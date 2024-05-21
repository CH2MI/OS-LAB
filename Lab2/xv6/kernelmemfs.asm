
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
8010006f:	68 40 a2 10 80       	push   $0x8010a240
80100074:	68 00 d0 18 80       	push   $0x8018d000
80100079:	e8 af 48 00 00       	call   8010492d <initlock>
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
801000bd:	68 47 a2 10 80       	push   $0x8010a247
801000c2:	50                   	push   %eax
801000c3:	e8 08 47 00 00       	call   801047d0 <initsleeplock>
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
80100101:	e8 49 48 00 00       	call   8010494f <acquire>
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
80100140:	e8 78 48 00 00       	call   801049bd <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 b5 46 00 00       	call   8010480c <acquiresleep>
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
801001c1:	e8 f7 47 00 00       	call   801049bd <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 34 46 00 00       	call   8010480c <acquiresleep>
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
801001f5:	68 4e a2 10 80       	push   $0x8010a24e
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
8010022d:	e8 17 9f 00 00       	call   8010a149 <iderw>
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
8010024a:	e8 6f 46 00 00       	call   801048be <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 5f a2 10 80       	push   $0x8010a25f
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
80100278:	e8 cc 9e 00 00       	call   8010a149 <iderw>
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
80100293:	e8 26 46 00 00       	call   801048be <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 66 a2 10 80       	push   $0x8010a266
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 b5 45 00 00       	call   80104870 <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 d0 18 80       	push   $0x8018d000
801002c6:	e8 84 46 00 00       	call   8010494f <acquire>
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
80100336:	e8 82 46 00 00       	call   801049bd <release>
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
80100410:	e8 3a 45 00 00       	call   8010494f <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 6d a2 10 80       	push   $0x8010a26d
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
80100510:	c7 45 ec 76 a2 10 80 	movl   $0x8010a276,-0x14(%ebp)
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
8010059e:	e8 1a 44 00 00       	call   801049bd <release>
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
801005c7:	68 7d a2 10 80       	push   $0x8010a27d
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
801005e6:	68 91 a2 10 80       	push   $0x8010a291
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 0c 44 00 00       	call   80104a0f <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 93 a2 10 80       	push   $0x8010a293
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
801006a0:	e8 fb 79 00 00       	call   801080a0 <graphic_scroll_up>
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
801006f3:	e8 a8 79 00 00       	call   801080a0 <graphic_scroll_up>
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
80100757:	e8 af 79 00 00       	call   8010810b <font_render>
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
80100793:	e8 7f 5d 00 00       	call   80106517 <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 72 5d 00 00       	call   80106517 <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 65 5d 00 00       	call   80106517 <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x56>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 55 5d 00 00       	call   80106517 <uartputc>
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
801007eb:	e8 5f 41 00 00       	call   8010494f <acquire>
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
8010093f:	e8 d7 3c 00 00       	call   8010461b <wakeup>
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
80100962:	e8 56 40 00 00       	call   801049bd <release>
80100967:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010096a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010096e:	74 05                	je     80100975 <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
80100970:	e8 61 3d 00 00       	call   801046d6 <procdump>
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
8010099a:	e8 b0 3f 00 00       	call   8010494f <acquire>
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
801009bb:	e8 fd 3f 00 00       	call   801049bd <release>
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
801009e8:	e8 47 3b 00 00       	call   80104534 <sleep>
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
80100a66:	e8 52 3f 00 00       	call   801049bd <release>
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
80100aa2:	e8 a8 3e 00 00       	call   8010494f <acquire>
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
80100ae4:	e8 d4 3e 00 00       	call   801049bd <release>
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
80100b12:	68 97 a2 10 80       	push   $0x8010a297
80100b17:	68 00 1a 19 80       	push   $0x80191a00
80100b1c:	e8 0c 3e 00 00       	call   8010492d <initlock>
80100b21:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b24:	c7 05 4c 1a 19 80 86 	movl   $0x80100a86,0x80191a4c
80100b2b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b2e:	c7 05 48 1a 19 80 78 	movl   $0x80100978,0x80191a48
80100b35:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b38:	c7 45 f4 9f a2 10 80 	movl   $0x8010a29f,-0xc(%ebp)
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
80100bb5:	68 b5 a2 10 80       	push   $0x8010a2b5
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
80100c11:	e8 fd 68 00 00       	call   80107513 <setupkvm>
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
80100cb7:	e8 50 6c 00 00       	call   8010790c <allocuvm>
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
80100cfd:	e8 3d 6b 00 00       	call   8010783f <loaduvm>
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
80100d6c:	e8 9b 6b 00 00       	call   8010790c <allocuvm>
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
80100d90:	e8 d9 6d 00 00       	call   80107b6e <clearpteu>
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
80100dc9:	e8 45 40 00 00       	call   80104e13 <strlen>
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
80100df6:	e8 18 40 00 00       	call   80104e13 <strlen>
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
80100e1c:	e8 ec 6e 00 00       	call   80107d0d <copyout>
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
80100eb8:	e8 50 6e 00 00       	call   80107d0d <copyout>
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
80100f06:	e8 bd 3e 00 00       	call   80104dc8 <safestrcpy>
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
80100f49:	e8 e2 66 00 00       	call   80107630 <switchuvm>
80100f4e:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f51:	83 ec 0c             	sub    $0xc,%esp
80100f54:	ff 75 cc             	push   -0x34(%ebp)
80100f57:	e8 79 6b 00 00       	call   80107ad5 <freevm>
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
80100f97:	e8 39 6b 00 00       	call   80107ad5 <freevm>
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
80100fc8:	68 c1 a2 10 80       	push   $0x8010a2c1
80100fcd:	68 a0 1a 19 80       	push   $0x80191aa0
80100fd2:	e8 56 39 00 00       	call   8010492d <initlock>
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
80100feb:	e8 5f 39 00 00       	call   8010494f <acquire>
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
80101018:	e8 a0 39 00 00       	call   801049bd <release>
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
8010103b:	e8 7d 39 00 00       	call   801049bd <release>
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
80101058:	e8 f2 38 00 00       	call   8010494f <acquire>
8010105d:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101060:	8b 45 08             	mov    0x8(%ebp),%eax
80101063:	8b 40 04             	mov    0x4(%eax),%eax
80101066:	85 c0                	test   %eax,%eax
80101068:	7f 0d                	jg     80101077 <filedup+0x2d>
    panic("filedup");
8010106a:	83 ec 0c             	sub    $0xc,%esp
8010106d:	68 c8 a2 10 80       	push   $0x8010a2c8
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
8010108e:	e8 2a 39 00 00       	call   801049bd <release>
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
801010a9:	e8 a1 38 00 00       	call   8010494f <acquire>
801010ae:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010b1:	8b 45 08             	mov    0x8(%ebp),%eax
801010b4:	8b 40 04             	mov    0x4(%eax),%eax
801010b7:	85 c0                	test   %eax,%eax
801010b9:	7f 0d                	jg     801010c8 <fileclose+0x2d>
    panic("fileclose");
801010bb:	83 ec 0c             	sub    $0xc,%esp
801010be:	68 d0 a2 10 80       	push   $0x8010a2d0
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
801010e9:	e8 cf 38 00 00       	call   801049bd <release>
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
80101137:	e8 81 38 00 00       	call   801049bd <release>
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
80101286:	68 da a2 10 80       	push   $0x8010a2da
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
80101389:	68 e3 a2 10 80       	push   $0x8010a2e3
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
801013bf:	68 f3 a2 10 80       	push   $0x8010a2f3
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
801013f7:	e8 88 38 00 00       	call   80104c84 <memmove>
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
8010143d:	e8 83 37 00 00       	call   80104bc5 <memset>
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
8010159c:	68 00 a3 10 80       	push   $0x8010a300
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
80101627:	68 16 a3 10 80       	push   $0x8010a316
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
8010168b:	68 29 a3 10 80       	push   $0x8010a329
80101690:	68 60 24 19 80       	push   $0x80192460
80101695:	e8 93 32 00 00       	call   8010492d <initlock>
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
801016c1:	68 30 a3 10 80       	push   $0x8010a330
801016c6:	50                   	push   %eax
801016c7:	e8 04 31 00 00       	call   801047d0 <initsleeplock>
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
80101720:	68 38 a3 10 80       	push   $0x8010a338
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
80101799:	e8 27 34 00 00       	call   80104bc5 <memset>
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
80101801:	68 8b a3 10 80       	push   $0x8010a38b
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
801018a7:	e8 d8 33 00 00       	call   80104c84 <memmove>
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
801018dc:	e8 6e 30 00 00       	call   8010494f <acquire>
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
8010192a:	e8 8e 30 00 00       	call   801049bd <release>
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
80101966:	68 9d a3 10 80       	push   $0x8010a39d
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
801019a3:	e8 15 30 00 00       	call   801049bd <release>
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
801019be:	e8 8c 2f 00 00       	call   8010494f <acquire>
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
801019dd:	e8 db 2f 00 00       	call   801049bd <release>
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
80101a03:	68 ad a3 10 80       	push   $0x8010a3ad
80101a08:	e8 9c eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a10:	83 c0 0c             	add    $0xc,%eax
80101a13:	83 ec 0c             	sub    $0xc,%esp
80101a16:	50                   	push   %eax
80101a17:	e8 f0 2d 00 00       	call   8010480c <acquiresleep>
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
80101ac1:	e8 be 31 00 00       	call   80104c84 <memmove>
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
80101af0:	68 b3 a3 10 80       	push   $0x8010a3b3
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
80101b13:	e8 a6 2d 00 00       	call   801048be <holdingsleep>
80101b18:	83 c4 10             	add    $0x10,%esp
80101b1b:	85 c0                	test   %eax,%eax
80101b1d:	74 0a                	je     80101b29 <iunlock+0x2c>
80101b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b22:	8b 40 08             	mov    0x8(%eax),%eax
80101b25:	85 c0                	test   %eax,%eax
80101b27:	7f 0d                	jg     80101b36 <iunlock+0x39>
    panic("iunlock");
80101b29:	83 ec 0c             	sub    $0xc,%esp
80101b2c:	68 c2 a3 10 80       	push   $0x8010a3c2
80101b31:	e8 73 ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b36:	8b 45 08             	mov    0x8(%ebp),%eax
80101b39:	83 c0 0c             	add    $0xc,%eax
80101b3c:	83 ec 0c             	sub    $0xc,%esp
80101b3f:	50                   	push   %eax
80101b40:	e8 2b 2d 00 00       	call   80104870 <releasesleep>
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
80101b5b:	e8 ac 2c 00 00       	call   8010480c <acquiresleep>
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
80101b81:	e8 c9 2d 00 00       	call   8010494f <acquire>
80101b86:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b89:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8c:	8b 40 08             	mov    0x8(%eax),%eax
80101b8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b92:	83 ec 0c             	sub    $0xc,%esp
80101b95:	68 60 24 19 80       	push   $0x80192460
80101b9a:	e8 1e 2e 00 00       	call   801049bd <release>
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
80101be1:	e8 8a 2c 00 00       	call   80104870 <releasesleep>
80101be6:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101be9:	83 ec 0c             	sub    $0xc,%esp
80101bec:	68 60 24 19 80       	push   $0x80192460
80101bf1:	e8 59 2d 00 00       	call   8010494f <acquire>
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
80101c10:	e8 a8 2d 00 00       	call   801049bd <release>
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
80101d54:	68 ca a3 10 80       	push   $0x8010a3ca
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
80101ff2:	e8 8d 2c 00 00       	call   80104c84 <memmove>
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
80102142:	e8 3d 2b 00 00       	call   80104c84 <memmove>
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
801021c2:	e8 53 2b 00 00       	call   80104d1a <strncmp>
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
801021e2:	68 dd a3 10 80       	push   $0x8010a3dd
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
80102211:	68 ef a3 10 80       	push   $0x8010a3ef
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
801022e6:	68 fe a3 10 80       	push   $0x8010a3fe
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
80102321:	e8 4a 2a 00 00       	call   80104d70 <strncpy>
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
8010234d:	68 0b a4 10 80       	push   $0x8010a40b
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
801023bf:	e8 c0 28 00 00       	call   80104c84 <memmove>
801023c4:	83 c4 10             	add    $0x10,%esp
801023c7:	eb 26                	jmp    801023ef <skipelem+0x91>
  else {
    memmove(name, s, len);
801023c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023cc:	83 ec 04             	sub    $0x4,%esp
801023cf:	50                   	push   %eax
801023d0:	ff 75 f4             	push   -0xc(%ebp)
801023d3:	ff 75 0c             	push   0xc(%ebp)
801023d6:	e8 a9 28 00 00       	call   80104c84 <memmove>
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
801025cd:	68 14 a4 10 80       	push   $0x8010a414
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
80102674:	68 46 a4 10 80       	push   $0x8010a446
80102679:	68 c0 40 19 80       	push   $0x801940c0
8010267e:	e8 aa 22 00 00       	call   8010492d <initlock>
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
80102733:	68 4b a4 10 80       	push   $0x8010a44b
80102738:	e8 6c de ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010273d:	83 ec 04             	sub    $0x4,%esp
80102740:	68 00 10 00 00       	push   $0x1000
80102745:	6a 01                	push   $0x1
80102747:	ff 75 08             	push   0x8(%ebp)
8010274a:	e8 76 24 00 00       	call   80104bc5 <memset>
8010274f:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102752:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102757:	85 c0                	test   %eax,%eax
80102759:	74 10                	je     8010276b <kfree+0x65>
    acquire(&kmem.lock);
8010275b:	83 ec 0c             	sub    $0xc,%esp
8010275e:	68 c0 40 19 80       	push   $0x801940c0
80102763:	e8 e7 21 00 00       	call   8010494f <acquire>
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
80102795:	e8 23 22 00 00       	call   801049bd <release>
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
801027b7:	e8 93 21 00 00       	call   8010494f <acquire>
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
801027e8:	e8 d0 21 00 00       	call   801049bd <release>
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
80102d12:	e8 15 1f 00 00       	call   80104c2c <memcmp>
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
80102e26:	68 51 a4 10 80       	push   $0x8010a451
80102e2b:	68 20 41 19 80       	push   $0x80194120
80102e30:	e8 f8 1a 00 00       	call   8010492d <initlock>
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
80102edb:	e8 a4 1d 00 00       	call   80104c84 <memmove>
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
8010304a:	e8 00 19 00 00       	call   8010494f <acquire>
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
80103068:	e8 c7 14 00 00       	call   80104534 <sleep>
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
8010309d:	e8 92 14 00 00       	call   80104534 <sleep>
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
801030bc:	e8 fc 18 00 00       	call   801049bd <release>
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
801030dd:	e8 6d 18 00 00       	call   8010494f <acquire>
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
801030fe:	68 55 a4 10 80       	push   $0x8010a455
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
8010312c:	e8 ea 14 00 00       	call   8010461b <wakeup>
80103131:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103134:	83 ec 0c             	sub    $0xc,%esp
80103137:	68 20 41 19 80       	push   $0x80194120
8010313c:	e8 7c 18 00 00       	call   801049bd <release>
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
80103157:	e8 f3 17 00 00       	call   8010494f <acquire>
8010315c:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010315f:	c7 05 60 41 19 80 00 	movl   $0x0,0x80194160
80103166:	00 00 00 
    wakeup(&log);
80103169:	83 ec 0c             	sub    $0xc,%esp
8010316c:	68 20 41 19 80       	push   $0x80194120
80103171:	e8 a5 14 00 00       	call   8010461b <wakeup>
80103176:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103179:	83 ec 0c             	sub    $0xc,%esp
8010317c:	68 20 41 19 80       	push   $0x80194120
80103181:	e8 37 18 00 00       	call   801049bd <release>
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
801031fd:	e8 82 1a 00 00       	call   80104c84 <memmove>
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
8010329a:	68 64 a4 10 80       	push   $0x8010a464
8010329f:	e8 05 d3 ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
801032a4:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801032a9:	85 c0                	test   %eax,%eax
801032ab:	7f 0d                	jg     801032ba <log_write+0x45>
    panic("log_write outside of trans");
801032ad:	83 ec 0c             	sub    $0xc,%esp
801032b0:	68 7a a4 10 80       	push   $0x8010a47a
801032b5:	e8 ef d2 ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
801032ba:	83 ec 0c             	sub    $0xc,%esp
801032bd:	68 20 41 19 80       	push   $0x80194120
801032c2:	e8 88 16 00 00       	call   8010494f <acquire>
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
80103340:	e8 78 16 00 00       	call   801049bd <release>
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
80103376:	e8 6a 4c 00 00       	call   80107fe5 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010337b:	83 ec 08             	sub    $0x8,%esp
8010337e:	68 00 00 40 80       	push   $0x80400000
80103383:	68 00 90 19 80       	push   $0x80199000
80103388:	e8 de f2 ff ff       	call   8010266b <kinit1>
8010338d:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103390:	e8 6a 42 00 00       	call   801075ff <kvmalloc>
  mpinit_uefi();
80103395:	e8 11 4a 00 00       	call   80107dab <mpinit_uefi>
  lapicinit();     // interrupt controller
8010339a:	e8 3c f6 ff ff       	call   801029db <lapicinit>
  seginit();       // segment descriptors
8010339f:	e8 f3 3c 00 00       	call   80107097 <seginit>
  picinit();    // disable pic
801033a4:	e8 9d 01 00 00       	call   80103546 <picinit>
  ioapicinit();    // another interrupt controller
801033a9:	e8 d8 f1 ff ff       	call   80102586 <ioapicinit>
  consoleinit();   // console hardware
801033ae:	e8 4c d7 ff ff       	call   80100aff <consoleinit>
  uartinit();      // serial port
801033b3:	e8 78 30 00 00       	call   80106430 <uartinit>
  pinit();         // process table
801033b8:	e8 c2 05 00 00       	call   8010397f <pinit>
  tvinit();        // trap vectors
801033bd:	e8 3f 2c 00 00       	call   80106001 <tvinit>
  binit();         // buffer cache
801033c2:	e8 9f cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033c7:	e8 f3 db ff ff       	call   80100fbf <fileinit>
  ideinit();       // disk 
801033cc:	e8 55 6d 00 00       	call   8010a126 <ideinit>
  startothers();   // start other processors
801033d1:	e8 8a 00 00 00       	call   80103460 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033d6:	83 ec 08             	sub    $0x8,%esp
801033d9:	68 00 00 00 a0       	push   $0xa0000000
801033de:	68 00 00 40 80       	push   $0x80400000
801033e3:	e8 bc f2 ff ff       	call   801026a4 <kinit2>
801033e8:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033eb:	e8 4e 4e 00 00       	call   8010823e <pci_init>
  arp_scan();
801033f0:	e8 85 5b 00 00       	call   80108f7a <arp_scan>
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
80103405:	e8 0d 42 00 00       	call   80107617 <switchkvm>
  seginit();
8010340a:	e8 88 3c 00 00       	call   80107097 <seginit>
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
80103431:	68 95 a4 10 80       	push   $0x8010a495
80103436:	e8 b9 cf ff ff       	call   801003f4 <cprintf>
8010343b:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
8010343e:	e8 34 2d 00 00       	call   80106177 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103443:	e8 70 05 00 00       	call   801039b8 <mycpu>
80103448:	05 a0 00 00 00       	add    $0xa0,%eax
8010344d:	83 ec 08             	sub    $0x8,%esp
80103450:	6a 01                	push   $0x1
80103452:	50                   	push   %eax
80103453:	e8 f3 fe ff ff       	call   8010334b <xchg>
80103458:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010345b:	e8 e3 0e 00 00       	call   80104343 <scheduler>

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
8010347e:	e8 01 18 00 00       	call   80104c84 <memmove>
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
80103607:	68 a9 a4 10 80       	push   $0x8010a4a9
8010360c:	50                   	push   %eax
8010360d:	e8 1b 13 00 00       	call   8010492d <initlock>
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
801036cc:	e8 7e 12 00 00       	call   8010494f <acquire>
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
801036f3:	e8 23 0f 00 00       	call   8010461b <wakeup>
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
80103716:	e8 00 0f 00 00       	call   8010461b <wakeup>
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
8010373f:	e8 79 12 00 00       	call   801049bd <release>
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
8010375e:	e8 5a 12 00 00       	call   801049bd <release>
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
80103778:	e8 d2 11 00 00       	call   8010494f <acquire>
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
801037ac:	e8 0c 12 00 00       	call   801049bd <release>
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
801037ca:	e8 4c 0e 00 00       	call   8010461b <wakeup>
801037cf:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037d2:	8b 45 08             	mov    0x8(%ebp),%eax
801037d5:	8b 55 08             	mov    0x8(%ebp),%edx
801037d8:	81 c2 38 02 00 00    	add    $0x238,%edx
801037de:	83 ec 08             	sub    $0x8,%esp
801037e1:	50                   	push   %eax
801037e2:	52                   	push   %edx
801037e3:	e8 4c 0d 00 00       	call   80104534 <sleep>
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
8010384d:	e8 c9 0d 00 00       	call   8010461b <wakeup>
80103852:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103855:	8b 45 08             	mov    0x8(%ebp),%eax
80103858:	83 ec 0c             	sub    $0xc,%esp
8010385b:	50                   	push   %eax
8010385c:	e8 5c 11 00 00       	call   801049bd <release>
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
80103879:	e8 d1 10 00 00       	call   8010494f <acquire>
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
80103896:	e8 22 11 00 00       	call   801049bd <release>
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
801038b9:	e8 76 0c 00 00       	call   80104534 <sleep>
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
8010394c:	e8 ca 0c 00 00       	call   8010461b <wakeup>
80103951:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103954:	8b 45 08             	mov    0x8(%ebp),%eax
80103957:	83 ec 0c             	sub    $0xc,%esp
8010395a:	50                   	push   %eax
8010395b:	e8 5d 10 00 00       	call   801049bd <release>
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
80103988:	68 b0 a4 10 80       	push   $0x8010a4b0
8010398d:	68 00 42 19 80       	push   $0x80194200
80103992:	e8 96 0f 00 00       	call   8010492d <initlock>
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
801039cf:	68 b8 a4 10 80       	push   $0x8010a4b8
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
80103a24:	68 de a4 10 80       	push   $0x8010a4de
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
80103a36:	e8 7f 10 00 00       	call   80104aba <pushcli>
  c = mycpu();
80103a3b:	e8 78 ff ff ff       	call   801039b8 <mycpu>
80103a40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a46:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103a4f:	e8 b3 10 00 00       	call   80104b07 <popcli>
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
80103a67:	e8 e3 0e 00 00       	call   8010494f <acquire>
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
80103a97:	e8 21 0f 00 00       	call   801049bd <release>
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
80103ad0:	e8 e8 0e 00 00       	call   801049bd <release>
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
80103b1d:	ba bb 5f 10 80       	mov    $0x80105fbb,%edx
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
80103b42:	e8 7e 10 00 00       	call   80104bc5 <memset>
80103b47:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b4d:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b50:	ba ee 44 10 80       	mov    $0x801044ee,%edx
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
80103b73:	e8 9b 39 00 00       	call   80107513 <setupkvm>
80103b78:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b7b:	89 42 04             	mov    %eax,0x4(%edx)
80103b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b81:	8b 40 04             	mov    0x4(%eax),%eax
80103b84:	85 c0                	test   %eax,%eax
80103b86:	75 0d                	jne    80103b95 <userinit+0x38>
    panic("userinit: out of memory?");
80103b88:	83 ec 0c             	sub    $0xc,%esp
80103b8b:	68 ee a4 10 80       	push   $0x8010a4ee
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
80103baa:	e8 20 3c 00 00       	call   801077cf <inituvm>
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
80103bc9:	e8 f7 0f 00 00       	call   80104bc5 <memset>
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
80103c43:	68 07 a5 10 80       	push   $0x8010a507
80103c48:	50                   	push   %eax
80103c49:	e8 7a 11 00 00       	call   80104dc8 <safestrcpy>
80103c4e:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103c51:	83 ec 0c             	sub    $0xc,%esp
80103c54:	68 10 a5 10 80       	push   $0x8010a510
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
80103c6f:	e8 db 0c 00 00       	call   8010494f <acquire>
80103c74:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c7a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103c81:	83 ec 0c             	sub    $0xc,%esp
80103c84:	68 00 42 19 80       	push   $0x80194200
80103c89:	e8 2f 0d 00 00       	call   801049bd <release>
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
80103cc6:	e8 41 3c 00 00       	call   8010790c <allocuvm>
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
80103cfa:	e8 12 3d 00 00       	call   80107a11 <deallocuvm>
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
80103d20:	e8 0b 39 00 00       	call   80107630 <switchuvm>
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
80103d68:	e8 42 3e 00 00       	call   80107baf <copyuvm>
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
80103e62:	e8 61 0f 00 00       	call   80104dc8 <safestrcpy>
80103e67:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103e6a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e6d:	8b 40 10             	mov    0x10(%eax),%eax
80103e70:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103e73:	83 ec 0c             	sub    $0xc,%esp
80103e76:	68 00 42 19 80       	push   $0x80194200
80103e7b:	e8 cf 0a 00 00       	call   8010494f <acquire>
80103e80:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80103e83:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e86:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103e8d:	83 ec 0c             	sub    $0xc,%esp
80103e90:	68 00 42 19 80       	push   $0x80194200
80103e95:	e8 23 0b 00 00       	call   801049bd <release>
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
80103ec3:	68 12 a5 10 80       	push   $0x8010a512
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
80103f49:	e8 01 0a 00 00       	call   8010494f <acquire>
80103f4e:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80103f51:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f54:	8b 40 14             	mov    0x14(%eax),%eax
80103f57:	83 ec 0c             	sub    $0xc,%esp
80103f5a:	50                   	push   %eax
80103f5b:	e8 7b 06 00 00       	call   801045db <wakeup1>
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
80103f97:	e8 3f 06 00 00       	call   801045db <wakeup1>
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
80103fb6:	e8 40 04 00 00       	call   801043fb <sched>
  panic("zombie exit");
80103fbb:	83 ec 0c             	sub    $0xc,%esp
80103fbe:	68 1f a5 10 80       	push   $0x8010a51f
80103fc3:	e8 e1 c5 ff ff       	call   801005a9 <panic>

80103fc8 <exit2>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit2(int status)
{
80103fc8:	55                   	push   %ebp
80103fc9:	89 e5                	mov    %esp,%ebp
80103fcb:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80103fce:	e8 5d fa ff ff       	call   80103a30 <myproc>
80103fd3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80103fd6:	a1 34 62 19 80       	mov    0x80196234,%eax
80103fdb:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103fde:	75 0d                	jne    80103fed <exit2+0x25>
    panic("init exiting");
80103fe0:	83 ec 0c             	sub    $0xc,%esp
80103fe3:	68 12 a5 10 80       	push   $0x8010a512
80103fe8:	e8 bc c5 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80103fed:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80103ff4:	eb 3f                	jmp    80104035 <exit2+0x6d>
    if(curproc->ofile[fd]){
80103ff6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ff9:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103ffc:	83 c2 08             	add    $0x8,%edx
80103fff:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104003:	85 c0                	test   %eax,%eax
80104005:	74 2a                	je     80104031 <exit2+0x69>
      fileclose(curproc->ofile[fd]);
80104007:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010400a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010400d:	83 c2 08             	add    $0x8,%edx
80104010:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104014:	83 ec 0c             	sub    $0xc,%esp
80104017:	50                   	push   %eax
80104018:	e8 7e d0 ff ff       	call   8010109b <fileclose>
8010401d:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80104020:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104023:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104026:	83 c2 08             	add    $0x8,%edx
80104029:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104030:	00 
  for(fd = 0; fd < NOFILE; fd++){
80104031:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104035:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104039:	7e bb                	jle    80103ff6 <exit2+0x2e>
    }
  }

  begin_op();
8010403b:	e8 fc ef ff ff       	call   8010303c <begin_op>
  iput(curproc->cwd);
80104040:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104043:	8b 40 68             	mov    0x68(%eax),%eax
80104046:	83 ec 0c             	sub    $0xc,%esp
80104049:	50                   	push   %eax
8010404a:	e8 fc da ff ff       	call   80101b4b <iput>
8010404f:	83 c4 10             	add    $0x10,%esp
  end_op();
80104052:	e8 71 f0 ff ff       	call   801030c8 <end_op>
  curproc->cwd = 0;
80104057:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010405a:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104061:	83 ec 0c             	sub    $0xc,%esp
80104064:	68 00 42 19 80       	push   $0x80194200
80104069:	e8 e1 08 00 00       	call   8010494f <acquire>
8010406e:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104071:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104074:	8b 40 14             	mov    0x14(%eax),%eax
80104077:	83 ec 0c             	sub    $0xc,%esp
8010407a:	50                   	push   %eax
8010407b:	e8 5b 05 00 00       	call   801045db <wakeup1>
80104080:	83 c4 10             	add    $0x10,%esp

  // Copy status to parent xstatus
  curproc->parent->xstate = status;
80104083:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104086:	8b 40 14             	mov    0x14(%eax),%eax
80104089:	8b 55 08             	mov    0x8(%ebp),%edx
8010408c:	89 50 7c             	mov    %edx,0x7c(%eax)

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010408f:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104096:	eb 37                	jmp    801040cf <exit2+0x107>
    if(p->parent == curproc){
80104098:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010409b:	8b 40 14             	mov    0x14(%eax),%eax
8010409e:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801040a1:	75 28                	jne    801040cb <exit2+0x103>
      p->parent = initproc;
801040a3:	8b 15 34 62 19 80    	mov    0x80196234,%edx
801040a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040ac:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801040af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040b2:	8b 40 0c             	mov    0xc(%eax),%eax
801040b5:	83 f8 05             	cmp    $0x5,%eax
801040b8:	75 11                	jne    801040cb <exit2+0x103>
        wakeup1(initproc);
801040ba:	a1 34 62 19 80       	mov    0x80196234,%eax
801040bf:	83 ec 0c             	sub    $0xc,%esp
801040c2:	50                   	push   %eax
801040c3:	e8 13 05 00 00       	call   801045db <wakeup1>
801040c8:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801040cb:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801040cf:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
801040d6:	72 c0                	jb     80104098 <exit2+0xd0>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
801040d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040db:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801040e2:	e8 14 03 00 00       	call   801043fb <sched>
  panic("zombie exit");
801040e7:	83 ec 0c             	sub    $0xc,%esp
801040ea:	68 1f a5 10 80       	push   $0x8010a51f
801040ef:	e8 b5 c4 ff ff       	call   801005a9 <panic>

801040f4 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801040f4:	55                   	push   %ebp
801040f5:	89 e5                	mov    %esp,%ebp
801040f7:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801040fa:	e8 31 f9 ff ff       	call   80103a30 <myproc>
801040ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104102:	83 ec 0c             	sub    $0xc,%esp
80104105:	68 00 42 19 80       	push   $0x80194200
8010410a:	e8 40 08 00 00       	call   8010494f <acquire>
8010410f:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104112:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104119:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104120:	e9 a1 00 00 00       	jmp    801041c6 <wait+0xd2>
      if(p->parent != curproc)
80104125:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104128:	8b 40 14             	mov    0x14(%eax),%eax
8010412b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010412e:	0f 85 8d 00 00 00    	jne    801041c1 <wait+0xcd>
        continue;
      havekids = 1;
80104134:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010413b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010413e:	8b 40 0c             	mov    0xc(%eax),%eax
80104141:	83 f8 05             	cmp    $0x5,%eax
80104144:	75 7c                	jne    801041c2 <wait+0xce>
        // Found one.
        pid = p->pid;
80104146:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104149:	8b 40 10             	mov    0x10(%eax),%eax
8010414c:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
8010414f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104152:	8b 40 08             	mov    0x8(%eax),%eax
80104155:	83 ec 0c             	sub    $0xc,%esp
80104158:	50                   	push   %eax
80104159:	e8 a8 e5 ff ff       	call   80102706 <kfree>
8010415e:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104161:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104164:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010416b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010416e:	8b 40 04             	mov    0x4(%eax),%eax
80104171:	83 ec 0c             	sub    $0xc,%esp
80104174:	50                   	push   %eax
80104175:	e8 5b 39 00 00       	call   80107ad5 <freevm>
8010417a:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
8010417d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104180:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104187:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010418a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104191:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104194:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104198:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010419b:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
801041a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041a5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
801041ac:	83 ec 0c             	sub    $0xc,%esp
801041af:	68 00 42 19 80       	push   $0x80194200
801041b4:	e8 04 08 00 00       	call   801049bd <release>
801041b9:	83 c4 10             	add    $0x10,%esp
        return pid;
801041bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801041bf:	eb 51                	jmp    80104212 <wait+0x11e>
        continue;
801041c1:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801041c2:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801041c6:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
801041cd:	0f 82 52 ff ff ff    	jb     80104125 <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801041d3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801041d7:	74 0a                	je     801041e3 <wait+0xef>
801041d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041dc:	8b 40 24             	mov    0x24(%eax),%eax
801041df:	85 c0                	test   %eax,%eax
801041e1:	74 17                	je     801041fa <wait+0x106>
      release(&ptable.lock);
801041e3:	83 ec 0c             	sub    $0xc,%esp
801041e6:	68 00 42 19 80       	push   $0x80194200
801041eb:	e8 cd 07 00 00       	call   801049bd <release>
801041f0:	83 c4 10             	add    $0x10,%esp
      return -1;
801041f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041f8:	eb 18                	jmp    80104212 <wait+0x11e>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801041fa:	83 ec 08             	sub    $0x8,%esp
801041fd:	68 00 42 19 80       	push   $0x80194200
80104202:	ff 75 ec             	push   -0x14(%ebp)
80104205:	e8 2a 03 00 00       	call   80104534 <sleep>
8010420a:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
8010420d:	e9 00 ff ff ff       	jmp    80104112 <wait+0x1e>
  }
}
80104212:	c9                   	leave  
80104213:	c3                   	ret    

80104214 <wait2>:
// UNIX style custom wait
// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait2(int *status)
{
80104214:	55                   	push   %ebp
80104215:	89 e5                	mov    %esp,%ebp
80104217:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
8010421a:	e8 11 f8 ff ff       	call   80103a30 <myproc>
8010421f:	89 45 ec             	mov    %eax,-0x14(%ebp)

  acquire(&ptable.lock);
80104222:	83 ec 0c             	sub    $0xc,%esp
80104225:	68 00 42 19 80       	push   $0x80194200
8010422a:	e8 20 07 00 00       	call   8010494f <acquire>
8010422f:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104232:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104239:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104240:	e9 b0 00 00 00       	jmp    801042f5 <wait2+0xe1>
      if(p->parent != curproc)
80104245:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104248:	8b 40 14             	mov    0x14(%eax),%eax
8010424b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010424e:	0f 85 9c 00 00 00    	jne    801042f0 <wait2+0xdc>
        continue;
      havekids = 1;
80104254:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010425b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010425e:	8b 40 0c             	mov    0xc(%eax),%eax
80104261:	83 f8 05             	cmp    $0x5,%eax
80104264:	0f 85 87 00 00 00    	jne    801042f1 <wait2+0xdd>
        // Found one.
        pid = p->pid;
8010426a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010426d:	8b 40 10             	mov    0x10(%eax),%eax
80104270:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104273:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104276:	8b 40 08             	mov    0x8(%eax),%eax
80104279:	83 ec 0c             	sub    $0xc,%esp
8010427c:	50                   	push   %eax
8010427d:	e8 84 e4 ff ff       	call   80102706 <kfree>
80104282:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104285:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104288:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010428f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104292:	8b 40 04             	mov    0x4(%eax),%eax
80104295:	83 ec 0c             	sub    $0xc,%esp
80104298:	50                   	push   %eax
80104299:	e8 37 38 00 00       	call   80107ad5 <freevm>
8010429e:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
801042a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042a4:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801042ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ae:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801042b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042b8:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801042bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042bf:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
801042c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042c9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
	
	// Copy xstate to status
	*status = curproc->xstate;
801042d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801042d3:	8b 50 7c             	mov    0x7c(%eax),%edx
801042d6:	8b 45 08             	mov    0x8(%ebp),%eax
801042d9:	89 10                	mov    %edx,(%eax)

        release(&ptable.lock);
801042db:	83 ec 0c             	sub    $0xc,%esp
801042de:	68 00 42 19 80       	push   $0x80194200
801042e3:	e8 d5 06 00 00       	call   801049bd <release>
801042e8:	83 c4 10             	add    $0x10,%esp
        return pid;
801042eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801042ee:	eb 51                	jmp    80104341 <wait2+0x12d>
        continue;
801042f0:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801042f1:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801042f5:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
801042fc:	0f 82 43 ff ff ff    	jb     80104245 <wait2+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104302:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104306:	74 0a                	je     80104312 <wait2+0xfe>
80104308:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010430b:	8b 40 24             	mov    0x24(%eax),%eax
8010430e:	85 c0                	test   %eax,%eax
80104310:	74 17                	je     80104329 <wait2+0x115>
      release(&ptable.lock);
80104312:	83 ec 0c             	sub    $0xc,%esp
80104315:	68 00 42 19 80       	push   $0x80194200
8010431a:	e8 9e 06 00 00       	call   801049bd <release>
8010431f:	83 c4 10             	add    $0x10,%esp
      return -1;
80104322:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104327:	eb 18                	jmp    80104341 <wait2+0x12d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104329:	83 ec 08             	sub    $0x8,%esp
8010432c:	68 00 42 19 80       	push   $0x80194200
80104331:	ff 75 ec             	push   -0x14(%ebp)
80104334:	e8 fb 01 00 00       	call   80104534 <sleep>
80104339:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
8010433c:	e9 f1 fe ff ff       	jmp    80104232 <wait2+0x1e>
  }
}
80104341:	c9                   	leave  
80104342:	c3                   	ret    

80104343 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104343:	55                   	push   %ebp
80104344:	89 e5                	mov    %esp,%ebp
80104346:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104349:	e8 6a f6 ff ff       	call   801039b8 <mycpu>
8010434e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104351:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104354:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010435b:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
8010435e:	e8 15 f6 ff ff       	call   80103978 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104363:	83 ec 0c             	sub    $0xc,%esp
80104366:	68 00 42 19 80       	push   $0x80194200
8010436b:	e8 df 05 00 00       	call   8010494f <acquire>
80104370:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104373:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
8010437a:	eb 61                	jmp    801043dd <scheduler+0x9a>
      if(p->state != RUNNABLE)
8010437c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010437f:	8b 40 0c             	mov    0xc(%eax),%eax
80104382:	83 f8 03             	cmp    $0x3,%eax
80104385:	75 51                	jne    801043d8 <scheduler+0x95>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104387:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010438a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010438d:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104393:	83 ec 0c             	sub    $0xc,%esp
80104396:	ff 75 f4             	push   -0xc(%ebp)
80104399:	e8 92 32 00 00       	call   80107630 <switchuvm>
8010439e:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
801043a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043a4:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
801043ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ae:	8b 40 1c             	mov    0x1c(%eax),%eax
801043b1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043b4:	83 c2 04             	add    $0x4,%edx
801043b7:	83 ec 08             	sub    $0x8,%esp
801043ba:	50                   	push   %eax
801043bb:	52                   	push   %edx
801043bc:	e8 79 0a 00 00       	call   80104e3a <swtch>
801043c1:	83 c4 10             	add    $0x10,%esp
      switchkvm();
801043c4:	e8 4e 32 00 00       	call   80107617 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
801043c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043cc:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801043d3:	00 00 00 
801043d6:	eb 01                	jmp    801043d9 <scheduler+0x96>
        continue;
801043d8:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801043d9:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801043dd:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
801043e4:	72 96                	jb     8010437c <scheduler+0x39>
    }
    release(&ptable.lock);
801043e6:	83 ec 0c             	sub    $0xc,%esp
801043e9:	68 00 42 19 80       	push   $0x80194200
801043ee:	e8 ca 05 00 00       	call   801049bd <release>
801043f3:	83 c4 10             	add    $0x10,%esp
    sti();
801043f6:	e9 63 ff ff ff       	jmp    8010435e <scheduler+0x1b>

801043fb <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
801043fb:	55                   	push   %ebp
801043fc:	89 e5                	mov    %esp,%ebp
801043fe:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104401:	e8 2a f6 ff ff       	call   80103a30 <myproc>
80104406:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104409:	83 ec 0c             	sub    $0xc,%esp
8010440c:	68 00 42 19 80       	push   $0x80194200
80104411:	e8 74 06 00 00       	call   80104a8a <holding>
80104416:	83 c4 10             	add    $0x10,%esp
80104419:	85 c0                	test   %eax,%eax
8010441b:	75 0d                	jne    8010442a <sched+0x2f>
    panic("sched ptable.lock");
8010441d:	83 ec 0c             	sub    $0xc,%esp
80104420:	68 2b a5 10 80       	push   $0x8010a52b
80104425:	e8 7f c1 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
8010442a:	e8 89 f5 ff ff       	call   801039b8 <mycpu>
8010442f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104435:	83 f8 01             	cmp    $0x1,%eax
80104438:	74 0d                	je     80104447 <sched+0x4c>
    panic("sched locks");
8010443a:	83 ec 0c             	sub    $0xc,%esp
8010443d:	68 3d a5 10 80       	push   $0x8010a53d
80104442:	e8 62 c1 ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
80104447:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010444a:	8b 40 0c             	mov    0xc(%eax),%eax
8010444d:	83 f8 04             	cmp    $0x4,%eax
80104450:	75 0d                	jne    8010445f <sched+0x64>
    panic("sched running");
80104452:	83 ec 0c             	sub    $0xc,%esp
80104455:	68 49 a5 10 80       	push   $0x8010a549
8010445a:	e8 4a c1 ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
8010445f:	e8 04 f5 ff ff       	call   80103968 <readeflags>
80104464:	25 00 02 00 00       	and    $0x200,%eax
80104469:	85 c0                	test   %eax,%eax
8010446b:	74 0d                	je     8010447a <sched+0x7f>
    panic("sched interruptible");
8010446d:	83 ec 0c             	sub    $0xc,%esp
80104470:	68 57 a5 10 80       	push   $0x8010a557
80104475:	e8 2f c1 ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
8010447a:	e8 39 f5 ff ff       	call   801039b8 <mycpu>
8010447f:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104485:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104488:	e8 2b f5 ff ff       	call   801039b8 <mycpu>
8010448d:	8b 40 04             	mov    0x4(%eax),%eax
80104490:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104493:	83 c2 1c             	add    $0x1c,%edx
80104496:	83 ec 08             	sub    $0x8,%esp
80104499:	50                   	push   %eax
8010449a:	52                   	push   %edx
8010449b:	e8 9a 09 00 00       	call   80104e3a <swtch>
801044a0:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
801044a3:	e8 10 f5 ff ff       	call   801039b8 <mycpu>
801044a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801044ab:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
801044b1:	90                   	nop
801044b2:	c9                   	leave  
801044b3:	c3                   	ret    

801044b4 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
801044b4:	55                   	push   %ebp
801044b5:	89 e5                	mov    %esp,%ebp
801044b7:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801044ba:	83 ec 0c             	sub    $0xc,%esp
801044bd:	68 00 42 19 80       	push   $0x80194200
801044c2:	e8 88 04 00 00       	call   8010494f <acquire>
801044c7:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
801044ca:	e8 61 f5 ff ff       	call   80103a30 <myproc>
801044cf:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801044d6:	e8 20 ff ff ff       	call   801043fb <sched>
  release(&ptable.lock);
801044db:	83 ec 0c             	sub    $0xc,%esp
801044de:	68 00 42 19 80       	push   $0x80194200
801044e3:	e8 d5 04 00 00       	call   801049bd <release>
801044e8:	83 c4 10             	add    $0x10,%esp
}
801044eb:	90                   	nop
801044ec:	c9                   	leave  
801044ed:	c3                   	ret    

801044ee <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801044ee:	55                   	push   %ebp
801044ef:	89 e5                	mov    %esp,%ebp
801044f1:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801044f4:	83 ec 0c             	sub    $0xc,%esp
801044f7:	68 00 42 19 80       	push   $0x80194200
801044fc:	e8 bc 04 00 00       	call   801049bd <release>
80104501:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104504:	a1 04 f0 10 80       	mov    0x8010f004,%eax
80104509:	85 c0                	test   %eax,%eax
8010450b:	74 24                	je     80104531 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
8010450d:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
80104514:	00 00 00 
    iinit(ROOTDEV);
80104517:	83 ec 0c             	sub    $0xc,%esp
8010451a:	6a 01                	push   $0x1
8010451c:	e8 57 d1 ff ff       	call   80101678 <iinit>
80104521:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104524:	83 ec 0c             	sub    $0xc,%esp
80104527:	6a 01                	push   $0x1
80104529:	e8 ef e8 ff ff       	call   80102e1d <initlog>
8010452e:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104531:	90                   	nop
80104532:	c9                   	leave  
80104533:	c3                   	ret    

80104534 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104534:	55                   	push   %ebp
80104535:	89 e5                	mov    %esp,%ebp
80104537:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
8010453a:	e8 f1 f4 ff ff       	call   80103a30 <myproc>
8010453f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104542:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104546:	75 0d                	jne    80104555 <sleep+0x21>
    panic("sleep");
80104548:	83 ec 0c             	sub    $0xc,%esp
8010454b:	68 6b a5 10 80       	push   $0x8010a56b
80104550:	e8 54 c0 ff ff       	call   801005a9 <panic>

  if(lk == 0)
80104555:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104559:	75 0d                	jne    80104568 <sleep+0x34>
    panic("sleep without lk");
8010455b:	83 ec 0c             	sub    $0xc,%esp
8010455e:	68 71 a5 10 80       	push   $0x8010a571
80104563:	e8 41 c0 ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104568:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
8010456f:	74 1e                	je     8010458f <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104571:	83 ec 0c             	sub    $0xc,%esp
80104574:	68 00 42 19 80       	push   $0x80194200
80104579:	e8 d1 03 00 00       	call   8010494f <acquire>
8010457e:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104581:	83 ec 0c             	sub    $0xc,%esp
80104584:	ff 75 0c             	push   0xc(%ebp)
80104587:	e8 31 04 00 00       	call   801049bd <release>
8010458c:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
8010458f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104592:	8b 55 08             	mov    0x8(%ebp),%edx
80104595:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104598:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010459b:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
801045a2:	e8 54 fe ff ff       	call   801043fb <sched>

  // Tidy up.
  p->chan = 0;
801045a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045aa:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
801045b1:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
801045b8:	74 1e                	je     801045d8 <sleep+0xa4>
    release(&ptable.lock);
801045ba:	83 ec 0c             	sub    $0xc,%esp
801045bd:	68 00 42 19 80       	push   $0x80194200
801045c2:	e8 f6 03 00 00       	call   801049bd <release>
801045c7:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
801045ca:	83 ec 0c             	sub    $0xc,%esp
801045cd:	ff 75 0c             	push   0xc(%ebp)
801045d0:	e8 7a 03 00 00       	call   8010494f <acquire>
801045d5:	83 c4 10             	add    $0x10,%esp
  }
}
801045d8:	90                   	nop
801045d9:	c9                   	leave  
801045da:	c3                   	ret    

801045db <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
801045db:	55                   	push   %ebp
801045dc:	89 e5                	mov    %esp,%ebp
801045de:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801045e1:	c7 45 fc 34 42 19 80 	movl   $0x80194234,-0x4(%ebp)
801045e8:	eb 24                	jmp    8010460e <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
801045ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
801045ed:	8b 40 0c             	mov    0xc(%eax),%eax
801045f0:	83 f8 02             	cmp    $0x2,%eax
801045f3:	75 15                	jne    8010460a <wakeup1+0x2f>
801045f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801045f8:	8b 40 20             	mov    0x20(%eax),%eax
801045fb:	39 45 08             	cmp    %eax,0x8(%ebp)
801045fe:	75 0a                	jne    8010460a <wakeup1+0x2f>
      p->state = RUNNABLE;
80104600:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104603:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010460a:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
8010460e:	81 7d fc 34 62 19 80 	cmpl   $0x80196234,-0x4(%ebp)
80104615:	72 d3                	jb     801045ea <wakeup1+0xf>
}
80104617:	90                   	nop
80104618:	90                   	nop
80104619:	c9                   	leave  
8010461a:	c3                   	ret    

8010461b <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
8010461b:	55                   	push   %ebp
8010461c:	89 e5                	mov    %esp,%ebp
8010461e:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104621:	83 ec 0c             	sub    $0xc,%esp
80104624:	68 00 42 19 80       	push   $0x80194200
80104629:	e8 21 03 00 00       	call   8010494f <acquire>
8010462e:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104631:	83 ec 0c             	sub    $0xc,%esp
80104634:	ff 75 08             	push   0x8(%ebp)
80104637:	e8 9f ff ff ff       	call   801045db <wakeup1>
8010463c:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
8010463f:	83 ec 0c             	sub    $0xc,%esp
80104642:	68 00 42 19 80       	push   $0x80194200
80104647:	e8 71 03 00 00       	call   801049bd <release>
8010464c:	83 c4 10             	add    $0x10,%esp
}
8010464f:	90                   	nop
80104650:	c9                   	leave  
80104651:	c3                   	ret    

80104652 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104652:	55                   	push   %ebp
80104653:	89 e5                	mov    %esp,%ebp
80104655:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104658:	83 ec 0c             	sub    $0xc,%esp
8010465b:	68 00 42 19 80       	push   $0x80194200
80104660:	e8 ea 02 00 00       	call   8010494f <acquire>
80104665:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104668:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
8010466f:	eb 45                	jmp    801046b6 <kill+0x64>
    if(p->pid == pid){
80104671:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104674:	8b 40 10             	mov    0x10(%eax),%eax
80104677:	39 45 08             	cmp    %eax,0x8(%ebp)
8010467a:	75 36                	jne    801046b2 <kill+0x60>
      p->killed = 1;
8010467c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010467f:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104686:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104689:	8b 40 0c             	mov    0xc(%eax),%eax
8010468c:	83 f8 02             	cmp    $0x2,%eax
8010468f:	75 0a                	jne    8010469b <kill+0x49>
        p->state = RUNNABLE;
80104691:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104694:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
8010469b:	83 ec 0c             	sub    $0xc,%esp
8010469e:	68 00 42 19 80       	push   $0x80194200
801046a3:	e8 15 03 00 00       	call   801049bd <release>
801046a8:	83 c4 10             	add    $0x10,%esp
      return 0;
801046ab:	b8 00 00 00 00       	mov    $0x0,%eax
801046b0:	eb 22                	jmp    801046d4 <kill+0x82>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801046b2:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801046b6:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
801046bd:	72 b2                	jb     80104671 <kill+0x1f>
    }
  }
  release(&ptable.lock);
801046bf:	83 ec 0c             	sub    $0xc,%esp
801046c2:	68 00 42 19 80       	push   $0x80194200
801046c7:	e8 f1 02 00 00       	call   801049bd <release>
801046cc:	83 c4 10             	add    $0x10,%esp
  return -1;
801046cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801046d4:	c9                   	leave  
801046d5:	c3                   	ret    

801046d6 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801046d6:	55                   	push   %ebp
801046d7:	89 e5                	mov    %esp,%ebp
801046d9:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801046dc:	c7 45 f0 34 42 19 80 	movl   $0x80194234,-0x10(%ebp)
801046e3:	e9 d7 00 00 00       	jmp    801047bf <procdump+0xe9>
    if(p->state == UNUSED)
801046e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046eb:	8b 40 0c             	mov    0xc(%eax),%eax
801046ee:	85 c0                	test   %eax,%eax
801046f0:	0f 84 c4 00 00 00    	je     801047ba <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801046f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046f9:	8b 40 0c             	mov    0xc(%eax),%eax
801046fc:	83 f8 05             	cmp    $0x5,%eax
801046ff:	77 23                	ja     80104724 <procdump+0x4e>
80104701:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104704:	8b 40 0c             	mov    0xc(%eax),%eax
80104707:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
8010470e:	85 c0                	test   %eax,%eax
80104710:	74 12                	je     80104724 <procdump+0x4e>
      state = states[p->state];
80104712:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104715:	8b 40 0c             	mov    0xc(%eax),%eax
80104718:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
8010471f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104722:	eb 07                	jmp    8010472b <procdump+0x55>
    else
      state = "???";
80104724:	c7 45 ec 82 a5 10 80 	movl   $0x8010a582,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
8010472b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010472e:	8d 50 6c             	lea    0x6c(%eax),%edx
80104731:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104734:	8b 40 10             	mov    0x10(%eax),%eax
80104737:	52                   	push   %edx
80104738:	ff 75 ec             	push   -0x14(%ebp)
8010473b:	50                   	push   %eax
8010473c:	68 86 a5 10 80       	push   $0x8010a586
80104741:	e8 ae bc ff ff       	call   801003f4 <cprintf>
80104746:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104749:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010474c:	8b 40 0c             	mov    0xc(%eax),%eax
8010474f:	83 f8 02             	cmp    $0x2,%eax
80104752:	75 54                	jne    801047a8 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104754:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104757:	8b 40 1c             	mov    0x1c(%eax),%eax
8010475a:	8b 40 0c             	mov    0xc(%eax),%eax
8010475d:	83 c0 08             	add    $0x8,%eax
80104760:	89 c2                	mov    %eax,%edx
80104762:	83 ec 08             	sub    $0x8,%esp
80104765:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104768:	50                   	push   %eax
80104769:	52                   	push   %edx
8010476a:	e8 a0 02 00 00       	call   80104a0f <getcallerpcs>
8010476f:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104772:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104779:	eb 1c                	jmp    80104797 <procdump+0xc1>
        cprintf(" %p", pc[i]);
8010477b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010477e:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104782:	83 ec 08             	sub    $0x8,%esp
80104785:	50                   	push   %eax
80104786:	68 8f a5 10 80       	push   $0x8010a58f
8010478b:	e8 64 bc ff ff       	call   801003f4 <cprintf>
80104790:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104793:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104797:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010479b:	7f 0b                	jg     801047a8 <procdump+0xd2>
8010479d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047a0:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801047a4:	85 c0                	test   %eax,%eax
801047a6:	75 d3                	jne    8010477b <procdump+0xa5>
    }
    cprintf("\n");
801047a8:	83 ec 0c             	sub    $0xc,%esp
801047ab:	68 93 a5 10 80       	push   $0x8010a593
801047b0:	e8 3f bc ff ff       	call   801003f4 <cprintf>
801047b5:	83 c4 10             	add    $0x10,%esp
801047b8:	eb 01                	jmp    801047bb <procdump+0xe5>
      continue;
801047ba:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047bb:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
801047bf:	81 7d f0 34 62 19 80 	cmpl   $0x80196234,-0x10(%ebp)
801047c6:	0f 82 1c ff ff ff    	jb     801046e8 <procdump+0x12>
  }
}
801047cc:	90                   	nop
801047cd:	90                   	nop
801047ce:	c9                   	leave  
801047cf:	c3                   	ret    

801047d0 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801047d0:	55                   	push   %ebp
801047d1:	89 e5                	mov    %esp,%ebp
801047d3:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
801047d6:	8b 45 08             	mov    0x8(%ebp),%eax
801047d9:	83 c0 04             	add    $0x4,%eax
801047dc:	83 ec 08             	sub    $0x8,%esp
801047df:	68 bf a5 10 80       	push   $0x8010a5bf
801047e4:	50                   	push   %eax
801047e5:	e8 43 01 00 00       	call   8010492d <initlock>
801047ea:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
801047ed:	8b 45 08             	mov    0x8(%ebp),%eax
801047f0:	8b 55 0c             	mov    0xc(%ebp),%edx
801047f3:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
801047f6:	8b 45 08             	mov    0x8(%ebp),%eax
801047f9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801047ff:	8b 45 08             	mov    0x8(%ebp),%eax
80104802:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104809:	90                   	nop
8010480a:	c9                   	leave  
8010480b:	c3                   	ret    

8010480c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
8010480c:	55                   	push   %ebp
8010480d:	89 e5                	mov    %esp,%ebp
8010480f:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104812:	8b 45 08             	mov    0x8(%ebp),%eax
80104815:	83 c0 04             	add    $0x4,%eax
80104818:	83 ec 0c             	sub    $0xc,%esp
8010481b:	50                   	push   %eax
8010481c:	e8 2e 01 00 00       	call   8010494f <acquire>
80104821:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104824:	eb 15                	jmp    8010483b <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104826:	8b 45 08             	mov    0x8(%ebp),%eax
80104829:	83 c0 04             	add    $0x4,%eax
8010482c:	83 ec 08             	sub    $0x8,%esp
8010482f:	50                   	push   %eax
80104830:	ff 75 08             	push   0x8(%ebp)
80104833:	e8 fc fc ff ff       	call   80104534 <sleep>
80104838:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
8010483b:	8b 45 08             	mov    0x8(%ebp),%eax
8010483e:	8b 00                	mov    (%eax),%eax
80104840:	85 c0                	test   %eax,%eax
80104842:	75 e2                	jne    80104826 <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104844:	8b 45 08             	mov    0x8(%ebp),%eax
80104847:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
8010484d:	e8 de f1 ff ff       	call   80103a30 <myproc>
80104852:	8b 50 10             	mov    0x10(%eax),%edx
80104855:	8b 45 08             	mov    0x8(%ebp),%eax
80104858:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
8010485b:	8b 45 08             	mov    0x8(%ebp),%eax
8010485e:	83 c0 04             	add    $0x4,%eax
80104861:	83 ec 0c             	sub    $0xc,%esp
80104864:	50                   	push   %eax
80104865:	e8 53 01 00 00       	call   801049bd <release>
8010486a:	83 c4 10             	add    $0x10,%esp
}
8010486d:	90                   	nop
8010486e:	c9                   	leave  
8010486f:	c3                   	ret    

80104870 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104870:	55                   	push   %ebp
80104871:	89 e5                	mov    %esp,%ebp
80104873:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104876:	8b 45 08             	mov    0x8(%ebp),%eax
80104879:	83 c0 04             	add    $0x4,%eax
8010487c:	83 ec 0c             	sub    $0xc,%esp
8010487f:	50                   	push   %eax
80104880:	e8 ca 00 00 00       	call   8010494f <acquire>
80104885:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104888:	8b 45 08             	mov    0x8(%ebp),%eax
8010488b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104891:	8b 45 08             	mov    0x8(%ebp),%eax
80104894:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
8010489b:	83 ec 0c             	sub    $0xc,%esp
8010489e:	ff 75 08             	push   0x8(%ebp)
801048a1:	e8 75 fd ff ff       	call   8010461b <wakeup>
801048a6:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
801048a9:	8b 45 08             	mov    0x8(%ebp),%eax
801048ac:	83 c0 04             	add    $0x4,%eax
801048af:	83 ec 0c             	sub    $0xc,%esp
801048b2:	50                   	push   %eax
801048b3:	e8 05 01 00 00       	call   801049bd <release>
801048b8:	83 c4 10             	add    $0x10,%esp
}
801048bb:	90                   	nop
801048bc:	c9                   	leave  
801048bd:	c3                   	ret    

801048be <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801048be:	55                   	push   %ebp
801048bf:	89 e5                	mov    %esp,%ebp
801048c1:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
801048c4:	8b 45 08             	mov    0x8(%ebp),%eax
801048c7:	83 c0 04             	add    $0x4,%eax
801048ca:	83 ec 0c             	sub    $0xc,%esp
801048cd:	50                   	push   %eax
801048ce:	e8 7c 00 00 00       	call   8010494f <acquire>
801048d3:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
801048d6:	8b 45 08             	mov    0x8(%ebp),%eax
801048d9:	8b 00                	mov    (%eax),%eax
801048db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
801048de:	8b 45 08             	mov    0x8(%ebp),%eax
801048e1:	83 c0 04             	add    $0x4,%eax
801048e4:	83 ec 0c             	sub    $0xc,%esp
801048e7:	50                   	push   %eax
801048e8:	e8 d0 00 00 00       	call   801049bd <release>
801048ed:	83 c4 10             	add    $0x10,%esp
  return r;
801048f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801048f3:	c9                   	leave  
801048f4:	c3                   	ret    

801048f5 <readeflags>:
{
801048f5:	55                   	push   %ebp
801048f6:	89 e5                	mov    %esp,%ebp
801048f8:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801048fb:	9c                   	pushf  
801048fc:	58                   	pop    %eax
801048fd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104900:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104903:	c9                   	leave  
80104904:	c3                   	ret    

80104905 <cli>:
{
80104905:	55                   	push   %ebp
80104906:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104908:	fa                   	cli    
}
80104909:	90                   	nop
8010490a:	5d                   	pop    %ebp
8010490b:	c3                   	ret    

8010490c <sti>:
{
8010490c:	55                   	push   %ebp
8010490d:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010490f:	fb                   	sti    
}
80104910:	90                   	nop
80104911:	5d                   	pop    %ebp
80104912:	c3                   	ret    

80104913 <xchg>:
{
80104913:	55                   	push   %ebp
80104914:	89 e5                	mov    %esp,%ebp
80104916:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104919:	8b 55 08             	mov    0x8(%ebp),%edx
8010491c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010491f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104922:	f0 87 02             	lock xchg %eax,(%edx)
80104925:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104928:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010492b:	c9                   	leave  
8010492c:	c3                   	ret    

8010492d <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010492d:	55                   	push   %ebp
8010492e:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104930:	8b 45 08             	mov    0x8(%ebp),%eax
80104933:	8b 55 0c             	mov    0xc(%ebp),%edx
80104936:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104939:	8b 45 08             	mov    0x8(%ebp),%eax
8010493c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104942:	8b 45 08             	mov    0x8(%ebp),%eax
80104945:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
8010494c:	90                   	nop
8010494d:	5d                   	pop    %ebp
8010494e:	c3                   	ret    

8010494f <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010494f:	55                   	push   %ebp
80104950:	89 e5                	mov    %esp,%ebp
80104952:	53                   	push   %ebx
80104953:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104956:	e8 5f 01 00 00       	call   80104aba <pushcli>
  if(holding(lk)){
8010495b:	8b 45 08             	mov    0x8(%ebp),%eax
8010495e:	83 ec 0c             	sub    $0xc,%esp
80104961:	50                   	push   %eax
80104962:	e8 23 01 00 00       	call   80104a8a <holding>
80104967:	83 c4 10             	add    $0x10,%esp
8010496a:	85 c0                	test   %eax,%eax
8010496c:	74 0d                	je     8010497b <acquire+0x2c>
    panic("acquire");
8010496e:	83 ec 0c             	sub    $0xc,%esp
80104971:	68 ca a5 10 80       	push   $0x8010a5ca
80104976:	e8 2e bc ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
8010497b:	90                   	nop
8010497c:	8b 45 08             	mov    0x8(%ebp),%eax
8010497f:	83 ec 08             	sub    $0x8,%esp
80104982:	6a 01                	push   $0x1
80104984:	50                   	push   %eax
80104985:	e8 89 ff ff ff       	call   80104913 <xchg>
8010498a:	83 c4 10             	add    $0x10,%esp
8010498d:	85 c0                	test   %eax,%eax
8010498f:	75 eb                	jne    8010497c <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104991:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104996:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104999:	e8 1a f0 ff ff       	call   801039b8 <mycpu>
8010499e:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
801049a1:	8b 45 08             	mov    0x8(%ebp),%eax
801049a4:	83 c0 0c             	add    $0xc,%eax
801049a7:	83 ec 08             	sub    $0x8,%esp
801049aa:	50                   	push   %eax
801049ab:	8d 45 08             	lea    0x8(%ebp),%eax
801049ae:	50                   	push   %eax
801049af:	e8 5b 00 00 00       	call   80104a0f <getcallerpcs>
801049b4:	83 c4 10             	add    $0x10,%esp
}
801049b7:	90                   	nop
801049b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801049bb:	c9                   	leave  
801049bc:	c3                   	ret    

801049bd <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801049bd:	55                   	push   %ebp
801049be:	89 e5                	mov    %esp,%ebp
801049c0:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801049c3:	83 ec 0c             	sub    $0xc,%esp
801049c6:	ff 75 08             	push   0x8(%ebp)
801049c9:	e8 bc 00 00 00       	call   80104a8a <holding>
801049ce:	83 c4 10             	add    $0x10,%esp
801049d1:	85 c0                	test   %eax,%eax
801049d3:	75 0d                	jne    801049e2 <release+0x25>
    panic("release");
801049d5:	83 ec 0c             	sub    $0xc,%esp
801049d8:	68 d2 a5 10 80       	push   $0x8010a5d2
801049dd:	e8 c7 bb ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
801049e2:	8b 45 08             	mov    0x8(%ebp),%eax
801049e5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801049ec:	8b 45 08             	mov    0x8(%ebp),%eax
801049ef:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801049f6:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801049fb:	8b 45 08             	mov    0x8(%ebp),%eax
801049fe:	8b 55 08             	mov    0x8(%ebp),%edx
80104a01:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104a07:	e8 fb 00 00 00       	call   80104b07 <popcli>
}
80104a0c:	90                   	nop
80104a0d:	c9                   	leave  
80104a0e:	c3                   	ret    

80104a0f <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104a0f:	55                   	push   %ebp
80104a10:	89 e5                	mov    %esp,%ebp
80104a12:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104a15:	8b 45 08             	mov    0x8(%ebp),%eax
80104a18:	83 e8 08             	sub    $0x8,%eax
80104a1b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104a1e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104a25:	eb 38                	jmp    80104a5f <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104a27:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104a2b:	74 53                	je     80104a80 <getcallerpcs+0x71>
80104a2d:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104a34:	76 4a                	jbe    80104a80 <getcallerpcs+0x71>
80104a36:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104a3a:	74 44                	je     80104a80 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104a3c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104a3f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104a46:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a49:	01 c2                	add    %eax,%edx
80104a4b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a4e:	8b 40 04             	mov    0x4(%eax),%eax
80104a51:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104a53:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a56:	8b 00                	mov    (%eax),%eax
80104a58:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104a5b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104a5f:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104a63:	7e c2                	jle    80104a27 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80104a65:	eb 19                	jmp    80104a80 <getcallerpcs+0x71>
    pcs[i] = 0;
80104a67:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104a6a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104a71:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a74:	01 d0                	add    %edx,%eax
80104a76:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104a7c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104a80:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104a84:	7e e1                	jle    80104a67 <getcallerpcs+0x58>
}
80104a86:	90                   	nop
80104a87:	90                   	nop
80104a88:	c9                   	leave  
80104a89:	c3                   	ret    

80104a8a <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104a8a:	55                   	push   %ebp
80104a8b:	89 e5                	mov    %esp,%ebp
80104a8d:	53                   	push   %ebx
80104a8e:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104a91:	8b 45 08             	mov    0x8(%ebp),%eax
80104a94:	8b 00                	mov    (%eax),%eax
80104a96:	85 c0                	test   %eax,%eax
80104a98:	74 16                	je     80104ab0 <holding+0x26>
80104a9a:	8b 45 08             	mov    0x8(%ebp),%eax
80104a9d:	8b 58 08             	mov    0x8(%eax),%ebx
80104aa0:	e8 13 ef ff ff       	call   801039b8 <mycpu>
80104aa5:	39 c3                	cmp    %eax,%ebx
80104aa7:	75 07                	jne    80104ab0 <holding+0x26>
80104aa9:	b8 01 00 00 00       	mov    $0x1,%eax
80104aae:	eb 05                	jmp    80104ab5 <holding+0x2b>
80104ab0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104ab5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104ab8:	c9                   	leave  
80104ab9:	c3                   	ret    

80104aba <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104aba:	55                   	push   %ebp
80104abb:	89 e5                	mov    %esp,%ebp
80104abd:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104ac0:	e8 30 fe ff ff       	call   801048f5 <readeflags>
80104ac5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104ac8:	e8 38 fe ff ff       	call   80104905 <cli>
  if(mycpu()->ncli == 0)
80104acd:	e8 e6 ee ff ff       	call   801039b8 <mycpu>
80104ad2:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104ad8:	85 c0                	test   %eax,%eax
80104ada:	75 14                	jne    80104af0 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80104adc:	e8 d7 ee ff ff       	call   801039b8 <mycpu>
80104ae1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ae4:	81 e2 00 02 00 00    	and    $0x200,%edx
80104aea:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104af0:	e8 c3 ee ff ff       	call   801039b8 <mycpu>
80104af5:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104afb:	83 c2 01             	add    $0x1,%edx
80104afe:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104b04:	90                   	nop
80104b05:	c9                   	leave  
80104b06:	c3                   	ret    

80104b07 <popcli>:

void
popcli(void)
{
80104b07:	55                   	push   %ebp
80104b08:	89 e5                	mov    %esp,%ebp
80104b0a:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104b0d:	e8 e3 fd ff ff       	call   801048f5 <readeflags>
80104b12:	25 00 02 00 00       	and    $0x200,%eax
80104b17:	85 c0                	test   %eax,%eax
80104b19:	74 0d                	je     80104b28 <popcli+0x21>
    panic("popcli - interruptible");
80104b1b:	83 ec 0c             	sub    $0xc,%esp
80104b1e:	68 da a5 10 80       	push   $0x8010a5da
80104b23:	e8 81 ba ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
80104b28:	e8 8b ee ff ff       	call   801039b8 <mycpu>
80104b2d:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104b33:	83 ea 01             	sub    $0x1,%edx
80104b36:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104b3c:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104b42:	85 c0                	test   %eax,%eax
80104b44:	79 0d                	jns    80104b53 <popcli+0x4c>
    panic("popcli");
80104b46:	83 ec 0c             	sub    $0xc,%esp
80104b49:	68 f1 a5 10 80       	push   $0x8010a5f1
80104b4e:	e8 56 ba ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104b53:	e8 60 ee ff ff       	call   801039b8 <mycpu>
80104b58:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104b5e:	85 c0                	test   %eax,%eax
80104b60:	75 14                	jne    80104b76 <popcli+0x6f>
80104b62:	e8 51 ee ff ff       	call   801039b8 <mycpu>
80104b67:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104b6d:	85 c0                	test   %eax,%eax
80104b6f:	74 05                	je     80104b76 <popcli+0x6f>
    sti();
80104b71:	e8 96 fd ff ff       	call   8010490c <sti>
}
80104b76:	90                   	nop
80104b77:	c9                   	leave  
80104b78:	c3                   	ret    

80104b79 <stosb>:
{
80104b79:	55                   	push   %ebp
80104b7a:	89 e5                	mov    %esp,%ebp
80104b7c:	57                   	push   %edi
80104b7d:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104b7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104b81:	8b 55 10             	mov    0x10(%ebp),%edx
80104b84:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b87:	89 cb                	mov    %ecx,%ebx
80104b89:	89 df                	mov    %ebx,%edi
80104b8b:	89 d1                	mov    %edx,%ecx
80104b8d:	fc                   	cld    
80104b8e:	f3 aa                	rep stos %al,%es:(%edi)
80104b90:	89 ca                	mov    %ecx,%edx
80104b92:	89 fb                	mov    %edi,%ebx
80104b94:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104b97:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104b9a:	90                   	nop
80104b9b:	5b                   	pop    %ebx
80104b9c:	5f                   	pop    %edi
80104b9d:	5d                   	pop    %ebp
80104b9e:	c3                   	ret    

80104b9f <stosl>:
{
80104b9f:	55                   	push   %ebp
80104ba0:	89 e5                	mov    %esp,%ebp
80104ba2:	57                   	push   %edi
80104ba3:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104ba4:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104ba7:	8b 55 10             	mov    0x10(%ebp),%edx
80104baa:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bad:	89 cb                	mov    %ecx,%ebx
80104baf:	89 df                	mov    %ebx,%edi
80104bb1:	89 d1                	mov    %edx,%ecx
80104bb3:	fc                   	cld    
80104bb4:	f3 ab                	rep stos %eax,%es:(%edi)
80104bb6:	89 ca                	mov    %ecx,%edx
80104bb8:	89 fb                	mov    %edi,%ebx
80104bba:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104bbd:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104bc0:	90                   	nop
80104bc1:	5b                   	pop    %ebx
80104bc2:	5f                   	pop    %edi
80104bc3:	5d                   	pop    %ebp
80104bc4:	c3                   	ret    

80104bc5 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104bc5:	55                   	push   %ebp
80104bc6:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104bc8:	8b 45 08             	mov    0x8(%ebp),%eax
80104bcb:	83 e0 03             	and    $0x3,%eax
80104bce:	85 c0                	test   %eax,%eax
80104bd0:	75 43                	jne    80104c15 <memset+0x50>
80104bd2:	8b 45 10             	mov    0x10(%ebp),%eax
80104bd5:	83 e0 03             	and    $0x3,%eax
80104bd8:	85 c0                	test   %eax,%eax
80104bda:	75 39                	jne    80104c15 <memset+0x50>
    c &= 0xFF;
80104bdc:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104be3:	8b 45 10             	mov    0x10(%ebp),%eax
80104be6:	c1 e8 02             	shr    $0x2,%eax
80104be9:	89 c2                	mov    %eax,%edx
80104beb:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bee:	c1 e0 18             	shl    $0x18,%eax
80104bf1:	89 c1                	mov    %eax,%ecx
80104bf3:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bf6:	c1 e0 10             	shl    $0x10,%eax
80104bf9:	09 c1                	or     %eax,%ecx
80104bfb:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bfe:	c1 e0 08             	shl    $0x8,%eax
80104c01:	09 c8                	or     %ecx,%eax
80104c03:	0b 45 0c             	or     0xc(%ebp),%eax
80104c06:	52                   	push   %edx
80104c07:	50                   	push   %eax
80104c08:	ff 75 08             	push   0x8(%ebp)
80104c0b:	e8 8f ff ff ff       	call   80104b9f <stosl>
80104c10:	83 c4 0c             	add    $0xc,%esp
80104c13:	eb 12                	jmp    80104c27 <memset+0x62>
  } else
    stosb(dst, c, n);
80104c15:	8b 45 10             	mov    0x10(%ebp),%eax
80104c18:	50                   	push   %eax
80104c19:	ff 75 0c             	push   0xc(%ebp)
80104c1c:	ff 75 08             	push   0x8(%ebp)
80104c1f:	e8 55 ff ff ff       	call   80104b79 <stosb>
80104c24:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104c27:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104c2a:	c9                   	leave  
80104c2b:	c3                   	ret    

80104c2c <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104c2c:	55                   	push   %ebp
80104c2d:	89 e5                	mov    %esp,%ebp
80104c2f:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104c32:	8b 45 08             	mov    0x8(%ebp),%eax
80104c35:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104c38:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c3b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104c3e:	eb 30                	jmp    80104c70 <memcmp+0x44>
    if(*s1 != *s2)
80104c40:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c43:	0f b6 10             	movzbl (%eax),%edx
80104c46:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c49:	0f b6 00             	movzbl (%eax),%eax
80104c4c:	38 c2                	cmp    %al,%dl
80104c4e:	74 18                	je     80104c68 <memcmp+0x3c>
      return *s1 - *s2;
80104c50:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c53:	0f b6 00             	movzbl (%eax),%eax
80104c56:	0f b6 d0             	movzbl %al,%edx
80104c59:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c5c:	0f b6 00             	movzbl (%eax),%eax
80104c5f:	0f b6 c8             	movzbl %al,%ecx
80104c62:	89 d0                	mov    %edx,%eax
80104c64:	29 c8                	sub    %ecx,%eax
80104c66:	eb 1a                	jmp    80104c82 <memcmp+0x56>
    s1++, s2++;
80104c68:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104c6c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104c70:	8b 45 10             	mov    0x10(%ebp),%eax
80104c73:	8d 50 ff             	lea    -0x1(%eax),%edx
80104c76:	89 55 10             	mov    %edx,0x10(%ebp)
80104c79:	85 c0                	test   %eax,%eax
80104c7b:	75 c3                	jne    80104c40 <memcmp+0x14>
  }

  return 0;
80104c7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c82:	c9                   	leave  
80104c83:	c3                   	ret    

80104c84 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104c84:	55                   	push   %ebp
80104c85:	89 e5                	mov    %esp,%ebp
80104c87:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104c8a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c8d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104c90:	8b 45 08             	mov    0x8(%ebp),%eax
80104c93:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104c96:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c99:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104c9c:	73 54                	jae    80104cf2 <memmove+0x6e>
80104c9e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104ca1:	8b 45 10             	mov    0x10(%ebp),%eax
80104ca4:	01 d0                	add    %edx,%eax
80104ca6:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104ca9:	73 47                	jae    80104cf2 <memmove+0x6e>
    s += n;
80104cab:	8b 45 10             	mov    0x10(%ebp),%eax
80104cae:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104cb1:	8b 45 10             	mov    0x10(%ebp),%eax
80104cb4:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104cb7:	eb 13                	jmp    80104ccc <memmove+0x48>
      *--d = *--s;
80104cb9:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104cbd:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104cc1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cc4:	0f b6 10             	movzbl (%eax),%edx
80104cc7:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104cca:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104ccc:	8b 45 10             	mov    0x10(%ebp),%eax
80104ccf:	8d 50 ff             	lea    -0x1(%eax),%edx
80104cd2:	89 55 10             	mov    %edx,0x10(%ebp)
80104cd5:	85 c0                	test   %eax,%eax
80104cd7:	75 e0                	jne    80104cb9 <memmove+0x35>
  if(s < d && s + n > d){
80104cd9:	eb 24                	jmp    80104cff <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104cdb:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104cde:	8d 42 01             	lea    0x1(%edx),%eax
80104ce1:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104ce4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ce7:	8d 48 01             	lea    0x1(%eax),%ecx
80104cea:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104ced:	0f b6 12             	movzbl (%edx),%edx
80104cf0:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104cf2:	8b 45 10             	mov    0x10(%ebp),%eax
80104cf5:	8d 50 ff             	lea    -0x1(%eax),%edx
80104cf8:	89 55 10             	mov    %edx,0x10(%ebp)
80104cfb:	85 c0                	test   %eax,%eax
80104cfd:	75 dc                	jne    80104cdb <memmove+0x57>

  return dst;
80104cff:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104d02:	c9                   	leave  
80104d03:	c3                   	ret    

80104d04 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104d04:	55                   	push   %ebp
80104d05:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104d07:	ff 75 10             	push   0x10(%ebp)
80104d0a:	ff 75 0c             	push   0xc(%ebp)
80104d0d:	ff 75 08             	push   0x8(%ebp)
80104d10:	e8 6f ff ff ff       	call   80104c84 <memmove>
80104d15:	83 c4 0c             	add    $0xc,%esp
}
80104d18:	c9                   	leave  
80104d19:	c3                   	ret    

80104d1a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104d1a:	55                   	push   %ebp
80104d1b:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104d1d:	eb 0c                	jmp    80104d2b <strncmp+0x11>
    n--, p++, q++;
80104d1f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104d23:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104d27:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104d2b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104d2f:	74 1a                	je     80104d4b <strncmp+0x31>
80104d31:	8b 45 08             	mov    0x8(%ebp),%eax
80104d34:	0f b6 00             	movzbl (%eax),%eax
80104d37:	84 c0                	test   %al,%al
80104d39:	74 10                	je     80104d4b <strncmp+0x31>
80104d3b:	8b 45 08             	mov    0x8(%ebp),%eax
80104d3e:	0f b6 10             	movzbl (%eax),%edx
80104d41:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d44:	0f b6 00             	movzbl (%eax),%eax
80104d47:	38 c2                	cmp    %al,%dl
80104d49:	74 d4                	je     80104d1f <strncmp+0x5>
  if(n == 0)
80104d4b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104d4f:	75 07                	jne    80104d58 <strncmp+0x3e>
    return 0;
80104d51:	b8 00 00 00 00       	mov    $0x0,%eax
80104d56:	eb 16                	jmp    80104d6e <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80104d58:	8b 45 08             	mov    0x8(%ebp),%eax
80104d5b:	0f b6 00             	movzbl (%eax),%eax
80104d5e:	0f b6 d0             	movzbl %al,%edx
80104d61:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d64:	0f b6 00             	movzbl (%eax),%eax
80104d67:	0f b6 c8             	movzbl %al,%ecx
80104d6a:	89 d0                	mov    %edx,%eax
80104d6c:	29 c8                	sub    %ecx,%eax
}
80104d6e:	5d                   	pop    %ebp
80104d6f:	c3                   	ret    

80104d70 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104d70:	55                   	push   %ebp
80104d71:	89 e5                	mov    %esp,%ebp
80104d73:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104d76:	8b 45 08             	mov    0x8(%ebp),%eax
80104d79:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104d7c:	90                   	nop
80104d7d:	8b 45 10             	mov    0x10(%ebp),%eax
80104d80:	8d 50 ff             	lea    -0x1(%eax),%edx
80104d83:	89 55 10             	mov    %edx,0x10(%ebp)
80104d86:	85 c0                	test   %eax,%eax
80104d88:	7e 2c                	jle    80104db6 <strncpy+0x46>
80104d8a:	8b 55 0c             	mov    0xc(%ebp),%edx
80104d8d:	8d 42 01             	lea    0x1(%edx),%eax
80104d90:	89 45 0c             	mov    %eax,0xc(%ebp)
80104d93:	8b 45 08             	mov    0x8(%ebp),%eax
80104d96:	8d 48 01             	lea    0x1(%eax),%ecx
80104d99:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104d9c:	0f b6 12             	movzbl (%edx),%edx
80104d9f:	88 10                	mov    %dl,(%eax)
80104da1:	0f b6 00             	movzbl (%eax),%eax
80104da4:	84 c0                	test   %al,%al
80104da6:	75 d5                	jne    80104d7d <strncpy+0xd>
    ;
  while(n-- > 0)
80104da8:	eb 0c                	jmp    80104db6 <strncpy+0x46>
    *s++ = 0;
80104daa:	8b 45 08             	mov    0x8(%ebp),%eax
80104dad:	8d 50 01             	lea    0x1(%eax),%edx
80104db0:	89 55 08             	mov    %edx,0x8(%ebp)
80104db3:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104db6:	8b 45 10             	mov    0x10(%ebp),%eax
80104db9:	8d 50 ff             	lea    -0x1(%eax),%edx
80104dbc:	89 55 10             	mov    %edx,0x10(%ebp)
80104dbf:	85 c0                	test   %eax,%eax
80104dc1:	7f e7                	jg     80104daa <strncpy+0x3a>
  return os;
80104dc3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104dc6:	c9                   	leave  
80104dc7:	c3                   	ret    

80104dc8 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104dc8:	55                   	push   %ebp
80104dc9:	89 e5                	mov    %esp,%ebp
80104dcb:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104dce:	8b 45 08             	mov    0x8(%ebp),%eax
80104dd1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104dd4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104dd8:	7f 05                	jg     80104ddf <safestrcpy+0x17>
    return os;
80104dda:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ddd:	eb 32                	jmp    80104e11 <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80104ddf:	90                   	nop
80104de0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104de4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104de8:	7e 1e                	jle    80104e08 <safestrcpy+0x40>
80104dea:	8b 55 0c             	mov    0xc(%ebp),%edx
80104ded:	8d 42 01             	lea    0x1(%edx),%eax
80104df0:	89 45 0c             	mov    %eax,0xc(%ebp)
80104df3:	8b 45 08             	mov    0x8(%ebp),%eax
80104df6:	8d 48 01             	lea    0x1(%eax),%ecx
80104df9:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104dfc:	0f b6 12             	movzbl (%edx),%edx
80104dff:	88 10                	mov    %dl,(%eax)
80104e01:	0f b6 00             	movzbl (%eax),%eax
80104e04:	84 c0                	test   %al,%al
80104e06:	75 d8                	jne    80104de0 <safestrcpy+0x18>
    ;
  *s = 0;
80104e08:	8b 45 08             	mov    0x8(%ebp),%eax
80104e0b:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104e0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104e11:	c9                   	leave  
80104e12:	c3                   	ret    

80104e13 <strlen>:

int
strlen(const char *s)
{
80104e13:	55                   	push   %ebp
80104e14:	89 e5                	mov    %esp,%ebp
80104e16:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104e19:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104e20:	eb 04                	jmp    80104e26 <strlen+0x13>
80104e22:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104e26:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104e29:	8b 45 08             	mov    0x8(%ebp),%eax
80104e2c:	01 d0                	add    %edx,%eax
80104e2e:	0f b6 00             	movzbl (%eax),%eax
80104e31:	84 c0                	test   %al,%al
80104e33:	75 ed                	jne    80104e22 <strlen+0xf>
    ;
  return n;
80104e35:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104e38:	c9                   	leave  
80104e39:	c3                   	ret    

80104e3a <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104e3a:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104e3e:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104e42:	55                   	push   %ebp
  pushl %ebx
80104e43:	53                   	push   %ebx
  pushl %esi
80104e44:	56                   	push   %esi
  pushl %edi
80104e45:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104e46:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104e48:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104e4a:	5f                   	pop    %edi
  popl %esi
80104e4b:	5e                   	pop    %esi
  popl %ebx
80104e4c:	5b                   	pop    %ebx
  popl %ebp
80104e4d:	5d                   	pop    %ebp
  ret
80104e4e:	c3                   	ret    

80104e4f <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104e4f:	55                   	push   %ebp
80104e50:	89 e5                	mov    %esp,%ebp
80104e52:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104e55:	e8 d6 eb ff ff       	call   80103a30 <myproc>
80104e5a:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e60:	8b 00                	mov    (%eax),%eax
80104e62:	39 45 08             	cmp    %eax,0x8(%ebp)
80104e65:	73 0f                	jae    80104e76 <fetchint+0x27>
80104e67:	8b 45 08             	mov    0x8(%ebp),%eax
80104e6a:	8d 50 04             	lea    0x4(%eax),%edx
80104e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e70:	8b 00                	mov    (%eax),%eax
80104e72:	39 c2                	cmp    %eax,%edx
80104e74:	76 07                	jbe    80104e7d <fetchint+0x2e>
    return -1;
80104e76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e7b:	eb 0f                	jmp    80104e8c <fetchint+0x3d>
  *ip = *(int*)(addr);
80104e7d:	8b 45 08             	mov    0x8(%ebp),%eax
80104e80:	8b 10                	mov    (%eax),%edx
80104e82:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e85:	89 10                	mov    %edx,(%eax)
  return 0;
80104e87:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e8c:	c9                   	leave  
80104e8d:	c3                   	ret    

80104e8e <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104e8e:	55                   	push   %ebp
80104e8f:	89 e5                	mov    %esp,%ebp
80104e91:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80104e94:	e8 97 eb ff ff       	call   80103a30 <myproc>
80104e99:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80104e9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e9f:	8b 00                	mov    (%eax),%eax
80104ea1:	39 45 08             	cmp    %eax,0x8(%ebp)
80104ea4:	72 07                	jb     80104ead <fetchstr+0x1f>
    return -1;
80104ea6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104eab:	eb 41                	jmp    80104eee <fetchstr+0x60>
  *pp = (char*)addr;
80104ead:	8b 55 08             	mov    0x8(%ebp),%edx
80104eb0:	8b 45 0c             	mov    0xc(%ebp),%eax
80104eb3:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80104eb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104eb8:	8b 00                	mov    (%eax),%eax
80104eba:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80104ebd:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ec0:	8b 00                	mov    (%eax),%eax
80104ec2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104ec5:	eb 1a                	jmp    80104ee1 <fetchstr+0x53>
    if(*s == 0)
80104ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eca:	0f b6 00             	movzbl (%eax),%eax
80104ecd:	84 c0                	test   %al,%al
80104ecf:	75 0c                	jne    80104edd <fetchstr+0x4f>
      return s - *pp;
80104ed1:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ed4:	8b 10                	mov    (%eax),%edx
80104ed6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ed9:	29 d0                	sub    %edx,%eax
80104edb:	eb 11                	jmp    80104eee <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
80104edd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104ee1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ee4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104ee7:	72 de                	jb     80104ec7 <fetchstr+0x39>
  }
  return -1;
80104ee9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104eee:	c9                   	leave  
80104eef:	c3                   	ret    

80104ef0 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104ef0:	55                   	push   %ebp
80104ef1:	89 e5                	mov    %esp,%ebp
80104ef3:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104ef6:	e8 35 eb ff ff       	call   80103a30 <myproc>
80104efb:	8b 40 18             	mov    0x18(%eax),%eax
80104efe:	8b 50 44             	mov    0x44(%eax),%edx
80104f01:	8b 45 08             	mov    0x8(%ebp),%eax
80104f04:	c1 e0 02             	shl    $0x2,%eax
80104f07:	01 d0                	add    %edx,%eax
80104f09:	83 c0 04             	add    $0x4,%eax
80104f0c:	83 ec 08             	sub    $0x8,%esp
80104f0f:	ff 75 0c             	push   0xc(%ebp)
80104f12:	50                   	push   %eax
80104f13:	e8 37 ff ff ff       	call   80104e4f <fetchint>
80104f18:	83 c4 10             	add    $0x10,%esp
}
80104f1b:	c9                   	leave  
80104f1c:	c3                   	ret    

80104f1d <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104f1d:	55                   	push   %ebp
80104f1e:	89 e5                	mov    %esp,%ebp
80104f20:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80104f23:	e8 08 eb ff ff       	call   80103a30 <myproc>
80104f28:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80104f2b:	83 ec 08             	sub    $0x8,%esp
80104f2e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104f31:	50                   	push   %eax
80104f32:	ff 75 08             	push   0x8(%ebp)
80104f35:	e8 b6 ff ff ff       	call   80104ef0 <argint>
80104f3a:	83 c4 10             	add    $0x10,%esp
80104f3d:	85 c0                	test   %eax,%eax
80104f3f:	79 07                	jns    80104f48 <argptr+0x2b>
    return -1;
80104f41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f46:	eb 3b                	jmp    80104f83 <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104f48:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f4c:	78 1f                	js     80104f6d <argptr+0x50>
80104f4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f51:	8b 00                	mov    (%eax),%eax
80104f53:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f56:	39 d0                	cmp    %edx,%eax
80104f58:	76 13                	jbe    80104f6d <argptr+0x50>
80104f5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f5d:	89 c2                	mov    %eax,%edx
80104f5f:	8b 45 10             	mov    0x10(%ebp),%eax
80104f62:	01 c2                	add    %eax,%edx
80104f64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f67:	8b 00                	mov    (%eax),%eax
80104f69:	39 c2                	cmp    %eax,%edx
80104f6b:	76 07                	jbe    80104f74 <argptr+0x57>
    return -1;
80104f6d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f72:	eb 0f                	jmp    80104f83 <argptr+0x66>
  *pp = (char*)i;
80104f74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f77:	89 c2                	mov    %eax,%edx
80104f79:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f7c:	89 10                	mov    %edx,(%eax)
  return 0;
80104f7e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f83:	c9                   	leave  
80104f84:	c3                   	ret    

80104f85 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104f85:	55                   	push   %ebp
80104f86:	89 e5                	mov    %esp,%ebp
80104f88:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104f8b:	83 ec 08             	sub    $0x8,%esp
80104f8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f91:	50                   	push   %eax
80104f92:	ff 75 08             	push   0x8(%ebp)
80104f95:	e8 56 ff ff ff       	call   80104ef0 <argint>
80104f9a:	83 c4 10             	add    $0x10,%esp
80104f9d:	85 c0                	test   %eax,%eax
80104f9f:	79 07                	jns    80104fa8 <argstr+0x23>
    return -1;
80104fa1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fa6:	eb 12                	jmp    80104fba <argstr+0x35>
  return fetchstr(addr, pp);
80104fa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fab:	83 ec 08             	sub    $0x8,%esp
80104fae:	ff 75 0c             	push   0xc(%ebp)
80104fb1:	50                   	push   %eax
80104fb2:	e8 d7 fe ff ff       	call   80104e8e <fetchstr>
80104fb7:	83 c4 10             	add    $0x10,%esp
}
80104fba:	c9                   	leave  
80104fbb:	c3                   	ret    

80104fbc <syscall>:
[SYS_wait2]   sys_wait2, 
};

void
syscall(void)
{
80104fbc:	55                   	push   %ebp
80104fbd:	89 e5                	mov    %esp,%ebp
80104fbf:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80104fc2:	e8 69 ea ff ff       	call   80103a30 <myproc>
80104fc7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80104fca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fcd:	8b 40 18             	mov    0x18(%eax),%eax
80104fd0:	8b 40 1c             	mov    0x1c(%eax),%eax
80104fd3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104fd6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104fda:	7e 2f                	jle    8010500b <syscall+0x4f>
80104fdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fdf:	83 f8 17             	cmp    $0x17,%eax
80104fe2:	77 27                	ja     8010500b <syscall+0x4f>
80104fe4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fe7:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104fee:	85 c0                	test   %eax,%eax
80104ff0:	74 19                	je     8010500b <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80104ff2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ff5:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104ffc:	ff d0                	call   *%eax
80104ffe:	89 c2                	mov    %eax,%edx
80105000:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105003:	8b 40 18             	mov    0x18(%eax),%eax
80105006:	89 50 1c             	mov    %edx,0x1c(%eax)
80105009:	eb 2c                	jmp    80105037 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
8010500b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010500e:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80105011:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105014:	8b 40 10             	mov    0x10(%eax),%eax
80105017:	ff 75 f0             	push   -0x10(%ebp)
8010501a:	52                   	push   %edx
8010501b:	50                   	push   %eax
8010501c:	68 f8 a5 10 80       	push   $0x8010a5f8
80105021:	e8 ce b3 ff ff       	call   801003f4 <cprintf>
80105026:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80105029:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010502c:	8b 40 18             	mov    0x18(%eax),%eax
8010502f:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105036:	90                   	nop
80105037:	90                   	nop
80105038:	c9                   	leave  
80105039:	c3                   	ret    

8010503a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
8010503a:	55                   	push   %ebp
8010503b:	89 e5                	mov    %esp,%ebp
8010503d:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105040:	83 ec 08             	sub    $0x8,%esp
80105043:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105046:	50                   	push   %eax
80105047:	ff 75 08             	push   0x8(%ebp)
8010504a:	e8 a1 fe ff ff       	call   80104ef0 <argint>
8010504f:	83 c4 10             	add    $0x10,%esp
80105052:	85 c0                	test   %eax,%eax
80105054:	79 07                	jns    8010505d <argfd+0x23>
    return -1;
80105056:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010505b:	eb 4f                	jmp    801050ac <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010505d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105060:	85 c0                	test   %eax,%eax
80105062:	78 20                	js     80105084 <argfd+0x4a>
80105064:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105067:	83 f8 0f             	cmp    $0xf,%eax
8010506a:	7f 18                	jg     80105084 <argfd+0x4a>
8010506c:	e8 bf e9 ff ff       	call   80103a30 <myproc>
80105071:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105074:	83 c2 08             	add    $0x8,%edx
80105077:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010507b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010507e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105082:	75 07                	jne    8010508b <argfd+0x51>
    return -1;
80105084:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105089:	eb 21                	jmp    801050ac <argfd+0x72>
  if(pfd)
8010508b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010508f:	74 08                	je     80105099 <argfd+0x5f>
    *pfd = fd;
80105091:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105094:	8b 45 0c             	mov    0xc(%ebp),%eax
80105097:	89 10                	mov    %edx,(%eax)
  if(pf)
80105099:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010509d:	74 08                	je     801050a7 <argfd+0x6d>
    *pf = f;
8010509f:	8b 45 10             	mov    0x10(%ebp),%eax
801050a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801050a5:	89 10                	mov    %edx,(%eax)
  return 0;
801050a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801050ac:	c9                   	leave  
801050ad:	c3                   	ret    

801050ae <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801050ae:	55                   	push   %ebp
801050af:	89 e5                	mov    %esp,%ebp
801050b1:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
801050b4:	e8 77 e9 ff ff       	call   80103a30 <myproc>
801050b9:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
801050bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801050c3:	eb 2a                	jmp    801050ef <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
801050c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801050cb:	83 c2 08             	add    $0x8,%edx
801050ce:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801050d2:	85 c0                	test   %eax,%eax
801050d4:	75 15                	jne    801050eb <fdalloc+0x3d>
      curproc->ofile[fd] = f;
801050d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801050dc:	8d 4a 08             	lea    0x8(%edx),%ecx
801050df:	8b 55 08             	mov    0x8(%ebp),%edx
801050e2:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801050e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050e9:	eb 0f                	jmp    801050fa <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
801050eb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801050ef:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801050f3:	7e d0                	jle    801050c5 <fdalloc+0x17>
    }
  }
  return -1;
801050f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801050fa:	c9                   	leave  
801050fb:	c3                   	ret    

801050fc <sys_dup>:

int
sys_dup(void)
{
801050fc:	55                   	push   %ebp
801050fd:	89 e5                	mov    %esp,%ebp
801050ff:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105102:	83 ec 04             	sub    $0x4,%esp
80105105:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105108:	50                   	push   %eax
80105109:	6a 00                	push   $0x0
8010510b:	6a 00                	push   $0x0
8010510d:	e8 28 ff ff ff       	call   8010503a <argfd>
80105112:	83 c4 10             	add    $0x10,%esp
80105115:	85 c0                	test   %eax,%eax
80105117:	79 07                	jns    80105120 <sys_dup+0x24>
    return -1;
80105119:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010511e:	eb 31                	jmp    80105151 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105120:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105123:	83 ec 0c             	sub    $0xc,%esp
80105126:	50                   	push   %eax
80105127:	e8 82 ff ff ff       	call   801050ae <fdalloc>
8010512c:	83 c4 10             	add    $0x10,%esp
8010512f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105132:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105136:	79 07                	jns    8010513f <sys_dup+0x43>
    return -1;
80105138:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010513d:	eb 12                	jmp    80105151 <sys_dup+0x55>
  filedup(f);
8010513f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105142:	83 ec 0c             	sub    $0xc,%esp
80105145:	50                   	push   %eax
80105146:	e8 ff be ff ff       	call   8010104a <filedup>
8010514b:	83 c4 10             	add    $0x10,%esp
  return fd;
8010514e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105151:	c9                   	leave  
80105152:	c3                   	ret    

80105153 <sys_read>:

int
sys_read(void)
{
80105153:	55                   	push   %ebp
80105154:	89 e5                	mov    %esp,%ebp
80105156:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105159:	83 ec 04             	sub    $0x4,%esp
8010515c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010515f:	50                   	push   %eax
80105160:	6a 00                	push   $0x0
80105162:	6a 00                	push   $0x0
80105164:	e8 d1 fe ff ff       	call   8010503a <argfd>
80105169:	83 c4 10             	add    $0x10,%esp
8010516c:	85 c0                	test   %eax,%eax
8010516e:	78 2e                	js     8010519e <sys_read+0x4b>
80105170:	83 ec 08             	sub    $0x8,%esp
80105173:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105176:	50                   	push   %eax
80105177:	6a 02                	push   $0x2
80105179:	e8 72 fd ff ff       	call   80104ef0 <argint>
8010517e:	83 c4 10             	add    $0x10,%esp
80105181:	85 c0                	test   %eax,%eax
80105183:	78 19                	js     8010519e <sys_read+0x4b>
80105185:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105188:	83 ec 04             	sub    $0x4,%esp
8010518b:	50                   	push   %eax
8010518c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010518f:	50                   	push   %eax
80105190:	6a 01                	push   $0x1
80105192:	e8 86 fd ff ff       	call   80104f1d <argptr>
80105197:	83 c4 10             	add    $0x10,%esp
8010519a:	85 c0                	test   %eax,%eax
8010519c:	79 07                	jns    801051a5 <sys_read+0x52>
    return -1;
8010519e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051a3:	eb 17                	jmp    801051bc <sys_read+0x69>
  return fileread(f, p, n);
801051a5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801051a8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801051ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051ae:	83 ec 04             	sub    $0x4,%esp
801051b1:	51                   	push   %ecx
801051b2:	52                   	push   %edx
801051b3:	50                   	push   %eax
801051b4:	e8 21 c0 ff ff       	call   801011da <fileread>
801051b9:	83 c4 10             	add    $0x10,%esp
}
801051bc:	c9                   	leave  
801051bd:	c3                   	ret    

801051be <sys_write>:

int
sys_write(void)
{
801051be:	55                   	push   %ebp
801051bf:	89 e5                	mov    %esp,%ebp
801051c1:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801051c4:	83 ec 04             	sub    $0x4,%esp
801051c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801051ca:	50                   	push   %eax
801051cb:	6a 00                	push   $0x0
801051cd:	6a 00                	push   $0x0
801051cf:	e8 66 fe ff ff       	call   8010503a <argfd>
801051d4:	83 c4 10             	add    $0x10,%esp
801051d7:	85 c0                	test   %eax,%eax
801051d9:	78 2e                	js     80105209 <sys_write+0x4b>
801051db:	83 ec 08             	sub    $0x8,%esp
801051de:	8d 45 f0             	lea    -0x10(%ebp),%eax
801051e1:	50                   	push   %eax
801051e2:	6a 02                	push   $0x2
801051e4:	e8 07 fd ff ff       	call   80104ef0 <argint>
801051e9:	83 c4 10             	add    $0x10,%esp
801051ec:	85 c0                	test   %eax,%eax
801051ee:	78 19                	js     80105209 <sys_write+0x4b>
801051f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051f3:	83 ec 04             	sub    $0x4,%esp
801051f6:	50                   	push   %eax
801051f7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801051fa:	50                   	push   %eax
801051fb:	6a 01                	push   $0x1
801051fd:	e8 1b fd ff ff       	call   80104f1d <argptr>
80105202:	83 c4 10             	add    $0x10,%esp
80105205:	85 c0                	test   %eax,%eax
80105207:	79 07                	jns    80105210 <sys_write+0x52>
    return -1;
80105209:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010520e:	eb 17                	jmp    80105227 <sys_write+0x69>
  return filewrite(f, p, n);
80105210:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105213:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105216:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105219:	83 ec 04             	sub    $0x4,%esp
8010521c:	51                   	push   %ecx
8010521d:	52                   	push   %edx
8010521e:	50                   	push   %eax
8010521f:	e8 6e c0 ff ff       	call   80101292 <filewrite>
80105224:	83 c4 10             	add    $0x10,%esp
}
80105227:	c9                   	leave  
80105228:	c3                   	ret    

80105229 <sys_close>:

int
sys_close(void)
{
80105229:	55                   	push   %ebp
8010522a:	89 e5                	mov    %esp,%ebp
8010522c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
8010522f:	83 ec 04             	sub    $0x4,%esp
80105232:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105235:	50                   	push   %eax
80105236:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105239:	50                   	push   %eax
8010523a:	6a 00                	push   $0x0
8010523c:	e8 f9 fd ff ff       	call   8010503a <argfd>
80105241:	83 c4 10             	add    $0x10,%esp
80105244:	85 c0                	test   %eax,%eax
80105246:	79 07                	jns    8010524f <sys_close+0x26>
    return -1;
80105248:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010524d:	eb 27                	jmp    80105276 <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
8010524f:	e8 dc e7 ff ff       	call   80103a30 <myproc>
80105254:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105257:	83 c2 08             	add    $0x8,%edx
8010525a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105261:	00 
  fileclose(f);
80105262:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105265:	83 ec 0c             	sub    $0xc,%esp
80105268:	50                   	push   %eax
80105269:	e8 2d be ff ff       	call   8010109b <fileclose>
8010526e:	83 c4 10             	add    $0x10,%esp
  return 0;
80105271:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105276:	c9                   	leave  
80105277:	c3                   	ret    

80105278 <sys_fstat>:

int
sys_fstat(void)
{
80105278:	55                   	push   %ebp
80105279:	89 e5                	mov    %esp,%ebp
8010527b:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010527e:	83 ec 04             	sub    $0x4,%esp
80105281:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105284:	50                   	push   %eax
80105285:	6a 00                	push   $0x0
80105287:	6a 00                	push   $0x0
80105289:	e8 ac fd ff ff       	call   8010503a <argfd>
8010528e:	83 c4 10             	add    $0x10,%esp
80105291:	85 c0                	test   %eax,%eax
80105293:	78 17                	js     801052ac <sys_fstat+0x34>
80105295:	83 ec 04             	sub    $0x4,%esp
80105298:	6a 14                	push   $0x14
8010529a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010529d:	50                   	push   %eax
8010529e:	6a 01                	push   $0x1
801052a0:	e8 78 fc ff ff       	call   80104f1d <argptr>
801052a5:	83 c4 10             	add    $0x10,%esp
801052a8:	85 c0                	test   %eax,%eax
801052aa:	79 07                	jns    801052b3 <sys_fstat+0x3b>
    return -1;
801052ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052b1:	eb 13                	jmp    801052c6 <sys_fstat+0x4e>
  return filestat(f, st);
801052b3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801052b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052b9:	83 ec 08             	sub    $0x8,%esp
801052bc:	52                   	push   %edx
801052bd:	50                   	push   %eax
801052be:	e8 c0 be ff ff       	call   80101183 <filestat>
801052c3:	83 c4 10             	add    $0x10,%esp
}
801052c6:	c9                   	leave  
801052c7:	c3                   	ret    

801052c8 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801052c8:	55                   	push   %ebp
801052c9:	89 e5                	mov    %esp,%ebp
801052cb:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801052ce:	83 ec 08             	sub    $0x8,%esp
801052d1:	8d 45 d8             	lea    -0x28(%ebp),%eax
801052d4:	50                   	push   %eax
801052d5:	6a 00                	push   $0x0
801052d7:	e8 a9 fc ff ff       	call   80104f85 <argstr>
801052dc:	83 c4 10             	add    $0x10,%esp
801052df:	85 c0                	test   %eax,%eax
801052e1:	78 15                	js     801052f8 <sys_link+0x30>
801052e3:	83 ec 08             	sub    $0x8,%esp
801052e6:	8d 45 dc             	lea    -0x24(%ebp),%eax
801052e9:	50                   	push   %eax
801052ea:	6a 01                	push   $0x1
801052ec:	e8 94 fc ff ff       	call   80104f85 <argstr>
801052f1:	83 c4 10             	add    $0x10,%esp
801052f4:	85 c0                	test   %eax,%eax
801052f6:	79 0a                	jns    80105302 <sys_link+0x3a>
    return -1;
801052f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052fd:	e9 68 01 00 00       	jmp    8010546a <sys_link+0x1a2>

  begin_op();
80105302:	e8 35 dd ff ff       	call   8010303c <begin_op>
  if((ip = namei(old)) == 0){
80105307:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010530a:	83 ec 0c             	sub    $0xc,%esp
8010530d:	50                   	push   %eax
8010530e:	e8 0a d2 ff ff       	call   8010251d <namei>
80105313:	83 c4 10             	add    $0x10,%esp
80105316:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105319:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010531d:	75 0f                	jne    8010532e <sys_link+0x66>
    end_op();
8010531f:	e8 a4 dd ff ff       	call   801030c8 <end_op>
    return -1;
80105324:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105329:	e9 3c 01 00 00       	jmp    8010546a <sys_link+0x1a2>
  }

  ilock(ip);
8010532e:	83 ec 0c             	sub    $0xc,%esp
80105331:	ff 75 f4             	push   -0xc(%ebp)
80105334:	e8 b1 c6 ff ff       	call   801019ea <ilock>
80105339:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
8010533c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010533f:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105343:	66 83 f8 01          	cmp    $0x1,%ax
80105347:	75 1d                	jne    80105366 <sys_link+0x9e>
    iunlockput(ip);
80105349:	83 ec 0c             	sub    $0xc,%esp
8010534c:	ff 75 f4             	push   -0xc(%ebp)
8010534f:	e8 c7 c8 ff ff       	call   80101c1b <iunlockput>
80105354:	83 c4 10             	add    $0x10,%esp
    end_op();
80105357:	e8 6c dd ff ff       	call   801030c8 <end_op>
    return -1;
8010535c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105361:	e9 04 01 00 00       	jmp    8010546a <sys_link+0x1a2>
  }

  ip->nlink++;
80105366:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105369:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010536d:	83 c0 01             	add    $0x1,%eax
80105370:	89 c2                	mov    %eax,%edx
80105372:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105375:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105379:	83 ec 0c             	sub    $0xc,%esp
8010537c:	ff 75 f4             	push   -0xc(%ebp)
8010537f:	e8 89 c4 ff ff       	call   8010180d <iupdate>
80105384:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105387:	83 ec 0c             	sub    $0xc,%esp
8010538a:	ff 75 f4             	push   -0xc(%ebp)
8010538d:	e8 6b c7 ff ff       	call   80101afd <iunlock>
80105392:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105395:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105398:	83 ec 08             	sub    $0x8,%esp
8010539b:	8d 55 e2             	lea    -0x1e(%ebp),%edx
8010539e:	52                   	push   %edx
8010539f:	50                   	push   %eax
801053a0:	e8 94 d1 ff ff       	call   80102539 <nameiparent>
801053a5:	83 c4 10             	add    $0x10,%esp
801053a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801053ab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801053af:	74 71                	je     80105422 <sys_link+0x15a>
    goto bad;
  ilock(dp);
801053b1:	83 ec 0c             	sub    $0xc,%esp
801053b4:	ff 75 f0             	push   -0x10(%ebp)
801053b7:	e8 2e c6 ff ff       	call   801019ea <ilock>
801053bc:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801053bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053c2:	8b 10                	mov    (%eax),%edx
801053c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053c7:	8b 00                	mov    (%eax),%eax
801053c9:	39 c2                	cmp    %eax,%edx
801053cb:	75 1d                	jne    801053ea <sys_link+0x122>
801053cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053d0:	8b 40 04             	mov    0x4(%eax),%eax
801053d3:	83 ec 04             	sub    $0x4,%esp
801053d6:	50                   	push   %eax
801053d7:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801053da:	50                   	push   %eax
801053db:	ff 75 f0             	push   -0x10(%ebp)
801053de:	e8 a3 ce ff ff       	call   80102286 <dirlink>
801053e3:	83 c4 10             	add    $0x10,%esp
801053e6:	85 c0                	test   %eax,%eax
801053e8:	79 10                	jns    801053fa <sys_link+0x132>
    iunlockput(dp);
801053ea:	83 ec 0c             	sub    $0xc,%esp
801053ed:	ff 75 f0             	push   -0x10(%ebp)
801053f0:	e8 26 c8 ff ff       	call   80101c1b <iunlockput>
801053f5:	83 c4 10             	add    $0x10,%esp
    goto bad;
801053f8:	eb 29                	jmp    80105423 <sys_link+0x15b>
  }
  iunlockput(dp);
801053fa:	83 ec 0c             	sub    $0xc,%esp
801053fd:	ff 75 f0             	push   -0x10(%ebp)
80105400:	e8 16 c8 ff ff       	call   80101c1b <iunlockput>
80105405:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105408:	83 ec 0c             	sub    $0xc,%esp
8010540b:	ff 75 f4             	push   -0xc(%ebp)
8010540e:	e8 38 c7 ff ff       	call   80101b4b <iput>
80105413:	83 c4 10             	add    $0x10,%esp

  end_op();
80105416:	e8 ad dc ff ff       	call   801030c8 <end_op>

  return 0;
8010541b:	b8 00 00 00 00       	mov    $0x0,%eax
80105420:	eb 48                	jmp    8010546a <sys_link+0x1a2>
    goto bad;
80105422:	90                   	nop

bad:
  ilock(ip);
80105423:	83 ec 0c             	sub    $0xc,%esp
80105426:	ff 75 f4             	push   -0xc(%ebp)
80105429:	e8 bc c5 ff ff       	call   801019ea <ilock>
8010542e:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105431:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105434:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105438:	83 e8 01             	sub    $0x1,%eax
8010543b:	89 c2                	mov    %eax,%edx
8010543d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105440:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105444:	83 ec 0c             	sub    $0xc,%esp
80105447:	ff 75 f4             	push   -0xc(%ebp)
8010544a:	e8 be c3 ff ff       	call   8010180d <iupdate>
8010544f:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105452:	83 ec 0c             	sub    $0xc,%esp
80105455:	ff 75 f4             	push   -0xc(%ebp)
80105458:	e8 be c7 ff ff       	call   80101c1b <iunlockput>
8010545d:	83 c4 10             	add    $0x10,%esp
  end_op();
80105460:	e8 63 dc ff ff       	call   801030c8 <end_op>
  return -1;
80105465:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010546a:	c9                   	leave  
8010546b:	c3                   	ret    

8010546c <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010546c:	55                   	push   %ebp
8010546d:	89 e5                	mov    %esp,%ebp
8010546f:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105472:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105479:	eb 40                	jmp    801054bb <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010547b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010547e:	6a 10                	push   $0x10
80105480:	50                   	push   %eax
80105481:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105484:	50                   	push   %eax
80105485:	ff 75 08             	push   0x8(%ebp)
80105488:	e8 49 ca ff ff       	call   80101ed6 <readi>
8010548d:	83 c4 10             	add    $0x10,%esp
80105490:	83 f8 10             	cmp    $0x10,%eax
80105493:	74 0d                	je     801054a2 <isdirempty+0x36>
      panic("isdirempty: readi");
80105495:	83 ec 0c             	sub    $0xc,%esp
80105498:	68 14 a6 10 80       	push   $0x8010a614
8010549d:	e8 07 b1 ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
801054a2:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801054a6:	66 85 c0             	test   %ax,%ax
801054a9:	74 07                	je     801054b2 <isdirempty+0x46>
      return 0;
801054ab:	b8 00 00 00 00       	mov    $0x0,%eax
801054b0:	eb 1b                	jmp    801054cd <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801054b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054b5:	83 c0 10             	add    $0x10,%eax
801054b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801054bb:	8b 45 08             	mov    0x8(%ebp),%eax
801054be:	8b 50 58             	mov    0x58(%eax),%edx
801054c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054c4:	39 c2                	cmp    %eax,%edx
801054c6:	77 b3                	ja     8010547b <isdirempty+0xf>
  }
  return 1;
801054c8:	b8 01 00 00 00       	mov    $0x1,%eax
}
801054cd:	c9                   	leave  
801054ce:	c3                   	ret    

801054cf <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801054cf:	55                   	push   %ebp
801054d0:	89 e5                	mov    %esp,%ebp
801054d2:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801054d5:	83 ec 08             	sub    $0x8,%esp
801054d8:	8d 45 cc             	lea    -0x34(%ebp),%eax
801054db:	50                   	push   %eax
801054dc:	6a 00                	push   $0x0
801054de:	e8 a2 fa ff ff       	call   80104f85 <argstr>
801054e3:	83 c4 10             	add    $0x10,%esp
801054e6:	85 c0                	test   %eax,%eax
801054e8:	79 0a                	jns    801054f4 <sys_unlink+0x25>
    return -1;
801054ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054ef:	e9 bf 01 00 00       	jmp    801056b3 <sys_unlink+0x1e4>

  begin_op();
801054f4:	e8 43 db ff ff       	call   8010303c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801054f9:	8b 45 cc             	mov    -0x34(%ebp),%eax
801054fc:	83 ec 08             	sub    $0x8,%esp
801054ff:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105502:	52                   	push   %edx
80105503:	50                   	push   %eax
80105504:	e8 30 d0 ff ff       	call   80102539 <nameiparent>
80105509:	83 c4 10             	add    $0x10,%esp
8010550c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010550f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105513:	75 0f                	jne    80105524 <sys_unlink+0x55>
    end_op();
80105515:	e8 ae db ff ff       	call   801030c8 <end_op>
    return -1;
8010551a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010551f:	e9 8f 01 00 00       	jmp    801056b3 <sys_unlink+0x1e4>
  }

  ilock(dp);
80105524:	83 ec 0c             	sub    $0xc,%esp
80105527:	ff 75 f4             	push   -0xc(%ebp)
8010552a:	e8 bb c4 ff ff       	call   801019ea <ilock>
8010552f:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105532:	83 ec 08             	sub    $0x8,%esp
80105535:	68 26 a6 10 80       	push   $0x8010a626
8010553a:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010553d:	50                   	push   %eax
8010553e:	e8 6e cc ff ff       	call   801021b1 <namecmp>
80105543:	83 c4 10             	add    $0x10,%esp
80105546:	85 c0                	test   %eax,%eax
80105548:	0f 84 49 01 00 00    	je     80105697 <sys_unlink+0x1c8>
8010554e:	83 ec 08             	sub    $0x8,%esp
80105551:	68 28 a6 10 80       	push   $0x8010a628
80105556:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105559:	50                   	push   %eax
8010555a:	e8 52 cc ff ff       	call   801021b1 <namecmp>
8010555f:	83 c4 10             	add    $0x10,%esp
80105562:	85 c0                	test   %eax,%eax
80105564:	0f 84 2d 01 00 00    	je     80105697 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
8010556a:	83 ec 04             	sub    $0x4,%esp
8010556d:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105570:	50                   	push   %eax
80105571:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105574:	50                   	push   %eax
80105575:	ff 75 f4             	push   -0xc(%ebp)
80105578:	e8 4f cc ff ff       	call   801021cc <dirlookup>
8010557d:	83 c4 10             	add    $0x10,%esp
80105580:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105583:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105587:	0f 84 0d 01 00 00    	je     8010569a <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
8010558d:	83 ec 0c             	sub    $0xc,%esp
80105590:	ff 75 f0             	push   -0x10(%ebp)
80105593:	e8 52 c4 ff ff       	call   801019ea <ilock>
80105598:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
8010559b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010559e:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801055a2:	66 85 c0             	test   %ax,%ax
801055a5:	7f 0d                	jg     801055b4 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
801055a7:	83 ec 0c             	sub    $0xc,%esp
801055aa:	68 2b a6 10 80       	push   $0x8010a62b
801055af:	e8 f5 af ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801055b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055b7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801055bb:	66 83 f8 01          	cmp    $0x1,%ax
801055bf:	75 25                	jne    801055e6 <sys_unlink+0x117>
801055c1:	83 ec 0c             	sub    $0xc,%esp
801055c4:	ff 75 f0             	push   -0x10(%ebp)
801055c7:	e8 a0 fe ff ff       	call   8010546c <isdirempty>
801055cc:	83 c4 10             	add    $0x10,%esp
801055cf:	85 c0                	test   %eax,%eax
801055d1:	75 13                	jne    801055e6 <sys_unlink+0x117>
    iunlockput(ip);
801055d3:	83 ec 0c             	sub    $0xc,%esp
801055d6:	ff 75 f0             	push   -0x10(%ebp)
801055d9:	e8 3d c6 ff ff       	call   80101c1b <iunlockput>
801055de:	83 c4 10             	add    $0x10,%esp
    goto bad;
801055e1:	e9 b5 00 00 00       	jmp    8010569b <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
801055e6:	83 ec 04             	sub    $0x4,%esp
801055e9:	6a 10                	push   $0x10
801055eb:	6a 00                	push   $0x0
801055ed:	8d 45 e0             	lea    -0x20(%ebp),%eax
801055f0:	50                   	push   %eax
801055f1:	e8 cf f5 ff ff       	call   80104bc5 <memset>
801055f6:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801055f9:	8b 45 c8             	mov    -0x38(%ebp),%eax
801055fc:	6a 10                	push   $0x10
801055fe:	50                   	push   %eax
801055ff:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105602:	50                   	push   %eax
80105603:	ff 75 f4             	push   -0xc(%ebp)
80105606:	e8 20 ca ff ff       	call   8010202b <writei>
8010560b:	83 c4 10             	add    $0x10,%esp
8010560e:	83 f8 10             	cmp    $0x10,%eax
80105611:	74 0d                	je     80105620 <sys_unlink+0x151>
    panic("unlink: writei");
80105613:	83 ec 0c             	sub    $0xc,%esp
80105616:	68 3d a6 10 80       	push   $0x8010a63d
8010561b:	e8 89 af ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
80105620:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105623:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105627:	66 83 f8 01          	cmp    $0x1,%ax
8010562b:	75 21                	jne    8010564e <sys_unlink+0x17f>
    dp->nlink--;
8010562d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105630:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105634:	83 e8 01             	sub    $0x1,%eax
80105637:	89 c2                	mov    %eax,%edx
80105639:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010563c:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105640:	83 ec 0c             	sub    $0xc,%esp
80105643:	ff 75 f4             	push   -0xc(%ebp)
80105646:	e8 c2 c1 ff ff       	call   8010180d <iupdate>
8010564b:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
8010564e:	83 ec 0c             	sub    $0xc,%esp
80105651:	ff 75 f4             	push   -0xc(%ebp)
80105654:	e8 c2 c5 ff ff       	call   80101c1b <iunlockput>
80105659:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
8010565c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010565f:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105663:	83 e8 01             	sub    $0x1,%eax
80105666:	89 c2                	mov    %eax,%edx
80105668:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010566b:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010566f:	83 ec 0c             	sub    $0xc,%esp
80105672:	ff 75 f0             	push   -0x10(%ebp)
80105675:	e8 93 c1 ff ff       	call   8010180d <iupdate>
8010567a:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010567d:	83 ec 0c             	sub    $0xc,%esp
80105680:	ff 75 f0             	push   -0x10(%ebp)
80105683:	e8 93 c5 ff ff       	call   80101c1b <iunlockput>
80105688:	83 c4 10             	add    $0x10,%esp

  end_op();
8010568b:	e8 38 da ff ff       	call   801030c8 <end_op>

  return 0;
80105690:	b8 00 00 00 00       	mov    $0x0,%eax
80105695:	eb 1c                	jmp    801056b3 <sys_unlink+0x1e4>
    goto bad;
80105697:	90                   	nop
80105698:	eb 01                	jmp    8010569b <sys_unlink+0x1cc>
    goto bad;
8010569a:	90                   	nop

bad:
  iunlockput(dp);
8010569b:	83 ec 0c             	sub    $0xc,%esp
8010569e:	ff 75 f4             	push   -0xc(%ebp)
801056a1:	e8 75 c5 ff ff       	call   80101c1b <iunlockput>
801056a6:	83 c4 10             	add    $0x10,%esp
  end_op();
801056a9:	e8 1a da ff ff       	call   801030c8 <end_op>
  return -1;
801056ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801056b3:	c9                   	leave  
801056b4:	c3                   	ret    

801056b5 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801056b5:	55                   	push   %ebp
801056b6:	89 e5                	mov    %esp,%ebp
801056b8:	83 ec 38             	sub    $0x38,%esp
801056bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801056be:	8b 55 10             	mov    0x10(%ebp),%edx
801056c1:	8b 45 14             	mov    0x14(%ebp),%eax
801056c4:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801056c8:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801056cc:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801056d0:	83 ec 08             	sub    $0x8,%esp
801056d3:	8d 45 de             	lea    -0x22(%ebp),%eax
801056d6:	50                   	push   %eax
801056d7:	ff 75 08             	push   0x8(%ebp)
801056da:	e8 5a ce ff ff       	call   80102539 <nameiparent>
801056df:	83 c4 10             	add    $0x10,%esp
801056e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056e9:	75 0a                	jne    801056f5 <create+0x40>
    return 0;
801056eb:	b8 00 00 00 00       	mov    $0x0,%eax
801056f0:	e9 90 01 00 00       	jmp    80105885 <create+0x1d0>
  ilock(dp);
801056f5:	83 ec 0c             	sub    $0xc,%esp
801056f8:	ff 75 f4             	push   -0xc(%ebp)
801056fb:	e8 ea c2 ff ff       	call   801019ea <ilock>
80105700:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105703:	83 ec 04             	sub    $0x4,%esp
80105706:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105709:	50                   	push   %eax
8010570a:	8d 45 de             	lea    -0x22(%ebp),%eax
8010570d:	50                   	push   %eax
8010570e:	ff 75 f4             	push   -0xc(%ebp)
80105711:	e8 b6 ca ff ff       	call   801021cc <dirlookup>
80105716:	83 c4 10             	add    $0x10,%esp
80105719:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010571c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105720:	74 50                	je     80105772 <create+0xbd>
    iunlockput(dp);
80105722:	83 ec 0c             	sub    $0xc,%esp
80105725:	ff 75 f4             	push   -0xc(%ebp)
80105728:	e8 ee c4 ff ff       	call   80101c1b <iunlockput>
8010572d:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105730:	83 ec 0c             	sub    $0xc,%esp
80105733:	ff 75 f0             	push   -0x10(%ebp)
80105736:	e8 af c2 ff ff       	call   801019ea <ilock>
8010573b:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
8010573e:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105743:	75 15                	jne    8010575a <create+0xa5>
80105745:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105748:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010574c:	66 83 f8 02          	cmp    $0x2,%ax
80105750:	75 08                	jne    8010575a <create+0xa5>
      return ip;
80105752:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105755:	e9 2b 01 00 00       	jmp    80105885 <create+0x1d0>
    iunlockput(ip);
8010575a:	83 ec 0c             	sub    $0xc,%esp
8010575d:	ff 75 f0             	push   -0x10(%ebp)
80105760:	e8 b6 c4 ff ff       	call   80101c1b <iunlockput>
80105765:	83 c4 10             	add    $0x10,%esp
    return 0;
80105768:	b8 00 00 00 00       	mov    $0x0,%eax
8010576d:	e9 13 01 00 00       	jmp    80105885 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105772:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105776:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105779:	8b 00                	mov    (%eax),%eax
8010577b:	83 ec 08             	sub    $0x8,%esp
8010577e:	52                   	push   %edx
8010577f:	50                   	push   %eax
80105780:	e8 b1 bf ff ff       	call   80101736 <ialloc>
80105785:	83 c4 10             	add    $0x10,%esp
80105788:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010578b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010578f:	75 0d                	jne    8010579e <create+0xe9>
    panic("create: ialloc");
80105791:	83 ec 0c             	sub    $0xc,%esp
80105794:	68 4c a6 10 80       	push   $0x8010a64c
80105799:	e8 0b ae ff ff       	call   801005a9 <panic>

  ilock(ip);
8010579e:	83 ec 0c             	sub    $0xc,%esp
801057a1:	ff 75 f0             	push   -0x10(%ebp)
801057a4:	e8 41 c2 ff ff       	call   801019ea <ilock>
801057a9:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801057ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057af:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801057b3:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
801057b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057ba:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801057be:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
801057c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057c5:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
801057cb:	83 ec 0c             	sub    $0xc,%esp
801057ce:	ff 75 f0             	push   -0x10(%ebp)
801057d1:	e8 37 c0 ff ff       	call   8010180d <iupdate>
801057d6:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801057d9:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801057de:	75 6a                	jne    8010584a <create+0x195>
    dp->nlink++;  // for ".."
801057e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057e3:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801057e7:	83 c0 01             	add    $0x1,%eax
801057ea:	89 c2                	mov    %eax,%edx
801057ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057ef:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801057f3:	83 ec 0c             	sub    $0xc,%esp
801057f6:	ff 75 f4             	push   -0xc(%ebp)
801057f9:	e8 0f c0 ff ff       	call   8010180d <iupdate>
801057fe:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105801:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105804:	8b 40 04             	mov    0x4(%eax),%eax
80105807:	83 ec 04             	sub    $0x4,%esp
8010580a:	50                   	push   %eax
8010580b:	68 26 a6 10 80       	push   $0x8010a626
80105810:	ff 75 f0             	push   -0x10(%ebp)
80105813:	e8 6e ca ff ff       	call   80102286 <dirlink>
80105818:	83 c4 10             	add    $0x10,%esp
8010581b:	85 c0                	test   %eax,%eax
8010581d:	78 1e                	js     8010583d <create+0x188>
8010581f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105822:	8b 40 04             	mov    0x4(%eax),%eax
80105825:	83 ec 04             	sub    $0x4,%esp
80105828:	50                   	push   %eax
80105829:	68 28 a6 10 80       	push   $0x8010a628
8010582e:	ff 75 f0             	push   -0x10(%ebp)
80105831:	e8 50 ca ff ff       	call   80102286 <dirlink>
80105836:	83 c4 10             	add    $0x10,%esp
80105839:	85 c0                	test   %eax,%eax
8010583b:	79 0d                	jns    8010584a <create+0x195>
      panic("create dots");
8010583d:	83 ec 0c             	sub    $0xc,%esp
80105840:	68 5b a6 10 80       	push   $0x8010a65b
80105845:	e8 5f ad ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
8010584a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010584d:	8b 40 04             	mov    0x4(%eax),%eax
80105850:	83 ec 04             	sub    $0x4,%esp
80105853:	50                   	push   %eax
80105854:	8d 45 de             	lea    -0x22(%ebp),%eax
80105857:	50                   	push   %eax
80105858:	ff 75 f4             	push   -0xc(%ebp)
8010585b:	e8 26 ca ff ff       	call   80102286 <dirlink>
80105860:	83 c4 10             	add    $0x10,%esp
80105863:	85 c0                	test   %eax,%eax
80105865:	79 0d                	jns    80105874 <create+0x1bf>
    panic("create: dirlink");
80105867:	83 ec 0c             	sub    $0xc,%esp
8010586a:	68 67 a6 10 80       	push   $0x8010a667
8010586f:	e8 35 ad ff ff       	call   801005a9 <panic>

  iunlockput(dp);
80105874:	83 ec 0c             	sub    $0xc,%esp
80105877:	ff 75 f4             	push   -0xc(%ebp)
8010587a:	e8 9c c3 ff ff       	call   80101c1b <iunlockput>
8010587f:	83 c4 10             	add    $0x10,%esp

  return ip;
80105882:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105885:	c9                   	leave  
80105886:	c3                   	ret    

80105887 <sys_open>:

int
sys_open(void)
{
80105887:	55                   	push   %ebp
80105888:	89 e5                	mov    %esp,%ebp
8010588a:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010588d:	83 ec 08             	sub    $0x8,%esp
80105890:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105893:	50                   	push   %eax
80105894:	6a 00                	push   $0x0
80105896:	e8 ea f6 ff ff       	call   80104f85 <argstr>
8010589b:	83 c4 10             	add    $0x10,%esp
8010589e:	85 c0                	test   %eax,%eax
801058a0:	78 15                	js     801058b7 <sys_open+0x30>
801058a2:	83 ec 08             	sub    $0x8,%esp
801058a5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801058a8:	50                   	push   %eax
801058a9:	6a 01                	push   $0x1
801058ab:	e8 40 f6 ff ff       	call   80104ef0 <argint>
801058b0:	83 c4 10             	add    $0x10,%esp
801058b3:	85 c0                	test   %eax,%eax
801058b5:	79 0a                	jns    801058c1 <sys_open+0x3a>
    return -1;
801058b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058bc:	e9 61 01 00 00       	jmp    80105a22 <sys_open+0x19b>

  begin_op();
801058c1:	e8 76 d7 ff ff       	call   8010303c <begin_op>

  if(omode & O_CREATE){
801058c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801058c9:	25 00 02 00 00       	and    $0x200,%eax
801058ce:	85 c0                	test   %eax,%eax
801058d0:	74 2a                	je     801058fc <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
801058d2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801058d5:	6a 00                	push   $0x0
801058d7:	6a 00                	push   $0x0
801058d9:	6a 02                	push   $0x2
801058db:	50                   	push   %eax
801058dc:	e8 d4 fd ff ff       	call   801056b5 <create>
801058e1:	83 c4 10             	add    $0x10,%esp
801058e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801058e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058eb:	75 75                	jne    80105962 <sys_open+0xdb>
      end_op();
801058ed:	e8 d6 d7 ff ff       	call   801030c8 <end_op>
      return -1;
801058f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058f7:	e9 26 01 00 00       	jmp    80105a22 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
801058fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801058ff:	83 ec 0c             	sub    $0xc,%esp
80105902:	50                   	push   %eax
80105903:	e8 15 cc ff ff       	call   8010251d <namei>
80105908:	83 c4 10             	add    $0x10,%esp
8010590b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010590e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105912:	75 0f                	jne    80105923 <sys_open+0x9c>
      end_op();
80105914:	e8 af d7 ff ff       	call   801030c8 <end_op>
      return -1;
80105919:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010591e:	e9 ff 00 00 00       	jmp    80105a22 <sys_open+0x19b>
    }
    ilock(ip);
80105923:	83 ec 0c             	sub    $0xc,%esp
80105926:	ff 75 f4             	push   -0xc(%ebp)
80105929:	e8 bc c0 ff ff       	call   801019ea <ilock>
8010592e:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105931:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105934:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105938:	66 83 f8 01          	cmp    $0x1,%ax
8010593c:	75 24                	jne    80105962 <sys_open+0xdb>
8010593e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105941:	85 c0                	test   %eax,%eax
80105943:	74 1d                	je     80105962 <sys_open+0xdb>
      iunlockput(ip);
80105945:	83 ec 0c             	sub    $0xc,%esp
80105948:	ff 75 f4             	push   -0xc(%ebp)
8010594b:	e8 cb c2 ff ff       	call   80101c1b <iunlockput>
80105950:	83 c4 10             	add    $0x10,%esp
      end_op();
80105953:	e8 70 d7 ff ff       	call   801030c8 <end_op>
      return -1;
80105958:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010595d:	e9 c0 00 00 00       	jmp    80105a22 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105962:	e8 76 b6 ff ff       	call   80100fdd <filealloc>
80105967:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010596a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010596e:	74 17                	je     80105987 <sys_open+0x100>
80105970:	83 ec 0c             	sub    $0xc,%esp
80105973:	ff 75 f0             	push   -0x10(%ebp)
80105976:	e8 33 f7 ff ff       	call   801050ae <fdalloc>
8010597b:	83 c4 10             	add    $0x10,%esp
8010597e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105981:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105985:	79 2e                	jns    801059b5 <sys_open+0x12e>
    if(f)
80105987:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010598b:	74 0e                	je     8010599b <sys_open+0x114>
      fileclose(f);
8010598d:	83 ec 0c             	sub    $0xc,%esp
80105990:	ff 75 f0             	push   -0x10(%ebp)
80105993:	e8 03 b7 ff ff       	call   8010109b <fileclose>
80105998:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010599b:	83 ec 0c             	sub    $0xc,%esp
8010599e:	ff 75 f4             	push   -0xc(%ebp)
801059a1:	e8 75 c2 ff ff       	call   80101c1b <iunlockput>
801059a6:	83 c4 10             	add    $0x10,%esp
    end_op();
801059a9:	e8 1a d7 ff ff       	call   801030c8 <end_op>
    return -1;
801059ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059b3:	eb 6d                	jmp    80105a22 <sys_open+0x19b>
  }
  iunlock(ip);
801059b5:	83 ec 0c             	sub    $0xc,%esp
801059b8:	ff 75 f4             	push   -0xc(%ebp)
801059bb:	e8 3d c1 ff ff       	call   80101afd <iunlock>
801059c0:	83 c4 10             	add    $0x10,%esp
  end_op();
801059c3:	e8 00 d7 ff ff       	call   801030c8 <end_op>

  f->type = FD_INODE;
801059c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059cb:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801059d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801059d7:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801059da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059dd:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801059e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801059e7:	83 e0 01             	and    $0x1,%eax
801059ea:	85 c0                	test   %eax,%eax
801059ec:	0f 94 c0             	sete   %al
801059ef:	89 c2                	mov    %eax,%edx
801059f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059f4:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801059f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801059fa:	83 e0 01             	and    $0x1,%eax
801059fd:	85 c0                	test   %eax,%eax
801059ff:	75 0a                	jne    80105a0b <sys_open+0x184>
80105a01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105a04:	83 e0 02             	and    $0x2,%eax
80105a07:	85 c0                	test   %eax,%eax
80105a09:	74 07                	je     80105a12 <sys_open+0x18b>
80105a0b:	b8 01 00 00 00       	mov    $0x1,%eax
80105a10:	eb 05                	jmp    80105a17 <sys_open+0x190>
80105a12:	b8 00 00 00 00       	mov    $0x0,%eax
80105a17:	89 c2                	mov    %eax,%edx
80105a19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a1c:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105a1f:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105a22:	c9                   	leave  
80105a23:	c3                   	ret    

80105a24 <sys_mkdir>:

int
sys_mkdir(void)
{
80105a24:	55                   	push   %ebp
80105a25:	89 e5                	mov    %esp,%ebp
80105a27:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105a2a:	e8 0d d6 ff ff       	call   8010303c <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105a2f:	83 ec 08             	sub    $0x8,%esp
80105a32:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a35:	50                   	push   %eax
80105a36:	6a 00                	push   $0x0
80105a38:	e8 48 f5 ff ff       	call   80104f85 <argstr>
80105a3d:	83 c4 10             	add    $0x10,%esp
80105a40:	85 c0                	test   %eax,%eax
80105a42:	78 1b                	js     80105a5f <sys_mkdir+0x3b>
80105a44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a47:	6a 00                	push   $0x0
80105a49:	6a 00                	push   $0x0
80105a4b:	6a 01                	push   $0x1
80105a4d:	50                   	push   %eax
80105a4e:	e8 62 fc ff ff       	call   801056b5 <create>
80105a53:	83 c4 10             	add    $0x10,%esp
80105a56:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a59:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a5d:	75 0c                	jne    80105a6b <sys_mkdir+0x47>
    end_op();
80105a5f:	e8 64 d6 ff ff       	call   801030c8 <end_op>
    return -1;
80105a64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a69:	eb 18                	jmp    80105a83 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80105a6b:	83 ec 0c             	sub    $0xc,%esp
80105a6e:	ff 75 f4             	push   -0xc(%ebp)
80105a71:	e8 a5 c1 ff ff       	call   80101c1b <iunlockput>
80105a76:	83 c4 10             	add    $0x10,%esp
  end_op();
80105a79:	e8 4a d6 ff ff       	call   801030c8 <end_op>
  return 0;
80105a7e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a83:	c9                   	leave  
80105a84:	c3                   	ret    

80105a85 <sys_mknod>:

int
sys_mknod(void)
{
80105a85:	55                   	push   %ebp
80105a86:	89 e5                	mov    %esp,%ebp
80105a88:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105a8b:	e8 ac d5 ff ff       	call   8010303c <begin_op>
  if((argstr(0, &path)) < 0 ||
80105a90:	83 ec 08             	sub    $0x8,%esp
80105a93:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a96:	50                   	push   %eax
80105a97:	6a 00                	push   $0x0
80105a99:	e8 e7 f4 ff ff       	call   80104f85 <argstr>
80105a9e:	83 c4 10             	add    $0x10,%esp
80105aa1:	85 c0                	test   %eax,%eax
80105aa3:	78 4f                	js     80105af4 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80105aa5:	83 ec 08             	sub    $0x8,%esp
80105aa8:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105aab:	50                   	push   %eax
80105aac:	6a 01                	push   $0x1
80105aae:	e8 3d f4 ff ff       	call   80104ef0 <argint>
80105ab3:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105ab6:	85 c0                	test   %eax,%eax
80105ab8:	78 3a                	js     80105af4 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
80105aba:	83 ec 08             	sub    $0x8,%esp
80105abd:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105ac0:	50                   	push   %eax
80105ac1:	6a 02                	push   $0x2
80105ac3:	e8 28 f4 ff ff       	call   80104ef0 <argint>
80105ac8:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105acb:	85 c0                	test   %eax,%eax
80105acd:	78 25                	js     80105af4 <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105acf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ad2:	0f bf c8             	movswl %ax,%ecx
80105ad5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105ad8:	0f bf d0             	movswl %ax,%edx
80105adb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ade:	51                   	push   %ecx
80105adf:	52                   	push   %edx
80105ae0:	6a 03                	push   $0x3
80105ae2:	50                   	push   %eax
80105ae3:	e8 cd fb ff ff       	call   801056b5 <create>
80105ae8:	83 c4 10             	add    $0x10,%esp
80105aeb:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105aee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105af2:	75 0c                	jne    80105b00 <sys_mknod+0x7b>
    end_op();
80105af4:	e8 cf d5 ff ff       	call   801030c8 <end_op>
    return -1;
80105af9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105afe:	eb 18                	jmp    80105b18 <sys_mknod+0x93>
  }
  iunlockput(ip);
80105b00:	83 ec 0c             	sub    $0xc,%esp
80105b03:	ff 75 f4             	push   -0xc(%ebp)
80105b06:	e8 10 c1 ff ff       	call   80101c1b <iunlockput>
80105b0b:	83 c4 10             	add    $0x10,%esp
  end_op();
80105b0e:	e8 b5 d5 ff ff       	call   801030c8 <end_op>
  return 0;
80105b13:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b18:	c9                   	leave  
80105b19:	c3                   	ret    

80105b1a <sys_chdir>:

int
sys_chdir(void)
{
80105b1a:	55                   	push   %ebp
80105b1b:	89 e5                	mov    %esp,%ebp
80105b1d:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105b20:	e8 0b df ff ff       	call   80103a30 <myproc>
80105b25:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105b28:	e8 0f d5 ff ff       	call   8010303c <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105b2d:	83 ec 08             	sub    $0x8,%esp
80105b30:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b33:	50                   	push   %eax
80105b34:	6a 00                	push   $0x0
80105b36:	e8 4a f4 ff ff       	call   80104f85 <argstr>
80105b3b:	83 c4 10             	add    $0x10,%esp
80105b3e:	85 c0                	test   %eax,%eax
80105b40:	78 18                	js     80105b5a <sys_chdir+0x40>
80105b42:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105b45:	83 ec 0c             	sub    $0xc,%esp
80105b48:	50                   	push   %eax
80105b49:	e8 cf c9 ff ff       	call   8010251d <namei>
80105b4e:	83 c4 10             	add    $0x10,%esp
80105b51:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b54:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b58:	75 0c                	jne    80105b66 <sys_chdir+0x4c>
    end_op();
80105b5a:	e8 69 d5 ff ff       	call   801030c8 <end_op>
    return -1;
80105b5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b64:	eb 68                	jmp    80105bce <sys_chdir+0xb4>
  }
  ilock(ip);
80105b66:	83 ec 0c             	sub    $0xc,%esp
80105b69:	ff 75 f0             	push   -0x10(%ebp)
80105b6c:	e8 79 be ff ff       	call   801019ea <ilock>
80105b71:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105b74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b77:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105b7b:	66 83 f8 01          	cmp    $0x1,%ax
80105b7f:	74 1a                	je     80105b9b <sys_chdir+0x81>
    iunlockput(ip);
80105b81:	83 ec 0c             	sub    $0xc,%esp
80105b84:	ff 75 f0             	push   -0x10(%ebp)
80105b87:	e8 8f c0 ff ff       	call   80101c1b <iunlockput>
80105b8c:	83 c4 10             	add    $0x10,%esp
    end_op();
80105b8f:	e8 34 d5 ff ff       	call   801030c8 <end_op>
    return -1;
80105b94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b99:	eb 33                	jmp    80105bce <sys_chdir+0xb4>
  }
  iunlock(ip);
80105b9b:	83 ec 0c             	sub    $0xc,%esp
80105b9e:	ff 75 f0             	push   -0x10(%ebp)
80105ba1:	e8 57 bf ff ff       	call   80101afd <iunlock>
80105ba6:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bac:	8b 40 68             	mov    0x68(%eax),%eax
80105baf:	83 ec 0c             	sub    $0xc,%esp
80105bb2:	50                   	push   %eax
80105bb3:	e8 93 bf ff ff       	call   80101b4b <iput>
80105bb8:	83 c4 10             	add    $0x10,%esp
  end_op();
80105bbb:	e8 08 d5 ff ff       	call   801030c8 <end_op>
  curproc->cwd = ip;
80105bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bc3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105bc6:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105bc9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105bce:	c9                   	leave  
80105bcf:	c3                   	ret    

80105bd0 <sys_exec>:

int
sys_exec(void)
{
80105bd0:	55                   	push   %ebp
80105bd1:	89 e5                	mov    %esp,%ebp
80105bd3:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105bd9:	83 ec 08             	sub    $0x8,%esp
80105bdc:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bdf:	50                   	push   %eax
80105be0:	6a 00                	push   $0x0
80105be2:	e8 9e f3 ff ff       	call   80104f85 <argstr>
80105be7:	83 c4 10             	add    $0x10,%esp
80105bea:	85 c0                	test   %eax,%eax
80105bec:	78 18                	js     80105c06 <sys_exec+0x36>
80105bee:	83 ec 08             	sub    $0x8,%esp
80105bf1:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105bf7:	50                   	push   %eax
80105bf8:	6a 01                	push   $0x1
80105bfa:	e8 f1 f2 ff ff       	call   80104ef0 <argint>
80105bff:	83 c4 10             	add    $0x10,%esp
80105c02:	85 c0                	test   %eax,%eax
80105c04:	79 0a                	jns    80105c10 <sys_exec+0x40>
    return -1;
80105c06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c0b:	e9 c6 00 00 00       	jmp    80105cd6 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80105c10:	83 ec 04             	sub    $0x4,%esp
80105c13:	68 80 00 00 00       	push   $0x80
80105c18:	6a 00                	push   $0x0
80105c1a:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105c20:	50                   	push   %eax
80105c21:	e8 9f ef ff ff       	call   80104bc5 <memset>
80105c26:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105c29:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105c30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c33:	83 f8 1f             	cmp    $0x1f,%eax
80105c36:	76 0a                	jbe    80105c42 <sys_exec+0x72>
      return -1;
80105c38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c3d:	e9 94 00 00 00       	jmp    80105cd6 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c45:	c1 e0 02             	shl    $0x2,%eax
80105c48:	89 c2                	mov    %eax,%edx
80105c4a:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105c50:	01 c2                	add    %eax,%edx
80105c52:	83 ec 08             	sub    $0x8,%esp
80105c55:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105c5b:	50                   	push   %eax
80105c5c:	52                   	push   %edx
80105c5d:	e8 ed f1 ff ff       	call   80104e4f <fetchint>
80105c62:	83 c4 10             	add    $0x10,%esp
80105c65:	85 c0                	test   %eax,%eax
80105c67:	79 07                	jns    80105c70 <sys_exec+0xa0>
      return -1;
80105c69:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c6e:	eb 66                	jmp    80105cd6 <sys_exec+0x106>
    if(uarg == 0){
80105c70:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105c76:	85 c0                	test   %eax,%eax
80105c78:	75 27                	jne    80105ca1 <sys_exec+0xd1>
      argv[i] = 0;
80105c7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c7d:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105c84:	00 00 00 00 
      break;
80105c88:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105c89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c8c:	83 ec 08             	sub    $0x8,%esp
80105c8f:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105c95:	52                   	push   %edx
80105c96:	50                   	push   %eax
80105c97:	e8 e4 ae ff ff       	call   80100b80 <exec>
80105c9c:	83 c4 10             	add    $0x10,%esp
80105c9f:	eb 35                	jmp    80105cd6 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105ca1:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105caa:	c1 e0 02             	shl    $0x2,%eax
80105cad:	01 c2                	add    %eax,%edx
80105caf:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105cb5:	83 ec 08             	sub    $0x8,%esp
80105cb8:	52                   	push   %edx
80105cb9:	50                   	push   %eax
80105cba:	e8 cf f1 ff ff       	call   80104e8e <fetchstr>
80105cbf:	83 c4 10             	add    $0x10,%esp
80105cc2:	85 c0                	test   %eax,%eax
80105cc4:	79 07                	jns    80105ccd <sys_exec+0xfd>
      return -1;
80105cc6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ccb:	eb 09                	jmp    80105cd6 <sys_exec+0x106>
  for(i=0;; i++){
80105ccd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105cd1:	e9 5a ff ff ff       	jmp    80105c30 <sys_exec+0x60>
}
80105cd6:	c9                   	leave  
80105cd7:	c3                   	ret    

80105cd8 <sys_pipe>:

int
sys_pipe(void)
{
80105cd8:	55                   	push   %ebp
80105cd9:	89 e5                	mov    %esp,%ebp
80105cdb:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105cde:	83 ec 04             	sub    $0x4,%esp
80105ce1:	6a 08                	push   $0x8
80105ce3:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ce6:	50                   	push   %eax
80105ce7:	6a 00                	push   $0x0
80105ce9:	e8 2f f2 ff ff       	call   80104f1d <argptr>
80105cee:	83 c4 10             	add    $0x10,%esp
80105cf1:	85 c0                	test   %eax,%eax
80105cf3:	79 0a                	jns    80105cff <sys_pipe+0x27>
    return -1;
80105cf5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cfa:	e9 ae 00 00 00       	jmp    80105dad <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105cff:	83 ec 08             	sub    $0x8,%esp
80105d02:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105d05:	50                   	push   %eax
80105d06:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105d09:	50                   	push   %eax
80105d0a:	e8 5e d8 ff ff       	call   8010356d <pipealloc>
80105d0f:	83 c4 10             	add    $0x10,%esp
80105d12:	85 c0                	test   %eax,%eax
80105d14:	79 0a                	jns    80105d20 <sys_pipe+0x48>
    return -1;
80105d16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d1b:	e9 8d 00 00 00       	jmp    80105dad <sys_pipe+0xd5>
  fd0 = -1;
80105d20:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105d27:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d2a:	83 ec 0c             	sub    $0xc,%esp
80105d2d:	50                   	push   %eax
80105d2e:	e8 7b f3 ff ff       	call   801050ae <fdalloc>
80105d33:	83 c4 10             	add    $0x10,%esp
80105d36:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d39:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d3d:	78 18                	js     80105d57 <sys_pipe+0x7f>
80105d3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d42:	83 ec 0c             	sub    $0xc,%esp
80105d45:	50                   	push   %eax
80105d46:	e8 63 f3 ff ff       	call   801050ae <fdalloc>
80105d4b:	83 c4 10             	add    $0x10,%esp
80105d4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d51:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d55:	79 3e                	jns    80105d95 <sys_pipe+0xbd>
    if(fd0 >= 0)
80105d57:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d5b:	78 13                	js     80105d70 <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105d5d:	e8 ce dc ff ff       	call   80103a30 <myproc>
80105d62:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d65:	83 c2 08             	add    $0x8,%edx
80105d68:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105d6f:	00 
    fileclose(rf);
80105d70:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d73:	83 ec 0c             	sub    $0xc,%esp
80105d76:	50                   	push   %eax
80105d77:	e8 1f b3 ff ff       	call   8010109b <fileclose>
80105d7c:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105d7f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d82:	83 ec 0c             	sub    $0xc,%esp
80105d85:	50                   	push   %eax
80105d86:	e8 10 b3 ff ff       	call   8010109b <fileclose>
80105d8b:	83 c4 10             	add    $0x10,%esp
    return -1;
80105d8e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d93:	eb 18                	jmp    80105dad <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80105d95:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105d98:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d9b:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105d9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105da0:	8d 50 04             	lea    0x4(%eax),%edx
80105da3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105da6:	89 02                	mov    %eax,(%edx)
  return 0;
80105da8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105dad:	c9                   	leave  
80105dae:	c3                   	ret    

80105daf <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80105daf:	55                   	push   %ebp
80105db0:	89 e5                	mov    %esp,%ebp
80105db2:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105db5:	e8 75 df ff ff       	call   80103d2f <fork>
}
80105dba:	c9                   	leave  
80105dbb:	c3                   	ret    

80105dbc <sys_exit>:

int
sys_exit(void)
{
80105dbc:	55                   	push   %ebp
80105dbd:	89 e5                	mov    %esp,%ebp
80105dbf:	83 ec 08             	sub    $0x8,%esp
  exit();
80105dc2:	e8 e1 e0 ff ff       	call   80103ea8 <exit>
  return 0;  // not reached
80105dc7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105dcc:	c9                   	leave  
80105dcd:	c3                   	ret    

80105dce <sys_wait>:

int
sys_wait(void)
{
80105dce:	55                   	push   %ebp
80105dcf:	89 e5                	mov    %esp,%ebp
80105dd1:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105dd4:	e8 1b e3 ff ff       	call   801040f4 <wait>
}
80105dd9:	c9                   	leave  
80105dda:	c3                   	ret    

80105ddb <sys_kill>:

int
sys_kill(void)
{
80105ddb:	55                   	push   %ebp
80105ddc:	89 e5                	mov    %esp,%ebp
80105dde:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105de1:	83 ec 08             	sub    $0x8,%esp
80105de4:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105de7:	50                   	push   %eax
80105de8:	6a 00                	push   $0x0
80105dea:	e8 01 f1 ff ff       	call   80104ef0 <argint>
80105def:	83 c4 10             	add    $0x10,%esp
80105df2:	85 c0                	test   %eax,%eax
80105df4:	79 07                	jns    80105dfd <sys_kill+0x22>
    return -1;
80105df6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dfb:	eb 0f                	jmp    80105e0c <sys_kill+0x31>
  return kill(pid);
80105dfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e00:	83 ec 0c             	sub    $0xc,%esp
80105e03:	50                   	push   %eax
80105e04:	e8 49 e8 ff ff       	call   80104652 <kill>
80105e09:	83 c4 10             	add    $0x10,%esp
}
80105e0c:	c9                   	leave  
80105e0d:	c3                   	ret    

80105e0e <sys_getpid>:

int
sys_getpid(void)
{
80105e0e:	55                   	push   %ebp
80105e0f:	89 e5                	mov    %esp,%ebp
80105e11:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105e14:	e8 17 dc ff ff       	call   80103a30 <myproc>
80105e19:	8b 40 10             	mov    0x10(%eax),%eax
}
80105e1c:	c9                   	leave  
80105e1d:	c3                   	ret    

80105e1e <sys_sbrk>:

int
sys_sbrk(void)
{
80105e1e:	55                   	push   %ebp
80105e1f:	89 e5                	mov    %esp,%ebp
80105e21:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105e24:	83 ec 08             	sub    $0x8,%esp
80105e27:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e2a:	50                   	push   %eax
80105e2b:	6a 00                	push   $0x0
80105e2d:	e8 be f0 ff ff       	call   80104ef0 <argint>
80105e32:	83 c4 10             	add    $0x10,%esp
80105e35:	85 c0                	test   %eax,%eax
80105e37:	79 07                	jns    80105e40 <sys_sbrk+0x22>
    return -1;
80105e39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e3e:	eb 27                	jmp    80105e67 <sys_sbrk+0x49>
  addr = myproc()->sz;
80105e40:	e8 eb db ff ff       	call   80103a30 <myproc>
80105e45:	8b 00                	mov    (%eax),%eax
80105e47:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80105e4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e4d:	83 ec 0c             	sub    $0xc,%esp
80105e50:	50                   	push   %eax
80105e51:	e8 3e de ff ff       	call   80103c94 <growproc>
80105e56:	83 c4 10             	add    $0x10,%esp
80105e59:	85 c0                	test   %eax,%eax
80105e5b:	79 07                	jns    80105e64 <sys_sbrk+0x46>
    return -1;
80105e5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e62:	eb 03                	jmp    80105e67 <sys_sbrk+0x49>
  return addr;
80105e64:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105e67:	c9                   	leave  
80105e68:	c3                   	ret    

80105e69 <sys_sleep>:

int
sys_sleep(void)
{
80105e69:	55                   	push   %ebp
80105e6a:	89 e5                	mov    %esp,%ebp
80105e6c:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105e6f:	83 ec 08             	sub    $0x8,%esp
80105e72:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e75:	50                   	push   %eax
80105e76:	6a 00                	push   $0x0
80105e78:	e8 73 f0 ff ff       	call   80104ef0 <argint>
80105e7d:	83 c4 10             	add    $0x10,%esp
80105e80:	85 c0                	test   %eax,%eax
80105e82:	79 07                	jns    80105e8b <sys_sleep+0x22>
    return -1;
80105e84:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e89:	eb 76                	jmp    80105f01 <sys_sleep+0x98>
  acquire(&tickslock);
80105e8b:	83 ec 0c             	sub    $0xc,%esp
80105e8e:	68 40 6a 19 80       	push   $0x80196a40
80105e93:	e8 b7 ea ff ff       	call   8010494f <acquire>
80105e98:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80105e9b:	a1 74 6a 19 80       	mov    0x80196a74,%eax
80105ea0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80105ea3:	eb 38                	jmp    80105edd <sys_sleep+0x74>
    if(myproc()->killed){
80105ea5:	e8 86 db ff ff       	call   80103a30 <myproc>
80105eaa:	8b 40 24             	mov    0x24(%eax),%eax
80105ead:	85 c0                	test   %eax,%eax
80105eaf:	74 17                	je     80105ec8 <sys_sleep+0x5f>
      release(&tickslock);
80105eb1:	83 ec 0c             	sub    $0xc,%esp
80105eb4:	68 40 6a 19 80       	push   $0x80196a40
80105eb9:	e8 ff ea ff ff       	call   801049bd <release>
80105ebe:	83 c4 10             	add    $0x10,%esp
      return -1;
80105ec1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ec6:	eb 39                	jmp    80105f01 <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80105ec8:	83 ec 08             	sub    $0x8,%esp
80105ecb:	68 40 6a 19 80       	push   $0x80196a40
80105ed0:	68 74 6a 19 80       	push   $0x80196a74
80105ed5:	e8 5a e6 ff ff       	call   80104534 <sleep>
80105eda:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80105edd:	a1 74 6a 19 80       	mov    0x80196a74,%eax
80105ee2:	2b 45 f4             	sub    -0xc(%ebp),%eax
80105ee5:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ee8:	39 d0                	cmp    %edx,%eax
80105eea:	72 b9                	jb     80105ea5 <sys_sleep+0x3c>
  }
  release(&tickslock);
80105eec:	83 ec 0c             	sub    $0xc,%esp
80105eef:	68 40 6a 19 80       	push   $0x80196a40
80105ef4:	e8 c4 ea ff ff       	call   801049bd <release>
80105ef9:	83 c4 10             	add    $0x10,%esp
  return 0;
80105efc:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f01:	c9                   	leave  
80105f02:	c3                   	ret    

80105f03 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105f03:	55                   	push   %ebp
80105f04:	89 e5                	mov    %esp,%ebp
80105f06:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80105f09:	83 ec 0c             	sub    $0xc,%esp
80105f0c:	68 40 6a 19 80       	push   $0x80196a40
80105f11:	e8 39 ea ff ff       	call   8010494f <acquire>
80105f16:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80105f19:	a1 74 6a 19 80       	mov    0x80196a74,%eax
80105f1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80105f21:	83 ec 0c             	sub    $0xc,%esp
80105f24:	68 40 6a 19 80       	push   $0x80196a40
80105f29:	e8 8f ea ff ff       	call   801049bd <release>
80105f2e:	83 c4 10             	add    $0x10,%esp
  return xticks;
80105f31:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105f34:	c9                   	leave  
80105f35:	c3                   	ret    

80105f36 <sys_exit2>:

int
sys_exit2(void)
{
80105f36:	55                   	push   %ebp
80105f37:	89 e5                	mov    %esp,%ebp
80105f39:	83 ec 18             	sub    $0x18,%esp
  int n;
  if (argint(0, &n) < 0)
80105f3c:	83 ec 08             	sub    $0x8,%esp
80105f3f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105f42:	50                   	push   %eax
80105f43:	6a 00                	push   $0x0
80105f45:	e8 a6 ef ff ff       	call   80104ef0 <argint>
80105f4a:	83 c4 10             	add    $0x10,%esp
80105f4d:	85 c0                	test   %eax,%eax
80105f4f:	79 07                	jns    80105f58 <sys_exit2+0x22>
      return -1;
80105f51:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f56:	eb 14                	jmp    80105f6c <sys_exit2+0x36>
  exit2(n);
80105f58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f5b:	83 ec 0c             	sub    $0xc,%esp
80105f5e:	50                   	push   %eax
80105f5f:	e8 64 e0 ff ff       	call   80103fc8 <exit2>
80105f64:	83 c4 10             	add    $0x10,%esp
  return 0;  // not reached
80105f67:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f6c:	c9                   	leave  
80105f6d:	c3                   	ret    

80105f6e <sys_wait2>:

int
sys_wait2(void)
{
80105f6e:	55                   	push   %ebp
80105f6f:	89 e5                	mov    %esp,%ebp
80105f71:	83 ec 18             	sub    $0x18,%esp
 int *p;
 if (argptr(0, (void*)&p, sizeof(*p)) < 0)
80105f74:	83 ec 04             	sub    $0x4,%esp
80105f77:	6a 04                	push   $0x4
80105f79:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105f7c:	50                   	push   %eax
80105f7d:	6a 00                	push   $0x0
80105f7f:	e8 99 ef ff ff       	call   80104f1d <argptr>
80105f84:	83 c4 10             	add    $0x10,%esp
80105f87:	85 c0                	test   %eax,%eax
80105f89:	79 07                	jns    80105f92 <sys_wait2+0x24>
     return -1;
80105f8b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f90:	eb 0f                	jmp    80105fa1 <sys_wait2+0x33>
 return wait2(p);
80105f92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f95:	83 ec 0c             	sub    $0xc,%esp
80105f98:	50                   	push   %eax
80105f99:	e8 76 e2 ff ff       	call   80104214 <wait2>
80105f9e:	83 c4 10             	add    $0x10,%esp
}
80105fa1:	c9                   	leave  
80105fa2:	c3                   	ret    

80105fa3 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80105fa3:	1e                   	push   %ds
  pushl %es
80105fa4:	06                   	push   %es
  pushl %fs
80105fa5:	0f a0                	push   %fs
  pushl %gs
80105fa7:	0f a8                	push   %gs
  pushal
80105fa9:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80105faa:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80105fae:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80105fb0:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80105fb2:	54                   	push   %esp
  call trap
80105fb3:	e8 d7 01 00 00       	call   8010618f <trap>
  addl $4, %esp
80105fb8:	83 c4 04             	add    $0x4,%esp

80105fbb <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80105fbb:	61                   	popa   
  popl %gs
80105fbc:	0f a9                	pop    %gs
  popl %fs
80105fbe:	0f a1                	pop    %fs
  popl %es
80105fc0:	07                   	pop    %es
  popl %ds
80105fc1:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80105fc2:	83 c4 08             	add    $0x8,%esp
  iret
80105fc5:	cf                   	iret   

80105fc6 <lidt>:
{
80105fc6:	55                   	push   %ebp
80105fc7:	89 e5                	mov    %esp,%ebp
80105fc9:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80105fcc:	8b 45 0c             	mov    0xc(%ebp),%eax
80105fcf:	83 e8 01             	sub    $0x1,%eax
80105fd2:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80105fd6:	8b 45 08             	mov    0x8(%ebp),%eax
80105fd9:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105fdd:	8b 45 08             	mov    0x8(%ebp),%eax
80105fe0:	c1 e8 10             	shr    $0x10,%eax
80105fe3:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105fe7:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105fea:	0f 01 18             	lidtl  (%eax)
}
80105fed:	90                   	nop
80105fee:	c9                   	leave  
80105fef:	c3                   	ret    

80105ff0 <rcr2>:

static inline uint
rcr2(void)
{
80105ff0:	55                   	push   %ebp
80105ff1:	89 e5                	mov    %esp,%ebp
80105ff3:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105ff6:	0f 20 d0             	mov    %cr2,%eax
80105ff9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80105ffc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105fff:	c9                   	leave  
80106000:	c3                   	ret    

80106001 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106001:	55                   	push   %ebp
80106002:	89 e5                	mov    %esp,%ebp
80106004:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106007:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010600e:	e9 c3 00 00 00       	jmp    801060d6 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106013:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106016:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
8010601d:	89 c2                	mov    %eax,%edx
8010601f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106022:	66 89 14 c5 40 62 19 	mov    %dx,-0x7fe69dc0(,%eax,8)
80106029:	80 
8010602a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010602d:	66 c7 04 c5 42 62 19 	movw   $0x8,-0x7fe69dbe(,%eax,8)
80106034:	80 08 00 
80106037:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010603a:	0f b6 14 c5 44 62 19 	movzbl -0x7fe69dbc(,%eax,8),%edx
80106041:	80 
80106042:	83 e2 e0             	and    $0xffffffe0,%edx
80106045:	88 14 c5 44 62 19 80 	mov    %dl,-0x7fe69dbc(,%eax,8)
8010604c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010604f:	0f b6 14 c5 44 62 19 	movzbl -0x7fe69dbc(,%eax,8),%edx
80106056:	80 
80106057:	83 e2 1f             	and    $0x1f,%edx
8010605a:	88 14 c5 44 62 19 80 	mov    %dl,-0x7fe69dbc(,%eax,8)
80106061:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106064:	0f b6 14 c5 45 62 19 	movzbl -0x7fe69dbb(,%eax,8),%edx
8010606b:	80 
8010606c:	83 e2 f0             	and    $0xfffffff0,%edx
8010606f:	83 ca 0e             	or     $0xe,%edx
80106072:	88 14 c5 45 62 19 80 	mov    %dl,-0x7fe69dbb(,%eax,8)
80106079:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010607c:	0f b6 14 c5 45 62 19 	movzbl -0x7fe69dbb(,%eax,8),%edx
80106083:	80 
80106084:	83 e2 ef             	and    $0xffffffef,%edx
80106087:	88 14 c5 45 62 19 80 	mov    %dl,-0x7fe69dbb(,%eax,8)
8010608e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106091:	0f b6 14 c5 45 62 19 	movzbl -0x7fe69dbb(,%eax,8),%edx
80106098:	80 
80106099:	83 e2 9f             	and    $0xffffff9f,%edx
8010609c:	88 14 c5 45 62 19 80 	mov    %dl,-0x7fe69dbb(,%eax,8)
801060a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060a6:	0f b6 14 c5 45 62 19 	movzbl -0x7fe69dbb(,%eax,8),%edx
801060ad:	80 
801060ae:	83 ca 80             	or     $0xffffff80,%edx
801060b1:	88 14 c5 45 62 19 80 	mov    %dl,-0x7fe69dbb(,%eax,8)
801060b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060bb:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
801060c2:	c1 e8 10             	shr    $0x10,%eax
801060c5:	89 c2                	mov    %eax,%edx
801060c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060ca:	66 89 14 c5 46 62 19 	mov    %dx,-0x7fe69dba(,%eax,8)
801060d1:	80 
  for(i = 0; i < 256; i++)
801060d2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801060d6:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801060dd:	0f 8e 30 ff ff ff    	jle    80106013 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801060e3:	a1 80 f1 10 80       	mov    0x8010f180,%eax
801060e8:	66 a3 40 64 19 80    	mov    %ax,0x80196440
801060ee:	66 c7 05 42 64 19 80 	movw   $0x8,0x80196442
801060f5:	08 00 
801060f7:	0f b6 05 44 64 19 80 	movzbl 0x80196444,%eax
801060fe:	83 e0 e0             	and    $0xffffffe0,%eax
80106101:	a2 44 64 19 80       	mov    %al,0x80196444
80106106:	0f b6 05 44 64 19 80 	movzbl 0x80196444,%eax
8010610d:	83 e0 1f             	and    $0x1f,%eax
80106110:	a2 44 64 19 80       	mov    %al,0x80196444
80106115:	0f b6 05 45 64 19 80 	movzbl 0x80196445,%eax
8010611c:	83 c8 0f             	or     $0xf,%eax
8010611f:	a2 45 64 19 80       	mov    %al,0x80196445
80106124:	0f b6 05 45 64 19 80 	movzbl 0x80196445,%eax
8010612b:	83 e0 ef             	and    $0xffffffef,%eax
8010612e:	a2 45 64 19 80       	mov    %al,0x80196445
80106133:	0f b6 05 45 64 19 80 	movzbl 0x80196445,%eax
8010613a:	83 c8 60             	or     $0x60,%eax
8010613d:	a2 45 64 19 80       	mov    %al,0x80196445
80106142:	0f b6 05 45 64 19 80 	movzbl 0x80196445,%eax
80106149:	83 c8 80             	or     $0xffffff80,%eax
8010614c:	a2 45 64 19 80       	mov    %al,0x80196445
80106151:	a1 80 f1 10 80       	mov    0x8010f180,%eax
80106156:	c1 e8 10             	shr    $0x10,%eax
80106159:	66 a3 46 64 19 80    	mov    %ax,0x80196446

  initlock(&tickslock, "time");
8010615f:	83 ec 08             	sub    $0x8,%esp
80106162:	68 78 a6 10 80       	push   $0x8010a678
80106167:	68 40 6a 19 80       	push   $0x80196a40
8010616c:	e8 bc e7 ff ff       	call   8010492d <initlock>
80106171:	83 c4 10             	add    $0x10,%esp
}
80106174:	90                   	nop
80106175:	c9                   	leave  
80106176:	c3                   	ret    

80106177 <idtinit>:

void
idtinit(void)
{
80106177:	55                   	push   %ebp
80106178:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
8010617a:	68 00 08 00 00       	push   $0x800
8010617f:	68 40 62 19 80       	push   $0x80196240
80106184:	e8 3d fe ff ff       	call   80105fc6 <lidt>
80106189:	83 c4 08             	add    $0x8,%esp
}
8010618c:	90                   	nop
8010618d:	c9                   	leave  
8010618e:	c3                   	ret    

8010618f <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010618f:	55                   	push   %ebp
80106190:	89 e5                	mov    %esp,%ebp
80106192:	57                   	push   %edi
80106193:	56                   	push   %esi
80106194:	53                   	push   %ebx
80106195:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80106198:	8b 45 08             	mov    0x8(%ebp),%eax
8010619b:	8b 40 30             	mov    0x30(%eax),%eax
8010619e:	83 f8 40             	cmp    $0x40,%eax
801061a1:	75 3b                	jne    801061de <trap+0x4f>
    if(myproc()->killed)
801061a3:	e8 88 d8 ff ff       	call   80103a30 <myproc>
801061a8:	8b 40 24             	mov    0x24(%eax),%eax
801061ab:	85 c0                	test   %eax,%eax
801061ad:	74 05                	je     801061b4 <trap+0x25>
      exit();
801061af:	e8 f4 dc ff ff       	call   80103ea8 <exit>
    myproc()->tf = tf;
801061b4:	e8 77 d8 ff ff       	call   80103a30 <myproc>
801061b9:	8b 55 08             	mov    0x8(%ebp),%edx
801061bc:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801061bf:	e8 f8 ed ff ff       	call   80104fbc <syscall>
    if(myproc()->killed)
801061c4:	e8 67 d8 ff ff       	call   80103a30 <myproc>
801061c9:	8b 40 24             	mov    0x24(%eax),%eax
801061cc:	85 c0                	test   %eax,%eax
801061ce:	0f 84 15 02 00 00    	je     801063e9 <trap+0x25a>
      exit();
801061d4:	e8 cf dc ff ff       	call   80103ea8 <exit>
    return;
801061d9:	e9 0b 02 00 00       	jmp    801063e9 <trap+0x25a>
  }

  switch(tf->trapno){
801061de:	8b 45 08             	mov    0x8(%ebp),%eax
801061e1:	8b 40 30             	mov    0x30(%eax),%eax
801061e4:	83 e8 20             	sub    $0x20,%eax
801061e7:	83 f8 1f             	cmp    $0x1f,%eax
801061ea:	0f 87 c4 00 00 00    	ja     801062b4 <trap+0x125>
801061f0:	8b 04 85 20 a7 10 80 	mov    -0x7fef58e0(,%eax,4),%eax
801061f7:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801061f9:	e8 9f d7 ff ff       	call   8010399d <cpuid>
801061fe:	85 c0                	test   %eax,%eax
80106200:	75 3d                	jne    8010623f <trap+0xb0>
      acquire(&tickslock);
80106202:	83 ec 0c             	sub    $0xc,%esp
80106205:	68 40 6a 19 80       	push   $0x80196a40
8010620a:	e8 40 e7 ff ff       	call   8010494f <acquire>
8010620f:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106212:	a1 74 6a 19 80       	mov    0x80196a74,%eax
80106217:	83 c0 01             	add    $0x1,%eax
8010621a:	a3 74 6a 19 80       	mov    %eax,0x80196a74
      wakeup(&ticks);
8010621f:	83 ec 0c             	sub    $0xc,%esp
80106222:	68 74 6a 19 80       	push   $0x80196a74
80106227:	e8 ef e3 ff ff       	call   8010461b <wakeup>
8010622c:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
8010622f:	83 ec 0c             	sub    $0xc,%esp
80106232:	68 40 6a 19 80       	push   $0x80196a40
80106237:	e8 81 e7 ff ff       	call   801049bd <release>
8010623c:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
8010623f:	e8 d8 c8 ff ff       	call   80102b1c <lapiceoi>
    break;
80106244:	e9 20 01 00 00       	jmp    80106369 <trap+0x1da>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106249:	e8 f5 3e 00 00       	call   8010a143 <ideintr>
    lapiceoi();
8010624e:	e8 c9 c8 ff ff       	call   80102b1c <lapiceoi>
    break;
80106253:	e9 11 01 00 00       	jmp    80106369 <trap+0x1da>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106258:	e8 04 c7 ff ff       	call   80102961 <kbdintr>
    lapiceoi();
8010625d:	e8 ba c8 ff ff       	call   80102b1c <lapiceoi>
    break;
80106262:	e9 02 01 00 00       	jmp    80106369 <trap+0x1da>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106267:	e8 53 03 00 00       	call   801065bf <uartintr>
    lapiceoi();
8010626c:	e8 ab c8 ff ff       	call   80102b1c <lapiceoi>
    break;
80106271:	e9 f3 00 00 00       	jmp    80106369 <trap+0x1da>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106276:	e8 7b 2b 00 00       	call   80108df6 <i8254_intr>
    lapiceoi();
8010627b:	e8 9c c8 ff ff       	call   80102b1c <lapiceoi>
    break;
80106280:	e9 e4 00 00 00       	jmp    80106369 <trap+0x1da>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106285:	8b 45 08             	mov    0x8(%ebp),%eax
80106288:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
8010628b:	8b 45 08             	mov    0x8(%ebp),%eax
8010628e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106292:	0f b7 d8             	movzwl %ax,%ebx
80106295:	e8 03 d7 ff ff       	call   8010399d <cpuid>
8010629a:	56                   	push   %esi
8010629b:	53                   	push   %ebx
8010629c:	50                   	push   %eax
8010629d:	68 80 a6 10 80       	push   $0x8010a680
801062a2:	e8 4d a1 ff ff       	call   801003f4 <cprintf>
801062a7:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
801062aa:	e8 6d c8 ff ff       	call   80102b1c <lapiceoi>
    break;
801062af:	e9 b5 00 00 00       	jmp    80106369 <trap+0x1da>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
801062b4:	e8 77 d7 ff ff       	call   80103a30 <myproc>
801062b9:	85 c0                	test   %eax,%eax
801062bb:	74 11                	je     801062ce <trap+0x13f>
801062bd:	8b 45 08             	mov    0x8(%ebp),%eax
801062c0:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801062c4:	0f b7 c0             	movzwl %ax,%eax
801062c7:	83 e0 03             	and    $0x3,%eax
801062ca:	85 c0                	test   %eax,%eax
801062cc:	75 39                	jne    80106307 <trap+0x178>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801062ce:	e8 1d fd ff ff       	call   80105ff0 <rcr2>
801062d3:	89 c3                	mov    %eax,%ebx
801062d5:	8b 45 08             	mov    0x8(%ebp),%eax
801062d8:	8b 70 38             	mov    0x38(%eax),%esi
801062db:	e8 bd d6 ff ff       	call   8010399d <cpuid>
801062e0:	8b 55 08             	mov    0x8(%ebp),%edx
801062e3:	8b 52 30             	mov    0x30(%edx),%edx
801062e6:	83 ec 0c             	sub    $0xc,%esp
801062e9:	53                   	push   %ebx
801062ea:	56                   	push   %esi
801062eb:	50                   	push   %eax
801062ec:	52                   	push   %edx
801062ed:	68 a4 a6 10 80       	push   $0x8010a6a4
801062f2:	e8 fd a0 ff ff       	call   801003f4 <cprintf>
801062f7:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
801062fa:	83 ec 0c             	sub    $0xc,%esp
801062fd:	68 d6 a6 10 80       	push   $0x8010a6d6
80106302:	e8 a2 a2 ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106307:	e8 e4 fc ff ff       	call   80105ff0 <rcr2>
8010630c:	89 c6                	mov    %eax,%esi
8010630e:	8b 45 08             	mov    0x8(%ebp),%eax
80106311:	8b 40 38             	mov    0x38(%eax),%eax
80106314:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106317:	e8 81 d6 ff ff       	call   8010399d <cpuid>
8010631c:	89 c3                	mov    %eax,%ebx
8010631e:	8b 45 08             	mov    0x8(%ebp),%eax
80106321:	8b 48 34             	mov    0x34(%eax),%ecx
80106324:	89 4d e0             	mov    %ecx,-0x20(%ebp)
80106327:	8b 45 08             	mov    0x8(%ebp),%eax
8010632a:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
8010632d:	e8 fe d6 ff ff       	call   80103a30 <myproc>
80106332:	8d 50 6c             	lea    0x6c(%eax),%edx
80106335:	89 55 dc             	mov    %edx,-0x24(%ebp)
80106338:	e8 f3 d6 ff ff       	call   80103a30 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010633d:	8b 40 10             	mov    0x10(%eax),%eax
80106340:	56                   	push   %esi
80106341:	ff 75 e4             	push   -0x1c(%ebp)
80106344:	53                   	push   %ebx
80106345:	ff 75 e0             	push   -0x20(%ebp)
80106348:	57                   	push   %edi
80106349:	ff 75 dc             	push   -0x24(%ebp)
8010634c:	50                   	push   %eax
8010634d:	68 dc a6 10 80       	push   $0x8010a6dc
80106352:	e8 9d a0 ff ff       	call   801003f4 <cprintf>
80106357:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
8010635a:	e8 d1 d6 ff ff       	call   80103a30 <myproc>
8010635f:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106366:	eb 01                	jmp    80106369 <trap+0x1da>
    break;
80106368:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106369:	e8 c2 d6 ff ff       	call   80103a30 <myproc>
8010636e:	85 c0                	test   %eax,%eax
80106370:	74 23                	je     80106395 <trap+0x206>
80106372:	e8 b9 d6 ff ff       	call   80103a30 <myproc>
80106377:	8b 40 24             	mov    0x24(%eax),%eax
8010637a:	85 c0                	test   %eax,%eax
8010637c:	74 17                	je     80106395 <trap+0x206>
8010637e:	8b 45 08             	mov    0x8(%ebp),%eax
80106381:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106385:	0f b7 c0             	movzwl %ax,%eax
80106388:	83 e0 03             	and    $0x3,%eax
8010638b:	83 f8 03             	cmp    $0x3,%eax
8010638e:	75 05                	jne    80106395 <trap+0x206>
    exit();
80106390:	e8 13 db ff ff       	call   80103ea8 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106395:	e8 96 d6 ff ff       	call   80103a30 <myproc>
8010639a:	85 c0                	test   %eax,%eax
8010639c:	74 1d                	je     801063bb <trap+0x22c>
8010639e:	e8 8d d6 ff ff       	call   80103a30 <myproc>
801063a3:	8b 40 0c             	mov    0xc(%eax),%eax
801063a6:	83 f8 04             	cmp    $0x4,%eax
801063a9:	75 10                	jne    801063bb <trap+0x22c>
     tf->trapno == T_IRQ0+IRQ_TIMER)
801063ab:	8b 45 08             	mov    0x8(%ebp),%eax
801063ae:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
801063b1:	83 f8 20             	cmp    $0x20,%eax
801063b4:	75 05                	jne    801063bb <trap+0x22c>
    yield();
801063b6:	e8 f9 e0 ff ff       	call   801044b4 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801063bb:	e8 70 d6 ff ff       	call   80103a30 <myproc>
801063c0:	85 c0                	test   %eax,%eax
801063c2:	74 26                	je     801063ea <trap+0x25b>
801063c4:	e8 67 d6 ff ff       	call   80103a30 <myproc>
801063c9:	8b 40 24             	mov    0x24(%eax),%eax
801063cc:	85 c0                	test   %eax,%eax
801063ce:	74 1a                	je     801063ea <trap+0x25b>
801063d0:	8b 45 08             	mov    0x8(%ebp),%eax
801063d3:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801063d7:	0f b7 c0             	movzwl %ax,%eax
801063da:	83 e0 03             	and    $0x3,%eax
801063dd:	83 f8 03             	cmp    $0x3,%eax
801063e0:	75 08                	jne    801063ea <trap+0x25b>
    exit();
801063e2:	e8 c1 da ff ff       	call   80103ea8 <exit>
801063e7:	eb 01                	jmp    801063ea <trap+0x25b>
    return;
801063e9:	90                   	nop
}
801063ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
801063ed:	5b                   	pop    %ebx
801063ee:	5e                   	pop    %esi
801063ef:	5f                   	pop    %edi
801063f0:	5d                   	pop    %ebp
801063f1:	c3                   	ret    

801063f2 <inb>:
{
801063f2:	55                   	push   %ebp
801063f3:	89 e5                	mov    %esp,%ebp
801063f5:	83 ec 14             	sub    $0x14,%esp
801063f8:	8b 45 08             	mov    0x8(%ebp),%eax
801063fb:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801063ff:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106403:	89 c2                	mov    %eax,%edx
80106405:	ec                   	in     (%dx),%al
80106406:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106409:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010640d:	c9                   	leave  
8010640e:	c3                   	ret    

8010640f <outb>:
{
8010640f:	55                   	push   %ebp
80106410:	89 e5                	mov    %esp,%ebp
80106412:	83 ec 08             	sub    $0x8,%esp
80106415:	8b 45 08             	mov    0x8(%ebp),%eax
80106418:	8b 55 0c             	mov    0xc(%ebp),%edx
8010641b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010641f:	89 d0                	mov    %edx,%eax
80106421:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106424:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106428:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010642c:	ee                   	out    %al,(%dx)
}
8010642d:	90                   	nop
8010642e:	c9                   	leave  
8010642f:	c3                   	ret    

80106430 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106430:	55                   	push   %ebp
80106431:	89 e5                	mov    %esp,%ebp
80106433:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106436:	6a 00                	push   $0x0
80106438:	68 fa 03 00 00       	push   $0x3fa
8010643d:	e8 cd ff ff ff       	call   8010640f <outb>
80106442:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106445:	68 80 00 00 00       	push   $0x80
8010644a:	68 fb 03 00 00       	push   $0x3fb
8010644f:	e8 bb ff ff ff       	call   8010640f <outb>
80106454:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106457:	6a 0c                	push   $0xc
80106459:	68 f8 03 00 00       	push   $0x3f8
8010645e:	e8 ac ff ff ff       	call   8010640f <outb>
80106463:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106466:	6a 00                	push   $0x0
80106468:	68 f9 03 00 00       	push   $0x3f9
8010646d:	e8 9d ff ff ff       	call   8010640f <outb>
80106472:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106475:	6a 03                	push   $0x3
80106477:	68 fb 03 00 00       	push   $0x3fb
8010647c:	e8 8e ff ff ff       	call   8010640f <outb>
80106481:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106484:	6a 00                	push   $0x0
80106486:	68 fc 03 00 00       	push   $0x3fc
8010648b:	e8 7f ff ff ff       	call   8010640f <outb>
80106490:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106493:	6a 01                	push   $0x1
80106495:	68 f9 03 00 00       	push   $0x3f9
8010649a:	e8 70 ff ff ff       	call   8010640f <outb>
8010649f:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801064a2:	68 fd 03 00 00       	push   $0x3fd
801064a7:	e8 46 ff ff ff       	call   801063f2 <inb>
801064ac:	83 c4 04             	add    $0x4,%esp
801064af:	3c ff                	cmp    $0xff,%al
801064b1:	74 61                	je     80106514 <uartinit+0xe4>
    return;
  uart = 1;
801064b3:	c7 05 78 6a 19 80 01 	movl   $0x1,0x80196a78
801064ba:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801064bd:	68 fa 03 00 00       	push   $0x3fa
801064c2:	e8 2b ff ff ff       	call   801063f2 <inb>
801064c7:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801064ca:	68 f8 03 00 00       	push   $0x3f8
801064cf:	e8 1e ff ff ff       	call   801063f2 <inb>
801064d4:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
801064d7:	83 ec 08             	sub    $0x8,%esp
801064da:	6a 00                	push   $0x0
801064dc:	6a 04                	push   $0x4
801064de:	e8 4b c1 ff ff       	call   8010262e <ioapicenable>
801064e3:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801064e6:	c7 45 f4 a0 a7 10 80 	movl   $0x8010a7a0,-0xc(%ebp)
801064ed:	eb 19                	jmp    80106508 <uartinit+0xd8>
    uartputc(*p);
801064ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064f2:	0f b6 00             	movzbl (%eax),%eax
801064f5:	0f be c0             	movsbl %al,%eax
801064f8:	83 ec 0c             	sub    $0xc,%esp
801064fb:	50                   	push   %eax
801064fc:	e8 16 00 00 00       	call   80106517 <uartputc>
80106501:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106504:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106508:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010650b:	0f b6 00             	movzbl (%eax),%eax
8010650e:	84 c0                	test   %al,%al
80106510:	75 dd                	jne    801064ef <uartinit+0xbf>
80106512:	eb 01                	jmp    80106515 <uartinit+0xe5>
    return;
80106514:	90                   	nop
}
80106515:	c9                   	leave  
80106516:	c3                   	ret    

80106517 <uartputc>:

void
uartputc(int c)
{
80106517:	55                   	push   %ebp
80106518:	89 e5                	mov    %esp,%ebp
8010651a:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
8010651d:	a1 78 6a 19 80       	mov    0x80196a78,%eax
80106522:	85 c0                	test   %eax,%eax
80106524:	74 53                	je     80106579 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106526:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010652d:	eb 11                	jmp    80106540 <uartputc+0x29>
    microdelay(10);
8010652f:	83 ec 0c             	sub    $0xc,%esp
80106532:	6a 0a                	push   $0xa
80106534:	e8 fe c5 ff ff       	call   80102b37 <microdelay>
80106539:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010653c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106540:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106544:	7f 1a                	jg     80106560 <uartputc+0x49>
80106546:	83 ec 0c             	sub    $0xc,%esp
80106549:	68 fd 03 00 00       	push   $0x3fd
8010654e:	e8 9f fe ff ff       	call   801063f2 <inb>
80106553:	83 c4 10             	add    $0x10,%esp
80106556:	0f b6 c0             	movzbl %al,%eax
80106559:	83 e0 20             	and    $0x20,%eax
8010655c:	85 c0                	test   %eax,%eax
8010655e:	74 cf                	je     8010652f <uartputc+0x18>
  outb(COM1+0, c);
80106560:	8b 45 08             	mov    0x8(%ebp),%eax
80106563:	0f b6 c0             	movzbl %al,%eax
80106566:	83 ec 08             	sub    $0x8,%esp
80106569:	50                   	push   %eax
8010656a:	68 f8 03 00 00       	push   $0x3f8
8010656f:	e8 9b fe ff ff       	call   8010640f <outb>
80106574:	83 c4 10             	add    $0x10,%esp
80106577:	eb 01                	jmp    8010657a <uartputc+0x63>
    return;
80106579:	90                   	nop
}
8010657a:	c9                   	leave  
8010657b:	c3                   	ret    

8010657c <uartgetc>:

static int
uartgetc(void)
{
8010657c:	55                   	push   %ebp
8010657d:	89 e5                	mov    %esp,%ebp
  if(!uart)
8010657f:	a1 78 6a 19 80       	mov    0x80196a78,%eax
80106584:	85 c0                	test   %eax,%eax
80106586:	75 07                	jne    8010658f <uartgetc+0x13>
    return -1;
80106588:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010658d:	eb 2e                	jmp    801065bd <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
8010658f:	68 fd 03 00 00       	push   $0x3fd
80106594:	e8 59 fe ff ff       	call   801063f2 <inb>
80106599:	83 c4 04             	add    $0x4,%esp
8010659c:	0f b6 c0             	movzbl %al,%eax
8010659f:	83 e0 01             	and    $0x1,%eax
801065a2:	85 c0                	test   %eax,%eax
801065a4:	75 07                	jne    801065ad <uartgetc+0x31>
    return -1;
801065a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065ab:	eb 10                	jmp    801065bd <uartgetc+0x41>
  return inb(COM1+0);
801065ad:	68 f8 03 00 00       	push   $0x3f8
801065b2:	e8 3b fe ff ff       	call   801063f2 <inb>
801065b7:	83 c4 04             	add    $0x4,%esp
801065ba:	0f b6 c0             	movzbl %al,%eax
}
801065bd:	c9                   	leave  
801065be:	c3                   	ret    

801065bf <uartintr>:

void
uartintr(void)
{
801065bf:	55                   	push   %ebp
801065c0:	89 e5                	mov    %esp,%ebp
801065c2:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
801065c5:	83 ec 0c             	sub    $0xc,%esp
801065c8:	68 7c 65 10 80       	push   $0x8010657c
801065cd:	e8 04 a2 ff ff       	call   801007d6 <consoleintr>
801065d2:	83 c4 10             	add    $0x10,%esp
}
801065d5:	90                   	nop
801065d6:	c9                   	leave  
801065d7:	c3                   	ret    

801065d8 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801065d8:	6a 00                	push   $0x0
  pushl $0
801065da:	6a 00                	push   $0x0
  jmp alltraps
801065dc:	e9 c2 f9 ff ff       	jmp    80105fa3 <alltraps>

801065e1 <vector1>:
.globl vector1
vector1:
  pushl $0
801065e1:	6a 00                	push   $0x0
  pushl $1
801065e3:	6a 01                	push   $0x1
  jmp alltraps
801065e5:	e9 b9 f9 ff ff       	jmp    80105fa3 <alltraps>

801065ea <vector2>:
.globl vector2
vector2:
  pushl $0
801065ea:	6a 00                	push   $0x0
  pushl $2
801065ec:	6a 02                	push   $0x2
  jmp alltraps
801065ee:	e9 b0 f9 ff ff       	jmp    80105fa3 <alltraps>

801065f3 <vector3>:
.globl vector3
vector3:
  pushl $0
801065f3:	6a 00                	push   $0x0
  pushl $3
801065f5:	6a 03                	push   $0x3
  jmp alltraps
801065f7:	e9 a7 f9 ff ff       	jmp    80105fa3 <alltraps>

801065fc <vector4>:
.globl vector4
vector4:
  pushl $0
801065fc:	6a 00                	push   $0x0
  pushl $4
801065fe:	6a 04                	push   $0x4
  jmp alltraps
80106600:	e9 9e f9 ff ff       	jmp    80105fa3 <alltraps>

80106605 <vector5>:
.globl vector5
vector5:
  pushl $0
80106605:	6a 00                	push   $0x0
  pushl $5
80106607:	6a 05                	push   $0x5
  jmp alltraps
80106609:	e9 95 f9 ff ff       	jmp    80105fa3 <alltraps>

8010660e <vector6>:
.globl vector6
vector6:
  pushl $0
8010660e:	6a 00                	push   $0x0
  pushl $6
80106610:	6a 06                	push   $0x6
  jmp alltraps
80106612:	e9 8c f9 ff ff       	jmp    80105fa3 <alltraps>

80106617 <vector7>:
.globl vector7
vector7:
  pushl $0
80106617:	6a 00                	push   $0x0
  pushl $7
80106619:	6a 07                	push   $0x7
  jmp alltraps
8010661b:	e9 83 f9 ff ff       	jmp    80105fa3 <alltraps>

80106620 <vector8>:
.globl vector8
vector8:
  pushl $8
80106620:	6a 08                	push   $0x8
  jmp alltraps
80106622:	e9 7c f9 ff ff       	jmp    80105fa3 <alltraps>

80106627 <vector9>:
.globl vector9
vector9:
  pushl $0
80106627:	6a 00                	push   $0x0
  pushl $9
80106629:	6a 09                	push   $0x9
  jmp alltraps
8010662b:	e9 73 f9 ff ff       	jmp    80105fa3 <alltraps>

80106630 <vector10>:
.globl vector10
vector10:
  pushl $10
80106630:	6a 0a                	push   $0xa
  jmp alltraps
80106632:	e9 6c f9 ff ff       	jmp    80105fa3 <alltraps>

80106637 <vector11>:
.globl vector11
vector11:
  pushl $11
80106637:	6a 0b                	push   $0xb
  jmp alltraps
80106639:	e9 65 f9 ff ff       	jmp    80105fa3 <alltraps>

8010663e <vector12>:
.globl vector12
vector12:
  pushl $12
8010663e:	6a 0c                	push   $0xc
  jmp alltraps
80106640:	e9 5e f9 ff ff       	jmp    80105fa3 <alltraps>

80106645 <vector13>:
.globl vector13
vector13:
  pushl $13
80106645:	6a 0d                	push   $0xd
  jmp alltraps
80106647:	e9 57 f9 ff ff       	jmp    80105fa3 <alltraps>

8010664c <vector14>:
.globl vector14
vector14:
  pushl $14
8010664c:	6a 0e                	push   $0xe
  jmp alltraps
8010664e:	e9 50 f9 ff ff       	jmp    80105fa3 <alltraps>

80106653 <vector15>:
.globl vector15
vector15:
  pushl $0
80106653:	6a 00                	push   $0x0
  pushl $15
80106655:	6a 0f                	push   $0xf
  jmp alltraps
80106657:	e9 47 f9 ff ff       	jmp    80105fa3 <alltraps>

8010665c <vector16>:
.globl vector16
vector16:
  pushl $0
8010665c:	6a 00                	push   $0x0
  pushl $16
8010665e:	6a 10                	push   $0x10
  jmp alltraps
80106660:	e9 3e f9 ff ff       	jmp    80105fa3 <alltraps>

80106665 <vector17>:
.globl vector17
vector17:
  pushl $17
80106665:	6a 11                	push   $0x11
  jmp alltraps
80106667:	e9 37 f9 ff ff       	jmp    80105fa3 <alltraps>

8010666c <vector18>:
.globl vector18
vector18:
  pushl $0
8010666c:	6a 00                	push   $0x0
  pushl $18
8010666e:	6a 12                	push   $0x12
  jmp alltraps
80106670:	e9 2e f9 ff ff       	jmp    80105fa3 <alltraps>

80106675 <vector19>:
.globl vector19
vector19:
  pushl $0
80106675:	6a 00                	push   $0x0
  pushl $19
80106677:	6a 13                	push   $0x13
  jmp alltraps
80106679:	e9 25 f9 ff ff       	jmp    80105fa3 <alltraps>

8010667e <vector20>:
.globl vector20
vector20:
  pushl $0
8010667e:	6a 00                	push   $0x0
  pushl $20
80106680:	6a 14                	push   $0x14
  jmp alltraps
80106682:	e9 1c f9 ff ff       	jmp    80105fa3 <alltraps>

80106687 <vector21>:
.globl vector21
vector21:
  pushl $0
80106687:	6a 00                	push   $0x0
  pushl $21
80106689:	6a 15                	push   $0x15
  jmp alltraps
8010668b:	e9 13 f9 ff ff       	jmp    80105fa3 <alltraps>

80106690 <vector22>:
.globl vector22
vector22:
  pushl $0
80106690:	6a 00                	push   $0x0
  pushl $22
80106692:	6a 16                	push   $0x16
  jmp alltraps
80106694:	e9 0a f9 ff ff       	jmp    80105fa3 <alltraps>

80106699 <vector23>:
.globl vector23
vector23:
  pushl $0
80106699:	6a 00                	push   $0x0
  pushl $23
8010669b:	6a 17                	push   $0x17
  jmp alltraps
8010669d:	e9 01 f9 ff ff       	jmp    80105fa3 <alltraps>

801066a2 <vector24>:
.globl vector24
vector24:
  pushl $0
801066a2:	6a 00                	push   $0x0
  pushl $24
801066a4:	6a 18                	push   $0x18
  jmp alltraps
801066a6:	e9 f8 f8 ff ff       	jmp    80105fa3 <alltraps>

801066ab <vector25>:
.globl vector25
vector25:
  pushl $0
801066ab:	6a 00                	push   $0x0
  pushl $25
801066ad:	6a 19                	push   $0x19
  jmp alltraps
801066af:	e9 ef f8 ff ff       	jmp    80105fa3 <alltraps>

801066b4 <vector26>:
.globl vector26
vector26:
  pushl $0
801066b4:	6a 00                	push   $0x0
  pushl $26
801066b6:	6a 1a                	push   $0x1a
  jmp alltraps
801066b8:	e9 e6 f8 ff ff       	jmp    80105fa3 <alltraps>

801066bd <vector27>:
.globl vector27
vector27:
  pushl $0
801066bd:	6a 00                	push   $0x0
  pushl $27
801066bf:	6a 1b                	push   $0x1b
  jmp alltraps
801066c1:	e9 dd f8 ff ff       	jmp    80105fa3 <alltraps>

801066c6 <vector28>:
.globl vector28
vector28:
  pushl $0
801066c6:	6a 00                	push   $0x0
  pushl $28
801066c8:	6a 1c                	push   $0x1c
  jmp alltraps
801066ca:	e9 d4 f8 ff ff       	jmp    80105fa3 <alltraps>

801066cf <vector29>:
.globl vector29
vector29:
  pushl $0
801066cf:	6a 00                	push   $0x0
  pushl $29
801066d1:	6a 1d                	push   $0x1d
  jmp alltraps
801066d3:	e9 cb f8 ff ff       	jmp    80105fa3 <alltraps>

801066d8 <vector30>:
.globl vector30
vector30:
  pushl $0
801066d8:	6a 00                	push   $0x0
  pushl $30
801066da:	6a 1e                	push   $0x1e
  jmp alltraps
801066dc:	e9 c2 f8 ff ff       	jmp    80105fa3 <alltraps>

801066e1 <vector31>:
.globl vector31
vector31:
  pushl $0
801066e1:	6a 00                	push   $0x0
  pushl $31
801066e3:	6a 1f                	push   $0x1f
  jmp alltraps
801066e5:	e9 b9 f8 ff ff       	jmp    80105fa3 <alltraps>

801066ea <vector32>:
.globl vector32
vector32:
  pushl $0
801066ea:	6a 00                	push   $0x0
  pushl $32
801066ec:	6a 20                	push   $0x20
  jmp alltraps
801066ee:	e9 b0 f8 ff ff       	jmp    80105fa3 <alltraps>

801066f3 <vector33>:
.globl vector33
vector33:
  pushl $0
801066f3:	6a 00                	push   $0x0
  pushl $33
801066f5:	6a 21                	push   $0x21
  jmp alltraps
801066f7:	e9 a7 f8 ff ff       	jmp    80105fa3 <alltraps>

801066fc <vector34>:
.globl vector34
vector34:
  pushl $0
801066fc:	6a 00                	push   $0x0
  pushl $34
801066fe:	6a 22                	push   $0x22
  jmp alltraps
80106700:	e9 9e f8 ff ff       	jmp    80105fa3 <alltraps>

80106705 <vector35>:
.globl vector35
vector35:
  pushl $0
80106705:	6a 00                	push   $0x0
  pushl $35
80106707:	6a 23                	push   $0x23
  jmp alltraps
80106709:	e9 95 f8 ff ff       	jmp    80105fa3 <alltraps>

8010670e <vector36>:
.globl vector36
vector36:
  pushl $0
8010670e:	6a 00                	push   $0x0
  pushl $36
80106710:	6a 24                	push   $0x24
  jmp alltraps
80106712:	e9 8c f8 ff ff       	jmp    80105fa3 <alltraps>

80106717 <vector37>:
.globl vector37
vector37:
  pushl $0
80106717:	6a 00                	push   $0x0
  pushl $37
80106719:	6a 25                	push   $0x25
  jmp alltraps
8010671b:	e9 83 f8 ff ff       	jmp    80105fa3 <alltraps>

80106720 <vector38>:
.globl vector38
vector38:
  pushl $0
80106720:	6a 00                	push   $0x0
  pushl $38
80106722:	6a 26                	push   $0x26
  jmp alltraps
80106724:	e9 7a f8 ff ff       	jmp    80105fa3 <alltraps>

80106729 <vector39>:
.globl vector39
vector39:
  pushl $0
80106729:	6a 00                	push   $0x0
  pushl $39
8010672b:	6a 27                	push   $0x27
  jmp alltraps
8010672d:	e9 71 f8 ff ff       	jmp    80105fa3 <alltraps>

80106732 <vector40>:
.globl vector40
vector40:
  pushl $0
80106732:	6a 00                	push   $0x0
  pushl $40
80106734:	6a 28                	push   $0x28
  jmp alltraps
80106736:	e9 68 f8 ff ff       	jmp    80105fa3 <alltraps>

8010673b <vector41>:
.globl vector41
vector41:
  pushl $0
8010673b:	6a 00                	push   $0x0
  pushl $41
8010673d:	6a 29                	push   $0x29
  jmp alltraps
8010673f:	e9 5f f8 ff ff       	jmp    80105fa3 <alltraps>

80106744 <vector42>:
.globl vector42
vector42:
  pushl $0
80106744:	6a 00                	push   $0x0
  pushl $42
80106746:	6a 2a                	push   $0x2a
  jmp alltraps
80106748:	e9 56 f8 ff ff       	jmp    80105fa3 <alltraps>

8010674d <vector43>:
.globl vector43
vector43:
  pushl $0
8010674d:	6a 00                	push   $0x0
  pushl $43
8010674f:	6a 2b                	push   $0x2b
  jmp alltraps
80106751:	e9 4d f8 ff ff       	jmp    80105fa3 <alltraps>

80106756 <vector44>:
.globl vector44
vector44:
  pushl $0
80106756:	6a 00                	push   $0x0
  pushl $44
80106758:	6a 2c                	push   $0x2c
  jmp alltraps
8010675a:	e9 44 f8 ff ff       	jmp    80105fa3 <alltraps>

8010675f <vector45>:
.globl vector45
vector45:
  pushl $0
8010675f:	6a 00                	push   $0x0
  pushl $45
80106761:	6a 2d                	push   $0x2d
  jmp alltraps
80106763:	e9 3b f8 ff ff       	jmp    80105fa3 <alltraps>

80106768 <vector46>:
.globl vector46
vector46:
  pushl $0
80106768:	6a 00                	push   $0x0
  pushl $46
8010676a:	6a 2e                	push   $0x2e
  jmp alltraps
8010676c:	e9 32 f8 ff ff       	jmp    80105fa3 <alltraps>

80106771 <vector47>:
.globl vector47
vector47:
  pushl $0
80106771:	6a 00                	push   $0x0
  pushl $47
80106773:	6a 2f                	push   $0x2f
  jmp alltraps
80106775:	e9 29 f8 ff ff       	jmp    80105fa3 <alltraps>

8010677a <vector48>:
.globl vector48
vector48:
  pushl $0
8010677a:	6a 00                	push   $0x0
  pushl $48
8010677c:	6a 30                	push   $0x30
  jmp alltraps
8010677e:	e9 20 f8 ff ff       	jmp    80105fa3 <alltraps>

80106783 <vector49>:
.globl vector49
vector49:
  pushl $0
80106783:	6a 00                	push   $0x0
  pushl $49
80106785:	6a 31                	push   $0x31
  jmp alltraps
80106787:	e9 17 f8 ff ff       	jmp    80105fa3 <alltraps>

8010678c <vector50>:
.globl vector50
vector50:
  pushl $0
8010678c:	6a 00                	push   $0x0
  pushl $50
8010678e:	6a 32                	push   $0x32
  jmp alltraps
80106790:	e9 0e f8 ff ff       	jmp    80105fa3 <alltraps>

80106795 <vector51>:
.globl vector51
vector51:
  pushl $0
80106795:	6a 00                	push   $0x0
  pushl $51
80106797:	6a 33                	push   $0x33
  jmp alltraps
80106799:	e9 05 f8 ff ff       	jmp    80105fa3 <alltraps>

8010679e <vector52>:
.globl vector52
vector52:
  pushl $0
8010679e:	6a 00                	push   $0x0
  pushl $52
801067a0:	6a 34                	push   $0x34
  jmp alltraps
801067a2:	e9 fc f7 ff ff       	jmp    80105fa3 <alltraps>

801067a7 <vector53>:
.globl vector53
vector53:
  pushl $0
801067a7:	6a 00                	push   $0x0
  pushl $53
801067a9:	6a 35                	push   $0x35
  jmp alltraps
801067ab:	e9 f3 f7 ff ff       	jmp    80105fa3 <alltraps>

801067b0 <vector54>:
.globl vector54
vector54:
  pushl $0
801067b0:	6a 00                	push   $0x0
  pushl $54
801067b2:	6a 36                	push   $0x36
  jmp alltraps
801067b4:	e9 ea f7 ff ff       	jmp    80105fa3 <alltraps>

801067b9 <vector55>:
.globl vector55
vector55:
  pushl $0
801067b9:	6a 00                	push   $0x0
  pushl $55
801067bb:	6a 37                	push   $0x37
  jmp alltraps
801067bd:	e9 e1 f7 ff ff       	jmp    80105fa3 <alltraps>

801067c2 <vector56>:
.globl vector56
vector56:
  pushl $0
801067c2:	6a 00                	push   $0x0
  pushl $56
801067c4:	6a 38                	push   $0x38
  jmp alltraps
801067c6:	e9 d8 f7 ff ff       	jmp    80105fa3 <alltraps>

801067cb <vector57>:
.globl vector57
vector57:
  pushl $0
801067cb:	6a 00                	push   $0x0
  pushl $57
801067cd:	6a 39                	push   $0x39
  jmp alltraps
801067cf:	e9 cf f7 ff ff       	jmp    80105fa3 <alltraps>

801067d4 <vector58>:
.globl vector58
vector58:
  pushl $0
801067d4:	6a 00                	push   $0x0
  pushl $58
801067d6:	6a 3a                	push   $0x3a
  jmp alltraps
801067d8:	e9 c6 f7 ff ff       	jmp    80105fa3 <alltraps>

801067dd <vector59>:
.globl vector59
vector59:
  pushl $0
801067dd:	6a 00                	push   $0x0
  pushl $59
801067df:	6a 3b                	push   $0x3b
  jmp alltraps
801067e1:	e9 bd f7 ff ff       	jmp    80105fa3 <alltraps>

801067e6 <vector60>:
.globl vector60
vector60:
  pushl $0
801067e6:	6a 00                	push   $0x0
  pushl $60
801067e8:	6a 3c                	push   $0x3c
  jmp alltraps
801067ea:	e9 b4 f7 ff ff       	jmp    80105fa3 <alltraps>

801067ef <vector61>:
.globl vector61
vector61:
  pushl $0
801067ef:	6a 00                	push   $0x0
  pushl $61
801067f1:	6a 3d                	push   $0x3d
  jmp alltraps
801067f3:	e9 ab f7 ff ff       	jmp    80105fa3 <alltraps>

801067f8 <vector62>:
.globl vector62
vector62:
  pushl $0
801067f8:	6a 00                	push   $0x0
  pushl $62
801067fa:	6a 3e                	push   $0x3e
  jmp alltraps
801067fc:	e9 a2 f7 ff ff       	jmp    80105fa3 <alltraps>

80106801 <vector63>:
.globl vector63
vector63:
  pushl $0
80106801:	6a 00                	push   $0x0
  pushl $63
80106803:	6a 3f                	push   $0x3f
  jmp alltraps
80106805:	e9 99 f7 ff ff       	jmp    80105fa3 <alltraps>

8010680a <vector64>:
.globl vector64
vector64:
  pushl $0
8010680a:	6a 00                	push   $0x0
  pushl $64
8010680c:	6a 40                	push   $0x40
  jmp alltraps
8010680e:	e9 90 f7 ff ff       	jmp    80105fa3 <alltraps>

80106813 <vector65>:
.globl vector65
vector65:
  pushl $0
80106813:	6a 00                	push   $0x0
  pushl $65
80106815:	6a 41                	push   $0x41
  jmp alltraps
80106817:	e9 87 f7 ff ff       	jmp    80105fa3 <alltraps>

8010681c <vector66>:
.globl vector66
vector66:
  pushl $0
8010681c:	6a 00                	push   $0x0
  pushl $66
8010681e:	6a 42                	push   $0x42
  jmp alltraps
80106820:	e9 7e f7 ff ff       	jmp    80105fa3 <alltraps>

80106825 <vector67>:
.globl vector67
vector67:
  pushl $0
80106825:	6a 00                	push   $0x0
  pushl $67
80106827:	6a 43                	push   $0x43
  jmp alltraps
80106829:	e9 75 f7 ff ff       	jmp    80105fa3 <alltraps>

8010682e <vector68>:
.globl vector68
vector68:
  pushl $0
8010682e:	6a 00                	push   $0x0
  pushl $68
80106830:	6a 44                	push   $0x44
  jmp alltraps
80106832:	e9 6c f7 ff ff       	jmp    80105fa3 <alltraps>

80106837 <vector69>:
.globl vector69
vector69:
  pushl $0
80106837:	6a 00                	push   $0x0
  pushl $69
80106839:	6a 45                	push   $0x45
  jmp alltraps
8010683b:	e9 63 f7 ff ff       	jmp    80105fa3 <alltraps>

80106840 <vector70>:
.globl vector70
vector70:
  pushl $0
80106840:	6a 00                	push   $0x0
  pushl $70
80106842:	6a 46                	push   $0x46
  jmp alltraps
80106844:	e9 5a f7 ff ff       	jmp    80105fa3 <alltraps>

80106849 <vector71>:
.globl vector71
vector71:
  pushl $0
80106849:	6a 00                	push   $0x0
  pushl $71
8010684b:	6a 47                	push   $0x47
  jmp alltraps
8010684d:	e9 51 f7 ff ff       	jmp    80105fa3 <alltraps>

80106852 <vector72>:
.globl vector72
vector72:
  pushl $0
80106852:	6a 00                	push   $0x0
  pushl $72
80106854:	6a 48                	push   $0x48
  jmp alltraps
80106856:	e9 48 f7 ff ff       	jmp    80105fa3 <alltraps>

8010685b <vector73>:
.globl vector73
vector73:
  pushl $0
8010685b:	6a 00                	push   $0x0
  pushl $73
8010685d:	6a 49                	push   $0x49
  jmp alltraps
8010685f:	e9 3f f7 ff ff       	jmp    80105fa3 <alltraps>

80106864 <vector74>:
.globl vector74
vector74:
  pushl $0
80106864:	6a 00                	push   $0x0
  pushl $74
80106866:	6a 4a                	push   $0x4a
  jmp alltraps
80106868:	e9 36 f7 ff ff       	jmp    80105fa3 <alltraps>

8010686d <vector75>:
.globl vector75
vector75:
  pushl $0
8010686d:	6a 00                	push   $0x0
  pushl $75
8010686f:	6a 4b                	push   $0x4b
  jmp alltraps
80106871:	e9 2d f7 ff ff       	jmp    80105fa3 <alltraps>

80106876 <vector76>:
.globl vector76
vector76:
  pushl $0
80106876:	6a 00                	push   $0x0
  pushl $76
80106878:	6a 4c                	push   $0x4c
  jmp alltraps
8010687a:	e9 24 f7 ff ff       	jmp    80105fa3 <alltraps>

8010687f <vector77>:
.globl vector77
vector77:
  pushl $0
8010687f:	6a 00                	push   $0x0
  pushl $77
80106881:	6a 4d                	push   $0x4d
  jmp alltraps
80106883:	e9 1b f7 ff ff       	jmp    80105fa3 <alltraps>

80106888 <vector78>:
.globl vector78
vector78:
  pushl $0
80106888:	6a 00                	push   $0x0
  pushl $78
8010688a:	6a 4e                	push   $0x4e
  jmp alltraps
8010688c:	e9 12 f7 ff ff       	jmp    80105fa3 <alltraps>

80106891 <vector79>:
.globl vector79
vector79:
  pushl $0
80106891:	6a 00                	push   $0x0
  pushl $79
80106893:	6a 4f                	push   $0x4f
  jmp alltraps
80106895:	e9 09 f7 ff ff       	jmp    80105fa3 <alltraps>

8010689a <vector80>:
.globl vector80
vector80:
  pushl $0
8010689a:	6a 00                	push   $0x0
  pushl $80
8010689c:	6a 50                	push   $0x50
  jmp alltraps
8010689e:	e9 00 f7 ff ff       	jmp    80105fa3 <alltraps>

801068a3 <vector81>:
.globl vector81
vector81:
  pushl $0
801068a3:	6a 00                	push   $0x0
  pushl $81
801068a5:	6a 51                	push   $0x51
  jmp alltraps
801068a7:	e9 f7 f6 ff ff       	jmp    80105fa3 <alltraps>

801068ac <vector82>:
.globl vector82
vector82:
  pushl $0
801068ac:	6a 00                	push   $0x0
  pushl $82
801068ae:	6a 52                	push   $0x52
  jmp alltraps
801068b0:	e9 ee f6 ff ff       	jmp    80105fa3 <alltraps>

801068b5 <vector83>:
.globl vector83
vector83:
  pushl $0
801068b5:	6a 00                	push   $0x0
  pushl $83
801068b7:	6a 53                	push   $0x53
  jmp alltraps
801068b9:	e9 e5 f6 ff ff       	jmp    80105fa3 <alltraps>

801068be <vector84>:
.globl vector84
vector84:
  pushl $0
801068be:	6a 00                	push   $0x0
  pushl $84
801068c0:	6a 54                	push   $0x54
  jmp alltraps
801068c2:	e9 dc f6 ff ff       	jmp    80105fa3 <alltraps>

801068c7 <vector85>:
.globl vector85
vector85:
  pushl $0
801068c7:	6a 00                	push   $0x0
  pushl $85
801068c9:	6a 55                	push   $0x55
  jmp alltraps
801068cb:	e9 d3 f6 ff ff       	jmp    80105fa3 <alltraps>

801068d0 <vector86>:
.globl vector86
vector86:
  pushl $0
801068d0:	6a 00                	push   $0x0
  pushl $86
801068d2:	6a 56                	push   $0x56
  jmp alltraps
801068d4:	e9 ca f6 ff ff       	jmp    80105fa3 <alltraps>

801068d9 <vector87>:
.globl vector87
vector87:
  pushl $0
801068d9:	6a 00                	push   $0x0
  pushl $87
801068db:	6a 57                	push   $0x57
  jmp alltraps
801068dd:	e9 c1 f6 ff ff       	jmp    80105fa3 <alltraps>

801068e2 <vector88>:
.globl vector88
vector88:
  pushl $0
801068e2:	6a 00                	push   $0x0
  pushl $88
801068e4:	6a 58                	push   $0x58
  jmp alltraps
801068e6:	e9 b8 f6 ff ff       	jmp    80105fa3 <alltraps>

801068eb <vector89>:
.globl vector89
vector89:
  pushl $0
801068eb:	6a 00                	push   $0x0
  pushl $89
801068ed:	6a 59                	push   $0x59
  jmp alltraps
801068ef:	e9 af f6 ff ff       	jmp    80105fa3 <alltraps>

801068f4 <vector90>:
.globl vector90
vector90:
  pushl $0
801068f4:	6a 00                	push   $0x0
  pushl $90
801068f6:	6a 5a                	push   $0x5a
  jmp alltraps
801068f8:	e9 a6 f6 ff ff       	jmp    80105fa3 <alltraps>

801068fd <vector91>:
.globl vector91
vector91:
  pushl $0
801068fd:	6a 00                	push   $0x0
  pushl $91
801068ff:	6a 5b                	push   $0x5b
  jmp alltraps
80106901:	e9 9d f6 ff ff       	jmp    80105fa3 <alltraps>

80106906 <vector92>:
.globl vector92
vector92:
  pushl $0
80106906:	6a 00                	push   $0x0
  pushl $92
80106908:	6a 5c                	push   $0x5c
  jmp alltraps
8010690a:	e9 94 f6 ff ff       	jmp    80105fa3 <alltraps>

8010690f <vector93>:
.globl vector93
vector93:
  pushl $0
8010690f:	6a 00                	push   $0x0
  pushl $93
80106911:	6a 5d                	push   $0x5d
  jmp alltraps
80106913:	e9 8b f6 ff ff       	jmp    80105fa3 <alltraps>

80106918 <vector94>:
.globl vector94
vector94:
  pushl $0
80106918:	6a 00                	push   $0x0
  pushl $94
8010691a:	6a 5e                	push   $0x5e
  jmp alltraps
8010691c:	e9 82 f6 ff ff       	jmp    80105fa3 <alltraps>

80106921 <vector95>:
.globl vector95
vector95:
  pushl $0
80106921:	6a 00                	push   $0x0
  pushl $95
80106923:	6a 5f                	push   $0x5f
  jmp alltraps
80106925:	e9 79 f6 ff ff       	jmp    80105fa3 <alltraps>

8010692a <vector96>:
.globl vector96
vector96:
  pushl $0
8010692a:	6a 00                	push   $0x0
  pushl $96
8010692c:	6a 60                	push   $0x60
  jmp alltraps
8010692e:	e9 70 f6 ff ff       	jmp    80105fa3 <alltraps>

80106933 <vector97>:
.globl vector97
vector97:
  pushl $0
80106933:	6a 00                	push   $0x0
  pushl $97
80106935:	6a 61                	push   $0x61
  jmp alltraps
80106937:	e9 67 f6 ff ff       	jmp    80105fa3 <alltraps>

8010693c <vector98>:
.globl vector98
vector98:
  pushl $0
8010693c:	6a 00                	push   $0x0
  pushl $98
8010693e:	6a 62                	push   $0x62
  jmp alltraps
80106940:	e9 5e f6 ff ff       	jmp    80105fa3 <alltraps>

80106945 <vector99>:
.globl vector99
vector99:
  pushl $0
80106945:	6a 00                	push   $0x0
  pushl $99
80106947:	6a 63                	push   $0x63
  jmp alltraps
80106949:	e9 55 f6 ff ff       	jmp    80105fa3 <alltraps>

8010694e <vector100>:
.globl vector100
vector100:
  pushl $0
8010694e:	6a 00                	push   $0x0
  pushl $100
80106950:	6a 64                	push   $0x64
  jmp alltraps
80106952:	e9 4c f6 ff ff       	jmp    80105fa3 <alltraps>

80106957 <vector101>:
.globl vector101
vector101:
  pushl $0
80106957:	6a 00                	push   $0x0
  pushl $101
80106959:	6a 65                	push   $0x65
  jmp alltraps
8010695b:	e9 43 f6 ff ff       	jmp    80105fa3 <alltraps>

80106960 <vector102>:
.globl vector102
vector102:
  pushl $0
80106960:	6a 00                	push   $0x0
  pushl $102
80106962:	6a 66                	push   $0x66
  jmp alltraps
80106964:	e9 3a f6 ff ff       	jmp    80105fa3 <alltraps>

80106969 <vector103>:
.globl vector103
vector103:
  pushl $0
80106969:	6a 00                	push   $0x0
  pushl $103
8010696b:	6a 67                	push   $0x67
  jmp alltraps
8010696d:	e9 31 f6 ff ff       	jmp    80105fa3 <alltraps>

80106972 <vector104>:
.globl vector104
vector104:
  pushl $0
80106972:	6a 00                	push   $0x0
  pushl $104
80106974:	6a 68                	push   $0x68
  jmp alltraps
80106976:	e9 28 f6 ff ff       	jmp    80105fa3 <alltraps>

8010697b <vector105>:
.globl vector105
vector105:
  pushl $0
8010697b:	6a 00                	push   $0x0
  pushl $105
8010697d:	6a 69                	push   $0x69
  jmp alltraps
8010697f:	e9 1f f6 ff ff       	jmp    80105fa3 <alltraps>

80106984 <vector106>:
.globl vector106
vector106:
  pushl $0
80106984:	6a 00                	push   $0x0
  pushl $106
80106986:	6a 6a                	push   $0x6a
  jmp alltraps
80106988:	e9 16 f6 ff ff       	jmp    80105fa3 <alltraps>

8010698d <vector107>:
.globl vector107
vector107:
  pushl $0
8010698d:	6a 00                	push   $0x0
  pushl $107
8010698f:	6a 6b                	push   $0x6b
  jmp alltraps
80106991:	e9 0d f6 ff ff       	jmp    80105fa3 <alltraps>

80106996 <vector108>:
.globl vector108
vector108:
  pushl $0
80106996:	6a 00                	push   $0x0
  pushl $108
80106998:	6a 6c                	push   $0x6c
  jmp alltraps
8010699a:	e9 04 f6 ff ff       	jmp    80105fa3 <alltraps>

8010699f <vector109>:
.globl vector109
vector109:
  pushl $0
8010699f:	6a 00                	push   $0x0
  pushl $109
801069a1:	6a 6d                	push   $0x6d
  jmp alltraps
801069a3:	e9 fb f5 ff ff       	jmp    80105fa3 <alltraps>

801069a8 <vector110>:
.globl vector110
vector110:
  pushl $0
801069a8:	6a 00                	push   $0x0
  pushl $110
801069aa:	6a 6e                	push   $0x6e
  jmp alltraps
801069ac:	e9 f2 f5 ff ff       	jmp    80105fa3 <alltraps>

801069b1 <vector111>:
.globl vector111
vector111:
  pushl $0
801069b1:	6a 00                	push   $0x0
  pushl $111
801069b3:	6a 6f                	push   $0x6f
  jmp alltraps
801069b5:	e9 e9 f5 ff ff       	jmp    80105fa3 <alltraps>

801069ba <vector112>:
.globl vector112
vector112:
  pushl $0
801069ba:	6a 00                	push   $0x0
  pushl $112
801069bc:	6a 70                	push   $0x70
  jmp alltraps
801069be:	e9 e0 f5 ff ff       	jmp    80105fa3 <alltraps>

801069c3 <vector113>:
.globl vector113
vector113:
  pushl $0
801069c3:	6a 00                	push   $0x0
  pushl $113
801069c5:	6a 71                	push   $0x71
  jmp alltraps
801069c7:	e9 d7 f5 ff ff       	jmp    80105fa3 <alltraps>

801069cc <vector114>:
.globl vector114
vector114:
  pushl $0
801069cc:	6a 00                	push   $0x0
  pushl $114
801069ce:	6a 72                	push   $0x72
  jmp alltraps
801069d0:	e9 ce f5 ff ff       	jmp    80105fa3 <alltraps>

801069d5 <vector115>:
.globl vector115
vector115:
  pushl $0
801069d5:	6a 00                	push   $0x0
  pushl $115
801069d7:	6a 73                	push   $0x73
  jmp alltraps
801069d9:	e9 c5 f5 ff ff       	jmp    80105fa3 <alltraps>

801069de <vector116>:
.globl vector116
vector116:
  pushl $0
801069de:	6a 00                	push   $0x0
  pushl $116
801069e0:	6a 74                	push   $0x74
  jmp alltraps
801069e2:	e9 bc f5 ff ff       	jmp    80105fa3 <alltraps>

801069e7 <vector117>:
.globl vector117
vector117:
  pushl $0
801069e7:	6a 00                	push   $0x0
  pushl $117
801069e9:	6a 75                	push   $0x75
  jmp alltraps
801069eb:	e9 b3 f5 ff ff       	jmp    80105fa3 <alltraps>

801069f0 <vector118>:
.globl vector118
vector118:
  pushl $0
801069f0:	6a 00                	push   $0x0
  pushl $118
801069f2:	6a 76                	push   $0x76
  jmp alltraps
801069f4:	e9 aa f5 ff ff       	jmp    80105fa3 <alltraps>

801069f9 <vector119>:
.globl vector119
vector119:
  pushl $0
801069f9:	6a 00                	push   $0x0
  pushl $119
801069fb:	6a 77                	push   $0x77
  jmp alltraps
801069fd:	e9 a1 f5 ff ff       	jmp    80105fa3 <alltraps>

80106a02 <vector120>:
.globl vector120
vector120:
  pushl $0
80106a02:	6a 00                	push   $0x0
  pushl $120
80106a04:	6a 78                	push   $0x78
  jmp alltraps
80106a06:	e9 98 f5 ff ff       	jmp    80105fa3 <alltraps>

80106a0b <vector121>:
.globl vector121
vector121:
  pushl $0
80106a0b:	6a 00                	push   $0x0
  pushl $121
80106a0d:	6a 79                	push   $0x79
  jmp alltraps
80106a0f:	e9 8f f5 ff ff       	jmp    80105fa3 <alltraps>

80106a14 <vector122>:
.globl vector122
vector122:
  pushl $0
80106a14:	6a 00                	push   $0x0
  pushl $122
80106a16:	6a 7a                	push   $0x7a
  jmp alltraps
80106a18:	e9 86 f5 ff ff       	jmp    80105fa3 <alltraps>

80106a1d <vector123>:
.globl vector123
vector123:
  pushl $0
80106a1d:	6a 00                	push   $0x0
  pushl $123
80106a1f:	6a 7b                	push   $0x7b
  jmp alltraps
80106a21:	e9 7d f5 ff ff       	jmp    80105fa3 <alltraps>

80106a26 <vector124>:
.globl vector124
vector124:
  pushl $0
80106a26:	6a 00                	push   $0x0
  pushl $124
80106a28:	6a 7c                	push   $0x7c
  jmp alltraps
80106a2a:	e9 74 f5 ff ff       	jmp    80105fa3 <alltraps>

80106a2f <vector125>:
.globl vector125
vector125:
  pushl $0
80106a2f:	6a 00                	push   $0x0
  pushl $125
80106a31:	6a 7d                	push   $0x7d
  jmp alltraps
80106a33:	e9 6b f5 ff ff       	jmp    80105fa3 <alltraps>

80106a38 <vector126>:
.globl vector126
vector126:
  pushl $0
80106a38:	6a 00                	push   $0x0
  pushl $126
80106a3a:	6a 7e                	push   $0x7e
  jmp alltraps
80106a3c:	e9 62 f5 ff ff       	jmp    80105fa3 <alltraps>

80106a41 <vector127>:
.globl vector127
vector127:
  pushl $0
80106a41:	6a 00                	push   $0x0
  pushl $127
80106a43:	6a 7f                	push   $0x7f
  jmp alltraps
80106a45:	e9 59 f5 ff ff       	jmp    80105fa3 <alltraps>

80106a4a <vector128>:
.globl vector128
vector128:
  pushl $0
80106a4a:	6a 00                	push   $0x0
  pushl $128
80106a4c:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106a51:	e9 4d f5 ff ff       	jmp    80105fa3 <alltraps>

80106a56 <vector129>:
.globl vector129
vector129:
  pushl $0
80106a56:	6a 00                	push   $0x0
  pushl $129
80106a58:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106a5d:	e9 41 f5 ff ff       	jmp    80105fa3 <alltraps>

80106a62 <vector130>:
.globl vector130
vector130:
  pushl $0
80106a62:	6a 00                	push   $0x0
  pushl $130
80106a64:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106a69:	e9 35 f5 ff ff       	jmp    80105fa3 <alltraps>

80106a6e <vector131>:
.globl vector131
vector131:
  pushl $0
80106a6e:	6a 00                	push   $0x0
  pushl $131
80106a70:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106a75:	e9 29 f5 ff ff       	jmp    80105fa3 <alltraps>

80106a7a <vector132>:
.globl vector132
vector132:
  pushl $0
80106a7a:	6a 00                	push   $0x0
  pushl $132
80106a7c:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106a81:	e9 1d f5 ff ff       	jmp    80105fa3 <alltraps>

80106a86 <vector133>:
.globl vector133
vector133:
  pushl $0
80106a86:	6a 00                	push   $0x0
  pushl $133
80106a88:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106a8d:	e9 11 f5 ff ff       	jmp    80105fa3 <alltraps>

80106a92 <vector134>:
.globl vector134
vector134:
  pushl $0
80106a92:	6a 00                	push   $0x0
  pushl $134
80106a94:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106a99:	e9 05 f5 ff ff       	jmp    80105fa3 <alltraps>

80106a9e <vector135>:
.globl vector135
vector135:
  pushl $0
80106a9e:	6a 00                	push   $0x0
  pushl $135
80106aa0:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106aa5:	e9 f9 f4 ff ff       	jmp    80105fa3 <alltraps>

80106aaa <vector136>:
.globl vector136
vector136:
  pushl $0
80106aaa:	6a 00                	push   $0x0
  pushl $136
80106aac:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106ab1:	e9 ed f4 ff ff       	jmp    80105fa3 <alltraps>

80106ab6 <vector137>:
.globl vector137
vector137:
  pushl $0
80106ab6:	6a 00                	push   $0x0
  pushl $137
80106ab8:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106abd:	e9 e1 f4 ff ff       	jmp    80105fa3 <alltraps>

80106ac2 <vector138>:
.globl vector138
vector138:
  pushl $0
80106ac2:	6a 00                	push   $0x0
  pushl $138
80106ac4:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106ac9:	e9 d5 f4 ff ff       	jmp    80105fa3 <alltraps>

80106ace <vector139>:
.globl vector139
vector139:
  pushl $0
80106ace:	6a 00                	push   $0x0
  pushl $139
80106ad0:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106ad5:	e9 c9 f4 ff ff       	jmp    80105fa3 <alltraps>

80106ada <vector140>:
.globl vector140
vector140:
  pushl $0
80106ada:	6a 00                	push   $0x0
  pushl $140
80106adc:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106ae1:	e9 bd f4 ff ff       	jmp    80105fa3 <alltraps>

80106ae6 <vector141>:
.globl vector141
vector141:
  pushl $0
80106ae6:	6a 00                	push   $0x0
  pushl $141
80106ae8:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106aed:	e9 b1 f4 ff ff       	jmp    80105fa3 <alltraps>

80106af2 <vector142>:
.globl vector142
vector142:
  pushl $0
80106af2:	6a 00                	push   $0x0
  pushl $142
80106af4:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106af9:	e9 a5 f4 ff ff       	jmp    80105fa3 <alltraps>

80106afe <vector143>:
.globl vector143
vector143:
  pushl $0
80106afe:	6a 00                	push   $0x0
  pushl $143
80106b00:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106b05:	e9 99 f4 ff ff       	jmp    80105fa3 <alltraps>

80106b0a <vector144>:
.globl vector144
vector144:
  pushl $0
80106b0a:	6a 00                	push   $0x0
  pushl $144
80106b0c:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106b11:	e9 8d f4 ff ff       	jmp    80105fa3 <alltraps>

80106b16 <vector145>:
.globl vector145
vector145:
  pushl $0
80106b16:	6a 00                	push   $0x0
  pushl $145
80106b18:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106b1d:	e9 81 f4 ff ff       	jmp    80105fa3 <alltraps>

80106b22 <vector146>:
.globl vector146
vector146:
  pushl $0
80106b22:	6a 00                	push   $0x0
  pushl $146
80106b24:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106b29:	e9 75 f4 ff ff       	jmp    80105fa3 <alltraps>

80106b2e <vector147>:
.globl vector147
vector147:
  pushl $0
80106b2e:	6a 00                	push   $0x0
  pushl $147
80106b30:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106b35:	e9 69 f4 ff ff       	jmp    80105fa3 <alltraps>

80106b3a <vector148>:
.globl vector148
vector148:
  pushl $0
80106b3a:	6a 00                	push   $0x0
  pushl $148
80106b3c:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106b41:	e9 5d f4 ff ff       	jmp    80105fa3 <alltraps>

80106b46 <vector149>:
.globl vector149
vector149:
  pushl $0
80106b46:	6a 00                	push   $0x0
  pushl $149
80106b48:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106b4d:	e9 51 f4 ff ff       	jmp    80105fa3 <alltraps>

80106b52 <vector150>:
.globl vector150
vector150:
  pushl $0
80106b52:	6a 00                	push   $0x0
  pushl $150
80106b54:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106b59:	e9 45 f4 ff ff       	jmp    80105fa3 <alltraps>

80106b5e <vector151>:
.globl vector151
vector151:
  pushl $0
80106b5e:	6a 00                	push   $0x0
  pushl $151
80106b60:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106b65:	e9 39 f4 ff ff       	jmp    80105fa3 <alltraps>

80106b6a <vector152>:
.globl vector152
vector152:
  pushl $0
80106b6a:	6a 00                	push   $0x0
  pushl $152
80106b6c:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106b71:	e9 2d f4 ff ff       	jmp    80105fa3 <alltraps>

80106b76 <vector153>:
.globl vector153
vector153:
  pushl $0
80106b76:	6a 00                	push   $0x0
  pushl $153
80106b78:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106b7d:	e9 21 f4 ff ff       	jmp    80105fa3 <alltraps>

80106b82 <vector154>:
.globl vector154
vector154:
  pushl $0
80106b82:	6a 00                	push   $0x0
  pushl $154
80106b84:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106b89:	e9 15 f4 ff ff       	jmp    80105fa3 <alltraps>

80106b8e <vector155>:
.globl vector155
vector155:
  pushl $0
80106b8e:	6a 00                	push   $0x0
  pushl $155
80106b90:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106b95:	e9 09 f4 ff ff       	jmp    80105fa3 <alltraps>

80106b9a <vector156>:
.globl vector156
vector156:
  pushl $0
80106b9a:	6a 00                	push   $0x0
  pushl $156
80106b9c:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106ba1:	e9 fd f3 ff ff       	jmp    80105fa3 <alltraps>

80106ba6 <vector157>:
.globl vector157
vector157:
  pushl $0
80106ba6:	6a 00                	push   $0x0
  pushl $157
80106ba8:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106bad:	e9 f1 f3 ff ff       	jmp    80105fa3 <alltraps>

80106bb2 <vector158>:
.globl vector158
vector158:
  pushl $0
80106bb2:	6a 00                	push   $0x0
  pushl $158
80106bb4:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106bb9:	e9 e5 f3 ff ff       	jmp    80105fa3 <alltraps>

80106bbe <vector159>:
.globl vector159
vector159:
  pushl $0
80106bbe:	6a 00                	push   $0x0
  pushl $159
80106bc0:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106bc5:	e9 d9 f3 ff ff       	jmp    80105fa3 <alltraps>

80106bca <vector160>:
.globl vector160
vector160:
  pushl $0
80106bca:	6a 00                	push   $0x0
  pushl $160
80106bcc:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106bd1:	e9 cd f3 ff ff       	jmp    80105fa3 <alltraps>

80106bd6 <vector161>:
.globl vector161
vector161:
  pushl $0
80106bd6:	6a 00                	push   $0x0
  pushl $161
80106bd8:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106bdd:	e9 c1 f3 ff ff       	jmp    80105fa3 <alltraps>

80106be2 <vector162>:
.globl vector162
vector162:
  pushl $0
80106be2:	6a 00                	push   $0x0
  pushl $162
80106be4:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106be9:	e9 b5 f3 ff ff       	jmp    80105fa3 <alltraps>

80106bee <vector163>:
.globl vector163
vector163:
  pushl $0
80106bee:	6a 00                	push   $0x0
  pushl $163
80106bf0:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106bf5:	e9 a9 f3 ff ff       	jmp    80105fa3 <alltraps>

80106bfa <vector164>:
.globl vector164
vector164:
  pushl $0
80106bfa:	6a 00                	push   $0x0
  pushl $164
80106bfc:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106c01:	e9 9d f3 ff ff       	jmp    80105fa3 <alltraps>

80106c06 <vector165>:
.globl vector165
vector165:
  pushl $0
80106c06:	6a 00                	push   $0x0
  pushl $165
80106c08:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106c0d:	e9 91 f3 ff ff       	jmp    80105fa3 <alltraps>

80106c12 <vector166>:
.globl vector166
vector166:
  pushl $0
80106c12:	6a 00                	push   $0x0
  pushl $166
80106c14:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106c19:	e9 85 f3 ff ff       	jmp    80105fa3 <alltraps>

80106c1e <vector167>:
.globl vector167
vector167:
  pushl $0
80106c1e:	6a 00                	push   $0x0
  pushl $167
80106c20:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106c25:	e9 79 f3 ff ff       	jmp    80105fa3 <alltraps>

80106c2a <vector168>:
.globl vector168
vector168:
  pushl $0
80106c2a:	6a 00                	push   $0x0
  pushl $168
80106c2c:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106c31:	e9 6d f3 ff ff       	jmp    80105fa3 <alltraps>

80106c36 <vector169>:
.globl vector169
vector169:
  pushl $0
80106c36:	6a 00                	push   $0x0
  pushl $169
80106c38:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106c3d:	e9 61 f3 ff ff       	jmp    80105fa3 <alltraps>

80106c42 <vector170>:
.globl vector170
vector170:
  pushl $0
80106c42:	6a 00                	push   $0x0
  pushl $170
80106c44:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106c49:	e9 55 f3 ff ff       	jmp    80105fa3 <alltraps>

80106c4e <vector171>:
.globl vector171
vector171:
  pushl $0
80106c4e:	6a 00                	push   $0x0
  pushl $171
80106c50:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106c55:	e9 49 f3 ff ff       	jmp    80105fa3 <alltraps>

80106c5a <vector172>:
.globl vector172
vector172:
  pushl $0
80106c5a:	6a 00                	push   $0x0
  pushl $172
80106c5c:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106c61:	e9 3d f3 ff ff       	jmp    80105fa3 <alltraps>

80106c66 <vector173>:
.globl vector173
vector173:
  pushl $0
80106c66:	6a 00                	push   $0x0
  pushl $173
80106c68:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106c6d:	e9 31 f3 ff ff       	jmp    80105fa3 <alltraps>

80106c72 <vector174>:
.globl vector174
vector174:
  pushl $0
80106c72:	6a 00                	push   $0x0
  pushl $174
80106c74:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106c79:	e9 25 f3 ff ff       	jmp    80105fa3 <alltraps>

80106c7e <vector175>:
.globl vector175
vector175:
  pushl $0
80106c7e:	6a 00                	push   $0x0
  pushl $175
80106c80:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106c85:	e9 19 f3 ff ff       	jmp    80105fa3 <alltraps>

80106c8a <vector176>:
.globl vector176
vector176:
  pushl $0
80106c8a:	6a 00                	push   $0x0
  pushl $176
80106c8c:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106c91:	e9 0d f3 ff ff       	jmp    80105fa3 <alltraps>

80106c96 <vector177>:
.globl vector177
vector177:
  pushl $0
80106c96:	6a 00                	push   $0x0
  pushl $177
80106c98:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106c9d:	e9 01 f3 ff ff       	jmp    80105fa3 <alltraps>

80106ca2 <vector178>:
.globl vector178
vector178:
  pushl $0
80106ca2:	6a 00                	push   $0x0
  pushl $178
80106ca4:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106ca9:	e9 f5 f2 ff ff       	jmp    80105fa3 <alltraps>

80106cae <vector179>:
.globl vector179
vector179:
  pushl $0
80106cae:	6a 00                	push   $0x0
  pushl $179
80106cb0:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106cb5:	e9 e9 f2 ff ff       	jmp    80105fa3 <alltraps>

80106cba <vector180>:
.globl vector180
vector180:
  pushl $0
80106cba:	6a 00                	push   $0x0
  pushl $180
80106cbc:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106cc1:	e9 dd f2 ff ff       	jmp    80105fa3 <alltraps>

80106cc6 <vector181>:
.globl vector181
vector181:
  pushl $0
80106cc6:	6a 00                	push   $0x0
  pushl $181
80106cc8:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106ccd:	e9 d1 f2 ff ff       	jmp    80105fa3 <alltraps>

80106cd2 <vector182>:
.globl vector182
vector182:
  pushl $0
80106cd2:	6a 00                	push   $0x0
  pushl $182
80106cd4:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106cd9:	e9 c5 f2 ff ff       	jmp    80105fa3 <alltraps>

80106cde <vector183>:
.globl vector183
vector183:
  pushl $0
80106cde:	6a 00                	push   $0x0
  pushl $183
80106ce0:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106ce5:	e9 b9 f2 ff ff       	jmp    80105fa3 <alltraps>

80106cea <vector184>:
.globl vector184
vector184:
  pushl $0
80106cea:	6a 00                	push   $0x0
  pushl $184
80106cec:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106cf1:	e9 ad f2 ff ff       	jmp    80105fa3 <alltraps>

80106cf6 <vector185>:
.globl vector185
vector185:
  pushl $0
80106cf6:	6a 00                	push   $0x0
  pushl $185
80106cf8:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106cfd:	e9 a1 f2 ff ff       	jmp    80105fa3 <alltraps>

80106d02 <vector186>:
.globl vector186
vector186:
  pushl $0
80106d02:	6a 00                	push   $0x0
  pushl $186
80106d04:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106d09:	e9 95 f2 ff ff       	jmp    80105fa3 <alltraps>

80106d0e <vector187>:
.globl vector187
vector187:
  pushl $0
80106d0e:	6a 00                	push   $0x0
  pushl $187
80106d10:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106d15:	e9 89 f2 ff ff       	jmp    80105fa3 <alltraps>

80106d1a <vector188>:
.globl vector188
vector188:
  pushl $0
80106d1a:	6a 00                	push   $0x0
  pushl $188
80106d1c:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106d21:	e9 7d f2 ff ff       	jmp    80105fa3 <alltraps>

80106d26 <vector189>:
.globl vector189
vector189:
  pushl $0
80106d26:	6a 00                	push   $0x0
  pushl $189
80106d28:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106d2d:	e9 71 f2 ff ff       	jmp    80105fa3 <alltraps>

80106d32 <vector190>:
.globl vector190
vector190:
  pushl $0
80106d32:	6a 00                	push   $0x0
  pushl $190
80106d34:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106d39:	e9 65 f2 ff ff       	jmp    80105fa3 <alltraps>

80106d3e <vector191>:
.globl vector191
vector191:
  pushl $0
80106d3e:	6a 00                	push   $0x0
  pushl $191
80106d40:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106d45:	e9 59 f2 ff ff       	jmp    80105fa3 <alltraps>

80106d4a <vector192>:
.globl vector192
vector192:
  pushl $0
80106d4a:	6a 00                	push   $0x0
  pushl $192
80106d4c:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106d51:	e9 4d f2 ff ff       	jmp    80105fa3 <alltraps>

80106d56 <vector193>:
.globl vector193
vector193:
  pushl $0
80106d56:	6a 00                	push   $0x0
  pushl $193
80106d58:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106d5d:	e9 41 f2 ff ff       	jmp    80105fa3 <alltraps>

80106d62 <vector194>:
.globl vector194
vector194:
  pushl $0
80106d62:	6a 00                	push   $0x0
  pushl $194
80106d64:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106d69:	e9 35 f2 ff ff       	jmp    80105fa3 <alltraps>

80106d6e <vector195>:
.globl vector195
vector195:
  pushl $0
80106d6e:	6a 00                	push   $0x0
  pushl $195
80106d70:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106d75:	e9 29 f2 ff ff       	jmp    80105fa3 <alltraps>

80106d7a <vector196>:
.globl vector196
vector196:
  pushl $0
80106d7a:	6a 00                	push   $0x0
  pushl $196
80106d7c:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106d81:	e9 1d f2 ff ff       	jmp    80105fa3 <alltraps>

80106d86 <vector197>:
.globl vector197
vector197:
  pushl $0
80106d86:	6a 00                	push   $0x0
  pushl $197
80106d88:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106d8d:	e9 11 f2 ff ff       	jmp    80105fa3 <alltraps>

80106d92 <vector198>:
.globl vector198
vector198:
  pushl $0
80106d92:	6a 00                	push   $0x0
  pushl $198
80106d94:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106d99:	e9 05 f2 ff ff       	jmp    80105fa3 <alltraps>

80106d9e <vector199>:
.globl vector199
vector199:
  pushl $0
80106d9e:	6a 00                	push   $0x0
  pushl $199
80106da0:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106da5:	e9 f9 f1 ff ff       	jmp    80105fa3 <alltraps>

80106daa <vector200>:
.globl vector200
vector200:
  pushl $0
80106daa:	6a 00                	push   $0x0
  pushl $200
80106dac:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106db1:	e9 ed f1 ff ff       	jmp    80105fa3 <alltraps>

80106db6 <vector201>:
.globl vector201
vector201:
  pushl $0
80106db6:	6a 00                	push   $0x0
  pushl $201
80106db8:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80106dbd:	e9 e1 f1 ff ff       	jmp    80105fa3 <alltraps>

80106dc2 <vector202>:
.globl vector202
vector202:
  pushl $0
80106dc2:	6a 00                	push   $0x0
  pushl $202
80106dc4:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106dc9:	e9 d5 f1 ff ff       	jmp    80105fa3 <alltraps>

80106dce <vector203>:
.globl vector203
vector203:
  pushl $0
80106dce:	6a 00                	push   $0x0
  pushl $203
80106dd0:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106dd5:	e9 c9 f1 ff ff       	jmp    80105fa3 <alltraps>

80106dda <vector204>:
.globl vector204
vector204:
  pushl $0
80106dda:	6a 00                	push   $0x0
  pushl $204
80106ddc:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106de1:	e9 bd f1 ff ff       	jmp    80105fa3 <alltraps>

80106de6 <vector205>:
.globl vector205
vector205:
  pushl $0
80106de6:	6a 00                	push   $0x0
  pushl $205
80106de8:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106ded:	e9 b1 f1 ff ff       	jmp    80105fa3 <alltraps>

80106df2 <vector206>:
.globl vector206
vector206:
  pushl $0
80106df2:	6a 00                	push   $0x0
  pushl $206
80106df4:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106df9:	e9 a5 f1 ff ff       	jmp    80105fa3 <alltraps>

80106dfe <vector207>:
.globl vector207
vector207:
  pushl $0
80106dfe:	6a 00                	push   $0x0
  pushl $207
80106e00:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106e05:	e9 99 f1 ff ff       	jmp    80105fa3 <alltraps>

80106e0a <vector208>:
.globl vector208
vector208:
  pushl $0
80106e0a:	6a 00                	push   $0x0
  pushl $208
80106e0c:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106e11:	e9 8d f1 ff ff       	jmp    80105fa3 <alltraps>

80106e16 <vector209>:
.globl vector209
vector209:
  pushl $0
80106e16:	6a 00                	push   $0x0
  pushl $209
80106e18:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106e1d:	e9 81 f1 ff ff       	jmp    80105fa3 <alltraps>

80106e22 <vector210>:
.globl vector210
vector210:
  pushl $0
80106e22:	6a 00                	push   $0x0
  pushl $210
80106e24:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106e29:	e9 75 f1 ff ff       	jmp    80105fa3 <alltraps>

80106e2e <vector211>:
.globl vector211
vector211:
  pushl $0
80106e2e:	6a 00                	push   $0x0
  pushl $211
80106e30:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106e35:	e9 69 f1 ff ff       	jmp    80105fa3 <alltraps>

80106e3a <vector212>:
.globl vector212
vector212:
  pushl $0
80106e3a:	6a 00                	push   $0x0
  pushl $212
80106e3c:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106e41:	e9 5d f1 ff ff       	jmp    80105fa3 <alltraps>

80106e46 <vector213>:
.globl vector213
vector213:
  pushl $0
80106e46:	6a 00                	push   $0x0
  pushl $213
80106e48:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80106e4d:	e9 51 f1 ff ff       	jmp    80105fa3 <alltraps>

80106e52 <vector214>:
.globl vector214
vector214:
  pushl $0
80106e52:	6a 00                	push   $0x0
  pushl $214
80106e54:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106e59:	e9 45 f1 ff ff       	jmp    80105fa3 <alltraps>

80106e5e <vector215>:
.globl vector215
vector215:
  pushl $0
80106e5e:	6a 00                	push   $0x0
  pushl $215
80106e60:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106e65:	e9 39 f1 ff ff       	jmp    80105fa3 <alltraps>

80106e6a <vector216>:
.globl vector216
vector216:
  pushl $0
80106e6a:	6a 00                	push   $0x0
  pushl $216
80106e6c:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106e71:	e9 2d f1 ff ff       	jmp    80105fa3 <alltraps>

80106e76 <vector217>:
.globl vector217
vector217:
  pushl $0
80106e76:	6a 00                	push   $0x0
  pushl $217
80106e78:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80106e7d:	e9 21 f1 ff ff       	jmp    80105fa3 <alltraps>

80106e82 <vector218>:
.globl vector218
vector218:
  pushl $0
80106e82:	6a 00                	push   $0x0
  pushl $218
80106e84:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106e89:	e9 15 f1 ff ff       	jmp    80105fa3 <alltraps>

80106e8e <vector219>:
.globl vector219
vector219:
  pushl $0
80106e8e:	6a 00                	push   $0x0
  pushl $219
80106e90:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106e95:	e9 09 f1 ff ff       	jmp    80105fa3 <alltraps>

80106e9a <vector220>:
.globl vector220
vector220:
  pushl $0
80106e9a:	6a 00                	push   $0x0
  pushl $220
80106e9c:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80106ea1:	e9 fd f0 ff ff       	jmp    80105fa3 <alltraps>

80106ea6 <vector221>:
.globl vector221
vector221:
  pushl $0
80106ea6:	6a 00                	push   $0x0
  pushl $221
80106ea8:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80106ead:	e9 f1 f0 ff ff       	jmp    80105fa3 <alltraps>

80106eb2 <vector222>:
.globl vector222
vector222:
  pushl $0
80106eb2:	6a 00                	push   $0x0
  pushl $222
80106eb4:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80106eb9:	e9 e5 f0 ff ff       	jmp    80105fa3 <alltraps>

80106ebe <vector223>:
.globl vector223
vector223:
  pushl $0
80106ebe:	6a 00                	push   $0x0
  pushl $223
80106ec0:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106ec5:	e9 d9 f0 ff ff       	jmp    80105fa3 <alltraps>

80106eca <vector224>:
.globl vector224
vector224:
  pushl $0
80106eca:	6a 00                	push   $0x0
  pushl $224
80106ecc:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80106ed1:	e9 cd f0 ff ff       	jmp    80105fa3 <alltraps>

80106ed6 <vector225>:
.globl vector225
vector225:
  pushl $0
80106ed6:	6a 00                	push   $0x0
  pushl $225
80106ed8:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80106edd:	e9 c1 f0 ff ff       	jmp    80105fa3 <alltraps>

80106ee2 <vector226>:
.globl vector226
vector226:
  pushl $0
80106ee2:	6a 00                	push   $0x0
  pushl $226
80106ee4:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80106ee9:	e9 b5 f0 ff ff       	jmp    80105fa3 <alltraps>

80106eee <vector227>:
.globl vector227
vector227:
  pushl $0
80106eee:	6a 00                	push   $0x0
  pushl $227
80106ef0:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80106ef5:	e9 a9 f0 ff ff       	jmp    80105fa3 <alltraps>

80106efa <vector228>:
.globl vector228
vector228:
  pushl $0
80106efa:	6a 00                	push   $0x0
  pushl $228
80106efc:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80106f01:	e9 9d f0 ff ff       	jmp    80105fa3 <alltraps>

80106f06 <vector229>:
.globl vector229
vector229:
  pushl $0
80106f06:	6a 00                	push   $0x0
  pushl $229
80106f08:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80106f0d:	e9 91 f0 ff ff       	jmp    80105fa3 <alltraps>

80106f12 <vector230>:
.globl vector230
vector230:
  pushl $0
80106f12:	6a 00                	push   $0x0
  pushl $230
80106f14:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80106f19:	e9 85 f0 ff ff       	jmp    80105fa3 <alltraps>

80106f1e <vector231>:
.globl vector231
vector231:
  pushl $0
80106f1e:	6a 00                	push   $0x0
  pushl $231
80106f20:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80106f25:	e9 79 f0 ff ff       	jmp    80105fa3 <alltraps>

80106f2a <vector232>:
.globl vector232
vector232:
  pushl $0
80106f2a:	6a 00                	push   $0x0
  pushl $232
80106f2c:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80106f31:	e9 6d f0 ff ff       	jmp    80105fa3 <alltraps>

80106f36 <vector233>:
.globl vector233
vector233:
  pushl $0
80106f36:	6a 00                	push   $0x0
  pushl $233
80106f38:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80106f3d:	e9 61 f0 ff ff       	jmp    80105fa3 <alltraps>

80106f42 <vector234>:
.globl vector234
vector234:
  pushl $0
80106f42:	6a 00                	push   $0x0
  pushl $234
80106f44:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80106f49:	e9 55 f0 ff ff       	jmp    80105fa3 <alltraps>

80106f4e <vector235>:
.globl vector235
vector235:
  pushl $0
80106f4e:	6a 00                	push   $0x0
  pushl $235
80106f50:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80106f55:	e9 49 f0 ff ff       	jmp    80105fa3 <alltraps>

80106f5a <vector236>:
.globl vector236
vector236:
  pushl $0
80106f5a:	6a 00                	push   $0x0
  pushl $236
80106f5c:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80106f61:	e9 3d f0 ff ff       	jmp    80105fa3 <alltraps>

80106f66 <vector237>:
.globl vector237
vector237:
  pushl $0
80106f66:	6a 00                	push   $0x0
  pushl $237
80106f68:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80106f6d:	e9 31 f0 ff ff       	jmp    80105fa3 <alltraps>

80106f72 <vector238>:
.globl vector238
vector238:
  pushl $0
80106f72:	6a 00                	push   $0x0
  pushl $238
80106f74:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80106f79:	e9 25 f0 ff ff       	jmp    80105fa3 <alltraps>

80106f7e <vector239>:
.globl vector239
vector239:
  pushl $0
80106f7e:	6a 00                	push   $0x0
  pushl $239
80106f80:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80106f85:	e9 19 f0 ff ff       	jmp    80105fa3 <alltraps>

80106f8a <vector240>:
.globl vector240
vector240:
  pushl $0
80106f8a:	6a 00                	push   $0x0
  pushl $240
80106f8c:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80106f91:	e9 0d f0 ff ff       	jmp    80105fa3 <alltraps>

80106f96 <vector241>:
.globl vector241
vector241:
  pushl $0
80106f96:	6a 00                	push   $0x0
  pushl $241
80106f98:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80106f9d:	e9 01 f0 ff ff       	jmp    80105fa3 <alltraps>

80106fa2 <vector242>:
.globl vector242
vector242:
  pushl $0
80106fa2:	6a 00                	push   $0x0
  pushl $242
80106fa4:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80106fa9:	e9 f5 ef ff ff       	jmp    80105fa3 <alltraps>

80106fae <vector243>:
.globl vector243
vector243:
  pushl $0
80106fae:	6a 00                	push   $0x0
  pushl $243
80106fb0:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80106fb5:	e9 e9 ef ff ff       	jmp    80105fa3 <alltraps>

80106fba <vector244>:
.globl vector244
vector244:
  pushl $0
80106fba:	6a 00                	push   $0x0
  pushl $244
80106fbc:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80106fc1:	e9 dd ef ff ff       	jmp    80105fa3 <alltraps>

80106fc6 <vector245>:
.globl vector245
vector245:
  pushl $0
80106fc6:	6a 00                	push   $0x0
  pushl $245
80106fc8:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80106fcd:	e9 d1 ef ff ff       	jmp    80105fa3 <alltraps>

80106fd2 <vector246>:
.globl vector246
vector246:
  pushl $0
80106fd2:	6a 00                	push   $0x0
  pushl $246
80106fd4:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80106fd9:	e9 c5 ef ff ff       	jmp    80105fa3 <alltraps>

80106fde <vector247>:
.globl vector247
vector247:
  pushl $0
80106fde:	6a 00                	push   $0x0
  pushl $247
80106fe0:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80106fe5:	e9 b9 ef ff ff       	jmp    80105fa3 <alltraps>

80106fea <vector248>:
.globl vector248
vector248:
  pushl $0
80106fea:	6a 00                	push   $0x0
  pushl $248
80106fec:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80106ff1:	e9 ad ef ff ff       	jmp    80105fa3 <alltraps>

80106ff6 <vector249>:
.globl vector249
vector249:
  pushl $0
80106ff6:	6a 00                	push   $0x0
  pushl $249
80106ff8:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80106ffd:	e9 a1 ef ff ff       	jmp    80105fa3 <alltraps>

80107002 <vector250>:
.globl vector250
vector250:
  pushl $0
80107002:	6a 00                	push   $0x0
  pushl $250
80107004:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107009:	e9 95 ef ff ff       	jmp    80105fa3 <alltraps>

8010700e <vector251>:
.globl vector251
vector251:
  pushl $0
8010700e:	6a 00                	push   $0x0
  pushl $251
80107010:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107015:	e9 89 ef ff ff       	jmp    80105fa3 <alltraps>

8010701a <vector252>:
.globl vector252
vector252:
  pushl $0
8010701a:	6a 00                	push   $0x0
  pushl $252
8010701c:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107021:	e9 7d ef ff ff       	jmp    80105fa3 <alltraps>

80107026 <vector253>:
.globl vector253
vector253:
  pushl $0
80107026:	6a 00                	push   $0x0
  pushl $253
80107028:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010702d:	e9 71 ef ff ff       	jmp    80105fa3 <alltraps>

80107032 <vector254>:
.globl vector254
vector254:
  pushl $0
80107032:	6a 00                	push   $0x0
  pushl $254
80107034:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107039:	e9 65 ef ff ff       	jmp    80105fa3 <alltraps>

8010703e <vector255>:
.globl vector255
vector255:
  pushl $0
8010703e:	6a 00                	push   $0x0
  pushl $255
80107040:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107045:	e9 59 ef ff ff       	jmp    80105fa3 <alltraps>

8010704a <lgdt>:
{
8010704a:	55                   	push   %ebp
8010704b:	89 e5                	mov    %esp,%ebp
8010704d:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107050:	8b 45 0c             	mov    0xc(%ebp),%eax
80107053:	83 e8 01             	sub    $0x1,%eax
80107056:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010705a:	8b 45 08             	mov    0x8(%ebp),%eax
8010705d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107061:	8b 45 08             	mov    0x8(%ebp),%eax
80107064:	c1 e8 10             	shr    $0x10,%eax
80107067:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
8010706b:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010706e:	0f 01 10             	lgdtl  (%eax)
}
80107071:	90                   	nop
80107072:	c9                   	leave  
80107073:	c3                   	ret    

80107074 <ltr>:
{
80107074:	55                   	push   %ebp
80107075:	89 e5                	mov    %esp,%ebp
80107077:	83 ec 04             	sub    $0x4,%esp
8010707a:	8b 45 08             	mov    0x8(%ebp),%eax
8010707d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107081:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107085:	0f 00 d8             	ltr    %ax
}
80107088:	90                   	nop
80107089:	c9                   	leave  
8010708a:	c3                   	ret    

8010708b <lcr3>:

static inline void
lcr3(uint val)
{
8010708b:	55                   	push   %ebp
8010708c:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010708e:	8b 45 08             	mov    0x8(%ebp),%eax
80107091:	0f 22 d8             	mov    %eax,%cr3
}
80107094:	90                   	nop
80107095:	5d                   	pop    %ebp
80107096:	c3                   	ret    

80107097 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107097:	55                   	push   %ebp
80107098:	89 e5                	mov    %esp,%ebp
8010709a:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
8010709d:	e8 fb c8 ff ff       	call   8010399d <cpuid>
801070a2:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801070a8:	05 80 6a 19 80       	add    $0x80196a80,%eax
801070ad:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801070b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070b3:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801070b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070bc:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801070c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070c5:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801070c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070cc:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801070d0:	83 e2 f0             	and    $0xfffffff0,%edx
801070d3:	83 ca 0a             	or     $0xa,%edx
801070d6:	88 50 7d             	mov    %dl,0x7d(%eax)
801070d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070dc:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801070e0:	83 ca 10             	or     $0x10,%edx
801070e3:	88 50 7d             	mov    %dl,0x7d(%eax)
801070e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070e9:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801070ed:	83 e2 9f             	and    $0xffffff9f,%edx
801070f0:	88 50 7d             	mov    %dl,0x7d(%eax)
801070f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070f6:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801070fa:	83 ca 80             	or     $0xffffff80,%edx
801070fd:	88 50 7d             	mov    %dl,0x7d(%eax)
80107100:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107103:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107107:	83 ca 0f             	or     $0xf,%edx
8010710a:	88 50 7e             	mov    %dl,0x7e(%eax)
8010710d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107110:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107114:	83 e2 ef             	and    $0xffffffef,%edx
80107117:	88 50 7e             	mov    %dl,0x7e(%eax)
8010711a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010711d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107121:	83 e2 df             	and    $0xffffffdf,%edx
80107124:	88 50 7e             	mov    %dl,0x7e(%eax)
80107127:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010712a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010712e:	83 ca 40             	or     $0x40,%edx
80107131:	88 50 7e             	mov    %dl,0x7e(%eax)
80107134:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107137:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010713b:	83 ca 80             	or     $0xffffff80,%edx
8010713e:	88 50 7e             	mov    %dl,0x7e(%eax)
80107141:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107144:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010714b:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107152:	ff ff 
80107154:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107157:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010715e:	00 00 
80107160:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107163:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010716a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010716d:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107174:	83 e2 f0             	and    $0xfffffff0,%edx
80107177:	83 ca 02             	or     $0x2,%edx
8010717a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107180:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107183:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010718a:	83 ca 10             	or     $0x10,%edx
8010718d:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107193:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107196:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010719d:	83 e2 9f             	and    $0xffffff9f,%edx
801071a0:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801071a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071a9:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801071b0:	83 ca 80             	or     $0xffffff80,%edx
801071b3:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801071b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071bc:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801071c3:	83 ca 0f             	or     $0xf,%edx
801071c6:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801071cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071cf:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801071d6:	83 e2 ef             	and    $0xffffffef,%edx
801071d9:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801071df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071e2:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801071e9:	83 e2 df             	and    $0xffffffdf,%edx
801071ec:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801071f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071f5:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801071fc:	83 ca 40             	or     $0x40,%edx
801071ff:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107205:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107208:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010720f:	83 ca 80             	or     $0xffffff80,%edx
80107212:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107218:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010721b:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107222:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107225:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
8010722c:	ff ff 
8010722e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107231:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107238:	00 00 
8010723a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010723d:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107244:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107247:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010724e:	83 e2 f0             	and    $0xfffffff0,%edx
80107251:	83 ca 0a             	or     $0xa,%edx
80107254:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010725a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010725d:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107264:	83 ca 10             	or     $0x10,%edx
80107267:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010726d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107270:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107277:	83 ca 60             	or     $0x60,%edx
8010727a:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107280:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107283:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010728a:	83 ca 80             	or     $0xffffff80,%edx
8010728d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107293:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107296:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010729d:	83 ca 0f             	or     $0xf,%edx
801072a0:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801072a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072a9:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801072b0:	83 e2 ef             	and    $0xffffffef,%edx
801072b3:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801072b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072bc:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801072c3:	83 e2 df             	and    $0xffffffdf,%edx
801072c6:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801072cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072cf:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801072d6:	83 ca 40             	or     $0x40,%edx
801072d9:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801072df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072e2:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801072e9:	83 ca 80             	or     $0xffffff80,%edx
801072ec:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801072f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072f5:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801072fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072ff:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107306:	ff ff 
80107308:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010730b:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107312:	00 00 
80107314:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107317:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010731e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107321:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107328:	83 e2 f0             	and    $0xfffffff0,%edx
8010732b:	83 ca 02             	or     $0x2,%edx
8010732e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107334:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107337:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010733e:	83 ca 10             	or     $0x10,%edx
80107341:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107347:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010734a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107351:	83 ca 60             	or     $0x60,%edx
80107354:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010735a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010735d:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107364:	83 ca 80             	or     $0xffffff80,%edx
80107367:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010736d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107370:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107377:	83 ca 0f             	or     $0xf,%edx
8010737a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107380:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107383:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010738a:	83 e2 ef             	and    $0xffffffef,%edx
8010738d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107393:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107396:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010739d:	83 e2 df             	and    $0xffffffdf,%edx
801073a0:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801073a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073a9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801073b0:	83 ca 40             	or     $0x40,%edx
801073b3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801073b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073bc:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801073c3:	83 ca 80             	or     $0xffffff80,%edx
801073c6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801073cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073cf:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801073d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073d9:	83 c0 70             	add    $0x70,%eax
801073dc:	83 ec 08             	sub    $0x8,%esp
801073df:	6a 30                	push   $0x30
801073e1:	50                   	push   %eax
801073e2:	e8 63 fc ff ff       	call   8010704a <lgdt>
801073e7:	83 c4 10             	add    $0x10,%esp
}
801073ea:	90                   	nop
801073eb:	c9                   	leave  
801073ec:	c3                   	ret    

801073ed <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801073ed:	55                   	push   %ebp
801073ee:	89 e5                	mov    %esp,%ebp
801073f0:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801073f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801073f6:	c1 e8 16             	shr    $0x16,%eax
801073f9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107400:	8b 45 08             	mov    0x8(%ebp),%eax
80107403:	01 d0                	add    %edx,%eax
80107405:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107408:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010740b:	8b 00                	mov    (%eax),%eax
8010740d:	83 e0 01             	and    $0x1,%eax
80107410:	85 c0                	test   %eax,%eax
80107412:	74 14                	je     80107428 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107414:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107417:	8b 00                	mov    (%eax),%eax
80107419:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010741e:	05 00 00 00 80       	add    $0x80000000,%eax
80107423:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107426:	eb 42                	jmp    8010746a <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107428:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010742c:	74 0e                	je     8010743c <walkpgdir+0x4f>
8010742e:	e8 6d b3 ff ff       	call   801027a0 <kalloc>
80107433:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107436:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010743a:	75 07                	jne    80107443 <walkpgdir+0x56>
      return 0;
8010743c:	b8 00 00 00 00       	mov    $0x0,%eax
80107441:	eb 3e                	jmp    80107481 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107443:	83 ec 04             	sub    $0x4,%esp
80107446:	68 00 10 00 00       	push   $0x1000
8010744b:	6a 00                	push   $0x0
8010744d:	ff 75 f4             	push   -0xc(%ebp)
80107450:	e8 70 d7 ff ff       	call   80104bc5 <memset>
80107455:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107458:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010745b:	05 00 00 00 80       	add    $0x80000000,%eax
80107460:	83 c8 07             	or     $0x7,%eax
80107463:	89 c2                	mov    %eax,%edx
80107465:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107468:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
8010746a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010746d:	c1 e8 0c             	shr    $0xc,%eax
80107470:	25 ff 03 00 00       	and    $0x3ff,%eax
80107475:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010747c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010747f:	01 d0                	add    %edx,%eax
}
80107481:	c9                   	leave  
80107482:	c3                   	ret    

80107483 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107483:	55                   	push   %ebp
80107484:	89 e5                	mov    %esp,%ebp
80107486:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107489:	8b 45 0c             	mov    0xc(%ebp),%eax
8010748c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107491:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107494:	8b 55 0c             	mov    0xc(%ebp),%edx
80107497:	8b 45 10             	mov    0x10(%ebp),%eax
8010749a:	01 d0                	add    %edx,%eax
8010749c:	83 e8 01             	sub    $0x1,%eax
8010749f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801074a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801074a7:	83 ec 04             	sub    $0x4,%esp
801074aa:	6a 01                	push   $0x1
801074ac:	ff 75 f4             	push   -0xc(%ebp)
801074af:	ff 75 08             	push   0x8(%ebp)
801074b2:	e8 36 ff ff ff       	call   801073ed <walkpgdir>
801074b7:	83 c4 10             	add    $0x10,%esp
801074ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
801074bd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801074c1:	75 07                	jne    801074ca <mappages+0x47>
      return -1;
801074c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801074c8:	eb 47                	jmp    80107511 <mappages+0x8e>
    if(*pte & PTE_P)
801074ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
801074cd:	8b 00                	mov    (%eax),%eax
801074cf:	83 e0 01             	and    $0x1,%eax
801074d2:	85 c0                	test   %eax,%eax
801074d4:	74 0d                	je     801074e3 <mappages+0x60>
      panic("remap");
801074d6:	83 ec 0c             	sub    $0xc,%esp
801074d9:	68 a8 a7 10 80       	push   $0x8010a7a8
801074de:	e8 c6 90 ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
801074e3:	8b 45 18             	mov    0x18(%ebp),%eax
801074e6:	0b 45 14             	or     0x14(%ebp),%eax
801074e9:	83 c8 01             	or     $0x1,%eax
801074ec:	89 c2                	mov    %eax,%edx
801074ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
801074f1:	89 10                	mov    %edx,(%eax)
    if(a == last)
801074f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074f6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801074f9:	74 10                	je     8010750b <mappages+0x88>
      break;
    a += PGSIZE;
801074fb:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107502:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107509:	eb 9c                	jmp    801074a7 <mappages+0x24>
      break;
8010750b:	90                   	nop
  }
  return 0;
8010750c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107511:	c9                   	leave  
80107512:	c3                   	ret    

80107513 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107513:	55                   	push   %ebp
80107514:	89 e5                	mov    %esp,%ebp
80107516:	53                   	push   %ebx
80107517:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
8010751a:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80107521:	8b 15 50 6d 19 80    	mov    0x80196d50,%edx
80107527:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
8010752c:	29 d0                	sub    %edx,%eax
8010752e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107531:	a1 48 6d 19 80       	mov    0x80196d48,%eax
80107536:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107539:	8b 15 48 6d 19 80    	mov    0x80196d48,%edx
8010753f:	a1 50 6d 19 80       	mov    0x80196d50,%eax
80107544:	01 d0                	add    %edx,%eax
80107546:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107549:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107550:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107553:	83 c0 30             	add    $0x30,%eax
80107556:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107559:	89 10                	mov    %edx,(%eax)
8010755b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010755e:	89 50 04             	mov    %edx,0x4(%eax)
80107561:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107564:	89 50 08             	mov    %edx,0x8(%eax)
80107567:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010756a:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
8010756d:	e8 2e b2 ff ff       	call   801027a0 <kalloc>
80107572:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107575:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107579:	75 07                	jne    80107582 <setupkvm+0x6f>
    return 0;
8010757b:	b8 00 00 00 00       	mov    $0x0,%eax
80107580:	eb 78                	jmp    801075fa <setupkvm+0xe7>
  }
  memset(pgdir, 0, PGSIZE);
80107582:	83 ec 04             	sub    $0x4,%esp
80107585:	68 00 10 00 00       	push   $0x1000
8010758a:	6a 00                	push   $0x0
8010758c:	ff 75 f0             	push   -0x10(%ebp)
8010758f:	e8 31 d6 ff ff       	call   80104bc5 <memset>
80107594:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107597:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
8010759e:	eb 4e                	jmp    801075ee <setupkvm+0xdb>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801075a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075a3:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
801075a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075a9:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801075ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075af:	8b 58 08             	mov    0x8(%eax),%ebx
801075b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075b5:	8b 40 04             	mov    0x4(%eax),%eax
801075b8:	29 c3                	sub    %eax,%ebx
801075ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075bd:	8b 00                	mov    (%eax),%eax
801075bf:	83 ec 0c             	sub    $0xc,%esp
801075c2:	51                   	push   %ecx
801075c3:	52                   	push   %edx
801075c4:	53                   	push   %ebx
801075c5:	50                   	push   %eax
801075c6:	ff 75 f0             	push   -0x10(%ebp)
801075c9:	e8 b5 fe ff ff       	call   80107483 <mappages>
801075ce:	83 c4 20             	add    $0x20,%esp
801075d1:	85 c0                	test   %eax,%eax
801075d3:	79 15                	jns    801075ea <setupkvm+0xd7>
      freevm(pgdir);
801075d5:	83 ec 0c             	sub    $0xc,%esp
801075d8:	ff 75 f0             	push   -0x10(%ebp)
801075db:	e8 f5 04 00 00       	call   80107ad5 <freevm>
801075e0:	83 c4 10             	add    $0x10,%esp
      return 0;
801075e3:	b8 00 00 00 00       	mov    $0x0,%eax
801075e8:	eb 10                	jmp    801075fa <setupkvm+0xe7>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801075ea:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801075ee:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
801075f5:	72 a9                	jb     801075a0 <setupkvm+0x8d>
    }
  return pgdir;
801075f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801075fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801075fd:	c9                   	leave  
801075fe:	c3                   	ret    

801075ff <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801075ff:	55                   	push   %ebp
80107600:	89 e5                	mov    %esp,%ebp
80107602:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107605:	e8 09 ff ff ff       	call   80107513 <setupkvm>
8010760a:	a3 7c 6a 19 80       	mov    %eax,0x80196a7c
  switchkvm();
8010760f:	e8 03 00 00 00       	call   80107617 <switchkvm>
}
80107614:	90                   	nop
80107615:	c9                   	leave  
80107616:	c3                   	ret    

80107617 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107617:	55                   	push   %ebp
80107618:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
8010761a:	a1 7c 6a 19 80       	mov    0x80196a7c,%eax
8010761f:	05 00 00 00 80       	add    $0x80000000,%eax
80107624:	50                   	push   %eax
80107625:	e8 61 fa ff ff       	call   8010708b <lcr3>
8010762a:	83 c4 04             	add    $0x4,%esp
}
8010762d:	90                   	nop
8010762e:	c9                   	leave  
8010762f:	c3                   	ret    

80107630 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107630:	55                   	push   %ebp
80107631:	89 e5                	mov    %esp,%ebp
80107633:	56                   	push   %esi
80107634:	53                   	push   %ebx
80107635:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107638:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010763c:	75 0d                	jne    8010764b <switchuvm+0x1b>
    panic("switchuvm: no process");
8010763e:	83 ec 0c             	sub    $0xc,%esp
80107641:	68 ae a7 10 80       	push   $0x8010a7ae
80107646:	e8 5e 8f ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
8010764b:	8b 45 08             	mov    0x8(%ebp),%eax
8010764e:	8b 40 08             	mov    0x8(%eax),%eax
80107651:	85 c0                	test   %eax,%eax
80107653:	75 0d                	jne    80107662 <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107655:	83 ec 0c             	sub    $0xc,%esp
80107658:	68 c4 a7 10 80       	push   $0x8010a7c4
8010765d:	e8 47 8f ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
80107662:	8b 45 08             	mov    0x8(%ebp),%eax
80107665:	8b 40 04             	mov    0x4(%eax),%eax
80107668:	85 c0                	test   %eax,%eax
8010766a:	75 0d                	jne    80107679 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
8010766c:	83 ec 0c             	sub    $0xc,%esp
8010766f:	68 d9 a7 10 80       	push   $0x8010a7d9
80107674:	e8 30 8f ff ff       	call   801005a9 <panic>

  pushcli();
80107679:	e8 3c d4 ff ff       	call   80104aba <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
8010767e:	e8 35 c3 ff ff       	call   801039b8 <mycpu>
80107683:	89 c3                	mov    %eax,%ebx
80107685:	e8 2e c3 ff ff       	call   801039b8 <mycpu>
8010768a:	83 c0 08             	add    $0x8,%eax
8010768d:	89 c6                	mov    %eax,%esi
8010768f:	e8 24 c3 ff ff       	call   801039b8 <mycpu>
80107694:	83 c0 08             	add    $0x8,%eax
80107697:	c1 e8 10             	shr    $0x10,%eax
8010769a:	88 45 f7             	mov    %al,-0x9(%ebp)
8010769d:	e8 16 c3 ff ff       	call   801039b8 <mycpu>
801076a2:	83 c0 08             	add    $0x8,%eax
801076a5:	c1 e8 18             	shr    $0x18,%eax
801076a8:	89 c2                	mov    %eax,%edx
801076aa:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801076b1:	67 00 
801076b3:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
801076ba:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
801076be:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
801076c4:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801076cb:	83 e0 f0             	and    $0xfffffff0,%eax
801076ce:	83 c8 09             	or     $0x9,%eax
801076d1:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801076d7:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801076de:	83 c8 10             	or     $0x10,%eax
801076e1:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801076e7:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801076ee:	83 e0 9f             	and    $0xffffff9f,%eax
801076f1:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801076f7:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801076fe:	83 c8 80             	or     $0xffffff80,%eax
80107701:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107707:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010770e:	83 e0 f0             	and    $0xfffffff0,%eax
80107711:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107717:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010771e:	83 e0 ef             	and    $0xffffffef,%eax
80107721:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107727:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010772e:	83 e0 df             	and    $0xffffffdf,%eax
80107731:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107737:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010773e:	83 c8 40             	or     $0x40,%eax
80107741:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107747:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010774e:	83 e0 7f             	and    $0x7f,%eax
80107751:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107757:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
8010775d:	e8 56 c2 ff ff       	call   801039b8 <mycpu>
80107762:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107769:	83 e2 ef             	and    $0xffffffef,%edx
8010776c:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107772:	e8 41 c2 ff ff       	call   801039b8 <mycpu>
80107777:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
8010777d:	8b 45 08             	mov    0x8(%ebp),%eax
80107780:	8b 40 08             	mov    0x8(%eax),%eax
80107783:	89 c3                	mov    %eax,%ebx
80107785:	e8 2e c2 ff ff       	call   801039b8 <mycpu>
8010778a:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107790:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107793:	e8 20 c2 ff ff       	call   801039b8 <mycpu>
80107798:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
8010779e:	83 ec 0c             	sub    $0xc,%esp
801077a1:	6a 28                	push   $0x28
801077a3:	e8 cc f8 ff ff       	call   80107074 <ltr>
801077a8:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
801077ab:	8b 45 08             	mov    0x8(%ebp),%eax
801077ae:	8b 40 04             	mov    0x4(%eax),%eax
801077b1:	05 00 00 00 80       	add    $0x80000000,%eax
801077b6:	83 ec 0c             	sub    $0xc,%esp
801077b9:	50                   	push   %eax
801077ba:	e8 cc f8 ff ff       	call   8010708b <lcr3>
801077bf:	83 c4 10             	add    $0x10,%esp
  popcli();
801077c2:	e8 40 d3 ff ff       	call   80104b07 <popcli>
}
801077c7:	90                   	nop
801077c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801077cb:	5b                   	pop    %ebx
801077cc:	5e                   	pop    %esi
801077cd:	5d                   	pop    %ebp
801077ce:	c3                   	ret    

801077cf <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801077cf:	55                   	push   %ebp
801077d0:	89 e5                	mov    %esp,%ebp
801077d2:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
801077d5:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801077dc:	76 0d                	jbe    801077eb <inituvm+0x1c>
    panic("inituvm: more than a page");
801077de:	83 ec 0c             	sub    $0xc,%esp
801077e1:	68 ed a7 10 80       	push   $0x8010a7ed
801077e6:	e8 be 8d ff ff       	call   801005a9 <panic>
  mem = kalloc();
801077eb:	e8 b0 af ff ff       	call   801027a0 <kalloc>
801077f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801077f3:	83 ec 04             	sub    $0x4,%esp
801077f6:	68 00 10 00 00       	push   $0x1000
801077fb:	6a 00                	push   $0x0
801077fd:	ff 75 f4             	push   -0xc(%ebp)
80107800:	e8 c0 d3 ff ff       	call   80104bc5 <memset>
80107805:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107808:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010780b:	05 00 00 00 80       	add    $0x80000000,%eax
80107810:	83 ec 0c             	sub    $0xc,%esp
80107813:	6a 06                	push   $0x6
80107815:	50                   	push   %eax
80107816:	68 00 10 00 00       	push   $0x1000
8010781b:	6a 00                	push   $0x0
8010781d:	ff 75 08             	push   0x8(%ebp)
80107820:	e8 5e fc ff ff       	call   80107483 <mappages>
80107825:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107828:	83 ec 04             	sub    $0x4,%esp
8010782b:	ff 75 10             	push   0x10(%ebp)
8010782e:	ff 75 0c             	push   0xc(%ebp)
80107831:	ff 75 f4             	push   -0xc(%ebp)
80107834:	e8 4b d4 ff ff       	call   80104c84 <memmove>
80107839:	83 c4 10             	add    $0x10,%esp
}
8010783c:	90                   	nop
8010783d:	c9                   	leave  
8010783e:	c3                   	ret    

8010783f <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010783f:	55                   	push   %ebp
80107840:	89 e5                	mov    %esp,%ebp
80107842:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107845:	8b 45 0c             	mov    0xc(%ebp),%eax
80107848:	25 ff 0f 00 00       	and    $0xfff,%eax
8010784d:	85 c0                	test   %eax,%eax
8010784f:	74 0d                	je     8010785e <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107851:	83 ec 0c             	sub    $0xc,%esp
80107854:	68 08 a8 10 80       	push   $0x8010a808
80107859:	e8 4b 8d ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
8010785e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107865:	e9 8f 00 00 00       	jmp    801078f9 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
8010786a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010786d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107870:	01 d0                	add    %edx,%eax
80107872:	83 ec 04             	sub    $0x4,%esp
80107875:	6a 00                	push   $0x0
80107877:	50                   	push   %eax
80107878:	ff 75 08             	push   0x8(%ebp)
8010787b:	e8 6d fb ff ff       	call   801073ed <walkpgdir>
80107880:	83 c4 10             	add    $0x10,%esp
80107883:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107886:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010788a:	75 0d                	jne    80107899 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
8010788c:	83 ec 0c             	sub    $0xc,%esp
8010788f:	68 2b a8 10 80       	push   $0x8010a82b
80107894:	e8 10 8d ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107899:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010789c:	8b 00                	mov    (%eax),%eax
8010789e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801078a3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801078a6:	8b 45 18             	mov    0x18(%ebp),%eax
801078a9:	2b 45 f4             	sub    -0xc(%ebp),%eax
801078ac:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801078b1:	77 0b                	ja     801078be <loaduvm+0x7f>
      n = sz - i;
801078b3:	8b 45 18             	mov    0x18(%ebp),%eax
801078b6:	2b 45 f4             	sub    -0xc(%ebp),%eax
801078b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801078bc:	eb 07                	jmp    801078c5 <loaduvm+0x86>
    else
      n = PGSIZE;
801078be:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
801078c5:	8b 55 14             	mov    0x14(%ebp),%edx
801078c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078cb:	01 d0                	add    %edx,%eax
801078cd:	8b 55 e8             	mov    -0x18(%ebp),%edx
801078d0:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801078d6:	ff 75 f0             	push   -0x10(%ebp)
801078d9:	50                   	push   %eax
801078da:	52                   	push   %edx
801078db:	ff 75 10             	push   0x10(%ebp)
801078de:	e8 f3 a5 ff ff       	call   80101ed6 <readi>
801078e3:	83 c4 10             	add    $0x10,%esp
801078e6:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801078e9:	74 07                	je     801078f2 <loaduvm+0xb3>
      return -1;
801078eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801078f0:	eb 18                	jmp    8010790a <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
801078f2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801078f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078fc:	3b 45 18             	cmp    0x18(%ebp),%eax
801078ff:	0f 82 65 ff ff ff    	jb     8010786a <loaduvm+0x2b>
  }
  return 0;
80107905:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010790a:	c9                   	leave  
8010790b:	c3                   	ret    

8010790c <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010790c:	55                   	push   %ebp
8010790d:	89 e5                	mov    %esp,%ebp
8010790f:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107912:	8b 45 10             	mov    0x10(%ebp),%eax
80107915:	85 c0                	test   %eax,%eax
80107917:	79 0a                	jns    80107923 <allocuvm+0x17>
    return 0;
80107919:	b8 00 00 00 00       	mov    $0x0,%eax
8010791e:	e9 ec 00 00 00       	jmp    80107a0f <allocuvm+0x103>
  if(newsz < oldsz)
80107923:	8b 45 10             	mov    0x10(%ebp),%eax
80107926:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107929:	73 08                	jae    80107933 <allocuvm+0x27>
    return oldsz;
8010792b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010792e:	e9 dc 00 00 00       	jmp    80107a0f <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80107933:	8b 45 0c             	mov    0xc(%ebp),%eax
80107936:	05 ff 0f 00 00       	add    $0xfff,%eax
8010793b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107940:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107943:	e9 b8 00 00 00       	jmp    80107a00 <allocuvm+0xf4>
    mem = kalloc();
80107948:	e8 53 ae ff ff       	call   801027a0 <kalloc>
8010794d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107950:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107954:	75 2e                	jne    80107984 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80107956:	83 ec 0c             	sub    $0xc,%esp
80107959:	68 49 a8 10 80       	push   $0x8010a849
8010795e:	e8 91 8a ff ff       	call   801003f4 <cprintf>
80107963:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107966:	83 ec 04             	sub    $0x4,%esp
80107969:	ff 75 0c             	push   0xc(%ebp)
8010796c:	ff 75 10             	push   0x10(%ebp)
8010796f:	ff 75 08             	push   0x8(%ebp)
80107972:	e8 9a 00 00 00       	call   80107a11 <deallocuvm>
80107977:	83 c4 10             	add    $0x10,%esp
      return 0;
8010797a:	b8 00 00 00 00       	mov    $0x0,%eax
8010797f:	e9 8b 00 00 00       	jmp    80107a0f <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80107984:	83 ec 04             	sub    $0x4,%esp
80107987:	68 00 10 00 00       	push   $0x1000
8010798c:	6a 00                	push   $0x0
8010798e:	ff 75 f0             	push   -0x10(%ebp)
80107991:	e8 2f d2 ff ff       	call   80104bc5 <memset>
80107996:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107999:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010799c:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801079a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a5:	83 ec 0c             	sub    $0xc,%esp
801079a8:	6a 06                	push   $0x6
801079aa:	52                   	push   %edx
801079ab:	68 00 10 00 00       	push   $0x1000
801079b0:	50                   	push   %eax
801079b1:	ff 75 08             	push   0x8(%ebp)
801079b4:	e8 ca fa ff ff       	call   80107483 <mappages>
801079b9:	83 c4 20             	add    $0x20,%esp
801079bc:	85 c0                	test   %eax,%eax
801079be:	79 39                	jns    801079f9 <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
801079c0:	83 ec 0c             	sub    $0xc,%esp
801079c3:	68 61 a8 10 80       	push   $0x8010a861
801079c8:	e8 27 8a ff ff       	call   801003f4 <cprintf>
801079cd:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801079d0:	83 ec 04             	sub    $0x4,%esp
801079d3:	ff 75 0c             	push   0xc(%ebp)
801079d6:	ff 75 10             	push   0x10(%ebp)
801079d9:	ff 75 08             	push   0x8(%ebp)
801079dc:	e8 30 00 00 00       	call   80107a11 <deallocuvm>
801079e1:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
801079e4:	83 ec 0c             	sub    $0xc,%esp
801079e7:	ff 75 f0             	push   -0x10(%ebp)
801079ea:	e8 17 ad ff ff       	call   80102706 <kfree>
801079ef:	83 c4 10             	add    $0x10,%esp
      return 0;
801079f2:	b8 00 00 00 00       	mov    $0x0,%eax
801079f7:	eb 16                	jmp    80107a0f <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
801079f9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a03:	3b 45 10             	cmp    0x10(%ebp),%eax
80107a06:	0f 82 3c ff ff ff    	jb     80107948 <allocuvm+0x3c>
    }
  }
  return newsz;
80107a0c:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107a0f:	c9                   	leave  
80107a10:	c3                   	ret    

80107a11 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107a11:	55                   	push   %ebp
80107a12:	89 e5                	mov    %esp,%ebp
80107a14:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107a17:	8b 45 10             	mov    0x10(%ebp),%eax
80107a1a:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107a1d:	72 08                	jb     80107a27 <deallocuvm+0x16>
    return oldsz;
80107a1f:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a22:	e9 ac 00 00 00       	jmp    80107ad3 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80107a27:	8b 45 10             	mov    0x10(%ebp),%eax
80107a2a:	05 ff 0f 00 00       	add    $0xfff,%eax
80107a2f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107a34:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107a37:	e9 88 00 00 00       	jmp    80107ac4 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107a3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a3f:	83 ec 04             	sub    $0x4,%esp
80107a42:	6a 00                	push   $0x0
80107a44:	50                   	push   %eax
80107a45:	ff 75 08             	push   0x8(%ebp)
80107a48:	e8 a0 f9 ff ff       	call   801073ed <walkpgdir>
80107a4d:	83 c4 10             	add    $0x10,%esp
80107a50:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107a53:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107a57:	75 16                	jne    80107a6f <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107a59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a5c:	c1 e8 16             	shr    $0x16,%eax
80107a5f:	83 c0 01             	add    $0x1,%eax
80107a62:	c1 e0 16             	shl    $0x16,%eax
80107a65:	2d 00 10 00 00       	sub    $0x1000,%eax
80107a6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107a6d:	eb 4e                	jmp    80107abd <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80107a6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a72:	8b 00                	mov    (%eax),%eax
80107a74:	83 e0 01             	and    $0x1,%eax
80107a77:	85 c0                	test   %eax,%eax
80107a79:	74 42                	je     80107abd <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80107a7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a7e:	8b 00                	mov    (%eax),%eax
80107a80:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107a85:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107a88:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107a8c:	75 0d                	jne    80107a9b <deallocuvm+0x8a>
        panic("kfree");
80107a8e:	83 ec 0c             	sub    $0xc,%esp
80107a91:	68 7d a8 10 80       	push   $0x8010a87d
80107a96:	e8 0e 8b ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
80107a9b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107a9e:	05 00 00 00 80       	add    $0x80000000,%eax
80107aa3:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107aa6:	83 ec 0c             	sub    $0xc,%esp
80107aa9:	ff 75 e8             	push   -0x18(%ebp)
80107aac:	e8 55 ac ff ff       	call   80102706 <kfree>
80107ab1:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107ab4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ab7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107abd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac7:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107aca:	0f 82 6c ff ff ff    	jb     80107a3c <deallocuvm+0x2b>
    }
  }
  return newsz;
80107ad0:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107ad3:	c9                   	leave  
80107ad4:	c3                   	ret    

80107ad5 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107ad5:	55                   	push   %ebp
80107ad6:	89 e5                	mov    %esp,%ebp
80107ad8:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107adb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107adf:	75 0d                	jne    80107aee <freevm+0x19>
    panic("freevm: no pgdir");
80107ae1:	83 ec 0c             	sub    $0xc,%esp
80107ae4:	68 83 a8 10 80       	push   $0x8010a883
80107ae9:	e8 bb 8a ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107aee:	83 ec 04             	sub    $0x4,%esp
80107af1:	6a 00                	push   $0x0
80107af3:	68 00 00 00 80       	push   $0x80000000
80107af8:	ff 75 08             	push   0x8(%ebp)
80107afb:	e8 11 ff ff ff       	call   80107a11 <deallocuvm>
80107b00:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107b03:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107b0a:	eb 48                	jmp    80107b54 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80107b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107b16:	8b 45 08             	mov    0x8(%ebp),%eax
80107b19:	01 d0                	add    %edx,%eax
80107b1b:	8b 00                	mov    (%eax),%eax
80107b1d:	83 e0 01             	and    $0x1,%eax
80107b20:	85 c0                	test   %eax,%eax
80107b22:	74 2c                	je     80107b50 <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107b24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b27:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107b2e:	8b 45 08             	mov    0x8(%ebp),%eax
80107b31:	01 d0                	add    %edx,%eax
80107b33:	8b 00                	mov    (%eax),%eax
80107b35:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b3a:	05 00 00 00 80       	add    $0x80000000,%eax
80107b3f:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107b42:	83 ec 0c             	sub    $0xc,%esp
80107b45:	ff 75 f0             	push   -0x10(%ebp)
80107b48:	e8 b9 ab ff ff       	call   80102706 <kfree>
80107b4d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107b50:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107b54:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107b5b:	76 af                	jbe    80107b0c <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80107b5d:	83 ec 0c             	sub    $0xc,%esp
80107b60:	ff 75 08             	push   0x8(%ebp)
80107b63:	e8 9e ab ff ff       	call   80102706 <kfree>
80107b68:	83 c4 10             	add    $0x10,%esp
}
80107b6b:	90                   	nop
80107b6c:	c9                   	leave  
80107b6d:	c3                   	ret    

80107b6e <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107b6e:	55                   	push   %ebp
80107b6f:	89 e5                	mov    %esp,%ebp
80107b71:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107b74:	83 ec 04             	sub    $0x4,%esp
80107b77:	6a 00                	push   $0x0
80107b79:	ff 75 0c             	push   0xc(%ebp)
80107b7c:	ff 75 08             	push   0x8(%ebp)
80107b7f:	e8 69 f8 ff ff       	call   801073ed <walkpgdir>
80107b84:	83 c4 10             	add    $0x10,%esp
80107b87:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107b8a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107b8e:	75 0d                	jne    80107b9d <clearpteu+0x2f>
    panic("clearpteu");
80107b90:	83 ec 0c             	sub    $0xc,%esp
80107b93:	68 94 a8 10 80       	push   $0x8010a894
80107b98:	e8 0c 8a ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
80107b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba0:	8b 00                	mov    (%eax),%eax
80107ba2:	83 e0 fb             	and    $0xfffffffb,%eax
80107ba5:	89 c2                	mov    %eax,%edx
80107ba7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107baa:	89 10                	mov    %edx,(%eax)
}
80107bac:	90                   	nop
80107bad:	c9                   	leave  
80107bae:	c3                   	ret    

80107baf <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107baf:	55                   	push   %ebp
80107bb0:	89 e5                	mov    %esp,%ebp
80107bb2:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107bb5:	e8 59 f9 ff ff       	call   80107513 <setupkvm>
80107bba:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107bbd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107bc1:	75 0a                	jne    80107bcd <copyuvm+0x1e>
    return 0;
80107bc3:	b8 00 00 00 00       	mov    $0x0,%eax
80107bc8:	e9 eb 00 00 00       	jmp    80107cb8 <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
80107bcd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107bd4:	e9 b7 00 00 00       	jmp    80107c90 <copyuvm+0xe1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bdc:	83 ec 04             	sub    $0x4,%esp
80107bdf:	6a 00                	push   $0x0
80107be1:	50                   	push   %eax
80107be2:	ff 75 08             	push   0x8(%ebp)
80107be5:	e8 03 f8 ff ff       	call   801073ed <walkpgdir>
80107bea:	83 c4 10             	add    $0x10,%esp
80107bed:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107bf0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107bf4:	75 0d                	jne    80107c03 <copyuvm+0x54>
      panic("copyuvm: pte should exist");
80107bf6:	83 ec 0c             	sub    $0xc,%esp
80107bf9:	68 9e a8 10 80       	push   $0x8010a89e
80107bfe:	e8 a6 89 ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
80107c03:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c06:	8b 00                	mov    (%eax),%eax
80107c08:	83 e0 01             	and    $0x1,%eax
80107c0b:	85 c0                	test   %eax,%eax
80107c0d:	75 0d                	jne    80107c1c <copyuvm+0x6d>
      panic("copyuvm: page not present");
80107c0f:	83 ec 0c             	sub    $0xc,%esp
80107c12:	68 b8 a8 10 80       	push   $0x8010a8b8
80107c17:	e8 8d 89 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107c1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c1f:	8b 00                	mov    (%eax),%eax
80107c21:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c26:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107c29:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c2c:	8b 00                	mov    (%eax),%eax
80107c2e:	25 ff 0f 00 00       	and    $0xfff,%eax
80107c33:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107c36:	e8 65 ab ff ff       	call   801027a0 <kalloc>
80107c3b:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107c3e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107c42:	74 5d                	je     80107ca1 <copyuvm+0xf2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107c44:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107c47:	05 00 00 00 80       	add    $0x80000000,%eax
80107c4c:	83 ec 04             	sub    $0x4,%esp
80107c4f:	68 00 10 00 00       	push   $0x1000
80107c54:	50                   	push   %eax
80107c55:	ff 75 e0             	push   -0x20(%ebp)
80107c58:	e8 27 d0 ff ff       	call   80104c84 <memmove>
80107c5d:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107c60:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107c63:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107c66:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107c6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c6f:	83 ec 0c             	sub    $0xc,%esp
80107c72:	52                   	push   %edx
80107c73:	51                   	push   %ecx
80107c74:	68 00 10 00 00       	push   $0x1000
80107c79:	50                   	push   %eax
80107c7a:	ff 75 f0             	push   -0x10(%ebp)
80107c7d:	e8 01 f8 ff ff       	call   80107483 <mappages>
80107c82:	83 c4 20             	add    $0x20,%esp
80107c85:	85 c0                	test   %eax,%eax
80107c87:	78 1b                	js     80107ca4 <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
80107c89:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107c90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c93:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107c96:	0f 82 3d ff ff ff    	jb     80107bd9 <copyuvm+0x2a>
      goto bad;
  }
  return d;
80107c9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c9f:	eb 17                	jmp    80107cb8 <copyuvm+0x109>
      goto bad;
80107ca1:	90                   	nop
80107ca2:	eb 01                	jmp    80107ca5 <copyuvm+0xf6>
      goto bad;
80107ca4:	90                   	nop

bad:
  freevm(d);
80107ca5:	83 ec 0c             	sub    $0xc,%esp
80107ca8:	ff 75 f0             	push   -0x10(%ebp)
80107cab:	e8 25 fe ff ff       	call   80107ad5 <freevm>
80107cb0:	83 c4 10             	add    $0x10,%esp
  return 0;
80107cb3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107cb8:	c9                   	leave  
80107cb9:	c3                   	ret    

80107cba <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107cba:	55                   	push   %ebp
80107cbb:	89 e5                	mov    %esp,%ebp
80107cbd:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107cc0:	83 ec 04             	sub    $0x4,%esp
80107cc3:	6a 00                	push   $0x0
80107cc5:	ff 75 0c             	push   0xc(%ebp)
80107cc8:	ff 75 08             	push   0x8(%ebp)
80107ccb:	e8 1d f7 ff ff       	call   801073ed <walkpgdir>
80107cd0:	83 c4 10             	add    $0x10,%esp
80107cd3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80107cd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd9:	8b 00                	mov    (%eax),%eax
80107cdb:	83 e0 01             	and    $0x1,%eax
80107cde:	85 c0                	test   %eax,%eax
80107ce0:	75 07                	jne    80107ce9 <uva2ka+0x2f>
    return 0;
80107ce2:	b8 00 00 00 00       	mov    $0x0,%eax
80107ce7:	eb 22                	jmp    80107d0b <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80107ce9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cec:	8b 00                	mov    (%eax),%eax
80107cee:	83 e0 04             	and    $0x4,%eax
80107cf1:	85 c0                	test   %eax,%eax
80107cf3:	75 07                	jne    80107cfc <uva2ka+0x42>
    return 0;
80107cf5:	b8 00 00 00 00       	mov    $0x0,%eax
80107cfa:	eb 0f                	jmp    80107d0b <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80107cfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cff:	8b 00                	mov    (%eax),%eax
80107d01:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d06:	05 00 00 00 80       	add    $0x80000000,%eax
}
80107d0b:	c9                   	leave  
80107d0c:	c3                   	ret    

80107d0d <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107d0d:	55                   	push   %ebp
80107d0e:	89 e5                	mov    %esp,%ebp
80107d10:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80107d13:	8b 45 10             	mov    0x10(%ebp),%eax
80107d16:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80107d19:	eb 7f                	jmp    80107d9a <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80107d1b:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d1e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d23:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80107d26:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d29:	83 ec 08             	sub    $0x8,%esp
80107d2c:	50                   	push   %eax
80107d2d:	ff 75 08             	push   0x8(%ebp)
80107d30:	e8 85 ff ff ff       	call   80107cba <uva2ka>
80107d35:	83 c4 10             	add    $0x10,%esp
80107d38:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80107d3b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80107d3f:	75 07                	jne    80107d48 <copyout+0x3b>
      return -1;
80107d41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d46:	eb 61                	jmp    80107da9 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80107d48:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d4b:	2b 45 0c             	sub    0xc(%ebp),%eax
80107d4e:	05 00 10 00 00       	add    $0x1000,%eax
80107d53:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80107d56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d59:	3b 45 14             	cmp    0x14(%ebp),%eax
80107d5c:	76 06                	jbe    80107d64 <copyout+0x57>
      n = len;
80107d5e:	8b 45 14             	mov    0x14(%ebp),%eax
80107d61:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80107d64:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d67:	2b 45 ec             	sub    -0x14(%ebp),%eax
80107d6a:	89 c2                	mov    %eax,%edx
80107d6c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107d6f:	01 d0                	add    %edx,%eax
80107d71:	83 ec 04             	sub    $0x4,%esp
80107d74:	ff 75 f0             	push   -0x10(%ebp)
80107d77:	ff 75 f4             	push   -0xc(%ebp)
80107d7a:	50                   	push   %eax
80107d7b:	e8 04 cf ff ff       	call   80104c84 <memmove>
80107d80:	83 c4 10             	add    $0x10,%esp
    len -= n;
80107d83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d86:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80107d89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d8c:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80107d8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d92:	05 00 10 00 00       	add    $0x1000,%eax
80107d97:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80107d9a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80107d9e:	0f 85 77 ff ff ff    	jne    80107d1b <copyout+0xe>
  }
  return 0;
80107da4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107da9:	c9                   	leave  
80107daa:	c3                   	ret    

80107dab <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80107dab:	55                   	push   %ebp
80107dac:	89 e5                	mov    %esp,%ebp
80107dae:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107db1:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80107db8:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107dbb:	8b 40 08             	mov    0x8(%eax),%eax
80107dbe:	05 00 00 00 80       	add    $0x80000000,%eax
80107dc3:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80107dc6:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80107dcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd0:	8b 40 24             	mov    0x24(%eax),%eax
80107dd3:	a3 00 41 19 80       	mov    %eax,0x80194100
  ncpu = 0;
80107dd8:	c7 05 40 6d 19 80 00 	movl   $0x0,0x80196d40
80107ddf:	00 00 00 

  while(i<madt->len){
80107de2:	90                   	nop
80107de3:	e9 bd 00 00 00       	jmp    80107ea5 <mpinit_uefi+0xfa>
    uchar *entry_type = ((uchar *)madt)+i;
80107de8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107deb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107dee:	01 d0                	add    %edx,%eax
80107df0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80107df3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107df6:	0f b6 00             	movzbl (%eax),%eax
80107df9:	0f b6 c0             	movzbl %al,%eax
80107dfc:	83 f8 05             	cmp    $0x5,%eax
80107dff:	0f 87 a0 00 00 00    	ja     80107ea5 <mpinit_uefi+0xfa>
80107e05:	8b 04 85 d4 a8 10 80 	mov    -0x7fef572c(,%eax,4),%eax
80107e0c:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80107e0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e11:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80107e14:	a1 40 6d 19 80       	mov    0x80196d40,%eax
80107e19:	83 f8 03             	cmp    $0x3,%eax
80107e1c:	7f 28                	jg     80107e46 <mpinit_uefi+0x9b>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80107e1e:	8b 15 40 6d 19 80    	mov    0x80196d40,%edx
80107e24:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107e27:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80107e2b:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80107e31:	81 c2 80 6a 19 80    	add    $0x80196a80,%edx
80107e37:	88 02                	mov    %al,(%edx)
          ncpu++;
80107e39:	a1 40 6d 19 80       	mov    0x80196d40,%eax
80107e3e:	83 c0 01             	add    $0x1,%eax
80107e41:	a3 40 6d 19 80       	mov    %eax,0x80196d40
        }
        i += lapic_entry->record_len;
80107e46:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107e49:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107e4d:	0f b6 c0             	movzbl %al,%eax
80107e50:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107e53:	eb 50                	jmp    80107ea5 <mpinit_uefi+0xfa>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80107e55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e58:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80107e5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107e5e:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80107e62:	a2 44 6d 19 80       	mov    %al,0x80196d44
        i += ioapic->record_len;
80107e67:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107e6a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107e6e:	0f b6 c0             	movzbl %al,%eax
80107e71:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107e74:	eb 2f                	jmp    80107ea5 <mpinit_uefi+0xfa>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80107e76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e79:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80107e7c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107e7f:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107e83:	0f b6 c0             	movzbl %al,%eax
80107e86:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107e89:	eb 1a                	jmp    80107ea5 <mpinit_uefi+0xfa>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80107e8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e8e:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80107e91:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e94:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107e98:	0f b6 c0             	movzbl %al,%eax
80107e9b:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107e9e:	eb 05                	jmp    80107ea5 <mpinit_uefi+0xfa>

      case 5:
        i = i + 0xC;
80107ea0:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80107ea4:	90                   	nop
  while(i<madt->len){
80107ea5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea8:	8b 40 04             	mov    0x4(%eax),%eax
80107eab:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80107eae:	0f 82 34 ff ff ff    	jb     80107de8 <mpinit_uefi+0x3d>
    }
  }

}
80107eb4:	90                   	nop
80107eb5:	90                   	nop
80107eb6:	c9                   	leave  
80107eb7:	c3                   	ret    

80107eb8 <inb>:
{
80107eb8:	55                   	push   %ebp
80107eb9:	89 e5                	mov    %esp,%ebp
80107ebb:	83 ec 14             	sub    $0x14,%esp
80107ebe:	8b 45 08             	mov    0x8(%ebp),%eax
80107ec1:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107ec5:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107ec9:	89 c2                	mov    %eax,%edx
80107ecb:	ec                   	in     (%dx),%al
80107ecc:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107ecf:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107ed3:	c9                   	leave  
80107ed4:	c3                   	ret    

80107ed5 <outb>:
{
80107ed5:	55                   	push   %ebp
80107ed6:	89 e5                	mov    %esp,%ebp
80107ed8:	83 ec 08             	sub    $0x8,%esp
80107edb:	8b 45 08             	mov    0x8(%ebp),%eax
80107ede:	8b 55 0c             	mov    0xc(%ebp),%edx
80107ee1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80107ee5:	89 d0                	mov    %edx,%eax
80107ee7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107eea:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107eee:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107ef2:	ee                   	out    %al,(%dx)
}
80107ef3:	90                   	nop
80107ef4:	c9                   	leave  
80107ef5:	c3                   	ret    

80107ef6 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80107ef6:	55                   	push   %ebp
80107ef7:	89 e5                	mov    %esp,%ebp
80107ef9:	83 ec 28             	sub    $0x28,%esp
80107efc:	8b 45 08             	mov    0x8(%ebp),%eax
80107eff:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80107f02:	6a 00                	push   $0x0
80107f04:	68 fa 03 00 00       	push   $0x3fa
80107f09:	e8 c7 ff ff ff       	call   80107ed5 <outb>
80107f0e:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107f11:	68 80 00 00 00       	push   $0x80
80107f16:	68 fb 03 00 00       	push   $0x3fb
80107f1b:	e8 b5 ff ff ff       	call   80107ed5 <outb>
80107f20:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107f23:	6a 0c                	push   $0xc
80107f25:	68 f8 03 00 00       	push   $0x3f8
80107f2a:	e8 a6 ff ff ff       	call   80107ed5 <outb>
80107f2f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107f32:	6a 00                	push   $0x0
80107f34:	68 f9 03 00 00       	push   $0x3f9
80107f39:	e8 97 ff ff ff       	call   80107ed5 <outb>
80107f3e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107f41:	6a 03                	push   $0x3
80107f43:	68 fb 03 00 00       	push   $0x3fb
80107f48:	e8 88 ff ff ff       	call   80107ed5 <outb>
80107f4d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107f50:	6a 00                	push   $0x0
80107f52:	68 fc 03 00 00       	push   $0x3fc
80107f57:	e8 79 ff ff ff       	call   80107ed5 <outb>
80107f5c:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
80107f5f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107f66:	eb 11                	jmp    80107f79 <uart_debug+0x83>
80107f68:	83 ec 0c             	sub    $0xc,%esp
80107f6b:	6a 0a                	push   $0xa
80107f6d:	e8 c5 ab ff ff       	call   80102b37 <microdelay>
80107f72:	83 c4 10             	add    $0x10,%esp
80107f75:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107f79:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107f7d:	7f 1a                	jg     80107f99 <uart_debug+0xa3>
80107f7f:	83 ec 0c             	sub    $0xc,%esp
80107f82:	68 fd 03 00 00       	push   $0x3fd
80107f87:	e8 2c ff ff ff       	call   80107eb8 <inb>
80107f8c:	83 c4 10             	add    $0x10,%esp
80107f8f:	0f b6 c0             	movzbl %al,%eax
80107f92:	83 e0 20             	and    $0x20,%eax
80107f95:	85 c0                	test   %eax,%eax
80107f97:	74 cf                	je     80107f68 <uart_debug+0x72>
  outb(COM1+0, p);
80107f99:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80107f9d:	0f b6 c0             	movzbl %al,%eax
80107fa0:	83 ec 08             	sub    $0x8,%esp
80107fa3:	50                   	push   %eax
80107fa4:	68 f8 03 00 00       	push   $0x3f8
80107fa9:	e8 27 ff ff ff       	call   80107ed5 <outb>
80107fae:	83 c4 10             	add    $0x10,%esp
}
80107fb1:	90                   	nop
80107fb2:	c9                   	leave  
80107fb3:	c3                   	ret    

80107fb4 <uart_debugs>:

void uart_debugs(char *p){
80107fb4:	55                   	push   %ebp
80107fb5:	89 e5                	mov    %esp,%ebp
80107fb7:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80107fba:	eb 1b                	jmp    80107fd7 <uart_debugs+0x23>
    uart_debug(*p++);
80107fbc:	8b 45 08             	mov    0x8(%ebp),%eax
80107fbf:	8d 50 01             	lea    0x1(%eax),%edx
80107fc2:	89 55 08             	mov    %edx,0x8(%ebp)
80107fc5:	0f b6 00             	movzbl (%eax),%eax
80107fc8:	0f be c0             	movsbl %al,%eax
80107fcb:	83 ec 0c             	sub    $0xc,%esp
80107fce:	50                   	push   %eax
80107fcf:	e8 22 ff ff ff       	call   80107ef6 <uart_debug>
80107fd4:	83 c4 10             	add    $0x10,%esp
  while(*p){
80107fd7:	8b 45 08             	mov    0x8(%ebp),%eax
80107fda:	0f b6 00             	movzbl (%eax),%eax
80107fdd:	84 c0                	test   %al,%al
80107fdf:	75 db                	jne    80107fbc <uart_debugs+0x8>
  }
}
80107fe1:	90                   	nop
80107fe2:	90                   	nop
80107fe3:	c9                   	leave  
80107fe4:	c3                   	ret    

80107fe5 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80107fe5:	55                   	push   %ebp
80107fe6:	89 e5                	mov    %esp,%ebp
80107fe8:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107feb:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80107ff2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107ff5:	8b 50 14             	mov    0x14(%eax),%edx
80107ff8:	8b 40 10             	mov    0x10(%eax),%eax
80107ffb:	a3 48 6d 19 80       	mov    %eax,0x80196d48
  gpu.vram_size = boot_param->graphic_config.frame_size;
80108000:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108003:	8b 50 1c             	mov    0x1c(%eax),%edx
80108006:	8b 40 18             	mov    0x18(%eax),%eax
80108009:	a3 50 6d 19 80       	mov    %eax,0x80196d50
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
8010800e:	8b 15 50 6d 19 80    	mov    0x80196d50,%edx
80108014:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
80108019:	29 d0                	sub    %edx,%eax
8010801b:	a3 4c 6d 19 80       	mov    %eax,0x80196d4c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80108020:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108023:	8b 50 24             	mov    0x24(%eax),%edx
80108026:	8b 40 20             	mov    0x20(%eax),%eax
80108029:	a3 54 6d 19 80       	mov    %eax,0x80196d54
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
8010802e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108031:	8b 50 2c             	mov    0x2c(%eax),%edx
80108034:	8b 40 28             	mov    0x28(%eax),%eax
80108037:	a3 58 6d 19 80       	mov    %eax,0x80196d58
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
8010803c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010803f:	8b 50 34             	mov    0x34(%eax),%edx
80108042:	8b 40 30             	mov    0x30(%eax),%eax
80108045:	a3 5c 6d 19 80       	mov    %eax,0x80196d5c
}
8010804a:	90                   	nop
8010804b:	c9                   	leave  
8010804c:	c3                   	ret    

8010804d <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
8010804d:	55                   	push   %ebp
8010804e:	89 e5                	mov    %esp,%ebp
80108050:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80108053:	8b 15 5c 6d 19 80    	mov    0x80196d5c,%edx
80108059:	8b 45 0c             	mov    0xc(%ebp),%eax
8010805c:	0f af d0             	imul   %eax,%edx
8010805f:	8b 45 08             	mov    0x8(%ebp),%eax
80108062:	01 d0                	add    %edx,%eax
80108064:	c1 e0 02             	shl    $0x2,%eax
80108067:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
8010806a:	8b 15 4c 6d 19 80    	mov    0x80196d4c,%edx
80108070:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108073:	01 d0                	add    %edx,%eax
80108075:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80108078:	8b 45 10             	mov    0x10(%ebp),%eax
8010807b:	0f b6 10             	movzbl (%eax),%edx
8010807e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108081:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80108083:	8b 45 10             	mov    0x10(%ebp),%eax
80108086:	0f b6 50 01          	movzbl 0x1(%eax),%edx
8010808a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010808d:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80108090:	8b 45 10             	mov    0x10(%ebp),%eax
80108093:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80108097:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010809a:	88 50 02             	mov    %dl,0x2(%eax)
}
8010809d:	90                   	nop
8010809e:	c9                   	leave  
8010809f:	c3                   	ret    

801080a0 <graphic_scroll_up>:

void graphic_scroll_up(int height){
801080a0:	55                   	push   %ebp
801080a1:	89 e5                	mov    %esp,%ebp
801080a3:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
801080a6:	8b 15 5c 6d 19 80    	mov    0x80196d5c,%edx
801080ac:	8b 45 08             	mov    0x8(%ebp),%eax
801080af:	0f af c2             	imul   %edx,%eax
801080b2:	c1 e0 02             	shl    $0x2,%eax
801080b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
801080b8:	a1 50 6d 19 80       	mov    0x80196d50,%eax
801080bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801080c0:	29 d0                	sub    %edx,%eax
801080c2:	8b 0d 4c 6d 19 80    	mov    0x80196d4c,%ecx
801080c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801080cb:	01 ca                	add    %ecx,%edx
801080cd:	89 d1                	mov    %edx,%ecx
801080cf:	8b 15 4c 6d 19 80    	mov    0x80196d4c,%edx
801080d5:	83 ec 04             	sub    $0x4,%esp
801080d8:	50                   	push   %eax
801080d9:	51                   	push   %ecx
801080da:	52                   	push   %edx
801080db:	e8 a4 cb ff ff       	call   80104c84 <memmove>
801080e0:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
801080e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080e6:	8b 0d 4c 6d 19 80    	mov    0x80196d4c,%ecx
801080ec:	8b 15 50 6d 19 80    	mov    0x80196d50,%edx
801080f2:	01 ca                	add    %ecx,%edx
801080f4:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801080f7:	29 ca                	sub    %ecx,%edx
801080f9:	83 ec 04             	sub    $0x4,%esp
801080fc:	50                   	push   %eax
801080fd:	6a 00                	push   $0x0
801080ff:	52                   	push   %edx
80108100:	e8 c0 ca ff ff       	call   80104bc5 <memset>
80108105:	83 c4 10             	add    $0x10,%esp
}
80108108:	90                   	nop
80108109:	c9                   	leave  
8010810a:	c3                   	ret    

8010810b <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
8010810b:	55                   	push   %ebp
8010810c:	89 e5                	mov    %esp,%ebp
8010810e:	53                   	push   %ebx
8010810f:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80108112:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108119:	e9 b1 00 00 00       	jmp    801081cf <font_render+0xc4>
    for(int j=14;j>-1;j--){
8010811e:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80108125:	e9 97 00 00 00       	jmp    801081c1 <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
8010812a:	8b 45 10             	mov    0x10(%ebp),%eax
8010812d:	83 e8 20             	sub    $0x20,%eax
80108130:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108133:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108136:	01 d0                	add    %edx,%eax
80108138:	0f b7 84 00 00 a9 10 	movzwl -0x7fef5700(%eax,%eax,1),%eax
8010813f:	80 
80108140:	0f b7 d0             	movzwl %ax,%edx
80108143:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108146:	bb 01 00 00 00       	mov    $0x1,%ebx
8010814b:	89 c1                	mov    %eax,%ecx
8010814d:	d3 e3                	shl    %cl,%ebx
8010814f:	89 d8                	mov    %ebx,%eax
80108151:	21 d0                	and    %edx,%eax
80108153:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80108156:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108159:	ba 01 00 00 00       	mov    $0x1,%edx
8010815e:	89 c1                	mov    %eax,%ecx
80108160:	d3 e2                	shl    %cl,%edx
80108162:	89 d0                	mov    %edx,%eax
80108164:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80108167:	75 2b                	jne    80108194 <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80108169:	8b 55 0c             	mov    0xc(%ebp),%edx
8010816c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010816f:	01 c2                	add    %eax,%edx
80108171:	b8 0e 00 00 00       	mov    $0xe,%eax
80108176:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108179:	89 c1                	mov    %eax,%ecx
8010817b:	8b 45 08             	mov    0x8(%ebp),%eax
8010817e:	01 c8                	add    %ecx,%eax
80108180:	83 ec 04             	sub    $0x4,%esp
80108183:	68 e0 f4 10 80       	push   $0x8010f4e0
80108188:	52                   	push   %edx
80108189:	50                   	push   %eax
8010818a:	e8 be fe ff ff       	call   8010804d <graphic_draw_pixel>
8010818f:	83 c4 10             	add    $0x10,%esp
80108192:	eb 29                	jmp    801081bd <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
80108194:	8b 55 0c             	mov    0xc(%ebp),%edx
80108197:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010819a:	01 c2                	add    %eax,%edx
8010819c:	b8 0e 00 00 00       	mov    $0xe,%eax
801081a1:	2b 45 f0             	sub    -0x10(%ebp),%eax
801081a4:	89 c1                	mov    %eax,%ecx
801081a6:	8b 45 08             	mov    0x8(%ebp),%eax
801081a9:	01 c8                	add    %ecx,%eax
801081ab:	83 ec 04             	sub    $0x4,%esp
801081ae:	68 60 6d 19 80       	push   $0x80196d60
801081b3:	52                   	push   %edx
801081b4:	50                   	push   %eax
801081b5:	e8 93 fe ff ff       	call   8010804d <graphic_draw_pixel>
801081ba:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
801081bd:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
801081c1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801081c5:	0f 89 5f ff ff ff    	jns    8010812a <font_render+0x1f>
  for(int i=0;i<30;i++){
801081cb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801081cf:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
801081d3:	0f 8e 45 ff ff ff    	jle    8010811e <font_render+0x13>
      }
    }
  }
}
801081d9:	90                   	nop
801081da:	90                   	nop
801081db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801081de:	c9                   	leave  
801081df:	c3                   	ret    

801081e0 <font_render_string>:

void font_render_string(char *string,int row){
801081e0:	55                   	push   %ebp
801081e1:	89 e5                	mov    %esp,%ebp
801081e3:	53                   	push   %ebx
801081e4:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
801081e7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
801081ee:	eb 33                	jmp    80108223 <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
801081f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801081f3:	8b 45 08             	mov    0x8(%ebp),%eax
801081f6:	01 d0                	add    %edx,%eax
801081f8:	0f b6 00             	movzbl (%eax),%eax
801081fb:	0f be c8             	movsbl %al,%ecx
801081fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80108201:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108204:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80108207:	89 d8                	mov    %ebx,%eax
80108209:	c1 e0 04             	shl    $0x4,%eax
8010820c:	29 d8                	sub    %ebx,%eax
8010820e:	83 c0 02             	add    $0x2,%eax
80108211:	83 ec 04             	sub    $0x4,%esp
80108214:	51                   	push   %ecx
80108215:	52                   	push   %edx
80108216:	50                   	push   %eax
80108217:	e8 ef fe ff ff       	call   8010810b <font_render>
8010821c:	83 c4 10             	add    $0x10,%esp
    i++;
8010821f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80108223:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108226:	8b 45 08             	mov    0x8(%ebp),%eax
80108229:	01 d0                	add    %edx,%eax
8010822b:	0f b6 00             	movzbl (%eax),%eax
8010822e:	84 c0                	test   %al,%al
80108230:	74 06                	je     80108238 <font_render_string+0x58>
80108232:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108236:	7e b8                	jle    801081f0 <font_render_string+0x10>
  }
}
80108238:	90                   	nop
80108239:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010823c:	c9                   	leave  
8010823d:	c3                   	ret    

8010823e <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
8010823e:	55                   	push   %ebp
8010823f:	89 e5                	mov    %esp,%ebp
80108241:	53                   	push   %ebx
80108242:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108245:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010824c:	eb 6b                	jmp    801082b9 <pci_init+0x7b>
    for(int j=0;j<32;j++){
8010824e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108255:	eb 58                	jmp    801082af <pci_init+0x71>
      for(int k=0;k<8;k++){
80108257:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010825e:	eb 45                	jmp    801082a5 <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
80108260:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108263:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108266:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108269:	83 ec 0c             	sub    $0xc,%esp
8010826c:	8d 5d e8             	lea    -0x18(%ebp),%ebx
8010826f:	53                   	push   %ebx
80108270:	6a 00                	push   $0x0
80108272:	51                   	push   %ecx
80108273:	52                   	push   %edx
80108274:	50                   	push   %eax
80108275:	e8 b0 00 00 00       	call   8010832a <pci_access_config>
8010827a:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
8010827d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108280:	0f b7 c0             	movzwl %ax,%eax
80108283:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108288:	74 17                	je     801082a1 <pci_init+0x63>
        pci_init_device(i,j,k);
8010828a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010828d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108290:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108293:	83 ec 04             	sub    $0x4,%esp
80108296:	51                   	push   %ecx
80108297:	52                   	push   %edx
80108298:	50                   	push   %eax
80108299:	e8 37 01 00 00       	call   801083d5 <pci_init_device>
8010829e:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
801082a1:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801082a5:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
801082a9:	7e b5                	jle    80108260 <pci_init+0x22>
    for(int j=0;j<32;j++){
801082ab:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801082af:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
801082b3:	7e a2                	jle    80108257 <pci_init+0x19>
  for(int i=0;i<256;i++){
801082b5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801082b9:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801082c0:	7e 8c                	jle    8010824e <pci_init+0x10>
      }
      }
    }
  }
}
801082c2:	90                   	nop
801082c3:	90                   	nop
801082c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801082c7:	c9                   	leave  
801082c8:	c3                   	ret    

801082c9 <pci_write_config>:

void pci_write_config(uint config){
801082c9:	55                   	push   %ebp
801082ca:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
801082cc:	8b 45 08             	mov    0x8(%ebp),%eax
801082cf:	ba f8 0c 00 00       	mov    $0xcf8,%edx
801082d4:	89 c0                	mov    %eax,%eax
801082d6:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801082d7:	90                   	nop
801082d8:	5d                   	pop    %ebp
801082d9:	c3                   	ret    

801082da <pci_write_data>:

void pci_write_data(uint config){
801082da:	55                   	push   %ebp
801082db:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
801082dd:	8b 45 08             	mov    0x8(%ebp),%eax
801082e0:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801082e5:	89 c0                	mov    %eax,%eax
801082e7:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801082e8:	90                   	nop
801082e9:	5d                   	pop    %ebp
801082ea:	c3                   	ret    

801082eb <pci_read_config>:
uint pci_read_config(){
801082eb:	55                   	push   %ebp
801082ec:	89 e5                	mov    %esp,%ebp
801082ee:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
801082f1:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801082f6:	ed                   	in     (%dx),%eax
801082f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
801082fa:	83 ec 0c             	sub    $0xc,%esp
801082fd:	68 c8 00 00 00       	push   $0xc8
80108302:	e8 30 a8 ff ff       	call   80102b37 <microdelay>
80108307:	83 c4 10             	add    $0x10,%esp
  return data;
8010830a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010830d:	c9                   	leave  
8010830e:	c3                   	ret    

8010830f <pci_test>:


void pci_test(){
8010830f:	55                   	push   %ebp
80108310:	89 e5                	mov    %esp,%ebp
80108312:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108315:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
8010831c:	ff 75 fc             	push   -0x4(%ebp)
8010831f:	e8 a5 ff ff ff       	call   801082c9 <pci_write_config>
80108324:	83 c4 04             	add    $0x4,%esp
}
80108327:	90                   	nop
80108328:	c9                   	leave  
80108329:	c3                   	ret    

8010832a <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
8010832a:	55                   	push   %ebp
8010832b:	89 e5                	mov    %esp,%ebp
8010832d:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108330:	8b 45 08             	mov    0x8(%ebp),%eax
80108333:	c1 e0 10             	shl    $0x10,%eax
80108336:	25 00 00 ff 00       	and    $0xff0000,%eax
8010833b:	89 c2                	mov    %eax,%edx
8010833d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108340:	c1 e0 0b             	shl    $0xb,%eax
80108343:	0f b7 c0             	movzwl %ax,%eax
80108346:	09 c2                	or     %eax,%edx
80108348:	8b 45 10             	mov    0x10(%ebp),%eax
8010834b:	c1 e0 08             	shl    $0x8,%eax
8010834e:	25 00 07 00 00       	and    $0x700,%eax
80108353:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108355:	8b 45 14             	mov    0x14(%ebp),%eax
80108358:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010835d:	09 d0                	or     %edx,%eax
8010835f:	0d 00 00 00 80       	or     $0x80000000,%eax
80108364:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80108367:	ff 75 f4             	push   -0xc(%ebp)
8010836a:	e8 5a ff ff ff       	call   801082c9 <pci_write_config>
8010836f:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108372:	e8 74 ff ff ff       	call   801082eb <pci_read_config>
80108377:	8b 55 18             	mov    0x18(%ebp),%edx
8010837a:	89 02                	mov    %eax,(%edx)
}
8010837c:	90                   	nop
8010837d:	c9                   	leave  
8010837e:	c3                   	ret    

8010837f <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
8010837f:	55                   	push   %ebp
80108380:	89 e5                	mov    %esp,%ebp
80108382:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108385:	8b 45 08             	mov    0x8(%ebp),%eax
80108388:	c1 e0 10             	shl    $0x10,%eax
8010838b:	25 00 00 ff 00       	and    $0xff0000,%eax
80108390:	89 c2                	mov    %eax,%edx
80108392:	8b 45 0c             	mov    0xc(%ebp),%eax
80108395:	c1 e0 0b             	shl    $0xb,%eax
80108398:	0f b7 c0             	movzwl %ax,%eax
8010839b:	09 c2                	or     %eax,%edx
8010839d:	8b 45 10             	mov    0x10(%ebp),%eax
801083a0:	c1 e0 08             	shl    $0x8,%eax
801083a3:	25 00 07 00 00       	and    $0x700,%eax
801083a8:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801083aa:	8b 45 14             	mov    0x14(%ebp),%eax
801083ad:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801083b2:	09 d0                	or     %edx,%eax
801083b4:	0d 00 00 00 80       	or     $0x80000000,%eax
801083b9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
801083bc:	ff 75 fc             	push   -0x4(%ebp)
801083bf:	e8 05 ff ff ff       	call   801082c9 <pci_write_config>
801083c4:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
801083c7:	ff 75 18             	push   0x18(%ebp)
801083ca:	e8 0b ff ff ff       	call   801082da <pci_write_data>
801083cf:	83 c4 04             	add    $0x4,%esp
}
801083d2:	90                   	nop
801083d3:	c9                   	leave  
801083d4:	c3                   	ret    

801083d5 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
801083d5:	55                   	push   %ebp
801083d6:	89 e5                	mov    %esp,%ebp
801083d8:	53                   	push   %ebx
801083d9:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
801083dc:	8b 45 08             	mov    0x8(%ebp),%eax
801083df:	a2 64 6d 19 80       	mov    %al,0x80196d64
  dev.device_num = device_num;
801083e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801083e7:	a2 65 6d 19 80       	mov    %al,0x80196d65
  dev.function_num = function_num;
801083ec:	8b 45 10             	mov    0x10(%ebp),%eax
801083ef:	a2 66 6d 19 80       	mov    %al,0x80196d66
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
801083f4:	ff 75 10             	push   0x10(%ebp)
801083f7:	ff 75 0c             	push   0xc(%ebp)
801083fa:	ff 75 08             	push   0x8(%ebp)
801083fd:	68 44 bf 10 80       	push   $0x8010bf44
80108402:	e8 ed 7f ff ff       	call   801003f4 <cprintf>
80108407:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
8010840a:	83 ec 0c             	sub    $0xc,%esp
8010840d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108410:	50                   	push   %eax
80108411:	6a 00                	push   $0x0
80108413:	ff 75 10             	push   0x10(%ebp)
80108416:	ff 75 0c             	push   0xc(%ebp)
80108419:	ff 75 08             	push   0x8(%ebp)
8010841c:	e8 09 ff ff ff       	call   8010832a <pci_access_config>
80108421:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108424:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108427:	c1 e8 10             	shr    $0x10,%eax
8010842a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
8010842d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108430:	25 ff ff 00 00       	and    $0xffff,%eax
80108435:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108438:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010843b:	a3 68 6d 19 80       	mov    %eax,0x80196d68
  dev.vendor_id = vendor_id;
80108440:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108443:	a3 6c 6d 19 80       	mov    %eax,0x80196d6c
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108448:	83 ec 04             	sub    $0x4,%esp
8010844b:	ff 75 f0             	push   -0x10(%ebp)
8010844e:	ff 75 f4             	push   -0xc(%ebp)
80108451:	68 78 bf 10 80       	push   $0x8010bf78
80108456:	e8 99 7f ff ff       	call   801003f4 <cprintf>
8010845b:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
8010845e:	83 ec 0c             	sub    $0xc,%esp
80108461:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108464:	50                   	push   %eax
80108465:	6a 08                	push   $0x8
80108467:	ff 75 10             	push   0x10(%ebp)
8010846a:	ff 75 0c             	push   0xc(%ebp)
8010846d:	ff 75 08             	push   0x8(%ebp)
80108470:	e8 b5 fe ff ff       	call   8010832a <pci_access_config>
80108475:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108478:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010847b:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
8010847e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108481:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108484:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108487:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010848a:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010848d:	0f b6 c0             	movzbl %al,%eax
80108490:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108493:	c1 eb 18             	shr    $0x18,%ebx
80108496:	83 ec 0c             	sub    $0xc,%esp
80108499:	51                   	push   %ecx
8010849a:	52                   	push   %edx
8010849b:	50                   	push   %eax
8010849c:	53                   	push   %ebx
8010849d:	68 9c bf 10 80       	push   $0x8010bf9c
801084a2:	e8 4d 7f ff ff       	call   801003f4 <cprintf>
801084a7:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
801084aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084ad:	c1 e8 18             	shr    $0x18,%eax
801084b0:	a2 70 6d 19 80       	mov    %al,0x80196d70
  dev.sub_class = (data>>16)&0xFF;
801084b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084b8:	c1 e8 10             	shr    $0x10,%eax
801084bb:	a2 71 6d 19 80       	mov    %al,0x80196d71
  dev.interface = (data>>8)&0xFF;
801084c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084c3:	c1 e8 08             	shr    $0x8,%eax
801084c6:	a2 72 6d 19 80       	mov    %al,0x80196d72
  dev.revision_id = data&0xFF;
801084cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084ce:	a2 73 6d 19 80       	mov    %al,0x80196d73
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
801084d3:	83 ec 0c             	sub    $0xc,%esp
801084d6:	8d 45 ec             	lea    -0x14(%ebp),%eax
801084d9:	50                   	push   %eax
801084da:	6a 10                	push   $0x10
801084dc:	ff 75 10             	push   0x10(%ebp)
801084df:	ff 75 0c             	push   0xc(%ebp)
801084e2:	ff 75 08             	push   0x8(%ebp)
801084e5:	e8 40 fe ff ff       	call   8010832a <pci_access_config>
801084ea:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
801084ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084f0:	a3 74 6d 19 80       	mov    %eax,0x80196d74
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
801084f5:	83 ec 0c             	sub    $0xc,%esp
801084f8:	8d 45 ec             	lea    -0x14(%ebp),%eax
801084fb:	50                   	push   %eax
801084fc:	6a 14                	push   $0x14
801084fe:	ff 75 10             	push   0x10(%ebp)
80108501:	ff 75 0c             	push   0xc(%ebp)
80108504:	ff 75 08             	push   0x8(%ebp)
80108507:	e8 1e fe ff ff       	call   8010832a <pci_access_config>
8010850c:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
8010850f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108512:	a3 78 6d 19 80       	mov    %eax,0x80196d78
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80108517:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
8010851e:	75 5a                	jne    8010857a <pci_init_device+0x1a5>
80108520:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108527:	75 51                	jne    8010857a <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
80108529:	83 ec 0c             	sub    $0xc,%esp
8010852c:	68 e1 bf 10 80       	push   $0x8010bfe1
80108531:	e8 be 7e ff ff       	call   801003f4 <cprintf>
80108536:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108539:	83 ec 0c             	sub    $0xc,%esp
8010853c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010853f:	50                   	push   %eax
80108540:	68 f0 00 00 00       	push   $0xf0
80108545:	ff 75 10             	push   0x10(%ebp)
80108548:	ff 75 0c             	push   0xc(%ebp)
8010854b:	ff 75 08             	push   0x8(%ebp)
8010854e:	e8 d7 fd ff ff       	call   8010832a <pci_access_config>
80108553:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108556:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108559:	83 ec 08             	sub    $0x8,%esp
8010855c:	50                   	push   %eax
8010855d:	68 fb bf 10 80       	push   $0x8010bffb
80108562:	e8 8d 7e ff ff       	call   801003f4 <cprintf>
80108567:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
8010856a:	83 ec 0c             	sub    $0xc,%esp
8010856d:	68 64 6d 19 80       	push   $0x80196d64
80108572:	e8 09 00 00 00       	call   80108580 <i8254_init>
80108577:	83 c4 10             	add    $0x10,%esp
  }
}
8010857a:	90                   	nop
8010857b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010857e:	c9                   	leave  
8010857f:	c3                   	ret    

80108580 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108580:	55                   	push   %ebp
80108581:	89 e5                	mov    %esp,%ebp
80108583:	53                   	push   %ebx
80108584:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108587:	8b 45 08             	mov    0x8(%ebp),%eax
8010858a:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010858e:	0f b6 c8             	movzbl %al,%ecx
80108591:	8b 45 08             	mov    0x8(%ebp),%eax
80108594:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108598:	0f b6 d0             	movzbl %al,%edx
8010859b:	8b 45 08             	mov    0x8(%ebp),%eax
8010859e:	0f b6 00             	movzbl (%eax),%eax
801085a1:	0f b6 c0             	movzbl %al,%eax
801085a4:	83 ec 0c             	sub    $0xc,%esp
801085a7:	8d 5d ec             	lea    -0x14(%ebp),%ebx
801085aa:	53                   	push   %ebx
801085ab:	6a 04                	push   $0x4
801085ad:	51                   	push   %ecx
801085ae:	52                   	push   %edx
801085af:	50                   	push   %eax
801085b0:	e8 75 fd ff ff       	call   8010832a <pci_access_config>
801085b5:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
801085b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085bb:	83 c8 04             	or     $0x4,%eax
801085be:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
801085c1:	8b 5d ec             	mov    -0x14(%ebp),%ebx
801085c4:	8b 45 08             	mov    0x8(%ebp),%eax
801085c7:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801085cb:	0f b6 c8             	movzbl %al,%ecx
801085ce:	8b 45 08             	mov    0x8(%ebp),%eax
801085d1:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801085d5:	0f b6 d0             	movzbl %al,%edx
801085d8:	8b 45 08             	mov    0x8(%ebp),%eax
801085db:	0f b6 00             	movzbl (%eax),%eax
801085de:	0f b6 c0             	movzbl %al,%eax
801085e1:	83 ec 0c             	sub    $0xc,%esp
801085e4:	53                   	push   %ebx
801085e5:	6a 04                	push   $0x4
801085e7:	51                   	push   %ecx
801085e8:	52                   	push   %edx
801085e9:	50                   	push   %eax
801085ea:	e8 90 fd ff ff       	call   8010837f <pci_write_config_register>
801085ef:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
801085f2:	8b 45 08             	mov    0x8(%ebp),%eax
801085f5:	8b 40 10             	mov    0x10(%eax),%eax
801085f8:	05 00 00 00 40       	add    $0x40000000,%eax
801085fd:	a3 7c 6d 19 80       	mov    %eax,0x80196d7c
  uint *ctrl = (uint *)base_addr;
80108602:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108607:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
8010860a:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
8010860f:	05 d8 00 00 00       	add    $0xd8,%eax
80108614:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108617:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010861a:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108620:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108623:	8b 00                	mov    (%eax),%eax
80108625:	0d 00 00 00 04       	or     $0x4000000,%eax
8010862a:	89 c2                	mov    %eax,%edx
8010862c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010862f:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108631:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108634:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
8010863a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010863d:	8b 00                	mov    (%eax),%eax
8010863f:	83 c8 40             	or     $0x40,%eax
80108642:	89 c2                	mov    %eax,%edx
80108644:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108647:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108649:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010864c:	8b 10                	mov    (%eax),%edx
8010864e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108651:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108653:	83 ec 0c             	sub    $0xc,%esp
80108656:	68 10 c0 10 80       	push   $0x8010c010
8010865b:	e8 94 7d ff ff       	call   801003f4 <cprintf>
80108660:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108663:	e8 38 a1 ff ff       	call   801027a0 <kalloc>
80108668:	a3 88 6d 19 80       	mov    %eax,0x80196d88
  *intr_addr = 0;
8010866d:	a1 88 6d 19 80       	mov    0x80196d88,%eax
80108672:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108678:	a1 88 6d 19 80       	mov    0x80196d88,%eax
8010867d:	83 ec 08             	sub    $0x8,%esp
80108680:	50                   	push   %eax
80108681:	68 32 c0 10 80       	push   $0x8010c032
80108686:	e8 69 7d ff ff       	call   801003f4 <cprintf>
8010868b:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
8010868e:	e8 50 00 00 00       	call   801086e3 <i8254_init_recv>
  i8254_init_send();
80108693:	e8 69 03 00 00       	call   80108a01 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108698:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010869f:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
801086a2:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801086a9:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
801086ac:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801086b3:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
801086b6:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801086bd:	0f b6 c0             	movzbl %al,%eax
801086c0:	83 ec 0c             	sub    $0xc,%esp
801086c3:	53                   	push   %ebx
801086c4:	51                   	push   %ecx
801086c5:	52                   	push   %edx
801086c6:	50                   	push   %eax
801086c7:	68 40 c0 10 80       	push   $0x8010c040
801086cc:	e8 23 7d ff ff       	call   801003f4 <cprintf>
801086d1:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
801086d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086d7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
801086dd:	90                   	nop
801086de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801086e1:	c9                   	leave  
801086e2:	c3                   	ret    

801086e3 <i8254_init_recv>:

void i8254_init_recv(){
801086e3:	55                   	push   %ebp
801086e4:	89 e5                	mov    %esp,%ebp
801086e6:	57                   	push   %edi
801086e7:	56                   	push   %esi
801086e8:	53                   	push   %ebx
801086e9:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
801086ec:	83 ec 0c             	sub    $0xc,%esp
801086ef:	6a 00                	push   $0x0
801086f1:	e8 e8 04 00 00       	call   80108bde <i8254_read_eeprom>
801086f6:	83 c4 10             	add    $0x10,%esp
801086f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
801086fc:	8b 45 d8             	mov    -0x28(%ebp),%eax
801086ff:	a2 80 6d 19 80       	mov    %al,0x80196d80
  mac_addr[1] = data_l>>8;
80108704:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108707:	c1 e8 08             	shr    $0x8,%eax
8010870a:	a2 81 6d 19 80       	mov    %al,0x80196d81
  uint data_m = i8254_read_eeprom(0x1);
8010870f:	83 ec 0c             	sub    $0xc,%esp
80108712:	6a 01                	push   $0x1
80108714:	e8 c5 04 00 00       	call   80108bde <i8254_read_eeprom>
80108719:	83 c4 10             	add    $0x10,%esp
8010871c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
8010871f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108722:	a2 82 6d 19 80       	mov    %al,0x80196d82
  mac_addr[3] = data_m>>8;
80108727:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010872a:	c1 e8 08             	shr    $0x8,%eax
8010872d:	a2 83 6d 19 80       	mov    %al,0x80196d83
  uint data_h = i8254_read_eeprom(0x2);
80108732:	83 ec 0c             	sub    $0xc,%esp
80108735:	6a 02                	push   $0x2
80108737:	e8 a2 04 00 00       	call   80108bde <i8254_read_eeprom>
8010873c:	83 c4 10             	add    $0x10,%esp
8010873f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108742:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108745:	a2 84 6d 19 80       	mov    %al,0x80196d84
  mac_addr[5] = data_h>>8;
8010874a:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010874d:	c1 e8 08             	shr    $0x8,%eax
80108750:	a2 85 6d 19 80       	mov    %al,0x80196d85
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108755:	0f b6 05 85 6d 19 80 	movzbl 0x80196d85,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010875c:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
8010875f:	0f b6 05 84 6d 19 80 	movzbl 0x80196d84,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108766:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108769:	0f b6 05 83 6d 19 80 	movzbl 0x80196d83,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108770:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108773:	0f b6 05 82 6d 19 80 	movzbl 0x80196d82,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010877a:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
8010877d:	0f b6 05 81 6d 19 80 	movzbl 0x80196d81,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108784:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108787:	0f b6 05 80 6d 19 80 	movzbl 0x80196d80,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010878e:	0f b6 c0             	movzbl %al,%eax
80108791:	83 ec 04             	sub    $0x4,%esp
80108794:	57                   	push   %edi
80108795:	56                   	push   %esi
80108796:	53                   	push   %ebx
80108797:	51                   	push   %ecx
80108798:	52                   	push   %edx
80108799:	50                   	push   %eax
8010879a:	68 58 c0 10 80       	push   $0x8010c058
8010879f:	e8 50 7c ff ff       	call   801003f4 <cprintf>
801087a4:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
801087a7:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801087ac:	05 00 54 00 00       	add    $0x5400,%eax
801087b1:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
801087b4:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801087b9:	05 04 54 00 00       	add    $0x5404,%eax
801087be:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
801087c1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801087c4:	c1 e0 10             	shl    $0x10,%eax
801087c7:	0b 45 d8             	or     -0x28(%ebp),%eax
801087ca:	89 c2                	mov    %eax,%edx
801087cc:	8b 45 cc             	mov    -0x34(%ebp),%eax
801087cf:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
801087d1:	8b 45 d0             	mov    -0x30(%ebp),%eax
801087d4:	0d 00 00 00 80       	or     $0x80000000,%eax
801087d9:	89 c2                	mov    %eax,%edx
801087db:	8b 45 c8             	mov    -0x38(%ebp),%eax
801087de:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
801087e0:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801087e5:	05 00 52 00 00       	add    $0x5200,%eax
801087ea:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
801087ed:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801087f4:	eb 19                	jmp    8010880f <i8254_init_recv+0x12c>
    mta[i] = 0;
801087f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801087f9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108800:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108803:	01 d0                	add    %edx,%eax
80108805:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
8010880b:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010880f:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108813:	7e e1                	jle    801087f6 <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108815:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
8010881a:	05 d0 00 00 00       	add    $0xd0,%eax
8010881f:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108822:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108825:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
8010882b:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108830:	05 c8 00 00 00       	add    $0xc8,%eax
80108835:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108838:	8b 45 bc             	mov    -0x44(%ebp),%eax
8010883b:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108841:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108846:	05 28 28 00 00       	add    $0x2828,%eax
8010884b:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
8010884e:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108851:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108857:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
8010885c:	05 00 01 00 00       	add    $0x100,%eax
80108861:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108864:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108867:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
8010886d:	e8 2e 9f ff ff       	call   801027a0 <kalloc>
80108872:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108875:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
8010887a:	05 00 28 00 00       	add    $0x2800,%eax
8010887f:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108882:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108887:	05 04 28 00 00       	add    $0x2804,%eax
8010888c:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
8010888f:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108894:	05 08 28 00 00       	add    $0x2808,%eax
80108899:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
8010889c:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801088a1:	05 10 28 00 00       	add    $0x2810,%eax
801088a6:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
801088a9:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801088ae:	05 18 28 00 00       	add    $0x2818,%eax
801088b3:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
801088b6:	8b 45 b0             	mov    -0x50(%ebp),%eax
801088b9:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801088bf:	8b 45 ac             	mov    -0x54(%ebp),%eax
801088c2:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
801088c4:	8b 45 a8             	mov    -0x58(%ebp),%eax
801088c7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
801088cd:	8b 45 a4             	mov    -0x5c(%ebp),%eax
801088d0:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
801088d6:	8b 45 a0             	mov    -0x60(%ebp),%eax
801088d9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
801088df:	8b 45 9c             	mov    -0x64(%ebp),%eax
801088e2:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
801088e8:	8b 45 b0             	mov    -0x50(%ebp),%eax
801088eb:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
801088ee:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801088f5:	eb 73                	jmp    8010896a <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
801088f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801088fa:	c1 e0 04             	shl    $0x4,%eax
801088fd:	89 c2                	mov    %eax,%edx
801088ff:	8b 45 98             	mov    -0x68(%ebp),%eax
80108902:	01 d0                	add    %edx,%eax
80108904:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
8010890b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010890e:	c1 e0 04             	shl    $0x4,%eax
80108911:	89 c2                	mov    %eax,%edx
80108913:	8b 45 98             	mov    -0x68(%ebp),%eax
80108916:	01 d0                	add    %edx,%eax
80108918:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
8010891e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108921:	c1 e0 04             	shl    $0x4,%eax
80108924:	89 c2                	mov    %eax,%edx
80108926:	8b 45 98             	mov    -0x68(%ebp),%eax
80108929:	01 d0                	add    %edx,%eax
8010892b:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108931:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108934:	c1 e0 04             	shl    $0x4,%eax
80108937:	89 c2                	mov    %eax,%edx
80108939:	8b 45 98             	mov    -0x68(%ebp),%eax
8010893c:	01 d0                	add    %edx,%eax
8010893e:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108942:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108945:	c1 e0 04             	shl    $0x4,%eax
80108948:	89 c2                	mov    %eax,%edx
8010894a:	8b 45 98             	mov    -0x68(%ebp),%eax
8010894d:	01 d0                	add    %edx,%eax
8010894f:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108953:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108956:	c1 e0 04             	shl    $0x4,%eax
80108959:	89 c2                	mov    %eax,%edx
8010895b:	8b 45 98             	mov    -0x68(%ebp),%eax
8010895e:	01 d0                	add    %edx,%eax
80108960:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108966:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
8010896a:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108971:	7e 84                	jle    801088f7 <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108973:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
8010897a:	eb 57                	jmp    801089d3 <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
8010897c:	e8 1f 9e ff ff       	call   801027a0 <kalloc>
80108981:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108984:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108988:	75 12                	jne    8010899c <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
8010898a:	83 ec 0c             	sub    $0xc,%esp
8010898d:	68 78 c0 10 80       	push   $0x8010c078
80108992:	e8 5d 7a ff ff       	call   801003f4 <cprintf>
80108997:	83 c4 10             	add    $0x10,%esp
      break;
8010899a:	eb 3d                	jmp    801089d9 <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
8010899c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010899f:	c1 e0 04             	shl    $0x4,%eax
801089a2:	89 c2                	mov    %eax,%edx
801089a4:	8b 45 98             	mov    -0x68(%ebp),%eax
801089a7:	01 d0                	add    %edx,%eax
801089a9:	8b 55 94             	mov    -0x6c(%ebp),%edx
801089ac:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801089b2:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
801089b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801089b7:	83 c0 01             	add    $0x1,%eax
801089ba:	c1 e0 04             	shl    $0x4,%eax
801089bd:	89 c2                	mov    %eax,%edx
801089bf:	8b 45 98             	mov    -0x68(%ebp),%eax
801089c2:	01 d0                	add    %edx,%eax
801089c4:	8b 55 94             	mov    -0x6c(%ebp),%edx
801089c7:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
801089cd:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
801089cf:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
801089d3:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
801089d7:	7e a3                	jle    8010897c <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
801089d9:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801089dc:	8b 00                	mov    (%eax),%eax
801089de:	83 c8 02             	or     $0x2,%eax
801089e1:	89 c2                	mov    %eax,%edx
801089e3:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801089e6:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
801089e8:	83 ec 0c             	sub    $0xc,%esp
801089eb:	68 98 c0 10 80       	push   $0x8010c098
801089f0:	e8 ff 79 ff ff       	call   801003f4 <cprintf>
801089f5:	83 c4 10             	add    $0x10,%esp
}
801089f8:	90                   	nop
801089f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
801089fc:	5b                   	pop    %ebx
801089fd:	5e                   	pop    %esi
801089fe:	5f                   	pop    %edi
801089ff:	5d                   	pop    %ebp
80108a00:	c3                   	ret    

80108a01 <i8254_init_send>:

void i8254_init_send(){
80108a01:	55                   	push   %ebp
80108a02:	89 e5                	mov    %esp,%ebp
80108a04:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108a07:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108a0c:	05 28 38 00 00       	add    $0x3828,%eax
80108a11:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108a14:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a17:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108a1d:	e8 7e 9d ff ff       	call   801027a0 <kalloc>
80108a22:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108a25:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108a2a:	05 00 38 00 00       	add    $0x3800,%eax
80108a2f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108a32:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108a37:	05 04 38 00 00       	add    $0x3804,%eax
80108a3c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108a3f:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108a44:	05 08 38 00 00       	add    $0x3808,%eax
80108a49:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108a4c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108a4f:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108a55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108a58:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108a5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108a5d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108a63:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108a66:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108a6c:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108a71:	05 10 38 00 00       	add    $0x3810,%eax
80108a76:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108a79:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108a7e:	05 18 38 00 00       	add    $0x3818,%eax
80108a83:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108a86:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108a89:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108a8f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108a92:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108a98:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108a9b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108a9e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108aa5:	e9 82 00 00 00       	jmp    80108b2c <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80108aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aad:	c1 e0 04             	shl    $0x4,%eax
80108ab0:	89 c2                	mov    %eax,%edx
80108ab2:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ab5:	01 d0                	add    %edx,%eax
80108ab7:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ac1:	c1 e0 04             	shl    $0x4,%eax
80108ac4:	89 c2                	mov    %eax,%edx
80108ac6:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ac9:	01 d0                	add    %edx,%eax
80108acb:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ad4:	c1 e0 04             	shl    $0x4,%eax
80108ad7:	89 c2                	mov    %eax,%edx
80108ad9:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108adc:	01 d0                	add    %edx,%eax
80108ade:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ae5:	c1 e0 04             	shl    $0x4,%eax
80108ae8:	89 c2                	mov    %eax,%edx
80108aea:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108aed:	01 d0                	add    %edx,%eax
80108aef:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108af6:	c1 e0 04             	shl    $0x4,%eax
80108af9:	89 c2                	mov    %eax,%edx
80108afb:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108afe:	01 d0                	add    %edx,%eax
80108b00:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b07:	c1 e0 04             	shl    $0x4,%eax
80108b0a:	89 c2                	mov    %eax,%edx
80108b0c:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b0f:	01 d0                	add    %edx,%eax
80108b11:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b18:	c1 e0 04             	shl    $0x4,%eax
80108b1b:	89 c2                	mov    %eax,%edx
80108b1d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b20:	01 d0                	add    %edx,%eax
80108b22:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108b28:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108b2c:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108b33:	0f 8e 71 ff ff ff    	jle    80108aaa <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108b39:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108b40:	eb 57                	jmp    80108b99 <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
80108b42:	e8 59 9c ff ff       	call   801027a0 <kalloc>
80108b47:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108b4a:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108b4e:	75 12                	jne    80108b62 <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
80108b50:	83 ec 0c             	sub    $0xc,%esp
80108b53:	68 78 c0 10 80       	push   $0x8010c078
80108b58:	e8 97 78 ff ff       	call   801003f4 <cprintf>
80108b5d:	83 c4 10             	add    $0x10,%esp
      break;
80108b60:	eb 3d                	jmp    80108b9f <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108b62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b65:	c1 e0 04             	shl    $0x4,%eax
80108b68:	89 c2                	mov    %eax,%edx
80108b6a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b6d:	01 d0                	add    %edx,%eax
80108b6f:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108b72:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108b78:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108b7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b7d:	83 c0 01             	add    $0x1,%eax
80108b80:	c1 e0 04             	shl    $0x4,%eax
80108b83:	89 c2                	mov    %eax,%edx
80108b85:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b88:	01 d0                	add    %edx,%eax
80108b8a:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108b8d:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108b93:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108b95:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108b99:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108b9d:	7e a3                	jle    80108b42 <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108b9f:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108ba4:	05 00 04 00 00       	add    $0x400,%eax
80108ba9:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108bac:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108baf:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108bb5:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108bba:	05 10 04 00 00       	add    $0x410,%eax
80108bbf:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108bc2:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108bc5:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108bcb:	83 ec 0c             	sub    $0xc,%esp
80108bce:	68 b8 c0 10 80       	push   $0x8010c0b8
80108bd3:	e8 1c 78 ff ff       	call   801003f4 <cprintf>
80108bd8:	83 c4 10             	add    $0x10,%esp

}
80108bdb:	90                   	nop
80108bdc:	c9                   	leave  
80108bdd:	c3                   	ret    

80108bde <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108bde:	55                   	push   %ebp
80108bdf:	89 e5                	mov    %esp,%ebp
80108be1:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80108be4:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108be9:	83 c0 14             	add    $0x14,%eax
80108bec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108bef:	8b 45 08             	mov    0x8(%ebp),%eax
80108bf2:	c1 e0 08             	shl    $0x8,%eax
80108bf5:	0f b7 c0             	movzwl %ax,%eax
80108bf8:	83 c8 01             	or     $0x1,%eax
80108bfb:	89 c2                	mov    %eax,%edx
80108bfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c00:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108c02:	83 ec 0c             	sub    $0xc,%esp
80108c05:	68 d8 c0 10 80       	push   $0x8010c0d8
80108c0a:	e8 e5 77 ff ff       	call   801003f4 <cprintf>
80108c0f:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80108c12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c15:	8b 00                	mov    (%eax),%eax
80108c17:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80108c1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c1d:	83 e0 10             	and    $0x10,%eax
80108c20:	85 c0                	test   %eax,%eax
80108c22:	75 02                	jne    80108c26 <i8254_read_eeprom+0x48>
  while(1){
80108c24:	eb dc                	jmp    80108c02 <i8254_read_eeprom+0x24>
      break;
80108c26:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80108c27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c2a:	8b 00                	mov    (%eax),%eax
80108c2c:	c1 e8 10             	shr    $0x10,%eax
}
80108c2f:	c9                   	leave  
80108c30:	c3                   	ret    

80108c31 <i8254_recv>:
void i8254_recv(){
80108c31:	55                   	push   %ebp
80108c32:	89 e5                	mov    %esp,%ebp
80108c34:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108c37:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108c3c:	05 10 28 00 00       	add    $0x2810,%eax
80108c41:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108c44:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108c49:	05 18 28 00 00       	add    $0x2818,%eax
80108c4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108c51:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108c56:	05 00 28 00 00       	add    $0x2800,%eax
80108c5b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108c5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c61:	8b 00                	mov    (%eax),%eax
80108c63:	05 00 00 00 80       	add    $0x80000000,%eax
80108c68:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c6e:	8b 10                	mov    (%eax),%edx
80108c70:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c73:	8b 08                	mov    (%eax),%ecx
80108c75:	89 d0                	mov    %edx,%eax
80108c77:	29 c8                	sub    %ecx,%eax
80108c79:	25 ff 00 00 00       	and    $0xff,%eax
80108c7e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80108c81:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108c85:	7e 37                	jle    80108cbe <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80108c87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c8a:	8b 00                	mov    (%eax),%eax
80108c8c:	c1 e0 04             	shl    $0x4,%eax
80108c8f:	89 c2                	mov    %eax,%edx
80108c91:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c94:	01 d0                	add    %edx,%eax
80108c96:	8b 00                	mov    (%eax),%eax
80108c98:	05 00 00 00 80       	add    $0x80000000,%eax
80108c9d:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80108ca0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ca3:	8b 00                	mov    (%eax),%eax
80108ca5:	83 c0 01             	add    $0x1,%eax
80108ca8:	0f b6 d0             	movzbl %al,%edx
80108cab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cae:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80108cb0:	83 ec 0c             	sub    $0xc,%esp
80108cb3:	ff 75 e0             	push   -0x20(%ebp)
80108cb6:	e8 15 09 00 00       	call   801095d0 <eth_proc>
80108cbb:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80108cbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cc1:	8b 10                	mov    (%eax),%edx
80108cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cc6:	8b 00                	mov    (%eax),%eax
80108cc8:	39 c2                	cmp    %eax,%edx
80108cca:	75 9f                	jne    80108c6b <i8254_recv+0x3a>
      (*rdt)--;
80108ccc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ccf:	8b 00                	mov    (%eax),%eax
80108cd1:	8d 50 ff             	lea    -0x1(%eax),%edx
80108cd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cd7:	89 10                	mov    %edx,(%eax)
  while(1){
80108cd9:	eb 90                	jmp    80108c6b <i8254_recv+0x3a>

80108cdb <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80108cdb:	55                   	push   %ebp
80108cdc:	89 e5                	mov    %esp,%ebp
80108cde:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80108ce1:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108ce6:	05 10 38 00 00       	add    $0x3810,%eax
80108ceb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108cee:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108cf3:	05 18 38 00 00       	add    $0x3818,%eax
80108cf8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108cfb:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108d00:	05 00 38 00 00       	add    $0x3800,%eax
80108d05:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80108d08:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d0b:	8b 00                	mov    (%eax),%eax
80108d0d:	05 00 00 00 80       	add    $0x80000000,%eax
80108d12:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80108d15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d18:	8b 10                	mov    (%eax),%edx
80108d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d1d:	8b 08                	mov    (%eax),%ecx
80108d1f:	89 d0                	mov    %edx,%eax
80108d21:	29 c8                	sub    %ecx,%eax
80108d23:	0f b6 d0             	movzbl %al,%edx
80108d26:	b8 00 01 00 00       	mov    $0x100,%eax
80108d2b:	29 d0                	sub    %edx,%eax
80108d2d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80108d30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d33:	8b 00                	mov    (%eax),%eax
80108d35:	25 ff 00 00 00       	and    $0xff,%eax
80108d3a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80108d3d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108d41:	0f 8e a8 00 00 00    	jle    80108def <i8254_send+0x114>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80108d47:	8b 45 08             	mov    0x8(%ebp),%eax
80108d4a:	8b 55 e0             	mov    -0x20(%ebp),%edx
80108d4d:	89 d1                	mov    %edx,%ecx
80108d4f:	c1 e1 04             	shl    $0x4,%ecx
80108d52:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108d55:	01 ca                	add    %ecx,%edx
80108d57:	8b 12                	mov    (%edx),%edx
80108d59:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108d5f:	83 ec 04             	sub    $0x4,%esp
80108d62:	ff 75 0c             	push   0xc(%ebp)
80108d65:	50                   	push   %eax
80108d66:	52                   	push   %edx
80108d67:	e8 18 bf ff ff       	call   80104c84 <memmove>
80108d6c:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80108d6f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d72:	c1 e0 04             	shl    $0x4,%eax
80108d75:	89 c2                	mov    %eax,%edx
80108d77:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d7a:	01 d0                	add    %edx,%eax
80108d7c:	8b 55 0c             	mov    0xc(%ebp),%edx
80108d7f:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80108d83:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d86:	c1 e0 04             	shl    $0x4,%eax
80108d89:	89 c2                	mov    %eax,%edx
80108d8b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d8e:	01 d0                	add    %edx,%eax
80108d90:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80108d94:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d97:	c1 e0 04             	shl    $0x4,%eax
80108d9a:	89 c2                	mov    %eax,%edx
80108d9c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d9f:	01 d0                	add    %edx,%eax
80108da1:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80108da5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108da8:	c1 e0 04             	shl    $0x4,%eax
80108dab:	89 c2                	mov    %eax,%edx
80108dad:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108db0:	01 d0                	add    %edx,%eax
80108db2:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80108db6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108db9:	c1 e0 04             	shl    $0x4,%eax
80108dbc:	89 c2                	mov    %eax,%edx
80108dbe:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108dc1:	01 d0                	add    %edx,%eax
80108dc3:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80108dc9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108dcc:	c1 e0 04             	shl    $0x4,%eax
80108dcf:	89 c2                	mov    %eax,%edx
80108dd1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108dd4:	01 d0                	add    %edx,%eax
80108dd6:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80108dda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ddd:	8b 00                	mov    (%eax),%eax
80108ddf:	83 c0 01             	add    $0x1,%eax
80108de2:	0f b6 d0             	movzbl %al,%edx
80108de5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108de8:	89 10                	mov    %edx,(%eax)
    return len;
80108dea:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ded:	eb 05                	jmp    80108df4 <i8254_send+0x119>
  }else{
    return -1;
80108def:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80108df4:	c9                   	leave  
80108df5:	c3                   	ret    

80108df6 <i8254_intr>:

void i8254_intr(){
80108df6:	55                   	push   %ebp
80108df7:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80108df9:	a1 88 6d 19 80       	mov    0x80196d88,%eax
80108dfe:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80108e04:	90                   	nop
80108e05:	5d                   	pop    %ebp
80108e06:	c3                   	ret    

80108e07 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80108e07:	55                   	push   %ebp
80108e08:	89 e5                	mov    %esp,%ebp
80108e0a:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80108e0d:	8b 45 08             	mov    0x8(%ebp),%eax
80108e10:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80108e13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e16:	0f b7 00             	movzwl (%eax),%eax
80108e19:	66 3d 00 01          	cmp    $0x100,%ax
80108e1d:	74 0a                	je     80108e29 <arp_proc+0x22>
80108e1f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108e24:	e9 4f 01 00 00       	jmp    80108f78 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80108e29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e2c:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80108e30:	66 83 f8 08          	cmp    $0x8,%ax
80108e34:	74 0a                	je     80108e40 <arp_proc+0x39>
80108e36:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108e3b:	e9 38 01 00 00       	jmp    80108f78 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
80108e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e43:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80108e47:	3c 06                	cmp    $0x6,%al
80108e49:	74 0a                	je     80108e55 <arp_proc+0x4e>
80108e4b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108e50:	e9 23 01 00 00       	jmp    80108f78 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80108e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e58:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80108e5c:	3c 04                	cmp    $0x4,%al
80108e5e:	74 0a                	je     80108e6a <arp_proc+0x63>
80108e60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108e65:	e9 0e 01 00 00       	jmp    80108f78 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80108e6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e6d:	83 c0 18             	add    $0x18,%eax
80108e70:	83 ec 04             	sub    $0x4,%esp
80108e73:	6a 04                	push   $0x4
80108e75:	50                   	push   %eax
80108e76:	68 e4 f4 10 80       	push   $0x8010f4e4
80108e7b:	e8 ac bd ff ff       	call   80104c2c <memcmp>
80108e80:	83 c4 10             	add    $0x10,%esp
80108e83:	85 c0                	test   %eax,%eax
80108e85:	74 27                	je     80108eae <arp_proc+0xa7>
80108e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e8a:	83 c0 0e             	add    $0xe,%eax
80108e8d:	83 ec 04             	sub    $0x4,%esp
80108e90:	6a 04                	push   $0x4
80108e92:	50                   	push   %eax
80108e93:	68 e4 f4 10 80       	push   $0x8010f4e4
80108e98:	e8 8f bd ff ff       	call   80104c2c <memcmp>
80108e9d:	83 c4 10             	add    $0x10,%esp
80108ea0:	85 c0                	test   %eax,%eax
80108ea2:	74 0a                	je     80108eae <arp_proc+0xa7>
80108ea4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108ea9:	e9 ca 00 00 00       	jmp    80108f78 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108eae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108eb1:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108eb5:	66 3d 00 01          	cmp    $0x100,%ax
80108eb9:	75 69                	jne    80108f24 <arp_proc+0x11d>
80108ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ebe:	83 c0 18             	add    $0x18,%eax
80108ec1:	83 ec 04             	sub    $0x4,%esp
80108ec4:	6a 04                	push   $0x4
80108ec6:	50                   	push   %eax
80108ec7:	68 e4 f4 10 80       	push   $0x8010f4e4
80108ecc:	e8 5b bd ff ff       	call   80104c2c <memcmp>
80108ed1:	83 c4 10             	add    $0x10,%esp
80108ed4:	85 c0                	test   %eax,%eax
80108ed6:	75 4c                	jne    80108f24 <arp_proc+0x11d>
    uint send = (uint)kalloc();
80108ed8:	e8 c3 98 ff ff       	call   801027a0 <kalloc>
80108edd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80108ee0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80108ee7:	83 ec 04             	sub    $0x4,%esp
80108eea:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108eed:	50                   	push   %eax
80108eee:	ff 75 f0             	push   -0x10(%ebp)
80108ef1:	ff 75 f4             	push   -0xc(%ebp)
80108ef4:	e8 1f 04 00 00       	call   80109318 <arp_reply_pkt_create>
80108ef9:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80108efc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108eff:	83 ec 08             	sub    $0x8,%esp
80108f02:	50                   	push   %eax
80108f03:	ff 75 f0             	push   -0x10(%ebp)
80108f06:	e8 d0 fd ff ff       	call   80108cdb <i8254_send>
80108f0b:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
80108f0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f11:	83 ec 0c             	sub    $0xc,%esp
80108f14:	50                   	push   %eax
80108f15:	e8 ec 97 ff ff       	call   80102706 <kfree>
80108f1a:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
80108f1d:	b8 02 00 00 00       	mov    $0x2,%eax
80108f22:	eb 54                	jmp    80108f78 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108f24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f27:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108f2b:	66 3d 00 02          	cmp    $0x200,%ax
80108f2f:	75 42                	jne    80108f73 <arp_proc+0x16c>
80108f31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f34:	83 c0 18             	add    $0x18,%eax
80108f37:	83 ec 04             	sub    $0x4,%esp
80108f3a:	6a 04                	push   $0x4
80108f3c:	50                   	push   %eax
80108f3d:	68 e4 f4 10 80       	push   $0x8010f4e4
80108f42:	e8 e5 bc ff ff       	call   80104c2c <memcmp>
80108f47:	83 c4 10             	add    $0x10,%esp
80108f4a:	85 c0                	test   %eax,%eax
80108f4c:	75 25                	jne    80108f73 <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
80108f4e:	83 ec 0c             	sub    $0xc,%esp
80108f51:	68 dc c0 10 80       	push   $0x8010c0dc
80108f56:	e8 99 74 ff ff       	call   801003f4 <cprintf>
80108f5b:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
80108f5e:	83 ec 0c             	sub    $0xc,%esp
80108f61:	ff 75 f4             	push   -0xc(%ebp)
80108f64:	e8 af 01 00 00       	call   80109118 <arp_table_update>
80108f69:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80108f6c:	b8 01 00 00 00       	mov    $0x1,%eax
80108f71:	eb 05                	jmp    80108f78 <arp_proc+0x171>
  }else{
    return -1;
80108f73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80108f78:	c9                   	leave  
80108f79:	c3                   	ret    

80108f7a <arp_scan>:

void arp_scan(){
80108f7a:	55                   	push   %ebp
80108f7b:	89 e5                	mov    %esp,%ebp
80108f7d:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80108f80:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108f87:	eb 6f                	jmp    80108ff8 <arp_scan+0x7e>
    uint send = (uint)kalloc();
80108f89:	e8 12 98 ff ff       	call   801027a0 <kalloc>
80108f8e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80108f91:	83 ec 04             	sub    $0x4,%esp
80108f94:	ff 75 f4             	push   -0xc(%ebp)
80108f97:	8d 45 e8             	lea    -0x18(%ebp),%eax
80108f9a:	50                   	push   %eax
80108f9b:	ff 75 ec             	push   -0x14(%ebp)
80108f9e:	e8 62 00 00 00       	call   80109005 <arp_broadcast>
80108fa3:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80108fa6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108fa9:	83 ec 08             	sub    $0x8,%esp
80108fac:	50                   	push   %eax
80108fad:	ff 75 ec             	push   -0x14(%ebp)
80108fb0:	e8 26 fd ff ff       	call   80108cdb <i8254_send>
80108fb5:	83 c4 10             	add    $0x10,%esp
80108fb8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80108fbb:	eb 22                	jmp    80108fdf <arp_scan+0x65>
      microdelay(1);
80108fbd:	83 ec 0c             	sub    $0xc,%esp
80108fc0:	6a 01                	push   $0x1
80108fc2:	e8 70 9b ff ff       	call   80102b37 <microdelay>
80108fc7:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80108fca:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108fcd:	83 ec 08             	sub    $0x8,%esp
80108fd0:	50                   	push   %eax
80108fd1:	ff 75 ec             	push   -0x14(%ebp)
80108fd4:	e8 02 fd ff ff       	call   80108cdb <i8254_send>
80108fd9:	83 c4 10             	add    $0x10,%esp
80108fdc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80108fdf:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80108fe3:	74 d8                	je     80108fbd <arp_scan+0x43>
    }
    kfree((char *)send);
80108fe5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fe8:	83 ec 0c             	sub    $0xc,%esp
80108feb:	50                   	push   %eax
80108fec:	e8 15 97 ff ff       	call   80102706 <kfree>
80108ff1:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80108ff4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108ff8:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108fff:	7e 88                	jle    80108f89 <arp_scan+0xf>
  }
}
80109001:	90                   	nop
80109002:	90                   	nop
80109003:	c9                   	leave  
80109004:	c3                   	ret    

80109005 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80109005:	55                   	push   %ebp
80109006:	89 e5                	mov    %esp,%ebp
80109008:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
8010900b:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
8010900f:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80109013:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80109017:	8b 45 10             	mov    0x10(%ebp),%eax
8010901a:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
8010901d:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80109024:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
8010902a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80109031:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109037:	8b 45 0c             	mov    0xc(%ebp),%eax
8010903a:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109040:	8b 45 08             	mov    0x8(%ebp),%eax
80109043:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109046:	8b 45 08             	mov    0x8(%ebp),%eax
80109049:	83 c0 0e             	add    $0xe,%eax
8010904c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
8010904f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109052:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109056:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109059:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
8010905d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109060:	83 ec 04             	sub    $0x4,%esp
80109063:	6a 06                	push   $0x6
80109065:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80109068:	52                   	push   %edx
80109069:	50                   	push   %eax
8010906a:	e8 15 bc ff ff       	call   80104c84 <memmove>
8010906f:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109075:	83 c0 06             	add    $0x6,%eax
80109078:	83 ec 04             	sub    $0x4,%esp
8010907b:	6a 06                	push   $0x6
8010907d:	68 80 6d 19 80       	push   $0x80196d80
80109082:	50                   	push   %eax
80109083:	e8 fc bb ff ff       	call   80104c84 <memmove>
80109088:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
8010908b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010908e:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109093:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109096:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
8010909c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010909f:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
801090a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090a6:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
801090aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090ad:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
801090b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090b6:	8d 50 12             	lea    0x12(%eax),%edx
801090b9:	83 ec 04             	sub    $0x4,%esp
801090bc:	6a 06                	push   $0x6
801090be:	8d 45 e0             	lea    -0x20(%ebp),%eax
801090c1:	50                   	push   %eax
801090c2:	52                   	push   %edx
801090c3:	e8 bc bb ff ff       	call   80104c84 <memmove>
801090c8:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
801090cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090ce:	8d 50 18             	lea    0x18(%eax),%edx
801090d1:	83 ec 04             	sub    $0x4,%esp
801090d4:	6a 04                	push   $0x4
801090d6:	8d 45 ec             	lea    -0x14(%ebp),%eax
801090d9:	50                   	push   %eax
801090da:	52                   	push   %edx
801090db:	e8 a4 bb ff ff       	call   80104c84 <memmove>
801090e0:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801090e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090e6:	83 c0 08             	add    $0x8,%eax
801090e9:	83 ec 04             	sub    $0x4,%esp
801090ec:	6a 06                	push   $0x6
801090ee:	68 80 6d 19 80       	push   $0x80196d80
801090f3:	50                   	push   %eax
801090f4:	e8 8b bb ff ff       	call   80104c84 <memmove>
801090f9:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801090fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090ff:	83 c0 0e             	add    $0xe,%eax
80109102:	83 ec 04             	sub    $0x4,%esp
80109105:	6a 04                	push   $0x4
80109107:	68 e4 f4 10 80       	push   $0x8010f4e4
8010910c:	50                   	push   %eax
8010910d:	e8 72 bb ff ff       	call   80104c84 <memmove>
80109112:	83 c4 10             	add    $0x10,%esp
}
80109115:	90                   	nop
80109116:	c9                   	leave  
80109117:	c3                   	ret    

80109118 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80109118:	55                   	push   %ebp
80109119:	89 e5                	mov    %esp,%ebp
8010911b:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
8010911e:	8b 45 08             	mov    0x8(%ebp),%eax
80109121:	83 c0 0e             	add    $0xe,%eax
80109124:	83 ec 0c             	sub    $0xc,%esp
80109127:	50                   	push   %eax
80109128:	e8 bc 00 00 00       	call   801091e9 <arp_table_search>
8010912d:	83 c4 10             	add    $0x10,%esp
80109130:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80109133:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109137:	78 2d                	js     80109166 <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109139:	8b 45 08             	mov    0x8(%ebp),%eax
8010913c:	8d 48 08             	lea    0x8(%eax),%ecx
8010913f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109142:	89 d0                	mov    %edx,%eax
80109144:	c1 e0 02             	shl    $0x2,%eax
80109147:	01 d0                	add    %edx,%eax
80109149:	01 c0                	add    %eax,%eax
8010914b:	01 d0                	add    %edx,%eax
8010914d:	05 a0 6d 19 80       	add    $0x80196da0,%eax
80109152:	83 c0 04             	add    $0x4,%eax
80109155:	83 ec 04             	sub    $0x4,%esp
80109158:	6a 06                	push   $0x6
8010915a:	51                   	push   %ecx
8010915b:	50                   	push   %eax
8010915c:	e8 23 bb ff ff       	call   80104c84 <memmove>
80109161:	83 c4 10             	add    $0x10,%esp
80109164:	eb 70                	jmp    801091d6 <arp_table_update+0xbe>
  }else{
    index += 1;
80109166:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
8010916a:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
8010916d:	8b 45 08             	mov    0x8(%ebp),%eax
80109170:	8d 48 08             	lea    0x8(%eax),%ecx
80109173:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109176:	89 d0                	mov    %edx,%eax
80109178:	c1 e0 02             	shl    $0x2,%eax
8010917b:	01 d0                	add    %edx,%eax
8010917d:	01 c0                	add    %eax,%eax
8010917f:	01 d0                	add    %edx,%eax
80109181:	05 a0 6d 19 80       	add    $0x80196da0,%eax
80109186:	83 c0 04             	add    $0x4,%eax
80109189:	83 ec 04             	sub    $0x4,%esp
8010918c:	6a 06                	push   $0x6
8010918e:	51                   	push   %ecx
8010918f:	50                   	push   %eax
80109190:	e8 ef ba ff ff       	call   80104c84 <memmove>
80109195:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109198:	8b 45 08             	mov    0x8(%ebp),%eax
8010919b:	8d 48 0e             	lea    0xe(%eax),%ecx
8010919e:	8b 55 f4             	mov    -0xc(%ebp),%edx
801091a1:	89 d0                	mov    %edx,%eax
801091a3:	c1 e0 02             	shl    $0x2,%eax
801091a6:	01 d0                	add    %edx,%eax
801091a8:	01 c0                	add    %eax,%eax
801091aa:	01 d0                	add    %edx,%eax
801091ac:	05 a0 6d 19 80       	add    $0x80196da0,%eax
801091b1:	83 ec 04             	sub    $0x4,%esp
801091b4:	6a 04                	push   $0x4
801091b6:	51                   	push   %ecx
801091b7:	50                   	push   %eax
801091b8:	e8 c7 ba ff ff       	call   80104c84 <memmove>
801091bd:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
801091c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801091c3:	89 d0                	mov    %edx,%eax
801091c5:	c1 e0 02             	shl    $0x2,%eax
801091c8:	01 d0                	add    %edx,%eax
801091ca:	01 c0                	add    %eax,%eax
801091cc:	01 d0                	add    %edx,%eax
801091ce:	05 aa 6d 19 80       	add    $0x80196daa,%eax
801091d3:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
801091d6:	83 ec 0c             	sub    $0xc,%esp
801091d9:	68 a0 6d 19 80       	push   $0x80196da0
801091de:	e8 83 00 00 00       	call   80109266 <print_arp_table>
801091e3:	83 c4 10             	add    $0x10,%esp
}
801091e6:	90                   	nop
801091e7:	c9                   	leave  
801091e8:	c3                   	ret    

801091e9 <arp_table_search>:

int arp_table_search(uchar *ip){
801091e9:	55                   	push   %ebp
801091ea:	89 e5                	mov    %esp,%ebp
801091ec:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
801091ef:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801091f6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801091fd:	eb 59                	jmp    80109258 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
801091ff:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109202:	89 d0                	mov    %edx,%eax
80109204:	c1 e0 02             	shl    $0x2,%eax
80109207:	01 d0                	add    %edx,%eax
80109209:	01 c0                	add    %eax,%eax
8010920b:	01 d0                	add    %edx,%eax
8010920d:	05 a0 6d 19 80       	add    $0x80196da0,%eax
80109212:	83 ec 04             	sub    $0x4,%esp
80109215:	6a 04                	push   $0x4
80109217:	ff 75 08             	push   0x8(%ebp)
8010921a:	50                   	push   %eax
8010921b:	e8 0c ba ff ff       	call   80104c2c <memcmp>
80109220:	83 c4 10             	add    $0x10,%esp
80109223:	85 c0                	test   %eax,%eax
80109225:	75 05                	jne    8010922c <arp_table_search+0x43>
      return i;
80109227:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010922a:	eb 38                	jmp    80109264 <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
8010922c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010922f:	89 d0                	mov    %edx,%eax
80109231:	c1 e0 02             	shl    $0x2,%eax
80109234:	01 d0                	add    %edx,%eax
80109236:	01 c0                	add    %eax,%eax
80109238:	01 d0                	add    %edx,%eax
8010923a:	05 aa 6d 19 80       	add    $0x80196daa,%eax
8010923f:	0f b6 00             	movzbl (%eax),%eax
80109242:	84 c0                	test   %al,%al
80109244:	75 0e                	jne    80109254 <arp_table_search+0x6b>
80109246:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010924a:	75 08                	jne    80109254 <arp_table_search+0x6b>
      empty = -i;
8010924c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010924f:	f7 d8                	neg    %eax
80109251:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109254:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109258:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
8010925c:	7e a1                	jle    801091ff <arp_table_search+0x16>
    }
  }
  return empty-1;
8010925e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109261:	83 e8 01             	sub    $0x1,%eax
}
80109264:	c9                   	leave  
80109265:	c3                   	ret    

80109266 <print_arp_table>:

void print_arp_table(){
80109266:	55                   	push   %ebp
80109267:	89 e5                	mov    %esp,%ebp
80109269:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
8010926c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109273:	e9 92 00 00 00       	jmp    8010930a <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
80109278:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010927b:	89 d0                	mov    %edx,%eax
8010927d:	c1 e0 02             	shl    $0x2,%eax
80109280:	01 d0                	add    %edx,%eax
80109282:	01 c0                	add    %eax,%eax
80109284:	01 d0                	add    %edx,%eax
80109286:	05 aa 6d 19 80       	add    $0x80196daa,%eax
8010928b:	0f b6 00             	movzbl (%eax),%eax
8010928e:	84 c0                	test   %al,%al
80109290:	74 74                	je     80109306 <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
80109292:	83 ec 08             	sub    $0x8,%esp
80109295:	ff 75 f4             	push   -0xc(%ebp)
80109298:	68 ef c0 10 80       	push   $0x8010c0ef
8010929d:	e8 52 71 ff ff       	call   801003f4 <cprintf>
801092a2:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
801092a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801092a8:	89 d0                	mov    %edx,%eax
801092aa:	c1 e0 02             	shl    $0x2,%eax
801092ad:	01 d0                	add    %edx,%eax
801092af:	01 c0                	add    %eax,%eax
801092b1:	01 d0                	add    %edx,%eax
801092b3:	05 a0 6d 19 80       	add    $0x80196da0,%eax
801092b8:	83 ec 0c             	sub    $0xc,%esp
801092bb:	50                   	push   %eax
801092bc:	e8 54 02 00 00       	call   80109515 <print_ipv4>
801092c1:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
801092c4:	83 ec 0c             	sub    $0xc,%esp
801092c7:	68 fe c0 10 80       	push   $0x8010c0fe
801092cc:	e8 23 71 ff ff       	call   801003f4 <cprintf>
801092d1:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
801092d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801092d7:	89 d0                	mov    %edx,%eax
801092d9:	c1 e0 02             	shl    $0x2,%eax
801092dc:	01 d0                	add    %edx,%eax
801092de:	01 c0                	add    %eax,%eax
801092e0:	01 d0                	add    %edx,%eax
801092e2:	05 a0 6d 19 80       	add    $0x80196da0,%eax
801092e7:	83 c0 04             	add    $0x4,%eax
801092ea:	83 ec 0c             	sub    $0xc,%esp
801092ed:	50                   	push   %eax
801092ee:	e8 70 02 00 00       	call   80109563 <print_mac>
801092f3:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
801092f6:	83 ec 0c             	sub    $0xc,%esp
801092f9:	68 00 c1 10 80       	push   $0x8010c100
801092fe:	e8 f1 70 ff ff       	call   801003f4 <cprintf>
80109303:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109306:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010930a:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
8010930e:	0f 8e 64 ff ff ff    	jle    80109278 <print_arp_table+0x12>
    }
  }
}
80109314:	90                   	nop
80109315:	90                   	nop
80109316:	c9                   	leave  
80109317:	c3                   	ret    

80109318 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
80109318:	55                   	push   %ebp
80109319:	89 e5                	mov    %esp,%ebp
8010931b:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
8010931e:	8b 45 10             	mov    0x10(%ebp),%eax
80109321:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109327:	8b 45 0c             	mov    0xc(%ebp),%eax
8010932a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
8010932d:	8b 45 0c             	mov    0xc(%ebp),%eax
80109330:	83 c0 0e             	add    $0xe,%eax
80109333:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109336:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109339:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
8010933d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109340:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109344:	8b 45 08             	mov    0x8(%ebp),%eax
80109347:	8d 50 08             	lea    0x8(%eax),%edx
8010934a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010934d:	83 ec 04             	sub    $0x4,%esp
80109350:	6a 06                	push   $0x6
80109352:	52                   	push   %edx
80109353:	50                   	push   %eax
80109354:	e8 2b b9 ff ff       	call   80104c84 <memmove>
80109359:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
8010935c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010935f:	83 c0 06             	add    $0x6,%eax
80109362:	83 ec 04             	sub    $0x4,%esp
80109365:	6a 06                	push   $0x6
80109367:	68 80 6d 19 80       	push   $0x80196d80
8010936c:	50                   	push   %eax
8010936d:	e8 12 b9 ff ff       	call   80104c84 <memmove>
80109372:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109375:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109378:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
8010937d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109380:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109386:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109389:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
8010938d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109390:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109394:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109397:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
8010939d:	8b 45 08             	mov    0x8(%ebp),%eax
801093a0:	8d 50 08             	lea    0x8(%eax),%edx
801093a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093a6:	83 c0 12             	add    $0x12,%eax
801093a9:	83 ec 04             	sub    $0x4,%esp
801093ac:	6a 06                	push   $0x6
801093ae:	52                   	push   %edx
801093af:	50                   	push   %eax
801093b0:	e8 cf b8 ff ff       	call   80104c84 <memmove>
801093b5:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
801093b8:	8b 45 08             	mov    0x8(%ebp),%eax
801093bb:	8d 50 0e             	lea    0xe(%eax),%edx
801093be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093c1:	83 c0 18             	add    $0x18,%eax
801093c4:	83 ec 04             	sub    $0x4,%esp
801093c7:	6a 04                	push   $0x4
801093c9:	52                   	push   %edx
801093ca:	50                   	push   %eax
801093cb:	e8 b4 b8 ff ff       	call   80104c84 <memmove>
801093d0:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801093d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093d6:	83 c0 08             	add    $0x8,%eax
801093d9:	83 ec 04             	sub    $0x4,%esp
801093dc:	6a 06                	push   $0x6
801093de:	68 80 6d 19 80       	push   $0x80196d80
801093e3:	50                   	push   %eax
801093e4:	e8 9b b8 ff ff       	call   80104c84 <memmove>
801093e9:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801093ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093ef:	83 c0 0e             	add    $0xe,%eax
801093f2:	83 ec 04             	sub    $0x4,%esp
801093f5:	6a 04                	push   $0x4
801093f7:	68 e4 f4 10 80       	push   $0x8010f4e4
801093fc:	50                   	push   %eax
801093fd:	e8 82 b8 ff ff       	call   80104c84 <memmove>
80109402:	83 c4 10             	add    $0x10,%esp
}
80109405:	90                   	nop
80109406:	c9                   	leave  
80109407:	c3                   	ret    

80109408 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
80109408:	55                   	push   %ebp
80109409:	89 e5                	mov    %esp,%ebp
8010940b:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
8010940e:	83 ec 0c             	sub    $0xc,%esp
80109411:	68 02 c1 10 80       	push   $0x8010c102
80109416:	e8 d9 6f ff ff       	call   801003f4 <cprintf>
8010941b:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
8010941e:	8b 45 08             	mov    0x8(%ebp),%eax
80109421:	83 c0 0e             	add    $0xe,%eax
80109424:	83 ec 0c             	sub    $0xc,%esp
80109427:	50                   	push   %eax
80109428:	e8 e8 00 00 00       	call   80109515 <print_ipv4>
8010942d:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109430:	83 ec 0c             	sub    $0xc,%esp
80109433:	68 00 c1 10 80       	push   $0x8010c100
80109438:	e8 b7 6f ff ff       	call   801003f4 <cprintf>
8010943d:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
80109440:	8b 45 08             	mov    0x8(%ebp),%eax
80109443:	83 c0 08             	add    $0x8,%eax
80109446:	83 ec 0c             	sub    $0xc,%esp
80109449:	50                   	push   %eax
8010944a:	e8 14 01 00 00       	call   80109563 <print_mac>
8010944f:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109452:	83 ec 0c             	sub    $0xc,%esp
80109455:	68 00 c1 10 80       	push   $0x8010c100
8010945a:	e8 95 6f ff ff       	call   801003f4 <cprintf>
8010945f:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
80109462:	83 ec 0c             	sub    $0xc,%esp
80109465:	68 19 c1 10 80       	push   $0x8010c119
8010946a:	e8 85 6f ff ff       	call   801003f4 <cprintf>
8010946f:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
80109472:	8b 45 08             	mov    0x8(%ebp),%eax
80109475:	83 c0 18             	add    $0x18,%eax
80109478:	83 ec 0c             	sub    $0xc,%esp
8010947b:	50                   	push   %eax
8010947c:	e8 94 00 00 00       	call   80109515 <print_ipv4>
80109481:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109484:	83 ec 0c             	sub    $0xc,%esp
80109487:	68 00 c1 10 80       	push   $0x8010c100
8010948c:	e8 63 6f ff ff       	call   801003f4 <cprintf>
80109491:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109494:	8b 45 08             	mov    0x8(%ebp),%eax
80109497:	83 c0 12             	add    $0x12,%eax
8010949a:	83 ec 0c             	sub    $0xc,%esp
8010949d:	50                   	push   %eax
8010949e:	e8 c0 00 00 00       	call   80109563 <print_mac>
801094a3:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801094a6:	83 ec 0c             	sub    $0xc,%esp
801094a9:	68 00 c1 10 80       	push   $0x8010c100
801094ae:	e8 41 6f ff ff       	call   801003f4 <cprintf>
801094b3:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
801094b6:	83 ec 0c             	sub    $0xc,%esp
801094b9:	68 30 c1 10 80       	push   $0x8010c130
801094be:	e8 31 6f ff ff       	call   801003f4 <cprintf>
801094c3:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
801094c6:	8b 45 08             	mov    0x8(%ebp),%eax
801094c9:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801094cd:	66 3d 00 01          	cmp    $0x100,%ax
801094d1:	75 12                	jne    801094e5 <print_arp_info+0xdd>
801094d3:	83 ec 0c             	sub    $0xc,%esp
801094d6:	68 3c c1 10 80       	push   $0x8010c13c
801094db:	e8 14 6f ff ff       	call   801003f4 <cprintf>
801094e0:	83 c4 10             	add    $0x10,%esp
801094e3:	eb 1d                	jmp    80109502 <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
801094e5:	8b 45 08             	mov    0x8(%ebp),%eax
801094e8:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801094ec:	66 3d 00 02          	cmp    $0x200,%ax
801094f0:	75 10                	jne    80109502 <print_arp_info+0xfa>
    cprintf("Reply\n");
801094f2:	83 ec 0c             	sub    $0xc,%esp
801094f5:	68 45 c1 10 80       	push   $0x8010c145
801094fa:	e8 f5 6e ff ff       	call   801003f4 <cprintf>
801094ff:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
80109502:	83 ec 0c             	sub    $0xc,%esp
80109505:	68 00 c1 10 80       	push   $0x8010c100
8010950a:	e8 e5 6e ff ff       	call   801003f4 <cprintf>
8010950f:	83 c4 10             	add    $0x10,%esp
}
80109512:	90                   	nop
80109513:	c9                   	leave  
80109514:	c3                   	ret    

80109515 <print_ipv4>:

void print_ipv4(uchar *ip){
80109515:	55                   	push   %ebp
80109516:	89 e5                	mov    %esp,%ebp
80109518:	53                   	push   %ebx
80109519:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
8010951c:	8b 45 08             	mov    0x8(%ebp),%eax
8010951f:	83 c0 03             	add    $0x3,%eax
80109522:	0f b6 00             	movzbl (%eax),%eax
80109525:	0f b6 d8             	movzbl %al,%ebx
80109528:	8b 45 08             	mov    0x8(%ebp),%eax
8010952b:	83 c0 02             	add    $0x2,%eax
8010952e:	0f b6 00             	movzbl (%eax),%eax
80109531:	0f b6 c8             	movzbl %al,%ecx
80109534:	8b 45 08             	mov    0x8(%ebp),%eax
80109537:	83 c0 01             	add    $0x1,%eax
8010953a:	0f b6 00             	movzbl (%eax),%eax
8010953d:	0f b6 d0             	movzbl %al,%edx
80109540:	8b 45 08             	mov    0x8(%ebp),%eax
80109543:	0f b6 00             	movzbl (%eax),%eax
80109546:	0f b6 c0             	movzbl %al,%eax
80109549:	83 ec 0c             	sub    $0xc,%esp
8010954c:	53                   	push   %ebx
8010954d:	51                   	push   %ecx
8010954e:	52                   	push   %edx
8010954f:	50                   	push   %eax
80109550:	68 4c c1 10 80       	push   $0x8010c14c
80109555:	e8 9a 6e ff ff       	call   801003f4 <cprintf>
8010955a:	83 c4 20             	add    $0x20,%esp
}
8010955d:	90                   	nop
8010955e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109561:	c9                   	leave  
80109562:	c3                   	ret    

80109563 <print_mac>:

void print_mac(uchar *mac){
80109563:	55                   	push   %ebp
80109564:	89 e5                	mov    %esp,%ebp
80109566:	57                   	push   %edi
80109567:	56                   	push   %esi
80109568:	53                   	push   %ebx
80109569:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
8010956c:	8b 45 08             	mov    0x8(%ebp),%eax
8010956f:	83 c0 05             	add    $0x5,%eax
80109572:	0f b6 00             	movzbl (%eax),%eax
80109575:	0f b6 f8             	movzbl %al,%edi
80109578:	8b 45 08             	mov    0x8(%ebp),%eax
8010957b:	83 c0 04             	add    $0x4,%eax
8010957e:	0f b6 00             	movzbl (%eax),%eax
80109581:	0f b6 f0             	movzbl %al,%esi
80109584:	8b 45 08             	mov    0x8(%ebp),%eax
80109587:	83 c0 03             	add    $0x3,%eax
8010958a:	0f b6 00             	movzbl (%eax),%eax
8010958d:	0f b6 d8             	movzbl %al,%ebx
80109590:	8b 45 08             	mov    0x8(%ebp),%eax
80109593:	83 c0 02             	add    $0x2,%eax
80109596:	0f b6 00             	movzbl (%eax),%eax
80109599:	0f b6 c8             	movzbl %al,%ecx
8010959c:	8b 45 08             	mov    0x8(%ebp),%eax
8010959f:	83 c0 01             	add    $0x1,%eax
801095a2:	0f b6 00             	movzbl (%eax),%eax
801095a5:	0f b6 d0             	movzbl %al,%edx
801095a8:	8b 45 08             	mov    0x8(%ebp),%eax
801095ab:	0f b6 00             	movzbl (%eax),%eax
801095ae:	0f b6 c0             	movzbl %al,%eax
801095b1:	83 ec 04             	sub    $0x4,%esp
801095b4:	57                   	push   %edi
801095b5:	56                   	push   %esi
801095b6:	53                   	push   %ebx
801095b7:	51                   	push   %ecx
801095b8:	52                   	push   %edx
801095b9:	50                   	push   %eax
801095ba:	68 64 c1 10 80       	push   $0x8010c164
801095bf:	e8 30 6e ff ff       	call   801003f4 <cprintf>
801095c4:	83 c4 20             	add    $0x20,%esp
}
801095c7:	90                   	nop
801095c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801095cb:	5b                   	pop    %ebx
801095cc:	5e                   	pop    %esi
801095cd:	5f                   	pop    %edi
801095ce:	5d                   	pop    %ebp
801095cf:	c3                   	ret    

801095d0 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
801095d0:	55                   	push   %ebp
801095d1:	89 e5                	mov    %esp,%ebp
801095d3:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
801095d6:	8b 45 08             	mov    0x8(%ebp),%eax
801095d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
801095dc:	8b 45 08             	mov    0x8(%ebp),%eax
801095df:	83 c0 0e             	add    $0xe,%eax
801095e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
801095e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095e8:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801095ec:	3c 08                	cmp    $0x8,%al
801095ee:	75 1b                	jne    8010960b <eth_proc+0x3b>
801095f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095f3:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801095f7:	3c 06                	cmp    $0x6,%al
801095f9:	75 10                	jne    8010960b <eth_proc+0x3b>
    arp_proc(pkt_addr);
801095fb:	83 ec 0c             	sub    $0xc,%esp
801095fe:	ff 75 f0             	push   -0x10(%ebp)
80109601:	e8 01 f8 ff ff       	call   80108e07 <arp_proc>
80109606:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109609:	eb 24                	jmp    8010962f <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
8010960b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010960e:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109612:	3c 08                	cmp    $0x8,%al
80109614:	75 19                	jne    8010962f <eth_proc+0x5f>
80109616:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109619:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010961d:	84 c0                	test   %al,%al
8010961f:	75 0e                	jne    8010962f <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
80109621:	83 ec 0c             	sub    $0xc,%esp
80109624:	ff 75 08             	push   0x8(%ebp)
80109627:	e8 a3 00 00 00       	call   801096cf <ipv4_proc>
8010962c:	83 c4 10             	add    $0x10,%esp
}
8010962f:	90                   	nop
80109630:	c9                   	leave  
80109631:	c3                   	ret    

80109632 <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109632:	55                   	push   %ebp
80109633:	89 e5                	mov    %esp,%ebp
80109635:	83 ec 04             	sub    $0x4,%esp
80109638:	8b 45 08             	mov    0x8(%ebp),%eax
8010963b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
8010963f:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109643:	c1 e0 08             	shl    $0x8,%eax
80109646:	89 c2                	mov    %eax,%edx
80109648:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010964c:	66 c1 e8 08          	shr    $0x8,%ax
80109650:	01 d0                	add    %edx,%eax
}
80109652:	c9                   	leave  
80109653:	c3                   	ret    

80109654 <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109654:	55                   	push   %ebp
80109655:	89 e5                	mov    %esp,%ebp
80109657:	83 ec 04             	sub    $0x4,%esp
8010965a:	8b 45 08             	mov    0x8(%ebp),%eax
8010965d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109661:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109665:	c1 e0 08             	shl    $0x8,%eax
80109668:	89 c2                	mov    %eax,%edx
8010966a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010966e:	66 c1 e8 08          	shr    $0x8,%ax
80109672:	01 d0                	add    %edx,%eax
}
80109674:	c9                   	leave  
80109675:	c3                   	ret    

80109676 <H2N_uint>:

uint H2N_uint(uint value){
80109676:	55                   	push   %ebp
80109677:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109679:	8b 45 08             	mov    0x8(%ebp),%eax
8010967c:	c1 e0 18             	shl    $0x18,%eax
8010967f:	25 00 00 00 0f       	and    $0xf000000,%eax
80109684:	89 c2                	mov    %eax,%edx
80109686:	8b 45 08             	mov    0x8(%ebp),%eax
80109689:	c1 e0 08             	shl    $0x8,%eax
8010968c:	25 00 f0 00 00       	and    $0xf000,%eax
80109691:	09 c2                	or     %eax,%edx
80109693:	8b 45 08             	mov    0x8(%ebp),%eax
80109696:	c1 e8 08             	shr    $0x8,%eax
80109699:	83 e0 0f             	and    $0xf,%eax
8010969c:	01 d0                	add    %edx,%eax
}
8010969e:	5d                   	pop    %ebp
8010969f:	c3                   	ret    

801096a0 <N2H_uint>:

uint N2H_uint(uint value){
801096a0:	55                   	push   %ebp
801096a1:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
801096a3:	8b 45 08             	mov    0x8(%ebp),%eax
801096a6:	c1 e0 18             	shl    $0x18,%eax
801096a9:	89 c2                	mov    %eax,%edx
801096ab:	8b 45 08             	mov    0x8(%ebp),%eax
801096ae:	c1 e0 08             	shl    $0x8,%eax
801096b1:	25 00 00 ff 00       	and    $0xff0000,%eax
801096b6:	01 c2                	add    %eax,%edx
801096b8:	8b 45 08             	mov    0x8(%ebp),%eax
801096bb:	c1 e8 08             	shr    $0x8,%eax
801096be:	25 00 ff 00 00       	and    $0xff00,%eax
801096c3:	01 c2                	add    %eax,%edx
801096c5:	8b 45 08             	mov    0x8(%ebp),%eax
801096c8:	c1 e8 18             	shr    $0x18,%eax
801096cb:	01 d0                	add    %edx,%eax
}
801096cd:	5d                   	pop    %ebp
801096ce:	c3                   	ret    

801096cf <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
801096cf:	55                   	push   %ebp
801096d0:	89 e5                	mov    %esp,%ebp
801096d2:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
801096d5:	8b 45 08             	mov    0x8(%ebp),%eax
801096d8:	83 c0 0e             	add    $0xe,%eax
801096db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
801096de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096e1:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801096e5:	0f b7 d0             	movzwl %ax,%edx
801096e8:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
801096ed:	39 c2                	cmp    %eax,%edx
801096ef:	74 60                	je     80109751 <ipv4_proc+0x82>
801096f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096f4:	83 c0 0c             	add    $0xc,%eax
801096f7:	83 ec 04             	sub    $0x4,%esp
801096fa:	6a 04                	push   $0x4
801096fc:	50                   	push   %eax
801096fd:	68 e4 f4 10 80       	push   $0x8010f4e4
80109702:	e8 25 b5 ff ff       	call   80104c2c <memcmp>
80109707:	83 c4 10             	add    $0x10,%esp
8010970a:	85 c0                	test   %eax,%eax
8010970c:	74 43                	je     80109751 <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
8010970e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109711:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109715:	0f b7 c0             	movzwl %ax,%eax
80109718:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
8010971d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109720:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109724:	3c 01                	cmp    $0x1,%al
80109726:	75 10                	jne    80109738 <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
80109728:	83 ec 0c             	sub    $0xc,%esp
8010972b:	ff 75 08             	push   0x8(%ebp)
8010972e:	e8 a3 00 00 00       	call   801097d6 <icmp_proc>
80109733:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109736:	eb 19                	jmp    80109751 <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109738:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010973b:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010973f:	3c 06                	cmp    $0x6,%al
80109741:	75 0e                	jne    80109751 <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
80109743:	83 ec 0c             	sub    $0xc,%esp
80109746:	ff 75 08             	push   0x8(%ebp)
80109749:	e8 b3 03 00 00       	call   80109b01 <tcp_proc>
8010974e:	83 c4 10             	add    $0x10,%esp
}
80109751:	90                   	nop
80109752:	c9                   	leave  
80109753:	c3                   	ret    

80109754 <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109754:	55                   	push   %ebp
80109755:	89 e5                	mov    %esp,%ebp
80109757:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
8010975a:	8b 45 08             	mov    0x8(%ebp),%eax
8010975d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109760:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109763:	0f b6 00             	movzbl (%eax),%eax
80109766:	83 e0 0f             	and    $0xf,%eax
80109769:	01 c0                	add    %eax,%eax
8010976b:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
8010976e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109775:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010977c:	eb 48                	jmp    801097c6 <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010977e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109781:	01 c0                	add    %eax,%eax
80109783:	89 c2                	mov    %eax,%edx
80109785:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109788:	01 d0                	add    %edx,%eax
8010978a:	0f b6 00             	movzbl (%eax),%eax
8010978d:	0f b6 c0             	movzbl %al,%eax
80109790:	c1 e0 08             	shl    $0x8,%eax
80109793:	89 c2                	mov    %eax,%edx
80109795:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109798:	01 c0                	add    %eax,%eax
8010979a:	8d 48 01             	lea    0x1(%eax),%ecx
8010979d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097a0:	01 c8                	add    %ecx,%eax
801097a2:	0f b6 00             	movzbl (%eax),%eax
801097a5:	0f b6 c0             	movzbl %al,%eax
801097a8:	01 d0                	add    %edx,%eax
801097aa:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
801097ad:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
801097b4:	76 0c                	jbe    801097c2 <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
801097b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801097b9:	0f b7 c0             	movzwl %ax,%eax
801097bc:	83 c0 01             	add    $0x1,%eax
801097bf:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
801097c2:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801097c6:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
801097ca:	39 45 f8             	cmp    %eax,-0x8(%ebp)
801097cd:	7c af                	jl     8010977e <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
801097cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
801097d2:	f7 d0                	not    %eax
}
801097d4:	c9                   	leave  
801097d5:	c3                   	ret    

801097d6 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
801097d6:	55                   	push   %ebp
801097d7:	89 e5                	mov    %esp,%ebp
801097d9:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
801097dc:	8b 45 08             	mov    0x8(%ebp),%eax
801097df:	83 c0 0e             	add    $0xe,%eax
801097e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
801097e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097e8:	0f b6 00             	movzbl (%eax),%eax
801097eb:	0f b6 c0             	movzbl %al,%eax
801097ee:	83 e0 0f             	and    $0xf,%eax
801097f1:	c1 e0 02             	shl    $0x2,%eax
801097f4:	89 c2                	mov    %eax,%edx
801097f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097f9:	01 d0                	add    %edx,%eax
801097fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
801097fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109801:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109805:	84 c0                	test   %al,%al
80109807:	75 4f                	jne    80109858 <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109809:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010980c:	0f b6 00             	movzbl (%eax),%eax
8010980f:	3c 08                	cmp    $0x8,%al
80109811:	75 45                	jne    80109858 <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
80109813:	e8 88 8f ff ff       	call   801027a0 <kalloc>
80109818:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
8010981b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109822:	83 ec 04             	sub    $0x4,%esp
80109825:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109828:	50                   	push   %eax
80109829:	ff 75 ec             	push   -0x14(%ebp)
8010982c:	ff 75 08             	push   0x8(%ebp)
8010982f:	e8 78 00 00 00       	call   801098ac <icmp_reply_pkt_create>
80109834:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109837:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010983a:	83 ec 08             	sub    $0x8,%esp
8010983d:	50                   	push   %eax
8010983e:	ff 75 ec             	push   -0x14(%ebp)
80109841:	e8 95 f4 ff ff       	call   80108cdb <i8254_send>
80109846:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109849:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010984c:	83 ec 0c             	sub    $0xc,%esp
8010984f:	50                   	push   %eax
80109850:	e8 b1 8e ff ff       	call   80102706 <kfree>
80109855:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109858:	90                   	nop
80109859:	c9                   	leave  
8010985a:	c3                   	ret    

8010985b <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
8010985b:	55                   	push   %ebp
8010985c:	89 e5                	mov    %esp,%ebp
8010985e:	53                   	push   %ebx
8010985f:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109862:	8b 45 08             	mov    0x8(%ebp),%eax
80109865:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109869:	0f b7 c0             	movzwl %ax,%eax
8010986c:	83 ec 0c             	sub    $0xc,%esp
8010986f:	50                   	push   %eax
80109870:	e8 bd fd ff ff       	call   80109632 <N2H_ushort>
80109875:	83 c4 10             	add    $0x10,%esp
80109878:	0f b7 d8             	movzwl %ax,%ebx
8010987b:	8b 45 08             	mov    0x8(%ebp),%eax
8010987e:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109882:	0f b7 c0             	movzwl %ax,%eax
80109885:	83 ec 0c             	sub    $0xc,%esp
80109888:	50                   	push   %eax
80109889:	e8 a4 fd ff ff       	call   80109632 <N2H_ushort>
8010988e:	83 c4 10             	add    $0x10,%esp
80109891:	0f b7 c0             	movzwl %ax,%eax
80109894:	83 ec 04             	sub    $0x4,%esp
80109897:	53                   	push   %ebx
80109898:	50                   	push   %eax
80109899:	68 83 c1 10 80       	push   $0x8010c183
8010989e:	e8 51 6b ff ff       	call   801003f4 <cprintf>
801098a3:	83 c4 10             	add    $0x10,%esp
}
801098a6:	90                   	nop
801098a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801098aa:	c9                   	leave  
801098ab:	c3                   	ret    

801098ac <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
801098ac:	55                   	push   %ebp
801098ad:	89 e5                	mov    %esp,%ebp
801098af:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
801098b2:	8b 45 08             	mov    0x8(%ebp),%eax
801098b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
801098b8:	8b 45 08             	mov    0x8(%ebp),%eax
801098bb:	83 c0 0e             	add    $0xe,%eax
801098be:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
801098c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098c4:	0f b6 00             	movzbl (%eax),%eax
801098c7:	0f b6 c0             	movzbl %al,%eax
801098ca:	83 e0 0f             	and    $0xf,%eax
801098cd:	c1 e0 02             	shl    $0x2,%eax
801098d0:	89 c2                	mov    %eax,%edx
801098d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098d5:	01 d0                	add    %edx,%eax
801098d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
801098da:	8b 45 0c             	mov    0xc(%ebp),%eax
801098dd:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
801098e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801098e3:	83 c0 0e             	add    $0xe,%eax
801098e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
801098e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801098ec:	83 c0 14             	add    $0x14,%eax
801098ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
801098f2:	8b 45 10             	mov    0x10(%ebp),%eax
801098f5:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
801098fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098fe:	8d 50 06             	lea    0x6(%eax),%edx
80109901:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109904:	83 ec 04             	sub    $0x4,%esp
80109907:	6a 06                	push   $0x6
80109909:	52                   	push   %edx
8010990a:	50                   	push   %eax
8010990b:	e8 74 b3 ff ff       	call   80104c84 <memmove>
80109910:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109913:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109916:	83 c0 06             	add    $0x6,%eax
80109919:	83 ec 04             	sub    $0x4,%esp
8010991c:	6a 06                	push   $0x6
8010991e:	68 80 6d 19 80       	push   $0x80196d80
80109923:	50                   	push   %eax
80109924:	e8 5b b3 ff ff       	call   80104c84 <memmove>
80109929:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010992c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010992f:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109933:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109936:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010993a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010993d:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109940:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109943:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109947:	83 ec 0c             	sub    $0xc,%esp
8010994a:	6a 54                	push   $0x54
8010994c:	e8 03 fd ff ff       	call   80109654 <H2N_ushort>
80109951:	83 c4 10             	add    $0x10,%esp
80109954:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109957:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010995b:	0f b7 15 60 70 19 80 	movzwl 0x80197060,%edx
80109962:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109965:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109969:	0f b7 05 60 70 19 80 	movzwl 0x80197060,%eax
80109970:	83 c0 01             	add    $0x1,%eax
80109973:	66 a3 60 70 19 80    	mov    %ax,0x80197060
  ipv4_send->fragment = H2N_ushort(0x4000);
80109979:	83 ec 0c             	sub    $0xc,%esp
8010997c:	68 00 40 00 00       	push   $0x4000
80109981:	e8 ce fc ff ff       	call   80109654 <H2N_ushort>
80109986:	83 c4 10             	add    $0x10,%esp
80109989:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010998c:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109990:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109993:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109997:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010999a:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010999e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801099a1:	83 c0 0c             	add    $0xc,%eax
801099a4:	83 ec 04             	sub    $0x4,%esp
801099a7:	6a 04                	push   $0x4
801099a9:	68 e4 f4 10 80       	push   $0x8010f4e4
801099ae:	50                   	push   %eax
801099af:	e8 d0 b2 ff ff       	call   80104c84 <memmove>
801099b4:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
801099b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099ba:	8d 50 0c             	lea    0xc(%eax),%edx
801099bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801099c0:	83 c0 10             	add    $0x10,%eax
801099c3:	83 ec 04             	sub    $0x4,%esp
801099c6:	6a 04                	push   $0x4
801099c8:	52                   	push   %edx
801099c9:	50                   	push   %eax
801099ca:	e8 b5 b2 ff ff       	call   80104c84 <memmove>
801099cf:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
801099d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801099d5:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
801099db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801099de:	83 ec 0c             	sub    $0xc,%esp
801099e1:	50                   	push   %eax
801099e2:	e8 6d fd ff ff       	call   80109754 <ipv4_chksum>
801099e7:	83 c4 10             	add    $0x10,%esp
801099ea:	0f b7 c0             	movzwl %ax,%eax
801099ed:	83 ec 0c             	sub    $0xc,%esp
801099f0:	50                   	push   %eax
801099f1:	e8 5e fc ff ff       	call   80109654 <H2N_ushort>
801099f6:	83 c4 10             	add    $0x10,%esp
801099f9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801099fc:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109a00:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a03:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109a06:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a09:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109a0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109a10:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109a14:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a17:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109a1b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109a1e:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109a22:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a25:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109a29:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109a2c:	8d 50 08             	lea    0x8(%eax),%edx
80109a2f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a32:	83 c0 08             	add    $0x8,%eax
80109a35:	83 ec 04             	sub    $0x4,%esp
80109a38:	6a 08                	push   $0x8
80109a3a:	52                   	push   %edx
80109a3b:	50                   	push   %eax
80109a3c:	e8 43 b2 ff ff       	call   80104c84 <memmove>
80109a41:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109a44:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109a47:	8d 50 10             	lea    0x10(%eax),%edx
80109a4a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a4d:	83 c0 10             	add    $0x10,%eax
80109a50:	83 ec 04             	sub    $0x4,%esp
80109a53:	6a 30                	push   $0x30
80109a55:	52                   	push   %edx
80109a56:	50                   	push   %eax
80109a57:	e8 28 b2 ff ff       	call   80104c84 <memmove>
80109a5c:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109a5f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a62:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109a68:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109a6b:	83 ec 0c             	sub    $0xc,%esp
80109a6e:	50                   	push   %eax
80109a6f:	e8 1c 00 00 00       	call   80109a90 <icmp_chksum>
80109a74:	83 c4 10             	add    $0x10,%esp
80109a77:	0f b7 c0             	movzwl %ax,%eax
80109a7a:	83 ec 0c             	sub    $0xc,%esp
80109a7d:	50                   	push   %eax
80109a7e:	e8 d1 fb ff ff       	call   80109654 <H2N_ushort>
80109a83:	83 c4 10             	add    $0x10,%esp
80109a86:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109a89:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109a8d:	90                   	nop
80109a8e:	c9                   	leave  
80109a8f:	c3                   	ret    

80109a90 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109a90:	55                   	push   %ebp
80109a91:	89 e5                	mov    %esp,%ebp
80109a93:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109a96:	8b 45 08             	mov    0x8(%ebp),%eax
80109a99:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109a9c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109aa3:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109aaa:	eb 48                	jmp    80109af4 <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109aac:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109aaf:	01 c0                	add    %eax,%eax
80109ab1:	89 c2                	mov    %eax,%edx
80109ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ab6:	01 d0                	add    %edx,%eax
80109ab8:	0f b6 00             	movzbl (%eax),%eax
80109abb:	0f b6 c0             	movzbl %al,%eax
80109abe:	c1 e0 08             	shl    $0x8,%eax
80109ac1:	89 c2                	mov    %eax,%edx
80109ac3:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109ac6:	01 c0                	add    %eax,%eax
80109ac8:	8d 48 01             	lea    0x1(%eax),%ecx
80109acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ace:	01 c8                	add    %ecx,%eax
80109ad0:	0f b6 00             	movzbl (%eax),%eax
80109ad3:	0f b6 c0             	movzbl %al,%eax
80109ad6:	01 d0                	add    %edx,%eax
80109ad8:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109adb:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109ae2:	76 0c                	jbe    80109af0 <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
80109ae4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109ae7:	0f b7 c0             	movzwl %ax,%eax
80109aea:	83 c0 01             	add    $0x1,%eax
80109aed:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109af0:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109af4:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109af8:	7e b2                	jle    80109aac <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
80109afa:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109afd:	f7 d0                	not    %eax
}
80109aff:	c9                   	leave  
80109b00:	c3                   	ret    

80109b01 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109b01:	55                   	push   %ebp
80109b02:	89 e5                	mov    %esp,%ebp
80109b04:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109b07:	8b 45 08             	mov    0x8(%ebp),%eax
80109b0a:	83 c0 0e             	add    $0xe,%eax
80109b0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b13:	0f b6 00             	movzbl (%eax),%eax
80109b16:	0f b6 c0             	movzbl %al,%eax
80109b19:	83 e0 0f             	and    $0xf,%eax
80109b1c:	c1 e0 02             	shl    $0x2,%eax
80109b1f:	89 c2                	mov    %eax,%edx
80109b21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b24:	01 d0                	add    %edx,%eax
80109b26:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109b29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b2c:	83 c0 14             	add    $0x14,%eax
80109b2f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109b32:	e8 69 8c ff ff       	call   801027a0 <kalloc>
80109b37:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109b3a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109b41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b44:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109b48:	0f b6 c0             	movzbl %al,%eax
80109b4b:	83 e0 02             	and    $0x2,%eax
80109b4e:	85 c0                	test   %eax,%eax
80109b50:	74 3d                	je     80109b8f <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109b52:	83 ec 0c             	sub    $0xc,%esp
80109b55:	6a 00                	push   $0x0
80109b57:	6a 12                	push   $0x12
80109b59:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109b5c:	50                   	push   %eax
80109b5d:	ff 75 e8             	push   -0x18(%ebp)
80109b60:	ff 75 08             	push   0x8(%ebp)
80109b63:	e8 a2 01 00 00       	call   80109d0a <tcp_pkt_create>
80109b68:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109b6b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109b6e:	83 ec 08             	sub    $0x8,%esp
80109b71:	50                   	push   %eax
80109b72:	ff 75 e8             	push   -0x18(%ebp)
80109b75:	e8 61 f1 ff ff       	call   80108cdb <i8254_send>
80109b7a:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109b7d:	a1 64 70 19 80       	mov    0x80197064,%eax
80109b82:	83 c0 01             	add    $0x1,%eax
80109b85:	a3 64 70 19 80       	mov    %eax,0x80197064
80109b8a:	e9 69 01 00 00       	jmp    80109cf8 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109b8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b92:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109b96:	3c 18                	cmp    $0x18,%al
80109b98:	0f 85 10 01 00 00    	jne    80109cae <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
80109b9e:	83 ec 04             	sub    $0x4,%esp
80109ba1:	6a 03                	push   $0x3
80109ba3:	68 9e c1 10 80       	push   $0x8010c19e
80109ba8:	ff 75 ec             	push   -0x14(%ebp)
80109bab:	e8 7c b0 ff ff       	call   80104c2c <memcmp>
80109bb0:	83 c4 10             	add    $0x10,%esp
80109bb3:	85 c0                	test   %eax,%eax
80109bb5:	74 74                	je     80109c2b <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
80109bb7:	83 ec 0c             	sub    $0xc,%esp
80109bba:	68 a2 c1 10 80       	push   $0x8010c1a2
80109bbf:	e8 30 68 ff ff       	call   801003f4 <cprintf>
80109bc4:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109bc7:	83 ec 0c             	sub    $0xc,%esp
80109bca:	6a 00                	push   $0x0
80109bcc:	6a 10                	push   $0x10
80109bce:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109bd1:	50                   	push   %eax
80109bd2:	ff 75 e8             	push   -0x18(%ebp)
80109bd5:	ff 75 08             	push   0x8(%ebp)
80109bd8:	e8 2d 01 00 00       	call   80109d0a <tcp_pkt_create>
80109bdd:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109be0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109be3:	83 ec 08             	sub    $0x8,%esp
80109be6:	50                   	push   %eax
80109be7:	ff 75 e8             	push   -0x18(%ebp)
80109bea:	e8 ec f0 ff ff       	call   80108cdb <i8254_send>
80109bef:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109bf2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109bf5:	83 c0 36             	add    $0x36,%eax
80109bf8:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109bfb:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109bfe:	50                   	push   %eax
80109bff:	ff 75 e0             	push   -0x20(%ebp)
80109c02:	6a 00                	push   $0x0
80109c04:	6a 00                	push   $0x0
80109c06:	e8 5a 04 00 00       	call   8010a065 <http_proc>
80109c0b:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109c0e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109c11:	83 ec 0c             	sub    $0xc,%esp
80109c14:	50                   	push   %eax
80109c15:	6a 18                	push   $0x18
80109c17:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109c1a:	50                   	push   %eax
80109c1b:	ff 75 e8             	push   -0x18(%ebp)
80109c1e:	ff 75 08             	push   0x8(%ebp)
80109c21:	e8 e4 00 00 00       	call   80109d0a <tcp_pkt_create>
80109c26:	83 c4 20             	add    $0x20,%esp
80109c29:	eb 62                	jmp    80109c8d <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109c2b:	83 ec 0c             	sub    $0xc,%esp
80109c2e:	6a 00                	push   $0x0
80109c30:	6a 10                	push   $0x10
80109c32:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109c35:	50                   	push   %eax
80109c36:	ff 75 e8             	push   -0x18(%ebp)
80109c39:	ff 75 08             	push   0x8(%ebp)
80109c3c:	e8 c9 00 00 00       	call   80109d0a <tcp_pkt_create>
80109c41:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
80109c44:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109c47:	83 ec 08             	sub    $0x8,%esp
80109c4a:	50                   	push   %eax
80109c4b:	ff 75 e8             	push   -0x18(%ebp)
80109c4e:	e8 88 f0 ff ff       	call   80108cdb <i8254_send>
80109c53:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109c56:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c59:	83 c0 36             	add    $0x36,%eax
80109c5c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109c5f:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109c62:	50                   	push   %eax
80109c63:	ff 75 e4             	push   -0x1c(%ebp)
80109c66:	6a 00                	push   $0x0
80109c68:	6a 00                	push   $0x0
80109c6a:	e8 f6 03 00 00       	call   8010a065 <http_proc>
80109c6f:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109c72:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109c75:	83 ec 0c             	sub    $0xc,%esp
80109c78:	50                   	push   %eax
80109c79:	6a 18                	push   $0x18
80109c7b:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109c7e:	50                   	push   %eax
80109c7f:	ff 75 e8             	push   -0x18(%ebp)
80109c82:	ff 75 08             	push   0x8(%ebp)
80109c85:	e8 80 00 00 00       	call   80109d0a <tcp_pkt_create>
80109c8a:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
80109c8d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109c90:	83 ec 08             	sub    $0x8,%esp
80109c93:	50                   	push   %eax
80109c94:	ff 75 e8             	push   -0x18(%ebp)
80109c97:	e8 3f f0 ff ff       	call   80108cdb <i8254_send>
80109c9c:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109c9f:	a1 64 70 19 80       	mov    0x80197064,%eax
80109ca4:	83 c0 01             	add    $0x1,%eax
80109ca7:	a3 64 70 19 80       	mov    %eax,0x80197064
80109cac:	eb 4a                	jmp    80109cf8 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
80109cae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cb1:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109cb5:	3c 10                	cmp    $0x10,%al
80109cb7:	75 3f                	jne    80109cf8 <tcp_proc+0x1f7>
    if(fin_flag == 1){
80109cb9:	a1 68 70 19 80       	mov    0x80197068,%eax
80109cbe:	83 f8 01             	cmp    $0x1,%eax
80109cc1:	75 35                	jne    80109cf8 <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
80109cc3:	83 ec 0c             	sub    $0xc,%esp
80109cc6:	6a 00                	push   $0x0
80109cc8:	6a 01                	push   $0x1
80109cca:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109ccd:	50                   	push   %eax
80109cce:	ff 75 e8             	push   -0x18(%ebp)
80109cd1:	ff 75 08             	push   0x8(%ebp)
80109cd4:	e8 31 00 00 00       	call   80109d0a <tcp_pkt_create>
80109cd9:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109cdc:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109cdf:	83 ec 08             	sub    $0x8,%esp
80109ce2:	50                   	push   %eax
80109ce3:	ff 75 e8             	push   -0x18(%ebp)
80109ce6:	e8 f0 ef ff ff       	call   80108cdb <i8254_send>
80109ceb:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
80109cee:	c7 05 68 70 19 80 00 	movl   $0x0,0x80197068
80109cf5:	00 00 00 
    }
  }
  kfree((char *)send_addr);
80109cf8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109cfb:	83 ec 0c             	sub    $0xc,%esp
80109cfe:	50                   	push   %eax
80109cff:	e8 02 8a ff ff       	call   80102706 <kfree>
80109d04:	83 c4 10             	add    $0x10,%esp
}
80109d07:	90                   	nop
80109d08:	c9                   	leave  
80109d09:	c3                   	ret    

80109d0a <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
80109d0a:	55                   	push   %ebp
80109d0b:	89 e5                	mov    %esp,%ebp
80109d0d:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109d10:	8b 45 08             	mov    0x8(%ebp),%eax
80109d13:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109d16:	8b 45 08             	mov    0x8(%ebp),%eax
80109d19:	83 c0 0e             	add    $0xe,%eax
80109d1c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
80109d1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d22:	0f b6 00             	movzbl (%eax),%eax
80109d25:	0f b6 c0             	movzbl %al,%eax
80109d28:	83 e0 0f             	and    $0xf,%eax
80109d2b:	c1 e0 02             	shl    $0x2,%eax
80109d2e:	89 c2                	mov    %eax,%edx
80109d30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d33:	01 d0                	add    %edx,%eax
80109d35:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109d38:	8b 45 0c             	mov    0xc(%ebp),%eax
80109d3b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
80109d3e:	8b 45 0c             	mov    0xc(%ebp),%eax
80109d41:	83 c0 0e             	add    $0xe,%eax
80109d44:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
80109d47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d4a:	83 c0 14             	add    $0x14,%eax
80109d4d:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
80109d50:	8b 45 18             	mov    0x18(%ebp),%eax
80109d53:	8d 50 36             	lea    0x36(%eax),%edx
80109d56:	8b 45 10             	mov    0x10(%ebp),%eax
80109d59:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109d5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d5e:	8d 50 06             	lea    0x6(%eax),%edx
80109d61:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d64:	83 ec 04             	sub    $0x4,%esp
80109d67:	6a 06                	push   $0x6
80109d69:	52                   	push   %edx
80109d6a:	50                   	push   %eax
80109d6b:	e8 14 af ff ff       	call   80104c84 <memmove>
80109d70:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109d73:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d76:	83 c0 06             	add    $0x6,%eax
80109d79:	83 ec 04             	sub    $0x4,%esp
80109d7c:	6a 06                	push   $0x6
80109d7e:	68 80 6d 19 80       	push   $0x80196d80
80109d83:	50                   	push   %eax
80109d84:	e8 fb ae ff ff       	call   80104c84 <memmove>
80109d89:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109d8c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d8f:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109d93:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d96:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109d9a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d9d:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109da0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109da3:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
80109da7:	8b 45 18             	mov    0x18(%ebp),%eax
80109daa:	83 c0 28             	add    $0x28,%eax
80109dad:	0f b7 c0             	movzwl %ax,%eax
80109db0:	83 ec 0c             	sub    $0xc,%esp
80109db3:	50                   	push   %eax
80109db4:	e8 9b f8 ff ff       	call   80109654 <H2N_ushort>
80109db9:	83 c4 10             	add    $0x10,%esp
80109dbc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109dbf:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109dc3:	0f b7 15 60 70 19 80 	movzwl 0x80197060,%edx
80109dca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109dcd:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109dd1:	0f b7 05 60 70 19 80 	movzwl 0x80197060,%eax
80109dd8:	83 c0 01             	add    $0x1,%eax
80109ddb:	66 a3 60 70 19 80    	mov    %ax,0x80197060
  ipv4_send->fragment = H2N_ushort(0x0000);
80109de1:	83 ec 0c             	sub    $0xc,%esp
80109de4:	6a 00                	push   $0x0
80109de6:	e8 69 f8 ff ff       	call   80109654 <H2N_ushort>
80109deb:	83 c4 10             	add    $0x10,%esp
80109dee:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109df1:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109df5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109df8:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
80109dfc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109dff:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109e03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e06:	83 c0 0c             	add    $0xc,%eax
80109e09:	83 ec 04             	sub    $0x4,%esp
80109e0c:	6a 04                	push   $0x4
80109e0e:	68 e4 f4 10 80       	push   $0x8010f4e4
80109e13:	50                   	push   %eax
80109e14:	e8 6b ae ff ff       	call   80104c84 <memmove>
80109e19:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109e1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e1f:	8d 50 0c             	lea    0xc(%eax),%edx
80109e22:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e25:	83 c0 10             	add    $0x10,%eax
80109e28:	83 ec 04             	sub    $0x4,%esp
80109e2b:	6a 04                	push   $0x4
80109e2d:	52                   	push   %edx
80109e2e:	50                   	push   %eax
80109e2f:	e8 50 ae ff ff       	call   80104c84 <memmove>
80109e34:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109e37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e3a:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109e40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e43:	83 ec 0c             	sub    $0xc,%esp
80109e46:	50                   	push   %eax
80109e47:	e8 08 f9 ff ff       	call   80109754 <ipv4_chksum>
80109e4c:	83 c4 10             	add    $0x10,%esp
80109e4f:	0f b7 c0             	movzwl %ax,%eax
80109e52:	83 ec 0c             	sub    $0xc,%esp
80109e55:	50                   	push   %eax
80109e56:	e8 f9 f7 ff ff       	call   80109654 <H2N_ushort>
80109e5b:	83 c4 10             	add    $0x10,%esp
80109e5e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109e61:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
80109e65:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109e68:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80109e6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e6f:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
80109e72:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109e75:	0f b7 10             	movzwl (%eax),%edx
80109e78:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e7b:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
80109e7f:	a1 64 70 19 80       	mov    0x80197064,%eax
80109e84:	83 ec 0c             	sub    $0xc,%esp
80109e87:	50                   	push   %eax
80109e88:	e8 e9 f7 ff ff       	call   80109676 <H2N_uint>
80109e8d:	83 c4 10             	add    $0x10,%esp
80109e90:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109e93:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
80109e96:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109e99:	8b 40 04             	mov    0x4(%eax),%eax
80109e9c:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
80109ea2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ea5:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
80109ea8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109eab:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
80109eaf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109eb2:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
80109eb6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109eb9:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
80109ebd:	8b 45 14             	mov    0x14(%ebp),%eax
80109ec0:	89 c2                	mov    %eax,%edx
80109ec2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ec5:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
80109ec8:	83 ec 0c             	sub    $0xc,%esp
80109ecb:	68 90 38 00 00       	push   $0x3890
80109ed0:	e8 7f f7 ff ff       	call   80109654 <H2N_ushort>
80109ed5:	83 c4 10             	add    $0x10,%esp
80109ed8:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109edb:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
80109edf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ee2:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
80109ee8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109eeb:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
80109ef1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ef4:	83 ec 0c             	sub    $0xc,%esp
80109ef7:	50                   	push   %eax
80109ef8:	e8 1f 00 00 00       	call   80109f1c <tcp_chksum>
80109efd:	83 c4 10             	add    $0x10,%esp
80109f00:	83 c0 08             	add    $0x8,%eax
80109f03:	0f b7 c0             	movzwl %ax,%eax
80109f06:	83 ec 0c             	sub    $0xc,%esp
80109f09:	50                   	push   %eax
80109f0a:	e8 45 f7 ff ff       	call   80109654 <H2N_ushort>
80109f0f:	83 c4 10             	add    $0x10,%esp
80109f12:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109f15:	66 89 42 10          	mov    %ax,0x10(%edx)


}
80109f19:	90                   	nop
80109f1a:	c9                   	leave  
80109f1b:	c3                   	ret    

80109f1c <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
80109f1c:	55                   	push   %ebp
80109f1d:	89 e5                	mov    %esp,%ebp
80109f1f:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
80109f22:	8b 45 08             	mov    0x8(%ebp),%eax
80109f25:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
80109f28:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f2b:	83 c0 14             	add    $0x14,%eax
80109f2e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
80109f31:	83 ec 04             	sub    $0x4,%esp
80109f34:	6a 04                	push   $0x4
80109f36:	68 e4 f4 10 80       	push   $0x8010f4e4
80109f3b:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109f3e:	50                   	push   %eax
80109f3f:	e8 40 ad ff ff       	call   80104c84 <memmove>
80109f44:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
80109f47:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f4a:	83 c0 0c             	add    $0xc,%eax
80109f4d:	83 ec 04             	sub    $0x4,%esp
80109f50:	6a 04                	push   $0x4
80109f52:	50                   	push   %eax
80109f53:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109f56:	83 c0 04             	add    $0x4,%eax
80109f59:	50                   	push   %eax
80109f5a:	e8 25 ad ff ff       	call   80104c84 <memmove>
80109f5f:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
80109f62:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
80109f66:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
80109f6a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f6d:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80109f71:	0f b7 c0             	movzwl %ax,%eax
80109f74:	83 ec 0c             	sub    $0xc,%esp
80109f77:	50                   	push   %eax
80109f78:	e8 b5 f6 ff ff       	call   80109632 <N2H_ushort>
80109f7d:	83 c4 10             	add    $0x10,%esp
80109f80:	83 e8 14             	sub    $0x14,%eax
80109f83:	0f b7 c0             	movzwl %ax,%eax
80109f86:	83 ec 0c             	sub    $0xc,%esp
80109f89:	50                   	push   %eax
80109f8a:	e8 c5 f6 ff ff       	call   80109654 <H2N_ushort>
80109f8f:	83 c4 10             	add    $0x10,%esp
80109f92:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
80109f96:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
80109f9d:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109fa0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
80109fa3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109faa:	eb 33                	jmp    80109fdf <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109fac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109faf:	01 c0                	add    %eax,%eax
80109fb1:	89 c2                	mov    %eax,%edx
80109fb3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109fb6:	01 d0                	add    %edx,%eax
80109fb8:	0f b6 00             	movzbl (%eax),%eax
80109fbb:	0f b6 c0             	movzbl %al,%eax
80109fbe:	c1 e0 08             	shl    $0x8,%eax
80109fc1:	89 c2                	mov    %eax,%edx
80109fc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fc6:	01 c0                	add    %eax,%eax
80109fc8:	8d 48 01             	lea    0x1(%eax),%ecx
80109fcb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109fce:	01 c8                	add    %ecx,%eax
80109fd0:	0f b6 00             	movzbl (%eax),%eax
80109fd3:	0f b6 c0             	movzbl %al,%eax
80109fd6:	01 d0                	add    %edx,%eax
80109fd8:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
80109fdb:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109fdf:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
80109fe3:	7e c7                	jle    80109fac <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
80109fe5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109fe8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
80109feb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80109ff2:	eb 33                	jmp    8010a027 <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109ff4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ff7:	01 c0                	add    %eax,%eax
80109ff9:	89 c2                	mov    %eax,%edx
80109ffb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ffe:	01 d0                	add    %edx,%eax
8010a000:	0f b6 00             	movzbl (%eax),%eax
8010a003:	0f b6 c0             	movzbl %al,%eax
8010a006:	c1 e0 08             	shl    $0x8,%eax
8010a009:	89 c2                	mov    %eax,%edx
8010a00b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a00e:	01 c0                	add    %eax,%eax
8010a010:	8d 48 01             	lea    0x1(%eax),%ecx
8010a013:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a016:	01 c8                	add    %ecx,%eax
8010a018:	0f b6 00             	movzbl (%eax),%eax
8010a01b:	0f b6 c0             	movzbl %al,%eax
8010a01e:	01 d0                	add    %edx,%eax
8010a020:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a023:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a027:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a02b:	0f b7 c0             	movzwl %ax,%eax
8010a02e:	83 ec 0c             	sub    $0xc,%esp
8010a031:	50                   	push   %eax
8010a032:	e8 fb f5 ff ff       	call   80109632 <N2H_ushort>
8010a037:	83 c4 10             	add    $0x10,%esp
8010a03a:	66 d1 e8             	shr    %ax
8010a03d:	0f b7 c0             	movzwl %ax,%eax
8010a040:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a043:	7c af                	jl     80109ff4 <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
8010a045:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a048:	c1 e8 10             	shr    $0x10,%eax
8010a04b:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a04e:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a051:	f7 d0                	not    %eax
}
8010a053:	c9                   	leave  
8010a054:	c3                   	ret    

8010a055 <tcp_fin>:

void tcp_fin(){
8010a055:	55                   	push   %ebp
8010a056:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a058:	c7 05 68 70 19 80 01 	movl   $0x1,0x80197068
8010a05f:	00 00 00 
}
8010a062:	90                   	nop
8010a063:	5d                   	pop    %ebp
8010a064:	c3                   	ret    

8010a065 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a065:	55                   	push   %ebp
8010a066:	89 e5                	mov    %esp,%ebp
8010a068:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a06b:	8b 45 10             	mov    0x10(%ebp),%eax
8010a06e:	83 ec 04             	sub    $0x4,%esp
8010a071:	6a 00                	push   $0x0
8010a073:	68 ab c1 10 80       	push   $0x8010c1ab
8010a078:	50                   	push   %eax
8010a079:	e8 65 00 00 00       	call   8010a0e3 <http_strcpy>
8010a07e:	83 c4 10             	add    $0x10,%esp
8010a081:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a084:	8b 45 10             	mov    0x10(%ebp),%eax
8010a087:	83 ec 04             	sub    $0x4,%esp
8010a08a:	ff 75 f4             	push   -0xc(%ebp)
8010a08d:	68 be c1 10 80       	push   $0x8010c1be
8010a092:	50                   	push   %eax
8010a093:	e8 4b 00 00 00       	call   8010a0e3 <http_strcpy>
8010a098:	83 c4 10             	add    $0x10,%esp
8010a09b:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a09e:	8b 45 10             	mov    0x10(%ebp),%eax
8010a0a1:	83 ec 04             	sub    $0x4,%esp
8010a0a4:	ff 75 f4             	push   -0xc(%ebp)
8010a0a7:	68 d9 c1 10 80       	push   $0x8010c1d9
8010a0ac:	50                   	push   %eax
8010a0ad:	e8 31 00 00 00       	call   8010a0e3 <http_strcpy>
8010a0b2:	83 c4 10             	add    $0x10,%esp
8010a0b5:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a0b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0bb:	83 e0 01             	and    $0x1,%eax
8010a0be:	85 c0                	test   %eax,%eax
8010a0c0:	74 11                	je     8010a0d3 <http_proc+0x6e>
    char *payload = (char *)send;
8010a0c2:	8b 45 10             	mov    0x10(%ebp),%eax
8010a0c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a0c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a0cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0ce:	01 d0                	add    %edx,%eax
8010a0d0:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a0d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a0d6:	8b 45 14             	mov    0x14(%ebp),%eax
8010a0d9:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a0db:	e8 75 ff ff ff       	call   8010a055 <tcp_fin>
}
8010a0e0:	90                   	nop
8010a0e1:	c9                   	leave  
8010a0e2:	c3                   	ret    

8010a0e3 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a0e3:	55                   	push   %ebp
8010a0e4:	89 e5                	mov    %esp,%ebp
8010a0e6:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a0e9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a0f0:	eb 20                	jmp    8010a112 <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010a0f2:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a0f5:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a0f8:	01 d0                	add    %edx,%eax
8010a0fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a0fd:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a100:	01 ca                	add    %ecx,%edx
8010a102:	89 d1                	mov    %edx,%ecx
8010a104:	8b 55 08             	mov    0x8(%ebp),%edx
8010a107:	01 ca                	add    %ecx,%edx
8010a109:	0f b6 00             	movzbl (%eax),%eax
8010a10c:	88 02                	mov    %al,(%edx)
    i++;
8010a10e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a112:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a115:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a118:	01 d0                	add    %edx,%eax
8010a11a:	0f b6 00             	movzbl (%eax),%eax
8010a11d:	84 c0                	test   %al,%al
8010a11f:	75 d1                	jne    8010a0f2 <http_strcpy+0xf>
  }
  return i;
8010a121:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a124:	c9                   	leave  
8010a125:	c3                   	ret    

8010a126 <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a126:	55                   	push   %ebp
8010a127:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a129:	c7 05 70 70 19 80 a2 	movl   $0x8010f5a2,0x80197070
8010a130:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a133:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a138:	c1 e8 09             	shr    $0x9,%eax
8010a13b:	a3 6c 70 19 80       	mov    %eax,0x8019706c
}
8010a140:	90                   	nop
8010a141:	5d                   	pop    %ebp
8010a142:	c3                   	ret    

8010a143 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a143:	55                   	push   %ebp
8010a144:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a146:	90                   	nop
8010a147:	5d                   	pop    %ebp
8010a148:	c3                   	ret    

8010a149 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a149:	55                   	push   %ebp
8010a14a:	89 e5                	mov    %esp,%ebp
8010a14c:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a14f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a152:	83 c0 0c             	add    $0xc,%eax
8010a155:	83 ec 0c             	sub    $0xc,%esp
8010a158:	50                   	push   %eax
8010a159:	e8 60 a7 ff ff       	call   801048be <holdingsleep>
8010a15e:	83 c4 10             	add    $0x10,%esp
8010a161:	85 c0                	test   %eax,%eax
8010a163:	75 0d                	jne    8010a172 <iderw+0x29>
    panic("iderw: buf not locked");
8010a165:	83 ec 0c             	sub    $0xc,%esp
8010a168:	68 ea c1 10 80       	push   $0x8010c1ea
8010a16d:	e8 37 64 ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a172:	8b 45 08             	mov    0x8(%ebp),%eax
8010a175:	8b 00                	mov    (%eax),%eax
8010a177:	83 e0 06             	and    $0x6,%eax
8010a17a:	83 f8 02             	cmp    $0x2,%eax
8010a17d:	75 0d                	jne    8010a18c <iderw+0x43>
    panic("iderw: nothing to do");
8010a17f:	83 ec 0c             	sub    $0xc,%esp
8010a182:	68 00 c2 10 80       	push   $0x8010c200
8010a187:	e8 1d 64 ff ff       	call   801005a9 <panic>
  if(b->dev != 1)
8010a18c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a18f:	8b 40 04             	mov    0x4(%eax),%eax
8010a192:	83 f8 01             	cmp    $0x1,%eax
8010a195:	74 0d                	je     8010a1a4 <iderw+0x5b>
    panic("iderw: request not for disk 1");
8010a197:	83 ec 0c             	sub    $0xc,%esp
8010a19a:	68 15 c2 10 80       	push   $0x8010c215
8010a19f:	e8 05 64 ff ff       	call   801005a9 <panic>
  if(b->blockno >= disksize)
8010a1a4:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1a7:	8b 40 08             	mov    0x8(%eax),%eax
8010a1aa:	8b 15 6c 70 19 80    	mov    0x8019706c,%edx
8010a1b0:	39 d0                	cmp    %edx,%eax
8010a1b2:	72 0d                	jb     8010a1c1 <iderw+0x78>
    panic("iderw: block out of range");
8010a1b4:	83 ec 0c             	sub    $0xc,%esp
8010a1b7:	68 33 c2 10 80       	push   $0x8010c233
8010a1bc:	e8 e8 63 ff ff       	call   801005a9 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a1c1:	8b 15 70 70 19 80    	mov    0x80197070,%edx
8010a1c7:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1ca:	8b 40 08             	mov    0x8(%eax),%eax
8010a1cd:	c1 e0 09             	shl    $0x9,%eax
8010a1d0:	01 d0                	add    %edx,%eax
8010a1d2:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a1d5:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1d8:	8b 00                	mov    (%eax),%eax
8010a1da:	83 e0 04             	and    $0x4,%eax
8010a1dd:	85 c0                	test   %eax,%eax
8010a1df:	74 2b                	je     8010a20c <iderw+0xc3>
    b->flags &= ~B_DIRTY;
8010a1e1:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1e4:	8b 00                	mov    (%eax),%eax
8010a1e6:	83 e0 fb             	and    $0xfffffffb,%eax
8010a1e9:	89 c2                	mov    %eax,%edx
8010a1eb:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1ee:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a1f0:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1f3:	83 c0 5c             	add    $0x5c,%eax
8010a1f6:	83 ec 04             	sub    $0x4,%esp
8010a1f9:	68 00 02 00 00       	push   $0x200
8010a1fe:	50                   	push   %eax
8010a1ff:	ff 75 f4             	push   -0xc(%ebp)
8010a202:	e8 7d aa ff ff       	call   80104c84 <memmove>
8010a207:	83 c4 10             	add    $0x10,%esp
8010a20a:	eb 1a                	jmp    8010a226 <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
8010a20c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a20f:	83 c0 5c             	add    $0x5c,%eax
8010a212:	83 ec 04             	sub    $0x4,%esp
8010a215:	68 00 02 00 00       	push   $0x200
8010a21a:	ff 75 f4             	push   -0xc(%ebp)
8010a21d:	50                   	push   %eax
8010a21e:	e8 61 aa ff ff       	call   80104c84 <memmove>
8010a223:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a226:	8b 45 08             	mov    0x8(%ebp),%eax
8010a229:	8b 00                	mov    (%eax),%eax
8010a22b:	83 c8 02             	or     $0x2,%eax
8010a22e:	89 c2                	mov    %eax,%edx
8010a230:	8b 45 08             	mov    0x8(%ebp),%eax
8010a233:	89 10                	mov    %edx,(%eax)
}
8010a235:	90                   	nop
8010a236:	c9                   	leave  
8010a237:	c3                   	ret    
