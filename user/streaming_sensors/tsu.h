#ifndef TSU_H
#define TSU_H

#include <optional>


class TimeStampingUnit {
public:
    static uint64_t getResolvedTimeStamp(uint64_t);

private:
    static std::optional<uint64_t> calibrationHwTimestamp;
    static std::optional<uint64_t> calibrationMsSinceEpoch;
};

#endif
