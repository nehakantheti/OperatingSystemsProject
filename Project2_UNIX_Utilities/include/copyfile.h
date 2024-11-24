// copyfile.h

#ifndef COPYFILE_H
#define COPYFILE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

void show_progress(size_t copied, size_t total);
void copy_with_progress(const char *src, const char *dest);

#endif // COPYFILE_H
