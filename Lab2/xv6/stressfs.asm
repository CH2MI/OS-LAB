
_stressfs:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "fs.h"
#include "fcntl.h"

int
main(int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	81 ec 24 02 00 00    	sub    $0x224,%esp
  int fd, i;
  char path[] = "stressfs0";
  14:	c7 45 e6 73 74 72 65 	movl   $0x65727473,-0x1a(%ebp)
  1b:	c7 45 ea 73 73 66 73 	movl   $0x73667373,-0x16(%ebp)
  22:	66 c7 45 ee 30 00    	movw   $0x30,-0x12(%ebp)
  char data[512];

  printf(1, "stressfs starting\n");
  28:	83 ec 08             	sub    $0x8,%esp
  2b:	68 e4 08 00 00       	push   $0x8e4
  30:	6a 01                	push   $0x1
  32:	e8 f6 04 00 00       	call   52d <printf>
  37:	83 c4 10             	add    $0x10,%esp
  memset(data, 'a', sizeof(data));
  3a:	83 ec 04             	sub    $0x4,%esp
  3d:	68 00 02 00 00       	push   $0x200
  42:	6a 61                	push   $0x61
  44:	8d 85 e6 fd ff ff    	lea    -0x21a(%ebp),%eax
  4a:	50                   	push   %eax
  4b:	e8 be 01 00 00       	call   20e <memset>
  50:	83 c4 10             	add    $0x10,%esp

  for(i = 0; i < 4; i++)
  53:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  5a:	eb 0d                	jmp    69 <main+0x69>
    if(fork() > 0)
  5c:	e8 40 03 00 00       	call   3a1 <fork>
  61:	85 c0                	test   %eax,%eax
  63:	7f 0c                	jg     71 <main+0x71>
  for(i = 0; i < 4; i++)
  65:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  69:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
  6d:	7e ed                	jle    5c <main+0x5c>
  6f:	eb 01                	jmp    72 <main+0x72>
      break;
  71:	90                   	nop

  printf(1, "write %d\n", i);
  72:	83 ec 04             	sub    $0x4,%esp
  75:	ff 75 f4             	push   -0xc(%ebp)
  78:	68 f7 08 00 00       	push   $0x8f7
  7d:	6a 01                	push   $0x1
  7f:	e8 a9 04 00 00       	call   52d <printf>
  84:	83 c4 10             	add    $0x10,%esp

  path[8] += i;
  87:	0f b6 45 ee          	movzbl -0x12(%ebp),%eax
  8b:	89 c2                	mov    %eax,%edx
  8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  90:	01 d0                	add    %edx,%eax
  92:	88 45 ee             	mov    %al,-0x12(%ebp)
  fd = open(path, O_CREATE | O_RDWR);
  95:	83 ec 08             	sub    $0x8,%esp
  98:	68 02 02 00 00       	push   $0x202
  9d:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  a0:	50                   	push   %eax
  a1:	e8 43 03 00 00       	call   3e9 <open>
  a6:	83 c4 10             	add    $0x10,%esp
  a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; i < 20; i++)
  ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  b3:	eb 1e                	jmp    d3 <main+0xd3>
//    printf(fd, "%d\n", i);
    write(fd, data, sizeof(data));
  b5:	83 ec 04             	sub    $0x4,%esp
  b8:	68 00 02 00 00       	push   $0x200
  bd:	8d 85 e6 fd ff ff    	lea    -0x21a(%ebp),%eax
  c3:	50                   	push   %eax
  c4:	ff 75 f0             	push   -0x10(%ebp)
  c7:	e8 fd 02 00 00       	call   3c9 <write>
  cc:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 20; i++)
  cf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  d3:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
  d7:	7e dc                	jle    b5 <main+0xb5>
  close(fd);
  d9:	83 ec 0c             	sub    $0xc,%esp
  dc:	ff 75 f0             	push   -0x10(%ebp)
  df:	e8 ed 02 00 00       	call   3d1 <close>
  e4:	83 c4 10             	add    $0x10,%esp

  printf(1, "read\n");
  e7:	83 ec 08             	sub    $0x8,%esp
  ea:	68 01 09 00 00       	push   $0x901
  ef:	6a 01                	push   $0x1
  f1:	e8 37 04 00 00       	call   52d <printf>
  f6:	83 c4 10             	add    $0x10,%esp

  fd = open(path, O_RDONLY);
  f9:	83 ec 08             	sub    $0x8,%esp
  fc:	6a 00                	push   $0x0
  fe:	8d 45 e6             	lea    -0x1a(%ebp),%eax
 101:	50                   	push   %eax
 102:	e8 e2 02 00 00       	call   3e9 <open>
 107:	83 c4 10             	add    $0x10,%esp
 10a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for (i = 0; i < 20; i++)
 10d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 114:	eb 1e                	jmp    134 <main+0x134>
    read(fd, data, sizeof(data));
 116:	83 ec 04             	sub    $0x4,%esp
 119:	68 00 02 00 00       	push   $0x200
 11e:	8d 85 e6 fd ff ff    	lea    -0x21a(%ebp),%eax
 124:	50                   	push   %eax
 125:	ff 75 f0             	push   -0x10(%ebp)
 128:	e8 94 02 00 00       	call   3c1 <read>
 12d:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 20; i++)
 130:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 134:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
 138:	7e dc                	jle    116 <main+0x116>
  close(fd);
 13a:	83 ec 0c             	sub    $0xc,%esp
 13d:	ff 75 f0             	push   -0x10(%ebp)
 140:	e8 8c 02 00 00       	call   3d1 <close>
 145:	83 c4 10             	add    $0x10,%esp

  wait();
 148:	e8 64 02 00 00       	call   3b1 <wait>

  exit();
 14d:	e8 57 02 00 00       	call   3a9 <exit>

00000152 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 152:	55                   	push   %ebp
 153:	89 e5                	mov    %esp,%ebp
 155:	57                   	push   %edi
 156:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 157:	8b 4d 08             	mov    0x8(%ebp),%ecx
 15a:	8b 55 10             	mov    0x10(%ebp),%edx
 15d:	8b 45 0c             	mov    0xc(%ebp),%eax
 160:	89 cb                	mov    %ecx,%ebx
 162:	89 df                	mov    %ebx,%edi
 164:	89 d1                	mov    %edx,%ecx
 166:	fc                   	cld    
 167:	f3 aa                	rep stos %al,%es:(%edi)
 169:	89 ca                	mov    %ecx,%edx
 16b:	89 fb                	mov    %edi,%ebx
 16d:	89 5d 08             	mov    %ebx,0x8(%ebp)
 170:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 173:	90                   	nop
 174:	5b                   	pop    %ebx
 175:	5f                   	pop    %edi
 176:	5d                   	pop    %ebp
 177:	c3                   	ret    

00000178 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 178:	55                   	push   %ebp
 179:	89 e5                	mov    %esp,%ebp
 17b:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 17e:	8b 45 08             	mov    0x8(%ebp),%eax
 181:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 184:	90                   	nop
 185:	8b 55 0c             	mov    0xc(%ebp),%edx
 188:	8d 42 01             	lea    0x1(%edx),%eax
 18b:	89 45 0c             	mov    %eax,0xc(%ebp)
 18e:	8b 45 08             	mov    0x8(%ebp),%eax
 191:	8d 48 01             	lea    0x1(%eax),%ecx
 194:	89 4d 08             	mov    %ecx,0x8(%ebp)
 197:	0f b6 12             	movzbl (%edx),%edx
 19a:	88 10                	mov    %dl,(%eax)
 19c:	0f b6 00             	movzbl (%eax),%eax
 19f:	84 c0                	test   %al,%al
 1a1:	75 e2                	jne    185 <strcpy+0xd>
    ;
  return os;
 1a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1a6:	c9                   	leave  
 1a7:	c3                   	ret    

000001a8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1a8:	55                   	push   %ebp
 1a9:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 1ab:	eb 08                	jmp    1b5 <strcmp+0xd>
    p++, q++;
 1ad:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1b1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 1b5:	8b 45 08             	mov    0x8(%ebp),%eax
 1b8:	0f b6 00             	movzbl (%eax),%eax
 1bb:	84 c0                	test   %al,%al
 1bd:	74 10                	je     1cf <strcmp+0x27>
 1bf:	8b 45 08             	mov    0x8(%ebp),%eax
 1c2:	0f b6 10             	movzbl (%eax),%edx
 1c5:	8b 45 0c             	mov    0xc(%ebp),%eax
 1c8:	0f b6 00             	movzbl (%eax),%eax
 1cb:	38 c2                	cmp    %al,%dl
 1cd:	74 de                	je     1ad <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 1cf:	8b 45 08             	mov    0x8(%ebp),%eax
 1d2:	0f b6 00             	movzbl (%eax),%eax
 1d5:	0f b6 d0             	movzbl %al,%edx
 1d8:	8b 45 0c             	mov    0xc(%ebp),%eax
 1db:	0f b6 00             	movzbl (%eax),%eax
 1de:	0f b6 c8             	movzbl %al,%ecx
 1e1:	89 d0                	mov    %edx,%eax
 1e3:	29 c8                	sub    %ecx,%eax
}
 1e5:	5d                   	pop    %ebp
 1e6:	c3                   	ret    

000001e7 <strlen>:

uint
strlen(char *s)
{
 1e7:	55                   	push   %ebp
 1e8:	89 e5                	mov    %esp,%ebp
 1ea:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1ed:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1f4:	eb 04                	jmp    1fa <strlen+0x13>
 1f6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1fa:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1fd:	8b 45 08             	mov    0x8(%ebp),%eax
 200:	01 d0                	add    %edx,%eax
 202:	0f b6 00             	movzbl (%eax),%eax
 205:	84 c0                	test   %al,%al
 207:	75 ed                	jne    1f6 <strlen+0xf>
    ;
  return n;
 209:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 20c:	c9                   	leave  
 20d:	c3                   	ret    

0000020e <memset>:

void*
memset(void *dst, int c, uint n)
{
 20e:	55                   	push   %ebp
 20f:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 211:	8b 45 10             	mov    0x10(%ebp),%eax
 214:	50                   	push   %eax
 215:	ff 75 0c             	push   0xc(%ebp)
 218:	ff 75 08             	push   0x8(%ebp)
 21b:	e8 32 ff ff ff       	call   152 <stosb>
 220:	83 c4 0c             	add    $0xc,%esp
  return dst;
 223:	8b 45 08             	mov    0x8(%ebp),%eax
}
 226:	c9                   	leave  
 227:	c3                   	ret    

00000228 <strchr>:

char*
strchr(const char *s, char c)
{
 228:	55                   	push   %ebp
 229:	89 e5                	mov    %esp,%ebp
 22b:	83 ec 04             	sub    $0x4,%esp
 22e:	8b 45 0c             	mov    0xc(%ebp),%eax
 231:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 234:	eb 14                	jmp    24a <strchr+0x22>
    if(*s == c)
 236:	8b 45 08             	mov    0x8(%ebp),%eax
 239:	0f b6 00             	movzbl (%eax),%eax
 23c:	38 45 fc             	cmp    %al,-0x4(%ebp)
 23f:	75 05                	jne    246 <strchr+0x1e>
      return (char*)s;
 241:	8b 45 08             	mov    0x8(%ebp),%eax
 244:	eb 13                	jmp    259 <strchr+0x31>
  for(; *s; s++)
 246:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 24a:	8b 45 08             	mov    0x8(%ebp),%eax
 24d:	0f b6 00             	movzbl (%eax),%eax
 250:	84 c0                	test   %al,%al
 252:	75 e2                	jne    236 <strchr+0xe>
  return 0;
 254:	b8 00 00 00 00       	mov    $0x0,%eax
}
 259:	c9                   	leave  
 25a:	c3                   	ret    

0000025b <gets>:

char*
gets(char *buf, int max)
{
 25b:	55                   	push   %ebp
 25c:	89 e5                	mov    %esp,%ebp
 25e:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 261:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 268:	eb 42                	jmp    2ac <gets+0x51>
    cc = read(0, &c, 1);
 26a:	83 ec 04             	sub    $0x4,%esp
 26d:	6a 01                	push   $0x1
 26f:	8d 45 ef             	lea    -0x11(%ebp),%eax
 272:	50                   	push   %eax
 273:	6a 00                	push   $0x0
 275:	e8 47 01 00 00       	call   3c1 <read>
 27a:	83 c4 10             	add    $0x10,%esp
 27d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 280:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 284:	7e 33                	jle    2b9 <gets+0x5e>
      break;
    buf[i++] = c;
 286:	8b 45 f4             	mov    -0xc(%ebp),%eax
 289:	8d 50 01             	lea    0x1(%eax),%edx
 28c:	89 55 f4             	mov    %edx,-0xc(%ebp)
 28f:	89 c2                	mov    %eax,%edx
 291:	8b 45 08             	mov    0x8(%ebp),%eax
 294:	01 c2                	add    %eax,%edx
 296:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 29a:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 29c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2a0:	3c 0a                	cmp    $0xa,%al
 2a2:	74 16                	je     2ba <gets+0x5f>
 2a4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2a8:	3c 0d                	cmp    $0xd,%al
 2aa:	74 0e                	je     2ba <gets+0x5f>
  for(i=0; i+1 < max; ){
 2ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2af:	83 c0 01             	add    $0x1,%eax
 2b2:	39 45 0c             	cmp    %eax,0xc(%ebp)
 2b5:	7f b3                	jg     26a <gets+0xf>
 2b7:	eb 01                	jmp    2ba <gets+0x5f>
      break;
 2b9:	90                   	nop
      break;
  }
  buf[i] = '\0';
 2ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
 2bd:	8b 45 08             	mov    0x8(%ebp),%eax
 2c0:	01 d0                	add    %edx,%eax
 2c2:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2c5:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2c8:	c9                   	leave  
 2c9:	c3                   	ret    

000002ca <stat>:

int
stat(char *n, struct stat *st)
{
 2ca:	55                   	push   %ebp
 2cb:	89 e5                	mov    %esp,%ebp
 2cd:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2d0:	83 ec 08             	sub    $0x8,%esp
 2d3:	6a 00                	push   $0x0
 2d5:	ff 75 08             	push   0x8(%ebp)
 2d8:	e8 0c 01 00 00       	call   3e9 <open>
 2dd:	83 c4 10             	add    $0x10,%esp
 2e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2e7:	79 07                	jns    2f0 <stat+0x26>
    return -1;
 2e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2ee:	eb 25                	jmp    315 <stat+0x4b>
  r = fstat(fd, st);
 2f0:	83 ec 08             	sub    $0x8,%esp
 2f3:	ff 75 0c             	push   0xc(%ebp)
 2f6:	ff 75 f4             	push   -0xc(%ebp)
 2f9:	e8 03 01 00 00       	call   401 <fstat>
 2fe:	83 c4 10             	add    $0x10,%esp
 301:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 304:	83 ec 0c             	sub    $0xc,%esp
 307:	ff 75 f4             	push   -0xc(%ebp)
 30a:	e8 c2 00 00 00       	call   3d1 <close>
 30f:	83 c4 10             	add    $0x10,%esp
  return r;
 312:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 315:	c9                   	leave  
 316:	c3                   	ret    

00000317 <atoi>:

int
atoi(const char *s)
{
 317:	55                   	push   %ebp
 318:	89 e5                	mov    %esp,%ebp
 31a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 31d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 324:	eb 25                	jmp    34b <atoi+0x34>
    n = n*10 + *s++ - '0';
 326:	8b 55 fc             	mov    -0x4(%ebp),%edx
 329:	89 d0                	mov    %edx,%eax
 32b:	c1 e0 02             	shl    $0x2,%eax
 32e:	01 d0                	add    %edx,%eax
 330:	01 c0                	add    %eax,%eax
 332:	89 c1                	mov    %eax,%ecx
 334:	8b 45 08             	mov    0x8(%ebp),%eax
 337:	8d 50 01             	lea    0x1(%eax),%edx
 33a:	89 55 08             	mov    %edx,0x8(%ebp)
 33d:	0f b6 00             	movzbl (%eax),%eax
 340:	0f be c0             	movsbl %al,%eax
 343:	01 c8                	add    %ecx,%eax
 345:	83 e8 30             	sub    $0x30,%eax
 348:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 34b:	8b 45 08             	mov    0x8(%ebp),%eax
 34e:	0f b6 00             	movzbl (%eax),%eax
 351:	3c 2f                	cmp    $0x2f,%al
 353:	7e 0a                	jle    35f <atoi+0x48>
 355:	8b 45 08             	mov    0x8(%ebp),%eax
 358:	0f b6 00             	movzbl (%eax),%eax
 35b:	3c 39                	cmp    $0x39,%al
 35d:	7e c7                	jle    326 <atoi+0xf>
  return n;
 35f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 362:	c9                   	leave  
 363:	c3                   	ret    

00000364 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 364:	55                   	push   %ebp
 365:	89 e5                	mov    %esp,%ebp
 367:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 36a:	8b 45 08             	mov    0x8(%ebp),%eax
 36d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 370:	8b 45 0c             	mov    0xc(%ebp),%eax
 373:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 376:	eb 17                	jmp    38f <memmove+0x2b>
    *dst++ = *src++;
 378:	8b 55 f8             	mov    -0x8(%ebp),%edx
 37b:	8d 42 01             	lea    0x1(%edx),%eax
 37e:	89 45 f8             	mov    %eax,-0x8(%ebp)
 381:	8b 45 fc             	mov    -0x4(%ebp),%eax
 384:	8d 48 01             	lea    0x1(%eax),%ecx
 387:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 38a:	0f b6 12             	movzbl (%edx),%edx
 38d:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 38f:	8b 45 10             	mov    0x10(%ebp),%eax
 392:	8d 50 ff             	lea    -0x1(%eax),%edx
 395:	89 55 10             	mov    %edx,0x10(%ebp)
 398:	85 c0                	test   %eax,%eax
 39a:	7f dc                	jg     378 <memmove+0x14>
  return vdst;
 39c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 39f:	c9                   	leave  
 3a0:	c3                   	ret    

000003a1 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 3a1:	b8 01 00 00 00       	mov    $0x1,%eax
 3a6:	cd 40                	int    $0x40
 3a8:	c3                   	ret    

000003a9 <exit>:
SYSCALL(exit)
 3a9:	b8 02 00 00 00       	mov    $0x2,%eax
 3ae:	cd 40                	int    $0x40
 3b0:	c3                   	ret    

000003b1 <wait>:
SYSCALL(wait)
 3b1:	b8 03 00 00 00       	mov    $0x3,%eax
 3b6:	cd 40                	int    $0x40
 3b8:	c3                   	ret    

000003b9 <pipe>:
SYSCALL(pipe)
 3b9:	b8 04 00 00 00       	mov    $0x4,%eax
 3be:	cd 40                	int    $0x40
 3c0:	c3                   	ret    

000003c1 <read>:
SYSCALL(read)
 3c1:	b8 05 00 00 00       	mov    $0x5,%eax
 3c6:	cd 40                	int    $0x40
 3c8:	c3                   	ret    

000003c9 <write>:
SYSCALL(write)
 3c9:	b8 10 00 00 00       	mov    $0x10,%eax
 3ce:	cd 40                	int    $0x40
 3d0:	c3                   	ret    

000003d1 <close>:
SYSCALL(close)
 3d1:	b8 15 00 00 00       	mov    $0x15,%eax
 3d6:	cd 40                	int    $0x40
 3d8:	c3                   	ret    

000003d9 <kill>:
SYSCALL(kill)
 3d9:	b8 06 00 00 00       	mov    $0x6,%eax
 3de:	cd 40                	int    $0x40
 3e0:	c3                   	ret    

000003e1 <exec>:
SYSCALL(exec)
 3e1:	b8 07 00 00 00       	mov    $0x7,%eax
 3e6:	cd 40                	int    $0x40
 3e8:	c3                   	ret    

000003e9 <open>:
SYSCALL(open)
 3e9:	b8 0f 00 00 00       	mov    $0xf,%eax
 3ee:	cd 40                	int    $0x40
 3f0:	c3                   	ret    

000003f1 <mknod>:
SYSCALL(mknod)
 3f1:	b8 11 00 00 00       	mov    $0x11,%eax
 3f6:	cd 40                	int    $0x40
 3f8:	c3                   	ret    

000003f9 <unlink>:
SYSCALL(unlink)
 3f9:	b8 12 00 00 00       	mov    $0x12,%eax
 3fe:	cd 40                	int    $0x40
 400:	c3                   	ret    

00000401 <fstat>:
SYSCALL(fstat)
 401:	b8 08 00 00 00       	mov    $0x8,%eax
 406:	cd 40                	int    $0x40
 408:	c3                   	ret    

00000409 <link>:
SYSCALL(link)
 409:	b8 13 00 00 00       	mov    $0x13,%eax
 40e:	cd 40                	int    $0x40
 410:	c3                   	ret    

00000411 <mkdir>:
SYSCALL(mkdir)
 411:	b8 14 00 00 00       	mov    $0x14,%eax
 416:	cd 40                	int    $0x40
 418:	c3                   	ret    

00000419 <chdir>:
SYSCALL(chdir)
 419:	b8 09 00 00 00       	mov    $0x9,%eax
 41e:	cd 40                	int    $0x40
 420:	c3                   	ret    

00000421 <dup>:
SYSCALL(dup)
 421:	b8 0a 00 00 00       	mov    $0xa,%eax
 426:	cd 40                	int    $0x40
 428:	c3                   	ret    

00000429 <getpid>:
SYSCALL(getpid)
 429:	b8 0b 00 00 00       	mov    $0xb,%eax
 42e:	cd 40                	int    $0x40
 430:	c3                   	ret    

00000431 <sbrk>:
SYSCALL(sbrk)
 431:	b8 0c 00 00 00       	mov    $0xc,%eax
 436:	cd 40                	int    $0x40
 438:	c3                   	ret    

00000439 <sleep>:
SYSCALL(sleep)
 439:	b8 0d 00 00 00       	mov    $0xd,%eax
 43e:	cd 40                	int    $0x40
 440:	c3                   	ret    

00000441 <uptime>:
SYSCALL(uptime)
 441:	b8 0e 00 00 00       	mov    $0xe,%eax
 446:	cd 40                	int    $0x40
 448:	c3                   	ret    

00000449 <exit2>:
SYSCALL(exit2)
 449:	b8 16 00 00 00       	mov    $0x16,%eax
 44e:	cd 40                	int    $0x40
 450:	c3                   	ret    

00000451 <wait2>:
SYSCALL(wait2)
 451:	b8 17 00 00 00       	mov    $0x17,%eax
 456:	cd 40                	int    $0x40
 458:	c3                   	ret    

00000459 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 459:	55                   	push   %ebp
 45a:	89 e5                	mov    %esp,%ebp
 45c:	83 ec 18             	sub    $0x18,%esp
 45f:	8b 45 0c             	mov    0xc(%ebp),%eax
 462:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 465:	83 ec 04             	sub    $0x4,%esp
 468:	6a 01                	push   $0x1
 46a:	8d 45 f4             	lea    -0xc(%ebp),%eax
 46d:	50                   	push   %eax
 46e:	ff 75 08             	push   0x8(%ebp)
 471:	e8 53 ff ff ff       	call   3c9 <write>
 476:	83 c4 10             	add    $0x10,%esp
}
 479:	90                   	nop
 47a:	c9                   	leave  
 47b:	c3                   	ret    

0000047c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 47c:	55                   	push   %ebp
 47d:	89 e5                	mov    %esp,%ebp
 47f:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 482:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 489:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 48d:	74 17                	je     4a6 <printint+0x2a>
 48f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 493:	79 11                	jns    4a6 <printint+0x2a>
    neg = 1;
 495:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 49c:	8b 45 0c             	mov    0xc(%ebp),%eax
 49f:	f7 d8                	neg    %eax
 4a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4a4:	eb 06                	jmp    4ac <printint+0x30>
  } else {
    x = xx;
 4a6:	8b 45 0c             	mov    0xc(%ebp),%eax
 4a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4b3:	8b 4d 10             	mov    0x10(%ebp),%ecx
 4b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4b9:	ba 00 00 00 00       	mov    $0x0,%edx
 4be:	f7 f1                	div    %ecx
 4c0:	89 d1                	mov    %edx,%ecx
 4c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4c5:	8d 50 01             	lea    0x1(%eax),%edx
 4c8:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4cb:	0f b6 91 54 0b 00 00 	movzbl 0xb54(%ecx),%edx
 4d2:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 4d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
 4d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4dc:	ba 00 00 00 00       	mov    $0x0,%edx
 4e1:	f7 f1                	div    %ecx
 4e3:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4e6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4ea:	75 c7                	jne    4b3 <printint+0x37>
  if(neg)
 4ec:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4f0:	74 2d                	je     51f <printint+0xa3>
    buf[i++] = '-';
 4f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4f5:	8d 50 01             	lea    0x1(%eax),%edx
 4f8:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4fb:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 500:	eb 1d                	jmp    51f <printint+0xa3>
    putc(fd, buf[i]);
 502:	8d 55 dc             	lea    -0x24(%ebp),%edx
 505:	8b 45 f4             	mov    -0xc(%ebp),%eax
 508:	01 d0                	add    %edx,%eax
 50a:	0f b6 00             	movzbl (%eax),%eax
 50d:	0f be c0             	movsbl %al,%eax
 510:	83 ec 08             	sub    $0x8,%esp
 513:	50                   	push   %eax
 514:	ff 75 08             	push   0x8(%ebp)
 517:	e8 3d ff ff ff       	call   459 <putc>
 51c:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 51f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 523:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 527:	79 d9                	jns    502 <printint+0x86>
}
 529:	90                   	nop
 52a:	90                   	nop
 52b:	c9                   	leave  
 52c:	c3                   	ret    

0000052d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 52d:	55                   	push   %ebp
 52e:	89 e5                	mov    %esp,%ebp
 530:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 533:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 53a:	8d 45 0c             	lea    0xc(%ebp),%eax
 53d:	83 c0 04             	add    $0x4,%eax
 540:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 543:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 54a:	e9 59 01 00 00       	jmp    6a8 <printf+0x17b>
    c = fmt[i] & 0xff;
 54f:	8b 55 0c             	mov    0xc(%ebp),%edx
 552:	8b 45 f0             	mov    -0x10(%ebp),%eax
 555:	01 d0                	add    %edx,%eax
 557:	0f b6 00             	movzbl (%eax),%eax
 55a:	0f be c0             	movsbl %al,%eax
 55d:	25 ff 00 00 00       	and    $0xff,%eax
 562:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 565:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 569:	75 2c                	jne    597 <printf+0x6a>
      if(c == '%'){
 56b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 56f:	75 0c                	jne    57d <printf+0x50>
        state = '%';
 571:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 578:	e9 27 01 00 00       	jmp    6a4 <printf+0x177>
      } else {
        putc(fd, c);
 57d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 580:	0f be c0             	movsbl %al,%eax
 583:	83 ec 08             	sub    $0x8,%esp
 586:	50                   	push   %eax
 587:	ff 75 08             	push   0x8(%ebp)
 58a:	e8 ca fe ff ff       	call   459 <putc>
 58f:	83 c4 10             	add    $0x10,%esp
 592:	e9 0d 01 00 00       	jmp    6a4 <printf+0x177>
      }
    } else if(state == '%'){
 597:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 59b:	0f 85 03 01 00 00    	jne    6a4 <printf+0x177>
      if(c == 'd'){
 5a1:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5a5:	75 1e                	jne    5c5 <printf+0x98>
        printint(fd, *ap, 10, 1);
 5a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5aa:	8b 00                	mov    (%eax),%eax
 5ac:	6a 01                	push   $0x1
 5ae:	6a 0a                	push   $0xa
 5b0:	50                   	push   %eax
 5b1:	ff 75 08             	push   0x8(%ebp)
 5b4:	e8 c3 fe ff ff       	call   47c <printint>
 5b9:	83 c4 10             	add    $0x10,%esp
        ap++;
 5bc:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5c0:	e9 d8 00 00 00       	jmp    69d <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 5c5:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5c9:	74 06                	je     5d1 <printf+0xa4>
 5cb:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5cf:	75 1e                	jne    5ef <printf+0xc2>
        printint(fd, *ap, 16, 0);
 5d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5d4:	8b 00                	mov    (%eax),%eax
 5d6:	6a 00                	push   $0x0
 5d8:	6a 10                	push   $0x10
 5da:	50                   	push   %eax
 5db:	ff 75 08             	push   0x8(%ebp)
 5de:	e8 99 fe ff ff       	call   47c <printint>
 5e3:	83 c4 10             	add    $0x10,%esp
        ap++;
 5e6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5ea:	e9 ae 00 00 00       	jmp    69d <printf+0x170>
      } else if(c == 's'){
 5ef:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5f3:	75 43                	jne    638 <printf+0x10b>
        s = (char*)*ap;
 5f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5f8:	8b 00                	mov    (%eax),%eax
 5fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5fd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 601:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 605:	75 25                	jne    62c <printf+0xff>
          s = "(null)";
 607:	c7 45 f4 07 09 00 00 	movl   $0x907,-0xc(%ebp)
        while(*s != 0){
 60e:	eb 1c                	jmp    62c <printf+0xff>
          putc(fd, *s);
 610:	8b 45 f4             	mov    -0xc(%ebp),%eax
 613:	0f b6 00             	movzbl (%eax),%eax
 616:	0f be c0             	movsbl %al,%eax
 619:	83 ec 08             	sub    $0x8,%esp
 61c:	50                   	push   %eax
 61d:	ff 75 08             	push   0x8(%ebp)
 620:	e8 34 fe ff ff       	call   459 <putc>
 625:	83 c4 10             	add    $0x10,%esp
          s++;
 628:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 62c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 62f:	0f b6 00             	movzbl (%eax),%eax
 632:	84 c0                	test   %al,%al
 634:	75 da                	jne    610 <printf+0xe3>
 636:	eb 65                	jmp    69d <printf+0x170>
        }
      } else if(c == 'c'){
 638:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 63c:	75 1d                	jne    65b <printf+0x12e>
        putc(fd, *ap);
 63e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 641:	8b 00                	mov    (%eax),%eax
 643:	0f be c0             	movsbl %al,%eax
 646:	83 ec 08             	sub    $0x8,%esp
 649:	50                   	push   %eax
 64a:	ff 75 08             	push   0x8(%ebp)
 64d:	e8 07 fe ff ff       	call   459 <putc>
 652:	83 c4 10             	add    $0x10,%esp
        ap++;
 655:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 659:	eb 42                	jmp    69d <printf+0x170>
      } else if(c == '%'){
 65b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 65f:	75 17                	jne    678 <printf+0x14b>
        putc(fd, c);
 661:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 664:	0f be c0             	movsbl %al,%eax
 667:	83 ec 08             	sub    $0x8,%esp
 66a:	50                   	push   %eax
 66b:	ff 75 08             	push   0x8(%ebp)
 66e:	e8 e6 fd ff ff       	call   459 <putc>
 673:	83 c4 10             	add    $0x10,%esp
 676:	eb 25                	jmp    69d <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 678:	83 ec 08             	sub    $0x8,%esp
 67b:	6a 25                	push   $0x25
 67d:	ff 75 08             	push   0x8(%ebp)
 680:	e8 d4 fd ff ff       	call   459 <putc>
 685:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 688:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 68b:	0f be c0             	movsbl %al,%eax
 68e:	83 ec 08             	sub    $0x8,%esp
 691:	50                   	push   %eax
 692:	ff 75 08             	push   0x8(%ebp)
 695:	e8 bf fd ff ff       	call   459 <putc>
 69a:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 69d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 6a4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6a8:	8b 55 0c             	mov    0xc(%ebp),%edx
 6ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6ae:	01 d0                	add    %edx,%eax
 6b0:	0f b6 00             	movzbl (%eax),%eax
 6b3:	84 c0                	test   %al,%al
 6b5:	0f 85 94 fe ff ff    	jne    54f <printf+0x22>
    }
  }
}
 6bb:	90                   	nop
 6bc:	90                   	nop
 6bd:	c9                   	leave  
 6be:	c3                   	ret    

000006bf <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6bf:	55                   	push   %ebp
 6c0:	89 e5                	mov    %esp,%ebp
 6c2:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6c5:	8b 45 08             	mov    0x8(%ebp),%eax
 6c8:	83 e8 08             	sub    $0x8,%eax
 6cb:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6ce:	a1 70 0b 00 00       	mov    0xb70,%eax
 6d3:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6d6:	eb 24                	jmp    6fc <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6db:	8b 00                	mov    (%eax),%eax
 6dd:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 6e0:	72 12                	jb     6f4 <free+0x35>
 6e2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e5:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6e8:	77 24                	ja     70e <free+0x4f>
 6ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ed:	8b 00                	mov    (%eax),%eax
 6ef:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6f2:	72 1a                	jb     70e <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f7:	8b 00                	mov    (%eax),%eax
 6f9:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6fc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ff:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 702:	76 d4                	jbe    6d8 <free+0x19>
 704:	8b 45 fc             	mov    -0x4(%ebp),%eax
 707:	8b 00                	mov    (%eax),%eax
 709:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 70c:	73 ca                	jae    6d8 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 70e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 711:	8b 40 04             	mov    0x4(%eax),%eax
 714:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 71b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 71e:	01 c2                	add    %eax,%edx
 720:	8b 45 fc             	mov    -0x4(%ebp),%eax
 723:	8b 00                	mov    (%eax),%eax
 725:	39 c2                	cmp    %eax,%edx
 727:	75 24                	jne    74d <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 729:	8b 45 f8             	mov    -0x8(%ebp),%eax
 72c:	8b 50 04             	mov    0x4(%eax),%edx
 72f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 732:	8b 00                	mov    (%eax),%eax
 734:	8b 40 04             	mov    0x4(%eax),%eax
 737:	01 c2                	add    %eax,%edx
 739:	8b 45 f8             	mov    -0x8(%ebp),%eax
 73c:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 73f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 742:	8b 00                	mov    (%eax),%eax
 744:	8b 10                	mov    (%eax),%edx
 746:	8b 45 f8             	mov    -0x8(%ebp),%eax
 749:	89 10                	mov    %edx,(%eax)
 74b:	eb 0a                	jmp    757 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 74d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 750:	8b 10                	mov    (%eax),%edx
 752:	8b 45 f8             	mov    -0x8(%ebp),%eax
 755:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 757:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75a:	8b 40 04             	mov    0x4(%eax),%eax
 75d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 764:	8b 45 fc             	mov    -0x4(%ebp),%eax
 767:	01 d0                	add    %edx,%eax
 769:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 76c:	75 20                	jne    78e <free+0xcf>
    p->s.size += bp->s.size;
 76e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 771:	8b 50 04             	mov    0x4(%eax),%edx
 774:	8b 45 f8             	mov    -0x8(%ebp),%eax
 777:	8b 40 04             	mov    0x4(%eax),%eax
 77a:	01 c2                	add    %eax,%edx
 77c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77f:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 782:	8b 45 f8             	mov    -0x8(%ebp),%eax
 785:	8b 10                	mov    (%eax),%edx
 787:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78a:	89 10                	mov    %edx,(%eax)
 78c:	eb 08                	jmp    796 <free+0xd7>
  } else
    p->s.ptr = bp;
 78e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 791:	8b 55 f8             	mov    -0x8(%ebp),%edx
 794:	89 10                	mov    %edx,(%eax)
  freep = p;
 796:	8b 45 fc             	mov    -0x4(%ebp),%eax
 799:	a3 70 0b 00 00       	mov    %eax,0xb70
}
 79e:	90                   	nop
 79f:	c9                   	leave  
 7a0:	c3                   	ret    

000007a1 <morecore>:

static Header*
morecore(uint nu)
{
 7a1:	55                   	push   %ebp
 7a2:	89 e5                	mov    %esp,%ebp
 7a4:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7a7:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7ae:	77 07                	ja     7b7 <morecore+0x16>
    nu = 4096;
 7b0:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7b7:	8b 45 08             	mov    0x8(%ebp),%eax
 7ba:	c1 e0 03             	shl    $0x3,%eax
 7bd:	83 ec 0c             	sub    $0xc,%esp
 7c0:	50                   	push   %eax
 7c1:	e8 6b fc ff ff       	call   431 <sbrk>
 7c6:	83 c4 10             	add    $0x10,%esp
 7c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7cc:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7d0:	75 07                	jne    7d9 <morecore+0x38>
    return 0;
 7d2:	b8 00 00 00 00       	mov    $0x0,%eax
 7d7:	eb 26                	jmp    7ff <morecore+0x5e>
  hp = (Header*)p;
 7d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7df:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e2:	8b 55 08             	mov    0x8(%ebp),%edx
 7e5:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7eb:	83 c0 08             	add    $0x8,%eax
 7ee:	83 ec 0c             	sub    $0xc,%esp
 7f1:	50                   	push   %eax
 7f2:	e8 c8 fe ff ff       	call   6bf <free>
 7f7:	83 c4 10             	add    $0x10,%esp
  return freep;
 7fa:	a1 70 0b 00 00       	mov    0xb70,%eax
}
 7ff:	c9                   	leave  
 800:	c3                   	ret    

00000801 <malloc>:

void*
malloc(uint nbytes)
{
 801:	55                   	push   %ebp
 802:	89 e5                	mov    %esp,%ebp
 804:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 807:	8b 45 08             	mov    0x8(%ebp),%eax
 80a:	83 c0 07             	add    $0x7,%eax
 80d:	c1 e8 03             	shr    $0x3,%eax
 810:	83 c0 01             	add    $0x1,%eax
 813:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 816:	a1 70 0b 00 00       	mov    0xb70,%eax
 81b:	89 45 f0             	mov    %eax,-0x10(%ebp)
 81e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 822:	75 23                	jne    847 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 824:	c7 45 f0 68 0b 00 00 	movl   $0xb68,-0x10(%ebp)
 82b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 82e:	a3 70 0b 00 00       	mov    %eax,0xb70
 833:	a1 70 0b 00 00       	mov    0xb70,%eax
 838:	a3 68 0b 00 00       	mov    %eax,0xb68
    base.s.size = 0;
 83d:	c7 05 6c 0b 00 00 00 	movl   $0x0,0xb6c
 844:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 847:	8b 45 f0             	mov    -0x10(%ebp),%eax
 84a:	8b 00                	mov    (%eax),%eax
 84c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 84f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 852:	8b 40 04             	mov    0x4(%eax),%eax
 855:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 858:	77 4d                	ja     8a7 <malloc+0xa6>
      if(p->s.size == nunits)
 85a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85d:	8b 40 04             	mov    0x4(%eax),%eax
 860:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 863:	75 0c                	jne    871 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 865:	8b 45 f4             	mov    -0xc(%ebp),%eax
 868:	8b 10                	mov    (%eax),%edx
 86a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 86d:	89 10                	mov    %edx,(%eax)
 86f:	eb 26                	jmp    897 <malloc+0x96>
      else {
        p->s.size -= nunits;
 871:	8b 45 f4             	mov    -0xc(%ebp),%eax
 874:	8b 40 04             	mov    0x4(%eax),%eax
 877:	2b 45 ec             	sub    -0x14(%ebp),%eax
 87a:	89 c2                	mov    %eax,%edx
 87c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87f:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 882:	8b 45 f4             	mov    -0xc(%ebp),%eax
 885:	8b 40 04             	mov    0x4(%eax),%eax
 888:	c1 e0 03             	shl    $0x3,%eax
 88b:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 88e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 891:	8b 55 ec             	mov    -0x14(%ebp),%edx
 894:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 897:	8b 45 f0             	mov    -0x10(%ebp),%eax
 89a:	a3 70 0b 00 00       	mov    %eax,0xb70
      return (void*)(p + 1);
 89f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a2:	83 c0 08             	add    $0x8,%eax
 8a5:	eb 3b                	jmp    8e2 <malloc+0xe1>
    }
    if(p == freep)
 8a7:	a1 70 0b 00 00       	mov    0xb70,%eax
 8ac:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8af:	75 1e                	jne    8cf <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 8b1:	83 ec 0c             	sub    $0xc,%esp
 8b4:	ff 75 ec             	push   -0x14(%ebp)
 8b7:	e8 e5 fe ff ff       	call   7a1 <morecore>
 8bc:	83 c4 10             	add    $0x10,%esp
 8bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8c2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8c6:	75 07                	jne    8cf <malloc+0xce>
        return 0;
 8c8:	b8 00 00 00 00       	mov    $0x0,%eax
 8cd:	eb 13                	jmp    8e2 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d8:	8b 00                	mov    (%eax),%eax
 8da:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8dd:	e9 6d ff ff ff       	jmp    84f <malloc+0x4e>
  }
}
 8e2:	c9                   	leave  
 8e3:	c3                   	ret    
