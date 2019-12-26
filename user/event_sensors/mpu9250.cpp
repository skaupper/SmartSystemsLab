#include "mpu9250.h"

#include <signal.h>
#include <sys/ioctl.h>

#include <cmath>
#include <cstring>
#include <functional>
#include <iostream>
#include <sstream>

#include "fpga.h"
#include "mpu9250_conversion.txx"
#include "tsu.h"


/* IO Control (IOCTL) */
#define IOC_MODE_POLLING         0
#define IOC_MODE_BUFFER          1
#define IOC_CMD_SET_READ_POLLING _IO(4711, IOC_MODE_POLLING)
#define IOC_CMD_SET_READ_BUFFER  _IO(4711, IOC_MODE_BUFFER)

#define SIG_USR1 10


#define EVENT_PACKETS 1024

using namespace std::placeholders;


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



static const std::string CHARACTER_DEVICE = "/dev/mpu9250";
static std::mutex mpuMutex;
static std::function<void(std::vector<MPU9250Data> &&)> fSetEventQueue;


static void signalHandler(int n, siginfo_t *info, void *unused) {
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

            // TODO: do we need the remaining fields?
            data.acc_x  = pod.acc_x[i];
            data.acc_y  = pod.acc_y[i];
            data.acc_z  = pod.acc_z[i];
            data.gyro_x = pod.gyro_x[i];
            data.gyro_y = pod.gyro_y[i];
            data.gyro_z = pod.gyro_z[i];

            convertAccUnits(data, data);
            convertGyroUnits(data, data);

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



std::string MPU9250::getTopic() const {
    static const std::string TOPIC_NAME = "sensors/mpu9250";
    return TOPIC_NAME;
}

MPU9250::MPU9250(double frequency) : StreamingSensor(frequency) {
    fSetEventQueue = std::bind(&MPU9250::setEventQueue, this, _1);

    struct sigaction sig;
    sig.sa_sigaction = signalHandler;
    sig.sa_flags     = SA_SIGINFO;
    sigaction(SIG_USR1, &sig, NULL);
}

std::optional<MPU9250Data> MPU9250::doPoll() {
    static const int READ_SIZE = sizeof(MPU9250PollingPOD);
    MPU9250Data results {};
    MPU9250PollingPOD pod {};


    // lock fpga device using a lock guard
    // the result is never used, but it keeps the mutex locked until it goes out of scope
    auto _fpgaLck = lockFPGA();
    std::unique_lock _mpuLck(mpuMutex);

    // open character device
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
    convertAccUnits(pod, results);
    convertMagUnits(pod, results);
    convertGyroUnits(pod, results);

    // close character device
    (void) fclose(fd);

    return std::make_optional(results);
}

std::string MPU9250Data::toJsonString() const {
    std::stringstream ss;
    ss << "{";
    ss << "\"gyro_x\":" << gyro_x << ",";
    ss << "\"gyro_y\":" << gyro_y << ",";
    ss << "\"gyro_z\":" << gyro_z << ",";
    ss << "\"acc_x\":" << acc_x << ",";
    ss << "\"acc_y\":" << acc_y << ",";
    ss << "\"acc_z\":" << acc_z << ",";
    ss << "\"mag_x\":" << mag_x << ",";
    ss << "\"mag_y\":" << mag_y << ",";
    ss << "\"mag_z\":" << mag_z << ",";
    ss << "\"timestamp\":" << TimeStampingUnit::getResolvedTimeStamp(timeStamp);
    ss << "}";
    return ss.str();
}
