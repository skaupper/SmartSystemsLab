#ifndef APDS9301_H
#define APDS9301_H

#include "sensors.h"


struct APDS9301Data : public Serializable {
    std::string toJsonString() const override;

    struct
    {
        uint32_t timestamp_lo;
        uint32_t timestamp_hi;
        uint16_t value;
    } POD;
};

class APDS9301 : public StreamingSensor<APDS9301Data> {
public:
    using StreamingSensor::StreamingSensor;

    std::string getTopic() const override;

protected:
    std::optional<APDS9301Data> doPoll() override;
};

#endif // APDS9301_H
