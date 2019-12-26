template<class T>
std::vector<T> StreamingSensor<T>::getQueue() {
    std::lock_guard lck(queueMutex);

    auto result = std::move(queue);
    queue.clear();
    return result;
}

template<class T>
bool StreamingSensor<T>::hasEventHappened() {
    std::lock_guard lck(eventMutex);

    auto result   = eventHappened;
    eventHappened = false;
    return result;
}

template<class T>
std::vector<T> StreamingSensor<T>::getEventQueue() {
    std::lock_guard lck(eventMutex);

    auto result = std::move(eventQueue);
    eventQueue.clear();
    return result;
}

template<class T>
void StreamingSensor<T>::setEventQueue(std::vector<T> &&newEventQueue) {
    std::lock_guard lck(eventMutex);

    if (eventHappened) {
        std::cerr << "An event has not been published yet and gets dropped" << std::endl;
    }
    eventHappened = true;
    eventQueue = std::move(newEventQueue);
}

template<class T>
void StreamingSensor<T>::startPolling() {
    static const std::chrono::microseconds delay {static_cast<int>(1000 * 1000 / frequency)};
    running = true;

    while (running) {
        auto before           = std::chrono::high_resolution_clock::now();
        auto iterationEndTime = before + delay;

        auto result = doPoll();
        if (result.has_value()) {
            auto value = result.value();

            // doProcess may delay the execution
            doProcess(value);
            doStore(value);
        }

        // do not delay longer than needed
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
