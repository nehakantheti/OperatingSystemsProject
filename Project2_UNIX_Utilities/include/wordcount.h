// wordcount.h
#ifndef WORDCOUNT_H
#define WORDCOUNT_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

// Function declarations
void display_bargraph(const char *label, int value, const char *color);
const char* get_word_color(int count);
void display_histogram(int counts[], char *words[], int count);
void word_histogram(const char *filename);

#endif // WORDCOUNT_H

