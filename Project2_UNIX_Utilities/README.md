# **UNIX_Utilities**

This project replicates some of the most commonly used UNIX commands with simplified functionality. These utilities are intended to serve as educational examples of how UNIX command-line tools operate. The tools are designed to work in a Linux environment and provide fundamental operations like listing files, displaying file content, pattern searching, and basic file manipulation.

---

### **Overview**

This shell project implements several Unix-like commands (ls, cat, grep, wc, cp, mv, rm, and time) in the `./bin/` directory. The shell interacts with these commands by providing functionality similar to a lightweight terminal. Each command is implemented in C and supports common options or features associated with the original Unix commands.

---

### **Table of Contents:**
1. **Setup Instructions**
2. **Commands Overview**
   - listdir
   - fdisplay
   - searchtext
   - wordcount
   - copyfile
   - movefile
   - deletefile
   - runtime
3. **Shell**

---

### **1. Setup Instructions**

- **Clone or Copy Files**: Copy the provided code into a working directory.
- **Compile the Commands**: Use the provided `Makefile` to compile all the commands.

**Run:**
```bash
make all
```

This will generate executable files in the ./bin/ directory.

**Run the Shell:** Launch the shell using:
```bash
./bin/shell
```

### **Commands Overview**

**->listdir**

**Description:** Lists files and directories in the current or specified directory.

**Usage:**
```bash
listdir [OPTION] [DIRECTORY]
```

**Options:**
-a: Show all files (including hidden files).
-l: Display detailed information about files.
**Example:**
```bash
listdir -l
```

**->fdisplay**

**Description:** Displays the content of a file.

**Usage:**
```bash
fdisplay [FILE]
```
**Example:**
```bash
fdisplay file.txt
```

**->searchtext**

**Description:** Searches for a pattern in a file and prints matching lines.

**Usage:**
```bash
searchtext [PATTERN] [FILE]
```

**Example:**
```bash
searchtext "hello" file.txt
```

**->wordcount**

**Description:** Counts lines, words, and characters in a file. Displays histograms of word and character frequency.

**Usage:**
```bash
wordcount [FILE]
```

**Example:**
```bash
wordcount file.txt
```

**->copyfile**

**Description:** Copies a file with progress indication.

**Usage:**
```bash
copyfile [SOURCE_FILE] [DEST_FILE]
```

**Example:**
```bash
copyfile source.txt dest.txt
```

**->movefile**

**Description:** Moves or renames a file.

**Usage:**
```bash
movefile [SOURCE_FILE] [DEST_FILE]
```

**Example:**
```bash
movefile old_name.txt new_name.txt
```

**->deletefile**

**Description:** Removes files or directories (recursively if required).

**Usage:**
```bash
deletefile [-r] [FILE_OR_DIRECTORY]
```

**Options:**
-r: Recursively remove directories.

**Example:**
```bash
deletefile -r folder_name
```

**->runtime**

**Description:** Measures the time taken to execute another command.

**Usage:**
```bash
runtime [COMMAND] [ARGS...]
```

**Example:**
```bash
runtime listdir -l
```

**->Shell**

**Description:** A interactive shell (shell) to execute the above commands.

**How to Use:**

**Run the shell:**
```bash
./shell
```

**Type a command:**
```bash
What do you want? > listdir -l
```

**Exit the shell:**

```bash
What do you want? > exit
```

**Notes:**

1.All commands must be placed in the ./bin/ directory.

2.Ensure the executables have the correct permissions:


```bash
chmod +x ./bin/*
```

3.The runtime command can be used to measure the execution time of other commands.

Issues or Debugging

If a command does not execute:
- Verify it exists in the ./bin/ directory.
- Ensure it has execution permissions.
- Check if the path is correctly set in the shell.

This README provides an overview of how to use and run the Linux commands implemented in C.
