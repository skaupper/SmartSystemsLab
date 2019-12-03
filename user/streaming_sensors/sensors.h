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
    std::vector<T> getQueue();
    void startPolling();
    void stop();

protected:
    virtual std::optional<T> doPoll() = 0;
    void doStore(T const &data);

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


#include "sensors.txx"

#endif
