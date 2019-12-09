template<class T>
std::vector<T> StreamingSensor<T>::getQueue() {
    std::lock_guard lck(queueMutex);
    auto result = std::move(*currentQueue);

    currentQueueIndex++;
    currentQueueIndex %= QUEUE_COUNT;
    currentQueue = &queues[currentQueueIndex];

    return result;
}

template<class T>
void StreamingSensor<T>::startPolling() {
    static const std::chrono::milliseconds delay {static_cast<int>(1000 / frequency)};
    running = true;

    while (running) {
        auto before = std::chrono::high_resolution_clock::now();

        auto result = doPoll();
        if (result.has_value()) {
            auto value = result.value();

            // doProcess may delay the execution
            std::thread([this, value]() { doProcess(value); }).detach();
            doStore(value);
        }


        // do not delay longer than needed
        auto after       = std::chrono::high_resolution_clock::now();
        auto actualDelay = delay;
        if (after > before) {
            actualDelay -= std::chrono::duration_cast<std::chrono::milliseconds>(after - before);
        } else {
            actualDelay = std::chrono::milliseconds {0};
        }
        std::this_thread::sleep_for(actualDelay);
    }
}

template<class T>
void StreamingSensor<T>::stop() {
    running = false;
}

template<class T>
void StreamingSensor<T>::doStore(T const &data) {
    std::lock_guard lck(queueMutex);
    currentQueue->push_back(data);
}
