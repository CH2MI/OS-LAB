
_uthread:     file format elf32-i386


Disassembly of section .text:

00000000 <thread_init>:
extern void thread_switch(void);
static void thread_schedule(void);

void 
thread_init(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 08             	sub    $0x8,%esp
  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  current_thread = &all_thread[0];
   6:	c7 05 a0 0d 00 00 c0 	movl   $0xdc0,0xda0
   d:	0d 00 00 
  current_thread->state = RUNNING;
  10:	a1 a0 0d 00 00       	mov    0xda0,%eax
  15:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  1c:	00 00 00 
  uthread_init((int)thread_schedule);
  1f:	b8 33 00 00 00       	mov    $0x33,%eax
  24:	83 ec 0c             	sub    $0xc,%esp
  27:	50                   	push   %eax
  28:	e8 72 05 00 00       	call   59f <uthread_init>
  2d:	83 c4 10             	add    $0x10,%esp
}
  30:	90                   	nop
  31:	c9                   	leave  
  32:	c3                   	ret    

00000033 <thread_schedule>:

static void 
thread_schedule(void)
{
  33:	55                   	push   %ebp
  34:	89 e5                	mov    %esp,%ebp
  36:	83 ec 18             	sub    $0x18,%esp
  thread_p t;

  if (current_thread != all_thread && current_thread->state == RUNNING) {
  39:	a1 a0 0d 00 00       	mov    0xda0,%eax
  3e:	3d c0 0d 00 00       	cmp    $0xdc0,%eax
  43:	74 1f                	je     64 <thread_schedule+0x31>
  45:	a1 a0 0d 00 00       	mov    0xda0,%eax
  4a:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  50:	83 f8 01             	cmp    $0x1,%eax
  53:	75 0f                	jne    64 <thread_schedule+0x31>
	 current_thread->state = RUNNABLE;
  55:	a1 a0 0d 00 00       	mov    0xda0,%eax
  5a:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
  61:	00 00 00 
  }

  /* Find another runnable thread. */
  next_thread = 0;
  64:	c7 05 a4 0d 00 00 00 	movl   $0x0,0xda4
  6b:	00 00 00 
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  6e:	c7 45 f4 c0 0d 00 00 	movl   $0xdc0,-0xc(%ebp)
  75:	eb 29                	jmp    a0 <thread_schedule+0x6d>
    if (t->state == RUNNABLE && t != current_thread) {
  77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  7a:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  80:	83 f8 02             	cmp    $0x2,%eax
  83:	75 14                	jne    99 <thread_schedule+0x66>
  85:	a1 a0 0d 00 00       	mov    0xda0,%eax
  8a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  8d:	74 0a                	je     99 <thread_schedule+0x66>
      next_thread = t;
  8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  92:	a3 a4 0d 00 00       	mov    %eax,0xda4
      break;
  97:	eb 11                	jmp    aa <thread_schedule+0x77>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  99:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
  a0:	b8 e0 8d 00 00       	mov    $0x8de0,%eax
  a5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  a8:	72 cd                	jb     77 <thread_schedule+0x44>
    }
  }

  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
  aa:	b8 e0 8d 00 00       	mov    $0x8de0,%eax
  af:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  b2:	72 1a                	jb     ce <thread_schedule+0x9b>
  b4:	a1 a0 0d 00 00       	mov    0xda0,%eax
  b9:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  bf:	83 f8 02             	cmp    $0x2,%eax
  c2:	75 0a                	jne    ce <thread_schedule+0x9b>
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
  c4:	a1 a0 0d 00 00       	mov    0xda0,%eax
  c9:	a3 a4 0d 00 00       	mov    %eax,0xda4
  }

  if (next_thread == 0) {
  ce:	a1 a4 0d 00 00       	mov    0xda4,%eax
  d3:	85 c0                	test   %eax,%eax
  d5:	75 24                	jne    fb <thread_schedule+0xc8>
    uthread_init(0);
  d7:	83 ec 0c             	sub    $0xc,%esp
  da:	6a 00                	push   $0x0
  dc:	e8 be 04 00 00       	call   59f <uthread_init>
  e1:	83 c4 10             	add    $0x10,%esp
    printf(2, "thread_schedule: no runnable threads\n");
  e4:	83 ec 08             	sub    $0x8,%esp
  e7:	68 34 0a 00 00       	push   $0xa34
  ec:	6a 02                	push   $0x2
  ee:	e8 88 05 00 00       	call   67b <printf>
  f3:	83 c4 10             	add    $0x10,%esp
    exit();
  f6:	e8 04 04 00 00       	call   4ff <exit>
  }

  if (current_thread != next_thread) {         /* switch threads?  */
  fb:	8b 15 a0 0d 00 00    	mov    0xda0,%edx
 101:	a1 a4 0d 00 00       	mov    0xda4,%eax
 106:	39 c2                	cmp    %eax,%edx
 108:	74 16                	je     120 <thread_schedule+0xed>
    next_thread->state = RUNNING;
 10a:	a1 a4 0d 00 00       	mov    0xda4,%eax
 10f:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
 116:	00 00 00 
    thread_switch();
 119:	e8 58 01 00 00       	call   276 <thread_switch>
  } else
    next_thread = 0;
}
 11e:	eb 0a                	jmp    12a <thread_schedule+0xf7>
    next_thread = 0;
 120:	c7 05 a4 0d 00 00 00 	movl   $0x0,0xda4
 127:	00 00 00 
}
 12a:	90                   	nop
 12b:	c9                   	leave  
 12c:	c3                   	ret    

0000012d <thread_create>:

void 
thread_create(void (*func)())
{
 12d:	55                   	push   %ebp
 12e:	89 e5                	mov    %esp,%ebp
 130:	83 ec 10             	sub    $0x10,%esp
  thread_p t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 133:	c7 45 fc c0 0d 00 00 	movl   $0xdc0,-0x4(%ebp)
 13a:	eb 14                	jmp    150 <thread_create+0x23>
    if (t->state == FREE) break;
 13c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 13f:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 145:	85 c0                	test   %eax,%eax
 147:	74 13                	je     15c <thread_create+0x2f>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 149:	81 45 fc 08 20 00 00 	addl   $0x2008,-0x4(%ebp)
 150:	b8 e0 8d 00 00       	mov    $0x8de0,%eax
 155:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 158:	72 e2                	jb     13c <thread_create+0xf>
 15a:	eb 01                	jmp    15d <thread_create+0x30>
    if (t->state == FREE) break;
 15c:	90                   	nop
  }
  t->sp = (int) (t->stack + STACK_SIZE);   // set sp to the top of the stack
 15d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 160:	83 c0 04             	add    $0x4,%eax
 163:	05 00 20 00 00       	add    $0x2000,%eax
 168:	89 c2                	mov    %eax,%edx
 16a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 16d:	89 10                	mov    %edx,(%eax)
  t->sp -= 4;                              // space for return address
 16f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 172:	8b 00                	mov    (%eax),%eax
 174:	8d 50 fc             	lea    -0x4(%eax),%edx
 177:	8b 45 fc             	mov    -0x4(%ebp),%eax
 17a:	89 10                	mov    %edx,(%eax)
  * (int *) (t->sp) = (int)func;           // push return address on stack
 17c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 17f:	8b 00                	mov    (%eax),%eax
 181:	89 c2                	mov    %eax,%edx
 183:	8b 45 08             	mov    0x8(%ebp),%eax
 186:	89 02                	mov    %eax,(%edx)
  t->sp -= 32;                             // space for registers that thread_switch expects
 188:	8b 45 fc             	mov    -0x4(%ebp),%eax
 18b:	8b 00                	mov    (%eax),%eax
 18d:	8d 50 e0             	lea    -0x20(%eax),%edx
 190:	8b 45 fc             	mov    -0x4(%ebp),%eax
 193:	89 10                	mov    %edx,(%eax)
  t->state = RUNNABLE;
 195:	8b 45 fc             	mov    -0x4(%ebp),%eax
 198:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 19f:	00 00 00 
}
 1a2:	90                   	nop
 1a3:	c9                   	leave  
 1a4:	c3                   	ret    

000001a5 <thread_yield>:

void 
thread_yield(void)
{
 1a5:	55                   	push   %ebp
 1a6:	89 e5                	mov    %esp,%ebp
 1a8:	83 ec 08             	sub    $0x8,%esp
  current_thread->state = RUNNABLE;
 1ab:	a1 a0 0d 00 00       	mov    0xda0,%eax
 1b0:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 1b7:	00 00 00 
  thread_schedule();
 1ba:	e8 74 fe ff ff       	call   33 <thread_schedule>
}
 1bf:	90                   	nop
 1c0:	c9                   	leave  
 1c1:	c3                   	ret    

000001c2 <mythread>:

static void 
mythread(void)
{
 1c2:	55                   	push   %ebp
 1c3:	89 e5                	mov    %esp,%ebp
 1c5:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "my thread running\n");
 1c8:	83 ec 08             	sub    $0x8,%esp
 1cb:	68 5a 0a 00 00       	push   $0xa5a
 1d0:	6a 01                	push   $0x1
 1d2:	e8 a4 04 00 00       	call   67b <printf>
 1d7:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 1da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1e1:	eb 1c                	jmp    1ff <mythread+0x3d>
    printf(1, "%d my thread 0x%x\n", i, (int) current_thread);
 1e3:	a1 a0 0d 00 00       	mov    0xda0,%eax
 1e8:	50                   	push   %eax
 1e9:	ff 75 f4             	push   -0xc(%ebp)
 1ec:	68 6d 0a 00 00       	push   $0xa6d
 1f1:	6a 01                	push   $0x1
 1f3:	e8 83 04 00 00       	call   67b <printf>
 1f8:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 1fb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 1ff:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 203:	7e de                	jle    1e3 <mythread+0x21>
    //thread_yield();
  }
  printf(1, "my thread: exit\n");
 205:	83 ec 08             	sub    $0x8,%esp
 208:	68 80 0a 00 00       	push   $0xa80
 20d:	6a 01                	push   $0x1
 20f:	e8 67 04 00 00       	call   67b <printf>
 214:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 217:	a1 a0 0d 00 00       	mov    0xda0,%eax
 21c:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 223:	00 00 00 
  thread_schedule();
 226:	e8 08 fe ff ff       	call   33 <thread_schedule>
}
 22b:	90                   	nop
 22c:	c9                   	leave  
 22d:	c3                   	ret    

0000022e <main>:


int 
main(int argc, char *argv[]) 
{
 22e:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 232:	83 e4 f0             	and    $0xfffffff0,%esp
 235:	ff 71 fc             	push   -0x4(%ecx)
 238:	55                   	push   %ebp
 239:	89 e5                	mov    %esp,%ebp
 23b:	51                   	push   %ecx
 23c:	83 ec 04             	sub    $0x4,%esp
  thread_init();
 23f:	e8 bc fd ff ff       	call   0 <thread_init>
  thread_create(mythread);
 244:	83 ec 0c             	sub    $0xc,%esp
 247:	68 c2 01 00 00       	push   $0x1c2
 24c:	e8 dc fe ff ff       	call   12d <thread_create>
 251:	83 c4 10             	add    $0x10,%esp
  thread_create(mythread);
 254:	83 ec 0c             	sub    $0xc,%esp
 257:	68 c2 01 00 00       	push   $0x1c2
 25c:	e8 cc fe ff ff       	call   12d <thread_create>
 261:	83 c4 10             	add    $0x10,%esp
  thread_schedule();
 264:	e8 ca fd ff ff       	call   33 <thread_schedule>
  return 0;
 269:	b8 00 00 00 00       	mov    $0x0,%eax
 26e:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 271:	c9                   	leave  
 272:	8d 61 fc             	lea    -0x4(%ecx),%esp
 275:	c3                   	ret    

00000276 <thread_switch>:

	.globl thread_switch
thread_switch:
	/* YOUR CODE HERE */
	
	subl $0x4, %esp
 276:	83 ec 04             	sub    $0x4,%esp
	pushl %eax
 279:	50                   	push   %eax
	pushl %ebx
 27a:	53                   	push   %ebx
	pushl %ecx
 27b:	51                   	push   %ecx
	pushl %edx
 27c:	52                   	push   %edx
	pushl %esi
 27d:	56                   	push   %esi
	pushl %edi
 27e:	57                   	push   %edi
	pushl %ebp
 27f:	55                   	push   %ebp
	
	movl current_thread, %eax
 280:	a1 a0 0d 00 00       	mov    0xda0,%eax
	movl %esp, (%eax)
 285:	89 20                	mov    %esp,(%eax)
	
	movl next_thread, %eax
 287:	a1 a4 0d 00 00       	mov    0xda4,%eax
	movl (%eax), %esp
 28c:	8b 20                	mov    (%eax),%esp

	movl %eax, current_thread
 28e:	a3 a0 0d 00 00       	mov    %eax,0xda0

	movl $0, next_thread
 293:	c7 05 a4 0d 00 00 00 	movl   $0x0,0xda4
 29a:	00 00 00 

	popl %ebp
 29d:	5d                   	pop    %ebp
	popl %edi
 29e:	5f                   	pop    %edi
	popl %esi
 29f:	5e                   	pop    %esi
	popl %edx
 2a0:	5a                   	pop    %edx
	popl %ecx
 2a1:	59                   	pop    %ecx
	popl %ebx
 2a2:	5b                   	pop    %ebx
	popl %eax
 2a3:	58                   	pop    %eax
	addl $0x4, %esp
 2a4:	83 c4 04             	add    $0x4,%esp
	
	ret    /* return to ra */
 2a7:	c3                   	ret    

000002a8 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 2a8:	55                   	push   %ebp
 2a9:	89 e5                	mov    %esp,%ebp
 2ab:	57                   	push   %edi
 2ac:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 2ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2b0:	8b 55 10             	mov    0x10(%ebp),%edx
 2b3:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b6:	89 cb                	mov    %ecx,%ebx
 2b8:	89 df                	mov    %ebx,%edi
 2ba:	89 d1                	mov    %edx,%ecx
 2bc:	fc                   	cld    
 2bd:	f3 aa                	rep stos %al,%es:(%edi)
 2bf:	89 ca                	mov    %ecx,%edx
 2c1:	89 fb                	mov    %edi,%ebx
 2c3:	89 5d 08             	mov    %ebx,0x8(%ebp)
 2c6:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 2c9:	90                   	nop
 2ca:	5b                   	pop    %ebx
 2cb:	5f                   	pop    %edi
 2cc:	5d                   	pop    %ebp
 2cd:	c3                   	ret    

000002ce <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 2ce:	55                   	push   %ebp
 2cf:	89 e5                	mov    %esp,%ebp
 2d1:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 2d4:	8b 45 08             	mov    0x8(%ebp),%eax
 2d7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 2da:	90                   	nop
 2db:	8b 55 0c             	mov    0xc(%ebp),%edx
 2de:	8d 42 01             	lea    0x1(%edx),%eax
 2e1:	89 45 0c             	mov    %eax,0xc(%ebp)
 2e4:	8b 45 08             	mov    0x8(%ebp),%eax
 2e7:	8d 48 01             	lea    0x1(%eax),%ecx
 2ea:	89 4d 08             	mov    %ecx,0x8(%ebp)
 2ed:	0f b6 12             	movzbl (%edx),%edx
 2f0:	88 10                	mov    %dl,(%eax)
 2f2:	0f b6 00             	movzbl (%eax),%eax
 2f5:	84 c0                	test   %al,%al
 2f7:	75 e2                	jne    2db <strcpy+0xd>
    ;
  return os;
 2f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2fc:	c9                   	leave  
 2fd:	c3                   	ret    

000002fe <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2fe:	55                   	push   %ebp
 2ff:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 301:	eb 08                	jmp    30b <strcmp+0xd>
    p++, q++;
 303:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 307:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 30b:	8b 45 08             	mov    0x8(%ebp),%eax
 30e:	0f b6 00             	movzbl (%eax),%eax
 311:	84 c0                	test   %al,%al
 313:	74 10                	je     325 <strcmp+0x27>
 315:	8b 45 08             	mov    0x8(%ebp),%eax
 318:	0f b6 10             	movzbl (%eax),%edx
 31b:	8b 45 0c             	mov    0xc(%ebp),%eax
 31e:	0f b6 00             	movzbl (%eax),%eax
 321:	38 c2                	cmp    %al,%dl
 323:	74 de                	je     303 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 325:	8b 45 08             	mov    0x8(%ebp),%eax
 328:	0f b6 00             	movzbl (%eax),%eax
 32b:	0f b6 d0             	movzbl %al,%edx
 32e:	8b 45 0c             	mov    0xc(%ebp),%eax
 331:	0f b6 00             	movzbl (%eax),%eax
 334:	0f b6 c8             	movzbl %al,%ecx
 337:	89 d0                	mov    %edx,%eax
 339:	29 c8                	sub    %ecx,%eax
}
 33b:	5d                   	pop    %ebp
 33c:	c3                   	ret    

0000033d <strlen>:

uint
strlen(char *s)
{
 33d:	55                   	push   %ebp
 33e:	89 e5                	mov    %esp,%ebp
 340:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 343:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 34a:	eb 04                	jmp    350 <strlen+0x13>
 34c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 350:	8b 55 fc             	mov    -0x4(%ebp),%edx
 353:	8b 45 08             	mov    0x8(%ebp),%eax
 356:	01 d0                	add    %edx,%eax
 358:	0f b6 00             	movzbl (%eax),%eax
 35b:	84 c0                	test   %al,%al
 35d:	75 ed                	jne    34c <strlen+0xf>
    ;
  return n;
 35f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 362:	c9                   	leave  
 363:	c3                   	ret    

00000364 <memset>:

void*
memset(void *dst, int c, uint n)
{
 364:	55                   	push   %ebp
 365:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 367:	8b 45 10             	mov    0x10(%ebp),%eax
 36a:	50                   	push   %eax
 36b:	ff 75 0c             	push   0xc(%ebp)
 36e:	ff 75 08             	push   0x8(%ebp)
 371:	e8 32 ff ff ff       	call   2a8 <stosb>
 376:	83 c4 0c             	add    $0xc,%esp
  return dst;
 379:	8b 45 08             	mov    0x8(%ebp),%eax
}
 37c:	c9                   	leave  
 37d:	c3                   	ret    

0000037e <strchr>:

char*
strchr(const char *s, char c)
{
 37e:	55                   	push   %ebp
 37f:	89 e5                	mov    %esp,%ebp
 381:	83 ec 04             	sub    $0x4,%esp
 384:	8b 45 0c             	mov    0xc(%ebp),%eax
 387:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 38a:	eb 14                	jmp    3a0 <strchr+0x22>
    if(*s == c)
 38c:	8b 45 08             	mov    0x8(%ebp),%eax
 38f:	0f b6 00             	movzbl (%eax),%eax
 392:	38 45 fc             	cmp    %al,-0x4(%ebp)
 395:	75 05                	jne    39c <strchr+0x1e>
      return (char*)s;
 397:	8b 45 08             	mov    0x8(%ebp),%eax
 39a:	eb 13                	jmp    3af <strchr+0x31>
  for(; *s; s++)
 39c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3a0:	8b 45 08             	mov    0x8(%ebp),%eax
 3a3:	0f b6 00             	movzbl (%eax),%eax
 3a6:	84 c0                	test   %al,%al
 3a8:	75 e2                	jne    38c <strchr+0xe>
  return 0;
 3aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
 3af:	c9                   	leave  
 3b0:	c3                   	ret    

000003b1 <gets>:

char*
gets(char *buf, int max)
{
 3b1:	55                   	push   %ebp
 3b2:	89 e5                	mov    %esp,%ebp
 3b4:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3b7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3be:	eb 42                	jmp    402 <gets+0x51>
    cc = read(0, &c, 1);
 3c0:	83 ec 04             	sub    $0x4,%esp
 3c3:	6a 01                	push   $0x1
 3c5:	8d 45 ef             	lea    -0x11(%ebp),%eax
 3c8:	50                   	push   %eax
 3c9:	6a 00                	push   $0x0
 3cb:	e8 47 01 00 00       	call   517 <read>
 3d0:	83 c4 10             	add    $0x10,%esp
 3d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 3d6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3da:	7e 33                	jle    40f <gets+0x5e>
      break;
    buf[i++] = c;
 3dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3df:	8d 50 01             	lea    0x1(%eax),%edx
 3e2:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3e5:	89 c2                	mov    %eax,%edx
 3e7:	8b 45 08             	mov    0x8(%ebp),%eax
 3ea:	01 c2                	add    %eax,%edx
 3ec:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3f0:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 3f2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3f6:	3c 0a                	cmp    $0xa,%al
 3f8:	74 16                	je     410 <gets+0x5f>
 3fa:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3fe:	3c 0d                	cmp    $0xd,%al
 400:	74 0e                	je     410 <gets+0x5f>
  for(i=0; i+1 < max; ){
 402:	8b 45 f4             	mov    -0xc(%ebp),%eax
 405:	83 c0 01             	add    $0x1,%eax
 408:	39 45 0c             	cmp    %eax,0xc(%ebp)
 40b:	7f b3                	jg     3c0 <gets+0xf>
 40d:	eb 01                	jmp    410 <gets+0x5f>
      break;
 40f:	90                   	nop
      break;
  }
  buf[i] = '\0';
 410:	8b 55 f4             	mov    -0xc(%ebp),%edx
 413:	8b 45 08             	mov    0x8(%ebp),%eax
 416:	01 d0                	add    %edx,%eax
 418:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 41b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 41e:	c9                   	leave  
 41f:	c3                   	ret    

00000420 <stat>:

int
stat(char *n, struct stat *st)
{
 420:	55                   	push   %ebp
 421:	89 e5                	mov    %esp,%ebp
 423:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 426:	83 ec 08             	sub    $0x8,%esp
 429:	6a 00                	push   $0x0
 42b:	ff 75 08             	push   0x8(%ebp)
 42e:	e8 0c 01 00 00       	call   53f <open>
 433:	83 c4 10             	add    $0x10,%esp
 436:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 439:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 43d:	79 07                	jns    446 <stat+0x26>
    return -1;
 43f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 444:	eb 25                	jmp    46b <stat+0x4b>
  r = fstat(fd, st);
 446:	83 ec 08             	sub    $0x8,%esp
 449:	ff 75 0c             	push   0xc(%ebp)
 44c:	ff 75 f4             	push   -0xc(%ebp)
 44f:	e8 03 01 00 00       	call   557 <fstat>
 454:	83 c4 10             	add    $0x10,%esp
 457:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 45a:	83 ec 0c             	sub    $0xc,%esp
 45d:	ff 75 f4             	push   -0xc(%ebp)
 460:	e8 c2 00 00 00       	call   527 <close>
 465:	83 c4 10             	add    $0x10,%esp
  return r;
 468:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 46b:	c9                   	leave  
 46c:	c3                   	ret    

0000046d <atoi>:

int
atoi(const char *s)
{
 46d:	55                   	push   %ebp
 46e:	89 e5                	mov    %esp,%ebp
 470:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 473:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 47a:	eb 25                	jmp    4a1 <atoi+0x34>
    n = n*10 + *s++ - '0';
 47c:	8b 55 fc             	mov    -0x4(%ebp),%edx
 47f:	89 d0                	mov    %edx,%eax
 481:	c1 e0 02             	shl    $0x2,%eax
 484:	01 d0                	add    %edx,%eax
 486:	01 c0                	add    %eax,%eax
 488:	89 c1                	mov    %eax,%ecx
 48a:	8b 45 08             	mov    0x8(%ebp),%eax
 48d:	8d 50 01             	lea    0x1(%eax),%edx
 490:	89 55 08             	mov    %edx,0x8(%ebp)
 493:	0f b6 00             	movzbl (%eax),%eax
 496:	0f be c0             	movsbl %al,%eax
 499:	01 c8                	add    %ecx,%eax
 49b:	83 e8 30             	sub    $0x30,%eax
 49e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4a1:	8b 45 08             	mov    0x8(%ebp),%eax
 4a4:	0f b6 00             	movzbl (%eax),%eax
 4a7:	3c 2f                	cmp    $0x2f,%al
 4a9:	7e 0a                	jle    4b5 <atoi+0x48>
 4ab:	8b 45 08             	mov    0x8(%ebp),%eax
 4ae:	0f b6 00             	movzbl (%eax),%eax
 4b1:	3c 39                	cmp    $0x39,%al
 4b3:	7e c7                	jle    47c <atoi+0xf>
  return n;
 4b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4b8:	c9                   	leave  
 4b9:	c3                   	ret    

000004ba <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 4ba:	55                   	push   %ebp
 4bb:	89 e5                	mov    %esp,%ebp
 4bd:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 4c0:	8b 45 08             	mov    0x8(%ebp),%eax
 4c3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 4c6:	8b 45 0c             	mov    0xc(%ebp),%eax
 4c9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 4cc:	eb 17                	jmp    4e5 <memmove+0x2b>
    *dst++ = *src++;
 4ce:	8b 55 f8             	mov    -0x8(%ebp),%edx
 4d1:	8d 42 01             	lea    0x1(%edx),%eax
 4d4:	89 45 f8             	mov    %eax,-0x8(%ebp)
 4d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4da:	8d 48 01             	lea    0x1(%eax),%ecx
 4dd:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 4e0:	0f b6 12             	movzbl (%edx),%edx
 4e3:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 4e5:	8b 45 10             	mov    0x10(%ebp),%eax
 4e8:	8d 50 ff             	lea    -0x1(%eax),%edx
 4eb:	89 55 10             	mov    %edx,0x10(%ebp)
 4ee:	85 c0                	test   %eax,%eax
 4f0:	7f dc                	jg     4ce <memmove+0x14>
  return vdst;
 4f2:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4f5:	c9                   	leave  
 4f6:	c3                   	ret    

000004f7 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 4f7:	b8 01 00 00 00       	mov    $0x1,%eax
 4fc:	cd 40                	int    $0x40
 4fe:	c3                   	ret    

000004ff <exit>:
SYSCALL(exit)
 4ff:	b8 02 00 00 00       	mov    $0x2,%eax
 504:	cd 40                	int    $0x40
 506:	c3                   	ret    

00000507 <wait>:
SYSCALL(wait)
 507:	b8 03 00 00 00       	mov    $0x3,%eax
 50c:	cd 40                	int    $0x40
 50e:	c3                   	ret    

0000050f <pipe>:
SYSCALL(pipe)
 50f:	b8 04 00 00 00       	mov    $0x4,%eax
 514:	cd 40                	int    $0x40
 516:	c3                   	ret    

00000517 <read>:
SYSCALL(read)
 517:	b8 05 00 00 00       	mov    $0x5,%eax
 51c:	cd 40                	int    $0x40
 51e:	c3                   	ret    

0000051f <write>:
SYSCALL(write)
 51f:	b8 10 00 00 00       	mov    $0x10,%eax
 524:	cd 40                	int    $0x40
 526:	c3                   	ret    

00000527 <close>:
SYSCALL(close)
 527:	b8 15 00 00 00       	mov    $0x15,%eax
 52c:	cd 40                	int    $0x40
 52e:	c3                   	ret    

0000052f <kill>:
SYSCALL(kill)
 52f:	b8 06 00 00 00       	mov    $0x6,%eax
 534:	cd 40                	int    $0x40
 536:	c3                   	ret    

00000537 <exec>:
SYSCALL(exec)
 537:	b8 07 00 00 00       	mov    $0x7,%eax
 53c:	cd 40                	int    $0x40
 53e:	c3                   	ret    

0000053f <open>:
SYSCALL(open)
 53f:	b8 0f 00 00 00       	mov    $0xf,%eax
 544:	cd 40                	int    $0x40
 546:	c3                   	ret    

00000547 <mknod>:
SYSCALL(mknod)
 547:	b8 11 00 00 00       	mov    $0x11,%eax
 54c:	cd 40                	int    $0x40
 54e:	c3                   	ret    

0000054f <unlink>:
SYSCALL(unlink)
 54f:	b8 12 00 00 00       	mov    $0x12,%eax
 554:	cd 40                	int    $0x40
 556:	c3                   	ret    

00000557 <fstat>:
SYSCALL(fstat)
 557:	b8 08 00 00 00       	mov    $0x8,%eax
 55c:	cd 40                	int    $0x40
 55e:	c3                   	ret    

0000055f <link>:
SYSCALL(link)
 55f:	b8 13 00 00 00       	mov    $0x13,%eax
 564:	cd 40                	int    $0x40
 566:	c3                   	ret    

00000567 <mkdir>:
SYSCALL(mkdir)
 567:	b8 14 00 00 00       	mov    $0x14,%eax
 56c:	cd 40                	int    $0x40
 56e:	c3                   	ret    

0000056f <chdir>:
SYSCALL(chdir)
 56f:	b8 09 00 00 00       	mov    $0x9,%eax
 574:	cd 40                	int    $0x40
 576:	c3                   	ret    

00000577 <dup>:
SYSCALL(dup)
 577:	b8 0a 00 00 00       	mov    $0xa,%eax
 57c:	cd 40                	int    $0x40
 57e:	c3                   	ret    

0000057f <getpid>:
SYSCALL(getpid)
 57f:	b8 0b 00 00 00       	mov    $0xb,%eax
 584:	cd 40                	int    $0x40
 586:	c3                   	ret    

00000587 <sbrk>:
SYSCALL(sbrk)
 587:	b8 0c 00 00 00       	mov    $0xc,%eax
 58c:	cd 40                	int    $0x40
 58e:	c3                   	ret    

0000058f <sleep>:
SYSCALL(sleep)
 58f:	b8 0d 00 00 00       	mov    $0xd,%eax
 594:	cd 40                	int    $0x40
 596:	c3                   	ret    

00000597 <uptime>:
SYSCALL(uptime)
 597:	b8 0e 00 00 00       	mov    $0xe,%eax
 59c:	cd 40                	int    $0x40
 59e:	c3                   	ret    

0000059f <uthread_init>:
 59f:	b8 16 00 00 00       	mov    $0x16,%eax
 5a4:	cd 40                	int    $0x40
 5a6:	c3                   	ret    

000005a7 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5a7:	55                   	push   %ebp
 5a8:	89 e5                	mov    %esp,%ebp
 5aa:	83 ec 18             	sub    $0x18,%esp
 5ad:	8b 45 0c             	mov    0xc(%ebp),%eax
 5b0:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5b3:	83 ec 04             	sub    $0x4,%esp
 5b6:	6a 01                	push   $0x1
 5b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5bb:	50                   	push   %eax
 5bc:	ff 75 08             	push   0x8(%ebp)
 5bf:	e8 5b ff ff ff       	call   51f <write>
 5c4:	83 c4 10             	add    $0x10,%esp
}
 5c7:	90                   	nop
 5c8:	c9                   	leave  
 5c9:	c3                   	ret    

000005ca <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5ca:	55                   	push   %ebp
 5cb:	89 e5                	mov    %esp,%ebp
 5cd:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5d0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5d7:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 5db:	74 17                	je     5f4 <printint+0x2a>
 5dd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5e1:	79 11                	jns    5f4 <printint+0x2a>
    neg = 1;
 5e3:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 5ea:	8b 45 0c             	mov    0xc(%ebp),%eax
 5ed:	f7 d8                	neg    %eax
 5ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5f2:	eb 06                	jmp    5fa <printint+0x30>
  } else {
    x = xx;
 5f4:	8b 45 0c             	mov    0xc(%ebp),%eax
 5f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 5fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 601:	8b 4d 10             	mov    0x10(%ebp),%ecx
 604:	8b 45 ec             	mov    -0x14(%ebp),%eax
 607:	ba 00 00 00 00       	mov    $0x0,%edx
 60c:	f7 f1                	div    %ecx
 60e:	89 d1                	mov    %edx,%ecx
 610:	8b 45 f4             	mov    -0xc(%ebp),%eax
 613:	8d 50 01             	lea    0x1(%eax),%edx
 616:	89 55 f4             	mov    %edx,-0xc(%ebp)
 619:	0f b6 91 84 0d 00 00 	movzbl 0xd84(%ecx),%edx
 620:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 624:	8b 4d 10             	mov    0x10(%ebp),%ecx
 627:	8b 45 ec             	mov    -0x14(%ebp),%eax
 62a:	ba 00 00 00 00       	mov    $0x0,%edx
 62f:	f7 f1                	div    %ecx
 631:	89 45 ec             	mov    %eax,-0x14(%ebp)
 634:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 638:	75 c7                	jne    601 <printint+0x37>
  if(neg)
 63a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 63e:	74 2d                	je     66d <printint+0xa3>
    buf[i++] = '-';
 640:	8b 45 f4             	mov    -0xc(%ebp),%eax
 643:	8d 50 01             	lea    0x1(%eax),%edx
 646:	89 55 f4             	mov    %edx,-0xc(%ebp)
 649:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 64e:	eb 1d                	jmp    66d <printint+0xa3>
    putc(fd, buf[i]);
 650:	8d 55 dc             	lea    -0x24(%ebp),%edx
 653:	8b 45 f4             	mov    -0xc(%ebp),%eax
 656:	01 d0                	add    %edx,%eax
 658:	0f b6 00             	movzbl (%eax),%eax
 65b:	0f be c0             	movsbl %al,%eax
 65e:	83 ec 08             	sub    $0x8,%esp
 661:	50                   	push   %eax
 662:	ff 75 08             	push   0x8(%ebp)
 665:	e8 3d ff ff ff       	call   5a7 <putc>
 66a:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 66d:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 671:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 675:	79 d9                	jns    650 <printint+0x86>
}
 677:	90                   	nop
 678:	90                   	nop
 679:	c9                   	leave  
 67a:	c3                   	ret    

0000067b <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 67b:	55                   	push   %ebp
 67c:	89 e5                	mov    %esp,%ebp
 67e:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 681:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 688:	8d 45 0c             	lea    0xc(%ebp),%eax
 68b:	83 c0 04             	add    $0x4,%eax
 68e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 691:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 698:	e9 59 01 00 00       	jmp    7f6 <printf+0x17b>
    c = fmt[i] & 0xff;
 69d:	8b 55 0c             	mov    0xc(%ebp),%edx
 6a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6a3:	01 d0                	add    %edx,%eax
 6a5:	0f b6 00             	movzbl (%eax),%eax
 6a8:	0f be c0             	movsbl %al,%eax
 6ab:	25 ff 00 00 00       	and    $0xff,%eax
 6b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6b3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6b7:	75 2c                	jne    6e5 <printf+0x6a>
      if(c == '%'){
 6b9:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6bd:	75 0c                	jne    6cb <printf+0x50>
        state = '%';
 6bf:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6c6:	e9 27 01 00 00       	jmp    7f2 <printf+0x177>
      } else {
        putc(fd, c);
 6cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6ce:	0f be c0             	movsbl %al,%eax
 6d1:	83 ec 08             	sub    $0x8,%esp
 6d4:	50                   	push   %eax
 6d5:	ff 75 08             	push   0x8(%ebp)
 6d8:	e8 ca fe ff ff       	call   5a7 <putc>
 6dd:	83 c4 10             	add    $0x10,%esp
 6e0:	e9 0d 01 00 00       	jmp    7f2 <printf+0x177>
      }
    } else if(state == '%'){
 6e5:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6e9:	0f 85 03 01 00 00    	jne    7f2 <printf+0x177>
      if(c == 'd'){
 6ef:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 6f3:	75 1e                	jne    713 <printf+0x98>
        printint(fd, *ap, 10, 1);
 6f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6f8:	8b 00                	mov    (%eax),%eax
 6fa:	6a 01                	push   $0x1
 6fc:	6a 0a                	push   $0xa
 6fe:	50                   	push   %eax
 6ff:	ff 75 08             	push   0x8(%ebp)
 702:	e8 c3 fe ff ff       	call   5ca <printint>
 707:	83 c4 10             	add    $0x10,%esp
        ap++;
 70a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 70e:	e9 d8 00 00 00       	jmp    7eb <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 713:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 717:	74 06                	je     71f <printf+0xa4>
 719:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 71d:	75 1e                	jne    73d <printf+0xc2>
        printint(fd, *ap, 16, 0);
 71f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 722:	8b 00                	mov    (%eax),%eax
 724:	6a 00                	push   $0x0
 726:	6a 10                	push   $0x10
 728:	50                   	push   %eax
 729:	ff 75 08             	push   0x8(%ebp)
 72c:	e8 99 fe ff ff       	call   5ca <printint>
 731:	83 c4 10             	add    $0x10,%esp
        ap++;
 734:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 738:	e9 ae 00 00 00       	jmp    7eb <printf+0x170>
      } else if(c == 's'){
 73d:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 741:	75 43                	jne    786 <printf+0x10b>
        s = (char*)*ap;
 743:	8b 45 e8             	mov    -0x18(%ebp),%eax
 746:	8b 00                	mov    (%eax),%eax
 748:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 74b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 74f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 753:	75 25                	jne    77a <printf+0xff>
          s = "(null)";
 755:	c7 45 f4 91 0a 00 00 	movl   $0xa91,-0xc(%ebp)
        while(*s != 0){
 75c:	eb 1c                	jmp    77a <printf+0xff>
          putc(fd, *s);
 75e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 761:	0f b6 00             	movzbl (%eax),%eax
 764:	0f be c0             	movsbl %al,%eax
 767:	83 ec 08             	sub    $0x8,%esp
 76a:	50                   	push   %eax
 76b:	ff 75 08             	push   0x8(%ebp)
 76e:	e8 34 fe ff ff       	call   5a7 <putc>
 773:	83 c4 10             	add    $0x10,%esp
          s++;
 776:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 77a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 77d:	0f b6 00             	movzbl (%eax),%eax
 780:	84 c0                	test   %al,%al
 782:	75 da                	jne    75e <printf+0xe3>
 784:	eb 65                	jmp    7eb <printf+0x170>
        }
      } else if(c == 'c'){
 786:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 78a:	75 1d                	jne    7a9 <printf+0x12e>
        putc(fd, *ap);
 78c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 78f:	8b 00                	mov    (%eax),%eax
 791:	0f be c0             	movsbl %al,%eax
 794:	83 ec 08             	sub    $0x8,%esp
 797:	50                   	push   %eax
 798:	ff 75 08             	push   0x8(%ebp)
 79b:	e8 07 fe ff ff       	call   5a7 <putc>
 7a0:	83 c4 10             	add    $0x10,%esp
        ap++;
 7a3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7a7:	eb 42                	jmp    7eb <printf+0x170>
      } else if(c == '%'){
 7a9:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7ad:	75 17                	jne    7c6 <printf+0x14b>
        putc(fd, c);
 7af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7b2:	0f be c0             	movsbl %al,%eax
 7b5:	83 ec 08             	sub    $0x8,%esp
 7b8:	50                   	push   %eax
 7b9:	ff 75 08             	push   0x8(%ebp)
 7bc:	e8 e6 fd ff ff       	call   5a7 <putc>
 7c1:	83 c4 10             	add    $0x10,%esp
 7c4:	eb 25                	jmp    7eb <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7c6:	83 ec 08             	sub    $0x8,%esp
 7c9:	6a 25                	push   $0x25
 7cb:	ff 75 08             	push   0x8(%ebp)
 7ce:	e8 d4 fd ff ff       	call   5a7 <putc>
 7d3:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 7d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7d9:	0f be c0             	movsbl %al,%eax
 7dc:	83 ec 08             	sub    $0x8,%esp
 7df:	50                   	push   %eax
 7e0:	ff 75 08             	push   0x8(%ebp)
 7e3:	e8 bf fd ff ff       	call   5a7 <putc>
 7e8:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 7eb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 7f2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 7f6:	8b 55 0c             	mov    0xc(%ebp),%edx
 7f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7fc:	01 d0                	add    %edx,%eax
 7fe:	0f b6 00             	movzbl (%eax),%eax
 801:	84 c0                	test   %al,%al
 803:	0f 85 94 fe ff ff    	jne    69d <printf+0x22>
    }
  }
}
 809:	90                   	nop
 80a:	90                   	nop
 80b:	c9                   	leave  
 80c:	c3                   	ret    

0000080d <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 80d:	55                   	push   %ebp
 80e:	89 e5                	mov    %esp,%ebp
 810:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 813:	8b 45 08             	mov    0x8(%ebp),%eax
 816:	83 e8 08             	sub    $0x8,%eax
 819:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 81c:	a1 e8 8d 00 00       	mov    0x8de8,%eax
 821:	89 45 fc             	mov    %eax,-0x4(%ebp)
 824:	eb 24                	jmp    84a <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 826:	8b 45 fc             	mov    -0x4(%ebp),%eax
 829:	8b 00                	mov    (%eax),%eax
 82b:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 82e:	72 12                	jb     842 <free+0x35>
 830:	8b 45 f8             	mov    -0x8(%ebp),%eax
 833:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 836:	77 24                	ja     85c <free+0x4f>
 838:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83b:	8b 00                	mov    (%eax),%eax
 83d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 840:	72 1a                	jb     85c <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 842:	8b 45 fc             	mov    -0x4(%ebp),%eax
 845:	8b 00                	mov    (%eax),%eax
 847:	89 45 fc             	mov    %eax,-0x4(%ebp)
 84a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 84d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 850:	76 d4                	jbe    826 <free+0x19>
 852:	8b 45 fc             	mov    -0x4(%ebp),%eax
 855:	8b 00                	mov    (%eax),%eax
 857:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 85a:	73 ca                	jae    826 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 85c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 85f:	8b 40 04             	mov    0x4(%eax),%eax
 862:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 869:	8b 45 f8             	mov    -0x8(%ebp),%eax
 86c:	01 c2                	add    %eax,%edx
 86e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 871:	8b 00                	mov    (%eax),%eax
 873:	39 c2                	cmp    %eax,%edx
 875:	75 24                	jne    89b <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 877:	8b 45 f8             	mov    -0x8(%ebp),%eax
 87a:	8b 50 04             	mov    0x4(%eax),%edx
 87d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 880:	8b 00                	mov    (%eax),%eax
 882:	8b 40 04             	mov    0x4(%eax),%eax
 885:	01 c2                	add    %eax,%edx
 887:	8b 45 f8             	mov    -0x8(%ebp),%eax
 88a:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 88d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 890:	8b 00                	mov    (%eax),%eax
 892:	8b 10                	mov    (%eax),%edx
 894:	8b 45 f8             	mov    -0x8(%ebp),%eax
 897:	89 10                	mov    %edx,(%eax)
 899:	eb 0a                	jmp    8a5 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 89b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 89e:	8b 10                	mov    (%eax),%edx
 8a0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a3:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a8:	8b 40 04             	mov    0x4(%eax),%eax
 8ab:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b5:	01 d0                	add    %edx,%eax
 8b7:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8ba:	75 20                	jne    8dc <free+0xcf>
    p->s.size += bp->s.size;
 8bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8bf:	8b 50 04             	mov    0x4(%eax),%edx
 8c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c5:	8b 40 04             	mov    0x4(%eax),%eax
 8c8:	01 c2                	add    %eax,%edx
 8ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8cd:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8d0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d3:	8b 10                	mov    (%eax),%edx
 8d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d8:	89 10                	mov    %edx,(%eax)
 8da:	eb 08                	jmp    8e4 <free+0xd7>
  } else
    p->s.ptr = bp;
 8dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8df:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8e2:	89 10                	mov    %edx,(%eax)
  freep = p;
 8e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e7:	a3 e8 8d 00 00       	mov    %eax,0x8de8
}
 8ec:	90                   	nop
 8ed:	c9                   	leave  
 8ee:	c3                   	ret    

000008ef <morecore>:

static Header*
morecore(uint nu)
{
 8ef:	55                   	push   %ebp
 8f0:	89 e5                	mov    %esp,%ebp
 8f2:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 8f5:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8fc:	77 07                	ja     905 <morecore+0x16>
    nu = 4096;
 8fe:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 905:	8b 45 08             	mov    0x8(%ebp),%eax
 908:	c1 e0 03             	shl    $0x3,%eax
 90b:	83 ec 0c             	sub    $0xc,%esp
 90e:	50                   	push   %eax
 90f:	e8 73 fc ff ff       	call   587 <sbrk>
 914:	83 c4 10             	add    $0x10,%esp
 917:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 91a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 91e:	75 07                	jne    927 <morecore+0x38>
    return 0;
 920:	b8 00 00 00 00       	mov    $0x0,%eax
 925:	eb 26                	jmp    94d <morecore+0x5e>
  hp = (Header*)p;
 927:	8b 45 f4             	mov    -0xc(%ebp),%eax
 92a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 92d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 930:	8b 55 08             	mov    0x8(%ebp),%edx
 933:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 936:	8b 45 f0             	mov    -0x10(%ebp),%eax
 939:	83 c0 08             	add    $0x8,%eax
 93c:	83 ec 0c             	sub    $0xc,%esp
 93f:	50                   	push   %eax
 940:	e8 c8 fe ff ff       	call   80d <free>
 945:	83 c4 10             	add    $0x10,%esp
  return freep;
 948:	a1 e8 8d 00 00       	mov    0x8de8,%eax
}
 94d:	c9                   	leave  
 94e:	c3                   	ret    

0000094f <malloc>:

void*
malloc(uint nbytes)
{
 94f:	55                   	push   %ebp
 950:	89 e5                	mov    %esp,%ebp
 952:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 955:	8b 45 08             	mov    0x8(%ebp),%eax
 958:	83 c0 07             	add    $0x7,%eax
 95b:	c1 e8 03             	shr    $0x3,%eax
 95e:	83 c0 01             	add    $0x1,%eax
 961:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 964:	a1 e8 8d 00 00       	mov    0x8de8,%eax
 969:	89 45 f0             	mov    %eax,-0x10(%ebp)
 96c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 970:	75 23                	jne    995 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 972:	c7 45 f0 e0 8d 00 00 	movl   $0x8de0,-0x10(%ebp)
 979:	8b 45 f0             	mov    -0x10(%ebp),%eax
 97c:	a3 e8 8d 00 00       	mov    %eax,0x8de8
 981:	a1 e8 8d 00 00       	mov    0x8de8,%eax
 986:	a3 e0 8d 00 00       	mov    %eax,0x8de0
    base.s.size = 0;
 98b:	c7 05 e4 8d 00 00 00 	movl   $0x0,0x8de4
 992:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 995:	8b 45 f0             	mov    -0x10(%ebp),%eax
 998:	8b 00                	mov    (%eax),%eax
 99a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 99d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a0:	8b 40 04             	mov    0x4(%eax),%eax
 9a3:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 9a6:	77 4d                	ja     9f5 <malloc+0xa6>
      if(p->s.size == nunits)
 9a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ab:	8b 40 04             	mov    0x4(%eax),%eax
 9ae:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 9b1:	75 0c                	jne    9bf <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 9b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b6:	8b 10                	mov    (%eax),%edx
 9b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9bb:	89 10                	mov    %edx,(%eax)
 9bd:	eb 26                	jmp    9e5 <malloc+0x96>
      else {
        p->s.size -= nunits;
 9bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c2:	8b 40 04             	mov    0x4(%eax),%eax
 9c5:	2b 45 ec             	sub    -0x14(%ebp),%eax
 9c8:	89 c2                	mov    %eax,%edx
 9ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9cd:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d3:	8b 40 04             	mov    0x4(%eax),%eax
 9d6:	c1 e0 03             	shl    $0x3,%eax
 9d9:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9df:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9e2:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9e8:	a3 e8 8d 00 00       	mov    %eax,0x8de8
      return (void*)(p + 1);
 9ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f0:	83 c0 08             	add    $0x8,%eax
 9f3:	eb 3b                	jmp    a30 <malloc+0xe1>
    }
    if(p == freep)
 9f5:	a1 e8 8d 00 00       	mov    0x8de8,%eax
 9fa:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 9fd:	75 1e                	jne    a1d <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 9ff:	83 ec 0c             	sub    $0xc,%esp
 a02:	ff 75 ec             	push   -0x14(%ebp)
 a05:	e8 e5 fe ff ff       	call   8ef <morecore>
 a0a:	83 c4 10             	add    $0x10,%esp
 a0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a10:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a14:	75 07                	jne    a1d <malloc+0xce>
        return 0;
 a16:	b8 00 00 00 00       	mov    $0x0,%eax
 a1b:	eb 13                	jmp    a30 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a20:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a26:	8b 00                	mov    (%eax),%eax
 a28:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a2b:	e9 6d ff ff ff       	jmp    99d <malloc+0x4e>
  }
}
 a30:	c9                   	leave  
 a31:	c3                   	ret    
