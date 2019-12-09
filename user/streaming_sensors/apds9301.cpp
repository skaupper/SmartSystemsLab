#include "apds9301.h"

#include <cstring>
#include <iostream>
#include <sstream>

#include "fpga.h"
#include "tsu.h"


std::string APDS9301::getTopic() const {
    static const std::string TOPIC_NAME = "sensors/apds9301";
    return TOPIC_NAME;
}


void APDS9301::doProcess(APDS9301Data const &data) {
    //
    // dimm 7-segment display according to the latest light intensity
    //

    static const int SEGMENT_COUNT = 6;
    static const std::string CHARACTER_DEVICE = "/dev/sevensegment";

    // TODO: do we see something?
    uint8_t brightness = data.POD.value >> 8;
    // brightness = 0x7f;
    uint8_t values[SEGMENT_COUNT]   = {'0', '0', '0', '0', '0', '0'};

    auto _lck = lockFPGA();

    // open character device
    auto fd = fopen(CHARACTER_DEVICE.c_str(), "wb");
    if (!fd) {
        std::cerr << "Failed to open character device '" << CHARACTER_DEVICE << "'" << std::endl;
        return;
    }

    // write display values
    for (int i = 0; i < SEGMENT_COUNT; ++i) {
        if (fputc(values[i], fd) == EOF) {
            std::cerr << "Failed to write character (index " << i << ")" << std::endl;
            fclose(fd);
            return;
        }
    }

    // write brightness level
    if (fputc(brightness, fd) == EOF) {
        std::cerr << "Failed to write brightness level" << std::endl;
        fclose(fd);
        return;
    }

    // write enable bits
    if (fputc(0xff, fd) == EOF) {
        std::cerr << "Failed to write enable bits" << std::endl;
        fclose(fd);
        return;
    }

    (void) fclose(fd);
}

std::optional<APDS9301Data> APDS9301::doPoll() {
    static const std::string CHARACTER_DEVICE = "/dev/apds9301";

    static const int READ_SIZE = sizeof(APDS9301Data::POD);
    APDS9301Data results {};


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

    // TODO: transform ADC values to useful units if necessary

    // close character device
    (void) fclose(fd);

    return std::make_optional(results);
}

std::string APDS9301Data::toJsonString() const {
    uint64_t timeStamp = (((uint64_t) POD.timestamp_hi) << 32) | POD.timestamp_lo;

    std::stringstream ss;
    ss << "{";
    ss << "\"ambient_light\":" << POD.value << ",";
    ss << "\"timestamp\":" << TimeStampingUnit::getResolvedTimeStamp(timeStamp);
    ss << "}";
    return ss.str();
}
