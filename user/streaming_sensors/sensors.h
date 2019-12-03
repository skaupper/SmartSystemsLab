#ifndef SENSORS_H
#define SENSORS_H

#include <string>
#include <optional>
#include <thread>
#include <mutex>
#include <vector>
#include <iostream>


template<class T>
class StreamingSensor {
public:
    StreamingSensor(double frequency): frequency(frequency) {}
    virtual ~StreamingSensor() {}

    virtual std::string getTopic() const = 0;

    std::vector<T> getQueue() {
        std::lock_guard lck(queueMutex);
        auto result = std::move(*currentQueue);

        // calculate next queue
        currentQueueIndex++;
        currentQueueIndex %= QUEUE_COUNT;
        currentQueue = &queues[currentQueueIndex];

        return result;
    }

    void startPolling() {
        const std::chrono::milliseconds delay { static_cast<int>(1000 / frequency) };
        running = true;

        while(running) {
            auto before = std::chrono::high_resolution_clock::now();

            auto result = doPoll();
            if (result.has_value()) {
                doStore(result.value());
            }

            auto after = std::chrono::high_resolution_clock::now();
            auto actualDelay = delay;
            if (after > before) {
                actualDelay -= std::chrono::duration_cast<std::chrono::milliseconds>(after - before);
            } else {
                actualDelay = std::chrono::milliseconds{0};
            }
            std::this_thread::sleep_for(actualDelay);
        }

        std::cout << "Stopped" << std::endl;
    }

    void stop() {
        running = false;
    }

protected:
    virtual std::optional<T> doPoll() = 0;
    void doStore(T const &data) {
        std::lock_guard lck(queueMutex);
        currentQueue->push_back(data);
    }

private:
    const double frequency;
    static const int QUEUE_COUNT = 2;

    bool running;

    std::mutex queueMutex;

    int currentQueueIndex = 0;
    std::vector<T> *currentQueue = &queues[currentQueueIndex];
    std::vector<T> queues[QUEUE_COUNT];
};


class Serializable {
public:
    virtual std::string toJsonString() const = 0;
};


#endif
