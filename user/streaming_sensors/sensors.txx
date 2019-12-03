template<class T>
std::vector<T> StreamingSensor<T>::getQueue() {
    std::lock_guard lck(queueMutex);
    auto result = std::move(*currentQueue);

    // calculate next queue
    currentQueueIndex++;
    currentQueueIndex %= QUEUE_COUNT;
    currentQueue = &queues[currentQueueIndex];

    return result;
}

template<class T>
void StreamingSensor<T>::startPolling() {
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

template<class T>
void StreamingSensor<T>::stop() {
    running = false;
}

template<class T>
void StreamingSensor<T>::doStore(T const &data) {
    std::lock_guard lck(queueMutex);
    currentQueue->push_back(data);
}
