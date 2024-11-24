// #include "user/user.h"
// #include "kernel/stat.h"
// #include "kernel/types.h"

// int main(void) {
//     int pid = fork();  // Create a child process

//     if (pid == 0) {
//         // Child process
//         int ppid = getppid();  // Get the parent process ID
//         printf("Child process: My parent process ID is %d\n", ppid);
//     } else {
//         // Parent process
//         sleep(10);  // Sleep for a while to allow the child process to print
//         printf("Parent process: My child process ID is %d\n", pid);
//     }

//     exit(0);
// }

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main() {

    printf("In the initial process, Parent PID: %d\n", getppid());
    int pid = fork();  // Create a child process

    if (pid < 0) {
        // Error during fork
        printf("Fork failed!\n");
        exit(1);
    }

    if (pid == 0) {
        int child_pid = fork();
        if (child_pid < 0) {
            // Error during fork
            printf("Child fork failed!\n");
            exit(1);
        }

        if (child_pid == 0) {
            // In the grandchild process
            printf("In the grandchild process (PID: %d), Parent PID: %d\n", getpid(), getppid());
            exit(0);  // Grandchild exits
        }
        wait(0);
        printf("In the child process (PID: %d), Parent PID: %d\n", getpid(), getppid());
        exit(0);  // Child exits
    }

    // Parent process
    wait(0);  // Wait for child processes to exit

    printf("In the parent process (PID: %d), Parent PID: %d\n", getpid(), getppid());

    exit(0);  // Parent exits
}
