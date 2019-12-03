#ifndef MPU9250_H
#define MPU9250_H

#include "sensors.h"


struct MPU9250Data : public Serializable {
    std::string toJsonString() const override;

    uint64_t timeStamp;
};

class MPU9250 : public StreamingSensor<MPU9250Data> {
public:
    using StreamingSensor::StreamingSensor;

    std::string getTopic() const override;

protected:
    std::optional<MPU9250Data> doPoll() override;
};

#endif // MPU9250_H
