#include "kernel/types.h"
#include "user/user.h"
#include "kernel/syscall.h"

int main() {
    int pid = fork();

    if (pid == 0) {
        // Child process
        for (int i = 1; i <= 5; i++) {
            printf("Child running iteration %d...\n", i);
            sleep(3);  // Simulate some work
        }
        printf("Child completed its task\n");
        exit(0);  // Exit gracefully
    } else if (pid > 0) {
        // Parent process
        sleep(8);  // Let the child run for a while
        printf("Parent sending SIGSTOP to child %d\n", pid);
        sigstop(pid);  // Stop the child process

        sleep(5);  // Wait for a while before continuing the child
        printf("Parent sending SIGCONT to child %d\n", pid);
        sigcont(pid);  // Continue the child process

        wait(0);  // Wait for child process to exit
        printf("Parent: Child process %d finished\n", pid);
    } else {
        // Error in fork
        printf("Fork failed\n");
    }

    exit(0);
}
