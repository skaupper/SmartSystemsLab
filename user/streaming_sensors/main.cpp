#include "fpga.h"
#include "sensors.h"

#include <mqtt/client.h>

#include <iostream>
#include <string>
#include <chrono>
#include <optional>
#include <sstream>

using namespace std::literals::chrono_literals;



int main() {
    static const std::string SERVER_URI     = "193.170.192.224:1883";
    static const std::string CLIENT_ID      = "streaming_sensors";

    try {
        initFPGA("streaming_sensors");
    } catch (const std::string &s) {
        std::cerr << "Failed to initialize FPGA: " << s << std::endl;
        return -1;
    }

    mqtt::client client(SERVER_URI, CLIENT_ID);
    client.connect();



    while(1) {
        std::this_thread::sleep_for(1000ms);

        auto optValues = readFromCDev();
        if (!optValues.has_value()) {
            continue;
        }


        if (auto result = HDC1000::readFromCDev(); result.has_value()) {
            auto value = result.value();
            auto payload = value.toJsonString();
            client.publish(HDC1000::getSensorTopic(), payload.data(), payload.size());
        }

        auto values = optValues.value();
        auto payloadString = constructPayloadString(values);

        client.publish(HDC1000_TOPIC, payloadString.data(), payloadString.size());
    }

    return 0;
}
