#include "apds9301.h"

#include <cstring>
#include <iostream>
#include <sstream>

#include "fpga.h"
#include "tsu.h"

struct APDS9301POD {
    uint32_t timestamp_lo;
    uint32_t timestamp_hi;
    uint16_t value;
} __attribute__((packed));


std::string APDS9301::getTopic() const {
    static const std::string TOPIC_NAME = "sensors/apds9301";
    return TOPIC_NAME;
}


void APDS9301::doProcess(APDS9301Data const &data) {
#ifdef NO_SENSORS
    // nothing to process here
    return;
#endif

    //
    // dimm 7-segment display according to the latest light intensity
    //

    static const int SEGMENT_COUNT            = 6;
    static const std::string CHARACTER_DEVICE = "/dev/sevensegment";

    uint8_t brightness            = data.value >> 8;
    uint8_t values[SEGMENT_COUNT] = {0};

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
#ifdef NO_SENSORS
    static int c = 0;

    APDS9301Data data{};
    data.timeStamp = TimeStampingUnit::getCurrentTimeStamp();
    data.value = 10 * c;

    c = (c + 1) % 100;
    return data;
#endif

    static const std::string CHARACTER_DEVICE = "/dev/apds9301";

    static const int READ_SIZE = sizeof(APDS9301POD);
    APDS9301Data results {};
    APDS9301POD pod = {};


    // lock fpga device using a lock guard
    // the result is never used, but it keeps the mutex locked until it goes out of scope
    auto _lck = lockFPGA();

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
    results.value = pod.value;

    // close character device
    (void) fclose(fd);

    return std::make_optional(results);
}

std::string APDS9301Data::toJsonString() const {
    std::stringstream ss;
    ss << "{";
    ss << "\"ambient_light\":" << value << ",";
    ss << "\"timestamp\":" << timeStamp;
    ss << "}";
    return ss.str();
}
