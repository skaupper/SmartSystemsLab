#include <mqtt/client.h>
#include <mqtt/ssl_options.h>
#include <mqtt/connect_options.h>
#include <zlib.h>

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
#include <cassert>

#include "apds9301.h"
#include "fpga.h"
#include "hdc1000.h"
#include "mpu9250.h"
#include "sensors.h"

using namespace std::literals::chrono_literals;


void compressMemory(void *in_data, size_t in_data_size, std::vector<uint8_t> &out_data)
{
    std::vector<uint8_t> buffer;

    const size_t BUFSIZE = 128 * 1024;
    uint8_t temp_buffer[BUFSIZE];

    z_stream strm;
    strm.zalloc = 0;
    strm.zfree = 0;
    strm.next_in = reinterpret_cast<uint8_t *>(in_data);
    strm.avail_in = in_data_size;
    strm.next_out = temp_buffer;
    strm.avail_out = BUFSIZE;

    deflateInit(&strm, Z_BEST_COMPRESSION);

    while (strm.avail_in != 0)
    {
        int res = deflate(&strm, Z_NO_FLUSH);
        assert(res == Z_OK);
        if (strm.avail_out == 0)
        {
            buffer.insert(buffer.end(), temp_buffer, temp_buffer + BUFSIZE);
            strm.next_out = temp_buffer;
            strm.avail_out = BUFSIZE;
        }
    }

    int deflate_res = Z_OK;
    while (deflate_res == Z_OK)
    {
        if (strm.avail_out == 0)
        {
            buffer.insert(buffer.end(), temp_buffer, temp_buffer + BUFSIZE);
            strm.next_out = temp_buffer;
            strm.avail_out = BUFSIZE;
        }
        deflate_res = deflate(&strm, Z_FINISH);
    }

    assert(deflate_res == Z_STREAM_END);
    buffer.insert(buffer.end(), temp_buffer, temp_buffer + BUFSIZE - strm.avail_out);
    deflateEnd(&strm);

    out_data.swap(buffer);
}

template <class DATA>
void publishData(const std::vector<DATA> &data, const std::string &topic, mqtt::client &client)
{
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

        std::vector<uint8_t> compressedPayload;
        compressMemory(payloadString.data(), payloadString.size(), compressedPayload);

        client.publish(topic, compressedPayload.data(), compressedPayload.size());
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


int main(int argc, char *argv[]) {
    static const std::string SERVER_URI = "ssl://193.170.192.224:8883";
    static const std::string CLIENT_ID  = "event_sensors";
    static const int DEFAULT_THRESHOLD = 12000;

    //
    // Parse CLI arguments
    //
    int threshold = DEFAULT_THRESHOLD;

    if (argc > 2) {
        std::cerr << "Usage: " << argv[0] << " [<event_threshold>]" << std::endl;
        return -1;
    } else if (argc == 2) {
        try {
            size_t idx = 0;
            threshold = std::stoi(argv[1], &idx);

            if (idx < strlen(argv[1])) {
                throw std::invalid_argument(argv[1]);
            }
        } catch (const std::invalid_argument &ex) {
            std::cerr << "Argument '" << argv[1] << "' cannot be parsed as an integer" << std::endl;
            return -1;
        }
    }


    //
    // Check operation mode
    //
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
    MPU9250 mpu9250(2, threshold);
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
