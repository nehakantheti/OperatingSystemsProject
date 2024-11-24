#include "../kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
    int pid;

    // Test forex() without arguments (normal fork behavior)
    //printf("Testing forex() without arguments:\n");

    //pid = forex(0);  // Passing 0 as the argument to signify no file
    //if (pid < 0) {
    //    printf("forex failed\n");
    //    exit(1);
    //}

    //if (pid == 0) {  // Child process
    //    printf("Child process created (PID: %d)\n", getpid());
    //    exit(0);
    //} else {
    //   wait(0);  // Parent process waits for the child
    //    printf("Parent process waited for child (PID: %d)\n", pid);
    //}

    // Test forex() with arguments (direct exec behavior)
    printf("Testing forex() with arguments:\n");

    pid = forex("check");
    if (pid < 0) {
        printf("forex failed with exec argument\n");
        exit(1);
    }

    if (pid == 0) {  // Child process
        printf("This line will not execute if exec succeeds.\n");
        //exit(0);
    } else {
        wait(0);  // Parent process waits for the child
        printf("Parent process waited for exec child (PID: %d)\n", pid);
    }

    exit(0);
}


