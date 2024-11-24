#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>

#define MAX_COMMAND_LEN 256

void run_command(char *command)
{
    if (command == NULL)
        return;
    char *args[10];
    char *token = strtok(command, " \n");
    int i = 0;

    // Tokenize the input command
    while (token)
    {
        args[i++] = token;
        token = strtok(NULL, " \n");
    }
    args[i] = NULL;

    // Construct the full path for custom commands
    char path[100] = "./bin/";
    if (strcmp(args[0], "listdir") == 0 || strcmp(args[0], "fdisplay") == 0 ||
        strcmp(args[0], "searchtext") == 0 || strcmp(args[0], "wordcount") == 0 ||
        strcmp(args[0], "copyfile") == 0 || strcmp(args[0], "movefile") == 0 ||
        strcmp(args[0], "deletefile") == 0 || strcmp(args[0], "runtime" ) == 0)
    {

        strcat(path, args[0]);
        args[0] = path; // Update the command to use the full path
    }

    else
    {
        printf("Command not found\n");
        exit(1);
    }

    // Fork and execute the command
    if (fork() == 0)
    { // Child process
        execvp(args[0], args);
        perror("shell");
        exit(1);
    }
    else
    { // Parent process
        wait(NULL);
    }
}

int main()
{
    char command[MAX_COMMAND_LEN];

    printf("Welcome to our shell! Type 'exit' to quit.\n");

    while (1)
    {
        printf("What do you want? > ");
        fgets(command, MAX_COMMAND_LEN, stdin);

        if (strcmp(command, "\n") == 0)
        {
            continue;
        }
        // Exit condition
        if (strcmp(command, "exit\n") == 0)
        {
            break;
        }

        // Execute the command
        run_command(command);
    }

    printf("Exiting shell. Goodbye!\n");
    return 0;
}
