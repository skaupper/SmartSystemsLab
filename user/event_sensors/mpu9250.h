#ifndef MPU9250_H
#define MPU9250_H

#include "sensors.h"


struct MPU9250Data : public Serializable {
    std::string toJsonString() const override;

    uint64_t timeStamp;
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
    MPU9250(double);

    std::string getTopic() const override;

protected:
    std::optional<MPU9250Data> doPoll() override;
};

#endif  // MPU9250_H
