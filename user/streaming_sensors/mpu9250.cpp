#include "mpu9250.h"

#include <cstring>
#include <iostream>
#include <sstream>

#include "fpga.h"
#include "tsu.h"


std::string MPU9250::getTopic() const {
    static const std::string TOPIC_NAME = "sensors/mpu9250";
    return TOPIC_NAME;
}


std::optional<MPU9250Data> MPU9250::doPoll() {
    static const std::string CHARACTER_DEVICE = "/dev/mpu9250";

    static const int READ_SIZE = sizeof(MPU9250Data::POD);
    MPU9250Data results {};

    // lock fpga device using a lock guard
    // the result is never used, but it keeps the mutex locked until it goes out of scope
    auto _lck = lockFPGA();

    // open character device
    auto fd = fopen(CHARACTER_DEVICE.c_str(), "rb");
    if (!fd) {
        std::cerr << "Failed to open character device '" << CHARACTER_DEVICE << "'" << std::endl;
        return {};
    }

    // TODO: is this working the way I think it is?
    if (fread(&results.POD, READ_SIZE, 1, fd) != 1) {
        std::cerr << "Failed to read sensor values" << std::endl;
        return {};
    }

    // TODO: transform ADC values to useful units

    // close character device
    (void) fclose(fd);

    return std::make_optional(results);
}

std::string MPU9250Data::toJsonString() const {
    uint64_t timeStamp = (((uint64_t) POD.timestamp_hi) << 32) | POD.timestamp_lo;

    std::stringstream ss;
    ss << "{";
    ss << "\"gyro_x\":" << POD.gyro_x << ",";
    ss << "\"gyro_y\":" << POD.gyro_y << ",";
    ss << "\"gyro_z\":" << POD.gyro_z << ",";
    ss << "\"acc_x\":" << POD.acc_x << ",";
    ss << "\"acc_y\":" << POD.acc_y << ",";
    ss << "\"acc_z\":" << POD.acc_z << ",";
    ss << "\"mag_x\":" << POD.mag_x << ",";
    ss << "\"mag_y\":" << POD.mag_y << ",";
    ss << "\"mag_z\":" << POD.mag_z << ",";
    ss << "\"timestamp\":" << TimeStampingUnit::getResolvedTimeStamp(timeStamp);
    ss << "}";
    return ss.str();
}
