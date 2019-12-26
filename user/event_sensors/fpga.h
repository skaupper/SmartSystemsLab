#ifndef FPGA_H
#define FPGA_H

#include <mutex>
#include <string>


void initFPGA(std::string name);
std::lock_guard<std::mutex> lockFPGA();

#endif
