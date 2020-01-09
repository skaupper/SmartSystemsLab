#include <mqtt/client.h>
#include <mqtt/ssl_options.h>
#include <mqtt/connect_options.h>

#include <algorithm>
#include <chrono>
#include <cmath>
#include <functional>
#include <iostream>
#include <optional>
#include <sstream>
#include <string>
#include <thread>
#include <fstream>

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

/**
 * Check if the given trust store exists. If not, fall back to the system one.
 */
std::optional<std::string> getTrustStore(const std::string &certPath)
{
    static const std::string FALLBACK_CERT = "/etc/SmartSystemsLab/ca.crt";

    std::ifstream f(certPath);
    if (f) {
        return certPath;
    }

    f.open(FALLBACK_CERT);
    if (f) {
        std::cout << "Using fallback certificate" << std::endl;
        return FALLBACK_CERT;
    }

    std::cerr << "No certificate found" << std::endl;
    return std::nullopt;
}


int main() {
    static const std::string SERVER_URI = "ssl://193.170.192.224:8883";
    static const std::string CLIENT_ID  = "event_sensors";


#ifndef NO_SENSORS
    std::cout << "Operation mode: actual sensors" << std::endl;

    try {
        initFPGA("event_sensors");
    } catch (const std::string &s) {
        std::cerr << "Failed to initialize FPGA: " << s << std::endl;
        return -1;
    }
#else
    std::cout << "Operation mode: dummy data" << std::endl;
#endif

    //
    // Setup MQTT client
    //
    mqtt::client client(SERVER_URI, CLIENT_ID);
    mqtt::ssl_options sslOptions;
    auto trustStoreOpt = getTrustStore("ca.crt");
    if (!trustStoreOpt.has_value()) {
        return -1;
    }
    sslOptions.set_trust_store(trustStoreOpt.value());

    mqtt::connect_options options;
    options.set_ssl(sslOptions);

    client.connect(options);


    //
    // Setup sensors
    //
    HDC1000 hdc1000(50);
    MPU9250 mpu9250(2);
    APDS9301 apds9301(2.5);

    // start a thread for each sensor
    std::vector<std::thread> sensorThreads;
    sensorThreads.emplace_back(std::bind(&HDC1000::startPolling, &hdc1000));
    sensorThreads.emplace_back(std::bind(&MPU9250::startPolling, &mpu9250));
    sensorThreads.emplace_back(std::bind(&APDS9301::startPolling, &apds9301));


    //
    // Every second publish all available sensor data at once
    //
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

    //
    // Stop and cleanup threads
    //
    hdc1000.stop();
    mpu9250.stop();
    apds9301.stop();

    for (auto &&t: sensorThreads) {
        t.join();
    }
    return 0;
}
