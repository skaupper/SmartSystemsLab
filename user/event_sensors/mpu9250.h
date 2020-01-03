#ifndef MPU9250_H
#define MPU9250_H

#include "sensors.h"


struct MPU9250Data : public Serializable {
    std::string toJsonString() const override;

    uint64_t timeStamp;
    bool event;
    std::optional<double> gyro_x;
    std::optional<double> gyro_y;
    std::optional<double> gyro_z;
    std::optional<double> acc_x;
    std::optional<double> acc_y;
    std::optional<double> acc_z;
    std::optional<double> mag_x;
    std::optional<double> mag_y;
    std::optional<double> mag_z;
};

class MPU9250 : public StreamingSensor<MPU9250Data> {
public:
    MPU9250(double);

    std::string getTopic() const override;

protected:
    std::optional<MPU9250Data> doPoll() override;
};

#endif  // MPU9250_H
