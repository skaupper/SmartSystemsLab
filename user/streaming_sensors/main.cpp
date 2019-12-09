#include <mqtt/client.h>

#include <chrono>
#include <functional>
#include <iostream>
#include <optional>
#include <sstream>
#include <string>
#include <thread>

#include "apds9301.h"
#include "fpga.h"
#include "hdc1000.h"
#include "mpu9250.h"
#include "sensors.h"

using namespace std::literals::chrono_literals;


template<class SENSOR>
void publishSensorData(SENSOR &sensor, mqtt::client &client) {
    std::stringstream msg;
    std::string payloadString;

    msg << "[";
    auto sensorValues = sensor.getQueue();
    // std::cout << sensorValues.size() << std::endl;
    bool first        = true;
    for (auto &v: sensorValues) {
        if (!first) {
            msg << ",";
        }
        first = false;
        msg << v.toJsonString();
    }
    msg << "]";
    payloadString = msg.str();
    // std::cout << payloadString << std::endl;

    client.publish(sensor.getTopic(), payloadString.data(), payloadString.size());
}


int main() {
    static const std::string SERVER_URI = "193.170.192.224:1883";
    static const std::string CLIENT_ID  = "streaming_sensors";

    try {
        initFPGA("streaming_sensors");
    } catch (const std::string &s) {
        std::cerr << "Failed to initialize FPGA: " << s << std::endl;
        return -1;
    }

    mqtt::client client(SERVER_URI, CLIENT_ID);
    client.connect();

    HDC1000 hdc1000(50);
    MPU9250 mpu9250(1000);
    APDS9301 apds9301(2.5);

    // start a thread for each sensor
    std::vector<std::thread> sensorThreads;
    sensorThreads.emplace_back(std::bind(&HDC1000::startPolling, &hdc1000));
    sensorThreads.emplace_back(std::bind(&MPU9250::startPolling, &mpu9250));
    sensorThreads.emplace_back(std::bind(&APDS9301::startPolling, &apds9301));


    while (true) {
        // std::cout << "HDC1000: ";
        publishSensorData(hdc1000, client);
        // std::cout << "MPU9250: ";
        publishSensorData(mpu9250, client);
        // std::cout << "APDS9301: ";
        publishSensorData(apds9301, client);
        std::this_thread::sleep_for(1000ms);
    }


    hdc1000.stop();
    mpu9250.stop();
    apds9301.stop();

    for (auto &&t: sensorThreads) {
        t.join();
    }
    return 0;
}
