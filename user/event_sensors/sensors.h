#ifndef SENSORS_H
#define SENSORS_H

#include <iostream>
#include <mutex>
#include <optional>
#include <string>
#include <thread>
#include <vector>


template<class T>
class StreamingSensor {
public:
    StreamingSensor(double frequency) : frequency(frequency) {}
    virtual ~StreamingSensor() {}

    virtual std::string getTopic() const = 0;
    std::vector<T> getQueue();

    bool hasEventHappened();
    std::vector<T> getEventQueue();
    void setEventQueue(std::vector<T> &&newEventQueue);

    void startPolling();
    void stop();

protected:
    virtual std::optional<T> doPoll() = 0;
    void doStore(T const &data);
    virtual void doProcess(T const &data) {}

private:
    const double frequency;

    bool running = false;
    bool eventHappened = false;

    std::mutex queueMutex;
    std::mutex eventMutex;

    std::vector<T> queue;
    std::vector<T> eventQueue;
};


class Serializable {
public:
    virtual std::string toJsonString() const = 0;
};


#include "sensors.txx"

#endif
