#include "fpga.h"
#include "sensors.h"
#include "hdc1000.h"
#include "mpu9250.h"
#include "apds931.h"

#include <mqtt/client.h>

#include <iostream>
#include <string>
#include <chrono>
#include <optional>
#include <sstream>
#include <thread>

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
    // client.publish(HDC1000_TOPIC, payloadString.data(), payloadString.size());

    HDC1000 hdc1000(50);
    MPU9250 mpu9250(1000);
    APDS931 apds931(2.5);

    // start a thread for each sensor
    std::vector<std::thread> sensorThreads;
    sensorThreads.emplace_back(std::bind(&HDC1000::startPolling, &hdc1000));
    sensorThreads.emplace_back(std::bind(&MPU9250::startPolling, &mpu9250));
    sensorThreads.emplace_back(std::bind(&APDS931::startPolling, &apds931));


    // TODO: periodically publish queues


    std::this_thread::sleep_for(2000ms);
    hdc1000.stop();
    mpu9250.stop();
    apds931.stop();


    for (auto &&t: sensorThreads) {
        t.join();
    }
    return 0;
}
