#include "apds9301.h"
#include "fpga.h"
#include <iostream>
#include <sstream>
#include <cstring>
#include "tsu.h"



std::string APDS9301::getTopic() const {
    static const std::string TOPIC_NAME = "sensors/apds931";
    return TOPIC_NAME;
}


std::optional<APDS9301Data> APDS9301::doPoll() {
    static const std::string CHARACTER_DEVICE = "/dev/apds931";

    static const int READ_SIZE = sizeof(APDS9301Data::POD);
    APDS9301Data results{};

    // lock fpga device using a lock guard
    // the result is never used, but it keeps the mutex locked until it goes out of scope
    auto _lck = lockFPGA();

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

    // TODO: transform ADC values to useful units

    // close character device
    (void) fclose(fd);

    return std::make_optional(results);
}

std::string APDS9301Data::toJsonString() const {
    uint64_t timeStamp = (((uint64_t)POD.timestamp_hi) << 32) | POD.timestamp_lo;

    std::stringstream ss;
    ss << "{";
    ss << "\"ambient_light\":"  << POD.value << ",";
    ss << "\"timestamp\":"      << TimeStampingUnit::getResolvedTimeStamp(timeStamp);
    ss << "}";
    return ss.str();
}
