#include "tsu.h"
#include <chrono>


std::optional<uint64_t> TimeStampingUnit::calibrationHwTimestamp;
std::optional<uint64_t> TimeStampingUnit::calibrationMsSinceEpoch;


uint64_t TimeStampingUnit::getResolvedTimeStamp(uint64_t hwTimeStamp) {
    if (!calibrationHwTimestamp.has_value()) {
        auto durationSinceEpoch = std::chrono::high_resolution_clock::now().time_since_epoch();
        uint64_t msSinceEpoch = std::chrono::duration_cast<std::chrono::milliseconds>(durationSinceEpoch).count();

        calibrationHwTimestamp = hwTimeStamp;
        calibrationMsSinceEpoch = msSinceEpoch;
    }

    return (hwTimeStamp - calibrationHwTimestamp.value()) + calibrationMsSinceEpoch.value();
}
