
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
8010005f:	ba 56 33 10 80       	mov    $0x80103356,%edx
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
8010006f:	68 e0 a0 10 80       	push   $0x8010a0e0
80100074:	68 00 d0 18 80       	push   $0x8018d000
80100079:	e8 9b 47 00 00       	call   80104819 <initlock>
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
801000bd:	68 e7 a0 10 80       	push   $0x8010a0e7
801000c2:	50                   	push   %eax
801000c3:	e8 f4 45 00 00       	call   801046bc <initsleeplock>
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
80100101:	e8 35 47 00 00       	call   8010483b <acquire>
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
80100140:	e8 64 47 00 00       	call   801048a9 <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 a1 45 00 00       	call   801046f8 <acquiresleep>
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
801001c1:	e8 e3 46 00 00       	call   801048a9 <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 20 45 00 00       	call   801046f8 <acquiresleep>
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
801001f5:	68 ee a0 10 80       	push   $0x8010a0ee
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
8010022d:	e8 a6 9d 00 00       	call   80109fd8 <iderw>
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
8010024a:	e8 5b 45 00 00       	call   801047aa <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 ff a0 10 80       	push   $0x8010a0ff
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
80100278:	e8 5b 9d 00 00       	call   80109fd8 <iderw>
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
80100293:	e8 12 45 00 00       	call   801047aa <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 06 a1 10 80       	push   $0x8010a106
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 a1 44 00 00       	call   8010475c <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 d0 18 80       	push   $0x8018d000
801002c6:	e8 70 45 00 00       	call   8010483b <acquire>
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
80100336:	e8 6e 45 00 00       	call   801048a9 <release>
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
80100410:	e8 26 44 00 00       	call   8010483b <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 0d a1 10 80       	push   $0x8010a10d
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
80100510:	c7 45 ec 16 a1 10 80 	movl   $0x8010a116,-0x14(%ebp)
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
8010059e:	e8 06 43 00 00       	call   801048a9 <release>
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
801005be:	e8 28 25 00 00       	call   80102aeb <lapicid>
801005c3:	83 ec 08             	sub    $0x8,%esp
801005c6:	50                   	push   %eax
801005c7:	68 1d a1 10 80       	push   $0x8010a11d
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
801005e6:	68 31 a1 10 80       	push   $0x8010a131
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 f8 42 00 00       	call   801048fb <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 33 a1 10 80       	push   $0x8010a133
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
801006a0:	e8 8a 78 00 00       	call   80107f2f <graphic_scroll_up>
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
801006f3:	e8 37 78 00 00       	call   80107f2f <graphic_scroll_up>
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
80100757:	e8 3e 78 00 00       	call   80107f9a <font_render>
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
80100793:	e8 21 5c 00 00       	call   801063b9 <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 14 5c 00 00       	call   801063b9 <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 07 5c 00 00       	call   801063b9 <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x56>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 f7 5b 00 00       	call   801063b9 <uartputc>
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
801007eb:	e8 4b 40 00 00       	call   8010483b <acquire>
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
8010093f:	e8 6d 3a 00 00       	call   801043b1 <wakeup>
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
80100962:	e8 42 3f 00 00       	call   801048a9 <release>
80100967:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010096a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010096e:	74 05                	je     80100975 <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
80100970:	e8 f7 3a 00 00       	call   8010446c <procdump>
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
80100984:	e8 65 11 00 00       	call   80101aee <iunlock>
80100989:	83 c4 10             	add    $0x10,%esp
  target = n;
8010098c:	8b 45 10             	mov    0x10(%ebp),%eax
8010098f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100992:	83 ec 0c             	sub    $0xc,%esp
80100995:	68 00 1a 19 80       	push   $0x80191a00
8010099a:	e8 9c 3e 00 00       	call   8010483b <acquire>
8010099f:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009a2:	e9 ab 00 00 00       	jmp    80100a52 <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009a7:	e8 75 30 00 00       	call   80103a21 <myproc>
801009ac:	8b 40 24             	mov    0x24(%eax),%eax
801009af:	85 c0                	test   %eax,%eax
801009b1:	74 28                	je     801009db <consoleread+0x63>
        release(&cons.lock);
801009b3:	83 ec 0c             	sub    $0xc,%esp
801009b6:	68 00 1a 19 80       	push   $0x80191a00
801009bb:	e8 e9 3e 00 00       	call   801048a9 <release>
801009c0:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009c3:	83 ec 0c             	sub    $0xc,%esp
801009c6:	ff 75 08             	push   0x8(%ebp)
801009c9:	e8 0d 10 00 00       	call   801019db <ilock>
801009ce:	83 c4 10             	add    $0x10,%esp
        return -1;
801009d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009d6:	e9 a9 00 00 00       	jmp    80100a84 <consoleread+0x10c>
      }
      sleep(&input.r, &cons.lock);
801009db:	83 ec 08             	sub    $0x8,%esp
801009de:	68 00 1a 19 80       	push   $0x80191a00
801009e3:	68 e0 19 19 80       	push   $0x801919e0
801009e8:	e8 dd 38 00 00       	call   801042ca <sleep>
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
80100a66:	e8 3e 3e 00 00       	call   801048a9 <release>
80100a6b:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a6e:	83 ec 0c             	sub    $0xc,%esp
80100a71:	ff 75 08             	push   0x8(%ebp)
80100a74:	e8 62 0f 00 00       	call   801019db <ilock>
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
80100a92:	e8 57 10 00 00       	call   80101aee <iunlock>
80100a97:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100a9a:	83 ec 0c             	sub    $0xc,%esp
80100a9d:	68 00 1a 19 80       	push   $0x80191a00
80100aa2:	e8 94 3d 00 00       	call   8010483b <acquire>
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
80100ae4:	e8 c0 3d 00 00       	call   801048a9 <release>
80100ae9:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100aec:	83 ec 0c             	sub    $0xc,%esp
80100aef:	ff 75 08             	push   0x8(%ebp)
80100af2:	e8 e4 0e 00 00       	call   801019db <ilock>
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
80100b12:	68 37 a1 10 80       	push   $0x8010a137
80100b17:	68 00 1a 19 80       	push   $0x80191a00
80100b1c:	e8 f8 3c 00 00       	call   80104819 <initlock>
80100b21:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b24:	c7 05 4c 1a 19 80 86 	movl   $0x80100a86,0x80191a4c
80100b2b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b2e:	c7 05 48 1a 19 80 78 	movl   $0x80100978,0x80191a48
80100b35:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b38:	c7 45 f4 3f a1 10 80 	movl   $0x8010a13f,-0xc(%ebp)
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
80100b75:	e8 a5 1a 00 00       	call   8010261f <ioapicenable>
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
80100b83:	81 ec 28 01 00 00    	sub    $0x128,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100b89:	e8 93 2e 00 00       	call   80103a21 <myproc>
80100b8e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100b91:	e8 97 24 00 00       	call   8010302d <begin_op>

  if((ip = namei(path)) == 0){
80100b96:	83 ec 0c             	sub    $0xc,%esp
80100b99:	ff 75 08             	push   0x8(%ebp)
80100b9c:	e8 6d 19 00 00       	call   8010250e <namei>
80100ba1:	83 c4 10             	add    $0x10,%esp
80100ba4:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100ba7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bab:	75 1f                	jne    80100bcc <exec+0x4c>
    end_op();
80100bad:	e8 07 25 00 00       	call   801030b9 <end_op>
    cprintf("exec: fail\n");
80100bb2:	83 ec 0c             	sub    $0xc,%esp
80100bb5:	68 55 a1 10 80       	push   $0x8010a155
80100bba:	e8 35 f8 ff ff       	call   801003f4 <cprintf>
80100bbf:	83 c4 10             	add    $0x10,%esp
    return -1;
80100bc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bc7:	e9 e2 03 00 00       	jmp    80100fae <exec+0x42e>
  }
  ilock(ip);
80100bcc:	83 ec 0c             	sub    $0xc,%esp
80100bcf:	ff 75 d8             	push   -0x28(%ebp)
80100bd2:	e8 04 0e 00 00       	call   801019db <ilock>
80100bd7:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100bda:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100be1:	6a 34                	push   $0x34
80100be3:	6a 00                	push   $0x0
80100be5:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
80100beb:	50                   	push   %eax
80100bec:	ff 75 d8             	push   -0x28(%ebp)
80100bef:	e8 d3 12 00 00       	call   80101ec7 <readi>
80100bf4:	83 c4 10             	add    $0x10,%esp
80100bf7:	83 f8 34             	cmp    $0x34,%eax
80100bfa:	0f 85 57 03 00 00    	jne    80100f57 <exec+0x3d7>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c00:	8b 85 04 ff ff ff    	mov    -0xfc(%ebp),%eax
80100c06:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c0b:	0f 85 49 03 00 00    	jne    80100f5a <exec+0x3da>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c11:	e8 9f 67 00 00       	call   801073b5 <setupkvm>
80100c16:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c19:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c1d:	0f 84 3a 03 00 00    	je     80100f5d <exec+0x3dd>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c23:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c2a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c31:	8b 85 20 ff ff ff    	mov    -0xe0(%ebp),%eax
80100c37:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c3a:	e9 de 00 00 00       	jmp    80100d1d <exec+0x19d>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c3f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c42:	6a 20                	push   $0x20
80100c44:	50                   	push   %eax
80100c45:	8d 85 e4 fe ff ff    	lea    -0x11c(%ebp),%eax
80100c4b:	50                   	push   %eax
80100c4c:	ff 75 d8             	push   -0x28(%ebp)
80100c4f:	e8 73 12 00 00       	call   80101ec7 <readi>
80100c54:	83 c4 10             	add    $0x10,%esp
80100c57:	83 f8 20             	cmp    $0x20,%eax
80100c5a:	0f 85 00 03 00 00    	jne    80100f60 <exec+0x3e0>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c60:	8b 85 e4 fe ff ff    	mov    -0x11c(%ebp),%eax
80100c66:	83 f8 01             	cmp    $0x1,%eax
80100c69:	0f 85 a0 00 00 00    	jne    80100d0f <exec+0x18f>
      continue;
    if(ph.memsz < ph.filesz)
80100c6f:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100c75:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100c7b:	39 c2                	cmp    %eax,%edx
80100c7d:	0f 82 e0 02 00 00    	jb     80100f63 <exec+0x3e3>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c83:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100c89:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100c8f:	01 c2                	add    %eax,%edx
80100c91:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100c97:	39 c2                	cmp    %eax,%edx
80100c99:	0f 82 c7 02 00 00    	jb     80100f66 <exec+0x3e6>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c9f:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100ca5:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100cab:	01 d0                	add    %edx,%eax
80100cad:	83 ec 04             	sub    $0x4,%esp
80100cb0:	50                   	push   %eax
80100cb1:	ff 75 e0             	push   -0x20(%ebp)
80100cb4:	ff 75 d4             	push   -0x2c(%ebp)
80100cb7:	e8 f2 6a 00 00       	call   801077ae <allocuvm>
80100cbc:	83 c4 10             	add    $0x10,%esp
80100cbf:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cc2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cc6:	0f 84 9d 02 00 00    	je     80100f69 <exec+0x3e9>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100ccc:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100cd2:	25 ff 0f 00 00       	and    $0xfff,%eax
80100cd7:	85 c0                	test   %eax,%eax
80100cd9:	0f 85 8d 02 00 00    	jne    80100f6c <exec+0x3ec>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100cdf:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100ce5:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100ceb:	8b 8d ec fe ff ff    	mov    -0x114(%ebp),%ecx
80100cf1:	83 ec 0c             	sub    $0xc,%esp
80100cf4:	52                   	push   %edx
80100cf5:	50                   	push   %eax
80100cf6:	ff 75 d8             	push   -0x28(%ebp)
80100cf9:	51                   	push   %ecx
80100cfa:	ff 75 d4             	push   -0x2c(%ebp)
80100cfd:	e8 df 69 00 00       	call   801076e1 <loaduvm>
80100d02:	83 c4 20             	add    $0x20,%esp
80100d05:	85 c0                	test   %eax,%eax
80100d07:	0f 88 62 02 00 00    	js     80100f6f <exec+0x3ef>
80100d0d:	eb 01                	jmp    80100d10 <exec+0x190>
      continue;
80100d0f:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d10:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d14:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d17:	83 c0 20             	add    $0x20,%eax
80100d1a:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d1d:	0f b7 85 30 ff ff ff 	movzwl -0xd0(%ebp),%eax
80100d24:	0f b7 c0             	movzwl %ax,%eax
80100d27:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d2a:	0f 8c 0f ff ff ff    	jl     80100c3f <exec+0xbf>
      goto bad;
  }
  iunlockput(ip);
80100d30:	83 ec 0c             	sub    $0xc,%esp
80100d33:	ff 75 d8             	push   -0x28(%ebp)
80100d36:	e8 d1 0e 00 00       	call   80101c0c <iunlockput>
80100d3b:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d3e:	e8 76 23 00 00       	call   801030b9 <end_op>
  ip = 0;
80100d43:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;
  */
 
  // Allocate Stack at the top address
  uint tmp = PGROUNDUP(sz);
80100d4a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d4d:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d52:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d57:	89 45 cc             	mov    %eax,-0x34(%ebp)
  sz = KERNBASE - PGSIZE;
80100d5a:	c7 45 e0 00 f0 ff 7f 	movl   $0x7ffff000,-0x20(%ebp)
  if ((sz = allocuvm(pgdir, sz, sz + PGSIZE)) == 0)
80100d61:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d64:	05 00 10 00 00       	add    $0x1000,%eax
80100d69:	83 ec 04             	sub    $0x4,%esp
80100d6c:	50                   	push   %eax
80100d6d:	ff 75 e0             	push   -0x20(%ebp)
80100d70:	ff 75 d4             	push   -0x2c(%ebp)
80100d73:	e8 36 6a 00 00       	call   801077ae <allocuvm>
80100d78:	83 c4 10             	add    $0x10,%esp
80100d7b:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d7e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d82:	0f 84 ea 01 00 00    	je     80100f72 <exec+0x3f2>
    goto bad; 
  sp = KERNBASE;
80100d88:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)


  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d8f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d96:	e9 96 00 00 00       	jmp    80100e31 <exec+0x2b1>
    if(argc >= MAXARG)
80100d9b:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d9f:	0f 87 d0 01 00 00    	ja     80100f75 <exec+0x3f5>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100da5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100da8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100daf:	8b 45 0c             	mov    0xc(%ebp),%eax
80100db2:	01 d0                	add    %edx,%eax
80100db4:	8b 00                	mov    (%eax),%eax
80100db6:	83 ec 0c             	sub    $0xc,%esp
80100db9:	50                   	push   %eax
80100dba:	e8 40 3f 00 00       	call   80104cff <strlen>
80100dbf:	83 c4 10             	add    $0x10,%esp
80100dc2:	89 c2                	mov    %eax,%edx
80100dc4:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dc7:	29 d0                	sub    %edx,%eax
80100dc9:	83 e8 01             	sub    $0x1,%eax
80100dcc:	83 e0 fc             	and    $0xfffffffc,%eax
80100dcf:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100dd2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dd5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ddc:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ddf:	01 d0                	add    %edx,%eax
80100de1:	8b 00                	mov    (%eax),%eax
80100de3:	83 ec 0c             	sub    $0xc,%esp
80100de6:	50                   	push   %eax
80100de7:	e8 13 3f 00 00       	call   80104cff <strlen>
80100dec:	83 c4 10             	add    $0x10,%esp
80100def:	83 c0 01             	add    $0x1,%eax
80100df2:	89 c2                	mov    %eax,%edx
80100df4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100df7:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100dfe:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e01:	01 c8                	add    %ecx,%eax
80100e03:	8b 00                	mov    (%eax),%eax
80100e05:	52                   	push   %edx
80100e06:	50                   	push   %eax
80100e07:	ff 75 dc             	push   -0x24(%ebp)
80100e0a:	ff 75 d4             	push   -0x2c(%ebp)
80100e0d:	e8 8a 6d 00 00       	call   80107b9c <copyout>
80100e12:	83 c4 10             	add    $0x10,%esp
80100e15:	85 c0                	test   %eax,%eax
80100e17:	0f 88 5b 01 00 00    	js     80100f78 <exec+0x3f8>
      goto bad;
    ustack[3+argc] = sp;
80100e1d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e20:	8d 50 03             	lea    0x3(%eax),%edx
80100e23:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e26:	89 84 95 38 ff ff ff 	mov    %eax,-0xc8(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e2d:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e34:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e3b:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e3e:	01 d0                	add    %edx,%eax
80100e40:	8b 00                	mov    (%eax),%eax
80100e42:	85 c0                	test   %eax,%eax
80100e44:	0f 85 51 ff ff ff    	jne    80100d9b <exec+0x21b>
  }
  ustack[3+argc] = 0;
80100e4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e4d:	83 c0 03             	add    $0x3,%eax
80100e50:	c7 84 85 38 ff ff ff 	movl   $0x0,-0xc8(%ebp,%eax,4)
80100e57:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e5b:	c7 85 38 ff ff ff ff 	movl   $0xffffffff,-0xc8(%ebp)
80100e62:	ff ff ff 
  ustack[1] = argc;
80100e65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e68:	89 85 3c ff ff ff    	mov    %eax,-0xc4(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e71:	83 c0 01             	add    $0x1,%eax
80100e74:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e7b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e7e:	29 d0                	sub    %edx,%eax
80100e80:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)

  sp -= (3+argc+1) * 4;
80100e86:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e89:	83 c0 04             	add    $0x4,%eax
80100e8c:	c1 e0 02             	shl    $0x2,%eax
80100e8f:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e95:	83 c0 04             	add    $0x4,%eax
80100e98:	c1 e0 02             	shl    $0x2,%eax
80100e9b:	50                   	push   %eax
80100e9c:	8d 85 38 ff ff ff    	lea    -0xc8(%ebp),%eax
80100ea2:	50                   	push   %eax
80100ea3:	ff 75 dc             	push   -0x24(%ebp)
80100ea6:	ff 75 d4             	push   -0x2c(%ebp)
80100ea9:	e8 ee 6c 00 00       	call   80107b9c <copyout>
80100eae:	83 c4 10             	add    $0x10,%esp
80100eb1:	85 c0                	test   %eax,%eax
80100eb3:	0f 88 c2 00 00 00    	js     80100f7b <exec+0x3fb>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100eb9:	8b 45 08             	mov    0x8(%ebp),%eax
80100ebc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100ebf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ec2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100ec5:	eb 17                	jmp    80100ede <exec+0x35e>
    if(*s == '/')
80100ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100eca:	0f b6 00             	movzbl (%eax),%eax
80100ecd:	3c 2f                	cmp    $0x2f,%al
80100ecf:	75 09                	jne    80100eda <exec+0x35a>
      last = s+1;
80100ed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ed4:	83 c0 01             	add    $0x1,%eax
80100ed7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100eda:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ede:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ee1:	0f b6 00             	movzbl (%eax),%eax
80100ee4:	84 c0                	test   %al,%al
80100ee6:	75 df                	jne    80100ec7 <exec+0x347>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100ee8:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100eeb:	83 c0 6c             	add    $0x6c,%eax
80100eee:	83 ec 04             	sub    $0x4,%esp
80100ef1:	6a 10                	push   $0x10
80100ef3:	ff 75 f0             	push   -0x10(%ebp)
80100ef6:	50                   	push   %eax
80100ef7:	e8 b8 3d 00 00       	call   80104cb4 <safestrcpy>
80100efc:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100eff:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f02:	8b 40 04             	mov    0x4(%eax),%eax
80100f05:	89 45 c8             	mov    %eax,-0x38(%ebp)
  curproc->pgdir = pgdir;
80100f08:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f0b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f0e:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = tmp;
80100f11:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f14:	8b 55 cc             	mov    -0x34(%ebp),%edx
80100f17:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f19:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f1c:	8b 40 18             	mov    0x18(%eax),%eax
80100f1f:	8b 95 1c ff ff ff    	mov    -0xe4(%ebp),%edx
80100f25:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f28:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f2b:	8b 40 18             	mov    0x18(%eax),%eax
80100f2e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f31:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f34:	83 ec 0c             	sub    $0xc,%esp
80100f37:	ff 75 d0             	push   -0x30(%ebp)
80100f3a:	e8 93 65 00 00       	call   801074d2 <switchuvm>
80100f3f:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f42:	83 ec 0c             	sub    $0xc,%esp
80100f45:	ff 75 c8             	push   -0x38(%ebp)
80100f48:	e8 2c 6a 00 00       	call   80107979 <freevm>
80100f4d:	83 c4 10             	add    $0x10,%esp

  return 0;
80100f50:	b8 00 00 00 00       	mov    $0x0,%eax
80100f55:	eb 57                	jmp    80100fae <exec+0x42e>
    goto bad;
80100f57:	90                   	nop
80100f58:	eb 22                	jmp    80100f7c <exec+0x3fc>
    goto bad;
80100f5a:	90                   	nop
80100f5b:	eb 1f                	jmp    80100f7c <exec+0x3fc>
    goto bad;
80100f5d:	90                   	nop
80100f5e:	eb 1c                	jmp    80100f7c <exec+0x3fc>
      goto bad;
80100f60:	90                   	nop
80100f61:	eb 19                	jmp    80100f7c <exec+0x3fc>
      goto bad;
80100f63:	90                   	nop
80100f64:	eb 16                	jmp    80100f7c <exec+0x3fc>
      goto bad;
80100f66:	90                   	nop
80100f67:	eb 13                	jmp    80100f7c <exec+0x3fc>
      goto bad;
80100f69:	90                   	nop
80100f6a:	eb 10                	jmp    80100f7c <exec+0x3fc>
      goto bad;
80100f6c:	90                   	nop
80100f6d:	eb 0d                	jmp    80100f7c <exec+0x3fc>
      goto bad;
80100f6f:	90                   	nop
80100f70:	eb 0a                	jmp    80100f7c <exec+0x3fc>
    goto bad; 
80100f72:	90                   	nop
80100f73:	eb 07                	jmp    80100f7c <exec+0x3fc>
      goto bad;
80100f75:	90                   	nop
80100f76:	eb 04                	jmp    80100f7c <exec+0x3fc>
      goto bad;
80100f78:	90                   	nop
80100f79:	eb 01                	jmp    80100f7c <exec+0x3fc>
    goto bad;
80100f7b:	90                   	nop

 bad:
  if(pgdir)
80100f7c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f80:	74 0e                	je     80100f90 <exec+0x410>
    freevm(pgdir);
80100f82:	83 ec 0c             	sub    $0xc,%esp
80100f85:	ff 75 d4             	push   -0x2c(%ebp)
80100f88:	e8 ec 69 00 00       	call   80107979 <freevm>
80100f8d:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f90:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f94:	74 13                	je     80100fa9 <exec+0x429>
    iunlockput(ip);
80100f96:	83 ec 0c             	sub    $0xc,%esp
80100f99:	ff 75 d8             	push   -0x28(%ebp)
80100f9c:	e8 6b 0c 00 00       	call   80101c0c <iunlockput>
80100fa1:	83 c4 10             	add    $0x10,%esp
    end_op();
80100fa4:	e8 10 21 00 00       	call   801030b9 <end_op>
  }
  return -1;
80100fa9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fae:	c9                   	leave  
80100faf:	c3                   	ret    

80100fb0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fb0:	55                   	push   %ebp
80100fb1:	89 e5                	mov    %esp,%ebp
80100fb3:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100fb6:	83 ec 08             	sub    $0x8,%esp
80100fb9:	68 61 a1 10 80       	push   $0x8010a161
80100fbe:	68 a0 1a 19 80       	push   $0x80191aa0
80100fc3:	e8 51 38 00 00       	call   80104819 <initlock>
80100fc8:	83 c4 10             	add    $0x10,%esp
}
80100fcb:	90                   	nop
80100fcc:	c9                   	leave  
80100fcd:	c3                   	ret    

80100fce <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fce:	55                   	push   %ebp
80100fcf:	89 e5                	mov    %esp,%ebp
80100fd1:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fd4:	83 ec 0c             	sub    $0xc,%esp
80100fd7:	68 a0 1a 19 80       	push   $0x80191aa0
80100fdc:	e8 5a 38 00 00       	call   8010483b <acquire>
80100fe1:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fe4:	c7 45 f4 d4 1a 19 80 	movl   $0x80191ad4,-0xc(%ebp)
80100feb:	eb 2d                	jmp    8010101a <filealloc+0x4c>
    if(f->ref == 0){
80100fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ff0:	8b 40 04             	mov    0x4(%eax),%eax
80100ff3:	85 c0                	test   %eax,%eax
80100ff5:	75 1f                	jne    80101016 <filealloc+0x48>
      f->ref = 1;
80100ff7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ffa:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101001:	83 ec 0c             	sub    $0xc,%esp
80101004:	68 a0 1a 19 80       	push   $0x80191aa0
80101009:	e8 9b 38 00 00       	call   801048a9 <release>
8010100e:	83 c4 10             	add    $0x10,%esp
      return f;
80101011:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101014:	eb 23                	jmp    80101039 <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101016:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
8010101a:	b8 34 24 19 80       	mov    $0x80192434,%eax
8010101f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101022:	72 c9                	jb     80100fed <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
80101024:	83 ec 0c             	sub    $0xc,%esp
80101027:	68 a0 1a 19 80       	push   $0x80191aa0
8010102c:	e8 78 38 00 00       	call   801048a9 <release>
80101031:	83 c4 10             	add    $0x10,%esp
  return 0;
80101034:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101039:	c9                   	leave  
8010103a:	c3                   	ret    

8010103b <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010103b:	55                   	push   %ebp
8010103c:	89 e5                	mov    %esp,%ebp
8010103e:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101041:	83 ec 0c             	sub    $0xc,%esp
80101044:	68 a0 1a 19 80       	push   $0x80191aa0
80101049:	e8 ed 37 00 00       	call   8010483b <acquire>
8010104e:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101051:	8b 45 08             	mov    0x8(%ebp),%eax
80101054:	8b 40 04             	mov    0x4(%eax),%eax
80101057:	85 c0                	test   %eax,%eax
80101059:	7f 0d                	jg     80101068 <filedup+0x2d>
    panic("filedup");
8010105b:	83 ec 0c             	sub    $0xc,%esp
8010105e:	68 68 a1 10 80       	push   $0x8010a168
80101063:	e8 41 f5 ff ff       	call   801005a9 <panic>
  f->ref++;
80101068:	8b 45 08             	mov    0x8(%ebp),%eax
8010106b:	8b 40 04             	mov    0x4(%eax),%eax
8010106e:	8d 50 01             	lea    0x1(%eax),%edx
80101071:	8b 45 08             	mov    0x8(%ebp),%eax
80101074:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101077:	83 ec 0c             	sub    $0xc,%esp
8010107a:	68 a0 1a 19 80       	push   $0x80191aa0
8010107f:	e8 25 38 00 00       	call   801048a9 <release>
80101084:	83 c4 10             	add    $0x10,%esp
  return f;
80101087:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010108a:	c9                   	leave  
8010108b:	c3                   	ret    

8010108c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010108c:	55                   	push   %ebp
8010108d:	89 e5                	mov    %esp,%ebp
8010108f:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101092:	83 ec 0c             	sub    $0xc,%esp
80101095:	68 a0 1a 19 80       	push   $0x80191aa0
8010109a:	e8 9c 37 00 00       	call   8010483b <acquire>
8010109f:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010a2:	8b 45 08             	mov    0x8(%ebp),%eax
801010a5:	8b 40 04             	mov    0x4(%eax),%eax
801010a8:	85 c0                	test   %eax,%eax
801010aa:	7f 0d                	jg     801010b9 <fileclose+0x2d>
    panic("fileclose");
801010ac:	83 ec 0c             	sub    $0xc,%esp
801010af:	68 70 a1 10 80       	push   $0x8010a170
801010b4:	e8 f0 f4 ff ff       	call   801005a9 <panic>
  if(--f->ref > 0){
801010b9:	8b 45 08             	mov    0x8(%ebp),%eax
801010bc:	8b 40 04             	mov    0x4(%eax),%eax
801010bf:	8d 50 ff             	lea    -0x1(%eax),%edx
801010c2:	8b 45 08             	mov    0x8(%ebp),%eax
801010c5:	89 50 04             	mov    %edx,0x4(%eax)
801010c8:	8b 45 08             	mov    0x8(%ebp),%eax
801010cb:	8b 40 04             	mov    0x4(%eax),%eax
801010ce:	85 c0                	test   %eax,%eax
801010d0:	7e 15                	jle    801010e7 <fileclose+0x5b>
    release(&ftable.lock);
801010d2:	83 ec 0c             	sub    $0xc,%esp
801010d5:	68 a0 1a 19 80       	push   $0x80191aa0
801010da:	e8 ca 37 00 00       	call   801048a9 <release>
801010df:	83 c4 10             	add    $0x10,%esp
801010e2:	e9 8b 00 00 00       	jmp    80101172 <fileclose+0xe6>
    return;
  }
  ff = *f;
801010e7:	8b 45 08             	mov    0x8(%ebp),%eax
801010ea:	8b 10                	mov    (%eax),%edx
801010ec:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010ef:	8b 50 04             	mov    0x4(%eax),%edx
801010f2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801010f5:	8b 50 08             	mov    0x8(%eax),%edx
801010f8:	89 55 e8             	mov    %edx,-0x18(%ebp)
801010fb:	8b 50 0c             	mov    0xc(%eax),%edx
801010fe:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101101:	8b 50 10             	mov    0x10(%eax),%edx
80101104:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101107:	8b 40 14             	mov    0x14(%eax),%eax
8010110a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010110d:	8b 45 08             	mov    0x8(%ebp),%eax
80101110:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101117:	8b 45 08             	mov    0x8(%ebp),%eax
8010111a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101120:	83 ec 0c             	sub    $0xc,%esp
80101123:	68 a0 1a 19 80       	push   $0x80191aa0
80101128:	e8 7c 37 00 00       	call   801048a9 <release>
8010112d:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
80101130:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101133:	83 f8 01             	cmp    $0x1,%eax
80101136:	75 19                	jne    80101151 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
80101138:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010113c:	0f be d0             	movsbl %al,%edx
8010113f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101142:	83 ec 08             	sub    $0x8,%esp
80101145:	52                   	push   %edx
80101146:	50                   	push   %eax
80101147:	e8 64 25 00 00       	call   801036b0 <pipeclose>
8010114c:	83 c4 10             	add    $0x10,%esp
8010114f:	eb 21                	jmp    80101172 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101151:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101154:	83 f8 02             	cmp    $0x2,%eax
80101157:	75 19                	jne    80101172 <fileclose+0xe6>
    begin_op();
80101159:	e8 cf 1e 00 00       	call   8010302d <begin_op>
    iput(ff.ip);
8010115e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101161:	83 ec 0c             	sub    $0xc,%esp
80101164:	50                   	push   %eax
80101165:	e8 d2 09 00 00       	call   80101b3c <iput>
8010116a:	83 c4 10             	add    $0x10,%esp
    end_op();
8010116d:	e8 47 1f 00 00       	call   801030b9 <end_op>
  }
}
80101172:	c9                   	leave  
80101173:	c3                   	ret    

80101174 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101174:	55                   	push   %ebp
80101175:	89 e5                	mov    %esp,%ebp
80101177:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
8010117a:	8b 45 08             	mov    0x8(%ebp),%eax
8010117d:	8b 00                	mov    (%eax),%eax
8010117f:	83 f8 02             	cmp    $0x2,%eax
80101182:	75 40                	jne    801011c4 <filestat+0x50>
    ilock(f->ip);
80101184:	8b 45 08             	mov    0x8(%ebp),%eax
80101187:	8b 40 10             	mov    0x10(%eax),%eax
8010118a:	83 ec 0c             	sub    $0xc,%esp
8010118d:	50                   	push   %eax
8010118e:	e8 48 08 00 00       	call   801019db <ilock>
80101193:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
80101196:	8b 45 08             	mov    0x8(%ebp),%eax
80101199:	8b 40 10             	mov    0x10(%eax),%eax
8010119c:	83 ec 08             	sub    $0x8,%esp
8010119f:	ff 75 0c             	push   0xc(%ebp)
801011a2:	50                   	push   %eax
801011a3:	e8 d9 0c 00 00       	call   80101e81 <stati>
801011a8:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801011ab:	8b 45 08             	mov    0x8(%ebp),%eax
801011ae:	8b 40 10             	mov    0x10(%eax),%eax
801011b1:	83 ec 0c             	sub    $0xc,%esp
801011b4:	50                   	push   %eax
801011b5:	e8 34 09 00 00       	call   80101aee <iunlock>
801011ba:	83 c4 10             	add    $0x10,%esp
    return 0;
801011bd:	b8 00 00 00 00       	mov    $0x0,%eax
801011c2:	eb 05                	jmp    801011c9 <filestat+0x55>
  }
  return -1;
801011c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011c9:	c9                   	leave  
801011ca:	c3                   	ret    

801011cb <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011cb:	55                   	push   %ebp
801011cc:	89 e5                	mov    %esp,%ebp
801011ce:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801011d1:	8b 45 08             	mov    0x8(%ebp),%eax
801011d4:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011d8:	84 c0                	test   %al,%al
801011da:	75 0a                	jne    801011e6 <fileread+0x1b>
    return -1;
801011dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011e1:	e9 9b 00 00 00       	jmp    80101281 <fileread+0xb6>
  if(f->type == FD_PIPE)
801011e6:	8b 45 08             	mov    0x8(%ebp),%eax
801011e9:	8b 00                	mov    (%eax),%eax
801011eb:	83 f8 01             	cmp    $0x1,%eax
801011ee:	75 1a                	jne    8010120a <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801011f0:	8b 45 08             	mov    0x8(%ebp),%eax
801011f3:	8b 40 0c             	mov    0xc(%eax),%eax
801011f6:	83 ec 04             	sub    $0x4,%esp
801011f9:	ff 75 10             	push   0x10(%ebp)
801011fc:	ff 75 0c             	push   0xc(%ebp)
801011ff:	50                   	push   %eax
80101200:	e8 58 26 00 00       	call   8010385d <piperead>
80101205:	83 c4 10             	add    $0x10,%esp
80101208:	eb 77                	jmp    80101281 <fileread+0xb6>
  if(f->type == FD_INODE){
8010120a:	8b 45 08             	mov    0x8(%ebp),%eax
8010120d:	8b 00                	mov    (%eax),%eax
8010120f:	83 f8 02             	cmp    $0x2,%eax
80101212:	75 60                	jne    80101274 <fileread+0xa9>
    ilock(f->ip);
80101214:	8b 45 08             	mov    0x8(%ebp),%eax
80101217:	8b 40 10             	mov    0x10(%eax),%eax
8010121a:	83 ec 0c             	sub    $0xc,%esp
8010121d:	50                   	push   %eax
8010121e:	e8 b8 07 00 00       	call   801019db <ilock>
80101223:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101226:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101229:	8b 45 08             	mov    0x8(%ebp),%eax
8010122c:	8b 50 14             	mov    0x14(%eax),%edx
8010122f:	8b 45 08             	mov    0x8(%ebp),%eax
80101232:	8b 40 10             	mov    0x10(%eax),%eax
80101235:	51                   	push   %ecx
80101236:	52                   	push   %edx
80101237:	ff 75 0c             	push   0xc(%ebp)
8010123a:	50                   	push   %eax
8010123b:	e8 87 0c 00 00       	call   80101ec7 <readi>
80101240:	83 c4 10             	add    $0x10,%esp
80101243:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101246:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010124a:	7e 11                	jle    8010125d <fileread+0x92>
      f->off += r;
8010124c:	8b 45 08             	mov    0x8(%ebp),%eax
8010124f:	8b 50 14             	mov    0x14(%eax),%edx
80101252:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101255:	01 c2                	add    %eax,%edx
80101257:	8b 45 08             	mov    0x8(%ebp),%eax
8010125a:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010125d:	8b 45 08             	mov    0x8(%ebp),%eax
80101260:	8b 40 10             	mov    0x10(%eax),%eax
80101263:	83 ec 0c             	sub    $0xc,%esp
80101266:	50                   	push   %eax
80101267:	e8 82 08 00 00       	call   80101aee <iunlock>
8010126c:	83 c4 10             	add    $0x10,%esp
    return r;
8010126f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101272:	eb 0d                	jmp    80101281 <fileread+0xb6>
  }
  panic("fileread");
80101274:	83 ec 0c             	sub    $0xc,%esp
80101277:	68 7a a1 10 80       	push   $0x8010a17a
8010127c:	e8 28 f3 ff ff       	call   801005a9 <panic>
}
80101281:	c9                   	leave  
80101282:	c3                   	ret    

80101283 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101283:	55                   	push   %ebp
80101284:	89 e5                	mov    %esp,%ebp
80101286:	53                   	push   %ebx
80101287:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
8010128a:	8b 45 08             	mov    0x8(%ebp),%eax
8010128d:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101291:	84 c0                	test   %al,%al
80101293:	75 0a                	jne    8010129f <filewrite+0x1c>
    return -1;
80101295:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010129a:	e9 1b 01 00 00       	jmp    801013ba <filewrite+0x137>
  if(f->type == FD_PIPE)
8010129f:	8b 45 08             	mov    0x8(%ebp),%eax
801012a2:	8b 00                	mov    (%eax),%eax
801012a4:	83 f8 01             	cmp    $0x1,%eax
801012a7:	75 1d                	jne    801012c6 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
801012a9:	8b 45 08             	mov    0x8(%ebp),%eax
801012ac:	8b 40 0c             	mov    0xc(%eax),%eax
801012af:	83 ec 04             	sub    $0x4,%esp
801012b2:	ff 75 10             	push   0x10(%ebp)
801012b5:	ff 75 0c             	push   0xc(%ebp)
801012b8:	50                   	push   %eax
801012b9:	e8 9d 24 00 00       	call   8010375b <pipewrite>
801012be:	83 c4 10             	add    $0x10,%esp
801012c1:	e9 f4 00 00 00       	jmp    801013ba <filewrite+0x137>
  if(f->type == FD_INODE){
801012c6:	8b 45 08             	mov    0x8(%ebp),%eax
801012c9:	8b 00                	mov    (%eax),%eax
801012cb:	83 f8 02             	cmp    $0x2,%eax
801012ce:	0f 85 d9 00 00 00    	jne    801013ad <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801012d4:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801012db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012e2:	e9 a3 00 00 00       	jmp    8010138a <filewrite+0x107>
      int n1 = n - i;
801012e7:	8b 45 10             	mov    0x10(%ebp),%eax
801012ea:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801012f3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801012f6:	7e 06                	jle    801012fe <filewrite+0x7b>
        n1 = max;
801012f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801012fb:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801012fe:	e8 2a 1d 00 00       	call   8010302d <begin_op>
      ilock(f->ip);
80101303:	8b 45 08             	mov    0x8(%ebp),%eax
80101306:	8b 40 10             	mov    0x10(%eax),%eax
80101309:	83 ec 0c             	sub    $0xc,%esp
8010130c:	50                   	push   %eax
8010130d:	e8 c9 06 00 00       	call   801019db <ilock>
80101312:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101315:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101318:	8b 45 08             	mov    0x8(%ebp),%eax
8010131b:	8b 50 14             	mov    0x14(%eax),%edx
8010131e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101321:	8b 45 0c             	mov    0xc(%ebp),%eax
80101324:	01 c3                	add    %eax,%ebx
80101326:	8b 45 08             	mov    0x8(%ebp),%eax
80101329:	8b 40 10             	mov    0x10(%eax),%eax
8010132c:	51                   	push   %ecx
8010132d:	52                   	push   %edx
8010132e:	53                   	push   %ebx
8010132f:	50                   	push   %eax
80101330:	e8 e7 0c 00 00       	call   8010201c <writei>
80101335:	83 c4 10             	add    $0x10,%esp
80101338:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010133b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010133f:	7e 11                	jle    80101352 <filewrite+0xcf>
        f->off += r;
80101341:	8b 45 08             	mov    0x8(%ebp),%eax
80101344:	8b 50 14             	mov    0x14(%eax),%edx
80101347:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010134a:	01 c2                	add    %eax,%edx
8010134c:	8b 45 08             	mov    0x8(%ebp),%eax
8010134f:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101352:	8b 45 08             	mov    0x8(%ebp),%eax
80101355:	8b 40 10             	mov    0x10(%eax),%eax
80101358:	83 ec 0c             	sub    $0xc,%esp
8010135b:	50                   	push   %eax
8010135c:	e8 8d 07 00 00       	call   80101aee <iunlock>
80101361:	83 c4 10             	add    $0x10,%esp
      end_op();
80101364:	e8 50 1d 00 00       	call   801030b9 <end_op>

      if(r < 0)
80101369:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010136d:	78 29                	js     80101398 <filewrite+0x115>
        break;
      if(r != n1)
8010136f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101372:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101375:	74 0d                	je     80101384 <filewrite+0x101>
        panic("short filewrite");
80101377:	83 ec 0c             	sub    $0xc,%esp
8010137a:	68 83 a1 10 80       	push   $0x8010a183
8010137f:	e8 25 f2 ff ff       	call   801005a9 <panic>
      i += r;
80101384:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101387:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
8010138a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010138d:	3b 45 10             	cmp    0x10(%ebp),%eax
80101390:	0f 8c 51 ff ff ff    	jl     801012e7 <filewrite+0x64>
80101396:	eb 01                	jmp    80101399 <filewrite+0x116>
        break;
80101398:	90                   	nop
    }
    return i == n ? n : -1;
80101399:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010139c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010139f:	75 05                	jne    801013a6 <filewrite+0x123>
801013a1:	8b 45 10             	mov    0x10(%ebp),%eax
801013a4:	eb 14                	jmp    801013ba <filewrite+0x137>
801013a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013ab:	eb 0d                	jmp    801013ba <filewrite+0x137>
  }
  panic("filewrite");
801013ad:	83 ec 0c             	sub    $0xc,%esp
801013b0:	68 93 a1 10 80       	push   $0x8010a193
801013b5:	e8 ef f1 ff ff       	call   801005a9 <panic>
}
801013ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013bd:	c9                   	leave  
801013be:	c3                   	ret    

801013bf <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013bf:	55                   	push   %ebp
801013c0:	89 e5                	mov    %esp,%ebp
801013c2:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801013c5:	8b 45 08             	mov    0x8(%ebp),%eax
801013c8:	83 ec 08             	sub    $0x8,%esp
801013cb:	6a 01                	push   $0x1
801013cd:	50                   	push   %eax
801013ce:	e8 2e ee ff ff       	call   80100201 <bread>
801013d3:	83 c4 10             	add    $0x10,%esp
801013d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013dc:	83 c0 5c             	add    $0x5c,%eax
801013df:	83 ec 04             	sub    $0x4,%esp
801013e2:	6a 1c                	push   $0x1c
801013e4:	50                   	push   %eax
801013e5:	ff 75 0c             	push   0xc(%ebp)
801013e8:	e8 83 37 00 00       	call   80104b70 <memmove>
801013ed:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013f0:	83 ec 0c             	sub    $0xc,%esp
801013f3:	ff 75 f4             	push   -0xc(%ebp)
801013f6:	e8 88 ee ff ff       	call   80100283 <brelse>
801013fb:	83 c4 10             	add    $0x10,%esp
}
801013fe:	90                   	nop
801013ff:	c9                   	leave  
80101400:	c3                   	ret    

80101401 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101401:	55                   	push   %ebp
80101402:	89 e5                	mov    %esp,%ebp
80101404:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101407:	8b 55 0c             	mov    0xc(%ebp),%edx
8010140a:	8b 45 08             	mov    0x8(%ebp),%eax
8010140d:	83 ec 08             	sub    $0x8,%esp
80101410:	52                   	push   %edx
80101411:	50                   	push   %eax
80101412:	e8 ea ed ff ff       	call   80100201 <bread>
80101417:	83 c4 10             	add    $0x10,%esp
8010141a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010141d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101420:	83 c0 5c             	add    $0x5c,%eax
80101423:	83 ec 04             	sub    $0x4,%esp
80101426:	68 00 02 00 00       	push   $0x200
8010142b:	6a 00                	push   $0x0
8010142d:	50                   	push   %eax
8010142e:	e8 7e 36 00 00       	call   80104ab1 <memset>
80101433:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101436:	83 ec 0c             	sub    $0xc,%esp
80101439:	ff 75 f4             	push   -0xc(%ebp)
8010143c:	e8 25 1e 00 00       	call   80103266 <log_write>
80101441:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101444:	83 ec 0c             	sub    $0xc,%esp
80101447:	ff 75 f4             	push   -0xc(%ebp)
8010144a:	e8 34 ee ff ff       	call   80100283 <brelse>
8010144f:	83 c4 10             	add    $0x10,%esp
}
80101452:	90                   	nop
80101453:	c9                   	leave  
80101454:	c3                   	ret    

80101455 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101455:	55                   	push   %ebp
80101456:	89 e5                	mov    %esp,%ebp
80101458:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
8010145b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101462:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101469:	e9 0b 01 00 00       	jmp    80101579 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
8010146e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101471:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101477:	85 c0                	test   %eax,%eax
80101479:	0f 48 c2             	cmovs  %edx,%eax
8010147c:	c1 f8 0c             	sar    $0xc,%eax
8010147f:	89 c2                	mov    %eax,%edx
80101481:	a1 58 24 19 80       	mov    0x80192458,%eax
80101486:	01 d0                	add    %edx,%eax
80101488:	83 ec 08             	sub    $0x8,%esp
8010148b:	50                   	push   %eax
8010148c:	ff 75 08             	push   0x8(%ebp)
8010148f:	e8 6d ed ff ff       	call   80100201 <bread>
80101494:	83 c4 10             	add    $0x10,%esp
80101497:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010149a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801014a1:	e9 9e 00 00 00       	jmp    80101544 <balloc+0xef>
      m = 1 << (bi % 8);
801014a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014a9:	83 e0 07             	and    $0x7,%eax
801014ac:	ba 01 00 00 00       	mov    $0x1,%edx
801014b1:	89 c1                	mov    %eax,%ecx
801014b3:	d3 e2                	shl    %cl,%edx
801014b5:	89 d0                	mov    %edx,%eax
801014b7:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014bd:	8d 50 07             	lea    0x7(%eax),%edx
801014c0:	85 c0                	test   %eax,%eax
801014c2:	0f 48 c2             	cmovs  %edx,%eax
801014c5:	c1 f8 03             	sar    $0x3,%eax
801014c8:	89 c2                	mov    %eax,%edx
801014ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014cd:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801014d2:	0f b6 c0             	movzbl %al,%eax
801014d5:	23 45 e8             	and    -0x18(%ebp),%eax
801014d8:	85 c0                	test   %eax,%eax
801014da:	75 64                	jne    80101540 <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
801014dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014df:	8d 50 07             	lea    0x7(%eax),%edx
801014e2:	85 c0                	test   %eax,%eax
801014e4:	0f 48 c2             	cmovs  %edx,%eax
801014e7:	c1 f8 03             	sar    $0x3,%eax
801014ea:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014ed:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801014f2:	89 d1                	mov    %edx,%ecx
801014f4:	8b 55 e8             	mov    -0x18(%ebp),%edx
801014f7:	09 ca                	or     %ecx,%edx
801014f9:	89 d1                	mov    %edx,%ecx
801014fb:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014fe:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101502:	83 ec 0c             	sub    $0xc,%esp
80101505:	ff 75 ec             	push   -0x14(%ebp)
80101508:	e8 59 1d 00 00       	call   80103266 <log_write>
8010150d:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101510:	83 ec 0c             	sub    $0xc,%esp
80101513:	ff 75 ec             	push   -0x14(%ebp)
80101516:	e8 68 ed ff ff       	call   80100283 <brelse>
8010151b:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010151e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101521:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101524:	01 c2                	add    %eax,%edx
80101526:	8b 45 08             	mov    0x8(%ebp),%eax
80101529:	83 ec 08             	sub    $0x8,%esp
8010152c:	52                   	push   %edx
8010152d:	50                   	push   %eax
8010152e:	e8 ce fe ff ff       	call   80101401 <bzero>
80101533:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101536:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101539:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010153c:	01 d0                	add    %edx,%eax
8010153e:	eb 57                	jmp    80101597 <balloc+0x142>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101540:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101544:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010154b:	7f 17                	jg     80101564 <balloc+0x10f>
8010154d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101550:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101553:	01 d0                	add    %edx,%eax
80101555:	89 c2                	mov    %eax,%edx
80101557:	a1 40 24 19 80       	mov    0x80192440,%eax
8010155c:	39 c2                	cmp    %eax,%edx
8010155e:	0f 82 42 ff ff ff    	jb     801014a6 <balloc+0x51>
      }
    }
    brelse(bp);
80101564:	83 ec 0c             	sub    $0xc,%esp
80101567:	ff 75 ec             	push   -0x14(%ebp)
8010156a:	e8 14 ed ff ff       	call   80100283 <brelse>
8010156f:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
80101572:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101579:	8b 15 40 24 19 80    	mov    0x80192440,%edx
8010157f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101582:	39 c2                	cmp    %eax,%edx
80101584:	0f 87 e4 fe ff ff    	ja     8010146e <balloc+0x19>
  }
  panic("balloc: out of blocks");
8010158a:	83 ec 0c             	sub    $0xc,%esp
8010158d:	68 a0 a1 10 80       	push   $0x8010a1a0
80101592:	e8 12 f0 ff ff       	call   801005a9 <panic>
}
80101597:	c9                   	leave  
80101598:	c3                   	ret    

80101599 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101599:	55                   	push   %ebp
8010159a:	89 e5                	mov    %esp,%ebp
8010159c:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
8010159f:	83 ec 08             	sub    $0x8,%esp
801015a2:	68 40 24 19 80       	push   $0x80192440
801015a7:	ff 75 08             	push   0x8(%ebp)
801015aa:	e8 10 fe ff ff       	call   801013bf <readsb>
801015af:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801015b5:	c1 e8 0c             	shr    $0xc,%eax
801015b8:	89 c2                	mov    %eax,%edx
801015ba:	a1 58 24 19 80       	mov    0x80192458,%eax
801015bf:	01 c2                	add    %eax,%edx
801015c1:	8b 45 08             	mov    0x8(%ebp),%eax
801015c4:	83 ec 08             	sub    $0x8,%esp
801015c7:	52                   	push   %edx
801015c8:	50                   	push   %eax
801015c9:	e8 33 ec ff ff       	call   80100201 <bread>
801015ce:	83 c4 10             	add    $0x10,%esp
801015d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801015d7:	25 ff 0f 00 00       	and    $0xfff,%eax
801015dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015e2:	83 e0 07             	and    $0x7,%eax
801015e5:	ba 01 00 00 00       	mov    $0x1,%edx
801015ea:	89 c1                	mov    %eax,%ecx
801015ec:	d3 e2                	shl    %cl,%edx
801015ee:	89 d0                	mov    %edx,%eax
801015f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801015f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015f6:	8d 50 07             	lea    0x7(%eax),%edx
801015f9:	85 c0                	test   %eax,%eax
801015fb:	0f 48 c2             	cmovs  %edx,%eax
801015fe:	c1 f8 03             	sar    $0x3,%eax
80101601:	89 c2                	mov    %eax,%edx
80101603:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101606:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
8010160b:	0f b6 c0             	movzbl %al,%eax
8010160e:	23 45 ec             	and    -0x14(%ebp),%eax
80101611:	85 c0                	test   %eax,%eax
80101613:	75 0d                	jne    80101622 <bfree+0x89>
    panic("freeing free block");
80101615:	83 ec 0c             	sub    $0xc,%esp
80101618:	68 b6 a1 10 80       	push   $0x8010a1b6
8010161d:	e8 87 ef ff ff       	call   801005a9 <panic>
  bp->data[bi/8] &= ~m;
80101622:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101625:	8d 50 07             	lea    0x7(%eax),%edx
80101628:	85 c0                	test   %eax,%eax
8010162a:	0f 48 c2             	cmovs  %edx,%eax
8010162d:	c1 f8 03             	sar    $0x3,%eax
80101630:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101633:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101638:	89 d1                	mov    %edx,%ecx
8010163a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010163d:	f7 d2                	not    %edx
8010163f:	21 ca                	and    %ecx,%edx
80101641:	89 d1                	mov    %edx,%ecx
80101643:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101646:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
8010164a:	83 ec 0c             	sub    $0xc,%esp
8010164d:	ff 75 f4             	push   -0xc(%ebp)
80101650:	e8 11 1c 00 00       	call   80103266 <log_write>
80101655:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101658:	83 ec 0c             	sub    $0xc,%esp
8010165b:	ff 75 f4             	push   -0xc(%ebp)
8010165e:	e8 20 ec ff ff       	call   80100283 <brelse>
80101663:	83 c4 10             	add    $0x10,%esp
}
80101666:	90                   	nop
80101667:	c9                   	leave  
80101668:	c3                   	ret    

80101669 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101669:	55                   	push   %ebp
8010166a:	89 e5                	mov    %esp,%ebp
8010166c:	57                   	push   %edi
8010166d:	56                   	push   %esi
8010166e:	53                   	push   %ebx
8010166f:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
80101672:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101679:	83 ec 08             	sub    $0x8,%esp
8010167c:	68 c9 a1 10 80       	push   $0x8010a1c9
80101681:	68 60 24 19 80       	push   $0x80192460
80101686:	e8 8e 31 00 00       	call   80104819 <initlock>
8010168b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
8010168e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101695:	eb 2d                	jmp    801016c4 <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
80101697:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010169a:	89 d0                	mov    %edx,%eax
8010169c:	c1 e0 03             	shl    $0x3,%eax
8010169f:	01 d0                	add    %edx,%eax
801016a1:	c1 e0 04             	shl    $0x4,%eax
801016a4:	83 c0 30             	add    $0x30,%eax
801016a7:	05 60 24 19 80       	add    $0x80192460,%eax
801016ac:	83 c0 10             	add    $0x10,%eax
801016af:	83 ec 08             	sub    $0x8,%esp
801016b2:	68 d0 a1 10 80       	push   $0x8010a1d0
801016b7:	50                   	push   %eax
801016b8:	e8 ff 2f 00 00       	call   801046bc <initsleeplock>
801016bd:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016c0:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801016c4:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016c8:	7e cd                	jle    80101697 <iinit+0x2e>
  }

  readsb(dev, &sb);
801016ca:	83 ec 08             	sub    $0x8,%esp
801016cd:	68 40 24 19 80       	push   $0x80192440
801016d2:	ff 75 08             	push   0x8(%ebp)
801016d5:	e8 e5 fc ff ff       	call   801013bf <readsb>
801016da:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016dd:	a1 58 24 19 80       	mov    0x80192458,%eax
801016e2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801016e5:	8b 3d 54 24 19 80    	mov    0x80192454,%edi
801016eb:	8b 35 50 24 19 80    	mov    0x80192450,%esi
801016f1:	8b 1d 4c 24 19 80    	mov    0x8019244c,%ebx
801016f7:	8b 0d 48 24 19 80    	mov    0x80192448,%ecx
801016fd:	8b 15 44 24 19 80    	mov    0x80192444,%edx
80101703:	a1 40 24 19 80       	mov    0x80192440,%eax
80101708:	ff 75 d4             	push   -0x2c(%ebp)
8010170b:	57                   	push   %edi
8010170c:	56                   	push   %esi
8010170d:	53                   	push   %ebx
8010170e:	51                   	push   %ecx
8010170f:	52                   	push   %edx
80101710:	50                   	push   %eax
80101711:	68 d8 a1 10 80       	push   $0x8010a1d8
80101716:	e8 d9 ec ff ff       	call   801003f4 <cprintf>
8010171b:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
8010171e:	90                   	nop
8010171f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101722:	5b                   	pop    %ebx
80101723:	5e                   	pop    %esi
80101724:	5f                   	pop    %edi
80101725:	5d                   	pop    %ebp
80101726:	c3                   	ret    

80101727 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101727:	55                   	push   %ebp
80101728:	89 e5                	mov    %esp,%ebp
8010172a:	83 ec 28             	sub    $0x28,%esp
8010172d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101730:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101734:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010173b:	e9 9e 00 00 00       	jmp    801017de <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
80101740:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101743:	c1 e8 03             	shr    $0x3,%eax
80101746:	89 c2                	mov    %eax,%edx
80101748:	a1 54 24 19 80       	mov    0x80192454,%eax
8010174d:	01 d0                	add    %edx,%eax
8010174f:	83 ec 08             	sub    $0x8,%esp
80101752:	50                   	push   %eax
80101753:	ff 75 08             	push   0x8(%ebp)
80101756:	e8 a6 ea ff ff       	call   80100201 <bread>
8010175b:	83 c4 10             	add    $0x10,%esp
8010175e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101761:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101764:	8d 50 5c             	lea    0x5c(%eax),%edx
80101767:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010176a:	83 e0 07             	and    $0x7,%eax
8010176d:	c1 e0 06             	shl    $0x6,%eax
80101770:	01 d0                	add    %edx,%eax
80101772:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101775:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101778:	0f b7 00             	movzwl (%eax),%eax
8010177b:	66 85 c0             	test   %ax,%ax
8010177e:	75 4c                	jne    801017cc <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
80101780:	83 ec 04             	sub    $0x4,%esp
80101783:	6a 40                	push   $0x40
80101785:	6a 00                	push   $0x0
80101787:	ff 75 ec             	push   -0x14(%ebp)
8010178a:	e8 22 33 00 00       	call   80104ab1 <memset>
8010178f:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101792:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101795:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
80101799:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
8010179c:	83 ec 0c             	sub    $0xc,%esp
8010179f:	ff 75 f0             	push   -0x10(%ebp)
801017a2:	e8 bf 1a 00 00       	call   80103266 <log_write>
801017a7:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017aa:	83 ec 0c             	sub    $0xc,%esp
801017ad:	ff 75 f0             	push   -0x10(%ebp)
801017b0:	e8 ce ea ff ff       	call   80100283 <brelse>
801017b5:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017bb:	83 ec 08             	sub    $0x8,%esp
801017be:	50                   	push   %eax
801017bf:	ff 75 08             	push   0x8(%ebp)
801017c2:	e8 f8 00 00 00       	call   801018bf <iget>
801017c7:	83 c4 10             	add    $0x10,%esp
801017ca:	eb 30                	jmp    801017fc <ialloc+0xd5>
    }
    brelse(bp);
801017cc:	83 ec 0c             	sub    $0xc,%esp
801017cf:	ff 75 f0             	push   -0x10(%ebp)
801017d2:	e8 ac ea ff ff       	call   80100283 <brelse>
801017d7:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801017da:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801017de:	8b 15 48 24 19 80    	mov    0x80192448,%edx
801017e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017e7:	39 c2                	cmp    %eax,%edx
801017e9:	0f 87 51 ff ff ff    	ja     80101740 <ialloc+0x19>
  }
  panic("ialloc: no inodes");
801017ef:	83 ec 0c             	sub    $0xc,%esp
801017f2:	68 2b a2 10 80       	push   $0x8010a22b
801017f7:	e8 ad ed ff ff       	call   801005a9 <panic>
}
801017fc:	c9                   	leave  
801017fd:	c3                   	ret    

801017fe <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
801017fe:	55                   	push   %ebp
801017ff:	89 e5                	mov    %esp,%ebp
80101801:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101804:	8b 45 08             	mov    0x8(%ebp),%eax
80101807:	8b 40 04             	mov    0x4(%eax),%eax
8010180a:	c1 e8 03             	shr    $0x3,%eax
8010180d:	89 c2                	mov    %eax,%edx
8010180f:	a1 54 24 19 80       	mov    0x80192454,%eax
80101814:	01 c2                	add    %eax,%edx
80101816:	8b 45 08             	mov    0x8(%ebp),%eax
80101819:	8b 00                	mov    (%eax),%eax
8010181b:	83 ec 08             	sub    $0x8,%esp
8010181e:	52                   	push   %edx
8010181f:	50                   	push   %eax
80101820:	e8 dc e9 ff ff       	call   80100201 <bread>
80101825:	83 c4 10             	add    $0x10,%esp
80101828:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010182b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010182e:	8d 50 5c             	lea    0x5c(%eax),%edx
80101831:	8b 45 08             	mov    0x8(%ebp),%eax
80101834:	8b 40 04             	mov    0x4(%eax),%eax
80101837:	83 e0 07             	and    $0x7,%eax
8010183a:	c1 e0 06             	shl    $0x6,%eax
8010183d:	01 d0                	add    %edx,%eax
8010183f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101842:	8b 45 08             	mov    0x8(%ebp),%eax
80101845:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101849:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010184c:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010184f:	8b 45 08             	mov    0x8(%ebp),%eax
80101852:	0f b7 50 52          	movzwl 0x52(%eax),%edx
80101856:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101859:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010185d:	8b 45 08             	mov    0x8(%ebp),%eax
80101860:	0f b7 50 54          	movzwl 0x54(%eax),%edx
80101864:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101867:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010186b:	8b 45 08             	mov    0x8(%ebp),%eax
8010186e:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101872:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101875:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101879:	8b 45 08             	mov    0x8(%ebp),%eax
8010187c:	8b 50 58             	mov    0x58(%eax),%edx
8010187f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101882:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101885:	8b 45 08             	mov    0x8(%ebp),%eax
80101888:	8d 50 5c             	lea    0x5c(%eax),%edx
8010188b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010188e:	83 c0 0c             	add    $0xc,%eax
80101891:	83 ec 04             	sub    $0x4,%esp
80101894:	6a 34                	push   $0x34
80101896:	52                   	push   %edx
80101897:	50                   	push   %eax
80101898:	e8 d3 32 00 00       	call   80104b70 <memmove>
8010189d:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018a0:	83 ec 0c             	sub    $0xc,%esp
801018a3:	ff 75 f4             	push   -0xc(%ebp)
801018a6:	e8 bb 19 00 00       	call   80103266 <log_write>
801018ab:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018ae:	83 ec 0c             	sub    $0xc,%esp
801018b1:	ff 75 f4             	push   -0xc(%ebp)
801018b4:	e8 ca e9 ff ff       	call   80100283 <brelse>
801018b9:	83 c4 10             	add    $0x10,%esp
}
801018bc:	90                   	nop
801018bd:	c9                   	leave  
801018be:	c3                   	ret    

801018bf <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018bf:	55                   	push   %ebp
801018c0:	89 e5                	mov    %esp,%ebp
801018c2:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801018c5:	83 ec 0c             	sub    $0xc,%esp
801018c8:	68 60 24 19 80       	push   $0x80192460
801018cd:	e8 69 2f 00 00       	call   8010483b <acquire>
801018d2:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801018d5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018dc:	c7 45 f4 94 24 19 80 	movl   $0x80192494,-0xc(%ebp)
801018e3:	eb 60                	jmp    80101945 <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801018e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018e8:	8b 40 08             	mov    0x8(%eax),%eax
801018eb:	85 c0                	test   %eax,%eax
801018ed:	7e 39                	jle    80101928 <iget+0x69>
801018ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f2:	8b 00                	mov    (%eax),%eax
801018f4:	39 45 08             	cmp    %eax,0x8(%ebp)
801018f7:	75 2f                	jne    80101928 <iget+0x69>
801018f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018fc:	8b 40 04             	mov    0x4(%eax),%eax
801018ff:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101902:	75 24                	jne    80101928 <iget+0x69>
      ip->ref++;
80101904:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101907:	8b 40 08             	mov    0x8(%eax),%eax
8010190a:	8d 50 01             	lea    0x1(%eax),%edx
8010190d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101910:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101913:	83 ec 0c             	sub    $0xc,%esp
80101916:	68 60 24 19 80       	push   $0x80192460
8010191b:	e8 89 2f 00 00       	call   801048a9 <release>
80101920:	83 c4 10             	add    $0x10,%esp
      return ip;
80101923:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101926:	eb 77                	jmp    8010199f <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101928:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010192c:	75 10                	jne    8010193e <iget+0x7f>
8010192e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101931:	8b 40 08             	mov    0x8(%eax),%eax
80101934:	85 c0                	test   %eax,%eax
80101936:	75 06                	jne    8010193e <iget+0x7f>
      empty = ip;
80101938:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010193b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010193e:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101945:	81 7d f4 b4 40 19 80 	cmpl   $0x801940b4,-0xc(%ebp)
8010194c:	72 97                	jb     801018e5 <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010194e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101952:	75 0d                	jne    80101961 <iget+0xa2>
    panic("iget: no inodes");
80101954:	83 ec 0c             	sub    $0xc,%esp
80101957:	68 3d a2 10 80       	push   $0x8010a23d
8010195c:	e8 48 ec ff ff       	call   801005a9 <panic>

  ip = empty;
80101961:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101964:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101967:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010196a:	8b 55 08             	mov    0x8(%ebp),%edx
8010196d:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
8010196f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101972:	8b 55 0c             	mov    0xc(%ebp),%edx
80101975:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101978:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010197b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101982:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101985:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
8010198c:	83 ec 0c             	sub    $0xc,%esp
8010198f:	68 60 24 19 80       	push   $0x80192460
80101994:	e8 10 2f 00 00       	call   801048a9 <release>
80101999:	83 c4 10             	add    $0x10,%esp

  return ip;
8010199c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010199f:	c9                   	leave  
801019a0:	c3                   	ret    

801019a1 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801019a1:	55                   	push   %ebp
801019a2:	89 e5                	mov    %esp,%ebp
801019a4:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801019a7:	83 ec 0c             	sub    $0xc,%esp
801019aa:	68 60 24 19 80       	push   $0x80192460
801019af:	e8 87 2e 00 00       	call   8010483b <acquire>
801019b4:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019b7:	8b 45 08             	mov    0x8(%ebp),%eax
801019ba:	8b 40 08             	mov    0x8(%eax),%eax
801019bd:	8d 50 01             	lea    0x1(%eax),%edx
801019c0:	8b 45 08             	mov    0x8(%ebp),%eax
801019c3:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019c6:	83 ec 0c             	sub    $0xc,%esp
801019c9:	68 60 24 19 80       	push   $0x80192460
801019ce:	e8 d6 2e 00 00       	call   801048a9 <release>
801019d3:	83 c4 10             	add    $0x10,%esp
  return ip;
801019d6:	8b 45 08             	mov    0x8(%ebp),%eax
}
801019d9:	c9                   	leave  
801019da:	c3                   	ret    

801019db <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801019db:	55                   	push   %ebp
801019dc:	89 e5                	mov    %esp,%ebp
801019de:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801019e1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019e5:	74 0a                	je     801019f1 <ilock+0x16>
801019e7:	8b 45 08             	mov    0x8(%ebp),%eax
801019ea:	8b 40 08             	mov    0x8(%eax),%eax
801019ed:	85 c0                	test   %eax,%eax
801019ef:	7f 0d                	jg     801019fe <ilock+0x23>
    panic("ilock");
801019f1:	83 ec 0c             	sub    $0xc,%esp
801019f4:	68 4d a2 10 80       	push   $0x8010a24d
801019f9:	e8 ab eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
801019fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101a01:	83 c0 0c             	add    $0xc,%eax
80101a04:	83 ec 0c             	sub    $0xc,%esp
80101a07:	50                   	push   %eax
80101a08:	e8 eb 2c 00 00       	call   801046f8 <acquiresleep>
80101a0d:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101a10:	8b 45 08             	mov    0x8(%ebp),%eax
80101a13:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a16:	85 c0                	test   %eax,%eax
80101a18:	0f 85 cd 00 00 00    	jne    80101aeb <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a21:	8b 40 04             	mov    0x4(%eax),%eax
80101a24:	c1 e8 03             	shr    $0x3,%eax
80101a27:	89 c2                	mov    %eax,%edx
80101a29:	a1 54 24 19 80       	mov    0x80192454,%eax
80101a2e:	01 c2                	add    %eax,%edx
80101a30:	8b 45 08             	mov    0x8(%ebp),%eax
80101a33:	8b 00                	mov    (%eax),%eax
80101a35:	83 ec 08             	sub    $0x8,%esp
80101a38:	52                   	push   %edx
80101a39:	50                   	push   %eax
80101a3a:	e8 c2 e7 ff ff       	call   80100201 <bread>
80101a3f:	83 c4 10             	add    $0x10,%esp
80101a42:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a48:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a4b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a4e:	8b 40 04             	mov    0x4(%eax),%eax
80101a51:	83 e0 07             	and    $0x7,%eax
80101a54:	c1 e0 06             	shl    $0x6,%eax
80101a57:	01 d0                	add    %edx,%eax
80101a59:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a5f:	0f b7 10             	movzwl (%eax),%edx
80101a62:	8b 45 08             	mov    0x8(%ebp),%eax
80101a65:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101a69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a6c:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a70:	8b 45 08             	mov    0x8(%ebp),%eax
80101a73:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101a77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a7a:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a81:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101a85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a88:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a8c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8f:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101a93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a96:	8b 50 08             	mov    0x8(%eax),%edx
80101a99:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9c:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101a9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aa2:	8d 50 0c             	lea    0xc(%eax),%edx
80101aa5:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa8:	83 c0 5c             	add    $0x5c,%eax
80101aab:	83 ec 04             	sub    $0x4,%esp
80101aae:	6a 34                	push   $0x34
80101ab0:	52                   	push   %edx
80101ab1:	50                   	push   %eax
80101ab2:	e8 b9 30 00 00       	call   80104b70 <memmove>
80101ab7:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101aba:	83 ec 0c             	sub    $0xc,%esp
80101abd:	ff 75 f4             	push   -0xc(%ebp)
80101ac0:	e8 be e7 ff ff       	call   80100283 <brelse>
80101ac5:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101ac8:	8b 45 08             	mov    0x8(%ebp),%eax
80101acb:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101ad2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad5:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ad9:	66 85 c0             	test   %ax,%ax
80101adc:	75 0d                	jne    80101aeb <ilock+0x110>
      panic("ilock: no type");
80101ade:	83 ec 0c             	sub    $0xc,%esp
80101ae1:	68 53 a2 10 80       	push   $0x8010a253
80101ae6:	e8 be ea ff ff       	call   801005a9 <panic>
  }
}
80101aeb:	90                   	nop
80101aec:	c9                   	leave  
80101aed:	c3                   	ret    

80101aee <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101aee:	55                   	push   %ebp
80101aef:	89 e5                	mov    %esp,%ebp
80101af1:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101af4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101af8:	74 20                	je     80101b1a <iunlock+0x2c>
80101afa:	8b 45 08             	mov    0x8(%ebp),%eax
80101afd:	83 c0 0c             	add    $0xc,%eax
80101b00:	83 ec 0c             	sub    $0xc,%esp
80101b03:	50                   	push   %eax
80101b04:	e8 a1 2c 00 00       	call   801047aa <holdingsleep>
80101b09:	83 c4 10             	add    $0x10,%esp
80101b0c:	85 c0                	test   %eax,%eax
80101b0e:	74 0a                	je     80101b1a <iunlock+0x2c>
80101b10:	8b 45 08             	mov    0x8(%ebp),%eax
80101b13:	8b 40 08             	mov    0x8(%eax),%eax
80101b16:	85 c0                	test   %eax,%eax
80101b18:	7f 0d                	jg     80101b27 <iunlock+0x39>
    panic("iunlock");
80101b1a:	83 ec 0c             	sub    $0xc,%esp
80101b1d:	68 62 a2 10 80       	push   $0x8010a262
80101b22:	e8 82 ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b27:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2a:	83 c0 0c             	add    $0xc,%eax
80101b2d:	83 ec 0c             	sub    $0xc,%esp
80101b30:	50                   	push   %eax
80101b31:	e8 26 2c 00 00       	call   8010475c <releasesleep>
80101b36:	83 c4 10             	add    $0x10,%esp
}
80101b39:	90                   	nop
80101b3a:	c9                   	leave  
80101b3b:	c3                   	ret    

80101b3c <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b3c:	55                   	push   %ebp
80101b3d:	89 e5                	mov    %esp,%ebp
80101b3f:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101b42:	8b 45 08             	mov    0x8(%ebp),%eax
80101b45:	83 c0 0c             	add    $0xc,%eax
80101b48:	83 ec 0c             	sub    $0xc,%esp
80101b4b:	50                   	push   %eax
80101b4c:	e8 a7 2b 00 00       	call   801046f8 <acquiresleep>
80101b51:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101b54:	8b 45 08             	mov    0x8(%ebp),%eax
80101b57:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b5a:	85 c0                	test   %eax,%eax
80101b5c:	74 6a                	je     80101bc8 <iput+0x8c>
80101b5e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b61:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101b65:	66 85 c0             	test   %ax,%ax
80101b68:	75 5e                	jne    80101bc8 <iput+0x8c>
    acquire(&icache.lock);
80101b6a:	83 ec 0c             	sub    $0xc,%esp
80101b6d:	68 60 24 19 80       	push   $0x80192460
80101b72:	e8 c4 2c 00 00       	call   8010483b <acquire>
80101b77:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b7a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7d:	8b 40 08             	mov    0x8(%eax),%eax
80101b80:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b83:	83 ec 0c             	sub    $0xc,%esp
80101b86:	68 60 24 19 80       	push   $0x80192460
80101b8b:	e8 19 2d 00 00       	call   801048a9 <release>
80101b90:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101b93:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101b97:	75 2f                	jne    80101bc8 <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101b99:	83 ec 0c             	sub    $0xc,%esp
80101b9c:	ff 75 08             	push   0x8(%ebp)
80101b9f:	e8 ad 01 00 00       	call   80101d51 <itrunc>
80101ba4:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101ba7:	8b 45 08             	mov    0x8(%ebp),%eax
80101baa:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101bb0:	83 ec 0c             	sub    $0xc,%esp
80101bb3:	ff 75 08             	push   0x8(%ebp)
80101bb6:	e8 43 fc ff ff       	call   801017fe <iupdate>
80101bbb:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101bbe:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc1:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101bc8:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcb:	83 c0 0c             	add    $0xc,%eax
80101bce:	83 ec 0c             	sub    $0xc,%esp
80101bd1:	50                   	push   %eax
80101bd2:	e8 85 2b 00 00       	call   8010475c <releasesleep>
80101bd7:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101bda:	83 ec 0c             	sub    $0xc,%esp
80101bdd:	68 60 24 19 80       	push   $0x80192460
80101be2:	e8 54 2c 00 00       	call   8010483b <acquire>
80101be7:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101bea:	8b 45 08             	mov    0x8(%ebp),%eax
80101bed:	8b 40 08             	mov    0x8(%eax),%eax
80101bf0:	8d 50 ff             	lea    -0x1(%eax),%edx
80101bf3:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf6:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101bf9:	83 ec 0c             	sub    $0xc,%esp
80101bfc:	68 60 24 19 80       	push   $0x80192460
80101c01:	e8 a3 2c 00 00       	call   801048a9 <release>
80101c06:	83 c4 10             	add    $0x10,%esp
}
80101c09:	90                   	nop
80101c0a:	c9                   	leave  
80101c0b:	c3                   	ret    

80101c0c <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c0c:	55                   	push   %ebp
80101c0d:	89 e5                	mov    %esp,%ebp
80101c0f:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c12:	83 ec 0c             	sub    $0xc,%esp
80101c15:	ff 75 08             	push   0x8(%ebp)
80101c18:	e8 d1 fe ff ff       	call   80101aee <iunlock>
80101c1d:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c20:	83 ec 0c             	sub    $0xc,%esp
80101c23:	ff 75 08             	push   0x8(%ebp)
80101c26:	e8 11 ff ff ff       	call   80101b3c <iput>
80101c2b:	83 c4 10             	add    $0x10,%esp
}
80101c2e:	90                   	nop
80101c2f:	c9                   	leave  
80101c30:	c3                   	ret    

80101c31 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c31:	55                   	push   %ebp
80101c32:	89 e5                	mov    %esp,%ebp
80101c34:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c37:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c3b:	77 42                	ja     80101c7f <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101c3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c40:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c43:	83 c2 14             	add    $0x14,%edx
80101c46:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c4d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c51:	75 24                	jne    80101c77 <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c53:	8b 45 08             	mov    0x8(%ebp),%eax
80101c56:	8b 00                	mov    (%eax),%eax
80101c58:	83 ec 0c             	sub    $0xc,%esp
80101c5b:	50                   	push   %eax
80101c5c:	e8 f4 f7 ff ff       	call   80101455 <balloc>
80101c61:	83 c4 10             	add    $0x10,%esp
80101c64:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c67:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6a:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c6d:	8d 4a 14             	lea    0x14(%edx),%ecx
80101c70:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c73:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c7a:	e9 d0 00 00 00       	jmp    80101d4f <bmap+0x11e>
  }
  bn -= NDIRECT;
80101c7f:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c83:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c87:	0f 87 b5 00 00 00    	ja     80101d42 <bmap+0x111>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101c8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c90:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101c96:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c99:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c9d:	75 20                	jne    80101cbf <bmap+0x8e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101c9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca2:	8b 00                	mov    (%eax),%eax
80101ca4:	83 ec 0c             	sub    $0xc,%esp
80101ca7:	50                   	push   %eax
80101ca8:	e8 a8 f7 ff ff       	call   80101455 <balloc>
80101cad:	83 c4 10             	add    $0x10,%esp
80101cb0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cb3:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cb9:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101cbf:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc2:	8b 00                	mov    (%eax),%eax
80101cc4:	83 ec 08             	sub    $0x8,%esp
80101cc7:	ff 75 f4             	push   -0xc(%ebp)
80101cca:	50                   	push   %eax
80101ccb:	e8 31 e5 ff ff       	call   80100201 <bread>
80101cd0:	83 c4 10             	add    $0x10,%esp
80101cd3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101cd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cd9:	83 c0 5c             	add    $0x5c,%eax
80101cdc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cdf:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ce2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ce9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cec:	01 d0                	add    %edx,%eax
80101cee:	8b 00                	mov    (%eax),%eax
80101cf0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cf3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cf7:	75 36                	jne    80101d2f <bmap+0xfe>
      a[bn] = addr = balloc(ip->dev);
80101cf9:	8b 45 08             	mov    0x8(%ebp),%eax
80101cfc:	8b 00                	mov    (%eax),%eax
80101cfe:	83 ec 0c             	sub    $0xc,%esp
80101d01:	50                   	push   %eax
80101d02:	e8 4e f7 ff ff       	call   80101455 <balloc>
80101d07:	83 c4 10             	add    $0x10,%esp
80101d0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d0d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d10:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d17:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d1a:	01 c2                	add    %eax,%edx
80101d1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d1f:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d21:	83 ec 0c             	sub    $0xc,%esp
80101d24:	ff 75 f0             	push   -0x10(%ebp)
80101d27:	e8 3a 15 00 00       	call   80103266 <log_write>
80101d2c:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d2f:	83 ec 0c             	sub    $0xc,%esp
80101d32:	ff 75 f0             	push   -0x10(%ebp)
80101d35:	e8 49 e5 ff ff       	call   80100283 <brelse>
80101d3a:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d40:	eb 0d                	jmp    80101d4f <bmap+0x11e>
  }

  panic("bmap: out of range");
80101d42:	83 ec 0c             	sub    $0xc,%esp
80101d45:	68 6a a2 10 80       	push   $0x8010a26a
80101d4a:	e8 5a e8 ff ff       	call   801005a9 <panic>
}
80101d4f:	c9                   	leave  
80101d50:	c3                   	ret    

80101d51 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d51:	55                   	push   %ebp
80101d52:	89 e5                	mov    %esp,%ebp
80101d54:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d57:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d5e:	eb 45                	jmp    80101da5 <itrunc+0x54>
    if(ip->addrs[i]){
80101d60:	8b 45 08             	mov    0x8(%ebp),%eax
80101d63:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d66:	83 c2 14             	add    $0x14,%edx
80101d69:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d6d:	85 c0                	test   %eax,%eax
80101d6f:	74 30                	je     80101da1 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d71:	8b 45 08             	mov    0x8(%ebp),%eax
80101d74:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d77:	83 c2 14             	add    $0x14,%edx
80101d7a:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d7e:	8b 55 08             	mov    0x8(%ebp),%edx
80101d81:	8b 12                	mov    (%edx),%edx
80101d83:	83 ec 08             	sub    $0x8,%esp
80101d86:	50                   	push   %eax
80101d87:	52                   	push   %edx
80101d88:	e8 0c f8 ff ff       	call   80101599 <bfree>
80101d8d:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101d90:	8b 45 08             	mov    0x8(%ebp),%eax
80101d93:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d96:	83 c2 14             	add    $0x14,%edx
80101d99:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101da0:	00 
  for(i = 0; i < NDIRECT; i++){
80101da1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101da5:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101da9:	7e b5                	jle    80101d60 <itrunc+0xf>
    }
  }

  if(ip->addrs[NDIRECT]){
80101dab:	8b 45 08             	mov    0x8(%ebp),%eax
80101dae:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101db4:	85 c0                	test   %eax,%eax
80101db6:	0f 84 aa 00 00 00    	je     80101e66 <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dbc:	8b 45 08             	mov    0x8(%ebp),%eax
80101dbf:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101dc5:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc8:	8b 00                	mov    (%eax),%eax
80101dca:	83 ec 08             	sub    $0x8,%esp
80101dcd:	52                   	push   %edx
80101dce:	50                   	push   %eax
80101dcf:	e8 2d e4 ff ff       	call   80100201 <bread>
80101dd4:	83 c4 10             	add    $0x10,%esp
80101dd7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101dda:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ddd:	83 c0 5c             	add    $0x5c,%eax
80101de0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101de3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101dea:	eb 3c                	jmp    80101e28 <itrunc+0xd7>
      if(a[j])
80101dec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101def:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101df6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101df9:	01 d0                	add    %edx,%eax
80101dfb:	8b 00                	mov    (%eax),%eax
80101dfd:	85 c0                	test   %eax,%eax
80101dff:	74 23                	je     80101e24 <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101e01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e04:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e0b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e0e:	01 d0                	add    %edx,%eax
80101e10:	8b 00                	mov    (%eax),%eax
80101e12:	8b 55 08             	mov    0x8(%ebp),%edx
80101e15:	8b 12                	mov    (%edx),%edx
80101e17:	83 ec 08             	sub    $0x8,%esp
80101e1a:	50                   	push   %eax
80101e1b:	52                   	push   %edx
80101e1c:	e8 78 f7 ff ff       	call   80101599 <bfree>
80101e21:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101e24:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e2b:	83 f8 7f             	cmp    $0x7f,%eax
80101e2e:	76 bc                	jbe    80101dec <itrunc+0x9b>
    }
    brelse(bp);
80101e30:	83 ec 0c             	sub    $0xc,%esp
80101e33:	ff 75 ec             	push   -0x14(%ebp)
80101e36:	e8 48 e4 ff ff       	call   80100283 <brelse>
80101e3b:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e41:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e47:	8b 55 08             	mov    0x8(%ebp),%edx
80101e4a:	8b 12                	mov    (%edx),%edx
80101e4c:	83 ec 08             	sub    $0x8,%esp
80101e4f:	50                   	push   %eax
80101e50:	52                   	push   %edx
80101e51:	e8 43 f7 ff ff       	call   80101599 <bfree>
80101e56:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e59:	8b 45 08             	mov    0x8(%ebp),%eax
80101e5c:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101e63:	00 00 00 
  }

  ip->size = 0;
80101e66:	8b 45 08             	mov    0x8(%ebp),%eax
80101e69:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101e70:	83 ec 0c             	sub    $0xc,%esp
80101e73:	ff 75 08             	push   0x8(%ebp)
80101e76:	e8 83 f9 ff ff       	call   801017fe <iupdate>
80101e7b:	83 c4 10             	add    $0x10,%esp
}
80101e7e:	90                   	nop
80101e7f:	c9                   	leave  
80101e80:	c3                   	ret    

80101e81 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101e81:	55                   	push   %ebp
80101e82:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e84:	8b 45 08             	mov    0x8(%ebp),%eax
80101e87:	8b 00                	mov    (%eax),%eax
80101e89:	89 c2                	mov    %eax,%edx
80101e8b:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e8e:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101e91:	8b 45 08             	mov    0x8(%ebp),%eax
80101e94:	8b 50 04             	mov    0x4(%eax),%edx
80101e97:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e9a:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101e9d:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea0:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101ea4:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ea7:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101eaa:	8b 45 08             	mov    0x8(%ebp),%eax
80101ead:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101eb1:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb4:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101eb8:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebb:	8b 50 58             	mov    0x58(%eax),%edx
80101ebe:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ec1:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ec4:	90                   	nop
80101ec5:	5d                   	pop    %ebp
80101ec6:	c3                   	ret    

80101ec7 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ec7:	55                   	push   %ebp
80101ec8:	89 e5                	mov    %esp,%ebp
80101eca:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ecd:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed0:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ed4:	66 83 f8 03          	cmp    $0x3,%ax
80101ed8:	75 5c                	jne    80101f36 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101eda:	8b 45 08             	mov    0x8(%ebp),%eax
80101edd:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101ee1:	66 85 c0             	test   %ax,%ax
80101ee4:	78 20                	js     80101f06 <readi+0x3f>
80101ee6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee9:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101eed:	66 83 f8 09          	cmp    $0x9,%ax
80101ef1:	7f 13                	jg     80101f06 <readi+0x3f>
80101ef3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef6:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101efa:	98                   	cwtl   
80101efb:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f02:	85 c0                	test   %eax,%eax
80101f04:	75 0a                	jne    80101f10 <readi+0x49>
      return -1;
80101f06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f0b:	e9 0a 01 00 00       	jmp    8010201a <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f10:	8b 45 08             	mov    0x8(%ebp),%eax
80101f13:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f17:	98                   	cwtl   
80101f18:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f1f:	8b 55 14             	mov    0x14(%ebp),%edx
80101f22:	83 ec 04             	sub    $0x4,%esp
80101f25:	52                   	push   %edx
80101f26:	ff 75 0c             	push   0xc(%ebp)
80101f29:	ff 75 08             	push   0x8(%ebp)
80101f2c:	ff d0                	call   *%eax
80101f2e:	83 c4 10             	add    $0x10,%esp
80101f31:	e9 e4 00 00 00       	jmp    8010201a <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80101f36:	8b 45 08             	mov    0x8(%ebp),%eax
80101f39:	8b 40 58             	mov    0x58(%eax),%eax
80101f3c:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f3f:	77 0d                	ja     80101f4e <readi+0x87>
80101f41:	8b 55 10             	mov    0x10(%ebp),%edx
80101f44:	8b 45 14             	mov    0x14(%ebp),%eax
80101f47:	01 d0                	add    %edx,%eax
80101f49:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f4c:	76 0a                	jbe    80101f58 <readi+0x91>
    return -1;
80101f4e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f53:	e9 c2 00 00 00       	jmp    8010201a <readi+0x153>
  if(off + n > ip->size)
80101f58:	8b 55 10             	mov    0x10(%ebp),%edx
80101f5b:	8b 45 14             	mov    0x14(%ebp),%eax
80101f5e:	01 c2                	add    %eax,%edx
80101f60:	8b 45 08             	mov    0x8(%ebp),%eax
80101f63:	8b 40 58             	mov    0x58(%eax),%eax
80101f66:	39 c2                	cmp    %eax,%edx
80101f68:	76 0c                	jbe    80101f76 <readi+0xaf>
    n = ip->size - off;
80101f6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f6d:	8b 40 58             	mov    0x58(%eax),%eax
80101f70:	2b 45 10             	sub    0x10(%ebp),%eax
80101f73:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f76:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f7d:	e9 89 00 00 00       	jmp    8010200b <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f82:	8b 45 10             	mov    0x10(%ebp),%eax
80101f85:	c1 e8 09             	shr    $0x9,%eax
80101f88:	83 ec 08             	sub    $0x8,%esp
80101f8b:	50                   	push   %eax
80101f8c:	ff 75 08             	push   0x8(%ebp)
80101f8f:	e8 9d fc ff ff       	call   80101c31 <bmap>
80101f94:	83 c4 10             	add    $0x10,%esp
80101f97:	8b 55 08             	mov    0x8(%ebp),%edx
80101f9a:	8b 12                	mov    (%edx),%edx
80101f9c:	83 ec 08             	sub    $0x8,%esp
80101f9f:	50                   	push   %eax
80101fa0:	52                   	push   %edx
80101fa1:	e8 5b e2 ff ff       	call   80100201 <bread>
80101fa6:	83 c4 10             	add    $0x10,%esp
80101fa9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fac:	8b 45 10             	mov    0x10(%ebp),%eax
80101faf:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fb4:	ba 00 02 00 00       	mov    $0x200,%edx
80101fb9:	29 c2                	sub    %eax,%edx
80101fbb:	8b 45 14             	mov    0x14(%ebp),%eax
80101fbe:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fc1:	39 c2                	cmp    %eax,%edx
80101fc3:	0f 46 c2             	cmovbe %edx,%eax
80101fc6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fcc:	8d 50 5c             	lea    0x5c(%eax),%edx
80101fcf:	8b 45 10             	mov    0x10(%ebp),%eax
80101fd2:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fd7:	01 d0                	add    %edx,%eax
80101fd9:	83 ec 04             	sub    $0x4,%esp
80101fdc:	ff 75 ec             	push   -0x14(%ebp)
80101fdf:	50                   	push   %eax
80101fe0:	ff 75 0c             	push   0xc(%ebp)
80101fe3:	e8 88 2b 00 00       	call   80104b70 <memmove>
80101fe8:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101feb:	83 ec 0c             	sub    $0xc,%esp
80101fee:	ff 75 f0             	push   -0x10(%ebp)
80101ff1:	e8 8d e2 ff ff       	call   80100283 <brelse>
80101ff6:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101ff9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ffc:	01 45 f4             	add    %eax,-0xc(%ebp)
80101fff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102002:	01 45 10             	add    %eax,0x10(%ebp)
80102005:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102008:	01 45 0c             	add    %eax,0xc(%ebp)
8010200b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010200e:	3b 45 14             	cmp    0x14(%ebp),%eax
80102011:	0f 82 6b ff ff ff    	jb     80101f82 <readi+0xbb>
  }
  return n;
80102017:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010201a:	c9                   	leave  
8010201b:	c3                   	ret    

8010201c <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010201c:	55                   	push   %ebp
8010201d:	89 e5                	mov    %esp,%ebp
8010201f:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102022:	8b 45 08             	mov    0x8(%ebp),%eax
80102025:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102029:	66 83 f8 03          	cmp    $0x3,%ax
8010202d:	75 5c                	jne    8010208b <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010202f:	8b 45 08             	mov    0x8(%ebp),%eax
80102032:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102036:	66 85 c0             	test   %ax,%ax
80102039:	78 20                	js     8010205b <writei+0x3f>
8010203b:	8b 45 08             	mov    0x8(%ebp),%eax
8010203e:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102042:	66 83 f8 09          	cmp    $0x9,%ax
80102046:	7f 13                	jg     8010205b <writei+0x3f>
80102048:	8b 45 08             	mov    0x8(%ebp),%eax
8010204b:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010204f:	98                   	cwtl   
80102050:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
80102057:	85 c0                	test   %eax,%eax
80102059:	75 0a                	jne    80102065 <writei+0x49>
      return -1;
8010205b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102060:	e9 3b 01 00 00       	jmp    801021a0 <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
80102065:	8b 45 08             	mov    0x8(%ebp),%eax
80102068:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010206c:	98                   	cwtl   
8010206d:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
80102074:	8b 55 14             	mov    0x14(%ebp),%edx
80102077:	83 ec 04             	sub    $0x4,%esp
8010207a:	52                   	push   %edx
8010207b:	ff 75 0c             	push   0xc(%ebp)
8010207e:	ff 75 08             	push   0x8(%ebp)
80102081:	ff d0                	call   *%eax
80102083:	83 c4 10             	add    $0x10,%esp
80102086:	e9 15 01 00 00       	jmp    801021a0 <writei+0x184>
  }

  if(off > ip->size || off + n < off)
8010208b:	8b 45 08             	mov    0x8(%ebp),%eax
8010208e:	8b 40 58             	mov    0x58(%eax),%eax
80102091:	39 45 10             	cmp    %eax,0x10(%ebp)
80102094:	77 0d                	ja     801020a3 <writei+0x87>
80102096:	8b 55 10             	mov    0x10(%ebp),%edx
80102099:	8b 45 14             	mov    0x14(%ebp),%eax
8010209c:	01 d0                	add    %edx,%eax
8010209e:	39 45 10             	cmp    %eax,0x10(%ebp)
801020a1:	76 0a                	jbe    801020ad <writei+0x91>
    return -1;
801020a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020a8:	e9 f3 00 00 00       	jmp    801021a0 <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
801020ad:	8b 55 10             	mov    0x10(%ebp),%edx
801020b0:	8b 45 14             	mov    0x14(%ebp),%eax
801020b3:	01 d0                	add    %edx,%eax
801020b5:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020ba:	76 0a                	jbe    801020c6 <writei+0xaa>
    return -1;
801020bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020c1:	e9 da 00 00 00       	jmp    801021a0 <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020cd:	e9 97 00 00 00       	jmp    80102169 <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020d2:	8b 45 10             	mov    0x10(%ebp),%eax
801020d5:	c1 e8 09             	shr    $0x9,%eax
801020d8:	83 ec 08             	sub    $0x8,%esp
801020db:	50                   	push   %eax
801020dc:	ff 75 08             	push   0x8(%ebp)
801020df:	e8 4d fb ff ff       	call   80101c31 <bmap>
801020e4:	83 c4 10             	add    $0x10,%esp
801020e7:	8b 55 08             	mov    0x8(%ebp),%edx
801020ea:	8b 12                	mov    (%edx),%edx
801020ec:	83 ec 08             	sub    $0x8,%esp
801020ef:	50                   	push   %eax
801020f0:	52                   	push   %edx
801020f1:	e8 0b e1 ff ff       	call   80100201 <bread>
801020f6:	83 c4 10             	add    $0x10,%esp
801020f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801020fc:	8b 45 10             	mov    0x10(%ebp),%eax
801020ff:	25 ff 01 00 00       	and    $0x1ff,%eax
80102104:	ba 00 02 00 00       	mov    $0x200,%edx
80102109:	29 c2                	sub    %eax,%edx
8010210b:	8b 45 14             	mov    0x14(%ebp),%eax
8010210e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102111:	39 c2                	cmp    %eax,%edx
80102113:	0f 46 c2             	cmovbe %edx,%eax
80102116:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102119:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010211c:	8d 50 5c             	lea    0x5c(%eax),%edx
8010211f:	8b 45 10             	mov    0x10(%ebp),%eax
80102122:	25 ff 01 00 00       	and    $0x1ff,%eax
80102127:	01 d0                	add    %edx,%eax
80102129:	83 ec 04             	sub    $0x4,%esp
8010212c:	ff 75 ec             	push   -0x14(%ebp)
8010212f:	ff 75 0c             	push   0xc(%ebp)
80102132:	50                   	push   %eax
80102133:	e8 38 2a 00 00       	call   80104b70 <memmove>
80102138:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
8010213b:	83 ec 0c             	sub    $0xc,%esp
8010213e:	ff 75 f0             	push   -0x10(%ebp)
80102141:	e8 20 11 00 00       	call   80103266 <log_write>
80102146:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102149:	83 ec 0c             	sub    $0xc,%esp
8010214c:	ff 75 f0             	push   -0x10(%ebp)
8010214f:	e8 2f e1 ff ff       	call   80100283 <brelse>
80102154:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102157:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010215a:	01 45 f4             	add    %eax,-0xc(%ebp)
8010215d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102160:	01 45 10             	add    %eax,0x10(%ebp)
80102163:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102166:	01 45 0c             	add    %eax,0xc(%ebp)
80102169:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010216c:	3b 45 14             	cmp    0x14(%ebp),%eax
8010216f:	0f 82 5d ff ff ff    	jb     801020d2 <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
80102175:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102179:	74 22                	je     8010219d <writei+0x181>
8010217b:	8b 45 08             	mov    0x8(%ebp),%eax
8010217e:	8b 40 58             	mov    0x58(%eax),%eax
80102181:	39 45 10             	cmp    %eax,0x10(%ebp)
80102184:	76 17                	jbe    8010219d <writei+0x181>
    ip->size = off;
80102186:	8b 45 08             	mov    0x8(%ebp),%eax
80102189:	8b 55 10             	mov    0x10(%ebp),%edx
8010218c:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
8010218f:	83 ec 0c             	sub    $0xc,%esp
80102192:	ff 75 08             	push   0x8(%ebp)
80102195:	e8 64 f6 ff ff       	call   801017fe <iupdate>
8010219a:	83 c4 10             	add    $0x10,%esp
  }
  return n;
8010219d:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021a0:	c9                   	leave  
801021a1:	c3                   	ret    

801021a2 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021a2:	55                   	push   %ebp
801021a3:	89 e5                	mov    %esp,%ebp
801021a5:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021a8:	83 ec 04             	sub    $0x4,%esp
801021ab:	6a 0e                	push   $0xe
801021ad:	ff 75 0c             	push   0xc(%ebp)
801021b0:	ff 75 08             	push   0x8(%ebp)
801021b3:	e8 4e 2a 00 00       	call   80104c06 <strncmp>
801021b8:	83 c4 10             	add    $0x10,%esp
}
801021bb:	c9                   	leave  
801021bc:	c3                   	ret    

801021bd <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021bd:	55                   	push   %ebp
801021be:	89 e5                	mov    %esp,%ebp
801021c0:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021c3:	8b 45 08             	mov    0x8(%ebp),%eax
801021c6:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801021ca:	66 83 f8 01          	cmp    $0x1,%ax
801021ce:	74 0d                	je     801021dd <dirlookup+0x20>
    panic("dirlookup not DIR");
801021d0:	83 ec 0c             	sub    $0xc,%esp
801021d3:	68 7d a2 10 80       	push   $0x8010a27d
801021d8:	e8 cc e3 ff ff       	call   801005a9 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021e4:	eb 7b                	jmp    80102261 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021e6:	6a 10                	push   $0x10
801021e8:	ff 75 f4             	push   -0xc(%ebp)
801021eb:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021ee:	50                   	push   %eax
801021ef:	ff 75 08             	push   0x8(%ebp)
801021f2:	e8 d0 fc ff ff       	call   80101ec7 <readi>
801021f7:	83 c4 10             	add    $0x10,%esp
801021fa:	83 f8 10             	cmp    $0x10,%eax
801021fd:	74 0d                	je     8010220c <dirlookup+0x4f>
      panic("dirlookup read");
801021ff:	83 ec 0c             	sub    $0xc,%esp
80102202:	68 8f a2 10 80       	push   $0x8010a28f
80102207:	e8 9d e3 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
8010220c:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102210:	66 85 c0             	test   %ax,%ax
80102213:	74 47                	je     8010225c <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
80102215:	83 ec 08             	sub    $0x8,%esp
80102218:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010221b:	83 c0 02             	add    $0x2,%eax
8010221e:	50                   	push   %eax
8010221f:	ff 75 0c             	push   0xc(%ebp)
80102222:	e8 7b ff ff ff       	call   801021a2 <namecmp>
80102227:	83 c4 10             	add    $0x10,%esp
8010222a:	85 c0                	test   %eax,%eax
8010222c:	75 2f                	jne    8010225d <dirlookup+0xa0>
      // entry matches path element
      if(poff)
8010222e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102232:	74 08                	je     8010223c <dirlookup+0x7f>
        *poff = off;
80102234:	8b 45 10             	mov    0x10(%ebp),%eax
80102237:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010223a:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010223c:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102240:	0f b7 c0             	movzwl %ax,%eax
80102243:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102246:	8b 45 08             	mov    0x8(%ebp),%eax
80102249:	8b 00                	mov    (%eax),%eax
8010224b:	83 ec 08             	sub    $0x8,%esp
8010224e:	ff 75 f0             	push   -0x10(%ebp)
80102251:	50                   	push   %eax
80102252:	e8 68 f6 ff ff       	call   801018bf <iget>
80102257:	83 c4 10             	add    $0x10,%esp
8010225a:	eb 19                	jmp    80102275 <dirlookup+0xb8>
      continue;
8010225c:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
8010225d:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102261:	8b 45 08             	mov    0x8(%ebp),%eax
80102264:	8b 40 58             	mov    0x58(%eax),%eax
80102267:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010226a:	0f 82 76 ff ff ff    	jb     801021e6 <dirlookup+0x29>
    }
  }

  return 0;
80102270:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102275:	c9                   	leave  
80102276:	c3                   	ret    

80102277 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102277:	55                   	push   %ebp
80102278:	89 e5                	mov    %esp,%ebp
8010227a:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010227d:	83 ec 04             	sub    $0x4,%esp
80102280:	6a 00                	push   $0x0
80102282:	ff 75 0c             	push   0xc(%ebp)
80102285:	ff 75 08             	push   0x8(%ebp)
80102288:	e8 30 ff ff ff       	call   801021bd <dirlookup>
8010228d:	83 c4 10             	add    $0x10,%esp
80102290:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102293:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102297:	74 18                	je     801022b1 <dirlink+0x3a>
    iput(ip);
80102299:	83 ec 0c             	sub    $0xc,%esp
8010229c:	ff 75 f0             	push   -0x10(%ebp)
8010229f:	e8 98 f8 ff ff       	call   80101b3c <iput>
801022a4:	83 c4 10             	add    $0x10,%esp
    return -1;
801022a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022ac:	e9 9c 00 00 00       	jmp    8010234d <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022b8:	eb 39                	jmp    801022f3 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022bd:	6a 10                	push   $0x10
801022bf:	50                   	push   %eax
801022c0:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022c3:	50                   	push   %eax
801022c4:	ff 75 08             	push   0x8(%ebp)
801022c7:	e8 fb fb ff ff       	call   80101ec7 <readi>
801022cc:	83 c4 10             	add    $0x10,%esp
801022cf:	83 f8 10             	cmp    $0x10,%eax
801022d2:	74 0d                	je     801022e1 <dirlink+0x6a>
      panic("dirlink read");
801022d4:	83 ec 0c             	sub    $0xc,%esp
801022d7:	68 9e a2 10 80       	push   $0x8010a29e
801022dc:	e8 c8 e2 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
801022e1:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022e5:	66 85 c0             	test   %ax,%ax
801022e8:	74 18                	je     80102302 <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
801022ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022ed:	83 c0 10             	add    $0x10,%eax
801022f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801022f3:	8b 45 08             	mov    0x8(%ebp),%eax
801022f6:	8b 50 58             	mov    0x58(%eax),%edx
801022f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022fc:	39 c2                	cmp    %eax,%edx
801022fe:	77 ba                	ja     801022ba <dirlink+0x43>
80102300:	eb 01                	jmp    80102303 <dirlink+0x8c>
      break;
80102302:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102303:	83 ec 04             	sub    $0x4,%esp
80102306:	6a 0e                	push   $0xe
80102308:	ff 75 0c             	push   0xc(%ebp)
8010230b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010230e:	83 c0 02             	add    $0x2,%eax
80102311:	50                   	push   %eax
80102312:	e8 45 29 00 00       	call   80104c5c <strncpy>
80102317:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
8010231a:	8b 45 10             	mov    0x10(%ebp),%eax
8010231d:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102321:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102324:	6a 10                	push   $0x10
80102326:	50                   	push   %eax
80102327:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010232a:	50                   	push   %eax
8010232b:	ff 75 08             	push   0x8(%ebp)
8010232e:	e8 e9 fc ff ff       	call   8010201c <writei>
80102333:	83 c4 10             	add    $0x10,%esp
80102336:	83 f8 10             	cmp    $0x10,%eax
80102339:	74 0d                	je     80102348 <dirlink+0xd1>
    panic("dirlink");
8010233b:	83 ec 0c             	sub    $0xc,%esp
8010233e:	68 ab a2 10 80       	push   $0x8010a2ab
80102343:	e8 61 e2 ff ff       	call   801005a9 <panic>

  return 0;
80102348:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010234d:	c9                   	leave  
8010234e:	c3                   	ret    

8010234f <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010234f:	55                   	push   %ebp
80102350:	89 e5                	mov    %esp,%ebp
80102352:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102355:	eb 04                	jmp    8010235b <skipelem+0xc>
    path++;
80102357:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
8010235b:	8b 45 08             	mov    0x8(%ebp),%eax
8010235e:	0f b6 00             	movzbl (%eax),%eax
80102361:	3c 2f                	cmp    $0x2f,%al
80102363:	74 f2                	je     80102357 <skipelem+0x8>
  if(*path == 0)
80102365:	8b 45 08             	mov    0x8(%ebp),%eax
80102368:	0f b6 00             	movzbl (%eax),%eax
8010236b:	84 c0                	test   %al,%al
8010236d:	75 07                	jne    80102376 <skipelem+0x27>
    return 0;
8010236f:	b8 00 00 00 00       	mov    $0x0,%eax
80102374:	eb 77                	jmp    801023ed <skipelem+0x9e>
  s = path;
80102376:	8b 45 08             	mov    0x8(%ebp),%eax
80102379:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010237c:	eb 04                	jmp    80102382 <skipelem+0x33>
    path++;
8010237e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102382:	8b 45 08             	mov    0x8(%ebp),%eax
80102385:	0f b6 00             	movzbl (%eax),%eax
80102388:	3c 2f                	cmp    $0x2f,%al
8010238a:	74 0a                	je     80102396 <skipelem+0x47>
8010238c:	8b 45 08             	mov    0x8(%ebp),%eax
8010238f:	0f b6 00             	movzbl (%eax),%eax
80102392:	84 c0                	test   %al,%al
80102394:	75 e8                	jne    8010237e <skipelem+0x2f>
  len = path - s;
80102396:	8b 45 08             	mov    0x8(%ebp),%eax
80102399:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010239c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
8010239f:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023a3:	7e 15                	jle    801023ba <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
801023a5:	83 ec 04             	sub    $0x4,%esp
801023a8:	6a 0e                	push   $0xe
801023aa:	ff 75 f4             	push   -0xc(%ebp)
801023ad:	ff 75 0c             	push   0xc(%ebp)
801023b0:	e8 bb 27 00 00       	call   80104b70 <memmove>
801023b5:	83 c4 10             	add    $0x10,%esp
801023b8:	eb 26                	jmp    801023e0 <skipelem+0x91>
  else {
    memmove(name, s, len);
801023ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023bd:	83 ec 04             	sub    $0x4,%esp
801023c0:	50                   	push   %eax
801023c1:	ff 75 f4             	push   -0xc(%ebp)
801023c4:	ff 75 0c             	push   0xc(%ebp)
801023c7:	e8 a4 27 00 00       	call   80104b70 <memmove>
801023cc:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023cf:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023d2:	8b 45 0c             	mov    0xc(%ebp),%eax
801023d5:	01 d0                	add    %edx,%eax
801023d7:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023da:	eb 04                	jmp    801023e0 <skipelem+0x91>
    path++;
801023dc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801023e0:	8b 45 08             	mov    0x8(%ebp),%eax
801023e3:	0f b6 00             	movzbl (%eax),%eax
801023e6:	3c 2f                	cmp    $0x2f,%al
801023e8:	74 f2                	je     801023dc <skipelem+0x8d>
  return path;
801023ea:	8b 45 08             	mov    0x8(%ebp),%eax
}
801023ed:	c9                   	leave  
801023ee:	c3                   	ret    

801023ef <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801023ef:	55                   	push   %ebp
801023f0:	89 e5                	mov    %esp,%ebp
801023f2:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801023f5:	8b 45 08             	mov    0x8(%ebp),%eax
801023f8:	0f b6 00             	movzbl (%eax),%eax
801023fb:	3c 2f                	cmp    $0x2f,%al
801023fd:	75 17                	jne    80102416 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
801023ff:	83 ec 08             	sub    $0x8,%esp
80102402:	6a 01                	push   $0x1
80102404:	6a 01                	push   $0x1
80102406:	e8 b4 f4 ff ff       	call   801018bf <iget>
8010240b:	83 c4 10             	add    $0x10,%esp
8010240e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102411:	e9 ba 00 00 00       	jmp    801024d0 <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
80102416:	e8 06 16 00 00       	call   80103a21 <myproc>
8010241b:	8b 40 68             	mov    0x68(%eax),%eax
8010241e:	83 ec 0c             	sub    $0xc,%esp
80102421:	50                   	push   %eax
80102422:	e8 7a f5 ff ff       	call   801019a1 <idup>
80102427:	83 c4 10             	add    $0x10,%esp
8010242a:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010242d:	e9 9e 00 00 00       	jmp    801024d0 <namex+0xe1>
    ilock(ip);
80102432:	83 ec 0c             	sub    $0xc,%esp
80102435:	ff 75 f4             	push   -0xc(%ebp)
80102438:	e8 9e f5 ff ff       	call   801019db <ilock>
8010243d:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102440:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102443:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102447:	66 83 f8 01          	cmp    $0x1,%ax
8010244b:	74 18                	je     80102465 <namex+0x76>
      iunlockput(ip);
8010244d:	83 ec 0c             	sub    $0xc,%esp
80102450:	ff 75 f4             	push   -0xc(%ebp)
80102453:	e8 b4 f7 ff ff       	call   80101c0c <iunlockput>
80102458:	83 c4 10             	add    $0x10,%esp
      return 0;
8010245b:	b8 00 00 00 00       	mov    $0x0,%eax
80102460:	e9 a7 00 00 00       	jmp    8010250c <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
80102465:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102469:	74 20                	je     8010248b <namex+0x9c>
8010246b:	8b 45 08             	mov    0x8(%ebp),%eax
8010246e:	0f b6 00             	movzbl (%eax),%eax
80102471:	84 c0                	test   %al,%al
80102473:	75 16                	jne    8010248b <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
80102475:	83 ec 0c             	sub    $0xc,%esp
80102478:	ff 75 f4             	push   -0xc(%ebp)
8010247b:	e8 6e f6 ff ff       	call   80101aee <iunlock>
80102480:	83 c4 10             	add    $0x10,%esp
      return ip;
80102483:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102486:	e9 81 00 00 00       	jmp    8010250c <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010248b:	83 ec 04             	sub    $0x4,%esp
8010248e:	6a 00                	push   $0x0
80102490:	ff 75 10             	push   0x10(%ebp)
80102493:	ff 75 f4             	push   -0xc(%ebp)
80102496:	e8 22 fd ff ff       	call   801021bd <dirlookup>
8010249b:	83 c4 10             	add    $0x10,%esp
8010249e:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024a1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024a5:	75 15                	jne    801024bc <namex+0xcd>
      iunlockput(ip);
801024a7:	83 ec 0c             	sub    $0xc,%esp
801024aa:	ff 75 f4             	push   -0xc(%ebp)
801024ad:	e8 5a f7 ff ff       	call   80101c0c <iunlockput>
801024b2:	83 c4 10             	add    $0x10,%esp
      return 0;
801024b5:	b8 00 00 00 00       	mov    $0x0,%eax
801024ba:	eb 50                	jmp    8010250c <namex+0x11d>
    }
    iunlockput(ip);
801024bc:	83 ec 0c             	sub    $0xc,%esp
801024bf:	ff 75 f4             	push   -0xc(%ebp)
801024c2:	e8 45 f7 ff ff       	call   80101c0c <iunlockput>
801024c7:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801024d0:	83 ec 08             	sub    $0x8,%esp
801024d3:	ff 75 10             	push   0x10(%ebp)
801024d6:	ff 75 08             	push   0x8(%ebp)
801024d9:	e8 71 fe ff ff       	call   8010234f <skipelem>
801024de:	83 c4 10             	add    $0x10,%esp
801024e1:	89 45 08             	mov    %eax,0x8(%ebp)
801024e4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024e8:	0f 85 44 ff ff ff    	jne    80102432 <namex+0x43>
  }
  if(nameiparent){
801024ee:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801024f2:	74 15                	je     80102509 <namex+0x11a>
    iput(ip);
801024f4:	83 ec 0c             	sub    $0xc,%esp
801024f7:	ff 75 f4             	push   -0xc(%ebp)
801024fa:	e8 3d f6 ff ff       	call   80101b3c <iput>
801024ff:	83 c4 10             	add    $0x10,%esp
    return 0;
80102502:	b8 00 00 00 00       	mov    $0x0,%eax
80102507:	eb 03                	jmp    8010250c <namex+0x11d>
  }
  return ip;
80102509:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010250c:	c9                   	leave  
8010250d:	c3                   	ret    

8010250e <namei>:

struct inode*
namei(char *path)
{
8010250e:	55                   	push   %ebp
8010250f:	89 e5                	mov    %esp,%ebp
80102511:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102514:	83 ec 04             	sub    $0x4,%esp
80102517:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010251a:	50                   	push   %eax
8010251b:	6a 00                	push   $0x0
8010251d:	ff 75 08             	push   0x8(%ebp)
80102520:	e8 ca fe ff ff       	call   801023ef <namex>
80102525:	83 c4 10             	add    $0x10,%esp
}
80102528:	c9                   	leave  
80102529:	c3                   	ret    

8010252a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
8010252a:	55                   	push   %ebp
8010252b:	89 e5                	mov    %esp,%ebp
8010252d:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102530:	83 ec 04             	sub    $0x4,%esp
80102533:	ff 75 0c             	push   0xc(%ebp)
80102536:	6a 01                	push   $0x1
80102538:	ff 75 08             	push   0x8(%ebp)
8010253b:	e8 af fe ff ff       	call   801023ef <namex>
80102540:	83 c4 10             	add    $0x10,%esp
}
80102543:	c9                   	leave  
80102544:	c3                   	ret    

80102545 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102545:	55                   	push   %ebp
80102546:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102548:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010254d:	8b 55 08             	mov    0x8(%ebp),%edx
80102550:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102552:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102557:	8b 40 10             	mov    0x10(%eax),%eax
}
8010255a:	5d                   	pop    %ebp
8010255b:	c3                   	ret    

8010255c <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
8010255c:	55                   	push   %ebp
8010255d:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010255f:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102564:	8b 55 08             	mov    0x8(%ebp),%edx
80102567:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102569:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010256e:	8b 55 0c             	mov    0xc(%ebp),%edx
80102571:	89 50 10             	mov    %edx,0x10(%eax)
}
80102574:	90                   	nop
80102575:	5d                   	pop    %ebp
80102576:	c3                   	ret    

80102577 <ioapicinit>:

void
ioapicinit(void)
{
80102577:	55                   	push   %ebp
80102578:	89 e5                	mov    %esp,%ebp
8010257a:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
8010257d:	c7 05 b4 40 19 80 00 	movl   $0xfec00000,0x801940b4
80102584:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102587:	6a 01                	push   $0x1
80102589:	e8 b7 ff ff ff       	call   80102545 <ioapicread>
8010258e:	83 c4 04             	add    $0x4,%esp
80102591:	c1 e8 10             	shr    $0x10,%eax
80102594:	25 ff 00 00 00       	and    $0xff,%eax
80102599:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
8010259c:	6a 00                	push   $0x0
8010259e:	e8 a2 ff ff ff       	call   80102545 <ioapicread>
801025a3:	83 c4 04             	add    $0x4,%esp
801025a6:	c1 e8 18             	shr    $0x18,%eax
801025a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801025ac:	0f b6 05 44 6c 19 80 	movzbl 0x80196c44,%eax
801025b3:	0f b6 c0             	movzbl %al,%eax
801025b6:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801025b9:	74 10                	je     801025cb <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801025bb:	83 ec 0c             	sub    $0xc,%esp
801025be:	68 b4 a2 10 80       	push   $0x8010a2b4
801025c3:	e8 2c de ff ff       	call   801003f4 <cprintf>
801025c8:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801025cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025d2:	eb 3f                	jmp    80102613 <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801025d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025d7:	83 c0 20             	add    $0x20,%eax
801025da:	0d 00 00 01 00       	or     $0x10000,%eax
801025df:	89 c2                	mov    %eax,%edx
801025e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025e4:	83 c0 08             	add    $0x8,%eax
801025e7:	01 c0                	add    %eax,%eax
801025e9:	83 ec 08             	sub    $0x8,%esp
801025ec:	52                   	push   %edx
801025ed:	50                   	push   %eax
801025ee:	e8 69 ff ff ff       	call   8010255c <ioapicwrite>
801025f3:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
801025f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025f9:	83 c0 08             	add    $0x8,%eax
801025fc:	01 c0                	add    %eax,%eax
801025fe:	83 c0 01             	add    $0x1,%eax
80102601:	83 ec 08             	sub    $0x8,%esp
80102604:	6a 00                	push   $0x0
80102606:	50                   	push   %eax
80102607:	e8 50 ff ff ff       	call   8010255c <ioapicwrite>
8010260c:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
8010260f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102613:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102616:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102619:	7e b9                	jle    801025d4 <ioapicinit+0x5d>
  }
}
8010261b:	90                   	nop
8010261c:	90                   	nop
8010261d:	c9                   	leave  
8010261e:	c3                   	ret    

8010261f <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010261f:	55                   	push   %ebp
80102620:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102622:	8b 45 08             	mov    0x8(%ebp),%eax
80102625:	83 c0 20             	add    $0x20,%eax
80102628:	89 c2                	mov    %eax,%edx
8010262a:	8b 45 08             	mov    0x8(%ebp),%eax
8010262d:	83 c0 08             	add    $0x8,%eax
80102630:	01 c0                	add    %eax,%eax
80102632:	52                   	push   %edx
80102633:	50                   	push   %eax
80102634:	e8 23 ff ff ff       	call   8010255c <ioapicwrite>
80102639:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010263c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010263f:	c1 e0 18             	shl    $0x18,%eax
80102642:	89 c2                	mov    %eax,%edx
80102644:	8b 45 08             	mov    0x8(%ebp),%eax
80102647:	83 c0 08             	add    $0x8,%eax
8010264a:	01 c0                	add    %eax,%eax
8010264c:	83 c0 01             	add    $0x1,%eax
8010264f:	52                   	push   %edx
80102650:	50                   	push   %eax
80102651:	e8 06 ff ff ff       	call   8010255c <ioapicwrite>
80102656:	83 c4 08             	add    $0x8,%esp
}
80102659:	90                   	nop
8010265a:	c9                   	leave  
8010265b:	c3                   	ret    

8010265c <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
8010265c:	55                   	push   %ebp
8010265d:	89 e5                	mov    %esp,%ebp
8010265f:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102662:	83 ec 08             	sub    $0x8,%esp
80102665:	68 e6 a2 10 80       	push   $0x8010a2e6
8010266a:	68 c0 40 19 80       	push   $0x801940c0
8010266f:	e8 a5 21 00 00       	call   80104819 <initlock>
80102674:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102677:	c7 05 f4 40 19 80 00 	movl   $0x0,0x801940f4
8010267e:	00 00 00 
  freerange(vstart, vend);
80102681:	83 ec 08             	sub    $0x8,%esp
80102684:	ff 75 0c             	push   0xc(%ebp)
80102687:	ff 75 08             	push   0x8(%ebp)
8010268a:	e8 2a 00 00 00       	call   801026b9 <freerange>
8010268f:	83 c4 10             	add    $0x10,%esp
}
80102692:	90                   	nop
80102693:	c9                   	leave  
80102694:	c3                   	ret    

80102695 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102695:	55                   	push   %ebp
80102696:	89 e5                	mov    %esp,%ebp
80102698:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
8010269b:	83 ec 08             	sub    $0x8,%esp
8010269e:	ff 75 0c             	push   0xc(%ebp)
801026a1:	ff 75 08             	push   0x8(%ebp)
801026a4:	e8 10 00 00 00       	call   801026b9 <freerange>
801026a9:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
801026ac:	c7 05 f4 40 19 80 01 	movl   $0x1,0x801940f4
801026b3:	00 00 00 
}
801026b6:	90                   	nop
801026b7:	c9                   	leave  
801026b8:	c3                   	ret    

801026b9 <freerange>:

void
freerange(void *vstart, void *vend)
{
801026b9:	55                   	push   %ebp
801026ba:	89 e5                	mov    %esp,%ebp
801026bc:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801026bf:	8b 45 08             	mov    0x8(%ebp),%eax
801026c2:	05 ff 0f 00 00       	add    $0xfff,%eax
801026c7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801026cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026cf:	eb 15                	jmp    801026e6 <freerange+0x2d>
    kfree(p);
801026d1:	83 ec 0c             	sub    $0xc,%esp
801026d4:	ff 75 f4             	push   -0xc(%ebp)
801026d7:	e8 1b 00 00 00       	call   801026f7 <kfree>
801026dc:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026df:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801026e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026e9:	05 00 10 00 00       	add    $0x1000,%eax
801026ee:	39 45 0c             	cmp    %eax,0xc(%ebp)
801026f1:	73 de                	jae    801026d1 <freerange+0x18>
}
801026f3:	90                   	nop
801026f4:	90                   	nop
801026f5:	c9                   	leave  
801026f6:	c3                   	ret    

801026f7 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
801026f7:	55                   	push   %ebp
801026f8:	89 e5                	mov    %esp,%ebp
801026fa:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
801026fd:	8b 45 08             	mov    0x8(%ebp),%eax
80102700:	25 ff 0f 00 00       	and    $0xfff,%eax
80102705:	85 c0                	test   %eax,%eax
80102707:	75 18                	jne    80102721 <kfree+0x2a>
80102709:	81 7d 08 00 80 19 80 	cmpl   $0x80198000,0x8(%ebp)
80102710:	72 0f                	jb     80102721 <kfree+0x2a>
80102712:	8b 45 08             	mov    0x8(%ebp),%eax
80102715:	05 00 00 00 80       	add    $0x80000000,%eax
8010271a:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
8010271f:	76 0d                	jbe    8010272e <kfree+0x37>
    panic("kfree");
80102721:	83 ec 0c             	sub    $0xc,%esp
80102724:	68 eb a2 10 80       	push   $0x8010a2eb
80102729:	e8 7b de ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010272e:	83 ec 04             	sub    $0x4,%esp
80102731:	68 00 10 00 00       	push   $0x1000
80102736:	6a 01                	push   $0x1
80102738:	ff 75 08             	push   0x8(%ebp)
8010273b:	e8 71 23 00 00       	call   80104ab1 <memset>
80102740:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102743:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102748:	85 c0                	test   %eax,%eax
8010274a:	74 10                	je     8010275c <kfree+0x65>
    acquire(&kmem.lock);
8010274c:	83 ec 0c             	sub    $0xc,%esp
8010274f:	68 c0 40 19 80       	push   $0x801940c0
80102754:	e8 e2 20 00 00       	call   8010483b <acquire>
80102759:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
8010275c:	8b 45 08             	mov    0x8(%ebp),%eax
8010275f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102762:	8b 15 f8 40 19 80    	mov    0x801940f8,%edx
80102768:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010276b:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
8010276d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102770:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
80102775:	a1 f4 40 19 80       	mov    0x801940f4,%eax
8010277a:	85 c0                	test   %eax,%eax
8010277c:	74 10                	je     8010278e <kfree+0x97>
    release(&kmem.lock);
8010277e:	83 ec 0c             	sub    $0xc,%esp
80102781:	68 c0 40 19 80       	push   $0x801940c0
80102786:	e8 1e 21 00 00       	call   801048a9 <release>
8010278b:	83 c4 10             	add    $0x10,%esp
}
8010278e:	90                   	nop
8010278f:	c9                   	leave  
80102790:	c3                   	ret    

80102791 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102791:	55                   	push   %ebp
80102792:	89 e5                	mov    %esp,%ebp
80102794:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102797:	a1 f4 40 19 80       	mov    0x801940f4,%eax
8010279c:	85 c0                	test   %eax,%eax
8010279e:	74 10                	je     801027b0 <kalloc+0x1f>
    acquire(&kmem.lock);
801027a0:	83 ec 0c             	sub    $0xc,%esp
801027a3:	68 c0 40 19 80       	push   $0x801940c0
801027a8:	e8 8e 20 00 00       	call   8010483b <acquire>
801027ad:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801027b0:	a1 f8 40 19 80       	mov    0x801940f8,%eax
801027b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801027b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027bc:	74 0a                	je     801027c8 <kalloc+0x37>
    kmem.freelist = r->next;
801027be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027c1:	8b 00                	mov    (%eax),%eax
801027c3:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
801027c8:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027cd:	85 c0                	test   %eax,%eax
801027cf:	74 10                	je     801027e1 <kalloc+0x50>
    release(&kmem.lock);
801027d1:	83 ec 0c             	sub    $0xc,%esp
801027d4:	68 c0 40 19 80       	push   $0x801940c0
801027d9:	e8 cb 20 00 00       	call   801048a9 <release>
801027de:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801027e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801027e4:	c9                   	leave  
801027e5:	c3                   	ret    

801027e6 <inb>:
{
801027e6:	55                   	push   %ebp
801027e7:	89 e5                	mov    %esp,%ebp
801027e9:	83 ec 14             	sub    $0x14,%esp
801027ec:	8b 45 08             	mov    0x8(%ebp),%eax
801027ef:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801027f3:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801027f7:	89 c2                	mov    %eax,%edx
801027f9:	ec                   	in     (%dx),%al
801027fa:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801027fd:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102801:	c9                   	leave  
80102802:	c3                   	ret    

80102803 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102803:	55                   	push   %ebp
80102804:	89 e5                	mov    %esp,%ebp
80102806:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102809:	6a 64                	push   $0x64
8010280b:	e8 d6 ff ff ff       	call   801027e6 <inb>
80102810:	83 c4 04             	add    $0x4,%esp
80102813:	0f b6 c0             	movzbl %al,%eax
80102816:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102819:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010281c:	83 e0 01             	and    $0x1,%eax
8010281f:	85 c0                	test   %eax,%eax
80102821:	75 0a                	jne    8010282d <kbdgetc+0x2a>
    return -1;
80102823:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102828:	e9 23 01 00 00       	jmp    80102950 <kbdgetc+0x14d>
  data = inb(KBDATAP);
8010282d:	6a 60                	push   $0x60
8010282f:	e8 b2 ff ff ff       	call   801027e6 <inb>
80102834:	83 c4 04             	add    $0x4,%esp
80102837:	0f b6 c0             	movzbl %al,%eax
8010283a:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
8010283d:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102844:	75 17                	jne    8010285d <kbdgetc+0x5a>
    shift |= E0ESC;
80102846:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010284b:	83 c8 40             	or     $0x40,%eax
8010284e:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
80102853:	b8 00 00 00 00       	mov    $0x0,%eax
80102858:	e9 f3 00 00 00       	jmp    80102950 <kbdgetc+0x14d>
  } else if(data & 0x80){
8010285d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102860:	25 80 00 00 00       	and    $0x80,%eax
80102865:	85 c0                	test   %eax,%eax
80102867:	74 45                	je     801028ae <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102869:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010286e:	83 e0 40             	and    $0x40,%eax
80102871:	85 c0                	test   %eax,%eax
80102873:	75 08                	jne    8010287d <kbdgetc+0x7a>
80102875:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102878:	83 e0 7f             	and    $0x7f,%eax
8010287b:	eb 03                	jmp    80102880 <kbdgetc+0x7d>
8010287d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102880:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102883:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102886:	05 20 d0 10 80       	add    $0x8010d020,%eax
8010288b:	0f b6 00             	movzbl (%eax),%eax
8010288e:	83 c8 40             	or     $0x40,%eax
80102891:	0f b6 c0             	movzbl %al,%eax
80102894:	f7 d0                	not    %eax
80102896:	89 c2                	mov    %eax,%edx
80102898:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010289d:	21 d0                	and    %edx,%eax
8010289f:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
801028a4:	b8 00 00 00 00       	mov    $0x0,%eax
801028a9:	e9 a2 00 00 00       	jmp    80102950 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
801028ae:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028b3:	83 e0 40             	and    $0x40,%eax
801028b6:	85 c0                	test   %eax,%eax
801028b8:	74 14                	je     801028ce <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801028ba:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801028c1:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028c6:	83 e0 bf             	and    $0xffffffbf,%eax
801028c9:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  }

  shift |= shiftcode[data];
801028ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028d1:	05 20 d0 10 80       	add    $0x8010d020,%eax
801028d6:	0f b6 00             	movzbl (%eax),%eax
801028d9:	0f b6 d0             	movzbl %al,%edx
801028dc:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028e1:	09 d0                	or     %edx,%eax
801028e3:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  shift ^= togglecode[data];
801028e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028eb:	05 20 d1 10 80       	add    $0x8010d120,%eax
801028f0:	0f b6 00             	movzbl (%eax),%eax
801028f3:	0f b6 d0             	movzbl %al,%edx
801028f6:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028fb:	31 d0                	xor    %edx,%eax
801028fd:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  c = charcode[shift & (CTL | SHIFT)][data];
80102902:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102907:	83 e0 03             	and    $0x3,%eax
8010290a:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102911:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102914:	01 d0                	add    %edx,%eax
80102916:	0f b6 00             	movzbl (%eax),%eax
80102919:	0f b6 c0             	movzbl %al,%eax
8010291c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
8010291f:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102924:	83 e0 08             	and    $0x8,%eax
80102927:	85 c0                	test   %eax,%eax
80102929:	74 22                	je     8010294d <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
8010292b:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
8010292f:	76 0c                	jbe    8010293d <kbdgetc+0x13a>
80102931:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102935:	77 06                	ja     8010293d <kbdgetc+0x13a>
      c += 'A' - 'a';
80102937:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
8010293b:	eb 10                	jmp    8010294d <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
8010293d:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102941:	76 0a                	jbe    8010294d <kbdgetc+0x14a>
80102943:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102947:	77 04                	ja     8010294d <kbdgetc+0x14a>
      c += 'a' - 'A';
80102949:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
8010294d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102950:	c9                   	leave  
80102951:	c3                   	ret    

80102952 <kbdintr>:

void
kbdintr(void)
{
80102952:	55                   	push   %ebp
80102953:	89 e5                	mov    %esp,%ebp
80102955:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102958:	83 ec 0c             	sub    $0xc,%esp
8010295b:	68 03 28 10 80       	push   $0x80102803
80102960:	e8 71 de ff ff       	call   801007d6 <consoleintr>
80102965:	83 c4 10             	add    $0x10,%esp
}
80102968:	90                   	nop
80102969:	c9                   	leave  
8010296a:	c3                   	ret    

8010296b <inb>:
{
8010296b:	55                   	push   %ebp
8010296c:	89 e5                	mov    %esp,%ebp
8010296e:	83 ec 14             	sub    $0x14,%esp
80102971:	8b 45 08             	mov    0x8(%ebp),%eax
80102974:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102978:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010297c:	89 c2                	mov    %eax,%edx
8010297e:	ec                   	in     (%dx),%al
8010297f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102982:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102986:	c9                   	leave  
80102987:	c3                   	ret    

80102988 <outb>:
{
80102988:	55                   	push   %ebp
80102989:	89 e5                	mov    %esp,%ebp
8010298b:	83 ec 08             	sub    $0x8,%esp
8010298e:	8b 45 08             	mov    0x8(%ebp),%eax
80102991:	8b 55 0c             	mov    0xc(%ebp),%edx
80102994:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102998:	89 d0                	mov    %edx,%eax
8010299a:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010299d:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801029a1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801029a5:	ee                   	out    %al,(%dx)
}
801029a6:	90                   	nop
801029a7:	c9                   	leave  
801029a8:	c3                   	ret    

801029a9 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
801029a9:	55                   	push   %ebp
801029aa:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801029ac:	8b 15 00 41 19 80    	mov    0x80194100,%edx
801029b2:	8b 45 08             	mov    0x8(%ebp),%eax
801029b5:	c1 e0 02             	shl    $0x2,%eax
801029b8:	01 c2                	add    %eax,%edx
801029ba:	8b 45 0c             	mov    0xc(%ebp),%eax
801029bd:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801029bf:	a1 00 41 19 80       	mov    0x80194100,%eax
801029c4:	83 c0 20             	add    $0x20,%eax
801029c7:	8b 00                	mov    (%eax),%eax
}
801029c9:	90                   	nop
801029ca:	5d                   	pop    %ebp
801029cb:	c3                   	ret    

801029cc <lapicinit>:

void
lapicinit(void)
{
801029cc:	55                   	push   %ebp
801029cd:	89 e5                	mov    %esp,%ebp
  if(!lapic)
801029cf:	a1 00 41 19 80       	mov    0x80194100,%eax
801029d4:	85 c0                	test   %eax,%eax
801029d6:	0f 84 0c 01 00 00    	je     80102ae8 <lapicinit+0x11c>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801029dc:	68 3f 01 00 00       	push   $0x13f
801029e1:	6a 3c                	push   $0x3c
801029e3:	e8 c1 ff ff ff       	call   801029a9 <lapicw>
801029e8:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801029eb:	6a 0b                	push   $0xb
801029ed:	68 f8 00 00 00       	push   $0xf8
801029f2:	e8 b2 ff ff ff       	call   801029a9 <lapicw>
801029f7:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801029fa:	68 20 00 02 00       	push   $0x20020
801029ff:	68 c8 00 00 00       	push   $0xc8
80102a04:	e8 a0 ff ff ff       	call   801029a9 <lapicw>
80102a09:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102a0c:	68 80 96 98 00       	push   $0x989680
80102a11:	68 e0 00 00 00       	push   $0xe0
80102a16:	e8 8e ff ff ff       	call   801029a9 <lapicw>
80102a1b:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102a1e:	68 00 00 01 00       	push   $0x10000
80102a23:	68 d4 00 00 00       	push   $0xd4
80102a28:	e8 7c ff ff ff       	call   801029a9 <lapicw>
80102a2d:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102a30:	68 00 00 01 00       	push   $0x10000
80102a35:	68 d8 00 00 00       	push   $0xd8
80102a3a:	e8 6a ff ff ff       	call   801029a9 <lapicw>
80102a3f:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102a42:	a1 00 41 19 80       	mov    0x80194100,%eax
80102a47:	83 c0 30             	add    $0x30,%eax
80102a4a:	8b 00                	mov    (%eax),%eax
80102a4c:	c1 e8 10             	shr    $0x10,%eax
80102a4f:	25 fc 00 00 00       	and    $0xfc,%eax
80102a54:	85 c0                	test   %eax,%eax
80102a56:	74 12                	je     80102a6a <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
80102a58:	68 00 00 01 00       	push   $0x10000
80102a5d:	68 d0 00 00 00       	push   $0xd0
80102a62:	e8 42 ff ff ff       	call   801029a9 <lapicw>
80102a67:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102a6a:	6a 33                	push   $0x33
80102a6c:	68 dc 00 00 00       	push   $0xdc
80102a71:	e8 33 ff ff ff       	call   801029a9 <lapicw>
80102a76:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102a79:	6a 00                	push   $0x0
80102a7b:	68 a0 00 00 00       	push   $0xa0
80102a80:	e8 24 ff ff ff       	call   801029a9 <lapicw>
80102a85:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102a88:	6a 00                	push   $0x0
80102a8a:	68 a0 00 00 00       	push   $0xa0
80102a8f:	e8 15 ff ff ff       	call   801029a9 <lapicw>
80102a94:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102a97:	6a 00                	push   $0x0
80102a99:	6a 2c                	push   $0x2c
80102a9b:	e8 09 ff ff ff       	call   801029a9 <lapicw>
80102aa0:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102aa3:	6a 00                	push   $0x0
80102aa5:	68 c4 00 00 00       	push   $0xc4
80102aaa:	e8 fa fe ff ff       	call   801029a9 <lapicw>
80102aaf:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102ab2:	68 00 85 08 00       	push   $0x88500
80102ab7:	68 c0 00 00 00       	push   $0xc0
80102abc:	e8 e8 fe ff ff       	call   801029a9 <lapicw>
80102ac1:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102ac4:	90                   	nop
80102ac5:	a1 00 41 19 80       	mov    0x80194100,%eax
80102aca:	05 00 03 00 00       	add    $0x300,%eax
80102acf:	8b 00                	mov    (%eax),%eax
80102ad1:	25 00 10 00 00       	and    $0x1000,%eax
80102ad6:	85 c0                	test   %eax,%eax
80102ad8:	75 eb                	jne    80102ac5 <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102ada:	6a 00                	push   $0x0
80102adc:	6a 20                	push   $0x20
80102ade:	e8 c6 fe ff ff       	call   801029a9 <lapicw>
80102ae3:	83 c4 08             	add    $0x8,%esp
80102ae6:	eb 01                	jmp    80102ae9 <lapicinit+0x11d>
    return;
80102ae8:	90                   	nop
}
80102ae9:	c9                   	leave  
80102aea:	c3                   	ret    

80102aeb <lapicid>:

int
lapicid(void)
{
80102aeb:	55                   	push   %ebp
80102aec:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102aee:	a1 00 41 19 80       	mov    0x80194100,%eax
80102af3:	85 c0                	test   %eax,%eax
80102af5:	75 07                	jne    80102afe <lapicid+0x13>
    return 0;
80102af7:	b8 00 00 00 00       	mov    $0x0,%eax
80102afc:	eb 0d                	jmp    80102b0b <lapicid+0x20>
  }
  return lapic[ID] >> 24;
80102afe:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b03:	83 c0 20             	add    $0x20,%eax
80102b06:	8b 00                	mov    (%eax),%eax
80102b08:	c1 e8 18             	shr    $0x18,%eax
}
80102b0b:	5d                   	pop    %ebp
80102b0c:	c3                   	ret    

80102b0d <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102b0d:	55                   	push   %ebp
80102b0e:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102b10:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b15:	85 c0                	test   %eax,%eax
80102b17:	74 0c                	je     80102b25 <lapiceoi+0x18>
    lapicw(EOI, 0);
80102b19:	6a 00                	push   $0x0
80102b1b:	6a 2c                	push   $0x2c
80102b1d:	e8 87 fe ff ff       	call   801029a9 <lapicw>
80102b22:	83 c4 08             	add    $0x8,%esp
}
80102b25:	90                   	nop
80102b26:	c9                   	leave  
80102b27:	c3                   	ret    

80102b28 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102b28:	55                   	push   %ebp
80102b29:	89 e5                	mov    %esp,%ebp
}
80102b2b:	90                   	nop
80102b2c:	5d                   	pop    %ebp
80102b2d:	c3                   	ret    

80102b2e <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102b2e:	55                   	push   %ebp
80102b2f:	89 e5                	mov    %esp,%ebp
80102b31:	83 ec 14             	sub    $0x14,%esp
80102b34:	8b 45 08             	mov    0x8(%ebp),%eax
80102b37:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102b3a:	6a 0f                	push   $0xf
80102b3c:	6a 70                	push   $0x70
80102b3e:	e8 45 fe ff ff       	call   80102988 <outb>
80102b43:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102b46:	6a 0a                	push   $0xa
80102b48:	6a 71                	push   $0x71
80102b4a:	e8 39 fe ff ff       	call   80102988 <outb>
80102b4f:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102b52:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102b59:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b5c:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102b61:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b64:	c1 e8 04             	shr    $0x4,%eax
80102b67:	89 c2                	mov    %eax,%edx
80102b69:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b6c:	83 c0 02             	add    $0x2,%eax
80102b6f:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102b72:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102b76:	c1 e0 18             	shl    $0x18,%eax
80102b79:	50                   	push   %eax
80102b7a:	68 c4 00 00 00       	push   $0xc4
80102b7f:	e8 25 fe ff ff       	call   801029a9 <lapicw>
80102b84:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102b87:	68 00 c5 00 00       	push   $0xc500
80102b8c:	68 c0 00 00 00       	push   $0xc0
80102b91:	e8 13 fe ff ff       	call   801029a9 <lapicw>
80102b96:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102b99:	68 c8 00 00 00       	push   $0xc8
80102b9e:	e8 85 ff ff ff       	call   80102b28 <microdelay>
80102ba3:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102ba6:	68 00 85 00 00       	push   $0x8500
80102bab:	68 c0 00 00 00       	push   $0xc0
80102bb0:	e8 f4 fd ff ff       	call   801029a9 <lapicw>
80102bb5:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102bb8:	6a 64                	push   $0x64
80102bba:	e8 69 ff ff ff       	call   80102b28 <microdelay>
80102bbf:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102bc2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102bc9:	eb 3d                	jmp    80102c08 <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
80102bcb:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102bcf:	c1 e0 18             	shl    $0x18,%eax
80102bd2:	50                   	push   %eax
80102bd3:	68 c4 00 00 00       	push   $0xc4
80102bd8:	e8 cc fd ff ff       	call   801029a9 <lapicw>
80102bdd:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102be0:	8b 45 0c             	mov    0xc(%ebp),%eax
80102be3:	c1 e8 0c             	shr    $0xc,%eax
80102be6:	80 cc 06             	or     $0x6,%ah
80102be9:	50                   	push   %eax
80102bea:	68 c0 00 00 00       	push   $0xc0
80102bef:	e8 b5 fd ff ff       	call   801029a9 <lapicw>
80102bf4:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102bf7:	68 c8 00 00 00       	push   $0xc8
80102bfc:	e8 27 ff ff ff       	call   80102b28 <microdelay>
80102c01:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102c04:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102c08:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102c0c:	7e bd                	jle    80102bcb <lapicstartap+0x9d>
  }
}
80102c0e:	90                   	nop
80102c0f:	90                   	nop
80102c10:	c9                   	leave  
80102c11:	c3                   	ret    

80102c12 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102c12:	55                   	push   %ebp
80102c13:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102c15:	8b 45 08             	mov    0x8(%ebp),%eax
80102c18:	0f b6 c0             	movzbl %al,%eax
80102c1b:	50                   	push   %eax
80102c1c:	6a 70                	push   $0x70
80102c1e:	e8 65 fd ff ff       	call   80102988 <outb>
80102c23:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102c26:	68 c8 00 00 00       	push   $0xc8
80102c2b:	e8 f8 fe ff ff       	call   80102b28 <microdelay>
80102c30:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102c33:	6a 71                	push   $0x71
80102c35:	e8 31 fd ff ff       	call   8010296b <inb>
80102c3a:	83 c4 04             	add    $0x4,%esp
80102c3d:	0f b6 c0             	movzbl %al,%eax
}
80102c40:	c9                   	leave  
80102c41:	c3                   	ret    

80102c42 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102c42:	55                   	push   %ebp
80102c43:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102c45:	6a 00                	push   $0x0
80102c47:	e8 c6 ff ff ff       	call   80102c12 <cmos_read>
80102c4c:	83 c4 04             	add    $0x4,%esp
80102c4f:	8b 55 08             	mov    0x8(%ebp),%edx
80102c52:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102c54:	6a 02                	push   $0x2
80102c56:	e8 b7 ff ff ff       	call   80102c12 <cmos_read>
80102c5b:	83 c4 04             	add    $0x4,%esp
80102c5e:	8b 55 08             	mov    0x8(%ebp),%edx
80102c61:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102c64:	6a 04                	push   $0x4
80102c66:	e8 a7 ff ff ff       	call   80102c12 <cmos_read>
80102c6b:	83 c4 04             	add    $0x4,%esp
80102c6e:	8b 55 08             	mov    0x8(%ebp),%edx
80102c71:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102c74:	6a 07                	push   $0x7
80102c76:	e8 97 ff ff ff       	call   80102c12 <cmos_read>
80102c7b:	83 c4 04             	add    $0x4,%esp
80102c7e:	8b 55 08             	mov    0x8(%ebp),%edx
80102c81:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102c84:	6a 08                	push   $0x8
80102c86:	e8 87 ff ff ff       	call   80102c12 <cmos_read>
80102c8b:	83 c4 04             	add    $0x4,%esp
80102c8e:	8b 55 08             	mov    0x8(%ebp),%edx
80102c91:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102c94:	6a 09                	push   $0x9
80102c96:	e8 77 ff ff ff       	call   80102c12 <cmos_read>
80102c9b:	83 c4 04             	add    $0x4,%esp
80102c9e:	8b 55 08             	mov    0x8(%ebp),%edx
80102ca1:	89 42 14             	mov    %eax,0x14(%edx)
}
80102ca4:	90                   	nop
80102ca5:	c9                   	leave  
80102ca6:	c3                   	ret    

80102ca7 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102ca7:	55                   	push   %ebp
80102ca8:	89 e5                	mov    %esp,%ebp
80102caa:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102cad:	6a 0b                	push   $0xb
80102caf:	e8 5e ff ff ff       	call   80102c12 <cmos_read>
80102cb4:	83 c4 04             	add    $0x4,%esp
80102cb7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102cba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cbd:	83 e0 04             	and    $0x4,%eax
80102cc0:	85 c0                	test   %eax,%eax
80102cc2:	0f 94 c0             	sete   %al
80102cc5:	0f b6 c0             	movzbl %al,%eax
80102cc8:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102ccb:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102cce:	50                   	push   %eax
80102ccf:	e8 6e ff ff ff       	call   80102c42 <fill_rtcdate>
80102cd4:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102cd7:	6a 0a                	push   $0xa
80102cd9:	e8 34 ff ff ff       	call   80102c12 <cmos_read>
80102cde:	83 c4 04             	add    $0x4,%esp
80102ce1:	25 80 00 00 00       	and    $0x80,%eax
80102ce6:	85 c0                	test   %eax,%eax
80102ce8:	75 27                	jne    80102d11 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80102cea:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102ced:	50                   	push   %eax
80102cee:	e8 4f ff ff ff       	call   80102c42 <fill_rtcdate>
80102cf3:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102cf6:	83 ec 04             	sub    $0x4,%esp
80102cf9:	6a 18                	push   $0x18
80102cfb:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102cfe:	50                   	push   %eax
80102cff:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102d02:	50                   	push   %eax
80102d03:	e8 10 1e 00 00       	call   80104b18 <memcmp>
80102d08:	83 c4 10             	add    $0x10,%esp
80102d0b:	85 c0                	test   %eax,%eax
80102d0d:	74 05                	je     80102d14 <cmostime+0x6d>
80102d0f:	eb ba                	jmp    80102ccb <cmostime+0x24>
        continue;
80102d11:	90                   	nop
    fill_rtcdate(&t1);
80102d12:	eb b7                	jmp    80102ccb <cmostime+0x24>
      break;
80102d14:	90                   	nop
  }

  // convert
  if(bcd) {
80102d15:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102d19:	0f 84 b4 00 00 00    	je     80102dd3 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102d1f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d22:	c1 e8 04             	shr    $0x4,%eax
80102d25:	89 c2                	mov    %eax,%edx
80102d27:	89 d0                	mov    %edx,%eax
80102d29:	c1 e0 02             	shl    $0x2,%eax
80102d2c:	01 d0                	add    %edx,%eax
80102d2e:	01 c0                	add    %eax,%eax
80102d30:	89 c2                	mov    %eax,%edx
80102d32:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d35:	83 e0 0f             	and    $0xf,%eax
80102d38:	01 d0                	add    %edx,%eax
80102d3a:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102d3d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d40:	c1 e8 04             	shr    $0x4,%eax
80102d43:	89 c2                	mov    %eax,%edx
80102d45:	89 d0                	mov    %edx,%eax
80102d47:	c1 e0 02             	shl    $0x2,%eax
80102d4a:	01 d0                	add    %edx,%eax
80102d4c:	01 c0                	add    %eax,%eax
80102d4e:	89 c2                	mov    %eax,%edx
80102d50:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d53:	83 e0 0f             	and    $0xf,%eax
80102d56:	01 d0                	add    %edx,%eax
80102d58:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102d5b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d5e:	c1 e8 04             	shr    $0x4,%eax
80102d61:	89 c2                	mov    %eax,%edx
80102d63:	89 d0                	mov    %edx,%eax
80102d65:	c1 e0 02             	shl    $0x2,%eax
80102d68:	01 d0                	add    %edx,%eax
80102d6a:	01 c0                	add    %eax,%eax
80102d6c:	89 c2                	mov    %eax,%edx
80102d6e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d71:	83 e0 0f             	and    $0xf,%eax
80102d74:	01 d0                	add    %edx,%eax
80102d76:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102d79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d7c:	c1 e8 04             	shr    $0x4,%eax
80102d7f:	89 c2                	mov    %eax,%edx
80102d81:	89 d0                	mov    %edx,%eax
80102d83:	c1 e0 02             	shl    $0x2,%eax
80102d86:	01 d0                	add    %edx,%eax
80102d88:	01 c0                	add    %eax,%eax
80102d8a:	89 c2                	mov    %eax,%edx
80102d8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d8f:	83 e0 0f             	and    $0xf,%eax
80102d92:	01 d0                	add    %edx,%eax
80102d94:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102d97:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102d9a:	c1 e8 04             	shr    $0x4,%eax
80102d9d:	89 c2                	mov    %eax,%edx
80102d9f:	89 d0                	mov    %edx,%eax
80102da1:	c1 e0 02             	shl    $0x2,%eax
80102da4:	01 d0                	add    %edx,%eax
80102da6:	01 c0                	add    %eax,%eax
80102da8:	89 c2                	mov    %eax,%edx
80102daa:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102dad:	83 e0 0f             	and    $0xf,%eax
80102db0:	01 d0                	add    %edx,%eax
80102db2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102db5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102db8:	c1 e8 04             	shr    $0x4,%eax
80102dbb:	89 c2                	mov    %eax,%edx
80102dbd:	89 d0                	mov    %edx,%eax
80102dbf:	c1 e0 02             	shl    $0x2,%eax
80102dc2:	01 d0                	add    %edx,%eax
80102dc4:	01 c0                	add    %eax,%eax
80102dc6:	89 c2                	mov    %eax,%edx
80102dc8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dcb:	83 e0 0f             	and    $0xf,%eax
80102dce:	01 d0                	add    %edx,%eax
80102dd0:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102dd3:	8b 45 08             	mov    0x8(%ebp),%eax
80102dd6:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102dd9:	89 10                	mov    %edx,(%eax)
80102ddb:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102dde:	89 50 04             	mov    %edx,0x4(%eax)
80102de1:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102de4:	89 50 08             	mov    %edx,0x8(%eax)
80102de7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102dea:	89 50 0c             	mov    %edx,0xc(%eax)
80102ded:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102df0:	89 50 10             	mov    %edx,0x10(%eax)
80102df3:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102df6:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102df9:	8b 45 08             	mov    0x8(%ebp),%eax
80102dfc:	8b 40 14             	mov    0x14(%eax),%eax
80102dff:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102e05:	8b 45 08             	mov    0x8(%ebp),%eax
80102e08:	89 50 14             	mov    %edx,0x14(%eax)
}
80102e0b:	90                   	nop
80102e0c:	c9                   	leave  
80102e0d:	c3                   	ret    

80102e0e <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102e0e:	55                   	push   %ebp
80102e0f:	89 e5                	mov    %esp,%ebp
80102e11:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102e14:	83 ec 08             	sub    $0x8,%esp
80102e17:	68 f1 a2 10 80       	push   $0x8010a2f1
80102e1c:	68 20 41 19 80       	push   $0x80194120
80102e21:	e8 f3 19 00 00       	call   80104819 <initlock>
80102e26:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80102e29:	83 ec 08             	sub    $0x8,%esp
80102e2c:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102e2f:	50                   	push   %eax
80102e30:	ff 75 08             	push   0x8(%ebp)
80102e33:	e8 87 e5 ff ff       	call   801013bf <readsb>
80102e38:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80102e3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102e3e:	a3 54 41 19 80       	mov    %eax,0x80194154
  log.size = sb.nlog;
80102e43:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102e46:	a3 58 41 19 80       	mov    %eax,0x80194158
  log.dev = dev;
80102e4b:	8b 45 08             	mov    0x8(%ebp),%eax
80102e4e:	a3 64 41 19 80       	mov    %eax,0x80194164
  recover_from_log();
80102e53:	e8 b3 01 00 00       	call   8010300b <recover_from_log>
}
80102e58:	90                   	nop
80102e59:	c9                   	leave  
80102e5a:	c3                   	ret    

80102e5b <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102e5b:	55                   	push   %ebp
80102e5c:	89 e5                	mov    %esp,%ebp
80102e5e:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102e61:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e68:	e9 95 00 00 00       	jmp    80102f02 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102e6d:	8b 15 54 41 19 80    	mov    0x80194154,%edx
80102e73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e76:	01 d0                	add    %edx,%eax
80102e78:	83 c0 01             	add    $0x1,%eax
80102e7b:	89 c2                	mov    %eax,%edx
80102e7d:	a1 64 41 19 80       	mov    0x80194164,%eax
80102e82:	83 ec 08             	sub    $0x8,%esp
80102e85:	52                   	push   %edx
80102e86:	50                   	push   %eax
80102e87:	e8 75 d3 ff ff       	call   80100201 <bread>
80102e8c:	83 c4 10             	add    $0x10,%esp
80102e8f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102e92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e95:	83 c0 10             	add    $0x10,%eax
80102e98:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
80102e9f:	89 c2                	mov    %eax,%edx
80102ea1:	a1 64 41 19 80       	mov    0x80194164,%eax
80102ea6:	83 ec 08             	sub    $0x8,%esp
80102ea9:	52                   	push   %edx
80102eaa:	50                   	push   %eax
80102eab:	e8 51 d3 ff ff       	call   80100201 <bread>
80102eb0:	83 c4 10             	add    $0x10,%esp
80102eb3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102eb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102eb9:	8d 50 5c             	lea    0x5c(%eax),%edx
80102ebc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ebf:	83 c0 5c             	add    $0x5c,%eax
80102ec2:	83 ec 04             	sub    $0x4,%esp
80102ec5:	68 00 02 00 00       	push   $0x200
80102eca:	52                   	push   %edx
80102ecb:	50                   	push   %eax
80102ecc:	e8 9f 1c 00 00       	call   80104b70 <memmove>
80102ed1:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80102ed4:	83 ec 0c             	sub    $0xc,%esp
80102ed7:	ff 75 ec             	push   -0x14(%ebp)
80102eda:	e8 5b d3 ff ff       	call   8010023a <bwrite>
80102edf:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80102ee2:	83 ec 0c             	sub    $0xc,%esp
80102ee5:	ff 75 f0             	push   -0x10(%ebp)
80102ee8:	e8 96 d3 ff ff       	call   80100283 <brelse>
80102eed:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80102ef0:	83 ec 0c             	sub    $0xc,%esp
80102ef3:	ff 75 ec             	push   -0x14(%ebp)
80102ef6:	e8 88 d3 ff ff       	call   80100283 <brelse>
80102efb:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80102efe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f02:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f07:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f0a:	0f 8c 5d ff ff ff    	jl     80102e6d <install_trans+0x12>
  }
}
80102f10:	90                   	nop
80102f11:	90                   	nop
80102f12:	c9                   	leave  
80102f13:	c3                   	ret    

80102f14 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80102f14:	55                   	push   %ebp
80102f15:	89 e5                	mov    %esp,%ebp
80102f17:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f1a:	a1 54 41 19 80       	mov    0x80194154,%eax
80102f1f:	89 c2                	mov    %eax,%edx
80102f21:	a1 64 41 19 80       	mov    0x80194164,%eax
80102f26:	83 ec 08             	sub    $0x8,%esp
80102f29:	52                   	push   %edx
80102f2a:	50                   	push   %eax
80102f2b:	e8 d1 d2 ff ff       	call   80100201 <bread>
80102f30:	83 c4 10             	add    $0x10,%esp
80102f33:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80102f36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f39:	83 c0 5c             	add    $0x5c,%eax
80102f3c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80102f3f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f42:	8b 00                	mov    (%eax),%eax
80102f44:	a3 68 41 19 80       	mov    %eax,0x80194168
  for (i = 0; i < log.lh.n; i++) {
80102f49:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102f50:	eb 1b                	jmp    80102f6d <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80102f52:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f55:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f58:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80102f5c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f5f:	83 c2 10             	add    $0x10,%edx
80102f62:	89 04 95 2c 41 19 80 	mov    %eax,-0x7fe6bed4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102f69:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f6d:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f72:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f75:	7c db                	jl     80102f52 <read_head+0x3e>
  }
  brelse(buf);
80102f77:	83 ec 0c             	sub    $0xc,%esp
80102f7a:	ff 75 f0             	push   -0x10(%ebp)
80102f7d:	e8 01 d3 ff ff       	call   80100283 <brelse>
80102f82:	83 c4 10             	add    $0x10,%esp
}
80102f85:	90                   	nop
80102f86:	c9                   	leave  
80102f87:	c3                   	ret    

80102f88 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102f88:	55                   	push   %ebp
80102f89:	89 e5                	mov    %esp,%ebp
80102f8b:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f8e:	a1 54 41 19 80       	mov    0x80194154,%eax
80102f93:	89 c2                	mov    %eax,%edx
80102f95:	a1 64 41 19 80       	mov    0x80194164,%eax
80102f9a:	83 ec 08             	sub    $0x8,%esp
80102f9d:	52                   	push   %edx
80102f9e:	50                   	push   %eax
80102f9f:	e8 5d d2 ff ff       	call   80100201 <bread>
80102fa4:	83 c4 10             	add    $0x10,%esp
80102fa7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80102faa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fad:	83 c0 5c             	add    $0x5c,%eax
80102fb0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80102fb3:	8b 15 68 41 19 80    	mov    0x80194168,%edx
80102fb9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fbc:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102fbe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102fc5:	eb 1b                	jmp    80102fe2 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80102fc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fca:	83 c0 10             	add    $0x10,%eax
80102fcd:	8b 0c 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%ecx
80102fd4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fd7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102fda:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102fde:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102fe2:	a1 68 41 19 80       	mov    0x80194168,%eax
80102fe7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102fea:	7c db                	jl     80102fc7 <write_head+0x3f>
  }
  bwrite(buf);
80102fec:	83 ec 0c             	sub    $0xc,%esp
80102fef:	ff 75 f0             	push   -0x10(%ebp)
80102ff2:	e8 43 d2 ff ff       	call   8010023a <bwrite>
80102ff7:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80102ffa:	83 ec 0c             	sub    $0xc,%esp
80102ffd:	ff 75 f0             	push   -0x10(%ebp)
80103000:	e8 7e d2 ff ff       	call   80100283 <brelse>
80103005:	83 c4 10             	add    $0x10,%esp
}
80103008:	90                   	nop
80103009:	c9                   	leave  
8010300a:	c3                   	ret    

8010300b <recover_from_log>:

static void
recover_from_log(void)
{
8010300b:	55                   	push   %ebp
8010300c:	89 e5                	mov    %esp,%ebp
8010300e:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103011:	e8 fe fe ff ff       	call   80102f14 <read_head>
  install_trans(); // if committed, copy from log to disk
80103016:	e8 40 fe ff ff       	call   80102e5b <install_trans>
  log.lh.n = 0;
8010301b:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
80103022:	00 00 00 
  write_head(); // clear the log
80103025:	e8 5e ff ff ff       	call   80102f88 <write_head>
}
8010302a:	90                   	nop
8010302b:	c9                   	leave  
8010302c:	c3                   	ret    

8010302d <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010302d:	55                   	push   %ebp
8010302e:	89 e5                	mov    %esp,%ebp
80103030:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103033:	83 ec 0c             	sub    $0xc,%esp
80103036:	68 20 41 19 80       	push   $0x80194120
8010303b:	e8 fb 17 00 00       	call   8010483b <acquire>
80103040:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103043:	a1 60 41 19 80       	mov    0x80194160,%eax
80103048:	85 c0                	test   %eax,%eax
8010304a:	74 17                	je     80103063 <begin_op+0x36>
      sleep(&log, &log.lock);
8010304c:	83 ec 08             	sub    $0x8,%esp
8010304f:	68 20 41 19 80       	push   $0x80194120
80103054:	68 20 41 19 80       	push   $0x80194120
80103059:	e8 6c 12 00 00       	call   801042ca <sleep>
8010305e:	83 c4 10             	add    $0x10,%esp
80103061:	eb e0                	jmp    80103043 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103063:	8b 0d 68 41 19 80    	mov    0x80194168,%ecx
80103069:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010306e:	8d 50 01             	lea    0x1(%eax),%edx
80103071:	89 d0                	mov    %edx,%eax
80103073:	c1 e0 02             	shl    $0x2,%eax
80103076:	01 d0                	add    %edx,%eax
80103078:	01 c0                	add    %eax,%eax
8010307a:	01 c8                	add    %ecx,%eax
8010307c:	83 f8 1e             	cmp    $0x1e,%eax
8010307f:	7e 17                	jle    80103098 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103081:	83 ec 08             	sub    $0x8,%esp
80103084:	68 20 41 19 80       	push   $0x80194120
80103089:	68 20 41 19 80       	push   $0x80194120
8010308e:	e8 37 12 00 00       	call   801042ca <sleep>
80103093:	83 c4 10             	add    $0x10,%esp
80103096:	eb ab                	jmp    80103043 <begin_op+0x16>
    } else {
      log.outstanding += 1;
80103098:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010309d:	83 c0 01             	add    $0x1,%eax
801030a0:	a3 5c 41 19 80       	mov    %eax,0x8019415c
      release(&log.lock);
801030a5:	83 ec 0c             	sub    $0xc,%esp
801030a8:	68 20 41 19 80       	push   $0x80194120
801030ad:	e8 f7 17 00 00       	call   801048a9 <release>
801030b2:	83 c4 10             	add    $0x10,%esp
      break;
801030b5:	90                   	nop
    }
  }
}
801030b6:	90                   	nop
801030b7:	c9                   	leave  
801030b8:	c3                   	ret    

801030b9 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801030b9:	55                   	push   %ebp
801030ba:	89 e5                	mov    %esp,%ebp
801030bc:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801030bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801030c6:	83 ec 0c             	sub    $0xc,%esp
801030c9:	68 20 41 19 80       	push   $0x80194120
801030ce:	e8 68 17 00 00       	call   8010483b <acquire>
801030d3:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801030d6:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030db:	83 e8 01             	sub    $0x1,%eax
801030de:	a3 5c 41 19 80       	mov    %eax,0x8019415c
  if(log.committing)
801030e3:	a1 60 41 19 80       	mov    0x80194160,%eax
801030e8:	85 c0                	test   %eax,%eax
801030ea:	74 0d                	je     801030f9 <end_op+0x40>
    panic("log.committing");
801030ec:	83 ec 0c             	sub    $0xc,%esp
801030ef:	68 f5 a2 10 80       	push   $0x8010a2f5
801030f4:	e8 b0 d4 ff ff       	call   801005a9 <panic>
  if(log.outstanding == 0){
801030f9:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030fe:	85 c0                	test   %eax,%eax
80103100:	75 13                	jne    80103115 <end_op+0x5c>
    do_commit = 1;
80103102:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103109:	c7 05 60 41 19 80 01 	movl   $0x1,0x80194160
80103110:	00 00 00 
80103113:	eb 10                	jmp    80103125 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103115:	83 ec 0c             	sub    $0xc,%esp
80103118:	68 20 41 19 80       	push   $0x80194120
8010311d:	e8 8f 12 00 00       	call   801043b1 <wakeup>
80103122:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103125:	83 ec 0c             	sub    $0xc,%esp
80103128:	68 20 41 19 80       	push   $0x80194120
8010312d:	e8 77 17 00 00       	call   801048a9 <release>
80103132:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103135:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103139:	74 3f                	je     8010317a <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010313b:	e8 f6 00 00 00       	call   80103236 <commit>
    acquire(&log.lock);
80103140:	83 ec 0c             	sub    $0xc,%esp
80103143:	68 20 41 19 80       	push   $0x80194120
80103148:	e8 ee 16 00 00       	call   8010483b <acquire>
8010314d:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103150:	c7 05 60 41 19 80 00 	movl   $0x0,0x80194160
80103157:	00 00 00 
    wakeup(&log);
8010315a:	83 ec 0c             	sub    $0xc,%esp
8010315d:	68 20 41 19 80       	push   $0x80194120
80103162:	e8 4a 12 00 00       	call   801043b1 <wakeup>
80103167:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010316a:	83 ec 0c             	sub    $0xc,%esp
8010316d:	68 20 41 19 80       	push   $0x80194120
80103172:	e8 32 17 00 00       	call   801048a9 <release>
80103177:	83 c4 10             	add    $0x10,%esp
  }
}
8010317a:	90                   	nop
8010317b:	c9                   	leave  
8010317c:	c3                   	ret    

8010317d <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
8010317d:	55                   	push   %ebp
8010317e:	89 e5                	mov    %esp,%ebp
80103180:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103183:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010318a:	e9 95 00 00 00       	jmp    80103224 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010318f:	8b 15 54 41 19 80    	mov    0x80194154,%edx
80103195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103198:	01 d0                	add    %edx,%eax
8010319a:	83 c0 01             	add    $0x1,%eax
8010319d:	89 c2                	mov    %eax,%edx
8010319f:	a1 64 41 19 80       	mov    0x80194164,%eax
801031a4:	83 ec 08             	sub    $0x8,%esp
801031a7:	52                   	push   %edx
801031a8:	50                   	push   %eax
801031a9:	e8 53 d0 ff ff       	call   80100201 <bread>
801031ae:	83 c4 10             	add    $0x10,%esp
801031b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801031b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031b7:	83 c0 10             	add    $0x10,%eax
801031ba:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801031c1:	89 c2                	mov    %eax,%edx
801031c3:	a1 64 41 19 80       	mov    0x80194164,%eax
801031c8:	83 ec 08             	sub    $0x8,%esp
801031cb:	52                   	push   %edx
801031cc:	50                   	push   %eax
801031cd:	e8 2f d0 ff ff       	call   80100201 <bread>
801031d2:	83 c4 10             	add    $0x10,%esp
801031d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801031d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031db:	8d 50 5c             	lea    0x5c(%eax),%edx
801031de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031e1:	83 c0 5c             	add    $0x5c,%eax
801031e4:	83 ec 04             	sub    $0x4,%esp
801031e7:	68 00 02 00 00       	push   $0x200
801031ec:	52                   	push   %edx
801031ed:	50                   	push   %eax
801031ee:	e8 7d 19 00 00       	call   80104b70 <memmove>
801031f3:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801031f6:	83 ec 0c             	sub    $0xc,%esp
801031f9:	ff 75 f0             	push   -0x10(%ebp)
801031fc:	e8 39 d0 ff ff       	call   8010023a <bwrite>
80103201:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103204:	83 ec 0c             	sub    $0xc,%esp
80103207:	ff 75 ec             	push   -0x14(%ebp)
8010320a:	e8 74 d0 ff ff       	call   80100283 <brelse>
8010320f:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103212:	83 ec 0c             	sub    $0xc,%esp
80103215:	ff 75 f0             	push   -0x10(%ebp)
80103218:	e8 66 d0 ff ff       	call   80100283 <brelse>
8010321d:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103220:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103224:	a1 68 41 19 80       	mov    0x80194168,%eax
80103229:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010322c:	0f 8c 5d ff ff ff    	jl     8010318f <write_log+0x12>
  }
}
80103232:	90                   	nop
80103233:	90                   	nop
80103234:	c9                   	leave  
80103235:	c3                   	ret    

80103236 <commit>:

static void
commit()
{
80103236:	55                   	push   %ebp
80103237:	89 e5                	mov    %esp,%ebp
80103239:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010323c:	a1 68 41 19 80       	mov    0x80194168,%eax
80103241:	85 c0                	test   %eax,%eax
80103243:	7e 1e                	jle    80103263 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103245:	e8 33 ff ff ff       	call   8010317d <write_log>
    write_head();    // Write header to disk -- the real commit
8010324a:	e8 39 fd ff ff       	call   80102f88 <write_head>
    install_trans(); // Now install writes to home locations
8010324f:	e8 07 fc ff ff       	call   80102e5b <install_trans>
    log.lh.n = 0;
80103254:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
8010325b:	00 00 00 
    write_head();    // Erase the transaction from the log
8010325e:	e8 25 fd ff ff       	call   80102f88 <write_head>
  }
}
80103263:	90                   	nop
80103264:	c9                   	leave  
80103265:	c3                   	ret    

80103266 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103266:	55                   	push   %ebp
80103267:	89 e5                	mov    %esp,%ebp
80103269:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010326c:	a1 68 41 19 80       	mov    0x80194168,%eax
80103271:	83 f8 1d             	cmp    $0x1d,%eax
80103274:	7f 12                	jg     80103288 <log_write+0x22>
80103276:	a1 68 41 19 80       	mov    0x80194168,%eax
8010327b:	8b 15 58 41 19 80    	mov    0x80194158,%edx
80103281:	83 ea 01             	sub    $0x1,%edx
80103284:	39 d0                	cmp    %edx,%eax
80103286:	7c 0d                	jl     80103295 <log_write+0x2f>
    panic("too big a transaction");
80103288:	83 ec 0c             	sub    $0xc,%esp
8010328b:	68 04 a3 10 80       	push   $0x8010a304
80103290:	e8 14 d3 ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
80103295:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010329a:	85 c0                	test   %eax,%eax
8010329c:	7f 0d                	jg     801032ab <log_write+0x45>
    panic("log_write outside of trans");
8010329e:	83 ec 0c             	sub    $0xc,%esp
801032a1:	68 1a a3 10 80       	push   $0x8010a31a
801032a6:	e8 fe d2 ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
801032ab:	83 ec 0c             	sub    $0xc,%esp
801032ae:	68 20 41 19 80       	push   $0x80194120
801032b3:	e8 83 15 00 00       	call   8010483b <acquire>
801032b8:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801032bb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032c2:	eb 1d                	jmp    801032e1 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801032c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032c7:	83 c0 10             	add    $0x10,%eax
801032ca:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801032d1:	89 c2                	mov    %eax,%edx
801032d3:	8b 45 08             	mov    0x8(%ebp),%eax
801032d6:	8b 40 08             	mov    0x8(%eax),%eax
801032d9:	39 c2                	cmp    %eax,%edx
801032db:	74 10                	je     801032ed <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
801032dd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801032e1:	a1 68 41 19 80       	mov    0x80194168,%eax
801032e6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801032e9:	7c d9                	jl     801032c4 <log_write+0x5e>
801032eb:	eb 01                	jmp    801032ee <log_write+0x88>
      break;
801032ed:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801032ee:	8b 45 08             	mov    0x8(%ebp),%eax
801032f1:	8b 40 08             	mov    0x8(%eax),%eax
801032f4:	89 c2                	mov    %eax,%edx
801032f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032f9:	83 c0 10             	add    $0x10,%eax
801032fc:	89 14 85 2c 41 19 80 	mov    %edx,-0x7fe6bed4(,%eax,4)
  if (i == log.lh.n)
80103303:	a1 68 41 19 80       	mov    0x80194168,%eax
80103308:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010330b:	75 0d                	jne    8010331a <log_write+0xb4>
    log.lh.n++;
8010330d:	a1 68 41 19 80       	mov    0x80194168,%eax
80103312:	83 c0 01             	add    $0x1,%eax
80103315:	a3 68 41 19 80       	mov    %eax,0x80194168
  b->flags |= B_DIRTY; // prevent eviction
8010331a:	8b 45 08             	mov    0x8(%ebp),%eax
8010331d:	8b 00                	mov    (%eax),%eax
8010331f:	83 c8 04             	or     $0x4,%eax
80103322:	89 c2                	mov    %eax,%edx
80103324:	8b 45 08             	mov    0x8(%ebp),%eax
80103327:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103329:	83 ec 0c             	sub    $0xc,%esp
8010332c:	68 20 41 19 80       	push   $0x80194120
80103331:	e8 73 15 00 00       	call   801048a9 <release>
80103336:	83 c4 10             	add    $0x10,%esp
}
80103339:	90                   	nop
8010333a:	c9                   	leave  
8010333b:	c3                   	ret    

8010333c <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010333c:	55                   	push   %ebp
8010333d:	89 e5                	mov    %esp,%ebp
8010333f:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103342:	8b 55 08             	mov    0x8(%ebp),%edx
80103345:	8b 45 0c             	mov    0xc(%ebp),%eax
80103348:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010334b:	f0 87 02             	lock xchg %eax,(%edx)
8010334e:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103351:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103354:	c9                   	leave  
80103355:	c3                   	ret    

80103356 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103356:	8d 4c 24 04          	lea    0x4(%esp),%ecx
8010335a:	83 e4 f0             	and    $0xfffffff0,%esp
8010335d:	ff 71 fc             	push   -0x4(%ecx)
80103360:	55                   	push   %ebp
80103361:	89 e5                	mov    %esp,%ebp
80103363:	51                   	push   %ecx
80103364:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
80103367:	e8 08 4b 00 00       	call   80107e74 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010336c:	83 ec 08             	sub    $0x8,%esp
8010336f:	68 00 00 40 80       	push   $0x80400000
80103374:	68 00 80 19 80       	push   $0x80198000
80103379:	e8 de f2 ff ff       	call   8010265c <kinit1>
8010337e:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103381:	e8 1b 41 00 00       	call   801074a1 <kvmalloc>
  mpinit_uefi();
80103386:	e8 af 48 00 00       	call   80107c3a <mpinit_uefi>
  lapicinit();     // interrupt controller
8010338b:	e8 3c f6 ff ff       	call   801029cc <lapicinit>
  seginit();       // segment descriptors
80103390:	e8 a4 3b 00 00       	call   80106f39 <seginit>
  picinit();    // disable pic
80103395:	e8 9d 01 00 00       	call   80103537 <picinit>
  ioapicinit();    // another interrupt controller
8010339a:	e8 d8 f1 ff ff       	call   80102577 <ioapicinit>
  consoleinit();   // console hardware
8010339f:	e8 5b d7 ff ff       	call   80100aff <consoleinit>
  uartinit();      // serial port
801033a4:	e8 29 2f 00 00       	call   801062d2 <uartinit>
  pinit();         // process table
801033a9:	e8 c2 05 00 00       	call   80103970 <pinit>
  tvinit();        // trap vectors
801033ae:	e8 a2 2a 00 00       	call   80105e55 <tvinit>
  binit();         // buffer cache
801033b3:	e8 ae cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033b8:	e8 f3 db ff ff       	call   80100fb0 <fileinit>
  ideinit();       // disk 
801033bd:	e8 f3 6b 00 00       	call   80109fb5 <ideinit>
  startothers();   // start other processors
801033c2:	e8 8a 00 00 00       	call   80103451 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033c7:	83 ec 08             	sub    $0x8,%esp
801033ca:	68 00 00 00 a0       	push   $0xa0000000
801033cf:	68 00 00 40 80       	push   $0x80400000
801033d4:	e8 bc f2 ff ff       	call   80102695 <kinit2>
801033d9:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033dc:	e8 ec 4c 00 00       	call   801080cd <pci_init>
  arp_scan();
801033e1:	e8 23 5a 00 00       	call   80108e09 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801033e6:	e8 63 07 00 00       	call   80103b4e <userinit>

  mpmain();        // finish this processor's setup
801033eb:	e8 1a 00 00 00       	call   8010340a <mpmain>

801033f0 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801033f0:	55                   	push   %ebp
801033f1:	89 e5                	mov    %esp,%ebp
801033f3:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801033f6:	e8 be 40 00 00       	call   801074b9 <switchkvm>
  seginit();
801033fb:	e8 39 3b 00 00       	call   80106f39 <seginit>
  lapicinit();
80103400:	e8 c7 f5 ff ff       	call   801029cc <lapicinit>
  mpmain();
80103405:	e8 00 00 00 00       	call   8010340a <mpmain>

8010340a <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
8010340a:	55                   	push   %ebp
8010340b:	89 e5                	mov    %esp,%ebp
8010340d:	53                   	push   %ebx
8010340e:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103411:	e8 78 05 00 00       	call   8010398e <cpuid>
80103416:	89 c3                	mov    %eax,%ebx
80103418:	e8 71 05 00 00       	call   8010398e <cpuid>
8010341d:	83 ec 04             	sub    $0x4,%esp
80103420:	53                   	push   %ebx
80103421:	50                   	push   %eax
80103422:	68 35 a3 10 80       	push   $0x8010a335
80103427:	e8 c8 cf ff ff       	call   801003f4 <cprintf>
8010342c:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
8010342f:	e8 97 2b 00 00       	call   80105fcb <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103434:	e8 70 05 00 00       	call   801039a9 <mycpu>
80103439:	05 a0 00 00 00       	add    $0xa0,%eax
8010343e:	83 ec 08             	sub    $0x8,%esp
80103441:	6a 01                	push   $0x1
80103443:	50                   	push   %eax
80103444:	e8 f3 fe ff ff       	call   8010333c <xchg>
80103449:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010344c:	e8 88 0c 00 00       	call   801040d9 <scheduler>

80103451 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103451:	55                   	push   %ebp
80103452:	89 e5                	mov    %esp,%ebp
80103454:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103457:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010345e:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103463:	83 ec 04             	sub    $0x4,%esp
80103466:	50                   	push   %eax
80103467:	68 18 f5 10 80       	push   $0x8010f518
8010346c:	ff 75 f0             	push   -0x10(%ebp)
8010346f:	e8 fc 16 00 00       	call   80104b70 <memmove>
80103474:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103477:	c7 45 f4 80 69 19 80 	movl   $0x80196980,-0xc(%ebp)
8010347e:	eb 79                	jmp    801034f9 <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
80103480:	e8 24 05 00 00       	call   801039a9 <mycpu>
80103485:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103488:	74 67                	je     801034f1 <startothers+0xa0>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010348a:	e8 02 f3 ff ff       	call   80102791 <kalloc>
8010348f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103492:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103495:	83 e8 04             	sub    $0x4,%eax
80103498:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010349b:	81 c2 00 10 00 00    	add    $0x1000,%edx
801034a1:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801034a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034a6:	83 e8 08             	sub    $0x8,%eax
801034a9:	c7 00 f0 33 10 80    	movl   $0x801033f0,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801034af:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
801034b4:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034bd:	83 e8 0c             	sub    $0xc,%eax
801034c0:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801034c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034c5:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034ce:	0f b6 00             	movzbl (%eax),%eax
801034d1:	0f b6 c0             	movzbl %al,%eax
801034d4:	83 ec 08             	sub    $0x8,%esp
801034d7:	52                   	push   %edx
801034d8:	50                   	push   %eax
801034d9:	e8 50 f6 ff ff       	call   80102b2e <lapicstartap>
801034de:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801034e1:	90                   	nop
801034e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034e5:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801034eb:	85 c0                	test   %eax,%eax
801034ed:	74 f3                	je     801034e2 <startothers+0x91>
801034ef:	eb 01                	jmp    801034f2 <startothers+0xa1>
      continue;
801034f1:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
801034f2:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
801034f9:	a1 40 6c 19 80       	mov    0x80196c40,%eax
801034fe:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103504:	05 80 69 19 80       	add    $0x80196980,%eax
80103509:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010350c:	0f 82 6e ff ff ff    	jb     80103480 <startothers+0x2f>
      ;
  }
}
80103512:	90                   	nop
80103513:	90                   	nop
80103514:	c9                   	leave  
80103515:	c3                   	ret    

80103516 <outb>:
{
80103516:	55                   	push   %ebp
80103517:	89 e5                	mov    %esp,%ebp
80103519:	83 ec 08             	sub    $0x8,%esp
8010351c:	8b 45 08             	mov    0x8(%ebp),%eax
8010351f:	8b 55 0c             	mov    0xc(%ebp),%edx
80103522:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103526:	89 d0                	mov    %edx,%eax
80103528:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010352b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010352f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103533:	ee                   	out    %al,(%dx)
}
80103534:	90                   	nop
80103535:	c9                   	leave  
80103536:	c3                   	ret    

80103537 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103537:	55                   	push   %ebp
80103538:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
8010353a:	68 ff 00 00 00       	push   $0xff
8010353f:	6a 21                	push   $0x21
80103541:	e8 d0 ff ff ff       	call   80103516 <outb>
80103546:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103549:	68 ff 00 00 00       	push   $0xff
8010354e:	68 a1 00 00 00       	push   $0xa1
80103553:	e8 be ff ff ff       	call   80103516 <outb>
80103558:	83 c4 08             	add    $0x8,%esp
}
8010355b:	90                   	nop
8010355c:	c9                   	leave  
8010355d:	c3                   	ret    

8010355e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
8010355e:	55                   	push   %ebp
8010355f:	89 e5                	mov    %esp,%ebp
80103561:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103564:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
8010356b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010356e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103574:	8b 45 0c             	mov    0xc(%ebp),%eax
80103577:	8b 10                	mov    (%eax),%edx
80103579:	8b 45 08             	mov    0x8(%ebp),%eax
8010357c:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010357e:	e8 4b da ff ff       	call   80100fce <filealloc>
80103583:	8b 55 08             	mov    0x8(%ebp),%edx
80103586:	89 02                	mov    %eax,(%edx)
80103588:	8b 45 08             	mov    0x8(%ebp),%eax
8010358b:	8b 00                	mov    (%eax),%eax
8010358d:	85 c0                	test   %eax,%eax
8010358f:	0f 84 c8 00 00 00    	je     8010365d <pipealloc+0xff>
80103595:	e8 34 da ff ff       	call   80100fce <filealloc>
8010359a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010359d:	89 02                	mov    %eax,(%edx)
8010359f:	8b 45 0c             	mov    0xc(%ebp),%eax
801035a2:	8b 00                	mov    (%eax),%eax
801035a4:	85 c0                	test   %eax,%eax
801035a6:	0f 84 b1 00 00 00    	je     8010365d <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801035ac:	e8 e0 f1 ff ff       	call   80102791 <kalloc>
801035b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801035b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035b8:	0f 84 a2 00 00 00    	je     80103660 <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
801035be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035c1:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801035c8:	00 00 00 
  p->writeopen = 1;
801035cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035ce:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801035d5:	00 00 00 
  p->nwrite = 0;
801035d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035db:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801035e2:	00 00 00 
  p->nread = 0;
801035e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035e8:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801035ef:	00 00 00 
  initlock(&p->lock, "pipe");
801035f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035f5:	83 ec 08             	sub    $0x8,%esp
801035f8:	68 49 a3 10 80       	push   $0x8010a349
801035fd:	50                   	push   %eax
801035fe:	e8 16 12 00 00       	call   80104819 <initlock>
80103603:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103606:	8b 45 08             	mov    0x8(%ebp),%eax
80103609:	8b 00                	mov    (%eax),%eax
8010360b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103611:	8b 45 08             	mov    0x8(%ebp),%eax
80103614:	8b 00                	mov    (%eax),%eax
80103616:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010361a:	8b 45 08             	mov    0x8(%ebp),%eax
8010361d:	8b 00                	mov    (%eax),%eax
8010361f:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103623:	8b 45 08             	mov    0x8(%ebp),%eax
80103626:	8b 00                	mov    (%eax),%eax
80103628:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010362b:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010362e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103631:	8b 00                	mov    (%eax),%eax
80103633:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103639:	8b 45 0c             	mov    0xc(%ebp),%eax
8010363c:	8b 00                	mov    (%eax),%eax
8010363e:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103642:	8b 45 0c             	mov    0xc(%ebp),%eax
80103645:	8b 00                	mov    (%eax),%eax
80103647:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010364b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010364e:	8b 00                	mov    (%eax),%eax
80103650:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103653:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103656:	b8 00 00 00 00       	mov    $0x0,%eax
8010365b:	eb 51                	jmp    801036ae <pipealloc+0x150>
    goto bad;
8010365d:	90                   	nop
8010365e:	eb 01                	jmp    80103661 <pipealloc+0x103>
    goto bad;
80103660:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103661:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103665:	74 0e                	je     80103675 <pipealloc+0x117>
    kfree((char*)p);
80103667:	83 ec 0c             	sub    $0xc,%esp
8010366a:	ff 75 f4             	push   -0xc(%ebp)
8010366d:	e8 85 f0 ff ff       	call   801026f7 <kfree>
80103672:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103675:	8b 45 08             	mov    0x8(%ebp),%eax
80103678:	8b 00                	mov    (%eax),%eax
8010367a:	85 c0                	test   %eax,%eax
8010367c:	74 11                	je     8010368f <pipealloc+0x131>
    fileclose(*f0);
8010367e:	8b 45 08             	mov    0x8(%ebp),%eax
80103681:	8b 00                	mov    (%eax),%eax
80103683:	83 ec 0c             	sub    $0xc,%esp
80103686:	50                   	push   %eax
80103687:	e8 00 da ff ff       	call   8010108c <fileclose>
8010368c:	83 c4 10             	add    $0x10,%esp
  if(*f1)
8010368f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103692:	8b 00                	mov    (%eax),%eax
80103694:	85 c0                	test   %eax,%eax
80103696:	74 11                	je     801036a9 <pipealloc+0x14b>
    fileclose(*f1);
80103698:	8b 45 0c             	mov    0xc(%ebp),%eax
8010369b:	8b 00                	mov    (%eax),%eax
8010369d:	83 ec 0c             	sub    $0xc,%esp
801036a0:	50                   	push   %eax
801036a1:	e8 e6 d9 ff ff       	call   8010108c <fileclose>
801036a6:	83 c4 10             	add    $0x10,%esp
  return -1;
801036a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801036ae:	c9                   	leave  
801036af:	c3                   	ret    

801036b0 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801036b0:	55                   	push   %ebp
801036b1:	89 e5                	mov    %esp,%ebp
801036b3:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801036b6:	8b 45 08             	mov    0x8(%ebp),%eax
801036b9:	83 ec 0c             	sub    $0xc,%esp
801036bc:	50                   	push   %eax
801036bd:	e8 79 11 00 00       	call   8010483b <acquire>
801036c2:	83 c4 10             	add    $0x10,%esp
  if(writable){
801036c5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801036c9:	74 23                	je     801036ee <pipeclose+0x3e>
    p->writeopen = 0;
801036cb:	8b 45 08             	mov    0x8(%ebp),%eax
801036ce:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801036d5:	00 00 00 
    wakeup(&p->nread);
801036d8:	8b 45 08             	mov    0x8(%ebp),%eax
801036db:	05 34 02 00 00       	add    $0x234,%eax
801036e0:	83 ec 0c             	sub    $0xc,%esp
801036e3:	50                   	push   %eax
801036e4:	e8 c8 0c 00 00       	call   801043b1 <wakeup>
801036e9:	83 c4 10             	add    $0x10,%esp
801036ec:	eb 21                	jmp    8010370f <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801036ee:	8b 45 08             	mov    0x8(%ebp),%eax
801036f1:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801036f8:	00 00 00 
    wakeup(&p->nwrite);
801036fb:	8b 45 08             	mov    0x8(%ebp),%eax
801036fe:	05 38 02 00 00       	add    $0x238,%eax
80103703:	83 ec 0c             	sub    $0xc,%esp
80103706:	50                   	push   %eax
80103707:	e8 a5 0c 00 00       	call   801043b1 <wakeup>
8010370c:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010370f:	8b 45 08             	mov    0x8(%ebp),%eax
80103712:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103718:	85 c0                	test   %eax,%eax
8010371a:	75 2c                	jne    80103748 <pipeclose+0x98>
8010371c:	8b 45 08             	mov    0x8(%ebp),%eax
8010371f:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103725:	85 c0                	test   %eax,%eax
80103727:	75 1f                	jne    80103748 <pipeclose+0x98>
    release(&p->lock);
80103729:	8b 45 08             	mov    0x8(%ebp),%eax
8010372c:	83 ec 0c             	sub    $0xc,%esp
8010372f:	50                   	push   %eax
80103730:	e8 74 11 00 00       	call   801048a9 <release>
80103735:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103738:	83 ec 0c             	sub    $0xc,%esp
8010373b:	ff 75 08             	push   0x8(%ebp)
8010373e:	e8 b4 ef ff ff       	call   801026f7 <kfree>
80103743:	83 c4 10             	add    $0x10,%esp
80103746:	eb 10                	jmp    80103758 <pipeclose+0xa8>
  } else
    release(&p->lock);
80103748:	8b 45 08             	mov    0x8(%ebp),%eax
8010374b:	83 ec 0c             	sub    $0xc,%esp
8010374e:	50                   	push   %eax
8010374f:	e8 55 11 00 00       	call   801048a9 <release>
80103754:	83 c4 10             	add    $0x10,%esp
}
80103757:	90                   	nop
80103758:	90                   	nop
80103759:	c9                   	leave  
8010375a:	c3                   	ret    

8010375b <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010375b:	55                   	push   %ebp
8010375c:	89 e5                	mov    %esp,%ebp
8010375e:	53                   	push   %ebx
8010375f:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103762:	8b 45 08             	mov    0x8(%ebp),%eax
80103765:	83 ec 0c             	sub    $0xc,%esp
80103768:	50                   	push   %eax
80103769:	e8 cd 10 00 00       	call   8010483b <acquire>
8010376e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103771:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103778:	e9 ad 00 00 00       	jmp    8010382a <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
8010377d:	8b 45 08             	mov    0x8(%ebp),%eax
80103780:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103786:	85 c0                	test   %eax,%eax
80103788:	74 0c                	je     80103796 <pipewrite+0x3b>
8010378a:	e8 92 02 00 00       	call   80103a21 <myproc>
8010378f:	8b 40 24             	mov    0x24(%eax),%eax
80103792:	85 c0                	test   %eax,%eax
80103794:	74 19                	je     801037af <pipewrite+0x54>
        release(&p->lock);
80103796:	8b 45 08             	mov    0x8(%ebp),%eax
80103799:	83 ec 0c             	sub    $0xc,%esp
8010379c:	50                   	push   %eax
8010379d:	e8 07 11 00 00       	call   801048a9 <release>
801037a2:	83 c4 10             	add    $0x10,%esp
        return -1;
801037a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801037aa:	e9 a9 00 00 00       	jmp    80103858 <pipewrite+0xfd>
      }
      wakeup(&p->nread);
801037af:	8b 45 08             	mov    0x8(%ebp),%eax
801037b2:	05 34 02 00 00       	add    $0x234,%eax
801037b7:	83 ec 0c             	sub    $0xc,%esp
801037ba:	50                   	push   %eax
801037bb:	e8 f1 0b 00 00       	call   801043b1 <wakeup>
801037c0:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037c3:	8b 45 08             	mov    0x8(%ebp),%eax
801037c6:	8b 55 08             	mov    0x8(%ebp),%edx
801037c9:	81 c2 38 02 00 00    	add    $0x238,%edx
801037cf:	83 ec 08             	sub    $0x8,%esp
801037d2:	50                   	push   %eax
801037d3:	52                   	push   %edx
801037d4:	e8 f1 0a 00 00       	call   801042ca <sleep>
801037d9:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801037dc:	8b 45 08             	mov    0x8(%ebp),%eax
801037df:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801037e5:	8b 45 08             	mov    0x8(%ebp),%eax
801037e8:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801037ee:	05 00 02 00 00       	add    $0x200,%eax
801037f3:	39 c2                	cmp    %eax,%edx
801037f5:	74 86                	je     8010377d <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801037f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801037fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801037fd:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80103800:	8b 45 08             	mov    0x8(%ebp),%eax
80103803:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103809:	8d 48 01             	lea    0x1(%eax),%ecx
8010380c:	8b 55 08             	mov    0x8(%ebp),%edx
8010380f:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103815:	25 ff 01 00 00       	and    $0x1ff,%eax
8010381a:	89 c1                	mov    %eax,%ecx
8010381c:	0f b6 13             	movzbl (%ebx),%edx
8010381f:	8b 45 08             	mov    0x8(%ebp),%eax
80103822:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103826:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010382a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010382d:	3b 45 10             	cmp    0x10(%ebp),%eax
80103830:	7c aa                	jl     801037dc <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103832:	8b 45 08             	mov    0x8(%ebp),%eax
80103835:	05 34 02 00 00       	add    $0x234,%eax
8010383a:	83 ec 0c             	sub    $0xc,%esp
8010383d:	50                   	push   %eax
8010383e:	e8 6e 0b 00 00       	call   801043b1 <wakeup>
80103843:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103846:	8b 45 08             	mov    0x8(%ebp),%eax
80103849:	83 ec 0c             	sub    $0xc,%esp
8010384c:	50                   	push   %eax
8010384d:	e8 57 10 00 00       	call   801048a9 <release>
80103852:	83 c4 10             	add    $0x10,%esp
  return n;
80103855:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103858:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010385b:	c9                   	leave  
8010385c:	c3                   	ret    

8010385d <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010385d:	55                   	push   %ebp
8010385e:	89 e5                	mov    %esp,%ebp
80103860:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103863:	8b 45 08             	mov    0x8(%ebp),%eax
80103866:	83 ec 0c             	sub    $0xc,%esp
80103869:	50                   	push   %eax
8010386a:	e8 cc 0f 00 00       	call   8010483b <acquire>
8010386f:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103872:	eb 3e                	jmp    801038b2 <piperead+0x55>
    if(myproc()->killed){
80103874:	e8 a8 01 00 00       	call   80103a21 <myproc>
80103879:	8b 40 24             	mov    0x24(%eax),%eax
8010387c:	85 c0                	test   %eax,%eax
8010387e:	74 19                	je     80103899 <piperead+0x3c>
      release(&p->lock);
80103880:	8b 45 08             	mov    0x8(%ebp),%eax
80103883:	83 ec 0c             	sub    $0xc,%esp
80103886:	50                   	push   %eax
80103887:	e8 1d 10 00 00       	call   801048a9 <release>
8010388c:	83 c4 10             	add    $0x10,%esp
      return -1;
8010388f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103894:	e9 be 00 00 00       	jmp    80103957 <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103899:	8b 45 08             	mov    0x8(%ebp),%eax
8010389c:	8b 55 08             	mov    0x8(%ebp),%edx
8010389f:	81 c2 34 02 00 00    	add    $0x234,%edx
801038a5:	83 ec 08             	sub    $0x8,%esp
801038a8:	50                   	push   %eax
801038a9:	52                   	push   %edx
801038aa:	e8 1b 0a 00 00       	call   801042ca <sleep>
801038af:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801038b2:	8b 45 08             	mov    0x8(%ebp),%eax
801038b5:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038bb:	8b 45 08             	mov    0x8(%ebp),%eax
801038be:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038c4:	39 c2                	cmp    %eax,%edx
801038c6:	75 0d                	jne    801038d5 <piperead+0x78>
801038c8:	8b 45 08             	mov    0x8(%ebp),%eax
801038cb:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801038d1:	85 c0                	test   %eax,%eax
801038d3:	75 9f                	jne    80103874 <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801038d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038dc:	eb 48                	jmp    80103926 <piperead+0xc9>
    if(p->nread == p->nwrite)
801038de:	8b 45 08             	mov    0x8(%ebp),%eax
801038e1:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038e7:	8b 45 08             	mov    0x8(%ebp),%eax
801038ea:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038f0:	39 c2                	cmp    %eax,%edx
801038f2:	74 3c                	je     80103930 <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801038f4:	8b 45 08             	mov    0x8(%ebp),%eax
801038f7:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801038fd:	8d 48 01             	lea    0x1(%eax),%ecx
80103900:	8b 55 08             	mov    0x8(%ebp),%edx
80103903:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103909:	25 ff 01 00 00       	and    $0x1ff,%eax
8010390e:	89 c1                	mov    %eax,%ecx
80103910:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103913:	8b 45 0c             	mov    0xc(%ebp),%eax
80103916:	01 c2                	add    %eax,%edx
80103918:	8b 45 08             	mov    0x8(%ebp),%eax
8010391b:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80103920:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103922:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103926:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103929:	3b 45 10             	cmp    0x10(%ebp),%eax
8010392c:	7c b0                	jl     801038de <piperead+0x81>
8010392e:	eb 01                	jmp    80103931 <piperead+0xd4>
      break;
80103930:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103931:	8b 45 08             	mov    0x8(%ebp),%eax
80103934:	05 38 02 00 00       	add    $0x238,%eax
80103939:	83 ec 0c             	sub    $0xc,%esp
8010393c:	50                   	push   %eax
8010393d:	e8 6f 0a 00 00       	call   801043b1 <wakeup>
80103942:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103945:	8b 45 08             	mov    0x8(%ebp),%eax
80103948:	83 ec 0c             	sub    $0xc,%esp
8010394b:	50                   	push   %eax
8010394c:	e8 58 0f 00 00       	call   801048a9 <release>
80103951:	83 c4 10             	add    $0x10,%esp
  return i;
80103954:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103957:	c9                   	leave  
80103958:	c3                   	ret    

80103959 <readeflags>:
{
80103959:	55                   	push   %ebp
8010395a:	89 e5                	mov    %esp,%ebp
8010395c:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010395f:	9c                   	pushf  
80103960:	58                   	pop    %eax
80103961:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103964:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103967:	c9                   	leave  
80103968:	c3                   	ret    

80103969 <sti>:
{
80103969:	55                   	push   %ebp
8010396a:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010396c:	fb                   	sti    
}
8010396d:	90                   	nop
8010396e:	5d                   	pop    %ebp
8010396f:	c3                   	ret    

80103970 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80103970:	55                   	push   %ebp
80103971:	89 e5                	mov    %esp,%ebp
80103973:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103976:	83 ec 08             	sub    $0x8,%esp
80103979:	68 50 a3 10 80       	push   $0x8010a350
8010397e:	68 00 42 19 80       	push   $0x80194200
80103983:	e8 91 0e 00 00       	call   80104819 <initlock>
80103988:	83 c4 10             	add    $0x10,%esp
}
8010398b:	90                   	nop
8010398c:	c9                   	leave  
8010398d:	c3                   	ret    

8010398e <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
8010398e:	55                   	push   %ebp
8010398f:	89 e5                	mov    %esp,%ebp
80103991:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103994:	e8 10 00 00 00       	call   801039a9 <mycpu>
80103999:	2d 80 69 19 80       	sub    $0x80196980,%eax
8010399e:	c1 f8 04             	sar    $0x4,%eax
801039a1:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801039a7:	c9                   	leave  
801039a8:	c3                   	ret    

801039a9 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801039a9:	55                   	push   %ebp
801039aa:	89 e5                	mov    %esp,%ebp
801039ac:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
801039af:	e8 a5 ff ff ff       	call   80103959 <readeflags>
801039b4:	25 00 02 00 00       	and    $0x200,%eax
801039b9:	85 c0                	test   %eax,%eax
801039bb:	74 0d                	je     801039ca <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
801039bd:	83 ec 0c             	sub    $0xc,%esp
801039c0:	68 58 a3 10 80       	push   $0x8010a358
801039c5:	e8 df cb ff ff       	call   801005a9 <panic>
  }

  apicid = lapicid();
801039ca:	e8 1c f1 ff ff       	call   80102aeb <lapicid>
801039cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801039d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801039d9:	eb 2d                	jmp    80103a08 <mycpu+0x5f>
    if (cpus[i].apicid == apicid){
801039db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039de:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801039e4:	05 80 69 19 80       	add    $0x80196980,%eax
801039e9:	0f b6 00             	movzbl (%eax),%eax
801039ec:	0f b6 c0             	movzbl %al,%eax
801039ef:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801039f2:	75 10                	jne    80103a04 <mycpu+0x5b>
      return &cpus[i];
801039f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039f7:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801039fd:	05 80 69 19 80       	add    $0x80196980,%eax
80103a02:	eb 1b                	jmp    80103a1f <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103a04:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a08:	a1 40 6c 19 80       	mov    0x80196c40,%eax
80103a0d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a10:	7c c9                	jl     801039db <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103a12:	83 ec 0c             	sub    $0xc,%esp
80103a15:	68 7e a3 10 80       	push   $0x8010a37e
80103a1a:	e8 8a cb ff ff       	call   801005a9 <panic>
}
80103a1f:	c9                   	leave  
80103a20:	c3                   	ret    

80103a21 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103a21:	55                   	push   %ebp
80103a22:	89 e5                	mov    %esp,%ebp
80103a24:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103a27:	e8 7a 0f 00 00       	call   801049a6 <pushcli>
  c = mycpu();
80103a2c:	e8 78 ff ff ff       	call   801039a9 <mycpu>
80103a31:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a37:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103a40:	e8 ae 0f 00 00       	call   801049f3 <popcli>
  return p;
80103a45:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103a48:	c9                   	leave  
80103a49:	c3                   	ret    

80103a4a <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103a4a:	55                   	push   %ebp
80103a4b:	89 e5                	mov    %esp,%ebp
80103a4d:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103a50:	83 ec 0c             	sub    $0xc,%esp
80103a53:	68 00 42 19 80       	push   $0x80194200
80103a58:	e8 de 0d 00 00       	call   8010483b <acquire>
80103a5d:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a60:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103a67:	eb 0e                	jmp    80103a77 <allocproc+0x2d>
    if(p->state == UNUSED){
80103a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a6c:	8b 40 0c             	mov    0xc(%eax),%eax
80103a6f:	85 c0                	test   %eax,%eax
80103a71:	74 27                	je     80103a9a <allocproc+0x50>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a73:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80103a77:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
80103a7e:	72 e9                	jb     80103a69 <allocproc+0x1f>
      goto found;
    }

  release(&ptable.lock);
80103a80:	83 ec 0c             	sub    $0xc,%esp
80103a83:	68 00 42 19 80       	push   $0x80194200
80103a88:	e8 1c 0e 00 00       	call   801048a9 <release>
80103a8d:	83 c4 10             	add    $0x10,%esp
  return 0;
80103a90:	b8 00 00 00 00       	mov    $0x0,%eax
80103a95:	e9 b2 00 00 00       	jmp    80103b4c <allocproc+0x102>
      goto found;
80103a9a:	90                   	nop

found:
  p->state = EMBRYO;
80103a9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a9e:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103aa5:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103aaa:	8d 50 01             	lea    0x1(%eax),%edx
80103aad:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103ab3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ab6:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80103ab9:	83 ec 0c             	sub    $0xc,%esp
80103abc:	68 00 42 19 80       	push   $0x80194200
80103ac1:	e8 e3 0d 00 00       	call   801048a9 <release>
80103ac6:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103ac9:	e8 c3 ec ff ff       	call   80102791 <kalloc>
80103ace:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ad1:	89 42 08             	mov    %eax,0x8(%edx)
80103ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ad7:	8b 40 08             	mov    0x8(%eax),%eax
80103ada:	85 c0                	test   %eax,%eax
80103adc:	75 11                	jne    80103aef <allocproc+0xa5>
    p->state = UNUSED;
80103ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103ae8:	b8 00 00 00 00       	mov    $0x0,%eax
80103aed:	eb 5d                	jmp    80103b4c <allocproc+0x102>
  }
  sp = p->kstack + KSTACKSIZE;
80103aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af2:	8b 40 08             	mov    0x8(%eax),%eax
80103af5:	05 00 10 00 00       	add    $0x1000,%eax
80103afa:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103afd:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b04:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b07:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103b0a:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103b0e:	ba 0f 5e 10 80       	mov    $0x80105e0f,%edx
80103b13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b16:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103b18:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80103b1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b1f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b22:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103b25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b28:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b2b:	83 ec 04             	sub    $0x4,%esp
80103b2e:	6a 14                	push   $0x14
80103b30:	6a 00                	push   $0x0
80103b32:	50                   	push   %eax
80103b33:	e8 79 0f 00 00       	call   80104ab1 <memset>
80103b38:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103b3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b3e:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b41:	ba 84 42 10 80       	mov    $0x80104284,%edx
80103b46:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103b4c:	c9                   	leave  
80103b4d:	c3                   	ret    

80103b4e <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103b4e:	55                   	push   %ebp
80103b4f:	89 e5                	mov    %esp,%ebp
80103b51:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103b54:	e8 f1 fe ff ff       	call   80103a4a <allocproc>
80103b59:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103b5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b5f:	a3 34 61 19 80       	mov    %eax,0x80196134
  if((p->pgdir = setupkvm()) == 0){
80103b64:	e8 4c 38 00 00       	call   801073b5 <setupkvm>
80103b69:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b6c:	89 42 04             	mov    %eax,0x4(%edx)
80103b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b72:	8b 40 04             	mov    0x4(%eax),%eax
80103b75:	85 c0                	test   %eax,%eax
80103b77:	75 0d                	jne    80103b86 <userinit+0x38>
    panic("userinit: out of memory?");
80103b79:	83 ec 0c             	sub    $0xc,%esp
80103b7c:	68 8e a3 10 80       	push   $0x8010a38e
80103b81:	e8 23 ca ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103b86:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b8e:	8b 40 04             	mov    0x4(%eax),%eax
80103b91:	83 ec 04             	sub    $0x4,%esp
80103b94:	52                   	push   %edx
80103b95:	68 ec f4 10 80       	push   $0x8010f4ec
80103b9a:	50                   	push   %eax
80103b9b:	e8 d1 3a 00 00       	call   80107671 <inituvm>
80103ba0:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103ba3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba6:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103baf:	8b 40 18             	mov    0x18(%eax),%eax
80103bb2:	83 ec 04             	sub    $0x4,%esp
80103bb5:	6a 4c                	push   $0x4c
80103bb7:	6a 00                	push   $0x0
80103bb9:	50                   	push   %eax
80103bba:	e8 f2 0e 00 00       	call   80104ab1 <memset>
80103bbf:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103bc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc5:	8b 40 18             	mov    0x18(%eax),%eax
80103bc8:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103bce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd1:	8b 40 18             	mov    0x18(%eax),%eax
80103bd4:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bdd:	8b 50 18             	mov    0x18(%eax),%edx
80103be0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be3:	8b 40 18             	mov    0x18(%eax),%eax
80103be6:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103bea:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103bee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf1:	8b 50 18             	mov    0x18(%eax),%edx
80103bf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf7:	8b 40 18             	mov    0x18(%eax),%eax
80103bfa:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103bfe:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103c02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c05:	8b 40 18             	mov    0x18(%eax),%eax
80103c08:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103c0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c12:	8b 40 18             	mov    0x18(%eax),%eax
80103c15:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103c1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c1f:	8b 40 18             	mov    0x18(%eax),%eax
80103c22:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103c29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c2c:	83 c0 6c             	add    $0x6c,%eax
80103c2f:	83 ec 04             	sub    $0x4,%esp
80103c32:	6a 10                	push   $0x10
80103c34:	68 a7 a3 10 80       	push   $0x8010a3a7
80103c39:	50                   	push   %eax
80103c3a:	e8 75 10 00 00       	call   80104cb4 <safestrcpy>
80103c3f:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103c42:	83 ec 0c             	sub    $0xc,%esp
80103c45:	68 b0 a3 10 80       	push   $0x8010a3b0
80103c4a:	e8 bf e8 ff ff       	call   8010250e <namei>
80103c4f:	83 c4 10             	add    $0x10,%esp
80103c52:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c55:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103c58:	83 ec 0c             	sub    $0xc,%esp
80103c5b:	68 00 42 19 80       	push   $0x80194200
80103c60:	e8 d6 0b 00 00       	call   8010483b <acquire>
80103c65:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103c68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c6b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103c72:	83 ec 0c             	sub    $0xc,%esp
80103c75:	68 00 42 19 80       	push   $0x80194200
80103c7a:	e8 2a 0c 00 00       	call   801048a9 <release>
80103c7f:	83 c4 10             	add    $0x10,%esp
}
80103c82:	90                   	nop
80103c83:	c9                   	leave  
80103c84:	c3                   	ret    

80103c85 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103c85:	55                   	push   %ebp
80103c86:	89 e5                	mov    %esp,%ebp
80103c88:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103c8b:	e8 91 fd ff ff       	call   80103a21 <myproc>
80103c90:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103c93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c96:	8b 00                	mov    (%eax),%eax
80103c98:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103c9b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103c9f:	7e 2e                	jle    80103ccf <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103ca1:	8b 55 08             	mov    0x8(%ebp),%edx
80103ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ca7:	01 c2                	add    %eax,%edx
80103ca9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cac:	8b 40 04             	mov    0x4(%eax),%eax
80103caf:	83 ec 04             	sub    $0x4,%esp
80103cb2:	52                   	push   %edx
80103cb3:	ff 75 f4             	push   -0xc(%ebp)
80103cb6:	50                   	push   %eax
80103cb7:	e8 f2 3a 00 00       	call   801077ae <allocuvm>
80103cbc:	83 c4 10             	add    $0x10,%esp
80103cbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cc2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103cc6:	75 3b                	jne    80103d03 <growproc+0x7e>
      return -1;
80103cc8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ccd:	eb 4f                	jmp    80103d1e <growproc+0x99>
  } else if(n < 0){
80103ccf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103cd3:	79 2e                	jns    80103d03 <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103cd5:	8b 55 08             	mov    0x8(%ebp),%edx
80103cd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cdb:	01 c2                	add    %eax,%edx
80103cdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ce0:	8b 40 04             	mov    0x4(%eax),%eax
80103ce3:	83 ec 04             	sub    $0x4,%esp
80103ce6:	52                   	push   %edx
80103ce7:	ff 75 f4             	push   -0xc(%ebp)
80103cea:	50                   	push   %eax
80103ceb:	e8 c5 3b 00 00       	call   801078b5 <deallocuvm>
80103cf0:	83 c4 10             	add    $0x10,%esp
80103cf3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cf6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103cfa:	75 07                	jne    80103d03 <growproc+0x7e>
      return -1;
80103cfc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d01:	eb 1b                	jmp    80103d1e <growproc+0x99>
  }
  curproc->sz = sz;
80103d03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d06:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d09:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103d0b:	83 ec 0c             	sub    $0xc,%esp
80103d0e:	ff 75 f0             	push   -0x10(%ebp)
80103d11:	e8 bc 37 00 00       	call   801074d2 <switchuvm>
80103d16:	83 c4 10             	add    $0x10,%esp
  return 0;
80103d19:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103d1e:	c9                   	leave  
80103d1f:	c3                   	ret    

80103d20 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103d20:	55                   	push   %ebp
80103d21:	89 e5                	mov    %esp,%ebp
80103d23:	57                   	push   %edi
80103d24:	56                   	push   %esi
80103d25:	53                   	push   %ebx
80103d26:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103d29:	e8 f3 fc ff ff       	call   80103a21 <myproc>
80103d2e:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103d31:	e8 14 fd ff ff       	call   80103a4a <allocproc>
80103d36:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103d39:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103d3d:	75 0a                	jne    80103d49 <fork+0x29>
    return -1;
80103d3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d44:	e9 48 01 00 00       	jmp    80103e91 <fork+0x171>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103d49:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d4c:	8b 10                	mov    (%eax),%edx
80103d4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d51:	8b 40 04             	mov    0x4(%eax),%eax
80103d54:	83 ec 08             	sub    $0x8,%esp
80103d57:	52                   	push   %edx
80103d58:	50                   	push   %eax
80103d59:	e8 f5 3c 00 00       	call   80107a53 <copyuvm>
80103d5e:	83 c4 10             	add    $0x10,%esp
80103d61:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103d64:	89 42 04             	mov    %eax,0x4(%edx)
80103d67:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d6a:	8b 40 04             	mov    0x4(%eax),%eax
80103d6d:	85 c0                	test   %eax,%eax
80103d6f:	75 30                	jne    80103da1 <fork+0x81>
    kfree(np->kstack);
80103d71:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d74:	8b 40 08             	mov    0x8(%eax),%eax
80103d77:	83 ec 0c             	sub    $0xc,%esp
80103d7a:	50                   	push   %eax
80103d7b:	e8 77 e9 ff ff       	call   801026f7 <kfree>
80103d80:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103d83:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d86:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103d8d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d90:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103d97:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d9c:	e9 f0 00 00 00       	jmp    80103e91 <fork+0x171>
  }
  np->sz = curproc->sz;
80103da1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103da4:	8b 10                	mov    (%eax),%edx
80103da6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103da9:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103dab:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dae:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103db1:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103db4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103db7:	8b 48 18             	mov    0x18(%eax),%ecx
80103dba:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dbd:	8b 40 18             	mov    0x18(%eax),%eax
80103dc0:	89 c2                	mov    %eax,%edx
80103dc2:	89 cb                	mov    %ecx,%ebx
80103dc4:	b8 13 00 00 00       	mov    $0x13,%eax
80103dc9:	89 d7                	mov    %edx,%edi
80103dcb:	89 de                	mov    %ebx,%esi
80103dcd:	89 c1                	mov    %eax,%ecx
80103dcf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103dd1:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dd4:	8b 40 18             	mov    0x18(%eax),%eax
80103dd7:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80103dde:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103de5:	eb 3b                	jmp    80103e22 <fork+0x102>
    if(curproc->ofile[i])
80103de7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dea:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103ded:	83 c2 08             	add    $0x8,%edx
80103df0:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103df4:	85 c0                	test   %eax,%eax
80103df6:	74 26                	je     80103e1e <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103df8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dfb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103dfe:	83 c2 08             	add    $0x8,%edx
80103e01:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e05:	83 ec 0c             	sub    $0xc,%esp
80103e08:	50                   	push   %eax
80103e09:	e8 2d d2 ff ff       	call   8010103b <filedup>
80103e0e:	83 c4 10             	add    $0x10,%esp
80103e11:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e14:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103e17:	83 c1 08             	add    $0x8,%ecx
80103e1a:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80103e1e:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103e22:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103e26:	7e bf                	jle    80103de7 <fork+0xc7>
  np->cwd = idup(curproc->cwd);
80103e28:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e2b:	8b 40 68             	mov    0x68(%eax),%eax
80103e2e:	83 ec 0c             	sub    $0xc,%esp
80103e31:	50                   	push   %eax
80103e32:	e8 6a db ff ff       	call   801019a1 <idup>
80103e37:	83 c4 10             	add    $0x10,%esp
80103e3a:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e3d:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103e40:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e43:	8d 50 6c             	lea    0x6c(%eax),%edx
80103e46:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e49:	83 c0 6c             	add    $0x6c,%eax
80103e4c:	83 ec 04             	sub    $0x4,%esp
80103e4f:	6a 10                	push   $0x10
80103e51:	52                   	push   %edx
80103e52:	50                   	push   %eax
80103e53:	e8 5c 0e 00 00       	call   80104cb4 <safestrcpy>
80103e58:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103e5b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e5e:	8b 40 10             	mov    0x10(%eax),%eax
80103e61:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103e64:	83 ec 0c             	sub    $0xc,%esp
80103e67:	68 00 42 19 80       	push   $0x80194200
80103e6c:	e8 ca 09 00 00       	call   8010483b <acquire>
80103e71:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80103e74:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e77:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103e7e:	83 ec 0c             	sub    $0xc,%esp
80103e81:	68 00 42 19 80       	push   $0x80194200
80103e86:	e8 1e 0a 00 00       	call   801048a9 <release>
80103e8b:	83 c4 10             	add    $0x10,%esp

  return pid;
80103e8e:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80103e91:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103e94:	5b                   	pop    %ebx
80103e95:	5e                   	pop    %esi
80103e96:	5f                   	pop    %edi
80103e97:	5d                   	pop    %ebp
80103e98:	c3                   	ret    

80103e99 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80103e99:	55                   	push   %ebp
80103e9a:	89 e5                	mov    %esp,%ebp
80103e9c:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80103e9f:	e8 7d fb ff ff       	call   80103a21 <myproc>
80103ea4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80103ea7:	a1 34 61 19 80       	mov    0x80196134,%eax
80103eac:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103eaf:	75 0d                	jne    80103ebe <exit+0x25>
    panic("init exiting");
80103eb1:	83 ec 0c             	sub    $0xc,%esp
80103eb4:	68 b2 a3 10 80       	push   $0x8010a3b2
80103eb9:	e8 eb c6 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80103ebe:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80103ec5:	eb 3f                	jmp    80103f06 <exit+0x6d>
    if(curproc->ofile[fd]){
80103ec7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103eca:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103ecd:	83 c2 08             	add    $0x8,%edx
80103ed0:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103ed4:	85 c0                	test   %eax,%eax
80103ed6:	74 2a                	je     80103f02 <exit+0x69>
      fileclose(curproc->ofile[fd]);
80103ed8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103edb:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103ede:	83 c2 08             	add    $0x8,%edx
80103ee1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103ee5:	83 ec 0c             	sub    $0xc,%esp
80103ee8:	50                   	push   %eax
80103ee9:	e8 9e d1 ff ff       	call   8010108c <fileclose>
80103eee:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80103ef1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ef4:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103ef7:	83 c2 08             	add    $0x8,%edx
80103efa:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80103f01:	00 
  for(fd = 0; fd < NOFILE; fd++){
80103f02:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80103f06:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80103f0a:	7e bb                	jle    80103ec7 <exit+0x2e>
    }
  }

  begin_op();
80103f0c:	e8 1c f1 ff ff       	call   8010302d <begin_op>
  iput(curproc->cwd);
80103f11:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f14:	8b 40 68             	mov    0x68(%eax),%eax
80103f17:	83 ec 0c             	sub    $0xc,%esp
80103f1a:	50                   	push   %eax
80103f1b:	e8 1c dc ff ff       	call   80101b3c <iput>
80103f20:	83 c4 10             	add    $0x10,%esp
  end_op();
80103f23:	e8 91 f1 ff ff       	call   801030b9 <end_op>
  curproc->cwd = 0;
80103f28:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f2b:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80103f32:	83 ec 0c             	sub    $0xc,%esp
80103f35:	68 00 42 19 80       	push   $0x80194200
80103f3a:	e8 fc 08 00 00       	call   8010483b <acquire>
80103f3f:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80103f42:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f45:	8b 40 14             	mov    0x14(%eax),%eax
80103f48:	83 ec 0c             	sub    $0xc,%esp
80103f4b:	50                   	push   %eax
80103f4c:	e8 20 04 00 00       	call   80104371 <wakeup1>
80103f51:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f54:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103f5b:	eb 37                	jmp    80103f94 <exit+0xfb>
    if(p->parent == curproc){
80103f5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f60:	8b 40 14             	mov    0x14(%eax),%eax
80103f63:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103f66:	75 28                	jne    80103f90 <exit+0xf7>
      p->parent = initproc;
80103f68:	8b 15 34 61 19 80    	mov    0x80196134,%edx
80103f6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f71:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80103f74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f77:	8b 40 0c             	mov    0xc(%eax),%eax
80103f7a:	83 f8 05             	cmp    $0x5,%eax
80103f7d:	75 11                	jne    80103f90 <exit+0xf7>
        wakeup1(initproc);
80103f7f:	a1 34 61 19 80       	mov    0x80196134,%eax
80103f84:	83 ec 0c             	sub    $0xc,%esp
80103f87:	50                   	push   %eax
80103f88:	e8 e4 03 00 00       	call   80104371 <wakeup1>
80103f8d:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f90:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80103f94:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
80103f9b:	72 c0                	jb     80103f5d <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80103f9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fa0:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80103fa7:	e8 e5 01 00 00       	call   80104191 <sched>
  panic("zombie exit");
80103fac:	83 ec 0c             	sub    $0xc,%esp
80103faf:	68 bf a3 10 80       	push   $0x8010a3bf
80103fb4:	e8 f0 c5 ff ff       	call   801005a9 <panic>

80103fb9 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80103fb9:	55                   	push   %ebp
80103fba:	89 e5                	mov    %esp,%ebp
80103fbc:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80103fbf:	e8 5d fa ff ff       	call   80103a21 <myproc>
80103fc4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80103fc7:	83 ec 0c             	sub    $0xc,%esp
80103fca:	68 00 42 19 80       	push   $0x80194200
80103fcf:	e8 67 08 00 00       	call   8010483b <acquire>
80103fd4:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80103fd7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103fde:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103fe5:	e9 a1 00 00 00       	jmp    8010408b <wait+0xd2>
      if(p->parent != curproc)
80103fea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fed:	8b 40 14             	mov    0x14(%eax),%eax
80103ff0:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103ff3:	0f 85 8d 00 00 00    	jne    80104086 <wait+0xcd>
        continue;
      havekids = 1;
80103ff9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104000:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104003:	8b 40 0c             	mov    0xc(%eax),%eax
80104006:	83 f8 05             	cmp    $0x5,%eax
80104009:	75 7c                	jne    80104087 <wait+0xce>
        // Found one.
        pid = p->pid;
8010400b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010400e:	8b 40 10             	mov    0x10(%eax),%eax
80104011:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104014:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104017:	8b 40 08             	mov    0x8(%eax),%eax
8010401a:	83 ec 0c             	sub    $0xc,%esp
8010401d:	50                   	push   %eax
8010401e:	e8 d4 e6 ff ff       	call   801026f7 <kfree>
80104023:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104026:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104029:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104030:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104033:	8b 40 04             	mov    0x4(%eax),%eax
80104036:	83 ec 0c             	sub    $0xc,%esp
80104039:	50                   	push   %eax
8010403a:	e8 3a 39 00 00       	call   80107979 <freevm>
8010403f:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104042:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104045:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010404c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010404f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104056:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104059:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010405d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104060:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104067:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010406a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104071:	83 ec 0c             	sub    $0xc,%esp
80104074:	68 00 42 19 80       	push   $0x80194200
80104079:	e8 2b 08 00 00       	call   801048a9 <release>
8010407e:	83 c4 10             	add    $0x10,%esp
        return pid;
80104081:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104084:	eb 51                	jmp    801040d7 <wait+0x11e>
        continue;
80104086:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104087:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010408b:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
80104092:	0f 82 52 ff ff ff    	jb     80103fea <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104098:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010409c:	74 0a                	je     801040a8 <wait+0xef>
8010409e:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040a1:	8b 40 24             	mov    0x24(%eax),%eax
801040a4:	85 c0                	test   %eax,%eax
801040a6:	74 17                	je     801040bf <wait+0x106>
      release(&ptable.lock);
801040a8:	83 ec 0c             	sub    $0xc,%esp
801040ab:	68 00 42 19 80       	push   $0x80194200
801040b0:	e8 f4 07 00 00       	call   801048a9 <release>
801040b5:	83 c4 10             	add    $0x10,%esp
      return -1;
801040b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040bd:	eb 18                	jmp    801040d7 <wait+0x11e>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801040bf:	83 ec 08             	sub    $0x8,%esp
801040c2:	68 00 42 19 80       	push   $0x80194200
801040c7:	ff 75 ec             	push   -0x14(%ebp)
801040ca:	e8 fb 01 00 00       	call   801042ca <sleep>
801040cf:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801040d2:	e9 00 ff ff ff       	jmp    80103fd7 <wait+0x1e>
  }
}
801040d7:	c9                   	leave  
801040d8:	c3                   	ret    

801040d9 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801040d9:	55                   	push   %ebp
801040da:	89 e5                	mov    %esp,%ebp
801040dc:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801040df:	e8 c5 f8 ff ff       	call   801039a9 <mycpu>
801040e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
801040e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040ea:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801040f1:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
801040f4:	e8 70 f8 ff ff       	call   80103969 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801040f9:	83 ec 0c             	sub    $0xc,%esp
801040fc:	68 00 42 19 80       	push   $0x80194200
80104101:	e8 35 07 00 00       	call   8010483b <acquire>
80104106:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104109:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104110:	eb 61                	jmp    80104173 <scheduler+0x9a>
      if(p->state != RUNNABLE)
80104112:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104115:	8b 40 0c             	mov    0xc(%eax),%eax
80104118:	83 f8 03             	cmp    $0x3,%eax
8010411b:	75 51                	jne    8010416e <scheduler+0x95>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
8010411d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104120:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104123:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104129:	83 ec 0c             	sub    $0xc,%esp
8010412c:	ff 75 f4             	push   -0xc(%ebp)
8010412f:	e8 9e 33 00 00       	call   801074d2 <switchuvm>
80104134:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104137:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010413a:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104141:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104144:	8b 40 1c             	mov    0x1c(%eax),%eax
80104147:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010414a:	83 c2 04             	add    $0x4,%edx
8010414d:	83 ec 08             	sub    $0x8,%esp
80104150:	50                   	push   %eax
80104151:	52                   	push   %edx
80104152:	e8 cf 0b 00 00       	call   80104d26 <swtch>
80104157:	83 c4 10             	add    $0x10,%esp
      switchkvm();
8010415a:	e8 5a 33 00 00       	call   801074b9 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
8010415f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104162:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104169:	00 00 00 
8010416c:	eb 01                	jmp    8010416f <scheduler+0x96>
        continue;
8010416e:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010416f:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104173:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
8010417a:	72 96                	jb     80104112 <scheduler+0x39>
    }
    release(&ptable.lock);
8010417c:	83 ec 0c             	sub    $0xc,%esp
8010417f:	68 00 42 19 80       	push   $0x80194200
80104184:	e8 20 07 00 00       	call   801048a9 <release>
80104189:	83 c4 10             	add    $0x10,%esp
    sti();
8010418c:	e9 63 ff ff ff       	jmp    801040f4 <scheduler+0x1b>

80104191 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104191:	55                   	push   %ebp
80104192:	89 e5                	mov    %esp,%ebp
80104194:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104197:	e8 85 f8 ff ff       	call   80103a21 <myproc>
8010419c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
8010419f:	83 ec 0c             	sub    $0xc,%esp
801041a2:	68 00 42 19 80       	push   $0x80194200
801041a7:	e8 ca 07 00 00       	call   80104976 <holding>
801041ac:	83 c4 10             	add    $0x10,%esp
801041af:	85 c0                	test   %eax,%eax
801041b1:	75 0d                	jne    801041c0 <sched+0x2f>
    panic("sched ptable.lock");
801041b3:	83 ec 0c             	sub    $0xc,%esp
801041b6:	68 cb a3 10 80       	push   $0x8010a3cb
801041bb:	e8 e9 c3 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
801041c0:	e8 e4 f7 ff ff       	call   801039a9 <mycpu>
801041c5:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801041cb:	83 f8 01             	cmp    $0x1,%eax
801041ce:	74 0d                	je     801041dd <sched+0x4c>
    panic("sched locks");
801041d0:	83 ec 0c             	sub    $0xc,%esp
801041d3:	68 dd a3 10 80       	push   $0x8010a3dd
801041d8:	e8 cc c3 ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
801041dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041e0:	8b 40 0c             	mov    0xc(%eax),%eax
801041e3:	83 f8 04             	cmp    $0x4,%eax
801041e6:	75 0d                	jne    801041f5 <sched+0x64>
    panic("sched running");
801041e8:	83 ec 0c             	sub    $0xc,%esp
801041eb:	68 e9 a3 10 80       	push   $0x8010a3e9
801041f0:	e8 b4 c3 ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
801041f5:	e8 5f f7 ff ff       	call   80103959 <readeflags>
801041fa:	25 00 02 00 00       	and    $0x200,%eax
801041ff:	85 c0                	test   %eax,%eax
80104201:	74 0d                	je     80104210 <sched+0x7f>
    panic("sched interruptible");
80104203:	83 ec 0c             	sub    $0xc,%esp
80104206:	68 f7 a3 10 80       	push   $0x8010a3f7
8010420b:	e8 99 c3 ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
80104210:	e8 94 f7 ff ff       	call   801039a9 <mycpu>
80104215:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010421b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
8010421e:	e8 86 f7 ff ff       	call   801039a9 <mycpu>
80104223:	8b 40 04             	mov    0x4(%eax),%eax
80104226:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104229:	83 c2 1c             	add    $0x1c,%edx
8010422c:	83 ec 08             	sub    $0x8,%esp
8010422f:	50                   	push   %eax
80104230:	52                   	push   %edx
80104231:	e8 f0 0a 00 00       	call   80104d26 <swtch>
80104236:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104239:	e8 6b f7 ff ff       	call   801039a9 <mycpu>
8010423e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104241:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104247:	90                   	nop
80104248:	c9                   	leave  
80104249:	c3                   	ret    

8010424a <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
8010424a:	55                   	push   %ebp
8010424b:	89 e5                	mov    %esp,%ebp
8010424d:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104250:	83 ec 0c             	sub    $0xc,%esp
80104253:	68 00 42 19 80       	push   $0x80194200
80104258:	e8 de 05 00 00       	call   8010483b <acquire>
8010425d:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104260:	e8 bc f7 ff ff       	call   80103a21 <myproc>
80104265:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010426c:	e8 20 ff ff ff       	call   80104191 <sched>
  release(&ptable.lock);
80104271:	83 ec 0c             	sub    $0xc,%esp
80104274:	68 00 42 19 80       	push   $0x80194200
80104279:	e8 2b 06 00 00       	call   801048a9 <release>
8010427e:	83 c4 10             	add    $0x10,%esp
}
80104281:	90                   	nop
80104282:	c9                   	leave  
80104283:	c3                   	ret    

80104284 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104284:	55                   	push   %ebp
80104285:	89 e5                	mov    %esp,%ebp
80104287:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
8010428a:	83 ec 0c             	sub    $0xc,%esp
8010428d:	68 00 42 19 80       	push   $0x80194200
80104292:	e8 12 06 00 00       	call   801048a9 <release>
80104297:	83 c4 10             	add    $0x10,%esp

  if (first) {
8010429a:	a1 04 f0 10 80       	mov    0x8010f004,%eax
8010429f:	85 c0                	test   %eax,%eax
801042a1:	74 24                	je     801042c7 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801042a3:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
801042aa:	00 00 00 
    iinit(ROOTDEV);
801042ad:	83 ec 0c             	sub    $0xc,%esp
801042b0:	6a 01                	push   $0x1
801042b2:	e8 b2 d3 ff ff       	call   80101669 <iinit>
801042b7:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801042ba:	83 ec 0c             	sub    $0xc,%esp
801042bd:	6a 01                	push   $0x1
801042bf:	e8 4a eb ff ff       	call   80102e0e <initlog>
801042c4:	83 c4 10             	add    $0x10,%esp
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
801042c7:	90                   	nop
801042c8:	c9                   	leave  
801042c9:	c3                   	ret    

801042ca <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801042ca:	55                   	push   %ebp
801042cb:	89 e5                	mov    %esp,%ebp
801042cd:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
801042d0:	e8 4c f7 ff ff       	call   80103a21 <myproc>
801042d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
801042d8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801042dc:	75 0d                	jne    801042eb <sleep+0x21>
    panic("sleep");
801042de:	83 ec 0c             	sub    $0xc,%esp
801042e1:	68 0b a4 10 80       	push   $0x8010a40b
801042e6:	e8 be c2 ff ff       	call   801005a9 <panic>

  if(lk == 0)
801042eb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801042ef:	75 0d                	jne    801042fe <sleep+0x34>
    panic("sleep without lk");
801042f1:	83 ec 0c             	sub    $0xc,%esp
801042f4:	68 11 a4 10 80       	push   $0x8010a411
801042f9:	e8 ab c2 ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801042fe:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
80104305:	74 1e                	je     80104325 <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104307:	83 ec 0c             	sub    $0xc,%esp
8010430a:	68 00 42 19 80       	push   $0x80194200
8010430f:	e8 27 05 00 00       	call   8010483b <acquire>
80104314:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104317:	83 ec 0c             	sub    $0xc,%esp
8010431a:	ff 75 0c             	push   0xc(%ebp)
8010431d:	e8 87 05 00 00       	call   801048a9 <release>
80104322:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104325:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104328:	8b 55 08             	mov    0x8(%ebp),%edx
8010432b:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
8010432e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104331:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104338:	e8 54 fe ff ff       	call   80104191 <sched>

  // Tidy up.
  p->chan = 0;
8010433d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104340:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104347:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
8010434e:	74 1e                	je     8010436e <sleep+0xa4>
    release(&ptable.lock);
80104350:	83 ec 0c             	sub    $0xc,%esp
80104353:	68 00 42 19 80       	push   $0x80194200
80104358:	e8 4c 05 00 00       	call   801048a9 <release>
8010435d:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104360:	83 ec 0c             	sub    $0xc,%esp
80104363:	ff 75 0c             	push   0xc(%ebp)
80104366:	e8 d0 04 00 00       	call   8010483b <acquire>
8010436b:	83 c4 10             	add    $0x10,%esp
  }
}
8010436e:	90                   	nop
8010436f:	c9                   	leave  
80104370:	c3                   	ret    

80104371 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104371:	55                   	push   %ebp
80104372:	89 e5                	mov    %esp,%ebp
80104374:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104377:	c7 45 fc 34 42 19 80 	movl   $0x80194234,-0x4(%ebp)
8010437e:	eb 24                	jmp    801043a4 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104380:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104383:	8b 40 0c             	mov    0xc(%eax),%eax
80104386:	83 f8 02             	cmp    $0x2,%eax
80104389:	75 15                	jne    801043a0 <wakeup1+0x2f>
8010438b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010438e:	8b 40 20             	mov    0x20(%eax),%eax
80104391:	39 45 08             	cmp    %eax,0x8(%ebp)
80104394:	75 0a                	jne    801043a0 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104396:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104399:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043a0:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
801043a4:	81 7d fc 34 61 19 80 	cmpl   $0x80196134,-0x4(%ebp)
801043ab:	72 d3                	jb     80104380 <wakeup1+0xf>
}
801043ad:	90                   	nop
801043ae:	90                   	nop
801043af:	c9                   	leave  
801043b0:	c3                   	ret    

801043b1 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801043b1:	55                   	push   %ebp
801043b2:	89 e5                	mov    %esp,%ebp
801043b4:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801043b7:	83 ec 0c             	sub    $0xc,%esp
801043ba:	68 00 42 19 80       	push   $0x80194200
801043bf:	e8 77 04 00 00       	call   8010483b <acquire>
801043c4:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801043c7:	83 ec 0c             	sub    $0xc,%esp
801043ca:	ff 75 08             	push   0x8(%ebp)
801043cd:	e8 9f ff ff ff       	call   80104371 <wakeup1>
801043d2:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801043d5:	83 ec 0c             	sub    $0xc,%esp
801043d8:	68 00 42 19 80       	push   $0x80194200
801043dd:	e8 c7 04 00 00       	call   801048a9 <release>
801043e2:	83 c4 10             	add    $0x10,%esp
}
801043e5:	90                   	nop
801043e6:	c9                   	leave  
801043e7:	c3                   	ret    

801043e8 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801043e8:	55                   	push   %ebp
801043e9:	89 e5                	mov    %esp,%ebp
801043eb:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801043ee:	83 ec 0c             	sub    $0xc,%esp
801043f1:	68 00 42 19 80       	push   $0x80194200
801043f6:	e8 40 04 00 00       	call   8010483b <acquire>
801043fb:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801043fe:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104405:	eb 45                	jmp    8010444c <kill+0x64>
    if(p->pid == pid){
80104407:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010440a:	8b 40 10             	mov    0x10(%eax),%eax
8010440d:	39 45 08             	cmp    %eax,0x8(%ebp)
80104410:	75 36                	jne    80104448 <kill+0x60>
      p->killed = 1;
80104412:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104415:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
8010441c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010441f:	8b 40 0c             	mov    0xc(%eax),%eax
80104422:	83 f8 02             	cmp    $0x2,%eax
80104425:	75 0a                	jne    80104431 <kill+0x49>
        p->state = RUNNABLE;
80104427:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010442a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104431:	83 ec 0c             	sub    $0xc,%esp
80104434:	68 00 42 19 80       	push   $0x80194200
80104439:	e8 6b 04 00 00       	call   801048a9 <release>
8010443e:	83 c4 10             	add    $0x10,%esp
      return 0;
80104441:	b8 00 00 00 00       	mov    $0x0,%eax
80104446:	eb 22                	jmp    8010446a <kill+0x82>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104448:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010444c:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
80104453:	72 b2                	jb     80104407 <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104455:	83 ec 0c             	sub    $0xc,%esp
80104458:	68 00 42 19 80       	push   $0x80194200
8010445d:	e8 47 04 00 00       	call   801048a9 <release>
80104462:	83 c4 10             	add    $0x10,%esp
  return -1;
80104465:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010446a:	c9                   	leave  
8010446b:	c3                   	ret    

8010446c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010446c:	55                   	push   %ebp
8010446d:	89 e5                	mov    %esp,%ebp
8010446f:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104472:	c7 45 f0 34 42 19 80 	movl   $0x80194234,-0x10(%ebp)
80104479:	e9 d7 00 00 00       	jmp    80104555 <procdump+0xe9>
    if(p->state == UNUSED)
8010447e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104481:	8b 40 0c             	mov    0xc(%eax),%eax
80104484:	85 c0                	test   %eax,%eax
80104486:	0f 84 c4 00 00 00    	je     80104550 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010448c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010448f:	8b 40 0c             	mov    0xc(%eax),%eax
80104492:	83 f8 05             	cmp    $0x5,%eax
80104495:	77 23                	ja     801044ba <procdump+0x4e>
80104497:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010449a:	8b 40 0c             	mov    0xc(%eax),%eax
8010449d:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801044a4:	85 c0                	test   %eax,%eax
801044a6:	74 12                	je     801044ba <procdump+0x4e>
      state = states[p->state];
801044a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044ab:	8b 40 0c             	mov    0xc(%eax),%eax
801044ae:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801044b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
801044b8:	eb 07                	jmp    801044c1 <procdump+0x55>
    else
      state = "???";
801044ba:	c7 45 ec 22 a4 10 80 	movl   $0x8010a422,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801044c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044c4:	8d 50 6c             	lea    0x6c(%eax),%edx
801044c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044ca:	8b 40 10             	mov    0x10(%eax),%eax
801044cd:	52                   	push   %edx
801044ce:	ff 75 ec             	push   -0x14(%ebp)
801044d1:	50                   	push   %eax
801044d2:	68 26 a4 10 80       	push   $0x8010a426
801044d7:	e8 18 bf ff ff       	call   801003f4 <cprintf>
801044dc:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801044df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044e2:	8b 40 0c             	mov    0xc(%eax),%eax
801044e5:	83 f8 02             	cmp    $0x2,%eax
801044e8:	75 54                	jne    8010453e <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801044ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044ed:	8b 40 1c             	mov    0x1c(%eax),%eax
801044f0:	8b 40 0c             	mov    0xc(%eax),%eax
801044f3:	83 c0 08             	add    $0x8,%eax
801044f6:	89 c2                	mov    %eax,%edx
801044f8:	83 ec 08             	sub    $0x8,%esp
801044fb:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801044fe:	50                   	push   %eax
801044ff:	52                   	push   %edx
80104500:	e8 f6 03 00 00       	call   801048fb <getcallerpcs>
80104505:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104508:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010450f:	eb 1c                	jmp    8010452d <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104511:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104514:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104518:	83 ec 08             	sub    $0x8,%esp
8010451b:	50                   	push   %eax
8010451c:	68 2f a4 10 80       	push   $0x8010a42f
80104521:	e8 ce be ff ff       	call   801003f4 <cprintf>
80104526:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104529:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010452d:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104531:	7f 0b                	jg     8010453e <procdump+0xd2>
80104533:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104536:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010453a:	85 c0                	test   %eax,%eax
8010453c:	75 d3                	jne    80104511 <procdump+0xa5>
    }
    cprintf("\n");
8010453e:	83 ec 0c             	sub    $0xc,%esp
80104541:	68 33 a4 10 80       	push   $0x8010a433
80104546:	e8 a9 be ff ff       	call   801003f4 <cprintf>
8010454b:	83 c4 10             	add    $0x10,%esp
8010454e:	eb 01                	jmp    80104551 <procdump+0xe5>
      continue;
80104550:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104551:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80104555:	81 7d f0 34 61 19 80 	cmpl   $0x80196134,-0x10(%ebp)
8010455c:	0f 82 1c ff ff ff    	jb     8010447e <procdump+0x12>
  }
}
80104562:	90                   	nop
80104563:	90                   	nop
80104564:	c9                   	leave  
80104565:	c3                   	ret    

80104566 <printpt>:

int
printpt(int pid)
{
80104566:	55                   	push   %ebp
80104567:	89 e5                	mov    %esp,%ebp
80104569:	56                   	push   %esi
8010456a:	53                   	push   %ebx
8010456b:	83 ec 10             	sub    $0x10,%esp
  pde_t* pgdir = myproc()->pgdir;
8010456e:	e8 ae f4 ff ff       	call   80103a21 <myproc>
80104573:	8b 40 04             	mov    0x4(%eax),%eax
80104576:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  cprintf("START PAGE TABLE (pid %d)\n", pid);
80104579:	83 ec 08             	sub    $0x8,%esp
8010457c:	ff 75 08             	push   0x8(%ebp)
8010457f:	68 35 a4 10 80       	push   $0x8010a435
80104584:	e8 6b be ff ff       	call   801003f4 <cprintf>
80104589:	83 c4 10             	add    $0x10,%esp
  
  // 유저영역의 페이지 디렉토리를 조사한다.
  for (uint i = 0; i < NPDENTRIES / 2; i++) {
8010458c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104593:	e9 fb 00 00 00       	jmp    80104693 <printpt+0x12d>

    // 활성화 된 페이지 디렉토리이면
    if (pgdir[i] & PTE_P) {
80104598:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010459b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801045a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801045a5:	01 d0                	add    %edx,%eax
801045a7:	8b 00                	mov    (%eax),%eax
801045a9:	83 e0 01             	and    $0x1,%eax
801045ac:	85 c0                	test   %eax,%eax
801045ae:	0f 84 db 00 00 00    	je     8010468f <printpt+0x129>
      
      // 해당 주소의 페이지 테이블을 가져온다.
      pte_t* pgtab = (pte_t*)P2V(PTE_ADDR(pgdir[i]));
801045b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801045be:	8b 45 ec             	mov    -0x14(%ebp),%eax
801045c1:	01 d0                	add    %edx,%eax
801045c3:	8b 00                	mov    (%eax),%eax
801045c5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801045ca:	05 00 00 00 80       	add    $0x80000000,%eax
801045cf:	89 45 e8             	mov    %eax,-0x18(%ebp)
      
      // 페이지 테이블의 개수 1024개를 모두 조사한다.
      for (uint j = 0; j < NPTENTRIES; j++) {
801045d2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801045d9:	e9 a4 00 00 00       	jmp    80104682 <printpt+0x11c>
        
        if (pgtab[j] & PTE_P) {
801045de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045e1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801045e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801045eb:	01 d0                	add    %edx,%eax
801045ed:	8b 00                	mov    (%eax),%eax
801045ef:	83 e0 01             	and    $0x1,%eax
801045f2:	85 c0                	test   %eax,%eax
801045f4:	0f 84 84 00 00 00    	je     8010467e <printpt+0x118>
          cprintf("%x %s %s %s %x\n", NPDENTRIES * i + j, "P", (pgtab[j] & PTE_U) ? "U" : "K", (pgtab[j] & PTE_W) ? "W" : "-", pgtab[j] >> PGSHIFT);
801045fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045fd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104604:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104607:	01 d0                	add    %edx,%eax
80104609:	8b 00                	mov    (%eax),%eax
8010460b:	c1 e8 0c             	shr    $0xc,%eax
8010460e:	89 c2                	mov    %eax,%edx
80104610:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104613:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
8010461a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010461d:	01 c8                	add    %ecx,%eax
8010461f:	8b 00                	mov    (%eax),%eax
80104621:	83 e0 02             	and    $0x2,%eax
80104624:	85 c0                	test   %eax,%eax
80104626:	74 07                	je     8010462f <printpt+0xc9>
80104628:	bb 50 a4 10 80       	mov    $0x8010a450,%ebx
8010462d:	eb 05                	jmp    80104634 <printpt+0xce>
8010462f:	bb 52 a4 10 80       	mov    $0x8010a452,%ebx
80104634:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104637:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
8010463e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104641:	01 c8                	add    %ecx,%eax
80104643:	8b 00                	mov    (%eax),%eax
80104645:	83 e0 04             	and    $0x4,%eax
80104648:	85 c0                	test   %eax,%eax
8010464a:	74 07                	je     80104653 <printpt+0xed>
8010464c:	b9 54 a4 10 80       	mov    $0x8010a454,%ecx
80104651:	eb 05                	jmp    80104658 <printpt+0xf2>
80104653:	b9 56 a4 10 80       	mov    $0x8010a456,%ecx
80104658:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010465b:	c1 e0 0a             	shl    $0xa,%eax
8010465e:	89 c6                	mov    %eax,%esi
80104660:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104663:	01 f0                	add    %esi,%eax
80104665:	83 ec 08             	sub    $0x8,%esp
80104668:	52                   	push   %edx
80104669:	53                   	push   %ebx
8010466a:	51                   	push   %ecx
8010466b:	68 58 a4 10 80       	push   $0x8010a458
80104670:	50                   	push   %eax
80104671:	68 5a a4 10 80       	push   $0x8010a45a
80104676:	e8 79 bd ff ff       	call   801003f4 <cprintf>
8010467b:	83 c4 20             	add    $0x20,%esp
      for (uint j = 0; j < NPTENTRIES; j++) {
8010467e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104682:	81 7d f0 ff 03 00 00 	cmpl   $0x3ff,-0x10(%ebp)
80104689:	0f 86 4f ff ff ff    	jbe    801045de <printpt+0x78>
  for (uint i = 0; i < NPDENTRIES / 2; i++) {
8010468f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104693:	81 7d f4 ff 01 00 00 	cmpl   $0x1ff,-0xc(%ebp)
8010469a:	0f 86 f8 fe ff ff    	jbe    80104598 <printpt+0x32>
        }
      }
    }
  }
  cprintf("END PAGE TABLE\n");
801046a0:	83 ec 0c             	sub    $0xc,%esp
801046a3:	68 6a a4 10 80       	push   $0x8010a46a
801046a8:	e8 47 bd ff ff       	call   801003f4 <cprintf>
801046ad:	83 c4 10             	add    $0x10,%esp
  return 0;
801046b0:	b8 00 00 00 00       	mov    $0x0,%eax
801046b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
801046b8:	5b                   	pop    %ebx
801046b9:	5e                   	pop    %esi
801046ba:	5d                   	pop    %ebp
801046bb:	c3                   	ret    

801046bc <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801046bc:	55                   	push   %ebp
801046bd:	89 e5                	mov    %esp,%ebp
801046bf:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
801046c2:	8b 45 08             	mov    0x8(%ebp),%eax
801046c5:	83 c0 04             	add    $0x4,%eax
801046c8:	83 ec 08             	sub    $0x8,%esp
801046cb:	68 a4 a4 10 80       	push   $0x8010a4a4
801046d0:	50                   	push   %eax
801046d1:	e8 43 01 00 00       	call   80104819 <initlock>
801046d6:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
801046d9:	8b 45 08             	mov    0x8(%ebp),%eax
801046dc:	8b 55 0c             	mov    0xc(%ebp),%edx
801046df:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
801046e2:	8b 45 08             	mov    0x8(%ebp),%eax
801046e5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801046eb:	8b 45 08             	mov    0x8(%ebp),%eax
801046ee:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
801046f5:	90                   	nop
801046f6:	c9                   	leave  
801046f7:	c3                   	ret    

801046f8 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801046f8:	55                   	push   %ebp
801046f9:	89 e5                	mov    %esp,%ebp
801046fb:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801046fe:	8b 45 08             	mov    0x8(%ebp),%eax
80104701:	83 c0 04             	add    $0x4,%eax
80104704:	83 ec 0c             	sub    $0xc,%esp
80104707:	50                   	push   %eax
80104708:	e8 2e 01 00 00       	call   8010483b <acquire>
8010470d:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104710:	eb 15                	jmp    80104727 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104712:	8b 45 08             	mov    0x8(%ebp),%eax
80104715:	83 c0 04             	add    $0x4,%eax
80104718:	83 ec 08             	sub    $0x8,%esp
8010471b:	50                   	push   %eax
8010471c:	ff 75 08             	push   0x8(%ebp)
8010471f:	e8 a6 fb ff ff       	call   801042ca <sleep>
80104724:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104727:	8b 45 08             	mov    0x8(%ebp),%eax
8010472a:	8b 00                	mov    (%eax),%eax
8010472c:	85 c0                	test   %eax,%eax
8010472e:	75 e2                	jne    80104712 <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104730:	8b 45 08             	mov    0x8(%ebp),%eax
80104733:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104739:	e8 e3 f2 ff ff       	call   80103a21 <myproc>
8010473e:	8b 50 10             	mov    0x10(%eax),%edx
80104741:	8b 45 08             	mov    0x8(%ebp),%eax
80104744:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104747:	8b 45 08             	mov    0x8(%ebp),%eax
8010474a:	83 c0 04             	add    $0x4,%eax
8010474d:	83 ec 0c             	sub    $0xc,%esp
80104750:	50                   	push   %eax
80104751:	e8 53 01 00 00       	call   801048a9 <release>
80104756:	83 c4 10             	add    $0x10,%esp
}
80104759:	90                   	nop
8010475a:	c9                   	leave  
8010475b:	c3                   	ret    

8010475c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
8010475c:	55                   	push   %ebp
8010475d:	89 e5                	mov    %esp,%ebp
8010475f:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104762:	8b 45 08             	mov    0x8(%ebp),%eax
80104765:	83 c0 04             	add    $0x4,%eax
80104768:	83 ec 0c             	sub    $0xc,%esp
8010476b:	50                   	push   %eax
8010476c:	e8 ca 00 00 00       	call   8010483b <acquire>
80104771:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104774:	8b 45 08             	mov    0x8(%ebp),%eax
80104777:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010477d:	8b 45 08             	mov    0x8(%ebp),%eax
80104780:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104787:	83 ec 0c             	sub    $0xc,%esp
8010478a:	ff 75 08             	push   0x8(%ebp)
8010478d:	e8 1f fc ff ff       	call   801043b1 <wakeup>
80104792:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104795:	8b 45 08             	mov    0x8(%ebp),%eax
80104798:	83 c0 04             	add    $0x4,%eax
8010479b:	83 ec 0c             	sub    $0xc,%esp
8010479e:	50                   	push   %eax
8010479f:	e8 05 01 00 00       	call   801048a9 <release>
801047a4:	83 c4 10             	add    $0x10,%esp
}
801047a7:	90                   	nop
801047a8:	c9                   	leave  
801047a9:	c3                   	ret    

801047aa <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801047aa:	55                   	push   %ebp
801047ab:	89 e5                	mov    %esp,%ebp
801047ad:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
801047b0:	8b 45 08             	mov    0x8(%ebp),%eax
801047b3:	83 c0 04             	add    $0x4,%eax
801047b6:	83 ec 0c             	sub    $0xc,%esp
801047b9:	50                   	push   %eax
801047ba:	e8 7c 00 00 00       	call   8010483b <acquire>
801047bf:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
801047c2:	8b 45 08             	mov    0x8(%ebp),%eax
801047c5:	8b 00                	mov    (%eax),%eax
801047c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
801047ca:	8b 45 08             	mov    0x8(%ebp),%eax
801047cd:	83 c0 04             	add    $0x4,%eax
801047d0:	83 ec 0c             	sub    $0xc,%esp
801047d3:	50                   	push   %eax
801047d4:	e8 d0 00 00 00       	call   801048a9 <release>
801047d9:	83 c4 10             	add    $0x10,%esp
  return r;
801047dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801047df:	c9                   	leave  
801047e0:	c3                   	ret    

801047e1 <readeflags>:
{
801047e1:	55                   	push   %ebp
801047e2:	89 e5                	mov    %esp,%ebp
801047e4:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801047e7:	9c                   	pushf  
801047e8:	58                   	pop    %eax
801047e9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801047ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801047ef:	c9                   	leave  
801047f0:	c3                   	ret    

801047f1 <cli>:
{
801047f1:	55                   	push   %ebp
801047f2:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801047f4:	fa                   	cli    
}
801047f5:	90                   	nop
801047f6:	5d                   	pop    %ebp
801047f7:	c3                   	ret    

801047f8 <sti>:
{
801047f8:	55                   	push   %ebp
801047f9:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801047fb:	fb                   	sti    
}
801047fc:	90                   	nop
801047fd:	5d                   	pop    %ebp
801047fe:	c3                   	ret    

801047ff <xchg>:
{
801047ff:	55                   	push   %ebp
80104800:	89 e5                	mov    %esp,%ebp
80104802:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104805:	8b 55 08             	mov    0x8(%ebp),%edx
80104808:	8b 45 0c             	mov    0xc(%ebp),%eax
8010480b:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010480e:	f0 87 02             	lock xchg %eax,(%edx)
80104811:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104814:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104817:	c9                   	leave  
80104818:	c3                   	ret    

80104819 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104819:	55                   	push   %ebp
8010481a:	89 e5                	mov    %esp,%ebp
  lk->name = name;
8010481c:	8b 45 08             	mov    0x8(%ebp),%eax
8010481f:	8b 55 0c             	mov    0xc(%ebp),%edx
80104822:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104825:	8b 45 08             	mov    0x8(%ebp),%eax
80104828:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010482e:	8b 45 08             	mov    0x8(%ebp),%eax
80104831:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104838:	90                   	nop
80104839:	5d                   	pop    %ebp
8010483a:	c3                   	ret    

8010483b <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010483b:	55                   	push   %ebp
8010483c:	89 e5                	mov    %esp,%ebp
8010483e:	53                   	push   %ebx
8010483f:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104842:	e8 5f 01 00 00       	call   801049a6 <pushcli>
  if(holding(lk)){
80104847:	8b 45 08             	mov    0x8(%ebp),%eax
8010484a:	83 ec 0c             	sub    $0xc,%esp
8010484d:	50                   	push   %eax
8010484e:	e8 23 01 00 00       	call   80104976 <holding>
80104853:	83 c4 10             	add    $0x10,%esp
80104856:	85 c0                	test   %eax,%eax
80104858:	74 0d                	je     80104867 <acquire+0x2c>
    panic("acquire");
8010485a:	83 ec 0c             	sub    $0xc,%esp
8010485d:	68 af a4 10 80       	push   $0x8010a4af
80104862:	e8 42 bd ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104867:	90                   	nop
80104868:	8b 45 08             	mov    0x8(%ebp),%eax
8010486b:	83 ec 08             	sub    $0x8,%esp
8010486e:	6a 01                	push   $0x1
80104870:	50                   	push   %eax
80104871:	e8 89 ff ff ff       	call   801047ff <xchg>
80104876:	83 c4 10             	add    $0x10,%esp
80104879:	85 c0                	test   %eax,%eax
8010487b:	75 eb                	jne    80104868 <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
8010487d:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104882:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104885:	e8 1f f1 ff ff       	call   801039a9 <mycpu>
8010488a:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
8010488d:	8b 45 08             	mov    0x8(%ebp),%eax
80104890:	83 c0 0c             	add    $0xc,%eax
80104893:	83 ec 08             	sub    $0x8,%esp
80104896:	50                   	push   %eax
80104897:	8d 45 08             	lea    0x8(%ebp),%eax
8010489a:	50                   	push   %eax
8010489b:	e8 5b 00 00 00       	call   801048fb <getcallerpcs>
801048a0:	83 c4 10             	add    $0x10,%esp
}
801048a3:	90                   	nop
801048a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801048a7:	c9                   	leave  
801048a8:	c3                   	ret    

801048a9 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801048a9:	55                   	push   %ebp
801048aa:	89 e5                	mov    %esp,%ebp
801048ac:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801048af:	83 ec 0c             	sub    $0xc,%esp
801048b2:	ff 75 08             	push   0x8(%ebp)
801048b5:	e8 bc 00 00 00       	call   80104976 <holding>
801048ba:	83 c4 10             	add    $0x10,%esp
801048bd:	85 c0                	test   %eax,%eax
801048bf:	75 0d                	jne    801048ce <release+0x25>
    panic("release");
801048c1:	83 ec 0c             	sub    $0xc,%esp
801048c4:	68 b7 a4 10 80       	push   $0x8010a4b7
801048c9:	e8 db bc ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
801048ce:	8b 45 08             	mov    0x8(%ebp),%eax
801048d1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801048d8:	8b 45 08             	mov    0x8(%ebp),%eax
801048db:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801048e2:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801048e7:	8b 45 08             	mov    0x8(%ebp),%eax
801048ea:	8b 55 08             	mov    0x8(%ebp),%edx
801048ed:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
801048f3:	e8 fb 00 00 00       	call   801049f3 <popcli>
}
801048f8:	90                   	nop
801048f9:	c9                   	leave  
801048fa:	c3                   	ret    

801048fb <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801048fb:	55                   	push   %ebp
801048fc:	89 e5                	mov    %esp,%ebp
801048fe:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104901:	8b 45 08             	mov    0x8(%ebp),%eax
80104904:	83 e8 08             	sub    $0x8,%eax
80104907:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010490a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104911:	eb 38                	jmp    8010494b <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104913:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104917:	74 53                	je     8010496c <getcallerpcs+0x71>
80104919:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104920:	76 4a                	jbe    8010496c <getcallerpcs+0x71>
80104922:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104926:	74 44                	je     8010496c <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104928:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010492b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104932:	8b 45 0c             	mov    0xc(%ebp),%eax
80104935:	01 c2                	add    %eax,%edx
80104937:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010493a:	8b 40 04             	mov    0x4(%eax),%eax
8010493d:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
8010493f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104942:	8b 00                	mov    (%eax),%eax
80104944:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104947:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010494b:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010494f:	7e c2                	jle    80104913 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80104951:	eb 19                	jmp    8010496c <getcallerpcs+0x71>
    pcs[i] = 0;
80104953:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104956:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010495d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104960:	01 d0                	add    %edx,%eax
80104962:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104968:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010496c:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104970:	7e e1                	jle    80104953 <getcallerpcs+0x58>
}
80104972:	90                   	nop
80104973:	90                   	nop
80104974:	c9                   	leave  
80104975:	c3                   	ret    

80104976 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104976:	55                   	push   %ebp
80104977:	89 e5                	mov    %esp,%ebp
80104979:	53                   	push   %ebx
8010497a:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
8010497d:	8b 45 08             	mov    0x8(%ebp),%eax
80104980:	8b 00                	mov    (%eax),%eax
80104982:	85 c0                	test   %eax,%eax
80104984:	74 16                	je     8010499c <holding+0x26>
80104986:	8b 45 08             	mov    0x8(%ebp),%eax
80104989:	8b 58 08             	mov    0x8(%eax),%ebx
8010498c:	e8 18 f0 ff ff       	call   801039a9 <mycpu>
80104991:	39 c3                	cmp    %eax,%ebx
80104993:	75 07                	jne    8010499c <holding+0x26>
80104995:	b8 01 00 00 00       	mov    $0x1,%eax
8010499a:	eb 05                	jmp    801049a1 <holding+0x2b>
8010499c:	b8 00 00 00 00       	mov    $0x0,%eax
}
801049a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801049a4:	c9                   	leave  
801049a5:	c3                   	ret    

801049a6 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801049a6:	55                   	push   %ebp
801049a7:	89 e5                	mov    %esp,%ebp
801049a9:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
801049ac:	e8 30 fe ff ff       	call   801047e1 <readeflags>
801049b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
801049b4:	e8 38 fe ff ff       	call   801047f1 <cli>
  if(mycpu()->ncli == 0)
801049b9:	e8 eb ef ff ff       	call   801039a9 <mycpu>
801049be:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801049c4:	85 c0                	test   %eax,%eax
801049c6:	75 14                	jne    801049dc <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
801049c8:	e8 dc ef ff ff       	call   801039a9 <mycpu>
801049cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049d0:	81 e2 00 02 00 00    	and    $0x200,%edx
801049d6:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
801049dc:	e8 c8 ef ff ff       	call   801039a9 <mycpu>
801049e1:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801049e7:	83 c2 01             	add    $0x1,%edx
801049ea:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
801049f0:	90                   	nop
801049f1:	c9                   	leave  
801049f2:	c3                   	ret    

801049f3 <popcli>:

void
popcli(void)
{
801049f3:	55                   	push   %ebp
801049f4:	89 e5                	mov    %esp,%ebp
801049f6:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
801049f9:	e8 e3 fd ff ff       	call   801047e1 <readeflags>
801049fe:	25 00 02 00 00       	and    $0x200,%eax
80104a03:	85 c0                	test   %eax,%eax
80104a05:	74 0d                	je     80104a14 <popcli+0x21>
    panic("popcli - interruptible");
80104a07:	83 ec 0c             	sub    $0xc,%esp
80104a0a:	68 bf a4 10 80       	push   $0x8010a4bf
80104a0f:	e8 95 bb ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
80104a14:	e8 90 ef ff ff       	call   801039a9 <mycpu>
80104a19:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104a1f:	83 ea 01             	sub    $0x1,%edx
80104a22:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104a28:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104a2e:	85 c0                	test   %eax,%eax
80104a30:	79 0d                	jns    80104a3f <popcli+0x4c>
    panic("popcli");
80104a32:	83 ec 0c             	sub    $0xc,%esp
80104a35:	68 d6 a4 10 80       	push   $0x8010a4d6
80104a3a:	e8 6a bb ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104a3f:	e8 65 ef ff ff       	call   801039a9 <mycpu>
80104a44:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104a4a:	85 c0                	test   %eax,%eax
80104a4c:	75 14                	jne    80104a62 <popcli+0x6f>
80104a4e:	e8 56 ef ff ff       	call   801039a9 <mycpu>
80104a53:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104a59:	85 c0                	test   %eax,%eax
80104a5b:	74 05                	je     80104a62 <popcli+0x6f>
    sti();
80104a5d:	e8 96 fd ff ff       	call   801047f8 <sti>
}
80104a62:	90                   	nop
80104a63:	c9                   	leave  
80104a64:	c3                   	ret    

80104a65 <stosb>:
{
80104a65:	55                   	push   %ebp
80104a66:	89 e5                	mov    %esp,%ebp
80104a68:	57                   	push   %edi
80104a69:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104a6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104a6d:	8b 55 10             	mov    0x10(%ebp),%edx
80104a70:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a73:	89 cb                	mov    %ecx,%ebx
80104a75:	89 df                	mov    %ebx,%edi
80104a77:	89 d1                	mov    %edx,%ecx
80104a79:	fc                   	cld    
80104a7a:	f3 aa                	rep stos %al,%es:(%edi)
80104a7c:	89 ca                	mov    %ecx,%edx
80104a7e:	89 fb                	mov    %edi,%ebx
80104a80:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104a83:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104a86:	90                   	nop
80104a87:	5b                   	pop    %ebx
80104a88:	5f                   	pop    %edi
80104a89:	5d                   	pop    %ebp
80104a8a:	c3                   	ret    

80104a8b <stosl>:
{
80104a8b:	55                   	push   %ebp
80104a8c:	89 e5                	mov    %esp,%ebp
80104a8e:	57                   	push   %edi
80104a8f:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104a90:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104a93:	8b 55 10             	mov    0x10(%ebp),%edx
80104a96:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a99:	89 cb                	mov    %ecx,%ebx
80104a9b:	89 df                	mov    %ebx,%edi
80104a9d:	89 d1                	mov    %edx,%ecx
80104a9f:	fc                   	cld    
80104aa0:	f3 ab                	rep stos %eax,%es:(%edi)
80104aa2:	89 ca                	mov    %ecx,%edx
80104aa4:	89 fb                	mov    %edi,%ebx
80104aa6:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104aa9:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104aac:	90                   	nop
80104aad:	5b                   	pop    %ebx
80104aae:	5f                   	pop    %edi
80104aaf:	5d                   	pop    %ebp
80104ab0:	c3                   	ret    

80104ab1 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104ab1:	55                   	push   %ebp
80104ab2:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104ab4:	8b 45 08             	mov    0x8(%ebp),%eax
80104ab7:	83 e0 03             	and    $0x3,%eax
80104aba:	85 c0                	test   %eax,%eax
80104abc:	75 43                	jne    80104b01 <memset+0x50>
80104abe:	8b 45 10             	mov    0x10(%ebp),%eax
80104ac1:	83 e0 03             	and    $0x3,%eax
80104ac4:	85 c0                	test   %eax,%eax
80104ac6:	75 39                	jne    80104b01 <memset+0x50>
    c &= 0xFF;
80104ac8:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104acf:	8b 45 10             	mov    0x10(%ebp),%eax
80104ad2:	c1 e8 02             	shr    $0x2,%eax
80104ad5:	89 c2                	mov    %eax,%edx
80104ad7:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ada:	c1 e0 18             	shl    $0x18,%eax
80104add:	89 c1                	mov    %eax,%ecx
80104adf:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ae2:	c1 e0 10             	shl    $0x10,%eax
80104ae5:	09 c1                	or     %eax,%ecx
80104ae7:	8b 45 0c             	mov    0xc(%ebp),%eax
80104aea:	c1 e0 08             	shl    $0x8,%eax
80104aed:	09 c8                	or     %ecx,%eax
80104aef:	0b 45 0c             	or     0xc(%ebp),%eax
80104af2:	52                   	push   %edx
80104af3:	50                   	push   %eax
80104af4:	ff 75 08             	push   0x8(%ebp)
80104af7:	e8 8f ff ff ff       	call   80104a8b <stosl>
80104afc:	83 c4 0c             	add    $0xc,%esp
80104aff:	eb 12                	jmp    80104b13 <memset+0x62>
  } else
    stosb(dst, c, n);
80104b01:	8b 45 10             	mov    0x10(%ebp),%eax
80104b04:	50                   	push   %eax
80104b05:	ff 75 0c             	push   0xc(%ebp)
80104b08:	ff 75 08             	push   0x8(%ebp)
80104b0b:	e8 55 ff ff ff       	call   80104a65 <stosb>
80104b10:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104b13:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104b16:	c9                   	leave  
80104b17:	c3                   	ret    

80104b18 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104b18:	55                   	push   %ebp
80104b19:	89 e5                	mov    %esp,%ebp
80104b1b:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104b1e:	8b 45 08             	mov    0x8(%ebp),%eax
80104b21:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104b24:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b27:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104b2a:	eb 30                	jmp    80104b5c <memcmp+0x44>
    if(*s1 != *s2)
80104b2c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b2f:	0f b6 10             	movzbl (%eax),%edx
80104b32:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104b35:	0f b6 00             	movzbl (%eax),%eax
80104b38:	38 c2                	cmp    %al,%dl
80104b3a:	74 18                	je     80104b54 <memcmp+0x3c>
      return *s1 - *s2;
80104b3c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b3f:	0f b6 00             	movzbl (%eax),%eax
80104b42:	0f b6 d0             	movzbl %al,%edx
80104b45:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104b48:	0f b6 00             	movzbl (%eax),%eax
80104b4b:	0f b6 c8             	movzbl %al,%ecx
80104b4e:	89 d0                	mov    %edx,%eax
80104b50:	29 c8                	sub    %ecx,%eax
80104b52:	eb 1a                	jmp    80104b6e <memcmp+0x56>
    s1++, s2++;
80104b54:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104b58:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104b5c:	8b 45 10             	mov    0x10(%ebp),%eax
80104b5f:	8d 50 ff             	lea    -0x1(%eax),%edx
80104b62:	89 55 10             	mov    %edx,0x10(%ebp)
80104b65:	85 c0                	test   %eax,%eax
80104b67:	75 c3                	jne    80104b2c <memcmp+0x14>
  }

  return 0;
80104b69:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b6e:	c9                   	leave  
80104b6f:	c3                   	ret    

80104b70 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104b70:	55                   	push   %ebp
80104b71:	89 e5                	mov    %esp,%ebp
80104b73:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104b76:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b79:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104b7c:	8b 45 08             	mov    0x8(%ebp),%eax
80104b7f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104b82:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b85:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104b88:	73 54                	jae    80104bde <memmove+0x6e>
80104b8a:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104b8d:	8b 45 10             	mov    0x10(%ebp),%eax
80104b90:	01 d0                	add    %edx,%eax
80104b92:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104b95:	73 47                	jae    80104bde <memmove+0x6e>
    s += n;
80104b97:	8b 45 10             	mov    0x10(%ebp),%eax
80104b9a:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104b9d:	8b 45 10             	mov    0x10(%ebp),%eax
80104ba0:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104ba3:	eb 13                	jmp    80104bb8 <memmove+0x48>
      *--d = *--s;
80104ba5:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104ba9:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104bad:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bb0:	0f b6 10             	movzbl (%eax),%edx
80104bb3:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104bb6:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104bb8:	8b 45 10             	mov    0x10(%ebp),%eax
80104bbb:	8d 50 ff             	lea    -0x1(%eax),%edx
80104bbe:	89 55 10             	mov    %edx,0x10(%ebp)
80104bc1:	85 c0                	test   %eax,%eax
80104bc3:	75 e0                	jne    80104ba5 <memmove+0x35>
  if(s < d && s + n > d){
80104bc5:	eb 24                	jmp    80104beb <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104bc7:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104bca:	8d 42 01             	lea    0x1(%edx),%eax
80104bcd:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104bd0:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104bd3:	8d 48 01             	lea    0x1(%eax),%ecx
80104bd6:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104bd9:	0f b6 12             	movzbl (%edx),%edx
80104bdc:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104bde:	8b 45 10             	mov    0x10(%ebp),%eax
80104be1:	8d 50 ff             	lea    -0x1(%eax),%edx
80104be4:	89 55 10             	mov    %edx,0x10(%ebp)
80104be7:	85 c0                	test   %eax,%eax
80104be9:	75 dc                	jne    80104bc7 <memmove+0x57>

  return dst;
80104beb:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104bee:	c9                   	leave  
80104bef:	c3                   	ret    

80104bf0 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104bf0:	55                   	push   %ebp
80104bf1:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104bf3:	ff 75 10             	push   0x10(%ebp)
80104bf6:	ff 75 0c             	push   0xc(%ebp)
80104bf9:	ff 75 08             	push   0x8(%ebp)
80104bfc:	e8 6f ff ff ff       	call   80104b70 <memmove>
80104c01:	83 c4 0c             	add    $0xc,%esp
}
80104c04:	c9                   	leave  
80104c05:	c3                   	ret    

80104c06 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104c06:	55                   	push   %ebp
80104c07:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104c09:	eb 0c                	jmp    80104c17 <strncmp+0x11>
    n--, p++, q++;
80104c0b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104c0f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104c13:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104c17:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104c1b:	74 1a                	je     80104c37 <strncmp+0x31>
80104c1d:	8b 45 08             	mov    0x8(%ebp),%eax
80104c20:	0f b6 00             	movzbl (%eax),%eax
80104c23:	84 c0                	test   %al,%al
80104c25:	74 10                	je     80104c37 <strncmp+0x31>
80104c27:	8b 45 08             	mov    0x8(%ebp),%eax
80104c2a:	0f b6 10             	movzbl (%eax),%edx
80104c2d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c30:	0f b6 00             	movzbl (%eax),%eax
80104c33:	38 c2                	cmp    %al,%dl
80104c35:	74 d4                	je     80104c0b <strncmp+0x5>
  if(n == 0)
80104c37:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104c3b:	75 07                	jne    80104c44 <strncmp+0x3e>
    return 0;
80104c3d:	b8 00 00 00 00       	mov    $0x0,%eax
80104c42:	eb 16                	jmp    80104c5a <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80104c44:	8b 45 08             	mov    0x8(%ebp),%eax
80104c47:	0f b6 00             	movzbl (%eax),%eax
80104c4a:	0f b6 d0             	movzbl %al,%edx
80104c4d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c50:	0f b6 00             	movzbl (%eax),%eax
80104c53:	0f b6 c8             	movzbl %al,%ecx
80104c56:	89 d0                	mov    %edx,%eax
80104c58:	29 c8                	sub    %ecx,%eax
}
80104c5a:	5d                   	pop    %ebp
80104c5b:	c3                   	ret    

80104c5c <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104c5c:	55                   	push   %ebp
80104c5d:	89 e5                	mov    %esp,%ebp
80104c5f:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104c62:	8b 45 08             	mov    0x8(%ebp),%eax
80104c65:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104c68:	90                   	nop
80104c69:	8b 45 10             	mov    0x10(%ebp),%eax
80104c6c:	8d 50 ff             	lea    -0x1(%eax),%edx
80104c6f:	89 55 10             	mov    %edx,0x10(%ebp)
80104c72:	85 c0                	test   %eax,%eax
80104c74:	7e 2c                	jle    80104ca2 <strncpy+0x46>
80104c76:	8b 55 0c             	mov    0xc(%ebp),%edx
80104c79:	8d 42 01             	lea    0x1(%edx),%eax
80104c7c:	89 45 0c             	mov    %eax,0xc(%ebp)
80104c7f:	8b 45 08             	mov    0x8(%ebp),%eax
80104c82:	8d 48 01             	lea    0x1(%eax),%ecx
80104c85:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104c88:	0f b6 12             	movzbl (%edx),%edx
80104c8b:	88 10                	mov    %dl,(%eax)
80104c8d:	0f b6 00             	movzbl (%eax),%eax
80104c90:	84 c0                	test   %al,%al
80104c92:	75 d5                	jne    80104c69 <strncpy+0xd>
    ;
  while(n-- > 0)
80104c94:	eb 0c                	jmp    80104ca2 <strncpy+0x46>
    *s++ = 0;
80104c96:	8b 45 08             	mov    0x8(%ebp),%eax
80104c99:	8d 50 01             	lea    0x1(%eax),%edx
80104c9c:	89 55 08             	mov    %edx,0x8(%ebp)
80104c9f:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104ca2:	8b 45 10             	mov    0x10(%ebp),%eax
80104ca5:	8d 50 ff             	lea    -0x1(%eax),%edx
80104ca8:	89 55 10             	mov    %edx,0x10(%ebp)
80104cab:	85 c0                	test   %eax,%eax
80104cad:	7f e7                	jg     80104c96 <strncpy+0x3a>
  return os;
80104caf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104cb2:	c9                   	leave  
80104cb3:	c3                   	ret    

80104cb4 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104cb4:	55                   	push   %ebp
80104cb5:	89 e5                	mov    %esp,%ebp
80104cb7:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104cba:	8b 45 08             	mov    0x8(%ebp),%eax
80104cbd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104cc0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104cc4:	7f 05                	jg     80104ccb <safestrcpy+0x17>
    return os;
80104cc6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cc9:	eb 32                	jmp    80104cfd <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80104ccb:	90                   	nop
80104ccc:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104cd0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104cd4:	7e 1e                	jle    80104cf4 <safestrcpy+0x40>
80104cd6:	8b 55 0c             	mov    0xc(%ebp),%edx
80104cd9:	8d 42 01             	lea    0x1(%edx),%eax
80104cdc:	89 45 0c             	mov    %eax,0xc(%ebp)
80104cdf:	8b 45 08             	mov    0x8(%ebp),%eax
80104ce2:	8d 48 01             	lea    0x1(%eax),%ecx
80104ce5:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104ce8:	0f b6 12             	movzbl (%edx),%edx
80104ceb:	88 10                	mov    %dl,(%eax)
80104ced:	0f b6 00             	movzbl (%eax),%eax
80104cf0:	84 c0                	test   %al,%al
80104cf2:	75 d8                	jne    80104ccc <safestrcpy+0x18>
    ;
  *s = 0;
80104cf4:	8b 45 08             	mov    0x8(%ebp),%eax
80104cf7:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104cfa:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104cfd:	c9                   	leave  
80104cfe:	c3                   	ret    

80104cff <strlen>:

int
strlen(const char *s)
{
80104cff:	55                   	push   %ebp
80104d00:	89 e5                	mov    %esp,%ebp
80104d02:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104d05:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104d0c:	eb 04                	jmp    80104d12 <strlen+0x13>
80104d0e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104d12:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104d15:	8b 45 08             	mov    0x8(%ebp),%eax
80104d18:	01 d0                	add    %edx,%eax
80104d1a:	0f b6 00             	movzbl (%eax),%eax
80104d1d:	84 c0                	test   %al,%al
80104d1f:	75 ed                	jne    80104d0e <strlen+0xf>
    ;
  return n;
80104d21:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d24:	c9                   	leave  
80104d25:	c3                   	ret    

80104d26 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104d26:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104d2a:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104d2e:	55                   	push   %ebp
  pushl %ebx
80104d2f:	53                   	push   %ebx
  pushl %esi
80104d30:	56                   	push   %esi
  pushl %edi
80104d31:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104d32:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104d34:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104d36:	5f                   	pop    %edi
  popl %esi
80104d37:	5e                   	pop    %esi
  popl %ebx
80104d38:	5b                   	pop    %ebx
  popl %ebp
80104d39:	5d                   	pop    %ebp
  ret
80104d3a:	c3                   	ret    

80104d3b <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104d3b:	55                   	push   %ebp
80104d3c:	89 e5                	mov    %esp,%ebp
  //struct proc *curproc = myproc();

  /*if(addr >= curproc->sz || addr+4 > curproc->sz)
    return -1;*/
  *ip = *(int*)(addr);
80104d3e:	8b 45 08             	mov    0x8(%ebp),%eax
80104d41:	8b 10                	mov    (%eax),%edx
80104d43:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d46:	89 10                	mov    %edx,(%eax)
  return 0;
80104d48:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d4d:	5d                   	pop    %ebp
80104d4e:	c3                   	ret    

80104d4f <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104d4f:	55                   	push   %ebp
80104d50:	89 e5                	mov    %esp,%ebp
80104d52:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80104d55:	e8 c7 ec ff ff       	call   80103a21 <myproc>
80104d5a:	89 45 f0             	mov    %eax,-0x10(%ebp)

  /*if(addr >= curproc->sz)
    return -1;*/
  *pp = (char*)addr;
80104d5d:	8b 55 08             	mov    0x8(%ebp),%edx
80104d60:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d63:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80104d65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d68:	8b 00                	mov    (%eax),%eax
80104d6a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80104d6d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d70:	8b 00                	mov    (%eax),%eax
80104d72:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104d75:	eb 1a                	jmp    80104d91 <fetchstr+0x42>
    if(*s == 0)
80104d77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d7a:	0f b6 00             	movzbl (%eax),%eax
80104d7d:	84 c0                	test   %al,%al
80104d7f:	75 0c                	jne    80104d8d <fetchstr+0x3e>
      return s - *pp;
80104d81:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d84:	8b 10                	mov    (%eax),%edx
80104d86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d89:	29 d0                	sub    %edx,%eax
80104d8b:	eb 11                	jmp    80104d9e <fetchstr+0x4f>
  for(s = *pp; s < ep; s++){
80104d8d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104d91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d94:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104d97:	72 de                	jb     80104d77 <fetchstr+0x28>
  }
  return -1;
80104d99:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104d9e:	c9                   	leave  
80104d9f:	c3                   	ret    

80104da0 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104da0:	55                   	push   %ebp
80104da1:	89 e5                	mov    %esp,%ebp
80104da3:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104da6:	e8 76 ec ff ff       	call   80103a21 <myproc>
80104dab:	8b 40 18             	mov    0x18(%eax),%eax
80104dae:	8b 50 44             	mov    0x44(%eax),%edx
80104db1:	8b 45 08             	mov    0x8(%ebp),%eax
80104db4:	c1 e0 02             	shl    $0x2,%eax
80104db7:	01 d0                	add    %edx,%eax
80104db9:	83 c0 04             	add    $0x4,%eax
80104dbc:	83 ec 08             	sub    $0x8,%esp
80104dbf:	ff 75 0c             	push   0xc(%ebp)
80104dc2:	50                   	push   %eax
80104dc3:	e8 73 ff ff ff       	call   80104d3b <fetchint>
80104dc8:	83 c4 10             	add    $0x10,%esp
}
80104dcb:	c9                   	leave  
80104dcc:	c3                   	ret    

80104dcd <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104dcd:	55                   	push   %ebp
80104dce:	89 e5                	mov    %esp,%ebp
80104dd0:	83 ec 18             	sub    $0x18,%esp
  int i;
  //struct proc *curproc = myproc();
 
  if(argint(n, &i) < 0)
80104dd3:	83 ec 08             	sub    $0x8,%esp
80104dd6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104dd9:	50                   	push   %eax
80104dda:	ff 75 08             	push   0x8(%ebp)
80104ddd:	e8 be ff ff ff       	call   80104da0 <argint>
80104de2:	83 c4 10             	add    $0x10,%esp
80104de5:	85 c0                	test   %eax,%eax
80104de7:	79 07                	jns    80104df0 <argptr+0x23>
    return -1;
80104de9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dee:	eb 1c                	jmp    80104e0c <argptr+0x3f>
  if(size < 0 /*|| (uint)i >= curproc->sz || (uint)i+size > curproc->sz*/)
80104df0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104df4:	79 07                	jns    80104dfd <argptr+0x30>
    return -1;
80104df6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dfb:	eb 0f                	jmp    80104e0c <argptr+0x3f>
  *pp = (char*)i;
80104dfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e00:	89 c2                	mov    %eax,%edx
80104e02:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e05:	89 10                	mov    %edx,(%eax)
  return 0;
80104e07:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e0c:	c9                   	leave  
80104e0d:	c3                   	ret    

80104e0e <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104e0e:	55                   	push   %ebp
80104e0f:	89 e5                	mov    %esp,%ebp
80104e11:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104e14:	83 ec 08             	sub    $0x8,%esp
80104e17:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e1a:	50                   	push   %eax
80104e1b:	ff 75 08             	push   0x8(%ebp)
80104e1e:	e8 7d ff ff ff       	call   80104da0 <argint>
80104e23:	83 c4 10             	add    $0x10,%esp
80104e26:	85 c0                	test   %eax,%eax
80104e28:	79 07                	jns    80104e31 <argstr+0x23>
    return -1;
80104e2a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e2f:	eb 12                	jmp    80104e43 <argstr+0x35>
  return fetchstr(addr, pp);
80104e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e34:	83 ec 08             	sub    $0x8,%esp
80104e37:	ff 75 0c             	push   0xc(%ebp)
80104e3a:	50                   	push   %eax
80104e3b:	e8 0f ff ff ff       	call   80104d4f <fetchstr>
80104e40:	83 c4 10             	add    $0x10,%esp
}
80104e43:	c9                   	leave  
80104e44:	c3                   	ret    

80104e45 <syscall>:
[SYS_printpt] sys_printpt,
};

void
syscall(void)
{
80104e45:	55                   	push   %ebp
80104e46:	89 e5                	mov    %esp,%ebp
80104e48:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80104e4b:	e8 d1 eb ff ff       	call   80103a21 <myproc>
80104e50:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80104e53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e56:	8b 40 18             	mov    0x18(%eax),%eax
80104e59:	8b 40 1c             	mov    0x1c(%eax),%eax
80104e5c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104e5f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104e63:	7e 2f                	jle    80104e94 <syscall+0x4f>
80104e65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e68:	83 f8 16             	cmp    $0x16,%eax
80104e6b:	77 27                	ja     80104e94 <syscall+0x4f>
80104e6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e70:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104e77:	85 c0                	test   %eax,%eax
80104e79:	74 19                	je     80104e94 <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80104e7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e7e:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104e85:	ff d0                	call   *%eax
80104e87:	89 c2                	mov    %eax,%edx
80104e89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e8c:	8b 40 18             	mov    0x18(%eax),%eax
80104e8f:	89 50 1c             	mov    %edx,0x1c(%eax)
80104e92:	eb 2c                	jmp    80104ec0 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80104e94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e97:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104e9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e9d:	8b 40 10             	mov    0x10(%eax),%eax
80104ea0:	ff 75 f0             	push   -0x10(%ebp)
80104ea3:	52                   	push   %edx
80104ea4:	50                   	push   %eax
80104ea5:	68 dd a4 10 80       	push   $0x8010a4dd
80104eaa:	e8 45 b5 ff ff       	call   801003f4 <cprintf>
80104eaf:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80104eb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eb5:	8b 40 18             	mov    0x18(%eax),%eax
80104eb8:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
80104ebf:	90                   	nop
80104ec0:	90                   	nop
80104ec1:	c9                   	leave  
80104ec2:	c3                   	ret    

80104ec3 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104ec3:	55                   	push   %ebp
80104ec4:	89 e5                	mov    %esp,%ebp
80104ec6:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104ec9:	83 ec 08             	sub    $0x8,%esp
80104ecc:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104ecf:	50                   	push   %eax
80104ed0:	ff 75 08             	push   0x8(%ebp)
80104ed3:	e8 c8 fe ff ff       	call   80104da0 <argint>
80104ed8:	83 c4 10             	add    $0x10,%esp
80104edb:	85 c0                	test   %eax,%eax
80104edd:	79 07                	jns    80104ee6 <argfd+0x23>
    return -1;
80104edf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ee4:	eb 4f                	jmp    80104f35 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104ee6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ee9:	85 c0                	test   %eax,%eax
80104eeb:	78 20                	js     80104f0d <argfd+0x4a>
80104eed:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ef0:	83 f8 0f             	cmp    $0xf,%eax
80104ef3:	7f 18                	jg     80104f0d <argfd+0x4a>
80104ef5:	e8 27 eb ff ff       	call   80103a21 <myproc>
80104efa:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104efd:	83 c2 08             	add    $0x8,%edx
80104f00:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104f04:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104f07:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104f0b:	75 07                	jne    80104f14 <argfd+0x51>
    return -1;
80104f0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f12:	eb 21                	jmp    80104f35 <argfd+0x72>
  if(pfd)
80104f14:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104f18:	74 08                	je     80104f22 <argfd+0x5f>
    *pfd = fd;
80104f1a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f1d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f20:	89 10                	mov    %edx,(%eax)
  if(pf)
80104f22:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f26:	74 08                	je     80104f30 <argfd+0x6d>
    *pf = f;
80104f28:	8b 45 10             	mov    0x10(%ebp),%eax
80104f2b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f2e:	89 10                	mov    %edx,(%eax)
  return 0;
80104f30:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f35:	c9                   	leave  
80104f36:	c3                   	ret    

80104f37 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80104f37:	55                   	push   %ebp
80104f38:	89 e5                	mov    %esp,%ebp
80104f3a:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80104f3d:	e8 df ea ff ff       	call   80103a21 <myproc>
80104f42:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80104f45:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104f4c:	eb 2a                	jmp    80104f78 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80104f4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f51:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f54:	83 c2 08             	add    $0x8,%edx
80104f57:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104f5b:	85 c0                	test   %eax,%eax
80104f5d:	75 15                	jne    80104f74 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80104f5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f62:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f65:	8d 4a 08             	lea    0x8(%edx),%ecx
80104f68:	8b 55 08             	mov    0x8(%ebp),%edx
80104f6b:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80104f6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f72:	eb 0f                	jmp    80104f83 <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
80104f74:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104f78:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104f7c:	7e d0                	jle    80104f4e <fdalloc+0x17>
    }
  }
  return -1;
80104f7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f83:	c9                   	leave  
80104f84:	c3                   	ret    

80104f85 <sys_dup>:

int
sys_dup(void)
{
80104f85:	55                   	push   %ebp
80104f86:	89 e5                	mov    %esp,%ebp
80104f88:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80104f8b:	83 ec 04             	sub    $0x4,%esp
80104f8e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104f91:	50                   	push   %eax
80104f92:	6a 00                	push   $0x0
80104f94:	6a 00                	push   $0x0
80104f96:	e8 28 ff ff ff       	call   80104ec3 <argfd>
80104f9b:	83 c4 10             	add    $0x10,%esp
80104f9e:	85 c0                	test   %eax,%eax
80104fa0:	79 07                	jns    80104fa9 <sys_dup+0x24>
    return -1;
80104fa2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fa7:	eb 31                	jmp    80104fda <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80104fa9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fac:	83 ec 0c             	sub    $0xc,%esp
80104faf:	50                   	push   %eax
80104fb0:	e8 82 ff ff ff       	call   80104f37 <fdalloc>
80104fb5:	83 c4 10             	add    $0x10,%esp
80104fb8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104fbb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104fbf:	79 07                	jns    80104fc8 <sys_dup+0x43>
    return -1;
80104fc1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fc6:	eb 12                	jmp    80104fda <sys_dup+0x55>
  filedup(f);
80104fc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fcb:	83 ec 0c             	sub    $0xc,%esp
80104fce:	50                   	push   %eax
80104fcf:	e8 67 c0 ff ff       	call   8010103b <filedup>
80104fd4:	83 c4 10             	add    $0x10,%esp
  return fd;
80104fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104fda:	c9                   	leave  
80104fdb:	c3                   	ret    

80104fdc <sys_read>:

int
sys_read(void)
{
80104fdc:	55                   	push   %ebp
80104fdd:	89 e5                	mov    %esp,%ebp
80104fdf:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104fe2:	83 ec 04             	sub    $0x4,%esp
80104fe5:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104fe8:	50                   	push   %eax
80104fe9:	6a 00                	push   $0x0
80104feb:	6a 00                	push   $0x0
80104fed:	e8 d1 fe ff ff       	call   80104ec3 <argfd>
80104ff2:	83 c4 10             	add    $0x10,%esp
80104ff5:	85 c0                	test   %eax,%eax
80104ff7:	78 2e                	js     80105027 <sys_read+0x4b>
80104ff9:	83 ec 08             	sub    $0x8,%esp
80104ffc:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104fff:	50                   	push   %eax
80105000:	6a 02                	push   $0x2
80105002:	e8 99 fd ff ff       	call   80104da0 <argint>
80105007:	83 c4 10             	add    $0x10,%esp
8010500a:	85 c0                	test   %eax,%eax
8010500c:	78 19                	js     80105027 <sys_read+0x4b>
8010500e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105011:	83 ec 04             	sub    $0x4,%esp
80105014:	50                   	push   %eax
80105015:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105018:	50                   	push   %eax
80105019:	6a 01                	push   $0x1
8010501b:	e8 ad fd ff ff       	call   80104dcd <argptr>
80105020:	83 c4 10             	add    $0x10,%esp
80105023:	85 c0                	test   %eax,%eax
80105025:	79 07                	jns    8010502e <sys_read+0x52>
    return -1;
80105027:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010502c:	eb 17                	jmp    80105045 <sys_read+0x69>
  return fileread(f, p, n);
8010502e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105031:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105034:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105037:	83 ec 04             	sub    $0x4,%esp
8010503a:	51                   	push   %ecx
8010503b:	52                   	push   %edx
8010503c:	50                   	push   %eax
8010503d:	e8 89 c1 ff ff       	call   801011cb <fileread>
80105042:	83 c4 10             	add    $0x10,%esp
}
80105045:	c9                   	leave  
80105046:	c3                   	ret    

80105047 <sys_write>:

int
sys_write(void)
{
80105047:	55                   	push   %ebp
80105048:	89 e5                	mov    %esp,%ebp
8010504a:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010504d:	83 ec 04             	sub    $0x4,%esp
80105050:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105053:	50                   	push   %eax
80105054:	6a 00                	push   $0x0
80105056:	6a 00                	push   $0x0
80105058:	e8 66 fe ff ff       	call   80104ec3 <argfd>
8010505d:	83 c4 10             	add    $0x10,%esp
80105060:	85 c0                	test   %eax,%eax
80105062:	78 2e                	js     80105092 <sys_write+0x4b>
80105064:	83 ec 08             	sub    $0x8,%esp
80105067:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010506a:	50                   	push   %eax
8010506b:	6a 02                	push   $0x2
8010506d:	e8 2e fd ff ff       	call   80104da0 <argint>
80105072:	83 c4 10             	add    $0x10,%esp
80105075:	85 c0                	test   %eax,%eax
80105077:	78 19                	js     80105092 <sys_write+0x4b>
80105079:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010507c:	83 ec 04             	sub    $0x4,%esp
8010507f:	50                   	push   %eax
80105080:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105083:	50                   	push   %eax
80105084:	6a 01                	push   $0x1
80105086:	e8 42 fd ff ff       	call   80104dcd <argptr>
8010508b:	83 c4 10             	add    $0x10,%esp
8010508e:	85 c0                	test   %eax,%eax
80105090:	79 07                	jns    80105099 <sys_write+0x52>
    return -1;
80105092:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105097:	eb 17                	jmp    801050b0 <sys_write+0x69>
  return filewrite(f, p, n);
80105099:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010509c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010509f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050a2:	83 ec 04             	sub    $0x4,%esp
801050a5:	51                   	push   %ecx
801050a6:	52                   	push   %edx
801050a7:	50                   	push   %eax
801050a8:	e8 d6 c1 ff ff       	call   80101283 <filewrite>
801050ad:	83 c4 10             	add    $0x10,%esp
}
801050b0:	c9                   	leave  
801050b1:	c3                   	ret    

801050b2 <sys_close>:

int
sys_close(void)
{
801050b2:	55                   	push   %ebp
801050b3:	89 e5                	mov    %esp,%ebp
801050b5:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801050b8:	83 ec 04             	sub    $0x4,%esp
801050bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801050be:	50                   	push   %eax
801050bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
801050c2:	50                   	push   %eax
801050c3:	6a 00                	push   $0x0
801050c5:	e8 f9 fd ff ff       	call   80104ec3 <argfd>
801050ca:	83 c4 10             	add    $0x10,%esp
801050cd:	85 c0                	test   %eax,%eax
801050cf:	79 07                	jns    801050d8 <sys_close+0x26>
    return -1;
801050d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050d6:	eb 27                	jmp    801050ff <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
801050d8:	e8 44 e9 ff ff       	call   80103a21 <myproc>
801050dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801050e0:	83 c2 08             	add    $0x8,%edx
801050e3:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801050ea:	00 
  fileclose(f);
801050eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050ee:	83 ec 0c             	sub    $0xc,%esp
801050f1:	50                   	push   %eax
801050f2:	e8 95 bf ff ff       	call   8010108c <fileclose>
801050f7:	83 c4 10             	add    $0x10,%esp
  return 0;
801050fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
801050ff:	c9                   	leave  
80105100:	c3                   	ret    

80105101 <sys_fstat>:

int
sys_fstat(void)
{
80105101:	55                   	push   %ebp
80105102:	89 e5                	mov    %esp,%ebp
80105104:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105107:	83 ec 04             	sub    $0x4,%esp
8010510a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010510d:	50                   	push   %eax
8010510e:	6a 00                	push   $0x0
80105110:	6a 00                	push   $0x0
80105112:	e8 ac fd ff ff       	call   80104ec3 <argfd>
80105117:	83 c4 10             	add    $0x10,%esp
8010511a:	85 c0                	test   %eax,%eax
8010511c:	78 17                	js     80105135 <sys_fstat+0x34>
8010511e:	83 ec 04             	sub    $0x4,%esp
80105121:	6a 14                	push   $0x14
80105123:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105126:	50                   	push   %eax
80105127:	6a 01                	push   $0x1
80105129:	e8 9f fc ff ff       	call   80104dcd <argptr>
8010512e:	83 c4 10             	add    $0x10,%esp
80105131:	85 c0                	test   %eax,%eax
80105133:	79 07                	jns    8010513c <sys_fstat+0x3b>
    return -1;
80105135:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010513a:	eb 13                	jmp    8010514f <sys_fstat+0x4e>
  return filestat(f, st);
8010513c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010513f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105142:	83 ec 08             	sub    $0x8,%esp
80105145:	52                   	push   %edx
80105146:	50                   	push   %eax
80105147:	e8 28 c0 ff ff       	call   80101174 <filestat>
8010514c:	83 c4 10             	add    $0x10,%esp
}
8010514f:	c9                   	leave  
80105150:	c3                   	ret    

80105151 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105151:	55                   	push   %ebp
80105152:	89 e5                	mov    %esp,%ebp
80105154:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105157:	83 ec 08             	sub    $0x8,%esp
8010515a:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010515d:	50                   	push   %eax
8010515e:	6a 00                	push   $0x0
80105160:	e8 a9 fc ff ff       	call   80104e0e <argstr>
80105165:	83 c4 10             	add    $0x10,%esp
80105168:	85 c0                	test   %eax,%eax
8010516a:	78 15                	js     80105181 <sys_link+0x30>
8010516c:	83 ec 08             	sub    $0x8,%esp
8010516f:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105172:	50                   	push   %eax
80105173:	6a 01                	push   $0x1
80105175:	e8 94 fc ff ff       	call   80104e0e <argstr>
8010517a:	83 c4 10             	add    $0x10,%esp
8010517d:	85 c0                	test   %eax,%eax
8010517f:	79 0a                	jns    8010518b <sys_link+0x3a>
    return -1;
80105181:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105186:	e9 68 01 00 00       	jmp    801052f3 <sys_link+0x1a2>

  begin_op();
8010518b:	e8 9d de ff ff       	call   8010302d <begin_op>
  if((ip = namei(old)) == 0){
80105190:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105193:	83 ec 0c             	sub    $0xc,%esp
80105196:	50                   	push   %eax
80105197:	e8 72 d3 ff ff       	call   8010250e <namei>
8010519c:	83 c4 10             	add    $0x10,%esp
8010519f:	89 45 f4             	mov    %eax,-0xc(%ebp)
801051a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801051a6:	75 0f                	jne    801051b7 <sys_link+0x66>
    end_op();
801051a8:	e8 0c df ff ff       	call   801030b9 <end_op>
    return -1;
801051ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051b2:	e9 3c 01 00 00       	jmp    801052f3 <sys_link+0x1a2>
  }

  ilock(ip);
801051b7:	83 ec 0c             	sub    $0xc,%esp
801051ba:	ff 75 f4             	push   -0xc(%ebp)
801051bd:	e8 19 c8 ff ff       	call   801019db <ilock>
801051c2:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801051c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051c8:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801051cc:	66 83 f8 01          	cmp    $0x1,%ax
801051d0:	75 1d                	jne    801051ef <sys_link+0x9e>
    iunlockput(ip);
801051d2:	83 ec 0c             	sub    $0xc,%esp
801051d5:	ff 75 f4             	push   -0xc(%ebp)
801051d8:	e8 2f ca ff ff       	call   80101c0c <iunlockput>
801051dd:	83 c4 10             	add    $0x10,%esp
    end_op();
801051e0:	e8 d4 de ff ff       	call   801030b9 <end_op>
    return -1;
801051e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051ea:	e9 04 01 00 00       	jmp    801052f3 <sys_link+0x1a2>
  }

  ip->nlink++;
801051ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051f2:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801051f6:	83 c0 01             	add    $0x1,%eax
801051f9:	89 c2                	mov    %eax,%edx
801051fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051fe:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105202:	83 ec 0c             	sub    $0xc,%esp
80105205:	ff 75 f4             	push   -0xc(%ebp)
80105208:	e8 f1 c5 ff ff       	call   801017fe <iupdate>
8010520d:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105210:	83 ec 0c             	sub    $0xc,%esp
80105213:	ff 75 f4             	push   -0xc(%ebp)
80105216:	e8 d3 c8 ff ff       	call   80101aee <iunlock>
8010521b:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
8010521e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105221:	83 ec 08             	sub    $0x8,%esp
80105224:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105227:	52                   	push   %edx
80105228:	50                   	push   %eax
80105229:	e8 fc d2 ff ff       	call   8010252a <nameiparent>
8010522e:	83 c4 10             	add    $0x10,%esp
80105231:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105234:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105238:	74 71                	je     801052ab <sys_link+0x15a>
    goto bad;
  ilock(dp);
8010523a:	83 ec 0c             	sub    $0xc,%esp
8010523d:	ff 75 f0             	push   -0x10(%ebp)
80105240:	e8 96 c7 ff ff       	call   801019db <ilock>
80105245:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105248:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010524b:	8b 10                	mov    (%eax),%edx
8010524d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105250:	8b 00                	mov    (%eax),%eax
80105252:	39 c2                	cmp    %eax,%edx
80105254:	75 1d                	jne    80105273 <sys_link+0x122>
80105256:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105259:	8b 40 04             	mov    0x4(%eax),%eax
8010525c:	83 ec 04             	sub    $0x4,%esp
8010525f:	50                   	push   %eax
80105260:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105263:	50                   	push   %eax
80105264:	ff 75 f0             	push   -0x10(%ebp)
80105267:	e8 0b d0 ff ff       	call   80102277 <dirlink>
8010526c:	83 c4 10             	add    $0x10,%esp
8010526f:	85 c0                	test   %eax,%eax
80105271:	79 10                	jns    80105283 <sys_link+0x132>
    iunlockput(dp);
80105273:	83 ec 0c             	sub    $0xc,%esp
80105276:	ff 75 f0             	push   -0x10(%ebp)
80105279:	e8 8e c9 ff ff       	call   80101c0c <iunlockput>
8010527e:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105281:	eb 29                	jmp    801052ac <sys_link+0x15b>
  }
  iunlockput(dp);
80105283:	83 ec 0c             	sub    $0xc,%esp
80105286:	ff 75 f0             	push   -0x10(%ebp)
80105289:	e8 7e c9 ff ff       	call   80101c0c <iunlockput>
8010528e:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105291:	83 ec 0c             	sub    $0xc,%esp
80105294:	ff 75 f4             	push   -0xc(%ebp)
80105297:	e8 a0 c8 ff ff       	call   80101b3c <iput>
8010529c:	83 c4 10             	add    $0x10,%esp

  end_op();
8010529f:	e8 15 de ff ff       	call   801030b9 <end_op>

  return 0;
801052a4:	b8 00 00 00 00       	mov    $0x0,%eax
801052a9:	eb 48                	jmp    801052f3 <sys_link+0x1a2>
    goto bad;
801052ab:	90                   	nop

bad:
  ilock(ip);
801052ac:	83 ec 0c             	sub    $0xc,%esp
801052af:	ff 75 f4             	push   -0xc(%ebp)
801052b2:	e8 24 c7 ff ff       	call   801019db <ilock>
801052b7:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801052ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052bd:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801052c1:	83 e8 01             	sub    $0x1,%eax
801052c4:	89 c2                	mov    %eax,%edx
801052c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052c9:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801052cd:	83 ec 0c             	sub    $0xc,%esp
801052d0:	ff 75 f4             	push   -0xc(%ebp)
801052d3:	e8 26 c5 ff ff       	call   801017fe <iupdate>
801052d8:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801052db:	83 ec 0c             	sub    $0xc,%esp
801052de:	ff 75 f4             	push   -0xc(%ebp)
801052e1:	e8 26 c9 ff ff       	call   80101c0c <iunlockput>
801052e6:	83 c4 10             	add    $0x10,%esp
  end_op();
801052e9:	e8 cb dd ff ff       	call   801030b9 <end_op>
  return -1;
801052ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801052f3:	c9                   	leave  
801052f4:	c3                   	ret    

801052f5 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801052f5:	55                   	push   %ebp
801052f6:	89 e5                	mov    %esp,%ebp
801052f8:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801052fb:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105302:	eb 40                	jmp    80105344 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105304:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105307:	6a 10                	push   $0x10
80105309:	50                   	push   %eax
8010530a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010530d:	50                   	push   %eax
8010530e:	ff 75 08             	push   0x8(%ebp)
80105311:	e8 b1 cb ff ff       	call   80101ec7 <readi>
80105316:	83 c4 10             	add    $0x10,%esp
80105319:	83 f8 10             	cmp    $0x10,%eax
8010531c:	74 0d                	je     8010532b <isdirempty+0x36>
      panic("isdirempty: readi");
8010531e:	83 ec 0c             	sub    $0xc,%esp
80105321:	68 f9 a4 10 80       	push   $0x8010a4f9
80105326:	e8 7e b2 ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
8010532b:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
8010532f:	66 85 c0             	test   %ax,%ax
80105332:	74 07                	je     8010533b <isdirempty+0x46>
      return 0;
80105334:	b8 00 00 00 00       	mov    $0x0,%eax
80105339:	eb 1b                	jmp    80105356 <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010533b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010533e:	83 c0 10             	add    $0x10,%eax
80105341:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105344:	8b 45 08             	mov    0x8(%ebp),%eax
80105347:	8b 50 58             	mov    0x58(%eax),%edx
8010534a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010534d:	39 c2                	cmp    %eax,%edx
8010534f:	77 b3                	ja     80105304 <isdirempty+0xf>
  }
  return 1;
80105351:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105356:	c9                   	leave  
80105357:	c3                   	ret    

80105358 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105358:	55                   	push   %ebp
80105359:	89 e5                	mov    %esp,%ebp
8010535b:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
8010535e:	83 ec 08             	sub    $0x8,%esp
80105361:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105364:	50                   	push   %eax
80105365:	6a 00                	push   $0x0
80105367:	e8 a2 fa ff ff       	call   80104e0e <argstr>
8010536c:	83 c4 10             	add    $0x10,%esp
8010536f:	85 c0                	test   %eax,%eax
80105371:	79 0a                	jns    8010537d <sys_unlink+0x25>
    return -1;
80105373:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105378:	e9 bf 01 00 00       	jmp    8010553c <sys_unlink+0x1e4>

  begin_op();
8010537d:	e8 ab dc ff ff       	call   8010302d <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105382:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105385:	83 ec 08             	sub    $0x8,%esp
80105388:	8d 55 d2             	lea    -0x2e(%ebp),%edx
8010538b:	52                   	push   %edx
8010538c:	50                   	push   %eax
8010538d:	e8 98 d1 ff ff       	call   8010252a <nameiparent>
80105392:	83 c4 10             	add    $0x10,%esp
80105395:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105398:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010539c:	75 0f                	jne    801053ad <sys_unlink+0x55>
    end_op();
8010539e:	e8 16 dd ff ff       	call   801030b9 <end_op>
    return -1;
801053a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053a8:	e9 8f 01 00 00       	jmp    8010553c <sys_unlink+0x1e4>
  }

  ilock(dp);
801053ad:	83 ec 0c             	sub    $0xc,%esp
801053b0:	ff 75 f4             	push   -0xc(%ebp)
801053b3:	e8 23 c6 ff ff       	call   801019db <ilock>
801053b8:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801053bb:	83 ec 08             	sub    $0x8,%esp
801053be:	68 0b a5 10 80       	push   $0x8010a50b
801053c3:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801053c6:	50                   	push   %eax
801053c7:	e8 d6 cd ff ff       	call   801021a2 <namecmp>
801053cc:	83 c4 10             	add    $0x10,%esp
801053cf:	85 c0                	test   %eax,%eax
801053d1:	0f 84 49 01 00 00    	je     80105520 <sys_unlink+0x1c8>
801053d7:	83 ec 08             	sub    $0x8,%esp
801053da:	68 0d a5 10 80       	push   $0x8010a50d
801053df:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801053e2:	50                   	push   %eax
801053e3:	e8 ba cd ff ff       	call   801021a2 <namecmp>
801053e8:	83 c4 10             	add    $0x10,%esp
801053eb:	85 c0                	test   %eax,%eax
801053ed:	0f 84 2d 01 00 00    	je     80105520 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801053f3:	83 ec 04             	sub    $0x4,%esp
801053f6:	8d 45 c8             	lea    -0x38(%ebp),%eax
801053f9:	50                   	push   %eax
801053fa:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801053fd:	50                   	push   %eax
801053fe:	ff 75 f4             	push   -0xc(%ebp)
80105401:	e8 b7 cd ff ff       	call   801021bd <dirlookup>
80105406:	83 c4 10             	add    $0x10,%esp
80105409:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010540c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105410:	0f 84 0d 01 00 00    	je     80105523 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105416:	83 ec 0c             	sub    $0xc,%esp
80105419:	ff 75 f0             	push   -0x10(%ebp)
8010541c:	e8 ba c5 ff ff       	call   801019db <ilock>
80105421:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105424:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105427:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010542b:	66 85 c0             	test   %ax,%ax
8010542e:	7f 0d                	jg     8010543d <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105430:	83 ec 0c             	sub    $0xc,%esp
80105433:	68 10 a5 10 80       	push   $0x8010a510
80105438:	e8 6c b1 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010543d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105440:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105444:	66 83 f8 01          	cmp    $0x1,%ax
80105448:	75 25                	jne    8010546f <sys_unlink+0x117>
8010544a:	83 ec 0c             	sub    $0xc,%esp
8010544d:	ff 75 f0             	push   -0x10(%ebp)
80105450:	e8 a0 fe ff ff       	call   801052f5 <isdirempty>
80105455:	83 c4 10             	add    $0x10,%esp
80105458:	85 c0                	test   %eax,%eax
8010545a:	75 13                	jne    8010546f <sys_unlink+0x117>
    iunlockput(ip);
8010545c:	83 ec 0c             	sub    $0xc,%esp
8010545f:	ff 75 f0             	push   -0x10(%ebp)
80105462:	e8 a5 c7 ff ff       	call   80101c0c <iunlockput>
80105467:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010546a:	e9 b5 00 00 00       	jmp    80105524 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
8010546f:	83 ec 04             	sub    $0x4,%esp
80105472:	6a 10                	push   $0x10
80105474:	6a 00                	push   $0x0
80105476:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105479:	50                   	push   %eax
8010547a:	e8 32 f6 ff ff       	call   80104ab1 <memset>
8010547f:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105482:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105485:	6a 10                	push   $0x10
80105487:	50                   	push   %eax
80105488:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010548b:	50                   	push   %eax
8010548c:	ff 75 f4             	push   -0xc(%ebp)
8010548f:	e8 88 cb ff ff       	call   8010201c <writei>
80105494:	83 c4 10             	add    $0x10,%esp
80105497:	83 f8 10             	cmp    $0x10,%eax
8010549a:	74 0d                	je     801054a9 <sys_unlink+0x151>
    panic("unlink: writei");
8010549c:	83 ec 0c             	sub    $0xc,%esp
8010549f:	68 22 a5 10 80       	push   $0x8010a522
801054a4:	e8 00 b1 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
801054a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054ac:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801054b0:	66 83 f8 01          	cmp    $0x1,%ax
801054b4:	75 21                	jne    801054d7 <sys_unlink+0x17f>
    dp->nlink--;
801054b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054b9:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801054bd:	83 e8 01             	sub    $0x1,%eax
801054c0:	89 c2                	mov    %eax,%edx
801054c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054c5:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801054c9:	83 ec 0c             	sub    $0xc,%esp
801054cc:	ff 75 f4             	push   -0xc(%ebp)
801054cf:	e8 2a c3 ff ff       	call   801017fe <iupdate>
801054d4:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
801054d7:	83 ec 0c             	sub    $0xc,%esp
801054da:	ff 75 f4             	push   -0xc(%ebp)
801054dd:	e8 2a c7 ff ff       	call   80101c0c <iunlockput>
801054e2:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
801054e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054e8:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801054ec:	83 e8 01             	sub    $0x1,%eax
801054ef:	89 c2                	mov    %eax,%edx
801054f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054f4:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801054f8:	83 ec 0c             	sub    $0xc,%esp
801054fb:	ff 75 f0             	push   -0x10(%ebp)
801054fe:	e8 fb c2 ff ff       	call   801017fe <iupdate>
80105503:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105506:	83 ec 0c             	sub    $0xc,%esp
80105509:	ff 75 f0             	push   -0x10(%ebp)
8010550c:	e8 fb c6 ff ff       	call   80101c0c <iunlockput>
80105511:	83 c4 10             	add    $0x10,%esp

  end_op();
80105514:	e8 a0 db ff ff       	call   801030b9 <end_op>

  return 0;
80105519:	b8 00 00 00 00       	mov    $0x0,%eax
8010551e:	eb 1c                	jmp    8010553c <sys_unlink+0x1e4>
    goto bad;
80105520:	90                   	nop
80105521:	eb 01                	jmp    80105524 <sys_unlink+0x1cc>
    goto bad;
80105523:	90                   	nop

bad:
  iunlockput(dp);
80105524:	83 ec 0c             	sub    $0xc,%esp
80105527:	ff 75 f4             	push   -0xc(%ebp)
8010552a:	e8 dd c6 ff ff       	call   80101c0c <iunlockput>
8010552f:	83 c4 10             	add    $0x10,%esp
  end_op();
80105532:	e8 82 db ff ff       	call   801030b9 <end_op>
  return -1;
80105537:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010553c:	c9                   	leave  
8010553d:	c3                   	ret    

8010553e <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010553e:	55                   	push   %ebp
8010553f:	89 e5                	mov    %esp,%ebp
80105541:	83 ec 38             	sub    $0x38,%esp
80105544:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105547:	8b 55 10             	mov    0x10(%ebp),%edx
8010554a:	8b 45 14             	mov    0x14(%ebp),%eax
8010554d:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105551:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105555:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105559:	83 ec 08             	sub    $0x8,%esp
8010555c:	8d 45 de             	lea    -0x22(%ebp),%eax
8010555f:	50                   	push   %eax
80105560:	ff 75 08             	push   0x8(%ebp)
80105563:	e8 c2 cf ff ff       	call   8010252a <nameiparent>
80105568:	83 c4 10             	add    $0x10,%esp
8010556b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010556e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105572:	75 0a                	jne    8010557e <create+0x40>
    return 0;
80105574:	b8 00 00 00 00       	mov    $0x0,%eax
80105579:	e9 90 01 00 00       	jmp    8010570e <create+0x1d0>
  ilock(dp);
8010557e:	83 ec 0c             	sub    $0xc,%esp
80105581:	ff 75 f4             	push   -0xc(%ebp)
80105584:	e8 52 c4 ff ff       	call   801019db <ilock>
80105589:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
8010558c:	83 ec 04             	sub    $0x4,%esp
8010558f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105592:	50                   	push   %eax
80105593:	8d 45 de             	lea    -0x22(%ebp),%eax
80105596:	50                   	push   %eax
80105597:	ff 75 f4             	push   -0xc(%ebp)
8010559a:	e8 1e cc ff ff       	call   801021bd <dirlookup>
8010559f:	83 c4 10             	add    $0x10,%esp
801055a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801055a5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801055a9:	74 50                	je     801055fb <create+0xbd>
    iunlockput(dp);
801055ab:	83 ec 0c             	sub    $0xc,%esp
801055ae:	ff 75 f4             	push   -0xc(%ebp)
801055b1:	e8 56 c6 ff ff       	call   80101c0c <iunlockput>
801055b6:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801055b9:	83 ec 0c             	sub    $0xc,%esp
801055bc:	ff 75 f0             	push   -0x10(%ebp)
801055bf:	e8 17 c4 ff ff       	call   801019db <ilock>
801055c4:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
801055c7:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801055cc:	75 15                	jne    801055e3 <create+0xa5>
801055ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055d1:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801055d5:	66 83 f8 02          	cmp    $0x2,%ax
801055d9:	75 08                	jne    801055e3 <create+0xa5>
      return ip;
801055db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055de:	e9 2b 01 00 00       	jmp    8010570e <create+0x1d0>
    iunlockput(ip);
801055e3:	83 ec 0c             	sub    $0xc,%esp
801055e6:	ff 75 f0             	push   -0x10(%ebp)
801055e9:	e8 1e c6 ff ff       	call   80101c0c <iunlockput>
801055ee:	83 c4 10             	add    $0x10,%esp
    return 0;
801055f1:	b8 00 00 00 00       	mov    $0x0,%eax
801055f6:	e9 13 01 00 00       	jmp    8010570e <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801055fb:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801055ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105602:	8b 00                	mov    (%eax),%eax
80105604:	83 ec 08             	sub    $0x8,%esp
80105607:	52                   	push   %edx
80105608:	50                   	push   %eax
80105609:	e8 19 c1 ff ff       	call   80101727 <ialloc>
8010560e:	83 c4 10             	add    $0x10,%esp
80105611:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105614:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105618:	75 0d                	jne    80105627 <create+0xe9>
    panic("create: ialloc");
8010561a:	83 ec 0c             	sub    $0xc,%esp
8010561d:	68 31 a5 10 80       	push   $0x8010a531
80105622:	e8 82 af ff ff       	call   801005a9 <panic>

  ilock(ip);
80105627:	83 ec 0c             	sub    $0xc,%esp
8010562a:	ff 75 f0             	push   -0x10(%ebp)
8010562d:	e8 a9 c3 ff ff       	call   801019db <ilock>
80105632:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105635:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105638:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
8010563c:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105640:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105643:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105647:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
8010564b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010564e:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105654:	83 ec 0c             	sub    $0xc,%esp
80105657:	ff 75 f0             	push   -0x10(%ebp)
8010565a:	e8 9f c1 ff ff       	call   801017fe <iupdate>
8010565f:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105662:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105667:	75 6a                	jne    801056d3 <create+0x195>
    dp->nlink++;  // for ".."
80105669:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010566c:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105670:	83 c0 01             	add    $0x1,%eax
80105673:	89 c2                	mov    %eax,%edx
80105675:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105678:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
8010567c:	83 ec 0c             	sub    $0xc,%esp
8010567f:	ff 75 f4             	push   -0xc(%ebp)
80105682:	e8 77 c1 ff ff       	call   801017fe <iupdate>
80105687:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010568a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010568d:	8b 40 04             	mov    0x4(%eax),%eax
80105690:	83 ec 04             	sub    $0x4,%esp
80105693:	50                   	push   %eax
80105694:	68 0b a5 10 80       	push   $0x8010a50b
80105699:	ff 75 f0             	push   -0x10(%ebp)
8010569c:	e8 d6 cb ff ff       	call   80102277 <dirlink>
801056a1:	83 c4 10             	add    $0x10,%esp
801056a4:	85 c0                	test   %eax,%eax
801056a6:	78 1e                	js     801056c6 <create+0x188>
801056a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056ab:	8b 40 04             	mov    0x4(%eax),%eax
801056ae:	83 ec 04             	sub    $0x4,%esp
801056b1:	50                   	push   %eax
801056b2:	68 0d a5 10 80       	push   $0x8010a50d
801056b7:	ff 75 f0             	push   -0x10(%ebp)
801056ba:	e8 b8 cb ff ff       	call   80102277 <dirlink>
801056bf:	83 c4 10             	add    $0x10,%esp
801056c2:	85 c0                	test   %eax,%eax
801056c4:	79 0d                	jns    801056d3 <create+0x195>
      panic("create dots");
801056c6:	83 ec 0c             	sub    $0xc,%esp
801056c9:	68 40 a5 10 80       	push   $0x8010a540
801056ce:	e8 d6 ae ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801056d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056d6:	8b 40 04             	mov    0x4(%eax),%eax
801056d9:	83 ec 04             	sub    $0x4,%esp
801056dc:	50                   	push   %eax
801056dd:	8d 45 de             	lea    -0x22(%ebp),%eax
801056e0:	50                   	push   %eax
801056e1:	ff 75 f4             	push   -0xc(%ebp)
801056e4:	e8 8e cb ff ff       	call   80102277 <dirlink>
801056e9:	83 c4 10             	add    $0x10,%esp
801056ec:	85 c0                	test   %eax,%eax
801056ee:	79 0d                	jns    801056fd <create+0x1bf>
    panic("create: dirlink");
801056f0:	83 ec 0c             	sub    $0xc,%esp
801056f3:	68 4c a5 10 80       	push   $0x8010a54c
801056f8:	e8 ac ae ff ff       	call   801005a9 <panic>

  iunlockput(dp);
801056fd:	83 ec 0c             	sub    $0xc,%esp
80105700:	ff 75 f4             	push   -0xc(%ebp)
80105703:	e8 04 c5 ff ff       	call   80101c0c <iunlockput>
80105708:	83 c4 10             	add    $0x10,%esp

  return ip;
8010570b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010570e:	c9                   	leave  
8010570f:	c3                   	ret    

80105710 <sys_open>:

int
sys_open(void)
{
80105710:	55                   	push   %ebp
80105711:	89 e5                	mov    %esp,%ebp
80105713:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105716:	83 ec 08             	sub    $0x8,%esp
80105719:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010571c:	50                   	push   %eax
8010571d:	6a 00                	push   $0x0
8010571f:	e8 ea f6 ff ff       	call   80104e0e <argstr>
80105724:	83 c4 10             	add    $0x10,%esp
80105727:	85 c0                	test   %eax,%eax
80105729:	78 15                	js     80105740 <sys_open+0x30>
8010572b:	83 ec 08             	sub    $0x8,%esp
8010572e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105731:	50                   	push   %eax
80105732:	6a 01                	push   $0x1
80105734:	e8 67 f6 ff ff       	call   80104da0 <argint>
80105739:	83 c4 10             	add    $0x10,%esp
8010573c:	85 c0                	test   %eax,%eax
8010573e:	79 0a                	jns    8010574a <sys_open+0x3a>
    return -1;
80105740:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105745:	e9 61 01 00 00       	jmp    801058ab <sys_open+0x19b>

  begin_op();
8010574a:	e8 de d8 ff ff       	call   8010302d <begin_op>
  if(omode & O_CREATE){
8010574f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105752:	25 00 02 00 00       	and    $0x200,%eax
80105757:	85 c0                	test   %eax,%eax
80105759:	74 2a                	je     80105785 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
8010575b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010575e:	6a 00                	push   $0x0
80105760:	6a 00                	push   $0x0
80105762:	6a 02                	push   $0x2
80105764:	50                   	push   %eax
80105765:	e8 d4 fd ff ff       	call   8010553e <create>
8010576a:	83 c4 10             	add    $0x10,%esp
8010576d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105770:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105774:	75 75                	jne    801057eb <sys_open+0xdb>
      end_op();
80105776:	e8 3e d9 ff ff       	call   801030b9 <end_op>
      return -1;
8010577b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105780:	e9 26 01 00 00       	jmp    801058ab <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105785:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105788:	83 ec 0c             	sub    $0xc,%esp
8010578b:	50                   	push   %eax
8010578c:	e8 7d cd ff ff       	call   8010250e <namei>
80105791:	83 c4 10             	add    $0x10,%esp
80105794:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105797:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010579b:	75 0f                	jne    801057ac <sys_open+0x9c>
      end_op();
8010579d:	e8 17 d9 ff ff       	call   801030b9 <end_op>
      return -1;
801057a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057a7:	e9 ff 00 00 00       	jmp    801058ab <sys_open+0x19b>
    }
    ilock(ip);
801057ac:	83 ec 0c             	sub    $0xc,%esp
801057af:	ff 75 f4             	push   -0xc(%ebp)
801057b2:	e8 24 c2 ff ff       	call   801019db <ilock>
801057b7:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
801057ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057bd:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801057c1:	66 83 f8 01          	cmp    $0x1,%ax
801057c5:	75 24                	jne    801057eb <sys_open+0xdb>
801057c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801057ca:	85 c0                	test   %eax,%eax
801057cc:	74 1d                	je     801057eb <sys_open+0xdb>
      iunlockput(ip);
801057ce:	83 ec 0c             	sub    $0xc,%esp
801057d1:	ff 75 f4             	push   -0xc(%ebp)
801057d4:	e8 33 c4 ff ff       	call   80101c0c <iunlockput>
801057d9:	83 c4 10             	add    $0x10,%esp
      end_op();
801057dc:	e8 d8 d8 ff ff       	call   801030b9 <end_op>
      return -1;
801057e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057e6:	e9 c0 00 00 00       	jmp    801058ab <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801057eb:	e8 de b7 ff ff       	call   80100fce <filealloc>
801057f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801057f3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801057f7:	74 17                	je     80105810 <sys_open+0x100>
801057f9:	83 ec 0c             	sub    $0xc,%esp
801057fc:	ff 75 f0             	push   -0x10(%ebp)
801057ff:	e8 33 f7 ff ff       	call   80104f37 <fdalloc>
80105804:	83 c4 10             	add    $0x10,%esp
80105807:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010580a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010580e:	79 2e                	jns    8010583e <sys_open+0x12e>
    if(f)
80105810:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105814:	74 0e                	je     80105824 <sys_open+0x114>
      fileclose(f);
80105816:	83 ec 0c             	sub    $0xc,%esp
80105819:	ff 75 f0             	push   -0x10(%ebp)
8010581c:	e8 6b b8 ff ff       	call   8010108c <fileclose>
80105821:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105824:	83 ec 0c             	sub    $0xc,%esp
80105827:	ff 75 f4             	push   -0xc(%ebp)
8010582a:	e8 dd c3 ff ff       	call   80101c0c <iunlockput>
8010582f:	83 c4 10             	add    $0x10,%esp
    end_op();
80105832:	e8 82 d8 ff ff       	call   801030b9 <end_op>
    return -1;
80105837:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010583c:	eb 6d                	jmp    801058ab <sys_open+0x19b>
  }
  iunlock(ip);
8010583e:	83 ec 0c             	sub    $0xc,%esp
80105841:	ff 75 f4             	push   -0xc(%ebp)
80105844:	e8 a5 c2 ff ff       	call   80101aee <iunlock>
80105849:	83 c4 10             	add    $0x10,%esp
  end_op();
8010584c:	e8 68 d8 ff ff       	call   801030b9 <end_op>

  f->type = FD_INODE;
80105851:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105854:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
8010585a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010585d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105860:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105863:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105866:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
8010586d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105870:	83 e0 01             	and    $0x1,%eax
80105873:	85 c0                	test   %eax,%eax
80105875:	0f 94 c0             	sete   %al
80105878:	89 c2                	mov    %eax,%edx
8010587a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010587d:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105880:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105883:	83 e0 01             	and    $0x1,%eax
80105886:	85 c0                	test   %eax,%eax
80105888:	75 0a                	jne    80105894 <sys_open+0x184>
8010588a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010588d:	83 e0 02             	and    $0x2,%eax
80105890:	85 c0                	test   %eax,%eax
80105892:	74 07                	je     8010589b <sys_open+0x18b>
80105894:	b8 01 00 00 00       	mov    $0x1,%eax
80105899:	eb 05                	jmp    801058a0 <sys_open+0x190>
8010589b:	b8 00 00 00 00       	mov    $0x0,%eax
801058a0:	89 c2                	mov    %eax,%edx
801058a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058a5:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801058a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801058ab:	c9                   	leave  
801058ac:	c3                   	ret    

801058ad <sys_mkdir>:

int
sys_mkdir(void)
{
801058ad:	55                   	push   %ebp
801058ae:	89 e5                	mov    %esp,%ebp
801058b0:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801058b3:	e8 75 d7 ff ff       	call   8010302d <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801058b8:	83 ec 08             	sub    $0x8,%esp
801058bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058be:	50                   	push   %eax
801058bf:	6a 00                	push   $0x0
801058c1:	e8 48 f5 ff ff       	call   80104e0e <argstr>
801058c6:	83 c4 10             	add    $0x10,%esp
801058c9:	85 c0                	test   %eax,%eax
801058cb:	78 1b                	js     801058e8 <sys_mkdir+0x3b>
801058cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058d0:	6a 00                	push   $0x0
801058d2:	6a 00                	push   $0x0
801058d4:	6a 01                	push   $0x1
801058d6:	50                   	push   %eax
801058d7:	e8 62 fc ff ff       	call   8010553e <create>
801058dc:	83 c4 10             	add    $0x10,%esp
801058df:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058e2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058e6:	75 0c                	jne    801058f4 <sys_mkdir+0x47>
    end_op();
801058e8:	e8 cc d7 ff ff       	call   801030b9 <end_op>
    return -1;
801058ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058f2:	eb 18                	jmp    8010590c <sys_mkdir+0x5f>
  }
  iunlockput(ip);
801058f4:	83 ec 0c             	sub    $0xc,%esp
801058f7:	ff 75 f4             	push   -0xc(%ebp)
801058fa:	e8 0d c3 ff ff       	call   80101c0c <iunlockput>
801058ff:	83 c4 10             	add    $0x10,%esp
  end_op();
80105902:	e8 b2 d7 ff ff       	call   801030b9 <end_op>
  return 0;
80105907:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010590c:	c9                   	leave  
8010590d:	c3                   	ret    

8010590e <sys_mknod>:

int
sys_mknod(void)
{
8010590e:	55                   	push   %ebp
8010590f:	89 e5                	mov    %esp,%ebp
80105911:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105914:	e8 14 d7 ff ff       	call   8010302d <begin_op>
  if((argstr(0, &path)) < 0 ||
80105919:	83 ec 08             	sub    $0x8,%esp
8010591c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010591f:	50                   	push   %eax
80105920:	6a 00                	push   $0x0
80105922:	e8 e7 f4 ff ff       	call   80104e0e <argstr>
80105927:	83 c4 10             	add    $0x10,%esp
8010592a:	85 c0                	test   %eax,%eax
8010592c:	78 4f                	js     8010597d <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
8010592e:	83 ec 08             	sub    $0x8,%esp
80105931:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105934:	50                   	push   %eax
80105935:	6a 01                	push   $0x1
80105937:	e8 64 f4 ff ff       	call   80104da0 <argint>
8010593c:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
8010593f:	85 c0                	test   %eax,%eax
80105941:	78 3a                	js     8010597d <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
80105943:	83 ec 08             	sub    $0x8,%esp
80105946:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105949:	50                   	push   %eax
8010594a:	6a 02                	push   $0x2
8010594c:	e8 4f f4 ff ff       	call   80104da0 <argint>
80105951:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105954:	85 c0                	test   %eax,%eax
80105956:	78 25                	js     8010597d <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105958:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010595b:	0f bf c8             	movswl %ax,%ecx
8010595e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105961:	0f bf d0             	movswl %ax,%edx
80105964:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105967:	51                   	push   %ecx
80105968:	52                   	push   %edx
80105969:	6a 03                	push   $0x3
8010596b:	50                   	push   %eax
8010596c:	e8 cd fb ff ff       	call   8010553e <create>
80105971:	83 c4 10             	add    $0x10,%esp
80105974:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105977:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010597b:	75 0c                	jne    80105989 <sys_mknod+0x7b>
    end_op();
8010597d:	e8 37 d7 ff ff       	call   801030b9 <end_op>
    return -1;
80105982:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105987:	eb 18                	jmp    801059a1 <sys_mknod+0x93>
  }
  iunlockput(ip);
80105989:	83 ec 0c             	sub    $0xc,%esp
8010598c:	ff 75 f4             	push   -0xc(%ebp)
8010598f:	e8 78 c2 ff ff       	call   80101c0c <iunlockput>
80105994:	83 c4 10             	add    $0x10,%esp
  end_op();
80105997:	e8 1d d7 ff ff       	call   801030b9 <end_op>
  return 0;
8010599c:	b8 00 00 00 00       	mov    $0x0,%eax
}
801059a1:	c9                   	leave  
801059a2:	c3                   	ret    

801059a3 <sys_chdir>:

int
sys_chdir(void)
{
801059a3:	55                   	push   %ebp
801059a4:	89 e5                	mov    %esp,%ebp
801059a6:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801059a9:	e8 73 e0 ff ff       	call   80103a21 <myproc>
801059ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
801059b1:	e8 77 d6 ff ff       	call   8010302d <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801059b6:	83 ec 08             	sub    $0x8,%esp
801059b9:	8d 45 ec             	lea    -0x14(%ebp),%eax
801059bc:	50                   	push   %eax
801059bd:	6a 00                	push   $0x0
801059bf:	e8 4a f4 ff ff       	call   80104e0e <argstr>
801059c4:	83 c4 10             	add    $0x10,%esp
801059c7:	85 c0                	test   %eax,%eax
801059c9:	78 18                	js     801059e3 <sys_chdir+0x40>
801059cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801059ce:	83 ec 0c             	sub    $0xc,%esp
801059d1:	50                   	push   %eax
801059d2:	e8 37 cb ff ff       	call   8010250e <namei>
801059d7:	83 c4 10             	add    $0x10,%esp
801059da:	89 45 f0             	mov    %eax,-0x10(%ebp)
801059dd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059e1:	75 0c                	jne    801059ef <sys_chdir+0x4c>
    end_op();
801059e3:	e8 d1 d6 ff ff       	call   801030b9 <end_op>
    return -1;
801059e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059ed:	eb 68                	jmp    80105a57 <sys_chdir+0xb4>
  }
  ilock(ip);
801059ef:	83 ec 0c             	sub    $0xc,%esp
801059f2:	ff 75 f0             	push   -0x10(%ebp)
801059f5:	e8 e1 bf ff ff       	call   801019db <ilock>
801059fa:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
801059fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a00:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105a04:	66 83 f8 01          	cmp    $0x1,%ax
80105a08:	74 1a                	je     80105a24 <sys_chdir+0x81>
    iunlockput(ip);
80105a0a:	83 ec 0c             	sub    $0xc,%esp
80105a0d:	ff 75 f0             	push   -0x10(%ebp)
80105a10:	e8 f7 c1 ff ff       	call   80101c0c <iunlockput>
80105a15:	83 c4 10             	add    $0x10,%esp
    end_op();
80105a18:	e8 9c d6 ff ff       	call   801030b9 <end_op>
    return -1;
80105a1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a22:	eb 33                	jmp    80105a57 <sys_chdir+0xb4>
  }
  iunlock(ip);
80105a24:	83 ec 0c             	sub    $0xc,%esp
80105a27:	ff 75 f0             	push   -0x10(%ebp)
80105a2a:	e8 bf c0 ff ff       	call   80101aee <iunlock>
80105a2f:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105a32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a35:	8b 40 68             	mov    0x68(%eax),%eax
80105a38:	83 ec 0c             	sub    $0xc,%esp
80105a3b:	50                   	push   %eax
80105a3c:	e8 fb c0 ff ff       	call   80101b3c <iput>
80105a41:	83 c4 10             	add    $0x10,%esp
  end_op();
80105a44:	e8 70 d6 ff ff       	call   801030b9 <end_op>
  curproc->cwd = ip;
80105a49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a4c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a4f:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105a52:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a57:	c9                   	leave  
80105a58:	c3                   	ret    

80105a59 <sys_exec>:

int
sys_exec(void)
{
80105a59:	55                   	push   %ebp
80105a5a:	89 e5                	mov    %esp,%ebp
80105a5c:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105a62:	83 ec 08             	sub    $0x8,%esp
80105a65:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a68:	50                   	push   %eax
80105a69:	6a 00                	push   $0x0
80105a6b:	e8 9e f3 ff ff       	call   80104e0e <argstr>
80105a70:	83 c4 10             	add    $0x10,%esp
80105a73:	85 c0                	test   %eax,%eax
80105a75:	78 18                	js     80105a8f <sys_exec+0x36>
80105a77:	83 ec 08             	sub    $0x8,%esp
80105a7a:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105a80:	50                   	push   %eax
80105a81:	6a 01                	push   $0x1
80105a83:	e8 18 f3 ff ff       	call   80104da0 <argint>
80105a88:	83 c4 10             	add    $0x10,%esp
80105a8b:	85 c0                	test   %eax,%eax
80105a8d:	79 0a                	jns    80105a99 <sys_exec+0x40>
    return -1;
80105a8f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a94:	e9 c6 00 00 00       	jmp    80105b5f <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80105a99:	83 ec 04             	sub    $0x4,%esp
80105a9c:	68 80 00 00 00       	push   $0x80
80105aa1:	6a 00                	push   $0x0
80105aa3:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105aa9:	50                   	push   %eax
80105aaa:	e8 02 f0 ff ff       	call   80104ab1 <memset>
80105aaf:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105ab2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105ab9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105abc:	83 f8 1f             	cmp    $0x1f,%eax
80105abf:	76 0a                	jbe    80105acb <sys_exec+0x72>
      return -1;
80105ac1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ac6:	e9 94 00 00 00       	jmp    80105b5f <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ace:	c1 e0 02             	shl    $0x2,%eax
80105ad1:	89 c2                	mov    %eax,%edx
80105ad3:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105ad9:	01 c2                	add    %eax,%edx
80105adb:	83 ec 08             	sub    $0x8,%esp
80105ade:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105ae4:	50                   	push   %eax
80105ae5:	52                   	push   %edx
80105ae6:	e8 50 f2 ff ff       	call   80104d3b <fetchint>
80105aeb:	83 c4 10             	add    $0x10,%esp
80105aee:	85 c0                	test   %eax,%eax
80105af0:	79 07                	jns    80105af9 <sys_exec+0xa0>
      return -1;
80105af2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105af7:	eb 66                	jmp    80105b5f <sys_exec+0x106>
    if(uarg == 0){
80105af9:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105aff:	85 c0                	test   %eax,%eax
80105b01:	75 27                	jne    80105b2a <sys_exec+0xd1>
      argv[i] = 0;
80105b03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b06:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105b0d:	00 00 00 00 
      break;
80105b11:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105b12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b15:	83 ec 08             	sub    $0x8,%esp
80105b18:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105b1e:	52                   	push   %edx
80105b1f:	50                   	push   %eax
80105b20:	e8 5b b0 ff ff       	call   80100b80 <exec>
80105b25:	83 c4 10             	add    $0x10,%esp
80105b28:	eb 35                	jmp    80105b5f <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105b2a:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b33:	c1 e0 02             	shl    $0x2,%eax
80105b36:	01 c2                	add    %eax,%edx
80105b38:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105b3e:	83 ec 08             	sub    $0x8,%esp
80105b41:	52                   	push   %edx
80105b42:	50                   	push   %eax
80105b43:	e8 07 f2 ff ff       	call   80104d4f <fetchstr>
80105b48:	83 c4 10             	add    $0x10,%esp
80105b4b:	85 c0                	test   %eax,%eax
80105b4d:	79 07                	jns    80105b56 <sys_exec+0xfd>
      return -1;
80105b4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b54:	eb 09                	jmp    80105b5f <sys_exec+0x106>
  for(i=0;; i++){
80105b56:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105b5a:	e9 5a ff ff ff       	jmp    80105ab9 <sys_exec+0x60>
}
80105b5f:	c9                   	leave  
80105b60:	c3                   	ret    

80105b61 <sys_pipe>:

int
sys_pipe(void)
{
80105b61:	55                   	push   %ebp
80105b62:	89 e5                	mov    %esp,%ebp
80105b64:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105b67:	83 ec 04             	sub    $0x4,%esp
80105b6a:	6a 08                	push   $0x8
80105b6c:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b6f:	50                   	push   %eax
80105b70:	6a 00                	push   $0x0
80105b72:	e8 56 f2 ff ff       	call   80104dcd <argptr>
80105b77:	83 c4 10             	add    $0x10,%esp
80105b7a:	85 c0                	test   %eax,%eax
80105b7c:	79 0a                	jns    80105b88 <sys_pipe+0x27>
    return -1;
80105b7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b83:	e9 ae 00 00 00       	jmp    80105c36 <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105b88:	83 ec 08             	sub    $0x8,%esp
80105b8b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105b8e:	50                   	push   %eax
80105b8f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105b92:	50                   	push   %eax
80105b93:	e8 c6 d9 ff ff       	call   8010355e <pipealloc>
80105b98:	83 c4 10             	add    $0x10,%esp
80105b9b:	85 c0                	test   %eax,%eax
80105b9d:	79 0a                	jns    80105ba9 <sys_pipe+0x48>
    return -1;
80105b9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ba4:	e9 8d 00 00 00       	jmp    80105c36 <sys_pipe+0xd5>
  fd0 = -1;
80105ba9:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105bb0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105bb3:	83 ec 0c             	sub    $0xc,%esp
80105bb6:	50                   	push   %eax
80105bb7:	e8 7b f3 ff ff       	call   80104f37 <fdalloc>
80105bbc:	83 c4 10             	add    $0x10,%esp
80105bbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bc2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bc6:	78 18                	js     80105be0 <sys_pipe+0x7f>
80105bc8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105bcb:	83 ec 0c             	sub    $0xc,%esp
80105bce:	50                   	push   %eax
80105bcf:	e8 63 f3 ff ff       	call   80104f37 <fdalloc>
80105bd4:	83 c4 10             	add    $0x10,%esp
80105bd7:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105bda:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105bde:	79 3e                	jns    80105c1e <sys_pipe+0xbd>
    if(fd0 >= 0)
80105be0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105be4:	78 13                	js     80105bf9 <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105be6:	e8 36 de ff ff       	call   80103a21 <myproc>
80105beb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105bee:	83 c2 08             	add    $0x8,%edx
80105bf1:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105bf8:	00 
    fileclose(rf);
80105bf9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105bfc:	83 ec 0c             	sub    $0xc,%esp
80105bff:	50                   	push   %eax
80105c00:	e8 87 b4 ff ff       	call   8010108c <fileclose>
80105c05:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105c08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c0b:	83 ec 0c             	sub    $0xc,%esp
80105c0e:	50                   	push   %eax
80105c0f:	e8 78 b4 ff ff       	call   8010108c <fileclose>
80105c14:	83 c4 10             	add    $0x10,%esp
    return -1;
80105c17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c1c:	eb 18                	jmp    80105c36 <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80105c1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105c21:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c24:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105c26:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105c29:	8d 50 04             	lea    0x4(%eax),%edx
80105c2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c2f:	89 02                	mov    %eax,(%edx)
  return 0;
80105c31:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c36:	c9                   	leave  
80105c37:	c3                   	ret    

80105c38 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80105c38:	55                   	push   %ebp
80105c39:	89 e5                	mov    %esp,%ebp
80105c3b:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105c3e:	e8 dd e0 ff ff       	call   80103d20 <fork>
}
80105c43:	c9                   	leave  
80105c44:	c3                   	ret    

80105c45 <sys_exit>:

int
sys_exit(void)
{
80105c45:	55                   	push   %ebp
80105c46:	89 e5                	mov    %esp,%ebp
80105c48:	83 ec 08             	sub    $0x8,%esp
  exit();
80105c4b:	e8 49 e2 ff ff       	call   80103e99 <exit>
  return 0;  // not reached
80105c50:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c55:	c9                   	leave  
80105c56:	c3                   	ret    

80105c57 <sys_wait>:

int
sys_wait(void)
{
80105c57:	55                   	push   %ebp
80105c58:	89 e5                	mov    %esp,%ebp
80105c5a:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105c5d:	e8 57 e3 ff ff       	call   80103fb9 <wait>
}
80105c62:	c9                   	leave  
80105c63:	c3                   	ret    

80105c64 <sys_kill>:

int
sys_kill(void)
{
80105c64:	55                   	push   %ebp
80105c65:	89 e5                	mov    %esp,%ebp
80105c67:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105c6a:	83 ec 08             	sub    $0x8,%esp
80105c6d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c70:	50                   	push   %eax
80105c71:	6a 00                	push   $0x0
80105c73:	e8 28 f1 ff ff       	call   80104da0 <argint>
80105c78:	83 c4 10             	add    $0x10,%esp
80105c7b:	85 c0                	test   %eax,%eax
80105c7d:	79 07                	jns    80105c86 <sys_kill+0x22>
    return -1;
80105c7f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c84:	eb 0f                	jmp    80105c95 <sys_kill+0x31>
  return kill(pid);
80105c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c89:	83 ec 0c             	sub    $0xc,%esp
80105c8c:	50                   	push   %eax
80105c8d:	e8 56 e7 ff ff       	call   801043e8 <kill>
80105c92:	83 c4 10             	add    $0x10,%esp
}
80105c95:	c9                   	leave  
80105c96:	c3                   	ret    

80105c97 <sys_getpid>:

int
sys_getpid(void)
{
80105c97:	55                   	push   %ebp
80105c98:	89 e5                	mov    %esp,%ebp
80105c9a:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105c9d:	e8 7f dd ff ff       	call   80103a21 <myproc>
80105ca2:	8b 40 10             	mov    0x10(%eax),%eax
}
80105ca5:	c9                   	leave  
80105ca6:	c3                   	ret    

80105ca7 <sys_sbrk>:

int
sys_sbrk(void)
{
80105ca7:	55                   	push   %ebp
80105ca8:	89 e5                	mov    %esp,%ebp
80105caa:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105cad:	83 ec 08             	sub    $0x8,%esp
80105cb0:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105cb3:	50                   	push   %eax
80105cb4:	6a 00                	push   $0x0
80105cb6:	e8 e5 f0 ff ff       	call   80104da0 <argint>
80105cbb:	83 c4 10             	add    $0x10,%esp
80105cbe:	85 c0                	test   %eax,%eax
80105cc0:	79 07                	jns    80105cc9 <sys_sbrk+0x22>
    return -1;
80105cc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cc7:	eb 27                	jmp    80105cf0 <sys_sbrk+0x49>
  addr = myproc()->sz;
80105cc9:	e8 53 dd ff ff       	call   80103a21 <myproc>
80105cce:	8b 00                	mov    (%eax),%eax
80105cd0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80105cd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cd6:	83 ec 0c             	sub    $0xc,%esp
80105cd9:	50                   	push   %eax
80105cda:	e8 a6 df ff ff       	call   80103c85 <growproc>
80105cdf:	83 c4 10             	add    $0x10,%esp
80105ce2:	85 c0                	test   %eax,%eax
80105ce4:	79 07                	jns    80105ced <sys_sbrk+0x46>
    return -1;
80105ce6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ceb:	eb 03                	jmp    80105cf0 <sys_sbrk+0x49>
  return addr;
80105ced:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105cf0:	c9                   	leave  
80105cf1:	c3                   	ret    

80105cf2 <sys_sleep>:

int
sys_sleep(void)
{
80105cf2:	55                   	push   %ebp
80105cf3:	89 e5                	mov    %esp,%ebp
80105cf5:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105cf8:	83 ec 08             	sub    $0x8,%esp
80105cfb:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105cfe:	50                   	push   %eax
80105cff:	6a 00                	push   $0x0
80105d01:	e8 9a f0 ff ff       	call   80104da0 <argint>
80105d06:	83 c4 10             	add    $0x10,%esp
80105d09:	85 c0                	test   %eax,%eax
80105d0b:	79 07                	jns    80105d14 <sys_sleep+0x22>
    return -1;
80105d0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d12:	eb 76                	jmp    80105d8a <sys_sleep+0x98>
  acquire(&tickslock);
80105d14:	83 ec 0c             	sub    $0xc,%esp
80105d17:	68 40 69 19 80       	push   $0x80196940
80105d1c:	e8 1a eb ff ff       	call   8010483b <acquire>
80105d21:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80105d24:	a1 74 69 19 80       	mov    0x80196974,%eax
80105d29:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80105d2c:	eb 38                	jmp    80105d66 <sys_sleep+0x74>
    if(myproc()->killed){
80105d2e:	e8 ee dc ff ff       	call   80103a21 <myproc>
80105d33:	8b 40 24             	mov    0x24(%eax),%eax
80105d36:	85 c0                	test   %eax,%eax
80105d38:	74 17                	je     80105d51 <sys_sleep+0x5f>
      release(&tickslock);
80105d3a:	83 ec 0c             	sub    $0xc,%esp
80105d3d:	68 40 69 19 80       	push   $0x80196940
80105d42:	e8 62 eb ff ff       	call   801048a9 <release>
80105d47:	83 c4 10             	add    $0x10,%esp
      return -1;
80105d4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d4f:	eb 39                	jmp    80105d8a <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80105d51:	83 ec 08             	sub    $0x8,%esp
80105d54:	68 40 69 19 80       	push   $0x80196940
80105d59:	68 74 69 19 80       	push   $0x80196974
80105d5e:	e8 67 e5 ff ff       	call   801042ca <sleep>
80105d63:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80105d66:	a1 74 69 19 80       	mov    0x80196974,%eax
80105d6b:	2b 45 f4             	sub    -0xc(%ebp),%eax
80105d6e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d71:	39 d0                	cmp    %edx,%eax
80105d73:	72 b9                	jb     80105d2e <sys_sleep+0x3c>
  }
  release(&tickslock);
80105d75:	83 ec 0c             	sub    $0xc,%esp
80105d78:	68 40 69 19 80       	push   $0x80196940
80105d7d:	e8 27 eb ff ff       	call   801048a9 <release>
80105d82:	83 c4 10             	add    $0x10,%esp
  return 0;
80105d85:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d8a:	c9                   	leave  
80105d8b:	c3                   	ret    

80105d8c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105d8c:	55                   	push   %ebp
80105d8d:	89 e5                	mov    %esp,%ebp
80105d8f:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80105d92:	83 ec 0c             	sub    $0xc,%esp
80105d95:	68 40 69 19 80       	push   $0x80196940
80105d9a:	e8 9c ea ff ff       	call   8010483b <acquire>
80105d9f:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80105da2:	a1 74 69 19 80       	mov    0x80196974,%eax
80105da7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80105daa:	83 ec 0c             	sub    $0xc,%esp
80105dad:	68 40 69 19 80       	push   $0x80196940
80105db2:	e8 f2 ea ff ff       	call   801048a9 <release>
80105db7:	83 c4 10             	add    $0x10,%esp
  return xticks;
80105dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105dbd:	c9                   	leave  
80105dbe:	c3                   	ret    

80105dbf <sys_printpt>:

  int sys_printpt(int pid)
  {
80105dbf:	55                   	push   %ebp
80105dc0:	89 e5                	mov    %esp,%ebp
80105dc2:	83 ec 18             	sub    $0x18,%esp
    int n;
    if (argint(0, &n) < 0)
80105dc5:	83 ec 08             	sub    $0x8,%esp
80105dc8:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105dcb:	50                   	push   %eax
80105dcc:	6a 00                	push   $0x0
80105dce:	e8 cd ef ff ff       	call   80104da0 <argint>
80105dd3:	83 c4 10             	add    $0x10,%esp
80105dd6:	85 c0                	test   %eax,%eax
80105dd8:	79 07                	jns    80105de1 <sys_printpt+0x22>
      return -1;
80105dda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ddf:	eb 14                	jmp    80105df5 <sys_printpt+0x36>
    printpt(n);
80105de1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105de4:	83 ec 0c             	sub    $0xc,%esp
80105de7:	50                   	push   %eax
80105de8:	e8 79 e7 ff ff       	call   80104566 <printpt>
80105ded:	83 c4 10             	add    $0x10,%esp
    return 0;
80105df0:	b8 00 00 00 00       	mov    $0x0,%eax
80105df5:	c9                   	leave  
80105df6:	c3                   	ret    

80105df7 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80105df7:	1e                   	push   %ds
  pushl %es
80105df8:	06                   	push   %es
  pushl %fs
80105df9:	0f a0                	push   %fs
  pushl %gs
80105dfb:	0f a8                	push   %gs
  pushal
80105dfd:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80105dfe:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80105e02:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80105e04:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80105e06:	54                   	push   %esp
  call trap
80105e07:	e8 d7 01 00 00       	call   80105fe3 <trap>
  addl $4, %esp
80105e0c:	83 c4 04             	add    $0x4,%esp

80105e0f <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80105e0f:	61                   	popa   
  popl %gs
80105e10:	0f a9                	pop    %gs
  popl %fs
80105e12:	0f a1                	pop    %fs
  popl %es
80105e14:	07                   	pop    %es
  popl %ds
80105e15:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80105e16:	83 c4 08             	add    $0x8,%esp
  iret
80105e19:	cf                   	iret   

80105e1a <lidt>:
{
80105e1a:	55                   	push   %ebp
80105e1b:	89 e5                	mov    %esp,%ebp
80105e1d:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80105e20:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e23:	83 e8 01             	sub    $0x1,%eax
80105e26:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80105e2a:	8b 45 08             	mov    0x8(%ebp),%eax
80105e2d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105e31:	8b 45 08             	mov    0x8(%ebp),%eax
80105e34:	c1 e8 10             	shr    $0x10,%eax
80105e37:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105e3b:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105e3e:	0f 01 18             	lidtl  (%eax)
}
80105e41:	90                   	nop
80105e42:	c9                   	leave  
80105e43:	c3                   	ret    

80105e44 <rcr2>:

static inline uint
rcr2(void)
{
80105e44:	55                   	push   %ebp
80105e45:	89 e5                	mov    %esp,%ebp
80105e47:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105e4a:	0f 20 d0             	mov    %cr2,%eax
80105e4d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80105e50:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105e53:	c9                   	leave  
80105e54:	c3                   	ret    

80105e55 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80105e55:	55                   	push   %ebp
80105e56:	89 e5                	mov    %esp,%ebp
80105e58:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80105e5b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105e62:	e9 c3 00 00 00       	jmp    80105f2a <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80105e67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e6a:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
80105e71:	89 c2                	mov    %eax,%edx
80105e73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e76:	66 89 14 c5 40 61 19 	mov    %dx,-0x7fe69ec0(,%eax,8)
80105e7d:	80 
80105e7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e81:	66 c7 04 c5 42 61 19 	movw   $0x8,-0x7fe69ebe(,%eax,8)
80105e88:	80 08 00 
80105e8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e8e:	0f b6 14 c5 44 61 19 	movzbl -0x7fe69ebc(,%eax,8),%edx
80105e95:	80 
80105e96:	83 e2 e0             	and    $0xffffffe0,%edx
80105e99:	88 14 c5 44 61 19 80 	mov    %dl,-0x7fe69ebc(,%eax,8)
80105ea0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ea3:	0f b6 14 c5 44 61 19 	movzbl -0x7fe69ebc(,%eax,8),%edx
80105eaa:	80 
80105eab:	83 e2 1f             	and    $0x1f,%edx
80105eae:	88 14 c5 44 61 19 80 	mov    %dl,-0x7fe69ebc(,%eax,8)
80105eb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eb8:	0f b6 14 c5 45 61 19 	movzbl -0x7fe69ebb(,%eax,8),%edx
80105ebf:	80 
80105ec0:	83 e2 f0             	and    $0xfffffff0,%edx
80105ec3:	83 ca 0e             	or     $0xe,%edx
80105ec6:	88 14 c5 45 61 19 80 	mov    %dl,-0x7fe69ebb(,%eax,8)
80105ecd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ed0:	0f b6 14 c5 45 61 19 	movzbl -0x7fe69ebb(,%eax,8),%edx
80105ed7:	80 
80105ed8:	83 e2 ef             	and    $0xffffffef,%edx
80105edb:	88 14 c5 45 61 19 80 	mov    %dl,-0x7fe69ebb(,%eax,8)
80105ee2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ee5:	0f b6 14 c5 45 61 19 	movzbl -0x7fe69ebb(,%eax,8),%edx
80105eec:	80 
80105eed:	83 e2 9f             	and    $0xffffff9f,%edx
80105ef0:	88 14 c5 45 61 19 80 	mov    %dl,-0x7fe69ebb(,%eax,8)
80105ef7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105efa:	0f b6 14 c5 45 61 19 	movzbl -0x7fe69ebb(,%eax,8),%edx
80105f01:	80 
80105f02:	83 ca 80             	or     $0xffffff80,%edx
80105f05:	88 14 c5 45 61 19 80 	mov    %dl,-0x7fe69ebb(,%eax,8)
80105f0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f0f:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
80105f16:	c1 e8 10             	shr    $0x10,%eax
80105f19:	89 c2                	mov    %eax,%edx
80105f1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f1e:	66 89 14 c5 46 61 19 	mov    %dx,-0x7fe69eba(,%eax,8)
80105f25:	80 
  for(i = 0; i < 256; i++)
80105f26:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105f2a:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80105f31:	0f 8e 30 ff ff ff    	jle    80105e67 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105f37:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
80105f3c:	66 a3 40 63 19 80    	mov    %ax,0x80196340
80105f42:	66 c7 05 42 63 19 80 	movw   $0x8,0x80196342
80105f49:	08 00 
80105f4b:	0f b6 05 44 63 19 80 	movzbl 0x80196344,%eax
80105f52:	83 e0 e0             	and    $0xffffffe0,%eax
80105f55:	a2 44 63 19 80       	mov    %al,0x80196344
80105f5a:	0f b6 05 44 63 19 80 	movzbl 0x80196344,%eax
80105f61:	83 e0 1f             	and    $0x1f,%eax
80105f64:	a2 44 63 19 80       	mov    %al,0x80196344
80105f69:	0f b6 05 45 63 19 80 	movzbl 0x80196345,%eax
80105f70:	83 c8 0f             	or     $0xf,%eax
80105f73:	a2 45 63 19 80       	mov    %al,0x80196345
80105f78:	0f b6 05 45 63 19 80 	movzbl 0x80196345,%eax
80105f7f:	83 e0 ef             	and    $0xffffffef,%eax
80105f82:	a2 45 63 19 80       	mov    %al,0x80196345
80105f87:	0f b6 05 45 63 19 80 	movzbl 0x80196345,%eax
80105f8e:	83 c8 60             	or     $0x60,%eax
80105f91:	a2 45 63 19 80       	mov    %al,0x80196345
80105f96:	0f b6 05 45 63 19 80 	movzbl 0x80196345,%eax
80105f9d:	83 c8 80             	or     $0xffffff80,%eax
80105fa0:	a2 45 63 19 80       	mov    %al,0x80196345
80105fa5:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
80105faa:	c1 e8 10             	shr    $0x10,%eax
80105fad:	66 a3 46 63 19 80    	mov    %ax,0x80196346

  initlock(&tickslock, "time");
80105fb3:	83 ec 08             	sub    $0x8,%esp
80105fb6:	68 5c a5 10 80       	push   $0x8010a55c
80105fbb:	68 40 69 19 80       	push   $0x80196940
80105fc0:	e8 54 e8 ff ff       	call   80104819 <initlock>
80105fc5:	83 c4 10             	add    $0x10,%esp
}
80105fc8:	90                   	nop
80105fc9:	c9                   	leave  
80105fca:	c3                   	ret    

80105fcb <idtinit>:

void
idtinit(void)
{
80105fcb:	55                   	push   %ebp
80105fcc:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80105fce:	68 00 08 00 00       	push   $0x800
80105fd3:	68 40 61 19 80       	push   $0x80196140
80105fd8:	e8 3d fe ff ff       	call   80105e1a <lidt>
80105fdd:	83 c4 08             	add    $0x8,%esp
}
80105fe0:	90                   	nop
80105fe1:	c9                   	leave  
80105fe2:	c3                   	ret    

80105fe3 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80105fe3:	55                   	push   %ebp
80105fe4:	89 e5                	mov    %esp,%ebp
80105fe6:	57                   	push   %edi
80105fe7:	56                   	push   %esi
80105fe8:	53                   	push   %ebx
80105fe9:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
80105fec:	8b 45 08             	mov    0x8(%ebp),%eax
80105fef:	8b 40 30             	mov    0x30(%eax),%eax
80105ff2:	83 f8 40             	cmp    $0x40,%eax
80105ff5:	75 3b                	jne    80106032 <trap+0x4f>
    if(myproc()->killed)
80105ff7:	e8 25 da ff ff       	call   80103a21 <myproc>
80105ffc:	8b 40 24             	mov    0x24(%eax),%eax
80105fff:	85 c0                	test   %eax,%eax
80106001:	74 05                	je     80106008 <trap+0x25>
      exit();
80106003:	e8 91 de ff ff       	call   80103e99 <exit>
    myproc()->tf = tf;
80106008:	e8 14 da ff ff       	call   80103a21 <myproc>
8010600d:	8b 55 08             	mov    0x8(%ebp),%edx
80106010:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106013:	e8 2d ee ff ff       	call   80104e45 <syscall>
    if(myproc()->killed)
80106018:	e8 04 da ff ff       	call   80103a21 <myproc>
8010601d:	8b 40 24             	mov    0x24(%eax),%eax
80106020:	85 c0                	test   %eax,%eax
80106022:	0f 84 63 02 00 00    	je     8010628b <trap+0x2a8>
      exit();
80106028:	e8 6c de ff ff       	call   80103e99 <exit>
    return;
8010602d:	e9 59 02 00 00       	jmp    8010628b <trap+0x2a8>
  }

  switch(tf->trapno){
80106032:	8b 45 08             	mov    0x8(%ebp),%eax
80106035:	8b 40 30             	mov    0x30(%eax),%eax
80106038:	83 e8 0e             	sub    $0xe,%eax
8010603b:	83 f8 31             	cmp    $0x31,%eax
8010603e:	0f 87 0f 01 00 00    	ja     80106153 <trap+0x170>
80106044:	8b 04 85 1c a6 10 80 	mov    -0x7fef59e4(,%eax,4),%eax
8010604b:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
8010604d:	e8 3c d9 ff ff       	call   8010398e <cpuid>
80106052:	85 c0                	test   %eax,%eax
80106054:	75 3d                	jne    80106093 <trap+0xb0>
      acquire(&tickslock);
80106056:	83 ec 0c             	sub    $0xc,%esp
80106059:	68 40 69 19 80       	push   $0x80196940
8010605e:	e8 d8 e7 ff ff       	call   8010483b <acquire>
80106063:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106066:	a1 74 69 19 80       	mov    0x80196974,%eax
8010606b:	83 c0 01             	add    $0x1,%eax
8010606e:	a3 74 69 19 80       	mov    %eax,0x80196974
      wakeup(&ticks);
80106073:	83 ec 0c             	sub    $0xc,%esp
80106076:	68 74 69 19 80       	push   $0x80196974
8010607b:	e8 31 e3 ff ff       	call   801043b1 <wakeup>
80106080:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106083:	83 ec 0c             	sub    $0xc,%esp
80106086:	68 40 69 19 80       	push   $0x80196940
8010608b:	e8 19 e8 ff ff       	call   801048a9 <release>
80106090:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106093:	e8 75 ca ff ff       	call   80102b0d <lapiceoi>
    break;
80106098:	e9 6e 01 00 00       	jmp    8010620b <trap+0x228>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010609d:	e8 30 3f 00 00       	call   80109fd2 <ideintr>
    lapiceoi();
801060a2:	e8 66 ca ff ff       	call   80102b0d <lapiceoi>
    break;
801060a7:	e9 5f 01 00 00       	jmp    8010620b <trap+0x228>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801060ac:	e8 a1 c8 ff ff       	call   80102952 <kbdintr>
    lapiceoi();
801060b1:	e8 57 ca ff ff       	call   80102b0d <lapiceoi>
    break;
801060b6:	e9 50 01 00 00       	jmp    8010620b <trap+0x228>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801060bb:	e8 a1 03 00 00       	call   80106461 <uartintr>
    lapiceoi();
801060c0:	e8 48 ca ff ff       	call   80102b0d <lapiceoi>
    break;
801060c5:	e9 41 01 00 00       	jmp    8010620b <trap+0x228>
  case T_IRQ0 + 0xB:
    i8254_intr();
801060ca:	e8 b6 2b 00 00       	call   80108c85 <i8254_intr>
    lapiceoi();
801060cf:	e8 39 ca ff ff       	call   80102b0d <lapiceoi>
    break;
801060d4:	e9 32 01 00 00       	jmp    8010620b <trap+0x228>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801060d9:	8b 45 08             	mov    0x8(%ebp),%eax
801060dc:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
801060df:	8b 45 08             	mov    0x8(%ebp),%eax
801060e2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801060e6:	0f b7 d8             	movzwl %ax,%ebx
801060e9:	e8 a0 d8 ff ff       	call   8010398e <cpuid>
801060ee:	56                   	push   %esi
801060ef:	53                   	push   %ebx
801060f0:	50                   	push   %eax
801060f1:	68 64 a5 10 80       	push   $0x8010a564
801060f6:	e8 f9 a2 ff ff       	call   801003f4 <cprintf>
801060fb:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
801060fe:	e8 0a ca ff ff       	call   80102b0d <lapiceoi>
    break;
80106103:	e9 03 01 00 00       	jmp    8010620b <trap+0x228>

  case T_PGFLT:
    uint sz = PGROUNDDOWN(rcr2());
80106108:	e8 37 fd ff ff       	call   80105e44 <rcr2>
8010610d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106112:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    if ((sz = allocuvm(myproc()->pgdir, sz, sz + PGSIZE)) == 0) 
80106115:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106118:	8d 98 00 10 00 00    	lea    0x1000(%eax),%ebx
8010611e:	e8 fe d8 ff ff       	call   80103a21 <myproc>
80106123:	8b 40 04             	mov    0x4(%eax),%eax
80106126:	83 ec 04             	sub    $0x4,%esp
80106129:	53                   	push   %ebx
8010612a:	ff 75 e4             	push   -0x1c(%ebp)
8010612d:	50                   	push   %eax
8010612e:	e8 7b 16 00 00       	call   801077ae <allocuvm>
80106133:	83 c4 10             	add    $0x10,%esp
80106136:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106139:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010613d:	0f 85 c7 00 00 00    	jne    8010620a <trap+0x227>
      cprintf("faild stack allocation\n");
80106143:	83 ec 0c             	sub    $0xc,%esp
80106146:	68 88 a5 10 80       	push   $0x8010a588
8010614b:	e8 a4 a2 ff ff       	call   801003f4 <cprintf>
80106150:	83 c4 10             	add    $0x10,%esp
      break;
    }
    
  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106153:	e8 c9 d8 ff ff       	call   80103a21 <myproc>
80106158:	85 c0                	test   %eax,%eax
8010615a:	74 11                	je     8010616d <trap+0x18a>
8010615c:	8b 45 08             	mov    0x8(%ebp),%eax
8010615f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106163:	0f b7 c0             	movzwl %ax,%eax
80106166:	83 e0 03             	and    $0x3,%eax
80106169:	85 c0                	test   %eax,%eax
8010616b:	75 39                	jne    801061a6 <trap+0x1c3>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010616d:	e8 d2 fc ff ff       	call   80105e44 <rcr2>
80106172:	89 c3                	mov    %eax,%ebx
80106174:	8b 45 08             	mov    0x8(%ebp),%eax
80106177:	8b 70 38             	mov    0x38(%eax),%esi
8010617a:	e8 0f d8 ff ff       	call   8010398e <cpuid>
8010617f:	8b 55 08             	mov    0x8(%ebp),%edx
80106182:	8b 52 30             	mov    0x30(%edx),%edx
80106185:	83 ec 0c             	sub    $0xc,%esp
80106188:	53                   	push   %ebx
80106189:	56                   	push   %esi
8010618a:	50                   	push   %eax
8010618b:	52                   	push   %edx
8010618c:	68 a0 a5 10 80       	push   $0x8010a5a0
80106191:	e8 5e a2 ff ff       	call   801003f4 <cprintf>
80106196:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106199:	83 ec 0c             	sub    $0xc,%esp
8010619c:	68 d2 a5 10 80       	push   $0x8010a5d2
801061a1:	e8 03 a4 ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801061a6:	e8 99 fc ff ff       	call   80105e44 <rcr2>
801061ab:	89 c6                	mov    %eax,%esi
801061ad:	8b 45 08             	mov    0x8(%ebp),%eax
801061b0:	8b 40 38             	mov    0x38(%eax),%eax
801061b3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801061b6:	e8 d3 d7 ff ff       	call   8010398e <cpuid>
801061bb:	89 c3                	mov    %eax,%ebx
801061bd:	8b 45 08             	mov    0x8(%ebp),%eax
801061c0:	8b 48 34             	mov    0x34(%eax),%ecx
801061c3:	89 4d d0             	mov    %ecx,-0x30(%ebp)
801061c6:	8b 45 08             	mov    0x8(%ebp),%eax
801061c9:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801061cc:	e8 50 d8 ff ff       	call   80103a21 <myproc>
801061d1:	8d 50 6c             	lea    0x6c(%eax),%edx
801061d4:	89 55 cc             	mov    %edx,-0x34(%ebp)
801061d7:	e8 45 d8 ff ff       	call   80103a21 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801061dc:	8b 40 10             	mov    0x10(%eax),%eax
801061df:	56                   	push   %esi
801061e0:	ff 75 d4             	push   -0x2c(%ebp)
801061e3:	53                   	push   %ebx
801061e4:	ff 75 d0             	push   -0x30(%ebp)
801061e7:	57                   	push   %edi
801061e8:	ff 75 cc             	push   -0x34(%ebp)
801061eb:	50                   	push   %eax
801061ec:	68 d8 a5 10 80       	push   $0x8010a5d8
801061f1:	e8 fe a1 ff ff       	call   801003f4 <cprintf>
801061f6:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
801061f9:	e8 23 d8 ff ff       	call   80103a21 <myproc>
801061fe:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106205:	eb 04                	jmp    8010620b <trap+0x228>
    break;
80106207:	90                   	nop
80106208:	eb 01                	jmp    8010620b <trap+0x228>
      break;
8010620a:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010620b:	e8 11 d8 ff ff       	call   80103a21 <myproc>
80106210:	85 c0                	test   %eax,%eax
80106212:	74 23                	je     80106237 <trap+0x254>
80106214:	e8 08 d8 ff ff       	call   80103a21 <myproc>
80106219:	8b 40 24             	mov    0x24(%eax),%eax
8010621c:	85 c0                	test   %eax,%eax
8010621e:	74 17                	je     80106237 <trap+0x254>
80106220:	8b 45 08             	mov    0x8(%ebp),%eax
80106223:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106227:	0f b7 c0             	movzwl %ax,%eax
8010622a:	83 e0 03             	and    $0x3,%eax
8010622d:	83 f8 03             	cmp    $0x3,%eax
80106230:	75 05                	jne    80106237 <trap+0x254>
    exit();
80106232:	e8 62 dc ff ff       	call   80103e99 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106237:	e8 e5 d7 ff ff       	call   80103a21 <myproc>
8010623c:	85 c0                	test   %eax,%eax
8010623e:	74 1d                	je     8010625d <trap+0x27a>
80106240:	e8 dc d7 ff ff       	call   80103a21 <myproc>
80106245:	8b 40 0c             	mov    0xc(%eax),%eax
80106248:	83 f8 04             	cmp    $0x4,%eax
8010624b:	75 10                	jne    8010625d <trap+0x27a>
     tf->trapno == T_IRQ0+IRQ_TIMER)
8010624d:	8b 45 08             	mov    0x8(%ebp),%eax
80106250:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106253:	83 f8 20             	cmp    $0x20,%eax
80106256:	75 05                	jne    8010625d <trap+0x27a>
    yield();
80106258:	e8 ed df ff ff       	call   8010424a <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010625d:	e8 bf d7 ff ff       	call   80103a21 <myproc>
80106262:	85 c0                	test   %eax,%eax
80106264:	74 26                	je     8010628c <trap+0x2a9>
80106266:	e8 b6 d7 ff ff       	call   80103a21 <myproc>
8010626b:	8b 40 24             	mov    0x24(%eax),%eax
8010626e:	85 c0                	test   %eax,%eax
80106270:	74 1a                	je     8010628c <trap+0x2a9>
80106272:	8b 45 08             	mov    0x8(%ebp),%eax
80106275:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106279:	0f b7 c0             	movzwl %ax,%eax
8010627c:	83 e0 03             	and    $0x3,%eax
8010627f:	83 f8 03             	cmp    $0x3,%eax
80106282:	75 08                	jne    8010628c <trap+0x2a9>
    exit();
80106284:	e8 10 dc ff ff       	call   80103e99 <exit>
80106289:	eb 01                	jmp    8010628c <trap+0x2a9>
    return;
8010628b:	90                   	nop
}
8010628c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010628f:	5b                   	pop    %ebx
80106290:	5e                   	pop    %esi
80106291:	5f                   	pop    %edi
80106292:	5d                   	pop    %ebp
80106293:	c3                   	ret    

80106294 <inb>:
{
80106294:	55                   	push   %ebp
80106295:	89 e5                	mov    %esp,%ebp
80106297:	83 ec 14             	sub    $0x14,%esp
8010629a:	8b 45 08             	mov    0x8(%ebp),%eax
8010629d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801062a1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801062a5:	89 c2                	mov    %eax,%edx
801062a7:	ec                   	in     (%dx),%al
801062a8:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801062ab:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801062af:	c9                   	leave  
801062b0:	c3                   	ret    

801062b1 <outb>:
{
801062b1:	55                   	push   %ebp
801062b2:	89 e5                	mov    %esp,%ebp
801062b4:	83 ec 08             	sub    $0x8,%esp
801062b7:	8b 45 08             	mov    0x8(%ebp),%eax
801062ba:	8b 55 0c             	mov    0xc(%ebp),%edx
801062bd:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801062c1:	89 d0                	mov    %edx,%eax
801062c3:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801062c6:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801062ca:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801062ce:	ee                   	out    %al,(%dx)
}
801062cf:	90                   	nop
801062d0:	c9                   	leave  
801062d1:	c3                   	ret    

801062d2 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801062d2:	55                   	push   %ebp
801062d3:	89 e5                	mov    %esp,%ebp
801062d5:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801062d8:	6a 00                	push   $0x0
801062da:	68 fa 03 00 00       	push   $0x3fa
801062df:	e8 cd ff ff ff       	call   801062b1 <outb>
801062e4:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801062e7:	68 80 00 00 00       	push   $0x80
801062ec:	68 fb 03 00 00       	push   $0x3fb
801062f1:	e8 bb ff ff ff       	call   801062b1 <outb>
801062f6:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801062f9:	6a 0c                	push   $0xc
801062fb:	68 f8 03 00 00       	push   $0x3f8
80106300:	e8 ac ff ff ff       	call   801062b1 <outb>
80106305:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106308:	6a 00                	push   $0x0
8010630a:	68 f9 03 00 00       	push   $0x3f9
8010630f:	e8 9d ff ff ff       	call   801062b1 <outb>
80106314:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106317:	6a 03                	push   $0x3
80106319:	68 fb 03 00 00       	push   $0x3fb
8010631e:	e8 8e ff ff ff       	call   801062b1 <outb>
80106323:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106326:	6a 00                	push   $0x0
80106328:	68 fc 03 00 00       	push   $0x3fc
8010632d:	e8 7f ff ff ff       	call   801062b1 <outb>
80106332:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106335:	6a 01                	push   $0x1
80106337:	68 f9 03 00 00       	push   $0x3f9
8010633c:	e8 70 ff ff ff       	call   801062b1 <outb>
80106341:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106344:	68 fd 03 00 00       	push   $0x3fd
80106349:	e8 46 ff ff ff       	call   80106294 <inb>
8010634e:	83 c4 04             	add    $0x4,%esp
80106351:	3c ff                	cmp    $0xff,%al
80106353:	74 61                	je     801063b6 <uartinit+0xe4>
    return;
  uart = 1;
80106355:	c7 05 78 69 19 80 01 	movl   $0x1,0x80196978
8010635c:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
8010635f:	68 fa 03 00 00       	push   $0x3fa
80106364:	e8 2b ff ff ff       	call   80106294 <inb>
80106369:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
8010636c:	68 f8 03 00 00       	push   $0x3f8
80106371:	e8 1e ff ff ff       	call   80106294 <inb>
80106376:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106379:	83 ec 08             	sub    $0x8,%esp
8010637c:	6a 00                	push   $0x0
8010637e:	6a 04                	push   $0x4
80106380:	e8 9a c2 ff ff       	call   8010261f <ioapicenable>
80106385:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106388:	c7 45 f4 e4 a6 10 80 	movl   $0x8010a6e4,-0xc(%ebp)
8010638f:	eb 19                	jmp    801063aa <uartinit+0xd8>
    uartputc(*p);
80106391:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106394:	0f b6 00             	movzbl (%eax),%eax
80106397:	0f be c0             	movsbl %al,%eax
8010639a:	83 ec 0c             	sub    $0xc,%esp
8010639d:	50                   	push   %eax
8010639e:	e8 16 00 00 00       	call   801063b9 <uartputc>
801063a3:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
801063a6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801063aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063ad:	0f b6 00             	movzbl (%eax),%eax
801063b0:	84 c0                	test   %al,%al
801063b2:	75 dd                	jne    80106391 <uartinit+0xbf>
801063b4:	eb 01                	jmp    801063b7 <uartinit+0xe5>
    return;
801063b6:	90                   	nop
}
801063b7:	c9                   	leave  
801063b8:	c3                   	ret    

801063b9 <uartputc>:

void
uartputc(int c)
{
801063b9:	55                   	push   %ebp
801063ba:	89 e5                	mov    %esp,%ebp
801063bc:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801063bf:	a1 78 69 19 80       	mov    0x80196978,%eax
801063c4:	85 c0                	test   %eax,%eax
801063c6:	74 53                	je     8010641b <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801063c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801063cf:	eb 11                	jmp    801063e2 <uartputc+0x29>
    microdelay(10);
801063d1:	83 ec 0c             	sub    $0xc,%esp
801063d4:	6a 0a                	push   $0xa
801063d6:	e8 4d c7 ff ff       	call   80102b28 <microdelay>
801063db:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801063de:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801063e2:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801063e6:	7f 1a                	jg     80106402 <uartputc+0x49>
801063e8:	83 ec 0c             	sub    $0xc,%esp
801063eb:	68 fd 03 00 00       	push   $0x3fd
801063f0:	e8 9f fe ff ff       	call   80106294 <inb>
801063f5:	83 c4 10             	add    $0x10,%esp
801063f8:	0f b6 c0             	movzbl %al,%eax
801063fb:	83 e0 20             	and    $0x20,%eax
801063fe:	85 c0                	test   %eax,%eax
80106400:	74 cf                	je     801063d1 <uartputc+0x18>
  outb(COM1+0, c);
80106402:	8b 45 08             	mov    0x8(%ebp),%eax
80106405:	0f b6 c0             	movzbl %al,%eax
80106408:	83 ec 08             	sub    $0x8,%esp
8010640b:	50                   	push   %eax
8010640c:	68 f8 03 00 00       	push   $0x3f8
80106411:	e8 9b fe ff ff       	call   801062b1 <outb>
80106416:	83 c4 10             	add    $0x10,%esp
80106419:	eb 01                	jmp    8010641c <uartputc+0x63>
    return;
8010641b:	90                   	nop
}
8010641c:	c9                   	leave  
8010641d:	c3                   	ret    

8010641e <uartgetc>:

static int
uartgetc(void)
{
8010641e:	55                   	push   %ebp
8010641f:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106421:	a1 78 69 19 80       	mov    0x80196978,%eax
80106426:	85 c0                	test   %eax,%eax
80106428:	75 07                	jne    80106431 <uartgetc+0x13>
    return -1;
8010642a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010642f:	eb 2e                	jmp    8010645f <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106431:	68 fd 03 00 00       	push   $0x3fd
80106436:	e8 59 fe ff ff       	call   80106294 <inb>
8010643b:	83 c4 04             	add    $0x4,%esp
8010643e:	0f b6 c0             	movzbl %al,%eax
80106441:	83 e0 01             	and    $0x1,%eax
80106444:	85 c0                	test   %eax,%eax
80106446:	75 07                	jne    8010644f <uartgetc+0x31>
    return -1;
80106448:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010644d:	eb 10                	jmp    8010645f <uartgetc+0x41>
  return inb(COM1+0);
8010644f:	68 f8 03 00 00       	push   $0x3f8
80106454:	e8 3b fe ff ff       	call   80106294 <inb>
80106459:	83 c4 04             	add    $0x4,%esp
8010645c:	0f b6 c0             	movzbl %al,%eax
}
8010645f:	c9                   	leave  
80106460:	c3                   	ret    

80106461 <uartintr>:

void
uartintr(void)
{
80106461:	55                   	push   %ebp
80106462:	89 e5                	mov    %esp,%ebp
80106464:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106467:	83 ec 0c             	sub    $0xc,%esp
8010646a:	68 1e 64 10 80       	push   $0x8010641e
8010646f:	e8 62 a3 ff ff       	call   801007d6 <consoleintr>
80106474:	83 c4 10             	add    $0x10,%esp
}
80106477:	90                   	nop
80106478:	c9                   	leave  
80106479:	c3                   	ret    

8010647a <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010647a:	6a 00                	push   $0x0
  pushl $0
8010647c:	6a 00                	push   $0x0
  jmp alltraps
8010647e:	e9 74 f9 ff ff       	jmp    80105df7 <alltraps>

80106483 <vector1>:
.globl vector1
vector1:
  pushl $0
80106483:	6a 00                	push   $0x0
  pushl $1
80106485:	6a 01                	push   $0x1
  jmp alltraps
80106487:	e9 6b f9 ff ff       	jmp    80105df7 <alltraps>

8010648c <vector2>:
.globl vector2
vector2:
  pushl $0
8010648c:	6a 00                	push   $0x0
  pushl $2
8010648e:	6a 02                	push   $0x2
  jmp alltraps
80106490:	e9 62 f9 ff ff       	jmp    80105df7 <alltraps>

80106495 <vector3>:
.globl vector3
vector3:
  pushl $0
80106495:	6a 00                	push   $0x0
  pushl $3
80106497:	6a 03                	push   $0x3
  jmp alltraps
80106499:	e9 59 f9 ff ff       	jmp    80105df7 <alltraps>

8010649e <vector4>:
.globl vector4
vector4:
  pushl $0
8010649e:	6a 00                	push   $0x0
  pushl $4
801064a0:	6a 04                	push   $0x4
  jmp alltraps
801064a2:	e9 50 f9 ff ff       	jmp    80105df7 <alltraps>

801064a7 <vector5>:
.globl vector5
vector5:
  pushl $0
801064a7:	6a 00                	push   $0x0
  pushl $5
801064a9:	6a 05                	push   $0x5
  jmp alltraps
801064ab:	e9 47 f9 ff ff       	jmp    80105df7 <alltraps>

801064b0 <vector6>:
.globl vector6
vector6:
  pushl $0
801064b0:	6a 00                	push   $0x0
  pushl $6
801064b2:	6a 06                	push   $0x6
  jmp alltraps
801064b4:	e9 3e f9 ff ff       	jmp    80105df7 <alltraps>

801064b9 <vector7>:
.globl vector7
vector7:
  pushl $0
801064b9:	6a 00                	push   $0x0
  pushl $7
801064bb:	6a 07                	push   $0x7
  jmp alltraps
801064bd:	e9 35 f9 ff ff       	jmp    80105df7 <alltraps>

801064c2 <vector8>:
.globl vector8
vector8:
  pushl $8
801064c2:	6a 08                	push   $0x8
  jmp alltraps
801064c4:	e9 2e f9 ff ff       	jmp    80105df7 <alltraps>

801064c9 <vector9>:
.globl vector9
vector9:
  pushl $0
801064c9:	6a 00                	push   $0x0
  pushl $9
801064cb:	6a 09                	push   $0x9
  jmp alltraps
801064cd:	e9 25 f9 ff ff       	jmp    80105df7 <alltraps>

801064d2 <vector10>:
.globl vector10
vector10:
  pushl $10
801064d2:	6a 0a                	push   $0xa
  jmp alltraps
801064d4:	e9 1e f9 ff ff       	jmp    80105df7 <alltraps>

801064d9 <vector11>:
.globl vector11
vector11:
  pushl $11
801064d9:	6a 0b                	push   $0xb
  jmp alltraps
801064db:	e9 17 f9 ff ff       	jmp    80105df7 <alltraps>

801064e0 <vector12>:
.globl vector12
vector12:
  pushl $12
801064e0:	6a 0c                	push   $0xc
  jmp alltraps
801064e2:	e9 10 f9 ff ff       	jmp    80105df7 <alltraps>

801064e7 <vector13>:
.globl vector13
vector13:
  pushl $13
801064e7:	6a 0d                	push   $0xd
  jmp alltraps
801064e9:	e9 09 f9 ff ff       	jmp    80105df7 <alltraps>

801064ee <vector14>:
.globl vector14
vector14:
  pushl $14
801064ee:	6a 0e                	push   $0xe
  jmp alltraps
801064f0:	e9 02 f9 ff ff       	jmp    80105df7 <alltraps>

801064f5 <vector15>:
.globl vector15
vector15:
  pushl $0
801064f5:	6a 00                	push   $0x0
  pushl $15
801064f7:	6a 0f                	push   $0xf
  jmp alltraps
801064f9:	e9 f9 f8 ff ff       	jmp    80105df7 <alltraps>

801064fe <vector16>:
.globl vector16
vector16:
  pushl $0
801064fe:	6a 00                	push   $0x0
  pushl $16
80106500:	6a 10                	push   $0x10
  jmp alltraps
80106502:	e9 f0 f8 ff ff       	jmp    80105df7 <alltraps>

80106507 <vector17>:
.globl vector17
vector17:
  pushl $17
80106507:	6a 11                	push   $0x11
  jmp alltraps
80106509:	e9 e9 f8 ff ff       	jmp    80105df7 <alltraps>

8010650e <vector18>:
.globl vector18
vector18:
  pushl $0
8010650e:	6a 00                	push   $0x0
  pushl $18
80106510:	6a 12                	push   $0x12
  jmp alltraps
80106512:	e9 e0 f8 ff ff       	jmp    80105df7 <alltraps>

80106517 <vector19>:
.globl vector19
vector19:
  pushl $0
80106517:	6a 00                	push   $0x0
  pushl $19
80106519:	6a 13                	push   $0x13
  jmp alltraps
8010651b:	e9 d7 f8 ff ff       	jmp    80105df7 <alltraps>

80106520 <vector20>:
.globl vector20
vector20:
  pushl $0
80106520:	6a 00                	push   $0x0
  pushl $20
80106522:	6a 14                	push   $0x14
  jmp alltraps
80106524:	e9 ce f8 ff ff       	jmp    80105df7 <alltraps>

80106529 <vector21>:
.globl vector21
vector21:
  pushl $0
80106529:	6a 00                	push   $0x0
  pushl $21
8010652b:	6a 15                	push   $0x15
  jmp alltraps
8010652d:	e9 c5 f8 ff ff       	jmp    80105df7 <alltraps>

80106532 <vector22>:
.globl vector22
vector22:
  pushl $0
80106532:	6a 00                	push   $0x0
  pushl $22
80106534:	6a 16                	push   $0x16
  jmp alltraps
80106536:	e9 bc f8 ff ff       	jmp    80105df7 <alltraps>

8010653b <vector23>:
.globl vector23
vector23:
  pushl $0
8010653b:	6a 00                	push   $0x0
  pushl $23
8010653d:	6a 17                	push   $0x17
  jmp alltraps
8010653f:	e9 b3 f8 ff ff       	jmp    80105df7 <alltraps>

80106544 <vector24>:
.globl vector24
vector24:
  pushl $0
80106544:	6a 00                	push   $0x0
  pushl $24
80106546:	6a 18                	push   $0x18
  jmp alltraps
80106548:	e9 aa f8 ff ff       	jmp    80105df7 <alltraps>

8010654d <vector25>:
.globl vector25
vector25:
  pushl $0
8010654d:	6a 00                	push   $0x0
  pushl $25
8010654f:	6a 19                	push   $0x19
  jmp alltraps
80106551:	e9 a1 f8 ff ff       	jmp    80105df7 <alltraps>

80106556 <vector26>:
.globl vector26
vector26:
  pushl $0
80106556:	6a 00                	push   $0x0
  pushl $26
80106558:	6a 1a                	push   $0x1a
  jmp alltraps
8010655a:	e9 98 f8 ff ff       	jmp    80105df7 <alltraps>

8010655f <vector27>:
.globl vector27
vector27:
  pushl $0
8010655f:	6a 00                	push   $0x0
  pushl $27
80106561:	6a 1b                	push   $0x1b
  jmp alltraps
80106563:	e9 8f f8 ff ff       	jmp    80105df7 <alltraps>

80106568 <vector28>:
.globl vector28
vector28:
  pushl $0
80106568:	6a 00                	push   $0x0
  pushl $28
8010656a:	6a 1c                	push   $0x1c
  jmp alltraps
8010656c:	e9 86 f8 ff ff       	jmp    80105df7 <alltraps>

80106571 <vector29>:
.globl vector29
vector29:
  pushl $0
80106571:	6a 00                	push   $0x0
  pushl $29
80106573:	6a 1d                	push   $0x1d
  jmp alltraps
80106575:	e9 7d f8 ff ff       	jmp    80105df7 <alltraps>

8010657a <vector30>:
.globl vector30
vector30:
  pushl $0
8010657a:	6a 00                	push   $0x0
  pushl $30
8010657c:	6a 1e                	push   $0x1e
  jmp alltraps
8010657e:	e9 74 f8 ff ff       	jmp    80105df7 <alltraps>

80106583 <vector31>:
.globl vector31
vector31:
  pushl $0
80106583:	6a 00                	push   $0x0
  pushl $31
80106585:	6a 1f                	push   $0x1f
  jmp alltraps
80106587:	e9 6b f8 ff ff       	jmp    80105df7 <alltraps>

8010658c <vector32>:
.globl vector32
vector32:
  pushl $0
8010658c:	6a 00                	push   $0x0
  pushl $32
8010658e:	6a 20                	push   $0x20
  jmp alltraps
80106590:	e9 62 f8 ff ff       	jmp    80105df7 <alltraps>

80106595 <vector33>:
.globl vector33
vector33:
  pushl $0
80106595:	6a 00                	push   $0x0
  pushl $33
80106597:	6a 21                	push   $0x21
  jmp alltraps
80106599:	e9 59 f8 ff ff       	jmp    80105df7 <alltraps>

8010659e <vector34>:
.globl vector34
vector34:
  pushl $0
8010659e:	6a 00                	push   $0x0
  pushl $34
801065a0:	6a 22                	push   $0x22
  jmp alltraps
801065a2:	e9 50 f8 ff ff       	jmp    80105df7 <alltraps>

801065a7 <vector35>:
.globl vector35
vector35:
  pushl $0
801065a7:	6a 00                	push   $0x0
  pushl $35
801065a9:	6a 23                	push   $0x23
  jmp alltraps
801065ab:	e9 47 f8 ff ff       	jmp    80105df7 <alltraps>

801065b0 <vector36>:
.globl vector36
vector36:
  pushl $0
801065b0:	6a 00                	push   $0x0
  pushl $36
801065b2:	6a 24                	push   $0x24
  jmp alltraps
801065b4:	e9 3e f8 ff ff       	jmp    80105df7 <alltraps>

801065b9 <vector37>:
.globl vector37
vector37:
  pushl $0
801065b9:	6a 00                	push   $0x0
  pushl $37
801065bb:	6a 25                	push   $0x25
  jmp alltraps
801065bd:	e9 35 f8 ff ff       	jmp    80105df7 <alltraps>

801065c2 <vector38>:
.globl vector38
vector38:
  pushl $0
801065c2:	6a 00                	push   $0x0
  pushl $38
801065c4:	6a 26                	push   $0x26
  jmp alltraps
801065c6:	e9 2c f8 ff ff       	jmp    80105df7 <alltraps>

801065cb <vector39>:
.globl vector39
vector39:
  pushl $0
801065cb:	6a 00                	push   $0x0
  pushl $39
801065cd:	6a 27                	push   $0x27
  jmp alltraps
801065cf:	e9 23 f8 ff ff       	jmp    80105df7 <alltraps>

801065d4 <vector40>:
.globl vector40
vector40:
  pushl $0
801065d4:	6a 00                	push   $0x0
  pushl $40
801065d6:	6a 28                	push   $0x28
  jmp alltraps
801065d8:	e9 1a f8 ff ff       	jmp    80105df7 <alltraps>

801065dd <vector41>:
.globl vector41
vector41:
  pushl $0
801065dd:	6a 00                	push   $0x0
  pushl $41
801065df:	6a 29                	push   $0x29
  jmp alltraps
801065e1:	e9 11 f8 ff ff       	jmp    80105df7 <alltraps>

801065e6 <vector42>:
.globl vector42
vector42:
  pushl $0
801065e6:	6a 00                	push   $0x0
  pushl $42
801065e8:	6a 2a                	push   $0x2a
  jmp alltraps
801065ea:	e9 08 f8 ff ff       	jmp    80105df7 <alltraps>

801065ef <vector43>:
.globl vector43
vector43:
  pushl $0
801065ef:	6a 00                	push   $0x0
  pushl $43
801065f1:	6a 2b                	push   $0x2b
  jmp alltraps
801065f3:	e9 ff f7 ff ff       	jmp    80105df7 <alltraps>

801065f8 <vector44>:
.globl vector44
vector44:
  pushl $0
801065f8:	6a 00                	push   $0x0
  pushl $44
801065fa:	6a 2c                	push   $0x2c
  jmp alltraps
801065fc:	e9 f6 f7 ff ff       	jmp    80105df7 <alltraps>

80106601 <vector45>:
.globl vector45
vector45:
  pushl $0
80106601:	6a 00                	push   $0x0
  pushl $45
80106603:	6a 2d                	push   $0x2d
  jmp alltraps
80106605:	e9 ed f7 ff ff       	jmp    80105df7 <alltraps>

8010660a <vector46>:
.globl vector46
vector46:
  pushl $0
8010660a:	6a 00                	push   $0x0
  pushl $46
8010660c:	6a 2e                	push   $0x2e
  jmp alltraps
8010660e:	e9 e4 f7 ff ff       	jmp    80105df7 <alltraps>

80106613 <vector47>:
.globl vector47
vector47:
  pushl $0
80106613:	6a 00                	push   $0x0
  pushl $47
80106615:	6a 2f                	push   $0x2f
  jmp alltraps
80106617:	e9 db f7 ff ff       	jmp    80105df7 <alltraps>

8010661c <vector48>:
.globl vector48
vector48:
  pushl $0
8010661c:	6a 00                	push   $0x0
  pushl $48
8010661e:	6a 30                	push   $0x30
  jmp alltraps
80106620:	e9 d2 f7 ff ff       	jmp    80105df7 <alltraps>

80106625 <vector49>:
.globl vector49
vector49:
  pushl $0
80106625:	6a 00                	push   $0x0
  pushl $49
80106627:	6a 31                	push   $0x31
  jmp alltraps
80106629:	e9 c9 f7 ff ff       	jmp    80105df7 <alltraps>

8010662e <vector50>:
.globl vector50
vector50:
  pushl $0
8010662e:	6a 00                	push   $0x0
  pushl $50
80106630:	6a 32                	push   $0x32
  jmp alltraps
80106632:	e9 c0 f7 ff ff       	jmp    80105df7 <alltraps>

80106637 <vector51>:
.globl vector51
vector51:
  pushl $0
80106637:	6a 00                	push   $0x0
  pushl $51
80106639:	6a 33                	push   $0x33
  jmp alltraps
8010663b:	e9 b7 f7 ff ff       	jmp    80105df7 <alltraps>

80106640 <vector52>:
.globl vector52
vector52:
  pushl $0
80106640:	6a 00                	push   $0x0
  pushl $52
80106642:	6a 34                	push   $0x34
  jmp alltraps
80106644:	e9 ae f7 ff ff       	jmp    80105df7 <alltraps>

80106649 <vector53>:
.globl vector53
vector53:
  pushl $0
80106649:	6a 00                	push   $0x0
  pushl $53
8010664b:	6a 35                	push   $0x35
  jmp alltraps
8010664d:	e9 a5 f7 ff ff       	jmp    80105df7 <alltraps>

80106652 <vector54>:
.globl vector54
vector54:
  pushl $0
80106652:	6a 00                	push   $0x0
  pushl $54
80106654:	6a 36                	push   $0x36
  jmp alltraps
80106656:	e9 9c f7 ff ff       	jmp    80105df7 <alltraps>

8010665b <vector55>:
.globl vector55
vector55:
  pushl $0
8010665b:	6a 00                	push   $0x0
  pushl $55
8010665d:	6a 37                	push   $0x37
  jmp alltraps
8010665f:	e9 93 f7 ff ff       	jmp    80105df7 <alltraps>

80106664 <vector56>:
.globl vector56
vector56:
  pushl $0
80106664:	6a 00                	push   $0x0
  pushl $56
80106666:	6a 38                	push   $0x38
  jmp alltraps
80106668:	e9 8a f7 ff ff       	jmp    80105df7 <alltraps>

8010666d <vector57>:
.globl vector57
vector57:
  pushl $0
8010666d:	6a 00                	push   $0x0
  pushl $57
8010666f:	6a 39                	push   $0x39
  jmp alltraps
80106671:	e9 81 f7 ff ff       	jmp    80105df7 <alltraps>

80106676 <vector58>:
.globl vector58
vector58:
  pushl $0
80106676:	6a 00                	push   $0x0
  pushl $58
80106678:	6a 3a                	push   $0x3a
  jmp alltraps
8010667a:	e9 78 f7 ff ff       	jmp    80105df7 <alltraps>

8010667f <vector59>:
.globl vector59
vector59:
  pushl $0
8010667f:	6a 00                	push   $0x0
  pushl $59
80106681:	6a 3b                	push   $0x3b
  jmp alltraps
80106683:	e9 6f f7 ff ff       	jmp    80105df7 <alltraps>

80106688 <vector60>:
.globl vector60
vector60:
  pushl $0
80106688:	6a 00                	push   $0x0
  pushl $60
8010668a:	6a 3c                	push   $0x3c
  jmp alltraps
8010668c:	e9 66 f7 ff ff       	jmp    80105df7 <alltraps>

80106691 <vector61>:
.globl vector61
vector61:
  pushl $0
80106691:	6a 00                	push   $0x0
  pushl $61
80106693:	6a 3d                	push   $0x3d
  jmp alltraps
80106695:	e9 5d f7 ff ff       	jmp    80105df7 <alltraps>

8010669a <vector62>:
.globl vector62
vector62:
  pushl $0
8010669a:	6a 00                	push   $0x0
  pushl $62
8010669c:	6a 3e                	push   $0x3e
  jmp alltraps
8010669e:	e9 54 f7 ff ff       	jmp    80105df7 <alltraps>

801066a3 <vector63>:
.globl vector63
vector63:
  pushl $0
801066a3:	6a 00                	push   $0x0
  pushl $63
801066a5:	6a 3f                	push   $0x3f
  jmp alltraps
801066a7:	e9 4b f7 ff ff       	jmp    80105df7 <alltraps>

801066ac <vector64>:
.globl vector64
vector64:
  pushl $0
801066ac:	6a 00                	push   $0x0
  pushl $64
801066ae:	6a 40                	push   $0x40
  jmp alltraps
801066b0:	e9 42 f7 ff ff       	jmp    80105df7 <alltraps>

801066b5 <vector65>:
.globl vector65
vector65:
  pushl $0
801066b5:	6a 00                	push   $0x0
  pushl $65
801066b7:	6a 41                	push   $0x41
  jmp alltraps
801066b9:	e9 39 f7 ff ff       	jmp    80105df7 <alltraps>

801066be <vector66>:
.globl vector66
vector66:
  pushl $0
801066be:	6a 00                	push   $0x0
  pushl $66
801066c0:	6a 42                	push   $0x42
  jmp alltraps
801066c2:	e9 30 f7 ff ff       	jmp    80105df7 <alltraps>

801066c7 <vector67>:
.globl vector67
vector67:
  pushl $0
801066c7:	6a 00                	push   $0x0
  pushl $67
801066c9:	6a 43                	push   $0x43
  jmp alltraps
801066cb:	e9 27 f7 ff ff       	jmp    80105df7 <alltraps>

801066d0 <vector68>:
.globl vector68
vector68:
  pushl $0
801066d0:	6a 00                	push   $0x0
  pushl $68
801066d2:	6a 44                	push   $0x44
  jmp alltraps
801066d4:	e9 1e f7 ff ff       	jmp    80105df7 <alltraps>

801066d9 <vector69>:
.globl vector69
vector69:
  pushl $0
801066d9:	6a 00                	push   $0x0
  pushl $69
801066db:	6a 45                	push   $0x45
  jmp alltraps
801066dd:	e9 15 f7 ff ff       	jmp    80105df7 <alltraps>

801066e2 <vector70>:
.globl vector70
vector70:
  pushl $0
801066e2:	6a 00                	push   $0x0
  pushl $70
801066e4:	6a 46                	push   $0x46
  jmp alltraps
801066e6:	e9 0c f7 ff ff       	jmp    80105df7 <alltraps>

801066eb <vector71>:
.globl vector71
vector71:
  pushl $0
801066eb:	6a 00                	push   $0x0
  pushl $71
801066ed:	6a 47                	push   $0x47
  jmp alltraps
801066ef:	e9 03 f7 ff ff       	jmp    80105df7 <alltraps>

801066f4 <vector72>:
.globl vector72
vector72:
  pushl $0
801066f4:	6a 00                	push   $0x0
  pushl $72
801066f6:	6a 48                	push   $0x48
  jmp alltraps
801066f8:	e9 fa f6 ff ff       	jmp    80105df7 <alltraps>

801066fd <vector73>:
.globl vector73
vector73:
  pushl $0
801066fd:	6a 00                	push   $0x0
  pushl $73
801066ff:	6a 49                	push   $0x49
  jmp alltraps
80106701:	e9 f1 f6 ff ff       	jmp    80105df7 <alltraps>

80106706 <vector74>:
.globl vector74
vector74:
  pushl $0
80106706:	6a 00                	push   $0x0
  pushl $74
80106708:	6a 4a                	push   $0x4a
  jmp alltraps
8010670a:	e9 e8 f6 ff ff       	jmp    80105df7 <alltraps>

8010670f <vector75>:
.globl vector75
vector75:
  pushl $0
8010670f:	6a 00                	push   $0x0
  pushl $75
80106711:	6a 4b                	push   $0x4b
  jmp alltraps
80106713:	e9 df f6 ff ff       	jmp    80105df7 <alltraps>

80106718 <vector76>:
.globl vector76
vector76:
  pushl $0
80106718:	6a 00                	push   $0x0
  pushl $76
8010671a:	6a 4c                	push   $0x4c
  jmp alltraps
8010671c:	e9 d6 f6 ff ff       	jmp    80105df7 <alltraps>

80106721 <vector77>:
.globl vector77
vector77:
  pushl $0
80106721:	6a 00                	push   $0x0
  pushl $77
80106723:	6a 4d                	push   $0x4d
  jmp alltraps
80106725:	e9 cd f6 ff ff       	jmp    80105df7 <alltraps>

8010672a <vector78>:
.globl vector78
vector78:
  pushl $0
8010672a:	6a 00                	push   $0x0
  pushl $78
8010672c:	6a 4e                	push   $0x4e
  jmp alltraps
8010672e:	e9 c4 f6 ff ff       	jmp    80105df7 <alltraps>

80106733 <vector79>:
.globl vector79
vector79:
  pushl $0
80106733:	6a 00                	push   $0x0
  pushl $79
80106735:	6a 4f                	push   $0x4f
  jmp alltraps
80106737:	e9 bb f6 ff ff       	jmp    80105df7 <alltraps>

8010673c <vector80>:
.globl vector80
vector80:
  pushl $0
8010673c:	6a 00                	push   $0x0
  pushl $80
8010673e:	6a 50                	push   $0x50
  jmp alltraps
80106740:	e9 b2 f6 ff ff       	jmp    80105df7 <alltraps>

80106745 <vector81>:
.globl vector81
vector81:
  pushl $0
80106745:	6a 00                	push   $0x0
  pushl $81
80106747:	6a 51                	push   $0x51
  jmp alltraps
80106749:	e9 a9 f6 ff ff       	jmp    80105df7 <alltraps>

8010674e <vector82>:
.globl vector82
vector82:
  pushl $0
8010674e:	6a 00                	push   $0x0
  pushl $82
80106750:	6a 52                	push   $0x52
  jmp alltraps
80106752:	e9 a0 f6 ff ff       	jmp    80105df7 <alltraps>

80106757 <vector83>:
.globl vector83
vector83:
  pushl $0
80106757:	6a 00                	push   $0x0
  pushl $83
80106759:	6a 53                	push   $0x53
  jmp alltraps
8010675b:	e9 97 f6 ff ff       	jmp    80105df7 <alltraps>

80106760 <vector84>:
.globl vector84
vector84:
  pushl $0
80106760:	6a 00                	push   $0x0
  pushl $84
80106762:	6a 54                	push   $0x54
  jmp alltraps
80106764:	e9 8e f6 ff ff       	jmp    80105df7 <alltraps>

80106769 <vector85>:
.globl vector85
vector85:
  pushl $0
80106769:	6a 00                	push   $0x0
  pushl $85
8010676b:	6a 55                	push   $0x55
  jmp alltraps
8010676d:	e9 85 f6 ff ff       	jmp    80105df7 <alltraps>

80106772 <vector86>:
.globl vector86
vector86:
  pushl $0
80106772:	6a 00                	push   $0x0
  pushl $86
80106774:	6a 56                	push   $0x56
  jmp alltraps
80106776:	e9 7c f6 ff ff       	jmp    80105df7 <alltraps>

8010677b <vector87>:
.globl vector87
vector87:
  pushl $0
8010677b:	6a 00                	push   $0x0
  pushl $87
8010677d:	6a 57                	push   $0x57
  jmp alltraps
8010677f:	e9 73 f6 ff ff       	jmp    80105df7 <alltraps>

80106784 <vector88>:
.globl vector88
vector88:
  pushl $0
80106784:	6a 00                	push   $0x0
  pushl $88
80106786:	6a 58                	push   $0x58
  jmp alltraps
80106788:	e9 6a f6 ff ff       	jmp    80105df7 <alltraps>

8010678d <vector89>:
.globl vector89
vector89:
  pushl $0
8010678d:	6a 00                	push   $0x0
  pushl $89
8010678f:	6a 59                	push   $0x59
  jmp alltraps
80106791:	e9 61 f6 ff ff       	jmp    80105df7 <alltraps>

80106796 <vector90>:
.globl vector90
vector90:
  pushl $0
80106796:	6a 00                	push   $0x0
  pushl $90
80106798:	6a 5a                	push   $0x5a
  jmp alltraps
8010679a:	e9 58 f6 ff ff       	jmp    80105df7 <alltraps>

8010679f <vector91>:
.globl vector91
vector91:
  pushl $0
8010679f:	6a 00                	push   $0x0
  pushl $91
801067a1:	6a 5b                	push   $0x5b
  jmp alltraps
801067a3:	e9 4f f6 ff ff       	jmp    80105df7 <alltraps>

801067a8 <vector92>:
.globl vector92
vector92:
  pushl $0
801067a8:	6a 00                	push   $0x0
  pushl $92
801067aa:	6a 5c                	push   $0x5c
  jmp alltraps
801067ac:	e9 46 f6 ff ff       	jmp    80105df7 <alltraps>

801067b1 <vector93>:
.globl vector93
vector93:
  pushl $0
801067b1:	6a 00                	push   $0x0
  pushl $93
801067b3:	6a 5d                	push   $0x5d
  jmp alltraps
801067b5:	e9 3d f6 ff ff       	jmp    80105df7 <alltraps>

801067ba <vector94>:
.globl vector94
vector94:
  pushl $0
801067ba:	6a 00                	push   $0x0
  pushl $94
801067bc:	6a 5e                	push   $0x5e
  jmp alltraps
801067be:	e9 34 f6 ff ff       	jmp    80105df7 <alltraps>

801067c3 <vector95>:
.globl vector95
vector95:
  pushl $0
801067c3:	6a 00                	push   $0x0
  pushl $95
801067c5:	6a 5f                	push   $0x5f
  jmp alltraps
801067c7:	e9 2b f6 ff ff       	jmp    80105df7 <alltraps>

801067cc <vector96>:
.globl vector96
vector96:
  pushl $0
801067cc:	6a 00                	push   $0x0
  pushl $96
801067ce:	6a 60                	push   $0x60
  jmp alltraps
801067d0:	e9 22 f6 ff ff       	jmp    80105df7 <alltraps>

801067d5 <vector97>:
.globl vector97
vector97:
  pushl $0
801067d5:	6a 00                	push   $0x0
  pushl $97
801067d7:	6a 61                	push   $0x61
  jmp alltraps
801067d9:	e9 19 f6 ff ff       	jmp    80105df7 <alltraps>

801067de <vector98>:
.globl vector98
vector98:
  pushl $0
801067de:	6a 00                	push   $0x0
  pushl $98
801067e0:	6a 62                	push   $0x62
  jmp alltraps
801067e2:	e9 10 f6 ff ff       	jmp    80105df7 <alltraps>

801067e7 <vector99>:
.globl vector99
vector99:
  pushl $0
801067e7:	6a 00                	push   $0x0
  pushl $99
801067e9:	6a 63                	push   $0x63
  jmp alltraps
801067eb:	e9 07 f6 ff ff       	jmp    80105df7 <alltraps>

801067f0 <vector100>:
.globl vector100
vector100:
  pushl $0
801067f0:	6a 00                	push   $0x0
  pushl $100
801067f2:	6a 64                	push   $0x64
  jmp alltraps
801067f4:	e9 fe f5 ff ff       	jmp    80105df7 <alltraps>

801067f9 <vector101>:
.globl vector101
vector101:
  pushl $0
801067f9:	6a 00                	push   $0x0
  pushl $101
801067fb:	6a 65                	push   $0x65
  jmp alltraps
801067fd:	e9 f5 f5 ff ff       	jmp    80105df7 <alltraps>

80106802 <vector102>:
.globl vector102
vector102:
  pushl $0
80106802:	6a 00                	push   $0x0
  pushl $102
80106804:	6a 66                	push   $0x66
  jmp alltraps
80106806:	e9 ec f5 ff ff       	jmp    80105df7 <alltraps>

8010680b <vector103>:
.globl vector103
vector103:
  pushl $0
8010680b:	6a 00                	push   $0x0
  pushl $103
8010680d:	6a 67                	push   $0x67
  jmp alltraps
8010680f:	e9 e3 f5 ff ff       	jmp    80105df7 <alltraps>

80106814 <vector104>:
.globl vector104
vector104:
  pushl $0
80106814:	6a 00                	push   $0x0
  pushl $104
80106816:	6a 68                	push   $0x68
  jmp alltraps
80106818:	e9 da f5 ff ff       	jmp    80105df7 <alltraps>

8010681d <vector105>:
.globl vector105
vector105:
  pushl $0
8010681d:	6a 00                	push   $0x0
  pushl $105
8010681f:	6a 69                	push   $0x69
  jmp alltraps
80106821:	e9 d1 f5 ff ff       	jmp    80105df7 <alltraps>

80106826 <vector106>:
.globl vector106
vector106:
  pushl $0
80106826:	6a 00                	push   $0x0
  pushl $106
80106828:	6a 6a                	push   $0x6a
  jmp alltraps
8010682a:	e9 c8 f5 ff ff       	jmp    80105df7 <alltraps>

8010682f <vector107>:
.globl vector107
vector107:
  pushl $0
8010682f:	6a 00                	push   $0x0
  pushl $107
80106831:	6a 6b                	push   $0x6b
  jmp alltraps
80106833:	e9 bf f5 ff ff       	jmp    80105df7 <alltraps>

80106838 <vector108>:
.globl vector108
vector108:
  pushl $0
80106838:	6a 00                	push   $0x0
  pushl $108
8010683a:	6a 6c                	push   $0x6c
  jmp alltraps
8010683c:	e9 b6 f5 ff ff       	jmp    80105df7 <alltraps>

80106841 <vector109>:
.globl vector109
vector109:
  pushl $0
80106841:	6a 00                	push   $0x0
  pushl $109
80106843:	6a 6d                	push   $0x6d
  jmp alltraps
80106845:	e9 ad f5 ff ff       	jmp    80105df7 <alltraps>

8010684a <vector110>:
.globl vector110
vector110:
  pushl $0
8010684a:	6a 00                	push   $0x0
  pushl $110
8010684c:	6a 6e                	push   $0x6e
  jmp alltraps
8010684e:	e9 a4 f5 ff ff       	jmp    80105df7 <alltraps>

80106853 <vector111>:
.globl vector111
vector111:
  pushl $0
80106853:	6a 00                	push   $0x0
  pushl $111
80106855:	6a 6f                	push   $0x6f
  jmp alltraps
80106857:	e9 9b f5 ff ff       	jmp    80105df7 <alltraps>

8010685c <vector112>:
.globl vector112
vector112:
  pushl $0
8010685c:	6a 00                	push   $0x0
  pushl $112
8010685e:	6a 70                	push   $0x70
  jmp alltraps
80106860:	e9 92 f5 ff ff       	jmp    80105df7 <alltraps>

80106865 <vector113>:
.globl vector113
vector113:
  pushl $0
80106865:	6a 00                	push   $0x0
  pushl $113
80106867:	6a 71                	push   $0x71
  jmp alltraps
80106869:	e9 89 f5 ff ff       	jmp    80105df7 <alltraps>

8010686e <vector114>:
.globl vector114
vector114:
  pushl $0
8010686e:	6a 00                	push   $0x0
  pushl $114
80106870:	6a 72                	push   $0x72
  jmp alltraps
80106872:	e9 80 f5 ff ff       	jmp    80105df7 <alltraps>

80106877 <vector115>:
.globl vector115
vector115:
  pushl $0
80106877:	6a 00                	push   $0x0
  pushl $115
80106879:	6a 73                	push   $0x73
  jmp alltraps
8010687b:	e9 77 f5 ff ff       	jmp    80105df7 <alltraps>

80106880 <vector116>:
.globl vector116
vector116:
  pushl $0
80106880:	6a 00                	push   $0x0
  pushl $116
80106882:	6a 74                	push   $0x74
  jmp alltraps
80106884:	e9 6e f5 ff ff       	jmp    80105df7 <alltraps>

80106889 <vector117>:
.globl vector117
vector117:
  pushl $0
80106889:	6a 00                	push   $0x0
  pushl $117
8010688b:	6a 75                	push   $0x75
  jmp alltraps
8010688d:	e9 65 f5 ff ff       	jmp    80105df7 <alltraps>

80106892 <vector118>:
.globl vector118
vector118:
  pushl $0
80106892:	6a 00                	push   $0x0
  pushl $118
80106894:	6a 76                	push   $0x76
  jmp alltraps
80106896:	e9 5c f5 ff ff       	jmp    80105df7 <alltraps>

8010689b <vector119>:
.globl vector119
vector119:
  pushl $0
8010689b:	6a 00                	push   $0x0
  pushl $119
8010689d:	6a 77                	push   $0x77
  jmp alltraps
8010689f:	e9 53 f5 ff ff       	jmp    80105df7 <alltraps>

801068a4 <vector120>:
.globl vector120
vector120:
  pushl $0
801068a4:	6a 00                	push   $0x0
  pushl $120
801068a6:	6a 78                	push   $0x78
  jmp alltraps
801068a8:	e9 4a f5 ff ff       	jmp    80105df7 <alltraps>

801068ad <vector121>:
.globl vector121
vector121:
  pushl $0
801068ad:	6a 00                	push   $0x0
  pushl $121
801068af:	6a 79                	push   $0x79
  jmp alltraps
801068b1:	e9 41 f5 ff ff       	jmp    80105df7 <alltraps>

801068b6 <vector122>:
.globl vector122
vector122:
  pushl $0
801068b6:	6a 00                	push   $0x0
  pushl $122
801068b8:	6a 7a                	push   $0x7a
  jmp alltraps
801068ba:	e9 38 f5 ff ff       	jmp    80105df7 <alltraps>

801068bf <vector123>:
.globl vector123
vector123:
  pushl $0
801068bf:	6a 00                	push   $0x0
  pushl $123
801068c1:	6a 7b                	push   $0x7b
  jmp alltraps
801068c3:	e9 2f f5 ff ff       	jmp    80105df7 <alltraps>

801068c8 <vector124>:
.globl vector124
vector124:
  pushl $0
801068c8:	6a 00                	push   $0x0
  pushl $124
801068ca:	6a 7c                	push   $0x7c
  jmp alltraps
801068cc:	e9 26 f5 ff ff       	jmp    80105df7 <alltraps>

801068d1 <vector125>:
.globl vector125
vector125:
  pushl $0
801068d1:	6a 00                	push   $0x0
  pushl $125
801068d3:	6a 7d                	push   $0x7d
  jmp alltraps
801068d5:	e9 1d f5 ff ff       	jmp    80105df7 <alltraps>

801068da <vector126>:
.globl vector126
vector126:
  pushl $0
801068da:	6a 00                	push   $0x0
  pushl $126
801068dc:	6a 7e                	push   $0x7e
  jmp alltraps
801068de:	e9 14 f5 ff ff       	jmp    80105df7 <alltraps>

801068e3 <vector127>:
.globl vector127
vector127:
  pushl $0
801068e3:	6a 00                	push   $0x0
  pushl $127
801068e5:	6a 7f                	push   $0x7f
  jmp alltraps
801068e7:	e9 0b f5 ff ff       	jmp    80105df7 <alltraps>

801068ec <vector128>:
.globl vector128
vector128:
  pushl $0
801068ec:	6a 00                	push   $0x0
  pushl $128
801068ee:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801068f3:	e9 ff f4 ff ff       	jmp    80105df7 <alltraps>

801068f8 <vector129>:
.globl vector129
vector129:
  pushl $0
801068f8:	6a 00                	push   $0x0
  pushl $129
801068fa:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801068ff:	e9 f3 f4 ff ff       	jmp    80105df7 <alltraps>

80106904 <vector130>:
.globl vector130
vector130:
  pushl $0
80106904:	6a 00                	push   $0x0
  pushl $130
80106906:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010690b:	e9 e7 f4 ff ff       	jmp    80105df7 <alltraps>

80106910 <vector131>:
.globl vector131
vector131:
  pushl $0
80106910:	6a 00                	push   $0x0
  pushl $131
80106912:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106917:	e9 db f4 ff ff       	jmp    80105df7 <alltraps>

8010691c <vector132>:
.globl vector132
vector132:
  pushl $0
8010691c:	6a 00                	push   $0x0
  pushl $132
8010691e:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106923:	e9 cf f4 ff ff       	jmp    80105df7 <alltraps>

80106928 <vector133>:
.globl vector133
vector133:
  pushl $0
80106928:	6a 00                	push   $0x0
  pushl $133
8010692a:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010692f:	e9 c3 f4 ff ff       	jmp    80105df7 <alltraps>

80106934 <vector134>:
.globl vector134
vector134:
  pushl $0
80106934:	6a 00                	push   $0x0
  pushl $134
80106936:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010693b:	e9 b7 f4 ff ff       	jmp    80105df7 <alltraps>

80106940 <vector135>:
.globl vector135
vector135:
  pushl $0
80106940:	6a 00                	push   $0x0
  pushl $135
80106942:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106947:	e9 ab f4 ff ff       	jmp    80105df7 <alltraps>

8010694c <vector136>:
.globl vector136
vector136:
  pushl $0
8010694c:	6a 00                	push   $0x0
  pushl $136
8010694e:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106953:	e9 9f f4 ff ff       	jmp    80105df7 <alltraps>

80106958 <vector137>:
.globl vector137
vector137:
  pushl $0
80106958:	6a 00                	push   $0x0
  pushl $137
8010695a:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010695f:	e9 93 f4 ff ff       	jmp    80105df7 <alltraps>

80106964 <vector138>:
.globl vector138
vector138:
  pushl $0
80106964:	6a 00                	push   $0x0
  pushl $138
80106966:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010696b:	e9 87 f4 ff ff       	jmp    80105df7 <alltraps>

80106970 <vector139>:
.globl vector139
vector139:
  pushl $0
80106970:	6a 00                	push   $0x0
  pushl $139
80106972:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106977:	e9 7b f4 ff ff       	jmp    80105df7 <alltraps>

8010697c <vector140>:
.globl vector140
vector140:
  pushl $0
8010697c:	6a 00                	push   $0x0
  pushl $140
8010697e:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106983:	e9 6f f4 ff ff       	jmp    80105df7 <alltraps>

80106988 <vector141>:
.globl vector141
vector141:
  pushl $0
80106988:	6a 00                	push   $0x0
  pushl $141
8010698a:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010698f:	e9 63 f4 ff ff       	jmp    80105df7 <alltraps>

80106994 <vector142>:
.globl vector142
vector142:
  pushl $0
80106994:	6a 00                	push   $0x0
  pushl $142
80106996:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010699b:	e9 57 f4 ff ff       	jmp    80105df7 <alltraps>

801069a0 <vector143>:
.globl vector143
vector143:
  pushl $0
801069a0:	6a 00                	push   $0x0
  pushl $143
801069a2:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801069a7:	e9 4b f4 ff ff       	jmp    80105df7 <alltraps>

801069ac <vector144>:
.globl vector144
vector144:
  pushl $0
801069ac:	6a 00                	push   $0x0
  pushl $144
801069ae:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801069b3:	e9 3f f4 ff ff       	jmp    80105df7 <alltraps>

801069b8 <vector145>:
.globl vector145
vector145:
  pushl $0
801069b8:	6a 00                	push   $0x0
  pushl $145
801069ba:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801069bf:	e9 33 f4 ff ff       	jmp    80105df7 <alltraps>

801069c4 <vector146>:
.globl vector146
vector146:
  pushl $0
801069c4:	6a 00                	push   $0x0
  pushl $146
801069c6:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801069cb:	e9 27 f4 ff ff       	jmp    80105df7 <alltraps>

801069d0 <vector147>:
.globl vector147
vector147:
  pushl $0
801069d0:	6a 00                	push   $0x0
  pushl $147
801069d2:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801069d7:	e9 1b f4 ff ff       	jmp    80105df7 <alltraps>

801069dc <vector148>:
.globl vector148
vector148:
  pushl $0
801069dc:	6a 00                	push   $0x0
  pushl $148
801069de:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801069e3:	e9 0f f4 ff ff       	jmp    80105df7 <alltraps>

801069e8 <vector149>:
.globl vector149
vector149:
  pushl $0
801069e8:	6a 00                	push   $0x0
  pushl $149
801069ea:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801069ef:	e9 03 f4 ff ff       	jmp    80105df7 <alltraps>

801069f4 <vector150>:
.globl vector150
vector150:
  pushl $0
801069f4:	6a 00                	push   $0x0
  pushl $150
801069f6:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801069fb:	e9 f7 f3 ff ff       	jmp    80105df7 <alltraps>

80106a00 <vector151>:
.globl vector151
vector151:
  pushl $0
80106a00:	6a 00                	push   $0x0
  pushl $151
80106a02:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106a07:	e9 eb f3 ff ff       	jmp    80105df7 <alltraps>

80106a0c <vector152>:
.globl vector152
vector152:
  pushl $0
80106a0c:	6a 00                	push   $0x0
  pushl $152
80106a0e:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106a13:	e9 df f3 ff ff       	jmp    80105df7 <alltraps>

80106a18 <vector153>:
.globl vector153
vector153:
  pushl $0
80106a18:	6a 00                	push   $0x0
  pushl $153
80106a1a:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106a1f:	e9 d3 f3 ff ff       	jmp    80105df7 <alltraps>

80106a24 <vector154>:
.globl vector154
vector154:
  pushl $0
80106a24:	6a 00                	push   $0x0
  pushl $154
80106a26:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106a2b:	e9 c7 f3 ff ff       	jmp    80105df7 <alltraps>

80106a30 <vector155>:
.globl vector155
vector155:
  pushl $0
80106a30:	6a 00                	push   $0x0
  pushl $155
80106a32:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106a37:	e9 bb f3 ff ff       	jmp    80105df7 <alltraps>

80106a3c <vector156>:
.globl vector156
vector156:
  pushl $0
80106a3c:	6a 00                	push   $0x0
  pushl $156
80106a3e:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106a43:	e9 af f3 ff ff       	jmp    80105df7 <alltraps>

80106a48 <vector157>:
.globl vector157
vector157:
  pushl $0
80106a48:	6a 00                	push   $0x0
  pushl $157
80106a4a:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106a4f:	e9 a3 f3 ff ff       	jmp    80105df7 <alltraps>

80106a54 <vector158>:
.globl vector158
vector158:
  pushl $0
80106a54:	6a 00                	push   $0x0
  pushl $158
80106a56:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106a5b:	e9 97 f3 ff ff       	jmp    80105df7 <alltraps>

80106a60 <vector159>:
.globl vector159
vector159:
  pushl $0
80106a60:	6a 00                	push   $0x0
  pushl $159
80106a62:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106a67:	e9 8b f3 ff ff       	jmp    80105df7 <alltraps>

80106a6c <vector160>:
.globl vector160
vector160:
  pushl $0
80106a6c:	6a 00                	push   $0x0
  pushl $160
80106a6e:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106a73:	e9 7f f3 ff ff       	jmp    80105df7 <alltraps>

80106a78 <vector161>:
.globl vector161
vector161:
  pushl $0
80106a78:	6a 00                	push   $0x0
  pushl $161
80106a7a:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106a7f:	e9 73 f3 ff ff       	jmp    80105df7 <alltraps>

80106a84 <vector162>:
.globl vector162
vector162:
  pushl $0
80106a84:	6a 00                	push   $0x0
  pushl $162
80106a86:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106a8b:	e9 67 f3 ff ff       	jmp    80105df7 <alltraps>

80106a90 <vector163>:
.globl vector163
vector163:
  pushl $0
80106a90:	6a 00                	push   $0x0
  pushl $163
80106a92:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106a97:	e9 5b f3 ff ff       	jmp    80105df7 <alltraps>

80106a9c <vector164>:
.globl vector164
vector164:
  pushl $0
80106a9c:	6a 00                	push   $0x0
  pushl $164
80106a9e:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106aa3:	e9 4f f3 ff ff       	jmp    80105df7 <alltraps>

80106aa8 <vector165>:
.globl vector165
vector165:
  pushl $0
80106aa8:	6a 00                	push   $0x0
  pushl $165
80106aaa:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106aaf:	e9 43 f3 ff ff       	jmp    80105df7 <alltraps>

80106ab4 <vector166>:
.globl vector166
vector166:
  pushl $0
80106ab4:	6a 00                	push   $0x0
  pushl $166
80106ab6:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106abb:	e9 37 f3 ff ff       	jmp    80105df7 <alltraps>

80106ac0 <vector167>:
.globl vector167
vector167:
  pushl $0
80106ac0:	6a 00                	push   $0x0
  pushl $167
80106ac2:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106ac7:	e9 2b f3 ff ff       	jmp    80105df7 <alltraps>

80106acc <vector168>:
.globl vector168
vector168:
  pushl $0
80106acc:	6a 00                	push   $0x0
  pushl $168
80106ace:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106ad3:	e9 1f f3 ff ff       	jmp    80105df7 <alltraps>

80106ad8 <vector169>:
.globl vector169
vector169:
  pushl $0
80106ad8:	6a 00                	push   $0x0
  pushl $169
80106ada:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106adf:	e9 13 f3 ff ff       	jmp    80105df7 <alltraps>

80106ae4 <vector170>:
.globl vector170
vector170:
  pushl $0
80106ae4:	6a 00                	push   $0x0
  pushl $170
80106ae6:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106aeb:	e9 07 f3 ff ff       	jmp    80105df7 <alltraps>

80106af0 <vector171>:
.globl vector171
vector171:
  pushl $0
80106af0:	6a 00                	push   $0x0
  pushl $171
80106af2:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106af7:	e9 fb f2 ff ff       	jmp    80105df7 <alltraps>

80106afc <vector172>:
.globl vector172
vector172:
  pushl $0
80106afc:	6a 00                	push   $0x0
  pushl $172
80106afe:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106b03:	e9 ef f2 ff ff       	jmp    80105df7 <alltraps>

80106b08 <vector173>:
.globl vector173
vector173:
  pushl $0
80106b08:	6a 00                	push   $0x0
  pushl $173
80106b0a:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106b0f:	e9 e3 f2 ff ff       	jmp    80105df7 <alltraps>

80106b14 <vector174>:
.globl vector174
vector174:
  pushl $0
80106b14:	6a 00                	push   $0x0
  pushl $174
80106b16:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106b1b:	e9 d7 f2 ff ff       	jmp    80105df7 <alltraps>

80106b20 <vector175>:
.globl vector175
vector175:
  pushl $0
80106b20:	6a 00                	push   $0x0
  pushl $175
80106b22:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106b27:	e9 cb f2 ff ff       	jmp    80105df7 <alltraps>

80106b2c <vector176>:
.globl vector176
vector176:
  pushl $0
80106b2c:	6a 00                	push   $0x0
  pushl $176
80106b2e:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106b33:	e9 bf f2 ff ff       	jmp    80105df7 <alltraps>

80106b38 <vector177>:
.globl vector177
vector177:
  pushl $0
80106b38:	6a 00                	push   $0x0
  pushl $177
80106b3a:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106b3f:	e9 b3 f2 ff ff       	jmp    80105df7 <alltraps>

80106b44 <vector178>:
.globl vector178
vector178:
  pushl $0
80106b44:	6a 00                	push   $0x0
  pushl $178
80106b46:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106b4b:	e9 a7 f2 ff ff       	jmp    80105df7 <alltraps>

80106b50 <vector179>:
.globl vector179
vector179:
  pushl $0
80106b50:	6a 00                	push   $0x0
  pushl $179
80106b52:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106b57:	e9 9b f2 ff ff       	jmp    80105df7 <alltraps>

80106b5c <vector180>:
.globl vector180
vector180:
  pushl $0
80106b5c:	6a 00                	push   $0x0
  pushl $180
80106b5e:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106b63:	e9 8f f2 ff ff       	jmp    80105df7 <alltraps>

80106b68 <vector181>:
.globl vector181
vector181:
  pushl $0
80106b68:	6a 00                	push   $0x0
  pushl $181
80106b6a:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106b6f:	e9 83 f2 ff ff       	jmp    80105df7 <alltraps>

80106b74 <vector182>:
.globl vector182
vector182:
  pushl $0
80106b74:	6a 00                	push   $0x0
  pushl $182
80106b76:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106b7b:	e9 77 f2 ff ff       	jmp    80105df7 <alltraps>

80106b80 <vector183>:
.globl vector183
vector183:
  pushl $0
80106b80:	6a 00                	push   $0x0
  pushl $183
80106b82:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106b87:	e9 6b f2 ff ff       	jmp    80105df7 <alltraps>

80106b8c <vector184>:
.globl vector184
vector184:
  pushl $0
80106b8c:	6a 00                	push   $0x0
  pushl $184
80106b8e:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106b93:	e9 5f f2 ff ff       	jmp    80105df7 <alltraps>

80106b98 <vector185>:
.globl vector185
vector185:
  pushl $0
80106b98:	6a 00                	push   $0x0
  pushl $185
80106b9a:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106b9f:	e9 53 f2 ff ff       	jmp    80105df7 <alltraps>

80106ba4 <vector186>:
.globl vector186
vector186:
  pushl $0
80106ba4:	6a 00                	push   $0x0
  pushl $186
80106ba6:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106bab:	e9 47 f2 ff ff       	jmp    80105df7 <alltraps>

80106bb0 <vector187>:
.globl vector187
vector187:
  pushl $0
80106bb0:	6a 00                	push   $0x0
  pushl $187
80106bb2:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106bb7:	e9 3b f2 ff ff       	jmp    80105df7 <alltraps>

80106bbc <vector188>:
.globl vector188
vector188:
  pushl $0
80106bbc:	6a 00                	push   $0x0
  pushl $188
80106bbe:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106bc3:	e9 2f f2 ff ff       	jmp    80105df7 <alltraps>

80106bc8 <vector189>:
.globl vector189
vector189:
  pushl $0
80106bc8:	6a 00                	push   $0x0
  pushl $189
80106bca:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106bcf:	e9 23 f2 ff ff       	jmp    80105df7 <alltraps>

80106bd4 <vector190>:
.globl vector190
vector190:
  pushl $0
80106bd4:	6a 00                	push   $0x0
  pushl $190
80106bd6:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106bdb:	e9 17 f2 ff ff       	jmp    80105df7 <alltraps>

80106be0 <vector191>:
.globl vector191
vector191:
  pushl $0
80106be0:	6a 00                	push   $0x0
  pushl $191
80106be2:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106be7:	e9 0b f2 ff ff       	jmp    80105df7 <alltraps>

80106bec <vector192>:
.globl vector192
vector192:
  pushl $0
80106bec:	6a 00                	push   $0x0
  pushl $192
80106bee:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106bf3:	e9 ff f1 ff ff       	jmp    80105df7 <alltraps>

80106bf8 <vector193>:
.globl vector193
vector193:
  pushl $0
80106bf8:	6a 00                	push   $0x0
  pushl $193
80106bfa:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106bff:	e9 f3 f1 ff ff       	jmp    80105df7 <alltraps>

80106c04 <vector194>:
.globl vector194
vector194:
  pushl $0
80106c04:	6a 00                	push   $0x0
  pushl $194
80106c06:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106c0b:	e9 e7 f1 ff ff       	jmp    80105df7 <alltraps>

80106c10 <vector195>:
.globl vector195
vector195:
  pushl $0
80106c10:	6a 00                	push   $0x0
  pushl $195
80106c12:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106c17:	e9 db f1 ff ff       	jmp    80105df7 <alltraps>

80106c1c <vector196>:
.globl vector196
vector196:
  pushl $0
80106c1c:	6a 00                	push   $0x0
  pushl $196
80106c1e:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106c23:	e9 cf f1 ff ff       	jmp    80105df7 <alltraps>

80106c28 <vector197>:
.globl vector197
vector197:
  pushl $0
80106c28:	6a 00                	push   $0x0
  pushl $197
80106c2a:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106c2f:	e9 c3 f1 ff ff       	jmp    80105df7 <alltraps>

80106c34 <vector198>:
.globl vector198
vector198:
  pushl $0
80106c34:	6a 00                	push   $0x0
  pushl $198
80106c36:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106c3b:	e9 b7 f1 ff ff       	jmp    80105df7 <alltraps>

80106c40 <vector199>:
.globl vector199
vector199:
  pushl $0
80106c40:	6a 00                	push   $0x0
  pushl $199
80106c42:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106c47:	e9 ab f1 ff ff       	jmp    80105df7 <alltraps>

80106c4c <vector200>:
.globl vector200
vector200:
  pushl $0
80106c4c:	6a 00                	push   $0x0
  pushl $200
80106c4e:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106c53:	e9 9f f1 ff ff       	jmp    80105df7 <alltraps>

80106c58 <vector201>:
.globl vector201
vector201:
  pushl $0
80106c58:	6a 00                	push   $0x0
  pushl $201
80106c5a:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80106c5f:	e9 93 f1 ff ff       	jmp    80105df7 <alltraps>

80106c64 <vector202>:
.globl vector202
vector202:
  pushl $0
80106c64:	6a 00                	push   $0x0
  pushl $202
80106c66:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106c6b:	e9 87 f1 ff ff       	jmp    80105df7 <alltraps>

80106c70 <vector203>:
.globl vector203
vector203:
  pushl $0
80106c70:	6a 00                	push   $0x0
  pushl $203
80106c72:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106c77:	e9 7b f1 ff ff       	jmp    80105df7 <alltraps>

80106c7c <vector204>:
.globl vector204
vector204:
  pushl $0
80106c7c:	6a 00                	push   $0x0
  pushl $204
80106c7e:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106c83:	e9 6f f1 ff ff       	jmp    80105df7 <alltraps>

80106c88 <vector205>:
.globl vector205
vector205:
  pushl $0
80106c88:	6a 00                	push   $0x0
  pushl $205
80106c8a:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106c8f:	e9 63 f1 ff ff       	jmp    80105df7 <alltraps>

80106c94 <vector206>:
.globl vector206
vector206:
  pushl $0
80106c94:	6a 00                	push   $0x0
  pushl $206
80106c96:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106c9b:	e9 57 f1 ff ff       	jmp    80105df7 <alltraps>

80106ca0 <vector207>:
.globl vector207
vector207:
  pushl $0
80106ca0:	6a 00                	push   $0x0
  pushl $207
80106ca2:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106ca7:	e9 4b f1 ff ff       	jmp    80105df7 <alltraps>

80106cac <vector208>:
.globl vector208
vector208:
  pushl $0
80106cac:	6a 00                	push   $0x0
  pushl $208
80106cae:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106cb3:	e9 3f f1 ff ff       	jmp    80105df7 <alltraps>

80106cb8 <vector209>:
.globl vector209
vector209:
  pushl $0
80106cb8:	6a 00                	push   $0x0
  pushl $209
80106cba:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106cbf:	e9 33 f1 ff ff       	jmp    80105df7 <alltraps>

80106cc4 <vector210>:
.globl vector210
vector210:
  pushl $0
80106cc4:	6a 00                	push   $0x0
  pushl $210
80106cc6:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106ccb:	e9 27 f1 ff ff       	jmp    80105df7 <alltraps>

80106cd0 <vector211>:
.globl vector211
vector211:
  pushl $0
80106cd0:	6a 00                	push   $0x0
  pushl $211
80106cd2:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106cd7:	e9 1b f1 ff ff       	jmp    80105df7 <alltraps>

80106cdc <vector212>:
.globl vector212
vector212:
  pushl $0
80106cdc:	6a 00                	push   $0x0
  pushl $212
80106cde:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106ce3:	e9 0f f1 ff ff       	jmp    80105df7 <alltraps>

80106ce8 <vector213>:
.globl vector213
vector213:
  pushl $0
80106ce8:	6a 00                	push   $0x0
  pushl $213
80106cea:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80106cef:	e9 03 f1 ff ff       	jmp    80105df7 <alltraps>

80106cf4 <vector214>:
.globl vector214
vector214:
  pushl $0
80106cf4:	6a 00                	push   $0x0
  pushl $214
80106cf6:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106cfb:	e9 f7 f0 ff ff       	jmp    80105df7 <alltraps>

80106d00 <vector215>:
.globl vector215
vector215:
  pushl $0
80106d00:	6a 00                	push   $0x0
  pushl $215
80106d02:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106d07:	e9 eb f0 ff ff       	jmp    80105df7 <alltraps>

80106d0c <vector216>:
.globl vector216
vector216:
  pushl $0
80106d0c:	6a 00                	push   $0x0
  pushl $216
80106d0e:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106d13:	e9 df f0 ff ff       	jmp    80105df7 <alltraps>

80106d18 <vector217>:
.globl vector217
vector217:
  pushl $0
80106d18:	6a 00                	push   $0x0
  pushl $217
80106d1a:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80106d1f:	e9 d3 f0 ff ff       	jmp    80105df7 <alltraps>

80106d24 <vector218>:
.globl vector218
vector218:
  pushl $0
80106d24:	6a 00                	push   $0x0
  pushl $218
80106d26:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106d2b:	e9 c7 f0 ff ff       	jmp    80105df7 <alltraps>

80106d30 <vector219>:
.globl vector219
vector219:
  pushl $0
80106d30:	6a 00                	push   $0x0
  pushl $219
80106d32:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106d37:	e9 bb f0 ff ff       	jmp    80105df7 <alltraps>

80106d3c <vector220>:
.globl vector220
vector220:
  pushl $0
80106d3c:	6a 00                	push   $0x0
  pushl $220
80106d3e:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80106d43:	e9 af f0 ff ff       	jmp    80105df7 <alltraps>

80106d48 <vector221>:
.globl vector221
vector221:
  pushl $0
80106d48:	6a 00                	push   $0x0
  pushl $221
80106d4a:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80106d4f:	e9 a3 f0 ff ff       	jmp    80105df7 <alltraps>

80106d54 <vector222>:
.globl vector222
vector222:
  pushl $0
80106d54:	6a 00                	push   $0x0
  pushl $222
80106d56:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80106d5b:	e9 97 f0 ff ff       	jmp    80105df7 <alltraps>

80106d60 <vector223>:
.globl vector223
vector223:
  pushl $0
80106d60:	6a 00                	push   $0x0
  pushl $223
80106d62:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106d67:	e9 8b f0 ff ff       	jmp    80105df7 <alltraps>

80106d6c <vector224>:
.globl vector224
vector224:
  pushl $0
80106d6c:	6a 00                	push   $0x0
  pushl $224
80106d6e:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80106d73:	e9 7f f0 ff ff       	jmp    80105df7 <alltraps>

80106d78 <vector225>:
.globl vector225
vector225:
  pushl $0
80106d78:	6a 00                	push   $0x0
  pushl $225
80106d7a:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80106d7f:	e9 73 f0 ff ff       	jmp    80105df7 <alltraps>

80106d84 <vector226>:
.globl vector226
vector226:
  pushl $0
80106d84:	6a 00                	push   $0x0
  pushl $226
80106d86:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80106d8b:	e9 67 f0 ff ff       	jmp    80105df7 <alltraps>

80106d90 <vector227>:
.globl vector227
vector227:
  pushl $0
80106d90:	6a 00                	push   $0x0
  pushl $227
80106d92:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80106d97:	e9 5b f0 ff ff       	jmp    80105df7 <alltraps>

80106d9c <vector228>:
.globl vector228
vector228:
  pushl $0
80106d9c:	6a 00                	push   $0x0
  pushl $228
80106d9e:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80106da3:	e9 4f f0 ff ff       	jmp    80105df7 <alltraps>

80106da8 <vector229>:
.globl vector229
vector229:
  pushl $0
80106da8:	6a 00                	push   $0x0
  pushl $229
80106daa:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80106daf:	e9 43 f0 ff ff       	jmp    80105df7 <alltraps>

80106db4 <vector230>:
.globl vector230
vector230:
  pushl $0
80106db4:	6a 00                	push   $0x0
  pushl $230
80106db6:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80106dbb:	e9 37 f0 ff ff       	jmp    80105df7 <alltraps>

80106dc0 <vector231>:
.globl vector231
vector231:
  pushl $0
80106dc0:	6a 00                	push   $0x0
  pushl $231
80106dc2:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80106dc7:	e9 2b f0 ff ff       	jmp    80105df7 <alltraps>

80106dcc <vector232>:
.globl vector232
vector232:
  pushl $0
80106dcc:	6a 00                	push   $0x0
  pushl $232
80106dce:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80106dd3:	e9 1f f0 ff ff       	jmp    80105df7 <alltraps>

80106dd8 <vector233>:
.globl vector233
vector233:
  pushl $0
80106dd8:	6a 00                	push   $0x0
  pushl $233
80106dda:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80106ddf:	e9 13 f0 ff ff       	jmp    80105df7 <alltraps>

80106de4 <vector234>:
.globl vector234
vector234:
  pushl $0
80106de4:	6a 00                	push   $0x0
  pushl $234
80106de6:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80106deb:	e9 07 f0 ff ff       	jmp    80105df7 <alltraps>

80106df0 <vector235>:
.globl vector235
vector235:
  pushl $0
80106df0:	6a 00                	push   $0x0
  pushl $235
80106df2:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80106df7:	e9 fb ef ff ff       	jmp    80105df7 <alltraps>

80106dfc <vector236>:
.globl vector236
vector236:
  pushl $0
80106dfc:	6a 00                	push   $0x0
  pushl $236
80106dfe:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80106e03:	e9 ef ef ff ff       	jmp    80105df7 <alltraps>

80106e08 <vector237>:
.globl vector237
vector237:
  pushl $0
80106e08:	6a 00                	push   $0x0
  pushl $237
80106e0a:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80106e0f:	e9 e3 ef ff ff       	jmp    80105df7 <alltraps>

80106e14 <vector238>:
.globl vector238
vector238:
  pushl $0
80106e14:	6a 00                	push   $0x0
  pushl $238
80106e16:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80106e1b:	e9 d7 ef ff ff       	jmp    80105df7 <alltraps>

80106e20 <vector239>:
.globl vector239
vector239:
  pushl $0
80106e20:	6a 00                	push   $0x0
  pushl $239
80106e22:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80106e27:	e9 cb ef ff ff       	jmp    80105df7 <alltraps>

80106e2c <vector240>:
.globl vector240
vector240:
  pushl $0
80106e2c:	6a 00                	push   $0x0
  pushl $240
80106e2e:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80106e33:	e9 bf ef ff ff       	jmp    80105df7 <alltraps>

80106e38 <vector241>:
.globl vector241
vector241:
  pushl $0
80106e38:	6a 00                	push   $0x0
  pushl $241
80106e3a:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80106e3f:	e9 b3 ef ff ff       	jmp    80105df7 <alltraps>

80106e44 <vector242>:
.globl vector242
vector242:
  pushl $0
80106e44:	6a 00                	push   $0x0
  pushl $242
80106e46:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80106e4b:	e9 a7 ef ff ff       	jmp    80105df7 <alltraps>

80106e50 <vector243>:
.globl vector243
vector243:
  pushl $0
80106e50:	6a 00                	push   $0x0
  pushl $243
80106e52:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80106e57:	e9 9b ef ff ff       	jmp    80105df7 <alltraps>

80106e5c <vector244>:
.globl vector244
vector244:
  pushl $0
80106e5c:	6a 00                	push   $0x0
  pushl $244
80106e5e:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80106e63:	e9 8f ef ff ff       	jmp    80105df7 <alltraps>

80106e68 <vector245>:
.globl vector245
vector245:
  pushl $0
80106e68:	6a 00                	push   $0x0
  pushl $245
80106e6a:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80106e6f:	e9 83 ef ff ff       	jmp    80105df7 <alltraps>

80106e74 <vector246>:
.globl vector246
vector246:
  pushl $0
80106e74:	6a 00                	push   $0x0
  pushl $246
80106e76:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80106e7b:	e9 77 ef ff ff       	jmp    80105df7 <alltraps>

80106e80 <vector247>:
.globl vector247
vector247:
  pushl $0
80106e80:	6a 00                	push   $0x0
  pushl $247
80106e82:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80106e87:	e9 6b ef ff ff       	jmp    80105df7 <alltraps>

80106e8c <vector248>:
.globl vector248
vector248:
  pushl $0
80106e8c:	6a 00                	push   $0x0
  pushl $248
80106e8e:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80106e93:	e9 5f ef ff ff       	jmp    80105df7 <alltraps>

80106e98 <vector249>:
.globl vector249
vector249:
  pushl $0
80106e98:	6a 00                	push   $0x0
  pushl $249
80106e9a:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80106e9f:	e9 53 ef ff ff       	jmp    80105df7 <alltraps>

80106ea4 <vector250>:
.globl vector250
vector250:
  pushl $0
80106ea4:	6a 00                	push   $0x0
  pushl $250
80106ea6:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80106eab:	e9 47 ef ff ff       	jmp    80105df7 <alltraps>

80106eb0 <vector251>:
.globl vector251
vector251:
  pushl $0
80106eb0:	6a 00                	push   $0x0
  pushl $251
80106eb2:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80106eb7:	e9 3b ef ff ff       	jmp    80105df7 <alltraps>

80106ebc <vector252>:
.globl vector252
vector252:
  pushl $0
80106ebc:	6a 00                	push   $0x0
  pushl $252
80106ebe:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80106ec3:	e9 2f ef ff ff       	jmp    80105df7 <alltraps>

80106ec8 <vector253>:
.globl vector253
vector253:
  pushl $0
80106ec8:	6a 00                	push   $0x0
  pushl $253
80106eca:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80106ecf:	e9 23 ef ff ff       	jmp    80105df7 <alltraps>

80106ed4 <vector254>:
.globl vector254
vector254:
  pushl $0
80106ed4:	6a 00                	push   $0x0
  pushl $254
80106ed6:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80106edb:	e9 17 ef ff ff       	jmp    80105df7 <alltraps>

80106ee0 <vector255>:
.globl vector255
vector255:
  pushl $0
80106ee0:	6a 00                	push   $0x0
  pushl $255
80106ee2:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80106ee7:	e9 0b ef ff ff       	jmp    80105df7 <alltraps>

80106eec <lgdt>:
{
80106eec:	55                   	push   %ebp
80106eed:	89 e5                	mov    %esp,%ebp
80106eef:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106ef2:	8b 45 0c             	mov    0xc(%ebp),%eax
80106ef5:	83 e8 01             	sub    $0x1,%eax
80106ef8:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106efc:	8b 45 08             	mov    0x8(%ebp),%eax
80106eff:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106f03:	8b 45 08             	mov    0x8(%ebp),%eax
80106f06:	c1 e8 10             	shr    $0x10,%eax
80106f09:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80106f0d:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106f10:	0f 01 10             	lgdtl  (%eax)
}
80106f13:	90                   	nop
80106f14:	c9                   	leave  
80106f15:	c3                   	ret    

80106f16 <ltr>:
{
80106f16:	55                   	push   %ebp
80106f17:	89 e5                	mov    %esp,%ebp
80106f19:	83 ec 04             	sub    $0x4,%esp
80106f1c:	8b 45 08             	mov    0x8(%ebp),%eax
80106f1f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80106f23:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80106f27:	0f 00 d8             	ltr    %ax
}
80106f2a:	90                   	nop
80106f2b:	c9                   	leave  
80106f2c:	c3                   	ret    

80106f2d <lcr3>:

static inline void
lcr3(uint val)
{
80106f2d:	55                   	push   %ebp
80106f2e:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106f30:	8b 45 08             	mov    0x8(%ebp),%eax
80106f33:	0f 22 d8             	mov    %eax,%cr3
}
80106f36:	90                   	nop
80106f37:	5d                   	pop    %ebp
80106f38:	c3                   	ret    

80106f39 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80106f39:	55                   	push   %ebp
80106f3a:	89 e5                	mov    %esp,%ebp
80106f3c:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80106f3f:	e8 4a ca ff ff       	call   8010398e <cpuid>
80106f44:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80106f4a:	05 80 69 19 80       	add    $0x80196980,%eax
80106f4f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80106f52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f55:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80106f5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f5e:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80106f64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f67:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80106f6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f6e:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106f72:	83 e2 f0             	and    $0xfffffff0,%edx
80106f75:	83 ca 0a             	or     $0xa,%edx
80106f78:	88 50 7d             	mov    %dl,0x7d(%eax)
80106f7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f7e:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106f82:	83 ca 10             	or     $0x10,%edx
80106f85:	88 50 7d             	mov    %dl,0x7d(%eax)
80106f88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f8b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106f8f:	83 e2 9f             	and    $0xffffff9f,%edx
80106f92:	88 50 7d             	mov    %dl,0x7d(%eax)
80106f95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f98:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106f9c:	83 ca 80             	or     $0xffffff80,%edx
80106f9f:	88 50 7d             	mov    %dl,0x7d(%eax)
80106fa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fa5:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106fa9:	83 ca 0f             	or     $0xf,%edx
80106fac:	88 50 7e             	mov    %dl,0x7e(%eax)
80106faf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fb2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106fb6:	83 e2 ef             	and    $0xffffffef,%edx
80106fb9:	88 50 7e             	mov    %dl,0x7e(%eax)
80106fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fbf:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106fc3:	83 e2 df             	and    $0xffffffdf,%edx
80106fc6:	88 50 7e             	mov    %dl,0x7e(%eax)
80106fc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fcc:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106fd0:	83 ca 40             	or     $0x40,%edx
80106fd3:	88 50 7e             	mov    %dl,0x7e(%eax)
80106fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fd9:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106fdd:	83 ca 80             	or     $0xffffff80,%edx
80106fe0:	88 50 7e             	mov    %dl,0x7e(%eax)
80106fe3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fe6:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80106fea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fed:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80106ff4:	ff ff 
80106ff6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ff9:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107000:	00 00 
80107002:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107005:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010700c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010700f:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107016:	83 e2 f0             	and    $0xfffffff0,%edx
80107019:	83 ca 02             	or     $0x2,%edx
8010701c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107022:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107025:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010702c:	83 ca 10             	or     $0x10,%edx
8010702f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107035:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107038:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010703f:	83 e2 9f             	and    $0xffffff9f,%edx
80107042:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107048:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010704b:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107052:	83 ca 80             	or     $0xffffff80,%edx
80107055:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010705b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010705e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107065:	83 ca 0f             	or     $0xf,%edx
80107068:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010706e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107071:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107078:	83 e2 ef             	and    $0xffffffef,%edx
8010707b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107084:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010708b:	83 e2 df             	and    $0xffffffdf,%edx
8010708e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107094:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107097:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010709e:	83 ca 40             	or     $0x40,%edx
801070a1:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801070a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070aa:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801070b1:	83 ca 80             	or     $0xffffff80,%edx
801070b4:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801070ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070bd:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801070c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070c7:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801070ce:	ff ff 
801070d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070d3:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801070da:	00 00 
801070dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070df:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801070e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070e9:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801070f0:	83 e2 f0             	and    $0xfffffff0,%edx
801070f3:	83 ca 0a             	or     $0xa,%edx
801070f6:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801070fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070ff:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107106:	83 ca 10             	or     $0x10,%edx
80107109:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010710f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107112:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107119:	83 ca 60             	or     $0x60,%edx
8010711c:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107122:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107125:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010712c:	83 ca 80             	or     $0xffffff80,%edx
8010712f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107135:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107138:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010713f:	83 ca 0f             	or     $0xf,%edx
80107142:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010714b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107152:	83 e2 ef             	and    $0xffffffef,%edx
80107155:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010715b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010715e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107165:	83 e2 df             	and    $0xffffffdf,%edx
80107168:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010716e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107171:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107178:	83 ca 40             	or     $0x40,%edx
8010717b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107184:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010718b:	83 ca 80             	or     $0xffffff80,%edx
8010718e:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107197:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010719e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071a1:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801071a8:	ff ff 
801071aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071ad:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801071b4:	00 00 
801071b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071b9:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801071c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071c3:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801071ca:	83 e2 f0             	and    $0xfffffff0,%edx
801071cd:	83 ca 02             	or     $0x2,%edx
801071d0:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801071d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071d9:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801071e0:	83 ca 10             	or     $0x10,%edx
801071e3:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801071e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071ec:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801071f3:	83 ca 60             	or     $0x60,%edx
801071f6:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801071fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071ff:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107206:	83 ca 80             	or     $0xffffff80,%edx
80107209:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010720f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107212:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107219:	83 ca 0f             	or     $0xf,%edx
8010721c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107222:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107225:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010722c:	83 e2 ef             	and    $0xffffffef,%edx
8010722f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107235:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107238:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010723f:	83 e2 df             	and    $0xffffffdf,%edx
80107242:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107248:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010724b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107252:	83 ca 40             	or     $0x40,%edx
80107255:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010725b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010725e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107265:	83 ca 80             	or     $0xffffff80,%edx
80107268:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010726e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107271:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107278:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010727b:	83 c0 70             	add    $0x70,%eax
8010727e:	83 ec 08             	sub    $0x8,%esp
80107281:	6a 30                	push   $0x30
80107283:	50                   	push   %eax
80107284:	e8 63 fc ff ff       	call   80106eec <lgdt>
80107289:	83 c4 10             	add    $0x10,%esp
}
8010728c:	90                   	nop
8010728d:	c9                   	leave  
8010728e:	c3                   	ret    

8010728f <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010728f:	55                   	push   %ebp
80107290:	89 e5                	mov    %esp,%ebp
80107292:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107295:	8b 45 0c             	mov    0xc(%ebp),%eax
80107298:	c1 e8 16             	shr    $0x16,%eax
8010729b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801072a2:	8b 45 08             	mov    0x8(%ebp),%eax
801072a5:	01 d0                	add    %edx,%eax
801072a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801072aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801072ad:	8b 00                	mov    (%eax),%eax
801072af:	83 e0 01             	and    $0x1,%eax
801072b2:	85 c0                	test   %eax,%eax
801072b4:	74 14                	je     801072ca <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801072b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801072b9:	8b 00                	mov    (%eax),%eax
801072bb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801072c0:	05 00 00 00 80       	add    $0x80000000,%eax
801072c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801072c8:	eb 42                	jmp    8010730c <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801072ca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801072ce:	74 0e                	je     801072de <walkpgdir+0x4f>
801072d0:	e8 bc b4 ff ff       	call   80102791 <kalloc>
801072d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801072d8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801072dc:	75 07                	jne    801072e5 <walkpgdir+0x56>
      return 0;
801072de:	b8 00 00 00 00       	mov    $0x0,%eax
801072e3:	eb 3e                	jmp    80107323 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.

    memset(pgtab, 0, PGSIZE);
801072e5:	83 ec 04             	sub    $0x4,%esp
801072e8:	68 00 10 00 00       	push   $0x1000
801072ed:	6a 00                	push   $0x0
801072ef:	ff 75 f4             	push   -0xc(%ebp)
801072f2:	e8 ba d7 ff ff       	call   80104ab1 <memset>
801072f7:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801072fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072fd:	05 00 00 00 80       	add    $0x80000000,%eax
80107302:	83 c8 07             	or     $0x7,%eax
80107305:	89 c2                	mov    %eax,%edx
80107307:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010730a:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
8010730c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010730f:	c1 e8 0c             	shr    $0xc,%eax
80107312:	25 ff 03 00 00       	and    $0x3ff,%eax
80107317:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010731e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107321:	01 d0                	add    %edx,%eax
}
80107323:	c9                   	leave  
80107324:	c3                   	ret    

80107325 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107325:	55                   	push   %ebp
80107326:	89 e5                	mov    %esp,%ebp
80107328:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
8010732b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010732e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107333:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107336:	8b 55 0c             	mov    0xc(%ebp),%edx
80107339:	8b 45 10             	mov    0x10(%ebp),%eax
8010733c:	01 d0                	add    %edx,%eax
8010733e:	83 e8 01             	sub    $0x1,%eax
80107341:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107346:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107349:	83 ec 04             	sub    $0x4,%esp
8010734c:	6a 01                	push   $0x1
8010734e:	ff 75 f4             	push   -0xc(%ebp)
80107351:	ff 75 08             	push   0x8(%ebp)
80107354:	e8 36 ff ff ff       	call   8010728f <walkpgdir>
80107359:	83 c4 10             	add    $0x10,%esp
8010735c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010735f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107363:	75 07                	jne    8010736c <mappages+0x47>
      return -1;
80107365:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010736a:	eb 47                	jmp    801073b3 <mappages+0x8e>
    if(*pte & PTE_P)
8010736c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010736f:	8b 00                	mov    (%eax),%eax
80107371:	83 e0 01             	and    $0x1,%eax
80107374:	85 c0                	test   %eax,%eax
80107376:	74 0d                	je     80107385 <mappages+0x60>
      panic("remap");
80107378:	83 ec 0c             	sub    $0xc,%esp
8010737b:	68 ec a6 10 80       	push   $0x8010a6ec
80107380:	e8 24 92 ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
80107385:	8b 45 18             	mov    0x18(%ebp),%eax
80107388:	0b 45 14             	or     0x14(%ebp),%eax
8010738b:	83 c8 01             	or     $0x1,%eax
8010738e:	89 c2                	mov    %eax,%edx
80107390:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107393:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107395:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107398:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010739b:	74 10                	je     801073ad <mappages+0x88>
      break;
    a += PGSIZE;
8010739d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801073a4:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801073ab:	eb 9c                	jmp    80107349 <mappages+0x24>
      break;
801073ad:	90                   	nop
  }
  return 0;
801073ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
801073b3:	c9                   	leave  
801073b4:	c3                   	ret    

801073b5 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801073b5:	55                   	push   %ebp
801073b6:	89 e5                	mov    %esp,%ebp
801073b8:	53                   	push   %ebx
801073b9:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
801073bc:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
801073c3:	8b 15 50 6c 19 80    	mov    0x80196c50,%edx
801073c9:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
801073ce:	29 d0                	sub    %edx,%eax
801073d0:	89 45 e0             	mov    %eax,-0x20(%ebp)
801073d3:	a1 48 6c 19 80       	mov    0x80196c48,%eax
801073d8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801073db:	8b 15 48 6c 19 80    	mov    0x80196c48,%edx
801073e1:	a1 50 6c 19 80       	mov    0x80196c50,%eax
801073e6:	01 d0                	add    %edx,%eax
801073e8:	89 45 e8             	mov    %eax,-0x18(%ebp)
801073eb:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
801073f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073f5:	83 c0 30             	add    $0x30,%eax
801073f8:	8b 55 e0             	mov    -0x20(%ebp),%edx
801073fb:	89 10                	mov    %edx,(%eax)
801073fd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107400:	89 50 04             	mov    %edx,0x4(%eax)
80107403:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107406:	89 50 08             	mov    %edx,0x8(%eax)
80107409:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010740c:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
8010740f:	e8 7d b3 ff ff       	call   80102791 <kalloc>
80107414:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107417:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010741b:	75 07                	jne    80107424 <setupkvm+0x6f>
    return 0;
8010741d:	b8 00 00 00 00       	mov    $0x0,%eax
80107422:	eb 78                	jmp    8010749c <setupkvm+0xe7>
  }
  memset(pgdir, 0, PGSIZE);
80107424:	83 ec 04             	sub    $0x4,%esp
80107427:	68 00 10 00 00       	push   $0x1000
8010742c:	6a 00                	push   $0x0
8010742e:	ff 75 f0             	push   -0x10(%ebp)
80107431:	e8 7b d6 ff ff       	call   80104ab1 <memset>
80107436:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107439:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
80107440:	eb 4e                	jmp    80107490 <setupkvm+0xdb>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107442:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107445:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107448:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010744b:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010744e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107451:	8b 58 08             	mov    0x8(%eax),%ebx
80107454:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107457:	8b 40 04             	mov    0x4(%eax),%eax
8010745a:	29 c3                	sub    %eax,%ebx
8010745c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010745f:	8b 00                	mov    (%eax),%eax
80107461:	83 ec 0c             	sub    $0xc,%esp
80107464:	51                   	push   %ecx
80107465:	52                   	push   %edx
80107466:	53                   	push   %ebx
80107467:	50                   	push   %eax
80107468:	ff 75 f0             	push   -0x10(%ebp)
8010746b:	e8 b5 fe ff ff       	call   80107325 <mappages>
80107470:	83 c4 20             	add    $0x20,%esp
80107473:	85 c0                	test   %eax,%eax
80107475:	79 15                	jns    8010748c <setupkvm+0xd7>
      freevm(pgdir);
80107477:	83 ec 0c             	sub    $0xc,%esp
8010747a:	ff 75 f0             	push   -0x10(%ebp)
8010747d:	e8 f7 04 00 00       	call   80107979 <freevm>
80107482:	83 c4 10             	add    $0x10,%esp
      return 0;
80107485:	b8 00 00 00 00       	mov    $0x0,%eax
8010748a:	eb 10                	jmp    8010749c <setupkvm+0xe7>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010748c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107490:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
80107497:	72 a9                	jb     80107442 <setupkvm+0x8d>
    }
  return pgdir;
80107499:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010749c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010749f:	c9                   	leave  
801074a0:	c3                   	ret    

801074a1 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801074a1:	55                   	push   %ebp
801074a2:	89 e5                	mov    %esp,%ebp
801074a4:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801074a7:	e8 09 ff ff ff       	call   801073b5 <setupkvm>
801074ac:	a3 7c 69 19 80       	mov    %eax,0x8019697c
  switchkvm();
801074b1:	e8 03 00 00 00       	call   801074b9 <switchkvm>
}
801074b6:	90                   	nop
801074b7:	c9                   	leave  
801074b8:	c3                   	ret    

801074b9 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801074b9:	55                   	push   %ebp
801074ba:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801074bc:	a1 7c 69 19 80       	mov    0x8019697c,%eax
801074c1:	05 00 00 00 80       	add    $0x80000000,%eax
801074c6:	50                   	push   %eax
801074c7:	e8 61 fa ff ff       	call   80106f2d <lcr3>
801074cc:	83 c4 04             	add    $0x4,%esp
}
801074cf:	90                   	nop
801074d0:	c9                   	leave  
801074d1:	c3                   	ret    

801074d2 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801074d2:	55                   	push   %ebp
801074d3:	89 e5                	mov    %esp,%ebp
801074d5:	56                   	push   %esi
801074d6:	53                   	push   %ebx
801074d7:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
801074da:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801074de:	75 0d                	jne    801074ed <switchuvm+0x1b>
    panic("switchuvm: no process");
801074e0:	83 ec 0c             	sub    $0xc,%esp
801074e3:	68 f2 a6 10 80       	push   $0x8010a6f2
801074e8:	e8 bc 90 ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
801074ed:	8b 45 08             	mov    0x8(%ebp),%eax
801074f0:	8b 40 08             	mov    0x8(%eax),%eax
801074f3:	85 c0                	test   %eax,%eax
801074f5:	75 0d                	jne    80107504 <switchuvm+0x32>
    panic("switchuvm: no kstack");
801074f7:	83 ec 0c             	sub    $0xc,%esp
801074fa:	68 08 a7 10 80       	push   $0x8010a708
801074ff:	e8 a5 90 ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
80107504:	8b 45 08             	mov    0x8(%ebp),%eax
80107507:	8b 40 04             	mov    0x4(%eax),%eax
8010750a:	85 c0                	test   %eax,%eax
8010750c:	75 0d                	jne    8010751b <switchuvm+0x49>
    panic("switchuvm: no pgdir");
8010750e:	83 ec 0c             	sub    $0xc,%esp
80107511:	68 1d a7 10 80       	push   $0x8010a71d
80107516:	e8 8e 90 ff ff       	call   801005a9 <panic>

  pushcli();
8010751b:	e8 86 d4 ff ff       	call   801049a6 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107520:	e8 84 c4 ff ff       	call   801039a9 <mycpu>
80107525:	89 c3                	mov    %eax,%ebx
80107527:	e8 7d c4 ff ff       	call   801039a9 <mycpu>
8010752c:	83 c0 08             	add    $0x8,%eax
8010752f:	89 c6                	mov    %eax,%esi
80107531:	e8 73 c4 ff ff       	call   801039a9 <mycpu>
80107536:	83 c0 08             	add    $0x8,%eax
80107539:	c1 e8 10             	shr    $0x10,%eax
8010753c:	88 45 f7             	mov    %al,-0x9(%ebp)
8010753f:	e8 65 c4 ff ff       	call   801039a9 <mycpu>
80107544:	83 c0 08             	add    $0x8,%eax
80107547:	c1 e8 18             	shr    $0x18,%eax
8010754a:	89 c2                	mov    %eax,%edx
8010754c:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107553:	67 00 
80107555:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
8010755c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107560:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107566:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010756d:	83 e0 f0             	and    $0xfffffff0,%eax
80107570:	83 c8 09             	or     $0x9,%eax
80107573:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107579:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107580:	83 c8 10             	or     $0x10,%eax
80107583:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107589:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107590:	83 e0 9f             	and    $0xffffff9f,%eax
80107593:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107599:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801075a0:	83 c8 80             	or     $0xffffff80,%eax
801075a3:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801075a9:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801075b0:	83 e0 f0             	and    $0xfffffff0,%eax
801075b3:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801075b9:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801075c0:	83 e0 ef             	and    $0xffffffef,%eax
801075c3:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801075c9:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801075d0:	83 e0 df             	and    $0xffffffdf,%eax
801075d3:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801075d9:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801075e0:	83 c8 40             	or     $0x40,%eax
801075e3:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801075e9:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801075f0:	83 e0 7f             	and    $0x7f,%eax
801075f3:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801075f9:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801075ff:	e8 a5 c3 ff ff       	call   801039a9 <mycpu>
80107604:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010760b:	83 e2 ef             	and    $0xffffffef,%edx
8010760e:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107614:	e8 90 c3 ff ff       	call   801039a9 <mycpu>
80107619:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
8010761f:	8b 45 08             	mov    0x8(%ebp),%eax
80107622:	8b 40 08             	mov    0x8(%eax),%eax
80107625:	89 c3                	mov    %eax,%ebx
80107627:	e8 7d c3 ff ff       	call   801039a9 <mycpu>
8010762c:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107632:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107635:	e8 6f c3 ff ff       	call   801039a9 <mycpu>
8010763a:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107640:	83 ec 0c             	sub    $0xc,%esp
80107643:	6a 28                	push   $0x28
80107645:	e8 cc f8 ff ff       	call   80106f16 <ltr>
8010764a:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
8010764d:	8b 45 08             	mov    0x8(%ebp),%eax
80107650:	8b 40 04             	mov    0x4(%eax),%eax
80107653:	05 00 00 00 80       	add    $0x80000000,%eax
80107658:	83 ec 0c             	sub    $0xc,%esp
8010765b:	50                   	push   %eax
8010765c:	e8 cc f8 ff ff       	call   80106f2d <lcr3>
80107661:	83 c4 10             	add    $0x10,%esp
  popcli();
80107664:	e8 8a d3 ff ff       	call   801049f3 <popcli>
}
80107669:	90                   	nop
8010766a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010766d:	5b                   	pop    %ebx
8010766e:	5e                   	pop    %esi
8010766f:	5d                   	pop    %ebp
80107670:	c3                   	ret    

80107671 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107671:	55                   	push   %ebp
80107672:	89 e5                	mov    %esp,%ebp
80107674:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107677:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
8010767e:	76 0d                	jbe    8010768d <inituvm+0x1c>
    panic("inituvm: more than a page");
80107680:	83 ec 0c             	sub    $0xc,%esp
80107683:	68 31 a7 10 80       	push   $0x8010a731
80107688:	e8 1c 8f ff ff       	call   801005a9 <panic>
  mem = kalloc();
8010768d:	e8 ff b0 ff ff       	call   80102791 <kalloc>
80107692:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107695:	83 ec 04             	sub    $0x4,%esp
80107698:	68 00 10 00 00       	push   $0x1000
8010769d:	6a 00                	push   $0x0
8010769f:	ff 75 f4             	push   -0xc(%ebp)
801076a2:	e8 0a d4 ff ff       	call   80104ab1 <memset>
801076a7:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801076aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076ad:	05 00 00 00 80       	add    $0x80000000,%eax
801076b2:	83 ec 0c             	sub    $0xc,%esp
801076b5:	6a 06                	push   $0x6
801076b7:	50                   	push   %eax
801076b8:	68 00 10 00 00       	push   $0x1000
801076bd:	6a 00                	push   $0x0
801076bf:	ff 75 08             	push   0x8(%ebp)
801076c2:	e8 5e fc ff ff       	call   80107325 <mappages>
801076c7:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
801076ca:	83 ec 04             	sub    $0x4,%esp
801076cd:	ff 75 10             	push   0x10(%ebp)
801076d0:	ff 75 0c             	push   0xc(%ebp)
801076d3:	ff 75 f4             	push   -0xc(%ebp)
801076d6:	e8 95 d4 ff ff       	call   80104b70 <memmove>
801076db:	83 c4 10             	add    $0x10,%esp
}
801076de:	90                   	nop
801076df:	c9                   	leave  
801076e0:	c3                   	ret    

801076e1 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801076e1:	55                   	push   %ebp
801076e2:	89 e5                	mov    %esp,%ebp
801076e4:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801076e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801076ea:	25 ff 0f 00 00       	and    $0xfff,%eax
801076ef:	85 c0                	test   %eax,%eax
801076f1:	74 0d                	je     80107700 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
801076f3:	83 ec 0c             	sub    $0xc,%esp
801076f6:	68 4c a7 10 80       	push   $0x8010a74c
801076fb:	e8 a9 8e ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107700:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107707:	e9 8f 00 00 00       	jmp    8010779b <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
8010770c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010770f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107712:	01 d0                	add    %edx,%eax
80107714:	83 ec 04             	sub    $0x4,%esp
80107717:	6a 00                	push   $0x0
80107719:	50                   	push   %eax
8010771a:	ff 75 08             	push   0x8(%ebp)
8010771d:	e8 6d fb ff ff       	call   8010728f <walkpgdir>
80107722:	83 c4 10             	add    $0x10,%esp
80107725:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107728:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010772c:	75 0d                	jne    8010773b <loaduvm+0x5a>
      panic("loaduvm: address should exist");
8010772e:	83 ec 0c             	sub    $0xc,%esp
80107731:	68 6f a7 10 80       	push   $0x8010a76f
80107736:	e8 6e 8e ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
8010773b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010773e:	8b 00                	mov    (%eax),%eax
80107740:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107745:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107748:	8b 45 18             	mov    0x18(%ebp),%eax
8010774b:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010774e:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107753:	77 0b                	ja     80107760 <loaduvm+0x7f>
      n = sz - i;
80107755:	8b 45 18             	mov    0x18(%ebp),%eax
80107758:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010775b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010775e:	eb 07                	jmp    80107767 <loaduvm+0x86>
    else
      n = PGSIZE;
80107760:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107767:	8b 55 14             	mov    0x14(%ebp),%edx
8010776a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010776d:	01 d0                	add    %edx,%eax
8010776f:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107772:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107778:	ff 75 f0             	push   -0x10(%ebp)
8010777b:	50                   	push   %eax
8010777c:	52                   	push   %edx
8010777d:	ff 75 10             	push   0x10(%ebp)
80107780:	e8 42 a7 ff ff       	call   80101ec7 <readi>
80107785:	83 c4 10             	add    $0x10,%esp
80107788:	39 45 f0             	cmp    %eax,-0x10(%ebp)
8010778b:	74 07                	je     80107794 <loaduvm+0xb3>
      return -1;
8010778d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107792:	eb 18                	jmp    801077ac <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
80107794:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010779b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010779e:	3b 45 18             	cmp    0x18(%ebp),%eax
801077a1:	0f 82 65 ff ff ff    	jb     8010770c <loaduvm+0x2b>
  }
  return 0;
801077a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801077ac:	c9                   	leave  
801077ad:	c3                   	ret    

801077ae <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801077ae:	55                   	push   %ebp
801077af:	89 e5                	mov    %esp,%ebp
801077b1:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz > KERNBASE)
801077b4:	81 7d 10 00 00 00 80 	cmpl   $0x80000000,0x10(%ebp)
801077bb:	76 0a                	jbe    801077c7 <allocuvm+0x19>
    return 0;
801077bd:	b8 00 00 00 00       	mov    $0x0,%eax
801077c2:	e9 ec 00 00 00       	jmp    801078b3 <allocuvm+0x105>
  if(newsz < oldsz)
801077c7:	8b 45 10             	mov    0x10(%ebp),%eax
801077ca:	3b 45 0c             	cmp    0xc(%ebp),%eax
801077cd:	73 08                	jae    801077d7 <allocuvm+0x29>
    return oldsz;
801077cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801077d2:	e9 dc 00 00 00       	jmp    801078b3 <allocuvm+0x105>

  a = PGROUNDUP(oldsz);
801077d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801077da:	05 ff 0f 00 00       	add    $0xfff,%eax
801077df:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801077e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801077e7:	e9 b8 00 00 00       	jmp    801078a4 <allocuvm+0xf6>
    mem = kalloc();
801077ec:	e8 a0 af ff ff       	call   80102791 <kalloc>
801077f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801077f4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801077f8:	75 2e                	jne    80107828 <allocuvm+0x7a>
      cprintf("allocuvm out of memory\n");
801077fa:	83 ec 0c             	sub    $0xc,%esp
801077fd:	68 8d a7 10 80       	push   $0x8010a78d
80107802:	e8 ed 8b ff ff       	call   801003f4 <cprintf>
80107807:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
8010780a:	83 ec 04             	sub    $0x4,%esp
8010780d:	ff 75 0c             	push   0xc(%ebp)
80107810:	ff 75 10             	push   0x10(%ebp)
80107813:	ff 75 08             	push   0x8(%ebp)
80107816:	e8 9a 00 00 00       	call   801078b5 <deallocuvm>
8010781b:	83 c4 10             	add    $0x10,%esp
      return 0;
8010781e:	b8 00 00 00 00       	mov    $0x0,%eax
80107823:	e9 8b 00 00 00       	jmp    801078b3 <allocuvm+0x105>
    }
    memset(mem, 0, PGSIZE);
80107828:	83 ec 04             	sub    $0x4,%esp
8010782b:	68 00 10 00 00       	push   $0x1000
80107830:	6a 00                	push   $0x0
80107832:	ff 75 f0             	push   -0x10(%ebp)
80107835:	e8 77 d2 ff ff       	call   80104ab1 <memset>
8010783a:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
8010783d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107840:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107846:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107849:	83 ec 0c             	sub    $0xc,%esp
8010784c:	6a 06                	push   $0x6
8010784e:	52                   	push   %edx
8010784f:	68 00 10 00 00       	push   $0x1000
80107854:	50                   	push   %eax
80107855:	ff 75 08             	push   0x8(%ebp)
80107858:	e8 c8 fa ff ff       	call   80107325 <mappages>
8010785d:	83 c4 20             	add    $0x20,%esp
80107860:	85 c0                	test   %eax,%eax
80107862:	79 39                	jns    8010789d <allocuvm+0xef>
      cprintf("allocuvm out of memory (2)\n");
80107864:	83 ec 0c             	sub    $0xc,%esp
80107867:	68 a5 a7 10 80       	push   $0x8010a7a5
8010786c:	e8 83 8b ff ff       	call   801003f4 <cprintf>
80107871:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107874:	83 ec 04             	sub    $0x4,%esp
80107877:	ff 75 0c             	push   0xc(%ebp)
8010787a:	ff 75 10             	push   0x10(%ebp)
8010787d:	ff 75 08             	push   0x8(%ebp)
80107880:	e8 30 00 00 00       	call   801078b5 <deallocuvm>
80107885:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107888:	83 ec 0c             	sub    $0xc,%esp
8010788b:	ff 75 f0             	push   -0x10(%ebp)
8010788e:	e8 64 ae ff ff       	call   801026f7 <kfree>
80107893:	83 c4 10             	add    $0x10,%esp
      return 0;
80107896:	b8 00 00 00 00       	mov    $0x0,%eax
8010789b:	eb 16                	jmp    801078b3 <allocuvm+0x105>
  for(; a < newsz; a += PGSIZE){
8010789d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801078a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a7:	3b 45 10             	cmp    0x10(%ebp),%eax
801078aa:	0f 82 3c ff ff ff    	jb     801077ec <allocuvm+0x3e>
    }
  }
  return newsz;
801078b0:	8b 45 10             	mov    0x10(%ebp),%eax
}
801078b3:	c9                   	leave  
801078b4:	c3                   	ret    

801078b5 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801078b5:	55                   	push   %ebp
801078b6:	89 e5                	mov    %esp,%ebp
801078b8:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801078bb:	8b 45 10             	mov    0x10(%ebp),%eax
801078be:	3b 45 0c             	cmp    0xc(%ebp),%eax
801078c1:	72 08                	jb     801078cb <deallocuvm+0x16>
    return oldsz;
801078c3:	8b 45 0c             	mov    0xc(%ebp),%eax
801078c6:	e9 ac 00 00 00       	jmp    80107977 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
801078cb:	8b 45 10             	mov    0x10(%ebp),%eax
801078ce:	05 ff 0f 00 00       	add    $0xfff,%eax
801078d3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801078d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801078db:	e9 88 00 00 00       	jmp    80107968 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
801078e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e3:	83 ec 04             	sub    $0x4,%esp
801078e6:	6a 00                	push   $0x0
801078e8:	50                   	push   %eax
801078e9:	ff 75 08             	push   0x8(%ebp)
801078ec:	e8 9e f9 ff ff       	call   8010728f <walkpgdir>
801078f1:	83 c4 10             	add    $0x10,%esp
801078f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801078f7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801078fb:	75 16                	jne    80107913 <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801078fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107900:	c1 e8 16             	shr    $0x16,%eax
80107903:	83 c0 01             	add    $0x1,%eax
80107906:	c1 e0 16             	shl    $0x16,%eax
80107909:	2d 00 10 00 00       	sub    $0x1000,%eax
8010790e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107911:	eb 4e                	jmp    80107961 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80107913:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107916:	8b 00                	mov    (%eax),%eax
80107918:	83 e0 01             	and    $0x1,%eax
8010791b:	85 c0                	test   %eax,%eax
8010791d:	74 42                	je     80107961 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
8010791f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107922:	8b 00                	mov    (%eax),%eax
80107924:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107929:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
8010792c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107930:	75 0d                	jne    8010793f <deallocuvm+0x8a>
        panic("kfree");
80107932:	83 ec 0c             	sub    $0xc,%esp
80107935:	68 c1 a7 10 80       	push   $0x8010a7c1
8010793a:	e8 6a 8c ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
8010793f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107942:	05 00 00 00 80       	add    $0x80000000,%eax
80107947:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
8010794a:	83 ec 0c             	sub    $0xc,%esp
8010794d:	ff 75 e8             	push   -0x18(%ebp)
80107950:	e8 a2 ad ff ff       	call   801026f7 <kfree>
80107955:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107958:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010795b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107961:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107968:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010796b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010796e:	0f 82 6c ff ff ff    	jb     801078e0 <deallocuvm+0x2b>
    }
  }
  return newsz;
80107974:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107977:	c9                   	leave  
80107978:	c3                   	ret    

80107979 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107979:	55                   	push   %ebp
8010797a:	89 e5                	mov    %esp,%ebp
8010797c:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
8010797f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107983:	75 0d                	jne    80107992 <freevm+0x19>
    panic("freevm: no pgdir");
80107985:	83 ec 0c             	sub    $0xc,%esp
80107988:	68 c7 a7 10 80       	push   $0x8010a7c7
8010798d:	e8 17 8c ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107992:	83 ec 04             	sub    $0x4,%esp
80107995:	6a 00                	push   $0x0
80107997:	68 00 00 00 80       	push   $0x80000000
8010799c:	ff 75 08             	push   0x8(%ebp)
8010799f:	e8 11 ff ff ff       	call   801078b5 <deallocuvm>
801079a4:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801079a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801079ae:	eb 48                	jmp    801079f8 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
801079b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079b3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801079ba:	8b 45 08             	mov    0x8(%ebp),%eax
801079bd:	01 d0                	add    %edx,%eax
801079bf:	8b 00                	mov    (%eax),%eax
801079c1:	83 e0 01             	and    $0x1,%eax
801079c4:	85 c0                	test   %eax,%eax
801079c6:	74 2c                	je     801079f4 <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801079c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079cb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801079d2:	8b 45 08             	mov    0x8(%ebp),%eax
801079d5:	01 d0                	add    %edx,%eax
801079d7:	8b 00                	mov    (%eax),%eax
801079d9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801079de:	05 00 00 00 80       	add    $0x80000000,%eax
801079e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801079e6:	83 ec 0c             	sub    $0xc,%esp
801079e9:	ff 75 f0             	push   -0x10(%ebp)
801079ec:	e8 06 ad ff ff       	call   801026f7 <kfree>
801079f1:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801079f4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801079f8:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801079ff:	76 af                	jbe    801079b0 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80107a01:	83 ec 0c             	sub    $0xc,%esp
80107a04:	ff 75 08             	push   0x8(%ebp)
80107a07:	e8 eb ac ff ff       	call   801026f7 <kfree>
80107a0c:	83 c4 10             	add    $0x10,%esp
}
80107a0f:	90                   	nop
80107a10:	c9                   	leave  
80107a11:	c3                   	ret    

80107a12 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107a12:	55                   	push   %ebp
80107a13:	89 e5                	mov    %esp,%ebp
80107a15:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107a18:	83 ec 04             	sub    $0x4,%esp
80107a1b:	6a 00                	push   $0x0
80107a1d:	ff 75 0c             	push   0xc(%ebp)
80107a20:	ff 75 08             	push   0x8(%ebp)
80107a23:	e8 67 f8 ff ff       	call   8010728f <walkpgdir>
80107a28:	83 c4 10             	add    $0x10,%esp
80107a2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107a2e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107a32:	75 0d                	jne    80107a41 <clearpteu+0x2f>
    panic("clearpteu");
80107a34:	83 ec 0c             	sub    $0xc,%esp
80107a37:	68 d8 a7 10 80       	push   $0x8010a7d8
80107a3c:	e8 68 8b ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
80107a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a44:	8b 00                	mov    (%eax),%eax
80107a46:	83 e0 fb             	and    $0xfffffffb,%eax
80107a49:	89 c2                	mov    %eax,%edx
80107a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a4e:	89 10                	mov    %edx,(%eax)
}
80107a50:	90                   	nop
80107a51:	c9                   	leave  
80107a52:	c3                   	ret    

80107a53 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107a53:	55                   	push   %ebp
80107a54:	89 e5                	mov    %esp,%ebp
80107a56:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107a59:	e8 57 f9 ff ff       	call   801073b5 <setupkvm>
80107a5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107a61:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107a65:	75 0a                	jne    80107a71 <copyuvm+0x1e>
    return 0;
80107a67:	b8 00 00 00 00       	mov    $0x0,%eax
80107a6c:	e9 d6 00 00 00       	jmp    80107b47 <copyuvm+0xf4>
  for(i = 0; i < KERNBASE; i += PGSIZE){
80107a71:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107a78:	e9 a3 00 00 00       	jmp    80107b20 <copyuvm+0xcd>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107a7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a80:	83 ec 04             	sub    $0x4,%esp
80107a83:	6a 00                	push   $0x0
80107a85:	50                   	push   %eax
80107a86:	ff 75 08             	push   0x8(%ebp)
80107a89:	e8 01 f8 ff ff       	call   8010728f <walkpgdir>
80107a8e:	83 c4 10             	add    $0x10,%esp
80107a91:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107a94:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107a98:	74 7b                	je     80107b15 <copyuvm+0xc2>
    {
      //panic("copyuvm: pte should exist");
      continue;
    }
    if(!(*pte & PTE_P))
80107a9a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107a9d:	8b 00                	mov    (%eax),%eax
80107a9f:	83 e0 01             	and    $0x1,%eax
80107aa2:	85 c0                	test   %eax,%eax
80107aa4:	74 72                	je     80107b18 <copyuvm+0xc5>
    {
      //panic("copyuvm: page not present");
      continue;
    }
    pa = PTE_ADDR(*pte);
80107aa6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107aa9:	8b 00                	mov    (%eax),%eax
80107aab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ab0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107ab3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ab6:	8b 00                	mov    (%eax),%eax
80107ab8:	25 ff 0f 00 00       	and    $0xfff,%eax
80107abd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107ac0:	e8 cc ac ff ff       	call   80102791 <kalloc>
80107ac5:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107ac8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107acc:	74 62                	je     80107b30 <copyuvm+0xdd>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107ace:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107ad1:	05 00 00 00 80       	add    $0x80000000,%eax
80107ad6:	83 ec 04             	sub    $0x4,%esp
80107ad9:	68 00 10 00 00       	push   $0x1000
80107ade:	50                   	push   %eax
80107adf:	ff 75 e0             	push   -0x20(%ebp)
80107ae2:	e8 89 d0 ff ff       	call   80104b70 <memmove>
80107ae7:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107aea:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107aed:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107af0:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107af6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af9:	83 ec 0c             	sub    $0xc,%esp
80107afc:	52                   	push   %edx
80107afd:	51                   	push   %ecx
80107afe:	68 00 10 00 00       	push   $0x1000
80107b03:	50                   	push   %eax
80107b04:	ff 75 f0             	push   -0x10(%ebp)
80107b07:	e8 19 f8 ff ff       	call   80107325 <mappages>
80107b0c:	83 c4 20             	add    $0x20,%esp
80107b0f:	85 c0                	test   %eax,%eax
80107b11:	78 20                	js     80107b33 <copyuvm+0xe0>
80107b13:	eb 04                	jmp    80107b19 <copyuvm+0xc6>
      continue;
80107b15:	90                   	nop
80107b16:	eb 01                	jmp    80107b19 <copyuvm+0xc6>
      continue;
80107b18:	90                   	nop
  for(i = 0; i < KERNBASE; i += PGSIZE){
80107b19:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b23:	85 c0                	test   %eax,%eax
80107b25:	0f 89 52 ff ff ff    	jns    80107a7d <copyuvm+0x2a>
      goto bad;
  }
  return d;
80107b2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b2e:	eb 17                	jmp    80107b47 <copyuvm+0xf4>
      goto bad;
80107b30:	90                   	nop
80107b31:	eb 01                	jmp    80107b34 <copyuvm+0xe1>
      goto bad;
80107b33:	90                   	nop

bad:
  freevm(d);
80107b34:	83 ec 0c             	sub    $0xc,%esp
80107b37:	ff 75 f0             	push   -0x10(%ebp)
80107b3a:	e8 3a fe ff ff       	call   80107979 <freevm>
80107b3f:	83 c4 10             	add    $0x10,%esp
  return 0;
80107b42:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107b47:	c9                   	leave  
80107b48:	c3                   	ret    

80107b49 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107b49:	55                   	push   %ebp
80107b4a:	89 e5                	mov    %esp,%ebp
80107b4c:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107b4f:	83 ec 04             	sub    $0x4,%esp
80107b52:	6a 00                	push   $0x0
80107b54:	ff 75 0c             	push   0xc(%ebp)
80107b57:	ff 75 08             	push   0x8(%ebp)
80107b5a:	e8 30 f7 ff ff       	call   8010728f <walkpgdir>
80107b5f:	83 c4 10             	add    $0x10,%esp
80107b62:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80107b65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b68:	8b 00                	mov    (%eax),%eax
80107b6a:	83 e0 01             	and    $0x1,%eax
80107b6d:	85 c0                	test   %eax,%eax
80107b6f:	75 07                	jne    80107b78 <uva2ka+0x2f>
    return 0;
80107b71:	b8 00 00 00 00       	mov    $0x0,%eax
80107b76:	eb 22                	jmp    80107b9a <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80107b78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b7b:	8b 00                	mov    (%eax),%eax
80107b7d:	83 e0 04             	and    $0x4,%eax
80107b80:	85 c0                	test   %eax,%eax
80107b82:	75 07                	jne    80107b8b <uva2ka+0x42>
    return 0;
80107b84:	b8 00 00 00 00       	mov    $0x0,%eax
80107b89:	eb 0f                	jmp    80107b9a <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80107b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b8e:	8b 00                	mov    (%eax),%eax
80107b90:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b95:	05 00 00 00 80       	add    $0x80000000,%eax
}
80107b9a:	c9                   	leave  
80107b9b:	c3                   	ret    

80107b9c <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107b9c:	55                   	push   %ebp
80107b9d:	89 e5                	mov    %esp,%ebp
80107b9f:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80107ba2:	8b 45 10             	mov    0x10(%ebp),%eax
80107ba5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80107ba8:	eb 7f                	jmp    80107c29 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80107baa:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bad:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107bb2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80107bb5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107bb8:	83 ec 08             	sub    $0x8,%esp
80107bbb:	50                   	push   %eax
80107bbc:	ff 75 08             	push   0x8(%ebp)
80107bbf:	e8 85 ff ff ff       	call   80107b49 <uva2ka>
80107bc4:	83 c4 10             	add    $0x10,%esp
80107bc7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80107bca:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80107bce:	75 07                	jne    80107bd7 <copyout+0x3b>
      return -1;
80107bd0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107bd5:	eb 61                	jmp    80107c38 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80107bd7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107bda:	2b 45 0c             	sub    0xc(%ebp),%eax
80107bdd:	05 00 10 00 00       	add    $0x1000,%eax
80107be2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80107be5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107be8:	3b 45 14             	cmp    0x14(%ebp),%eax
80107beb:	76 06                	jbe    80107bf3 <copyout+0x57>
      n = len;
80107bed:	8b 45 14             	mov    0x14(%ebp),%eax
80107bf0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80107bf3:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bf6:	2b 45 ec             	sub    -0x14(%ebp),%eax
80107bf9:	89 c2                	mov    %eax,%edx
80107bfb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107bfe:	01 d0                	add    %edx,%eax
80107c00:	83 ec 04             	sub    $0x4,%esp
80107c03:	ff 75 f0             	push   -0x10(%ebp)
80107c06:	ff 75 f4             	push   -0xc(%ebp)
80107c09:	50                   	push   %eax
80107c0a:	e8 61 cf ff ff       	call   80104b70 <memmove>
80107c0f:	83 c4 10             	add    $0x10,%esp
    len -= n;
80107c12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c15:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80107c18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c1b:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80107c1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c21:	05 00 10 00 00       	add    $0x1000,%eax
80107c26:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80107c29:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80107c2d:	0f 85 77 ff ff ff    	jne    80107baa <copyout+0xe>
  }
  return 0;
80107c33:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107c38:	c9                   	leave  
80107c39:	c3                   	ret    

80107c3a <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80107c3a:	55                   	push   %ebp
80107c3b:	89 e5                	mov    %esp,%ebp
80107c3d:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107c40:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80107c47:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107c4a:	8b 40 08             	mov    0x8(%eax),%eax
80107c4d:	05 00 00 00 80       	add    $0x80000000,%eax
80107c52:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80107c55:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80107c5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c5f:	8b 40 24             	mov    0x24(%eax),%eax
80107c62:	a3 00 41 19 80       	mov    %eax,0x80194100
  ncpu = 0;
80107c67:	c7 05 40 6c 19 80 00 	movl   $0x0,0x80196c40
80107c6e:	00 00 00 

  while(i<madt->len){
80107c71:	90                   	nop
80107c72:	e9 bd 00 00 00       	jmp    80107d34 <mpinit_uefi+0xfa>
    uchar *entry_type = ((uchar *)madt)+i;
80107c77:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107c7a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107c7d:	01 d0                	add    %edx,%eax
80107c7f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80107c82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c85:	0f b6 00             	movzbl (%eax),%eax
80107c88:	0f b6 c0             	movzbl %al,%eax
80107c8b:	83 f8 05             	cmp    $0x5,%eax
80107c8e:	0f 87 a0 00 00 00    	ja     80107d34 <mpinit_uefi+0xfa>
80107c94:	8b 04 85 e4 a7 10 80 	mov    -0x7fef581c(,%eax,4),%eax
80107c9b:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80107c9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ca0:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80107ca3:	a1 40 6c 19 80       	mov    0x80196c40,%eax
80107ca8:	83 f8 03             	cmp    $0x3,%eax
80107cab:	7f 28                	jg     80107cd5 <mpinit_uefi+0x9b>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80107cad:	8b 15 40 6c 19 80    	mov    0x80196c40,%edx
80107cb3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107cb6:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80107cba:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80107cc0:	81 c2 80 69 19 80    	add    $0x80196980,%edx
80107cc6:	88 02                	mov    %al,(%edx)
          ncpu++;
80107cc8:	a1 40 6c 19 80       	mov    0x80196c40,%eax
80107ccd:	83 c0 01             	add    $0x1,%eax
80107cd0:	a3 40 6c 19 80       	mov    %eax,0x80196c40
        }
        i += lapic_entry->record_len;
80107cd5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107cd8:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107cdc:	0f b6 c0             	movzbl %al,%eax
80107cdf:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107ce2:	eb 50                	jmp    80107d34 <mpinit_uefi+0xfa>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80107ce4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ce7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80107cea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107ced:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80107cf1:	a2 44 6c 19 80       	mov    %al,0x80196c44
        i += ioapic->record_len;
80107cf6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107cf9:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107cfd:	0f b6 c0             	movzbl %al,%eax
80107d00:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107d03:	eb 2f                	jmp    80107d34 <mpinit_uefi+0xfa>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80107d05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d08:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80107d0b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107d0e:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107d12:	0f b6 c0             	movzbl %al,%eax
80107d15:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107d18:	eb 1a                	jmp    80107d34 <mpinit_uefi+0xfa>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80107d1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d1d:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80107d20:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d23:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107d27:	0f b6 c0             	movzbl %al,%eax
80107d2a:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107d2d:	eb 05                	jmp    80107d34 <mpinit_uefi+0xfa>

      case 5:
        i = i + 0xC;
80107d2f:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80107d33:	90                   	nop
  while(i<madt->len){
80107d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d37:	8b 40 04             	mov    0x4(%eax),%eax
80107d3a:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80107d3d:	0f 82 34 ff ff ff    	jb     80107c77 <mpinit_uefi+0x3d>
    }
  }

}
80107d43:	90                   	nop
80107d44:	90                   	nop
80107d45:	c9                   	leave  
80107d46:	c3                   	ret    

80107d47 <inb>:
{
80107d47:	55                   	push   %ebp
80107d48:	89 e5                	mov    %esp,%ebp
80107d4a:	83 ec 14             	sub    $0x14,%esp
80107d4d:	8b 45 08             	mov    0x8(%ebp),%eax
80107d50:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107d54:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107d58:	89 c2                	mov    %eax,%edx
80107d5a:	ec                   	in     (%dx),%al
80107d5b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107d5e:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107d62:	c9                   	leave  
80107d63:	c3                   	ret    

80107d64 <outb>:
{
80107d64:	55                   	push   %ebp
80107d65:	89 e5                	mov    %esp,%ebp
80107d67:	83 ec 08             	sub    $0x8,%esp
80107d6a:	8b 45 08             	mov    0x8(%ebp),%eax
80107d6d:	8b 55 0c             	mov    0xc(%ebp),%edx
80107d70:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80107d74:	89 d0                	mov    %edx,%eax
80107d76:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107d79:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107d7d:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107d81:	ee                   	out    %al,(%dx)
}
80107d82:	90                   	nop
80107d83:	c9                   	leave  
80107d84:	c3                   	ret    

80107d85 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80107d85:	55                   	push   %ebp
80107d86:	89 e5                	mov    %esp,%ebp
80107d88:	83 ec 28             	sub    $0x28,%esp
80107d8b:	8b 45 08             	mov    0x8(%ebp),%eax
80107d8e:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80107d91:	6a 00                	push   $0x0
80107d93:	68 fa 03 00 00       	push   $0x3fa
80107d98:	e8 c7 ff ff ff       	call   80107d64 <outb>
80107d9d:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107da0:	68 80 00 00 00       	push   $0x80
80107da5:	68 fb 03 00 00       	push   $0x3fb
80107daa:	e8 b5 ff ff ff       	call   80107d64 <outb>
80107daf:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107db2:	6a 0c                	push   $0xc
80107db4:	68 f8 03 00 00       	push   $0x3f8
80107db9:	e8 a6 ff ff ff       	call   80107d64 <outb>
80107dbe:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107dc1:	6a 00                	push   $0x0
80107dc3:	68 f9 03 00 00       	push   $0x3f9
80107dc8:	e8 97 ff ff ff       	call   80107d64 <outb>
80107dcd:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107dd0:	6a 03                	push   $0x3
80107dd2:	68 fb 03 00 00       	push   $0x3fb
80107dd7:	e8 88 ff ff ff       	call   80107d64 <outb>
80107ddc:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107ddf:	6a 00                	push   $0x0
80107de1:	68 fc 03 00 00       	push   $0x3fc
80107de6:	e8 79 ff ff ff       	call   80107d64 <outb>
80107deb:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
80107dee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107df5:	eb 11                	jmp    80107e08 <uart_debug+0x83>
80107df7:	83 ec 0c             	sub    $0xc,%esp
80107dfa:	6a 0a                	push   $0xa
80107dfc:	e8 27 ad ff ff       	call   80102b28 <microdelay>
80107e01:	83 c4 10             	add    $0x10,%esp
80107e04:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107e08:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107e0c:	7f 1a                	jg     80107e28 <uart_debug+0xa3>
80107e0e:	83 ec 0c             	sub    $0xc,%esp
80107e11:	68 fd 03 00 00       	push   $0x3fd
80107e16:	e8 2c ff ff ff       	call   80107d47 <inb>
80107e1b:	83 c4 10             	add    $0x10,%esp
80107e1e:	0f b6 c0             	movzbl %al,%eax
80107e21:	83 e0 20             	and    $0x20,%eax
80107e24:	85 c0                	test   %eax,%eax
80107e26:	74 cf                	je     80107df7 <uart_debug+0x72>
  outb(COM1+0, p);
80107e28:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80107e2c:	0f b6 c0             	movzbl %al,%eax
80107e2f:	83 ec 08             	sub    $0x8,%esp
80107e32:	50                   	push   %eax
80107e33:	68 f8 03 00 00       	push   $0x3f8
80107e38:	e8 27 ff ff ff       	call   80107d64 <outb>
80107e3d:	83 c4 10             	add    $0x10,%esp
}
80107e40:	90                   	nop
80107e41:	c9                   	leave  
80107e42:	c3                   	ret    

80107e43 <uart_debugs>:

void uart_debugs(char *p){
80107e43:	55                   	push   %ebp
80107e44:	89 e5                	mov    %esp,%ebp
80107e46:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80107e49:	eb 1b                	jmp    80107e66 <uart_debugs+0x23>
    uart_debug(*p++);
80107e4b:	8b 45 08             	mov    0x8(%ebp),%eax
80107e4e:	8d 50 01             	lea    0x1(%eax),%edx
80107e51:	89 55 08             	mov    %edx,0x8(%ebp)
80107e54:	0f b6 00             	movzbl (%eax),%eax
80107e57:	0f be c0             	movsbl %al,%eax
80107e5a:	83 ec 0c             	sub    $0xc,%esp
80107e5d:	50                   	push   %eax
80107e5e:	e8 22 ff ff ff       	call   80107d85 <uart_debug>
80107e63:	83 c4 10             	add    $0x10,%esp
  while(*p){
80107e66:	8b 45 08             	mov    0x8(%ebp),%eax
80107e69:	0f b6 00             	movzbl (%eax),%eax
80107e6c:	84 c0                	test   %al,%al
80107e6e:	75 db                	jne    80107e4b <uart_debugs+0x8>
  }
}
80107e70:	90                   	nop
80107e71:	90                   	nop
80107e72:	c9                   	leave  
80107e73:	c3                   	ret    

80107e74 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80107e74:	55                   	push   %ebp
80107e75:	89 e5                	mov    %esp,%ebp
80107e77:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107e7a:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80107e81:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107e84:	8b 50 14             	mov    0x14(%eax),%edx
80107e87:	8b 40 10             	mov    0x10(%eax),%eax
80107e8a:	a3 48 6c 19 80       	mov    %eax,0x80196c48
  gpu.vram_size = boot_param->graphic_config.frame_size;
80107e8f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107e92:	8b 50 1c             	mov    0x1c(%eax),%edx
80107e95:	8b 40 18             	mov    0x18(%eax),%eax
80107e98:	a3 50 6c 19 80       	mov    %eax,0x80196c50
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80107e9d:	8b 15 50 6c 19 80    	mov    0x80196c50,%edx
80107ea3:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
80107ea8:	29 d0                	sub    %edx,%eax
80107eaa:	a3 4c 6c 19 80       	mov    %eax,0x80196c4c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80107eaf:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107eb2:	8b 50 24             	mov    0x24(%eax),%edx
80107eb5:	8b 40 20             	mov    0x20(%eax),%eax
80107eb8:	a3 54 6c 19 80       	mov    %eax,0x80196c54
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80107ebd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107ec0:	8b 50 2c             	mov    0x2c(%eax),%edx
80107ec3:	8b 40 28             	mov    0x28(%eax),%eax
80107ec6:	a3 58 6c 19 80       	mov    %eax,0x80196c58
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80107ecb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107ece:	8b 50 34             	mov    0x34(%eax),%edx
80107ed1:	8b 40 30             	mov    0x30(%eax),%eax
80107ed4:	a3 5c 6c 19 80       	mov    %eax,0x80196c5c
}
80107ed9:	90                   	nop
80107eda:	c9                   	leave  
80107edb:	c3                   	ret    

80107edc <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80107edc:	55                   	push   %ebp
80107edd:	89 e5                	mov    %esp,%ebp
80107edf:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80107ee2:	8b 15 5c 6c 19 80    	mov    0x80196c5c,%edx
80107ee8:	8b 45 0c             	mov    0xc(%ebp),%eax
80107eeb:	0f af d0             	imul   %eax,%edx
80107eee:	8b 45 08             	mov    0x8(%ebp),%eax
80107ef1:	01 d0                	add    %edx,%eax
80107ef3:	c1 e0 02             	shl    $0x2,%eax
80107ef6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80107ef9:	8b 15 4c 6c 19 80    	mov    0x80196c4c,%edx
80107eff:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107f02:	01 d0                	add    %edx,%eax
80107f04:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80107f07:	8b 45 10             	mov    0x10(%ebp),%eax
80107f0a:	0f b6 10             	movzbl (%eax),%edx
80107f0d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107f10:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80107f12:	8b 45 10             	mov    0x10(%ebp),%eax
80107f15:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80107f19:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107f1c:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80107f1f:	8b 45 10             	mov    0x10(%ebp),%eax
80107f22:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80107f26:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107f29:	88 50 02             	mov    %dl,0x2(%eax)
}
80107f2c:	90                   	nop
80107f2d:	c9                   	leave  
80107f2e:	c3                   	ret    

80107f2f <graphic_scroll_up>:

void graphic_scroll_up(int height){
80107f2f:	55                   	push   %ebp
80107f30:	89 e5                	mov    %esp,%ebp
80107f32:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80107f35:	8b 15 5c 6c 19 80    	mov    0x80196c5c,%edx
80107f3b:	8b 45 08             	mov    0x8(%ebp),%eax
80107f3e:	0f af c2             	imul   %edx,%eax
80107f41:	c1 e0 02             	shl    $0x2,%eax
80107f44:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80107f47:	a1 50 6c 19 80       	mov    0x80196c50,%eax
80107f4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107f4f:	29 d0                	sub    %edx,%eax
80107f51:	8b 0d 4c 6c 19 80    	mov    0x80196c4c,%ecx
80107f57:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107f5a:	01 ca                	add    %ecx,%edx
80107f5c:	89 d1                	mov    %edx,%ecx
80107f5e:	8b 15 4c 6c 19 80    	mov    0x80196c4c,%edx
80107f64:	83 ec 04             	sub    $0x4,%esp
80107f67:	50                   	push   %eax
80107f68:	51                   	push   %ecx
80107f69:	52                   	push   %edx
80107f6a:	e8 01 cc ff ff       	call   80104b70 <memmove>
80107f6f:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80107f72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f75:	8b 0d 4c 6c 19 80    	mov    0x80196c4c,%ecx
80107f7b:	8b 15 50 6c 19 80    	mov    0x80196c50,%edx
80107f81:	01 ca                	add    %ecx,%edx
80107f83:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80107f86:	29 ca                	sub    %ecx,%edx
80107f88:	83 ec 04             	sub    $0x4,%esp
80107f8b:	50                   	push   %eax
80107f8c:	6a 00                	push   $0x0
80107f8e:	52                   	push   %edx
80107f8f:	e8 1d cb ff ff       	call   80104ab1 <memset>
80107f94:	83 c4 10             	add    $0x10,%esp
}
80107f97:	90                   	nop
80107f98:	c9                   	leave  
80107f99:	c3                   	ret    

80107f9a <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80107f9a:	55                   	push   %ebp
80107f9b:	89 e5                	mov    %esp,%ebp
80107f9d:	53                   	push   %ebx
80107f9e:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80107fa1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107fa8:	e9 b1 00 00 00       	jmp    8010805e <font_render+0xc4>
    for(int j=14;j>-1;j--){
80107fad:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80107fb4:	e9 97 00 00 00       	jmp    80108050 <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
80107fb9:	8b 45 10             	mov    0x10(%ebp),%eax
80107fbc:	83 e8 20             	sub    $0x20,%eax
80107fbf:	6b d0 1e             	imul   $0x1e,%eax,%edx
80107fc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fc5:	01 d0                	add    %edx,%eax
80107fc7:	0f b7 84 00 00 a8 10 	movzwl -0x7fef5800(%eax,%eax,1),%eax
80107fce:	80 
80107fcf:	0f b7 d0             	movzwl %ax,%edx
80107fd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fd5:	bb 01 00 00 00       	mov    $0x1,%ebx
80107fda:	89 c1                	mov    %eax,%ecx
80107fdc:	d3 e3                	shl    %cl,%ebx
80107fde:	89 d8                	mov    %ebx,%eax
80107fe0:	21 d0                	and    %edx,%eax
80107fe2:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80107fe5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fe8:	ba 01 00 00 00       	mov    $0x1,%edx
80107fed:	89 c1                	mov    %eax,%ecx
80107fef:	d3 e2                	shl    %cl,%edx
80107ff1:	89 d0                	mov    %edx,%eax
80107ff3:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80107ff6:	75 2b                	jne    80108023 <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80107ff8:	8b 55 0c             	mov    0xc(%ebp),%edx
80107ffb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ffe:	01 c2                	add    %eax,%edx
80108000:	b8 0e 00 00 00       	mov    $0xe,%eax
80108005:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108008:	89 c1                	mov    %eax,%ecx
8010800a:	8b 45 08             	mov    0x8(%ebp),%eax
8010800d:	01 c8                	add    %ecx,%eax
8010800f:	83 ec 04             	sub    $0x4,%esp
80108012:	68 e0 f4 10 80       	push   $0x8010f4e0
80108017:	52                   	push   %edx
80108018:	50                   	push   %eax
80108019:	e8 be fe ff ff       	call   80107edc <graphic_draw_pixel>
8010801e:	83 c4 10             	add    $0x10,%esp
80108021:	eb 29                	jmp    8010804c <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
80108023:	8b 55 0c             	mov    0xc(%ebp),%edx
80108026:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108029:	01 c2                	add    %eax,%edx
8010802b:	b8 0e 00 00 00       	mov    $0xe,%eax
80108030:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108033:	89 c1                	mov    %eax,%ecx
80108035:	8b 45 08             	mov    0x8(%ebp),%eax
80108038:	01 c8                	add    %ecx,%eax
8010803a:	83 ec 04             	sub    $0x4,%esp
8010803d:	68 60 6c 19 80       	push   $0x80196c60
80108042:	52                   	push   %edx
80108043:	50                   	push   %eax
80108044:	e8 93 fe ff ff       	call   80107edc <graphic_draw_pixel>
80108049:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
8010804c:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108050:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108054:	0f 89 5f ff ff ff    	jns    80107fb9 <font_render+0x1f>
  for(int i=0;i<30;i++){
8010805a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010805e:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80108062:	0f 8e 45 ff ff ff    	jle    80107fad <font_render+0x13>
      }
    }
  }
}
80108068:	90                   	nop
80108069:	90                   	nop
8010806a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010806d:	c9                   	leave  
8010806e:	c3                   	ret    

8010806f <font_render_string>:

void font_render_string(char *string,int row){
8010806f:	55                   	push   %ebp
80108070:	89 e5                	mov    %esp,%ebp
80108072:	53                   	push   %ebx
80108073:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108076:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
8010807d:	eb 33                	jmp    801080b2 <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
8010807f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108082:	8b 45 08             	mov    0x8(%ebp),%eax
80108085:	01 d0                	add    %edx,%eax
80108087:	0f b6 00             	movzbl (%eax),%eax
8010808a:	0f be c8             	movsbl %al,%ecx
8010808d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108090:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108093:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80108096:	89 d8                	mov    %ebx,%eax
80108098:	c1 e0 04             	shl    $0x4,%eax
8010809b:	29 d8                	sub    %ebx,%eax
8010809d:	83 c0 02             	add    $0x2,%eax
801080a0:	83 ec 04             	sub    $0x4,%esp
801080a3:	51                   	push   %ecx
801080a4:	52                   	push   %edx
801080a5:	50                   	push   %eax
801080a6:	e8 ef fe ff ff       	call   80107f9a <font_render>
801080ab:	83 c4 10             	add    $0x10,%esp
    i++;
801080ae:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
801080b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801080b5:	8b 45 08             	mov    0x8(%ebp),%eax
801080b8:	01 d0                	add    %edx,%eax
801080ba:	0f b6 00             	movzbl (%eax),%eax
801080bd:	84 c0                	test   %al,%al
801080bf:	74 06                	je     801080c7 <font_render_string+0x58>
801080c1:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
801080c5:	7e b8                	jle    8010807f <font_render_string+0x10>
  }
}
801080c7:	90                   	nop
801080c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801080cb:	c9                   	leave  
801080cc:	c3                   	ret    

801080cd <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
801080cd:	55                   	push   %ebp
801080ce:	89 e5                	mov    %esp,%ebp
801080d0:	53                   	push   %ebx
801080d1:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
801080d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801080db:	eb 6b                	jmp    80108148 <pci_init+0x7b>
    for(int j=0;j<32;j++){
801080dd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801080e4:	eb 58                	jmp    8010813e <pci_init+0x71>
      for(int k=0;k<8;k++){
801080e6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801080ed:	eb 45                	jmp    80108134 <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
801080ef:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801080f2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801080f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080f8:	83 ec 0c             	sub    $0xc,%esp
801080fb:	8d 5d e8             	lea    -0x18(%ebp),%ebx
801080fe:	53                   	push   %ebx
801080ff:	6a 00                	push   $0x0
80108101:	51                   	push   %ecx
80108102:	52                   	push   %edx
80108103:	50                   	push   %eax
80108104:	e8 b0 00 00 00       	call   801081b9 <pci_access_config>
80108109:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
8010810c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010810f:	0f b7 c0             	movzwl %ax,%eax
80108112:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108117:	74 17                	je     80108130 <pci_init+0x63>
        pci_init_device(i,j,k);
80108119:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010811c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010811f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108122:	83 ec 04             	sub    $0x4,%esp
80108125:	51                   	push   %ecx
80108126:	52                   	push   %edx
80108127:	50                   	push   %eax
80108128:	e8 37 01 00 00       	call   80108264 <pci_init_device>
8010812d:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108130:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108134:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108138:	7e b5                	jle    801080ef <pci_init+0x22>
    for(int j=0;j<32;j++){
8010813a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010813e:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108142:	7e a2                	jle    801080e6 <pci_init+0x19>
  for(int i=0;i<256;i++){
80108144:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108148:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010814f:	7e 8c                	jle    801080dd <pci_init+0x10>
      }
      }
    }
  }
}
80108151:	90                   	nop
80108152:	90                   	nop
80108153:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108156:	c9                   	leave  
80108157:	c3                   	ret    

80108158 <pci_write_config>:

void pci_write_config(uint config){
80108158:	55                   	push   %ebp
80108159:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
8010815b:	8b 45 08             	mov    0x8(%ebp),%eax
8010815e:	ba f8 0c 00 00       	mov    $0xcf8,%edx
80108163:	89 c0                	mov    %eax,%eax
80108165:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108166:	90                   	nop
80108167:	5d                   	pop    %ebp
80108168:	c3                   	ret    

80108169 <pci_write_data>:

void pci_write_data(uint config){
80108169:	55                   	push   %ebp
8010816a:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
8010816c:	8b 45 08             	mov    0x8(%ebp),%eax
8010816f:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108174:	89 c0                	mov    %eax,%eax
80108176:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108177:	90                   	nop
80108178:	5d                   	pop    %ebp
80108179:	c3                   	ret    

8010817a <pci_read_config>:
uint pci_read_config(){
8010817a:	55                   	push   %ebp
8010817b:	89 e5                	mov    %esp,%ebp
8010817d:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108180:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108185:	ed                   	in     (%dx),%eax
80108186:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108189:	83 ec 0c             	sub    $0xc,%esp
8010818c:	68 c8 00 00 00       	push   $0xc8
80108191:	e8 92 a9 ff ff       	call   80102b28 <microdelay>
80108196:	83 c4 10             	add    $0x10,%esp
  return data;
80108199:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010819c:	c9                   	leave  
8010819d:	c3                   	ret    

8010819e <pci_test>:


void pci_test(){
8010819e:	55                   	push   %ebp
8010819f:	89 e5                	mov    %esp,%ebp
801081a1:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
801081a4:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
801081ab:	ff 75 fc             	push   -0x4(%ebp)
801081ae:	e8 a5 ff ff ff       	call   80108158 <pci_write_config>
801081b3:	83 c4 04             	add    $0x4,%esp
}
801081b6:	90                   	nop
801081b7:	c9                   	leave  
801081b8:	c3                   	ret    

801081b9 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
801081b9:	55                   	push   %ebp
801081ba:	89 e5                	mov    %esp,%ebp
801081bc:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801081bf:	8b 45 08             	mov    0x8(%ebp),%eax
801081c2:	c1 e0 10             	shl    $0x10,%eax
801081c5:	25 00 00 ff 00       	and    $0xff0000,%eax
801081ca:	89 c2                	mov    %eax,%edx
801081cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801081cf:	c1 e0 0b             	shl    $0xb,%eax
801081d2:	0f b7 c0             	movzwl %ax,%eax
801081d5:	09 c2                	or     %eax,%edx
801081d7:	8b 45 10             	mov    0x10(%ebp),%eax
801081da:	c1 e0 08             	shl    $0x8,%eax
801081dd:	25 00 07 00 00       	and    $0x700,%eax
801081e2:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801081e4:	8b 45 14             	mov    0x14(%ebp),%eax
801081e7:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801081ec:	09 d0                	or     %edx,%eax
801081ee:	0d 00 00 00 80       	or     $0x80000000,%eax
801081f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
801081f6:	ff 75 f4             	push   -0xc(%ebp)
801081f9:	e8 5a ff ff ff       	call   80108158 <pci_write_config>
801081fe:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108201:	e8 74 ff ff ff       	call   8010817a <pci_read_config>
80108206:	8b 55 18             	mov    0x18(%ebp),%edx
80108209:	89 02                	mov    %eax,(%edx)
}
8010820b:	90                   	nop
8010820c:	c9                   	leave  
8010820d:	c3                   	ret    

8010820e <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
8010820e:	55                   	push   %ebp
8010820f:	89 e5                	mov    %esp,%ebp
80108211:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108214:	8b 45 08             	mov    0x8(%ebp),%eax
80108217:	c1 e0 10             	shl    $0x10,%eax
8010821a:	25 00 00 ff 00       	and    $0xff0000,%eax
8010821f:	89 c2                	mov    %eax,%edx
80108221:	8b 45 0c             	mov    0xc(%ebp),%eax
80108224:	c1 e0 0b             	shl    $0xb,%eax
80108227:	0f b7 c0             	movzwl %ax,%eax
8010822a:	09 c2                	or     %eax,%edx
8010822c:	8b 45 10             	mov    0x10(%ebp),%eax
8010822f:	c1 e0 08             	shl    $0x8,%eax
80108232:	25 00 07 00 00       	and    $0x700,%eax
80108237:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108239:	8b 45 14             	mov    0x14(%ebp),%eax
8010823c:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108241:	09 d0                	or     %edx,%eax
80108243:	0d 00 00 00 80       	or     $0x80000000,%eax
80108248:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
8010824b:	ff 75 fc             	push   -0x4(%ebp)
8010824e:	e8 05 ff ff ff       	call   80108158 <pci_write_config>
80108253:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108256:	ff 75 18             	push   0x18(%ebp)
80108259:	e8 0b ff ff ff       	call   80108169 <pci_write_data>
8010825e:	83 c4 04             	add    $0x4,%esp
}
80108261:	90                   	nop
80108262:	c9                   	leave  
80108263:	c3                   	ret    

80108264 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80108264:	55                   	push   %ebp
80108265:	89 e5                	mov    %esp,%ebp
80108267:	53                   	push   %ebx
80108268:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
8010826b:	8b 45 08             	mov    0x8(%ebp),%eax
8010826e:	a2 64 6c 19 80       	mov    %al,0x80196c64
  dev.device_num = device_num;
80108273:	8b 45 0c             	mov    0xc(%ebp),%eax
80108276:	a2 65 6c 19 80       	mov    %al,0x80196c65
  dev.function_num = function_num;
8010827b:	8b 45 10             	mov    0x10(%ebp),%eax
8010827e:	a2 66 6c 19 80       	mov    %al,0x80196c66
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108283:	ff 75 10             	push   0x10(%ebp)
80108286:	ff 75 0c             	push   0xc(%ebp)
80108289:	ff 75 08             	push   0x8(%ebp)
8010828c:	68 44 be 10 80       	push   $0x8010be44
80108291:	e8 5e 81 ff ff       	call   801003f4 <cprintf>
80108296:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108299:	83 ec 0c             	sub    $0xc,%esp
8010829c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010829f:	50                   	push   %eax
801082a0:	6a 00                	push   $0x0
801082a2:	ff 75 10             	push   0x10(%ebp)
801082a5:	ff 75 0c             	push   0xc(%ebp)
801082a8:	ff 75 08             	push   0x8(%ebp)
801082ab:	e8 09 ff ff ff       	call   801081b9 <pci_access_config>
801082b0:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
801082b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082b6:	c1 e8 10             	shr    $0x10,%eax
801082b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
801082bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082bf:	25 ff ff 00 00       	and    $0xffff,%eax
801082c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
801082c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082ca:	a3 68 6c 19 80       	mov    %eax,0x80196c68
  dev.vendor_id = vendor_id;
801082cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082d2:	a3 6c 6c 19 80       	mov    %eax,0x80196c6c
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
801082d7:	83 ec 04             	sub    $0x4,%esp
801082da:	ff 75 f0             	push   -0x10(%ebp)
801082dd:	ff 75 f4             	push   -0xc(%ebp)
801082e0:	68 78 be 10 80       	push   $0x8010be78
801082e5:	e8 0a 81 ff ff       	call   801003f4 <cprintf>
801082ea:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
801082ed:	83 ec 0c             	sub    $0xc,%esp
801082f0:	8d 45 ec             	lea    -0x14(%ebp),%eax
801082f3:	50                   	push   %eax
801082f4:	6a 08                	push   $0x8
801082f6:	ff 75 10             	push   0x10(%ebp)
801082f9:	ff 75 0c             	push   0xc(%ebp)
801082fc:	ff 75 08             	push   0x8(%ebp)
801082ff:	e8 b5 fe ff ff       	call   801081b9 <pci_access_config>
80108304:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108307:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010830a:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
8010830d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108310:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108313:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108316:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108319:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010831c:	0f b6 c0             	movzbl %al,%eax
8010831f:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108322:	c1 eb 18             	shr    $0x18,%ebx
80108325:	83 ec 0c             	sub    $0xc,%esp
80108328:	51                   	push   %ecx
80108329:	52                   	push   %edx
8010832a:	50                   	push   %eax
8010832b:	53                   	push   %ebx
8010832c:	68 9c be 10 80       	push   $0x8010be9c
80108331:	e8 be 80 ff ff       	call   801003f4 <cprintf>
80108336:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108339:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010833c:	c1 e8 18             	shr    $0x18,%eax
8010833f:	a2 70 6c 19 80       	mov    %al,0x80196c70
  dev.sub_class = (data>>16)&0xFF;
80108344:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108347:	c1 e8 10             	shr    $0x10,%eax
8010834a:	a2 71 6c 19 80       	mov    %al,0x80196c71
  dev.interface = (data>>8)&0xFF;
8010834f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108352:	c1 e8 08             	shr    $0x8,%eax
80108355:	a2 72 6c 19 80       	mov    %al,0x80196c72
  dev.revision_id = data&0xFF;
8010835a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010835d:	a2 73 6c 19 80       	mov    %al,0x80196c73
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108362:	83 ec 0c             	sub    $0xc,%esp
80108365:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108368:	50                   	push   %eax
80108369:	6a 10                	push   $0x10
8010836b:	ff 75 10             	push   0x10(%ebp)
8010836e:	ff 75 0c             	push   0xc(%ebp)
80108371:	ff 75 08             	push   0x8(%ebp)
80108374:	e8 40 fe ff ff       	call   801081b9 <pci_access_config>
80108379:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
8010837c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010837f:	a3 74 6c 19 80       	mov    %eax,0x80196c74
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108384:	83 ec 0c             	sub    $0xc,%esp
80108387:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010838a:	50                   	push   %eax
8010838b:	6a 14                	push   $0x14
8010838d:	ff 75 10             	push   0x10(%ebp)
80108390:	ff 75 0c             	push   0xc(%ebp)
80108393:	ff 75 08             	push   0x8(%ebp)
80108396:	e8 1e fe ff ff       	call   801081b9 <pci_access_config>
8010839b:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
8010839e:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083a1:	a3 78 6c 19 80       	mov    %eax,0x80196c78
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
801083a6:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
801083ad:	75 5a                	jne    80108409 <pci_init_device+0x1a5>
801083af:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
801083b6:	75 51                	jne    80108409 <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
801083b8:	83 ec 0c             	sub    $0xc,%esp
801083bb:	68 e1 be 10 80       	push   $0x8010bee1
801083c0:	e8 2f 80 ff ff       	call   801003f4 <cprintf>
801083c5:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
801083c8:	83 ec 0c             	sub    $0xc,%esp
801083cb:	8d 45 ec             	lea    -0x14(%ebp),%eax
801083ce:	50                   	push   %eax
801083cf:	68 f0 00 00 00       	push   $0xf0
801083d4:	ff 75 10             	push   0x10(%ebp)
801083d7:	ff 75 0c             	push   0xc(%ebp)
801083da:	ff 75 08             	push   0x8(%ebp)
801083dd:	e8 d7 fd ff ff       	call   801081b9 <pci_access_config>
801083e2:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
801083e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083e8:	83 ec 08             	sub    $0x8,%esp
801083eb:	50                   	push   %eax
801083ec:	68 fb be 10 80       	push   $0x8010befb
801083f1:	e8 fe 7f ff ff       	call   801003f4 <cprintf>
801083f6:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
801083f9:	83 ec 0c             	sub    $0xc,%esp
801083fc:	68 64 6c 19 80       	push   $0x80196c64
80108401:	e8 09 00 00 00       	call   8010840f <i8254_init>
80108406:	83 c4 10             	add    $0x10,%esp
  }
}
80108409:	90                   	nop
8010840a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010840d:	c9                   	leave  
8010840e:	c3                   	ret    

8010840f <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
8010840f:	55                   	push   %ebp
80108410:	89 e5                	mov    %esp,%ebp
80108412:	53                   	push   %ebx
80108413:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108416:	8b 45 08             	mov    0x8(%ebp),%eax
80108419:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010841d:	0f b6 c8             	movzbl %al,%ecx
80108420:	8b 45 08             	mov    0x8(%ebp),%eax
80108423:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108427:	0f b6 d0             	movzbl %al,%edx
8010842a:	8b 45 08             	mov    0x8(%ebp),%eax
8010842d:	0f b6 00             	movzbl (%eax),%eax
80108430:	0f b6 c0             	movzbl %al,%eax
80108433:	83 ec 0c             	sub    $0xc,%esp
80108436:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108439:	53                   	push   %ebx
8010843a:	6a 04                	push   $0x4
8010843c:	51                   	push   %ecx
8010843d:	52                   	push   %edx
8010843e:	50                   	push   %eax
8010843f:	e8 75 fd ff ff       	call   801081b9 <pci_access_config>
80108444:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108447:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010844a:	83 c8 04             	or     $0x4,%eax
8010844d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108450:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108453:	8b 45 08             	mov    0x8(%ebp),%eax
80108456:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010845a:	0f b6 c8             	movzbl %al,%ecx
8010845d:	8b 45 08             	mov    0x8(%ebp),%eax
80108460:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108464:	0f b6 d0             	movzbl %al,%edx
80108467:	8b 45 08             	mov    0x8(%ebp),%eax
8010846a:	0f b6 00             	movzbl (%eax),%eax
8010846d:	0f b6 c0             	movzbl %al,%eax
80108470:	83 ec 0c             	sub    $0xc,%esp
80108473:	53                   	push   %ebx
80108474:	6a 04                	push   $0x4
80108476:	51                   	push   %ecx
80108477:	52                   	push   %edx
80108478:	50                   	push   %eax
80108479:	e8 90 fd ff ff       	call   8010820e <pci_write_config_register>
8010847e:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108481:	8b 45 08             	mov    0x8(%ebp),%eax
80108484:	8b 40 10             	mov    0x10(%eax),%eax
80108487:	05 00 00 00 40       	add    $0x40000000,%eax
8010848c:	a3 7c 6c 19 80       	mov    %eax,0x80196c7c
  uint *ctrl = (uint *)base_addr;
80108491:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108496:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108499:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
8010849e:	05 d8 00 00 00       	add    $0xd8,%eax
801084a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
801084a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084a9:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
801084af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084b2:	8b 00                	mov    (%eax),%eax
801084b4:	0d 00 00 00 04       	or     $0x4000000,%eax
801084b9:	89 c2                	mov    %eax,%edx
801084bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084be:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
801084c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084c3:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
801084c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084cc:	8b 00                	mov    (%eax),%eax
801084ce:	83 c8 40             	or     $0x40,%eax
801084d1:	89 c2                	mov    %eax,%edx
801084d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084d6:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
801084d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084db:	8b 10                	mov    (%eax),%edx
801084dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084e0:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
801084e2:	83 ec 0c             	sub    $0xc,%esp
801084e5:	68 10 bf 10 80       	push   $0x8010bf10
801084ea:	e8 05 7f ff ff       	call   801003f4 <cprintf>
801084ef:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
801084f2:	e8 9a a2 ff ff       	call   80102791 <kalloc>
801084f7:	a3 88 6c 19 80       	mov    %eax,0x80196c88
  *intr_addr = 0;
801084fc:	a1 88 6c 19 80       	mov    0x80196c88,%eax
80108501:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108507:	a1 88 6c 19 80       	mov    0x80196c88,%eax
8010850c:	83 ec 08             	sub    $0x8,%esp
8010850f:	50                   	push   %eax
80108510:	68 32 bf 10 80       	push   $0x8010bf32
80108515:	e8 da 7e ff ff       	call   801003f4 <cprintf>
8010851a:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
8010851d:	e8 50 00 00 00       	call   80108572 <i8254_init_recv>
  i8254_init_send();
80108522:	e8 69 03 00 00       	call   80108890 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108527:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010852e:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108531:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108538:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
8010853b:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108542:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108545:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010854c:	0f b6 c0             	movzbl %al,%eax
8010854f:	83 ec 0c             	sub    $0xc,%esp
80108552:	53                   	push   %ebx
80108553:	51                   	push   %ecx
80108554:	52                   	push   %edx
80108555:	50                   	push   %eax
80108556:	68 40 bf 10 80       	push   $0x8010bf40
8010855b:	e8 94 7e ff ff       	call   801003f4 <cprintf>
80108560:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108563:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108566:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
8010856c:	90                   	nop
8010856d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108570:	c9                   	leave  
80108571:	c3                   	ret    

80108572 <i8254_init_recv>:

void i8254_init_recv(){
80108572:	55                   	push   %ebp
80108573:	89 e5                	mov    %esp,%ebp
80108575:	57                   	push   %edi
80108576:	56                   	push   %esi
80108577:	53                   	push   %ebx
80108578:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
8010857b:	83 ec 0c             	sub    $0xc,%esp
8010857e:	6a 00                	push   $0x0
80108580:	e8 e8 04 00 00       	call   80108a6d <i8254_read_eeprom>
80108585:	83 c4 10             	add    $0x10,%esp
80108588:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
8010858b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010858e:	a2 80 6c 19 80       	mov    %al,0x80196c80
  mac_addr[1] = data_l>>8;
80108593:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108596:	c1 e8 08             	shr    $0x8,%eax
80108599:	a2 81 6c 19 80       	mov    %al,0x80196c81
  uint data_m = i8254_read_eeprom(0x1);
8010859e:	83 ec 0c             	sub    $0xc,%esp
801085a1:	6a 01                	push   $0x1
801085a3:	e8 c5 04 00 00       	call   80108a6d <i8254_read_eeprom>
801085a8:	83 c4 10             	add    $0x10,%esp
801085ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
801085ae:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801085b1:	a2 82 6c 19 80       	mov    %al,0x80196c82
  mac_addr[3] = data_m>>8;
801085b6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801085b9:	c1 e8 08             	shr    $0x8,%eax
801085bc:	a2 83 6c 19 80       	mov    %al,0x80196c83
  uint data_h = i8254_read_eeprom(0x2);
801085c1:	83 ec 0c             	sub    $0xc,%esp
801085c4:	6a 02                	push   $0x2
801085c6:	e8 a2 04 00 00       	call   80108a6d <i8254_read_eeprom>
801085cb:	83 c4 10             	add    $0x10,%esp
801085ce:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
801085d1:	8b 45 d0             	mov    -0x30(%ebp),%eax
801085d4:	a2 84 6c 19 80       	mov    %al,0x80196c84
  mac_addr[5] = data_h>>8;
801085d9:	8b 45 d0             	mov    -0x30(%ebp),%eax
801085dc:	c1 e8 08             	shr    $0x8,%eax
801085df:	a2 85 6c 19 80       	mov    %al,0x80196c85
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
801085e4:	0f b6 05 85 6c 19 80 	movzbl 0x80196c85,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801085eb:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
801085ee:	0f b6 05 84 6c 19 80 	movzbl 0x80196c84,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801085f5:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
801085f8:	0f b6 05 83 6c 19 80 	movzbl 0x80196c83,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801085ff:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108602:	0f b6 05 82 6c 19 80 	movzbl 0x80196c82,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108609:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
8010860c:	0f b6 05 81 6c 19 80 	movzbl 0x80196c81,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108613:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108616:	0f b6 05 80 6c 19 80 	movzbl 0x80196c80,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010861d:	0f b6 c0             	movzbl %al,%eax
80108620:	83 ec 04             	sub    $0x4,%esp
80108623:	57                   	push   %edi
80108624:	56                   	push   %esi
80108625:	53                   	push   %ebx
80108626:	51                   	push   %ecx
80108627:	52                   	push   %edx
80108628:	50                   	push   %eax
80108629:	68 58 bf 10 80       	push   $0x8010bf58
8010862e:	e8 c1 7d ff ff       	call   801003f4 <cprintf>
80108633:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108636:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
8010863b:	05 00 54 00 00       	add    $0x5400,%eax
80108640:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108643:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108648:	05 04 54 00 00       	add    $0x5404,%eax
8010864d:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108650:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108653:	c1 e0 10             	shl    $0x10,%eax
80108656:	0b 45 d8             	or     -0x28(%ebp),%eax
80108659:	89 c2                	mov    %eax,%edx
8010865b:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010865e:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108660:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108663:	0d 00 00 00 80       	or     $0x80000000,%eax
80108668:	89 c2                	mov    %eax,%edx
8010866a:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010866d:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
8010866f:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108674:	05 00 52 00 00       	add    $0x5200,%eax
80108679:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
8010867c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108683:	eb 19                	jmp    8010869e <i8254_init_recv+0x12c>
    mta[i] = 0;
80108685:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108688:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010868f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108692:	01 d0                	add    %edx,%eax
80108694:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
8010869a:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010869e:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
801086a2:	7e e1                	jle    80108685 <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
801086a4:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801086a9:	05 d0 00 00 00       	add    $0xd0,%eax
801086ae:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
801086b1:	8b 45 c0             	mov    -0x40(%ebp),%eax
801086b4:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
801086ba:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801086bf:	05 c8 00 00 00       	add    $0xc8,%eax
801086c4:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
801086c7:	8b 45 bc             	mov    -0x44(%ebp),%eax
801086ca:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
801086d0:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801086d5:	05 28 28 00 00       	add    $0x2828,%eax
801086da:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
801086dd:	8b 45 b8             	mov    -0x48(%ebp),%eax
801086e0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
801086e6:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801086eb:	05 00 01 00 00       	add    $0x100,%eax
801086f0:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
801086f3:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801086f6:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
801086fc:	e8 90 a0 ff ff       	call   80102791 <kalloc>
80108701:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108704:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108709:	05 00 28 00 00       	add    $0x2800,%eax
8010870e:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108711:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108716:	05 04 28 00 00       	add    $0x2804,%eax
8010871b:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
8010871e:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108723:	05 08 28 00 00       	add    $0x2808,%eax
80108728:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
8010872b:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108730:	05 10 28 00 00       	add    $0x2810,%eax
80108735:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108738:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
8010873d:	05 18 28 00 00       	add    $0x2818,%eax
80108742:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108745:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108748:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010874e:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108751:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108753:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108756:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
8010875c:	8b 45 a4             	mov    -0x5c(%ebp),%eax
8010875f:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108765:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108768:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
8010876e:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108771:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108777:	8b 45 b0             	mov    -0x50(%ebp),%eax
8010877a:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
8010877d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108784:	eb 73                	jmp    801087f9 <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
80108786:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108789:	c1 e0 04             	shl    $0x4,%eax
8010878c:	89 c2                	mov    %eax,%edx
8010878e:	8b 45 98             	mov    -0x68(%ebp),%eax
80108791:	01 d0                	add    %edx,%eax
80108793:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
8010879a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010879d:	c1 e0 04             	shl    $0x4,%eax
801087a0:	89 c2                	mov    %eax,%edx
801087a2:	8b 45 98             	mov    -0x68(%ebp),%eax
801087a5:	01 d0                	add    %edx,%eax
801087a7:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
801087ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
801087b0:	c1 e0 04             	shl    $0x4,%eax
801087b3:	89 c2                	mov    %eax,%edx
801087b5:	8b 45 98             	mov    -0x68(%ebp),%eax
801087b8:	01 d0                	add    %edx,%eax
801087ba:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
801087c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801087c3:	c1 e0 04             	shl    $0x4,%eax
801087c6:	89 c2                	mov    %eax,%edx
801087c8:	8b 45 98             	mov    -0x68(%ebp),%eax
801087cb:	01 d0                	add    %edx,%eax
801087cd:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
801087d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801087d4:	c1 e0 04             	shl    $0x4,%eax
801087d7:	89 c2                	mov    %eax,%edx
801087d9:	8b 45 98             	mov    -0x68(%ebp),%eax
801087dc:	01 d0                	add    %edx,%eax
801087de:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
801087e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801087e5:	c1 e0 04             	shl    $0x4,%eax
801087e8:	89 c2                	mov    %eax,%edx
801087ea:	8b 45 98             	mov    -0x68(%ebp),%eax
801087ed:	01 d0                	add    %edx,%eax
801087ef:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
801087f5:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
801087f9:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108800:	7e 84                	jle    80108786 <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108802:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108809:	eb 57                	jmp    80108862 <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
8010880b:	e8 81 9f ff ff       	call   80102791 <kalloc>
80108810:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108813:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108817:	75 12                	jne    8010882b <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80108819:	83 ec 0c             	sub    $0xc,%esp
8010881c:	68 78 bf 10 80       	push   $0x8010bf78
80108821:	e8 ce 7b ff ff       	call   801003f4 <cprintf>
80108826:	83 c4 10             	add    $0x10,%esp
      break;
80108829:	eb 3d                	jmp    80108868 <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
8010882b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010882e:	c1 e0 04             	shl    $0x4,%eax
80108831:	89 c2                	mov    %eax,%edx
80108833:	8b 45 98             	mov    -0x68(%ebp),%eax
80108836:	01 d0                	add    %edx,%eax
80108838:	8b 55 94             	mov    -0x6c(%ebp),%edx
8010883b:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108841:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108843:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108846:	83 c0 01             	add    $0x1,%eax
80108849:	c1 e0 04             	shl    $0x4,%eax
8010884c:	89 c2                	mov    %eax,%edx
8010884e:	8b 45 98             	mov    -0x68(%ebp),%eax
80108851:	01 d0                	add    %edx,%eax
80108853:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108856:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
8010885c:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
8010885e:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108862:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108866:	7e a3                	jle    8010880b <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
80108868:	8b 45 b4             	mov    -0x4c(%ebp),%eax
8010886b:	8b 00                	mov    (%eax),%eax
8010886d:	83 c8 02             	or     $0x2,%eax
80108870:	89 c2                	mov    %eax,%edx
80108872:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108875:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108877:	83 ec 0c             	sub    $0xc,%esp
8010887a:	68 98 bf 10 80       	push   $0x8010bf98
8010887f:	e8 70 7b ff ff       	call   801003f4 <cprintf>
80108884:	83 c4 10             	add    $0x10,%esp
}
80108887:	90                   	nop
80108888:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010888b:	5b                   	pop    %ebx
8010888c:	5e                   	pop    %esi
8010888d:	5f                   	pop    %edi
8010888e:	5d                   	pop    %ebp
8010888f:	c3                   	ret    

80108890 <i8254_init_send>:

void i8254_init_send(){
80108890:	55                   	push   %ebp
80108891:	89 e5                	mov    %esp,%ebp
80108893:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108896:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
8010889b:	05 28 38 00 00       	add    $0x3828,%eax
801088a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
801088a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088a6:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
801088ac:	e8 e0 9e ff ff       	call   80102791 <kalloc>
801088b1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
801088b4:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801088b9:	05 00 38 00 00       	add    $0x3800,%eax
801088be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
801088c1:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801088c6:	05 04 38 00 00       	add    $0x3804,%eax
801088cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
801088ce:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801088d3:	05 08 38 00 00       	add    $0x3808,%eax
801088d8:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
801088db:	8b 45 e8             	mov    -0x18(%ebp),%eax
801088de:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801088e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801088e7:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
801088e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801088ec:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
801088f2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801088f5:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
801088fb:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108900:	05 10 38 00 00       	add    $0x3810,%eax
80108905:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108908:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
8010890d:	05 18 38 00 00       	add    $0x3818,%eax
80108912:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108915:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108918:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
8010891e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108921:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108927:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010892a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
8010892d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108934:	e9 82 00 00 00       	jmp    801089bb <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80108939:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010893c:	c1 e0 04             	shl    $0x4,%eax
8010893f:	89 c2                	mov    %eax,%edx
80108941:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108944:	01 d0                	add    %edx,%eax
80108946:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
8010894d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108950:	c1 e0 04             	shl    $0x4,%eax
80108953:	89 c2                	mov    %eax,%edx
80108955:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108958:	01 d0                	add    %edx,%eax
8010895a:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108960:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108963:	c1 e0 04             	shl    $0x4,%eax
80108966:	89 c2                	mov    %eax,%edx
80108968:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010896b:	01 d0                	add    %edx,%eax
8010896d:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108971:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108974:	c1 e0 04             	shl    $0x4,%eax
80108977:	89 c2                	mov    %eax,%edx
80108979:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010897c:	01 d0                	add    %edx,%eax
8010897e:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108982:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108985:	c1 e0 04             	shl    $0x4,%eax
80108988:	89 c2                	mov    %eax,%edx
8010898a:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010898d:	01 d0                	add    %edx,%eax
8010898f:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108993:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108996:	c1 e0 04             	shl    $0x4,%eax
80108999:	89 c2                	mov    %eax,%edx
8010899b:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010899e:	01 d0                	add    %edx,%eax
801089a0:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
801089a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089a7:	c1 e0 04             	shl    $0x4,%eax
801089aa:	89 c2                	mov    %eax,%edx
801089ac:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089af:	01 d0                	add    %edx,%eax
801089b1:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
801089b7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801089bb:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801089c2:	0f 8e 71 ff ff ff    	jle    80108939 <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
801089c8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801089cf:	eb 57                	jmp    80108a28 <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
801089d1:	e8 bb 9d ff ff       	call   80102791 <kalloc>
801089d6:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
801089d9:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
801089dd:	75 12                	jne    801089f1 <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
801089df:	83 ec 0c             	sub    $0xc,%esp
801089e2:	68 78 bf 10 80       	push   $0x8010bf78
801089e7:	e8 08 7a ff ff       	call   801003f4 <cprintf>
801089ec:	83 c4 10             	add    $0x10,%esp
      break;
801089ef:	eb 3d                	jmp    80108a2e <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
801089f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089f4:	c1 e0 04             	shl    $0x4,%eax
801089f7:	89 c2                	mov    %eax,%edx
801089f9:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089fc:	01 d0                	add    %edx,%eax
801089fe:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108a01:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108a07:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108a09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a0c:	83 c0 01             	add    $0x1,%eax
80108a0f:	c1 e0 04             	shl    $0x4,%eax
80108a12:	89 c2                	mov    %eax,%edx
80108a14:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a17:	01 d0                	add    %edx,%eax
80108a19:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108a1c:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108a22:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108a24:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108a28:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108a2c:	7e a3                	jle    801089d1 <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108a2e:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108a33:	05 00 04 00 00       	add    $0x400,%eax
80108a38:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108a3b:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108a3e:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108a44:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108a49:	05 10 04 00 00       	add    $0x410,%eax
80108a4e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108a51:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108a54:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108a5a:	83 ec 0c             	sub    $0xc,%esp
80108a5d:	68 b8 bf 10 80       	push   $0x8010bfb8
80108a62:	e8 8d 79 ff ff       	call   801003f4 <cprintf>
80108a67:	83 c4 10             	add    $0x10,%esp

}
80108a6a:	90                   	nop
80108a6b:	c9                   	leave  
80108a6c:	c3                   	ret    

80108a6d <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108a6d:	55                   	push   %ebp
80108a6e:	89 e5                	mov    %esp,%ebp
80108a70:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80108a73:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108a78:	83 c0 14             	add    $0x14,%eax
80108a7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108a7e:	8b 45 08             	mov    0x8(%ebp),%eax
80108a81:	c1 e0 08             	shl    $0x8,%eax
80108a84:	0f b7 c0             	movzwl %ax,%eax
80108a87:	83 c8 01             	or     $0x1,%eax
80108a8a:	89 c2                	mov    %eax,%edx
80108a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a8f:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108a91:	83 ec 0c             	sub    $0xc,%esp
80108a94:	68 d8 bf 10 80       	push   $0x8010bfd8
80108a99:	e8 56 79 ff ff       	call   801003f4 <cprintf>
80108a9e:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80108aa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aa4:	8b 00                	mov    (%eax),%eax
80108aa6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80108aa9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108aac:	83 e0 10             	and    $0x10,%eax
80108aaf:	85 c0                	test   %eax,%eax
80108ab1:	75 02                	jne    80108ab5 <i8254_read_eeprom+0x48>
  while(1){
80108ab3:	eb dc                	jmp    80108a91 <i8254_read_eeprom+0x24>
      break;
80108ab5:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80108ab6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ab9:	8b 00                	mov    (%eax),%eax
80108abb:	c1 e8 10             	shr    $0x10,%eax
}
80108abe:	c9                   	leave  
80108abf:	c3                   	ret    

80108ac0 <i8254_recv>:
void i8254_recv(){
80108ac0:	55                   	push   %ebp
80108ac1:	89 e5                	mov    %esp,%ebp
80108ac3:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108ac6:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108acb:	05 10 28 00 00       	add    $0x2810,%eax
80108ad0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108ad3:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108ad8:	05 18 28 00 00       	add    $0x2818,%eax
80108add:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108ae0:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108ae5:	05 00 28 00 00       	add    $0x2800,%eax
80108aea:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108aed:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108af0:	8b 00                	mov    (%eax),%eax
80108af2:	05 00 00 00 80       	add    $0x80000000,%eax
80108af7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108afd:	8b 10                	mov    (%eax),%edx
80108aff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b02:	8b 08                	mov    (%eax),%ecx
80108b04:	89 d0                	mov    %edx,%eax
80108b06:	29 c8                	sub    %ecx,%eax
80108b08:	25 ff 00 00 00       	and    $0xff,%eax
80108b0d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80108b10:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108b14:	7e 37                	jle    80108b4d <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80108b16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b19:	8b 00                	mov    (%eax),%eax
80108b1b:	c1 e0 04             	shl    $0x4,%eax
80108b1e:	89 c2                	mov    %eax,%edx
80108b20:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b23:	01 d0                	add    %edx,%eax
80108b25:	8b 00                	mov    (%eax),%eax
80108b27:	05 00 00 00 80       	add    $0x80000000,%eax
80108b2c:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80108b2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b32:	8b 00                	mov    (%eax),%eax
80108b34:	83 c0 01             	add    $0x1,%eax
80108b37:	0f b6 d0             	movzbl %al,%edx
80108b3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b3d:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80108b3f:	83 ec 0c             	sub    $0xc,%esp
80108b42:	ff 75 e0             	push   -0x20(%ebp)
80108b45:	e8 15 09 00 00       	call   8010945f <eth_proc>
80108b4a:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80108b4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b50:	8b 10                	mov    (%eax),%edx
80108b52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b55:	8b 00                	mov    (%eax),%eax
80108b57:	39 c2                	cmp    %eax,%edx
80108b59:	75 9f                	jne    80108afa <i8254_recv+0x3a>
      (*rdt)--;
80108b5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b5e:	8b 00                	mov    (%eax),%eax
80108b60:	8d 50 ff             	lea    -0x1(%eax),%edx
80108b63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b66:	89 10                	mov    %edx,(%eax)
  while(1){
80108b68:	eb 90                	jmp    80108afa <i8254_recv+0x3a>

80108b6a <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80108b6a:	55                   	push   %ebp
80108b6b:	89 e5                	mov    %esp,%ebp
80108b6d:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80108b70:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108b75:	05 10 38 00 00       	add    $0x3810,%eax
80108b7a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108b7d:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108b82:	05 18 38 00 00       	add    $0x3818,%eax
80108b87:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108b8a:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108b8f:	05 00 38 00 00       	add    $0x3800,%eax
80108b94:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80108b97:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b9a:	8b 00                	mov    (%eax),%eax
80108b9c:	05 00 00 00 80       	add    $0x80000000,%eax
80108ba1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80108ba4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ba7:	8b 10                	mov    (%eax),%edx
80108ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bac:	8b 08                	mov    (%eax),%ecx
80108bae:	89 d0                	mov    %edx,%eax
80108bb0:	29 c8                	sub    %ecx,%eax
80108bb2:	0f b6 d0             	movzbl %al,%edx
80108bb5:	b8 00 01 00 00       	mov    $0x100,%eax
80108bba:	29 d0                	sub    %edx,%eax
80108bbc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80108bbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bc2:	8b 00                	mov    (%eax),%eax
80108bc4:	25 ff 00 00 00       	and    $0xff,%eax
80108bc9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80108bcc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108bd0:	0f 8e a8 00 00 00    	jle    80108c7e <i8254_send+0x114>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80108bd6:	8b 45 08             	mov    0x8(%ebp),%eax
80108bd9:	8b 55 e0             	mov    -0x20(%ebp),%edx
80108bdc:	89 d1                	mov    %edx,%ecx
80108bde:	c1 e1 04             	shl    $0x4,%ecx
80108be1:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108be4:	01 ca                	add    %ecx,%edx
80108be6:	8b 12                	mov    (%edx),%edx
80108be8:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108bee:	83 ec 04             	sub    $0x4,%esp
80108bf1:	ff 75 0c             	push   0xc(%ebp)
80108bf4:	50                   	push   %eax
80108bf5:	52                   	push   %edx
80108bf6:	e8 75 bf ff ff       	call   80104b70 <memmove>
80108bfb:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80108bfe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c01:	c1 e0 04             	shl    $0x4,%eax
80108c04:	89 c2                	mov    %eax,%edx
80108c06:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c09:	01 d0                	add    %edx,%eax
80108c0b:	8b 55 0c             	mov    0xc(%ebp),%edx
80108c0e:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80108c12:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c15:	c1 e0 04             	shl    $0x4,%eax
80108c18:	89 c2                	mov    %eax,%edx
80108c1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c1d:	01 d0                	add    %edx,%eax
80108c1f:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80108c23:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c26:	c1 e0 04             	shl    $0x4,%eax
80108c29:	89 c2                	mov    %eax,%edx
80108c2b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c2e:	01 d0                	add    %edx,%eax
80108c30:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80108c34:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c37:	c1 e0 04             	shl    $0x4,%eax
80108c3a:	89 c2                	mov    %eax,%edx
80108c3c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c3f:	01 d0                	add    %edx,%eax
80108c41:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80108c45:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c48:	c1 e0 04             	shl    $0x4,%eax
80108c4b:	89 c2                	mov    %eax,%edx
80108c4d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c50:	01 d0                	add    %edx,%eax
80108c52:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80108c58:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c5b:	c1 e0 04             	shl    $0x4,%eax
80108c5e:	89 c2                	mov    %eax,%edx
80108c60:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c63:	01 d0                	add    %edx,%eax
80108c65:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80108c69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c6c:	8b 00                	mov    (%eax),%eax
80108c6e:	83 c0 01             	add    $0x1,%eax
80108c71:	0f b6 d0             	movzbl %al,%edx
80108c74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c77:	89 10                	mov    %edx,(%eax)
    return len;
80108c79:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c7c:	eb 05                	jmp    80108c83 <i8254_send+0x119>
  }else{
    return -1;
80108c7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80108c83:	c9                   	leave  
80108c84:	c3                   	ret    

80108c85 <i8254_intr>:

void i8254_intr(){
80108c85:	55                   	push   %ebp
80108c86:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80108c88:	a1 88 6c 19 80       	mov    0x80196c88,%eax
80108c8d:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80108c93:	90                   	nop
80108c94:	5d                   	pop    %ebp
80108c95:	c3                   	ret    

80108c96 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80108c96:	55                   	push   %ebp
80108c97:	89 e5                	mov    %esp,%ebp
80108c99:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80108c9c:	8b 45 08             	mov    0x8(%ebp),%eax
80108c9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80108ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ca5:	0f b7 00             	movzwl (%eax),%eax
80108ca8:	66 3d 00 01          	cmp    $0x100,%ax
80108cac:	74 0a                	je     80108cb8 <arp_proc+0x22>
80108cae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108cb3:	e9 4f 01 00 00       	jmp    80108e07 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80108cb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cbb:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80108cbf:	66 83 f8 08          	cmp    $0x8,%ax
80108cc3:	74 0a                	je     80108ccf <arp_proc+0x39>
80108cc5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108cca:	e9 38 01 00 00       	jmp    80108e07 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
80108ccf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cd2:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80108cd6:	3c 06                	cmp    $0x6,%al
80108cd8:	74 0a                	je     80108ce4 <arp_proc+0x4e>
80108cda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108cdf:	e9 23 01 00 00       	jmp    80108e07 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80108ce4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ce7:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80108ceb:	3c 04                	cmp    $0x4,%al
80108ced:	74 0a                	je     80108cf9 <arp_proc+0x63>
80108cef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108cf4:	e9 0e 01 00 00       	jmp    80108e07 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80108cf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cfc:	83 c0 18             	add    $0x18,%eax
80108cff:	83 ec 04             	sub    $0x4,%esp
80108d02:	6a 04                	push   $0x4
80108d04:	50                   	push   %eax
80108d05:	68 e4 f4 10 80       	push   $0x8010f4e4
80108d0a:	e8 09 be ff ff       	call   80104b18 <memcmp>
80108d0f:	83 c4 10             	add    $0x10,%esp
80108d12:	85 c0                	test   %eax,%eax
80108d14:	74 27                	je     80108d3d <arp_proc+0xa7>
80108d16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d19:	83 c0 0e             	add    $0xe,%eax
80108d1c:	83 ec 04             	sub    $0x4,%esp
80108d1f:	6a 04                	push   $0x4
80108d21:	50                   	push   %eax
80108d22:	68 e4 f4 10 80       	push   $0x8010f4e4
80108d27:	e8 ec bd ff ff       	call   80104b18 <memcmp>
80108d2c:	83 c4 10             	add    $0x10,%esp
80108d2f:	85 c0                	test   %eax,%eax
80108d31:	74 0a                	je     80108d3d <arp_proc+0xa7>
80108d33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d38:	e9 ca 00 00 00       	jmp    80108e07 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108d3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d40:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108d44:	66 3d 00 01          	cmp    $0x100,%ax
80108d48:	75 69                	jne    80108db3 <arp_proc+0x11d>
80108d4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d4d:	83 c0 18             	add    $0x18,%eax
80108d50:	83 ec 04             	sub    $0x4,%esp
80108d53:	6a 04                	push   $0x4
80108d55:	50                   	push   %eax
80108d56:	68 e4 f4 10 80       	push   $0x8010f4e4
80108d5b:	e8 b8 bd ff ff       	call   80104b18 <memcmp>
80108d60:	83 c4 10             	add    $0x10,%esp
80108d63:	85 c0                	test   %eax,%eax
80108d65:	75 4c                	jne    80108db3 <arp_proc+0x11d>
    uint send = (uint)kalloc();
80108d67:	e8 25 9a ff ff       	call   80102791 <kalloc>
80108d6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80108d6f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80108d76:	83 ec 04             	sub    $0x4,%esp
80108d79:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108d7c:	50                   	push   %eax
80108d7d:	ff 75 f0             	push   -0x10(%ebp)
80108d80:	ff 75 f4             	push   -0xc(%ebp)
80108d83:	e8 1f 04 00 00       	call   801091a7 <arp_reply_pkt_create>
80108d88:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80108d8b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d8e:	83 ec 08             	sub    $0x8,%esp
80108d91:	50                   	push   %eax
80108d92:	ff 75 f0             	push   -0x10(%ebp)
80108d95:	e8 d0 fd ff ff       	call   80108b6a <i8254_send>
80108d9a:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
80108d9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108da0:	83 ec 0c             	sub    $0xc,%esp
80108da3:	50                   	push   %eax
80108da4:	e8 4e 99 ff ff       	call   801026f7 <kfree>
80108da9:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
80108dac:	b8 02 00 00 00       	mov    $0x2,%eax
80108db1:	eb 54                	jmp    80108e07 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108db3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108db6:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108dba:	66 3d 00 02          	cmp    $0x200,%ax
80108dbe:	75 42                	jne    80108e02 <arp_proc+0x16c>
80108dc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dc3:	83 c0 18             	add    $0x18,%eax
80108dc6:	83 ec 04             	sub    $0x4,%esp
80108dc9:	6a 04                	push   $0x4
80108dcb:	50                   	push   %eax
80108dcc:	68 e4 f4 10 80       	push   $0x8010f4e4
80108dd1:	e8 42 bd ff ff       	call   80104b18 <memcmp>
80108dd6:	83 c4 10             	add    $0x10,%esp
80108dd9:	85 c0                	test   %eax,%eax
80108ddb:	75 25                	jne    80108e02 <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
80108ddd:	83 ec 0c             	sub    $0xc,%esp
80108de0:	68 dc bf 10 80       	push   $0x8010bfdc
80108de5:	e8 0a 76 ff ff       	call   801003f4 <cprintf>
80108dea:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
80108ded:	83 ec 0c             	sub    $0xc,%esp
80108df0:	ff 75 f4             	push   -0xc(%ebp)
80108df3:	e8 af 01 00 00       	call   80108fa7 <arp_table_update>
80108df8:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80108dfb:	b8 01 00 00 00       	mov    $0x1,%eax
80108e00:	eb 05                	jmp    80108e07 <arp_proc+0x171>
  }else{
    return -1;
80108e02:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80108e07:	c9                   	leave  
80108e08:	c3                   	ret    

80108e09 <arp_scan>:

void arp_scan(){
80108e09:	55                   	push   %ebp
80108e0a:	89 e5                	mov    %esp,%ebp
80108e0c:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80108e0f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108e16:	eb 6f                	jmp    80108e87 <arp_scan+0x7e>
    uint send = (uint)kalloc();
80108e18:	e8 74 99 ff ff       	call   80102791 <kalloc>
80108e1d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80108e20:	83 ec 04             	sub    $0x4,%esp
80108e23:	ff 75 f4             	push   -0xc(%ebp)
80108e26:	8d 45 e8             	lea    -0x18(%ebp),%eax
80108e29:	50                   	push   %eax
80108e2a:	ff 75 ec             	push   -0x14(%ebp)
80108e2d:	e8 62 00 00 00       	call   80108e94 <arp_broadcast>
80108e32:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80108e35:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e38:	83 ec 08             	sub    $0x8,%esp
80108e3b:	50                   	push   %eax
80108e3c:	ff 75 ec             	push   -0x14(%ebp)
80108e3f:	e8 26 fd ff ff       	call   80108b6a <i8254_send>
80108e44:	83 c4 10             	add    $0x10,%esp
80108e47:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80108e4a:	eb 22                	jmp    80108e6e <arp_scan+0x65>
      microdelay(1);
80108e4c:	83 ec 0c             	sub    $0xc,%esp
80108e4f:	6a 01                	push   $0x1
80108e51:	e8 d2 9c ff ff       	call   80102b28 <microdelay>
80108e56:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80108e59:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e5c:	83 ec 08             	sub    $0x8,%esp
80108e5f:	50                   	push   %eax
80108e60:	ff 75 ec             	push   -0x14(%ebp)
80108e63:	e8 02 fd ff ff       	call   80108b6a <i8254_send>
80108e68:	83 c4 10             	add    $0x10,%esp
80108e6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80108e6e:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80108e72:	74 d8                	je     80108e4c <arp_scan+0x43>
    }
    kfree((char *)send);
80108e74:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e77:	83 ec 0c             	sub    $0xc,%esp
80108e7a:	50                   	push   %eax
80108e7b:	e8 77 98 ff ff       	call   801026f7 <kfree>
80108e80:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80108e83:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108e87:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108e8e:	7e 88                	jle    80108e18 <arp_scan+0xf>
  }
}
80108e90:	90                   	nop
80108e91:	90                   	nop
80108e92:	c9                   	leave  
80108e93:	c3                   	ret    

80108e94 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80108e94:	55                   	push   %ebp
80108e95:	89 e5                	mov    %esp,%ebp
80108e97:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80108e9a:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
80108e9e:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80108ea2:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80108ea6:	8b 45 10             	mov    0x10(%ebp),%eax
80108ea9:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80108eac:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80108eb3:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80108eb9:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108ec0:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80108ec6:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ec9:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80108ecf:	8b 45 08             	mov    0x8(%ebp),%eax
80108ed2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80108ed5:	8b 45 08             	mov    0x8(%ebp),%eax
80108ed8:	83 c0 0e             	add    $0xe,%eax
80108edb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80108ede:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ee1:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80108ee5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ee8:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80108eec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108eef:	83 ec 04             	sub    $0x4,%esp
80108ef2:	6a 06                	push   $0x6
80108ef4:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80108ef7:	52                   	push   %edx
80108ef8:	50                   	push   %eax
80108ef9:	e8 72 bc ff ff       	call   80104b70 <memmove>
80108efe:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80108f01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f04:	83 c0 06             	add    $0x6,%eax
80108f07:	83 ec 04             	sub    $0x4,%esp
80108f0a:	6a 06                	push   $0x6
80108f0c:	68 80 6c 19 80       	push   $0x80196c80
80108f11:	50                   	push   %eax
80108f12:	e8 59 bc ff ff       	call   80104b70 <memmove>
80108f17:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80108f1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f1d:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80108f22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f25:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80108f2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f2e:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80108f32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f35:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80108f39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f3c:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80108f42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f45:	8d 50 12             	lea    0x12(%eax),%edx
80108f48:	83 ec 04             	sub    $0x4,%esp
80108f4b:	6a 06                	push   $0x6
80108f4d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80108f50:	50                   	push   %eax
80108f51:	52                   	push   %edx
80108f52:	e8 19 bc ff ff       	call   80104b70 <memmove>
80108f57:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80108f5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f5d:	8d 50 18             	lea    0x18(%eax),%edx
80108f60:	83 ec 04             	sub    $0x4,%esp
80108f63:	6a 04                	push   $0x4
80108f65:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108f68:	50                   	push   %eax
80108f69:	52                   	push   %edx
80108f6a:	e8 01 bc ff ff       	call   80104b70 <memmove>
80108f6f:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80108f72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f75:	83 c0 08             	add    $0x8,%eax
80108f78:	83 ec 04             	sub    $0x4,%esp
80108f7b:	6a 06                	push   $0x6
80108f7d:	68 80 6c 19 80       	push   $0x80196c80
80108f82:	50                   	push   %eax
80108f83:	e8 e8 bb ff ff       	call   80104b70 <memmove>
80108f88:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80108f8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f8e:	83 c0 0e             	add    $0xe,%eax
80108f91:	83 ec 04             	sub    $0x4,%esp
80108f94:	6a 04                	push   $0x4
80108f96:	68 e4 f4 10 80       	push   $0x8010f4e4
80108f9b:	50                   	push   %eax
80108f9c:	e8 cf bb ff ff       	call   80104b70 <memmove>
80108fa1:	83 c4 10             	add    $0x10,%esp
}
80108fa4:	90                   	nop
80108fa5:	c9                   	leave  
80108fa6:	c3                   	ret    

80108fa7 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80108fa7:	55                   	push   %ebp
80108fa8:	89 e5                	mov    %esp,%ebp
80108faa:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80108fad:	8b 45 08             	mov    0x8(%ebp),%eax
80108fb0:	83 c0 0e             	add    $0xe,%eax
80108fb3:	83 ec 0c             	sub    $0xc,%esp
80108fb6:	50                   	push   %eax
80108fb7:	e8 bc 00 00 00       	call   80109078 <arp_table_search>
80108fbc:	83 c4 10             	add    $0x10,%esp
80108fbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80108fc2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108fc6:	78 2d                	js     80108ff5 <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80108fc8:	8b 45 08             	mov    0x8(%ebp),%eax
80108fcb:	8d 48 08             	lea    0x8(%eax),%ecx
80108fce:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108fd1:	89 d0                	mov    %edx,%eax
80108fd3:	c1 e0 02             	shl    $0x2,%eax
80108fd6:	01 d0                	add    %edx,%eax
80108fd8:	01 c0                	add    %eax,%eax
80108fda:	01 d0                	add    %edx,%eax
80108fdc:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
80108fe1:	83 c0 04             	add    $0x4,%eax
80108fe4:	83 ec 04             	sub    $0x4,%esp
80108fe7:	6a 06                	push   $0x6
80108fe9:	51                   	push   %ecx
80108fea:	50                   	push   %eax
80108feb:	e8 80 bb ff ff       	call   80104b70 <memmove>
80108ff0:	83 c4 10             	add    $0x10,%esp
80108ff3:	eb 70                	jmp    80109065 <arp_table_update+0xbe>
  }else{
    index += 1;
80108ff5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80108ff9:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80108ffc:	8b 45 08             	mov    0x8(%ebp),%eax
80108fff:	8d 48 08             	lea    0x8(%eax),%ecx
80109002:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109005:	89 d0                	mov    %edx,%eax
80109007:	c1 e0 02             	shl    $0x2,%eax
8010900a:	01 d0                	add    %edx,%eax
8010900c:	01 c0                	add    %eax,%eax
8010900e:	01 d0                	add    %edx,%eax
80109010:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
80109015:	83 c0 04             	add    $0x4,%eax
80109018:	83 ec 04             	sub    $0x4,%esp
8010901b:	6a 06                	push   $0x6
8010901d:	51                   	push   %ecx
8010901e:	50                   	push   %eax
8010901f:	e8 4c bb ff ff       	call   80104b70 <memmove>
80109024:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109027:	8b 45 08             	mov    0x8(%ebp),%eax
8010902a:	8d 48 0e             	lea    0xe(%eax),%ecx
8010902d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109030:	89 d0                	mov    %edx,%eax
80109032:	c1 e0 02             	shl    $0x2,%eax
80109035:	01 d0                	add    %edx,%eax
80109037:	01 c0                	add    %eax,%eax
80109039:	01 d0                	add    %edx,%eax
8010903b:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
80109040:	83 ec 04             	sub    $0x4,%esp
80109043:	6a 04                	push   $0x4
80109045:	51                   	push   %ecx
80109046:	50                   	push   %eax
80109047:	e8 24 bb ff ff       	call   80104b70 <memmove>
8010904c:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
8010904f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109052:	89 d0                	mov    %edx,%eax
80109054:	c1 e0 02             	shl    $0x2,%eax
80109057:	01 d0                	add    %edx,%eax
80109059:	01 c0                	add    %eax,%eax
8010905b:	01 d0                	add    %edx,%eax
8010905d:	05 aa 6c 19 80       	add    $0x80196caa,%eax
80109062:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80109065:	83 ec 0c             	sub    $0xc,%esp
80109068:	68 a0 6c 19 80       	push   $0x80196ca0
8010906d:	e8 83 00 00 00       	call   801090f5 <print_arp_table>
80109072:	83 c4 10             	add    $0x10,%esp
}
80109075:	90                   	nop
80109076:	c9                   	leave  
80109077:	c3                   	ret    

80109078 <arp_table_search>:

int arp_table_search(uchar *ip){
80109078:	55                   	push   %ebp
80109079:	89 e5                	mov    %esp,%ebp
8010907b:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
8010907e:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109085:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010908c:	eb 59                	jmp    801090e7 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
8010908e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109091:	89 d0                	mov    %edx,%eax
80109093:	c1 e0 02             	shl    $0x2,%eax
80109096:	01 d0                	add    %edx,%eax
80109098:	01 c0                	add    %eax,%eax
8010909a:	01 d0                	add    %edx,%eax
8010909c:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
801090a1:	83 ec 04             	sub    $0x4,%esp
801090a4:	6a 04                	push   $0x4
801090a6:	ff 75 08             	push   0x8(%ebp)
801090a9:	50                   	push   %eax
801090aa:	e8 69 ba ff ff       	call   80104b18 <memcmp>
801090af:	83 c4 10             	add    $0x10,%esp
801090b2:	85 c0                	test   %eax,%eax
801090b4:	75 05                	jne    801090bb <arp_table_search+0x43>
      return i;
801090b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090b9:	eb 38                	jmp    801090f3 <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
801090bb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801090be:	89 d0                	mov    %edx,%eax
801090c0:	c1 e0 02             	shl    $0x2,%eax
801090c3:	01 d0                	add    %edx,%eax
801090c5:	01 c0                	add    %eax,%eax
801090c7:	01 d0                	add    %edx,%eax
801090c9:	05 aa 6c 19 80       	add    $0x80196caa,%eax
801090ce:	0f b6 00             	movzbl (%eax),%eax
801090d1:	84 c0                	test   %al,%al
801090d3:	75 0e                	jne    801090e3 <arp_table_search+0x6b>
801090d5:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801090d9:	75 08                	jne    801090e3 <arp_table_search+0x6b>
      empty = -i;
801090db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090de:	f7 d8                	neg    %eax
801090e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801090e3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801090e7:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
801090eb:	7e a1                	jle    8010908e <arp_table_search+0x16>
    }
  }
  return empty-1;
801090ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090f0:	83 e8 01             	sub    $0x1,%eax
}
801090f3:	c9                   	leave  
801090f4:	c3                   	ret    

801090f5 <print_arp_table>:

void print_arp_table(){
801090f5:	55                   	push   %ebp
801090f6:	89 e5                	mov    %esp,%ebp
801090f8:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801090fb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109102:	e9 92 00 00 00       	jmp    80109199 <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
80109107:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010910a:	89 d0                	mov    %edx,%eax
8010910c:	c1 e0 02             	shl    $0x2,%eax
8010910f:	01 d0                	add    %edx,%eax
80109111:	01 c0                	add    %eax,%eax
80109113:	01 d0                	add    %edx,%eax
80109115:	05 aa 6c 19 80       	add    $0x80196caa,%eax
8010911a:	0f b6 00             	movzbl (%eax),%eax
8010911d:	84 c0                	test   %al,%al
8010911f:	74 74                	je     80109195 <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
80109121:	83 ec 08             	sub    $0x8,%esp
80109124:	ff 75 f4             	push   -0xc(%ebp)
80109127:	68 ef bf 10 80       	push   $0x8010bfef
8010912c:	e8 c3 72 ff ff       	call   801003f4 <cprintf>
80109131:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109134:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109137:	89 d0                	mov    %edx,%eax
80109139:	c1 e0 02             	shl    $0x2,%eax
8010913c:	01 d0                	add    %edx,%eax
8010913e:	01 c0                	add    %eax,%eax
80109140:	01 d0                	add    %edx,%eax
80109142:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
80109147:	83 ec 0c             	sub    $0xc,%esp
8010914a:	50                   	push   %eax
8010914b:	e8 54 02 00 00       	call   801093a4 <print_ipv4>
80109150:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109153:	83 ec 0c             	sub    $0xc,%esp
80109156:	68 fe bf 10 80       	push   $0x8010bffe
8010915b:	e8 94 72 ff ff       	call   801003f4 <cprintf>
80109160:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109163:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109166:	89 d0                	mov    %edx,%eax
80109168:	c1 e0 02             	shl    $0x2,%eax
8010916b:	01 d0                	add    %edx,%eax
8010916d:	01 c0                	add    %eax,%eax
8010916f:	01 d0                	add    %edx,%eax
80109171:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
80109176:	83 c0 04             	add    $0x4,%eax
80109179:	83 ec 0c             	sub    $0xc,%esp
8010917c:	50                   	push   %eax
8010917d:	e8 70 02 00 00       	call   801093f2 <print_mac>
80109182:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
80109185:	83 ec 0c             	sub    $0xc,%esp
80109188:	68 00 c0 10 80       	push   $0x8010c000
8010918d:	e8 62 72 ff ff       	call   801003f4 <cprintf>
80109192:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109195:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109199:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
8010919d:	0f 8e 64 ff ff ff    	jle    80109107 <print_arp_table+0x12>
    }
  }
}
801091a3:	90                   	nop
801091a4:	90                   	nop
801091a5:	c9                   	leave  
801091a6:	c3                   	ret    

801091a7 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
801091a7:	55                   	push   %ebp
801091a8:	89 e5                	mov    %esp,%ebp
801091aa:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801091ad:	8b 45 10             	mov    0x10(%ebp),%eax
801091b0:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801091b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801091b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801091bc:	8b 45 0c             	mov    0xc(%ebp),%eax
801091bf:	83 c0 0e             	add    $0xe,%eax
801091c2:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
801091c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091c8:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801091cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091cf:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
801091d3:	8b 45 08             	mov    0x8(%ebp),%eax
801091d6:	8d 50 08             	lea    0x8(%eax),%edx
801091d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091dc:	83 ec 04             	sub    $0x4,%esp
801091df:	6a 06                	push   $0x6
801091e1:	52                   	push   %edx
801091e2:	50                   	push   %eax
801091e3:	e8 88 b9 ff ff       	call   80104b70 <memmove>
801091e8:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801091eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091ee:	83 c0 06             	add    $0x6,%eax
801091f1:	83 ec 04             	sub    $0x4,%esp
801091f4:	6a 06                	push   $0x6
801091f6:	68 80 6c 19 80       	push   $0x80196c80
801091fb:	50                   	push   %eax
801091fc:	e8 6f b9 ff ff       	call   80104b70 <memmove>
80109201:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109204:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109207:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
8010920c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010920f:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109215:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109218:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
8010921c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010921f:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109223:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109226:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
8010922c:	8b 45 08             	mov    0x8(%ebp),%eax
8010922f:	8d 50 08             	lea    0x8(%eax),%edx
80109232:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109235:	83 c0 12             	add    $0x12,%eax
80109238:	83 ec 04             	sub    $0x4,%esp
8010923b:	6a 06                	push   $0x6
8010923d:	52                   	push   %edx
8010923e:	50                   	push   %eax
8010923f:	e8 2c b9 ff ff       	call   80104b70 <memmove>
80109244:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109247:	8b 45 08             	mov    0x8(%ebp),%eax
8010924a:	8d 50 0e             	lea    0xe(%eax),%edx
8010924d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109250:	83 c0 18             	add    $0x18,%eax
80109253:	83 ec 04             	sub    $0x4,%esp
80109256:	6a 04                	push   $0x4
80109258:	52                   	push   %edx
80109259:	50                   	push   %eax
8010925a:	e8 11 b9 ff ff       	call   80104b70 <memmove>
8010925f:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109262:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109265:	83 c0 08             	add    $0x8,%eax
80109268:	83 ec 04             	sub    $0x4,%esp
8010926b:	6a 06                	push   $0x6
8010926d:	68 80 6c 19 80       	push   $0x80196c80
80109272:	50                   	push   %eax
80109273:	e8 f8 b8 ff ff       	call   80104b70 <memmove>
80109278:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
8010927b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010927e:	83 c0 0e             	add    $0xe,%eax
80109281:	83 ec 04             	sub    $0x4,%esp
80109284:	6a 04                	push   $0x4
80109286:	68 e4 f4 10 80       	push   $0x8010f4e4
8010928b:	50                   	push   %eax
8010928c:	e8 df b8 ff ff       	call   80104b70 <memmove>
80109291:	83 c4 10             	add    $0x10,%esp
}
80109294:	90                   	nop
80109295:	c9                   	leave  
80109296:	c3                   	ret    

80109297 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
80109297:	55                   	push   %ebp
80109298:	89 e5                	mov    %esp,%ebp
8010929a:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
8010929d:	83 ec 0c             	sub    $0xc,%esp
801092a0:	68 02 c0 10 80       	push   $0x8010c002
801092a5:	e8 4a 71 ff ff       	call   801003f4 <cprintf>
801092aa:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
801092ad:	8b 45 08             	mov    0x8(%ebp),%eax
801092b0:	83 c0 0e             	add    $0xe,%eax
801092b3:	83 ec 0c             	sub    $0xc,%esp
801092b6:	50                   	push   %eax
801092b7:	e8 e8 00 00 00       	call   801093a4 <print_ipv4>
801092bc:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801092bf:	83 ec 0c             	sub    $0xc,%esp
801092c2:	68 00 c0 10 80       	push   $0x8010c000
801092c7:	e8 28 71 ff ff       	call   801003f4 <cprintf>
801092cc:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
801092cf:	8b 45 08             	mov    0x8(%ebp),%eax
801092d2:	83 c0 08             	add    $0x8,%eax
801092d5:	83 ec 0c             	sub    $0xc,%esp
801092d8:	50                   	push   %eax
801092d9:	e8 14 01 00 00       	call   801093f2 <print_mac>
801092de:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801092e1:	83 ec 0c             	sub    $0xc,%esp
801092e4:	68 00 c0 10 80       	push   $0x8010c000
801092e9:	e8 06 71 ff ff       	call   801003f4 <cprintf>
801092ee:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
801092f1:	83 ec 0c             	sub    $0xc,%esp
801092f4:	68 19 c0 10 80       	push   $0x8010c019
801092f9:	e8 f6 70 ff ff       	call   801003f4 <cprintf>
801092fe:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
80109301:	8b 45 08             	mov    0x8(%ebp),%eax
80109304:	83 c0 18             	add    $0x18,%eax
80109307:	83 ec 0c             	sub    $0xc,%esp
8010930a:	50                   	push   %eax
8010930b:	e8 94 00 00 00       	call   801093a4 <print_ipv4>
80109310:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109313:	83 ec 0c             	sub    $0xc,%esp
80109316:	68 00 c0 10 80       	push   $0x8010c000
8010931b:	e8 d4 70 ff ff       	call   801003f4 <cprintf>
80109320:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109323:	8b 45 08             	mov    0x8(%ebp),%eax
80109326:	83 c0 12             	add    $0x12,%eax
80109329:	83 ec 0c             	sub    $0xc,%esp
8010932c:	50                   	push   %eax
8010932d:	e8 c0 00 00 00       	call   801093f2 <print_mac>
80109332:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109335:	83 ec 0c             	sub    $0xc,%esp
80109338:	68 00 c0 10 80       	push   $0x8010c000
8010933d:	e8 b2 70 ff ff       	call   801003f4 <cprintf>
80109342:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109345:	83 ec 0c             	sub    $0xc,%esp
80109348:	68 30 c0 10 80       	push   $0x8010c030
8010934d:	e8 a2 70 ff ff       	call   801003f4 <cprintf>
80109352:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109355:	8b 45 08             	mov    0x8(%ebp),%eax
80109358:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010935c:	66 3d 00 01          	cmp    $0x100,%ax
80109360:	75 12                	jne    80109374 <print_arp_info+0xdd>
80109362:	83 ec 0c             	sub    $0xc,%esp
80109365:	68 3c c0 10 80       	push   $0x8010c03c
8010936a:	e8 85 70 ff ff       	call   801003f4 <cprintf>
8010936f:	83 c4 10             	add    $0x10,%esp
80109372:	eb 1d                	jmp    80109391 <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
80109374:	8b 45 08             	mov    0x8(%ebp),%eax
80109377:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010937b:	66 3d 00 02          	cmp    $0x200,%ax
8010937f:	75 10                	jne    80109391 <print_arp_info+0xfa>
    cprintf("Reply\n");
80109381:	83 ec 0c             	sub    $0xc,%esp
80109384:	68 45 c0 10 80       	push   $0x8010c045
80109389:	e8 66 70 ff ff       	call   801003f4 <cprintf>
8010938e:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
80109391:	83 ec 0c             	sub    $0xc,%esp
80109394:	68 00 c0 10 80       	push   $0x8010c000
80109399:	e8 56 70 ff ff       	call   801003f4 <cprintf>
8010939e:	83 c4 10             	add    $0x10,%esp
}
801093a1:	90                   	nop
801093a2:	c9                   	leave  
801093a3:	c3                   	ret    

801093a4 <print_ipv4>:

void print_ipv4(uchar *ip){
801093a4:	55                   	push   %ebp
801093a5:	89 e5                	mov    %esp,%ebp
801093a7:	53                   	push   %ebx
801093a8:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
801093ab:	8b 45 08             	mov    0x8(%ebp),%eax
801093ae:	83 c0 03             	add    $0x3,%eax
801093b1:	0f b6 00             	movzbl (%eax),%eax
801093b4:	0f b6 d8             	movzbl %al,%ebx
801093b7:	8b 45 08             	mov    0x8(%ebp),%eax
801093ba:	83 c0 02             	add    $0x2,%eax
801093bd:	0f b6 00             	movzbl (%eax),%eax
801093c0:	0f b6 c8             	movzbl %al,%ecx
801093c3:	8b 45 08             	mov    0x8(%ebp),%eax
801093c6:	83 c0 01             	add    $0x1,%eax
801093c9:	0f b6 00             	movzbl (%eax),%eax
801093cc:	0f b6 d0             	movzbl %al,%edx
801093cf:	8b 45 08             	mov    0x8(%ebp),%eax
801093d2:	0f b6 00             	movzbl (%eax),%eax
801093d5:	0f b6 c0             	movzbl %al,%eax
801093d8:	83 ec 0c             	sub    $0xc,%esp
801093db:	53                   	push   %ebx
801093dc:	51                   	push   %ecx
801093dd:	52                   	push   %edx
801093de:	50                   	push   %eax
801093df:	68 4c c0 10 80       	push   $0x8010c04c
801093e4:	e8 0b 70 ff ff       	call   801003f4 <cprintf>
801093e9:	83 c4 20             	add    $0x20,%esp
}
801093ec:	90                   	nop
801093ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801093f0:	c9                   	leave  
801093f1:	c3                   	ret    

801093f2 <print_mac>:

void print_mac(uchar *mac){
801093f2:	55                   	push   %ebp
801093f3:	89 e5                	mov    %esp,%ebp
801093f5:	57                   	push   %edi
801093f6:	56                   	push   %esi
801093f7:	53                   	push   %ebx
801093f8:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
801093fb:	8b 45 08             	mov    0x8(%ebp),%eax
801093fe:	83 c0 05             	add    $0x5,%eax
80109401:	0f b6 00             	movzbl (%eax),%eax
80109404:	0f b6 f8             	movzbl %al,%edi
80109407:	8b 45 08             	mov    0x8(%ebp),%eax
8010940a:	83 c0 04             	add    $0x4,%eax
8010940d:	0f b6 00             	movzbl (%eax),%eax
80109410:	0f b6 f0             	movzbl %al,%esi
80109413:	8b 45 08             	mov    0x8(%ebp),%eax
80109416:	83 c0 03             	add    $0x3,%eax
80109419:	0f b6 00             	movzbl (%eax),%eax
8010941c:	0f b6 d8             	movzbl %al,%ebx
8010941f:	8b 45 08             	mov    0x8(%ebp),%eax
80109422:	83 c0 02             	add    $0x2,%eax
80109425:	0f b6 00             	movzbl (%eax),%eax
80109428:	0f b6 c8             	movzbl %al,%ecx
8010942b:	8b 45 08             	mov    0x8(%ebp),%eax
8010942e:	83 c0 01             	add    $0x1,%eax
80109431:	0f b6 00             	movzbl (%eax),%eax
80109434:	0f b6 d0             	movzbl %al,%edx
80109437:	8b 45 08             	mov    0x8(%ebp),%eax
8010943a:	0f b6 00             	movzbl (%eax),%eax
8010943d:	0f b6 c0             	movzbl %al,%eax
80109440:	83 ec 04             	sub    $0x4,%esp
80109443:	57                   	push   %edi
80109444:	56                   	push   %esi
80109445:	53                   	push   %ebx
80109446:	51                   	push   %ecx
80109447:	52                   	push   %edx
80109448:	50                   	push   %eax
80109449:	68 64 c0 10 80       	push   $0x8010c064
8010944e:	e8 a1 6f ff ff       	call   801003f4 <cprintf>
80109453:	83 c4 20             	add    $0x20,%esp
}
80109456:	90                   	nop
80109457:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010945a:	5b                   	pop    %ebx
8010945b:	5e                   	pop    %esi
8010945c:	5f                   	pop    %edi
8010945d:	5d                   	pop    %ebp
8010945e:	c3                   	ret    

8010945f <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
8010945f:	55                   	push   %ebp
80109460:	89 e5                	mov    %esp,%ebp
80109462:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109465:	8b 45 08             	mov    0x8(%ebp),%eax
80109468:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
8010946b:	8b 45 08             	mov    0x8(%ebp),%eax
8010946e:	83 c0 0e             	add    $0xe,%eax
80109471:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109474:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109477:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
8010947b:	3c 08                	cmp    $0x8,%al
8010947d:	75 1b                	jne    8010949a <eth_proc+0x3b>
8010947f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109482:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109486:	3c 06                	cmp    $0x6,%al
80109488:	75 10                	jne    8010949a <eth_proc+0x3b>
    arp_proc(pkt_addr);
8010948a:	83 ec 0c             	sub    $0xc,%esp
8010948d:	ff 75 f0             	push   -0x10(%ebp)
80109490:	e8 01 f8 ff ff       	call   80108c96 <arp_proc>
80109495:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109498:	eb 24                	jmp    801094be <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
8010949a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010949d:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801094a1:	3c 08                	cmp    $0x8,%al
801094a3:	75 19                	jne    801094be <eth_proc+0x5f>
801094a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094a8:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801094ac:	84 c0                	test   %al,%al
801094ae:	75 0e                	jne    801094be <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
801094b0:	83 ec 0c             	sub    $0xc,%esp
801094b3:	ff 75 08             	push   0x8(%ebp)
801094b6:	e8 a3 00 00 00       	call   8010955e <ipv4_proc>
801094bb:	83 c4 10             	add    $0x10,%esp
}
801094be:	90                   	nop
801094bf:	c9                   	leave  
801094c0:	c3                   	ret    

801094c1 <N2H_ushort>:

ushort N2H_ushort(ushort value){
801094c1:	55                   	push   %ebp
801094c2:	89 e5                	mov    %esp,%ebp
801094c4:	83 ec 04             	sub    $0x4,%esp
801094c7:	8b 45 08             	mov    0x8(%ebp),%eax
801094ca:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
801094ce:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801094d2:	c1 e0 08             	shl    $0x8,%eax
801094d5:	89 c2                	mov    %eax,%edx
801094d7:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801094db:	66 c1 e8 08          	shr    $0x8,%ax
801094df:	01 d0                	add    %edx,%eax
}
801094e1:	c9                   	leave  
801094e2:	c3                   	ret    

801094e3 <H2N_ushort>:

ushort H2N_ushort(ushort value){
801094e3:	55                   	push   %ebp
801094e4:	89 e5                	mov    %esp,%ebp
801094e6:	83 ec 04             	sub    $0x4,%esp
801094e9:	8b 45 08             	mov    0x8(%ebp),%eax
801094ec:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
801094f0:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801094f4:	c1 e0 08             	shl    $0x8,%eax
801094f7:	89 c2                	mov    %eax,%edx
801094f9:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801094fd:	66 c1 e8 08          	shr    $0x8,%ax
80109501:	01 d0                	add    %edx,%eax
}
80109503:	c9                   	leave  
80109504:	c3                   	ret    

80109505 <H2N_uint>:

uint H2N_uint(uint value){
80109505:	55                   	push   %ebp
80109506:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109508:	8b 45 08             	mov    0x8(%ebp),%eax
8010950b:	c1 e0 18             	shl    $0x18,%eax
8010950e:	25 00 00 00 0f       	and    $0xf000000,%eax
80109513:	89 c2                	mov    %eax,%edx
80109515:	8b 45 08             	mov    0x8(%ebp),%eax
80109518:	c1 e0 08             	shl    $0x8,%eax
8010951b:	25 00 f0 00 00       	and    $0xf000,%eax
80109520:	09 c2                	or     %eax,%edx
80109522:	8b 45 08             	mov    0x8(%ebp),%eax
80109525:	c1 e8 08             	shr    $0x8,%eax
80109528:	83 e0 0f             	and    $0xf,%eax
8010952b:	01 d0                	add    %edx,%eax
}
8010952d:	5d                   	pop    %ebp
8010952e:	c3                   	ret    

8010952f <N2H_uint>:

uint N2H_uint(uint value){
8010952f:	55                   	push   %ebp
80109530:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109532:	8b 45 08             	mov    0x8(%ebp),%eax
80109535:	c1 e0 18             	shl    $0x18,%eax
80109538:	89 c2                	mov    %eax,%edx
8010953a:	8b 45 08             	mov    0x8(%ebp),%eax
8010953d:	c1 e0 08             	shl    $0x8,%eax
80109540:	25 00 00 ff 00       	and    $0xff0000,%eax
80109545:	01 c2                	add    %eax,%edx
80109547:	8b 45 08             	mov    0x8(%ebp),%eax
8010954a:	c1 e8 08             	shr    $0x8,%eax
8010954d:	25 00 ff 00 00       	and    $0xff00,%eax
80109552:	01 c2                	add    %eax,%edx
80109554:	8b 45 08             	mov    0x8(%ebp),%eax
80109557:	c1 e8 18             	shr    $0x18,%eax
8010955a:	01 d0                	add    %edx,%eax
}
8010955c:	5d                   	pop    %ebp
8010955d:	c3                   	ret    

8010955e <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
8010955e:	55                   	push   %ebp
8010955f:	89 e5                	mov    %esp,%ebp
80109561:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109564:	8b 45 08             	mov    0x8(%ebp),%eax
80109567:	83 c0 0e             	add    $0xe,%eax
8010956a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
8010956d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109570:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109574:	0f b7 d0             	movzwl %ax,%edx
80109577:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
8010957c:	39 c2                	cmp    %eax,%edx
8010957e:	74 60                	je     801095e0 <ipv4_proc+0x82>
80109580:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109583:	83 c0 0c             	add    $0xc,%eax
80109586:	83 ec 04             	sub    $0x4,%esp
80109589:	6a 04                	push   $0x4
8010958b:	50                   	push   %eax
8010958c:	68 e4 f4 10 80       	push   $0x8010f4e4
80109591:	e8 82 b5 ff ff       	call   80104b18 <memcmp>
80109596:	83 c4 10             	add    $0x10,%esp
80109599:	85 c0                	test   %eax,%eax
8010959b:	74 43                	je     801095e0 <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
8010959d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095a0:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801095a4:	0f b7 c0             	movzwl %ax,%eax
801095a7:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
801095ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095af:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801095b3:	3c 01                	cmp    $0x1,%al
801095b5:	75 10                	jne    801095c7 <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
801095b7:	83 ec 0c             	sub    $0xc,%esp
801095ba:	ff 75 08             	push   0x8(%ebp)
801095bd:	e8 a3 00 00 00       	call   80109665 <icmp_proc>
801095c2:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
801095c5:	eb 19                	jmp    801095e0 <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
801095c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095ca:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801095ce:	3c 06                	cmp    $0x6,%al
801095d0:	75 0e                	jne    801095e0 <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
801095d2:	83 ec 0c             	sub    $0xc,%esp
801095d5:	ff 75 08             	push   0x8(%ebp)
801095d8:	e8 b3 03 00 00       	call   80109990 <tcp_proc>
801095dd:	83 c4 10             	add    $0x10,%esp
}
801095e0:	90                   	nop
801095e1:	c9                   	leave  
801095e2:	c3                   	ret    

801095e3 <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
801095e3:	55                   	push   %ebp
801095e4:	89 e5                	mov    %esp,%ebp
801095e6:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
801095e9:	8b 45 08             	mov    0x8(%ebp),%eax
801095ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
801095ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095f2:	0f b6 00             	movzbl (%eax),%eax
801095f5:	83 e0 0f             	and    $0xf,%eax
801095f8:	01 c0                	add    %eax,%eax
801095fa:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
801095fd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109604:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010960b:	eb 48                	jmp    80109655 <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010960d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109610:	01 c0                	add    %eax,%eax
80109612:	89 c2                	mov    %eax,%edx
80109614:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109617:	01 d0                	add    %edx,%eax
80109619:	0f b6 00             	movzbl (%eax),%eax
8010961c:	0f b6 c0             	movzbl %al,%eax
8010961f:	c1 e0 08             	shl    $0x8,%eax
80109622:	89 c2                	mov    %eax,%edx
80109624:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109627:	01 c0                	add    %eax,%eax
80109629:	8d 48 01             	lea    0x1(%eax),%ecx
8010962c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010962f:	01 c8                	add    %ecx,%eax
80109631:	0f b6 00             	movzbl (%eax),%eax
80109634:	0f b6 c0             	movzbl %al,%eax
80109637:	01 d0                	add    %edx,%eax
80109639:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010963c:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109643:	76 0c                	jbe    80109651 <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
80109645:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109648:	0f b7 c0             	movzwl %ax,%eax
8010964b:	83 c0 01             	add    $0x1,%eax
8010964e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109651:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109655:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109659:	39 45 f8             	cmp    %eax,-0x8(%ebp)
8010965c:	7c af                	jl     8010960d <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
8010965e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109661:	f7 d0                	not    %eax
}
80109663:	c9                   	leave  
80109664:	c3                   	ret    

80109665 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109665:	55                   	push   %ebp
80109666:	89 e5                	mov    %esp,%ebp
80109668:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
8010966b:	8b 45 08             	mov    0x8(%ebp),%eax
8010966e:	83 c0 0e             	add    $0xe,%eax
80109671:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109674:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109677:	0f b6 00             	movzbl (%eax),%eax
8010967a:	0f b6 c0             	movzbl %al,%eax
8010967d:	83 e0 0f             	and    $0xf,%eax
80109680:	c1 e0 02             	shl    $0x2,%eax
80109683:	89 c2                	mov    %eax,%edx
80109685:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109688:	01 d0                	add    %edx,%eax
8010968a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
8010968d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109690:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109694:	84 c0                	test   %al,%al
80109696:	75 4f                	jne    801096e7 <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109698:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010969b:	0f b6 00             	movzbl (%eax),%eax
8010969e:	3c 08                	cmp    $0x8,%al
801096a0:	75 45                	jne    801096e7 <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
801096a2:	e8 ea 90 ff ff       	call   80102791 <kalloc>
801096a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
801096aa:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
801096b1:	83 ec 04             	sub    $0x4,%esp
801096b4:	8d 45 e8             	lea    -0x18(%ebp),%eax
801096b7:	50                   	push   %eax
801096b8:	ff 75 ec             	push   -0x14(%ebp)
801096bb:	ff 75 08             	push   0x8(%ebp)
801096be:	e8 78 00 00 00       	call   8010973b <icmp_reply_pkt_create>
801096c3:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
801096c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096c9:	83 ec 08             	sub    $0x8,%esp
801096cc:	50                   	push   %eax
801096cd:	ff 75 ec             	push   -0x14(%ebp)
801096d0:	e8 95 f4 ff ff       	call   80108b6a <i8254_send>
801096d5:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
801096d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801096db:	83 ec 0c             	sub    $0xc,%esp
801096de:	50                   	push   %eax
801096df:	e8 13 90 ff ff       	call   801026f7 <kfree>
801096e4:	83 c4 10             	add    $0x10,%esp
    }
  }
}
801096e7:	90                   	nop
801096e8:	c9                   	leave  
801096e9:	c3                   	ret    

801096ea <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
801096ea:	55                   	push   %ebp
801096eb:	89 e5                	mov    %esp,%ebp
801096ed:	53                   	push   %ebx
801096ee:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
801096f1:	8b 45 08             	mov    0x8(%ebp),%eax
801096f4:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801096f8:	0f b7 c0             	movzwl %ax,%eax
801096fb:	83 ec 0c             	sub    $0xc,%esp
801096fe:	50                   	push   %eax
801096ff:	e8 bd fd ff ff       	call   801094c1 <N2H_ushort>
80109704:	83 c4 10             	add    $0x10,%esp
80109707:	0f b7 d8             	movzwl %ax,%ebx
8010970a:	8b 45 08             	mov    0x8(%ebp),%eax
8010970d:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109711:	0f b7 c0             	movzwl %ax,%eax
80109714:	83 ec 0c             	sub    $0xc,%esp
80109717:	50                   	push   %eax
80109718:	e8 a4 fd ff ff       	call   801094c1 <N2H_ushort>
8010971d:	83 c4 10             	add    $0x10,%esp
80109720:	0f b7 c0             	movzwl %ax,%eax
80109723:	83 ec 04             	sub    $0x4,%esp
80109726:	53                   	push   %ebx
80109727:	50                   	push   %eax
80109728:	68 83 c0 10 80       	push   $0x8010c083
8010972d:	e8 c2 6c ff ff       	call   801003f4 <cprintf>
80109732:	83 c4 10             	add    $0x10,%esp
}
80109735:	90                   	nop
80109736:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109739:	c9                   	leave  
8010973a:	c3                   	ret    

8010973b <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
8010973b:	55                   	push   %ebp
8010973c:	89 e5                	mov    %esp,%ebp
8010973e:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109741:	8b 45 08             	mov    0x8(%ebp),%eax
80109744:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109747:	8b 45 08             	mov    0x8(%ebp),%eax
8010974a:	83 c0 0e             	add    $0xe,%eax
8010974d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109750:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109753:	0f b6 00             	movzbl (%eax),%eax
80109756:	0f b6 c0             	movzbl %al,%eax
80109759:	83 e0 0f             	and    $0xf,%eax
8010975c:	c1 e0 02             	shl    $0x2,%eax
8010975f:	89 c2                	mov    %eax,%edx
80109761:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109764:	01 d0                	add    %edx,%eax
80109766:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109769:	8b 45 0c             	mov    0xc(%ebp),%eax
8010976c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
8010976f:	8b 45 0c             	mov    0xc(%ebp),%eax
80109772:	83 c0 0e             	add    $0xe,%eax
80109775:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109778:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010977b:	83 c0 14             	add    $0x14,%eax
8010977e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109781:	8b 45 10             	mov    0x10(%ebp),%eax
80109784:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010978a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010978d:	8d 50 06             	lea    0x6(%eax),%edx
80109790:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109793:	83 ec 04             	sub    $0x4,%esp
80109796:	6a 06                	push   $0x6
80109798:	52                   	push   %edx
80109799:	50                   	push   %eax
8010979a:	e8 d1 b3 ff ff       	call   80104b70 <memmove>
8010979f:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
801097a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801097a5:	83 c0 06             	add    $0x6,%eax
801097a8:	83 ec 04             	sub    $0x4,%esp
801097ab:	6a 06                	push   $0x6
801097ad:	68 80 6c 19 80       	push   $0x80196c80
801097b2:	50                   	push   %eax
801097b3:	e8 b8 b3 ff ff       	call   80104b70 <memmove>
801097b8:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
801097bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801097be:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
801097c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801097c5:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
801097c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801097cc:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
801097cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801097d2:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
801097d6:	83 ec 0c             	sub    $0xc,%esp
801097d9:	6a 54                	push   $0x54
801097db:	e8 03 fd ff ff       	call   801094e3 <H2N_ushort>
801097e0:	83 c4 10             	add    $0x10,%esp
801097e3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801097e6:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
801097ea:	0f b7 15 60 6f 19 80 	movzwl 0x80196f60,%edx
801097f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801097f4:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
801097f8:	0f b7 05 60 6f 19 80 	movzwl 0x80196f60,%eax
801097ff:	83 c0 01             	add    $0x1,%eax
80109802:	66 a3 60 6f 19 80    	mov    %ax,0x80196f60
  ipv4_send->fragment = H2N_ushort(0x4000);
80109808:	83 ec 0c             	sub    $0xc,%esp
8010980b:	68 00 40 00 00       	push   $0x4000
80109810:	e8 ce fc ff ff       	call   801094e3 <H2N_ushort>
80109815:	83 c4 10             	add    $0x10,%esp
80109818:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010981b:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010981f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109822:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109826:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109829:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010982d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109830:	83 c0 0c             	add    $0xc,%eax
80109833:	83 ec 04             	sub    $0x4,%esp
80109836:	6a 04                	push   $0x4
80109838:	68 e4 f4 10 80       	push   $0x8010f4e4
8010983d:	50                   	push   %eax
8010983e:	e8 2d b3 ff ff       	call   80104b70 <memmove>
80109843:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109846:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109849:	8d 50 0c             	lea    0xc(%eax),%edx
8010984c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010984f:	83 c0 10             	add    $0x10,%eax
80109852:	83 ec 04             	sub    $0x4,%esp
80109855:	6a 04                	push   $0x4
80109857:	52                   	push   %edx
80109858:	50                   	push   %eax
80109859:	e8 12 b3 ff ff       	call   80104b70 <memmove>
8010985e:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109861:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109864:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010986a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010986d:	83 ec 0c             	sub    $0xc,%esp
80109870:	50                   	push   %eax
80109871:	e8 6d fd ff ff       	call   801095e3 <ipv4_chksum>
80109876:	83 c4 10             	add    $0x10,%esp
80109879:	0f b7 c0             	movzwl %ax,%eax
8010987c:	83 ec 0c             	sub    $0xc,%esp
8010987f:	50                   	push   %eax
80109880:	e8 5e fc ff ff       	call   801094e3 <H2N_ushort>
80109885:	83 c4 10             	add    $0x10,%esp
80109888:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010988b:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
8010988f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109892:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109895:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109898:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
8010989c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010989f:	0f b7 50 04          	movzwl 0x4(%eax),%edx
801098a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801098a6:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
801098aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801098ad:	0f b7 50 06          	movzwl 0x6(%eax),%edx
801098b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801098b4:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
801098b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801098bb:	8d 50 08             	lea    0x8(%eax),%edx
801098be:	8b 45 e0             	mov    -0x20(%ebp),%eax
801098c1:	83 c0 08             	add    $0x8,%eax
801098c4:	83 ec 04             	sub    $0x4,%esp
801098c7:	6a 08                	push   $0x8
801098c9:	52                   	push   %edx
801098ca:	50                   	push   %eax
801098cb:	e8 a0 b2 ff ff       	call   80104b70 <memmove>
801098d0:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
801098d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801098d6:	8d 50 10             	lea    0x10(%eax),%edx
801098d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801098dc:	83 c0 10             	add    $0x10,%eax
801098df:	83 ec 04             	sub    $0x4,%esp
801098e2:	6a 30                	push   $0x30
801098e4:	52                   	push   %edx
801098e5:	50                   	push   %eax
801098e6:	e8 85 b2 ff ff       	call   80104b70 <memmove>
801098eb:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
801098ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
801098f1:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
801098f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801098fa:	83 ec 0c             	sub    $0xc,%esp
801098fd:	50                   	push   %eax
801098fe:	e8 1c 00 00 00       	call   8010991f <icmp_chksum>
80109903:	83 c4 10             	add    $0x10,%esp
80109906:	0f b7 c0             	movzwl %ax,%eax
80109909:	83 ec 0c             	sub    $0xc,%esp
8010990c:	50                   	push   %eax
8010990d:	e8 d1 fb ff ff       	call   801094e3 <H2N_ushort>
80109912:	83 c4 10             	add    $0x10,%esp
80109915:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109918:	66 89 42 02          	mov    %ax,0x2(%edx)
}
8010991c:	90                   	nop
8010991d:	c9                   	leave  
8010991e:	c3                   	ret    

8010991f <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
8010991f:	55                   	push   %ebp
80109920:	89 e5                	mov    %esp,%ebp
80109922:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109925:	8b 45 08             	mov    0x8(%ebp),%eax
80109928:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
8010992b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109932:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109939:	eb 48                	jmp    80109983 <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010993b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010993e:	01 c0                	add    %eax,%eax
80109940:	89 c2                	mov    %eax,%edx
80109942:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109945:	01 d0                	add    %edx,%eax
80109947:	0f b6 00             	movzbl (%eax),%eax
8010994a:	0f b6 c0             	movzbl %al,%eax
8010994d:	c1 e0 08             	shl    $0x8,%eax
80109950:	89 c2                	mov    %eax,%edx
80109952:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109955:	01 c0                	add    %eax,%eax
80109957:	8d 48 01             	lea    0x1(%eax),%ecx
8010995a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010995d:	01 c8                	add    %ecx,%eax
8010995f:	0f b6 00             	movzbl (%eax),%eax
80109962:	0f b6 c0             	movzbl %al,%eax
80109965:	01 d0                	add    %edx,%eax
80109967:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010996a:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109971:	76 0c                	jbe    8010997f <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
80109973:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109976:	0f b7 c0             	movzwl %ax,%eax
80109979:	83 c0 01             	add    $0x1,%eax
8010997c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010997f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109983:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109987:	7e b2                	jle    8010993b <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
80109989:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010998c:	f7 d0                	not    %eax
}
8010998e:	c9                   	leave  
8010998f:	c3                   	ret    

80109990 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109990:	55                   	push   %ebp
80109991:	89 e5                	mov    %esp,%ebp
80109993:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109996:	8b 45 08             	mov    0x8(%ebp),%eax
80109999:	83 c0 0e             	add    $0xe,%eax
8010999c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010999f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099a2:	0f b6 00             	movzbl (%eax),%eax
801099a5:	0f b6 c0             	movzbl %al,%eax
801099a8:	83 e0 0f             	and    $0xf,%eax
801099ab:	c1 e0 02             	shl    $0x2,%eax
801099ae:	89 c2                	mov    %eax,%edx
801099b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099b3:	01 d0                	add    %edx,%eax
801099b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
801099b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099bb:	83 c0 14             	add    $0x14,%eax
801099be:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
801099c1:	e8 cb 8d ff ff       	call   80102791 <kalloc>
801099c6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
801099c9:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
801099d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099d3:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801099d7:	0f b6 c0             	movzbl %al,%eax
801099da:	83 e0 02             	and    $0x2,%eax
801099dd:	85 c0                	test   %eax,%eax
801099df:	74 3d                	je     80109a1e <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
801099e1:	83 ec 0c             	sub    $0xc,%esp
801099e4:	6a 00                	push   $0x0
801099e6:	6a 12                	push   $0x12
801099e8:	8d 45 dc             	lea    -0x24(%ebp),%eax
801099eb:	50                   	push   %eax
801099ec:	ff 75 e8             	push   -0x18(%ebp)
801099ef:	ff 75 08             	push   0x8(%ebp)
801099f2:	e8 a2 01 00 00       	call   80109b99 <tcp_pkt_create>
801099f7:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
801099fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
801099fd:	83 ec 08             	sub    $0x8,%esp
80109a00:	50                   	push   %eax
80109a01:	ff 75 e8             	push   -0x18(%ebp)
80109a04:	e8 61 f1 ff ff       	call   80108b6a <i8254_send>
80109a09:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109a0c:	a1 64 6f 19 80       	mov    0x80196f64,%eax
80109a11:	83 c0 01             	add    $0x1,%eax
80109a14:	a3 64 6f 19 80       	mov    %eax,0x80196f64
80109a19:	e9 69 01 00 00       	jmp    80109b87 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109a1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a21:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109a25:	3c 18                	cmp    $0x18,%al
80109a27:	0f 85 10 01 00 00    	jne    80109b3d <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
80109a2d:	83 ec 04             	sub    $0x4,%esp
80109a30:	6a 03                	push   $0x3
80109a32:	68 9e c0 10 80       	push   $0x8010c09e
80109a37:	ff 75 ec             	push   -0x14(%ebp)
80109a3a:	e8 d9 b0 ff ff       	call   80104b18 <memcmp>
80109a3f:	83 c4 10             	add    $0x10,%esp
80109a42:	85 c0                	test   %eax,%eax
80109a44:	74 74                	je     80109aba <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
80109a46:	83 ec 0c             	sub    $0xc,%esp
80109a49:	68 a2 c0 10 80       	push   $0x8010c0a2
80109a4e:	e8 a1 69 ff ff       	call   801003f4 <cprintf>
80109a53:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109a56:	83 ec 0c             	sub    $0xc,%esp
80109a59:	6a 00                	push   $0x0
80109a5b:	6a 10                	push   $0x10
80109a5d:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109a60:	50                   	push   %eax
80109a61:	ff 75 e8             	push   -0x18(%ebp)
80109a64:	ff 75 08             	push   0x8(%ebp)
80109a67:	e8 2d 01 00 00       	call   80109b99 <tcp_pkt_create>
80109a6c:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109a6f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109a72:	83 ec 08             	sub    $0x8,%esp
80109a75:	50                   	push   %eax
80109a76:	ff 75 e8             	push   -0x18(%ebp)
80109a79:	e8 ec f0 ff ff       	call   80108b6a <i8254_send>
80109a7e:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109a81:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a84:	83 c0 36             	add    $0x36,%eax
80109a87:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109a8a:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109a8d:	50                   	push   %eax
80109a8e:	ff 75 e0             	push   -0x20(%ebp)
80109a91:	6a 00                	push   $0x0
80109a93:	6a 00                	push   $0x0
80109a95:	e8 5a 04 00 00       	call   80109ef4 <http_proc>
80109a9a:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109a9d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109aa0:	83 ec 0c             	sub    $0xc,%esp
80109aa3:	50                   	push   %eax
80109aa4:	6a 18                	push   $0x18
80109aa6:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109aa9:	50                   	push   %eax
80109aaa:	ff 75 e8             	push   -0x18(%ebp)
80109aad:	ff 75 08             	push   0x8(%ebp)
80109ab0:	e8 e4 00 00 00       	call   80109b99 <tcp_pkt_create>
80109ab5:	83 c4 20             	add    $0x20,%esp
80109ab8:	eb 62                	jmp    80109b1c <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109aba:	83 ec 0c             	sub    $0xc,%esp
80109abd:	6a 00                	push   $0x0
80109abf:	6a 10                	push   $0x10
80109ac1:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109ac4:	50                   	push   %eax
80109ac5:	ff 75 e8             	push   -0x18(%ebp)
80109ac8:	ff 75 08             	push   0x8(%ebp)
80109acb:	e8 c9 00 00 00       	call   80109b99 <tcp_pkt_create>
80109ad0:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
80109ad3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109ad6:	83 ec 08             	sub    $0x8,%esp
80109ad9:	50                   	push   %eax
80109ada:	ff 75 e8             	push   -0x18(%ebp)
80109add:	e8 88 f0 ff ff       	call   80108b6a <i8254_send>
80109ae2:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109ae5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ae8:	83 c0 36             	add    $0x36,%eax
80109aeb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109aee:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109af1:	50                   	push   %eax
80109af2:	ff 75 e4             	push   -0x1c(%ebp)
80109af5:	6a 00                	push   $0x0
80109af7:	6a 00                	push   $0x0
80109af9:	e8 f6 03 00 00       	call   80109ef4 <http_proc>
80109afe:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109b01:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109b04:	83 ec 0c             	sub    $0xc,%esp
80109b07:	50                   	push   %eax
80109b08:	6a 18                	push   $0x18
80109b0a:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109b0d:	50                   	push   %eax
80109b0e:	ff 75 e8             	push   -0x18(%ebp)
80109b11:	ff 75 08             	push   0x8(%ebp)
80109b14:	e8 80 00 00 00       	call   80109b99 <tcp_pkt_create>
80109b19:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
80109b1c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109b1f:	83 ec 08             	sub    $0x8,%esp
80109b22:	50                   	push   %eax
80109b23:	ff 75 e8             	push   -0x18(%ebp)
80109b26:	e8 3f f0 ff ff       	call   80108b6a <i8254_send>
80109b2b:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109b2e:	a1 64 6f 19 80       	mov    0x80196f64,%eax
80109b33:	83 c0 01             	add    $0x1,%eax
80109b36:	a3 64 6f 19 80       	mov    %eax,0x80196f64
80109b3b:	eb 4a                	jmp    80109b87 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
80109b3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b40:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109b44:	3c 10                	cmp    $0x10,%al
80109b46:	75 3f                	jne    80109b87 <tcp_proc+0x1f7>
    if(fin_flag == 1){
80109b48:	a1 68 6f 19 80       	mov    0x80196f68,%eax
80109b4d:	83 f8 01             	cmp    $0x1,%eax
80109b50:	75 35                	jne    80109b87 <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
80109b52:	83 ec 0c             	sub    $0xc,%esp
80109b55:	6a 00                	push   $0x0
80109b57:	6a 01                	push   $0x1
80109b59:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109b5c:	50                   	push   %eax
80109b5d:	ff 75 e8             	push   -0x18(%ebp)
80109b60:	ff 75 08             	push   0x8(%ebp)
80109b63:	e8 31 00 00 00       	call   80109b99 <tcp_pkt_create>
80109b68:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109b6b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109b6e:	83 ec 08             	sub    $0x8,%esp
80109b71:	50                   	push   %eax
80109b72:	ff 75 e8             	push   -0x18(%ebp)
80109b75:	e8 f0 ef ff ff       	call   80108b6a <i8254_send>
80109b7a:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
80109b7d:	c7 05 68 6f 19 80 00 	movl   $0x0,0x80196f68
80109b84:	00 00 00 
    }
  }
  kfree((char *)send_addr);
80109b87:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b8a:	83 ec 0c             	sub    $0xc,%esp
80109b8d:	50                   	push   %eax
80109b8e:	e8 64 8b ff ff       	call   801026f7 <kfree>
80109b93:	83 c4 10             	add    $0x10,%esp
}
80109b96:	90                   	nop
80109b97:	c9                   	leave  
80109b98:	c3                   	ret    

80109b99 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
80109b99:	55                   	push   %ebp
80109b9a:	89 e5                	mov    %esp,%ebp
80109b9c:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109b9f:	8b 45 08             	mov    0x8(%ebp),%eax
80109ba2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109ba5:	8b 45 08             	mov    0x8(%ebp),%eax
80109ba8:	83 c0 0e             	add    $0xe,%eax
80109bab:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
80109bae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bb1:	0f b6 00             	movzbl (%eax),%eax
80109bb4:	0f b6 c0             	movzbl %al,%eax
80109bb7:	83 e0 0f             	and    $0xf,%eax
80109bba:	c1 e0 02             	shl    $0x2,%eax
80109bbd:	89 c2                	mov    %eax,%edx
80109bbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bc2:	01 d0                	add    %edx,%eax
80109bc4:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109bc7:	8b 45 0c             	mov    0xc(%ebp),%eax
80109bca:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
80109bcd:	8b 45 0c             	mov    0xc(%ebp),%eax
80109bd0:	83 c0 0e             	add    $0xe,%eax
80109bd3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
80109bd6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bd9:	83 c0 14             	add    $0x14,%eax
80109bdc:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
80109bdf:	8b 45 18             	mov    0x18(%ebp),%eax
80109be2:	8d 50 36             	lea    0x36(%eax),%edx
80109be5:	8b 45 10             	mov    0x10(%ebp),%eax
80109be8:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bed:	8d 50 06             	lea    0x6(%eax),%edx
80109bf0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109bf3:	83 ec 04             	sub    $0x4,%esp
80109bf6:	6a 06                	push   $0x6
80109bf8:	52                   	push   %edx
80109bf9:	50                   	push   %eax
80109bfa:	e8 71 af ff ff       	call   80104b70 <memmove>
80109bff:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109c02:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c05:	83 c0 06             	add    $0x6,%eax
80109c08:	83 ec 04             	sub    $0x4,%esp
80109c0b:	6a 06                	push   $0x6
80109c0d:	68 80 6c 19 80       	push   $0x80196c80
80109c12:	50                   	push   %eax
80109c13:	e8 58 af ff ff       	call   80104b70 <memmove>
80109c18:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109c1b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c1e:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109c22:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c25:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109c29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c2c:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109c2f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c32:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
80109c36:	8b 45 18             	mov    0x18(%ebp),%eax
80109c39:	83 c0 28             	add    $0x28,%eax
80109c3c:	0f b7 c0             	movzwl %ax,%eax
80109c3f:	83 ec 0c             	sub    $0xc,%esp
80109c42:	50                   	push   %eax
80109c43:	e8 9b f8 ff ff       	call   801094e3 <H2N_ushort>
80109c48:	83 c4 10             	add    $0x10,%esp
80109c4b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109c4e:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109c52:	0f b7 15 60 6f 19 80 	movzwl 0x80196f60,%edx
80109c59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c5c:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109c60:	0f b7 05 60 6f 19 80 	movzwl 0x80196f60,%eax
80109c67:	83 c0 01             	add    $0x1,%eax
80109c6a:	66 a3 60 6f 19 80    	mov    %ax,0x80196f60
  ipv4_send->fragment = H2N_ushort(0x0000);
80109c70:	83 ec 0c             	sub    $0xc,%esp
80109c73:	6a 00                	push   $0x0
80109c75:	e8 69 f8 ff ff       	call   801094e3 <H2N_ushort>
80109c7a:	83 c4 10             	add    $0x10,%esp
80109c7d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109c80:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109c84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c87:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
80109c8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c8e:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109c92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c95:	83 c0 0c             	add    $0xc,%eax
80109c98:	83 ec 04             	sub    $0x4,%esp
80109c9b:	6a 04                	push   $0x4
80109c9d:	68 e4 f4 10 80       	push   $0x8010f4e4
80109ca2:	50                   	push   %eax
80109ca3:	e8 c8 ae ff ff       	call   80104b70 <memmove>
80109ca8:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109cab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cae:	8d 50 0c             	lea    0xc(%eax),%edx
80109cb1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cb4:	83 c0 10             	add    $0x10,%eax
80109cb7:	83 ec 04             	sub    $0x4,%esp
80109cba:	6a 04                	push   $0x4
80109cbc:	52                   	push   %edx
80109cbd:	50                   	push   %eax
80109cbe:	e8 ad ae ff ff       	call   80104b70 <memmove>
80109cc3:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109cc6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cc9:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109ccf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cd2:	83 ec 0c             	sub    $0xc,%esp
80109cd5:	50                   	push   %eax
80109cd6:	e8 08 f9 ff ff       	call   801095e3 <ipv4_chksum>
80109cdb:	83 c4 10             	add    $0x10,%esp
80109cde:	0f b7 c0             	movzwl %ax,%eax
80109ce1:	83 ec 0c             	sub    $0xc,%esp
80109ce4:	50                   	push   %eax
80109ce5:	e8 f9 f7 ff ff       	call   801094e3 <H2N_ushort>
80109cea:	83 c4 10             	add    $0x10,%esp
80109ced:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109cf0:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
80109cf4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109cf7:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80109cfb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cfe:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
80109d01:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d04:	0f b7 10             	movzwl (%eax),%edx
80109d07:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d0a:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
80109d0e:	a1 64 6f 19 80       	mov    0x80196f64,%eax
80109d13:	83 ec 0c             	sub    $0xc,%esp
80109d16:	50                   	push   %eax
80109d17:	e8 e9 f7 ff ff       	call   80109505 <H2N_uint>
80109d1c:	83 c4 10             	add    $0x10,%esp
80109d1f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109d22:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
80109d25:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d28:	8b 40 04             	mov    0x4(%eax),%eax
80109d2b:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
80109d31:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d34:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
80109d37:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d3a:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
80109d3e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d41:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
80109d45:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d48:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
80109d4c:	8b 45 14             	mov    0x14(%ebp),%eax
80109d4f:	89 c2                	mov    %eax,%edx
80109d51:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d54:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
80109d57:	83 ec 0c             	sub    $0xc,%esp
80109d5a:	68 90 38 00 00       	push   $0x3890
80109d5f:	e8 7f f7 ff ff       	call   801094e3 <H2N_ushort>
80109d64:	83 c4 10             	add    $0x10,%esp
80109d67:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109d6a:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
80109d6e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d71:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
80109d77:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d7a:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
80109d80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d83:	83 ec 0c             	sub    $0xc,%esp
80109d86:	50                   	push   %eax
80109d87:	e8 1f 00 00 00       	call   80109dab <tcp_chksum>
80109d8c:	83 c4 10             	add    $0x10,%esp
80109d8f:	83 c0 08             	add    $0x8,%eax
80109d92:	0f b7 c0             	movzwl %ax,%eax
80109d95:	83 ec 0c             	sub    $0xc,%esp
80109d98:	50                   	push   %eax
80109d99:	e8 45 f7 ff ff       	call   801094e3 <H2N_ushort>
80109d9e:	83 c4 10             	add    $0x10,%esp
80109da1:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109da4:	66 89 42 10          	mov    %ax,0x10(%edx)


}
80109da8:	90                   	nop
80109da9:	c9                   	leave  
80109daa:	c3                   	ret    

80109dab <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
80109dab:	55                   	push   %ebp
80109dac:	89 e5                	mov    %esp,%ebp
80109dae:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
80109db1:	8b 45 08             	mov    0x8(%ebp),%eax
80109db4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
80109db7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109dba:	83 c0 14             	add    $0x14,%eax
80109dbd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
80109dc0:	83 ec 04             	sub    $0x4,%esp
80109dc3:	6a 04                	push   $0x4
80109dc5:	68 e4 f4 10 80       	push   $0x8010f4e4
80109dca:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109dcd:	50                   	push   %eax
80109dce:	e8 9d ad ff ff       	call   80104b70 <memmove>
80109dd3:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
80109dd6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109dd9:	83 c0 0c             	add    $0xc,%eax
80109ddc:	83 ec 04             	sub    $0x4,%esp
80109ddf:	6a 04                	push   $0x4
80109de1:	50                   	push   %eax
80109de2:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109de5:	83 c0 04             	add    $0x4,%eax
80109de8:	50                   	push   %eax
80109de9:	e8 82 ad ff ff       	call   80104b70 <memmove>
80109dee:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
80109df1:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
80109df5:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
80109df9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109dfc:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80109e00:	0f b7 c0             	movzwl %ax,%eax
80109e03:	83 ec 0c             	sub    $0xc,%esp
80109e06:	50                   	push   %eax
80109e07:	e8 b5 f6 ff ff       	call   801094c1 <N2H_ushort>
80109e0c:	83 c4 10             	add    $0x10,%esp
80109e0f:	83 e8 14             	sub    $0x14,%eax
80109e12:	0f b7 c0             	movzwl %ax,%eax
80109e15:	83 ec 0c             	sub    $0xc,%esp
80109e18:	50                   	push   %eax
80109e19:	e8 c5 f6 ff ff       	call   801094e3 <H2N_ushort>
80109e1e:	83 c4 10             	add    $0x10,%esp
80109e21:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
80109e25:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
80109e2c:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109e2f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
80109e32:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109e39:	eb 33                	jmp    80109e6e <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109e3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e3e:	01 c0                	add    %eax,%eax
80109e40:	89 c2                	mov    %eax,%edx
80109e42:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e45:	01 d0                	add    %edx,%eax
80109e47:	0f b6 00             	movzbl (%eax),%eax
80109e4a:	0f b6 c0             	movzbl %al,%eax
80109e4d:	c1 e0 08             	shl    $0x8,%eax
80109e50:	89 c2                	mov    %eax,%edx
80109e52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e55:	01 c0                	add    %eax,%eax
80109e57:	8d 48 01             	lea    0x1(%eax),%ecx
80109e5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e5d:	01 c8                	add    %ecx,%eax
80109e5f:	0f b6 00             	movzbl (%eax),%eax
80109e62:	0f b6 c0             	movzbl %al,%eax
80109e65:	01 d0                	add    %edx,%eax
80109e67:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
80109e6a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109e6e:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
80109e72:	7e c7                	jle    80109e3b <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
80109e74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e77:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
80109e7a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80109e81:	eb 33                	jmp    80109eb6 <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109e83:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109e86:	01 c0                	add    %eax,%eax
80109e88:	89 c2                	mov    %eax,%edx
80109e8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e8d:	01 d0                	add    %edx,%eax
80109e8f:	0f b6 00             	movzbl (%eax),%eax
80109e92:	0f b6 c0             	movzbl %al,%eax
80109e95:	c1 e0 08             	shl    $0x8,%eax
80109e98:	89 c2                	mov    %eax,%edx
80109e9a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109e9d:	01 c0                	add    %eax,%eax
80109e9f:	8d 48 01             	lea    0x1(%eax),%ecx
80109ea2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ea5:	01 c8                	add    %ecx,%eax
80109ea7:	0f b6 00             	movzbl (%eax),%eax
80109eaa:	0f b6 c0             	movzbl %al,%eax
80109ead:	01 d0                	add    %edx,%eax
80109eaf:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
80109eb2:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80109eb6:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
80109eba:	0f b7 c0             	movzwl %ax,%eax
80109ebd:	83 ec 0c             	sub    $0xc,%esp
80109ec0:	50                   	push   %eax
80109ec1:	e8 fb f5 ff ff       	call   801094c1 <N2H_ushort>
80109ec6:	83 c4 10             	add    $0x10,%esp
80109ec9:	66 d1 e8             	shr    %ax
80109ecc:	0f b7 c0             	movzwl %ax,%eax
80109ecf:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80109ed2:	7c af                	jl     80109e83 <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
80109ed4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ed7:	c1 e8 10             	shr    $0x10,%eax
80109eda:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
80109edd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ee0:	f7 d0                	not    %eax
}
80109ee2:	c9                   	leave  
80109ee3:	c3                   	ret    

80109ee4 <tcp_fin>:

void tcp_fin(){
80109ee4:	55                   	push   %ebp
80109ee5:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
80109ee7:	c7 05 68 6f 19 80 01 	movl   $0x1,0x80196f68
80109eee:	00 00 00 
}
80109ef1:	90                   	nop
80109ef2:	5d                   	pop    %ebp
80109ef3:	c3                   	ret    

80109ef4 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
80109ef4:	55                   	push   %ebp
80109ef5:	89 e5                	mov    %esp,%ebp
80109ef7:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
80109efa:	8b 45 10             	mov    0x10(%ebp),%eax
80109efd:	83 ec 04             	sub    $0x4,%esp
80109f00:	6a 00                	push   $0x0
80109f02:	68 ab c0 10 80       	push   $0x8010c0ab
80109f07:	50                   	push   %eax
80109f08:	e8 65 00 00 00       	call   80109f72 <http_strcpy>
80109f0d:	83 c4 10             	add    $0x10,%esp
80109f10:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
80109f13:	8b 45 10             	mov    0x10(%ebp),%eax
80109f16:	83 ec 04             	sub    $0x4,%esp
80109f19:	ff 75 f4             	push   -0xc(%ebp)
80109f1c:	68 be c0 10 80       	push   $0x8010c0be
80109f21:	50                   	push   %eax
80109f22:	e8 4b 00 00 00       	call   80109f72 <http_strcpy>
80109f27:	83 c4 10             	add    $0x10,%esp
80109f2a:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
80109f2d:	8b 45 10             	mov    0x10(%ebp),%eax
80109f30:	83 ec 04             	sub    $0x4,%esp
80109f33:	ff 75 f4             	push   -0xc(%ebp)
80109f36:	68 d9 c0 10 80       	push   $0x8010c0d9
80109f3b:	50                   	push   %eax
80109f3c:	e8 31 00 00 00       	call   80109f72 <http_strcpy>
80109f41:	83 c4 10             	add    $0x10,%esp
80109f44:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
80109f47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f4a:	83 e0 01             	and    $0x1,%eax
80109f4d:	85 c0                	test   %eax,%eax
80109f4f:	74 11                	je     80109f62 <http_proc+0x6e>
    char *payload = (char *)send;
80109f51:	8b 45 10             	mov    0x10(%ebp),%eax
80109f54:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
80109f57:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109f5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f5d:	01 d0                	add    %edx,%eax
80109f5f:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
80109f62:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109f65:	8b 45 14             	mov    0x14(%ebp),%eax
80109f68:	89 10                	mov    %edx,(%eax)
  tcp_fin();
80109f6a:	e8 75 ff ff ff       	call   80109ee4 <tcp_fin>
}
80109f6f:	90                   	nop
80109f70:	c9                   	leave  
80109f71:	c3                   	ret    

80109f72 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
80109f72:	55                   	push   %ebp
80109f73:	89 e5                	mov    %esp,%ebp
80109f75:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
80109f78:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
80109f7f:	eb 20                	jmp    80109fa1 <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
80109f81:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109f84:	8b 45 0c             	mov    0xc(%ebp),%eax
80109f87:	01 d0                	add    %edx,%eax
80109f89:	8b 4d 10             	mov    0x10(%ebp),%ecx
80109f8c:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109f8f:	01 ca                	add    %ecx,%edx
80109f91:	89 d1                	mov    %edx,%ecx
80109f93:	8b 55 08             	mov    0x8(%ebp),%edx
80109f96:	01 ca                	add    %ecx,%edx
80109f98:	0f b6 00             	movzbl (%eax),%eax
80109f9b:	88 02                	mov    %al,(%edx)
    i++;
80109f9d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
80109fa1:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109fa4:	8b 45 0c             	mov    0xc(%ebp),%eax
80109fa7:	01 d0                	add    %edx,%eax
80109fa9:	0f b6 00             	movzbl (%eax),%eax
80109fac:	84 c0                	test   %al,%al
80109fae:	75 d1                	jne    80109f81 <http_strcpy+0xf>
  }
  return i;
80109fb0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80109fb3:	c9                   	leave  
80109fb4:	c3                   	ret    

80109fb5 <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
80109fb5:	55                   	push   %ebp
80109fb6:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
80109fb8:	c7 05 70 6f 19 80 a2 	movl   $0x8010f5a2,0x80196f70
80109fbf:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
80109fc2:	b8 00 d0 07 00       	mov    $0x7d000,%eax
80109fc7:	c1 e8 09             	shr    $0x9,%eax
80109fca:	a3 6c 6f 19 80       	mov    %eax,0x80196f6c
}
80109fcf:	90                   	nop
80109fd0:	5d                   	pop    %ebp
80109fd1:	c3                   	ret    

80109fd2 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80109fd2:	55                   	push   %ebp
80109fd3:	89 e5                	mov    %esp,%ebp
  // no-op
}
80109fd5:	90                   	nop
80109fd6:	5d                   	pop    %ebp
80109fd7:	c3                   	ret    

80109fd8 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80109fd8:	55                   	push   %ebp
80109fd9:	89 e5                	mov    %esp,%ebp
80109fdb:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
80109fde:	8b 45 08             	mov    0x8(%ebp),%eax
80109fe1:	83 c0 0c             	add    $0xc,%eax
80109fe4:	83 ec 0c             	sub    $0xc,%esp
80109fe7:	50                   	push   %eax
80109fe8:	e8 bd a7 ff ff       	call   801047aa <holdingsleep>
80109fed:	83 c4 10             	add    $0x10,%esp
80109ff0:	85 c0                	test   %eax,%eax
80109ff2:	75 0d                	jne    8010a001 <iderw+0x29>
    panic("iderw: buf not locked");
80109ff4:	83 ec 0c             	sub    $0xc,%esp
80109ff7:	68 ea c0 10 80       	push   $0x8010c0ea
80109ffc:	e8 a8 65 ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a001:	8b 45 08             	mov    0x8(%ebp),%eax
8010a004:	8b 00                	mov    (%eax),%eax
8010a006:	83 e0 06             	and    $0x6,%eax
8010a009:	83 f8 02             	cmp    $0x2,%eax
8010a00c:	75 0d                	jne    8010a01b <iderw+0x43>
    panic("iderw: nothing to do");
8010a00e:	83 ec 0c             	sub    $0xc,%esp
8010a011:	68 00 c1 10 80       	push   $0x8010c100
8010a016:	e8 8e 65 ff ff       	call   801005a9 <panic>
  if(b->dev != 1)
8010a01b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a01e:	8b 40 04             	mov    0x4(%eax),%eax
8010a021:	83 f8 01             	cmp    $0x1,%eax
8010a024:	74 0d                	je     8010a033 <iderw+0x5b>
    panic("iderw: request not for disk 1");
8010a026:	83 ec 0c             	sub    $0xc,%esp
8010a029:	68 15 c1 10 80       	push   $0x8010c115
8010a02e:	e8 76 65 ff ff       	call   801005a9 <panic>
  if(b->blockno >= disksize)
8010a033:	8b 45 08             	mov    0x8(%ebp),%eax
8010a036:	8b 40 08             	mov    0x8(%eax),%eax
8010a039:	8b 15 6c 6f 19 80    	mov    0x80196f6c,%edx
8010a03f:	39 d0                	cmp    %edx,%eax
8010a041:	72 0d                	jb     8010a050 <iderw+0x78>
    panic("iderw: block out of range");
8010a043:	83 ec 0c             	sub    $0xc,%esp
8010a046:	68 33 c1 10 80       	push   $0x8010c133
8010a04b:	e8 59 65 ff ff       	call   801005a9 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a050:	8b 15 70 6f 19 80    	mov    0x80196f70,%edx
8010a056:	8b 45 08             	mov    0x8(%ebp),%eax
8010a059:	8b 40 08             	mov    0x8(%eax),%eax
8010a05c:	c1 e0 09             	shl    $0x9,%eax
8010a05f:	01 d0                	add    %edx,%eax
8010a061:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a064:	8b 45 08             	mov    0x8(%ebp),%eax
8010a067:	8b 00                	mov    (%eax),%eax
8010a069:	83 e0 04             	and    $0x4,%eax
8010a06c:	85 c0                	test   %eax,%eax
8010a06e:	74 2b                	je     8010a09b <iderw+0xc3>
    b->flags &= ~B_DIRTY;
8010a070:	8b 45 08             	mov    0x8(%ebp),%eax
8010a073:	8b 00                	mov    (%eax),%eax
8010a075:	83 e0 fb             	and    $0xfffffffb,%eax
8010a078:	89 c2                	mov    %eax,%edx
8010a07a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a07d:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a07f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a082:	83 c0 5c             	add    $0x5c,%eax
8010a085:	83 ec 04             	sub    $0x4,%esp
8010a088:	68 00 02 00 00       	push   $0x200
8010a08d:	50                   	push   %eax
8010a08e:	ff 75 f4             	push   -0xc(%ebp)
8010a091:	e8 da aa ff ff       	call   80104b70 <memmove>
8010a096:	83 c4 10             	add    $0x10,%esp
8010a099:	eb 1a                	jmp    8010a0b5 <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
8010a09b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a09e:	83 c0 5c             	add    $0x5c,%eax
8010a0a1:	83 ec 04             	sub    $0x4,%esp
8010a0a4:	68 00 02 00 00       	push   $0x200
8010a0a9:	ff 75 f4             	push   -0xc(%ebp)
8010a0ac:	50                   	push   %eax
8010a0ad:	e8 be aa ff ff       	call   80104b70 <memmove>
8010a0b2:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a0b5:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0b8:	8b 00                	mov    (%eax),%eax
8010a0ba:	83 c8 02             	or     $0x2,%eax
8010a0bd:	89 c2                	mov    %eax,%edx
8010a0bf:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0c2:	89 10                	mov    %edx,(%eax)
}
8010a0c4:	90                   	nop
8010a0c5:	c9                   	leave  
8010a0c6:	c3                   	ret    
