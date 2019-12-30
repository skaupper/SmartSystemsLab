#include <ifaddrs.h>
#include <netinet/in.h>
#include <arpa/inet.h>


#include <cstdio>
#include <cstdint>

#include <iostream>
#include <string>
#include <thread>
#include <chrono>

using namespace std::literals::chrono_literals;



struct IPv4Address {
    uint8_t segments[4];
};

int writeToCDev(char chars[], uint8_t brightness) {
    static const int SEGMENT_COUNT = 6;
//    static const std::string CHARACTER_DEVICE = "/dev/sevensegment";
    static const std::string CHARACTER_DEVICE = "/dev/xxxxx";

    std::cout << "here 11" << std::endl;

    // prepare input values
    uint8_t values[SEGMENT_COUNT];
    uint8_t combinedEnabled = 0;

    for (int i = 0; i < SEGMENT_COUNT; ++i) {
        bool isValidChar = (chars[i] >= '0' && chars[i] <= '9');
        combinedEnabled |= (((int) isValidChar) & 1) << (SEGMENT_COUNT - i - 1);

        if (isValidChar) {
            values[i] = chars[i];
        } else {
            values[i] = '0';
        }

        // Convert to binary for driver
        values[i] -= '0';
    }
    std::cout << "here 12" << CHARACTER_DEVICE << std::endl;

    // open character device
    auto fd = fopen(CHARACTER_DEVICE.c_str(), "wb");
    if (!fd) {
        std::cerr << "Failed to open character device '" << CHARACTER_DEVICE << "'" << std::endl;
        return -1;
    }
    std::cout << "here 13" << std::endl;

    // write display values
    for (int i = 0; i < SEGMENT_COUNT; ++i) {
        if (fputc(values[i] - '0', fd) == EOF) {
            std::cerr << "Failed to write character (index " << i << ")" << std::endl;
            return -1;
        }
    }
    std::cout << "here 14" << std::endl;

    // write brightness level
    if (fputc(brightness, fd) == EOF) {
        std::cerr << "Failed to write brightness level" << std::endl;
        return -1;
    }
    std::cout << "here 15" << std::endl;

    // write enable bits
    if (fputc(combinedEnabled, fd) == EOF) {
        std::cerr << "Failed to write enable bits" << std::endl;
        return -1;
    }

    std::cout << "here 16" << std::endl;

    auto ret = fclose(fd);
    if (ret != 0) {
        std::cerr << "error in fclose(fd): "<< ret << std::endl;
        return 0;
    }

    std::cout << "here 17" << std::endl;
    return 0;
}

IPv4Address getIP() {
    // drop 127.0.0.1
    static const uint32_t LOCAL_IP = 16777343;
    IPv4Address result;

    struct ifaddrs *ifAddrStruct = NULL;
    getifaddrs(&ifAddrStruct);


    for (auto ifa = ifAddrStruct; ifa != NULL; ifa = ifa->ifa_next) {
        if (!ifa->ifa_addr) {
            continue;
        }

        if (ifa->ifa_addr->sa_family == AF_INET) {
            auto ip = ((struct sockaddr_in *) ifa->ifa_addr)->sin_addr.s_addr;
            if (ip == LOCAL_IP) {
                continue;
            }

            // use the first non-local IP
            for (int i = 0; i < 4; ++i) {
                result.segments[i] = static_cast<uint8_t>((ip >> (i*8)) & 0xff);
            }
            break;
        }
    }

    if (ifAddrStruct) {
        freeifaddrs(ifAddrStruct);
    }

    return result;
}


int main() {
    static const uint8_t BRIGHTNESS = 0xff;

    auto ip = getIP();

    while(1) {
        for (int i = 0; i < 4; ++i) {
            char chars[7] = {0};
            auto s = ip.segments[i];

            snprintf(chars, 6, "%d", s);

            std::cout << "here 1" << std::endl;
            (void) writeToCDev(chars, BRIGHTNESS);

            std::cout << "here 100" << std::endl;

            std::this_thread::sleep_for(1000ms);
        }
    }

    return 0;
}
