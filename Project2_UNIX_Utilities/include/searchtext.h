#ifndef SEARCHTEXT_H
#define SEARCHTEXT_H

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

// Function Prototypes

/**
 * @brief Display usage instructions for custom_grep.
 */
void print_usage();

/**
 * @brief Perform case-insensitive substring search.
 * 
 * @param haystack The string to search in.
 * @param needle The string to search for.
 * @return 1 if the substring is found, 0 otherwise.
 */
int strcasestr_custom(const char *haystack, const char *needle);

/**
 * @brief Check if the pattern matches whole words only.
 * 
 * @param line The line to search in.
 * @param word The word to search for.
 * @return 1 if a whole word match is found, 0 otherwise.
 */
int is_whole_word(const char *line, const char *word);

/**
 * @brief Search for a pattern in a file and print matching lines.
 * 
 * @param pattern The pattern to search for.
 * @param filename The name of the file to search in.
 * @param case_insensitive 1 to perform case-insensitive matching, 0 otherwise.
 * @param line_numbers 1 to print line numbers, 0 otherwise.
 * @param word_only 1 to match whole words only, 0 otherwise.
 */
void search_pattern_in_file(const char *pattern, const char *filename, int case_insensitive, int line_numbers, int word_only);

#endif // SEARCHTEXT_H
