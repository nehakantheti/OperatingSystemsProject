#ifndef MOVEFILE_H
#define MOVEFILE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <errno.h>

// Function Prototypes

/**
 * @brief Print usage instructions for the custom_mv program.
 */
void print_usage();

/**
 * @brief Check if a given path is a directory.
 *
 * @param path The path to check.
 * @return 1 if the path is a directory, 0 otherwise, or -1 on error.
 */
int is_directory(const char *path);

/**
 * @brief Confirm whether to overwrite a file if it already exists.
 *
 * @param path The path of the existing file.
 * @return 1 to overwrite, 0 to skip.
 */
int confirm_overwrite(const char *path);

/**
 * @brief Copy a file from the source to the destination.
 *
 * @param source The source file path.
 * @param destination The destination file path.
 * @return 0 on success, -1 on failure.
 */
int copy_file(const char *source, const char *destination);

/**
 * @brief Move a file or directory from source to destination.
 *
 * @param source The source path.
 * @param destination The destination path.
 * @return 0 on success, -1 on failure.
 */
int move_file(const char *source, const char *destination);

#endif // MOVEFILE_H
