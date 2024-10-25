#include <stdint.h>

#include "video.h"
// Enable NMI and sti
int kernel_main(){
    const char* humBird="Hummingbird OS";
    print(humBird);

    return 0;
}
