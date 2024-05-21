
kernelmemfs:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <wait_main>:
8010000c:	00 00                	add    %al,(%eax)
	...

80100010 <entry>:
  .long 0
# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  #Set Data Segment
  mov $0x10,%ax
80100010:	66 b8 10 00          	mov    $0x10,%ax
  mov %ax,%ds
80100014:	8e d8                	mov    %eax,%ds
  mov %ax,%es
80100016:	8e c0                	mov    %eax,%es
  mov %ax,%ss
80100018:	8e d0                	mov    %eax,%ss
  mov $0,%ax
8010001a:	66 b8 00 00          	mov    $0x0,%ax
  mov %ax,%fs
8010001e:	8e e0                	mov    %eax,%fs
  mov %ax,%gs
80100020:	8e e8                	mov    %eax,%gs

  #Turn off paing
  movl %cr0,%eax
80100022:	0f 20 c0             	mov    %cr0,%eax
  andl $0x7fffffff,%eax
80100025:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
  movl %eax,%cr0 
8010002a:	0f 22 c0             	mov    %eax,%cr0

  #Set Page Table Base Address
  movl    $(V2P_WO(entrypgdir)), %eax
8010002d:	b8 00 e0 10 00       	mov    $0x10e000,%eax
  movl    %eax, %cr3
80100032:	0f 22 d8             	mov    %eax,%cr3
  
  #Disable IA32e mode
  movl $0x0c0000080,%ecx
80100035:	b9 80 00 00 c0       	mov    $0xc0000080,%ecx
  rdmsr
8010003a:	0f 32                	rdmsr  
  andl $0xFFFFFEFF,%eax
8010003c:	25 ff fe ff ff       	and    $0xfffffeff,%eax
  wrmsr
80100041:	0f 30                	wrmsr  

  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
80100043:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
80100046:	83 c8 10             	or     $0x10,%eax
  andl    $0xFFFFFFDF, %eax
80100049:	83 e0 df             	and    $0xffffffdf,%eax
  movl    %eax, %cr4
8010004c:	0f 22 e0             	mov    %eax,%cr4

  #Turn on Paging
  movl    %cr0, %eax
8010004f:	0f 20 c0             	mov    %cr0,%eax
  orl     $0x80010001, %eax
80100052:	0d 01 00 01 80       	or     $0x80010001,%eax
  movl    %eax, %cr0
80100057:	0f 22 c0             	mov    %eax,%cr0




  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
8010005a:	bc 80 7f 19 80       	mov    $0x80197f80,%esp
  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
#  jz .waiting_main
  movl $main, %edx
8010005f:	ba 65 33 10 80       	mov    $0x80103365,%edx
  jmp %edx
80100064:	ff e2                	jmp    *%edx

80100066 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100066:	55                   	push   %ebp
80100067:	89 e5                	mov    %esp,%ebp
80100069:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010006c:	83 ec 08             	sub    $0x8,%esp
8010006f:	68 20 a1 10 80       	push   $0x8010a120
80100074:	68 00 d0 18 80       	push   $0x8018d000
80100079:	e8 cc 47 00 00       	call   8010484a <initlock>
8010007e:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100081:	c7 05 4c 17 19 80 fc 	movl   $0x801916fc,0x8019174c
80100088:	16 19 80 
  bcache.head.next = &bcache.head;
8010008b:	c7 05 50 17 19 80 fc 	movl   $0x801916fc,0x80191750
80100092:	16 19 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100095:	c7 45 f4 34 d0 18 80 	movl   $0x8018d034,-0xc(%ebp)
8010009c:	eb 47                	jmp    801000e5 <binit+0x7f>
    b->next = bcache.head.next;
8010009e:	8b 15 50 17 19 80    	mov    0x80191750,%edx
801000a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a7:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801000aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ad:	c7 40 50 fc 16 19 80 	movl   $0x801916fc,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
801000b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000b7:	83 c0 0c             	add    $0xc,%eax
801000ba:	83 ec 08             	sub    $0x8,%esp
801000bd:	68 27 a1 10 80       	push   $0x8010a127
801000c2:	50                   	push   %eax
801000c3:	e8 25 46 00 00       	call   801046ed <initsleeplock>
801000c8:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000cb:	a1 50 17 19 80       	mov    0x80191750,%eax
801000d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000d3:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d9:	a3 50 17 19 80       	mov    %eax,0x80191750
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000de:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000e5:	b8 fc 16 19 80       	mov    $0x801916fc,%eax
801000ea:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ed:	72 af                	jb     8010009e <binit+0x38>
  }
}
801000ef:	90                   	nop
801000f0:	90                   	nop
801000f1:	c9                   	leave  
801000f2:	c3                   	ret    

801000f3 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000f3:	55                   	push   %ebp
801000f4:	89 e5                	mov    %esp,%ebp
801000f6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000f9:	83 ec 0c             	sub    $0xc,%esp
801000fc:	68 00 d0 18 80       	push   $0x8018d000
80100101:	e8 66 47 00 00       	call   8010486c <acquire>
80100106:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100109:	a1 50 17 19 80       	mov    0x80191750,%eax
8010010e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100111:	eb 58                	jmp    8010016b <bget+0x78>
    if(b->dev == dev && b->blockno == blockno){
80100113:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100116:	8b 40 04             	mov    0x4(%eax),%eax
80100119:	39 45 08             	cmp    %eax,0x8(%ebp)
8010011c:	75 44                	jne    80100162 <bget+0x6f>
8010011e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100121:	8b 40 08             	mov    0x8(%eax),%eax
80100124:	39 45 0c             	cmp    %eax,0xc(%ebp)
80100127:	75 39                	jne    80100162 <bget+0x6f>
      b->refcnt++;
80100129:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010012c:	8b 40 4c             	mov    0x4c(%eax),%eax
8010012f:	8d 50 01             	lea    0x1(%eax),%edx
80100132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100135:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
80100138:	83 ec 0c             	sub    $0xc,%esp
8010013b:	68 00 d0 18 80       	push   $0x8018d000
80100140:	e8 95 47 00 00       	call   801048da <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 d2 45 00 00       	call   80104729 <acquiresleep>
80100157:	83 c4 10             	add    $0x10,%esp
      return b;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	e9 9d 00 00 00       	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	8b 40 54             	mov    0x54(%eax),%eax
80100168:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010016b:	81 7d f4 fc 16 19 80 	cmpl   $0x801916fc,-0xc(%ebp)
80100172:	75 9f                	jne    80100113 <bget+0x20>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100174:	a1 4c 17 19 80       	mov    0x8019174c,%eax
80100179:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010017c:	eb 6b                	jmp    801001e9 <bget+0xf6>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010017e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100181:	8b 40 4c             	mov    0x4c(%eax),%eax
80100184:	85 c0                	test   %eax,%eax
80100186:	75 58                	jne    801001e0 <bget+0xed>
80100188:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010018b:	8b 00                	mov    (%eax),%eax
8010018d:	83 e0 04             	and    $0x4,%eax
80100190:	85 c0                	test   %eax,%eax
80100192:	75 4c                	jne    801001e0 <bget+0xed>
      b->dev = dev;
80100194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100197:	8b 55 08             	mov    0x8(%ebp),%edx
8010019a:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010019d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801001a3:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
801001a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
801001af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b2:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
801001b9:	83 ec 0c             	sub    $0xc,%esp
801001bc:	68 00 d0 18 80       	push   $0x8018d000
801001c1:	e8 14 47 00 00       	call   801048da <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 51 45 00 00       	call   80104729 <acquiresleep>
801001d8:	83 c4 10             	add    $0x10,%esp
      return b;
801001db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001de:	eb 1f                	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001e3:	8b 40 50             	mov    0x50(%eax),%eax
801001e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001e9:	81 7d f4 fc 16 19 80 	cmpl   $0x801916fc,-0xc(%ebp)
801001f0:	75 8c                	jne    8010017e <bget+0x8b>
    }
  }
  panic("bget: no buffers");
801001f2:	83 ec 0c             	sub    $0xc,%esp
801001f5:	68 2e a1 10 80       	push   $0x8010a12e
801001fa:	e8 aa 03 00 00       	call   801005a9 <panic>
}
801001ff:	c9                   	leave  
80100200:	c3                   	ret    

80100201 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
80100201:	55                   	push   %ebp
80100202:	89 e5                	mov    %esp,%ebp
80100204:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
80100207:	83 ec 08             	sub    $0x8,%esp
8010020a:	ff 75 0c             	push   0xc(%ebp)
8010020d:	ff 75 08             	push   0x8(%ebp)
80100210:	e8 de fe ff ff       	call   801000f3 <bget>
80100215:	83 c4 10             	add    $0x10,%esp
80100218:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
8010021b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010021e:	8b 00                	mov    (%eax),%eax
80100220:	83 e0 02             	and    $0x2,%eax
80100223:	85 c0                	test   %eax,%eax
80100225:	75 0e                	jne    80100235 <bread+0x34>
    iderw(b);
80100227:	83 ec 0c             	sub    $0xc,%esp
8010022a:	ff 75 f4             	push   -0xc(%ebp)
8010022d:	e8 ff 9d 00 00       	call   8010a031 <iderw>
80100232:	83 c4 10             	add    $0x10,%esp
  }
  return b;
80100235:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100238:	c9                   	leave  
80100239:	c3                   	ret    

8010023a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
8010023a:	55                   	push   %ebp
8010023b:	89 e5                	mov    %esp,%ebp
8010023d:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100240:	8b 45 08             	mov    0x8(%ebp),%eax
80100243:	83 c0 0c             	add    $0xc,%eax
80100246:	83 ec 0c             	sub    $0xc,%esp
80100249:	50                   	push   %eax
8010024a:	e8 8c 45 00 00       	call   801047db <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 3f a1 10 80       	push   $0x8010a13f
8010025e:	e8 46 03 00 00       	call   801005a9 <panic>
  b->flags |= B_DIRTY;
80100263:	8b 45 08             	mov    0x8(%ebp),%eax
80100266:	8b 00                	mov    (%eax),%eax
80100268:	83 c8 04             	or     $0x4,%eax
8010026b:	89 c2                	mov    %eax,%edx
8010026d:	8b 45 08             	mov    0x8(%ebp),%eax
80100270:	89 10                	mov    %edx,(%eax)
  iderw(b);
80100272:	83 ec 0c             	sub    $0xc,%esp
80100275:	ff 75 08             	push   0x8(%ebp)
80100278:	e8 b4 9d 00 00       	call   8010a031 <iderw>
8010027d:	83 c4 10             	add    $0x10,%esp
}
80100280:	90                   	nop
80100281:	c9                   	leave  
80100282:	c3                   	ret    

80100283 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100283:	55                   	push   %ebp
80100284:	89 e5                	mov    %esp,%ebp
80100286:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100289:	8b 45 08             	mov    0x8(%ebp),%eax
8010028c:	83 c0 0c             	add    $0xc,%eax
8010028f:	83 ec 0c             	sub    $0xc,%esp
80100292:	50                   	push   %eax
80100293:	e8 43 45 00 00       	call   801047db <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 46 a1 10 80       	push   $0x8010a146
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 d2 44 00 00       	call   8010478d <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 d0 18 80       	push   $0x8018d000
801002c6:	e8 a1 45 00 00       	call   8010486c <acquire>
801002cb:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
801002ce:	8b 45 08             	mov    0x8(%ebp),%eax
801002d1:	8b 40 4c             	mov    0x4c(%eax),%eax
801002d4:	8d 50 ff             	lea    -0x1(%eax),%edx
801002d7:	8b 45 08             	mov    0x8(%ebp),%eax
801002da:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002dd:	8b 45 08             	mov    0x8(%ebp),%eax
801002e0:	8b 40 4c             	mov    0x4c(%eax),%eax
801002e3:	85 c0                	test   %eax,%eax
801002e5:	75 47                	jne    8010032e <brelse+0xab>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002e7:	8b 45 08             	mov    0x8(%ebp),%eax
801002ea:	8b 40 54             	mov    0x54(%eax),%eax
801002ed:	8b 55 08             	mov    0x8(%ebp),%edx
801002f0:	8b 52 50             	mov    0x50(%edx),%edx
801002f3:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801002f6:	8b 45 08             	mov    0x8(%ebp),%eax
801002f9:	8b 40 50             	mov    0x50(%eax),%eax
801002fc:	8b 55 08             	mov    0x8(%ebp),%edx
801002ff:	8b 52 54             	mov    0x54(%edx),%edx
80100302:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100305:	8b 15 50 17 19 80    	mov    0x80191750,%edx
8010030b:	8b 45 08             	mov    0x8(%ebp),%eax
8010030e:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	c7 40 50 fc 16 19 80 	movl   $0x801916fc,0x50(%eax)
    bcache.head.next->prev = b;
8010031b:	a1 50 17 19 80       	mov    0x80191750,%eax
80100320:	8b 55 08             	mov    0x8(%ebp),%edx
80100323:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
80100326:	8b 45 08             	mov    0x8(%ebp),%eax
80100329:	a3 50 17 19 80       	mov    %eax,0x80191750
  }
  
  release(&bcache.lock);
8010032e:	83 ec 0c             	sub    $0xc,%esp
80100331:	68 00 d0 18 80       	push   $0x8018d000
80100336:	e8 9f 45 00 00       	call   801048da <release>
8010033b:	83 c4 10             	add    $0x10,%esp
}
8010033e:	90                   	nop
8010033f:	c9                   	leave  
80100340:	c3                   	ret    

80100341 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100341:	55                   	push   %ebp
80100342:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100344:	fa                   	cli    
}
80100345:	90                   	nop
80100346:	5d                   	pop    %ebp
80100347:	c3                   	ret    

80100348 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100348:	55                   	push   %ebp
80100349:	89 e5                	mov    %esp,%ebp
8010034b:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010034e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100352:	74 1c                	je     80100370 <printint+0x28>
80100354:	8b 45 08             	mov    0x8(%ebp),%eax
80100357:	c1 e8 1f             	shr    $0x1f,%eax
8010035a:	0f b6 c0             	movzbl %al,%eax
8010035d:	89 45 10             	mov    %eax,0x10(%ebp)
80100360:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100364:	74 0a                	je     80100370 <printint+0x28>
    x = -xx;
80100366:	8b 45 08             	mov    0x8(%ebp),%eax
80100369:	f7 d8                	neg    %eax
8010036b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010036e:	eb 06                	jmp    80100376 <printint+0x2e>
  else
    x = xx;
80100370:	8b 45 08             	mov    0x8(%ebp),%eax
80100373:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100376:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010037d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100380:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100383:	ba 00 00 00 00       	mov    $0x0,%edx
80100388:	f7 f1                	div    %ecx
8010038a:	89 d1                	mov    %edx,%ecx
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	0f b6 91 04 d0 10 80 	movzbl -0x7fef2ffc(%ecx),%edx
8010039c:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
801003a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003a6:	ba 00 00 00 00       	mov    $0x0,%edx
801003ab:	f7 f1                	div    %ecx
801003ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003b4:	75 c7                	jne    8010037d <printint+0x35>

  if(sign)
801003b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003ba:	74 2a                	je     801003e6 <printint+0x9e>
    buf[i++] = '-';
801003bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003bf:	8d 50 01             	lea    0x1(%eax),%edx
801003c2:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003c5:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003ca:	eb 1a                	jmp    801003e6 <printint+0x9e>
    consputc(buf[i]);
801003cc:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003d2:	01 d0                	add    %edx,%eax
801003d4:	0f b6 00             	movzbl (%eax),%eax
801003d7:	0f be c0             	movsbl %al,%eax
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	50                   	push   %eax
801003de:	e8 8c 03 00 00       	call   8010076f <consputc>
801003e3:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
801003e6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003ee:	79 dc                	jns    801003cc <printint+0x84>
}
801003f0:	90                   	nop
801003f1:	90                   	nop
801003f2:	c9                   	leave  
801003f3:	c3                   	ret    

801003f4 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003f4:	55                   	push   %ebp
801003f5:	89 e5                	mov    %esp,%ebp
801003f7:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003fa:	a1 34 1a 19 80       	mov    0x80191a34,%eax
801003ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
80100402:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100406:	74 10                	je     80100418 <cprintf+0x24>
    acquire(&cons.lock);
80100408:	83 ec 0c             	sub    $0xc,%esp
8010040b:	68 00 1a 19 80       	push   $0x80191a00
80100410:	e8 57 44 00 00       	call   8010486c <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 4d a1 10 80       	push   $0x8010a14d
80100427:	e8 7d 01 00 00       	call   801005a9 <panic>


  argp = (uint*)(void*)(&fmt + 1);
8010042c:	8d 45 0c             	lea    0xc(%ebp),%eax
8010042f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100432:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100439:	e9 2f 01 00 00       	jmp    8010056d <cprintf+0x179>
    if(c != '%'){
8010043e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100442:	74 13                	je     80100457 <cprintf+0x63>
      consputc(c);
80100444:	83 ec 0c             	sub    $0xc,%esp
80100447:	ff 75 e4             	push   -0x1c(%ebp)
8010044a:	e8 20 03 00 00       	call   8010076f <consputc>
8010044f:	83 c4 10             	add    $0x10,%esp
      continue;
80100452:	e9 12 01 00 00       	jmp    80100569 <cprintf+0x175>
    }
    c = fmt[++i] & 0xff;
80100457:	8b 55 08             	mov    0x8(%ebp),%edx
8010045a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010045e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100461:	01 d0                	add    %edx,%eax
80100463:	0f b6 00             	movzbl (%eax),%eax
80100466:	0f be c0             	movsbl %al,%eax
80100469:	25 ff 00 00 00       	and    $0xff,%eax
8010046e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100471:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100475:	0f 84 14 01 00 00    	je     8010058f <cprintf+0x19b>
      break;
    switch(c){
8010047b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
8010047f:	74 5e                	je     801004df <cprintf+0xeb>
80100481:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
80100485:	0f 8f c2 00 00 00    	jg     8010054d <cprintf+0x159>
8010048b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
8010048f:	74 6b                	je     801004fc <cprintf+0x108>
80100491:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
80100495:	0f 8f b2 00 00 00    	jg     8010054d <cprintf+0x159>
8010049b:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
8010049f:	74 3e                	je     801004df <cprintf+0xeb>
801004a1:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004a5:	0f 8f a2 00 00 00    	jg     8010054d <cprintf+0x159>
801004ab:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004af:	0f 84 89 00 00 00    	je     8010053e <cprintf+0x14a>
801004b5:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
801004b9:	0f 85 8e 00 00 00    	jne    8010054d <cprintf+0x159>
    case 'd':
      printint(*argp++, 10, 1);
801004bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004c2:	8d 50 04             	lea    0x4(%eax),%edx
801004c5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c8:	8b 00                	mov    (%eax),%eax
801004ca:	83 ec 04             	sub    $0x4,%esp
801004cd:	6a 01                	push   $0x1
801004cf:	6a 0a                	push   $0xa
801004d1:	50                   	push   %eax
801004d2:	e8 71 fe ff ff       	call   80100348 <printint>
801004d7:	83 c4 10             	add    $0x10,%esp
      break;
801004da:	e9 8a 00 00 00       	jmp    80100569 <cprintf+0x175>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004e2:	8d 50 04             	lea    0x4(%eax),%edx
801004e5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004e8:	8b 00                	mov    (%eax),%eax
801004ea:	83 ec 04             	sub    $0x4,%esp
801004ed:	6a 00                	push   $0x0
801004ef:	6a 10                	push   $0x10
801004f1:	50                   	push   %eax
801004f2:	e8 51 fe ff ff       	call   80100348 <printint>
801004f7:	83 c4 10             	add    $0x10,%esp
      break;
801004fa:	eb 6d                	jmp    80100569 <cprintf+0x175>
    case 's':
      if((s = (char*)*argp++) == 0)
801004fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004ff:	8d 50 04             	lea    0x4(%eax),%edx
80100502:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100505:	8b 00                	mov    (%eax),%eax
80100507:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010050a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010050e:	75 22                	jne    80100532 <cprintf+0x13e>
        s = "(null)";
80100510:	c7 45 ec 56 a1 10 80 	movl   $0x8010a156,-0x14(%ebp)
      for(; *s; s++)
80100517:	eb 19                	jmp    80100532 <cprintf+0x13e>
        consputc(*s);
80100519:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010051c:	0f b6 00             	movzbl (%eax),%eax
8010051f:	0f be c0             	movsbl %al,%eax
80100522:	83 ec 0c             	sub    $0xc,%esp
80100525:	50                   	push   %eax
80100526:	e8 44 02 00 00       	call   8010076f <consputc>
8010052b:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010052e:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100532:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100535:	0f b6 00             	movzbl (%eax),%eax
80100538:	84 c0                	test   %al,%al
8010053a:	75 dd                	jne    80100519 <cprintf+0x125>
      break;
8010053c:	eb 2b                	jmp    80100569 <cprintf+0x175>
    case '%':
      consputc('%');
8010053e:	83 ec 0c             	sub    $0xc,%esp
80100541:	6a 25                	push   $0x25
80100543:	e8 27 02 00 00       	call   8010076f <consputc>
80100548:	83 c4 10             	add    $0x10,%esp
      break;
8010054b:	eb 1c                	jmp    80100569 <cprintf+0x175>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010054d:	83 ec 0c             	sub    $0xc,%esp
80100550:	6a 25                	push   $0x25
80100552:	e8 18 02 00 00       	call   8010076f <consputc>
80100557:	83 c4 10             	add    $0x10,%esp
      consputc(c);
8010055a:	83 ec 0c             	sub    $0xc,%esp
8010055d:	ff 75 e4             	push   -0x1c(%ebp)
80100560:	e8 0a 02 00 00       	call   8010076f <consputc>
80100565:	83 c4 10             	add    $0x10,%esp
      break;
80100568:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100569:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010056d:	8b 55 08             	mov    0x8(%ebp),%edx
80100570:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100573:	01 d0                	add    %edx,%eax
80100575:	0f b6 00             	movzbl (%eax),%eax
80100578:	0f be c0             	movsbl %al,%eax
8010057b:	25 ff 00 00 00       	and    $0xff,%eax
80100580:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100583:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100587:	0f 85 b1 fe ff ff    	jne    8010043e <cprintf+0x4a>
8010058d:	eb 01                	jmp    80100590 <cprintf+0x19c>
      break;
8010058f:	90                   	nop
    }
  }

  if(locking)
80100590:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100594:	74 10                	je     801005a6 <cprintf+0x1b2>
    release(&cons.lock);
80100596:	83 ec 0c             	sub    $0xc,%esp
80100599:	68 00 1a 19 80       	push   $0x80191a00
8010059e:	e8 37 43 00 00       	call   801048da <release>
801005a3:	83 c4 10             	add    $0x10,%esp
}
801005a6:	90                   	nop
801005a7:	c9                   	leave  
801005a8:	c3                   	ret    

801005a9 <panic>:

void
panic(char *s)
{
801005a9:	55                   	push   %ebp
801005aa:	89 e5                	mov    %esp,%ebp
801005ac:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
801005af:	e8 8d fd ff ff       	call   80100341 <cli>
  cons.locking = 0;
801005b4:	c7 05 34 1a 19 80 00 	movl   $0x0,0x80191a34
801005bb:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005be:	e8 37 25 00 00       	call   80102afa <lapicid>
801005c3:	83 ec 08             	sub    $0x8,%esp
801005c6:	50                   	push   %eax
801005c7:	68 5d a1 10 80       	push   $0x8010a15d
801005cc:	e8 23 fe ff ff       	call   801003f4 <cprintf>
801005d1:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005d4:	8b 45 08             	mov    0x8(%ebp),%eax
801005d7:	83 ec 0c             	sub    $0xc,%esp
801005da:	50                   	push   %eax
801005db:	e8 14 fe ff ff       	call   801003f4 <cprintf>
801005e0:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005e3:	83 ec 0c             	sub    $0xc,%esp
801005e6:	68 71 a1 10 80       	push   $0x8010a171
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 29 43 00 00       	call   8010492c <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 73 a1 10 80       	push   $0x8010a173
8010061f:	e8 d0 fd ff ff       	call   801003f4 <cprintf>
80100624:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100627:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010062b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010062f:	7e de                	jle    8010060f <panic+0x66>
  panicked = 1; // freeze other CPU
80100631:	c7 05 ec 19 19 80 01 	movl   $0x1,0x801919ec
80100638:	00 00 00 
  for(;;)
8010063b:	eb fe                	jmp    8010063b <panic+0x92>

8010063d <graphic_putc>:

#define CONSOLE_HORIZONTAL_MAX 53
#define CONSOLE_VERTICAL_MAX 20
int console_pos = CONSOLE_HORIZONTAL_MAX*(CONSOLE_VERTICAL_MAX);
//int console_pos = 0;
void graphic_putc(int c){
8010063d:	55                   	push   %ebp
8010063e:	89 e5                	mov    %esp,%ebp
80100640:	83 ec 18             	sub    $0x18,%esp
  if(c == '\n'){
80100643:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100647:	75 64                	jne    801006ad <graphic_putc+0x70>
    console_pos += CONSOLE_HORIZONTAL_MAX - console_pos%CONSOLE_HORIZONTAL_MAX;
80100649:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
8010064f:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100654:	89 c8                	mov    %ecx,%eax
80100656:	f7 ea                	imul   %edx
80100658:	89 d0                	mov    %edx,%eax
8010065a:	c1 f8 04             	sar    $0x4,%eax
8010065d:	89 ca                	mov    %ecx,%edx
8010065f:	c1 fa 1f             	sar    $0x1f,%edx
80100662:	29 d0                	sub    %edx,%eax
80100664:	6b d0 35             	imul   $0x35,%eax,%edx
80100667:	89 c8                	mov    %ecx,%eax
80100669:	29 d0                	sub    %edx,%eax
8010066b:	ba 35 00 00 00       	mov    $0x35,%edx
80100670:	29 c2                	sub    %eax,%edx
80100672:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100677:	01 d0                	add    %edx,%eax
80100679:	a3 00 d0 10 80       	mov    %eax,0x8010d000
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
8010067e:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100683:	3d 23 04 00 00       	cmp    $0x423,%eax
80100688:	0f 8e de 00 00 00    	jle    8010076c <graphic_putc+0x12f>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
8010068e:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100693:	83 e8 35             	sub    $0x35,%eax
80100696:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
8010069b:	83 ec 0c             	sub    $0xc,%esp
8010069e:	6a 1e                	push   $0x1e
801006a0:	e8 e3 78 00 00       	call   80107f88 <graphic_scroll_up>
801006a5:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
    font_render(x,y,c);
    console_pos++;
  }
}
801006a8:	e9 bf 00 00 00       	jmp    8010076c <graphic_putc+0x12f>
  }else if(c == BACKSPACE){
801006ad:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006b4:	75 1f                	jne    801006d5 <graphic_putc+0x98>
    if(console_pos>0) --console_pos;
801006b6:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006bb:	85 c0                	test   %eax,%eax
801006bd:	0f 8e a9 00 00 00    	jle    8010076c <graphic_putc+0x12f>
801006c3:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006c8:	83 e8 01             	sub    $0x1,%eax
801006cb:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
801006d0:	e9 97 00 00 00       	jmp    8010076c <graphic_putc+0x12f>
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
801006d5:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006da:	3d 23 04 00 00       	cmp    $0x423,%eax
801006df:	7e 1a                	jle    801006fb <graphic_putc+0xbe>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
801006e1:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006e6:	83 e8 35             	sub    $0x35,%eax
801006e9:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
801006ee:	83 ec 0c             	sub    $0xc,%esp
801006f1:	6a 1e                	push   $0x1e
801006f3:	e8 90 78 00 00       	call   80107f88 <graphic_scroll_up>
801006f8:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
801006fb:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100701:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100706:	89 c8                	mov    %ecx,%eax
80100708:	f7 ea                	imul   %edx
8010070a:	89 d0                	mov    %edx,%eax
8010070c:	c1 f8 04             	sar    $0x4,%eax
8010070f:	89 ca                	mov    %ecx,%edx
80100711:	c1 fa 1f             	sar    $0x1f,%edx
80100714:	29 d0                	sub    %edx,%eax
80100716:	6b d0 35             	imul   $0x35,%eax,%edx
80100719:	89 c8                	mov    %ecx,%eax
8010071b:	29 d0                	sub    %edx,%eax
8010071d:	89 c2                	mov    %eax,%edx
8010071f:	c1 e2 04             	shl    $0x4,%edx
80100722:	29 c2                	sub    %eax,%edx
80100724:	8d 42 02             	lea    0x2(%edx),%eax
80100727:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
8010072a:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100730:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100735:	89 c8                	mov    %ecx,%eax
80100737:	f7 ea                	imul   %edx
80100739:	89 d0                	mov    %edx,%eax
8010073b:	c1 f8 04             	sar    $0x4,%eax
8010073e:	c1 f9 1f             	sar    $0x1f,%ecx
80100741:	89 ca                	mov    %ecx,%edx
80100743:	29 d0                	sub    %edx,%eax
80100745:	6b c0 1e             	imul   $0x1e,%eax,%eax
80100748:	89 45 f0             	mov    %eax,-0x10(%ebp)
    font_render(x,y,c);
8010074b:	83 ec 04             	sub    $0x4,%esp
8010074e:	ff 75 08             	push   0x8(%ebp)
80100751:	ff 75 f0             	push   -0x10(%ebp)
80100754:	ff 75 f4             	push   -0xc(%ebp)
80100757:	e8 97 78 00 00       	call   80107ff3 <font_render>
8010075c:	83 c4 10             	add    $0x10,%esp
    console_pos++;
8010075f:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100764:	83 c0 01             	add    $0x1,%eax
80100767:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
8010076c:	90                   	nop
8010076d:	c9                   	leave  
8010076e:	c3                   	ret    

8010076f <consputc>:


void
consputc(int c)
{
8010076f:	55                   	push   %ebp
80100770:	89 e5                	mov    %esp,%ebp
80100772:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100775:	a1 ec 19 19 80       	mov    0x801919ec,%eax
8010077a:	85 c0                	test   %eax,%eax
8010077c:	74 07                	je     80100785 <consputc+0x16>
    cli();
8010077e:	e8 be fb ff ff       	call   80100341 <cli>
    for(;;)
80100783:	eb fe                	jmp    80100783 <consputc+0x14>
      ;
  }

  if(c == BACKSPACE){
80100785:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010078c:	75 29                	jne    801007b7 <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010078e:	83 ec 0c             	sub    $0xc,%esp
80100791:	6a 08                	push   $0x8
80100793:	e8 67 5c 00 00       	call   801063ff <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 5a 5c 00 00       	call   801063ff <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 4d 5c 00 00       	call   801063ff <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x56>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 3d 5c 00 00       	call   801063ff <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
  }
  graphic_putc(c);
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	ff 75 08             	push   0x8(%ebp)
801007cb:	e8 6d fe ff ff       	call   8010063d <graphic_putc>
801007d0:	83 c4 10             	add    $0x10,%esp
}
801007d3:	90                   	nop
801007d4:	c9                   	leave  
801007d5:	c3                   	ret    

801007d6 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007d6:	55                   	push   %ebp
801007d7:	89 e5                	mov    %esp,%ebp
801007d9:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801007dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801007e3:	83 ec 0c             	sub    $0xc,%esp
801007e6:	68 00 1a 19 80       	push   $0x80191a00
801007eb:	e8 7c 40 00 00       	call   8010486c <acquire>
801007f0:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
801007f3:	e9 50 01 00 00       	jmp    80100948 <consoleintr+0x172>
    switch(c){
801007f8:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801007fc:	0f 84 81 00 00 00    	je     80100883 <consoleintr+0xad>
80100802:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100806:	0f 8f ac 00 00 00    	jg     801008b8 <consoleintr+0xe2>
8010080c:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100810:	74 43                	je     80100855 <consoleintr+0x7f>
80100812:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100816:	0f 8f 9c 00 00 00    	jg     801008b8 <consoleintr+0xe2>
8010081c:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
80100820:	74 61                	je     80100883 <consoleintr+0xad>
80100822:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
80100826:	0f 85 8c 00 00 00    	jne    801008b8 <consoleintr+0xe2>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
8010082c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100833:	e9 10 01 00 00       	jmp    80100948 <consoleintr+0x172>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100838:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010083d:	83 e8 01             	sub    $0x1,%eax
80100840:	a3 e8 19 19 80       	mov    %eax,0x801919e8
        consputc(BACKSPACE);
80100845:	83 ec 0c             	sub    $0xc,%esp
80100848:	68 00 01 00 00       	push   $0x100
8010084d:	e8 1d ff ff ff       	call   8010076f <consputc>
80100852:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100855:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
8010085b:	a1 e4 19 19 80       	mov    0x801919e4,%eax
80100860:	39 c2                	cmp    %eax,%edx
80100862:	0f 84 e0 00 00 00    	je     80100948 <consoleintr+0x172>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100868:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010086d:	83 e8 01             	sub    $0x1,%eax
80100870:	83 e0 7f             	and    $0x7f,%eax
80100873:	0f b6 80 60 19 19 80 	movzbl -0x7fe6e6a0(%eax),%eax
      while(input.e != input.w &&
8010087a:	3c 0a                	cmp    $0xa,%al
8010087c:	75 ba                	jne    80100838 <consoleintr+0x62>
      }
      break;
8010087e:	e9 c5 00 00 00       	jmp    80100948 <consoleintr+0x172>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100883:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
80100889:	a1 e4 19 19 80       	mov    0x801919e4,%eax
8010088e:	39 c2                	cmp    %eax,%edx
80100890:	0f 84 b2 00 00 00    	je     80100948 <consoleintr+0x172>
        input.e--;
80100896:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010089b:	83 e8 01             	sub    $0x1,%eax
8010089e:	a3 e8 19 19 80       	mov    %eax,0x801919e8
        consputc(BACKSPACE);
801008a3:	83 ec 0c             	sub    $0xc,%esp
801008a6:	68 00 01 00 00       	push   $0x100
801008ab:	e8 bf fe ff ff       	call   8010076f <consputc>
801008b0:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008b3:	e9 90 00 00 00       	jmp    80100948 <consoleintr+0x172>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008bc:	0f 84 85 00 00 00    	je     80100947 <consoleintr+0x171>
801008c2:	a1 e8 19 19 80       	mov    0x801919e8,%eax
801008c7:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
801008cd:	29 d0                	sub    %edx,%eax
801008cf:	83 f8 7f             	cmp    $0x7f,%eax
801008d2:	77 73                	ja     80100947 <consoleintr+0x171>
        c = (c == '\r') ? '\n' : c;
801008d4:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008d8:	74 05                	je     801008df <consoleintr+0x109>
801008da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008dd:	eb 05                	jmp    801008e4 <consoleintr+0x10e>
801008df:	b8 0a 00 00 00       	mov    $0xa,%eax
801008e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008e7:	a1 e8 19 19 80       	mov    0x801919e8,%eax
801008ec:	8d 50 01             	lea    0x1(%eax),%edx
801008ef:	89 15 e8 19 19 80    	mov    %edx,0x801919e8
801008f5:	83 e0 7f             	and    $0x7f,%eax
801008f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801008fb:	88 90 60 19 19 80    	mov    %dl,-0x7fe6e6a0(%eax)
        consputc(c);
80100901:	83 ec 0c             	sub    $0xc,%esp
80100904:	ff 75 f0             	push   -0x10(%ebp)
80100907:	e8 63 fe ff ff       	call   8010076f <consputc>
8010090c:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
8010090f:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100913:	74 18                	je     8010092d <consoleintr+0x157>
80100915:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100919:	74 12                	je     8010092d <consoleintr+0x157>
8010091b:	a1 e8 19 19 80       	mov    0x801919e8,%eax
80100920:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
80100926:	83 ea 80             	sub    $0xffffff80,%edx
80100929:	39 d0                	cmp    %edx,%eax
8010092b:	75 1a                	jne    80100947 <consoleintr+0x171>
          input.w = input.e;
8010092d:	a1 e8 19 19 80       	mov    0x801919e8,%eax
80100932:	a3 e4 19 19 80       	mov    %eax,0x801919e4
          wakeup(&input.r);
80100937:	83 ec 0c             	sub    $0xc,%esp
8010093a:	68 e0 19 19 80       	push   $0x801919e0
8010093f:	e8 7c 3a 00 00       	call   801043c0 <wakeup>
80100944:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100947:	90                   	nop
  while((c = getc()) >= 0){
80100948:	8b 45 08             	mov    0x8(%ebp),%eax
8010094b:	ff d0                	call   *%eax
8010094d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100950:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100954:	0f 89 9e fe ff ff    	jns    801007f8 <consoleintr+0x22>
    }
  }
  release(&cons.lock);
8010095a:	83 ec 0c             	sub    $0xc,%esp
8010095d:	68 00 1a 19 80       	push   $0x80191a00
80100962:	e8 73 3f 00 00       	call   801048da <release>
80100967:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010096a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010096e:	74 05                	je     80100975 <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
80100970:	e8 06 3b 00 00       	call   8010447b <procdump>
  }
}
80100975:	90                   	nop
80100976:	c9                   	leave  
80100977:	c3                   	ret    

80100978 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100978:	55                   	push   %ebp
80100979:	89 e5                	mov    %esp,%ebp
8010097b:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
8010097e:	83 ec 0c             	sub    $0xc,%esp
80100981:	ff 75 08             	push   0x8(%ebp)
80100984:	e8 74 11 00 00       	call   80101afd <iunlock>
80100989:	83 c4 10             	add    $0x10,%esp
  target = n;
8010098c:	8b 45 10             	mov    0x10(%ebp),%eax
8010098f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100992:	83 ec 0c             	sub    $0xc,%esp
80100995:	68 00 1a 19 80       	push   $0x80191a00
8010099a:	e8 cd 3e 00 00       	call   8010486c <acquire>
8010099f:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009a2:	e9 ab 00 00 00       	jmp    80100a52 <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009a7:	e8 84 30 00 00       	call   80103a30 <myproc>
801009ac:	8b 40 24             	mov    0x24(%eax),%eax
801009af:	85 c0                	test   %eax,%eax
801009b1:	74 28                	je     801009db <consoleread+0x63>
        release(&cons.lock);
801009b3:	83 ec 0c             	sub    $0xc,%esp
801009b6:	68 00 1a 19 80       	push   $0x80191a00
801009bb:	e8 1a 3f 00 00       	call   801048da <release>
801009c0:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009c3:	83 ec 0c             	sub    $0xc,%esp
801009c6:	ff 75 08             	push   0x8(%ebp)
801009c9:	e8 1c 10 00 00       	call   801019ea <ilock>
801009ce:	83 c4 10             	add    $0x10,%esp
        return -1;
801009d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009d6:	e9 a9 00 00 00       	jmp    80100a84 <consoleread+0x10c>
      }
      sleep(&input.r, &cons.lock);
801009db:	83 ec 08             	sub    $0x8,%esp
801009de:	68 00 1a 19 80       	push   $0x80191a00
801009e3:	68 e0 19 19 80       	push   $0x801919e0
801009e8:	e8 ec 38 00 00       	call   801042d9 <sleep>
801009ed:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
801009f0:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
801009f6:	a1 e4 19 19 80       	mov    0x801919e4,%eax
801009fb:	39 c2                	cmp    %eax,%edx
801009fd:	74 a8                	je     801009a7 <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009ff:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100a04:	8d 50 01             	lea    0x1(%eax),%edx
80100a07:	89 15 e0 19 19 80    	mov    %edx,0x801919e0
80100a0d:	83 e0 7f             	and    $0x7f,%eax
80100a10:	0f b6 80 60 19 19 80 	movzbl -0x7fe6e6a0(%eax),%eax
80100a17:	0f be c0             	movsbl %al,%eax
80100a1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a1d:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a21:	75 17                	jne    80100a3a <consoleread+0xc2>
      if(n < target){
80100a23:	8b 45 10             	mov    0x10(%ebp),%eax
80100a26:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100a29:	76 2f                	jbe    80100a5a <consoleread+0xe2>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a2b:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100a30:	83 e8 01             	sub    $0x1,%eax
80100a33:	a3 e0 19 19 80       	mov    %eax,0x801919e0
      }
      break;
80100a38:	eb 20                	jmp    80100a5a <consoleread+0xe2>
    }
    *dst++ = c;
80100a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a3d:	8d 50 01             	lea    0x1(%eax),%edx
80100a40:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a43:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a46:	88 10                	mov    %dl,(%eax)
    --n;
80100a48:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a4c:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a50:	74 0b                	je     80100a5d <consoleread+0xe5>
  while(n > 0){
80100a52:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a56:	7f 98                	jg     801009f0 <consoleread+0x78>
80100a58:	eb 04                	jmp    80100a5e <consoleread+0xe6>
      break;
80100a5a:	90                   	nop
80100a5b:	eb 01                	jmp    80100a5e <consoleread+0xe6>
      break;
80100a5d:	90                   	nop
  }
  release(&cons.lock);
80100a5e:	83 ec 0c             	sub    $0xc,%esp
80100a61:	68 00 1a 19 80       	push   $0x80191a00
80100a66:	e8 6f 3e 00 00       	call   801048da <release>
80100a6b:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a6e:	83 ec 0c             	sub    $0xc,%esp
80100a71:	ff 75 08             	push   0x8(%ebp)
80100a74:	e8 71 0f 00 00       	call   801019ea <ilock>
80100a79:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a7c:	8b 55 10             	mov    0x10(%ebp),%edx
80100a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a82:	29 d0                	sub    %edx,%eax
}
80100a84:	c9                   	leave  
80100a85:	c3                   	ret    

80100a86 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a86:	55                   	push   %ebp
80100a87:	89 e5                	mov    %esp,%ebp
80100a89:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100a8c:	83 ec 0c             	sub    $0xc,%esp
80100a8f:	ff 75 08             	push   0x8(%ebp)
80100a92:	e8 66 10 00 00       	call   80101afd <iunlock>
80100a97:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100a9a:	83 ec 0c             	sub    $0xc,%esp
80100a9d:	68 00 1a 19 80       	push   $0x80191a00
80100aa2:	e8 c5 3d 00 00       	call   8010486c <acquire>
80100aa7:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100aaa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100ab1:	eb 21                	jmp    80100ad4 <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100ab3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ab6:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ab9:	01 d0                	add    %edx,%eax
80100abb:	0f b6 00             	movzbl (%eax),%eax
80100abe:	0f be c0             	movsbl %al,%eax
80100ac1:	0f b6 c0             	movzbl %al,%eax
80100ac4:	83 ec 0c             	sub    $0xc,%esp
80100ac7:	50                   	push   %eax
80100ac8:	e8 a2 fc ff ff       	call   8010076f <consputc>
80100acd:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ad0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ad7:	3b 45 10             	cmp    0x10(%ebp),%eax
80100ada:	7c d7                	jl     80100ab3 <consolewrite+0x2d>
  release(&cons.lock);
80100adc:	83 ec 0c             	sub    $0xc,%esp
80100adf:	68 00 1a 19 80       	push   $0x80191a00
80100ae4:	e8 f1 3d 00 00       	call   801048da <release>
80100ae9:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100aec:	83 ec 0c             	sub    $0xc,%esp
80100aef:	ff 75 08             	push   0x8(%ebp)
80100af2:	e8 f3 0e 00 00       	call   801019ea <ilock>
80100af7:	83 c4 10             	add    $0x10,%esp

  return n;
80100afa:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100afd:	c9                   	leave  
80100afe:	c3                   	ret    

80100aff <consoleinit>:

void
consoleinit(void)
{
80100aff:	55                   	push   %ebp
80100b00:	89 e5                	mov    %esp,%ebp
80100b02:	83 ec 18             	sub    $0x18,%esp
  panicked = 0;
80100b05:	c7 05 ec 19 19 80 00 	movl   $0x0,0x801919ec
80100b0c:	00 00 00 
  initlock(&cons.lock, "console");
80100b0f:	83 ec 08             	sub    $0x8,%esp
80100b12:	68 77 a1 10 80       	push   $0x8010a177
80100b17:	68 00 1a 19 80       	push   $0x80191a00
80100b1c:	e8 29 3d 00 00       	call   8010484a <initlock>
80100b21:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b24:	c7 05 4c 1a 19 80 86 	movl   $0x80100a86,0x80191a4c
80100b2b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b2e:	c7 05 48 1a 19 80 78 	movl   $0x80100978,0x80191a48
80100b35:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b38:	c7 45 f4 7f a1 10 80 	movl   $0x8010a17f,-0xc(%ebp)
80100b3f:	eb 19                	jmp    80100b5a <consoleinit+0x5b>
    graphic_putc(*p);
80100b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b44:	0f b6 00             	movzbl (%eax),%eax
80100b47:	0f be c0             	movsbl %al,%eax
80100b4a:	83 ec 0c             	sub    $0xc,%esp
80100b4d:	50                   	push   %eax
80100b4e:	e8 ea fa ff ff       	call   8010063d <graphic_putc>
80100b53:	83 c4 10             	add    $0x10,%esp
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b56:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b5d:	0f b6 00             	movzbl (%eax),%eax
80100b60:	84 c0                	test   %al,%al
80100b62:	75 dd                	jne    80100b41 <consoleinit+0x42>
  
  cons.locking = 1;
80100b64:	c7 05 34 1a 19 80 01 	movl   $0x1,0x80191a34
80100b6b:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100b6e:	83 ec 08             	sub    $0x8,%esp
80100b71:	6a 00                	push   $0x0
80100b73:	6a 01                	push   $0x1
80100b75:	e8 b4 1a 00 00       	call   8010262e <ioapicenable>
80100b7a:	83 c4 10             	add    $0x10,%esp
}
80100b7d:	90                   	nop
80100b7e:	c9                   	leave  
80100b7f:	c3                   	ret    

80100b80 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b80:	55                   	push   %ebp
80100b81:	89 e5                	mov    %esp,%ebp
80100b83:	81 ec 18 01 00 00    	sub    $0x118,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100b89:	e8 a2 2e 00 00       	call   80103a30 <myproc>
80100b8e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100b91:	e8 a6 24 00 00       	call   8010303c <begin_op>

  if((ip = namei(path)) == 0){
80100b96:	83 ec 0c             	sub    $0xc,%esp
80100b99:	ff 75 08             	push   0x8(%ebp)
80100b9c:	e8 7c 19 00 00       	call   8010251d <namei>
80100ba1:	83 c4 10             	add    $0x10,%esp
80100ba4:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100ba7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bab:	75 1f                	jne    80100bcc <exec+0x4c>
    end_op();
80100bad:	e8 16 25 00 00       	call   801030c8 <end_op>
    cprintf("exec: fail\n");
80100bb2:	83 ec 0c             	sub    $0xc,%esp
80100bb5:	68 95 a1 10 80       	push   $0x8010a195
80100bba:	e8 35 f8 ff ff       	call   801003f4 <cprintf>
80100bbf:	83 c4 10             	add    $0x10,%esp
    return -1;
80100bc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bc7:	e9 f1 03 00 00       	jmp    80100fbd <exec+0x43d>
  }
  ilock(ip);
80100bcc:	83 ec 0c             	sub    $0xc,%esp
80100bcf:	ff 75 d8             	push   -0x28(%ebp)
80100bd2:	e8 13 0e 00 00       	call   801019ea <ilock>
80100bd7:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100bda:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100be1:	6a 34                	push   $0x34
80100be3:	6a 00                	push   $0x0
80100be5:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100beb:	50                   	push   %eax
80100bec:	ff 75 d8             	push   -0x28(%ebp)
80100bef:	e8 e2 12 00 00       	call   80101ed6 <readi>
80100bf4:	83 c4 10             	add    $0x10,%esp
80100bf7:	83 f8 34             	cmp    $0x34,%eax
80100bfa:	0f 85 66 03 00 00    	jne    80100f66 <exec+0x3e6>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c00:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c06:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c0b:	0f 85 58 03 00 00    	jne    80100f69 <exec+0x3e9>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c11:	e8 e5 67 00 00       	call   801073fb <setupkvm>
80100c16:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c19:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c1d:	0f 84 49 03 00 00    	je     80100f6c <exec+0x3ec>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c23:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c2a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c31:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100c37:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c3a:	e9 de 00 00 00       	jmp    80100d1d <exec+0x19d>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c3f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c42:	6a 20                	push   $0x20
80100c44:	50                   	push   %eax
80100c45:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100c4b:	50                   	push   %eax
80100c4c:	ff 75 d8             	push   -0x28(%ebp)
80100c4f:	e8 82 12 00 00       	call   80101ed6 <readi>
80100c54:	83 c4 10             	add    $0x10,%esp
80100c57:	83 f8 20             	cmp    $0x20,%eax
80100c5a:	0f 85 0f 03 00 00    	jne    80100f6f <exec+0x3ef>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c60:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100c66:	83 f8 01             	cmp    $0x1,%eax
80100c69:	0f 85 a0 00 00 00    	jne    80100d0f <exec+0x18f>
      continue;
    if(ph.memsz < ph.filesz)
80100c6f:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c75:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100c7b:	39 c2                	cmp    %eax,%edx
80100c7d:	0f 82 ef 02 00 00    	jb     80100f72 <exec+0x3f2>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c83:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c89:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c8f:	01 c2                	add    %eax,%edx
80100c91:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c97:	39 c2                	cmp    %eax,%edx
80100c99:	0f 82 d6 02 00 00    	jb     80100f75 <exec+0x3f5>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c9f:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ca5:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cab:	01 d0                	add    %edx,%eax
80100cad:	83 ec 04             	sub    $0x4,%esp
80100cb0:	50                   	push   %eax
80100cb1:	ff 75 e0             	push   -0x20(%ebp)
80100cb4:	ff 75 d4             	push   -0x2c(%ebp)
80100cb7:	e8 38 6b 00 00       	call   801077f4 <allocuvm>
80100cbc:	83 c4 10             	add    $0x10,%esp
80100cbf:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cc2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cc6:	0f 84 ac 02 00 00    	je     80100f78 <exec+0x3f8>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100ccc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cd2:	25 ff 0f 00 00       	and    $0xfff,%eax
80100cd7:	85 c0                	test   %eax,%eax
80100cd9:	0f 85 9c 02 00 00    	jne    80100f7b <exec+0x3fb>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100cdf:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100ce5:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100ceb:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100cf1:	83 ec 0c             	sub    $0xc,%esp
80100cf4:	52                   	push   %edx
80100cf5:	50                   	push   %eax
80100cf6:	ff 75 d8             	push   -0x28(%ebp)
80100cf9:	51                   	push   %ecx
80100cfa:	ff 75 d4             	push   -0x2c(%ebp)
80100cfd:	e8 25 6a 00 00       	call   80107727 <loaduvm>
80100d02:	83 c4 20             	add    $0x20,%esp
80100d05:	85 c0                	test   %eax,%eax
80100d07:	0f 88 71 02 00 00    	js     80100f7e <exec+0x3fe>
80100d0d:	eb 01                	jmp    80100d10 <exec+0x190>
      continue;
80100d0f:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d10:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d14:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d17:	83 c0 20             	add    $0x20,%eax
80100d1a:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d1d:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100d24:	0f b7 c0             	movzwl %ax,%eax
80100d27:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d2a:	0f 8c 0f ff ff ff    	jl     80100c3f <exec+0xbf>
      goto bad;
  }
  iunlockput(ip);
80100d30:	83 ec 0c             	sub    $0xc,%esp
80100d33:	ff 75 d8             	push   -0x28(%ebp)
80100d36:	e8 e0 0e 00 00       	call   80101c1b <iunlockput>
80100d3b:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d3e:	e8 85 23 00 00       	call   801030c8 <end_op>
  ip = 0;
80100d43:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d4a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d4d:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d52:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d57:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d5d:	05 00 20 00 00       	add    $0x2000,%eax
80100d62:	83 ec 04             	sub    $0x4,%esp
80100d65:	50                   	push   %eax
80100d66:	ff 75 e0             	push   -0x20(%ebp)
80100d69:	ff 75 d4             	push   -0x2c(%ebp)
80100d6c:	e8 83 6a 00 00       	call   801077f4 <allocuvm>
80100d71:	83 c4 10             	add    $0x10,%esp
80100d74:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d77:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d7b:	0f 84 00 02 00 00    	je     80100f81 <exec+0x401>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d81:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d84:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d89:	83 ec 08             	sub    $0x8,%esp
80100d8c:	50                   	push   %eax
80100d8d:	ff 75 d4             	push   -0x2c(%ebp)
80100d90:	e8 c1 6c 00 00       	call   80107a56 <clearpteu>
80100d95:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100d98:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d9b:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d9e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100da5:	e9 96 00 00 00       	jmp    80100e40 <exec+0x2c0>
    if(argc >= MAXARG)
80100daa:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100dae:	0f 87 d0 01 00 00    	ja     80100f84 <exec+0x404>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100db4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100db7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dbe:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dc1:	01 d0                	add    %edx,%eax
80100dc3:	8b 00                	mov    (%eax),%eax
80100dc5:	83 ec 0c             	sub    $0xc,%esp
80100dc8:	50                   	push   %eax
80100dc9:	e8 62 3f 00 00       	call   80104d30 <strlen>
80100dce:	83 c4 10             	add    $0x10,%esp
80100dd1:	89 c2                	mov    %eax,%edx
80100dd3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dd6:	29 d0                	sub    %edx,%eax
80100dd8:	83 e8 01             	sub    $0x1,%eax
80100ddb:	83 e0 fc             	and    $0xfffffffc,%eax
80100dde:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100de1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100de4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100deb:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dee:	01 d0                	add    %edx,%eax
80100df0:	8b 00                	mov    (%eax),%eax
80100df2:	83 ec 0c             	sub    $0xc,%esp
80100df5:	50                   	push   %eax
80100df6:	e8 35 3f 00 00       	call   80104d30 <strlen>
80100dfb:	83 c4 10             	add    $0x10,%esp
80100dfe:	83 c0 01             	add    $0x1,%eax
80100e01:	89 c2                	mov    %eax,%edx
80100e03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e06:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100e0d:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e10:	01 c8                	add    %ecx,%eax
80100e12:	8b 00                	mov    (%eax),%eax
80100e14:	52                   	push   %edx
80100e15:	50                   	push   %eax
80100e16:	ff 75 dc             	push   -0x24(%ebp)
80100e19:	ff 75 d4             	push   -0x2c(%ebp)
80100e1c:	e8 d4 6d 00 00       	call   80107bf5 <copyout>
80100e21:	83 c4 10             	add    $0x10,%esp
80100e24:	85 c0                	test   %eax,%eax
80100e26:	0f 88 5b 01 00 00    	js     80100f87 <exec+0x407>
      goto bad;
    ustack[3+argc] = sp;
80100e2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e2f:	8d 50 03             	lea    0x3(%eax),%edx
80100e32:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e35:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e3c:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e43:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e4a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e4d:	01 d0                	add    %edx,%eax
80100e4f:	8b 00                	mov    (%eax),%eax
80100e51:	85 c0                	test   %eax,%eax
80100e53:	0f 85 51 ff ff ff    	jne    80100daa <exec+0x22a>
  }
  ustack[3+argc] = 0;
80100e59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e5c:	83 c0 03             	add    $0x3,%eax
80100e5f:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100e66:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e6a:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100e71:	ff ff ff 
  ustack[1] = argc;
80100e74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e77:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e80:	83 c0 01             	add    $0x1,%eax
80100e83:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e8a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e8d:	29 d0                	sub    %edx,%eax
80100e8f:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100e95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e98:	83 c0 04             	add    $0x4,%eax
80100e9b:	c1 e0 02             	shl    $0x2,%eax
80100e9e:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100ea1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ea4:	83 c0 04             	add    $0x4,%eax
80100ea7:	c1 e0 02             	shl    $0x2,%eax
80100eaa:	50                   	push   %eax
80100eab:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100eb1:	50                   	push   %eax
80100eb2:	ff 75 dc             	push   -0x24(%ebp)
80100eb5:	ff 75 d4             	push   -0x2c(%ebp)
80100eb8:	e8 38 6d 00 00       	call   80107bf5 <copyout>
80100ebd:	83 c4 10             	add    $0x10,%esp
80100ec0:	85 c0                	test   %eax,%eax
80100ec2:	0f 88 c2 00 00 00    	js     80100f8a <exec+0x40a>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100ec8:	8b 45 08             	mov    0x8(%ebp),%eax
80100ecb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ed1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100ed4:	eb 17                	jmp    80100eed <exec+0x36d>
    if(*s == '/')
80100ed6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ed9:	0f b6 00             	movzbl (%eax),%eax
80100edc:	3c 2f                	cmp    $0x2f,%al
80100ede:	75 09                	jne    80100ee9 <exec+0x369>
      last = s+1;
80100ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ee3:	83 c0 01             	add    $0x1,%eax
80100ee6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100ee9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ef0:	0f b6 00             	movzbl (%eax),%eax
80100ef3:	84 c0                	test   %al,%al
80100ef5:	75 df                	jne    80100ed6 <exec+0x356>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100ef7:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100efa:	83 c0 6c             	add    $0x6c,%eax
80100efd:	83 ec 04             	sub    $0x4,%esp
80100f00:	6a 10                	push   $0x10
80100f02:	ff 75 f0             	push   -0x10(%ebp)
80100f05:	50                   	push   %eax
80100f06:	e8 da 3d 00 00       	call   80104ce5 <safestrcpy>
80100f0b:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f0e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f11:	8b 40 04             	mov    0x4(%eax),%eax
80100f14:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f17:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f1a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f1d:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f20:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f23:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f26:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f28:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f2b:	8b 40 18             	mov    0x18(%eax),%eax
80100f2e:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f34:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f37:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f3a:	8b 40 18             	mov    0x18(%eax),%eax
80100f3d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f40:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f43:	83 ec 0c             	sub    $0xc,%esp
80100f46:	ff 75 d0             	push   -0x30(%ebp)
80100f49:	e8 ca 65 00 00       	call   80107518 <switchuvm>
80100f4e:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f51:	83 ec 0c             	sub    $0xc,%esp
80100f54:	ff 75 cc             	push   -0x34(%ebp)
80100f57:	e8 61 6a 00 00       	call   801079bd <freevm>
80100f5c:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f5f:	b8 00 00 00 00       	mov    $0x0,%eax
80100f64:	eb 57                	jmp    80100fbd <exec+0x43d>
    goto bad;
80100f66:	90                   	nop
80100f67:	eb 22                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f69:	90                   	nop
80100f6a:	eb 1f                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f6c:	90                   	nop
80100f6d:	eb 1c                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f6f:	90                   	nop
80100f70:	eb 19                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f72:	90                   	nop
80100f73:	eb 16                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f75:	90                   	nop
80100f76:	eb 13                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f78:	90                   	nop
80100f79:	eb 10                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f7b:	90                   	nop
80100f7c:	eb 0d                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f7e:	90                   	nop
80100f7f:	eb 0a                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f81:	90                   	nop
80100f82:	eb 07                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f84:	90                   	nop
80100f85:	eb 04                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f87:	90                   	nop
80100f88:	eb 01                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f8a:	90                   	nop

 bad:
  if(pgdir)
80100f8b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f8f:	74 0e                	je     80100f9f <exec+0x41f>
    freevm(pgdir);
80100f91:	83 ec 0c             	sub    $0xc,%esp
80100f94:	ff 75 d4             	push   -0x2c(%ebp)
80100f97:	e8 21 6a 00 00       	call   801079bd <freevm>
80100f9c:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f9f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fa3:	74 13                	je     80100fb8 <exec+0x438>
    iunlockput(ip);
80100fa5:	83 ec 0c             	sub    $0xc,%esp
80100fa8:	ff 75 d8             	push   -0x28(%ebp)
80100fab:	e8 6b 0c 00 00       	call   80101c1b <iunlockput>
80100fb0:	83 c4 10             	add    $0x10,%esp
    end_op();
80100fb3:	e8 10 21 00 00       	call   801030c8 <end_op>
  }
  return -1;
80100fb8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fbd:	c9                   	leave  
80100fbe:	c3                   	ret    

80100fbf <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fbf:	55                   	push   %ebp
80100fc0:	89 e5                	mov    %esp,%ebp
80100fc2:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100fc5:	83 ec 08             	sub    $0x8,%esp
80100fc8:	68 a1 a1 10 80       	push   $0x8010a1a1
80100fcd:	68 a0 1a 19 80       	push   $0x80191aa0
80100fd2:	e8 73 38 00 00       	call   8010484a <initlock>
80100fd7:	83 c4 10             	add    $0x10,%esp
}
80100fda:	90                   	nop
80100fdb:	c9                   	leave  
80100fdc:	c3                   	ret    

80100fdd <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fdd:	55                   	push   %ebp
80100fde:	89 e5                	mov    %esp,%ebp
80100fe0:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fe3:	83 ec 0c             	sub    $0xc,%esp
80100fe6:	68 a0 1a 19 80       	push   $0x80191aa0
80100feb:	e8 7c 38 00 00       	call   8010486c <acquire>
80100ff0:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100ff3:	c7 45 f4 d4 1a 19 80 	movl   $0x80191ad4,-0xc(%ebp)
80100ffa:	eb 2d                	jmp    80101029 <filealloc+0x4c>
    if(f->ref == 0){
80100ffc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fff:	8b 40 04             	mov    0x4(%eax),%eax
80101002:	85 c0                	test   %eax,%eax
80101004:	75 1f                	jne    80101025 <filealloc+0x48>
      f->ref = 1;
80101006:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101009:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101010:	83 ec 0c             	sub    $0xc,%esp
80101013:	68 a0 1a 19 80       	push   $0x80191aa0
80101018:	e8 bd 38 00 00       	call   801048da <release>
8010101d:	83 c4 10             	add    $0x10,%esp
      return f;
80101020:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101023:	eb 23                	jmp    80101048 <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101025:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101029:	b8 34 24 19 80       	mov    $0x80192434,%eax
8010102e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101031:	72 c9                	jb     80100ffc <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
80101033:	83 ec 0c             	sub    $0xc,%esp
80101036:	68 a0 1a 19 80       	push   $0x80191aa0
8010103b:	e8 9a 38 00 00       	call   801048da <release>
80101040:	83 c4 10             	add    $0x10,%esp
  return 0;
80101043:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101048:	c9                   	leave  
80101049:	c3                   	ret    

8010104a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010104a:	55                   	push   %ebp
8010104b:	89 e5                	mov    %esp,%ebp
8010104d:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101050:	83 ec 0c             	sub    $0xc,%esp
80101053:	68 a0 1a 19 80       	push   $0x80191aa0
80101058:	e8 0f 38 00 00       	call   8010486c <acquire>
8010105d:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101060:	8b 45 08             	mov    0x8(%ebp),%eax
80101063:	8b 40 04             	mov    0x4(%eax),%eax
80101066:	85 c0                	test   %eax,%eax
80101068:	7f 0d                	jg     80101077 <filedup+0x2d>
    panic("filedup");
8010106a:	83 ec 0c             	sub    $0xc,%esp
8010106d:	68 a8 a1 10 80       	push   $0x8010a1a8
80101072:	e8 32 f5 ff ff       	call   801005a9 <panic>
  f->ref++;
80101077:	8b 45 08             	mov    0x8(%ebp),%eax
8010107a:	8b 40 04             	mov    0x4(%eax),%eax
8010107d:	8d 50 01             	lea    0x1(%eax),%edx
80101080:	8b 45 08             	mov    0x8(%ebp),%eax
80101083:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101086:	83 ec 0c             	sub    $0xc,%esp
80101089:	68 a0 1a 19 80       	push   $0x80191aa0
8010108e:	e8 47 38 00 00       	call   801048da <release>
80101093:	83 c4 10             	add    $0x10,%esp
  return f;
80101096:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101099:	c9                   	leave  
8010109a:	c3                   	ret    

8010109b <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010109b:	55                   	push   %ebp
8010109c:	89 e5                	mov    %esp,%ebp
8010109e:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010a1:	83 ec 0c             	sub    $0xc,%esp
801010a4:	68 a0 1a 19 80       	push   $0x80191aa0
801010a9:	e8 be 37 00 00       	call   8010486c <acquire>
801010ae:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010b1:	8b 45 08             	mov    0x8(%ebp),%eax
801010b4:	8b 40 04             	mov    0x4(%eax),%eax
801010b7:	85 c0                	test   %eax,%eax
801010b9:	7f 0d                	jg     801010c8 <fileclose+0x2d>
    panic("fileclose");
801010bb:	83 ec 0c             	sub    $0xc,%esp
801010be:	68 b0 a1 10 80       	push   $0x8010a1b0
801010c3:	e8 e1 f4 ff ff       	call   801005a9 <panic>
  if(--f->ref > 0){
801010c8:	8b 45 08             	mov    0x8(%ebp),%eax
801010cb:	8b 40 04             	mov    0x4(%eax),%eax
801010ce:	8d 50 ff             	lea    -0x1(%eax),%edx
801010d1:	8b 45 08             	mov    0x8(%ebp),%eax
801010d4:	89 50 04             	mov    %edx,0x4(%eax)
801010d7:	8b 45 08             	mov    0x8(%ebp),%eax
801010da:	8b 40 04             	mov    0x4(%eax),%eax
801010dd:	85 c0                	test   %eax,%eax
801010df:	7e 15                	jle    801010f6 <fileclose+0x5b>
    release(&ftable.lock);
801010e1:	83 ec 0c             	sub    $0xc,%esp
801010e4:	68 a0 1a 19 80       	push   $0x80191aa0
801010e9:	e8 ec 37 00 00       	call   801048da <release>
801010ee:	83 c4 10             	add    $0x10,%esp
801010f1:	e9 8b 00 00 00       	jmp    80101181 <fileclose+0xe6>
    return;
  }
  ff = *f;
801010f6:	8b 45 08             	mov    0x8(%ebp),%eax
801010f9:	8b 10                	mov    (%eax),%edx
801010fb:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010fe:	8b 50 04             	mov    0x4(%eax),%edx
80101101:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101104:	8b 50 08             	mov    0x8(%eax),%edx
80101107:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010110a:	8b 50 0c             	mov    0xc(%eax),%edx
8010110d:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101110:	8b 50 10             	mov    0x10(%eax),%edx
80101113:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101116:	8b 40 14             	mov    0x14(%eax),%eax
80101119:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010111c:	8b 45 08             	mov    0x8(%ebp),%eax
8010111f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101126:	8b 45 08             	mov    0x8(%ebp),%eax
80101129:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010112f:	83 ec 0c             	sub    $0xc,%esp
80101132:	68 a0 1a 19 80       	push   $0x80191aa0
80101137:	e8 9e 37 00 00       	call   801048da <release>
8010113c:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
8010113f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101142:	83 f8 01             	cmp    $0x1,%eax
80101145:	75 19                	jne    80101160 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
80101147:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010114b:	0f be d0             	movsbl %al,%edx
8010114e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101151:	83 ec 08             	sub    $0x8,%esp
80101154:	52                   	push   %edx
80101155:	50                   	push   %eax
80101156:	e8 64 25 00 00       	call   801036bf <pipeclose>
8010115b:	83 c4 10             	add    $0x10,%esp
8010115e:	eb 21                	jmp    80101181 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101160:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101163:	83 f8 02             	cmp    $0x2,%eax
80101166:	75 19                	jne    80101181 <fileclose+0xe6>
    begin_op();
80101168:	e8 cf 1e 00 00       	call   8010303c <begin_op>
    iput(ff.ip);
8010116d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101170:	83 ec 0c             	sub    $0xc,%esp
80101173:	50                   	push   %eax
80101174:	e8 d2 09 00 00       	call   80101b4b <iput>
80101179:	83 c4 10             	add    $0x10,%esp
    end_op();
8010117c:	e8 47 1f 00 00       	call   801030c8 <end_op>
  }
}
80101181:	c9                   	leave  
80101182:	c3                   	ret    

80101183 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101183:	55                   	push   %ebp
80101184:	89 e5                	mov    %esp,%ebp
80101186:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101189:	8b 45 08             	mov    0x8(%ebp),%eax
8010118c:	8b 00                	mov    (%eax),%eax
8010118e:	83 f8 02             	cmp    $0x2,%eax
80101191:	75 40                	jne    801011d3 <filestat+0x50>
    ilock(f->ip);
80101193:	8b 45 08             	mov    0x8(%ebp),%eax
80101196:	8b 40 10             	mov    0x10(%eax),%eax
80101199:	83 ec 0c             	sub    $0xc,%esp
8010119c:	50                   	push   %eax
8010119d:	e8 48 08 00 00       	call   801019ea <ilock>
801011a2:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011a5:	8b 45 08             	mov    0x8(%ebp),%eax
801011a8:	8b 40 10             	mov    0x10(%eax),%eax
801011ab:	83 ec 08             	sub    $0x8,%esp
801011ae:	ff 75 0c             	push   0xc(%ebp)
801011b1:	50                   	push   %eax
801011b2:	e8 d9 0c 00 00       	call   80101e90 <stati>
801011b7:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801011ba:	8b 45 08             	mov    0x8(%ebp),%eax
801011bd:	8b 40 10             	mov    0x10(%eax),%eax
801011c0:	83 ec 0c             	sub    $0xc,%esp
801011c3:	50                   	push   %eax
801011c4:	e8 34 09 00 00       	call   80101afd <iunlock>
801011c9:	83 c4 10             	add    $0x10,%esp
    return 0;
801011cc:	b8 00 00 00 00       	mov    $0x0,%eax
801011d1:	eb 05                	jmp    801011d8 <filestat+0x55>
  }
  return -1;
801011d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011d8:	c9                   	leave  
801011d9:	c3                   	ret    

801011da <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011da:	55                   	push   %ebp
801011db:	89 e5                	mov    %esp,%ebp
801011dd:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801011e0:	8b 45 08             	mov    0x8(%ebp),%eax
801011e3:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011e7:	84 c0                	test   %al,%al
801011e9:	75 0a                	jne    801011f5 <fileread+0x1b>
    return -1;
801011eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011f0:	e9 9b 00 00 00       	jmp    80101290 <fileread+0xb6>
  if(f->type == FD_PIPE)
801011f5:	8b 45 08             	mov    0x8(%ebp),%eax
801011f8:	8b 00                	mov    (%eax),%eax
801011fa:	83 f8 01             	cmp    $0x1,%eax
801011fd:	75 1a                	jne    80101219 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801011ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101202:	8b 40 0c             	mov    0xc(%eax),%eax
80101205:	83 ec 04             	sub    $0x4,%esp
80101208:	ff 75 10             	push   0x10(%ebp)
8010120b:	ff 75 0c             	push   0xc(%ebp)
8010120e:	50                   	push   %eax
8010120f:	e8 58 26 00 00       	call   8010386c <piperead>
80101214:	83 c4 10             	add    $0x10,%esp
80101217:	eb 77                	jmp    80101290 <fileread+0xb6>
  if(f->type == FD_INODE){
80101219:	8b 45 08             	mov    0x8(%ebp),%eax
8010121c:	8b 00                	mov    (%eax),%eax
8010121e:	83 f8 02             	cmp    $0x2,%eax
80101221:	75 60                	jne    80101283 <fileread+0xa9>
    ilock(f->ip);
80101223:	8b 45 08             	mov    0x8(%ebp),%eax
80101226:	8b 40 10             	mov    0x10(%eax),%eax
80101229:	83 ec 0c             	sub    $0xc,%esp
8010122c:	50                   	push   %eax
8010122d:	e8 b8 07 00 00       	call   801019ea <ilock>
80101232:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101235:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101238:	8b 45 08             	mov    0x8(%ebp),%eax
8010123b:	8b 50 14             	mov    0x14(%eax),%edx
8010123e:	8b 45 08             	mov    0x8(%ebp),%eax
80101241:	8b 40 10             	mov    0x10(%eax),%eax
80101244:	51                   	push   %ecx
80101245:	52                   	push   %edx
80101246:	ff 75 0c             	push   0xc(%ebp)
80101249:	50                   	push   %eax
8010124a:	e8 87 0c 00 00       	call   80101ed6 <readi>
8010124f:	83 c4 10             	add    $0x10,%esp
80101252:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101255:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101259:	7e 11                	jle    8010126c <fileread+0x92>
      f->off += r;
8010125b:	8b 45 08             	mov    0x8(%ebp),%eax
8010125e:	8b 50 14             	mov    0x14(%eax),%edx
80101261:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101264:	01 c2                	add    %eax,%edx
80101266:	8b 45 08             	mov    0x8(%ebp),%eax
80101269:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010126c:	8b 45 08             	mov    0x8(%ebp),%eax
8010126f:	8b 40 10             	mov    0x10(%eax),%eax
80101272:	83 ec 0c             	sub    $0xc,%esp
80101275:	50                   	push   %eax
80101276:	e8 82 08 00 00       	call   80101afd <iunlock>
8010127b:	83 c4 10             	add    $0x10,%esp
    return r;
8010127e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101281:	eb 0d                	jmp    80101290 <fileread+0xb6>
  }
  panic("fileread");
80101283:	83 ec 0c             	sub    $0xc,%esp
80101286:	68 ba a1 10 80       	push   $0x8010a1ba
8010128b:	e8 19 f3 ff ff       	call   801005a9 <panic>
}
80101290:	c9                   	leave  
80101291:	c3                   	ret    

80101292 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101292:	55                   	push   %ebp
80101293:	89 e5                	mov    %esp,%ebp
80101295:	53                   	push   %ebx
80101296:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101299:	8b 45 08             	mov    0x8(%ebp),%eax
8010129c:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012a0:	84 c0                	test   %al,%al
801012a2:	75 0a                	jne    801012ae <filewrite+0x1c>
    return -1;
801012a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012a9:	e9 1b 01 00 00       	jmp    801013c9 <filewrite+0x137>
  if(f->type == FD_PIPE)
801012ae:	8b 45 08             	mov    0x8(%ebp),%eax
801012b1:	8b 00                	mov    (%eax),%eax
801012b3:	83 f8 01             	cmp    $0x1,%eax
801012b6:	75 1d                	jne    801012d5 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
801012b8:	8b 45 08             	mov    0x8(%ebp),%eax
801012bb:	8b 40 0c             	mov    0xc(%eax),%eax
801012be:	83 ec 04             	sub    $0x4,%esp
801012c1:	ff 75 10             	push   0x10(%ebp)
801012c4:	ff 75 0c             	push   0xc(%ebp)
801012c7:	50                   	push   %eax
801012c8:	e8 9d 24 00 00       	call   8010376a <pipewrite>
801012cd:	83 c4 10             	add    $0x10,%esp
801012d0:	e9 f4 00 00 00       	jmp    801013c9 <filewrite+0x137>
  if(f->type == FD_INODE){
801012d5:	8b 45 08             	mov    0x8(%ebp),%eax
801012d8:	8b 00                	mov    (%eax),%eax
801012da:	83 f8 02             	cmp    $0x2,%eax
801012dd:	0f 85 d9 00 00 00    	jne    801013bc <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801012e3:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801012ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012f1:	e9 a3 00 00 00       	jmp    80101399 <filewrite+0x107>
      int n1 = n - i;
801012f6:	8b 45 10             	mov    0x10(%ebp),%eax
801012f9:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101302:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101305:	7e 06                	jle    8010130d <filewrite+0x7b>
        n1 = max;
80101307:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010130a:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010130d:	e8 2a 1d 00 00       	call   8010303c <begin_op>
      ilock(f->ip);
80101312:	8b 45 08             	mov    0x8(%ebp),%eax
80101315:	8b 40 10             	mov    0x10(%eax),%eax
80101318:	83 ec 0c             	sub    $0xc,%esp
8010131b:	50                   	push   %eax
8010131c:	e8 c9 06 00 00       	call   801019ea <ilock>
80101321:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101324:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101327:	8b 45 08             	mov    0x8(%ebp),%eax
8010132a:	8b 50 14             	mov    0x14(%eax),%edx
8010132d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101330:	8b 45 0c             	mov    0xc(%ebp),%eax
80101333:	01 c3                	add    %eax,%ebx
80101335:	8b 45 08             	mov    0x8(%ebp),%eax
80101338:	8b 40 10             	mov    0x10(%eax),%eax
8010133b:	51                   	push   %ecx
8010133c:	52                   	push   %edx
8010133d:	53                   	push   %ebx
8010133e:	50                   	push   %eax
8010133f:	e8 e7 0c 00 00       	call   8010202b <writei>
80101344:	83 c4 10             	add    $0x10,%esp
80101347:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010134a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010134e:	7e 11                	jle    80101361 <filewrite+0xcf>
        f->off += r;
80101350:	8b 45 08             	mov    0x8(%ebp),%eax
80101353:	8b 50 14             	mov    0x14(%eax),%edx
80101356:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101359:	01 c2                	add    %eax,%edx
8010135b:	8b 45 08             	mov    0x8(%ebp),%eax
8010135e:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101361:	8b 45 08             	mov    0x8(%ebp),%eax
80101364:	8b 40 10             	mov    0x10(%eax),%eax
80101367:	83 ec 0c             	sub    $0xc,%esp
8010136a:	50                   	push   %eax
8010136b:	e8 8d 07 00 00       	call   80101afd <iunlock>
80101370:	83 c4 10             	add    $0x10,%esp
      end_op();
80101373:	e8 50 1d 00 00       	call   801030c8 <end_op>

      if(r < 0)
80101378:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010137c:	78 29                	js     801013a7 <filewrite+0x115>
        break;
      if(r != n1)
8010137e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101381:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101384:	74 0d                	je     80101393 <filewrite+0x101>
        panic("short filewrite");
80101386:	83 ec 0c             	sub    $0xc,%esp
80101389:	68 c3 a1 10 80       	push   $0x8010a1c3
8010138e:	e8 16 f2 ff ff       	call   801005a9 <panic>
      i += r;
80101393:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101396:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
80101399:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010139c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010139f:	0f 8c 51 ff ff ff    	jl     801012f6 <filewrite+0x64>
801013a5:	eb 01                	jmp    801013a8 <filewrite+0x116>
        break;
801013a7:	90                   	nop
    }
    return i == n ? n : -1;
801013a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013ab:	3b 45 10             	cmp    0x10(%ebp),%eax
801013ae:	75 05                	jne    801013b5 <filewrite+0x123>
801013b0:	8b 45 10             	mov    0x10(%ebp),%eax
801013b3:	eb 14                	jmp    801013c9 <filewrite+0x137>
801013b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013ba:	eb 0d                	jmp    801013c9 <filewrite+0x137>
  }
  panic("filewrite");
801013bc:	83 ec 0c             	sub    $0xc,%esp
801013bf:	68 d3 a1 10 80       	push   $0x8010a1d3
801013c4:	e8 e0 f1 ff ff       	call   801005a9 <panic>
}
801013c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013cc:	c9                   	leave  
801013cd:	c3                   	ret    

801013ce <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013ce:	55                   	push   %ebp
801013cf:	89 e5                	mov    %esp,%ebp
801013d1:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801013d4:	8b 45 08             	mov    0x8(%ebp),%eax
801013d7:	83 ec 08             	sub    $0x8,%esp
801013da:	6a 01                	push   $0x1
801013dc:	50                   	push   %eax
801013dd:	e8 1f ee ff ff       	call   80100201 <bread>
801013e2:	83 c4 10             	add    $0x10,%esp
801013e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013eb:	83 c0 5c             	add    $0x5c,%eax
801013ee:	83 ec 04             	sub    $0x4,%esp
801013f1:	6a 1c                	push   $0x1c
801013f3:	50                   	push   %eax
801013f4:	ff 75 0c             	push   0xc(%ebp)
801013f7:	e8 a5 37 00 00       	call   80104ba1 <memmove>
801013fc:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013ff:	83 ec 0c             	sub    $0xc,%esp
80101402:	ff 75 f4             	push   -0xc(%ebp)
80101405:	e8 79 ee ff ff       	call   80100283 <brelse>
8010140a:	83 c4 10             	add    $0x10,%esp
}
8010140d:	90                   	nop
8010140e:	c9                   	leave  
8010140f:	c3                   	ret    

80101410 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101410:	55                   	push   %ebp
80101411:	89 e5                	mov    %esp,%ebp
80101413:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101416:	8b 55 0c             	mov    0xc(%ebp),%edx
80101419:	8b 45 08             	mov    0x8(%ebp),%eax
8010141c:	83 ec 08             	sub    $0x8,%esp
8010141f:	52                   	push   %edx
80101420:	50                   	push   %eax
80101421:	e8 db ed ff ff       	call   80100201 <bread>
80101426:	83 c4 10             	add    $0x10,%esp
80101429:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010142c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010142f:	83 c0 5c             	add    $0x5c,%eax
80101432:	83 ec 04             	sub    $0x4,%esp
80101435:	68 00 02 00 00       	push   $0x200
8010143a:	6a 00                	push   $0x0
8010143c:	50                   	push   %eax
8010143d:	e8 a0 36 00 00       	call   80104ae2 <memset>
80101442:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101445:	83 ec 0c             	sub    $0xc,%esp
80101448:	ff 75 f4             	push   -0xc(%ebp)
8010144b:	e8 25 1e 00 00       	call   80103275 <log_write>
80101450:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101453:	83 ec 0c             	sub    $0xc,%esp
80101456:	ff 75 f4             	push   -0xc(%ebp)
80101459:	e8 25 ee ff ff       	call   80100283 <brelse>
8010145e:	83 c4 10             	add    $0x10,%esp
}
80101461:	90                   	nop
80101462:	c9                   	leave  
80101463:	c3                   	ret    

80101464 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101464:	55                   	push   %ebp
80101465:	89 e5                	mov    %esp,%ebp
80101467:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
8010146a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101471:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101478:	e9 0b 01 00 00       	jmp    80101588 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
8010147d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101480:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101486:	85 c0                	test   %eax,%eax
80101488:	0f 48 c2             	cmovs  %edx,%eax
8010148b:	c1 f8 0c             	sar    $0xc,%eax
8010148e:	89 c2                	mov    %eax,%edx
80101490:	a1 58 24 19 80       	mov    0x80192458,%eax
80101495:	01 d0                	add    %edx,%eax
80101497:	83 ec 08             	sub    $0x8,%esp
8010149a:	50                   	push   %eax
8010149b:	ff 75 08             	push   0x8(%ebp)
8010149e:	e8 5e ed ff ff       	call   80100201 <bread>
801014a3:	83 c4 10             	add    $0x10,%esp
801014a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014a9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801014b0:	e9 9e 00 00 00       	jmp    80101553 <balloc+0xef>
      m = 1 << (bi % 8);
801014b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014b8:	83 e0 07             	and    $0x7,%eax
801014bb:	ba 01 00 00 00       	mov    $0x1,%edx
801014c0:	89 c1                	mov    %eax,%ecx
801014c2:	d3 e2                	shl    %cl,%edx
801014c4:	89 d0                	mov    %edx,%eax
801014c6:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014cc:	8d 50 07             	lea    0x7(%eax),%edx
801014cf:	85 c0                	test   %eax,%eax
801014d1:	0f 48 c2             	cmovs  %edx,%eax
801014d4:	c1 f8 03             	sar    $0x3,%eax
801014d7:	89 c2                	mov    %eax,%edx
801014d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014dc:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801014e1:	0f b6 c0             	movzbl %al,%eax
801014e4:	23 45 e8             	and    -0x18(%ebp),%eax
801014e7:	85 c0                	test   %eax,%eax
801014e9:	75 64                	jne    8010154f <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
801014eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014ee:	8d 50 07             	lea    0x7(%eax),%edx
801014f1:	85 c0                	test   %eax,%eax
801014f3:	0f 48 c2             	cmovs  %edx,%eax
801014f6:	c1 f8 03             	sar    $0x3,%eax
801014f9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014fc:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101501:	89 d1                	mov    %edx,%ecx
80101503:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101506:	09 ca                	or     %ecx,%edx
80101508:	89 d1                	mov    %edx,%ecx
8010150a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010150d:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101511:	83 ec 0c             	sub    $0xc,%esp
80101514:	ff 75 ec             	push   -0x14(%ebp)
80101517:	e8 59 1d 00 00       	call   80103275 <log_write>
8010151c:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
8010151f:	83 ec 0c             	sub    $0xc,%esp
80101522:	ff 75 ec             	push   -0x14(%ebp)
80101525:	e8 59 ed ff ff       	call   80100283 <brelse>
8010152a:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010152d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101530:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101533:	01 c2                	add    %eax,%edx
80101535:	8b 45 08             	mov    0x8(%ebp),%eax
80101538:	83 ec 08             	sub    $0x8,%esp
8010153b:	52                   	push   %edx
8010153c:	50                   	push   %eax
8010153d:	e8 ce fe ff ff       	call   80101410 <bzero>
80101542:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101545:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101548:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010154b:	01 d0                	add    %edx,%eax
8010154d:	eb 57                	jmp    801015a6 <balloc+0x142>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010154f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101553:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010155a:	7f 17                	jg     80101573 <balloc+0x10f>
8010155c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010155f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101562:	01 d0                	add    %edx,%eax
80101564:	89 c2                	mov    %eax,%edx
80101566:	a1 40 24 19 80       	mov    0x80192440,%eax
8010156b:	39 c2                	cmp    %eax,%edx
8010156d:	0f 82 42 ff ff ff    	jb     801014b5 <balloc+0x51>
      }
    }
    brelse(bp);
80101573:	83 ec 0c             	sub    $0xc,%esp
80101576:	ff 75 ec             	push   -0x14(%ebp)
80101579:	e8 05 ed ff ff       	call   80100283 <brelse>
8010157e:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
80101581:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101588:	8b 15 40 24 19 80    	mov    0x80192440,%edx
8010158e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101591:	39 c2                	cmp    %eax,%edx
80101593:	0f 87 e4 fe ff ff    	ja     8010147d <balloc+0x19>
  }
  panic("balloc: out of blocks");
80101599:	83 ec 0c             	sub    $0xc,%esp
8010159c:	68 e0 a1 10 80       	push   $0x8010a1e0
801015a1:	e8 03 f0 ff ff       	call   801005a9 <panic>
}
801015a6:	c9                   	leave  
801015a7:	c3                   	ret    

801015a8 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801015a8:	55                   	push   %ebp
801015a9:	89 e5                	mov    %esp,%ebp
801015ab:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801015ae:	83 ec 08             	sub    $0x8,%esp
801015b1:	68 40 24 19 80       	push   $0x80192440
801015b6:	ff 75 08             	push   0x8(%ebp)
801015b9:	e8 10 fe ff ff       	call   801013ce <readsb>
801015be:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801015c4:	c1 e8 0c             	shr    $0xc,%eax
801015c7:	89 c2                	mov    %eax,%edx
801015c9:	a1 58 24 19 80       	mov    0x80192458,%eax
801015ce:	01 c2                	add    %eax,%edx
801015d0:	8b 45 08             	mov    0x8(%ebp),%eax
801015d3:	83 ec 08             	sub    $0x8,%esp
801015d6:	52                   	push   %edx
801015d7:	50                   	push   %eax
801015d8:	e8 24 ec ff ff       	call   80100201 <bread>
801015dd:	83 c4 10             	add    $0x10,%esp
801015e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801015e6:	25 ff 0f 00 00       	and    $0xfff,%eax
801015eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015f1:	83 e0 07             	and    $0x7,%eax
801015f4:	ba 01 00 00 00       	mov    $0x1,%edx
801015f9:	89 c1                	mov    %eax,%ecx
801015fb:	d3 e2                	shl    %cl,%edx
801015fd:	89 d0                	mov    %edx,%eax
801015ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101602:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101605:	8d 50 07             	lea    0x7(%eax),%edx
80101608:	85 c0                	test   %eax,%eax
8010160a:	0f 48 c2             	cmovs  %edx,%eax
8010160d:	c1 f8 03             	sar    $0x3,%eax
80101610:	89 c2                	mov    %eax,%edx
80101612:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101615:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
8010161a:	0f b6 c0             	movzbl %al,%eax
8010161d:	23 45 ec             	and    -0x14(%ebp),%eax
80101620:	85 c0                	test   %eax,%eax
80101622:	75 0d                	jne    80101631 <bfree+0x89>
    panic("freeing free block");
80101624:	83 ec 0c             	sub    $0xc,%esp
80101627:	68 f6 a1 10 80       	push   $0x8010a1f6
8010162c:	e8 78 ef ff ff       	call   801005a9 <panic>
  bp->data[bi/8] &= ~m;
80101631:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101634:	8d 50 07             	lea    0x7(%eax),%edx
80101637:	85 c0                	test   %eax,%eax
80101639:	0f 48 c2             	cmovs  %edx,%eax
8010163c:	c1 f8 03             	sar    $0x3,%eax
8010163f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101642:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101647:	89 d1                	mov    %edx,%ecx
80101649:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010164c:	f7 d2                	not    %edx
8010164e:	21 ca                	and    %ecx,%edx
80101650:	89 d1                	mov    %edx,%ecx
80101652:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101655:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101659:	83 ec 0c             	sub    $0xc,%esp
8010165c:	ff 75 f4             	push   -0xc(%ebp)
8010165f:	e8 11 1c 00 00       	call   80103275 <log_write>
80101664:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101667:	83 ec 0c             	sub    $0xc,%esp
8010166a:	ff 75 f4             	push   -0xc(%ebp)
8010166d:	e8 11 ec ff ff       	call   80100283 <brelse>
80101672:	83 c4 10             	add    $0x10,%esp
}
80101675:	90                   	nop
80101676:	c9                   	leave  
80101677:	c3                   	ret    

80101678 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101678:	55                   	push   %ebp
80101679:	89 e5                	mov    %esp,%ebp
8010167b:	57                   	push   %edi
8010167c:	56                   	push   %esi
8010167d:	53                   	push   %ebx
8010167e:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
80101681:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101688:	83 ec 08             	sub    $0x8,%esp
8010168b:	68 09 a2 10 80       	push   $0x8010a209
80101690:	68 60 24 19 80       	push   $0x80192460
80101695:	e8 b0 31 00 00       	call   8010484a <initlock>
8010169a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
8010169d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801016a4:	eb 2d                	jmp    801016d3 <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
801016a6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801016a9:	89 d0                	mov    %edx,%eax
801016ab:	c1 e0 03             	shl    $0x3,%eax
801016ae:	01 d0                	add    %edx,%eax
801016b0:	c1 e0 04             	shl    $0x4,%eax
801016b3:	83 c0 30             	add    $0x30,%eax
801016b6:	05 60 24 19 80       	add    $0x80192460,%eax
801016bb:	83 c0 10             	add    $0x10,%eax
801016be:	83 ec 08             	sub    $0x8,%esp
801016c1:	68 10 a2 10 80       	push   $0x8010a210
801016c6:	50                   	push   %eax
801016c7:	e8 21 30 00 00       	call   801046ed <initsleeplock>
801016cc:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016cf:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801016d3:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016d7:	7e cd                	jle    801016a6 <iinit+0x2e>
  }

  readsb(dev, &sb);
801016d9:	83 ec 08             	sub    $0x8,%esp
801016dc:	68 40 24 19 80       	push   $0x80192440
801016e1:	ff 75 08             	push   0x8(%ebp)
801016e4:	e8 e5 fc ff ff       	call   801013ce <readsb>
801016e9:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016ec:	a1 58 24 19 80       	mov    0x80192458,%eax
801016f1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801016f4:	8b 3d 54 24 19 80    	mov    0x80192454,%edi
801016fa:	8b 35 50 24 19 80    	mov    0x80192450,%esi
80101700:	8b 1d 4c 24 19 80    	mov    0x8019244c,%ebx
80101706:	8b 0d 48 24 19 80    	mov    0x80192448,%ecx
8010170c:	8b 15 44 24 19 80    	mov    0x80192444,%edx
80101712:	a1 40 24 19 80       	mov    0x80192440,%eax
80101717:	ff 75 d4             	push   -0x2c(%ebp)
8010171a:	57                   	push   %edi
8010171b:	56                   	push   %esi
8010171c:	53                   	push   %ebx
8010171d:	51                   	push   %ecx
8010171e:	52                   	push   %edx
8010171f:	50                   	push   %eax
80101720:	68 18 a2 10 80       	push   $0x8010a218
80101725:	e8 ca ec ff ff       	call   801003f4 <cprintf>
8010172a:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
8010172d:	90                   	nop
8010172e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101731:	5b                   	pop    %ebx
80101732:	5e                   	pop    %esi
80101733:	5f                   	pop    %edi
80101734:	5d                   	pop    %ebp
80101735:	c3                   	ret    

80101736 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101736:	55                   	push   %ebp
80101737:	89 e5                	mov    %esp,%ebp
80101739:	83 ec 28             	sub    $0x28,%esp
8010173c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010173f:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101743:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010174a:	e9 9e 00 00 00       	jmp    801017ed <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
8010174f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101752:	c1 e8 03             	shr    $0x3,%eax
80101755:	89 c2                	mov    %eax,%edx
80101757:	a1 54 24 19 80       	mov    0x80192454,%eax
8010175c:	01 d0                	add    %edx,%eax
8010175e:	83 ec 08             	sub    $0x8,%esp
80101761:	50                   	push   %eax
80101762:	ff 75 08             	push   0x8(%ebp)
80101765:	e8 97 ea ff ff       	call   80100201 <bread>
8010176a:	83 c4 10             	add    $0x10,%esp
8010176d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101770:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101773:	8d 50 5c             	lea    0x5c(%eax),%edx
80101776:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101779:	83 e0 07             	and    $0x7,%eax
8010177c:	c1 e0 06             	shl    $0x6,%eax
8010177f:	01 d0                	add    %edx,%eax
80101781:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101784:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101787:	0f b7 00             	movzwl (%eax),%eax
8010178a:	66 85 c0             	test   %ax,%ax
8010178d:	75 4c                	jne    801017db <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
8010178f:	83 ec 04             	sub    $0x4,%esp
80101792:	6a 40                	push   $0x40
80101794:	6a 00                	push   $0x0
80101796:	ff 75 ec             	push   -0x14(%ebp)
80101799:	e8 44 33 00 00       	call   80104ae2 <memset>
8010179e:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017a4:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017a8:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017ab:	83 ec 0c             	sub    $0xc,%esp
801017ae:	ff 75 f0             	push   -0x10(%ebp)
801017b1:	e8 bf 1a 00 00       	call   80103275 <log_write>
801017b6:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017b9:	83 ec 0c             	sub    $0xc,%esp
801017bc:	ff 75 f0             	push   -0x10(%ebp)
801017bf:	e8 bf ea ff ff       	call   80100283 <brelse>
801017c4:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ca:	83 ec 08             	sub    $0x8,%esp
801017cd:	50                   	push   %eax
801017ce:	ff 75 08             	push   0x8(%ebp)
801017d1:	e8 f8 00 00 00       	call   801018ce <iget>
801017d6:	83 c4 10             	add    $0x10,%esp
801017d9:	eb 30                	jmp    8010180b <ialloc+0xd5>
    }
    brelse(bp);
801017db:	83 ec 0c             	sub    $0xc,%esp
801017de:	ff 75 f0             	push   -0x10(%ebp)
801017e1:	e8 9d ea ff ff       	call   80100283 <brelse>
801017e6:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801017e9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801017ed:	8b 15 48 24 19 80    	mov    0x80192448,%edx
801017f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f6:	39 c2                	cmp    %eax,%edx
801017f8:	0f 87 51 ff ff ff    	ja     8010174f <ialloc+0x19>
  }
  panic("ialloc: no inodes");
801017fe:	83 ec 0c             	sub    $0xc,%esp
80101801:	68 6b a2 10 80       	push   $0x8010a26b
80101806:	e8 9e ed ff ff       	call   801005a9 <panic>
}
8010180b:	c9                   	leave  
8010180c:	c3                   	ret    

8010180d <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
8010180d:	55                   	push   %ebp
8010180e:	89 e5                	mov    %esp,%ebp
80101810:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101813:	8b 45 08             	mov    0x8(%ebp),%eax
80101816:	8b 40 04             	mov    0x4(%eax),%eax
80101819:	c1 e8 03             	shr    $0x3,%eax
8010181c:	89 c2                	mov    %eax,%edx
8010181e:	a1 54 24 19 80       	mov    0x80192454,%eax
80101823:	01 c2                	add    %eax,%edx
80101825:	8b 45 08             	mov    0x8(%ebp),%eax
80101828:	8b 00                	mov    (%eax),%eax
8010182a:	83 ec 08             	sub    $0x8,%esp
8010182d:	52                   	push   %edx
8010182e:	50                   	push   %eax
8010182f:	e8 cd e9 ff ff       	call   80100201 <bread>
80101834:	83 c4 10             	add    $0x10,%esp
80101837:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010183a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010183d:	8d 50 5c             	lea    0x5c(%eax),%edx
80101840:	8b 45 08             	mov    0x8(%ebp),%eax
80101843:	8b 40 04             	mov    0x4(%eax),%eax
80101846:	83 e0 07             	and    $0x7,%eax
80101849:	c1 e0 06             	shl    $0x6,%eax
8010184c:	01 d0                	add    %edx,%eax
8010184e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101851:	8b 45 08             	mov    0x8(%ebp),%eax
80101854:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101858:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010185b:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010185e:	8b 45 08             	mov    0x8(%ebp),%eax
80101861:	0f b7 50 52          	movzwl 0x52(%eax),%edx
80101865:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101868:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010186c:	8b 45 08             	mov    0x8(%ebp),%eax
8010186f:	0f b7 50 54          	movzwl 0x54(%eax),%edx
80101873:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101876:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010187a:	8b 45 08             	mov    0x8(%ebp),%eax
8010187d:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101881:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101884:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101888:	8b 45 08             	mov    0x8(%ebp),%eax
8010188b:	8b 50 58             	mov    0x58(%eax),%edx
8010188e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101891:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101894:	8b 45 08             	mov    0x8(%ebp),%eax
80101897:	8d 50 5c             	lea    0x5c(%eax),%edx
8010189a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010189d:	83 c0 0c             	add    $0xc,%eax
801018a0:	83 ec 04             	sub    $0x4,%esp
801018a3:	6a 34                	push   $0x34
801018a5:	52                   	push   %edx
801018a6:	50                   	push   %eax
801018a7:	e8 f5 32 00 00       	call   80104ba1 <memmove>
801018ac:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018af:	83 ec 0c             	sub    $0xc,%esp
801018b2:	ff 75 f4             	push   -0xc(%ebp)
801018b5:	e8 bb 19 00 00       	call   80103275 <log_write>
801018ba:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018bd:	83 ec 0c             	sub    $0xc,%esp
801018c0:	ff 75 f4             	push   -0xc(%ebp)
801018c3:	e8 bb e9 ff ff       	call   80100283 <brelse>
801018c8:	83 c4 10             	add    $0x10,%esp
}
801018cb:	90                   	nop
801018cc:	c9                   	leave  
801018cd:	c3                   	ret    

801018ce <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018ce:	55                   	push   %ebp
801018cf:	89 e5                	mov    %esp,%ebp
801018d1:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801018d4:	83 ec 0c             	sub    $0xc,%esp
801018d7:	68 60 24 19 80       	push   $0x80192460
801018dc:	e8 8b 2f 00 00       	call   8010486c <acquire>
801018e1:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801018e4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018eb:	c7 45 f4 94 24 19 80 	movl   $0x80192494,-0xc(%ebp)
801018f2:	eb 60                	jmp    80101954 <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801018f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f7:	8b 40 08             	mov    0x8(%eax),%eax
801018fa:	85 c0                	test   %eax,%eax
801018fc:	7e 39                	jle    80101937 <iget+0x69>
801018fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101901:	8b 00                	mov    (%eax),%eax
80101903:	39 45 08             	cmp    %eax,0x8(%ebp)
80101906:	75 2f                	jne    80101937 <iget+0x69>
80101908:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190b:	8b 40 04             	mov    0x4(%eax),%eax
8010190e:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101911:	75 24                	jne    80101937 <iget+0x69>
      ip->ref++;
80101913:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101916:	8b 40 08             	mov    0x8(%eax),%eax
80101919:	8d 50 01             	lea    0x1(%eax),%edx
8010191c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010191f:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101922:	83 ec 0c             	sub    $0xc,%esp
80101925:	68 60 24 19 80       	push   $0x80192460
8010192a:	e8 ab 2f 00 00       	call   801048da <release>
8010192f:	83 c4 10             	add    $0x10,%esp
      return ip;
80101932:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101935:	eb 77                	jmp    801019ae <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101937:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010193b:	75 10                	jne    8010194d <iget+0x7f>
8010193d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101940:	8b 40 08             	mov    0x8(%eax),%eax
80101943:	85 c0                	test   %eax,%eax
80101945:	75 06                	jne    8010194d <iget+0x7f>
      empty = ip;
80101947:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010194a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010194d:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101954:	81 7d f4 b4 40 19 80 	cmpl   $0x801940b4,-0xc(%ebp)
8010195b:	72 97                	jb     801018f4 <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010195d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101961:	75 0d                	jne    80101970 <iget+0xa2>
    panic("iget: no inodes");
80101963:	83 ec 0c             	sub    $0xc,%esp
80101966:	68 7d a2 10 80       	push   $0x8010a27d
8010196b:	e8 39 ec ff ff       	call   801005a9 <panic>

  ip = empty;
80101970:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101973:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101976:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101979:	8b 55 08             	mov    0x8(%ebp),%edx
8010197c:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
8010197e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101981:	8b 55 0c             	mov    0xc(%ebp),%edx
80101984:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101987:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010198a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101991:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101994:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
8010199b:	83 ec 0c             	sub    $0xc,%esp
8010199e:	68 60 24 19 80       	push   $0x80192460
801019a3:	e8 32 2f 00 00       	call   801048da <release>
801019a8:	83 c4 10             	add    $0x10,%esp

  return ip;
801019ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801019ae:	c9                   	leave  
801019af:	c3                   	ret    

801019b0 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801019b0:	55                   	push   %ebp
801019b1:	89 e5                	mov    %esp,%ebp
801019b3:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801019b6:	83 ec 0c             	sub    $0xc,%esp
801019b9:	68 60 24 19 80       	push   $0x80192460
801019be:	e8 a9 2e 00 00       	call   8010486c <acquire>
801019c3:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019c6:	8b 45 08             	mov    0x8(%ebp),%eax
801019c9:	8b 40 08             	mov    0x8(%eax),%eax
801019cc:	8d 50 01             	lea    0x1(%eax),%edx
801019cf:	8b 45 08             	mov    0x8(%ebp),%eax
801019d2:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019d5:	83 ec 0c             	sub    $0xc,%esp
801019d8:	68 60 24 19 80       	push   $0x80192460
801019dd:	e8 f8 2e 00 00       	call   801048da <release>
801019e2:	83 c4 10             	add    $0x10,%esp
  return ip;
801019e5:	8b 45 08             	mov    0x8(%ebp),%eax
}
801019e8:	c9                   	leave  
801019e9:	c3                   	ret    

801019ea <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801019ea:	55                   	push   %ebp
801019eb:	89 e5                	mov    %esp,%ebp
801019ed:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801019f0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019f4:	74 0a                	je     80101a00 <ilock+0x16>
801019f6:	8b 45 08             	mov    0x8(%ebp),%eax
801019f9:	8b 40 08             	mov    0x8(%eax),%eax
801019fc:	85 c0                	test   %eax,%eax
801019fe:	7f 0d                	jg     80101a0d <ilock+0x23>
    panic("ilock");
80101a00:	83 ec 0c             	sub    $0xc,%esp
80101a03:	68 8d a2 10 80       	push   $0x8010a28d
80101a08:	e8 9c eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a10:	83 c0 0c             	add    $0xc,%eax
80101a13:	83 ec 0c             	sub    $0xc,%esp
80101a16:	50                   	push   %eax
80101a17:	e8 0d 2d 00 00       	call   80104729 <acquiresleep>
80101a1c:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101a1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a22:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a25:	85 c0                	test   %eax,%eax
80101a27:	0f 85 cd 00 00 00    	jne    80101afa <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a30:	8b 40 04             	mov    0x4(%eax),%eax
80101a33:	c1 e8 03             	shr    $0x3,%eax
80101a36:	89 c2                	mov    %eax,%edx
80101a38:	a1 54 24 19 80       	mov    0x80192454,%eax
80101a3d:	01 c2                	add    %eax,%edx
80101a3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a42:	8b 00                	mov    (%eax),%eax
80101a44:	83 ec 08             	sub    $0x8,%esp
80101a47:	52                   	push   %edx
80101a48:	50                   	push   %eax
80101a49:	e8 b3 e7 ff ff       	call   80100201 <bread>
80101a4e:	83 c4 10             	add    $0x10,%esp
80101a51:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a57:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5d:	8b 40 04             	mov    0x4(%eax),%eax
80101a60:	83 e0 07             	and    $0x7,%eax
80101a63:	c1 e0 06             	shl    $0x6,%eax
80101a66:	01 d0                	add    %edx,%eax
80101a68:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a6e:	0f b7 10             	movzwl (%eax),%edx
80101a71:	8b 45 08             	mov    0x8(%ebp),%eax
80101a74:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101a78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a7b:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a82:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101a86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a89:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a90:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101a94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a97:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9e:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101aa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aa5:	8b 50 08             	mov    0x8(%eax),%edx
80101aa8:	8b 45 08             	mov    0x8(%ebp),%eax
80101aab:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101aae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ab1:	8d 50 0c             	lea    0xc(%eax),%edx
80101ab4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab7:	83 c0 5c             	add    $0x5c,%eax
80101aba:	83 ec 04             	sub    $0x4,%esp
80101abd:	6a 34                	push   $0x34
80101abf:	52                   	push   %edx
80101ac0:	50                   	push   %eax
80101ac1:	e8 db 30 00 00       	call   80104ba1 <memmove>
80101ac6:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ac9:	83 ec 0c             	sub    $0xc,%esp
80101acc:	ff 75 f4             	push   -0xc(%ebp)
80101acf:	e8 af e7 ff ff       	call   80100283 <brelse>
80101ad4:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101ad7:	8b 45 08             	mov    0x8(%ebp),%eax
80101ada:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101ae1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae4:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ae8:	66 85 c0             	test   %ax,%ax
80101aeb:	75 0d                	jne    80101afa <ilock+0x110>
      panic("ilock: no type");
80101aed:	83 ec 0c             	sub    $0xc,%esp
80101af0:	68 93 a2 10 80       	push   $0x8010a293
80101af5:	e8 af ea ff ff       	call   801005a9 <panic>
  }
}
80101afa:	90                   	nop
80101afb:	c9                   	leave  
80101afc:	c3                   	ret    

80101afd <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101afd:	55                   	push   %ebp
80101afe:	89 e5                	mov    %esp,%ebp
80101b00:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b03:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b07:	74 20                	je     80101b29 <iunlock+0x2c>
80101b09:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0c:	83 c0 0c             	add    $0xc,%eax
80101b0f:	83 ec 0c             	sub    $0xc,%esp
80101b12:	50                   	push   %eax
80101b13:	e8 c3 2c 00 00       	call   801047db <holdingsleep>
80101b18:	83 c4 10             	add    $0x10,%esp
80101b1b:	85 c0                	test   %eax,%eax
80101b1d:	74 0a                	je     80101b29 <iunlock+0x2c>
80101b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b22:	8b 40 08             	mov    0x8(%eax),%eax
80101b25:	85 c0                	test   %eax,%eax
80101b27:	7f 0d                	jg     80101b36 <iunlock+0x39>
    panic("iunlock");
80101b29:	83 ec 0c             	sub    $0xc,%esp
80101b2c:	68 a2 a2 10 80       	push   $0x8010a2a2
80101b31:	e8 73 ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b36:	8b 45 08             	mov    0x8(%ebp),%eax
80101b39:	83 c0 0c             	add    $0xc,%eax
80101b3c:	83 ec 0c             	sub    $0xc,%esp
80101b3f:	50                   	push   %eax
80101b40:	e8 48 2c 00 00       	call   8010478d <releasesleep>
80101b45:	83 c4 10             	add    $0x10,%esp
}
80101b48:	90                   	nop
80101b49:	c9                   	leave  
80101b4a:	c3                   	ret    

80101b4b <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b4b:	55                   	push   %ebp
80101b4c:	89 e5                	mov    %esp,%ebp
80101b4e:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101b51:	8b 45 08             	mov    0x8(%ebp),%eax
80101b54:	83 c0 0c             	add    $0xc,%eax
80101b57:	83 ec 0c             	sub    $0xc,%esp
80101b5a:	50                   	push   %eax
80101b5b:	e8 c9 2b 00 00       	call   80104729 <acquiresleep>
80101b60:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101b63:	8b 45 08             	mov    0x8(%ebp),%eax
80101b66:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b69:	85 c0                	test   %eax,%eax
80101b6b:	74 6a                	je     80101bd7 <iput+0x8c>
80101b6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b70:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101b74:	66 85 c0             	test   %ax,%ax
80101b77:	75 5e                	jne    80101bd7 <iput+0x8c>
    acquire(&icache.lock);
80101b79:	83 ec 0c             	sub    $0xc,%esp
80101b7c:	68 60 24 19 80       	push   $0x80192460
80101b81:	e8 e6 2c 00 00       	call   8010486c <acquire>
80101b86:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b89:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8c:	8b 40 08             	mov    0x8(%eax),%eax
80101b8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b92:	83 ec 0c             	sub    $0xc,%esp
80101b95:	68 60 24 19 80       	push   $0x80192460
80101b9a:	e8 3b 2d 00 00       	call   801048da <release>
80101b9f:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101ba2:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101ba6:	75 2f                	jne    80101bd7 <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101ba8:	83 ec 0c             	sub    $0xc,%esp
80101bab:	ff 75 08             	push   0x8(%ebp)
80101bae:	e8 ad 01 00 00       	call   80101d60 <itrunc>
80101bb3:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101bb6:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb9:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101bbf:	83 ec 0c             	sub    $0xc,%esp
80101bc2:	ff 75 08             	push   0x8(%ebp)
80101bc5:	e8 43 fc ff ff       	call   8010180d <iupdate>
80101bca:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101bcd:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd0:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101bd7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bda:	83 c0 0c             	add    $0xc,%eax
80101bdd:	83 ec 0c             	sub    $0xc,%esp
80101be0:	50                   	push   %eax
80101be1:	e8 a7 2b 00 00       	call   8010478d <releasesleep>
80101be6:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101be9:	83 ec 0c             	sub    $0xc,%esp
80101bec:	68 60 24 19 80       	push   $0x80192460
80101bf1:	e8 76 2c 00 00       	call   8010486c <acquire>
80101bf6:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101bf9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfc:	8b 40 08             	mov    0x8(%eax),%eax
80101bff:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c02:	8b 45 08             	mov    0x8(%ebp),%eax
80101c05:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c08:	83 ec 0c             	sub    $0xc,%esp
80101c0b:	68 60 24 19 80       	push   $0x80192460
80101c10:	e8 c5 2c 00 00       	call   801048da <release>
80101c15:	83 c4 10             	add    $0x10,%esp
}
80101c18:	90                   	nop
80101c19:	c9                   	leave  
80101c1a:	c3                   	ret    

80101c1b <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c1b:	55                   	push   %ebp
80101c1c:	89 e5                	mov    %esp,%ebp
80101c1e:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c21:	83 ec 0c             	sub    $0xc,%esp
80101c24:	ff 75 08             	push   0x8(%ebp)
80101c27:	e8 d1 fe ff ff       	call   80101afd <iunlock>
80101c2c:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c2f:	83 ec 0c             	sub    $0xc,%esp
80101c32:	ff 75 08             	push   0x8(%ebp)
80101c35:	e8 11 ff ff ff       	call   80101b4b <iput>
80101c3a:	83 c4 10             	add    $0x10,%esp
}
80101c3d:	90                   	nop
80101c3e:	c9                   	leave  
80101c3f:	c3                   	ret    

80101c40 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c40:	55                   	push   %ebp
80101c41:	89 e5                	mov    %esp,%ebp
80101c43:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c46:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c4a:	77 42                	ja     80101c8e <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101c4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c52:	83 c2 14             	add    $0x14,%edx
80101c55:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c59:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c5c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c60:	75 24                	jne    80101c86 <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c62:	8b 45 08             	mov    0x8(%ebp),%eax
80101c65:	8b 00                	mov    (%eax),%eax
80101c67:	83 ec 0c             	sub    $0xc,%esp
80101c6a:	50                   	push   %eax
80101c6b:	e8 f4 f7 ff ff       	call   80101464 <balloc>
80101c70:	83 c4 10             	add    $0x10,%esp
80101c73:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c76:	8b 45 08             	mov    0x8(%ebp),%eax
80101c79:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c7c:	8d 4a 14             	lea    0x14(%edx),%ecx
80101c7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c82:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c89:	e9 d0 00 00 00       	jmp    80101d5e <bmap+0x11e>
  }
  bn -= NDIRECT;
80101c8e:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c92:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c96:	0f 87 b5 00 00 00    	ja     80101d51 <bmap+0x111>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101c9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9f:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101ca5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ca8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cac:	75 20                	jne    80101cce <bmap+0x8e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101cae:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb1:	8b 00                	mov    (%eax),%eax
80101cb3:	83 ec 0c             	sub    $0xc,%esp
80101cb6:	50                   	push   %eax
80101cb7:	e8 a8 f7 ff ff       	call   80101464 <balloc>
80101cbc:	83 c4 10             	add    $0x10,%esp
80101cbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cc8:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101cce:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd1:	8b 00                	mov    (%eax),%eax
80101cd3:	83 ec 08             	sub    $0x8,%esp
80101cd6:	ff 75 f4             	push   -0xc(%ebp)
80101cd9:	50                   	push   %eax
80101cda:	e8 22 e5 ff ff       	call   80100201 <bread>
80101cdf:	83 c4 10             	add    $0x10,%esp
80101ce2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101ce5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ce8:	83 c0 5c             	add    $0x5c,%eax
80101ceb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cee:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cf1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cf8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cfb:	01 d0                	add    %edx,%eax
80101cfd:	8b 00                	mov    (%eax),%eax
80101cff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d02:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d06:	75 36                	jne    80101d3e <bmap+0xfe>
      a[bn] = addr = balloc(ip->dev);
80101d08:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0b:	8b 00                	mov    (%eax),%eax
80101d0d:	83 ec 0c             	sub    $0xc,%esp
80101d10:	50                   	push   %eax
80101d11:	e8 4e f7 ff ff       	call   80101464 <balloc>
80101d16:	83 c4 10             	add    $0x10,%esp
80101d19:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d1c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d1f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d26:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d29:	01 c2                	add    %eax,%edx
80101d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d2e:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d30:	83 ec 0c             	sub    $0xc,%esp
80101d33:	ff 75 f0             	push   -0x10(%ebp)
80101d36:	e8 3a 15 00 00       	call   80103275 <log_write>
80101d3b:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d3e:	83 ec 0c             	sub    $0xc,%esp
80101d41:	ff 75 f0             	push   -0x10(%ebp)
80101d44:	e8 3a e5 ff ff       	call   80100283 <brelse>
80101d49:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d4f:	eb 0d                	jmp    80101d5e <bmap+0x11e>
  }

  panic("bmap: out of range");
80101d51:	83 ec 0c             	sub    $0xc,%esp
80101d54:	68 aa a2 10 80       	push   $0x8010a2aa
80101d59:	e8 4b e8 ff ff       	call   801005a9 <panic>
}
80101d5e:	c9                   	leave  
80101d5f:	c3                   	ret    

80101d60 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d60:	55                   	push   %ebp
80101d61:	89 e5                	mov    %esp,%ebp
80101d63:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d6d:	eb 45                	jmp    80101db4 <itrunc+0x54>
    if(ip->addrs[i]){
80101d6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d72:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d75:	83 c2 14             	add    $0x14,%edx
80101d78:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d7c:	85 c0                	test   %eax,%eax
80101d7e:	74 30                	je     80101db0 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d80:	8b 45 08             	mov    0x8(%ebp),%eax
80101d83:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d86:	83 c2 14             	add    $0x14,%edx
80101d89:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d8d:	8b 55 08             	mov    0x8(%ebp),%edx
80101d90:	8b 12                	mov    (%edx),%edx
80101d92:	83 ec 08             	sub    $0x8,%esp
80101d95:	50                   	push   %eax
80101d96:	52                   	push   %edx
80101d97:	e8 0c f8 ff ff       	call   801015a8 <bfree>
80101d9c:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101d9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101da2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101da5:	83 c2 14             	add    $0x14,%edx
80101da8:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101daf:	00 
  for(i = 0; i < NDIRECT; i++){
80101db0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101db4:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101db8:	7e b5                	jle    80101d6f <itrunc+0xf>
    }
  }

  if(ip->addrs[NDIRECT]){
80101dba:	8b 45 08             	mov    0x8(%ebp),%eax
80101dbd:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101dc3:	85 c0                	test   %eax,%eax
80101dc5:	0f 84 aa 00 00 00    	je     80101e75 <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dcb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dce:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101dd4:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd7:	8b 00                	mov    (%eax),%eax
80101dd9:	83 ec 08             	sub    $0x8,%esp
80101ddc:	52                   	push   %edx
80101ddd:	50                   	push   %eax
80101dde:	e8 1e e4 ff ff       	call   80100201 <bread>
80101de3:	83 c4 10             	add    $0x10,%esp
80101de6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101de9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dec:	83 c0 5c             	add    $0x5c,%eax
80101def:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101df2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101df9:	eb 3c                	jmp    80101e37 <itrunc+0xd7>
      if(a[j])
80101dfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dfe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e05:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e08:	01 d0                	add    %edx,%eax
80101e0a:	8b 00                	mov    (%eax),%eax
80101e0c:	85 c0                	test   %eax,%eax
80101e0e:	74 23                	je     80101e33 <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101e10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e13:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e1d:	01 d0                	add    %edx,%eax
80101e1f:	8b 00                	mov    (%eax),%eax
80101e21:	8b 55 08             	mov    0x8(%ebp),%edx
80101e24:	8b 12                	mov    (%edx),%edx
80101e26:	83 ec 08             	sub    $0x8,%esp
80101e29:	50                   	push   %eax
80101e2a:	52                   	push   %edx
80101e2b:	e8 78 f7 ff ff       	call   801015a8 <bfree>
80101e30:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101e33:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e3a:	83 f8 7f             	cmp    $0x7f,%eax
80101e3d:	76 bc                	jbe    80101dfb <itrunc+0x9b>
    }
    brelse(bp);
80101e3f:	83 ec 0c             	sub    $0xc,%esp
80101e42:	ff 75 ec             	push   -0x14(%ebp)
80101e45:	e8 39 e4 ff ff       	call   80100283 <brelse>
80101e4a:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e50:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e56:	8b 55 08             	mov    0x8(%ebp),%edx
80101e59:	8b 12                	mov    (%edx),%edx
80101e5b:	83 ec 08             	sub    $0x8,%esp
80101e5e:	50                   	push   %eax
80101e5f:	52                   	push   %edx
80101e60:	e8 43 f7 ff ff       	call   801015a8 <bfree>
80101e65:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e68:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6b:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101e72:	00 00 00 
  }

  ip->size = 0;
80101e75:	8b 45 08             	mov    0x8(%ebp),%eax
80101e78:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101e7f:	83 ec 0c             	sub    $0xc,%esp
80101e82:	ff 75 08             	push   0x8(%ebp)
80101e85:	e8 83 f9 ff ff       	call   8010180d <iupdate>
80101e8a:	83 c4 10             	add    $0x10,%esp
}
80101e8d:	90                   	nop
80101e8e:	c9                   	leave  
80101e8f:	c3                   	ret    

80101e90 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101e90:	55                   	push   %ebp
80101e91:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e93:	8b 45 08             	mov    0x8(%ebp),%eax
80101e96:	8b 00                	mov    (%eax),%eax
80101e98:	89 c2                	mov    %eax,%edx
80101e9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e9d:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101ea0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea3:	8b 50 04             	mov    0x4(%eax),%edx
80101ea6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ea9:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101eac:	8b 45 08             	mov    0x8(%ebp),%eax
80101eaf:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101eb3:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb6:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101eb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebc:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101ec0:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ec3:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ec7:	8b 45 08             	mov    0x8(%ebp),%eax
80101eca:	8b 50 58             	mov    0x58(%eax),%edx
80101ecd:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed0:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ed3:	90                   	nop
80101ed4:	5d                   	pop    %ebp
80101ed5:	c3                   	ret    

80101ed6 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ed6:	55                   	push   %ebp
80101ed7:	89 e5                	mov    %esp,%ebp
80101ed9:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101edc:	8b 45 08             	mov    0x8(%ebp),%eax
80101edf:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ee3:	66 83 f8 03          	cmp    $0x3,%ax
80101ee7:	75 5c                	jne    80101f45 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101ee9:	8b 45 08             	mov    0x8(%ebp),%eax
80101eec:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101ef0:	66 85 c0             	test   %ax,%ax
80101ef3:	78 20                	js     80101f15 <readi+0x3f>
80101ef5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef8:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101efc:	66 83 f8 09          	cmp    $0x9,%ax
80101f00:	7f 13                	jg     80101f15 <readi+0x3f>
80101f02:	8b 45 08             	mov    0x8(%ebp),%eax
80101f05:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f09:	98                   	cwtl   
80101f0a:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f11:	85 c0                	test   %eax,%eax
80101f13:	75 0a                	jne    80101f1f <readi+0x49>
      return -1;
80101f15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f1a:	e9 0a 01 00 00       	jmp    80102029 <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f22:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f26:	98                   	cwtl   
80101f27:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f2e:	8b 55 14             	mov    0x14(%ebp),%edx
80101f31:	83 ec 04             	sub    $0x4,%esp
80101f34:	52                   	push   %edx
80101f35:	ff 75 0c             	push   0xc(%ebp)
80101f38:	ff 75 08             	push   0x8(%ebp)
80101f3b:	ff d0                	call   *%eax
80101f3d:	83 c4 10             	add    $0x10,%esp
80101f40:	e9 e4 00 00 00       	jmp    80102029 <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80101f45:	8b 45 08             	mov    0x8(%ebp),%eax
80101f48:	8b 40 58             	mov    0x58(%eax),%eax
80101f4b:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f4e:	77 0d                	ja     80101f5d <readi+0x87>
80101f50:	8b 55 10             	mov    0x10(%ebp),%edx
80101f53:	8b 45 14             	mov    0x14(%ebp),%eax
80101f56:	01 d0                	add    %edx,%eax
80101f58:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f5b:	76 0a                	jbe    80101f67 <readi+0x91>
    return -1;
80101f5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f62:	e9 c2 00 00 00       	jmp    80102029 <readi+0x153>
  if(off + n > ip->size)
80101f67:	8b 55 10             	mov    0x10(%ebp),%edx
80101f6a:	8b 45 14             	mov    0x14(%ebp),%eax
80101f6d:	01 c2                	add    %eax,%edx
80101f6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f72:	8b 40 58             	mov    0x58(%eax),%eax
80101f75:	39 c2                	cmp    %eax,%edx
80101f77:	76 0c                	jbe    80101f85 <readi+0xaf>
    n = ip->size - off;
80101f79:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7c:	8b 40 58             	mov    0x58(%eax),%eax
80101f7f:	2b 45 10             	sub    0x10(%ebp),%eax
80101f82:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f85:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f8c:	e9 89 00 00 00       	jmp    8010201a <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f91:	8b 45 10             	mov    0x10(%ebp),%eax
80101f94:	c1 e8 09             	shr    $0x9,%eax
80101f97:	83 ec 08             	sub    $0x8,%esp
80101f9a:	50                   	push   %eax
80101f9b:	ff 75 08             	push   0x8(%ebp)
80101f9e:	e8 9d fc ff ff       	call   80101c40 <bmap>
80101fa3:	83 c4 10             	add    $0x10,%esp
80101fa6:	8b 55 08             	mov    0x8(%ebp),%edx
80101fa9:	8b 12                	mov    (%edx),%edx
80101fab:	83 ec 08             	sub    $0x8,%esp
80101fae:	50                   	push   %eax
80101faf:	52                   	push   %edx
80101fb0:	e8 4c e2 ff ff       	call   80100201 <bread>
80101fb5:	83 c4 10             	add    $0x10,%esp
80101fb8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fbb:	8b 45 10             	mov    0x10(%ebp),%eax
80101fbe:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fc3:	ba 00 02 00 00       	mov    $0x200,%edx
80101fc8:	29 c2                	sub    %eax,%edx
80101fca:	8b 45 14             	mov    0x14(%ebp),%eax
80101fcd:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fd0:	39 c2                	cmp    %eax,%edx
80101fd2:	0f 46 c2             	cmovbe %edx,%eax
80101fd5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fdb:	8d 50 5c             	lea    0x5c(%eax),%edx
80101fde:	8b 45 10             	mov    0x10(%ebp),%eax
80101fe1:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fe6:	01 d0                	add    %edx,%eax
80101fe8:	83 ec 04             	sub    $0x4,%esp
80101feb:	ff 75 ec             	push   -0x14(%ebp)
80101fee:	50                   	push   %eax
80101fef:	ff 75 0c             	push   0xc(%ebp)
80101ff2:	e8 aa 2b 00 00       	call   80104ba1 <memmove>
80101ff7:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ffa:	83 ec 0c             	sub    $0xc,%esp
80101ffd:	ff 75 f0             	push   -0x10(%ebp)
80102000:	e8 7e e2 ff ff       	call   80100283 <brelse>
80102005:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102008:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010200b:	01 45 f4             	add    %eax,-0xc(%ebp)
8010200e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102011:	01 45 10             	add    %eax,0x10(%ebp)
80102014:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102017:	01 45 0c             	add    %eax,0xc(%ebp)
8010201a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010201d:	3b 45 14             	cmp    0x14(%ebp),%eax
80102020:	0f 82 6b ff ff ff    	jb     80101f91 <readi+0xbb>
  }
  return n;
80102026:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102029:	c9                   	leave  
8010202a:	c3                   	ret    

8010202b <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010202b:	55                   	push   %ebp
8010202c:	89 e5                	mov    %esp,%ebp
8010202e:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102031:	8b 45 08             	mov    0x8(%ebp),%eax
80102034:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102038:	66 83 f8 03          	cmp    $0x3,%ax
8010203c:	75 5c                	jne    8010209a <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010203e:	8b 45 08             	mov    0x8(%ebp),%eax
80102041:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102045:	66 85 c0             	test   %ax,%ax
80102048:	78 20                	js     8010206a <writei+0x3f>
8010204a:	8b 45 08             	mov    0x8(%ebp),%eax
8010204d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102051:	66 83 f8 09          	cmp    $0x9,%ax
80102055:	7f 13                	jg     8010206a <writei+0x3f>
80102057:	8b 45 08             	mov    0x8(%ebp),%eax
8010205a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010205e:	98                   	cwtl   
8010205f:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
80102066:	85 c0                	test   %eax,%eax
80102068:	75 0a                	jne    80102074 <writei+0x49>
      return -1;
8010206a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010206f:	e9 3b 01 00 00       	jmp    801021af <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
80102074:	8b 45 08             	mov    0x8(%ebp),%eax
80102077:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010207b:	98                   	cwtl   
8010207c:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
80102083:	8b 55 14             	mov    0x14(%ebp),%edx
80102086:	83 ec 04             	sub    $0x4,%esp
80102089:	52                   	push   %edx
8010208a:	ff 75 0c             	push   0xc(%ebp)
8010208d:	ff 75 08             	push   0x8(%ebp)
80102090:	ff d0                	call   *%eax
80102092:	83 c4 10             	add    $0x10,%esp
80102095:	e9 15 01 00 00       	jmp    801021af <writei+0x184>
  }

  if(off > ip->size || off + n < off)
8010209a:	8b 45 08             	mov    0x8(%ebp),%eax
8010209d:	8b 40 58             	mov    0x58(%eax),%eax
801020a0:	39 45 10             	cmp    %eax,0x10(%ebp)
801020a3:	77 0d                	ja     801020b2 <writei+0x87>
801020a5:	8b 55 10             	mov    0x10(%ebp),%edx
801020a8:	8b 45 14             	mov    0x14(%ebp),%eax
801020ab:	01 d0                	add    %edx,%eax
801020ad:	39 45 10             	cmp    %eax,0x10(%ebp)
801020b0:	76 0a                	jbe    801020bc <writei+0x91>
    return -1;
801020b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020b7:	e9 f3 00 00 00       	jmp    801021af <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
801020bc:	8b 55 10             	mov    0x10(%ebp),%edx
801020bf:	8b 45 14             	mov    0x14(%ebp),%eax
801020c2:	01 d0                	add    %edx,%eax
801020c4:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020c9:	76 0a                	jbe    801020d5 <writei+0xaa>
    return -1;
801020cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020d0:	e9 da 00 00 00       	jmp    801021af <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020dc:	e9 97 00 00 00       	jmp    80102178 <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020e1:	8b 45 10             	mov    0x10(%ebp),%eax
801020e4:	c1 e8 09             	shr    $0x9,%eax
801020e7:	83 ec 08             	sub    $0x8,%esp
801020ea:	50                   	push   %eax
801020eb:	ff 75 08             	push   0x8(%ebp)
801020ee:	e8 4d fb ff ff       	call   80101c40 <bmap>
801020f3:	83 c4 10             	add    $0x10,%esp
801020f6:	8b 55 08             	mov    0x8(%ebp),%edx
801020f9:	8b 12                	mov    (%edx),%edx
801020fb:	83 ec 08             	sub    $0x8,%esp
801020fe:	50                   	push   %eax
801020ff:	52                   	push   %edx
80102100:	e8 fc e0 ff ff       	call   80100201 <bread>
80102105:	83 c4 10             	add    $0x10,%esp
80102108:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010210b:	8b 45 10             	mov    0x10(%ebp),%eax
8010210e:	25 ff 01 00 00       	and    $0x1ff,%eax
80102113:	ba 00 02 00 00       	mov    $0x200,%edx
80102118:	29 c2                	sub    %eax,%edx
8010211a:	8b 45 14             	mov    0x14(%ebp),%eax
8010211d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102120:	39 c2                	cmp    %eax,%edx
80102122:	0f 46 c2             	cmovbe %edx,%eax
80102125:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102128:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010212b:	8d 50 5c             	lea    0x5c(%eax),%edx
8010212e:	8b 45 10             	mov    0x10(%ebp),%eax
80102131:	25 ff 01 00 00       	and    $0x1ff,%eax
80102136:	01 d0                	add    %edx,%eax
80102138:	83 ec 04             	sub    $0x4,%esp
8010213b:	ff 75 ec             	push   -0x14(%ebp)
8010213e:	ff 75 0c             	push   0xc(%ebp)
80102141:	50                   	push   %eax
80102142:	e8 5a 2a 00 00       	call   80104ba1 <memmove>
80102147:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
8010214a:	83 ec 0c             	sub    $0xc,%esp
8010214d:	ff 75 f0             	push   -0x10(%ebp)
80102150:	e8 20 11 00 00       	call   80103275 <log_write>
80102155:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102158:	83 ec 0c             	sub    $0xc,%esp
8010215b:	ff 75 f0             	push   -0x10(%ebp)
8010215e:	e8 20 e1 ff ff       	call   80100283 <brelse>
80102163:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102166:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102169:	01 45 f4             	add    %eax,-0xc(%ebp)
8010216c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010216f:	01 45 10             	add    %eax,0x10(%ebp)
80102172:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102175:	01 45 0c             	add    %eax,0xc(%ebp)
80102178:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010217b:	3b 45 14             	cmp    0x14(%ebp),%eax
8010217e:	0f 82 5d ff ff ff    	jb     801020e1 <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
80102184:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102188:	74 22                	je     801021ac <writei+0x181>
8010218a:	8b 45 08             	mov    0x8(%ebp),%eax
8010218d:	8b 40 58             	mov    0x58(%eax),%eax
80102190:	39 45 10             	cmp    %eax,0x10(%ebp)
80102193:	76 17                	jbe    801021ac <writei+0x181>
    ip->size = off;
80102195:	8b 45 08             	mov    0x8(%ebp),%eax
80102198:	8b 55 10             	mov    0x10(%ebp),%edx
8010219b:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
8010219e:	83 ec 0c             	sub    $0xc,%esp
801021a1:	ff 75 08             	push   0x8(%ebp)
801021a4:	e8 64 f6 ff ff       	call   8010180d <iupdate>
801021a9:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021ac:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021af:	c9                   	leave  
801021b0:	c3                   	ret    

801021b1 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021b1:	55                   	push   %ebp
801021b2:	89 e5                	mov    %esp,%ebp
801021b4:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021b7:	83 ec 04             	sub    $0x4,%esp
801021ba:	6a 0e                	push   $0xe
801021bc:	ff 75 0c             	push   0xc(%ebp)
801021bf:	ff 75 08             	push   0x8(%ebp)
801021c2:	e8 70 2a 00 00       	call   80104c37 <strncmp>
801021c7:	83 c4 10             	add    $0x10,%esp
}
801021ca:	c9                   	leave  
801021cb:	c3                   	ret    

801021cc <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021cc:	55                   	push   %ebp
801021cd:	89 e5                	mov    %esp,%ebp
801021cf:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021d2:	8b 45 08             	mov    0x8(%ebp),%eax
801021d5:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801021d9:	66 83 f8 01          	cmp    $0x1,%ax
801021dd:	74 0d                	je     801021ec <dirlookup+0x20>
    panic("dirlookup not DIR");
801021df:	83 ec 0c             	sub    $0xc,%esp
801021e2:	68 bd a2 10 80       	push   $0x8010a2bd
801021e7:	e8 bd e3 ff ff       	call   801005a9 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021f3:	eb 7b                	jmp    80102270 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021f5:	6a 10                	push   $0x10
801021f7:	ff 75 f4             	push   -0xc(%ebp)
801021fa:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021fd:	50                   	push   %eax
801021fe:	ff 75 08             	push   0x8(%ebp)
80102201:	e8 d0 fc ff ff       	call   80101ed6 <readi>
80102206:	83 c4 10             	add    $0x10,%esp
80102209:	83 f8 10             	cmp    $0x10,%eax
8010220c:	74 0d                	je     8010221b <dirlookup+0x4f>
      panic("dirlookup read");
8010220e:	83 ec 0c             	sub    $0xc,%esp
80102211:	68 cf a2 10 80       	push   $0x8010a2cf
80102216:	e8 8e e3 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
8010221b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010221f:	66 85 c0             	test   %ax,%ax
80102222:	74 47                	je     8010226b <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
80102224:	83 ec 08             	sub    $0x8,%esp
80102227:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010222a:	83 c0 02             	add    $0x2,%eax
8010222d:	50                   	push   %eax
8010222e:	ff 75 0c             	push   0xc(%ebp)
80102231:	e8 7b ff ff ff       	call   801021b1 <namecmp>
80102236:	83 c4 10             	add    $0x10,%esp
80102239:	85 c0                	test   %eax,%eax
8010223b:	75 2f                	jne    8010226c <dirlookup+0xa0>
      // entry matches path element
      if(poff)
8010223d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102241:	74 08                	je     8010224b <dirlookup+0x7f>
        *poff = off;
80102243:	8b 45 10             	mov    0x10(%ebp),%eax
80102246:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102249:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010224b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010224f:	0f b7 c0             	movzwl %ax,%eax
80102252:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102255:	8b 45 08             	mov    0x8(%ebp),%eax
80102258:	8b 00                	mov    (%eax),%eax
8010225a:	83 ec 08             	sub    $0x8,%esp
8010225d:	ff 75 f0             	push   -0x10(%ebp)
80102260:	50                   	push   %eax
80102261:	e8 68 f6 ff ff       	call   801018ce <iget>
80102266:	83 c4 10             	add    $0x10,%esp
80102269:	eb 19                	jmp    80102284 <dirlookup+0xb8>
      continue;
8010226b:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
8010226c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102270:	8b 45 08             	mov    0x8(%ebp),%eax
80102273:	8b 40 58             	mov    0x58(%eax),%eax
80102276:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102279:	0f 82 76 ff ff ff    	jb     801021f5 <dirlookup+0x29>
    }
  }

  return 0;
8010227f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102284:	c9                   	leave  
80102285:	c3                   	ret    

80102286 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102286:	55                   	push   %ebp
80102287:	89 e5                	mov    %esp,%ebp
80102289:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010228c:	83 ec 04             	sub    $0x4,%esp
8010228f:	6a 00                	push   $0x0
80102291:	ff 75 0c             	push   0xc(%ebp)
80102294:	ff 75 08             	push   0x8(%ebp)
80102297:	e8 30 ff ff ff       	call   801021cc <dirlookup>
8010229c:	83 c4 10             	add    $0x10,%esp
8010229f:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022a2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022a6:	74 18                	je     801022c0 <dirlink+0x3a>
    iput(ip);
801022a8:	83 ec 0c             	sub    $0xc,%esp
801022ab:	ff 75 f0             	push   -0x10(%ebp)
801022ae:	e8 98 f8 ff ff       	call   80101b4b <iput>
801022b3:	83 c4 10             	add    $0x10,%esp
    return -1;
801022b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022bb:	e9 9c 00 00 00       	jmp    8010235c <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022c7:	eb 39                	jmp    80102302 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022cc:	6a 10                	push   $0x10
801022ce:	50                   	push   %eax
801022cf:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022d2:	50                   	push   %eax
801022d3:	ff 75 08             	push   0x8(%ebp)
801022d6:	e8 fb fb ff ff       	call   80101ed6 <readi>
801022db:	83 c4 10             	add    $0x10,%esp
801022de:	83 f8 10             	cmp    $0x10,%eax
801022e1:	74 0d                	je     801022f0 <dirlink+0x6a>
      panic("dirlink read");
801022e3:	83 ec 0c             	sub    $0xc,%esp
801022e6:	68 de a2 10 80       	push   $0x8010a2de
801022eb:	e8 b9 e2 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
801022f0:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022f4:	66 85 c0             	test   %ax,%ax
801022f7:	74 18                	je     80102311 <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
801022f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022fc:	83 c0 10             	add    $0x10,%eax
801022ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102302:	8b 45 08             	mov    0x8(%ebp),%eax
80102305:	8b 50 58             	mov    0x58(%eax),%edx
80102308:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010230b:	39 c2                	cmp    %eax,%edx
8010230d:	77 ba                	ja     801022c9 <dirlink+0x43>
8010230f:	eb 01                	jmp    80102312 <dirlink+0x8c>
      break;
80102311:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102312:	83 ec 04             	sub    $0x4,%esp
80102315:	6a 0e                	push   $0xe
80102317:	ff 75 0c             	push   0xc(%ebp)
8010231a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010231d:	83 c0 02             	add    $0x2,%eax
80102320:	50                   	push   %eax
80102321:	e8 67 29 00 00       	call   80104c8d <strncpy>
80102326:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102329:	8b 45 10             	mov    0x10(%ebp),%eax
8010232c:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102330:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102333:	6a 10                	push   $0x10
80102335:	50                   	push   %eax
80102336:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102339:	50                   	push   %eax
8010233a:	ff 75 08             	push   0x8(%ebp)
8010233d:	e8 e9 fc ff ff       	call   8010202b <writei>
80102342:	83 c4 10             	add    $0x10,%esp
80102345:	83 f8 10             	cmp    $0x10,%eax
80102348:	74 0d                	je     80102357 <dirlink+0xd1>
    panic("dirlink");
8010234a:	83 ec 0c             	sub    $0xc,%esp
8010234d:	68 eb a2 10 80       	push   $0x8010a2eb
80102352:	e8 52 e2 ff ff       	call   801005a9 <panic>

  return 0;
80102357:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010235c:	c9                   	leave  
8010235d:	c3                   	ret    

8010235e <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010235e:	55                   	push   %ebp
8010235f:	89 e5                	mov    %esp,%ebp
80102361:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102364:	eb 04                	jmp    8010236a <skipelem+0xc>
    path++;
80102366:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
8010236a:	8b 45 08             	mov    0x8(%ebp),%eax
8010236d:	0f b6 00             	movzbl (%eax),%eax
80102370:	3c 2f                	cmp    $0x2f,%al
80102372:	74 f2                	je     80102366 <skipelem+0x8>
  if(*path == 0)
80102374:	8b 45 08             	mov    0x8(%ebp),%eax
80102377:	0f b6 00             	movzbl (%eax),%eax
8010237a:	84 c0                	test   %al,%al
8010237c:	75 07                	jne    80102385 <skipelem+0x27>
    return 0;
8010237e:	b8 00 00 00 00       	mov    $0x0,%eax
80102383:	eb 77                	jmp    801023fc <skipelem+0x9e>
  s = path;
80102385:	8b 45 08             	mov    0x8(%ebp),%eax
80102388:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010238b:	eb 04                	jmp    80102391 <skipelem+0x33>
    path++;
8010238d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102391:	8b 45 08             	mov    0x8(%ebp),%eax
80102394:	0f b6 00             	movzbl (%eax),%eax
80102397:	3c 2f                	cmp    $0x2f,%al
80102399:	74 0a                	je     801023a5 <skipelem+0x47>
8010239b:	8b 45 08             	mov    0x8(%ebp),%eax
8010239e:	0f b6 00             	movzbl (%eax),%eax
801023a1:	84 c0                	test   %al,%al
801023a3:	75 e8                	jne    8010238d <skipelem+0x2f>
  len = path - s;
801023a5:	8b 45 08             	mov    0x8(%ebp),%eax
801023a8:	2b 45 f4             	sub    -0xc(%ebp),%eax
801023ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023ae:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023b2:	7e 15                	jle    801023c9 <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
801023b4:	83 ec 04             	sub    $0x4,%esp
801023b7:	6a 0e                	push   $0xe
801023b9:	ff 75 f4             	push   -0xc(%ebp)
801023bc:	ff 75 0c             	push   0xc(%ebp)
801023bf:	e8 dd 27 00 00       	call   80104ba1 <memmove>
801023c4:	83 c4 10             	add    $0x10,%esp
801023c7:	eb 26                	jmp    801023ef <skipelem+0x91>
  else {
    memmove(name, s, len);
801023c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023cc:	83 ec 04             	sub    $0x4,%esp
801023cf:	50                   	push   %eax
801023d0:	ff 75 f4             	push   -0xc(%ebp)
801023d3:	ff 75 0c             	push   0xc(%ebp)
801023d6:	e8 c6 27 00 00       	call   80104ba1 <memmove>
801023db:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023de:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801023e4:	01 d0                	add    %edx,%eax
801023e6:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023e9:	eb 04                	jmp    801023ef <skipelem+0x91>
    path++;
801023eb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801023ef:	8b 45 08             	mov    0x8(%ebp),%eax
801023f2:	0f b6 00             	movzbl (%eax),%eax
801023f5:	3c 2f                	cmp    $0x2f,%al
801023f7:	74 f2                	je     801023eb <skipelem+0x8d>
  return path;
801023f9:	8b 45 08             	mov    0x8(%ebp),%eax
}
801023fc:	c9                   	leave  
801023fd:	c3                   	ret    

801023fe <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801023fe:	55                   	push   %ebp
801023ff:	89 e5                	mov    %esp,%ebp
80102401:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102404:	8b 45 08             	mov    0x8(%ebp),%eax
80102407:	0f b6 00             	movzbl (%eax),%eax
8010240a:	3c 2f                	cmp    $0x2f,%al
8010240c:	75 17                	jne    80102425 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
8010240e:	83 ec 08             	sub    $0x8,%esp
80102411:	6a 01                	push   $0x1
80102413:	6a 01                	push   $0x1
80102415:	e8 b4 f4 ff ff       	call   801018ce <iget>
8010241a:	83 c4 10             	add    $0x10,%esp
8010241d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102420:	e9 ba 00 00 00       	jmp    801024df <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
80102425:	e8 06 16 00 00       	call   80103a30 <myproc>
8010242a:	8b 40 68             	mov    0x68(%eax),%eax
8010242d:	83 ec 0c             	sub    $0xc,%esp
80102430:	50                   	push   %eax
80102431:	e8 7a f5 ff ff       	call   801019b0 <idup>
80102436:	83 c4 10             	add    $0x10,%esp
80102439:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010243c:	e9 9e 00 00 00       	jmp    801024df <namex+0xe1>
    ilock(ip);
80102441:	83 ec 0c             	sub    $0xc,%esp
80102444:	ff 75 f4             	push   -0xc(%ebp)
80102447:	e8 9e f5 ff ff       	call   801019ea <ilock>
8010244c:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010244f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102452:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102456:	66 83 f8 01          	cmp    $0x1,%ax
8010245a:	74 18                	je     80102474 <namex+0x76>
      iunlockput(ip);
8010245c:	83 ec 0c             	sub    $0xc,%esp
8010245f:	ff 75 f4             	push   -0xc(%ebp)
80102462:	e8 b4 f7 ff ff       	call   80101c1b <iunlockput>
80102467:	83 c4 10             	add    $0x10,%esp
      return 0;
8010246a:	b8 00 00 00 00       	mov    $0x0,%eax
8010246f:	e9 a7 00 00 00       	jmp    8010251b <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
80102474:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102478:	74 20                	je     8010249a <namex+0x9c>
8010247a:	8b 45 08             	mov    0x8(%ebp),%eax
8010247d:	0f b6 00             	movzbl (%eax),%eax
80102480:	84 c0                	test   %al,%al
80102482:	75 16                	jne    8010249a <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
80102484:	83 ec 0c             	sub    $0xc,%esp
80102487:	ff 75 f4             	push   -0xc(%ebp)
8010248a:	e8 6e f6 ff ff       	call   80101afd <iunlock>
8010248f:	83 c4 10             	add    $0x10,%esp
      return ip;
80102492:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102495:	e9 81 00 00 00       	jmp    8010251b <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010249a:	83 ec 04             	sub    $0x4,%esp
8010249d:	6a 00                	push   $0x0
8010249f:	ff 75 10             	push   0x10(%ebp)
801024a2:	ff 75 f4             	push   -0xc(%ebp)
801024a5:	e8 22 fd ff ff       	call   801021cc <dirlookup>
801024aa:	83 c4 10             	add    $0x10,%esp
801024ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024b4:	75 15                	jne    801024cb <namex+0xcd>
      iunlockput(ip);
801024b6:	83 ec 0c             	sub    $0xc,%esp
801024b9:	ff 75 f4             	push   -0xc(%ebp)
801024bc:	e8 5a f7 ff ff       	call   80101c1b <iunlockput>
801024c1:	83 c4 10             	add    $0x10,%esp
      return 0;
801024c4:	b8 00 00 00 00       	mov    $0x0,%eax
801024c9:	eb 50                	jmp    8010251b <namex+0x11d>
    }
    iunlockput(ip);
801024cb:	83 ec 0c             	sub    $0xc,%esp
801024ce:	ff 75 f4             	push   -0xc(%ebp)
801024d1:	e8 45 f7 ff ff       	call   80101c1b <iunlockput>
801024d6:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801024df:	83 ec 08             	sub    $0x8,%esp
801024e2:	ff 75 10             	push   0x10(%ebp)
801024e5:	ff 75 08             	push   0x8(%ebp)
801024e8:	e8 71 fe ff ff       	call   8010235e <skipelem>
801024ed:	83 c4 10             	add    $0x10,%esp
801024f0:	89 45 08             	mov    %eax,0x8(%ebp)
801024f3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024f7:	0f 85 44 ff ff ff    	jne    80102441 <namex+0x43>
  }
  if(nameiparent){
801024fd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102501:	74 15                	je     80102518 <namex+0x11a>
    iput(ip);
80102503:	83 ec 0c             	sub    $0xc,%esp
80102506:	ff 75 f4             	push   -0xc(%ebp)
80102509:	e8 3d f6 ff ff       	call   80101b4b <iput>
8010250e:	83 c4 10             	add    $0x10,%esp
    return 0;
80102511:	b8 00 00 00 00       	mov    $0x0,%eax
80102516:	eb 03                	jmp    8010251b <namex+0x11d>
  }
  return ip;
80102518:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010251b:	c9                   	leave  
8010251c:	c3                   	ret    

8010251d <namei>:

struct inode*
namei(char *path)
{
8010251d:	55                   	push   %ebp
8010251e:	89 e5                	mov    %esp,%ebp
80102520:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102523:	83 ec 04             	sub    $0x4,%esp
80102526:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102529:	50                   	push   %eax
8010252a:	6a 00                	push   $0x0
8010252c:	ff 75 08             	push   0x8(%ebp)
8010252f:	e8 ca fe ff ff       	call   801023fe <namex>
80102534:	83 c4 10             	add    $0x10,%esp
}
80102537:	c9                   	leave  
80102538:	c3                   	ret    

80102539 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102539:	55                   	push   %ebp
8010253a:	89 e5                	mov    %esp,%ebp
8010253c:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010253f:	83 ec 04             	sub    $0x4,%esp
80102542:	ff 75 0c             	push   0xc(%ebp)
80102545:	6a 01                	push   $0x1
80102547:	ff 75 08             	push   0x8(%ebp)
8010254a:	e8 af fe ff ff       	call   801023fe <namex>
8010254f:	83 c4 10             	add    $0x10,%esp
}
80102552:	c9                   	leave  
80102553:	c3                   	ret    

80102554 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102554:	55                   	push   %ebp
80102555:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102557:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010255c:	8b 55 08             	mov    0x8(%ebp),%edx
8010255f:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102561:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102566:	8b 40 10             	mov    0x10(%eax),%eax
}
80102569:	5d                   	pop    %ebp
8010256a:	c3                   	ret    

8010256b <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
8010256b:	55                   	push   %ebp
8010256c:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010256e:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102573:	8b 55 08             	mov    0x8(%ebp),%edx
80102576:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102578:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010257d:	8b 55 0c             	mov    0xc(%ebp),%edx
80102580:	89 50 10             	mov    %edx,0x10(%eax)
}
80102583:	90                   	nop
80102584:	5d                   	pop    %ebp
80102585:	c3                   	ret    

80102586 <ioapicinit>:

void
ioapicinit(void)
{
80102586:	55                   	push   %ebp
80102587:	89 e5                	mov    %esp,%ebp
80102589:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
8010258c:	c7 05 b4 40 19 80 00 	movl   $0xfec00000,0x801940b4
80102593:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102596:	6a 01                	push   $0x1
80102598:	e8 b7 ff ff ff       	call   80102554 <ioapicread>
8010259d:	83 c4 04             	add    $0x4,%esp
801025a0:	c1 e8 10             	shr    $0x10,%eax
801025a3:	25 ff 00 00 00       	and    $0xff,%eax
801025a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801025ab:	6a 00                	push   $0x0
801025ad:	e8 a2 ff ff ff       	call   80102554 <ioapicread>
801025b2:	83 c4 04             	add    $0x4,%esp
801025b5:	c1 e8 18             	shr    $0x18,%eax
801025b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801025bb:	0f b6 05 44 6c 19 80 	movzbl 0x80196c44,%eax
801025c2:	0f b6 c0             	movzbl %al,%eax
801025c5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801025c8:	74 10                	je     801025da <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801025ca:	83 ec 0c             	sub    $0xc,%esp
801025cd:	68 f4 a2 10 80       	push   $0x8010a2f4
801025d2:	e8 1d de ff ff       	call   801003f4 <cprintf>
801025d7:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801025da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025e1:	eb 3f                	jmp    80102622 <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801025e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025e6:	83 c0 20             	add    $0x20,%eax
801025e9:	0d 00 00 01 00       	or     $0x10000,%eax
801025ee:	89 c2                	mov    %eax,%edx
801025f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025f3:	83 c0 08             	add    $0x8,%eax
801025f6:	01 c0                	add    %eax,%eax
801025f8:	83 ec 08             	sub    $0x8,%esp
801025fb:	52                   	push   %edx
801025fc:	50                   	push   %eax
801025fd:	e8 69 ff ff ff       	call   8010256b <ioapicwrite>
80102602:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102605:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102608:	83 c0 08             	add    $0x8,%eax
8010260b:	01 c0                	add    %eax,%eax
8010260d:	83 c0 01             	add    $0x1,%eax
80102610:	83 ec 08             	sub    $0x8,%esp
80102613:	6a 00                	push   $0x0
80102615:	50                   	push   %eax
80102616:	e8 50 ff ff ff       	call   8010256b <ioapicwrite>
8010261b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
8010261e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102622:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102625:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102628:	7e b9                	jle    801025e3 <ioapicinit+0x5d>
  }
}
8010262a:	90                   	nop
8010262b:	90                   	nop
8010262c:	c9                   	leave  
8010262d:	c3                   	ret    

8010262e <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010262e:	55                   	push   %ebp
8010262f:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102631:	8b 45 08             	mov    0x8(%ebp),%eax
80102634:	83 c0 20             	add    $0x20,%eax
80102637:	89 c2                	mov    %eax,%edx
80102639:	8b 45 08             	mov    0x8(%ebp),%eax
8010263c:	83 c0 08             	add    $0x8,%eax
8010263f:	01 c0                	add    %eax,%eax
80102641:	52                   	push   %edx
80102642:	50                   	push   %eax
80102643:	e8 23 ff ff ff       	call   8010256b <ioapicwrite>
80102648:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010264b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010264e:	c1 e0 18             	shl    $0x18,%eax
80102651:	89 c2                	mov    %eax,%edx
80102653:	8b 45 08             	mov    0x8(%ebp),%eax
80102656:	83 c0 08             	add    $0x8,%eax
80102659:	01 c0                	add    %eax,%eax
8010265b:	83 c0 01             	add    $0x1,%eax
8010265e:	52                   	push   %edx
8010265f:	50                   	push   %eax
80102660:	e8 06 ff ff ff       	call   8010256b <ioapicwrite>
80102665:	83 c4 08             	add    $0x8,%esp
}
80102668:	90                   	nop
80102669:	c9                   	leave  
8010266a:	c3                   	ret    

8010266b <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
8010266b:	55                   	push   %ebp
8010266c:	89 e5                	mov    %esp,%ebp
8010266e:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102671:	83 ec 08             	sub    $0x8,%esp
80102674:	68 26 a3 10 80       	push   $0x8010a326
80102679:	68 c0 40 19 80       	push   $0x801940c0
8010267e:	e8 c7 21 00 00       	call   8010484a <initlock>
80102683:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102686:	c7 05 f4 40 19 80 00 	movl   $0x0,0x801940f4
8010268d:	00 00 00 
  freerange(vstart, vend);
80102690:	83 ec 08             	sub    $0x8,%esp
80102693:	ff 75 0c             	push   0xc(%ebp)
80102696:	ff 75 08             	push   0x8(%ebp)
80102699:	e8 2a 00 00 00       	call   801026c8 <freerange>
8010269e:	83 c4 10             	add    $0x10,%esp
}
801026a1:	90                   	nop
801026a2:	c9                   	leave  
801026a3:	c3                   	ret    

801026a4 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801026a4:	55                   	push   %ebp
801026a5:	89 e5                	mov    %esp,%ebp
801026a7:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
801026aa:	83 ec 08             	sub    $0x8,%esp
801026ad:	ff 75 0c             	push   0xc(%ebp)
801026b0:	ff 75 08             	push   0x8(%ebp)
801026b3:	e8 10 00 00 00       	call   801026c8 <freerange>
801026b8:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
801026bb:	c7 05 f4 40 19 80 01 	movl   $0x1,0x801940f4
801026c2:	00 00 00 
}
801026c5:	90                   	nop
801026c6:	c9                   	leave  
801026c7:	c3                   	ret    

801026c8 <freerange>:

void
freerange(void *vstart, void *vend)
{
801026c8:	55                   	push   %ebp
801026c9:	89 e5                	mov    %esp,%ebp
801026cb:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801026ce:	8b 45 08             	mov    0x8(%ebp),%eax
801026d1:	05 ff 0f 00 00       	add    $0xfff,%eax
801026d6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801026db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026de:	eb 15                	jmp    801026f5 <freerange+0x2d>
    kfree(p);
801026e0:	83 ec 0c             	sub    $0xc,%esp
801026e3:	ff 75 f4             	push   -0xc(%ebp)
801026e6:	e8 1b 00 00 00       	call   80102706 <kfree>
801026eb:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026ee:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801026f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026f8:	05 00 10 00 00       	add    $0x1000,%eax
801026fd:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102700:	73 de                	jae    801026e0 <freerange+0x18>
}
80102702:	90                   	nop
80102703:	90                   	nop
80102704:	c9                   	leave  
80102705:	c3                   	ret    

80102706 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102706:	55                   	push   %ebp
80102707:	89 e5                	mov    %esp,%ebp
80102709:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
8010270c:	8b 45 08             	mov    0x8(%ebp),%eax
8010270f:	25 ff 0f 00 00       	and    $0xfff,%eax
80102714:	85 c0                	test   %eax,%eax
80102716:	75 18                	jne    80102730 <kfree+0x2a>
80102718:	81 7d 08 00 80 19 80 	cmpl   $0x80198000,0x8(%ebp)
8010271f:	72 0f                	jb     80102730 <kfree+0x2a>
80102721:	8b 45 08             	mov    0x8(%ebp),%eax
80102724:	05 00 00 00 80       	add    $0x80000000,%eax
80102729:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
8010272e:	76 0d                	jbe    8010273d <kfree+0x37>
    panic("kfree");
80102730:	83 ec 0c             	sub    $0xc,%esp
80102733:	68 2b a3 10 80       	push   $0x8010a32b
80102738:	e8 6c de ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010273d:	83 ec 04             	sub    $0x4,%esp
80102740:	68 00 10 00 00       	push   $0x1000
80102745:	6a 01                	push   $0x1
80102747:	ff 75 08             	push   0x8(%ebp)
8010274a:	e8 93 23 00 00       	call   80104ae2 <memset>
8010274f:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102752:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102757:	85 c0                	test   %eax,%eax
80102759:	74 10                	je     8010276b <kfree+0x65>
    acquire(&kmem.lock);
8010275b:	83 ec 0c             	sub    $0xc,%esp
8010275e:	68 c0 40 19 80       	push   $0x801940c0
80102763:	e8 04 21 00 00       	call   8010486c <acquire>
80102768:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
8010276b:	8b 45 08             	mov    0x8(%ebp),%eax
8010276e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102771:	8b 15 f8 40 19 80    	mov    0x801940f8,%edx
80102777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010277a:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
8010277c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010277f:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
80102784:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102789:	85 c0                	test   %eax,%eax
8010278b:	74 10                	je     8010279d <kfree+0x97>
    release(&kmem.lock);
8010278d:	83 ec 0c             	sub    $0xc,%esp
80102790:	68 c0 40 19 80       	push   $0x801940c0
80102795:	e8 40 21 00 00       	call   801048da <release>
8010279a:	83 c4 10             	add    $0x10,%esp
}
8010279d:	90                   	nop
8010279e:	c9                   	leave  
8010279f:	c3                   	ret    

801027a0 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801027a0:	55                   	push   %ebp
801027a1:	89 e5                	mov    %esp,%ebp
801027a3:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
801027a6:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027ab:	85 c0                	test   %eax,%eax
801027ad:	74 10                	je     801027bf <kalloc+0x1f>
    acquire(&kmem.lock);
801027af:	83 ec 0c             	sub    $0xc,%esp
801027b2:	68 c0 40 19 80       	push   $0x801940c0
801027b7:	e8 b0 20 00 00       	call   8010486c <acquire>
801027bc:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801027bf:	a1 f8 40 19 80       	mov    0x801940f8,%eax
801027c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801027c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027cb:	74 0a                	je     801027d7 <kalloc+0x37>
    kmem.freelist = r->next;
801027cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027d0:	8b 00                	mov    (%eax),%eax
801027d2:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
801027d7:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027dc:	85 c0                	test   %eax,%eax
801027de:	74 10                	je     801027f0 <kalloc+0x50>
    release(&kmem.lock);
801027e0:	83 ec 0c             	sub    $0xc,%esp
801027e3:	68 c0 40 19 80       	push   $0x801940c0
801027e8:	e8 ed 20 00 00       	call   801048da <release>
801027ed:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801027f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801027f3:	c9                   	leave  
801027f4:	c3                   	ret    

801027f5 <inb>:
{
801027f5:	55                   	push   %ebp
801027f6:	89 e5                	mov    %esp,%ebp
801027f8:	83 ec 14             	sub    $0x14,%esp
801027fb:	8b 45 08             	mov    0x8(%ebp),%eax
801027fe:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102802:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102806:	89 c2                	mov    %eax,%edx
80102808:	ec                   	in     (%dx),%al
80102809:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010280c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102810:	c9                   	leave  
80102811:	c3                   	ret    

80102812 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102812:	55                   	push   %ebp
80102813:	89 e5                	mov    %esp,%ebp
80102815:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102818:	6a 64                	push   $0x64
8010281a:	e8 d6 ff ff ff       	call   801027f5 <inb>
8010281f:	83 c4 04             	add    $0x4,%esp
80102822:	0f b6 c0             	movzbl %al,%eax
80102825:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102828:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010282b:	83 e0 01             	and    $0x1,%eax
8010282e:	85 c0                	test   %eax,%eax
80102830:	75 0a                	jne    8010283c <kbdgetc+0x2a>
    return -1;
80102832:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102837:	e9 23 01 00 00       	jmp    8010295f <kbdgetc+0x14d>
  data = inb(KBDATAP);
8010283c:	6a 60                	push   $0x60
8010283e:	e8 b2 ff ff ff       	call   801027f5 <inb>
80102843:	83 c4 04             	add    $0x4,%esp
80102846:	0f b6 c0             	movzbl %al,%eax
80102849:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
8010284c:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102853:	75 17                	jne    8010286c <kbdgetc+0x5a>
    shift |= E0ESC;
80102855:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010285a:	83 c8 40             	or     $0x40,%eax
8010285d:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
80102862:	b8 00 00 00 00       	mov    $0x0,%eax
80102867:	e9 f3 00 00 00       	jmp    8010295f <kbdgetc+0x14d>
  } else if(data & 0x80){
8010286c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010286f:	25 80 00 00 00       	and    $0x80,%eax
80102874:	85 c0                	test   %eax,%eax
80102876:	74 45                	je     801028bd <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102878:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010287d:	83 e0 40             	and    $0x40,%eax
80102880:	85 c0                	test   %eax,%eax
80102882:	75 08                	jne    8010288c <kbdgetc+0x7a>
80102884:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102887:	83 e0 7f             	and    $0x7f,%eax
8010288a:	eb 03                	jmp    8010288f <kbdgetc+0x7d>
8010288c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010288f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102892:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102895:	05 20 d0 10 80       	add    $0x8010d020,%eax
8010289a:	0f b6 00             	movzbl (%eax),%eax
8010289d:	83 c8 40             	or     $0x40,%eax
801028a0:	0f b6 c0             	movzbl %al,%eax
801028a3:	f7 d0                	not    %eax
801028a5:	89 c2                	mov    %eax,%edx
801028a7:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028ac:	21 d0                	and    %edx,%eax
801028ae:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
801028b3:	b8 00 00 00 00       	mov    $0x0,%eax
801028b8:	e9 a2 00 00 00       	jmp    8010295f <kbdgetc+0x14d>
  } else if(shift & E0ESC){
801028bd:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028c2:	83 e0 40             	and    $0x40,%eax
801028c5:	85 c0                	test   %eax,%eax
801028c7:	74 14                	je     801028dd <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801028c9:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801028d0:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028d5:	83 e0 bf             	and    $0xffffffbf,%eax
801028d8:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  }

  shift |= shiftcode[data];
801028dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028e0:	05 20 d0 10 80       	add    $0x8010d020,%eax
801028e5:	0f b6 00             	movzbl (%eax),%eax
801028e8:	0f b6 d0             	movzbl %al,%edx
801028eb:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028f0:	09 d0                	or     %edx,%eax
801028f2:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  shift ^= togglecode[data];
801028f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028fa:	05 20 d1 10 80       	add    $0x8010d120,%eax
801028ff:	0f b6 00             	movzbl (%eax),%eax
80102902:	0f b6 d0             	movzbl %al,%edx
80102905:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010290a:	31 d0                	xor    %edx,%eax
8010290c:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  c = charcode[shift & (CTL | SHIFT)][data];
80102911:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102916:	83 e0 03             	and    $0x3,%eax
80102919:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102920:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102923:	01 d0                	add    %edx,%eax
80102925:	0f b6 00             	movzbl (%eax),%eax
80102928:	0f b6 c0             	movzbl %al,%eax
8010292b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
8010292e:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102933:	83 e0 08             	and    $0x8,%eax
80102936:	85 c0                	test   %eax,%eax
80102938:	74 22                	je     8010295c <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
8010293a:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
8010293e:	76 0c                	jbe    8010294c <kbdgetc+0x13a>
80102940:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102944:	77 06                	ja     8010294c <kbdgetc+0x13a>
      c += 'A' - 'a';
80102946:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
8010294a:	eb 10                	jmp    8010295c <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
8010294c:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102950:	76 0a                	jbe    8010295c <kbdgetc+0x14a>
80102952:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102956:	77 04                	ja     8010295c <kbdgetc+0x14a>
      c += 'a' - 'A';
80102958:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
8010295c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010295f:	c9                   	leave  
80102960:	c3                   	ret    

80102961 <kbdintr>:

void
kbdintr(void)
{
80102961:	55                   	push   %ebp
80102962:	89 e5                	mov    %esp,%ebp
80102964:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102967:	83 ec 0c             	sub    $0xc,%esp
8010296a:	68 12 28 10 80       	push   $0x80102812
8010296f:	e8 62 de ff ff       	call   801007d6 <consoleintr>
80102974:	83 c4 10             	add    $0x10,%esp
}
80102977:	90                   	nop
80102978:	c9                   	leave  
80102979:	c3                   	ret    

8010297a <inb>:
{
8010297a:	55                   	push   %ebp
8010297b:	89 e5                	mov    %esp,%ebp
8010297d:	83 ec 14             	sub    $0x14,%esp
80102980:	8b 45 08             	mov    0x8(%ebp),%eax
80102983:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102987:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010298b:	89 c2                	mov    %eax,%edx
8010298d:	ec                   	in     (%dx),%al
8010298e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102991:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102995:	c9                   	leave  
80102996:	c3                   	ret    

80102997 <outb>:
{
80102997:	55                   	push   %ebp
80102998:	89 e5                	mov    %esp,%ebp
8010299a:	83 ec 08             	sub    $0x8,%esp
8010299d:	8b 45 08             	mov    0x8(%ebp),%eax
801029a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801029a3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801029a7:	89 d0                	mov    %edx,%eax
801029a9:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801029ac:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801029b0:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801029b4:	ee                   	out    %al,(%dx)
}
801029b5:	90                   	nop
801029b6:	c9                   	leave  
801029b7:	c3                   	ret    

801029b8 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
801029b8:	55                   	push   %ebp
801029b9:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801029bb:	8b 15 00 41 19 80    	mov    0x80194100,%edx
801029c1:	8b 45 08             	mov    0x8(%ebp),%eax
801029c4:	c1 e0 02             	shl    $0x2,%eax
801029c7:	01 c2                	add    %eax,%edx
801029c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801029cc:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801029ce:	a1 00 41 19 80       	mov    0x80194100,%eax
801029d3:	83 c0 20             	add    $0x20,%eax
801029d6:	8b 00                	mov    (%eax),%eax
}
801029d8:	90                   	nop
801029d9:	5d                   	pop    %ebp
801029da:	c3                   	ret    

801029db <lapicinit>:

void
lapicinit(void)
{
801029db:	55                   	push   %ebp
801029dc:	89 e5                	mov    %esp,%ebp
  if(!lapic)
801029de:	a1 00 41 19 80       	mov    0x80194100,%eax
801029e3:	85 c0                	test   %eax,%eax
801029e5:	0f 84 0c 01 00 00    	je     80102af7 <lapicinit+0x11c>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801029eb:	68 3f 01 00 00       	push   $0x13f
801029f0:	6a 3c                	push   $0x3c
801029f2:	e8 c1 ff ff ff       	call   801029b8 <lapicw>
801029f7:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801029fa:	6a 0b                	push   $0xb
801029fc:	68 f8 00 00 00       	push   $0xf8
80102a01:	e8 b2 ff ff ff       	call   801029b8 <lapicw>
80102a06:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102a09:	68 20 00 02 00       	push   $0x20020
80102a0e:	68 c8 00 00 00       	push   $0xc8
80102a13:	e8 a0 ff ff ff       	call   801029b8 <lapicw>
80102a18:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102a1b:	68 80 96 98 00       	push   $0x989680
80102a20:	68 e0 00 00 00       	push   $0xe0
80102a25:	e8 8e ff ff ff       	call   801029b8 <lapicw>
80102a2a:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102a2d:	68 00 00 01 00       	push   $0x10000
80102a32:	68 d4 00 00 00       	push   $0xd4
80102a37:	e8 7c ff ff ff       	call   801029b8 <lapicw>
80102a3c:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102a3f:	68 00 00 01 00       	push   $0x10000
80102a44:	68 d8 00 00 00       	push   $0xd8
80102a49:	e8 6a ff ff ff       	call   801029b8 <lapicw>
80102a4e:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102a51:	a1 00 41 19 80       	mov    0x80194100,%eax
80102a56:	83 c0 30             	add    $0x30,%eax
80102a59:	8b 00                	mov    (%eax),%eax
80102a5b:	c1 e8 10             	shr    $0x10,%eax
80102a5e:	25 fc 00 00 00       	and    $0xfc,%eax
80102a63:	85 c0                	test   %eax,%eax
80102a65:	74 12                	je     80102a79 <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
80102a67:	68 00 00 01 00       	push   $0x10000
80102a6c:	68 d0 00 00 00       	push   $0xd0
80102a71:	e8 42 ff ff ff       	call   801029b8 <lapicw>
80102a76:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102a79:	6a 33                	push   $0x33
80102a7b:	68 dc 00 00 00       	push   $0xdc
80102a80:	e8 33 ff ff ff       	call   801029b8 <lapicw>
80102a85:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102a88:	6a 00                	push   $0x0
80102a8a:	68 a0 00 00 00       	push   $0xa0
80102a8f:	e8 24 ff ff ff       	call   801029b8 <lapicw>
80102a94:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102a97:	6a 00                	push   $0x0
80102a99:	68 a0 00 00 00       	push   $0xa0
80102a9e:	e8 15 ff ff ff       	call   801029b8 <lapicw>
80102aa3:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102aa6:	6a 00                	push   $0x0
80102aa8:	6a 2c                	push   $0x2c
80102aaa:	e8 09 ff ff ff       	call   801029b8 <lapicw>
80102aaf:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102ab2:	6a 00                	push   $0x0
80102ab4:	68 c4 00 00 00       	push   $0xc4
80102ab9:	e8 fa fe ff ff       	call   801029b8 <lapicw>
80102abe:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102ac1:	68 00 85 08 00       	push   $0x88500
80102ac6:	68 c0 00 00 00       	push   $0xc0
80102acb:	e8 e8 fe ff ff       	call   801029b8 <lapicw>
80102ad0:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102ad3:	90                   	nop
80102ad4:	a1 00 41 19 80       	mov    0x80194100,%eax
80102ad9:	05 00 03 00 00       	add    $0x300,%eax
80102ade:	8b 00                	mov    (%eax),%eax
80102ae0:	25 00 10 00 00       	and    $0x1000,%eax
80102ae5:	85 c0                	test   %eax,%eax
80102ae7:	75 eb                	jne    80102ad4 <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102ae9:	6a 00                	push   $0x0
80102aeb:	6a 20                	push   $0x20
80102aed:	e8 c6 fe ff ff       	call   801029b8 <lapicw>
80102af2:	83 c4 08             	add    $0x8,%esp
80102af5:	eb 01                	jmp    80102af8 <lapicinit+0x11d>
    return;
80102af7:	90                   	nop
}
80102af8:	c9                   	leave  
80102af9:	c3                   	ret    

80102afa <lapicid>:

int
lapicid(void)
{
80102afa:	55                   	push   %ebp
80102afb:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102afd:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b02:	85 c0                	test   %eax,%eax
80102b04:	75 07                	jne    80102b0d <lapicid+0x13>
    return 0;
80102b06:	b8 00 00 00 00       	mov    $0x0,%eax
80102b0b:	eb 0d                	jmp    80102b1a <lapicid+0x20>
  }
  return lapic[ID] >> 24;
80102b0d:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b12:	83 c0 20             	add    $0x20,%eax
80102b15:	8b 00                	mov    (%eax),%eax
80102b17:	c1 e8 18             	shr    $0x18,%eax
}
80102b1a:	5d                   	pop    %ebp
80102b1b:	c3                   	ret    

80102b1c <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102b1c:	55                   	push   %ebp
80102b1d:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102b1f:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b24:	85 c0                	test   %eax,%eax
80102b26:	74 0c                	je     80102b34 <lapiceoi+0x18>
    lapicw(EOI, 0);
80102b28:	6a 00                	push   $0x0
80102b2a:	6a 2c                	push   $0x2c
80102b2c:	e8 87 fe ff ff       	call   801029b8 <lapicw>
80102b31:	83 c4 08             	add    $0x8,%esp
}
80102b34:	90                   	nop
80102b35:	c9                   	leave  
80102b36:	c3                   	ret    

80102b37 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102b37:	55                   	push   %ebp
80102b38:	89 e5                	mov    %esp,%ebp
}
80102b3a:	90                   	nop
80102b3b:	5d                   	pop    %ebp
80102b3c:	c3                   	ret    

80102b3d <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102b3d:	55                   	push   %ebp
80102b3e:	89 e5                	mov    %esp,%ebp
80102b40:	83 ec 14             	sub    $0x14,%esp
80102b43:	8b 45 08             	mov    0x8(%ebp),%eax
80102b46:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102b49:	6a 0f                	push   $0xf
80102b4b:	6a 70                	push   $0x70
80102b4d:	e8 45 fe ff ff       	call   80102997 <outb>
80102b52:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102b55:	6a 0a                	push   $0xa
80102b57:	6a 71                	push   $0x71
80102b59:	e8 39 fe ff ff       	call   80102997 <outb>
80102b5e:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102b61:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102b68:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b6b:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102b70:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b73:	c1 e8 04             	shr    $0x4,%eax
80102b76:	89 c2                	mov    %eax,%edx
80102b78:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b7b:	83 c0 02             	add    $0x2,%eax
80102b7e:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102b81:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102b85:	c1 e0 18             	shl    $0x18,%eax
80102b88:	50                   	push   %eax
80102b89:	68 c4 00 00 00       	push   $0xc4
80102b8e:	e8 25 fe ff ff       	call   801029b8 <lapicw>
80102b93:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102b96:	68 00 c5 00 00       	push   $0xc500
80102b9b:	68 c0 00 00 00       	push   $0xc0
80102ba0:	e8 13 fe ff ff       	call   801029b8 <lapicw>
80102ba5:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102ba8:	68 c8 00 00 00       	push   $0xc8
80102bad:	e8 85 ff ff ff       	call   80102b37 <microdelay>
80102bb2:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102bb5:	68 00 85 00 00       	push   $0x8500
80102bba:	68 c0 00 00 00       	push   $0xc0
80102bbf:	e8 f4 fd ff ff       	call   801029b8 <lapicw>
80102bc4:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102bc7:	6a 64                	push   $0x64
80102bc9:	e8 69 ff ff ff       	call   80102b37 <microdelay>
80102bce:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102bd1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102bd8:	eb 3d                	jmp    80102c17 <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
80102bda:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102bde:	c1 e0 18             	shl    $0x18,%eax
80102be1:	50                   	push   %eax
80102be2:	68 c4 00 00 00       	push   $0xc4
80102be7:	e8 cc fd ff ff       	call   801029b8 <lapicw>
80102bec:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102bef:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bf2:	c1 e8 0c             	shr    $0xc,%eax
80102bf5:	80 cc 06             	or     $0x6,%ah
80102bf8:	50                   	push   %eax
80102bf9:	68 c0 00 00 00       	push   $0xc0
80102bfe:	e8 b5 fd ff ff       	call   801029b8 <lapicw>
80102c03:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102c06:	68 c8 00 00 00       	push   $0xc8
80102c0b:	e8 27 ff ff ff       	call   80102b37 <microdelay>
80102c10:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102c13:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102c17:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102c1b:	7e bd                	jle    80102bda <lapicstartap+0x9d>
  }
}
80102c1d:	90                   	nop
80102c1e:	90                   	nop
80102c1f:	c9                   	leave  
80102c20:	c3                   	ret    

80102c21 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102c21:	55                   	push   %ebp
80102c22:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102c24:	8b 45 08             	mov    0x8(%ebp),%eax
80102c27:	0f b6 c0             	movzbl %al,%eax
80102c2a:	50                   	push   %eax
80102c2b:	6a 70                	push   $0x70
80102c2d:	e8 65 fd ff ff       	call   80102997 <outb>
80102c32:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102c35:	68 c8 00 00 00       	push   $0xc8
80102c3a:	e8 f8 fe ff ff       	call   80102b37 <microdelay>
80102c3f:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102c42:	6a 71                	push   $0x71
80102c44:	e8 31 fd ff ff       	call   8010297a <inb>
80102c49:	83 c4 04             	add    $0x4,%esp
80102c4c:	0f b6 c0             	movzbl %al,%eax
}
80102c4f:	c9                   	leave  
80102c50:	c3                   	ret    

80102c51 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102c51:	55                   	push   %ebp
80102c52:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102c54:	6a 00                	push   $0x0
80102c56:	e8 c6 ff ff ff       	call   80102c21 <cmos_read>
80102c5b:	83 c4 04             	add    $0x4,%esp
80102c5e:	8b 55 08             	mov    0x8(%ebp),%edx
80102c61:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102c63:	6a 02                	push   $0x2
80102c65:	e8 b7 ff ff ff       	call   80102c21 <cmos_read>
80102c6a:	83 c4 04             	add    $0x4,%esp
80102c6d:	8b 55 08             	mov    0x8(%ebp),%edx
80102c70:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102c73:	6a 04                	push   $0x4
80102c75:	e8 a7 ff ff ff       	call   80102c21 <cmos_read>
80102c7a:	83 c4 04             	add    $0x4,%esp
80102c7d:	8b 55 08             	mov    0x8(%ebp),%edx
80102c80:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102c83:	6a 07                	push   $0x7
80102c85:	e8 97 ff ff ff       	call   80102c21 <cmos_read>
80102c8a:	83 c4 04             	add    $0x4,%esp
80102c8d:	8b 55 08             	mov    0x8(%ebp),%edx
80102c90:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102c93:	6a 08                	push   $0x8
80102c95:	e8 87 ff ff ff       	call   80102c21 <cmos_read>
80102c9a:	83 c4 04             	add    $0x4,%esp
80102c9d:	8b 55 08             	mov    0x8(%ebp),%edx
80102ca0:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102ca3:	6a 09                	push   $0x9
80102ca5:	e8 77 ff ff ff       	call   80102c21 <cmos_read>
80102caa:	83 c4 04             	add    $0x4,%esp
80102cad:	8b 55 08             	mov    0x8(%ebp),%edx
80102cb0:	89 42 14             	mov    %eax,0x14(%edx)
}
80102cb3:	90                   	nop
80102cb4:	c9                   	leave  
80102cb5:	c3                   	ret    

80102cb6 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102cb6:	55                   	push   %ebp
80102cb7:	89 e5                	mov    %esp,%ebp
80102cb9:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102cbc:	6a 0b                	push   $0xb
80102cbe:	e8 5e ff ff ff       	call   80102c21 <cmos_read>
80102cc3:	83 c4 04             	add    $0x4,%esp
80102cc6:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ccc:	83 e0 04             	and    $0x4,%eax
80102ccf:	85 c0                	test   %eax,%eax
80102cd1:	0f 94 c0             	sete   %al
80102cd4:	0f b6 c0             	movzbl %al,%eax
80102cd7:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102cda:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102cdd:	50                   	push   %eax
80102cde:	e8 6e ff ff ff       	call   80102c51 <fill_rtcdate>
80102ce3:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102ce6:	6a 0a                	push   $0xa
80102ce8:	e8 34 ff ff ff       	call   80102c21 <cmos_read>
80102ced:	83 c4 04             	add    $0x4,%esp
80102cf0:	25 80 00 00 00       	and    $0x80,%eax
80102cf5:	85 c0                	test   %eax,%eax
80102cf7:	75 27                	jne    80102d20 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80102cf9:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102cfc:	50                   	push   %eax
80102cfd:	e8 4f ff ff ff       	call   80102c51 <fill_rtcdate>
80102d02:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102d05:	83 ec 04             	sub    $0x4,%esp
80102d08:	6a 18                	push   $0x18
80102d0a:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102d0d:	50                   	push   %eax
80102d0e:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102d11:	50                   	push   %eax
80102d12:	e8 32 1e 00 00       	call   80104b49 <memcmp>
80102d17:	83 c4 10             	add    $0x10,%esp
80102d1a:	85 c0                	test   %eax,%eax
80102d1c:	74 05                	je     80102d23 <cmostime+0x6d>
80102d1e:	eb ba                	jmp    80102cda <cmostime+0x24>
        continue;
80102d20:	90                   	nop
    fill_rtcdate(&t1);
80102d21:	eb b7                	jmp    80102cda <cmostime+0x24>
      break;
80102d23:	90                   	nop
  }

  // convert
  if(bcd) {
80102d24:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102d28:	0f 84 b4 00 00 00    	je     80102de2 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102d2e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d31:	c1 e8 04             	shr    $0x4,%eax
80102d34:	89 c2                	mov    %eax,%edx
80102d36:	89 d0                	mov    %edx,%eax
80102d38:	c1 e0 02             	shl    $0x2,%eax
80102d3b:	01 d0                	add    %edx,%eax
80102d3d:	01 c0                	add    %eax,%eax
80102d3f:	89 c2                	mov    %eax,%edx
80102d41:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d44:	83 e0 0f             	and    $0xf,%eax
80102d47:	01 d0                	add    %edx,%eax
80102d49:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102d4c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d4f:	c1 e8 04             	shr    $0x4,%eax
80102d52:	89 c2                	mov    %eax,%edx
80102d54:	89 d0                	mov    %edx,%eax
80102d56:	c1 e0 02             	shl    $0x2,%eax
80102d59:	01 d0                	add    %edx,%eax
80102d5b:	01 c0                	add    %eax,%eax
80102d5d:	89 c2                	mov    %eax,%edx
80102d5f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d62:	83 e0 0f             	and    $0xf,%eax
80102d65:	01 d0                	add    %edx,%eax
80102d67:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102d6a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d6d:	c1 e8 04             	shr    $0x4,%eax
80102d70:	89 c2                	mov    %eax,%edx
80102d72:	89 d0                	mov    %edx,%eax
80102d74:	c1 e0 02             	shl    $0x2,%eax
80102d77:	01 d0                	add    %edx,%eax
80102d79:	01 c0                	add    %eax,%eax
80102d7b:	89 c2                	mov    %eax,%edx
80102d7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d80:	83 e0 0f             	and    $0xf,%eax
80102d83:	01 d0                	add    %edx,%eax
80102d85:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102d88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d8b:	c1 e8 04             	shr    $0x4,%eax
80102d8e:	89 c2                	mov    %eax,%edx
80102d90:	89 d0                	mov    %edx,%eax
80102d92:	c1 e0 02             	shl    $0x2,%eax
80102d95:	01 d0                	add    %edx,%eax
80102d97:	01 c0                	add    %eax,%eax
80102d99:	89 c2                	mov    %eax,%edx
80102d9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d9e:	83 e0 0f             	and    $0xf,%eax
80102da1:	01 d0                	add    %edx,%eax
80102da3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102da6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102da9:	c1 e8 04             	shr    $0x4,%eax
80102dac:	89 c2                	mov    %eax,%edx
80102dae:	89 d0                	mov    %edx,%eax
80102db0:	c1 e0 02             	shl    $0x2,%eax
80102db3:	01 d0                	add    %edx,%eax
80102db5:	01 c0                	add    %eax,%eax
80102db7:	89 c2                	mov    %eax,%edx
80102db9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102dbc:	83 e0 0f             	and    $0xf,%eax
80102dbf:	01 d0                	add    %edx,%eax
80102dc1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102dc4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dc7:	c1 e8 04             	shr    $0x4,%eax
80102dca:	89 c2                	mov    %eax,%edx
80102dcc:	89 d0                	mov    %edx,%eax
80102dce:	c1 e0 02             	shl    $0x2,%eax
80102dd1:	01 d0                	add    %edx,%eax
80102dd3:	01 c0                	add    %eax,%eax
80102dd5:	89 c2                	mov    %eax,%edx
80102dd7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dda:	83 e0 0f             	and    $0xf,%eax
80102ddd:	01 d0                	add    %edx,%eax
80102ddf:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102de2:	8b 45 08             	mov    0x8(%ebp),%eax
80102de5:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102de8:	89 10                	mov    %edx,(%eax)
80102dea:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102ded:	89 50 04             	mov    %edx,0x4(%eax)
80102df0:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102df3:	89 50 08             	mov    %edx,0x8(%eax)
80102df6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102df9:	89 50 0c             	mov    %edx,0xc(%eax)
80102dfc:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102dff:	89 50 10             	mov    %edx,0x10(%eax)
80102e02:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102e05:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102e08:	8b 45 08             	mov    0x8(%ebp),%eax
80102e0b:	8b 40 14             	mov    0x14(%eax),%eax
80102e0e:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102e14:	8b 45 08             	mov    0x8(%ebp),%eax
80102e17:	89 50 14             	mov    %edx,0x14(%eax)
}
80102e1a:	90                   	nop
80102e1b:	c9                   	leave  
80102e1c:	c3                   	ret    

80102e1d <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102e1d:	55                   	push   %ebp
80102e1e:	89 e5                	mov    %esp,%ebp
80102e20:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102e23:	83 ec 08             	sub    $0x8,%esp
80102e26:	68 31 a3 10 80       	push   $0x8010a331
80102e2b:	68 20 41 19 80       	push   $0x80194120
80102e30:	e8 15 1a 00 00       	call   8010484a <initlock>
80102e35:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80102e38:	83 ec 08             	sub    $0x8,%esp
80102e3b:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102e3e:	50                   	push   %eax
80102e3f:	ff 75 08             	push   0x8(%ebp)
80102e42:	e8 87 e5 ff ff       	call   801013ce <readsb>
80102e47:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80102e4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102e4d:	a3 54 41 19 80       	mov    %eax,0x80194154
  log.size = sb.nlog;
80102e52:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102e55:	a3 58 41 19 80       	mov    %eax,0x80194158
  log.dev = dev;
80102e5a:	8b 45 08             	mov    0x8(%ebp),%eax
80102e5d:	a3 64 41 19 80       	mov    %eax,0x80194164
  recover_from_log();
80102e62:	e8 b3 01 00 00       	call   8010301a <recover_from_log>
}
80102e67:	90                   	nop
80102e68:	c9                   	leave  
80102e69:	c3                   	ret    

80102e6a <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102e6a:	55                   	push   %ebp
80102e6b:	89 e5                	mov    %esp,%ebp
80102e6d:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102e70:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e77:	e9 95 00 00 00       	jmp    80102f11 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102e7c:	8b 15 54 41 19 80    	mov    0x80194154,%edx
80102e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e85:	01 d0                	add    %edx,%eax
80102e87:	83 c0 01             	add    $0x1,%eax
80102e8a:	89 c2                	mov    %eax,%edx
80102e8c:	a1 64 41 19 80       	mov    0x80194164,%eax
80102e91:	83 ec 08             	sub    $0x8,%esp
80102e94:	52                   	push   %edx
80102e95:	50                   	push   %eax
80102e96:	e8 66 d3 ff ff       	call   80100201 <bread>
80102e9b:	83 c4 10             	add    $0x10,%esp
80102e9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ea4:	83 c0 10             	add    $0x10,%eax
80102ea7:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
80102eae:	89 c2                	mov    %eax,%edx
80102eb0:	a1 64 41 19 80       	mov    0x80194164,%eax
80102eb5:	83 ec 08             	sub    $0x8,%esp
80102eb8:	52                   	push   %edx
80102eb9:	50                   	push   %eax
80102eba:	e8 42 d3 ff ff       	call   80100201 <bread>
80102ebf:	83 c4 10             	add    $0x10,%esp
80102ec2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102ec5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ec8:	8d 50 5c             	lea    0x5c(%eax),%edx
80102ecb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ece:	83 c0 5c             	add    $0x5c,%eax
80102ed1:	83 ec 04             	sub    $0x4,%esp
80102ed4:	68 00 02 00 00       	push   $0x200
80102ed9:	52                   	push   %edx
80102eda:	50                   	push   %eax
80102edb:	e8 c1 1c 00 00       	call   80104ba1 <memmove>
80102ee0:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80102ee3:	83 ec 0c             	sub    $0xc,%esp
80102ee6:	ff 75 ec             	push   -0x14(%ebp)
80102ee9:	e8 4c d3 ff ff       	call   8010023a <bwrite>
80102eee:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80102ef1:	83 ec 0c             	sub    $0xc,%esp
80102ef4:	ff 75 f0             	push   -0x10(%ebp)
80102ef7:	e8 87 d3 ff ff       	call   80100283 <brelse>
80102efc:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80102eff:	83 ec 0c             	sub    $0xc,%esp
80102f02:	ff 75 ec             	push   -0x14(%ebp)
80102f05:	e8 79 d3 ff ff       	call   80100283 <brelse>
80102f0a:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80102f0d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f11:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f16:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f19:	0f 8c 5d ff ff ff    	jl     80102e7c <install_trans+0x12>
  }
}
80102f1f:	90                   	nop
80102f20:	90                   	nop
80102f21:	c9                   	leave  
80102f22:	c3                   	ret    

80102f23 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80102f23:	55                   	push   %ebp
80102f24:	89 e5                	mov    %esp,%ebp
80102f26:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f29:	a1 54 41 19 80       	mov    0x80194154,%eax
80102f2e:	89 c2                	mov    %eax,%edx
80102f30:	a1 64 41 19 80       	mov    0x80194164,%eax
80102f35:	83 ec 08             	sub    $0x8,%esp
80102f38:	52                   	push   %edx
80102f39:	50                   	push   %eax
80102f3a:	e8 c2 d2 ff ff       	call   80100201 <bread>
80102f3f:	83 c4 10             	add    $0x10,%esp
80102f42:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80102f45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f48:	83 c0 5c             	add    $0x5c,%eax
80102f4b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80102f4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f51:	8b 00                	mov    (%eax),%eax
80102f53:	a3 68 41 19 80       	mov    %eax,0x80194168
  for (i = 0; i < log.lh.n; i++) {
80102f58:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102f5f:	eb 1b                	jmp    80102f7c <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80102f61:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f64:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f67:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80102f6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f6e:	83 c2 10             	add    $0x10,%edx
80102f71:	89 04 95 2c 41 19 80 	mov    %eax,-0x7fe6bed4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102f78:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f7c:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f81:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f84:	7c db                	jl     80102f61 <read_head+0x3e>
  }
  brelse(buf);
80102f86:	83 ec 0c             	sub    $0xc,%esp
80102f89:	ff 75 f0             	push   -0x10(%ebp)
80102f8c:	e8 f2 d2 ff ff       	call   80100283 <brelse>
80102f91:	83 c4 10             	add    $0x10,%esp
}
80102f94:	90                   	nop
80102f95:	c9                   	leave  
80102f96:	c3                   	ret    

80102f97 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102f97:	55                   	push   %ebp
80102f98:	89 e5                	mov    %esp,%ebp
80102f9a:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f9d:	a1 54 41 19 80       	mov    0x80194154,%eax
80102fa2:	89 c2                	mov    %eax,%edx
80102fa4:	a1 64 41 19 80       	mov    0x80194164,%eax
80102fa9:	83 ec 08             	sub    $0x8,%esp
80102fac:	52                   	push   %edx
80102fad:	50                   	push   %eax
80102fae:	e8 4e d2 ff ff       	call   80100201 <bread>
80102fb3:	83 c4 10             	add    $0x10,%esp
80102fb6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80102fb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fbc:	83 c0 5c             	add    $0x5c,%eax
80102fbf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80102fc2:	8b 15 68 41 19 80    	mov    0x80194168,%edx
80102fc8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fcb:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102fcd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102fd4:	eb 1b                	jmp    80102ff1 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80102fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fd9:	83 c0 10             	add    $0x10,%eax
80102fdc:	8b 0c 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%ecx
80102fe3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fe6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102fe9:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102fed:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102ff1:	a1 68 41 19 80       	mov    0x80194168,%eax
80102ff6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102ff9:	7c db                	jl     80102fd6 <write_head+0x3f>
  }
  bwrite(buf);
80102ffb:	83 ec 0c             	sub    $0xc,%esp
80102ffe:	ff 75 f0             	push   -0x10(%ebp)
80103001:	e8 34 d2 ff ff       	call   8010023a <bwrite>
80103006:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103009:	83 ec 0c             	sub    $0xc,%esp
8010300c:	ff 75 f0             	push   -0x10(%ebp)
8010300f:	e8 6f d2 ff ff       	call   80100283 <brelse>
80103014:	83 c4 10             	add    $0x10,%esp
}
80103017:	90                   	nop
80103018:	c9                   	leave  
80103019:	c3                   	ret    

8010301a <recover_from_log>:

static void
recover_from_log(void)
{
8010301a:	55                   	push   %ebp
8010301b:	89 e5                	mov    %esp,%ebp
8010301d:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103020:	e8 fe fe ff ff       	call   80102f23 <read_head>
  install_trans(); // if committed, copy from log to disk
80103025:	e8 40 fe ff ff       	call   80102e6a <install_trans>
  log.lh.n = 0;
8010302a:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
80103031:	00 00 00 
  write_head(); // clear the log
80103034:	e8 5e ff ff ff       	call   80102f97 <write_head>
}
80103039:	90                   	nop
8010303a:	c9                   	leave  
8010303b:	c3                   	ret    

8010303c <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010303c:	55                   	push   %ebp
8010303d:	89 e5                	mov    %esp,%ebp
8010303f:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103042:	83 ec 0c             	sub    $0xc,%esp
80103045:	68 20 41 19 80       	push   $0x80194120
8010304a:	e8 1d 18 00 00       	call   8010486c <acquire>
8010304f:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103052:	a1 60 41 19 80       	mov    0x80194160,%eax
80103057:	85 c0                	test   %eax,%eax
80103059:	74 17                	je     80103072 <begin_op+0x36>
      sleep(&log, &log.lock);
8010305b:	83 ec 08             	sub    $0x8,%esp
8010305e:	68 20 41 19 80       	push   $0x80194120
80103063:	68 20 41 19 80       	push   $0x80194120
80103068:	e8 6c 12 00 00       	call   801042d9 <sleep>
8010306d:	83 c4 10             	add    $0x10,%esp
80103070:	eb e0                	jmp    80103052 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103072:	8b 0d 68 41 19 80    	mov    0x80194168,%ecx
80103078:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010307d:	8d 50 01             	lea    0x1(%eax),%edx
80103080:	89 d0                	mov    %edx,%eax
80103082:	c1 e0 02             	shl    $0x2,%eax
80103085:	01 d0                	add    %edx,%eax
80103087:	01 c0                	add    %eax,%eax
80103089:	01 c8                	add    %ecx,%eax
8010308b:	83 f8 1e             	cmp    $0x1e,%eax
8010308e:	7e 17                	jle    801030a7 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103090:	83 ec 08             	sub    $0x8,%esp
80103093:	68 20 41 19 80       	push   $0x80194120
80103098:	68 20 41 19 80       	push   $0x80194120
8010309d:	e8 37 12 00 00       	call   801042d9 <sleep>
801030a2:	83 c4 10             	add    $0x10,%esp
801030a5:	eb ab                	jmp    80103052 <begin_op+0x16>
    } else {
      log.outstanding += 1;
801030a7:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030ac:	83 c0 01             	add    $0x1,%eax
801030af:	a3 5c 41 19 80       	mov    %eax,0x8019415c
      release(&log.lock);
801030b4:	83 ec 0c             	sub    $0xc,%esp
801030b7:	68 20 41 19 80       	push   $0x80194120
801030bc:	e8 19 18 00 00       	call   801048da <release>
801030c1:	83 c4 10             	add    $0x10,%esp
      break;
801030c4:	90                   	nop
    }
  }
}
801030c5:	90                   	nop
801030c6:	c9                   	leave  
801030c7:	c3                   	ret    

801030c8 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801030c8:	55                   	push   %ebp
801030c9:	89 e5                	mov    %esp,%ebp
801030cb:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801030ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801030d5:	83 ec 0c             	sub    $0xc,%esp
801030d8:	68 20 41 19 80       	push   $0x80194120
801030dd:	e8 8a 17 00 00       	call   8010486c <acquire>
801030e2:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801030e5:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030ea:	83 e8 01             	sub    $0x1,%eax
801030ed:	a3 5c 41 19 80       	mov    %eax,0x8019415c
  if(log.committing)
801030f2:	a1 60 41 19 80       	mov    0x80194160,%eax
801030f7:	85 c0                	test   %eax,%eax
801030f9:	74 0d                	je     80103108 <end_op+0x40>
    panic("log.committing");
801030fb:	83 ec 0c             	sub    $0xc,%esp
801030fe:	68 35 a3 10 80       	push   $0x8010a335
80103103:	e8 a1 d4 ff ff       	call   801005a9 <panic>
  if(log.outstanding == 0){
80103108:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010310d:	85 c0                	test   %eax,%eax
8010310f:	75 13                	jne    80103124 <end_op+0x5c>
    do_commit = 1;
80103111:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103118:	c7 05 60 41 19 80 01 	movl   $0x1,0x80194160
8010311f:	00 00 00 
80103122:	eb 10                	jmp    80103134 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103124:	83 ec 0c             	sub    $0xc,%esp
80103127:	68 20 41 19 80       	push   $0x80194120
8010312c:	e8 8f 12 00 00       	call   801043c0 <wakeup>
80103131:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103134:	83 ec 0c             	sub    $0xc,%esp
80103137:	68 20 41 19 80       	push   $0x80194120
8010313c:	e8 99 17 00 00       	call   801048da <release>
80103141:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103144:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103148:	74 3f                	je     80103189 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010314a:	e8 f6 00 00 00       	call   80103245 <commit>
    acquire(&log.lock);
8010314f:	83 ec 0c             	sub    $0xc,%esp
80103152:	68 20 41 19 80       	push   $0x80194120
80103157:	e8 10 17 00 00       	call   8010486c <acquire>
8010315c:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010315f:	c7 05 60 41 19 80 00 	movl   $0x0,0x80194160
80103166:	00 00 00 
    wakeup(&log);
80103169:	83 ec 0c             	sub    $0xc,%esp
8010316c:	68 20 41 19 80       	push   $0x80194120
80103171:	e8 4a 12 00 00       	call   801043c0 <wakeup>
80103176:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103179:	83 ec 0c             	sub    $0xc,%esp
8010317c:	68 20 41 19 80       	push   $0x80194120
80103181:	e8 54 17 00 00       	call   801048da <release>
80103186:	83 c4 10             	add    $0x10,%esp
  }
}
80103189:	90                   	nop
8010318a:	c9                   	leave  
8010318b:	c3                   	ret    

8010318c <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
8010318c:	55                   	push   %ebp
8010318d:	89 e5                	mov    %esp,%ebp
8010318f:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103192:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103199:	e9 95 00 00 00       	jmp    80103233 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010319e:	8b 15 54 41 19 80    	mov    0x80194154,%edx
801031a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031a7:	01 d0                	add    %edx,%eax
801031a9:	83 c0 01             	add    $0x1,%eax
801031ac:	89 c2                	mov    %eax,%edx
801031ae:	a1 64 41 19 80       	mov    0x80194164,%eax
801031b3:	83 ec 08             	sub    $0x8,%esp
801031b6:	52                   	push   %edx
801031b7:	50                   	push   %eax
801031b8:	e8 44 d0 ff ff       	call   80100201 <bread>
801031bd:	83 c4 10             	add    $0x10,%esp
801031c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801031c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031c6:	83 c0 10             	add    $0x10,%eax
801031c9:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801031d0:	89 c2                	mov    %eax,%edx
801031d2:	a1 64 41 19 80       	mov    0x80194164,%eax
801031d7:	83 ec 08             	sub    $0x8,%esp
801031da:	52                   	push   %edx
801031db:	50                   	push   %eax
801031dc:	e8 20 d0 ff ff       	call   80100201 <bread>
801031e1:	83 c4 10             	add    $0x10,%esp
801031e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801031e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031ea:	8d 50 5c             	lea    0x5c(%eax),%edx
801031ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031f0:	83 c0 5c             	add    $0x5c,%eax
801031f3:	83 ec 04             	sub    $0x4,%esp
801031f6:	68 00 02 00 00       	push   $0x200
801031fb:	52                   	push   %edx
801031fc:	50                   	push   %eax
801031fd:	e8 9f 19 00 00       	call   80104ba1 <memmove>
80103202:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103205:	83 ec 0c             	sub    $0xc,%esp
80103208:	ff 75 f0             	push   -0x10(%ebp)
8010320b:	e8 2a d0 ff ff       	call   8010023a <bwrite>
80103210:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103213:	83 ec 0c             	sub    $0xc,%esp
80103216:	ff 75 ec             	push   -0x14(%ebp)
80103219:	e8 65 d0 ff ff       	call   80100283 <brelse>
8010321e:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103221:	83 ec 0c             	sub    $0xc,%esp
80103224:	ff 75 f0             	push   -0x10(%ebp)
80103227:	e8 57 d0 ff ff       	call   80100283 <brelse>
8010322c:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
8010322f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103233:	a1 68 41 19 80       	mov    0x80194168,%eax
80103238:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010323b:	0f 8c 5d ff ff ff    	jl     8010319e <write_log+0x12>
  }
}
80103241:	90                   	nop
80103242:	90                   	nop
80103243:	c9                   	leave  
80103244:	c3                   	ret    

80103245 <commit>:

static void
commit()
{
80103245:	55                   	push   %ebp
80103246:	89 e5                	mov    %esp,%ebp
80103248:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010324b:	a1 68 41 19 80       	mov    0x80194168,%eax
80103250:	85 c0                	test   %eax,%eax
80103252:	7e 1e                	jle    80103272 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103254:	e8 33 ff ff ff       	call   8010318c <write_log>
    write_head();    // Write header to disk -- the real commit
80103259:	e8 39 fd ff ff       	call   80102f97 <write_head>
    install_trans(); // Now install writes to home locations
8010325e:	e8 07 fc ff ff       	call   80102e6a <install_trans>
    log.lh.n = 0;
80103263:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
8010326a:	00 00 00 
    write_head();    // Erase the transaction from the log
8010326d:	e8 25 fd ff ff       	call   80102f97 <write_head>
  }
}
80103272:	90                   	nop
80103273:	c9                   	leave  
80103274:	c3                   	ret    

80103275 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103275:	55                   	push   %ebp
80103276:	89 e5                	mov    %esp,%ebp
80103278:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010327b:	a1 68 41 19 80       	mov    0x80194168,%eax
80103280:	83 f8 1d             	cmp    $0x1d,%eax
80103283:	7f 12                	jg     80103297 <log_write+0x22>
80103285:	a1 68 41 19 80       	mov    0x80194168,%eax
8010328a:	8b 15 58 41 19 80    	mov    0x80194158,%edx
80103290:	83 ea 01             	sub    $0x1,%edx
80103293:	39 d0                	cmp    %edx,%eax
80103295:	7c 0d                	jl     801032a4 <log_write+0x2f>
    panic("too big a transaction");
80103297:	83 ec 0c             	sub    $0xc,%esp
8010329a:	68 44 a3 10 80       	push   $0x8010a344
8010329f:	e8 05 d3 ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
801032a4:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801032a9:	85 c0                	test   %eax,%eax
801032ab:	7f 0d                	jg     801032ba <log_write+0x45>
    panic("log_write outside of trans");
801032ad:	83 ec 0c             	sub    $0xc,%esp
801032b0:	68 5a a3 10 80       	push   $0x8010a35a
801032b5:	e8 ef d2 ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
801032ba:	83 ec 0c             	sub    $0xc,%esp
801032bd:	68 20 41 19 80       	push   $0x80194120
801032c2:	e8 a5 15 00 00       	call   8010486c <acquire>
801032c7:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801032ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032d1:	eb 1d                	jmp    801032f0 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801032d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032d6:	83 c0 10             	add    $0x10,%eax
801032d9:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801032e0:	89 c2                	mov    %eax,%edx
801032e2:	8b 45 08             	mov    0x8(%ebp),%eax
801032e5:	8b 40 08             	mov    0x8(%eax),%eax
801032e8:	39 c2                	cmp    %eax,%edx
801032ea:	74 10                	je     801032fc <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
801032ec:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801032f0:	a1 68 41 19 80       	mov    0x80194168,%eax
801032f5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801032f8:	7c d9                	jl     801032d3 <log_write+0x5e>
801032fa:	eb 01                	jmp    801032fd <log_write+0x88>
      break;
801032fc:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801032fd:	8b 45 08             	mov    0x8(%ebp),%eax
80103300:	8b 40 08             	mov    0x8(%eax),%eax
80103303:	89 c2                	mov    %eax,%edx
80103305:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103308:	83 c0 10             	add    $0x10,%eax
8010330b:	89 14 85 2c 41 19 80 	mov    %edx,-0x7fe6bed4(,%eax,4)
  if (i == log.lh.n)
80103312:	a1 68 41 19 80       	mov    0x80194168,%eax
80103317:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010331a:	75 0d                	jne    80103329 <log_write+0xb4>
    log.lh.n++;
8010331c:	a1 68 41 19 80       	mov    0x80194168,%eax
80103321:	83 c0 01             	add    $0x1,%eax
80103324:	a3 68 41 19 80       	mov    %eax,0x80194168
  b->flags |= B_DIRTY; // prevent eviction
80103329:	8b 45 08             	mov    0x8(%ebp),%eax
8010332c:	8b 00                	mov    (%eax),%eax
8010332e:	83 c8 04             	or     $0x4,%eax
80103331:	89 c2                	mov    %eax,%edx
80103333:	8b 45 08             	mov    0x8(%ebp),%eax
80103336:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103338:	83 ec 0c             	sub    $0xc,%esp
8010333b:	68 20 41 19 80       	push   $0x80194120
80103340:	e8 95 15 00 00       	call   801048da <release>
80103345:	83 c4 10             	add    $0x10,%esp
}
80103348:	90                   	nop
80103349:	c9                   	leave  
8010334a:	c3                   	ret    

8010334b <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010334b:	55                   	push   %ebp
8010334c:	89 e5                	mov    %esp,%ebp
8010334e:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103351:	8b 55 08             	mov    0x8(%ebp),%edx
80103354:	8b 45 0c             	mov    0xc(%ebp),%eax
80103357:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010335a:	f0 87 02             	lock xchg %eax,(%edx)
8010335d:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103360:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103363:	c9                   	leave  
80103364:	c3                   	ret    

80103365 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103365:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103369:	83 e4 f0             	and    $0xfffffff0,%esp
8010336c:	ff 71 fc             	push   -0x4(%ecx)
8010336f:	55                   	push   %ebp
80103370:	89 e5                	mov    %esp,%ebp
80103372:	51                   	push   %ecx
80103373:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
80103376:	e8 52 4b 00 00       	call   80107ecd <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010337b:	83 ec 08             	sub    $0x8,%esp
8010337e:	68 00 00 40 80       	push   $0x80400000
80103383:	68 00 80 19 80       	push   $0x80198000
80103388:	e8 de f2 ff ff       	call   8010266b <kinit1>
8010338d:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103390:	e8 52 41 00 00       	call   801074e7 <kvmalloc>
  mpinit_uefi();
80103395:	e8 f9 48 00 00       	call   80107c93 <mpinit_uefi>
  lapicinit();     // interrupt controller
8010339a:	e8 3c f6 ff ff       	call   801029db <lapicinit>
  seginit();       // segment descriptors
8010339f:	e8 db 3b 00 00       	call   80106f7f <seginit>
  picinit();    // disable pic
801033a4:	e8 9d 01 00 00       	call   80103546 <picinit>
  ioapicinit();    // another interrupt controller
801033a9:	e8 d8 f1 ff ff       	call   80102586 <ioapicinit>
  consoleinit();   // console hardware
801033ae:	e8 4c d7 ff ff       	call   80100aff <consoleinit>
  uartinit();      // serial port
801033b3:	e8 60 2f 00 00       	call   80106318 <uartinit>
  pinit();         // process table
801033b8:	e8 c2 05 00 00       	call   8010397f <pinit>
  tvinit();        // trap vectors
801033bd:	e8 27 2b 00 00       	call   80105ee9 <tvinit>
  binit();         // buffer cache
801033c2:	e8 9f cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033c7:	e8 f3 db ff ff       	call   80100fbf <fileinit>
  ideinit();       // disk 
801033cc:	e8 3d 6c 00 00       	call   8010a00e <ideinit>
  startothers();   // start other processors
801033d1:	e8 8a 00 00 00       	call   80103460 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033d6:	83 ec 08             	sub    $0x8,%esp
801033d9:	68 00 00 00 a0       	push   $0xa0000000
801033de:	68 00 00 40 80       	push   $0x80400000
801033e3:	e8 bc f2 ff ff       	call   801026a4 <kinit2>
801033e8:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033eb:	e8 36 4d 00 00       	call   80108126 <pci_init>
  arp_scan();
801033f0:	e8 6d 5a 00 00       	call   80108e62 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801033f5:	e8 63 07 00 00       	call   80103b5d <userinit>

  mpmain();        // finish this processor's setup
801033fa:	e8 1a 00 00 00       	call   80103419 <mpmain>

801033ff <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801033ff:	55                   	push   %ebp
80103400:	89 e5                	mov    %esp,%ebp
80103402:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103405:	e8 f5 40 00 00       	call   801074ff <switchkvm>
  seginit();
8010340a:	e8 70 3b 00 00       	call   80106f7f <seginit>
  lapicinit();
8010340f:	e8 c7 f5 ff ff       	call   801029db <lapicinit>
  mpmain();
80103414:	e8 00 00 00 00       	call   80103419 <mpmain>

80103419 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103419:	55                   	push   %ebp
8010341a:	89 e5                	mov    %esp,%ebp
8010341c:	53                   	push   %ebx
8010341d:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103420:	e8 78 05 00 00       	call   8010399d <cpuid>
80103425:	89 c3                	mov    %eax,%ebx
80103427:	e8 71 05 00 00       	call   8010399d <cpuid>
8010342c:	83 ec 04             	sub    $0x4,%esp
8010342f:	53                   	push   %ebx
80103430:	50                   	push   %eax
80103431:	68 75 a3 10 80       	push   $0x8010a375
80103436:	e8 b9 cf ff ff       	call   801003f4 <cprintf>
8010343b:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
8010343e:	e8 1c 2c 00 00       	call   8010605f <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103443:	e8 70 05 00 00       	call   801039b8 <mycpu>
80103448:	05 a0 00 00 00       	add    $0xa0,%eax
8010344d:	83 ec 08             	sub    $0x8,%esp
80103450:	6a 01                	push   $0x1
80103452:	50                   	push   %eax
80103453:	e8 f3 fe ff ff       	call   8010334b <xchg>
80103458:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010345b:	e8 88 0c 00 00       	call   801040e8 <scheduler>

80103460 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103460:	55                   	push   %ebp
80103461:	89 e5                	mov    %esp,%ebp
80103463:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103466:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010346d:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103472:	83 ec 04             	sub    $0x4,%esp
80103475:	50                   	push   %eax
80103476:	68 18 f5 10 80       	push   $0x8010f518
8010347b:	ff 75 f0             	push   -0x10(%ebp)
8010347e:	e8 1e 17 00 00       	call   80104ba1 <memmove>
80103483:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103486:	c7 45 f4 80 69 19 80 	movl   $0x80196980,-0xc(%ebp)
8010348d:	eb 79                	jmp    80103508 <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
8010348f:	e8 24 05 00 00       	call   801039b8 <mycpu>
80103494:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103497:	74 67                	je     80103500 <startothers+0xa0>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103499:	e8 02 f3 ff ff       	call   801027a0 <kalloc>
8010349e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801034a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034a4:	83 e8 04             	sub    $0x4,%eax
801034a7:	8b 55 ec             	mov    -0x14(%ebp),%edx
801034aa:	81 c2 00 10 00 00    	add    $0x1000,%edx
801034b0:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801034b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034b5:	83 e8 08             	sub    $0x8,%eax
801034b8:	c7 00 ff 33 10 80    	movl   $0x801033ff,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801034be:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
801034c3:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034cc:	83 e8 0c             	sub    $0xc,%eax
801034cf:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801034d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034d4:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034dd:	0f b6 00             	movzbl (%eax),%eax
801034e0:	0f b6 c0             	movzbl %al,%eax
801034e3:	83 ec 08             	sub    $0x8,%esp
801034e6:	52                   	push   %edx
801034e7:	50                   	push   %eax
801034e8:	e8 50 f6 ff ff       	call   80102b3d <lapicstartap>
801034ed:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801034f0:	90                   	nop
801034f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034f4:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801034fa:	85 c0                	test   %eax,%eax
801034fc:	74 f3                	je     801034f1 <startothers+0x91>
801034fe:	eb 01                	jmp    80103501 <startothers+0xa1>
      continue;
80103500:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103501:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103508:	a1 40 6c 19 80       	mov    0x80196c40,%eax
8010350d:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103513:	05 80 69 19 80       	add    $0x80196980,%eax
80103518:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010351b:	0f 82 6e ff ff ff    	jb     8010348f <startothers+0x2f>
      ;
  }
}
80103521:	90                   	nop
80103522:	90                   	nop
80103523:	c9                   	leave  
80103524:	c3                   	ret    

80103525 <outb>:
{
80103525:	55                   	push   %ebp
80103526:	89 e5                	mov    %esp,%ebp
80103528:	83 ec 08             	sub    $0x8,%esp
8010352b:	8b 45 08             	mov    0x8(%ebp),%eax
8010352e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103531:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103535:	89 d0                	mov    %edx,%eax
80103537:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010353a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010353e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103542:	ee                   	out    %al,(%dx)
}
80103543:	90                   	nop
80103544:	c9                   	leave  
80103545:	c3                   	ret    

80103546 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103546:	55                   	push   %ebp
80103547:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103549:	68 ff 00 00 00       	push   $0xff
8010354e:	6a 21                	push   $0x21
80103550:	e8 d0 ff ff ff       	call   80103525 <outb>
80103555:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103558:	68 ff 00 00 00       	push   $0xff
8010355d:	68 a1 00 00 00       	push   $0xa1
80103562:	e8 be ff ff ff       	call   80103525 <outb>
80103567:	83 c4 08             	add    $0x8,%esp
}
8010356a:	90                   	nop
8010356b:	c9                   	leave  
8010356c:	c3                   	ret    

8010356d <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
8010356d:	55                   	push   %ebp
8010356e:	89 e5                	mov    %esp,%ebp
80103570:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103573:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
8010357a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010357d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103583:	8b 45 0c             	mov    0xc(%ebp),%eax
80103586:	8b 10                	mov    (%eax),%edx
80103588:	8b 45 08             	mov    0x8(%ebp),%eax
8010358b:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010358d:	e8 4b da ff ff       	call   80100fdd <filealloc>
80103592:	8b 55 08             	mov    0x8(%ebp),%edx
80103595:	89 02                	mov    %eax,(%edx)
80103597:	8b 45 08             	mov    0x8(%ebp),%eax
8010359a:	8b 00                	mov    (%eax),%eax
8010359c:	85 c0                	test   %eax,%eax
8010359e:	0f 84 c8 00 00 00    	je     8010366c <pipealloc+0xff>
801035a4:	e8 34 da ff ff       	call   80100fdd <filealloc>
801035a9:	8b 55 0c             	mov    0xc(%ebp),%edx
801035ac:	89 02                	mov    %eax,(%edx)
801035ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801035b1:	8b 00                	mov    (%eax),%eax
801035b3:	85 c0                	test   %eax,%eax
801035b5:	0f 84 b1 00 00 00    	je     8010366c <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801035bb:	e8 e0 f1 ff ff       	call   801027a0 <kalloc>
801035c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801035c3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035c7:	0f 84 a2 00 00 00    	je     8010366f <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
801035cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035d0:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801035d7:	00 00 00 
  p->writeopen = 1;
801035da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035dd:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801035e4:	00 00 00 
  p->nwrite = 0;
801035e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035ea:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801035f1:	00 00 00 
  p->nread = 0;
801035f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035f7:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801035fe:	00 00 00 
  initlock(&p->lock, "pipe");
80103601:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103604:	83 ec 08             	sub    $0x8,%esp
80103607:	68 89 a3 10 80       	push   $0x8010a389
8010360c:	50                   	push   %eax
8010360d:	e8 38 12 00 00       	call   8010484a <initlock>
80103612:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103615:	8b 45 08             	mov    0x8(%ebp),%eax
80103618:	8b 00                	mov    (%eax),%eax
8010361a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103620:	8b 45 08             	mov    0x8(%ebp),%eax
80103623:	8b 00                	mov    (%eax),%eax
80103625:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103629:	8b 45 08             	mov    0x8(%ebp),%eax
8010362c:	8b 00                	mov    (%eax),%eax
8010362e:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103632:	8b 45 08             	mov    0x8(%ebp),%eax
80103635:	8b 00                	mov    (%eax),%eax
80103637:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010363a:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010363d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103640:	8b 00                	mov    (%eax),%eax
80103642:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103648:	8b 45 0c             	mov    0xc(%ebp),%eax
8010364b:	8b 00                	mov    (%eax),%eax
8010364d:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103651:	8b 45 0c             	mov    0xc(%ebp),%eax
80103654:	8b 00                	mov    (%eax),%eax
80103656:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010365a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010365d:	8b 00                	mov    (%eax),%eax
8010365f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103662:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103665:	b8 00 00 00 00       	mov    $0x0,%eax
8010366a:	eb 51                	jmp    801036bd <pipealloc+0x150>
    goto bad;
8010366c:	90                   	nop
8010366d:	eb 01                	jmp    80103670 <pipealloc+0x103>
    goto bad;
8010366f:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103670:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103674:	74 0e                	je     80103684 <pipealloc+0x117>
    kfree((char*)p);
80103676:	83 ec 0c             	sub    $0xc,%esp
80103679:	ff 75 f4             	push   -0xc(%ebp)
8010367c:	e8 85 f0 ff ff       	call   80102706 <kfree>
80103681:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103684:	8b 45 08             	mov    0x8(%ebp),%eax
80103687:	8b 00                	mov    (%eax),%eax
80103689:	85 c0                	test   %eax,%eax
8010368b:	74 11                	je     8010369e <pipealloc+0x131>
    fileclose(*f0);
8010368d:	8b 45 08             	mov    0x8(%ebp),%eax
80103690:	8b 00                	mov    (%eax),%eax
80103692:	83 ec 0c             	sub    $0xc,%esp
80103695:	50                   	push   %eax
80103696:	e8 00 da ff ff       	call   8010109b <fileclose>
8010369b:	83 c4 10             	add    $0x10,%esp
  if(*f1)
8010369e:	8b 45 0c             	mov    0xc(%ebp),%eax
801036a1:	8b 00                	mov    (%eax),%eax
801036a3:	85 c0                	test   %eax,%eax
801036a5:	74 11                	je     801036b8 <pipealloc+0x14b>
    fileclose(*f1);
801036a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801036aa:	8b 00                	mov    (%eax),%eax
801036ac:	83 ec 0c             	sub    $0xc,%esp
801036af:	50                   	push   %eax
801036b0:	e8 e6 d9 ff ff       	call   8010109b <fileclose>
801036b5:	83 c4 10             	add    $0x10,%esp
  return -1;
801036b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801036bd:	c9                   	leave  
801036be:	c3                   	ret    

801036bf <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801036bf:	55                   	push   %ebp
801036c0:	89 e5                	mov    %esp,%ebp
801036c2:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801036c5:	8b 45 08             	mov    0x8(%ebp),%eax
801036c8:	83 ec 0c             	sub    $0xc,%esp
801036cb:	50                   	push   %eax
801036cc:	e8 9b 11 00 00       	call   8010486c <acquire>
801036d1:	83 c4 10             	add    $0x10,%esp
  if(writable){
801036d4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801036d8:	74 23                	je     801036fd <pipeclose+0x3e>
    p->writeopen = 0;
801036da:	8b 45 08             	mov    0x8(%ebp),%eax
801036dd:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801036e4:	00 00 00 
    wakeup(&p->nread);
801036e7:	8b 45 08             	mov    0x8(%ebp),%eax
801036ea:	05 34 02 00 00       	add    $0x234,%eax
801036ef:	83 ec 0c             	sub    $0xc,%esp
801036f2:	50                   	push   %eax
801036f3:	e8 c8 0c 00 00       	call   801043c0 <wakeup>
801036f8:	83 c4 10             	add    $0x10,%esp
801036fb:	eb 21                	jmp    8010371e <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801036fd:	8b 45 08             	mov    0x8(%ebp),%eax
80103700:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103707:	00 00 00 
    wakeup(&p->nwrite);
8010370a:	8b 45 08             	mov    0x8(%ebp),%eax
8010370d:	05 38 02 00 00       	add    $0x238,%eax
80103712:	83 ec 0c             	sub    $0xc,%esp
80103715:	50                   	push   %eax
80103716:	e8 a5 0c 00 00       	call   801043c0 <wakeup>
8010371b:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010371e:	8b 45 08             	mov    0x8(%ebp),%eax
80103721:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103727:	85 c0                	test   %eax,%eax
80103729:	75 2c                	jne    80103757 <pipeclose+0x98>
8010372b:	8b 45 08             	mov    0x8(%ebp),%eax
8010372e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103734:	85 c0                	test   %eax,%eax
80103736:	75 1f                	jne    80103757 <pipeclose+0x98>
    release(&p->lock);
80103738:	8b 45 08             	mov    0x8(%ebp),%eax
8010373b:	83 ec 0c             	sub    $0xc,%esp
8010373e:	50                   	push   %eax
8010373f:	e8 96 11 00 00       	call   801048da <release>
80103744:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103747:	83 ec 0c             	sub    $0xc,%esp
8010374a:	ff 75 08             	push   0x8(%ebp)
8010374d:	e8 b4 ef ff ff       	call   80102706 <kfree>
80103752:	83 c4 10             	add    $0x10,%esp
80103755:	eb 10                	jmp    80103767 <pipeclose+0xa8>
  } else
    release(&p->lock);
80103757:	8b 45 08             	mov    0x8(%ebp),%eax
8010375a:	83 ec 0c             	sub    $0xc,%esp
8010375d:	50                   	push   %eax
8010375e:	e8 77 11 00 00       	call   801048da <release>
80103763:	83 c4 10             	add    $0x10,%esp
}
80103766:	90                   	nop
80103767:	90                   	nop
80103768:	c9                   	leave  
80103769:	c3                   	ret    

8010376a <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010376a:	55                   	push   %ebp
8010376b:	89 e5                	mov    %esp,%ebp
8010376d:	53                   	push   %ebx
8010376e:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103771:	8b 45 08             	mov    0x8(%ebp),%eax
80103774:	83 ec 0c             	sub    $0xc,%esp
80103777:	50                   	push   %eax
80103778:	e8 ef 10 00 00       	call   8010486c <acquire>
8010377d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103780:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103787:	e9 ad 00 00 00       	jmp    80103839 <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
8010378c:	8b 45 08             	mov    0x8(%ebp),%eax
8010378f:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103795:	85 c0                	test   %eax,%eax
80103797:	74 0c                	je     801037a5 <pipewrite+0x3b>
80103799:	e8 92 02 00 00       	call   80103a30 <myproc>
8010379e:	8b 40 24             	mov    0x24(%eax),%eax
801037a1:	85 c0                	test   %eax,%eax
801037a3:	74 19                	je     801037be <pipewrite+0x54>
        release(&p->lock);
801037a5:	8b 45 08             	mov    0x8(%ebp),%eax
801037a8:	83 ec 0c             	sub    $0xc,%esp
801037ab:	50                   	push   %eax
801037ac:	e8 29 11 00 00       	call   801048da <release>
801037b1:	83 c4 10             	add    $0x10,%esp
        return -1;
801037b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801037b9:	e9 a9 00 00 00       	jmp    80103867 <pipewrite+0xfd>
      }
      wakeup(&p->nread);
801037be:	8b 45 08             	mov    0x8(%ebp),%eax
801037c1:	05 34 02 00 00       	add    $0x234,%eax
801037c6:	83 ec 0c             	sub    $0xc,%esp
801037c9:	50                   	push   %eax
801037ca:	e8 f1 0b 00 00       	call   801043c0 <wakeup>
801037cf:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037d2:	8b 45 08             	mov    0x8(%ebp),%eax
801037d5:	8b 55 08             	mov    0x8(%ebp),%edx
801037d8:	81 c2 38 02 00 00    	add    $0x238,%edx
801037de:	83 ec 08             	sub    $0x8,%esp
801037e1:	50                   	push   %eax
801037e2:	52                   	push   %edx
801037e3:	e8 f1 0a 00 00       	call   801042d9 <sleep>
801037e8:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801037eb:	8b 45 08             	mov    0x8(%ebp),%eax
801037ee:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801037f4:	8b 45 08             	mov    0x8(%ebp),%eax
801037f7:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801037fd:	05 00 02 00 00       	add    $0x200,%eax
80103802:	39 c2                	cmp    %eax,%edx
80103804:	74 86                	je     8010378c <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103806:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103809:	8b 45 0c             	mov    0xc(%ebp),%eax
8010380c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010380f:	8b 45 08             	mov    0x8(%ebp),%eax
80103812:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103818:	8d 48 01             	lea    0x1(%eax),%ecx
8010381b:	8b 55 08             	mov    0x8(%ebp),%edx
8010381e:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103824:	25 ff 01 00 00       	and    $0x1ff,%eax
80103829:	89 c1                	mov    %eax,%ecx
8010382b:	0f b6 13             	movzbl (%ebx),%edx
8010382e:	8b 45 08             	mov    0x8(%ebp),%eax
80103831:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103835:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010383c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010383f:	7c aa                	jl     801037eb <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103841:	8b 45 08             	mov    0x8(%ebp),%eax
80103844:	05 34 02 00 00       	add    $0x234,%eax
80103849:	83 ec 0c             	sub    $0xc,%esp
8010384c:	50                   	push   %eax
8010384d:	e8 6e 0b 00 00       	call   801043c0 <wakeup>
80103852:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103855:	8b 45 08             	mov    0x8(%ebp),%eax
80103858:	83 ec 0c             	sub    $0xc,%esp
8010385b:	50                   	push   %eax
8010385c:	e8 79 10 00 00       	call   801048da <release>
80103861:	83 c4 10             	add    $0x10,%esp
  return n;
80103864:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103867:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010386a:	c9                   	leave  
8010386b:	c3                   	ret    

8010386c <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010386c:	55                   	push   %ebp
8010386d:	89 e5                	mov    %esp,%ebp
8010386f:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103872:	8b 45 08             	mov    0x8(%ebp),%eax
80103875:	83 ec 0c             	sub    $0xc,%esp
80103878:	50                   	push   %eax
80103879:	e8 ee 0f 00 00       	call   8010486c <acquire>
8010387e:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103881:	eb 3e                	jmp    801038c1 <piperead+0x55>
    if(myproc()->killed){
80103883:	e8 a8 01 00 00       	call   80103a30 <myproc>
80103888:	8b 40 24             	mov    0x24(%eax),%eax
8010388b:	85 c0                	test   %eax,%eax
8010388d:	74 19                	je     801038a8 <piperead+0x3c>
      release(&p->lock);
8010388f:	8b 45 08             	mov    0x8(%ebp),%eax
80103892:	83 ec 0c             	sub    $0xc,%esp
80103895:	50                   	push   %eax
80103896:	e8 3f 10 00 00       	call   801048da <release>
8010389b:	83 c4 10             	add    $0x10,%esp
      return -1;
8010389e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801038a3:	e9 be 00 00 00       	jmp    80103966 <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801038a8:	8b 45 08             	mov    0x8(%ebp),%eax
801038ab:	8b 55 08             	mov    0x8(%ebp),%edx
801038ae:	81 c2 34 02 00 00    	add    $0x234,%edx
801038b4:	83 ec 08             	sub    $0x8,%esp
801038b7:	50                   	push   %eax
801038b8:	52                   	push   %edx
801038b9:	e8 1b 0a 00 00       	call   801042d9 <sleep>
801038be:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801038c1:	8b 45 08             	mov    0x8(%ebp),%eax
801038c4:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038ca:	8b 45 08             	mov    0x8(%ebp),%eax
801038cd:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038d3:	39 c2                	cmp    %eax,%edx
801038d5:	75 0d                	jne    801038e4 <piperead+0x78>
801038d7:	8b 45 08             	mov    0x8(%ebp),%eax
801038da:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801038e0:	85 c0                	test   %eax,%eax
801038e2:	75 9f                	jne    80103883 <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801038e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038eb:	eb 48                	jmp    80103935 <piperead+0xc9>
    if(p->nread == p->nwrite)
801038ed:	8b 45 08             	mov    0x8(%ebp),%eax
801038f0:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038f6:	8b 45 08             	mov    0x8(%ebp),%eax
801038f9:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038ff:	39 c2                	cmp    %eax,%edx
80103901:	74 3c                	je     8010393f <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103903:	8b 45 08             	mov    0x8(%ebp),%eax
80103906:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010390c:	8d 48 01             	lea    0x1(%eax),%ecx
8010390f:	8b 55 08             	mov    0x8(%ebp),%edx
80103912:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103918:	25 ff 01 00 00       	and    $0x1ff,%eax
8010391d:	89 c1                	mov    %eax,%ecx
8010391f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103922:	8b 45 0c             	mov    0xc(%ebp),%eax
80103925:	01 c2                	add    %eax,%edx
80103927:	8b 45 08             	mov    0x8(%ebp),%eax
8010392a:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
8010392f:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103931:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103935:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103938:	3b 45 10             	cmp    0x10(%ebp),%eax
8010393b:	7c b0                	jl     801038ed <piperead+0x81>
8010393d:	eb 01                	jmp    80103940 <piperead+0xd4>
      break;
8010393f:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103940:	8b 45 08             	mov    0x8(%ebp),%eax
80103943:	05 38 02 00 00       	add    $0x238,%eax
80103948:	83 ec 0c             	sub    $0xc,%esp
8010394b:	50                   	push   %eax
8010394c:	e8 6f 0a 00 00       	call   801043c0 <wakeup>
80103951:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103954:	8b 45 08             	mov    0x8(%ebp),%eax
80103957:	83 ec 0c             	sub    $0xc,%esp
8010395a:	50                   	push   %eax
8010395b:	e8 7a 0f 00 00       	call   801048da <release>
80103960:	83 c4 10             	add    $0x10,%esp
  return i;
80103963:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103966:	c9                   	leave  
80103967:	c3                   	ret    

80103968 <readeflags>:
{
80103968:	55                   	push   %ebp
80103969:	89 e5                	mov    %esp,%ebp
8010396b:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010396e:	9c                   	pushf  
8010396f:	58                   	pop    %eax
80103970:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103973:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103976:	c9                   	leave  
80103977:	c3                   	ret    

80103978 <sti>:
{
80103978:	55                   	push   %ebp
80103979:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010397b:	fb                   	sti    
}
8010397c:	90                   	nop
8010397d:	5d                   	pop    %ebp
8010397e:	c3                   	ret    

8010397f <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010397f:	55                   	push   %ebp
80103980:	89 e5                	mov    %esp,%ebp
80103982:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103985:	83 ec 08             	sub    $0x8,%esp
80103988:	68 90 a3 10 80       	push   $0x8010a390
8010398d:	68 00 42 19 80       	push   $0x80194200
80103992:	e8 b3 0e 00 00       	call   8010484a <initlock>
80103997:	83 c4 10             	add    $0x10,%esp
}
8010399a:	90                   	nop
8010399b:	c9                   	leave  
8010399c:	c3                   	ret    

8010399d <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
8010399d:	55                   	push   %ebp
8010399e:	89 e5                	mov    %esp,%ebp
801039a0:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801039a3:	e8 10 00 00 00       	call   801039b8 <mycpu>
801039a8:	2d 80 69 19 80       	sub    $0x80196980,%eax
801039ad:	c1 f8 04             	sar    $0x4,%eax
801039b0:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801039b6:	c9                   	leave  
801039b7:	c3                   	ret    

801039b8 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801039b8:	55                   	push   %ebp
801039b9:	89 e5                	mov    %esp,%ebp
801039bb:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
801039be:	e8 a5 ff ff ff       	call   80103968 <readeflags>
801039c3:	25 00 02 00 00       	and    $0x200,%eax
801039c8:	85 c0                	test   %eax,%eax
801039ca:	74 0d                	je     801039d9 <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
801039cc:	83 ec 0c             	sub    $0xc,%esp
801039cf:	68 98 a3 10 80       	push   $0x8010a398
801039d4:	e8 d0 cb ff ff       	call   801005a9 <panic>
  }

  apicid = lapicid();
801039d9:	e8 1c f1 ff ff       	call   80102afa <lapicid>
801039de:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801039e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801039e8:	eb 2d                	jmp    80103a17 <mycpu+0x5f>
    if (cpus[i].apicid == apicid){
801039ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039ed:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801039f3:	05 80 69 19 80       	add    $0x80196980,%eax
801039f8:	0f b6 00             	movzbl (%eax),%eax
801039fb:	0f b6 c0             	movzbl %al,%eax
801039fe:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103a01:	75 10                	jne    80103a13 <mycpu+0x5b>
      return &cpus[i];
80103a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a06:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103a0c:	05 80 69 19 80       	add    $0x80196980,%eax
80103a11:	eb 1b                	jmp    80103a2e <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103a13:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a17:	a1 40 6c 19 80       	mov    0x80196c40,%eax
80103a1c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a1f:	7c c9                	jl     801039ea <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103a21:	83 ec 0c             	sub    $0xc,%esp
80103a24:	68 be a3 10 80       	push   $0x8010a3be
80103a29:	e8 7b cb ff ff       	call   801005a9 <panic>
}
80103a2e:	c9                   	leave  
80103a2f:	c3                   	ret    

80103a30 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103a30:	55                   	push   %ebp
80103a31:	89 e5                	mov    %esp,%ebp
80103a33:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103a36:	e8 9c 0f 00 00       	call   801049d7 <pushcli>
  c = mycpu();
80103a3b:	e8 78 ff ff ff       	call   801039b8 <mycpu>
80103a40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a46:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103a4f:	e8 d0 0f 00 00       	call   80104a24 <popcli>
  return p;
80103a54:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103a57:	c9                   	leave  
80103a58:	c3                   	ret    

80103a59 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103a59:	55                   	push   %ebp
80103a5a:	89 e5                	mov    %esp,%ebp
80103a5c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103a5f:	83 ec 0c             	sub    $0xc,%esp
80103a62:	68 00 42 19 80       	push   $0x80194200
80103a67:	e8 00 0e 00 00       	call   8010486c <acquire>
80103a6c:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a6f:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103a76:	eb 0e                	jmp    80103a86 <allocproc+0x2d>
    if(p->state == UNUSED){
80103a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a7b:	8b 40 0c             	mov    0xc(%eax),%eax
80103a7e:	85 c0                	test   %eax,%eax
80103a80:	74 27                	je     80103aa9 <allocproc+0x50>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a82:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80103a86:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
80103a8d:	72 e9                	jb     80103a78 <allocproc+0x1f>
      goto found;
    }

  release(&ptable.lock);
80103a8f:	83 ec 0c             	sub    $0xc,%esp
80103a92:	68 00 42 19 80       	push   $0x80194200
80103a97:	e8 3e 0e 00 00       	call   801048da <release>
80103a9c:	83 c4 10             	add    $0x10,%esp
  return 0;
80103a9f:	b8 00 00 00 00       	mov    $0x0,%eax
80103aa4:	e9 b2 00 00 00       	jmp    80103b5b <allocproc+0x102>
      goto found;
80103aa9:	90                   	nop

found:
  p->state = EMBRYO;
80103aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aad:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103ab4:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103ab9:	8d 50 01             	lea    0x1(%eax),%edx
80103abc:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103ac2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ac5:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80103ac8:	83 ec 0c             	sub    $0xc,%esp
80103acb:	68 00 42 19 80       	push   $0x80194200
80103ad0:	e8 05 0e 00 00       	call   801048da <release>
80103ad5:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103ad8:	e8 c3 ec ff ff       	call   801027a0 <kalloc>
80103add:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ae0:	89 42 08             	mov    %eax,0x8(%edx)
80103ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae6:	8b 40 08             	mov    0x8(%eax),%eax
80103ae9:	85 c0                	test   %eax,%eax
80103aeb:	75 11                	jne    80103afe <allocproc+0xa5>
    p->state = UNUSED;
80103aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103af7:	b8 00 00 00 00       	mov    $0x0,%eax
80103afc:	eb 5d                	jmp    80103b5b <allocproc+0x102>
  }
  sp = p->kstack + KSTACKSIZE;
80103afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b01:	8b 40 08             	mov    0x8(%eax),%eax
80103b04:	05 00 10 00 00       	add    $0x1000,%eax
80103b09:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103b0c:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b13:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b16:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103b19:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103b1d:	ba a3 5e 10 80       	mov    $0x80105ea3,%edx
80103b22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b25:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103b27:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80103b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b2e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b31:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103b34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b37:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b3a:	83 ec 04             	sub    $0x4,%esp
80103b3d:	6a 14                	push   $0x14
80103b3f:	6a 00                	push   $0x0
80103b41:	50                   	push   %eax
80103b42:	e8 9b 0f 00 00       	call   80104ae2 <memset>
80103b47:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b4d:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b50:	ba 93 42 10 80       	mov    $0x80104293,%edx
80103b55:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103b5b:	c9                   	leave  
80103b5c:	c3                   	ret    

80103b5d <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103b5d:	55                   	push   %ebp
80103b5e:	89 e5                	mov    %esp,%ebp
80103b60:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103b63:	e8 f1 fe ff ff       	call   80103a59 <allocproc>
80103b68:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b6e:	a3 34 61 19 80       	mov    %eax,0x80196134
  if((p->pgdir = setupkvm()) == 0){
80103b73:	e8 83 38 00 00       	call   801073fb <setupkvm>
80103b78:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b7b:	89 42 04             	mov    %eax,0x4(%edx)
80103b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b81:	8b 40 04             	mov    0x4(%eax),%eax
80103b84:	85 c0                	test   %eax,%eax
80103b86:	75 0d                	jne    80103b95 <userinit+0x38>
    panic("userinit: out of memory?");
80103b88:	83 ec 0c             	sub    $0xc,%esp
80103b8b:	68 ce a3 10 80       	push   $0x8010a3ce
80103b90:	e8 14 ca ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103b95:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103b9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b9d:	8b 40 04             	mov    0x4(%eax),%eax
80103ba0:	83 ec 04             	sub    $0x4,%esp
80103ba3:	52                   	push   %edx
80103ba4:	68 ec f4 10 80       	push   $0x8010f4ec
80103ba9:	50                   	push   %eax
80103baa:	e8 08 3b 00 00       	call   801076b7 <inituvm>
80103baf:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb5:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103bbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bbe:	8b 40 18             	mov    0x18(%eax),%eax
80103bc1:	83 ec 04             	sub    $0x4,%esp
80103bc4:	6a 4c                	push   $0x4c
80103bc6:	6a 00                	push   $0x0
80103bc8:	50                   	push   %eax
80103bc9:	e8 14 0f 00 00       	call   80104ae2 <memset>
80103bce:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd4:	8b 40 18             	mov    0x18(%eax),%eax
80103bd7:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103bdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be0:	8b 40 18             	mov    0x18(%eax),%eax
80103be3:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bec:	8b 50 18             	mov    0x18(%eax),%edx
80103bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf2:	8b 40 18             	mov    0x18(%eax),%eax
80103bf5:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103bf9:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103bfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c00:	8b 50 18             	mov    0x18(%eax),%edx
80103c03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c06:	8b 40 18             	mov    0x18(%eax),%eax
80103c09:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c0d:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c14:	8b 40 18             	mov    0x18(%eax),%eax
80103c17:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c21:	8b 40 18             	mov    0x18(%eax),%eax
80103c24:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c2e:	8b 40 18             	mov    0x18(%eax),%eax
80103c31:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c3b:	83 c0 6c             	add    $0x6c,%eax
80103c3e:	83 ec 04             	sub    $0x4,%esp
80103c41:	6a 10                	push   $0x10
80103c43:	68 e7 a3 10 80       	push   $0x8010a3e7
80103c48:	50                   	push   %eax
80103c49:	e8 97 10 00 00       	call   80104ce5 <safestrcpy>
80103c4e:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103c51:	83 ec 0c             	sub    $0xc,%esp
80103c54:	68 f0 a3 10 80       	push   $0x8010a3f0
80103c59:	e8 bf e8 ff ff       	call   8010251d <namei>
80103c5e:	83 c4 10             	add    $0x10,%esp
80103c61:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c64:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103c67:	83 ec 0c             	sub    $0xc,%esp
80103c6a:	68 00 42 19 80       	push   $0x80194200
80103c6f:	e8 f8 0b 00 00       	call   8010486c <acquire>
80103c74:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c7a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103c81:	83 ec 0c             	sub    $0xc,%esp
80103c84:	68 00 42 19 80       	push   $0x80194200
80103c89:	e8 4c 0c 00 00       	call   801048da <release>
80103c8e:	83 c4 10             	add    $0x10,%esp
}
80103c91:	90                   	nop
80103c92:	c9                   	leave  
80103c93:	c3                   	ret    

80103c94 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103c94:	55                   	push   %ebp
80103c95:	89 e5                	mov    %esp,%ebp
80103c97:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103c9a:	e8 91 fd ff ff       	call   80103a30 <myproc>
80103c9f:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103ca2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ca5:	8b 00                	mov    (%eax),%eax
80103ca7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103caa:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103cae:	7e 2e                	jle    80103cde <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103cb0:	8b 55 08             	mov    0x8(%ebp),%edx
80103cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb6:	01 c2                	add    %eax,%edx
80103cb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cbb:	8b 40 04             	mov    0x4(%eax),%eax
80103cbe:	83 ec 04             	sub    $0x4,%esp
80103cc1:	52                   	push   %edx
80103cc2:	ff 75 f4             	push   -0xc(%ebp)
80103cc5:	50                   	push   %eax
80103cc6:	e8 29 3b 00 00       	call   801077f4 <allocuvm>
80103ccb:	83 c4 10             	add    $0x10,%esp
80103cce:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cd1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103cd5:	75 3b                	jne    80103d12 <growproc+0x7e>
      return -1;
80103cd7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103cdc:	eb 4f                	jmp    80103d2d <growproc+0x99>
  } else if(n < 0){
80103cde:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103ce2:	79 2e                	jns    80103d12 <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103ce4:	8b 55 08             	mov    0x8(%ebp),%edx
80103ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cea:	01 c2                	add    %eax,%edx
80103cec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cef:	8b 40 04             	mov    0x4(%eax),%eax
80103cf2:	83 ec 04             	sub    $0x4,%esp
80103cf5:	52                   	push   %edx
80103cf6:	ff 75 f4             	push   -0xc(%ebp)
80103cf9:	50                   	push   %eax
80103cfa:	e8 fa 3b 00 00       	call   801078f9 <deallocuvm>
80103cff:	83 c4 10             	add    $0x10,%esp
80103d02:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d05:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d09:	75 07                	jne    80103d12 <growproc+0x7e>
      return -1;
80103d0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d10:	eb 1b                	jmp    80103d2d <growproc+0x99>
  }
  curproc->sz = sz;
80103d12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d15:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d18:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103d1a:	83 ec 0c             	sub    $0xc,%esp
80103d1d:	ff 75 f0             	push   -0x10(%ebp)
80103d20:	e8 f3 37 00 00       	call   80107518 <switchuvm>
80103d25:	83 c4 10             	add    $0x10,%esp
  return 0;
80103d28:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103d2d:	c9                   	leave  
80103d2e:	c3                   	ret    

80103d2f <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103d2f:	55                   	push   %ebp
80103d30:	89 e5                	mov    %esp,%ebp
80103d32:	57                   	push   %edi
80103d33:	56                   	push   %esi
80103d34:	53                   	push   %ebx
80103d35:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103d38:	e8 f3 fc ff ff       	call   80103a30 <myproc>
80103d3d:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103d40:	e8 14 fd ff ff       	call   80103a59 <allocproc>
80103d45:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103d48:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103d4c:	75 0a                	jne    80103d58 <fork+0x29>
    return -1;
80103d4e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d53:	e9 48 01 00 00       	jmp    80103ea0 <fork+0x171>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103d58:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d5b:	8b 10                	mov    (%eax),%edx
80103d5d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d60:	8b 40 04             	mov    0x4(%eax),%eax
80103d63:	83 ec 08             	sub    $0x8,%esp
80103d66:	52                   	push   %edx
80103d67:	50                   	push   %eax
80103d68:	e8 2a 3d 00 00       	call   80107a97 <copyuvm>
80103d6d:	83 c4 10             	add    $0x10,%esp
80103d70:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103d73:	89 42 04             	mov    %eax,0x4(%edx)
80103d76:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d79:	8b 40 04             	mov    0x4(%eax),%eax
80103d7c:	85 c0                	test   %eax,%eax
80103d7e:	75 30                	jne    80103db0 <fork+0x81>
    kfree(np->kstack);
80103d80:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d83:	8b 40 08             	mov    0x8(%eax),%eax
80103d86:	83 ec 0c             	sub    $0xc,%esp
80103d89:	50                   	push   %eax
80103d8a:	e8 77 e9 ff ff       	call   80102706 <kfree>
80103d8f:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103d92:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d95:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103d9c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d9f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103da6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103dab:	e9 f0 00 00 00       	jmp    80103ea0 <fork+0x171>
  }
  np->sz = curproc->sz;
80103db0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103db3:	8b 10                	mov    (%eax),%edx
80103db5:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103db8:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103dba:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dbd:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103dc0:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103dc3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dc6:	8b 48 18             	mov    0x18(%eax),%ecx
80103dc9:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dcc:	8b 40 18             	mov    0x18(%eax),%eax
80103dcf:	89 c2                	mov    %eax,%edx
80103dd1:	89 cb                	mov    %ecx,%ebx
80103dd3:	b8 13 00 00 00       	mov    $0x13,%eax
80103dd8:	89 d7                	mov    %edx,%edi
80103dda:	89 de                	mov    %ebx,%esi
80103ddc:	89 c1                	mov    %eax,%ecx
80103dde:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103de0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103de3:	8b 40 18             	mov    0x18(%eax),%eax
80103de6:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80103ded:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103df4:	eb 3b                	jmp    80103e31 <fork+0x102>
    if(curproc->ofile[i])
80103df6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103df9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103dfc:	83 c2 08             	add    $0x8,%edx
80103dff:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e03:	85 c0                	test   %eax,%eax
80103e05:	74 26                	je     80103e2d <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103e07:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e0a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e0d:	83 c2 08             	add    $0x8,%edx
80103e10:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e14:	83 ec 0c             	sub    $0xc,%esp
80103e17:	50                   	push   %eax
80103e18:	e8 2d d2 ff ff       	call   8010104a <filedup>
80103e1d:	83 c4 10             	add    $0x10,%esp
80103e20:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e23:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103e26:	83 c1 08             	add    $0x8,%ecx
80103e29:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80103e2d:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103e31:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103e35:	7e bf                	jle    80103df6 <fork+0xc7>
  np->cwd = idup(curproc->cwd);
80103e37:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e3a:	8b 40 68             	mov    0x68(%eax),%eax
80103e3d:	83 ec 0c             	sub    $0xc,%esp
80103e40:	50                   	push   %eax
80103e41:	e8 6a db ff ff       	call   801019b0 <idup>
80103e46:	83 c4 10             	add    $0x10,%esp
80103e49:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e4c:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103e4f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e52:	8d 50 6c             	lea    0x6c(%eax),%edx
80103e55:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e58:	83 c0 6c             	add    $0x6c,%eax
80103e5b:	83 ec 04             	sub    $0x4,%esp
80103e5e:	6a 10                	push   $0x10
80103e60:	52                   	push   %edx
80103e61:	50                   	push   %eax
80103e62:	e8 7e 0e 00 00       	call   80104ce5 <safestrcpy>
80103e67:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103e6a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e6d:	8b 40 10             	mov    0x10(%eax),%eax
80103e70:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103e73:	83 ec 0c             	sub    $0xc,%esp
80103e76:	68 00 42 19 80       	push   $0x80194200
80103e7b:	e8 ec 09 00 00       	call   8010486c <acquire>
80103e80:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80103e83:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e86:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103e8d:	83 ec 0c             	sub    $0xc,%esp
80103e90:	68 00 42 19 80       	push   $0x80194200
80103e95:	e8 40 0a 00 00       	call   801048da <release>
80103e9a:	83 c4 10             	add    $0x10,%esp

  return pid;
80103e9d:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80103ea0:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103ea3:	5b                   	pop    %ebx
80103ea4:	5e                   	pop    %esi
80103ea5:	5f                   	pop    %edi
80103ea6:	5d                   	pop    %ebp
80103ea7:	c3                   	ret    

80103ea8 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80103ea8:	55                   	push   %ebp
80103ea9:	89 e5                	mov    %esp,%ebp
80103eab:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80103eae:	e8 7d fb ff ff       	call   80103a30 <myproc>
80103eb3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80103eb6:	a1 34 61 19 80       	mov    0x80196134,%eax
80103ebb:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103ebe:	75 0d                	jne    80103ecd <exit+0x25>
    panic("init exiting");
80103ec0:	83 ec 0c             	sub    $0xc,%esp
80103ec3:	68 f2 a3 10 80       	push   $0x8010a3f2
80103ec8:	e8 dc c6 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80103ecd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80103ed4:	eb 3f                	jmp    80103f15 <exit+0x6d>
    if(curproc->ofile[fd]){
80103ed6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ed9:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103edc:	83 c2 08             	add    $0x8,%edx
80103edf:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103ee3:	85 c0                	test   %eax,%eax
80103ee5:	74 2a                	je     80103f11 <exit+0x69>
      fileclose(curproc->ofile[fd]);
80103ee7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103eea:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103eed:	83 c2 08             	add    $0x8,%edx
80103ef0:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103ef4:	83 ec 0c             	sub    $0xc,%esp
80103ef7:	50                   	push   %eax
80103ef8:	e8 9e d1 ff ff       	call   8010109b <fileclose>
80103efd:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80103f00:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f03:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f06:	83 c2 08             	add    $0x8,%edx
80103f09:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80103f10:	00 
  for(fd = 0; fd < NOFILE; fd++){
80103f11:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80103f15:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80103f19:	7e bb                	jle    80103ed6 <exit+0x2e>
    }
  }

  begin_op();
80103f1b:	e8 1c f1 ff ff       	call   8010303c <begin_op>
  iput(curproc->cwd);
80103f20:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f23:	8b 40 68             	mov    0x68(%eax),%eax
80103f26:	83 ec 0c             	sub    $0xc,%esp
80103f29:	50                   	push   %eax
80103f2a:	e8 1c dc ff ff       	call   80101b4b <iput>
80103f2f:	83 c4 10             	add    $0x10,%esp
  end_op();
80103f32:	e8 91 f1 ff ff       	call   801030c8 <end_op>
  curproc->cwd = 0;
80103f37:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f3a:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80103f41:	83 ec 0c             	sub    $0xc,%esp
80103f44:	68 00 42 19 80       	push   $0x80194200
80103f49:	e8 1e 09 00 00       	call   8010486c <acquire>
80103f4e:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80103f51:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f54:	8b 40 14             	mov    0x14(%eax),%eax
80103f57:	83 ec 0c             	sub    $0xc,%esp
80103f5a:	50                   	push   %eax
80103f5b:	e8 20 04 00 00       	call   80104380 <wakeup1>
80103f60:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f63:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103f6a:	eb 37                	jmp    80103fa3 <exit+0xfb>
    if(p->parent == curproc){
80103f6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f6f:	8b 40 14             	mov    0x14(%eax),%eax
80103f72:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103f75:	75 28                	jne    80103f9f <exit+0xf7>
      p->parent = initproc;
80103f77:	8b 15 34 61 19 80    	mov    0x80196134,%edx
80103f7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f80:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80103f83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f86:	8b 40 0c             	mov    0xc(%eax),%eax
80103f89:	83 f8 05             	cmp    $0x5,%eax
80103f8c:	75 11                	jne    80103f9f <exit+0xf7>
        wakeup1(initproc);
80103f8e:	a1 34 61 19 80       	mov    0x80196134,%eax
80103f93:	83 ec 0c             	sub    $0xc,%esp
80103f96:	50                   	push   %eax
80103f97:	e8 e4 03 00 00       	call   80104380 <wakeup1>
80103f9c:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f9f:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80103fa3:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
80103faa:	72 c0                	jb     80103f6c <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80103fac:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103faf:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80103fb6:	e8 e5 01 00 00       	call   801041a0 <sched>
  panic("zombie exit");
80103fbb:	83 ec 0c             	sub    $0xc,%esp
80103fbe:	68 ff a3 10 80       	push   $0x8010a3ff
80103fc3:	e8 e1 c5 ff ff       	call   801005a9 <panic>

80103fc8 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80103fc8:	55                   	push   %ebp
80103fc9:	89 e5                	mov    %esp,%ebp
80103fcb:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80103fce:	e8 5d fa ff ff       	call   80103a30 <myproc>
80103fd3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80103fd6:	83 ec 0c             	sub    $0xc,%esp
80103fd9:	68 00 42 19 80       	push   $0x80194200
80103fde:	e8 89 08 00 00       	call   8010486c <acquire>
80103fe3:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80103fe6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103fed:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103ff4:	e9 a1 00 00 00       	jmp    8010409a <wait+0xd2>
      if(p->parent != curproc)
80103ff9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ffc:	8b 40 14             	mov    0x14(%eax),%eax
80103fff:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104002:	0f 85 8d 00 00 00    	jne    80104095 <wait+0xcd>
        continue;
      havekids = 1;
80104008:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010400f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104012:	8b 40 0c             	mov    0xc(%eax),%eax
80104015:	83 f8 05             	cmp    $0x5,%eax
80104018:	75 7c                	jne    80104096 <wait+0xce>
        // Found one.
        pid = p->pid;
8010401a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010401d:	8b 40 10             	mov    0x10(%eax),%eax
80104020:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104023:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104026:	8b 40 08             	mov    0x8(%eax),%eax
80104029:	83 ec 0c             	sub    $0xc,%esp
8010402c:	50                   	push   %eax
8010402d:	e8 d4 e6 ff ff       	call   80102706 <kfree>
80104032:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104035:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104038:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010403f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104042:	8b 40 04             	mov    0x4(%eax),%eax
80104045:	83 ec 0c             	sub    $0xc,%esp
80104048:	50                   	push   %eax
80104049:	e8 6f 39 00 00       	call   801079bd <freevm>
8010404e:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104051:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104054:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010405b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010405e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104065:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104068:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010406c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010406f:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104076:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104079:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104080:	83 ec 0c             	sub    $0xc,%esp
80104083:	68 00 42 19 80       	push   $0x80194200
80104088:	e8 4d 08 00 00       	call   801048da <release>
8010408d:	83 c4 10             	add    $0x10,%esp
        return pid;
80104090:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104093:	eb 51                	jmp    801040e6 <wait+0x11e>
        continue;
80104095:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104096:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010409a:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
801040a1:	0f 82 52 ff ff ff    	jb     80103ff9 <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801040a7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801040ab:	74 0a                	je     801040b7 <wait+0xef>
801040ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040b0:	8b 40 24             	mov    0x24(%eax),%eax
801040b3:	85 c0                	test   %eax,%eax
801040b5:	74 17                	je     801040ce <wait+0x106>
      release(&ptable.lock);
801040b7:	83 ec 0c             	sub    $0xc,%esp
801040ba:	68 00 42 19 80       	push   $0x80194200
801040bf:	e8 16 08 00 00       	call   801048da <release>
801040c4:	83 c4 10             	add    $0x10,%esp
      return -1;
801040c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040cc:	eb 18                	jmp    801040e6 <wait+0x11e>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801040ce:	83 ec 08             	sub    $0x8,%esp
801040d1:	68 00 42 19 80       	push   $0x80194200
801040d6:	ff 75 ec             	push   -0x14(%ebp)
801040d9:	e8 fb 01 00 00       	call   801042d9 <sleep>
801040de:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801040e1:	e9 00 ff ff ff       	jmp    80103fe6 <wait+0x1e>
  }
}
801040e6:	c9                   	leave  
801040e7:	c3                   	ret    

801040e8 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801040e8:	55                   	push   %ebp
801040e9:	89 e5                	mov    %esp,%ebp
801040eb:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801040ee:	e8 c5 f8 ff ff       	call   801039b8 <mycpu>
801040f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
801040f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040f9:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104100:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104103:	e8 70 f8 ff ff       	call   80103978 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104108:	83 ec 0c             	sub    $0xc,%esp
8010410b:	68 00 42 19 80       	push   $0x80194200
80104110:	e8 57 07 00 00       	call   8010486c <acquire>
80104115:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104118:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
8010411f:	eb 61                	jmp    80104182 <scheduler+0x9a>
      if(p->state != RUNNABLE)
80104121:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104124:	8b 40 0c             	mov    0xc(%eax),%eax
80104127:	83 f8 03             	cmp    $0x3,%eax
8010412a:	75 51                	jne    8010417d <scheduler+0x95>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
8010412c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010412f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104132:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104138:	83 ec 0c             	sub    $0xc,%esp
8010413b:	ff 75 f4             	push   -0xc(%ebp)
8010413e:	e8 d5 33 00 00       	call   80107518 <switchuvm>
80104143:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104146:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104149:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104153:	8b 40 1c             	mov    0x1c(%eax),%eax
80104156:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104159:	83 c2 04             	add    $0x4,%edx
8010415c:	83 ec 08             	sub    $0x8,%esp
8010415f:	50                   	push   %eax
80104160:	52                   	push   %edx
80104161:	e8 f1 0b 00 00       	call   80104d57 <swtch>
80104166:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104169:	e8 91 33 00 00       	call   801074ff <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
8010416e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104171:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104178:	00 00 00 
8010417b:	eb 01                	jmp    8010417e <scheduler+0x96>
        continue;
8010417d:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010417e:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104182:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
80104189:	72 96                	jb     80104121 <scheduler+0x39>
    }
    release(&ptable.lock);
8010418b:	83 ec 0c             	sub    $0xc,%esp
8010418e:	68 00 42 19 80       	push   $0x80194200
80104193:	e8 42 07 00 00       	call   801048da <release>
80104198:	83 c4 10             	add    $0x10,%esp
    sti();
8010419b:	e9 63 ff ff ff       	jmp    80104103 <scheduler+0x1b>

801041a0 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
801041a0:	55                   	push   %ebp
801041a1:	89 e5                	mov    %esp,%ebp
801041a3:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
801041a6:	e8 85 f8 ff ff       	call   80103a30 <myproc>
801041ab:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
801041ae:	83 ec 0c             	sub    $0xc,%esp
801041b1:	68 00 42 19 80       	push   $0x80194200
801041b6:	e8 ec 07 00 00       	call   801049a7 <holding>
801041bb:	83 c4 10             	add    $0x10,%esp
801041be:	85 c0                	test   %eax,%eax
801041c0:	75 0d                	jne    801041cf <sched+0x2f>
    panic("sched ptable.lock");
801041c2:	83 ec 0c             	sub    $0xc,%esp
801041c5:	68 0b a4 10 80       	push   $0x8010a40b
801041ca:	e8 da c3 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
801041cf:	e8 e4 f7 ff ff       	call   801039b8 <mycpu>
801041d4:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801041da:	83 f8 01             	cmp    $0x1,%eax
801041dd:	74 0d                	je     801041ec <sched+0x4c>
    panic("sched locks");
801041df:	83 ec 0c             	sub    $0xc,%esp
801041e2:	68 1d a4 10 80       	push   $0x8010a41d
801041e7:	e8 bd c3 ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
801041ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041ef:	8b 40 0c             	mov    0xc(%eax),%eax
801041f2:	83 f8 04             	cmp    $0x4,%eax
801041f5:	75 0d                	jne    80104204 <sched+0x64>
    panic("sched running");
801041f7:	83 ec 0c             	sub    $0xc,%esp
801041fa:	68 29 a4 10 80       	push   $0x8010a429
801041ff:	e8 a5 c3 ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
80104204:	e8 5f f7 ff ff       	call   80103968 <readeflags>
80104209:	25 00 02 00 00       	and    $0x200,%eax
8010420e:	85 c0                	test   %eax,%eax
80104210:	74 0d                	je     8010421f <sched+0x7f>
    panic("sched interruptible");
80104212:	83 ec 0c             	sub    $0xc,%esp
80104215:	68 37 a4 10 80       	push   $0x8010a437
8010421a:	e8 8a c3 ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
8010421f:	e8 94 f7 ff ff       	call   801039b8 <mycpu>
80104224:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010422a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
8010422d:	e8 86 f7 ff ff       	call   801039b8 <mycpu>
80104232:	8b 40 04             	mov    0x4(%eax),%eax
80104235:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104238:	83 c2 1c             	add    $0x1c,%edx
8010423b:	83 ec 08             	sub    $0x8,%esp
8010423e:	50                   	push   %eax
8010423f:	52                   	push   %edx
80104240:	e8 12 0b 00 00       	call   80104d57 <swtch>
80104245:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104248:	e8 6b f7 ff ff       	call   801039b8 <mycpu>
8010424d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104250:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104256:	90                   	nop
80104257:	c9                   	leave  
80104258:	c3                   	ret    

80104259 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104259:	55                   	push   %ebp
8010425a:	89 e5                	mov    %esp,%ebp
8010425c:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
8010425f:	83 ec 0c             	sub    $0xc,%esp
80104262:	68 00 42 19 80       	push   $0x80194200
80104267:	e8 00 06 00 00       	call   8010486c <acquire>
8010426c:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
8010426f:	e8 bc f7 ff ff       	call   80103a30 <myproc>
80104274:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010427b:	e8 20 ff ff ff       	call   801041a0 <sched>
  release(&ptable.lock);
80104280:	83 ec 0c             	sub    $0xc,%esp
80104283:	68 00 42 19 80       	push   $0x80194200
80104288:	e8 4d 06 00 00       	call   801048da <release>
8010428d:	83 c4 10             	add    $0x10,%esp
}
80104290:	90                   	nop
80104291:	c9                   	leave  
80104292:	c3                   	ret    

80104293 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104293:	55                   	push   %ebp
80104294:	89 e5                	mov    %esp,%ebp
80104296:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104299:	83 ec 0c             	sub    $0xc,%esp
8010429c:	68 00 42 19 80       	push   $0x80194200
801042a1:	e8 34 06 00 00       	call   801048da <release>
801042a6:	83 c4 10             	add    $0x10,%esp

  if (first) {
801042a9:	a1 04 f0 10 80       	mov    0x8010f004,%eax
801042ae:	85 c0                	test   %eax,%eax
801042b0:	74 24                	je     801042d6 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801042b2:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
801042b9:	00 00 00 
    iinit(ROOTDEV);
801042bc:	83 ec 0c             	sub    $0xc,%esp
801042bf:	6a 01                	push   $0x1
801042c1:	e8 b2 d3 ff ff       	call   80101678 <iinit>
801042c6:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801042c9:	83 ec 0c             	sub    $0xc,%esp
801042cc:	6a 01                	push   $0x1
801042ce:	e8 4a eb ff ff       	call   80102e1d <initlog>
801042d3:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801042d6:	90                   	nop
801042d7:	c9                   	leave  
801042d8:	c3                   	ret    

801042d9 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801042d9:	55                   	push   %ebp
801042da:	89 e5                	mov    %esp,%ebp
801042dc:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
801042df:	e8 4c f7 ff ff       	call   80103a30 <myproc>
801042e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
801042e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801042eb:	75 0d                	jne    801042fa <sleep+0x21>
    panic("sleep");
801042ed:	83 ec 0c             	sub    $0xc,%esp
801042f0:	68 4b a4 10 80       	push   $0x8010a44b
801042f5:	e8 af c2 ff ff       	call   801005a9 <panic>

  if(lk == 0)
801042fa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801042fe:	75 0d                	jne    8010430d <sleep+0x34>
    panic("sleep without lk");
80104300:	83 ec 0c             	sub    $0xc,%esp
80104303:	68 51 a4 10 80       	push   $0x8010a451
80104308:	e8 9c c2 ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
8010430d:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
80104314:	74 1e                	je     80104334 <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104316:	83 ec 0c             	sub    $0xc,%esp
80104319:	68 00 42 19 80       	push   $0x80194200
8010431e:	e8 49 05 00 00       	call   8010486c <acquire>
80104323:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104326:	83 ec 0c             	sub    $0xc,%esp
80104329:	ff 75 0c             	push   0xc(%ebp)
8010432c:	e8 a9 05 00 00       	call   801048da <release>
80104331:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104334:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104337:	8b 55 08             	mov    0x8(%ebp),%edx
8010433a:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
8010433d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104340:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104347:	e8 54 fe ff ff       	call   801041a0 <sched>

  // Tidy up.
  p->chan = 0;
8010434c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010434f:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104356:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
8010435d:	74 1e                	je     8010437d <sleep+0xa4>
    release(&ptable.lock);
8010435f:	83 ec 0c             	sub    $0xc,%esp
80104362:	68 00 42 19 80       	push   $0x80194200
80104367:	e8 6e 05 00 00       	call   801048da <release>
8010436c:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
8010436f:	83 ec 0c             	sub    $0xc,%esp
80104372:	ff 75 0c             	push   0xc(%ebp)
80104375:	e8 f2 04 00 00       	call   8010486c <acquire>
8010437a:	83 c4 10             	add    $0x10,%esp
  }
}
8010437d:	90                   	nop
8010437e:	c9                   	leave  
8010437f:	c3                   	ret    

80104380 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104380:	55                   	push   %ebp
80104381:	89 e5                	mov    %esp,%ebp
80104383:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104386:	c7 45 fc 34 42 19 80 	movl   $0x80194234,-0x4(%ebp)
8010438d:	eb 24                	jmp    801043b3 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
8010438f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104392:	8b 40 0c             	mov    0xc(%eax),%eax
80104395:	83 f8 02             	cmp    $0x2,%eax
80104398:	75 15                	jne    801043af <wakeup1+0x2f>
8010439a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010439d:	8b 40 20             	mov    0x20(%eax),%eax
801043a0:	39 45 08             	cmp    %eax,0x8(%ebp)
801043a3:	75 0a                	jne    801043af <wakeup1+0x2f>
      p->state = RUNNABLE;
801043a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801043a8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043af:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
801043b3:	81 7d fc 34 61 19 80 	cmpl   $0x80196134,-0x4(%ebp)
801043ba:	72 d3                	jb     8010438f <wakeup1+0xf>
}
801043bc:	90                   	nop
801043bd:	90                   	nop
801043be:	c9                   	leave  
801043bf:	c3                   	ret    

801043c0 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801043c0:	55                   	push   %ebp
801043c1:	89 e5                	mov    %esp,%ebp
801043c3:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801043c6:	83 ec 0c             	sub    $0xc,%esp
801043c9:	68 00 42 19 80       	push   $0x80194200
801043ce:	e8 99 04 00 00       	call   8010486c <acquire>
801043d3:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801043d6:	83 ec 0c             	sub    $0xc,%esp
801043d9:	ff 75 08             	push   0x8(%ebp)
801043dc:	e8 9f ff ff ff       	call   80104380 <wakeup1>
801043e1:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801043e4:	83 ec 0c             	sub    $0xc,%esp
801043e7:	68 00 42 19 80       	push   $0x80194200
801043ec:	e8 e9 04 00 00       	call   801048da <release>
801043f1:	83 c4 10             	add    $0x10,%esp
}
801043f4:	90                   	nop
801043f5:	c9                   	leave  
801043f6:	c3                   	ret    

801043f7 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801043f7:	55                   	push   %ebp
801043f8:	89 e5                	mov    %esp,%ebp
801043fa:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801043fd:	83 ec 0c             	sub    $0xc,%esp
80104400:	68 00 42 19 80       	push   $0x80194200
80104405:	e8 62 04 00 00       	call   8010486c <acquire>
8010440a:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010440d:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104414:	eb 45                	jmp    8010445b <kill+0x64>
    if(p->pid == pid){
80104416:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104419:	8b 40 10             	mov    0x10(%eax),%eax
8010441c:	39 45 08             	cmp    %eax,0x8(%ebp)
8010441f:	75 36                	jne    80104457 <kill+0x60>
      p->killed = 1;
80104421:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104424:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
8010442b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010442e:	8b 40 0c             	mov    0xc(%eax),%eax
80104431:	83 f8 02             	cmp    $0x2,%eax
80104434:	75 0a                	jne    80104440 <kill+0x49>
        p->state = RUNNABLE;
80104436:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104439:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104440:	83 ec 0c             	sub    $0xc,%esp
80104443:	68 00 42 19 80       	push   $0x80194200
80104448:	e8 8d 04 00 00       	call   801048da <release>
8010444d:	83 c4 10             	add    $0x10,%esp
      return 0;
80104450:	b8 00 00 00 00       	mov    $0x0,%eax
80104455:	eb 22                	jmp    80104479 <kill+0x82>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104457:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010445b:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
80104462:	72 b2                	jb     80104416 <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104464:	83 ec 0c             	sub    $0xc,%esp
80104467:	68 00 42 19 80       	push   $0x80194200
8010446c:	e8 69 04 00 00       	call   801048da <release>
80104471:	83 c4 10             	add    $0x10,%esp
  return -1;
80104474:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104479:	c9                   	leave  
8010447a:	c3                   	ret    

8010447b <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010447b:	55                   	push   %ebp
8010447c:	89 e5                	mov    %esp,%ebp
8010447e:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104481:	c7 45 f0 34 42 19 80 	movl   $0x80194234,-0x10(%ebp)
80104488:	e9 d7 00 00 00       	jmp    80104564 <procdump+0xe9>
    if(p->state == UNUSED)
8010448d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104490:	8b 40 0c             	mov    0xc(%eax),%eax
80104493:	85 c0                	test   %eax,%eax
80104495:	0f 84 c4 00 00 00    	je     8010455f <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010449b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010449e:	8b 40 0c             	mov    0xc(%eax),%eax
801044a1:	83 f8 05             	cmp    $0x5,%eax
801044a4:	77 23                	ja     801044c9 <procdump+0x4e>
801044a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044a9:	8b 40 0c             	mov    0xc(%eax),%eax
801044ac:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801044b3:	85 c0                	test   %eax,%eax
801044b5:	74 12                	je     801044c9 <procdump+0x4e>
      state = states[p->state];
801044b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044ba:	8b 40 0c             	mov    0xc(%eax),%eax
801044bd:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801044c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801044c7:	eb 07                	jmp    801044d0 <procdump+0x55>
    else
      state = "???";
801044c9:	c7 45 ec 62 a4 10 80 	movl   $0x8010a462,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801044d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044d3:	8d 50 6c             	lea    0x6c(%eax),%edx
801044d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044d9:	8b 40 10             	mov    0x10(%eax),%eax
801044dc:	52                   	push   %edx
801044dd:	ff 75 ec             	push   -0x14(%ebp)
801044e0:	50                   	push   %eax
801044e1:	68 66 a4 10 80       	push   $0x8010a466
801044e6:	e8 09 bf ff ff       	call   801003f4 <cprintf>
801044eb:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801044ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044f1:	8b 40 0c             	mov    0xc(%eax),%eax
801044f4:	83 f8 02             	cmp    $0x2,%eax
801044f7:	75 54                	jne    8010454d <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801044f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044fc:	8b 40 1c             	mov    0x1c(%eax),%eax
801044ff:	8b 40 0c             	mov    0xc(%eax),%eax
80104502:	83 c0 08             	add    $0x8,%eax
80104505:	89 c2                	mov    %eax,%edx
80104507:	83 ec 08             	sub    $0x8,%esp
8010450a:	8d 45 c4             	lea    -0x3c(%ebp),%eax
8010450d:	50                   	push   %eax
8010450e:	52                   	push   %edx
8010450f:	e8 18 04 00 00       	call   8010492c <getcallerpcs>
80104514:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104517:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010451e:	eb 1c                	jmp    8010453c <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104520:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104523:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104527:	83 ec 08             	sub    $0x8,%esp
8010452a:	50                   	push   %eax
8010452b:	68 6f a4 10 80       	push   $0x8010a46f
80104530:	e8 bf be ff ff       	call   801003f4 <cprintf>
80104535:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104538:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010453c:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104540:	7f 0b                	jg     8010454d <procdump+0xd2>
80104542:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104545:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104549:	85 c0                	test   %eax,%eax
8010454b:	75 d3                	jne    80104520 <procdump+0xa5>
    }
    cprintf("\n");
8010454d:	83 ec 0c             	sub    $0xc,%esp
80104550:	68 73 a4 10 80       	push   $0x8010a473
80104555:	e8 9a be ff ff       	call   801003f4 <cprintf>
8010455a:	83 c4 10             	add    $0x10,%esp
8010455d:	eb 01                	jmp    80104560 <procdump+0xe5>
      continue;
8010455f:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104560:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80104564:	81 7d f0 34 61 19 80 	cmpl   $0x80196134,-0x10(%ebp)
8010456b:	0f 82 1c ff ff ff    	jb     8010448d <procdump+0x12>
  }
}
80104571:	90                   	nop
80104572:	90                   	nop
80104573:	c9                   	leave  
80104574:	c3                   	ret    

80104575 <printpt>:

int
printpt(int pid)
{
80104575:	55                   	push   %ebp
80104576:	89 e5                	mov    %esp,%ebp
80104578:	83 ec 18             	sub    $0x18,%esp
  pde_t* pgdir = myproc()->pgdir;
8010457b:	e8 b0 f4 ff ff       	call   80103a30 <myproc>
80104580:	8b 40 04             	mov    0x4(%eax),%eax
80104583:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  cprintf("%d\n", myproc()->pid);
80104586:	e8 a5 f4 ff ff       	call   80103a30 <myproc>
8010458b:	8b 40 10             	mov    0x10(%eax),%eax
8010458e:	83 ec 08             	sub    $0x8,%esp
80104591:	50                   	push   %eax
80104592:	68 75 a4 10 80       	push   $0x8010a475
80104597:	e8 58 be ff ff       	call   801003f4 <cprintf>
8010459c:	83 c4 10             	add    $0x10,%esp
  cprintf("START PAGE TABLE (pid %d)\n", pid);
8010459f:	83 ec 08             	sub    $0x8,%esp
801045a2:	ff 75 08             	push   0x8(%ebp)
801045a5:	68 79 a4 10 80       	push   $0x8010a479
801045aa:	e8 45 be ff ff       	call   801003f4 <cprintf>
801045af:	83 c4 10             	add    $0x10,%esp
  
  //int cnt = 0;
  
  // 유저영역의 페이지 디렉토리를 조사한다.
  for (uint i = 0; i < PDX(KERNBASE); i++) {
801045b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801045b9:	e9 0b 01 00 00       	jmp    801046c9 <printpt+0x154>

    // 활성화 된 페이지 디렉토리이면
    if (pgdir[i] & PTE_P) {
801045be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801045c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801045cb:	01 d0                	add    %edx,%eax
801045cd:	8b 00                	mov    (%eax),%eax
801045cf:	83 e0 01             	and    $0x1,%eax
801045d2:	85 c0                	test   %eax,%eax
801045d4:	0f 84 eb 00 00 00    	je     801046c5 <printpt+0x150>
      
      //cprintf("%p %x\n", &pgdir[i], pgdir[i]);

      // 해당 주소의 페이지 테이블을 가져온다.
      pte_t* pgtab = (pte_t*)P2V(PTE_ADDR(pgdir[i]));
801045da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045dd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801045e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801045e7:	01 d0                	add    %edx,%eax
801045e9:	8b 00                	mov    (%eax),%eax
801045eb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801045f0:	05 00 00 00 80       	add    $0x80000000,%eax
801045f5:	89 45 e8             	mov    %eax,-0x18(%ebp)
      
      //cprintf("%p %x %p\n", pgdir, pgdir[i], pgtab);

      // 페이지 테이블의 개수 1024개를 모두 조사한다.
      for (uint j = 0; j < NPTENTRIES; j++) {
801045f8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801045ff:	e9 b4 00 00 00       	jmp    801046b8 <printpt+0x143>
        
        if (pgtab[j] & PTE_P) {
80104604:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104607:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010460e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104611:	01 d0                	add    %edx,%eax
80104613:	8b 00                	mov    (%eax),%eax
80104615:	83 e0 01             	and    $0x1,%eax
80104618:	85 c0                	test   %eax,%eax
8010461a:	0f 84 94 00 00 00    	je     801046b4 <printpt+0x13f>
          

          cprintf("%p %x Data : \n", &pgtab[j], pgtab[j]);
80104620:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104623:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010462a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010462d:	01 d0                	add    %edx,%eax
8010462f:	8b 00                	mov    (%eax),%eax
80104631:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104634:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
8010463b:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010463e:	01 ca                	add    %ecx,%edx
80104640:	83 ec 04             	sub    $0x4,%esp
80104643:	50                   	push   %eax
80104644:	52                   	push   %edx
80104645:	68 94 a4 10 80       	push   $0x8010a494
8010464a:	e8 a5 bd ff ff       	call   801003f4 <cprintf>
8010464f:	83 c4 10             	add    $0x10,%esp
          cprintf("%d %s %s %s\n", j, "P", (pgtab[j] & PTE_U) ? "U\0" : "K\0", (pgtab[j] & PTE_W) ? "W\0" : "-\0");
80104652:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104655:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010465c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010465f:	01 d0                	add    %edx,%eax
80104661:	8b 00                	mov    (%eax),%eax
80104663:	83 e0 02             	and    $0x2,%eax
80104666:	85 c0                	test   %eax,%eax
80104668:	74 07                	je     80104671 <printpt+0xfc>
8010466a:	ba a3 a4 10 80       	mov    $0x8010a4a3,%edx
8010466f:	eb 05                	jmp    80104676 <printpt+0x101>
80104671:	ba a6 a4 10 80       	mov    $0x8010a4a6,%edx
80104676:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104679:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80104680:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104683:	01 c8                	add    %ecx,%eax
80104685:	8b 00                	mov    (%eax),%eax
80104687:	83 e0 04             	and    $0x4,%eax
8010468a:	85 c0                	test   %eax,%eax
8010468c:	74 07                	je     80104695 <printpt+0x120>
8010468e:	b8 a9 a4 10 80       	mov    $0x8010a4a9,%eax
80104693:	eb 05                	jmp    8010469a <printpt+0x125>
80104695:	b8 ac a4 10 80       	mov    $0x8010a4ac,%eax
8010469a:	83 ec 0c             	sub    $0xc,%esp
8010469d:	52                   	push   %edx
8010469e:	50                   	push   %eax
8010469f:	68 af a4 10 80       	push   $0x8010a4af
801046a4:	ff 75 f0             	push   -0x10(%ebp)
801046a7:	68 b1 a4 10 80       	push   $0x8010a4b1
801046ac:	e8 43 bd ff ff       	call   801003f4 <cprintf>
801046b1:	83 c4 20             	add    $0x20,%esp
      for (uint j = 0; j < NPTENTRIES; j++) {
801046b4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801046b8:	81 7d f0 ff 03 00 00 	cmpl   $0x3ff,-0x10(%ebp)
801046bf:	0f 86 3f ff ff ff    	jbe    80104604 <printpt+0x8f>
  for (uint i = 0; i < PDX(KERNBASE); i++) {
801046c5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801046c9:	81 7d f4 ff 01 00 00 	cmpl   $0x1ff,-0xc(%ebp)
801046d0:	0f 86 e8 fe ff ff    	jbe    801045be <printpt+0x49>
    }
  }
  
  

  cprintf("END PAGE TABLE\n");
801046d6:	83 ec 0c             	sub    $0xc,%esp
801046d9:	68 be a4 10 80       	push   $0x8010a4be
801046de:	e8 11 bd ff ff       	call   801003f4 <cprintf>
801046e3:	83 c4 10             	add    $0x10,%esp
  return 0;
801046e6:	b8 00 00 00 00       	mov    $0x0,%eax
801046eb:	c9                   	leave  
801046ec:	c3                   	ret    

801046ed <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801046ed:	55                   	push   %ebp
801046ee:	89 e5                	mov    %esp,%ebp
801046f0:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
801046f3:	8b 45 08             	mov    0x8(%ebp),%eax
801046f6:	83 c0 04             	add    $0x4,%eax
801046f9:	83 ec 08             	sub    $0x8,%esp
801046fc:	68 f8 a4 10 80       	push   $0x8010a4f8
80104701:	50                   	push   %eax
80104702:	e8 43 01 00 00       	call   8010484a <initlock>
80104707:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
8010470a:	8b 45 08             	mov    0x8(%ebp),%eax
8010470d:	8b 55 0c             	mov    0xc(%ebp),%edx
80104710:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104713:	8b 45 08             	mov    0x8(%ebp),%eax
80104716:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010471c:	8b 45 08             	mov    0x8(%ebp),%eax
8010471f:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104726:	90                   	nop
80104727:	c9                   	leave  
80104728:	c3                   	ret    

80104729 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104729:	55                   	push   %ebp
8010472a:	89 e5                	mov    %esp,%ebp
8010472c:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
8010472f:	8b 45 08             	mov    0x8(%ebp),%eax
80104732:	83 c0 04             	add    $0x4,%eax
80104735:	83 ec 0c             	sub    $0xc,%esp
80104738:	50                   	push   %eax
80104739:	e8 2e 01 00 00       	call   8010486c <acquire>
8010473e:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104741:	eb 15                	jmp    80104758 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104743:	8b 45 08             	mov    0x8(%ebp),%eax
80104746:	83 c0 04             	add    $0x4,%eax
80104749:	83 ec 08             	sub    $0x8,%esp
8010474c:	50                   	push   %eax
8010474d:	ff 75 08             	push   0x8(%ebp)
80104750:	e8 84 fb ff ff       	call   801042d9 <sleep>
80104755:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104758:	8b 45 08             	mov    0x8(%ebp),%eax
8010475b:	8b 00                	mov    (%eax),%eax
8010475d:	85 c0                	test   %eax,%eax
8010475f:	75 e2                	jne    80104743 <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104761:	8b 45 08             	mov    0x8(%ebp),%eax
80104764:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
8010476a:	e8 c1 f2 ff ff       	call   80103a30 <myproc>
8010476f:	8b 50 10             	mov    0x10(%eax),%edx
80104772:	8b 45 08             	mov    0x8(%ebp),%eax
80104775:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104778:	8b 45 08             	mov    0x8(%ebp),%eax
8010477b:	83 c0 04             	add    $0x4,%eax
8010477e:	83 ec 0c             	sub    $0xc,%esp
80104781:	50                   	push   %eax
80104782:	e8 53 01 00 00       	call   801048da <release>
80104787:	83 c4 10             	add    $0x10,%esp
}
8010478a:	90                   	nop
8010478b:	c9                   	leave  
8010478c:	c3                   	ret    

8010478d <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
8010478d:	55                   	push   %ebp
8010478e:	89 e5                	mov    %esp,%ebp
80104790:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104793:	8b 45 08             	mov    0x8(%ebp),%eax
80104796:	83 c0 04             	add    $0x4,%eax
80104799:	83 ec 0c             	sub    $0xc,%esp
8010479c:	50                   	push   %eax
8010479d:	e8 ca 00 00 00       	call   8010486c <acquire>
801047a2:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
801047a5:	8b 45 08             	mov    0x8(%ebp),%eax
801047a8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801047ae:	8b 45 08             	mov    0x8(%ebp),%eax
801047b1:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
801047b8:	83 ec 0c             	sub    $0xc,%esp
801047bb:	ff 75 08             	push   0x8(%ebp)
801047be:	e8 fd fb ff ff       	call   801043c0 <wakeup>
801047c3:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
801047c6:	8b 45 08             	mov    0x8(%ebp),%eax
801047c9:	83 c0 04             	add    $0x4,%eax
801047cc:	83 ec 0c             	sub    $0xc,%esp
801047cf:	50                   	push   %eax
801047d0:	e8 05 01 00 00       	call   801048da <release>
801047d5:	83 c4 10             	add    $0x10,%esp
}
801047d8:	90                   	nop
801047d9:	c9                   	leave  
801047da:	c3                   	ret    

801047db <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801047db:	55                   	push   %ebp
801047dc:	89 e5                	mov    %esp,%ebp
801047de:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
801047e1:	8b 45 08             	mov    0x8(%ebp),%eax
801047e4:	83 c0 04             	add    $0x4,%eax
801047e7:	83 ec 0c             	sub    $0xc,%esp
801047ea:	50                   	push   %eax
801047eb:	e8 7c 00 00 00       	call   8010486c <acquire>
801047f0:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
801047f3:	8b 45 08             	mov    0x8(%ebp),%eax
801047f6:	8b 00                	mov    (%eax),%eax
801047f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
801047fb:	8b 45 08             	mov    0x8(%ebp),%eax
801047fe:	83 c0 04             	add    $0x4,%eax
80104801:	83 ec 0c             	sub    $0xc,%esp
80104804:	50                   	push   %eax
80104805:	e8 d0 00 00 00       	call   801048da <release>
8010480a:	83 c4 10             	add    $0x10,%esp
  return r;
8010480d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104810:	c9                   	leave  
80104811:	c3                   	ret    

80104812 <readeflags>:
{
80104812:	55                   	push   %ebp
80104813:	89 e5                	mov    %esp,%ebp
80104815:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104818:	9c                   	pushf  
80104819:	58                   	pop    %eax
8010481a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010481d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104820:	c9                   	leave  
80104821:	c3                   	ret    

80104822 <cli>:
{
80104822:	55                   	push   %ebp
80104823:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104825:	fa                   	cli    
}
80104826:	90                   	nop
80104827:	5d                   	pop    %ebp
80104828:	c3                   	ret    

80104829 <sti>:
{
80104829:	55                   	push   %ebp
8010482a:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010482c:	fb                   	sti    
}
8010482d:	90                   	nop
8010482e:	5d                   	pop    %ebp
8010482f:	c3                   	ret    

80104830 <xchg>:
{
80104830:	55                   	push   %ebp
80104831:	89 e5                	mov    %esp,%ebp
80104833:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104836:	8b 55 08             	mov    0x8(%ebp),%edx
80104839:	8b 45 0c             	mov    0xc(%ebp),%eax
8010483c:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010483f:	f0 87 02             	lock xchg %eax,(%edx)
80104842:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104845:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104848:	c9                   	leave  
80104849:	c3                   	ret    

8010484a <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010484a:	55                   	push   %ebp
8010484b:	89 e5                	mov    %esp,%ebp
  lk->name = name;
8010484d:	8b 45 08             	mov    0x8(%ebp),%eax
80104850:	8b 55 0c             	mov    0xc(%ebp),%edx
80104853:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104856:	8b 45 08             	mov    0x8(%ebp),%eax
80104859:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010485f:	8b 45 08             	mov    0x8(%ebp),%eax
80104862:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104869:	90                   	nop
8010486a:	5d                   	pop    %ebp
8010486b:	c3                   	ret    

8010486c <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010486c:	55                   	push   %ebp
8010486d:	89 e5                	mov    %esp,%ebp
8010486f:	53                   	push   %ebx
80104870:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104873:	e8 5f 01 00 00       	call   801049d7 <pushcli>
  if(holding(lk)){
80104878:	8b 45 08             	mov    0x8(%ebp),%eax
8010487b:	83 ec 0c             	sub    $0xc,%esp
8010487e:	50                   	push   %eax
8010487f:	e8 23 01 00 00       	call   801049a7 <holding>
80104884:	83 c4 10             	add    $0x10,%esp
80104887:	85 c0                	test   %eax,%eax
80104889:	74 0d                	je     80104898 <acquire+0x2c>
    panic("acquire");
8010488b:	83 ec 0c             	sub    $0xc,%esp
8010488e:	68 03 a5 10 80       	push   $0x8010a503
80104893:	e8 11 bd ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104898:	90                   	nop
80104899:	8b 45 08             	mov    0x8(%ebp),%eax
8010489c:	83 ec 08             	sub    $0x8,%esp
8010489f:	6a 01                	push   $0x1
801048a1:	50                   	push   %eax
801048a2:	e8 89 ff ff ff       	call   80104830 <xchg>
801048a7:	83 c4 10             	add    $0x10,%esp
801048aa:	85 c0                	test   %eax,%eax
801048ac:	75 eb                	jne    80104899 <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
801048ae:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
801048b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
801048b6:	e8 fd f0 ff ff       	call   801039b8 <mycpu>
801048bb:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
801048be:	8b 45 08             	mov    0x8(%ebp),%eax
801048c1:	83 c0 0c             	add    $0xc,%eax
801048c4:	83 ec 08             	sub    $0x8,%esp
801048c7:	50                   	push   %eax
801048c8:	8d 45 08             	lea    0x8(%ebp),%eax
801048cb:	50                   	push   %eax
801048cc:	e8 5b 00 00 00       	call   8010492c <getcallerpcs>
801048d1:	83 c4 10             	add    $0x10,%esp
}
801048d4:	90                   	nop
801048d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801048d8:	c9                   	leave  
801048d9:	c3                   	ret    

801048da <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801048da:	55                   	push   %ebp
801048db:	89 e5                	mov    %esp,%ebp
801048dd:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801048e0:	83 ec 0c             	sub    $0xc,%esp
801048e3:	ff 75 08             	push   0x8(%ebp)
801048e6:	e8 bc 00 00 00       	call   801049a7 <holding>
801048eb:	83 c4 10             	add    $0x10,%esp
801048ee:	85 c0                	test   %eax,%eax
801048f0:	75 0d                	jne    801048ff <release+0x25>
    panic("release");
801048f2:	83 ec 0c             	sub    $0xc,%esp
801048f5:	68 0b a5 10 80       	push   $0x8010a50b
801048fa:	e8 aa bc ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
801048ff:	8b 45 08             	mov    0x8(%ebp),%eax
80104902:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104909:	8b 45 08             	mov    0x8(%ebp),%eax
8010490c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104913:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104918:	8b 45 08             	mov    0x8(%ebp),%eax
8010491b:	8b 55 08             	mov    0x8(%ebp),%edx
8010491e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104924:	e8 fb 00 00 00       	call   80104a24 <popcli>
}
80104929:	90                   	nop
8010492a:	c9                   	leave  
8010492b:	c3                   	ret    

8010492c <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010492c:	55                   	push   %ebp
8010492d:	89 e5                	mov    %esp,%ebp
8010492f:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104932:	8b 45 08             	mov    0x8(%ebp),%eax
80104935:	83 e8 08             	sub    $0x8,%eax
80104938:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010493b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104942:	eb 38                	jmp    8010497c <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104944:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104948:	74 53                	je     8010499d <getcallerpcs+0x71>
8010494a:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104951:	76 4a                	jbe    8010499d <getcallerpcs+0x71>
80104953:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104957:	74 44                	je     8010499d <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104959:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010495c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104963:	8b 45 0c             	mov    0xc(%ebp),%eax
80104966:	01 c2                	add    %eax,%edx
80104968:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010496b:	8b 40 04             	mov    0x4(%eax),%eax
8010496e:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104970:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104973:	8b 00                	mov    (%eax),%eax
80104975:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104978:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010497c:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104980:	7e c2                	jle    80104944 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80104982:	eb 19                	jmp    8010499d <getcallerpcs+0x71>
    pcs[i] = 0;
80104984:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104987:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010498e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104991:	01 d0                	add    %edx,%eax
80104993:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104999:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010499d:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801049a1:	7e e1                	jle    80104984 <getcallerpcs+0x58>
}
801049a3:	90                   	nop
801049a4:	90                   	nop
801049a5:	c9                   	leave  
801049a6:	c3                   	ret    

801049a7 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801049a7:	55                   	push   %ebp
801049a8:	89 e5                	mov    %esp,%ebp
801049aa:	53                   	push   %ebx
801049ab:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
801049ae:	8b 45 08             	mov    0x8(%ebp),%eax
801049b1:	8b 00                	mov    (%eax),%eax
801049b3:	85 c0                	test   %eax,%eax
801049b5:	74 16                	je     801049cd <holding+0x26>
801049b7:	8b 45 08             	mov    0x8(%ebp),%eax
801049ba:	8b 58 08             	mov    0x8(%eax),%ebx
801049bd:	e8 f6 ef ff ff       	call   801039b8 <mycpu>
801049c2:	39 c3                	cmp    %eax,%ebx
801049c4:	75 07                	jne    801049cd <holding+0x26>
801049c6:	b8 01 00 00 00       	mov    $0x1,%eax
801049cb:	eb 05                	jmp    801049d2 <holding+0x2b>
801049cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801049d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801049d5:	c9                   	leave  
801049d6:	c3                   	ret    

801049d7 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801049d7:	55                   	push   %ebp
801049d8:	89 e5                	mov    %esp,%ebp
801049da:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
801049dd:	e8 30 fe ff ff       	call   80104812 <readeflags>
801049e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
801049e5:	e8 38 fe ff ff       	call   80104822 <cli>
  if(mycpu()->ncli == 0)
801049ea:	e8 c9 ef ff ff       	call   801039b8 <mycpu>
801049ef:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801049f5:	85 c0                	test   %eax,%eax
801049f7:	75 14                	jne    80104a0d <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
801049f9:	e8 ba ef ff ff       	call   801039b8 <mycpu>
801049fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a01:	81 e2 00 02 00 00    	and    $0x200,%edx
80104a07:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104a0d:	e8 a6 ef ff ff       	call   801039b8 <mycpu>
80104a12:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104a18:	83 c2 01             	add    $0x1,%edx
80104a1b:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104a21:	90                   	nop
80104a22:	c9                   	leave  
80104a23:	c3                   	ret    

80104a24 <popcli>:

void
popcli(void)
{
80104a24:	55                   	push   %ebp
80104a25:	89 e5                	mov    %esp,%ebp
80104a27:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104a2a:	e8 e3 fd ff ff       	call   80104812 <readeflags>
80104a2f:	25 00 02 00 00       	and    $0x200,%eax
80104a34:	85 c0                	test   %eax,%eax
80104a36:	74 0d                	je     80104a45 <popcli+0x21>
    panic("popcli - interruptible");
80104a38:	83 ec 0c             	sub    $0xc,%esp
80104a3b:	68 13 a5 10 80       	push   $0x8010a513
80104a40:	e8 64 bb ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
80104a45:	e8 6e ef ff ff       	call   801039b8 <mycpu>
80104a4a:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104a50:	83 ea 01             	sub    $0x1,%edx
80104a53:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104a59:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104a5f:	85 c0                	test   %eax,%eax
80104a61:	79 0d                	jns    80104a70 <popcli+0x4c>
    panic("popcli");
80104a63:	83 ec 0c             	sub    $0xc,%esp
80104a66:	68 2a a5 10 80       	push   $0x8010a52a
80104a6b:	e8 39 bb ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104a70:	e8 43 ef ff ff       	call   801039b8 <mycpu>
80104a75:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104a7b:	85 c0                	test   %eax,%eax
80104a7d:	75 14                	jne    80104a93 <popcli+0x6f>
80104a7f:	e8 34 ef ff ff       	call   801039b8 <mycpu>
80104a84:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104a8a:	85 c0                	test   %eax,%eax
80104a8c:	74 05                	je     80104a93 <popcli+0x6f>
    sti();
80104a8e:	e8 96 fd ff ff       	call   80104829 <sti>
}
80104a93:	90                   	nop
80104a94:	c9                   	leave  
80104a95:	c3                   	ret    

80104a96 <stosb>:
{
80104a96:	55                   	push   %ebp
80104a97:	89 e5                	mov    %esp,%ebp
80104a99:	57                   	push   %edi
80104a9a:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104a9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104a9e:	8b 55 10             	mov    0x10(%ebp),%edx
80104aa1:	8b 45 0c             	mov    0xc(%ebp),%eax
80104aa4:	89 cb                	mov    %ecx,%ebx
80104aa6:	89 df                	mov    %ebx,%edi
80104aa8:	89 d1                	mov    %edx,%ecx
80104aaa:	fc                   	cld    
80104aab:	f3 aa                	rep stos %al,%es:(%edi)
80104aad:	89 ca                	mov    %ecx,%edx
80104aaf:	89 fb                	mov    %edi,%ebx
80104ab1:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104ab4:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104ab7:	90                   	nop
80104ab8:	5b                   	pop    %ebx
80104ab9:	5f                   	pop    %edi
80104aba:	5d                   	pop    %ebp
80104abb:	c3                   	ret    

80104abc <stosl>:
{
80104abc:	55                   	push   %ebp
80104abd:	89 e5                	mov    %esp,%ebp
80104abf:	57                   	push   %edi
80104ac0:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104ac1:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104ac4:	8b 55 10             	mov    0x10(%ebp),%edx
80104ac7:	8b 45 0c             	mov    0xc(%ebp),%eax
80104aca:	89 cb                	mov    %ecx,%ebx
80104acc:	89 df                	mov    %ebx,%edi
80104ace:	89 d1                	mov    %edx,%ecx
80104ad0:	fc                   	cld    
80104ad1:	f3 ab                	rep stos %eax,%es:(%edi)
80104ad3:	89 ca                	mov    %ecx,%edx
80104ad5:	89 fb                	mov    %edi,%ebx
80104ad7:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104ada:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104add:	90                   	nop
80104ade:	5b                   	pop    %ebx
80104adf:	5f                   	pop    %edi
80104ae0:	5d                   	pop    %ebp
80104ae1:	c3                   	ret    

80104ae2 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104ae2:	55                   	push   %ebp
80104ae3:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104ae5:	8b 45 08             	mov    0x8(%ebp),%eax
80104ae8:	83 e0 03             	and    $0x3,%eax
80104aeb:	85 c0                	test   %eax,%eax
80104aed:	75 43                	jne    80104b32 <memset+0x50>
80104aef:	8b 45 10             	mov    0x10(%ebp),%eax
80104af2:	83 e0 03             	and    $0x3,%eax
80104af5:	85 c0                	test   %eax,%eax
80104af7:	75 39                	jne    80104b32 <memset+0x50>
    c &= 0xFF;
80104af9:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104b00:	8b 45 10             	mov    0x10(%ebp),%eax
80104b03:	c1 e8 02             	shr    $0x2,%eax
80104b06:	89 c2                	mov    %eax,%edx
80104b08:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b0b:	c1 e0 18             	shl    $0x18,%eax
80104b0e:	89 c1                	mov    %eax,%ecx
80104b10:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b13:	c1 e0 10             	shl    $0x10,%eax
80104b16:	09 c1                	or     %eax,%ecx
80104b18:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b1b:	c1 e0 08             	shl    $0x8,%eax
80104b1e:	09 c8                	or     %ecx,%eax
80104b20:	0b 45 0c             	or     0xc(%ebp),%eax
80104b23:	52                   	push   %edx
80104b24:	50                   	push   %eax
80104b25:	ff 75 08             	push   0x8(%ebp)
80104b28:	e8 8f ff ff ff       	call   80104abc <stosl>
80104b2d:	83 c4 0c             	add    $0xc,%esp
80104b30:	eb 12                	jmp    80104b44 <memset+0x62>
  } else
    stosb(dst, c, n);
80104b32:	8b 45 10             	mov    0x10(%ebp),%eax
80104b35:	50                   	push   %eax
80104b36:	ff 75 0c             	push   0xc(%ebp)
80104b39:	ff 75 08             	push   0x8(%ebp)
80104b3c:	e8 55 ff ff ff       	call   80104a96 <stosb>
80104b41:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104b44:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104b47:	c9                   	leave  
80104b48:	c3                   	ret    

80104b49 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104b49:	55                   	push   %ebp
80104b4a:	89 e5                	mov    %esp,%ebp
80104b4c:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104b4f:	8b 45 08             	mov    0x8(%ebp),%eax
80104b52:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104b55:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b58:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104b5b:	eb 30                	jmp    80104b8d <memcmp+0x44>
    if(*s1 != *s2)
80104b5d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b60:	0f b6 10             	movzbl (%eax),%edx
80104b63:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104b66:	0f b6 00             	movzbl (%eax),%eax
80104b69:	38 c2                	cmp    %al,%dl
80104b6b:	74 18                	je     80104b85 <memcmp+0x3c>
      return *s1 - *s2;
80104b6d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b70:	0f b6 00             	movzbl (%eax),%eax
80104b73:	0f b6 d0             	movzbl %al,%edx
80104b76:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104b79:	0f b6 00             	movzbl (%eax),%eax
80104b7c:	0f b6 c8             	movzbl %al,%ecx
80104b7f:	89 d0                	mov    %edx,%eax
80104b81:	29 c8                	sub    %ecx,%eax
80104b83:	eb 1a                	jmp    80104b9f <memcmp+0x56>
    s1++, s2++;
80104b85:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104b89:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104b8d:	8b 45 10             	mov    0x10(%ebp),%eax
80104b90:	8d 50 ff             	lea    -0x1(%eax),%edx
80104b93:	89 55 10             	mov    %edx,0x10(%ebp)
80104b96:	85 c0                	test   %eax,%eax
80104b98:	75 c3                	jne    80104b5d <memcmp+0x14>
  }

  return 0;
80104b9a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b9f:	c9                   	leave  
80104ba0:	c3                   	ret    

80104ba1 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104ba1:	55                   	push   %ebp
80104ba2:	89 e5                	mov    %esp,%ebp
80104ba4:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104ba7:	8b 45 0c             	mov    0xc(%ebp),%eax
80104baa:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104bad:	8b 45 08             	mov    0x8(%ebp),%eax
80104bb0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104bb3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bb6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104bb9:	73 54                	jae    80104c0f <memmove+0x6e>
80104bbb:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104bbe:	8b 45 10             	mov    0x10(%ebp),%eax
80104bc1:	01 d0                	add    %edx,%eax
80104bc3:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104bc6:	73 47                	jae    80104c0f <memmove+0x6e>
    s += n;
80104bc8:	8b 45 10             	mov    0x10(%ebp),%eax
80104bcb:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104bce:	8b 45 10             	mov    0x10(%ebp),%eax
80104bd1:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104bd4:	eb 13                	jmp    80104be9 <memmove+0x48>
      *--d = *--s;
80104bd6:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104bda:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104bde:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104be1:	0f b6 10             	movzbl (%eax),%edx
80104be4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104be7:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104be9:	8b 45 10             	mov    0x10(%ebp),%eax
80104bec:	8d 50 ff             	lea    -0x1(%eax),%edx
80104bef:	89 55 10             	mov    %edx,0x10(%ebp)
80104bf2:	85 c0                	test   %eax,%eax
80104bf4:	75 e0                	jne    80104bd6 <memmove+0x35>
  if(s < d && s + n > d){
80104bf6:	eb 24                	jmp    80104c1c <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104bf8:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104bfb:	8d 42 01             	lea    0x1(%edx),%eax
80104bfe:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104c01:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c04:	8d 48 01             	lea    0x1(%eax),%ecx
80104c07:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104c0a:	0f b6 12             	movzbl (%edx),%edx
80104c0d:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104c0f:	8b 45 10             	mov    0x10(%ebp),%eax
80104c12:	8d 50 ff             	lea    -0x1(%eax),%edx
80104c15:	89 55 10             	mov    %edx,0x10(%ebp)
80104c18:	85 c0                	test   %eax,%eax
80104c1a:	75 dc                	jne    80104bf8 <memmove+0x57>

  return dst;
80104c1c:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104c1f:	c9                   	leave  
80104c20:	c3                   	ret    

80104c21 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104c21:	55                   	push   %ebp
80104c22:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104c24:	ff 75 10             	push   0x10(%ebp)
80104c27:	ff 75 0c             	push   0xc(%ebp)
80104c2a:	ff 75 08             	push   0x8(%ebp)
80104c2d:	e8 6f ff ff ff       	call   80104ba1 <memmove>
80104c32:	83 c4 0c             	add    $0xc,%esp
}
80104c35:	c9                   	leave  
80104c36:	c3                   	ret    

80104c37 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104c37:	55                   	push   %ebp
80104c38:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104c3a:	eb 0c                	jmp    80104c48 <strncmp+0x11>
    n--, p++, q++;
80104c3c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104c40:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104c44:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104c48:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104c4c:	74 1a                	je     80104c68 <strncmp+0x31>
80104c4e:	8b 45 08             	mov    0x8(%ebp),%eax
80104c51:	0f b6 00             	movzbl (%eax),%eax
80104c54:	84 c0                	test   %al,%al
80104c56:	74 10                	je     80104c68 <strncmp+0x31>
80104c58:	8b 45 08             	mov    0x8(%ebp),%eax
80104c5b:	0f b6 10             	movzbl (%eax),%edx
80104c5e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c61:	0f b6 00             	movzbl (%eax),%eax
80104c64:	38 c2                	cmp    %al,%dl
80104c66:	74 d4                	je     80104c3c <strncmp+0x5>
  if(n == 0)
80104c68:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104c6c:	75 07                	jne    80104c75 <strncmp+0x3e>
    return 0;
80104c6e:	b8 00 00 00 00       	mov    $0x0,%eax
80104c73:	eb 16                	jmp    80104c8b <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80104c75:	8b 45 08             	mov    0x8(%ebp),%eax
80104c78:	0f b6 00             	movzbl (%eax),%eax
80104c7b:	0f b6 d0             	movzbl %al,%edx
80104c7e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c81:	0f b6 00             	movzbl (%eax),%eax
80104c84:	0f b6 c8             	movzbl %al,%ecx
80104c87:	89 d0                	mov    %edx,%eax
80104c89:	29 c8                	sub    %ecx,%eax
}
80104c8b:	5d                   	pop    %ebp
80104c8c:	c3                   	ret    

80104c8d <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104c8d:	55                   	push   %ebp
80104c8e:	89 e5                	mov    %esp,%ebp
80104c90:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104c93:	8b 45 08             	mov    0x8(%ebp),%eax
80104c96:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104c99:	90                   	nop
80104c9a:	8b 45 10             	mov    0x10(%ebp),%eax
80104c9d:	8d 50 ff             	lea    -0x1(%eax),%edx
80104ca0:	89 55 10             	mov    %edx,0x10(%ebp)
80104ca3:	85 c0                	test   %eax,%eax
80104ca5:	7e 2c                	jle    80104cd3 <strncpy+0x46>
80104ca7:	8b 55 0c             	mov    0xc(%ebp),%edx
80104caa:	8d 42 01             	lea    0x1(%edx),%eax
80104cad:	89 45 0c             	mov    %eax,0xc(%ebp)
80104cb0:	8b 45 08             	mov    0x8(%ebp),%eax
80104cb3:	8d 48 01             	lea    0x1(%eax),%ecx
80104cb6:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104cb9:	0f b6 12             	movzbl (%edx),%edx
80104cbc:	88 10                	mov    %dl,(%eax)
80104cbe:	0f b6 00             	movzbl (%eax),%eax
80104cc1:	84 c0                	test   %al,%al
80104cc3:	75 d5                	jne    80104c9a <strncpy+0xd>
    ;
  while(n-- > 0)
80104cc5:	eb 0c                	jmp    80104cd3 <strncpy+0x46>
    *s++ = 0;
80104cc7:	8b 45 08             	mov    0x8(%ebp),%eax
80104cca:	8d 50 01             	lea    0x1(%eax),%edx
80104ccd:	89 55 08             	mov    %edx,0x8(%ebp)
80104cd0:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104cd3:	8b 45 10             	mov    0x10(%ebp),%eax
80104cd6:	8d 50 ff             	lea    -0x1(%eax),%edx
80104cd9:	89 55 10             	mov    %edx,0x10(%ebp)
80104cdc:	85 c0                	test   %eax,%eax
80104cde:	7f e7                	jg     80104cc7 <strncpy+0x3a>
  return os;
80104ce0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104ce3:	c9                   	leave  
80104ce4:	c3                   	ret    

80104ce5 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104ce5:	55                   	push   %ebp
80104ce6:	89 e5                	mov    %esp,%ebp
80104ce8:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104ceb:	8b 45 08             	mov    0x8(%ebp),%eax
80104cee:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104cf1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104cf5:	7f 05                	jg     80104cfc <safestrcpy+0x17>
    return os;
80104cf7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cfa:	eb 32                	jmp    80104d2e <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80104cfc:	90                   	nop
80104cfd:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104d01:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104d05:	7e 1e                	jle    80104d25 <safestrcpy+0x40>
80104d07:	8b 55 0c             	mov    0xc(%ebp),%edx
80104d0a:	8d 42 01             	lea    0x1(%edx),%eax
80104d0d:	89 45 0c             	mov    %eax,0xc(%ebp)
80104d10:	8b 45 08             	mov    0x8(%ebp),%eax
80104d13:	8d 48 01             	lea    0x1(%eax),%ecx
80104d16:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104d19:	0f b6 12             	movzbl (%edx),%edx
80104d1c:	88 10                	mov    %dl,(%eax)
80104d1e:	0f b6 00             	movzbl (%eax),%eax
80104d21:	84 c0                	test   %al,%al
80104d23:	75 d8                	jne    80104cfd <safestrcpy+0x18>
    ;
  *s = 0;
80104d25:	8b 45 08             	mov    0x8(%ebp),%eax
80104d28:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104d2b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d2e:	c9                   	leave  
80104d2f:	c3                   	ret    

80104d30 <strlen>:

int
strlen(const char *s)
{
80104d30:	55                   	push   %ebp
80104d31:	89 e5                	mov    %esp,%ebp
80104d33:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104d36:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104d3d:	eb 04                	jmp    80104d43 <strlen+0x13>
80104d3f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104d43:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104d46:	8b 45 08             	mov    0x8(%ebp),%eax
80104d49:	01 d0                	add    %edx,%eax
80104d4b:	0f b6 00             	movzbl (%eax),%eax
80104d4e:	84 c0                	test   %al,%al
80104d50:	75 ed                	jne    80104d3f <strlen+0xf>
    ;
  return n;
80104d52:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d55:	c9                   	leave  
80104d56:	c3                   	ret    

80104d57 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104d57:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104d5b:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104d5f:	55                   	push   %ebp
  pushl %ebx
80104d60:	53                   	push   %ebx
  pushl %esi
80104d61:	56                   	push   %esi
  pushl %edi
80104d62:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104d63:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104d65:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104d67:	5f                   	pop    %edi
  popl %esi
80104d68:	5e                   	pop    %esi
  popl %ebx
80104d69:	5b                   	pop    %ebx
  popl %ebp
80104d6a:	5d                   	pop    %ebp
  ret
80104d6b:	c3                   	ret    

80104d6c <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104d6c:	55                   	push   %ebp
80104d6d:	89 e5                	mov    %esp,%ebp
80104d6f:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104d72:	e8 b9 ec ff ff       	call   80103a30 <myproc>
80104d77:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104d7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d7d:	8b 00                	mov    (%eax),%eax
80104d7f:	39 45 08             	cmp    %eax,0x8(%ebp)
80104d82:	73 0f                	jae    80104d93 <fetchint+0x27>
80104d84:	8b 45 08             	mov    0x8(%ebp),%eax
80104d87:	8d 50 04             	lea    0x4(%eax),%edx
80104d8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d8d:	8b 00                	mov    (%eax),%eax
80104d8f:	39 c2                	cmp    %eax,%edx
80104d91:	76 07                	jbe    80104d9a <fetchint+0x2e>
    return -1;
80104d93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d98:	eb 0f                	jmp    80104da9 <fetchint+0x3d>
  *ip = *(int*)(addr);
80104d9a:	8b 45 08             	mov    0x8(%ebp),%eax
80104d9d:	8b 10                	mov    (%eax),%edx
80104d9f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104da2:	89 10                	mov    %edx,(%eax)
  return 0;
80104da4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104da9:	c9                   	leave  
80104daa:	c3                   	ret    

80104dab <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104dab:	55                   	push   %ebp
80104dac:	89 e5                	mov    %esp,%ebp
80104dae:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80104db1:	e8 7a ec ff ff       	call   80103a30 <myproc>
80104db6:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80104db9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dbc:	8b 00                	mov    (%eax),%eax
80104dbe:	39 45 08             	cmp    %eax,0x8(%ebp)
80104dc1:	72 07                	jb     80104dca <fetchstr+0x1f>
    return -1;
80104dc3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dc8:	eb 41                	jmp    80104e0b <fetchstr+0x60>
  *pp = (char*)addr;
80104dca:	8b 55 08             	mov    0x8(%ebp),%edx
80104dcd:	8b 45 0c             	mov    0xc(%ebp),%eax
80104dd0:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80104dd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dd5:	8b 00                	mov    (%eax),%eax
80104dd7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80104dda:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ddd:	8b 00                	mov    (%eax),%eax
80104ddf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104de2:	eb 1a                	jmp    80104dfe <fetchstr+0x53>
    if(*s == 0)
80104de4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104de7:	0f b6 00             	movzbl (%eax),%eax
80104dea:	84 c0                	test   %al,%al
80104dec:	75 0c                	jne    80104dfa <fetchstr+0x4f>
      return s - *pp;
80104dee:	8b 45 0c             	mov    0xc(%ebp),%eax
80104df1:	8b 10                	mov    (%eax),%edx
80104df3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104df6:	29 d0                	sub    %edx,%eax
80104df8:	eb 11                	jmp    80104e0b <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
80104dfa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104dfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e01:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104e04:	72 de                	jb     80104de4 <fetchstr+0x39>
  }
  return -1;
80104e06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104e0b:	c9                   	leave  
80104e0c:	c3                   	ret    

80104e0d <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104e0d:	55                   	push   %ebp
80104e0e:	89 e5                	mov    %esp,%ebp
80104e10:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104e13:	e8 18 ec ff ff       	call   80103a30 <myproc>
80104e18:	8b 40 18             	mov    0x18(%eax),%eax
80104e1b:	8b 50 44             	mov    0x44(%eax),%edx
80104e1e:	8b 45 08             	mov    0x8(%ebp),%eax
80104e21:	c1 e0 02             	shl    $0x2,%eax
80104e24:	01 d0                	add    %edx,%eax
80104e26:	83 c0 04             	add    $0x4,%eax
80104e29:	83 ec 08             	sub    $0x8,%esp
80104e2c:	ff 75 0c             	push   0xc(%ebp)
80104e2f:	50                   	push   %eax
80104e30:	e8 37 ff ff ff       	call   80104d6c <fetchint>
80104e35:	83 c4 10             	add    $0x10,%esp
}
80104e38:	c9                   	leave  
80104e39:	c3                   	ret    

80104e3a <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104e3a:	55                   	push   %ebp
80104e3b:	89 e5                	mov    %esp,%ebp
80104e3d:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80104e40:	e8 eb eb ff ff       	call   80103a30 <myproc>
80104e45:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80104e48:	83 ec 08             	sub    $0x8,%esp
80104e4b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104e4e:	50                   	push   %eax
80104e4f:	ff 75 08             	push   0x8(%ebp)
80104e52:	e8 b6 ff ff ff       	call   80104e0d <argint>
80104e57:	83 c4 10             	add    $0x10,%esp
80104e5a:	85 c0                	test   %eax,%eax
80104e5c:	79 07                	jns    80104e65 <argptr+0x2b>
    return -1;
80104e5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e63:	eb 3b                	jmp    80104ea0 <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104e65:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104e69:	78 1f                	js     80104e8a <argptr+0x50>
80104e6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e6e:	8b 00                	mov    (%eax),%eax
80104e70:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104e73:	39 d0                	cmp    %edx,%eax
80104e75:	76 13                	jbe    80104e8a <argptr+0x50>
80104e77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e7a:	89 c2                	mov    %eax,%edx
80104e7c:	8b 45 10             	mov    0x10(%ebp),%eax
80104e7f:	01 c2                	add    %eax,%edx
80104e81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e84:	8b 00                	mov    (%eax),%eax
80104e86:	39 c2                	cmp    %eax,%edx
80104e88:	76 07                	jbe    80104e91 <argptr+0x57>
    return -1;
80104e8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e8f:	eb 0f                	jmp    80104ea0 <argptr+0x66>
  *pp = (char*)i;
80104e91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e94:	89 c2                	mov    %eax,%edx
80104e96:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e99:	89 10                	mov    %edx,(%eax)
  return 0;
80104e9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104ea0:	c9                   	leave  
80104ea1:	c3                   	ret    

80104ea2 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104ea2:	55                   	push   %ebp
80104ea3:	89 e5                	mov    %esp,%ebp
80104ea5:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104ea8:	83 ec 08             	sub    $0x8,%esp
80104eab:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104eae:	50                   	push   %eax
80104eaf:	ff 75 08             	push   0x8(%ebp)
80104eb2:	e8 56 ff ff ff       	call   80104e0d <argint>
80104eb7:	83 c4 10             	add    $0x10,%esp
80104eba:	85 c0                	test   %eax,%eax
80104ebc:	79 07                	jns    80104ec5 <argstr+0x23>
    return -1;
80104ebe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ec3:	eb 12                	jmp    80104ed7 <argstr+0x35>
  return fetchstr(addr, pp);
80104ec5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ec8:	83 ec 08             	sub    $0x8,%esp
80104ecb:	ff 75 0c             	push   0xc(%ebp)
80104ece:	50                   	push   %eax
80104ecf:	e8 d7 fe ff ff       	call   80104dab <fetchstr>
80104ed4:	83 c4 10             	add    $0x10,%esp
}
80104ed7:	c9                   	leave  
80104ed8:	c3                   	ret    

80104ed9 <syscall>:
[SYS_printpt] sys_printpt,
};

void
syscall(void)
{
80104ed9:	55                   	push   %ebp
80104eda:	89 e5                	mov    %esp,%ebp
80104edc:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80104edf:	e8 4c eb ff ff       	call   80103a30 <myproc>
80104ee4:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80104ee7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eea:	8b 40 18             	mov    0x18(%eax),%eax
80104eed:	8b 40 1c             	mov    0x1c(%eax),%eax
80104ef0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104ef3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104ef7:	7e 2f                	jle    80104f28 <syscall+0x4f>
80104ef9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104efc:	83 f8 16             	cmp    $0x16,%eax
80104eff:	77 27                	ja     80104f28 <syscall+0x4f>
80104f01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f04:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104f0b:	85 c0                	test   %eax,%eax
80104f0d:	74 19                	je     80104f28 <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80104f0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f12:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104f19:	ff d0                	call   *%eax
80104f1b:	89 c2                	mov    %eax,%edx
80104f1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f20:	8b 40 18             	mov    0x18(%eax),%eax
80104f23:	89 50 1c             	mov    %edx,0x1c(%eax)
80104f26:	eb 2c                	jmp    80104f54 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80104f28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f2b:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104f2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f31:	8b 40 10             	mov    0x10(%eax),%eax
80104f34:	ff 75 f0             	push   -0x10(%ebp)
80104f37:	52                   	push   %edx
80104f38:	50                   	push   %eax
80104f39:	68 31 a5 10 80       	push   $0x8010a531
80104f3e:	e8 b1 b4 ff ff       	call   801003f4 <cprintf>
80104f43:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80104f46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f49:	8b 40 18             	mov    0x18(%eax),%eax
80104f4c:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80104f53:	90                   	nop
80104f54:	90                   	nop
80104f55:	c9                   	leave  
80104f56:	c3                   	ret    

80104f57 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104f57:	55                   	push   %ebp
80104f58:	89 e5                	mov    %esp,%ebp
80104f5a:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104f5d:	83 ec 08             	sub    $0x8,%esp
80104f60:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104f63:	50                   	push   %eax
80104f64:	ff 75 08             	push   0x8(%ebp)
80104f67:	e8 a1 fe ff ff       	call   80104e0d <argint>
80104f6c:	83 c4 10             	add    $0x10,%esp
80104f6f:	85 c0                	test   %eax,%eax
80104f71:	79 07                	jns    80104f7a <argfd+0x23>
    return -1;
80104f73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f78:	eb 4f                	jmp    80104fc9 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104f7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f7d:	85 c0                	test   %eax,%eax
80104f7f:	78 20                	js     80104fa1 <argfd+0x4a>
80104f81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f84:	83 f8 0f             	cmp    $0xf,%eax
80104f87:	7f 18                	jg     80104fa1 <argfd+0x4a>
80104f89:	e8 a2 ea ff ff       	call   80103a30 <myproc>
80104f8e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f91:	83 c2 08             	add    $0x8,%edx
80104f94:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104f98:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104f9b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104f9f:	75 07                	jne    80104fa8 <argfd+0x51>
    return -1;
80104fa1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fa6:	eb 21                	jmp    80104fc9 <argfd+0x72>
  if(pfd)
80104fa8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104fac:	74 08                	je     80104fb6 <argfd+0x5f>
    *pfd = fd;
80104fae:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104fb1:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fb4:	89 10                	mov    %edx,(%eax)
  if(pf)
80104fb6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104fba:	74 08                	je     80104fc4 <argfd+0x6d>
    *pf = f;
80104fbc:	8b 45 10             	mov    0x10(%ebp),%eax
80104fbf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104fc2:	89 10                	mov    %edx,(%eax)
  return 0;
80104fc4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104fc9:	c9                   	leave  
80104fca:	c3                   	ret    

80104fcb <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80104fcb:	55                   	push   %ebp
80104fcc:	89 e5                	mov    %esp,%ebp
80104fce:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80104fd1:	e8 5a ea ff ff       	call   80103a30 <myproc>
80104fd6:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80104fd9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104fe0:	eb 2a                	jmp    8010500c <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80104fe2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fe5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104fe8:	83 c2 08             	add    $0x8,%edx
80104feb:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104fef:	85 c0                	test   %eax,%eax
80104ff1:	75 15                	jne    80105008 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80104ff3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ff6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ff9:	8d 4a 08             	lea    0x8(%edx),%ecx
80104ffc:	8b 55 08             	mov    0x8(%ebp),%edx
80104fff:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105003:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105006:	eb 0f                	jmp    80105017 <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
80105008:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010500c:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105010:	7e d0                	jle    80104fe2 <fdalloc+0x17>
    }
  }
  return -1;
80105012:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105017:	c9                   	leave  
80105018:	c3                   	ret    

80105019 <sys_dup>:

int
sys_dup(void)
{
80105019:	55                   	push   %ebp
8010501a:	89 e5                	mov    %esp,%ebp
8010501c:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
8010501f:	83 ec 04             	sub    $0x4,%esp
80105022:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105025:	50                   	push   %eax
80105026:	6a 00                	push   $0x0
80105028:	6a 00                	push   $0x0
8010502a:	e8 28 ff ff ff       	call   80104f57 <argfd>
8010502f:	83 c4 10             	add    $0x10,%esp
80105032:	85 c0                	test   %eax,%eax
80105034:	79 07                	jns    8010503d <sys_dup+0x24>
    return -1;
80105036:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010503b:	eb 31                	jmp    8010506e <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
8010503d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105040:	83 ec 0c             	sub    $0xc,%esp
80105043:	50                   	push   %eax
80105044:	e8 82 ff ff ff       	call   80104fcb <fdalloc>
80105049:	83 c4 10             	add    $0x10,%esp
8010504c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010504f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105053:	79 07                	jns    8010505c <sys_dup+0x43>
    return -1;
80105055:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010505a:	eb 12                	jmp    8010506e <sys_dup+0x55>
  filedup(f);
8010505c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010505f:	83 ec 0c             	sub    $0xc,%esp
80105062:	50                   	push   %eax
80105063:	e8 e2 bf ff ff       	call   8010104a <filedup>
80105068:	83 c4 10             	add    $0x10,%esp
  return fd;
8010506b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010506e:	c9                   	leave  
8010506f:	c3                   	ret    

80105070 <sys_read>:

int
sys_read(void)
{
80105070:	55                   	push   %ebp
80105071:	89 e5                	mov    %esp,%ebp
80105073:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105076:	83 ec 04             	sub    $0x4,%esp
80105079:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010507c:	50                   	push   %eax
8010507d:	6a 00                	push   $0x0
8010507f:	6a 00                	push   $0x0
80105081:	e8 d1 fe ff ff       	call   80104f57 <argfd>
80105086:	83 c4 10             	add    $0x10,%esp
80105089:	85 c0                	test   %eax,%eax
8010508b:	78 2e                	js     801050bb <sys_read+0x4b>
8010508d:	83 ec 08             	sub    $0x8,%esp
80105090:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105093:	50                   	push   %eax
80105094:	6a 02                	push   $0x2
80105096:	e8 72 fd ff ff       	call   80104e0d <argint>
8010509b:	83 c4 10             	add    $0x10,%esp
8010509e:	85 c0                	test   %eax,%eax
801050a0:	78 19                	js     801050bb <sys_read+0x4b>
801050a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050a5:	83 ec 04             	sub    $0x4,%esp
801050a8:	50                   	push   %eax
801050a9:	8d 45 ec             	lea    -0x14(%ebp),%eax
801050ac:	50                   	push   %eax
801050ad:	6a 01                	push   $0x1
801050af:	e8 86 fd ff ff       	call   80104e3a <argptr>
801050b4:	83 c4 10             	add    $0x10,%esp
801050b7:	85 c0                	test   %eax,%eax
801050b9:	79 07                	jns    801050c2 <sys_read+0x52>
    return -1;
801050bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050c0:	eb 17                	jmp    801050d9 <sys_read+0x69>
  return fileread(f, p, n);
801050c2:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801050c5:	8b 55 ec             	mov    -0x14(%ebp),%edx
801050c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050cb:	83 ec 04             	sub    $0x4,%esp
801050ce:	51                   	push   %ecx
801050cf:	52                   	push   %edx
801050d0:	50                   	push   %eax
801050d1:	e8 04 c1 ff ff       	call   801011da <fileread>
801050d6:	83 c4 10             	add    $0x10,%esp
}
801050d9:	c9                   	leave  
801050da:	c3                   	ret    

801050db <sys_write>:

int
sys_write(void)
{
801050db:	55                   	push   %ebp
801050dc:	89 e5                	mov    %esp,%ebp
801050de:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801050e1:	83 ec 04             	sub    $0x4,%esp
801050e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
801050e7:	50                   	push   %eax
801050e8:	6a 00                	push   $0x0
801050ea:	6a 00                	push   $0x0
801050ec:	e8 66 fe ff ff       	call   80104f57 <argfd>
801050f1:	83 c4 10             	add    $0x10,%esp
801050f4:	85 c0                	test   %eax,%eax
801050f6:	78 2e                	js     80105126 <sys_write+0x4b>
801050f8:	83 ec 08             	sub    $0x8,%esp
801050fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801050fe:	50                   	push   %eax
801050ff:	6a 02                	push   $0x2
80105101:	e8 07 fd ff ff       	call   80104e0d <argint>
80105106:	83 c4 10             	add    $0x10,%esp
80105109:	85 c0                	test   %eax,%eax
8010510b:	78 19                	js     80105126 <sys_write+0x4b>
8010510d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105110:	83 ec 04             	sub    $0x4,%esp
80105113:	50                   	push   %eax
80105114:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105117:	50                   	push   %eax
80105118:	6a 01                	push   $0x1
8010511a:	e8 1b fd ff ff       	call   80104e3a <argptr>
8010511f:	83 c4 10             	add    $0x10,%esp
80105122:	85 c0                	test   %eax,%eax
80105124:	79 07                	jns    8010512d <sys_write+0x52>
    return -1;
80105126:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010512b:	eb 17                	jmp    80105144 <sys_write+0x69>
  return filewrite(f, p, n);
8010512d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105130:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105133:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105136:	83 ec 04             	sub    $0x4,%esp
80105139:	51                   	push   %ecx
8010513a:	52                   	push   %edx
8010513b:	50                   	push   %eax
8010513c:	e8 51 c1 ff ff       	call   80101292 <filewrite>
80105141:	83 c4 10             	add    $0x10,%esp
}
80105144:	c9                   	leave  
80105145:	c3                   	ret    

80105146 <sys_close>:

int
sys_close(void)
{
80105146:	55                   	push   %ebp
80105147:	89 e5                	mov    %esp,%ebp
80105149:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
8010514c:	83 ec 04             	sub    $0x4,%esp
8010514f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105152:	50                   	push   %eax
80105153:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105156:	50                   	push   %eax
80105157:	6a 00                	push   $0x0
80105159:	e8 f9 fd ff ff       	call   80104f57 <argfd>
8010515e:	83 c4 10             	add    $0x10,%esp
80105161:	85 c0                	test   %eax,%eax
80105163:	79 07                	jns    8010516c <sys_close+0x26>
    return -1;
80105165:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010516a:	eb 27                	jmp    80105193 <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
8010516c:	e8 bf e8 ff ff       	call   80103a30 <myproc>
80105171:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105174:	83 c2 08             	add    $0x8,%edx
80105177:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010517e:	00 
  fileclose(f);
8010517f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105182:	83 ec 0c             	sub    $0xc,%esp
80105185:	50                   	push   %eax
80105186:	e8 10 bf ff ff       	call   8010109b <fileclose>
8010518b:	83 c4 10             	add    $0x10,%esp
  return 0;
8010518e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105193:	c9                   	leave  
80105194:	c3                   	ret    

80105195 <sys_fstat>:

int
sys_fstat(void)
{
80105195:	55                   	push   %ebp
80105196:	89 e5                	mov    %esp,%ebp
80105198:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010519b:	83 ec 04             	sub    $0x4,%esp
8010519e:	8d 45 f4             	lea    -0xc(%ebp),%eax
801051a1:	50                   	push   %eax
801051a2:	6a 00                	push   $0x0
801051a4:	6a 00                	push   $0x0
801051a6:	e8 ac fd ff ff       	call   80104f57 <argfd>
801051ab:	83 c4 10             	add    $0x10,%esp
801051ae:	85 c0                	test   %eax,%eax
801051b0:	78 17                	js     801051c9 <sys_fstat+0x34>
801051b2:	83 ec 04             	sub    $0x4,%esp
801051b5:	6a 14                	push   $0x14
801051b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801051ba:	50                   	push   %eax
801051bb:	6a 01                	push   $0x1
801051bd:	e8 78 fc ff ff       	call   80104e3a <argptr>
801051c2:	83 c4 10             	add    $0x10,%esp
801051c5:	85 c0                	test   %eax,%eax
801051c7:	79 07                	jns    801051d0 <sys_fstat+0x3b>
    return -1;
801051c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051ce:	eb 13                	jmp    801051e3 <sys_fstat+0x4e>
  return filestat(f, st);
801051d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801051d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051d6:	83 ec 08             	sub    $0x8,%esp
801051d9:	52                   	push   %edx
801051da:	50                   	push   %eax
801051db:	e8 a3 bf ff ff       	call   80101183 <filestat>
801051e0:	83 c4 10             	add    $0x10,%esp
}
801051e3:	c9                   	leave  
801051e4:	c3                   	ret    

801051e5 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801051e5:	55                   	push   %ebp
801051e6:	89 e5                	mov    %esp,%ebp
801051e8:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801051eb:	83 ec 08             	sub    $0x8,%esp
801051ee:	8d 45 d8             	lea    -0x28(%ebp),%eax
801051f1:	50                   	push   %eax
801051f2:	6a 00                	push   $0x0
801051f4:	e8 a9 fc ff ff       	call   80104ea2 <argstr>
801051f9:	83 c4 10             	add    $0x10,%esp
801051fc:	85 c0                	test   %eax,%eax
801051fe:	78 15                	js     80105215 <sys_link+0x30>
80105200:	83 ec 08             	sub    $0x8,%esp
80105203:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105206:	50                   	push   %eax
80105207:	6a 01                	push   $0x1
80105209:	e8 94 fc ff ff       	call   80104ea2 <argstr>
8010520e:	83 c4 10             	add    $0x10,%esp
80105211:	85 c0                	test   %eax,%eax
80105213:	79 0a                	jns    8010521f <sys_link+0x3a>
    return -1;
80105215:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010521a:	e9 68 01 00 00       	jmp    80105387 <sys_link+0x1a2>

  begin_op();
8010521f:	e8 18 de ff ff       	call   8010303c <begin_op>
  if((ip = namei(old)) == 0){
80105224:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105227:	83 ec 0c             	sub    $0xc,%esp
8010522a:	50                   	push   %eax
8010522b:	e8 ed d2 ff ff       	call   8010251d <namei>
80105230:	83 c4 10             	add    $0x10,%esp
80105233:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105236:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010523a:	75 0f                	jne    8010524b <sys_link+0x66>
    end_op();
8010523c:	e8 87 de ff ff       	call   801030c8 <end_op>
    return -1;
80105241:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105246:	e9 3c 01 00 00       	jmp    80105387 <sys_link+0x1a2>
  }

  ilock(ip);
8010524b:	83 ec 0c             	sub    $0xc,%esp
8010524e:	ff 75 f4             	push   -0xc(%ebp)
80105251:	e8 94 c7 ff ff       	call   801019ea <ilock>
80105256:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105259:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010525c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105260:	66 83 f8 01          	cmp    $0x1,%ax
80105264:	75 1d                	jne    80105283 <sys_link+0x9e>
    iunlockput(ip);
80105266:	83 ec 0c             	sub    $0xc,%esp
80105269:	ff 75 f4             	push   -0xc(%ebp)
8010526c:	e8 aa c9 ff ff       	call   80101c1b <iunlockput>
80105271:	83 c4 10             	add    $0x10,%esp
    end_op();
80105274:	e8 4f de ff ff       	call   801030c8 <end_op>
    return -1;
80105279:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010527e:	e9 04 01 00 00       	jmp    80105387 <sys_link+0x1a2>
  }

  ip->nlink++;
80105283:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105286:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010528a:	83 c0 01             	add    $0x1,%eax
8010528d:	89 c2                	mov    %eax,%edx
8010528f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105292:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105296:	83 ec 0c             	sub    $0xc,%esp
80105299:	ff 75 f4             	push   -0xc(%ebp)
8010529c:	e8 6c c5 ff ff       	call   8010180d <iupdate>
801052a1:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
801052a4:	83 ec 0c             	sub    $0xc,%esp
801052a7:	ff 75 f4             	push   -0xc(%ebp)
801052aa:	e8 4e c8 ff ff       	call   80101afd <iunlock>
801052af:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
801052b2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801052b5:	83 ec 08             	sub    $0x8,%esp
801052b8:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801052bb:	52                   	push   %edx
801052bc:	50                   	push   %eax
801052bd:	e8 77 d2 ff ff       	call   80102539 <nameiparent>
801052c2:	83 c4 10             	add    $0x10,%esp
801052c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801052c8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801052cc:	74 71                	je     8010533f <sys_link+0x15a>
    goto bad;
  ilock(dp);
801052ce:	83 ec 0c             	sub    $0xc,%esp
801052d1:	ff 75 f0             	push   -0x10(%ebp)
801052d4:	e8 11 c7 ff ff       	call   801019ea <ilock>
801052d9:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801052dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052df:	8b 10                	mov    (%eax),%edx
801052e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052e4:	8b 00                	mov    (%eax),%eax
801052e6:	39 c2                	cmp    %eax,%edx
801052e8:	75 1d                	jne    80105307 <sys_link+0x122>
801052ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052ed:	8b 40 04             	mov    0x4(%eax),%eax
801052f0:	83 ec 04             	sub    $0x4,%esp
801052f3:	50                   	push   %eax
801052f4:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801052f7:	50                   	push   %eax
801052f8:	ff 75 f0             	push   -0x10(%ebp)
801052fb:	e8 86 cf ff ff       	call   80102286 <dirlink>
80105300:	83 c4 10             	add    $0x10,%esp
80105303:	85 c0                	test   %eax,%eax
80105305:	79 10                	jns    80105317 <sys_link+0x132>
    iunlockput(dp);
80105307:	83 ec 0c             	sub    $0xc,%esp
8010530a:	ff 75 f0             	push   -0x10(%ebp)
8010530d:	e8 09 c9 ff ff       	call   80101c1b <iunlockput>
80105312:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105315:	eb 29                	jmp    80105340 <sys_link+0x15b>
  }
  iunlockput(dp);
80105317:	83 ec 0c             	sub    $0xc,%esp
8010531a:	ff 75 f0             	push   -0x10(%ebp)
8010531d:	e8 f9 c8 ff ff       	call   80101c1b <iunlockput>
80105322:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105325:	83 ec 0c             	sub    $0xc,%esp
80105328:	ff 75 f4             	push   -0xc(%ebp)
8010532b:	e8 1b c8 ff ff       	call   80101b4b <iput>
80105330:	83 c4 10             	add    $0x10,%esp

  end_op();
80105333:	e8 90 dd ff ff       	call   801030c8 <end_op>

  return 0;
80105338:	b8 00 00 00 00       	mov    $0x0,%eax
8010533d:	eb 48                	jmp    80105387 <sys_link+0x1a2>
    goto bad;
8010533f:	90                   	nop

bad:
  ilock(ip);
80105340:	83 ec 0c             	sub    $0xc,%esp
80105343:	ff 75 f4             	push   -0xc(%ebp)
80105346:	e8 9f c6 ff ff       	call   801019ea <ilock>
8010534b:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
8010534e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105351:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105355:	83 e8 01             	sub    $0x1,%eax
80105358:	89 c2                	mov    %eax,%edx
8010535a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010535d:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105361:	83 ec 0c             	sub    $0xc,%esp
80105364:	ff 75 f4             	push   -0xc(%ebp)
80105367:	e8 a1 c4 ff ff       	call   8010180d <iupdate>
8010536c:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010536f:	83 ec 0c             	sub    $0xc,%esp
80105372:	ff 75 f4             	push   -0xc(%ebp)
80105375:	e8 a1 c8 ff ff       	call   80101c1b <iunlockput>
8010537a:	83 c4 10             	add    $0x10,%esp
  end_op();
8010537d:	e8 46 dd ff ff       	call   801030c8 <end_op>
  return -1;
80105382:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105387:	c9                   	leave  
80105388:	c3                   	ret    

80105389 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105389:	55                   	push   %ebp
8010538a:	89 e5                	mov    %esp,%ebp
8010538c:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010538f:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105396:	eb 40                	jmp    801053d8 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105398:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010539b:	6a 10                	push   $0x10
8010539d:	50                   	push   %eax
8010539e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801053a1:	50                   	push   %eax
801053a2:	ff 75 08             	push   0x8(%ebp)
801053a5:	e8 2c cb ff ff       	call   80101ed6 <readi>
801053aa:	83 c4 10             	add    $0x10,%esp
801053ad:	83 f8 10             	cmp    $0x10,%eax
801053b0:	74 0d                	je     801053bf <isdirempty+0x36>
      panic("isdirempty: readi");
801053b2:	83 ec 0c             	sub    $0xc,%esp
801053b5:	68 4d a5 10 80       	push   $0x8010a54d
801053ba:	e8 ea b1 ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
801053bf:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801053c3:	66 85 c0             	test   %ax,%ax
801053c6:	74 07                	je     801053cf <isdirempty+0x46>
      return 0;
801053c8:	b8 00 00 00 00       	mov    $0x0,%eax
801053cd:	eb 1b                	jmp    801053ea <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801053cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053d2:	83 c0 10             	add    $0x10,%eax
801053d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801053d8:	8b 45 08             	mov    0x8(%ebp),%eax
801053db:	8b 50 58             	mov    0x58(%eax),%edx
801053de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053e1:	39 c2                	cmp    %eax,%edx
801053e3:	77 b3                	ja     80105398 <isdirempty+0xf>
  }
  return 1;
801053e5:	b8 01 00 00 00       	mov    $0x1,%eax
}
801053ea:	c9                   	leave  
801053eb:	c3                   	ret    

801053ec <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801053ec:	55                   	push   %ebp
801053ed:	89 e5                	mov    %esp,%ebp
801053ef:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801053f2:	83 ec 08             	sub    $0x8,%esp
801053f5:	8d 45 cc             	lea    -0x34(%ebp),%eax
801053f8:	50                   	push   %eax
801053f9:	6a 00                	push   $0x0
801053fb:	e8 a2 fa ff ff       	call   80104ea2 <argstr>
80105400:	83 c4 10             	add    $0x10,%esp
80105403:	85 c0                	test   %eax,%eax
80105405:	79 0a                	jns    80105411 <sys_unlink+0x25>
    return -1;
80105407:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010540c:	e9 bf 01 00 00       	jmp    801055d0 <sys_unlink+0x1e4>

  begin_op();
80105411:	e8 26 dc ff ff       	call   8010303c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105416:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105419:	83 ec 08             	sub    $0x8,%esp
8010541c:	8d 55 d2             	lea    -0x2e(%ebp),%edx
8010541f:	52                   	push   %edx
80105420:	50                   	push   %eax
80105421:	e8 13 d1 ff ff       	call   80102539 <nameiparent>
80105426:	83 c4 10             	add    $0x10,%esp
80105429:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010542c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105430:	75 0f                	jne    80105441 <sys_unlink+0x55>
    end_op();
80105432:	e8 91 dc ff ff       	call   801030c8 <end_op>
    return -1;
80105437:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010543c:	e9 8f 01 00 00       	jmp    801055d0 <sys_unlink+0x1e4>
  }

  ilock(dp);
80105441:	83 ec 0c             	sub    $0xc,%esp
80105444:	ff 75 f4             	push   -0xc(%ebp)
80105447:	e8 9e c5 ff ff       	call   801019ea <ilock>
8010544c:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010544f:	83 ec 08             	sub    $0x8,%esp
80105452:	68 5f a5 10 80       	push   $0x8010a55f
80105457:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010545a:	50                   	push   %eax
8010545b:	e8 51 cd ff ff       	call   801021b1 <namecmp>
80105460:	83 c4 10             	add    $0x10,%esp
80105463:	85 c0                	test   %eax,%eax
80105465:	0f 84 49 01 00 00    	je     801055b4 <sys_unlink+0x1c8>
8010546b:	83 ec 08             	sub    $0x8,%esp
8010546e:	68 61 a5 10 80       	push   $0x8010a561
80105473:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105476:	50                   	push   %eax
80105477:	e8 35 cd ff ff       	call   801021b1 <namecmp>
8010547c:	83 c4 10             	add    $0x10,%esp
8010547f:	85 c0                	test   %eax,%eax
80105481:	0f 84 2d 01 00 00    	je     801055b4 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105487:	83 ec 04             	sub    $0x4,%esp
8010548a:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010548d:	50                   	push   %eax
8010548e:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105491:	50                   	push   %eax
80105492:	ff 75 f4             	push   -0xc(%ebp)
80105495:	e8 32 cd ff ff       	call   801021cc <dirlookup>
8010549a:	83 c4 10             	add    $0x10,%esp
8010549d:	89 45 f0             	mov    %eax,-0x10(%ebp)
801054a0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801054a4:	0f 84 0d 01 00 00    	je     801055b7 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
801054aa:	83 ec 0c             	sub    $0xc,%esp
801054ad:	ff 75 f0             	push   -0x10(%ebp)
801054b0:	e8 35 c5 ff ff       	call   801019ea <ilock>
801054b5:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
801054b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054bb:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801054bf:	66 85 c0             	test   %ax,%ax
801054c2:	7f 0d                	jg     801054d1 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
801054c4:	83 ec 0c             	sub    $0xc,%esp
801054c7:	68 64 a5 10 80       	push   $0x8010a564
801054cc:	e8 d8 b0 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801054d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054d4:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801054d8:	66 83 f8 01          	cmp    $0x1,%ax
801054dc:	75 25                	jne    80105503 <sys_unlink+0x117>
801054de:	83 ec 0c             	sub    $0xc,%esp
801054e1:	ff 75 f0             	push   -0x10(%ebp)
801054e4:	e8 a0 fe ff ff       	call   80105389 <isdirempty>
801054e9:	83 c4 10             	add    $0x10,%esp
801054ec:	85 c0                	test   %eax,%eax
801054ee:	75 13                	jne    80105503 <sys_unlink+0x117>
    iunlockput(ip);
801054f0:	83 ec 0c             	sub    $0xc,%esp
801054f3:	ff 75 f0             	push   -0x10(%ebp)
801054f6:	e8 20 c7 ff ff       	call   80101c1b <iunlockput>
801054fb:	83 c4 10             	add    $0x10,%esp
    goto bad;
801054fe:	e9 b5 00 00 00       	jmp    801055b8 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
80105503:	83 ec 04             	sub    $0x4,%esp
80105506:	6a 10                	push   $0x10
80105508:	6a 00                	push   $0x0
8010550a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010550d:	50                   	push   %eax
8010550e:	e8 cf f5 ff ff       	call   80104ae2 <memset>
80105513:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105516:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105519:	6a 10                	push   $0x10
8010551b:	50                   	push   %eax
8010551c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010551f:	50                   	push   %eax
80105520:	ff 75 f4             	push   -0xc(%ebp)
80105523:	e8 03 cb ff ff       	call   8010202b <writei>
80105528:	83 c4 10             	add    $0x10,%esp
8010552b:	83 f8 10             	cmp    $0x10,%eax
8010552e:	74 0d                	je     8010553d <sys_unlink+0x151>
    panic("unlink: writei");
80105530:	83 ec 0c             	sub    $0xc,%esp
80105533:	68 76 a5 10 80       	push   $0x8010a576
80105538:	e8 6c b0 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
8010553d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105540:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105544:	66 83 f8 01          	cmp    $0x1,%ax
80105548:	75 21                	jne    8010556b <sys_unlink+0x17f>
    dp->nlink--;
8010554a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010554d:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105551:	83 e8 01             	sub    $0x1,%eax
80105554:	89 c2                	mov    %eax,%edx
80105556:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105559:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
8010555d:	83 ec 0c             	sub    $0xc,%esp
80105560:	ff 75 f4             	push   -0xc(%ebp)
80105563:	e8 a5 c2 ff ff       	call   8010180d <iupdate>
80105568:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
8010556b:	83 ec 0c             	sub    $0xc,%esp
8010556e:	ff 75 f4             	push   -0xc(%ebp)
80105571:	e8 a5 c6 ff ff       	call   80101c1b <iunlockput>
80105576:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105579:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010557c:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105580:	83 e8 01             	sub    $0x1,%eax
80105583:	89 c2                	mov    %eax,%edx
80105585:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105588:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010558c:	83 ec 0c             	sub    $0xc,%esp
8010558f:	ff 75 f0             	push   -0x10(%ebp)
80105592:	e8 76 c2 ff ff       	call   8010180d <iupdate>
80105597:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010559a:	83 ec 0c             	sub    $0xc,%esp
8010559d:	ff 75 f0             	push   -0x10(%ebp)
801055a0:	e8 76 c6 ff ff       	call   80101c1b <iunlockput>
801055a5:	83 c4 10             	add    $0x10,%esp

  end_op();
801055a8:	e8 1b db ff ff       	call   801030c8 <end_op>

  return 0;
801055ad:	b8 00 00 00 00       	mov    $0x0,%eax
801055b2:	eb 1c                	jmp    801055d0 <sys_unlink+0x1e4>
    goto bad;
801055b4:	90                   	nop
801055b5:	eb 01                	jmp    801055b8 <sys_unlink+0x1cc>
    goto bad;
801055b7:	90                   	nop

bad:
  iunlockput(dp);
801055b8:	83 ec 0c             	sub    $0xc,%esp
801055bb:	ff 75 f4             	push   -0xc(%ebp)
801055be:	e8 58 c6 ff ff       	call   80101c1b <iunlockput>
801055c3:	83 c4 10             	add    $0x10,%esp
  end_op();
801055c6:	e8 fd da ff ff       	call   801030c8 <end_op>
  return -1;
801055cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801055d0:	c9                   	leave  
801055d1:	c3                   	ret    

801055d2 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801055d2:	55                   	push   %ebp
801055d3:	89 e5                	mov    %esp,%ebp
801055d5:	83 ec 38             	sub    $0x38,%esp
801055d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801055db:	8b 55 10             	mov    0x10(%ebp),%edx
801055de:	8b 45 14             	mov    0x14(%ebp),%eax
801055e1:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801055e5:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801055e9:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801055ed:	83 ec 08             	sub    $0x8,%esp
801055f0:	8d 45 de             	lea    -0x22(%ebp),%eax
801055f3:	50                   	push   %eax
801055f4:	ff 75 08             	push   0x8(%ebp)
801055f7:	e8 3d cf ff ff       	call   80102539 <nameiparent>
801055fc:	83 c4 10             	add    $0x10,%esp
801055ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105602:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105606:	75 0a                	jne    80105612 <create+0x40>
    return 0;
80105608:	b8 00 00 00 00       	mov    $0x0,%eax
8010560d:	e9 90 01 00 00       	jmp    801057a2 <create+0x1d0>
  ilock(dp);
80105612:	83 ec 0c             	sub    $0xc,%esp
80105615:	ff 75 f4             	push   -0xc(%ebp)
80105618:	e8 cd c3 ff ff       	call   801019ea <ilock>
8010561d:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105620:	83 ec 04             	sub    $0x4,%esp
80105623:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105626:	50                   	push   %eax
80105627:	8d 45 de             	lea    -0x22(%ebp),%eax
8010562a:	50                   	push   %eax
8010562b:	ff 75 f4             	push   -0xc(%ebp)
8010562e:	e8 99 cb ff ff       	call   801021cc <dirlookup>
80105633:	83 c4 10             	add    $0x10,%esp
80105636:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105639:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010563d:	74 50                	je     8010568f <create+0xbd>
    iunlockput(dp);
8010563f:	83 ec 0c             	sub    $0xc,%esp
80105642:	ff 75 f4             	push   -0xc(%ebp)
80105645:	e8 d1 c5 ff ff       	call   80101c1b <iunlockput>
8010564a:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
8010564d:	83 ec 0c             	sub    $0xc,%esp
80105650:	ff 75 f0             	push   -0x10(%ebp)
80105653:	e8 92 c3 ff ff       	call   801019ea <ilock>
80105658:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
8010565b:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105660:	75 15                	jne    80105677 <create+0xa5>
80105662:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105665:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105669:	66 83 f8 02          	cmp    $0x2,%ax
8010566d:	75 08                	jne    80105677 <create+0xa5>
      return ip;
8010566f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105672:	e9 2b 01 00 00       	jmp    801057a2 <create+0x1d0>
    iunlockput(ip);
80105677:	83 ec 0c             	sub    $0xc,%esp
8010567a:	ff 75 f0             	push   -0x10(%ebp)
8010567d:	e8 99 c5 ff ff       	call   80101c1b <iunlockput>
80105682:	83 c4 10             	add    $0x10,%esp
    return 0;
80105685:	b8 00 00 00 00       	mov    $0x0,%eax
8010568a:	e9 13 01 00 00       	jmp    801057a2 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
8010568f:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105693:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105696:	8b 00                	mov    (%eax),%eax
80105698:	83 ec 08             	sub    $0x8,%esp
8010569b:	52                   	push   %edx
8010569c:	50                   	push   %eax
8010569d:	e8 94 c0 ff ff       	call   80101736 <ialloc>
801056a2:	83 c4 10             	add    $0x10,%esp
801056a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801056a8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801056ac:	75 0d                	jne    801056bb <create+0xe9>
    panic("create: ialloc");
801056ae:	83 ec 0c             	sub    $0xc,%esp
801056b1:	68 85 a5 10 80       	push   $0x8010a585
801056b6:	e8 ee ae ff ff       	call   801005a9 <panic>

  ilock(ip);
801056bb:	83 ec 0c             	sub    $0xc,%esp
801056be:	ff 75 f0             	push   -0x10(%ebp)
801056c1:	e8 24 c3 ff ff       	call   801019ea <ilock>
801056c6:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801056c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056cc:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801056d0:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
801056d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056d7:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801056db:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
801056df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056e2:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
801056e8:	83 ec 0c             	sub    $0xc,%esp
801056eb:	ff 75 f0             	push   -0x10(%ebp)
801056ee:	e8 1a c1 ff ff       	call   8010180d <iupdate>
801056f3:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801056f6:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801056fb:	75 6a                	jne    80105767 <create+0x195>
    dp->nlink++;  // for ".."
801056fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105700:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105704:	83 c0 01             	add    $0x1,%eax
80105707:	89 c2                	mov    %eax,%edx
80105709:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010570c:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105710:	83 ec 0c             	sub    $0xc,%esp
80105713:	ff 75 f4             	push   -0xc(%ebp)
80105716:	e8 f2 c0 ff ff       	call   8010180d <iupdate>
8010571b:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010571e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105721:	8b 40 04             	mov    0x4(%eax),%eax
80105724:	83 ec 04             	sub    $0x4,%esp
80105727:	50                   	push   %eax
80105728:	68 5f a5 10 80       	push   $0x8010a55f
8010572d:	ff 75 f0             	push   -0x10(%ebp)
80105730:	e8 51 cb ff ff       	call   80102286 <dirlink>
80105735:	83 c4 10             	add    $0x10,%esp
80105738:	85 c0                	test   %eax,%eax
8010573a:	78 1e                	js     8010575a <create+0x188>
8010573c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010573f:	8b 40 04             	mov    0x4(%eax),%eax
80105742:	83 ec 04             	sub    $0x4,%esp
80105745:	50                   	push   %eax
80105746:	68 61 a5 10 80       	push   $0x8010a561
8010574b:	ff 75 f0             	push   -0x10(%ebp)
8010574e:	e8 33 cb ff ff       	call   80102286 <dirlink>
80105753:	83 c4 10             	add    $0x10,%esp
80105756:	85 c0                	test   %eax,%eax
80105758:	79 0d                	jns    80105767 <create+0x195>
      panic("create dots");
8010575a:	83 ec 0c             	sub    $0xc,%esp
8010575d:	68 94 a5 10 80       	push   $0x8010a594
80105762:	e8 42 ae ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105767:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010576a:	8b 40 04             	mov    0x4(%eax),%eax
8010576d:	83 ec 04             	sub    $0x4,%esp
80105770:	50                   	push   %eax
80105771:	8d 45 de             	lea    -0x22(%ebp),%eax
80105774:	50                   	push   %eax
80105775:	ff 75 f4             	push   -0xc(%ebp)
80105778:	e8 09 cb ff ff       	call   80102286 <dirlink>
8010577d:	83 c4 10             	add    $0x10,%esp
80105780:	85 c0                	test   %eax,%eax
80105782:	79 0d                	jns    80105791 <create+0x1bf>
    panic("create: dirlink");
80105784:	83 ec 0c             	sub    $0xc,%esp
80105787:	68 a0 a5 10 80       	push   $0x8010a5a0
8010578c:	e8 18 ae ff ff       	call   801005a9 <panic>

  iunlockput(dp);
80105791:	83 ec 0c             	sub    $0xc,%esp
80105794:	ff 75 f4             	push   -0xc(%ebp)
80105797:	e8 7f c4 ff ff       	call   80101c1b <iunlockput>
8010579c:	83 c4 10             	add    $0x10,%esp

  return ip;
8010579f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801057a2:	c9                   	leave  
801057a3:	c3                   	ret    

801057a4 <sys_open>:

int
sys_open(void)
{
801057a4:	55                   	push   %ebp
801057a5:	89 e5                	mov    %esp,%ebp
801057a7:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801057aa:	83 ec 08             	sub    $0x8,%esp
801057ad:	8d 45 e8             	lea    -0x18(%ebp),%eax
801057b0:	50                   	push   %eax
801057b1:	6a 00                	push   $0x0
801057b3:	e8 ea f6 ff ff       	call   80104ea2 <argstr>
801057b8:	83 c4 10             	add    $0x10,%esp
801057bb:	85 c0                	test   %eax,%eax
801057bd:	78 15                	js     801057d4 <sys_open+0x30>
801057bf:	83 ec 08             	sub    $0x8,%esp
801057c2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801057c5:	50                   	push   %eax
801057c6:	6a 01                	push   $0x1
801057c8:	e8 40 f6 ff ff       	call   80104e0d <argint>
801057cd:	83 c4 10             	add    $0x10,%esp
801057d0:	85 c0                	test   %eax,%eax
801057d2:	79 0a                	jns    801057de <sys_open+0x3a>
    return -1;
801057d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057d9:	e9 61 01 00 00       	jmp    8010593f <sys_open+0x19b>

  begin_op();
801057de:	e8 59 d8 ff ff       	call   8010303c <begin_op>

  if(omode & O_CREATE){
801057e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801057e6:	25 00 02 00 00       	and    $0x200,%eax
801057eb:	85 c0                	test   %eax,%eax
801057ed:	74 2a                	je     80105819 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
801057ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
801057f2:	6a 00                	push   $0x0
801057f4:	6a 00                	push   $0x0
801057f6:	6a 02                	push   $0x2
801057f8:	50                   	push   %eax
801057f9:	e8 d4 fd ff ff       	call   801055d2 <create>
801057fe:	83 c4 10             	add    $0x10,%esp
80105801:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105804:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105808:	75 75                	jne    8010587f <sys_open+0xdb>
      end_op();
8010580a:	e8 b9 d8 ff ff       	call   801030c8 <end_op>
      return -1;
8010580f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105814:	e9 26 01 00 00       	jmp    8010593f <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105819:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010581c:	83 ec 0c             	sub    $0xc,%esp
8010581f:	50                   	push   %eax
80105820:	e8 f8 cc ff ff       	call   8010251d <namei>
80105825:	83 c4 10             	add    $0x10,%esp
80105828:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010582b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010582f:	75 0f                	jne    80105840 <sys_open+0x9c>
      end_op();
80105831:	e8 92 d8 ff ff       	call   801030c8 <end_op>
      return -1;
80105836:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010583b:	e9 ff 00 00 00       	jmp    8010593f <sys_open+0x19b>
    }
    ilock(ip);
80105840:	83 ec 0c             	sub    $0xc,%esp
80105843:	ff 75 f4             	push   -0xc(%ebp)
80105846:	e8 9f c1 ff ff       	call   801019ea <ilock>
8010584b:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
8010584e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105851:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105855:	66 83 f8 01          	cmp    $0x1,%ax
80105859:	75 24                	jne    8010587f <sys_open+0xdb>
8010585b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010585e:	85 c0                	test   %eax,%eax
80105860:	74 1d                	je     8010587f <sys_open+0xdb>
      iunlockput(ip);
80105862:	83 ec 0c             	sub    $0xc,%esp
80105865:	ff 75 f4             	push   -0xc(%ebp)
80105868:	e8 ae c3 ff ff       	call   80101c1b <iunlockput>
8010586d:	83 c4 10             	add    $0x10,%esp
      end_op();
80105870:	e8 53 d8 ff ff       	call   801030c8 <end_op>
      return -1;
80105875:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010587a:	e9 c0 00 00 00       	jmp    8010593f <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010587f:	e8 59 b7 ff ff       	call   80100fdd <filealloc>
80105884:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105887:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010588b:	74 17                	je     801058a4 <sys_open+0x100>
8010588d:	83 ec 0c             	sub    $0xc,%esp
80105890:	ff 75 f0             	push   -0x10(%ebp)
80105893:	e8 33 f7 ff ff       	call   80104fcb <fdalloc>
80105898:	83 c4 10             	add    $0x10,%esp
8010589b:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010589e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801058a2:	79 2e                	jns    801058d2 <sys_open+0x12e>
    if(f)
801058a4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801058a8:	74 0e                	je     801058b8 <sys_open+0x114>
      fileclose(f);
801058aa:	83 ec 0c             	sub    $0xc,%esp
801058ad:	ff 75 f0             	push   -0x10(%ebp)
801058b0:	e8 e6 b7 ff ff       	call   8010109b <fileclose>
801058b5:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801058b8:	83 ec 0c             	sub    $0xc,%esp
801058bb:	ff 75 f4             	push   -0xc(%ebp)
801058be:	e8 58 c3 ff ff       	call   80101c1b <iunlockput>
801058c3:	83 c4 10             	add    $0x10,%esp
    end_op();
801058c6:	e8 fd d7 ff ff       	call   801030c8 <end_op>
    return -1;
801058cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058d0:	eb 6d                	jmp    8010593f <sys_open+0x19b>
  }
  iunlock(ip);
801058d2:	83 ec 0c             	sub    $0xc,%esp
801058d5:	ff 75 f4             	push   -0xc(%ebp)
801058d8:	e8 20 c2 ff ff       	call   80101afd <iunlock>
801058dd:	83 c4 10             	add    $0x10,%esp
  end_op();
801058e0:	e8 e3 d7 ff ff       	call   801030c8 <end_op>

  f->type = FD_INODE;
801058e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058e8:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801058ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058f4:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801058f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058fa:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105901:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105904:	83 e0 01             	and    $0x1,%eax
80105907:	85 c0                	test   %eax,%eax
80105909:	0f 94 c0             	sete   %al
8010590c:	89 c2                	mov    %eax,%edx
8010590e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105911:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105914:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105917:	83 e0 01             	and    $0x1,%eax
8010591a:	85 c0                	test   %eax,%eax
8010591c:	75 0a                	jne    80105928 <sys_open+0x184>
8010591e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105921:	83 e0 02             	and    $0x2,%eax
80105924:	85 c0                	test   %eax,%eax
80105926:	74 07                	je     8010592f <sys_open+0x18b>
80105928:	b8 01 00 00 00       	mov    $0x1,%eax
8010592d:	eb 05                	jmp    80105934 <sys_open+0x190>
8010592f:	b8 00 00 00 00       	mov    $0x0,%eax
80105934:	89 c2                	mov    %eax,%edx
80105936:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105939:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
8010593c:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
8010593f:	c9                   	leave  
80105940:	c3                   	ret    

80105941 <sys_mkdir>:

int
sys_mkdir(void)
{
80105941:	55                   	push   %ebp
80105942:	89 e5                	mov    %esp,%ebp
80105944:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105947:	e8 f0 d6 ff ff       	call   8010303c <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010594c:	83 ec 08             	sub    $0x8,%esp
8010594f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105952:	50                   	push   %eax
80105953:	6a 00                	push   $0x0
80105955:	e8 48 f5 ff ff       	call   80104ea2 <argstr>
8010595a:	83 c4 10             	add    $0x10,%esp
8010595d:	85 c0                	test   %eax,%eax
8010595f:	78 1b                	js     8010597c <sys_mkdir+0x3b>
80105961:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105964:	6a 00                	push   $0x0
80105966:	6a 00                	push   $0x0
80105968:	6a 01                	push   $0x1
8010596a:	50                   	push   %eax
8010596b:	e8 62 fc ff ff       	call   801055d2 <create>
80105970:	83 c4 10             	add    $0x10,%esp
80105973:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105976:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010597a:	75 0c                	jne    80105988 <sys_mkdir+0x47>
    end_op();
8010597c:	e8 47 d7 ff ff       	call   801030c8 <end_op>
    return -1;
80105981:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105986:	eb 18                	jmp    801059a0 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80105988:	83 ec 0c             	sub    $0xc,%esp
8010598b:	ff 75 f4             	push   -0xc(%ebp)
8010598e:	e8 88 c2 ff ff       	call   80101c1b <iunlockput>
80105993:	83 c4 10             	add    $0x10,%esp
  end_op();
80105996:	e8 2d d7 ff ff       	call   801030c8 <end_op>
  return 0;
8010599b:	b8 00 00 00 00       	mov    $0x0,%eax
}
801059a0:	c9                   	leave  
801059a1:	c3                   	ret    

801059a2 <sys_mknod>:

int
sys_mknod(void)
{
801059a2:	55                   	push   %ebp
801059a3:	89 e5                	mov    %esp,%ebp
801059a5:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
801059a8:	e8 8f d6 ff ff       	call   8010303c <begin_op>
  if((argstr(0, &path)) < 0 ||
801059ad:	83 ec 08             	sub    $0x8,%esp
801059b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059b3:	50                   	push   %eax
801059b4:	6a 00                	push   $0x0
801059b6:	e8 e7 f4 ff ff       	call   80104ea2 <argstr>
801059bb:	83 c4 10             	add    $0x10,%esp
801059be:	85 c0                	test   %eax,%eax
801059c0:	78 4f                	js     80105a11 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
801059c2:	83 ec 08             	sub    $0x8,%esp
801059c5:	8d 45 ec             	lea    -0x14(%ebp),%eax
801059c8:	50                   	push   %eax
801059c9:	6a 01                	push   $0x1
801059cb:	e8 3d f4 ff ff       	call   80104e0d <argint>
801059d0:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
801059d3:	85 c0                	test   %eax,%eax
801059d5:	78 3a                	js     80105a11 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
801059d7:	83 ec 08             	sub    $0x8,%esp
801059da:	8d 45 e8             	lea    -0x18(%ebp),%eax
801059dd:	50                   	push   %eax
801059de:	6a 02                	push   $0x2
801059e0:	e8 28 f4 ff ff       	call   80104e0d <argint>
801059e5:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
801059e8:	85 c0                	test   %eax,%eax
801059ea:	78 25                	js     80105a11 <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
801059ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
801059ef:	0f bf c8             	movswl %ax,%ecx
801059f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801059f5:	0f bf d0             	movswl %ax,%edx
801059f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059fb:	51                   	push   %ecx
801059fc:	52                   	push   %edx
801059fd:	6a 03                	push   $0x3
801059ff:	50                   	push   %eax
80105a00:	e8 cd fb ff ff       	call   801055d2 <create>
80105a05:	83 c4 10             	add    $0x10,%esp
80105a08:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105a0b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a0f:	75 0c                	jne    80105a1d <sys_mknod+0x7b>
    end_op();
80105a11:	e8 b2 d6 ff ff       	call   801030c8 <end_op>
    return -1;
80105a16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a1b:	eb 18                	jmp    80105a35 <sys_mknod+0x93>
  }
  iunlockput(ip);
80105a1d:	83 ec 0c             	sub    $0xc,%esp
80105a20:	ff 75 f4             	push   -0xc(%ebp)
80105a23:	e8 f3 c1 ff ff       	call   80101c1b <iunlockput>
80105a28:	83 c4 10             	add    $0x10,%esp
  end_op();
80105a2b:	e8 98 d6 ff ff       	call   801030c8 <end_op>
  return 0;
80105a30:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a35:	c9                   	leave  
80105a36:	c3                   	ret    

80105a37 <sys_chdir>:

int
sys_chdir(void)
{
80105a37:	55                   	push   %ebp
80105a38:	89 e5                	mov    %esp,%ebp
80105a3a:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105a3d:	e8 ee df ff ff       	call   80103a30 <myproc>
80105a42:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105a45:	e8 f2 d5 ff ff       	call   8010303c <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105a4a:	83 ec 08             	sub    $0x8,%esp
80105a4d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105a50:	50                   	push   %eax
80105a51:	6a 00                	push   $0x0
80105a53:	e8 4a f4 ff ff       	call   80104ea2 <argstr>
80105a58:	83 c4 10             	add    $0x10,%esp
80105a5b:	85 c0                	test   %eax,%eax
80105a5d:	78 18                	js     80105a77 <sys_chdir+0x40>
80105a5f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105a62:	83 ec 0c             	sub    $0xc,%esp
80105a65:	50                   	push   %eax
80105a66:	e8 b2 ca ff ff       	call   8010251d <namei>
80105a6b:	83 c4 10             	add    $0x10,%esp
80105a6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a71:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a75:	75 0c                	jne    80105a83 <sys_chdir+0x4c>
    end_op();
80105a77:	e8 4c d6 ff ff       	call   801030c8 <end_op>
    return -1;
80105a7c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a81:	eb 68                	jmp    80105aeb <sys_chdir+0xb4>
  }
  ilock(ip);
80105a83:	83 ec 0c             	sub    $0xc,%esp
80105a86:	ff 75 f0             	push   -0x10(%ebp)
80105a89:	e8 5c bf ff ff       	call   801019ea <ilock>
80105a8e:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105a91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a94:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105a98:	66 83 f8 01          	cmp    $0x1,%ax
80105a9c:	74 1a                	je     80105ab8 <sys_chdir+0x81>
    iunlockput(ip);
80105a9e:	83 ec 0c             	sub    $0xc,%esp
80105aa1:	ff 75 f0             	push   -0x10(%ebp)
80105aa4:	e8 72 c1 ff ff       	call   80101c1b <iunlockput>
80105aa9:	83 c4 10             	add    $0x10,%esp
    end_op();
80105aac:	e8 17 d6 ff ff       	call   801030c8 <end_op>
    return -1;
80105ab1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ab6:	eb 33                	jmp    80105aeb <sys_chdir+0xb4>
  }
  iunlock(ip);
80105ab8:	83 ec 0c             	sub    $0xc,%esp
80105abb:	ff 75 f0             	push   -0x10(%ebp)
80105abe:	e8 3a c0 ff ff       	call   80101afd <iunlock>
80105ac3:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ac9:	8b 40 68             	mov    0x68(%eax),%eax
80105acc:	83 ec 0c             	sub    $0xc,%esp
80105acf:	50                   	push   %eax
80105ad0:	e8 76 c0 ff ff       	call   80101b4b <iput>
80105ad5:	83 c4 10             	add    $0x10,%esp
  end_op();
80105ad8:	e8 eb d5 ff ff       	call   801030c8 <end_op>
  curproc->cwd = ip;
80105add:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ae0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ae3:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105ae6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105aeb:	c9                   	leave  
80105aec:	c3                   	ret    

80105aed <sys_exec>:

int
sys_exec(void)
{
80105aed:	55                   	push   %ebp
80105aee:	89 e5                	mov    %esp,%ebp
80105af0:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105af6:	83 ec 08             	sub    $0x8,%esp
80105af9:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105afc:	50                   	push   %eax
80105afd:	6a 00                	push   $0x0
80105aff:	e8 9e f3 ff ff       	call   80104ea2 <argstr>
80105b04:	83 c4 10             	add    $0x10,%esp
80105b07:	85 c0                	test   %eax,%eax
80105b09:	78 18                	js     80105b23 <sys_exec+0x36>
80105b0b:	83 ec 08             	sub    $0x8,%esp
80105b0e:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105b14:	50                   	push   %eax
80105b15:	6a 01                	push   $0x1
80105b17:	e8 f1 f2 ff ff       	call   80104e0d <argint>
80105b1c:	83 c4 10             	add    $0x10,%esp
80105b1f:	85 c0                	test   %eax,%eax
80105b21:	79 0a                	jns    80105b2d <sys_exec+0x40>
    return -1;
80105b23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b28:	e9 c6 00 00 00       	jmp    80105bf3 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80105b2d:	83 ec 04             	sub    $0x4,%esp
80105b30:	68 80 00 00 00       	push   $0x80
80105b35:	6a 00                	push   $0x0
80105b37:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105b3d:	50                   	push   %eax
80105b3e:	e8 9f ef ff ff       	call   80104ae2 <memset>
80105b43:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105b46:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b50:	83 f8 1f             	cmp    $0x1f,%eax
80105b53:	76 0a                	jbe    80105b5f <sys_exec+0x72>
      return -1;
80105b55:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b5a:	e9 94 00 00 00       	jmp    80105bf3 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b62:	c1 e0 02             	shl    $0x2,%eax
80105b65:	89 c2                	mov    %eax,%edx
80105b67:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105b6d:	01 c2                	add    %eax,%edx
80105b6f:	83 ec 08             	sub    $0x8,%esp
80105b72:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105b78:	50                   	push   %eax
80105b79:	52                   	push   %edx
80105b7a:	e8 ed f1 ff ff       	call   80104d6c <fetchint>
80105b7f:	83 c4 10             	add    $0x10,%esp
80105b82:	85 c0                	test   %eax,%eax
80105b84:	79 07                	jns    80105b8d <sys_exec+0xa0>
      return -1;
80105b86:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b8b:	eb 66                	jmp    80105bf3 <sys_exec+0x106>
    if(uarg == 0){
80105b8d:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105b93:	85 c0                	test   %eax,%eax
80105b95:	75 27                	jne    80105bbe <sys_exec+0xd1>
      argv[i] = 0;
80105b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b9a:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105ba1:	00 00 00 00 
      break;
80105ba5:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105ba6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ba9:	83 ec 08             	sub    $0x8,%esp
80105bac:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105bb2:	52                   	push   %edx
80105bb3:	50                   	push   %eax
80105bb4:	e8 c7 af ff ff       	call   80100b80 <exec>
80105bb9:	83 c4 10             	add    $0x10,%esp
80105bbc:	eb 35                	jmp    80105bf3 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105bbe:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bc7:	c1 e0 02             	shl    $0x2,%eax
80105bca:	01 c2                	add    %eax,%edx
80105bcc:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105bd2:	83 ec 08             	sub    $0x8,%esp
80105bd5:	52                   	push   %edx
80105bd6:	50                   	push   %eax
80105bd7:	e8 cf f1 ff ff       	call   80104dab <fetchstr>
80105bdc:	83 c4 10             	add    $0x10,%esp
80105bdf:	85 c0                	test   %eax,%eax
80105be1:	79 07                	jns    80105bea <sys_exec+0xfd>
      return -1;
80105be3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105be8:	eb 09                	jmp    80105bf3 <sys_exec+0x106>
  for(i=0;; i++){
80105bea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105bee:	e9 5a ff ff ff       	jmp    80105b4d <sys_exec+0x60>
}
80105bf3:	c9                   	leave  
80105bf4:	c3                   	ret    

80105bf5 <sys_pipe>:

int
sys_pipe(void)
{
80105bf5:	55                   	push   %ebp
80105bf6:	89 e5                	mov    %esp,%ebp
80105bf8:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105bfb:	83 ec 04             	sub    $0x4,%esp
80105bfe:	6a 08                	push   $0x8
80105c00:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c03:	50                   	push   %eax
80105c04:	6a 00                	push   $0x0
80105c06:	e8 2f f2 ff ff       	call   80104e3a <argptr>
80105c0b:	83 c4 10             	add    $0x10,%esp
80105c0e:	85 c0                	test   %eax,%eax
80105c10:	79 0a                	jns    80105c1c <sys_pipe+0x27>
    return -1;
80105c12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c17:	e9 ae 00 00 00       	jmp    80105cca <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105c1c:	83 ec 08             	sub    $0x8,%esp
80105c1f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105c22:	50                   	push   %eax
80105c23:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105c26:	50                   	push   %eax
80105c27:	e8 41 d9 ff ff       	call   8010356d <pipealloc>
80105c2c:	83 c4 10             	add    $0x10,%esp
80105c2f:	85 c0                	test   %eax,%eax
80105c31:	79 0a                	jns    80105c3d <sys_pipe+0x48>
    return -1;
80105c33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c38:	e9 8d 00 00 00       	jmp    80105cca <sys_pipe+0xd5>
  fd0 = -1;
80105c3d:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105c44:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105c47:	83 ec 0c             	sub    $0xc,%esp
80105c4a:	50                   	push   %eax
80105c4b:	e8 7b f3 ff ff       	call   80104fcb <fdalloc>
80105c50:	83 c4 10             	add    $0x10,%esp
80105c53:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c56:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c5a:	78 18                	js     80105c74 <sys_pipe+0x7f>
80105c5c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c5f:	83 ec 0c             	sub    $0xc,%esp
80105c62:	50                   	push   %eax
80105c63:	e8 63 f3 ff ff       	call   80104fcb <fdalloc>
80105c68:	83 c4 10             	add    $0x10,%esp
80105c6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c6e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c72:	79 3e                	jns    80105cb2 <sys_pipe+0xbd>
    if(fd0 >= 0)
80105c74:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c78:	78 13                	js     80105c8d <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105c7a:	e8 b1 dd ff ff       	call   80103a30 <myproc>
80105c7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c82:	83 c2 08             	add    $0x8,%edx
80105c85:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105c8c:	00 
    fileclose(rf);
80105c8d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105c90:	83 ec 0c             	sub    $0xc,%esp
80105c93:	50                   	push   %eax
80105c94:	e8 02 b4 ff ff       	call   8010109b <fileclose>
80105c99:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105c9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c9f:	83 ec 0c             	sub    $0xc,%esp
80105ca2:	50                   	push   %eax
80105ca3:	e8 f3 b3 ff ff       	call   8010109b <fileclose>
80105ca8:	83 c4 10             	add    $0x10,%esp
    return -1;
80105cab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cb0:	eb 18                	jmp    80105cca <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80105cb2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105cb5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105cb8:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105cba:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105cbd:	8d 50 04             	lea    0x4(%eax),%edx
80105cc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cc3:	89 02                	mov    %eax,(%edx)
  return 0;
80105cc5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cca:	c9                   	leave  
80105ccb:	c3                   	ret    

80105ccc <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80105ccc:	55                   	push   %ebp
80105ccd:	89 e5                	mov    %esp,%ebp
80105ccf:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105cd2:	e8 58 e0 ff ff       	call   80103d2f <fork>
}
80105cd7:	c9                   	leave  
80105cd8:	c3                   	ret    

80105cd9 <sys_exit>:

int
sys_exit(void)
{
80105cd9:	55                   	push   %ebp
80105cda:	89 e5                	mov    %esp,%ebp
80105cdc:	83 ec 08             	sub    $0x8,%esp
  exit();
80105cdf:	e8 c4 e1 ff ff       	call   80103ea8 <exit>
  return 0;  // not reached
80105ce4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ce9:	c9                   	leave  
80105cea:	c3                   	ret    

80105ceb <sys_wait>:

int
sys_wait(void)
{
80105ceb:	55                   	push   %ebp
80105cec:	89 e5                	mov    %esp,%ebp
80105cee:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105cf1:	e8 d2 e2 ff ff       	call   80103fc8 <wait>
}
80105cf6:	c9                   	leave  
80105cf7:	c3                   	ret    

80105cf8 <sys_kill>:

int
sys_kill(void)
{
80105cf8:	55                   	push   %ebp
80105cf9:	89 e5                	mov    %esp,%ebp
80105cfb:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105cfe:	83 ec 08             	sub    $0x8,%esp
80105d01:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105d04:	50                   	push   %eax
80105d05:	6a 00                	push   $0x0
80105d07:	e8 01 f1 ff ff       	call   80104e0d <argint>
80105d0c:	83 c4 10             	add    $0x10,%esp
80105d0f:	85 c0                	test   %eax,%eax
80105d11:	79 07                	jns    80105d1a <sys_kill+0x22>
    return -1;
80105d13:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d18:	eb 0f                	jmp    80105d29 <sys_kill+0x31>
  return kill(pid);
80105d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d1d:	83 ec 0c             	sub    $0xc,%esp
80105d20:	50                   	push   %eax
80105d21:	e8 d1 e6 ff ff       	call   801043f7 <kill>
80105d26:	83 c4 10             	add    $0x10,%esp
}
80105d29:	c9                   	leave  
80105d2a:	c3                   	ret    

80105d2b <sys_getpid>:

int
sys_getpid(void)
{
80105d2b:	55                   	push   %ebp
80105d2c:	89 e5                	mov    %esp,%ebp
80105d2e:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105d31:	e8 fa dc ff ff       	call   80103a30 <myproc>
80105d36:	8b 40 10             	mov    0x10(%eax),%eax
}
80105d39:	c9                   	leave  
80105d3a:	c3                   	ret    

80105d3b <sys_sbrk>:

int
sys_sbrk(void)
{
80105d3b:	55                   	push   %ebp
80105d3c:	89 e5                	mov    %esp,%ebp
80105d3e:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105d41:	83 ec 08             	sub    $0x8,%esp
80105d44:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d47:	50                   	push   %eax
80105d48:	6a 00                	push   $0x0
80105d4a:	e8 be f0 ff ff       	call   80104e0d <argint>
80105d4f:	83 c4 10             	add    $0x10,%esp
80105d52:	85 c0                	test   %eax,%eax
80105d54:	79 07                	jns    80105d5d <sys_sbrk+0x22>
    return -1;
80105d56:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d5b:	eb 27                	jmp    80105d84 <sys_sbrk+0x49>
  addr = myproc()->sz;
80105d5d:	e8 ce dc ff ff       	call   80103a30 <myproc>
80105d62:	8b 00                	mov    (%eax),%eax
80105d64:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80105d67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d6a:	83 ec 0c             	sub    $0xc,%esp
80105d6d:	50                   	push   %eax
80105d6e:	e8 21 df ff ff       	call   80103c94 <growproc>
80105d73:	83 c4 10             	add    $0x10,%esp
80105d76:	85 c0                	test   %eax,%eax
80105d78:	79 07                	jns    80105d81 <sys_sbrk+0x46>
    return -1;
80105d7a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d7f:	eb 03                	jmp    80105d84 <sys_sbrk+0x49>
  return addr;
80105d81:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105d84:	c9                   	leave  
80105d85:	c3                   	ret    

80105d86 <sys_sleep>:

int
sys_sleep(void)
{
80105d86:	55                   	push   %ebp
80105d87:	89 e5                	mov    %esp,%ebp
80105d89:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105d8c:	83 ec 08             	sub    $0x8,%esp
80105d8f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d92:	50                   	push   %eax
80105d93:	6a 00                	push   $0x0
80105d95:	e8 73 f0 ff ff       	call   80104e0d <argint>
80105d9a:	83 c4 10             	add    $0x10,%esp
80105d9d:	85 c0                	test   %eax,%eax
80105d9f:	79 07                	jns    80105da8 <sys_sleep+0x22>
    return -1;
80105da1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105da6:	eb 76                	jmp    80105e1e <sys_sleep+0x98>
  acquire(&tickslock);
80105da8:	83 ec 0c             	sub    $0xc,%esp
80105dab:	68 40 69 19 80       	push   $0x80196940
80105db0:	e8 b7 ea ff ff       	call   8010486c <acquire>
80105db5:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80105db8:	a1 74 69 19 80       	mov    0x80196974,%eax
80105dbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80105dc0:	eb 38                	jmp    80105dfa <sys_sleep+0x74>
    if(myproc()->killed){
80105dc2:	e8 69 dc ff ff       	call   80103a30 <myproc>
80105dc7:	8b 40 24             	mov    0x24(%eax),%eax
80105dca:	85 c0                	test   %eax,%eax
80105dcc:	74 17                	je     80105de5 <sys_sleep+0x5f>
      release(&tickslock);
80105dce:	83 ec 0c             	sub    $0xc,%esp
80105dd1:	68 40 69 19 80       	push   $0x80196940
80105dd6:	e8 ff ea ff ff       	call   801048da <release>
80105ddb:	83 c4 10             	add    $0x10,%esp
      return -1;
80105dde:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105de3:	eb 39                	jmp    80105e1e <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80105de5:	83 ec 08             	sub    $0x8,%esp
80105de8:	68 40 69 19 80       	push   $0x80196940
80105ded:	68 74 69 19 80       	push   $0x80196974
80105df2:	e8 e2 e4 ff ff       	call   801042d9 <sleep>
80105df7:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80105dfa:	a1 74 69 19 80       	mov    0x80196974,%eax
80105dff:	2b 45 f4             	sub    -0xc(%ebp),%eax
80105e02:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105e05:	39 d0                	cmp    %edx,%eax
80105e07:	72 b9                	jb     80105dc2 <sys_sleep+0x3c>
  }
  release(&tickslock);
80105e09:	83 ec 0c             	sub    $0xc,%esp
80105e0c:	68 40 69 19 80       	push   $0x80196940
80105e11:	e8 c4 ea ff ff       	call   801048da <release>
80105e16:	83 c4 10             	add    $0x10,%esp
  return 0;
80105e19:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e1e:	c9                   	leave  
80105e1f:	c3                   	ret    

80105e20 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105e20:	55                   	push   %ebp
80105e21:	89 e5                	mov    %esp,%ebp
80105e23:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80105e26:	83 ec 0c             	sub    $0xc,%esp
80105e29:	68 40 69 19 80       	push   $0x80196940
80105e2e:	e8 39 ea ff ff       	call   8010486c <acquire>
80105e33:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80105e36:	a1 74 69 19 80       	mov    0x80196974,%eax
80105e3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80105e3e:	83 ec 0c             	sub    $0xc,%esp
80105e41:	68 40 69 19 80       	push   $0x80196940
80105e46:	e8 8f ea ff ff       	call   801048da <release>
80105e4b:	83 c4 10             	add    $0x10,%esp
  return xticks;
80105e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105e51:	c9                   	leave  
80105e52:	c3                   	ret    

80105e53 <sys_printpt>:

int sys_printpt(int pid)
{
80105e53:	55                   	push   %ebp
80105e54:	89 e5                	mov    %esp,%ebp
80105e56:	83 ec 18             	sub    $0x18,%esp
  int n;
  if (argint(0, &n) < 0)
80105e59:	83 ec 08             	sub    $0x8,%esp
80105e5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105e5f:	50                   	push   %eax
80105e60:	6a 00                	push   $0x0
80105e62:	e8 a6 ef ff ff       	call   80104e0d <argint>
80105e67:	83 c4 10             	add    $0x10,%esp
80105e6a:	85 c0                	test   %eax,%eax
80105e6c:	79 07                	jns    80105e75 <sys_printpt+0x22>
    return -1;
80105e6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e73:	eb 14                	jmp    80105e89 <sys_printpt+0x36>
  printpt(n);
80105e75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e78:	83 ec 0c             	sub    $0xc,%esp
80105e7b:	50                   	push   %eax
80105e7c:	e8 f4 e6 ff ff       	call   80104575 <printpt>
80105e81:	83 c4 10             	add    $0x10,%esp
  return 0;
80105e84:	b8 00 00 00 00       	mov    $0x0,%eax
80105e89:	c9                   	leave  
80105e8a:	c3                   	ret    

80105e8b <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80105e8b:	1e                   	push   %ds
  pushl %es
80105e8c:	06                   	push   %es
  pushl %fs
80105e8d:	0f a0                	push   %fs
  pushl %gs
80105e8f:	0f a8                	push   %gs
  pushal
80105e91:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80105e92:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80105e96:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80105e98:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80105e9a:	54                   	push   %esp
  call trap
80105e9b:	e8 d7 01 00 00       	call   80106077 <trap>
  addl $4, %esp
80105ea0:	83 c4 04             	add    $0x4,%esp

80105ea3 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80105ea3:	61                   	popa   
  popl %gs
80105ea4:	0f a9                	pop    %gs
  popl %fs
80105ea6:	0f a1                	pop    %fs
  popl %es
80105ea8:	07                   	pop    %es
  popl %ds
80105ea9:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80105eaa:	83 c4 08             	add    $0x8,%esp
  iret
80105ead:	cf                   	iret   

80105eae <lidt>:
{
80105eae:	55                   	push   %ebp
80105eaf:	89 e5                	mov    %esp,%ebp
80105eb1:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80105eb4:	8b 45 0c             	mov    0xc(%ebp),%eax
80105eb7:	83 e8 01             	sub    $0x1,%eax
80105eba:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80105ebe:	8b 45 08             	mov    0x8(%ebp),%eax
80105ec1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105ec5:	8b 45 08             	mov    0x8(%ebp),%eax
80105ec8:	c1 e8 10             	shr    $0x10,%eax
80105ecb:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105ecf:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105ed2:	0f 01 18             	lidtl  (%eax)
}
80105ed5:	90                   	nop
80105ed6:	c9                   	leave  
80105ed7:	c3                   	ret    

80105ed8 <rcr2>:

static inline uint
rcr2(void)
{
80105ed8:	55                   	push   %ebp
80105ed9:	89 e5                	mov    %esp,%ebp
80105edb:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105ede:	0f 20 d0             	mov    %cr2,%eax
80105ee1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80105ee4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105ee7:	c9                   	leave  
80105ee8:	c3                   	ret    

80105ee9 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80105ee9:	55                   	push   %ebp
80105eea:	89 e5                	mov    %esp,%ebp
80105eec:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80105eef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105ef6:	e9 c3 00 00 00       	jmp    80105fbe <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80105efb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105efe:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
80105f05:	89 c2                	mov    %eax,%edx
80105f07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f0a:	66 89 14 c5 40 61 19 	mov    %dx,-0x7fe69ec0(,%eax,8)
80105f11:	80 
80105f12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f15:	66 c7 04 c5 42 61 19 	movw   $0x8,-0x7fe69ebe(,%eax,8)
80105f1c:	80 08 00 
80105f1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f22:	0f b6 14 c5 44 61 19 	movzbl -0x7fe69ebc(,%eax,8),%edx
80105f29:	80 
80105f2a:	83 e2 e0             	and    $0xffffffe0,%edx
80105f2d:	88 14 c5 44 61 19 80 	mov    %dl,-0x7fe69ebc(,%eax,8)
80105f34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f37:	0f b6 14 c5 44 61 19 	movzbl -0x7fe69ebc(,%eax,8),%edx
80105f3e:	80 
80105f3f:	83 e2 1f             	and    $0x1f,%edx
80105f42:	88 14 c5 44 61 19 80 	mov    %dl,-0x7fe69ebc(,%eax,8)
80105f49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f4c:	0f b6 14 c5 45 61 19 	movzbl -0x7fe69ebb(,%eax,8),%edx
80105f53:	80 
80105f54:	83 e2 f0             	and    $0xfffffff0,%edx
80105f57:	83 ca 0e             	or     $0xe,%edx
80105f5a:	88 14 c5 45 61 19 80 	mov    %dl,-0x7fe69ebb(,%eax,8)
80105f61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f64:	0f b6 14 c5 45 61 19 	movzbl -0x7fe69ebb(,%eax,8),%edx
80105f6b:	80 
80105f6c:	83 e2 ef             	and    $0xffffffef,%edx
80105f6f:	88 14 c5 45 61 19 80 	mov    %dl,-0x7fe69ebb(,%eax,8)
80105f76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f79:	0f b6 14 c5 45 61 19 	movzbl -0x7fe69ebb(,%eax,8),%edx
80105f80:	80 
80105f81:	83 e2 9f             	and    $0xffffff9f,%edx
80105f84:	88 14 c5 45 61 19 80 	mov    %dl,-0x7fe69ebb(,%eax,8)
80105f8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f8e:	0f b6 14 c5 45 61 19 	movzbl -0x7fe69ebb(,%eax,8),%edx
80105f95:	80 
80105f96:	83 ca 80             	or     $0xffffff80,%edx
80105f99:	88 14 c5 45 61 19 80 	mov    %dl,-0x7fe69ebb(,%eax,8)
80105fa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fa3:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
80105faa:	c1 e8 10             	shr    $0x10,%eax
80105fad:	89 c2                	mov    %eax,%edx
80105faf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fb2:	66 89 14 c5 46 61 19 	mov    %dx,-0x7fe69eba(,%eax,8)
80105fb9:	80 
  for(i = 0; i < 256; i++)
80105fba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105fbe:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80105fc5:	0f 8e 30 ff ff ff    	jle    80105efb <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105fcb:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
80105fd0:	66 a3 40 63 19 80    	mov    %ax,0x80196340
80105fd6:	66 c7 05 42 63 19 80 	movw   $0x8,0x80196342
80105fdd:	08 00 
80105fdf:	0f b6 05 44 63 19 80 	movzbl 0x80196344,%eax
80105fe6:	83 e0 e0             	and    $0xffffffe0,%eax
80105fe9:	a2 44 63 19 80       	mov    %al,0x80196344
80105fee:	0f b6 05 44 63 19 80 	movzbl 0x80196344,%eax
80105ff5:	83 e0 1f             	and    $0x1f,%eax
80105ff8:	a2 44 63 19 80       	mov    %al,0x80196344
80105ffd:	0f b6 05 45 63 19 80 	movzbl 0x80196345,%eax
80106004:	83 c8 0f             	or     $0xf,%eax
80106007:	a2 45 63 19 80       	mov    %al,0x80196345
8010600c:	0f b6 05 45 63 19 80 	movzbl 0x80196345,%eax
80106013:	83 e0 ef             	and    $0xffffffef,%eax
80106016:	a2 45 63 19 80       	mov    %al,0x80196345
8010601b:	0f b6 05 45 63 19 80 	movzbl 0x80196345,%eax
80106022:	83 c8 60             	or     $0x60,%eax
80106025:	a2 45 63 19 80       	mov    %al,0x80196345
8010602a:	0f b6 05 45 63 19 80 	movzbl 0x80196345,%eax
80106031:	83 c8 80             	or     $0xffffff80,%eax
80106034:	a2 45 63 19 80       	mov    %al,0x80196345
80106039:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
8010603e:	c1 e8 10             	shr    $0x10,%eax
80106041:	66 a3 46 63 19 80    	mov    %ax,0x80196346

  initlock(&tickslock, "time");
80106047:	83 ec 08             	sub    $0x8,%esp
8010604a:	68 b0 a5 10 80       	push   $0x8010a5b0
8010604f:	68 40 69 19 80       	push   $0x80196940
80106054:	e8 f1 e7 ff ff       	call   8010484a <initlock>
80106059:	83 c4 10             	add    $0x10,%esp
}
8010605c:	90                   	nop
8010605d:	c9                   	leave  
8010605e:	c3                   	ret    

8010605f <idtinit>:

void
idtinit(void)
{
8010605f:	55                   	push   %ebp
80106060:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106062:	68 00 08 00 00       	push   $0x800
80106067:	68 40 61 19 80       	push   $0x80196140
8010606c:	e8 3d fe ff ff       	call   80105eae <lidt>
80106071:	83 c4 08             	add    $0x8,%esp
}
80106074:	90                   	nop
80106075:	c9                   	leave  
80106076:	c3                   	ret    

80106077 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106077:	55                   	push   %ebp
80106078:	89 e5                	mov    %esp,%ebp
8010607a:	57                   	push   %edi
8010607b:	56                   	push   %esi
8010607c:	53                   	push   %ebx
8010607d:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80106080:	8b 45 08             	mov    0x8(%ebp),%eax
80106083:	8b 40 30             	mov    0x30(%eax),%eax
80106086:	83 f8 40             	cmp    $0x40,%eax
80106089:	75 3b                	jne    801060c6 <trap+0x4f>
    if(myproc()->killed)
8010608b:	e8 a0 d9 ff ff       	call   80103a30 <myproc>
80106090:	8b 40 24             	mov    0x24(%eax),%eax
80106093:	85 c0                	test   %eax,%eax
80106095:	74 05                	je     8010609c <trap+0x25>
      exit();
80106097:	e8 0c de ff ff       	call   80103ea8 <exit>
    myproc()->tf = tf;
8010609c:	e8 8f d9 ff ff       	call   80103a30 <myproc>
801060a1:	8b 55 08             	mov    0x8(%ebp),%edx
801060a4:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801060a7:	e8 2d ee ff ff       	call   80104ed9 <syscall>
    if(myproc()->killed)
801060ac:	e8 7f d9 ff ff       	call   80103a30 <myproc>
801060b1:	8b 40 24             	mov    0x24(%eax),%eax
801060b4:	85 c0                	test   %eax,%eax
801060b6:	0f 84 15 02 00 00    	je     801062d1 <trap+0x25a>
      exit();
801060bc:	e8 e7 dd ff ff       	call   80103ea8 <exit>
    return;
801060c1:	e9 0b 02 00 00       	jmp    801062d1 <trap+0x25a>
  }

  switch(tf->trapno){
801060c6:	8b 45 08             	mov    0x8(%ebp),%eax
801060c9:	8b 40 30             	mov    0x30(%eax),%eax
801060cc:	83 e8 20             	sub    $0x20,%eax
801060cf:	83 f8 1f             	cmp    $0x1f,%eax
801060d2:	0f 87 c4 00 00 00    	ja     8010619c <trap+0x125>
801060d8:	8b 04 85 58 a6 10 80 	mov    -0x7fef59a8(,%eax,4),%eax
801060df:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801060e1:	e8 b7 d8 ff ff       	call   8010399d <cpuid>
801060e6:	85 c0                	test   %eax,%eax
801060e8:	75 3d                	jne    80106127 <trap+0xb0>
      acquire(&tickslock);
801060ea:	83 ec 0c             	sub    $0xc,%esp
801060ed:	68 40 69 19 80       	push   $0x80196940
801060f2:	e8 75 e7 ff ff       	call   8010486c <acquire>
801060f7:	83 c4 10             	add    $0x10,%esp
      ticks++;
801060fa:	a1 74 69 19 80       	mov    0x80196974,%eax
801060ff:	83 c0 01             	add    $0x1,%eax
80106102:	a3 74 69 19 80       	mov    %eax,0x80196974
      wakeup(&ticks);
80106107:	83 ec 0c             	sub    $0xc,%esp
8010610a:	68 74 69 19 80       	push   $0x80196974
8010610f:	e8 ac e2 ff ff       	call   801043c0 <wakeup>
80106114:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106117:	83 ec 0c             	sub    $0xc,%esp
8010611a:	68 40 69 19 80       	push   $0x80196940
8010611f:	e8 b6 e7 ff ff       	call   801048da <release>
80106124:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106127:	e8 f0 c9 ff ff       	call   80102b1c <lapiceoi>
    break;
8010612c:	e9 20 01 00 00       	jmp    80106251 <trap+0x1da>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106131:	e8 f5 3e 00 00       	call   8010a02b <ideintr>
    lapiceoi();
80106136:	e8 e1 c9 ff ff       	call   80102b1c <lapiceoi>
    break;
8010613b:	e9 11 01 00 00       	jmp    80106251 <trap+0x1da>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106140:	e8 1c c8 ff ff       	call   80102961 <kbdintr>
    lapiceoi();
80106145:	e8 d2 c9 ff ff       	call   80102b1c <lapiceoi>
    break;
8010614a:	e9 02 01 00 00       	jmp    80106251 <trap+0x1da>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010614f:	e8 53 03 00 00       	call   801064a7 <uartintr>
    lapiceoi();
80106154:	e8 c3 c9 ff ff       	call   80102b1c <lapiceoi>
    break;
80106159:	e9 f3 00 00 00       	jmp    80106251 <trap+0x1da>
  case T_IRQ0 + 0xB:
    i8254_intr();
8010615e:	e8 7b 2b 00 00       	call   80108cde <i8254_intr>
    lapiceoi();
80106163:	e8 b4 c9 ff ff       	call   80102b1c <lapiceoi>
    break;
80106168:	e9 e4 00 00 00       	jmp    80106251 <trap+0x1da>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010616d:	8b 45 08             	mov    0x8(%ebp),%eax
80106170:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106173:	8b 45 08             	mov    0x8(%ebp),%eax
80106176:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010617a:	0f b7 d8             	movzwl %ax,%ebx
8010617d:	e8 1b d8 ff ff       	call   8010399d <cpuid>
80106182:	56                   	push   %esi
80106183:	53                   	push   %ebx
80106184:	50                   	push   %eax
80106185:	68 b8 a5 10 80       	push   $0x8010a5b8
8010618a:	e8 65 a2 ff ff       	call   801003f4 <cprintf>
8010618f:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106192:	e8 85 c9 ff ff       	call   80102b1c <lapiceoi>
    break;
80106197:	e9 b5 00 00 00       	jmp    80106251 <trap+0x1da>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
8010619c:	e8 8f d8 ff ff       	call   80103a30 <myproc>
801061a1:	85 c0                	test   %eax,%eax
801061a3:	74 11                	je     801061b6 <trap+0x13f>
801061a5:	8b 45 08             	mov    0x8(%ebp),%eax
801061a8:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801061ac:	0f b7 c0             	movzwl %ax,%eax
801061af:	83 e0 03             	and    $0x3,%eax
801061b2:	85 c0                	test   %eax,%eax
801061b4:	75 39                	jne    801061ef <trap+0x178>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801061b6:	e8 1d fd ff ff       	call   80105ed8 <rcr2>
801061bb:	89 c3                	mov    %eax,%ebx
801061bd:	8b 45 08             	mov    0x8(%ebp),%eax
801061c0:	8b 70 38             	mov    0x38(%eax),%esi
801061c3:	e8 d5 d7 ff ff       	call   8010399d <cpuid>
801061c8:	8b 55 08             	mov    0x8(%ebp),%edx
801061cb:	8b 52 30             	mov    0x30(%edx),%edx
801061ce:	83 ec 0c             	sub    $0xc,%esp
801061d1:	53                   	push   %ebx
801061d2:	56                   	push   %esi
801061d3:	50                   	push   %eax
801061d4:	52                   	push   %edx
801061d5:	68 dc a5 10 80       	push   $0x8010a5dc
801061da:	e8 15 a2 ff ff       	call   801003f4 <cprintf>
801061df:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
801061e2:	83 ec 0c             	sub    $0xc,%esp
801061e5:	68 0e a6 10 80       	push   $0x8010a60e
801061ea:	e8 ba a3 ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801061ef:	e8 e4 fc ff ff       	call   80105ed8 <rcr2>
801061f4:	89 c6                	mov    %eax,%esi
801061f6:	8b 45 08             	mov    0x8(%ebp),%eax
801061f9:	8b 40 38             	mov    0x38(%eax),%eax
801061fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801061ff:	e8 99 d7 ff ff       	call   8010399d <cpuid>
80106204:	89 c3                	mov    %eax,%ebx
80106206:	8b 45 08             	mov    0x8(%ebp),%eax
80106209:	8b 48 34             	mov    0x34(%eax),%ecx
8010620c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
8010620f:	8b 45 08             	mov    0x8(%ebp),%eax
80106212:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106215:	e8 16 d8 ff ff       	call   80103a30 <myproc>
8010621a:	8d 50 6c             	lea    0x6c(%eax),%edx
8010621d:	89 55 dc             	mov    %edx,-0x24(%ebp)
80106220:	e8 0b d8 ff ff       	call   80103a30 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106225:	8b 40 10             	mov    0x10(%eax),%eax
80106228:	56                   	push   %esi
80106229:	ff 75 e4             	push   -0x1c(%ebp)
8010622c:	53                   	push   %ebx
8010622d:	ff 75 e0             	push   -0x20(%ebp)
80106230:	57                   	push   %edi
80106231:	ff 75 dc             	push   -0x24(%ebp)
80106234:	50                   	push   %eax
80106235:	68 14 a6 10 80       	push   $0x8010a614
8010623a:	e8 b5 a1 ff ff       	call   801003f4 <cprintf>
8010623f:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106242:	e8 e9 d7 ff ff       	call   80103a30 <myproc>
80106247:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
8010624e:	eb 01                	jmp    80106251 <trap+0x1da>
    break;
80106250:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106251:	e8 da d7 ff ff       	call   80103a30 <myproc>
80106256:	85 c0                	test   %eax,%eax
80106258:	74 23                	je     8010627d <trap+0x206>
8010625a:	e8 d1 d7 ff ff       	call   80103a30 <myproc>
8010625f:	8b 40 24             	mov    0x24(%eax),%eax
80106262:	85 c0                	test   %eax,%eax
80106264:	74 17                	je     8010627d <trap+0x206>
80106266:	8b 45 08             	mov    0x8(%ebp),%eax
80106269:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010626d:	0f b7 c0             	movzwl %ax,%eax
80106270:	83 e0 03             	and    $0x3,%eax
80106273:	83 f8 03             	cmp    $0x3,%eax
80106276:	75 05                	jne    8010627d <trap+0x206>
    exit();
80106278:	e8 2b dc ff ff       	call   80103ea8 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
8010627d:	e8 ae d7 ff ff       	call   80103a30 <myproc>
80106282:	85 c0                	test   %eax,%eax
80106284:	74 1d                	je     801062a3 <trap+0x22c>
80106286:	e8 a5 d7 ff ff       	call   80103a30 <myproc>
8010628b:	8b 40 0c             	mov    0xc(%eax),%eax
8010628e:	83 f8 04             	cmp    $0x4,%eax
80106291:	75 10                	jne    801062a3 <trap+0x22c>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106293:	8b 45 08             	mov    0x8(%ebp),%eax
80106296:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106299:	83 f8 20             	cmp    $0x20,%eax
8010629c:	75 05                	jne    801062a3 <trap+0x22c>
    yield();
8010629e:	e8 b6 df ff ff       	call   80104259 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801062a3:	e8 88 d7 ff ff       	call   80103a30 <myproc>
801062a8:	85 c0                	test   %eax,%eax
801062aa:	74 26                	je     801062d2 <trap+0x25b>
801062ac:	e8 7f d7 ff ff       	call   80103a30 <myproc>
801062b1:	8b 40 24             	mov    0x24(%eax),%eax
801062b4:	85 c0                	test   %eax,%eax
801062b6:	74 1a                	je     801062d2 <trap+0x25b>
801062b8:	8b 45 08             	mov    0x8(%ebp),%eax
801062bb:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801062bf:	0f b7 c0             	movzwl %ax,%eax
801062c2:	83 e0 03             	and    $0x3,%eax
801062c5:	83 f8 03             	cmp    $0x3,%eax
801062c8:	75 08                	jne    801062d2 <trap+0x25b>
    exit();
801062ca:	e8 d9 db ff ff       	call   80103ea8 <exit>
801062cf:	eb 01                	jmp    801062d2 <trap+0x25b>
    return;
801062d1:	90                   	nop
}
801062d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801062d5:	5b                   	pop    %ebx
801062d6:	5e                   	pop    %esi
801062d7:	5f                   	pop    %edi
801062d8:	5d                   	pop    %ebp
801062d9:	c3                   	ret    

801062da <inb>:
{
801062da:	55                   	push   %ebp
801062db:	89 e5                	mov    %esp,%ebp
801062dd:	83 ec 14             	sub    $0x14,%esp
801062e0:	8b 45 08             	mov    0x8(%ebp),%eax
801062e3:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801062e7:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801062eb:	89 c2                	mov    %eax,%edx
801062ed:	ec                   	in     (%dx),%al
801062ee:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801062f1:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801062f5:	c9                   	leave  
801062f6:	c3                   	ret    

801062f7 <outb>:
{
801062f7:	55                   	push   %ebp
801062f8:	89 e5                	mov    %esp,%ebp
801062fa:	83 ec 08             	sub    $0x8,%esp
801062fd:	8b 45 08             	mov    0x8(%ebp),%eax
80106300:	8b 55 0c             	mov    0xc(%ebp),%edx
80106303:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106307:	89 d0                	mov    %edx,%eax
80106309:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010630c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106310:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106314:	ee                   	out    %al,(%dx)
}
80106315:	90                   	nop
80106316:	c9                   	leave  
80106317:	c3                   	ret    

80106318 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106318:	55                   	push   %ebp
80106319:	89 e5                	mov    %esp,%ebp
8010631b:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
8010631e:	6a 00                	push   $0x0
80106320:	68 fa 03 00 00       	push   $0x3fa
80106325:	e8 cd ff ff ff       	call   801062f7 <outb>
8010632a:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010632d:	68 80 00 00 00       	push   $0x80
80106332:	68 fb 03 00 00       	push   $0x3fb
80106337:	e8 bb ff ff ff       	call   801062f7 <outb>
8010633c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
8010633f:	6a 0c                	push   $0xc
80106341:	68 f8 03 00 00       	push   $0x3f8
80106346:	e8 ac ff ff ff       	call   801062f7 <outb>
8010634b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
8010634e:	6a 00                	push   $0x0
80106350:	68 f9 03 00 00       	push   $0x3f9
80106355:	e8 9d ff ff ff       	call   801062f7 <outb>
8010635a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010635d:	6a 03                	push   $0x3
8010635f:	68 fb 03 00 00       	push   $0x3fb
80106364:	e8 8e ff ff ff       	call   801062f7 <outb>
80106369:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010636c:	6a 00                	push   $0x0
8010636e:	68 fc 03 00 00       	push   $0x3fc
80106373:	e8 7f ff ff ff       	call   801062f7 <outb>
80106378:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
8010637b:	6a 01                	push   $0x1
8010637d:	68 f9 03 00 00       	push   $0x3f9
80106382:	e8 70 ff ff ff       	call   801062f7 <outb>
80106387:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
8010638a:	68 fd 03 00 00       	push   $0x3fd
8010638f:	e8 46 ff ff ff       	call   801062da <inb>
80106394:	83 c4 04             	add    $0x4,%esp
80106397:	3c ff                	cmp    $0xff,%al
80106399:	74 61                	je     801063fc <uartinit+0xe4>
    return;
  uart = 1;
8010639b:	c7 05 78 69 19 80 01 	movl   $0x1,0x80196978
801063a2:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801063a5:	68 fa 03 00 00       	push   $0x3fa
801063aa:	e8 2b ff ff ff       	call   801062da <inb>
801063af:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801063b2:	68 f8 03 00 00       	push   $0x3f8
801063b7:	e8 1e ff ff ff       	call   801062da <inb>
801063bc:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
801063bf:	83 ec 08             	sub    $0x8,%esp
801063c2:	6a 00                	push   $0x0
801063c4:	6a 04                	push   $0x4
801063c6:	e8 63 c2 ff ff       	call   8010262e <ioapicenable>
801063cb:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801063ce:	c7 45 f4 d8 a6 10 80 	movl   $0x8010a6d8,-0xc(%ebp)
801063d5:	eb 19                	jmp    801063f0 <uartinit+0xd8>
    uartputc(*p);
801063d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063da:	0f b6 00             	movzbl (%eax),%eax
801063dd:	0f be c0             	movsbl %al,%eax
801063e0:	83 ec 0c             	sub    $0xc,%esp
801063e3:	50                   	push   %eax
801063e4:	e8 16 00 00 00       	call   801063ff <uartputc>
801063e9:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
801063ec:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801063f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063f3:	0f b6 00             	movzbl (%eax),%eax
801063f6:	84 c0                	test   %al,%al
801063f8:	75 dd                	jne    801063d7 <uartinit+0xbf>
801063fa:	eb 01                	jmp    801063fd <uartinit+0xe5>
    return;
801063fc:	90                   	nop
}
801063fd:	c9                   	leave  
801063fe:	c3                   	ret    

801063ff <uartputc>:

void
uartputc(int c)
{
801063ff:	55                   	push   %ebp
80106400:	89 e5                	mov    %esp,%ebp
80106402:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106405:	a1 78 69 19 80       	mov    0x80196978,%eax
8010640a:	85 c0                	test   %eax,%eax
8010640c:	74 53                	je     80106461 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010640e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106415:	eb 11                	jmp    80106428 <uartputc+0x29>
    microdelay(10);
80106417:	83 ec 0c             	sub    $0xc,%esp
8010641a:	6a 0a                	push   $0xa
8010641c:	e8 16 c7 ff ff       	call   80102b37 <microdelay>
80106421:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106424:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106428:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010642c:	7f 1a                	jg     80106448 <uartputc+0x49>
8010642e:	83 ec 0c             	sub    $0xc,%esp
80106431:	68 fd 03 00 00       	push   $0x3fd
80106436:	e8 9f fe ff ff       	call   801062da <inb>
8010643b:	83 c4 10             	add    $0x10,%esp
8010643e:	0f b6 c0             	movzbl %al,%eax
80106441:	83 e0 20             	and    $0x20,%eax
80106444:	85 c0                	test   %eax,%eax
80106446:	74 cf                	je     80106417 <uartputc+0x18>
  outb(COM1+0, c);
80106448:	8b 45 08             	mov    0x8(%ebp),%eax
8010644b:	0f b6 c0             	movzbl %al,%eax
8010644e:	83 ec 08             	sub    $0x8,%esp
80106451:	50                   	push   %eax
80106452:	68 f8 03 00 00       	push   $0x3f8
80106457:	e8 9b fe ff ff       	call   801062f7 <outb>
8010645c:	83 c4 10             	add    $0x10,%esp
8010645f:	eb 01                	jmp    80106462 <uartputc+0x63>
    return;
80106461:	90                   	nop
}
80106462:	c9                   	leave  
80106463:	c3                   	ret    

80106464 <uartgetc>:

static int
uartgetc(void)
{
80106464:	55                   	push   %ebp
80106465:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106467:	a1 78 69 19 80       	mov    0x80196978,%eax
8010646c:	85 c0                	test   %eax,%eax
8010646e:	75 07                	jne    80106477 <uartgetc+0x13>
    return -1;
80106470:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106475:	eb 2e                	jmp    801064a5 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106477:	68 fd 03 00 00       	push   $0x3fd
8010647c:	e8 59 fe ff ff       	call   801062da <inb>
80106481:	83 c4 04             	add    $0x4,%esp
80106484:	0f b6 c0             	movzbl %al,%eax
80106487:	83 e0 01             	and    $0x1,%eax
8010648a:	85 c0                	test   %eax,%eax
8010648c:	75 07                	jne    80106495 <uartgetc+0x31>
    return -1;
8010648e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106493:	eb 10                	jmp    801064a5 <uartgetc+0x41>
  return inb(COM1+0);
80106495:	68 f8 03 00 00       	push   $0x3f8
8010649a:	e8 3b fe ff ff       	call   801062da <inb>
8010649f:	83 c4 04             	add    $0x4,%esp
801064a2:	0f b6 c0             	movzbl %al,%eax
}
801064a5:	c9                   	leave  
801064a6:	c3                   	ret    

801064a7 <uartintr>:

void
uartintr(void)
{
801064a7:	55                   	push   %ebp
801064a8:	89 e5                	mov    %esp,%ebp
801064aa:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
801064ad:	83 ec 0c             	sub    $0xc,%esp
801064b0:	68 64 64 10 80       	push   $0x80106464
801064b5:	e8 1c a3 ff ff       	call   801007d6 <consoleintr>
801064ba:	83 c4 10             	add    $0x10,%esp
}
801064bd:	90                   	nop
801064be:	c9                   	leave  
801064bf:	c3                   	ret    

801064c0 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801064c0:	6a 00                	push   $0x0
  pushl $0
801064c2:	6a 00                	push   $0x0
  jmp alltraps
801064c4:	e9 c2 f9 ff ff       	jmp    80105e8b <alltraps>

801064c9 <vector1>:
.globl vector1
vector1:
  pushl $0
801064c9:	6a 00                	push   $0x0
  pushl $1
801064cb:	6a 01                	push   $0x1
  jmp alltraps
801064cd:	e9 b9 f9 ff ff       	jmp    80105e8b <alltraps>

801064d2 <vector2>:
.globl vector2
vector2:
  pushl $0
801064d2:	6a 00                	push   $0x0
  pushl $2
801064d4:	6a 02                	push   $0x2
  jmp alltraps
801064d6:	e9 b0 f9 ff ff       	jmp    80105e8b <alltraps>

801064db <vector3>:
.globl vector3
vector3:
  pushl $0
801064db:	6a 00                	push   $0x0
  pushl $3
801064dd:	6a 03                	push   $0x3
  jmp alltraps
801064df:	e9 a7 f9 ff ff       	jmp    80105e8b <alltraps>

801064e4 <vector4>:
.globl vector4
vector4:
  pushl $0
801064e4:	6a 00                	push   $0x0
  pushl $4
801064e6:	6a 04                	push   $0x4
  jmp alltraps
801064e8:	e9 9e f9 ff ff       	jmp    80105e8b <alltraps>

801064ed <vector5>:
.globl vector5
vector5:
  pushl $0
801064ed:	6a 00                	push   $0x0
  pushl $5
801064ef:	6a 05                	push   $0x5
  jmp alltraps
801064f1:	e9 95 f9 ff ff       	jmp    80105e8b <alltraps>

801064f6 <vector6>:
.globl vector6
vector6:
  pushl $0
801064f6:	6a 00                	push   $0x0
  pushl $6
801064f8:	6a 06                	push   $0x6
  jmp alltraps
801064fa:	e9 8c f9 ff ff       	jmp    80105e8b <alltraps>

801064ff <vector7>:
.globl vector7
vector7:
  pushl $0
801064ff:	6a 00                	push   $0x0
  pushl $7
80106501:	6a 07                	push   $0x7
  jmp alltraps
80106503:	e9 83 f9 ff ff       	jmp    80105e8b <alltraps>

80106508 <vector8>:
.globl vector8
vector8:
  pushl $8
80106508:	6a 08                	push   $0x8
  jmp alltraps
8010650a:	e9 7c f9 ff ff       	jmp    80105e8b <alltraps>

8010650f <vector9>:
.globl vector9
vector9:
  pushl $0
8010650f:	6a 00                	push   $0x0
  pushl $9
80106511:	6a 09                	push   $0x9
  jmp alltraps
80106513:	e9 73 f9 ff ff       	jmp    80105e8b <alltraps>

80106518 <vector10>:
.globl vector10
vector10:
  pushl $10
80106518:	6a 0a                	push   $0xa
  jmp alltraps
8010651a:	e9 6c f9 ff ff       	jmp    80105e8b <alltraps>

8010651f <vector11>:
.globl vector11
vector11:
  pushl $11
8010651f:	6a 0b                	push   $0xb
  jmp alltraps
80106521:	e9 65 f9 ff ff       	jmp    80105e8b <alltraps>

80106526 <vector12>:
.globl vector12
vector12:
  pushl $12
80106526:	6a 0c                	push   $0xc
  jmp alltraps
80106528:	e9 5e f9 ff ff       	jmp    80105e8b <alltraps>

8010652d <vector13>:
.globl vector13
vector13:
  pushl $13
8010652d:	6a 0d                	push   $0xd
  jmp alltraps
8010652f:	e9 57 f9 ff ff       	jmp    80105e8b <alltraps>

80106534 <vector14>:
.globl vector14
vector14:
  pushl $14
80106534:	6a 0e                	push   $0xe
  jmp alltraps
80106536:	e9 50 f9 ff ff       	jmp    80105e8b <alltraps>

8010653b <vector15>:
.globl vector15
vector15:
  pushl $0
8010653b:	6a 00                	push   $0x0
  pushl $15
8010653d:	6a 0f                	push   $0xf
  jmp alltraps
8010653f:	e9 47 f9 ff ff       	jmp    80105e8b <alltraps>

80106544 <vector16>:
.globl vector16
vector16:
  pushl $0
80106544:	6a 00                	push   $0x0
  pushl $16
80106546:	6a 10                	push   $0x10
  jmp alltraps
80106548:	e9 3e f9 ff ff       	jmp    80105e8b <alltraps>

8010654d <vector17>:
.globl vector17
vector17:
  pushl $17
8010654d:	6a 11                	push   $0x11
  jmp alltraps
8010654f:	e9 37 f9 ff ff       	jmp    80105e8b <alltraps>

80106554 <vector18>:
.globl vector18
vector18:
  pushl $0
80106554:	6a 00                	push   $0x0
  pushl $18
80106556:	6a 12                	push   $0x12
  jmp alltraps
80106558:	e9 2e f9 ff ff       	jmp    80105e8b <alltraps>

8010655d <vector19>:
.globl vector19
vector19:
  pushl $0
8010655d:	6a 00                	push   $0x0
  pushl $19
8010655f:	6a 13                	push   $0x13
  jmp alltraps
80106561:	e9 25 f9 ff ff       	jmp    80105e8b <alltraps>

80106566 <vector20>:
.globl vector20
vector20:
  pushl $0
80106566:	6a 00                	push   $0x0
  pushl $20
80106568:	6a 14                	push   $0x14
  jmp alltraps
8010656a:	e9 1c f9 ff ff       	jmp    80105e8b <alltraps>

8010656f <vector21>:
.globl vector21
vector21:
  pushl $0
8010656f:	6a 00                	push   $0x0
  pushl $21
80106571:	6a 15                	push   $0x15
  jmp alltraps
80106573:	e9 13 f9 ff ff       	jmp    80105e8b <alltraps>

80106578 <vector22>:
.globl vector22
vector22:
  pushl $0
80106578:	6a 00                	push   $0x0
  pushl $22
8010657a:	6a 16                	push   $0x16
  jmp alltraps
8010657c:	e9 0a f9 ff ff       	jmp    80105e8b <alltraps>

80106581 <vector23>:
.globl vector23
vector23:
  pushl $0
80106581:	6a 00                	push   $0x0
  pushl $23
80106583:	6a 17                	push   $0x17
  jmp alltraps
80106585:	e9 01 f9 ff ff       	jmp    80105e8b <alltraps>

8010658a <vector24>:
.globl vector24
vector24:
  pushl $0
8010658a:	6a 00                	push   $0x0
  pushl $24
8010658c:	6a 18                	push   $0x18
  jmp alltraps
8010658e:	e9 f8 f8 ff ff       	jmp    80105e8b <alltraps>

80106593 <vector25>:
.globl vector25
vector25:
  pushl $0
80106593:	6a 00                	push   $0x0
  pushl $25
80106595:	6a 19                	push   $0x19
  jmp alltraps
80106597:	e9 ef f8 ff ff       	jmp    80105e8b <alltraps>

8010659c <vector26>:
.globl vector26
vector26:
  pushl $0
8010659c:	6a 00                	push   $0x0
  pushl $26
8010659e:	6a 1a                	push   $0x1a
  jmp alltraps
801065a0:	e9 e6 f8 ff ff       	jmp    80105e8b <alltraps>

801065a5 <vector27>:
.globl vector27
vector27:
  pushl $0
801065a5:	6a 00                	push   $0x0
  pushl $27
801065a7:	6a 1b                	push   $0x1b
  jmp alltraps
801065a9:	e9 dd f8 ff ff       	jmp    80105e8b <alltraps>

801065ae <vector28>:
.globl vector28
vector28:
  pushl $0
801065ae:	6a 00                	push   $0x0
  pushl $28
801065b0:	6a 1c                	push   $0x1c
  jmp alltraps
801065b2:	e9 d4 f8 ff ff       	jmp    80105e8b <alltraps>

801065b7 <vector29>:
.globl vector29
vector29:
  pushl $0
801065b7:	6a 00                	push   $0x0
  pushl $29
801065b9:	6a 1d                	push   $0x1d
  jmp alltraps
801065bb:	e9 cb f8 ff ff       	jmp    80105e8b <alltraps>

801065c0 <vector30>:
.globl vector30
vector30:
  pushl $0
801065c0:	6a 00                	push   $0x0
  pushl $30
801065c2:	6a 1e                	push   $0x1e
  jmp alltraps
801065c4:	e9 c2 f8 ff ff       	jmp    80105e8b <alltraps>

801065c9 <vector31>:
.globl vector31
vector31:
  pushl $0
801065c9:	6a 00                	push   $0x0
  pushl $31
801065cb:	6a 1f                	push   $0x1f
  jmp alltraps
801065cd:	e9 b9 f8 ff ff       	jmp    80105e8b <alltraps>

801065d2 <vector32>:
.globl vector32
vector32:
  pushl $0
801065d2:	6a 00                	push   $0x0
  pushl $32
801065d4:	6a 20                	push   $0x20
  jmp alltraps
801065d6:	e9 b0 f8 ff ff       	jmp    80105e8b <alltraps>

801065db <vector33>:
.globl vector33
vector33:
  pushl $0
801065db:	6a 00                	push   $0x0
  pushl $33
801065dd:	6a 21                	push   $0x21
  jmp alltraps
801065df:	e9 a7 f8 ff ff       	jmp    80105e8b <alltraps>

801065e4 <vector34>:
.globl vector34
vector34:
  pushl $0
801065e4:	6a 00                	push   $0x0
  pushl $34
801065e6:	6a 22                	push   $0x22
  jmp alltraps
801065e8:	e9 9e f8 ff ff       	jmp    80105e8b <alltraps>

801065ed <vector35>:
.globl vector35
vector35:
  pushl $0
801065ed:	6a 00                	push   $0x0
  pushl $35
801065ef:	6a 23                	push   $0x23
  jmp alltraps
801065f1:	e9 95 f8 ff ff       	jmp    80105e8b <alltraps>

801065f6 <vector36>:
.globl vector36
vector36:
  pushl $0
801065f6:	6a 00                	push   $0x0
  pushl $36
801065f8:	6a 24                	push   $0x24
  jmp alltraps
801065fa:	e9 8c f8 ff ff       	jmp    80105e8b <alltraps>

801065ff <vector37>:
.globl vector37
vector37:
  pushl $0
801065ff:	6a 00                	push   $0x0
  pushl $37
80106601:	6a 25                	push   $0x25
  jmp alltraps
80106603:	e9 83 f8 ff ff       	jmp    80105e8b <alltraps>

80106608 <vector38>:
.globl vector38
vector38:
  pushl $0
80106608:	6a 00                	push   $0x0
  pushl $38
8010660a:	6a 26                	push   $0x26
  jmp alltraps
8010660c:	e9 7a f8 ff ff       	jmp    80105e8b <alltraps>

80106611 <vector39>:
.globl vector39
vector39:
  pushl $0
80106611:	6a 00                	push   $0x0
  pushl $39
80106613:	6a 27                	push   $0x27
  jmp alltraps
80106615:	e9 71 f8 ff ff       	jmp    80105e8b <alltraps>

8010661a <vector40>:
.globl vector40
vector40:
  pushl $0
8010661a:	6a 00                	push   $0x0
  pushl $40
8010661c:	6a 28                	push   $0x28
  jmp alltraps
8010661e:	e9 68 f8 ff ff       	jmp    80105e8b <alltraps>

80106623 <vector41>:
.globl vector41
vector41:
  pushl $0
80106623:	6a 00                	push   $0x0
  pushl $41
80106625:	6a 29                	push   $0x29
  jmp alltraps
80106627:	e9 5f f8 ff ff       	jmp    80105e8b <alltraps>

8010662c <vector42>:
.globl vector42
vector42:
  pushl $0
8010662c:	6a 00                	push   $0x0
  pushl $42
8010662e:	6a 2a                	push   $0x2a
  jmp alltraps
80106630:	e9 56 f8 ff ff       	jmp    80105e8b <alltraps>

80106635 <vector43>:
.globl vector43
vector43:
  pushl $0
80106635:	6a 00                	push   $0x0
  pushl $43
80106637:	6a 2b                	push   $0x2b
  jmp alltraps
80106639:	e9 4d f8 ff ff       	jmp    80105e8b <alltraps>

8010663e <vector44>:
.globl vector44
vector44:
  pushl $0
8010663e:	6a 00                	push   $0x0
  pushl $44
80106640:	6a 2c                	push   $0x2c
  jmp alltraps
80106642:	e9 44 f8 ff ff       	jmp    80105e8b <alltraps>

80106647 <vector45>:
.globl vector45
vector45:
  pushl $0
80106647:	6a 00                	push   $0x0
  pushl $45
80106649:	6a 2d                	push   $0x2d
  jmp alltraps
8010664b:	e9 3b f8 ff ff       	jmp    80105e8b <alltraps>

80106650 <vector46>:
.globl vector46
vector46:
  pushl $0
80106650:	6a 00                	push   $0x0
  pushl $46
80106652:	6a 2e                	push   $0x2e
  jmp alltraps
80106654:	e9 32 f8 ff ff       	jmp    80105e8b <alltraps>

80106659 <vector47>:
.globl vector47
vector47:
  pushl $0
80106659:	6a 00                	push   $0x0
  pushl $47
8010665b:	6a 2f                	push   $0x2f
  jmp alltraps
8010665d:	e9 29 f8 ff ff       	jmp    80105e8b <alltraps>

80106662 <vector48>:
.globl vector48
vector48:
  pushl $0
80106662:	6a 00                	push   $0x0
  pushl $48
80106664:	6a 30                	push   $0x30
  jmp alltraps
80106666:	e9 20 f8 ff ff       	jmp    80105e8b <alltraps>

8010666b <vector49>:
.globl vector49
vector49:
  pushl $0
8010666b:	6a 00                	push   $0x0
  pushl $49
8010666d:	6a 31                	push   $0x31
  jmp alltraps
8010666f:	e9 17 f8 ff ff       	jmp    80105e8b <alltraps>

80106674 <vector50>:
.globl vector50
vector50:
  pushl $0
80106674:	6a 00                	push   $0x0
  pushl $50
80106676:	6a 32                	push   $0x32
  jmp alltraps
80106678:	e9 0e f8 ff ff       	jmp    80105e8b <alltraps>

8010667d <vector51>:
.globl vector51
vector51:
  pushl $0
8010667d:	6a 00                	push   $0x0
  pushl $51
8010667f:	6a 33                	push   $0x33
  jmp alltraps
80106681:	e9 05 f8 ff ff       	jmp    80105e8b <alltraps>

80106686 <vector52>:
.globl vector52
vector52:
  pushl $0
80106686:	6a 00                	push   $0x0
  pushl $52
80106688:	6a 34                	push   $0x34
  jmp alltraps
8010668a:	e9 fc f7 ff ff       	jmp    80105e8b <alltraps>

8010668f <vector53>:
.globl vector53
vector53:
  pushl $0
8010668f:	6a 00                	push   $0x0
  pushl $53
80106691:	6a 35                	push   $0x35
  jmp alltraps
80106693:	e9 f3 f7 ff ff       	jmp    80105e8b <alltraps>

80106698 <vector54>:
.globl vector54
vector54:
  pushl $0
80106698:	6a 00                	push   $0x0
  pushl $54
8010669a:	6a 36                	push   $0x36
  jmp alltraps
8010669c:	e9 ea f7 ff ff       	jmp    80105e8b <alltraps>

801066a1 <vector55>:
.globl vector55
vector55:
  pushl $0
801066a1:	6a 00                	push   $0x0
  pushl $55
801066a3:	6a 37                	push   $0x37
  jmp alltraps
801066a5:	e9 e1 f7 ff ff       	jmp    80105e8b <alltraps>

801066aa <vector56>:
.globl vector56
vector56:
  pushl $0
801066aa:	6a 00                	push   $0x0
  pushl $56
801066ac:	6a 38                	push   $0x38
  jmp alltraps
801066ae:	e9 d8 f7 ff ff       	jmp    80105e8b <alltraps>

801066b3 <vector57>:
.globl vector57
vector57:
  pushl $0
801066b3:	6a 00                	push   $0x0
  pushl $57
801066b5:	6a 39                	push   $0x39
  jmp alltraps
801066b7:	e9 cf f7 ff ff       	jmp    80105e8b <alltraps>

801066bc <vector58>:
.globl vector58
vector58:
  pushl $0
801066bc:	6a 00                	push   $0x0
  pushl $58
801066be:	6a 3a                	push   $0x3a
  jmp alltraps
801066c0:	e9 c6 f7 ff ff       	jmp    80105e8b <alltraps>

801066c5 <vector59>:
.globl vector59
vector59:
  pushl $0
801066c5:	6a 00                	push   $0x0
  pushl $59
801066c7:	6a 3b                	push   $0x3b
  jmp alltraps
801066c9:	e9 bd f7 ff ff       	jmp    80105e8b <alltraps>

801066ce <vector60>:
.globl vector60
vector60:
  pushl $0
801066ce:	6a 00                	push   $0x0
  pushl $60
801066d0:	6a 3c                	push   $0x3c
  jmp alltraps
801066d2:	e9 b4 f7 ff ff       	jmp    80105e8b <alltraps>

801066d7 <vector61>:
.globl vector61
vector61:
  pushl $0
801066d7:	6a 00                	push   $0x0
  pushl $61
801066d9:	6a 3d                	push   $0x3d
  jmp alltraps
801066db:	e9 ab f7 ff ff       	jmp    80105e8b <alltraps>

801066e0 <vector62>:
.globl vector62
vector62:
  pushl $0
801066e0:	6a 00                	push   $0x0
  pushl $62
801066e2:	6a 3e                	push   $0x3e
  jmp alltraps
801066e4:	e9 a2 f7 ff ff       	jmp    80105e8b <alltraps>

801066e9 <vector63>:
.globl vector63
vector63:
  pushl $0
801066e9:	6a 00                	push   $0x0
  pushl $63
801066eb:	6a 3f                	push   $0x3f
  jmp alltraps
801066ed:	e9 99 f7 ff ff       	jmp    80105e8b <alltraps>

801066f2 <vector64>:
.globl vector64
vector64:
  pushl $0
801066f2:	6a 00                	push   $0x0
  pushl $64
801066f4:	6a 40                	push   $0x40
  jmp alltraps
801066f6:	e9 90 f7 ff ff       	jmp    80105e8b <alltraps>

801066fb <vector65>:
.globl vector65
vector65:
  pushl $0
801066fb:	6a 00                	push   $0x0
  pushl $65
801066fd:	6a 41                	push   $0x41
  jmp alltraps
801066ff:	e9 87 f7 ff ff       	jmp    80105e8b <alltraps>

80106704 <vector66>:
.globl vector66
vector66:
  pushl $0
80106704:	6a 00                	push   $0x0
  pushl $66
80106706:	6a 42                	push   $0x42
  jmp alltraps
80106708:	e9 7e f7 ff ff       	jmp    80105e8b <alltraps>

8010670d <vector67>:
.globl vector67
vector67:
  pushl $0
8010670d:	6a 00                	push   $0x0
  pushl $67
8010670f:	6a 43                	push   $0x43
  jmp alltraps
80106711:	e9 75 f7 ff ff       	jmp    80105e8b <alltraps>

80106716 <vector68>:
.globl vector68
vector68:
  pushl $0
80106716:	6a 00                	push   $0x0
  pushl $68
80106718:	6a 44                	push   $0x44
  jmp alltraps
8010671a:	e9 6c f7 ff ff       	jmp    80105e8b <alltraps>

8010671f <vector69>:
.globl vector69
vector69:
  pushl $0
8010671f:	6a 00                	push   $0x0
  pushl $69
80106721:	6a 45                	push   $0x45
  jmp alltraps
80106723:	e9 63 f7 ff ff       	jmp    80105e8b <alltraps>

80106728 <vector70>:
.globl vector70
vector70:
  pushl $0
80106728:	6a 00                	push   $0x0
  pushl $70
8010672a:	6a 46                	push   $0x46
  jmp alltraps
8010672c:	e9 5a f7 ff ff       	jmp    80105e8b <alltraps>

80106731 <vector71>:
.globl vector71
vector71:
  pushl $0
80106731:	6a 00                	push   $0x0
  pushl $71
80106733:	6a 47                	push   $0x47
  jmp alltraps
80106735:	e9 51 f7 ff ff       	jmp    80105e8b <alltraps>

8010673a <vector72>:
.globl vector72
vector72:
  pushl $0
8010673a:	6a 00                	push   $0x0
  pushl $72
8010673c:	6a 48                	push   $0x48
  jmp alltraps
8010673e:	e9 48 f7 ff ff       	jmp    80105e8b <alltraps>

80106743 <vector73>:
.globl vector73
vector73:
  pushl $0
80106743:	6a 00                	push   $0x0
  pushl $73
80106745:	6a 49                	push   $0x49
  jmp alltraps
80106747:	e9 3f f7 ff ff       	jmp    80105e8b <alltraps>

8010674c <vector74>:
.globl vector74
vector74:
  pushl $0
8010674c:	6a 00                	push   $0x0
  pushl $74
8010674e:	6a 4a                	push   $0x4a
  jmp alltraps
80106750:	e9 36 f7 ff ff       	jmp    80105e8b <alltraps>

80106755 <vector75>:
.globl vector75
vector75:
  pushl $0
80106755:	6a 00                	push   $0x0
  pushl $75
80106757:	6a 4b                	push   $0x4b
  jmp alltraps
80106759:	e9 2d f7 ff ff       	jmp    80105e8b <alltraps>

8010675e <vector76>:
.globl vector76
vector76:
  pushl $0
8010675e:	6a 00                	push   $0x0
  pushl $76
80106760:	6a 4c                	push   $0x4c
  jmp alltraps
80106762:	e9 24 f7 ff ff       	jmp    80105e8b <alltraps>

80106767 <vector77>:
.globl vector77
vector77:
  pushl $0
80106767:	6a 00                	push   $0x0
  pushl $77
80106769:	6a 4d                	push   $0x4d
  jmp alltraps
8010676b:	e9 1b f7 ff ff       	jmp    80105e8b <alltraps>

80106770 <vector78>:
.globl vector78
vector78:
  pushl $0
80106770:	6a 00                	push   $0x0
  pushl $78
80106772:	6a 4e                	push   $0x4e
  jmp alltraps
80106774:	e9 12 f7 ff ff       	jmp    80105e8b <alltraps>

80106779 <vector79>:
.globl vector79
vector79:
  pushl $0
80106779:	6a 00                	push   $0x0
  pushl $79
8010677b:	6a 4f                	push   $0x4f
  jmp alltraps
8010677d:	e9 09 f7 ff ff       	jmp    80105e8b <alltraps>

80106782 <vector80>:
.globl vector80
vector80:
  pushl $0
80106782:	6a 00                	push   $0x0
  pushl $80
80106784:	6a 50                	push   $0x50
  jmp alltraps
80106786:	e9 00 f7 ff ff       	jmp    80105e8b <alltraps>

8010678b <vector81>:
.globl vector81
vector81:
  pushl $0
8010678b:	6a 00                	push   $0x0
  pushl $81
8010678d:	6a 51                	push   $0x51
  jmp alltraps
8010678f:	e9 f7 f6 ff ff       	jmp    80105e8b <alltraps>

80106794 <vector82>:
.globl vector82
vector82:
  pushl $0
80106794:	6a 00                	push   $0x0
  pushl $82
80106796:	6a 52                	push   $0x52
  jmp alltraps
80106798:	e9 ee f6 ff ff       	jmp    80105e8b <alltraps>

8010679d <vector83>:
.globl vector83
vector83:
  pushl $0
8010679d:	6a 00                	push   $0x0
  pushl $83
8010679f:	6a 53                	push   $0x53
  jmp alltraps
801067a1:	e9 e5 f6 ff ff       	jmp    80105e8b <alltraps>

801067a6 <vector84>:
.globl vector84
vector84:
  pushl $0
801067a6:	6a 00                	push   $0x0
  pushl $84
801067a8:	6a 54                	push   $0x54
  jmp alltraps
801067aa:	e9 dc f6 ff ff       	jmp    80105e8b <alltraps>

801067af <vector85>:
.globl vector85
vector85:
  pushl $0
801067af:	6a 00                	push   $0x0
  pushl $85
801067b1:	6a 55                	push   $0x55
  jmp alltraps
801067b3:	e9 d3 f6 ff ff       	jmp    80105e8b <alltraps>

801067b8 <vector86>:
.globl vector86
vector86:
  pushl $0
801067b8:	6a 00                	push   $0x0
  pushl $86
801067ba:	6a 56                	push   $0x56
  jmp alltraps
801067bc:	e9 ca f6 ff ff       	jmp    80105e8b <alltraps>

801067c1 <vector87>:
.globl vector87
vector87:
  pushl $0
801067c1:	6a 00                	push   $0x0
  pushl $87
801067c3:	6a 57                	push   $0x57
  jmp alltraps
801067c5:	e9 c1 f6 ff ff       	jmp    80105e8b <alltraps>

801067ca <vector88>:
.globl vector88
vector88:
  pushl $0
801067ca:	6a 00                	push   $0x0
  pushl $88
801067cc:	6a 58                	push   $0x58
  jmp alltraps
801067ce:	e9 b8 f6 ff ff       	jmp    80105e8b <alltraps>

801067d3 <vector89>:
.globl vector89
vector89:
  pushl $0
801067d3:	6a 00                	push   $0x0
  pushl $89
801067d5:	6a 59                	push   $0x59
  jmp alltraps
801067d7:	e9 af f6 ff ff       	jmp    80105e8b <alltraps>

801067dc <vector90>:
.globl vector90
vector90:
  pushl $0
801067dc:	6a 00                	push   $0x0
  pushl $90
801067de:	6a 5a                	push   $0x5a
  jmp alltraps
801067e0:	e9 a6 f6 ff ff       	jmp    80105e8b <alltraps>

801067e5 <vector91>:
.globl vector91
vector91:
  pushl $0
801067e5:	6a 00                	push   $0x0
  pushl $91
801067e7:	6a 5b                	push   $0x5b
  jmp alltraps
801067e9:	e9 9d f6 ff ff       	jmp    80105e8b <alltraps>

801067ee <vector92>:
.globl vector92
vector92:
  pushl $0
801067ee:	6a 00                	push   $0x0
  pushl $92
801067f0:	6a 5c                	push   $0x5c
  jmp alltraps
801067f2:	e9 94 f6 ff ff       	jmp    80105e8b <alltraps>

801067f7 <vector93>:
.globl vector93
vector93:
  pushl $0
801067f7:	6a 00                	push   $0x0
  pushl $93
801067f9:	6a 5d                	push   $0x5d
  jmp alltraps
801067fb:	e9 8b f6 ff ff       	jmp    80105e8b <alltraps>

80106800 <vector94>:
.globl vector94
vector94:
  pushl $0
80106800:	6a 00                	push   $0x0
  pushl $94
80106802:	6a 5e                	push   $0x5e
  jmp alltraps
80106804:	e9 82 f6 ff ff       	jmp    80105e8b <alltraps>

80106809 <vector95>:
.globl vector95
vector95:
  pushl $0
80106809:	6a 00                	push   $0x0
  pushl $95
8010680b:	6a 5f                	push   $0x5f
  jmp alltraps
8010680d:	e9 79 f6 ff ff       	jmp    80105e8b <alltraps>

80106812 <vector96>:
.globl vector96
vector96:
  pushl $0
80106812:	6a 00                	push   $0x0
  pushl $96
80106814:	6a 60                	push   $0x60
  jmp alltraps
80106816:	e9 70 f6 ff ff       	jmp    80105e8b <alltraps>

8010681b <vector97>:
.globl vector97
vector97:
  pushl $0
8010681b:	6a 00                	push   $0x0
  pushl $97
8010681d:	6a 61                	push   $0x61
  jmp alltraps
8010681f:	e9 67 f6 ff ff       	jmp    80105e8b <alltraps>

80106824 <vector98>:
.globl vector98
vector98:
  pushl $0
80106824:	6a 00                	push   $0x0
  pushl $98
80106826:	6a 62                	push   $0x62
  jmp alltraps
80106828:	e9 5e f6 ff ff       	jmp    80105e8b <alltraps>

8010682d <vector99>:
.globl vector99
vector99:
  pushl $0
8010682d:	6a 00                	push   $0x0
  pushl $99
8010682f:	6a 63                	push   $0x63
  jmp alltraps
80106831:	e9 55 f6 ff ff       	jmp    80105e8b <alltraps>

80106836 <vector100>:
.globl vector100
vector100:
  pushl $0
80106836:	6a 00                	push   $0x0
  pushl $100
80106838:	6a 64                	push   $0x64
  jmp alltraps
8010683a:	e9 4c f6 ff ff       	jmp    80105e8b <alltraps>

8010683f <vector101>:
.globl vector101
vector101:
  pushl $0
8010683f:	6a 00                	push   $0x0
  pushl $101
80106841:	6a 65                	push   $0x65
  jmp alltraps
80106843:	e9 43 f6 ff ff       	jmp    80105e8b <alltraps>

80106848 <vector102>:
.globl vector102
vector102:
  pushl $0
80106848:	6a 00                	push   $0x0
  pushl $102
8010684a:	6a 66                	push   $0x66
  jmp alltraps
8010684c:	e9 3a f6 ff ff       	jmp    80105e8b <alltraps>

80106851 <vector103>:
.globl vector103
vector103:
  pushl $0
80106851:	6a 00                	push   $0x0
  pushl $103
80106853:	6a 67                	push   $0x67
  jmp alltraps
80106855:	e9 31 f6 ff ff       	jmp    80105e8b <alltraps>

8010685a <vector104>:
.globl vector104
vector104:
  pushl $0
8010685a:	6a 00                	push   $0x0
  pushl $104
8010685c:	6a 68                	push   $0x68
  jmp alltraps
8010685e:	e9 28 f6 ff ff       	jmp    80105e8b <alltraps>

80106863 <vector105>:
.globl vector105
vector105:
  pushl $0
80106863:	6a 00                	push   $0x0
  pushl $105
80106865:	6a 69                	push   $0x69
  jmp alltraps
80106867:	e9 1f f6 ff ff       	jmp    80105e8b <alltraps>

8010686c <vector106>:
.globl vector106
vector106:
  pushl $0
8010686c:	6a 00                	push   $0x0
  pushl $106
8010686e:	6a 6a                	push   $0x6a
  jmp alltraps
80106870:	e9 16 f6 ff ff       	jmp    80105e8b <alltraps>

80106875 <vector107>:
.globl vector107
vector107:
  pushl $0
80106875:	6a 00                	push   $0x0
  pushl $107
80106877:	6a 6b                	push   $0x6b
  jmp alltraps
80106879:	e9 0d f6 ff ff       	jmp    80105e8b <alltraps>

8010687e <vector108>:
.globl vector108
vector108:
  pushl $0
8010687e:	6a 00                	push   $0x0
  pushl $108
80106880:	6a 6c                	push   $0x6c
  jmp alltraps
80106882:	e9 04 f6 ff ff       	jmp    80105e8b <alltraps>

80106887 <vector109>:
.globl vector109
vector109:
  pushl $0
80106887:	6a 00                	push   $0x0
  pushl $109
80106889:	6a 6d                	push   $0x6d
  jmp alltraps
8010688b:	e9 fb f5 ff ff       	jmp    80105e8b <alltraps>

80106890 <vector110>:
.globl vector110
vector110:
  pushl $0
80106890:	6a 00                	push   $0x0
  pushl $110
80106892:	6a 6e                	push   $0x6e
  jmp alltraps
80106894:	e9 f2 f5 ff ff       	jmp    80105e8b <alltraps>

80106899 <vector111>:
.globl vector111
vector111:
  pushl $0
80106899:	6a 00                	push   $0x0
  pushl $111
8010689b:	6a 6f                	push   $0x6f
  jmp alltraps
8010689d:	e9 e9 f5 ff ff       	jmp    80105e8b <alltraps>

801068a2 <vector112>:
.globl vector112
vector112:
  pushl $0
801068a2:	6a 00                	push   $0x0
  pushl $112
801068a4:	6a 70                	push   $0x70
  jmp alltraps
801068a6:	e9 e0 f5 ff ff       	jmp    80105e8b <alltraps>

801068ab <vector113>:
.globl vector113
vector113:
  pushl $0
801068ab:	6a 00                	push   $0x0
  pushl $113
801068ad:	6a 71                	push   $0x71
  jmp alltraps
801068af:	e9 d7 f5 ff ff       	jmp    80105e8b <alltraps>

801068b4 <vector114>:
.globl vector114
vector114:
  pushl $0
801068b4:	6a 00                	push   $0x0
  pushl $114
801068b6:	6a 72                	push   $0x72
  jmp alltraps
801068b8:	e9 ce f5 ff ff       	jmp    80105e8b <alltraps>

801068bd <vector115>:
.globl vector115
vector115:
  pushl $0
801068bd:	6a 00                	push   $0x0
  pushl $115
801068bf:	6a 73                	push   $0x73
  jmp alltraps
801068c1:	e9 c5 f5 ff ff       	jmp    80105e8b <alltraps>

801068c6 <vector116>:
.globl vector116
vector116:
  pushl $0
801068c6:	6a 00                	push   $0x0
  pushl $116
801068c8:	6a 74                	push   $0x74
  jmp alltraps
801068ca:	e9 bc f5 ff ff       	jmp    80105e8b <alltraps>

801068cf <vector117>:
.globl vector117
vector117:
  pushl $0
801068cf:	6a 00                	push   $0x0
  pushl $117
801068d1:	6a 75                	push   $0x75
  jmp alltraps
801068d3:	e9 b3 f5 ff ff       	jmp    80105e8b <alltraps>

801068d8 <vector118>:
.globl vector118
vector118:
  pushl $0
801068d8:	6a 00                	push   $0x0
  pushl $118
801068da:	6a 76                	push   $0x76
  jmp alltraps
801068dc:	e9 aa f5 ff ff       	jmp    80105e8b <alltraps>

801068e1 <vector119>:
.globl vector119
vector119:
  pushl $0
801068e1:	6a 00                	push   $0x0
  pushl $119
801068e3:	6a 77                	push   $0x77
  jmp alltraps
801068e5:	e9 a1 f5 ff ff       	jmp    80105e8b <alltraps>

801068ea <vector120>:
.globl vector120
vector120:
  pushl $0
801068ea:	6a 00                	push   $0x0
  pushl $120
801068ec:	6a 78                	push   $0x78
  jmp alltraps
801068ee:	e9 98 f5 ff ff       	jmp    80105e8b <alltraps>

801068f3 <vector121>:
.globl vector121
vector121:
  pushl $0
801068f3:	6a 00                	push   $0x0
  pushl $121
801068f5:	6a 79                	push   $0x79
  jmp alltraps
801068f7:	e9 8f f5 ff ff       	jmp    80105e8b <alltraps>

801068fc <vector122>:
.globl vector122
vector122:
  pushl $0
801068fc:	6a 00                	push   $0x0
  pushl $122
801068fe:	6a 7a                	push   $0x7a
  jmp alltraps
80106900:	e9 86 f5 ff ff       	jmp    80105e8b <alltraps>

80106905 <vector123>:
.globl vector123
vector123:
  pushl $0
80106905:	6a 00                	push   $0x0
  pushl $123
80106907:	6a 7b                	push   $0x7b
  jmp alltraps
80106909:	e9 7d f5 ff ff       	jmp    80105e8b <alltraps>

8010690e <vector124>:
.globl vector124
vector124:
  pushl $0
8010690e:	6a 00                	push   $0x0
  pushl $124
80106910:	6a 7c                	push   $0x7c
  jmp alltraps
80106912:	e9 74 f5 ff ff       	jmp    80105e8b <alltraps>

80106917 <vector125>:
.globl vector125
vector125:
  pushl $0
80106917:	6a 00                	push   $0x0
  pushl $125
80106919:	6a 7d                	push   $0x7d
  jmp alltraps
8010691b:	e9 6b f5 ff ff       	jmp    80105e8b <alltraps>

80106920 <vector126>:
.globl vector126
vector126:
  pushl $0
80106920:	6a 00                	push   $0x0
  pushl $126
80106922:	6a 7e                	push   $0x7e
  jmp alltraps
80106924:	e9 62 f5 ff ff       	jmp    80105e8b <alltraps>

80106929 <vector127>:
.globl vector127
vector127:
  pushl $0
80106929:	6a 00                	push   $0x0
  pushl $127
8010692b:	6a 7f                	push   $0x7f
  jmp alltraps
8010692d:	e9 59 f5 ff ff       	jmp    80105e8b <alltraps>

80106932 <vector128>:
.globl vector128
vector128:
  pushl $0
80106932:	6a 00                	push   $0x0
  pushl $128
80106934:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106939:	e9 4d f5 ff ff       	jmp    80105e8b <alltraps>

8010693e <vector129>:
.globl vector129
vector129:
  pushl $0
8010693e:	6a 00                	push   $0x0
  pushl $129
80106940:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106945:	e9 41 f5 ff ff       	jmp    80105e8b <alltraps>

8010694a <vector130>:
.globl vector130
vector130:
  pushl $0
8010694a:	6a 00                	push   $0x0
  pushl $130
8010694c:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106951:	e9 35 f5 ff ff       	jmp    80105e8b <alltraps>

80106956 <vector131>:
.globl vector131
vector131:
  pushl $0
80106956:	6a 00                	push   $0x0
  pushl $131
80106958:	68 83 00 00 00       	push   $0x83
  jmp alltraps
8010695d:	e9 29 f5 ff ff       	jmp    80105e8b <alltraps>

80106962 <vector132>:
.globl vector132
vector132:
  pushl $0
80106962:	6a 00                	push   $0x0
  pushl $132
80106964:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106969:	e9 1d f5 ff ff       	jmp    80105e8b <alltraps>

8010696e <vector133>:
.globl vector133
vector133:
  pushl $0
8010696e:	6a 00                	push   $0x0
  pushl $133
80106970:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106975:	e9 11 f5 ff ff       	jmp    80105e8b <alltraps>

8010697a <vector134>:
.globl vector134
vector134:
  pushl $0
8010697a:	6a 00                	push   $0x0
  pushl $134
8010697c:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106981:	e9 05 f5 ff ff       	jmp    80105e8b <alltraps>

80106986 <vector135>:
.globl vector135
vector135:
  pushl $0
80106986:	6a 00                	push   $0x0
  pushl $135
80106988:	68 87 00 00 00       	push   $0x87
  jmp alltraps
8010698d:	e9 f9 f4 ff ff       	jmp    80105e8b <alltraps>

80106992 <vector136>:
.globl vector136
vector136:
  pushl $0
80106992:	6a 00                	push   $0x0
  pushl $136
80106994:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106999:	e9 ed f4 ff ff       	jmp    80105e8b <alltraps>

8010699e <vector137>:
.globl vector137
vector137:
  pushl $0
8010699e:	6a 00                	push   $0x0
  pushl $137
801069a0:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801069a5:	e9 e1 f4 ff ff       	jmp    80105e8b <alltraps>

801069aa <vector138>:
.globl vector138
vector138:
  pushl $0
801069aa:	6a 00                	push   $0x0
  pushl $138
801069ac:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801069b1:	e9 d5 f4 ff ff       	jmp    80105e8b <alltraps>

801069b6 <vector139>:
.globl vector139
vector139:
  pushl $0
801069b6:	6a 00                	push   $0x0
  pushl $139
801069b8:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801069bd:	e9 c9 f4 ff ff       	jmp    80105e8b <alltraps>

801069c2 <vector140>:
.globl vector140
vector140:
  pushl $0
801069c2:	6a 00                	push   $0x0
  pushl $140
801069c4:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801069c9:	e9 bd f4 ff ff       	jmp    80105e8b <alltraps>

801069ce <vector141>:
.globl vector141
vector141:
  pushl $0
801069ce:	6a 00                	push   $0x0
  pushl $141
801069d0:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801069d5:	e9 b1 f4 ff ff       	jmp    80105e8b <alltraps>

801069da <vector142>:
.globl vector142
vector142:
  pushl $0
801069da:	6a 00                	push   $0x0
  pushl $142
801069dc:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801069e1:	e9 a5 f4 ff ff       	jmp    80105e8b <alltraps>

801069e6 <vector143>:
.globl vector143
vector143:
  pushl $0
801069e6:	6a 00                	push   $0x0
  pushl $143
801069e8:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801069ed:	e9 99 f4 ff ff       	jmp    80105e8b <alltraps>

801069f2 <vector144>:
.globl vector144
vector144:
  pushl $0
801069f2:	6a 00                	push   $0x0
  pushl $144
801069f4:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801069f9:	e9 8d f4 ff ff       	jmp    80105e8b <alltraps>

801069fe <vector145>:
.globl vector145
vector145:
  pushl $0
801069fe:	6a 00                	push   $0x0
  pushl $145
80106a00:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106a05:	e9 81 f4 ff ff       	jmp    80105e8b <alltraps>

80106a0a <vector146>:
.globl vector146
vector146:
  pushl $0
80106a0a:	6a 00                	push   $0x0
  pushl $146
80106a0c:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106a11:	e9 75 f4 ff ff       	jmp    80105e8b <alltraps>

80106a16 <vector147>:
.globl vector147
vector147:
  pushl $0
80106a16:	6a 00                	push   $0x0
  pushl $147
80106a18:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106a1d:	e9 69 f4 ff ff       	jmp    80105e8b <alltraps>

80106a22 <vector148>:
.globl vector148
vector148:
  pushl $0
80106a22:	6a 00                	push   $0x0
  pushl $148
80106a24:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106a29:	e9 5d f4 ff ff       	jmp    80105e8b <alltraps>

80106a2e <vector149>:
.globl vector149
vector149:
  pushl $0
80106a2e:	6a 00                	push   $0x0
  pushl $149
80106a30:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106a35:	e9 51 f4 ff ff       	jmp    80105e8b <alltraps>

80106a3a <vector150>:
.globl vector150
vector150:
  pushl $0
80106a3a:	6a 00                	push   $0x0
  pushl $150
80106a3c:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106a41:	e9 45 f4 ff ff       	jmp    80105e8b <alltraps>

80106a46 <vector151>:
.globl vector151
vector151:
  pushl $0
80106a46:	6a 00                	push   $0x0
  pushl $151
80106a48:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106a4d:	e9 39 f4 ff ff       	jmp    80105e8b <alltraps>

80106a52 <vector152>:
.globl vector152
vector152:
  pushl $0
80106a52:	6a 00                	push   $0x0
  pushl $152
80106a54:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106a59:	e9 2d f4 ff ff       	jmp    80105e8b <alltraps>

80106a5e <vector153>:
.globl vector153
vector153:
  pushl $0
80106a5e:	6a 00                	push   $0x0
  pushl $153
80106a60:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106a65:	e9 21 f4 ff ff       	jmp    80105e8b <alltraps>

80106a6a <vector154>:
.globl vector154
vector154:
  pushl $0
80106a6a:	6a 00                	push   $0x0
  pushl $154
80106a6c:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106a71:	e9 15 f4 ff ff       	jmp    80105e8b <alltraps>

80106a76 <vector155>:
.globl vector155
vector155:
  pushl $0
80106a76:	6a 00                	push   $0x0
  pushl $155
80106a78:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106a7d:	e9 09 f4 ff ff       	jmp    80105e8b <alltraps>

80106a82 <vector156>:
.globl vector156
vector156:
  pushl $0
80106a82:	6a 00                	push   $0x0
  pushl $156
80106a84:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106a89:	e9 fd f3 ff ff       	jmp    80105e8b <alltraps>

80106a8e <vector157>:
.globl vector157
vector157:
  pushl $0
80106a8e:	6a 00                	push   $0x0
  pushl $157
80106a90:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106a95:	e9 f1 f3 ff ff       	jmp    80105e8b <alltraps>

80106a9a <vector158>:
.globl vector158
vector158:
  pushl $0
80106a9a:	6a 00                	push   $0x0
  pushl $158
80106a9c:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106aa1:	e9 e5 f3 ff ff       	jmp    80105e8b <alltraps>

80106aa6 <vector159>:
.globl vector159
vector159:
  pushl $0
80106aa6:	6a 00                	push   $0x0
  pushl $159
80106aa8:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106aad:	e9 d9 f3 ff ff       	jmp    80105e8b <alltraps>

80106ab2 <vector160>:
.globl vector160
vector160:
  pushl $0
80106ab2:	6a 00                	push   $0x0
  pushl $160
80106ab4:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106ab9:	e9 cd f3 ff ff       	jmp    80105e8b <alltraps>

80106abe <vector161>:
.globl vector161
vector161:
  pushl $0
80106abe:	6a 00                	push   $0x0
  pushl $161
80106ac0:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106ac5:	e9 c1 f3 ff ff       	jmp    80105e8b <alltraps>

80106aca <vector162>:
.globl vector162
vector162:
  pushl $0
80106aca:	6a 00                	push   $0x0
  pushl $162
80106acc:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106ad1:	e9 b5 f3 ff ff       	jmp    80105e8b <alltraps>

80106ad6 <vector163>:
.globl vector163
vector163:
  pushl $0
80106ad6:	6a 00                	push   $0x0
  pushl $163
80106ad8:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106add:	e9 a9 f3 ff ff       	jmp    80105e8b <alltraps>

80106ae2 <vector164>:
.globl vector164
vector164:
  pushl $0
80106ae2:	6a 00                	push   $0x0
  pushl $164
80106ae4:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106ae9:	e9 9d f3 ff ff       	jmp    80105e8b <alltraps>

80106aee <vector165>:
.globl vector165
vector165:
  pushl $0
80106aee:	6a 00                	push   $0x0
  pushl $165
80106af0:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106af5:	e9 91 f3 ff ff       	jmp    80105e8b <alltraps>

80106afa <vector166>:
.globl vector166
vector166:
  pushl $0
80106afa:	6a 00                	push   $0x0
  pushl $166
80106afc:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106b01:	e9 85 f3 ff ff       	jmp    80105e8b <alltraps>

80106b06 <vector167>:
.globl vector167
vector167:
  pushl $0
80106b06:	6a 00                	push   $0x0
  pushl $167
80106b08:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106b0d:	e9 79 f3 ff ff       	jmp    80105e8b <alltraps>

80106b12 <vector168>:
.globl vector168
vector168:
  pushl $0
80106b12:	6a 00                	push   $0x0
  pushl $168
80106b14:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106b19:	e9 6d f3 ff ff       	jmp    80105e8b <alltraps>

80106b1e <vector169>:
.globl vector169
vector169:
  pushl $0
80106b1e:	6a 00                	push   $0x0
  pushl $169
80106b20:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106b25:	e9 61 f3 ff ff       	jmp    80105e8b <alltraps>

80106b2a <vector170>:
.globl vector170
vector170:
  pushl $0
80106b2a:	6a 00                	push   $0x0
  pushl $170
80106b2c:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106b31:	e9 55 f3 ff ff       	jmp    80105e8b <alltraps>

80106b36 <vector171>:
.globl vector171
vector171:
  pushl $0
80106b36:	6a 00                	push   $0x0
  pushl $171
80106b38:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106b3d:	e9 49 f3 ff ff       	jmp    80105e8b <alltraps>

80106b42 <vector172>:
.globl vector172
vector172:
  pushl $0
80106b42:	6a 00                	push   $0x0
  pushl $172
80106b44:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106b49:	e9 3d f3 ff ff       	jmp    80105e8b <alltraps>

80106b4e <vector173>:
.globl vector173
vector173:
  pushl $0
80106b4e:	6a 00                	push   $0x0
  pushl $173
80106b50:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106b55:	e9 31 f3 ff ff       	jmp    80105e8b <alltraps>

80106b5a <vector174>:
.globl vector174
vector174:
  pushl $0
80106b5a:	6a 00                	push   $0x0
  pushl $174
80106b5c:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106b61:	e9 25 f3 ff ff       	jmp    80105e8b <alltraps>

80106b66 <vector175>:
.globl vector175
vector175:
  pushl $0
80106b66:	6a 00                	push   $0x0
  pushl $175
80106b68:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106b6d:	e9 19 f3 ff ff       	jmp    80105e8b <alltraps>

80106b72 <vector176>:
.globl vector176
vector176:
  pushl $0
80106b72:	6a 00                	push   $0x0
  pushl $176
80106b74:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106b79:	e9 0d f3 ff ff       	jmp    80105e8b <alltraps>

80106b7e <vector177>:
.globl vector177
vector177:
  pushl $0
80106b7e:	6a 00                	push   $0x0
  pushl $177
80106b80:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106b85:	e9 01 f3 ff ff       	jmp    80105e8b <alltraps>

80106b8a <vector178>:
.globl vector178
vector178:
  pushl $0
80106b8a:	6a 00                	push   $0x0
  pushl $178
80106b8c:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106b91:	e9 f5 f2 ff ff       	jmp    80105e8b <alltraps>

80106b96 <vector179>:
.globl vector179
vector179:
  pushl $0
80106b96:	6a 00                	push   $0x0
  pushl $179
80106b98:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106b9d:	e9 e9 f2 ff ff       	jmp    80105e8b <alltraps>

80106ba2 <vector180>:
.globl vector180
vector180:
  pushl $0
80106ba2:	6a 00                	push   $0x0
  pushl $180
80106ba4:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106ba9:	e9 dd f2 ff ff       	jmp    80105e8b <alltraps>

80106bae <vector181>:
.globl vector181
vector181:
  pushl $0
80106bae:	6a 00                	push   $0x0
  pushl $181
80106bb0:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106bb5:	e9 d1 f2 ff ff       	jmp    80105e8b <alltraps>

80106bba <vector182>:
.globl vector182
vector182:
  pushl $0
80106bba:	6a 00                	push   $0x0
  pushl $182
80106bbc:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106bc1:	e9 c5 f2 ff ff       	jmp    80105e8b <alltraps>

80106bc6 <vector183>:
.globl vector183
vector183:
  pushl $0
80106bc6:	6a 00                	push   $0x0
  pushl $183
80106bc8:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106bcd:	e9 b9 f2 ff ff       	jmp    80105e8b <alltraps>

80106bd2 <vector184>:
.globl vector184
vector184:
  pushl $0
80106bd2:	6a 00                	push   $0x0
  pushl $184
80106bd4:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106bd9:	e9 ad f2 ff ff       	jmp    80105e8b <alltraps>

80106bde <vector185>:
.globl vector185
vector185:
  pushl $0
80106bde:	6a 00                	push   $0x0
  pushl $185
80106be0:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106be5:	e9 a1 f2 ff ff       	jmp    80105e8b <alltraps>

80106bea <vector186>:
.globl vector186
vector186:
  pushl $0
80106bea:	6a 00                	push   $0x0
  pushl $186
80106bec:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106bf1:	e9 95 f2 ff ff       	jmp    80105e8b <alltraps>

80106bf6 <vector187>:
.globl vector187
vector187:
  pushl $0
80106bf6:	6a 00                	push   $0x0
  pushl $187
80106bf8:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106bfd:	e9 89 f2 ff ff       	jmp    80105e8b <alltraps>

80106c02 <vector188>:
.globl vector188
vector188:
  pushl $0
80106c02:	6a 00                	push   $0x0
  pushl $188
80106c04:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106c09:	e9 7d f2 ff ff       	jmp    80105e8b <alltraps>

80106c0e <vector189>:
.globl vector189
vector189:
  pushl $0
80106c0e:	6a 00                	push   $0x0
  pushl $189
80106c10:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106c15:	e9 71 f2 ff ff       	jmp    80105e8b <alltraps>

80106c1a <vector190>:
.globl vector190
vector190:
  pushl $0
80106c1a:	6a 00                	push   $0x0
  pushl $190
80106c1c:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106c21:	e9 65 f2 ff ff       	jmp    80105e8b <alltraps>

80106c26 <vector191>:
.globl vector191
vector191:
  pushl $0
80106c26:	6a 00                	push   $0x0
  pushl $191
80106c28:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106c2d:	e9 59 f2 ff ff       	jmp    80105e8b <alltraps>

80106c32 <vector192>:
.globl vector192
vector192:
  pushl $0
80106c32:	6a 00                	push   $0x0
  pushl $192
80106c34:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106c39:	e9 4d f2 ff ff       	jmp    80105e8b <alltraps>

80106c3e <vector193>:
.globl vector193
vector193:
  pushl $0
80106c3e:	6a 00                	push   $0x0
  pushl $193
80106c40:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106c45:	e9 41 f2 ff ff       	jmp    80105e8b <alltraps>

80106c4a <vector194>:
.globl vector194
vector194:
  pushl $0
80106c4a:	6a 00                	push   $0x0
  pushl $194
80106c4c:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106c51:	e9 35 f2 ff ff       	jmp    80105e8b <alltraps>

80106c56 <vector195>:
.globl vector195
vector195:
  pushl $0
80106c56:	6a 00                	push   $0x0
  pushl $195
80106c58:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106c5d:	e9 29 f2 ff ff       	jmp    80105e8b <alltraps>

80106c62 <vector196>:
.globl vector196
vector196:
  pushl $0
80106c62:	6a 00                	push   $0x0
  pushl $196
80106c64:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106c69:	e9 1d f2 ff ff       	jmp    80105e8b <alltraps>

80106c6e <vector197>:
.globl vector197
vector197:
  pushl $0
80106c6e:	6a 00                	push   $0x0
  pushl $197
80106c70:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106c75:	e9 11 f2 ff ff       	jmp    80105e8b <alltraps>

80106c7a <vector198>:
.globl vector198
vector198:
  pushl $0
80106c7a:	6a 00                	push   $0x0
  pushl $198
80106c7c:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106c81:	e9 05 f2 ff ff       	jmp    80105e8b <alltraps>

80106c86 <vector199>:
.globl vector199
vector199:
  pushl $0
80106c86:	6a 00                	push   $0x0
  pushl $199
80106c88:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106c8d:	e9 f9 f1 ff ff       	jmp    80105e8b <alltraps>

80106c92 <vector200>:
.globl vector200
vector200:
  pushl $0
80106c92:	6a 00                	push   $0x0
  pushl $200
80106c94:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106c99:	e9 ed f1 ff ff       	jmp    80105e8b <alltraps>

80106c9e <vector201>:
.globl vector201
vector201:
  pushl $0
80106c9e:	6a 00                	push   $0x0
  pushl $201
80106ca0:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80106ca5:	e9 e1 f1 ff ff       	jmp    80105e8b <alltraps>

80106caa <vector202>:
.globl vector202
vector202:
  pushl $0
80106caa:	6a 00                	push   $0x0
  pushl $202
80106cac:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106cb1:	e9 d5 f1 ff ff       	jmp    80105e8b <alltraps>

80106cb6 <vector203>:
.globl vector203
vector203:
  pushl $0
80106cb6:	6a 00                	push   $0x0
  pushl $203
80106cb8:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106cbd:	e9 c9 f1 ff ff       	jmp    80105e8b <alltraps>

80106cc2 <vector204>:
.globl vector204
vector204:
  pushl $0
80106cc2:	6a 00                	push   $0x0
  pushl $204
80106cc4:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106cc9:	e9 bd f1 ff ff       	jmp    80105e8b <alltraps>

80106cce <vector205>:
.globl vector205
vector205:
  pushl $0
80106cce:	6a 00                	push   $0x0
  pushl $205
80106cd0:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106cd5:	e9 b1 f1 ff ff       	jmp    80105e8b <alltraps>

80106cda <vector206>:
.globl vector206
vector206:
  pushl $0
80106cda:	6a 00                	push   $0x0
  pushl $206
80106cdc:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106ce1:	e9 a5 f1 ff ff       	jmp    80105e8b <alltraps>

80106ce6 <vector207>:
.globl vector207
vector207:
  pushl $0
80106ce6:	6a 00                	push   $0x0
  pushl $207
80106ce8:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106ced:	e9 99 f1 ff ff       	jmp    80105e8b <alltraps>

80106cf2 <vector208>:
.globl vector208
vector208:
  pushl $0
80106cf2:	6a 00                	push   $0x0
  pushl $208
80106cf4:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106cf9:	e9 8d f1 ff ff       	jmp    80105e8b <alltraps>

80106cfe <vector209>:
.globl vector209
vector209:
  pushl $0
80106cfe:	6a 00                	push   $0x0
  pushl $209
80106d00:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106d05:	e9 81 f1 ff ff       	jmp    80105e8b <alltraps>

80106d0a <vector210>:
.globl vector210
vector210:
  pushl $0
80106d0a:	6a 00                	push   $0x0
  pushl $210
80106d0c:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106d11:	e9 75 f1 ff ff       	jmp    80105e8b <alltraps>

80106d16 <vector211>:
.globl vector211
vector211:
  pushl $0
80106d16:	6a 00                	push   $0x0
  pushl $211
80106d18:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106d1d:	e9 69 f1 ff ff       	jmp    80105e8b <alltraps>

80106d22 <vector212>:
.globl vector212
vector212:
  pushl $0
80106d22:	6a 00                	push   $0x0
  pushl $212
80106d24:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106d29:	e9 5d f1 ff ff       	jmp    80105e8b <alltraps>

80106d2e <vector213>:
.globl vector213
vector213:
  pushl $0
80106d2e:	6a 00                	push   $0x0
  pushl $213
80106d30:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80106d35:	e9 51 f1 ff ff       	jmp    80105e8b <alltraps>

80106d3a <vector214>:
.globl vector214
vector214:
  pushl $0
80106d3a:	6a 00                	push   $0x0
  pushl $214
80106d3c:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106d41:	e9 45 f1 ff ff       	jmp    80105e8b <alltraps>

80106d46 <vector215>:
.globl vector215
vector215:
  pushl $0
80106d46:	6a 00                	push   $0x0
  pushl $215
80106d48:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106d4d:	e9 39 f1 ff ff       	jmp    80105e8b <alltraps>

80106d52 <vector216>:
.globl vector216
vector216:
  pushl $0
80106d52:	6a 00                	push   $0x0
  pushl $216
80106d54:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106d59:	e9 2d f1 ff ff       	jmp    80105e8b <alltraps>

80106d5e <vector217>:
.globl vector217
vector217:
  pushl $0
80106d5e:	6a 00                	push   $0x0
  pushl $217
80106d60:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80106d65:	e9 21 f1 ff ff       	jmp    80105e8b <alltraps>

80106d6a <vector218>:
.globl vector218
vector218:
  pushl $0
80106d6a:	6a 00                	push   $0x0
  pushl $218
80106d6c:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106d71:	e9 15 f1 ff ff       	jmp    80105e8b <alltraps>

80106d76 <vector219>:
.globl vector219
vector219:
  pushl $0
80106d76:	6a 00                	push   $0x0
  pushl $219
80106d78:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106d7d:	e9 09 f1 ff ff       	jmp    80105e8b <alltraps>

80106d82 <vector220>:
.globl vector220
vector220:
  pushl $0
80106d82:	6a 00                	push   $0x0
  pushl $220
80106d84:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80106d89:	e9 fd f0 ff ff       	jmp    80105e8b <alltraps>

80106d8e <vector221>:
.globl vector221
vector221:
  pushl $0
80106d8e:	6a 00                	push   $0x0
  pushl $221
80106d90:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80106d95:	e9 f1 f0 ff ff       	jmp    80105e8b <alltraps>

80106d9a <vector222>:
.globl vector222
vector222:
  pushl $0
80106d9a:	6a 00                	push   $0x0
  pushl $222
80106d9c:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80106da1:	e9 e5 f0 ff ff       	jmp    80105e8b <alltraps>

80106da6 <vector223>:
.globl vector223
vector223:
  pushl $0
80106da6:	6a 00                	push   $0x0
  pushl $223
80106da8:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106dad:	e9 d9 f0 ff ff       	jmp    80105e8b <alltraps>

80106db2 <vector224>:
.globl vector224
vector224:
  pushl $0
80106db2:	6a 00                	push   $0x0
  pushl $224
80106db4:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80106db9:	e9 cd f0 ff ff       	jmp    80105e8b <alltraps>

80106dbe <vector225>:
.globl vector225
vector225:
  pushl $0
80106dbe:	6a 00                	push   $0x0
  pushl $225
80106dc0:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80106dc5:	e9 c1 f0 ff ff       	jmp    80105e8b <alltraps>

80106dca <vector226>:
.globl vector226
vector226:
  pushl $0
80106dca:	6a 00                	push   $0x0
  pushl $226
80106dcc:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80106dd1:	e9 b5 f0 ff ff       	jmp    80105e8b <alltraps>

80106dd6 <vector227>:
.globl vector227
vector227:
  pushl $0
80106dd6:	6a 00                	push   $0x0
  pushl $227
80106dd8:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80106ddd:	e9 a9 f0 ff ff       	jmp    80105e8b <alltraps>

80106de2 <vector228>:
.globl vector228
vector228:
  pushl $0
80106de2:	6a 00                	push   $0x0
  pushl $228
80106de4:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80106de9:	e9 9d f0 ff ff       	jmp    80105e8b <alltraps>

80106dee <vector229>:
.globl vector229
vector229:
  pushl $0
80106dee:	6a 00                	push   $0x0
  pushl $229
80106df0:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80106df5:	e9 91 f0 ff ff       	jmp    80105e8b <alltraps>

80106dfa <vector230>:
.globl vector230
vector230:
  pushl $0
80106dfa:	6a 00                	push   $0x0
  pushl $230
80106dfc:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80106e01:	e9 85 f0 ff ff       	jmp    80105e8b <alltraps>

80106e06 <vector231>:
.globl vector231
vector231:
  pushl $0
80106e06:	6a 00                	push   $0x0
  pushl $231
80106e08:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80106e0d:	e9 79 f0 ff ff       	jmp    80105e8b <alltraps>

80106e12 <vector232>:
.globl vector232
vector232:
  pushl $0
80106e12:	6a 00                	push   $0x0
  pushl $232
80106e14:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80106e19:	e9 6d f0 ff ff       	jmp    80105e8b <alltraps>

80106e1e <vector233>:
.globl vector233
vector233:
  pushl $0
80106e1e:	6a 00                	push   $0x0
  pushl $233
80106e20:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80106e25:	e9 61 f0 ff ff       	jmp    80105e8b <alltraps>

80106e2a <vector234>:
.globl vector234
vector234:
  pushl $0
80106e2a:	6a 00                	push   $0x0
  pushl $234
80106e2c:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80106e31:	e9 55 f0 ff ff       	jmp    80105e8b <alltraps>

80106e36 <vector235>:
.globl vector235
vector235:
  pushl $0
80106e36:	6a 00                	push   $0x0
  pushl $235
80106e38:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80106e3d:	e9 49 f0 ff ff       	jmp    80105e8b <alltraps>

80106e42 <vector236>:
.globl vector236
vector236:
  pushl $0
80106e42:	6a 00                	push   $0x0
  pushl $236
80106e44:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80106e49:	e9 3d f0 ff ff       	jmp    80105e8b <alltraps>

80106e4e <vector237>:
.globl vector237
vector237:
  pushl $0
80106e4e:	6a 00                	push   $0x0
  pushl $237
80106e50:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80106e55:	e9 31 f0 ff ff       	jmp    80105e8b <alltraps>

80106e5a <vector238>:
.globl vector238
vector238:
  pushl $0
80106e5a:	6a 00                	push   $0x0
  pushl $238
80106e5c:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80106e61:	e9 25 f0 ff ff       	jmp    80105e8b <alltraps>

80106e66 <vector239>:
.globl vector239
vector239:
  pushl $0
80106e66:	6a 00                	push   $0x0
  pushl $239
80106e68:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80106e6d:	e9 19 f0 ff ff       	jmp    80105e8b <alltraps>

80106e72 <vector240>:
.globl vector240
vector240:
  pushl $0
80106e72:	6a 00                	push   $0x0
  pushl $240
80106e74:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80106e79:	e9 0d f0 ff ff       	jmp    80105e8b <alltraps>

80106e7e <vector241>:
.globl vector241
vector241:
  pushl $0
80106e7e:	6a 00                	push   $0x0
  pushl $241
80106e80:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80106e85:	e9 01 f0 ff ff       	jmp    80105e8b <alltraps>

80106e8a <vector242>:
.globl vector242
vector242:
  pushl $0
80106e8a:	6a 00                	push   $0x0
  pushl $242
80106e8c:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80106e91:	e9 f5 ef ff ff       	jmp    80105e8b <alltraps>

80106e96 <vector243>:
.globl vector243
vector243:
  pushl $0
80106e96:	6a 00                	push   $0x0
  pushl $243
80106e98:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80106e9d:	e9 e9 ef ff ff       	jmp    80105e8b <alltraps>

80106ea2 <vector244>:
.globl vector244
vector244:
  pushl $0
80106ea2:	6a 00                	push   $0x0
  pushl $244
80106ea4:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80106ea9:	e9 dd ef ff ff       	jmp    80105e8b <alltraps>

80106eae <vector245>:
.globl vector245
vector245:
  pushl $0
80106eae:	6a 00                	push   $0x0
  pushl $245
80106eb0:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80106eb5:	e9 d1 ef ff ff       	jmp    80105e8b <alltraps>

80106eba <vector246>:
.globl vector246
vector246:
  pushl $0
80106eba:	6a 00                	push   $0x0
  pushl $246
80106ebc:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80106ec1:	e9 c5 ef ff ff       	jmp    80105e8b <alltraps>

80106ec6 <vector247>:
.globl vector247
vector247:
  pushl $0
80106ec6:	6a 00                	push   $0x0
  pushl $247
80106ec8:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80106ecd:	e9 b9 ef ff ff       	jmp    80105e8b <alltraps>

80106ed2 <vector248>:
.globl vector248
vector248:
  pushl $0
80106ed2:	6a 00                	push   $0x0
  pushl $248
80106ed4:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80106ed9:	e9 ad ef ff ff       	jmp    80105e8b <alltraps>

80106ede <vector249>:
.globl vector249
vector249:
  pushl $0
80106ede:	6a 00                	push   $0x0
  pushl $249
80106ee0:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80106ee5:	e9 a1 ef ff ff       	jmp    80105e8b <alltraps>

80106eea <vector250>:
.globl vector250
vector250:
  pushl $0
80106eea:	6a 00                	push   $0x0
  pushl $250
80106eec:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80106ef1:	e9 95 ef ff ff       	jmp    80105e8b <alltraps>

80106ef6 <vector251>:
.globl vector251
vector251:
  pushl $0
80106ef6:	6a 00                	push   $0x0
  pushl $251
80106ef8:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80106efd:	e9 89 ef ff ff       	jmp    80105e8b <alltraps>

80106f02 <vector252>:
.globl vector252
vector252:
  pushl $0
80106f02:	6a 00                	push   $0x0
  pushl $252
80106f04:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80106f09:	e9 7d ef ff ff       	jmp    80105e8b <alltraps>

80106f0e <vector253>:
.globl vector253
vector253:
  pushl $0
80106f0e:	6a 00                	push   $0x0
  pushl $253
80106f10:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80106f15:	e9 71 ef ff ff       	jmp    80105e8b <alltraps>

80106f1a <vector254>:
.globl vector254
vector254:
  pushl $0
80106f1a:	6a 00                	push   $0x0
  pushl $254
80106f1c:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80106f21:	e9 65 ef ff ff       	jmp    80105e8b <alltraps>

80106f26 <vector255>:
.globl vector255
vector255:
  pushl $0
80106f26:	6a 00                	push   $0x0
  pushl $255
80106f28:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80106f2d:	e9 59 ef ff ff       	jmp    80105e8b <alltraps>

80106f32 <lgdt>:
{
80106f32:	55                   	push   %ebp
80106f33:	89 e5                	mov    %esp,%ebp
80106f35:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106f38:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f3b:	83 e8 01             	sub    $0x1,%eax
80106f3e:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106f42:	8b 45 08             	mov    0x8(%ebp),%eax
80106f45:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106f49:	8b 45 08             	mov    0x8(%ebp),%eax
80106f4c:	c1 e8 10             	shr    $0x10,%eax
80106f4f:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80106f53:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106f56:	0f 01 10             	lgdtl  (%eax)
}
80106f59:	90                   	nop
80106f5a:	c9                   	leave  
80106f5b:	c3                   	ret    

80106f5c <ltr>:
{
80106f5c:	55                   	push   %ebp
80106f5d:	89 e5                	mov    %esp,%ebp
80106f5f:	83 ec 04             	sub    $0x4,%esp
80106f62:	8b 45 08             	mov    0x8(%ebp),%eax
80106f65:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80106f69:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80106f6d:	0f 00 d8             	ltr    %ax
}
80106f70:	90                   	nop
80106f71:	c9                   	leave  
80106f72:	c3                   	ret    

80106f73 <lcr3>:

static inline void
lcr3(uint val)
{
80106f73:	55                   	push   %ebp
80106f74:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106f76:	8b 45 08             	mov    0x8(%ebp),%eax
80106f79:	0f 22 d8             	mov    %eax,%cr3
}
80106f7c:	90                   	nop
80106f7d:	5d                   	pop    %ebp
80106f7e:	c3                   	ret    

80106f7f <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80106f7f:	55                   	push   %ebp
80106f80:	89 e5                	mov    %esp,%ebp
80106f82:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80106f85:	e8 13 ca ff ff       	call   8010399d <cpuid>
80106f8a:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80106f90:	05 80 69 19 80       	add    $0x80196980,%eax
80106f95:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80106f98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f9b:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80106fa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fa4:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80106faa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fad:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80106fb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fb4:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106fb8:	83 e2 f0             	and    $0xfffffff0,%edx
80106fbb:	83 ca 0a             	or     $0xa,%edx
80106fbe:	88 50 7d             	mov    %dl,0x7d(%eax)
80106fc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fc4:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106fc8:	83 ca 10             	or     $0x10,%edx
80106fcb:	88 50 7d             	mov    %dl,0x7d(%eax)
80106fce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fd1:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106fd5:	83 e2 9f             	and    $0xffffff9f,%edx
80106fd8:	88 50 7d             	mov    %dl,0x7d(%eax)
80106fdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fde:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106fe2:	83 ca 80             	or     $0xffffff80,%edx
80106fe5:	88 50 7d             	mov    %dl,0x7d(%eax)
80106fe8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106feb:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106fef:	83 ca 0f             	or     $0xf,%edx
80106ff2:	88 50 7e             	mov    %dl,0x7e(%eax)
80106ff5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ff8:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106ffc:	83 e2 ef             	and    $0xffffffef,%edx
80106fff:	88 50 7e             	mov    %dl,0x7e(%eax)
80107002:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107005:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107009:	83 e2 df             	and    $0xffffffdf,%edx
8010700c:	88 50 7e             	mov    %dl,0x7e(%eax)
8010700f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107012:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107016:	83 ca 40             	or     $0x40,%edx
80107019:	88 50 7e             	mov    %dl,0x7e(%eax)
8010701c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010701f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107023:	83 ca 80             	or     $0xffffff80,%edx
80107026:	88 50 7e             	mov    %dl,0x7e(%eax)
80107029:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010702c:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107030:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107033:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010703a:	ff ff 
8010703c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010703f:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107046:	00 00 
80107048:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010704b:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107052:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107055:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010705c:	83 e2 f0             	and    $0xfffffff0,%edx
8010705f:	83 ca 02             	or     $0x2,%edx
80107062:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107068:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010706b:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107072:	83 ca 10             	or     $0x10,%edx
80107075:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010707b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010707e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107085:	83 e2 9f             	and    $0xffffff9f,%edx
80107088:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010708e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107091:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107098:	83 ca 80             	or     $0xffffff80,%edx
8010709b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801070a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070a4:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801070ab:	83 ca 0f             	or     $0xf,%edx
801070ae:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801070b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070b7:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801070be:	83 e2 ef             	and    $0xffffffef,%edx
801070c1:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801070c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070ca:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801070d1:	83 e2 df             	and    $0xffffffdf,%edx
801070d4:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801070da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070dd:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801070e4:	83 ca 40             	or     $0x40,%edx
801070e7:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801070ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070f0:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801070f7:	83 ca 80             	or     $0xffffff80,%edx
801070fa:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107100:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107103:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010710a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010710d:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107114:	ff ff 
80107116:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107119:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107120:	00 00 
80107122:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107125:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
8010712c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010712f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107136:	83 e2 f0             	and    $0xfffffff0,%edx
80107139:	83 ca 0a             	or     $0xa,%edx
8010713c:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107145:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010714c:	83 ca 10             	or     $0x10,%edx
8010714f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107155:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107158:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010715f:	83 ca 60             	or     $0x60,%edx
80107162:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107168:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010716b:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107172:	83 ca 80             	or     $0xffffff80,%edx
80107175:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010717b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010717e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107185:	83 ca 0f             	or     $0xf,%edx
80107188:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010718e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107191:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107198:	83 e2 ef             	and    $0xffffffef,%edx
8010719b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801071a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071a4:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801071ab:	83 e2 df             	and    $0xffffffdf,%edx
801071ae:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801071b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071b7:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801071be:	83 ca 40             	or     $0x40,%edx
801071c1:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801071c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071ca:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801071d1:	83 ca 80             	or     $0xffffff80,%edx
801071d4:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801071da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071dd:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801071e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071e7:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801071ee:	ff ff 
801071f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071f3:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801071fa:	00 00 
801071fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071ff:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107206:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107209:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107210:	83 e2 f0             	and    $0xfffffff0,%edx
80107213:	83 ca 02             	or     $0x2,%edx
80107216:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010721c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010721f:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107226:	83 ca 10             	or     $0x10,%edx
80107229:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010722f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107232:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107239:	83 ca 60             	or     $0x60,%edx
8010723c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107242:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107245:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010724c:	83 ca 80             	or     $0xffffff80,%edx
8010724f:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107255:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107258:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010725f:	83 ca 0f             	or     $0xf,%edx
80107262:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107268:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010726b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107272:	83 e2 ef             	and    $0xffffffef,%edx
80107275:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010727b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010727e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107285:	83 e2 df             	and    $0xffffffdf,%edx
80107288:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010728e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107291:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107298:	83 ca 40             	or     $0x40,%edx
8010729b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801072a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072a4:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801072ab:	83 ca 80             	or     $0xffffff80,%edx
801072ae:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801072b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072b7:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801072be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072c1:	83 c0 70             	add    $0x70,%eax
801072c4:	83 ec 08             	sub    $0x8,%esp
801072c7:	6a 30                	push   $0x30
801072c9:	50                   	push   %eax
801072ca:	e8 63 fc ff ff       	call   80106f32 <lgdt>
801072cf:	83 c4 10             	add    $0x10,%esp
}
801072d2:	90                   	nop
801072d3:	c9                   	leave  
801072d4:	c3                   	ret    

801072d5 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801072d5:	55                   	push   %ebp
801072d6:	89 e5                	mov    %esp,%ebp
801072d8:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801072db:	8b 45 0c             	mov    0xc(%ebp),%eax
801072de:	c1 e8 16             	shr    $0x16,%eax
801072e1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801072e8:	8b 45 08             	mov    0x8(%ebp),%eax
801072eb:	01 d0                	add    %edx,%eax
801072ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801072f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801072f3:	8b 00                	mov    (%eax),%eax
801072f5:	83 e0 01             	and    $0x1,%eax
801072f8:	85 c0                	test   %eax,%eax
801072fa:	74 14                	je     80107310 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801072fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801072ff:	8b 00                	mov    (%eax),%eax
80107301:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107306:	05 00 00 00 80       	add    $0x80000000,%eax
8010730b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010730e:	eb 42                	jmp    80107352 <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107310:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107314:	74 0e                	je     80107324 <walkpgdir+0x4f>
80107316:	e8 85 b4 ff ff       	call   801027a0 <kalloc>
8010731b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010731e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107322:	75 07                	jne    8010732b <walkpgdir+0x56>
      return 0;
80107324:	b8 00 00 00 00       	mov    $0x0,%eax
80107329:	eb 3e                	jmp    80107369 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
8010732b:	83 ec 04             	sub    $0x4,%esp
8010732e:	68 00 10 00 00       	push   $0x1000
80107333:	6a 00                	push   $0x0
80107335:	ff 75 f4             	push   -0xc(%ebp)
80107338:	e8 a5 d7 ff ff       	call   80104ae2 <memset>
8010733d:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107340:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107343:	05 00 00 00 80       	add    $0x80000000,%eax
80107348:	83 c8 07             	or     $0x7,%eax
8010734b:	89 c2                	mov    %eax,%edx
8010734d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107350:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107352:	8b 45 0c             	mov    0xc(%ebp),%eax
80107355:	c1 e8 0c             	shr    $0xc,%eax
80107358:	25 ff 03 00 00       	and    $0x3ff,%eax
8010735d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107364:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107367:	01 d0                	add    %edx,%eax
}
80107369:	c9                   	leave  
8010736a:	c3                   	ret    

8010736b <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010736b:	55                   	push   %ebp
8010736c:	89 e5                	mov    %esp,%ebp
8010736e:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107371:	8b 45 0c             	mov    0xc(%ebp),%eax
80107374:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107379:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010737c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010737f:	8b 45 10             	mov    0x10(%ebp),%eax
80107382:	01 d0                	add    %edx,%eax
80107384:	83 e8 01             	sub    $0x1,%eax
80107387:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010738c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010738f:	83 ec 04             	sub    $0x4,%esp
80107392:	6a 01                	push   $0x1
80107394:	ff 75 f4             	push   -0xc(%ebp)
80107397:	ff 75 08             	push   0x8(%ebp)
8010739a:	e8 36 ff ff ff       	call   801072d5 <walkpgdir>
8010739f:	83 c4 10             	add    $0x10,%esp
801073a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
801073a5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801073a9:	75 07                	jne    801073b2 <mappages+0x47>
      return -1;
801073ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073b0:	eb 47                	jmp    801073f9 <mappages+0x8e>
    if(*pte & PTE_P)
801073b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801073b5:	8b 00                	mov    (%eax),%eax
801073b7:	83 e0 01             	and    $0x1,%eax
801073ba:	85 c0                	test   %eax,%eax
801073bc:	74 0d                	je     801073cb <mappages+0x60>
      panic("remap");
801073be:	83 ec 0c             	sub    $0xc,%esp
801073c1:	68 e0 a6 10 80       	push   $0x8010a6e0
801073c6:	e8 de 91 ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
801073cb:	8b 45 18             	mov    0x18(%ebp),%eax
801073ce:	0b 45 14             	or     0x14(%ebp),%eax
801073d1:	83 c8 01             	or     $0x1,%eax
801073d4:	89 c2                	mov    %eax,%edx
801073d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801073d9:	89 10                	mov    %edx,(%eax)
    if(a == last)
801073db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073de:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801073e1:	74 10                	je     801073f3 <mappages+0x88>
      break;
    a += PGSIZE;
801073e3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801073ea:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801073f1:	eb 9c                	jmp    8010738f <mappages+0x24>
      break;
801073f3:	90                   	nop
  }
  return 0;
801073f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801073f9:	c9                   	leave  
801073fa:	c3                   	ret    

801073fb <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801073fb:	55                   	push   %ebp
801073fc:	89 e5                	mov    %esp,%ebp
801073fe:	53                   	push   %ebx
801073ff:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
80107402:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80107409:	8b 15 50 6c 19 80    	mov    0x80196c50,%edx
8010740f:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
80107414:	29 d0                	sub    %edx,%eax
80107416:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107419:	a1 48 6c 19 80       	mov    0x80196c48,%eax
8010741e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107421:	8b 15 48 6c 19 80    	mov    0x80196c48,%edx
80107427:	a1 50 6c 19 80       	mov    0x80196c50,%eax
8010742c:	01 d0                	add    %edx,%eax
8010742e:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107431:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107438:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010743b:	83 c0 30             	add    $0x30,%eax
8010743e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107441:	89 10                	mov    %edx,(%eax)
80107443:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107446:	89 50 04             	mov    %edx,0x4(%eax)
80107449:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010744c:	89 50 08             	mov    %edx,0x8(%eax)
8010744f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107452:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107455:	e8 46 b3 ff ff       	call   801027a0 <kalloc>
8010745a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010745d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107461:	75 07                	jne    8010746a <setupkvm+0x6f>
    return 0;
80107463:	b8 00 00 00 00       	mov    $0x0,%eax
80107468:	eb 78                	jmp    801074e2 <setupkvm+0xe7>
  }
  memset(pgdir, 0, PGSIZE);
8010746a:	83 ec 04             	sub    $0x4,%esp
8010746d:	68 00 10 00 00       	push   $0x1000
80107472:	6a 00                	push   $0x0
80107474:	ff 75 f0             	push   -0x10(%ebp)
80107477:	e8 66 d6 ff ff       	call   80104ae2 <memset>
8010747c:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010747f:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
80107486:	eb 4e                	jmp    801074d6 <setupkvm+0xdb>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107488:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010748b:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
8010748e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107491:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107494:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107497:	8b 58 08             	mov    0x8(%eax),%ebx
8010749a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010749d:	8b 40 04             	mov    0x4(%eax),%eax
801074a0:	29 c3                	sub    %eax,%ebx
801074a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074a5:	8b 00                	mov    (%eax),%eax
801074a7:	83 ec 0c             	sub    $0xc,%esp
801074aa:	51                   	push   %ecx
801074ab:	52                   	push   %edx
801074ac:	53                   	push   %ebx
801074ad:	50                   	push   %eax
801074ae:	ff 75 f0             	push   -0x10(%ebp)
801074b1:	e8 b5 fe ff ff       	call   8010736b <mappages>
801074b6:	83 c4 20             	add    $0x20,%esp
801074b9:	85 c0                	test   %eax,%eax
801074bb:	79 15                	jns    801074d2 <setupkvm+0xd7>
      freevm(pgdir);
801074bd:	83 ec 0c             	sub    $0xc,%esp
801074c0:	ff 75 f0             	push   -0x10(%ebp)
801074c3:	e8 f5 04 00 00       	call   801079bd <freevm>
801074c8:	83 c4 10             	add    $0x10,%esp
      return 0;
801074cb:	b8 00 00 00 00       	mov    $0x0,%eax
801074d0:	eb 10                	jmp    801074e2 <setupkvm+0xe7>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801074d2:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801074d6:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
801074dd:	72 a9                	jb     80107488 <setupkvm+0x8d>
    }
  return pgdir;
801074df:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801074e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801074e5:	c9                   	leave  
801074e6:	c3                   	ret    

801074e7 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801074e7:	55                   	push   %ebp
801074e8:	89 e5                	mov    %esp,%ebp
801074ea:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801074ed:	e8 09 ff ff ff       	call   801073fb <setupkvm>
801074f2:	a3 7c 69 19 80       	mov    %eax,0x8019697c
  switchkvm();
801074f7:	e8 03 00 00 00       	call   801074ff <switchkvm>
}
801074fc:	90                   	nop
801074fd:	c9                   	leave  
801074fe:	c3                   	ret    

801074ff <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801074ff:	55                   	push   %ebp
80107500:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107502:	a1 7c 69 19 80       	mov    0x8019697c,%eax
80107507:	05 00 00 00 80       	add    $0x80000000,%eax
8010750c:	50                   	push   %eax
8010750d:	e8 61 fa ff ff       	call   80106f73 <lcr3>
80107512:	83 c4 04             	add    $0x4,%esp
}
80107515:	90                   	nop
80107516:	c9                   	leave  
80107517:	c3                   	ret    

80107518 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107518:	55                   	push   %ebp
80107519:	89 e5                	mov    %esp,%ebp
8010751b:	56                   	push   %esi
8010751c:	53                   	push   %ebx
8010751d:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107520:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107524:	75 0d                	jne    80107533 <switchuvm+0x1b>
    panic("switchuvm: no process");
80107526:	83 ec 0c             	sub    $0xc,%esp
80107529:	68 e6 a6 10 80       	push   $0x8010a6e6
8010752e:	e8 76 90 ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
80107533:	8b 45 08             	mov    0x8(%ebp),%eax
80107536:	8b 40 08             	mov    0x8(%eax),%eax
80107539:	85 c0                	test   %eax,%eax
8010753b:	75 0d                	jne    8010754a <switchuvm+0x32>
    panic("switchuvm: no kstack");
8010753d:	83 ec 0c             	sub    $0xc,%esp
80107540:	68 fc a6 10 80       	push   $0x8010a6fc
80107545:	e8 5f 90 ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
8010754a:	8b 45 08             	mov    0x8(%ebp),%eax
8010754d:	8b 40 04             	mov    0x4(%eax),%eax
80107550:	85 c0                	test   %eax,%eax
80107552:	75 0d                	jne    80107561 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80107554:	83 ec 0c             	sub    $0xc,%esp
80107557:	68 11 a7 10 80       	push   $0x8010a711
8010755c:	e8 48 90 ff ff       	call   801005a9 <panic>

  pushcli();
80107561:	e8 71 d4 ff ff       	call   801049d7 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107566:	e8 4d c4 ff ff       	call   801039b8 <mycpu>
8010756b:	89 c3                	mov    %eax,%ebx
8010756d:	e8 46 c4 ff ff       	call   801039b8 <mycpu>
80107572:	83 c0 08             	add    $0x8,%eax
80107575:	89 c6                	mov    %eax,%esi
80107577:	e8 3c c4 ff ff       	call   801039b8 <mycpu>
8010757c:	83 c0 08             	add    $0x8,%eax
8010757f:	c1 e8 10             	shr    $0x10,%eax
80107582:	88 45 f7             	mov    %al,-0x9(%ebp)
80107585:	e8 2e c4 ff ff       	call   801039b8 <mycpu>
8010758a:	83 c0 08             	add    $0x8,%eax
8010758d:	c1 e8 18             	shr    $0x18,%eax
80107590:	89 c2                	mov    %eax,%edx
80107592:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107599:	67 00 
8010759b:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
801075a2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
801075a6:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
801075ac:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801075b3:	83 e0 f0             	and    $0xfffffff0,%eax
801075b6:	83 c8 09             	or     $0x9,%eax
801075b9:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801075bf:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801075c6:	83 c8 10             	or     $0x10,%eax
801075c9:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801075cf:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801075d6:	83 e0 9f             	and    $0xffffff9f,%eax
801075d9:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801075df:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801075e6:	83 c8 80             	or     $0xffffff80,%eax
801075e9:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801075ef:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801075f6:	83 e0 f0             	and    $0xfffffff0,%eax
801075f9:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801075ff:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107606:	83 e0 ef             	and    $0xffffffef,%eax
80107609:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010760f:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107616:	83 e0 df             	and    $0xffffffdf,%eax
80107619:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010761f:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107626:	83 c8 40             	or     $0x40,%eax
80107629:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010762f:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107636:	83 e0 7f             	and    $0x7f,%eax
80107639:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010763f:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107645:	e8 6e c3 ff ff       	call   801039b8 <mycpu>
8010764a:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107651:	83 e2 ef             	and    $0xffffffef,%edx
80107654:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
8010765a:	e8 59 c3 ff ff       	call   801039b8 <mycpu>
8010765f:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107665:	8b 45 08             	mov    0x8(%ebp),%eax
80107668:	8b 40 08             	mov    0x8(%eax),%eax
8010766b:	89 c3                	mov    %eax,%ebx
8010766d:	e8 46 c3 ff ff       	call   801039b8 <mycpu>
80107672:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107678:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
8010767b:	e8 38 c3 ff ff       	call   801039b8 <mycpu>
80107680:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107686:	83 ec 0c             	sub    $0xc,%esp
80107689:	6a 28                	push   $0x28
8010768b:	e8 cc f8 ff ff       	call   80106f5c <ltr>
80107690:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107693:	8b 45 08             	mov    0x8(%ebp),%eax
80107696:	8b 40 04             	mov    0x4(%eax),%eax
80107699:	05 00 00 00 80       	add    $0x80000000,%eax
8010769e:	83 ec 0c             	sub    $0xc,%esp
801076a1:	50                   	push   %eax
801076a2:	e8 cc f8 ff ff       	call   80106f73 <lcr3>
801076a7:	83 c4 10             	add    $0x10,%esp
  popcli();
801076aa:	e8 75 d3 ff ff       	call   80104a24 <popcli>
}
801076af:	90                   	nop
801076b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
801076b3:	5b                   	pop    %ebx
801076b4:	5e                   	pop    %esi
801076b5:	5d                   	pop    %ebp
801076b6:	c3                   	ret    

801076b7 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801076b7:	55                   	push   %ebp
801076b8:	89 e5                	mov    %esp,%ebp
801076ba:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
801076bd:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801076c4:	76 0d                	jbe    801076d3 <inituvm+0x1c>
    panic("inituvm: more than a page");
801076c6:	83 ec 0c             	sub    $0xc,%esp
801076c9:	68 25 a7 10 80       	push   $0x8010a725
801076ce:	e8 d6 8e ff ff       	call   801005a9 <panic>
  mem = kalloc();
801076d3:	e8 c8 b0 ff ff       	call   801027a0 <kalloc>
801076d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801076db:	83 ec 04             	sub    $0x4,%esp
801076de:	68 00 10 00 00       	push   $0x1000
801076e3:	6a 00                	push   $0x0
801076e5:	ff 75 f4             	push   -0xc(%ebp)
801076e8:	e8 f5 d3 ff ff       	call   80104ae2 <memset>
801076ed:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801076f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076f3:	05 00 00 00 80       	add    $0x80000000,%eax
801076f8:	83 ec 0c             	sub    $0xc,%esp
801076fb:	6a 06                	push   $0x6
801076fd:	50                   	push   %eax
801076fe:	68 00 10 00 00       	push   $0x1000
80107703:	6a 00                	push   $0x0
80107705:	ff 75 08             	push   0x8(%ebp)
80107708:	e8 5e fc ff ff       	call   8010736b <mappages>
8010770d:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107710:	83 ec 04             	sub    $0x4,%esp
80107713:	ff 75 10             	push   0x10(%ebp)
80107716:	ff 75 0c             	push   0xc(%ebp)
80107719:	ff 75 f4             	push   -0xc(%ebp)
8010771c:	e8 80 d4 ff ff       	call   80104ba1 <memmove>
80107721:	83 c4 10             	add    $0x10,%esp
}
80107724:	90                   	nop
80107725:	c9                   	leave  
80107726:	c3                   	ret    

80107727 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107727:	55                   	push   %ebp
80107728:	89 e5                	mov    %esp,%ebp
8010772a:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
8010772d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107730:	25 ff 0f 00 00       	and    $0xfff,%eax
80107735:	85 c0                	test   %eax,%eax
80107737:	74 0d                	je     80107746 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107739:	83 ec 0c             	sub    $0xc,%esp
8010773c:	68 40 a7 10 80       	push   $0x8010a740
80107741:	e8 63 8e ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107746:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010774d:	e9 8f 00 00 00       	jmp    801077e1 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107752:	8b 55 0c             	mov    0xc(%ebp),%edx
80107755:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107758:	01 d0                	add    %edx,%eax
8010775a:	83 ec 04             	sub    $0x4,%esp
8010775d:	6a 00                	push   $0x0
8010775f:	50                   	push   %eax
80107760:	ff 75 08             	push   0x8(%ebp)
80107763:	e8 6d fb ff ff       	call   801072d5 <walkpgdir>
80107768:	83 c4 10             	add    $0x10,%esp
8010776b:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010776e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107772:	75 0d                	jne    80107781 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80107774:	83 ec 0c             	sub    $0xc,%esp
80107777:	68 63 a7 10 80       	push   $0x8010a763
8010777c:	e8 28 8e ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107781:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107784:	8b 00                	mov    (%eax),%eax
80107786:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010778b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
8010778e:	8b 45 18             	mov    0x18(%ebp),%eax
80107791:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107794:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107799:	77 0b                	ja     801077a6 <loaduvm+0x7f>
      n = sz - i;
8010779b:	8b 45 18             	mov    0x18(%ebp),%eax
8010779e:	2b 45 f4             	sub    -0xc(%ebp),%eax
801077a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801077a4:	eb 07                	jmp    801077ad <loaduvm+0x86>
    else
      n = PGSIZE;
801077a6:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
801077ad:	8b 55 14             	mov    0x14(%ebp),%edx
801077b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077b3:	01 d0                	add    %edx,%eax
801077b5:	8b 55 e8             	mov    -0x18(%ebp),%edx
801077b8:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801077be:	ff 75 f0             	push   -0x10(%ebp)
801077c1:	50                   	push   %eax
801077c2:	52                   	push   %edx
801077c3:	ff 75 10             	push   0x10(%ebp)
801077c6:	e8 0b a7 ff ff       	call   80101ed6 <readi>
801077cb:	83 c4 10             	add    $0x10,%esp
801077ce:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801077d1:	74 07                	je     801077da <loaduvm+0xb3>
      return -1;
801077d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801077d8:	eb 18                	jmp    801077f2 <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
801077da:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801077e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077e4:	3b 45 18             	cmp    0x18(%ebp),%eax
801077e7:	0f 82 65 ff ff ff    	jb     80107752 <loaduvm+0x2b>
  }
  return 0;
801077ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
801077f2:	c9                   	leave  
801077f3:	c3                   	ret    

801077f4 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801077f4:	55                   	push   %ebp
801077f5:	89 e5                	mov    %esp,%ebp
801077f7:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801077fa:	8b 45 10             	mov    0x10(%ebp),%eax
801077fd:	85 c0                	test   %eax,%eax
801077ff:	79 0a                	jns    8010780b <allocuvm+0x17>
    return 0;
80107801:	b8 00 00 00 00       	mov    $0x0,%eax
80107806:	e9 ec 00 00 00       	jmp    801078f7 <allocuvm+0x103>
  if(newsz < oldsz)
8010780b:	8b 45 10             	mov    0x10(%ebp),%eax
8010780e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107811:	73 08                	jae    8010781b <allocuvm+0x27>
    return oldsz;
80107813:	8b 45 0c             	mov    0xc(%ebp),%eax
80107816:	e9 dc 00 00 00       	jmp    801078f7 <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
8010781b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010781e:	05 ff 0f 00 00       	add    $0xfff,%eax
80107823:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107828:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
8010782b:	e9 b8 00 00 00       	jmp    801078e8 <allocuvm+0xf4>
    mem = kalloc();
80107830:	e8 6b af ff ff       	call   801027a0 <kalloc>
80107835:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107838:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010783c:	75 2e                	jne    8010786c <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
8010783e:	83 ec 0c             	sub    $0xc,%esp
80107841:	68 81 a7 10 80       	push   $0x8010a781
80107846:	e8 a9 8b ff ff       	call   801003f4 <cprintf>
8010784b:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
8010784e:	83 ec 04             	sub    $0x4,%esp
80107851:	ff 75 0c             	push   0xc(%ebp)
80107854:	ff 75 10             	push   0x10(%ebp)
80107857:	ff 75 08             	push   0x8(%ebp)
8010785a:	e8 9a 00 00 00       	call   801078f9 <deallocuvm>
8010785f:	83 c4 10             	add    $0x10,%esp
      return 0;
80107862:	b8 00 00 00 00       	mov    $0x0,%eax
80107867:	e9 8b 00 00 00       	jmp    801078f7 <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
8010786c:	83 ec 04             	sub    $0x4,%esp
8010786f:	68 00 10 00 00       	push   $0x1000
80107874:	6a 00                	push   $0x0
80107876:	ff 75 f0             	push   -0x10(%ebp)
80107879:	e8 64 d2 ff ff       	call   80104ae2 <memset>
8010787e:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107881:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107884:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010788a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010788d:	83 ec 0c             	sub    $0xc,%esp
80107890:	6a 06                	push   $0x6
80107892:	52                   	push   %edx
80107893:	68 00 10 00 00       	push   $0x1000
80107898:	50                   	push   %eax
80107899:	ff 75 08             	push   0x8(%ebp)
8010789c:	e8 ca fa ff ff       	call   8010736b <mappages>
801078a1:	83 c4 20             	add    $0x20,%esp
801078a4:	85 c0                	test   %eax,%eax
801078a6:	79 39                	jns    801078e1 <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
801078a8:	83 ec 0c             	sub    $0xc,%esp
801078ab:	68 99 a7 10 80       	push   $0x8010a799
801078b0:	e8 3f 8b ff ff       	call   801003f4 <cprintf>
801078b5:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801078b8:	83 ec 04             	sub    $0x4,%esp
801078bb:	ff 75 0c             	push   0xc(%ebp)
801078be:	ff 75 10             	push   0x10(%ebp)
801078c1:	ff 75 08             	push   0x8(%ebp)
801078c4:	e8 30 00 00 00       	call   801078f9 <deallocuvm>
801078c9:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
801078cc:	83 ec 0c             	sub    $0xc,%esp
801078cf:	ff 75 f0             	push   -0x10(%ebp)
801078d2:	e8 2f ae ff ff       	call   80102706 <kfree>
801078d7:	83 c4 10             	add    $0x10,%esp
      return 0;
801078da:	b8 00 00 00 00       	mov    $0x0,%eax
801078df:	eb 16                	jmp    801078f7 <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
801078e1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801078e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078eb:	3b 45 10             	cmp    0x10(%ebp),%eax
801078ee:	0f 82 3c ff ff ff    	jb     80107830 <allocuvm+0x3c>
    }
  }
  return newsz;
801078f4:	8b 45 10             	mov    0x10(%ebp),%eax
}
801078f7:	c9                   	leave  
801078f8:	c3                   	ret    

801078f9 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801078f9:	55                   	push   %ebp
801078fa:	89 e5                	mov    %esp,%ebp
801078fc:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801078ff:	8b 45 10             	mov    0x10(%ebp),%eax
80107902:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107905:	72 08                	jb     8010790f <deallocuvm+0x16>
    return oldsz;
80107907:	8b 45 0c             	mov    0xc(%ebp),%eax
8010790a:	e9 ac 00 00 00       	jmp    801079bb <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
8010790f:	8b 45 10             	mov    0x10(%ebp),%eax
80107912:	05 ff 0f 00 00       	add    $0xfff,%eax
80107917:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010791c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010791f:	e9 88 00 00 00       	jmp    801079ac <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107927:	83 ec 04             	sub    $0x4,%esp
8010792a:	6a 00                	push   $0x0
8010792c:	50                   	push   %eax
8010792d:	ff 75 08             	push   0x8(%ebp)
80107930:	e8 a0 f9 ff ff       	call   801072d5 <walkpgdir>
80107935:	83 c4 10             	add    $0x10,%esp
80107938:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
8010793b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010793f:	75 16                	jne    80107957 <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107941:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107944:	c1 e8 16             	shr    $0x16,%eax
80107947:	83 c0 01             	add    $0x1,%eax
8010794a:	c1 e0 16             	shl    $0x16,%eax
8010794d:	2d 00 10 00 00       	sub    $0x1000,%eax
80107952:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107955:	eb 4e                	jmp    801079a5 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80107957:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010795a:	8b 00                	mov    (%eax),%eax
8010795c:	83 e0 01             	and    $0x1,%eax
8010795f:	85 c0                	test   %eax,%eax
80107961:	74 42                	je     801079a5 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80107963:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107966:	8b 00                	mov    (%eax),%eax
80107968:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010796d:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107970:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107974:	75 0d                	jne    80107983 <deallocuvm+0x8a>
        panic("kfree");
80107976:	83 ec 0c             	sub    $0xc,%esp
80107979:	68 b5 a7 10 80       	push   $0x8010a7b5
8010797e:	e8 26 8c ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
80107983:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107986:	05 00 00 00 80       	add    $0x80000000,%eax
8010798b:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
8010798e:	83 ec 0c             	sub    $0xc,%esp
80107991:	ff 75 e8             	push   -0x18(%ebp)
80107994:	e8 6d ad ff ff       	call   80102706 <kfree>
80107999:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
8010799c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010799f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
801079a5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801079ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079af:	3b 45 0c             	cmp    0xc(%ebp),%eax
801079b2:	0f 82 6c ff ff ff    	jb     80107924 <deallocuvm+0x2b>
    }
  }
  return newsz;
801079b8:	8b 45 10             	mov    0x10(%ebp),%eax
}
801079bb:	c9                   	leave  
801079bc:	c3                   	ret    

801079bd <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801079bd:	55                   	push   %ebp
801079be:	89 e5                	mov    %esp,%ebp
801079c0:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801079c3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801079c7:	75 0d                	jne    801079d6 <freevm+0x19>
    panic("freevm: no pgdir");
801079c9:	83 ec 0c             	sub    $0xc,%esp
801079cc:	68 bb a7 10 80       	push   $0x8010a7bb
801079d1:	e8 d3 8b ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801079d6:	83 ec 04             	sub    $0x4,%esp
801079d9:	6a 00                	push   $0x0
801079db:	68 00 00 00 80       	push   $0x80000000
801079e0:	ff 75 08             	push   0x8(%ebp)
801079e3:	e8 11 ff ff ff       	call   801078f9 <deallocuvm>
801079e8:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801079eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801079f2:	eb 48                	jmp    80107a3c <freevm+0x7f>
    if(pgdir[i] & PTE_P){
801079f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801079fe:	8b 45 08             	mov    0x8(%ebp),%eax
80107a01:	01 d0                	add    %edx,%eax
80107a03:	8b 00                	mov    (%eax),%eax
80107a05:	83 e0 01             	and    $0x1,%eax
80107a08:	85 c0                	test   %eax,%eax
80107a0a:	74 2c                	je     80107a38 <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107a0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a0f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107a16:	8b 45 08             	mov    0x8(%ebp),%eax
80107a19:	01 d0                	add    %edx,%eax
80107a1b:	8b 00                	mov    (%eax),%eax
80107a1d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107a22:	05 00 00 00 80       	add    $0x80000000,%eax
80107a27:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107a2a:	83 ec 0c             	sub    $0xc,%esp
80107a2d:	ff 75 f0             	push   -0x10(%ebp)
80107a30:	e8 d1 ac ff ff       	call   80102706 <kfree>
80107a35:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107a38:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107a3c:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107a43:	76 af                	jbe    801079f4 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80107a45:	83 ec 0c             	sub    $0xc,%esp
80107a48:	ff 75 08             	push   0x8(%ebp)
80107a4b:	e8 b6 ac ff ff       	call   80102706 <kfree>
80107a50:	83 c4 10             	add    $0x10,%esp
}
80107a53:	90                   	nop
80107a54:	c9                   	leave  
80107a55:	c3                   	ret    

80107a56 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107a56:	55                   	push   %ebp
80107a57:	89 e5                	mov    %esp,%ebp
80107a59:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107a5c:	83 ec 04             	sub    $0x4,%esp
80107a5f:	6a 00                	push   $0x0
80107a61:	ff 75 0c             	push   0xc(%ebp)
80107a64:	ff 75 08             	push   0x8(%ebp)
80107a67:	e8 69 f8 ff ff       	call   801072d5 <walkpgdir>
80107a6c:	83 c4 10             	add    $0x10,%esp
80107a6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107a72:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107a76:	75 0d                	jne    80107a85 <clearpteu+0x2f>
    panic("clearpteu");
80107a78:	83 ec 0c             	sub    $0xc,%esp
80107a7b:	68 cc a7 10 80       	push   $0x8010a7cc
80107a80:	e8 24 8b ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
80107a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a88:	8b 00                	mov    (%eax),%eax
80107a8a:	83 e0 fb             	and    $0xfffffffb,%eax
80107a8d:	89 c2                	mov    %eax,%edx
80107a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a92:	89 10                	mov    %edx,(%eax)
}
80107a94:	90                   	nop
80107a95:	c9                   	leave  
80107a96:	c3                   	ret    

80107a97 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107a97:	55                   	push   %ebp
80107a98:	89 e5                	mov    %esp,%ebp
80107a9a:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107a9d:	e8 59 f9 ff ff       	call   801073fb <setupkvm>
80107aa2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107aa5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107aa9:	75 0a                	jne    80107ab5 <copyuvm+0x1e>
    return 0;
80107aab:	b8 00 00 00 00       	mov    $0x0,%eax
80107ab0:	e9 eb 00 00 00       	jmp    80107ba0 <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
80107ab5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107abc:	e9 b7 00 00 00       	jmp    80107b78 <copyuvm+0xe1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107ac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac4:	83 ec 04             	sub    $0x4,%esp
80107ac7:	6a 00                	push   $0x0
80107ac9:	50                   	push   %eax
80107aca:	ff 75 08             	push   0x8(%ebp)
80107acd:	e8 03 f8 ff ff       	call   801072d5 <walkpgdir>
80107ad2:	83 c4 10             	add    $0x10,%esp
80107ad5:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107ad8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107adc:	75 0d                	jne    80107aeb <copyuvm+0x54>
      panic("copyuvm: pte should exist");
80107ade:	83 ec 0c             	sub    $0xc,%esp
80107ae1:	68 d6 a7 10 80       	push   $0x8010a7d6
80107ae6:	e8 be 8a ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
80107aeb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107aee:	8b 00                	mov    (%eax),%eax
80107af0:	83 e0 01             	and    $0x1,%eax
80107af3:	85 c0                	test   %eax,%eax
80107af5:	75 0d                	jne    80107b04 <copyuvm+0x6d>
      panic("copyuvm: page not present");
80107af7:	83 ec 0c             	sub    $0xc,%esp
80107afa:	68 f0 a7 10 80       	push   $0x8010a7f0
80107aff:	e8 a5 8a ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107b04:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b07:	8b 00                	mov    (%eax),%eax
80107b09:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b0e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107b11:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b14:	8b 00                	mov    (%eax),%eax
80107b16:	25 ff 0f 00 00       	and    $0xfff,%eax
80107b1b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107b1e:	e8 7d ac ff ff       	call   801027a0 <kalloc>
80107b23:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107b26:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107b2a:	74 5d                	je     80107b89 <copyuvm+0xf2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107b2c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107b2f:	05 00 00 00 80       	add    $0x80000000,%eax
80107b34:	83 ec 04             	sub    $0x4,%esp
80107b37:	68 00 10 00 00       	push   $0x1000
80107b3c:	50                   	push   %eax
80107b3d:	ff 75 e0             	push   -0x20(%ebp)
80107b40:	e8 5c d0 ff ff       	call   80104ba1 <memmove>
80107b45:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107b48:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107b4b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107b4e:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b57:	83 ec 0c             	sub    $0xc,%esp
80107b5a:	52                   	push   %edx
80107b5b:	51                   	push   %ecx
80107b5c:	68 00 10 00 00       	push   $0x1000
80107b61:	50                   	push   %eax
80107b62:	ff 75 f0             	push   -0x10(%ebp)
80107b65:	e8 01 f8 ff ff       	call   8010736b <mappages>
80107b6a:	83 c4 20             	add    $0x20,%esp
80107b6d:	85 c0                	test   %eax,%eax
80107b6f:	78 1b                	js     80107b8c <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
80107b71:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107b78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b7b:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107b7e:	0f 82 3d ff ff ff    	jb     80107ac1 <copyuvm+0x2a>
      goto bad;
  }
  return d;
80107b84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b87:	eb 17                	jmp    80107ba0 <copyuvm+0x109>
      goto bad;
80107b89:	90                   	nop
80107b8a:	eb 01                	jmp    80107b8d <copyuvm+0xf6>
      goto bad;
80107b8c:	90                   	nop

bad:
  freevm(d);
80107b8d:	83 ec 0c             	sub    $0xc,%esp
80107b90:	ff 75 f0             	push   -0x10(%ebp)
80107b93:	e8 25 fe ff ff       	call   801079bd <freevm>
80107b98:	83 c4 10             	add    $0x10,%esp
  return 0;
80107b9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107ba0:	c9                   	leave  
80107ba1:	c3                   	ret    

80107ba2 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107ba2:	55                   	push   %ebp
80107ba3:	89 e5                	mov    %esp,%ebp
80107ba5:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107ba8:	83 ec 04             	sub    $0x4,%esp
80107bab:	6a 00                	push   $0x0
80107bad:	ff 75 0c             	push   0xc(%ebp)
80107bb0:	ff 75 08             	push   0x8(%ebp)
80107bb3:	e8 1d f7 ff ff       	call   801072d5 <walkpgdir>
80107bb8:	83 c4 10             	add    $0x10,%esp
80107bbb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80107bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc1:	8b 00                	mov    (%eax),%eax
80107bc3:	83 e0 01             	and    $0x1,%eax
80107bc6:	85 c0                	test   %eax,%eax
80107bc8:	75 07                	jne    80107bd1 <uva2ka+0x2f>
    return 0;
80107bca:	b8 00 00 00 00       	mov    $0x0,%eax
80107bcf:	eb 22                	jmp    80107bf3 <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80107bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd4:	8b 00                	mov    (%eax),%eax
80107bd6:	83 e0 04             	and    $0x4,%eax
80107bd9:	85 c0                	test   %eax,%eax
80107bdb:	75 07                	jne    80107be4 <uva2ka+0x42>
    return 0;
80107bdd:	b8 00 00 00 00       	mov    $0x0,%eax
80107be2:	eb 0f                	jmp    80107bf3 <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80107be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be7:	8b 00                	mov    (%eax),%eax
80107be9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107bee:	05 00 00 00 80       	add    $0x80000000,%eax
}
80107bf3:	c9                   	leave  
80107bf4:	c3                   	ret    

80107bf5 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107bf5:	55                   	push   %ebp
80107bf6:	89 e5                	mov    %esp,%ebp
80107bf8:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80107bfb:	8b 45 10             	mov    0x10(%ebp),%eax
80107bfe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80107c01:	eb 7f                	jmp    80107c82 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80107c03:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c06:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c0b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80107c0e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c11:	83 ec 08             	sub    $0x8,%esp
80107c14:	50                   	push   %eax
80107c15:	ff 75 08             	push   0x8(%ebp)
80107c18:	e8 85 ff ff ff       	call   80107ba2 <uva2ka>
80107c1d:	83 c4 10             	add    $0x10,%esp
80107c20:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80107c23:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80107c27:	75 07                	jne    80107c30 <copyout+0x3b>
      return -1;
80107c29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c2e:	eb 61                	jmp    80107c91 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80107c30:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c33:	2b 45 0c             	sub    0xc(%ebp),%eax
80107c36:	05 00 10 00 00       	add    $0x1000,%eax
80107c3b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80107c3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c41:	3b 45 14             	cmp    0x14(%ebp),%eax
80107c44:	76 06                	jbe    80107c4c <copyout+0x57>
      n = len;
80107c46:	8b 45 14             	mov    0x14(%ebp),%eax
80107c49:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80107c4c:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c4f:	2b 45 ec             	sub    -0x14(%ebp),%eax
80107c52:	89 c2                	mov    %eax,%edx
80107c54:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107c57:	01 d0                	add    %edx,%eax
80107c59:	83 ec 04             	sub    $0x4,%esp
80107c5c:	ff 75 f0             	push   -0x10(%ebp)
80107c5f:	ff 75 f4             	push   -0xc(%ebp)
80107c62:	50                   	push   %eax
80107c63:	e8 39 cf ff ff       	call   80104ba1 <memmove>
80107c68:	83 c4 10             	add    $0x10,%esp
    len -= n;
80107c6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c6e:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80107c71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c74:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80107c77:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c7a:	05 00 10 00 00       	add    $0x1000,%eax
80107c7f:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80107c82:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80107c86:	0f 85 77 ff ff ff    	jne    80107c03 <copyout+0xe>
  }
  return 0;
80107c8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107c91:	c9                   	leave  
80107c92:	c3                   	ret    

80107c93 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80107c93:	55                   	push   %ebp
80107c94:	89 e5                	mov    %esp,%ebp
80107c96:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107c99:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80107ca0:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107ca3:	8b 40 08             	mov    0x8(%eax),%eax
80107ca6:	05 00 00 00 80       	add    $0x80000000,%eax
80107cab:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80107cae:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80107cb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb8:	8b 40 24             	mov    0x24(%eax),%eax
80107cbb:	a3 00 41 19 80       	mov    %eax,0x80194100
  ncpu = 0;
80107cc0:	c7 05 40 6c 19 80 00 	movl   $0x0,0x80196c40
80107cc7:	00 00 00 

  while(i<madt->len){
80107cca:	90                   	nop
80107ccb:	e9 bd 00 00 00       	jmp    80107d8d <mpinit_uefi+0xfa>
    uchar *entry_type = ((uchar *)madt)+i;
80107cd0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107cd3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107cd6:	01 d0                	add    %edx,%eax
80107cd8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80107cdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cde:	0f b6 00             	movzbl (%eax),%eax
80107ce1:	0f b6 c0             	movzbl %al,%eax
80107ce4:	83 f8 05             	cmp    $0x5,%eax
80107ce7:	0f 87 a0 00 00 00    	ja     80107d8d <mpinit_uefi+0xfa>
80107ced:	8b 04 85 0c a8 10 80 	mov    -0x7fef57f4(,%eax,4),%eax
80107cf4:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80107cf6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cf9:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80107cfc:	a1 40 6c 19 80       	mov    0x80196c40,%eax
80107d01:	83 f8 03             	cmp    $0x3,%eax
80107d04:	7f 28                	jg     80107d2e <mpinit_uefi+0x9b>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80107d06:	8b 15 40 6c 19 80    	mov    0x80196c40,%edx
80107d0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107d0f:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80107d13:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80107d19:	81 c2 80 69 19 80    	add    $0x80196980,%edx
80107d1f:	88 02                	mov    %al,(%edx)
          ncpu++;
80107d21:	a1 40 6c 19 80       	mov    0x80196c40,%eax
80107d26:	83 c0 01             	add    $0x1,%eax
80107d29:	a3 40 6c 19 80       	mov    %eax,0x80196c40
        }
        i += lapic_entry->record_len;
80107d2e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107d31:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107d35:	0f b6 c0             	movzbl %al,%eax
80107d38:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107d3b:	eb 50                	jmp    80107d8d <mpinit_uefi+0xfa>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80107d3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d40:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80107d43:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107d46:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80107d4a:	a2 44 6c 19 80       	mov    %al,0x80196c44
        i += ioapic->record_len;
80107d4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107d52:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107d56:	0f b6 c0             	movzbl %al,%eax
80107d59:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107d5c:	eb 2f                	jmp    80107d8d <mpinit_uefi+0xfa>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80107d5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d61:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80107d64:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107d67:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107d6b:	0f b6 c0             	movzbl %al,%eax
80107d6e:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107d71:	eb 1a                	jmp    80107d8d <mpinit_uefi+0xfa>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80107d73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d76:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80107d79:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d7c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107d80:	0f b6 c0             	movzbl %al,%eax
80107d83:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107d86:	eb 05                	jmp    80107d8d <mpinit_uefi+0xfa>

      case 5:
        i = i + 0xC;
80107d88:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80107d8c:	90                   	nop
  while(i<madt->len){
80107d8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d90:	8b 40 04             	mov    0x4(%eax),%eax
80107d93:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80107d96:	0f 82 34 ff ff ff    	jb     80107cd0 <mpinit_uefi+0x3d>
    }
  }

}
80107d9c:	90                   	nop
80107d9d:	90                   	nop
80107d9e:	c9                   	leave  
80107d9f:	c3                   	ret    

80107da0 <inb>:
{
80107da0:	55                   	push   %ebp
80107da1:	89 e5                	mov    %esp,%ebp
80107da3:	83 ec 14             	sub    $0x14,%esp
80107da6:	8b 45 08             	mov    0x8(%ebp),%eax
80107da9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107dad:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107db1:	89 c2                	mov    %eax,%edx
80107db3:	ec                   	in     (%dx),%al
80107db4:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107db7:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107dbb:	c9                   	leave  
80107dbc:	c3                   	ret    

80107dbd <outb>:
{
80107dbd:	55                   	push   %ebp
80107dbe:	89 e5                	mov    %esp,%ebp
80107dc0:	83 ec 08             	sub    $0x8,%esp
80107dc3:	8b 45 08             	mov    0x8(%ebp),%eax
80107dc6:	8b 55 0c             	mov    0xc(%ebp),%edx
80107dc9:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80107dcd:	89 d0                	mov    %edx,%eax
80107dcf:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107dd2:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107dd6:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107dda:	ee                   	out    %al,(%dx)
}
80107ddb:	90                   	nop
80107ddc:	c9                   	leave  
80107ddd:	c3                   	ret    

80107dde <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80107dde:	55                   	push   %ebp
80107ddf:	89 e5                	mov    %esp,%ebp
80107de1:	83 ec 28             	sub    $0x28,%esp
80107de4:	8b 45 08             	mov    0x8(%ebp),%eax
80107de7:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80107dea:	6a 00                	push   $0x0
80107dec:	68 fa 03 00 00       	push   $0x3fa
80107df1:	e8 c7 ff ff ff       	call   80107dbd <outb>
80107df6:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107df9:	68 80 00 00 00       	push   $0x80
80107dfe:	68 fb 03 00 00       	push   $0x3fb
80107e03:	e8 b5 ff ff ff       	call   80107dbd <outb>
80107e08:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107e0b:	6a 0c                	push   $0xc
80107e0d:	68 f8 03 00 00       	push   $0x3f8
80107e12:	e8 a6 ff ff ff       	call   80107dbd <outb>
80107e17:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107e1a:	6a 00                	push   $0x0
80107e1c:	68 f9 03 00 00       	push   $0x3f9
80107e21:	e8 97 ff ff ff       	call   80107dbd <outb>
80107e26:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107e29:	6a 03                	push   $0x3
80107e2b:	68 fb 03 00 00       	push   $0x3fb
80107e30:	e8 88 ff ff ff       	call   80107dbd <outb>
80107e35:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107e38:	6a 00                	push   $0x0
80107e3a:	68 fc 03 00 00       	push   $0x3fc
80107e3f:	e8 79 ff ff ff       	call   80107dbd <outb>
80107e44:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
80107e47:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107e4e:	eb 11                	jmp    80107e61 <uart_debug+0x83>
80107e50:	83 ec 0c             	sub    $0xc,%esp
80107e53:	6a 0a                	push   $0xa
80107e55:	e8 dd ac ff ff       	call   80102b37 <microdelay>
80107e5a:	83 c4 10             	add    $0x10,%esp
80107e5d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107e61:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107e65:	7f 1a                	jg     80107e81 <uart_debug+0xa3>
80107e67:	83 ec 0c             	sub    $0xc,%esp
80107e6a:	68 fd 03 00 00       	push   $0x3fd
80107e6f:	e8 2c ff ff ff       	call   80107da0 <inb>
80107e74:	83 c4 10             	add    $0x10,%esp
80107e77:	0f b6 c0             	movzbl %al,%eax
80107e7a:	83 e0 20             	and    $0x20,%eax
80107e7d:	85 c0                	test   %eax,%eax
80107e7f:	74 cf                	je     80107e50 <uart_debug+0x72>
  outb(COM1+0, p);
80107e81:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80107e85:	0f b6 c0             	movzbl %al,%eax
80107e88:	83 ec 08             	sub    $0x8,%esp
80107e8b:	50                   	push   %eax
80107e8c:	68 f8 03 00 00       	push   $0x3f8
80107e91:	e8 27 ff ff ff       	call   80107dbd <outb>
80107e96:	83 c4 10             	add    $0x10,%esp
}
80107e99:	90                   	nop
80107e9a:	c9                   	leave  
80107e9b:	c3                   	ret    

80107e9c <uart_debugs>:

void uart_debugs(char *p){
80107e9c:	55                   	push   %ebp
80107e9d:	89 e5                	mov    %esp,%ebp
80107e9f:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80107ea2:	eb 1b                	jmp    80107ebf <uart_debugs+0x23>
    uart_debug(*p++);
80107ea4:	8b 45 08             	mov    0x8(%ebp),%eax
80107ea7:	8d 50 01             	lea    0x1(%eax),%edx
80107eaa:	89 55 08             	mov    %edx,0x8(%ebp)
80107ead:	0f b6 00             	movzbl (%eax),%eax
80107eb0:	0f be c0             	movsbl %al,%eax
80107eb3:	83 ec 0c             	sub    $0xc,%esp
80107eb6:	50                   	push   %eax
80107eb7:	e8 22 ff ff ff       	call   80107dde <uart_debug>
80107ebc:	83 c4 10             	add    $0x10,%esp
  while(*p){
80107ebf:	8b 45 08             	mov    0x8(%ebp),%eax
80107ec2:	0f b6 00             	movzbl (%eax),%eax
80107ec5:	84 c0                	test   %al,%al
80107ec7:	75 db                	jne    80107ea4 <uart_debugs+0x8>
  }
}
80107ec9:	90                   	nop
80107eca:	90                   	nop
80107ecb:	c9                   	leave  
80107ecc:	c3                   	ret    

80107ecd <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80107ecd:	55                   	push   %ebp
80107ece:	89 e5                	mov    %esp,%ebp
80107ed0:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107ed3:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80107eda:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107edd:	8b 50 14             	mov    0x14(%eax),%edx
80107ee0:	8b 40 10             	mov    0x10(%eax),%eax
80107ee3:	a3 48 6c 19 80       	mov    %eax,0x80196c48
  gpu.vram_size = boot_param->graphic_config.frame_size;
80107ee8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107eeb:	8b 50 1c             	mov    0x1c(%eax),%edx
80107eee:	8b 40 18             	mov    0x18(%eax),%eax
80107ef1:	a3 50 6c 19 80       	mov    %eax,0x80196c50
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80107ef6:	8b 15 50 6c 19 80    	mov    0x80196c50,%edx
80107efc:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
80107f01:	29 d0                	sub    %edx,%eax
80107f03:	a3 4c 6c 19 80       	mov    %eax,0x80196c4c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80107f08:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107f0b:	8b 50 24             	mov    0x24(%eax),%edx
80107f0e:	8b 40 20             	mov    0x20(%eax),%eax
80107f11:	a3 54 6c 19 80       	mov    %eax,0x80196c54
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80107f16:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107f19:	8b 50 2c             	mov    0x2c(%eax),%edx
80107f1c:	8b 40 28             	mov    0x28(%eax),%eax
80107f1f:	a3 58 6c 19 80       	mov    %eax,0x80196c58
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80107f24:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107f27:	8b 50 34             	mov    0x34(%eax),%edx
80107f2a:	8b 40 30             	mov    0x30(%eax),%eax
80107f2d:	a3 5c 6c 19 80       	mov    %eax,0x80196c5c
}
80107f32:	90                   	nop
80107f33:	c9                   	leave  
80107f34:	c3                   	ret    

80107f35 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80107f35:	55                   	push   %ebp
80107f36:	89 e5                	mov    %esp,%ebp
80107f38:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80107f3b:	8b 15 5c 6c 19 80    	mov    0x80196c5c,%edx
80107f41:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f44:	0f af d0             	imul   %eax,%edx
80107f47:	8b 45 08             	mov    0x8(%ebp),%eax
80107f4a:	01 d0                	add    %edx,%eax
80107f4c:	c1 e0 02             	shl    $0x2,%eax
80107f4f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80107f52:	8b 15 4c 6c 19 80    	mov    0x80196c4c,%edx
80107f58:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107f5b:	01 d0                	add    %edx,%eax
80107f5d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80107f60:	8b 45 10             	mov    0x10(%ebp),%eax
80107f63:	0f b6 10             	movzbl (%eax),%edx
80107f66:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107f69:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80107f6b:	8b 45 10             	mov    0x10(%ebp),%eax
80107f6e:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80107f72:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107f75:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80107f78:	8b 45 10             	mov    0x10(%ebp),%eax
80107f7b:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80107f7f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107f82:	88 50 02             	mov    %dl,0x2(%eax)
}
80107f85:	90                   	nop
80107f86:	c9                   	leave  
80107f87:	c3                   	ret    

80107f88 <graphic_scroll_up>:

void graphic_scroll_up(int height){
80107f88:	55                   	push   %ebp
80107f89:	89 e5                	mov    %esp,%ebp
80107f8b:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80107f8e:	8b 15 5c 6c 19 80    	mov    0x80196c5c,%edx
80107f94:	8b 45 08             	mov    0x8(%ebp),%eax
80107f97:	0f af c2             	imul   %edx,%eax
80107f9a:	c1 e0 02             	shl    $0x2,%eax
80107f9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80107fa0:	a1 50 6c 19 80       	mov    0x80196c50,%eax
80107fa5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107fa8:	29 d0                	sub    %edx,%eax
80107faa:	8b 0d 4c 6c 19 80    	mov    0x80196c4c,%ecx
80107fb0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107fb3:	01 ca                	add    %ecx,%edx
80107fb5:	89 d1                	mov    %edx,%ecx
80107fb7:	8b 15 4c 6c 19 80    	mov    0x80196c4c,%edx
80107fbd:	83 ec 04             	sub    $0x4,%esp
80107fc0:	50                   	push   %eax
80107fc1:	51                   	push   %ecx
80107fc2:	52                   	push   %edx
80107fc3:	e8 d9 cb ff ff       	call   80104ba1 <memmove>
80107fc8:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80107fcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fce:	8b 0d 4c 6c 19 80    	mov    0x80196c4c,%ecx
80107fd4:	8b 15 50 6c 19 80    	mov    0x80196c50,%edx
80107fda:	01 ca                	add    %ecx,%edx
80107fdc:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80107fdf:	29 ca                	sub    %ecx,%edx
80107fe1:	83 ec 04             	sub    $0x4,%esp
80107fe4:	50                   	push   %eax
80107fe5:	6a 00                	push   $0x0
80107fe7:	52                   	push   %edx
80107fe8:	e8 f5 ca ff ff       	call   80104ae2 <memset>
80107fed:	83 c4 10             	add    $0x10,%esp
}
80107ff0:	90                   	nop
80107ff1:	c9                   	leave  
80107ff2:	c3                   	ret    

80107ff3 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80107ff3:	55                   	push   %ebp
80107ff4:	89 e5                	mov    %esp,%ebp
80107ff6:	53                   	push   %ebx
80107ff7:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80107ffa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108001:	e9 b1 00 00 00       	jmp    801080b7 <font_render+0xc4>
    for(int j=14;j>-1;j--){
80108006:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
8010800d:	e9 97 00 00 00       	jmp    801080a9 <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
80108012:	8b 45 10             	mov    0x10(%ebp),%eax
80108015:	83 e8 20             	sub    $0x20,%eax
80108018:	6b d0 1e             	imul   $0x1e,%eax,%edx
8010801b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010801e:	01 d0                	add    %edx,%eax
80108020:	0f b7 84 00 40 a8 10 	movzwl -0x7fef57c0(%eax,%eax,1),%eax
80108027:	80 
80108028:	0f b7 d0             	movzwl %ax,%edx
8010802b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010802e:	bb 01 00 00 00       	mov    $0x1,%ebx
80108033:	89 c1                	mov    %eax,%ecx
80108035:	d3 e3                	shl    %cl,%ebx
80108037:	89 d8                	mov    %ebx,%eax
80108039:	21 d0                	and    %edx,%eax
8010803b:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
8010803e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108041:	ba 01 00 00 00       	mov    $0x1,%edx
80108046:	89 c1                	mov    %eax,%ecx
80108048:	d3 e2                	shl    %cl,%edx
8010804a:	89 d0                	mov    %edx,%eax
8010804c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010804f:	75 2b                	jne    8010807c <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80108051:	8b 55 0c             	mov    0xc(%ebp),%edx
80108054:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108057:	01 c2                	add    %eax,%edx
80108059:	b8 0e 00 00 00       	mov    $0xe,%eax
8010805e:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108061:	89 c1                	mov    %eax,%ecx
80108063:	8b 45 08             	mov    0x8(%ebp),%eax
80108066:	01 c8                	add    %ecx,%eax
80108068:	83 ec 04             	sub    $0x4,%esp
8010806b:	68 e0 f4 10 80       	push   $0x8010f4e0
80108070:	52                   	push   %edx
80108071:	50                   	push   %eax
80108072:	e8 be fe ff ff       	call   80107f35 <graphic_draw_pixel>
80108077:	83 c4 10             	add    $0x10,%esp
8010807a:	eb 29                	jmp    801080a5 <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
8010807c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010807f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108082:	01 c2                	add    %eax,%edx
80108084:	b8 0e 00 00 00       	mov    $0xe,%eax
80108089:	2b 45 f0             	sub    -0x10(%ebp),%eax
8010808c:	89 c1                	mov    %eax,%ecx
8010808e:	8b 45 08             	mov    0x8(%ebp),%eax
80108091:	01 c8                	add    %ecx,%eax
80108093:	83 ec 04             	sub    $0x4,%esp
80108096:	68 60 6c 19 80       	push   $0x80196c60
8010809b:	52                   	push   %edx
8010809c:	50                   	push   %eax
8010809d:	e8 93 fe ff ff       	call   80107f35 <graphic_draw_pixel>
801080a2:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
801080a5:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
801080a9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801080ad:	0f 89 5f ff ff ff    	jns    80108012 <font_render+0x1f>
  for(int i=0;i<30;i++){
801080b3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801080b7:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
801080bb:	0f 8e 45 ff ff ff    	jle    80108006 <font_render+0x13>
      }
    }
  }
}
801080c1:	90                   	nop
801080c2:	90                   	nop
801080c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801080c6:	c9                   	leave  
801080c7:	c3                   	ret    

801080c8 <font_render_string>:

void font_render_string(char *string,int row){
801080c8:	55                   	push   %ebp
801080c9:	89 e5                	mov    %esp,%ebp
801080cb:	53                   	push   %ebx
801080cc:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
801080cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
801080d6:	eb 33                	jmp    8010810b <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
801080d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801080db:	8b 45 08             	mov    0x8(%ebp),%eax
801080de:	01 d0                	add    %edx,%eax
801080e0:	0f b6 00             	movzbl (%eax),%eax
801080e3:	0f be c8             	movsbl %al,%ecx
801080e6:	8b 45 0c             	mov    0xc(%ebp),%eax
801080e9:	6b d0 1e             	imul   $0x1e,%eax,%edx
801080ec:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801080ef:	89 d8                	mov    %ebx,%eax
801080f1:	c1 e0 04             	shl    $0x4,%eax
801080f4:	29 d8                	sub    %ebx,%eax
801080f6:	83 c0 02             	add    $0x2,%eax
801080f9:	83 ec 04             	sub    $0x4,%esp
801080fc:	51                   	push   %ecx
801080fd:	52                   	push   %edx
801080fe:	50                   	push   %eax
801080ff:	e8 ef fe ff ff       	call   80107ff3 <font_render>
80108104:	83 c4 10             	add    $0x10,%esp
    i++;
80108107:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
8010810b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010810e:	8b 45 08             	mov    0x8(%ebp),%eax
80108111:	01 d0                	add    %edx,%eax
80108113:	0f b6 00             	movzbl (%eax),%eax
80108116:	84 c0                	test   %al,%al
80108118:	74 06                	je     80108120 <font_render_string+0x58>
8010811a:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
8010811e:	7e b8                	jle    801080d8 <font_render_string+0x10>
  }
}
80108120:	90                   	nop
80108121:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108124:	c9                   	leave  
80108125:	c3                   	ret    

80108126 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80108126:	55                   	push   %ebp
80108127:	89 e5                	mov    %esp,%ebp
80108129:	53                   	push   %ebx
8010812a:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
8010812d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108134:	eb 6b                	jmp    801081a1 <pci_init+0x7b>
    for(int j=0;j<32;j++){
80108136:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010813d:	eb 58                	jmp    80108197 <pci_init+0x71>
      for(int k=0;k<8;k++){
8010813f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108146:	eb 45                	jmp    8010818d <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
80108148:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010814b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010814e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108151:	83 ec 0c             	sub    $0xc,%esp
80108154:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108157:	53                   	push   %ebx
80108158:	6a 00                	push   $0x0
8010815a:	51                   	push   %ecx
8010815b:	52                   	push   %edx
8010815c:	50                   	push   %eax
8010815d:	e8 b0 00 00 00       	call   80108212 <pci_access_config>
80108162:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
80108165:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108168:	0f b7 c0             	movzwl %ax,%eax
8010816b:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108170:	74 17                	je     80108189 <pci_init+0x63>
        pci_init_device(i,j,k);
80108172:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108175:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108178:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010817b:	83 ec 04             	sub    $0x4,%esp
8010817e:	51                   	push   %ecx
8010817f:	52                   	push   %edx
80108180:	50                   	push   %eax
80108181:	e8 37 01 00 00       	call   801082bd <pci_init_device>
80108186:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108189:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010818d:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108191:	7e b5                	jle    80108148 <pci_init+0x22>
    for(int j=0;j<32;j++){
80108193:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108197:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
8010819b:	7e a2                	jle    8010813f <pci_init+0x19>
  for(int i=0;i<256;i++){
8010819d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801081a1:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801081a8:	7e 8c                	jle    80108136 <pci_init+0x10>
      }
      }
    }
  }
}
801081aa:	90                   	nop
801081ab:	90                   	nop
801081ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801081af:	c9                   	leave  
801081b0:	c3                   	ret    

801081b1 <pci_write_config>:

void pci_write_config(uint config){
801081b1:	55                   	push   %ebp
801081b2:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
801081b4:	8b 45 08             	mov    0x8(%ebp),%eax
801081b7:	ba f8 0c 00 00       	mov    $0xcf8,%edx
801081bc:	89 c0                	mov    %eax,%eax
801081be:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801081bf:	90                   	nop
801081c0:	5d                   	pop    %ebp
801081c1:	c3                   	ret    

801081c2 <pci_write_data>:

void pci_write_data(uint config){
801081c2:	55                   	push   %ebp
801081c3:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
801081c5:	8b 45 08             	mov    0x8(%ebp),%eax
801081c8:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801081cd:	89 c0                	mov    %eax,%eax
801081cf:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801081d0:	90                   	nop
801081d1:	5d                   	pop    %ebp
801081d2:	c3                   	ret    

801081d3 <pci_read_config>:
uint pci_read_config(){
801081d3:	55                   	push   %ebp
801081d4:	89 e5                	mov    %esp,%ebp
801081d6:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
801081d9:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801081de:	ed                   	in     (%dx),%eax
801081df:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
801081e2:	83 ec 0c             	sub    $0xc,%esp
801081e5:	68 c8 00 00 00       	push   $0xc8
801081ea:	e8 48 a9 ff ff       	call   80102b37 <microdelay>
801081ef:	83 c4 10             	add    $0x10,%esp
  return data;
801081f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801081f5:	c9                   	leave  
801081f6:	c3                   	ret    

801081f7 <pci_test>:


void pci_test(){
801081f7:	55                   	push   %ebp
801081f8:	89 e5                	mov    %esp,%ebp
801081fa:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
801081fd:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
80108204:	ff 75 fc             	push   -0x4(%ebp)
80108207:	e8 a5 ff ff ff       	call   801081b1 <pci_write_config>
8010820c:	83 c4 04             	add    $0x4,%esp
}
8010820f:	90                   	nop
80108210:	c9                   	leave  
80108211:	c3                   	ret    

80108212 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
80108212:	55                   	push   %ebp
80108213:	89 e5                	mov    %esp,%ebp
80108215:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108218:	8b 45 08             	mov    0x8(%ebp),%eax
8010821b:	c1 e0 10             	shl    $0x10,%eax
8010821e:	25 00 00 ff 00       	and    $0xff0000,%eax
80108223:	89 c2                	mov    %eax,%edx
80108225:	8b 45 0c             	mov    0xc(%ebp),%eax
80108228:	c1 e0 0b             	shl    $0xb,%eax
8010822b:	0f b7 c0             	movzwl %ax,%eax
8010822e:	09 c2                	or     %eax,%edx
80108230:	8b 45 10             	mov    0x10(%ebp),%eax
80108233:	c1 e0 08             	shl    $0x8,%eax
80108236:	25 00 07 00 00       	and    $0x700,%eax
8010823b:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
8010823d:	8b 45 14             	mov    0x14(%ebp),%eax
80108240:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108245:	09 d0                	or     %edx,%eax
80108247:	0d 00 00 00 80       	or     $0x80000000,%eax
8010824c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
8010824f:	ff 75 f4             	push   -0xc(%ebp)
80108252:	e8 5a ff ff ff       	call   801081b1 <pci_write_config>
80108257:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
8010825a:	e8 74 ff ff ff       	call   801081d3 <pci_read_config>
8010825f:	8b 55 18             	mov    0x18(%ebp),%edx
80108262:	89 02                	mov    %eax,(%edx)
}
80108264:	90                   	nop
80108265:	c9                   	leave  
80108266:	c3                   	ret    

80108267 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108267:	55                   	push   %ebp
80108268:	89 e5                	mov    %esp,%ebp
8010826a:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010826d:	8b 45 08             	mov    0x8(%ebp),%eax
80108270:	c1 e0 10             	shl    $0x10,%eax
80108273:	25 00 00 ff 00       	and    $0xff0000,%eax
80108278:	89 c2                	mov    %eax,%edx
8010827a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010827d:	c1 e0 0b             	shl    $0xb,%eax
80108280:	0f b7 c0             	movzwl %ax,%eax
80108283:	09 c2                	or     %eax,%edx
80108285:	8b 45 10             	mov    0x10(%ebp),%eax
80108288:	c1 e0 08             	shl    $0x8,%eax
8010828b:	25 00 07 00 00       	and    $0x700,%eax
80108290:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108292:	8b 45 14             	mov    0x14(%ebp),%eax
80108295:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010829a:	09 d0                	or     %edx,%eax
8010829c:	0d 00 00 00 80       	or     $0x80000000,%eax
801082a1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
801082a4:	ff 75 fc             	push   -0x4(%ebp)
801082a7:	e8 05 ff ff ff       	call   801081b1 <pci_write_config>
801082ac:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
801082af:	ff 75 18             	push   0x18(%ebp)
801082b2:	e8 0b ff ff ff       	call   801081c2 <pci_write_data>
801082b7:	83 c4 04             	add    $0x4,%esp
}
801082ba:	90                   	nop
801082bb:	c9                   	leave  
801082bc:	c3                   	ret    

801082bd <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
801082bd:	55                   	push   %ebp
801082be:	89 e5                	mov    %esp,%ebp
801082c0:	53                   	push   %ebx
801082c1:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
801082c4:	8b 45 08             	mov    0x8(%ebp),%eax
801082c7:	a2 64 6c 19 80       	mov    %al,0x80196c64
  dev.device_num = device_num;
801082cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801082cf:	a2 65 6c 19 80       	mov    %al,0x80196c65
  dev.function_num = function_num;
801082d4:	8b 45 10             	mov    0x10(%ebp),%eax
801082d7:	a2 66 6c 19 80       	mov    %al,0x80196c66
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
801082dc:	ff 75 10             	push   0x10(%ebp)
801082df:	ff 75 0c             	push   0xc(%ebp)
801082e2:	ff 75 08             	push   0x8(%ebp)
801082e5:	68 84 be 10 80       	push   $0x8010be84
801082ea:	e8 05 81 ff ff       	call   801003f4 <cprintf>
801082ef:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
801082f2:	83 ec 0c             	sub    $0xc,%esp
801082f5:	8d 45 ec             	lea    -0x14(%ebp),%eax
801082f8:	50                   	push   %eax
801082f9:	6a 00                	push   $0x0
801082fb:	ff 75 10             	push   0x10(%ebp)
801082fe:	ff 75 0c             	push   0xc(%ebp)
80108301:	ff 75 08             	push   0x8(%ebp)
80108304:	e8 09 ff ff ff       	call   80108212 <pci_access_config>
80108309:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
8010830c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010830f:	c1 e8 10             	shr    $0x10,%eax
80108312:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
80108315:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108318:	25 ff ff 00 00       	and    $0xffff,%eax
8010831d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108320:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108323:	a3 68 6c 19 80       	mov    %eax,0x80196c68
  dev.vendor_id = vendor_id;
80108328:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010832b:	a3 6c 6c 19 80       	mov    %eax,0x80196c6c
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108330:	83 ec 04             	sub    $0x4,%esp
80108333:	ff 75 f0             	push   -0x10(%ebp)
80108336:	ff 75 f4             	push   -0xc(%ebp)
80108339:	68 b8 be 10 80       	push   $0x8010beb8
8010833e:	e8 b1 80 ff ff       	call   801003f4 <cprintf>
80108343:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
80108346:	83 ec 0c             	sub    $0xc,%esp
80108349:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010834c:	50                   	push   %eax
8010834d:	6a 08                	push   $0x8
8010834f:	ff 75 10             	push   0x10(%ebp)
80108352:	ff 75 0c             	push   0xc(%ebp)
80108355:	ff 75 08             	push   0x8(%ebp)
80108358:	e8 b5 fe ff ff       	call   80108212 <pci_access_config>
8010835d:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108360:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108363:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108366:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108369:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010836c:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
8010836f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108372:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108375:	0f b6 c0             	movzbl %al,%eax
80108378:	8b 5d ec             	mov    -0x14(%ebp),%ebx
8010837b:	c1 eb 18             	shr    $0x18,%ebx
8010837e:	83 ec 0c             	sub    $0xc,%esp
80108381:	51                   	push   %ecx
80108382:	52                   	push   %edx
80108383:	50                   	push   %eax
80108384:	53                   	push   %ebx
80108385:	68 dc be 10 80       	push   $0x8010bedc
8010838a:	e8 65 80 ff ff       	call   801003f4 <cprintf>
8010838f:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108392:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108395:	c1 e8 18             	shr    $0x18,%eax
80108398:	a2 70 6c 19 80       	mov    %al,0x80196c70
  dev.sub_class = (data>>16)&0xFF;
8010839d:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083a0:	c1 e8 10             	shr    $0x10,%eax
801083a3:	a2 71 6c 19 80       	mov    %al,0x80196c71
  dev.interface = (data>>8)&0xFF;
801083a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083ab:	c1 e8 08             	shr    $0x8,%eax
801083ae:	a2 72 6c 19 80       	mov    %al,0x80196c72
  dev.revision_id = data&0xFF;
801083b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083b6:	a2 73 6c 19 80       	mov    %al,0x80196c73
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
801083bb:	83 ec 0c             	sub    $0xc,%esp
801083be:	8d 45 ec             	lea    -0x14(%ebp),%eax
801083c1:	50                   	push   %eax
801083c2:	6a 10                	push   $0x10
801083c4:	ff 75 10             	push   0x10(%ebp)
801083c7:	ff 75 0c             	push   0xc(%ebp)
801083ca:	ff 75 08             	push   0x8(%ebp)
801083cd:	e8 40 fe ff ff       	call   80108212 <pci_access_config>
801083d2:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
801083d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083d8:	a3 74 6c 19 80       	mov    %eax,0x80196c74
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
801083dd:	83 ec 0c             	sub    $0xc,%esp
801083e0:	8d 45 ec             	lea    -0x14(%ebp),%eax
801083e3:	50                   	push   %eax
801083e4:	6a 14                	push   $0x14
801083e6:	ff 75 10             	push   0x10(%ebp)
801083e9:	ff 75 0c             	push   0xc(%ebp)
801083ec:	ff 75 08             	push   0x8(%ebp)
801083ef:	e8 1e fe ff ff       	call   80108212 <pci_access_config>
801083f4:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
801083f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083fa:	a3 78 6c 19 80       	mov    %eax,0x80196c78
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
801083ff:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
80108406:	75 5a                	jne    80108462 <pci_init_device+0x1a5>
80108408:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
8010840f:	75 51                	jne    80108462 <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
80108411:	83 ec 0c             	sub    $0xc,%esp
80108414:	68 21 bf 10 80       	push   $0x8010bf21
80108419:	e8 d6 7f ff ff       	call   801003f4 <cprintf>
8010841e:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108421:	83 ec 0c             	sub    $0xc,%esp
80108424:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108427:	50                   	push   %eax
80108428:	68 f0 00 00 00       	push   $0xf0
8010842d:	ff 75 10             	push   0x10(%ebp)
80108430:	ff 75 0c             	push   0xc(%ebp)
80108433:	ff 75 08             	push   0x8(%ebp)
80108436:	e8 d7 fd ff ff       	call   80108212 <pci_access_config>
8010843b:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
8010843e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108441:	83 ec 08             	sub    $0x8,%esp
80108444:	50                   	push   %eax
80108445:	68 3b bf 10 80       	push   $0x8010bf3b
8010844a:	e8 a5 7f ff ff       	call   801003f4 <cprintf>
8010844f:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108452:	83 ec 0c             	sub    $0xc,%esp
80108455:	68 64 6c 19 80       	push   $0x80196c64
8010845a:	e8 09 00 00 00       	call   80108468 <i8254_init>
8010845f:	83 c4 10             	add    $0x10,%esp
  }
}
80108462:	90                   	nop
80108463:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108466:	c9                   	leave  
80108467:	c3                   	ret    

80108468 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108468:	55                   	push   %ebp
80108469:	89 e5                	mov    %esp,%ebp
8010846b:	53                   	push   %ebx
8010846c:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
8010846f:	8b 45 08             	mov    0x8(%ebp),%eax
80108472:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108476:	0f b6 c8             	movzbl %al,%ecx
80108479:	8b 45 08             	mov    0x8(%ebp),%eax
8010847c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108480:	0f b6 d0             	movzbl %al,%edx
80108483:	8b 45 08             	mov    0x8(%ebp),%eax
80108486:	0f b6 00             	movzbl (%eax),%eax
80108489:	0f b6 c0             	movzbl %al,%eax
8010848c:	83 ec 0c             	sub    $0xc,%esp
8010848f:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108492:	53                   	push   %ebx
80108493:	6a 04                	push   $0x4
80108495:	51                   	push   %ecx
80108496:	52                   	push   %edx
80108497:	50                   	push   %eax
80108498:	e8 75 fd ff ff       	call   80108212 <pci_access_config>
8010849d:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
801084a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084a3:	83 c8 04             	or     $0x4,%eax
801084a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
801084a9:	8b 5d ec             	mov    -0x14(%ebp),%ebx
801084ac:	8b 45 08             	mov    0x8(%ebp),%eax
801084af:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801084b3:	0f b6 c8             	movzbl %al,%ecx
801084b6:	8b 45 08             	mov    0x8(%ebp),%eax
801084b9:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801084bd:	0f b6 d0             	movzbl %al,%edx
801084c0:	8b 45 08             	mov    0x8(%ebp),%eax
801084c3:	0f b6 00             	movzbl (%eax),%eax
801084c6:	0f b6 c0             	movzbl %al,%eax
801084c9:	83 ec 0c             	sub    $0xc,%esp
801084cc:	53                   	push   %ebx
801084cd:	6a 04                	push   $0x4
801084cf:	51                   	push   %ecx
801084d0:	52                   	push   %edx
801084d1:	50                   	push   %eax
801084d2:	e8 90 fd ff ff       	call   80108267 <pci_write_config_register>
801084d7:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
801084da:	8b 45 08             	mov    0x8(%ebp),%eax
801084dd:	8b 40 10             	mov    0x10(%eax),%eax
801084e0:	05 00 00 00 40       	add    $0x40000000,%eax
801084e5:	a3 7c 6c 19 80       	mov    %eax,0x80196c7c
  uint *ctrl = (uint *)base_addr;
801084ea:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801084ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
801084f2:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801084f7:	05 d8 00 00 00       	add    $0xd8,%eax
801084fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
801084ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108502:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108508:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010850b:	8b 00                	mov    (%eax),%eax
8010850d:	0d 00 00 00 04       	or     $0x4000000,%eax
80108512:	89 c2                	mov    %eax,%edx
80108514:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108517:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108519:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010851c:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108522:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108525:	8b 00                	mov    (%eax),%eax
80108527:	83 c8 40             	or     $0x40,%eax
8010852a:	89 c2                	mov    %eax,%edx
8010852c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010852f:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108531:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108534:	8b 10                	mov    (%eax),%edx
80108536:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108539:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
8010853b:	83 ec 0c             	sub    $0xc,%esp
8010853e:	68 50 bf 10 80       	push   $0x8010bf50
80108543:	e8 ac 7e ff ff       	call   801003f4 <cprintf>
80108548:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
8010854b:	e8 50 a2 ff ff       	call   801027a0 <kalloc>
80108550:	a3 88 6c 19 80       	mov    %eax,0x80196c88
  *intr_addr = 0;
80108555:	a1 88 6c 19 80       	mov    0x80196c88,%eax
8010855a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108560:	a1 88 6c 19 80       	mov    0x80196c88,%eax
80108565:	83 ec 08             	sub    $0x8,%esp
80108568:	50                   	push   %eax
80108569:	68 72 bf 10 80       	push   $0x8010bf72
8010856e:	e8 81 7e ff ff       	call   801003f4 <cprintf>
80108573:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108576:	e8 50 00 00 00       	call   801085cb <i8254_init_recv>
  i8254_init_send();
8010857b:	e8 69 03 00 00       	call   801088e9 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108580:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108587:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
8010858a:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108591:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108594:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010859b:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
8010859e:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801085a5:	0f b6 c0             	movzbl %al,%eax
801085a8:	83 ec 0c             	sub    $0xc,%esp
801085ab:	53                   	push   %ebx
801085ac:	51                   	push   %ecx
801085ad:	52                   	push   %edx
801085ae:	50                   	push   %eax
801085af:	68 80 bf 10 80       	push   $0x8010bf80
801085b4:	e8 3b 7e ff ff       	call   801003f4 <cprintf>
801085b9:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
801085bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085bf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
801085c5:	90                   	nop
801085c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801085c9:	c9                   	leave  
801085ca:	c3                   	ret    

801085cb <i8254_init_recv>:

void i8254_init_recv(){
801085cb:	55                   	push   %ebp
801085cc:	89 e5                	mov    %esp,%ebp
801085ce:	57                   	push   %edi
801085cf:	56                   	push   %esi
801085d0:	53                   	push   %ebx
801085d1:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
801085d4:	83 ec 0c             	sub    $0xc,%esp
801085d7:	6a 00                	push   $0x0
801085d9:	e8 e8 04 00 00       	call   80108ac6 <i8254_read_eeprom>
801085de:	83 c4 10             	add    $0x10,%esp
801085e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
801085e4:	8b 45 d8             	mov    -0x28(%ebp),%eax
801085e7:	a2 80 6c 19 80       	mov    %al,0x80196c80
  mac_addr[1] = data_l>>8;
801085ec:	8b 45 d8             	mov    -0x28(%ebp),%eax
801085ef:	c1 e8 08             	shr    $0x8,%eax
801085f2:	a2 81 6c 19 80       	mov    %al,0x80196c81
  uint data_m = i8254_read_eeprom(0x1);
801085f7:	83 ec 0c             	sub    $0xc,%esp
801085fa:	6a 01                	push   $0x1
801085fc:	e8 c5 04 00 00       	call   80108ac6 <i8254_read_eeprom>
80108601:	83 c4 10             	add    $0x10,%esp
80108604:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108607:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010860a:	a2 82 6c 19 80       	mov    %al,0x80196c82
  mac_addr[3] = data_m>>8;
8010860f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108612:	c1 e8 08             	shr    $0x8,%eax
80108615:	a2 83 6c 19 80       	mov    %al,0x80196c83
  uint data_h = i8254_read_eeprom(0x2);
8010861a:	83 ec 0c             	sub    $0xc,%esp
8010861d:	6a 02                	push   $0x2
8010861f:	e8 a2 04 00 00       	call   80108ac6 <i8254_read_eeprom>
80108624:	83 c4 10             	add    $0x10,%esp
80108627:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
8010862a:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010862d:	a2 84 6c 19 80       	mov    %al,0x80196c84
  mac_addr[5] = data_h>>8;
80108632:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108635:	c1 e8 08             	shr    $0x8,%eax
80108638:	a2 85 6c 19 80       	mov    %al,0x80196c85
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
8010863d:	0f b6 05 85 6c 19 80 	movzbl 0x80196c85,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108644:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108647:	0f b6 05 84 6c 19 80 	movzbl 0x80196c84,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010864e:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108651:	0f b6 05 83 6c 19 80 	movzbl 0x80196c83,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108658:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
8010865b:	0f b6 05 82 6c 19 80 	movzbl 0x80196c82,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108662:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108665:	0f b6 05 81 6c 19 80 	movzbl 0x80196c81,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010866c:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
8010866f:	0f b6 05 80 6c 19 80 	movzbl 0x80196c80,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108676:	0f b6 c0             	movzbl %al,%eax
80108679:	83 ec 04             	sub    $0x4,%esp
8010867c:	57                   	push   %edi
8010867d:	56                   	push   %esi
8010867e:	53                   	push   %ebx
8010867f:	51                   	push   %ecx
80108680:	52                   	push   %edx
80108681:	50                   	push   %eax
80108682:	68 98 bf 10 80       	push   $0x8010bf98
80108687:	e8 68 7d ff ff       	call   801003f4 <cprintf>
8010868c:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
8010868f:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108694:	05 00 54 00 00       	add    $0x5400,%eax
80108699:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
8010869c:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801086a1:	05 04 54 00 00       	add    $0x5404,%eax
801086a6:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
801086a9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801086ac:	c1 e0 10             	shl    $0x10,%eax
801086af:	0b 45 d8             	or     -0x28(%ebp),%eax
801086b2:	89 c2                	mov    %eax,%edx
801086b4:	8b 45 cc             	mov    -0x34(%ebp),%eax
801086b7:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
801086b9:	8b 45 d0             	mov    -0x30(%ebp),%eax
801086bc:	0d 00 00 00 80       	or     $0x80000000,%eax
801086c1:	89 c2                	mov    %eax,%edx
801086c3:	8b 45 c8             	mov    -0x38(%ebp),%eax
801086c6:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
801086c8:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801086cd:	05 00 52 00 00       	add    $0x5200,%eax
801086d2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
801086d5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801086dc:	eb 19                	jmp    801086f7 <i8254_init_recv+0x12c>
    mta[i] = 0;
801086de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801086e1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801086e8:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801086eb:	01 d0                	add    %edx,%eax
801086ed:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
801086f3:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801086f7:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
801086fb:	7e e1                	jle    801086de <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
801086fd:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108702:	05 d0 00 00 00       	add    $0xd0,%eax
80108707:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
8010870a:	8b 45 c0             	mov    -0x40(%ebp),%eax
8010870d:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108713:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108718:	05 c8 00 00 00       	add    $0xc8,%eax
8010871d:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108720:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108723:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108729:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
8010872e:	05 28 28 00 00       	add    $0x2828,%eax
80108733:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108736:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108739:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
8010873f:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108744:	05 00 01 00 00       	add    $0x100,%eax
80108749:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
8010874c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
8010874f:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108755:	e8 46 a0 ff ff       	call   801027a0 <kalloc>
8010875a:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
8010875d:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108762:	05 00 28 00 00       	add    $0x2800,%eax
80108767:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
8010876a:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
8010876f:	05 04 28 00 00       	add    $0x2804,%eax
80108774:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108777:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
8010877c:	05 08 28 00 00       	add    $0x2808,%eax
80108781:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108784:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108789:	05 10 28 00 00       	add    $0x2810,%eax
8010878e:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108791:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108796:	05 18 28 00 00       	add    $0x2818,%eax
8010879b:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
8010879e:	8b 45 b0             	mov    -0x50(%ebp),%eax
801087a1:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801087a7:	8b 45 ac             	mov    -0x54(%ebp),%eax
801087aa:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
801087ac:	8b 45 a8             	mov    -0x58(%ebp),%eax
801087af:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
801087b5:	8b 45 a4             	mov    -0x5c(%ebp),%eax
801087b8:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
801087be:	8b 45 a0             	mov    -0x60(%ebp),%eax
801087c1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
801087c7:	8b 45 9c             	mov    -0x64(%ebp),%eax
801087ca:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
801087d0:	8b 45 b0             	mov    -0x50(%ebp),%eax
801087d3:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
801087d6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801087dd:	eb 73                	jmp    80108852 <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
801087df:	8b 45 e0             	mov    -0x20(%ebp),%eax
801087e2:	c1 e0 04             	shl    $0x4,%eax
801087e5:	89 c2                	mov    %eax,%edx
801087e7:	8b 45 98             	mov    -0x68(%ebp),%eax
801087ea:	01 d0                	add    %edx,%eax
801087ec:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
801087f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801087f6:	c1 e0 04             	shl    $0x4,%eax
801087f9:	89 c2                	mov    %eax,%edx
801087fb:	8b 45 98             	mov    -0x68(%ebp),%eax
801087fe:	01 d0                	add    %edx,%eax
80108800:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108806:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108809:	c1 e0 04             	shl    $0x4,%eax
8010880c:	89 c2                	mov    %eax,%edx
8010880e:	8b 45 98             	mov    -0x68(%ebp),%eax
80108811:	01 d0                	add    %edx,%eax
80108813:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108819:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010881c:	c1 e0 04             	shl    $0x4,%eax
8010881f:	89 c2                	mov    %eax,%edx
80108821:	8b 45 98             	mov    -0x68(%ebp),%eax
80108824:	01 d0                	add    %edx,%eax
80108826:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
8010882a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010882d:	c1 e0 04             	shl    $0x4,%eax
80108830:	89 c2                	mov    %eax,%edx
80108832:	8b 45 98             	mov    -0x68(%ebp),%eax
80108835:	01 d0                	add    %edx,%eax
80108837:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
8010883b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010883e:	c1 e0 04             	shl    $0x4,%eax
80108841:	89 c2                	mov    %eax,%edx
80108843:	8b 45 98             	mov    -0x68(%ebp),%eax
80108846:	01 d0                	add    %edx,%eax
80108848:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
8010884e:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108852:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108859:	7e 84                	jle    801087df <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
8010885b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108862:	eb 57                	jmp    801088bb <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
80108864:	e8 37 9f ff ff       	call   801027a0 <kalloc>
80108869:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
8010886c:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108870:	75 12                	jne    80108884 <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80108872:	83 ec 0c             	sub    $0xc,%esp
80108875:	68 b8 bf 10 80       	push   $0x8010bfb8
8010887a:	e8 75 7b ff ff       	call   801003f4 <cprintf>
8010887f:	83 c4 10             	add    $0x10,%esp
      break;
80108882:	eb 3d                	jmp    801088c1 <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108884:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108887:	c1 e0 04             	shl    $0x4,%eax
8010888a:	89 c2                	mov    %eax,%edx
8010888c:	8b 45 98             	mov    -0x68(%ebp),%eax
8010888f:	01 d0                	add    %edx,%eax
80108891:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108894:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010889a:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
8010889c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010889f:	83 c0 01             	add    $0x1,%eax
801088a2:	c1 e0 04             	shl    $0x4,%eax
801088a5:	89 c2                	mov    %eax,%edx
801088a7:	8b 45 98             	mov    -0x68(%ebp),%eax
801088aa:	01 d0                	add    %edx,%eax
801088ac:	8b 55 94             	mov    -0x6c(%ebp),%edx
801088af:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
801088b5:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
801088b7:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
801088bb:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
801088bf:	7e a3                	jle    80108864 <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
801088c1:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801088c4:	8b 00                	mov    (%eax),%eax
801088c6:	83 c8 02             	or     $0x2,%eax
801088c9:	89 c2                	mov    %eax,%edx
801088cb:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801088ce:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
801088d0:	83 ec 0c             	sub    $0xc,%esp
801088d3:	68 d8 bf 10 80       	push   $0x8010bfd8
801088d8:	e8 17 7b ff ff       	call   801003f4 <cprintf>
801088dd:	83 c4 10             	add    $0x10,%esp
}
801088e0:	90                   	nop
801088e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801088e4:	5b                   	pop    %ebx
801088e5:	5e                   	pop    %esi
801088e6:	5f                   	pop    %edi
801088e7:	5d                   	pop    %ebp
801088e8:	c3                   	ret    

801088e9 <i8254_init_send>:

void i8254_init_send(){
801088e9:	55                   	push   %ebp
801088ea:	89 e5                	mov    %esp,%ebp
801088ec:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
801088ef:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801088f4:	05 28 38 00 00       	add    $0x3828,%eax
801088f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
801088fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088ff:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108905:	e8 96 9e ff ff       	call   801027a0 <kalloc>
8010890a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
8010890d:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108912:	05 00 38 00 00       	add    $0x3800,%eax
80108917:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
8010891a:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
8010891f:	05 04 38 00 00       	add    $0x3804,%eax
80108924:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108927:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
8010892c:	05 08 38 00 00       	add    $0x3808,%eax
80108931:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108934:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108937:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010893d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108940:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108942:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108945:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
8010894b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010894e:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108954:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108959:	05 10 38 00 00       	add    $0x3810,%eax
8010895e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108961:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108966:	05 18 38 00 00       	add    $0x3818,%eax
8010896b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
8010896e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108971:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108977:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010897a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108980:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108983:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108986:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010898d:	e9 82 00 00 00       	jmp    80108a14 <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80108992:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108995:	c1 e0 04             	shl    $0x4,%eax
80108998:	89 c2                	mov    %eax,%edx
8010899a:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010899d:	01 d0                	add    %edx,%eax
8010899f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
801089a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089a9:	c1 e0 04             	shl    $0x4,%eax
801089ac:	89 c2                	mov    %eax,%edx
801089ae:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089b1:	01 d0                	add    %edx,%eax
801089b3:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
801089b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089bc:	c1 e0 04             	shl    $0x4,%eax
801089bf:	89 c2                	mov    %eax,%edx
801089c1:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089c4:	01 d0                	add    %edx,%eax
801089c6:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
801089ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089cd:	c1 e0 04             	shl    $0x4,%eax
801089d0:	89 c2                	mov    %eax,%edx
801089d2:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089d5:	01 d0                	add    %edx,%eax
801089d7:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
801089db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089de:	c1 e0 04             	shl    $0x4,%eax
801089e1:	89 c2                	mov    %eax,%edx
801089e3:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089e6:	01 d0                	add    %edx,%eax
801089e8:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
801089ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ef:	c1 e0 04             	shl    $0x4,%eax
801089f2:	89 c2                	mov    %eax,%edx
801089f4:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089f7:	01 d0                	add    %edx,%eax
801089f9:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
801089fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a00:	c1 e0 04             	shl    $0x4,%eax
80108a03:	89 c2                	mov    %eax,%edx
80108a05:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a08:	01 d0                	add    %edx,%eax
80108a0a:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108a10:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108a14:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108a1b:	0f 8e 71 ff ff ff    	jle    80108992 <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108a21:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108a28:	eb 57                	jmp    80108a81 <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
80108a2a:	e8 71 9d ff ff       	call   801027a0 <kalloc>
80108a2f:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108a32:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108a36:	75 12                	jne    80108a4a <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
80108a38:	83 ec 0c             	sub    $0xc,%esp
80108a3b:	68 b8 bf 10 80       	push   $0x8010bfb8
80108a40:	e8 af 79 ff ff       	call   801003f4 <cprintf>
80108a45:	83 c4 10             	add    $0x10,%esp
      break;
80108a48:	eb 3d                	jmp    80108a87 <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108a4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a4d:	c1 e0 04             	shl    $0x4,%eax
80108a50:	89 c2                	mov    %eax,%edx
80108a52:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a55:	01 d0                	add    %edx,%eax
80108a57:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108a5a:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108a60:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108a62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a65:	83 c0 01             	add    $0x1,%eax
80108a68:	c1 e0 04             	shl    $0x4,%eax
80108a6b:	89 c2                	mov    %eax,%edx
80108a6d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a70:	01 d0                	add    %edx,%eax
80108a72:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108a75:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108a7b:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108a7d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108a81:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108a85:	7e a3                	jle    80108a2a <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108a87:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108a8c:	05 00 04 00 00       	add    $0x400,%eax
80108a91:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108a94:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108a97:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108a9d:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108aa2:	05 10 04 00 00       	add    $0x410,%eax
80108aa7:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108aaa:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108aad:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108ab3:	83 ec 0c             	sub    $0xc,%esp
80108ab6:	68 f8 bf 10 80       	push   $0x8010bff8
80108abb:	e8 34 79 ff ff       	call   801003f4 <cprintf>
80108ac0:	83 c4 10             	add    $0x10,%esp

}
80108ac3:	90                   	nop
80108ac4:	c9                   	leave  
80108ac5:	c3                   	ret    

80108ac6 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108ac6:	55                   	push   %ebp
80108ac7:	89 e5                	mov    %esp,%ebp
80108ac9:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80108acc:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108ad1:	83 c0 14             	add    $0x14,%eax
80108ad4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108ad7:	8b 45 08             	mov    0x8(%ebp),%eax
80108ada:	c1 e0 08             	shl    $0x8,%eax
80108add:	0f b7 c0             	movzwl %ax,%eax
80108ae0:	83 c8 01             	or     $0x1,%eax
80108ae3:	89 c2                	mov    %eax,%edx
80108ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ae8:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108aea:	83 ec 0c             	sub    $0xc,%esp
80108aed:	68 18 c0 10 80       	push   $0x8010c018
80108af2:	e8 fd 78 ff ff       	call   801003f4 <cprintf>
80108af7:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80108afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108afd:	8b 00                	mov    (%eax),%eax
80108aff:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80108b02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b05:	83 e0 10             	and    $0x10,%eax
80108b08:	85 c0                	test   %eax,%eax
80108b0a:	75 02                	jne    80108b0e <i8254_read_eeprom+0x48>
  while(1){
80108b0c:	eb dc                	jmp    80108aea <i8254_read_eeprom+0x24>
      break;
80108b0e:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80108b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b12:	8b 00                	mov    (%eax),%eax
80108b14:	c1 e8 10             	shr    $0x10,%eax
}
80108b17:	c9                   	leave  
80108b18:	c3                   	ret    

80108b19 <i8254_recv>:
void i8254_recv(){
80108b19:	55                   	push   %ebp
80108b1a:	89 e5                	mov    %esp,%ebp
80108b1c:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108b1f:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108b24:	05 10 28 00 00       	add    $0x2810,%eax
80108b29:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108b2c:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108b31:	05 18 28 00 00       	add    $0x2818,%eax
80108b36:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108b39:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108b3e:	05 00 28 00 00       	add    $0x2800,%eax
80108b43:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108b46:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b49:	8b 00                	mov    (%eax),%eax
80108b4b:	05 00 00 00 80       	add    $0x80000000,%eax
80108b50:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b56:	8b 10                	mov    (%eax),%edx
80108b58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b5b:	8b 08                	mov    (%eax),%ecx
80108b5d:	89 d0                	mov    %edx,%eax
80108b5f:	29 c8                	sub    %ecx,%eax
80108b61:	25 ff 00 00 00       	and    $0xff,%eax
80108b66:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80108b69:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108b6d:	7e 37                	jle    80108ba6 <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80108b6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b72:	8b 00                	mov    (%eax),%eax
80108b74:	c1 e0 04             	shl    $0x4,%eax
80108b77:	89 c2                	mov    %eax,%edx
80108b79:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b7c:	01 d0                	add    %edx,%eax
80108b7e:	8b 00                	mov    (%eax),%eax
80108b80:	05 00 00 00 80       	add    $0x80000000,%eax
80108b85:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80108b88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b8b:	8b 00                	mov    (%eax),%eax
80108b8d:	83 c0 01             	add    $0x1,%eax
80108b90:	0f b6 d0             	movzbl %al,%edx
80108b93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b96:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80108b98:	83 ec 0c             	sub    $0xc,%esp
80108b9b:	ff 75 e0             	push   -0x20(%ebp)
80108b9e:	e8 15 09 00 00       	call   801094b8 <eth_proc>
80108ba3:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80108ba6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ba9:	8b 10                	mov    (%eax),%edx
80108bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bae:	8b 00                	mov    (%eax),%eax
80108bb0:	39 c2                	cmp    %eax,%edx
80108bb2:	75 9f                	jne    80108b53 <i8254_recv+0x3a>
      (*rdt)--;
80108bb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bb7:	8b 00                	mov    (%eax),%eax
80108bb9:	8d 50 ff             	lea    -0x1(%eax),%edx
80108bbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bbf:	89 10                	mov    %edx,(%eax)
  while(1){
80108bc1:	eb 90                	jmp    80108b53 <i8254_recv+0x3a>

80108bc3 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80108bc3:	55                   	push   %ebp
80108bc4:	89 e5                	mov    %esp,%ebp
80108bc6:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80108bc9:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108bce:	05 10 38 00 00       	add    $0x3810,%eax
80108bd3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108bd6:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108bdb:	05 18 38 00 00       	add    $0x3818,%eax
80108be0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108be3:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108be8:	05 00 38 00 00       	add    $0x3800,%eax
80108bed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80108bf0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bf3:	8b 00                	mov    (%eax),%eax
80108bf5:	05 00 00 00 80       	add    $0x80000000,%eax
80108bfa:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80108bfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c00:	8b 10                	mov    (%eax),%edx
80108c02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c05:	8b 08                	mov    (%eax),%ecx
80108c07:	89 d0                	mov    %edx,%eax
80108c09:	29 c8                	sub    %ecx,%eax
80108c0b:	0f b6 d0             	movzbl %al,%edx
80108c0e:	b8 00 01 00 00       	mov    $0x100,%eax
80108c13:	29 d0                	sub    %edx,%eax
80108c15:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80108c18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c1b:	8b 00                	mov    (%eax),%eax
80108c1d:	25 ff 00 00 00       	and    $0xff,%eax
80108c22:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80108c25:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108c29:	0f 8e a8 00 00 00    	jle    80108cd7 <i8254_send+0x114>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80108c2f:	8b 45 08             	mov    0x8(%ebp),%eax
80108c32:	8b 55 e0             	mov    -0x20(%ebp),%edx
80108c35:	89 d1                	mov    %edx,%ecx
80108c37:	c1 e1 04             	shl    $0x4,%ecx
80108c3a:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108c3d:	01 ca                	add    %ecx,%edx
80108c3f:	8b 12                	mov    (%edx),%edx
80108c41:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108c47:	83 ec 04             	sub    $0x4,%esp
80108c4a:	ff 75 0c             	push   0xc(%ebp)
80108c4d:	50                   	push   %eax
80108c4e:	52                   	push   %edx
80108c4f:	e8 4d bf ff ff       	call   80104ba1 <memmove>
80108c54:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80108c57:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c5a:	c1 e0 04             	shl    $0x4,%eax
80108c5d:	89 c2                	mov    %eax,%edx
80108c5f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c62:	01 d0                	add    %edx,%eax
80108c64:	8b 55 0c             	mov    0xc(%ebp),%edx
80108c67:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80108c6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c6e:	c1 e0 04             	shl    $0x4,%eax
80108c71:	89 c2                	mov    %eax,%edx
80108c73:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c76:	01 d0                	add    %edx,%eax
80108c78:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80108c7c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c7f:	c1 e0 04             	shl    $0x4,%eax
80108c82:	89 c2                	mov    %eax,%edx
80108c84:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c87:	01 d0                	add    %edx,%eax
80108c89:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80108c8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c90:	c1 e0 04             	shl    $0x4,%eax
80108c93:	89 c2                	mov    %eax,%edx
80108c95:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c98:	01 d0                	add    %edx,%eax
80108c9a:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80108c9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ca1:	c1 e0 04             	shl    $0x4,%eax
80108ca4:	89 c2                	mov    %eax,%edx
80108ca6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ca9:	01 d0                	add    %edx,%eax
80108cab:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80108cb1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108cb4:	c1 e0 04             	shl    $0x4,%eax
80108cb7:	89 c2                	mov    %eax,%edx
80108cb9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108cbc:	01 d0                	add    %edx,%eax
80108cbe:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80108cc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cc5:	8b 00                	mov    (%eax),%eax
80108cc7:	83 c0 01             	add    $0x1,%eax
80108cca:	0f b6 d0             	movzbl %al,%edx
80108ccd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cd0:	89 10                	mov    %edx,(%eax)
    return len;
80108cd2:	8b 45 0c             	mov    0xc(%ebp),%eax
80108cd5:	eb 05                	jmp    80108cdc <i8254_send+0x119>
  }else{
    return -1;
80108cd7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80108cdc:	c9                   	leave  
80108cdd:	c3                   	ret    

80108cde <i8254_intr>:

void i8254_intr(){
80108cde:	55                   	push   %ebp
80108cdf:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80108ce1:	a1 88 6c 19 80       	mov    0x80196c88,%eax
80108ce6:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80108cec:	90                   	nop
80108ced:	5d                   	pop    %ebp
80108cee:	c3                   	ret    

80108cef <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80108cef:	55                   	push   %ebp
80108cf0:	89 e5                	mov    %esp,%ebp
80108cf2:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80108cf5:	8b 45 08             	mov    0x8(%ebp),%eax
80108cf8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80108cfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cfe:	0f b7 00             	movzwl (%eax),%eax
80108d01:	66 3d 00 01          	cmp    $0x100,%ax
80108d05:	74 0a                	je     80108d11 <arp_proc+0x22>
80108d07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d0c:	e9 4f 01 00 00       	jmp    80108e60 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80108d11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d14:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80108d18:	66 83 f8 08          	cmp    $0x8,%ax
80108d1c:	74 0a                	je     80108d28 <arp_proc+0x39>
80108d1e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d23:	e9 38 01 00 00       	jmp    80108e60 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
80108d28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d2b:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80108d2f:	3c 06                	cmp    $0x6,%al
80108d31:	74 0a                	je     80108d3d <arp_proc+0x4e>
80108d33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d38:	e9 23 01 00 00       	jmp    80108e60 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80108d3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d40:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80108d44:	3c 04                	cmp    $0x4,%al
80108d46:	74 0a                	je     80108d52 <arp_proc+0x63>
80108d48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d4d:	e9 0e 01 00 00       	jmp    80108e60 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80108d52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d55:	83 c0 18             	add    $0x18,%eax
80108d58:	83 ec 04             	sub    $0x4,%esp
80108d5b:	6a 04                	push   $0x4
80108d5d:	50                   	push   %eax
80108d5e:	68 e4 f4 10 80       	push   $0x8010f4e4
80108d63:	e8 e1 bd ff ff       	call   80104b49 <memcmp>
80108d68:	83 c4 10             	add    $0x10,%esp
80108d6b:	85 c0                	test   %eax,%eax
80108d6d:	74 27                	je     80108d96 <arp_proc+0xa7>
80108d6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d72:	83 c0 0e             	add    $0xe,%eax
80108d75:	83 ec 04             	sub    $0x4,%esp
80108d78:	6a 04                	push   $0x4
80108d7a:	50                   	push   %eax
80108d7b:	68 e4 f4 10 80       	push   $0x8010f4e4
80108d80:	e8 c4 bd ff ff       	call   80104b49 <memcmp>
80108d85:	83 c4 10             	add    $0x10,%esp
80108d88:	85 c0                	test   %eax,%eax
80108d8a:	74 0a                	je     80108d96 <arp_proc+0xa7>
80108d8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d91:	e9 ca 00 00 00       	jmp    80108e60 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108d96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d99:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108d9d:	66 3d 00 01          	cmp    $0x100,%ax
80108da1:	75 69                	jne    80108e0c <arp_proc+0x11d>
80108da3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108da6:	83 c0 18             	add    $0x18,%eax
80108da9:	83 ec 04             	sub    $0x4,%esp
80108dac:	6a 04                	push   $0x4
80108dae:	50                   	push   %eax
80108daf:	68 e4 f4 10 80       	push   $0x8010f4e4
80108db4:	e8 90 bd ff ff       	call   80104b49 <memcmp>
80108db9:	83 c4 10             	add    $0x10,%esp
80108dbc:	85 c0                	test   %eax,%eax
80108dbe:	75 4c                	jne    80108e0c <arp_proc+0x11d>
    uint send = (uint)kalloc();
80108dc0:	e8 db 99 ff ff       	call   801027a0 <kalloc>
80108dc5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80108dc8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80108dcf:	83 ec 04             	sub    $0x4,%esp
80108dd2:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108dd5:	50                   	push   %eax
80108dd6:	ff 75 f0             	push   -0x10(%ebp)
80108dd9:	ff 75 f4             	push   -0xc(%ebp)
80108ddc:	e8 1f 04 00 00       	call   80109200 <arp_reply_pkt_create>
80108de1:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80108de4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108de7:	83 ec 08             	sub    $0x8,%esp
80108dea:	50                   	push   %eax
80108deb:	ff 75 f0             	push   -0x10(%ebp)
80108dee:	e8 d0 fd ff ff       	call   80108bc3 <i8254_send>
80108df3:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
80108df6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108df9:	83 ec 0c             	sub    $0xc,%esp
80108dfc:	50                   	push   %eax
80108dfd:	e8 04 99 ff ff       	call   80102706 <kfree>
80108e02:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
80108e05:	b8 02 00 00 00       	mov    $0x2,%eax
80108e0a:	eb 54                	jmp    80108e60 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108e0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e0f:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108e13:	66 3d 00 02          	cmp    $0x200,%ax
80108e17:	75 42                	jne    80108e5b <arp_proc+0x16c>
80108e19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e1c:	83 c0 18             	add    $0x18,%eax
80108e1f:	83 ec 04             	sub    $0x4,%esp
80108e22:	6a 04                	push   $0x4
80108e24:	50                   	push   %eax
80108e25:	68 e4 f4 10 80       	push   $0x8010f4e4
80108e2a:	e8 1a bd ff ff       	call   80104b49 <memcmp>
80108e2f:	83 c4 10             	add    $0x10,%esp
80108e32:	85 c0                	test   %eax,%eax
80108e34:	75 25                	jne    80108e5b <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
80108e36:	83 ec 0c             	sub    $0xc,%esp
80108e39:	68 1c c0 10 80       	push   $0x8010c01c
80108e3e:	e8 b1 75 ff ff       	call   801003f4 <cprintf>
80108e43:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
80108e46:	83 ec 0c             	sub    $0xc,%esp
80108e49:	ff 75 f4             	push   -0xc(%ebp)
80108e4c:	e8 af 01 00 00       	call   80109000 <arp_table_update>
80108e51:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80108e54:	b8 01 00 00 00       	mov    $0x1,%eax
80108e59:	eb 05                	jmp    80108e60 <arp_proc+0x171>
  }else{
    return -1;
80108e5b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80108e60:	c9                   	leave  
80108e61:	c3                   	ret    

80108e62 <arp_scan>:

void arp_scan(){
80108e62:	55                   	push   %ebp
80108e63:	89 e5                	mov    %esp,%ebp
80108e65:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80108e68:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108e6f:	eb 6f                	jmp    80108ee0 <arp_scan+0x7e>
    uint send = (uint)kalloc();
80108e71:	e8 2a 99 ff ff       	call   801027a0 <kalloc>
80108e76:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80108e79:	83 ec 04             	sub    $0x4,%esp
80108e7c:	ff 75 f4             	push   -0xc(%ebp)
80108e7f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80108e82:	50                   	push   %eax
80108e83:	ff 75 ec             	push   -0x14(%ebp)
80108e86:	e8 62 00 00 00       	call   80108eed <arp_broadcast>
80108e8b:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80108e8e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e91:	83 ec 08             	sub    $0x8,%esp
80108e94:	50                   	push   %eax
80108e95:	ff 75 ec             	push   -0x14(%ebp)
80108e98:	e8 26 fd ff ff       	call   80108bc3 <i8254_send>
80108e9d:	83 c4 10             	add    $0x10,%esp
80108ea0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80108ea3:	eb 22                	jmp    80108ec7 <arp_scan+0x65>
      microdelay(1);
80108ea5:	83 ec 0c             	sub    $0xc,%esp
80108ea8:	6a 01                	push   $0x1
80108eaa:	e8 88 9c ff ff       	call   80102b37 <microdelay>
80108eaf:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80108eb2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108eb5:	83 ec 08             	sub    $0x8,%esp
80108eb8:	50                   	push   %eax
80108eb9:	ff 75 ec             	push   -0x14(%ebp)
80108ebc:	e8 02 fd ff ff       	call   80108bc3 <i8254_send>
80108ec1:	83 c4 10             	add    $0x10,%esp
80108ec4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80108ec7:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80108ecb:	74 d8                	je     80108ea5 <arp_scan+0x43>
    }
    kfree((char *)send);
80108ecd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ed0:	83 ec 0c             	sub    $0xc,%esp
80108ed3:	50                   	push   %eax
80108ed4:	e8 2d 98 ff ff       	call   80102706 <kfree>
80108ed9:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80108edc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108ee0:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108ee7:	7e 88                	jle    80108e71 <arp_scan+0xf>
  }
}
80108ee9:	90                   	nop
80108eea:	90                   	nop
80108eeb:	c9                   	leave  
80108eec:	c3                   	ret    

80108eed <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80108eed:	55                   	push   %ebp
80108eee:	89 e5                	mov    %esp,%ebp
80108ef0:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80108ef3:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
80108ef7:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80108efb:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80108eff:	8b 45 10             	mov    0x10(%ebp),%eax
80108f02:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80108f05:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80108f0c:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80108f12:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108f19:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80108f1f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f22:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80108f28:	8b 45 08             	mov    0x8(%ebp),%eax
80108f2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80108f2e:	8b 45 08             	mov    0x8(%ebp),%eax
80108f31:	83 c0 0e             	add    $0xe,%eax
80108f34:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80108f37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f3a:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80108f3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f41:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80108f45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f48:	83 ec 04             	sub    $0x4,%esp
80108f4b:	6a 06                	push   $0x6
80108f4d:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80108f50:	52                   	push   %edx
80108f51:	50                   	push   %eax
80108f52:	e8 4a bc ff ff       	call   80104ba1 <memmove>
80108f57:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80108f5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f5d:	83 c0 06             	add    $0x6,%eax
80108f60:	83 ec 04             	sub    $0x4,%esp
80108f63:	6a 06                	push   $0x6
80108f65:	68 80 6c 19 80       	push   $0x80196c80
80108f6a:	50                   	push   %eax
80108f6b:	e8 31 bc ff ff       	call   80104ba1 <memmove>
80108f70:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80108f73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f76:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80108f7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f7e:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80108f84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f87:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80108f8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f8e:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80108f92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f95:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80108f9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f9e:	8d 50 12             	lea    0x12(%eax),%edx
80108fa1:	83 ec 04             	sub    $0x4,%esp
80108fa4:	6a 06                	push   $0x6
80108fa6:	8d 45 e0             	lea    -0x20(%ebp),%eax
80108fa9:	50                   	push   %eax
80108faa:	52                   	push   %edx
80108fab:	e8 f1 bb ff ff       	call   80104ba1 <memmove>
80108fb0:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80108fb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fb6:	8d 50 18             	lea    0x18(%eax),%edx
80108fb9:	83 ec 04             	sub    $0x4,%esp
80108fbc:	6a 04                	push   $0x4
80108fbe:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108fc1:	50                   	push   %eax
80108fc2:	52                   	push   %edx
80108fc3:	e8 d9 bb ff ff       	call   80104ba1 <memmove>
80108fc8:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80108fcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fce:	83 c0 08             	add    $0x8,%eax
80108fd1:	83 ec 04             	sub    $0x4,%esp
80108fd4:	6a 06                	push   $0x6
80108fd6:	68 80 6c 19 80       	push   $0x80196c80
80108fdb:	50                   	push   %eax
80108fdc:	e8 c0 bb ff ff       	call   80104ba1 <memmove>
80108fe1:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80108fe4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fe7:	83 c0 0e             	add    $0xe,%eax
80108fea:	83 ec 04             	sub    $0x4,%esp
80108fed:	6a 04                	push   $0x4
80108fef:	68 e4 f4 10 80       	push   $0x8010f4e4
80108ff4:	50                   	push   %eax
80108ff5:	e8 a7 bb ff ff       	call   80104ba1 <memmove>
80108ffa:	83 c4 10             	add    $0x10,%esp
}
80108ffd:	90                   	nop
80108ffe:	c9                   	leave  
80108fff:	c3                   	ret    

80109000 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80109000:	55                   	push   %ebp
80109001:	89 e5                	mov    %esp,%ebp
80109003:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80109006:	8b 45 08             	mov    0x8(%ebp),%eax
80109009:	83 c0 0e             	add    $0xe,%eax
8010900c:	83 ec 0c             	sub    $0xc,%esp
8010900f:	50                   	push   %eax
80109010:	e8 bc 00 00 00       	call   801090d1 <arp_table_search>
80109015:	83 c4 10             	add    $0x10,%esp
80109018:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
8010901b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010901f:	78 2d                	js     8010904e <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109021:	8b 45 08             	mov    0x8(%ebp),%eax
80109024:	8d 48 08             	lea    0x8(%eax),%ecx
80109027:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010902a:	89 d0                	mov    %edx,%eax
8010902c:	c1 e0 02             	shl    $0x2,%eax
8010902f:	01 d0                	add    %edx,%eax
80109031:	01 c0                	add    %eax,%eax
80109033:	01 d0                	add    %edx,%eax
80109035:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
8010903a:	83 c0 04             	add    $0x4,%eax
8010903d:	83 ec 04             	sub    $0x4,%esp
80109040:	6a 06                	push   $0x6
80109042:	51                   	push   %ecx
80109043:	50                   	push   %eax
80109044:	e8 58 bb ff ff       	call   80104ba1 <memmove>
80109049:	83 c4 10             	add    $0x10,%esp
8010904c:	eb 70                	jmp    801090be <arp_table_update+0xbe>
  }else{
    index += 1;
8010904e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109052:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109055:	8b 45 08             	mov    0x8(%ebp),%eax
80109058:	8d 48 08             	lea    0x8(%eax),%ecx
8010905b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010905e:	89 d0                	mov    %edx,%eax
80109060:	c1 e0 02             	shl    $0x2,%eax
80109063:	01 d0                	add    %edx,%eax
80109065:	01 c0                	add    %eax,%eax
80109067:	01 d0                	add    %edx,%eax
80109069:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
8010906e:	83 c0 04             	add    $0x4,%eax
80109071:	83 ec 04             	sub    $0x4,%esp
80109074:	6a 06                	push   $0x6
80109076:	51                   	push   %ecx
80109077:	50                   	push   %eax
80109078:	e8 24 bb ff ff       	call   80104ba1 <memmove>
8010907d:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109080:	8b 45 08             	mov    0x8(%ebp),%eax
80109083:	8d 48 0e             	lea    0xe(%eax),%ecx
80109086:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109089:	89 d0                	mov    %edx,%eax
8010908b:	c1 e0 02             	shl    $0x2,%eax
8010908e:	01 d0                	add    %edx,%eax
80109090:	01 c0                	add    %eax,%eax
80109092:	01 d0                	add    %edx,%eax
80109094:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
80109099:	83 ec 04             	sub    $0x4,%esp
8010909c:	6a 04                	push   $0x4
8010909e:	51                   	push   %ecx
8010909f:	50                   	push   %eax
801090a0:	e8 fc ba ff ff       	call   80104ba1 <memmove>
801090a5:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
801090a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801090ab:	89 d0                	mov    %edx,%eax
801090ad:	c1 e0 02             	shl    $0x2,%eax
801090b0:	01 d0                	add    %edx,%eax
801090b2:	01 c0                	add    %eax,%eax
801090b4:	01 d0                	add    %edx,%eax
801090b6:	05 aa 6c 19 80       	add    $0x80196caa,%eax
801090bb:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
801090be:	83 ec 0c             	sub    $0xc,%esp
801090c1:	68 a0 6c 19 80       	push   $0x80196ca0
801090c6:	e8 83 00 00 00       	call   8010914e <print_arp_table>
801090cb:	83 c4 10             	add    $0x10,%esp
}
801090ce:	90                   	nop
801090cf:	c9                   	leave  
801090d0:	c3                   	ret    

801090d1 <arp_table_search>:

int arp_table_search(uchar *ip){
801090d1:	55                   	push   %ebp
801090d2:	89 e5                	mov    %esp,%ebp
801090d4:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
801090d7:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801090de:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801090e5:	eb 59                	jmp    80109140 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
801090e7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801090ea:	89 d0                	mov    %edx,%eax
801090ec:	c1 e0 02             	shl    $0x2,%eax
801090ef:	01 d0                	add    %edx,%eax
801090f1:	01 c0                	add    %eax,%eax
801090f3:	01 d0                	add    %edx,%eax
801090f5:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
801090fa:	83 ec 04             	sub    $0x4,%esp
801090fd:	6a 04                	push   $0x4
801090ff:	ff 75 08             	push   0x8(%ebp)
80109102:	50                   	push   %eax
80109103:	e8 41 ba ff ff       	call   80104b49 <memcmp>
80109108:	83 c4 10             	add    $0x10,%esp
8010910b:	85 c0                	test   %eax,%eax
8010910d:	75 05                	jne    80109114 <arp_table_search+0x43>
      return i;
8010910f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109112:	eb 38                	jmp    8010914c <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
80109114:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109117:	89 d0                	mov    %edx,%eax
80109119:	c1 e0 02             	shl    $0x2,%eax
8010911c:	01 d0                	add    %edx,%eax
8010911e:	01 c0                	add    %eax,%eax
80109120:	01 d0                	add    %edx,%eax
80109122:	05 aa 6c 19 80       	add    $0x80196caa,%eax
80109127:	0f b6 00             	movzbl (%eax),%eax
8010912a:	84 c0                	test   %al,%al
8010912c:	75 0e                	jne    8010913c <arp_table_search+0x6b>
8010912e:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109132:	75 08                	jne    8010913c <arp_table_search+0x6b>
      empty = -i;
80109134:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109137:	f7 d8                	neg    %eax
80109139:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
8010913c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109140:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80109144:	7e a1                	jle    801090e7 <arp_table_search+0x16>
    }
  }
  return empty-1;
80109146:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109149:	83 e8 01             	sub    $0x1,%eax
}
8010914c:	c9                   	leave  
8010914d:	c3                   	ret    

8010914e <print_arp_table>:

void print_arp_table(){
8010914e:	55                   	push   %ebp
8010914f:	89 e5                	mov    %esp,%ebp
80109151:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109154:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010915b:	e9 92 00 00 00       	jmp    801091f2 <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
80109160:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109163:	89 d0                	mov    %edx,%eax
80109165:	c1 e0 02             	shl    $0x2,%eax
80109168:	01 d0                	add    %edx,%eax
8010916a:	01 c0                	add    %eax,%eax
8010916c:	01 d0                	add    %edx,%eax
8010916e:	05 aa 6c 19 80       	add    $0x80196caa,%eax
80109173:	0f b6 00             	movzbl (%eax),%eax
80109176:	84 c0                	test   %al,%al
80109178:	74 74                	je     801091ee <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
8010917a:	83 ec 08             	sub    $0x8,%esp
8010917d:	ff 75 f4             	push   -0xc(%ebp)
80109180:	68 2f c0 10 80       	push   $0x8010c02f
80109185:	e8 6a 72 ff ff       	call   801003f4 <cprintf>
8010918a:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
8010918d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109190:	89 d0                	mov    %edx,%eax
80109192:	c1 e0 02             	shl    $0x2,%eax
80109195:	01 d0                	add    %edx,%eax
80109197:	01 c0                	add    %eax,%eax
80109199:	01 d0                	add    %edx,%eax
8010919b:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
801091a0:	83 ec 0c             	sub    $0xc,%esp
801091a3:	50                   	push   %eax
801091a4:	e8 54 02 00 00       	call   801093fd <print_ipv4>
801091a9:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
801091ac:	83 ec 0c             	sub    $0xc,%esp
801091af:	68 3e c0 10 80       	push   $0x8010c03e
801091b4:	e8 3b 72 ff ff       	call   801003f4 <cprintf>
801091b9:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
801091bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801091bf:	89 d0                	mov    %edx,%eax
801091c1:	c1 e0 02             	shl    $0x2,%eax
801091c4:	01 d0                	add    %edx,%eax
801091c6:	01 c0                	add    %eax,%eax
801091c8:	01 d0                	add    %edx,%eax
801091ca:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
801091cf:	83 c0 04             	add    $0x4,%eax
801091d2:	83 ec 0c             	sub    $0xc,%esp
801091d5:	50                   	push   %eax
801091d6:	e8 70 02 00 00       	call   8010944b <print_mac>
801091db:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
801091de:	83 ec 0c             	sub    $0xc,%esp
801091e1:	68 40 c0 10 80       	push   $0x8010c040
801091e6:	e8 09 72 ff ff       	call   801003f4 <cprintf>
801091eb:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801091ee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801091f2:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801091f6:	0f 8e 64 ff ff ff    	jle    80109160 <print_arp_table+0x12>
    }
  }
}
801091fc:	90                   	nop
801091fd:	90                   	nop
801091fe:	c9                   	leave  
801091ff:	c3                   	ret    

80109200 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
80109200:	55                   	push   %ebp
80109201:	89 e5                	mov    %esp,%ebp
80109203:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109206:	8b 45 10             	mov    0x10(%ebp),%eax
80109209:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
8010920f:	8b 45 0c             	mov    0xc(%ebp),%eax
80109212:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109215:	8b 45 0c             	mov    0xc(%ebp),%eax
80109218:	83 c0 0e             	add    $0xe,%eax
8010921b:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
8010921e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109221:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109225:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109228:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
8010922c:	8b 45 08             	mov    0x8(%ebp),%eax
8010922f:	8d 50 08             	lea    0x8(%eax),%edx
80109232:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109235:	83 ec 04             	sub    $0x4,%esp
80109238:	6a 06                	push   $0x6
8010923a:	52                   	push   %edx
8010923b:	50                   	push   %eax
8010923c:	e8 60 b9 ff ff       	call   80104ba1 <memmove>
80109241:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109244:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109247:	83 c0 06             	add    $0x6,%eax
8010924a:	83 ec 04             	sub    $0x4,%esp
8010924d:	6a 06                	push   $0x6
8010924f:	68 80 6c 19 80       	push   $0x80196c80
80109254:	50                   	push   %eax
80109255:	e8 47 b9 ff ff       	call   80104ba1 <memmove>
8010925a:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
8010925d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109260:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109265:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109268:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
8010926e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109271:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109275:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109278:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
8010927c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010927f:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109285:	8b 45 08             	mov    0x8(%ebp),%eax
80109288:	8d 50 08             	lea    0x8(%eax),%edx
8010928b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010928e:	83 c0 12             	add    $0x12,%eax
80109291:	83 ec 04             	sub    $0x4,%esp
80109294:	6a 06                	push   $0x6
80109296:	52                   	push   %edx
80109297:	50                   	push   %eax
80109298:	e8 04 b9 ff ff       	call   80104ba1 <memmove>
8010929d:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
801092a0:	8b 45 08             	mov    0x8(%ebp),%eax
801092a3:	8d 50 0e             	lea    0xe(%eax),%edx
801092a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092a9:	83 c0 18             	add    $0x18,%eax
801092ac:	83 ec 04             	sub    $0x4,%esp
801092af:	6a 04                	push   $0x4
801092b1:	52                   	push   %edx
801092b2:	50                   	push   %eax
801092b3:	e8 e9 b8 ff ff       	call   80104ba1 <memmove>
801092b8:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801092bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092be:	83 c0 08             	add    $0x8,%eax
801092c1:	83 ec 04             	sub    $0x4,%esp
801092c4:	6a 06                	push   $0x6
801092c6:	68 80 6c 19 80       	push   $0x80196c80
801092cb:	50                   	push   %eax
801092cc:	e8 d0 b8 ff ff       	call   80104ba1 <memmove>
801092d1:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801092d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092d7:	83 c0 0e             	add    $0xe,%eax
801092da:	83 ec 04             	sub    $0x4,%esp
801092dd:	6a 04                	push   $0x4
801092df:	68 e4 f4 10 80       	push   $0x8010f4e4
801092e4:	50                   	push   %eax
801092e5:	e8 b7 b8 ff ff       	call   80104ba1 <memmove>
801092ea:	83 c4 10             	add    $0x10,%esp
}
801092ed:	90                   	nop
801092ee:	c9                   	leave  
801092ef:	c3                   	ret    

801092f0 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
801092f0:	55                   	push   %ebp
801092f1:	89 e5                	mov    %esp,%ebp
801092f3:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
801092f6:	83 ec 0c             	sub    $0xc,%esp
801092f9:	68 42 c0 10 80       	push   $0x8010c042
801092fe:	e8 f1 70 ff ff       	call   801003f4 <cprintf>
80109303:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
80109306:	8b 45 08             	mov    0x8(%ebp),%eax
80109309:	83 c0 0e             	add    $0xe,%eax
8010930c:	83 ec 0c             	sub    $0xc,%esp
8010930f:	50                   	push   %eax
80109310:	e8 e8 00 00 00       	call   801093fd <print_ipv4>
80109315:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109318:	83 ec 0c             	sub    $0xc,%esp
8010931b:	68 40 c0 10 80       	push   $0x8010c040
80109320:	e8 cf 70 ff ff       	call   801003f4 <cprintf>
80109325:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
80109328:	8b 45 08             	mov    0x8(%ebp),%eax
8010932b:	83 c0 08             	add    $0x8,%eax
8010932e:	83 ec 0c             	sub    $0xc,%esp
80109331:	50                   	push   %eax
80109332:	e8 14 01 00 00       	call   8010944b <print_mac>
80109337:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010933a:	83 ec 0c             	sub    $0xc,%esp
8010933d:	68 40 c0 10 80       	push   $0x8010c040
80109342:	e8 ad 70 ff ff       	call   801003f4 <cprintf>
80109347:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
8010934a:	83 ec 0c             	sub    $0xc,%esp
8010934d:	68 59 c0 10 80       	push   $0x8010c059
80109352:	e8 9d 70 ff ff       	call   801003f4 <cprintf>
80109357:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
8010935a:	8b 45 08             	mov    0x8(%ebp),%eax
8010935d:	83 c0 18             	add    $0x18,%eax
80109360:	83 ec 0c             	sub    $0xc,%esp
80109363:	50                   	push   %eax
80109364:	e8 94 00 00 00       	call   801093fd <print_ipv4>
80109369:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010936c:	83 ec 0c             	sub    $0xc,%esp
8010936f:	68 40 c0 10 80       	push   $0x8010c040
80109374:	e8 7b 70 ff ff       	call   801003f4 <cprintf>
80109379:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
8010937c:	8b 45 08             	mov    0x8(%ebp),%eax
8010937f:	83 c0 12             	add    $0x12,%eax
80109382:	83 ec 0c             	sub    $0xc,%esp
80109385:	50                   	push   %eax
80109386:	e8 c0 00 00 00       	call   8010944b <print_mac>
8010938b:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010938e:	83 ec 0c             	sub    $0xc,%esp
80109391:	68 40 c0 10 80       	push   $0x8010c040
80109396:	e8 59 70 ff ff       	call   801003f4 <cprintf>
8010939b:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
8010939e:	83 ec 0c             	sub    $0xc,%esp
801093a1:	68 70 c0 10 80       	push   $0x8010c070
801093a6:	e8 49 70 ff ff       	call   801003f4 <cprintf>
801093ab:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
801093ae:	8b 45 08             	mov    0x8(%ebp),%eax
801093b1:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801093b5:	66 3d 00 01          	cmp    $0x100,%ax
801093b9:	75 12                	jne    801093cd <print_arp_info+0xdd>
801093bb:	83 ec 0c             	sub    $0xc,%esp
801093be:	68 7c c0 10 80       	push   $0x8010c07c
801093c3:	e8 2c 70 ff ff       	call   801003f4 <cprintf>
801093c8:	83 c4 10             	add    $0x10,%esp
801093cb:	eb 1d                	jmp    801093ea <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
801093cd:	8b 45 08             	mov    0x8(%ebp),%eax
801093d0:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801093d4:	66 3d 00 02          	cmp    $0x200,%ax
801093d8:	75 10                	jne    801093ea <print_arp_info+0xfa>
    cprintf("Reply\n");
801093da:	83 ec 0c             	sub    $0xc,%esp
801093dd:	68 85 c0 10 80       	push   $0x8010c085
801093e2:	e8 0d 70 ff ff       	call   801003f4 <cprintf>
801093e7:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
801093ea:	83 ec 0c             	sub    $0xc,%esp
801093ed:	68 40 c0 10 80       	push   $0x8010c040
801093f2:	e8 fd 6f ff ff       	call   801003f4 <cprintf>
801093f7:	83 c4 10             	add    $0x10,%esp
}
801093fa:	90                   	nop
801093fb:	c9                   	leave  
801093fc:	c3                   	ret    

801093fd <print_ipv4>:

void print_ipv4(uchar *ip){
801093fd:	55                   	push   %ebp
801093fe:	89 e5                	mov    %esp,%ebp
80109400:	53                   	push   %ebx
80109401:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
80109404:	8b 45 08             	mov    0x8(%ebp),%eax
80109407:	83 c0 03             	add    $0x3,%eax
8010940a:	0f b6 00             	movzbl (%eax),%eax
8010940d:	0f b6 d8             	movzbl %al,%ebx
80109410:	8b 45 08             	mov    0x8(%ebp),%eax
80109413:	83 c0 02             	add    $0x2,%eax
80109416:	0f b6 00             	movzbl (%eax),%eax
80109419:	0f b6 c8             	movzbl %al,%ecx
8010941c:	8b 45 08             	mov    0x8(%ebp),%eax
8010941f:	83 c0 01             	add    $0x1,%eax
80109422:	0f b6 00             	movzbl (%eax),%eax
80109425:	0f b6 d0             	movzbl %al,%edx
80109428:	8b 45 08             	mov    0x8(%ebp),%eax
8010942b:	0f b6 00             	movzbl (%eax),%eax
8010942e:	0f b6 c0             	movzbl %al,%eax
80109431:	83 ec 0c             	sub    $0xc,%esp
80109434:	53                   	push   %ebx
80109435:	51                   	push   %ecx
80109436:	52                   	push   %edx
80109437:	50                   	push   %eax
80109438:	68 8c c0 10 80       	push   $0x8010c08c
8010943d:	e8 b2 6f ff ff       	call   801003f4 <cprintf>
80109442:	83 c4 20             	add    $0x20,%esp
}
80109445:	90                   	nop
80109446:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109449:	c9                   	leave  
8010944a:	c3                   	ret    

8010944b <print_mac>:

void print_mac(uchar *mac){
8010944b:	55                   	push   %ebp
8010944c:	89 e5                	mov    %esp,%ebp
8010944e:	57                   	push   %edi
8010944f:	56                   	push   %esi
80109450:	53                   	push   %ebx
80109451:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109454:	8b 45 08             	mov    0x8(%ebp),%eax
80109457:	83 c0 05             	add    $0x5,%eax
8010945a:	0f b6 00             	movzbl (%eax),%eax
8010945d:	0f b6 f8             	movzbl %al,%edi
80109460:	8b 45 08             	mov    0x8(%ebp),%eax
80109463:	83 c0 04             	add    $0x4,%eax
80109466:	0f b6 00             	movzbl (%eax),%eax
80109469:	0f b6 f0             	movzbl %al,%esi
8010946c:	8b 45 08             	mov    0x8(%ebp),%eax
8010946f:	83 c0 03             	add    $0x3,%eax
80109472:	0f b6 00             	movzbl (%eax),%eax
80109475:	0f b6 d8             	movzbl %al,%ebx
80109478:	8b 45 08             	mov    0x8(%ebp),%eax
8010947b:	83 c0 02             	add    $0x2,%eax
8010947e:	0f b6 00             	movzbl (%eax),%eax
80109481:	0f b6 c8             	movzbl %al,%ecx
80109484:	8b 45 08             	mov    0x8(%ebp),%eax
80109487:	83 c0 01             	add    $0x1,%eax
8010948a:	0f b6 00             	movzbl (%eax),%eax
8010948d:	0f b6 d0             	movzbl %al,%edx
80109490:	8b 45 08             	mov    0x8(%ebp),%eax
80109493:	0f b6 00             	movzbl (%eax),%eax
80109496:	0f b6 c0             	movzbl %al,%eax
80109499:	83 ec 04             	sub    $0x4,%esp
8010949c:	57                   	push   %edi
8010949d:	56                   	push   %esi
8010949e:	53                   	push   %ebx
8010949f:	51                   	push   %ecx
801094a0:	52                   	push   %edx
801094a1:	50                   	push   %eax
801094a2:	68 a4 c0 10 80       	push   $0x8010c0a4
801094a7:	e8 48 6f ff ff       	call   801003f4 <cprintf>
801094ac:	83 c4 20             	add    $0x20,%esp
}
801094af:	90                   	nop
801094b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801094b3:	5b                   	pop    %ebx
801094b4:	5e                   	pop    %esi
801094b5:	5f                   	pop    %edi
801094b6:	5d                   	pop    %ebp
801094b7:	c3                   	ret    

801094b8 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
801094b8:	55                   	push   %ebp
801094b9:	89 e5                	mov    %esp,%ebp
801094bb:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
801094be:	8b 45 08             	mov    0x8(%ebp),%eax
801094c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
801094c4:	8b 45 08             	mov    0x8(%ebp),%eax
801094c7:	83 c0 0e             	add    $0xe,%eax
801094ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
801094cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094d0:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801094d4:	3c 08                	cmp    $0x8,%al
801094d6:	75 1b                	jne    801094f3 <eth_proc+0x3b>
801094d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094db:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801094df:	3c 06                	cmp    $0x6,%al
801094e1:	75 10                	jne    801094f3 <eth_proc+0x3b>
    arp_proc(pkt_addr);
801094e3:	83 ec 0c             	sub    $0xc,%esp
801094e6:	ff 75 f0             	push   -0x10(%ebp)
801094e9:	e8 01 f8 ff ff       	call   80108cef <arp_proc>
801094ee:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
801094f1:	eb 24                	jmp    80109517 <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
801094f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094f6:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801094fa:	3c 08                	cmp    $0x8,%al
801094fc:	75 19                	jne    80109517 <eth_proc+0x5f>
801094fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109501:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109505:	84 c0                	test   %al,%al
80109507:	75 0e                	jne    80109517 <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
80109509:	83 ec 0c             	sub    $0xc,%esp
8010950c:	ff 75 08             	push   0x8(%ebp)
8010950f:	e8 a3 00 00 00       	call   801095b7 <ipv4_proc>
80109514:	83 c4 10             	add    $0x10,%esp
}
80109517:	90                   	nop
80109518:	c9                   	leave  
80109519:	c3                   	ret    

8010951a <N2H_ushort>:

ushort N2H_ushort(ushort value){
8010951a:	55                   	push   %ebp
8010951b:	89 e5                	mov    %esp,%ebp
8010951d:	83 ec 04             	sub    $0x4,%esp
80109520:	8b 45 08             	mov    0x8(%ebp),%eax
80109523:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109527:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010952b:	c1 e0 08             	shl    $0x8,%eax
8010952e:	89 c2                	mov    %eax,%edx
80109530:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109534:	66 c1 e8 08          	shr    $0x8,%ax
80109538:	01 d0                	add    %edx,%eax
}
8010953a:	c9                   	leave  
8010953b:	c3                   	ret    

8010953c <H2N_ushort>:

ushort H2N_ushort(ushort value){
8010953c:	55                   	push   %ebp
8010953d:	89 e5                	mov    %esp,%ebp
8010953f:	83 ec 04             	sub    $0x4,%esp
80109542:	8b 45 08             	mov    0x8(%ebp),%eax
80109545:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109549:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010954d:	c1 e0 08             	shl    $0x8,%eax
80109550:	89 c2                	mov    %eax,%edx
80109552:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109556:	66 c1 e8 08          	shr    $0x8,%ax
8010955a:	01 d0                	add    %edx,%eax
}
8010955c:	c9                   	leave  
8010955d:	c3                   	ret    

8010955e <H2N_uint>:

uint H2N_uint(uint value){
8010955e:	55                   	push   %ebp
8010955f:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109561:	8b 45 08             	mov    0x8(%ebp),%eax
80109564:	c1 e0 18             	shl    $0x18,%eax
80109567:	25 00 00 00 0f       	and    $0xf000000,%eax
8010956c:	89 c2                	mov    %eax,%edx
8010956e:	8b 45 08             	mov    0x8(%ebp),%eax
80109571:	c1 e0 08             	shl    $0x8,%eax
80109574:	25 00 f0 00 00       	and    $0xf000,%eax
80109579:	09 c2                	or     %eax,%edx
8010957b:	8b 45 08             	mov    0x8(%ebp),%eax
8010957e:	c1 e8 08             	shr    $0x8,%eax
80109581:	83 e0 0f             	and    $0xf,%eax
80109584:	01 d0                	add    %edx,%eax
}
80109586:	5d                   	pop    %ebp
80109587:	c3                   	ret    

80109588 <N2H_uint>:

uint N2H_uint(uint value){
80109588:	55                   	push   %ebp
80109589:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
8010958b:	8b 45 08             	mov    0x8(%ebp),%eax
8010958e:	c1 e0 18             	shl    $0x18,%eax
80109591:	89 c2                	mov    %eax,%edx
80109593:	8b 45 08             	mov    0x8(%ebp),%eax
80109596:	c1 e0 08             	shl    $0x8,%eax
80109599:	25 00 00 ff 00       	and    $0xff0000,%eax
8010959e:	01 c2                	add    %eax,%edx
801095a0:	8b 45 08             	mov    0x8(%ebp),%eax
801095a3:	c1 e8 08             	shr    $0x8,%eax
801095a6:	25 00 ff 00 00       	and    $0xff00,%eax
801095ab:	01 c2                	add    %eax,%edx
801095ad:	8b 45 08             	mov    0x8(%ebp),%eax
801095b0:	c1 e8 18             	shr    $0x18,%eax
801095b3:	01 d0                	add    %edx,%eax
}
801095b5:	5d                   	pop    %ebp
801095b6:	c3                   	ret    

801095b7 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
801095b7:	55                   	push   %ebp
801095b8:	89 e5                	mov    %esp,%ebp
801095ba:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
801095bd:	8b 45 08             	mov    0x8(%ebp),%eax
801095c0:	83 c0 0e             	add    $0xe,%eax
801095c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
801095c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095c9:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801095cd:	0f b7 d0             	movzwl %ax,%edx
801095d0:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
801095d5:	39 c2                	cmp    %eax,%edx
801095d7:	74 60                	je     80109639 <ipv4_proc+0x82>
801095d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095dc:	83 c0 0c             	add    $0xc,%eax
801095df:	83 ec 04             	sub    $0x4,%esp
801095e2:	6a 04                	push   $0x4
801095e4:	50                   	push   %eax
801095e5:	68 e4 f4 10 80       	push   $0x8010f4e4
801095ea:	e8 5a b5 ff ff       	call   80104b49 <memcmp>
801095ef:	83 c4 10             	add    $0x10,%esp
801095f2:	85 c0                	test   %eax,%eax
801095f4:	74 43                	je     80109639 <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
801095f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095f9:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801095fd:	0f b7 c0             	movzwl %ax,%eax
80109600:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109605:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109608:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010960c:	3c 01                	cmp    $0x1,%al
8010960e:	75 10                	jne    80109620 <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
80109610:	83 ec 0c             	sub    $0xc,%esp
80109613:	ff 75 08             	push   0x8(%ebp)
80109616:	e8 a3 00 00 00       	call   801096be <icmp_proc>
8010961b:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
8010961e:	eb 19                	jmp    80109639 <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109620:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109623:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109627:	3c 06                	cmp    $0x6,%al
80109629:	75 0e                	jne    80109639 <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
8010962b:	83 ec 0c             	sub    $0xc,%esp
8010962e:	ff 75 08             	push   0x8(%ebp)
80109631:	e8 b3 03 00 00       	call   801099e9 <tcp_proc>
80109636:	83 c4 10             	add    $0x10,%esp
}
80109639:	90                   	nop
8010963a:	c9                   	leave  
8010963b:	c3                   	ret    

8010963c <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
8010963c:	55                   	push   %ebp
8010963d:	89 e5                	mov    %esp,%ebp
8010963f:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109642:	8b 45 08             	mov    0x8(%ebp),%eax
80109645:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109648:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010964b:	0f b6 00             	movzbl (%eax),%eax
8010964e:	83 e0 0f             	and    $0xf,%eax
80109651:	01 c0                	add    %eax,%eax
80109653:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109656:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010965d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109664:	eb 48                	jmp    801096ae <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109666:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109669:	01 c0                	add    %eax,%eax
8010966b:	89 c2                	mov    %eax,%edx
8010966d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109670:	01 d0                	add    %edx,%eax
80109672:	0f b6 00             	movzbl (%eax),%eax
80109675:	0f b6 c0             	movzbl %al,%eax
80109678:	c1 e0 08             	shl    $0x8,%eax
8010967b:	89 c2                	mov    %eax,%edx
8010967d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109680:	01 c0                	add    %eax,%eax
80109682:	8d 48 01             	lea    0x1(%eax),%ecx
80109685:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109688:	01 c8                	add    %ecx,%eax
8010968a:	0f b6 00             	movzbl (%eax),%eax
8010968d:	0f b6 c0             	movzbl %al,%eax
80109690:	01 d0                	add    %edx,%eax
80109692:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109695:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010969c:	76 0c                	jbe    801096aa <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
8010969e:	8b 45 fc             	mov    -0x4(%ebp),%eax
801096a1:	0f b7 c0             	movzwl %ax,%eax
801096a4:	83 c0 01             	add    $0x1,%eax
801096a7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
801096aa:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801096ae:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
801096b2:	39 45 f8             	cmp    %eax,-0x8(%ebp)
801096b5:	7c af                	jl     80109666 <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
801096b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801096ba:	f7 d0                	not    %eax
}
801096bc:	c9                   	leave  
801096bd:	c3                   	ret    

801096be <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
801096be:	55                   	push   %ebp
801096bf:	89 e5                	mov    %esp,%ebp
801096c1:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
801096c4:	8b 45 08             	mov    0x8(%ebp),%eax
801096c7:	83 c0 0e             	add    $0xe,%eax
801096ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
801096cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096d0:	0f b6 00             	movzbl (%eax),%eax
801096d3:	0f b6 c0             	movzbl %al,%eax
801096d6:	83 e0 0f             	and    $0xf,%eax
801096d9:	c1 e0 02             	shl    $0x2,%eax
801096dc:	89 c2                	mov    %eax,%edx
801096de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096e1:	01 d0                	add    %edx,%eax
801096e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
801096e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096e9:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801096ed:	84 c0                	test   %al,%al
801096ef:	75 4f                	jne    80109740 <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
801096f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096f4:	0f b6 00             	movzbl (%eax),%eax
801096f7:	3c 08                	cmp    $0x8,%al
801096f9:	75 45                	jne    80109740 <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
801096fb:	e8 a0 90 ff ff       	call   801027a0 <kalloc>
80109700:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109703:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
8010970a:	83 ec 04             	sub    $0x4,%esp
8010970d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109710:	50                   	push   %eax
80109711:	ff 75 ec             	push   -0x14(%ebp)
80109714:	ff 75 08             	push   0x8(%ebp)
80109717:	e8 78 00 00 00       	call   80109794 <icmp_reply_pkt_create>
8010971c:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
8010971f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109722:	83 ec 08             	sub    $0x8,%esp
80109725:	50                   	push   %eax
80109726:	ff 75 ec             	push   -0x14(%ebp)
80109729:	e8 95 f4 ff ff       	call   80108bc3 <i8254_send>
8010972e:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109731:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109734:	83 ec 0c             	sub    $0xc,%esp
80109737:	50                   	push   %eax
80109738:	e8 c9 8f ff ff       	call   80102706 <kfree>
8010973d:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109740:	90                   	nop
80109741:	c9                   	leave  
80109742:	c3                   	ret    

80109743 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109743:	55                   	push   %ebp
80109744:	89 e5                	mov    %esp,%ebp
80109746:	53                   	push   %ebx
80109747:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
8010974a:	8b 45 08             	mov    0x8(%ebp),%eax
8010974d:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109751:	0f b7 c0             	movzwl %ax,%eax
80109754:	83 ec 0c             	sub    $0xc,%esp
80109757:	50                   	push   %eax
80109758:	e8 bd fd ff ff       	call   8010951a <N2H_ushort>
8010975d:	83 c4 10             	add    $0x10,%esp
80109760:	0f b7 d8             	movzwl %ax,%ebx
80109763:	8b 45 08             	mov    0x8(%ebp),%eax
80109766:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010976a:	0f b7 c0             	movzwl %ax,%eax
8010976d:	83 ec 0c             	sub    $0xc,%esp
80109770:	50                   	push   %eax
80109771:	e8 a4 fd ff ff       	call   8010951a <N2H_ushort>
80109776:	83 c4 10             	add    $0x10,%esp
80109779:	0f b7 c0             	movzwl %ax,%eax
8010977c:	83 ec 04             	sub    $0x4,%esp
8010977f:	53                   	push   %ebx
80109780:	50                   	push   %eax
80109781:	68 c3 c0 10 80       	push   $0x8010c0c3
80109786:	e8 69 6c ff ff       	call   801003f4 <cprintf>
8010978b:	83 c4 10             	add    $0x10,%esp
}
8010978e:	90                   	nop
8010978f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109792:	c9                   	leave  
80109793:	c3                   	ret    

80109794 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109794:	55                   	push   %ebp
80109795:	89 e5                	mov    %esp,%ebp
80109797:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010979a:	8b 45 08             	mov    0x8(%ebp),%eax
8010979d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
801097a0:	8b 45 08             	mov    0x8(%ebp),%eax
801097a3:	83 c0 0e             	add    $0xe,%eax
801097a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
801097a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097ac:	0f b6 00             	movzbl (%eax),%eax
801097af:	0f b6 c0             	movzbl %al,%eax
801097b2:	83 e0 0f             	and    $0xf,%eax
801097b5:	c1 e0 02             	shl    $0x2,%eax
801097b8:	89 c2                	mov    %eax,%edx
801097ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097bd:	01 d0                	add    %edx,%eax
801097bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
801097c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801097c5:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
801097c8:	8b 45 0c             	mov    0xc(%ebp),%eax
801097cb:	83 c0 0e             	add    $0xe,%eax
801097ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
801097d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801097d4:	83 c0 14             	add    $0x14,%eax
801097d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
801097da:	8b 45 10             	mov    0x10(%ebp),%eax
801097dd:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
801097e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097e6:	8d 50 06             	lea    0x6(%eax),%edx
801097e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801097ec:	83 ec 04             	sub    $0x4,%esp
801097ef:	6a 06                	push   $0x6
801097f1:	52                   	push   %edx
801097f2:	50                   	push   %eax
801097f3:	e8 a9 b3 ff ff       	call   80104ba1 <memmove>
801097f8:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
801097fb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801097fe:	83 c0 06             	add    $0x6,%eax
80109801:	83 ec 04             	sub    $0x4,%esp
80109804:	6a 06                	push   $0x6
80109806:	68 80 6c 19 80       	push   $0x80196c80
8010980b:	50                   	push   %eax
8010980c:	e8 90 b3 ff ff       	call   80104ba1 <memmove>
80109811:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109814:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109817:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010981b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010981e:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109822:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109825:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109828:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010982b:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
8010982f:	83 ec 0c             	sub    $0xc,%esp
80109832:	6a 54                	push   $0x54
80109834:	e8 03 fd ff ff       	call   8010953c <H2N_ushort>
80109839:	83 c4 10             	add    $0x10,%esp
8010983c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010983f:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109843:	0f b7 15 60 6f 19 80 	movzwl 0x80196f60,%edx
8010984a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010984d:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109851:	0f b7 05 60 6f 19 80 	movzwl 0x80196f60,%eax
80109858:	83 c0 01             	add    $0x1,%eax
8010985b:	66 a3 60 6f 19 80    	mov    %ax,0x80196f60
  ipv4_send->fragment = H2N_ushort(0x4000);
80109861:	83 ec 0c             	sub    $0xc,%esp
80109864:	68 00 40 00 00       	push   $0x4000
80109869:	e8 ce fc ff ff       	call   8010953c <H2N_ushort>
8010986e:	83 c4 10             	add    $0x10,%esp
80109871:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109874:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109878:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010987b:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
8010987f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109882:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109886:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109889:	83 c0 0c             	add    $0xc,%eax
8010988c:	83 ec 04             	sub    $0x4,%esp
8010988f:	6a 04                	push   $0x4
80109891:	68 e4 f4 10 80       	push   $0x8010f4e4
80109896:	50                   	push   %eax
80109897:	e8 05 b3 ff ff       	call   80104ba1 <memmove>
8010989c:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010989f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098a2:	8d 50 0c             	lea    0xc(%eax),%edx
801098a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801098a8:	83 c0 10             	add    $0x10,%eax
801098ab:	83 ec 04             	sub    $0x4,%esp
801098ae:	6a 04                	push   $0x4
801098b0:	52                   	push   %edx
801098b1:	50                   	push   %eax
801098b2:	e8 ea b2 ff ff       	call   80104ba1 <memmove>
801098b7:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
801098ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801098bd:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
801098c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801098c6:	83 ec 0c             	sub    $0xc,%esp
801098c9:	50                   	push   %eax
801098ca:	e8 6d fd ff ff       	call   8010963c <ipv4_chksum>
801098cf:	83 c4 10             	add    $0x10,%esp
801098d2:	0f b7 c0             	movzwl %ax,%eax
801098d5:	83 ec 0c             	sub    $0xc,%esp
801098d8:	50                   	push   %eax
801098d9:	e8 5e fc ff ff       	call   8010953c <H2N_ushort>
801098de:	83 c4 10             	add    $0x10,%esp
801098e1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801098e4:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
801098e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801098eb:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
801098ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
801098f1:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
801098f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801098f8:	0f b7 50 04          	movzwl 0x4(%eax),%edx
801098fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801098ff:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109903:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109906:	0f b7 50 06          	movzwl 0x6(%eax),%edx
8010990a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010990d:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109911:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109914:	8d 50 08             	lea    0x8(%eax),%edx
80109917:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010991a:	83 c0 08             	add    $0x8,%eax
8010991d:	83 ec 04             	sub    $0x4,%esp
80109920:	6a 08                	push   $0x8
80109922:	52                   	push   %edx
80109923:	50                   	push   %eax
80109924:	e8 78 b2 ff ff       	call   80104ba1 <memmove>
80109929:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
8010992c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010992f:	8d 50 10             	lea    0x10(%eax),%edx
80109932:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109935:	83 c0 10             	add    $0x10,%eax
80109938:	83 ec 04             	sub    $0x4,%esp
8010993b:	6a 30                	push   $0x30
8010993d:	52                   	push   %edx
8010993e:	50                   	push   %eax
8010993f:	e8 5d b2 ff ff       	call   80104ba1 <memmove>
80109944:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109947:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010994a:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109950:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109953:	83 ec 0c             	sub    $0xc,%esp
80109956:	50                   	push   %eax
80109957:	e8 1c 00 00 00       	call   80109978 <icmp_chksum>
8010995c:	83 c4 10             	add    $0x10,%esp
8010995f:	0f b7 c0             	movzwl %ax,%eax
80109962:	83 ec 0c             	sub    $0xc,%esp
80109965:	50                   	push   %eax
80109966:	e8 d1 fb ff ff       	call   8010953c <H2N_ushort>
8010996b:	83 c4 10             	add    $0x10,%esp
8010996e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109971:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109975:	90                   	nop
80109976:	c9                   	leave  
80109977:	c3                   	ret    

80109978 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109978:	55                   	push   %ebp
80109979:	89 e5                	mov    %esp,%ebp
8010997b:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
8010997e:	8b 45 08             	mov    0x8(%ebp),%eax
80109981:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109984:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010998b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109992:	eb 48                	jmp    801099dc <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109994:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109997:	01 c0                	add    %eax,%eax
80109999:	89 c2                	mov    %eax,%edx
8010999b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010999e:	01 d0                	add    %edx,%eax
801099a0:	0f b6 00             	movzbl (%eax),%eax
801099a3:	0f b6 c0             	movzbl %al,%eax
801099a6:	c1 e0 08             	shl    $0x8,%eax
801099a9:	89 c2                	mov    %eax,%edx
801099ab:	8b 45 f8             	mov    -0x8(%ebp),%eax
801099ae:	01 c0                	add    %eax,%eax
801099b0:	8d 48 01             	lea    0x1(%eax),%ecx
801099b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099b6:	01 c8                	add    %ecx,%eax
801099b8:	0f b6 00             	movzbl (%eax),%eax
801099bb:	0f b6 c0             	movzbl %al,%eax
801099be:	01 d0                	add    %edx,%eax
801099c0:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
801099c3:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
801099ca:	76 0c                	jbe    801099d8 <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
801099cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801099cf:	0f b7 c0             	movzwl %ax,%eax
801099d2:	83 c0 01             	add    $0x1,%eax
801099d5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
801099d8:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801099dc:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
801099e0:	7e b2                	jle    80109994 <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
801099e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801099e5:	f7 d0                	not    %eax
}
801099e7:	c9                   	leave  
801099e8:	c3                   	ret    

801099e9 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
801099e9:	55                   	push   %ebp
801099ea:	89 e5                	mov    %esp,%ebp
801099ec:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
801099ef:	8b 45 08             	mov    0x8(%ebp),%eax
801099f2:	83 c0 0e             	add    $0xe,%eax
801099f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
801099f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099fb:	0f b6 00             	movzbl (%eax),%eax
801099fe:	0f b6 c0             	movzbl %al,%eax
80109a01:	83 e0 0f             	and    $0xf,%eax
80109a04:	c1 e0 02             	shl    $0x2,%eax
80109a07:	89 c2                	mov    %eax,%edx
80109a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a0c:	01 d0                	add    %edx,%eax
80109a0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109a11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a14:	83 c0 14             	add    $0x14,%eax
80109a17:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109a1a:	e8 81 8d ff ff       	call   801027a0 <kalloc>
80109a1f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109a22:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109a29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a2c:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109a30:	0f b6 c0             	movzbl %al,%eax
80109a33:	83 e0 02             	and    $0x2,%eax
80109a36:	85 c0                	test   %eax,%eax
80109a38:	74 3d                	je     80109a77 <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109a3a:	83 ec 0c             	sub    $0xc,%esp
80109a3d:	6a 00                	push   $0x0
80109a3f:	6a 12                	push   $0x12
80109a41:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109a44:	50                   	push   %eax
80109a45:	ff 75 e8             	push   -0x18(%ebp)
80109a48:	ff 75 08             	push   0x8(%ebp)
80109a4b:	e8 a2 01 00 00       	call   80109bf2 <tcp_pkt_create>
80109a50:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109a53:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109a56:	83 ec 08             	sub    $0x8,%esp
80109a59:	50                   	push   %eax
80109a5a:	ff 75 e8             	push   -0x18(%ebp)
80109a5d:	e8 61 f1 ff ff       	call   80108bc3 <i8254_send>
80109a62:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109a65:	a1 64 6f 19 80       	mov    0x80196f64,%eax
80109a6a:	83 c0 01             	add    $0x1,%eax
80109a6d:	a3 64 6f 19 80       	mov    %eax,0x80196f64
80109a72:	e9 69 01 00 00       	jmp    80109be0 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109a77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a7a:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109a7e:	3c 18                	cmp    $0x18,%al
80109a80:	0f 85 10 01 00 00    	jne    80109b96 <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
80109a86:	83 ec 04             	sub    $0x4,%esp
80109a89:	6a 03                	push   $0x3
80109a8b:	68 de c0 10 80       	push   $0x8010c0de
80109a90:	ff 75 ec             	push   -0x14(%ebp)
80109a93:	e8 b1 b0 ff ff       	call   80104b49 <memcmp>
80109a98:	83 c4 10             	add    $0x10,%esp
80109a9b:	85 c0                	test   %eax,%eax
80109a9d:	74 74                	je     80109b13 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
80109a9f:	83 ec 0c             	sub    $0xc,%esp
80109aa2:	68 e2 c0 10 80       	push   $0x8010c0e2
80109aa7:	e8 48 69 ff ff       	call   801003f4 <cprintf>
80109aac:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109aaf:	83 ec 0c             	sub    $0xc,%esp
80109ab2:	6a 00                	push   $0x0
80109ab4:	6a 10                	push   $0x10
80109ab6:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109ab9:	50                   	push   %eax
80109aba:	ff 75 e8             	push   -0x18(%ebp)
80109abd:	ff 75 08             	push   0x8(%ebp)
80109ac0:	e8 2d 01 00 00       	call   80109bf2 <tcp_pkt_create>
80109ac5:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109ac8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109acb:	83 ec 08             	sub    $0x8,%esp
80109ace:	50                   	push   %eax
80109acf:	ff 75 e8             	push   -0x18(%ebp)
80109ad2:	e8 ec f0 ff ff       	call   80108bc3 <i8254_send>
80109ad7:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109ada:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109add:	83 c0 36             	add    $0x36,%eax
80109ae0:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109ae3:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109ae6:	50                   	push   %eax
80109ae7:	ff 75 e0             	push   -0x20(%ebp)
80109aea:	6a 00                	push   $0x0
80109aec:	6a 00                	push   $0x0
80109aee:	e8 5a 04 00 00       	call   80109f4d <http_proc>
80109af3:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109af6:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109af9:	83 ec 0c             	sub    $0xc,%esp
80109afc:	50                   	push   %eax
80109afd:	6a 18                	push   $0x18
80109aff:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109b02:	50                   	push   %eax
80109b03:	ff 75 e8             	push   -0x18(%ebp)
80109b06:	ff 75 08             	push   0x8(%ebp)
80109b09:	e8 e4 00 00 00       	call   80109bf2 <tcp_pkt_create>
80109b0e:	83 c4 20             	add    $0x20,%esp
80109b11:	eb 62                	jmp    80109b75 <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109b13:	83 ec 0c             	sub    $0xc,%esp
80109b16:	6a 00                	push   $0x0
80109b18:	6a 10                	push   $0x10
80109b1a:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109b1d:	50                   	push   %eax
80109b1e:	ff 75 e8             	push   -0x18(%ebp)
80109b21:	ff 75 08             	push   0x8(%ebp)
80109b24:	e8 c9 00 00 00       	call   80109bf2 <tcp_pkt_create>
80109b29:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
80109b2c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109b2f:	83 ec 08             	sub    $0x8,%esp
80109b32:	50                   	push   %eax
80109b33:	ff 75 e8             	push   -0x18(%ebp)
80109b36:	e8 88 f0 ff ff       	call   80108bc3 <i8254_send>
80109b3b:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109b3e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b41:	83 c0 36             	add    $0x36,%eax
80109b44:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109b47:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109b4a:	50                   	push   %eax
80109b4b:	ff 75 e4             	push   -0x1c(%ebp)
80109b4e:	6a 00                	push   $0x0
80109b50:	6a 00                	push   $0x0
80109b52:	e8 f6 03 00 00       	call   80109f4d <http_proc>
80109b57:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109b5a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109b5d:	83 ec 0c             	sub    $0xc,%esp
80109b60:	50                   	push   %eax
80109b61:	6a 18                	push   $0x18
80109b63:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109b66:	50                   	push   %eax
80109b67:	ff 75 e8             	push   -0x18(%ebp)
80109b6a:	ff 75 08             	push   0x8(%ebp)
80109b6d:	e8 80 00 00 00       	call   80109bf2 <tcp_pkt_create>
80109b72:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
80109b75:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109b78:	83 ec 08             	sub    $0x8,%esp
80109b7b:	50                   	push   %eax
80109b7c:	ff 75 e8             	push   -0x18(%ebp)
80109b7f:	e8 3f f0 ff ff       	call   80108bc3 <i8254_send>
80109b84:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109b87:	a1 64 6f 19 80       	mov    0x80196f64,%eax
80109b8c:	83 c0 01             	add    $0x1,%eax
80109b8f:	a3 64 6f 19 80       	mov    %eax,0x80196f64
80109b94:	eb 4a                	jmp    80109be0 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
80109b96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b99:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109b9d:	3c 10                	cmp    $0x10,%al
80109b9f:	75 3f                	jne    80109be0 <tcp_proc+0x1f7>
    if(fin_flag == 1){
80109ba1:	a1 68 6f 19 80       	mov    0x80196f68,%eax
80109ba6:	83 f8 01             	cmp    $0x1,%eax
80109ba9:	75 35                	jne    80109be0 <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
80109bab:	83 ec 0c             	sub    $0xc,%esp
80109bae:	6a 00                	push   $0x0
80109bb0:	6a 01                	push   $0x1
80109bb2:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109bb5:	50                   	push   %eax
80109bb6:	ff 75 e8             	push   -0x18(%ebp)
80109bb9:	ff 75 08             	push   0x8(%ebp)
80109bbc:	e8 31 00 00 00       	call   80109bf2 <tcp_pkt_create>
80109bc1:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109bc4:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109bc7:	83 ec 08             	sub    $0x8,%esp
80109bca:	50                   	push   %eax
80109bcb:	ff 75 e8             	push   -0x18(%ebp)
80109bce:	e8 f0 ef ff ff       	call   80108bc3 <i8254_send>
80109bd3:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
80109bd6:	c7 05 68 6f 19 80 00 	movl   $0x0,0x80196f68
80109bdd:	00 00 00 
    }
  }
  kfree((char *)send_addr);
80109be0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109be3:	83 ec 0c             	sub    $0xc,%esp
80109be6:	50                   	push   %eax
80109be7:	e8 1a 8b ff ff       	call   80102706 <kfree>
80109bec:	83 c4 10             	add    $0x10,%esp
}
80109bef:	90                   	nop
80109bf0:	c9                   	leave  
80109bf1:	c3                   	ret    

80109bf2 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
80109bf2:	55                   	push   %ebp
80109bf3:	89 e5                	mov    %esp,%ebp
80109bf5:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109bf8:	8b 45 08             	mov    0x8(%ebp),%eax
80109bfb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109bfe:	8b 45 08             	mov    0x8(%ebp),%eax
80109c01:	83 c0 0e             	add    $0xe,%eax
80109c04:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
80109c07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c0a:	0f b6 00             	movzbl (%eax),%eax
80109c0d:	0f b6 c0             	movzbl %al,%eax
80109c10:	83 e0 0f             	and    $0xf,%eax
80109c13:	c1 e0 02             	shl    $0x2,%eax
80109c16:	89 c2                	mov    %eax,%edx
80109c18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c1b:	01 d0                	add    %edx,%eax
80109c1d:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109c20:	8b 45 0c             	mov    0xc(%ebp),%eax
80109c23:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
80109c26:	8b 45 0c             	mov    0xc(%ebp),%eax
80109c29:	83 c0 0e             	add    $0xe,%eax
80109c2c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
80109c2f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c32:	83 c0 14             	add    $0x14,%eax
80109c35:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
80109c38:	8b 45 18             	mov    0x18(%ebp),%eax
80109c3b:	8d 50 36             	lea    0x36(%eax),%edx
80109c3e:	8b 45 10             	mov    0x10(%ebp),%eax
80109c41:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c46:	8d 50 06             	lea    0x6(%eax),%edx
80109c49:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c4c:	83 ec 04             	sub    $0x4,%esp
80109c4f:	6a 06                	push   $0x6
80109c51:	52                   	push   %edx
80109c52:	50                   	push   %eax
80109c53:	e8 49 af ff ff       	call   80104ba1 <memmove>
80109c58:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109c5b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c5e:	83 c0 06             	add    $0x6,%eax
80109c61:	83 ec 04             	sub    $0x4,%esp
80109c64:	6a 06                	push   $0x6
80109c66:	68 80 6c 19 80       	push   $0x80196c80
80109c6b:	50                   	push   %eax
80109c6c:	e8 30 af ff ff       	call   80104ba1 <memmove>
80109c71:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109c74:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c77:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109c7b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c7e:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109c82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c85:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109c88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c8b:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
80109c8f:	8b 45 18             	mov    0x18(%ebp),%eax
80109c92:	83 c0 28             	add    $0x28,%eax
80109c95:	0f b7 c0             	movzwl %ax,%eax
80109c98:	83 ec 0c             	sub    $0xc,%esp
80109c9b:	50                   	push   %eax
80109c9c:	e8 9b f8 ff ff       	call   8010953c <H2N_ushort>
80109ca1:	83 c4 10             	add    $0x10,%esp
80109ca4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109ca7:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109cab:	0f b7 15 60 6f 19 80 	movzwl 0x80196f60,%edx
80109cb2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cb5:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109cb9:	0f b7 05 60 6f 19 80 	movzwl 0x80196f60,%eax
80109cc0:	83 c0 01             	add    $0x1,%eax
80109cc3:	66 a3 60 6f 19 80    	mov    %ax,0x80196f60
  ipv4_send->fragment = H2N_ushort(0x0000);
80109cc9:	83 ec 0c             	sub    $0xc,%esp
80109ccc:	6a 00                	push   $0x0
80109cce:	e8 69 f8 ff ff       	call   8010953c <H2N_ushort>
80109cd3:	83 c4 10             	add    $0x10,%esp
80109cd6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109cd9:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109cdd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ce0:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
80109ce4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ce7:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109ceb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cee:	83 c0 0c             	add    $0xc,%eax
80109cf1:	83 ec 04             	sub    $0x4,%esp
80109cf4:	6a 04                	push   $0x4
80109cf6:	68 e4 f4 10 80       	push   $0x8010f4e4
80109cfb:	50                   	push   %eax
80109cfc:	e8 a0 ae ff ff       	call   80104ba1 <memmove>
80109d01:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109d04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d07:	8d 50 0c             	lea    0xc(%eax),%edx
80109d0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d0d:	83 c0 10             	add    $0x10,%eax
80109d10:	83 ec 04             	sub    $0x4,%esp
80109d13:	6a 04                	push   $0x4
80109d15:	52                   	push   %edx
80109d16:	50                   	push   %eax
80109d17:	e8 85 ae ff ff       	call   80104ba1 <memmove>
80109d1c:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109d1f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d22:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109d28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d2b:	83 ec 0c             	sub    $0xc,%esp
80109d2e:	50                   	push   %eax
80109d2f:	e8 08 f9 ff ff       	call   8010963c <ipv4_chksum>
80109d34:	83 c4 10             	add    $0x10,%esp
80109d37:	0f b7 c0             	movzwl %ax,%eax
80109d3a:	83 ec 0c             	sub    $0xc,%esp
80109d3d:	50                   	push   %eax
80109d3e:	e8 f9 f7 ff ff       	call   8010953c <H2N_ushort>
80109d43:	83 c4 10             	add    $0x10,%esp
80109d46:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109d49:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
80109d4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d50:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80109d54:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d57:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
80109d5a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d5d:	0f b7 10             	movzwl (%eax),%edx
80109d60:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d63:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
80109d67:	a1 64 6f 19 80       	mov    0x80196f64,%eax
80109d6c:	83 ec 0c             	sub    $0xc,%esp
80109d6f:	50                   	push   %eax
80109d70:	e8 e9 f7 ff ff       	call   8010955e <H2N_uint>
80109d75:	83 c4 10             	add    $0x10,%esp
80109d78:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109d7b:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
80109d7e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d81:	8b 40 04             	mov    0x4(%eax),%eax
80109d84:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
80109d8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d8d:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
80109d90:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d93:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
80109d97:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d9a:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
80109d9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109da1:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
80109da5:	8b 45 14             	mov    0x14(%ebp),%eax
80109da8:	89 c2                	mov    %eax,%edx
80109daa:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109dad:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
80109db0:	83 ec 0c             	sub    $0xc,%esp
80109db3:	68 90 38 00 00       	push   $0x3890
80109db8:	e8 7f f7 ff ff       	call   8010953c <H2N_ushort>
80109dbd:	83 c4 10             	add    $0x10,%esp
80109dc0:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109dc3:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
80109dc7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109dca:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
80109dd0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109dd3:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
80109dd9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ddc:	83 ec 0c             	sub    $0xc,%esp
80109ddf:	50                   	push   %eax
80109de0:	e8 1f 00 00 00       	call   80109e04 <tcp_chksum>
80109de5:	83 c4 10             	add    $0x10,%esp
80109de8:	83 c0 08             	add    $0x8,%eax
80109deb:	0f b7 c0             	movzwl %ax,%eax
80109dee:	83 ec 0c             	sub    $0xc,%esp
80109df1:	50                   	push   %eax
80109df2:	e8 45 f7 ff ff       	call   8010953c <H2N_ushort>
80109df7:	83 c4 10             	add    $0x10,%esp
80109dfa:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109dfd:	66 89 42 10          	mov    %ax,0x10(%edx)


}
80109e01:	90                   	nop
80109e02:	c9                   	leave  
80109e03:	c3                   	ret    

80109e04 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
80109e04:	55                   	push   %ebp
80109e05:	89 e5                	mov    %esp,%ebp
80109e07:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
80109e0a:	8b 45 08             	mov    0x8(%ebp),%eax
80109e0d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
80109e10:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e13:	83 c0 14             	add    $0x14,%eax
80109e16:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
80109e19:	83 ec 04             	sub    $0x4,%esp
80109e1c:	6a 04                	push   $0x4
80109e1e:	68 e4 f4 10 80       	push   $0x8010f4e4
80109e23:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109e26:	50                   	push   %eax
80109e27:	e8 75 ad ff ff       	call   80104ba1 <memmove>
80109e2c:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
80109e2f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e32:	83 c0 0c             	add    $0xc,%eax
80109e35:	83 ec 04             	sub    $0x4,%esp
80109e38:	6a 04                	push   $0x4
80109e3a:	50                   	push   %eax
80109e3b:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109e3e:	83 c0 04             	add    $0x4,%eax
80109e41:	50                   	push   %eax
80109e42:	e8 5a ad ff ff       	call   80104ba1 <memmove>
80109e47:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
80109e4a:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
80109e4e:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
80109e52:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e55:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80109e59:	0f b7 c0             	movzwl %ax,%eax
80109e5c:	83 ec 0c             	sub    $0xc,%esp
80109e5f:	50                   	push   %eax
80109e60:	e8 b5 f6 ff ff       	call   8010951a <N2H_ushort>
80109e65:	83 c4 10             	add    $0x10,%esp
80109e68:	83 e8 14             	sub    $0x14,%eax
80109e6b:	0f b7 c0             	movzwl %ax,%eax
80109e6e:	83 ec 0c             	sub    $0xc,%esp
80109e71:	50                   	push   %eax
80109e72:	e8 c5 f6 ff ff       	call   8010953c <H2N_ushort>
80109e77:	83 c4 10             	add    $0x10,%esp
80109e7a:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
80109e7e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
80109e85:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109e88:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
80109e8b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109e92:	eb 33                	jmp    80109ec7 <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109e94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e97:	01 c0                	add    %eax,%eax
80109e99:	89 c2                	mov    %eax,%edx
80109e9b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e9e:	01 d0                	add    %edx,%eax
80109ea0:	0f b6 00             	movzbl (%eax),%eax
80109ea3:	0f b6 c0             	movzbl %al,%eax
80109ea6:	c1 e0 08             	shl    $0x8,%eax
80109ea9:	89 c2                	mov    %eax,%edx
80109eab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109eae:	01 c0                	add    %eax,%eax
80109eb0:	8d 48 01             	lea    0x1(%eax),%ecx
80109eb3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109eb6:	01 c8                	add    %ecx,%eax
80109eb8:	0f b6 00             	movzbl (%eax),%eax
80109ebb:	0f b6 c0             	movzbl %al,%eax
80109ebe:	01 d0                	add    %edx,%eax
80109ec0:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
80109ec3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109ec7:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
80109ecb:	7e c7                	jle    80109e94 <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
80109ecd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ed0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
80109ed3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80109eda:	eb 33                	jmp    80109f0f <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109edc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109edf:	01 c0                	add    %eax,%eax
80109ee1:	89 c2                	mov    %eax,%edx
80109ee3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ee6:	01 d0                	add    %edx,%eax
80109ee8:	0f b6 00             	movzbl (%eax),%eax
80109eeb:	0f b6 c0             	movzbl %al,%eax
80109eee:	c1 e0 08             	shl    $0x8,%eax
80109ef1:	89 c2                	mov    %eax,%edx
80109ef3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ef6:	01 c0                	add    %eax,%eax
80109ef8:	8d 48 01             	lea    0x1(%eax),%ecx
80109efb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109efe:	01 c8                	add    %ecx,%eax
80109f00:	0f b6 00             	movzbl (%eax),%eax
80109f03:	0f b6 c0             	movzbl %al,%eax
80109f06:	01 d0                	add    %edx,%eax
80109f08:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
80109f0b:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80109f0f:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
80109f13:	0f b7 c0             	movzwl %ax,%eax
80109f16:	83 ec 0c             	sub    $0xc,%esp
80109f19:	50                   	push   %eax
80109f1a:	e8 fb f5 ff ff       	call   8010951a <N2H_ushort>
80109f1f:	83 c4 10             	add    $0x10,%esp
80109f22:	66 d1 e8             	shr    %ax
80109f25:	0f b7 c0             	movzwl %ax,%eax
80109f28:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80109f2b:	7c af                	jl     80109edc <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
80109f2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f30:	c1 e8 10             	shr    $0x10,%eax
80109f33:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
80109f36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f39:	f7 d0                	not    %eax
}
80109f3b:	c9                   	leave  
80109f3c:	c3                   	ret    

80109f3d <tcp_fin>:

void tcp_fin(){
80109f3d:	55                   	push   %ebp
80109f3e:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
80109f40:	c7 05 68 6f 19 80 01 	movl   $0x1,0x80196f68
80109f47:	00 00 00 
}
80109f4a:	90                   	nop
80109f4b:	5d                   	pop    %ebp
80109f4c:	c3                   	ret    

80109f4d <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
80109f4d:	55                   	push   %ebp
80109f4e:	89 e5                	mov    %esp,%ebp
80109f50:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
80109f53:	8b 45 10             	mov    0x10(%ebp),%eax
80109f56:	83 ec 04             	sub    $0x4,%esp
80109f59:	6a 00                	push   $0x0
80109f5b:	68 eb c0 10 80       	push   $0x8010c0eb
80109f60:	50                   	push   %eax
80109f61:	e8 65 00 00 00       	call   80109fcb <http_strcpy>
80109f66:	83 c4 10             	add    $0x10,%esp
80109f69:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
80109f6c:	8b 45 10             	mov    0x10(%ebp),%eax
80109f6f:	83 ec 04             	sub    $0x4,%esp
80109f72:	ff 75 f4             	push   -0xc(%ebp)
80109f75:	68 fe c0 10 80       	push   $0x8010c0fe
80109f7a:	50                   	push   %eax
80109f7b:	e8 4b 00 00 00       	call   80109fcb <http_strcpy>
80109f80:	83 c4 10             	add    $0x10,%esp
80109f83:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
80109f86:	8b 45 10             	mov    0x10(%ebp),%eax
80109f89:	83 ec 04             	sub    $0x4,%esp
80109f8c:	ff 75 f4             	push   -0xc(%ebp)
80109f8f:	68 19 c1 10 80       	push   $0x8010c119
80109f94:	50                   	push   %eax
80109f95:	e8 31 00 00 00       	call   80109fcb <http_strcpy>
80109f9a:	83 c4 10             	add    $0x10,%esp
80109f9d:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
80109fa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fa3:	83 e0 01             	and    $0x1,%eax
80109fa6:	85 c0                	test   %eax,%eax
80109fa8:	74 11                	je     80109fbb <http_proc+0x6e>
    char *payload = (char *)send;
80109faa:	8b 45 10             	mov    0x10(%ebp),%eax
80109fad:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
80109fb0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109fb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fb6:	01 d0                	add    %edx,%eax
80109fb8:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
80109fbb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109fbe:	8b 45 14             	mov    0x14(%ebp),%eax
80109fc1:	89 10                	mov    %edx,(%eax)
  tcp_fin();
80109fc3:	e8 75 ff ff ff       	call   80109f3d <tcp_fin>
}
80109fc8:	90                   	nop
80109fc9:	c9                   	leave  
80109fca:	c3                   	ret    

80109fcb <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
80109fcb:	55                   	push   %ebp
80109fcc:	89 e5                	mov    %esp,%ebp
80109fce:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
80109fd1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
80109fd8:	eb 20                	jmp    80109ffa <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
80109fda:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109fdd:	8b 45 0c             	mov    0xc(%ebp),%eax
80109fe0:	01 d0                	add    %edx,%eax
80109fe2:	8b 4d 10             	mov    0x10(%ebp),%ecx
80109fe5:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109fe8:	01 ca                	add    %ecx,%edx
80109fea:	89 d1                	mov    %edx,%ecx
80109fec:	8b 55 08             	mov    0x8(%ebp),%edx
80109fef:	01 ca                	add    %ecx,%edx
80109ff1:	0f b6 00             	movzbl (%eax),%eax
80109ff4:	88 02                	mov    %al,(%edx)
    i++;
80109ff6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
80109ffa:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109ffd:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a000:	01 d0                	add    %edx,%eax
8010a002:	0f b6 00             	movzbl (%eax),%eax
8010a005:	84 c0                	test   %al,%al
8010a007:	75 d1                	jne    80109fda <http_strcpy+0xf>
  }
  return i;
8010a009:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a00c:	c9                   	leave  
8010a00d:	c3                   	ret    

8010a00e <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a00e:	55                   	push   %ebp
8010a00f:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a011:	c7 05 70 6f 19 80 a2 	movl   $0x8010f5a2,0x80196f70
8010a018:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a01b:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a020:	c1 e8 09             	shr    $0x9,%eax
8010a023:	a3 6c 6f 19 80       	mov    %eax,0x80196f6c
}
8010a028:	90                   	nop
8010a029:	5d                   	pop    %ebp
8010a02a:	c3                   	ret    

8010a02b <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a02b:	55                   	push   %ebp
8010a02c:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a02e:	90                   	nop
8010a02f:	5d                   	pop    %ebp
8010a030:	c3                   	ret    

8010a031 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a031:	55                   	push   %ebp
8010a032:	89 e5                	mov    %esp,%ebp
8010a034:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a037:	8b 45 08             	mov    0x8(%ebp),%eax
8010a03a:	83 c0 0c             	add    $0xc,%eax
8010a03d:	83 ec 0c             	sub    $0xc,%esp
8010a040:	50                   	push   %eax
8010a041:	e8 95 a7 ff ff       	call   801047db <holdingsleep>
8010a046:	83 c4 10             	add    $0x10,%esp
8010a049:	85 c0                	test   %eax,%eax
8010a04b:	75 0d                	jne    8010a05a <iderw+0x29>
    panic("iderw: buf not locked");
8010a04d:	83 ec 0c             	sub    $0xc,%esp
8010a050:	68 2a c1 10 80       	push   $0x8010c12a
8010a055:	e8 4f 65 ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a05a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a05d:	8b 00                	mov    (%eax),%eax
8010a05f:	83 e0 06             	and    $0x6,%eax
8010a062:	83 f8 02             	cmp    $0x2,%eax
8010a065:	75 0d                	jne    8010a074 <iderw+0x43>
    panic("iderw: nothing to do");
8010a067:	83 ec 0c             	sub    $0xc,%esp
8010a06a:	68 40 c1 10 80       	push   $0x8010c140
8010a06f:	e8 35 65 ff ff       	call   801005a9 <panic>
  if(b->dev != 1)
8010a074:	8b 45 08             	mov    0x8(%ebp),%eax
8010a077:	8b 40 04             	mov    0x4(%eax),%eax
8010a07a:	83 f8 01             	cmp    $0x1,%eax
8010a07d:	74 0d                	je     8010a08c <iderw+0x5b>
    panic("iderw: request not for disk 1");
8010a07f:	83 ec 0c             	sub    $0xc,%esp
8010a082:	68 55 c1 10 80       	push   $0x8010c155
8010a087:	e8 1d 65 ff ff       	call   801005a9 <panic>
  if(b->blockno >= disksize)
8010a08c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a08f:	8b 40 08             	mov    0x8(%eax),%eax
8010a092:	8b 15 6c 6f 19 80    	mov    0x80196f6c,%edx
8010a098:	39 d0                	cmp    %edx,%eax
8010a09a:	72 0d                	jb     8010a0a9 <iderw+0x78>
    panic("iderw: block out of range");
8010a09c:	83 ec 0c             	sub    $0xc,%esp
8010a09f:	68 73 c1 10 80       	push   $0x8010c173
8010a0a4:	e8 00 65 ff ff       	call   801005a9 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a0a9:	8b 15 70 6f 19 80    	mov    0x80196f70,%edx
8010a0af:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0b2:	8b 40 08             	mov    0x8(%eax),%eax
8010a0b5:	c1 e0 09             	shl    $0x9,%eax
8010a0b8:	01 d0                	add    %edx,%eax
8010a0ba:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a0bd:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0c0:	8b 00                	mov    (%eax),%eax
8010a0c2:	83 e0 04             	and    $0x4,%eax
8010a0c5:	85 c0                	test   %eax,%eax
8010a0c7:	74 2b                	je     8010a0f4 <iderw+0xc3>
    b->flags &= ~B_DIRTY;
8010a0c9:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0cc:	8b 00                	mov    (%eax),%eax
8010a0ce:	83 e0 fb             	and    $0xfffffffb,%eax
8010a0d1:	89 c2                	mov    %eax,%edx
8010a0d3:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0d6:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a0d8:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0db:	83 c0 5c             	add    $0x5c,%eax
8010a0de:	83 ec 04             	sub    $0x4,%esp
8010a0e1:	68 00 02 00 00       	push   $0x200
8010a0e6:	50                   	push   %eax
8010a0e7:	ff 75 f4             	push   -0xc(%ebp)
8010a0ea:	e8 b2 aa ff ff       	call   80104ba1 <memmove>
8010a0ef:	83 c4 10             	add    $0x10,%esp
8010a0f2:	eb 1a                	jmp    8010a10e <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
8010a0f4:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0f7:	83 c0 5c             	add    $0x5c,%eax
8010a0fa:	83 ec 04             	sub    $0x4,%esp
8010a0fd:	68 00 02 00 00       	push   $0x200
8010a102:	ff 75 f4             	push   -0xc(%ebp)
8010a105:	50                   	push   %eax
8010a106:	e8 96 aa ff ff       	call   80104ba1 <memmove>
8010a10b:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a10e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a111:	8b 00                	mov    (%eax),%eax
8010a113:	83 c8 02             	or     $0x2,%eax
8010a116:	89 c2                	mov    %eax,%edx
8010a118:	8b 45 08             	mov    0x8(%ebp),%eax
8010a11b:	89 10                	mov    %edx,(%eax)
}
8010a11d:	90                   	nop
8010a11e:	c9                   	leave  
8010a11f:	c3                   	ret    
