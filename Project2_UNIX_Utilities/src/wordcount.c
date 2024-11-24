#include "wordcount.h"
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

// ANSI color codes for colored output
#define RESET "\033[0m"
#define RED "\033[31m"
#define GREEN "\033[32m"
#define YELLOW "\033[33m"
#define BLUE "\033[34m"
#define MAGENTA "\033[35m"
#define CYAN "\033[36m"
#define WHITE "\033[37m"

// Function to display a bar graph with colored blocks
void display_bargraph(const char *label, int value, const char *color) {
    printf("%-15s: ", label);
    printf("%s", color); // Apply color
    for (int i = 0; i < value; i++) {
        printf("█"); // Colored block
    }
    printf("%s %d\n", RESET, value); // Reset color and display value
}

// Function to decide color based on word frequency
const char* get_word_color(int count) {
    if (count %6 == 0) {
        return RED; 
    } 
    else if (count %6 == 1) {
        return YELLOW; 
    } 
    else if (count %6 == 2) {
        return GREEN; 
    }
    else if (count %6 == 3) {
        return MAGENTA; 
    } 
    else if (count %6 == 4) {
        return CYAN; 
    }
    return BLUE; 
}

// Function to display the word histogram with colors
void display_histogram(int counts[], char *words[], int count) {
    printf("\nWord Frequency Histogram:\n");
    for (int i = 0; i < count; i++) {
        // Assign color based on word count (frequency)
        const char *color = get_word_color(counts[i]);
        display_bargraph(words[i], counts[i], color);
    }
}

// Function to calculate counts and generate a histogram
void word_histogram(const char *filename) {
    FILE *file = fopen(filename, "r");
    if (!file) {
        perror("wordcount");
        return;
    }

    char word[50];
    char *words[1000];
    int counts[1000] = {0};
    int word_count = 0;
    int total_words = 0;
    int total_lines = 0;
    int total_chars = 0;

    int char_counts[128] = {0}; // ASCII character counts

    int ch;
    int in_word = 0;

    // Read file and count characters, words, and lines
    while ((ch = fgetc(file)) != EOF) {
        total_chars++;

        if (ch >= 0 && ch < 128) { // Count only valid ASCII characters
            char_counts[ch]++;
        }

        if (ch == '\n') total_lines++;

        if (isspace(ch)) {
            if (in_word) {
                in_word = 0;
                total_words++;
            }
        } else {
            in_word = 1;
        }
    }

    // Reset file pointer for histogram calculation
    rewind(file);

    // Calculate word histogram
    while (fscanf(file, "%49s", word) != EOF) {
        for (int i = 0; word[i]; i++) word[i] = tolower(word[i]); // Normalize to lowercase

        int found = 0;
        for (int i = 0; i < word_count; i++) {
            if (strcmp(words[i], word) == 0) {
                counts[i]++;
                found = 1;
                break;
            }
        }
        if (!found) {
            words[word_count] = strdup(word);
            counts[word_count++] = 1;
        }
    }

    fclose(file);

    // Display results
    printf("Total Lines: %d\n", total_lines);
    printf("Total Words: %d\n", total_words);
    printf("Total Characters: %d\n", total_chars);

    printf("\nCharacter Count Bar Graph (ASCII characters):\n");
    for (int i = 0; i < 128; i++) {
        if (char_counts[i] > 0) {
            char label[10];
            if (isprint(i)) { // Printable characters
                snprintf(label, sizeof(label), "'%c'", i);
            } else { // Non-printable characters
                snprintf(label, sizeof(label), "0x%02X", i);
            }

            // Alternate colors based on character type
            const char *color = (i >= 'a' && i <= 'z') ? GREEN :
                                (i >= 'A' && i <= 'Z') ? BLUE :
                                (i >= '0' && i <= '9') ? YELLOW : MAGENTA;

            display_bargraph(label, char_counts[i], color);
        }
    }

    display_histogram(counts, words, word_count);

    // Free dynamically allocated memory
    for (int i = 0; i < word_count; i++) {
        free(words[i]);
    }
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: wordcount <filename>\n");
        return 1;
    }

    const char *filename = argv[1];
    word_histogram(filename);
    return 0;
}
