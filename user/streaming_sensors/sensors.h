#ifndef SENSORS_H
#define SENSORS_H

#include <string>
#include <optional>


class HDC1000 {
public:
    static std::string getSensorTopic();
    static std::optional<HDC1000> readFromCDev();
    std::string toJsonString() const;

private:
    static const std::string CHARACTER_DEVICE = "/dev/humid_temp";
    static const std::string TOPIC_NAME = "sensor/hdc1000";

    uint64_t timeStamp;
    uint16_t temperature;
    uint16_t humidity;
};


class MPU9250 {
public:
    static std::string getSensorTopic();
    static std::optional<HDC1000> readFromCDev();
    std::string toJsonString() const;

private:
    static const std::string CHARACTER_DEVICE = "/dev/humid_temp";
    static const std::string TOPIC_NAME = "sensor/mpu9250";

    uint64_t timeStamp;
    // TODO
};

#endif
