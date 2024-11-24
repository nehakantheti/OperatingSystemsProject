#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <errno.h>

void print_usage() {
    printf("Usage: movefile <source> <destination>\n");
}

int is_directory(const char *path) {
    struct stat path_stat;
    if (stat(path, &path_stat) != 0) {
        perror("movefile");
        return -1;
    }
    return S_ISDIR(path_stat.st_mode);
}

int confirm_overwrite(const char *path) {
    char response;
    printf("movefile: '%s' already exists. Overwrite? (y/n): ", path);
    while (1) {
        response = getchar();
        if (response == 'y' || response == 'Y') return 1;
        if (response == 'n' || response == 'N') return 0;
        printf("Please enter 'y' (yes) or 'n' (no): ");
    }
}

int copy_file(const char *source, const char *destination) {
    FILE *src = fopen(source, "rb");
    if (!src) {
        perror("movefile");
        return -1;
    }

    FILE *dest = fopen(destination, "wb");
    if (!dest) {
        perror("movefile");
        fclose(src);
        return -1;
    }

    char buffer[4096];
    size_t bytes;
    while ((bytes = fread(buffer, 1, sizeof(buffer), src)) > 0) {
        if (fwrite(buffer, 1, bytes, dest) != bytes) {
            perror("movefile");
            fclose(src);
            fclose(dest);
            return -1;
        }
    }

    fclose(src);
    fclose(dest);
    return 0;
}

int move_file(const char *source, const char *destination) {
    // Check if destination exists
    if (access(destination, F_OK) == 0) {
        if (!confirm_overwrite(destination)) {
            printf("movefile: Move cancelled.\n");
            return -1;
        }
    }

    // Attempt to rename the file
    if (rename(source, destination) == 0) {
        return 0;
    }

    // Handle cross-device moves by manually copying and deleting
    if (errno == EXDEV) {
        printf("movefile: Cross-device move detected. Performing manual copy.\n");
        if (copy_file(source, destination) == 0) {
            if (remove(source) != 0) {
                perror("movefile");
                return -1;
            }
            return 0;
        }
        return -1;
    }

    perror("movefile");
    return -1;
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        print_usage();
        return 1;
    }

    const char *source = argv[1];
    const char *destination = argv[2];

    // Check if source exists
    if (access(source, F_OK) != 0) {
        perror("movefile");
        return 1;
    }

    // Prevent moving a directory into itself
    if (is_directory(source) == 1 && is_directory(destination) == 1) {
        if (strncmp(source, destination, strlen(source)) == 0) {
            fprintf(stderr, "movefile: Cannot move directory '%s' into itself.\n", source);
            return 1;
        }
    }

    // Perform the move
    if (move_file(source, destination) == 0) {
        printf("movefile: Moved '%s' to '%s'\n", source, destination);
        return 0;
    }

    return 1;
}
