#include "fpga.h"

#include <libfpgaregion.h>

#include <cassert>
#include <iostream>
#include <memory>


static std::mutex fpgaMutex;
static std::unique_ptr<FpgaRegion> fpga;


static void ReconfigRequested() {
    std::cout << "Reconfiguration in progres" << std::endl;
    fpgaMutex.lock();
    fpga->Release();
    std::cout << "Reconfiguration requested" << std::endl;
}

static void ReconfigDone() {
    std::cout << "Reconfiguration done" << std::endl;
    fpga->Acquire();
    fpgaMutex.unlock();
}




void initFPGA(std::string name) {
    fpga = std::make_unique<FpgaRegion>(name, ReconfigRequested, ReconfigDone);
    fpga->Acquire();
}


std::lock_guard<std::mutex> lockFPGA() {
    assert(fpga);
    return std::lock_guard(fpgaMutex);
}
