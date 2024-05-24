
_recurse:     file format elf32-i386


Disassembly of section .text:

00000000 <recurse>:
// Prevent this function from being optimized, which might give it closed form
#pragma GCC push_options
#pragma GCC optimize ("O0")

static int recurse(int n)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 08             	sub    $0x8,%esp
  if(n == 0)
   6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
   a:	75 07                	jne    13 <recurse+0x13>
    return 0;
   c:	b8 00 00 00 00       	mov    $0x0,%eax
  11:	eb 17                	jmp    2a <recurse+0x2a>
  return n + recurse(n - 1);
  13:	8b 45 08             	mov    0x8(%ebp),%eax
  16:	83 e8 01             	sub    $0x1,%eax
  19:	83 ec 0c             	sub    $0xc,%esp
  1c:	50                   	push   %eax
  1d:	e8 de ff ff ff       	call   0 <recurse>
  22:	83 c4 10             	add    $0x10,%esp
  25:	8b 55 08             	mov    0x8(%ebp),%edx
  28:	01 d0                	add    %edx,%eax
}
  2a:	c9                   	leave  
  2b:	c3                   	ret    

0000002c <main>:
#pragma GCC pop_options

int main(int argc, char *argv[])
{
  2c:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  30:	83 e4 f0             	and    $0xfffffff0,%esp
  33:	ff 71 fc             	push   -0x4(%ecx)
  36:	55                   	push   %ebp
  37:	89 e5                	mov    %esp,%ebp
  39:	51                   	push   %ecx
  3a:	83 ec 14             	sub    $0x14,%esp
  3d:	89 c8                	mov    %ecx,%eax
  int n, m;

  if(argc != 2){
  3f:	83 38 02             	cmpl   $0x2,(%eax)
  42:	74 1d                	je     61 <main+0x35>
    printf(1, "Usage: %s levels\n", argv[0]);
  44:	8b 40 04             	mov    0x4(%eax),%eax
  47:	8b 00                	mov    (%eax),%eax
  49:	83 ec 04             	sub    $0x4,%esp
  4c:	50                   	push   %eax
  4d:	68 42 08 00 00       	push   $0x842
  52:	6a 01                	push   $0x1
  54:	e8 32 04 00 00       	call   48b <printf>
  59:	83 c4 10             	add    $0x10,%esp
    exit();
  5c:	e8 ae 02 00 00       	call   30f <exit>
  }
  //printpt(getpid()); // Uncomment for the test.
  n = atoi(argv[1]);
  61:	8b 40 04             	mov    0x4(%eax),%eax
  64:	83 c0 04             	add    $0x4,%eax
  67:	8b 00                	mov    (%eax),%eax
  69:	83 ec 0c             	sub    $0xc,%esp
  6c:	50                   	push   %eax
  6d:	e8 0b 02 00 00       	call   27d <atoi>
  72:	83 c4 10             	add    $0x10,%esp
  75:	89 45 f4             	mov    %eax,-0xc(%ebp)
  printf(1, "Recursing %d levels\n", n);
  78:	83 ec 04             	sub    $0x4,%esp
  7b:	ff 75 f4             	push   -0xc(%ebp)
  7e:	68 54 08 00 00       	push   $0x854
  83:	6a 01                	push   $0x1
  85:	e8 01 04 00 00       	call   48b <printf>
  8a:	83 c4 10             	add    $0x10,%esp
  m = recurse(n);
  8d:	83 ec 0c             	sub    $0xc,%esp
  90:	ff 75 f4             	push   -0xc(%ebp)
  93:	e8 68 ff ff ff       	call   0 <recurse>
  98:	83 c4 10             	add    $0x10,%esp
  9b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  printf(1, "Yielded a value of %d\n", m);
  9e:	83 ec 04             	sub    $0x4,%esp
  a1:	ff 75 f0             	push   -0x10(%ebp)
  a4:	68 69 08 00 00       	push   $0x869
  a9:	6a 01                	push   $0x1
  ab:	e8 db 03 00 00       	call   48b <printf>
  b0:	83 c4 10             	add    $0x10,%esp
  //printpt(getpid()); // Uncomment for the test.
  exit();
  b3:	e8 57 02 00 00       	call   30f <exit>

000000b8 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  b8:	55                   	push   %ebp
  b9:	89 e5                	mov    %esp,%ebp
  bb:	57                   	push   %edi
  bc:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  c0:	8b 55 10             	mov    0x10(%ebp),%edx
  c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  c6:	89 cb                	mov    %ecx,%ebx
  c8:	89 df                	mov    %ebx,%edi
  ca:	89 d1                	mov    %edx,%ecx
  cc:	fc                   	cld    
  cd:	f3 aa                	rep stos %al,%es:(%edi)
  cf:	89 ca                	mov    %ecx,%edx
  d1:	89 fb                	mov    %edi,%ebx
  d3:	89 5d 08             	mov    %ebx,0x8(%ebp)
  d6:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  d9:	90                   	nop
  da:	5b                   	pop    %ebx
  db:	5f                   	pop    %edi
  dc:	5d                   	pop    %ebp
  dd:	c3                   	ret    

000000de <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  de:	55                   	push   %ebp
  df:	89 e5                	mov    %esp,%ebp
  e1:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  e4:	8b 45 08             	mov    0x8(%ebp),%eax
  e7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  ea:	90                   	nop
  eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  ee:	8d 42 01             	lea    0x1(%edx),%eax
  f1:	89 45 0c             	mov    %eax,0xc(%ebp)
  f4:	8b 45 08             	mov    0x8(%ebp),%eax
  f7:	8d 48 01             	lea    0x1(%eax),%ecx
  fa:	89 4d 08             	mov    %ecx,0x8(%ebp)
  fd:	0f b6 12             	movzbl (%edx),%edx
 100:	88 10                	mov    %dl,(%eax)
 102:	0f b6 00             	movzbl (%eax),%eax
 105:	84 c0                	test   %al,%al
 107:	75 e2                	jne    eb <strcpy+0xd>
    ;
  return os;
 109:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 10c:	c9                   	leave  
 10d:	c3                   	ret    

0000010e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 10e:	55                   	push   %ebp
 10f:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 111:	eb 08                	jmp    11b <strcmp+0xd>
    p++, q++;
 113:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 117:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 11b:	8b 45 08             	mov    0x8(%ebp),%eax
 11e:	0f b6 00             	movzbl (%eax),%eax
 121:	84 c0                	test   %al,%al
 123:	74 10                	je     135 <strcmp+0x27>
 125:	8b 45 08             	mov    0x8(%ebp),%eax
 128:	0f b6 10             	movzbl (%eax),%edx
 12b:	8b 45 0c             	mov    0xc(%ebp),%eax
 12e:	0f b6 00             	movzbl (%eax),%eax
 131:	38 c2                	cmp    %al,%dl
 133:	74 de                	je     113 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 135:	8b 45 08             	mov    0x8(%ebp),%eax
 138:	0f b6 00             	movzbl (%eax),%eax
 13b:	0f b6 d0             	movzbl %al,%edx
 13e:	8b 45 0c             	mov    0xc(%ebp),%eax
 141:	0f b6 00             	movzbl (%eax),%eax
 144:	0f b6 c8             	movzbl %al,%ecx
 147:	89 d0                	mov    %edx,%eax
 149:	29 c8                	sub    %ecx,%eax
}
 14b:	5d                   	pop    %ebp
 14c:	c3                   	ret    

0000014d <strlen>:

uint
strlen(char *s)
{
 14d:	55                   	push   %ebp
 14e:	89 e5                	mov    %esp,%ebp
 150:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 153:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 15a:	eb 04                	jmp    160 <strlen+0x13>
 15c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 160:	8b 55 fc             	mov    -0x4(%ebp),%edx
 163:	8b 45 08             	mov    0x8(%ebp),%eax
 166:	01 d0                	add    %edx,%eax
 168:	0f b6 00             	movzbl (%eax),%eax
 16b:	84 c0                	test   %al,%al
 16d:	75 ed                	jne    15c <strlen+0xf>
    ;
  return n;
 16f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 172:	c9                   	leave  
 173:	c3                   	ret    

00000174 <memset>:

void*
memset(void *dst, int c, uint n)
{
 174:	55                   	push   %ebp
 175:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 177:	8b 45 10             	mov    0x10(%ebp),%eax
 17a:	50                   	push   %eax
 17b:	ff 75 0c             	push   0xc(%ebp)
 17e:	ff 75 08             	push   0x8(%ebp)
 181:	e8 32 ff ff ff       	call   b8 <stosb>
 186:	83 c4 0c             	add    $0xc,%esp
  return dst;
 189:	8b 45 08             	mov    0x8(%ebp),%eax
}
 18c:	c9                   	leave  
 18d:	c3                   	ret    

0000018e <strchr>:

char*
strchr(const char *s, char c)
{
 18e:	55                   	push   %ebp
 18f:	89 e5                	mov    %esp,%ebp
 191:	83 ec 04             	sub    $0x4,%esp
 194:	8b 45 0c             	mov    0xc(%ebp),%eax
 197:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 19a:	eb 14                	jmp    1b0 <strchr+0x22>
    if(*s == c)
 19c:	8b 45 08             	mov    0x8(%ebp),%eax
 19f:	0f b6 00             	movzbl (%eax),%eax
 1a2:	38 45 fc             	cmp    %al,-0x4(%ebp)
 1a5:	75 05                	jne    1ac <strchr+0x1e>
      return (char*)s;
 1a7:	8b 45 08             	mov    0x8(%ebp),%eax
 1aa:	eb 13                	jmp    1bf <strchr+0x31>
  for(; *s; s++)
 1ac:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1b0:	8b 45 08             	mov    0x8(%ebp),%eax
 1b3:	0f b6 00             	movzbl (%eax),%eax
 1b6:	84 c0                	test   %al,%al
 1b8:	75 e2                	jne    19c <strchr+0xe>
  return 0;
 1ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1bf:	c9                   	leave  
 1c0:	c3                   	ret    

000001c1 <gets>:

char*
gets(char *buf, int max)
{
 1c1:	55                   	push   %ebp
 1c2:	89 e5                	mov    %esp,%ebp
 1c4:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1c7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1ce:	eb 42                	jmp    212 <gets+0x51>
    cc = read(0, &c, 1);
 1d0:	83 ec 04             	sub    $0x4,%esp
 1d3:	6a 01                	push   $0x1
 1d5:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1d8:	50                   	push   %eax
 1d9:	6a 00                	push   $0x0
 1db:	e8 47 01 00 00       	call   327 <read>
 1e0:	83 c4 10             	add    $0x10,%esp
 1e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1e6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1ea:	7e 33                	jle    21f <gets+0x5e>
      break;
    buf[i++] = c;
 1ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ef:	8d 50 01             	lea    0x1(%eax),%edx
 1f2:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1f5:	89 c2                	mov    %eax,%edx
 1f7:	8b 45 08             	mov    0x8(%ebp),%eax
 1fa:	01 c2                	add    %eax,%edx
 1fc:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 200:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 202:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 206:	3c 0a                	cmp    $0xa,%al
 208:	74 16                	je     220 <gets+0x5f>
 20a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 20e:	3c 0d                	cmp    $0xd,%al
 210:	74 0e                	je     220 <gets+0x5f>
  for(i=0; i+1 < max; ){
 212:	8b 45 f4             	mov    -0xc(%ebp),%eax
 215:	83 c0 01             	add    $0x1,%eax
 218:	39 45 0c             	cmp    %eax,0xc(%ebp)
 21b:	7f b3                	jg     1d0 <gets+0xf>
 21d:	eb 01                	jmp    220 <gets+0x5f>
      break;
 21f:	90                   	nop
      break;
  }
  buf[i] = '\0';
 220:	8b 55 f4             	mov    -0xc(%ebp),%edx
 223:	8b 45 08             	mov    0x8(%ebp),%eax
 226:	01 d0                	add    %edx,%eax
 228:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 22b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 22e:	c9                   	leave  
 22f:	c3                   	ret    

00000230 <stat>:

int
stat(char *n, struct stat *st)
{
 230:	55                   	push   %ebp
 231:	89 e5                	mov    %esp,%ebp
 233:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 236:	83 ec 08             	sub    $0x8,%esp
 239:	6a 00                	push   $0x0
 23b:	ff 75 08             	push   0x8(%ebp)
 23e:	e8 0c 01 00 00       	call   34f <open>
 243:	83 c4 10             	add    $0x10,%esp
 246:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 249:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 24d:	79 07                	jns    256 <stat+0x26>
    return -1;
 24f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 254:	eb 25                	jmp    27b <stat+0x4b>
  r = fstat(fd, st);
 256:	83 ec 08             	sub    $0x8,%esp
 259:	ff 75 0c             	push   0xc(%ebp)
 25c:	ff 75 f4             	push   -0xc(%ebp)
 25f:	e8 03 01 00 00       	call   367 <fstat>
 264:	83 c4 10             	add    $0x10,%esp
 267:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 26a:	83 ec 0c             	sub    $0xc,%esp
 26d:	ff 75 f4             	push   -0xc(%ebp)
 270:	e8 c2 00 00 00       	call   337 <close>
 275:	83 c4 10             	add    $0x10,%esp
  return r;
 278:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 27b:	c9                   	leave  
 27c:	c3                   	ret    

0000027d <atoi>:

int
atoi(const char *s)
{
 27d:	55                   	push   %ebp
 27e:	89 e5                	mov    %esp,%ebp
 280:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 283:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 28a:	eb 25                	jmp    2b1 <atoi+0x34>
    n = n*10 + *s++ - '0';
 28c:	8b 55 fc             	mov    -0x4(%ebp),%edx
 28f:	89 d0                	mov    %edx,%eax
 291:	c1 e0 02             	shl    $0x2,%eax
 294:	01 d0                	add    %edx,%eax
 296:	01 c0                	add    %eax,%eax
 298:	89 c1                	mov    %eax,%ecx
 29a:	8b 45 08             	mov    0x8(%ebp),%eax
 29d:	8d 50 01             	lea    0x1(%eax),%edx
 2a0:	89 55 08             	mov    %edx,0x8(%ebp)
 2a3:	0f b6 00             	movzbl (%eax),%eax
 2a6:	0f be c0             	movsbl %al,%eax
 2a9:	01 c8                	add    %ecx,%eax
 2ab:	83 e8 30             	sub    $0x30,%eax
 2ae:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2b1:	8b 45 08             	mov    0x8(%ebp),%eax
 2b4:	0f b6 00             	movzbl (%eax),%eax
 2b7:	3c 2f                	cmp    $0x2f,%al
 2b9:	7e 0a                	jle    2c5 <atoi+0x48>
 2bb:	8b 45 08             	mov    0x8(%ebp),%eax
 2be:	0f b6 00             	movzbl (%eax),%eax
 2c1:	3c 39                	cmp    $0x39,%al
 2c3:	7e c7                	jle    28c <atoi+0xf>
  return n;
 2c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2c8:	c9                   	leave  
 2c9:	c3                   	ret    

000002ca <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2ca:	55                   	push   %ebp
 2cb:	89 e5                	mov    %esp,%ebp
 2cd:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 2d0:	8b 45 08             	mov    0x8(%ebp),%eax
 2d3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2d6:	8b 45 0c             	mov    0xc(%ebp),%eax
 2d9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2dc:	eb 17                	jmp    2f5 <memmove+0x2b>
    *dst++ = *src++;
 2de:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2e1:	8d 42 01             	lea    0x1(%edx),%eax
 2e4:	89 45 f8             	mov    %eax,-0x8(%ebp)
 2e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2ea:	8d 48 01             	lea    0x1(%eax),%ecx
 2ed:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 2f0:	0f b6 12             	movzbl (%edx),%edx
 2f3:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 2f5:	8b 45 10             	mov    0x10(%ebp),%eax
 2f8:	8d 50 ff             	lea    -0x1(%eax),%edx
 2fb:	89 55 10             	mov    %edx,0x10(%ebp)
 2fe:	85 c0                	test   %eax,%eax
 300:	7f dc                	jg     2de <memmove+0x14>
  return vdst;
 302:	8b 45 08             	mov    0x8(%ebp),%eax
}
 305:	c9                   	leave  
 306:	c3                   	ret    

00000307 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 307:	b8 01 00 00 00       	mov    $0x1,%eax
 30c:	cd 40                	int    $0x40
 30e:	c3                   	ret    

0000030f <exit>:
SYSCALL(exit)
 30f:	b8 02 00 00 00       	mov    $0x2,%eax
 314:	cd 40                	int    $0x40
 316:	c3                   	ret    

00000317 <wait>:
SYSCALL(wait)
 317:	b8 03 00 00 00       	mov    $0x3,%eax
 31c:	cd 40                	int    $0x40
 31e:	c3                   	ret    

0000031f <pipe>:
SYSCALL(pipe)
 31f:	b8 04 00 00 00       	mov    $0x4,%eax
 324:	cd 40                	int    $0x40
 326:	c3                   	ret    

00000327 <read>:
SYSCALL(read)
 327:	b8 05 00 00 00       	mov    $0x5,%eax
 32c:	cd 40                	int    $0x40
 32e:	c3                   	ret    

0000032f <write>:
SYSCALL(write)
 32f:	b8 10 00 00 00       	mov    $0x10,%eax
 334:	cd 40                	int    $0x40
 336:	c3                   	ret    

00000337 <close>:
SYSCALL(close)
 337:	b8 15 00 00 00       	mov    $0x15,%eax
 33c:	cd 40                	int    $0x40
 33e:	c3                   	ret    

0000033f <kill>:
SYSCALL(kill)
 33f:	b8 06 00 00 00       	mov    $0x6,%eax
 344:	cd 40                	int    $0x40
 346:	c3                   	ret    

00000347 <exec>:
SYSCALL(exec)
 347:	b8 07 00 00 00       	mov    $0x7,%eax
 34c:	cd 40                	int    $0x40
 34e:	c3                   	ret    

0000034f <open>:
SYSCALL(open)
 34f:	b8 0f 00 00 00       	mov    $0xf,%eax
 354:	cd 40                	int    $0x40
 356:	c3                   	ret    

00000357 <mknod>:
SYSCALL(mknod)
 357:	b8 11 00 00 00       	mov    $0x11,%eax
 35c:	cd 40                	int    $0x40
 35e:	c3                   	ret    

0000035f <unlink>:
SYSCALL(unlink)
 35f:	b8 12 00 00 00       	mov    $0x12,%eax
 364:	cd 40                	int    $0x40
 366:	c3                   	ret    

00000367 <fstat>:
SYSCALL(fstat)
 367:	b8 08 00 00 00       	mov    $0x8,%eax
 36c:	cd 40                	int    $0x40
 36e:	c3                   	ret    

0000036f <link>:
SYSCALL(link)
 36f:	b8 13 00 00 00       	mov    $0x13,%eax
 374:	cd 40                	int    $0x40
 376:	c3                   	ret    

00000377 <mkdir>:
SYSCALL(mkdir)
 377:	b8 14 00 00 00       	mov    $0x14,%eax
 37c:	cd 40                	int    $0x40
 37e:	c3                   	ret    

0000037f <chdir>:
SYSCALL(chdir)
 37f:	b8 09 00 00 00       	mov    $0x9,%eax
 384:	cd 40                	int    $0x40
 386:	c3                   	ret    

00000387 <dup>:
SYSCALL(dup)
 387:	b8 0a 00 00 00       	mov    $0xa,%eax
 38c:	cd 40                	int    $0x40
 38e:	c3                   	ret    

0000038f <getpid>:
SYSCALL(getpid)
 38f:	b8 0b 00 00 00       	mov    $0xb,%eax
 394:	cd 40                	int    $0x40
 396:	c3                   	ret    

00000397 <sbrk>:
SYSCALL(sbrk)
 397:	b8 0c 00 00 00       	mov    $0xc,%eax
 39c:	cd 40                	int    $0x40
 39e:	c3                   	ret    

0000039f <sleep>:
SYSCALL(sleep)
 39f:	b8 0d 00 00 00       	mov    $0xd,%eax
 3a4:	cd 40                	int    $0x40
 3a6:	c3                   	ret    

000003a7 <uptime>:
SYSCALL(uptime)
 3a7:	b8 0e 00 00 00       	mov    $0xe,%eax
 3ac:	cd 40                	int    $0x40
 3ae:	c3                   	ret    

000003af <printpt>:
SYSCALL(printpt)
 3af:	b8 16 00 00 00       	mov    $0x16,%eax
 3b4:	cd 40                	int    $0x40
 3b6:	c3                   	ret    

000003b7 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3b7:	55                   	push   %ebp
 3b8:	89 e5                	mov    %esp,%ebp
 3ba:	83 ec 18             	sub    $0x18,%esp
 3bd:	8b 45 0c             	mov    0xc(%ebp),%eax
 3c0:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3c3:	83 ec 04             	sub    $0x4,%esp
 3c6:	6a 01                	push   $0x1
 3c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3cb:	50                   	push   %eax
 3cc:	ff 75 08             	push   0x8(%ebp)
 3cf:	e8 5b ff ff ff       	call   32f <write>
 3d4:	83 c4 10             	add    $0x10,%esp
}
 3d7:	90                   	nop
 3d8:	c9                   	leave  
 3d9:	c3                   	ret    

000003da <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3da:	55                   	push   %ebp
 3db:	89 e5                	mov    %esp,%ebp
 3dd:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3e0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3e7:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3eb:	74 17                	je     404 <printint+0x2a>
 3ed:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3f1:	79 11                	jns    404 <printint+0x2a>
    neg = 1;
 3f3:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3fa:	8b 45 0c             	mov    0xc(%ebp),%eax
 3fd:	f7 d8                	neg    %eax
 3ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
 402:	eb 06                	jmp    40a <printint+0x30>
  } else {
    x = xx;
 404:	8b 45 0c             	mov    0xc(%ebp),%eax
 407:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 40a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 411:	8b 4d 10             	mov    0x10(%ebp),%ecx
 414:	8b 45 ec             	mov    -0x14(%ebp),%eax
 417:	ba 00 00 00 00       	mov    $0x0,%edx
 41c:	f7 f1                	div    %ecx
 41e:	89 d1                	mov    %edx,%ecx
 420:	8b 45 f4             	mov    -0xc(%ebp),%eax
 423:	8d 50 01             	lea    0x1(%eax),%edx
 426:	89 55 f4             	mov    %edx,-0xc(%ebp)
 429:	0f b6 91 ec 0a 00 00 	movzbl 0xaec(%ecx),%edx
 430:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 434:	8b 4d 10             	mov    0x10(%ebp),%ecx
 437:	8b 45 ec             	mov    -0x14(%ebp),%eax
 43a:	ba 00 00 00 00       	mov    $0x0,%edx
 43f:	f7 f1                	div    %ecx
 441:	89 45 ec             	mov    %eax,-0x14(%ebp)
 444:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 448:	75 c7                	jne    411 <printint+0x37>
  if(neg)
 44a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 44e:	74 2d                	je     47d <printint+0xa3>
    buf[i++] = '-';
 450:	8b 45 f4             	mov    -0xc(%ebp),%eax
 453:	8d 50 01             	lea    0x1(%eax),%edx
 456:	89 55 f4             	mov    %edx,-0xc(%ebp)
 459:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 45e:	eb 1d                	jmp    47d <printint+0xa3>
    putc(fd, buf[i]);
 460:	8d 55 dc             	lea    -0x24(%ebp),%edx
 463:	8b 45 f4             	mov    -0xc(%ebp),%eax
 466:	01 d0                	add    %edx,%eax
 468:	0f b6 00             	movzbl (%eax),%eax
 46b:	0f be c0             	movsbl %al,%eax
 46e:	83 ec 08             	sub    $0x8,%esp
 471:	50                   	push   %eax
 472:	ff 75 08             	push   0x8(%ebp)
 475:	e8 3d ff ff ff       	call   3b7 <putc>
 47a:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 47d:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 481:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 485:	79 d9                	jns    460 <printint+0x86>
}
 487:	90                   	nop
 488:	90                   	nop
 489:	c9                   	leave  
 48a:	c3                   	ret    

0000048b <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 48b:	55                   	push   %ebp
 48c:	89 e5                	mov    %esp,%ebp
 48e:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 491:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 498:	8d 45 0c             	lea    0xc(%ebp),%eax
 49b:	83 c0 04             	add    $0x4,%eax
 49e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4a1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4a8:	e9 59 01 00 00       	jmp    606 <printf+0x17b>
    c = fmt[i] & 0xff;
 4ad:	8b 55 0c             	mov    0xc(%ebp),%edx
 4b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4b3:	01 d0                	add    %edx,%eax
 4b5:	0f b6 00             	movzbl (%eax),%eax
 4b8:	0f be c0             	movsbl %al,%eax
 4bb:	25 ff 00 00 00       	and    $0xff,%eax
 4c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4c3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4c7:	75 2c                	jne    4f5 <printf+0x6a>
      if(c == '%'){
 4c9:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4cd:	75 0c                	jne    4db <printf+0x50>
        state = '%';
 4cf:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4d6:	e9 27 01 00 00       	jmp    602 <printf+0x177>
      } else {
        putc(fd, c);
 4db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4de:	0f be c0             	movsbl %al,%eax
 4e1:	83 ec 08             	sub    $0x8,%esp
 4e4:	50                   	push   %eax
 4e5:	ff 75 08             	push   0x8(%ebp)
 4e8:	e8 ca fe ff ff       	call   3b7 <putc>
 4ed:	83 c4 10             	add    $0x10,%esp
 4f0:	e9 0d 01 00 00       	jmp    602 <printf+0x177>
      }
    } else if(state == '%'){
 4f5:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4f9:	0f 85 03 01 00 00    	jne    602 <printf+0x177>
      if(c == 'd'){
 4ff:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 503:	75 1e                	jne    523 <printf+0x98>
        printint(fd, *ap, 10, 1);
 505:	8b 45 e8             	mov    -0x18(%ebp),%eax
 508:	8b 00                	mov    (%eax),%eax
 50a:	6a 01                	push   $0x1
 50c:	6a 0a                	push   $0xa
 50e:	50                   	push   %eax
 50f:	ff 75 08             	push   0x8(%ebp)
 512:	e8 c3 fe ff ff       	call   3da <printint>
 517:	83 c4 10             	add    $0x10,%esp
        ap++;
 51a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 51e:	e9 d8 00 00 00       	jmp    5fb <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 523:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 527:	74 06                	je     52f <printf+0xa4>
 529:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 52d:	75 1e                	jne    54d <printf+0xc2>
        printint(fd, *ap, 16, 0);
 52f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 532:	8b 00                	mov    (%eax),%eax
 534:	6a 00                	push   $0x0
 536:	6a 10                	push   $0x10
 538:	50                   	push   %eax
 539:	ff 75 08             	push   0x8(%ebp)
 53c:	e8 99 fe ff ff       	call   3da <printint>
 541:	83 c4 10             	add    $0x10,%esp
        ap++;
 544:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 548:	e9 ae 00 00 00       	jmp    5fb <printf+0x170>
      } else if(c == 's'){
 54d:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 551:	75 43                	jne    596 <printf+0x10b>
        s = (char*)*ap;
 553:	8b 45 e8             	mov    -0x18(%ebp),%eax
 556:	8b 00                	mov    (%eax),%eax
 558:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 55b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 55f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 563:	75 25                	jne    58a <printf+0xff>
          s = "(null)";
 565:	c7 45 f4 80 08 00 00 	movl   $0x880,-0xc(%ebp)
        while(*s != 0){
 56c:	eb 1c                	jmp    58a <printf+0xff>
          putc(fd, *s);
 56e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 571:	0f b6 00             	movzbl (%eax),%eax
 574:	0f be c0             	movsbl %al,%eax
 577:	83 ec 08             	sub    $0x8,%esp
 57a:	50                   	push   %eax
 57b:	ff 75 08             	push   0x8(%ebp)
 57e:	e8 34 fe ff ff       	call   3b7 <putc>
 583:	83 c4 10             	add    $0x10,%esp
          s++;
 586:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 58a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 58d:	0f b6 00             	movzbl (%eax),%eax
 590:	84 c0                	test   %al,%al
 592:	75 da                	jne    56e <printf+0xe3>
 594:	eb 65                	jmp    5fb <printf+0x170>
        }
      } else if(c == 'c'){
 596:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 59a:	75 1d                	jne    5b9 <printf+0x12e>
        putc(fd, *ap);
 59c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 59f:	8b 00                	mov    (%eax),%eax
 5a1:	0f be c0             	movsbl %al,%eax
 5a4:	83 ec 08             	sub    $0x8,%esp
 5a7:	50                   	push   %eax
 5a8:	ff 75 08             	push   0x8(%ebp)
 5ab:	e8 07 fe ff ff       	call   3b7 <putc>
 5b0:	83 c4 10             	add    $0x10,%esp
        ap++;
 5b3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5b7:	eb 42                	jmp    5fb <printf+0x170>
      } else if(c == '%'){
 5b9:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5bd:	75 17                	jne    5d6 <printf+0x14b>
        putc(fd, c);
 5bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5c2:	0f be c0             	movsbl %al,%eax
 5c5:	83 ec 08             	sub    $0x8,%esp
 5c8:	50                   	push   %eax
 5c9:	ff 75 08             	push   0x8(%ebp)
 5cc:	e8 e6 fd ff ff       	call   3b7 <putc>
 5d1:	83 c4 10             	add    $0x10,%esp
 5d4:	eb 25                	jmp    5fb <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5d6:	83 ec 08             	sub    $0x8,%esp
 5d9:	6a 25                	push   $0x25
 5db:	ff 75 08             	push   0x8(%ebp)
 5de:	e8 d4 fd ff ff       	call   3b7 <putc>
 5e3:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 5e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5e9:	0f be c0             	movsbl %al,%eax
 5ec:	83 ec 08             	sub    $0x8,%esp
 5ef:	50                   	push   %eax
 5f0:	ff 75 08             	push   0x8(%ebp)
 5f3:	e8 bf fd ff ff       	call   3b7 <putc>
 5f8:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 5fb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 602:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 606:	8b 55 0c             	mov    0xc(%ebp),%edx
 609:	8b 45 f0             	mov    -0x10(%ebp),%eax
 60c:	01 d0                	add    %edx,%eax
 60e:	0f b6 00             	movzbl (%eax),%eax
 611:	84 c0                	test   %al,%al
 613:	0f 85 94 fe ff ff    	jne    4ad <printf+0x22>
    }
  }
}
 619:	90                   	nop
 61a:	90                   	nop
 61b:	c9                   	leave  
 61c:	c3                   	ret    

0000061d <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 61d:	55                   	push   %ebp
 61e:	89 e5                	mov    %esp,%ebp
 620:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 623:	8b 45 08             	mov    0x8(%ebp),%eax
 626:	83 e8 08             	sub    $0x8,%eax
 629:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 62c:	a1 08 0b 00 00       	mov    0xb08,%eax
 631:	89 45 fc             	mov    %eax,-0x4(%ebp)
 634:	eb 24                	jmp    65a <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 636:	8b 45 fc             	mov    -0x4(%ebp),%eax
 639:	8b 00                	mov    (%eax),%eax
 63b:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 63e:	72 12                	jb     652 <free+0x35>
 640:	8b 45 f8             	mov    -0x8(%ebp),%eax
 643:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 646:	77 24                	ja     66c <free+0x4f>
 648:	8b 45 fc             	mov    -0x4(%ebp),%eax
 64b:	8b 00                	mov    (%eax),%eax
 64d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 650:	72 1a                	jb     66c <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 652:	8b 45 fc             	mov    -0x4(%ebp),%eax
 655:	8b 00                	mov    (%eax),%eax
 657:	89 45 fc             	mov    %eax,-0x4(%ebp)
 65a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 65d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 660:	76 d4                	jbe    636 <free+0x19>
 662:	8b 45 fc             	mov    -0x4(%ebp),%eax
 665:	8b 00                	mov    (%eax),%eax
 667:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 66a:	73 ca                	jae    636 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 66c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 66f:	8b 40 04             	mov    0x4(%eax),%eax
 672:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 679:	8b 45 f8             	mov    -0x8(%ebp),%eax
 67c:	01 c2                	add    %eax,%edx
 67e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 681:	8b 00                	mov    (%eax),%eax
 683:	39 c2                	cmp    %eax,%edx
 685:	75 24                	jne    6ab <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 687:	8b 45 f8             	mov    -0x8(%ebp),%eax
 68a:	8b 50 04             	mov    0x4(%eax),%edx
 68d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 690:	8b 00                	mov    (%eax),%eax
 692:	8b 40 04             	mov    0x4(%eax),%eax
 695:	01 c2                	add    %eax,%edx
 697:	8b 45 f8             	mov    -0x8(%ebp),%eax
 69a:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 69d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a0:	8b 00                	mov    (%eax),%eax
 6a2:	8b 10                	mov    (%eax),%edx
 6a4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a7:	89 10                	mov    %edx,(%eax)
 6a9:	eb 0a                	jmp    6b5 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 6ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ae:	8b 10                	mov    (%eax),%edx
 6b0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b3:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b8:	8b 40 04             	mov    0x4(%eax),%eax
 6bb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c5:	01 d0                	add    %edx,%eax
 6c7:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6ca:	75 20                	jne    6ec <free+0xcf>
    p->s.size += bp->s.size;
 6cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6cf:	8b 50 04             	mov    0x4(%eax),%edx
 6d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d5:	8b 40 04             	mov    0x4(%eax),%eax
 6d8:	01 c2                	add    %eax,%edx
 6da:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6dd:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6e0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e3:	8b 10                	mov    (%eax),%edx
 6e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e8:	89 10                	mov    %edx,(%eax)
 6ea:	eb 08                	jmp    6f4 <free+0xd7>
  } else
    p->s.ptr = bp;
 6ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ef:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6f2:	89 10                	mov    %edx,(%eax)
  freep = p;
 6f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f7:	a3 08 0b 00 00       	mov    %eax,0xb08
}
 6fc:	90                   	nop
 6fd:	c9                   	leave  
 6fe:	c3                   	ret    

000006ff <morecore>:

static Header*
morecore(uint nu)
{
 6ff:	55                   	push   %ebp
 700:	89 e5                	mov    %esp,%ebp
 702:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 705:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 70c:	77 07                	ja     715 <morecore+0x16>
    nu = 4096;
 70e:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 715:	8b 45 08             	mov    0x8(%ebp),%eax
 718:	c1 e0 03             	shl    $0x3,%eax
 71b:	83 ec 0c             	sub    $0xc,%esp
 71e:	50                   	push   %eax
 71f:	e8 73 fc ff ff       	call   397 <sbrk>
 724:	83 c4 10             	add    $0x10,%esp
 727:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 72a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 72e:	75 07                	jne    737 <morecore+0x38>
    return 0;
 730:	b8 00 00 00 00       	mov    $0x0,%eax
 735:	eb 26                	jmp    75d <morecore+0x5e>
  hp = (Header*)p;
 737:	8b 45 f4             	mov    -0xc(%ebp),%eax
 73a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 73d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 740:	8b 55 08             	mov    0x8(%ebp),%edx
 743:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 746:	8b 45 f0             	mov    -0x10(%ebp),%eax
 749:	83 c0 08             	add    $0x8,%eax
 74c:	83 ec 0c             	sub    $0xc,%esp
 74f:	50                   	push   %eax
 750:	e8 c8 fe ff ff       	call   61d <free>
 755:	83 c4 10             	add    $0x10,%esp
  return freep;
 758:	a1 08 0b 00 00       	mov    0xb08,%eax
}
 75d:	c9                   	leave  
 75e:	c3                   	ret    

0000075f <malloc>:

void*
malloc(uint nbytes)
{
 75f:	55                   	push   %ebp
 760:	89 e5                	mov    %esp,%ebp
 762:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 765:	8b 45 08             	mov    0x8(%ebp),%eax
 768:	83 c0 07             	add    $0x7,%eax
 76b:	c1 e8 03             	shr    $0x3,%eax
 76e:	83 c0 01             	add    $0x1,%eax
 771:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 774:	a1 08 0b 00 00       	mov    0xb08,%eax
 779:	89 45 f0             	mov    %eax,-0x10(%ebp)
 77c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 780:	75 23                	jne    7a5 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 782:	c7 45 f0 00 0b 00 00 	movl   $0xb00,-0x10(%ebp)
 789:	8b 45 f0             	mov    -0x10(%ebp),%eax
 78c:	a3 08 0b 00 00       	mov    %eax,0xb08
 791:	a1 08 0b 00 00       	mov    0xb08,%eax
 796:	a3 00 0b 00 00       	mov    %eax,0xb00
    base.s.size = 0;
 79b:	c7 05 04 0b 00 00 00 	movl   $0x0,0xb04
 7a2:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a8:	8b 00                	mov    (%eax),%eax
 7aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b0:	8b 40 04             	mov    0x4(%eax),%eax
 7b3:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 7b6:	77 4d                	ja     805 <malloc+0xa6>
      if(p->s.size == nunits)
 7b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7bb:	8b 40 04             	mov    0x4(%eax),%eax
 7be:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 7c1:	75 0c                	jne    7cf <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c6:	8b 10                	mov    (%eax),%edx
 7c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7cb:	89 10                	mov    %edx,(%eax)
 7cd:	eb 26                	jmp    7f5 <malloc+0x96>
      else {
        p->s.size -= nunits;
 7cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d2:	8b 40 04             	mov    0x4(%eax),%eax
 7d5:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7d8:	89 c2                	mov    %eax,%edx
 7da:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7dd:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e3:	8b 40 04             	mov    0x4(%eax),%eax
 7e6:	c1 e0 03             	shl    $0x3,%eax
 7e9:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ef:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7f2:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7f8:	a3 08 0b 00 00       	mov    %eax,0xb08
      return (void*)(p + 1);
 7fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 800:	83 c0 08             	add    $0x8,%eax
 803:	eb 3b                	jmp    840 <malloc+0xe1>
    }
    if(p == freep)
 805:	a1 08 0b 00 00       	mov    0xb08,%eax
 80a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 80d:	75 1e                	jne    82d <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 80f:	83 ec 0c             	sub    $0xc,%esp
 812:	ff 75 ec             	push   -0x14(%ebp)
 815:	e8 e5 fe ff ff       	call   6ff <morecore>
 81a:	83 c4 10             	add    $0x10,%esp
 81d:	89 45 f4             	mov    %eax,-0xc(%ebp)
 820:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 824:	75 07                	jne    82d <malloc+0xce>
        return 0;
 826:	b8 00 00 00 00       	mov    $0x0,%eax
 82b:	eb 13                	jmp    840 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 82d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 830:	89 45 f0             	mov    %eax,-0x10(%ebp)
 833:	8b 45 f4             	mov    -0xc(%ebp),%eax
 836:	8b 00                	mov    (%eax),%eax
 838:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 83b:	e9 6d ff ff ff       	jmp    7ad <malloc+0x4e>
  }
}
 840:	c9                   	leave  
 841:	c3                   	ret    
