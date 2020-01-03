#include <mqtt/client.h>

#include <algorithm>
#include <chrono>
#include <cmath>
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


template<class DATA>
void publishData(const std::vector<DATA> &data, const std::string &topic, mqtt::client &client) {
    static const int MAX_PACKETS_PER_BURST = 100;

    std::stringstream msg;
    std::string payloadString;


    // how many burst packets need to be sent?
    int bursts = std::ceil(1.0 * data.size() / MAX_PACKETS_PER_BURST);

    for (int b = 0; b < bursts; b++) {
        // the size of the current burst packet
        int size = std::min(MAX_PACKETS_PER_BURST, (int) data.size() - b * MAX_PACKETS_PER_BURST);

        msg.str("");
        msg << "[";

        bool first = true;
        for (int i = 0; i < size; i++) {
            auto &v = data[b * MAX_PACKETS_PER_BURST + i];
            if (!first) {
                msg << ",";
            }
            first = false;
            msg << v.toJsonString();
        }

        msg << "]";
        payloadString = msg.str();

        client.publish(topic, payloadString.data(), payloadString.size());
    }
}

template<class SENSOR>
void publishSensorData(SENSOR &sensor, mqtt::client &client) {
    auto pollingData = sensor.getQueue();
    auto eventData = sensor.getEventQueue();

    // std::cout << pollingData.size() << std::endl;

    publishData(pollingData, sensor.getTopic(), client);
    publishData(eventData, sensor.getTopic(), client);
}


int main() {
    static const std::string SERVER_URI = "193.170.192.224:1883";
    static const std::string CLIENT_ID  = "event_sensors";

    try {
        initFPGA("event_sensors");
    } catch (const std::string &s) {
        std::cerr << "Failed to initialize FPGA: " << s << std::endl;
        return -1;
    }

    mqtt::client client(SERVER_URI, CLIENT_ID);
    client.connect();

    HDC1000 hdc1000(50);
    // TODO: the MQTT lib has some problems with sending this much data, whats the cause for this?
    MPU9250 mpu9250(2);
    APDS9301 apds9301(2.5);

    // start a thread for each sensor
    std::vector<std::thread> sensorThreads;
    sensorThreads.emplace_back(std::bind(&HDC1000::startPolling, &hdc1000));
    sensorThreads.emplace_back(std::bind(&MPU9250::startPolling, &mpu9250));
    sensorThreads.emplace_back(std::bind(&APDS9301::startPolling, &apds9301));

    auto iterationEnd = std::chrono::high_resolution_clock::now();
    while (true) {
        iterationEnd += std::chrono::milliseconds(1000);

        // std::cout << "HDC1000: ";
        publishSensorData(hdc1000, client);
        // std::cout << "MPU9250: ";
        publishSensorData(mpu9250, client);
        // std::cout << "APDS9301: ";
        publishSensorData(apds9301, client);

        std::this_thread::sleep_until(iterationEnd);
    }


    hdc1000.stop();
    mpu9250.stop();
    apds9301.stop();

    for (auto &&t: sensorThreads) {
        t.join();
    }
    return 0;
}
