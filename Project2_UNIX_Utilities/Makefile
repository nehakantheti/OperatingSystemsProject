# Variables
CC = gcc
CFLAGS = -Iinclude
BIN_DIR = bin
SRC_DIR = src

# Targets
all: listdir fdisplay searchtext wordcount copyfile movefile deletefile runtime shell

listdir: $(SRC_DIR)/listdir.c include/listdir.h
	@$(CC) $(CFLAGS) -o $(BIN_DIR)/listdir $(SRC_DIR)/listdir.c

fdisplay: $(SRC_DIR)/fdisplay.c include/fdisplay.h
	@$(CC) $(CFLAGS) -o $(BIN_DIR)/fdisplay $(SRC_DIR)/fdisplay.c

searchtext: $(SRC_DIR)/searchtext.c include/searchtext.h
	@$(CC) $(CFLAGS) -o $(BIN_DIR)/searchtext $(SRC_DIR)/searchtext.c

wordcount: $(SRC_DIR)/wordcount.c include/wordcount.h
	@$(CC) $(CFLAGS) -o $(BIN_DIR)/wordcount $(SRC_DIR)/wordcount.c

copyfile: $(SRC_DIR)/copyfile.c include/copyfile.h
	@$(CC) $(CFLAGS) -o $(BIN_DIR)/copyfile $(SRC_DIR)/copyfile.c

movefile: $(SRC_DIR)/movefile.c include/movefile.h
	@$(CC) $(CFLAGS) -o $(BIN_DIR)/movefile $(SRC_DIR)/movefile.c

deletefile: $(SRC_DIR)/deletefile.c include/deletefile.h
	@$(CC) $(CFLAGS) -o $(BIN_DIR)/deletefile $(SRC_DIR)/deletefile.c

runtime: $(SRC_DIR)/runtime.c include/runtime.h
	@$(CC) $(CFLAGS) -o $(BIN_DIR)/runtime $(SRC_DIR)/runtime.c -lrt -D_GNU_SOURCE

shell: $(SRC_DIR)/shell.c
	@$(CC) $(CFLAGS) -o bin/shell src/shell.c


clean:
	rm -f $(BIN_DIR)/*
