#include "fdisplay.h"

// Function to apply syntax highlighting to C files
void highlight_line(const char *line) {
    const char *keywords[] = {"int", "return", "if", "else", "for", "while", "#include", "void"};
    int keyword_count = sizeof(keywords) / sizeof(keywords[0]);
    char temp[1024];
    strcpy(temp, line);

    char *token = strtok(temp, " \t\n");
    while (token) {
        int is_keyword = 0;
        for (int i = 0; i < keyword_count; i++) {
            if (strcmp(token, keywords[i]) == 0) {
                printf("\033[1;32m%s\033[0m ", token); // Green for keywords
                is_keyword = 1;
                break;
            }
        }
        if (!is_keyword) {
            printf("%s ", token);
        }
        token = strtok(NULL, " \t\n");
    }
    printf("\n");
}

void display_file_with_highlighting(const char *filename) {
    FILE *file = fopen(filename, "r");
    if (!file) {
        perror("fdisplay");
        return;
    }

    char line[1024];
    while (fgets(line, sizeof(line), file)) {
        highlight_line(line);
    }

    fclose(file);
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: fdisplay <filename>\n");
        return 1;
    }

    const char *filename = argv[1];
    display_file_with_highlighting(filename);
    return 0;
}
