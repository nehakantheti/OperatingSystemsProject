#include "runtime.h"


void execute_and_time(char *command[], int arg_count) {
    struct timespec start, end;
    clock_gettime(CLOCK_REALTIME, &start);

    pid_t pid = fork();

    if (pid == 0) {
        // Child process: Execute the command
        execvp(command[0], command);
        // If execvp fails, print the error and exit
        perror("runtime");
        exit(1);
    } else if (pid > 0) {
        // Parent process: Wait for child to complete
        int status;
        waitpid(pid, &status, 0);

        clock_gettime(CLOCK_REALTIME, &end);
        double elapsed_time = (end.tv_sec - start.tv_sec) +
                              (end.tv_nsec - start.tv_nsec) / 1e9;

        if (WIFEXITED(status)) {
            printf("Command executed successfully.\n");
            printf("Elapsed time: %.3f seconds\n", elapsed_time);
        } else {
            printf("Command terminated with an error.\n");
        }
    } else {
        // Fork failed
        perror("runtime");
        exit(1);
    }
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: runtime <command> [args...]\n");
        return 1;
    }

    char *command[argc];
    for (int i = 1; i < argc; i++) {
        command[i - 1] = argv[i];
    }
    command[argc - 1] = NULL;

    execute_and_time(command, argc - 1);
    return 0;
}
