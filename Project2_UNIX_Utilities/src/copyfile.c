#include "copyfile.h"

void show_progress(size_t copied, size_t total) {
    int percent = (copied * 100) / total;
    printf("\rCopying: [%-50s] %d%%", 
           (percent > 0 ? "##################################################" + 50 - (percent / 2) : ""),
           percent);
    fflush(stdout);
}

void copy_with_progress(const char *src, const char *dest) {
    FILE *src_file = fopen(src, "rb");
    FILE *dest_file = fopen(dest, "wb");
    if (!src_file || !dest_file) {
        perror("copyfile");
        return;
    }

    fseek(src_file, 0L, SEEK_END);
    size_t total_size = ftell(src_file);
    fseek(src_file, 0L, SEEK_SET);

    char buffer[4096];
    size_t bytes_read, bytes_written, total_copied = 0;

    while ((bytes_read = fread(buffer, 1, sizeof(buffer), src_file)) > 0) {
        bytes_written = fwrite(buffer, 1, bytes_read, dest_file);
        if (bytes_written != bytes_read) {
            perror("copyfile");
            break;
        }
        total_copied += bytes_written;
        show_progress(total_copied, total_size);
    }

    printf("\nCopy complete.\n");
    fclose(src_file);
    fclose(dest_file);
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: copyfile <source> <destination>\n");
        return 1;
    }

    copy_with_progress(argv[1], argv[2]);
    return 0;
}
