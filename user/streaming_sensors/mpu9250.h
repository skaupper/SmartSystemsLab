#ifndef MPU9250_H
#define MPU9250_H

#include "sensors.h"

struct MPU9250Data : public Serializable
{
    std::string toJsonString() const override;

    struct
    {
        uint32_t timestamp_lo;
        uint32_t timestamp_hi;
        uint16_t gyro_x;
        uint16_t gyro_y;
        uint16_t gyro_z;
        uint16_t acc_x;
        uint16_t acc_y;
        uint16_t acc_z;
        uint16_t mag_x;
        uint16_t mag_y;
        uint16_t mag_z;
    } POD;
};

class MPU9250 : public StreamingSensor<MPU9250Data>
{
public:
    using StreamingSensor::StreamingSensor;

    std::string getTopic() const override;

protected:
    std::optional<MPU9250Data> doPoll() override;
};

#endif // MPU9250_H
