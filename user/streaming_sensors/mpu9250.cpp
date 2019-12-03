#include "mpu9250.h"
#include "fpga.h"
#include <iostream>
#include <sstream>
#include <cstring>
#include "tsu.h"



std::string MPU9250::getTopic() const {
    static const std::string TOPIC_NAME = "sensors/mpu9250";
    return TOPIC_NAME;
}


std::optional<MPU9250Data> MPU9250::doPoll() {
    // TODO
    return std::nullopt;
    std::cout << "MPU9250" << std::endl;
    return std::nullopt;


    static const std::string CHARACTER_DEVICE = "/dev/mpu9250";

    // TODO
    static const int READ_SIZE = 1;
    // static const int OFFSET_TEMPERATURE = 0;
    // static const int OFFSET_HUMIDITY    = OFFSET_TEMPERATURE + sizeof(MPU9250::temperature);
    // static const int OFFSET_TIMESTAMP   = OFFSET_HUMIDITY + sizeof(MPU9250::humidity);

    MPU9250Data results{};
    uint8_t readBuf[READ_SIZE];

    // lock fpga device using a lock guard
    // the result is never used, but it keeps the mutex locked until it goes out of scope
    auto _lck = lockFPGA();

    // open character device
    auto fd = fopen(CHARACTER_DEVICE.c_str(), "rb");
    if (!fd) {
        std::cerr << "Failed to open character device '" << CHARACTER_DEVICE << "'" << std::endl;
        return {};
    }

    if (fread(readBuf, READ_SIZE, 1, fd) != 1) {
        std::cerr << "Failed to read sensor values" << std::endl;
        return {};
    }

    // copy sensor values to struct
    // memcpy(&results.temperature, readBuf + OFFSET_TEMPERATURE, sizeof(results.temperature));
    // memcpy(&results.humidity,    readBuf + OFFSET_HUMIDITY,    sizeof(results.humidity));
    // memcpy(&results.timeStamp,   readBuf + OFFSET_TIMESTAMP,   sizeof(results.timeStamp));


    // close character device
    (void) fclose(fd);

    return std::make_optional(results);
}

std::string MPU9250Data::toJsonString() const {
    std::stringstream ss;
    ss << "{";
    // TODO
    // ss << "\"tmp\":"        << temperature << ",";
    // ss << "\"hum\":"        << humidity    << ",";
    ss << "\"timestamp\":"  << TimeStampingUnit::getResolvedTimeStamp(timeStamp);
    ss << "}";
    return ss.str();
}
