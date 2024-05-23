
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
8010005f:	ba 58 33 10 80       	mov    $0x80103358,%edx
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
80100079:	e8 bf 47 00 00       	call   8010483d <initlock>
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
801000c3:	e8 18 46 00 00       	call   801046e0 <initsleeplock>
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
80100101:	e8 59 47 00 00       	call   8010485f <acquire>
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
80100140:	e8 88 47 00 00       	call   801048cd <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 c5 45 00 00       	call   8010471c <acquiresleep>
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
801001c1:	e8 07 47 00 00       	call   801048cd <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 44 45 00 00       	call   8010471c <acquiresleep>
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
8010022d:	e8 e0 9d 00 00       	call   8010a012 <iderw>
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
8010024a:	e8 7f 45 00 00       	call   801047ce <holdingsleep>
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
80100278:	e8 95 9d 00 00       	call   8010a012 <iderw>
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
80100293:	e8 36 45 00 00       	call   801047ce <holdingsleep>
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
801002b6:	e8 c5 44 00 00       	call   80104780 <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 d0 18 80       	push   $0x8018d000
801002c6:	e8 94 45 00 00       	call   8010485f <acquire>
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
80100336:	e8 92 45 00 00       	call   801048cd <release>
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
80100410:	e8 4a 44 00 00       	call   8010485f <acquire>
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
8010059e:	e8 2a 43 00 00       	call   801048cd <release>
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
801005be:	e8 2a 25 00 00       	call   80102aed <lapicid>
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
801005fe:	e8 1c 43 00 00       	call   8010491f <getcallerpcs>
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
801006a0:	e8 c4 78 00 00       	call   80107f69 <graphic_scroll_up>
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
801006f3:	e8 71 78 00 00       	call   80107f69 <graphic_scroll_up>
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
80100757:	e8 78 78 00 00       	call   80107fd4 <font_render>
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
80100793:	e8 5a 5c 00 00       	call   801063f2 <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 4d 5c 00 00       	call   801063f2 <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 40 5c 00 00       	call   801063f2 <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x56>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 30 5c 00 00       	call   801063f2 <uartputc>
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
801007eb:	e8 6f 40 00 00       	call   8010485f <acquire>
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
8010093f:	e8 6f 3a 00 00       	call   801043b3 <wakeup>
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
80100962:	e8 66 3f 00 00       	call   801048cd <release>
80100967:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010096a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010096e:	74 05                	je     80100975 <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
80100970:	e8 f9 3a 00 00       	call   8010446e <procdump>
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
80100984:	e8 67 11 00 00       	call   80101af0 <iunlock>
80100989:	83 c4 10             	add    $0x10,%esp
  target = n;
8010098c:	8b 45 10             	mov    0x10(%ebp),%eax
8010098f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100992:	83 ec 0c             	sub    $0xc,%esp
80100995:	68 00 1a 19 80       	push   $0x80191a00
8010099a:	e8 c0 3e 00 00       	call   8010485f <acquire>
8010099f:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009a2:	e9 ab 00 00 00       	jmp    80100a52 <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009a7:	e8 77 30 00 00       	call   80103a23 <myproc>
801009ac:	8b 40 24             	mov    0x24(%eax),%eax
801009af:	85 c0                	test   %eax,%eax
801009b1:	74 28                	je     801009db <consoleread+0x63>
        release(&cons.lock);
801009b3:	83 ec 0c             	sub    $0xc,%esp
801009b6:	68 00 1a 19 80       	push   $0x80191a00
801009bb:	e8 0d 3f 00 00       	call   801048cd <release>
801009c0:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009c3:	83 ec 0c             	sub    $0xc,%esp
801009c6:	ff 75 08             	push   0x8(%ebp)
801009c9:	e8 0f 10 00 00       	call   801019dd <ilock>
801009ce:	83 c4 10             	add    $0x10,%esp
        return -1;
801009d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009d6:	e9 a9 00 00 00       	jmp    80100a84 <consoleread+0x10c>
      }
      sleep(&input.r, &cons.lock);
801009db:	83 ec 08             	sub    $0x8,%esp
801009de:	68 00 1a 19 80       	push   $0x80191a00
801009e3:	68 e0 19 19 80       	push   $0x801919e0
801009e8:	e8 df 38 00 00       	call   801042cc <sleep>
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
80100a66:	e8 62 3e 00 00       	call   801048cd <release>
80100a6b:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a6e:	83 ec 0c             	sub    $0xc,%esp
80100a71:	ff 75 08             	push   0x8(%ebp)
80100a74:	e8 64 0f 00 00       	call   801019dd <ilock>
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
80100a92:	e8 59 10 00 00       	call   80101af0 <iunlock>
80100a97:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100a9a:	83 ec 0c             	sub    $0xc,%esp
80100a9d:	68 00 1a 19 80       	push   $0x80191a00
80100aa2:	e8 b8 3d 00 00       	call   8010485f <acquire>
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
80100ae4:	e8 e4 3d 00 00       	call   801048cd <release>
80100ae9:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100aec:	83 ec 0c             	sub    $0xc,%esp
80100aef:	ff 75 08             	push   0x8(%ebp)
80100af2:	e8 e6 0e 00 00       	call   801019dd <ilock>
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
80100b1c:	e8 1c 3d 00 00       	call   8010483d <initlock>
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
80100b75:	e8 a7 1a 00 00       	call   80102621 <ioapicenable>
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
80100b89:	e8 95 2e 00 00       	call   80103a23 <myproc>
80100b8e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100b91:	e8 99 24 00 00       	call   8010302f <begin_op>

  if((ip = namei(path)) == 0){
80100b96:	83 ec 0c             	sub    $0xc,%esp
80100b99:	ff 75 08             	push   0x8(%ebp)
80100b9c:	e8 6f 19 00 00       	call   80102510 <namei>
80100ba1:	83 c4 10             	add    $0x10,%esp
80100ba4:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100ba7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bab:	75 1f                	jne    80100bcc <exec+0x4c>
    end_op();
80100bad:	e8 09 25 00 00       	call   801030bb <end_op>
    cprintf("exec: fail\n");
80100bb2:	83 ec 0c             	sub    $0xc,%esp
80100bb5:	68 95 a1 10 80       	push   $0x8010a195
80100bba:	e8 35 f8 ff ff       	call   801003f4 <cprintf>
80100bbf:	83 c4 10             	add    $0x10,%esp
    return -1;
80100bc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bc7:	e9 e4 03 00 00       	jmp    80100fb0 <exec+0x430>
  }
  ilock(ip);
80100bcc:	83 ec 0c             	sub    $0xc,%esp
80100bcf:	ff 75 d8             	push   -0x28(%ebp)
80100bd2:	e8 06 0e 00 00       	call   801019dd <ilock>
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
80100bef:	e8 d5 12 00 00       	call   80101ec9 <readi>
80100bf4:	83 c4 10             	add    $0x10,%esp
80100bf7:	83 f8 34             	cmp    $0x34,%eax
80100bfa:	0f 85 59 03 00 00    	jne    80100f59 <exec+0x3d9>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c00:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c06:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c0b:	0f 85 4b 03 00 00    	jne    80100f5c <exec+0x3dc>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c11:	e8 d8 67 00 00       	call   801073ee <setupkvm>
80100c16:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c19:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c1d:	0f 84 3c 03 00 00    	je     80100f5f <exec+0x3df>
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
80100c4f:	e8 75 12 00 00       	call   80101ec9 <readi>
80100c54:	83 c4 10             	add    $0x10,%esp
80100c57:	83 f8 20             	cmp    $0x20,%eax
80100c5a:	0f 85 02 03 00 00    	jne    80100f62 <exec+0x3e2>
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
80100c7d:	0f 82 e2 02 00 00    	jb     80100f65 <exec+0x3e5>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c83:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c89:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c8f:	01 c2                	add    %eax,%edx
80100c91:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c97:	39 c2                	cmp    %eax,%edx
80100c99:	0f 82 c9 02 00 00    	jb     80100f68 <exec+0x3e8>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c9f:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ca5:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cab:	01 d0                	add    %edx,%eax
80100cad:	83 ec 04             	sub    $0x4,%esp
80100cb0:	50                   	push   %eax
80100cb1:	ff 75 e0             	push   -0x20(%ebp)
80100cb4:	ff 75 d4             	push   -0x2c(%ebp)
80100cb7:	e8 2b 6b 00 00       	call   801077e7 <allocuvm>
80100cbc:	83 c4 10             	add    $0x10,%esp
80100cbf:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cc2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cc6:	0f 84 9f 02 00 00    	je     80100f6b <exec+0x3eb>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100ccc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cd2:	25 ff 0f 00 00       	and    $0xfff,%eax
80100cd7:	85 c0                	test   %eax,%eax
80100cd9:	0f 85 8f 02 00 00    	jne    80100f6e <exec+0x3ee>
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
80100cfd:	e8 18 6a 00 00       	call   8010771a <loaduvm>
80100d02:	83 c4 20             	add    $0x20,%esp
80100d05:	85 c0                	test   %eax,%eax
80100d07:	0f 88 64 02 00 00    	js     80100f71 <exec+0x3f1>
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
80100d36:	e8 d3 0e 00 00       	call   80101c0e <iunlockput>
80100d3b:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d3e:	e8 78 23 00 00       	call   801030bb <end_op>
  ip = 0;
80100d43:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;
  */

  // Allocate Stack at the top address
  sz = PGROUNDDOWN(KERNBASE - 1);
80100d4a:	c7 45 e0 00 f0 ff 7f 	movl   $0x7ffff000,-0x20(%ebp)
  cprintf("now sz : %p\n", sz);
80100d51:	83 ec 08             	sub    $0x8,%esp
80100d54:	ff 75 e0             	push   -0x20(%ebp)
80100d57:	68 a1 a1 10 80       	push   $0x8010a1a1
80100d5c:	e8 93 f6 ff ff       	call   801003f4 <cprintf>
80100d61:	83 c4 10             	add    $0x10,%esp
  if ((sz = allocuvm(pgdir, sz, sz + PGSIZE)) == 0)
80100d64:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d67:	05 00 10 00 00       	add    $0x1000,%eax
80100d6c:	83 ec 04             	sub    $0x4,%esp
80100d6f:	50                   	push   %eax
80100d70:	ff 75 e0             	push   -0x20(%ebp)
80100d73:	ff 75 d4             	push   -0x2c(%ebp)
80100d76:	e8 6c 6a 00 00       	call   801077e7 <allocuvm>
80100d7b:	83 c4 10             	add    $0x10,%esp
80100d7e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d81:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d85:	0f 84 e9 01 00 00    	je     80100f74 <exec+0x3f4>
    goto bad;
  sp = sz;
80100d8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d8e:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d91:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d98:	e9 96 00 00 00       	jmp    80100e33 <exec+0x2b3>
    if(argc >= MAXARG)
80100d9d:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100da1:	0f 87 d0 01 00 00    	ja     80100f77 <exec+0x3f7>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100da7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100daa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100db1:	8b 45 0c             	mov    0xc(%ebp),%eax
80100db4:	01 d0                	add    %edx,%eax
80100db6:	8b 00                	mov    (%eax),%eax
80100db8:	83 ec 0c             	sub    $0xc,%esp
80100dbb:	50                   	push   %eax
80100dbc:	e8 62 3f 00 00       	call   80104d23 <strlen>
80100dc1:	83 c4 10             	add    $0x10,%esp
80100dc4:	89 c2                	mov    %eax,%edx
80100dc6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dc9:	29 d0                	sub    %edx,%eax
80100dcb:	83 e8 01             	sub    $0x1,%eax
80100dce:	83 e0 fc             	and    $0xfffffffc,%eax
80100dd1:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100dd4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dd7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dde:	8b 45 0c             	mov    0xc(%ebp),%eax
80100de1:	01 d0                	add    %edx,%eax
80100de3:	8b 00                	mov    (%eax),%eax
80100de5:	83 ec 0c             	sub    $0xc,%esp
80100de8:	50                   	push   %eax
80100de9:	e8 35 3f 00 00       	call   80104d23 <strlen>
80100dee:	83 c4 10             	add    $0x10,%esp
80100df1:	83 c0 01             	add    $0x1,%eax
80100df4:	89 c2                	mov    %eax,%edx
80100df6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100df9:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100e00:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e03:	01 c8                	add    %ecx,%eax
80100e05:	8b 00                	mov    (%eax),%eax
80100e07:	52                   	push   %edx
80100e08:	50                   	push   %eax
80100e09:	ff 75 dc             	push   -0x24(%ebp)
80100e0c:	ff 75 d4             	push   -0x2c(%ebp)
80100e0f:	e8 c2 6d 00 00       	call   80107bd6 <copyout>
80100e14:	83 c4 10             	add    $0x10,%esp
80100e17:	85 c0                	test   %eax,%eax
80100e19:	0f 88 5b 01 00 00    	js     80100f7a <exec+0x3fa>
      goto bad;
    ustack[3+argc] = sp;
80100e1f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e22:	8d 50 03             	lea    0x3(%eax),%edx
80100e25:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e28:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e2f:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e36:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e3d:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e40:	01 d0                	add    %edx,%eax
80100e42:	8b 00                	mov    (%eax),%eax
80100e44:	85 c0                	test   %eax,%eax
80100e46:	0f 85 51 ff ff ff    	jne    80100d9d <exec+0x21d>
  }
  ustack[3+argc] = 0;
80100e4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e4f:	83 c0 03             	add    $0x3,%eax
80100e52:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100e59:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e5d:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100e64:	ff ff ff 
  ustack[1] = argc;
80100e67:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e6a:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e73:	83 c0 01             	add    $0x1,%eax
80100e76:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e7d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e80:	29 d0                	sub    %edx,%eax
80100e82:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100e88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e8b:	83 c0 04             	add    $0x4,%eax
80100e8e:	c1 e0 02             	shl    $0x2,%eax
80100e91:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e94:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e97:	83 c0 04             	add    $0x4,%eax
80100e9a:	c1 e0 02             	shl    $0x2,%eax
80100e9d:	50                   	push   %eax
80100e9e:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100ea4:	50                   	push   %eax
80100ea5:	ff 75 dc             	push   -0x24(%ebp)
80100ea8:	ff 75 d4             	push   -0x2c(%ebp)
80100eab:	e8 26 6d 00 00       	call   80107bd6 <copyout>
80100eb0:	83 c4 10             	add    $0x10,%esp
80100eb3:	85 c0                	test   %eax,%eax
80100eb5:	0f 88 c2 00 00 00    	js     80100f7d <exec+0x3fd>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100ebb:	8b 45 08             	mov    0x8(%ebp),%eax
80100ebe:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100ec1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ec4:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100ec7:	eb 17                	jmp    80100ee0 <exec+0x360>
    if(*s == '/')
80100ec9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ecc:	0f b6 00             	movzbl (%eax),%eax
80100ecf:	3c 2f                	cmp    $0x2f,%al
80100ed1:	75 09                	jne    80100edc <exec+0x35c>
      last = s+1;
80100ed3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ed6:	83 c0 01             	add    $0x1,%eax
80100ed9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100edc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ee3:	0f b6 00             	movzbl (%eax),%eax
80100ee6:	84 c0                	test   %al,%al
80100ee8:	75 df                	jne    80100ec9 <exec+0x349>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100eea:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100eed:	83 c0 6c             	add    $0x6c,%eax
80100ef0:	83 ec 04             	sub    $0x4,%esp
80100ef3:	6a 10                	push   $0x10
80100ef5:	ff 75 f0             	push   -0x10(%ebp)
80100ef8:	50                   	push   %eax
80100ef9:	e8 da 3d 00 00       	call   80104cd8 <safestrcpy>
80100efe:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f01:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f04:	8b 40 04             	mov    0x4(%eax),%eax
80100f07:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f0a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f0d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f10:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f13:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f16:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f19:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f1b:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f1e:	8b 40 18             	mov    0x18(%eax),%eax
80100f21:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f27:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f2a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f2d:	8b 40 18             	mov    0x18(%eax),%eax
80100f30:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f33:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f36:	83 ec 0c             	sub    $0xc,%esp
80100f39:	ff 75 d0             	push   -0x30(%ebp)
80100f3c:	e8 ca 65 00 00       	call   8010750b <switchuvm>
80100f41:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f44:	83 ec 0c             	sub    $0xc,%esp
80100f47:	ff 75 cc             	push   -0x34(%ebp)
80100f4a:	e8 63 6a 00 00       	call   801079b2 <freevm>
80100f4f:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f52:	b8 00 00 00 00       	mov    $0x0,%eax
80100f57:	eb 57                	jmp    80100fb0 <exec+0x430>
    goto bad;
80100f59:	90                   	nop
80100f5a:	eb 22                	jmp    80100f7e <exec+0x3fe>
    goto bad;
80100f5c:	90                   	nop
80100f5d:	eb 1f                	jmp    80100f7e <exec+0x3fe>
    goto bad;
80100f5f:	90                   	nop
80100f60:	eb 1c                	jmp    80100f7e <exec+0x3fe>
      goto bad;
80100f62:	90                   	nop
80100f63:	eb 19                	jmp    80100f7e <exec+0x3fe>
      goto bad;
80100f65:	90                   	nop
80100f66:	eb 16                	jmp    80100f7e <exec+0x3fe>
      goto bad;
80100f68:	90                   	nop
80100f69:	eb 13                	jmp    80100f7e <exec+0x3fe>
      goto bad;
80100f6b:	90                   	nop
80100f6c:	eb 10                	jmp    80100f7e <exec+0x3fe>
      goto bad;
80100f6e:	90                   	nop
80100f6f:	eb 0d                	jmp    80100f7e <exec+0x3fe>
      goto bad;
80100f71:	90                   	nop
80100f72:	eb 0a                	jmp    80100f7e <exec+0x3fe>
    goto bad;
80100f74:	90                   	nop
80100f75:	eb 07                	jmp    80100f7e <exec+0x3fe>
      goto bad;
80100f77:	90                   	nop
80100f78:	eb 04                	jmp    80100f7e <exec+0x3fe>
      goto bad;
80100f7a:	90                   	nop
80100f7b:	eb 01                	jmp    80100f7e <exec+0x3fe>
    goto bad;
80100f7d:	90                   	nop

 bad:
  if(pgdir)
80100f7e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f82:	74 0e                	je     80100f92 <exec+0x412>
    freevm(pgdir);
80100f84:	83 ec 0c             	sub    $0xc,%esp
80100f87:	ff 75 d4             	push   -0x2c(%ebp)
80100f8a:	e8 23 6a 00 00       	call   801079b2 <freevm>
80100f8f:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f92:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f96:	74 13                	je     80100fab <exec+0x42b>
    iunlockput(ip);
80100f98:	83 ec 0c             	sub    $0xc,%esp
80100f9b:	ff 75 d8             	push   -0x28(%ebp)
80100f9e:	e8 6b 0c 00 00       	call   80101c0e <iunlockput>
80100fa3:	83 c4 10             	add    $0x10,%esp
    end_op();
80100fa6:	e8 10 21 00 00       	call   801030bb <end_op>
  }
  return -1;
80100fab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fb0:	c9                   	leave  
80100fb1:	c3                   	ret    

80100fb2 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fb2:	55                   	push   %ebp
80100fb3:	89 e5                	mov    %esp,%ebp
80100fb5:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100fb8:	83 ec 08             	sub    $0x8,%esp
80100fbb:	68 ae a1 10 80       	push   $0x8010a1ae
80100fc0:	68 a0 1a 19 80       	push   $0x80191aa0
80100fc5:	e8 73 38 00 00       	call   8010483d <initlock>
80100fca:	83 c4 10             	add    $0x10,%esp
}
80100fcd:	90                   	nop
80100fce:	c9                   	leave  
80100fcf:	c3                   	ret    

80100fd0 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fd0:	55                   	push   %ebp
80100fd1:	89 e5                	mov    %esp,%ebp
80100fd3:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fd6:	83 ec 0c             	sub    $0xc,%esp
80100fd9:	68 a0 1a 19 80       	push   $0x80191aa0
80100fde:	e8 7c 38 00 00       	call   8010485f <acquire>
80100fe3:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fe6:	c7 45 f4 d4 1a 19 80 	movl   $0x80191ad4,-0xc(%ebp)
80100fed:	eb 2d                	jmp    8010101c <filealloc+0x4c>
    if(f->ref == 0){
80100fef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ff2:	8b 40 04             	mov    0x4(%eax),%eax
80100ff5:	85 c0                	test   %eax,%eax
80100ff7:	75 1f                	jne    80101018 <filealloc+0x48>
      f->ref = 1;
80100ff9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ffc:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101003:	83 ec 0c             	sub    $0xc,%esp
80101006:	68 a0 1a 19 80       	push   $0x80191aa0
8010100b:	e8 bd 38 00 00       	call   801048cd <release>
80101010:	83 c4 10             	add    $0x10,%esp
      return f;
80101013:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101016:	eb 23                	jmp    8010103b <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101018:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
8010101c:	b8 34 24 19 80       	mov    $0x80192434,%eax
80101021:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101024:	72 c9                	jb     80100fef <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
80101026:	83 ec 0c             	sub    $0xc,%esp
80101029:	68 a0 1a 19 80       	push   $0x80191aa0
8010102e:	e8 9a 38 00 00       	call   801048cd <release>
80101033:	83 c4 10             	add    $0x10,%esp
  return 0;
80101036:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010103b:	c9                   	leave  
8010103c:	c3                   	ret    

8010103d <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010103d:	55                   	push   %ebp
8010103e:	89 e5                	mov    %esp,%ebp
80101040:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101043:	83 ec 0c             	sub    $0xc,%esp
80101046:	68 a0 1a 19 80       	push   $0x80191aa0
8010104b:	e8 0f 38 00 00       	call   8010485f <acquire>
80101050:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101053:	8b 45 08             	mov    0x8(%ebp),%eax
80101056:	8b 40 04             	mov    0x4(%eax),%eax
80101059:	85 c0                	test   %eax,%eax
8010105b:	7f 0d                	jg     8010106a <filedup+0x2d>
    panic("filedup");
8010105d:	83 ec 0c             	sub    $0xc,%esp
80101060:	68 b5 a1 10 80       	push   $0x8010a1b5
80101065:	e8 3f f5 ff ff       	call   801005a9 <panic>
  f->ref++;
8010106a:	8b 45 08             	mov    0x8(%ebp),%eax
8010106d:	8b 40 04             	mov    0x4(%eax),%eax
80101070:	8d 50 01             	lea    0x1(%eax),%edx
80101073:	8b 45 08             	mov    0x8(%ebp),%eax
80101076:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101079:	83 ec 0c             	sub    $0xc,%esp
8010107c:	68 a0 1a 19 80       	push   $0x80191aa0
80101081:	e8 47 38 00 00       	call   801048cd <release>
80101086:	83 c4 10             	add    $0x10,%esp
  return f;
80101089:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010108c:	c9                   	leave  
8010108d:	c3                   	ret    

8010108e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010108e:	55                   	push   %ebp
8010108f:	89 e5                	mov    %esp,%ebp
80101091:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101094:	83 ec 0c             	sub    $0xc,%esp
80101097:	68 a0 1a 19 80       	push   $0x80191aa0
8010109c:	e8 be 37 00 00       	call   8010485f <acquire>
801010a1:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010a4:	8b 45 08             	mov    0x8(%ebp),%eax
801010a7:	8b 40 04             	mov    0x4(%eax),%eax
801010aa:	85 c0                	test   %eax,%eax
801010ac:	7f 0d                	jg     801010bb <fileclose+0x2d>
    panic("fileclose");
801010ae:	83 ec 0c             	sub    $0xc,%esp
801010b1:	68 bd a1 10 80       	push   $0x8010a1bd
801010b6:	e8 ee f4 ff ff       	call   801005a9 <panic>
  if(--f->ref > 0){
801010bb:	8b 45 08             	mov    0x8(%ebp),%eax
801010be:	8b 40 04             	mov    0x4(%eax),%eax
801010c1:	8d 50 ff             	lea    -0x1(%eax),%edx
801010c4:	8b 45 08             	mov    0x8(%ebp),%eax
801010c7:	89 50 04             	mov    %edx,0x4(%eax)
801010ca:	8b 45 08             	mov    0x8(%ebp),%eax
801010cd:	8b 40 04             	mov    0x4(%eax),%eax
801010d0:	85 c0                	test   %eax,%eax
801010d2:	7e 15                	jle    801010e9 <fileclose+0x5b>
    release(&ftable.lock);
801010d4:	83 ec 0c             	sub    $0xc,%esp
801010d7:	68 a0 1a 19 80       	push   $0x80191aa0
801010dc:	e8 ec 37 00 00       	call   801048cd <release>
801010e1:	83 c4 10             	add    $0x10,%esp
801010e4:	e9 8b 00 00 00       	jmp    80101174 <fileclose+0xe6>
    return;
  }
  ff = *f;
801010e9:	8b 45 08             	mov    0x8(%ebp),%eax
801010ec:	8b 10                	mov    (%eax),%edx
801010ee:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010f1:	8b 50 04             	mov    0x4(%eax),%edx
801010f4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801010f7:	8b 50 08             	mov    0x8(%eax),%edx
801010fa:	89 55 e8             	mov    %edx,-0x18(%ebp)
801010fd:	8b 50 0c             	mov    0xc(%eax),%edx
80101100:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101103:	8b 50 10             	mov    0x10(%eax),%edx
80101106:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101109:	8b 40 14             	mov    0x14(%eax),%eax
8010110c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010110f:	8b 45 08             	mov    0x8(%ebp),%eax
80101112:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101119:	8b 45 08             	mov    0x8(%ebp),%eax
8010111c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101122:	83 ec 0c             	sub    $0xc,%esp
80101125:	68 a0 1a 19 80       	push   $0x80191aa0
8010112a:	e8 9e 37 00 00       	call   801048cd <release>
8010112f:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
80101132:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101135:	83 f8 01             	cmp    $0x1,%eax
80101138:	75 19                	jne    80101153 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
8010113a:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010113e:	0f be d0             	movsbl %al,%edx
80101141:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101144:	83 ec 08             	sub    $0x8,%esp
80101147:	52                   	push   %edx
80101148:	50                   	push   %eax
80101149:	e8 64 25 00 00       	call   801036b2 <pipeclose>
8010114e:	83 c4 10             	add    $0x10,%esp
80101151:	eb 21                	jmp    80101174 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101153:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101156:	83 f8 02             	cmp    $0x2,%eax
80101159:	75 19                	jne    80101174 <fileclose+0xe6>
    begin_op();
8010115b:	e8 cf 1e 00 00       	call   8010302f <begin_op>
    iput(ff.ip);
80101160:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101163:	83 ec 0c             	sub    $0xc,%esp
80101166:	50                   	push   %eax
80101167:	e8 d2 09 00 00       	call   80101b3e <iput>
8010116c:	83 c4 10             	add    $0x10,%esp
    end_op();
8010116f:	e8 47 1f 00 00       	call   801030bb <end_op>
  }
}
80101174:	c9                   	leave  
80101175:	c3                   	ret    

80101176 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101176:	55                   	push   %ebp
80101177:	89 e5                	mov    %esp,%ebp
80101179:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
8010117c:	8b 45 08             	mov    0x8(%ebp),%eax
8010117f:	8b 00                	mov    (%eax),%eax
80101181:	83 f8 02             	cmp    $0x2,%eax
80101184:	75 40                	jne    801011c6 <filestat+0x50>
    ilock(f->ip);
80101186:	8b 45 08             	mov    0x8(%ebp),%eax
80101189:	8b 40 10             	mov    0x10(%eax),%eax
8010118c:	83 ec 0c             	sub    $0xc,%esp
8010118f:	50                   	push   %eax
80101190:	e8 48 08 00 00       	call   801019dd <ilock>
80101195:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
80101198:	8b 45 08             	mov    0x8(%ebp),%eax
8010119b:	8b 40 10             	mov    0x10(%eax),%eax
8010119e:	83 ec 08             	sub    $0x8,%esp
801011a1:	ff 75 0c             	push   0xc(%ebp)
801011a4:	50                   	push   %eax
801011a5:	e8 d9 0c 00 00       	call   80101e83 <stati>
801011aa:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801011ad:	8b 45 08             	mov    0x8(%ebp),%eax
801011b0:	8b 40 10             	mov    0x10(%eax),%eax
801011b3:	83 ec 0c             	sub    $0xc,%esp
801011b6:	50                   	push   %eax
801011b7:	e8 34 09 00 00       	call   80101af0 <iunlock>
801011bc:	83 c4 10             	add    $0x10,%esp
    return 0;
801011bf:	b8 00 00 00 00       	mov    $0x0,%eax
801011c4:	eb 05                	jmp    801011cb <filestat+0x55>
  }
  return -1;
801011c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011cb:	c9                   	leave  
801011cc:	c3                   	ret    

801011cd <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011cd:	55                   	push   %ebp
801011ce:	89 e5                	mov    %esp,%ebp
801011d0:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801011d3:	8b 45 08             	mov    0x8(%ebp),%eax
801011d6:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011da:	84 c0                	test   %al,%al
801011dc:	75 0a                	jne    801011e8 <fileread+0x1b>
    return -1;
801011de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011e3:	e9 9b 00 00 00       	jmp    80101283 <fileread+0xb6>
  if(f->type == FD_PIPE)
801011e8:	8b 45 08             	mov    0x8(%ebp),%eax
801011eb:	8b 00                	mov    (%eax),%eax
801011ed:	83 f8 01             	cmp    $0x1,%eax
801011f0:	75 1a                	jne    8010120c <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801011f2:	8b 45 08             	mov    0x8(%ebp),%eax
801011f5:	8b 40 0c             	mov    0xc(%eax),%eax
801011f8:	83 ec 04             	sub    $0x4,%esp
801011fb:	ff 75 10             	push   0x10(%ebp)
801011fe:	ff 75 0c             	push   0xc(%ebp)
80101201:	50                   	push   %eax
80101202:	e8 58 26 00 00       	call   8010385f <piperead>
80101207:	83 c4 10             	add    $0x10,%esp
8010120a:	eb 77                	jmp    80101283 <fileread+0xb6>
  if(f->type == FD_INODE){
8010120c:	8b 45 08             	mov    0x8(%ebp),%eax
8010120f:	8b 00                	mov    (%eax),%eax
80101211:	83 f8 02             	cmp    $0x2,%eax
80101214:	75 60                	jne    80101276 <fileread+0xa9>
    ilock(f->ip);
80101216:	8b 45 08             	mov    0x8(%ebp),%eax
80101219:	8b 40 10             	mov    0x10(%eax),%eax
8010121c:	83 ec 0c             	sub    $0xc,%esp
8010121f:	50                   	push   %eax
80101220:	e8 b8 07 00 00       	call   801019dd <ilock>
80101225:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101228:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010122b:	8b 45 08             	mov    0x8(%ebp),%eax
8010122e:	8b 50 14             	mov    0x14(%eax),%edx
80101231:	8b 45 08             	mov    0x8(%ebp),%eax
80101234:	8b 40 10             	mov    0x10(%eax),%eax
80101237:	51                   	push   %ecx
80101238:	52                   	push   %edx
80101239:	ff 75 0c             	push   0xc(%ebp)
8010123c:	50                   	push   %eax
8010123d:	e8 87 0c 00 00       	call   80101ec9 <readi>
80101242:	83 c4 10             	add    $0x10,%esp
80101245:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101248:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010124c:	7e 11                	jle    8010125f <fileread+0x92>
      f->off += r;
8010124e:	8b 45 08             	mov    0x8(%ebp),%eax
80101251:	8b 50 14             	mov    0x14(%eax),%edx
80101254:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101257:	01 c2                	add    %eax,%edx
80101259:	8b 45 08             	mov    0x8(%ebp),%eax
8010125c:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010125f:	8b 45 08             	mov    0x8(%ebp),%eax
80101262:	8b 40 10             	mov    0x10(%eax),%eax
80101265:	83 ec 0c             	sub    $0xc,%esp
80101268:	50                   	push   %eax
80101269:	e8 82 08 00 00       	call   80101af0 <iunlock>
8010126e:	83 c4 10             	add    $0x10,%esp
    return r;
80101271:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101274:	eb 0d                	jmp    80101283 <fileread+0xb6>
  }
  panic("fileread");
80101276:	83 ec 0c             	sub    $0xc,%esp
80101279:	68 c7 a1 10 80       	push   $0x8010a1c7
8010127e:	e8 26 f3 ff ff       	call   801005a9 <panic>
}
80101283:	c9                   	leave  
80101284:	c3                   	ret    

80101285 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101285:	55                   	push   %ebp
80101286:	89 e5                	mov    %esp,%ebp
80101288:	53                   	push   %ebx
80101289:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
8010128c:	8b 45 08             	mov    0x8(%ebp),%eax
8010128f:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101293:	84 c0                	test   %al,%al
80101295:	75 0a                	jne    801012a1 <filewrite+0x1c>
    return -1;
80101297:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010129c:	e9 1b 01 00 00       	jmp    801013bc <filewrite+0x137>
  if(f->type == FD_PIPE)
801012a1:	8b 45 08             	mov    0x8(%ebp),%eax
801012a4:	8b 00                	mov    (%eax),%eax
801012a6:	83 f8 01             	cmp    $0x1,%eax
801012a9:	75 1d                	jne    801012c8 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
801012ab:	8b 45 08             	mov    0x8(%ebp),%eax
801012ae:	8b 40 0c             	mov    0xc(%eax),%eax
801012b1:	83 ec 04             	sub    $0x4,%esp
801012b4:	ff 75 10             	push   0x10(%ebp)
801012b7:	ff 75 0c             	push   0xc(%ebp)
801012ba:	50                   	push   %eax
801012bb:	e8 9d 24 00 00       	call   8010375d <pipewrite>
801012c0:	83 c4 10             	add    $0x10,%esp
801012c3:	e9 f4 00 00 00       	jmp    801013bc <filewrite+0x137>
  if(f->type == FD_INODE){
801012c8:	8b 45 08             	mov    0x8(%ebp),%eax
801012cb:	8b 00                	mov    (%eax),%eax
801012cd:	83 f8 02             	cmp    $0x2,%eax
801012d0:	0f 85 d9 00 00 00    	jne    801013af <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801012d6:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801012dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012e4:	e9 a3 00 00 00       	jmp    8010138c <filewrite+0x107>
      int n1 = n - i;
801012e9:	8b 45 10             	mov    0x10(%ebp),%eax
801012ec:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801012f5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801012f8:	7e 06                	jle    80101300 <filewrite+0x7b>
        n1 = max;
801012fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801012fd:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101300:	e8 2a 1d 00 00       	call   8010302f <begin_op>
      ilock(f->ip);
80101305:	8b 45 08             	mov    0x8(%ebp),%eax
80101308:	8b 40 10             	mov    0x10(%eax),%eax
8010130b:	83 ec 0c             	sub    $0xc,%esp
8010130e:	50                   	push   %eax
8010130f:	e8 c9 06 00 00       	call   801019dd <ilock>
80101314:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101317:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010131a:	8b 45 08             	mov    0x8(%ebp),%eax
8010131d:	8b 50 14             	mov    0x14(%eax),%edx
80101320:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101323:	8b 45 0c             	mov    0xc(%ebp),%eax
80101326:	01 c3                	add    %eax,%ebx
80101328:	8b 45 08             	mov    0x8(%ebp),%eax
8010132b:	8b 40 10             	mov    0x10(%eax),%eax
8010132e:	51                   	push   %ecx
8010132f:	52                   	push   %edx
80101330:	53                   	push   %ebx
80101331:	50                   	push   %eax
80101332:	e8 e7 0c 00 00       	call   8010201e <writei>
80101337:	83 c4 10             	add    $0x10,%esp
8010133a:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010133d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101341:	7e 11                	jle    80101354 <filewrite+0xcf>
        f->off += r;
80101343:	8b 45 08             	mov    0x8(%ebp),%eax
80101346:	8b 50 14             	mov    0x14(%eax),%edx
80101349:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010134c:	01 c2                	add    %eax,%edx
8010134e:	8b 45 08             	mov    0x8(%ebp),%eax
80101351:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101354:	8b 45 08             	mov    0x8(%ebp),%eax
80101357:	8b 40 10             	mov    0x10(%eax),%eax
8010135a:	83 ec 0c             	sub    $0xc,%esp
8010135d:	50                   	push   %eax
8010135e:	e8 8d 07 00 00       	call   80101af0 <iunlock>
80101363:	83 c4 10             	add    $0x10,%esp
      end_op();
80101366:	e8 50 1d 00 00       	call   801030bb <end_op>

      if(r < 0)
8010136b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010136f:	78 29                	js     8010139a <filewrite+0x115>
        break;
      if(r != n1)
80101371:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101374:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101377:	74 0d                	je     80101386 <filewrite+0x101>
        panic("short filewrite");
80101379:	83 ec 0c             	sub    $0xc,%esp
8010137c:	68 d0 a1 10 80       	push   $0x8010a1d0
80101381:	e8 23 f2 ff ff       	call   801005a9 <panic>
      i += r;
80101386:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101389:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
8010138c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010138f:	3b 45 10             	cmp    0x10(%ebp),%eax
80101392:	0f 8c 51 ff ff ff    	jl     801012e9 <filewrite+0x64>
80101398:	eb 01                	jmp    8010139b <filewrite+0x116>
        break;
8010139a:	90                   	nop
    }
    return i == n ? n : -1;
8010139b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010139e:	3b 45 10             	cmp    0x10(%ebp),%eax
801013a1:	75 05                	jne    801013a8 <filewrite+0x123>
801013a3:	8b 45 10             	mov    0x10(%ebp),%eax
801013a6:	eb 14                	jmp    801013bc <filewrite+0x137>
801013a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013ad:	eb 0d                	jmp    801013bc <filewrite+0x137>
  }
  panic("filewrite");
801013af:	83 ec 0c             	sub    $0xc,%esp
801013b2:	68 e0 a1 10 80       	push   $0x8010a1e0
801013b7:	e8 ed f1 ff ff       	call   801005a9 <panic>
}
801013bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013bf:	c9                   	leave  
801013c0:	c3                   	ret    

801013c1 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013c1:	55                   	push   %ebp
801013c2:	89 e5                	mov    %esp,%ebp
801013c4:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801013c7:	8b 45 08             	mov    0x8(%ebp),%eax
801013ca:	83 ec 08             	sub    $0x8,%esp
801013cd:	6a 01                	push   $0x1
801013cf:	50                   	push   %eax
801013d0:	e8 2c ee ff ff       	call   80100201 <bread>
801013d5:	83 c4 10             	add    $0x10,%esp
801013d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013de:	83 c0 5c             	add    $0x5c,%eax
801013e1:	83 ec 04             	sub    $0x4,%esp
801013e4:	6a 1c                	push   $0x1c
801013e6:	50                   	push   %eax
801013e7:	ff 75 0c             	push   0xc(%ebp)
801013ea:	e8 a5 37 00 00       	call   80104b94 <memmove>
801013ef:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013f2:	83 ec 0c             	sub    $0xc,%esp
801013f5:	ff 75 f4             	push   -0xc(%ebp)
801013f8:	e8 86 ee ff ff       	call   80100283 <brelse>
801013fd:	83 c4 10             	add    $0x10,%esp
}
80101400:	90                   	nop
80101401:	c9                   	leave  
80101402:	c3                   	ret    

80101403 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101403:	55                   	push   %ebp
80101404:	89 e5                	mov    %esp,%ebp
80101406:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101409:	8b 55 0c             	mov    0xc(%ebp),%edx
8010140c:	8b 45 08             	mov    0x8(%ebp),%eax
8010140f:	83 ec 08             	sub    $0x8,%esp
80101412:	52                   	push   %edx
80101413:	50                   	push   %eax
80101414:	e8 e8 ed ff ff       	call   80100201 <bread>
80101419:	83 c4 10             	add    $0x10,%esp
8010141c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010141f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101422:	83 c0 5c             	add    $0x5c,%eax
80101425:	83 ec 04             	sub    $0x4,%esp
80101428:	68 00 02 00 00       	push   $0x200
8010142d:	6a 00                	push   $0x0
8010142f:	50                   	push   %eax
80101430:	e8 a0 36 00 00       	call   80104ad5 <memset>
80101435:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101438:	83 ec 0c             	sub    $0xc,%esp
8010143b:	ff 75 f4             	push   -0xc(%ebp)
8010143e:	e8 25 1e 00 00       	call   80103268 <log_write>
80101443:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101446:	83 ec 0c             	sub    $0xc,%esp
80101449:	ff 75 f4             	push   -0xc(%ebp)
8010144c:	e8 32 ee ff ff       	call   80100283 <brelse>
80101451:	83 c4 10             	add    $0x10,%esp
}
80101454:	90                   	nop
80101455:	c9                   	leave  
80101456:	c3                   	ret    

80101457 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101457:	55                   	push   %ebp
80101458:	89 e5                	mov    %esp,%ebp
8010145a:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
8010145d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101464:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010146b:	e9 0b 01 00 00       	jmp    8010157b <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
80101470:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101473:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101479:	85 c0                	test   %eax,%eax
8010147b:	0f 48 c2             	cmovs  %edx,%eax
8010147e:	c1 f8 0c             	sar    $0xc,%eax
80101481:	89 c2                	mov    %eax,%edx
80101483:	a1 58 24 19 80       	mov    0x80192458,%eax
80101488:	01 d0                	add    %edx,%eax
8010148a:	83 ec 08             	sub    $0x8,%esp
8010148d:	50                   	push   %eax
8010148e:	ff 75 08             	push   0x8(%ebp)
80101491:	e8 6b ed ff ff       	call   80100201 <bread>
80101496:	83 c4 10             	add    $0x10,%esp
80101499:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010149c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801014a3:	e9 9e 00 00 00       	jmp    80101546 <balloc+0xef>
      m = 1 << (bi % 8);
801014a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014ab:	83 e0 07             	and    $0x7,%eax
801014ae:	ba 01 00 00 00       	mov    $0x1,%edx
801014b3:	89 c1                	mov    %eax,%ecx
801014b5:	d3 e2                	shl    %cl,%edx
801014b7:	89 d0                	mov    %edx,%eax
801014b9:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014bf:	8d 50 07             	lea    0x7(%eax),%edx
801014c2:	85 c0                	test   %eax,%eax
801014c4:	0f 48 c2             	cmovs  %edx,%eax
801014c7:	c1 f8 03             	sar    $0x3,%eax
801014ca:	89 c2                	mov    %eax,%edx
801014cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014cf:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801014d4:	0f b6 c0             	movzbl %al,%eax
801014d7:	23 45 e8             	and    -0x18(%ebp),%eax
801014da:	85 c0                	test   %eax,%eax
801014dc:	75 64                	jne    80101542 <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
801014de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014e1:	8d 50 07             	lea    0x7(%eax),%edx
801014e4:	85 c0                	test   %eax,%eax
801014e6:	0f 48 c2             	cmovs  %edx,%eax
801014e9:	c1 f8 03             	sar    $0x3,%eax
801014ec:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014ef:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801014f4:	89 d1                	mov    %edx,%ecx
801014f6:	8b 55 e8             	mov    -0x18(%ebp),%edx
801014f9:	09 ca                	or     %ecx,%edx
801014fb:	89 d1                	mov    %edx,%ecx
801014fd:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101500:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101504:	83 ec 0c             	sub    $0xc,%esp
80101507:	ff 75 ec             	push   -0x14(%ebp)
8010150a:	e8 59 1d 00 00       	call   80103268 <log_write>
8010150f:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101512:	83 ec 0c             	sub    $0xc,%esp
80101515:	ff 75 ec             	push   -0x14(%ebp)
80101518:	e8 66 ed ff ff       	call   80100283 <brelse>
8010151d:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101520:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101523:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101526:	01 c2                	add    %eax,%edx
80101528:	8b 45 08             	mov    0x8(%ebp),%eax
8010152b:	83 ec 08             	sub    $0x8,%esp
8010152e:	52                   	push   %edx
8010152f:	50                   	push   %eax
80101530:	e8 ce fe ff ff       	call   80101403 <bzero>
80101535:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101538:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010153b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010153e:	01 d0                	add    %edx,%eax
80101540:	eb 57                	jmp    80101599 <balloc+0x142>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101542:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101546:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010154d:	7f 17                	jg     80101566 <balloc+0x10f>
8010154f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101552:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101555:	01 d0                	add    %edx,%eax
80101557:	89 c2                	mov    %eax,%edx
80101559:	a1 40 24 19 80       	mov    0x80192440,%eax
8010155e:	39 c2                	cmp    %eax,%edx
80101560:	0f 82 42 ff ff ff    	jb     801014a8 <balloc+0x51>
      }
    }
    brelse(bp);
80101566:	83 ec 0c             	sub    $0xc,%esp
80101569:	ff 75 ec             	push   -0x14(%ebp)
8010156c:	e8 12 ed ff ff       	call   80100283 <brelse>
80101571:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
80101574:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010157b:	8b 15 40 24 19 80    	mov    0x80192440,%edx
80101581:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101584:	39 c2                	cmp    %eax,%edx
80101586:	0f 87 e4 fe ff ff    	ja     80101470 <balloc+0x19>
  }
  panic("balloc: out of blocks");
8010158c:	83 ec 0c             	sub    $0xc,%esp
8010158f:	68 ec a1 10 80       	push   $0x8010a1ec
80101594:	e8 10 f0 ff ff       	call   801005a9 <panic>
}
80101599:	c9                   	leave  
8010159a:	c3                   	ret    

8010159b <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010159b:	55                   	push   %ebp
8010159c:	89 e5                	mov    %esp,%ebp
8010159e:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801015a1:	83 ec 08             	sub    $0x8,%esp
801015a4:	68 40 24 19 80       	push   $0x80192440
801015a9:	ff 75 08             	push   0x8(%ebp)
801015ac:	e8 10 fe ff ff       	call   801013c1 <readsb>
801015b1:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801015b7:	c1 e8 0c             	shr    $0xc,%eax
801015ba:	89 c2                	mov    %eax,%edx
801015bc:	a1 58 24 19 80       	mov    0x80192458,%eax
801015c1:	01 c2                	add    %eax,%edx
801015c3:	8b 45 08             	mov    0x8(%ebp),%eax
801015c6:	83 ec 08             	sub    $0x8,%esp
801015c9:	52                   	push   %edx
801015ca:	50                   	push   %eax
801015cb:	e8 31 ec ff ff       	call   80100201 <bread>
801015d0:	83 c4 10             	add    $0x10,%esp
801015d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801015d9:	25 ff 0f 00 00       	and    $0xfff,%eax
801015de:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015e4:	83 e0 07             	and    $0x7,%eax
801015e7:	ba 01 00 00 00       	mov    $0x1,%edx
801015ec:	89 c1                	mov    %eax,%ecx
801015ee:	d3 e2                	shl    %cl,%edx
801015f0:	89 d0                	mov    %edx,%eax
801015f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801015f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015f8:	8d 50 07             	lea    0x7(%eax),%edx
801015fb:	85 c0                	test   %eax,%eax
801015fd:	0f 48 c2             	cmovs  %edx,%eax
80101600:	c1 f8 03             	sar    $0x3,%eax
80101603:	89 c2                	mov    %eax,%edx
80101605:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101608:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
8010160d:	0f b6 c0             	movzbl %al,%eax
80101610:	23 45 ec             	and    -0x14(%ebp),%eax
80101613:	85 c0                	test   %eax,%eax
80101615:	75 0d                	jne    80101624 <bfree+0x89>
    panic("freeing free block");
80101617:	83 ec 0c             	sub    $0xc,%esp
8010161a:	68 02 a2 10 80       	push   $0x8010a202
8010161f:	e8 85 ef ff ff       	call   801005a9 <panic>
  bp->data[bi/8] &= ~m;
80101624:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101627:	8d 50 07             	lea    0x7(%eax),%edx
8010162a:	85 c0                	test   %eax,%eax
8010162c:	0f 48 c2             	cmovs  %edx,%eax
8010162f:	c1 f8 03             	sar    $0x3,%eax
80101632:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101635:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
8010163a:	89 d1                	mov    %edx,%ecx
8010163c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010163f:	f7 d2                	not    %edx
80101641:	21 ca                	and    %ecx,%edx
80101643:	89 d1                	mov    %edx,%ecx
80101645:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101648:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
8010164c:	83 ec 0c             	sub    $0xc,%esp
8010164f:	ff 75 f4             	push   -0xc(%ebp)
80101652:	e8 11 1c 00 00       	call   80103268 <log_write>
80101657:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010165a:	83 ec 0c             	sub    $0xc,%esp
8010165d:	ff 75 f4             	push   -0xc(%ebp)
80101660:	e8 1e ec ff ff       	call   80100283 <brelse>
80101665:	83 c4 10             	add    $0x10,%esp
}
80101668:	90                   	nop
80101669:	c9                   	leave  
8010166a:	c3                   	ret    

8010166b <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
8010166b:	55                   	push   %ebp
8010166c:	89 e5                	mov    %esp,%ebp
8010166e:	57                   	push   %edi
8010166f:	56                   	push   %esi
80101670:	53                   	push   %ebx
80101671:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
80101674:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
8010167b:	83 ec 08             	sub    $0x8,%esp
8010167e:	68 15 a2 10 80       	push   $0x8010a215
80101683:	68 60 24 19 80       	push   $0x80192460
80101688:	e8 b0 31 00 00       	call   8010483d <initlock>
8010168d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
80101690:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101697:	eb 2d                	jmp    801016c6 <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
80101699:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010169c:	89 d0                	mov    %edx,%eax
8010169e:	c1 e0 03             	shl    $0x3,%eax
801016a1:	01 d0                	add    %edx,%eax
801016a3:	c1 e0 04             	shl    $0x4,%eax
801016a6:	83 c0 30             	add    $0x30,%eax
801016a9:	05 60 24 19 80       	add    $0x80192460,%eax
801016ae:	83 c0 10             	add    $0x10,%eax
801016b1:	83 ec 08             	sub    $0x8,%esp
801016b4:	68 1c a2 10 80       	push   $0x8010a21c
801016b9:	50                   	push   %eax
801016ba:	e8 21 30 00 00       	call   801046e0 <initsleeplock>
801016bf:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016c2:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801016c6:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016ca:	7e cd                	jle    80101699 <iinit+0x2e>
  }

  readsb(dev, &sb);
801016cc:	83 ec 08             	sub    $0x8,%esp
801016cf:	68 40 24 19 80       	push   $0x80192440
801016d4:	ff 75 08             	push   0x8(%ebp)
801016d7:	e8 e5 fc ff ff       	call   801013c1 <readsb>
801016dc:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016df:	a1 58 24 19 80       	mov    0x80192458,%eax
801016e4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801016e7:	8b 3d 54 24 19 80    	mov    0x80192454,%edi
801016ed:	8b 35 50 24 19 80    	mov    0x80192450,%esi
801016f3:	8b 1d 4c 24 19 80    	mov    0x8019244c,%ebx
801016f9:	8b 0d 48 24 19 80    	mov    0x80192448,%ecx
801016ff:	8b 15 44 24 19 80    	mov    0x80192444,%edx
80101705:	a1 40 24 19 80       	mov    0x80192440,%eax
8010170a:	ff 75 d4             	push   -0x2c(%ebp)
8010170d:	57                   	push   %edi
8010170e:	56                   	push   %esi
8010170f:	53                   	push   %ebx
80101710:	51                   	push   %ecx
80101711:	52                   	push   %edx
80101712:	50                   	push   %eax
80101713:	68 24 a2 10 80       	push   $0x8010a224
80101718:	e8 d7 ec ff ff       	call   801003f4 <cprintf>
8010171d:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
80101720:	90                   	nop
80101721:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101724:	5b                   	pop    %ebx
80101725:	5e                   	pop    %esi
80101726:	5f                   	pop    %edi
80101727:	5d                   	pop    %ebp
80101728:	c3                   	ret    

80101729 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101729:	55                   	push   %ebp
8010172a:	89 e5                	mov    %esp,%ebp
8010172c:	83 ec 28             	sub    $0x28,%esp
8010172f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101732:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101736:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010173d:	e9 9e 00 00 00       	jmp    801017e0 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
80101742:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101745:	c1 e8 03             	shr    $0x3,%eax
80101748:	89 c2                	mov    %eax,%edx
8010174a:	a1 54 24 19 80       	mov    0x80192454,%eax
8010174f:	01 d0                	add    %edx,%eax
80101751:	83 ec 08             	sub    $0x8,%esp
80101754:	50                   	push   %eax
80101755:	ff 75 08             	push   0x8(%ebp)
80101758:	e8 a4 ea ff ff       	call   80100201 <bread>
8010175d:	83 c4 10             	add    $0x10,%esp
80101760:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101763:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101766:	8d 50 5c             	lea    0x5c(%eax),%edx
80101769:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010176c:	83 e0 07             	and    $0x7,%eax
8010176f:	c1 e0 06             	shl    $0x6,%eax
80101772:	01 d0                	add    %edx,%eax
80101774:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101777:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010177a:	0f b7 00             	movzwl (%eax),%eax
8010177d:	66 85 c0             	test   %ax,%ax
80101780:	75 4c                	jne    801017ce <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
80101782:	83 ec 04             	sub    $0x4,%esp
80101785:	6a 40                	push   $0x40
80101787:	6a 00                	push   $0x0
80101789:	ff 75 ec             	push   -0x14(%ebp)
8010178c:	e8 44 33 00 00       	call   80104ad5 <memset>
80101791:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101794:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101797:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
8010179b:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
8010179e:	83 ec 0c             	sub    $0xc,%esp
801017a1:	ff 75 f0             	push   -0x10(%ebp)
801017a4:	e8 bf 1a 00 00       	call   80103268 <log_write>
801017a9:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017ac:	83 ec 0c             	sub    $0xc,%esp
801017af:	ff 75 f0             	push   -0x10(%ebp)
801017b2:	e8 cc ea ff ff       	call   80100283 <brelse>
801017b7:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017bd:	83 ec 08             	sub    $0x8,%esp
801017c0:	50                   	push   %eax
801017c1:	ff 75 08             	push   0x8(%ebp)
801017c4:	e8 f8 00 00 00       	call   801018c1 <iget>
801017c9:	83 c4 10             	add    $0x10,%esp
801017cc:	eb 30                	jmp    801017fe <ialloc+0xd5>
    }
    brelse(bp);
801017ce:	83 ec 0c             	sub    $0xc,%esp
801017d1:	ff 75 f0             	push   -0x10(%ebp)
801017d4:	e8 aa ea ff ff       	call   80100283 <brelse>
801017d9:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801017dc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801017e0:	8b 15 48 24 19 80    	mov    0x80192448,%edx
801017e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017e9:	39 c2                	cmp    %eax,%edx
801017eb:	0f 87 51 ff ff ff    	ja     80101742 <ialloc+0x19>
  }
  panic("ialloc: no inodes");
801017f1:	83 ec 0c             	sub    $0xc,%esp
801017f4:	68 77 a2 10 80       	push   $0x8010a277
801017f9:	e8 ab ed ff ff       	call   801005a9 <panic>
}
801017fe:	c9                   	leave  
801017ff:	c3                   	ret    

80101800 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101800:	55                   	push   %ebp
80101801:	89 e5                	mov    %esp,%ebp
80101803:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101806:	8b 45 08             	mov    0x8(%ebp),%eax
80101809:	8b 40 04             	mov    0x4(%eax),%eax
8010180c:	c1 e8 03             	shr    $0x3,%eax
8010180f:	89 c2                	mov    %eax,%edx
80101811:	a1 54 24 19 80       	mov    0x80192454,%eax
80101816:	01 c2                	add    %eax,%edx
80101818:	8b 45 08             	mov    0x8(%ebp),%eax
8010181b:	8b 00                	mov    (%eax),%eax
8010181d:	83 ec 08             	sub    $0x8,%esp
80101820:	52                   	push   %edx
80101821:	50                   	push   %eax
80101822:	e8 da e9 ff ff       	call   80100201 <bread>
80101827:	83 c4 10             	add    $0x10,%esp
8010182a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010182d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101830:	8d 50 5c             	lea    0x5c(%eax),%edx
80101833:	8b 45 08             	mov    0x8(%ebp),%eax
80101836:	8b 40 04             	mov    0x4(%eax),%eax
80101839:	83 e0 07             	and    $0x7,%eax
8010183c:	c1 e0 06             	shl    $0x6,%eax
8010183f:	01 d0                	add    %edx,%eax
80101841:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101844:	8b 45 08             	mov    0x8(%ebp),%eax
80101847:	0f b7 50 50          	movzwl 0x50(%eax),%edx
8010184b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010184e:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101851:	8b 45 08             	mov    0x8(%ebp),%eax
80101854:	0f b7 50 52          	movzwl 0x52(%eax),%edx
80101858:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010185b:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010185f:	8b 45 08             	mov    0x8(%ebp),%eax
80101862:	0f b7 50 54          	movzwl 0x54(%eax),%edx
80101866:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101869:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010186d:	8b 45 08             	mov    0x8(%ebp),%eax
80101870:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101874:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101877:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
8010187b:	8b 45 08             	mov    0x8(%ebp),%eax
8010187e:	8b 50 58             	mov    0x58(%eax),%edx
80101881:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101884:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101887:	8b 45 08             	mov    0x8(%ebp),%eax
8010188a:	8d 50 5c             	lea    0x5c(%eax),%edx
8010188d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101890:	83 c0 0c             	add    $0xc,%eax
80101893:	83 ec 04             	sub    $0x4,%esp
80101896:	6a 34                	push   $0x34
80101898:	52                   	push   %edx
80101899:	50                   	push   %eax
8010189a:	e8 f5 32 00 00       	call   80104b94 <memmove>
8010189f:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018a2:	83 ec 0c             	sub    $0xc,%esp
801018a5:	ff 75 f4             	push   -0xc(%ebp)
801018a8:	e8 bb 19 00 00       	call   80103268 <log_write>
801018ad:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018b0:	83 ec 0c             	sub    $0xc,%esp
801018b3:	ff 75 f4             	push   -0xc(%ebp)
801018b6:	e8 c8 e9 ff ff       	call   80100283 <brelse>
801018bb:	83 c4 10             	add    $0x10,%esp
}
801018be:	90                   	nop
801018bf:	c9                   	leave  
801018c0:	c3                   	ret    

801018c1 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018c1:	55                   	push   %ebp
801018c2:	89 e5                	mov    %esp,%ebp
801018c4:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801018c7:	83 ec 0c             	sub    $0xc,%esp
801018ca:	68 60 24 19 80       	push   $0x80192460
801018cf:	e8 8b 2f 00 00       	call   8010485f <acquire>
801018d4:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801018d7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018de:	c7 45 f4 94 24 19 80 	movl   $0x80192494,-0xc(%ebp)
801018e5:	eb 60                	jmp    80101947 <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801018e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ea:	8b 40 08             	mov    0x8(%eax),%eax
801018ed:	85 c0                	test   %eax,%eax
801018ef:	7e 39                	jle    8010192a <iget+0x69>
801018f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f4:	8b 00                	mov    (%eax),%eax
801018f6:	39 45 08             	cmp    %eax,0x8(%ebp)
801018f9:	75 2f                	jne    8010192a <iget+0x69>
801018fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018fe:	8b 40 04             	mov    0x4(%eax),%eax
80101901:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101904:	75 24                	jne    8010192a <iget+0x69>
      ip->ref++;
80101906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101909:	8b 40 08             	mov    0x8(%eax),%eax
8010190c:	8d 50 01             	lea    0x1(%eax),%edx
8010190f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101912:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101915:	83 ec 0c             	sub    $0xc,%esp
80101918:	68 60 24 19 80       	push   $0x80192460
8010191d:	e8 ab 2f 00 00       	call   801048cd <release>
80101922:	83 c4 10             	add    $0x10,%esp
      return ip;
80101925:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101928:	eb 77                	jmp    801019a1 <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010192a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010192e:	75 10                	jne    80101940 <iget+0x7f>
80101930:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101933:	8b 40 08             	mov    0x8(%eax),%eax
80101936:	85 c0                	test   %eax,%eax
80101938:	75 06                	jne    80101940 <iget+0x7f>
      empty = ip;
8010193a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010193d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101940:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101947:	81 7d f4 b4 40 19 80 	cmpl   $0x801940b4,-0xc(%ebp)
8010194e:	72 97                	jb     801018e7 <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101950:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101954:	75 0d                	jne    80101963 <iget+0xa2>
    panic("iget: no inodes");
80101956:	83 ec 0c             	sub    $0xc,%esp
80101959:	68 89 a2 10 80       	push   $0x8010a289
8010195e:	e8 46 ec ff ff       	call   801005a9 <panic>

  ip = empty;
80101963:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101966:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101969:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010196c:	8b 55 08             	mov    0x8(%ebp),%edx
8010196f:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101971:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101974:	8b 55 0c             	mov    0xc(%ebp),%edx
80101977:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
8010197a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010197d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101984:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101987:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
8010198e:	83 ec 0c             	sub    $0xc,%esp
80101991:	68 60 24 19 80       	push   $0x80192460
80101996:	e8 32 2f 00 00       	call   801048cd <release>
8010199b:	83 c4 10             	add    $0x10,%esp

  return ip;
8010199e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801019a1:	c9                   	leave  
801019a2:	c3                   	ret    

801019a3 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801019a3:	55                   	push   %ebp
801019a4:	89 e5                	mov    %esp,%ebp
801019a6:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801019a9:	83 ec 0c             	sub    $0xc,%esp
801019ac:	68 60 24 19 80       	push   $0x80192460
801019b1:	e8 a9 2e 00 00       	call   8010485f <acquire>
801019b6:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019b9:	8b 45 08             	mov    0x8(%ebp),%eax
801019bc:	8b 40 08             	mov    0x8(%eax),%eax
801019bf:	8d 50 01             	lea    0x1(%eax),%edx
801019c2:	8b 45 08             	mov    0x8(%ebp),%eax
801019c5:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019c8:	83 ec 0c             	sub    $0xc,%esp
801019cb:	68 60 24 19 80       	push   $0x80192460
801019d0:	e8 f8 2e 00 00       	call   801048cd <release>
801019d5:	83 c4 10             	add    $0x10,%esp
  return ip;
801019d8:	8b 45 08             	mov    0x8(%ebp),%eax
}
801019db:	c9                   	leave  
801019dc:	c3                   	ret    

801019dd <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801019dd:	55                   	push   %ebp
801019de:	89 e5                	mov    %esp,%ebp
801019e0:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801019e3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019e7:	74 0a                	je     801019f3 <ilock+0x16>
801019e9:	8b 45 08             	mov    0x8(%ebp),%eax
801019ec:	8b 40 08             	mov    0x8(%eax),%eax
801019ef:	85 c0                	test   %eax,%eax
801019f1:	7f 0d                	jg     80101a00 <ilock+0x23>
    panic("ilock");
801019f3:	83 ec 0c             	sub    $0xc,%esp
801019f6:	68 99 a2 10 80       	push   $0x8010a299
801019fb:	e8 a9 eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a00:	8b 45 08             	mov    0x8(%ebp),%eax
80101a03:	83 c0 0c             	add    $0xc,%eax
80101a06:	83 ec 0c             	sub    $0xc,%esp
80101a09:	50                   	push   %eax
80101a0a:	e8 0d 2d 00 00       	call   8010471c <acquiresleep>
80101a0f:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101a12:	8b 45 08             	mov    0x8(%ebp),%eax
80101a15:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a18:	85 c0                	test   %eax,%eax
80101a1a:	0f 85 cd 00 00 00    	jne    80101aed <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a20:	8b 45 08             	mov    0x8(%ebp),%eax
80101a23:	8b 40 04             	mov    0x4(%eax),%eax
80101a26:	c1 e8 03             	shr    $0x3,%eax
80101a29:	89 c2                	mov    %eax,%edx
80101a2b:	a1 54 24 19 80       	mov    0x80192454,%eax
80101a30:	01 c2                	add    %eax,%edx
80101a32:	8b 45 08             	mov    0x8(%ebp),%eax
80101a35:	8b 00                	mov    (%eax),%eax
80101a37:	83 ec 08             	sub    $0x8,%esp
80101a3a:	52                   	push   %edx
80101a3b:	50                   	push   %eax
80101a3c:	e8 c0 e7 ff ff       	call   80100201 <bread>
80101a41:	83 c4 10             	add    $0x10,%esp
80101a44:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a4a:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a50:	8b 40 04             	mov    0x4(%eax),%eax
80101a53:	83 e0 07             	and    $0x7,%eax
80101a56:	c1 e0 06             	shl    $0x6,%eax
80101a59:	01 d0                	add    %edx,%eax
80101a5b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a61:	0f b7 10             	movzwl (%eax),%edx
80101a64:	8b 45 08             	mov    0x8(%ebp),%eax
80101a67:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101a6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a6e:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a72:	8b 45 08             	mov    0x8(%ebp),%eax
80101a75:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101a79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a7c:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a80:	8b 45 08             	mov    0x8(%ebp),%eax
80101a83:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101a87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a8a:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a91:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101a95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a98:	8b 50 08             	mov    0x8(%eax),%edx
80101a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9e:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101aa1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aa4:	8d 50 0c             	lea    0xc(%eax),%edx
80101aa7:	8b 45 08             	mov    0x8(%ebp),%eax
80101aaa:	83 c0 5c             	add    $0x5c,%eax
80101aad:	83 ec 04             	sub    $0x4,%esp
80101ab0:	6a 34                	push   $0x34
80101ab2:	52                   	push   %edx
80101ab3:	50                   	push   %eax
80101ab4:	e8 db 30 00 00       	call   80104b94 <memmove>
80101ab9:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101abc:	83 ec 0c             	sub    $0xc,%esp
80101abf:	ff 75 f4             	push   -0xc(%ebp)
80101ac2:	e8 bc e7 ff ff       	call   80100283 <brelse>
80101ac7:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101aca:	8b 45 08             	mov    0x8(%ebp),%eax
80101acd:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101ad4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101adb:	66 85 c0             	test   %ax,%ax
80101ade:	75 0d                	jne    80101aed <ilock+0x110>
      panic("ilock: no type");
80101ae0:	83 ec 0c             	sub    $0xc,%esp
80101ae3:	68 9f a2 10 80       	push   $0x8010a29f
80101ae8:	e8 bc ea ff ff       	call   801005a9 <panic>
  }
}
80101aed:	90                   	nop
80101aee:	c9                   	leave  
80101aef:	c3                   	ret    

80101af0 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101af0:	55                   	push   %ebp
80101af1:	89 e5                	mov    %esp,%ebp
80101af3:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101af6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101afa:	74 20                	je     80101b1c <iunlock+0x2c>
80101afc:	8b 45 08             	mov    0x8(%ebp),%eax
80101aff:	83 c0 0c             	add    $0xc,%eax
80101b02:	83 ec 0c             	sub    $0xc,%esp
80101b05:	50                   	push   %eax
80101b06:	e8 c3 2c 00 00       	call   801047ce <holdingsleep>
80101b0b:	83 c4 10             	add    $0x10,%esp
80101b0e:	85 c0                	test   %eax,%eax
80101b10:	74 0a                	je     80101b1c <iunlock+0x2c>
80101b12:	8b 45 08             	mov    0x8(%ebp),%eax
80101b15:	8b 40 08             	mov    0x8(%eax),%eax
80101b18:	85 c0                	test   %eax,%eax
80101b1a:	7f 0d                	jg     80101b29 <iunlock+0x39>
    panic("iunlock");
80101b1c:	83 ec 0c             	sub    $0xc,%esp
80101b1f:	68 ae a2 10 80       	push   $0x8010a2ae
80101b24:	e8 80 ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b29:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2c:	83 c0 0c             	add    $0xc,%eax
80101b2f:	83 ec 0c             	sub    $0xc,%esp
80101b32:	50                   	push   %eax
80101b33:	e8 48 2c 00 00       	call   80104780 <releasesleep>
80101b38:	83 c4 10             	add    $0x10,%esp
}
80101b3b:	90                   	nop
80101b3c:	c9                   	leave  
80101b3d:	c3                   	ret    

80101b3e <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b3e:	55                   	push   %ebp
80101b3f:	89 e5                	mov    %esp,%ebp
80101b41:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101b44:	8b 45 08             	mov    0x8(%ebp),%eax
80101b47:	83 c0 0c             	add    $0xc,%eax
80101b4a:	83 ec 0c             	sub    $0xc,%esp
80101b4d:	50                   	push   %eax
80101b4e:	e8 c9 2b 00 00       	call   8010471c <acquiresleep>
80101b53:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101b56:	8b 45 08             	mov    0x8(%ebp),%eax
80101b59:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b5c:	85 c0                	test   %eax,%eax
80101b5e:	74 6a                	je     80101bca <iput+0x8c>
80101b60:	8b 45 08             	mov    0x8(%ebp),%eax
80101b63:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101b67:	66 85 c0             	test   %ax,%ax
80101b6a:	75 5e                	jne    80101bca <iput+0x8c>
    acquire(&icache.lock);
80101b6c:	83 ec 0c             	sub    $0xc,%esp
80101b6f:	68 60 24 19 80       	push   $0x80192460
80101b74:	e8 e6 2c 00 00       	call   8010485f <acquire>
80101b79:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b7c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7f:	8b 40 08             	mov    0x8(%eax),%eax
80101b82:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b85:	83 ec 0c             	sub    $0xc,%esp
80101b88:	68 60 24 19 80       	push   $0x80192460
80101b8d:	e8 3b 2d 00 00       	call   801048cd <release>
80101b92:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101b95:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101b99:	75 2f                	jne    80101bca <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101b9b:	83 ec 0c             	sub    $0xc,%esp
80101b9e:	ff 75 08             	push   0x8(%ebp)
80101ba1:	e8 ad 01 00 00       	call   80101d53 <itrunc>
80101ba6:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101ba9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bac:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101bb2:	83 ec 0c             	sub    $0xc,%esp
80101bb5:	ff 75 08             	push   0x8(%ebp)
80101bb8:	e8 43 fc ff ff       	call   80101800 <iupdate>
80101bbd:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101bc0:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc3:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101bca:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcd:	83 c0 0c             	add    $0xc,%eax
80101bd0:	83 ec 0c             	sub    $0xc,%esp
80101bd3:	50                   	push   %eax
80101bd4:	e8 a7 2b 00 00       	call   80104780 <releasesleep>
80101bd9:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101bdc:	83 ec 0c             	sub    $0xc,%esp
80101bdf:	68 60 24 19 80       	push   $0x80192460
80101be4:	e8 76 2c 00 00       	call   8010485f <acquire>
80101be9:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101bec:	8b 45 08             	mov    0x8(%ebp),%eax
80101bef:	8b 40 08             	mov    0x8(%eax),%eax
80101bf2:	8d 50 ff             	lea    -0x1(%eax),%edx
80101bf5:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf8:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101bfb:	83 ec 0c             	sub    $0xc,%esp
80101bfe:	68 60 24 19 80       	push   $0x80192460
80101c03:	e8 c5 2c 00 00       	call   801048cd <release>
80101c08:	83 c4 10             	add    $0x10,%esp
}
80101c0b:	90                   	nop
80101c0c:	c9                   	leave  
80101c0d:	c3                   	ret    

80101c0e <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c0e:	55                   	push   %ebp
80101c0f:	89 e5                	mov    %esp,%ebp
80101c11:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c14:	83 ec 0c             	sub    $0xc,%esp
80101c17:	ff 75 08             	push   0x8(%ebp)
80101c1a:	e8 d1 fe ff ff       	call   80101af0 <iunlock>
80101c1f:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c22:	83 ec 0c             	sub    $0xc,%esp
80101c25:	ff 75 08             	push   0x8(%ebp)
80101c28:	e8 11 ff ff ff       	call   80101b3e <iput>
80101c2d:	83 c4 10             	add    $0x10,%esp
}
80101c30:	90                   	nop
80101c31:	c9                   	leave  
80101c32:	c3                   	ret    

80101c33 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c33:	55                   	push   %ebp
80101c34:	89 e5                	mov    %esp,%ebp
80101c36:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c39:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c3d:	77 42                	ja     80101c81 <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101c3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c42:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c45:	83 c2 14             	add    $0x14,%edx
80101c48:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c4f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c53:	75 24                	jne    80101c79 <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c55:	8b 45 08             	mov    0x8(%ebp),%eax
80101c58:	8b 00                	mov    (%eax),%eax
80101c5a:	83 ec 0c             	sub    $0xc,%esp
80101c5d:	50                   	push   %eax
80101c5e:	e8 f4 f7 ff ff       	call   80101457 <balloc>
80101c63:	83 c4 10             	add    $0x10,%esp
80101c66:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c69:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6c:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c6f:	8d 4a 14             	lea    0x14(%edx),%ecx
80101c72:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c75:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c7c:	e9 d0 00 00 00       	jmp    80101d51 <bmap+0x11e>
  }
  bn -= NDIRECT;
80101c81:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c85:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c89:	0f 87 b5 00 00 00    	ja     80101d44 <bmap+0x111>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101c8f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c92:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101c98:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c9b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c9f:	75 20                	jne    80101cc1 <bmap+0x8e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101ca1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca4:	8b 00                	mov    (%eax),%eax
80101ca6:	83 ec 0c             	sub    $0xc,%esp
80101ca9:	50                   	push   %eax
80101caa:	e8 a8 f7 ff ff       	call   80101457 <balloc>
80101caf:	83 c4 10             	add    $0x10,%esp
80101cb2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cb5:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cbb:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101cc1:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc4:	8b 00                	mov    (%eax),%eax
80101cc6:	83 ec 08             	sub    $0x8,%esp
80101cc9:	ff 75 f4             	push   -0xc(%ebp)
80101ccc:	50                   	push   %eax
80101ccd:	e8 2f e5 ff ff       	call   80100201 <bread>
80101cd2:	83 c4 10             	add    $0x10,%esp
80101cd5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101cd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cdb:	83 c0 5c             	add    $0x5c,%eax
80101cde:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101ce1:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ce4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ceb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cee:	01 d0                	add    %edx,%eax
80101cf0:	8b 00                	mov    (%eax),%eax
80101cf2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cf5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cf9:	75 36                	jne    80101d31 <bmap+0xfe>
      a[bn] = addr = balloc(ip->dev);
80101cfb:	8b 45 08             	mov    0x8(%ebp),%eax
80101cfe:	8b 00                	mov    (%eax),%eax
80101d00:	83 ec 0c             	sub    $0xc,%esp
80101d03:	50                   	push   %eax
80101d04:	e8 4e f7 ff ff       	call   80101457 <balloc>
80101d09:	83 c4 10             	add    $0x10,%esp
80101d0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d0f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d12:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d19:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d1c:	01 c2                	add    %eax,%edx
80101d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d21:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d23:	83 ec 0c             	sub    $0xc,%esp
80101d26:	ff 75 f0             	push   -0x10(%ebp)
80101d29:	e8 3a 15 00 00       	call   80103268 <log_write>
80101d2e:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d31:	83 ec 0c             	sub    $0xc,%esp
80101d34:	ff 75 f0             	push   -0x10(%ebp)
80101d37:	e8 47 e5 ff ff       	call   80100283 <brelse>
80101d3c:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d42:	eb 0d                	jmp    80101d51 <bmap+0x11e>
  }

  panic("bmap: out of range");
80101d44:	83 ec 0c             	sub    $0xc,%esp
80101d47:	68 b6 a2 10 80       	push   $0x8010a2b6
80101d4c:	e8 58 e8 ff ff       	call   801005a9 <panic>
}
80101d51:	c9                   	leave  
80101d52:	c3                   	ret    

80101d53 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d53:	55                   	push   %ebp
80101d54:	89 e5                	mov    %esp,%ebp
80101d56:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d59:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d60:	eb 45                	jmp    80101da7 <itrunc+0x54>
    if(ip->addrs[i]){
80101d62:	8b 45 08             	mov    0x8(%ebp),%eax
80101d65:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d68:	83 c2 14             	add    $0x14,%edx
80101d6b:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d6f:	85 c0                	test   %eax,%eax
80101d71:	74 30                	je     80101da3 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d73:	8b 45 08             	mov    0x8(%ebp),%eax
80101d76:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d79:	83 c2 14             	add    $0x14,%edx
80101d7c:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d80:	8b 55 08             	mov    0x8(%ebp),%edx
80101d83:	8b 12                	mov    (%edx),%edx
80101d85:	83 ec 08             	sub    $0x8,%esp
80101d88:	50                   	push   %eax
80101d89:	52                   	push   %edx
80101d8a:	e8 0c f8 ff ff       	call   8010159b <bfree>
80101d8f:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101d92:	8b 45 08             	mov    0x8(%ebp),%eax
80101d95:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d98:	83 c2 14             	add    $0x14,%edx
80101d9b:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101da2:	00 
  for(i = 0; i < NDIRECT; i++){
80101da3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101da7:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101dab:	7e b5                	jle    80101d62 <itrunc+0xf>
    }
  }

  if(ip->addrs[NDIRECT]){
80101dad:	8b 45 08             	mov    0x8(%ebp),%eax
80101db0:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101db6:	85 c0                	test   %eax,%eax
80101db8:	0f 84 aa 00 00 00    	je     80101e68 <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dbe:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc1:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101dc7:	8b 45 08             	mov    0x8(%ebp),%eax
80101dca:	8b 00                	mov    (%eax),%eax
80101dcc:	83 ec 08             	sub    $0x8,%esp
80101dcf:	52                   	push   %edx
80101dd0:	50                   	push   %eax
80101dd1:	e8 2b e4 ff ff       	call   80100201 <bread>
80101dd6:	83 c4 10             	add    $0x10,%esp
80101dd9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101ddc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ddf:	83 c0 5c             	add    $0x5c,%eax
80101de2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101de5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101dec:	eb 3c                	jmp    80101e2a <itrunc+0xd7>
      if(a[j])
80101dee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101df1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101df8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101dfb:	01 d0                	add    %edx,%eax
80101dfd:	8b 00                	mov    (%eax),%eax
80101dff:	85 c0                	test   %eax,%eax
80101e01:	74 23                	je     80101e26 <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101e03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e06:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e10:	01 d0                	add    %edx,%eax
80101e12:	8b 00                	mov    (%eax),%eax
80101e14:	8b 55 08             	mov    0x8(%ebp),%edx
80101e17:	8b 12                	mov    (%edx),%edx
80101e19:	83 ec 08             	sub    $0x8,%esp
80101e1c:	50                   	push   %eax
80101e1d:	52                   	push   %edx
80101e1e:	e8 78 f7 ff ff       	call   8010159b <bfree>
80101e23:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101e26:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e2d:	83 f8 7f             	cmp    $0x7f,%eax
80101e30:	76 bc                	jbe    80101dee <itrunc+0x9b>
    }
    brelse(bp);
80101e32:	83 ec 0c             	sub    $0xc,%esp
80101e35:	ff 75 ec             	push   -0x14(%ebp)
80101e38:	e8 46 e4 ff ff       	call   80100283 <brelse>
80101e3d:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e40:	8b 45 08             	mov    0x8(%ebp),%eax
80101e43:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e49:	8b 55 08             	mov    0x8(%ebp),%edx
80101e4c:	8b 12                	mov    (%edx),%edx
80101e4e:	83 ec 08             	sub    $0x8,%esp
80101e51:	50                   	push   %eax
80101e52:	52                   	push   %edx
80101e53:	e8 43 f7 ff ff       	call   8010159b <bfree>
80101e58:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e5b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e5e:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101e65:	00 00 00 
  }

  ip->size = 0;
80101e68:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6b:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101e72:	83 ec 0c             	sub    $0xc,%esp
80101e75:	ff 75 08             	push   0x8(%ebp)
80101e78:	e8 83 f9 ff ff       	call   80101800 <iupdate>
80101e7d:	83 c4 10             	add    $0x10,%esp
}
80101e80:	90                   	nop
80101e81:	c9                   	leave  
80101e82:	c3                   	ret    

80101e83 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101e83:	55                   	push   %ebp
80101e84:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e86:	8b 45 08             	mov    0x8(%ebp),%eax
80101e89:	8b 00                	mov    (%eax),%eax
80101e8b:	89 c2                	mov    %eax,%edx
80101e8d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e90:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101e93:	8b 45 08             	mov    0x8(%ebp),%eax
80101e96:	8b 50 04             	mov    0x4(%eax),%edx
80101e99:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e9c:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101e9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea2:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101ea6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ea9:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101eac:	8b 45 08             	mov    0x8(%ebp),%eax
80101eaf:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101eb3:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb6:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101eba:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebd:	8b 50 58             	mov    0x58(%eax),%edx
80101ec0:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ec3:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ec6:	90                   	nop
80101ec7:	5d                   	pop    %ebp
80101ec8:	c3                   	ret    

80101ec9 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ec9:	55                   	push   %ebp
80101eca:	89 e5                	mov    %esp,%ebp
80101ecc:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ecf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed2:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ed6:	66 83 f8 03          	cmp    $0x3,%ax
80101eda:	75 5c                	jne    80101f38 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101edc:	8b 45 08             	mov    0x8(%ebp),%eax
80101edf:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101ee3:	66 85 c0             	test   %ax,%ax
80101ee6:	78 20                	js     80101f08 <readi+0x3f>
80101ee8:	8b 45 08             	mov    0x8(%ebp),%eax
80101eeb:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101eef:	66 83 f8 09          	cmp    $0x9,%ax
80101ef3:	7f 13                	jg     80101f08 <readi+0x3f>
80101ef5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef8:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101efc:	98                   	cwtl   
80101efd:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f04:	85 c0                	test   %eax,%eax
80101f06:	75 0a                	jne    80101f12 <readi+0x49>
      return -1;
80101f08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f0d:	e9 0a 01 00 00       	jmp    8010201c <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f12:	8b 45 08             	mov    0x8(%ebp),%eax
80101f15:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f19:	98                   	cwtl   
80101f1a:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f21:	8b 55 14             	mov    0x14(%ebp),%edx
80101f24:	83 ec 04             	sub    $0x4,%esp
80101f27:	52                   	push   %edx
80101f28:	ff 75 0c             	push   0xc(%ebp)
80101f2b:	ff 75 08             	push   0x8(%ebp)
80101f2e:	ff d0                	call   *%eax
80101f30:	83 c4 10             	add    $0x10,%esp
80101f33:	e9 e4 00 00 00       	jmp    8010201c <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80101f38:	8b 45 08             	mov    0x8(%ebp),%eax
80101f3b:	8b 40 58             	mov    0x58(%eax),%eax
80101f3e:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f41:	77 0d                	ja     80101f50 <readi+0x87>
80101f43:	8b 55 10             	mov    0x10(%ebp),%edx
80101f46:	8b 45 14             	mov    0x14(%ebp),%eax
80101f49:	01 d0                	add    %edx,%eax
80101f4b:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f4e:	76 0a                	jbe    80101f5a <readi+0x91>
    return -1;
80101f50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f55:	e9 c2 00 00 00       	jmp    8010201c <readi+0x153>
  if(off + n > ip->size)
80101f5a:	8b 55 10             	mov    0x10(%ebp),%edx
80101f5d:	8b 45 14             	mov    0x14(%ebp),%eax
80101f60:	01 c2                	add    %eax,%edx
80101f62:	8b 45 08             	mov    0x8(%ebp),%eax
80101f65:	8b 40 58             	mov    0x58(%eax),%eax
80101f68:	39 c2                	cmp    %eax,%edx
80101f6a:	76 0c                	jbe    80101f78 <readi+0xaf>
    n = ip->size - off;
80101f6c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f6f:	8b 40 58             	mov    0x58(%eax),%eax
80101f72:	2b 45 10             	sub    0x10(%ebp),%eax
80101f75:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f78:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f7f:	e9 89 00 00 00       	jmp    8010200d <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f84:	8b 45 10             	mov    0x10(%ebp),%eax
80101f87:	c1 e8 09             	shr    $0x9,%eax
80101f8a:	83 ec 08             	sub    $0x8,%esp
80101f8d:	50                   	push   %eax
80101f8e:	ff 75 08             	push   0x8(%ebp)
80101f91:	e8 9d fc ff ff       	call   80101c33 <bmap>
80101f96:	83 c4 10             	add    $0x10,%esp
80101f99:	8b 55 08             	mov    0x8(%ebp),%edx
80101f9c:	8b 12                	mov    (%edx),%edx
80101f9e:	83 ec 08             	sub    $0x8,%esp
80101fa1:	50                   	push   %eax
80101fa2:	52                   	push   %edx
80101fa3:	e8 59 e2 ff ff       	call   80100201 <bread>
80101fa8:	83 c4 10             	add    $0x10,%esp
80101fab:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fae:	8b 45 10             	mov    0x10(%ebp),%eax
80101fb1:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fb6:	ba 00 02 00 00       	mov    $0x200,%edx
80101fbb:	29 c2                	sub    %eax,%edx
80101fbd:	8b 45 14             	mov    0x14(%ebp),%eax
80101fc0:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fc3:	39 c2                	cmp    %eax,%edx
80101fc5:	0f 46 c2             	cmovbe %edx,%eax
80101fc8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fce:	8d 50 5c             	lea    0x5c(%eax),%edx
80101fd1:	8b 45 10             	mov    0x10(%ebp),%eax
80101fd4:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fd9:	01 d0                	add    %edx,%eax
80101fdb:	83 ec 04             	sub    $0x4,%esp
80101fde:	ff 75 ec             	push   -0x14(%ebp)
80101fe1:	50                   	push   %eax
80101fe2:	ff 75 0c             	push   0xc(%ebp)
80101fe5:	e8 aa 2b 00 00       	call   80104b94 <memmove>
80101fea:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101fed:	83 ec 0c             	sub    $0xc,%esp
80101ff0:	ff 75 f0             	push   -0x10(%ebp)
80101ff3:	e8 8b e2 ff ff       	call   80100283 <brelse>
80101ff8:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101ffb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ffe:	01 45 f4             	add    %eax,-0xc(%ebp)
80102001:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102004:	01 45 10             	add    %eax,0x10(%ebp)
80102007:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010200a:	01 45 0c             	add    %eax,0xc(%ebp)
8010200d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102010:	3b 45 14             	cmp    0x14(%ebp),%eax
80102013:	0f 82 6b ff ff ff    	jb     80101f84 <readi+0xbb>
  }
  return n;
80102019:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010201c:	c9                   	leave  
8010201d:	c3                   	ret    

8010201e <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010201e:	55                   	push   %ebp
8010201f:	89 e5                	mov    %esp,%ebp
80102021:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102024:	8b 45 08             	mov    0x8(%ebp),%eax
80102027:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010202b:	66 83 f8 03          	cmp    $0x3,%ax
8010202f:	75 5c                	jne    8010208d <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102031:	8b 45 08             	mov    0x8(%ebp),%eax
80102034:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102038:	66 85 c0             	test   %ax,%ax
8010203b:	78 20                	js     8010205d <writei+0x3f>
8010203d:	8b 45 08             	mov    0x8(%ebp),%eax
80102040:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102044:	66 83 f8 09          	cmp    $0x9,%ax
80102048:	7f 13                	jg     8010205d <writei+0x3f>
8010204a:	8b 45 08             	mov    0x8(%ebp),%eax
8010204d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102051:	98                   	cwtl   
80102052:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
80102059:	85 c0                	test   %eax,%eax
8010205b:	75 0a                	jne    80102067 <writei+0x49>
      return -1;
8010205d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102062:	e9 3b 01 00 00       	jmp    801021a2 <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
80102067:	8b 45 08             	mov    0x8(%ebp),%eax
8010206a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010206e:	98                   	cwtl   
8010206f:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
80102076:	8b 55 14             	mov    0x14(%ebp),%edx
80102079:	83 ec 04             	sub    $0x4,%esp
8010207c:	52                   	push   %edx
8010207d:	ff 75 0c             	push   0xc(%ebp)
80102080:	ff 75 08             	push   0x8(%ebp)
80102083:	ff d0                	call   *%eax
80102085:	83 c4 10             	add    $0x10,%esp
80102088:	e9 15 01 00 00       	jmp    801021a2 <writei+0x184>
  }

  if(off > ip->size || off + n < off)
8010208d:	8b 45 08             	mov    0x8(%ebp),%eax
80102090:	8b 40 58             	mov    0x58(%eax),%eax
80102093:	39 45 10             	cmp    %eax,0x10(%ebp)
80102096:	77 0d                	ja     801020a5 <writei+0x87>
80102098:	8b 55 10             	mov    0x10(%ebp),%edx
8010209b:	8b 45 14             	mov    0x14(%ebp),%eax
8010209e:	01 d0                	add    %edx,%eax
801020a0:	39 45 10             	cmp    %eax,0x10(%ebp)
801020a3:	76 0a                	jbe    801020af <writei+0x91>
    return -1;
801020a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020aa:	e9 f3 00 00 00       	jmp    801021a2 <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
801020af:	8b 55 10             	mov    0x10(%ebp),%edx
801020b2:	8b 45 14             	mov    0x14(%ebp),%eax
801020b5:	01 d0                	add    %edx,%eax
801020b7:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020bc:	76 0a                	jbe    801020c8 <writei+0xaa>
    return -1;
801020be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020c3:	e9 da 00 00 00       	jmp    801021a2 <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020cf:	e9 97 00 00 00       	jmp    8010216b <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020d4:	8b 45 10             	mov    0x10(%ebp),%eax
801020d7:	c1 e8 09             	shr    $0x9,%eax
801020da:	83 ec 08             	sub    $0x8,%esp
801020dd:	50                   	push   %eax
801020de:	ff 75 08             	push   0x8(%ebp)
801020e1:	e8 4d fb ff ff       	call   80101c33 <bmap>
801020e6:	83 c4 10             	add    $0x10,%esp
801020e9:	8b 55 08             	mov    0x8(%ebp),%edx
801020ec:	8b 12                	mov    (%edx),%edx
801020ee:	83 ec 08             	sub    $0x8,%esp
801020f1:	50                   	push   %eax
801020f2:	52                   	push   %edx
801020f3:	e8 09 e1 ff ff       	call   80100201 <bread>
801020f8:	83 c4 10             	add    $0x10,%esp
801020fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801020fe:	8b 45 10             	mov    0x10(%ebp),%eax
80102101:	25 ff 01 00 00       	and    $0x1ff,%eax
80102106:	ba 00 02 00 00       	mov    $0x200,%edx
8010210b:	29 c2                	sub    %eax,%edx
8010210d:	8b 45 14             	mov    0x14(%ebp),%eax
80102110:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102113:	39 c2                	cmp    %eax,%edx
80102115:	0f 46 c2             	cmovbe %edx,%eax
80102118:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
8010211b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010211e:	8d 50 5c             	lea    0x5c(%eax),%edx
80102121:	8b 45 10             	mov    0x10(%ebp),%eax
80102124:	25 ff 01 00 00       	and    $0x1ff,%eax
80102129:	01 d0                	add    %edx,%eax
8010212b:	83 ec 04             	sub    $0x4,%esp
8010212e:	ff 75 ec             	push   -0x14(%ebp)
80102131:	ff 75 0c             	push   0xc(%ebp)
80102134:	50                   	push   %eax
80102135:	e8 5a 2a 00 00       	call   80104b94 <memmove>
8010213a:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
8010213d:	83 ec 0c             	sub    $0xc,%esp
80102140:	ff 75 f0             	push   -0x10(%ebp)
80102143:	e8 20 11 00 00       	call   80103268 <log_write>
80102148:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010214b:	83 ec 0c             	sub    $0xc,%esp
8010214e:	ff 75 f0             	push   -0x10(%ebp)
80102151:	e8 2d e1 ff ff       	call   80100283 <brelse>
80102156:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102159:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010215c:	01 45 f4             	add    %eax,-0xc(%ebp)
8010215f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102162:	01 45 10             	add    %eax,0x10(%ebp)
80102165:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102168:	01 45 0c             	add    %eax,0xc(%ebp)
8010216b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010216e:	3b 45 14             	cmp    0x14(%ebp),%eax
80102171:	0f 82 5d ff ff ff    	jb     801020d4 <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
80102177:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010217b:	74 22                	je     8010219f <writei+0x181>
8010217d:	8b 45 08             	mov    0x8(%ebp),%eax
80102180:	8b 40 58             	mov    0x58(%eax),%eax
80102183:	39 45 10             	cmp    %eax,0x10(%ebp)
80102186:	76 17                	jbe    8010219f <writei+0x181>
    ip->size = off;
80102188:	8b 45 08             	mov    0x8(%ebp),%eax
8010218b:	8b 55 10             	mov    0x10(%ebp),%edx
8010218e:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
80102191:	83 ec 0c             	sub    $0xc,%esp
80102194:	ff 75 08             	push   0x8(%ebp)
80102197:	e8 64 f6 ff ff       	call   80101800 <iupdate>
8010219c:	83 c4 10             	add    $0x10,%esp
  }
  return n;
8010219f:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021a2:	c9                   	leave  
801021a3:	c3                   	ret    

801021a4 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021a4:	55                   	push   %ebp
801021a5:	89 e5                	mov    %esp,%ebp
801021a7:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021aa:	83 ec 04             	sub    $0x4,%esp
801021ad:	6a 0e                	push   $0xe
801021af:	ff 75 0c             	push   0xc(%ebp)
801021b2:	ff 75 08             	push   0x8(%ebp)
801021b5:	e8 70 2a 00 00       	call   80104c2a <strncmp>
801021ba:	83 c4 10             	add    $0x10,%esp
}
801021bd:	c9                   	leave  
801021be:	c3                   	ret    

801021bf <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021bf:	55                   	push   %ebp
801021c0:	89 e5                	mov    %esp,%ebp
801021c2:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021c5:	8b 45 08             	mov    0x8(%ebp),%eax
801021c8:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801021cc:	66 83 f8 01          	cmp    $0x1,%ax
801021d0:	74 0d                	je     801021df <dirlookup+0x20>
    panic("dirlookup not DIR");
801021d2:	83 ec 0c             	sub    $0xc,%esp
801021d5:	68 c9 a2 10 80       	push   $0x8010a2c9
801021da:	e8 ca e3 ff ff       	call   801005a9 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021df:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021e6:	eb 7b                	jmp    80102263 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021e8:	6a 10                	push   $0x10
801021ea:	ff 75 f4             	push   -0xc(%ebp)
801021ed:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021f0:	50                   	push   %eax
801021f1:	ff 75 08             	push   0x8(%ebp)
801021f4:	e8 d0 fc ff ff       	call   80101ec9 <readi>
801021f9:	83 c4 10             	add    $0x10,%esp
801021fc:	83 f8 10             	cmp    $0x10,%eax
801021ff:	74 0d                	je     8010220e <dirlookup+0x4f>
      panic("dirlookup read");
80102201:	83 ec 0c             	sub    $0xc,%esp
80102204:	68 db a2 10 80       	push   $0x8010a2db
80102209:	e8 9b e3 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
8010220e:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102212:	66 85 c0             	test   %ax,%ax
80102215:	74 47                	je     8010225e <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
80102217:	83 ec 08             	sub    $0x8,%esp
8010221a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010221d:	83 c0 02             	add    $0x2,%eax
80102220:	50                   	push   %eax
80102221:	ff 75 0c             	push   0xc(%ebp)
80102224:	e8 7b ff ff ff       	call   801021a4 <namecmp>
80102229:	83 c4 10             	add    $0x10,%esp
8010222c:	85 c0                	test   %eax,%eax
8010222e:	75 2f                	jne    8010225f <dirlookup+0xa0>
      // entry matches path element
      if(poff)
80102230:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102234:	74 08                	je     8010223e <dirlookup+0x7f>
        *poff = off;
80102236:	8b 45 10             	mov    0x10(%ebp),%eax
80102239:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010223c:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010223e:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102242:	0f b7 c0             	movzwl %ax,%eax
80102245:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102248:	8b 45 08             	mov    0x8(%ebp),%eax
8010224b:	8b 00                	mov    (%eax),%eax
8010224d:	83 ec 08             	sub    $0x8,%esp
80102250:	ff 75 f0             	push   -0x10(%ebp)
80102253:	50                   	push   %eax
80102254:	e8 68 f6 ff ff       	call   801018c1 <iget>
80102259:	83 c4 10             	add    $0x10,%esp
8010225c:	eb 19                	jmp    80102277 <dirlookup+0xb8>
      continue;
8010225e:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
8010225f:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102263:	8b 45 08             	mov    0x8(%ebp),%eax
80102266:	8b 40 58             	mov    0x58(%eax),%eax
80102269:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010226c:	0f 82 76 ff ff ff    	jb     801021e8 <dirlookup+0x29>
    }
  }

  return 0;
80102272:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102277:	c9                   	leave  
80102278:	c3                   	ret    

80102279 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102279:	55                   	push   %ebp
8010227a:	89 e5                	mov    %esp,%ebp
8010227c:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010227f:	83 ec 04             	sub    $0x4,%esp
80102282:	6a 00                	push   $0x0
80102284:	ff 75 0c             	push   0xc(%ebp)
80102287:	ff 75 08             	push   0x8(%ebp)
8010228a:	e8 30 ff ff ff       	call   801021bf <dirlookup>
8010228f:	83 c4 10             	add    $0x10,%esp
80102292:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102295:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102299:	74 18                	je     801022b3 <dirlink+0x3a>
    iput(ip);
8010229b:	83 ec 0c             	sub    $0xc,%esp
8010229e:	ff 75 f0             	push   -0x10(%ebp)
801022a1:	e8 98 f8 ff ff       	call   80101b3e <iput>
801022a6:	83 c4 10             	add    $0x10,%esp
    return -1;
801022a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022ae:	e9 9c 00 00 00       	jmp    8010234f <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022b3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022ba:	eb 39                	jmp    801022f5 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022bf:	6a 10                	push   $0x10
801022c1:	50                   	push   %eax
801022c2:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022c5:	50                   	push   %eax
801022c6:	ff 75 08             	push   0x8(%ebp)
801022c9:	e8 fb fb ff ff       	call   80101ec9 <readi>
801022ce:	83 c4 10             	add    $0x10,%esp
801022d1:	83 f8 10             	cmp    $0x10,%eax
801022d4:	74 0d                	je     801022e3 <dirlink+0x6a>
      panic("dirlink read");
801022d6:	83 ec 0c             	sub    $0xc,%esp
801022d9:	68 ea a2 10 80       	push   $0x8010a2ea
801022de:	e8 c6 e2 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
801022e3:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022e7:	66 85 c0             	test   %ax,%ax
801022ea:	74 18                	je     80102304 <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
801022ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022ef:	83 c0 10             	add    $0x10,%eax
801022f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801022f5:	8b 45 08             	mov    0x8(%ebp),%eax
801022f8:	8b 50 58             	mov    0x58(%eax),%edx
801022fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022fe:	39 c2                	cmp    %eax,%edx
80102300:	77 ba                	ja     801022bc <dirlink+0x43>
80102302:	eb 01                	jmp    80102305 <dirlink+0x8c>
      break;
80102304:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102305:	83 ec 04             	sub    $0x4,%esp
80102308:	6a 0e                	push   $0xe
8010230a:	ff 75 0c             	push   0xc(%ebp)
8010230d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102310:	83 c0 02             	add    $0x2,%eax
80102313:	50                   	push   %eax
80102314:	e8 67 29 00 00       	call   80104c80 <strncpy>
80102319:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
8010231c:	8b 45 10             	mov    0x10(%ebp),%eax
8010231f:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102323:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102326:	6a 10                	push   $0x10
80102328:	50                   	push   %eax
80102329:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010232c:	50                   	push   %eax
8010232d:	ff 75 08             	push   0x8(%ebp)
80102330:	e8 e9 fc ff ff       	call   8010201e <writei>
80102335:	83 c4 10             	add    $0x10,%esp
80102338:	83 f8 10             	cmp    $0x10,%eax
8010233b:	74 0d                	je     8010234a <dirlink+0xd1>
    panic("dirlink");
8010233d:	83 ec 0c             	sub    $0xc,%esp
80102340:	68 f7 a2 10 80       	push   $0x8010a2f7
80102345:	e8 5f e2 ff ff       	call   801005a9 <panic>

  return 0;
8010234a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010234f:	c9                   	leave  
80102350:	c3                   	ret    

80102351 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102351:	55                   	push   %ebp
80102352:	89 e5                	mov    %esp,%ebp
80102354:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102357:	eb 04                	jmp    8010235d <skipelem+0xc>
    path++;
80102359:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
8010235d:	8b 45 08             	mov    0x8(%ebp),%eax
80102360:	0f b6 00             	movzbl (%eax),%eax
80102363:	3c 2f                	cmp    $0x2f,%al
80102365:	74 f2                	je     80102359 <skipelem+0x8>
  if(*path == 0)
80102367:	8b 45 08             	mov    0x8(%ebp),%eax
8010236a:	0f b6 00             	movzbl (%eax),%eax
8010236d:	84 c0                	test   %al,%al
8010236f:	75 07                	jne    80102378 <skipelem+0x27>
    return 0;
80102371:	b8 00 00 00 00       	mov    $0x0,%eax
80102376:	eb 77                	jmp    801023ef <skipelem+0x9e>
  s = path;
80102378:	8b 45 08             	mov    0x8(%ebp),%eax
8010237b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010237e:	eb 04                	jmp    80102384 <skipelem+0x33>
    path++;
80102380:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102384:	8b 45 08             	mov    0x8(%ebp),%eax
80102387:	0f b6 00             	movzbl (%eax),%eax
8010238a:	3c 2f                	cmp    $0x2f,%al
8010238c:	74 0a                	je     80102398 <skipelem+0x47>
8010238e:	8b 45 08             	mov    0x8(%ebp),%eax
80102391:	0f b6 00             	movzbl (%eax),%eax
80102394:	84 c0                	test   %al,%al
80102396:	75 e8                	jne    80102380 <skipelem+0x2f>
  len = path - s;
80102398:	8b 45 08             	mov    0x8(%ebp),%eax
8010239b:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010239e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023a1:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023a5:	7e 15                	jle    801023bc <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
801023a7:	83 ec 04             	sub    $0x4,%esp
801023aa:	6a 0e                	push   $0xe
801023ac:	ff 75 f4             	push   -0xc(%ebp)
801023af:	ff 75 0c             	push   0xc(%ebp)
801023b2:	e8 dd 27 00 00       	call   80104b94 <memmove>
801023b7:	83 c4 10             	add    $0x10,%esp
801023ba:	eb 26                	jmp    801023e2 <skipelem+0x91>
  else {
    memmove(name, s, len);
801023bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023bf:	83 ec 04             	sub    $0x4,%esp
801023c2:	50                   	push   %eax
801023c3:	ff 75 f4             	push   -0xc(%ebp)
801023c6:	ff 75 0c             	push   0xc(%ebp)
801023c9:	e8 c6 27 00 00       	call   80104b94 <memmove>
801023ce:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023d1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801023d7:	01 d0                	add    %edx,%eax
801023d9:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023dc:	eb 04                	jmp    801023e2 <skipelem+0x91>
    path++;
801023de:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801023e2:	8b 45 08             	mov    0x8(%ebp),%eax
801023e5:	0f b6 00             	movzbl (%eax),%eax
801023e8:	3c 2f                	cmp    $0x2f,%al
801023ea:	74 f2                	je     801023de <skipelem+0x8d>
  return path;
801023ec:	8b 45 08             	mov    0x8(%ebp),%eax
}
801023ef:	c9                   	leave  
801023f0:	c3                   	ret    

801023f1 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801023f1:	55                   	push   %ebp
801023f2:	89 e5                	mov    %esp,%ebp
801023f4:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801023f7:	8b 45 08             	mov    0x8(%ebp),%eax
801023fa:	0f b6 00             	movzbl (%eax),%eax
801023fd:	3c 2f                	cmp    $0x2f,%al
801023ff:	75 17                	jne    80102418 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
80102401:	83 ec 08             	sub    $0x8,%esp
80102404:	6a 01                	push   $0x1
80102406:	6a 01                	push   $0x1
80102408:	e8 b4 f4 ff ff       	call   801018c1 <iget>
8010240d:	83 c4 10             	add    $0x10,%esp
80102410:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102413:	e9 ba 00 00 00       	jmp    801024d2 <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
80102418:	e8 06 16 00 00       	call   80103a23 <myproc>
8010241d:	8b 40 68             	mov    0x68(%eax),%eax
80102420:	83 ec 0c             	sub    $0xc,%esp
80102423:	50                   	push   %eax
80102424:	e8 7a f5 ff ff       	call   801019a3 <idup>
80102429:	83 c4 10             	add    $0x10,%esp
8010242c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010242f:	e9 9e 00 00 00       	jmp    801024d2 <namex+0xe1>
    ilock(ip);
80102434:	83 ec 0c             	sub    $0xc,%esp
80102437:	ff 75 f4             	push   -0xc(%ebp)
8010243a:	e8 9e f5 ff ff       	call   801019dd <ilock>
8010243f:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102442:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102445:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102449:	66 83 f8 01          	cmp    $0x1,%ax
8010244d:	74 18                	je     80102467 <namex+0x76>
      iunlockput(ip);
8010244f:	83 ec 0c             	sub    $0xc,%esp
80102452:	ff 75 f4             	push   -0xc(%ebp)
80102455:	e8 b4 f7 ff ff       	call   80101c0e <iunlockput>
8010245a:	83 c4 10             	add    $0x10,%esp
      return 0;
8010245d:	b8 00 00 00 00       	mov    $0x0,%eax
80102462:	e9 a7 00 00 00       	jmp    8010250e <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
80102467:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010246b:	74 20                	je     8010248d <namex+0x9c>
8010246d:	8b 45 08             	mov    0x8(%ebp),%eax
80102470:	0f b6 00             	movzbl (%eax),%eax
80102473:	84 c0                	test   %al,%al
80102475:	75 16                	jne    8010248d <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
80102477:	83 ec 0c             	sub    $0xc,%esp
8010247a:	ff 75 f4             	push   -0xc(%ebp)
8010247d:	e8 6e f6 ff ff       	call   80101af0 <iunlock>
80102482:	83 c4 10             	add    $0x10,%esp
      return ip;
80102485:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102488:	e9 81 00 00 00       	jmp    8010250e <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010248d:	83 ec 04             	sub    $0x4,%esp
80102490:	6a 00                	push   $0x0
80102492:	ff 75 10             	push   0x10(%ebp)
80102495:	ff 75 f4             	push   -0xc(%ebp)
80102498:	e8 22 fd ff ff       	call   801021bf <dirlookup>
8010249d:	83 c4 10             	add    $0x10,%esp
801024a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024a3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024a7:	75 15                	jne    801024be <namex+0xcd>
      iunlockput(ip);
801024a9:	83 ec 0c             	sub    $0xc,%esp
801024ac:	ff 75 f4             	push   -0xc(%ebp)
801024af:	e8 5a f7 ff ff       	call   80101c0e <iunlockput>
801024b4:	83 c4 10             	add    $0x10,%esp
      return 0;
801024b7:	b8 00 00 00 00       	mov    $0x0,%eax
801024bc:	eb 50                	jmp    8010250e <namex+0x11d>
    }
    iunlockput(ip);
801024be:	83 ec 0c             	sub    $0xc,%esp
801024c1:	ff 75 f4             	push   -0xc(%ebp)
801024c4:	e8 45 f7 ff ff       	call   80101c0e <iunlockput>
801024c9:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801024d2:	83 ec 08             	sub    $0x8,%esp
801024d5:	ff 75 10             	push   0x10(%ebp)
801024d8:	ff 75 08             	push   0x8(%ebp)
801024db:	e8 71 fe ff ff       	call   80102351 <skipelem>
801024e0:	83 c4 10             	add    $0x10,%esp
801024e3:	89 45 08             	mov    %eax,0x8(%ebp)
801024e6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024ea:	0f 85 44 ff ff ff    	jne    80102434 <namex+0x43>
  }
  if(nameiparent){
801024f0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801024f4:	74 15                	je     8010250b <namex+0x11a>
    iput(ip);
801024f6:	83 ec 0c             	sub    $0xc,%esp
801024f9:	ff 75 f4             	push   -0xc(%ebp)
801024fc:	e8 3d f6 ff ff       	call   80101b3e <iput>
80102501:	83 c4 10             	add    $0x10,%esp
    return 0;
80102504:	b8 00 00 00 00       	mov    $0x0,%eax
80102509:	eb 03                	jmp    8010250e <namex+0x11d>
  }
  return ip;
8010250b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010250e:	c9                   	leave  
8010250f:	c3                   	ret    

80102510 <namei>:

struct inode*
namei(char *path)
{
80102510:	55                   	push   %ebp
80102511:	89 e5                	mov    %esp,%ebp
80102513:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102516:	83 ec 04             	sub    $0x4,%esp
80102519:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010251c:	50                   	push   %eax
8010251d:	6a 00                	push   $0x0
8010251f:	ff 75 08             	push   0x8(%ebp)
80102522:	e8 ca fe ff ff       	call   801023f1 <namex>
80102527:	83 c4 10             	add    $0x10,%esp
}
8010252a:	c9                   	leave  
8010252b:	c3                   	ret    

8010252c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
8010252c:	55                   	push   %ebp
8010252d:	89 e5                	mov    %esp,%ebp
8010252f:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102532:	83 ec 04             	sub    $0x4,%esp
80102535:	ff 75 0c             	push   0xc(%ebp)
80102538:	6a 01                	push   $0x1
8010253a:	ff 75 08             	push   0x8(%ebp)
8010253d:	e8 af fe ff ff       	call   801023f1 <namex>
80102542:	83 c4 10             	add    $0x10,%esp
}
80102545:	c9                   	leave  
80102546:	c3                   	ret    

80102547 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102547:	55                   	push   %ebp
80102548:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010254a:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010254f:	8b 55 08             	mov    0x8(%ebp),%edx
80102552:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102554:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102559:	8b 40 10             	mov    0x10(%eax),%eax
}
8010255c:	5d                   	pop    %ebp
8010255d:	c3                   	ret    

8010255e <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
8010255e:	55                   	push   %ebp
8010255f:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102561:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102566:	8b 55 08             	mov    0x8(%ebp),%edx
80102569:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
8010256b:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102570:	8b 55 0c             	mov    0xc(%ebp),%edx
80102573:	89 50 10             	mov    %edx,0x10(%eax)
}
80102576:	90                   	nop
80102577:	5d                   	pop    %ebp
80102578:	c3                   	ret    

80102579 <ioapicinit>:

void
ioapicinit(void)
{
80102579:	55                   	push   %ebp
8010257a:	89 e5                	mov    %esp,%ebp
8010257c:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
8010257f:	c7 05 b4 40 19 80 00 	movl   $0xfec00000,0x801940b4
80102586:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102589:	6a 01                	push   $0x1
8010258b:	e8 b7 ff ff ff       	call   80102547 <ioapicread>
80102590:	83 c4 04             	add    $0x4,%esp
80102593:	c1 e8 10             	shr    $0x10,%eax
80102596:	25 ff 00 00 00       	and    $0xff,%eax
8010259b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
8010259e:	6a 00                	push   $0x0
801025a0:	e8 a2 ff ff ff       	call   80102547 <ioapicread>
801025a5:	83 c4 04             	add    $0x4,%esp
801025a8:	c1 e8 18             	shr    $0x18,%eax
801025ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801025ae:	0f b6 05 44 6c 19 80 	movzbl 0x80196c44,%eax
801025b5:	0f b6 c0             	movzbl %al,%eax
801025b8:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801025bb:	74 10                	je     801025cd <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801025bd:	83 ec 0c             	sub    $0xc,%esp
801025c0:	68 00 a3 10 80       	push   $0x8010a300
801025c5:	e8 2a de ff ff       	call   801003f4 <cprintf>
801025ca:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801025cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025d4:	eb 3f                	jmp    80102615 <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801025d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025d9:	83 c0 20             	add    $0x20,%eax
801025dc:	0d 00 00 01 00       	or     $0x10000,%eax
801025e1:	89 c2                	mov    %eax,%edx
801025e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025e6:	83 c0 08             	add    $0x8,%eax
801025e9:	01 c0                	add    %eax,%eax
801025eb:	83 ec 08             	sub    $0x8,%esp
801025ee:	52                   	push   %edx
801025ef:	50                   	push   %eax
801025f0:	e8 69 ff ff ff       	call   8010255e <ioapicwrite>
801025f5:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
801025f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025fb:	83 c0 08             	add    $0x8,%eax
801025fe:	01 c0                	add    %eax,%eax
80102600:	83 c0 01             	add    $0x1,%eax
80102603:	83 ec 08             	sub    $0x8,%esp
80102606:	6a 00                	push   $0x0
80102608:	50                   	push   %eax
80102609:	e8 50 ff ff ff       	call   8010255e <ioapicwrite>
8010260e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102611:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102615:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102618:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010261b:	7e b9                	jle    801025d6 <ioapicinit+0x5d>
  }
}
8010261d:	90                   	nop
8010261e:	90                   	nop
8010261f:	c9                   	leave  
80102620:	c3                   	ret    

80102621 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102621:	55                   	push   %ebp
80102622:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102624:	8b 45 08             	mov    0x8(%ebp),%eax
80102627:	83 c0 20             	add    $0x20,%eax
8010262a:	89 c2                	mov    %eax,%edx
8010262c:	8b 45 08             	mov    0x8(%ebp),%eax
8010262f:	83 c0 08             	add    $0x8,%eax
80102632:	01 c0                	add    %eax,%eax
80102634:	52                   	push   %edx
80102635:	50                   	push   %eax
80102636:	e8 23 ff ff ff       	call   8010255e <ioapicwrite>
8010263b:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010263e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102641:	c1 e0 18             	shl    $0x18,%eax
80102644:	89 c2                	mov    %eax,%edx
80102646:	8b 45 08             	mov    0x8(%ebp),%eax
80102649:	83 c0 08             	add    $0x8,%eax
8010264c:	01 c0                	add    %eax,%eax
8010264e:	83 c0 01             	add    $0x1,%eax
80102651:	52                   	push   %edx
80102652:	50                   	push   %eax
80102653:	e8 06 ff ff ff       	call   8010255e <ioapicwrite>
80102658:	83 c4 08             	add    $0x8,%esp
}
8010265b:	90                   	nop
8010265c:	c9                   	leave  
8010265d:	c3                   	ret    

8010265e <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
8010265e:	55                   	push   %ebp
8010265f:	89 e5                	mov    %esp,%ebp
80102661:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102664:	83 ec 08             	sub    $0x8,%esp
80102667:	68 32 a3 10 80       	push   $0x8010a332
8010266c:	68 c0 40 19 80       	push   $0x801940c0
80102671:	e8 c7 21 00 00       	call   8010483d <initlock>
80102676:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102679:	c7 05 f4 40 19 80 00 	movl   $0x0,0x801940f4
80102680:	00 00 00 
  freerange(vstart, vend);
80102683:	83 ec 08             	sub    $0x8,%esp
80102686:	ff 75 0c             	push   0xc(%ebp)
80102689:	ff 75 08             	push   0x8(%ebp)
8010268c:	e8 2a 00 00 00       	call   801026bb <freerange>
80102691:	83 c4 10             	add    $0x10,%esp
}
80102694:	90                   	nop
80102695:	c9                   	leave  
80102696:	c3                   	ret    

80102697 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102697:	55                   	push   %ebp
80102698:	89 e5                	mov    %esp,%ebp
8010269a:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
8010269d:	83 ec 08             	sub    $0x8,%esp
801026a0:	ff 75 0c             	push   0xc(%ebp)
801026a3:	ff 75 08             	push   0x8(%ebp)
801026a6:	e8 10 00 00 00       	call   801026bb <freerange>
801026ab:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
801026ae:	c7 05 f4 40 19 80 01 	movl   $0x1,0x801940f4
801026b5:	00 00 00 
}
801026b8:	90                   	nop
801026b9:	c9                   	leave  
801026ba:	c3                   	ret    

801026bb <freerange>:

void
freerange(void *vstart, void *vend)
{
801026bb:	55                   	push   %ebp
801026bc:	89 e5                	mov    %esp,%ebp
801026be:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801026c1:	8b 45 08             	mov    0x8(%ebp),%eax
801026c4:	05 ff 0f 00 00       	add    $0xfff,%eax
801026c9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801026ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026d1:	eb 15                	jmp    801026e8 <freerange+0x2d>
    kfree(p);
801026d3:	83 ec 0c             	sub    $0xc,%esp
801026d6:	ff 75 f4             	push   -0xc(%ebp)
801026d9:	e8 1b 00 00 00       	call   801026f9 <kfree>
801026de:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026e1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801026e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026eb:	05 00 10 00 00       	add    $0x1000,%eax
801026f0:	39 45 0c             	cmp    %eax,0xc(%ebp)
801026f3:	73 de                	jae    801026d3 <freerange+0x18>
}
801026f5:	90                   	nop
801026f6:	90                   	nop
801026f7:	c9                   	leave  
801026f8:	c3                   	ret    

801026f9 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
801026f9:	55                   	push   %ebp
801026fa:	89 e5                	mov    %esp,%ebp
801026fc:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
801026ff:	8b 45 08             	mov    0x8(%ebp),%eax
80102702:	25 ff 0f 00 00       	and    $0xfff,%eax
80102707:	85 c0                	test   %eax,%eax
80102709:	75 18                	jne    80102723 <kfree+0x2a>
8010270b:	81 7d 08 00 80 19 80 	cmpl   $0x80198000,0x8(%ebp)
80102712:	72 0f                	jb     80102723 <kfree+0x2a>
80102714:	8b 45 08             	mov    0x8(%ebp),%eax
80102717:	05 00 00 00 80       	add    $0x80000000,%eax
8010271c:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
80102721:	76 0d                	jbe    80102730 <kfree+0x37>
    panic("kfree");
80102723:	83 ec 0c             	sub    $0xc,%esp
80102726:	68 37 a3 10 80       	push   $0x8010a337
8010272b:	e8 79 de ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102730:	83 ec 04             	sub    $0x4,%esp
80102733:	68 00 10 00 00       	push   $0x1000
80102738:	6a 01                	push   $0x1
8010273a:	ff 75 08             	push   0x8(%ebp)
8010273d:	e8 93 23 00 00       	call   80104ad5 <memset>
80102742:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102745:	a1 f4 40 19 80       	mov    0x801940f4,%eax
8010274a:	85 c0                	test   %eax,%eax
8010274c:	74 10                	je     8010275e <kfree+0x65>
    acquire(&kmem.lock);
8010274e:	83 ec 0c             	sub    $0xc,%esp
80102751:	68 c0 40 19 80       	push   $0x801940c0
80102756:	e8 04 21 00 00       	call   8010485f <acquire>
8010275b:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
8010275e:	8b 45 08             	mov    0x8(%ebp),%eax
80102761:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102764:	8b 15 f8 40 19 80    	mov    0x801940f8,%edx
8010276a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010276d:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
8010276f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102772:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
80102777:	a1 f4 40 19 80       	mov    0x801940f4,%eax
8010277c:	85 c0                	test   %eax,%eax
8010277e:	74 10                	je     80102790 <kfree+0x97>
    release(&kmem.lock);
80102780:	83 ec 0c             	sub    $0xc,%esp
80102783:	68 c0 40 19 80       	push   $0x801940c0
80102788:	e8 40 21 00 00       	call   801048cd <release>
8010278d:	83 c4 10             	add    $0x10,%esp
}
80102790:	90                   	nop
80102791:	c9                   	leave  
80102792:	c3                   	ret    

80102793 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102793:	55                   	push   %ebp
80102794:	89 e5                	mov    %esp,%ebp
80102796:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102799:	a1 f4 40 19 80       	mov    0x801940f4,%eax
8010279e:	85 c0                	test   %eax,%eax
801027a0:	74 10                	je     801027b2 <kalloc+0x1f>
    acquire(&kmem.lock);
801027a2:	83 ec 0c             	sub    $0xc,%esp
801027a5:	68 c0 40 19 80       	push   $0x801940c0
801027aa:	e8 b0 20 00 00       	call   8010485f <acquire>
801027af:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801027b2:	a1 f8 40 19 80       	mov    0x801940f8,%eax
801027b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801027ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027be:	74 0a                	je     801027ca <kalloc+0x37>
    kmem.freelist = r->next;
801027c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027c3:	8b 00                	mov    (%eax),%eax
801027c5:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
801027ca:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027cf:	85 c0                	test   %eax,%eax
801027d1:	74 10                	je     801027e3 <kalloc+0x50>
    release(&kmem.lock);
801027d3:	83 ec 0c             	sub    $0xc,%esp
801027d6:	68 c0 40 19 80       	push   $0x801940c0
801027db:	e8 ed 20 00 00       	call   801048cd <release>
801027e0:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801027e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801027e6:	c9                   	leave  
801027e7:	c3                   	ret    

801027e8 <inb>:
{
801027e8:	55                   	push   %ebp
801027e9:	89 e5                	mov    %esp,%ebp
801027eb:	83 ec 14             	sub    $0x14,%esp
801027ee:	8b 45 08             	mov    0x8(%ebp),%eax
801027f1:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801027f5:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801027f9:	89 c2                	mov    %eax,%edx
801027fb:	ec                   	in     (%dx),%al
801027fc:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801027ff:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102803:	c9                   	leave  
80102804:	c3                   	ret    

80102805 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102805:	55                   	push   %ebp
80102806:	89 e5                	mov    %esp,%ebp
80102808:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
8010280b:	6a 64                	push   $0x64
8010280d:	e8 d6 ff ff ff       	call   801027e8 <inb>
80102812:	83 c4 04             	add    $0x4,%esp
80102815:	0f b6 c0             	movzbl %al,%eax
80102818:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
8010281b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010281e:	83 e0 01             	and    $0x1,%eax
80102821:	85 c0                	test   %eax,%eax
80102823:	75 0a                	jne    8010282f <kbdgetc+0x2a>
    return -1;
80102825:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010282a:	e9 23 01 00 00       	jmp    80102952 <kbdgetc+0x14d>
  data = inb(KBDATAP);
8010282f:	6a 60                	push   $0x60
80102831:	e8 b2 ff ff ff       	call   801027e8 <inb>
80102836:	83 c4 04             	add    $0x4,%esp
80102839:	0f b6 c0             	movzbl %al,%eax
8010283c:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
8010283f:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102846:	75 17                	jne    8010285f <kbdgetc+0x5a>
    shift |= E0ESC;
80102848:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010284d:	83 c8 40             	or     $0x40,%eax
80102850:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
80102855:	b8 00 00 00 00       	mov    $0x0,%eax
8010285a:	e9 f3 00 00 00       	jmp    80102952 <kbdgetc+0x14d>
  } else if(data & 0x80){
8010285f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102862:	25 80 00 00 00       	and    $0x80,%eax
80102867:	85 c0                	test   %eax,%eax
80102869:	74 45                	je     801028b0 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
8010286b:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102870:	83 e0 40             	and    $0x40,%eax
80102873:	85 c0                	test   %eax,%eax
80102875:	75 08                	jne    8010287f <kbdgetc+0x7a>
80102877:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010287a:	83 e0 7f             	and    $0x7f,%eax
8010287d:	eb 03                	jmp    80102882 <kbdgetc+0x7d>
8010287f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102882:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102885:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102888:	05 20 d0 10 80       	add    $0x8010d020,%eax
8010288d:	0f b6 00             	movzbl (%eax),%eax
80102890:	83 c8 40             	or     $0x40,%eax
80102893:	0f b6 c0             	movzbl %al,%eax
80102896:	f7 d0                	not    %eax
80102898:	89 c2                	mov    %eax,%edx
8010289a:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010289f:	21 d0                	and    %edx,%eax
801028a1:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
801028a6:	b8 00 00 00 00       	mov    $0x0,%eax
801028ab:	e9 a2 00 00 00       	jmp    80102952 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
801028b0:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028b5:	83 e0 40             	and    $0x40,%eax
801028b8:	85 c0                	test   %eax,%eax
801028ba:	74 14                	je     801028d0 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801028bc:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801028c3:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028c8:	83 e0 bf             	and    $0xffffffbf,%eax
801028cb:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  }

  shift |= shiftcode[data];
801028d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028d3:	05 20 d0 10 80       	add    $0x8010d020,%eax
801028d8:	0f b6 00             	movzbl (%eax),%eax
801028db:	0f b6 d0             	movzbl %al,%edx
801028de:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028e3:	09 d0                	or     %edx,%eax
801028e5:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  shift ^= togglecode[data];
801028ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028ed:	05 20 d1 10 80       	add    $0x8010d120,%eax
801028f2:	0f b6 00             	movzbl (%eax),%eax
801028f5:	0f b6 d0             	movzbl %al,%edx
801028f8:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028fd:	31 d0                	xor    %edx,%eax
801028ff:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  c = charcode[shift & (CTL | SHIFT)][data];
80102904:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102909:	83 e0 03             	and    $0x3,%eax
8010290c:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102913:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102916:	01 d0                	add    %edx,%eax
80102918:	0f b6 00             	movzbl (%eax),%eax
8010291b:	0f b6 c0             	movzbl %al,%eax
8010291e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102921:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102926:	83 e0 08             	and    $0x8,%eax
80102929:	85 c0                	test   %eax,%eax
8010292b:	74 22                	je     8010294f <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
8010292d:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102931:	76 0c                	jbe    8010293f <kbdgetc+0x13a>
80102933:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102937:	77 06                	ja     8010293f <kbdgetc+0x13a>
      c += 'A' - 'a';
80102939:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
8010293d:	eb 10                	jmp    8010294f <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
8010293f:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102943:	76 0a                	jbe    8010294f <kbdgetc+0x14a>
80102945:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102949:	77 04                	ja     8010294f <kbdgetc+0x14a>
      c += 'a' - 'A';
8010294b:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
8010294f:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102952:	c9                   	leave  
80102953:	c3                   	ret    

80102954 <kbdintr>:

void
kbdintr(void)
{
80102954:	55                   	push   %ebp
80102955:	89 e5                	mov    %esp,%ebp
80102957:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
8010295a:	83 ec 0c             	sub    $0xc,%esp
8010295d:	68 05 28 10 80       	push   $0x80102805
80102962:	e8 6f de ff ff       	call   801007d6 <consoleintr>
80102967:	83 c4 10             	add    $0x10,%esp
}
8010296a:	90                   	nop
8010296b:	c9                   	leave  
8010296c:	c3                   	ret    

8010296d <inb>:
{
8010296d:	55                   	push   %ebp
8010296e:	89 e5                	mov    %esp,%ebp
80102970:	83 ec 14             	sub    $0x14,%esp
80102973:	8b 45 08             	mov    0x8(%ebp),%eax
80102976:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010297a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010297e:	89 c2                	mov    %eax,%edx
80102980:	ec                   	in     (%dx),%al
80102981:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102984:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102988:	c9                   	leave  
80102989:	c3                   	ret    

8010298a <outb>:
{
8010298a:	55                   	push   %ebp
8010298b:	89 e5                	mov    %esp,%ebp
8010298d:	83 ec 08             	sub    $0x8,%esp
80102990:	8b 45 08             	mov    0x8(%ebp),%eax
80102993:	8b 55 0c             	mov    0xc(%ebp),%edx
80102996:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010299a:	89 d0                	mov    %edx,%eax
8010299c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010299f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801029a3:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801029a7:	ee                   	out    %al,(%dx)
}
801029a8:	90                   	nop
801029a9:	c9                   	leave  
801029aa:	c3                   	ret    

801029ab <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
801029ab:	55                   	push   %ebp
801029ac:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801029ae:	8b 15 00 41 19 80    	mov    0x80194100,%edx
801029b4:	8b 45 08             	mov    0x8(%ebp),%eax
801029b7:	c1 e0 02             	shl    $0x2,%eax
801029ba:	01 c2                	add    %eax,%edx
801029bc:	8b 45 0c             	mov    0xc(%ebp),%eax
801029bf:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801029c1:	a1 00 41 19 80       	mov    0x80194100,%eax
801029c6:	83 c0 20             	add    $0x20,%eax
801029c9:	8b 00                	mov    (%eax),%eax
}
801029cb:	90                   	nop
801029cc:	5d                   	pop    %ebp
801029cd:	c3                   	ret    

801029ce <lapicinit>:

void
lapicinit(void)
{
801029ce:	55                   	push   %ebp
801029cf:	89 e5                	mov    %esp,%ebp
  if(!lapic)
801029d1:	a1 00 41 19 80       	mov    0x80194100,%eax
801029d6:	85 c0                	test   %eax,%eax
801029d8:	0f 84 0c 01 00 00    	je     80102aea <lapicinit+0x11c>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801029de:	68 3f 01 00 00       	push   $0x13f
801029e3:	6a 3c                	push   $0x3c
801029e5:	e8 c1 ff ff ff       	call   801029ab <lapicw>
801029ea:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801029ed:	6a 0b                	push   $0xb
801029ef:	68 f8 00 00 00       	push   $0xf8
801029f4:	e8 b2 ff ff ff       	call   801029ab <lapicw>
801029f9:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801029fc:	68 20 00 02 00       	push   $0x20020
80102a01:	68 c8 00 00 00       	push   $0xc8
80102a06:	e8 a0 ff ff ff       	call   801029ab <lapicw>
80102a0b:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102a0e:	68 80 96 98 00       	push   $0x989680
80102a13:	68 e0 00 00 00       	push   $0xe0
80102a18:	e8 8e ff ff ff       	call   801029ab <lapicw>
80102a1d:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102a20:	68 00 00 01 00       	push   $0x10000
80102a25:	68 d4 00 00 00       	push   $0xd4
80102a2a:	e8 7c ff ff ff       	call   801029ab <lapicw>
80102a2f:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102a32:	68 00 00 01 00       	push   $0x10000
80102a37:	68 d8 00 00 00       	push   $0xd8
80102a3c:	e8 6a ff ff ff       	call   801029ab <lapicw>
80102a41:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102a44:	a1 00 41 19 80       	mov    0x80194100,%eax
80102a49:	83 c0 30             	add    $0x30,%eax
80102a4c:	8b 00                	mov    (%eax),%eax
80102a4e:	c1 e8 10             	shr    $0x10,%eax
80102a51:	25 fc 00 00 00       	and    $0xfc,%eax
80102a56:	85 c0                	test   %eax,%eax
80102a58:	74 12                	je     80102a6c <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
80102a5a:	68 00 00 01 00       	push   $0x10000
80102a5f:	68 d0 00 00 00       	push   $0xd0
80102a64:	e8 42 ff ff ff       	call   801029ab <lapicw>
80102a69:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102a6c:	6a 33                	push   $0x33
80102a6e:	68 dc 00 00 00       	push   $0xdc
80102a73:	e8 33 ff ff ff       	call   801029ab <lapicw>
80102a78:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102a7b:	6a 00                	push   $0x0
80102a7d:	68 a0 00 00 00       	push   $0xa0
80102a82:	e8 24 ff ff ff       	call   801029ab <lapicw>
80102a87:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102a8a:	6a 00                	push   $0x0
80102a8c:	68 a0 00 00 00       	push   $0xa0
80102a91:	e8 15 ff ff ff       	call   801029ab <lapicw>
80102a96:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102a99:	6a 00                	push   $0x0
80102a9b:	6a 2c                	push   $0x2c
80102a9d:	e8 09 ff ff ff       	call   801029ab <lapicw>
80102aa2:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102aa5:	6a 00                	push   $0x0
80102aa7:	68 c4 00 00 00       	push   $0xc4
80102aac:	e8 fa fe ff ff       	call   801029ab <lapicw>
80102ab1:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102ab4:	68 00 85 08 00       	push   $0x88500
80102ab9:	68 c0 00 00 00       	push   $0xc0
80102abe:	e8 e8 fe ff ff       	call   801029ab <lapicw>
80102ac3:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102ac6:	90                   	nop
80102ac7:	a1 00 41 19 80       	mov    0x80194100,%eax
80102acc:	05 00 03 00 00       	add    $0x300,%eax
80102ad1:	8b 00                	mov    (%eax),%eax
80102ad3:	25 00 10 00 00       	and    $0x1000,%eax
80102ad8:	85 c0                	test   %eax,%eax
80102ada:	75 eb                	jne    80102ac7 <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102adc:	6a 00                	push   $0x0
80102ade:	6a 20                	push   $0x20
80102ae0:	e8 c6 fe ff ff       	call   801029ab <lapicw>
80102ae5:	83 c4 08             	add    $0x8,%esp
80102ae8:	eb 01                	jmp    80102aeb <lapicinit+0x11d>
    return;
80102aea:	90                   	nop
}
80102aeb:	c9                   	leave  
80102aec:	c3                   	ret    

80102aed <lapicid>:

int
lapicid(void)
{
80102aed:	55                   	push   %ebp
80102aee:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102af0:	a1 00 41 19 80       	mov    0x80194100,%eax
80102af5:	85 c0                	test   %eax,%eax
80102af7:	75 07                	jne    80102b00 <lapicid+0x13>
    return 0;
80102af9:	b8 00 00 00 00       	mov    $0x0,%eax
80102afe:	eb 0d                	jmp    80102b0d <lapicid+0x20>
  }
  return lapic[ID] >> 24;
80102b00:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b05:	83 c0 20             	add    $0x20,%eax
80102b08:	8b 00                	mov    (%eax),%eax
80102b0a:	c1 e8 18             	shr    $0x18,%eax
}
80102b0d:	5d                   	pop    %ebp
80102b0e:	c3                   	ret    

80102b0f <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102b0f:	55                   	push   %ebp
80102b10:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102b12:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b17:	85 c0                	test   %eax,%eax
80102b19:	74 0c                	je     80102b27 <lapiceoi+0x18>
    lapicw(EOI, 0);
80102b1b:	6a 00                	push   $0x0
80102b1d:	6a 2c                	push   $0x2c
80102b1f:	e8 87 fe ff ff       	call   801029ab <lapicw>
80102b24:	83 c4 08             	add    $0x8,%esp
}
80102b27:	90                   	nop
80102b28:	c9                   	leave  
80102b29:	c3                   	ret    

80102b2a <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102b2a:	55                   	push   %ebp
80102b2b:	89 e5                	mov    %esp,%ebp
}
80102b2d:	90                   	nop
80102b2e:	5d                   	pop    %ebp
80102b2f:	c3                   	ret    

80102b30 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102b30:	55                   	push   %ebp
80102b31:	89 e5                	mov    %esp,%ebp
80102b33:	83 ec 14             	sub    $0x14,%esp
80102b36:	8b 45 08             	mov    0x8(%ebp),%eax
80102b39:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102b3c:	6a 0f                	push   $0xf
80102b3e:	6a 70                	push   $0x70
80102b40:	e8 45 fe ff ff       	call   8010298a <outb>
80102b45:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102b48:	6a 0a                	push   $0xa
80102b4a:	6a 71                	push   $0x71
80102b4c:	e8 39 fe ff ff       	call   8010298a <outb>
80102b51:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102b54:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102b5b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b5e:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102b63:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b66:	c1 e8 04             	shr    $0x4,%eax
80102b69:	89 c2                	mov    %eax,%edx
80102b6b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b6e:	83 c0 02             	add    $0x2,%eax
80102b71:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102b74:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102b78:	c1 e0 18             	shl    $0x18,%eax
80102b7b:	50                   	push   %eax
80102b7c:	68 c4 00 00 00       	push   $0xc4
80102b81:	e8 25 fe ff ff       	call   801029ab <lapicw>
80102b86:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102b89:	68 00 c5 00 00       	push   $0xc500
80102b8e:	68 c0 00 00 00       	push   $0xc0
80102b93:	e8 13 fe ff ff       	call   801029ab <lapicw>
80102b98:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102b9b:	68 c8 00 00 00       	push   $0xc8
80102ba0:	e8 85 ff ff ff       	call   80102b2a <microdelay>
80102ba5:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102ba8:	68 00 85 00 00       	push   $0x8500
80102bad:	68 c0 00 00 00       	push   $0xc0
80102bb2:	e8 f4 fd ff ff       	call   801029ab <lapicw>
80102bb7:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102bba:	6a 64                	push   $0x64
80102bbc:	e8 69 ff ff ff       	call   80102b2a <microdelay>
80102bc1:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102bc4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102bcb:	eb 3d                	jmp    80102c0a <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
80102bcd:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102bd1:	c1 e0 18             	shl    $0x18,%eax
80102bd4:	50                   	push   %eax
80102bd5:	68 c4 00 00 00       	push   $0xc4
80102bda:	e8 cc fd ff ff       	call   801029ab <lapicw>
80102bdf:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102be2:	8b 45 0c             	mov    0xc(%ebp),%eax
80102be5:	c1 e8 0c             	shr    $0xc,%eax
80102be8:	80 cc 06             	or     $0x6,%ah
80102beb:	50                   	push   %eax
80102bec:	68 c0 00 00 00       	push   $0xc0
80102bf1:	e8 b5 fd ff ff       	call   801029ab <lapicw>
80102bf6:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102bf9:	68 c8 00 00 00       	push   $0xc8
80102bfe:	e8 27 ff ff ff       	call   80102b2a <microdelay>
80102c03:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102c06:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102c0a:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102c0e:	7e bd                	jle    80102bcd <lapicstartap+0x9d>
  }
}
80102c10:	90                   	nop
80102c11:	90                   	nop
80102c12:	c9                   	leave  
80102c13:	c3                   	ret    

80102c14 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102c14:	55                   	push   %ebp
80102c15:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102c17:	8b 45 08             	mov    0x8(%ebp),%eax
80102c1a:	0f b6 c0             	movzbl %al,%eax
80102c1d:	50                   	push   %eax
80102c1e:	6a 70                	push   $0x70
80102c20:	e8 65 fd ff ff       	call   8010298a <outb>
80102c25:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102c28:	68 c8 00 00 00       	push   $0xc8
80102c2d:	e8 f8 fe ff ff       	call   80102b2a <microdelay>
80102c32:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102c35:	6a 71                	push   $0x71
80102c37:	e8 31 fd ff ff       	call   8010296d <inb>
80102c3c:	83 c4 04             	add    $0x4,%esp
80102c3f:	0f b6 c0             	movzbl %al,%eax
}
80102c42:	c9                   	leave  
80102c43:	c3                   	ret    

80102c44 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102c44:	55                   	push   %ebp
80102c45:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102c47:	6a 00                	push   $0x0
80102c49:	e8 c6 ff ff ff       	call   80102c14 <cmos_read>
80102c4e:	83 c4 04             	add    $0x4,%esp
80102c51:	8b 55 08             	mov    0x8(%ebp),%edx
80102c54:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102c56:	6a 02                	push   $0x2
80102c58:	e8 b7 ff ff ff       	call   80102c14 <cmos_read>
80102c5d:	83 c4 04             	add    $0x4,%esp
80102c60:	8b 55 08             	mov    0x8(%ebp),%edx
80102c63:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102c66:	6a 04                	push   $0x4
80102c68:	e8 a7 ff ff ff       	call   80102c14 <cmos_read>
80102c6d:	83 c4 04             	add    $0x4,%esp
80102c70:	8b 55 08             	mov    0x8(%ebp),%edx
80102c73:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102c76:	6a 07                	push   $0x7
80102c78:	e8 97 ff ff ff       	call   80102c14 <cmos_read>
80102c7d:	83 c4 04             	add    $0x4,%esp
80102c80:	8b 55 08             	mov    0x8(%ebp),%edx
80102c83:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102c86:	6a 08                	push   $0x8
80102c88:	e8 87 ff ff ff       	call   80102c14 <cmos_read>
80102c8d:	83 c4 04             	add    $0x4,%esp
80102c90:	8b 55 08             	mov    0x8(%ebp),%edx
80102c93:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102c96:	6a 09                	push   $0x9
80102c98:	e8 77 ff ff ff       	call   80102c14 <cmos_read>
80102c9d:	83 c4 04             	add    $0x4,%esp
80102ca0:	8b 55 08             	mov    0x8(%ebp),%edx
80102ca3:	89 42 14             	mov    %eax,0x14(%edx)
}
80102ca6:	90                   	nop
80102ca7:	c9                   	leave  
80102ca8:	c3                   	ret    

80102ca9 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102ca9:	55                   	push   %ebp
80102caa:	89 e5                	mov    %esp,%ebp
80102cac:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102caf:	6a 0b                	push   $0xb
80102cb1:	e8 5e ff ff ff       	call   80102c14 <cmos_read>
80102cb6:	83 c4 04             	add    $0x4,%esp
80102cb9:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102cbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cbf:	83 e0 04             	and    $0x4,%eax
80102cc2:	85 c0                	test   %eax,%eax
80102cc4:	0f 94 c0             	sete   %al
80102cc7:	0f b6 c0             	movzbl %al,%eax
80102cca:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102ccd:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102cd0:	50                   	push   %eax
80102cd1:	e8 6e ff ff ff       	call   80102c44 <fill_rtcdate>
80102cd6:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102cd9:	6a 0a                	push   $0xa
80102cdb:	e8 34 ff ff ff       	call   80102c14 <cmos_read>
80102ce0:	83 c4 04             	add    $0x4,%esp
80102ce3:	25 80 00 00 00       	and    $0x80,%eax
80102ce8:	85 c0                	test   %eax,%eax
80102cea:	75 27                	jne    80102d13 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80102cec:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102cef:	50                   	push   %eax
80102cf0:	e8 4f ff ff ff       	call   80102c44 <fill_rtcdate>
80102cf5:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102cf8:	83 ec 04             	sub    $0x4,%esp
80102cfb:	6a 18                	push   $0x18
80102cfd:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102d00:	50                   	push   %eax
80102d01:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102d04:	50                   	push   %eax
80102d05:	e8 32 1e 00 00       	call   80104b3c <memcmp>
80102d0a:	83 c4 10             	add    $0x10,%esp
80102d0d:	85 c0                	test   %eax,%eax
80102d0f:	74 05                	je     80102d16 <cmostime+0x6d>
80102d11:	eb ba                	jmp    80102ccd <cmostime+0x24>
        continue;
80102d13:	90                   	nop
    fill_rtcdate(&t1);
80102d14:	eb b7                	jmp    80102ccd <cmostime+0x24>
      break;
80102d16:	90                   	nop
  }

  // convert
  if(bcd) {
80102d17:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102d1b:	0f 84 b4 00 00 00    	je     80102dd5 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102d21:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d24:	c1 e8 04             	shr    $0x4,%eax
80102d27:	89 c2                	mov    %eax,%edx
80102d29:	89 d0                	mov    %edx,%eax
80102d2b:	c1 e0 02             	shl    $0x2,%eax
80102d2e:	01 d0                	add    %edx,%eax
80102d30:	01 c0                	add    %eax,%eax
80102d32:	89 c2                	mov    %eax,%edx
80102d34:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d37:	83 e0 0f             	and    $0xf,%eax
80102d3a:	01 d0                	add    %edx,%eax
80102d3c:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102d3f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d42:	c1 e8 04             	shr    $0x4,%eax
80102d45:	89 c2                	mov    %eax,%edx
80102d47:	89 d0                	mov    %edx,%eax
80102d49:	c1 e0 02             	shl    $0x2,%eax
80102d4c:	01 d0                	add    %edx,%eax
80102d4e:	01 c0                	add    %eax,%eax
80102d50:	89 c2                	mov    %eax,%edx
80102d52:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d55:	83 e0 0f             	and    $0xf,%eax
80102d58:	01 d0                	add    %edx,%eax
80102d5a:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102d5d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d60:	c1 e8 04             	shr    $0x4,%eax
80102d63:	89 c2                	mov    %eax,%edx
80102d65:	89 d0                	mov    %edx,%eax
80102d67:	c1 e0 02             	shl    $0x2,%eax
80102d6a:	01 d0                	add    %edx,%eax
80102d6c:	01 c0                	add    %eax,%eax
80102d6e:	89 c2                	mov    %eax,%edx
80102d70:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d73:	83 e0 0f             	and    $0xf,%eax
80102d76:	01 d0                	add    %edx,%eax
80102d78:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102d7b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d7e:	c1 e8 04             	shr    $0x4,%eax
80102d81:	89 c2                	mov    %eax,%edx
80102d83:	89 d0                	mov    %edx,%eax
80102d85:	c1 e0 02             	shl    $0x2,%eax
80102d88:	01 d0                	add    %edx,%eax
80102d8a:	01 c0                	add    %eax,%eax
80102d8c:	89 c2                	mov    %eax,%edx
80102d8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d91:	83 e0 0f             	and    $0xf,%eax
80102d94:	01 d0                	add    %edx,%eax
80102d96:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102d99:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102d9c:	c1 e8 04             	shr    $0x4,%eax
80102d9f:	89 c2                	mov    %eax,%edx
80102da1:	89 d0                	mov    %edx,%eax
80102da3:	c1 e0 02             	shl    $0x2,%eax
80102da6:	01 d0                	add    %edx,%eax
80102da8:	01 c0                	add    %eax,%eax
80102daa:	89 c2                	mov    %eax,%edx
80102dac:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102daf:	83 e0 0f             	and    $0xf,%eax
80102db2:	01 d0                	add    %edx,%eax
80102db4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102db7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dba:	c1 e8 04             	shr    $0x4,%eax
80102dbd:	89 c2                	mov    %eax,%edx
80102dbf:	89 d0                	mov    %edx,%eax
80102dc1:	c1 e0 02             	shl    $0x2,%eax
80102dc4:	01 d0                	add    %edx,%eax
80102dc6:	01 c0                	add    %eax,%eax
80102dc8:	89 c2                	mov    %eax,%edx
80102dca:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dcd:	83 e0 0f             	and    $0xf,%eax
80102dd0:	01 d0                	add    %edx,%eax
80102dd2:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102dd5:	8b 45 08             	mov    0x8(%ebp),%eax
80102dd8:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102ddb:	89 10                	mov    %edx,(%eax)
80102ddd:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102de0:	89 50 04             	mov    %edx,0x4(%eax)
80102de3:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102de6:	89 50 08             	mov    %edx,0x8(%eax)
80102de9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102dec:	89 50 0c             	mov    %edx,0xc(%eax)
80102def:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102df2:	89 50 10             	mov    %edx,0x10(%eax)
80102df5:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102df8:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102dfb:	8b 45 08             	mov    0x8(%ebp),%eax
80102dfe:	8b 40 14             	mov    0x14(%eax),%eax
80102e01:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102e07:	8b 45 08             	mov    0x8(%ebp),%eax
80102e0a:	89 50 14             	mov    %edx,0x14(%eax)
}
80102e0d:	90                   	nop
80102e0e:	c9                   	leave  
80102e0f:	c3                   	ret    

80102e10 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102e10:	55                   	push   %ebp
80102e11:	89 e5                	mov    %esp,%ebp
80102e13:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102e16:	83 ec 08             	sub    $0x8,%esp
80102e19:	68 3d a3 10 80       	push   $0x8010a33d
80102e1e:	68 20 41 19 80       	push   $0x80194120
80102e23:	e8 15 1a 00 00       	call   8010483d <initlock>
80102e28:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80102e2b:	83 ec 08             	sub    $0x8,%esp
80102e2e:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102e31:	50                   	push   %eax
80102e32:	ff 75 08             	push   0x8(%ebp)
80102e35:	e8 87 e5 ff ff       	call   801013c1 <readsb>
80102e3a:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80102e3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102e40:	a3 54 41 19 80       	mov    %eax,0x80194154
  log.size = sb.nlog;
80102e45:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102e48:	a3 58 41 19 80       	mov    %eax,0x80194158
  log.dev = dev;
80102e4d:	8b 45 08             	mov    0x8(%ebp),%eax
80102e50:	a3 64 41 19 80       	mov    %eax,0x80194164
  recover_from_log();
80102e55:	e8 b3 01 00 00       	call   8010300d <recover_from_log>
}
80102e5a:	90                   	nop
80102e5b:	c9                   	leave  
80102e5c:	c3                   	ret    

80102e5d <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102e5d:	55                   	push   %ebp
80102e5e:	89 e5                	mov    %esp,%ebp
80102e60:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102e63:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e6a:	e9 95 00 00 00       	jmp    80102f04 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102e6f:	8b 15 54 41 19 80    	mov    0x80194154,%edx
80102e75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e78:	01 d0                	add    %edx,%eax
80102e7a:	83 c0 01             	add    $0x1,%eax
80102e7d:	89 c2                	mov    %eax,%edx
80102e7f:	a1 64 41 19 80       	mov    0x80194164,%eax
80102e84:	83 ec 08             	sub    $0x8,%esp
80102e87:	52                   	push   %edx
80102e88:	50                   	push   %eax
80102e89:	e8 73 d3 ff ff       	call   80100201 <bread>
80102e8e:	83 c4 10             	add    $0x10,%esp
80102e91:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102e94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e97:	83 c0 10             	add    $0x10,%eax
80102e9a:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
80102ea1:	89 c2                	mov    %eax,%edx
80102ea3:	a1 64 41 19 80       	mov    0x80194164,%eax
80102ea8:	83 ec 08             	sub    $0x8,%esp
80102eab:	52                   	push   %edx
80102eac:	50                   	push   %eax
80102ead:	e8 4f d3 ff ff       	call   80100201 <bread>
80102eb2:	83 c4 10             	add    $0x10,%esp
80102eb5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102eb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ebb:	8d 50 5c             	lea    0x5c(%eax),%edx
80102ebe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ec1:	83 c0 5c             	add    $0x5c,%eax
80102ec4:	83 ec 04             	sub    $0x4,%esp
80102ec7:	68 00 02 00 00       	push   $0x200
80102ecc:	52                   	push   %edx
80102ecd:	50                   	push   %eax
80102ece:	e8 c1 1c 00 00       	call   80104b94 <memmove>
80102ed3:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80102ed6:	83 ec 0c             	sub    $0xc,%esp
80102ed9:	ff 75 ec             	push   -0x14(%ebp)
80102edc:	e8 59 d3 ff ff       	call   8010023a <bwrite>
80102ee1:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80102ee4:	83 ec 0c             	sub    $0xc,%esp
80102ee7:	ff 75 f0             	push   -0x10(%ebp)
80102eea:	e8 94 d3 ff ff       	call   80100283 <brelse>
80102eef:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80102ef2:	83 ec 0c             	sub    $0xc,%esp
80102ef5:	ff 75 ec             	push   -0x14(%ebp)
80102ef8:	e8 86 d3 ff ff       	call   80100283 <brelse>
80102efd:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80102f00:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f04:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f09:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f0c:	0f 8c 5d ff ff ff    	jl     80102e6f <install_trans+0x12>
  }
}
80102f12:	90                   	nop
80102f13:	90                   	nop
80102f14:	c9                   	leave  
80102f15:	c3                   	ret    

80102f16 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80102f16:	55                   	push   %ebp
80102f17:	89 e5                	mov    %esp,%ebp
80102f19:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f1c:	a1 54 41 19 80       	mov    0x80194154,%eax
80102f21:	89 c2                	mov    %eax,%edx
80102f23:	a1 64 41 19 80       	mov    0x80194164,%eax
80102f28:	83 ec 08             	sub    $0x8,%esp
80102f2b:	52                   	push   %edx
80102f2c:	50                   	push   %eax
80102f2d:	e8 cf d2 ff ff       	call   80100201 <bread>
80102f32:	83 c4 10             	add    $0x10,%esp
80102f35:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80102f38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f3b:	83 c0 5c             	add    $0x5c,%eax
80102f3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80102f41:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f44:	8b 00                	mov    (%eax),%eax
80102f46:	a3 68 41 19 80       	mov    %eax,0x80194168
  for (i = 0; i < log.lh.n; i++) {
80102f4b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102f52:	eb 1b                	jmp    80102f6f <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80102f54:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f57:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f5a:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80102f5e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f61:	83 c2 10             	add    $0x10,%edx
80102f64:	89 04 95 2c 41 19 80 	mov    %eax,-0x7fe6bed4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102f6b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f6f:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f74:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f77:	7c db                	jl     80102f54 <read_head+0x3e>
  }
  brelse(buf);
80102f79:	83 ec 0c             	sub    $0xc,%esp
80102f7c:	ff 75 f0             	push   -0x10(%ebp)
80102f7f:	e8 ff d2 ff ff       	call   80100283 <brelse>
80102f84:	83 c4 10             	add    $0x10,%esp
}
80102f87:	90                   	nop
80102f88:	c9                   	leave  
80102f89:	c3                   	ret    

80102f8a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102f8a:	55                   	push   %ebp
80102f8b:	89 e5                	mov    %esp,%ebp
80102f8d:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f90:	a1 54 41 19 80       	mov    0x80194154,%eax
80102f95:	89 c2                	mov    %eax,%edx
80102f97:	a1 64 41 19 80       	mov    0x80194164,%eax
80102f9c:	83 ec 08             	sub    $0x8,%esp
80102f9f:	52                   	push   %edx
80102fa0:	50                   	push   %eax
80102fa1:	e8 5b d2 ff ff       	call   80100201 <bread>
80102fa6:	83 c4 10             	add    $0x10,%esp
80102fa9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80102fac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102faf:	83 c0 5c             	add    $0x5c,%eax
80102fb2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80102fb5:	8b 15 68 41 19 80    	mov    0x80194168,%edx
80102fbb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fbe:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102fc0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102fc7:	eb 1b                	jmp    80102fe4 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80102fc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fcc:	83 c0 10             	add    $0x10,%eax
80102fcf:	8b 0c 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%ecx
80102fd6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fd9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102fdc:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102fe0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102fe4:	a1 68 41 19 80       	mov    0x80194168,%eax
80102fe9:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102fec:	7c db                	jl     80102fc9 <write_head+0x3f>
  }
  bwrite(buf);
80102fee:	83 ec 0c             	sub    $0xc,%esp
80102ff1:	ff 75 f0             	push   -0x10(%ebp)
80102ff4:	e8 41 d2 ff ff       	call   8010023a <bwrite>
80102ff9:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80102ffc:	83 ec 0c             	sub    $0xc,%esp
80102fff:	ff 75 f0             	push   -0x10(%ebp)
80103002:	e8 7c d2 ff ff       	call   80100283 <brelse>
80103007:	83 c4 10             	add    $0x10,%esp
}
8010300a:	90                   	nop
8010300b:	c9                   	leave  
8010300c:	c3                   	ret    

8010300d <recover_from_log>:

static void
recover_from_log(void)
{
8010300d:	55                   	push   %ebp
8010300e:	89 e5                	mov    %esp,%ebp
80103010:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103013:	e8 fe fe ff ff       	call   80102f16 <read_head>
  install_trans(); // if committed, copy from log to disk
80103018:	e8 40 fe ff ff       	call   80102e5d <install_trans>
  log.lh.n = 0;
8010301d:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
80103024:	00 00 00 
  write_head(); // clear the log
80103027:	e8 5e ff ff ff       	call   80102f8a <write_head>
}
8010302c:	90                   	nop
8010302d:	c9                   	leave  
8010302e:	c3                   	ret    

8010302f <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010302f:	55                   	push   %ebp
80103030:	89 e5                	mov    %esp,%ebp
80103032:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103035:	83 ec 0c             	sub    $0xc,%esp
80103038:	68 20 41 19 80       	push   $0x80194120
8010303d:	e8 1d 18 00 00       	call   8010485f <acquire>
80103042:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103045:	a1 60 41 19 80       	mov    0x80194160,%eax
8010304a:	85 c0                	test   %eax,%eax
8010304c:	74 17                	je     80103065 <begin_op+0x36>
      sleep(&log, &log.lock);
8010304e:	83 ec 08             	sub    $0x8,%esp
80103051:	68 20 41 19 80       	push   $0x80194120
80103056:	68 20 41 19 80       	push   $0x80194120
8010305b:	e8 6c 12 00 00       	call   801042cc <sleep>
80103060:	83 c4 10             	add    $0x10,%esp
80103063:	eb e0                	jmp    80103045 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103065:	8b 0d 68 41 19 80    	mov    0x80194168,%ecx
8010306b:	a1 5c 41 19 80       	mov    0x8019415c,%eax
80103070:	8d 50 01             	lea    0x1(%eax),%edx
80103073:	89 d0                	mov    %edx,%eax
80103075:	c1 e0 02             	shl    $0x2,%eax
80103078:	01 d0                	add    %edx,%eax
8010307a:	01 c0                	add    %eax,%eax
8010307c:	01 c8                	add    %ecx,%eax
8010307e:	83 f8 1e             	cmp    $0x1e,%eax
80103081:	7e 17                	jle    8010309a <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103083:	83 ec 08             	sub    $0x8,%esp
80103086:	68 20 41 19 80       	push   $0x80194120
8010308b:	68 20 41 19 80       	push   $0x80194120
80103090:	e8 37 12 00 00       	call   801042cc <sleep>
80103095:	83 c4 10             	add    $0x10,%esp
80103098:	eb ab                	jmp    80103045 <begin_op+0x16>
    } else {
      log.outstanding += 1;
8010309a:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010309f:	83 c0 01             	add    $0x1,%eax
801030a2:	a3 5c 41 19 80       	mov    %eax,0x8019415c
      release(&log.lock);
801030a7:	83 ec 0c             	sub    $0xc,%esp
801030aa:	68 20 41 19 80       	push   $0x80194120
801030af:	e8 19 18 00 00       	call   801048cd <release>
801030b4:	83 c4 10             	add    $0x10,%esp
      break;
801030b7:	90                   	nop
    }
  }
}
801030b8:	90                   	nop
801030b9:	c9                   	leave  
801030ba:	c3                   	ret    

801030bb <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801030bb:	55                   	push   %ebp
801030bc:	89 e5                	mov    %esp,%ebp
801030be:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801030c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801030c8:	83 ec 0c             	sub    $0xc,%esp
801030cb:	68 20 41 19 80       	push   $0x80194120
801030d0:	e8 8a 17 00 00       	call   8010485f <acquire>
801030d5:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801030d8:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030dd:	83 e8 01             	sub    $0x1,%eax
801030e0:	a3 5c 41 19 80       	mov    %eax,0x8019415c
  if(log.committing)
801030e5:	a1 60 41 19 80       	mov    0x80194160,%eax
801030ea:	85 c0                	test   %eax,%eax
801030ec:	74 0d                	je     801030fb <end_op+0x40>
    panic("log.committing");
801030ee:	83 ec 0c             	sub    $0xc,%esp
801030f1:	68 41 a3 10 80       	push   $0x8010a341
801030f6:	e8 ae d4 ff ff       	call   801005a9 <panic>
  if(log.outstanding == 0){
801030fb:	a1 5c 41 19 80       	mov    0x8019415c,%eax
80103100:	85 c0                	test   %eax,%eax
80103102:	75 13                	jne    80103117 <end_op+0x5c>
    do_commit = 1;
80103104:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010310b:	c7 05 60 41 19 80 01 	movl   $0x1,0x80194160
80103112:	00 00 00 
80103115:	eb 10                	jmp    80103127 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103117:	83 ec 0c             	sub    $0xc,%esp
8010311a:	68 20 41 19 80       	push   $0x80194120
8010311f:	e8 8f 12 00 00       	call   801043b3 <wakeup>
80103124:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103127:	83 ec 0c             	sub    $0xc,%esp
8010312a:	68 20 41 19 80       	push   $0x80194120
8010312f:	e8 99 17 00 00       	call   801048cd <release>
80103134:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103137:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010313b:	74 3f                	je     8010317c <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010313d:	e8 f6 00 00 00       	call   80103238 <commit>
    acquire(&log.lock);
80103142:	83 ec 0c             	sub    $0xc,%esp
80103145:	68 20 41 19 80       	push   $0x80194120
8010314a:	e8 10 17 00 00       	call   8010485f <acquire>
8010314f:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103152:	c7 05 60 41 19 80 00 	movl   $0x0,0x80194160
80103159:	00 00 00 
    wakeup(&log);
8010315c:	83 ec 0c             	sub    $0xc,%esp
8010315f:	68 20 41 19 80       	push   $0x80194120
80103164:	e8 4a 12 00 00       	call   801043b3 <wakeup>
80103169:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010316c:	83 ec 0c             	sub    $0xc,%esp
8010316f:	68 20 41 19 80       	push   $0x80194120
80103174:	e8 54 17 00 00       	call   801048cd <release>
80103179:	83 c4 10             	add    $0x10,%esp
  }
}
8010317c:	90                   	nop
8010317d:	c9                   	leave  
8010317e:	c3                   	ret    

8010317f <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
8010317f:	55                   	push   %ebp
80103180:	89 e5                	mov    %esp,%ebp
80103182:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103185:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010318c:	e9 95 00 00 00       	jmp    80103226 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103191:	8b 15 54 41 19 80    	mov    0x80194154,%edx
80103197:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010319a:	01 d0                	add    %edx,%eax
8010319c:	83 c0 01             	add    $0x1,%eax
8010319f:	89 c2                	mov    %eax,%edx
801031a1:	a1 64 41 19 80       	mov    0x80194164,%eax
801031a6:	83 ec 08             	sub    $0x8,%esp
801031a9:	52                   	push   %edx
801031aa:	50                   	push   %eax
801031ab:	e8 51 d0 ff ff       	call   80100201 <bread>
801031b0:	83 c4 10             	add    $0x10,%esp
801031b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801031b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031b9:	83 c0 10             	add    $0x10,%eax
801031bc:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801031c3:	89 c2                	mov    %eax,%edx
801031c5:	a1 64 41 19 80       	mov    0x80194164,%eax
801031ca:	83 ec 08             	sub    $0x8,%esp
801031cd:	52                   	push   %edx
801031ce:	50                   	push   %eax
801031cf:	e8 2d d0 ff ff       	call   80100201 <bread>
801031d4:	83 c4 10             	add    $0x10,%esp
801031d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801031da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031dd:	8d 50 5c             	lea    0x5c(%eax),%edx
801031e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031e3:	83 c0 5c             	add    $0x5c,%eax
801031e6:	83 ec 04             	sub    $0x4,%esp
801031e9:	68 00 02 00 00       	push   $0x200
801031ee:	52                   	push   %edx
801031ef:	50                   	push   %eax
801031f0:	e8 9f 19 00 00       	call   80104b94 <memmove>
801031f5:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801031f8:	83 ec 0c             	sub    $0xc,%esp
801031fb:	ff 75 f0             	push   -0x10(%ebp)
801031fe:	e8 37 d0 ff ff       	call   8010023a <bwrite>
80103203:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103206:	83 ec 0c             	sub    $0xc,%esp
80103209:	ff 75 ec             	push   -0x14(%ebp)
8010320c:	e8 72 d0 ff ff       	call   80100283 <brelse>
80103211:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103214:	83 ec 0c             	sub    $0xc,%esp
80103217:	ff 75 f0             	push   -0x10(%ebp)
8010321a:	e8 64 d0 ff ff       	call   80100283 <brelse>
8010321f:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103222:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103226:	a1 68 41 19 80       	mov    0x80194168,%eax
8010322b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010322e:	0f 8c 5d ff ff ff    	jl     80103191 <write_log+0x12>
  }
}
80103234:	90                   	nop
80103235:	90                   	nop
80103236:	c9                   	leave  
80103237:	c3                   	ret    

80103238 <commit>:

static void
commit()
{
80103238:	55                   	push   %ebp
80103239:	89 e5                	mov    %esp,%ebp
8010323b:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010323e:	a1 68 41 19 80       	mov    0x80194168,%eax
80103243:	85 c0                	test   %eax,%eax
80103245:	7e 1e                	jle    80103265 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103247:	e8 33 ff ff ff       	call   8010317f <write_log>
    write_head();    // Write header to disk -- the real commit
8010324c:	e8 39 fd ff ff       	call   80102f8a <write_head>
    install_trans(); // Now install writes to home locations
80103251:	e8 07 fc ff ff       	call   80102e5d <install_trans>
    log.lh.n = 0;
80103256:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
8010325d:	00 00 00 
    write_head();    // Erase the transaction from the log
80103260:	e8 25 fd ff ff       	call   80102f8a <write_head>
  }
}
80103265:	90                   	nop
80103266:	c9                   	leave  
80103267:	c3                   	ret    

80103268 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103268:	55                   	push   %ebp
80103269:	89 e5                	mov    %esp,%ebp
8010326b:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010326e:	a1 68 41 19 80       	mov    0x80194168,%eax
80103273:	83 f8 1d             	cmp    $0x1d,%eax
80103276:	7f 12                	jg     8010328a <log_write+0x22>
80103278:	a1 68 41 19 80       	mov    0x80194168,%eax
8010327d:	8b 15 58 41 19 80    	mov    0x80194158,%edx
80103283:	83 ea 01             	sub    $0x1,%edx
80103286:	39 d0                	cmp    %edx,%eax
80103288:	7c 0d                	jl     80103297 <log_write+0x2f>
    panic("too big a transaction");
8010328a:	83 ec 0c             	sub    $0xc,%esp
8010328d:	68 50 a3 10 80       	push   $0x8010a350
80103292:	e8 12 d3 ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
80103297:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010329c:	85 c0                	test   %eax,%eax
8010329e:	7f 0d                	jg     801032ad <log_write+0x45>
    panic("log_write outside of trans");
801032a0:	83 ec 0c             	sub    $0xc,%esp
801032a3:	68 66 a3 10 80       	push   $0x8010a366
801032a8:	e8 fc d2 ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
801032ad:	83 ec 0c             	sub    $0xc,%esp
801032b0:	68 20 41 19 80       	push   $0x80194120
801032b5:	e8 a5 15 00 00       	call   8010485f <acquire>
801032ba:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801032bd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032c4:	eb 1d                	jmp    801032e3 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801032c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032c9:	83 c0 10             	add    $0x10,%eax
801032cc:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801032d3:	89 c2                	mov    %eax,%edx
801032d5:	8b 45 08             	mov    0x8(%ebp),%eax
801032d8:	8b 40 08             	mov    0x8(%eax),%eax
801032db:	39 c2                	cmp    %eax,%edx
801032dd:	74 10                	je     801032ef <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
801032df:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801032e3:	a1 68 41 19 80       	mov    0x80194168,%eax
801032e8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801032eb:	7c d9                	jl     801032c6 <log_write+0x5e>
801032ed:	eb 01                	jmp    801032f0 <log_write+0x88>
      break;
801032ef:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801032f0:	8b 45 08             	mov    0x8(%ebp),%eax
801032f3:	8b 40 08             	mov    0x8(%eax),%eax
801032f6:	89 c2                	mov    %eax,%edx
801032f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032fb:	83 c0 10             	add    $0x10,%eax
801032fe:	89 14 85 2c 41 19 80 	mov    %edx,-0x7fe6bed4(,%eax,4)
  if (i == log.lh.n)
80103305:	a1 68 41 19 80       	mov    0x80194168,%eax
8010330a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010330d:	75 0d                	jne    8010331c <log_write+0xb4>
    log.lh.n++;
8010330f:	a1 68 41 19 80       	mov    0x80194168,%eax
80103314:	83 c0 01             	add    $0x1,%eax
80103317:	a3 68 41 19 80       	mov    %eax,0x80194168
  b->flags |= B_DIRTY; // prevent eviction
8010331c:	8b 45 08             	mov    0x8(%ebp),%eax
8010331f:	8b 00                	mov    (%eax),%eax
80103321:	83 c8 04             	or     $0x4,%eax
80103324:	89 c2                	mov    %eax,%edx
80103326:	8b 45 08             	mov    0x8(%ebp),%eax
80103329:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
8010332b:	83 ec 0c             	sub    $0xc,%esp
8010332e:	68 20 41 19 80       	push   $0x80194120
80103333:	e8 95 15 00 00       	call   801048cd <release>
80103338:	83 c4 10             	add    $0x10,%esp
}
8010333b:	90                   	nop
8010333c:	c9                   	leave  
8010333d:	c3                   	ret    

8010333e <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010333e:	55                   	push   %ebp
8010333f:	89 e5                	mov    %esp,%ebp
80103341:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103344:	8b 55 08             	mov    0x8(%ebp),%edx
80103347:	8b 45 0c             	mov    0xc(%ebp),%eax
8010334a:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010334d:	f0 87 02             	lock xchg %eax,(%edx)
80103350:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103353:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103356:	c9                   	leave  
80103357:	c3                   	ret    

80103358 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103358:	8d 4c 24 04          	lea    0x4(%esp),%ecx
8010335c:	83 e4 f0             	and    $0xfffffff0,%esp
8010335f:	ff 71 fc             	push   -0x4(%ecx)
80103362:	55                   	push   %ebp
80103363:	89 e5                	mov    %esp,%ebp
80103365:	51                   	push   %ecx
80103366:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
80103369:	e8 40 4b 00 00       	call   80107eae <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010336e:	83 ec 08             	sub    $0x8,%esp
80103371:	68 00 00 40 80       	push   $0x80400000
80103376:	68 00 80 19 80       	push   $0x80198000
8010337b:	e8 de f2 ff ff       	call   8010265e <kinit1>
80103380:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103383:	e8 52 41 00 00       	call   801074da <kvmalloc>
  mpinit_uefi();
80103388:	e8 e7 48 00 00       	call   80107c74 <mpinit_uefi>
  lapicinit();     // interrupt controller
8010338d:	e8 3c f6 ff ff       	call   801029ce <lapicinit>
  seginit();       // segment descriptors
80103392:	e8 db 3b 00 00       	call   80106f72 <seginit>
  picinit();    // disable pic
80103397:	e8 9d 01 00 00       	call   80103539 <picinit>
  ioapicinit();    // another interrupt controller
8010339c:	e8 d8 f1 ff ff       	call   80102579 <ioapicinit>
  consoleinit();   // console hardware
801033a1:	e8 59 d7 ff ff       	call   80100aff <consoleinit>
  uartinit();      // serial port
801033a6:	e8 60 2f 00 00       	call   8010630b <uartinit>
  pinit();         // process table
801033ab:	e8 c2 05 00 00       	call   80103972 <pinit>
  tvinit();        // trap vectors
801033b0:	e8 27 2b 00 00       	call   80105edc <tvinit>
  binit();         // buffer cache
801033b5:	e8 ac cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033ba:	e8 f3 db ff ff       	call   80100fb2 <fileinit>
  ideinit();       // disk 
801033bf:	e8 2b 6c 00 00       	call   80109fef <ideinit>
  startothers();   // start other processors
801033c4:	e8 8a 00 00 00       	call   80103453 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033c9:	83 ec 08             	sub    $0x8,%esp
801033cc:	68 00 00 00 a0       	push   $0xa0000000
801033d1:	68 00 00 40 80       	push   $0x80400000
801033d6:	e8 bc f2 ff ff       	call   80102697 <kinit2>
801033db:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033de:	e8 24 4d 00 00       	call   80108107 <pci_init>
  arp_scan();
801033e3:	e8 5b 5a 00 00       	call   80108e43 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801033e8:	e8 63 07 00 00       	call   80103b50 <userinit>

  mpmain();        // finish this processor's setup
801033ed:	e8 1a 00 00 00       	call   8010340c <mpmain>

801033f2 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801033f2:	55                   	push   %ebp
801033f3:	89 e5                	mov    %esp,%ebp
801033f5:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801033f8:	e8 f5 40 00 00       	call   801074f2 <switchkvm>
  seginit();
801033fd:	e8 70 3b 00 00       	call   80106f72 <seginit>
  lapicinit();
80103402:	e8 c7 f5 ff ff       	call   801029ce <lapicinit>
  mpmain();
80103407:	e8 00 00 00 00       	call   8010340c <mpmain>

8010340c <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
8010340c:	55                   	push   %ebp
8010340d:	89 e5                	mov    %esp,%ebp
8010340f:	53                   	push   %ebx
80103410:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103413:	e8 78 05 00 00       	call   80103990 <cpuid>
80103418:	89 c3                	mov    %eax,%ebx
8010341a:	e8 71 05 00 00       	call   80103990 <cpuid>
8010341f:	83 ec 04             	sub    $0x4,%esp
80103422:	53                   	push   %ebx
80103423:	50                   	push   %eax
80103424:	68 81 a3 10 80       	push   $0x8010a381
80103429:	e8 c6 cf ff ff       	call   801003f4 <cprintf>
8010342e:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103431:	e8 1c 2c 00 00       	call   80106052 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103436:	e8 70 05 00 00       	call   801039ab <mycpu>
8010343b:	05 a0 00 00 00       	add    $0xa0,%eax
80103440:	83 ec 08             	sub    $0x8,%esp
80103443:	6a 01                	push   $0x1
80103445:	50                   	push   %eax
80103446:	e8 f3 fe ff ff       	call   8010333e <xchg>
8010344b:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010344e:	e8 88 0c 00 00       	call   801040db <scheduler>

80103453 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103453:	55                   	push   %ebp
80103454:	89 e5                	mov    %esp,%ebp
80103456:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103459:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103460:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103465:	83 ec 04             	sub    $0x4,%esp
80103468:	50                   	push   %eax
80103469:	68 18 f5 10 80       	push   $0x8010f518
8010346e:	ff 75 f0             	push   -0x10(%ebp)
80103471:	e8 1e 17 00 00       	call   80104b94 <memmove>
80103476:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103479:	c7 45 f4 80 69 19 80 	movl   $0x80196980,-0xc(%ebp)
80103480:	eb 79                	jmp    801034fb <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
80103482:	e8 24 05 00 00       	call   801039ab <mycpu>
80103487:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010348a:	74 67                	je     801034f3 <startothers+0xa0>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010348c:	e8 02 f3 ff ff       	call   80102793 <kalloc>
80103491:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103494:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103497:	83 e8 04             	sub    $0x4,%eax
8010349a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010349d:	81 c2 00 10 00 00    	add    $0x1000,%edx
801034a3:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801034a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034a8:	83 e8 08             	sub    $0x8,%eax
801034ab:	c7 00 f2 33 10 80    	movl   $0x801033f2,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801034b1:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
801034b6:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034bf:	83 e8 0c             	sub    $0xc,%eax
801034c2:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801034c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034c7:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034d0:	0f b6 00             	movzbl (%eax),%eax
801034d3:	0f b6 c0             	movzbl %al,%eax
801034d6:	83 ec 08             	sub    $0x8,%esp
801034d9:	52                   	push   %edx
801034da:	50                   	push   %eax
801034db:	e8 50 f6 ff ff       	call   80102b30 <lapicstartap>
801034e0:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801034e3:	90                   	nop
801034e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034e7:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801034ed:	85 c0                	test   %eax,%eax
801034ef:	74 f3                	je     801034e4 <startothers+0x91>
801034f1:	eb 01                	jmp    801034f4 <startothers+0xa1>
      continue;
801034f3:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
801034f4:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
801034fb:	a1 40 6c 19 80       	mov    0x80196c40,%eax
80103500:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103506:	05 80 69 19 80       	add    $0x80196980,%eax
8010350b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010350e:	0f 82 6e ff ff ff    	jb     80103482 <startothers+0x2f>
      ;
  }
}
80103514:	90                   	nop
80103515:	90                   	nop
80103516:	c9                   	leave  
80103517:	c3                   	ret    

80103518 <outb>:
{
80103518:	55                   	push   %ebp
80103519:	89 e5                	mov    %esp,%ebp
8010351b:	83 ec 08             	sub    $0x8,%esp
8010351e:	8b 45 08             	mov    0x8(%ebp),%eax
80103521:	8b 55 0c             	mov    0xc(%ebp),%edx
80103524:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103528:	89 d0                	mov    %edx,%eax
8010352a:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010352d:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103531:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103535:	ee                   	out    %al,(%dx)
}
80103536:	90                   	nop
80103537:	c9                   	leave  
80103538:	c3                   	ret    

80103539 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103539:	55                   	push   %ebp
8010353a:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
8010353c:	68 ff 00 00 00       	push   $0xff
80103541:	6a 21                	push   $0x21
80103543:	e8 d0 ff ff ff       	call   80103518 <outb>
80103548:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
8010354b:	68 ff 00 00 00       	push   $0xff
80103550:	68 a1 00 00 00       	push   $0xa1
80103555:	e8 be ff ff ff       	call   80103518 <outb>
8010355a:	83 c4 08             	add    $0x8,%esp
}
8010355d:	90                   	nop
8010355e:	c9                   	leave  
8010355f:	c3                   	ret    

80103560 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103560:	55                   	push   %ebp
80103561:	89 e5                	mov    %esp,%ebp
80103563:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103566:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
8010356d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103570:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103576:	8b 45 0c             	mov    0xc(%ebp),%eax
80103579:	8b 10                	mov    (%eax),%edx
8010357b:	8b 45 08             	mov    0x8(%ebp),%eax
8010357e:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103580:	e8 4b da ff ff       	call   80100fd0 <filealloc>
80103585:	8b 55 08             	mov    0x8(%ebp),%edx
80103588:	89 02                	mov    %eax,(%edx)
8010358a:	8b 45 08             	mov    0x8(%ebp),%eax
8010358d:	8b 00                	mov    (%eax),%eax
8010358f:	85 c0                	test   %eax,%eax
80103591:	0f 84 c8 00 00 00    	je     8010365f <pipealloc+0xff>
80103597:	e8 34 da ff ff       	call   80100fd0 <filealloc>
8010359c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010359f:	89 02                	mov    %eax,(%edx)
801035a1:	8b 45 0c             	mov    0xc(%ebp),%eax
801035a4:	8b 00                	mov    (%eax),%eax
801035a6:	85 c0                	test   %eax,%eax
801035a8:	0f 84 b1 00 00 00    	je     8010365f <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801035ae:	e8 e0 f1 ff ff       	call   80102793 <kalloc>
801035b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801035b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035ba:	0f 84 a2 00 00 00    	je     80103662 <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
801035c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035c3:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801035ca:	00 00 00 
  p->writeopen = 1;
801035cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035d0:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801035d7:	00 00 00 
  p->nwrite = 0;
801035da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035dd:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801035e4:	00 00 00 
  p->nread = 0;
801035e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035ea:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801035f1:	00 00 00 
  initlock(&p->lock, "pipe");
801035f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035f7:	83 ec 08             	sub    $0x8,%esp
801035fa:	68 95 a3 10 80       	push   $0x8010a395
801035ff:	50                   	push   %eax
80103600:	e8 38 12 00 00       	call   8010483d <initlock>
80103605:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103608:	8b 45 08             	mov    0x8(%ebp),%eax
8010360b:	8b 00                	mov    (%eax),%eax
8010360d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103613:	8b 45 08             	mov    0x8(%ebp),%eax
80103616:	8b 00                	mov    (%eax),%eax
80103618:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010361c:	8b 45 08             	mov    0x8(%ebp),%eax
8010361f:	8b 00                	mov    (%eax),%eax
80103621:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103625:	8b 45 08             	mov    0x8(%ebp),%eax
80103628:	8b 00                	mov    (%eax),%eax
8010362a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010362d:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103630:	8b 45 0c             	mov    0xc(%ebp),%eax
80103633:	8b 00                	mov    (%eax),%eax
80103635:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
8010363b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010363e:	8b 00                	mov    (%eax),%eax
80103640:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103644:	8b 45 0c             	mov    0xc(%ebp),%eax
80103647:	8b 00                	mov    (%eax),%eax
80103649:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010364d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103650:	8b 00                	mov    (%eax),%eax
80103652:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103655:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103658:	b8 00 00 00 00       	mov    $0x0,%eax
8010365d:	eb 51                	jmp    801036b0 <pipealloc+0x150>
    goto bad;
8010365f:	90                   	nop
80103660:	eb 01                	jmp    80103663 <pipealloc+0x103>
    goto bad;
80103662:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103663:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103667:	74 0e                	je     80103677 <pipealloc+0x117>
    kfree((char*)p);
80103669:	83 ec 0c             	sub    $0xc,%esp
8010366c:	ff 75 f4             	push   -0xc(%ebp)
8010366f:	e8 85 f0 ff ff       	call   801026f9 <kfree>
80103674:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103677:	8b 45 08             	mov    0x8(%ebp),%eax
8010367a:	8b 00                	mov    (%eax),%eax
8010367c:	85 c0                	test   %eax,%eax
8010367e:	74 11                	je     80103691 <pipealloc+0x131>
    fileclose(*f0);
80103680:	8b 45 08             	mov    0x8(%ebp),%eax
80103683:	8b 00                	mov    (%eax),%eax
80103685:	83 ec 0c             	sub    $0xc,%esp
80103688:	50                   	push   %eax
80103689:	e8 00 da ff ff       	call   8010108e <fileclose>
8010368e:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103691:	8b 45 0c             	mov    0xc(%ebp),%eax
80103694:	8b 00                	mov    (%eax),%eax
80103696:	85 c0                	test   %eax,%eax
80103698:	74 11                	je     801036ab <pipealloc+0x14b>
    fileclose(*f1);
8010369a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010369d:	8b 00                	mov    (%eax),%eax
8010369f:	83 ec 0c             	sub    $0xc,%esp
801036a2:	50                   	push   %eax
801036a3:	e8 e6 d9 ff ff       	call   8010108e <fileclose>
801036a8:	83 c4 10             	add    $0x10,%esp
  return -1;
801036ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801036b0:	c9                   	leave  
801036b1:	c3                   	ret    

801036b2 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801036b2:	55                   	push   %ebp
801036b3:	89 e5                	mov    %esp,%ebp
801036b5:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801036b8:	8b 45 08             	mov    0x8(%ebp),%eax
801036bb:	83 ec 0c             	sub    $0xc,%esp
801036be:	50                   	push   %eax
801036bf:	e8 9b 11 00 00       	call   8010485f <acquire>
801036c4:	83 c4 10             	add    $0x10,%esp
  if(writable){
801036c7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801036cb:	74 23                	je     801036f0 <pipeclose+0x3e>
    p->writeopen = 0;
801036cd:	8b 45 08             	mov    0x8(%ebp),%eax
801036d0:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801036d7:	00 00 00 
    wakeup(&p->nread);
801036da:	8b 45 08             	mov    0x8(%ebp),%eax
801036dd:	05 34 02 00 00       	add    $0x234,%eax
801036e2:	83 ec 0c             	sub    $0xc,%esp
801036e5:	50                   	push   %eax
801036e6:	e8 c8 0c 00 00       	call   801043b3 <wakeup>
801036eb:	83 c4 10             	add    $0x10,%esp
801036ee:	eb 21                	jmp    80103711 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801036f0:	8b 45 08             	mov    0x8(%ebp),%eax
801036f3:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801036fa:	00 00 00 
    wakeup(&p->nwrite);
801036fd:	8b 45 08             	mov    0x8(%ebp),%eax
80103700:	05 38 02 00 00       	add    $0x238,%eax
80103705:	83 ec 0c             	sub    $0xc,%esp
80103708:	50                   	push   %eax
80103709:	e8 a5 0c 00 00       	call   801043b3 <wakeup>
8010370e:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103711:	8b 45 08             	mov    0x8(%ebp),%eax
80103714:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010371a:	85 c0                	test   %eax,%eax
8010371c:	75 2c                	jne    8010374a <pipeclose+0x98>
8010371e:	8b 45 08             	mov    0x8(%ebp),%eax
80103721:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103727:	85 c0                	test   %eax,%eax
80103729:	75 1f                	jne    8010374a <pipeclose+0x98>
    release(&p->lock);
8010372b:	8b 45 08             	mov    0x8(%ebp),%eax
8010372e:	83 ec 0c             	sub    $0xc,%esp
80103731:	50                   	push   %eax
80103732:	e8 96 11 00 00       	call   801048cd <release>
80103737:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
8010373a:	83 ec 0c             	sub    $0xc,%esp
8010373d:	ff 75 08             	push   0x8(%ebp)
80103740:	e8 b4 ef ff ff       	call   801026f9 <kfree>
80103745:	83 c4 10             	add    $0x10,%esp
80103748:	eb 10                	jmp    8010375a <pipeclose+0xa8>
  } else
    release(&p->lock);
8010374a:	8b 45 08             	mov    0x8(%ebp),%eax
8010374d:	83 ec 0c             	sub    $0xc,%esp
80103750:	50                   	push   %eax
80103751:	e8 77 11 00 00       	call   801048cd <release>
80103756:	83 c4 10             	add    $0x10,%esp
}
80103759:	90                   	nop
8010375a:	90                   	nop
8010375b:	c9                   	leave  
8010375c:	c3                   	ret    

8010375d <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010375d:	55                   	push   %ebp
8010375e:	89 e5                	mov    %esp,%ebp
80103760:	53                   	push   %ebx
80103761:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103764:	8b 45 08             	mov    0x8(%ebp),%eax
80103767:	83 ec 0c             	sub    $0xc,%esp
8010376a:	50                   	push   %eax
8010376b:	e8 ef 10 00 00       	call   8010485f <acquire>
80103770:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103773:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010377a:	e9 ad 00 00 00       	jmp    8010382c <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
8010377f:	8b 45 08             	mov    0x8(%ebp),%eax
80103782:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103788:	85 c0                	test   %eax,%eax
8010378a:	74 0c                	je     80103798 <pipewrite+0x3b>
8010378c:	e8 92 02 00 00       	call   80103a23 <myproc>
80103791:	8b 40 24             	mov    0x24(%eax),%eax
80103794:	85 c0                	test   %eax,%eax
80103796:	74 19                	je     801037b1 <pipewrite+0x54>
        release(&p->lock);
80103798:	8b 45 08             	mov    0x8(%ebp),%eax
8010379b:	83 ec 0c             	sub    $0xc,%esp
8010379e:	50                   	push   %eax
8010379f:	e8 29 11 00 00       	call   801048cd <release>
801037a4:	83 c4 10             	add    $0x10,%esp
        return -1;
801037a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801037ac:	e9 a9 00 00 00       	jmp    8010385a <pipewrite+0xfd>
      }
      wakeup(&p->nread);
801037b1:	8b 45 08             	mov    0x8(%ebp),%eax
801037b4:	05 34 02 00 00       	add    $0x234,%eax
801037b9:	83 ec 0c             	sub    $0xc,%esp
801037bc:	50                   	push   %eax
801037bd:	e8 f1 0b 00 00       	call   801043b3 <wakeup>
801037c2:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037c5:	8b 45 08             	mov    0x8(%ebp),%eax
801037c8:	8b 55 08             	mov    0x8(%ebp),%edx
801037cb:	81 c2 38 02 00 00    	add    $0x238,%edx
801037d1:	83 ec 08             	sub    $0x8,%esp
801037d4:	50                   	push   %eax
801037d5:	52                   	push   %edx
801037d6:	e8 f1 0a 00 00       	call   801042cc <sleep>
801037db:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801037de:	8b 45 08             	mov    0x8(%ebp),%eax
801037e1:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801037e7:	8b 45 08             	mov    0x8(%ebp),%eax
801037ea:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801037f0:	05 00 02 00 00       	add    $0x200,%eax
801037f5:	39 c2                	cmp    %eax,%edx
801037f7:	74 86                	je     8010377f <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801037f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801037fc:	8b 45 0c             	mov    0xc(%ebp),%eax
801037ff:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80103802:	8b 45 08             	mov    0x8(%ebp),%eax
80103805:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010380b:	8d 48 01             	lea    0x1(%eax),%ecx
8010380e:	8b 55 08             	mov    0x8(%ebp),%edx
80103811:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103817:	25 ff 01 00 00       	and    $0x1ff,%eax
8010381c:	89 c1                	mov    %eax,%ecx
8010381e:	0f b6 13             	movzbl (%ebx),%edx
80103821:	8b 45 08             	mov    0x8(%ebp),%eax
80103824:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103828:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010382c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010382f:	3b 45 10             	cmp    0x10(%ebp),%eax
80103832:	7c aa                	jl     801037de <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103834:	8b 45 08             	mov    0x8(%ebp),%eax
80103837:	05 34 02 00 00       	add    $0x234,%eax
8010383c:	83 ec 0c             	sub    $0xc,%esp
8010383f:	50                   	push   %eax
80103840:	e8 6e 0b 00 00       	call   801043b3 <wakeup>
80103845:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103848:	8b 45 08             	mov    0x8(%ebp),%eax
8010384b:	83 ec 0c             	sub    $0xc,%esp
8010384e:	50                   	push   %eax
8010384f:	e8 79 10 00 00       	call   801048cd <release>
80103854:	83 c4 10             	add    $0x10,%esp
  return n;
80103857:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010385a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010385d:	c9                   	leave  
8010385e:	c3                   	ret    

8010385f <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010385f:	55                   	push   %ebp
80103860:	89 e5                	mov    %esp,%ebp
80103862:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103865:	8b 45 08             	mov    0x8(%ebp),%eax
80103868:	83 ec 0c             	sub    $0xc,%esp
8010386b:	50                   	push   %eax
8010386c:	e8 ee 0f 00 00       	call   8010485f <acquire>
80103871:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103874:	eb 3e                	jmp    801038b4 <piperead+0x55>
    if(myproc()->killed){
80103876:	e8 a8 01 00 00       	call   80103a23 <myproc>
8010387b:	8b 40 24             	mov    0x24(%eax),%eax
8010387e:	85 c0                	test   %eax,%eax
80103880:	74 19                	je     8010389b <piperead+0x3c>
      release(&p->lock);
80103882:	8b 45 08             	mov    0x8(%ebp),%eax
80103885:	83 ec 0c             	sub    $0xc,%esp
80103888:	50                   	push   %eax
80103889:	e8 3f 10 00 00       	call   801048cd <release>
8010388e:	83 c4 10             	add    $0x10,%esp
      return -1;
80103891:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103896:	e9 be 00 00 00       	jmp    80103959 <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010389b:	8b 45 08             	mov    0x8(%ebp),%eax
8010389e:	8b 55 08             	mov    0x8(%ebp),%edx
801038a1:	81 c2 34 02 00 00    	add    $0x234,%edx
801038a7:	83 ec 08             	sub    $0x8,%esp
801038aa:	50                   	push   %eax
801038ab:	52                   	push   %edx
801038ac:	e8 1b 0a 00 00       	call   801042cc <sleep>
801038b1:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801038b4:	8b 45 08             	mov    0x8(%ebp),%eax
801038b7:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038bd:	8b 45 08             	mov    0x8(%ebp),%eax
801038c0:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038c6:	39 c2                	cmp    %eax,%edx
801038c8:	75 0d                	jne    801038d7 <piperead+0x78>
801038ca:	8b 45 08             	mov    0x8(%ebp),%eax
801038cd:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801038d3:	85 c0                	test   %eax,%eax
801038d5:	75 9f                	jne    80103876 <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801038d7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038de:	eb 48                	jmp    80103928 <piperead+0xc9>
    if(p->nread == p->nwrite)
801038e0:	8b 45 08             	mov    0x8(%ebp),%eax
801038e3:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038e9:	8b 45 08             	mov    0x8(%ebp),%eax
801038ec:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038f2:	39 c2                	cmp    %eax,%edx
801038f4:	74 3c                	je     80103932 <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801038f6:	8b 45 08             	mov    0x8(%ebp),%eax
801038f9:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801038ff:	8d 48 01             	lea    0x1(%eax),%ecx
80103902:	8b 55 08             	mov    0x8(%ebp),%edx
80103905:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
8010390b:	25 ff 01 00 00       	and    $0x1ff,%eax
80103910:	89 c1                	mov    %eax,%ecx
80103912:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103915:	8b 45 0c             	mov    0xc(%ebp),%eax
80103918:	01 c2                	add    %eax,%edx
8010391a:	8b 45 08             	mov    0x8(%ebp),%eax
8010391d:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80103922:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103924:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103928:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010392b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010392e:	7c b0                	jl     801038e0 <piperead+0x81>
80103930:	eb 01                	jmp    80103933 <piperead+0xd4>
      break;
80103932:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103933:	8b 45 08             	mov    0x8(%ebp),%eax
80103936:	05 38 02 00 00       	add    $0x238,%eax
8010393b:	83 ec 0c             	sub    $0xc,%esp
8010393e:	50                   	push   %eax
8010393f:	e8 6f 0a 00 00       	call   801043b3 <wakeup>
80103944:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103947:	8b 45 08             	mov    0x8(%ebp),%eax
8010394a:	83 ec 0c             	sub    $0xc,%esp
8010394d:	50                   	push   %eax
8010394e:	e8 7a 0f 00 00       	call   801048cd <release>
80103953:	83 c4 10             	add    $0x10,%esp
  return i;
80103956:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103959:	c9                   	leave  
8010395a:	c3                   	ret    

8010395b <readeflags>:
{
8010395b:	55                   	push   %ebp
8010395c:	89 e5                	mov    %esp,%ebp
8010395e:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103961:	9c                   	pushf  
80103962:	58                   	pop    %eax
80103963:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103966:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103969:	c9                   	leave  
8010396a:	c3                   	ret    

8010396b <sti>:
{
8010396b:	55                   	push   %ebp
8010396c:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010396e:	fb                   	sti    
}
8010396f:	90                   	nop
80103970:	5d                   	pop    %ebp
80103971:	c3                   	ret    

80103972 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80103972:	55                   	push   %ebp
80103973:	89 e5                	mov    %esp,%ebp
80103975:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103978:	83 ec 08             	sub    $0x8,%esp
8010397b:	68 9c a3 10 80       	push   $0x8010a39c
80103980:	68 00 42 19 80       	push   $0x80194200
80103985:	e8 b3 0e 00 00       	call   8010483d <initlock>
8010398a:	83 c4 10             	add    $0x10,%esp
}
8010398d:	90                   	nop
8010398e:	c9                   	leave  
8010398f:	c3                   	ret    

80103990 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80103990:	55                   	push   %ebp
80103991:	89 e5                	mov    %esp,%ebp
80103993:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103996:	e8 10 00 00 00       	call   801039ab <mycpu>
8010399b:	2d 80 69 19 80       	sub    $0x80196980,%eax
801039a0:	c1 f8 04             	sar    $0x4,%eax
801039a3:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801039a9:	c9                   	leave  
801039aa:	c3                   	ret    

801039ab <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801039ab:	55                   	push   %ebp
801039ac:	89 e5                	mov    %esp,%ebp
801039ae:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
801039b1:	e8 a5 ff ff ff       	call   8010395b <readeflags>
801039b6:	25 00 02 00 00       	and    $0x200,%eax
801039bb:	85 c0                	test   %eax,%eax
801039bd:	74 0d                	je     801039cc <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
801039bf:	83 ec 0c             	sub    $0xc,%esp
801039c2:	68 a4 a3 10 80       	push   $0x8010a3a4
801039c7:	e8 dd cb ff ff       	call   801005a9 <panic>
  }

  apicid = lapicid();
801039cc:	e8 1c f1 ff ff       	call   80102aed <lapicid>
801039d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801039d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801039db:	eb 2d                	jmp    80103a0a <mycpu+0x5f>
    if (cpus[i].apicid == apicid){
801039dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039e0:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801039e6:	05 80 69 19 80       	add    $0x80196980,%eax
801039eb:	0f b6 00             	movzbl (%eax),%eax
801039ee:	0f b6 c0             	movzbl %al,%eax
801039f1:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801039f4:	75 10                	jne    80103a06 <mycpu+0x5b>
      return &cpus[i];
801039f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039f9:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801039ff:	05 80 69 19 80       	add    $0x80196980,%eax
80103a04:	eb 1b                	jmp    80103a21 <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103a06:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a0a:	a1 40 6c 19 80       	mov    0x80196c40,%eax
80103a0f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a12:	7c c9                	jl     801039dd <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103a14:	83 ec 0c             	sub    $0xc,%esp
80103a17:	68 ca a3 10 80       	push   $0x8010a3ca
80103a1c:	e8 88 cb ff ff       	call   801005a9 <panic>
}
80103a21:	c9                   	leave  
80103a22:	c3                   	ret    

80103a23 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103a23:	55                   	push   %ebp
80103a24:	89 e5                	mov    %esp,%ebp
80103a26:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103a29:	e8 9c 0f 00 00       	call   801049ca <pushcli>
  c = mycpu();
80103a2e:	e8 78 ff ff ff       	call   801039ab <mycpu>
80103a33:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a39:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a3f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103a42:	e8 d0 0f 00 00       	call   80104a17 <popcli>
  return p;
80103a47:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103a4a:	c9                   	leave  
80103a4b:	c3                   	ret    

80103a4c <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103a4c:	55                   	push   %ebp
80103a4d:	89 e5                	mov    %esp,%ebp
80103a4f:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103a52:	83 ec 0c             	sub    $0xc,%esp
80103a55:	68 00 42 19 80       	push   $0x80194200
80103a5a:	e8 00 0e 00 00       	call   8010485f <acquire>
80103a5f:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a62:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103a69:	eb 0e                	jmp    80103a79 <allocproc+0x2d>
    if(p->state == UNUSED){
80103a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a6e:	8b 40 0c             	mov    0xc(%eax),%eax
80103a71:	85 c0                	test   %eax,%eax
80103a73:	74 27                	je     80103a9c <allocproc+0x50>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a75:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80103a79:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
80103a80:	72 e9                	jb     80103a6b <allocproc+0x1f>
      goto found;
    }

  release(&ptable.lock);
80103a82:	83 ec 0c             	sub    $0xc,%esp
80103a85:	68 00 42 19 80       	push   $0x80194200
80103a8a:	e8 3e 0e 00 00       	call   801048cd <release>
80103a8f:	83 c4 10             	add    $0x10,%esp
  return 0;
80103a92:	b8 00 00 00 00       	mov    $0x0,%eax
80103a97:	e9 b2 00 00 00       	jmp    80103b4e <allocproc+0x102>
      goto found;
80103a9c:	90                   	nop

found:
  p->state = EMBRYO;
80103a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aa0:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103aa7:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103aac:	8d 50 01             	lea    0x1(%eax),%edx
80103aaf:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103ab5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ab8:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80103abb:	83 ec 0c             	sub    $0xc,%esp
80103abe:	68 00 42 19 80       	push   $0x80194200
80103ac3:	e8 05 0e 00 00       	call   801048cd <release>
80103ac8:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103acb:	e8 c3 ec ff ff       	call   80102793 <kalloc>
80103ad0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ad3:	89 42 08             	mov    %eax,0x8(%edx)
80103ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ad9:	8b 40 08             	mov    0x8(%eax),%eax
80103adc:	85 c0                	test   %eax,%eax
80103ade:	75 11                	jne    80103af1 <allocproc+0xa5>
    p->state = UNUSED;
80103ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103aea:	b8 00 00 00 00       	mov    $0x0,%eax
80103aef:	eb 5d                	jmp    80103b4e <allocproc+0x102>
  }
  sp = p->kstack + KSTACKSIZE;
80103af1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af4:	8b 40 08             	mov    0x8(%eax),%eax
80103af7:	05 00 10 00 00       	add    $0x1000,%eax
80103afc:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103aff:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103b03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b06:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b09:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103b0c:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103b10:	ba 96 5e 10 80       	mov    $0x80105e96,%edx
80103b15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b18:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103b1a:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80103b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b21:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b24:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103b27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b2a:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b2d:	83 ec 04             	sub    $0x4,%esp
80103b30:	6a 14                	push   $0x14
80103b32:	6a 00                	push   $0x0
80103b34:	50                   	push   %eax
80103b35:	e8 9b 0f 00 00       	call   80104ad5 <memset>
80103b3a:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103b3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b40:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b43:	ba 86 42 10 80       	mov    $0x80104286,%edx
80103b48:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103b4e:	c9                   	leave  
80103b4f:	c3                   	ret    

80103b50 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103b50:	55                   	push   %ebp
80103b51:	89 e5                	mov    %esp,%ebp
80103b53:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103b56:	e8 f1 fe ff ff       	call   80103a4c <allocproc>
80103b5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103b5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b61:	a3 34 61 19 80       	mov    %eax,0x80196134
  if((p->pgdir = setupkvm()) == 0){
80103b66:	e8 83 38 00 00       	call   801073ee <setupkvm>
80103b6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b6e:	89 42 04             	mov    %eax,0x4(%edx)
80103b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b74:	8b 40 04             	mov    0x4(%eax),%eax
80103b77:	85 c0                	test   %eax,%eax
80103b79:	75 0d                	jne    80103b88 <userinit+0x38>
    panic("userinit: out of memory?");
80103b7b:	83 ec 0c             	sub    $0xc,%esp
80103b7e:	68 da a3 10 80       	push   $0x8010a3da
80103b83:	e8 21 ca ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103b88:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b90:	8b 40 04             	mov    0x4(%eax),%eax
80103b93:	83 ec 04             	sub    $0x4,%esp
80103b96:	52                   	push   %edx
80103b97:	68 ec f4 10 80       	push   $0x8010f4ec
80103b9c:	50                   	push   %eax
80103b9d:	e8 08 3b 00 00       	call   801076aa <inituvm>
80103ba2:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba8:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb1:	8b 40 18             	mov    0x18(%eax),%eax
80103bb4:	83 ec 04             	sub    $0x4,%esp
80103bb7:	6a 4c                	push   $0x4c
80103bb9:	6a 00                	push   $0x0
80103bbb:	50                   	push   %eax
80103bbc:	e8 14 0f 00 00       	call   80104ad5 <memset>
80103bc1:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc7:	8b 40 18             	mov    0x18(%eax),%eax
80103bca:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd3:	8b 40 18             	mov    0x18(%eax),%eax
80103bd6:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103bdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bdf:	8b 50 18             	mov    0x18(%eax),%edx
80103be2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be5:	8b 40 18             	mov    0x18(%eax),%eax
80103be8:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103bec:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103bf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf3:	8b 50 18             	mov    0x18(%eax),%edx
80103bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf9:	8b 40 18             	mov    0x18(%eax),%eax
80103bfc:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c00:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103c04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c07:	8b 40 18             	mov    0x18(%eax),%eax
80103c0a:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c14:	8b 40 18             	mov    0x18(%eax),%eax
80103c17:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c21:	8b 40 18             	mov    0x18(%eax),%eax
80103c24:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c2e:	83 c0 6c             	add    $0x6c,%eax
80103c31:	83 ec 04             	sub    $0x4,%esp
80103c34:	6a 10                	push   $0x10
80103c36:	68 f3 a3 10 80       	push   $0x8010a3f3
80103c3b:	50                   	push   %eax
80103c3c:	e8 97 10 00 00       	call   80104cd8 <safestrcpy>
80103c41:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103c44:	83 ec 0c             	sub    $0xc,%esp
80103c47:	68 fc a3 10 80       	push   $0x8010a3fc
80103c4c:	e8 bf e8 ff ff       	call   80102510 <namei>
80103c51:	83 c4 10             	add    $0x10,%esp
80103c54:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c57:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103c5a:	83 ec 0c             	sub    $0xc,%esp
80103c5d:	68 00 42 19 80       	push   $0x80194200
80103c62:	e8 f8 0b 00 00       	call   8010485f <acquire>
80103c67:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c6d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103c74:	83 ec 0c             	sub    $0xc,%esp
80103c77:	68 00 42 19 80       	push   $0x80194200
80103c7c:	e8 4c 0c 00 00       	call   801048cd <release>
80103c81:	83 c4 10             	add    $0x10,%esp
}
80103c84:	90                   	nop
80103c85:	c9                   	leave  
80103c86:	c3                   	ret    

80103c87 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103c87:	55                   	push   %ebp
80103c88:	89 e5                	mov    %esp,%ebp
80103c8a:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103c8d:	e8 91 fd ff ff       	call   80103a23 <myproc>
80103c92:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103c95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c98:	8b 00                	mov    (%eax),%eax
80103c9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103c9d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103ca1:	7e 2e                	jle    80103cd1 <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103ca3:	8b 55 08             	mov    0x8(%ebp),%edx
80103ca6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ca9:	01 c2                	add    %eax,%edx
80103cab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cae:	8b 40 04             	mov    0x4(%eax),%eax
80103cb1:	83 ec 04             	sub    $0x4,%esp
80103cb4:	52                   	push   %edx
80103cb5:	ff 75 f4             	push   -0xc(%ebp)
80103cb8:	50                   	push   %eax
80103cb9:	e8 29 3b 00 00       	call   801077e7 <allocuvm>
80103cbe:	83 c4 10             	add    $0x10,%esp
80103cc1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cc4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103cc8:	75 3b                	jne    80103d05 <growproc+0x7e>
      return -1;
80103cca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ccf:	eb 4f                	jmp    80103d20 <growproc+0x99>
  } else if(n < 0){
80103cd1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103cd5:	79 2e                	jns    80103d05 <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103cd7:	8b 55 08             	mov    0x8(%ebp),%edx
80103cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cdd:	01 c2                	add    %eax,%edx
80103cdf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ce2:	8b 40 04             	mov    0x4(%eax),%eax
80103ce5:	83 ec 04             	sub    $0x4,%esp
80103ce8:	52                   	push   %edx
80103ce9:	ff 75 f4             	push   -0xc(%ebp)
80103cec:	50                   	push   %eax
80103ced:	e8 fc 3b 00 00       	call   801078ee <deallocuvm>
80103cf2:	83 c4 10             	add    $0x10,%esp
80103cf5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cf8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103cfc:	75 07                	jne    80103d05 <growproc+0x7e>
      return -1;
80103cfe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d03:	eb 1b                	jmp    80103d20 <growproc+0x99>
  }
  curproc->sz = sz;
80103d05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d08:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d0b:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103d0d:	83 ec 0c             	sub    $0xc,%esp
80103d10:	ff 75 f0             	push   -0x10(%ebp)
80103d13:	e8 f3 37 00 00       	call   8010750b <switchuvm>
80103d18:	83 c4 10             	add    $0x10,%esp
  return 0;
80103d1b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103d20:	c9                   	leave  
80103d21:	c3                   	ret    

80103d22 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103d22:	55                   	push   %ebp
80103d23:	89 e5                	mov    %esp,%ebp
80103d25:	57                   	push   %edi
80103d26:	56                   	push   %esi
80103d27:	53                   	push   %ebx
80103d28:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103d2b:	e8 f3 fc ff ff       	call   80103a23 <myproc>
80103d30:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103d33:	e8 14 fd ff ff       	call   80103a4c <allocproc>
80103d38:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103d3b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103d3f:	75 0a                	jne    80103d4b <fork+0x29>
    return -1;
80103d41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d46:	e9 48 01 00 00       	jmp    80103e93 <fork+0x171>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103d4b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d4e:	8b 10                	mov    (%eax),%edx
80103d50:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d53:	8b 40 04             	mov    0x4(%eax),%eax
80103d56:	83 ec 08             	sub    $0x8,%esp
80103d59:	52                   	push   %edx
80103d5a:	50                   	push   %eax
80103d5b:	e8 2c 3d 00 00       	call   80107a8c <copyuvm>
80103d60:	83 c4 10             	add    $0x10,%esp
80103d63:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103d66:	89 42 04             	mov    %eax,0x4(%edx)
80103d69:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d6c:	8b 40 04             	mov    0x4(%eax),%eax
80103d6f:	85 c0                	test   %eax,%eax
80103d71:	75 30                	jne    80103da3 <fork+0x81>
    kfree(np->kstack);
80103d73:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d76:	8b 40 08             	mov    0x8(%eax),%eax
80103d79:	83 ec 0c             	sub    $0xc,%esp
80103d7c:	50                   	push   %eax
80103d7d:	e8 77 e9 ff ff       	call   801026f9 <kfree>
80103d82:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103d85:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d88:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103d8f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d92:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103d99:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d9e:	e9 f0 00 00 00       	jmp    80103e93 <fork+0x171>
  }
  np->sz = curproc->sz;
80103da3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103da6:	8b 10                	mov    (%eax),%edx
80103da8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dab:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103dad:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103db0:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103db3:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103db6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103db9:	8b 48 18             	mov    0x18(%eax),%ecx
80103dbc:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dbf:	8b 40 18             	mov    0x18(%eax),%eax
80103dc2:	89 c2                	mov    %eax,%edx
80103dc4:	89 cb                	mov    %ecx,%ebx
80103dc6:	b8 13 00 00 00       	mov    $0x13,%eax
80103dcb:	89 d7                	mov    %edx,%edi
80103dcd:	89 de                	mov    %ebx,%esi
80103dcf:	89 c1                	mov    %eax,%ecx
80103dd1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103dd3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dd6:	8b 40 18             	mov    0x18(%eax),%eax
80103dd9:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80103de0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103de7:	eb 3b                	jmp    80103e24 <fork+0x102>
    if(curproc->ofile[i])
80103de9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dec:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103def:	83 c2 08             	add    $0x8,%edx
80103df2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103df6:	85 c0                	test   %eax,%eax
80103df8:	74 26                	je     80103e20 <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103dfa:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dfd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e00:	83 c2 08             	add    $0x8,%edx
80103e03:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e07:	83 ec 0c             	sub    $0xc,%esp
80103e0a:	50                   	push   %eax
80103e0b:	e8 2d d2 ff ff       	call   8010103d <filedup>
80103e10:	83 c4 10             	add    $0x10,%esp
80103e13:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e16:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103e19:	83 c1 08             	add    $0x8,%ecx
80103e1c:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80103e20:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103e24:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103e28:	7e bf                	jle    80103de9 <fork+0xc7>
  np->cwd = idup(curproc->cwd);
80103e2a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e2d:	8b 40 68             	mov    0x68(%eax),%eax
80103e30:	83 ec 0c             	sub    $0xc,%esp
80103e33:	50                   	push   %eax
80103e34:	e8 6a db ff ff       	call   801019a3 <idup>
80103e39:	83 c4 10             	add    $0x10,%esp
80103e3c:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e3f:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103e42:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e45:	8d 50 6c             	lea    0x6c(%eax),%edx
80103e48:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e4b:	83 c0 6c             	add    $0x6c,%eax
80103e4e:	83 ec 04             	sub    $0x4,%esp
80103e51:	6a 10                	push   $0x10
80103e53:	52                   	push   %edx
80103e54:	50                   	push   %eax
80103e55:	e8 7e 0e 00 00       	call   80104cd8 <safestrcpy>
80103e5a:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103e5d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e60:	8b 40 10             	mov    0x10(%eax),%eax
80103e63:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103e66:	83 ec 0c             	sub    $0xc,%esp
80103e69:	68 00 42 19 80       	push   $0x80194200
80103e6e:	e8 ec 09 00 00       	call   8010485f <acquire>
80103e73:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80103e76:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e79:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103e80:	83 ec 0c             	sub    $0xc,%esp
80103e83:	68 00 42 19 80       	push   $0x80194200
80103e88:	e8 40 0a 00 00       	call   801048cd <release>
80103e8d:	83 c4 10             	add    $0x10,%esp

  return pid;
80103e90:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80103e93:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103e96:	5b                   	pop    %ebx
80103e97:	5e                   	pop    %esi
80103e98:	5f                   	pop    %edi
80103e99:	5d                   	pop    %ebp
80103e9a:	c3                   	ret    

80103e9b <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80103e9b:	55                   	push   %ebp
80103e9c:	89 e5                	mov    %esp,%ebp
80103e9e:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80103ea1:	e8 7d fb ff ff       	call   80103a23 <myproc>
80103ea6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80103ea9:	a1 34 61 19 80       	mov    0x80196134,%eax
80103eae:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103eb1:	75 0d                	jne    80103ec0 <exit+0x25>
    panic("init exiting");
80103eb3:	83 ec 0c             	sub    $0xc,%esp
80103eb6:	68 fe a3 10 80       	push   $0x8010a3fe
80103ebb:	e8 e9 c6 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80103ec0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80103ec7:	eb 3f                	jmp    80103f08 <exit+0x6d>
    if(curproc->ofile[fd]){
80103ec9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ecc:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103ecf:	83 c2 08             	add    $0x8,%edx
80103ed2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103ed6:	85 c0                	test   %eax,%eax
80103ed8:	74 2a                	je     80103f04 <exit+0x69>
      fileclose(curproc->ofile[fd]);
80103eda:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103edd:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103ee0:	83 c2 08             	add    $0x8,%edx
80103ee3:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103ee7:	83 ec 0c             	sub    $0xc,%esp
80103eea:	50                   	push   %eax
80103eeb:	e8 9e d1 ff ff       	call   8010108e <fileclose>
80103ef0:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80103ef3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ef6:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103ef9:	83 c2 08             	add    $0x8,%edx
80103efc:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80103f03:	00 
  for(fd = 0; fd < NOFILE; fd++){
80103f04:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80103f08:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80103f0c:	7e bb                	jle    80103ec9 <exit+0x2e>
    }
  }

  begin_op();
80103f0e:	e8 1c f1 ff ff       	call   8010302f <begin_op>
  iput(curproc->cwd);
80103f13:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f16:	8b 40 68             	mov    0x68(%eax),%eax
80103f19:	83 ec 0c             	sub    $0xc,%esp
80103f1c:	50                   	push   %eax
80103f1d:	e8 1c dc ff ff       	call   80101b3e <iput>
80103f22:	83 c4 10             	add    $0x10,%esp
  end_op();
80103f25:	e8 91 f1 ff ff       	call   801030bb <end_op>
  curproc->cwd = 0;
80103f2a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f2d:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80103f34:	83 ec 0c             	sub    $0xc,%esp
80103f37:	68 00 42 19 80       	push   $0x80194200
80103f3c:	e8 1e 09 00 00       	call   8010485f <acquire>
80103f41:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80103f44:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f47:	8b 40 14             	mov    0x14(%eax),%eax
80103f4a:	83 ec 0c             	sub    $0xc,%esp
80103f4d:	50                   	push   %eax
80103f4e:	e8 20 04 00 00       	call   80104373 <wakeup1>
80103f53:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f56:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103f5d:	eb 37                	jmp    80103f96 <exit+0xfb>
    if(p->parent == curproc){
80103f5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f62:	8b 40 14             	mov    0x14(%eax),%eax
80103f65:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103f68:	75 28                	jne    80103f92 <exit+0xf7>
      p->parent = initproc;
80103f6a:	8b 15 34 61 19 80    	mov    0x80196134,%edx
80103f70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f73:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80103f76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f79:	8b 40 0c             	mov    0xc(%eax),%eax
80103f7c:	83 f8 05             	cmp    $0x5,%eax
80103f7f:	75 11                	jne    80103f92 <exit+0xf7>
        wakeup1(initproc);
80103f81:	a1 34 61 19 80       	mov    0x80196134,%eax
80103f86:	83 ec 0c             	sub    $0xc,%esp
80103f89:	50                   	push   %eax
80103f8a:	e8 e4 03 00 00       	call   80104373 <wakeup1>
80103f8f:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f92:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80103f96:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
80103f9d:	72 c0                	jb     80103f5f <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80103f9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fa2:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80103fa9:	e8 e5 01 00 00       	call   80104193 <sched>
  panic("zombie exit");
80103fae:	83 ec 0c             	sub    $0xc,%esp
80103fb1:	68 0b a4 10 80       	push   $0x8010a40b
80103fb6:	e8 ee c5 ff ff       	call   801005a9 <panic>

80103fbb <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80103fbb:	55                   	push   %ebp
80103fbc:	89 e5                	mov    %esp,%ebp
80103fbe:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80103fc1:	e8 5d fa ff ff       	call   80103a23 <myproc>
80103fc6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80103fc9:	83 ec 0c             	sub    $0xc,%esp
80103fcc:	68 00 42 19 80       	push   $0x80194200
80103fd1:	e8 89 08 00 00       	call   8010485f <acquire>
80103fd6:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80103fd9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103fe0:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103fe7:	e9 a1 00 00 00       	jmp    8010408d <wait+0xd2>
      if(p->parent != curproc)
80103fec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fef:	8b 40 14             	mov    0x14(%eax),%eax
80103ff2:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103ff5:	0f 85 8d 00 00 00    	jne    80104088 <wait+0xcd>
        continue;
      havekids = 1;
80103ffb:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104002:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104005:	8b 40 0c             	mov    0xc(%eax),%eax
80104008:	83 f8 05             	cmp    $0x5,%eax
8010400b:	75 7c                	jne    80104089 <wait+0xce>
        // Found one.
        pid = p->pid;
8010400d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104010:	8b 40 10             	mov    0x10(%eax),%eax
80104013:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104016:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104019:	8b 40 08             	mov    0x8(%eax),%eax
8010401c:	83 ec 0c             	sub    $0xc,%esp
8010401f:	50                   	push   %eax
80104020:	e8 d4 e6 ff ff       	call   801026f9 <kfree>
80104025:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104028:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010402b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104032:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104035:	8b 40 04             	mov    0x4(%eax),%eax
80104038:	83 ec 0c             	sub    $0xc,%esp
8010403b:	50                   	push   %eax
8010403c:	e8 71 39 00 00       	call   801079b2 <freevm>
80104041:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104044:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104047:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010404e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104051:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104058:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010405b:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010405f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104062:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104069:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010406c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104073:	83 ec 0c             	sub    $0xc,%esp
80104076:	68 00 42 19 80       	push   $0x80194200
8010407b:	e8 4d 08 00 00       	call   801048cd <release>
80104080:	83 c4 10             	add    $0x10,%esp
        return pid;
80104083:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104086:	eb 51                	jmp    801040d9 <wait+0x11e>
        continue;
80104088:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104089:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010408d:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
80104094:	0f 82 52 ff ff ff    	jb     80103fec <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
8010409a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010409e:	74 0a                	je     801040aa <wait+0xef>
801040a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040a3:	8b 40 24             	mov    0x24(%eax),%eax
801040a6:	85 c0                	test   %eax,%eax
801040a8:	74 17                	je     801040c1 <wait+0x106>
      release(&ptable.lock);
801040aa:	83 ec 0c             	sub    $0xc,%esp
801040ad:	68 00 42 19 80       	push   $0x80194200
801040b2:	e8 16 08 00 00       	call   801048cd <release>
801040b7:	83 c4 10             	add    $0x10,%esp
      return -1;
801040ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040bf:	eb 18                	jmp    801040d9 <wait+0x11e>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801040c1:	83 ec 08             	sub    $0x8,%esp
801040c4:	68 00 42 19 80       	push   $0x80194200
801040c9:	ff 75 ec             	push   -0x14(%ebp)
801040cc:	e8 fb 01 00 00       	call   801042cc <sleep>
801040d1:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801040d4:	e9 00 ff ff ff       	jmp    80103fd9 <wait+0x1e>
  }
}
801040d9:	c9                   	leave  
801040da:	c3                   	ret    

801040db <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801040db:	55                   	push   %ebp
801040dc:	89 e5                	mov    %esp,%ebp
801040de:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801040e1:	e8 c5 f8 ff ff       	call   801039ab <mycpu>
801040e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
801040e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040ec:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801040f3:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
801040f6:	e8 70 f8 ff ff       	call   8010396b <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801040fb:	83 ec 0c             	sub    $0xc,%esp
801040fe:	68 00 42 19 80       	push   $0x80194200
80104103:	e8 57 07 00 00       	call   8010485f <acquire>
80104108:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010410b:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104112:	eb 61                	jmp    80104175 <scheduler+0x9a>
      if(p->state != RUNNABLE)
80104114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104117:	8b 40 0c             	mov    0xc(%eax),%eax
8010411a:	83 f8 03             	cmp    $0x3,%eax
8010411d:	75 51                	jne    80104170 <scheduler+0x95>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
8010411f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104122:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104125:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
8010412b:	83 ec 0c             	sub    $0xc,%esp
8010412e:	ff 75 f4             	push   -0xc(%ebp)
80104131:	e8 d5 33 00 00       	call   8010750b <switchuvm>
80104136:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104139:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010413c:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104143:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104146:	8b 40 1c             	mov    0x1c(%eax),%eax
80104149:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010414c:	83 c2 04             	add    $0x4,%edx
8010414f:	83 ec 08             	sub    $0x8,%esp
80104152:	50                   	push   %eax
80104153:	52                   	push   %edx
80104154:	e8 f1 0b 00 00       	call   80104d4a <swtch>
80104159:	83 c4 10             	add    $0x10,%esp
      switchkvm();
8010415c:	e8 91 33 00 00       	call   801074f2 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104161:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104164:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010416b:	00 00 00 
8010416e:	eb 01                	jmp    80104171 <scheduler+0x96>
        continue;
80104170:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104171:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104175:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
8010417c:	72 96                	jb     80104114 <scheduler+0x39>
    }
    release(&ptable.lock);
8010417e:	83 ec 0c             	sub    $0xc,%esp
80104181:	68 00 42 19 80       	push   $0x80194200
80104186:	e8 42 07 00 00       	call   801048cd <release>
8010418b:	83 c4 10             	add    $0x10,%esp
    sti();
8010418e:	e9 63 ff ff ff       	jmp    801040f6 <scheduler+0x1b>

80104193 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104193:	55                   	push   %ebp
80104194:	89 e5                	mov    %esp,%ebp
80104196:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104199:	e8 85 f8 ff ff       	call   80103a23 <myproc>
8010419e:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
801041a1:	83 ec 0c             	sub    $0xc,%esp
801041a4:	68 00 42 19 80       	push   $0x80194200
801041a9:	e8 ec 07 00 00       	call   8010499a <holding>
801041ae:	83 c4 10             	add    $0x10,%esp
801041b1:	85 c0                	test   %eax,%eax
801041b3:	75 0d                	jne    801041c2 <sched+0x2f>
    panic("sched ptable.lock");
801041b5:	83 ec 0c             	sub    $0xc,%esp
801041b8:	68 17 a4 10 80       	push   $0x8010a417
801041bd:	e8 e7 c3 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
801041c2:	e8 e4 f7 ff ff       	call   801039ab <mycpu>
801041c7:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801041cd:	83 f8 01             	cmp    $0x1,%eax
801041d0:	74 0d                	je     801041df <sched+0x4c>
    panic("sched locks");
801041d2:	83 ec 0c             	sub    $0xc,%esp
801041d5:	68 29 a4 10 80       	push   $0x8010a429
801041da:	e8 ca c3 ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
801041df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041e2:	8b 40 0c             	mov    0xc(%eax),%eax
801041e5:	83 f8 04             	cmp    $0x4,%eax
801041e8:	75 0d                	jne    801041f7 <sched+0x64>
    panic("sched running");
801041ea:	83 ec 0c             	sub    $0xc,%esp
801041ed:	68 35 a4 10 80       	push   $0x8010a435
801041f2:	e8 b2 c3 ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
801041f7:	e8 5f f7 ff ff       	call   8010395b <readeflags>
801041fc:	25 00 02 00 00       	and    $0x200,%eax
80104201:	85 c0                	test   %eax,%eax
80104203:	74 0d                	je     80104212 <sched+0x7f>
    panic("sched interruptible");
80104205:	83 ec 0c             	sub    $0xc,%esp
80104208:	68 43 a4 10 80       	push   $0x8010a443
8010420d:	e8 97 c3 ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
80104212:	e8 94 f7 ff ff       	call   801039ab <mycpu>
80104217:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010421d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104220:	e8 86 f7 ff ff       	call   801039ab <mycpu>
80104225:	8b 40 04             	mov    0x4(%eax),%eax
80104228:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010422b:	83 c2 1c             	add    $0x1c,%edx
8010422e:	83 ec 08             	sub    $0x8,%esp
80104231:	50                   	push   %eax
80104232:	52                   	push   %edx
80104233:	e8 12 0b 00 00       	call   80104d4a <swtch>
80104238:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
8010423b:	e8 6b f7 ff ff       	call   801039ab <mycpu>
80104240:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104243:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104249:	90                   	nop
8010424a:	c9                   	leave  
8010424b:	c3                   	ret    

8010424c <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
8010424c:	55                   	push   %ebp
8010424d:	89 e5                	mov    %esp,%ebp
8010424f:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104252:	83 ec 0c             	sub    $0xc,%esp
80104255:	68 00 42 19 80       	push   $0x80194200
8010425a:	e8 00 06 00 00       	call   8010485f <acquire>
8010425f:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104262:	e8 bc f7 ff ff       	call   80103a23 <myproc>
80104267:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010426e:	e8 20 ff ff ff       	call   80104193 <sched>
  release(&ptable.lock);
80104273:	83 ec 0c             	sub    $0xc,%esp
80104276:	68 00 42 19 80       	push   $0x80194200
8010427b:	e8 4d 06 00 00       	call   801048cd <release>
80104280:	83 c4 10             	add    $0x10,%esp
}
80104283:	90                   	nop
80104284:	c9                   	leave  
80104285:	c3                   	ret    

80104286 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104286:	55                   	push   %ebp
80104287:	89 e5                	mov    %esp,%ebp
80104289:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
8010428c:	83 ec 0c             	sub    $0xc,%esp
8010428f:	68 00 42 19 80       	push   $0x80194200
80104294:	e8 34 06 00 00       	call   801048cd <release>
80104299:	83 c4 10             	add    $0x10,%esp

  if (first) {
8010429c:	a1 04 f0 10 80       	mov    0x8010f004,%eax
801042a1:	85 c0                	test   %eax,%eax
801042a3:	74 24                	je     801042c9 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801042a5:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
801042ac:	00 00 00 
    iinit(ROOTDEV);
801042af:	83 ec 0c             	sub    $0xc,%esp
801042b2:	6a 01                	push   $0x1
801042b4:	e8 b2 d3 ff ff       	call   8010166b <iinit>
801042b9:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801042bc:	83 ec 0c             	sub    $0xc,%esp
801042bf:	6a 01                	push   $0x1
801042c1:	e8 4a eb ff ff       	call   80102e10 <initlog>
801042c6:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801042c9:	90                   	nop
801042ca:	c9                   	leave  
801042cb:	c3                   	ret    

801042cc <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801042cc:	55                   	push   %ebp
801042cd:	89 e5                	mov    %esp,%ebp
801042cf:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
801042d2:	e8 4c f7 ff ff       	call   80103a23 <myproc>
801042d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
801042da:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801042de:	75 0d                	jne    801042ed <sleep+0x21>
    panic("sleep");
801042e0:	83 ec 0c             	sub    $0xc,%esp
801042e3:	68 57 a4 10 80       	push   $0x8010a457
801042e8:	e8 bc c2 ff ff       	call   801005a9 <panic>

  if(lk == 0)
801042ed:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801042f1:	75 0d                	jne    80104300 <sleep+0x34>
    panic("sleep without lk");
801042f3:	83 ec 0c             	sub    $0xc,%esp
801042f6:	68 5d a4 10 80       	push   $0x8010a45d
801042fb:	e8 a9 c2 ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104300:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
80104307:	74 1e                	je     80104327 <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104309:	83 ec 0c             	sub    $0xc,%esp
8010430c:	68 00 42 19 80       	push   $0x80194200
80104311:	e8 49 05 00 00       	call   8010485f <acquire>
80104316:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104319:	83 ec 0c             	sub    $0xc,%esp
8010431c:	ff 75 0c             	push   0xc(%ebp)
8010431f:	e8 a9 05 00 00       	call   801048cd <release>
80104324:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104327:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010432a:	8b 55 08             	mov    0x8(%ebp),%edx
8010432d:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104330:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104333:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
8010433a:	e8 54 fe ff ff       	call   80104193 <sched>

  // Tidy up.
  p->chan = 0;
8010433f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104342:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104349:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
80104350:	74 1e                	je     80104370 <sleep+0xa4>
    release(&ptable.lock);
80104352:	83 ec 0c             	sub    $0xc,%esp
80104355:	68 00 42 19 80       	push   $0x80194200
8010435a:	e8 6e 05 00 00       	call   801048cd <release>
8010435f:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104362:	83 ec 0c             	sub    $0xc,%esp
80104365:	ff 75 0c             	push   0xc(%ebp)
80104368:	e8 f2 04 00 00       	call   8010485f <acquire>
8010436d:	83 c4 10             	add    $0x10,%esp
  }
}
80104370:	90                   	nop
80104371:	c9                   	leave  
80104372:	c3                   	ret    

80104373 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104373:	55                   	push   %ebp
80104374:	89 e5                	mov    %esp,%ebp
80104376:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104379:	c7 45 fc 34 42 19 80 	movl   $0x80194234,-0x4(%ebp)
80104380:	eb 24                	jmp    801043a6 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104382:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104385:	8b 40 0c             	mov    0xc(%eax),%eax
80104388:	83 f8 02             	cmp    $0x2,%eax
8010438b:	75 15                	jne    801043a2 <wakeup1+0x2f>
8010438d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104390:	8b 40 20             	mov    0x20(%eax),%eax
80104393:	39 45 08             	cmp    %eax,0x8(%ebp)
80104396:	75 0a                	jne    801043a2 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104398:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010439b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043a2:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
801043a6:	81 7d fc 34 61 19 80 	cmpl   $0x80196134,-0x4(%ebp)
801043ad:	72 d3                	jb     80104382 <wakeup1+0xf>
}
801043af:	90                   	nop
801043b0:	90                   	nop
801043b1:	c9                   	leave  
801043b2:	c3                   	ret    

801043b3 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801043b3:	55                   	push   %ebp
801043b4:	89 e5                	mov    %esp,%ebp
801043b6:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801043b9:	83 ec 0c             	sub    $0xc,%esp
801043bc:	68 00 42 19 80       	push   $0x80194200
801043c1:	e8 99 04 00 00       	call   8010485f <acquire>
801043c6:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801043c9:	83 ec 0c             	sub    $0xc,%esp
801043cc:	ff 75 08             	push   0x8(%ebp)
801043cf:	e8 9f ff ff ff       	call   80104373 <wakeup1>
801043d4:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801043d7:	83 ec 0c             	sub    $0xc,%esp
801043da:	68 00 42 19 80       	push   $0x80194200
801043df:	e8 e9 04 00 00       	call   801048cd <release>
801043e4:	83 c4 10             	add    $0x10,%esp
}
801043e7:	90                   	nop
801043e8:	c9                   	leave  
801043e9:	c3                   	ret    

801043ea <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801043ea:	55                   	push   %ebp
801043eb:	89 e5                	mov    %esp,%ebp
801043ed:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801043f0:	83 ec 0c             	sub    $0xc,%esp
801043f3:	68 00 42 19 80       	push   $0x80194200
801043f8:	e8 62 04 00 00       	call   8010485f <acquire>
801043fd:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104400:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104407:	eb 45                	jmp    8010444e <kill+0x64>
    if(p->pid == pid){
80104409:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010440c:	8b 40 10             	mov    0x10(%eax),%eax
8010440f:	39 45 08             	cmp    %eax,0x8(%ebp)
80104412:	75 36                	jne    8010444a <kill+0x60>
      p->killed = 1;
80104414:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104417:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
8010441e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104421:	8b 40 0c             	mov    0xc(%eax),%eax
80104424:	83 f8 02             	cmp    $0x2,%eax
80104427:	75 0a                	jne    80104433 <kill+0x49>
        p->state = RUNNABLE;
80104429:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010442c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104433:	83 ec 0c             	sub    $0xc,%esp
80104436:	68 00 42 19 80       	push   $0x80194200
8010443b:	e8 8d 04 00 00       	call   801048cd <release>
80104440:	83 c4 10             	add    $0x10,%esp
      return 0;
80104443:	b8 00 00 00 00       	mov    $0x0,%eax
80104448:	eb 22                	jmp    8010446c <kill+0x82>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010444a:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010444e:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
80104455:	72 b2                	jb     80104409 <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104457:	83 ec 0c             	sub    $0xc,%esp
8010445a:	68 00 42 19 80       	push   $0x80194200
8010445f:	e8 69 04 00 00       	call   801048cd <release>
80104464:	83 c4 10             	add    $0x10,%esp
  return -1;
80104467:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010446c:	c9                   	leave  
8010446d:	c3                   	ret    

8010446e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010446e:	55                   	push   %ebp
8010446f:	89 e5                	mov    %esp,%ebp
80104471:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104474:	c7 45 f0 34 42 19 80 	movl   $0x80194234,-0x10(%ebp)
8010447b:	e9 d7 00 00 00       	jmp    80104557 <procdump+0xe9>
    if(p->state == UNUSED)
80104480:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104483:	8b 40 0c             	mov    0xc(%eax),%eax
80104486:	85 c0                	test   %eax,%eax
80104488:	0f 84 c4 00 00 00    	je     80104552 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010448e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104491:	8b 40 0c             	mov    0xc(%eax),%eax
80104494:	83 f8 05             	cmp    $0x5,%eax
80104497:	77 23                	ja     801044bc <procdump+0x4e>
80104499:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010449c:	8b 40 0c             	mov    0xc(%eax),%eax
8010449f:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801044a6:	85 c0                	test   %eax,%eax
801044a8:	74 12                	je     801044bc <procdump+0x4e>
      state = states[p->state];
801044aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044ad:	8b 40 0c             	mov    0xc(%eax),%eax
801044b0:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801044b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
801044ba:	eb 07                	jmp    801044c3 <procdump+0x55>
    else
      state = "???";
801044bc:	c7 45 ec 6e a4 10 80 	movl   $0x8010a46e,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801044c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044c6:	8d 50 6c             	lea    0x6c(%eax),%edx
801044c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044cc:	8b 40 10             	mov    0x10(%eax),%eax
801044cf:	52                   	push   %edx
801044d0:	ff 75 ec             	push   -0x14(%ebp)
801044d3:	50                   	push   %eax
801044d4:	68 72 a4 10 80       	push   $0x8010a472
801044d9:	e8 16 bf ff ff       	call   801003f4 <cprintf>
801044de:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801044e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044e4:	8b 40 0c             	mov    0xc(%eax),%eax
801044e7:	83 f8 02             	cmp    $0x2,%eax
801044ea:	75 54                	jne    80104540 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801044ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044ef:	8b 40 1c             	mov    0x1c(%eax),%eax
801044f2:	8b 40 0c             	mov    0xc(%eax),%eax
801044f5:	83 c0 08             	add    $0x8,%eax
801044f8:	89 c2                	mov    %eax,%edx
801044fa:	83 ec 08             	sub    $0x8,%esp
801044fd:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104500:	50                   	push   %eax
80104501:	52                   	push   %edx
80104502:	e8 18 04 00 00       	call   8010491f <getcallerpcs>
80104507:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
8010450a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104511:	eb 1c                	jmp    8010452f <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104513:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104516:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010451a:	83 ec 08             	sub    $0x8,%esp
8010451d:	50                   	push   %eax
8010451e:	68 7b a4 10 80       	push   $0x8010a47b
80104523:	e8 cc be ff ff       	call   801003f4 <cprintf>
80104528:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
8010452b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010452f:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104533:	7f 0b                	jg     80104540 <procdump+0xd2>
80104535:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104538:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010453c:	85 c0                	test   %eax,%eax
8010453e:	75 d3                	jne    80104513 <procdump+0xa5>
    }
    cprintf("\n");
80104540:	83 ec 0c             	sub    $0xc,%esp
80104543:	68 7f a4 10 80       	push   $0x8010a47f
80104548:	e8 a7 be ff ff       	call   801003f4 <cprintf>
8010454d:	83 c4 10             	add    $0x10,%esp
80104550:	eb 01                	jmp    80104553 <procdump+0xe5>
      continue;
80104552:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104553:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80104557:	81 7d f0 34 61 19 80 	cmpl   $0x80196134,-0x10(%ebp)
8010455e:	0f 82 1c ff ff ff    	jb     80104480 <procdump+0x12>
  }
}
80104564:	90                   	nop
80104565:	90                   	nop
80104566:	c9                   	leave  
80104567:	c3                   	ret    

80104568 <printpt>:

int
printpt(int pid)
{
80104568:	55                   	push   %ebp
80104569:	89 e5                	mov    %esp,%ebp
8010456b:	83 ec 18             	sub    $0x18,%esp
  pde_t* pgdir = myproc()->pgdir;
8010456e:	e8 b0 f4 ff ff       	call   80103a23 <myproc>
80104573:	8b 40 04             	mov    0x4(%eax),%eax
80104576:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  cprintf("%d\n", myproc()->pid);
80104579:	e8 a5 f4 ff ff       	call   80103a23 <myproc>
8010457e:	8b 40 10             	mov    0x10(%eax),%eax
80104581:	83 ec 08             	sub    $0x8,%esp
80104584:	50                   	push   %eax
80104585:	68 81 a4 10 80       	push   $0x8010a481
8010458a:	e8 65 be ff ff       	call   801003f4 <cprintf>
8010458f:	83 c4 10             	add    $0x10,%esp
  cprintf("START PAGE TABLE (pid %d)\n", pid);
80104592:	83 ec 08             	sub    $0x8,%esp
80104595:	ff 75 08             	push   0x8(%ebp)
80104598:	68 85 a4 10 80       	push   $0x8010a485
8010459d:	e8 52 be ff ff       	call   801003f4 <cprintf>
801045a2:	83 c4 10             	add    $0x10,%esp
  
  //int cnt = 0;
  
  // 유저영역의 페이지 디렉토리를 조사한다.
  for (uint i = 0; i < PDX(KERNBASE); i++) {
801045a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801045ac:	e9 0b 01 00 00       	jmp    801046bc <printpt+0x154>

    // 활성화 된 페이지 디렉토리이면
    if (pgdir[i] & PTE_P) {
801045b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801045bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801045be:	01 d0                	add    %edx,%eax
801045c0:	8b 00                	mov    (%eax),%eax
801045c2:	83 e0 01             	and    $0x1,%eax
801045c5:	85 c0                	test   %eax,%eax
801045c7:	0f 84 eb 00 00 00    	je     801046b8 <printpt+0x150>
      
      //cprintf("%p %x\n", &pgdir[i], pgdir[i]);

      // 해당 주소의 페이지 테이블을 가져온다.
      pte_t* pgtab = (pte_t*)P2V(PTE_ADDR(pgdir[i]));
801045cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801045d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801045da:	01 d0                	add    %edx,%eax
801045dc:	8b 00                	mov    (%eax),%eax
801045de:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801045e3:	05 00 00 00 80       	add    $0x80000000,%eax
801045e8:	89 45 e8             	mov    %eax,-0x18(%ebp)
      
      //cprintf("%p %x %p\n", pgdir, pgdir[i], pgtab);

      // 페이지 테이블의 개수 1024개를 모두 조사한다.
      for (uint j = 0; j < NPTENTRIES; j++) {
801045eb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801045f2:	e9 b4 00 00 00       	jmp    801046ab <printpt+0x143>
        
        if (pgtab[j] & PTE_P) {
801045f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045fa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104601:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104604:	01 d0                	add    %edx,%eax
80104606:	8b 00                	mov    (%eax),%eax
80104608:	83 e0 01             	and    $0x1,%eax
8010460b:	85 c0                	test   %eax,%eax
8010460d:	0f 84 94 00 00 00    	je     801046a7 <printpt+0x13f>
          

          cprintf("%p %x Data : \n", &pgtab[j], pgtab[j]);
80104613:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104616:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010461d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104620:	01 d0                	add    %edx,%eax
80104622:	8b 00                	mov    (%eax),%eax
80104624:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104627:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
8010462e:	8b 55 e8             	mov    -0x18(%ebp),%edx
80104631:	01 ca                	add    %ecx,%edx
80104633:	83 ec 04             	sub    $0x4,%esp
80104636:	50                   	push   %eax
80104637:	52                   	push   %edx
80104638:	68 a0 a4 10 80       	push   $0x8010a4a0
8010463d:	e8 b2 bd ff ff       	call   801003f4 <cprintf>
80104642:	83 c4 10             	add    $0x10,%esp
          cprintf("%d %s %s %s\n", j, "P", (pgtab[j] & PTE_U) ? "U\0" : "K\0", (pgtab[j] & PTE_W) ? "W\0" : "-\0");
80104645:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104648:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010464f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104652:	01 d0                	add    %edx,%eax
80104654:	8b 00                	mov    (%eax),%eax
80104656:	83 e0 02             	and    $0x2,%eax
80104659:	85 c0                	test   %eax,%eax
8010465b:	74 07                	je     80104664 <printpt+0xfc>
8010465d:	ba af a4 10 80       	mov    $0x8010a4af,%edx
80104662:	eb 05                	jmp    80104669 <printpt+0x101>
80104664:	ba b2 a4 10 80       	mov    $0x8010a4b2,%edx
80104669:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010466c:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80104673:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104676:	01 c8                	add    %ecx,%eax
80104678:	8b 00                	mov    (%eax),%eax
8010467a:	83 e0 04             	and    $0x4,%eax
8010467d:	85 c0                	test   %eax,%eax
8010467f:	74 07                	je     80104688 <printpt+0x120>
80104681:	b8 b5 a4 10 80       	mov    $0x8010a4b5,%eax
80104686:	eb 05                	jmp    8010468d <printpt+0x125>
80104688:	b8 b8 a4 10 80       	mov    $0x8010a4b8,%eax
8010468d:	83 ec 0c             	sub    $0xc,%esp
80104690:	52                   	push   %edx
80104691:	50                   	push   %eax
80104692:	68 bb a4 10 80       	push   $0x8010a4bb
80104697:	ff 75 f0             	push   -0x10(%ebp)
8010469a:	68 bd a4 10 80       	push   $0x8010a4bd
8010469f:	e8 50 bd ff ff       	call   801003f4 <cprintf>
801046a4:	83 c4 20             	add    $0x20,%esp
      for (uint j = 0; j < NPTENTRIES; j++) {
801046a7:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801046ab:	81 7d f0 ff 03 00 00 	cmpl   $0x3ff,-0x10(%ebp)
801046b2:	0f 86 3f ff ff ff    	jbe    801045f7 <printpt+0x8f>
  for (uint i = 0; i < PDX(KERNBASE); i++) {
801046b8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801046bc:	81 7d f4 ff 01 00 00 	cmpl   $0x1ff,-0xc(%ebp)
801046c3:	0f 86 e8 fe ff ff    	jbe    801045b1 <printpt+0x49>
    }
  }
  
  

  cprintf("END PAGE TABLE\n");
801046c9:	83 ec 0c             	sub    $0xc,%esp
801046cc:	68 ca a4 10 80       	push   $0x8010a4ca
801046d1:	e8 1e bd ff ff       	call   801003f4 <cprintf>
801046d6:	83 c4 10             	add    $0x10,%esp
  return 0;
801046d9:	b8 00 00 00 00       	mov    $0x0,%eax
801046de:	c9                   	leave  
801046df:	c3                   	ret    

801046e0 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801046e0:	55                   	push   %ebp
801046e1:	89 e5                	mov    %esp,%ebp
801046e3:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
801046e6:	8b 45 08             	mov    0x8(%ebp),%eax
801046e9:	83 c0 04             	add    $0x4,%eax
801046ec:	83 ec 08             	sub    $0x8,%esp
801046ef:	68 04 a5 10 80       	push   $0x8010a504
801046f4:	50                   	push   %eax
801046f5:	e8 43 01 00 00       	call   8010483d <initlock>
801046fa:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
801046fd:	8b 45 08             	mov    0x8(%ebp),%eax
80104700:	8b 55 0c             	mov    0xc(%ebp),%edx
80104703:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104706:	8b 45 08             	mov    0x8(%ebp),%eax
80104709:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010470f:	8b 45 08             	mov    0x8(%ebp),%eax
80104712:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104719:	90                   	nop
8010471a:	c9                   	leave  
8010471b:	c3                   	ret    

8010471c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
8010471c:	55                   	push   %ebp
8010471d:	89 e5                	mov    %esp,%ebp
8010471f:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104722:	8b 45 08             	mov    0x8(%ebp),%eax
80104725:	83 c0 04             	add    $0x4,%eax
80104728:	83 ec 0c             	sub    $0xc,%esp
8010472b:	50                   	push   %eax
8010472c:	e8 2e 01 00 00       	call   8010485f <acquire>
80104731:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104734:	eb 15                	jmp    8010474b <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104736:	8b 45 08             	mov    0x8(%ebp),%eax
80104739:	83 c0 04             	add    $0x4,%eax
8010473c:	83 ec 08             	sub    $0x8,%esp
8010473f:	50                   	push   %eax
80104740:	ff 75 08             	push   0x8(%ebp)
80104743:	e8 84 fb ff ff       	call   801042cc <sleep>
80104748:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
8010474b:	8b 45 08             	mov    0x8(%ebp),%eax
8010474e:	8b 00                	mov    (%eax),%eax
80104750:	85 c0                	test   %eax,%eax
80104752:	75 e2                	jne    80104736 <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104754:	8b 45 08             	mov    0x8(%ebp),%eax
80104757:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
8010475d:	e8 c1 f2 ff ff       	call   80103a23 <myproc>
80104762:	8b 50 10             	mov    0x10(%eax),%edx
80104765:	8b 45 08             	mov    0x8(%ebp),%eax
80104768:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
8010476b:	8b 45 08             	mov    0x8(%ebp),%eax
8010476e:	83 c0 04             	add    $0x4,%eax
80104771:	83 ec 0c             	sub    $0xc,%esp
80104774:	50                   	push   %eax
80104775:	e8 53 01 00 00       	call   801048cd <release>
8010477a:	83 c4 10             	add    $0x10,%esp
}
8010477d:	90                   	nop
8010477e:	c9                   	leave  
8010477f:	c3                   	ret    

80104780 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104780:	55                   	push   %ebp
80104781:	89 e5                	mov    %esp,%ebp
80104783:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104786:	8b 45 08             	mov    0x8(%ebp),%eax
80104789:	83 c0 04             	add    $0x4,%eax
8010478c:	83 ec 0c             	sub    $0xc,%esp
8010478f:	50                   	push   %eax
80104790:	e8 ca 00 00 00       	call   8010485f <acquire>
80104795:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104798:	8b 45 08             	mov    0x8(%ebp),%eax
8010479b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801047a1:	8b 45 08             	mov    0x8(%ebp),%eax
801047a4:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
801047ab:	83 ec 0c             	sub    $0xc,%esp
801047ae:	ff 75 08             	push   0x8(%ebp)
801047b1:	e8 fd fb ff ff       	call   801043b3 <wakeup>
801047b6:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
801047b9:	8b 45 08             	mov    0x8(%ebp),%eax
801047bc:	83 c0 04             	add    $0x4,%eax
801047bf:	83 ec 0c             	sub    $0xc,%esp
801047c2:	50                   	push   %eax
801047c3:	e8 05 01 00 00       	call   801048cd <release>
801047c8:	83 c4 10             	add    $0x10,%esp
}
801047cb:	90                   	nop
801047cc:	c9                   	leave  
801047cd:	c3                   	ret    

801047ce <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801047ce:	55                   	push   %ebp
801047cf:	89 e5                	mov    %esp,%ebp
801047d1:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
801047d4:	8b 45 08             	mov    0x8(%ebp),%eax
801047d7:	83 c0 04             	add    $0x4,%eax
801047da:	83 ec 0c             	sub    $0xc,%esp
801047dd:	50                   	push   %eax
801047de:	e8 7c 00 00 00       	call   8010485f <acquire>
801047e3:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
801047e6:	8b 45 08             	mov    0x8(%ebp),%eax
801047e9:	8b 00                	mov    (%eax),%eax
801047eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
801047ee:	8b 45 08             	mov    0x8(%ebp),%eax
801047f1:	83 c0 04             	add    $0x4,%eax
801047f4:	83 ec 0c             	sub    $0xc,%esp
801047f7:	50                   	push   %eax
801047f8:	e8 d0 00 00 00       	call   801048cd <release>
801047fd:	83 c4 10             	add    $0x10,%esp
  return r;
80104800:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104803:	c9                   	leave  
80104804:	c3                   	ret    

80104805 <readeflags>:
{
80104805:	55                   	push   %ebp
80104806:	89 e5                	mov    %esp,%ebp
80104808:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010480b:	9c                   	pushf  
8010480c:	58                   	pop    %eax
8010480d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104810:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104813:	c9                   	leave  
80104814:	c3                   	ret    

80104815 <cli>:
{
80104815:	55                   	push   %ebp
80104816:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104818:	fa                   	cli    
}
80104819:	90                   	nop
8010481a:	5d                   	pop    %ebp
8010481b:	c3                   	ret    

8010481c <sti>:
{
8010481c:	55                   	push   %ebp
8010481d:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010481f:	fb                   	sti    
}
80104820:	90                   	nop
80104821:	5d                   	pop    %ebp
80104822:	c3                   	ret    

80104823 <xchg>:
{
80104823:	55                   	push   %ebp
80104824:	89 e5                	mov    %esp,%ebp
80104826:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104829:	8b 55 08             	mov    0x8(%ebp),%edx
8010482c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010482f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104832:	f0 87 02             	lock xchg %eax,(%edx)
80104835:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104838:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010483b:	c9                   	leave  
8010483c:	c3                   	ret    

8010483d <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010483d:	55                   	push   %ebp
8010483e:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104840:	8b 45 08             	mov    0x8(%ebp),%eax
80104843:	8b 55 0c             	mov    0xc(%ebp),%edx
80104846:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104849:	8b 45 08             	mov    0x8(%ebp),%eax
8010484c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104852:	8b 45 08             	mov    0x8(%ebp),%eax
80104855:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
8010485c:	90                   	nop
8010485d:	5d                   	pop    %ebp
8010485e:	c3                   	ret    

8010485f <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010485f:	55                   	push   %ebp
80104860:	89 e5                	mov    %esp,%ebp
80104862:	53                   	push   %ebx
80104863:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104866:	e8 5f 01 00 00       	call   801049ca <pushcli>
  if(holding(lk)){
8010486b:	8b 45 08             	mov    0x8(%ebp),%eax
8010486e:	83 ec 0c             	sub    $0xc,%esp
80104871:	50                   	push   %eax
80104872:	e8 23 01 00 00       	call   8010499a <holding>
80104877:	83 c4 10             	add    $0x10,%esp
8010487a:	85 c0                	test   %eax,%eax
8010487c:	74 0d                	je     8010488b <acquire+0x2c>
    panic("acquire");
8010487e:	83 ec 0c             	sub    $0xc,%esp
80104881:	68 0f a5 10 80       	push   $0x8010a50f
80104886:	e8 1e bd ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
8010488b:	90                   	nop
8010488c:	8b 45 08             	mov    0x8(%ebp),%eax
8010488f:	83 ec 08             	sub    $0x8,%esp
80104892:	6a 01                	push   $0x1
80104894:	50                   	push   %eax
80104895:	e8 89 ff ff ff       	call   80104823 <xchg>
8010489a:	83 c4 10             	add    $0x10,%esp
8010489d:	85 c0                	test   %eax,%eax
8010489f:	75 eb                	jne    8010488c <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
801048a1:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
801048a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
801048a9:	e8 fd f0 ff ff       	call   801039ab <mycpu>
801048ae:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
801048b1:	8b 45 08             	mov    0x8(%ebp),%eax
801048b4:	83 c0 0c             	add    $0xc,%eax
801048b7:	83 ec 08             	sub    $0x8,%esp
801048ba:	50                   	push   %eax
801048bb:	8d 45 08             	lea    0x8(%ebp),%eax
801048be:	50                   	push   %eax
801048bf:	e8 5b 00 00 00       	call   8010491f <getcallerpcs>
801048c4:	83 c4 10             	add    $0x10,%esp
}
801048c7:	90                   	nop
801048c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801048cb:	c9                   	leave  
801048cc:	c3                   	ret    

801048cd <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801048cd:	55                   	push   %ebp
801048ce:	89 e5                	mov    %esp,%ebp
801048d0:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801048d3:	83 ec 0c             	sub    $0xc,%esp
801048d6:	ff 75 08             	push   0x8(%ebp)
801048d9:	e8 bc 00 00 00       	call   8010499a <holding>
801048de:	83 c4 10             	add    $0x10,%esp
801048e1:	85 c0                	test   %eax,%eax
801048e3:	75 0d                	jne    801048f2 <release+0x25>
    panic("release");
801048e5:	83 ec 0c             	sub    $0xc,%esp
801048e8:	68 17 a5 10 80       	push   $0x8010a517
801048ed:	e8 b7 bc ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
801048f2:	8b 45 08             	mov    0x8(%ebp),%eax
801048f5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801048fc:	8b 45 08             	mov    0x8(%ebp),%eax
801048ff:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104906:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
8010490b:	8b 45 08             	mov    0x8(%ebp),%eax
8010490e:	8b 55 08             	mov    0x8(%ebp),%edx
80104911:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104917:	e8 fb 00 00 00       	call   80104a17 <popcli>
}
8010491c:	90                   	nop
8010491d:	c9                   	leave  
8010491e:	c3                   	ret    

8010491f <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010491f:	55                   	push   %ebp
80104920:	89 e5                	mov    %esp,%ebp
80104922:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104925:	8b 45 08             	mov    0x8(%ebp),%eax
80104928:	83 e8 08             	sub    $0x8,%eax
8010492b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010492e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104935:	eb 38                	jmp    8010496f <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104937:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010493b:	74 53                	je     80104990 <getcallerpcs+0x71>
8010493d:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104944:	76 4a                	jbe    80104990 <getcallerpcs+0x71>
80104946:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
8010494a:	74 44                	je     80104990 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010494c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010494f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104956:	8b 45 0c             	mov    0xc(%ebp),%eax
80104959:	01 c2                	add    %eax,%edx
8010495b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010495e:	8b 40 04             	mov    0x4(%eax),%eax
80104961:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104963:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104966:	8b 00                	mov    (%eax),%eax
80104968:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010496b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010496f:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104973:	7e c2                	jle    80104937 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80104975:	eb 19                	jmp    80104990 <getcallerpcs+0x71>
    pcs[i] = 0;
80104977:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010497a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104981:	8b 45 0c             	mov    0xc(%ebp),%eax
80104984:	01 d0                	add    %edx,%eax
80104986:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
8010498c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104990:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104994:	7e e1                	jle    80104977 <getcallerpcs+0x58>
}
80104996:	90                   	nop
80104997:	90                   	nop
80104998:	c9                   	leave  
80104999:	c3                   	ret    

8010499a <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
8010499a:	55                   	push   %ebp
8010499b:	89 e5                	mov    %esp,%ebp
8010499d:	53                   	push   %ebx
8010499e:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
801049a1:	8b 45 08             	mov    0x8(%ebp),%eax
801049a4:	8b 00                	mov    (%eax),%eax
801049a6:	85 c0                	test   %eax,%eax
801049a8:	74 16                	je     801049c0 <holding+0x26>
801049aa:	8b 45 08             	mov    0x8(%ebp),%eax
801049ad:	8b 58 08             	mov    0x8(%eax),%ebx
801049b0:	e8 f6 ef ff ff       	call   801039ab <mycpu>
801049b5:	39 c3                	cmp    %eax,%ebx
801049b7:	75 07                	jne    801049c0 <holding+0x26>
801049b9:	b8 01 00 00 00       	mov    $0x1,%eax
801049be:	eb 05                	jmp    801049c5 <holding+0x2b>
801049c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801049c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801049c8:	c9                   	leave  
801049c9:	c3                   	ret    

801049ca <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801049ca:	55                   	push   %ebp
801049cb:	89 e5                	mov    %esp,%ebp
801049cd:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
801049d0:	e8 30 fe ff ff       	call   80104805 <readeflags>
801049d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
801049d8:	e8 38 fe ff ff       	call   80104815 <cli>
  if(mycpu()->ncli == 0)
801049dd:	e8 c9 ef ff ff       	call   801039ab <mycpu>
801049e2:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801049e8:	85 c0                	test   %eax,%eax
801049ea:	75 14                	jne    80104a00 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
801049ec:	e8 ba ef ff ff       	call   801039ab <mycpu>
801049f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049f4:	81 e2 00 02 00 00    	and    $0x200,%edx
801049fa:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104a00:	e8 a6 ef ff ff       	call   801039ab <mycpu>
80104a05:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104a0b:	83 c2 01             	add    $0x1,%edx
80104a0e:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104a14:	90                   	nop
80104a15:	c9                   	leave  
80104a16:	c3                   	ret    

80104a17 <popcli>:

void
popcli(void)
{
80104a17:	55                   	push   %ebp
80104a18:	89 e5                	mov    %esp,%ebp
80104a1a:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104a1d:	e8 e3 fd ff ff       	call   80104805 <readeflags>
80104a22:	25 00 02 00 00       	and    $0x200,%eax
80104a27:	85 c0                	test   %eax,%eax
80104a29:	74 0d                	je     80104a38 <popcli+0x21>
    panic("popcli - interruptible");
80104a2b:	83 ec 0c             	sub    $0xc,%esp
80104a2e:	68 1f a5 10 80       	push   $0x8010a51f
80104a33:	e8 71 bb ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
80104a38:	e8 6e ef ff ff       	call   801039ab <mycpu>
80104a3d:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104a43:	83 ea 01             	sub    $0x1,%edx
80104a46:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104a4c:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104a52:	85 c0                	test   %eax,%eax
80104a54:	79 0d                	jns    80104a63 <popcli+0x4c>
    panic("popcli");
80104a56:	83 ec 0c             	sub    $0xc,%esp
80104a59:	68 36 a5 10 80       	push   $0x8010a536
80104a5e:	e8 46 bb ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104a63:	e8 43 ef ff ff       	call   801039ab <mycpu>
80104a68:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104a6e:	85 c0                	test   %eax,%eax
80104a70:	75 14                	jne    80104a86 <popcli+0x6f>
80104a72:	e8 34 ef ff ff       	call   801039ab <mycpu>
80104a77:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104a7d:	85 c0                	test   %eax,%eax
80104a7f:	74 05                	je     80104a86 <popcli+0x6f>
    sti();
80104a81:	e8 96 fd ff ff       	call   8010481c <sti>
}
80104a86:	90                   	nop
80104a87:	c9                   	leave  
80104a88:	c3                   	ret    

80104a89 <stosb>:
{
80104a89:	55                   	push   %ebp
80104a8a:	89 e5                	mov    %esp,%ebp
80104a8c:	57                   	push   %edi
80104a8d:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104a8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104a91:	8b 55 10             	mov    0x10(%ebp),%edx
80104a94:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a97:	89 cb                	mov    %ecx,%ebx
80104a99:	89 df                	mov    %ebx,%edi
80104a9b:	89 d1                	mov    %edx,%ecx
80104a9d:	fc                   	cld    
80104a9e:	f3 aa                	rep stos %al,%es:(%edi)
80104aa0:	89 ca                	mov    %ecx,%edx
80104aa2:	89 fb                	mov    %edi,%ebx
80104aa4:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104aa7:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104aaa:	90                   	nop
80104aab:	5b                   	pop    %ebx
80104aac:	5f                   	pop    %edi
80104aad:	5d                   	pop    %ebp
80104aae:	c3                   	ret    

80104aaf <stosl>:
{
80104aaf:	55                   	push   %ebp
80104ab0:	89 e5                	mov    %esp,%ebp
80104ab2:	57                   	push   %edi
80104ab3:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104ab4:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104ab7:	8b 55 10             	mov    0x10(%ebp),%edx
80104aba:	8b 45 0c             	mov    0xc(%ebp),%eax
80104abd:	89 cb                	mov    %ecx,%ebx
80104abf:	89 df                	mov    %ebx,%edi
80104ac1:	89 d1                	mov    %edx,%ecx
80104ac3:	fc                   	cld    
80104ac4:	f3 ab                	rep stos %eax,%es:(%edi)
80104ac6:	89 ca                	mov    %ecx,%edx
80104ac8:	89 fb                	mov    %edi,%ebx
80104aca:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104acd:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104ad0:	90                   	nop
80104ad1:	5b                   	pop    %ebx
80104ad2:	5f                   	pop    %edi
80104ad3:	5d                   	pop    %ebp
80104ad4:	c3                   	ret    

80104ad5 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104ad5:	55                   	push   %ebp
80104ad6:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104ad8:	8b 45 08             	mov    0x8(%ebp),%eax
80104adb:	83 e0 03             	and    $0x3,%eax
80104ade:	85 c0                	test   %eax,%eax
80104ae0:	75 43                	jne    80104b25 <memset+0x50>
80104ae2:	8b 45 10             	mov    0x10(%ebp),%eax
80104ae5:	83 e0 03             	and    $0x3,%eax
80104ae8:	85 c0                	test   %eax,%eax
80104aea:	75 39                	jne    80104b25 <memset+0x50>
    c &= 0xFF;
80104aec:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104af3:	8b 45 10             	mov    0x10(%ebp),%eax
80104af6:	c1 e8 02             	shr    $0x2,%eax
80104af9:	89 c2                	mov    %eax,%edx
80104afb:	8b 45 0c             	mov    0xc(%ebp),%eax
80104afe:	c1 e0 18             	shl    $0x18,%eax
80104b01:	89 c1                	mov    %eax,%ecx
80104b03:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b06:	c1 e0 10             	shl    $0x10,%eax
80104b09:	09 c1                	or     %eax,%ecx
80104b0b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b0e:	c1 e0 08             	shl    $0x8,%eax
80104b11:	09 c8                	or     %ecx,%eax
80104b13:	0b 45 0c             	or     0xc(%ebp),%eax
80104b16:	52                   	push   %edx
80104b17:	50                   	push   %eax
80104b18:	ff 75 08             	push   0x8(%ebp)
80104b1b:	e8 8f ff ff ff       	call   80104aaf <stosl>
80104b20:	83 c4 0c             	add    $0xc,%esp
80104b23:	eb 12                	jmp    80104b37 <memset+0x62>
  } else
    stosb(dst, c, n);
80104b25:	8b 45 10             	mov    0x10(%ebp),%eax
80104b28:	50                   	push   %eax
80104b29:	ff 75 0c             	push   0xc(%ebp)
80104b2c:	ff 75 08             	push   0x8(%ebp)
80104b2f:	e8 55 ff ff ff       	call   80104a89 <stosb>
80104b34:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104b37:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104b3a:	c9                   	leave  
80104b3b:	c3                   	ret    

80104b3c <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104b3c:	55                   	push   %ebp
80104b3d:	89 e5                	mov    %esp,%ebp
80104b3f:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104b42:	8b 45 08             	mov    0x8(%ebp),%eax
80104b45:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104b48:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b4b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104b4e:	eb 30                	jmp    80104b80 <memcmp+0x44>
    if(*s1 != *s2)
80104b50:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b53:	0f b6 10             	movzbl (%eax),%edx
80104b56:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104b59:	0f b6 00             	movzbl (%eax),%eax
80104b5c:	38 c2                	cmp    %al,%dl
80104b5e:	74 18                	je     80104b78 <memcmp+0x3c>
      return *s1 - *s2;
80104b60:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b63:	0f b6 00             	movzbl (%eax),%eax
80104b66:	0f b6 d0             	movzbl %al,%edx
80104b69:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104b6c:	0f b6 00             	movzbl (%eax),%eax
80104b6f:	0f b6 c8             	movzbl %al,%ecx
80104b72:	89 d0                	mov    %edx,%eax
80104b74:	29 c8                	sub    %ecx,%eax
80104b76:	eb 1a                	jmp    80104b92 <memcmp+0x56>
    s1++, s2++;
80104b78:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104b7c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104b80:	8b 45 10             	mov    0x10(%ebp),%eax
80104b83:	8d 50 ff             	lea    -0x1(%eax),%edx
80104b86:	89 55 10             	mov    %edx,0x10(%ebp)
80104b89:	85 c0                	test   %eax,%eax
80104b8b:	75 c3                	jne    80104b50 <memcmp+0x14>
  }

  return 0;
80104b8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b92:	c9                   	leave  
80104b93:	c3                   	ret    

80104b94 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104b94:	55                   	push   %ebp
80104b95:	89 e5                	mov    %esp,%ebp
80104b97:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104b9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b9d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104ba0:	8b 45 08             	mov    0x8(%ebp),%eax
80104ba3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104ba6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ba9:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104bac:	73 54                	jae    80104c02 <memmove+0x6e>
80104bae:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104bb1:	8b 45 10             	mov    0x10(%ebp),%eax
80104bb4:	01 d0                	add    %edx,%eax
80104bb6:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104bb9:	73 47                	jae    80104c02 <memmove+0x6e>
    s += n;
80104bbb:	8b 45 10             	mov    0x10(%ebp),%eax
80104bbe:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104bc1:	8b 45 10             	mov    0x10(%ebp),%eax
80104bc4:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104bc7:	eb 13                	jmp    80104bdc <memmove+0x48>
      *--d = *--s;
80104bc9:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104bcd:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104bd1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bd4:	0f b6 10             	movzbl (%eax),%edx
80104bd7:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104bda:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104bdc:	8b 45 10             	mov    0x10(%ebp),%eax
80104bdf:	8d 50 ff             	lea    -0x1(%eax),%edx
80104be2:	89 55 10             	mov    %edx,0x10(%ebp)
80104be5:	85 c0                	test   %eax,%eax
80104be7:	75 e0                	jne    80104bc9 <memmove+0x35>
  if(s < d && s + n > d){
80104be9:	eb 24                	jmp    80104c0f <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104beb:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104bee:	8d 42 01             	lea    0x1(%edx),%eax
80104bf1:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104bf4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104bf7:	8d 48 01             	lea    0x1(%eax),%ecx
80104bfa:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104bfd:	0f b6 12             	movzbl (%edx),%edx
80104c00:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104c02:	8b 45 10             	mov    0x10(%ebp),%eax
80104c05:	8d 50 ff             	lea    -0x1(%eax),%edx
80104c08:	89 55 10             	mov    %edx,0x10(%ebp)
80104c0b:	85 c0                	test   %eax,%eax
80104c0d:	75 dc                	jne    80104beb <memmove+0x57>

  return dst;
80104c0f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104c12:	c9                   	leave  
80104c13:	c3                   	ret    

80104c14 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104c14:	55                   	push   %ebp
80104c15:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104c17:	ff 75 10             	push   0x10(%ebp)
80104c1a:	ff 75 0c             	push   0xc(%ebp)
80104c1d:	ff 75 08             	push   0x8(%ebp)
80104c20:	e8 6f ff ff ff       	call   80104b94 <memmove>
80104c25:	83 c4 0c             	add    $0xc,%esp
}
80104c28:	c9                   	leave  
80104c29:	c3                   	ret    

80104c2a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104c2a:	55                   	push   %ebp
80104c2b:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104c2d:	eb 0c                	jmp    80104c3b <strncmp+0x11>
    n--, p++, q++;
80104c2f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104c33:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104c37:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104c3b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104c3f:	74 1a                	je     80104c5b <strncmp+0x31>
80104c41:	8b 45 08             	mov    0x8(%ebp),%eax
80104c44:	0f b6 00             	movzbl (%eax),%eax
80104c47:	84 c0                	test   %al,%al
80104c49:	74 10                	je     80104c5b <strncmp+0x31>
80104c4b:	8b 45 08             	mov    0x8(%ebp),%eax
80104c4e:	0f b6 10             	movzbl (%eax),%edx
80104c51:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c54:	0f b6 00             	movzbl (%eax),%eax
80104c57:	38 c2                	cmp    %al,%dl
80104c59:	74 d4                	je     80104c2f <strncmp+0x5>
  if(n == 0)
80104c5b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104c5f:	75 07                	jne    80104c68 <strncmp+0x3e>
    return 0;
80104c61:	b8 00 00 00 00       	mov    $0x0,%eax
80104c66:	eb 16                	jmp    80104c7e <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80104c68:	8b 45 08             	mov    0x8(%ebp),%eax
80104c6b:	0f b6 00             	movzbl (%eax),%eax
80104c6e:	0f b6 d0             	movzbl %al,%edx
80104c71:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c74:	0f b6 00             	movzbl (%eax),%eax
80104c77:	0f b6 c8             	movzbl %al,%ecx
80104c7a:	89 d0                	mov    %edx,%eax
80104c7c:	29 c8                	sub    %ecx,%eax
}
80104c7e:	5d                   	pop    %ebp
80104c7f:	c3                   	ret    

80104c80 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104c80:	55                   	push   %ebp
80104c81:	89 e5                	mov    %esp,%ebp
80104c83:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104c86:	8b 45 08             	mov    0x8(%ebp),%eax
80104c89:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104c8c:	90                   	nop
80104c8d:	8b 45 10             	mov    0x10(%ebp),%eax
80104c90:	8d 50 ff             	lea    -0x1(%eax),%edx
80104c93:	89 55 10             	mov    %edx,0x10(%ebp)
80104c96:	85 c0                	test   %eax,%eax
80104c98:	7e 2c                	jle    80104cc6 <strncpy+0x46>
80104c9a:	8b 55 0c             	mov    0xc(%ebp),%edx
80104c9d:	8d 42 01             	lea    0x1(%edx),%eax
80104ca0:	89 45 0c             	mov    %eax,0xc(%ebp)
80104ca3:	8b 45 08             	mov    0x8(%ebp),%eax
80104ca6:	8d 48 01             	lea    0x1(%eax),%ecx
80104ca9:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104cac:	0f b6 12             	movzbl (%edx),%edx
80104caf:	88 10                	mov    %dl,(%eax)
80104cb1:	0f b6 00             	movzbl (%eax),%eax
80104cb4:	84 c0                	test   %al,%al
80104cb6:	75 d5                	jne    80104c8d <strncpy+0xd>
    ;
  while(n-- > 0)
80104cb8:	eb 0c                	jmp    80104cc6 <strncpy+0x46>
    *s++ = 0;
80104cba:	8b 45 08             	mov    0x8(%ebp),%eax
80104cbd:	8d 50 01             	lea    0x1(%eax),%edx
80104cc0:	89 55 08             	mov    %edx,0x8(%ebp)
80104cc3:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104cc6:	8b 45 10             	mov    0x10(%ebp),%eax
80104cc9:	8d 50 ff             	lea    -0x1(%eax),%edx
80104ccc:	89 55 10             	mov    %edx,0x10(%ebp)
80104ccf:	85 c0                	test   %eax,%eax
80104cd1:	7f e7                	jg     80104cba <strncpy+0x3a>
  return os;
80104cd3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104cd6:	c9                   	leave  
80104cd7:	c3                   	ret    

80104cd8 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104cd8:	55                   	push   %ebp
80104cd9:	89 e5                	mov    %esp,%ebp
80104cdb:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104cde:	8b 45 08             	mov    0x8(%ebp),%eax
80104ce1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104ce4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104ce8:	7f 05                	jg     80104cef <safestrcpy+0x17>
    return os;
80104cea:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ced:	eb 32                	jmp    80104d21 <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80104cef:	90                   	nop
80104cf0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104cf4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104cf8:	7e 1e                	jle    80104d18 <safestrcpy+0x40>
80104cfa:	8b 55 0c             	mov    0xc(%ebp),%edx
80104cfd:	8d 42 01             	lea    0x1(%edx),%eax
80104d00:	89 45 0c             	mov    %eax,0xc(%ebp)
80104d03:	8b 45 08             	mov    0x8(%ebp),%eax
80104d06:	8d 48 01             	lea    0x1(%eax),%ecx
80104d09:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104d0c:	0f b6 12             	movzbl (%edx),%edx
80104d0f:	88 10                	mov    %dl,(%eax)
80104d11:	0f b6 00             	movzbl (%eax),%eax
80104d14:	84 c0                	test   %al,%al
80104d16:	75 d8                	jne    80104cf0 <safestrcpy+0x18>
    ;
  *s = 0;
80104d18:	8b 45 08             	mov    0x8(%ebp),%eax
80104d1b:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104d1e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d21:	c9                   	leave  
80104d22:	c3                   	ret    

80104d23 <strlen>:

int
strlen(const char *s)
{
80104d23:	55                   	push   %ebp
80104d24:	89 e5                	mov    %esp,%ebp
80104d26:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104d29:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104d30:	eb 04                	jmp    80104d36 <strlen+0x13>
80104d32:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104d36:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104d39:	8b 45 08             	mov    0x8(%ebp),%eax
80104d3c:	01 d0                	add    %edx,%eax
80104d3e:	0f b6 00             	movzbl (%eax),%eax
80104d41:	84 c0                	test   %al,%al
80104d43:	75 ed                	jne    80104d32 <strlen+0xf>
    ;
  return n;
80104d45:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d48:	c9                   	leave  
80104d49:	c3                   	ret    

80104d4a <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104d4a:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104d4e:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104d52:	55                   	push   %ebp
  pushl %ebx
80104d53:	53                   	push   %ebx
  pushl %esi
80104d54:	56                   	push   %esi
  pushl %edi
80104d55:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104d56:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104d58:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104d5a:	5f                   	pop    %edi
  popl %esi
80104d5b:	5e                   	pop    %esi
  popl %ebx
80104d5c:	5b                   	pop    %ebx
  popl %ebp
80104d5d:	5d                   	pop    %ebp
  ret
80104d5e:	c3                   	ret    

80104d5f <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104d5f:	55                   	push   %ebp
80104d60:	89 e5                	mov    %esp,%ebp
80104d62:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104d65:	e8 b9 ec ff ff       	call   80103a23 <myproc>
80104d6a:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104d6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d70:	8b 00                	mov    (%eax),%eax
80104d72:	39 45 08             	cmp    %eax,0x8(%ebp)
80104d75:	73 0f                	jae    80104d86 <fetchint+0x27>
80104d77:	8b 45 08             	mov    0x8(%ebp),%eax
80104d7a:	8d 50 04             	lea    0x4(%eax),%edx
80104d7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d80:	8b 00                	mov    (%eax),%eax
80104d82:	39 c2                	cmp    %eax,%edx
80104d84:	76 07                	jbe    80104d8d <fetchint+0x2e>
    return -1;
80104d86:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d8b:	eb 0f                	jmp    80104d9c <fetchint+0x3d>
  *ip = *(int*)(addr);
80104d8d:	8b 45 08             	mov    0x8(%ebp),%eax
80104d90:	8b 10                	mov    (%eax),%edx
80104d92:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d95:	89 10                	mov    %edx,(%eax)
  return 0;
80104d97:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d9c:	c9                   	leave  
80104d9d:	c3                   	ret    

80104d9e <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104d9e:	55                   	push   %ebp
80104d9f:	89 e5                	mov    %esp,%ebp
80104da1:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80104da4:	e8 7a ec ff ff       	call   80103a23 <myproc>
80104da9:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80104dac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104daf:	8b 00                	mov    (%eax),%eax
80104db1:	39 45 08             	cmp    %eax,0x8(%ebp)
80104db4:	72 07                	jb     80104dbd <fetchstr+0x1f>
    return -1;
80104db6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dbb:	eb 41                	jmp    80104dfe <fetchstr+0x60>
  *pp = (char*)addr;
80104dbd:	8b 55 08             	mov    0x8(%ebp),%edx
80104dc0:	8b 45 0c             	mov    0xc(%ebp),%eax
80104dc3:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80104dc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dc8:	8b 00                	mov    (%eax),%eax
80104dca:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80104dcd:	8b 45 0c             	mov    0xc(%ebp),%eax
80104dd0:	8b 00                	mov    (%eax),%eax
80104dd2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104dd5:	eb 1a                	jmp    80104df1 <fetchstr+0x53>
    if(*s == 0)
80104dd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dda:	0f b6 00             	movzbl (%eax),%eax
80104ddd:	84 c0                	test   %al,%al
80104ddf:	75 0c                	jne    80104ded <fetchstr+0x4f>
      return s - *pp;
80104de1:	8b 45 0c             	mov    0xc(%ebp),%eax
80104de4:	8b 10                	mov    (%eax),%edx
80104de6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104de9:	29 d0                	sub    %edx,%eax
80104deb:	eb 11                	jmp    80104dfe <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
80104ded:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104df1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104df4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104df7:	72 de                	jb     80104dd7 <fetchstr+0x39>
  }
  return -1;
80104df9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104dfe:	c9                   	leave  
80104dff:	c3                   	ret    

80104e00 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104e00:	55                   	push   %ebp
80104e01:	89 e5                	mov    %esp,%ebp
80104e03:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104e06:	e8 18 ec ff ff       	call   80103a23 <myproc>
80104e0b:	8b 40 18             	mov    0x18(%eax),%eax
80104e0e:	8b 50 44             	mov    0x44(%eax),%edx
80104e11:	8b 45 08             	mov    0x8(%ebp),%eax
80104e14:	c1 e0 02             	shl    $0x2,%eax
80104e17:	01 d0                	add    %edx,%eax
80104e19:	83 c0 04             	add    $0x4,%eax
80104e1c:	83 ec 08             	sub    $0x8,%esp
80104e1f:	ff 75 0c             	push   0xc(%ebp)
80104e22:	50                   	push   %eax
80104e23:	e8 37 ff ff ff       	call   80104d5f <fetchint>
80104e28:	83 c4 10             	add    $0x10,%esp
}
80104e2b:	c9                   	leave  
80104e2c:	c3                   	ret    

80104e2d <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104e2d:	55                   	push   %ebp
80104e2e:	89 e5                	mov    %esp,%ebp
80104e30:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80104e33:	e8 eb eb ff ff       	call   80103a23 <myproc>
80104e38:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80104e3b:	83 ec 08             	sub    $0x8,%esp
80104e3e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104e41:	50                   	push   %eax
80104e42:	ff 75 08             	push   0x8(%ebp)
80104e45:	e8 b6 ff ff ff       	call   80104e00 <argint>
80104e4a:	83 c4 10             	add    $0x10,%esp
80104e4d:	85 c0                	test   %eax,%eax
80104e4f:	79 07                	jns    80104e58 <argptr+0x2b>
    return -1;
80104e51:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e56:	eb 3b                	jmp    80104e93 <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104e58:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104e5c:	78 1f                	js     80104e7d <argptr+0x50>
80104e5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e61:	8b 00                	mov    (%eax),%eax
80104e63:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104e66:	39 d0                	cmp    %edx,%eax
80104e68:	76 13                	jbe    80104e7d <argptr+0x50>
80104e6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e6d:	89 c2                	mov    %eax,%edx
80104e6f:	8b 45 10             	mov    0x10(%ebp),%eax
80104e72:	01 c2                	add    %eax,%edx
80104e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e77:	8b 00                	mov    (%eax),%eax
80104e79:	39 c2                	cmp    %eax,%edx
80104e7b:	76 07                	jbe    80104e84 <argptr+0x57>
    return -1;
80104e7d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e82:	eb 0f                	jmp    80104e93 <argptr+0x66>
  *pp = (char*)i;
80104e84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e87:	89 c2                	mov    %eax,%edx
80104e89:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e8c:	89 10                	mov    %edx,(%eax)
  return 0;
80104e8e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e93:	c9                   	leave  
80104e94:	c3                   	ret    

80104e95 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104e95:	55                   	push   %ebp
80104e96:	89 e5                	mov    %esp,%ebp
80104e98:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104e9b:	83 ec 08             	sub    $0x8,%esp
80104e9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104ea1:	50                   	push   %eax
80104ea2:	ff 75 08             	push   0x8(%ebp)
80104ea5:	e8 56 ff ff ff       	call   80104e00 <argint>
80104eaa:	83 c4 10             	add    $0x10,%esp
80104ead:	85 c0                	test   %eax,%eax
80104eaf:	79 07                	jns    80104eb8 <argstr+0x23>
    return -1;
80104eb1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104eb6:	eb 12                	jmp    80104eca <argstr+0x35>
  return fetchstr(addr, pp);
80104eb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ebb:	83 ec 08             	sub    $0x8,%esp
80104ebe:	ff 75 0c             	push   0xc(%ebp)
80104ec1:	50                   	push   %eax
80104ec2:	e8 d7 fe ff ff       	call   80104d9e <fetchstr>
80104ec7:	83 c4 10             	add    $0x10,%esp
}
80104eca:	c9                   	leave  
80104ecb:	c3                   	ret    

80104ecc <syscall>:
[SYS_printpt] sys_printpt,
};

void
syscall(void)
{
80104ecc:	55                   	push   %ebp
80104ecd:	89 e5                	mov    %esp,%ebp
80104ecf:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80104ed2:	e8 4c eb ff ff       	call   80103a23 <myproc>
80104ed7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80104eda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104edd:	8b 40 18             	mov    0x18(%eax),%eax
80104ee0:	8b 40 1c             	mov    0x1c(%eax),%eax
80104ee3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104ee6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104eea:	7e 2f                	jle    80104f1b <syscall+0x4f>
80104eec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104eef:	83 f8 16             	cmp    $0x16,%eax
80104ef2:	77 27                	ja     80104f1b <syscall+0x4f>
80104ef4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ef7:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104efe:	85 c0                	test   %eax,%eax
80104f00:	74 19                	je     80104f1b <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80104f02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f05:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104f0c:	ff d0                	call   *%eax
80104f0e:	89 c2                	mov    %eax,%edx
80104f10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f13:	8b 40 18             	mov    0x18(%eax),%eax
80104f16:	89 50 1c             	mov    %edx,0x1c(%eax)
80104f19:	eb 2c                	jmp    80104f47 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80104f1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f1e:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104f21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f24:	8b 40 10             	mov    0x10(%eax),%eax
80104f27:	ff 75 f0             	push   -0x10(%ebp)
80104f2a:	52                   	push   %edx
80104f2b:	50                   	push   %eax
80104f2c:	68 3d a5 10 80       	push   $0x8010a53d
80104f31:	e8 be b4 ff ff       	call   801003f4 <cprintf>
80104f36:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80104f39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f3c:	8b 40 18             	mov    0x18(%eax),%eax
80104f3f:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80104f46:	90                   	nop
80104f47:	90                   	nop
80104f48:	c9                   	leave  
80104f49:	c3                   	ret    

80104f4a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104f4a:	55                   	push   %ebp
80104f4b:	89 e5                	mov    %esp,%ebp
80104f4d:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104f50:	83 ec 08             	sub    $0x8,%esp
80104f53:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104f56:	50                   	push   %eax
80104f57:	ff 75 08             	push   0x8(%ebp)
80104f5a:	e8 a1 fe ff ff       	call   80104e00 <argint>
80104f5f:	83 c4 10             	add    $0x10,%esp
80104f62:	85 c0                	test   %eax,%eax
80104f64:	79 07                	jns    80104f6d <argfd+0x23>
    return -1;
80104f66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f6b:	eb 4f                	jmp    80104fbc <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104f6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f70:	85 c0                	test   %eax,%eax
80104f72:	78 20                	js     80104f94 <argfd+0x4a>
80104f74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f77:	83 f8 0f             	cmp    $0xf,%eax
80104f7a:	7f 18                	jg     80104f94 <argfd+0x4a>
80104f7c:	e8 a2 ea ff ff       	call   80103a23 <myproc>
80104f81:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f84:	83 c2 08             	add    $0x8,%edx
80104f87:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104f8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104f8e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104f92:	75 07                	jne    80104f9b <argfd+0x51>
    return -1;
80104f94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f99:	eb 21                	jmp    80104fbc <argfd+0x72>
  if(pfd)
80104f9b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104f9f:	74 08                	je     80104fa9 <argfd+0x5f>
    *pfd = fd;
80104fa1:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104fa4:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fa7:	89 10                	mov    %edx,(%eax)
  if(pf)
80104fa9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104fad:	74 08                	je     80104fb7 <argfd+0x6d>
    *pf = f;
80104faf:	8b 45 10             	mov    0x10(%ebp),%eax
80104fb2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104fb5:	89 10                	mov    %edx,(%eax)
  return 0;
80104fb7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104fbc:	c9                   	leave  
80104fbd:	c3                   	ret    

80104fbe <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80104fbe:	55                   	push   %ebp
80104fbf:	89 e5                	mov    %esp,%ebp
80104fc1:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80104fc4:	e8 5a ea ff ff       	call   80103a23 <myproc>
80104fc9:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80104fcc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104fd3:	eb 2a                	jmp    80104fff <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80104fd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fd8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104fdb:	83 c2 08             	add    $0x8,%edx
80104fde:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104fe2:	85 c0                	test   %eax,%eax
80104fe4:	75 15                	jne    80104ffb <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80104fe6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fe9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104fec:	8d 4a 08             	lea    0x8(%edx),%ecx
80104fef:	8b 55 08             	mov    0x8(%ebp),%edx
80104ff2:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80104ff6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ff9:	eb 0f                	jmp    8010500a <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
80104ffb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104fff:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105003:	7e d0                	jle    80104fd5 <fdalloc+0x17>
    }
  }
  return -1;
80105005:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010500a:	c9                   	leave  
8010500b:	c3                   	ret    

8010500c <sys_dup>:

int
sys_dup(void)
{
8010500c:	55                   	push   %ebp
8010500d:	89 e5                	mov    %esp,%ebp
8010500f:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105012:	83 ec 04             	sub    $0x4,%esp
80105015:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105018:	50                   	push   %eax
80105019:	6a 00                	push   $0x0
8010501b:	6a 00                	push   $0x0
8010501d:	e8 28 ff ff ff       	call   80104f4a <argfd>
80105022:	83 c4 10             	add    $0x10,%esp
80105025:	85 c0                	test   %eax,%eax
80105027:	79 07                	jns    80105030 <sys_dup+0x24>
    return -1;
80105029:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010502e:	eb 31                	jmp    80105061 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105030:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105033:	83 ec 0c             	sub    $0xc,%esp
80105036:	50                   	push   %eax
80105037:	e8 82 ff ff ff       	call   80104fbe <fdalloc>
8010503c:	83 c4 10             	add    $0x10,%esp
8010503f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105042:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105046:	79 07                	jns    8010504f <sys_dup+0x43>
    return -1;
80105048:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010504d:	eb 12                	jmp    80105061 <sys_dup+0x55>
  filedup(f);
8010504f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105052:	83 ec 0c             	sub    $0xc,%esp
80105055:	50                   	push   %eax
80105056:	e8 e2 bf ff ff       	call   8010103d <filedup>
8010505b:	83 c4 10             	add    $0x10,%esp
  return fd;
8010505e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105061:	c9                   	leave  
80105062:	c3                   	ret    

80105063 <sys_read>:

int
sys_read(void)
{
80105063:	55                   	push   %ebp
80105064:	89 e5                	mov    %esp,%ebp
80105066:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105069:	83 ec 04             	sub    $0x4,%esp
8010506c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010506f:	50                   	push   %eax
80105070:	6a 00                	push   $0x0
80105072:	6a 00                	push   $0x0
80105074:	e8 d1 fe ff ff       	call   80104f4a <argfd>
80105079:	83 c4 10             	add    $0x10,%esp
8010507c:	85 c0                	test   %eax,%eax
8010507e:	78 2e                	js     801050ae <sys_read+0x4b>
80105080:	83 ec 08             	sub    $0x8,%esp
80105083:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105086:	50                   	push   %eax
80105087:	6a 02                	push   $0x2
80105089:	e8 72 fd ff ff       	call   80104e00 <argint>
8010508e:	83 c4 10             	add    $0x10,%esp
80105091:	85 c0                	test   %eax,%eax
80105093:	78 19                	js     801050ae <sys_read+0x4b>
80105095:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105098:	83 ec 04             	sub    $0x4,%esp
8010509b:	50                   	push   %eax
8010509c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010509f:	50                   	push   %eax
801050a0:	6a 01                	push   $0x1
801050a2:	e8 86 fd ff ff       	call   80104e2d <argptr>
801050a7:	83 c4 10             	add    $0x10,%esp
801050aa:	85 c0                	test   %eax,%eax
801050ac:	79 07                	jns    801050b5 <sys_read+0x52>
    return -1;
801050ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050b3:	eb 17                	jmp    801050cc <sys_read+0x69>
  return fileread(f, p, n);
801050b5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801050b8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801050bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050be:	83 ec 04             	sub    $0x4,%esp
801050c1:	51                   	push   %ecx
801050c2:	52                   	push   %edx
801050c3:	50                   	push   %eax
801050c4:	e8 04 c1 ff ff       	call   801011cd <fileread>
801050c9:	83 c4 10             	add    $0x10,%esp
}
801050cc:	c9                   	leave  
801050cd:	c3                   	ret    

801050ce <sys_write>:

int
sys_write(void)
{
801050ce:	55                   	push   %ebp
801050cf:	89 e5                	mov    %esp,%ebp
801050d1:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801050d4:	83 ec 04             	sub    $0x4,%esp
801050d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801050da:	50                   	push   %eax
801050db:	6a 00                	push   $0x0
801050dd:	6a 00                	push   $0x0
801050df:	e8 66 fe ff ff       	call   80104f4a <argfd>
801050e4:	83 c4 10             	add    $0x10,%esp
801050e7:	85 c0                	test   %eax,%eax
801050e9:	78 2e                	js     80105119 <sys_write+0x4b>
801050eb:	83 ec 08             	sub    $0x8,%esp
801050ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
801050f1:	50                   	push   %eax
801050f2:	6a 02                	push   $0x2
801050f4:	e8 07 fd ff ff       	call   80104e00 <argint>
801050f9:	83 c4 10             	add    $0x10,%esp
801050fc:	85 c0                	test   %eax,%eax
801050fe:	78 19                	js     80105119 <sys_write+0x4b>
80105100:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105103:	83 ec 04             	sub    $0x4,%esp
80105106:	50                   	push   %eax
80105107:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010510a:	50                   	push   %eax
8010510b:	6a 01                	push   $0x1
8010510d:	e8 1b fd ff ff       	call   80104e2d <argptr>
80105112:	83 c4 10             	add    $0x10,%esp
80105115:	85 c0                	test   %eax,%eax
80105117:	79 07                	jns    80105120 <sys_write+0x52>
    return -1;
80105119:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010511e:	eb 17                	jmp    80105137 <sys_write+0x69>
  return filewrite(f, p, n);
80105120:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105123:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105129:	83 ec 04             	sub    $0x4,%esp
8010512c:	51                   	push   %ecx
8010512d:	52                   	push   %edx
8010512e:	50                   	push   %eax
8010512f:	e8 51 c1 ff ff       	call   80101285 <filewrite>
80105134:	83 c4 10             	add    $0x10,%esp
}
80105137:	c9                   	leave  
80105138:	c3                   	ret    

80105139 <sys_close>:

int
sys_close(void)
{
80105139:	55                   	push   %ebp
8010513a:	89 e5                	mov    %esp,%ebp
8010513c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
8010513f:	83 ec 04             	sub    $0x4,%esp
80105142:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105145:	50                   	push   %eax
80105146:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105149:	50                   	push   %eax
8010514a:	6a 00                	push   $0x0
8010514c:	e8 f9 fd ff ff       	call   80104f4a <argfd>
80105151:	83 c4 10             	add    $0x10,%esp
80105154:	85 c0                	test   %eax,%eax
80105156:	79 07                	jns    8010515f <sys_close+0x26>
    return -1;
80105158:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010515d:	eb 27                	jmp    80105186 <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
8010515f:	e8 bf e8 ff ff       	call   80103a23 <myproc>
80105164:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105167:	83 c2 08             	add    $0x8,%edx
8010516a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105171:	00 
  fileclose(f);
80105172:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105175:	83 ec 0c             	sub    $0xc,%esp
80105178:	50                   	push   %eax
80105179:	e8 10 bf ff ff       	call   8010108e <fileclose>
8010517e:	83 c4 10             	add    $0x10,%esp
  return 0;
80105181:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105186:	c9                   	leave  
80105187:	c3                   	ret    

80105188 <sys_fstat>:

int
sys_fstat(void)
{
80105188:	55                   	push   %ebp
80105189:	89 e5                	mov    %esp,%ebp
8010518b:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010518e:	83 ec 04             	sub    $0x4,%esp
80105191:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105194:	50                   	push   %eax
80105195:	6a 00                	push   $0x0
80105197:	6a 00                	push   $0x0
80105199:	e8 ac fd ff ff       	call   80104f4a <argfd>
8010519e:	83 c4 10             	add    $0x10,%esp
801051a1:	85 c0                	test   %eax,%eax
801051a3:	78 17                	js     801051bc <sys_fstat+0x34>
801051a5:	83 ec 04             	sub    $0x4,%esp
801051a8:	6a 14                	push   $0x14
801051aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
801051ad:	50                   	push   %eax
801051ae:	6a 01                	push   $0x1
801051b0:	e8 78 fc ff ff       	call   80104e2d <argptr>
801051b5:	83 c4 10             	add    $0x10,%esp
801051b8:	85 c0                	test   %eax,%eax
801051ba:	79 07                	jns    801051c3 <sys_fstat+0x3b>
    return -1;
801051bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051c1:	eb 13                	jmp    801051d6 <sys_fstat+0x4e>
  return filestat(f, st);
801051c3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801051c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051c9:	83 ec 08             	sub    $0x8,%esp
801051cc:	52                   	push   %edx
801051cd:	50                   	push   %eax
801051ce:	e8 a3 bf ff ff       	call   80101176 <filestat>
801051d3:	83 c4 10             	add    $0x10,%esp
}
801051d6:	c9                   	leave  
801051d7:	c3                   	ret    

801051d8 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801051d8:	55                   	push   %ebp
801051d9:	89 e5                	mov    %esp,%ebp
801051db:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801051de:	83 ec 08             	sub    $0x8,%esp
801051e1:	8d 45 d8             	lea    -0x28(%ebp),%eax
801051e4:	50                   	push   %eax
801051e5:	6a 00                	push   $0x0
801051e7:	e8 a9 fc ff ff       	call   80104e95 <argstr>
801051ec:	83 c4 10             	add    $0x10,%esp
801051ef:	85 c0                	test   %eax,%eax
801051f1:	78 15                	js     80105208 <sys_link+0x30>
801051f3:	83 ec 08             	sub    $0x8,%esp
801051f6:	8d 45 dc             	lea    -0x24(%ebp),%eax
801051f9:	50                   	push   %eax
801051fa:	6a 01                	push   $0x1
801051fc:	e8 94 fc ff ff       	call   80104e95 <argstr>
80105201:	83 c4 10             	add    $0x10,%esp
80105204:	85 c0                	test   %eax,%eax
80105206:	79 0a                	jns    80105212 <sys_link+0x3a>
    return -1;
80105208:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010520d:	e9 68 01 00 00       	jmp    8010537a <sys_link+0x1a2>

  begin_op();
80105212:	e8 18 de ff ff       	call   8010302f <begin_op>
  if((ip = namei(old)) == 0){
80105217:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010521a:	83 ec 0c             	sub    $0xc,%esp
8010521d:	50                   	push   %eax
8010521e:	e8 ed d2 ff ff       	call   80102510 <namei>
80105223:	83 c4 10             	add    $0x10,%esp
80105226:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105229:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010522d:	75 0f                	jne    8010523e <sys_link+0x66>
    end_op();
8010522f:	e8 87 de ff ff       	call   801030bb <end_op>
    return -1;
80105234:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105239:	e9 3c 01 00 00       	jmp    8010537a <sys_link+0x1a2>
  }

  ilock(ip);
8010523e:	83 ec 0c             	sub    $0xc,%esp
80105241:	ff 75 f4             	push   -0xc(%ebp)
80105244:	e8 94 c7 ff ff       	call   801019dd <ilock>
80105249:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
8010524c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010524f:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105253:	66 83 f8 01          	cmp    $0x1,%ax
80105257:	75 1d                	jne    80105276 <sys_link+0x9e>
    iunlockput(ip);
80105259:	83 ec 0c             	sub    $0xc,%esp
8010525c:	ff 75 f4             	push   -0xc(%ebp)
8010525f:	e8 aa c9 ff ff       	call   80101c0e <iunlockput>
80105264:	83 c4 10             	add    $0x10,%esp
    end_op();
80105267:	e8 4f de ff ff       	call   801030bb <end_op>
    return -1;
8010526c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105271:	e9 04 01 00 00       	jmp    8010537a <sys_link+0x1a2>
  }

  ip->nlink++;
80105276:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105279:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010527d:	83 c0 01             	add    $0x1,%eax
80105280:	89 c2                	mov    %eax,%edx
80105282:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105285:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105289:	83 ec 0c             	sub    $0xc,%esp
8010528c:	ff 75 f4             	push   -0xc(%ebp)
8010528f:	e8 6c c5 ff ff       	call   80101800 <iupdate>
80105294:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105297:	83 ec 0c             	sub    $0xc,%esp
8010529a:	ff 75 f4             	push   -0xc(%ebp)
8010529d:	e8 4e c8 ff ff       	call   80101af0 <iunlock>
801052a2:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
801052a5:	8b 45 dc             	mov    -0x24(%ebp),%eax
801052a8:	83 ec 08             	sub    $0x8,%esp
801052ab:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801052ae:	52                   	push   %edx
801052af:	50                   	push   %eax
801052b0:	e8 77 d2 ff ff       	call   8010252c <nameiparent>
801052b5:	83 c4 10             	add    $0x10,%esp
801052b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801052bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801052bf:	74 71                	je     80105332 <sys_link+0x15a>
    goto bad;
  ilock(dp);
801052c1:	83 ec 0c             	sub    $0xc,%esp
801052c4:	ff 75 f0             	push   -0x10(%ebp)
801052c7:	e8 11 c7 ff ff       	call   801019dd <ilock>
801052cc:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801052cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052d2:	8b 10                	mov    (%eax),%edx
801052d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052d7:	8b 00                	mov    (%eax),%eax
801052d9:	39 c2                	cmp    %eax,%edx
801052db:	75 1d                	jne    801052fa <sys_link+0x122>
801052dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052e0:	8b 40 04             	mov    0x4(%eax),%eax
801052e3:	83 ec 04             	sub    $0x4,%esp
801052e6:	50                   	push   %eax
801052e7:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801052ea:	50                   	push   %eax
801052eb:	ff 75 f0             	push   -0x10(%ebp)
801052ee:	e8 86 cf ff ff       	call   80102279 <dirlink>
801052f3:	83 c4 10             	add    $0x10,%esp
801052f6:	85 c0                	test   %eax,%eax
801052f8:	79 10                	jns    8010530a <sys_link+0x132>
    iunlockput(dp);
801052fa:	83 ec 0c             	sub    $0xc,%esp
801052fd:	ff 75 f0             	push   -0x10(%ebp)
80105300:	e8 09 c9 ff ff       	call   80101c0e <iunlockput>
80105305:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105308:	eb 29                	jmp    80105333 <sys_link+0x15b>
  }
  iunlockput(dp);
8010530a:	83 ec 0c             	sub    $0xc,%esp
8010530d:	ff 75 f0             	push   -0x10(%ebp)
80105310:	e8 f9 c8 ff ff       	call   80101c0e <iunlockput>
80105315:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105318:	83 ec 0c             	sub    $0xc,%esp
8010531b:	ff 75 f4             	push   -0xc(%ebp)
8010531e:	e8 1b c8 ff ff       	call   80101b3e <iput>
80105323:	83 c4 10             	add    $0x10,%esp

  end_op();
80105326:	e8 90 dd ff ff       	call   801030bb <end_op>

  return 0;
8010532b:	b8 00 00 00 00       	mov    $0x0,%eax
80105330:	eb 48                	jmp    8010537a <sys_link+0x1a2>
    goto bad;
80105332:	90                   	nop

bad:
  ilock(ip);
80105333:	83 ec 0c             	sub    $0xc,%esp
80105336:	ff 75 f4             	push   -0xc(%ebp)
80105339:	e8 9f c6 ff ff       	call   801019dd <ilock>
8010533e:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105341:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105344:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105348:	83 e8 01             	sub    $0x1,%eax
8010534b:	89 c2                	mov    %eax,%edx
8010534d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105350:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105354:	83 ec 0c             	sub    $0xc,%esp
80105357:	ff 75 f4             	push   -0xc(%ebp)
8010535a:	e8 a1 c4 ff ff       	call   80101800 <iupdate>
8010535f:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105362:	83 ec 0c             	sub    $0xc,%esp
80105365:	ff 75 f4             	push   -0xc(%ebp)
80105368:	e8 a1 c8 ff ff       	call   80101c0e <iunlockput>
8010536d:	83 c4 10             	add    $0x10,%esp
  end_op();
80105370:	e8 46 dd ff ff       	call   801030bb <end_op>
  return -1;
80105375:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010537a:	c9                   	leave  
8010537b:	c3                   	ret    

8010537c <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010537c:	55                   	push   %ebp
8010537d:	89 e5                	mov    %esp,%ebp
8010537f:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105382:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105389:	eb 40                	jmp    801053cb <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010538b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010538e:	6a 10                	push   $0x10
80105390:	50                   	push   %eax
80105391:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105394:	50                   	push   %eax
80105395:	ff 75 08             	push   0x8(%ebp)
80105398:	e8 2c cb ff ff       	call   80101ec9 <readi>
8010539d:	83 c4 10             	add    $0x10,%esp
801053a0:	83 f8 10             	cmp    $0x10,%eax
801053a3:	74 0d                	je     801053b2 <isdirempty+0x36>
      panic("isdirempty: readi");
801053a5:	83 ec 0c             	sub    $0xc,%esp
801053a8:	68 59 a5 10 80       	push   $0x8010a559
801053ad:	e8 f7 b1 ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
801053b2:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801053b6:	66 85 c0             	test   %ax,%ax
801053b9:	74 07                	je     801053c2 <isdirempty+0x46>
      return 0;
801053bb:	b8 00 00 00 00       	mov    $0x0,%eax
801053c0:	eb 1b                	jmp    801053dd <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801053c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053c5:	83 c0 10             	add    $0x10,%eax
801053c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801053cb:	8b 45 08             	mov    0x8(%ebp),%eax
801053ce:	8b 50 58             	mov    0x58(%eax),%edx
801053d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053d4:	39 c2                	cmp    %eax,%edx
801053d6:	77 b3                	ja     8010538b <isdirempty+0xf>
  }
  return 1;
801053d8:	b8 01 00 00 00       	mov    $0x1,%eax
}
801053dd:	c9                   	leave  
801053de:	c3                   	ret    

801053df <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801053df:	55                   	push   %ebp
801053e0:	89 e5                	mov    %esp,%ebp
801053e2:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801053e5:	83 ec 08             	sub    $0x8,%esp
801053e8:	8d 45 cc             	lea    -0x34(%ebp),%eax
801053eb:	50                   	push   %eax
801053ec:	6a 00                	push   $0x0
801053ee:	e8 a2 fa ff ff       	call   80104e95 <argstr>
801053f3:	83 c4 10             	add    $0x10,%esp
801053f6:	85 c0                	test   %eax,%eax
801053f8:	79 0a                	jns    80105404 <sys_unlink+0x25>
    return -1;
801053fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053ff:	e9 bf 01 00 00       	jmp    801055c3 <sys_unlink+0x1e4>

  begin_op();
80105404:	e8 26 dc ff ff       	call   8010302f <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105409:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010540c:	83 ec 08             	sub    $0x8,%esp
8010540f:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105412:	52                   	push   %edx
80105413:	50                   	push   %eax
80105414:	e8 13 d1 ff ff       	call   8010252c <nameiparent>
80105419:	83 c4 10             	add    $0x10,%esp
8010541c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010541f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105423:	75 0f                	jne    80105434 <sys_unlink+0x55>
    end_op();
80105425:	e8 91 dc ff ff       	call   801030bb <end_op>
    return -1;
8010542a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010542f:	e9 8f 01 00 00       	jmp    801055c3 <sys_unlink+0x1e4>
  }

  ilock(dp);
80105434:	83 ec 0c             	sub    $0xc,%esp
80105437:	ff 75 f4             	push   -0xc(%ebp)
8010543a:	e8 9e c5 ff ff       	call   801019dd <ilock>
8010543f:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105442:	83 ec 08             	sub    $0x8,%esp
80105445:	68 6b a5 10 80       	push   $0x8010a56b
8010544a:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010544d:	50                   	push   %eax
8010544e:	e8 51 cd ff ff       	call   801021a4 <namecmp>
80105453:	83 c4 10             	add    $0x10,%esp
80105456:	85 c0                	test   %eax,%eax
80105458:	0f 84 49 01 00 00    	je     801055a7 <sys_unlink+0x1c8>
8010545e:	83 ec 08             	sub    $0x8,%esp
80105461:	68 6d a5 10 80       	push   $0x8010a56d
80105466:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105469:	50                   	push   %eax
8010546a:	e8 35 cd ff ff       	call   801021a4 <namecmp>
8010546f:	83 c4 10             	add    $0x10,%esp
80105472:	85 c0                	test   %eax,%eax
80105474:	0f 84 2d 01 00 00    	je     801055a7 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
8010547a:	83 ec 04             	sub    $0x4,%esp
8010547d:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105480:	50                   	push   %eax
80105481:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105484:	50                   	push   %eax
80105485:	ff 75 f4             	push   -0xc(%ebp)
80105488:	e8 32 cd ff ff       	call   801021bf <dirlookup>
8010548d:	83 c4 10             	add    $0x10,%esp
80105490:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105493:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105497:	0f 84 0d 01 00 00    	je     801055aa <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
8010549d:	83 ec 0c             	sub    $0xc,%esp
801054a0:	ff 75 f0             	push   -0x10(%ebp)
801054a3:	e8 35 c5 ff ff       	call   801019dd <ilock>
801054a8:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
801054ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054ae:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801054b2:	66 85 c0             	test   %ax,%ax
801054b5:	7f 0d                	jg     801054c4 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
801054b7:	83 ec 0c             	sub    $0xc,%esp
801054ba:	68 70 a5 10 80       	push   $0x8010a570
801054bf:	e8 e5 b0 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801054c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054c7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801054cb:	66 83 f8 01          	cmp    $0x1,%ax
801054cf:	75 25                	jne    801054f6 <sys_unlink+0x117>
801054d1:	83 ec 0c             	sub    $0xc,%esp
801054d4:	ff 75 f0             	push   -0x10(%ebp)
801054d7:	e8 a0 fe ff ff       	call   8010537c <isdirempty>
801054dc:	83 c4 10             	add    $0x10,%esp
801054df:	85 c0                	test   %eax,%eax
801054e1:	75 13                	jne    801054f6 <sys_unlink+0x117>
    iunlockput(ip);
801054e3:	83 ec 0c             	sub    $0xc,%esp
801054e6:	ff 75 f0             	push   -0x10(%ebp)
801054e9:	e8 20 c7 ff ff       	call   80101c0e <iunlockput>
801054ee:	83 c4 10             	add    $0x10,%esp
    goto bad;
801054f1:	e9 b5 00 00 00       	jmp    801055ab <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
801054f6:	83 ec 04             	sub    $0x4,%esp
801054f9:	6a 10                	push   $0x10
801054fb:	6a 00                	push   $0x0
801054fd:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105500:	50                   	push   %eax
80105501:	e8 cf f5 ff ff       	call   80104ad5 <memset>
80105506:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105509:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010550c:	6a 10                	push   $0x10
8010550e:	50                   	push   %eax
8010550f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105512:	50                   	push   %eax
80105513:	ff 75 f4             	push   -0xc(%ebp)
80105516:	e8 03 cb ff ff       	call   8010201e <writei>
8010551b:	83 c4 10             	add    $0x10,%esp
8010551e:	83 f8 10             	cmp    $0x10,%eax
80105521:	74 0d                	je     80105530 <sys_unlink+0x151>
    panic("unlink: writei");
80105523:	83 ec 0c             	sub    $0xc,%esp
80105526:	68 82 a5 10 80       	push   $0x8010a582
8010552b:	e8 79 b0 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
80105530:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105533:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105537:	66 83 f8 01          	cmp    $0x1,%ax
8010553b:	75 21                	jne    8010555e <sys_unlink+0x17f>
    dp->nlink--;
8010553d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105540:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105544:	83 e8 01             	sub    $0x1,%eax
80105547:	89 c2                	mov    %eax,%edx
80105549:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010554c:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105550:	83 ec 0c             	sub    $0xc,%esp
80105553:	ff 75 f4             	push   -0xc(%ebp)
80105556:	e8 a5 c2 ff ff       	call   80101800 <iupdate>
8010555b:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
8010555e:	83 ec 0c             	sub    $0xc,%esp
80105561:	ff 75 f4             	push   -0xc(%ebp)
80105564:	e8 a5 c6 ff ff       	call   80101c0e <iunlockput>
80105569:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
8010556c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010556f:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105573:	83 e8 01             	sub    $0x1,%eax
80105576:	89 c2                	mov    %eax,%edx
80105578:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010557b:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010557f:	83 ec 0c             	sub    $0xc,%esp
80105582:	ff 75 f0             	push   -0x10(%ebp)
80105585:	e8 76 c2 ff ff       	call   80101800 <iupdate>
8010558a:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010558d:	83 ec 0c             	sub    $0xc,%esp
80105590:	ff 75 f0             	push   -0x10(%ebp)
80105593:	e8 76 c6 ff ff       	call   80101c0e <iunlockput>
80105598:	83 c4 10             	add    $0x10,%esp

  end_op();
8010559b:	e8 1b db ff ff       	call   801030bb <end_op>

  return 0;
801055a0:	b8 00 00 00 00       	mov    $0x0,%eax
801055a5:	eb 1c                	jmp    801055c3 <sys_unlink+0x1e4>
    goto bad;
801055a7:	90                   	nop
801055a8:	eb 01                	jmp    801055ab <sys_unlink+0x1cc>
    goto bad;
801055aa:	90                   	nop

bad:
  iunlockput(dp);
801055ab:	83 ec 0c             	sub    $0xc,%esp
801055ae:	ff 75 f4             	push   -0xc(%ebp)
801055b1:	e8 58 c6 ff ff       	call   80101c0e <iunlockput>
801055b6:	83 c4 10             	add    $0x10,%esp
  end_op();
801055b9:	e8 fd da ff ff       	call   801030bb <end_op>
  return -1;
801055be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801055c3:	c9                   	leave  
801055c4:	c3                   	ret    

801055c5 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801055c5:	55                   	push   %ebp
801055c6:	89 e5                	mov    %esp,%ebp
801055c8:	83 ec 38             	sub    $0x38,%esp
801055cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801055ce:	8b 55 10             	mov    0x10(%ebp),%edx
801055d1:	8b 45 14             	mov    0x14(%ebp),%eax
801055d4:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801055d8:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801055dc:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801055e0:	83 ec 08             	sub    $0x8,%esp
801055e3:	8d 45 de             	lea    -0x22(%ebp),%eax
801055e6:	50                   	push   %eax
801055e7:	ff 75 08             	push   0x8(%ebp)
801055ea:	e8 3d cf ff ff       	call   8010252c <nameiparent>
801055ef:	83 c4 10             	add    $0x10,%esp
801055f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801055f5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801055f9:	75 0a                	jne    80105605 <create+0x40>
    return 0;
801055fb:	b8 00 00 00 00       	mov    $0x0,%eax
80105600:	e9 90 01 00 00       	jmp    80105795 <create+0x1d0>
  ilock(dp);
80105605:	83 ec 0c             	sub    $0xc,%esp
80105608:	ff 75 f4             	push   -0xc(%ebp)
8010560b:	e8 cd c3 ff ff       	call   801019dd <ilock>
80105610:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105613:	83 ec 04             	sub    $0x4,%esp
80105616:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105619:	50                   	push   %eax
8010561a:	8d 45 de             	lea    -0x22(%ebp),%eax
8010561d:	50                   	push   %eax
8010561e:	ff 75 f4             	push   -0xc(%ebp)
80105621:	e8 99 cb ff ff       	call   801021bf <dirlookup>
80105626:	83 c4 10             	add    $0x10,%esp
80105629:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010562c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105630:	74 50                	je     80105682 <create+0xbd>
    iunlockput(dp);
80105632:	83 ec 0c             	sub    $0xc,%esp
80105635:	ff 75 f4             	push   -0xc(%ebp)
80105638:	e8 d1 c5 ff ff       	call   80101c0e <iunlockput>
8010563d:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105640:	83 ec 0c             	sub    $0xc,%esp
80105643:	ff 75 f0             	push   -0x10(%ebp)
80105646:	e8 92 c3 ff ff       	call   801019dd <ilock>
8010564b:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
8010564e:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105653:	75 15                	jne    8010566a <create+0xa5>
80105655:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105658:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010565c:	66 83 f8 02          	cmp    $0x2,%ax
80105660:	75 08                	jne    8010566a <create+0xa5>
      return ip;
80105662:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105665:	e9 2b 01 00 00       	jmp    80105795 <create+0x1d0>
    iunlockput(ip);
8010566a:	83 ec 0c             	sub    $0xc,%esp
8010566d:	ff 75 f0             	push   -0x10(%ebp)
80105670:	e8 99 c5 ff ff       	call   80101c0e <iunlockput>
80105675:	83 c4 10             	add    $0x10,%esp
    return 0;
80105678:	b8 00 00 00 00       	mov    $0x0,%eax
8010567d:	e9 13 01 00 00       	jmp    80105795 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105682:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105686:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105689:	8b 00                	mov    (%eax),%eax
8010568b:	83 ec 08             	sub    $0x8,%esp
8010568e:	52                   	push   %edx
8010568f:	50                   	push   %eax
80105690:	e8 94 c0 ff ff       	call   80101729 <ialloc>
80105695:	83 c4 10             	add    $0x10,%esp
80105698:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010569b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010569f:	75 0d                	jne    801056ae <create+0xe9>
    panic("create: ialloc");
801056a1:	83 ec 0c             	sub    $0xc,%esp
801056a4:	68 91 a5 10 80       	push   $0x8010a591
801056a9:	e8 fb ae ff ff       	call   801005a9 <panic>

  ilock(ip);
801056ae:	83 ec 0c             	sub    $0xc,%esp
801056b1:	ff 75 f0             	push   -0x10(%ebp)
801056b4:	e8 24 c3 ff ff       	call   801019dd <ilock>
801056b9:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801056bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056bf:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801056c3:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
801056c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056ca:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801056ce:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
801056d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056d5:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
801056db:	83 ec 0c             	sub    $0xc,%esp
801056de:	ff 75 f0             	push   -0x10(%ebp)
801056e1:	e8 1a c1 ff ff       	call   80101800 <iupdate>
801056e6:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801056e9:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801056ee:	75 6a                	jne    8010575a <create+0x195>
    dp->nlink++;  // for ".."
801056f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056f3:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801056f7:	83 c0 01             	add    $0x1,%eax
801056fa:	89 c2                	mov    %eax,%edx
801056fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056ff:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105703:	83 ec 0c             	sub    $0xc,%esp
80105706:	ff 75 f4             	push   -0xc(%ebp)
80105709:	e8 f2 c0 ff ff       	call   80101800 <iupdate>
8010570e:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105711:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105714:	8b 40 04             	mov    0x4(%eax),%eax
80105717:	83 ec 04             	sub    $0x4,%esp
8010571a:	50                   	push   %eax
8010571b:	68 6b a5 10 80       	push   $0x8010a56b
80105720:	ff 75 f0             	push   -0x10(%ebp)
80105723:	e8 51 cb ff ff       	call   80102279 <dirlink>
80105728:	83 c4 10             	add    $0x10,%esp
8010572b:	85 c0                	test   %eax,%eax
8010572d:	78 1e                	js     8010574d <create+0x188>
8010572f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105732:	8b 40 04             	mov    0x4(%eax),%eax
80105735:	83 ec 04             	sub    $0x4,%esp
80105738:	50                   	push   %eax
80105739:	68 6d a5 10 80       	push   $0x8010a56d
8010573e:	ff 75 f0             	push   -0x10(%ebp)
80105741:	e8 33 cb ff ff       	call   80102279 <dirlink>
80105746:	83 c4 10             	add    $0x10,%esp
80105749:	85 c0                	test   %eax,%eax
8010574b:	79 0d                	jns    8010575a <create+0x195>
      panic("create dots");
8010574d:	83 ec 0c             	sub    $0xc,%esp
80105750:	68 a0 a5 10 80       	push   $0x8010a5a0
80105755:	e8 4f ae ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
8010575a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010575d:	8b 40 04             	mov    0x4(%eax),%eax
80105760:	83 ec 04             	sub    $0x4,%esp
80105763:	50                   	push   %eax
80105764:	8d 45 de             	lea    -0x22(%ebp),%eax
80105767:	50                   	push   %eax
80105768:	ff 75 f4             	push   -0xc(%ebp)
8010576b:	e8 09 cb ff ff       	call   80102279 <dirlink>
80105770:	83 c4 10             	add    $0x10,%esp
80105773:	85 c0                	test   %eax,%eax
80105775:	79 0d                	jns    80105784 <create+0x1bf>
    panic("create: dirlink");
80105777:	83 ec 0c             	sub    $0xc,%esp
8010577a:	68 ac a5 10 80       	push   $0x8010a5ac
8010577f:	e8 25 ae ff ff       	call   801005a9 <panic>

  iunlockput(dp);
80105784:	83 ec 0c             	sub    $0xc,%esp
80105787:	ff 75 f4             	push   -0xc(%ebp)
8010578a:	e8 7f c4 ff ff       	call   80101c0e <iunlockput>
8010578f:	83 c4 10             	add    $0x10,%esp

  return ip;
80105792:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105795:	c9                   	leave  
80105796:	c3                   	ret    

80105797 <sys_open>:

int
sys_open(void)
{
80105797:	55                   	push   %ebp
80105798:	89 e5                	mov    %esp,%ebp
8010579a:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010579d:	83 ec 08             	sub    $0x8,%esp
801057a0:	8d 45 e8             	lea    -0x18(%ebp),%eax
801057a3:	50                   	push   %eax
801057a4:	6a 00                	push   $0x0
801057a6:	e8 ea f6 ff ff       	call   80104e95 <argstr>
801057ab:	83 c4 10             	add    $0x10,%esp
801057ae:	85 c0                	test   %eax,%eax
801057b0:	78 15                	js     801057c7 <sys_open+0x30>
801057b2:	83 ec 08             	sub    $0x8,%esp
801057b5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801057b8:	50                   	push   %eax
801057b9:	6a 01                	push   $0x1
801057bb:	e8 40 f6 ff ff       	call   80104e00 <argint>
801057c0:	83 c4 10             	add    $0x10,%esp
801057c3:	85 c0                	test   %eax,%eax
801057c5:	79 0a                	jns    801057d1 <sys_open+0x3a>
    return -1;
801057c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057cc:	e9 61 01 00 00       	jmp    80105932 <sys_open+0x19b>

  begin_op();
801057d1:	e8 59 d8 ff ff       	call   8010302f <begin_op>

  if(omode & O_CREATE){
801057d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801057d9:	25 00 02 00 00       	and    $0x200,%eax
801057de:	85 c0                	test   %eax,%eax
801057e0:	74 2a                	je     8010580c <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
801057e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801057e5:	6a 00                	push   $0x0
801057e7:	6a 00                	push   $0x0
801057e9:	6a 02                	push   $0x2
801057eb:	50                   	push   %eax
801057ec:	e8 d4 fd ff ff       	call   801055c5 <create>
801057f1:	83 c4 10             	add    $0x10,%esp
801057f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801057f7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057fb:	75 75                	jne    80105872 <sys_open+0xdb>
      end_op();
801057fd:	e8 b9 d8 ff ff       	call   801030bb <end_op>
      return -1;
80105802:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105807:	e9 26 01 00 00       	jmp    80105932 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
8010580c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010580f:	83 ec 0c             	sub    $0xc,%esp
80105812:	50                   	push   %eax
80105813:	e8 f8 cc ff ff       	call   80102510 <namei>
80105818:	83 c4 10             	add    $0x10,%esp
8010581b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010581e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105822:	75 0f                	jne    80105833 <sys_open+0x9c>
      end_op();
80105824:	e8 92 d8 ff ff       	call   801030bb <end_op>
      return -1;
80105829:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010582e:	e9 ff 00 00 00       	jmp    80105932 <sys_open+0x19b>
    }
    ilock(ip);
80105833:	83 ec 0c             	sub    $0xc,%esp
80105836:	ff 75 f4             	push   -0xc(%ebp)
80105839:	e8 9f c1 ff ff       	call   801019dd <ilock>
8010583e:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105841:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105844:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105848:	66 83 f8 01          	cmp    $0x1,%ax
8010584c:	75 24                	jne    80105872 <sys_open+0xdb>
8010584e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105851:	85 c0                	test   %eax,%eax
80105853:	74 1d                	je     80105872 <sys_open+0xdb>
      iunlockput(ip);
80105855:	83 ec 0c             	sub    $0xc,%esp
80105858:	ff 75 f4             	push   -0xc(%ebp)
8010585b:	e8 ae c3 ff ff       	call   80101c0e <iunlockput>
80105860:	83 c4 10             	add    $0x10,%esp
      end_op();
80105863:	e8 53 d8 ff ff       	call   801030bb <end_op>
      return -1;
80105868:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010586d:	e9 c0 00 00 00       	jmp    80105932 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105872:	e8 59 b7 ff ff       	call   80100fd0 <filealloc>
80105877:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010587a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010587e:	74 17                	je     80105897 <sys_open+0x100>
80105880:	83 ec 0c             	sub    $0xc,%esp
80105883:	ff 75 f0             	push   -0x10(%ebp)
80105886:	e8 33 f7 ff ff       	call   80104fbe <fdalloc>
8010588b:	83 c4 10             	add    $0x10,%esp
8010588e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105891:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105895:	79 2e                	jns    801058c5 <sys_open+0x12e>
    if(f)
80105897:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010589b:	74 0e                	je     801058ab <sys_open+0x114>
      fileclose(f);
8010589d:	83 ec 0c             	sub    $0xc,%esp
801058a0:	ff 75 f0             	push   -0x10(%ebp)
801058a3:	e8 e6 b7 ff ff       	call   8010108e <fileclose>
801058a8:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801058ab:	83 ec 0c             	sub    $0xc,%esp
801058ae:	ff 75 f4             	push   -0xc(%ebp)
801058b1:	e8 58 c3 ff ff       	call   80101c0e <iunlockput>
801058b6:	83 c4 10             	add    $0x10,%esp
    end_op();
801058b9:	e8 fd d7 ff ff       	call   801030bb <end_op>
    return -1;
801058be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058c3:	eb 6d                	jmp    80105932 <sys_open+0x19b>
  }
  iunlock(ip);
801058c5:	83 ec 0c             	sub    $0xc,%esp
801058c8:	ff 75 f4             	push   -0xc(%ebp)
801058cb:	e8 20 c2 ff ff       	call   80101af0 <iunlock>
801058d0:	83 c4 10             	add    $0x10,%esp
  end_op();
801058d3:	e8 e3 d7 ff ff       	call   801030bb <end_op>

  f->type = FD_INODE;
801058d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058db:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801058e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058e7:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801058ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058ed:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801058f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801058f7:	83 e0 01             	and    $0x1,%eax
801058fa:	85 c0                	test   %eax,%eax
801058fc:	0f 94 c0             	sete   %al
801058ff:	89 c2                	mov    %eax,%edx
80105901:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105904:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105907:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010590a:	83 e0 01             	and    $0x1,%eax
8010590d:	85 c0                	test   %eax,%eax
8010590f:	75 0a                	jne    8010591b <sys_open+0x184>
80105911:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105914:	83 e0 02             	and    $0x2,%eax
80105917:	85 c0                	test   %eax,%eax
80105919:	74 07                	je     80105922 <sys_open+0x18b>
8010591b:	b8 01 00 00 00       	mov    $0x1,%eax
80105920:	eb 05                	jmp    80105927 <sys_open+0x190>
80105922:	b8 00 00 00 00       	mov    $0x0,%eax
80105927:	89 c2                	mov    %eax,%edx
80105929:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010592c:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
8010592f:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105932:	c9                   	leave  
80105933:	c3                   	ret    

80105934 <sys_mkdir>:

int
sys_mkdir(void)
{
80105934:	55                   	push   %ebp
80105935:	89 e5                	mov    %esp,%ebp
80105937:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010593a:	e8 f0 d6 ff ff       	call   8010302f <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010593f:	83 ec 08             	sub    $0x8,%esp
80105942:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105945:	50                   	push   %eax
80105946:	6a 00                	push   $0x0
80105948:	e8 48 f5 ff ff       	call   80104e95 <argstr>
8010594d:	83 c4 10             	add    $0x10,%esp
80105950:	85 c0                	test   %eax,%eax
80105952:	78 1b                	js     8010596f <sys_mkdir+0x3b>
80105954:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105957:	6a 00                	push   $0x0
80105959:	6a 00                	push   $0x0
8010595b:	6a 01                	push   $0x1
8010595d:	50                   	push   %eax
8010595e:	e8 62 fc ff ff       	call   801055c5 <create>
80105963:	83 c4 10             	add    $0x10,%esp
80105966:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105969:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010596d:	75 0c                	jne    8010597b <sys_mkdir+0x47>
    end_op();
8010596f:	e8 47 d7 ff ff       	call   801030bb <end_op>
    return -1;
80105974:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105979:	eb 18                	jmp    80105993 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
8010597b:	83 ec 0c             	sub    $0xc,%esp
8010597e:	ff 75 f4             	push   -0xc(%ebp)
80105981:	e8 88 c2 ff ff       	call   80101c0e <iunlockput>
80105986:	83 c4 10             	add    $0x10,%esp
  end_op();
80105989:	e8 2d d7 ff ff       	call   801030bb <end_op>
  return 0;
8010598e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105993:	c9                   	leave  
80105994:	c3                   	ret    

80105995 <sys_mknod>:

int
sys_mknod(void)
{
80105995:	55                   	push   %ebp
80105996:	89 e5                	mov    %esp,%ebp
80105998:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
8010599b:	e8 8f d6 ff ff       	call   8010302f <begin_op>
  if((argstr(0, &path)) < 0 ||
801059a0:	83 ec 08             	sub    $0x8,%esp
801059a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059a6:	50                   	push   %eax
801059a7:	6a 00                	push   $0x0
801059a9:	e8 e7 f4 ff ff       	call   80104e95 <argstr>
801059ae:	83 c4 10             	add    $0x10,%esp
801059b1:	85 c0                	test   %eax,%eax
801059b3:	78 4f                	js     80105a04 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
801059b5:	83 ec 08             	sub    $0x8,%esp
801059b8:	8d 45 ec             	lea    -0x14(%ebp),%eax
801059bb:	50                   	push   %eax
801059bc:	6a 01                	push   $0x1
801059be:	e8 3d f4 ff ff       	call   80104e00 <argint>
801059c3:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
801059c6:	85 c0                	test   %eax,%eax
801059c8:	78 3a                	js     80105a04 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
801059ca:	83 ec 08             	sub    $0x8,%esp
801059cd:	8d 45 e8             	lea    -0x18(%ebp),%eax
801059d0:	50                   	push   %eax
801059d1:	6a 02                	push   $0x2
801059d3:	e8 28 f4 ff ff       	call   80104e00 <argint>
801059d8:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
801059db:	85 c0                	test   %eax,%eax
801059dd:	78 25                	js     80105a04 <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
801059df:	8b 45 e8             	mov    -0x18(%ebp),%eax
801059e2:	0f bf c8             	movswl %ax,%ecx
801059e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801059e8:	0f bf d0             	movswl %ax,%edx
801059eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059ee:	51                   	push   %ecx
801059ef:	52                   	push   %edx
801059f0:	6a 03                	push   $0x3
801059f2:	50                   	push   %eax
801059f3:	e8 cd fb ff ff       	call   801055c5 <create>
801059f8:	83 c4 10             	add    $0x10,%esp
801059fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
801059fe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a02:	75 0c                	jne    80105a10 <sys_mknod+0x7b>
    end_op();
80105a04:	e8 b2 d6 ff ff       	call   801030bb <end_op>
    return -1;
80105a09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a0e:	eb 18                	jmp    80105a28 <sys_mknod+0x93>
  }
  iunlockput(ip);
80105a10:	83 ec 0c             	sub    $0xc,%esp
80105a13:	ff 75 f4             	push   -0xc(%ebp)
80105a16:	e8 f3 c1 ff ff       	call   80101c0e <iunlockput>
80105a1b:	83 c4 10             	add    $0x10,%esp
  end_op();
80105a1e:	e8 98 d6 ff ff       	call   801030bb <end_op>
  return 0;
80105a23:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a28:	c9                   	leave  
80105a29:	c3                   	ret    

80105a2a <sys_chdir>:

int
sys_chdir(void)
{
80105a2a:	55                   	push   %ebp
80105a2b:	89 e5                	mov    %esp,%ebp
80105a2d:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105a30:	e8 ee df ff ff       	call   80103a23 <myproc>
80105a35:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105a38:	e8 f2 d5 ff ff       	call   8010302f <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105a3d:	83 ec 08             	sub    $0x8,%esp
80105a40:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105a43:	50                   	push   %eax
80105a44:	6a 00                	push   $0x0
80105a46:	e8 4a f4 ff ff       	call   80104e95 <argstr>
80105a4b:	83 c4 10             	add    $0x10,%esp
80105a4e:	85 c0                	test   %eax,%eax
80105a50:	78 18                	js     80105a6a <sys_chdir+0x40>
80105a52:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105a55:	83 ec 0c             	sub    $0xc,%esp
80105a58:	50                   	push   %eax
80105a59:	e8 b2 ca ff ff       	call   80102510 <namei>
80105a5e:	83 c4 10             	add    $0x10,%esp
80105a61:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a64:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a68:	75 0c                	jne    80105a76 <sys_chdir+0x4c>
    end_op();
80105a6a:	e8 4c d6 ff ff       	call   801030bb <end_op>
    return -1;
80105a6f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a74:	eb 68                	jmp    80105ade <sys_chdir+0xb4>
  }
  ilock(ip);
80105a76:	83 ec 0c             	sub    $0xc,%esp
80105a79:	ff 75 f0             	push   -0x10(%ebp)
80105a7c:	e8 5c bf ff ff       	call   801019dd <ilock>
80105a81:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105a84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a87:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105a8b:	66 83 f8 01          	cmp    $0x1,%ax
80105a8f:	74 1a                	je     80105aab <sys_chdir+0x81>
    iunlockput(ip);
80105a91:	83 ec 0c             	sub    $0xc,%esp
80105a94:	ff 75 f0             	push   -0x10(%ebp)
80105a97:	e8 72 c1 ff ff       	call   80101c0e <iunlockput>
80105a9c:	83 c4 10             	add    $0x10,%esp
    end_op();
80105a9f:	e8 17 d6 ff ff       	call   801030bb <end_op>
    return -1;
80105aa4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aa9:	eb 33                	jmp    80105ade <sys_chdir+0xb4>
  }
  iunlock(ip);
80105aab:	83 ec 0c             	sub    $0xc,%esp
80105aae:	ff 75 f0             	push   -0x10(%ebp)
80105ab1:	e8 3a c0 ff ff       	call   80101af0 <iunlock>
80105ab6:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105ab9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105abc:	8b 40 68             	mov    0x68(%eax),%eax
80105abf:	83 ec 0c             	sub    $0xc,%esp
80105ac2:	50                   	push   %eax
80105ac3:	e8 76 c0 ff ff       	call   80101b3e <iput>
80105ac8:	83 c4 10             	add    $0x10,%esp
  end_op();
80105acb:	e8 eb d5 ff ff       	call   801030bb <end_op>
  curproc->cwd = ip;
80105ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ad3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ad6:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105ad9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ade:	c9                   	leave  
80105adf:	c3                   	ret    

80105ae0 <sys_exec>:

int
sys_exec(void)
{
80105ae0:	55                   	push   %ebp
80105ae1:	89 e5                	mov    %esp,%ebp
80105ae3:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105ae9:	83 ec 08             	sub    $0x8,%esp
80105aec:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105aef:	50                   	push   %eax
80105af0:	6a 00                	push   $0x0
80105af2:	e8 9e f3 ff ff       	call   80104e95 <argstr>
80105af7:	83 c4 10             	add    $0x10,%esp
80105afa:	85 c0                	test   %eax,%eax
80105afc:	78 18                	js     80105b16 <sys_exec+0x36>
80105afe:	83 ec 08             	sub    $0x8,%esp
80105b01:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105b07:	50                   	push   %eax
80105b08:	6a 01                	push   $0x1
80105b0a:	e8 f1 f2 ff ff       	call   80104e00 <argint>
80105b0f:	83 c4 10             	add    $0x10,%esp
80105b12:	85 c0                	test   %eax,%eax
80105b14:	79 0a                	jns    80105b20 <sys_exec+0x40>
    return -1;
80105b16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b1b:	e9 c6 00 00 00       	jmp    80105be6 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80105b20:	83 ec 04             	sub    $0x4,%esp
80105b23:	68 80 00 00 00       	push   $0x80
80105b28:	6a 00                	push   $0x0
80105b2a:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105b30:	50                   	push   %eax
80105b31:	e8 9f ef ff ff       	call   80104ad5 <memset>
80105b36:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105b39:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b43:	83 f8 1f             	cmp    $0x1f,%eax
80105b46:	76 0a                	jbe    80105b52 <sys_exec+0x72>
      return -1;
80105b48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b4d:	e9 94 00 00 00       	jmp    80105be6 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105b52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b55:	c1 e0 02             	shl    $0x2,%eax
80105b58:	89 c2                	mov    %eax,%edx
80105b5a:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105b60:	01 c2                	add    %eax,%edx
80105b62:	83 ec 08             	sub    $0x8,%esp
80105b65:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105b6b:	50                   	push   %eax
80105b6c:	52                   	push   %edx
80105b6d:	e8 ed f1 ff ff       	call   80104d5f <fetchint>
80105b72:	83 c4 10             	add    $0x10,%esp
80105b75:	85 c0                	test   %eax,%eax
80105b77:	79 07                	jns    80105b80 <sys_exec+0xa0>
      return -1;
80105b79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b7e:	eb 66                	jmp    80105be6 <sys_exec+0x106>
    if(uarg == 0){
80105b80:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105b86:	85 c0                	test   %eax,%eax
80105b88:	75 27                	jne    80105bb1 <sys_exec+0xd1>
      argv[i] = 0;
80105b8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b8d:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105b94:	00 00 00 00 
      break;
80105b98:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105b99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b9c:	83 ec 08             	sub    $0x8,%esp
80105b9f:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105ba5:	52                   	push   %edx
80105ba6:	50                   	push   %eax
80105ba7:	e8 d4 af ff ff       	call   80100b80 <exec>
80105bac:	83 c4 10             	add    $0x10,%esp
80105baf:	eb 35                	jmp    80105be6 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105bb1:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105bb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bba:	c1 e0 02             	shl    $0x2,%eax
80105bbd:	01 c2                	add    %eax,%edx
80105bbf:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105bc5:	83 ec 08             	sub    $0x8,%esp
80105bc8:	52                   	push   %edx
80105bc9:	50                   	push   %eax
80105bca:	e8 cf f1 ff ff       	call   80104d9e <fetchstr>
80105bcf:	83 c4 10             	add    $0x10,%esp
80105bd2:	85 c0                	test   %eax,%eax
80105bd4:	79 07                	jns    80105bdd <sys_exec+0xfd>
      return -1;
80105bd6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bdb:	eb 09                	jmp    80105be6 <sys_exec+0x106>
  for(i=0;; i++){
80105bdd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105be1:	e9 5a ff ff ff       	jmp    80105b40 <sys_exec+0x60>
}
80105be6:	c9                   	leave  
80105be7:	c3                   	ret    

80105be8 <sys_pipe>:

int
sys_pipe(void)
{
80105be8:	55                   	push   %ebp
80105be9:	89 e5                	mov    %esp,%ebp
80105beb:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105bee:	83 ec 04             	sub    $0x4,%esp
80105bf1:	6a 08                	push   $0x8
80105bf3:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105bf6:	50                   	push   %eax
80105bf7:	6a 00                	push   $0x0
80105bf9:	e8 2f f2 ff ff       	call   80104e2d <argptr>
80105bfe:	83 c4 10             	add    $0x10,%esp
80105c01:	85 c0                	test   %eax,%eax
80105c03:	79 0a                	jns    80105c0f <sys_pipe+0x27>
    return -1;
80105c05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c0a:	e9 ae 00 00 00       	jmp    80105cbd <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105c0f:	83 ec 08             	sub    $0x8,%esp
80105c12:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105c15:	50                   	push   %eax
80105c16:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105c19:	50                   	push   %eax
80105c1a:	e8 41 d9 ff ff       	call   80103560 <pipealloc>
80105c1f:	83 c4 10             	add    $0x10,%esp
80105c22:	85 c0                	test   %eax,%eax
80105c24:	79 0a                	jns    80105c30 <sys_pipe+0x48>
    return -1;
80105c26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c2b:	e9 8d 00 00 00       	jmp    80105cbd <sys_pipe+0xd5>
  fd0 = -1;
80105c30:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105c37:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105c3a:	83 ec 0c             	sub    $0xc,%esp
80105c3d:	50                   	push   %eax
80105c3e:	e8 7b f3 ff ff       	call   80104fbe <fdalloc>
80105c43:	83 c4 10             	add    $0x10,%esp
80105c46:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c49:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c4d:	78 18                	js     80105c67 <sys_pipe+0x7f>
80105c4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c52:	83 ec 0c             	sub    $0xc,%esp
80105c55:	50                   	push   %eax
80105c56:	e8 63 f3 ff ff       	call   80104fbe <fdalloc>
80105c5b:	83 c4 10             	add    $0x10,%esp
80105c5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c61:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c65:	79 3e                	jns    80105ca5 <sys_pipe+0xbd>
    if(fd0 >= 0)
80105c67:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c6b:	78 13                	js     80105c80 <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105c6d:	e8 b1 dd ff ff       	call   80103a23 <myproc>
80105c72:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c75:	83 c2 08             	add    $0x8,%edx
80105c78:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105c7f:	00 
    fileclose(rf);
80105c80:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105c83:	83 ec 0c             	sub    $0xc,%esp
80105c86:	50                   	push   %eax
80105c87:	e8 02 b4 ff ff       	call   8010108e <fileclose>
80105c8c:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105c8f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c92:	83 ec 0c             	sub    $0xc,%esp
80105c95:	50                   	push   %eax
80105c96:	e8 f3 b3 ff ff       	call   8010108e <fileclose>
80105c9b:	83 c4 10             	add    $0x10,%esp
    return -1;
80105c9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ca3:	eb 18                	jmp    80105cbd <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80105ca5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105ca8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105cab:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105cad:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105cb0:	8d 50 04             	lea    0x4(%eax),%edx
80105cb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cb6:	89 02                	mov    %eax,(%edx)
  return 0;
80105cb8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cbd:	c9                   	leave  
80105cbe:	c3                   	ret    

80105cbf <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80105cbf:	55                   	push   %ebp
80105cc0:	89 e5                	mov    %esp,%ebp
80105cc2:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105cc5:	e8 58 e0 ff ff       	call   80103d22 <fork>
}
80105cca:	c9                   	leave  
80105ccb:	c3                   	ret    

80105ccc <sys_exit>:

int
sys_exit(void)
{
80105ccc:	55                   	push   %ebp
80105ccd:	89 e5                	mov    %esp,%ebp
80105ccf:	83 ec 08             	sub    $0x8,%esp
  exit();
80105cd2:	e8 c4 e1 ff ff       	call   80103e9b <exit>
  return 0;  // not reached
80105cd7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cdc:	c9                   	leave  
80105cdd:	c3                   	ret    

80105cde <sys_wait>:

int
sys_wait(void)
{
80105cde:	55                   	push   %ebp
80105cdf:	89 e5                	mov    %esp,%ebp
80105ce1:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105ce4:	e8 d2 e2 ff ff       	call   80103fbb <wait>
}
80105ce9:	c9                   	leave  
80105cea:	c3                   	ret    

80105ceb <sys_kill>:

int
sys_kill(void)
{
80105ceb:	55                   	push   %ebp
80105cec:	89 e5                	mov    %esp,%ebp
80105cee:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105cf1:	83 ec 08             	sub    $0x8,%esp
80105cf4:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105cf7:	50                   	push   %eax
80105cf8:	6a 00                	push   $0x0
80105cfa:	e8 01 f1 ff ff       	call   80104e00 <argint>
80105cff:	83 c4 10             	add    $0x10,%esp
80105d02:	85 c0                	test   %eax,%eax
80105d04:	79 07                	jns    80105d0d <sys_kill+0x22>
    return -1;
80105d06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d0b:	eb 0f                	jmp    80105d1c <sys_kill+0x31>
  return kill(pid);
80105d0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d10:	83 ec 0c             	sub    $0xc,%esp
80105d13:	50                   	push   %eax
80105d14:	e8 d1 e6 ff ff       	call   801043ea <kill>
80105d19:	83 c4 10             	add    $0x10,%esp
}
80105d1c:	c9                   	leave  
80105d1d:	c3                   	ret    

80105d1e <sys_getpid>:

int
sys_getpid(void)
{
80105d1e:	55                   	push   %ebp
80105d1f:	89 e5                	mov    %esp,%ebp
80105d21:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105d24:	e8 fa dc ff ff       	call   80103a23 <myproc>
80105d29:	8b 40 10             	mov    0x10(%eax),%eax
}
80105d2c:	c9                   	leave  
80105d2d:	c3                   	ret    

80105d2e <sys_sbrk>:

int
sys_sbrk(void)
{
80105d2e:	55                   	push   %ebp
80105d2f:	89 e5                	mov    %esp,%ebp
80105d31:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105d34:	83 ec 08             	sub    $0x8,%esp
80105d37:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d3a:	50                   	push   %eax
80105d3b:	6a 00                	push   $0x0
80105d3d:	e8 be f0 ff ff       	call   80104e00 <argint>
80105d42:	83 c4 10             	add    $0x10,%esp
80105d45:	85 c0                	test   %eax,%eax
80105d47:	79 07                	jns    80105d50 <sys_sbrk+0x22>
    return -1;
80105d49:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d4e:	eb 27                	jmp    80105d77 <sys_sbrk+0x49>
  addr = myproc()->sz;
80105d50:	e8 ce dc ff ff       	call   80103a23 <myproc>
80105d55:	8b 00                	mov    (%eax),%eax
80105d57:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80105d5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d5d:	83 ec 0c             	sub    $0xc,%esp
80105d60:	50                   	push   %eax
80105d61:	e8 21 df ff ff       	call   80103c87 <growproc>
80105d66:	83 c4 10             	add    $0x10,%esp
80105d69:	85 c0                	test   %eax,%eax
80105d6b:	79 07                	jns    80105d74 <sys_sbrk+0x46>
    return -1;
80105d6d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d72:	eb 03                	jmp    80105d77 <sys_sbrk+0x49>
  return addr;
80105d74:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105d77:	c9                   	leave  
80105d78:	c3                   	ret    

80105d79 <sys_sleep>:

int
sys_sleep(void)
{
80105d79:	55                   	push   %ebp
80105d7a:	89 e5                	mov    %esp,%ebp
80105d7c:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105d7f:	83 ec 08             	sub    $0x8,%esp
80105d82:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d85:	50                   	push   %eax
80105d86:	6a 00                	push   $0x0
80105d88:	e8 73 f0 ff ff       	call   80104e00 <argint>
80105d8d:	83 c4 10             	add    $0x10,%esp
80105d90:	85 c0                	test   %eax,%eax
80105d92:	79 07                	jns    80105d9b <sys_sleep+0x22>
    return -1;
80105d94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d99:	eb 76                	jmp    80105e11 <sys_sleep+0x98>
  acquire(&tickslock);
80105d9b:	83 ec 0c             	sub    $0xc,%esp
80105d9e:	68 40 69 19 80       	push   $0x80196940
80105da3:	e8 b7 ea ff ff       	call   8010485f <acquire>
80105da8:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80105dab:	a1 74 69 19 80       	mov    0x80196974,%eax
80105db0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80105db3:	eb 38                	jmp    80105ded <sys_sleep+0x74>
    if(myproc()->killed){
80105db5:	e8 69 dc ff ff       	call   80103a23 <myproc>
80105dba:	8b 40 24             	mov    0x24(%eax),%eax
80105dbd:	85 c0                	test   %eax,%eax
80105dbf:	74 17                	je     80105dd8 <sys_sleep+0x5f>
      release(&tickslock);
80105dc1:	83 ec 0c             	sub    $0xc,%esp
80105dc4:	68 40 69 19 80       	push   $0x80196940
80105dc9:	e8 ff ea ff ff       	call   801048cd <release>
80105dce:	83 c4 10             	add    $0x10,%esp
      return -1;
80105dd1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dd6:	eb 39                	jmp    80105e11 <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80105dd8:	83 ec 08             	sub    $0x8,%esp
80105ddb:	68 40 69 19 80       	push   $0x80196940
80105de0:	68 74 69 19 80       	push   $0x80196974
80105de5:	e8 e2 e4 ff ff       	call   801042cc <sleep>
80105dea:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80105ded:	a1 74 69 19 80       	mov    0x80196974,%eax
80105df2:	2b 45 f4             	sub    -0xc(%ebp),%eax
80105df5:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105df8:	39 d0                	cmp    %edx,%eax
80105dfa:	72 b9                	jb     80105db5 <sys_sleep+0x3c>
  }
  release(&tickslock);
80105dfc:	83 ec 0c             	sub    $0xc,%esp
80105dff:	68 40 69 19 80       	push   $0x80196940
80105e04:	e8 c4 ea ff ff       	call   801048cd <release>
80105e09:	83 c4 10             	add    $0x10,%esp
  return 0;
80105e0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e11:	c9                   	leave  
80105e12:	c3                   	ret    

80105e13 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105e13:	55                   	push   %ebp
80105e14:	89 e5                	mov    %esp,%ebp
80105e16:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80105e19:	83 ec 0c             	sub    $0xc,%esp
80105e1c:	68 40 69 19 80       	push   $0x80196940
80105e21:	e8 39 ea ff ff       	call   8010485f <acquire>
80105e26:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80105e29:	a1 74 69 19 80       	mov    0x80196974,%eax
80105e2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80105e31:	83 ec 0c             	sub    $0xc,%esp
80105e34:	68 40 69 19 80       	push   $0x80196940
80105e39:	e8 8f ea ff ff       	call   801048cd <release>
80105e3e:	83 c4 10             	add    $0x10,%esp
  return xticks;
80105e41:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105e44:	c9                   	leave  
80105e45:	c3                   	ret    

80105e46 <sys_printpt>:

int sys_printpt(int pid)
{
80105e46:	55                   	push   %ebp
80105e47:	89 e5                	mov    %esp,%ebp
80105e49:	83 ec 18             	sub    $0x18,%esp
  int n;
  if (argint(0, &n) < 0)
80105e4c:	83 ec 08             	sub    $0x8,%esp
80105e4f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105e52:	50                   	push   %eax
80105e53:	6a 00                	push   $0x0
80105e55:	e8 a6 ef ff ff       	call   80104e00 <argint>
80105e5a:	83 c4 10             	add    $0x10,%esp
80105e5d:	85 c0                	test   %eax,%eax
80105e5f:	79 07                	jns    80105e68 <sys_printpt+0x22>
    return -1;
80105e61:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e66:	eb 14                	jmp    80105e7c <sys_printpt+0x36>
  printpt(n);
80105e68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e6b:	83 ec 0c             	sub    $0xc,%esp
80105e6e:	50                   	push   %eax
80105e6f:	e8 f4 e6 ff ff       	call   80104568 <printpt>
80105e74:	83 c4 10             	add    $0x10,%esp
  return 0;
80105e77:	b8 00 00 00 00       	mov    $0x0,%eax
80105e7c:	c9                   	leave  
80105e7d:	c3                   	ret    

80105e7e <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80105e7e:	1e                   	push   %ds
  pushl %es
80105e7f:	06                   	push   %es
  pushl %fs
80105e80:	0f a0                	push   %fs
  pushl %gs
80105e82:	0f a8                	push   %gs
  pushal
80105e84:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80105e85:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80105e89:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80105e8b:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80105e8d:	54                   	push   %esp
  call trap
80105e8e:	e8 d7 01 00 00       	call   8010606a <trap>
  addl $4, %esp
80105e93:	83 c4 04             	add    $0x4,%esp

80105e96 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80105e96:	61                   	popa   
  popl %gs
80105e97:	0f a9                	pop    %gs
  popl %fs
80105e99:	0f a1                	pop    %fs
  popl %es
80105e9b:	07                   	pop    %es
  popl %ds
80105e9c:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80105e9d:	83 c4 08             	add    $0x8,%esp
  iret
80105ea0:	cf                   	iret   

80105ea1 <lidt>:
{
80105ea1:	55                   	push   %ebp
80105ea2:	89 e5                	mov    %esp,%ebp
80105ea4:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80105ea7:	8b 45 0c             	mov    0xc(%ebp),%eax
80105eaa:	83 e8 01             	sub    $0x1,%eax
80105ead:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80105eb1:	8b 45 08             	mov    0x8(%ebp),%eax
80105eb4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105eb8:	8b 45 08             	mov    0x8(%ebp),%eax
80105ebb:	c1 e8 10             	shr    $0x10,%eax
80105ebe:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105ec2:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105ec5:	0f 01 18             	lidtl  (%eax)
}
80105ec8:	90                   	nop
80105ec9:	c9                   	leave  
80105eca:	c3                   	ret    

80105ecb <rcr2>:

static inline uint
rcr2(void)
{
80105ecb:	55                   	push   %ebp
80105ecc:	89 e5                	mov    %esp,%ebp
80105ece:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105ed1:	0f 20 d0             	mov    %cr2,%eax
80105ed4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80105ed7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105eda:	c9                   	leave  
80105edb:	c3                   	ret    

80105edc <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80105edc:	55                   	push   %ebp
80105edd:	89 e5                	mov    %esp,%ebp
80105edf:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80105ee2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105ee9:	e9 c3 00 00 00       	jmp    80105fb1 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80105eee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ef1:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
80105ef8:	89 c2                	mov    %eax,%edx
80105efa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105efd:	66 89 14 c5 40 61 19 	mov    %dx,-0x7fe69ec0(,%eax,8)
80105f04:	80 
80105f05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f08:	66 c7 04 c5 42 61 19 	movw   $0x8,-0x7fe69ebe(,%eax,8)
80105f0f:	80 08 00 
80105f12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f15:	0f b6 14 c5 44 61 19 	movzbl -0x7fe69ebc(,%eax,8),%edx
80105f1c:	80 
80105f1d:	83 e2 e0             	and    $0xffffffe0,%edx
80105f20:	88 14 c5 44 61 19 80 	mov    %dl,-0x7fe69ebc(,%eax,8)
80105f27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f2a:	0f b6 14 c5 44 61 19 	movzbl -0x7fe69ebc(,%eax,8),%edx
80105f31:	80 
80105f32:	83 e2 1f             	and    $0x1f,%edx
80105f35:	88 14 c5 44 61 19 80 	mov    %dl,-0x7fe69ebc(,%eax,8)
80105f3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f3f:	0f b6 14 c5 45 61 19 	movzbl -0x7fe69ebb(,%eax,8),%edx
80105f46:	80 
80105f47:	83 e2 f0             	and    $0xfffffff0,%edx
80105f4a:	83 ca 0e             	or     $0xe,%edx
80105f4d:	88 14 c5 45 61 19 80 	mov    %dl,-0x7fe69ebb(,%eax,8)
80105f54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f57:	0f b6 14 c5 45 61 19 	movzbl -0x7fe69ebb(,%eax,8),%edx
80105f5e:	80 
80105f5f:	83 e2 ef             	and    $0xffffffef,%edx
80105f62:	88 14 c5 45 61 19 80 	mov    %dl,-0x7fe69ebb(,%eax,8)
80105f69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f6c:	0f b6 14 c5 45 61 19 	movzbl -0x7fe69ebb(,%eax,8),%edx
80105f73:	80 
80105f74:	83 e2 9f             	and    $0xffffff9f,%edx
80105f77:	88 14 c5 45 61 19 80 	mov    %dl,-0x7fe69ebb(,%eax,8)
80105f7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f81:	0f b6 14 c5 45 61 19 	movzbl -0x7fe69ebb(,%eax,8),%edx
80105f88:	80 
80105f89:	83 ca 80             	or     $0xffffff80,%edx
80105f8c:	88 14 c5 45 61 19 80 	mov    %dl,-0x7fe69ebb(,%eax,8)
80105f93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f96:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
80105f9d:	c1 e8 10             	shr    $0x10,%eax
80105fa0:	89 c2                	mov    %eax,%edx
80105fa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fa5:	66 89 14 c5 46 61 19 	mov    %dx,-0x7fe69eba(,%eax,8)
80105fac:	80 
  for(i = 0; i < 256; i++)
80105fad:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105fb1:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80105fb8:	0f 8e 30 ff ff ff    	jle    80105eee <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105fbe:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
80105fc3:	66 a3 40 63 19 80    	mov    %ax,0x80196340
80105fc9:	66 c7 05 42 63 19 80 	movw   $0x8,0x80196342
80105fd0:	08 00 
80105fd2:	0f b6 05 44 63 19 80 	movzbl 0x80196344,%eax
80105fd9:	83 e0 e0             	and    $0xffffffe0,%eax
80105fdc:	a2 44 63 19 80       	mov    %al,0x80196344
80105fe1:	0f b6 05 44 63 19 80 	movzbl 0x80196344,%eax
80105fe8:	83 e0 1f             	and    $0x1f,%eax
80105feb:	a2 44 63 19 80       	mov    %al,0x80196344
80105ff0:	0f b6 05 45 63 19 80 	movzbl 0x80196345,%eax
80105ff7:	83 c8 0f             	or     $0xf,%eax
80105ffa:	a2 45 63 19 80       	mov    %al,0x80196345
80105fff:	0f b6 05 45 63 19 80 	movzbl 0x80196345,%eax
80106006:	83 e0 ef             	and    $0xffffffef,%eax
80106009:	a2 45 63 19 80       	mov    %al,0x80196345
8010600e:	0f b6 05 45 63 19 80 	movzbl 0x80196345,%eax
80106015:	83 c8 60             	or     $0x60,%eax
80106018:	a2 45 63 19 80       	mov    %al,0x80196345
8010601d:	0f b6 05 45 63 19 80 	movzbl 0x80196345,%eax
80106024:	83 c8 80             	or     $0xffffff80,%eax
80106027:	a2 45 63 19 80       	mov    %al,0x80196345
8010602c:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
80106031:	c1 e8 10             	shr    $0x10,%eax
80106034:	66 a3 46 63 19 80    	mov    %ax,0x80196346

  initlock(&tickslock, "time");
8010603a:	83 ec 08             	sub    $0x8,%esp
8010603d:	68 bc a5 10 80       	push   $0x8010a5bc
80106042:	68 40 69 19 80       	push   $0x80196940
80106047:	e8 f1 e7 ff ff       	call   8010483d <initlock>
8010604c:	83 c4 10             	add    $0x10,%esp
}
8010604f:	90                   	nop
80106050:	c9                   	leave  
80106051:	c3                   	ret    

80106052 <idtinit>:

void
idtinit(void)
{
80106052:	55                   	push   %ebp
80106053:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106055:	68 00 08 00 00       	push   $0x800
8010605a:	68 40 61 19 80       	push   $0x80196140
8010605f:	e8 3d fe ff ff       	call   80105ea1 <lidt>
80106064:	83 c4 08             	add    $0x8,%esp
}
80106067:	90                   	nop
80106068:	c9                   	leave  
80106069:	c3                   	ret    

8010606a <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010606a:	55                   	push   %ebp
8010606b:	89 e5                	mov    %esp,%ebp
8010606d:	57                   	push   %edi
8010606e:	56                   	push   %esi
8010606f:	53                   	push   %ebx
80106070:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80106073:	8b 45 08             	mov    0x8(%ebp),%eax
80106076:	8b 40 30             	mov    0x30(%eax),%eax
80106079:	83 f8 40             	cmp    $0x40,%eax
8010607c:	75 3b                	jne    801060b9 <trap+0x4f>
    if(myproc()->killed)
8010607e:	e8 a0 d9 ff ff       	call   80103a23 <myproc>
80106083:	8b 40 24             	mov    0x24(%eax),%eax
80106086:	85 c0                	test   %eax,%eax
80106088:	74 05                	je     8010608f <trap+0x25>
      exit();
8010608a:	e8 0c de ff ff       	call   80103e9b <exit>
    myproc()->tf = tf;
8010608f:	e8 8f d9 ff ff       	call   80103a23 <myproc>
80106094:	8b 55 08             	mov    0x8(%ebp),%edx
80106097:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
8010609a:	e8 2d ee ff ff       	call   80104ecc <syscall>
    if(myproc()->killed)
8010609f:	e8 7f d9 ff ff       	call   80103a23 <myproc>
801060a4:	8b 40 24             	mov    0x24(%eax),%eax
801060a7:	85 c0                	test   %eax,%eax
801060a9:	0f 84 15 02 00 00    	je     801062c4 <trap+0x25a>
      exit();
801060af:	e8 e7 dd ff ff       	call   80103e9b <exit>
    return;
801060b4:	e9 0b 02 00 00       	jmp    801062c4 <trap+0x25a>
  }

  switch(tf->trapno){
801060b9:	8b 45 08             	mov    0x8(%ebp),%eax
801060bc:	8b 40 30             	mov    0x30(%eax),%eax
801060bf:	83 e8 20             	sub    $0x20,%eax
801060c2:	83 f8 1f             	cmp    $0x1f,%eax
801060c5:	0f 87 c4 00 00 00    	ja     8010618f <trap+0x125>
801060cb:	8b 04 85 64 a6 10 80 	mov    -0x7fef599c(,%eax,4),%eax
801060d2:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801060d4:	e8 b7 d8 ff ff       	call   80103990 <cpuid>
801060d9:	85 c0                	test   %eax,%eax
801060db:	75 3d                	jne    8010611a <trap+0xb0>
      acquire(&tickslock);
801060dd:	83 ec 0c             	sub    $0xc,%esp
801060e0:	68 40 69 19 80       	push   $0x80196940
801060e5:	e8 75 e7 ff ff       	call   8010485f <acquire>
801060ea:	83 c4 10             	add    $0x10,%esp
      ticks++;
801060ed:	a1 74 69 19 80       	mov    0x80196974,%eax
801060f2:	83 c0 01             	add    $0x1,%eax
801060f5:	a3 74 69 19 80       	mov    %eax,0x80196974
      wakeup(&ticks);
801060fa:	83 ec 0c             	sub    $0xc,%esp
801060fd:	68 74 69 19 80       	push   $0x80196974
80106102:	e8 ac e2 ff ff       	call   801043b3 <wakeup>
80106107:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
8010610a:	83 ec 0c             	sub    $0xc,%esp
8010610d:	68 40 69 19 80       	push   $0x80196940
80106112:	e8 b6 e7 ff ff       	call   801048cd <release>
80106117:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
8010611a:	e8 f0 c9 ff ff       	call   80102b0f <lapiceoi>
    break;
8010611f:	e9 20 01 00 00       	jmp    80106244 <trap+0x1da>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106124:	e8 e3 3e 00 00       	call   8010a00c <ideintr>
    lapiceoi();
80106129:	e8 e1 c9 ff ff       	call   80102b0f <lapiceoi>
    break;
8010612e:	e9 11 01 00 00       	jmp    80106244 <trap+0x1da>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106133:	e8 1c c8 ff ff       	call   80102954 <kbdintr>
    lapiceoi();
80106138:	e8 d2 c9 ff ff       	call   80102b0f <lapiceoi>
    break;
8010613d:	e9 02 01 00 00       	jmp    80106244 <trap+0x1da>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106142:	e8 53 03 00 00       	call   8010649a <uartintr>
    lapiceoi();
80106147:	e8 c3 c9 ff ff       	call   80102b0f <lapiceoi>
    break;
8010614c:	e9 f3 00 00 00       	jmp    80106244 <trap+0x1da>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106151:	e8 69 2b 00 00       	call   80108cbf <i8254_intr>
    lapiceoi();
80106156:	e8 b4 c9 ff ff       	call   80102b0f <lapiceoi>
    break;
8010615b:	e9 e4 00 00 00       	jmp    80106244 <trap+0x1da>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106160:	8b 45 08             	mov    0x8(%ebp),%eax
80106163:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106166:	8b 45 08             	mov    0x8(%ebp),%eax
80106169:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010616d:	0f b7 d8             	movzwl %ax,%ebx
80106170:	e8 1b d8 ff ff       	call   80103990 <cpuid>
80106175:	56                   	push   %esi
80106176:	53                   	push   %ebx
80106177:	50                   	push   %eax
80106178:	68 c4 a5 10 80       	push   $0x8010a5c4
8010617d:	e8 72 a2 ff ff       	call   801003f4 <cprintf>
80106182:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106185:	e8 85 c9 ff ff       	call   80102b0f <lapiceoi>
    break;
8010618a:	e9 b5 00 00 00       	jmp    80106244 <trap+0x1da>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
8010618f:	e8 8f d8 ff ff       	call   80103a23 <myproc>
80106194:	85 c0                	test   %eax,%eax
80106196:	74 11                	je     801061a9 <trap+0x13f>
80106198:	8b 45 08             	mov    0x8(%ebp),%eax
8010619b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010619f:	0f b7 c0             	movzwl %ax,%eax
801061a2:	83 e0 03             	and    $0x3,%eax
801061a5:	85 c0                	test   %eax,%eax
801061a7:	75 39                	jne    801061e2 <trap+0x178>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801061a9:	e8 1d fd ff ff       	call   80105ecb <rcr2>
801061ae:	89 c3                	mov    %eax,%ebx
801061b0:	8b 45 08             	mov    0x8(%ebp),%eax
801061b3:	8b 70 38             	mov    0x38(%eax),%esi
801061b6:	e8 d5 d7 ff ff       	call   80103990 <cpuid>
801061bb:	8b 55 08             	mov    0x8(%ebp),%edx
801061be:	8b 52 30             	mov    0x30(%edx),%edx
801061c1:	83 ec 0c             	sub    $0xc,%esp
801061c4:	53                   	push   %ebx
801061c5:	56                   	push   %esi
801061c6:	50                   	push   %eax
801061c7:	52                   	push   %edx
801061c8:	68 e8 a5 10 80       	push   $0x8010a5e8
801061cd:	e8 22 a2 ff ff       	call   801003f4 <cprintf>
801061d2:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
801061d5:	83 ec 0c             	sub    $0xc,%esp
801061d8:	68 1a a6 10 80       	push   $0x8010a61a
801061dd:	e8 c7 a3 ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801061e2:	e8 e4 fc ff ff       	call   80105ecb <rcr2>
801061e7:	89 c6                	mov    %eax,%esi
801061e9:	8b 45 08             	mov    0x8(%ebp),%eax
801061ec:	8b 40 38             	mov    0x38(%eax),%eax
801061ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801061f2:	e8 99 d7 ff ff       	call   80103990 <cpuid>
801061f7:	89 c3                	mov    %eax,%ebx
801061f9:	8b 45 08             	mov    0x8(%ebp),%eax
801061fc:	8b 48 34             	mov    0x34(%eax),%ecx
801061ff:	89 4d e0             	mov    %ecx,-0x20(%ebp)
80106202:	8b 45 08             	mov    0x8(%ebp),%eax
80106205:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106208:	e8 16 d8 ff ff       	call   80103a23 <myproc>
8010620d:	8d 50 6c             	lea    0x6c(%eax),%edx
80106210:	89 55 dc             	mov    %edx,-0x24(%ebp)
80106213:	e8 0b d8 ff ff       	call   80103a23 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106218:	8b 40 10             	mov    0x10(%eax),%eax
8010621b:	56                   	push   %esi
8010621c:	ff 75 e4             	push   -0x1c(%ebp)
8010621f:	53                   	push   %ebx
80106220:	ff 75 e0             	push   -0x20(%ebp)
80106223:	57                   	push   %edi
80106224:	ff 75 dc             	push   -0x24(%ebp)
80106227:	50                   	push   %eax
80106228:	68 20 a6 10 80       	push   $0x8010a620
8010622d:	e8 c2 a1 ff ff       	call   801003f4 <cprintf>
80106232:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106235:	e8 e9 d7 ff ff       	call   80103a23 <myproc>
8010623a:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106241:	eb 01                	jmp    80106244 <trap+0x1da>
    break;
80106243:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106244:	e8 da d7 ff ff       	call   80103a23 <myproc>
80106249:	85 c0                	test   %eax,%eax
8010624b:	74 23                	je     80106270 <trap+0x206>
8010624d:	e8 d1 d7 ff ff       	call   80103a23 <myproc>
80106252:	8b 40 24             	mov    0x24(%eax),%eax
80106255:	85 c0                	test   %eax,%eax
80106257:	74 17                	je     80106270 <trap+0x206>
80106259:	8b 45 08             	mov    0x8(%ebp),%eax
8010625c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106260:	0f b7 c0             	movzwl %ax,%eax
80106263:	83 e0 03             	and    $0x3,%eax
80106266:	83 f8 03             	cmp    $0x3,%eax
80106269:	75 05                	jne    80106270 <trap+0x206>
    exit();
8010626b:	e8 2b dc ff ff       	call   80103e9b <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106270:	e8 ae d7 ff ff       	call   80103a23 <myproc>
80106275:	85 c0                	test   %eax,%eax
80106277:	74 1d                	je     80106296 <trap+0x22c>
80106279:	e8 a5 d7 ff ff       	call   80103a23 <myproc>
8010627e:	8b 40 0c             	mov    0xc(%eax),%eax
80106281:	83 f8 04             	cmp    $0x4,%eax
80106284:	75 10                	jne    80106296 <trap+0x22c>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106286:	8b 45 08             	mov    0x8(%ebp),%eax
80106289:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
8010628c:	83 f8 20             	cmp    $0x20,%eax
8010628f:	75 05                	jne    80106296 <trap+0x22c>
    yield();
80106291:	e8 b6 df ff ff       	call   8010424c <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106296:	e8 88 d7 ff ff       	call   80103a23 <myproc>
8010629b:	85 c0                	test   %eax,%eax
8010629d:	74 26                	je     801062c5 <trap+0x25b>
8010629f:	e8 7f d7 ff ff       	call   80103a23 <myproc>
801062a4:	8b 40 24             	mov    0x24(%eax),%eax
801062a7:	85 c0                	test   %eax,%eax
801062a9:	74 1a                	je     801062c5 <trap+0x25b>
801062ab:	8b 45 08             	mov    0x8(%ebp),%eax
801062ae:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801062b2:	0f b7 c0             	movzwl %ax,%eax
801062b5:	83 e0 03             	and    $0x3,%eax
801062b8:	83 f8 03             	cmp    $0x3,%eax
801062bb:	75 08                	jne    801062c5 <trap+0x25b>
    exit();
801062bd:	e8 d9 db ff ff       	call   80103e9b <exit>
801062c2:	eb 01                	jmp    801062c5 <trap+0x25b>
    return;
801062c4:	90                   	nop
}
801062c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801062c8:	5b                   	pop    %ebx
801062c9:	5e                   	pop    %esi
801062ca:	5f                   	pop    %edi
801062cb:	5d                   	pop    %ebp
801062cc:	c3                   	ret    

801062cd <inb>:
{
801062cd:	55                   	push   %ebp
801062ce:	89 e5                	mov    %esp,%ebp
801062d0:	83 ec 14             	sub    $0x14,%esp
801062d3:	8b 45 08             	mov    0x8(%ebp),%eax
801062d6:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801062da:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801062de:	89 c2                	mov    %eax,%edx
801062e0:	ec                   	in     (%dx),%al
801062e1:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801062e4:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801062e8:	c9                   	leave  
801062e9:	c3                   	ret    

801062ea <outb>:
{
801062ea:	55                   	push   %ebp
801062eb:	89 e5                	mov    %esp,%ebp
801062ed:	83 ec 08             	sub    $0x8,%esp
801062f0:	8b 45 08             	mov    0x8(%ebp),%eax
801062f3:	8b 55 0c             	mov    0xc(%ebp),%edx
801062f6:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801062fa:	89 d0                	mov    %edx,%eax
801062fc:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801062ff:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106303:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106307:	ee                   	out    %al,(%dx)
}
80106308:	90                   	nop
80106309:	c9                   	leave  
8010630a:	c3                   	ret    

8010630b <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
8010630b:	55                   	push   %ebp
8010630c:	89 e5                	mov    %esp,%ebp
8010630e:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106311:	6a 00                	push   $0x0
80106313:	68 fa 03 00 00       	push   $0x3fa
80106318:	e8 cd ff ff ff       	call   801062ea <outb>
8010631d:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106320:	68 80 00 00 00       	push   $0x80
80106325:	68 fb 03 00 00       	push   $0x3fb
8010632a:	e8 bb ff ff ff       	call   801062ea <outb>
8010632f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106332:	6a 0c                	push   $0xc
80106334:	68 f8 03 00 00       	push   $0x3f8
80106339:	e8 ac ff ff ff       	call   801062ea <outb>
8010633e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106341:	6a 00                	push   $0x0
80106343:	68 f9 03 00 00       	push   $0x3f9
80106348:	e8 9d ff ff ff       	call   801062ea <outb>
8010634d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106350:	6a 03                	push   $0x3
80106352:	68 fb 03 00 00       	push   $0x3fb
80106357:	e8 8e ff ff ff       	call   801062ea <outb>
8010635c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010635f:	6a 00                	push   $0x0
80106361:	68 fc 03 00 00       	push   $0x3fc
80106366:	e8 7f ff ff ff       	call   801062ea <outb>
8010636b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
8010636e:	6a 01                	push   $0x1
80106370:	68 f9 03 00 00       	push   $0x3f9
80106375:	e8 70 ff ff ff       	call   801062ea <outb>
8010637a:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
8010637d:	68 fd 03 00 00       	push   $0x3fd
80106382:	e8 46 ff ff ff       	call   801062cd <inb>
80106387:	83 c4 04             	add    $0x4,%esp
8010638a:	3c ff                	cmp    $0xff,%al
8010638c:	74 61                	je     801063ef <uartinit+0xe4>
    return;
  uart = 1;
8010638e:	c7 05 78 69 19 80 01 	movl   $0x1,0x80196978
80106395:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106398:	68 fa 03 00 00       	push   $0x3fa
8010639d:	e8 2b ff ff ff       	call   801062cd <inb>
801063a2:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801063a5:	68 f8 03 00 00       	push   $0x3f8
801063aa:	e8 1e ff ff ff       	call   801062cd <inb>
801063af:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
801063b2:	83 ec 08             	sub    $0x8,%esp
801063b5:	6a 00                	push   $0x0
801063b7:	6a 04                	push   $0x4
801063b9:	e8 63 c2 ff ff       	call   80102621 <ioapicenable>
801063be:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801063c1:	c7 45 f4 e4 a6 10 80 	movl   $0x8010a6e4,-0xc(%ebp)
801063c8:	eb 19                	jmp    801063e3 <uartinit+0xd8>
    uartputc(*p);
801063ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063cd:	0f b6 00             	movzbl (%eax),%eax
801063d0:	0f be c0             	movsbl %al,%eax
801063d3:	83 ec 0c             	sub    $0xc,%esp
801063d6:	50                   	push   %eax
801063d7:	e8 16 00 00 00       	call   801063f2 <uartputc>
801063dc:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
801063df:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801063e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063e6:	0f b6 00             	movzbl (%eax),%eax
801063e9:	84 c0                	test   %al,%al
801063eb:	75 dd                	jne    801063ca <uartinit+0xbf>
801063ed:	eb 01                	jmp    801063f0 <uartinit+0xe5>
    return;
801063ef:	90                   	nop
}
801063f0:	c9                   	leave  
801063f1:	c3                   	ret    

801063f2 <uartputc>:

void
uartputc(int c)
{
801063f2:	55                   	push   %ebp
801063f3:	89 e5                	mov    %esp,%ebp
801063f5:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801063f8:	a1 78 69 19 80       	mov    0x80196978,%eax
801063fd:	85 c0                	test   %eax,%eax
801063ff:	74 53                	je     80106454 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106401:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106408:	eb 11                	jmp    8010641b <uartputc+0x29>
    microdelay(10);
8010640a:	83 ec 0c             	sub    $0xc,%esp
8010640d:	6a 0a                	push   $0xa
8010640f:	e8 16 c7 ff ff       	call   80102b2a <microdelay>
80106414:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106417:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010641b:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010641f:	7f 1a                	jg     8010643b <uartputc+0x49>
80106421:	83 ec 0c             	sub    $0xc,%esp
80106424:	68 fd 03 00 00       	push   $0x3fd
80106429:	e8 9f fe ff ff       	call   801062cd <inb>
8010642e:	83 c4 10             	add    $0x10,%esp
80106431:	0f b6 c0             	movzbl %al,%eax
80106434:	83 e0 20             	and    $0x20,%eax
80106437:	85 c0                	test   %eax,%eax
80106439:	74 cf                	je     8010640a <uartputc+0x18>
  outb(COM1+0, c);
8010643b:	8b 45 08             	mov    0x8(%ebp),%eax
8010643e:	0f b6 c0             	movzbl %al,%eax
80106441:	83 ec 08             	sub    $0x8,%esp
80106444:	50                   	push   %eax
80106445:	68 f8 03 00 00       	push   $0x3f8
8010644a:	e8 9b fe ff ff       	call   801062ea <outb>
8010644f:	83 c4 10             	add    $0x10,%esp
80106452:	eb 01                	jmp    80106455 <uartputc+0x63>
    return;
80106454:	90                   	nop
}
80106455:	c9                   	leave  
80106456:	c3                   	ret    

80106457 <uartgetc>:

static int
uartgetc(void)
{
80106457:	55                   	push   %ebp
80106458:	89 e5                	mov    %esp,%ebp
  if(!uart)
8010645a:	a1 78 69 19 80       	mov    0x80196978,%eax
8010645f:	85 c0                	test   %eax,%eax
80106461:	75 07                	jne    8010646a <uartgetc+0x13>
    return -1;
80106463:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106468:	eb 2e                	jmp    80106498 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
8010646a:	68 fd 03 00 00       	push   $0x3fd
8010646f:	e8 59 fe ff ff       	call   801062cd <inb>
80106474:	83 c4 04             	add    $0x4,%esp
80106477:	0f b6 c0             	movzbl %al,%eax
8010647a:	83 e0 01             	and    $0x1,%eax
8010647d:	85 c0                	test   %eax,%eax
8010647f:	75 07                	jne    80106488 <uartgetc+0x31>
    return -1;
80106481:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106486:	eb 10                	jmp    80106498 <uartgetc+0x41>
  return inb(COM1+0);
80106488:	68 f8 03 00 00       	push   $0x3f8
8010648d:	e8 3b fe ff ff       	call   801062cd <inb>
80106492:	83 c4 04             	add    $0x4,%esp
80106495:	0f b6 c0             	movzbl %al,%eax
}
80106498:	c9                   	leave  
80106499:	c3                   	ret    

8010649a <uartintr>:

void
uartintr(void)
{
8010649a:	55                   	push   %ebp
8010649b:	89 e5                	mov    %esp,%ebp
8010649d:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
801064a0:	83 ec 0c             	sub    $0xc,%esp
801064a3:	68 57 64 10 80       	push   $0x80106457
801064a8:	e8 29 a3 ff ff       	call   801007d6 <consoleintr>
801064ad:	83 c4 10             	add    $0x10,%esp
}
801064b0:	90                   	nop
801064b1:	c9                   	leave  
801064b2:	c3                   	ret    

801064b3 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801064b3:	6a 00                	push   $0x0
  pushl $0
801064b5:	6a 00                	push   $0x0
  jmp alltraps
801064b7:	e9 c2 f9 ff ff       	jmp    80105e7e <alltraps>

801064bc <vector1>:
.globl vector1
vector1:
  pushl $0
801064bc:	6a 00                	push   $0x0
  pushl $1
801064be:	6a 01                	push   $0x1
  jmp alltraps
801064c0:	e9 b9 f9 ff ff       	jmp    80105e7e <alltraps>

801064c5 <vector2>:
.globl vector2
vector2:
  pushl $0
801064c5:	6a 00                	push   $0x0
  pushl $2
801064c7:	6a 02                	push   $0x2
  jmp alltraps
801064c9:	e9 b0 f9 ff ff       	jmp    80105e7e <alltraps>

801064ce <vector3>:
.globl vector3
vector3:
  pushl $0
801064ce:	6a 00                	push   $0x0
  pushl $3
801064d0:	6a 03                	push   $0x3
  jmp alltraps
801064d2:	e9 a7 f9 ff ff       	jmp    80105e7e <alltraps>

801064d7 <vector4>:
.globl vector4
vector4:
  pushl $0
801064d7:	6a 00                	push   $0x0
  pushl $4
801064d9:	6a 04                	push   $0x4
  jmp alltraps
801064db:	e9 9e f9 ff ff       	jmp    80105e7e <alltraps>

801064e0 <vector5>:
.globl vector5
vector5:
  pushl $0
801064e0:	6a 00                	push   $0x0
  pushl $5
801064e2:	6a 05                	push   $0x5
  jmp alltraps
801064e4:	e9 95 f9 ff ff       	jmp    80105e7e <alltraps>

801064e9 <vector6>:
.globl vector6
vector6:
  pushl $0
801064e9:	6a 00                	push   $0x0
  pushl $6
801064eb:	6a 06                	push   $0x6
  jmp alltraps
801064ed:	e9 8c f9 ff ff       	jmp    80105e7e <alltraps>

801064f2 <vector7>:
.globl vector7
vector7:
  pushl $0
801064f2:	6a 00                	push   $0x0
  pushl $7
801064f4:	6a 07                	push   $0x7
  jmp alltraps
801064f6:	e9 83 f9 ff ff       	jmp    80105e7e <alltraps>

801064fb <vector8>:
.globl vector8
vector8:
  pushl $8
801064fb:	6a 08                	push   $0x8
  jmp alltraps
801064fd:	e9 7c f9 ff ff       	jmp    80105e7e <alltraps>

80106502 <vector9>:
.globl vector9
vector9:
  pushl $0
80106502:	6a 00                	push   $0x0
  pushl $9
80106504:	6a 09                	push   $0x9
  jmp alltraps
80106506:	e9 73 f9 ff ff       	jmp    80105e7e <alltraps>

8010650b <vector10>:
.globl vector10
vector10:
  pushl $10
8010650b:	6a 0a                	push   $0xa
  jmp alltraps
8010650d:	e9 6c f9 ff ff       	jmp    80105e7e <alltraps>

80106512 <vector11>:
.globl vector11
vector11:
  pushl $11
80106512:	6a 0b                	push   $0xb
  jmp alltraps
80106514:	e9 65 f9 ff ff       	jmp    80105e7e <alltraps>

80106519 <vector12>:
.globl vector12
vector12:
  pushl $12
80106519:	6a 0c                	push   $0xc
  jmp alltraps
8010651b:	e9 5e f9 ff ff       	jmp    80105e7e <alltraps>

80106520 <vector13>:
.globl vector13
vector13:
  pushl $13
80106520:	6a 0d                	push   $0xd
  jmp alltraps
80106522:	e9 57 f9 ff ff       	jmp    80105e7e <alltraps>

80106527 <vector14>:
.globl vector14
vector14:
  pushl $14
80106527:	6a 0e                	push   $0xe
  jmp alltraps
80106529:	e9 50 f9 ff ff       	jmp    80105e7e <alltraps>

8010652e <vector15>:
.globl vector15
vector15:
  pushl $0
8010652e:	6a 00                	push   $0x0
  pushl $15
80106530:	6a 0f                	push   $0xf
  jmp alltraps
80106532:	e9 47 f9 ff ff       	jmp    80105e7e <alltraps>

80106537 <vector16>:
.globl vector16
vector16:
  pushl $0
80106537:	6a 00                	push   $0x0
  pushl $16
80106539:	6a 10                	push   $0x10
  jmp alltraps
8010653b:	e9 3e f9 ff ff       	jmp    80105e7e <alltraps>

80106540 <vector17>:
.globl vector17
vector17:
  pushl $17
80106540:	6a 11                	push   $0x11
  jmp alltraps
80106542:	e9 37 f9 ff ff       	jmp    80105e7e <alltraps>

80106547 <vector18>:
.globl vector18
vector18:
  pushl $0
80106547:	6a 00                	push   $0x0
  pushl $18
80106549:	6a 12                	push   $0x12
  jmp alltraps
8010654b:	e9 2e f9 ff ff       	jmp    80105e7e <alltraps>

80106550 <vector19>:
.globl vector19
vector19:
  pushl $0
80106550:	6a 00                	push   $0x0
  pushl $19
80106552:	6a 13                	push   $0x13
  jmp alltraps
80106554:	e9 25 f9 ff ff       	jmp    80105e7e <alltraps>

80106559 <vector20>:
.globl vector20
vector20:
  pushl $0
80106559:	6a 00                	push   $0x0
  pushl $20
8010655b:	6a 14                	push   $0x14
  jmp alltraps
8010655d:	e9 1c f9 ff ff       	jmp    80105e7e <alltraps>

80106562 <vector21>:
.globl vector21
vector21:
  pushl $0
80106562:	6a 00                	push   $0x0
  pushl $21
80106564:	6a 15                	push   $0x15
  jmp alltraps
80106566:	e9 13 f9 ff ff       	jmp    80105e7e <alltraps>

8010656b <vector22>:
.globl vector22
vector22:
  pushl $0
8010656b:	6a 00                	push   $0x0
  pushl $22
8010656d:	6a 16                	push   $0x16
  jmp alltraps
8010656f:	e9 0a f9 ff ff       	jmp    80105e7e <alltraps>

80106574 <vector23>:
.globl vector23
vector23:
  pushl $0
80106574:	6a 00                	push   $0x0
  pushl $23
80106576:	6a 17                	push   $0x17
  jmp alltraps
80106578:	e9 01 f9 ff ff       	jmp    80105e7e <alltraps>

8010657d <vector24>:
.globl vector24
vector24:
  pushl $0
8010657d:	6a 00                	push   $0x0
  pushl $24
8010657f:	6a 18                	push   $0x18
  jmp alltraps
80106581:	e9 f8 f8 ff ff       	jmp    80105e7e <alltraps>

80106586 <vector25>:
.globl vector25
vector25:
  pushl $0
80106586:	6a 00                	push   $0x0
  pushl $25
80106588:	6a 19                	push   $0x19
  jmp alltraps
8010658a:	e9 ef f8 ff ff       	jmp    80105e7e <alltraps>

8010658f <vector26>:
.globl vector26
vector26:
  pushl $0
8010658f:	6a 00                	push   $0x0
  pushl $26
80106591:	6a 1a                	push   $0x1a
  jmp alltraps
80106593:	e9 e6 f8 ff ff       	jmp    80105e7e <alltraps>

80106598 <vector27>:
.globl vector27
vector27:
  pushl $0
80106598:	6a 00                	push   $0x0
  pushl $27
8010659a:	6a 1b                	push   $0x1b
  jmp alltraps
8010659c:	e9 dd f8 ff ff       	jmp    80105e7e <alltraps>

801065a1 <vector28>:
.globl vector28
vector28:
  pushl $0
801065a1:	6a 00                	push   $0x0
  pushl $28
801065a3:	6a 1c                	push   $0x1c
  jmp alltraps
801065a5:	e9 d4 f8 ff ff       	jmp    80105e7e <alltraps>

801065aa <vector29>:
.globl vector29
vector29:
  pushl $0
801065aa:	6a 00                	push   $0x0
  pushl $29
801065ac:	6a 1d                	push   $0x1d
  jmp alltraps
801065ae:	e9 cb f8 ff ff       	jmp    80105e7e <alltraps>

801065b3 <vector30>:
.globl vector30
vector30:
  pushl $0
801065b3:	6a 00                	push   $0x0
  pushl $30
801065b5:	6a 1e                	push   $0x1e
  jmp alltraps
801065b7:	e9 c2 f8 ff ff       	jmp    80105e7e <alltraps>

801065bc <vector31>:
.globl vector31
vector31:
  pushl $0
801065bc:	6a 00                	push   $0x0
  pushl $31
801065be:	6a 1f                	push   $0x1f
  jmp alltraps
801065c0:	e9 b9 f8 ff ff       	jmp    80105e7e <alltraps>

801065c5 <vector32>:
.globl vector32
vector32:
  pushl $0
801065c5:	6a 00                	push   $0x0
  pushl $32
801065c7:	6a 20                	push   $0x20
  jmp alltraps
801065c9:	e9 b0 f8 ff ff       	jmp    80105e7e <alltraps>

801065ce <vector33>:
.globl vector33
vector33:
  pushl $0
801065ce:	6a 00                	push   $0x0
  pushl $33
801065d0:	6a 21                	push   $0x21
  jmp alltraps
801065d2:	e9 a7 f8 ff ff       	jmp    80105e7e <alltraps>

801065d7 <vector34>:
.globl vector34
vector34:
  pushl $0
801065d7:	6a 00                	push   $0x0
  pushl $34
801065d9:	6a 22                	push   $0x22
  jmp alltraps
801065db:	e9 9e f8 ff ff       	jmp    80105e7e <alltraps>

801065e0 <vector35>:
.globl vector35
vector35:
  pushl $0
801065e0:	6a 00                	push   $0x0
  pushl $35
801065e2:	6a 23                	push   $0x23
  jmp alltraps
801065e4:	e9 95 f8 ff ff       	jmp    80105e7e <alltraps>

801065e9 <vector36>:
.globl vector36
vector36:
  pushl $0
801065e9:	6a 00                	push   $0x0
  pushl $36
801065eb:	6a 24                	push   $0x24
  jmp alltraps
801065ed:	e9 8c f8 ff ff       	jmp    80105e7e <alltraps>

801065f2 <vector37>:
.globl vector37
vector37:
  pushl $0
801065f2:	6a 00                	push   $0x0
  pushl $37
801065f4:	6a 25                	push   $0x25
  jmp alltraps
801065f6:	e9 83 f8 ff ff       	jmp    80105e7e <alltraps>

801065fb <vector38>:
.globl vector38
vector38:
  pushl $0
801065fb:	6a 00                	push   $0x0
  pushl $38
801065fd:	6a 26                	push   $0x26
  jmp alltraps
801065ff:	e9 7a f8 ff ff       	jmp    80105e7e <alltraps>

80106604 <vector39>:
.globl vector39
vector39:
  pushl $0
80106604:	6a 00                	push   $0x0
  pushl $39
80106606:	6a 27                	push   $0x27
  jmp alltraps
80106608:	e9 71 f8 ff ff       	jmp    80105e7e <alltraps>

8010660d <vector40>:
.globl vector40
vector40:
  pushl $0
8010660d:	6a 00                	push   $0x0
  pushl $40
8010660f:	6a 28                	push   $0x28
  jmp alltraps
80106611:	e9 68 f8 ff ff       	jmp    80105e7e <alltraps>

80106616 <vector41>:
.globl vector41
vector41:
  pushl $0
80106616:	6a 00                	push   $0x0
  pushl $41
80106618:	6a 29                	push   $0x29
  jmp alltraps
8010661a:	e9 5f f8 ff ff       	jmp    80105e7e <alltraps>

8010661f <vector42>:
.globl vector42
vector42:
  pushl $0
8010661f:	6a 00                	push   $0x0
  pushl $42
80106621:	6a 2a                	push   $0x2a
  jmp alltraps
80106623:	e9 56 f8 ff ff       	jmp    80105e7e <alltraps>

80106628 <vector43>:
.globl vector43
vector43:
  pushl $0
80106628:	6a 00                	push   $0x0
  pushl $43
8010662a:	6a 2b                	push   $0x2b
  jmp alltraps
8010662c:	e9 4d f8 ff ff       	jmp    80105e7e <alltraps>

80106631 <vector44>:
.globl vector44
vector44:
  pushl $0
80106631:	6a 00                	push   $0x0
  pushl $44
80106633:	6a 2c                	push   $0x2c
  jmp alltraps
80106635:	e9 44 f8 ff ff       	jmp    80105e7e <alltraps>

8010663a <vector45>:
.globl vector45
vector45:
  pushl $0
8010663a:	6a 00                	push   $0x0
  pushl $45
8010663c:	6a 2d                	push   $0x2d
  jmp alltraps
8010663e:	e9 3b f8 ff ff       	jmp    80105e7e <alltraps>

80106643 <vector46>:
.globl vector46
vector46:
  pushl $0
80106643:	6a 00                	push   $0x0
  pushl $46
80106645:	6a 2e                	push   $0x2e
  jmp alltraps
80106647:	e9 32 f8 ff ff       	jmp    80105e7e <alltraps>

8010664c <vector47>:
.globl vector47
vector47:
  pushl $0
8010664c:	6a 00                	push   $0x0
  pushl $47
8010664e:	6a 2f                	push   $0x2f
  jmp alltraps
80106650:	e9 29 f8 ff ff       	jmp    80105e7e <alltraps>

80106655 <vector48>:
.globl vector48
vector48:
  pushl $0
80106655:	6a 00                	push   $0x0
  pushl $48
80106657:	6a 30                	push   $0x30
  jmp alltraps
80106659:	e9 20 f8 ff ff       	jmp    80105e7e <alltraps>

8010665e <vector49>:
.globl vector49
vector49:
  pushl $0
8010665e:	6a 00                	push   $0x0
  pushl $49
80106660:	6a 31                	push   $0x31
  jmp alltraps
80106662:	e9 17 f8 ff ff       	jmp    80105e7e <alltraps>

80106667 <vector50>:
.globl vector50
vector50:
  pushl $0
80106667:	6a 00                	push   $0x0
  pushl $50
80106669:	6a 32                	push   $0x32
  jmp alltraps
8010666b:	e9 0e f8 ff ff       	jmp    80105e7e <alltraps>

80106670 <vector51>:
.globl vector51
vector51:
  pushl $0
80106670:	6a 00                	push   $0x0
  pushl $51
80106672:	6a 33                	push   $0x33
  jmp alltraps
80106674:	e9 05 f8 ff ff       	jmp    80105e7e <alltraps>

80106679 <vector52>:
.globl vector52
vector52:
  pushl $0
80106679:	6a 00                	push   $0x0
  pushl $52
8010667b:	6a 34                	push   $0x34
  jmp alltraps
8010667d:	e9 fc f7 ff ff       	jmp    80105e7e <alltraps>

80106682 <vector53>:
.globl vector53
vector53:
  pushl $0
80106682:	6a 00                	push   $0x0
  pushl $53
80106684:	6a 35                	push   $0x35
  jmp alltraps
80106686:	e9 f3 f7 ff ff       	jmp    80105e7e <alltraps>

8010668b <vector54>:
.globl vector54
vector54:
  pushl $0
8010668b:	6a 00                	push   $0x0
  pushl $54
8010668d:	6a 36                	push   $0x36
  jmp alltraps
8010668f:	e9 ea f7 ff ff       	jmp    80105e7e <alltraps>

80106694 <vector55>:
.globl vector55
vector55:
  pushl $0
80106694:	6a 00                	push   $0x0
  pushl $55
80106696:	6a 37                	push   $0x37
  jmp alltraps
80106698:	e9 e1 f7 ff ff       	jmp    80105e7e <alltraps>

8010669d <vector56>:
.globl vector56
vector56:
  pushl $0
8010669d:	6a 00                	push   $0x0
  pushl $56
8010669f:	6a 38                	push   $0x38
  jmp alltraps
801066a1:	e9 d8 f7 ff ff       	jmp    80105e7e <alltraps>

801066a6 <vector57>:
.globl vector57
vector57:
  pushl $0
801066a6:	6a 00                	push   $0x0
  pushl $57
801066a8:	6a 39                	push   $0x39
  jmp alltraps
801066aa:	e9 cf f7 ff ff       	jmp    80105e7e <alltraps>

801066af <vector58>:
.globl vector58
vector58:
  pushl $0
801066af:	6a 00                	push   $0x0
  pushl $58
801066b1:	6a 3a                	push   $0x3a
  jmp alltraps
801066b3:	e9 c6 f7 ff ff       	jmp    80105e7e <alltraps>

801066b8 <vector59>:
.globl vector59
vector59:
  pushl $0
801066b8:	6a 00                	push   $0x0
  pushl $59
801066ba:	6a 3b                	push   $0x3b
  jmp alltraps
801066bc:	e9 bd f7 ff ff       	jmp    80105e7e <alltraps>

801066c1 <vector60>:
.globl vector60
vector60:
  pushl $0
801066c1:	6a 00                	push   $0x0
  pushl $60
801066c3:	6a 3c                	push   $0x3c
  jmp alltraps
801066c5:	e9 b4 f7 ff ff       	jmp    80105e7e <alltraps>

801066ca <vector61>:
.globl vector61
vector61:
  pushl $0
801066ca:	6a 00                	push   $0x0
  pushl $61
801066cc:	6a 3d                	push   $0x3d
  jmp alltraps
801066ce:	e9 ab f7 ff ff       	jmp    80105e7e <alltraps>

801066d3 <vector62>:
.globl vector62
vector62:
  pushl $0
801066d3:	6a 00                	push   $0x0
  pushl $62
801066d5:	6a 3e                	push   $0x3e
  jmp alltraps
801066d7:	e9 a2 f7 ff ff       	jmp    80105e7e <alltraps>

801066dc <vector63>:
.globl vector63
vector63:
  pushl $0
801066dc:	6a 00                	push   $0x0
  pushl $63
801066de:	6a 3f                	push   $0x3f
  jmp alltraps
801066e0:	e9 99 f7 ff ff       	jmp    80105e7e <alltraps>

801066e5 <vector64>:
.globl vector64
vector64:
  pushl $0
801066e5:	6a 00                	push   $0x0
  pushl $64
801066e7:	6a 40                	push   $0x40
  jmp alltraps
801066e9:	e9 90 f7 ff ff       	jmp    80105e7e <alltraps>

801066ee <vector65>:
.globl vector65
vector65:
  pushl $0
801066ee:	6a 00                	push   $0x0
  pushl $65
801066f0:	6a 41                	push   $0x41
  jmp alltraps
801066f2:	e9 87 f7 ff ff       	jmp    80105e7e <alltraps>

801066f7 <vector66>:
.globl vector66
vector66:
  pushl $0
801066f7:	6a 00                	push   $0x0
  pushl $66
801066f9:	6a 42                	push   $0x42
  jmp alltraps
801066fb:	e9 7e f7 ff ff       	jmp    80105e7e <alltraps>

80106700 <vector67>:
.globl vector67
vector67:
  pushl $0
80106700:	6a 00                	push   $0x0
  pushl $67
80106702:	6a 43                	push   $0x43
  jmp alltraps
80106704:	e9 75 f7 ff ff       	jmp    80105e7e <alltraps>

80106709 <vector68>:
.globl vector68
vector68:
  pushl $0
80106709:	6a 00                	push   $0x0
  pushl $68
8010670b:	6a 44                	push   $0x44
  jmp alltraps
8010670d:	e9 6c f7 ff ff       	jmp    80105e7e <alltraps>

80106712 <vector69>:
.globl vector69
vector69:
  pushl $0
80106712:	6a 00                	push   $0x0
  pushl $69
80106714:	6a 45                	push   $0x45
  jmp alltraps
80106716:	e9 63 f7 ff ff       	jmp    80105e7e <alltraps>

8010671b <vector70>:
.globl vector70
vector70:
  pushl $0
8010671b:	6a 00                	push   $0x0
  pushl $70
8010671d:	6a 46                	push   $0x46
  jmp alltraps
8010671f:	e9 5a f7 ff ff       	jmp    80105e7e <alltraps>

80106724 <vector71>:
.globl vector71
vector71:
  pushl $0
80106724:	6a 00                	push   $0x0
  pushl $71
80106726:	6a 47                	push   $0x47
  jmp alltraps
80106728:	e9 51 f7 ff ff       	jmp    80105e7e <alltraps>

8010672d <vector72>:
.globl vector72
vector72:
  pushl $0
8010672d:	6a 00                	push   $0x0
  pushl $72
8010672f:	6a 48                	push   $0x48
  jmp alltraps
80106731:	e9 48 f7 ff ff       	jmp    80105e7e <alltraps>

80106736 <vector73>:
.globl vector73
vector73:
  pushl $0
80106736:	6a 00                	push   $0x0
  pushl $73
80106738:	6a 49                	push   $0x49
  jmp alltraps
8010673a:	e9 3f f7 ff ff       	jmp    80105e7e <alltraps>

8010673f <vector74>:
.globl vector74
vector74:
  pushl $0
8010673f:	6a 00                	push   $0x0
  pushl $74
80106741:	6a 4a                	push   $0x4a
  jmp alltraps
80106743:	e9 36 f7 ff ff       	jmp    80105e7e <alltraps>

80106748 <vector75>:
.globl vector75
vector75:
  pushl $0
80106748:	6a 00                	push   $0x0
  pushl $75
8010674a:	6a 4b                	push   $0x4b
  jmp alltraps
8010674c:	e9 2d f7 ff ff       	jmp    80105e7e <alltraps>

80106751 <vector76>:
.globl vector76
vector76:
  pushl $0
80106751:	6a 00                	push   $0x0
  pushl $76
80106753:	6a 4c                	push   $0x4c
  jmp alltraps
80106755:	e9 24 f7 ff ff       	jmp    80105e7e <alltraps>

8010675a <vector77>:
.globl vector77
vector77:
  pushl $0
8010675a:	6a 00                	push   $0x0
  pushl $77
8010675c:	6a 4d                	push   $0x4d
  jmp alltraps
8010675e:	e9 1b f7 ff ff       	jmp    80105e7e <alltraps>

80106763 <vector78>:
.globl vector78
vector78:
  pushl $0
80106763:	6a 00                	push   $0x0
  pushl $78
80106765:	6a 4e                	push   $0x4e
  jmp alltraps
80106767:	e9 12 f7 ff ff       	jmp    80105e7e <alltraps>

8010676c <vector79>:
.globl vector79
vector79:
  pushl $0
8010676c:	6a 00                	push   $0x0
  pushl $79
8010676e:	6a 4f                	push   $0x4f
  jmp alltraps
80106770:	e9 09 f7 ff ff       	jmp    80105e7e <alltraps>

80106775 <vector80>:
.globl vector80
vector80:
  pushl $0
80106775:	6a 00                	push   $0x0
  pushl $80
80106777:	6a 50                	push   $0x50
  jmp alltraps
80106779:	e9 00 f7 ff ff       	jmp    80105e7e <alltraps>

8010677e <vector81>:
.globl vector81
vector81:
  pushl $0
8010677e:	6a 00                	push   $0x0
  pushl $81
80106780:	6a 51                	push   $0x51
  jmp alltraps
80106782:	e9 f7 f6 ff ff       	jmp    80105e7e <alltraps>

80106787 <vector82>:
.globl vector82
vector82:
  pushl $0
80106787:	6a 00                	push   $0x0
  pushl $82
80106789:	6a 52                	push   $0x52
  jmp alltraps
8010678b:	e9 ee f6 ff ff       	jmp    80105e7e <alltraps>

80106790 <vector83>:
.globl vector83
vector83:
  pushl $0
80106790:	6a 00                	push   $0x0
  pushl $83
80106792:	6a 53                	push   $0x53
  jmp alltraps
80106794:	e9 e5 f6 ff ff       	jmp    80105e7e <alltraps>

80106799 <vector84>:
.globl vector84
vector84:
  pushl $0
80106799:	6a 00                	push   $0x0
  pushl $84
8010679b:	6a 54                	push   $0x54
  jmp alltraps
8010679d:	e9 dc f6 ff ff       	jmp    80105e7e <alltraps>

801067a2 <vector85>:
.globl vector85
vector85:
  pushl $0
801067a2:	6a 00                	push   $0x0
  pushl $85
801067a4:	6a 55                	push   $0x55
  jmp alltraps
801067a6:	e9 d3 f6 ff ff       	jmp    80105e7e <alltraps>

801067ab <vector86>:
.globl vector86
vector86:
  pushl $0
801067ab:	6a 00                	push   $0x0
  pushl $86
801067ad:	6a 56                	push   $0x56
  jmp alltraps
801067af:	e9 ca f6 ff ff       	jmp    80105e7e <alltraps>

801067b4 <vector87>:
.globl vector87
vector87:
  pushl $0
801067b4:	6a 00                	push   $0x0
  pushl $87
801067b6:	6a 57                	push   $0x57
  jmp alltraps
801067b8:	e9 c1 f6 ff ff       	jmp    80105e7e <alltraps>

801067bd <vector88>:
.globl vector88
vector88:
  pushl $0
801067bd:	6a 00                	push   $0x0
  pushl $88
801067bf:	6a 58                	push   $0x58
  jmp alltraps
801067c1:	e9 b8 f6 ff ff       	jmp    80105e7e <alltraps>

801067c6 <vector89>:
.globl vector89
vector89:
  pushl $0
801067c6:	6a 00                	push   $0x0
  pushl $89
801067c8:	6a 59                	push   $0x59
  jmp alltraps
801067ca:	e9 af f6 ff ff       	jmp    80105e7e <alltraps>

801067cf <vector90>:
.globl vector90
vector90:
  pushl $0
801067cf:	6a 00                	push   $0x0
  pushl $90
801067d1:	6a 5a                	push   $0x5a
  jmp alltraps
801067d3:	e9 a6 f6 ff ff       	jmp    80105e7e <alltraps>

801067d8 <vector91>:
.globl vector91
vector91:
  pushl $0
801067d8:	6a 00                	push   $0x0
  pushl $91
801067da:	6a 5b                	push   $0x5b
  jmp alltraps
801067dc:	e9 9d f6 ff ff       	jmp    80105e7e <alltraps>

801067e1 <vector92>:
.globl vector92
vector92:
  pushl $0
801067e1:	6a 00                	push   $0x0
  pushl $92
801067e3:	6a 5c                	push   $0x5c
  jmp alltraps
801067e5:	e9 94 f6 ff ff       	jmp    80105e7e <alltraps>

801067ea <vector93>:
.globl vector93
vector93:
  pushl $0
801067ea:	6a 00                	push   $0x0
  pushl $93
801067ec:	6a 5d                	push   $0x5d
  jmp alltraps
801067ee:	e9 8b f6 ff ff       	jmp    80105e7e <alltraps>

801067f3 <vector94>:
.globl vector94
vector94:
  pushl $0
801067f3:	6a 00                	push   $0x0
  pushl $94
801067f5:	6a 5e                	push   $0x5e
  jmp alltraps
801067f7:	e9 82 f6 ff ff       	jmp    80105e7e <alltraps>

801067fc <vector95>:
.globl vector95
vector95:
  pushl $0
801067fc:	6a 00                	push   $0x0
  pushl $95
801067fe:	6a 5f                	push   $0x5f
  jmp alltraps
80106800:	e9 79 f6 ff ff       	jmp    80105e7e <alltraps>

80106805 <vector96>:
.globl vector96
vector96:
  pushl $0
80106805:	6a 00                	push   $0x0
  pushl $96
80106807:	6a 60                	push   $0x60
  jmp alltraps
80106809:	e9 70 f6 ff ff       	jmp    80105e7e <alltraps>

8010680e <vector97>:
.globl vector97
vector97:
  pushl $0
8010680e:	6a 00                	push   $0x0
  pushl $97
80106810:	6a 61                	push   $0x61
  jmp alltraps
80106812:	e9 67 f6 ff ff       	jmp    80105e7e <alltraps>

80106817 <vector98>:
.globl vector98
vector98:
  pushl $0
80106817:	6a 00                	push   $0x0
  pushl $98
80106819:	6a 62                	push   $0x62
  jmp alltraps
8010681b:	e9 5e f6 ff ff       	jmp    80105e7e <alltraps>

80106820 <vector99>:
.globl vector99
vector99:
  pushl $0
80106820:	6a 00                	push   $0x0
  pushl $99
80106822:	6a 63                	push   $0x63
  jmp alltraps
80106824:	e9 55 f6 ff ff       	jmp    80105e7e <alltraps>

80106829 <vector100>:
.globl vector100
vector100:
  pushl $0
80106829:	6a 00                	push   $0x0
  pushl $100
8010682b:	6a 64                	push   $0x64
  jmp alltraps
8010682d:	e9 4c f6 ff ff       	jmp    80105e7e <alltraps>

80106832 <vector101>:
.globl vector101
vector101:
  pushl $0
80106832:	6a 00                	push   $0x0
  pushl $101
80106834:	6a 65                	push   $0x65
  jmp alltraps
80106836:	e9 43 f6 ff ff       	jmp    80105e7e <alltraps>

8010683b <vector102>:
.globl vector102
vector102:
  pushl $0
8010683b:	6a 00                	push   $0x0
  pushl $102
8010683d:	6a 66                	push   $0x66
  jmp alltraps
8010683f:	e9 3a f6 ff ff       	jmp    80105e7e <alltraps>

80106844 <vector103>:
.globl vector103
vector103:
  pushl $0
80106844:	6a 00                	push   $0x0
  pushl $103
80106846:	6a 67                	push   $0x67
  jmp alltraps
80106848:	e9 31 f6 ff ff       	jmp    80105e7e <alltraps>

8010684d <vector104>:
.globl vector104
vector104:
  pushl $0
8010684d:	6a 00                	push   $0x0
  pushl $104
8010684f:	6a 68                	push   $0x68
  jmp alltraps
80106851:	e9 28 f6 ff ff       	jmp    80105e7e <alltraps>

80106856 <vector105>:
.globl vector105
vector105:
  pushl $0
80106856:	6a 00                	push   $0x0
  pushl $105
80106858:	6a 69                	push   $0x69
  jmp alltraps
8010685a:	e9 1f f6 ff ff       	jmp    80105e7e <alltraps>

8010685f <vector106>:
.globl vector106
vector106:
  pushl $0
8010685f:	6a 00                	push   $0x0
  pushl $106
80106861:	6a 6a                	push   $0x6a
  jmp alltraps
80106863:	e9 16 f6 ff ff       	jmp    80105e7e <alltraps>

80106868 <vector107>:
.globl vector107
vector107:
  pushl $0
80106868:	6a 00                	push   $0x0
  pushl $107
8010686a:	6a 6b                	push   $0x6b
  jmp alltraps
8010686c:	e9 0d f6 ff ff       	jmp    80105e7e <alltraps>

80106871 <vector108>:
.globl vector108
vector108:
  pushl $0
80106871:	6a 00                	push   $0x0
  pushl $108
80106873:	6a 6c                	push   $0x6c
  jmp alltraps
80106875:	e9 04 f6 ff ff       	jmp    80105e7e <alltraps>

8010687a <vector109>:
.globl vector109
vector109:
  pushl $0
8010687a:	6a 00                	push   $0x0
  pushl $109
8010687c:	6a 6d                	push   $0x6d
  jmp alltraps
8010687e:	e9 fb f5 ff ff       	jmp    80105e7e <alltraps>

80106883 <vector110>:
.globl vector110
vector110:
  pushl $0
80106883:	6a 00                	push   $0x0
  pushl $110
80106885:	6a 6e                	push   $0x6e
  jmp alltraps
80106887:	e9 f2 f5 ff ff       	jmp    80105e7e <alltraps>

8010688c <vector111>:
.globl vector111
vector111:
  pushl $0
8010688c:	6a 00                	push   $0x0
  pushl $111
8010688e:	6a 6f                	push   $0x6f
  jmp alltraps
80106890:	e9 e9 f5 ff ff       	jmp    80105e7e <alltraps>

80106895 <vector112>:
.globl vector112
vector112:
  pushl $0
80106895:	6a 00                	push   $0x0
  pushl $112
80106897:	6a 70                	push   $0x70
  jmp alltraps
80106899:	e9 e0 f5 ff ff       	jmp    80105e7e <alltraps>

8010689e <vector113>:
.globl vector113
vector113:
  pushl $0
8010689e:	6a 00                	push   $0x0
  pushl $113
801068a0:	6a 71                	push   $0x71
  jmp alltraps
801068a2:	e9 d7 f5 ff ff       	jmp    80105e7e <alltraps>

801068a7 <vector114>:
.globl vector114
vector114:
  pushl $0
801068a7:	6a 00                	push   $0x0
  pushl $114
801068a9:	6a 72                	push   $0x72
  jmp alltraps
801068ab:	e9 ce f5 ff ff       	jmp    80105e7e <alltraps>

801068b0 <vector115>:
.globl vector115
vector115:
  pushl $0
801068b0:	6a 00                	push   $0x0
  pushl $115
801068b2:	6a 73                	push   $0x73
  jmp alltraps
801068b4:	e9 c5 f5 ff ff       	jmp    80105e7e <alltraps>

801068b9 <vector116>:
.globl vector116
vector116:
  pushl $0
801068b9:	6a 00                	push   $0x0
  pushl $116
801068bb:	6a 74                	push   $0x74
  jmp alltraps
801068bd:	e9 bc f5 ff ff       	jmp    80105e7e <alltraps>

801068c2 <vector117>:
.globl vector117
vector117:
  pushl $0
801068c2:	6a 00                	push   $0x0
  pushl $117
801068c4:	6a 75                	push   $0x75
  jmp alltraps
801068c6:	e9 b3 f5 ff ff       	jmp    80105e7e <alltraps>

801068cb <vector118>:
.globl vector118
vector118:
  pushl $0
801068cb:	6a 00                	push   $0x0
  pushl $118
801068cd:	6a 76                	push   $0x76
  jmp alltraps
801068cf:	e9 aa f5 ff ff       	jmp    80105e7e <alltraps>

801068d4 <vector119>:
.globl vector119
vector119:
  pushl $0
801068d4:	6a 00                	push   $0x0
  pushl $119
801068d6:	6a 77                	push   $0x77
  jmp alltraps
801068d8:	e9 a1 f5 ff ff       	jmp    80105e7e <alltraps>

801068dd <vector120>:
.globl vector120
vector120:
  pushl $0
801068dd:	6a 00                	push   $0x0
  pushl $120
801068df:	6a 78                	push   $0x78
  jmp alltraps
801068e1:	e9 98 f5 ff ff       	jmp    80105e7e <alltraps>

801068e6 <vector121>:
.globl vector121
vector121:
  pushl $0
801068e6:	6a 00                	push   $0x0
  pushl $121
801068e8:	6a 79                	push   $0x79
  jmp alltraps
801068ea:	e9 8f f5 ff ff       	jmp    80105e7e <alltraps>

801068ef <vector122>:
.globl vector122
vector122:
  pushl $0
801068ef:	6a 00                	push   $0x0
  pushl $122
801068f1:	6a 7a                	push   $0x7a
  jmp alltraps
801068f3:	e9 86 f5 ff ff       	jmp    80105e7e <alltraps>

801068f8 <vector123>:
.globl vector123
vector123:
  pushl $0
801068f8:	6a 00                	push   $0x0
  pushl $123
801068fa:	6a 7b                	push   $0x7b
  jmp alltraps
801068fc:	e9 7d f5 ff ff       	jmp    80105e7e <alltraps>

80106901 <vector124>:
.globl vector124
vector124:
  pushl $0
80106901:	6a 00                	push   $0x0
  pushl $124
80106903:	6a 7c                	push   $0x7c
  jmp alltraps
80106905:	e9 74 f5 ff ff       	jmp    80105e7e <alltraps>

8010690a <vector125>:
.globl vector125
vector125:
  pushl $0
8010690a:	6a 00                	push   $0x0
  pushl $125
8010690c:	6a 7d                	push   $0x7d
  jmp alltraps
8010690e:	e9 6b f5 ff ff       	jmp    80105e7e <alltraps>

80106913 <vector126>:
.globl vector126
vector126:
  pushl $0
80106913:	6a 00                	push   $0x0
  pushl $126
80106915:	6a 7e                	push   $0x7e
  jmp alltraps
80106917:	e9 62 f5 ff ff       	jmp    80105e7e <alltraps>

8010691c <vector127>:
.globl vector127
vector127:
  pushl $0
8010691c:	6a 00                	push   $0x0
  pushl $127
8010691e:	6a 7f                	push   $0x7f
  jmp alltraps
80106920:	e9 59 f5 ff ff       	jmp    80105e7e <alltraps>

80106925 <vector128>:
.globl vector128
vector128:
  pushl $0
80106925:	6a 00                	push   $0x0
  pushl $128
80106927:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010692c:	e9 4d f5 ff ff       	jmp    80105e7e <alltraps>

80106931 <vector129>:
.globl vector129
vector129:
  pushl $0
80106931:	6a 00                	push   $0x0
  pushl $129
80106933:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106938:	e9 41 f5 ff ff       	jmp    80105e7e <alltraps>

8010693d <vector130>:
.globl vector130
vector130:
  pushl $0
8010693d:	6a 00                	push   $0x0
  pushl $130
8010693f:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106944:	e9 35 f5 ff ff       	jmp    80105e7e <alltraps>

80106949 <vector131>:
.globl vector131
vector131:
  pushl $0
80106949:	6a 00                	push   $0x0
  pushl $131
8010694b:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106950:	e9 29 f5 ff ff       	jmp    80105e7e <alltraps>

80106955 <vector132>:
.globl vector132
vector132:
  pushl $0
80106955:	6a 00                	push   $0x0
  pushl $132
80106957:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010695c:	e9 1d f5 ff ff       	jmp    80105e7e <alltraps>

80106961 <vector133>:
.globl vector133
vector133:
  pushl $0
80106961:	6a 00                	push   $0x0
  pushl $133
80106963:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106968:	e9 11 f5 ff ff       	jmp    80105e7e <alltraps>

8010696d <vector134>:
.globl vector134
vector134:
  pushl $0
8010696d:	6a 00                	push   $0x0
  pushl $134
8010696f:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106974:	e9 05 f5 ff ff       	jmp    80105e7e <alltraps>

80106979 <vector135>:
.globl vector135
vector135:
  pushl $0
80106979:	6a 00                	push   $0x0
  pushl $135
8010697b:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106980:	e9 f9 f4 ff ff       	jmp    80105e7e <alltraps>

80106985 <vector136>:
.globl vector136
vector136:
  pushl $0
80106985:	6a 00                	push   $0x0
  pushl $136
80106987:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010698c:	e9 ed f4 ff ff       	jmp    80105e7e <alltraps>

80106991 <vector137>:
.globl vector137
vector137:
  pushl $0
80106991:	6a 00                	push   $0x0
  pushl $137
80106993:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106998:	e9 e1 f4 ff ff       	jmp    80105e7e <alltraps>

8010699d <vector138>:
.globl vector138
vector138:
  pushl $0
8010699d:	6a 00                	push   $0x0
  pushl $138
8010699f:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801069a4:	e9 d5 f4 ff ff       	jmp    80105e7e <alltraps>

801069a9 <vector139>:
.globl vector139
vector139:
  pushl $0
801069a9:	6a 00                	push   $0x0
  pushl $139
801069ab:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801069b0:	e9 c9 f4 ff ff       	jmp    80105e7e <alltraps>

801069b5 <vector140>:
.globl vector140
vector140:
  pushl $0
801069b5:	6a 00                	push   $0x0
  pushl $140
801069b7:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801069bc:	e9 bd f4 ff ff       	jmp    80105e7e <alltraps>

801069c1 <vector141>:
.globl vector141
vector141:
  pushl $0
801069c1:	6a 00                	push   $0x0
  pushl $141
801069c3:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801069c8:	e9 b1 f4 ff ff       	jmp    80105e7e <alltraps>

801069cd <vector142>:
.globl vector142
vector142:
  pushl $0
801069cd:	6a 00                	push   $0x0
  pushl $142
801069cf:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801069d4:	e9 a5 f4 ff ff       	jmp    80105e7e <alltraps>

801069d9 <vector143>:
.globl vector143
vector143:
  pushl $0
801069d9:	6a 00                	push   $0x0
  pushl $143
801069db:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801069e0:	e9 99 f4 ff ff       	jmp    80105e7e <alltraps>

801069e5 <vector144>:
.globl vector144
vector144:
  pushl $0
801069e5:	6a 00                	push   $0x0
  pushl $144
801069e7:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801069ec:	e9 8d f4 ff ff       	jmp    80105e7e <alltraps>

801069f1 <vector145>:
.globl vector145
vector145:
  pushl $0
801069f1:	6a 00                	push   $0x0
  pushl $145
801069f3:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801069f8:	e9 81 f4 ff ff       	jmp    80105e7e <alltraps>

801069fd <vector146>:
.globl vector146
vector146:
  pushl $0
801069fd:	6a 00                	push   $0x0
  pushl $146
801069ff:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106a04:	e9 75 f4 ff ff       	jmp    80105e7e <alltraps>

80106a09 <vector147>:
.globl vector147
vector147:
  pushl $0
80106a09:	6a 00                	push   $0x0
  pushl $147
80106a0b:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106a10:	e9 69 f4 ff ff       	jmp    80105e7e <alltraps>

80106a15 <vector148>:
.globl vector148
vector148:
  pushl $0
80106a15:	6a 00                	push   $0x0
  pushl $148
80106a17:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106a1c:	e9 5d f4 ff ff       	jmp    80105e7e <alltraps>

80106a21 <vector149>:
.globl vector149
vector149:
  pushl $0
80106a21:	6a 00                	push   $0x0
  pushl $149
80106a23:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106a28:	e9 51 f4 ff ff       	jmp    80105e7e <alltraps>

80106a2d <vector150>:
.globl vector150
vector150:
  pushl $0
80106a2d:	6a 00                	push   $0x0
  pushl $150
80106a2f:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106a34:	e9 45 f4 ff ff       	jmp    80105e7e <alltraps>

80106a39 <vector151>:
.globl vector151
vector151:
  pushl $0
80106a39:	6a 00                	push   $0x0
  pushl $151
80106a3b:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106a40:	e9 39 f4 ff ff       	jmp    80105e7e <alltraps>

80106a45 <vector152>:
.globl vector152
vector152:
  pushl $0
80106a45:	6a 00                	push   $0x0
  pushl $152
80106a47:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106a4c:	e9 2d f4 ff ff       	jmp    80105e7e <alltraps>

80106a51 <vector153>:
.globl vector153
vector153:
  pushl $0
80106a51:	6a 00                	push   $0x0
  pushl $153
80106a53:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106a58:	e9 21 f4 ff ff       	jmp    80105e7e <alltraps>

80106a5d <vector154>:
.globl vector154
vector154:
  pushl $0
80106a5d:	6a 00                	push   $0x0
  pushl $154
80106a5f:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106a64:	e9 15 f4 ff ff       	jmp    80105e7e <alltraps>

80106a69 <vector155>:
.globl vector155
vector155:
  pushl $0
80106a69:	6a 00                	push   $0x0
  pushl $155
80106a6b:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106a70:	e9 09 f4 ff ff       	jmp    80105e7e <alltraps>

80106a75 <vector156>:
.globl vector156
vector156:
  pushl $0
80106a75:	6a 00                	push   $0x0
  pushl $156
80106a77:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106a7c:	e9 fd f3 ff ff       	jmp    80105e7e <alltraps>

80106a81 <vector157>:
.globl vector157
vector157:
  pushl $0
80106a81:	6a 00                	push   $0x0
  pushl $157
80106a83:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106a88:	e9 f1 f3 ff ff       	jmp    80105e7e <alltraps>

80106a8d <vector158>:
.globl vector158
vector158:
  pushl $0
80106a8d:	6a 00                	push   $0x0
  pushl $158
80106a8f:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106a94:	e9 e5 f3 ff ff       	jmp    80105e7e <alltraps>

80106a99 <vector159>:
.globl vector159
vector159:
  pushl $0
80106a99:	6a 00                	push   $0x0
  pushl $159
80106a9b:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106aa0:	e9 d9 f3 ff ff       	jmp    80105e7e <alltraps>

80106aa5 <vector160>:
.globl vector160
vector160:
  pushl $0
80106aa5:	6a 00                	push   $0x0
  pushl $160
80106aa7:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106aac:	e9 cd f3 ff ff       	jmp    80105e7e <alltraps>

80106ab1 <vector161>:
.globl vector161
vector161:
  pushl $0
80106ab1:	6a 00                	push   $0x0
  pushl $161
80106ab3:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106ab8:	e9 c1 f3 ff ff       	jmp    80105e7e <alltraps>

80106abd <vector162>:
.globl vector162
vector162:
  pushl $0
80106abd:	6a 00                	push   $0x0
  pushl $162
80106abf:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106ac4:	e9 b5 f3 ff ff       	jmp    80105e7e <alltraps>

80106ac9 <vector163>:
.globl vector163
vector163:
  pushl $0
80106ac9:	6a 00                	push   $0x0
  pushl $163
80106acb:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106ad0:	e9 a9 f3 ff ff       	jmp    80105e7e <alltraps>

80106ad5 <vector164>:
.globl vector164
vector164:
  pushl $0
80106ad5:	6a 00                	push   $0x0
  pushl $164
80106ad7:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106adc:	e9 9d f3 ff ff       	jmp    80105e7e <alltraps>

80106ae1 <vector165>:
.globl vector165
vector165:
  pushl $0
80106ae1:	6a 00                	push   $0x0
  pushl $165
80106ae3:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106ae8:	e9 91 f3 ff ff       	jmp    80105e7e <alltraps>

80106aed <vector166>:
.globl vector166
vector166:
  pushl $0
80106aed:	6a 00                	push   $0x0
  pushl $166
80106aef:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106af4:	e9 85 f3 ff ff       	jmp    80105e7e <alltraps>

80106af9 <vector167>:
.globl vector167
vector167:
  pushl $0
80106af9:	6a 00                	push   $0x0
  pushl $167
80106afb:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106b00:	e9 79 f3 ff ff       	jmp    80105e7e <alltraps>

80106b05 <vector168>:
.globl vector168
vector168:
  pushl $0
80106b05:	6a 00                	push   $0x0
  pushl $168
80106b07:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106b0c:	e9 6d f3 ff ff       	jmp    80105e7e <alltraps>

80106b11 <vector169>:
.globl vector169
vector169:
  pushl $0
80106b11:	6a 00                	push   $0x0
  pushl $169
80106b13:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106b18:	e9 61 f3 ff ff       	jmp    80105e7e <alltraps>

80106b1d <vector170>:
.globl vector170
vector170:
  pushl $0
80106b1d:	6a 00                	push   $0x0
  pushl $170
80106b1f:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106b24:	e9 55 f3 ff ff       	jmp    80105e7e <alltraps>

80106b29 <vector171>:
.globl vector171
vector171:
  pushl $0
80106b29:	6a 00                	push   $0x0
  pushl $171
80106b2b:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106b30:	e9 49 f3 ff ff       	jmp    80105e7e <alltraps>

80106b35 <vector172>:
.globl vector172
vector172:
  pushl $0
80106b35:	6a 00                	push   $0x0
  pushl $172
80106b37:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106b3c:	e9 3d f3 ff ff       	jmp    80105e7e <alltraps>

80106b41 <vector173>:
.globl vector173
vector173:
  pushl $0
80106b41:	6a 00                	push   $0x0
  pushl $173
80106b43:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106b48:	e9 31 f3 ff ff       	jmp    80105e7e <alltraps>

80106b4d <vector174>:
.globl vector174
vector174:
  pushl $0
80106b4d:	6a 00                	push   $0x0
  pushl $174
80106b4f:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106b54:	e9 25 f3 ff ff       	jmp    80105e7e <alltraps>

80106b59 <vector175>:
.globl vector175
vector175:
  pushl $0
80106b59:	6a 00                	push   $0x0
  pushl $175
80106b5b:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106b60:	e9 19 f3 ff ff       	jmp    80105e7e <alltraps>

80106b65 <vector176>:
.globl vector176
vector176:
  pushl $0
80106b65:	6a 00                	push   $0x0
  pushl $176
80106b67:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106b6c:	e9 0d f3 ff ff       	jmp    80105e7e <alltraps>

80106b71 <vector177>:
.globl vector177
vector177:
  pushl $0
80106b71:	6a 00                	push   $0x0
  pushl $177
80106b73:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106b78:	e9 01 f3 ff ff       	jmp    80105e7e <alltraps>

80106b7d <vector178>:
.globl vector178
vector178:
  pushl $0
80106b7d:	6a 00                	push   $0x0
  pushl $178
80106b7f:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106b84:	e9 f5 f2 ff ff       	jmp    80105e7e <alltraps>

80106b89 <vector179>:
.globl vector179
vector179:
  pushl $0
80106b89:	6a 00                	push   $0x0
  pushl $179
80106b8b:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106b90:	e9 e9 f2 ff ff       	jmp    80105e7e <alltraps>

80106b95 <vector180>:
.globl vector180
vector180:
  pushl $0
80106b95:	6a 00                	push   $0x0
  pushl $180
80106b97:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106b9c:	e9 dd f2 ff ff       	jmp    80105e7e <alltraps>

80106ba1 <vector181>:
.globl vector181
vector181:
  pushl $0
80106ba1:	6a 00                	push   $0x0
  pushl $181
80106ba3:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106ba8:	e9 d1 f2 ff ff       	jmp    80105e7e <alltraps>

80106bad <vector182>:
.globl vector182
vector182:
  pushl $0
80106bad:	6a 00                	push   $0x0
  pushl $182
80106baf:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106bb4:	e9 c5 f2 ff ff       	jmp    80105e7e <alltraps>

80106bb9 <vector183>:
.globl vector183
vector183:
  pushl $0
80106bb9:	6a 00                	push   $0x0
  pushl $183
80106bbb:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106bc0:	e9 b9 f2 ff ff       	jmp    80105e7e <alltraps>

80106bc5 <vector184>:
.globl vector184
vector184:
  pushl $0
80106bc5:	6a 00                	push   $0x0
  pushl $184
80106bc7:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106bcc:	e9 ad f2 ff ff       	jmp    80105e7e <alltraps>

80106bd1 <vector185>:
.globl vector185
vector185:
  pushl $0
80106bd1:	6a 00                	push   $0x0
  pushl $185
80106bd3:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106bd8:	e9 a1 f2 ff ff       	jmp    80105e7e <alltraps>

80106bdd <vector186>:
.globl vector186
vector186:
  pushl $0
80106bdd:	6a 00                	push   $0x0
  pushl $186
80106bdf:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106be4:	e9 95 f2 ff ff       	jmp    80105e7e <alltraps>

80106be9 <vector187>:
.globl vector187
vector187:
  pushl $0
80106be9:	6a 00                	push   $0x0
  pushl $187
80106beb:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106bf0:	e9 89 f2 ff ff       	jmp    80105e7e <alltraps>

80106bf5 <vector188>:
.globl vector188
vector188:
  pushl $0
80106bf5:	6a 00                	push   $0x0
  pushl $188
80106bf7:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106bfc:	e9 7d f2 ff ff       	jmp    80105e7e <alltraps>

80106c01 <vector189>:
.globl vector189
vector189:
  pushl $0
80106c01:	6a 00                	push   $0x0
  pushl $189
80106c03:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106c08:	e9 71 f2 ff ff       	jmp    80105e7e <alltraps>

80106c0d <vector190>:
.globl vector190
vector190:
  pushl $0
80106c0d:	6a 00                	push   $0x0
  pushl $190
80106c0f:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106c14:	e9 65 f2 ff ff       	jmp    80105e7e <alltraps>

80106c19 <vector191>:
.globl vector191
vector191:
  pushl $0
80106c19:	6a 00                	push   $0x0
  pushl $191
80106c1b:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106c20:	e9 59 f2 ff ff       	jmp    80105e7e <alltraps>

80106c25 <vector192>:
.globl vector192
vector192:
  pushl $0
80106c25:	6a 00                	push   $0x0
  pushl $192
80106c27:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106c2c:	e9 4d f2 ff ff       	jmp    80105e7e <alltraps>

80106c31 <vector193>:
.globl vector193
vector193:
  pushl $0
80106c31:	6a 00                	push   $0x0
  pushl $193
80106c33:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106c38:	e9 41 f2 ff ff       	jmp    80105e7e <alltraps>

80106c3d <vector194>:
.globl vector194
vector194:
  pushl $0
80106c3d:	6a 00                	push   $0x0
  pushl $194
80106c3f:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106c44:	e9 35 f2 ff ff       	jmp    80105e7e <alltraps>

80106c49 <vector195>:
.globl vector195
vector195:
  pushl $0
80106c49:	6a 00                	push   $0x0
  pushl $195
80106c4b:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106c50:	e9 29 f2 ff ff       	jmp    80105e7e <alltraps>

80106c55 <vector196>:
.globl vector196
vector196:
  pushl $0
80106c55:	6a 00                	push   $0x0
  pushl $196
80106c57:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106c5c:	e9 1d f2 ff ff       	jmp    80105e7e <alltraps>

80106c61 <vector197>:
.globl vector197
vector197:
  pushl $0
80106c61:	6a 00                	push   $0x0
  pushl $197
80106c63:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106c68:	e9 11 f2 ff ff       	jmp    80105e7e <alltraps>

80106c6d <vector198>:
.globl vector198
vector198:
  pushl $0
80106c6d:	6a 00                	push   $0x0
  pushl $198
80106c6f:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106c74:	e9 05 f2 ff ff       	jmp    80105e7e <alltraps>

80106c79 <vector199>:
.globl vector199
vector199:
  pushl $0
80106c79:	6a 00                	push   $0x0
  pushl $199
80106c7b:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106c80:	e9 f9 f1 ff ff       	jmp    80105e7e <alltraps>

80106c85 <vector200>:
.globl vector200
vector200:
  pushl $0
80106c85:	6a 00                	push   $0x0
  pushl $200
80106c87:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106c8c:	e9 ed f1 ff ff       	jmp    80105e7e <alltraps>

80106c91 <vector201>:
.globl vector201
vector201:
  pushl $0
80106c91:	6a 00                	push   $0x0
  pushl $201
80106c93:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80106c98:	e9 e1 f1 ff ff       	jmp    80105e7e <alltraps>

80106c9d <vector202>:
.globl vector202
vector202:
  pushl $0
80106c9d:	6a 00                	push   $0x0
  pushl $202
80106c9f:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106ca4:	e9 d5 f1 ff ff       	jmp    80105e7e <alltraps>

80106ca9 <vector203>:
.globl vector203
vector203:
  pushl $0
80106ca9:	6a 00                	push   $0x0
  pushl $203
80106cab:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106cb0:	e9 c9 f1 ff ff       	jmp    80105e7e <alltraps>

80106cb5 <vector204>:
.globl vector204
vector204:
  pushl $0
80106cb5:	6a 00                	push   $0x0
  pushl $204
80106cb7:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106cbc:	e9 bd f1 ff ff       	jmp    80105e7e <alltraps>

80106cc1 <vector205>:
.globl vector205
vector205:
  pushl $0
80106cc1:	6a 00                	push   $0x0
  pushl $205
80106cc3:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106cc8:	e9 b1 f1 ff ff       	jmp    80105e7e <alltraps>

80106ccd <vector206>:
.globl vector206
vector206:
  pushl $0
80106ccd:	6a 00                	push   $0x0
  pushl $206
80106ccf:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106cd4:	e9 a5 f1 ff ff       	jmp    80105e7e <alltraps>

80106cd9 <vector207>:
.globl vector207
vector207:
  pushl $0
80106cd9:	6a 00                	push   $0x0
  pushl $207
80106cdb:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106ce0:	e9 99 f1 ff ff       	jmp    80105e7e <alltraps>

80106ce5 <vector208>:
.globl vector208
vector208:
  pushl $0
80106ce5:	6a 00                	push   $0x0
  pushl $208
80106ce7:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106cec:	e9 8d f1 ff ff       	jmp    80105e7e <alltraps>

80106cf1 <vector209>:
.globl vector209
vector209:
  pushl $0
80106cf1:	6a 00                	push   $0x0
  pushl $209
80106cf3:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106cf8:	e9 81 f1 ff ff       	jmp    80105e7e <alltraps>

80106cfd <vector210>:
.globl vector210
vector210:
  pushl $0
80106cfd:	6a 00                	push   $0x0
  pushl $210
80106cff:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106d04:	e9 75 f1 ff ff       	jmp    80105e7e <alltraps>

80106d09 <vector211>:
.globl vector211
vector211:
  pushl $0
80106d09:	6a 00                	push   $0x0
  pushl $211
80106d0b:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106d10:	e9 69 f1 ff ff       	jmp    80105e7e <alltraps>

80106d15 <vector212>:
.globl vector212
vector212:
  pushl $0
80106d15:	6a 00                	push   $0x0
  pushl $212
80106d17:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106d1c:	e9 5d f1 ff ff       	jmp    80105e7e <alltraps>

80106d21 <vector213>:
.globl vector213
vector213:
  pushl $0
80106d21:	6a 00                	push   $0x0
  pushl $213
80106d23:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80106d28:	e9 51 f1 ff ff       	jmp    80105e7e <alltraps>

80106d2d <vector214>:
.globl vector214
vector214:
  pushl $0
80106d2d:	6a 00                	push   $0x0
  pushl $214
80106d2f:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106d34:	e9 45 f1 ff ff       	jmp    80105e7e <alltraps>

80106d39 <vector215>:
.globl vector215
vector215:
  pushl $0
80106d39:	6a 00                	push   $0x0
  pushl $215
80106d3b:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106d40:	e9 39 f1 ff ff       	jmp    80105e7e <alltraps>

80106d45 <vector216>:
.globl vector216
vector216:
  pushl $0
80106d45:	6a 00                	push   $0x0
  pushl $216
80106d47:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106d4c:	e9 2d f1 ff ff       	jmp    80105e7e <alltraps>

80106d51 <vector217>:
.globl vector217
vector217:
  pushl $0
80106d51:	6a 00                	push   $0x0
  pushl $217
80106d53:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80106d58:	e9 21 f1 ff ff       	jmp    80105e7e <alltraps>

80106d5d <vector218>:
.globl vector218
vector218:
  pushl $0
80106d5d:	6a 00                	push   $0x0
  pushl $218
80106d5f:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106d64:	e9 15 f1 ff ff       	jmp    80105e7e <alltraps>

80106d69 <vector219>:
.globl vector219
vector219:
  pushl $0
80106d69:	6a 00                	push   $0x0
  pushl $219
80106d6b:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106d70:	e9 09 f1 ff ff       	jmp    80105e7e <alltraps>

80106d75 <vector220>:
.globl vector220
vector220:
  pushl $0
80106d75:	6a 00                	push   $0x0
  pushl $220
80106d77:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80106d7c:	e9 fd f0 ff ff       	jmp    80105e7e <alltraps>

80106d81 <vector221>:
.globl vector221
vector221:
  pushl $0
80106d81:	6a 00                	push   $0x0
  pushl $221
80106d83:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80106d88:	e9 f1 f0 ff ff       	jmp    80105e7e <alltraps>

80106d8d <vector222>:
.globl vector222
vector222:
  pushl $0
80106d8d:	6a 00                	push   $0x0
  pushl $222
80106d8f:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80106d94:	e9 e5 f0 ff ff       	jmp    80105e7e <alltraps>

80106d99 <vector223>:
.globl vector223
vector223:
  pushl $0
80106d99:	6a 00                	push   $0x0
  pushl $223
80106d9b:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106da0:	e9 d9 f0 ff ff       	jmp    80105e7e <alltraps>

80106da5 <vector224>:
.globl vector224
vector224:
  pushl $0
80106da5:	6a 00                	push   $0x0
  pushl $224
80106da7:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80106dac:	e9 cd f0 ff ff       	jmp    80105e7e <alltraps>

80106db1 <vector225>:
.globl vector225
vector225:
  pushl $0
80106db1:	6a 00                	push   $0x0
  pushl $225
80106db3:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80106db8:	e9 c1 f0 ff ff       	jmp    80105e7e <alltraps>

80106dbd <vector226>:
.globl vector226
vector226:
  pushl $0
80106dbd:	6a 00                	push   $0x0
  pushl $226
80106dbf:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80106dc4:	e9 b5 f0 ff ff       	jmp    80105e7e <alltraps>

80106dc9 <vector227>:
.globl vector227
vector227:
  pushl $0
80106dc9:	6a 00                	push   $0x0
  pushl $227
80106dcb:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80106dd0:	e9 a9 f0 ff ff       	jmp    80105e7e <alltraps>

80106dd5 <vector228>:
.globl vector228
vector228:
  pushl $0
80106dd5:	6a 00                	push   $0x0
  pushl $228
80106dd7:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80106ddc:	e9 9d f0 ff ff       	jmp    80105e7e <alltraps>

80106de1 <vector229>:
.globl vector229
vector229:
  pushl $0
80106de1:	6a 00                	push   $0x0
  pushl $229
80106de3:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80106de8:	e9 91 f0 ff ff       	jmp    80105e7e <alltraps>

80106ded <vector230>:
.globl vector230
vector230:
  pushl $0
80106ded:	6a 00                	push   $0x0
  pushl $230
80106def:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80106df4:	e9 85 f0 ff ff       	jmp    80105e7e <alltraps>

80106df9 <vector231>:
.globl vector231
vector231:
  pushl $0
80106df9:	6a 00                	push   $0x0
  pushl $231
80106dfb:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80106e00:	e9 79 f0 ff ff       	jmp    80105e7e <alltraps>

80106e05 <vector232>:
.globl vector232
vector232:
  pushl $0
80106e05:	6a 00                	push   $0x0
  pushl $232
80106e07:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80106e0c:	e9 6d f0 ff ff       	jmp    80105e7e <alltraps>

80106e11 <vector233>:
.globl vector233
vector233:
  pushl $0
80106e11:	6a 00                	push   $0x0
  pushl $233
80106e13:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80106e18:	e9 61 f0 ff ff       	jmp    80105e7e <alltraps>

80106e1d <vector234>:
.globl vector234
vector234:
  pushl $0
80106e1d:	6a 00                	push   $0x0
  pushl $234
80106e1f:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80106e24:	e9 55 f0 ff ff       	jmp    80105e7e <alltraps>

80106e29 <vector235>:
.globl vector235
vector235:
  pushl $0
80106e29:	6a 00                	push   $0x0
  pushl $235
80106e2b:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80106e30:	e9 49 f0 ff ff       	jmp    80105e7e <alltraps>

80106e35 <vector236>:
.globl vector236
vector236:
  pushl $0
80106e35:	6a 00                	push   $0x0
  pushl $236
80106e37:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80106e3c:	e9 3d f0 ff ff       	jmp    80105e7e <alltraps>

80106e41 <vector237>:
.globl vector237
vector237:
  pushl $0
80106e41:	6a 00                	push   $0x0
  pushl $237
80106e43:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80106e48:	e9 31 f0 ff ff       	jmp    80105e7e <alltraps>

80106e4d <vector238>:
.globl vector238
vector238:
  pushl $0
80106e4d:	6a 00                	push   $0x0
  pushl $238
80106e4f:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80106e54:	e9 25 f0 ff ff       	jmp    80105e7e <alltraps>

80106e59 <vector239>:
.globl vector239
vector239:
  pushl $0
80106e59:	6a 00                	push   $0x0
  pushl $239
80106e5b:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80106e60:	e9 19 f0 ff ff       	jmp    80105e7e <alltraps>

80106e65 <vector240>:
.globl vector240
vector240:
  pushl $0
80106e65:	6a 00                	push   $0x0
  pushl $240
80106e67:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80106e6c:	e9 0d f0 ff ff       	jmp    80105e7e <alltraps>

80106e71 <vector241>:
.globl vector241
vector241:
  pushl $0
80106e71:	6a 00                	push   $0x0
  pushl $241
80106e73:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80106e78:	e9 01 f0 ff ff       	jmp    80105e7e <alltraps>

80106e7d <vector242>:
.globl vector242
vector242:
  pushl $0
80106e7d:	6a 00                	push   $0x0
  pushl $242
80106e7f:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80106e84:	e9 f5 ef ff ff       	jmp    80105e7e <alltraps>

80106e89 <vector243>:
.globl vector243
vector243:
  pushl $0
80106e89:	6a 00                	push   $0x0
  pushl $243
80106e8b:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80106e90:	e9 e9 ef ff ff       	jmp    80105e7e <alltraps>

80106e95 <vector244>:
.globl vector244
vector244:
  pushl $0
80106e95:	6a 00                	push   $0x0
  pushl $244
80106e97:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80106e9c:	e9 dd ef ff ff       	jmp    80105e7e <alltraps>

80106ea1 <vector245>:
.globl vector245
vector245:
  pushl $0
80106ea1:	6a 00                	push   $0x0
  pushl $245
80106ea3:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80106ea8:	e9 d1 ef ff ff       	jmp    80105e7e <alltraps>

80106ead <vector246>:
.globl vector246
vector246:
  pushl $0
80106ead:	6a 00                	push   $0x0
  pushl $246
80106eaf:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80106eb4:	e9 c5 ef ff ff       	jmp    80105e7e <alltraps>

80106eb9 <vector247>:
.globl vector247
vector247:
  pushl $0
80106eb9:	6a 00                	push   $0x0
  pushl $247
80106ebb:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80106ec0:	e9 b9 ef ff ff       	jmp    80105e7e <alltraps>

80106ec5 <vector248>:
.globl vector248
vector248:
  pushl $0
80106ec5:	6a 00                	push   $0x0
  pushl $248
80106ec7:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80106ecc:	e9 ad ef ff ff       	jmp    80105e7e <alltraps>

80106ed1 <vector249>:
.globl vector249
vector249:
  pushl $0
80106ed1:	6a 00                	push   $0x0
  pushl $249
80106ed3:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80106ed8:	e9 a1 ef ff ff       	jmp    80105e7e <alltraps>

80106edd <vector250>:
.globl vector250
vector250:
  pushl $0
80106edd:	6a 00                	push   $0x0
  pushl $250
80106edf:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80106ee4:	e9 95 ef ff ff       	jmp    80105e7e <alltraps>

80106ee9 <vector251>:
.globl vector251
vector251:
  pushl $0
80106ee9:	6a 00                	push   $0x0
  pushl $251
80106eeb:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80106ef0:	e9 89 ef ff ff       	jmp    80105e7e <alltraps>

80106ef5 <vector252>:
.globl vector252
vector252:
  pushl $0
80106ef5:	6a 00                	push   $0x0
  pushl $252
80106ef7:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80106efc:	e9 7d ef ff ff       	jmp    80105e7e <alltraps>

80106f01 <vector253>:
.globl vector253
vector253:
  pushl $0
80106f01:	6a 00                	push   $0x0
  pushl $253
80106f03:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80106f08:	e9 71 ef ff ff       	jmp    80105e7e <alltraps>

80106f0d <vector254>:
.globl vector254
vector254:
  pushl $0
80106f0d:	6a 00                	push   $0x0
  pushl $254
80106f0f:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80106f14:	e9 65 ef ff ff       	jmp    80105e7e <alltraps>

80106f19 <vector255>:
.globl vector255
vector255:
  pushl $0
80106f19:	6a 00                	push   $0x0
  pushl $255
80106f1b:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80106f20:	e9 59 ef ff ff       	jmp    80105e7e <alltraps>

80106f25 <lgdt>:
{
80106f25:	55                   	push   %ebp
80106f26:	89 e5                	mov    %esp,%ebp
80106f28:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106f2b:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f2e:	83 e8 01             	sub    $0x1,%eax
80106f31:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106f35:	8b 45 08             	mov    0x8(%ebp),%eax
80106f38:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106f3c:	8b 45 08             	mov    0x8(%ebp),%eax
80106f3f:	c1 e8 10             	shr    $0x10,%eax
80106f42:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80106f46:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106f49:	0f 01 10             	lgdtl  (%eax)
}
80106f4c:	90                   	nop
80106f4d:	c9                   	leave  
80106f4e:	c3                   	ret    

80106f4f <ltr>:
{
80106f4f:	55                   	push   %ebp
80106f50:	89 e5                	mov    %esp,%ebp
80106f52:	83 ec 04             	sub    $0x4,%esp
80106f55:	8b 45 08             	mov    0x8(%ebp),%eax
80106f58:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80106f5c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80106f60:	0f 00 d8             	ltr    %ax
}
80106f63:	90                   	nop
80106f64:	c9                   	leave  
80106f65:	c3                   	ret    

80106f66 <lcr3>:

static inline void
lcr3(uint val)
{
80106f66:	55                   	push   %ebp
80106f67:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106f69:	8b 45 08             	mov    0x8(%ebp),%eax
80106f6c:	0f 22 d8             	mov    %eax,%cr3
}
80106f6f:	90                   	nop
80106f70:	5d                   	pop    %ebp
80106f71:	c3                   	ret    

80106f72 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80106f72:	55                   	push   %ebp
80106f73:	89 e5                	mov    %esp,%ebp
80106f75:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80106f78:	e8 13 ca ff ff       	call   80103990 <cpuid>
80106f7d:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80106f83:	05 80 69 19 80       	add    $0x80196980,%eax
80106f88:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80106f8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f8e:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80106f94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f97:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80106f9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fa0:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80106fa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fa7:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106fab:	83 e2 f0             	and    $0xfffffff0,%edx
80106fae:	83 ca 0a             	or     $0xa,%edx
80106fb1:	88 50 7d             	mov    %dl,0x7d(%eax)
80106fb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fb7:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106fbb:	83 ca 10             	or     $0x10,%edx
80106fbe:	88 50 7d             	mov    %dl,0x7d(%eax)
80106fc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fc4:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106fc8:	83 e2 9f             	and    $0xffffff9f,%edx
80106fcb:	88 50 7d             	mov    %dl,0x7d(%eax)
80106fce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fd1:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106fd5:	83 ca 80             	or     $0xffffff80,%edx
80106fd8:	88 50 7d             	mov    %dl,0x7d(%eax)
80106fdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fde:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106fe2:	83 ca 0f             	or     $0xf,%edx
80106fe5:	88 50 7e             	mov    %dl,0x7e(%eax)
80106fe8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106feb:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106fef:	83 e2 ef             	and    $0xffffffef,%edx
80106ff2:	88 50 7e             	mov    %dl,0x7e(%eax)
80106ff5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ff8:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106ffc:	83 e2 df             	and    $0xffffffdf,%edx
80106fff:	88 50 7e             	mov    %dl,0x7e(%eax)
80107002:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107005:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107009:	83 ca 40             	or     $0x40,%edx
8010700c:	88 50 7e             	mov    %dl,0x7e(%eax)
8010700f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107012:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107016:	83 ca 80             	or     $0xffffff80,%edx
80107019:	88 50 7e             	mov    %dl,0x7e(%eax)
8010701c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010701f:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107023:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107026:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010702d:	ff ff 
8010702f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107032:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107039:	00 00 
8010703b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010703e:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107045:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107048:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010704f:	83 e2 f0             	and    $0xfffffff0,%edx
80107052:	83 ca 02             	or     $0x2,%edx
80107055:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010705b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010705e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107065:	83 ca 10             	or     $0x10,%edx
80107068:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010706e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107071:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107078:	83 e2 9f             	and    $0xffffff9f,%edx
8010707b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107084:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010708b:	83 ca 80             	or     $0xffffff80,%edx
8010708e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107094:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107097:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010709e:	83 ca 0f             	or     $0xf,%edx
801070a1:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801070a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070aa:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801070b1:	83 e2 ef             	and    $0xffffffef,%edx
801070b4:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801070ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070bd:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801070c4:	83 e2 df             	and    $0xffffffdf,%edx
801070c7:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801070cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070d0:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801070d7:	83 ca 40             	or     $0x40,%edx
801070da:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801070e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070e3:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801070ea:	83 ca 80             	or     $0xffffff80,%edx
801070ed:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801070f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070f6:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801070fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107100:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107107:	ff ff 
80107109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010710c:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107113:	00 00 
80107115:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107118:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
8010711f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107122:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107129:	83 e2 f0             	and    $0xfffffff0,%edx
8010712c:	83 ca 0a             	or     $0xa,%edx
8010712f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107135:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107138:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010713f:	83 ca 10             	or     $0x10,%edx
80107142:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010714b:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107152:	83 ca 60             	or     $0x60,%edx
80107155:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010715b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010715e:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107165:	83 ca 80             	or     $0xffffff80,%edx
80107168:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010716e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107171:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107178:	83 ca 0f             	or     $0xf,%edx
8010717b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107184:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010718b:	83 e2 ef             	and    $0xffffffef,%edx
8010718e:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107197:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010719e:	83 e2 df             	and    $0xffffffdf,%edx
801071a1:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801071a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071aa:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801071b1:	83 ca 40             	or     $0x40,%edx
801071b4:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801071ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071bd:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801071c4:	83 ca 80             	or     $0xffffff80,%edx
801071c7:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801071cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071d0:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801071d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071da:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801071e1:	ff ff 
801071e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071e6:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801071ed:	00 00 
801071ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071f2:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801071f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071fc:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107203:	83 e2 f0             	and    $0xfffffff0,%edx
80107206:	83 ca 02             	or     $0x2,%edx
80107209:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010720f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107212:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107219:	83 ca 10             	or     $0x10,%edx
8010721c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107222:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107225:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010722c:	83 ca 60             	or     $0x60,%edx
8010722f:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107235:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107238:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010723f:	83 ca 80             	or     $0xffffff80,%edx
80107242:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107248:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010724b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107252:	83 ca 0f             	or     $0xf,%edx
80107255:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010725b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010725e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107265:	83 e2 ef             	and    $0xffffffef,%edx
80107268:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010726e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107271:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107278:	83 e2 df             	and    $0xffffffdf,%edx
8010727b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107281:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107284:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010728b:	83 ca 40             	or     $0x40,%edx
8010728e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107294:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107297:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010729e:	83 ca 80             	or     $0xffffff80,%edx
801072a1:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801072a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072aa:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801072b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072b4:	83 c0 70             	add    $0x70,%eax
801072b7:	83 ec 08             	sub    $0x8,%esp
801072ba:	6a 30                	push   $0x30
801072bc:	50                   	push   %eax
801072bd:	e8 63 fc ff ff       	call   80106f25 <lgdt>
801072c2:	83 c4 10             	add    $0x10,%esp
}
801072c5:	90                   	nop
801072c6:	c9                   	leave  
801072c7:	c3                   	ret    

801072c8 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801072c8:	55                   	push   %ebp
801072c9:	89 e5                	mov    %esp,%ebp
801072cb:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801072ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801072d1:	c1 e8 16             	shr    $0x16,%eax
801072d4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801072db:	8b 45 08             	mov    0x8(%ebp),%eax
801072de:	01 d0                	add    %edx,%eax
801072e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801072e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801072e6:	8b 00                	mov    (%eax),%eax
801072e8:	83 e0 01             	and    $0x1,%eax
801072eb:	85 c0                	test   %eax,%eax
801072ed:	74 14                	je     80107303 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801072ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801072f2:	8b 00                	mov    (%eax),%eax
801072f4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801072f9:	05 00 00 00 80       	add    $0x80000000,%eax
801072fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107301:	eb 42                	jmp    80107345 <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107303:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107307:	74 0e                	je     80107317 <walkpgdir+0x4f>
80107309:	e8 85 b4 ff ff       	call   80102793 <kalloc>
8010730e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107311:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107315:	75 07                	jne    8010731e <walkpgdir+0x56>
      return 0;
80107317:	b8 00 00 00 00       	mov    $0x0,%eax
8010731c:	eb 3e                	jmp    8010735c <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
8010731e:	83 ec 04             	sub    $0x4,%esp
80107321:	68 00 10 00 00       	push   $0x1000
80107326:	6a 00                	push   $0x0
80107328:	ff 75 f4             	push   -0xc(%ebp)
8010732b:	e8 a5 d7 ff ff       	call   80104ad5 <memset>
80107330:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107333:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107336:	05 00 00 00 80       	add    $0x80000000,%eax
8010733b:	83 c8 07             	or     $0x7,%eax
8010733e:	89 c2                	mov    %eax,%edx
80107340:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107343:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107345:	8b 45 0c             	mov    0xc(%ebp),%eax
80107348:	c1 e8 0c             	shr    $0xc,%eax
8010734b:	25 ff 03 00 00       	and    $0x3ff,%eax
80107350:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107357:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010735a:	01 d0                	add    %edx,%eax
}
8010735c:	c9                   	leave  
8010735d:	c3                   	ret    

8010735e <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010735e:	55                   	push   %ebp
8010735f:	89 e5                	mov    %esp,%ebp
80107361:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107364:	8b 45 0c             	mov    0xc(%ebp),%eax
80107367:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010736c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010736f:	8b 55 0c             	mov    0xc(%ebp),%edx
80107372:	8b 45 10             	mov    0x10(%ebp),%eax
80107375:	01 d0                	add    %edx,%eax
80107377:	83 e8 01             	sub    $0x1,%eax
8010737a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010737f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107382:	83 ec 04             	sub    $0x4,%esp
80107385:	6a 01                	push   $0x1
80107387:	ff 75 f4             	push   -0xc(%ebp)
8010738a:	ff 75 08             	push   0x8(%ebp)
8010738d:	e8 36 ff ff ff       	call   801072c8 <walkpgdir>
80107392:	83 c4 10             	add    $0x10,%esp
80107395:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107398:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010739c:	75 07                	jne    801073a5 <mappages+0x47>
      return -1;
8010739e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073a3:	eb 47                	jmp    801073ec <mappages+0x8e>
    if(*pte & PTE_P)
801073a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801073a8:	8b 00                	mov    (%eax),%eax
801073aa:	83 e0 01             	and    $0x1,%eax
801073ad:	85 c0                	test   %eax,%eax
801073af:	74 0d                	je     801073be <mappages+0x60>
      panic("remap");
801073b1:	83 ec 0c             	sub    $0xc,%esp
801073b4:	68 ec a6 10 80       	push   $0x8010a6ec
801073b9:	e8 eb 91 ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
801073be:	8b 45 18             	mov    0x18(%ebp),%eax
801073c1:	0b 45 14             	or     0x14(%ebp),%eax
801073c4:	83 c8 01             	or     $0x1,%eax
801073c7:	89 c2                	mov    %eax,%edx
801073c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801073cc:	89 10                	mov    %edx,(%eax)
    if(a == last)
801073ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073d1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801073d4:	74 10                	je     801073e6 <mappages+0x88>
      break;
    a += PGSIZE;
801073d6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801073dd:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801073e4:	eb 9c                	jmp    80107382 <mappages+0x24>
      break;
801073e6:	90                   	nop
  }
  return 0;
801073e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801073ec:	c9                   	leave  
801073ed:	c3                   	ret    

801073ee <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801073ee:	55                   	push   %ebp
801073ef:	89 e5                	mov    %esp,%ebp
801073f1:	53                   	push   %ebx
801073f2:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
801073f5:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
801073fc:	8b 15 50 6c 19 80    	mov    0x80196c50,%edx
80107402:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
80107407:	29 d0                	sub    %edx,%eax
80107409:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010740c:	a1 48 6c 19 80       	mov    0x80196c48,%eax
80107411:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107414:	8b 15 48 6c 19 80    	mov    0x80196c48,%edx
8010741a:	a1 50 6c 19 80       	mov    0x80196c50,%eax
8010741f:	01 d0                	add    %edx,%eax
80107421:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107424:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
8010742b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010742e:	83 c0 30             	add    $0x30,%eax
80107431:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107434:	89 10                	mov    %edx,(%eax)
80107436:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107439:	89 50 04             	mov    %edx,0x4(%eax)
8010743c:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010743f:	89 50 08             	mov    %edx,0x8(%eax)
80107442:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107445:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107448:	e8 46 b3 ff ff       	call   80102793 <kalloc>
8010744d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107450:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107454:	75 07                	jne    8010745d <setupkvm+0x6f>
    return 0;
80107456:	b8 00 00 00 00       	mov    $0x0,%eax
8010745b:	eb 78                	jmp    801074d5 <setupkvm+0xe7>
  }
  memset(pgdir, 0, PGSIZE);
8010745d:	83 ec 04             	sub    $0x4,%esp
80107460:	68 00 10 00 00       	push   $0x1000
80107465:	6a 00                	push   $0x0
80107467:	ff 75 f0             	push   -0x10(%ebp)
8010746a:	e8 66 d6 ff ff       	call   80104ad5 <memset>
8010746f:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107472:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
80107479:	eb 4e                	jmp    801074c9 <setupkvm+0xdb>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010747b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010747e:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107481:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107484:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107487:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010748a:	8b 58 08             	mov    0x8(%eax),%ebx
8010748d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107490:	8b 40 04             	mov    0x4(%eax),%eax
80107493:	29 c3                	sub    %eax,%ebx
80107495:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107498:	8b 00                	mov    (%eax),%eax
8010749a:	83 ec 0c             	sub    $0xc,%esp
8010749d:	51                   	push   %ecx
8010749e:	52                   	push   %edx
8010749f:	53                   	push   %ebx
801074a0:	50                   	push   %eax
801074a1:	ff 75 f0             	push   -0x10(%ebp)
801074a4:	e8 b5 fe ff ff       	call   8010735e <mappages>
801074a9:	83 c4 20             	add    $0x20,%esp
801074ac:	85 c0                	test   %eax,%eax
801074ae:	79 15                	jns    801074c5 <setupkvm+0xd7>
      freevm(pgdir);
801074b0:	83 ec 0c             	sub    $0xc,%esp
801074b3:	ff 75 f0             	push   -0x10(%ebp)
801074b6:	e8 f7 04 00 00       	call   801079b2 <freevm>
801074bb:	83 c4 10             	add    $0x10,%esp
      return 0;
801074be:	b8 00 00 00 00       	mov    $0x0,%eax
801074c3:	eb 10                	jmp    801074d5 <setupkvm+0xe7>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801074c5:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801074c9:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
801074d0:	72 a9                	jb     8010747b <setupkvm+0x8d>
    }
  return pgdir;
801074d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801074d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801074d8:	c9                   	leave  
801074d9:	c3                   	ret    

801074da <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801074da:	55                   	push   %ebp
801074db:	89 e5                	mov    %esp,%ebp
801074dd:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801074e0:	e8 09 ff ff ff       	call   801073ee <setupkvm>
801074e5:	a3 7c 69 19 80       	mov    %eax,0x8019697c
  switchkvm();
801074ea:	e8 03 00 00 00       	call   801074f2 <switchkvm>
}
801074ef:	90                   	nop
801074f0:	c9                   	leave  
801074f1:	c3                   	ret    

801074f2 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801074f2:	55                   	push   %ebp
801074f3:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801074f5:	a1 7c 69 19 80       	mov    0x8019697c,%eax
801074fa:	05 00 00 00 80       	add    $0x80000000,%eax
801074ff:	50                   	push   %eax
80107500:	e8 61 fa ff ff       	call   80106f66 <lcr3>
80107505:	83 c4 04             	add    $0x4,%esp
}
80107508:	90                   	nop
80107509:	c9                   	leave  
8010750a:	c3                   	ret    

8010750b <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
8010750b:	55                   	push   %ebp
8010750c:	89 e5                	mov    %esp,%ebp
8010750e:	56                   	push   %esi
8010750f:	53                   	push   %ebx
80107510:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107513:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107517:	75 0d                	jne    80107526 <switchuvm+0x1b>
    panic("switchuvm: no process");
80107519:	83 ec 0c             	sub    $0xc,%esp
8010751c:	68 f2 a6 10 80       	push   $0x8010a6f2
80107521:	e8 83 90 ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
80107526:	8b 45 08             	mov    0x8(%ebp),%eax
80107529:	8b 40 08             	mov    0x8(%eax),%eax
8010752c:	85 c0                	test   %eax,%eax
8010752e:	75 0d                	jne    8010753d <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107530:	83 ec 0c             	sub    $0xc,%esp
80107533:	68 08 a7 10 80       	push   $0x8010a708
80107538:	e8 6c 90 ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
8010753d:	8b 45 08             	mov    0x8(%ebp),%eax
80107540:	8b 40 04             	mov    0x4(%eax),%eax
80107543:	85 c0                	test   %eax,%eax
80107545:	75 0d                	jne    80107554 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80107547:	83 ec 0c             	sub    $0xc,%esp
8010754a:	68 1d a7 10 80       	push   $0x8010a71d
8010754f:	e8 55 90 ff ff       	call   801005a9 <panic>

  pushcli();
80107554:	e8 71 d4 ff ff       	call   801049ca <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107559:	e8 4d c4 ff ff       	call   801039ab <mycpu>
8010755e:	89 c3                	mov    %eax,%ebx
80107560:	e8 46 c4 ff ff       	call   801039ab <mycpu>
80107565:	83 c0 08             	add    $0x8,%eax
80107568:	89 c6                	mov    %eax,%esi
8010756a:	e8 3c c4 ff ff       	call   801039ab <mycpu>
8010756f:	83 c0 08             	add    $0x8,%eax
80107572:	c1 e8 10             	shr    $0x10,%eax
80107575:	88 45 f7             	mov    %al,-0x9(%ebp)
80107578:	e8 2e c4 ff ff       	call   801039ab <mycpu>
8010757d:	83 c0 08             	add    $0x8,%eax
80107580:	c1 e8 18             	shr    $0x18,%eax
80107583:	89 c2                	mov    %eax,%edx
80107585:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
8010758c:	67 00 
8010758e:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107595:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107599:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
8010759f:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801075a6:	83 e0 f0             	and    $0xfffffff0,%eax
801075a9:	83 c8 09             	or     $0x9,%eax
801075ac:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801075b2:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801075b9:	83 c8 10             	or     $0x10,%eax
801075bc:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801075c2:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801075c9:	83 e0 9f             	and    $0xffffff9f,%eax
801075cc:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801075d2:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801075d9:	83 c8 80             	or     $0xffffff80,%eax
801075dc:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801075e2:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801075e9:	83 e0 f0             	and    $0xfffffff0,%eax
801075ec:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801075f2:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801075f9:	83 e0 ef             	and    $0xffffffef,%eax
801075fc:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107602:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107609:	83 e0 df             	and    $0xffffffdf,%eax
8010760c:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107612:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107619:	83 c8 40             	or     $0x40,%eax
8010761c:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107622:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107629:	83 e0 7f             	and    $0x7f,%eax
8010762c:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107632:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107638:	e8 6e c3 ff ff       	call   801039ab <mycpu>
8010763d:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107644:	83 e2 ef             	and    $0xffffffef,%edx
80107647:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
8010764d:	e8 59 c3 ff ff       	call   801039ab <mycpu>
80107652:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107658:	8b 45 08             	mov    0x8(%ebp),%eax
8010765b:	8b 40 08             	mov    0x8(%eax),%eax
8010765e:	89 c3                	mov    %eax,%ebx
80107660:	e8 46 c3 ff ff       	call   801039ab <mycpu>
80107665:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
8010766b:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
8010766e:	e8 38 c3 ff ff       	call   801039ab <mycpu>
80107673:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107679:	83 ec 0c             	sub    $0xc,%esp
8010767c:	6a 28                	push   $0x28
8010767e:	e8 cc f8 ff ff       	call   80106f4f <ltr>
80107683:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107686:	8b 45 08             	mov    0x8(%ebp),%eax
80107689:	8b 40 04             	mov    0x4(%eax),%eax
8010768c:	05 00 00 00 80       	add    $0x80000000,%eax
80107691:	83 ec 0c             	sub    $0xc,%esp
80107694:	50                   	push   %eax
80107695:	e8 cc f8 ff ff       	call   80106f66 <lcr3>
8010769a:	83 c4 10             	add    $0x10,%esp
  popcli();
8010769d:	e8 75 d3 ff ff       	call   80104a17 <popcli>
}
801076a2:	90                   	nop
801076a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
801076a6:	5b                   	pop    %ebx
801076a7:	5e                   	pop    %esi
801076a8:	5d                   	pop    %ebp
801076a9:	c3                   	ret    

801076aa <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801076aa:	55                   	push   %ebp
801076ab:	89 e5                	mov    %esp,%ebp
801076ad:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
801076b0:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801076b7:	76 0d                	jbe    801076c6 <inituvm+0x1c>
    panic("inituvm: more than a page");
801076b9:	83 ec 0c             	sub    $0xc,%esp
801076bc:	68 31 a7 10 80       	push   $0x8010a731
801076c1:	e8 e3 8e ff ff       	call   801005a9 <panic>
  mem = kalloc();
801076c6:	e8 c8 b0 ff ff       	call   80102793 <kalloc>
801076cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801076ce:	83 ec 04             	sub    $0x4,%esp
801076d1:	68 00 10 00 00       	push   $0x1000
801076d6:	6a 00                	push   $0x0
801076d8:	ff 75 f4             	push   -0xc(%ebp)
801076db:	e8 f5 d3 ff ff       	call   80104ad5 <memset>
801076e0:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801076e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076e6:	05 00 00 00 80       	add    $0x80000000,%eax
801076eb:	83 ec 0c             	sub    $0xc,%esp
801076ee:	6a 06                	push   $0x6
801076f0:	50                   	push   %eax
801076f1:	68 00 10 00 00       	push   $0x1000
801076f6:	6a 00                	push   $0x0
801076f8:	ff 75 08             	push   0x8(%ebp)
801076fb:	e8 5e fc ff ff       	call   8010735e <mappages>
80107700:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107703:	83 ec 04             	sub    $0x4,%esp
80107706:	ff 75 10             	push   0x10(%ebp)
80107709:	ff 75 0c             	push   0xc(%ebp)
8010770c:	ff 75 f4             	push   -0xc(%ebp)
8010770f:	e8 80 d4 ff ff       	call   80104b94 <memmove>
80107714:	83 c4 10             	add    $0x10,%esp
}
80107717:	90                   	nop
80107718:	c9                   	leave  
80107719:	c3                   	ret    

8010771a <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010771a:	55                   	push   %ebp
8010771b:	89 e5                	mov    %esp,%ebp
8010771d:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107720:	8b 45 0c             	mov    0xc(%ebp),%eax
80107723:	25 ff 0f 00 00       	and    $0xfff,%eax
80107728:	85 c0                	test   %eax,%eax
8010772a:	74 0d                	je     80107739 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
8010772c:	83 ec 0c             	sub    $0xc,%esp
8010772f:	68 4c a7 10 80       	push   $0x8010a74c
80107734:	e8 70 8e ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107739:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107740:	e9 8f 00 00 00       	jmp    801077d4 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107745:	8b 55 0c             	mov    0xc(%ebp),%edx
80107748:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010774b:	01 d0                	add    %edx,%eax
8010774d:	83 ec 04             	sub    $0x4,%esp
80107750:	6a 00                	push   $0x0
80107752:	50                   	push   %eax
80107753:	ff 75 08             	push   0x8(%ebp)
80107756:	e8 6d fb ff ff       	call   801072c8 <walkpgdir>
8010775b:	83 c4 10             	add    $0x10,%esp
8010775e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107761:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107765:	75 0d                	jne    80107774 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80107767:	83 ec 0c             	sub    $0xc,%esp
8010776a:	68 6f a7 10 80       	push   $0x8010a76f
8010776f:	e8 35 8e ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107774:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107777:	8b 00                	mov    (%eax),%eax
80107779:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010777e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107781:	8b 45 18             	mov    0x18(%ebp),%eax
80107784:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107787:	3d ff 0f 00 00       	cmp    $0xfff,%eax
8010778c:	77 0b                	ja     80107799 <loaduvm+0x7f>
      n = sz - i;
8010778e:	8b 45 18             	mov    0x18(%ebp),%eax
80107791:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107794:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107797:	eb 07                	jmp    801077a0 <loaduvm+0x86>
    else
      n = PGSIZE;
80107799:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
801077a0:	8b 55 14             	mov    0x14(%ebp),%edx
801077a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077a6:	01 d0                	add    %edx,%eax
801077a8:	8b 55 e8             	mov    -0x18(%ebp),%edx
801077ab:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801077b1:	ff 75 f0             	push   -0x10(%ebp)
801077b4:	50                   	push   %eax
801077b5:	52                   	push   %edx
801077b6:	ff 75 10             	push   0x10(%ebp)
801077b9:	e8 0b a7 ff ff       	call   80101ec9 <readi>
801077be:	83 c4 10             	add    $0x10,%esp
801077c1:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801077c4:	74 07                	je     801077cd <loaduvm+0xb3>
      return -1;
801077c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801077cb:	eb 18                	jmp    801077e5 <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
801077cd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801077d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077d7:	3b 45 18             	cmp    0x18(%ebp),%eax
801077da:	0f 82 65 ff ff ff    	jb     80107745 <loaduvm+0x2b>
  }
  return 0;
801077e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801077e5:	c9                   	leave  
801077e6:	c3                   	ret    

801077e7 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801077e7:	55                   	push   %ebp
801077e8:	89 e5                	mov    %esp,%ebp
801077ea:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz > KERNBASE)
801077ed:	81 7d 10 00 00 00 80 	cmpl   $0x80000000,0x10(%ebp)
801077f4:	76 0a                	jbe    80107800 <allocuvm+0x19>
    return 0;
801077f6:	b8 00 00 00 00       	mov    $0x0,%eax
801077fb:	e9 ec 00 00 00       	jmp    801078ec <allocuvm+0x105>
  if(newsz < oldsz)
80107800:	8b 45 10             	mov    0x10(%ebp),%eax
80107803:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107806:	73 08                	jae    80107810 <allocuvm+0x29>
    return oldsz;
80107808:	8b 45 0c             	mov    0xc(%ebp),%eax
8010780b:	e9 dc 00 00 00       	jmp    801078ec <allocuvm+0x105>

  a = PGROUNDUP(oldsz);
80107810:	8b 45 0c             	mov    0xc(%ebp),%eax
80107813:	05 ff 0f 00 00       	add    $0xfff,%eax
80107818:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010781d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107820:	e9 b8 00 00 00       	jmp    801078dd <allocuvm+0xf6>
    mem = kalloc();
80107825:	e8 69 af ff ff       	call   80102793 <kalloc>
8010782a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010782d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107831:	75 2e                	jne    80107861 <allocuvm+0x7a>
      cprintf("allocuvm out of memory\n");
80107833:	83 ec 0c             	sub    $0xc,%esp
80107836:	68 8d a7 10 80       	push   $0x8010a78d
8010783b:	e8 b4 8b ff ff       	call   801003f4 <cprintf>
80107840:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107843:	83 ec 04             	sub    $0x4,%esp
80107846:	ff 75 0c             	push   0xc(%ebp)
80107849:	ff 75 10             	push   0x10(%ebp)
8010784c:	ff 75 08             	push   0x8(%ebp)
8010784f:	e8 9a 00 00 00       	call   801078ee <deallocuvm>
80107854:	83 c4 10             	add    $0x10,%esp
      return 0;
80107857:	b8 00 00 00 00       	mov    $0x0,%eax
8010785c:	e9 8b 00 00 00       	jmp    801078ec <allocuvm+0x105>
    }
    memset(mem, 0, PGSIZE);
80107861:	83 ec 04             	sub    $0x4,%esp
80107864:	68 00 10 00 00       	push   $0x1000
80107869:	6a 00                	push   $0x0
8010786b:	ff 75 f0             	push   -0x10(%ebp)
8010786e:	e8 62 d2 ff ff       	call   80104ad5 <memset>
80107873:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107876:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107879:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010787f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107882:	83 ec 0c             	sub    $0xc,%esp
80107885:	6a 06                	push   $0x6
80107887:	52                   	push   %edx
80107888:	68 00 10 00 00       	push   $0x1000
8010788d:	50                   	push   %eax
8010788e:	ff 75 08             	push   0x8(%ebp)
80107891:	e8 c8 fa ff ff       	call   8010735e <mappages>
80107896:	83 c4 20             	add    $0x20,%esp
80107899:	85 c0                	test   %eax,%eax
8010789b:	79 39                	jns    801078d6 <allocuvm+0xef>
      cprintf("allocuvm out of memory (2)\n");
8010789d:	83 ec 0c             	sub    $0xc,%esp
801078a0:	68 a5 a7 10 80       	push   $0x8010a7a5
801078a5:	e8 4a 8b ff ff       	call   801003f4 <cprintf>
801078aa:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801078ad:	83 ec 04             	sub    $0x4,%esp
801078b0:	ff 75 0c             	push   0xc(%ebp)
801078b3:	ff 75 10             	push   0x10(%ebp)
801078b6:	ff 75 08             	push   0x8(%ebp)
801078b9:	e8 30 00 00 00       	call   801078ee <deallocuvm>
801078be:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
801078c1:	83 ec 0c             	sub    $0xc,%esp
801078c4:	ff 75 f0             	push   -0x10(%ebp)
801078c7:	e8 2d ae ff ff       	call   801026f9 <kfree>
801078cc:	83 c4 10             	add    $0x10,%esp
      return 0;
801078cf:	b8 00 00 00 00       	mov    $0x0,%eax
801078d4:	eb 16                	jmp    801078ec <allocuvm+0x105>
  for(; a < newsz; a += PGSIZE){
801078d6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801078dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e0:	3b 45 10             	cmp    0x10(%ebp),%eax
801078e3:	0f 82 3c ff ff ff    	jb     80107825 <allocuvm+0x3e>
    }
  }
  return newsz;
801078e9:	8b 45 10             	mov    0x10(%ebp),%eax
}
801078ec:	c9                   	leave  
801078ed:	c3                   	ret    

801078ee <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801078ee:	55                   	push   %ebp
801078ef:	89 e5                	mov    %esp,%ebp
801078f1:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801078f4:	8b 45 10             	mov    0x10(%ebp),%eax
801078f7:	3b 45 0c             	cmp    0xc(%ebp),%eax
801078fa:	72 08                	jb     80107904 <deallocuvm+0x16>
    return oldsz;
801078fc:	8b 45 0c             	mov    0xc(%ebp),%eax
801078ff:	e9 ac 00 00 00       	jmp    801079b0 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80107904:	8b 45 10             	mov    0x10(%ebp),%eax
80107907:	05 ff 0f 00 00       	add    $0xfff,%eax
8010790c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107911:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107914:	e9 88 00 00 00       	jmp    801079a1 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107919:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010791c:	83 ec 04             	sub    $0x4,%esp
8010791f:	6a 00                	push   $0x0
80107921:	50                   	push   %eax
80107922:	ff 75 08             	push   0x8(%ebp)
80107925:	e8 9e f9 ff ff       	call   801072c8 <walkpgdir>
8010792a:	83 c4 10             	add    $0x10,%esp
8010792d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107930:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107934:	75 16                	jne    8010794c <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107936:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107939:	c1 e8 16             	shr    $0x16,%eax
8010793c:	83 c0 01             	add    $0x1,%eax
8010793f:	c1 e0 16             	shl    $0x16,%eax
80107942:	2d 00 10 00 00       	sub    $0x1000,%eax
80107947:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010794a:	eb 4e                	jmp    8010799a <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
8010794c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010794f:	8b 00                	mov    (%eax),%eax
80107951:	83 e0 01             	and    $0x1,%eax
80107954:	85 c0                	test   %eax,%eax
80107956:	74 42                	je     8010799a <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80107958:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010795b:	8b 00                	mov    (%eax),%eax
8010795d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107962:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107965:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107969:	75 0d                	jne    80107978 <deallocuvm+0x8a>
        panic("kfree");
8010796b:	83 ec 0c             	sub    $0xc,%esp
8010796e:	68 c1 a7 10 80       	push   $0x8010a7c1
80107973:	e8 31 8c ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
80107978:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010797b:	05 00 00 00 80       	add    $0x80000000,%eax
80107980:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107983:	83 ec 0c             	sub    $0xc,%esp
80107986:	ff 75 e8             	push   -0x18(%ebp)
80107989:	e8 6b ad ff ff       	call   801026f9 <kfree>
8010798e:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107991:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107994:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
8010799a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801079a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801079a7:	0f 82 6c ff ff ff    	jb     80107919 <deallocuvm+0x2b>
    }
  }
  return newsz;
801079ad:	8b 45 10             	mov    0x10(%ebp),%eax
}
801079b0:	c9                   	leave  
801079b1:	c3                   	ret    

801079b2 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801079b2:	55                   	push   %ebp
801079b3:	89 e5                	mov    %esp,%ebp
801079b5:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801079b8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801079bc:	75 0d                	jne    801079cb <freevm+0x19>
    panic("freevm: no pgdir");
801079be:	83 ec 0c             	sub    $0xc,%esp
801079c1:	68 c7 a7 10 80       	push   $0x8010a7c7
801079c6:	e8 de 8b ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801079cb:	83 ec 04             	sub    $0x4,%esp
801079ce:	6a 00                	push   $0x0
801079d0:	68 00 00 00 80       	push   $0x80000000
801079d5:	ff 75 08             	push   0x8(%ebp)
801079d8:	e8 11 ff ff ff       	call   801078ee <deallocuvm>
801079dd:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801079e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801079e7:	eb 48                	jmp    80107a31 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
801079e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ec:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801079f3:	8b 45 08             	mov    0x8(%ebp),%eax
801079f6:	01 d0                	add    %edx,%eax
801079f8:	8b 00                	mov    (%eax),%eax
801079fa:	83 e0 01             	and    $0x1,%eax
801079fd:	85 c0                	test   %eax,%eax
801079ff:	74 2c                	je     80107a2d <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107a01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a04:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107a0b:	8b 45 08             	mov    0x8(%ebp),%eax
80107a0e:	01 d0                	add    %edx,%eax
80107a10:	8b 00                	mov    (%eax),%eax
80107a12:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107a17:	05 00 00 00 80       	add    $0x80000000,%eax
80107a1c:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107a1f:	83 ec 0c             	sub    $0xc,%esp
80107a22:	ff 75 f0             	push   -0x10(%ebp)
80107a25:	e8 cf ac ff ff       	call   801026f9 <kfree>
80107a2a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107a2d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107a31:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107a38:	76 af                	jbe    801079e9 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80107a3a:	83 ec 0c             	sub    $0xc,%esp
80107a3d:	ff 75 08             	push   0x8(%ebp)
80107a40:	e8 b4 ac ff ff       	call   801026f9 <kfree>
80107a45:	83 c4 10             	add    $0x10,%esp
}
80107a48:	90                   	nop
80107a49:	c9                   	leave  
80107a4a:	c3                   	ret    

80107a4b <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107a4b:	55                   	push   %ebp
80107a4c:	89 e5                	mov    %esp,%ebp
80107a4e:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107a51:	83 ec 04             	sub    $0x4,%esp
80107a54:	6a 00                	push   $0x0
80107a56:	ff 75 0c             	push   0xc(%ebp)
80107a59:	ff 75 08             	push   0x8(%ebp)
80107a5c:	e8 67 f8 ff ff       	call   801072c8 <walkpgdir>
80107a61:	83 c4 10             	add    $0x10,%esp
80107a64:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107a67:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107a6b:	75 0d                	jne    80107a7a <clearpteu+0x2f>
    panic("clearpteu");
80107a6d:	83 ec 0c             	sub    $0xc,%esp
80107a70:	68 d8 a7 10 80       	push   $0x8010a7d8
80107a75:	e8 2f 8b ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
80107a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7d:	8b 00                	mov    (%eax),%eax
80107a7f:	83 e0 fb             	and    $0xfffffffb,%eax
80107a82:	89 c2                	mov    %eax,%edx
80107a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a87:	89 10                	mov    %edx,(%eax)
}
80107a89:	90                   	nop
80107a8a:	c9                   	leave  
80107a8b:	c3                   	ret    

80107a8c <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107a8c:	55                   	push   %ebp
80107a8d:	89 e5                	mov    %esp,%ebp
80107a8f:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107a92:	e8 57 f9 ff ff       	call   801073ee <setupkvm>
80107a97:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107a9a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107a9e:	75 0a                	jne    80107aaa <copyuvm+0x1e>
    return 0;
80107aa0:	b8 00 00 00 00       	mov    $0x0,%eax
80107aa5:	e9 d7 00 00 00       	jmp    80107b81 <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
80107aaa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107ab1:	e9 a3 00 00 00       	jmp    80107b59 <copyuvm+0xcd>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107ab6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab9:	83 ec 04             	sub    $0x4,%esp
80107abc:	6a 00                	push   $0x0
80107abe:	50                   	push   %eax
80107abf:	ff 75 08             	push   0x8(%ebp)
80107ac2:	e8 01 f8 ff ff       	call   801072c8 <walkpgdir>
80107ac7:	83 c4 10             	add    $0x10,%esp
80107aca:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107acd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107ad1:	74 7b                	je     80107b4e <copyuvm+0xc2>
    {
      //panic("copyuvm: pte should exist");
      continue;
    }
    if(!(*pte & PTE_P))
80107ad3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ad6:	8b 00                	mov    (%eax),%eax
80107ad8:	83 e0 01             	and    $0x1,%eax
80107adb:	85 c0                	test   %eax,%eax
80107add:	74 72                	je     80107b51 <copyuvm+0xc5>
    {
      //panic("copyuvm: page not present");
      continue;
    }
    pa = PTE_ADDR(*pte);
80107adf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ae2:	8b 00                	mov    (%eax),%eax
80107ae4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ae9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107aec:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107aef:	8b 00                	mov    (%eax),%eax
80107af1:	25 ff 0f 00 00       	and    $0xfff,%eax
80107af6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107af9:	e8 95 ac ff ff       	call   80102793 <kalloc>
80107afe:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107b01:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107b05:	74 63                	je     80107b6a <copyuvm+0xde>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107b07:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107b0a:	05 00 00 00 80       	add    $0x80000000,%eax
80107b0f:	83 ec 04             	sub    $0x4,%esp
80107b12:	68 00 10 00 00       	push   $0x1000
80107b17:	50                   	push   %eax
80107b18:	ff 75 e0             	push   -0x20(%ebp)
80107b1b:	e8 74 d0 ff ff       	call   80104b94 <memmove>
80107b20:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107b23:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107b26:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107b29:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107b2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b32:	83 ec 0c             	sub    $0xc,%esp
80107b35:	52                   	push   %edx
80107b36:	51                   	push   %ecx
80107b37:	68 00 10 00 00       	push   $0x1000
80107b3c:	50                   	push   %eax
80107b3d:	ff 75 f0             	push   -0x10(%ebp)
80107b40:	e8 19 f8 ff ff       	call   8010735e <mappages>
80107b45:	83 c4 20             	add    $0x20,%esp
80107b48:	85 c0                	test   %eax,%eax
80107b4a:	78 21                	js     80107b6d <copyuvm+0xe1>
80107b4c:	eb 04                	jmp    80107b52 <copyuvm+0xc6>
      continue;
80107b4e:	90                   	nop
80107b4f:	eb 01                	jmp    80107b52 <copyuvm+0xc6>
      continue;
80107b51:	90                   	nop
  for(i = 0; i < sz; i += PGSIZE){
80107b52:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b5c:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107b5f:	0f 82 51 ff ff ff    	jb     80107ab6 <copyuvm+0x2a>
      goto bad;
  }
  return d;
80107b65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b68:	eb 17                	jmp    80107b81 <copyuvm+0xf5>
      goto bad;
80107b6a:	90                   	nop
80107b6b:	eb 01                	jmp    80107b6e <copyuvm+0xe2>
      goto bad;
80107b6d:	90                   	nop

bad:
  freevm(d);
80107b6e:	83 ec 0c             	sub    $0xc,%esp
80107b71:	ff 75 f0             	push   -0x10(%ebp)
80107b74:	e8 39 fe ff ff       	call   801079b2 <freevm>
80107b79:	83 c4 10             	add    $0x10,%esp
  return 0;
80107b7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107b81:	c9                   	leave  
80107b82:	c3                   	ret    

80107b83 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107b83:	55                   	push   %ebp
80107b84:	89 e5                	mov    %esp,%ebp
80107b86:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107b89:	83 ec 04             	sub    $0x4,%esp
80107b8c:	6a 00                	push   $0x0
80107b8e:	ff 75 0c             	push   0xc(%ebp)
80107b91:	ff 75 08             	push   0x8(%ebp)
80107b94:	e8 2f f7 ff ff       	call   801072c8 <walkpgdir>
80107b99:	83 c4 10             	add    $0x10,%esp
80107b9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80107b9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba2:	8b 00                	mov    (%eax),%eax
80107ba4:	83 e0 01             	and    $0x1,%eax
80107ba7:	85 c0                	test   %eax,%eax
80107ba9:	75 07                	jne    80107bb2 <uva2ka+0x2f>
    return 0;
80107bab:	b8 00 00 00 00       	mov    $0x0,%eax
80107bb0:	eb 22                	jmp    80107bd4 <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80107bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb5:	8b 00                	mov    (%eax),%eax
80107bb7:	83 e0 04             	and    $0x4,%eax
80107bba:	85 c0                	test   %eax,%eax
80107bbc:	75 07                	jne    80107bc5 <uva2ka+0x42>
    return 0;
80107bbe:	b8 00 00 00 00       	mov    $0x0,%eax
80107bc3:	eb 0f                	jmp    80107bd4 <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80107bc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc8:	8b 00                	mov    (%eax),%eax
80107bca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107bcf:	05 00 00 00 80       	add    $0x80000000,%eax
}
80107bd4:	c9                   	leave  
80107bd5:	c3                   	ret    

80107bd6 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107bd6:	55                   	push   %ebp
80107bd7:	89 e5                	mov    %esp,%ebp
80107bd9:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80107bdc:	8b 45 10             	mov    0x10(%ebp),%eax
80107bdf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80107be2:	eb 7f                	jmp    80107c63 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80107be4:	8b 45 0c             	mov    0xc(%ebp),%eax
80107be7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107bec:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80107bef:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107bf2:	83 ec 08             	sub    $0x8,%esp
80107bf5:	50                   	push   %eax
80107bf6:	ff 75 08             	push   0x8(%ebp)
80107bf9:	e8 85 ff ff ff       	call   80107b83 <uva2ka>
80107bfe:	83 c4 10             	add    $0x10,%esp
80107c01:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80107c04:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80107c08:	75 07                	jne    80107c11 <copyout+0x3b>
      return -1;
80107c0a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c0f:	eb 61                	jmp    80107c72 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80107c11:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c14:	2b 45 0c             	sub    0xc(%ebp),%eax
80107c17:	05 00 10 00 00       	add    $0x1000,%eax
80107c1c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80107c1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c22:	3b 45 14             	cmp    0x14(%ebp),%eax
80107c25:	76 06                	jbe    80107c2d <copyout+0x57>
      n = len;
80107c27:	8b 45 14             	mov    0x14(%ebp),%eax
80107c2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80107c2d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c30:	2b 45 ec             	sub    -0x14(%ebp),%eax
80107c33:	89 c2                	mov    %eax,%edx
80107c35:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107c38:	01 d0                	add    %edx,%eax
80107c3a:	83 ec 04             	sub    $0x4,%esp
80107c3d:	ff 75 f0             	push   -0x10(%ebp)
80107c40:	ff 75 f4             	push   -0xc(%ebp)
80107c43:	50                   	push   %eax
80107c44:	e8 4b cf ff ff       	call   80104b94 <memmove>
80107c49:	83 c4 10             	add    $0x10,%esp
    len -= n;
80107c4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c4f:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80107c52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c55:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80107c58:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c5b:	05 00 10 00 00       	add    $0x1000,%eax
80107c60:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80107c63:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80107c67:	0f 85 77 ff ff ff    	jne    80107be4 <copyout+0xe>
  }
  return 0;
80107c6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107c72:	c9                   	leave  
80107c73:	c3                   	ret    

80107c74 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80107c74:	55                   	push   %ebp
80107c75:	89 e5                	mov    %esp,%ebp
80107c77:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107c7a:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80107c81:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107c84:	8b 40 08             	mov    0x8(%eax),%eax
80107c87:	05 00 00 00 80       	add    $0x80000000,%eax
80107c8c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80107c8f:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80107c96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c99:	8b 40 24             	mov    0x24(%eax),%eax
80107c9c:	a3 00 41 19 80       	mov    %eax,0x80194100
  ncpu = 0;
80107ca1:	c7 05 40 6c 19 80 00 	movl   $0x0,0x80196c40
80107ca8:	00 00 00 

  while(i<madt->len){
80107cab:	90                   	nop
80107cac:	e9 bd 00 00 00       	jmp    80107d6e <mpinit_uefi+0xfa>
    uchar *entry_type = ((uchar *)madt)+i;
80107cb1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107cb4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107cb7:	01 d0                	add    %edx,%eax
80107cb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80107cbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cbf:	0f b6 00             	movzbl (%eax),%eax
80107cc2:	0f b6 c0             	movzbl %al,%eax
80107cc5:	83 f8 05             	cmp    $0x5,%eax
80107cc8:	0f 87 a0 00 00 00    	ja     80107d6e <mpinit_uefi+0xfa>
80107cce:	8b 04 85 e4 a7 10 80 	mov    -0x7fef581c(,%eax,4),%eax
80107cd5:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80107cd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cda:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80107cdd:	a1 40 6c 19 80       	mov    0x80196c40,%eax
80107ce2:	83 f8 03             	cmp    $0x3,%eax
80107ce5:	7f 28                	jg     80107d0f <mpinit_uefi+0x9b>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80107ce7:	8b 15 40 6c 19 80    	mov    0x80196c40,%edx
80107ced:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107cf0:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80107cf4:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80107cfa:	81 c2 80 69 19 80    	add    $0x80196980,%edx
80107d00:	88 02                	mov    %al,(%edx)
          ncpu++;
80107d02:	a1 40 6c 19 80       	mov    0x80196c40,%eax
80107d07:	83 c0 01             	add    $0x1,%eax
80107d0a:	a3 40 6c 19 80       	mov    %eax,0x80196c40
        }
        i += lapic_entry->record_len;
80107d0f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107d12:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107d16:	0f b6 c0             	movzbl %al,%eax
80107d19:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107d1c:	eb 50                	jmp    80107d6e <mpinit_uefi+0xfa>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80107d1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d21:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80107d24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107d27:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80107d2b:	a2 44 6c 19 80       	mov    %al,0x80196c44
        i += ioapic->record_len;
80107d30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107d33:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107d37:	0f b6 c0             	movzbl %al,%eax
80107d3a:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107d3d:	eb 2f                	jmp    80107d6e <mpinit_uefi+0xfa>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80107d3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d42:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80107d45:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107d48:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107d4c:	0f b6 c0             	movzbl %al,%eax
80107d4f:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107d52:	eb 1a                	jmp    80107d6e <mpinit_uefi+0xfa>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80107d54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d57:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80107d5a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d5d:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107d61:	0f b6 c0             	movzbl %al,%eax
80107d64:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107d67:	eb 05                	jmp    80107d6e <mpinit_uefi+0xfa>

      case 5:
        i = i + 0xC;
80107d69:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80107d6d:	90                   	nop
  while(i<madt->len){
80107d6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d71:	8b 40 04             	mov    0x4(%eax),%eax
80107d74:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80107d77:	0f 82 34 ff ff ff    	jb     80107cb1 <mpinit_uefi+0x3d>
    }
  }

}
80107d7d:	90                   	nop
80107d7e:	90                   	nop
80107d7f:	c9                   	leave  
80107d80:	c3                   	ret    

80107d81 <inb>:
{
80107d81:	55                   	push   %ebp
80107d82:	89 e5                	mov    %esp,%ebp
80107d84:	83 ec 14             	sub    $0x14,%esp
80107d87:	8b 45 08             	mov    0x8(%ebp),%eax
80107d8a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107d8e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107d92:	89 c2                	mov    %eax,%edx
80107d94:	ec                   	in     (%dx),%al
80107d95:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107d98:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107d9c:	c9                   	leave  
80107d9d:	c3                   	ret    

80107d9e <outb>:
{
80107d9e:	55                   	push   %ebp
80107d9f:	89 e5                	mov    %esp,%ebp
80107da1:	83 ec 08             	sub    $0x8,%esp
80107da4:	8b 45 08             	mov    0x8(%ebp),%eax
80107da7:	8b 55 0c             	mov    0xc(%ebp),%edx
80107daa:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80107dae:	89 d0                	mov    %edx,%eax
80107db0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107db3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107db7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107dbb:	ee                   	out    %al,(%dx)
}
80107dbc:	90                   	nop
80107dbd:	c9                   	leave  
80107dbe:	c3                   	ret    

80107dbf <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80107dbf:	55                   	push   %ebp
80107dc0:	89 e5                	mov    %esp,%ebp
80107dc2:	83 ec 28             	sub    $0x28,%esp
80107dc5:	8b 45 08             	mov    0x8(%ebp),%eax
80107dc8:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80107dcb:	6a 00                	push   $0x0
80107dcd:	68 fa 03 00 00       	push   $0x3fa
80107dd2:	e8 c7 ff ff ff       	call   80107d9e <outb>
80107dd7:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107dda:	68 80 00 00 00       	push   $0x80
80107ddf:	68 fb 03 00 00       	push   $0x3fb
80107de4:	e8 b5 ff ff ff       	call   80107d9e <outb>
80107de9:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107dec:	6a 0c                	push   $0xc
80107dee:	68 f8 03 00 00       	push   $0x3f8
80107df3:	e8 a6 ff ff ff       	call   80107d9e <outb>
80107df8:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107dfb:	6a 00                	push   $0x0
80107dfd:	68 f9 03 00 00       	push   $0x3f9
80107e02:	e8 97 ff ff ff       	call   80107d9e <outb>
80107e07:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107e0a:	6a 03                	push   $0x3
80107e0c:	68 fb 03 00 00       	push   $0x3fb
80107e11:	e8 88 ff ff ff       	call   80107d9e <outb>
80107e16:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107e19:	6a 00                	push   $0x0
80107e1b:	68 fc 03 00 00       	push   $0x3fc
80107e20:	e8 79 ff ff ff       	call   80107d9e <outb>
80107e25:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
80107e28:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107e2f:	eb 11                	jmp    80107e42 <uart_debug+0x83>
80107e31:	83 ec 0c             	sub    $0xc,%esp
80107e34:	6a 0a                	push   $0xa
80107e36:	e8 ef ac ff ff       	call   80102b2a <microdelay>
80107e3b:	83 c4 10             	add    $0x10,%esp
80107e3e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107e42:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107e46:	7f 1a                	jg     80107e62 <uart_debug+0xa3>
80107e48:	83 ec 0c             	sub    $0xc,%esp
80107e4b:	68 fd 03 00 00       	push   $0x3fd
80107e50:	e8 2c ff ff ff       	call   80107d81 <inb>
80107e55:	83 c4 10             	add    $0x10,%esp
80107e58:	0f b6 c0             	movzbl %al,%eax
80107e5b:	83 e0 20             	and    $0x20,%eax
80107e5e:	85 c0                	test   %eax,%eax
80107e60:	74 cf                	je     80107e31 <uart_debug+0x72>
  outb(COM1+0, p);
80107e62:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80107e66:	0f b6 c0             	movzbl %al,%eax
80107e69:	83 ec 08             	sub    $0x8,%esp
80107e6c:	50                   	push   %eax
80107e6d:	68 f8 03 00 00       	push   $0x3f8
80107e72:	e8 27 ff ff ff       	call   80107d9e <outb>
80107e77:	83 c4 10             	add    $0x10,%esp
}
80107e7a:	90                   	nop
80107e7b:	c9                   	leave  
80107e7c:	c3                   	ret    

80107e7d <uart_debugs>:

void uart_debugs(char *p){
80107e7d:	55                   	push   %ebp
80107e7e:	89 e5                	mov    %esp,%ebp
80107e80:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80107e83:	eb 1b                	jmp    80107ea0 <uart_debugs+0x23>
    uart_debug(*p++);
80107e85:	8b 45 08             	mov    0x8(%ebp),%eax
80107e88:	8d 50 01             	lea    0x1(%eax),%edx
80107e8b:	89 55 08             	mov    %edx,0x8(%ebp)
80107e8e:	0f b6 00             	movzbl (%eax),%eax
80107e91:	0f be c0             	movsbl %al,%eax
80107e94:	83 ec 0c             	sub    $0xc,%esp
80107e97:	50                   	push   %eax
80107e98:	e8 22 ff ff ff       	call   80107dbf <uart_debug>
80107e9d:	83 c4 10             	add    $0x10,%esp
  while(*p){
80107ea0:	8b 45 08             	mov    0x8(%ebp),%eax
80107ea3:	0f b6 00             	movzbl (%eax),%eax
80107ea6:	84 c0                	test   %al,%al
80107ea8:	75 db                	jne    80107e85 <uart_debugs+0x8>
  }
}
80107eaa:	90                   	nop
80107eab:	90                   	nop
80107eac:	c9                   	leave  
80107ead:	c3                   	ret    

80107eae <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80107eae:	55                   	push   %ebp
80107eaf:	89 e5                	mov    %esp,%ebp
80107eb1:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107eb4:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80107ebb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107ebe:	8b 50 14             	mov    0x14(%eax),%edx
80107ec1:	8b 40 10             	mov    0x10(%eax),%eax
80107ec4:	a3 48 6c 19 80       	mov    %eax,0x80196c48
  gpu.vram_size = boot_param->graphic_config.frame_size;
80107ec9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107ecc:	8b 50 1c             	mov    0x1c(%eax),%edx
80107ecf:	8b 40 18             	mov    0x18(%eax),%eax
80107ed2:	a3 50 6c 19 80       	mov    %eax,0x80196c50
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80107ed7:	8b 15 50 6c 19 80    	mov    0x80196c50,%edx
80107edd:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
80107ee2:	29 d0                	sub    %edx,%eax
80107ee4:	a3 4c 6c 19 80       	mov    %eax,0x80196c4c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80107ee9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107eec:	8b 50 24             	mov    0x24(%eax),%edx
80107eef:	8b 40 20             	mov    0x20(%eax),%eax
80107ef2:	a3 54 6c 19 80       	mov    %eax,0x80196c54
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80107ef7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107efa:	8b 50 2c             	mov    0x2c(%eax),%edx
80107efd:	8b 40 28             	mov    0x28(%eax),%eax
80107f00:	a3 58 6c 19 80       	mov    %eax,0x80196c58
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80107f05:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107f08:	8b 50 34             	mov    0x34(%eax),%edx
80107f0b:	8b 40 30             	mov    0x30(%eax),%eax
80107f0e:	a3 5c 6c 19 80       	mov    %eax,0x80196c5c
}
80107f13:	90                   	nop
80107f14:	c9                   	leave  
80107f15:	c3                   	ret    

80107f16 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80107f16:	55                   	push   %ebp
80107f17:	89 e5                	mov    %esp,%ebp
80107f19:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80107f1c:	8b 15 5c 6c 19 80    	mov    0x80196c5c,%edx
80107f22:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f25:	0f af d0             	imul   %eax,%edx
80107f28:	8b 45 08             	mov    0x8(%ebp),%eax
80107f2b:	01 d0                	add    %edx,%eax
80107f2d:	c1 e0 02             	shl    $0x2,%eax
80107f30:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80107f33:	8b 15 4c 6c 19 80    	mov    0x80196c4c,%edx
80107f39:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107f3c:	01 d0                	add    %edx,%eax
80107f3e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80107f41:	8b 45 10             	mov    0x10(%ebp),%eax
80107f44:	0f b6 10             	movzbl (%eax),%edx
80107f47:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107f4a:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80107f4c:	8b 45 10             	mov    0x10(%ebp),%eax
80107f4f:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80107f53:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107f56:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80107f59:	8b 45 10             	mov    0x10(%ebp),%eax
80107f5c:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80107f60:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107f63:	88 50 02             	mov    %dl,0x2(%eax)
}
80107f66:	90                   	nop
80107f67:	c9                   	leave  
80107f68:	c3                   	ret    

80107f69 <graphic_scroll_up>:

void graphic_scroll_up(int height){
80107f69:	55                   	push   %ebp
80107f6a:	89 e5                	mov    %esp,%ebp
80107f6c:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80107f6f:	8b 15 5c 6c 19 80    	mov    0x80196c5c,%edx
80107f75:	8b 45 08             	mov    0x8(%ebp),%eax
80107f78:	0f af c2             	imul   %edx,%eax
80107f7b:	c1 e0 02             	shl    $0x2,%eax
80107f7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80107f81:	a1 50 6c 19 80       	mov    0x80196c50,%eax
80107f86:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107f89:	29 d0                	sub    %edx,%eax
80107f8b:	8b 0d 4c 6c 19 80    	mov    0x80196c4c,%ecx
80107f91:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107f94:	01 ca                	add    %ecx,%edx
80107f96:	89 d1                	mov    %edx,%ecx
80107f98:	8b 15 4c 6c 19 80    	mov    0x80196c4c,%edx
80107f9e:	83 ec 04             	sub    $0x4,%esp
80107fa1:	50                   	push   %eax
80107fa2:	51                   	push   %ecx
80107fa3:	52                   	push   %edx
80107fa4:	e8 eb cb ff ff       	call   80104b94 <memmove>
80107fa9:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80107fac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107faf:	8b 0d 4c 6c 19 80    	mov    0x80196c4c,%ecx
80107fb5:	8b 15 50 6c 19 80    	mov    0x80196c50,%edx
80107fbb:	01 ca                	add    %ecx,%edx
80107fbd:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80107fc0:	29 ca                	sub    %ecx,%edx
80107fc2:	83 ec 04             	sub    $0x4,%esp
80107fc5:	50                   	push   %eax
80107fc6:	6a 00                	push   $0x0
80107fc8:	52                   	push   %edx
80107fc9:	e8 07 cb ff ff       	call   80104ad5 <memset>
80107fce:	83 c4 10             	add    $0x10,%esp
}
80107fd1:	90                   	nop
80107fd2:	c9                   	leave  
80107fd3:	c3                   	ret    

80107fd4 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80107fd4:	55                   	push   %ebp
80107fd5:	89 e5                	mov    %esp,%ebp
80107fd7:	53                   	push   %ebx
80107fd8:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80107fdb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107fe2:	e9 b1 00 00 00       	jmp    80108098 <font_render+0xc4>
    for(int j=14;j>-1;j--){
80107fe7:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80107fee:	e9 97 00 00 00       	jmp    8010808a <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
80107ff3:	8b 45 10             	mov    0x10(%ebp),%eax
80107ff6:	83 e8 20             	sub    $0x20,%eax
80107ff9:	6b d0 1e             	imul   $0x1e,%eax,%edx
80107ffc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fff:	01 d0                	add    %edx,%eax
80108001:	0f b7 84 00 00 a8 10 	movzwl -0x7fef5800(%eax,%eax,1),%eax
80108008:	80 
80108009:	0f b7 d0             	movzwl %ax,%edx
8010800c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010800f:	bb 01 00 00 00       	mov    $0x1,%ebx
80108014:	89 c1                	mov    %eax,%ecx
80108016:	d3 e3                	shl    %cl,%ebx
80108018:	89 d8                	mov    %ebx,%eax
8010801a:	21 d0                	and    %edx,%eax
8010801c:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
8010801f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108022:	ba 01 00 00 00       	mov    $0x1,%edx
80108027:	89 c1                	mov    %eax,%ecx
80108029:	d3 e2                	shl    %cl,%edx
8010802b:	89 d0                	mov    %edx,%eax
8010802d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80108030:	75 2b                	jne    8010805d <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80108032:	8b 55 0c             	mov    0xc(%ebp),%edx
80108035:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108038:	01 c2                	add    %eax,%edx
8010803a:	b8 0e 00 00 00       	mov    $0xe,%eax
8010803f:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108042:	89 c1                	mov    %eax,%ecx
80108044:	8b 45 08             	mov    0x8(%ebp),%eax
80108047:	01 c8                	add    %ecx,%eax
80108049:	83 ec 04             	sub    $0x4,%esp
8010804c:	68 e0 f4 10 80       	push   $0x8010f4e0
80108051:	52                   	push   %edx
80108052:	50                   	push   %eax
80108053:	e8 be fe ff ff       	call   80107f16 <graphic_draw_pixel>
80108058:	83 c4 10             	add    $0x10,%esp
8010805b:	eb 29                	jmp    80108086 <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
8010805d:	8b 55 0c             	mov    0xc(%ebp),%edx
80108060:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108063:	01 c2                	add    %eax,%edx
80108065:	b8 0e 00 00 00       	mov    $0xe,%eax
8010806a:	2b 45 f0             	sub    -0x10(%ebp),%eax
8010806d:	89 c1                	mov    %eax,%ecx
8010806f:	8b 45 08             	mov    0x8(%ebp),%eax
80108072:	01 c8                	add    %ecx,%eax
80108074:	83 ec 04             	sub    $0x4,%esp
80108077:	68 60 6c 19 80       	push   $0x80196c60
8010807c:	52                   	push   %edx
8010807d:	50                   	push   %eax
8010807e:	e8 93 fe ff ff       	call   80107f16 <graphic_draw_pixel>
80108083:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108086:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
8010808a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010808e:	0f 89 5f ff ff ff    	jns    80107ff3 <font_render+0x1f>
  for(int i=0;i<30;i++){
80108094:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108098:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
8010809c:	0f 8e 45 ff ff ff    	jle    80107fe7 <font_render+0x13>
      }
    }
  }
}
801080a2:	90                   	nop
801080a3:	90                   	nop
801080a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801080a7:	c9                   	leave  
801080a8:	c3                   	ret    

801080a9 <font_render_string>:

void font_render_string(char *string,int row){
801080a9:	55                   	push   %ebp
801080aa:	89 e5                	mov    %esp,%ebp
801080ac:	53                   	push   %ebx
801080ad:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
801080b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
801080b7:	eb 33                	jmp    801080ec <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
801080b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801080bc:	8b 45 08             	mov    0x8(%ebp),%eax
801080bf:	01 d0                	add    %edx,%eax
801080c1:	0f b6 00             	movzbl (%eax),%eax
801080c4:	0f be c8             	movsbl %al,%ecx
801080c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801080ca:	6b d0 1e             	imul   $0x1e,%eax,%edx
801080cd:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801080d0:	89 d8                	mov    %ebx,%eax
801080d2:	c1 e0 04             	shl    $0x4,%eax
801080d5:	29 d8                	sub    %ebx,%eax
801080d7:	83 c0 02             	add    $0x2,%eax
801080da:	83 ec 04             	sub    $0x4,%esp
801080dd:	51                   	push   %ecx
801080de:	52                   	push   %edx
801080df:	50                   	push   %eax
801080e0:	e8 ef fe ff ff       	call   80107fd4 <font_render>
801080e5:	83 c4 10             	add    $0x10,%esp
    i++;
801080e8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
801080ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
801080ef:	8b 45 08             	mov    0x8(%ebp),%eax
801080f2:	01 d0                	add    %edx,%eax
801080f4:	0f b6 00             	movzbl (%eax),%eax
801080f7:	84 c0                	test   %al,%al
801080f9:	74 06                	je     80108101 <font_render_string+0x58>
801080fb:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
801080ff:	7e b8                	jle    801080b9 <font_render_string+0x10>
  }
}
80108101:	90                   	nop
80108102:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108105:	c9                   	leave  
80108106:	c3                   	ret    

80108107 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80108107:	55                   	push   %ebp
80108108:	89 e5                	mov    %esp,%ebp
8010810a:	53                   	push   %ebx
8010810b:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
8010810e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108115:	eb 6b                	jmp    80108182 <pci_init+0x7b>
    for(int j=0;j<32;j++){
80108117:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010811e:	eb 58                	jmp    80108178 <pci_init+0x71>
      for(int k=0;k<8;k++){
80108120:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108127:	eb 45                	jmp    8010816e <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
80108129:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010812c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010812f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108132:	83 ec 0c             	sub    $0xc,%esp
80108135:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108138:	53                   	push   %ebx
80108139:	6a 00                	push   $0x0
8010813b:	51                   	push   %ecx
8010813c:	52                   	push   %edx
8010813d:	50                   	push   %eax
8010813e:	e8 b0 00 00 00       	call   801081f3 <pci_access_config>
80108143:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
80108146:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108149:	0f b7 c0             	movzwl %ax,%eax
8010814c:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108151:	74 17                	je     8010816a <pci_init+0x63>
        pci_init_device(i,j,k);
80108153:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108156:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010815c:	83 ec 04             	sub    $0x4,%esp
8010815f:	51                   	push   %ecx
80108160:	52                   	push   %edx
80108161:	50                   	push   %eax
80108162:	e8 37 01 00 00       	call   8010829e <pci_init_device>
80108167:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
8010816a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010816e:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108172:	7e b5                	jle    80108129 <pci_init+0x22>
    for(int j=0;j<32;j++){
80108174:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108178:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
8010817c:	7e a2                	jle    80108120 <pci_init+0x19>
  for(int i=0;i<256;i++){
8010817e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108182:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108189:	7e 8c                	jle    80108117 <pci_init+0x10>
      }
      }
    }
  }
}
8010818b:	90                   	nop
8010818c:	90                   	nop
8010818d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108190:	c9                   	leave  
80108191:	c3                   	ret    

80108192 <pci_write_config>:

void pci_write_config(uint config){
80108192:	55                   	push   %ebp
80108193:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108195:	8b 45 08             	mov    0x8(%ebp),%eax
80108198:	ba f8 0c 00 00       	mov    $0xcf8,%edx
8010819d:	89 c0                	mov    %eax,%eax
8010819f:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801081a0:	90                   	nop
801081a1:	5d                   	pop    %ebp
801081a2:	c3                   	ret    

801081a3 <pci_write_data>:

void pci_write_data(uint config){
801081a3:	55                   	push   %ebp
801081a4:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
801081a6:	8b 45 08             	mov    0x8(%ebp),%eax
801081a9:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801081ae:	89 c0                	mov    %eax,%eax
801081b0:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801081b1:	90                   	nop
801081b2:	5d                   	pop    %ebp
801081b3:	c3                   	ret    

801081b4 <pci_read_config>:
uint pci_read_config(){
801081b4:	55                   	push   %ebp
801081b5:	89 e5                	mov    %esp,%ebp
801081b7:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
801081ba:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801081bf:	ed                   	in     (%dx),%eax
801081c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
801081c3:	83 ec 0c             	sub    $0xc,%esp
801081c6:	68 c8 00 00 00       	push   $0xc8
801081cb:	e8 5a a9 ff ff       	call   80102b2a <microdelay>
801081d0:	83 c4 10             	add    $0x10,%esp
  return data;
801081d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801081d6:	c9                   	leave  
801081d7:	c3                   	ret    

801081d8 <pci_test>:


void pci_test(){
801081d8:	55                   	push   %ebp
801081d9:	89 e5                	mov    %esp,%ebp
801081db:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
801081de:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
801081e5:	ff 75 fc             	push   -0x4(%ebp)
801081e8:	e8 a5 ff ff ff       	call   80108192 <pci_write_config>
801081ed:	83 c4 04             	add    $0x4,%esp
}
801081f0:	90                   	nop
801081f1:	c9                   	leave  
801081f2:	c3                   	ret    

801081f3 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
801081f3:	55                   	push   %ebp
801081f4:	89 e5                	mov    %esp,%ebp
801081f6:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801081f9:	8b 45 08             	mov    0x8(%ebp),%eax
801081fc:	c1 e0 10             	shl    $0x10,%eax
801081ff:	25 00 00 ff 00       	and    $0xff0000,%eax
80108204:	89 c2                	mov    %eax,%edx
80108206:	8b 45 0c             	mov    0xc(%ebp),%eax
80108209:	c1 e0 0b             	shl    $0xb,%eax
8010820c:	0f b7 c0             	movzwl %ax,%eax
8010820f:	09 c2                	or     %eax,%edx
80108211:	8b 45 10             	mov    0x10(%ebp),%eax
80108214:	c1 e0 08             	shl    $0x8,%eax
80108217:	25 00 07 00 00       	and    $0x700,%eax
8010821c:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
8010821e:	8b 45 14             	mov    0x14(%ebp),%eax
80108221:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108226:	09 d0                	or     %edx,%eax
80108228:	0d 00 00 00 80       	or     $0x80000000,%eax
8010822d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80108230:	ff 75 f4             	push   -0xc(%ebp)
80108233:	e8 5a ff ff ff       	call   80108192 <pci_write_config>
80108238:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
8010823b:	e8 74 ff ff ff       	call   801081b4 <pci_read_config>
80108240:	8b 55 18             	mov    0x18(%ebp),%edx
80108243:	89 02                	mov    %eax,(%edx)
}
80108245:	90                   	nop
80108246:	c9                   	leave  
80108247:	c3                   	ret    

80108248 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108248:	55                   	push   %ebp
80108249:	89 e5                	mov    %esp,%ebp
8010824b:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010824e:	8b 45 08             	mov    0x8(%ebp),%eax
80108251:	c1 e0 10             	shl    $0x10,%eax
80108254:	25 00 00 ff 00       	and    $0xff0000,%eax
80108259:	89 c2                	mov    %eax,%edx
8010825b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010825e:	c1 e0 0b             	shl    $0xb,%eax
80108261:	0f b7 c0             	movzwl %ax,%eax
80108264:	09 c2                	or     %eax,%edx
80108266:	8b 45 10             	mov    0x10(%ebp),%eax
80108269:	c1 e0 08             	shl    $0x8,%eax
8010826c:	25 00 07 00 00       	and    $0x700,%eax
80108271:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108273:	8b 45 14             	mov    0x14(%ebp),%eax
80108276:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010827b:	09 d0                	or     %edx,%eax
8010827d:	0d 00 00 00 80       	or     $0x80000000,%eax
80108282:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108285:	ff 75 fc             	push   -0x4(%ebp)
80108288:	e8 05 ff ff ff       	call   80108192 <pci_write_config>
8010828d:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108290:	ff 75 18             	push   0x18(%ebp)
80108293:	e8 0b ff ff ff       	call   801081a3 <pci_write_data>
80108298:	83 c4 04             	add    $0x4,%esp
}
8010829b:	90                   	nop
8010829c:	c9                   	leave  
8010829d:	c3                   	ret    

8010829e <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
8010829e:	55                   	push   %ebp
8010829f:	89 e5                	mov    %esp,%ebp
801082a1:	53                   	push   %ebx
801082a2:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
801082a5:	8b 45 08             	mov    0x8(%ebp),%eax
801082a8:	a2 64 6c 19 80       	mov    %al,0x80196c64
  dev.device_num = device_num;
801082ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801082b0:	a2 65 6c 19 80       	mov    %al,0x80196c65
  dev.function_num = function_num;
801082b5:	8b 45 10             	mov    0x10(%ebp),%eax
801082b8:	a2 66 6c 19 80       	mov    %al,0x80196c66
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
801082bd:	ff 75 10             	push   0x10(%ebp)
801082c0:	ff 75 0c             	push   0xc(%ebp)
801082c3:	ff 75 08             	push   0x8(%ebp)
801082c6:	68 44 be 10 80       	push   $0x8010be44
801082cb:	e8 24 81 ff ff       	call   801003f4 <cprintf>
801082d0:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
801082d3:	83 ec 0c             	sub    $0xc,%esp
801082d6:	8d 45 ec             	lea    -0x14(%ebp),%eax
801082d9:	50                   	push   %eax
801082da:	6a 00                	push   $0x0
801082dc:	ff 75 10             	push   0x10(%ebp)
801082df:	ff 75 0c             	push   0xc(%ebp)
801082e2:	ff 75 08             	push   0x8(%ebp)
801082e5:	e8 09 ff ff ff       	call   801081f3 <pci_access_config>
801082ea:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
801082ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082f0:	c1 e8 10             	shr    $0x10,%eax
801082f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
801082f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082f9:	25 ff ff 00 00       	and    $0xffff,%eax
801082fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108301:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108304:	a3 68 6c 19 80       	mov    %eax,0x80196c68
  dev.vendor_id = vendor_id;
80108309:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010830c:	a3 6c 6c 19 80       	mov    %eax,0x80196c6c
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108311:	83 ec 04             	sub    $0x4,%esp
80108314:	ff 75 f0             	push   -0x10(%ebp)
80108317:	ff 75 f4             	push   -0xc(%ebp)
8010831a:	68 78 be 10 80       	push   $0x8010be78
8010831f:	e8 d0 80 ff ff       	call   801003f4 <cprintf>
80108324:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
80108327:	83 ec 0c             	sub    $0xc,%esp
8010832a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010832d:	50                   	push   %eax
8010832e:	6a 08                	push   $0x8
80108330:	ff 75 10             	push   0x10(%ebp)
80108333:	ff 75 0c             	push   0xc(%ebp)
80108336:	ff 75 08             	push   0x8(%ebp)
80108339:	e8 b5 fe ff ff       	call   801081f3 <pci_access_config>
8010833e:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108341:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108344:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108347:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010834a:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010834d:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108350:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108353:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108356:	0f b6 c0             	movzbl %al,%eax
80108359:	8b 5d ec             	mov    -0x14(%ebp),%ebx
8010835c:	c1 eb 18             	shr    $0x18,%ebx
8010835f:	83 ec 0c             	sub    $0xc,%esp
80108362:	51                   	push   %ecx
80108363:	52                   	push   %edx
80108364:	50                   	push   %eax
80108365:	53                   	push   %ebx
80108366:	68 9c be 10 80       	push   $0x8010be9c
8010836b:	e8 84 80 ff ff       	call   801003f4 <cprintf>
80108370:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108373:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108376:	c1 e8 18             	shr    $0x18,%eax
80108379:	a2 70 6c 19 80       	mov    %al,0x80196c70
  dev.sub_class = (data>>16)&0xFF;
8010837e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108381:	c1 e8 10             	shr    $0x10,%eax
80108384:	a2 71 6c 19 80       	mov    %al,0x80196c71
  dev.interface = (data>>8)&0xFF;
80108389:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010838c:	c1 e8 08             	shr    $0x8,%eax
8010838f:	a2 72 6c 19 80       	mov    %al,0x80196c72
  dev.revision_id = data&0xFF;
80108394:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108397:	a2 73 6c 19 80       	mov    %al,0x80196c73
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
8010839c:	83 ec 0c             	sub    $0xc,%esp
8010839f:	8d 45 ec             	lea    -0x14(%ebp),%eax
801083a2:	50                   	push   %eax
801083a3:	6a 10                	push   $0x10
801083a5:	ff 75 10             	push   0x10(%ebp)
801083a8:	ff 75 0c             	push   0xc(%ebp)
801083ab:	ff 75 08             	push   0x8(%ebp)
801083ae:	e8 40 fe ff ff       	call   801081f3 <pci_access_config>
801083b3:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
801083b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083b9:	a3 74 6c 19 80       	mov    %eax,0x80196c74
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
801083be:	83 ec 0c             	sub    $0xc,%esp
801083c1:	8d 45 ec             	lea    -0x14(%ebp),%eax
801083c4:	50                   	push   %eax
801083c5:	6a 14                	push   $0x14
801083c7:	ff 75 10             	push   0x10(%ebp)
801083ca:	ff 75 0c             	push   0xc(%ebp)
801083cd:	ff 75 08             	push   0x8(%ebp)
801083d0:	e8 1e fe ff ff       	call   801081f3 <pci_access_config>
801083d5:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
801083d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083db:	a3 78 6c 19 80       	mov    %eax,0x80196c78
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
801083e0:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
801083e7:	75 5a                	jne    80108443 <pci_init_device+0x1a5>
801083e9:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
801083f0:	75 51                	jne    80108443 <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
801083f2:	83 ec 0c             	sub    $0xc,%esp
801083f5:	68 e1 be 10 80       	push   $0x8010bee1
801083fa:	e8 f5 7f ff ff       	call   801003f4 <cprintf>
801083ff:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108402:	83 ec 0c             	sub    $0xc,%esp
80108405:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108408:	50                   	push   %eax
80108409:	68 f0 00 00 00       	push   $0xf0
8010840e:	ff 75 10             	push   0x10(%ebp)
80108411:	ff 75 0c             	push   0xc(%ebp)
80108414:	ff 75 08             	push   0x8(%ebp)
80108417:	e8 d7 fd ff ff       	call   801081f3 <pci_access_config>
8010841c:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
8010841f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108422:	83 ec 08             	sub    $0x8,%esp
80108425:	50                   	push   %eax
80108426:	68 fb be 10 80       	push   $0x8010befb
8010842b:	e8 c4 7f ff ff       	call   801003f4 <cprintf>
80108430:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108433:	83 ec 0c             	sub    $0xc,%esp
80108436:	68 64 6c 19 80       	push   $0x80196c64
8010843b:	e8 09 00 00 00       	call   80108449 <i8254_init>
80108440:	83 c4 10             	add    $0x10,%esp
  }
}
80108443:	90                   	nop
80108444:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108447:	c9                   	leave  
80108448:	c3                   	ret    

80108449 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108449:	55                   	push   %ebp
8010844a:	89 e5                	mov    %esp,%ebp
8010844c:	53                   	push   %ebx
8010844d:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108450:	8b 45 08             	mov    0x8(%ebp),%eax
80108453:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108457:	0f b6 c8             	movzbl %al,%ecx
8010845a:	8b 45 08             	mov    0x8(%ebp),%eax
8010845d:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108461:	0f b6 d0             	movzbl %al,%edx
80108464:	8b 45 08             	mov    0x8(%ebp),%eax
80108467:	0f b6 00             	movzbl (%eax),%eax
8010846a:	0f b6 c0             	movzbl %al,%eax
8010846d:	83 ec 0c             	sub    $0xc,%esp
80108470:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108473:	53                   	push   %ebx
80108474:	6a 04                	push   $0x4
80108476:	51                   	push   %ecx
80108477:	52                   	push   %edx
80108478:	50                   	push   %eax
80108479:	e8 75 fd ff ff       	call   801081f3 <pci_access_config>
8010847e:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108481:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108484:	83 c8 04             	or     $0x4,%eax
80108487:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
8010848a:	8b 5d ec             	mov    -0x14(%ebp),%ebx
8010848d:	8b 45 08             	mov    0x8(%ebp),%eax
80108490:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108494:	0f b6 c8             	movzbl %al,%ecx
80108497:	8b 45 08             	mov    0x8(%ebp),%eax
8010849a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010849e:	0f b6 d0             	movzbl %al,%edx
801084a1:	8b 45 08             	mov    0x8(%ebp),%eax
801084a4:	0f b6 00             	movzbl (%eax),%eax
801084a7:	0f b6 c0             	movzbl %al,%eax
801084aa:	83 ec 0c             	sub    $0xc,%esp
801084ad:	53                   	push   %ebx
801084ae:	6a 04                	push   $0x4
801084b0:	51                   	push   %ecx
801084b1:	52                   	push   %edx
801084b2:	50                   	push   %eax
801084b3:	e8 90 fd ff ff       	call   80108248 <pci_write_config_register>
801084b8:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
801084bb:	8b 45 08             	mov    0x8(%ebp),%eax
801084be:	8b 40 10             	mov    0x10(%eax),%eax
801084c1:	05 00 00 00 40       	add    $0x40000000,%eax
801084c6:	a3 7c 6c 19 80       	mov    %eax,0x80196c7c
  uint *ctrl = (uint *)base_addr;
801084cb:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801084d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
801084d3:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801084d8:	05 d8 00 00 00       	add    $0xd8,%eax
801084dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
801084e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084e3:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
801084e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ec:	8b 00                	mov    (%eax),%eax
801084ee:	0d 00 00 00 04       	or     $0x4000000,%eax
801084f3:	89 c2                	mov    %eax,%edx
801084f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084f8:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
801084fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084fd:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108503:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108506:	8b 00                	mov    (%eax),%eax
80108508:	83 c8 40             	or     $0x40,%eax
8010850b:	89 c2                	mov    %eax,%edx
8010850d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108510:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108512:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108515:	8b 10                	mov    (%eax),%edx
80108517:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010851a:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
8010851c:	83 ec 0c             	sub    $0xc,%esp
8010851f:	68 10 bf 10 80       	push   $0x8010bf10
80108524:	e8 cb 7e ff ff       	call   801003f4 <cprintf>
80108529:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
8010852c:	e8 62 a2 ff ff       	call   80102793 <kalloc>
80108531:	a3 88 6c 19 80       	mov    %eax,0x80196c88
  *intr_addr = 0;
80108536:	a1 88 6c 19 80       	mov    0x80196c88,%eax
8010853b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108541:	a1 88 6c 19 80       	mov    0x80196c88,%eax
80108546:	83 ec 08             	sub    $0x8,%esp
80108549:	50                   	push   %eax
8010854a:	68 32 bf 10 80       	push   $0x8010bf32
8010854f:	e8 a0 7e ff ff       	call   801003f4 <cprintf>
80108554:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108557:	e8 50 00 00 00       	call   801085ac <i8254_init_recv>
  i8254_init_send();
8010855c:	e8 69 03 00 00       	call   801088ca <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108561:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108568:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
8010856b:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108572:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108575:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010857c:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
8010857f:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108586:	0f b6 c0             	movzbl %al,%eax
80108589:	83 ec 0c             	sub    $0xc,%esp
8010858c:	53                   	push   %ebx
8010858d:	51                   	push   %ecx
8010858e:	52                   	push   %edx
8010858f:	50                   	push   %eax
80108590:	68 40 bf 10 80       	push   $0x8010bf40
80108595:	e8 5a 7e ff ff       	call   801003f4 <cprintf>
8010859a:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
8010859d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085a0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
801085a6:	90                   	nop
801085a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801085aa:	c9                   	leave  
801085ab:	c3                   	ret    

801085ac <i8254_init_recv>:

void i8254_init_recv(){
801085ac:	55                   	push   %ebp
801085ad:	89 e5                	mov    %esp,%ebp
801085af:	57                   	push   %edi
801085b0:	56                   	push   %esi
801085b1:	53                   	push   %ebx
801085b2:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
801085b5:	83 ec 0c             	sub    $0xc,%esp
801085b8:	6a 00                	push   $0x0
801085ba:	e8 e8 04 00 00       	call   80108aa7 <i8254_read_eeprom>
801085bf:	83 c4 10             	add    $0x10,%esp
801085c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
801085c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
801085c8:	a2 80 6c 19 80       	mov    %al,0x80196c80
  mac_addr[1] = data_l>>8;
801085cd:	8b 45 d8             	mov    -0x28(%ebp),%eax
801085d0:	c1 e8 08             	shr    $0x8,%eax
801085d3:	a2 81 6c 19 80       	mov    %al,0x80196c81
  uint data_m = i8254_read_eeprom(0x1);
801085d8:	83 ec 0c             	sub    $0xc,%esp
801085db:	6a 01                	push   $0x1
801085dd:	e8 c5 04 00 00       	call   80108aa7 <i8254_read_eeprom>
801085e2:	83 c4 10             	add    $0x10,%esp
801085e5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
801085e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801085eb:	a2 82 6c 19 80       	mov    %al,0x80196c82
  mac_addr[3] = data_m>>8;
801085f0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801085f3:	c1 e8 08             	shr    $0x8,%eax
801085f6:	a2 83 6c 19 80       	mov    %al,0x80196c83
  uint data_h = i8254_read_eeprom(0x2);
801085fb:	83 ec 0c             	sub    $0xc,%esp
801085fe:	6a 02                	push   $0x2
80108600:	e8 a2 04 00 00       	call   80108aa7 <i8254_read_eeprom>
80108605:	83 c4 10             	add    $0x10,%esp
80108608:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
8010860b:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010860e:	a2 84 6c 19 80       	mov    %al,0x80196c84
  mac_addr[5] = data_h>>8;
80108613:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108616:	c1 e8 08             	shr    $0x8,%eax
80108619:	a2 85 6c 19 80       	mov    %al,0x80196c85
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
8010861e:	0f b6 05 85 6c 19 80 	movzbl 0x80196c85,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108625:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108628:	0f b6 05 84 6c 19 80 	movzbl 0x80196c84,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010862f:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108632:	0f b6 05 83 6c 19 80 	movzbl 0x80196c83,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108639:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
8010863c:	0f b6 05 82 6c 19 80 	movzbl 0x80196c82,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108643:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108646:	0f b6 05 81 6c 19 80 	movzbl 0x80196c81,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010864d:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108650:	0f b6 05 80 6c 19 80 	movzbl 0x80196c80,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108657:	0f b6 c0             	movzbl %al,%eax
8010865a:	83 ec 04             	sub    $0x4,%esp
8010865d:	57                   	push   %edi
8010865e:	56                   	push   %esi
8010865f:	53                   	push   %ebx
80108660:	51                   	push   %ecx
80108661:	52                   	push   %edx
80108662:	50                   	push   %eax
80108663:	68 58 bf 10 80       	push   $0x8010bf58
80108668:	e8 87 7d ff ff       	call   801003f4 <cprintf>
8010866d:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108670:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108675:	05 00 54 00 00       	add    $0x5400,%eax
8010867a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
8010867d:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108682:	05 04 54 00 00       	add    $0x5404,%eax
80108687:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
8010868a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010868d:	c1 e0 10             	shl    $0x10,%eax
80108690:	0b 45 d8             	or     -0x28(%ebp),%eax
80108693:	89 c2                	mov    %eax,%edx
80108695:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108698:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
8010869a:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010869d:	0d 00 00 00 80       	or     $0x80000000,%eax
801086a2:	89 c2                	mov    %eax,%edx
801086a4:	8b 45 c8             	mov    -0x38(%ebp),%eax
801086a7:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
801086a9:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801086ae:	05 00 52 00 00       	add    $0x5200,%eax
801086b3:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
801086b6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801086bd:	eb 19                	jmp    801086d8 <i8254_init_recv+0x12c>
    mta[i] = 0;
801086bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801086c2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801086c9:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801086cc:	01 d0                	add    %edx,%eax
801086ce:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
801086d4:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801086d8:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
801086dc:	7e e1                	jle    801086bf <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
801086de:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801086e3:	05 d0 00 00 00       	add    $0xd0,%eax
801086e8:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
801086eb:	8b 45 c0             	mov    -0x40(%ebp),%eax
801086ee:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
801086f4:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801086f9:	05 c8 00 00 00       	add    $0xc8,%eax
801086fe:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108701:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108704:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
8010870a:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
8010870f:	05 28 28 00 00       	add    $0x2828,%eax
80108714:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108717:	8b 45 b8             	mov    -0x48(%ebp),%eax
8010871a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108720:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108725:	05 00 01 00 00       	add    $0x100,%eax
8010872a:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
8010872d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108730:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108736:	e8 58 a0 ff ff       	call   80102793 <kalloc>
8010873b:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
8010873e:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108743:	05 00 28 00 00       	add    $0x2800,%eax
80108748:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
8010874b:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108750:	05 04 28 00 00       	add    $0x2804,%eax
80108755:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108758:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
8010875d:	05 08 28 00 00       	add    $0x2808,%eax
80108762:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108765:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
8010876a:	05 10 28 00 00       	add    $0x2810,%eax
8010876f:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108772:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108777:	05 18 28 00 00       	add    $0x2818,%eax
8010877c:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
8010877f:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108782:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108788:	8b 45 ac             	mov    -0x54(%ebp),%eax
8010878b:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
8010878d:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108790:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108796:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108799:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
8010879f:	8b 45 a0             	mov    -0x60(%ebp),%eax
801087a2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
801087a8:	8b 45 9c             	mov    -0x64(%ebp),%eax
801087ab:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
801087b1:	8b 45 b0             	mov    -0x50(%ebp),%eax
801087b4:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
801087b7:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801087be:	eb 73                	jmp    80108833 <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
801087c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801087c3:	c1 e0 04             	shl    $0x4,%eax
801087c6:	89 c2                	mov    %eax,%edx
801087c8:	8b 45 98             	mov    -0x68(%ebp),%eax
801087cb:	01 d0                	add    %edx,%eax
801087cd:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
801087d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801087d7:	c1 e0 04             	shl    $0x4,%eax
801087da:	89 c2                	mov    %eax,%edx
801087dc:	8b 45 98             	mov    -0x68(%ebp),%eax
801087df:	01 d0                	add    %edx,%eax
801087e1:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
801087e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801087ea:	c1 e0 04             	shl    $0x4,%eax
801087ed:	89 c2                	mov    %eax,%edx
801087ef:	8b 45 98             	mov    -0x68(%ebp),%eax
801087f2:	01 d0                	add    %edx,%eax
801087f4:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
801087fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
801087fd:	c1 e0 04             	shl    $0x4,%eax
80108800:	89 c2                	mov    %eax,%edx
80108802:	8b 45 98             	mov    -0x68(%ebp),%eax
80108805:	01 d0                	add    %edx,%eax
80108807:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
8010880b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010880e:	c1 e0 04             	shl    $0x4,%eax
80108811:	89 c2                	mov    %eax,%edx
80108813:	8b 45 98             	mov    -0x68(%ebp),%eax
80108816:	01 d0                	add    %edx,%eax
80108818:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
8010881c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010881f:	c1 e0 04             	shl    $0x4,%eax
80108822:	89 c2                	mov    %eax,%edx
80108824:	8b 45 98             	mov    -0x68(%ebp),%eax
80108827:	01 d0                	add    %edx,%eax
80108829:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
8010882f:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108833:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
8010883a:	7e 84                	jle    801087c0 <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
8010883c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108843:	eb 57                	jmp    8010889c <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
80108845:	e8 49 9f ff ff       	call   80102793 <kalloc>
8010884a:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
8010884d:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108851:	75 12                	jne    80108865 <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80108853:	83 ec 0c             	sub    $0xc,%esp
80108856:	68 78 bf 10 80       	push   $0x8010bf78
8010885b:	e8 94 7b ff ff       	call   801003f4 <cprintf>
80108860:	83 c4 10             	add    $0x10,%esp
      break;
80108863:	eb 3d                	jmp    801088a2 <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108865:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108868:	c1 e0 04             	shl    $0x4,%eax
8010886b:	89 c2                	mov    %eax,%edx
8010886d:	8b 45 98             	mov    -0x68(%ebp),%eax
80108870:	01 d0                	add    %edx,%eax
80108872:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108875:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010887b:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
8010887d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108880:	83 c0 01             	add    $0x1,%eax
80108883:	c1 e0 04             	shl    $0x4,%eax
80108886:	89 c2                	mov    %eax,%edx
80108888:	8b 45 98             	mov    -0x68(%ebp),%eax
8010888b:	01 d0                	add    %edx,%eax
8010888d:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108890:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108896:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108898:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
8010889c:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
801088a0:	7e a3                	jle    80108845 <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
801088a2:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801088a5:	8b 00                	mov    (%eax),%eax
801088a7:	83 c8 02             	or     $0x2,%eax
801088aa:	89 c2                	mov    %eax,%edx
801088ac:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801088af:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
801088b1:	83 ec 0c             	sub    $0xc,%esp
801088b4:	68 98 bf 10 80       	push   $0x8010bf98
801088b9:	e8 36 7b ff ff       	call   801003f4 <cprintf>
801088be:	83 c4 10             	add    $0x10,%esp
}
801088c1:	90                   	nop
801088c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801088c5:	5b                   	pop    %ebx
801088c6:	5e                   	pop    %esi
801088c7:	5f                   	pop    %edi
801088c8:	5d                   	pop    %ebp
801088c9:	c3                   	ret    

801088ca <i8254_init_send>:

void i8254_init_send(){
801088ca:	55                   	push   %ebp
801088cb:	89 e5                	mov    %esp,%ebp
801088cd:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
801088d0:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801088d5:	05 28 38 00 00       	add    $0x3828,%eax
801088da:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
801088dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088e0:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
801088e6:	e8 a8 9e ff ff       	call   80102793 <kalloc>
801088eb:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
801088ee:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801088f3:	05 00 38 00 00       	add    $0x3800,%eax
801088f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
801088fb:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108900:	05 04 38 00 00       	add    $0x3804,%eax
80108905:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108908:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
8010890d:	05 08 38 00 00       	add    $0x3808,%eax
80108912:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108915:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108918:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010891e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108921:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108923:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108926:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
8010892c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010892f:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108935:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
8010893a:	05 10 38 00 00       	add    $0x3810,%eax
8010893f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108942:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108947:	05 18 38 00 00       	add    $0x3818,%eax
8010894c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
8010894f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108952:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108958:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010895b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108961:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108964:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108967:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010896e:	e9 82 00 00 00       	jmp    801089f5 <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80108973:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108976:	c1 e0 04             	shl    $0x4,%eax
80108979:	89 c2                	mov    %eax,%edx
8010897b:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010897e:	01 d0                	add    %edx,%eax
80108980:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108987:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010898a:	c1 e0 04             	shl    $0x4,%eax
8010898d:	89 c2                	mov    %eax,%edx
8010898f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108992:	01 d0                	add    %edx,%eax
80108994:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
8010899a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010899d:	c1 e0 04             	shl    $0x4,%eax
801089a0:	89 c2                	mov    %eax,%edx
801089a2:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089a5:	01 d0                	add    %edx,%eax
801089a7:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
801089ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ae:	c1 e0 04             	shl    $0x4,%eax
801089b1:	89 c2                	mov    %eax,%edx
801089b3:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089b6:	01 d0                	add    %edx,%eax
801089b8:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
801089bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089bf:	c1 e0 04             	shl    $0x4,%eax
801089c2:	89 c2                	mov    %eax,%edx
801089c4:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089c7:	01 d0                	add    %edx,%eax
801089c9:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
801089cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089d0:	c1 e0 04             	shl    $0x4,%eax
801089d3:	89 c2                	mov    %eax,%edx
801089d5:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089d8:	01 d0                	add    %edx,%eax
801089da:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
801089de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089e1:	c1 e0 04             	shl    $0x4,%eax
801089e4:	89 c2                	mov    %eax,%edx
801089e6:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089e9:	01 d0                	add    %edx,%eax
801089eb:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
801089f1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801089f5:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801089fc:	0f 8e 71 ff ff ff    	jle    80108973 <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108a02:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108a09:	eb 57                	jmp    80108a62 <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
80108a0b:	e8 83 9d ff ff       	call   80102793 <kalloc>
80108a10:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108a13:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108a17:	75 12                	jne    80108a2b <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
80108a19:	83 ec 0c             	sub    $0xc,%esp
80108a1c:	68 78 bf 10 80       	push   $0x8010bf78
80108a21:	e8 ce 79 ff ff       	call   801003f4 <cprintf>
80108a26:	83 c4 10             	add    $0x10,%esp
      break;
80108a29:	eb 3d                	jmp    80108a68 <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108a2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a2e:	c1 e0 04             	shl    $0x4,%eax
80108a31:	89 c2                	mov    %eax,%edx
80108a33:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a36:	01 d0                	add    %edx,%eax
80108a38:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108a3b:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108a41:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108a43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a46:	83 c0 01             	add    $0x1,%eax
80108a49:	c1 e0 04             	shl    $0x4,%eax
80108a4c:	89 c2                	mov    %eax,%edx
80108a4e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a51:	01 d0                	add    %edx,%eax
80108a53:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108a56:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108a5c:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108a5e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108a62:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108a66:	7e a3                	jle    80108a0b <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108a68:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108a6d:	05 00 04 00 00       	add    $0x400,%eax
80108a72:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108a75:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108a78:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108a7e:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108a83:	05 10 04 00 00       	add    $0x410,%eax
80108a88:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108a8b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108a8e:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108a94:	83 ec 0c             	sub    $0xc,%esp
80108a97:	68 b8 bf 10 80       	push   $0x8010bfb8
80108a9c:	e8 53 79 ff ff       	call   801003f4 <cprintf>
80108aa1:	83 c4 10             	add    $0x10,%esp

}
80108aa4:	90                   	nop
80108aa5:	c9                   	leave  
80108aa6:	c3                   	ret    

80108aa7 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108aa7:	55                   	push   %ebp
80108aa8:	89 e5                	mov    %esp,%ebp
80108aaa:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80108aad:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108ab2:	83 c0 14             	add    $0x14,%eax
80108ab5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108ab8:	8b 45 08             	mov    0x8(%ebp),%eax
80108abb:	c1 e0 08             	shl    $0x8,%eax
80108abe:	0f b7 c0             	movzwl %ax,%eax
80108ac1:	83 c8 01             	or     $0x1,%eax
80108ac4:	89 c2                	mov    %eax,%edx
80108ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ac9:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108acb:	83 ec 0c             	sub    $0xc,%esp
80108ace:	68 d8 bf 10 80       	push   $0x8010bfd8
80108ad3:	e8 1c 79 ff ff       	call   801003f4 <cprintf>
80108ad8:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80108adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ade:	8b 00                	mov    (%eax),%eax
80108ae0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80108ae3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ae6:	83 e0 10             	and    $0x10,%eax
80108ae9:	85 c0                	test   %eax,%eax
80108aeb:	75 02                	jne    80108aef <i8254_read_eeprom+0x48>
  while(1){
80108aed:	eb dc                	jmp    80108acb <i8254_read_eeprom+0x24>
      break;
80108aef:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80108af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108af3:	8b 00                	mov    (%eax),%eax
80108af5:	c1 e8 10             	shr    $0x10,%eax
}
80108af8:	c9                   	leave  
80108af9:	c3                   	ret    

80108afa <i8254_recv>:
void i8254_recv(){
80108afa:	55                   	push   %ebp
80108afb:	89 e5                	mov    %esp,%ebp
80108afd:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108b00:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108b05:	05 10 28 00 00       	add    $0x2810,%eax
80108b0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108b0d:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108b12:	05 18 28 00 00       	add    $0x2818,%eax
80108b17:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108b1a:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108b1f:	05 00 28 00 00       	add    $0x2800,%eax
80108b24:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108b27:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b2a:	8b 00                	mov    (%eax),%eax
80108b2c:	05 00 00 00 80       	add    $0x80000000,%eax
80108b31:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108b34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b37:	8b 10                	mov    (%eax),%edx
80108b39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b3c:	8b 08                	mov    (%eax),%ecx
80108b3e:	89 d0                	mov    %edx,%eax
80108b40:	29 c8                	sub    %ecx,%eax
80108b42:	25 ff 00 00 00       	and    $0xff,%eax
80108b47:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80108b4a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108b4e:	7e 37                	jle    80108b87 <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80108b50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b53:	8b 00                	mov    (%eax),%eax
80108b55:	c1 e0 04             	shl    $0x4,%eax
80108b58:	89 c2                	mov    %eax,%edx
80108b5a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b5d:	01 d0                	add    %edx,%eax
80108b5f:	8b 00                	mov    (%eax),%eax
80108b61:	05 00 00 00 80       	add    $0x80000000,%eax
80108b66:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80108b69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b6c:	8b 00                	mov    (%eax),%eax
80108b6e:	83 c0 01             	add    $0x1,%eax
80108b71:	0f b6 d0             	movzbl %al,%edx
80108b74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b77:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80108b79:	83 ec 0c             	sub    $0xc,%esp
80108b7c:	ff 75 e0             	push   -0x20(%ebp)
80108b7f:	e8 15 09 00 00       	call   80109499 <eth_proc>
80108b84:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80108b87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b8a:	8b 10                	mov    (%eax),%edx
80108b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b8f:	8b 00                	mov    (%eax),%eax
80108b91:	39 c2                	cmp    %eax,%edx
80108b93:	75 9f                	jne    80108b34 <i8254_recv+0x3a>
      (*rdt)--;
80108b95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b98:	8b 00                	mov    (%eax),%eax
80108b9a:	8d 50 ff             	lea    -0x1(%eax),%edx
80108b9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ba0:	89 10                	mov    %edx,(%eax)
  while(1){
80108ba2:	eb 90                	jmp    80108b34 <i8254_recv+0x3a>

80108ba4 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80108ba4:	55                   	push   %ebp
80108ba5:	89 e5                	mov    %esp,%ebp
80108ba7:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80108baa:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108baf:	05 10 38 00 00       	add    $0x3810,%eax
80108bb4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108bb7:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108bbc:	05 18 38 00 00       	add    $0x3818,%eax
80108bc1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108bc4:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108bc9:	05 00 38 00 00       	add    $0x3800,%eax
80108bce:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80108bd1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bd4:	8b 00                	mov    (%eax),%eax
80108bd6:	05 00 00 00 80       	add    $0x80000000,%eax
80108bdb:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80108bde:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108be1:	8b 10                	mov    (%eax),%edx
80108be3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108be6:	8b 08                	mov    (%eax),%ecx
80108be8:	89 d0                	mov    %edx,%eax
80108bea:	29 c8                	sub    %ecx,%eax
80108bec:	0f b6 d0             	movzbl %al,%edx
80108bef:	b8 00 01 00 00       	mov    $0x100,%eax
80108bf4:	29 d0                	sub    %edx,%eax
80108bf6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80108bf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bfc:	8b 00                	mov    (%eax),%eax
80108bfe:	25 ff 00 00 00       	and    $0xff,%eax
80108c03:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80108c06:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108c0a:	0f 8e a8 00 00 00    	jle    80108cb8 <i8254_send+0x114>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80108c10:	8b 45 08             	mov    0x8(%ebp),%eax
80108c13:	8b 55 e0             	mov    -0x20(%ebp),%edx
80108c16:	89 d1                	mov    %edx,%ecx
80108c18:	c1 e1 04             	shl    $0x4,%ecx
80108c1b:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108c1e:	01 ca                	add    %ecx,%edx
80108c20:	8b 12                	mov    (%edx),%edx
80108c22:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108c28:	83 ec 04             	sub    $0x4,%esp
80108c2b:	ff 75 0c             	push   0xc(%ebp)
80108c2e:	50                   	push   %eax
80108c2f:	52                   	push   %edx
80108c30:	e8 5f bf ff ff       	call   80104b94 <memmove>
80108c35:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80108c38:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c3b:	c1 e0 04             	shl    $0x4,%eax
80108c3e:	89 c2                	mov    %eax,%edx
80108c40:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c43:	01 d0                	add    %edx,%eax
80108c45:	8b 55 0c             	mov    0xc(%ebp),%edx
80108c48:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80108c4c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c4f:	c1 e0 04             	shl    $0x4,%eax
80108c52:	89 c2                	mov    %eax,%edx
80108c54:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c57:	01 d0                	add    %edx,%eax
80108c59:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80108c5d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c60:	c1 e0 04             	shl    $0x4,%eax
80108c63:	89 c2                	mov    %eax,%edx
80108c65:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c68:	01 d0                	add    %edx,%eax
80108c6a:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80108c6e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c71:	c1 e0 04             	shl    $0x4,%eax
80108c74:	89 c2                	mov    %eax,%edx
80108c76:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c79:	01 d0                	add    %edx,%eax
80108c7b:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80108c7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c82:	c1 e0 04             	shl    $0x4,%eax
80108c85:	89 c2                	mov    %eax,%edx
80108c87:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c8a:	01 d0                	add    %edx,%eax
80108c8c:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80108c92:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c95:	c1 e0 04             	shl    $0x4,%eax
80108c98:	89 c2                	mov    %eax,%edx
80108c9a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c9d:	01 d0                	add    %edx,%eax
80108c9f:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80108ca3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ca6:	8b 00                	mov    (%eax),%eax
80108ca8:	83 c0 01             	add    $0x1,%eax
80108cab:	0f b6 d0             	movzbl %al,%edx
80108cae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cb1:	89 10                	mov    %edx,(%eax)
    return len;
80108cb3:	8b 45 0c             	mov    0xc(%ebp),%eax
80108cb6:	eb 05                	jmp    80108cbd <i8254_send+0x119>
  }else{
    return -1;
80108cb8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80108cbd:	c9                   	leave  
80108cbe:	c3                   	ret    

80108cbf <i8254_intr>:

void i8254_intr(){
80108cbf:	55                   	push   %ebp
80108cc0:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80108cc2:	a1 88 6c 19 80       	mov    0x80196c88,%eax
80108cc7:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80108ccd:	90                   	nop
80108cce:	5d                   	pop    %ebp
80108ccf:	c3                   	ret    

80108cd0 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80108cd0:	55                   	push   %ebp
80108cd1:	89 e5                	mov    %esp,%ebp
80108cd3:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80108cd6:	8b 45 08             	mov    0x8(%ebp),%eax
80108cd9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80108cdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cdf:	0f b7 00             	movzwl (%eax),%eax
80108ce2:	66 3d 00 01          	cmp    $0x100,%ax
80108ce6:	74 0a                	je     80108cf2 <arp_proc+0x22>
80108ce8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108ced:	e9 4f 01 00 00       	jmp    80108e41 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80108cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cf5:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80108cf9:	66 83 f8 08          	cmp    $0x8,%ax
80108cfd:	74 0a                	je     80108d09 <arp_proc+0x39>
80108cff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d04:	e9 38 01 00 00       	jmp    80108e41 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
80108d09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d0c:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80108d10:	3c 06                	cmp    $0x6,%al
80108d12:	74 0a                	je     80108d1e <arp_proc+0x4e>
80108d14:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d19:	e9 23 01 00 00       	jmp    80108e41 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80108d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d21:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80108d25:	3c 04                	cmp    $0x4,%al
80108d27:	74 0a                	je     80108d33 <arp_proc+0x63>
80108d29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d2e:	e9 0e 01 00 00       	jmp    80108e41 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80108d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d36:	83 c0 18             	add    $0x18,%eax
80108d39:	83 ec 04             	sub    $0x4,%esp
80108d3c:	6a 04                	push   $0x4
80108d3e:	50                   	push   %eax
80108d3f:	68 e4 f4 10 80       	push   $0x8010f4e4
80108d44:	e8 f3 bd ff ff       	call   80104b3c <memcmp>
80108d49:	83 c4 10             	add    $0x10,%esp
80108d4c:	85 c0                	test   %eax,%eax
80108d4e:	74 27                	je     80108d77 <arp_proc+0xa7>
80108d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d53:	83 c0 0e             	add    $0xe,%eax
80108d56:	83 ec 04             	sub    $0x4,%esp
80108d59:	6a 04                	push   $0x4
80108d5b:	50                   	push   %eax
80108d5c:	68 e4 f4 10 80       	push   $0x8010f4e4
80108d61:	e8 d6 bd ff ff       	call   80104b3c <memcmp>
80108d66:	83 c4 10             	add    $0x10,%esp
80108d69:	85 c0                	test   %eax,%eax
80108d6b:	74 0a                	je     80108d77 <arp_proc+0xa7>
80108d6d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d72:	e9 ca 00 00 00       	jmp    80108e41 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108d77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d7a:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108d7e:	66 3d 00 01          	cmp    $0x100,%ax
80108d82:	75 69                	jne    80108ded <arp_proc+0x11d>
80108d84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d87:	83 c0 18             	add    $0x18,%eax
80108d8a:	83 ec 04             	sub    $0x4,%esp
80108d8d:	6a 04                	push   $0x4
80108d8f:	50                   	push   %eax
80108d90:	68 e4 f4 10 80       	push   $0x8010f4e4
80108d95:	e8 a2 bd ff ff       	call   80104b3c <memcmp>
80108d9a:	83 c4 10             	add    $0x10,%esp
80108d9d:	85 c0                	test   %eax,%eax
80108d9f:	75 4c                	jne    80108ded <arp_proc+0x11d>
    uint send = (uint)kalloc();
80108da1:	e8 ed 99 ff ff       	call   80102793 <kalloc>
80108da6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80108da9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80108db0:	83 ec 04             	sub    $0x4,%esp
80108db3:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108db6:	50                   	push   %eax
80108db7:	ff 75 f0             	push   -0x10(%ebp)
80108dba:	ff 75 f4             	push   -0xc(%ebp)
80108dbd:	e8 1f 04 00 00       	call   801091e1 <arp_reply_pkt_create>
80108dc2:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80108dc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108dc8:	83 ec 08             	sub    $0x8,%esp
80108dcb:	50                   	push   %eax
80108dcc:	ff 75 f0             	push   -0x10(%ebp)
80108dcf:	e8 d0 fd ff ff       	call   80108ba4 <i8254_send>
80108dd4:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
80108dd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108dda:	83 ec 0c             	sub    $0xc,%esp
80108ddd:	50                   	push   %eax
80108dde:	e8 16 99 ff ff       	call   801026f9 <kfree>
80108de3:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
80108de6:	b8 02 00 00 00       	mov    $0x2,%eax
80108deb:	eb 54                	jmp    80108e41 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108ded:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108df0:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108df4:	66 3d 00 02          	cmp    $0x200,%ax
80108df8:	75 42                	jne    80108e3c <arp_proc+0x16c>
80108dfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dfd:	83 c0 18             	add    $0x18,%eax
80108e00:	83 ec 04             	sub    $0x4,%esp
80108e03:	6a 04                	push   $0x4
80108e05:	50                   	push   %eax
80108e06:	68 e4 f4 10 80       	push   $0x8010f4e4
80108e0b:	e8 2c bd ff ff       	call   80104b3c <memcmp>
80108e10:	83 c4 10             	add    $0x10,%esp
80108e13:	85 c0                	test   %eax,%eax
80108e15:	75 25                	jne    80108e3c <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
80108e17:	83 ec 0c             	sub    $0xc,%esp
80108e1a:	68 dc bf 10 80       	push   $0x8010bfdc
80108e1f:	e8 d0 75 ff ff       	call   801003f4 <cprintf>
80108e24:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
80108e27:	83 ec 0c             	sub    $0xc,%esp
80108e2a:	ff 75 f4             	push   -0xc(%ebp)
80108e2d:	e8 af 01 00 00       	call   80108fe1 <arp_table_update>
80108e32:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80108e35:	b8 01 00 00 00       	mov    $0x1,%eax
80108e3a:	eb 05                	jmp    80108e41 <arp_proc+0x171>
  }else{
    return -1;
80108e3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80108e41:	c9                   	leave  
80108e42:	c3                   	ret    

80108e43 <arp_scan>:

void arp_scan(){
80108e43:	55                   	push   %ebp
80108e44:	89 e5                	mov    %esp,%ebp
80108e46:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80108e49:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108e50:	eb 6f                	jmp    80108ec1 <arp_scan+0x7e>
    uint send = (uint)kalloc();
80108e52:	e8 3c 99 ff ff       	call   80102793 <kalloc>
80108e57:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80108e5a:	83 ec 04             	sub    $0x4,%esp
80108e5d:	ff 75 f4             	push   -0xc(%ebp)
80108e60:	8d 45 e8             	lea    -0x18(%ebp),%eax
80108e63:	50                   	push   %eax
80108e64:	ff 75 ec             	push   -0x14(%ebp)
80108e67:	e8 62 00 00 00       	call   80108ece <arp_broadcast>
80108e6c:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80108e6f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e72:	83 ec 08             	sub    $0x8,%esp
80108e75:	50                   	push   %eax
80108e76:	ff 75 ec             	push   -0x14(%ebp)
80108e79:	e8 26 fd ff ff       	call   80108ba4 <i8254_send>
80108e7e:	83 c4 10             	add    $0x10,%esp
80108e81:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80108e84:	eb 22                	jmp    80108ea8 <arp_scan+0x65>
      microdelay(1);
80108e86:	83 ec 0c             	sub    $0xc,%esp
80108e89:	6a 01                	push   $0x1
80108e8b:	e8 9a 9c ff ff       	call   80102b2a <microdelay>
80108e90:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80108e93:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e96:	83 ec 08             	sub    $0x8,%esp
80108e99:	50                   	push   %eax
80108e9a:	ff 75 ec             	push   -0x14(%ebp)
80108e9d:	e8 02 fd ff ff       	call   80108ba4 <i8254_send>
80108ea2:	83 c4 10             	add    $0x10,%esp
80108ea5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80108ea8:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80108eac:	74 d8                	je     80108e86 <arp_scan+0x43>
    }
    kfree((char *)send);
80108eae:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108eb1:	83 ec 0c             	sub    $0xc,%esp
80108eb4:	50                   	push   %eax
80108eb5:	e8 3f 98 ff ff       	call   801026f9 <kfree>
80108eba:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80108ebd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108ec1:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108ec8:	7e 88                	jle    80108e52 <arp_scan+0xf>
  }
}
80108eca:	90                   	nop
80108ecb:	90                   	nop
80108ecc:	c9                   	leave  
80108ecd:	c3                   	ret    

80108ece <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80108ece:	55                   	push   %ebp
80108ecf:	89 e5                	mov    %esp,%ebp
80108ed1:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80108ed4:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
80108ed8:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80108edc:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80108ee0:	8b 45 10             	mov    0x10(%ebp),%eax
80108ee3:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80108ee6:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80108eed:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80108ef3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108efa:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80108f00:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f03:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80108f09:	8b 45 08             	mov    0x8(%ebp),%eax
80108f0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80108f0f:	8b 45 08             	mov    0x8(%ebp),%eax
80108f12:	83 c0 0e             	add    $0xe,%eax
80108f15:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80108f18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f1b:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80108f1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f22:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80108f26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f29:	83 ec 04             	sub    $0x4,%esp
80108f2c:	6a 06                	push   $0x6
80108f2e:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80108f31:	52                   	push   %edx
80108f32:	50                   	push   %eax
80108f33:	e8 5c bc ff ff       	call   80104b94 <memmove>
80108f38:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80108f3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f3e:	83 c0 06             	add    $0x6,%eax
80108f41:	83 ec 04             	sub    $0x4,%esp
80108f44:	6a 06                	push   $0x6
80108f46:	68 80 6c 19 80       	push   $0x80196c80
80108f4b:	50                   	push   %eax
80108f4c:	e8 43 bc ff ff       	call   80104b94 <memmove>
80108f51:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80108f54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f57:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80108f5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f5f:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80108f65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f68:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80108f6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f6f:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80108f73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f76:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80108f7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f7f:	8d 50 12             	lea    0x12(%eax),%edx
80108f82:	83 ec 04             	sub    $0x4,%esp
80108f85:	6a 06                	push   $0x6
80108f87:	8d 45 e0             	lea    -0x20(%ebp),%eax
80108f8a:	50                   	push   %eax
80108f8b:	52                   	push   %edx
80108f8c:	e8 03 bc ff ff       	call   80104b94 <memmove>
80108f91:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80108f94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f97:	8d 50 18             	lea    0x18(%eax),%edx
80108f9a:	83 ec 04             	sub    $0x4,%esp
80108f9d:	6a 04                	push   $0x4
80108f9f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108fa2:	50                   	push   %eax
80108fa3:	52                   	push   %edx
80108fa4:	e8 eb bb ff ff       	call   80104b94 <memmove>
80108fa9:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80108fac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108faf:	83 c0 08             	add    $0x8,%eax
80108fb2:	83 ec 04             	sub    $0x4,%esp
80108fb5:	6a 06                	push   $0x6
80108fb7:	68 80 6c 19 80       	push   $0x80196c80
80108fbc:	50                   	push   %eax
80108fbd:	e8 d2 bb ff ff       	call   80104b94 <memmove>
80108fc2:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80108fc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fc8:	83 c0 0e             	add    $0xe,%eax
80108fcb:	83 ec 04             	sub    $0x4,%esp
80108fce:	6a 04                	push   $0x4
80108fd0:	68 e4 f4 10 80       	push   $0x8010f4e4
80108fd5:	50                   	push   %eax
80108fd6:	e8 b9 bb ff ff       	call   80104b94 <memmove>
80108fdb:	83 c4 10             	add    $0x10,%esp
}
80108fde:	90                   	nop
80108fdf:	c9                   	leave  
80108fe0:	c3                   	ret    

80108fe1 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80108fe1:	55                   	push   %ebp
80108fe2:	89 e5                	mov    %esp,%ebp
80108fe4:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80108fe7:	8b 45 08             	mov    0x8(%ebp),%eax
80108fea:	83 c0 0e             	add    $0xe,%eax
80108fed:	83 ec 0c             	sub    $0xc,%esp
80108ff0:	50                   	push   %eax
80108ff1:	e8 bc 00 00 00       	call   801090b2 <arp_table_search>
80108ff6:	83 c4 10             	add    $0x10,%esp
80108ff9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80108ffc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109000:	78 2d                	js     8010902f <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109002:	8b 45 08             	mov    0x8(%ebp),%eax
80109005:	8d 48 08             	lea    0x8(%eax),%ecx
80109008:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010900b:	89 d0                	mov    %edx,%eax
8010900d:	c1 e0 02             	shl    $0x2,%eax
80109010:	01 d0                	add    %edx,%eax
80109012:	01 c0                	add    %eax,%eax
80109014:	01 d0                	add    %edx,%eax
80109016:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
8010901b:	83 c0 04             	add    $0x4,%eax
8010901e:	83 ec 04             	sub    $0x4,%esp
80109021:	6a 06                	push   $0x6
80109023:	51                   	push   %ecx
80109024:	50                   	push   %eax
80109025:	e8 6a bb ff ff       	call   80104b94 <memmove>
8010902a:	83 c4 10             	add    $0x10,%esp
8010902d:	eb 70                	jmp    8010909f <arp_table_update+0xbe>
  }else{
    index += 1;
8010902f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109033:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109036:	8b 45 08             	mov    0x8(%ebp),%eax
80109039:	8d 48 08             	lea    0x8(%eax),%ecx
8010903c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010903f:	89 d0                	mov    %edx,%eax
80109041:	c1 e0 02             	shl    $0x2,%eax
80109044:	01 d0                	add    %edx,%eax
80109046:	01 c0                	add    %eax,%eax
80109048:	01 d0                	add    %edx,%eax
8010904a:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
8010904f:	83 c0 04             	add    $0x4,%eax
80109052:	83 ec 04             	sub    $0x4,%esp
80109055:	6a 06                	push   $0x6
80109057:	51                   	push   %ecx
80109058:	50                   	push   %eax
80109059:	e8 36 bb ff ff       	call   80104b94 <memmove>
8010905e:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109061:	8b 45 08             	mov    0x8(%ebp),%eax
80109064:	8d 48 0e             	lea    0xe(%eax),%ecx
80109067:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010906a:	89 d0                	mov    %edx,%eax
8010906c:	c1 e0 02             	shl    $0x2,%eax
8010906f:	01 d0                	add    %edx,%eax
80109071:	01 c0                	add    %eax,%eax
80109073:	01 d0                	add    %edx,%eax
80109075:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
8010907a:	83 ec 04             	sub    $0x4,%esp
8010907d:	6a 04                	push   $0x4
8010907f:	51                   	push   %ecx
80109080:	50                   	push   %eax
80109081:	e8 0e bb ff ff       	call   80104b94 <memmove>
80109086:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80109089:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010908c:	89 d0                	mov    %edx,%eax
8010908e:	c1 e0 02             	shl    $0x2,%eax
80109091:	01 d0                	add    %edx,%eax
80109093:	01 c0                	add    %eax,%eax
80109095:	01 d0                	add    %edx,%eax
80109097:	05 aa 6c 19 80       	add    $0x80196caa,%eax
8010909c:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
8010909f:	83 ec 0c             	sub    $0xc,%esp
801090a2:	68 a0 6c 19 80       	push   $0x80196ca0
801090a7:	e8 83 00 00 00       	call   8010912f <print_arp_table>
801090ac:	83 c4 10             	add    $0x10,%esp
}
801090af:	90                   	nop
801090b0:	c9                   	leave  
801090b1:	c3                   	ret    

801090b2 <arp_table_search>:

int arp_table_search(uchar *ip){
801090b2:	55                   	push   %ebp
801090b3:	89 e5                	mov    %esp,%ebp
801090b5:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
801090b8:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801090bf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801090c6:	eb 59                	jmp    80109121 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
801090c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801090cb:	89 d0                	mov    %edx,%eax
801090cd:	c1 e0 02             	shl    $0x2,%eax
801090d0:	01 d0                	add    %edx,%eax
801090d2:	01 c0                	add    %eax,%eax
801090d4:	01 d0                	add    %edx,%eax
801090d6:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
801090db:	83 ec 04             	sub    $0x4,%esp
801090de:	6a 04                	push   $0x4
801090e0:	ff 75 08             	push   0x8(%ebp)
801090e3:	50                   	push   %eax
801090e4:	e8 53 ba ff ff       	call   80104b3c <memcmp>
801090e9:	83 c4 10             	add    $0x10,%esp
801090ec:	85 c0                	test   %eax,%eax
801090ee:	75 05                	jne    801090f5 <arp_table_search+0x43>
      return i;
801090f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090f3:	eb 38                	jmp    8010912d <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
801090f5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801090f8:	89 d0                	mov    %edx,%eax
801090fa:	c1 e0 02             	shl    $0x2,%eax
801090fd:	01 d0                	add    %edx,%eax
801090ff:	01 c0                	add    %eax,%eax
80109101:	01 d0                	add    %edx,%eax
80109103:	05 aa 6c 19 80       	add    $0x80196caa,%eax
80109108:	0f b6 00             	movzbl (%eax),%eax
8010910b:	84 c0                	test   %al,%al
8010910d:	75 0e                	jne    8010911d <arp_table_search+0x6b>
8010910f:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109113:	75 08                	jne    8010911d <arp_table_search+0x6b>
      empty = -i;
80109115:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109118:	f7 d8                	neg    %eax
8010911a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
8010911d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109121:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80109125:	7e a1                	jle    801090c8 <arp_table_search+0x16>
    }
  }
  return empty-1;
80109127:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010912a:	83 e8 01             	sub    $0x1,%eax
}
8010912d:	c9                   	leave  
8010912e:	c3                   	ret    

8010912f <print_arp_table>:

void print_arp_table(){
8010912f:	55                   	push   %ebp
80109130:	89 e5                	mov    %esp,%ebp
80109132:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109135:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010913c:	e9 92 00 00 00       	jmp    801091d3 <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
80109141:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109144:	89 d0                	mov    %edx,%eax
80109146:	c1 e0 02             	shl    $0x2,%eax
80109149:	01 d0                	add    %edx,%eax
8010914b:	01 c0                	add    %eax,%eax
8010914d:	01 d0                	add    %edx,%eax
8010914f:	05 aa 6c 19 80       	add    $0x80196caa,%eax
80109154:	0f b6 00             	movzbl (%eax),%eax
80109157:	84 c0                	test   %al,%al
80109159:	74 74                	je     801091cf <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
8010915b:	83 ec 08             	sub    $0x8,%esp
8010915e:	ff 75 f4             	push   -0xc(%ebp)
80109161:	68 ef bf 10 80       	push   $0x8010bfef
80109166:	e8 89 72 ff ff       	call   801003f4 <cprintf>
8010916b:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
8010916e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109171:	89 d0                	mov    %edx,%eax
80109173:	c1 e0 02             	shl    $0x2,%eax
80109176:	01 d0                	add    %edx,%eax
80109178:	01 c0                	add    %eax,%eax
8010917a:	01 d0                	add    %edx,%eax
8010917c:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
80109181:	83 ec 0c             	sub    $0xc,%esp
80109184:	50                   	push   %eax
80109185:	e8 54 02 00 00       	call   801093de <print_ipv4>
8010918a:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
8010918d:	83 ec 0c             	sub    $0xc,%esp
80109190:	68 fe bf 10 80       	push   $0x8010bffe
80109195:	e8 5a 72 ff ff       	call   801003f4 <cprintf>
8010919a:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
8010919d:	8b 55 f4             	mov    -0xc(%ebp),%edx
801091a0:	89 d0                	mov    %edx,%eax
801091a2:	c1 e0 02             	shl    $0x2,%eax
801091a5:	01 d0                	add    %edx,%eax
801091a7:	01 c0                	add    %eax,%eax
801091a9:	01 d0                	add    %edx,%eax
801091ab:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
801091b0:	83 c0 04             	add    $0x4,%eax
801091b3:	83 ec 0c             	sub    $0xc,%esp
801091b6:	50                   	push   %eax
801091b7:	e8 70 02 00 00       	call   8010942c <print_mac>
801091bc:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
801091bf:	83 ec 0c             	sub    $0xc,%esp
801091c2:	68 00 c0 10 80       	push   $0x8010c000
801091c7:	e8 28 72 ff ff       	call   801003f4 <cprintf>
801091cc:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801091cf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801091d3:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801091d7:	0f 8e 64 ff ff ff    	jle    80109141 <print_arp_table+0x12>
    }
  }
}
801091dd:	90                   	nop
801091de:	90                   	nop
801091df:	c9                   	leave  
801091e0:	c3                   	ret    

801091e1 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
801091e1:	55                   	push   %ebp
801091e2:	89 e5                	mov    %esp,%ebp
801091e4:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801091e7:	8b 45 10             	mov    0x10(%ebp),%eax
801091ea:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801091f0:	8b 45 0c             	mov    0xc(%ebp),%eax
801091f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801091f6:	8b 45 0c             	mov    0xc(%ebp),%eax
801091f9:	83 c0 0e             	add    $0xe,%eax
801091fc:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
801091ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109202:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109206:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109209:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
8010920d:	8b 45 08             	mov    0x8(%ebp),%eax
80109210:	8d 50 08             	lea    0x8(%eax),%edx
80109213:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109216:	83 ec 04             	sub    $0x4,%esp
80109219:	6a 06                	push   $0x6
8010921b:	52                   	push   %edx
8010921c:	50                   	push   %eax
8010921d:	e8 72 b9 ff ff       	call   80104b94 <memmove>
80109222:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109225:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109228:	83 c0 06             	add    $0x6,%eax
8010922b:	83 ec 04             	sub    $0x4,%esp
8010922e:	6a 06                	push   $0x6
80109230:	68 80 6c 19 80       	push   $0x80196c80
80109235:	50                   	push   %eax
80109236:	e8 59 b9 ff ff       	call   80104b94 <memmove>
8010923b:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
8010923e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109241:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109246:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109249:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
8010924f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109252:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109256:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109259:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
8010925d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109260:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109266:	8b 45 08             	mov    0x8(%ebp),%eax
80109269:	8d 50 08             	lea    0x8(%eax),%edx
8010926c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010926f:	83 c0 12             	add    $0x12,%eax
80109272:	83 ec 04             	sub    $0x4,%esp
80109275:	6a 06                	push   $0x6
80109277:	52                   	push   %edx
80109278:	50                   	push   %eax
80109279:	e8 16 b9 ff ff       	call   80104b94 <memmove>
8010927e:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109281:	8b 45 08             	mov    0x8(%ebp),%eax
80109284:	8d 50 0e             	lea    0xe(%eax),%edx
80109287:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010928a:	83 c0 18             	add    $0x18,%eax
8010928d:	83 ec 04             	sub    $0x4,%esp
80109290:	6a 04                	push   $0x4
80109292:	52                   	push   %edx
80109293:	50                   	push   %eax
80109294:	e8 fb b8 ff ff       	call   80104b94 <memmove>
80109299:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
8010929c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010929f:	83 c0 08             	add    $0x8,%eax
801092a2:	83 ec 04             	sub    $0x4,%esp
801092a5:	6a 06                	push   $0x6
801092a7:	68 80 6c 19 80       	push   $0x80196c80
801092ac:	50                   	push   %eax
801092ad:	e8 e2 b8 ff ff       	call   80104b94 <memmove>
801092b2:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801092b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092b8:	83 c0 0e             	add    $0xe,%eax
801092bb:	83 ec 04             	sub    $0x4,%esp
801092be:	6a 04                	push   $0x4
801092c0:	68 e4 f4 10 80       	push   $0x8010f4e4
801092c5:	50                   	push   %eax
801092c6:	e8 c9 b8 ff ff       	call   80104b94 <memmove>
801092cb:	83 c4 10             	add    $0x10,%esp
}
801092ce:	90                   	nop
801092cf:	c9                   	leave  
801092d0:	c3                   	ret    

801092d1 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
801092d1:	55                   	push   %ebp
801092d2:	89 e5                	mov    %esp,%ebp
801092d4:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
801092d7:	83 ec 0c             	sub    $0xc,%esp
801092da:	68 02 c0 10 80       	push   $0x8010c002
801092df:	e8 10 71 ff ff       	call   801003f4 <cprintf>
801092e4:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
801092e7:	8b 45 08             	mov    0x8(%ebp),%eax
801092ea:	83 c0 0e             	add    $0xe,%eax
801092ed:	83 ec 0c             	sub    $0xc,%esp
801092f0:	50                   	push   %eax
801092f1:	e8 e8 00 00 00       	call   801093de <print_ipv4>
801092f6:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801092f9:	83 ec 0c             	sub    $0xc,%esp
801092fc:	68 00 c0 10 80       	push   $0x8010c000
80109301:	e8 ee 70 ff ff       	call   801003f4 <cprintf>
80109306:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
80109309:	8b 45 08             	mov    0x8(%ebp),%eax
8010930c:	83 c0 08             	add    $0x8,%eax
8010930f:	83 ec 0c             	sub    $0xc,%esp
80109312:	50                   	push   %eax
80109313:	e8 14 01 00 00       	call   8010942c <print_mac>
80109318:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010931b:	83 ec 0c             	sub    $0xc,%esp
8010931e:	68 00 c0 10 80       	push   $0x8010c000
80109323:	e8 cc 70 ff ff       	call   801003f4 <cprintf>
80109328:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
8010932b:	83 ec 0c             	sub    $0xc,%esp
8010932e:	68 19 c0 10 80       	push   $0x8010c019
80109333:	e8 bc 70 ff ff       	call   801003f4 <cprintf>
80109338:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
8010933b:	8b 45 08             	mov    0x8(%ebp),%eax
8010933e:	83 c0 18             	add    $0x18,%eax
80109341:	83 ec 0c             	sub    $0xc,%esp
80109344:	50                   	push   %eax
80109345:	e8 94 00 00 00       	call   801093de <print_ipv4>
8010934a:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010934d:	83 ec 0c             	sub    $0xc,%esp
80109350:	68 00 c0 10 80       	push   $0x8010c000
80109355:	e8 9a 70 ff ff       	call   801003f4 <cprintf>
8010935a:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
8010935d:	8b 45 08             	mov    0x8(%ebp),%eax
80109360:	83 c0 12             	add    $0x12,%eax
80109363:	83 ec 0c             	sub    $0xc,%esp
80109366:	50                   	push   %eax
80109367:	e8 c0 00 00 00       	call   8010942c <print_mac>
8010936c:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010936f:	83 ec 0c             	sub    $0xc,%esp
80109372:	68 00 c0 10 80       	push   $0x8010c000
80109377:	e8 78 70 ff ff       	call   801003f4 <cprintf>
8010937c:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
8010937f:	83 ec 0c             	sub    $0xc,%esp
80109382:	68 30 c0 10 80       	push   $0x8010c030
80109387:	e8 68 70 ff ff       	call   801003f4 <cprintf>
8010938c:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
8010938f:	8b 45 08             	mov    0x8(%ebp),%eax
80109392:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109396:	66 3d 00 01          	cmp    $0x100,%ax
8010939a:	75 12                	jne    801093ae <print_arp_info+0xdd>
8010939c:	83 ec 0c             	sub    $0xc,%esp
8010939f:	68 3c c0 10 80       	push   $0x8010c03c
801093a4:	e8 4b 70 ff ff       	call   801003f4 <cprintf>
801093a9:	83 c4 10             	add    $0x10,%esp
801093ac:	eb 1d                	jmp    801093cb <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
801093ae:	8b 45 08             	mov    0x8(%ebp),%eax
801093b1:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801093b5:	66 3d 00 02          	cmp    $0x200,%ax
801093b9:	75 10                	jne    801093cb <print_arp_info+0xfa>
    cprintf("Reply\n");
801093bb:	83 ec 0c             	sub    $0xc,%esp
801093be:	68 45 c0 10 80       	push   $0x8010c045
801093c3:	e8 2c 70 ff ff       	call   801003f4 <cprintf>
801093c8:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
801093cb:	83 ec 0c             	sub    $0xc,%esp
801093ce:	68 00 c0 10 80       	push   $0x8010c000
801093d3:	e8 1c 70 ff ff       	call   801003f4 <cprintf>
801093d8:	83 c4 10             	add    $0x10,%esp
}
801093db:	90                   	nop
801093dc:	c9                   	leave  
801093dd:	c3                   	ret    

801093de <print_ipv4>:

void print_ipv4(uchar *ip){
801093de:	55                   	push   %ebp
801093df:	89 e5                	mov    %esp,%ebp
801093e1:	53                   	push   %ebx
801093e2:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
801093e5:	8b 45 08             	mov    0x8(%ebp),%eax
801093e8:	83 c0 03             	add    $0x3,%eax
801093eb:	0f b6 00             	movzbl (%eax),%eax
801093ee:	0f b6 d8             	movzbl %al,%ebx
801093f1:	8b 45 08             	mov    0x8(%ebp),%eax
801093f4:	83 c0 02             	add    $0x2,%eax
801093f7:	0f b6 00             	movzbl (%eax),%eax
801093fa:	0f b6 c8             	movzbl %al,%ecx
801093fd:	8b 45 08             	mov    0x8(%ebp),%eax
80109400:	83 c0 01             	add    $0x1,%eax
80109403:	0f b6 00             	movzbl (%eax),%eax
80109406:	0f b6 d0             	movzbl %al,%edx
80109409:	8b 45 08             	mov    0x8(%ebp),%eax
8010940c:	0f b6 00             	movzbl (%eax),%eax
8010940f:	0f b6 c0             	movzbl %al,%eax
80109412:	83 ec 0c             	sub    $0xc,%esp
80109415:	53                   	push   %ebx
80109416:	51                   	push   %ecx
80109417:	52                   	push   %edx
80109418:	50                   	push   %eax
80109419:	68 4c c0 10 80       	push   $0x8010c04c
8010941e:	e8 d1 6f ff ff       	call   801003f4 <cprintf>
80109423:	83 c4 20             	add    $0x20,%esp
}
80109426:	90                   	nop
80109427:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010942a:	c9                   	leave  
8010942b:	c3                   	ret    

8010942c <print_mac>:

void print_mac(uchar *mac){
8010942c:	55                   	push   %ebp
8010942d:	89 e5                	mov    %esp,%ebp
8010942f:	57                   	push   %edi
80109430:	56                   	push   %esi
80109431:	53                   	push   %ebx
80109432:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109435:	8b 45 08             	mov    0x8(%ebp),%eax
80109438:	83 c0 05             	add    $0x5,%eax
8010943b:	0f b6 00             	movzbl (%eax),%eax
8010943e:	0f b6 f8             	movzbl %al,%edi
80109441:	8b 45 08             	mov    0x8(%ebp),%eax
80109444:	83 c0 04             	add    $0x4,%eax
80109447:	0f b6 00             	movzbl (%eax),%eax
8010944a:	0f b6 f0             	movzbl %al,%esi
8010944d:	8b 45 08             	mov    0x8(%ebp),%eax
80109450:	83 c0 03             	add    $0x3,%eax
80109453:	0f b6 00             	movzbl (%eax),%eax
80109456:	0f b6 d8             	movzbl %al,%ebx
80109459:	8b 45 08             	mov    0x8(%ebp),%eax
8010945c:	83 c0 02             	add    $0x2,%eax
8010945f:	0f b6 00             	movzbl (%eax),%eax
80109462:	0f b6 c8             	movzbl %al,%ecx
80109465:	8b 45 08             	mov    0x8(%ebp),%eax
80109468:	83 c0 01             	add    $0x1,%eax
8010946b:	0f b6 00             	movzbl (%eax),%eax
8010946e:	0f b6 d0             	movzbl %al,%edx
80109471:	8b 45 08             	mov    0x8(%ebp),%eax
80109474:	0f b6 00             	movzbl (%eax),%eax
80109477:	0f b6 c0             	movzbl %al,%eax
8010947a:	83 ec 04             	sub    $0x4,%esp
8010947d:	57                   	push   %edi
8010947e:	56                   	push   %esi
8010947f:	53                   	push   %ebx
80109480:	51                   	push   %ecx
80109481:	52                   	push   %edx
80109482:	50                   	push   %eax
80109483:	68 64 c0 10 80       	push   $0x8010c064
80109488:	e8 67 6f ff ff       	call   801003f4 <cprintf>
8010948d:	83 c4 20             	add    $0x20,%esp
}
80109490:	90                   	nop
80109491:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109494:	5b                   	pop    %ebx
80109495:	5e                   	pop    %esi
80109496:	5f                   	pop    %edi
80109497:	5d                   	pop    %ebp
80109498:	c3                   	ret    

80109499 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109499:	55                   	push   %ebp
8010949a:	89 e5                	mov    %esp,%ebp
8010949c:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
8010949f:	8b 45 08             	mov    0x8(%ebp),%eax
801094a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
801094a5:	8b 45 08             	mov    0x8(%ebp),%eax
801094a8:	83 c0 0e             	add    $0xe,%eax
801094ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
801094ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094b1:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801094b5:	3c 08                	cmp    $0x8,%al
801094b7:	75 1b                	jne    801094d4 <eth_proc+0x3b>
801094b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094bc:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801094c0:	3c 06                	cmp    $0x6,%al
801094c2:	75 10                	jne    801094d4 <eth_proc+0x3b>
    arp_proc(pkt_addr);
801094c4:	83 ec 0c             	sub    $0xc,%esp
801094c7:	ff 75 f0             	push   -0x10(%ebp)
801094ca:	e8 01 f8 ff ff       	call   80108cd0 <arp_proc>
801094cf:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
801094d2:	eb 24                	jmp    801094f8 <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
801094d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094d7:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801094db:	3c 08                	cmp    $0x8,%al
801094dd:	75 19                	jne    801094f8 <eth_proc+0x5f>
801094df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094e2:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801094e6:	84 c0                	test   %al,%al
801094e8:	75 0e                	jne    801094f8 <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
801094ea:	83 ec 0c             	sub    $0xc,%esp
801094ed:	ff 75 08             	push   0x8(%ebp)
801094f0:	e8 a3 00 00 00       	call   80109598 <ipv4_proc>
801094f5:	83 c4 10             	add    $0x10,%esp
}
801094f8:	90                   	nop
801094f9:	c9                   	leave  
801094fa:	c3                   	ret    

801094fb <N2H_ushort>:

ushort N2H_ushort(ushort value){
801094fb:	55                   	push   %ebp
801094fc:	89 e5                	mov    %esp,%ebp
801094fe:	83 ec 04             	sub    $0x4,%esp
80109501:	8b 45 08             	mov    0x8(%ebp),%eax
80109504:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109508:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010950c:	c1 e0 08             	shl    $0x8,%eax
8010950f:	89 c2                	mov    %eax,%edx
80109511:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109515:	66 c1 e8 08          	shr    $0x8,%ax
80109519:	01 d0                	add    %edx,%eax
}
8010951b:	c9                   	leave  
8010951c:	c3                   	ret    

8010951d <H2N_ushort>:

ushort H2N_ushort(ushort value){
8010951d:	55                   	push   %ebp
8010951e:	89 e5                	mov    %esp,%ebp
80109520:	83 ec 04             	sub    $0x4,%esp
80109523:	8b 45 08             	mov    0x8(%ebp),%eax
80109526:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
8010952a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010952e:	c1 e0 08             	shl    $0x8,%eax
80109531:	89 c2                	mov    %eax,%edx
80109533:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109537:	66 c1 e8 08          	shr    $0x8,%ax
8010953b:	01 d0                	add    %edx,%eax
}
8010953d:	c9                   	leave  
8010953e:	c3                   	ret    

8010953f <H2N_uint>:

uint H2N_uint(uint value){
8010953f:	55                   	push   %ebp
80109540:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109542:	8b 45 08             	mov    0x8(%ebp),%eax
80109545:	c1 e0 18             	shl    $0x18,%eax
80109548:	25 00 00 00 0f       	and    $0xf000000,%eax
8010954d:	89 c2                	mov    %eax,%edx
8010954f:	8b 45 08             	mov    0x8(%ebp),%eax
80109552:	c1 e0 08             	shl    $0x8,%eax
80109555:	25 00 f0 00 00       	and    $0xf000,%eax
8010955a:	09 c2                	or     %eax,%edx
8010955c:	8b 45 08             	mov    0x8(%ebp),%eax
8010955f:	c1 e8 08             	shr    $0x8,%eax
80109562:	83 e0 0f             	and    $0xf,%eax
80109565:	01 d0                	add    %edx,%eax
}
80109567:	5d                   	pop    %ebp
80109568:	c3                   	ret    

80109569 <N2H_uint>:

uint N2H_uint(uint value){
80109569:	55                   	push   %ebp
8010956a:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
8010956c:	8b 45 08             	mov    0x8(%ebp),%eax
8010956f:	c1 e0 18             	shl    $0x18,%eax
80109572:	89 c2                	mov    %eax,%edx
80109574:	8b 45 08             	mov    0x8(%ebp),%eax
80109577:	c1 e0 08             	shl    $0x8,%eax
8010957a:	25 00 00 ff 00       	and    $0xff0000,%eax
8010957f:	01 c2                	add    %eax,%edx
80109581:	8b 45 08             	mov    0x8(%ebp),%eax
80109584:	c1 e8 08             	shr    $0x8,%eax
80109587:	25 00 ff 00 00       	and    $0xff00,%eax
8010958c:	01 c2                	add    %eax,%edx
8010958e:	8b 45 08             	mov    0x8(%ebp),%eax
80109591:	c1 e8 18             	shr    $0x18,%eax
80109594:	01 d0                	add    %edx,%eax
}
80109596:	5d                   	pop    %ebp
80109597:	c3                   	ret    

80109598 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109598:	55                   	push   %ebp
80109599:	89 e5                	mov    %esp,%ebp
8010959b:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
8010959e:	8b 45 08             	mov    0x8(%ebp),%eax
801095a1:	83 c0 0e             	add    $0xe,%eax
801095a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
801095a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095aa:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801095ae:	0f b7 d0             	movzwl %ax,%edx
801095b1:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
801095b6:	39 c2                	cmp    %eax,%edx
801095b8:	74 60                	je     8010961a <ipv4_proc+0x82>
801095ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095bd:	83 c0 0c             	add    $0xc,%eax
801095c0:	83 ec 04             	sub    $0x4,%esp
801095c3:	6a 04                	push   $0x4
801095c5:	50                   	push   %eax
801095c6:	68 e4 f4 10 80       	push   $0x8010f4e4
801095cb:	e8 6c b5 ff ff       	call   80104b3c <memcmp>
801095d0:	83 c4 10             	add    $0x10,%esp
801095d3:	85 c0                	test   %eax,%eax
801095d5:	74 43                	je     8010961a <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
801095d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095da:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801095de:	0f b7 c0             	movzwl %ax,%eax
801095e1:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
801095e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095e9:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801095ed:	3c 01                	cmp    $0x1,%al
801095ef:	75 10                	jne    80109601 <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
801095f1:	83 ec 0c             	sub    $0xc,%esp
801095f4:	ff 75 08             	push   0x8(%ebp)
801095f7:	e8 a3 00 00 00       	call   8010969f <icmp_proc>
801095fc:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
801095ff:	eb 19                	jmp    8010961a <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109601:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109604:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109608:	3c 06                	cmp    $0x6,%al
8010960a:	75 0e                	jne    8010961a <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
8010960c:	83 ec 0c             	sub    $0xc,%esp
8010960f:	ff 75 08             	push   0x8(%ebp)
80109612:	e8 b3 03 00 00       	call   801099ca <tcp_proc>
80109617:	83 c4 10             	add    $0x10,%esp
}
8010961a:	90                   	nop
8010961b:	c9                   	leave  
8010961c:	c3                   	ret    

8010961d <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
8010961d:	55                   	push   %ebp
8010961e:	89 e5                	mov    %esp,%ebp
80109620:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109623:	8b 45 08             	mov    0x8(%ebp),%eax
80109626:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109629:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010962c:	0f b6 00             	movzbl (%eax),%eax
8010962f:	83 e0 0f             	and    $0xf,%eax
80109632:	01 c0                	add    %eax,%eax
80109634:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109637:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010963e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109645:	eb 48                	jmp    8010968f <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109647:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010964a:	01 c0                	add    %eax,%eax
8010964c:	89 c2                	mov    %eax,%edx
8010964e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109651:	01 d0                	add    %edx,%eax
80109653:	0f b6 00             	movzbl (%eax),%eax
80109656:	0f b6 c0             	movzbl %al,%eax
80109659:	c1 e0 08             	shl    $0x8,%eax
8010965c:	89 c2                	mov    %eax,%edx
8010965e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109661:	01 c0                	add    %eax,%eax
80109663:	8d 48 01             	lea    0x1(%eax),%ecx
80109666:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109669:	01 c8                	add    %ecx,%eax
8010966b:	0f b6 00             	movzbl (%eax),%eax
8010966e:	0f b6 c0             	movzbl %al,%eax
80109671:	01 d0                	add    %edx,%eax
80109673:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109676:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010967d:	76 0c                	jbe    8010968b <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
8010967f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109682:	0f b7 c0             	movzwl %ax,%eax
80109685:	83 c0 01             	add    $0x1,%eax
80109688:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010968b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010968f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109693:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109696:	7c af                	jl     80109647 <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
80109698:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010969b:	f7 d0                	not    %eax
}
8010969d:	c9                   	leave  
8010969e:	c3                   	ret    

8010969f <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
8010969f:	55                   	push   %ebp
801096a0:	89 e5                	mov    %esp,%ebp
801096a2:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
801096a5:	8b 45 08             	mov    0x8(%ebp),%eax
801096a8:	83 c0 0e             	add    $0xe,%eax
801096ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
801096ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096b1:	0f b6 00             	movzbl (%eax),%eax
801096b4:	0f b6 c0             	movzbl %al,%eax
801096b7:	83 e0 0f             	and    $0xf,%eax
801096ba:	c1 e0 02             	shl    $0x2,%eax
801096bd:	89 c2                	mov    %eax,%edx
801096bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096c2:	01 d0                	add    %edx,%eax
801096c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
801096c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096ca:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801096ce:	84 c0                	test   %al,%al
801096d0:	75 4f                	jne    80109721 <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
801096d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096d5:	0f b6 00             	movzbl (%eax),%eax
801096d8:	3c 08                	cmp    $0x8,%al
801096da:	75 45                	jne    80109721 <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
801096dc:	e8 b2 90 ff ff       	call   80102793 <kalloc>
801096e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
801096e4:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
801096eb:	83 ec 04             	sub    $0x4,%esp
801096ee:	8d 45 e8             	lea    -0x18(%ebp),%eax
801096f1:	50                   	push   %eax
801096f2:	ff 75 ec             	push   -0x14(%ebp)
801096f5:	ff 75 08             	push   0x8(%ebp)
801096f8:	e8 78 00 00 00       	call   80109775 <icmp_reply_pkt_create>
801096fd:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109700:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109703:	83 ec 08             	sub    $0x8,%esp
80109706:	50                   	push   %eax
80109707:	ff 75 ec             	push   -0x14(%ebp)
8010970a:	e8 95 f4 ff ff       	call   80108ba4 <i8254_send>
8010970f:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109712:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109715:	83 ec 0c             	sub    $0xc,%esp
80109718:	50                   	push   %eax
80109719:	e8 db 8f ff ff       	call   801026f9 <kfree>
8010971e:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109721:	90                   	nop
80109722:	c9                   	leave  
80109723:	c3                   	ret    

80109724 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109724:	55                   	push   %ebp
80109725:	89 e5                	mov    %esp,%ebp
80109727:	53                   	push   %ebx
80109728:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
8010972b:	8b 45 08             	mov    0x8(%ebp),%eax
8010972e:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109732:	0f b7 c0             	movzwl %ax,%eax
80109735:	83 ec 0c             	sub    $0xc,%esp
80109738:	50                   	push   %eax
80109739:	e8 bd fd ff ff       	call   801094fb <N2H_ushort>
8010973e:	83 c4 10             	add    $0x10,%esp
80109741:	0f b7 d8             	movzwl %ax,%ebx
80109744:	8b 45 08             	mov    0x8(%ebp),%eax
80109747:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010974b:	0f b7 c0             	movzwl %ax,%eax
8010974e:	83 ec 0c             	sub    $0xc,%esp
80109751:	50                   	push   %eax
80109752:	e8 a4 fd ff ff       	call   801094fb <N2H_ushort>
80109757:	83 c4 10             	add    $0x10,%esp
8010975a:	0f b7 c0             	movzwl %ax,%eax
8010975d:	83 ec 04             	sub    $0x4,%esp
80109760:	53                   	push   %ebx
80109761:	50                   	push   %eax
80109762:	68 83 c0 10 80       	push   $0x8010c083
80109767:	e8 88 6c ff ff       	call   801003f4 <cprintf>
8010976c:	83 c4 10             	add    $0x10,%esp
}
8010976f:	90                   	nop
80109770:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109773:	c9                   	leave  
80109774:	c3                   	ret    

80109775 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109775:	55                   	push   %ebp
80109776:	89 e5                	mov    %esp,%ebp
80109778:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010977b:	8b 45 08             	mov    0x8(%ebp),%eax
8010977e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109781:	8b 45 08             	mov    0x8(%ebp),%eax
80109784:	83 c0 0e             	add    $0xe,%eax
80109787:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
8010978a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010978d:	0f b6 00             	movzbl (%eax),%eax
80109790:	0f b6 c0             	movzbl %al,%eax
80109793:	83 e0 0f             	and    $0xf,%eax
80109796:	c1 e0 02             	shl    $0x2,%eax
80109799:	89 c2                	mov    %eax,%edx
8010979b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010979e:	01 d0                	add    %edx,%eax
801097a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
801097a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801097a6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
801097a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801097ac:	83 c0 0e             	add    $0xe,%eax
801097af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
801097b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801097b5:	83 c0 14             	add    $0x14,%eax
801097b8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
801097bb:	8b 45 10             	mov    0x10(%ebp),%eax
801097be:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
801097c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097c7:	8d 50 06             	lea    0x6(%eax),%edx
801097ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
801097cd:	83 ec 04             	sub    $0x4,%esp
801097d0:	6a 06                	push   $0x6
801097d2:	52                   	push   %edx
801097d3:	50                   	push   %eax
801097d4:	e8 bb b3 ff ff       	call   80104b94 <memmove>
801097d9:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
801097dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801097df:	83 c0 06             	add    $0x6,%eax
801097e2:	83 ec 04             	sub    $0x4,%esp
801097e5:	6a 06                	push   $0x6
801097e7:	68 80 6c 19 80       	push   $0x80196c80
801097ec:	50                   	push   %eax
801097ed:	e8 a2 b3 ff ff       	call   80104b94 <memmove>
801097f2:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
801097f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801097f8:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
801097fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801097ff:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109803:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109806:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109809:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010980c:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109810:	83 ec 0c             	sub    $0xc,%esp
80109813:	6a 54                	push   $0x54
80109815:	e8 03 fd ff ff       	call   8010951d <H2N_ushort>
8010981a:	83 c4 10             	add    $0x10,%esp
8010981d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109820:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109824:	0f b7 15 60 6f 19 80 	movzwl 0x80196f60,%edx
8010982b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010982e:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109832:	0f b7 05 60 6f 19 80 	movzwl 0x80196f60,%eax
80109839:	83 c0 01             	add    $0x1,%eax
8010983c:	66 a3 60 6f 19 80    	mov    %ax,0x80196f60
  ipv4_send->fragment = H2N_ushort(0x4000);
80109842:	83 ec 0c             	sub    $0xc,%esp
80109845:	68 00 40 00 00       	push   $0x4000
8010984a:	e8 ce fc ff ff       	call   8010951d <H2N_ushort>
8010984f:	83 c4 10             	add    $0x10,%esp
80109852:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109855:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109859:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010985c:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109860:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109863:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109867:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010986a:	83 c0 0c             	add    $0xc,%eax
8010986d:	83 ec 04             	sub    $0x4,%esp
80109870:	6a 04                	push   $0x4
80109872:	68 e4 f4 10 80       	push   $0x8010f4e4
80109877:	50                   	push   %eax
80109878:	e8 17 b3 ff ff       	call   80104b94 <memmove>
8010987d:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109880:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109883:	8d 50 0c             	lea    0xc(%eax),%edx
80109886:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109889:	83 c0 10             	add    $0x10,%eax
8010988c:	83 ec 04             	sub    $0x4,%esp
8010988f:	6a 04                	push   $0x4
80109891:	52                   	push   %edx
80109892:	50                   	push   %eax
80109893:	e8 fc b2 ff ff       	call   80104b94 <memmove>
80109898:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010989b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010989e:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
801098a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801098a7:	83 ec 0c             	sub    $0xc,%esp
801098aa:	50                   	push   %eax
801098ab:	e8 6d fd ff ff       	call   8010961d <ipv4_chksum>
801098b0:	83 c4 10             	add    $0x10,%esp
801098b3:	0f b7 c0             	movzwl %ax,%eax
801098b6:	83 ec 0c             	sub    $0xc,%esp
801098b9:	50                   	push   %eax
801098ba:	e8 5e fc ff ff       	call   8010951d <H2N_ushort>
801098bf:	83 c4 10             	add    $0x10,%esp
801098c2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801098c5:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
801098c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801098cc:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
801098cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801098d2:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
801098d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801098d9:	0f b7 50 04          	movzwl 0x4(%eax),%edx
801098dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801098e0:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
801098e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801098e7:	0f b7 50 06          	movzwl 0x6(%eax),%edx
801098eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801098ee:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
801098f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801098f5:	8d 50 08             	lea    0x8(%eax),%edx
801098f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801098fb:	83 c0 08             	add    $0x8,%eax
801098fe:	83 ec 04             	sub    $0x4,%esp
80109901:	6a 08                	push   $0x8
80109903:	52                   	push   %edx
80109904:	50                   	push   %eax
80109905:	e8 8a b2 ff ff       	call   80104b94 <memmove>
8010990a:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
8010990d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109910:	8d 50 10             	lea    0x10(%eax),%edx
80109913:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109916:	83 c0 10             	add    $0x10,%eax
80109919:	83 ec 04             	sub    $0x4,%esp
8010991c:	6a 30                	push   $0x30
8010991e:	52                   	push   %edx
8010991f:	50                   	push   %eax
80109920:	e8 6f b2 ff ff       	call   80104b94 <memmove>
80109925:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109928:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010992b:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109931:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109934:	83 ec 0c             	sub    $0xc,%esp
80109937:	50                   	push   %eax
80109938:	e8 1c 00 00 00       	call   80109959 <icmp_chksum>
8010993d:	83 c4 10             	add    $0x10,%esp
80109940:	0f b7 c0             	movzwl %ax,%eax
80109943:	83 ec 0c             	sub    $0xc,%esp
80109946:	50                   	push   %eax
80109947:	e8 d1 fb ff ff       	call   8010951d <H2N_ushort>
8010994c:	83 c4 10             	add    $0x10,%esp
8010994f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109952:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109956:	90                   	nop
80109957:	c9                   	leave  
80109958:	c3                   	ret    

80109959 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109959:	55                   	push   %ebp
8010995a:	89 e5                	mov    %esp,%ebp
8010995c:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
8010995f:	8b 45 08             	mov    0x8(%ebp),%eax
80109962:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109965:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010996c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109973:	eb 48                	jmp    801099bd <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109975:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109978:	01 c0                	add    %eax,%eax
8010997a:	89 c2                	mov    %eax,%edx
8010997c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010997f:	01 d0                	add    %edx,%eax
80109981:	0f b6 00             	movzbl (%eax),%eax
80109984:	0f b6 c0             	movzbl %al,%eax
80109987:	c1 e0 08             	shl    $0x8,%eax
8010998a:	89 c2                	mov    %eax,%edx
8010998c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010998f:	01 c0                	add    %eax,%eax
80109991:	8d 48 01             	lea    0x1(%eax),%ecx
80109994:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109997:	01 c8                	add    %ecx,%eax
80109999:	0f b6 00             	movzbl (%eax),%eax
8010999c:	0f b6 c0             	movzbl %al,%eax
8010999f:	01 d0                	add    %edx,%eax
801099a1:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
801099a4:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
801099ab:	76 0c                	jbe    801099b9 <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
801099ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
801099b0:	0f b7 c0             	movzwl %ax,%eax
801099b3:	83 c0 01             	add    $0x1,%eax
801099b6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
801099b9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801099bd:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
801099c1:	7e b2                	jle    80109975 <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
801099c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801099c6:	f7 d0                	not    %eax
}
801099c8:	c9                   	leave  
801099c9:	c3                   	ret    

801099ca <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
801099ca:	55                   	push   %ebp
801099cb:	89 e5                	mov    %esp,%ebp
801099cd:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
801099d0:	8b 45 08             	mov    0x8(%ebp),%eax
801099d3:	83 c0 0e             	add    $0xe,%eax
801099d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
801099d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099dc:	0f b6 00             	movzbl (%eax),%eax
801099df:	0f b6 c0             	movzbl %al,%eax
801099e2:	83 e0 0f             	and    $0xf,%eax
801099e5:	c1 e0 02             	shl    $0x2,%eax
801099e8:	89 c2                	mov    %eax,%edx
801099ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099ed:	01 d0                	add    %edx,%eax
801099ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
801099f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099f5:	83 c0 14             	add    $0x14,%eax
801099f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
801099fb:	e8 93 8d ff ff       	call   80102793 <kalloc>
80109a00:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109a03:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109a0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a0d:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109a11:	0f b6 c0             	movzbl %al,%eax
80109a14:	83 e0 02             	and    $0x2,%eax
80109a17:	85 c0                	test   %eax,%eax
80109a19:	74 3d                	je     80109a58 <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109a1b:	83 ec 0c             	sub    $0xc,%esp
80109a1e:	6a 00                	push   $0x0
80109a20:	6a 12                	push   $0x12
80109a22:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109a25:	50                   	push   %eax
80109a26:	ff 75 e8             	push   -0x18(%ebp)
80109a29:	ff 75 08             	push   0x8(%ebp)
80109a2c:	e8 a2 01 00 00       	call   80109bd3 <tcp_pkt_create>
80109a31:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109a34:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109a37:	83 ec 08             	sub    $0x8,%esp
80109a3a:	50                   	push   %eax
80109a3b:	ff 75 e8             	push   -0x18(%ebp)
80109a3e:	e8 61 f1 ff ff       	call   80108ba4 <i8254_send>
80109a43:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109a46:	a1 64 6f 19 80       	mov    0x80196f64,%eax
80109a4b:	83 c0 01             	add    $0x1,%eax
80109a4e:	a3 64 6f 19 80       	mov    %eax,0x80196f64
80109a53:	e9 69 01 00 00       	jmp    80109bc1 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109a58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a5b:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109a5f:	3c 18                	cmp    $0x18,%al
80109a61:	0f 85 10 01 00 00    	jne    80109b77 <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
80109a67:	83 ec 04             	sub    $0x4,%esp
80109a6a:	6a 03                	push   $0x3
80109a6c:	68 9e c0 10 80       	push   $0x8010c09e
80109a71:	ff 75 ec             	push   -0x14(%ebp)
80109a74:	e8 c3 b0 ff ff       	call   80104b3c <memcmp>
80109a79:	83 c4 10             	add    $0x10,%esp
80109a7c:	85 c0                	test   %eax,%eax
80109a7e:	74 74                	je     80109af4 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
80109a80:	83 ec 0c             	sub    $0xc,%esp
80109a83:	68 a2 c0 10 80       	push   $0x8010c0a2
80109a88:	e8 67 69 ff ff       	call   801003f4 <cprintf>
80109a8d:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109a90:	83 ec 0c             	sub    $0xc,%esp
80109a93:	6a 00                	push   $0x0
80109a95:	6a 10                	push   $0x10
80109a97:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109a9a:	50                   	push   %eax
80109a9b:	ff 75 e8             	push   -0x18(%ebp)
80109a9e:	ff 75 08             	push   0x8(%ebp)
80109aa1:	e8 2d 01 00 00       	call   80109bd3 <tcp_pkt_create>
80109aa6:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109aa9:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109aac:	83 ec 08             	sub    $0x8,%esp
80109aaf:	50                   	push   %eax
80109ab0:	ff 75 e8             	push   -0x18(%ebp)
80109ab3:	e8 ec f0 ff ff       	call   80108ba4 <i8254_send>
80109ab8:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109abb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109abe:	83 c0 36             	add    $0x36,%eax
80109ac1:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109ac4:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109ac7:	50                   	push   %eax
80109ac8:	ff 75 e0             	push   -0x20(%ebp)
80109acb:	6a 00                	push   $0x0
80109acd:	6a 00                	push   $0x0
80109acf:	e8 5a 04 00 00       	call   80109f2e <http_proc>
80109ad4:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109ad7:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109ada:	83 ec 0c             	sub    $0xc,%esp
80109add:	50                   	push   %eax
80109ade:	6a 18                	push   $0x18
80109ae0:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109ae3:	50                   	push   %eax
80109ae4:	ff 75 e8             	push   -0x18(%ebp)
80109ae7:	ff 75 08             	push   0x8(%ebp)
80109aea:	e8 e4 00 00 00       	call   80109bd3 <tcp_pkt_create>
80109aef:	83 c4 20             	add    $0x20,%esp
80109af2:	eb 62                	jmp    80109b56 <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109af4:	83 ec 0c             	sub    $0xc,%esp
80109af7:	6a 00                	push   $0x0
80109af9:	6a 10                	push   $0x10
80109afb:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109afe:	50                   	push   %eax
80109aff:	ff 75 e8             	push   -0x18(%ebp)
80109b02:	ff 75 08             	push   0x8(%ebp)
80109b05:	e8 c9 00 00 00       	call   80109bd3 <tcp_pkt_create>
80109b0a:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
80109b0d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109b10:	83 ec 08             	sub    $0x8,%esp
80109b13:	50                   	push   %eax
80109b14:	ff 75 e8             	push   -0x18(%ebp)
80109b17:	e8 88 f0 ff ff       	call   80108ba4 <i8254_send>
80109b1c:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109b1f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b22:	83 c0 36             	add    $0x36,%eax
80109b25:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109b28:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109b2b:	50                   	push   %eax
80109b2c:	ff 75 e4             	push   -0x1c(%ebp)
80109b2f:	6a 00                	push   $0x0
80109b31:	6a 00                	push   $0x0
80109b33:	e8 f6 03 00 00       	call   80109f2e <http_proc>
80109b38:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109b3b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109b3e:	83 ec 0c             	sub    $0xc,%esp
80109b41:	50                   	push   %eax
80109b42:	6a 18                	push   $0x18
80109b44:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109b47:	50                   	push   %eax
80109b48:	ff 75 e8             	push   -0x18(%ebp)
80109b4b:	ff 75 08             	push   0x8(%ebp)
80109b4e:	e8 80 00 00 00       	call   80109bd3 <tcp_pkt_create>
80109b53:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
80109b56:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109b59:	83 ec 08             	sub    $0x8,%esp
80109b5c:	50                   	push   %eax
80109b5d:	ff 75 e8             	push   -0x18(%ebp)
80109b60:	e8 3f f0 ff ff       	call   80108ba4 <i8254_send>
80109b65:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109b68:	a1 64 6f 19 80       	mov    0x80196f64,%eax
80109b6d:	83 c0 01             	add    $0x1,%eax
80109b70:	a3 64 6f 19 80       	mov    %eax,0x80196f64
80109b75:	eb 4a                	jmp    80109bc1 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
80109b77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b7a:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109b7e:	3c 10                	cmp    $0x10,%al
80109b80:	75 3f                	jne    80109bc1 <tcp_proc+0x1f7>
    if(fin_flag == 1){
80109b82:	a1 68 6f 19 80       	mov    0x80196f68,%eax
80109b87:	83 f8 01             	cmp    $0x1,%eax
80109b8a:	75 35                	jne    80109bc1 <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
80109b8c:	83 ec 0c             	sub    $0xc,%esp
80109b8f:	6a 00                	push   $0x0
80109b91:	6a 01                	push   $0x1
80109b93:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109b96:	50                   	push   %eax
80109b97:	ff 75 e8             	push   -0x18(%ebp)
80109b9a:	ff 75 08             	push   0x8(%ebp)
80109b9d:	e8 31 00 00 00       	call   80109bd3 <tcp_pkt_create>
80109ba2:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109ba5:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109ba8:	83 ec 08             	sub    $0x8,%esp
80109bab:	50                   	push   %eax
80109bac:	ff 75 e8             	push   -0x18(%ebp)
80109baf:	e8 f0 ef ff ff       	call   80108ba4 <i8254_send>
80109bb4:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
80109bb7:	c7 05 68 6f 19 80 00 	movl   $0x0,0x80196f68
80109bbe:	00 00 00 
    }
  }
  kfree((char *)send_addr);
80109bc1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109bc4:	83 ec 0c             	sub    $0xc,%esp
80109bc7:	50                   	push   %eax
80109bc8:	e8 2c 8b ff ff       	call   801026f9 <kfree>
80109bcd:	83 c4 10             	add    $0x10,%esp
}
80109bd0:	90                   	nop
80109bd1:	c9                   	leave  
80109bd2:	c3                   	ret    

80109bd3 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
80109bd3:	55                   	push   %ebp
80109bd4:	89 e5                	mov    %esp,%ebp
80109bd6:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109bd9:	8b 45 08             	mov    0x8(%ebp),%eax
80109bdc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109bdf:	8b 45 08             	mov    0x8(%ebp),%eax
80109be2:	83 c0 0e             	add    $0xe,%eax
80109be5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
80109be8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109beb:	0f b6 00             	movzbl (%eax),%eax
80109bee:	0f b6 c0             	movzbl %al,%eax
80109bf1:	83 e0 0f             	and    $0xf,%eax
80109bf4:	c1 e0 02             	shl    $0x2,%eax
80109bf7:	89 c2                	mov    %eax,%edx
80109bf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bfc:	01 d0                	add    %edx,%eax
80109bfe:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109c01:	8b 45 0c             	mov    0xc(%ebp),%eax
80109c04:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
80109c07:	8b 45 0c             	mov    0xc(%ebp),%eax
80109c0a:	83 c0 0e             	add    $0xe,%eax
80109c0d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
80109c10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c13:	83 c0 14             	add    $0x14,%eax
80109c16:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
80109c19:	8b 45 18             	mov    0x18(%ebp),%eax
80109c1c:	8d 50 36             	lea    0x36(%eax),%edx
80109c1f:	8b 45 10             	mov    0x10(%ebp),%eax
80109c22:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109c24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c27:	8d 50 06             	lea    0x6(%eax),%edx
80109c2a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c2d:	83 ec 04             	sub    $0x4,%esp
80109c30:	6a 06                	push   $0x6
80109c32:	52                   	push   %edx
80109c33:	50                   	push   %eax
80109c34:	e8 5b af ff ff       	call   80104b94 <memmove>
80109c39:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109c3c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c3f:	83 c0 06             	add    $0x6,%eax
80109c42:	83 ec 04             	sub    $0x4,%esp
80109c45:	6a 06                	push   $0x6
80109c47:	68 80 6c 19 80       	push   $0x80196c80
80109c4c:	50                   	push   %eax
80109c4d:	e8 42 af ff ff       	call   80104b94 <memmove>
80109c52:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109c55:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c58:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109c5c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c5f:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109c63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c66:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109c69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c6c:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
80109c70:	8b 45 18             	mov    0x18(%ebp),%eax
80109c73:	83 c0 28             	add    $0x28,%eax
80109c76:	0f b7 c0             	movzwl %ax,%eax
80109c79:	83 ec 0c             	sub    $0xc,%esp
80109c7c:	50                   	push   %eax
80109c7d:	e8 9b f8 ff ff       	call   8010951d <H2N_ushort>
80109c82:	83 c4 10             	add    $0x10,%esp
80109c85:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109c88:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109c8c:	0f b7 15 60 6f 19 80 	movzwl 0x80196f60,%edx
80109c93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c96:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109c9a:	0f b7 05 60 6f 19 80 	movzwl 0x80196f60,%eax
80109ca1:	83 c0 01             	add    $0x1,%eax
80109ca4:	66 a3 60 6f 19 80    	mov    %ax,0x80196f60
  ipv4_send->fragment = H2N_ushort(0x0000);
80109caa:	83 ec 0c             	sub    $0xc,%esp
80109cad:	6a 00                	push   $0x0
80109caf:	e8 69 f8 ff ff       	call   8010951d <H2N_ushort>
80109cb4:	83 c4 10             	add    $0x10,%esp
80109cb7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109cba:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109cbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cc1:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
80109cc5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cc8:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109ccc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ccf:	83 c0 0c             	add    $0xc,%eax
80109cd2:	83 ec 04             	sub    $0x4,%esp
80109cd5:	6a 04                	push   $0x4
80109cd7:	68 e4 f4 10 80       	push   $0x8010f4e4
80109cdc:	50                   	push   %eax
80109cdd:	e8 b2 ae ff ff       	call   80104b94 <memmove>
80109ce2:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109ce5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ce8:	8d 50 0c             	lea    0xc(%eax),%edx
80109ceb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cee:	83 c0 10             	add    $0x10,%eax
80109cf1:	83 ec 04             	sub    $0x4,%esp
80109cf4:	6a 04                	push   $0x4
80109cf6:	52                   	push   %edx
80109cf7:	50                   	push   %eax
80109cf8:	e8 97 ae ff ff       	call   80104b94 <memmove>
80109cfd:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109d00:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d03:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109d09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d0c:	83 ec 0c             	sub    $0xc,%esp
80109d0f:	50                   	push   %eax
80109d10:	e8 08 f9 ff ff       	call   8010961d <ipv4_chksum>
80109d15:	83 c4 10             	add    $0x10,%esp
80109d18:	0f b7 c0             	movzwl %ax,%eax
80109d1b:	83 ec 0c             	sub    $0xc,%esp
80109d1e:	50                   	push   %eax
80109d1f:	e8 f9 f7 ff ff       	call   8010951d <H2N_ushort>
80109d24:	83 c4 10             	add    $0x10,%esp
80109d27:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109d2a:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
80109d2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d31:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80109d35:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d38:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
80109d3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d3e:	0f b7 10             	movzwl (%eax),%edx
80109d41:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d44:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
80109d48:	a1 64 6f 19 80       	mov    0x80196f64,%eax
80109d4d:	83 ec 0c             	sub    $0xc,%esp
80109d50:	50                   	push   %eax
80109d51:	e8 e9 f7 ff ff       	call   8010953f <H2N_uint>
80109d56:	83 c4 10             	add    $0x10,%esp
80109d59:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109d5c:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
80109d5f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d62:	8b 40 04             	mov    0x4(%eax),%eax
80109d65:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
80109d6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d6e:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
80109d71:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d74:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
80109d78:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d7b:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
80109d7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d82:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
80109d86:	8b 45 14             	mov    0x14(%ebp),%eax
80109d89:	89 c2                	mov    %eax,%edx
80109d8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d8e:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
80109d91:	83 ec 0c             	sub    $0xc,%esp
80109d94:	68 90 38 00 00       	push   $0x3890
80109d99:	e8 7f f7 ff ff       	call   8010951d <H2N_ushort>
80109d9e:	83 c4 10             	add    $0x10,%esp
80109da1:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109da4:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
80109da8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109dab:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
80109db1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109db4:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
80109dba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109dbd:	83 ec 0c             	sub    $0xc,%esp
80109dc0:	50                   	push   %eax
80109dc1:	e8 1f 00 00 00       	call   80109de5 <tcp_chksum>
80109dc6:	83 c4 10             	add    $0x10,%esp
80109dc9:	83 c0 08             	add    $0x8,%eax
80109dcc:	0f b7 c0             	movzwl %ax,%eax
80109dcf:	83 ec 0c             	sub    $0xc,%esp
80109dd2:	50                   	push   %eax
80109dd3:	e8 45 f7 ff ff       	call   8010951d <H2N_ushort>
80109dd8:	83 c4 10             	add    $0x10,%esp
80109ddb:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109dde:	66 89 42 10          	mov    %ax,0x10(%edx)


}
80109de2:	90                   	nop
80109de3:	c9                   	leave  
80109de4:	c3                   	ret    

80109de5 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
80109de5:	55                   	push   %ebp
80109de6:	89 e5                	mov    %esp,%ebp
80109de8:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
80109deb:	8b 45 08             	mov    0x8(%ebp),%eax
80109dee:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
80109df1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109df4:	83 c0 14             	add    $0x14,%eax
80109df7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
80109dfa:	83 ec 04             	sub    $0x4,%esp
80109dfd:	6a 04                	push   $0x4
80109dff:	68 e4 f4 10 80       	push   $0x8010f4e4
80109e04:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109e07:	50                   	push   %eax
80109e08:	e8 87 ad ff ff       	call   80104b94 <memmove>
80109e0d:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
80109e10:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e13:	83 c0 0c             	add    $0xc,%eax
80109e16:	83 ec 04             	sub    $0x4,%esp
80109e19:	6a 04                	push   $0x4
80109e1b:	50                   	push   %eax
80109e1c:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109e1f:	83 c0 04             	add    $0x4,%eax
80109e22:	50                   	push   %eax
80109e23:	e8 6c ad ff ff       	call   80104b94 <memmove>
80109e28:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
80109e2b:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
80109e2f:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
80109e33:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e36:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80109e3a:	0f b7 c0             	movzwl %ax,%eax
80109e3d:	83 ec 0c             	sub    $0xc,%esp
80109e40:	50                   	push   %eax
80109e41:	e8 b5 f6 ff ff       	call   801094fb <N2H_ushort>
80109e46:	83 c4 10             	add    $0x10,%esp
80109e49:	83 e8 14             	sub    $0x14,%eax
80109e4c:	0f b7 c0             	movzwl %ax,%eax
80109e4f:	83 ec 0c             	sub    $0xc,%esp
80109e52:	50                   	push   %eax
80109e53:	e8 c5 f6 ff ff       	call   8010951d <H2N_ushort>
80109e58:	83 c4 10             	add    $0x10,%esp
80109e5b:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
80109e5f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
80109e66:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109e69:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
80109e6c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109e73:	eb 33                	jmp    80109ea8 <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109e75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e78:	01 c0                	add    %eax,%eax
80109e7a:	89 c2                	mov    %eax,%edx
80109e7c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e7f:	01 d0                	add    %edx,%eax
80109e81:	0f b6 00             	movzbl (%eax),%eax
80109e84:	0f b6 c0             	movzbl %al,%eax
80109e87:	c1 e0 08             	shl    $0x8,%eax
80109e8a:	89 c2                	mov    %eax,%edx
80109e8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e8f:	01 c0                	add    %eax,%eax
80109e91:	8d 48 01             	lea    0x1(%eax),%ecx
80109e94:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e97:	01 c8                	add    %ecx,%eax
80109e99:	0f b6 00             	movzbl (%eax),%eax
80109e9c:	0f b6 c0             	movzbl %al,%eax
80109e9f:	01 d0                	add    %edx,%eax
80109ea1:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
80109ea4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109ea8:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
80109eac:	7e c7                	jle    80109e75 <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
80109eae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109eb1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
80109eb4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80109ebb:	eb 33                	jmp    80109ef0 <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109ebd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ec0:	01 c0                	add    %eax,%eax
80109ec2:	89 c2                	mov    %eax,%edx
80109ec4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ec7:	01 d0                	add    %edx,%eax
80109ec9:	0f b6 00             	movzbl (%eax),%eax
80109ecc:	0f b6 c0             	movzbl %al,%eax
80109ecf:	c1 e0 08             	shl    $0x8,%eax
80109ed2:	89 c2                	mov    %eax,%edx
80109ed4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ed7:	01 c0                	add    %eax,%eax
80109ed9:	8d 48 01             	lea    0x1(%eax),%ecx
80109edc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109edf:	01 c8                	add    %ecx,%eax
80109ee1:	0f b6 00             	movzbl (%eax),%eax
80109ee4:	0f b6 c0             	movzbl %al,%eax
80109ee7:	01 d0                	add    %edx,%eax
80109ee9:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
80109eec:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80109ef0:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
80109ef4:	0f b7 c0             	movzwl %ax,%eax
80109ef7:	83 ec 0c             	sub    $0xc,%esp
80109efa:	50                   	push   %eax
80109efb:	e8 fb f5 ff ff       	call   801094fb <N2H_ushort>
80109f00:	83 c4 10             	add    $0x10,%esp
80109f03:	66 d1 e8             	shr    %ax
80109f06:	0f b7 c0             	movzwl %ax,%eax
80109f09:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80109f0c:	7c af                	jl     80109ebd <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
80109f0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f11:	c1 e8 10             	shr    $0x10,%eax
80109f14:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
80109f17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f1a:	f7 d0                	not    %eax
}
80109f1c:	c9                   	leave  
80109f1d:	c3                   	ret    

80109f1e <tcp_fin>:

void tcp_fin(){
80109f1e:	55                   	push   %ebp
80109f1f:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
80109f21:	c7 05 68 6f 19 80 01 	movl   $0x1,0x80196f68
80109f28:	00 00 00 
}
80109f2b:	90                   	nop
80109f2c:	5d                   	pop    %ebp
80109f2d:	c3                   	ret    

80109f2e <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
80109f2e:	55                   	push   %ebp
80109f2f:	89 e5                	mov    %esp,%ebp
80109f31:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
80109f34:	8b 45 10             	mov    0x10(%ebp),%eax
80109f37:	83 ec 04             	sub    $0x4,%esp
80109f3a:	6a 00                	push   $0x0
80109f3c:	68 ab c0 10 80       	push   $0x8010c0ab
80109f41:	50                   	push   %eax
80109f42:	e8 65 00 00 00       	call   80109fac <http_strcpy>
80109f47:	83 c4 10             	add    $0x10,%esp
80109f4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
80109f4d:	8b 45 10             	mov    0x10(%ebp),%eax
80109f50:	83 ec 04             	sub    $0x4,%esp
80109f53:	ff 75 f4             	push   -0xc(%ebp)
80109f56:	68 be c0 10 80       	push   $0x8010c0be
80109f5b:	50                   	push   %eax
80109f5c:	e8 4b 00 00 00       	call   80109fac <http_strcpy>
80109f61:	83 c4 10             	add    $0x10,%esp
80109f64:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
80109f67:	8b 45 10             	mov    0x10(%ebp),%eax
80109f6a:	83 ec 04             	sub    $0x4,%esp
80109f6d:	ff 75 f4             	push   -0xc(%ebp)
80109f70:	68 d9 c0 10 80       	push   $0x8010c0d9
80109f75:	50                   	push   %eax
80109f76:	e8 31 00 00 00       	call   80109fac <http_strcpy>
80109f7b:	83 c4 10             	add    $0x10,%esp
80109f7e:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
80109f81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f84:	83 e0 01             	and    $0x1,%eax
80109f87:	85 c0                	test   %eax,%eax
80109f89:	74 11                	je     80109f9c <http_proc+0x6e>
    char *payload = (char *)send;
80109f8b:	8b 45 10             	mov    0x10(%ebp),%eax
80109f8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
80109f91:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109f94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f97:	01 d0                	add    %edx,%eax
80109f99:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
80109f9c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109f9f:	8b 45 14             	mov    0x14(%ebp),%eax
80109fa2:	89 10                	mov    %edx,(%eax)
  tcp_fin();
80109fa4:	e8 75 ff ff ff       	call   80109f1e <tcp_fin>
}
80109fa9:	90                   	nop
80109faa:	c9                   	leave  
80109fab:	c3                   	ret    

80109fac <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
80109fac:	55                   	push   %ebp
80109fad:	89 e5                	mov    %esp,%ebp
80109faf:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
80109fb2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
80109fb9:	eb 20                	jmp    80109fdb <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
80109fbb:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109fbe:	8b 45 0c             	mov    0xc(%ebp),%eax
80109fc1:	01 d0                	add    %edx,%eax
80109fc3:	8b 4d 10             	mov    0x10(%ebp),%ecx
80109fc6:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109fc9:	01 ca                	add    %ecx,%edx
80109fcb:	89 d1                	mov    %edx,%ecx
80109fcd:	8b 55 08             	mov    0x8(%ebp),%edx
80109fd0:	01 ca                	add    %ecx,%edx
80109fd2:	0f b6 00             	movzbl (%eax),%eax
80109fd5:	88 02                	mov    %al,(%edx)
    i++;
80109fd7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
80109fdb:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109fde:	8b 45 0c             	mov    0xc(%ebp),%eax
80109fe1:	01 d0                	add    %edx,%eax
80109fe3:	0f b6 00             	movzbl (%eax),%eax
80109fe6:	84 c0                	test   %al,%al
80109fe8:	75 d1                	jne    80109fbb <http_strcpy+0xf>
  }
  return i;
80109fea:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80109fed:	c9                   	leave  
80109fee:	c3                   	ret    

80109fef <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
80109fef:	55                   	push   %ebp
80109ff0:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
80109ff2:	c7 05 70 6f 19 80 a2 	movl   $0x8010f5a2,0x80196f70
80109ff9:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
80109ffc:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a001:	c1 e8 09             	shr    $0x9,%eax
8010a004:	a3 6c 6f 19 80       	mov    %eax,0x80196f6c
}
8010a009:	90                   	nop
8010a00a:	5d                   	pop    %ebp
8010a00b:	c3                   	ret    

8010a00c <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a00c:	55                   	push   %ebp
8010a00d:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a00f:	90                   	nop
8010a010:	5d                   	pop    %ebp
8010a011:	c3                   	ret    

8010a012 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a012:	55                   	push   %ebp
8010a013:	89 e5                	mov    %esp,%ebp
8010a015:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a018:	8b 45 08             	mov    0x8(%ebp),%eax
8010a01b:	83 c0 0c             	add    $0xc,%eax
8010a01e:	83 ec 0c             	sub    $0xc,%esp
8010a021:	50                   	push   %eax
8010a022:	e8 a7 a7 ff ff       	call   801047ce <holdingsleep>
8010a027:	83 c4 10             	add    $0x10,%esp
8010a02a:	85 c0                	test   %eax,%eax
8010a02c:	75 0d                	jne    8010a03b <iderw+0x29>
    panic("iderw: buf not locked");
8010a02e:	83 ec 0c             	sub    $0xc,%esp
8010a031:	68 ea c0 10 80       	push   $0x8010c0ea
8010a036:	e8 6e 65 ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a03b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a03e:	8b 00                	mov    (%eax),%eax
8010a040:	83 e0 06             	and    $0x6,%eax
8010a043:	83 f8 02             	cmp    $0x2,%eax
8010a046:	75 0d                	jne    8010a055 <iderw+0x43>
    panic("iderw: nothing to do");
8010a048:	83 ec 0c             	sub    $0xc,%esp
8010a04b:	68 00 c1 10 80       	push   $0x8010c100
8010a050:	e8 54 65 ff ff       	call   801005a9 <panic>
  if(b->dev != 1)
8010a055:	8b 45 08             	mov    0x8(%ebp),%eax
8010a058:	8b 40 04             	mov    0x4(%eax),%eax
8010a05b:	83 f8 01             	cmp    $0x1,%eax
8010a05e:	74 0d                	je     8010a06d <iderw+0x5b>
    panic("iderw: request not for disk 1");
8010a060:	83 ec 0c             	sub    $0xc,%esp
8010a063:	68 15 c1 10 80       	push   $0x8010c115
8010a068:	e8 3c 65 ff ff       	call   801005a9 <panic>
  if(b->blockno >= disksize)
8010a06d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a070:	8b 40 08             	mov    0x8(%eax),%eax
8010a073:	8b 15 6c 6f 19 80    	mov    0x80196f6c,%edx
8010a079:	39 d0                	cmp    %edx,%eax
8010a07b:	72 0d                	jb     8010a08a <iderw+0x78>
    panic("iderw: block out of range");
8010a07d:	83 ec 0c             	sub    $0xc,%esp
8010a080:	68 33 c1 10 80       	push   $0x8010c133
8010a085:	e8 1f 65 ff ff       	call   801005a9 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a08a:	8b 15 70 6f 19 80    	mov    0x80196f70,%edx
8010a090:	8b 45 08             	mov    0x8(%ebp),%eax
8010a093:	8b 40 08             	mov    0x8(%eax),%eax
8010a096:	c1 e0 09             	shl    $0x9,%eax
8010a099:	01 d0                	add    %edx,%eax
8010a09b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a09e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0a1:	8b 00                	mov    (%eax),%eax
8010a0a3:	83 e0 04             	and    $0x4,%eax
8010a0a6:	85 c0                	test   %eax,%eax
8010a0a8:	74 2b                	je     8010a0d5 <iderw+0xc3>
    b->flags &= ~B_DIRTY;
8010a0aa:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0ad:	8b 00                	mov    (%eax),%eax
8010a0af:	83 e0 fb             	and    $0xfffffffb,%eax
8010a0b2:	89 c2                	mov    %eax,%edx
8010a0b4:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0b7:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a0b9:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0bc:	83 c0 5c             	add    $0x5c,%eax
8010a0bf:	83 ec 04             	sub    $0x4,%esp
8010a0c2:	68 00 02 00 00       	push   $0x200
8010a0c7:	50                   	push   %eax
8010a0c8:	ff 75 f4             	push   -0xc(%ebp)
8010a0cb:	e8 c4 aa ff ff       	call   80104b94 <memmove>
8010a0d0:	83 c4 10             	add    $0x10,%esp
8010a0d3:	eb 1a                	jmp    8010a0ef <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
8010a0d5:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0d8:	83 c0 5c             	add    $0x5c,%eax
8010a0db:	83 ec 04             	sub    $0x4,%esp
8010a0de:	68 00 02 00 00       	push   $0x200
8010a0e3:	ff 75 f4             	push   -0xc(%ebp)
8010a0e6:	50                   	push   %eax
8010a0e7:	e8 a8 aa ff ff       	call   80104b94 <memmove>
8010a0ec:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a0ef:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0f2:	8b 00                	mov    (%eax),%eax
8010a0f4:	83 c8 02             	or     $0x2,%eax
8010a0f7:	89 c2                	mov    %eax,%edx
8010a0f9:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0fc:	89 10                	mov    %edx,(%eax)
}
8010a0fe:	90                   	nop
8010a0ff:	c9                   	leave  
8010a100:	c3                   	ret    
