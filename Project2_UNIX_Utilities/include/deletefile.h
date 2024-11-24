// deletefile.h

#ifndef DELETEFILE_H
#define DELETEFILE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <sys/stat.h>
#include <unistd.h>

int remove_directory(const char *path);

#endif // DELETEFILE_H
