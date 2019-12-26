#include "mpu9250.h"

#include <cstring>
#include <iostream>
#include <sstream>
#include <cmath>
#include <functional>
#include <signal.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <fcntl.h>

#include "fpga.h"
#include "tsu.h"


/* IO Control (IOCTL) */
#define IOC_MODE_POLLING 0
#define IOC_MODE_BUFFER 1
#define IOC_CMD_SET_READ_POLLING _IO(4711, IOC_MODE_POLLING)
#define IOC_CMD_SET_READ_BUFFER _IO(4711, IOC_MODE_BUFFER)

#define SIG_USR1 10


static const std::string CHARACTER_DEVICE = "/dev/mpu9250";
static std::mutex mpuMutex;


static void signalHandler(int n, siginfo_t *info, void *unused) {
    auto _fpgaLck = lockFPGA();
    std::unique_lock _mpuLck(mpuMutex);


    auto fd = open(CHARACTER_DEVICE.c_str(), O_RDWR);
    if (fd == -1) {
        std::cerr << "Failed to open character device in signal handler" << std::endl;
        return;
    }

    // request the event buffers
    if(ioctl(fd, IOC_CMD_SET_READ_BUFFER) < 0) {
        std::cerr << "Requesting the event buffers failed: " << strerror(errno) << std::endl;
        close(fd);
        return;
    }





    // reset the mode to polling mode
    if(ioctl(fd, IOC_CMD_SET_READ_POLLING) < 0) {
        std::cerr << "Requesting polling mode failed: " << strerror(errno) << std::endl;
        std::cerr << "ATTENTION: The application invariants are broken now! An application restart is required!" << std::endl;
        close(fd);
        return;
    }

    close(fd);
}



std::string MPU9250::getTopic() const {
    static const std::string TOPIC_NAME = "sensors/mpu9250";
    return TOPIC_NAME;
}

MPU9250::MPU9250(double frequency) : StreamingSensor(frequency) {
    struct sigaction sig;
    sig.sa_sigaction = signalHandler;
    sig.sa_flags = SA_SIGINFO;
    sigaction(SIG_USR1, &sig, NULL);
}

std::optional<MPU9250Data> MPU9250::doPoll() {
    return std::nullopt;

    static const int READ_SIZE = sizeof(MPU9250Data::POD);
    MPU9250Data results {};

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

    if (fread(&results.POD, READ_SIZE, 1, fd) != 1) {
        std::cerr << "Failed to read sensor values" << std::endl;
        return {};
    }

    //
    // Translate values to more meaningful units
    //

    // all sensors provide 16bit values proportionally to its full scale ranges
    static const double GYRO_FULL_SCALE = 2000.0;               // degrees per second
    static const double MAG_FULL_SCALE  = 4800.0;               // micro tesla
    static const double ACC_FULL_SCALE  = 4.0;                  // g

    static const int ADC_MAX_VAL        = std::pow(2, 16 - 1);  // values are signed integer

    results.gyro_x = results.POD.gyro_x * GYRO_FULL_SCALE / ADC_MAX_VAL;
    results.gyro_y = results.POD.gyro_y * GYRO_FULL_SCALE / ADC_MAX_VAL;
    results.gyro_z = results.POD.gyro_z * GYRO_FULL_SCALE / ADC_MAX_VAL;
    results.mag_x  = results.POD.mag_x * MAG_FULL_SCALE / ADC_MAX_VAL;
    results.mag_y  = results.POD.mag_y * MAG_FULL_SCALE / ADC_MAX_VAL;
    results.mag_z  = results.POD.mag_z * MAG_FULL_SCALE / ADC_MAX_VAL;
    results.acc_x  = results.POD.acc_x * ACC_FULL_SCALE / ADC_MAX_VAL;
    results.acc_y  = results.POD.acc_y * ACC_FULL_SCALE / ADC_MAX_VAL;
    results.acc_z  = results.POD.acc_z * ACC_FULL_SCALE / ADC_MAX_VAL;

    // close character device
    (void) fclose(fd);

    return std::make_optional(results);
}

std::string MPU9250Data::toJsonString() const {
    uint64_t timeStamp = (((uint64_t) POD.timestamp_hi) << 32) | POD.timestamp_lo;

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
