# 2024 OS-LAB Repositories

Lab1은 존재 하지 않습니다.


# Lab2

goals:
1. **Adding new system calls**
   + void exit2(int status), int wait2(int *status)
   + To provide UNIX-style ending of child processes.


# Lab3

goals:
1. **Complete uthread_switch.S**
2. **Enable time sharing among user-level threads**


# Lab4

goals:
1. **Add a system call int printpt(int pid) that outputs the process’s page table**
   + Only prints the last level page table entries that are valid.
2. Rearrange stack
   + Allocate stack at the top address (below KERNBASE).
3. Demand paging for stack growth
4. Test with recurse.c
   + Should be able to run recurse 1040 without error.
