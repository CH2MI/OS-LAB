# 2024 OS-LAB Repositories

Lab1은 존재 하지 않습니다.

# Lab2
---

**내용 추가 예정**

# Lab3
---

**내용 추가 예정**

# Lab4
---

goals: (완료한 부분은 볼드체)
1. **Add a system call int printpt(int pid) that outputs the process’s page table**
   + Only prints the last level page table entries that are valid.
2. Rearrange stack
   + Allocate stack at the top address (below KERNBASE).
3. Demand paging for stack growth
4. Test with recurse.c
   + Should be able to run recurse 1040 without error.