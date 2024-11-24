// listdir.h

#ifndef LISTDIR_H
#define LISTDIR_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <sys/stat.h>
#include <unistd.h>
#include <sys/types.h>

const char *get_file_icon(const char *path);
void list_tree(const char *path, int level);

#endif // LISTDIR_H
