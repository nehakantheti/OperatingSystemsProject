#include<searchtext.h>

void print_usage() {
    printf("Usage: searchtext [OPTIONS] <pattern> <file>\n");
    printf("Options:\n");
    printf("  -i          Perform case-insensitive matching\n");
    printf("  -n          Print line numbers with matched lines\n");
    printf("  -w          Match whole words only\n");
    printf("  -h          Display this help message\n");
}

// Case-insensitive string matching
int strcasestr_custom(const char *haystack, const char *needle) {
    char *h = strdup(haystack);
    char *n = strdup(needle);
    for (char *p = h; *p; p++) *p = tolower(*p);
    for (char *p = n; *p; p++) *p = tolower(*p);
    int found = strstr(h, n) != NULL;
    free(h);
    free(n);
    return found;
}

// Word-only matching
int is_whole_word(const char *line, const char *word) {
    const char *p = line;
    while ((p = strstr(p, word)) != NULL) {
        if ((p == line || isspace(*(p - 1))) && (isspace(*(p + strlen(word))) || *(p + strlen(word)) == '\0')) {
            return 1;
        }
        p++;
    }
    return 0;
}

void search_pattern_in_file(const char *pattern, const char *filename, int case_insensitive, int line_numbers, int word_only) {
    FILE *file = fopen(filename, "r");
    if (file == NULL) {
        perror("searchtext");
        return;
    }

    char line[1024];
    int line_number = 0;

    while (fgets(line, sizeof(line), file) != NULL) {
        line_number++;
        int match = 0;

        if (case_insensitive) {
            match = strcasestr_custom(line, pattern);
        } else {
            match = (strstr(line, pattern) != NULL);
        }

        if (word_only) {
            match = is_whole_word(line, pattern);
        }

        if (match) {
            if (line_numbers) {
                printf("%d: ", line_number);
            }
            printf("%s", line);
        }
    }

    fclose(file);
}

int main(int argc, char *argv[]) {
    if (argc < 3) {
        print_usage();
        return 1;
    }

    int case_insensitive = 0;
    int line_numbers = 0;
    int word_only = 0;

    // Parse options
    int opt_index = 1;
    while (opt_index < argc && argv[opt_index][0] == '-') {
        if (strcmp(argv[opt_index], "-i") == 0) {
            case_insensitive = 1;
        } else if (strcmp(argv[opt_index], "-n") == 0) {
            line_numbers = 1;
        } else if (strcmp(argv[opt_index], "-w") == 0) {
            word_only = 1;
        } else if (strcmp(argv[opt_index], "-h") == 0) {
            print_usage();
            return 0;
        } else {
            fprintf(stderr, "Unknown option: %s\n", argv[opt_index]);
            print_usage();
            return 1;
        }
        opt_index++;
    }

    if (argc - opt_index < 2) {
        print_usage();
        return 1;
    }

    const char *pattern = argv[opt_index];
    const char *filename = argv[opt_index + 1];

    search_pattern_in_file(pattern, filename, case_insensitive, line_numbers, word_only);
    return 0;
}
