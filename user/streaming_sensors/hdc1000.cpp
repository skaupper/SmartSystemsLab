#include "hdc1000.h"
#include "fpga.h"
#include <iostream>
#include <sstream>
#include <cstring>
#include "tsu.h"


std::string HDC1000::getTopic() const {
    static const std::string TOPIC_NAME = "sensors/hdc1000";
    return TOPIC_NAME;
}

std::optional<HDC1000Data> HDC1000::doPoll() {
    // TODO
    std::cout << "HDC1000" << std::endl;
    return std::nullopt;


    static const std::string CHARACTER_DEVICE = "/dev/hdc1000";

    static const int READ_SIZE = 12;
    static const int OFFSET_TEMPERATURE = 0;
    static const int OFFSET_HUMIDITY    = OFFSET_TEMPERATURE + sizeof(HDC1000Data::temperature);
    static const int OFFSET_TIMESTAMP   = OFFSET_HUMIDITY + sizeof(HDC1000Data::humidity);

    HDC1000Data results;
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
    memcpy(&results.temperature, readBuf + OFFSET_TEMPERATURE, sizeof(results.temperature));
    memcpy(&results.humidity,    readBuf + OFFSET_HUMIDITY,    sizeof(results.humidity));
    memcpy(&results.timeStamp,   readBuf + OFFSET_TIMESTAMP,   sizeof(results.timeStamp));


    // close character device
    (void) fclose(fd);

    return std::make_optional(results);
}

std::string HDC1000Data::toJsonString() const {
    std::stringstream ss;
    ss << "{";
    ss << "\"tmp\":"        << temperature << ",";
    ss << "\"hum\":"        << humidity    << ",";
    ss << "\"timestamp\":"  << TimeStampingUnit::getResolvedTimeStamp(timeStamp);
    ss << "}";
    return ss.str();
}
