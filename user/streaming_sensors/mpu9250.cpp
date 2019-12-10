#include "mpu9250.h"

#include <cstring>
#include <iostream>
#include <sstream>
#include <cmath>

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
