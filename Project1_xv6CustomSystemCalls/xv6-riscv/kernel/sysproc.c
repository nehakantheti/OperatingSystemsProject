#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  exit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return fork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return wait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int n;

  argint(0, &n);
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  if(n < 0)
    n = 0;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

uint64
sys_forex(void)
{
    char filename[128]; // Buffer for the filename
    int pid;

    // Fetch the filename argument from user space
    if (argstr(0, filename, sizeof(filename)) < 0) {
        filename[0] = '\0'; // Set to an empty string if no argument is provided
    }
    char full_path[100];
    int i = 0;

    // Add the '/' to the path
    full_path[i++] = '/';

    // Copy the filename to the full_path starting after the '/'
    for (int j = 0; filename[j] != '\0'; j++, i++) {
        full_path[i] = filename[j];
    }

    // Null-terminate the string
    full_path[i] = '\0';
    pid = fork();
    if (pid < 0) 
    {
      return -1; // Fork failed
    }
    if (pid == 0) 
    {
      // In child process
      if (filename[0] != '\0') 
      {
        // Execute the specified program
        if(exec(full_path, 0)<0)
        {
        	printf("File not opening!\n");
        }
        exit(0); // Exit if exec fails
      }
      // If no filename is provided, continue as a normal forked process
    }
    // In parent process, return the PID of the child
    return pid;
}

uint64 
sys_getppid(void) {
    struct proc *p = myproc();  // Get the current process
    return p->parent ? p->parent->pid : 0;  // Return the parent's PID, or 0 if no parent
}

int 
sys_usleep(void) {
    int microseconds;
    argint(0, &microseconds);
    if (microseconds < 0) {
        return -1;
    }

    // For very small delays, use microdelay
    if (microseconds < 1000) {
        microdelay(microseconds);
        return 0;
    }

    // For larger delays, use the sleep mechanism
    uint ticks = microseconds / 1000; // Convert to milliseconds
    uint start_ticks = ticks;
    acquire(&tickslock);
    while (ticks > 0 && ticks - start_ticks < microseconds / 1000) {
        sleep(&ticks, &tickslock);
    }
    release(&tickslock);

    return 0;
}

uint64
sys_waitpid(void)
{
    int pid;
    uint64 status;

    // Get arguments from user space
    argint(0, &pid);
    argaddr(1, &status);

    return waitpid(pid, status);
}


uint64 sys_sigstop(void) {
    int pid;
    //int ret;
    // Capture the return value of argint
    argint(0, &pid);
    if (pid == 0)  
        return -1; // If argint fails, return -1
    return sigstop(pid);
    // struct proc *p;

    // for(p = proc; p < &proc[NPROC]; p++){
    //     acquire(&p->lock);
    //     if(p->pid == pid){
    //         // Set process state to STOPPED or SLEEPING (suspend execution).
    //         p->state = SLEEPING;  // or STOPPED if you have a STOPPED state.
    //         release(&p->lock);
    //         return 0;
    //     }
    //     release(&p->lock);
    // }
    // return -1;
}

uint64 sys_sigcont(void) {
    int pid;
    //int ret;
    // Capture the return value of argint
    argint(0, &pid);
    if (pid== 0)  
        return -1; // If argint fails, return -1
    return sigcont(pid);
}
