#include "deletefile.h"

// Function to remove a directory recursively
int remove_directory(const char *path) {
    DIR *dir = opendir(path);
    if (!dir) {
        perror("deletefile");
        return -1;
    }

    struct dirent *entry;
    char filepath[1024];
    struct stat path_stat;

    while ((entry = readdir(dir)) != NULL) {
        // Skip "." and ".."
        if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0) {
            continue;
        }

        snprintf(filepath, sizeof(filepath), "%s/%s", path, entry->d_name);
        if (stat(filepath, &path_stat) == -1) {
            perror("deletefile");
            closedir(dir);
            return -1;
        }

        if (S_ISDIR(path_stat.st_mode)) {
            // Recursively remove subdirectory
            if (remove_directory(filepath) == -1) {
                closedir(dir);
                return -1;
            }
        } else {
            // Remove file
            if (remove(filepath) == -1) {
                perror("deletefile");
                closedir(dir);
                return -1;
            }
        }
    }

    closedir(dir);

    // Remove the directory itself
    if (rmdir(path) == -1) {
        perror("deletefile");
        return -1;
    }

    return 0;
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: ./bin/deletefile [-r] <file_or_directory>\n");
        return 1;
    }

    int recursive = 0;
    const char *target;

    if (argc == 3 && strcmp(argv[1], "-r") == 0) {
        recursive = 1;
        target = argv[2];
    } else if (argc == 2) {
        target = argv[1];
    } else {
        fprintf(stderr, "Usage: ./bin/deletefile [-r] <file_or_directory>\n");
        return 1;
    }

    struct stat path_stat;
    if (stat(target, &path_stat) == -1) {
        perror("deletefile");
        return 1;
    }

    if (S_ISDIR(path_stat.st_mode)) {
        if (!recursive) {
            fprintf(stderr, "deletefile: Cannot remove '%s': Is a directory\n", target);
            return 1;
        }

        // Remove directory recursively
        if (remove_directory(target) == -1) {
            return 1;
        }
    } else {
        // Remove file
        if (remove(target) == -1) {
            perror("deletefile");
            return 1;
        }
    }

    printf("Removed '%s'\n", target);
    return 0;
}
