
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
8010005a:	bc 80 80 19 80       	mov    $0x80198080,%esp
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
8010006f:	68 20 a0 10 80       	push   $0x8010a020
80100074:	68 00 d0 18 80       	push   $0x8018d000
80100079:	e8 6c 46 00 00       	call   801046ea <initlock>
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
801000bd:	68 27 a0 10 80       	push   $0x8010a027
801000c2:	50                   	push   %eax
801000c3:	e8 c5 44 00 00       	call   8010458d <initsleeplock>
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
80100101:	e8 06 46 00 00       	call   8010470c <acquire>
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
80100140:	e8 35 46 00 00       	call   8010477a <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 72 44 00 00       	call   801045c9 <acquiresleep>
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
801001c1:	e8 b4 45 00 00       	call   8010477a <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 f1 43 00 00       	call   801045c9 <acquiresleep>
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
801001f5:	68 2e a0 10 80       	push   $0x8010a02e
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
8010022d:	e8 e6 9c 00 00       	call   80109f18 <iderw>
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
8010024a:	e8 2c 44 00 00       	call   8010467b <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 3f a0 10 80       	push   $0x8010a03f
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
80100278:	e8 9b 9c 00 00       	call   80109f18 <iderw>
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
80100293:	e8 e3 43 00 00       	call   8010467b <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 46 a0 10 80       	push   $0x8010a046
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 72 43 00 00       	call   8010462d <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 d0 18 80       	push   $0x8018d000
801002c6:	e8 41 44 00 00       	call   8010470c <acquire>
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
80100336:	e8 3f 44 00 00       	call   8010477a <release>
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
80100410:	e8 f7 42 00 00       	call   8010470c <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 4d a0 10 80       	push   $0x8010a04d
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
80100510:	c7 45 ec 56 a0 10 80 	movl   $0x8010a056,-0x14(%ebp)
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
8010059e:	e8 d7 41 00 00       	call   8010477a <release>
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
801005c7:	68 5d a0 10 80       	push   $0x8010a05d
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
801005e6:	68 71 a0 10 80       	push   $0x8010a071
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 c9 41 00 00       	call   801047cc <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 73 a0 10 80       	push   $0x8010a073
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
801006a0:	e8 ca 77 00 00       	call   80107e6f <graphic_scroll_up>
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
801006f3:	e8 77 77 00 00       	call   80107e6f <graphic_scroll_up>
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
80100757:	e8 7e 77 00 00       	call   80107eda <font_render>
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
80100793:	e8 4e 5b 00 00       	call   801062e6 <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 41 5b 00 00       	call   801062e6 <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 34 5b 00 00       	call   801062e6 <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x56>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 24 5b 00 00       	call   801062e6 <uartputc>
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
801007eb:	e8 1c 3f 00 00       	call   8010470c <acquire>
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
80100962:	e8 13 3e 00 00       	call   8010477a <release>
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
8010099a:	e8 6d 3d 00 00       	call   8010470c <acquire>
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
801009bb:	e8 ba 3d 00 00       	call   8010477a <release>
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
80100a66:	e8 0f 3d 00 00       	call   8010477a <release>
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
80100aa2:	e8 65 3c 00 00       	call   8010470c <acquire>
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
80100ae4:	e8 91 3c 00 00       	call   8010477a <release>
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
80100b12:	68 77 a0 10 80       	push   $0x8010a077
80100b17:	68 00 1a 19 80       	push   $0x80191a00
80100b1c:	e8 c9 3b 00 00       	call   801046ea <initlock>
80100b21:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b24:	c7 05 4c 1a 19 80 86 	movl   $0x80100a86,0x80191a4c
80100b2b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b2e:	c7 05 48 1a 19 80 78 	movl   $0x80100978,0x80191a48
80100b35:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b38:	c7 45 f4 7f a0 10 80 	movl   $0x8010a07f,-0xc(%ebp)
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
80100bb5:	68 95 a0 10 80       	push   $0x8010a095
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
80100c11:	e8 cc 66 00 00       	call   801072e2 <setupkvm>
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
80100cb7:	e8 1f 6a 00 00       	call   801076db <allocuvm>
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
80100cfd:	e8 0c 69 00 00       	call   8010760e <loaduvm>
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
80100d6c:	e8 6a 69 00 00       	call   801076db <allocuvm>
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
80100d90:	e8 a8 6b 00 00       	call   8010793d <clearpteu>
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
80100dc9:	e8 02 3e 00 00       	call   80104bd0 <strlen>
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
80100df6:	e8 d5 3d 00 00       	call   80104bd0 <strlen>
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
80100e1c:	e8 bb 6c 00 00       	call   80107adc <copyout>
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
80100eb8:	e8 1f 6c 00 00       	call   80107adc <copyout>
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
80100f06:	e8 7a 3c 00 00       	call   80104b85 <safestrcpy>
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
80100f49:	e8 b1 64 00 00       	call   801073ff <switchuvm>
80100f4e:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f51:	83 ec 0c             	sub    $0xc,%esp
80100f54:	ff 75 cc             	push   -0x34(%ebp)
80100f57:	e8 48 69 00 00       	call   801078a4 <freevm>
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
80100f97:	e8 08 69 00 00       	call   801078a4 <freevm>
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
80100fc8:	68 a1 a0 10 80       	push   $0x8010a0a1
80100fcd:	68 a0 1a 19 80       	push   $0x80191aa0
80100fd2:	e8 13 37 00 00       	call   801046ea <initlock>
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
80100feb:	e8 1c 37 00 00       	call   8010470c <acquire>
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
80101018:	e8 5d 37 00 00       	call   8010477a <release>
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
8010103b:	e8 3a 37 00 00       	call   8010477a <release>
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
80101058:	e8 af 36 00 00       	call   8010470c <acquire>
8010105d:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101060:	8b 45 08             	mov    0x8(%ebp),%eax
80101063:	8b 40 04             	mov    0x4(%eax),%eax
80101066:	85 c0                	test   %eax,%eax
80101068:	7f 0d                	jg     80101077 <filedup+0x2d>
    panic("filedup");
8010106a:	83 ec 0c             	sub    $0xc,%esp
8010106d:	68 a8 a0 10 80       	push   $0x8010a0a8
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
8010108e:	e8 e7 36 00 00       	call   8010477a <release>
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
801010a9:	e8 5e 36 00 00       	call   8010470c <acquire>
801010ae:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010b1:	8b 45 08             	mov    0x8(%ebp),%eax
801010b4:	8b 40 04             	mov    0x4(%eax),%eax
801010b7:	85 c0                	test   %eax,%eax
801010b9:	7f 0d                	jg     801010c8 <fileclose+0x2d>
    panic("fileclose");
801010bb:	83 ec 0c             	sub    $0xc,%esp
801010be:	68 b0 a0 10 80       	push   $0x8010a0b0
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
801010e9:	e8 8c 36 00 00       	call   8010477a <release>
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
80101137:	e8 3e 36 00 00       	call   8010477a <release>
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
80101286:	68 ba a0 10 80       	push   $0x8010a0ba
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
80101389:	68 c3 a0 10 80       	push   $0x8010a0c3
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
801013bf:	68 d3 a0 10 80       	push   $0x8010a0d3
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
801013f7:	e8 45 36 00 00       	call   80104a41 <memmove>
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
8010143d:	e8 40 35 00 00       	call   80104982 <memset>
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
8010159c:	68 e0 a0 10 80       	push   $0x8010a0e0
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
80101627:	68 f6 a0 10 80       	push   $0x8010a0f6
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
8010168b:	68 09 a1 10 80       	push   $0x8010a109
80101690:	68 60 24 19 80       	push   $0x80192460
80101695:	e8 50 30 00 00       	call   801046ea <initlock>
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
801016c1:	68 10 a1 10 80       	push   $0x8010a110
801016c6:	50                   	push   %eax
801016c7:	e8 c1 2e 00 00       	call   8010458d <initsleeplock>
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
80101720:	68 18 a1 10 80       	push   $0x8010a118
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
80101799:	e8 e4 31 00 00       	call   80104982 <memset>
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
80101801:	68 6b a1 10 80       	push   $0x8010a16b
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
801018a7:	e8 95 31 00 00       	call   80104a41 <memmove>
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
801018dc:	e8 2b 2e 00 00       	call   8010470c <acquire>
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
8010192a:	e8 4b 2e 00 00       	call   8010477a <release>
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
80101966:	68 7d a1 10 80       	push   $0x8010a17d
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
801019a3:	e8 d2 2d 00 00       	call   8010477a <release>
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
801019be:	e8 49 2d 00 00       	call   8010470c <acquire>
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
801019dd:	e8 98 2d 00 00       	call   8010477a <release>
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
80101a03:	68 8d a1 10 80       	push   $0x8010a18d
80101a08:	e8 9c eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a10:	83 c0 0c             	add    $0xc,%eax
80101a13:	83 ec 0c             	sub    $0xc,%esp
80101a16:	50                   	push   %eax
80101a17:	e8 ad 2b 00 00       	call   801045c9 <acquiresleep>
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
80101ac1:	e8 7b 2f 00 00       	call   80104a41 <memmove>
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
80101af0:	68 93 a1 10 80       	push   $0x8010a193
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
80101b13:	e8 63 2b 00 00       	call   8010467b <holdingsleep>
80101b18:	83 c4 10             	add    $0x10,%esp
80101b1b:	85 c0                	test   %eax,%eax
80101b1d:	74 0a                	je     80101b29 <iunlock+0x2c>
80101b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b22:	8b 40 08             	mov    0x8(%eax),%eax
80101b25:	85 c0                	test   %eax,%eax
80101b27:	7f 0d                	jg     80101b36 <iunlock+0x39>
    panic("iunlock");
80101b29:	83 ec 0c             	sub    $0xc,%esp
80101b2c:	68 a2 a1 10 80       	push   $0x8010a1a2
80101b31:	e8 73 ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b36:	8b 45 08             	mov    0x8(%ebp),%eax
80101b39:	83 c0 0c             	add    $0xc,%eax
80101b3c:	83 ec 0c             	sub    $0xc,%esp
80101b3f:	50                   	push   %eax
80101b40:	e8 e8 2a 00 00       	call   8010462d <releasesleep>
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
80101b5b:	e8 69 2a 00 00       	call   801045c9 <acquiresleep>
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
80101b81:	e8 86 2b 00 00       	call   8010470c <acquire>
80101b86:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b89:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8c:	8b 40 08             	mov    0x8(%eax),%eax
80101b8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b92:	83 ec 0c             	sub    $0xc,%esp
80101b95:	68 60 24 19 80       	push   $0x80192460
80101b9a:	e8 db 2b 00 00       	call   8010477a <release>
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
80101be1:	e8 47 2a 00 00       	call   8010462d <releasesleep>
80101be6:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101be9:	83 ec 0c             	sub    $0xc,%esp
80101bec:	68 60 24 19 80       	push   $0x80192460
80101bf1:	e8 16 2b 00 00       	call   8010470c <acquire>
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
80101c10:	e8 65 2b 00 00       	call   8010477a <release>
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
80101d54:	68 aa a1 10 80       	push   $0x8010a1aa
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
80101ff2:	e8 4a 2a 00 00       	call   80104a41 <memmove>
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
80102142:	e8 fa 28 00 00       	call   80104a41 <memmove>
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
801021c2:	e8 10 29 00 00       	call   80104ad7 <strncmp>
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
801021e2:	68 bd a1 10 80       	push   $0x8010a1bd
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
80102211:	68 cf a1 10 80       	push   $0x8010a1cf
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
801022e6:	68 de a1 10 80       	push   $0x8010a1de
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
80102321:	e8 07 28 00 00       	call   80104b2d <strncpy>
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
8010234d:	68 eb a1 10 80       	push   $0x8010a1eb
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
801023bf:	e8 7d 26 00 00       	call   80104a41 <memmove>
801023c4:	83 c4 10             	add    $0x10,%esp
801023c7:	eb 26                	jmp    801023ef <skipelem+0x91>
  else {
    memmove(name, s, len);
801023c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023cc:	83 ec 04             	sub    $0x4,%esp
801023cf:	50                   	push   %eax
801023d0:	ff 75 f4             	push   -0xc(%ebp)
801023d3:	ff 75 0c             	push   0xc(%ebp)
801023d6:	e8 66 26 00 00       	call   80104a41 <memmove>
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
801025bb:	0f b6 05 44 6d 19 80 	movzbl 0x80196d44,%eax
801025c2:	0f b6 c0             	movzbl %al,%eax
801025c5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801025c8:	74 10                	je     801025da <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801025ca:	83 ec 0c             	sub    $0xc,%esp
801025cd:	68 f4 a1 10 80       	push   $0x8010a1f4
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
80102674:	68 26 a2 10 80       	push   $0x8010a226
80102679:	68 c0 40 19 80       	push   $0x801940c0
8010267e:	e8 67 20 00 00       	call   801046ea <initlock>
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
80102718:	81 7d 08 00 90 19 80 	cmpl   $0x80199000,0x8(%ebp)
8010271f:	72 0f                	jb     80102730 <kfree+0x2a>
80102721:	8b 45 08             	mov    0x8(%ebp),%eax
80102724:	05 00 00 00 80       	add    $0x80000000,%eax
80102729:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
8010272e:	76 0d                	jbe    8010273d <kfree+0x37>
    panic("kfree");
80102730:	83 ec 0c             	sub    $0xc,%esp
80102733:	68 2b a2 10 80       	push   $0x8010a22b
80102738:	e8 6c de ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010273d:	83 ec 04             	sub    $0x4,%esp
80102740:	68 00 10 00 00       	push   $0x1000
80102745:	6a 01                	push   $0x1
80102747:	ff 75 08             	push   0x8(%ebp)
8010274a:	e8 33 22 00 00       	call   80104982 <memset>
8010274f:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102752:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102757:	85 c0                	test   %eax,%eax
80102759:	74 10                	je     8010276b <kfree+0x65>
    acquire(&kmem.lock);
8010275b:	83 ec 0c             	sub    $0xc,%esp
8010275e:	68 c0 40 19 80       	push   $0x801940c0
80102763:	e8 a4 1f 00 00       	call   8010470c <acquire>
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
80102795:	e8 e0 1f 00 00       	call   8010477a <release>
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
801027b7:	e8 50 1f 00 00       	call   8010470c <acquire>
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
801027e8:	e8 8d 1f 00 00       	call   8010477a <release>
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
80102d12:	e8 d2 1c 00 00       	call   801049e9 <memcmp>
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
80102e26:	68 31 a2 10 80       	push   $0x8010a231
80102e2b:	68 20 41 19 80       	push   $0x80194120
80102e30:	e8 b5 18 00 00       	call   801046ea <initlock>
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
80102edb:	e8 61 1b 00 00       	call   80104a41 <memmove>
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
8010304a:	e8 bd 16 00 00       	call   8010470c <acquire>
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
801030bc:	e8 b9 16 00 00       	call   8010477a <release>
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
801030dd:	e8 2a 16 00 00       	call   8010470c <acquire>
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
801030fe:	68 35 a2 10 80       	push   $0x8010a235
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
8010313c:	e8 39 16 00 00       	call   8010477a <release>
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
80103157:	e8 b0 15 00 00       	call   8010470c <acquire>
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
80103181:	e8 f4 15 00 00       	call   8010477a <release>
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
801031fd:	e8 3f 18 00 00       	call   80104a41 <memmove>
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
8010329a:	68 44 a2 10 80       	push   $0x8010a244
8010329f:	e8 05 d3 ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
801032a4:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801032a9:	85 c0                	test   %eax,%eax
801032ab:	7f 0d                	jg     801032ba <log_write+0x45>
    panic("log_write outside of trans");
801032ad:	83 ec 0c             	sub    $0xc,%esp
801032b0:	68 5a a2 10 80       	push   $0x8010a25a
801032b5:	e8 ef d2 ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
801032ba:	83 ec 0c             	sub    $0xc,%esp
801032bd:	68 20 41 19 80       	push   $0x80194120
801032c2:	e8 45 14 00 00       	call   8010470c <acquire>
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
80103340:	e8 35 14 00 00       	call   8010477a <release>
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
80103376:	e8 39 4a 00 00       	call   80107db4 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010337b:	83 ec 08             	sub    $0x8,%esp
8010337e:	68 00 00 40 80       	push   $0x80400000
80103383:	68 00 90 19 80       	push   $0x80199000
80103388:	e8 de f2 ff ff       	call   8010266b <kinit1>
8010338d:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103390:	e8 39 40 00 00       	call   801073ce <kvmalloc>
  mpinit_uefi();
80103395:	e8 e0 47 00 00       	call   80107b7a <mpinit_uefi>
  lapicinit();     // interrupt controller
8010339a:	e8 3c f6 ff ff       	call   801029db <lapicinit>
  seginit();       // segment descriptors
8010339f:	e8 c2 3a 00 00       	call   80106e66 <seginit>
  picinit();    // disable pic
801033a4:	e8 9d 01 00 00       	call   80103546 <picinit>
  ioapicinit();    // another interrupt controller
801033a9:	e8 d8 f1 ff ff       	call   80102586 <ioapicinit>
  consoleinit();   // console hardware
801033ae:	e8 4c d7 ff ff       	call   80100aff <consoleinit>
  uartinit();      // serial port
801033b3:	e8 47 2e 00 00       	call   801061ff <uartinit>
  pinit();         // process table
801033b8:	e8 c2 05 00 00       	call   8010397f <pinit>
  tvinit();        // trap vectors
801033bd:	e8 c7 29 00 00       	call   80105d89 <tvinit>
  binit();         // buffer cache
801033c2:	e8 9f cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033c7:	e8 f3 db ff ff       	call   80100fbf <fileinit>
  ideinit();       // disk 
801033cc:	e8 24 6b 00 00       	call   80109ef5 <ideinit>
  startothers();   // start other processors
801033d1:	e8 8a 00 00 00       	call   80103460 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033d6:	83 ec 08             	sub    $0x8,%esp
801033d9:	68 00 00 00 a0       	push   $0xa0000000
801033de:	68 00 00 40 80       	push   $0x80400000
801033e3:	e8 bc f2 ff ff       	call   801026a4 <kinit2>
801033e8:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033eb:	e8 1d 4c 00 00       	call   8010800d <pci_init>
  arp_scan();
801033f0:	e8 54 59 00 00       	call   80108d49 <arp_scan>
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
80103405:	e8 dc 3f 00 00       	call   801073e6 <switchkvm>
  seginit();
8010340a:	e8 57 3a 00 00       	call   80106e66 <seginit>
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
80103431:	68 75 a2 10 80       	push   $0x8010a275
80103436:	e8 b9 cf ff ff       	call   801003f4 <cprintf>
8010343b:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
8010343e:	e8 bc 2a 00 00       	call   80105eff <idtinit>
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
8010347e:	e8 be 15 00 00       	call   80104a41 <memmove>
80103483:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103486:	c7 45 f4 80 6a 19 80 	movl   $0x80196a80,-0xc(%ebp)
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
80103508:	a1 40 6d 19 80       	mov    0x80196d40,%eax
8010350d:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103513:	05 80 6a 19 80       	add    $0x80196a80,%eax
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
80103607:	68 89 a2 10 80       	push   $0x8010a289
8010360c:	50                   	push   %eax
8010360d:	e8 d8 10 00 00       	call   801046ea <initlock>
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
801036cc:	e8 3b 10 00 00       	call   8010470c <acquire>
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
8010373f:	e8 36 10 00 00       	call   8010477a <release>
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
8010375e:	e8 17 10 00 00       	call   8010477a <release>
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
80103778:	e8 8f 0f 00 00       	call   8010470c <acquire>
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
801037ac:	e8 c9 0f 00 00       	call   8010477a <release>
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
8010385c:	e8 19 0f 00 00       	call   8010477a <release>
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
80103879:	e8 8e 0e 00 00       	call   8010470c <acquire>
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
80103896:	e8 df 0e 00 00       	call   8010477a <release>
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
8010395b:	e8 1a 0e 00 00       	call   8010477a <release>
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
80103988:	68 90 a2 10 80       	push   $0x8010a290
8010398d:	68 00 42 19 80       	push   $0x80194200
80103992:	e8 53 0d 00 00       	call   801046ea <initlock>
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
801039a8:	2d 80 6a 19 80       	sub    $0x80196a80,%eax
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
801039cf:	68 98 a2 10 80       	push   $0x8010a298
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
801039f3:	05 80 6a 19 80       	add    $0x80196a80,%eax
801039f8:	0f b6 00             	movzbl (%eax),%eax
801039fb:	0f b6 c0             	movzbl %al,%eax
801039fe:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103a01:	75 10                	jne    80103a13 <mycpu+0x5b>
      return &cpus[i];
80103a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a06:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103a0c:	05 80 6a 19 80       	add    $0x80196a80,%eax
80103a11:	eb 1b                	jmp    80103a2e <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103a13:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a17:	a1 40 6d 19 80       	mov    0x80196d40,%eax
80103a1c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a1f:	7c c9                	jl     801039ea <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103a21:	83 ec 0c             	sub    $0xc,%esp
80103a24:	68 be a2 10 80       	push   $0x8010a2be
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
80103a36:	e8 3c 0e 00 00       	call   80104877 <pushcli>
  c = mycpu();
80103a3b:	e8 78 ff ff ff       	call   801039b8 <mycpu>
80103a40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a46:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103a4f:	e8 70 0e 00 00       	call   801048c4 <popcli>
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
80103a67:	e8 a0 0c 00 00       	call   8010470c <acquire>
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
80103a82:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80103a86:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
80103a8d:	72 e9                	jb     80103a78 <allocproc+0x1f>
      goto found;
    }

  release(&ptable.lock);
80103a8f:	83 ec 0c             	sub    $0xc,%esp
80103a92:	68 00 42 19 80       	push   $0x80194200
80103a97:	e8 de 0c 00 00       	call   8010477a <release>
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
80103ad0:	e8 a5 0c 00 00       	call   8010477a <release>
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
80103b1d:	ba 43 5d 10 80       	mov    $0x80105d43,%edx
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
80103b42:	e8 3b 0e 00 00       	call   80104982 <memset>
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
80103b6e:	a3 34 62 19 80       	mov    %eax,0x80196234
  if((p->pgdir = setupkvm()) == 0){
80103b73:	e8 6a 37 00 00       	call   801072e2 <setupkvm>
80103b78:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b7b:	89 42 04             	mov    %eax,0x4(%edx)
80103b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b81:	8b 40 04             	mov    0x4(%eax),%eax
80103b84:	85 c0                	test   %eax,%eax
80103b86:	75 0d                	jne    80103b95 <userinit+0x38>
    panic("userinit: out of memory?");
80103b88:	83 ec 0c             	sub    $0xc,%esp
80103b8b:	68 ce a2 10 80       	push   $0x8010a2ce
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
80103baa:	e8 ef 39 00 00       	call   8010759e <inituvm>
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
80103bc9:	e8 b4 0d 00 00       	call   80104982 <memset>
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
80103c43:	68 e7 a2 10 80       	push   $0x8010a2e7
80103c48:	50                   	push   %eax
80103c49:	e8 37 0f 00 00       	call   80104b85 <safestrcpy>
80103c4e:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103c51:	83 ec 0c             	sub    $0xc,%esp
80103c54:	68 f0 a2 10 80       	push   $0x8010a2f0
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
80103c6f:	e8 98 0a 00 00       	call   8010470c <acquire>
80103c74:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c7a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103c81:	83 ec 0c             	sub    $0xc,%esp
80103c84:	68 00 42 19 80       	push   $0x80194200
80103c89:	e8 ec 0a 00 00       	call   8010477a <release>
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
80103cc6:	e8 10 3a 00 00       	call   801076db <allocuvm>
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
80103cfa:	e8 e1 3a 00 00       	call   801077e0 <deallocuvm>
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
80103d20:	e8 da 36 00 00       	call   801073ff <switchuvm>
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
80103d68:	e8 11 3c 00 00       	call   8010797e <copyuvm>
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
80103e62:	e8 1e 0d 00 00       	call   80104b85 <safestrcpy>
80103e67:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103e6a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e6d:	8b 40 10             	mov    0x10(%eax),%eax
80103e70:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103e73:	83 ec 0c             	sub    $0xc,%esp
80103e76:	68 00 42 19 80       	push   $0x80194200
80103e7b:	e8 8c 08 00 00       	call   8010470c <acquire>
80103e80:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80103e83:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e86:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103e8d:	83 ec 0c             	sub    $0xc,%esp
80103e90:	68 00 42 19 80       	push   $0x80194200
80103e95:	e8 e0 08 00 00       	call   8010477a <release>
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
80103eb6:	a1 34 62 19 80       	mov    0x80196234,%eax
80103ebb:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103ebe:	75 0d                	jne    80103ecd <exit+0x25>
    panic("init exiting");
80103ec0:	83 ec 0c             	sub    $0xc,%esp
80103ec3:	68 f2 a2 10 80       	push   $0x8010a2f2
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
80103f49:	e8 be 07 00 00       	call   8010470c <acquire>
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
80103f77:	8b 15 34 62 19 80    	mov    0x80196234,%edx
80103f7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f80:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80103f83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f86:	8b 40 0c             	mov    0xc(%eax),%eax
80103f89:	83 f8 05             	cmp    $0x5,%eax
80103f8c:	75 11                	jne    80103f9f <exit+0xf7>
        wakeup1(initproc);
80103f8e:	a1 34 62 19 80       	mov    0x80196234,%eax
80103f93:	83 ec 0c             	sub    $0xc,%esp
80103f96:	50                   	push   %eax
80103f97:	e8 e4 03 00 00       	call   80104380 <wakeup1>
80103f9c:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f9f:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80103fa3:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
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
80103fbe:	68 ff a2 10 80       	push   $0x8010a2ff
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
80103fde:	e8 29 07 00 00       	call   8010470c <acquire>
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
80104049:	e8 56 38 00 00       	call   801078a4 <freevm>
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
80104088:	e8 ed 06 00 00       	call   8010477a <release>
8010408d:	83 c4 10             	add    $0x10,%esp
        return pid;
80104090:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104093:	eb 51                	jmp    801040e6 <wait+0x11e>
        continue;
80104095:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104096:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
8010409a:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
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
801040bf:	e8 b6 06 00 00       	call   8010477a <release>
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
80104110:	e8 f7 05 00 00       	call   8010470c <acquire>
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
8010413e:	e8 bc 32 00 00       	call   801073ff <switchuvm>
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
80104161:	e8 91 0a 00 00       	call   80104bf7 <swtch>
80104166:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104169:	e8 78 32 00 00       	call   801073e6 <switchkvm>

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
8010417e:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104182:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
80104189:	72 96                	jb     80104121 <scheduler+0x39>
    }
    release(&ptable.lock);
8010418b:	83 ec 0c             	sub    $0xc,%esp
8010418e:	68 00 42 19 80       	push   $0x80194200
80104193:	e8 e2 05 00 00       	call   8010477a <release>
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
801041b6:	e8 8c 06 00 00       	call   80104847 <holding>
801041bb:	83 c4 10             	add    $0x10,%esp
801041be:	85 c0                	test   %eax,%eax
801041c0:	75 0d                	jne    801041cf <sched+0x2f>
    panic("sched ptable.lock");
801041c2:	83 ec 0c             	sub    $0xc,%esp
801041c5:	68 0b a3 10 80       	push   $0x8010a30b
801041ca:	e8 da c3 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
801041cf:	e8 e4 f7 ff ff       	call   801039b8 <mycpu>
801041d4:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801041da:	83 f8 01             	cmp    $0x1,%eax
801041dd:	74 0d                	je     801041ec <sched+0x4c>
    panic("sched locks");
801041df:	83 ec 0c             	sub    $0xc,%esp
801041e2:	68 1d a3 10 80       	push   $0x8010a31d
801041e7:	e8 bd c3 ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
801041ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041ef:	8b 40 0c             	mov    0xc(%eax),%eax
801041f2:	83 f8 04             	cmp    $0x4,%eax
801041f5:	75 0d                	jne    80104204 <sched+0x64>
    panic("sched running");
801041f7:	83 ec 0c             	sub    $0xc,%esp
801041fa:	68 29 a3 10 80       	push   $0x8010a329
801041ff:	e8 a5 c3 ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
80104204:	e8 5f f7 ff ff       	call   80103968 <readeflags>
80104209:	25 00 02 00 00       	and    $0x200,%eax
8010420e:	85 c0                	test   %eax,%eax
80104210:	74 0d                	je     8010421f <sched+0x7f>
    panic("sched interruptible");
80104212:	83 ec 0c             	sub    $0xc,%esp
80104215:	68 37 a3 10 80       	push   $0x8010a337
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
80104240:	e8 b2 09 00 00       	call   80104bf7 <swtch>
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
80104267:	e8 a0 04 00 00       	call   8010470c <acquire>
8010426c:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
8010426f:	e8 bc f7 ff ff       	call   80103a30 <myproc>
80104274:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010427b:	e8 20 ff ff ff       	call   801041a0 <sched>
  release(&ptable.lock);
80104280:	83 ec 0c             	sub    $0xc,%esp
80104283:	68 00 42 19 80       	push   $0x80194200
80104288:	e8 ed 04 00 00       	call   8010477a <release>
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
801042a1:	e8 d4 04 00 00       	call   8010477a <release>
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
801042f0:	68 4b a3 10 80       	push   $0x8010a34b
801042f5:	e8 af c2 ff ff       	call   801005a9 <panic>

  if(lk == 0)
801042fa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801042fe:	75 0d                	jne    8010430d <sleep+0x34>
    panic("sleep without lk");
80104300:	83 ec 0c             	sub    $0xc,%esp
80104303:	68 51 a3 10 80       	push   $0x8010a351
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
8010431e:	e8 e9 03 00 00       	call   8010470c <acquire>
80104323:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104326:	83 ec 0c             	sub    $0xc,%esp
80104329:	ff 75 0c             	push   0xc(%ebp)
8010432c:	e8 49 04 00 00       	call   8010477a <release>
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
80104367:	e8 0e 04 00 00       	call   8010477a <release>
8010436c:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
8010436f:	83 ec 0c             	sub    $0xc,%esp
80104372:	ff 75 0c             	push   0xc(%ebp)
80104375:	e8 92 03 00 00       	call   8010470c <acquire>
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
801043af:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
801043b3:	81 7d fc 34 62 19 80 	cmpl   $0x80196234,-0x4(%ebp)
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
801043ce:	e8 39 03 00 00       	call   8010470c <acquire>
801043d3:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801043d6:	83 ec 0c             	sub    $0xc,%esp
801043d9:	ff 75 08             	push   0x8(%ebp)
801043dc:	e8 9f ff ff ff       	call   80104380 <wakeup1>
801043e1:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801043e4:	83 ec 0c             	sub    $0xc,%esp
801043e7:	68 00 42 19 80       	push   $0x80194200
801043ec:	e8 89 03 00 00       	call   8010477a <release>
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
80104405:	e8 02 03 00 00       	call   8010470c <acquire>
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
80104448:	e8 2d 03 00 00       	call   8010477a <release>
8010444d:	83 c4 10             	add    $0x10,%esp
      return 0;
80104450:	b8 00 00 00 00       	mov    $0x0,%eax
80104455:	eb 22                	jmp    80104479 <kill+0x82>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104457:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
8010445b:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
80104462:	72 b2                	jb     80104416 <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104464:	83 ec 0c             	sub    $0xc,%esp
80104467:	68 00 42 19 80       	push   $0x80194200
8010446c:	e8 09 03 00 00       	call   8010477a <release>
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
801044c9:	c7 45 ec 62 a3 10 80 	movl   $0x8010a362,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801044d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044d3:	8d 50 6c             	lea    0x6c(%eax),%edx
801044d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044d9:	8b 40 10             	mov    0x10(%eax),%eax
801044dc:	52                   	push   %edx
801044dd:	ff 75 ec             	push   -0x14(%ebp)
801044e0:	50                   	push   %eax
801044e1:	68 66 a3 10 80       	push   $0x8010a366
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
8010450f:	e8 b8 02 00 00       	call   801047cc <getcallerpcs>
80104514:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104517:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010451e:	eb 1c                	jmp    8010453c <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104520:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104523:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104527:	83 ec 08             	sub    $0x8,%esp
8010452a:	50                   	push   %eax
8010452b:	68 6f a3 10 80       	push   $0x8010a36f
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
80104550:	68 73 a3 10 80       	push   $0x8010a373
80104555:	e8 9a be ff ff       	call   801003f4 <cprintf>
8010455a:	83 c4 10             	add    $0x10,%esp
8010455d:	eb 01                	jmp    80104560 <procdump+0xe5>
      continue;
8010455f:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104560:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
80104564:	81 7d f0 34 62 19 80 	cmpl   $0x80196234,-0x10(%ebp)
8010456b:	0f 82 1c ff ff ff    	jb     8010448d <procdump+0x12>
  }
}
80104571:	90                   	nop
80104572:	90                   	nop
80104573:	c9                   	leave  
80104574:	c3                   	ret    

80104575 <uthread_init>:

int 
uthread_init(int address)
{
80104575:	55                   	push   %ebp
80104576:	89 e5                	mov    %esp,%ebp
80104578:	83 ec 08             	sub    $0x8,%esp
  myproc()->scheduler = (uint)address;
8010457b:	e8 b0 f4 ff ff       	call   80103a30 <myproc>
80104580:	8b 55 08             	mov    0x8(%ebp),%edx
80104583:	89 50 7c             	mov    %edx,0x7c(%eax)
  return 0;
80104586:	b8 00 00 00 00       	mov    $0x0,%eax
8010458b:	c9                   	leave  
8010458c:	c3                   	ret    

8010458d <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
8010458d:	55                   	push   %ebp
8010458e:	89 e5                	mov    %esp,%ebp
80104590:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104593:	8b 45 08             	mov    0x8(%ebp),%eax
80104596:	83 c0 04             	add    $0x4,%eax
80104599:	83 ec 08             	sub    $0x8,%esp
8010459c:	68 9f a3 10 80       	push   $0x8010a39f
801045a1:	50                   	push   %eax
801045a2:	e8 43 01 00 00       	call   801046ea <initlock>
801045a7:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
801045aa:	8b 45 08             	mov    0x8(%ebp),%eax
801045ad:	8b 55 0c             	mov    0xc(%ebp),%edx
801045b0:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
801045b3:	8b 45 08             	mov    0x8(%ebp),%eax
801045b6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801045bc:	8b 45 08             	mov    0x8(%ebp),%eax
801045bf:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
801045c6:	90                   	nop
801045c7:	c9                   	leave  
801045c8:	c3                   	ret    

801045c9 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801045c9:	55                   	push   %ebp
801045ca:	89 e5                	mov    %esp,%ebp
801045cc:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801045cf:	8b 45 08             	mov    0x8(%ebp),%eax
801045d2:	83 c0 04             	add    $0x4,%eax
801045d5:	83 ec 0c             	sub    $0xc,%esp
801045d8:	50                   	push   %eax
801045d9:	e8 2e 01 00 00       	call   8010470c <acquire>
801045de:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801045e1:	eb 15                	jmp    801045f8 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
801045e3:	8b 45 08             	mov    0x8(%ebp),%eax
801045e6:	83 c0 04             	add    $0x4,%eax
801045e9:	83 ec 08             	sub    $0x8,%esp
801045ec:	50                   	push   %eax
801045ed:	ff 75 08             	push   0x8(%ebp)
801045f0:	e8 e4 fc ff ff       	call   801042d9 <sleep>
801045f5:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801045f8:	8b 45 08             	mov    0x8(%ebp),%eax
801045fb:	8b 00                	mov    (%eax),%eax
801045fd:	85 c0                	test   %eax,%eax
801045ff:	75 e2                	jne    801045e3 <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104601:	8b 45 08             	mov    0x8(%ebp),%eax
80104604:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
8010460a:	e8 21 f4 ff ff       	call   80103a30 <myproc>
8010460f:	8b 50 10             	mov    0x10(%eax),%edx
80104612:	8b 45 08             	mov    0x8(%ebp),%eax
80104615:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104618:	8b 45 08             	mov    0x8(%ebp),%eax
8010461b:	83 c0 04             	add    $0x4,%eax
8010461e:	83 ec 0c             	sub    $0xc,%esp
80104621:	50                   	push   %eax
80104622:	e8 53 01 00 00       	call   8010477a <release>
80104627:	83 c4 10             	add    $0x10,%esp
}
8010462a:	90                   	nop
8010462b:	c9                   	leave  
8010462c:	c3                   	ret    

8010462d <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
8010462d:	55                   	push   %ebp
8010462e:	89 e5                	mov    %esp,%ebp
80104630:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104633:	8b 45 08             	mov    0x8(%ebp),%eax
80104636:	83 c0 04             	add    $0x4,%eax
80104639:	83 ec 0c             	sub    $0xc,%esp
8010463c:	50                   	push   %eax
8010463d:	e8 ca 00 00 00       	call   8010470c <acquire>
80104642:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104645:	8b 45 08             	mov    0x8(%ebp),%eax
80104648:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010464e:	8b 45 08             	mov    0x8(%ebp),%eax
80104651:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104658:	83 ec 0c             	sub    $0xc,%esp
8010465b:	ff 75 08             	push   0x8(%ebp)
8010465e:	e8 5d fd ff ff       	call   801043c0 <wakeup>
80104663:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104666:	8b 45 08             	mov    0x8(%ebp),%eax
80104669:	83 c0 04             	add    $0x4,%eax
8010466c:	83 ec 0c             	sub    $0xc,%esp
8010466f:	50                   	push   %eax
80104670:	e8 05 01 00 00       	call   8010477a <release>
80104675:	83 c4 10             	add    $0x10,%esp
}
80104678:	90                   	nop
80104679:	c9                   	leave  
8010467a:	c3                   	ret    

8010467b <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
8010467b:	55                   	push   %ebp
8010467c:	89 e5                	mov    %esp,%ebp
8010467e:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104681:	8b 45 08             	mov    0x8(%ebp),%eax
80104684:	83 c0 04             	add    $0x4,%eax
80104687:	83 ec 0c             	sub    $0xc,%esp
8010468a:	50                   	push   %eax
8010468b:	e8 7c 00 00 00       	call   8010470c <acquire>
80104690:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104693:	8b 45 08             	mov    0x8(%ebp),%eax
80104696:	8b 00                	mov    (%eax),%eax
80104698:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
8010469b:	8b 45 08             	mov    0x8(%ebp),%eax
8010469e:	83 c0 04             	add    $0x4,%eax
801046a1:	83 ec 0c             	sub    $0xc,%esp
801046a4:	50                   	push   %eax
801046a5:	e8 d0 00 00 00       	call   8010477a <release>
801046aa:	83 c4 10             	add    $0x10,%esp
  return r;
801046ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801046b0:	c9                   	leave  
801046b1:	c3                   	ret    

801046b2 <readeflags>:
{
801046b2:	55                   	push   %ebp
801046b3:	89 e5                	mov    %esp,%ebp
801046b5:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801046b8:	9c                   	pushf  
801046b9:	58                   	pop    %eax
801046ba:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801046bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801046c0:	c9                   	leave  
801046c1:	c3                   	ret    

801046c2 <cli>:
{
801046c2:	55                   	push   %ebp
801046c3:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801046c5:	fa                   	cli    
}
801046c6:	90                   	nop
801046c7:	5d                   	pop    %ebp
801046c8:	c3                   	ret    

801046c9 <sti>:
{
801046c9:	55                   	push   %ebp
801046ca:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801046cc:	fb                   	sti    
}
801046cd:	90                   	nop
801046ce:	5d                   	pop    %ebp
801046cf:	c3                   	ret    

801046d0 <xchg>:
{
801046d0:	55                   	push   %ebp
801046d1:	89 e5                	mov    %esp,%ebp
801046d3:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
801046d6:	8b 55 08             	mov    0x8(%ebp),%edx
801046d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801046dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
801046df:	f0 87 02             	lock xchg %eax,(%edx)
801046e2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
801046e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801046e8:	c9                   	leave  
801046e9:	c3                   	ret    

801046ea <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801046ea:	55                   	push   %ebp
801046eb:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801046ed:	8b 45 08             	mov    0x8(%ebp),%eax
801046f0:	8b 55 0c             	mov    0xc(%ebp),%edx
801046f3:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801046f6:	8b 45 08             	mov    0x8(%ebp),%eax
801046f9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801046ff:	8b 45 08             	mov    0x8(%ebp),%eax
80104702:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104709:	90                   	nop
8010470a:	5d                   	pop    %ebp
8010470b:	c3                   	ret    

8010470c <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010470c:	55                   	push   %ebp
8010470d:	89 e5                	mov    %esp,%ebp
8010470f:	53                   	push   %ebx
80104710:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104713:	e8 5f 01 00 00       	call   80104877 <pushcli>
  if(holding(lk)){
80104718:	8b 45 08             	mov    0x8(%ebp),%eax
8010471b:	83 ec 0c             	sub    $0xc,%esp
8010471e:	50                   	push   %eax
8010471f:	e8 23 01 00 00       	call   80104847 <holding>
80104724:	83 c4 10             	add    $0x10,%esp
80104727:	85 c0                	test   %eax,%eax
80104729:	74 0d                	je     80104738 <acquire+0x2c>
    panic("acquire");
8010472b:	83 ec 0c             	sub    $0xc,%esp
8010472e:	68 aa a3 10 80       	push   $0x8010a3aa
80104733:	e8 71 be ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104738:	90                   	nop
80104739:	8b 45 08             	mov    0x8(%ebp),%eax
8010473c:	83 ec 08             	sub    $0x8,%esp
8010473f:	6a 01                	push   $0x1
80104741:	50                   	push   %eax
80104742:	e8 89 ff ff ff       	call   801046d0 <xchg>
80104747:	83 c4 10             	add    $0x10,%esp
8010474a:	85 c0                	test   %eax,%eax
8010474c:	75 eb                	jne    80104739 <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
8010474e:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104753:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104756:	e8 5d f2 ff ff       	call   801039b8 <mycpu>
8010475b:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
8010475e:	8b 45 08             	mov    0x8(%ebp),%eax
80104761:	83 c0 0c             	add    $0xc,%eax
80104764:	83 ec 08             	sub    $0x8,%esp
80104767:	50                   	push   %eax
80104768:	8d 45 08             	lea    0x8(%ebp),%eax
8010476b:	50                   	push   %eax
8010476c:	e8 5b 00 00 00       	call   801047cc <getcallerpcs>
80104771:	83 c4 10             	add    $0x10,%esp
}
80104774:	90                   	nop
80104775:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104778:	c9                   	leave  
80104779:	c3                   	ret    

8010477a <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
8010477a:	55                   	push   %ebp
8010477b:	89 e5                	mov    %esp,%ebp
8010477d:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104780:	83 ec 0c             	sub    $0xc,%esp
80104783:	ff 75 08             	push   0x8(%ebp)
80104786:	e8 bc 00 00 00       	call   80104847 <holding>
8010478b:	83 c4 10             	add    $0x10,%esp
8010478e:	85 c0                	test   %eax,%eax
80104790:	75 0d                	jne    8010479f <release+0x25>
    panic("release");
80104792:	83 ec 0c             	sub    $0xc,%esp
80104795:	68 b2 a3 10 80       	push   $0x8010a3b2
8010479a:	e8 0a be ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
8010479f:	8b 45 08             	mov    0x8(%ebp),%eax
801047a2:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801047a9:	8b 45 08             	mov    0x8(%ebp),%eax
801047ac:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801047b3:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801047b8:	8b 45 08             	mov    0x8(%ebp),%eax
801047bb:	8b 55 08             	mov    0x8(%ebp),%edx
801047be:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
801047c4:	e8 fb 00 00 00       	call   801048c4 <popcli>
}
801047c9:	90                   	nop
801047ca:	c9                   	leave  
801047cb:	c3                   	ret    

801047cc <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801047cc:	55                   	push   %ebp
801047cd:	89 e5                	mov    %esp,%ebp
801047cf:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801047d2:	8b 45 08             	mov    0x8(%ebp),%eax
801047d5:	83 e8 08             	sub    $0x8,%eax
801047d8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801047db:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801047e2:	eb 38                	jmp    8010481c <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801047e4:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801047e8:	74 53                	je     8010483d <getcallerpcs+0x71>
801047ea:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801047f1:	76 4a                	jbe    8010483d <getcallerpcs+0x71>
801047f3:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801047f7:	74 44                	je     8010483d <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
801047f9:	8b 45 f8             	mov    -0x8(%ebp),%eax
801047fc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104803:	8b 45 0c             	mov    0xc(%ebp),%eax
80104806:	01 c2                	add    %eax,%edx
80104808:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010480b:	8b 40 04             	mov    0x4(%eax),%eax
8010480e:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104810:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104813:	8b 00                	mov    (%eax),%eax
80104815:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104818:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010481c:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104820:	7e c2                	jle    801047e4 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80104822:	eb 19                	jmp    8010483d <getcallerpcs+0x71>
    pcs[i] = 0;
80104824:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104827:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010482e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104831:	01 d0                	add    %edx,%eax
80104833:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104839:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010483d:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104841:	7e e1                	jle    80104824 <getcallerpcs+0x58>
}
80104843:	90                   	nop
80104844:	90                   	nop
80104845:	c9                   	leave  
80104846:	c3                   	ret    

80104847 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104847:	55                   	push   %ebp
80104848:	89 e5                	mov    %esp,%ebp
8010484a:	53                   	push   %ebx
8010484b:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
8010484e:	8b 45 08             	mov    0x8(%ebp),%eax
80104851:	8b 00                	mov    (%eax),%eax
80104853:	85 c0                	test   %eax,%eax
80104855:	74 16                	je     8010486d <holding+0x26>
80104857:	8b 45 08             	mov    0x8(%ebp),%eax
8010485a:	8b 58 08             	mov    0x8(%eax),%ebx
8010485d:	e8 56 f1 ff ff       	call   801039b8 <mycpu>
80104862:	39 c3                	cmp    %eax,%ebx
80104864:	75 07                	jne    8010486d <holding+0x26>
80104866:	b8 01 00 00 00       	mov    $0x1,%eax
8010486b:	eb 05                	jmp    80104872 <holding+0x2b>
8010486d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104872:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104875:	c9                   	leave  
80104876:	c3                   	ret    

80104877 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104877:	55                   	push   %ebp
80104878:	89 e5                	mov    %esp,%ebp
8010487a:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
8010487d:	e8 30 fe ff ff       	call   801046b2 <readeflags>
80104882:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104885:	e8 38 fe ff ff       	call   801046c2 <cli>
  if(mycpu()->ncli == 0)
8010488a:	e8 29 f1 ff ff       	call   801039b8 <mycpu>
8010488f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104895:	85 c0                	test   %eax,%eax
80104897:	75 14                	jne    801048ad <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80104899:	e8 1a f1 ff ff       	call   801039b8 <mycpu>
8010489e:	8b 55 f4             	mov    -0xc(%ebp),%edx
801048a1:	81 e2 00 02 00 00    	and    $0x200,%edx
801048a7:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
801048ad:	e8 06 f1 ff ff       	call   801039b8 <mycpu>
801048b2:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801048b8:	83 c2 01             	add    $0x1,%edx
801048bb:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
801048c1:	90                   	nop
801048c2:	c9                   	leave  
801048c3:	c3                   	ret    

801048c4 <popcli>:

void
popcli(void)
{
801048c4:	55                   	push   %ebp
801048c5:	89 e5                	mov    %esp,%ebp
801048c7:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
801048ca:	e8 e3 fd ff ff       	call   801046b2 <readeflags>
801048cf:	25 00 02 00 00       	and    $0x200,%eax
801048d4:	85 c0                	test   %eax,%eax
801048d6:	74 0d                	je     801048e5 <popcli+0x21>
    panic("popcli - interruptible");
801048d8:	83 ec 0c             	sub    $0xc,%esp
801048db:	68 ba a3 10 80       	push   $0x8010a3ba
801048e0:	e8 c4 bc ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
801048e5:	e8 ce f0 ff ff       	call   801039b8 <mycpu>
801048ea:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801048f0:	83 ea 01             	sub    $0x1,%edx
801048f3:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
801048f9:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801048ff:	85 c0                	test   %eax,%eax
80104901:	79 0d                	jns    80104910 <popcli+0x4c>
    panic("popcli");
80104903:	83 ec 0c             	sub    $0xc,%esp
80104906:	68 d1 a3 10 80       	push   $0x8010a3d1
8010490b:	e8 99 bc ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104910:	e8 a3 f0 ff ff       	call   801039b8 <mycpu>
80104915:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010491b:	85 c0                	test   %eax,%eax
8010491d:	75 14                	jne    80104933 <popcli+0x6f>
8010491f:	e8 94 f0 ff ff       	call   801039b8 <mycpu>
80104924:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010492a:	85 c0                	test   %eax,%eax
8010492c:	74 05                	je     80104933 <popcli+0x6f>
    sti();
8010492e:	e8 96 fd ff ff       	call   801046c9 <sti>
}
80104933:	90                   	nop
80104934:	c9                   	leave  
80104935:	c3                   	ret    

80104936 <stosb>:
{
80104936:	55                   	push   %ebp
80104937:	89 e5                	mov    %esp,%ebp
80104939:	57                   	push   %edi
8010493a:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
8010493b:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010493e:	8b 55 10             	mov    0x10(%ebp),%edx
80104941:	8b 45 0c             	mov    0xc(%ebp),%eax
80104944:	89 cb                	mov    %ecx,%ebx
80104946:	89 df                	mov    %ebx,%edi
80104948:	89 d1                	mov    %edx,%ecx
8010494a:	fc                   	cld    
8010494b:	f3 aa                	rep stos %al,%es:(%edi)
8010494d:	89 ca                	mov    %ecx,%edx
8010494f:	89 fb                	mov    %edi,%ebx
80104951:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104954:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104957:	90                   	nop
80104958:	5b                   	pop    %ebx
80104959:	5f                   	pop    %edi
8010495a:	5d                   	pop    %ebp
8010495b:	c3                   	ret    

8010495c <stosl>:
{
8010495c:	55                   	push   %ebp
8010495d:	89 e5                	mov    %esp,%ebp
8010495f:	57                   	push   %edi
80104960:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104961:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104964:	8b 55 10             	mov    0x10(%ebp),%edx
80104967:	8b 45 0c             	mov    0xc(%ebp),%eax
8010496a:	89 cb                	mov    %ecx,%ebx
8010496c:	89 df                	mov    %ebx,%edi
8010496e:	89 d1                	mov    %edx,%ecx
80104970:	fc                   	cld    
80104971:	f3 ab                	rep stos %eax,%es:(%edi)
80104973:	89 ca                	mov    %ecx,%edx
80104975:	89 fb                	mov    %edi,%ebx
80104977:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010497a:	89 55 10             	mov    %edx,0x10(%ebp)
}
8010497d:	90                   	nop
8010497e:	5b                   	pop    %ebx
8010497f:	5f                   	pop    %edi
80104980:	5d                   	pop    %ebp
80104981:	c3                   	ret    

80104982 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104982:	55                   	push   %ebp
80104983:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104985:	8b 45 08             	mov    0x8(%ebp),%eax
80104988:	83 e0 03             	and    $0x3,%eax
8010498b:	85 c0                	test   %eax,%eax
8010498d:	75 43                	jne    801049d2 <memset+0x50>
8010498f:	8b 45 10             	mov    0x10(%ebp),%eax
80104992:	83 e0 03             	and    $0x3,%eax
80104995:	85 c0                	test   %eax,%eax
80104997:	75 39                	jne    801049d2 <memset+0x50>
    c &= 0xFF;
80104999:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801049a0:	8b 45 10             	mov    0x10(%ebp),%eax
801049a3:	c1 e8 02             	shr    $0x2,%eax
801049a6:	89 c2                	mov    %eax,%edx
801049a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801049ab:	c1 e0 18             	shl    $0x18,%eax
801049ae:	89 c1                	mov    %eax,%ecx
801049b0:	8b 45 0c             	mov    0xc(%ebp),%eax
801049b3:	c1 e0 10             	shl    $0x10,%eax
801049b6:	09 c1                	or     %eax,%ecx
801049b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801049bb:	c1 e0 08             	shl    $0x8,%eax
801049be:	09 c8                	or     %ecx,%eax
801049c0:	0b 45 0c             	or     0xc(%ebp),%eax
801049c3:	52                   	push   %edx
801049c4:	50                   	push   %eax
801049c5:	ff 75 08             	push   0x8(%ebp)
801049c8:	e8 8f ff ff ff       	call   8010495c <stosl>
801049cd:	83 c4 0c             	add    $0xc,%esp
801049d0:	eb 12                	jmp    801049e4 <memset+0x62>
  } else
    stosb(dst, c, n);
801049d2:	8b 45 10             	mov    0x10(%ebp),%eax
801049d5:	50                   	push   %eax
801049d6:	ff 75 0c             	push   0xc(%ebp)
801049d9:	ff 75 08             	push   0x8(%ebp)
801049dc:	e8 55 ff ff ff       	call   80104936 <stosb>
801049e1:	83 c4 0c             	add    $0xc,%esp
  return dst;
801049e4:	8b 45 08             	mov    0x8(%ebp),%eax
}
801049e7:	c9                   	leave  
801049e8:	c3                   	ret    

801049e9 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801049e9:	55                   	push   %ebp
801049ea:	89 e5                	mov    %esp,%ebp
801049ec:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
801049ef:	8b 45 08             	mov    0x8(%ebp),%eax
801049f2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801049f5:	8b 45 0c             	mov    0xc(%ebp),%eax
801049f8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801049fb:	eb 30                	jmp    80104a2d <memcmp+0x44>
    if(*s1 != *s2)
801049fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a00:	0f b6 10             	movzbl (%eax),%edx
80104a03:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104a06:	0f b6 00             	movzbl (%eax),%eax
80104a09:	38 c2                	cmp    %al,%dl
80104a0b:	74 18                	je     80104a25 <memcmp+0x3c>
      return *s1 - *s2;
80104a0d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a10:	0f b6 00             	movzbl (%eax),%eax
80104a13:	0f b6 d0             	movzbl %al,%edx
80104a16:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104a19:	0f b6 00             	movzbl (%eax),%eax
80104a1c:	0f b6 c8             	movzbl %al,%ecx
80104a1f:	89 d0                	mov    %edx,%eax
80104a21:	29 c8                	sub    %ecx,%eax
80104a23:	eb 1a                	jmp    80104a3f <memcmp+0x56>
    s1++, s2++;
80104a25:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104a29:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104a2d:	8b 45 10             	mov    0x10(%ebp),%eax
80104a30:	8d 50 ff             	lea    -0x1(%eax),%edx
80104a33:	89 55 10             	mov    %edx,0x10(%ebp)
80104a36:	85 c0                	test   %eax,%eax
80104a38:	75 c3                	jne    801049fd <memcmp+0x14>
  }

  return 0;
80104a3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a3f:	c9                   	leave  
80104a40:	c3                   	ret    

80104a41 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104a41:	55                   	push   %ebp
80104a42:	89 e5                	mov    %esp,%ebp
80104a44:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104a47:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a4a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104a4d:	8b 45 08             	mov    0x8(%ebp),%eax
80104a50:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104a53:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a56:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104a59:	73 54                	jae    80104aaf <memmove+0x6e>
80104a5b:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104a5e:	8b 45 10             	mov    0x10(%ebp),%eax
80104a61:	01 d0                	add    %edx,%eax
80104a63:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104a66:	73 47                	jae    80104aaf <memmove+0x6e>
    s += n;
80104a68:	8b 45 10             	mov    0x10(%ebp),%eax
80104a6b:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104a6e:	8b 45 10             	mov    0x10(%ebp),%eax
80104a71:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104a74:	eb 13                	jmp    80104a89 <memmove+0x48>
      *--d = *--s;
80104a76:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104a7a:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104a7e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a81:	0f b6 10             	movzbl (%eax),%edx
80104a84:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104a87:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104a89:	8b 45 10             	mov    0x10(%ebp),%eax
80104a8c:	8d 50 ff             	lea    -0x1(%eax),%edx
80104a8f:	89 55 10             	mov    %edx,0x10(%ebp)
80104a92:	85 c0                	test   %eax,%eax
80104a94:	75 e0                	jne    80104a76 <memmove+0x35>
  if(s < d && s + n > d){
80104a96:	eb 24                	jmp    80104abc <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104a98:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104a9b:	8d 42 01             	lea    0x1(%edx),%eax
80104a9e:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104aa1:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104aa4:	8d 48 01             	lea    0x1(%eax),%ecx
80104aa7:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104aaa:	0f b6 12             	movzbl (%edx),%edx
80104aad:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104aaf:	8b 45 10             	mov    0x10(%ebp),%eax
80104ab2:	8d 50 ff             	lea    -0x1(%eax),%edx
80104ab5:	89 55 10             	mov    %edx,0x10(%ebp)
80104ab8:	85 c0                	test   %eax,%eax
80104aba:	75 dc                	jne    80104a98 <memmove+0x57>

  return dst;
80104abc:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104abf:	c9                   	leave  
80104ac0:	c3                   	ret    

80104ac1 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104ac1:	55                   	push   %ebp
80104ac2:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104ac4:	ff 75 10             	push   0x10(%ebp)
80104ac7:	ff 75 0c             	push   0xc(%ebp)
80104aca:	ff 75 08             	push   0x8(%ebp)
80104acd:	e8 6f ff ff ff       	call   80104a41 <memmove>
80104ad2:	83 c4 0c             	add    $0xc,%esp
}
80104ad5:	c9                   	leave  
80104ad6:	c3                   	ret    

80104ad7 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104ad7:	55                   	push   %ebp
80104ad8:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104ada:	eb 0c                	jmp    80104ae8 <strncmp+0x11>
    n--, p++, q++;
80104adc:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104ae0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104ae4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104ae8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104aec:	74 1a                	je     80104b08 <strncmp+0x31>
80104aee:	8b 45 08             	mov    0x8(%ebp),%eax
80104af1:	0f b6 00             	movzbl (%eax),%eax
80104af4:	84 c0                	test   %al,%al
80104af6:	74 10                	je     80104b08 <strncmp+0x31>
80104af8:	8b 45 08             	mov    0x8(%ebp),%eax
80104afb:	0f b6 10             	movzbl (%eax),%edx
80104afe:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b01:	0f b6 00             	movzbl (%eax),%eax
80104b04:	38 c2                	cmp    %al,%dl
80104b06:	74 d4                	je     80104adc <strncmp+0x5>
  if(n == 0)
80104b08:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104b0c:	75 07                	jne    80104b15 <strncmp+0x3e>
    return 0;
80104b0e:	b8 00 00 00 00       	mov    $0x0,%eax
80104b13:	eb 16                	jmp    80104b2b <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80104b15:	8b 45 08             	mov    0x8(%ebp),%eax
80104b18:	0f b6 00             	movzbl (%eax),%eax
80104b1b:	0f b6 d0             	movzbl %al,%edx
80104b1e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b21:	0f b6 00             	movzbl (%eax),%eax
80104b24:	0f b6 c8             	movzbl %al,%ecx
80104b27:	89 d0                	mov    %edx,%eax
80104b29:	29 c8                	sub    %ecx,%eax
}
80104b2b:	5d                   	pop    %ebp
80104b2c:	c3                   	ret    

80104b2d <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104b2d:	55                   	push   %ebp
80104b2e:	89 e5                	mov    %esp,%ebp
80104b30:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104b33:	8b 45 08             	mov    0x8(%ebp),%eax
80104b36:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104b39:	90                   	nop
80104b3a:	8b 45 10             	mov    0x10(%ebp),%eax
80104b3d:	8d 50 ff             	lea    -0x1(%eax),%edx
80104b40:	89 55 10             	mov    %edx,0x10(%ebp)
80104b43:	85 c0                	test   %eax,%eax
80104b45:	7e 2c                	jle    80104b73 <strncpy+0x46>
80104b47:	8b 55 0c             	mov    0xc(%ebp),%edx
80104b4a:	8d 42 01             	lea    0x1(%edx),%eax
80104b4d:	89 45 0c             	mov    %eax,0xc(%ebp)
80104b50:	8b 45 08             	mov    0x8(%ebp),%eax
80104b53:	8d 48 01             	lea    0x1(%eax),%ecx
80104b56:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104b59:	0f b6 12             	movzbl (%edx),%edx
80104b5c:	88 10                	mov    %dl,(%eax)
80104b5e:	0f b6 00             	movzbl (%eax),%eax
80104b61:	84 c0                	test   %al,%al
80104b63:	75 d5                	jne    80104b3a <strncpy+0xd>
    ;
  while(n-- > 0)
80104b65:	eb 0c                	jmp    80104b73 <strncpy+0x46>
    *s++ = 0;
80104b67:	8b 45 08             	mov    0x8(%ebp),%eax
80104b6a:	8d 50 01             	lea    0x1(%eax),%edx
80104b6d:	89 55 08             	mov    %edx,0x8(%ebp)
80104b70:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104b73:	8b 45 10             	mov    0x10(%ebp),%eax
80104b76:	8d 50 ff             	lea    -0x1(%eax),%edx
80104b79:	89 55 10             	mov    %edx,0x10(%ebp)
80104b7c:	85 c0                	test   %eax,%eax
80104b7e:	7f e7                	jg     80104b67 <strncpy+0x3a>
  return os;
80104b80:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104b83:	c9                   	leave  
80104b84:	c3                   	ret    

80104b85 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104b85:	55                   	push   %ebp
80104b86:	89 e5                	mov    %esp,%ebp
80104b88:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104b8b:	8b 45 08             	mov    0x8(%ebp),%eax
80104b8e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104b91:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104b95:	7f 05                	jg     80104b9c <safestrcpy+0x17>
    return os;
80104b97:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b9a:	eb 32                	jmp    80104bce <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80104b9c:	90                   	nop
80104b9d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104ba1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104ba5:	7e 1e                	jle    80104bc5 <safestrcpy+0x40>
80104ba7:	8b 55 0c             	mov    0xc(%ebp),%edx
80104baa:	8d 42 01             	lea    0x1(%edx),%eax
80104bad:	89 45 0c             	mov    %eax,0xc(%ebp)
80104bb0:	8b 45 08             	mov    0x8(%ebp),%eax
80104bb3:	8d 48 01             	lea    0x1(%eax),%ecx
80104bb6:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104bb9:	0f b6 12             	movzbl (%edx),%edx
80104bbc:	88 10                	mov    %dl,(%eax)
80104bbe:	0f b6 00             	movzbl (%eax),%eax
80104bc1:	84 c0                	test   %al,%al
80104bc3:	75 d8                	jne    80104b9d <safestrcpy+0x18>
    ;
  *s = 0;
80104bc5:	8b 45 08             	mov    0x8(%ebp),%eax
80104bc8:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104bcb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104bce:	c9                   	leave  
80104bcf:	c3                   	ret    

80104bd0 <strlen>:

int
strlen(const char *s)
{
80104bd0:	55                   	push   %ebp
80104bd1:	89 e5                	mov    %esp,%ebp
80104bd3:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104bd6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104bdd:	eb 04                	jmp    80104be3 <strlen+0x13>
80104bdf:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104be3:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104be6:	8b 45 08             	mov    0x8(%ebp),%eax
80104be9:	01 d0                	add    %edx,%eax
80104beb:	0f b6 00             	movzbl (%eax),%eax
80104bee:	84 c0                	test   %al,%al
80104bf0:	75 ed                	jne    80104bdf <strlen+0xf>
    ;
  return n;
80104bf2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104bf5:	c9                   	leave  
80104bf6:	c3                   	ret    

80104bf7 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104bf7:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104bfb:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104bff:	55                   	push   %ebp
  pushl %ebx
80104c00:	53                   	push   %ebx
  pushl %esi
80104c01:	56                   	push   %esi
  pushl %edi
80104c02:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104c03:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104c05:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104c07:	5f                   	pop    %edi
  popl %esi
80104c08:	5e                   	pop    %esi
  popl %ebx
80104c09:	5b                   	pop    %ebx
  popl %ebp
80104c0a:	5d                   	pop    %ebp
  ret
80104c0b:	c3                   	ret    

80104c0c <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104c0c:	55                   	push   %ebp
80104c0d:	89 e5                	mov    %esp,%ebp
80104c0f:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104c12:	e8 19 ee ff ff       	call   80103a30 <myproc>
80104c17:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104c1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c1d:	8b 00                	mov    (%eax),%eax
80104c1f:	39 45 08             	cmp    %eax,0x8(%ebp)
80104c22:	73 0f                	jae    80104c33 <fetchint+0x27>
80104c24:	8b 45 08             	mov    0x8(%ebp),%eax
80104c27:	8d 50 04             	lea    0x4(%eax),%edx
80104c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c2d:	8b 00                	mov    (%eax),%eax
80104c2f:	39 c2                	cmp    %eax,%edx
80104c31:	76 07                	jbe    80104c3a <fetchint+0x2e>
    return -1;
80104c33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c38:	eb 0f                	jmp    80104c49 <fetchint+0x3d>
  *ip = *(int*)(addr);
80104c3a:	8b 45 08             	mov    0x8(%ebp),%eax
80104c3d:	8b 10                	mov    (%eax),%edx
80104c3f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c42:	89 10                	mov    %edx,(%eax)
  return 0;
80104c44:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c49:	c9                   	leave  
80104c4a:	c3                   	ret    

80104c4b <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104c4b:	55                   	push   %ebp
80104c4c:	89 e5                	mov    %esp,%ebp
80104c4e:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80104c51:	e8 da ed ff ff       	call   80103a30 <myproc>
80104c56:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80104c59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c5c:	8b 00                	mov    (%eax),%eax
80104c5e:	39 45 08             	cmp    %eax,0x8(%ebp)
80104c61:	72 07                	jb     80104c6a <fetchstr+0x1f>
    return -1;
80104c63:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c68:	eb 41                	jmp    80104cab <fetchstr+0x60>
  *pp = (char*)addr;
80104c6a:	8b 55 08             	mov    0x8(%ebp),%edx
80104c6d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c70:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80104c72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c75:	8b 00                	mov    (%eax),%eax
80104c77:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80104c7a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c7d:	8b 00                	mov    (%eax),%eax
80104c7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104c82:	eb 1a                	jmp    80104c9e <fetchstr+0x53>
    if(*s == 0)
80104c84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c87:	0f b6 00             	movzbl (%eax),%eax
80104c8a:	84 c0                	test   %al,%al
80104c8c:	75 0c                	jne    80104c9a <fetchstr+0x4f>
      return s - *pp;
80104c8e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c91:	8b 10                	mov    (%eax),%edx
80104c93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c96:	29 d0                	sub    %edx,%eax
80104c98:	eb 11                	jmp    80104cab <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
80104c9a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104c9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ca1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104ca4:	72 de                	jb     80104c84 <fetchstr+0x39>
  }
  return -1;
80104ca6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104cab:	c9                   	leave  
80104cac:	c3                   	ret    

80104cad <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104cad:	55                   	push   %ebp
80104cae:	89 e5                	mov    %esp,%ebp
80104cb0:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104cb3:	e8 78 ed ff ff       	call   80103a30 <myproc>
80104cb8:	8b 40 18             	mov    0x18(%eax),%eax
80104cbb:	8b 50 44             	mov    0x44(%eax),%edx
80104cbe:	8b 45 08             	mov    0x8(%ebp),%eax
80104cc1:	c1 e0 02             	shl    $0x2,%eax
80104cc4:	01 d0                	add    %edx,%eax
80104cc6:	83 c0 04             	add    $0x4,%eax
80104cc9:	83 ec 08             	sub    $0x8,%esp
80104ccc:	ff 75 0c             	push   0xc(%ebp)
80104ccf:	50                   	push   %eax
80104cd0:	e8 37 ff ff ff       	call   80104c0c <fetchint>
80104cd5:	83 c4 10             	add    $0x10,%esp
}
80104cd8:	c9                   	leave  
80104cd9:	c3                   	ret    

80104cda <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104cda:	55                   	push   %ebp
80104cdb:	89 e5                	mov    %esp,%ebp
80104cdd:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80104ce0:	e8 4b ed ff ff       	call   80103a30 <myproc>
80104ce5:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80104ce8:	83 ec 08             	sub    $0x8,%esp
80104ceb:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104cee:	50                   	push   %eax
80104cef:	ff 75 08             	push   0x8(%ebp)
80104cf2:	e8 b6 ff ff ff       	call   80104cad <argint>
80104cf7:	83 c4 10             	add    $0x10,%esp
80104cfa:	85 c0                	test   %eax,%eax
80104cfc:	79 07                	jns    80104d05 <argptr+0x2b>
    return -1;
80104cfe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d03:	eb 3b                	jmp    80104d40 <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104d05:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104d09:	78 1f                	js     80104d2a <argptr+0x50>
80104d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d0e:	8b 00                	mov    (%eax),%eax
80104d10:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d13:	39 d0                	cmp    %edx,%eax
80104d15:	76 13                	jbe    80104d2a <argptr+0x50>
80104d17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d1a:	89 c2                	mov    %eax,%edx
80104d1c:	8b 45 10             	mov    0x10(%ebp),%eax
80104d1f:	01 c2                	add    %eax,%edx
80104d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d24:	8b 00                	mov    (%eax),%eax
80104d26:	39 c2                	cmp    %eax,%edx
80104d28:	76 07                	jbe    80104d31 <argptr+0x57>
    return -1;
80104d2a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d2f:	eb 0f                	jmp    80104d40 <argptr+0x66>
  *pp = (char*)i;
80104d31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d34:	89 c2                	mov    %eax,%edx
80104d36:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d39:	89 10                	mov    %edx,(%eax)
  return 0;
80104d3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d40:	c9                   	leave  
80104d41:	c3                   	ret    

80104d42 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104d42:	55                   	push   %ebp
80104d43:	89 e5                	mov    %esp,%ebp
80104d45:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104d48:	83 ec 08             	sub    $0x8,%esp
80104d4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d4e:	50                   	push   %eax
80104d4f:	ff 75 08             	push   0x8(%ebp)
80104d52:	e8 56 ff ff ff       	call   80104cad <argint>
80104d57:	83 c4 10             	add    $0x10,%esp
80104d5a:	85 c0                	test   %eax,%eax
80104d5c:	79 07                	jns    80104d65 <argstr+0x23>
    return -1;
80104d5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d63:	eb 12                	jmp    80104d77 <argstr+0x35>
  return fetchstr(addr, pp);
80104d65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d68:	83 ec 08             	sub    $0x8,%esp
80104d6b:	ff 75 0c             	push   0xc(%ebp)
80104d6e:	50                   	push   %eax
80104d6f:	e8 d7 fe ff ff       	call   80104c4b <fetchstr>
80104d74:	83 c4 10             	add    $0x10,%esp
}
80104d77:	c9                   	leave  
80104d78:	c3                   	ret    

80104d79 <syscall>:
[SYS_uthread_init]   sys_uthread_init,
};

void
syscall(void)
{
80104d79:	55                   	push   %ebp
80104d7a:	89 e5                	mov    %esp,%ebp
80104d7c:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80104d7f:	e8 ac ec ff ff       	call   80103a30 <myproc>
80104d84:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80104d87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d8a:	8b 40 18             	mov    0x18(%eax),%eax
80104d8d:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d90:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104d93:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104d97:	7e 2f                	jle    80104dc8 <syscall+0x4f>
80104d99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d9c:	83 f8 16             	cmp    $0x16,%eax
80104d9f:	77 27                	ja     80104dc8 <syscall+0x4f>
80104da1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104da4:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104dab:	85 c0                	test   %eax,%eax
80104dad:	74 19                	je     80104dc8 <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80104daf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104db2:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104db9:	ff d0                	call   *%eax
80104dbb:	89 c2                	mov    %eax,%edx
80104dbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dc0:	8b 40 18             	mov    0x18(%eax),%eax
80104dc3:	89 50 1c             	mov    %edx,0x1c(%eax)
80104dc6:	eb 2c                	jmp    80104df4 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80104dc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dcb:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104dce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dd1:	8b 40 10             	mov    0x10(%eax),%eax
80104dd4:	ff 75 f0             	push   -0x10(%ebp)
80104dd7:	52                   	push   %edx
80104dd8:	50                   	push   %eax
80104dd9:	68 d8 a3 10 80       	push   $0x8010a3d8
80104dde:	e8 11 b6 ff ff       	call   801003f4 <cprintf>
80104de3:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80104de6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104de9:	8b 40 18             	mov    0x18(%eax),%eax
80104dec:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80104df3:	90                   	nop
80104df4:	90                   	nop
80104df5:	c9                   	leave  
80104df6:	c3                   	ret    

80104df7 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104df7:	55                   	push   %ebp
80104df8:	89 e5                	mov    %esp,%ebp
80104dfa:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104dfd:	83 ec 08             	sub    $0x8,%esp
80104e00:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104e03:	50                   	push   %eax
80104e04:	ff 75 08             	push   0x8(%ebp)
80104e07:	e8 a1 fe ff ff       	call   80104cad <argint>
80104e0c:	83 c4 10             	add    $0x10,%esp
80104e0f:	85 c0                	test   %eax,%eax
80104e11:	79 07                	jns    80104e1a <argfd+0x23>
    return -1;
80104e13:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e18:	eb 4f                	jmp    80104e69 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104e1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e1d:	85 c0                	test   %eax,%eax
80104e1f:	78 20                	js     80104e41 <argfd+0x4a>
80104e21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e24:	83 f8 0f             	cmp    $0xf,%eax
80104e27:	7f 18                	jg     80104e41 <argfd+0x4a>
80104e29:	e8 02 ec ff ff       	call   80103a30 <myproc>
80104e2e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104e31:	83 c2 08             	add    $0x8,%edx
80104e34:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104e38:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104e3b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104e3f:	75 07                	jne    80104e48 <argfd+0x51>
    return -1;
80104e41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e46:	eb 21                	jmp    80104e69 <argfd+0x72>
  if(pfd)
80104e48:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104e4c:	74 08                	je     80104e56 <argfd+0x5f>
    *pfd = fd;
80104e4e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104e51:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e54:	89 10                	mov    %edx,(%eax)
  if(pf)
80104e56:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104e5a:	74 08                	je     80104e64 <argfd+0x6d>
    *pf = f;
80104e5c:	8b 45 10             	mov    0x10(%ebp),%eax
80104e5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e62:	89 10                	mov    %edx,(%eax)
  return 0;
80104e64:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e69:	c9                   	leave  
80104e6a:	c3                   	ret    

80104e6b <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80104e6b:	55                   	push   %ebp
80104e6c:	89 e5                	mov    %esp,%ebp
80104e6e:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80104e71:	e8 ba eb ff ff       	call   80103a30 <myproc>
80104e76:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80104e79:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104e80:	eb 2a                	jmp    80104eac <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80104e82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e85:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e88:	83 c2 08             	add    $0x8,%edx
80104e8b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104e8f:	85 c0                	test   %eax,%eax
80104e91:	75 15                	jne    80104ea8 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80104e93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e96:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e99:	8d 4a 08             	lea    0x8(%edx),%ecx
80104e9c:	8b 55 08             	mov    0x8(%ebp),%edx
80104e9f:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80104ea3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ea6:	eb 0f                	jmp    80104eb7 <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
80104ea8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104eac:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104eb0:	7e d0                	jle    80104e82 <fdalloc+0x17>
    }
  }
  return -1;
80104eb2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104eb7:	c9                   	leave  
80104eb8:	c3                   	ret    

80104eb9 <sys_dup>:

int
sys_dup(void)
{
80104eb9:	55                   	push   %ebp
80104eba:	89 e5                	mov    %esp,%ebp
80104ebc:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80104ebf:	83 ec 04             	sub    $0x4,%esp
80104ec2:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104ec5:	50                   	push   %eax
80104ec6:	6a 00                	push   $0x0
80104ec8:	6a 00                	push   $0x0
80104eca:	e8 28 ff ff ff       	call   80104df7 <argfd>
80104ecf:	83 c4 10             	add    $0x10,%esp
80104ed2:	85 c0                	test   %eax,%eax
80104ed4:	79 07                	jns    80104edd <sys_dup+0x24>
    return -1;
80104ed6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104edb:	eb 31                	jmp    80104f0e <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80104edd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ee0:	83 ec 0c             	sub    $0xc,%esp
80104ee3:	50                   	push   %eax
80104ee4:	e8 82 ff ff ff       	call   80104e6b <fdalloc>
80104ee9:	83 c4 10             	add    $0x10,%esp
80104eec:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104eef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104ef3:	79 07                	jns    80104efc <sys_dup+0x43>
    return -1;
80104ef5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104efa:	eb 12                	jmp    80104f0e <sys_dup+0x55>
  filedup(f);
80104efc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104eff:	83 ec 0c             	sub    $0xc,%esp
80104f02:	50                   	push   %eax
80104f03:	e8 42 c1 ff ff       	call   8010104a <filedup>
80104f08:	83 c4 10             	add    $0x10,%esp
  return fd;
80104f0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104f0e:	c9                   	leave  
80104f0f:	c3                   	ret    

80104f10 <sys_read>:

int
sys_read(void)
{
80104f10:	55                   	push   %ebp
80104f11:	89 e5                	mov    %esp,%ebp
80104f13:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104f16:	83 ec 04             	sub    $0x4,%esp
80104f19:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f1c:	50                   	push   %eax
80104f1d:	6a 00                	push   $0x0
80104f1f:	6a 00                	push   $0x0
80104f21:	e8 d1 fe ff ff       	call   80104df7 <argfd>
80104f26:	83 c4 10             	add    $0x10,%esp
80104f29:	85 c0                	test   %eax,%eax
80104f2b:	78 2e                	js     80104f5b <sys_read+0x4b>
80104f2d:	83 ec 08             	sub    $0x8,%esp
80104f30:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104f33:	50                   	push   %eax
80104f34:	6a 02                	push   $0x2
80104f36:	e8 72 fd ff ff       	call   80104cad <argint>
80104f3b:	83 c4 10             	add    $0x10,%esp
80104f3e:	85 c0                	test   %eax,%eax
80104f40:	78 19                	js     80104f5b <sys_read+0x4b>
80104f42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f45:	83 ec 04             	sub    $0x4,%esp
80104f48:	50                   	push   %eax
80104f49:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104f4c:	50                   	push   %eax
80104f4d:	6a 01                	push   $0x1
80104f4f:	e8 86 fd ff ff       	call   80104cda <argptr>
80104f54:	83 c4 10             	add    $0x10,%esp
80104f57:	85 c0                	test   %eax,%eax
80104f59:	79 07                	jns    80104f62 <sys_read+0x52>
    return -1;
80104f5b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f60:	eb 17                	jmp    80104f79 <sys_read+0x69>
  return fileread(f, p, n);
80104f62:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104f65:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104f68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f6b:	83 ec 04             	sub    $0x4,%esp
80104f6e:	51                   	push   %ecx
80104f6f:	52                   	push   %edx
80104f70:	50                   	push   %eax
80104f71:	e8 64 c2 ff ff       	call   801011da <fileread>
80104f76:	83 c4 10             	add    $0x10,%esp
}
80104f79:	c9                   	leave  
80104f7a:	c3                   	ret    

80104f7b <sys_write>:

int
sys_write(void)
{
80104f7b:	55                   	push   %ebp
80104f7c:	89 e5                	mov    %esp,%ebp
80104f7e:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104f81:	83 ec 04             	sub    $0x4,%esp
80104f84:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f87:	50                   	push   %eax
80104f88:	6a 00                	push   $0x0
80104f8a:	6a 00                	push   $0x0
80104f8c:	e8 66 fe ff ff       	call   80104df7 <argfd>
80104f91:	83 c4 10             	add    $0x10,%esp
80104f94:	85 c0                	test   %eax,%eax
80104f96:	78 2e                	js     80104fc6 <sys_write+0x4b>
80104f98:	83 ec 08             	sub    $0x8,%esp
80104f9b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104f9e:	50                   	push   %eax
80104f9f:	6a 02                	push   $0x2
80104fa1:	e8 07 fd ff ff       	call   80104cad <argint>
80104fa6:	83 c4 10             	add    $0x10,%esp
80104fa9:	85 c0                	test   %eax,%eax
80104fab:	78 19                	js     80104fc6 <sys_write+0x4b>
80104fad:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fb0:	83 ec 04             	sub    $0x4,%esp
80104fb3:	50                   	push   %eax
80104fb4:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104fb7:	50                   	push   %eax
80104fb8:	6a 01                	push   $0x1
80104fba:	e8 1b fd ff ff       	call   80104cda <argptr>
80104fbf:	83 c4 10             	add    $0x10,%esp
80104fc2:	85 c0                	test   %eax,%eax
80104fc4:	79 07                	jns    80104fcd <sys_write+0x52>
    return -1;
80104fc6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fcb:	eb 17                	jmp    80104fe4 <sys_write+0x69>
  return filewrite(f, p, n);
80104fcd:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104fd0:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104fd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fd6:	83 ec 04             	sub    $0x4,%esp
80104fd9:	51                   	push   %ecx
80104fda:	52                   	push   %edx
80104fdb:	50                   	push   %eax
80104fdc:	e8 b1 c2 ff ff       	call   80101292 <filewrite>
80104fe1:	83 c4 10             	add    $0x10,%esp
}
80104fe4:	c9                   	leave  
80104fe5:	c3                   	ret    

80104fe6 <sys_close>:

int
sys_close(void)
{
80104fe6:	55                   	push   %ebp
80104fe7:	89 e5                	mov    %esp,%ebp
80104fe9:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80104fec:	83 ec 04             	sub    $0x4,%esp
80104fef:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104ff2:	50                   	push   %eax
80104ff3:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104ff6:	50                   	push   %eax
80104ff7:	6a 00                	push   $0x0
80104ff9:	e8 f9 fd ff ff       	call   80104df7 <argfd>
80104ffe:	83 c4 10             	add    $0x10,%esp
80105001:	85 c0                	test   %eax,%eax
80105003:	79 07                	jns    8010500c <sys_close+0x26>
    return -1;
80105005:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010500a:	eb 27                	jmp    80105033 <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
8010500c:	e8 1f ea ff ff       	call   80103a30 <myproc>
80105011:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105014:	83 c2 08             	add    $0x8,%edx
80105017:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010501e:	00 
  fileclose(f);
8010501f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105022:	83 ec 0c             	sub    $0xc,%esp
80105025:	50                   	push   %eax
80105026:	e8 70 c0 ff ff       	call   8010109b <fileclose>
8010502b:	83 c4 10             	add    $0x10,%esp
  return 0;
8010502e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105033:	c9                   	leave  
80105034:	c3                   	ret    

80105035 <sys_fstat>:

int
sys_fstat(void)
{
80105035:	55                   	push   %ebp
80105036:	89 e5                	mov    %esp,%ebp
80105038:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010503b:	83 ec 04             	sub    $0x4,%esp
8010503e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105041:	50                   	push   %eax
80105042:	6a 00                	push   $0x0
80105044:	6a 00                	push   $0x0
80105046:	e8 ac fd ff ff       	call   80104df7 <argfd>
8010504b:	83 c4 10             	add    $0x10,%esp
8010504e:	85 c0                	test   %eax,%eax
80105050:	78 17                	js     80105069 <sys_fstat+0x34>
80105052:	83 ec 04             	sub    $0x4,%esp
80105055:	6a 14                	push   $0x14
80105057:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010505a:	50                   	push   %eax
8010505b:	6a 01                	push   $0x1
8010505d:	e8 78 fc ff ff       	call   80104cda <argptr>
80105062:	83 c4 10             	add    $0x10,%esp
80105065:	85 c0                	test   %eax,%eax
80105067:	79 07                	jns    80105070 <sys_fstat+0x3b>
    return -1;
80105069:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010506e:	eb 13                	jmp    80105083 <sys_fstat+0x4e>
  return filestat(f, st);
80105070:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105073:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105076:	83 ec 08             	sub    $0x8,%esp
80105079:	52                   	push   %edx
8010507a:	50                   	push   %eax
8010507b:	e8 03 c1 ff ff       	call   80101183 <filestat>
80105080:	83 c4 10             	add    $0x10,%esp
}
80105083:	c9                   	leave  
80105084:	c3                   	ret    

80105085 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105085:	55                   	push   %ebp
80105086:	89 e5                	mov    %esp,%ebp
80105088:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010508b:	83 ec 08             	sub    $0x8,%esp
8010508e:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105091:	50                   	push   %eax
80105092:	6a 00                	push   $0x0
80105094:	e8 a9 fc ff ff       	call   80104d42 <argstr>
80105099:	83 c4 10             	add    $0x10,%esp
8010509c:	85 c0                	test   %eax,%eax
8010509e:	78 15                	js     801050b5 <sys_link+0x30>
801050a0:	83 ec 08             	sub    $0x8,%esp
801050a3:	8d 45 dc             	lea    -0x24(%ebp),%eax
801050a6:	50                   	push   %eax
801050a7:	6a 01                	push   $0x1
801050a9:	e8 94 fc ff ff       	call   80104d42 <argstr>
801050ae:	83 c4 10             	add    $0x10,%esp
801050b1:	85 c0                	test   %eax,%eax
801050b3:	79 0a                	jns    801050bf <sys_link+0x3a>
    return -1;
801050b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050ba:	e9 68 01 00 00       	jmp    80105227 <sys_link+0x1a2>

  begin_op();
801050bf:	e8 78 df ff ff       	call   8010303c <begin_op>
  if((ip = namei(old)) == 0){
801050c4:	8b 45 d8             	mov    -0x28(%ebp),%eax
801050c7:	83 ec 0c             	sub    $0xc,%esp
801050ca:	50                   	push   %eax
801050cb:	e8 4d d4 ff ff       	call   8010251d <namei>
801050d0:	83 c4 10             	add    $0x10,%esp
801050d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801050d6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801050da:	75 0f                	jne    801050eb <sys_link+0x66>
    end_op();
801050dc:	e8 e7 df ff ff       	call   801030c8 <end_op>
    return -1;
801050e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050e6:	e9 3c 01 00 00       	jmp    80105227 <sys_link+0x1a2>
  }

  ilock(ip);
801050eb:	83 ec 0c             	sub    $0xc,%esp
801050ee:	ff 75 f4             	push   -0xc(%ebp)
801050f1:	e8 f4 c8 ff ff       	call   801019ea <ilock>
801050f6:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801050f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050fc:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105100:	66 83 f8 01          	cmp    $0x1,%ax
80105104:	75 1d                	jne    80105123 <sys_link+0x9e>
    iunlockput(ip);
80105106:	83 ec 0c             	sub    $0xc,%esp
80105109:	ff 75 f4             	push   -0xc(%ebp)
8010510c:	e8 0a cb ff ff       	call   80101c1b <iunlockput>
80105111:	83 c4 10             	add    $0x10,%esp
    end_op();
80105114:	e8 af df ff ff       	call   801030c8 <end_op>
    return -1;
80105119:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010511e:	e9 04 01 00 00       	jmp    80105227 <sys_link+0x1a2>
  }

  ip->nlink++;
80105123:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105126:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010512a:	83 c0 01             	add    $0x1,%eax
8010512d:	89 c2                	mov    %eax,%edx
8010512f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105132:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105136:	83 ec 0c             	sub    $0xc,%esp
80105139:	ff 75 f4             	push   -0xc(%ebp)
8010513c:	e8 cc c6 ff ff       	call   8010180d <iupdate>
80105141:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105144:	83 ec 0c             	sub    $0xc,%esp
80105147:	ff 75 f4             	push   -0xc(%ebp)
8010514a:	e8 ae c9 ff ff       	call   80101afd <iunlock>
8010514f:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105152:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105155:	83 ec 08             	sub    $0x8,%esp
80105158:	8d 55 e2             	lea    -0x1e(%ebp),%edx
8010515b:	52                   	push   %edx
8010515c:	50                   	push   %eax
8010515d:	e8 d7 d3 ff ff       	call   80102539 <nameiparent>
80105162:	83 c4 10             	add    $0x10,%esp
80105165:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105168:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010516c:	74 71                	je     801051df <sys_link+0x15a>
    goto bad;
  ilock(dp);
8010516e:	83 ec 0c             	sub    $0xc,%esp
80105171:	ff 75 f0             	push   -0x10(%ebp)
80105174:	e8 71 c8 ff ff       	call   801019ea <ilock>
80105179:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
8010517c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010517f:	8b 10                	mov    (%eax),%edx
80105181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105184:	8b 00                	mov    (%eax),%eax
80105186:	39 c2                	cmp    %eax,%edx
80105188:	75 1d                	jne    801051a7 <sys_link+0x122>
8010518a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010518d:	8b 40 04             	mov    0x4(%eax),%eax
80105190:	83 ec 04             	sub    $0x4,%esp
80105193:	50                   	push   %eax
80105194:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105197:	50                   	push   %eax
80105198:	ff 75 f0             	push   -0x10(%ebp)
8010519b:	e8 e6 d0 ff ff       	call   80102286 <dirlink>
801051a0:	83 c4 10             	add    $0x10,%esp
801051a3:	85 c0                	test   %eax,%eax
801051a5:	79 10                	jns    801051b7 <sys_link+0x132>
    iunlockput(dp);
801051a7:	83 ec 0c             	sub    $0xc,%esp
801051aa:	ff 75 f0             	push   -0x10(%ebp)
801051ad:	e8 69 ca ff ff       	call   80101c1b <iunlockput>
801051b2:	83 c4 10             	add    $0x10,%esp
    goto bad;
801051b5:	eb 29                	jmp    801051e0 <sys_link+0x15b>
  }
  iunlockput(dp);
801051b7:	83 ec 0c             	sub    $0xc,%esp
801051ba:	ff 75 f0             	push   -0x10(%ebp)
801051bd:	e8 59 ca ff ff       	call   80101c1b <iunlockput>
801051c2:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801051c5:	83 ec 0c             	sub    $0xc,%esp
801051c8:	ff 75 f4             	push   -0xc(%ebp)
801051cb:	e8 7b c9 ff ff       	call   80101b4b <iput>
801051d0:	83 c4 10             	add    $0x10,%esp

  end_op();
801051d3:	e8 f0 de ff ff       	call   801030c8 <end_op>

  return 0;
801051d8:	b8 00 00 00 00       	mov    $0x0,%eax
801051dd:	eb 48                	jmp    80105227 <sys_link+0x1a2>
    goto bad;
801051df:	90                   	nop

bad:
  ilock(ip);
801051e0:	83 ec 0c             	sub    $0xc,%esp
801051e3:	ff 75 f4             	push   -0xc(%ebp)
801051e6:	e8 ff c7 ff ff       	call   801019ea <ilock>
801051eb:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801051ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051f1:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801051f5:	83 e8 01             	sub    $0x1,%eax
801051f8:	89 c2                	mov    %eax,%edx
801051fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051fd:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105201:	83 ec 0c             	sub    $0xc,%esp
80105204:	ff 75 f4             	push   -0xc(%ebp)
80105207:	e8 01 c6 ff ff       	call   8010180d <iupdate>
8010520c:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010520f:	83 ec 0c             	sub    $0xc,%esp
80105212:	ff 75 f4             	push   -0xc(%ebp)
80105215:	e8 01 ca ff ff       	call   80101c1b <iunlockput>
8010521a:	83 c4 10             	add    $0x10,%esp
  end_op();
8010521d:	e8 a6 de ff ff       	call   801030c8 <end_op>
  return -1;
80105222:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105227:	c9                   	leave  
80105228:	c3                   	ret    

80105229 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105229:	55                   	push   %ebp
8010522a:	89 e5                	mov    %esp,%ebp
8010522c:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010522f:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105236:	eb 40                	jmp    80105278 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105238:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010523b:	6a 10                	push   $0x10
8010523d:	50                   	push   %eax
8010523e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105241:	50                   	push   %eax
80105242:	ff 75 08             	push   0x8(%ebp)
80105245:	e8 8c cc ff ff       	call   80101ed6 <readi>
8010524a:	83 c4 10             	add    $0x10,%esp
8010524d:	83 f8 10             	cmp    $0x10,%eax
80105250:	74 0d                	je     8010525f <isdirempty+0x36>
      panic("isdirempty: readi");
80105252:	83 ec 0c             	sub    $0xc,%esp
80105255:	68 f4 a3 10 80       	push   $0x8010a3f4
8010525a:	e8 4a b3 ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
8010525f:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105263:	66 85 c0             	test   %ax,%ax
80105266:	74 07                	je     8010526f <isdirempty+0x46>
      return 0;
80105268:	b8 00 00 00 00       	mov    $0x0,%eax
8010526d:	eb 1b                	jmp    8010528a <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010526f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105272:	83 c0 10             	add    $0x10,%eax
80105275:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105278:	8b 45 08             	mov    0x8(%ebp),%eax
8010527b:	8b 50 58             	mov    0x58(%eax),%edx
8010527e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105281:	39 c2                	cmp    %eax,%edx
80105283:	77 b3                	ja     80105238 <isdirempty+0xf>
  }
  return 1;
80105285:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010528a:	c9                   	leave  
8010528b:	c3                   	ret    

8010528c <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
8010528c:	55                   	push   %ebp
8010528d:	89 e5                	mov    %esp,%ebp
8010528f:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105292:	83 ec 08             	sub    $0x8,%esp
80105295:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105298:	50                   	push   %eax
80105299:	6a 00                	push   $0x0
8010529b:	e8 a2 fa ff ff       	call   80104d42 <argstr>
801052a0:	83 c4 10             	add    $0x10,%esp
801052a3:	85 c0                	test   %eax,%eax
801052a5:	79 0a                	jns    801052b1 <sys_unlink+0x25>
    return -1;
801052a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052ac:	e9 bf 01 00 00       	jmp    80105470 <sys_unlink+0x1e4>

  begin_op();
801052b1:	e8 86 dd ff ff       	call   8010303c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801052b6:	8b 45 cc             	mov    -0x34(%ebp),%eax
801052b9:	83 ec 08             	sub    $0x8,%esp
801052bc:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801052bf:	52                   	push   %edx
801052c0:	50                   	push   %eax
801052c1:	e8 73 d2 ff ff       	call   80102539 <nameiparent>
801052c6:	83 c4 10             	add    $0x10,%esp
801052c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801052cc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801052d0:	75 0f                	jne    801052e1 <sys_unlink+0x55>
    end_op();
801052d2:	e8 f1 dd ff ff       	call   801030c8 <end_op>
    return -1;
801052d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052dc:	e9 8f 01 00 00       	jmp    80105470 <sys_unlink+0x1e4>
  }

  ilock(dp);
801052e1:	83 ec 0c             	sub    $0xc,%esp
801052e4:	ff 75 f4             	push   -0xc(%ebp)
801052e7:	e8 fe c6 ff ff       	call   801019ea <ilock>
801052ec:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801052ef:	83 ec 08             	sub    $0x8,%esp
801052f2:	68 06 a4 10 80       	push   $0x8010a406
801052f7:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801052fa:	50                   	push   %eax
801052fb:	e8 b1 ce ff ff       	call   801021b1 <namecmp>
80105300:	83 c4 10             	add    $0x10,%esp
80105303:	85 c0                	test   %eax,%eax
80105305:	0f 84 49 01 00 00    	je     80105454 <sys_unlink+0x1c8>
8010530b:	83 ec 08             	sub    $0x8,%esp
8010530e:	68 08 a4 10 80       	push   $0x8010a408
80105313:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105316:	50                   	push   %eax
80105317:	e8 95 ce ff ff       	call   801021b1 <namecmp>
8010531c:	83 c4 10             	add    $0x10,%esp
8010531f:	85 c0                	test   %eax,%eax
80105321:	0f 84 2d 01 00 00    	je     80105454 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105327:	83 ec 04             	sub    $0x4,%esp
8010532a:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010532d:	50                   	push   %eax
8010532e:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105331:	50                   	push   %eax
80105332:	ff 75 f4             	push   -0xc(%ebp)
80105335:	e8 92 ce ff ff       	call   801021cc <dirlookup>
8010533a:	83 c4 10             	add    $0x10,%esp
8010533d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105340:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105344:	0f 84 0d 01 00 00    	je     80105457 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
8010534a:	83 ec 0c             	sub    $0xc,%esp
8010534d:	ff 75 f0             	push   -0x10(%ebp)
80105350:	e8 95 c6 ff ff       	call   801019ea <ilock>
80105355:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105358:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010535b:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010535f:	66 85 c0             	test   %ax,%ax
80105362:	7f 0d                	jg     80105371 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105364:	83 ec 0c             	sub    $0xc,%esp
80105367:	68 0b a4 10 80       	push   $0x8010a40b
8010536c:	e8 38 b2 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105371:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105374:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105378:	66 83 f8 01          	cmp    $0x1,%ax
8010537c:	75 25                	jne    801053a3 <sys_unlink+0x117>
8010537e:	83 ec 0c             	sub    $0xc,%esp
80105381:	ff 75 f0             	push   -0x10(%ebp)
80105384:	e8 a0 fe ff ff       	call   80105229 <isdirempty>
80105389:	83 c4 10             	add    $0x10,%esp
8010538c:	85 c0                	test   %eax,%eax
8010538e:	75 13                	jne    801053a3 <sys_unlink+0x117>
    iunlockput(ip);
80105390:	83 ec 0c             	sub    $0xc,%esp
80105393:	ff 75 f0             	push   -0x10(%ebp)
80105396:	e8 80 c8 ff ff       	call   80101c1b <iunlockput>
8010539b:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010539e:	e9 b5 00 00 00       	jmp    80105458 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
801053a3:	83 ec 04             	sub    $0x4,%esp
801053a6:	6a 10                	push   $0x10
801053a8:	6a 00                	push   $0x0
801053aa:	8d 45 e0             	lea    -0x20(%ebp),%eax
801053ad:	50                   	push   %eax
801053ae:	e8 cf f5 ff ff       	call   80104982 <memset>
801053b3:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801053b6:	8b 45 c8             	mov    -0x38(%ebp),%eax
801053b9:	6a 10                	push   $0x10
801053bb:	50                   	push   %eax
801053bc:	8d 45 e0             	lea    -0x20(%ebp),%eax
801053bf:	50                   	push   %eax
801053c0:	ff 75 f4             	push   -0xc(%ebp)
801053c3:	e8 63 cc ff ff       	call   8010202b <writei>
801053c8:	83 c4 10             	add    $0x10,%esp
801053cb:	83 f8 10             	cmp    $0x10,%eax
801053ce:	74 0d                	je     801053dd <sys_unlink+0x151>
    panic("unlink: writei");
801053d0:	83 ec 0c             	sub    $0xc,%esp
801053d3:	68 1d a4 10 80       	push   $0x8010a41d
801053d8:	e8 cc b1 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
801053dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053e0:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801053e4:	66 83 f8 01          	cmp    $0x1,%ax
801053e8:	75 21                	jne    8010540b <sys_unlink+0x17f>
    dp->nlink--;
801053ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053ed:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801053f1:	83 e8 01             	sub    $0x1,%eax
801053f4:	89 c2                	mov    %eax,%edx
801053f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053f9:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801053fd:	83 ec 0c             	sub    $0xc,%esp
80105400:	ff 75 f4             	push   -0xc(%ebp)
80105403:	e8 05 c4 ff ff       	call   8010180d <iupdate>
80105408:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
8010540b:	83 ec 0c             	sub    $0xc,%esp
8010540e:	ff 75 f4             	push   -0xc(%ebp)
80105411:	e8 05 c8 ff ff       	call   80101c1b <iunlockput>
80105416:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105419:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010541c:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105420:	83 e8 01             	sub    $0x1,%eax
80105423:	89 c2                	mov    %eax,%edx
80105425:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105428:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010542c:	83 ec 0c             	sub    $0xc,%esp
8010542f:	ff 75 f0             	push   -0x10(%ebp)
80105432:	e8 d6 c3 ff ff       	call   8010180d <iupdate>
80105437:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010543a:	83 ec 0c             	sub    $0xc,%esp
8010543d:	ff 75 f0             	push   -0x10(%ebp)
80105440:	e8 d6 c7 ff ff       	call   80101c1b <iunlockput>
80105445:	83 c4 10             	add    $0x10,%esp

  end_op();
80105448:	e8 7b dc ff ff       	call   801030c8 <end_op>

  return 0;
8010544d:	b8 00 00 00 00       	mov    $0x0,%eax
80105452:	eb 1c                	jmp    80105470 <sys_unlink+0x1e4>
    goto bad;
80105454:	90                   	nop
80105455:	eb 01                	jmp    80105458 <sys_unlink+0x1cc>
    goto bad;
80105457:	90                   	nop

bad:
  iunlockput(dp);
80105458:	83 ec 0c             	sub    $0xc,%esp
8010545b:	ff 75 f4             	push   -0xc(%ebp)
8010545e:	e8 b8 c7 ff ff       	call   80101c1b <iunlockput>
80105463:	83 c4 10             	add    $0x10,%esp
  end_op();
80105466:	e8 5d dc ff ff       	call   801030c8 <end_op>
  return -1;
8010546b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105470:	c9                   	leave  
80105471:	c3                   	ret    

80105472 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105472:	55                   	push   %ebp
80105473:	89 e5                	mov    %esp,%ebp
80105475:	83 ec 38             	sub    $0x38,%esp
80105478:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010547b:	8b 55 10             	mov    0x10(%ebp),%edx
8010547e:	8b 45 14             	mov    0x14(%ebp),%eax
80105481:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105485:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105489:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010548d:	83 ec 08             	sub    $0x8,%esp
80105490:	8d 45 de             	lea    -0x22(%ebp),%eax
80105493:	50                   	push   %eax
80105494:	ff 75 08             	push   0x8(%ebp)
80105497:	e8 9d d0 ff ff       	call   80102539 <nameiparent>
8010549c:	83 c4 10             	add    $0x10,%esp
8010549f:	89 45 f4             	mov    %eax,-0xc(%ebp)
801054a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801054a6:	75 0a                	jne    801054b2 <create+0x40>
    return 0;
801054a8:	b8 00 00 00 00       	mov    $0x0,%eax
801054ad:	e9 90 01 00 00       	jmp    80105642 <create+0x1d0>
  ilock(dp);
801054b2:	83 ec 0c             	sub    $0xc,%esp
801054b5:	ff 75 f4             	push   -0xc(%ebp)
801054b8:	e8 2d c5 ff ff       	call   801019ea <ilock>
801054bd:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801054c0:	83 ec 04             	sub    $0x4,%esp
801054c3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801054c6:	50                   	push   %eax
801054c7:	8d 45 de             	lea    -0x22(%ebp),%eax
801054ca:	50                   	push   %eax
801054cb:	ff 75 f4             	push   -0xc(%ebp)
801054ce:	e8 f9 cc ff ff       	call   801021cc <dirlookup>
801054d3:	83 c4 10             	add    $0x10,%esp
801054d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801054d9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801054dd:	74 50                	je     8010552f <create+0xbd>
    iunlockput(dp);
801054df:	83 ec 0c             	sub    $0xc,%esp
801054e2:	ff 75 f4             	push   -0xc(%ebp)
801054e5:	e8 31 c7 ff ff       	call   80101c1b <iunlockput>
801054ea:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801054ed:	83 ec 0c             	sub    $0xc,%esp
801054f0:	ff 75 f0             	push   -0x10(%ebp)
801054f3:	e8 f2 c4 ff ff       	call   801019ea <ilock>
801054f8:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
801054fb:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105500:	75 15                	jne    80105517 <create+0xa5>
80105502:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105505:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105509:	66 83 f8 02          	cmp    $0x2,%ax
8010550d:	75 08                	jne    80105517 <create+0xa5>
      return ip;
8010550f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105512:	e9 2b 01 00 00       	jmp    80105642 <create+0x1d0>
    iunlockput(ip);
80105517:	83 ec 0c             	sub    $0xc,%esp
8010551a:	ff 75 f0             	push   -0x10(%ebp)
8010551d:	e8 f9 c6 ff ff       	call   80101c1b <iunlockput>
80105522:	83 c4 10             	add    $0x10,%esp
    return 0;
80105525:	b8 00 00 00 00       	mov    $0x0,%eax
8010552a:	e9 13 01 00 00       	jmp    80105642 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
8010552f:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105533:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105536:	8b 00                	mov    (%eax),%eax
80105538:	83 ec 08             	sub    $0x8,%esp
8010553b:	52                   	push   %edx
8010553c:	50                   	push   %eax
8010553d:	e8 f4 c1 ff ff       	call   80101736 <ialloc>
80105542:	83 c4 10             	add    $0x10,%esp
80105545:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105548:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010554c:	75 0d                	jne    8010555b <create+0xe9>
    panic("create: ialloc");
8010554e:	83 ec 0c             	sub    $0xc,%esp
80105551:	68 2c a4 10 80       	push   $0x8010a42c
80105556:	e8 4e b0 ff ff       	call   801005a9 <panic>

  ilock(ip);
8010555b:	83 ec 0c             	sub    $0xc,%esp
8010555e:	ff 75 f0             	push   -0x10(%ebp)
80105561:	e8 84 c4 ff ff       	call   801019ea <ilock>
80105566:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105569:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010556c:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105570:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105574:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105577:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
8010557b:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
8010557f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105582:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105588:	83 ec 0c             	sub    $0xc,%esp
8010558b:	ff 75 f0             	push   -0x10(%ebp)
8010558e:	e8 7a c2 ff ff       	call   8010180d <iupdate>
80105593:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105596:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010559b:	75 6a                	jne    80105607 <create+0x195>
    dp->nlink++;  // for ".."
8010559d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055a0:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801055a4:	83 c0 01             	add    $0x1,%eax
801055a7:	89 c2                	mov    %eax,%edx
801055a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055ac:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801055b0:	83 ec 0c             	sub    $0xc,%esp
801055b3:	ff 75 f4             	push   -0xc(%ebp)
801055b6:	e8 52 c2 ff ff       	call   8010180d <iupdate>
801055bb:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801055be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055c1:	8b 40 04             	mov    0x4(%eax),%eax
801055c4:	83 ec 04             	sub    $0x4,%esp
801055c7:	50                   	push   %eax
801055c8:	68 06 a4 10 80       	push   $0x8010a406
801055cd:	ff 75 f0             	push   -0x10(%ebp)
801055d0:	e8 b1 cc ff ff       	call   80102286 <dirlink>
801055d5:	83 c4 10             	add    $0x10,%esp
801055d8:	85 c0                	test   %eax,%eax
801055da:	78 1e                	js     801055fa <create+0x188>
801055dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055df:	8b 40 04             	mov    0x4(%eax),%eax
801055e2:	83 ec 04             	sub    $0x4,%esp
801055e5:	50                   	push   %eax
801055e6:	68 08 a4 10 80       	push   $0x8010a408
801055eb:	ff 75 f0             	push   -0x10(%ebp)
801055ee:	e8 93 cc ff ff       	call   80102286 <dirlink>
801055f3:	83 c4 10             	add    $0x10,%esp
801055f6:	85 c0                	test   %eax,%eax
801055f8:	79 0d                	jns    80105607 <create+0x195>
      panic("create dots");
801055fa:	83 ec 0c             	sub    $0xc,%esp
801055fd:	68 3b a4 10 80       	push   $0x8010a43b
80105602:	e8 a2 af ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105607:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010560a:	8b 40 04             	mov    0x4(%eax),%eax
8010560d:	83 ec 04             	sub    $0x4,%esp
80105610:	50                   	push   %eax
80105611:	8d 45 de             	lea    -0x22(%ebp),%eax
80105614:	50                   	push   %eax
80105615:	ff 75 f4             	push   -0xc(%ebp)
80105618:	e8 69 cc ff ff       	call   80102286 <dirlink>
8010561d:	83 c4 10             	add    $0x10,%esp
80105620:	85 c0                	test   %eax,%eax
80105622:	79 0d                	jns    80105631 <create+0x1bf>
    panic("create: dirlink");
80105624:	83 ec 0c             	sub    $0xc,%esp
80105627:	68 47 a4 10 80       	push   $0x8010a447
8010562c:	e8 78 af ff ff       	call   801005a9 <panic>

  iunlockput(dp);
80105631:	83 ec 0c             	sub    $0xc,%esp
80105634:	ff 75 f4             	push   -0xc(%ebp)
80105637:	e8 df c5 ff ff       	call   80101c1b <iunlockput>
8010563c:	83 c4 10             	add    $0x10,%esp

  return ip;
8010563f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105642:	c9                   	leave  
80105643:	c3                   	ret    

80105644 <sys_open>:

int
sys_open(void)
{
80105644:	55                   	push   %ebp
80105645:	89 e5                	mov    %esp,%ebp
80105647:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010564a:	83 ec 08             	sub    $0x8,%esp
8010564d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105650:	50                   	push   %eax
80105651:	6a 00                	push   $0x0
80105653:	e8 ea f6 ff ff       	call   80104d42 <argstr>
80105658:	83 c4 10             	add    $0x10,%esp
8010565b:	85 c0                	test   %eax,%eax
8010565d:	78 15                	js     80105674 <sys_open+0x30>
8010565f:	83 ec 08             	sub    $0x8,%esp
80105662:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105665:	50                   	push   %eax
80105666:	6a 01                	push   $0x1
80105668:	e8 40 f6 ff ff       	call   80104cad <argint>
8010566d:	83 c4 10             	add    $0x10,%esp
80105670:	85 c0                	test   %eax,%eax
80105672:	79 0a                	jns    8010567e <sys_open+0x3a>
    return -1;
80105674:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105679:	e9 61 01 00 00       	jmp    801057df <sys_open+0x19b>

  begin_op();
8010567e:	e8 b9 d9 ff ff       	call   8010303c <begin_op>

  if(omode & O_CREATE){
80105683:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105686:	25 00 02 00 00       	and    $0x200,%eax
8010568b:	85 c0                	test   %eax,%eax
8010568d:	74 2a                	je     801056b9 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
8010568f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105692:	6a 00                	push   $0x0
80105694:	6a 00                	push   $0x0
80105696:	6a 02                	push   $0x2
80105698:	50                   	push   %eax
80105699:	e8 d4 fd ff ff       	call   80105472 <create>
8010569e:	83 c4 10             	add    $0x10,%esp
801056a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801056a4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056a8:	75 75                	jne    8010571f <sys_open+0xdb>
      end_op();
801056aa:	e8 19 da ff ff       	call   801030c8 <end_op>
      return -1;
801056af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056b4:	e9 26 01 00 00       	jmp    801057df <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
801056b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801056bc:	83 ec 0c             	sub    $0xc,%esp
801056bf:	50                   	push   %eax
801056c0:	e8 58 ce ff ff       	call   8010251d <namei>
801056c5:	83 c4 10             	add    $0x10,%esp
801056c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056cb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056cf:	75 0f                	jne    801056e0 <sys_open+0x9c>
      end_op();
801056d1:	e8 f2 d9 ff ff       	call   801030c8 <end_op>
      return -1;
801056d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056db:	e9 ff 00 00 00       	jmp    801057df <sys_open+0x19b>
    }
    ilock(ip);
801056e0:	83 ec 0c             	sub    $0xc,%esp
801056e3:	ff 75 f4             	push   -0xc(%ebp)
801056e6:	e8 ff c2 ff ff       	call   801019ea <ilock>
801056eb:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
801056ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056f1:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801056f5:	66 83 f8 01          	cmp    $0x1,%ax
801056f9:	75 24                	jne    8010571f <sys_open+0xdb>
801056fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801056fe:	85 c0                	test   %eax,%eax
80105700:	74 1d                	je     8010571f <sys_open+0xdb>
      iunlockput(ip);
80105702:	83 ec 0c             	sub    $0xc,%esp
80105705:	ff 75 f4             	push   -0xc(%ebp)
80105708:	e8 0e c5 ff ff       	call   80101c1b <iunlockput>
8010570d:	83 c4 10             	add    $0x10,%esp
      end_op();
80105710:	e8 b3 d9 ff ff       	call   801030c8 <end_op>
      return -1;
80105715:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010571a:	e9 c0 00 00 00       	jmp    801057df <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010571f:	e8 b9 b8 ff ff       	call   80100fdd <filealloc>
80105724:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105727:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010572b:	74 17                	je     80105744 <sys_open+0x100>
8010572d:	83 ec 0c             	sub    $0xc,%esp
80105730:	ff 75 f0             	push   -0x10(%ebp)
80105733:	e8 33 f7 ff ff       	call   80104e6b <fdalloc>
80105738:	83 c4 10             	add    $0x10,%esp
8010573b:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010573e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105742:	79 2e                	jns    80105772 <sys_open+0x12e>
    if(f)
80105744:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105748:	74 0e                	je     80105758 <sys_open+0x114>
      fileclose(f);
8010574a:	83 ec 0c             	sub    $0xc,%esp
8010574d:	ff 75 f0             	push   -0x10(%ebp)
80105750:	e8 46 b9 ff ff       	call   8010109b <fileclose>
80105755:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105758:	83 ec 0c             	sub    $0xc,%esp
8010575b:	ff 75 f4             	push   -0xc(%ebp)
8010575e:	e8 b8 c4 ff ff       	call   80101c1b <iunlockput>
80105763:	83 c4 10             	add    $0x10,%esp
    end_op();
80105766:	e8 5d d9 ff ff       	call   801030c8 <end_op>
    return -1;
8010576b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105770:	eb 6d                	jmp    801057df <sys_open+0x19b>
  }
  iunlock(ip);
80105772:	83 ec 0c             	sub    $0xc,%esp
80105775:	ff 75 f4             	push   -0xc(%ebp)
80105778:	e8 80 c3 ff ff       	call   80101afd <iunlock>
8010577d:	83 c4 10             	add    $0x10,%esp
  end_op();
80105780:	e8 43 d9 ff ff       	call   801030c8 <end_op>

  f->type = FD_INODE;
80105785:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105788:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
8010578e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105791:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105794:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105797:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010579a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801057a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801057a4:	83 e0 01             	and    $0x1,%eax
801057a7:	85 c0                	test   %eax,%eax
801057a9:	0f 94 c0             	sete   %al
801057ac:	89 c2                	mov    %eax,%edx
801057ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057b1:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801057b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801057b7:	83 e0 01             	and    $0x1,%eax
801057ba:	85 c0                	test   %eax,%eax
801057bc:	75 0a                	jne    801057c8 <sys_open+0x184>
801057be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801057c1:	83 e0 02             	and    $0x2,%eax
801057c4:	85 c0                	test   %eax,%eax
801057c6:	74 07                	je     801057cf <sys_open+0x18b>
801057c8:	b8 01 00 00 00       	mov    $0x1,%eax
801057cd:	eb 05                	jmp    801057d4 <sys_open+0x190>
801057cf:	b8 00 00 00 00       	mov    $0x0,%eax
801057d4:	89 c2                	mov    %eax,%edx
801057d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057d9:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801057dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801057df:	c9                   	leave  
801057e0:	c3                   	ret    

801057e1 <sys_mkdir>:

int
sys_mkdir(void)
{
801057e1:	55                   	push   %ebp
801057e2:	89 e5                	mov    %esp,%ebp
801057e4:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801057e7:	e8 50 d8 ff ff       	call   8010303c <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801057ec:	83 ec 08             	sub    $0x8,%esp
801057ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057f2:	50                   	push   %eax
801057f3:	6a 00                	push   $0x0
801057f5:	e8 48 f5 ff ff       	call   80104d42 <argstr>
801057fa:	83 c4 10             	add    $0x10,%esp
801057fd:	85 c0                	test   %eax,%eax
801057ff:	78 1b                	js     8010581c <sys_mkdir+0x3b>
80105801:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105804:	6a 00                	push   $0x0
80105806:	6a 00                	push   $0x0
80105808:	6a 01                	push   $0x1
8010580a:	50                   	push   %eax
8010580b:	e8 62 fc ff ff       	call   80105472 <create>
80105810:	83 c4 10             	add    $0x10,%esp
80105813:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105816:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010581a:	75 0c                	jne    80105828 <sys_mkdir+0x47>
    end_op();
8010581c:	e8 a7 d8 ff ff       	call   801030c8 <end_op>
    return -1;
80105821:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105826:	eb 18                	jmp    80105840 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80105828:	83 ec 0c             	sub    $0xc,%esp
8010582b:	ff 75 f4             	push   -0xc(%ebp)
8010582e:	e8 e8 c3 ff ff       	call   80101c1b <iunlockput>
80105833:	83 c4 10             	add    $0x10,%esp
  end_op();
80105836:	e8 8d d8 ff ff       	call   801030c8 <end_op>
  return 0;
8010583b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105840:	c9                   	leave  
80105841:	c3                   	ret    

80105842 <sys_mknod>:

int
sys_mknod(void)
{
80105842:	55                   	push   %ebp
80105843:	89 e5                	mov    %esp,%ebp
80105845:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105848:	e8 ef d7 ff ff       	call   8010303c <begin_op>
  if((argstr(0, &path)) < 0 ||
8010584d:	83 ec 08             	sub    $0x8,%esp
80105850:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105853:	50                   	push   %eax
80105854:	6a 00                	push   $0x0
80105856:	e8 e7 f4 ff ff       	call   80104d42 <argstr>
8010585b:	83 c4 10             	add    $0x10,%esp
8010585e:	85 c0                	test   %eax,%eax
80105860:	78 4f                	js     801058b1 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80105862:	83 ec 08             	sub    $0x8,%esp
80105865:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105868:	50                   	push   %eax
80105869:	6a 01                	push   $0x1
8010586b:	e8 3d f4 ff ff       	call   80104cad <argint>
80105870:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105873:	85 c0                	test   %eax,%eax
80105875:	78 3a                	js     801058b1 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
80105877:	83 ec 08             	sub    $0x8,%esp
8010587a:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010587d:	50                   	push   %eax
8010587e:	6a 02                	push   $0x2
80105880:	e8 28 f4 ff ff       	call   80104cad <argint>
80105885:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105888:	85 c0                	test   %eax,%eax
8010588a:	78 25                	js     801058b1 <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
8010588c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010588f:	0f bf c8             	movswl %ax,%ecx
80105892:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105895:	0f bf d0             	movswl %ax,%edx
80105898:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010589b:	51                   	push   %ecx
8010589c:	52                   	push   %edx
8010589d:	6a 03                	push   $0x3
8010589f:	50                   	push   %eax
801058a0:	e8 cd fb ff ff       	call   80105472 <create>
801058a5:	83 c4 10             	add    $0x10,%esp
801058a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
801058ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058af:	75 0c                	jne    801058bd <sys_mknod+0x7b>
    end_op();
801058b1:	e8 12 d8 ff ff       	call   801030c8 <end_op>
    return -1;
801058b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058bb:	eb 18                	jmp    801058d5 <sys_mknod+0x93>
  }
  iunlockput(ip);
801058bd:	83 ec 0c             	sub    $0xc,%esp
801058c0:	ff 75 f4             	push   -0xc(%ebp)
801058c3:	e8 53 c3 ff ff       	call   80101c1b <iunlockput>
801058c8:	83 c4 10             	add    $0x10,%esp
  end_op();
801058cb:	e8 f8 d7 ff ff       	call   801030c8 <end_op>
  return 0;
801058d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058d5:	c9                   	leave  
801058d6:	c3                   	ret    

801058d7 <sys_chdir>:

int
sys_chdir(void)
{
801058d7:	55                   	push   %ebp
801058d8:	89 e5                	mov    %esp,%ebp
801058da:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801058dd:	e8 4e e1 ff ff       	call   80103a30 <myproc>
801058e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
801058e5:	e8 52 d7 ff ff       	call   8010303c <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801058ea:	83 ec 08             	sub    $0x8,%esp
801058ed:	8d 45 ec             	lea    -0x14(%ebp),%eax
801058f0:	50                   	push   %eax
801058f1:	6a 00                	push   $0x0
801058f3:	e8 4a f4 ff ff       	call   80104d42 <argstr>
801058f8:	83 c4 10             	add    $0x10,%esp
801058fb:	85 c0                	test   %eax,%eax
801058fd:	78 18                	js     80105917 <sys_chdir+0x40>
801058ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105902:	83 ec 0c             	sub    $0xc,%esp
80105905:	50                   	push   %eax
80105906:	e8 12 cc ff ff       	call   8010251d <namei>
8010590b:	83 c4 10             	add    $0x10,%esp
8010590e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105911:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105915:	75 0c                	jne    80105923 <sys_chdir+0x4c>
    end_op();
80105917:	e8 ac d7 ff ff       	call   801030c8 <end_op>
    return -1;
8010591c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105921:	eb 68                	jmp    8010598b <sys_chdir+0xb4>
  }
  ilock(ip);
80105923:	83 ec 0c             	sub    $0xc,%esp
80105926:	ff 75 f0             	push   -0x10(%ebp)
80105929:	e8 bc c0 ff ff       	call   801019ea <ilock>
8010592e:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105931:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105934:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105938:	66 83 f8 01          	cmp    $0x1,%ax
8010593c:	74 1a                	je     80105958 <sys_chdir+0x81>
    iunlockput(ip);
8010593e:	83 ec 0c             	sub    $0xc,%esp
80105941:	ff 75 f0             	push   -0x10(%ebp)
80105944:	e8 d2 c2 ff ff       	call   80101c1b <iunlockput>
80105949:	83 c4 10             	add    $0x10,%esp
    end_op();
8010594c:	e8 77 d7 ff ff       	call   801030c8 <end_op>
    return -1;
80105951:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105956:	eb 33                	jmp    8010598b <sys_chdir+0xb4>
  }
  iunlock(ip);
80105958:	83 ec 0c             	sub    $0xc,%esp
8010595b:	ff 75 f0             	push   -0x10(%ebp)
8010595e:	e8 9a c1 ff ff       	call   80101afd <iunlock>
80105963:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105966:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105969:	8b 40 68             	mov    0x68(%eax),%eax
8010596c:	83 ec 0c             	sub    $0xc,%esp
8010596f:	50                   	push   %eax
80105970:	e8 d6 c1 ff ff       	call   80101b4b <iput>
80105975:	83 c4 10             	add    $0x10,%esp
  end_op();
80105978:	e8 4b d7 ff ff       	call   801030c8 <end_op>
  curproc->cwd = ip;
8010597d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105980:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105983:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105986:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010598b:	c9                   	leave  
8010598c:	c3                   	ret    

8010598d <sys_exec>:

int
sys_exec(void)
{
8010598d:	55                   	push   %ebp
8010598e:	89 e5                	mov    %esp,%ebp
80105990:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105996:	83 ec 08             	sub    $0x8,%esp
80105999:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010599c:	50                   	push   %eax
8010599d:	6a 00                	push   $0x0
8010599f:	e8 9e f3 ff ff       	call   80104d42 <argstr>
801059a4:	83 c4 10             	add    $0x10,%esp
801059a7:	85 c0                	test   %eax,%eax
801059a9:	78 18                	js     801059c3 <sys_exec+0x36>
801059ab:	83 ec 08             	sub    $0x8,%esp
801059ae:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801059b4:	50                   	push   %eax
801059b5:	6a 01                	push   $0x1
801059b7:	e8 f1 f2 ff ff       	call   80104cad <argint>
801059bc:	83 c4 10             	add    $0x10,%esp
801059bf:	85 c0                	test   %eax,%eax
801059c1:	79 0a                	jns    801059cd <sys_exec+0x40>
    return -1;
801059c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059c8:	e9 c6 00 00 00       	jmp    80105a93 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
801059cd:	83 ec 04             	sub    $0x4,%esp
801059d0:	68 80 00 00 00       	push   $0x80
801059d5:	6a 00                	push   $0x0
801059d7:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801059dd:	50                   	push   %eax
801059de:	e8 9f ef ff ff       	call   80104982 <memset>
801059e3:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
801059e6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801059ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059f0:	83 f8 1f             	cmp    $0x1f,%eax
801059f3:	76 0a                	jbe    801059ff <sys_exec+0x72>
      return -1;
801059f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059fa:	e9 94 00 00 00       	jmp    80105a93 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801059ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a02:	c1 e0 02             	shl    $0x2,%eax
80105a05:	89 c2                	mov    %eax,%edx
80105a07:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105a0d:	01 c2                	add    %eax,%edx
80105a0f:	83 ec 08             	sub    $0x8,%esp
80105a12:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105a18:	50                   	push   %eax
80105a19:	52                   	push   %edx
80105a1a:	e8 ed f1 ff ff       	call   80104c0c <fetchint>
80105a1f:	83 c4 10             	add    $0x10,%esp
80105a22:	85 c0                	test   %eax,%eax
80105a24:	79 07                	jns    80105a2d <sys_exec+0xa0>
      return -1;
80105a26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a2b:	eb 66                	jmp    80105a93 <sys_exec+0x106>
    if(uarg == 0){
80105a2d:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105a33:	85 c0                	test   %eax,%eax
80105a35:	75 27                	jne    80105a5e <sys_exec+0xd1>
      argv[i] = 0;
80105a37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a3a:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105a41:	00 00 00 00 
      break;
80105a45:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105a46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a49:	83 ec 08             	sub    $0x8,%esp
80105a4c:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105a52:	52                   	push   %edx
80105a53:	50                   	push   %eax
80105a54:	e8 27 b1 ff ff       	call   80100b80 <exec>
80105a59:	83 c4 10             	add    $0x10,%esp
80105a5c:	eb 35                	jmp    80105a93 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105a5e:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a67:	c1 e0 02             	shl    $0x2,%eax
80105a6a:	01 c2                	add    %eax,%edx
80105a6c:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105a72:	83 ec 08             	sub    $0x8,%esp
80105a75:	52                   	push   %edx
80105a76:	50                   	push   %eax
80105a77:	e8 cf f1 ff ff       	call   80104c4b <fetchstr>
80105a7c:	83 c4 10             	add    $0x10,%esp
80105a7f:	85 c0                	test   %eax,%eax
80105a81:	79 07                	jns    80105a8a <sys_exec+0xfd>
      return -1;
80105a83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a88:	eb 09                	jmp    80105a93 <sys_exec+0x106>
  for(i=0;; i++){
80105a8a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105a8e:	e9 5a ff ff ff       	jmp    801059ed <sys_exec+0x60>
}
80105a93:	c9                   	leave  
80105a94:	c3                   	ret    

80105a95 <sys_pipe>:

int
sys_pipe(void)
{
80105a95:	55                   	push   %ebp
80105a96:	89 e5                	mov    %esp,%ebp
80105a98:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105a9b:	83 ec 04             	sub    $0x4,%esp
80105a9e:	6a 08                	push   $0x8
80105aa0:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105aa3:	50                   	push   %eax
80105aa4:	6a 00                	push   $0x0
80105aa6:	e8 2f f2 ff ff       	call   80104cda <argptr>
80105aab:	83 c4 10             	add    $0x10,%esp
80105aae:	85 c0                	test   %eax,%eax
80105ab0:	79 0a                	jns    80105abc <sys_pipe+0x27>
    return -1;
80105ab2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ab7:	e9 ae 00 00 00       	jmp    80105b6a <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105abc:	83 ec 08             	sub    $0x8,%esp
80105abf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105ac2:	50                   	push   %eax
80105ac3:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105ac6:	50                   	push   %eax
80105ac7:	e8 a1 da ff ff       	call   8010356d <pipealloc>
80105acc:	83 c4 10             	add    $0x10,%esp
80105acf:	85 c0                	test   %eax,%eax
80105ad1:	79 0a                	jns    80105add <sys_pipe+0x48>
    return -1;
80105ad3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ad8:	e9 8d 00 00 00       	jmp    80105b6a <sys_pipe+0xd5>
  fd0 = -1;
80105add:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105ae4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ae7:	83 ec 0c             	sub    $0xc,%esp
80105aea:	50                   	push   %eax
80105aeb:	e8 7b f3 ff ff       	call   80104e6b <fdalloc>
80105af0:	83 c4 10             	add    $0x10,%esp
80105af3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105af6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105afa:	78 18                	js     80105b14 <sys_pipe+0x7f>
80105afc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105aff:	83 ec 0c             	sub    $0xc,%esp
80105b02:	50                   	push   %eax
80105b03:	e8 63 f3 ff ff       	call   80104e6b <fdalloc>
80105b08:	83 c4 10             	add    $0x10,%esp
80105b0b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b0e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b12:	79 3e                	jns    80105b52 <sys_pipe+0xbd>
    if(fd0 >= 0)
80105b14:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b18:	78 13                	js     80105b2d <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105b1a:	e8 11 df ff ff       	call   80103a30 <myproc>
80105b1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b22:	83 c2 08             	add    $0x8,%edx
80105b25:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105b2c:	00 
    fileclose(rf);
80105b2d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b30:	83 ec 0c             	sub    $0xc,%esp
80105b33:	50                   	push   %eax
80105b34:	e8 62 b5 ff ff       	call   8010109b <fileclose>
80105b39:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105b3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b3f:	83 ec 0c             	sub    $0xc,%esp
80105b42:	50                   	push   %eax
80105b43:	e8 53 b5 ff ff       	call   8010109b <fileclose>
80105b48:	83 c4 10             	add    $0x10,%esp
    return -1;
80105b4b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b50:	eb 18                	jmp    80105b6a <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80105b52:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105b55:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b58:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105b5a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105b5d:	8d 50 04             	lea    0x4(%eax),%edx
80105b60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b63:	89 02                	mov    %eax,(%edx)
  return 0;
80105b65:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b6a:	c9                   	leave  
80105b6b:	c3                   	ret    

80105b6c <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80105b6c:	55                   	push   %ebp
80105b6d:	89 e5                	mov    %esp,%ebp
80105b6f:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105b72:	e8 b8 e1 ff ff       	call   80103d2f <fork>
}
80105b77:	c9                   	leave  
80105b78:	c3                   	ret    

80105b79 <sys_exit>:

int
sys_exit(void)
{
80105b79:	55                   	push   %ebp
80105b7a:	89 e5                	mov    %esp,%ebp
80105b7c:	83 ec 08             	sub    $0x8,%esp
  exit();
80105b7f:	e8 24 e3 ff ff       	call   80103ea8 <exit>
  return 0;  // not reached
80105b84:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b89:	c9                   	leave  
80105b8a:	c3                   	ret    

80105b8b <sys_wait>:

int
sys_wait(void)
{
80105b8b:	55                   	push   %ebp
80105b8c:	89 e5                	mov    %esp,%ebp
80105b8e:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105b91:	e8 32 e4 ff ff       	call   80103fc8 <wait>
}
80105b96:	c9                   	leave  
80105b97:	c3                   	ret    

80105b98 <sys_kill>:

int
sys_kill(void)
{
80105b98:	55                   	push   %ebp
80105b99:	89 e5                	mov    %esp,%ebp
80105b9b:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105b9e:	83 ec 08             	sub    $0x8,%esp
80105ba1:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ba4:	50                   	push   %eax
80105ba5:	6a 00                	push   $0x0
80105ba7:	e8 01 f1 ff ff       	call   80104cad <argint>
80105bac:	83 c4 10             	add    $0x10,%esp
80105baf:	85 c0                	test   %eax,%eax
80105bb1:	79 07                	jns    80105bba <sys_kill+0x22>
    return -1;
80105bb3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bb8:	eb 0f                	jmp    80105bc9 <sys_kill+0x31>
  return kill(pid);
80105bba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bbd:	83 ec 0c             	sub    $0xc,%esp
80105bc0:	50                   	push   %eax
80105bc1:	e8 31 e8 ff ff       	call   801043f7 <kill>
80105bc6:	83 c4 10             	add    $0x10,%esp
}
80105bc9:	c9                   	leave  
80105bca:	c3                   	ret    

80105bcb <sys_getpid>:

int
sys_getpid(void)
{
80105bcb:	55                   	push   %ebp
80105bcc:	89 e5                	mov    %esp,%ebp
80105bce:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105bd1:	e8 5a de ff ff       	call   80103a30 <myproc>
80105bd6:	8b 40 10             	mov    0x10(%eax),%eax
}
80105bd9:	c9                   	leave  
80105bda:	c3                   	ret    

80105bdb <sys_sbrk>:

int
sys_sbrk(void)
{
80105bdb:	55                   	push   %ebp
80105bdc:	89 e5                	mov    %esp,%ebp
80105bde:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105be1:	83 ec 08             	sub    $0x8,%esp
80105be4:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105be7:	50                   	push   %eax
80105be8:	6a 00                	push   $0x0
80105bea:	e8 be f0 ff ff       	call   80104cad <argint>
80105bef:	83 c4 10             	add    $0x10,%esp
80105bf2:	85 c0                	test   %eax,%eax
80105bf4:	79 07                	jns    80105bfd <sys_sbrk+0x22>
    return -1;
80105bf6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bfb:	eb 27                	jmp    80105c24 <sys_sbrk+0x49>
  addr = myproc()->sz;
80105bfd:	e8 2e de ff ff       	call   80103a30 <myproc>
80105c02:	8b 00                	mov    (%eax),%eax
80105c04:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80105c07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c0a:	83 ec 0c             	sub    $0xc,%esp
80105c0d:	50                   	push   %eax
80105c0e:	e8 81 e0 ff ff       	call   80103c94 <growproc>
80105c13:	83 c4 10             	add    $0x10,%esp
80105c16:	85 c0                	test   %eax,%eax
80105c18:	79 07                	jns    80105c21 <sys_sbrk+0x46>
    return -1;
80105c1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c1f:	eb 03                	jmp    80105c24 <sys_sbrk+0x49>
  return addr;
80105c21:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105c24:	c9                   	leave  
80105c25:	c3                   	ret    

80105c26 <sys_sleep>:

int
sys_sleep(void)
{
80105c26:	55                   	push   %ebp
80105c27:	89 e5                	mov    %esp,%ebp
80105c29:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105c2c:	83 ec 08             	sub    $0x8,%esp
80105c2f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c32:	50                   	push   %eax
80105c33:	6a 00                	push   $0x0
80105c35:	e8 73 f0 ff ff       	call   80104cad <argint>
80105c3a:	83 c4 10             	add    $0x10,%esp
80105c3d:	85 c0                	test   %eax,%eax
80105c3f:	79 07                	jns    80105c48 <sys_sleep+0x22>
    return -1;
80105c41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c46:	eb 76                	jmp    80105cbe <sys_sleep+0x98>
  acquire(&tickslock);
80105c48:	83 ec 0c             	sub    $0xc,%esp
80105c4b:	68 40 6a 19 80       	push   $0x80196a40
80105c50:	e8 b7 ea ff ff       	call   8010470c <acquire>
80105c55:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80105c58:	a1 74 6a 19 80       	mov    0x80196a74,%eax
80105c5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80105c60:	eb 38                	jmp    80105c9a <sys_sleep+0x74>
    if(myproc()->killed){
80105c62:	e8 c9 dd ff ff       	call   80103a30 <myproc>
80105c67:	8b 40 24             	mov    0x24(%eax),%eax
80105c6a:	85 c0                	test   %eax,%eax
80105c6c:	74 17                	je     80105c85 <sys_sleep+0x5f>
      release(&tickslock);
80105c6e:	83 ec 0c             	sub    $0xc,%esp
80105c71:	68 40 6a 19 80       	push   $0x80196a40
80105c76:	e8 ff ea ff ff       	call   8010477a <release>
80105c7b:	83 c4 10             	add    $0x10,%esp
      return -1;
80105c7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c83:	eb 39                	jmp    80105cbe <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80105c85:	83 ec 08             	sub    $0x8,%esp
80105c88:	68 40 6a 19 80       	push   $0x80196a40
80105c8d:	68 74 6a 19 80       	push   $0x80196a74
80105c92:	e8 42 e6 ff ff       	call   801042d9 <sleep>
80105c97:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80105c9a:	a1 74 6a 19 80       	mov    0x80196a74,%eax
80105c9f:	2b 45 f4             	sub    -0xc(%ebp),%eax
80105ca2:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ca5:	39 d0                	cmp    %edx,%eax
80105ca7:	72 b9                	jb     80105c62 <sys_sleep+0x3c>
  }
  release(&tickslock);
80105ca9:	83 ec 0c             	sub    $0xc,%esp
80105cac:	68 40 6a 19 80       	push   $0x80196a40
80105cb1:	e8 c4 ea ff ff       	call   8010477a <release>
80105cb6:	83 c4 10             	add    $0x10,%esp
  return 0;
80105cb9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cbe:	c9                   	leave  
80105cbf:	c3                   	ret    

80105cc0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105cc0:	55                   	push   %ebp
80105cc1:	89 e5                	mov    %esp,%ebp
80105cc3:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80105cc6:	83 ec 0c             	sub    $0xc,%esp
80105cc9:	68 40 6a 19 80       	push   $0x80196a40
80105cce:	e8 39 ea ff ff       	call   8010470c <acquire>
80105cd3:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80105cd6:	a1 74 6a 19 80       	mov    0x80196a74,%eax
80105cdb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80105cde:	83 ec 0c             	sub    $0xc,%esp
80105ce1:	68 40 6a 19 80       	push   $0x80196a40
80105ce6:	e8 8f ea ff ff       	call   8010477a <release>
80105ceb:	83 c4 10             	add    $0x10,%esp
  return xticks;
80105cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105cf1:	c9                   	leave  
80105cf2:	c3                   	ret    

80105cf3 <sys_uthread_init>:

int 
sys_uthread_init(void)
{
80105cf3:	55                   	push   %ebp
80105cf4:	89 e5                	mov    %esp,%ebp
80105cf6:	83 ec 18             	sub    $0x18,%esp
  int n;
  if (argint(0, &n) < 0)
80105cf9:	83 ec 08             	sub    $0x8,%esp
80105cfc:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105cff:	50                   	push   %eax
80105d00:	6a 00                	push   $0x0
80105d02:	e8 a6 ef ff ff       	call   80104cad <argint>
80105d07:	83 c4 10             	add    $0x10,%esp
80105d0a:	85 c0                	test   %eax,%eax
80105d0c:	79 07                	jns    80105d15 <sys_uthread_init+0x22>
      return -1;
80105d0e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d13:	eb 14                	jmp    80105d29 <sys_uthread_init+0x36>
  uthread_init(n);
80105d15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d18:	83 ec 0c             	sub    $0xc,%esp
80105d1b:	50                   	push   %eax
80105d1c:	e8 54 e8 ff ff       	call   80104575 <uthread_init>
80105d21:	83 c4 10             	add    $0x10,%esp
  return 0;
80105d24:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d29:	c9                   	leave  
80105d2a:	c3                   	ret    

80105d2b <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80105d2b:	1e                   	push   %ds
  pushl %es
80105d2c:	06                   	push   %es
  pushl %fs
80105d2d:	0f a0                	push   %fs
  pushl %gs
80105d2f:	0f a8                	push   %gs
  pushal
80105d31:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80105d32:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80105d36:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80105d38:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80105d3a:	54                   	push   %esp
  call trap
80105d3b:	e8 d7 01 00 00       	call   80105f17 <trap>
  addl $4, %esp
80105d40:	83 c4 04             	add    $0x4,%esp

80105d43 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80105d43:	61                   	popa   
  popl %gs
80105d44:	0f a9                	pop    %gs
  popl %fs
80105d46:	0f a1                	pop    %fs
  popl %es
80105d48:	07                   	pop    %es
  popl %ds
80105d49:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80105d4a:	83 c4 08             	add    $0x8,%esp
  iret
80105d4d:	cf                   	iret   

80105d4e <lidt>:
{
80105d4e:	55                   	push   %ebp
80105d4f:	89 e5                	mov    %esp,%ebp
80105d51:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80105d54:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d57:	83 e8 01             	sub    $0x1,%eax
80105d5a:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80105d5e:	8b 45 08             	mov    0x8(%ebp),%eax
80105d61:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105d65:	8b 45 08             	mov    0x8(%ebp),%eax
80105d68:	c1 e8 10             	shr    $0x10,%eax
80105d6b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105d6f:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105d72:	0f 01 18             	lidtl  (%eax)
}
80105d75:	90                   	nop
80105d76:	c9                   	leave  
80105d77:	c3                   	ret    

80105d78 <rcr2>:

static inline uint
rcr2(void)
{
80105d78:	55                   	push   %ebp
80105d79:	89 e5                	mov    %esp,%ebp
80105d7b:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105d7e:	0f 20 d0             	mov    %cr2,%eax
80105d81:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80105d84:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105d87:	c9                   	leave  
80105d88:	c3                   	ret    

80105d89 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80105d89:	55                   	push   %ebp
80105d8a:	89 e5                	mov    %esp,%ebp
80105d8c:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80105d8f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105d96:	e9 c3 00 00 00       	jmp    80105e5e <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80105d9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d9e:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
80105da5:	89 c2                	mov    %eax,%edx
80105da7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105daa:	66 89 14 c5 40 62 19 	mov    %dx,-0x7fe69dc0(,%eax,8)
80105db1:	80 
80105db2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105db5:	66 c7 04 c5 42 62 19 	movw   $0x8,-0x7fe69dbe(,%eax,8)
80105dbc:	80 08 00 
80105dbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dc2:	0f b6 14 c5 44 62 19 	movzbl -0x7fe69dbc(,%eax,8),%edx
80105dc9:	80 
80105dca:	83 e2 e0             	and    $0xffffffe0,%edx
80105dcd:	88 14 c5 44 62 19 80 	mov    %dl,-0x7fe69dbc(,%eax,8)
80105dd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dd7:	0f b6 14 c5 44 62 19 	movzbl -0x7fe69dbc(,%eax,8),%edx
80105dde:	80 
80105ddf:	83 e2 1f             	and    $0x1f,%edx
80105de2:	88 14 c5 44 62 19 80 	mov    %dl,-0x7fe69dbc(,%eax,8)
80105de9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dec:	0f b6 14 c5 45 62 19 	movzbl -0x7fe69dbb(,%eax,8),%edx
80105df3:	80 
80105df4:	83 e2 f0             	and    $0xfffffff0,%edx
80105df7:	83 ca 0e             	or     $0xe,%edx
80105dfa:	88 14 c5 45 62 19 80 	mov    %dl,-0x7fe69dbb(,%eax,8)
80105e01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e04:	0f b6 14 c5 45 62 19 	movzbl -0x7fe69dbb(,%eax,8),%edx
80105e0b:	80 
80105e0c:	83 e2 ef             	and    $0xffffffef,%edx
80105e0f:	88 14 c5 45 62 19 80 	mov    %dl,-0x7fe69dbb(,%eax,8)
80105e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e19:	0f b6 14 c5 45 62 19 	movzbl -0x7fe69dbb(,%eax,8),%edx
80105e20:	80 
80105e21:	83 e2 9f             	and    $0xffffff9f,%edx
80105e24:	88 14 c5 45 62 19 80 	mov    %dl,-0x7fe69dbb(,%eax,8)
80105e2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e2e:	0f b6 14 c5 45 62 19 	movzbl -0x7fe69dbb(,%eax,8),%edx
80105e35:	80 
80105e36:	83 ca 80             	or     $0xffffff80,%edx
80105e39:	88 14 c5 45 62 19 80 	mov    %dl,-0x7fe69dbb(,%eax,8)
80105e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e43:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
80105e4a:	c1 e8 10             	shr    $0x10,%eax
80105e4d:	89 c2                	mov    %eax,%edx
80105e4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e52:	66 89 14 c5 46 62 19 	mov    %dx,-0x7fe69dba(,%eax,8)
80105e59:	80 
  for(i = 0; i < 256; i++)
80105e5a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105e5e:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80105e65:	0f 8e 30 ff ff ff    	jle    80105d9b <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105e6b:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
80105e70:	66 a3 40 64 19 80    	mov    %ax,0x80196440
80105e76:	66 c7 05 42 64 19 80 	movw   $0x8,0x80196442
80105e7d:	08 00 
80105e7f:	0f b6 05 44 64 19 80 	movzbl 0x80196444,%eax
80105e86:	83 e0 e0             	and    $0xffffffe0,%eax
80105e89:	a2 44 64 19 80       	mov    %al,0x80196444
80105e8e:	0f b6 05 44 64 19 80 	movzbl 0x80196444,%eax
80105e95:	83 e0 1f             	and    $0x1f,%eax
80105e98:	a2 44 64 19 80       	mov    %al,0x80196444
80105e9d:	0f b6 05 45 64 19 80 	movzbl 0x80196445,%eax
80105ea4:	83 c8 0f             	or     $0xf,%eax
80105ea7:	a2 45 64 19 80       	mov    %al,0x80196445
80105eac:	0f b6 05 45 64 19 80 	movzbl 0x80196445,%eax
80105eb3:	83 e0 ef             	and    $0xffffffef,%eax
80105eb6:	a2 45 64 19 80       	mov    %al,0x80196445
80105ebb:	0f b6 05 45 64 19 80 	movzbl 0x80196445,%eax
80105ec2:	83 c8 60             	or     $0x60,%eax
80105ec5:	a2 45 64 19 80       	mov    %al,0x80196445
80105eca:	0f b6 05 45 64 19 80 	movzbl 0x80196445,%eax
80105ed1:	83 c8 80             	or     $0xffffff80,%eax
80105ed4:	a2 45 64 19 80       	mov    %al,0x80196445
80105ed9:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
80105ede:	c1 e8 10             	shr    $0x10,%eax
80105ee1:	66 a3 46 64 19 80    	mov    %ax,0x80196446

  initlock(&tickslock, "time");
80105ee7:	83 ec 08             	sub    $0x8,%esp
80105eea:	68 58 a4 10 80       	push   $0x8010a458
80105eef:	68 40 6a 19 80       	push   $0x80196a40
80105ef4:	e8 f1 e7 ff ff       	call   801046ea <initlock>
80105ef9:	83 c4 10             	add    $0x10,%esp
}
80105efc:	90                   	nop
80105efd:	c9                   	leave  
80105efe:	c3                   	ret    

80105eff <idtinit>:

void
idtinit(void)
{
80105eff:	55                   	push   %ebp
80105f00:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80105f02:	68 00 08 00 00       	push   $0x800
80105f07:	68 40 62 19 80       	push   $0x80196240
80105f0c:	e8 3d fe ff ff       	call   80105d4e <lidt>
80105f11:	83 c4 08             	add    $0x8,%esp
}
80105f14:	90                   	nop
80105f15:	c9                   	leave  
80105f16:	c3                   	ret    

80105f17 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80105f17:	55                   	push   %ebp
80105f18:	89 e5                	mov    %esp,%ebp
80105f1a:	57                   	push   %edi
80105f1b:	56                   	push   %esi
80105f1c:	53                   	push   %ebx
80105f1d:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
80105f20:	8b 45 08             	mov    0x8(%ebp),%eax
80105f23:	8b 40 30             	mov    0x30(%eax),%eax
80105f26:	83 f8 40             	cmp    $0x40,%eax
80105f29:	75 3b                	jne    80105f66 <trap+0x4f>
    if(myproc()->killed)
80105f2b:	e8 00 db ff ff       	call   80103a30 <myproc>
80105f30:	8b 40 24             	mov    0x24(%eax),%eax
80105f33:	85 c0                	test   %eax,%eax
80105f35:	74 05                	je     80105f3c <trap+0x25>
      exit();
80105f37:	e8 6c df ff ff       	call   80103ea8 <exit>
    myproc()->tf = tf;
80105f3c:	e8 ef da ff ff       	call   80103a30 <myproc>
80105f41:	8b 55 08             	mov    0x8(%ebp),%edx
80105f44:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80105f47:	e8 2d ee ff ff       	call   80104d79 <syscall>
    if(myproc()->killed)
80105f4c:	e8 df da ff ff       	call   80103a30 <myproc>
80105f51:	8b 40 24             	mov    0x24(%eax),%eax
80105f54:	85 c0                	test   %eax,%eax
80105f56:	0f 84 5c 02 00 00    	je     801061b8 <trap+0x2a1>
      exit();
80105f5c:	e8 47 df ff ff       	call   80103ea8 <exit>
    return;
80105f61:	e9 52 02 00 00       	jmp    801061b8 <trap+0x2a1>
  }

  switch(tf->trapno){
80105f66:	8b 45 08             	mov    0x8(%ebp),%eax
80105f69:	8b 40 30             	mov    0x30(%eax),%eax
80105f6c:	83 e8 20             	sub    $0x20,%eax
80105f6f:	83 f8 1f             	cmp    $0x1f,%eax
80105f72:	0f 87 08 01 00 00    	ja     80106080 <trap+0x169>
80105f78:	8b 04 85 00 a5 10 80 	mov    -0x7fef5b00(,%eax,4),%eax
80105f7f:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80105f81:	e8 17 da ff ff       	call   8010399d <cpuid>
80105f86:	85 c0                	test   %eax,%eax
80105f88:	75 3d                	jne    80105fc7 <trap+0xb0>
      acquire(&tickslock);
80105f8a:	83 ec 0c             	sub    $0xc,%esp
80105f8d:	68 40 6a 19 80       	push   $0x80196a40
80105f92:	e8 75 e7 ff ff       	call   8010470c <acquire>
80105f97:	83 c4 10             	add    $0x10,%esp
      ticks++;
80105f9a:	a1 74 6a 19 80       	mov    0x80196a74,%eax
80105f9f:	83 c0 01             	add    $0x1,%eax
80105fa2:	a3 74 6a 19 80       	mov    %eax,0x80196a74
      wakeup(&ticks);
80105fa7:	83 ec 0c             	sub    $0xc,%esp
80105faa:	68 74 6a 19 80       	push   $0x80196a74
80105faf:	e8 0c e4 ff ff       	call   801043c0 <wakeup>
80105fb4:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80105fb7:	83 ec 0c             	sub    $0xc,%esp
80105fba:	68 40 6a 19 80       	push   $0x80196a40
80105fbf:	e8 b6 e7 ff ff       	call   8010477a <release>
80105fc4:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80105fc7:	e8 50 cb ff ff       	call   80102b1c <lapiceoi>

    struct proc *curproc = myproc();
80105fcc:	e8 5f da ff ff       	call   80103a30 <myproc>
80105fd1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 
    if (curproc && curproc->scheduler) {
80105fd4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80105fd8:	0f 84 59 01 00 00    	je     80106137 <trap+0x220>
80105fde:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fe1:	8b 40 7c             	mov    0x7c(%eax),%eax
80105fe4:	85 c0                	test   %eax,%eax
80105fe6:	0f 84 4b 01 00 00    	je     80106137 <trap+0x220>
      if (!(tf->cs & 3)) {
80105fec:	8b 45 08             	mov    0x8(%ebp),%eax
80105fef:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80105ff3:	0f b7 c0             	movzwl %ax,%eax
80105ff6:	83 e0 03             	and    $0x3,%eax
80105ff9:	85 c0                	test   %eax,%eax
80105ffb:	0f 85 36 01 00 00    	jne    80106137 <trap+0x220>
        curproc->tf->eip = curproc->scheduler;
80106001:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106004:	8b 40 18             	mov    0x18(%eax),%eax
80106007:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010600a:	8b 52 7c             	mov    0x7c(%edx),%edx
8010600d:	89 50 38             	mov    %edx,0x38(%eax)
      }
    }
    
    break;
80106010:	e9 22 01 00 00       	jmp    80106137 <trap+0x220>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106015:	e8 f8 3e 00 00       	call   80109f12 <ideintr>
    lapiceoi();
8010601a:	e8 fd ca ff ff       	call   80102b1c <lapiceoi>
    break;
8010601f:	e9 14 01 00 00       	jmp    80106138 <trap+0x221>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106024:	e8 38 c9 ff ff       	call   80102961 <kbdintr>
    lapiceoi();
80106029:	e8 ee ca ff ff       	call   80102b1c <lapiceoi>
    break;
8010602e:	e9 05 01 00 00       	jmp    80106138 <trap+0x221>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106033:	e8 56 03 00 00       	call   8010638e <uartintr>
    lapiceoi();
80106038:	e8 df ca ff ff       	call   80102b1c <lapiceoi>
    break;
8010603d:	e9 f6 00 00 00       	jmp    80106138 <trap+0x221>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106042:	e8 7e 2b 00 00       	call   80108bc5 <i8254_intr>
    lapiceoi();
80106047:	e8 d0 ca ff ff       	call   80102b1c <lapiceoi>
    break;
8010604c:	e9 e7 00 00 00       	jmp    80106138 <trap+0x221>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106051:	8b 45 08             	mov    0x8(%ebp),%eax
80106054:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106057:	8b 45 08             	mov    0x8(%ebp),%eax
8010605a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010605e:	0f b7 d8             	movzwl %ax,%ebx
80106061:	e8 37 d9 ff ff       	call   8010399d <cpuid>
80106066:	56                   	push   %esi
80106067:	53                   	push   %ebx
80106068:	50                   	push   %eax
80106069:	68 60 a4 10 80       	push   $0x8010a460
8010606e:	e8 81 a3 ff ff       	call   801003f4 <cprintf>
80106073:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106076:	e8 a1 ca ff ff       	call   80102b1c <lapiceoi>
    break;
8010607b:	e9 b8 00 00 00       	jmp    80106138 <trap+0x221>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106080:	e8 ab d9 ff ff       	call   80103a30 <myproc>
80106085:	85 c0                	test   %eax,%eax
80106087:	74 11                	je     8010609a <trap+0x183>
80106089:	8b 45 08             	mov    0x8(%ebp),%eax
8010608c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106090:	0f b7 c0             	movzwl %ax,%eax
80106093:	83 e0 03             	and    $0x3,%eax
80106096:	85 c0                	test   %eax,%eax
80106098:	75 39                	jne    801060d3 <trap+0x1bc>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010609a:	e8 d9 fc ff ff       	call   80105d78 <rcr2>
8010609f:	89 c3                	mov    %eax,%ebx
801060a1:	8b 45 08             	mov    0x8(%ebp),%eax
801060a4:	8b 70 38             	mov    0x38(%eax),%esi
801060a7:	e8 f1 d8 ff ff       	call   8010399d <cpuid>
801060ac:	8b 55 08             	mov    0x8(%ebp),%edx
801060af:	8b 52 30             	mov    0x30(%edx),%edx
801060b2:	83 ec 0c             	sub    $0xc,%esp
801060b5:	53                   	push   %ebx
801060b6:	56                   	push   %esi
801060b7:	50                   	push   %eax
801060b8:	52                   	push   %edx
801060b9:	68 84 a4 10 80       	push   $0x8010a484
801060be:	e8 31 a3 ff ff       	call   801003f4 <cprintf>
801060c3:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
801060c6:	83 ec 0c             	sub    $0xc,%esp
801060c9:	68 b6 a4 10 80       	push   $0x8010a4b6
801060ce:	e8 d6 a4 ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801060d3:	e8 a0 fc ff ff       	call   80105d78 <rcr2>
801060d8:	89 c6                	mov    %eax,%esi
801060da:	8b 45 08             	mov    0x8(%ebp),%eax
801060dd:	8b 40 38             	mov    0x38(%eax),%eax
801060e0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801060e3:	e8 b5 d8 ff ff       	call   8010399d <cpuid>
801060e8:	89 c3                	mov    %eax,%ebx
801060ea:	8b 45 08             	mov    0x8(%ebp),%eax
801060ed:	8b 48 34             	mov    0x34(%eax),%ecx
801060f0:	89 4d d0             	mov    %ecx,-0x30(%ebp)
801060f3:	8b 45 08             	mov    0x8(%ebp),%eax
801060f6:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801060f9:	e8 32 d9 ff ff       	call   80103a30 <myproc>
801060fe:	8d 50 6c             	lea    0x6c(%eax),%edx
80106101:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106104:	e8 27 d9 ff ff       	call   80103a30 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106109:	8b 40 10             	mov    0x10(%eax),%eax
8010610c:	56                   	push   %esi
8010610d:	ff 75 d4             	push   -0x2c(%ebp)
80106110:	53                   	push   %ebx
80106111:	ff 75 d0             	push   -0x30(%ebp)
80106114:	57                   	push   %edi
80106115:	ff 75 cc             	push   -0x34(%ebp)
80106118:	50                   	push   %eax
80106119:	68 bc a4 10 80       	push   $0x8010a4bc
8010611e:	e8 d1 a2 ff ff       	call   801003f4 <cprintf>
80106123:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106126:	e8 05 d9 ff ff       	call   80103a30 <myproc>
8010612b:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106132:	eb 04                	jmp    80106138 <trap+0x221>
    break;
80106134:	90                   	nop
80106135:	eb 01                	jmp    80106138 <trap+0x221>
    break;
80106137:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106138:	e8 f3 d8 ff ff       	call   80103a30 <myproc>
8010613d:	85 c0                	test   %eax,%eax
8010613f:	74 23                	je     80106164 <trap+0x24d>
80106141:	e8 ea d8 ff ff       	call   80103a30 <myproc>
80106146:	8b 40 24             	mov    0x24(%eax),%eax
80106149:	85 c0                	test   %eax,%eax
8010614b:	74 17                	je     80106164 <trap+0x24d>
8010614d:	8b 45 08             	mov    0x8(%ebp),%eax
80106150:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106154:	0f b7 c0             	movzwl %ax,%eax
80106157:	83 e0 03             	and    $0x3,%eax
8010615a:	83 f8 03             	cmp    $0x3,%eax
8010615d:	75 05                	jne    80106164 <trap+0x24d>
    exit();
8010615f:	e8 44 dd ff ff       	call   80103ea8 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106164:	e8 c7 d8 ff ff       	call   80103a30 <myproc>
80106169:	85 c0                	test   %eax,%eax
8010616b:	74 1d                	je     8010618a <trap+0x273>
8010616d:	e8 be d8 ff ff       	call   80103a30 <myproc>
80106172:	8b 40 0c             	mov    0xc(%eax),%eax
80106175:	83 f8 04             	cmp    $0x4,%eax
80106178:	75 10                	jne    8010618a <trap+0x273>
     tf->trapno == T_IRQ0+IRQ_TIMER)
8010617a:	8b 45 08             	mov    0x8(%ebp),%eax
8010617d:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106180:	83 f8 20             	cmp    $0x20,%eax
80106183:	75 05                	jne    8010618a <trap+0x273>
    yield();
80106185:	e8 cf e0 ff ff       	call   80104259 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010618a:	e8 a1 d8 ff ff       	call   80103a30 <myproc>
8010618f:	85 c0                	test   %eax,%eax
80106191:	74 26                	je     801061b9 <trap+0x2a2>
80106193:	e8 98 d8 ff ff       	call   80103a30 <myproc>
80106198:	8b 40 24             	mov    0x24(%eax),%eax
8010619b:	85 c0                	test   %eax,%eax
8010619d:	74 1a                	je     801061b9 <trap+0x2a2>
8010619f:	8b 45 08             	mov    0x8(%ebp),%eax
801061a2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801061a6:	0f b7 c0             	movzwl %ax,%eax
801061a9:	83 e0 03             	and    $0x3,%eax
801061ac:	83 f8 03             	cmp    $0x3,%eax
801061af:	75 08                	jne    801061b9 <trap+0x2a2>
    exit();
801061b1:	e8 f2 dc ff ff       	call   80103ea8 <exit>
801061b6:	eb 01                	jmp    801061b9 <trap+0x2a2>
    return;
801061b8:	90                   	nop
}
801061b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
801061bc:	5b                   	pop    %ebx
801061bd:	5e                   	pop    %esi
801061be:	5f                   	pop    %edi
801061bf:	5d                   	pop    %ebp
801061c0:	c3                   	ret    

801061c1 <inb>:
{
801061c1:	55                   	push   %ebp
801061c2:	89 e5                	mov    %esp,%ebp
801061c4:	83 ec 14             	sub    $0x14,%esp
801061c7:	8b 45 08             	mov    0x8(%ebp),%eax
801061ca:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801061ce:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801061d2:	89 c2                	mov    %eax,%edx
801061d4:	ec                   	in     (%dx),%al
801061d5:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801061d8:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801061dc:	c9                   	leave  
801061dd:	c3                   	ret    

801061de <outb>:
{
801061de:	55                   	push   %ebp
801061df:	89 e5                	mov    %esp,%ebp
801061e1:	83 ec 08             	sub    $0x8,%esp
801061e4:	8b 45 08             	mov    0x8(%ebp),%eax
801061e7:	8b 55 0c             	mov    0xc(%ebp),%edx
801061ea:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801061ee:	89 d0                	mov    %edx,%eax
801061f0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801061f3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801061f7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801061fb:	ee                   	out    %al,(%dx)
}
801061fc:	90                   	nop
801061fd:	c9                   	leave  
801061fe:	c3                   	ret    

801061ff <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801061ff:	55                   	push   %ebp
80106200:	89 e5                	mov    %esp,%ebp
80106202:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106205:	6a 00                	push   $0x0
80106207:	68 fa 03 00 00       	push   $0x3fa
8010620c:	e8 cd ff ff ff       	call   801061de <outb>
80106211:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106214:	68 80 00 00 00       	push   $0x80
80106219:	68 fb 03 00 00       	push   $0x3fb
8010621e:	e8 bb ff ff ff       	call   801061de <outb>
80106223:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106226:	6a 0c                	push   $0xc
80106228:	68 f8 03 00 00       	push   $0x3f8
8010622d:	e8 ac ff ff ff       	call   801061de <outb>
80106232:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106235:	6a 00                	push   $0x0
80106237:	68 f9 03 00 00       	push   $0x3f9
8010623c:	e8 9d ff ff ff       	call   801061de <outb>
80106241:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106244:	6a 03                	push   $0x3
80106246:	68 fb 03 00 00       	push   $0x3fb
8010624b:	e8 8e ff ff ff       	call   801061de <outb>
80106250:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106253:	6a 00                	push   $0x0
80106255:	68 fc 03 00 00       	push   $0x3fc
8010625a:	e8 7f ff ff ff       	call   801061de <outb>
8010625f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106262:	6a 01                	push   $0x1
80106264:	68 f9 03 00 00       	push   $0x3f9
80106269:	e8 70 ff ff ff       	call   801061de <outb>
8010626e:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106271:	68 fd 03 00 00       	push   $0x3fd
80106276:	e8 46 ff ff ff       	call   801061c1 <inb>
8010627b:	83 c4 04             	add    $0x4,%esp
8010627e:	3c ff                	cmp    $0xff,%al
80106280:	74 61                	je     801062e3 <uartinit+0xe4>
    return;
  uart = 1;
80106282:	c7 05 78 6a 19 80 01 	movl   $0x1,0x80196a78
80106289:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
8010628c:	68 fa 03 00 00       	push   $0x3fa
80106291:	e8 2b ff ff ff       	call   801061c1 <inb>
80106296:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106299:	68 f8 03 00 00       	push   $0x3f8
8010629e:	e8 1e ff ff ff       	call   801061c1 <inb>
801062a3:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
801062a6:	83 ec 08             	sub    $0x8,%esp
801062a9:	6a 00                	push   $0x0
801062ab:	6a 04                	push   $0x4
801062ad:	e8 7c c3 ff ff       	call   8010262e <ioapicenable>
801062b2:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801062b5:	c7 45 f4 80 a5 10 80 	movl   $0x8010a580,-0xc(%ebp)
801062bc:	eb 19                	jmp    801062d7 <uartinit+0xd8>
    uartputc(*p);
801062be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062c1:	0f b6 00             	movzbl (%eax),%eax
801062c4:	0f be c0             	movsbl %al,%eax
801062c7:	83 ec 0c             	sub    $0xc,%esp
801062ca:	50                   	push   %eax
801062cb:	e8 16 00 00 00       	call   801062e6 <uartputc>
801062d0:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
801062d3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801062d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062da:	0f b6 00             	movzbl (%eax),%eax
801062dd:	84 c0                	test   %al,%al
801062df:	75 dd                	jne    801062be <uartinit+0xbf>
801062e1:	eb 01                	jmp    801062e4 <uartinit+0xe5>
    return;
801062e3:	90                   	nop
}
801062e4:	c9                   	leave  
801062e5:	c3                   	ret    

801062e6 <uartputc>:

void
uartputc(int c)
{
801062e6:	55                   	push   %ebp
801062e7:	89 e5                	mov    %esp,%ebp
801062e9:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801062ec:	a1 78 6a 19 80       	mov    0x80196a78,%eax
801062f1:	85 c0                	test   %eax,%eax
801062f3:	74 53                	je     80106348 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801062f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801062fc:	eb 11                	jmp    8010630f <uartputc+0x29>
    microdelay(10);
801062fe:	83 ec 0c             	sub    $0xc,%esp
80106301:	6a 0a                	push   $0xa
80106303:	e8 2f c8 ff ff       	call   80102b37 <microdelay>
80106308:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010630b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010630f:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106313:	7f 1a                	jg     8010632f <uartputc+0x49>
80106315:	83 ec 0c             	sub    $0xc,%esp
80106318:	68 fd 03 00 00       	push   $0x3fd
8010631d:	e8 9f fe ff ff       	call   801061c1 <inb>
80106322:	83 c4 10             	add    $0x10,%esp
80106325:	0f b6 c0             	movzbl %al,%eax
80106328:	83 e0 20             	and    $0x20,%eax
8010632b:	85 c0                	test   %eax,%eax
8010632d:	74 cf                	je     801062fe <uartputc+0x18>
  outb(COM1+0, c);
8010632f:	8b 45 08             	mov    0x8(%ebp),%eax
80106332:	0f b6 c0             	movzbl %al,%eax
80106335:	83 ec 08             	sub    $0x8,%esp
80106338:	50                   	push   %eax
80106339:	68 f8 03 00 00       	push   $0x3f8
8010633e:	e8 9b fe ff ff       	call   801061de <outb>
80106343:	83 c4 10             	add    $0x10,%esp
80106346:	eb 01                	jmp    80106349 <uartputc+0x63>
    return;
80106348:	90                   	nop
}
80106349:	c9                   	leave  
8010634a:	c3                   	ret    

8010634b <uartgetc>:

static int
uartgetc(void)
{
8010634b:	55                   	push   %ebp
8010634c:	89 e5                	mov    %esp,%ebp
  if(!uart)
8010634e:	a1 78 6a 19 80       	mov    0x80196a78,%eax
80106353:	85 c0                	test   %eax,%eax
80106355:	75 07                	jne    8010635e <uartgetc+0x13>
    return -1;
80106357:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010635c:	eb 2e                	jmp    8010638c <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
8010635e:	68 fd 03 00 00       	push   $0x3fd
80106363:	e8 59 fe ff ff       	call   801061c1 <inb>
80106368:	83 c4 04             	add    $0x4,%esp
8010636b:	0f b6 c0             	movzbl %al,%eax
8010636e:	83 e0 01             	and    $0x1,%eax
80106371:	85 c0                	test   %eax,%eax
80106373:	75 07                	jne    8010637c <uartgetc+0x31>
    return -1;
80106375:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010637a:	eb 10                	jmp    8010638c <uartgetc+0x41>
  return inb(COM1+0);
8010637c:	68 f8 03 00 00       	push   $0x3f8
80106381:	e8 3b fe ff ff       	call   801061c1 <inb>
80106386:	83 c4 04             	add    $0x4,%esp
80106389:	0f b6 c0             	movzbl %al,%eax
}
8010638c:	c9                   	leave  
8010638d:	c3                   	ret    

8010638e <uartintr>:

void
uartintr(void)
{
8010638e:	55                   	push   %ebp
8010638f:	89 e5                	mov    %esp,%ebp
80106391:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106394:	83 ec 0c             	sub    $0xc,%esp
80106397:	68 4b 63 10 80       	push   $0x8010634b
8010639c:	e8 35 a4 ff ff       	call   801007d6 <consoleintr>
801063a1:	83 c4 10             	add    $0x10,%esp
}
801063a4:	90                   	nop
801063a5:	c9                   	leave  
801063a6:	c3                   	ret    

801063a7 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801063a7:	6a 00                	push   $0x0
  pushl $0
801063a9:	6a 00                	push   $0x0
  jmp alltraps
801063ab:	e9 7b f9 ff ff       	jmp    80105d2b <alltraps>

801063b0 <vector1>:
.globl vector1
vector1:
  pushl $0
801063b0:	6a 00                	push   $0x0
  pushl $1
801063b2:	6a 01                	push   $0x1
  jmp alltraps
801063b4:	e9 72 f9 ff ff       	jmp    80105d2b <alltraps>

801063b9 <vector2>:
.globl vector2
vector2:
  pushl $0
801063b9:	6a 00                	push   $0x0
  pushl $2
801063bb:	6a 02                	push   $0x2
  jmp alltraps
801063bd:	e9 69 f9 ff ff       	jmp    80105d2b <alltraps>

801063c2 <vector3>:
.globl vector3
vector3:
  pushl $0
801063c2:	6a 00                	push   $0x0
  pushl $3
801063c4:	6a 03                	push   $0x3
  jmp alltraps
801063c6:	e9 60 f9 ff ff       	jmp    80105d2b <alltraps>

801063cb <vector4>:
.globl vector4
vector4:
  pushl $0
801063cb:	6a 00                	push   $0x0
  pushl $4
801063cd:	6a 04                	push   $0x4
  jmp alltraps
801063cf:	e9 57 f9 ff ff       	jmp    80105d2b <alltraps>

801063d4 <vector5>:
.globl vector5
vector5:
  pushl $0
801063d4:	6a 00                	push   $0x0
  pushl $5
801063d6:	6a 05                	push   $0x5
  jmp alltraps
801063d8:	e9 4e f9 ff ff       	jmp    80105d2b <alltraps>

801063dd <vector6>:
.globl vector6
vector6:
  pushl $0
801063dd:	6a 00                	push   $0x0
  pushl $6
801063df:	6a 06                	push   $0x6
  jmp alltraps
801063e1:	e9 45 f9 ff ff       	jmp    80105d2b <alltraps>

801063e6 <vector7>:
.globl vector7
vector7:
  pushl $0
801063e6:	6a 00                	push   $0x0
  pushl $7
801063e8:	6a 07                	push   $0x7
  jmp alltraps
801063ea:	e9 3c f9 ff ff       	jmp    80105d2b <alltraps>

801063ef <vector8>:
.globl vector8
vector8:
  pushl $8
801063ef:	6a 08                	push   $0x8
  jmp alltraps
801063f1:	e9 35 f9 ff ff       	jmp    80105d2b <alltraps>

801063f6 <vector9>:
.globl vector9
vector9:
  pushl $0
801063f6:	6a 00                	push   $0x0
  pushl $9
801063f8:	6a 09                	push   $0x9
  jmp alltraps
801063fa:	e9 2c f9 ff ff       	jmp    80105d2b <alltraps>

801063ff <vector10>:
.globl vector10
vector10:
  pushl $10
801063ff:	6a 0a                	push   $0xa
  jmp alltraps
80106401:	e9 25 f9 ff ff       	jmp    80105d2b <alltraps>

80106406 <vector11>:
.globl vector11
vector11:
  pushl $11
80106406:	6a 0b                	push   $0xb
  jmp alltraps
80106408:	e9 1e f9 ff ff       	jmp    80105d2b <alltraps>

8010640d <vector12>:
.globl vector12
vector12:
  pushl $12
8010640d:	6a 0c                	push   $0xc
  jmp alltraps
8010640f:	e9 17 f9 ff ff       	jmp    80105d2b <alltraps>

80106414 <vector13>:
.globl vector13
vector13:
  pushl $13
80106414:	6a 0d                	push   $0xd
  jmp alltraps
80106416:	e9 10 f9 ff ff       	jmp    80105d2b <alltraps>

8010641b <vector14>:
.globl vector14
vector14:
  pushl $14
8010641b:	6a 0e                	push   $0xe
  jmp alltraps
8010641d:	e9 09 f9 ff ff       	jmp    80105d2b <alltraps>

80106422 <vector15>:
.globl vector15
vector15:
  pushl $0
80106422:	6a 00                	push   $0x0
  pushl $15
80106424:	6a 0f                	push   $0xf
  jmp alltraps
80106426:	e9 00 f9 ff ff       	jmp    80105d2b <alltraps>

8010642b <vector16>:
.globl vector16
vector16:
  pushl $0
8010642b:	6a 00                	push   $0x0
  pushl $16
8010642d:	6a 10                	push   $0x10
  jmp alltraps
8010642f:	e9 f7 f8 ff ff       	jmp    80105d2b <alltraps>

80106434 <vector17>:
.globl vector17
vector17:
  pushl $17
80106434:	6a 11                	push   $0x11
  jmp alltraps
80106436:	e9 f0 f8 ff ff       	jmp    80105d2b <alltraps>

8010643b <vector18>:
.globl vector18
vector18:
  pushl $0
8010643b:	6a 00                	push   $0x0
  pushl $18
8010643d:	6a 12                	push   $0x12
  jmp alltraps
8010643f:	e9 e7 f8 ff ff       	jmp    80105d2b <alltraps>

80106444 <vector19>:
.globl vector19
vector19:
  pushl $0
80106444:	6a 00                	push   $0x0
  pushl $19
80106446:	6a 13                	push   $0x13
  jmp alltraps
80106448:	e9 de f8 ff ff       	jmp    80105d2b <alltraps>

8010644d <vector20>:
.globl vector20
vector20:
  pushl $0
8010644d:	6a 00                	push   $0x0
  pushl $20
8010644f:	6a 14                	push   $0x14
  jmp alltraps
80106451:	e9 d5 f8 ff ff       	jmp    80105d2b <alltraps>

80106456 <vector21>:
.globl vector21
vector21:
  pushl $0
80106456:	6a 00                	push   $0x0
  pushl $21
80106458:	6a 15                	push   $0x15
  jmp alltraps
8010645a:	e9 cc f8 ff ff       	jmp    80105d2b <alltraps>

8010645f <vector22>:
.globl vector22
vector22:
  pushl $0
8010645f:	6a 00                	push   $0x0
  pushl $22
80106461:	6a 16                	push   $0x16
  jmp alltraps
80106463:	e9 c3 f8 ff ff       	jmp    80105d2b <alltraps>

80106468 <vector23>:
.globl vector23
vector23:
  pushl $0
80106468:	6a 00                	push   $0x0
  pushl $23
8010646a:	6a 17                	push   $0x17
  jmp alltraps
8010646c:	e9 ba f8 ff ff       	jmp    80105d2b <alltraps>

80106471 <vector24>:
.globl vector24
vector24:
  pushl $0
80106471:	6a 00                	push   $0x0
  pushl $24
80106473:	6a 18                	push   $0x18
  jmp alltraps
80106475:	e9 b1 f8 ff ff       	jmp    80105d2b <alltraps>

8010647a <vector25>:
.globl vector25
vector25:
  pushl $0
8010647a:	6a 00                	push   $0x0
  pushl $25
8010647c:	6a 19                	push   $0x19
  jmp alltraps
8010647e:	e9 a8 f8 ff ff       	jmp    80105d2b <alltraps>

80106483 <vector26>:
.globl vector26
vector26:
  pushl $0
80106483:	6a 00                	push   $0x0
  pushl $26
80106485:	6a 1a                	push   $0x1a
  jmp alltraps
80106487:	e9 9f f8 ff ff       	jmp    80105d2b <alltraps>

8010648c <vector27>:
.globl vector27
vector27:
  pushl $0
8010648c:	6a 00                	push   $0x0
  pushl $27
8010648e:	6a 1b                	push   $0x1b
  jmp alltraps
80106490:	e9 96 f8 ff ff       	jmp    80105d2b <alltraps>

80106495 <vector28>:
.globl vector28
vector28:
  pushl $0
80106495:	6a 00                	push   $0x0
  pushl $28
80106497:	6a 1c                	push   $0x1c
  jmp alltraps
80106499:	e9 8d f8 ff ff       	jmp    80105d2b <alltraps>

8010649e <vector29>:
.globl vector29
vector29:
  pushl $0
8010649e:	6a 00                	push   $0x0
  pushl $29
801064a0:	6a 1d                	push   $0x1d
  jmp alltraps
801064a2:	e9 84 f8 ff ff       	jmp    80105d2b <alltraps>

801064a7 <vector30>:
.globl vector30
vector30:
  pushl $0
801064a7:	6a 00                	push   $0x0
  pushl $30
801064a9:	6a 1e                	push   $0x1e
  jmp alltraps
801064ab:	e9 7b f8 ff ff       	jmp    80105d2b <alltraps>

801064b0 <vector31>:
.globl vector31
vector31:
  pushl $0
801064b0:	6a 00                	push   $0x0
  pushl $31
801064b2:	6a 1f                	push   $0x1f
  jmp alltraps
801064b4:	e9 72 f8 ff ff       	jmp    80105d2b <alltraps>

801064b9 <vector32>:
.globl vector32
vector32:
  pushl $0
801064b9:	6a 00                	push   $0x0
  pushl $32
801064bb:	6a 20                	push   $0x20
  jmp alltraps
801064bd:	e9 69 f8 ff ff       	jmp    80105d2b <alltraps>

801064c2 <vector33>:
.globl vector33
vector33:
  pushl $0
801064c2:	6a 00                	push   $0x0
  pushl $33
801064c4:	6a 21                	push   $0x21
  jmp alltraps
801064c6:	e9 60 f8 ff ff       	jmp    80105d2b <alltraps>

801064cb <vector34>:
.globl vector34
vector34:
  pushl $0
801064cb:	6a 00                	push   $0x0
  pushl $34
801064cd:	6a 22                	push   $0x22
  jmp alltraps
801064cf:	e9 57 f8 ff ff       	jmp    80105d2b <alltraps>

801064d4 <vector35>:
.globl vector35
vector35:
  pushl $0
801064d4:	6a 00                	push   $0x0
  pushl $35
801064d6:	6a 23                	push   $0x23
  jmp alltraps
801064d8:	e9 4e f8 ff ff       	jmp    80105d2b <alltraps>

801064dd <vector36>:
.globl vector36
vector36:
  pushl $0
801064dd:	6a 00                	push   $0x0
  pushl $36
801064df:	6a 24                	push   $0x24
  jmp alltraps
801064e1:	e9 45 f8 ff ff       	jmp    80105d2b <alltraps>

801064e6 <vector37>:
.globl vector37
vector37:
  pushl $0
801064e6:	6a 00                	push   $0x0
  pushl $37
801064e8:	6a 25                	push   $0x25
  jmp alltraps
801064ea:	e9 3c f8 ff ff       	jmp    80105d2b <alltraps>

801064ef <vector38>:
.globl vector38
vector38:
  pushl $0
801064ef:	6a 00                	push   $0x0
  pushl $38
801064f1:	6a 26                	push   $0x26
  jmp alltraps
801064f3:	e9 33 f8 ff ff       	jmp    80105d2b <alltraps>

801064f8 <vector39>:
.globl vector39
vector39:
  pushl $0
801064f8:	6a 00                	push   $0x0
  pushl $39
801064fa:	6a 27                	push   $0x27
  jmp alltraps
801064fc:	e9 2a f8 ff ff       	jmp    80105d2b <alltraps>

80106501 <vector40>:
.globl vector40
vector40:
  pushl $0
80106501:	6a 00                	push   $0x0
  pushl $40
80106503:	6a 28                	push   $0x28
  jmp alltraps
80106505:	e9 21 f8 ff ff       	jmp    80105d2b <alltraps>

8010650a <vector41>:
.globl vector41
vector41:
  pushl $0
8010650a:	6a 00                	push   $0x0
  pushl $41
8010650c:	6a 29                	push   $0x29
  jmp alltraps
8010650e:	e9 18 f8 ff ff       	jmp    80105d2b <alltraps>

80106513 <vector42>:
.globl vector42
vector42:
  pushl $0
80106513:	6a 00                	push   $0x0
  pushl $42
80106515:	6a 2a                	push   $0x2a
  jmp alltraps
80106517:	e9 0f f8 ff ff       	jmp    80105d2b <alltraps>

8010651c <vector43>:
.globl vector43
vector43:
  pushl $0
8010651c:	6a 00                	push   $0x0
  pushl $43
8010651e:	6a 2b                	push   $0x2b
  jmp alltraps
80106520:	e9 06 f8 ff ff       	jmp    80105d2b <alltraps>

80106525 <vector44>:
.globl vector44
vector44:
  pushl $0
80106525:	6a 00                	push   $0x0
  pushl $44
80106527:	6a 2c                	push   $0x2c
  jmp alltraps
80106529:	e9 fd f7 ff ff       	jmp    80105d2b <alltraps>

8010652e <vector45>:
.globl vector45
vector45:
  pushl $0
8010652e:	6a 00                	push   $0x0
  pushl $45
80106530:	6a 2d                	push   $0x2d
  jmp alltraps
80106532:	e9 f4 f7 ff ff       	jmp    80105d2b <alltraps>

80106537 <vector46>:
.globl vector46
vector46:
  pushl $0
80106537:	6a 00                	push   $0x0
  pushl $46
80106539:	6a 2e                	push   $0x2e
  jmp alltraps
8010653b:	e9 eb f7 ff ff       	jmp    80105d2b <alltraps>

80106540 <vector47>:
.globl vector47
vector47:
  pushl $0
80106540:	6a 00                	push   $0x0
  pushl $47
80106542:	6a 2f                	push   $0x2f
  jmp alltraps
80106544:	e9 e2 f7 ff ff       	jmp    80105d2b <alltraps>

80106549 <vector48>:
.globl vector48
vector48:
  pushl $0
80106549:	6a 00                	push   $0x0
  pushl $48
8010654b:	6a 30                	push   $0x30
  jmp alltraps
8010654d:	e9 d9 f7 ff ff       	jmp    80105d2b <alltraps>

80106552 <vector49>:
.globl vector49
vector49:
  pushl $0
80106552:	6a 00                	push   $0x0
  pushl $49
80106554:	6a 31                	push   $0x31
  jmp alltraps
80106556:	e9 d0 f7 ff ff       	jmp    80105d2b <alltraps>

8010655b <vector50>:
.globl vector50
vector50:
  pushl $0
8010655b:	6a 00                	push   $0x0
  pushl $50
8010655d:	6a 32                	push   $0x32
  jmp alltraps
8010655f:	e9 c7 f7 ff ff       	jmp    80105d2b <alltraps>

80106564 <vector51>:
.globl vector51
vector51:
  pushl $0
80106564:	6a 00                	push   $0x0
  pushl $51
80106566:	6a 33                	push   $0x33
  jmp alltraps
80106568:	e9 be f7 ff ff       	jmp    80105d2b <alltraps>

8010656d <vector52>:
.globl vector52
vector52:
  pushl $0
8010656d:	6a 00                	push   $0x0
  pushl $52
8010656f:	6a 34                	push   $0x34
  jmp alltraps
80106571:	e9 b5 f7 ff ff       	jmp    80105d2b <alltraps>

80106576 <vector53>:
.globl vector53
vector53:
  pushl $0
80106576:	6a 00                	push   $0x0
  pushl $53
80106578:	6a 35                	push   $0x35
  jmp alltraps
8010657a:	e9 ac f7 ff ff       	jmp    80105d2b <alltraps>

8010657f <vector54>:
.globl vector54
vector54:
  pushl $0
8010657f:	6a 00                	push   $0x0
  pushl $54
80106581:	6a 36                	push   $0x36
  jmp alltraps
80106583:	e9 a3 f7 ff ff       	jmp    80105d2b <alltraps>

80106588 <vector55>:
.globl vector55
vector55:
  pushl $0
80106588:	6a 00                	push   $0x0
  pushl $55
8010658a:	6a 37                	push   $0x37
  jmp alltraps
8010658c:	e9 9a f7 ff ff       	jmp    80105d2b <alltraps>

80106591 <vector56>:
.globl vector56
vector56:
  pushl $0
80106591:	6a 00                	push   $0x0
  pushl $56
80106593:	6a 38                	push   $0x38
  jmp alltraps
80106595:	e9 91 f7 ff ff       	jmp    80105d2b <alltraps>

8010659a <vector57>:
.globl vector57
vector57:
  pushl $0
8010659a:	6a 00                	push   $0x0
  pushl $57
8010659c:	6a 39                	push   $0x39
  jmp alltraps
8010659e:	e9 88 f7 ff ff       	jmp    80105d2b <alltraps>

801065a3 <vector58>:
.globl vector58
vector58:
  pushl $0
801065a3:	6a 00                	push   $0x0
  pushl $58
801065a5:	6a 3a                	push   $0x3a
  jmp alltraps
801065a7:	e9 7f f7 ff ff       	jmp    80105d2b <alltraps>

801065ac <vector59>:
.globl vector59
vector59:
  pushl $0
801065ac:	6a 00                	push   $0x0
  pushl $59
801065ae:	6a 3b                	push   $0x3b
  jmp alltraps
801065b0:	e9 76 f7 ff ff       	jmp    80105d2b <alltraps>

801065b5 <vector60>:
.globl vector60
vector60:
  pushl $0
801065b5:	6a 00                	push   $0x0
  pushl $60
801065b7:	6a 3c                	push   $0x3c
  jmp alltraps
801065b9:	e9 6d f7 ff ff       	jmp    80105d2b <alltraps>

801065be <vector61>:
.globl vector61
vector61:
  pushl $0
801065be:	6a 00                	push   $0x0
  pushl $61
801065c0:	6a 3d                	push   $0x3d
  jmp alltraps
801065c2:	e9 64 f7 ff ff       	jmp    80105d2b <alltraps>

801065c7 <vector62>:
.globl vector62
vector62:
  pushl $0
801065c7:	6a 00                	push   $0x0
  pushl $62
801065c9:	6a 3e                	push   $0x3e
  jmp alltraps
801065cb:	e9 5b f7 ff ff       	jmp    80105d2b <alltraps>

801065d0 <vector63>:
.globl vector63
vector63:
  pushl $0
801065d0:	6a 00                	push   $0x0
  pushl $63
801065d2:	6a 3f                	push   $0x3f
  jmp alltraps
801065d4:	e9 52 f7 ff ff       	jmp    80105d2b <alltraps>

801065d9 <vector64>:
.globl vector64
vector64:
  pushl $0
801065d9:	6a 00                	push   $0x0
  pushl $64
801065db:	6a 40                	push   $0x40
  jmp alltraps
801065dd:	e9 49 f7 ff ff       	jmp    80105d2b <alltraps>

801065e2 <vector65>:
.globl vector65
vector65:
  pushl $0
801065e2:	6a 00                	push   $0x0
  pushl $65
801065e4:	6a 41                	push   $0x41
  jmp alltraps
801065e6:	e9 40 f7 ff ff       	jmp    80105d2b <alltraps>

801065eb <vector66>:
.globl vector66
vector66:
  pushl $0
801065eb:	6a 00                	push   $0x0
  pushl $66
801065ed:	6a 42                	push   $0x42
  jmp alltraps
801065ef:	e9 37 f7 ff ff       	jmp    80105d2b <alltraps>

801065f4 <vector67>:
.globl vector67
vector67:
  pushl $0
801065f4:	6a 00                	push   $0x0
  pushl $67
801065f6:	6a 43                	push   $0x43
  jmp alltraps
801065f8:	e9 2e f7 ff ff       	jmp    80105d2b <alltraps>

801065fd <vector68>:
.globl vector68
vector68:
  pushl $0
801065fd:	6a 00                	push   $0x0
  pushl $68
801065ff:	6a 44                	push   $0x44
  jmp alltraps
80106601:	e9 25 f7 ff ff       	jmp    80105d2b <alltraps>

80106606 <vector69>:
.globl vector69
vector69:
  pushl $0
80106606:	6a 00                	push   $0x0
  pushl $69
80106608:	6a 45                	push   $0x45
  jmp alltraps
8010660a:	e9 1c f7 ff ff       	jmp    80105d2b <alltraps>

8010660f <vector70>:
.globl vector70
vector70:
  pushl $0
8010660f:	6a 00                	push   $0x0
  pushl $70
80106611:	6a 46                	push   $0x46
  jmp alltraps
80106613:	e9 13 f7 ff ff       	jmp    80105d2b <alltraps>

80106618 <vector71>:
.globl vector71
vector71:
  pushl $0
80106618:	6a 00                	push   $0x0
  pushl $71
8010661a:	6a 47                	push   $0x47
  jmp alltraps
8010661c:	e9 0a f7 ff ff       	jmp    80105d2b <alltraps>

80106621 <vector72>:
.globl vector72
vector72:
  pushl $0
80106621:	6a 00                	push   $0x0
  pushl $72
80106623:	6a 48                	push   $0x48
  jmp alltraps
80106625:	e9 01 f7 ff ff       	jmp    80105d2b <alltraps>

8010662a <vector73>:
.globl vector73
vector73:
  pushl $0
8010662a:	6a 00                	push   $0x0
  pushl $73
8010662c:	6a 49                	push   $0x49
  jmp alltraps
8010662e:	e9 f8 f6 ff ff       	jmp    80105d2b <alltraps>

80106633 <vector74>:
.globl vector74
vector74:
  pushl $0
80106633:	6a 00                	push   $0x0
  pushl $74
80106635:	6a 4a                	push   $0x4a
  jmp alltraps
80106637:	e9 ef f6 ff ff       	jmp    80105d2b <alltraps>

8010663c <vector75>:
.globl vector75
vector75:
  pushl $0
8010663c:	6a 00                	push   $0x0
  pushl $75
8010663e:	6a 4b                	push   $0x4b
  jmp alltraps
80106640:	e9 e6 f6 ff ff       	jmp    80105d2b <alltraps>

80106645 <vector76>:
.globl vector76
vector76:
  pushl $0
80106645:	6a 00                	push   $0x0
  pushl $76
80106647:	6a 4c                	push   $0x4c
  jmp alltraps
80106649:	e9 dd f6 ff ff       	jmp    80105d2b <alltraps>

8010664e <vector77>:
.globl vector77
vector77:
  pushl $0
8010664e:	6a 00                	push   $0x0
  pushl $77
80106650:	6a 4d                	push   $0x4d
  jmp alltraps
80106652:	e9 d4 f6 ff ff       	jmp    80105d2b <alltraps>

80106657 <vector78>:
.globl vector78
vector78:
  pushl $0
80106657:	6a 00                	push   $0x0
  pushl $78
80106659:	6a 4e                	push   $0x4e
  jmp alltraps
8010665b:	e9 cb f6 ff ff       	jmp    80105d2b <alltraps>

80106660 <vector79>:
.globl vector79
vector79:
  pushl $0
80106660:	6a 00                	push   $0x0
  pushl $79
80106662:	6a 4f                	push   $0x4f
  jmp alltraps
80106664:	e9 c2 f6 ff ff       	jmp    80105d2b <alltraps>

80106669 <vector80>:
.globl vector80
vector80:
  pushl $0
80106669:	6a 00                	push   $0x0
  pushl $80
8010666b:	6a 50                	push   $0x50
  jmp alltraps
8010666d:	e9 b9 f6 ff ff       	jmp    80105d2b <alltraps>

80106672 <vector81>:
.globl vector81
vector81:
  pushl $0
80106672:	6a 00                	push   $0x0
  pushl $81
80106674:	6a 51                	push   $0x51
  jmp alltraps
80106676:	e9 b0 f6 ff ff       	jmp    80105d2b <alltraps>

8010667b <vector82>:
.globl vector82
vector82:
  pushl $0
8010667b:	6a 00                	push   $0x0
  pushl $82
8010667d:	6a 52                	push   $0x52
  jmp alltraps
8010667f:	e9 a7 f6 ff ff       	jmp    80105d2b <alltraps>

80106684 <vector83>:
.globl vector83
vector83:
  pushl $0
80106684:	6a 00                	push   $0x0
  pushl $83
80106686:	6a 53                	push   $0x53
  jmp alltraps
80106688:	e9 9e f6 ff ff       	jmp    80105d2b <alltraps>

8010668d <vector84>:
.globl vector84
vector84:
  pushl $0
8010668d:	6a 00                	push   $0x0
  pushl $84
8010668f:	6a 54                	push   $0x54
  jmp alltraps
80106691:	e9 95 f6 ff ff       	jmp    80105d2b <alltraps>

80106696 <vector85>:
.globl vector85
vector85:
  pushl $0
80106696:	6a 00                	push   $0x0
  pushl $85
80106698:	6a 55                	push   $0x55
  jmp alltraps
8010669a:	e9 8c f6 ff ff       	jmp    80105d2b <alltraps>

8010669f <vector86>:
.globl vector86
vector86:
  pushl $0
8010669f:	6a 00                	push   $0x0
  pushl $86
801066a1:	6a 56                	push   $0x56
  jmp alltraps
801066a3:	e9 83 f6 ff ff       	jmp    80105d2b <alltraps>

801066a8 <vector87>:
.globl vector87
vector87:
  pushl $0
801066a8:	6a 00                	push   $0x0
  pushl $87
801066aa:	6a 57                	push   $0x57
  jmp alltraps
801066ac:	e9 7a f6 ff ff       	jmp    80105d2b <alltraps>

801066b1 <vector88>:
.globl vector88
vector88:
  pushl $0
801066b1:	6a 00                	push   $0x0
  pushl $88
801066b3:	6a 58                	push   $0x58
  jmp alltraps
801066b5:	e9 71 f6 ff ff       	jmp    80105d2b <alltraps>

801066ba <vector89>:
.globl vector89
vector89:
  pushl $0
801066ba:	6a 00                	push   $0x0
  pushl $89
801066bc:	6a 59                	push   $0x59
  jmp alltraps
801066be:	e9 68 f6 ff ff       	jmp    80105d2b <alltraps>

801066c3 <vector90>:
.globl vector90
vector90:
  pushl $0
801066c3:	6a 00                	push   $0x0
  pushl $90
801066c5:	6a 5a                	push   $0x5a
  jmp alltraps
801066c7:	e9 5f f6 ff ff       	jmp    80105d2b <alltraps>

801066cc <vector91>:
.globl vector91
vector91:
  pushl $0
801066cc:	6a 00                	push   $0x0
  pushl $91
801066ce:	6a 5b                	push   $0x5b
  jmp alltraps
801066d0:	e9 56 f6 ff ff       	jmp    80105d2b <alltraps>

801066d5 <vector92>:
.globl vector92
vector92:
  pushl $0
801066d5:	6a 00                	push   $0x0
  pushl $92
801066d7:	6a 5c                	push   $0x5c
  jmp alltraps
801066d9:	e9 4d f6 ff ff       	jmp    80105d2b <alltraps>

801066de <vector93>:
.globl vector93
vector93:
  pushl $0
801066de:	6a 00                	push   $0x0
  pushl $93
801066e0:	6a 5d                	push   $0x5d
  jmp alltraps
801066e2:	e9 44 f6 ff ff       	jmp    80105d2b <alltraps>

801066e7 <vector94>:
.globl vector94
vector94:
  pushl $0
801066e7:	6a 00                	push   $0x0
  pushl $94
801066e9:	6a 5e                	push   $0x5e
  jmp alltraps
801066eb:	e9 3b f6 ff ff       	jmp    80105d2b <alltraps>

801066f0 <vector95>:
.globl vector95
vector95:
  pushl $0
801066f0:	6a 00                	push   $0x0
  pushl $95
801066f2:	6a 5f                	push   $0x5f
  jmp alltraps
801066f4:	e9 32 f6 ff ff       	jmp    80105d2b <alltraps>

801066f9 <vector96>:
.globl vector96
vector96:
  pushl $0
801066f9:	6a 00                	push   $0x0
  pushl $96
801066fb:	6a 60                	push   $0x60
  jmp alltraps
801066fd:	e9 29 f6 ff ff       	jmp    80105d2b <alltraps>

80106702 <vector97>:
.globl vector97
vector97:
  pushl $0
80106702:	6a 00                	push   $0x0
  pushl $97
80106704:	6a 61                	push   $0x61
  jmp alltraps
80106706:	e9 20 f6 ff ff       	jmp    80105d2b <alltraps>

8010670b <vector98>:
.globl vector98
vector98:
  pushl $0
8010670b:	6a 00                	push   $0x0
  pushl $98
8010670d:	6a 62                	push   $0x62
  jmp alltraps
8010670f:	e9 17 f6 ff ff       	jmp    80105d2b <alltraps>

80106714 <vector99>:
.globl vector99
vector99:
  pushl $0
80106714:	6a 00                	push   $0x0
  pushl $99
80106716:	6a 63                	push   $0x63
  jmp alltraps
80106718:	e9 0e f6 ff ff       	jmp    80105d2b <alltraps>

8010671d <vector100>:
.globl vector100
vector100:
  pushl $0
8010671d:	6a 00                	push   $0x0
  pushl $100
8010671f:	6a 64                	push   $0x64
  jmp alltraps
80106721:	e9 05 f6 ff ff       	jmp    80105d2b <alltraps>

80106726 <vector101>:
.globl vector101
vector101:
  pushl $0
80106726:	6a 00                	push   $0x0
  pushl $101
80106728:	6a 65                	push   $0x65
  jmp alltraps
8010672a:	e9 fc f5 ff ff       	jmp    80105d2b <alltraps>

8010672f <vector102>:
.globl vector102
vector102:
  pushl $0
8010672f:	6a 00                	push   $0x0
  pushl $102
80106731:	6a 66                	push   $0x66
  jmp alltraps
80106733:	e9 f3 f5 ff ff       	jmp    80105d2b <alltraps>

80106738 <vector103>:
.globl vector103
vector103:
  pushl $0
80106738:	6a 00                	push   $0x0
  pushl $103
8010673a:	6a 67                	push   $0x67
  jmp alltraps
8010673c:	e9 ea f5 ff ff       	jmp    80105d2b <alltraps>

80106741 <vector104>:
.globl vector104
vector104:
  pushl $0
80106741:	6a 00                	push   $0x0
  pushl $104
80106743:	6a 68                	push   $0x68
  jmp alltraps
80106745:	e9 e1 f5 ff ff       	jmp    80105d2b <alltraps>

8010674a <vector105>:
.globl vector105
vector105:
  pushl $0
8010674a:	6a 00                	push   $0x0
  pushl $105
8010674c:	6a 69                	push   $0x69
  jmp alltraps
8010674e:	e9 d8 f5 ff ff       	jmp    80105d2b <alltraps>

80106753 <vector106>:
.globl vector106
vector106:
  pushl $0
80106753:	6a 00                	push   $0x0
  pushl $106
80106755:	6a 6a                	push   $0x6a
  jmp alltraps
80106757:	e9 cf f5 ff ff       	jmp    80105d2b <alltraps>

8010675c <vector107>:
.globl vector107
vector107:
  pushl $0
8010675c:	6a 00                	push   $0x0
  pushl $107
8010675e:	6a 6b                	push   $0x6b
  jmp alltraps
80106760:	e9 c6 f5 ff ff       	jmp    80105d2b <alltraps>

80106765 <vector108>:
.globl vector108
vector108:
  pushl $0
80106765:	6a 00                	push   $0x0
  pushl $108
80106767:	6a 6c                	push   $0x6c
  jmp alltraps
80106769:	e9 bd f5 ff ff       	jmp    80105d2b <alltraps>

8010676e <vector109>:
.globl vector109
vector109:
  pushl $0
8010676e:	6a 00                	push   $0x0
  pushl $109
80106770:	6a 6d                	push   $0x6d
  jmp alltraps
80106772:	e9 b4 f5 ff ff       	jmp    80105d2b <alltraps>

80106777 <vector110>:
.globl vector110
vector110:
  pushl $0
80106777:	6a 00                	push   $0x0
  pushl $110
80106779:	6a 6e                	push   $0x6e
  jmp alltraps
8010677b:	e9 ab f5 ff ff       	jmp    80105d2b <alltraps>

80106780 <vector111>:
.globl vector111
vector111:
  pushl $0
80106780:	6a 00                	push   $0x0
  pushl $111
80106782:	6a 6f                	push   $0x6f
  jmp alltraps
80106784:	e9 a2 f5 ff ff       	jmp    80105d2b <alltraps>

80106789 <vector112>:
.globl vector112
vector112:
  pushl $0
80106789:	6a 00                	push   $0x0
  pushl $112
8010678b:	6a 70                	push   $0x70
  jmp alltraps
8010678d:	e9 99 f5 ff ff       	jmp    80105d2b <alltraps>

80106792 <vector113>:
.globl vector113
vector113:
  pushl $0
80106792:	6a 00                	push   $0x0
  pushl $113
80106794:	6a 71                	push   $0x71
  jmp alltraps
80106796:	e9 90 f5 ff ff       	jmp    80105d2b <alltraps>

8010679b <vector114>:
.globl vector114
vector114:
  pushl $0
8010679b:	6a 00                	push   $0x0
  pushl $114
8010679d:	6a 72                	push   $0x72
  jmp alltraps
8010679f:	e9 87 f5 ff ff       	jmp    80105d2b <alltraps>

801067a4 <vector115>:
.globl vector115
vector115:
  pushl $0
801067a4:	6a 00                	push   $0x0
  pushl $115
801067a6:	6a 73                	push   $0x73
  jmp alltraps
801067a8:	e9 7e f5 ff ff       	jmp    80105d2b <alltraps>

801067ad <vector116>:
.globl vector116
vector116:
  pushl $0
801067ad:	6a 00                	push   $0x0
  pushl $116
801067af:	6a 74                	push   $0x74
  jmp alltraps
801067b1:	e9 75 f5 ff ff       	jmp    80105d2b <alltraps>

801067b6 <vector117>:
.globl vector117
vector117:
  pushl $0
801067b6:	6a 00                	push   $0x0
  pushl $117
801067b8:	6a 75                	push   $0x75
  jmp alltraps
801067ba:	e9 6c f5 ff ff       	jmp    80105d2b <alltraps>

801067bf <vector118>:
.globl vector118
vector118:
  pushl $0
801067bf:	6a 00                	push   $0x0
  pushl $118
801067c1:	6a 76                	push   $0x76
  jmp alltraps
801067c3:	e9 63 f5 ff ff       	jmp    80105d2b <alltraps>

801067c8 <vector119>:
.globl vector119
vector119:
  pushl $0
801067c8:	6a 00                	push   $0x0
  pushl $119
801067ca:	6a 77                	push   $0x77
  jmp alltraps
801067cc:	e9 5a f5 ff ff       	jmp    80105d2b <alltraps>

801067d1 <vector120>:
.globl vector120
vector120:
  pushl $0
801067d1:	6a 00                	push   $0x0
  pushl $120
801067d3:	6a 78                	push   $0x78
  jmp alltraps
801067d5:	e9 51 f5 ff ff       	jmp    80105d2b <alltraps>

801067da <vector121>:
.globl vector121
vector121:
  pushl $0
801067da:	6a 00                	push   $0x0
  pushl $121
801067dc:	6a 79                	push   $0x79
  jmp alltraps
801067de:	e9 48 f5 ff ff       	jmp    80105d2b <alltraps>

801067e3 <vector122>:
.globl vector122
vector122:
  pushl $0
801067e3:	6a 00                	push   $0x0
  pushl $122
801067e5:	6a 7a                	push   $0x7a
  jmp alltraps
801067e7:	e9 3f f5 ff ff       	jmp    80105d2b <alltraps>

801067ec <vector123>:
.globl vector123
vector123:
  pushl $0
801067ec:	6a 00                	push   $0x0
  pushl $123
801067ee:	6a 7b                	push   $0x7b
  jmp alltraps
801067f0:	e9 36 f5 ff ff       	jmp    80105d2b <alltraps>

801067f5 <vector124>:
.globl vector124
vector124:
  pushl $0
801067f5:	6a 00                	push   $0x0
  pushl $124
801067f7:	6a 7c                	push   $0x7c
  jmp alltraps
801067f9:	e9 2d f5 ff ff       	jmp    80105d2b <alltraps>

801067fe <vector125>:
.globl vector125
vector125:
  pushl $0
801067fe:	6a 00                	push   $0x0
  pushl $125
80106800:	6a 7d                	push   $0x7d
  jmp alltraps
80106802:	e9 24 f5 ff ff       	jmp    80105d2b <alltraps>

80106807 <vector126>:
.globl vector126
vector126:
  pushl $0
80106807:	6a 00                	push   $0x0
  pushl $126
80106809:	6a 7e                	push   $0x7e
  jmp alltraps
8010680b:	e9 1b f5 ff ff       	jmp    80105d2b <alltraps>

80106810 <vector127>:
.globl vector127
vector127:
  pushl $0
80106810:	6a 00                	push   $0x0
  pushl $127
80106812:	6a 7f                	push   $0x7f
  jmp alltraps
80106814:	e9 12 f5 ff ff       	jmp    80105d2b <alltraps>

80106819 <vector128>:
.globl vector128
vector128:
  pushl $0
80106819:	6a 00                	push   $0x0
  pushl $128
8010681b:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106820:	e9 06 f5 ff ff       	jmp    80105d2b <alltraps>

80106825 <vector129>:
.globl vector129
vector129:
  pushl $0
80106825:	6a 00                	push   $0x0
  pushl $129
80106827:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010682c:	e9 fa f4 ff ff       	jmp    80105d2b <alltraps>

80106831 <vector130>:
.globl vector130
vector130:
  pushl $0
80106831:	6a 00                	push   $0x0
  pushl $130
80106833:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106838:	e9 ee f4 ff ff       	jmp    80105d2b <alltraps>

8010683d <vector131>:
.globl vector131
vector131:
  pushl $0
8010683d:	6a 00                	push   $0x0
  pushl $131
8010683f:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106844:	e9 e2 f4 ff ff       	jmp    80105d2b <alltraps>

80106849 <vector132>:
.globl vector132
vector132:
  pushl $0
80106849:	6a 00                	push   $0x0
  pushl $132
8010684b:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106850:	e9 d6 f4 ff ff       	jmp    80105d2b <alltraps>

80106855 <vector133>:
.globl vector133
vector133:
  pushl $0
80106855:	6a 00                	push   $0x0
  pushl $133
80106857:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010685c:	e9 ca f4 ff ff       	jmp    80105d2b <alltraps>

80106861 <vector134>:
.globl vector134
vector134:
  pushl $0
80106861:	6a 00                	push   $0x0
  pushl $134
80106863:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106868:	e9 be f4 ff ff       	jmp    80105d2b <alltraps>

8010686d <vector135>:
.globl vector135
vector135:
  pushl $0
8010686d:	6a 00                	push   $0x0
  pushl $135
8010686f:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106874:	e9 b2 f4 ff ff       	jmp    80105d2b <alltraps>

80106879 <vector136>:
.globl vector136
vector136:
  pushl $0
80106879:	6a 00                	push   $0x0
  pushl $136
8010687b:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106880:	e9 a6 f4 ff ff       	jmp    80105d2b <alltraps>

80106885 <vector137>:
.globl vector137
vector137:
  pushl $0
80106885:	6a 00                	push   $0x0
  pushl $137
80106887:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010688c:	e9 9a f4 ff ff       	jmp    80105d2b <alltraps>

80106891 <vector138>:
.globl vector138
vector138:
  pushl $0
80106891:	6a 00                	push   $0x0
  pushl $138
80106893:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106898:	e9 8e f4 ff ff       	jmp    80105d2b <alltraps>

8010689d <vector139>:
.globl vector139
vector139:
  pushl $0
8010689d:	6a 00                	push   $0x0
  pushl $139
8010689f:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801068a4:	e9 82 f4 ff ff       	jmp    80105d2b <alltraps>

801068a9 <vector140>:
.globl vector140
vector140:
  pushl $0
801068a9:	6a 00                	push   $0x0
  pushl $140
801068ab:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801068b0:	e9 76 f4 ff ff       	jmp    80105d2b <alltraps>

801068b5 <vector141>:
.globl vector141
vector141:
  pushl $0
801068b5:	6a 00                	push   $0x0
  pushl $141
801068b7:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801068bc:	e9 6a f4 ff ff       	jmp    80105d2b <alltraps>

801068c1 <vector142>:
.globl vector142
vector142:
  pushl $0
801068c1:	6a 00                	push   $0x0
  pushl $142
801068c3:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801068c8:	e9 5e f4 ff ff       	jmp    80105d2b <alltraps>

801068cd <vector143>:
.globl vector143
vector143:
  pushl $0
801068cd:	6a 00                	push   $0x0
  pushl $143
801068cf:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801068d4:	e9 52 f4 ff ff       	jmp    80105d2b <alltraps>

801068d9 <vector144>:
.globl vector144
vector144:
  pushl $0
801068d9:	6a 00                	push   $0x0
  pushl $144
801068db:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801068e0:	e9 46 f4 ff ff       	jmp    80105d2b <alltraps>

801068e5 <vector145>:
.globl vector145
vector145:
  pushl $0
801068e5:	6a 00                	push   $0x0
  pushl $145
801068e7:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801068ec:	e9 3a f4 ff ff       	jmp    80105d2b <alltraps>

801068f1 <vector146>:
.globl vector146
vector146:
  pushl $0
801068f1:	6a 00                	push   $0x0
  pushl $146
801068f3:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801068f8:	e9 2e f4 ff ff       	jmp    80105d2b <alltraps>

801068fd <vector147>:
.globl vector147
vector147:
  pushl $0
801068fd:	6a 00                	push   $0x0
  pushl $147
801068ff:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106904:	e9 22 f4 ff ff       	jmp    80105d2b <alltraps>

80106909 <vector148>:
.globl vector148
vector148:
  pushl $0
80106909:	6a 00                	push   $0x0
  pushl $148
8010690b:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106910:	e9 16 f4 ff ff       	jmp    80105d2b <alltraps>

80106915 <vector149>:
.globl vector149
vector149:
  pushl $0
80106915:	6a 00                	push   $0x0
  pushl $149
80106917:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010691c:	e9 0a f4 ff ff       	jmp    80105d2b <alltraps>

80106921 <vector150>:
.globl vector150
vector150:
  pushl $0
80106921:	6a 00                	push   $0x0
  pushl $150
80106923:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106928:	e9 fe f3 ff ff       	jmp    80105d2b <alltraps>

8010692d <vector151>:
.globl vector151
vector151:
  pushl $0
8010692d:	6a 00                	push   $0x0
  pushl $151
8010692f:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106934:	e9 f2 f3 ff ff       	jmp    80105d2b <alltraps>

80106939 <vector152>:
.globl vector152
vector152:
  pushl $0
80106939:	6a 00                	push   $0x0
  pushl $152
8010693b:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106940:	e9 e6 f3 ff ff       	jmp    80105d2b <alltraps>

80106945 <vector153>:
.globl vector153
vector153:
  pushl $0
80106945:	6a 00                	push   $0x0
  pushl $153
80106947:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010694c:	e9 da f3 ff ff       	jmp    80105d2b <alltraps>

80106951 <vector154>:
.globl vector154
vector154:
  pushl $0
80106951:	6a 00                	push   $0x0
  pushl $154
80106953:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106958:	e9 ce f3 ff ff       	jmp    80105d2b <alltraps>

8010695d <vector155>:
.globl vector155
vector155:
  pushl $0
8010695d:	6a 00                	push   $0x0
  pushl $155
8010695f:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106964:	e9 c2 f3 ff ff       	jmp    80105d2b <alltraps>

80106969 <vector156>:
.globl vector156
vector156:
  pushl $0
80106969:	6a 00                	push   $0x0
  pushl $156
8010696b:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106970:	e9 b6 f3 ff ff       	jmp    80105d2b <alltraps>

80106975 <vector157>:
.globl vector157
vector157:
  pushl $0
80106975:	6a 00                	push   $0x0
  pushl $157
80106977:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010697c:	e9 aa f3 ff ff       	jmp    80105d2b <alltraps>

80106981 <vector158>:
.globl vector158
vector158:
  pushl $0
80106981:	6a 00                	push   $0x0
  pushl $158
80106983:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106988:	e9 9e f3 ff ff       	jmp    80105d2b <alltraps>

8010698d <vector159>:
.globl vector159
vector159:
  pushl $0
8010698d:	6a 00                	push   $0x0
  pushl $159
8010698f:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106994:	e9 92 f3 ff ff       	jmp    80105d2b <alltraps>

80106999 <vector160>:
.globl vector160
vector160:
  pushl $0
80106999:	6a 00                	push   $0x0
  pushl $160
8010699b:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801069a0:	e9 86 f3 ff ff       	jmp    80105d2b <alltraps>

801069a5 <vector161>:
.globl vector161
vector161:
  pushl $0
801069a5:	6a 00                	push   $0x0
  pushl $161
801069a7:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801069ac:	e9 7a f3 ff ff       	jmp    80105d2b <alltraps>

801069b1 <vector162>:
.globl vector162
vector162:
  pushl $0
801069b1:	6a 00                	push   $0x0
  pushl $162
801069b3:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801069b8:	e9 6e f3 ff ff       	jmp    80105d2b <alltraps>

801069bd <vector163>:
.globl vector163
vector163:
  pushl $0
801069bd:	6a 00                	push   $0x0
  pushl $163
801069bf:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801069c4:	e9 62 f3 ff ff       	jmp    80105d2b <alltraps>

801069c9 <vector164>:
.globl vector164
vector164:
  pushl $0
801069c9:	6a 00                	push   $0x0
  pushl $164
801069cb:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801069d0:	e9 56 f3 ff ff       	jmp    80105d2b <alltraps>

801069d5 <vector165>:
.globl vector165
vector165:
  pushl $0
801069d5:	6a 00                	push   $0x0
  pushl $165
801069d7:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801069dc:	e9 4a f3 ff ff       	jmp    80105d2b <alltraps>

801069e1 <vector166>:
.globl vector166
vector166:
  pushl $0
801069e1:	6a 00                	push   $0x0
  pushl $166
801069e3:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801069e8:	e9 3e f3 ff ff       	jmp    80105d2b <alltraps>

801069ed <vector167>:
.globl vector167
vector167:
  pushl $0
801069ed:	6a 00                	push   $0x0
  pushl $167
801069ef:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801069f4:	e9 32 f3 ff ff       	jmp    80105d2b <alltraps>

801069f9 <vector168>:
.globl vector168
vector168:
  pushl $0
801069f9:	6a 00                	push   $0x0
  pushl $168
801069fb:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106a00:	e9 26 f3 ff ff       	jmp    80105d2b <alltraps>

80106a05 <vector169>:
.globl vector169
vector169:
  pushl $0
80106a05:	6a 00                	push   $0x0
  pushl $169
80106a07:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106a0c:	e9 1a f3 ff ff       	jmp    80105d2b <alltraps>

80106a11 <vector170>:
.globl vector170
vector170:
  pushl $0
80106a11:	6a 00                	push   $0x0
  pushl $170
80106a13:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106a18:	e9 0e f3 ff ff       	jmp    80105d2b <alltraps>

80106a1d <vector171>:
.globl vector171
vector171:
  pushl $0
80106a1d:	6a 00                	push   $0x0
  pushl $171
80106a1f:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106a24:	e9 02 f3 ff ff       	jmp    80105d2b <alltraps>

80106a29 <vector172>:
.globl vector172
vector172:
  pushl $0
80106a29:	6a 00                	push   $0x0
  pushl $172
80106a2b:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106a30:	e9 f6 f2 ff ff       	jmp    80105d2b <alltraps>

80106a35 <vector173>:
.globl vector173
vector173:
  pushl $0
80106a35:	6a 00                	push   $0x0
  pushl $173
80106a37:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106a3c:	e9 ea f2 ff ff       	jmp    80105d2b <alltraps>

80106a41 <vector174>:
.globl vector174
vector174:
  pushl $0
80106a41:	6a 00                	push   $0x0
  pushl $174
80106a43:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106a48:	e9 de f2 ff ff       	jmp    80105d2b <alltraps>

80106a4d <vector175>:
.globl vector175
vector175:
  pushl $0
80106a4d:	6a 00                	push   $0x0
  pushl $175
80106a4f:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106a54:	e9 d2 f2 ff ff       	jmp    80105d2b <alltraps>

80106a59 <vector176>:
.globl vector176
vector176:
  pushl $0
80106a59:	6a 00                	push   $0x0
  pushl $176
80106a5b:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106a60:	e9 c6 f2 ff ff       	jmp    80105d2b <alltraps>

80106a65 <vector177>:
.globl vector177
vector177:
  pushl $0
80106a65:	6a 00                	push   $0x0
  pushl $177
80106a67:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106a6c:	e9 ba f2 ff ff       	jmp    80105d2b <alltraps>

80106a71 <vector178>:
.globl vector178
vector178:
  pushl $0
80106a71:	6a 00                	push   $0x0
  pushl $178
80106a73:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106a78:	e9 ae f2 ff ff       	jmp    80105d2b <alltraps>

80106a7d <vector179>:
.globl vector179
vector179:
  pushl $0
80106a7d:	6a 00                	push   $0x0
  pushl $179
80106a7f:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106a84:	e9 a2 f2 ff ff       	jmp    80105d2b <alltraps>

80106a89 <vector180>:
.globl vector180
vector180:
  pushl $0
80106a89:	6a 00                	push   $0x0
  pushl $180
80106a8b:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106a90:	e9 96 f2 ff ff       	jmp    80105d2b <alltraps>

80106a95 <vector181>:
.globl vector181
vector181:
  pushl $0
80106a95:	6a 00                	push   $0x0
  pushl $181
80106a97:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106a9c:	e9 8a f2 ff ff       	jmp    80105d2b <alltraps>

80106aa1 <vector182>:
.globl vector182
vector182:
  pushl $0
80106aa1:	6a 00                	push   $0x0
  pushl $182
80106aa3:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106aa8:	e9 7e f2 ff ff       	jmp    80105d2b <alltraps>

80106aad <vector183>:
.globl vector183
vector183:
  pushl $0
80106aad:	6a 00                	push   $0x0
  pushl $183
80106aaf:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106ab4:	e9 72 f2 ff ff       	jmp    80105d2b <alltraps>

80106ab9 <vector184>:
.globl vector184
vector184:
  pushl $0
80106ab9:	6a 00                	push   $0x0
  pushl $184
80106abb:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106ac0:	e9 66 f2 ff ff       	jmp    80105d2b <alltraps>

80106ac5 <vector185>:
.globl vector185
vector185:
  pushl $0
80106ac5:	6a 00                	push   $0x0
  pushl $185
80106ac7:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106acc:	e9 5a f2 ff ff       	jmp    80105d2b <alltraps>

80106ad1 <vector186>:
.globl vector186
vector186:
  pushl $0
80106ad1:	6a 00                	push   $0x0
  pushl $186
80106ad3:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106ad8:	e9 4e f2 ff ff       	jmp    80105d2b <alltraps>

80106add <vector187>:
.globl vector187
vector187:
  pushl $0
80106add:	6a 00                	push   $0x0
  pushl $187
80106adf:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106ae4:	e9 42 f2 ff ff       	jmp    80105d2b <alltraps>

80106ae9 <vector188>:
.globl vector188
vector188:
  pushl $0
80106ae9:	6a 00                	push   $0x0
  pushl $188
80106aeb:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106af0:	e9 36 f2 ff ff       	jmp    80105d2b <alltraps>

80106af5 <vector189>:
.globl vector189
vector189:
  pushl $0
80106af5:	6a 00                	push   $0x0
  pushl $189
80106af7:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106afc:	e9 2a f2 ff ff       	jmp    80105d2b <alltraps>

80106b01 <vector190>:
.globl vector190
vector190:
  pushl $0
80106b01:	6a 00                	push   $0x0
  pushl $190
80106b03:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106b08:	e9 1e f2 ff ff       	jmp    80105d2b <alltraps>

80106b0d <vector191>:
.globl vector191
vector191:
  pushl $0
80106b0d:	6a 00                	push   $0x0
  pushl $191
80106b0f:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106b14:	e9 12 f2 ff ff       	jmp    80105d2b <alltraps>

80106b19 <vector192>:
.globl vector192
vector192:
  pushl $0
80106b19:	6a 00                	push   $0x0
  pushl $192
80106b1b:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106b20:	e9 06 f2 ff ff       	jmp    80105d2b <alltraps>

80106b25 <vector193>:
.globl vector193
vector193:
  pushl $0
80106b25:	6a 00                	push   $0x0
  pushl $193
80106b27:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106b2c:	e9 fa f1 ff ff       	jmp    80105d2b <alltraps>

80106b31 <vector194>:
.globl vector194
vector194:
  pushl $0
80106b31:	6a 00                	push   $0x0
  pushl $194
80106b33:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106b38:	e9 ee f1 ff ff       	jmp    80105d2b <alltraps>

80106b3d <vector195>:
.globl vector195
vector195:
  pushl $0
80106b3d:	6a 00                	push   $0x0
  pushl $195
80106b3f:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106b44:	e9 e2 f1 ff ff       	jmp    80105d2b <alltraps>

80106b49 <vector196>:
.globl vector196
vector196:
  pushl $0
80106b49:	6a 00                	push   $0x0
  pushl $196
80106b4b:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106b50:	e9 d6 f1 ff ff       	jmp    80105d2b <alltraps>

80106b55 <vector197>:
.globl vector197
vector197:
  pushl $0
80106b55:	6a 00                	push   $0x0
  pushl $197
80106b57:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106b5c:	e9 ca f1 ff ff       	jmp    80105d2b <alltraps>

80106b61 <vector198>:
.globl vector198
vector198:
  pushl $0
80106b61:	6a 00                	push   $0x0
  pushl $198
80106b63:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106b68:	e9 be f1 ff ff       	jmp    80105d2b <alltraps>

80106b6d <vector199>:
.globl vector199
vector199:
  pushl $0
80106b6d:	6a 00                	push   $0x0
  pushl $199
80106b6f:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106b74:	e9 b2 f1 ff ff       	jmp    80105d2b <alltraps>

80106b79 <vector200>:
.globl vector200
vector200:
  pushl $0
80106b79:	6a 00                	push   $0x0
  pushl $200
80106b7b:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106b80:	e9 a6 f1 ff ff       	jmp    80105d2b <alltraps>

80106b85 <vector201>:
.globl vector201
vector201:
  pushl $0
80106b85:	6a 00                	push   $0x0
  pushl $201
80106b87:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80106b8c:	e9 9a f1 ff ff       	jmp    80105d2b <alltraps>

80106b91 <vector202>:
.globl vector202
vector202:
  pushl $0
80106b91:	6a 00                	push   $0x0
  pushl $202
80106b93:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106b98:	e9 8e f1 ff ff       	jmp    80105d2b <alltraps>

80106b9d <vector203>:
.globl vector203
vector203:
  pushl $0
80106b9d:	6a 00                	push   $0x0
  pushl $203
80106b9f:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106ba4:	e9 82 f1 ff ff       	jmp    80105d2b <alltraps>

80106ba9 <vector204>:
.globl vector204
vector204:
  pushl $0
80106ba9:	6a 00                	push   $0x0
  pushl $204
80106bab:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106bb0:	e9 76 f1 ff ff       	jmp    80105d2b <alltraps>

80106bb5 <vector205>:
.globl vector205
vector205:
  pushl $0
80106bb5:	6a 00                	push   $0x0
  pushl $205
80106bb7:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106bbc:	e9 6a f1 ff ff       	jmp    80105d2b <alltraps>

80106bc1 <vector206>:
.globl vector206
vector206:
  pushl $0
80106bc1:	6a 00                	push   $0x0
  pushl $206
80106bc3:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106bc8:	e9 5e f1 ff ff       	jmp    80105d2b <alltraps>

80106bcd <vector207>:
.globl vector207
vector207:
  pushl $0
80106bcd:	6a 00                	push   $0x0
  pushl $207
80106bcf:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106bd4:	e9 52 f1 ff ff       	jmp    80105d2b <alltraps>

80106bd9 <vector208>:
.globl vector208
vector208:
  pushl $0
80106bd9:	6a 00                	push   $0x0
  pushl $208
80106bdb:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106be0:	e9 46 f1 ff ff       	jmp    80105d2b <alltraps>

80106be5 <vector209>:
.globl vector209
vector209:
  pushl $0
80106be5:	6a 00                	push   $0x0
  pushl $209
80106be7:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106bec:	e9 3a f1 ff ff       	jmp    80105d2b <alltraps>

80106bf1 <vector210>:
.globl vector210
vector210:
  pushl $0
80106bf1:	6a 00                	push   $0x0
  pushl $210
80106bf3:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106bf8:	e9 2e f1 ff ff       	jmp    80105d2b <alltraps>

80106bfd <vector211>:
.globl vector211
vector211:
  pushl $0
80106bfd:	6a 00                	push   $0x0
  pushl $211
80106bff:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106c04:	e9 22 f1 ff ff       	jmp    80105d2b <alltraps>

80106c09 <vector212>:
.globl vector212
vector212:
  pushl $0
80106c09:	6a 00                	push   $0x0
  pushl $212
80106c0b:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106c10:	e9 16 f1 ff ff       	jmp    80105d2b <alltraps>

80106c15 <vector213>:
.globl vector213
vector213:
  pushl $0
80106c15:	6a 00                	push   $0x0
  pushl $213
80106c17:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80106c1c:	e9 0a f1 ff ff       	jmp    80105d2b <alltraps>

80106c21 <vector214>:
.globl vector214
vector214:
  pushl $0
80106c21:	6a 00                	push   $0x0
  pushl $214
80106c23:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106c28:	e9 fe f0 ff ff       	jmp    80105d2b <alltraps>

80106c2d <vector215>:
.globl vector215
vector215:
  pushl $0
80106c2d:	6a 00                	push   $0x0
  pushl $215
80106c2f:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106c34:	e9 f2 f0 ff ff       	jmp    80105d2b <alltraps>

80106c39 <vector216>:
.globl vector216
vector216:
  pushl $0
80106c39:	6a 00                	push   $0x0
  pushl $216
80106c3b:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106c40:	e9 e6 f0 ff ff       	jmp    80105d2b <alltraps>

80106c45 <vector217>:
.globl vector217
vector217:
  pushl $0
80106c45:	6a 00                	push   $0x0
  pushl $217
80106c47:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80106c4c:	e9 da f0 ff ff       	jmp    80105d2b <alltraps>

80106c51 <vector218>:
.globl vector218
vector218:
  pushl $0
80106c51:	6a 00                	push   $0x0
  pushl $218
80106c53:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106c58:	e9 ce f0 ff ff       	jmp    80105d2b <alltraps>

80106c5d <vector219>:
.globl vector219
vector219:
  pushl $0
80106c5d:	6a 00                	push   $0x0
  pushl $219
80106c5f:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106c64:	e9 c2 f0 ff ff       	jmp    80105d2b <alltraps>

80106c69 <vector220>:
.globl vector220
vector220:
  pushl $0
80106c69:	6a 00                	push   $0x0
  pushl $220
80106c6b:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80106c70:	e9 b6 f0 ff ff       	jmp    80105d2b <alltraps>

80106c75 <vector221>:
.globl vector221
vector221:
  pushl $0
80106c75:	6a 00                	push   $0x0
  pushl $221
80106c77:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80106c7c:	e9 aa f0 ff ff       	jmp    80105d2b <alltraps>

80106c81 <vector222>:
.globl vector222
vector222:
  pushl $0
80106c81:	6a 00                	push   $0x0
  pushl $222
80106c83:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80106c88:	e9 9e f0 ff ff       	jmp    80105d2b <alltraps>

80106c8d <vector223>:
.globl vector223
vector223:
  pushl $0
80106c8d:	6a 00                	push   $0x0
  pushl $223
80106c8f:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106c94:	e9 92 f0 ff ff       	jmp    80105d2b <alltraps>

80106c99 <vector224>:
.globl vector224
vector224:
  pushl $0
80106c99:	6a 00                	push   $0x0
  pushl $224
80106c9b:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80106ca0:	e9 86 f0 ff ff       	jmp    80105d2b <alltraps>

80106ca5 <vector225>:
.globl vector225
vector225:
  pushl $0
80106ca5:	6a 00                	push   $0x0
  pushl $225
80106ca7:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80106cac:	e9 7a f0 ff ff       	jmp    80105d2b <alltraps>

80106cb1 <vector226>:
.globl vector226
vector226:
  pushl $0
80106cb1:	6a 00                	push   $0x0
  pushl $226
80106cb3:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80106cb8:	e9 6e f0 ff ff       	jmp    80105d2b <alltraps>

80106cbd <vector227>:
.globl vector227
vector227:
  pushl $0
80106cbd:	6a 00                	push   $0x0
  pushl $227
80106cbf:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80106cc4:	e9 62 f0 ff ff       	jmp    80105d2b <alltraps>

80106cc9 <vector228>:
.globl vector228
vector228:
  pushl $0
80106cc9:	6a 00                	push   $0x0
  pushl $228
80106ccb:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80106cd0:	e9 56 f0 ff ff       	jmp    80105d2b <alltraps>

80106cd5 <vector229>:
.globl vector229
vector229:
  pushl $0
80106cd5:	6a 00                	push   $0x0
  pushl $229
80106cd7:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80106cdc:	e9 4a f0 ff ff       	jmp    80105d2b <alltraps>

80106ce1 <vector230>:
.globl vector230
vector230:
  pushl $0
80106ce1:	6a 00                	push   $0x0
  pushl $230
80106ce3:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80106ce8:	e9 3e f0 ff ff       	jmp    80105d2b <alltraps>

80106ced <vector231>:
.globl vector231
vector231:
  pushl $0
80106ced:	6a 00                	push   $0x0
  pushl $231
80106cef:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80106cf4:	e9 32 f0 ff ff       	jmp    80105d2b <alltraps>

80106cf9 <vector232>:
.globl vector232
vector232:
  pushl $0
80106cf9:	6a 00                	push   $0x0
  pushl $232
80106cfb:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80106d00:	e9 26 f0 ff ff       	jmp    80105d2b <alltraps>

80106d05 <vector233>:
.globl vector233
vector233:
  pushl $0
80106d05:	6a 00                	push   $0x0
  pushl $233
80106d07:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80106d0c:	e9 1a f0 ff ff       	jmp    80105d2b <alltraps>

80106d11 <vector234>:
.globl vector234
vector234:
  pushl $0
80106d11:	6a 00                	push   $0x0
  pushl $234
80106d13:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80106d18:	e9 0e f0 ff ff       	jmp    80105d2b <alltraps>

80106d1d <vector235>:
.globl vector235
vector235:
  pushl $0
80106d1d:	6a 00                	push   $0x0
  pushl $235
80106d1f:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80106d24:	e9 02 f0 ff ff       	jmp    80105d2b <alltraps>

80106d29 <vector236>:
.globl vector236
vector236:
  pushl $0
80106d29:	6a 00                	push   $0x0
  pushl $236
80106d2b:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80106d30:	e9 f6 ef ff ff       	jmp    80105d2b <alltraps>

80106d35 <vector237>:
.globl vector237
vector237:
  pushl $0
80106d35:	6a 00                	push   $0x0
  pushl $237
80106d37:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80106d3c:	e9 ea ef ff ff       	jmp    80105d2b <alltraps>

80106d41 <vector238>:
.globl vector238
vector238:
  pushl $0
80106d41:	6a 00                	push   $0x0
  pushl $238
80106d43:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80106d48:	e9 de ef ff ff       	jmp    80105d2b <alltraps>

80106d4d <vector239>:
.globl vector239
vector239:
  pushl $0
80106d4d:	6a 00                	push   $0x0
  pushl $239
80106d4f:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80106d54:	e9 d2 ef ff ff       	jmp    80105d2b <alltraps>

80106d59 <vector240>:
.globl vector240
vector240:
  pushl $0
80106d59:	6a 00                	push   $0x0
  pushl $240
80106d5b:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80106d60:	e9 c6 ef ff ff       	jmp    80105d2b <alltraps>

80106d65 <vector241>:
.globl vector241
vector241:
  pushl $0
80106d65:	6a 00                	push   $0x0
  pushl $241
80106d67:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80106d6c:	e9 ba ef ff ff       	jmp    80105d2b <alltraps>

80106d71 <vector242>:
.globl vector242
vector242:
  pushl $0
80106d71:	6a 00                	push   $0x0
  pushl $242
80106d73:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80106d78:	e9 ae ef ff ff       	jmp    80105d2b <alltraps>

80106d7d <vector243>:
.globl vector243
vector243:
  pushl $0
80106d7d:	6a 00                	push   $0x0
  pushl $243
80106d7f:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80106d84:	e9 a2 ef ff ff       	jmp    80105d2b <alltraps>

80106d89 <vector244>:
.globl vector244
vector244:
  pushl $0
80106d89:	6a 00                	push   $0x0
  pushl $244
80106d8b:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80106d90:	e9 96 ef ff ff       	jmp    80105d2b <alltraps>

80106d95 <vector245>:
.globl vector245
vector245:
  pushl $0
80106d95:	6a 00                	push   $0x0
  pushl $245
80106d97:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80106d9c:	e9 8a ef ff ff       	jmp    80105d2b <alltraps>

80106da1 <vector246>:
.globl vector246
vector246:
  pushl $0
80106da1:	6a 00                	push   $0x0
  pushl $246
80106da3:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80106da8:	e9 7e ef ff ff       	jmp    80105d2b <alltraps>

80106dad <vector247>:
.globl vector247
vector247:
  pushl $0
80106dad:	6a 00                	push   $0x0
  pushl $247
80106daf:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80106db4:	e9 72 ef ff ff       	jmp    80105d2b <alltraps>

80106db9 <vector248>:
.globl vector248
vector248:
  pushl $0
80106db9:	6a 00                	push   $0x0
  pushl $248
80106dbb:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80106dc0:	e9 66 ef ff ff       	jmp    80105d2b <alltraps>

80106dc5 <vector249>:
.globl vector249
vector249:
  pushl $0
80106dc5:	6a 00                	push   $0x0
  pushl $249
80106dc7:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80106dcc:	e9 5a ef ff ff       	jmp    80105d2b <alltraps>

80106dd1 <vector250>:
.globl vector250
vector250:
  pushl $0
80106dd1:	6a 00                	push   $0x0
  pushl $250
80106dd3:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80106dd8:	e9 4e ef ff ff       	jmp    80105d2b <alltraps>

80106ddd <vector251>:
.globl vector251
vector251:
  pushl $0
80106ddd:	6a 00                	push   $0x0
  pushl $251
80106ddf:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80106de4:	e9 42 ef ff ff       	jmp    80105d2b <alltraps>

80106de9 <vector252>:
.globl vector252
vector252:
  pushl $0
80106de9:	6a 00                	push   $0x0
  pushl $252
80106deb:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80106df0:	e9 36 ef ff ff       	jmp    80105d2b <alltraps>

80106df5 <vector253>:
.globl vector253
vector253:
  pushl $0
80106df5:	6a 00                	push   $0x0
  pushl $253
80106df7:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80106dfc:	e9 2a ef ff ff       	jmp    80105d2b <alltraps>

80106e01 <vector254>:
.globl vector254
vector254:
  pushl $0
80106e01:	6a 00                	push   $0x0
  pushl $254
80106e03:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80106e08:	e9 1e ef ff ff       	jmp    80105d2b <alltraps>

80106e0d <vector255>:
.globl vector255
vector255:
  pushl $0
80106e0d:	6a 00                	push   $0x0
  pushl $255
80106e0f:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80106e14:	e9 12 ef ff ff       	jmp    80105d2b <alltraps>

80106e19 <lgdt>:
{
80106e19:	55                   	push   %ebp
80106e1a:	89 e5                	mov    %esp,%ebp
80106e1c:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106e1f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e22:	83 e8 01             	sub    $0x1,%eax
80106e25:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106e29:	8b 45 08             	mov    0x8(%ebp),%eax
80106e2c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106e30:	8b 45 08             	mov    0x8(%ebp),%eax
80106e33:	c1 e8 10             	shr    $0x10,%eax
80106e36:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80106e3a:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106e3d:	0f 01 10             	lgdtl  (%eax)
}
80106e40:	90                   	nop
80106e41:	c9                   	leave  
80106e42:	c3                   	ret    

80106e43 <ltr>:
{
80106e43:	55                   	push   %ebp
80106e44:	89 e5                	mov    %esp,%ebp
80106e46:	83 ec 04             	sub    $0x4,%esp
80106e49:	8b 45 08             	mov    0x8(%ebp),%eax
80106e4c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80106e50:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80106e54:	0f 00 d8             	ltr    %ax
}
80106e57:	90                   	nop
80106e58:	c9                   	leave  
80106e59:	c3                   	ret    

80106e5a <lcr3>:

static inline void
lcr3(uint val)
{
80106e5a:	55                   	push   %ebp
80106e5b:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106e5d:	8b 45 08             	mov    0x8(%ebp),%eax
80106e60:	0f 22 d8             	mov    %eax,%cr3
}
80106e63:	90                   	nop
80106e64:	5d                   	pop    %ebp
80106e65:	c3                   	ret    

80106e66 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80106e66:	55                   	push   %ebp
80106e67:	89 e5                	mov    %esp,%ebp
80106e69:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80106e6c:	e8 2c cb ff ff       	call   8010399d <cpuid>
80106e71:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80106e77:	05 80 6a 19 80       	add    $0x80196a80,%eax
80106e7c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80106e7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e82:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80106e88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e8b:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80106e91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e94:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80106e98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e9b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106e9f:	83 e2 f0             	and    $0xfffffff0,%edx
80106ea2:	83 ca 0a             	or     $0xa,%edx
80106ea5:	88 50 7d             	mov    %dl,0x7d(%eax)
80106ea8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106eab:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106eaf:	83 ca 10             	or     $0x10,%edx
80106eb2:	88 50 7d             	mov    %dl,0x7d(%eax)
80106eb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106eb8:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106ebc:	83 e2 9f             	and    $0xffffff9f,%edx
80106ebf:	88 50 7d             	mov    %dl,0x7d(%eax)
80106ec2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ec5:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106ec9:	83 ca 80             	or     $0xffffff80,%edx
80106ecc:	88 50 7d             	mov    %dl,0x7d(%eax)
80106ecf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ed2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106ed6:	83 ca 0f             	or     $0xf,%edx
80106ed9:	88 50 7e             	mov    %dl,0x7e(%eax)
80106edc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106edf:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106ee3:	83 e2 ef             	and    $0xffffffef,%edx
80106ee6:	88 50 7e             	mov    %dl,0x7e(%eax)
80106ee9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106eec:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106ef0:	83 e2 df             	and    $0xffffffdf,%edx
80106ef3:	88 50 7e             	mov    %dl,0x7e(%eax)
80106ef6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ef9:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106efd:	83 ca 40             	or     $0x40,%edx
80106f00:	88 50 7e             	mov    %dl,0x7e(%eax)
80106f03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f06:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106f0a:	83 ca 80             	or     $0xffffff80,%edx
80106f0d:	88 50 7e             	mov    %dl,0x7e(%eax)
80106f10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f13:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80106f17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f1a:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80106f21:	ff ff 
80106f23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f26:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80106f2d:	00 00 
80106f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f32:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80106f39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f3c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80106f43:	83 e2 f0             	and    $0xfffffff0,%edx
80106f46:	83 ca 02             	or     $0x2,%edx
80106f49:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80106f4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f52:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80106f59:	83 ca 10             	or     $0x10,%edx
80106f5c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80106f62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f65:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80106f6c:	83 e2 9f             	and    $0xffffff9f,%edx
80106f6f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80106f75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f78:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80106f7f:	83 ca 80             	or     $0xffffff80,%edx
80106f82:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80106f88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f8b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80106f92:	83 ca 0f             	or     $0xf,%edx
80106f95:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80106f9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f9e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80106fa5:	83 e2 ef             	and    $0xffffffef,%edx
80106fa8:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80106fae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fb1:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80106fb8:	83 e2 df             	and    $0xffffffdf,%edx
80106fbb:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80106fc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fc4:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80106fcb:	83 ca 40             	or     $0x40,%edx
80106fce:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80106fd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fd7:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80106fde:	83 ca 80             	or     $0xffffff80,%edx
80106fe1:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80106fe7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fea:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80106ff1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ff4:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80106ffb:	ff ff 
80106ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107000:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107007:	00 00 
80107009:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010700c:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107013:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107016:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010701d:	83 e2 f0             	and    $0xfffffff0,%edx
80107020:	83 ca 0a             	or     $0xa,%edx
80107023:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107029:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010702c:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107033:	83 ca 10             	or     $0x10,%edx
80107036:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010703c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010703f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107046:	83 ca 60             	or     $0x60,%edx
80107049:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010704f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107052:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107059:	83 ca 80             	or     $0xffffff80,%edx
8010705c:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107062:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107065:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010706c:	83 ca 0f             	or     $0xf,%edx
8010706f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107075:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107078:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010707f:	83 e2 ef             	and    $0xffffffef,%edx
80107082:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107088:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010708b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107092:	83 e2 df             	and    $0xffffffdf,%edx
80107095:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010709b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010709e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801070a5:	83 ca 40             	or     $0x40,%edx
801070a8:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801070ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070b1:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801070b8:	83 ca 80             	or     $0xffffff80,%edx
801070bb:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801070c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070c4:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801070cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070ce:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801070d5:	ff ff 
801070d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070da:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801070e1:	00 00 
801070e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070e6:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801070ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070f0:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801070f7:	83 e2 f0             	and    $0xfffffff0,%edx
801070fa:	83 ca 02             	or     $0x2,%edx
801070fd:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107103:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107106:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010710d:	83 ca 10             	or     $0x10,%edx
80107110:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107116:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107119:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107120:	83 ca 60             	or     $0x60,%edx
80107123:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107129:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010712c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107133:	83 ca 80             	or     $0xffffff80,%edx
80107136:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010713c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010713f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107146:	83 ca 0f             	or     $0xf,%edx
80107149:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010714f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107152:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107159:	83 e2 ef             	and    $0xffffffef,%edx
8010715c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107165:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010716c:	83 e2 df             	and    $0xffffffdf,%edx
8010716f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107175:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107178:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010717f:	83 ca 40             	or     $0x40,%edx
80107182:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107188:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010718b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107192:	83 ca 80             	or     $0xffffff80,%edx
80107195:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010719b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010719e:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801071a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071a8:	83 c0 70             	add    $0x70,%eax
801071ab:	83 ec 08             	sub    $0x8,%esp
801071ae:	6a 30                	push   $0x30
801071b0:	50                   	push   %eax
801071b1:	e8 63 fc ff ff       	call   80106e19 <lgdt>
801071b6:	83 c4 10             	add    $0x10,%esp
}
801071b9:	90                   	nop
801071ba:	c9                   	leave  
801071bb:	c3                   	ret    

801071bc <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801071bc:	55                   	push   %ebp
801071bd:	89 e5                	mov    %esp,%ebp
801071bf:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801071c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801071c5:	c1 e8 16             	shr    $0x16,%eax
801071c8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801071cf:	8b 45 08             	mov    0x8(%ebp),%eax
801071d2:	01 d0                	add    %edx,%eax
801071d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801071d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801071da:	8b 00                	mov    (%eax),%eax
801071dc:	83 e0 01             	and    $0x1,%eax
801071df:	85 c0                	test   %eax,%eax
801071e1:	74 14                	je     801071f7 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801071e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801071e6:	8b 00                	mov    (%eax),%eax
801071e8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801071ed:	05 00 00 00 80       	add    $0x80000000,%eax
801071f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801071f5:	eb 42                	jmp    80107239 <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801071f7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801071fb:	74 0e                	je     8010720b <walkpgdir+0x4f>
801071fd:	e8 9e b5 ff ff       	call   801027a0 <kalloc>
80107202:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107205:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107209:	75 07                	jne    80107212 <walkpgdir+0x56>
      return 0;
8010720b:	b8 00 00 00 00       	mov    $0x0,%eax
80107210:	eb 3e                	jmp    80107250 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107212:	83 ec 04             	sub    $0x4,%esp
80107215:	68 00 10 00 00       	push   $0x1000
8010721a:	6a 00                	push   $0x0
8010721c:	ff 75 f4             	push   -0xc(%ebp)
8010721f:	e8 5e d7 ff ff       	call   80104982 <memset>
80107224:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107227:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010722a:	05 00 00 00 80       	add    $0x80000000,%eax
8010722f:	83 c8 07             	or     $0x7,%eax
80107232:	89 c2                	mov    %eax,%edx
80107234:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107237:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107239:	8b 45 0c             	mov    0xc(%ebp),%eax
8010723c:	c1 e8 0c             	shr    $0xc,%eax
8010723f:	25 ff 03 00 00       	and    $0x3ff,%eax
80107244:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010724b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010724e:	01 d0                	add    %edx,%eax
}
80107250:	c9                   	leave  
80107251:	c3                   	ret    

80107252 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107252:	55                   	push   %ebp
80107253:	89 e5                	mov    %esp,%ebp
80107255:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107258:	8b 45 0c             	mov    0xc(%ebp),%eax
8010725b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107260:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107263:	8b 55 0c             	mov    0xc(%ebp),%edx
80107266:	8b 45 10             	mov    0x10(%ebp),%eax
80107269:	01 d0                	add    %edx,%eax
8010726b:	83 e8 01             	sub    $0x1,%eax
8010726e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107273:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107276:	83 ec 04             	sub    $0x4,%esp
80107279:	6a 01                	push   $0x1
8010727b:	ff 75 f4             	push   -0xc(%ebp)
8010727e:	ff 75 08             	push   0x8(%ebp)
80107281:	e8 36 ff ff ff       	call   801071bc <walkpgdir>
80107286:	83 c4 10             	add    $0x10,%esp
80107289:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010728c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107290:	75 07                	jne    80107299 <mappages+0x47>
      return -1;
80107292:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107297:	eb 47                	jmp    801072e0 <mappages+0x8e>
    if(*pte & PTE_P)
80107299:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010729c:	8b 00                	mov    (%eax),%eax
8010729e:	83 e0 01             	and    $0x1,%eax
801072a1:	85 c0                	test   %eax,%eax
801072a3:	74 0d                	je     801072b2 <mappages+0x60>
      panic("remap");
801072a5:	83 ec 0c             	sub    $0xc,%esp
801072a8:	68 88 a5 10 80       	push   $0x8010a588
801072ad:	e8 f7 92 ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
801072b2:	8b 45 18             	mov    0x18(%ebp),%eax
801072b5:	0b 45 14             	or     0x14(%ebp),%eax
801072b8:	83 c8 01             	or     $0x1,%eax
801072bb:	89 c2                	mov    %eax,%edx
801072bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801072c0:	89 10                	mov    %edx,(%eax)
    if(a == last)
801072c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072c5:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801072c8:	74 10                	je     801072da <mappages+0x88>
      break;
    a += PGSIZE;
801072ca:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801072d1:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801072d8:	eb 9c                	jmp    80107276 <mappages+0x24>
      break;
801072da:	90                   	nop
  }
  return 0;
801072db:	b8 00 00 00 00       	mov    $0x0,%eax
}
801072e0:	c9                   	leave  
801072e1:	c3                   	ret    

801072e2 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801072e2:	55                   	push   %ebp
801072e3:	89 e5                	mov    %esp,%ebp
801072e5:	53                   	push   %ebx
801072e6:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
801072e9:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
801072f0:	8b 15 50 6d 19 80    	mov    0x80196d50,%edx
801072f6:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
801072fb:	29 d0                	sub    %edx,%eax
801072fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107300:	a1 48 6d 19 80       	mov    0x80196d48,%eax
80107305:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107308:	8b 15 48 6d 19 80    	mov    0x80196d48,%edx
8010730e:	a1 50 6d 19 80       	mov    0x80196d50,%eax
80107313:	01 d0                	add    %edx,%eax
80107315:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107318:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
8010731f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107322:	83 c0 30             	add    $0x30,%eax
80107325:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107328:	89 10                	mov    %edx,(%eax)
8010732a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010732d:	89 50 04             	mov    %edx,0x4(%eax)
80107330:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107333:	89 50 08             	mov    %edx,0x8(%eax)
80107336:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107339:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
8010733c:	e8 5f b4 ff ff       	call   801027a0 <kalloc>
80107341:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107344:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107348:	75 07                	jne    80107351 <setupkvm+0x6f>
    return 0;
8010734a:	b8 00 00 00 00       	mov    $0x0,%eax
8010734f:	eb 78                	jmp    801073c9 <setupkvm+0xe7>
  }
  memset(pgdir, 0, PGSIZE);
80107351:	83 ec 04             	sub    $0x4,%esp
80107354:	68 00 10 00 00       	push   $0x1000
80107359:	6a 00                	push   $0x0
8010735b:	ff 75 f0             	push   -0x10(%ebp)
8010735e:	e8 1f d6 ff ff       	call   80104982 <memset>
80107363:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107366:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
8010736d:	eb 4e                	jmp    801073bd <setupkvm+0xdb>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010736f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107372:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107375:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107378:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010737b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010737e:	8b 58 08             	mov    0x8(%eax),%ebx
80107381:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107384:	8b 40 04             	mov    0x4(%eax),%eax
80107387:	29 c3                	sub    %eax,%ebx
80107389:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010738c:	8b 00                	mov    (%eax),%eax
8010738e:	83 ec 0c             	sub    $0xc,%esp
80107391:	51                   	push   %ecx
80107392:	52                   	push   %edx
80107393:	53                   	push   %ebx
80107394:	50                   	push   %eax
80107395:	ff 75 f0             	push   -0x10(%ebp)
80107398:	e8 b5 fe ff ff       	call   80107252 <mappages>
8010739d:	83 c4 20             	add    $0x20,%esp
801073a0:	85 c0                	test   %eax,%eax
801073a2:	79 15                	jns    801073b9 <setupkvm+0xd7>
      freevm(pgdir);
801073a4:	83 ec 0c             	sub    $0xc,%esp
801073a7:	ff 75 f0             	push   -0x10(%ebp)
801073aa:	e8 f5 04 00 00       	call   801078a4 <freevm>
801073af:	83 c4 10             	add    $0x10,%esp
      return 0;
801073b2:	b8 00 00 00 00       	mov    $0x0,%eax
801073b7:	eb 10                	jmp    801073c9 <setupkvm+0xe7>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801073b9:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801073bd:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
801073c4:	72 a9                	jb     8010736f <setupkvm+0x8d>
    }
  return pgdir;
801073c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801073c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801073cc:	c9                   	leave  
801073cd:	c3                   	ret    

801073ce <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801073ce:	55                   	push   %ebp
801073cf:	89 e5                	mov    %esp,%ebp
801073d1:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801073d4:	e8 09 ff ff ff       	call   801072e2 <setupkvm>
801073d9:	a3 7c 6a 19 80       	mov    %eax,0x80196a7c
  switchkvm();
801073de:	e8 03 00 00 00       	call   801073e6 <switchkvm>
}
801073e3:	90                   	nop
801073e4:	c9                   	leave  
801073e5:	c3                   	ret    

801073e6 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801073e6:	55                   	push   %ebp
801073e7:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801073e9:	a1 7c 6a 19 80       	mov    0x80196a7c,%eax
801073ee:	05 00 00 00 80       	add    $0x80000000,%eax
801073f3:	50                   	push   %eax
801073f4:	e8 61 fa ff ff       	call   80106e5a <lcr3>
801073f9:	83 c4 04             	add    $0x4,%esp
}
801073fc:	90                   	nop
801073fd:	c9                   	leave  
801073fe:	c3                   	ret    

801073ff <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801073ff:	55                   	push   %ebp
80107400:	89 e5                	mov    %esp,%ebp
80107402:	56                   	push   %esi
80107403:	53                   	push   %ebx
80107404:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107407:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010740b:	75 0d                	jne    8010741a <switchuvm+0x1b>
    panic("switchuvm: no process");
8010740d:	83 ec 0c             	sub    $0xc,%esp
80107410:	68 8e a5 10 80       	push   $0x8010a58e
80107415:	e8 8f 91 ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
8010741a:	8b 45 08             	mov    0x8(%ebp),%eax
8010741d:	8b 40 08             	mov    0x8(%eax),%eax
80107420:	85 c0                	test   %eax,%eax
80107422:	75 0d                	jne    80107431 <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107424:	83 ec 0c             	sub    $0xc,%esp
80107427:	68 a4 a5 10 80       	push   $0x8010a5a4
8010742c:	e8 78 91 ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
80107431:	8b 45 08             	mov    0x8(%ebp),%eax
80107434:	8b 40 04             	mov    0x4(%eax),%eax
80107437:	85 c0                	test   %eax,%eax
80107439:	75 0d                	jne    80107448 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
8010743b:	83 ec 0c             	sub    $0xc,%esp
8010743e:	68 b9 a5 10 80       	push   $0x8010a5b9
80107443:	e8 61 91 ff ff       	call   801005a9 <panic>

  pushcli();
80107448:	e8 2a d4 ff ff       	call   80104877 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
8010744d:	e8 66 c5 ff ff       	call   801039b8 <mycpu>
80107452:	89 c3                	mov    %eax,%ebx
80107454:	e8 5f c5 ff ff       	call   801039b8 <mycpu>
80107459:	83 c0 08             	add    $0x8,%eax
8010745c:	89 c6                	mov    %eax,%esi
8010745e:	e8 55 c5 ff ff       	call   801039b8 <mycpu>
80107463:	83 c0 08             	add    $0x8,%eax
80107466:	c1 e8 10             	shr    $0x10,%eax
80107469:	88 45 f7             	mov    %al,-0x9(%ebp)
8010746c:	e8 47 c5 ff ff       	call   801039b8 <mycpu>
80107471:	83 c0 08             	add    $0x8,%eax
80107474:	c1 e8 18             	shr    $0x18,%eax
80107477:	89 c2                	mov    %eax,%edx
80107479:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107480:	67 00 
80107482:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107489:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
8010748d:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107493:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010749a:	83 e0 f0             	and    $0xfffffff0,%eax
8010749d:	83 c8 09             	or     $0x9,%eax
801074a0:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801074a6:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801074ad:	83 c8 10             	or     $0x10,%eax
801074b0:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801074b6:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801074bd:	83 e0 9f             	and    $0xffffff9f,%eax
801074c0:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801074c6:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801074cd:	83 c8 80             	or     $0xffffff80,%eax
801074d0:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801074d6:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801074dd:	83 e0 f0             	and    $0xfffffff0,%eax
801074e0:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801074e6:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801074ed:	83 e0 ef             	and    $0xffffffef,%eax
801074f0:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801074f6:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801074fd:	83 e0 df             	and    $0xffffffdf,%eax
80107500:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107506:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010750d:	83 c8 40             	or     $0x40,%eax
80107510:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107516:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010751d:	83 e0 7f             	and    $0x7f,%eax
80107520:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107526:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
8010752c:	e8 87 c4 ff ff       	call   801039b8 <mycpu>
80107531:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107538:	83 e2 ef             	and    $0xffffffef,%edx
8010753b:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107541:	e8 72 c4 ff ff       	call   801039b8 <mycpu>
80107546:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
8010754c:	8b 45 08             	mov    0x8(%ebp),%eax
8010754f:	8b 40 08             	mov    0x8(%eax),%eax
80107552:	89 c3                	mov    %eax,%ebx
80107554:	e8 5f c4 ff ff       	call   801039b8 <mycpu>
80107559:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
8010755f:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107562:	e8 51 c4 ff ff       	call   801039b8 <mycpu>
80107567:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
8010756d:	83 ec 0c             	sub    $0xc,%esp
80107570:	6a 28                	push   $0x28
80107572:	e8 cc f8 ff ff       	call   80106e43 <ltr>
80107577:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
8010757a:	8b 45 08             	mov    0x8(%ebp),%eax
8010757d:	8b 40 04             	mov    0x4(%eax),%eax
80107580:	05 00 00 00 80       	add    $0x80000000,%eax
80107585:	83 ec 0c             	sub    $0xc,%esp
80107588:	50                   	push   %eax
80107589:	e8 cc f8 ff ff       	call   80106e5a <lcr3>
8010758e:	83 c4 10             	add    $0x10,%esp
  popcli();
80107591:	e8 2e d3 ff ff       	call   801048c4 <popcli>
}
80107596:	90                   	nop
80107597:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010759a:	5b                   	pop    %ebx
8010759b:	5e                   	pop    %esi
8010759c:	5d                   	pop    %ebp
8010759d:	c3                   	ret    

8010759e <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
8010759e:	55                   	push   %ebp
8010759f:	89 e5                	mov    %esp,%ebp
801075a1:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
801075a4:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801075ab:	76 0d                	jbe    801075ba <inituvm+0x1c>
    panic("inituvm: more than a page");
801075ad:	83 ec 0c             	sub    $0xc,%esp
801075b0:	68 cd a5 10 80       	push   $0x8010a5cd
801075b5:	e8 ef 8f ff ff       	call   801005a9 <panic>
  mem = kalloc();
801075ba:	e8 e1 b1 ff ff       	call   801027a0 <kalloc>
801075bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801075c2:	83 ec 04             	sub    $0x4,%esp
801075c5:	68 00 10 00 00       	push   $0x1000
801075ca:	6a 00                	push   $0x0
801075cc:	ff 75 f4             	push   -0xc(%ebp)
801075cf:	e8 ae d3 ff ff       	call   80104982 <memset>
801075d4:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801075d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075da:	05 00 00 00 80       	add    $0x80000000,%eax
801075df:	83 ec 0c             	sub    $0xc,%esp
801075e2:	6a 06                	push   $0x6
801075e4:	50                   	push   %eax
801075e5:	68 00 10 00 00       	push   $0x1000
801075ea:	6a 00                	push   $0x0
801075ec:	ff 75 08             	push   0x8(%ebp)
801075ef:	e8 5e fc ff ff       	call   80107252 <mappages>
801075f4:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
801075f7:	83 ec 04             	sub    $0x4,%esp
801075fa:	ff 75 10             	push   0x10(%ebp)
801075fd:	ff 75 0c             	push   0xc(%ebp)
80107600:	ff 75 f4             	push   -0xc(%ebp)
80107603:	e8 39 d4 ff ff       	call   80104a41 <memmove>
80107608:	83 c4 10             	add    $0x10,%esp
}
8010760b:	90                   	nop
8010760c:	c9                   	leave  
8010760d:	c3                   	ret    

8010760e <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010760e:	55                   	push   %ebp
8010760f:	89 e5                	mov    %esp,%ebp
80107611:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107614:	8b 45 0c             	mov    0xc(%ebp),%eax
80107617:	25 ff 0f 00 00       	and    $0xfff,%eax
8010761c:	85 c0                	test   %eax,%eax
8010761e:	74 0d                	je     8010762d <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107620:	83 ec 0c             	sub    $0xc,%esp
80107623:	68 e8 a5 10 80       	push   $0x8010a5e8
80107628:	e8 7c 8f ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
8010762d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107634:	e9 8f 00 00 00       	jmp    801076c8 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107639:	8b 55 0c             	mov    0xc(%ebp),%edx
8010763c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010763f:	01 d0                	add    %edx,%eax
80107641:	83 ec 04             	sub    $0x4,%esp
80107644:	6a 00                	push   $0x0
80107646:	50                   	push   %eax
80107647:	ff 75 08             	push   0x8(%ebp)
8010764a:	e8 6d fb ff ff       	call   801071bc <walkpgdir>
8010764f:	83 c4 10             	add    $0x10,%esp
80107652:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107655:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107659:	75 0d                	jne    80107668 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
8010765b:	83 ec 0c             	sub    $0xc,%esp
8010765e:	68 0b a6 10 80       	push   $0x8010a60b
80107663:	e8 41 8f ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107668:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010766b:	8b 00                	mov    (%eax),%eax
8010766d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107672:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107675:	8b 45 18             	mov    0x18(%ebp),%eax
80107678:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010767b:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107680:	77 0b                	ja     8010768d <loaduvm+0x7f>
      n = sz - i;
80107682:	8b 45 18             	mov    0x18(%ebp),%eax
80107685:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107688:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010768b:	eb 07                	jmp    80107694 <loaduvm+0x86>
    else
      n = PGSIZE;
8010768d:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107694:	8b 55 14             	mov    0x14(%ebp),%edx
80107697:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010769a:	01 d0                	add    %edx,%eax
8010769c:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010769f:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801076a5:	ff 75 f0             	push   -0x10(%ebp)
801076a8:	50                   	push   %eax
801076a9:	52                   	push   %edx
801076aa:	ff 75 10             	push   0x10(%ebp)
801076ad:	e8 24 a8 ff ff       	call   80101ed6 <readi>
801076b2:	83 c4 10             	add    $0x10,%esp
801076b5:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801076b8:	74 07                	je     801076c1 <loaduvm+0xb3>
      return -1;
801076ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801076bf:	eb 18                	jmp    801076d9 <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
801076c1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801076c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076cb:	3b 45 18             	cmp    0x18(%ebp),%eax
801076ce:	0f 82 65 ff ff ff    	jb     80107639 <loaduvm+0x2b>
  }
  return 0;
801076d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801076d9:	c9                   	leave  
801076da:	c3                   	ret    

801076db <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801076db:	55                   	push   %ebp
801076dc:	89 e5                	mov    %esp,%ebp
801076de:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801076e1:	8b 45 10             	mov    0x10(%ebp),%eax
801076e4:	85 c0                	test   %eax,%eax
801076e6:	79 0a                	jns    801076f2 <allocuvm+0x17>
    return 0;
801076e8:	b8 00 00 00 00       	mov    $0x0,%eax
801076ed:	e9 ec 00 00 00       	jmp    801077de <allocuvm+0x103>
  if(newsz < oldsz)
801076f2:	8b 45 10             	mov    0x10(%ebp),%eax
801076f5:	3b 45 0c             	cmp    0xc(%ebp),%eax
801076f8:	73 08                	jae    80107702 <allocuvm+0x27>
    return oldsz;
801076fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801076fd:	e9 dc 00 00 00       	jmp    801077de <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80107702:	8b 45 0c             	mov    0xc(%ebp),%eax
80107705:	05 ff 0f 00 00       	add    $0xfff,%eax
8010770a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010770f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107712:	e9 b8 00 00 00       	jmp    801077cf <allocuvm+0xf4>
    mem = kalloc();
80107717:	e8 84 b0 ff ff       	call   801027a0 <kalloc>
8010771c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010771f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107723:	75 2e                	jne    80107753 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80107725:	83 ec 0c             	sub    $0xc,%esp
80107728:	68 29 a6 10 80       	push   $0x8010a629
8010772d:	e8 c2 8c ff ff       	call   801003f4 <cprintf>
80107732:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107735:	83 ec 04             	sub    $0x4,%esp
80107738:	ff 75 0c             	push   0xc(%ebp)
8010773b:	ff 75 10             	push   0x10(%ebp)
8010773e:	ff 75 08             	push   0x8(%ebp)
80107741:	e8 9a 00 00 00       	call   801077e0 <deallocuvm>
80107746:	83 c4 10             	add    $0x10,%esp
      return 0;
80107749:	b8 00 00 00 00       	mov    $0x0,%eax
8010774e:	e9 8b 00 00 00       	jmp    801077de <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80107753:	83 ec 04             	sub    $0x4,%esp
80107756:	68 00 10 00 00       	push   $0x1000
8010775b:	6a 00                	push   $0x0
8010775d:	ff 75 f0             	push   -0x10(%ebp)
80107760:	e8 1d d2 ff ff       	call   80104982 <memset>
80107765:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107768:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010776b:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107771:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107774:	83 ec 0c             	sub    $0xc,%esp
80107777:	6a 06                	push   $0x6
80107779:	52                   	push   %edx
8010777a:	68 00 10 00 00       	push   $0x1000
8010777f:	50                   	push   %eax
80107780:	ff 75 08             	push   0x8(%ebp)
80107783:	e8 ca fa ff ff       	call   80107252 <mappages>
80107788:	83 c4 20             	add    $0x20,%esp
8010778b:	85 c0                	test   %eax,%eax
8010778d:	79 39                	jns    801077c8 <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
8010778f:	83 ec 0c             	sub    $0xc,%esp
80107792:	68 41 a6 10 80       	push   $0x8010a641
80107797:	e8 58 8c ff ff       	call   801003f4 <cprintf>
8010779c:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
8010779f:	83 ec 04             	sub    $0x4,%esp
801077a2:	ff 75 0c             	push   0xc(%ebp)
801077a5:	ff 75 10             	push   0x10(%ebp)
801077a8:	ff 75 08             	push   0x8(%ebp)
801077ab:	e8 30 00 00 00       	call   801077e0 <deallocuvm>
801077b0:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
801077b3:	83 ec 0c             	sub    $0xc,%esp
801077b6:	ff 75 f0             	push   -0x10(%ebp)
801077b9:	e8 48 af ff ff       	call   80102706 <kfree>
801077be:	83 c4 10             	add    $0x10,%esp
      return 0;
801077c1:	b8 00 00 00 00       	mov    $0x0,%eax
801077c6:	eb 16                	jmp    801077de <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
801077c8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801077cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077d2:	3b 45 10             	cmp    0x10(%ebp),%eax
801077d5:	0f 82 3c ff ff ff    	jb     80107717 <allocuvm+0x3c>
    }
  }
  return newsz;
801077db:	8b 45 10             	mov    0x10(%ebp),%eax
}
801077de:	c9                   	leave  
801077df:	c3                   	ret    

801077e0 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801077e0:	55                   	push   %ebp
801077e1:	89 e5                	mov    %esp,%ebp
801077e3:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801077e6:	8b 45 10             	mov    0x10(%ebp),%eax
801077e9:	3b 45 0c             	cmp    0xc(%ebp),%eax
801077ec:	72 08                	jb     801077f6 <deallocuvm+0x16>
    return oldsz;
801077ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801077f1:	e9 ac 00 00 00       	jmp    801078a2 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
801077f6:	8b 45 10             	mov    0x10(%ebp),%eax
801077f9:	05 ff 0f 00 00       	add    $0xfff,%eax
801077fe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107803:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107806:	e9 88 00 00 00       	jmp    80107893 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010780b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010780e:	83 ec 04             	sub    $0x4,%esp
80107811:	6a 00                	push   $0x0
80107813:	50                   	push   %eax
80107814:	ff 75 08             	push   0x8(%ebp)
80107817:	e8 a0 f9 ff ff       	call   801071bc <walkpgdir>
8010781c:	83 c4 10             	add    $0x10,%esp
8010781f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107822:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107826:	75 16                	jne    8010783e <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107828:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010782b:	c1 e8 16             	shr    $0x16,%eax
8010782e:	83 c0 01             	add    $0x1,%eax
80107831:	c1 e0 16             	shl    $0x16,%eax
80107834:	2d 00 10 00 00       	sub    $0x1000,%eax
80107839:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010783c:	eb 4e                	jmp    8010788c <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
8010783e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107841:	8b 00                	mov    (%eax),%eax
80107843:	83 e0 01             	and    $0x1,%eax
80107846:	85 c0                	test   %eax,%eax
80107848:	74 42                	je     8010788c <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
8010784a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010784d:	8b 00                	mov    (%eax),%eax
8010784f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107854:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107857:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010785b:	75 0d                	jne    8010786a <deallocuvm+0x8a>
        panic("kfree");
8010785d:	83 ec 0c             	sub    $0xc,%esp
80107860:	68 5d a6 10 80       	push   $0x8010a65d
80107865:	e8 3f 8d ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
8010786a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010786d:	05 00 00 00 80       	add    $0x80000000,%eax
80107872:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107875:	83 ec 0c             	sub    $0xc,%esp
80107878:	ff 75 e8             	push   -0x18(%ebp)
8010787b:	e8 86 ae ff ff       	call   80102706 <kfree>
80107880:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107883:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107886:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
8010788c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107893:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107896:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107899:	0f 82 6c ff ff ff    	jb     8010780b <deallocuvm+0x2b>
    }
  }
  return newsz;
8010789f:	8b 45 10             	mov    0x10(%ebp),%eax
}
801078a2:	c9                   	leave  
801078a3:	c3                   	ret    

801078a4 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801078a4:	55                   	push   %ebp
801078a5:	89 e5                	mov    %esp,%ebp
801078a7:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801078aa:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801078ae:	75 0d                	jne    801078bd <freevm+0x19>
    panic("freevm: no pgdir");
801078b0:	83 ec 0c             	sub    $0xc,%esp
801078b3:	68 63 a6 10 80       	push   $0x8010a663
801078b8:	e8 ec 8c ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801078bd:	83 ec 04             	sub    $0x4,%esp
801078c0:	6a 00                	push   $0x0
801078c2:	68 00 00 00 80       	push   $0x80000000
801078c7:	ff 75 08             	push   0x8(%ebp)
801078ca:	e8 11 ff ff ff       	call   801077e0 <deallocuvm>
801078cf:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801078d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801078d9:	eb 48                	jmp    80107923 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
801078db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078de:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801078e5:	8b 45 08             	mov    0x8(%ebp),%eax
801078e8:	01 d0                	add    %edx,%eax
801078ea:	8b 00                	mov    (%eax),%eax
801078ec:	83 e0 01             	and    $0x1,%eax
801078ef:	85 c0                	test   %eax,%eax
801078f1:	74 2c                	je     8010791f <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801078f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801078fd:	8b 45 08             	mov    0x8(%ebp),%eax
80107900:	01 d0                	add    %edx,%eax
80107902:	8b 00                	mov    (%eax),%eax
80107904:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107909:	05 00 00 00 80       	add    $0x80000000,%eax
8010790e:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107911:	83 ec 0c             	sub    $0xc,%esp
80107914:	ff 75 f0             	push   -0x10(%ebp)
80107917:	e8 ea ad ff ff       	call   80102706 <kfree>
8010791c:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010791f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107923:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
8010792a:	76 af                	jbe    801078db <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
8010792c:	83 ec 0c             	sub    $0xc,%esp
8010792f:	ff 75 08             	push   0x8(%ebp)
80107932:	e8 cf ad ff ff       	call   80102706 <kfree>
80107937:	83 c4 10             	add    $0x10,%esp
}
8010793a:	90                   	nop
8010793b:	c9                   	leave  
8010793c:	c3                   	ret    

8010793d <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010793d:	55                   	push   %ebp
8010793e:	89 e5                	mov    %esp,%ebp
80107940:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107943:	83 ec 04             	sub    $0x4,%esp
80107946:	6a 00                	push   $0x0
80107948:	ff 75 0c             	push   0xc(%ebp)
8010794b:	ff 75 08             	push   0x8(%ebp)
8010794e:	e8 69 f8 ff ff       	call   801071bc <walkpgdir>
80107953:	83 c4 10             	add    $0x10,%esp
80107956:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107959:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010795d:	75 0d                	jne    8010796c <clearpteu+0x2f>
    panic("clearpteu");
8010795f:	83 ec 0c             	sub    $0xc,%esp
80107962:	68 74 a6 10 80       	push   $0x8010a674
80107967:	e8 3d 8c ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
8010796c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010796f:	8b 00                	mov    (%eax),%eax
80107971:	83 e0 fb             	and    $0xfffffffb,%eax
80107974:	89 c2                	mov    %eax,%edx
80107976:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107979:	89 10                	mov    %edx,(%eax)
}
8010797b:	90                   	nop
8010797c:	c9                   	leave  
8010797d:	c3                   	ret    

8010797e <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010797e:	55                   	push   %ebp
8010797f:	89 e5                	mov    %esp,%ebp
80107981:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107984:	e8 59 f9 ff ff       	call   801072e2 <setupkvm>
80107989:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010798c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107990:	75 0a                	jne    8010799c <copyuvm+0x1e>
    return 0;
80107992:	b8 00 00 00 00       	mov    $0x0,%eax
80107997:	e9 eb 00 00 00       	jmp    80107a87 <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
8010799c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801079a3:	e9 b7 00 00 00       	jmp    80107a5f <copyuvm+0xe1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801079a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ab:	83 ec 04             	sub    $0x4,%esp
801079ae:	6a 00                	push   $0x0
801079b0:	50                   	push   %eax
801079b1:	ff 75 08             	push   0x8(%ebp)
801079b4:	e8 03 f8 ff ff       	call   801071bc <walkpgdir>
801079b9:	83 c4 10             	add    $0x10,%esp
801079bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
801079bf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801079c3:	75 0d                	jne    801079d2 <copyuvm+0x54>
      panic("copyuvm: pte should exist");
801079c5:	83 ec 0c             	sub    $0xc,%esp
801079c8:	68 7e a6 10 80       	push   $0x8010a67e
801079cd:	e8 d7 8b ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
801079d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801079d5:	8b 00                	mov    (%eax),%eax
801079d7:	83 e0 01             	and    $0x1,%eax
801079da:	85 c0                	test   %eax,%eax
801079dc:	75 0d                	jne    801079eb <copyuvm+0x6d>
      panic("copyuvm: page not present");
801079de:	83 ec 0c             	sub    $0xc,%esp
801079e1:	68 98 a6 10 80       	push   $0x8010a698
801079e6:	e8 be 8b ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
801079eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801079ee:	8b 00                	mov    (%eax),%eax
801079f0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801079f5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801079f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801079fb:	8b 00                	mov    (%eax),%eax
801079fd:	25 ff 0f 00 00       	and    $0xfff,%eax
80107a02:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107a05:	e8 96 ad ff ff       	call   801027a0 <kalloc>
80107a0a:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107a0d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107a11:	74 5d                	je     80107a70 <copyuvm+0xf2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107a13:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107a16:	05 00 00 00 80       	add    $0x80000000,%eax
80107a1b:	83 ec 04             	sub    $0x4,%esp
80107a1e:	68 00 10 00 00       	push   $0x1000
80107a23:	50                   	push   %eax
80107a24:	ff 75 e0             	push   -0x20(%ebp)
80107a27:	e8 15 d0 ff ff       	call   80104a41 <memmove>
80107a2c:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107a2f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107a32:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107a35:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107a3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a3e:	83 ec 0c             	sub    $0xc,%esp
80107a41:	52                   	push   %edx
80107a42:	51                   	push   %ecx
80107a43:	68 00 10 00 00       	push   $0x1000
80107a48:	50                   	push   %eax
80107a49:	ff 75 f0             	push   -0x10(%ebp)
80107a4c:	e8 01 f8 ff ff       	call   80107252 <mappages>
80107a51:	83 c4 20             	add    $0x20,%esp
80107a54:	85 c0                	test   %eax,%eax
80107a56:	78 1b                	js     80107a73 <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
80107a58:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a62:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107a65:	0f 82 3d ff ff ff    	jb     801079a8 <copyuvm+0x2a>
      goto bad;
  }
  return d;
80107a6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a6e:	eb 17                	jmp    80107a87 <copyuvm+0x109>
      goto bad;
80107a70:	90                   	nop
80107a71:	eb 01                	jmp    80107a74 <copyuvm+0xf6>
      goto bad;
80107a73:	90                   	nop

bad:
  freevm(d);
80107a74:	83 ec 0c             	sub    $0xc,%esp
80107a77:	ff 75 f0             	push   -0x10(%ebp)
80107a7a:	e8 25 fe ff ff       	call   801078a4 <freevm>
80107a7f:	83 c4 10             	add    $0x10,%esp
  return 0;
80107a82:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107a87:	c9                   	leave  
80107a88:	c3                   	ret    

80107a89 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107a89:	55                   	push   %ebp
80107a8a:	89 e5                	mov    %esp,%ebp
80107a8c:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107a8f:	83 ec 04             	sub    $0x4,%esp
80107a92:	6a 00                	push   $0x0
80107a94:	ff 75 0c             	push   0xc(%ebp)
80107a97:	ff 75 08             	push   0x8(%ebp)
80107a9a:	e8 1d f7 ff ff       	call   801071bc <walkpgdir>
80107a9f:	83 c4 10             	add    $0x10,%esp
80107aa2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80107aa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa8:	8b 00                	mov    (%eax),%eax
80107aaa:	83 e0 01             	and    $0x1,%eax
80107aad:	85 c0                	test   %eax,%eax
80107aaf:	75 07                	jne    80107ab8 <uva2ka+0x2f>
    return 0;
80107ab1:	b8 00 00 00 00       	mov    $0x0,%eax
80107ab6:	eb 22                	jmp    80107ada <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80107ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107abb:	8b 00                	mov    (%eax),%eax
80107abd:	83 e0 04             	and    $0x4,%eax
80107ac0:	85 c0                	test   %eax,%eax
80107ac2:	75 07                	jne    80107acb <uva2ka+0x42>
    return 0;
80107ac4:	b8 00 00 00 00       	mov    $0x0,%eax
80107ac9:	eb 0f                	jmp    80107ada <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80107acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ace:	8b 00                	mov    (%eax),%eax
80107ad0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ad5:	05 00 00 00 80       	add    $0x80000000,%eax
}
80107ada:	c9                   	leave  
80107adb:	c3                   	ret    

80107adc <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107adc:	55                   	push   %ebp
80107add:	89 e5                	mov    %esp,%ebp
80107adf:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80107ae2:	8b 45 10             	mov    0x10(%ebp),%eax
80107ae5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80107ae8:	eb 7f                	jmp    80107b69 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80107aea:	8b 45 0c             	mov    0xc(%ebp),%eax
80107aed:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107af2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80107af5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107af8:	83 ec 08             	sub    $0x8,%esp
80107afb:	50                   	push   %eax
80107afc:	ff 75 08             	push   0x8(%ebp)
80107aff:	e8 85 ff ff ff       	call   80107a89 <uva2ka>
80107b04:	83 c4 10             	add    $0x10,%esp
80107b07:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80107b0a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80107b0e:	75 07                	jne    80107b17 <copyout+0x3b>
      return -1;
80107b10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b15:	eb 61                	jmp    80107b78 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80107b17:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b1a:	2b 45 0c             	sub    0xc(%ebp),%eax
80107b1d:	05 00 10 00 00       	add    $0x1000,%eax
80107b22:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80107b25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b28:	3b 45 14             	cmp    0x14(%ebp),%eax
80107b2b:	76 06                	jbe    80107b33 <copyout+0x57>
      n = len;
80107b2d:	8b 45 14             	mov    0x14(%ebp),%eax
80107b30:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80107b33:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b36:	2b 45 ec             	sub    -0x14(%ebp),%eax
80107b39:	89 c2                	mov    %eax,%edx
80107b3b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107b3e:	01 d0                	add    %edx,%eax
80107b40:	83 ec 04             	sub    $0x4,%esp
80107b43:	ff 75 f0             	push   -0x10(%ebp)
80107b46:	ff 75 f4             	push   -0xc(%ebp)
80107b49:	50                   	push   %eax
80107b4a:	e8 f2 ce ff ff       	call   80104a41 <memmove>
80107b4f:	83 c4 10             	add    $0x10,%esp
    len -= n;
80107b52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b55:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80107b58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b5b:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80107b5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b61:	05 00 10 00 00       	add    $0x1000,%eax
80107b66:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80107b69:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80107b6d:	0f 85 77 ff ff ff    	jne    80107aea <copyout+0xe>
  }
  return 0;
80107b73:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107b78:	c9                   	leave  
80107b79:	c3                   	ret    

80107b7a <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80107b7a:	55                   	push   %ebp
80107b7b:	89 e5                	mov    %esp,%ebp
80107b7d:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107b80:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80107b87:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107b8a:	8b 40 08             	mov    0x8(%eax),%eax
80107b8d:	05 00 00 00 80       	add    $0x80000000,%eax
80107b92:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80107b95:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80107b9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b9f:	8b 40 24             	mov    0x24(%eax),%eax
80107ba2:	a3 00 41 19 80       	mov    %eax,0x80194100
  ncpu = 0;
80107ba7:	c7 05 40 6d 19 80 00 	movl   $0x0,0x80196d40
80107bae:	00 00 00 

  while(i<madt->len){
80107bb1:	90                   	nop
80107bb2:	e9 bd 00 00 00       	jmp    80107c74 <mpinit_uefi+0xfa>
    uchar *entry_type = ((uchar *)madt)+i;
80107bb7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107bba:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107bbd:	01 d0                	add    %edx,%eax
80107bbf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80107bc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107bc5:	0f b6 00             	movzbl (%eax),%eax
80107bc8:	0f b6 c0             	movzbl %al,%eax
80107bcb:	83 f8 05             	cmp    $0x5,%eax
80107bce:	0f 87 a0 00 00 00    	ja     80107c74 <mpinit_uefi+0xfa>
80107bd4:	8b 04 85 b4 a6 10 80 	mov    -0x7fef594c(,%eax,4),%eax
80107bdb:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80107bdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107be0:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80107be3:	a1 40 6d 19 80       	mov    0x80196d40,%eax
80107be8:	83 f8 03             	cmp    $0x3,%eax
80107beb:	7f 28                	jg     80107c15 <mpinit_uefi+0x9b>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80107bed:	8b 15 40 6d 19 80    	mov    0x80196d40,%edx
80107bf3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107bf6:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80107bfa:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80107c00:	81 c2 80 6a 19 80    	add    $0x80196a80,%edx
80107c06:	88 02                	mov    %al,(%edx)
          ncpu++;
80107c08:	a1 40 6d 19 80       	mov    0x80196d40,%eax
80107c0d:	83 c0 01             	add    $0x1,%eax
80107c10:	a3 40 6d 19 80       	mov    %eax,0x80196d40
        }
        i += lapic_entry->record_len;
80107c15:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107c18:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107c1c:	0f b6 c0             	movzbl %al,%eax
80107c1f:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107c22:	eb 50                	jmp    80107c74 <mpinit_uefi+0xfa>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80107c24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c27:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80107c2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107c2d:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80107c31:	a2 44 6d 19 80       	mov    %al,0x80196d44
        i += ioapic->record_len;
80107c36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107c39:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107c3d:	0f b6 c0             	movzbl %al,%eax
80107c40:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107c43:	eb 2f                	jmp    80107c74 <mpinit_uefi+0xfa>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80107c45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c48:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80107c4b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107c4e:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107c52:	0f b6 c0             	movzbl %al,%eax
80107c55:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107c58:	eb 1a                	jmp    80107c74 <mpinit_uefi+0xfa>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80107c5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c5d:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80107c60:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c63:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107c67:	0f b6 c0             	movzbl %al,%eax
80107c6a:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107c6d:	eb 05                	jmp    80107c74 <mpinit_uefi+0xfa>

      case 5:
        i = i + 0xC;
80107c6f:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80107c73:	90                   	nop
  while(i<madt->len){
80107c74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c77:	8b 40 04             	mov    0x4(%eax),%eax
80107c7a:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80107c7d:	0f 82 34 ff ff ff    	jb     80107bb7 <mpinit_uefi+0x3d>
    }
  }

}
80107c83:	90                   	nop
80107c84:	90                   	nop
80107c85:	c9                   	leave  
80107c86:	c3                   	ret    

80107c87 <inb>:
{
80107c87:	55                   	push   %ebp
80107c88:	89 e5                	mov    %esp,%ebp
80107c8a:	83 ec 14             	sub    $0x14,%esp
80107c8d:	8b 45 08             	mov    0x8(%ebp),%eax
80107c90:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107c94:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107c98:	89 c2                	mov    %eax,%edx
80107c9a:	ec                   	in     (%dx),%al
80107c9b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107c9e:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107ca2:	c9                   	leave  
80107ca3:	c3                   	ret    

80107ca4 <outb>:
{
80107ca4:	55                   	push   %ebp
80107ca5:	89 e5                	mov    %esp,%ebp
80107ca7:	83 ec 08             	sub    $0x8,%esp
80107caa:	8b 45 08             	mov    0x8(%ebp),%eax
80107cad:	8b 55 0c             	mov    0xc(%ebp),%edx
80107cb0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80107cb4:	89 d0                	mov    %edx,%eax
80107cb6:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107cb9:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107cbd:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107cc1:	ee                   	out    %al,(%dx)
}
80107cc2:	90                   	nop
80107cc3:	c9                   	leave  
80107cc4:	c3                   	ret    

80107cc5 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80107cc5:	55                   	push   %ebp
80107cc6:	89 e5                	mov    %esp,%ebp
80107cc8:	83 ec 28             	sub    $0x28,%esp
80107ccb:	8b 45 08             	mov    0x8(%ebp),%eax
80107cce:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80107cd1:	6a 00                	push   $0x0
80107cd3:	68 fa 03 00 00       	push   $0x3fa
80107cd8:	e8 c7 ff ff ff       	call   80107ca4 <outb>
80107cdd:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107ce0:	68 80 00 00 00       	push   $0x80
80107ce5:	68 fb 03 00 00       	push   $0x3fb
80107cea:	e8 b5 ff ff ff       	call   80107ca4 <outb>
80107cef:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107cf2:	6a 0c                	push   $0xc
80107cf4:	68 f8 03 00 00       	push   $0x3f8
80107cf9:	e8 a6 ff ff ff       	call   80107ca4 <outb>
80107cfe:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107d01:	6a 00                	push   $0x0
80107d03:	68 f9 03 00 00       	push   $0x3f9
80107d08:	e8 97 ff ff ff       	call   80107ca4 <outb>
80107d0d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107d10:	6a 03                	push   $0x3
80107d12:	68 fb 03 00 00       	push   $0x3fb
80107d17:	e8 88 ff ff ff       	call   80107ca4 <outb>
80107d1c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107d1f:	6a 00                	push   $0x0
80107d21:	68 fc 03 00 00       	push   $0x3fc
80107d26:	e8 79 ff ff ff       	call   80107ca4 <outb>
80107d2b:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
80107d2e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107d35:	eb 11                	jmp    80107d48 <uart_debug+0x83>
80107d37:	83 ec 0c             	sub    $0xc,%esp
80107d3a:	6a 0a                	push   $0xa
80107d3c:	e8 f6 ad ff ff       	call   80102b37 <microdelay>
80107d41:	83 c4 10             	add    $0x10,%esp
80107d44:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107d48:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107d4c:	7f 1a                	jg     80107d68 <uart_debug+0xa3>
80107d4e:	83 ec 0c             	sub    $0xc,%esp
80107d51:	68 fd 03 00 00       	push   $0x3fd
80107d56:	e8 2c ff ff ff       	call   80107c87 <inb>
80107d5b:	83 c4 10             	add    $0x10,%esp
80107d5e:	0f b6 c0             	movzbl %al,%eax
80107d61:	83 e0 20             	and    $0x20,%eax
80107d64:	85 c0                	test   %eax,%eax
80107d66:	74 cf                	je     80107d37 <uart_debug+0x72>
  outb(COM1+0, p);
80107d68:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80107d6c:	0f b6 c0             	movzbl %al,%eax
80107d6f:	83 ec 08             	sub    $0x8,%esp
80107d72:	50                   	push   %eax
80107d73:	68 f8 03 00 00       	push   $0x3f8
80107d78:	e8 27 ff ff ff       	call   80107ca4 <outb>
80107d7d:	83 c4 10             	add    $0x10,%esp
}
80107d80:	90                   	nop
80107d81:	c9                   	leave  
80107d82:	c3                   	ret    

80107d83 <uart_debugs>:

void uart_debugs(char *p){
80107d83:	55                   	push   %ebp
80107d84:	89 e5                	mov    %esp,%ebp
80107d86:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80107d89:	eb 1b                	jmp    80107da6 <uart_debugs+0x23>
    uart_debug(*p++);
80107d8b:	8b 45 08             	mov    0x8(%ebp),%eax
80107d8e:	8d 50 01             	lea    0x1(%eax),%edx
80107d91:	89 55 08             	mov    %edx,0x8(%ebp)
80107d94:	0f b6 00             	movzbl (%eax),%eax
80107d97:	0f be c0             	movsbl %al,%eax
80107d9a:	83 ec 0c             	sub    $0xc,%esp
80107d9d:	50                   	push   %eax
80107d9e:	e8 22 ff ff ff       	call   80107cc5 <uart_debug>
80107da3:	83 c4 10             	add    $0x10,%esp
  while(*p){
80107da6:	8b 45 08             	mov    0x8(%ebp),%eax
80107da9:	0f b6 00             	movzbl (%eax),%eax
80107dac:	84 c0                	test   %al,%al
80107dae:	75 db                	jne    80107d8b <uart_debugs+0x8>
  }
}
80107db0:	90                   	nop
80107db1:	90                   	nop
80107db2:	c9                   	leave  
80107db3:	c3                   	ret    

80107db4 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80107db4:	55                   	push   %ebp
80107db5:	89 e5                	mov    %esp,%ebp
80107db7:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107dba:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80107dc1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107dc4:	8b 50 14             	mov    0x14(%eax),%edx
80107dc7:	8b 40 10             	mov    0x10(%eax),%eax
80107dca:	a3 48 6d 19 80       	mov    %eax,0x80196d48
  gpu.vram_size = boot_param->graphic_config.frame_size;
80107dcf:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107dd2:	8b 50 1c             	mov    0x1c(%eax),%edx
80107dd5:	8b 40 18             	mov    0x18(%eax),%eax
80107dd8:	a3 50 6d 19 80       	mov    %eax,0x80196d50
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80107ddd:	8b 15 50 6d 19 80    	mov    0x80196d50,%edx
80107de3:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
80107de8:	29 d0                	sub    %edx,%eax
80107dea:	a3 4c 6d 19 80       	mov    %eax,0x80196d4c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80107def:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107df2:	8b 50 24             	mov    0x24(%eax),%edx
80107df5:	8b 40 20             	mov    0x20(%eax),%eax
80107df8:	a3 54 6d 19 80       	mov    %eax,0x80196d54
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80107dfd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107e00:	8b 50 2c             	mov    0x2c(%eax),%edx
80107e03:	8b 40 28             	mov    0x28(%eax),%eax
80107e06:	a3 58 6d 19 80       	mov    %eax,0x80196d58
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80107e0b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107e0e:	8b 50 34             	mov    0x34(%eax),%edx
80107e11:	8b 40 30             	mov    0x30(%eax),%eax
80107e14:	a3 5c 6d 19 80       	mov    %eax,0x80196d5c
}
80107e19:	90                   	nop
80107e1a:	c9                   	leave  
80107e1b:	c3                   	ret    

80107e1c <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80107e1c:	55                   	push   %ebp
80107e1d:	89 e5                	mov    %esp,%ebp
80107e1f:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80107e22:	8b 15 5c 6d 19 80    	mov    0x80196d5c,%edx
80107e28:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e2b:	0f af d0             	imul   %eax,%edx
80107e2e:	8b 45 08             	mov    0x8(%ebp),%eax
80107e31:	01 d0                	add    %edx,%eax
80107e33:	c1 e0 02             	shl    $0x2,%eax
80107e36:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80107e39:	8b 15 4c 6d 19 80    	mov    0x80196d4c,%edx
80107e3f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107e42:	01 d0                	add    %edx,%eax
80107e44:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80107e47:	8b 45 10             	mov    0x10(%ebp),%eax
80107e4a:	0f b6 10             	movzbl (%eax),%edx
80107e4d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107e50:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80107e52:	8b 45 10             	mov    0x10(%ebp),%eax
80107e55:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80107e59:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107e5c:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80107e5f:	8b 45 10             	mov    0x10(%ebp),%eax
80107e62:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80107e66:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107e69:	88 50 02             	mov    %dl,0x2(%eax)
}
80107e6c:	90                   	nop
80107e6d:	c9                   	leave  
80107e6e:	c3                   	ret    

80107e6f <graphic_scroll_up>:

void graphic_scroll_up(int height){
80107e6f:	55                   	push   %ebp
80107e70:	89 e5                	mov    %esp,%ebp
80107e72:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80107e75:	8b 15 5c 6d 19 80    	mov    0x80196d5c,%edx
80107e7b:	8b 45 08             	mov    0x8(%ebp),%eax
80107e7e:	0f af c2             	imul   %edx,%eax
80107e81:	c1 e0 02             	shl    $0x2,%eax
80107e84:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80107e87:	a1 50 6d 19 80       	mov    0x80196d50,%eax
80107e8c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107e8f:	29 d0                	sub    %edx,%eax
80107e91:	8b 0d 4c 6d 19 80    	mov    0x80196d4c,%ecx
80107e97:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107e9a:	01 ca                	add    %ecx,%edx
80107e9c:	89 d1                	mov    %edx,%ecx
80107e9e:	8b 15 4c 6d 19 80    	mov    0x80196d4c,%edx
80107ea4:	83 ec 04             	sub    $0x4,%esp
80107ea7:	50                   	push   %eax
80107ea8:	51                   	push   %ecx
80107ea9:	52                   	push   %edx
80107eaa:	e8 92 cb ff ff       	call   80104a41 <memmove>
80107eaf:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80107eb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eb5:	8b 0d 4c 6d 19 80    	mov    0x80196d4c,%ecx
80107ebb:	8b 15 50 6d 19 80    	mov    0x80196d50,%edx
80107ec1:	01 ca                	add    %ecx,%edx
80107ec3:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80107ec6:	29 ca                	sub    %ecx,%edx
80107ec8:	83 ec 04             	sub    $0x4,%esp
80107ecb:	50                   	push   %eax
80107ecc:	6a 00                	push   $0x0
80107ece:	52                   	push   %edx
80107ecf:	e8 ae ca ff ff       	call   80104982 <memset>
80107ed4:	83 c4 10             	add    $0x10,%esp
}
80107ed7:	90                   	nop
80107ed8:	c9                   	leave  
80107ed9:	c3                   	ret    

80107eda <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80107eda:	55                   	push   %ebp
80107edb:	89 e5                	mov    %esp,%ebp
80107edd:	53                   	push   %ebx
80107ede:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80107ee1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107ee8:	e9 b1 00 00 00       	jmp    80107f9e <font_render+0xc4>
    for(int j=14;j>-1;j--){
80107eed:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80107ef4:	e9 97 00 00 00       	jmp    80107f90 <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
80107ef9:	8b 45 10             	mov    0x10(%ebp),%eax
80107efc:	83 e8 20             	sub    $0x20,%eax
80107eff:	6b d0 1e             	imul   $0x1e,%eax,%edx
80107f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f05:	01 d0                	add    %edx,%eax
80107f07:	0f b7 84 00 e0 a6 10 	movzwl -0x7fef5920(%eax,%eax,1),%eax
80107f0e:	80 
80107f0f:	0f b7 d0             	movzwl %ax,%edx
80107f12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f15:	bb 01 00 00 00       	mov    $0x1,%ebx
80107f1a:	89 c1                	mov    %eax,%ecx
80107f1c:	d3 e3                	shl    %cl,%ebx
80107f1e:	89 d8                	mov    %ebx,%eax
80107f20:	21 d0                	and    %edx,%eax
80107f22:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80107f25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f28:	ba 01 00 00 00       	mov    $0x1,%edx
80107f2d:	89 c1                	mov    %eax,%ecx
80107f2f:	d3 e2                	shl    %cl,%edx
80107f31:	89 d0                	mov    %edx,%eax
80107f33:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80107f36:	75 2b                	jne    80107f63 <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80107f38:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f3e:	01 c2                	add    %eax,%edx
80107f40:	b8 0e 00 00 00       	mov    $0xe,%eax
80107f45:	2b 45 f0             	sub    -0x10(%ebp),%eax
80107f48:	89 c1                	mov    %eax,%ecx
80107f4a:	8b 45 08             	mov    0x8(%ebp),%eax
80107f4d:	01 c8                	add    %ecx,%eax
80107f4f:	83 ec 04             	sub    $0x4,%esp
80107f52:	68 e0 f4 10 80       	push   $0x8010f4e0
80107f57:	52                   	push   %edx
80107f58:	50                   	push   %eax
80107f59:	e8 be fe ff ff       	call   80107e1c <graphic_draw_pixel>
80107f5e:	83 c4 10             	add    $0x10,%esp
80107f61:	eb 29                	jmp    80107f8c <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
80107f63:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f69:	01 c2                	add    %eax,%edx
80107f6b:	b8 0e 00 00 00       	mov    $0xe,%eax
80107f70:	2b 45 f0             	sub    -0x10(%ebp),%eax
80107f73:	89 c1                	mov    %eax,%ecx
80107f75:	8b 45 08             	mov    0x8(%ebp),%eax
80107f78:	01 c8                	add    %ecx,%eax
80107f7a:	83 ec 04             	sub    $0x4,%esp
80107f7d:	68 60 6d 19 80       	push   $0x80196d60
80107f82:	52                   	push   %edx
80107f83:	50                   	push   %eax
80107f84:	e8 93 fe ff ff       	call   80107e1c <graphic_draw_pixel>
80107f89:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80107f8c:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80107f90:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107f94:	0f 89 5f ff ff ff    	jns    80107ef9 <font_render+0x1f>
  for(int i=0;i<30;i++){
80107f9a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107f9e:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80107fa2:	0f 8e 45 ff ff ff    	jle    80107eed <font_render+0x13>
      }
    }
  }
}
80107fa8:	90                   	nop
80107fa9:	90                   	nop
80107faa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107fad:	c9                   	leave  
80107fae:	c3                   	ret    

80107faf <font_render_string>:

void font_render_string(char *string,int row){
80107faf:	55                   	push   %ebp
80107fb0:	89 e5                	mov    %esp,%ebp
80107fb2:	53                   	push   %ebx
80107fb3:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80107fb6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
80107fbd:	eb 33                	jmp    80107ff2 <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
80107fbf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107fc2:	8b 45 08             	mov    0x8(%ebp),%eax
80107fc5:	01 d0                	add    %edx,%eax
80107fc7:	0f b6 00             	movzbl (%eax),%eax
80107fca:	0f be c8             	movsbl %al,%ecx
80107fcd:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fd0:	6b d0 1e             	imul   $0x1e,%eax,%edx
80107fd3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80107fd6:	89 d8                	mov    %ebx,%eax
80107fd8:	c1 e0 04             	shl    $0x4,%eax
80107fdb:	29 d8                	sub    %ebx,%eax
80107fdd:	83 c0 02             	add    $0x2,%eax
80107fe0:	83 ec 04             	sub    $0x4,%esp
80107fe3:	51                   	push   %ecx
80107fe4:	52                   	push   %edx
80107fe5:	50                   	push   %eax
80107fe6:	e8 ef fe ff ff       	call   80107eda <font_render>
80107feb:	83 c4 10             	add    $0x10,%esp
    i++;
80107fee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80107ff2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107ff5:	8b 45 08             	mov    0x8(%ebp),%eax
80107ff8:	01 d0                	add    %edx,%eax
80107ffa:	0f b6 00             	movzbl (%eax),%eax
80107ffd:	84 c0                	test   %al,%al
80107fff:	74 06                	je     80108007 <font_render_string+0x58>
80108001:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108005:	7e b8                	jle    80107fbf <font_render_string+0x10>
  }
}
80108007:	90                   	nop
80108008:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010800b:	c9                   	leave  
8010800c:	c3                   	ret    

8010800d <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
8010800d:	55                   	push   %ebp
8010800e:	89 e5                	mov    %esp,%ebp
80108010:	53                   	push   %ebx
80108011:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108014:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010801b:	eb 6b                	jmp    80108088 <pci_init+0x7b>
    for(int j=0;j<32;j++){
8010801d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108024:	eb 58                	jmp    8010807e <pci_init+0x71>
      for(int k=0;k<8;k++){
80108026:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010802d:	eb 45                	jmp    80108074 <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
8010802f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108032:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108035:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108038:	83 ec 0c             	sub    $0xc,%esp
8010803b:	8d 5d e8             	lea    -0x18(%ebp),%ebx
8010803e:	53                   	push   %ebx
8010803f:	6a 00                	push   $0x0
80108041:	51                   	push   %ecx
80108042:	52                   	push   %edx
80108043:	50                   	push   %eax
80108044:	e8 b0 00 00 00       	call   801080f9 <pci_access_config>
80108049:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
8010804c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010804f:	0f b7 c0             	movzwl %ax,%eax
80108052:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108057:	74 17                	je     80108070 <pci_init+0x63>
        pci_init_device(i,j,k);
80108059:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010805c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010805f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108062:	83 ec 04             	sub    $0x4,%esp
80108065:	51                   	push   %ecx
80108066:	52                   	push   %edx
80108067:	50                   	push   %eax
80108068:	e8 37 01 00 00       	call   801081a4 <pci_init_device>
8010806d:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108070:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108074:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108078:	7e b5                	jle    8010802f <pci_init+0x22>
    for(int j=0;j<32;j++){
8010807a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010807e:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108082:	7e a2                	jle    80108026 <pci_init+0x19>
  for(int i=0;i<256;i++){
80108084:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108088:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010808f:	7e 8c                	jle    8010801d <pci_init+0x10>
      }
      }
    }
  }
}
80108091:	90                   	nop
80108092:	90                   	nop
80108093:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108096:	c9                   	leave  
80108097:	c3                   	ret    

80108098 <pci_write_config>:

void pci_write_config(uint config){
80108098:	55                   	push   %ebp
80108099:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
8010809b:	8b 45 08             	mov    0x8(%ebp),%eax
8010809e:	ba f8 0c 00 00       	mov    $0xcf8,%edx
801080a3:	89 c0                	mov    %eax,%eax
801080a5:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801080a6:	90                   	nop
801080a7:	5d                   	pop    %ebp
801080a8:	c3                   	ret    

801080a9 <pci_write_data>:

void pci_write_data(uint config){
801080a9:	55                   	push   %ebp
801080aa:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
801080ac:	8b 45 08             	mov    0x8(%ebp),%eax
801080af:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801080b4:	89 c0                	mov    %eax,%eax
801080b6:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801080b7:	90                   	nop
801080b8:	5d                   	pop    %ebp
801080b9:	c3                   	ret    

801080ba <pci_read_config>:
uint pci_read_config(){
801080ba:	55                   	push   %ebp
801080bb:	89 e5                	mov    %esp,%ebp
801080bd:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
801080c0:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801080c5:	ed                   	in     (%dx),%eax
801080c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
801080c9:	83 ec 0c             	sub    $0xc,%esp
801080cc:	68 c8 00 00 00       	push   $0xc8
801080d1:	e8 61 aa ff ff       	call   80102b37 <microdelay>
801080d6:	83 c4 10             	add    $0x10,%esp
  return data;
801080d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801080dc:	c9                   	leave  
801080dd:	c3                   	ret    

801080de <pci_test>:


void pci_test(){
801080de:	55                   	push   %ebp
801080df:	89 e5                	mov    %esp,%ebp
801080e1:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
801080e4:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
801080eb:	ff 75 fc             	push   -0x4(%ebp)
801080ee:	e8 a5 ff ff ff       	call   80108098 <pci_write_config>
801080f3:	83 c4 04             	add    $0x4,%esp
}
801080f6:	90                   	nop
801080f7:	c9                   	leave  
801080f8:	c3                   	ret    

801080f9 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
801080f9:	55                   	push   %ebp
801080fa:	89 e5                	mov    %esp,%ebp
801080fc:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801080ff:	8b 45 08             	mov    0x8(%ebp),%eax
80108102:	c1 e0 10             	shl    $0x10,%eax
80108105:	25 00 00 ff 00       	and    $0xff0000,%eax
8010810a:	89 c2                	mov    %eax,%edx
8010810c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010810f:	c1 e0 0b             	shl    $0xb,%eax
80108112:	0f b7 c0             	movzwl %ax,%eax
80108115:	09 c2                	or     %eax,%edx
80108117:	8b 45 10             	mov    0x10(%ebp),%eax
8010811a:	c1 e0 08             	shl    $0x8,%eax
8010811d:	25 00 07 00 00       	and    $0x700,%eax
80108122:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108124:	8b 45 14             	mov    0x14(%ebp),%eax
80108127:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010812c:	09 d0                	or     %edx,%eax
8010812e:	0d 00 00 00 80       	or     $0x80000000,%eax
80108133:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80108136:	ff 75 f4             	push   -0xc(%ebp)
80108139:	e8 5a ff ff ff       	call   80108098 <pci_write_config>
8010813e:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108141:	e8 74 ff ff ff       	call   801080ba <pci_read_config>
80108146:	8b 55 18             	mov    0x18(%ebp),%edx
80108149:	89 02                	mov    %eax,(%edx)
}
8010814b:	90                   	nop
8010814c:	c9                   	leave  
8010814d:	c3                   	ret    

8010814e <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
8010814e:	55                   	push   %ebp
8010814f:	89 e5                	mov    %esp,%ebp
80108151:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108154:	8b 45 08             	mov    0x8(%ebp),%eax
80108157:	c1 e0 10             	shl    $0x10,%eax
8010815a:	25 00 00 ff 00       	and    $0xff0000,%eax
8010815f:	89 c2                	mov    %eax,%edx
80108161:	8b 45 0c             	mov    0xc(%ebp),%eax
80108164:	c1 e0 0b             	shl    $0xb,%eax
80108167:	0f b7 c0             	movzwl %ax,%eax
8010816a:	09 c2                	or     %eax,%edx
8010816c:	8b 45 10             	mov    0x10(%ebp),%eax
8010816f:	c1 e0 08             	shl    $0x8,%eax
80108172:	25 00 07 00 00       	and    $0x700,%eax
80108177:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108179:	8b 45 14             	mov    0x14(%ebp),%eax
8010817c:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108181:	09 d0                	or     %edx,%eax
80108183:	0d 00 00 00 80       	or     $0x80000000,%eax
80108188:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
8010818b:	ff 75 fc             	push   -0x4(%ebp)
8010818e:	e8 05 ff ff ff       	call   80108098 <pci_write_config>
80108193:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108196:	ff 75 18             	push   0x18(%ebp)
80108199:	e8 0b ff ff ff       	call   801080a9 <pci_write_data>
8010819e:	83 c4 04             	add    $0x4,%esp
}
801081a1:	90                   	nop
801081a2:	c9                   	leave  
801081a3:	c3                   	ret    

801081a4 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
801081a4:	55                   	push   %ebp
801081a5:	89 e5                	mov    %esp,%ebp
801081a7:	53                   	push   %ebx
801081a8:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
801081ab:	8b 45 08             	mov    0x8(%ebp),%eax
801081ae:	a2 64 6d 19 80       	mov    %al,0x80196d64
  dev.device_num = device_num;
801081b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801081b6:	a2 65 6d 19 80       	mov    %al,0x80196d65
  dev.function_num = function_num;
801081bb:	8b 45 10             	mov    0x10(%ebp),%eax
801081be:	a2 66 6d 19 80       	mov    %al,0x80196d66
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
801081c3:	ff 75 10             	push   0x10(%ebp)
801081c6:	ff 75 0c             	push   0xc(%ebp)
801081c9:	ff 75 08             	push   0x8(%ebp)
801081cc:	68 24 bd 10 80       	push   $0x8010bd24
801081d1:	e8 1e 82 ff ff       	call   801003f4 <cprintf>
801081d6:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
801081d9:	83 ec 0c             	sub    $0xc,%esp
801081dc:	8d 45 ec             	lea    -0x14(%ebp),%eax
801081df:	50                   	push   %eax
801081e0:	6a 00                	push   $0x0
801081e2:	ff 75 10             	push   0x10(%ebp)
801081e5:	ff 75 0c             	push   0xc(%ebp)
801081e8:	ff 75 08             	push   0x8(%ebp)
801081eb:	e8 09 ff ff ff       	call   801080f9 <pci_access_config>
801081f0:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
801081f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081f6:	c1 e8 10             	shr    $0x10,%eax
801081f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
801081fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081ff:	25 ff ff 00 00       	and    $0xffff,%eax
80108204:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108207:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010820a:	a3 68 6d 19 80       	mov    %eax,0x80196d68
  dev.vendor_id = vendor_id;
8010820f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108212:	a3 6c 6d 19 80       	mov    %eax,0x80196d6c
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108217:	83 ec 04             	sub    $0x4,%esp
8010821a:	ff 75 f0             	push   -0x10(%ebp)
8010821d:	ff 75 f4             	push   -0xc(%ebp)
80108220:	68 58 bd 10 80       	push   $0x8010bd58
80108225:	e8 ca 81 ff ff       	call   801003f4 <cprintf>
8010822a:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
8010822d:	83 ec 0c             	sub    $0xc,%esp
80108230:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108233:	50                   	push   %eax
80108234:	6a 08                	push   $0x8
80108236:	ff 75 10             	push   0x10(%ebp)
80108239:	ff 75 0c             	push   0xc(%ebp)
8010823c:	ff 75 08             	push   0x8(%ebp)
8010823f:	e8 b5 fe ff ff       	call   801080f9 <pci_access_config>
80108244:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108247:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010824a:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
8010824d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108250:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108253:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108256:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108259:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010825c:	0f b6 c0             	movzbl %al,%eax
8010825f:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108262:	c1 eb 18             	shr    $0x18,%ebx
80108265:	83 ec 0c             	sub    $0xc,%esp
80108268:	51                   	push   %ecx
80108269:	52                   	push   %edx
8010826a:	50                   	push   %eax
8010826b:	53                   	push   %ebx
8010826c:	68 7c bd 10 80       	push   $0x8010bd7c
80108271:	e8 7e 81 ff ff       	call   801003f4 <cprintf>
80108276:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108279:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010827c:	c1 e8 18             	shr    $0x18,%eax
8010827f:	a2 70 6d 19 80       	mov    %al,0x80196d70
  dev.sub_class = (data>>16)&0xFF;
80108284:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108287:	c1 e8 10             	shr    $0x10,%eax
8010828a:	a2 71 6d 19 80       	mov    %al,0x80196d71
  dev.interface = (data>>8)&0xFF;
8010828f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108292:	c1 e8 08             	shr    $0x8,%eax
80108295:	a2 72 6d 19 80       	mov    %al,0x80196d72
  dev.revision_id = data&0xFF;
8010829a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010829d:	a2 73 6d 19 80       	mov    %al,0x80196d73
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
801082a2:	83 ec 0c             	sub    $0xc,%esp
801082a5:	8d 45 ec             	lea    -0x14(%ebp),%eax
801082a8:	50                   	push   %eax
801082a9:	6a 10                	push   $0x10
801082ab:	ff 75 10             	push   0x10(%ebp)
801082ae:	ff 75 0c             	push   0xc(%ebp)
801082b1:	ff 75 08             	push   0x8(%ebp)
801082b4:	e8 40 fe ff ff       	call   801080f9 <pci_access_config>
801082b9:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
801082bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082bf:	a3 74 6d 19 80       	mov    %eax,0x80196d74
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
801082c4:	83 ec 0c             	sub    $0xc,%esp
801082c7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801082ca:	50                   	push   %eax
801082cb:	6a 14                	push   $0x14
801082cd:	ff 75 10             	push   0x10(%ebp)
801082d0:	ff 75 0c             	push   0xc(%ebp)
801082d3:	ff 75 08             	push   0x8(%ebp)
801082d6:	e8 1e fe ff ff       	call   801080f9 <pci_access_config>
801082db:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
801082de:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082e1:	a3 78 6d 19 80       	mov    %eax,0x80196d78
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
801082e6:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
801082ed:	75 5a                	jne    80108349 <pci_init_device+0x1a5>
801082ef:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
801082f6:	75 51                	jne    80108349 <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
801082f8:	83 ec 0c             	sub    $0xc,%esp
801082fb:	68 c1 bd 10 80       	push   $0x8010bdc1
80108300:	e8 ef 80 ff ff       	call   801003f4 <cprintf>
80108305:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108308:	83 ec 0c             	sub    $0xc,%esp
8010830b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010830e:	50                   	push   %eax
8010830f:	68 f0 00 00 00       	push   $0xf0
80108314:	ff 75 10             	push   0x10(%ebp)
80108317:	ff 75 0c             	push   0xc(%ebp)
8010831a:	ff 75 08             	push   0x8(%ebp)
8010831d:	e8 d7 fd ff ff       	call   801080f9 <pci_access_config>
80108322:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108325:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108328:	83 ec 08             	sub    $0x8,%esp
8010832b:	50                   	push   %eax
8010832c:	68 db bd 10 80       	push   $0x8010bddb
80108331:	e8 be 80 ff ff       	call   801003f4 <cprintf>
80108336:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108339:	83 ec 0c             	sub    $0xc,%esp
8010833c:	68 64 6d 19 80       	push   $0x80196d64
80108341:	e8 09 00 00 00       	call   8010834f <i8254_init>
80108346:	83 c4 10             	add    $0x10,%esp
  }
}
80108349:	90                   	nop
8010834a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010834d:	c9                   	leave  
8010834e:	c3                   	ret    

8010834f <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
8010834f:	55                   	push   %ebp
80108350:	89 e5                	mov    %esp,%ebp
80108352:	53                   	push   %ebx
80108353:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108356:	8b 45 08             	mov    0x8(%ebp),%eax
80108359:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010835d:	0f b6 c8             	movzbl %al,%ecx
80108360:	8b 45 08             	mov    0x8(%ebp),%eax
80108363:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108367:	0f b6 d0             	movzbl %al,%edx
8010836a:	8b 45 08             	mov    0x8(%ebp),%eax
8010836d:	0f b6 00             	movzbl (%eax),%eax
80108370:	0f b6 c0             	movzbl %al,%eax
80108373:	83 ec 0c             	sub    $0xc,%esp
80108376:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108379:	53                   	push   %ebx
8010837a:	6a 04                	push   $0x4
8010837c:	51                   	push   %ecx
8010837d:	52                   	push   %edx
8010837e:	50                   	push   %eax
8010837f:	e8 75 fd ff ff       	call   801080f9 <pci_access_config>
80108384:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108387:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010838a:	83 c8 04             	or     $0x4,%eax
8010838d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108390:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108393:	8b 45 08             	mov    0x8(%ebp),%eax
80108396:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010839a:	0f b6 c8             	movzbl %al,%ecx
8010839d:	8b 45 08             	mov    0x8(%ebp),%eax
801083a0:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801083a4:	0f b6 d0             	movzbl %al,%edx
801083a7:	8b 45 08             	mov    0x8(%ebp),%eax
801083aa:	0f b6 00             	movzbl (%eax),%eax
801083ad:	0f b6 c0             	movzbl %al,%eax
801083b0:	83 ec 0c             	sub    $0xc,%esp
801083b3:	53                   	push   %ebx
801083b4:	6a 04                	push   $0x4
801083b6:	51                   	push   %ecx
801083b7:	52                   	push   %edx
801083b8:	50                   	push   %eax
801083b9:	e8 90 fd ff ff       	call   8010814e <pci_write_config_register>
801083be:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
801083c1:	8b 45 08             	mov    0x8(%ebp),%eax
801083c4:	8b 40 10             	mov    0x10(%eax),%eax
801083c7:	05 00 00 00 40       	add    $0x40000000,%eax
801083cc:	a3 7c 6d 19 80       	mov    %eax,0x80196d7c
  uint *ctrl = (uint *)base_addr;
801083d1:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801083d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
801083d9:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801083de:	05 d8 00 00 00       	add    $0xd8,%eax
801083e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
801083e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083e9:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
801083ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083f2:	8b 00                	mov    (%eax),%eax
801083f4:	0d 00 00 00 04       	or     $0x4000000,%eax
801083f9:	89 c2                	mov    %eax,%edx
801083fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083fe:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108400:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108403:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108409:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010840c:	8b 00                	mov    (%eax),%eax
8010840e:	83 c8 40             	or     $0x40,%eax
80108411:	89 c2                	mov    %eax,%edx
80108413:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108416:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108418:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010841b:	8b 10                	mov    (%eax),%edx
8010841d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108420:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108422:	83 ec 0c             	sub    $0xc,%esp
80108425:	68 f0 bd 10 80       	push   $0x8010bdf0
8010842a:	e8 c5 7f ff ff       	call   801003f4 <cprintf>
8010842f:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108432:	e8 69 a3 ff ff       	call   801027a0 <kalloc>
80108437:	a3 88 6d 19 80       	mov    %eax,0x80196d88
  *intr_addr = 0;
8010843c:	a1 88 6d 19 80       	mov    0x80196d88,%eax
80108441:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108447:	a1 88 6d 19 80       	mov    0x80196d88,%eax
8010844c:	83 ec 08             	sub    $0x8,%esp
8010844f:	50                   	push   %eax
80108450:	68 12 be 10 80       	push   $0x8010be12
80108455:	e8 9a 7f ff ff       	call   801003f4 <cprintf>
8010845a:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
8010845d:	e8 50 00 00 00       	call   801084b2 <i8254_init_recv>
  i8254_init_send();
80108462:	e8 69 03 00 00       	call   801087d0 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108467:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010846e:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108471:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108478:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
8010847b:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108482:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108485:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010848c:	0f b6 c0             	movzbl %al,%eax
8010848f:	83 ec 0c             	sub    $0xc,%esp
80108492:	53                   	push   %ebx
80108493:	51                   	push   %ecx
80108494:	52                   	push   %edx
80108495:	50                   	push   %eax
80108496:	68 20 be 10 80       	push   $0x8010be20
8010849b:	e8 54 7f ff ff       	call   801003f4 <cprintf>
801084a0:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
801084a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084a6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
801084ac:	90                   	nop
801084ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801084b0:	c9                   	leave  
801084b1:	c3                   	ret    

801084b2 <i8254_init_recv>:

void i8254_init_recv(){
801084b2:	55                   	push   %ebp
801084b3:	89 e5                	mov    %esp,%ebp
801084b5:	57                   	push   %edi
801084b6:	56                   	push   %esi
801084b7:	53                   	push   %ebx
801084b8:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
801084bb:	83 ec 0c             	sub    $0xc,%esp
801084be:	6a 00                	push   $0x0
801084c0:	e8 e8 04 00 00       	call   801089ad <i8254_read_eeprom>
801084c5:	83 c4 10             	add    $0x10,%esp
801084c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
801084cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
801084ce:	a2 80 6d 19 80       	mov    %al,0x80196d80
  mac_addr[1] = data_l>>8;
801084d3:	8b 45 d8             	mov    -0x28(%ebp),%eax
801084d6:	c1 e8 08             	shr    $0x8,%eax
801084d9:	a2 81 6d 19 80       	mov    %al,0x80196d81
  uint data_m = i8254_read_eeprom(0x1);
801084de:	83 ec 0c             	sub    $0xc,%esp
801084e1:	6a 01                	push   $0x1
801084e3:	e8 c5 04 00 00       	call   801089ad <i8254_read_eeprom>
801084e8:	83 c4 10             	add    $0x10,%esp
801084eb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
801084ee:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801084f1:	a2 82 6d 19 80       	mov    %al,0x80196d82
  mac_addr[3] = data_m>>8;
801084f6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801084f9:	c1 e8 08             	shr    $0x8,%eax
801084fc:	a2 83 6d 19 80       	mov    %al,0x80196d83
  uint data_h = i8254_read_eeprom(0x2);
80108501:	83 ec 0c             	sub    $0xc,%esp
80108504:	6a 02                	push   $0x2
80108506:	e8 a2 04 00 00       	call   801089ad <i8254_read_eeprom>
8010850b:	83 c4 10             	add    $0x10,%esp
8010850e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108511:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108514:	a2 84 6d 19 80       	mov    %al,0x80196d84
  mac_addr[5] = data_h>>8;
80108519:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010851c:	c1 e8 08             	shr    $0x8,%eax
8010851f:	a2 85 6d 19 80       	mov    %al,0x80196d85
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108524:	0f b6 05 85 6d 19 80 	movzbl 0x80196d85,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010852b:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
8010852e:	0f b6 05 84 6d 19 80 	movzbl 0x80196d84,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108535:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108538:	0f b6 05 83 6d 19 80 	movzbl 0x80196d83,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010853f:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108542:	0f b6 05 82 6d 19 80 	movzbl 0x80196d82,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108549:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
8010854c:	0f b6 05 81 6d 19 80 	movzbl 0x80196d81,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108553:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108556:	0f b6 05 80 6d 19 80 	movzbl 0x80196d80,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010855d:	0f b6 c0             	movzbl %al,%eax
80108560:	83 ec 04             	sub    $0x4,%esp
80108563:	57                   	push   %edi
80108564:	56                   	push   %esi
80108565:	53                   	push   %ebx
80108566:	51                   	push   %ecx
80108567:	52                   	push   %edx
80108568:	50                   	push   %eax
80108569:	68 38 be 10 80       	push   $0x8010be38
8010856e:	e8 81 7e ff ff       	call   801003f4 <cprintf>
80108573:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108576:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
8010857b:	05 00 54 00 00       	add    $0x5400,%eax
80108580:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108583:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108588:	05 04 54 00 00       	add    $0x5404,%eax
8010858d:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108590:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108593:	c1 e0 10             	shl    $0x10,%eax
80108596:	0b 45 d8             	or     -0x28(%ebp),%eax
80108599:	89 c2                	mov    %eax,%edx
8010859b:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010859e:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
801085a0:	8b 45 d0             	mov    -0x30(%ebp),%eax
801085a3:	0d 00 00 00 80       	or     $0x80000000,%eax
801085a8:	89 c2                	mov    %eax,%edx
801085aa:	8b 45 c8             	mov    -0x38(%ebp),%eax
801085ad:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
801085af:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801085b4:	05 00 52 00 00       	add    $0x5200,%eax
801085b9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
801085bc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801085c3:	eb 19                	jmp    801085de <i8254_init_recv+0x12c>
    mta[i] = 0;
801085c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801085c8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801085cf:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801085d2:	01 d0                	add    %edx,%eax
801085d4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
801085da:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801085de:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
801085e2:	7e e1                	jle    801085c5 <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
801085e4:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801085e9:	05 d0 00 00 00       	add    $0xd0,%eax
801085ee:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
801085f1:	8b 45 c0             	mov    -0x40(%ebp),%eax
801085f4:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
801085fa:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801085ff:	05 c8 00 00 00       	add    $0xc8,%eax
80108604:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108607:	8b 45 bc             	mov    -0x44(%ebp),%eax
8010860a:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108610:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108615:	05 28 28 00 00       	add    $0x2828,%eax
8010861a:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
8010861d:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108620:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108626:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
8010862b:	05 00 01 00 00       	add    $0x100,%eax
80108630:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108633:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108636:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
8010863c:	e8 5f a1 ff ff       	call   801027a0 <kalloc>
80108641:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108644:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108649:	05 00 28 00 00       	add    $0x2800,%eax
8010864e:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108651:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108656:	05 04 28 00 00       	add    $0x2804,%eax
8010865b:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
8010865e:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108663:	05 08 28 00 00       	add    $0x2808,%eax
80108668:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
8010866b:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108670:	05 10 28 00 00       	add    $0x2810,%eax
80108675:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108678:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
8010867d:	05 18 28 00 00       	add    $0x2818,%eax
80108682:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108685:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108688:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010868e:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108691:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108693:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108696:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
8010869c:	8b 45 a4             	mov    -0x5c(%ebp),%eax
8010869f:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
801086a5:	8b 45 a0             	mov    -0x60(%ebp),%eax
801086a8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
801086ae:	8b 45 9c             	mov    -0x64(%ebp),%eax
801086b1:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
801086b7:	8b 45 b0             	mov    -0x50(%ebp),%eax
801086ba:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
801086bd:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801086c4:	eb 73                	jmp    80108739 <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
801086c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801086c9:	c1 e0 04             	shl    $0x4,%eax
801086cc:	89 c2                	mov    %eax,%edx
801086ce:	8b 45 98             	mov    -0x68(%ebp),%eax
801086d1:	01 d0                	add    %edx,%eax
801086d3:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
801086da:	8b 45 e0             	mov    -0x20(%ebp),%eax
801086dd:	c1 e0 04             	shl    $0x4,%eax
801086e0:	89 c2                	mov    %eax,%edx
801086e2:	8b 45 98             	mov    -0x68(%ebp),%eax
801086e5:	01 d0                	add    %edx,%eax
801086e7:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
801086ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
801086f0:	c1 e0 04             	shl    $0x4,%eax
801086f3:	89 c2                	mov    %eax,%edx
801086f5:	8b 45 98             	mov    -0x68(%ebp),%eax
801086f8:	01 d0                	add    %edx,%eax
801086fa:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108700:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108703:	c1 e0 04             	shl    $0x4,%eax
80108706:	89 c2                	mov    %eax,%edx
80108708:	8b 45 98             	mov    -0x68(%ebp),%eax
8010870b:	01 d0                	add    %edx,%eax
8010870d:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108711:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108714:	c1 e0 04             	shl    $0x4,%eax
80108717:	89 c2                	mov    %eax,%edx
80108719:	8b 45 98             	mov    -0x68(%ebp),%eax
8010871c:	01 d0                	add    %edx,%eax
8010871e:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108722:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108725:	c1 e0 04             	shl    $0x4,%eax
80108728:	89 c2                	mov    %eax,%edx
8010872a:	8b 45 98             	mov    -0x68(%ebp),%eax
8010872d:	01 d0                	add    %edx,%eax
8010872f:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108735:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108739:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108740:	7e 84                	jle    801086c6 <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108742:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108749:	eb 57                	jmp    801087a2 <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
8010874b:	e8 50 a0 ff ff       	call   801027a0 <kalloc>
80108750:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108753:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108757:	75 12                	jne    8010876b <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80108759:	83 ec 0c             	sub    $0xc,%esp
8010875c:	68 58 be 10 80       	push   $0x8010be58
80108761:	e8 8e 7c ff ff       	call   801003f4 <cprintf>
80108766:	83 c4 10             	add    $0x10,%esp
      break;
80108769:	eb 3d                	jmp    801087a8 <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
8010876b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010876e:	c1 e0 04             	shl    $0x4,%eax
80108771:	89 c2                	mov    %eax,%edx
80108773:	8b 45 98             	mov    -0x68(%ebp),%eax
80108776:	01 d0                	add    %edx,%eax
80108778:	8b 55 94             	mov    -0x6c(%ebp),%edx
8010877b:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108781:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108783:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108786:	83 c0 01             	add    $0x1,%eax
80108789:	c1 e0 04             	shl    $0x4,%eax
8010878c:	89 c2                	mov    %eax,%edx
8010878e:	8b 45 98             	mov    -0x68(%ebp),%eax
80108791:	01 d0                	add    %edx,%eax
80108793:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108796:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
8010879c:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
8010879e:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
801087a2:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
801087a6:	7e a3                	jle    8010874b <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
801087a8:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801087ab:	8b 00                	mov    (%eax),%eax
801087ad:	83 c8 02             	or     $0x2,%eax
801087b0:	89 c2                	mov    %eax,%edx
801087b2:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801087b5:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
801087b7:	83 ec 0c             	sub    $0xc,%esp
801087ba:	68 78 be 10 80       	push   $0x8010be78
801087bf:	e8 30 7c ff ff       	call   801003f4 <cprintf>
801087c4:	83 c4 10             	add    $0x10,%esp
}
801087c7:	90                   	nop
801087c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801087cb:	5b                   	pop    %ebx
801087cc:	5e                   	pop    %esi
801087cd:	5f                   	pop    %edi
801087ce:	5d                   	pop    %ebp
801087cf:	c3                   	ret    

801087d0 <i8254_init_send>:

void i8254_init_send(){
801087d0:	55                   	push   %ebp
801087d1:	89 e5                	mov    %esp,%ebp
801087d3:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
801087d6:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801087db:	05 28 38 00 00       	add    $0x3828,%eax
801087e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
801087e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087e6:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
801087ec:	e8 af 9f ff ff       	call   801027a0 <kalloc>
801087f1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
801087f4:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801087f9:	05 00 38 00 00       	add    $0x3800,%eax
801087fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108801:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108806:	05 04 38 00 00       	add    $0x3804,%eax
8010880b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
8010880e:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108813:	05 08 38 00 00       	add    $0x3808,%eax
80108818:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
8010881b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010881e:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108824:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108827:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108829:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010882c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108832:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108835:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
8010883b:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108840:	05 10 38 00 00       	add    $0x3810,%eax
80108845:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108848:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
8010884d:	05 18 38 00 00       	add    $0x3818,%eax
80108852:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108855:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108858:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
8010885e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108861:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108867:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010886a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
8010886d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108874:	e9 82 00 00 00       	jmp    801088fb <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80108879:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010887c:	c1 e0 04             	shl    $0x4,%eax
8010887f:	89 c2                	mov    %eax,%edx
80108881:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108884:	01 d0                	add    %edx,%eax
80108886:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
8010888d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108890:	c1 e0 04             	shl    $0x4,%eax
80108893:	89 c2                	mov    %eax,%edx
80108895:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108898:	01 d0                	add    %edx,%eax
8010889a:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
801088a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088a3:	c1 e0 04             	shl    $0x4,%eax
801088a6:	89 c2                	mov    %eax,%edx
801088a8:	8b 45 d0             	mov    -0x30(%ebp),%eax
801088ab:	01 d0                	add    %edx,%eax
801088ad:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
801088b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088b4:	c1 e0 04             	shl    $0x4,%eax
801088b7:	89 c2                	mov    %eax,%edx
801088b9:	8b 45 d0             	mov    -0x30(%ebp),%eax
801088bc:	01 d0                	add    %edx,%eax
801088be:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
801088c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088c5:	c1 e0 04             	shl    $0x4,%eax
801088c8:	89 c2                	mov    %eax,%edx
801088ca:	8b 45 d0             	mov    -0x30(%ebp),%eax
801088cd:	01 d0                	add    %edx,%eax
801088cf:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
801088d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088d6:	c1 e0 04             	shl    $0x4,%eax
801088d9:	89 c2                	mov    %eax,%edx
801088db:	8b 45 d0             	mov    -0x30(%ebp),%eax
801088de:	01 d0                	add    %edx,%eax
801088e0:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
801088e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088e7:	c1 e0 04             	shl    $0x4,%eax
801088ea:	89 c2                	mov    %eax,%edx
801088ec:	8b 45 d0             	mov    -0x30(%ebp),%eax
801088ef:	01 d0                	add    %edx,%eax
801088f1:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
801088f7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801088fb:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108902:	0f 8e 71 ff ff ff    	jle    80108879 <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108908:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010890f:	eb 57                	jmp    80108968 <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
80108911:	e8 8a 9e ff ff       	call   801027a0 <kalloc>
80108916:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108919:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
8010891d:	75 12                	jne    80108931 <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
8010891f:	83 ec 0c             	sub    $0xc,%esp
80108922:	68 58 be 10 80       	push   $0x8010be58
80108927:	e8 c8 7a ff ff       	call   801003f4 <cprintf>
8010892c:	83 c4 10             	add    $0x10,%esp
      break;
8010892f:	eb 3d                	jmp    8010896e <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108931:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108934:	c1 e0 04             	shl    $0x4,%eax
80108937:	89 c2                	mov    %eax,%edx
80108939:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010893c:	01 d0                	add    %edx,%eax
8010893e:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108941:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108947:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108949:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010894c:	83 c0 01             	add    $0x1,%eax
8010894f:	c1 e0 04             	shl    $0x4,%eax
80108952:	89 c2                	mov    %eax,%edx
80108954:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108957:	01 d0                	add    %edx,%eax
80108959:	8b 55 cc             	mov    -0x34(%ebp),%edx
8010895c:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108962:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108964:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108968:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
8010896c:	7e a3                	jle    80108911 <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
8010896e:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108973:	05 00 04 00 00       	add    $0x400,%eax
80108978:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
8010897b:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010897e:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108984:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108989:	05 10 04 00 00       	add    $0x410,%eax
8010898e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108991:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108994:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
8010899a:	83 ec 0c             	sub    $0xc,%esp
8010899d:	68 98 be 10 80       	push   $0x8010be98
801089a2:	e8 4d 7a ff ff       	call   801003f4 <cprintf>
801089a7:	83 c4 10             	add    $0x10,%esp

}
801089aa:	90                   	nop
801089ab:	c9                   	leave  
801089ac:	c3                   	ret    

801089ad <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
801089ad:	55                   	push   %ebp
801089ae:	89 e5                	mov    %esp,%ebp
801089b0:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
801089b3:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801089b8:	83 c0 14             	add    $0x14,%eax
801089bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
801089be:	8b 45 08             	mov    0x8(%ebp),%eax
801089c1:	c1 e0 08             	shl    $0x8,%eax
801089c4:	0f b7 c0             	movzwl %ax,%eax
801089c7:	83 c8 01             	or     $0x1,%eax
801089ca:	89 c2                	mov    %eax,%edx
801089cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089cf:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
801089d1:	83 ec 0c             	sub    $0xc,%esp
801089d4:	68 b8 be 10 80       	push   $0x8010beb8
801089d9:	e8 16 7a ff ff       	call   801003f4 <cprintf>
801089de:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
801089e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089e4:	8b 00                	mov    (%eax),%eax
801089e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
801089e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089ec:	83 e0 10             	and    $0x10,%eax
801089ef:	85 c0                	test   %eax,%eax
801089f1:	75 02                	jne    801089f5 <i8254_read_eeprom+0x48>
  while(1){
801089f3:	eb dc                	jmp    801089d1 <i8254_read_eeprom+0x24>
      break;
801089f5:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
801089f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089f9:	8b 00                	mov    (%eax),%eax
801089fb:	c1 e8 10             	shr    $0x10,%eax
}
801089fe:	c9                   	leave  
801089ff:	c3                   	ret    

80108a00 <i8254_recv>:
void i8254_recv(){
80108a00:	55                   	push   %ebp
80108a01:	89 e5                	mov    %esp,%ebp
80108a03:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108a06:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108a0b:	05 10 28 00 00       	add    $0x2810,%eax
80108a10:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108a13:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108a18:	05 18 28 00 00       	add    $0x2818,%eax
80108a1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108a20:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108a25:	05 00 28 00 00       	add    $0x2800,%eax
80108a2a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108a2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a30:	8b 00                	mov    (%eax),%eax
80108a32:	05 00 00 00 80       	add    $0x80000000,%eax
80108a37:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a3d:	8b 10                	mov    (%eax),%edx
80108a3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a42:	8b 08                	mov    (%eax),%ecx
80108a44:	89 d0                	mov    %edx,%eax
80108a46:	29 c8                	sub    %ecx,%eax
80108a48:	25 ff 00 00 00       	and    $0xff,%eax
80108a4d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80108a50:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108a54:	7e 37                	jle    80108a8d <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80108a56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a59:	8b 00                	mov    (%eax),%eax
80108a5b:	c1 e0 04             	shl    $0x4,%eax
80108a5e:	89 c2                	mov    %eax,%edx
80108a60:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108a63:	01 d0                	add    %edx,%eax
80108a65:	8b 00                	mov    (%eax),%eax
80108a67:	05 00 00 00 80       	add    $0x80000000,%eax
80108a6c:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80108a6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a72:	8b 00                	mov    (%eax),%eax
80108a74:	83 c0 01             	add    $0x1,%eax
80108a77:	0f b6 d0             	movzbl %al,%edx
80108a7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a7d:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80108a7f:	83 ec 0c             	sub    $0xc,%esp
80108a82:	ff 75 e0             	push   -0x20(%ebp)
80108a85:	e8 15 09 00 00       	call   8010939f <eth_proc>
80108a8a:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80108a8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a90:	8b 10                	mov    (%eax),%edx
80108a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a95:	8b 00                	mov    (%eax),%eax
80108a97:	39 c2                	cmp    %eax,%edx
80108a99:	75 9f                	jne    80108a3a <i8254_recv+0x3a>
      (*rdt)--;
80108a9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a9e:	8b 00                	mov    (%eax),%eax
80108aa0:	8d 50 ff             	lea    -0x1(%eax),%edx
80108aa3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108aa6:	89 10                	mov    %edx,(%eax)
  while(1){
80108aa8:	eb 90                	jmp    80108a3a <i8254_recv+0x3a>

80108aaa <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80108aaa:	55                   	push   %ebp
80108aab:	89 e5                	mov    %esp,%ebp
80108aad:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80108ab0:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108ab5:	05 10 38 00 00       	add    $0x3810,%eax
80108aba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108abd:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108ac2:	05 18 38 00 00       	add    $0x3818,%eax
80108ac7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108aca:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108acf:	05 00 38 00 00       	add    $0x3800,%eax
80108ad4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80108ad7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ada:	8b 00                	mov    (%eax),%eax
80108adc:	05 00 00 00 80       	add    $0x80000000,%eax
80108ae1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80108ae4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ae7:	8b 10                	mov    (%eax),%edx
80108ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aec:	8b 08                	mov    (%eax),%ecx
80108aee:	89 d0                	mov    %edx,%eax
80108af0:	29 c8                	sub    %ecx,%eax
80108af2:	0f b6 d0             	movzbl %al,%edx
80108af5:	b8 00 01 00 00       	mov    $0x100,%eax
80108afa:	29 d0                	sub    %edx,%eax
80108afc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80108aff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b02:	8b 00                	mov    (%eax),%eax
80108b04:	25 ff 00 00 00       	and    $0xff,%eax
80108b09:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80108b0c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108b10:	0f 8e a8 00 00 00    	jle    80108bbe <i8254_send+0x114>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80108b16:	8b 45 08             	mov    0x8(%ebp),%eax
80108b19:	8b 55 e0             	mov    -0x20(%ebp),%edx
80108b1c:	89 d1                	mov    %edx,%ecx
80108b1e:	c1 e1 04             	shl    $0x4,%ecx
80108b21:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108b24:	01 ca                	add    %ecx,%edx
80108b26:	8b 12                	mov    (%edx),%edx
80108b28:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108b2e:	83 ec 04             	sub    $0x4,%esp
80108b31:	ff 75 0c             	push   0xc(%ebp)
80108b34:	50                   	push   %eax
80108b35:	52                   	push   %edx
80108b36:	e8 06 bf ff ff       	call   80104a41 <memmove>
80108b3b:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80108b3e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b41:	c1 e0 04             	shl    $0x4,%eax
80108b44:	89 c2                	mov    %eax,%edx
80108b46:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b49:	01 d0                	add    %edx,%eax
80108b4b:	8b 55 0c             	mov    0xc(%ebp),%edx
80108b4e:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80108b52:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b55:	c1 e0 04             	shl    $0x4,%eax
80108b58:	89 c2                	mov    %eax,%edx
80108b5a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b5d:	01 d0                	add    %edx,%eax
80108b5f:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80108b63:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b66:	c1 e0 04             	shl    $0x4,%eax
80108b69:	89 c2                	mov    %eax,%edx
80108b6b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b6e:	01 d0                	add    %edx,%eax
80108b70:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80108b74:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b77:	c1 e0 04             	shl    $0x4,%eax
80108b7a:	89 c2                	mov    %eax,%edx
80108b7c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b7f:	01 d0                	add    %edx,%eax
80108b81:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80108b85:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b88:	c1 e0 04             	shl    $0x4,%eax
80108b8b:	89 c2                	mov    %eax,%edx
80108b8d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b90:	01 d0                	add    %edx,%eax
80108b92:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80108b98:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b9b:	c1 e0 04             	shl    $0x4,%eax
80108b9e:	89 c2                	mov    %eax,%edx
80108ba0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ba3:	01 d0                	add    %edx,%eax
80108ba5:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80108ba9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bac:	8b 00                	mov    (%eax),%eax
80108bae:	83 c0 01             	add    $0x1,%eax
80108bb1:	0f b6 d0             	movzbl %al,%edx
80108bb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bb7:	89 10                	mov    %edx,(%eax)
    return len;
80108bb9:	8b 45 0c             	mov    0xc(%ebp),%eax
80108bbc:	eb 05                	jmp    80108bc3 <i8254_send+0x119>
  }else{
    return -1;
80108bbe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80108bc3:	c9                   	leave  
80108bc4:	c3                   	ret    

80108bc5 <i8254_intr>:

void i8254_intr(){
80108bc5:	55                   	push   %ebp
80108bc6:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80108bc8:	a1 88 6d 19 80       	mov    0x80196d88,%eax
80108bcd:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80108bd3:	90                   	nop
80108bd4:	5d                   	pop    %ebp
80108bd5:	c3                   	ret    

80108bd6 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80108bd6:	55                   	push   %ebp
80108bd7:	89 e5                	mov    %esp,%ebp
80108bd9:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80108bdc:	8b 45 08             	mov    0x8(%ebp),%eax
80108bdf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80108be2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108be5:	0f b7 00             	movzwl (%eax),%eax
80108be8:	66 3d 00 01          	cmp    $0x100,%ax
80108bec:	74 0a                	je     80108bf8 <arp_proc+0x22>
80108bee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108bf3:	e9 4f 01 00 00       	jmp    80108d47 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80108bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bfb:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80108bff:	66 83 f8 08          	cmp    $0x8,%ax
80108c03:	74 0a                	je     80108c0f <arp_proc+0x39>
80108c05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c0a:	e9 38 01 00 00       	jmp    80108d47 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
80108c0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c12:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80108c16:	3c 06                	cmp    $0x6,%al
80108c18:	74 0a                	je     80108c24 <arp_proc+0x4e>
80108c1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c1f:	e9 23 01 00 00       	jmp    80108d47 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80108c24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c27:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80108c2b:	3c 04                	cmp    $0x4,%al
80108c2d:	74 0a                	je     80108c39 <arp_proc+0x63>
80108c2f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c34:	e9 0e 01 00 00       	jmp    80108d47 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80108c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c3c:	83 c0 18             	add    $0x18,%eax
80108c3f:	83 ec 04             	sub    $0x4,%esp
80108c42:	6a 04                	push   $0x4
80108c44:	50                   	push   %eax
80108c45:	68 e4 f4 10 80       	push   $0x8010f4e4
80108c4a:	e8 9a bd ff ff       	call   801049e9 <memcmp>
80108c4f:	83 c4 10             	add    $0x10,%esp
80108c52:	85 c0                	test   %eax,%eax
80108c54:	74 27                	je     80108c7d <arp_proc+0xa7>
80108c56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c59:	83 c0 0e             	add    $0xe,%eax
80108c5c:	83 ec 04             	sub    $0x4,%esp
80108c5f:	6a 04                	push   $0x4
80108c61:	50                   	push   %eax
80108c62:	68 e4 f4 10 80       	push   $0x8010f4e4
80108c67:	e8 7d bd ff ff       	call   801049e9 <memcmp>
80108c6c:	83 c4 10             	add    $0x10,%esp
80108c6f:	85 c0                	test   %eax,%eax
80108c71:	74 0a                	je     80108c7d <arp_proc+0xa7>
80108c73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c78:	e9 ca 00 00 00       	jmp    80108d47 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108c7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c80:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108c84:	66 3d 00 01          	cmp    $0x100,%ax
80108c88:	75 69                	jne    80108cf3 <arp_proc+0x11d>
80108c8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c8d:	83 c0 18             	add    $0x18,%eax
80108c90:	83 ec 04             	sub    $0x4,%esp
80108c93:	6a 04                	push   $0x4
80108c95:	50                   	push   %eax
80108c96:	68 e4 f4 10 80       	push   $0x8010f4e4
80108c9b:	e8 49 bd ff ff       	call   801049e9 <memcmp>
80108ca0:	83 c4 10             	add    $0x10,%esp
80108ca3:	85 c0                	test   %eax,%eax
80108ca5:	75 4c                	jne    80108cf3 <arp_proc+0x11d>
    uint send = (uint)kalloc();
80108ca7:	e8 f4 9a ff ff       	call   801027a0 <kalloc>
80108cac:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80108caf:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80108cb6:	83 ec 04             	sub    $0x4,%esp
80108cb9:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108cbc:	50                   	push   %eax
80108cbd:	ff 75 f0             	push   -0x10(%ebp)
80108cc0:	ff 75 f4             	push   -0xc(%ebp)
80108cc3:	e8 1f 04 00 00       	call   801090e7 <arp_reply_pkt_create>
80108cc8:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80108ccb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108cce:	83 ec 08             	sub    $0x8,%esp
80108cd1:	50                   	push   %eax
80108cd2:	ff 75 f0             	push   -0x10(%ebp)
80108cd5:	e8 d0 fd ff ff       	call   80108aaa <i8254_send>
80108cda:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
80108cdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ce0:	83 ec 0c             	sub    $0xc,%esp
80108ce3:	50                   	push   %eax
80108ce4:	e8 1d 9a ff ff       	call   80102706 <kfree>
80108ce9:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
80108cec:	b8 02 00 00 00       	mov    $0x2,%eax
80108cf1:	eb 54                	jmp    80108d47 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108cf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cf6:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108cfa:	66 3d 00 02          	cmp    $0x200,%ax
80108cfe:	75 42                	jne    80108d42 <arp_proc+0x16c>
80108d00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d03:	83 c0 18             	add    $0x18,%eax
80108d06:	83 ec 04             	sub    $0x4,%esp
80108d09:	6a 04                	push   $0x4
80108d0b:	50                   	push   %eax
80108d0c:	68 e4 f4 10 80       	push   $0x8010f4e4
80108d11:	e8 d3 bc ff ff       	call   801049e9 <memcmp>
80108d16:	83 c4 10             	add    $0x10,%esp
80108d19:	85 c0                	test   %eax,%eax
80108d1b:	75 25                	jne    80108d42 <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
80108d1d:	83 ec 0c             	sub    $0xc,%esp
80108d20:	68 bc be 10 80       	push   $0x8010bebc
80108d25:	e8 ca 76 ff ff       	call   801003f4 <cprintf>
80108d2a:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
80108d2d:	83 ec 0c             	sub    $0xc,%esp
80108d30:	ff 75 f4             	push   -0xc(%ebp)
80108d33:	e8 af 01 00 00       	call   80108ee7 <arp_table_update>
80108d38:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80108d3b:	b8 01 00 00 00       	mov    $0x1,%eax
80108d40:	eb 05                	jmp    80108d47 <arp_proc+0x171>
  }else{
    return -1;
80108d42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80108d47:	c9                   	leave  
80108d48:	c3                   	ret    

80108d49 <arp_scan>:

void arp_scan(){
80108d49:	55                   	push   %ebp
80108d4a:	89 e5                	mov    %esp,%ebp
80108d4c:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80108d4f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108d56:	eb 6f                	jmp    80108dc7 <arp_scan+0x7e>
    uint send = (uint)kalloc();
80108d58:	e8 43 9a ff ff       	call   801027a0 <kalloc>
80108d5d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80108d60:	83 ec 04             	sub    $0x4,%esp
80108d63:	ff 75 f4             	push   -0xc(%ebp)
80108d66:	8d 45 e8             	lea    -0x18(%ebp),%eax
80108d69:	50                   	push   %eax
80108d6a:	ff 75 ec             	push   -0x14(%ebp)
80108d6d:	e8 62 00 00 00       	call   80108dd4 <arp_broadcast>
80108d72:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80108d75:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d78:	83 ec 08             	sub    $0x8,%esp
80108d7b:	50                   	push   %eax
80108d7c:	ff 75 ec             	push   -0x14(%ebp)
80108d7f:	e8 26 fd ff ff       	call   80108aaa <i8254_send>
80108d84:	83 c4 10             	add    $0x10,%esp
80108d87:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80108d8a:	eb 22                	jmp    80108dae <arp_scan+0x65>
      microdelay(1);
80108d8c:	83 ec 0c             	sub    $0xc,%esp
80108d8f:	6a 01                	push   $0x1
80108d91:	e8 a1 9d ff ff       	call   80102b37 <microdelay>
80108d96:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80108d99:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d9c:	83 ec 08             	sub    $0x8,%esp
80108d9f:	50                   	push   %eax
80108da0:	ff 75 ec             	push   -0x14(%ebp)
80108da3:	e8 02 fd ff ff       	call   80108aaa <i8254_send>
80108da8:	83 c4 10             	add    $0x10,%esp
80108dab:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80108dae:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80108db2:	74 d8                	je     80108d8c <arp_scan+0x43>
    }
    kfree((char *)send);
80108db4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108db7:	83 ec 0c             	sub    $0xc,%esp
80108dba:	50                   	push   %eax
80108dbb:	e8 46 99 ff ff       	call   80102706 <kfree>
80108dc0:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80108dc3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108dc7:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108dce:	7e 88                	jle    80108d58 <arp_scan+0xf>
  }
}
80108dd0:	90                   	nop
80108dd1:	90                   	nop
80108dd2:	c9                   	leave  
80108dd3:	c3                   	ret    

80108dd4 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80108dd4:	55                   	push   %ebp
80108dd5:	89 e5                	mov    %esp,%ebp
80108dd7:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80108dda:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
80108dde:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80108de2:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80108de6:	8b 45 10             	mov    0x10(%ebp),%eax
80108de9:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80108dec:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80108df3:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80108df9:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108e00:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80108e06:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e09:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80108e0f:	8b 45 08             	mov    0x8(%ebp),%eax
80108e12:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80108e15:	8b 45 08             	mov    0x8(%ebp),%eax
80108e18:	83 c0 0e             	add    $0xe,%eax
80108e1b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80108e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e21:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80108e25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e28:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80108e2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e2f:	83 ec 04             	sub    $0x4,%esp
80108e32:	6a 06                	push   $0x6
80108e34:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80108e37:	52                   	push   %edx
80108e38:	50                   	push   %eax
80108e39:	e8 03 bc ff ff       	call   80104a41 <memmove>
80108e3e:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80108e41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e44:	83 c0 06             	add    $0x6,%eax
80108e47:	83 ec 04             	sub    $0x4,%esp
80108e4a:	6a 06                	push   $0x6
80108e4c:	68 80 6d 19 80       	push   $0x80196d80
80108e51:	50                   	push   %eax
80108e52:	e8 ea bb ff ff       	call   80104a41 <memmove>
80108e57:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80108e5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e5d:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80108e62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e65:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80108e6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e6e:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80108e72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e75:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80108e79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e7c:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80108e82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e85:	8d 50 12             	lea    0x12(%eax),%edx
80108e88:	83 ec 04             	sub    $0x4,%esp
80108e8b:	6a 06                	push   $0x6
80108e8d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80108e90:	50                   	push   %eax
80108e91:	52                   	push   %edx
80108e92:	e8 aa bb ff ff       	call   80104a41 <memmove>
80108e97:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80108e9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e9d:	8d 50 18             	lea    0x18(%eax),%edx
80108ea0:	83 ec 04             	sub    $0x4,%esp
80108ea3:	6a 04                	push   $0x4
80108ea5:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108ea8:	50                   	push   %eax
80108ea9:	52                   	push   %edx
80108eaa:	e8 92 bb ff ff       	call   80104a41 <memmove>
80108eaf:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80108eb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108eb5:	83 c0 08             	add    $0x8,%eax
80108eb8:	83 ec 04             	sub    $0x4,%esp
80108ebb:	6a 06                	push   $0x6
80108ebd:	68 80 6d 19 80       	push   $0x80196d80
80108ec2:	50                   	push   %eax
80108ec3:	e8 79 bb ff ff       	call   80104a41 <memmove>
80108ec8:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80108ecb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ece:	83 c0 0e             	add    $0xe,%eax
80108ed1:	83 ec 04             	sub    $0x4,%esp
80108ed4:	6a 04                	push   $0x4
80108ed6:	68 e4 f4 10 80       	push   $0x8010f4e4
80108edb:	50                   	push   %eax
80108edc:	e8 60 bb ff ff       	call   80104a41 <memmove>
80108ee1:	83 c4 10             	add    $0x10,%esp
}
80108ee4:	90                   	nop
80108ee5:	c9                   	leave  
80108ee6:	c3                   	ret    

80108ee7 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80108ee7:	55                   	push   %ebp
80108ee8:	89 e5                	mov    %esp,%ebp
80108eea:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80108eed:	8b 45 08             	mov    0x8(%ebp),%eax
80108ef0:	83 c0 0e             	add    $0xe,%eax
80108ef3:	83 ec 0c             	sub    $0xc,%esp
80108ef6:	50                   	push   %eax
80108ef7:	e8 bc 00 00 00       	call   80108fb8 <arp_table_search>
80108efc:	83 c4 10             	add    $0x10,%esp
80108eff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80108f02:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108f06:	78 2d                	js     80108f35 <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80108f08:	8b 45 08             	mov    0x8(%ebp),%eax
80108f0b:	8d 48 08             	lea    0x8(%eax),%ecx
80108f0e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108f11:	89 d0                	mov    %edx,%eax
80108f13:	c1 e0 02             	shl    $0x2,%eax
80108f16:	01 d0                	add    %edx,%eax
80108f18:	01 c0                	add    %eax,%eax
80108f1a:	01 d0                	add    %edx,%eax
80108f1c:	05 a0 6d 19 80       	add    $0x80196da0,%eax
80108f21:	83 c0 04             	add    $0x4,%eax
80108f24:	83 ec 04             	sub    $0x4,%esp
80108f27:	6a 06                	push   $0x6
80108f29:	51                   	push   %ecx
80108f2a:	50                   	push   %eax
80108f2b:	e8 11 bb ff ff       	call   80104a41 <memmove>
80108f30:	83 c4 10             	add    $0x10,%esp
80108f33:	eb 70                	jmp    80108fa5 <arp_table_update+0xbe>
  }else{
    index += 1;
80108f35:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80108f39:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80108f3c:	8b 45 08             	mov    0x8(%ebp),%eax
80108f3f:	8d 48 08             	lea    0x8(%eax),%ecx
80108f42:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108f45:	89 d0                	mov    %edx,%eax
80108f47:	c1 e0 02             	shl    $0x2,%eax
80108f4a:	01 d0                	add    %edx,%eax
80108f4c:	01 c0                	add    %eax,%eax
80108f4e:	01 d0                	add    %edx,%eax
80108f50:	05 a0 6d 19 80       	add    $0x80196da0,%eax
80108f55:	83 c0 04             	add    $0x4,%eax
80108f58:	83 ec 04             	sub    $0x4,%esp
80108f5b:	6a 06                	push   $0x6
80108f5d:	51                   	push   %ecx
80108f5e:	50                   	push   %eax
80108f5f:	e8 dd ba ff ff       	call   80104a41 <memmove>
80108f64:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80108f67:	8b 45 08             	mov    0x8(%ebp),%eax
80108f6a:	8d 48 0e             	lea    0xe(%eax),%ecx
80108f6d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108f70:	89 d0                	mov    %edx,%eax
80108f72:	c1 e0 02             	shl    $0x2,%eax
80108f75:	01 d0                	add    %edx,%eax
80108f77:	01 c0                	add    %eax,%eax
80108f79:	01 d0                	add    %edx,%eax
80108f7b:	05 a0 6d 19 80       	add    $0x80196da0,%eax
80108f80:	83 ec 04             	sub    $0x4,%esp
80108f83:	6a 04                	push   $0x4
80108f85:	51                   	push   %ecx
80108f86:	50                   	push   %eax
80108f87:	e8 b5 ba ff ff       	call   80104a41 <memmove>
80108f8c:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80108f8f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108f92:	89 d0                	mov    %edx,%eax
80108f94:	c1 e0 02             	shl    $0x2,%eax
80108f97:	01 d0                	add    %edx,%eax
80108f99:	01 c0                	add    %eax,%eax
80108f9b:	01 d0                	add    %edx,%eax
80108f9d:	05 aa 6d 19 80       	add    $0x80196daa,%eax
80108fa2:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80108fa5:	83 ec 0c             	sub    $0xc,%esp
80108fa8:	68 a0 6d 19 80       	push   $0x80196da0
80108fad:	e8 83 00 00 00       	call   80109035 <print_arp_table>
80108fb2:	83 c4 10             	add    $0x10,%esp
}
80108fb5:	90                   	nop
80108fb6:	c9                   	leave  
80108fb7:	c3                   	ret    

80108fb8 <arp_table_search>:

int arp_table_search(uchar *ip){
80108fb8:	55                   	push   %ebp
80108fb9:	89 e5                	mov    %esp,%ebp
80108fbb:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80108fbe:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80108fc5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108fcc:	eb 59                	jmp    80109027 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
80108fce:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108fd1:	89 d0                	mov    %edx,%eax
80108fd3:	c1 e0 02             	shl    $0x2,%eax
80108fd6:	01 d0                	add    %edx,%eax
80108fd8:	01 c0                	add    %eax,%eax
80108fda:	01 d0                	add    %edx,%eax
80108fdc:	05 a0 6d 19 80       	add    $0x80196da0,%eax
80108fe1:	83 ec 04             	sub    $0x4,%esp
80108fe4:	6a 04                	push   $0x4
80108fe6:	ff 75 08             	push   0x8(%ebp)
80108fe9:	50                   	push   %eax
80108fea:	e8 fa b9 ff ff       	call   801049e9 <memcmp>
80108fef:	83 c4 10             	add    $0x10,%esp
80108ff2:	85 c0                	test   %eax,%eax
80108ff4:	75 05                	jne    80108ffb <arp_table_search+0x43>
      return i;
80108ff6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ff9:	eb 38                	jmp    80109033 <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
80108ffb:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108ffe:	89 d0                	mov    %edx,%eax
80109000:	c1 e0 02             	shl    $0x2,%eax
80109003:	01 d0                	add    %edx,%eax
80109005:	01 c0                	add    %eax,%eax
80109007:	01 d0                	add    %edx,%eax
80109009:	05 aa 6d 19 80       	add    $0x80196daa,%eax
8010900e:	0f b6 00             	movzbl (%eax),%eax
80109011:	84 c0                	test   %al,%al
80109013:	75 0e                	jne    80109023 <arp_table_search+0x6b>
80109015:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109019:	75 08                	jne    80109023 <arp_table_search+0x6b>
      empty = -i;
8010901b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010901e:	f7 d8                	neg    %eax
80109020:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109023:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109027:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
8010902b:	7e a1                	jle    80108fce <arp_table_search+0x16>
    }
  }
  return empty-1;
8010902d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109030:	83 e8 01             	sub    $0x1,%eax
}
80109033:	c9                   	leave  
80109034:	c3                   	ret    

80109035 <print_arp_table>:

void print_arp_table(){
80109035:	55                   	push   %ebp
80109036:	89 e5                	mov    %esp,%ebp
80109038:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
8010903b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109042:	e9 92 00 00 00       	jmp    801090d9 <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
80109047:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010904a:	89 d0                	mov    %edx,%eax
8010904c:	c1 e0 02             	shl    $0x2,%eax
8010904f:	01 d0                	add    %edx,%eax
80109051:	01 c0                	add    %eax,%eax
80109053:	01 d0                	add    %edx,%eax
80109055:	05 aa 6d 19 80       	add    $0x80196daa,%eax
8010905a:	0f b6 00             	movzbl (%eax),%eax
8010905d:	84 c0                	test   %al,%al
8010905f:	74 74                	je     801090d5 <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
80109061:	83 ec 08             	sub    $0x8,%esp
80109064:	ff 75 f4             	push   -0xc(%ebp)
80109067:	68 cf be 10 80       	push   $0x8010becf
8010906c:	e8 83 73 ff ff       	call   801003f4 <cprintf>
80109071:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109074:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109077:	89 d0                	mov    %edx,%eax
80109079:	c1 e0 02             	shl    $0x2,%eax
8010907c:	01 d0                	add    %edx,%eax
8010907e:	01 c0                	add    %eax,%eax
80109080:	01 d0                	add    %edx,%eax
80109082:	05 a0 6d 19 80       	add    $0x80196da0,%eax
80109087:	83 ec 0c             	sub    $0xc,%esp
8010908a:	50                   	push   %eax
8010908b:	e8 54 02 00 00       	call   801092e4 <print_ipv4>
80109090:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109093:	83 ec 0c             	sub    $0xc,%esp
80109096:	68 de be 10 80       	push   $0x8010bede
8010909b:	e8 54 73 ff ff       	call   801003f4 <cprintf>
801090a0:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
801090a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801090a6:	89 d0                	mov    %edx,%eax
801090a8:	c1 e0 02             	shl    $0x2,%eax
801090ab:	01 d0                	add    %edx,%eax
801090ad:	01 c0                	add    %eax,%eax
801090af:	01 d0                	add    %edx,%eax
801090b1:	05 a0 6d 19 80       	add    $0x80196da0,%eax
801090b6:	83 c0 04             	add    $0x4,%eax
801090b9:	83 ec 0c             	sub    $0xc,%esp
801090bc:	50                   	push   %eax
801090bd:	e8 70 02 00 00       	call   80109332 <print_mac>
801090c2:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
801090c5:	83 ec 0c             	sub    $0xc,%esp
801090c8:	68 e0 be 10 80       	push   $0x8010bee0
801090cd:	e8 22 73 ff ff       	call   801003f4 <cprintf>
801090d2:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801090d5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801090d9:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801090dd:	0f 8e 64 ff ff ff    	jle    80109047 <print_arp_table+0x12>
    }
  }
}
801090e3:	90                   	nop
801090e4:	90                   	nop
801090e5:	c9                   	leave  
801090e6:	c3                   	ret    

801090e7 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
801090e7:	55                   	push   %ebp
801090e8:	89 e5                	mov    %esp,%ebp
801090ea:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801090ed:	8b 45 10             	mov    0x10(%ebp),%eax
801090f0:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801090f6:	8b 45 0c             	mov    0xc(%ebp),%eax
801090f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801090fc:	8b 45 0c             	mov    0xc(%ebp),%eax
801090ff:	83 c0 0e             	add    $0xe,%eax
80109102:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109105:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109108:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
8010910c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010910f:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109113:	8b 45 08             	mov    0x8(%ebp),%eax
80109116:	8d 50 08             	lea    0x8(%eax),%edx
80109119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010911c:	83 ec 04             	sub    $0x4,%esp
8010911f:	6a 06                	push   $0x6
80109121:	52                   	push   %edx
80109122:	50                   	push   %eax
80109123:	e8 19 b9 ff ff       	call   80104a41 <memmove>
80109128:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
8010912b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010912e:	83 c0 06             	add    $0x6,%eax
80109131:	83 ec 04             	sub    $0x4,%esp
80109134:	6a 06                	push   $0x6
80109136:	68 80 6d 19 80       	push   $0x80196d80
8010913b:	50                   	push   %eax
8010913c:	e8 00 b9 ff ff       	call   80104a41 <memmove>
80109141:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109144:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109147:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
8010914c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010914f:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109155:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109158:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
8010915c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010915f:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109163:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109166:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
8010916c:	8b 45 08             	mov    0x8(%ebp),%eax
8010916f:	8d 50 08             	lea    0x8(%eax),%edx
80109172:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109175:	83 c0 12             	add    $0x12,%eax
80109178:	83 ec 04             	sub    $0x4,%esp
8010917b:	6a 06                	push   $0x6
8010917d:	52                   	push   %edx
8010917e:	50                   	push   %eax
8010917f:	e8 bd b8 ff ff       	call   80104a41 <memmove>
80109184:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109187:	8b 45 08             	mov    0x8(%ebp),%eax
8010918a:	8d 50 0e             	lea    0xe(%eax),%edx
8010918d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109190:	83 c0 18             	add    $0x18,%eax
80109193:	83 ec 04             	sub    $0x4,%esp
80109196:	6a 04                	push   $0x4
80109198:	52                   	push   %edx
80109199:	50                   	push   %eax
8010919a:	e8 a2 b8 ff ff       	call   80104a41 <memmove>
8010919f:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801091a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091a5:	83 c0 08             	add    $0x8,%eax
801091a8:	83 ec 04             	sub    $0x4,%esp
801091ab:	6a 06                	push   $0x6
801091ad:	68 80 6d 19 80       	push   $0x80196d80
801091b2:	50                   	push   %eax
801091b3:	e8 89 b8 ff ff       	call   80104a41 <memmove>
801091b8:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801091bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091be:	83 c0 0e             	add    $0xe,%eax
801091c1:	83 ec 04             	sub    $0x4,%esp
801091c4:	6a 04                	push   $0x4
801091c6:	68 e4 f4 10 80       	push   $0x8010f4e4
801091cb:	50                   	push   %eax
801091cc:	e8 70 b8 ff ff       	call   80104a41 <memmove>
801091d1:	83 c4 10             	add    $0x10,%esp
}
801091d4:	90                   	nop
801091d5:	c9                   	leave  
801091d6:	c3                   	ret    

801091d7 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
801091d7:	55                   	push   %ebp
801091d8:	89 e5                	mov    %esp,%ebp
801091da:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
801091dd:	83 ec 0c             	sub    $0xc,%esp
801091e0:	68 e2 be 10 80       	push   $0x8010bee2
801091e5:	e8 0a 72 ff ff       	call   801003f4 <cprintf>
801091ea:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
801091ed:	8b 45 08             	mov    0x8(%ebp),%eax
801091f0:	83 c0 0e             	add    $0xe,%eax
801091f3:	83 ec 0c             	sub    $0xc,%esp
801091f6:	50                   	push   %eax
801091f7:	e8 e8 00 00 00       	call   801092e4 <print_ipv4>
801091fc:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801091ff:	83 ec 0c             	sub    $0xc,%esp
80109202:	68 e0 be 10 80       	push   $0x8010bee0
80109207:	e8 e8 71 ff ff       	call   801003f4 <cprintf>
8010920c:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
8010920f:	8b 45 08             	mov    0x8(%ebp),%eax
80109212:	83 c0 08             	add    $0x8,%eax
80109215:	83 ec 0c             	sub    $0xc,%esp
80109218:	50                   	push   %eax
80109219:	e8 14 01 00 00       	call   80109332 <print_mac>
8010921e:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109221:	83 ec 0c             	sub    $0xc,%esp
80109224:	68 e0 be 10 80       	push   $0x8010bee0
80109229:	e8 c6 71 ff ff       	call   801003f4 <cprintf>
8010922e:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
80109231:	83 ec 0c             	sub    $0xc,%esp
80109234:	68 f9 be 10 80       	push   $0x8010bef9
80109239:	e8 b6 71 ff ff       	call   801003f4 <cprintf>
8010923e:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
80109241:	8b 45 08             	mov    0x8(%ebp),%eax
80109244:	83 c0 18             	add    $0x18,%eax
80109247:	83 ec 0c             	sub    $0xc,%esp
8010924a:	50                   	push   %eax
8010924b:	e8 94 00 00 00       	call   801092e4 <print_ipv4>
80109250:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109253:	83 ec 0c             	sub    $0xc,%esp
80109256:	68 e0 be 10 80       	push   $0x8010bee0
8010925b:	e8 94 71 ff ff       	call   801003f4 <cprintf>
80109260:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109263:	8b 45 08             	mov    0x8(%ebp),%eax
80109266:	83 c0 12             	add    $0x12,%eax
80109269:	83 ec 0c             	sub    $0xc,%esp
8010926c:	50                   	push   %eax
8010926d:	e8 c0 00 00 00       	call   80109332 <print_mac>
80109272:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109275:	83 ec 0c             	sub    $0xc,%esp
80109278:	68 e0 be 10 80       	push   $0x8010bee0
8010927d:	e8 72 71 ff ff       	call   801003f4 <cprintf>
80109282:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109285:	83 ec 0c             	sub    $0xc,%esp
80109288:	68 10 bf 10 80       	push   $0x8010bf10
8010928d:	e8 62 71 ff ff       	call   801003f4 <cprintf>
80109292:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109295:	8b 45 08             	mov    0x8(%ebp),%eax
80109298:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010929c:	66 3d 00 01          	cmp    $0x100,%ax
801092a0:	75 12                	jne    801092b4 <print_arp_info+0xdd>
801092a2:	83 ec 0c             	sub    $0xc,%esp
801092a5:	68 1c bf 10 80       	push   $0x8010bf1c
801092aa:	e8 45 71 ff ff       	call   801003f4 <cprintf>
801092af:	83 c4 10             	add    $0x10,%esp
801092b2:	eb 1d                	jmp    801092d1 <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
801092b4:	8b 45 08             	mov    0x8(%ebp),%eax
801092b7:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801092bb:	66 3d 00 02          	cmp    $0x200,%ax
801092bf:	75 10                	jne    801092d1 <print_arp_info+0xfa>
    cprintf("Reply\n");
801092c1:	83 ec 0c             	sub    $0xc,%esp
801092c4:	68 25 bf 10 80       	push   $0x8010bf25
801092c9:	e8 26 71 ff ff       	call   801003f4 <cprintf>
801092ce:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
801092d1:	83 ec 0c             	sub    $0xc,%esp
801092d4:	68 e0 be 10 80       	push   $0x8010bee0
801092d9:	e8 16 71 ff ff       	call   801003f4 <cprintf>
801092de:	83 c4 10             	add    $0x10,%esp
}
801092e1:	90                   	nop
801092e2:	c9                   	leave  
801092e3:	c3                   	ret    

801092e4 <print_ipv4>:

void print_ipv4(uchar *ip){
801092e4:	55                   	push   %ebp
801092e5:	89 e5                	mov    %esp,%ebp
801092e7:	53                   	push   %ebx
801092e8:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
801092eb:	8b 45 08             	mov    0x8(%ebp),%eax
801092ee:	83 c0 03             	add    $0x3,%eax
801092f1:	0f b6 00             	movzbl (%eax),%eax
801092f4:	0f b6 d8             	movzbl %al,%ebx
801092f7:	8b 45 08             	mov    0x8(%ebp),%eax
801092fa:	83 c0 02             	add    $0x2,%eax
801092fd:	0f b6 00             	movzbl (%eax),%eax
80109300:	0f b6 c8             	movzbl %al,%ecx
80109303:	8b 45 08             	mov    0x8(%ebp),%eax
80109306:	83 c0 01             	add    $0x1,%eax
80109309:	0f b6 00             	movzbl (%eax),%eax
8010930c:	0f b6 d0             	movzbl %al,%edx
8010930f:	8b 45 08             	mov    0x8(%ebp),%eax
80109312:	0f b6 00             	movzbl (%eax),%eax
80109315:	0f b6 c0             	movzbl %al,%eax
80109318:	83 ec 0c             	sub    $0xc,%esp
8010931b:	53                   	push   %ebx
8010931c:	51                   	push   %ecx
8010931d:	52                   	push   %edx
8010931e:	50                   	push   %eax
8010931f:	68 2c bf 10 80       	push   $0x8010bf2c
80109324:	e8 cb 70 ff ff       	call   801003f4 <cprintf>
80109329:	83 c4 20             	add    $0x20,%esp
}
8010932c:	90                   	nop
8010932d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109330:	c9                   	leave  
80109331:	c3                   	ret    

80109332 <print_mac>:

void print_mac(uchar *mac){
80109332:	55                   	push   %ebp
80109333:	89 e5                	mov    %esp,%ebp
80109335:	57                   	push   %edi
80109336:	56                   	push   %esi
80109337:	53                   	push   %ebx
80109338:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
8010933b:	8b 45 08             	mov    0x8(%ebp),%eax
8010933e:	83 c0 05             	add    $0x5,%eax
80109341:	0f b6 00             	movzbl (%eax),%eax
80109344:	0f b6 f8             	movzbl %al,%edi
80109347:	8b 45 08             	mov    0x8(%ebp),%eax
8010934a:	83 c0 04             	add    $0x4,%eax
8010934d:	0f b6 00             	movzbl (%eax),%eax
80109350:	0f b6 f0             	movzbl %al,%esi
80109353:	8b 45 08             	mov    0x8(%ebp),%eax
80109356:	83 c0 03             	add    $0x3,%eax
80109359:	0f b6 00             	movzbl (%eax),%eax
8010935c:	0f b6 d8             	movzbl %al,%ebx
8010935f:	8b 45 08             	mov    0x8(%ebp),%eax
80109362:	83 c0 02             	add    $0x2,%eax
80109365:	0f b6 00             	movzbl (%eax),%eax
80109368:	0f b6 c8             	movzbl %al,%ecx
8010936b:	8b 45 08             	mov    0x8(%ebp),%eax
8010936e:	83 c0 01             	add    $0x1,%eax
80109371:	0f b6 00             	movzbl (%eax),%eax
80109374:	0f b6 d0             	movzbl %al,%edx
80109377:	8b 45 08             	mov    0x8(%ebp),%eax
8010937a:	0f b6 00             	movzbl (%eax),%eax
8010937d:	0f b6 c0             	movzbl %al,%eax
80109380:	83 ec 04             	sub    $0x4,%esp
80109383:	57                   	push   %edi
80109384:	56                   	push   %esi
80109385:	53                   	push   %ebx
80109386:	51                   	push   %ecx
80109387:	52                   	push   %edx
80109388:	50                   	push   %eax
80109389:	68 44 bf 10 80       	push   $0x8010bf44
8010938e:	e8 61 70 ff ff       	call   801003f4 <cprintf>
80109393:	83 c4 20             	add    $0x20,%esp
}
80109396:	90                   	nop
80109397:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010939a:	5b                   	pop    %ebx
8010939b:	5e                   	pop    %esi
8010939c:	5f                   	pop    %edi
8010939d:	5d                   	pop    %ebp
8010939e:	c3                   	ret    

8010939f <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
8010939f:	55                   	push   %ebp
801093a0:	89 e5                	mov    %esp,%ebp
801093a2:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
801093a5:	8b 45 08             	mov    0x8(%ebp),%eax
801093a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
801093ab:	8b 45 08             	mov    0x8(%ebp),%eax
801093ae:	83 c0 0e             	add    $0xe,%eax
801093b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
801093b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093b7:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801093bb:	3c 08                	cmp    $0x8,%al
801093bd:	75 1b                	jne    801093da <eth_proc+0x3b>
801093bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093c2:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801093c6:	3c 06                	cmp    $0x6,%al
801093c8:	75 10                	jne    801093da <eth_proc+0x3b>
    arp_proc(pkt_addr);
801093ca:	83 ec 0c             	sub    $0xc,%esp
801093cd:	ff 75 f0             	push   -0x10(%ebp)
801093d0:	e8 01 f8 ff ff       	call   80108bd6 <arp_proc>
801093d5:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
801093d8:	eb 24                	jmp    801093fe <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
801093da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093dd:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801093e1:	3c 08                	cmp    $0x8,%al
801093e3:	75 19                	jne    801093fe <eth_proc+0x5f>
801093e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093e8:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801093ec:	84 c0                	test   %al,%al
801093ee:	75 0e                	jne    801093fe <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
801093f0:	83 ec 0c             	sub    $0xc,%esp
801093f3:	ff 75 08             	push   0x8(%ebp)
801093f6:	e8 a3 00 00 00       	call   8010949e <ipv4_proc>
801093fb:	83 c4 10             	add    $0x10,%esp
}
801093fe:	90                   	nop
801093ff:	c9                   	leave  
80109400:	c3                   	ret    

80109401 <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109401:	55                   	push   %ebp
80109402:	89 e5                	mov    %esp,%ebp
80109404:	83 ec 04             	sub    $0x4,%esp
80109407:	8b 45 08             	mov    0x8(%ebp),%eax
8010940a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
8010940e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109412:	c1 e0 08             	shl    $0x8,%eax
80109415:	89 c2                	mov    %eax,%edx
80109417:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010941b:	66 c1 e8 08          	shr    $0x8,%ax
8010941f:	01 d0                	add    %edx,%eax
}
80109421:	c9                   	leave  
80109422:	c3                   	ret    

80109423 <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109423:	55                   	push   %ebp
80109424:	89 e5                	mov    %esp,%ebp
80109426:	83 ec 04             	sub    $0x4,%esp
80109429:	8b 45 08             	mov    0x8(%ebp),%eax
8010942c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109430:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109434:	c1 e0 08             	shl    $0x8,%eax
80109437:	89 c2                	mov    %eax,%edx
80109439:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010943d:	66 c1 e8 08          	shr    $0x8,%ax
80109441:	01 d0                	add    %edx,%eax
}
80109443:	c9                   	leave  
80109444:	c3                   	ret    

80109445 <H2N_uint>:

uint H2N_uint(uint value){
80109445:	55                   	push   %ebp
80109446:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109448:	8b 45 08             	mov    0x8(%ebp),%eax
8010944b:	c1 e0 18             	shl    $0x18,%eax
8010944e:	25 00 00 00 0f       	and    $0xf000000,%eax
80109453:	89 c2                	mov    %eax,%edx
80109455:	8b 45 08             	mov    0x8(%ebp),%eax
80109458:	c1 e0 08             	shl    $0x8,%eax
8010945b:	25 00 f0 00 00       	and    $0xf000,%eax
80109460:	09 c2                	or     %eax,%edx
80109462:	8b 45 08             	mov    0x8(%ebp),%eax
80109465:	c1 e8 08             	shr    $0x8,%eax
80109468:	83 e0 0f             	and    $0xf,%eax
8010946b:	01 d0                	add    %edx,%eax
}
8010946d:	5d                   	pop    %ebp
8010946e:	c3                   	ret    

8010946f <N2H_uint>:

uint N2H_uint(uint value){
8010946f:	55                   	push   %ebp
80109470:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109472:	8b 45 08             	mov    0x8(%ebp),%eax
80109475:	c1 e0 18             	shl    $0x18,%eax
80109478:	89 c2                	mov    %eax,%edx
8010947a:	8b 45 08             	mov    0x8(%ebp),%eax
8010947d:	c1 e0 08             	shl    $0x8,%eax
80109480:	25 00 00 ff 00       	and    $0xff0000,%eax
80109485:	01 c2                	add    %eax,%edx
80109487:	8b 45 08             	mov    0x8(%ebp),%eax
8010948a:	c1 e8 08             	shr    $0x8,%eax
8010948d:	25 00 ff 00 00       	and    $0xff00,%eax
80109492:	01 c2                	add    %eax,%edx
80109494:	8b 45 08             	mov    0x8(%ebp),%eax
80109497:	c1 e8 18             	shr    $0x18,%eax
8010949a:	01 d0                	add    %edx,%eax
}
8010949c:	5d                   	pop    %ebp
8010949d:	c3                   	ret    

8010949e <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
8010949e:	55                   	push   %ebp
8010949f:	89 e5                	mov    %esp,%ebp
801094a1:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
801094a4:	8b 45 08             	mov    0x8(%ebp),%eax
801094a7:	83 c0 0e             	add    $0xe,%eax
801094aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
801094ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094b0:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801094b4:	0f b7 d0             	movzwl %ax,%edx
801094b7:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
801094bc:	39 c2                	cmp    %eax,%edx
801094be:	74 60                	je     80109520 <ipv4_proc+0x82>
801094c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094c3:	83 c0 0c             	add    $0xc,%eax
801094c6:	83 ec 04             	sub    $0x4,%esp
801094c9:	6a 04                	push   $0x4
801094cb:	50                   	push   %eax
801094cc:	68 e4 f4 10 80       	push   $0x8010f4e4
801094d1:	e8 13 b5 ff ff       	call   801049e9 <memcmp>
801094d6:	83 c4 10             	add    $0x10,%esp
801094d9:	85 c0                	test   %eax,%eax
801094db:	74 43                	je     80109520 <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
801094dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094e0:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801094e4:	0f b7 c0             	movzwl %ax,%eax
801094e7:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
801094ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094ef:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801094f3:	3c 01                	cmp    $0x1,%al
801094f5:	75 10                	jne    80109507 <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
801094f7:	83 ec 0c             	sub    $0xc,%esp
801094fa:	ff 75 08             	push   0x8(%ebp)
801094fd:	e8 a3 00 00 00       	call   801095a5 <icmp_proc>
80109502:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109505:	eb 19                	jmp    80109520 <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109507:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010950a:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010950e:	3c 06                	cmp    $0x6,%al
80109510:	75 0e                	jne    80109520 <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
80109512:	83 ec 0c             	sub    $0xc,%esp
80109515:	ff 75 08             	push   0x8(%ebp)
80109518:	e8 b3 03 00 00       	call   801098d0 <tcp_proc>
8010951d:	83 c4 10             	add    $0x10,%esp
}
80109520:	90                   	nop
80109521:	c9                   	leave  
80109522:	c3                   	ret    

80109523 <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109523:	55                   	push   %ebp
80109524:	89 e5                	mov    %esp,%ebp
80109526:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109529:	8b 45 08             	mov    0x8(%ebp),%eax
8010952c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
8010952f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109532:	0f b6 00             	movzbl (%eax),%eax
80109535:	83 e0 0f             	and    $0xf,%eax
80109538:	01 c0                	add    %eax,%eax
8010953a:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
8010953d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109544:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010954b:	eb 48                	jmp    80109595 <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010954d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109550:	01 c0                	add    %eax,%eax
80109552:	89 c2                	mov    %eax,%edx
80109554:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109557:	01 d0                	add    %edx,%eax
80109559:	0f b6 00             	movzbl (%eax),%eax
8010955c:	0f b6 c0             	movzbl %al,%eax
8010955f:	c1 e0 08             	shl    $0x8,%eax
80109562:	89 c2                	mov    %eax,%edx
80109564:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109567:	01 c0                	add    %eax,%eax
80109569:	8d 48 01             	lea    0x1(%eax),%ecx
8010956c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010956f:	01 c8                	add    %ecx,%eax
80109571:	0f b6 00             	movzbl (%eax),%eax
80109574:	0f b6 c0             	movzbl %al,%eax
80109577:	01 d0                	add    %edx,%eax
80109579:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010957c:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109583:	76 0c                	jbe    80109591 <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
80109585:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109588:	0f b7 c0             	movzwl %ax,%eax
8010958b:	83 c0 01             	add    $0x1,%eax
8010958e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109591:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109595:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109599:	39 45 f8             	cmp    %eax,-0x8(%ebp)
8010959c:	7c af                	jl     8010954d <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
8010959e:	8b 45 fc             	mov    -0x4(%ebp),%eax
801095a1:	f7 d0                	not    %eax
}
801095a3:	c9                   	leave  
801095a4:	c3                   	ret    

801095a5 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
801095a5:	55                   	push   %ebp
801095a6:	89 e5                	mov    %esp,%ebp
801095a8:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
801095ab:	8b 45 08             	mov    0x8(%ebp),%eax
801095ae:	83 c0 0e             	add    $0xe,%eax
801095b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
801095b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095b7:	0f b6 00             	movzbl (%eax),%eax
801095ba:	0f b6 c0             	movzbl %al,%eax
801095bd:	83 e0 0f             	and    $0xf,%eax
801095c0:	c1 e0 02             	shl    $0x2,%eax
801095c3:	89 c2                	mov    %eax,%edx
801095c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095c8:	01 d0                	add    %edx,%eax
801095ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
801095cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095d0:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801095d4:	84 c0                	test   %al,%al
801095d6:	75 4f                	jne    80109627 <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
801095d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095db:	0f b6 00             	movzbl (%eax),%eax
801095de:	3c 08                	cmp    $0x8,%al
801095e0:	75 45                	jne    80109627 <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
801095e2:	e8 b9 91 ff ff       	call   801027a0 <kalloc>
801095e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
801095ea:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
801095f1:	83 ec 04             	sub    $0x4,%esp
801095f4:	8d 45 e8             	lea    -0x18(%ebp),%eax
801095f7:	50                   	push   %eax
801095f8:	ff 75 ec             	push   -0x14(%ebp)
801095fb:	ff 75 08             	push   0x8(%ebp)
801095fe:	e8 78 00 00 00       	call   8010967b <icmp_reply_pkt_create>
80109603:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109606:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109609:	83 ec 08             	sub    $0x8,%esp
8010960c:	50                   	push   %eax
8010960d:	ff 75 ec             	push   -0x14(%ebp)
80109610:	e8 95 f4 ff ff       	call   80108aaa <i8254_send>
80109615:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109618:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010961b:	83 ec 0c             	sub    $0xc,%esp
8010961e:	50                   	push   %eax
8010961f:	e8 e2 90 ff ff       	call   80102706 <kfree>
80109624:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109627:	90                   	nop
80109628:	c9                   	leave  
80109629:	c3                   	ret    

8010962a <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
8010962a:	55                   	push   %ebp
8010962b:	89 e5                	mov    %esp,%ebp
8010962d:	53                   	push   %ebx
8010962e:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109631:	8b 45 08             	mov    0x8(%ebp),%eax
80109634:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109638:	0f b7 c0             	movzwl %ax,%eax
8010963b:	83 ec 0c             	sub    $0xc,%esp
8010963e:	50                   	push   %eax
8010963f:	e8 bd fd ff ff       	call   80109401 <N2H_ushort>
80109644:	83 c4 10             	add    $0x10,%esp
80109647:	0f b7 d8             	movzwl %ax,%ebx
8010964a:	8b 45 08             	mov    0x8(%ebp),%eax
8010964d:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109651:	0f b7 c0             	movzwl %ax,%eax
80109654:	83 ec 0c             	sub    $0xc,%esp
80109657:	50                   	push   %eax
80109658:	e8 a4 fd ff ff       	call   80109401 <N2H_ushort>
8010965d:	83 c4 10             	add    $0x10,%esp
80109660:	0f b7 c0             	movzwl %ax,%eax
80109663:	83 ec 04             	sub    $0x4,%esp
80109666:	53                   	push   %ebx
80109667:	50                   	push   %eax
80109668:	68 63 bf 10 80       	push   $0x8010bf63
8010966d:	e8 82 6d ff ff       	call   801003f4 <cprintf>
80109672:	83 c4 10             	add    $0x10,%esp
}
80109675:	90                   	nop
80109676:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109679:	c9                   	leave  
8010967a:	c3                   	ret    

8010967b <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
8010967b:	55                   	push   %ebp
8010967c:	89 e5                	mov    %esp,%ebp
8010967e:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109681:	8b 45 08             	mov    0x8(%ebp),%eax
80109684:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109687:	8b 45 08             	mov    0x8(%ebp),%eax
8010968a:	83 c0 0e             	add    $0xe,%eax
8010968d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109690:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109693:	0f b6 00             	movzbl (%eax),%eax
80109696:	0f b6 c0             	movzbl %al,%eax
80109699:	83 e0 0f             	and    $0xf,%eax
8010969c:	c1 e0 02             	shl    $0x2,%eax
8010969f:	89 c2                	mov    %eax,%edx
801096a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096a4:	01 d0                	add    %edx,%eax
801096a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
801096a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801096ac:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
801096af:	8b 45 0c             	mov    0xc(%ebp),%eax
801096b2:	83 c0 0e             	add    $0xe,%eax
801096b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
801096b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801096bb:	83 c0 14             	add    $0x14,%eax
801096be:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
801096c1:	8b 45 10             	mov    0x10(%ebp),%eax
801096c4:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
801096ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096cd:	8d 50 06             	lea    0x6(%eax),%edx
801096d0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096d3:	83 ec 04             	sub    $0x4,%esp
801096d6:	6a 06                	push   $0x6
801096d8:	52                   	push   %edx
801096d9:	50                   	push   %eax
801096da:	e8 62 b3 ff ff       	call   80104a41 <memmove>
801096df:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
801096e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096e5:	83 c0 06             	add    $0x6,%eax
801096e8:	83 ec 04             	sub    $0x4,%esp
801096eb:	6a 06                	push   $0x6
801096ed:	68 80 6d 19 80       	push   $0x80196d80
801096f2:	50                   	push   %eax
801096f3:	e8 49 b3 ff ff       	call   80104a41 <memmove>
801096f8:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
801096fb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096fe:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109702:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109705:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109709:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010970c:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010970f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109712:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109716:	83 ec 0c             	sub    $0xc,%esp
80109719:	6a 54                	push   $0x54
8010971b:	e8 03 fd ff ff       	call   80109423 <H2N_ushort>
80109720:	83 c4 10             	add    $0x10,%esp
80109723:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109726:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010972a:	0f b7 15 60 70 19 80 	movzwl 0x80197060,%edx
80109731:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109734:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109738:	0f b7 05 60 70 19 80 	movzwl 0x80197060,%eax
8010973f:	83 c0 01             	add    $0x1,%eax
80109742:	66 a3 60 70 19 80    	mov    %ax,0x80197060
  ipv4_send->fragment = H2N_ushort(0x4000);
80109748:	83 ec 0c             	sub    $0xc,%esp
8010974b:	68 00 40 00 00       	push   $0x4000
80109750:	e8 ce fc ff ff       	call   80109423 <H2N_ushort>
80109755:	83 c4 10             	add    $0x10,%esp
80109758:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010975b:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010975f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109762:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109766:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109769:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010976d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109770:	83 c0 0c             	add    $0xc,%eax
80109773:	83 ec 04             	sub    $0x4,%esp
80109776:	6a 04                	push   $0x4
80109778:	68 e4 f4 10 80       	push   $0x8010f4e4
8010977d:	50                   	push   %eax
8010977e:	e8 be b2 ff ff       	call   80104a41 <memmove>
80109783:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109786:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109789:	8d 50 0c             	lea    0xc(%eax),%edx
8010978c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010978f:	83 c0 10             	add    $0x10,%eax
80109792:	83 ec 04             	sub    $0x4,%esp
80109795:	6a 04                	push   $0x4
80109797:	52                   	push   %edx
80109798:	50                   	push   %eax
80109799:	e8 a3 b2 ff ff       	call   80104a41 <memmove>
8010979e:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
801097a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801097a4:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
801097aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801097ad:	83 ec 0c             	sub    $0xc,%esp
801097b0:	50                   	push   %eax
801097b1:	e8 6d fd ff ff       	call   80109523 <ipv4_chksum>
801097b6:	83 c4 10             	add    $0x10,%esp
801097b9:	0f b7 c0             	movzwl %ax,%eax
801097bc:	83 ec 0c             	sub    $0xc,%esp
801097bf:	50                   	push   %eax
801097c0:	e8 5e fc ff ff       	call   80109423 <H2N_ushort>
801097c5:	83 c4 10             	add    $0x10,%esp
801097c8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801097cb:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
801097cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801097d2:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
801097d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801097d8:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
801097dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801097df:	0f b7 50 04          	movzwl 0x4(%eax),%edx
801097e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801097e6:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
801097ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
801097ed:	0f b7 50 06          	movzwl 0x6(%eax),%edx
801097f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801097f4:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
801097f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801097fb:	8d 50 08             	lea    0x8(%eax),%edx
801097fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109801:	83 c0 08             	add    $0x8,%eax
80109804:	83 ec 04             	sub    $0x4,%esp
80109807:	6a 08                	push   $0x8
80109809:	52                   	push   %edx
8010980a:	50                   	push   %eax
8010980b:	e8 31 b2 ff ff       	call   80104a41 <memmove>
80109810:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109813:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109816:	8d 50 10             	lea    0x10(%eax),%edx
80109819:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010981c:	83 c0 10             	add    $0x10,%eax
8010981f:	83 ec 04             	sub    $0x4,%esp
80109822:	6a 30                	push   $0x30
80109824:	52                   	push   %edx
80109825:	50                   	push   %eax
80109826:	e8 16 b2 ff ff       	call   80104a41 <memmove>
8010982b:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
8010982e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109831:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109837:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010983a:	83 ec 0c             	sub    $0xc,%esp
8010983d:	50                   	push   %eax
8010983e:	e8 1c 00 00 00       	call   8010985f <icmp_chksum>
80109843:	83 c4 10             	add    $0x10,%esp
80109846:	0f b7 c0             	movzwl %ax,%eax
80109849:	83 ec 0c             	sub    $0xc,%esp
8010984c:	50                   	push   %eax
8010984d:	e8 d1 fb ff ff       	call   80109423 <H2N_ushort>
80109852:	83 c4 10             	add    $0x10,%esp
80109855:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109858:	66 89 42 02          	mov    %ax,0x2(%edx)
}
8010985c:	90                   	nop
8010985d:	c9                   	leave  
8010985e:	c3                   	ret    

8010985f <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
8010985f:	55                   	push   %ebp
80109860:	89 e5                	mov    %esp,%ebp
80109862:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109865:	8b 45 08             	mov    0x8(%ebp),%eax
80109868:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
8010986b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109872:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109879:	eb 48                	jmp    801098c3 <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010987b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010987e:	01 c0                	add    %eax,%eax
80109880:	89 c2                	mov    %eax,%edx
80109882:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109885:	01 d0                	add    %edx,%eax
80109887:	0f b6 00             	movzbl (%eax),%eax
8010988a:	0f b6 c0             	movzbl %al,%eax
8010988d:	c1 e0 08             	shl    $0x8,%eax
80109890:	89 c2                	mov    %eax,%edx
80109892:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109895:	01 c0                	add    %eax,%eax
80109897:	8d 48 01             	lea    0x1(%eax),%ecx
8010989a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010989d:	01 c8                	add    %ecx,%eax
8010989f:	0f b6 00             	movzbl (%eax),%eax
801098a2:	0f b6 c0             	movzbl %al,%eax
801098a5:	01 d0                	add    %edx,%eax
801098a7:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
801098aa:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
801098b1:	76 0c                	jbe    801098bf <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
801098b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801098b6:	0f b7 c0             	movzwl %ax,%eax
801098b9:	83 c0 01             	add    $0x1,%eax
801098bc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
801098bf:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801098c3:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
801098c7:	7e b2                	jle    8010987b <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
801098c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801098cc:	f7 d0                	not    %eax
}
801098ce:	c9                   	leave  
801098cf:	c3                   	ret    

801098d0 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
801098d0:	55                   	push   %ebp
801098d1:	89 e5                	mov    %esp,%ebp
801098d3:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
801098d6:	8b 45 08             	mov    0x8(%ebp),%eax
801098d9:	83 c0 0e             	add    $0xe,%eax
801098dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
801098df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098e2:	0f b6 00             	movzbl (%eax),%eax
801098e5:	0f b6 c0             	movzbl %al,%eax
801098e8:	83 e0 0f             	and    $0xf,%eax
801098eb:	c1 e0 02             	shl    $0x2,%eax
801098ee:	89 c2                	mov    %eax,%edx
801098f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098f3:	01 d0                	add    %edx,%eax
801098f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
801098f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098fb:	83 c0 14             	add    $0x14,%eax
801098fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109901:	e8 9a 8e ff ff       	call   801027a0 <kalloc>
80109906:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109909:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109910:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109913:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109917:	0f b6 c0             	movzbl %al,%eax
8010991a:	83 e0 02             	and    $0x2,%eax
8010991d:	85 c0                	test   %eax,%eax
8010991f:	74 3d                	je     8010995e <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109921:	83 ec 0c             	sub    $0xc,%esp
80109924:	6a 00                	push   $0x0
80109926:	6a 12                	push   $0x12
80109928:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010992b:	50                   	push   %eax
8010992c:	ff 75 e8             	push   -0x18(%ebp)
8010992f:	ff 75 08             	push   0x8(%ebp)
80109932:	e8 a2 01 00 00       	call   80109ad9 <tcp_pkt_create>
80109937:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
8010993a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010993d:	83 ec 08             	sub    $0x8,%esp
80109940:	50                   	push   %eax
80109941:	ff 75 e8             	push   -0x18(%ebp)
80109944:	e8 61 f1 ff ff       	call   80108aaa <i8254_send>
80109949:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010994c:	a1 64 70 19 80       	mov    0x80197064,%eax
80109951:	83 c0 01             	add    $0x1,%eax
80109954:	a3 64 70 19 80       	mov    %eax,0x80197064
80109959:	e9 69 01 00 00       	jmp    80109ac7 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
8010995e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109961:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109965:	3c 18                	cmp    $0x18,%al
80109967:	0f 85 10 01 00 00    	jne    80109a7d <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
8010996d:	83 ec 04             	sub    $0x4,%esp
80109970:	6a 03                	push   $0x3
80109972:	68 7e bf 10 80       	push   $0x8010bf7e
80109977:	ff 75 ec             	push   -0x14(%ebp)
8010997a:	e8 6a b0 ff ff       	call   801049e9 <memcmp>
8010997f:	83 c4 10             	add    $0x10,%esp
80109982:	85 c0                	test   %eax,%eax
80109984:	74 74                	je     801099fa <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
80109986:	83 ec 0c             	sub    $0xc,%esp
80109989:	68 82 bf 10 80       	push   $0x8010bf82
8010998e:	e8 61 6a ff ff       	call   801003f4 <cprintf>
80109993:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109996:	83 ec 0c             	sub    $0xc,%esp
80109999:	6a 00                	push   $0x0
8010999b:	6a 10                	push   $0x10
8010999d:	8d 45 dc             	lea    -0x24(%ebp),%eax
801099a0:	50                   	push   %eax
801099a1:	ff 75 e8             	push   -0x18(%ebp)
801099a4:	ff 75 08             	push   0x8(%ebp)
801099a7:	e8 2d 01 00 00       	call   80109ad9 <tcp_pkt_create>
801099ac:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
801099af:	8b 45 dc             	mov    -0x24(%ebp),%eax
801099b2:	83 ec 08             	sub    $0x8,%esp
801099b5:	50                   	push   %eax
801099b6:	ff 75 e8             	push   -0x18(%ebp)
801099b9:	e8 ec f0 ff ff       	call   80108aaa <i8254_send>
801099be:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
801099c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801099c4:	83 c0 36             	add    $0x36,%eax
801099c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
801099ca:	8d 45 d8             	lea    -0x28(%ebp),%eax
801099cd:	50                   	push   %eax
801099ce:	ff 75 e0             	push   -0x20(%ebp)
801099d1:	6a 00                	push   $0x0
801099d3:	6a 00                	push   $0x0
801099d5:	e8 5a 04 00 00       	call   80109e34 <http_proc>
801099da:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
801099dd:	8b 45 d8             	mov    -0x28(%ebp),%eax
801099e0:	83 ec 0c             	sub    $0xc,%esp
801099e3:	50                   	push   %eax
801099e4:	6a 18                	push   $0x18
801099e6:	8d 45 dc             	lea    -0x24(%ebp),%eax
801099e9:	50                   	push   %eax
801099ea:	ff 75 e8             	push   -0x18(%ebp)
801099ed:	ff 75 08             	push   0x8(%ebp)
801099f0:	e8 e4 00 00 00       	call   80109ad9 <tcp_pkt_create>
801099f5:	83 c4 20             	add    $0x20,%esp
801099f8:	eb 62                	jmp    80109a5c <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
801099fa:	83 ec 0c             	sub    $0xc,%esp
801099fd:	6a 00                	push   $0x0
801099ff:	6a 10                	push   $0x10
80109a01:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109a04:	50                   	push   %eax
80109a05:	ff 75 e8             	push   -0x18(%ebp)
80109a08:	ff 75 08             	push   0x8(%ebp)
80109a0b:	e8 c9 00 00 00       	call   80109ad9 <tcp_pkt_create>
80109a10:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
80109a13:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109a16:	83 ec 08             	sub    $0x8,%esp
80109a19:	50                   	push   %eax
80109a1a:	ff 75 e8             	push   -0x18(%ebp)
80109a1d:	e8 88 f0 ff ff       	call   80108aaa <i8254_send>
80109a22:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109a25:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a28:	83 c0 36             	add    $0x36,%eax
80109a2b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109a2e:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109a31:	50                   	push   %eax
80109a32:	ff 75 e4             	push   -0x1c(%ebp)
80109a35:	6a 00                	push   $0x0
80109a37:	6a 00                	push   $0x0
80109a39:	e8 f6 03 00 00       	call   80109e34 <http_proc>
80109a3e:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109a41:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109a44:	83 ec 0c             	sub    $0xc,%esp
80109a47:	50                   	push   %eax
80109a48:	6a 18                	push   $0x18
80109a4a:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109a4d:	50                   	push   %eax
80109a4e:	ff 75 e8             	push   -0x18(%ebp)
80109a51:	ff 75 08             	push   0x8(%ebp)
80109a54:	e8 80 00 00 00       	call   80109ad9 <tcp_pkt_create>
80109a59:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
80109a5c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109a5f:	83 ec 08             	sub    $0x8,%esp
80109a62:	50                   	push   %eax
80109a63:	ff 75 e8             	push   -0x18(%ebp)
80109a66:	e8 3f f0 ff ff       	call   80108aaa <i8254_send>
80109a6b:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109a6e:	a1 64 70 19 80       	mov    0x80197064,%eax
80109a73:	83 c0 01             	add    $0x1,%eax
80109a76:	a3 64 70 19 80       	mov    %eax,0x80197064
80109a7b:	eb 4a                	jmp    80109ac7 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
80109a7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a80:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109a84:	3c 10                	cmp    $0x10,%al
80109a86:	75 3f                	jne    80109ac7 <tcp_proc+0x1f7>
    if(fin_flag == 1){
80109a88:	a1 68 70 19 80       	mov    0x80197068,%eax
80109a8d:	83 f8 01             	cmp    $0x1,%eax
80109a90:	75 35                	jne    80109ac7 <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
80109a92:	83 ec 0c             	sub    $0xc,%esp
80109a95:	6a 00                	push   $0x0
80109a97:	6a 01                	push   $0x1
80109a99:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109a9c:	50                   	push   %eax
80109a9d:	ff 75 e8             	push   -0x18(%ebp)
80109aa0:	ff 75 08             	push   0x8(%ebp)
80109aa3:	e8 31 00 00 00       	call   80109ad9 <tcp_pkt_create>
80109aa8:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109aab:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109aae:	83 ec 08             	sub    $0x8,%esp
80109ab1:	50                   	push   %eax
80109ab2:	ff 75 e8             	push   -0x18(%ebp)
80109ab5:	e8 f0 ef ff ff       	call   80108aaa <i8254_send>
80109aba:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
80109abd:	c7 05 68 70 19 80 00 	movl   $0x0,0x80197068
80109ac4:	00 00 00 
    }
  }
  kfree((char *)send_addr);
80109ac7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109aca:	83 ec 0c             	sub    $0xc,%esp
80109acd:	50                   	push   %eax
80109ace:	e8 33 8c ff ff       	call   80102706 <kfree>
80109ad3:	83 c4 10             	add    $0x10,%esp
}
80109ad6:	90                   	nop
80109ad7:	c9                   	leave  
80109ad8:	c3                   	ret    

80109ad9 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
80109ad9:	55                   	push   %ebp
80109ada:	89 e5                	mov    %esp,%ebp
80109adc:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109adf:	8b 45 08             	mov    0x8(%ebp),%eax
80109ae2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109ae5:	8b 45 08             	mov    0x8(%ebp),%eax
80109ae8:	83 c0 0e             	add    $0xe,%eax
80109aeb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
80109aee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109af1:	0f b6 00             	movzbl (%eax),%eax
80109af4:	0f b6 c0             	movzbl %al,%eax
80109af7:	83 e0 0f             	and    $0xf,%eax
80109afa:	c1 e0 02             	shl    $0x2,%eax
80109afd:	89 c2                	mov    %eax,%edx
80109aff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b02:	01 d0                	add    %edx,%eax
80109b04:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109b07:	8b 45 0c             	mov    0xc(%ebp),%eax
80109b0a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
80109b0d:	8b 45 0c             	mov    0xc(%ebp),%eax
80109b10:	83 c0 0e             	add    $0xe,%eax
80109b13:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
80109b16:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b19:	83 c0 14             	add    $0x14,%eax
80109b1c:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
80109b1f:	8b 45 18             	mov    0x18(%ebp),%eax
80109b22:	8d 50 36             	lea    0x36(%eax),%edx
80109b25:	8b 45 10             	mov    0x10(%ebp),%eax
80109b28:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109b2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b2d:	8d 50 06             	lea    0x6(%eax),%edx
80109b30:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b33:	83 ec 04             	sub    $0x4,%esp
80109b36:	6a 06                	push   $0x6
80109b38:	52                   	push   %edx
80109b39:	50                   	push   %eax
80109b3a:	e8 02 af ff ff       	call   80104a41 <memmove>
80109b3f:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109b42:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b45:	83 c0 06             	add    $0x6,%eax
80109b48:	83 ec 04             	sub    $0x4,%esp
80109b4b:	6a 06                	push   $0x6
80109b4d:	68 80 6d 19 80       	push   $0x80196d80
80109b52:	50                   	push   %eax
80109b53:	e8 e9 ae ff ff       	call   80104a41 <memmove>
80109b58:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109b5b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b5e:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109b62:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b65:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109b69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b6c:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109b6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b72:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
80109b76:	8b 45 18             	mov    0x18(%ebp),%eax
80109b79:	83 c0 28             	add    $0x28,%eax
80109b7c:	0f b7 c0             	movzwl %ax,%eax
80109b7f:	83 ec 0c             	sub    $0xc,%esp
80109b82:	50                   	push   %eax
80109b83:	e8 9b f8 ff ff       	call   80109423 <H2N_ushort>
80109b88:	83 c4 10             	add    $0x10,%esp
80109b8b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109b8e:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109b92:	0f b7 15 60 70 19 80 	movzwl 0x80197060,%edx
80109b99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b9c:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109ba0:	0f b7 05 60 70 19 80 	movzwl 0x80197060,%eax
80109ba7:	83 c0 01             	add    $0x1,%eax
80109baa:	66 a3 60 70 19 80    	mov    %ax,0x80197060
  ipv4_send->fragment = H2N_ushort(0x0000);
80109bb0:	83 ec 0c             	sub    $0xc,%esp
80109bb3:	6a 00                	push   $0x0
80109bb5:	e8 69 f8 ff ff       	call   80109423 <H2N_ushort>
80109bba:	83 c4 10             	add    $0x10,%esp
80109bbd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109bc0:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109bc4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bc7:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
80109bcb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bce:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109bd2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bd5:	83 c0 0c             	add    $0xc,%eax
80109bd8:	83 ec 04             	sub    $0x4,%esp
80109bdb:	6a 04                	push   $0x4
80109bdd:	68 e4 f4 10 80       	push   $0x8010f4e4
80109be2:	50                   	push   %eax
80109be3:	e8 59 ae ff ff       	call   80104a41 <memmove>
80109be8:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109beb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bee:	8d 50 0c             	lea    0xc(%eax),%edx
80109bf1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bf4:	83 c0 10             	add    $0x10,%eax
80109bf7:	83 ec 04             	sub    $0x4,%esp
80109bfa:	6a 04                	push   $0x4
80109bfc:	52                   	push   %edx
80109bfd:	50                   	push   %eax
80109bfe:	e8 3e ae ff ff       	call   80104a41 <memmove>
80109c03:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109c06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c09:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109c0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c12:	83 ec 0c             	sub    $0xc,%esp
80109c15:	50                   	push   %eax
80109c16:	e8 08 f9 ff ff       	call   80109523 <ipv4_chksum>
80109c1b:	83 c4 10             	add    $0x10,%esp
80109c1e:	0f b7 c0             	movzwl %ax,%eax
80109c21:	83 ec 0c             	sub    $0xc,%esp
80109c24:	50                   	push   %eax
80109c25:	e8 f9 f7 ff ff       	call   80109423 <H2N_ushort>
80109c2a:	83 c4 10             	add    $0x10,%esp
80109c2d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109c30:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
80109c34:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c37:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80109c3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c3e:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
80109c41:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c44:	0f b7 10             	movzwl (%eax),%edx
80109c47:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c4a:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
80109c4e:	a1 64 70 19 80       	mov    0x80197064,%eax
80109c53:	83 ec 0c             	sub    $0xc,%esp
80109c56:	50                   	push   %eax
80109c57:	e8 e9 f7 ff ff       	call   80109445 <H2N_uint>
80109c5c:	83 c4 10             	add    $0x10,%esp
80109c5f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109c62:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
80109c65:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c68:	8b 40 04             	mov    0x4(%eax),%eax
80109c6b:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
80109c71:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c74:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
80109c77:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c7a:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
80109c7e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c81:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
80109c85:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c88:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
80109c8c:	8b 45 14             	mov    0x14(%ebp),%eax
80109c8f:	89 c2                	mov    %eax,%edx
80109c91:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c94:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
80109c97:	83 ec 0c             	sub    $0xc,%esp
80109c9a:	68 90 38 00 00       	push   $0x3890
80109c9f:	e8 7f f7 ff ff       	call   80109423 <H2N_ushort>
80109ca4:	83 c4 10             	add    $0x10,%esp
80109ca7:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109caa:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
80109cae:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cb1:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
80109cb7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cba:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
80109cc0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cc3:	83 ec 0c             	sub    $0xc,%esp
80109cc6:	50                   	push   %eax
80109cc7:	e8 1f 00 00 00       	call   80109ceb <tcp_chksum>
80109ccc:	83 c4 10             	add    $0x10,%esp
80109ccf:	83 c0 08             	add    $0x8,%eax
80109cd2:	0f b7 c0             	movzwl %ax,%eax
80109cd5:	83 ec 0c             	sub    $0xc,%esp
80109cd8:	50                   	push   %eax
80109cd9:	e8 45 f7 ff ff       	call   80109423 <H2N_ushort>
80109cde:	83 c4 10             	add    $0x10,%esp
80109ce1:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109ce4:	66 89 42 10          	mov    %ax,0x10(%edx)


}
80109ce8:	90                   	nop
80109ce9:	c9                   	leave  
80109cea:	c3                   	ret    

80109ceb <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
80109ceb:	55                   	push   %ebp
80109cec:	89 e5                	mov    %esp,%ebp
80109cee:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
80109cf1:	8b 45 08             	mov    0x8(%ebp),%eax
80109cf4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
80109cf7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109cfa:	83 c0 14             	add    $0x14,%eax
80109cfd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
80109d00:	83 ec 04             	sub    $0x4,%esp
80109d03:	6a 04                	push   $0x4
80109d05:	68 e4 f4 10 80       	push   $0x8010f4e4
80109d0a:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109d0d:	50                   	push   %eax
80109d0e:	e8 2e ad ff ff       	call   80104a41 <memmove>
80109d13:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
80109d16:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d19:	83 c0 0c             	add    $0xc,%eax
80109d1c:	83 ec 04             	sub    $0x4,%esp
80109d1f:	6a 04                	push   $0x4
80109d21:	50                   	push   %eax
80109d22:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109d25:	83 c0 04             	add    $0x4,%eax
80109d28:	50                   	push   %eax
80109d29:	e8 13 ad ff ff       	call   80104a41 <memmove>
80109d2e:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
80109d31:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
80109d35:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
80109d39:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d3c:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80109d40:	0f b7 c0             	movzwl %ax,%eax
80109d43:	83 ec 0c             	sub    $0xc,%esp
80109d46:	50                   	push   %eax
80109d47:	e8 b5 f6 ff ff       	call   80109401 <N2H_ushort>
80109d4c:	83 c4 10             	add    $0x10,%esp
80109d4f:	83 e8 14             	sub    $0x14,%eax
80109d52:	0f b7 c0             	movzwl %ax,%eax
80109d55:	83 ec 0c             	sub    $0xc,%esp
80109d58:	50                   	push   %eax
80109d59:	e8 c5 f6 ff ff       	call   80109423 <H2N_ushort>
80109d5e:	83 c4 10             	add    $0x10,%esp
80109d61:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
80109d65:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
80109d6c:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109d6f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
80109d72:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109d79:	eb 33                	jmp    80109dae <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109d7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d7e:	01 c0                	add    %eax,%eax
80109d80:	89 c2                	mov    %eax,%edx
80109d82:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d85:	01 d0                	add    %edx,%eax
80109d87:	0f b6 00             	movzbl (%eax),%eax
80109d8a:	0f b6 c0             	movzbl %al,%eax
80109d8d:	c1 e0 08             	shl    $0x8,%eax
80109d90:	89 c2                	mov    %eax,%edx
80109d92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d95:	01 c0                	add    %eax,%eax
80109d97:	8d 48 01             	lea    0x1(%eax),%ecx
80109d9a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d9d:	01 c8                	add    %ecx,%eax
80109d9f:	0f b6 00             	movzbl (%eax),%eax
80109da2:	0f b6 c0             	movzbl %al,%eax
80109da5:	01 d0                	add    %edx,%eax
80109da7:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
80109daa:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109dae:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
80109db2:	7e c7                	jle    80109d7b <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
80109db4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109db7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
80109dba:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80109dc1:	eb 33                	jmp    80109df6 <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109dc3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109dc6:	01 c0                	add    %eax,%eax
80109dc8:	89 c2                	mov    %eax,%edx
80109dca:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109dcd:	01 d0                	add    %edx,%eax
80109dcf:	0f b6 00             	movzbl (%eax),%eax
80109dd2:	0f b6 c0             	movzbl %al,%eax
80109dd5:	c1 e0 08             	shl    $0x8,%eax
80109dd8:	89 c2                	mov    %eax,%edx
80109dda:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ddd:	01 c0                	add    %eax,%eax
80109ddf:	8d 48 01             	lea    0x1(%eax),%ecx
80109de2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109de5:	01 c8                	add    %ecx,%eax
80109de7:	0f b6 00             	movzbl (%eax),%eax
80109dea:	0f b6 c0             	movzbl %al,%eax
80109ded:	01 d0                	add    %edx,%eax
80109def:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
80109df2:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80109df6:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
80109dfa:	0f b7 c0             	movzwl %ax,%eax
80109dfd:	83 ec 0c             	sub    $0xc,%esp
80109e00:	50                   	push   %eax
80109e01:	e8 fb f5 ff ff       	call   80109401 <N2H_ushort>
80109e06:	83 c4 10             	add    $0x10,%esp
80109e09:	66 d1 e8             	shr    %ax
80109e0c:	0f b7 c0             	movzwl %ax,%eax
80109e0f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80109e12:	7c af                	jl     80109dc3 <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
80109e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e17:	c1 e8 10             	shr    $0x10,%eax
80109e1a:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
80109e1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e20:	f7 d0                	not    %eax
}
80109e22:	c9                   	leave  
80109e23:	c3                   	ret    

80109e24 <tcp_fin>:

void tcp_fin(){
80109e24:	55                   	push   %ebp
80109e25:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
80109e27:	c7 05 68 70 19 80 01 	movl   $0x1,0x80197068
80109e2e:	00 00 00 
}
80109e31:	90                   	nop
80109e32:	5d                   	pop    %ebp
80109e33:	c3                   	ret    

80109e34 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
80109e34:	55                   	push   %ebp
80109e35:	89 e5                	mov    %esp,%ebp
80109e37:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
80109e3a:	8b 45 10             	mov    0x10(%ebp),%eax
80109e3d:	83 ec 04             	sub    $0x4,%esp
80109e40:	6a 00                	push   $0x0
80109e42:	68 8b bf 10 80       	push   $0x8010bf8b
80109e47:	50                   	push   %eax
80109e48:	e8 65 00 00 00       	call   80109eb2 <http_strcpy>
80109e4d:	83 c4 10             	add    $0x10,%esp
80109e50:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
80109e53:	8b 45 10             	mov    0x10(%ebp),%eax
80109e56:	83 ec 04             	sub    $0x4,%esp
80109e59:	ff 75 f4             	push   -0xc(%ebp)
80109e5c:	68 9e bf 10 80       	push   $0x8010bf9e
80109e61:	50                   	push   %eax
80109e62:	e8 4b 00 00 00       	call   80109eb2 <http_strcpy>
80109e67:	83 c4 10             	add    $0x10,%esp
80109e6a:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
80109e6d:	8b 45 10             	mov    0x10(%ebp),%eax
80109e70:	83 ec 04             	sub    $0x4,%esp
80109e73:	ff 75 f4             	push   -0xc(%ebp)
80109e76:	68 b9 bf 10 80       	push   $0x8010bfb9
80109e7b:	50                   	push   %eax
80109e7c:	e8 31 00 00 00       	call   80109eb2 <http_strcpy>
80109e81:	83 c4 10             	add    $0x10,%esp
80109e84:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
80109e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e8a:	83 e0 01             	and    $0x1,%eax
80109e8d:	85 c0                	test   %eax,%eax
80109e8f:	74 11                	je     80109ea2 <http_proc+0x6e>
    char *payload = (char *)send;
80109e91:	8b 45 10             	mov    0x10(%ebp),%eax
80109e94:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
80109e97:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109e9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e9d:	01 d0                	add    %edx,%eax
80109e9f:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
80109ea2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109ea5:	8b 45 14             	mov    0x14(%ebp),%eax
80109ea8:	89 10                	mov    %edx,(%eax)
  tcp_fin();
80109eaa:	e8 75 ff ff ff       	call   80109e24 <tcp_fin>
}
80109eaf:	90                   	nop
80109eb0:	c9                   	leave  
80109eb1:	c3                   	ret    

80109eb2 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
80109eb2:	55                   	push   %ebp
80109eb3:	89 e5                	mov    %esp,%ebp
80109eb5:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
80109eb8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
80109ebf:	eb 20                	jmp    80109ee1 <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
80109ec1:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109ec4:	8b 45 0c             	mov    0xc(%ebp),%eax
80109ec7:	01 d0                	add    %edx,%eax
80109ec9:	8b 4d 10             	mov    0x10(%ebp),%ecx
80109ecc:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109ecf:	01 ca                	add    %ecx,%edx
80109ed1:	89 d1                	mov    %edx,%ecx
80109ed3:	8b 55 08             	mov    0x8(%ebp),%edx
80109ed6:	01 ca                	add    %ecx,%edx
80109ed8:	0f b6 00             	movzbl (%eax),%eax
80109edb:	88 02                	mov    %al,(%edx)
    i++;
80109edd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
80109ee1:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109ee4:	8b 45 0c             	mov    0xc(%ebp),%eax
80109ee7:	01 d0                	add    %edx,%eax
80109ee9:	0f b6 00             	movzbl (%eax),%eax
80109eec:	84 c0                	test   %al,%al
80109eee:	75 d1                	jne    80109ec1 <http_strcpy+0xf>
  }
  return i;
80109ef0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80109ef3:	c9                   	leave  
80109ef4:	c3                   	ret    

80109ef5 <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
80109ef5:	55                   	push   %ebp
80109ef6:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
80109ef8:	c7 05 70 70 19 80 a2 	movl   $0x8010f5a2,0x80197070
80109eff:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
80109f02:	b8 00 d0 07 00       	mov    $0x7d000,%eax
80109f07:	c1 e8 09             	shr    $0x9,%eax
80109f0a:	a3 6c 70 19 80       	mov    %eax,0x8019706c
}
80109f0f:	90                   	nop
80109f10:	5d                   	pop    %ebp
80109f11:	c3                   	ret    

80109f12 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80109f12:	55                   	push   %ebp
80109f13:	89 e5                	mov    %esp,%ebp
  // no-op
}
80109f15:	90                   	nop
80109f16:	5d                   	pop    %ebp
80109f17:	c3                   	ret    

80109f18 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80109f18:	55                   	push   %ebp
80109f19:	89 e5                	mov    %esp,%ebp
80109f1b:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
80109f1e:	8b 45 08             	mov    0x8(%ebp),%eax
80109f21:	83 c0 0c             	add    $0xc,%eax
80109f24:	83 ec 0c             	sub    $0xc,%esp
80109f27:	50                   	push   %eax
80109f28:	e8 4e a7 ff ff       	call   8010467b <holdingsleep>
80109f2d:	83 c4 10             	add    $0x10,%esp
80109f30:	85 c0                	test   %eax,%eax
80109f32:	75 0d                	jne    80109f41 <iderw+0x29>
    panic("iderw: buf not locked");
80109f34:	83 ec 0c             	sub    $0xc,%esp
80109f37:	68 ca bf 10 80       	push   $0x8010bfca
80109f3c:	e8 68 66 ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80109f41:	8b 45 08             	mov    0x8(%ebp),%eax
80109f44:	8b 00                	mov    (%eax),%eax
80109f46:	83 e0 06             	and    $0x6,%eax
80109f49:	83 f8 02             	cmp    $0x2,%eax
80109f4c:	75 0d                	jne    80109f5b <iderw+0x43>
    panic("iderw: nothing to do");
80109f4e:	83 ec 0c             	sub    $0xc,%esp
80109f51:	68 e0 bf 10 80       	push   $0x8010bfe0
80109f56:	e8 4e 66 ff ff       	call   801005a9 <panic>
  if(b->dev != 1)
80109f5b:	8b 45 08             	mov    0x8(%ebp),%eax
80109f5e:	8b 40 04             	mov    0x4(%eax),%eax
80109f61:	83 f8 01             	cmp    $0x1,%eax
80109f64:	74 0d                	je     80109f73 <iderw+0x5b>
    panic("iderw: request not for disk 1");
80109f66:	83 ec 0c             	sub    $0xc,%esp
80109f69:	68 f5 bf 10 80       	push   $0x8010bff5
80109f6e:	e8 36 66 ff ff       	call   801005a9 <panic>
  if(b->blockno >= disksize)
80109f73:	8b 45 08             	mov    0x8(%ebp),%eax
80109f76:	8b 40 08             	mov    0x8(%eax),%eax
80109f79:	8b 15 6c 70 19 80    	mov    0x8019706c,%edx
80109f7f:	39 d0                	cmp    %edx,%eax
80109f81:	72 0d                	jb     80109f90 <iderw+0x78>
    panic("iderw: block out of range");
80109f83:	83 ec 0c             	sub    $0xc,%esp
80109f86:	68 13 c0 10 80       	push   $0x8010c013
80109f8b:	e8 19 66 ff ff       	call   801005a9 <panic>

  p = memdisk + b->blockno*BSIZE;
80109f90:	8b 15 70 70 19 80    	mov    0x80197070,%edx
80109f96:	8b 45 08             	mov    0x8(%ebp),%eax
80109f99:	8b 40 08             	mov    0x8(%eax),%eax
80109f9c:	c1 e0 09             	shl    $0x9,%eax
80109f9f:	01 d0                	add    %edx,%eax
80109fa1:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
80109fa4:	8b 45 08             	mov    0x8(%ebp),%eax
80109fa7:	8b 00                	mov    (%eax),%eax
80109fa9:	83 e0 04             	and    $0x4,%eax
80109fac:	85 c0                	test   %eax,%eax
80109fae:	74 2b                	je     80109fdb <iderw+0xc3>
    b->flags &= ~B_DIRTY;
80109fb0:	8b 45 08             	mov    0x8(%ebp),%eax
80109fb3:	8b 00                	mov    (%eax),%eax
80109fb5:	83 e0 fb             	and    $0xfffffffb,%eax
80109fb8:	89 c2                	mov    %eax,%edx
80109fba:	8b 45 08             	mov    0x8(%ebp),%eax
80109fbd:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
80109fbf:	8b 45 08             	mov    0x8(%ebp),%eax
80109fc2:	83 c0 5c             	add    $0x5c,%eax
80109fc5:	83 ec 04             	sub    $0x4,%esp
80109fc8:	68 00 02 00 00       	push   $0x200
80109fcd:	50                   	push   %eax
80109fce:	ff 75 f4             	push   -0xc(%ebp)
80109fd1:	e8 6b aa ff ff       	call   80104a41 <memmove>
80109fd6:	83 c4 10             	add    $0x10,%esp
80109fd9:	eb 1a                	jmp    80109ff5 <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
80109fdb:	8b 45 08             	mov    0x8(%ebp),%eax
80109fde:	83 c0 5c             	add    $0x5c,%eax
80109fe1:	83 ec 04             	sub    $0x4,%esp
80109fe4:	68 00 02 00 00       	push   $0x200
80109fe9:	ff 75 f4             	push   -0xc(%ebp)
80109fec:	50                   	push   %eax
80109fed:	e8 4f aa ff ff       	call   80104a41 <memmove>
80109ff2:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
80109ff5:	8b 45 08             	mov    0x8(%ebp),%eax
80109ff8:	8b 00                	mov    (%eax),%eax
80109ffa:	83 c8 02             	or     $0x2,%eax
80109ffd:	89 c2                	mov    %eax,%edx
80109fff:	8b 45 08             	mov    0x8(%ebp),%eax
8010a002:	89 10                	mov    %edx,(%eax)
}
8010a004:	90                   	nop
8010a005:	c9                   	leave  
8010a006:	c3                   	ret    
