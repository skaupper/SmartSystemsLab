#ifndef HDC1000_H
#define HDC1000_H

#include "sensors.h"


struct HDC1000Data : public Serializable {
    std::string toJsonString() const override;

    uint64_t timeStamp;
    double temperature;
    double humidity;
};

class HDC1000 : public StreamingSensor<HDC1000Data> {
public:
    using StreamingSensor::StreamingSensor;

    std::string getTopic() const override;

protected:
    std::optional<HDC1000Data> doPoll() override;
};

#endif // HDC1000_H
