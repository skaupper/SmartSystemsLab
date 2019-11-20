#include "mqtt/client.h"


#include <cstdio>
#include <cstdint>

#include <iostream>
#include <string>
#include <thread>
#include <chrono>
#include <optional>
#include <sstream>

using namespace std::literals::chrono_literals;



struct HDC1000 {
    uint64_t timeStamp;
    uint16_t temperature;
    uint16_t humidity;
};

std::optional<HDC1000> readFromCDev() {
    static const std::string CHARACTER_DEVICE = "/dev/humid_temp";
    static const int READ_SIZE = 12;

    static const int OFFSET_TEMPERATURE = 0;
    static const int OFFSET_HUMIDITY    = OFFSET_TEMPERATURE + sizeof(HDC1000::temperature);
    static const int OFFSET_TIMESTAMP   = OFFSET_HUMIDITY + sizeof(HDC1000::humidity);

    HDC1000 results;
    uint8_t readBuf[READ_SIZE];

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

std::string constructPayloadString(HDC1000 payload) {
    std::stringstream ss;
    ss << "{";
    ss << "\"tmp\":"        << payload.temperature << ",";
    ss << "\"hum\":"        << payload.humidity    << ",";
    ss << "\"timestamp\":"  << payload.timeStamp;
    ss << "}";
    return ss.str();
}



int main() {
    static const std::string SERVER_URI     = "193.170.192.224:1883";
    static const std::string CLIENT_ID      = "HDC1000_client";
    static const std::string HDC1000_TOPIC  = "sensor/hdc1000";

    mqtt::client client(SERVER_URI, CLIENT_ID);
    client.connect();


    while(1) {
        std::this_thread::sleep_for(1000ms);

        auto optValues = readFromCDev();
        if (!optValues.has_value()) {
            continue;
        }

        auto values = optValues.value();
        auto payloadString = constructPayloadString(values);

        client.publish(HDC1000_TOPIC, payloadString.data(), payloadString.size());
    }

    return 0;
}
