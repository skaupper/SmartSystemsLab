#include "hdc1000.h"

#include <cstring>
#include <iostream>
#include <sstream>

#include "fpga.h"
#include "tsu.h"


std::string HDC1000::getTopic() const {
    static const std::string TOPIC_NAME = "sensors/hdc1000";
    return TOPIC_NAME;
}

std::optional<HDC1000Data> HDC1000::doPoll() {
    static const std::string CHARACTER_DEVICE = "/dev/hdc1000";

    static const int READ_SIZE          = 12;
    static const int OFFSET_TEMPERATURE = 0;
    static const int OFFSET_HUMIDITY    = OFFSET_TEMPERATURE + 2;
    static const int OFFSET_TIMESTAMP   = OFFSET_HUMIDITY + 2;

    HDC1000Data results;
    uint16_t temperature;
    uint16_t humidity;
    uint32_t timeStamp;
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
    memcpy(&temperature, readBuf + OFFSET_TEMPERATURE, sizeof(temperature));
    memcpy(&humidity, readBuf + OFFSET_HUMIDITY, sizeof(humidity));
    memcpy(&timeStamp, readBuf + OFFSET_TIMESTAMP, sizeof(timeStamp));



    results.timeStamp = TimeStampingUnit::getResolvedTimeStamp(timeStamp);
    // calculations according to the datasheet
    results.humidity    = (humidity * 100) / 65536.;
    results.temperature = (temperature * 165) / 65536. - 40;

    // close character device
    (void) fclose(fd);

    return std::make_optional(results);
}

std::string HDC1000Data::toJsonString() const {
    std::stringstream ss;
    ss << "{";
    ss << "\"tmp\":" << temperature << ",";
    ss << "\"hum\":" << humidity << ",";
    ss << "\"timestamp\":" << timeStamp;
    ss << "}";
    return ss.str();
}
