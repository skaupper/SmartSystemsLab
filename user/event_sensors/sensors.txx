template<class T>
std::vector<T> StreamingSensor<T>::getQueue() {
    std::lock_guard lck(queueMutex);

    auto result = std::move(queue);
    queue.clear();
    return result;
}

template<class T>
std::vector<T> StreamingSensor<T>::getEventQueue() {
    std::lock_guard lck(eventMutex);

    auto result = std::move(eventQueue);
    eventQueue.clear();
    eventHappened = false;
    return result;
}

template<class T>
void StreamingSensor<T>::setEventQueue(std::vector<T> &&newEventQueue) {
    std::lock_guard lck(eventMutex);

    if (eventHappened) {
        std::cerr << "An event has not been published yet and gets dropped" << std::endl;
    }
    eventHappened = true;
    eventQueue    = std::move(newEventQueue);
}

template<class T>
void StreamingSensor<T>::startPolling() {
    static const std::chrono::microseconds delay {static_cast<int>(1000 * 1000 / frequency)};
    running = true;

    auto before           = std::chrono::high_resolution_clock::now();
    auto iterationEndTime = before;

    while (running) {
        iterationEndTime += delay;

        auto result = doPoll();
        if (result.has_value()) {
            auto value = result.value();

            doProcess(value);
            doStore(value);
        }

        std::this_thread::sleep_until(iterationEndTime);
    }
}

template<class T>
void StreamingSensor<T>::stop() {
    running = false;
}

template<class T>
void StreamingSensor<T>::doStore(T const &data) {
    std::lock_guard lck(queueMutex);
    queue.push_back(data);
}
