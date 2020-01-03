#include "mpu9250.h"

#include <signal.h>
#include <sys/ioctl.h>

#include <cmath>
#include <cstring>
#include <functional>
#include <iostream>
#include <sstream>

#include <iomanip>

#include "fpga.h"
#include "mpu9250_conversion.txx"
#include "tsu.h"


using namespace std::placeholders;



/* Helper macro for creating the JSON string. */
#define ADD_FIELD_IF_AVAILABLE(stream, f)                                                                              \
    do {                                                                                                               \
        if (f.has_value()) {                                                                                           \
            stream << "\"" #f "\":" << f.value() << ",";                                                               \
        }                                                                                                              \
    } while (0)


/* IO Control (IOCTL) */
#define IOC_MODE_POLLING         0
#define IOC_MODE_BUFFER          1
#define IOC_CMD_SET_READ_POLLING _IO(4711, IOC_MODE_POLLING)
#define IOC_CMD_SET_READ_BUFFER  _IO(4711, IOC_MODE_BUFFER)


/* Event specific defines */
#define EVENT_SIGNAL_NR 10
#define EVENT_PACKETS   1024


/* Data structures used for reading the character device */
struct MPU9250PollingPOD {
    uint32_t timestamp_lo;
    uint32_t timestamp_hi;
    int16_t gyro_x;
    int16_t gyro_y;
    int16_t gyro_z;
    int16_t acc_x;
    int16_t acc_y;
    int16_t acc_z;
    int16_t mag_x;
    int16_t mag_y;
    int16_t mag_z;
} __attribute__((packed));

struct MPU9250EventPOD {
    uint16_t acc_x[EVENT_PACKETS];
    uint16_t acc_y[EVENT_PACKETS];
    uint16_t acc_z[EVENT_PACKETS];
    uint16_t gyro_x[EVENT_PACKETS];
    uint16_t gyro_y[EVENT_PACKETS];
    uint16_t gyro_z[EVENT_PACKETS];
} __attribute__((packed));


/* Constants and variables used to communication with the CDEV and the main application */
static const std::string CHARACTER_DEVICE = "/dev/mpu9250";
static std::mutex mpuMutex;
static std::function<void(std::vector<MPU9250Data> &&)> fSetEventQueue;



//
// Implementation of the sensor in event mode
//

static void eventDataReady(int, siginfo_t *, void *) {
    static const int READ_SIZE = sizeof(MPU9250EventPOD);
    MPU9250EventPOD pod;

    auto _fpgaLck = lockFPGA();
    std::unique_lock _mpuLck(mpuMutex);


    auto fd = fopen(CHARACTER_DEVICE.c_str(), "rb");
    if (!fd) {
        std::cerr << "Failed to open character device in signal handler" << std::endl;
        return;
    }

    // request the event buffers
    if (ioctl(fileno(fd), IOC_CMD_SET_READ_BUFFER) < 0) {
        std::cerr << "Requesting the event buffers failed: " << strerror(errno) << std::endl;
        fclose(fd);
        return;
    }


    auto readSuccessful = true;
    if (fread(&pod, READ_SIZE, 1, fd) != 1) {
        std::cerr << "Failed to read event data" << std::endl;
        readSuccessful = false;
    }

    if (readSuccessful) {
        std::vector<MPU9250Data> eventData;

        for (int i = 0; i < EVENT_PACKETS; ++i) {
            MPU9250Data data = {};
            MPU9250PollingPOD tmp;

            // TODO: do we need the remaining fields?
            tmp.acc_x  = pod.acc_x[i];
            tmp.acc_y  = pod.acc_y[i];
            tmp.acc_z  = pod.acc_z[i];
            tmp.gyro_x = pod.gyro_x[i];
            tmp.gyro_y = pod.gyro_y[i];
            tmp.gyro_z = pod.gyro_z[i];

            // std::cout << "Acc : x: " << std::hex << tmp.acc_x << ", y: " << std::hex << tmp.acc_y << ", z: " << std::hex << tmp.acc_z << std::endl;
            // std::cout << "Gyro: x: " << std::hex << tmp.gyro_x << ", y: " << std::hex << tmp.gyro_y << ", z: " << std::hex << tmp.gyro_z << std::endl;
            // std::cout << std::endl;

            data.event = true;
            convertAccUnits(tmp, data);
            convertGyroUnits(tmp, data);

            eventData.emplace_back(std::move(data));
        }

        fSetEventQueue(std::move(eventData));
    }


    // reset the mode to polling mode
    if (ioctl(fileno(fd), IOC_CMD_SET_READ_POLLING) < 0) {
        std::cerr << "Requesting polling mode failed: " << strerror(errno) << std::endl;
        std::cerr << "ATTENTION: The application invariants are broken now! An application restart is required!"
                  << std::endl;
        fclose(fd);
        return;
    }

    fclose(fd);
}



//
// Implementation of the sensor in polling mode
//

std::string MPU9250::getTopic() const {
    static const std::string TOPIC_NAME = "sensors/mpu9250";
    return TOPIC_NAME;
}

MPU9250::MPU9250(double frequency) : StreamingSensor(frequency) {
    fSetEventQueue = std::bind(&MPU9250::setEventQueue, this, _1);

    struct sigaction sig;
    sig.sa_sigaction = eventDataReady;
    sig.sa_flags     = SA_SIGINFO;
    sigaction(EVENT_SIGNAL_NR, &sig, NULL);
}

std::optional<MPU9250Data> MPU9250::doPoll() {
    static const int READ_SIZE = sizeof(MPU9250PollingPOD);
    MPU9250Data results {};
    MPU9250PollingPOD pod {};


    // lock fpga device using a lock guard
    // the result is never used, but it keeps the mutex locked until it goes out of scope
    auto _fpgaLck = lockFPGA();
    std::unique_lock _mpuLck(mpuMutex);


    auto fd = fopen(CHARACTER_DEVICE.c_str(), "rb");
    if (!fd) {
        std::cerr << "Failed to open character device '" << CHARACTER_DEVICE << "'" << std::endl;
        return {};
    }


    if (fread(&pod, READ_SIZE, 1, fd) != 1) {
        std::cerr << "Failed to read sensor values" << std::endl;
        return {};
    }


    results.timeStamp = (((uint64_t) pod.timestamp_hi) << 32) | pod.timestamp_lo;
    results.event = false;
    convertAccUnits(pod, results);
    convertMagUnits(pod, results);
    convertGyroUnits(pod, results);


    (void) fclose(fd);

    return results;
}

std::string MPU9250Data::toJsonString() const {
    std::stringstream ss;
    ss << "{";

    ADD_FIELD_IF_AVAILABLE(ss, gyro_x);
    ADD_FIELD_IF_AVAILABLE(ss, gyro_y);
    ADD_FIELD_IF_AVAILABLE(ss, gyro_z);
    ADD_FIELD_IF_AVAILABLE(ss, acc_x);
    ADD_FIELD_IF_AVAILABLE(ss, acc_y);
    ADD_FIELD_IF_AVAILABLE(ss, acc_z);
    ADD_FIELD_IF_AVAILABLE(ss, mag_x);
    ADD_FIELD_IF_AVAILABLE(ss, mag_y);
    ADD_FIELD_IF_AVAILABLE(ss, mag_z);

    ss << "\"event\":" << event << ",";
    ss << "\"timestamp\":" << TimeStampingUnit::getResolvedTimeStamp(timeStamp);
    ss << "}";
    return ss.str();
}
