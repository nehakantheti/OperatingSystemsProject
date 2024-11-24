#include "listdir.h"

// Function to determine the icon based on file type
const char *get_file_icon(const char *path) {
    struct stat file_stat;
    if (stat(path, &file_stat) == -1) {
        return "❓"; // Unknown
    }
    if (S_ISDIR(file_stat.st_mode)) return "📂"; // Directory
    if (S_ISREG(file_stat.st_mode)) {
        if (file_stat.st_mode & S_IXUSR) return "🛠️"; // Executable
        return "📄"; // Regular file
    }
    return "❓"; // Default
}

// Recursive function to list directories in tree format
void list_tree(const char *path, int level) {
    DIR *dir = opendir(path);
    if (!dir) {
        perror("listdir");
        return;
    }

    struct dirent *entry;
    while ((entry = readdir(dir)) != NULL) {
        if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0) continue; // Skip . and ..

        for (int i = 0; i < level; i++) printf("│   "); // Indent for tree view

        // Construct the full path
        char full_path[1024];
        snprintf(full_path, sizeof(full_path), "%s/%s", path, entry->d_name);

        // Print with icon
        printf("├── %s %s\n", get_file_icon(full_path), entry->d_name);

        // Use stat to check if the entry is a directory
        struct stat entry_stat;
        if (stat(full_path, &entry_stat) == 0 && S_ISDIR(entry_stat.st_mode)) {
            list_tree(full_path, level + 1); // Recursively list subdirectories
        }
    }
    closedir(dir);
}

int main(int argc, char *argv[]) {
    const char *path = ".";
    int tree_view = 0;

    // Parse command-line arguments
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-t") == 0) {
            tree_view = 1;
        } else {
            path = argv[i];
        }
    }

    if (tree_view) {
        list_tree(path, 0);
    } else {
        // Regular listing logic (basic version)
        DIR *dir = opendir(path);
        if (!dir) {
            perror("listdir");
            return 1;
        }

        struct dirent *entry;
        while ((entry = readdir(dir)) != NULL) {
            if (strcmp(entry->d_name, ".") != 0 && strcmp(entry->d_name, "..") != 0) {
                printf("%s\n", entry->d_name);
            }
        }
        closedir(dir);
    }

    return 0;
}
