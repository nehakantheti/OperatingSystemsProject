#include "kernel/types.h"
#include "user/user.h"

// Wrapper for sigstop system call
int sigstop(int pid) {
    return syscall(SYS_SIGSTOP, pid);
}

// Wrapper for sigcont system call
int sigcont(int pid) {
    return syscall(SYS_SIGCONT, pid);
}
