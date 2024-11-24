// runtime.h
#ifndef RUNTIME_H
#define RUNTIME_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>
#include <time.h>

// Function to execute a command and measure its execution time
void execute_and_time(char *command[], int arg_count);

#endif // RUNTIME_H
