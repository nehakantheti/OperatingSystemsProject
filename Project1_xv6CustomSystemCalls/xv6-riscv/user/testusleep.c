#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main() {
    printf("Testing usleep...\n");

    for (int i = 0; i < 5; i++) {
        printf("Sleeping for 500 microseconds (%d)\n", i + 1);
        usleep(500); // Sleep for 500 microseconds
    }

    printf("Testing completed!\n");
    exit(0);
}