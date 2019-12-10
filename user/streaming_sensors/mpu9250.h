#ifndef MPU9250_H
#define MPU9250_H

#include "sensors.h"

struct MPU9250Data : public Serializable {
    std::string toJsonString() const override;

    struct {
        uint32_t timestamp_lo;
        uint32_t timestamp_hi;
        int16_t gyro_x;
        int16_t gyro_y;
        int16_t gyro_z;
        int16_t acc_x;
        int16_t acc_y;
        int16_t acc_z;
        int16_t mag_x;
        int16_t mag_y;
        int16_t mag_z;
    } __attribute__((packed)) POD;

    double gyro_x;
    double gyro_y;
    double gyro_z;
    double acc_x;
    double acc_y;
    double acc_z;
    double mag_x;
    double mag_y;
    double mag_z;
};

class MPU9250 : public StreamingSensor<MPU9250Data> {
public:
    using StreamingSensor::StreamingSensor;

    std::string getTopic() const override;

protected:
    std::optional<MPU9250Data> doPoll() override;
};

#endif  // MPU9250_H
