#ifndef APDS931_H
#define APDS931_H

#include "sensors.h"


struct APDS931Data : public Serializable {
    std::string toJsonString() const override;

    uint64_t timeStamp;
};

class APDS931 : public StreamingSensor<APDS931Data> {
public:
    using StreamingSensor::StreamingSensor;

    std::string getTopic() const override;

protected:
    std::optional<APDS931Data> doPoll() override;
};

#endif // APDS931_H
