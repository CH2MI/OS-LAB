
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
8010005f:	ba 60 33 10 80       	mov    $0x80103360,%edx
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
80100079:	e8 96 47 00 00       	call   80104814 <initlock>
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
801000c3:	e8 ef 45 00 00       	call   801046b7 <initsleeplock>
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
80100101:	e8 30 47 00 00       	call   80104836 <acquire>
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
80100140:	e8 5f 47 00 00       	call   801048a4 <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 9c 45 00 00       	call   801046f3 <acquiresleep>
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
801001c1:	e8 de 46 00 00       	call   801048a4 <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 1b 45 00 00       	call   801046f3 <acquiresleep>
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
8010024a:	e8 56 45 00 00       	call   801047a5 <holdingsleep>
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
80100293:	e8 0d 45 00 00       	call   801047a5 <holdingsleep>
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
801002b6:	e8 9c 44 00 00       	call   80104757 <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 d0 18 80       	push   $0x8018d000
801002c6:	e8 6b 45 00 00       	call   80104836 <acquire>
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
80100336:	e8 69 45 00 00       	call   801048a4 <release>
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
80100410:	e8 21 44 00 00       	call   80104836 <acquire>
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
8010059e:	e8 01 43 00 00       	call   801048a4 <release>
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
801005be:	e8 32 25 00 00       	call   80102af5 <lapicid>
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
801005fe:	e8 f3 42 00 00       	call   801048f6 <getcallerpcs>
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
80100793:	e8 5b 5c 00 00       	call   801063f3 <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 4e 5c 00 00       	call   801063f3 <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 41 5c 00 00       	call   801063f3 <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x56>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 31 5c 00 00       	call   801063f3 <uartputc>
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
801007eb:	e8 46 40 00 00       	call   80104836 <acquire>
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
8010093f:	e8 77 3a 00 00       	call   801043bb <wakeup>
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
80100962:	e8 3d 3f 00 00       	call   801048a4 <release>
80100967:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010096a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010096e:	74 05                	je     80100975 <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
80100970:	e8 01 3b 00 00       	call   80104476 <procdump>
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
80100984:	e8 6f 11 00 00       	call   80101af8 <iunlock>
80100989:	83 c4 10             	add    $0x10,%esp
  target = n;
8010098c:	8b 45 10             	mov    0x10(%ebp),%eax
8010098f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100992:	83 ec 0c             	sub    $0xc,%esp
80100995:	68 00 1a 19 80       	push   $0x80191a00
8010099a:	e8 97 3e 00 00       	call   80104836 <acquire>
8010099f:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009a2:	e9 ab 00 00 00       	jmp    80100a52 <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009a7:	e8 7f 30 00 00       	call   80103a2b <myproc>
801009ac:	8b 40 24             	mov    0x24(%eax),%eax
801009af:	85 c0                	test   %eax,%eax
801009b1:	74 28                	je     801009db <consoleread+0x63>
        release(&cons.lock);
801009b3:	83 ec 0c             	sub    $0xc,%esp
801009b6:	68 00 1a 19 80       	push   $0x80191a00
801009bb:	e8 e4 3e 00 00       	call   801048a4 <release>
801009c0:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009c3:	83 ec 0c             	sub    $0xc,%esp
801009c6:	ff 75 08             	push   0x8(%ebp)
801009c9:	e8 17 10 00 00       	call   801019e5 <ilock>
801009ce:	83 c4 10             	add    $0x10,%esp
        return -1;
801009d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009d6:	e9 a9 00 00 00       	jmp    80100a84 <consoleread+0x10c>
      }
      sleep(&input.r, &cons.lock);
801009db:	83 ec 08             	sub    $0x8,%esp
801009de:	68 00 1a 19 80       	push   $0x80191a00
801009e3:	68 e0 19 19 80       	push   $0x801919e0
801009e8:	e8 e7 38 00 00       	call   801042d4 <sleep>
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
80100a66:	e8 39 3e 00 00       	call   801048a4 <release>
80100a6b:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a6e:	83 ec 0c             	sub    $0xc,%esp
80100a71:	ff 75 08             	push   0x8(%ebp)
80100a74:	e8 6c 0f 00 00       	call   801019e5 <ilock>
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
80100a92:	e8 61 10 00 00       	call   80101af8 <iunlock>
80100a97:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100a9a:	83 ec 0c             	sub    $0xc,%esp
80100a9d:	68 00 1a 19 80       	push   $0x80191a00
80100aa2:	e8 8f 3d 00 00       	call   80104836 <acquire>
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
80100ae4:	e8 bb 3d 00 00       	call   801048a4 <release>
80100ae9:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100aec:	83 ec 0c             	sub    $0xc,%esp
80100aef:	ff 75 08             	push   0x8(%ebp)
80100af2:	e8 ee 0e 00 00       	call   801019e5 <ilock>
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
80100b1c:	e8 f3 3c 00 00       	call   80104814 <initlock>
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
80100b75:	e8 af 1a 00 00       	call   80102629 <ioapicenable>
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
80100b89:	e8 9d 2e 00 00       	call   80103a2b <myproc>
80100b8e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100b91:	e8 a1 24 00 00       	call   80103037 <begin_op>

  if((ip = namei(path)) == 0){
80100b96:	83 ec 0c             	sub    $0xc,%esp
80100b99:	ff 75 08             	push   0x8(%ebp)
80100b9c:	e8 77 19 00 00       	call   80102518 <namei>
80100ba1:	83 c4 10             	add    $0x10,%esp
80100ba4:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100ba7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bab:	75 1f                	jne    80100bcc <exec+0x4c>
    end_op();
80100bad:	e8 11 25 00 00       	call   801030c3 <end_op>
    cprintf("exec: fail\n");
80100bb2:	83 ec 0c             	sub    $0xc,%esp
80100bb5:	68 95 a1 10 80       	push   $0x8010a195
80100bba:	e8 35 f8 ff ff       	call   801003f4 <cprintf>
80100bbf:	83 c4 10             	add    $0x10,%esp
    return -1;
80100bc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bc7:	e9 ec 03 00 00       	jmp    80100fb8 <exec+0x438>
  }
  ilock(ip);
80100bcc:	83 ec 0c             	sub    $0xc,%esp
80100bcf:	ff 75 d8             	push   -0x28(%ebp)
80100bd2:	e8 0e 0e 00 00       	call   801019e5 <ilock>
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
80100bef:	e8 dd 12 00 00       	call   80101ed1 <readi>
80100bf4:	83 c4 10             	add    $0x10,%esp
80100bf7:	83 f8 34             	cmp    $0x34,%eax
80100bfa:	0f 85 61 03 00 00    	jne    80100f61 <exec+0x3e1>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c00:	8b 85 04 ff ff ff    	mov    -0xfc(%ebp),%eax
80100c06:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c0b:	0f 85 53 03 00 00    	jne    80100f64 <exec+0x3e4>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c11:	e8 d9 67 00 00       	call   801073ef <setupkvm>
80100c16:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c19:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c1d:	0f 84 44 03 00 00    	je     80100f67 <exec+0x3e7>
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
80100c4f:	e8 7d 12 00 00       	call   80101ed1 <readi>
80100c54:	83 c4 10             	add    $0x10,%esp
80100c57:	83 f8 20             	cmp    $0x20,%eax
80100c5a:	0f 85 0a 03 00 00    	jne    80100f6a <exec+0x3ea>
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
80100c7d:	0f 82 ea 02 00 00    	jb     80100f6d <exec+0x3ed>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c83:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100c89:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100c8f:	01 c2                	add    %eax,%edx
80100c91:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100c97:	39 c2                	cmp    %eax,%edx
80100c99:	0f 82 d1 02 00 00    	jb     80100f70 <exec+0x3f0>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c9f:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100ca5:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100cab:	01 d0                	add    %edx,%eax
80100cad:	83 ec 04             	sub    $0x4,%esp
80100cb0:	50                   	push   %eax
80100cb1:	ff 75 e0             	push   -0x20(%ebp)
80100cb4:	ff 75 d4             	push   -0x2c(%ebp)
80100cb7:	e8 2c 6b 00 00       	call   801077e8 <allocuvm>
80100cbc:	83 c4 10             	add    $0x10,%esp
80100cbf:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cc2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cc6:	0f 84 a7 02 00 00    	je     80100f73 <exec+0x3f3>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100ccc:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100cd2:	25 ff 0f 00 00       	and    $0xfff,%eax
80100cd7:	85 c0                	test   %eax,%eax
80100cd9:	0f 85 97 02 00 00    	jne    80100f76 <exec+0x3f6>
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
80100cfd:	e8 19 6a 00 00       	call   8010771b <loaduvm>
80100d02:	83 c4 20             	add    $0x20,%esp
80100d05:	85 c0                	test   %eax,%eax
80100d07:	0f 88 6c 02 00 00    	js     80100f79 <exec+0x3f9>
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
80100d36:	e8 db 0e 00 00       	call   80101c16 <iunlockput>
80100d3b:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d3e:	e8 80 23 00 00       	call   801030c3 <end_op>
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
80100d73:	e8 70 6a 00 00       	call   801077e8 <allocuvm>
80100d78:	83 c4 10             	add    $0x10,%esp
80100d7b:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d7e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d82:	0f 84 f4 01 00 00    	je     80100f7c <exec+0x3fc>
    goto bad; 
  sp = KERNBASE;
80100d88:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)


  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d8f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d96:	e9 96 00 00 00       	jmp    80100e31 <exec+0x2b1>
    if(argc >= MAXARG)
80100d9b:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d9f:	0f 87 da 01 00 00    	ja     80100f7f <exec+0x3ff>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100da5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100da8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100daf:	8b 45 0c             	mov    0xc(%ebp),%eax
80100db2:	01 d0                	add    %edx,%eax
80100db4:	8b 00                	mov    (%eax),%eax
80100db6:	83 ec 0c             	sub    $0xc,%esp
80100db9:	50                   	push   %eax
80100dba:	e8 3b 3f 00 00       	call   80104cfa <strlen>
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
80100de7:	e8 0e 3f 00 00       	call   80104cfa <strlen>
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
80100e0d:	e8 c4 6d 00 00       	call   80107bd6 <copyout>
80100e12:	83 c4 10             	add    $0x10,%esp
80100e15:	85 c0                	test   %eax,%eax
80100e17:	0f 88 65 01 00 00    	js     80100f82 <exec+0x402>
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
80100ea9:	e8 28 6d 00 00       	call   80107bd6 <copyout>
80100eae:	83 c4 10             	add    $0x10,%esp
80100eb1:	85 c0                	test   %eax,%eax
80100eb3:	0f 88 cc 00 00 00    	js     80100f85 <exec+0x405>
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
80100ef7:	e8 b3 3d 00 00       	call   80104caf <safestrcpy>
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
  curproc->stackcnt = 1;
80100f34:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f37:	c7 40 7c 01 00 00 00 	movl   $0x1,0x7c(%eax)
  switchuvm(curproc);
80100f3e:	83 ec 0c             	sub    $0xc,%esp
80100f41:	ff 75 d0             	push   -0x30(%ebp)
80100f44:	e8 c3 65 00 00       	call   8010750c <switchuvm>
80100f49:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f4c:	83 ec 0c             	sub    $0xc,%esp
80100f4f:	ff 75 c8             	push   -0x38(%ebp)
80100f52:	e8 5c 6a 00 00       	call   801079b3 <freevm>
80100f57:	83 c4 10             	add    $0x10,%esp

  return 0;
80100f5a:	b8 00 00 00 00       	mov    $0x0,%eax
80100f5f:	eb 57                	jmp    80100fb8 <exec+0x438>
    goto bad;
80100f61:	90                   	nop
80100f62:	eb 22                	jmp    80100f86 <exec+0x406>
    goto bad;
80100f64:	90                   	nop
80100f65:	eb 1f                	jmp    80100f86 <exec+0x406>
    goto bad;
80100f67:	90                   	nop
80100f68:	eb 1c                	jmp    80100f86 <exec+0x406>
      goto bad;
80100f6a:	90                   	nop
80100f6b:	eb 19                	jmp    80100f86 <exec+0x406>
      goto bad;
80100f6d:	90                   	nop
80100f6e:	eb 16                	jmp    80100f86 <exec+0x406>
      goto bad;
80100f70:	90                   	nop
80100f71:	eb 13                	jmp    80100f86 <exec+0x406>
      goto bad;
80100f73:	90                   	nop
80100f74:	eb 10                	jmp    80100f86 <exec+0x406>
      goto bad;
80100f76:	90                   	nop
80100f77:	eb 0d                	jmp    80100f86 <exec+0x406>
      goto bad;
80100f79:	90                   	nop
80100f7a:	eb 0a                	jmp    80100f86 <exec+0x406>
    goto bad; 
80100f7c:	90                   	nop
80100f7d:	eb 07                	jmp    80100f86 <exec+0x406>
      goto bad;
80100f7f:	90                   	nop
80100f80:	eb 04                	jmp    80100f86 <exec+0x406>
      goto bad;
80100f82:	90                   	nop
80100f83:	eb 01                	jmp    80100f86 <exec+0x406>
    goto bad;
80100f85:	90                   	nop

 bad:
  if(pgdir)
80100f86:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f8a:	74 0e                	je     80100f9a <exec+0x41a>
    freevm(pgdir);
80100f8c:	83 ec 0c             	sub    $0xc,%esp
80100f8f:	ff 75 d4             	push   -0x2c(%ebp)
80100f92:	e8 1c 6a 00 00       	call   801079b3 <freevm>
80100f97:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f9a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f9e:	74 13                	je     80100fb3 <exec+0x433>
    iunlockput(ip);
80100fa0:	83 ec 0c             	sub    $0xc,%esp
80100fa3:	ff 75 d8             	push   -0x28(%ebp)
80100fa6:	e8 6b 0c 00 00       	call   80101c16 <iunlockput>
80100fab:	83 c4 10             	add    $0x10,%esp
    end_op();
80100fae:	e8 10 21 00 00       	call   801030c3 <end_op>
  }
  return -1;
80100fb3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fb8:	c9                   	leave  
80100fb9:	c3                   	ret    

80100fba <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fba:	55                   	push   %ebp
80100fbb:	89 e5                	mov    %esp,%ebp
80100fbd:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100fc0:	83 ec 08             	sub    $0x8,%esp
80100fc3:	68 a1 a1 10 80       	push   $0x8010a1a1
80100fc8:	68 a0 1a 19 80       	push   $0x80191aa0
80100fcd:	e8 42 38 00 00       	call   80104814 <initlock>
80100fd2:	83 c4 10             	add    $0x10,%esp
}
80100fd5:	90                   	nop
80100fd6:	c9                   	leave  
80100fd7:	c3                   	ret    

80100fd8 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fd8:	55                   	push   %ebp
80100fd9:	89 e5                	mov    %esp,%ebp
80100fdb:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fde:	83 ec 0c             	sub    $0xc,%esp
80100fe1:	68 a0 1a 19 80       	push   $0x80191aa0
80100fe6:	e8 4b 38 00 00       	call   80104836 <acquire>
80100feb:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fee:	c7 45 f4 d4 1a 19 80 	movl   $0x80191ad4,-0xc(%ebp)
80100ff5:	eb 2d                	jmp    80101024 <filealloc+0x4c>
    if(f->ref == 0){
80100ff7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ffa:	8b 40 04             	mov    0x4(%eax),%eax
80100ffd:	85 c0                	test   %eax,%eax
80100fff:	75 1f                	jne    80101020 <filealloc+0x48>
      f->ref = 1;
80101001:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101004:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010100b:	83 ec 0c             	sub    $0xc,%esp
8010100e:	68 a0 1a 19 80       	push   $0x80191aa0
80101013:	e8 8c 38 00 00       	call   801048a4 <release>
80101018:	83 c4 10             	add    $0x10,%esp
      return f;
8010101b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010101e:	eb 23                	jmp    80101043 <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101020:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101024:	b8 34 24 19 80       	mov    $0x80192434,%eax
80101029:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010102c:	72 c9                	jb     80100ff7 <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
8010102e:	83 ec 0c             	sub    $0xc,%esp
80101031:	68 a0 1a 19 80       	push   $0x80191aa0
80101036:	e8 69 38 00 00       	call   801048a4 <release>
8010103b:	83 c4 10             	add    $0x10,%esp
  return 0;
8010103e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101043:	c9                   	leave  
80101044:	c3                   	ret    

80101045 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101045:	55                   	push   %ebp
80101046:	89 e5                	mov    %esp,%ebp
80101048:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
8010104b:	83 ec 0c             	sub    $0xc,%esp
8010104e:	68 a0 1a 19 80       	push   $0x80191aa0
80101053:	e8 de 37 00 00       	call   80104836 <acquire>
80101058:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010105b:	8b 45 08             	mov    0x8(%ebp),%eax
8010105e:	8b 40 04             	mov    0x4(%eax),%eax
80101061:	85 c0                	test   %eax,%eax
80101063:	7f 0d                	jg     80101072 <filedup+0x2d>
    panic("filedup");
80101065:	83 ec 0c             	sub    $0xc,%esp
80101068:	68 a8 a1 10 80       	push   $0x8010a1a8
8010106d:	e8 37 f5 ff ff       	call   801005a9 <panic>
  f->ref++;
80101072:	8b 45 08             	mov    0x8(%ebp),%eax
80101075:	8b 40 04             	mov    0x4(%eax),%eax
80101078:	8d 50 01             	lea    0x1(%eax),%edx
8010107b:	8b 45 08             	mov    0x8(%ebp),%eax
8010107e:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101081:	83 ec 0c             	sub    $0xc,%esp
80101084:	68 a0 1a 19 80       	push   $0x80191aa0
80101089:	e8 16 38 00 00       	call   801048a4 <release>
8010108e:	83 c4 10             	add    $0x10,%esp
  return f;
80101091:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101094:	c9                   	leave  
80101095:	c3                   	ret    

80101096 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101096:	55                   	push   %ebp
80101097:	89 e5                	mov    %esp,%ebp
80101099:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
8010109c:	83 ec 0c             	sub    $0xc,%esp
8010109f:	68 a0 1a 19 80       	push   $0x80191aa0
801010a4:	e8 8d 37 00 00       	call   80104836 <acquire>
801010a9:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010ac:	8b 45 08             	mov    0x8(%ebp),%eax
801010af:	8b 40 04             	mov    0x4(%eax),%eax
801010b2:	85 c0                	test   %eax,%eax
801010b4:	7f 0d                	jg     801010c3 <fileclose+0x2d>
    panic("fileclose");
801010b6:	83 ec 0c             	sub    $0xc,%esp
801010b9:	68 b0 a1 10 80       	push   $0x8010a1b0
801010be:	e8 e6 f4 ff ff       	call   801005a9 <panic>
  if(--f->ref > 0){
801010c3:	8b 45 08             	mov    0x8(%ebp),%eax
801010c6:	8b 40 04             	mov    0x4(%eax),%eax
801010c9:	8d 50 ff             	lea    -0x1(%eax),%edx
801010cc:	8b 45 08             	mov    0x8(%ebp),%eax
801010cf:	89 50 04             	mov    %edx,0x4(%eax)
801010d2:	8b 45 08             	mov    0x8(%ebp),%eax
801010d5:	8b 40 04             	mov    0x4(%eax),%eax
801010d8:	85 c0                	test   %eax,%eax
801010da:	7e 15                	jle    801010f1 <fileclose+0x5b>
    release(&ftable.lock);
801010dc:	83 ec 0c             	sub    $0xc,%esp
801010df:	68 a0 1a 19 80       	push   $0x80191aa0
801010e4:	e8 bb 37 00 00       	call   801048a4 <release>
801010e9:	83 c4 10             	add    $0x10,%esp
801010ec:	e9 8b 00 00 00       	jmp    8010117c <fileclose+0xe6>
    return;
  }
  ff = *f;
801010f1:	8b 45 08             	mov    0x8(%ebp),%eax
801010f4:	8b 10                	mov    (%eax),%edx
801010f6:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010f9:	8b 50 04             	mov    0x4(%eax),%edx
801010fc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801010ff:	8b 50 08             	mov    0x8(%eax),%edx
80101102:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101105:	8b 50 0c             	mov    0xc(%eax),%edx
80101108:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010110b:	8b 50 10             	mov    0x10(%eax),%edx
8010110e:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101111:	8b 40 14             	mov    0x14(%eax),%eax
80101114:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101117:	8b 45 08             	mov    0x8(%ebp),%eax
8010111a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101121:	8b 45 08             	mov    0x8(%ebp),%eax
80101124:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010112a:	83 ec 0c             	sub    $0xc,%esp
8010112d:	68 a0 1a 19 80       	push   $0x80191aa0
80101132:	e8 6d 37 00 00       	call   801048a4 <release>
80101137:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
8010113a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010113d:	83 f8 01             	cmp    $0x1,%eax
80101140:	75 19                	jne    8010115b <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
80101142:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101146:	0f be d0             	movsbl %al,%edx
80101149:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010114c:	83 ec 08             	sub    $0x8,%esp
8010114f:	52                   	push   %edx
80101150:	50                   	push   %eax
80101151:	e8 64 25 00 00       	call   801036ba <pipeclose>
80101156:	83 c4 10             	add    $0x10,%esp
80101159:	eb 21                	jmp    8010117c <fileclose+0xe6>
  else if(ff.type == FD_INODE){
8010115b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010115e:	83 f8 02             	cmp    $0x2,%eax
80101161:	75 19                	jne    8010117c <fileclose+0xe6>
    begin_op();
80101163:	e8 cf 1e 00 00       	call   80103037 <begin_op>
    iput(ff.ip);
80101168:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010116b:	83 ec 0c             	sub    $0xc,%esp
8010116e:	50                   	push   %eax
8010116f:	e8 d2 09 00 00       	call   80101b46 <iput>
80101174:	83 c4 10             	add    $0x10,%esp
    end_op();
80101177:	e8 47 1f 00 00       	call   801030c3 <end_op>
  }
}
8010117c:	c9                   	leave  
8010117d:	c3                   	ret    

8010117e <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010117e:	55                   	push   %ebp
8010117f:	89 e5                	mov    %esp,%ebp
80101181:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101184:	8b 45 08             	mov    0x8(%ebp),%eax
80101187:	8b 00                	mov    (%eax),%eax
80101189:	83 f8 02             	cmp    $0x2,%eax
8010118c:	75 40                	jne    801011ce <filestat+0x50>
    ilock(f->ip);
8010118e:	8b 45 08             	mov    0x8(%ebp),%eax
80101191:	8b 40 10             	mov    0x10(%eax),%eax
80101194:	83 ec 0c             	sub    $0xc,%esp
80101197:	50                   	push   %eax
80101198:	e8 48 08 00 00       	call   801019e5 <ilock>
8010119d:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011a0:	8b 45 08             	mov    0x8(%ebp),%eax
801011a3:	8b 40 10             	mov    0x10(%eax),%eax
801011a6:	83 ec 08             	sub    $0x8,%esp
801011a9:	ff 75 0c             	push   0xc(%ebp)
801011ac:	50                   	push   %eax
801011ad:	e8 d9 0c 00 00       	call   80101e8b <stati>
801011b2:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801011b5:	8b 45 08             	mov    0x8(%ebp),%eax
801011b8:	8b 40 10             	mov    0x10(%eax),%eax
801011bb:	83 ec 0c             	sub    $0xc,%esp
801011be:	50                   	push   %eax
801011bf:	e8 34 09 00 00       	call   80101af8 <iunlock>
801011c4:	83 c4 10             	add    $0x10,%esp
    return 0;
801011c7:	b8 00 00 00 00       	mov    $0x0,%eax
801011cc:	eb 05                	jmp    801011d3 <filestat+0x55>
  }
  return -1;
801011ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011d3:	c9                   	leave  
801011d4:	c3                   	ret    

801011d5 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011d5:	55                   	push   %ebp
801011d6:	89 e5                	mov    %esp,%ebp
801011d8:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801011db:	8b 45 08             	mov    0x8(%ebp),%eax
801011de:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011e2:	84 c0                	test   %al,%al
801011e4:	75 0a                	jne    801011f0 <fileread+0x1b>
    return -1;
801011e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011eb:	e9 9b 00 00 00       	jmp    8010128b <fileread+0xb6>
  if(f->type == FD_PIPE)
801011f0:	8b 45 08             	mov    0x8(%ebp),%eax
801011f3:	8b 00                	mov    (%eax),%eax
801011f5:	83 f8 01             	cmp    $0x1,%eax
801011f8:	75 1a                	jne    80101214 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801011fa:	8b 45 08             	mov    0x8(%ebp),%eax
801011fd:	8b 40 0c             	mov    0xc(%eax),%eax
80101200:	83 ec 04             	sub    $0x4,%esp
80101203:	ff 75 10             	push   0x10(%ebp)
80101206:	ff 75 0c             	push   0xc(%ebp)
80101209:	50                   	push   %eax
8010120a:	e8 58 26 00 00       	call   80103867 <piperead>
8010120f:	83 c4 10             	add    $0x10,%esp
80101212:	eb 77                	jmp    8010128b <fileread+0xb6>
  if(f->type == FD_INODE){
80101214:	8b 45 08             	mov    0x8(%ebp),%eax
80101217:	8b 00                	mov    (%eax),%eax
80101219:	83 f8 02             	cmp    $0x2,%eax
8010121c:	75 60                	jne    8010127e <fileread+0xa9>
    ilock(f->ip);
8010121e:	8b 45 08             	mov    0x8(%ebp),%eax
80101221:	8b 40 10             	mov    0x10(%eax),%eax
80101224:	83 ec 0c             	sub    $0xc,%esp
80101227:	50                   	push   %eax
80101228:	e8 b8 07 00 00       	call   801019e5 <ilock>
8010122d:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101230:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101233:	8b 45 08             	mov    0x8(%ebp),%eax
80101236:	8b 50 14             	mov    0x14(%eax),%edx
80101239:	8b 45 08             	mov    0x8(%ebp),%eax
8010123c:	8b 40 10             	mov    0x10(%eax),%eax
8010123f:	51                   	push   %ecx
80101240:	52                   	push   %edx
80101241:	ff 75 0c             	push   0xc(%ebp)
80101244:	50                   	push   %eax
80101245:	e8 87 0c 00 00       	call   80101ed1 <readi>
8010124a:	83 c4 10             	add    $0x10,%esp
8010124d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101250:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101254:	7e 11                	jle    80101267 <fileread+0x92>
      f->off += r;
80101256:	8b 45 08             	mov    0x8(%ebp),%eax
80101259:	8b 50 14             	mov    0x14(%eax),%edx
8010125c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010125f:	01 c2                	add    %eax,%edx
80101261:	8b 45 08             	mov    0x8(%ebp),%eax
80101264:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101267:	8b 45 08             	mov    0x8(%ebp),%eax
8010126a:	8b 40 10             	mov    0x10(%eax),%eax
8010126d:	83 ec 0c             	sub    $0xc,%esp
80101270:	50                   	push   %eax
80101271:	e8 82 08 00 00       	call   80101af8 <iunlock>
80101276:	83 c4 10             	add    $0x10,%esp
    return r;
80101279:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010127c:	eb 0d                	jmp    8010128b <fileread+0xb6>
  }
  panic("fileread");
8010127e:	83 ec 0c             	sub    $0xc,%esp
80101281:	68 ba a1 10 80       	push   $0x8010a1ba
80101286:	e8 1e f3 ff ff       	call   801005a9 <panic>
}
8010128b:	c9                   	leave  
8010128c:	c3                   	ret    

8010128d <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010128d:	55                   	push   %ebp
8010128e:	89 e5                	mov    %esp,%ebp
80101290:	53                   	push   %ebx
80101291:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101294:	8b 45 08             	mov    0x8(%ebp),%eax
80101297:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010129b:	84 c0                	test   %al,%al
8010129d:	75 0a                	jne    801012a9 <filewrite+0x1c>
    return -1;
8010129f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012a4:	e9 1b 01 00 00       	jmp    801013c4 <filewrite+0x137>
  if(f->type == FD_PIPE)
801012a9:	8b 45 08             	mov    0x8(%ebp),%eax
801012ac:	8b 00                	mov    (%eax),%eax
801012ae:	83 f8 01             	cmp    $0x1,%eax
801012b1:	75 1d                	jne    801012d0 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
801012b3:	8b 45 08             	mov    0x8(%ebp),%eax
801012b6:	8b 40 0c             	mov    0xc(%eax),%eax
801012b9:	83 ec 04             	sub    $0x4,%esp
801012bc:	ff 75 10             	push   0x10(%ebp)
801012bf:	ff 75 0c             	push   0xc(%ebp)
801012c2:	50                   	push   %eax
801012c3:	e8 9d 24 00 00       	call   80103765 <pipewrite>
801012c8:	83 c4 10             	add    $0x10,%esp
801012cb:	e9 f4 00 00 00       	jmp    801013c4 <filewrite+0x137>
  if(f->type == FD_INODE){
801012d0:	8b 45 08             	mov    0x8(%ebp),%eax
801012d3:	8b 00                	mov    (%eax),%eax
801012d5:	83 f8 02             	cmp    $0x2,%eax
801012d8:	0f 85 d9 00 00 00    	jne    801013b7 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801012de:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801012e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012ec:	e9 a3 00 00 00       	jmp    80101394 <filewrite+0x107>
      int n1 = n - i;
801012f1:	8b 45 10             	mov    0x10(%ebp),%eax
801012f4:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801012fd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101300:	7e 06                	jle    80101308 <filewrite+0x7b>
        n1 = max;
80101302:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101305:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101308:	e8 2a 1d 00 00       	call   80103037 <begin_op>
      ilock(f->ip);
8010130d:	8b 45 08             	mov    0x8(%ebp),%eax
80101310:	8b 40 10             	mov    0x10(%eax),%eax
80101313:	83 ec 0c             	sub    $0xc,%esp
80101316:	50                   	push   %eax
80101317:	e8 c9 06 00 00       	call   801019e5 <ilock>
8010131c:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010131f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101322:	8b 45 08             	mov    0x8(%ebp),%eax
80101325:	8b 50 14             	mov    0x14(%eax),%edx
80101328:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010132b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010132e:	01 c3                	add    %eax,%ebx
80101330:	8b 45 08             	mov    0x8(%ebp),%eax
80101333:	8b 40 10             	mov    0x10(%eax),%eax
80101336:	51                   	push   %ecx
80101337:	52                   	push   %edx
80101338:	53                   	push   %ebx
80101339:	50                   	push   %eax
8010133a:	e8 e7 0c 00 00       	call   80102026 <writei>
8010133f:	83 c4 10             	add    $0x10,%esp
80101342:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101345:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101349:	7e 11                	jle    8010135c <filewrite+0xcf>
        f->off += r;
8010134b:	8b 45 08             	mov    0x8(%ebp),%eax
8010134e:	8b 50 14             	mov    0x14(%eax),%edx
80101351:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101354:	01 c2                	add    %eax,%edx
80101356:	8b 45 08             	mov    0x8(%ebp),%eax
80101359:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
8010135c:	8b 45 08             	mov    0x8(%ebp),%eax
8010135f:	8b 40 10             	mov    0x10(%eax),%eax
80101362:	83 ec 0c             	sub    $0xc,%esp
80101365:	50                   	push   %eax
80101366:	e8 8d 07 00 00       	call   80101af8 <iunlock>
8010136b:	83 c4 10             	add    $0x10,%esp
      end_op();
8010136e:	e8 50 1d 00 00       	call   801030c3 <end_op>

      if(r < 0)
80101373:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101377:	78 29                	js     801013a2 <filewrite+0x115>
        break;
      if(r != n1)
80101379:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010137c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010137f:	74 0d                	je     8010138e <filewrite+0x101>
        panic("short filewrite");
80101381:	83 ec 0c             	sub    $0xc,%esp
80101384:	68 c3 a1 10 80       	push   $0x8010a1c3
80101389:	e8 1b f2 ff ff       	call   801005a9 <panic>
      i += r;
8010138e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101391:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
80101394:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101397:	3b 45 10             	cmp    0x10(%ebp),%eax
8010139a:	0f 8c 51 ff ff ff    	jl     801012f1 <filewrite+0x64>
801013a0:	eb 01                	jmp    801013a3 <filewrite+0x116>
        break;
801013a2:	90                   	nop
    }
    return i == n ? n : -1;
801013a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013a6:	3b 45 10             	cmp    0x10(%ebp),%eax
801013a9:	75 05                	jne    801013b0 <filewrite+0x123>
801013ab:	8b 45 10             	mov    0x10(%ebp),%eax
801013ae:	eb 14                	jmp    801013c4 <filewrite+0x137>
801013b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013b5:	eb 0d                	jmp    801013c4 <filewrite+0x137>
  }
  panic("filewrite");
801013b7:	83 ec 0c             	sub    $0xc,%esp
801013ba:	68 d3 a1 10 80       	push   $0x8010a1d3
801013bf:	e8 e5 f1 ff ff       	call   801005a9 <panic>
}
801013c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013c7:	c9                   	leave  
801013c8:	c3                   	ret    

801013c9 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013c9:	55                   	push   %ebp
801013ca:	89 e5                	mov    %esp,%ebp
801013cc:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801013cf:	8b 45 08             	mov    0x8(%ebp),%eax
801013d2:	83 ec 08             	sub    $0x8,%esp
801013d5:	6a 01                	push   $0x1
801013d7:	50                   	push   %eax
801013d8:	e8 24 ee ff ff       	call   80100201 <bread>
801013dd:	83 c4 10             	add    $0x10,%esp
801013e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013e6:	83 c0 5c             	add    $0x5c,%eax
801013e9:	83 ec 04             	sub    $0x4,%esp
801013ec:	6a 1c                	push   $0x1c
801013ee:	50                   	push   %eax
801013ef:	ff 75 0c             	push   0xc(%ebp)
801013f2:	e8 74 37 00 00       	call   80104b6b <memmove>
801013f7:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013fa:	83 ec 0c             	sub    $0xc,%esp
801013fd:	ff 75 f4             	push   -0xc(%ebp)
80101400:	e8 7e ee ff ff       	call   80100283 <brelse>
80101405:	83 c4 10             	add    $0x10,%esp
}
80101408:	90                   	nop
80101409:	c9                   	leave  
8010140a:	c3                   	ret    

8010140b <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010140b:	55                   	push   %ebp
8010140c:	89 e5                	mov    %esp,%ebp
8010140e:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101411:	8b 55 0c             	mov    0xc(%ebp),%edx
80101414:	8b 45 08             	mov    0x8(%ebp),%eax
80101417:	83 ec 08             	sub    $0x8,%esp
8010141a:	52                   	push   %edx
8010141b:	50                   	push   %eax
8010141c:	e8 e0 ed ff ff       	call   80100201 <bread>
80101421:	83 c4 10             	add    $0x10,%esp
80101424:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101427:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010142a:	83 c0 5c             	add    $0x5c,%eax
8010142d:	83 ec 04             	sub    $0x4,%esp
80101430:	68 00 02 00 00       	push   $0x200
80101435:	6a 00                	push   $0x0
80101437:	50                   	push   %eax
80101438:	e8 6f 36 00 00       	call   80104aac <memset>
8010143d:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101440:	83 ec 0c             	sub    $0xc,%esp
80101443:	ff 75 f4             	push   -0xc(%ebp)
80101446:	e8 25 1e 00 00       	call   80103270 <log_write>
8010144b:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010144e:	83 ec 0c             	sub    $0xc,%esp
80101451:	ff 75 f4             	push   -0xc(%ebp)
80101454:	e8 2a ee ff ff       	call   80100283 <brelse>
80101459:	83 c4 10             	add    $0x10,%esp
}
8010145c:	90                   	nop
8010145d:	c9                   	leave  
8010145e:	c3                   	ret    

8010145f <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
8010145f:	55                   	push   %ebp
80101460:	89 e5                	mov    %esp,%ebp
80101462:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101465:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
8010146c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101473:	e9 0b 01 00 00       	jmp    80101583 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
80101478:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010147b:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101481:	85 c0                	test   %eax,%eax
80101483:	0f 48 c2             	cmovs  %edx,%eax
80101486:	c1 f8 0c             	sar    $0xc,%eax
80101489:	89 c2                	mov    %eax,%edx
8010148b:	a1 58 24 19 80       	mov    0x80192458,%eax
80101490:	01 d0                	add    %edx,%eax
80101492:	83 ec 08             	sub    $0x8,%esp
80101495:	50                   	push   %eax
80101496:	ff 75 08             	push   0x8(%ebp)
80101499:	e8 63 ed ff ff       	call   80100201 <bread>
8010149e:	83 c4 10             	add    $0x10,%esp
801014a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014a4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801014ab:	e9 9e 00 00 00       	jmp    8010154e <balloc+0xef>
      m = 1 << (bi % 8);
801014b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014b3:	83 e0 07             	and    $0x7,%eax
801014b6:	ba 01 00 00 00       	mov    $0x1,%edx
801014bb:	89 c1                	mov    %eax,%ecx
801014bd:	d3 e2                	shl    %cl,%edx
801014bf:	89 d0                	mov    %edx,%eax
801014c1:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014c7:	8d 50 07             	lea    0x7(%eax),%edx
801014ca:	85 c0                	test   %eax,%eax
801014cc:	0f 48 c2             	cmovs  %edx,%eax
801014cf:	c1 f8 03             	sar    $0x3,%eax
801014d2:	89 c2                	mov    %eax,%edx
801014d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014d7:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801014dc:	0f b6 c0             	movzbl %al,%eax
801014df:	23 45 e8             	and    -0x18(%ebp),%eax
801014e2:	85 c0                	test   %eax,%eax
801014e4:	75 64                	jne    8010154a <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
801014e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014e9:	8d 50 07             	lea    0x7(%eax),%edx
801014ec:	85 c0                	test   %eax,%eax
801014ee:	0f 48 c2             	cmovs  %edx,%eax
801014f1:	c1 f8 03             	sar    $0x3,%eax
801014f4:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014f7:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801014fc:	89 d1                	mov    %edx,%ecx
801014fe:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101501:	09 ca                	or     %ecx,%edx
80101503:	89 d1                	mov    %edx,%ecx
80101505:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101508:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
8010150c:	83 ec 0c             	sub    $0xc,%esp
8010150f:	ff 75 ec             	push   -0x14(%ebp)
80101512:	e8 59 1d 00 00       	call   80103270 <log_write>
80101517:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
8010151a:	83 ec 0c             	sub    $0xc,%esp
8010151d:	ff 75 ec             	push   -0x14(%ebp)
80101520:	e8 5e ed ff ff       	call   80100283 <brelse>
80101525:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101528:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010152b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010152e:	01 c2                	add    %eax,%edx
80101530:	8b 45 08             	mov    0x8(%ebp),%eax
80101533:	83 ec 08             	sub    $0x8,%esp
80101536:	52                   	push   %edx
80101537:	50                   	push   %eax
80101538:	e8 ce fe ff ff       	call   8010140b <bzero>
8010153d:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101540:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101543:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101546:	01 d0                	add    %edx,%eax
80101548:	eb 57                	jmp    801015a1 <balloc+0x142>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010154a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010154e:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101555:	7f 17                	jg     8010156e <balloc+0x10f>
80101557:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010155a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010155d:	01 d0                	add    %edx,%eax
8010155f:	89 c2                	mov    %eax,%edx
80101561:	a1 40 24 19 80       	mov    0x80192440,%eax
80101566:	39 c2                	cmp    %eax,%edx
80101568:	0f 82 42 ff ff ff    	jb     801014b0 <balloc+0x51>
      }
    }
    brelse(bp);
8010156e:	83 ec 0c             	sub    $0xc,%esp
80101571:	ff 75 ec             	push   -0x14(%ebp)
80101574:	e8 0a ed ff ff       	call   80100283 <brelse>
80101579:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
8010157c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101583:	8b 15 40 24 19 80    	mov    0x80192440,%edx
80101589:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010158c:	39 c2                	cmp    %eax,%edx
8010158e:	0f 87 e4 fe ff ff    	ja     80101478 <balloc+0x19>
  }
  panic("balloc: out of blocks");
80101594:	83 ec 0c             	sub    $0xc,%esp
80101597:	68 e0 a1 10 80       	push   $0x8010a1e0
8010159c:	e8 08 f0 ff ff       	call   801005a9 <panic>
}
801015a1:	c9                   	leave  
801015a2:	c3                   	ret    

801015a3 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801015a3:	55                   	push   %ebp
801015a4:	89 e5                	mov    %esp,%ebp
801015a6:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801015a9:	83 ec 08             	sub    $0x8,%esp
801015ac:	68 40 24 19 80       	push   $0x80192440
801015b1:	ff 75 08             	push   0x8(%ebp)
801015b4:	e8 10 fe ff ff       	call   801013c9 <readsb>
801015b9:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015bc:	8b 45 0c             	mov    0xc(%ebp),%eax
801015bf:	c1 e8 0c             	shr    $0xc,%eax
801015c2:	89 c2                	mov    %eax,%edx
801015c4:	a1 58 24 19 80       	mov    0x80192458,%eax
801015c9:	01 c2                	add    %eax,%edx
801015cb:	8b 45 08             	mov    0x8(%ebp),%eax
801015ce:	83 ec 08             	sub    $0x8,%esp
801015d1:	52                   	push   %edx
801015d2:	50                   	push   %eax
801015d3:	e8 29 ec ff ff       	call   80100201 <bread>
801015d8:	83 c4 10             	add    $0x10,%esp
801015db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015de:	8b 45 0c             	mov    0xc(%ebp),%eax
801015e1:	25 ff 0f 00 00       	and    $0xfff,%eax
801015e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015ec:	83 e0 07             	and    $0x7,%eax
801015ef:	ba 01 00 00 00       	mov    $0x1,%edx
801015f4:	89 c1                	mov    %eax,%ecx
801015f6:	d3 e2                	shl    %cl,%edx
801015f8:	89 d0                	mov    %edx,%eax
801015fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801015fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101600:	8d 50 07             	lea    0x7(%eax),%edx
80101603:	85 c0                	test   %eax,%eax
80101605:	0f 48 c2             	cmovs  %edx,%eax
80101608:	c1 f8 03             	sar    $0x3,%eax
8010160b:	89 c2                	mov    %eax,%edx
8010160d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101610:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101615:	0f b6 c0             	movzbl %al,%eax
80101618:	23 45 ec             	and    -0x14(%ebp),%eax
8010161b:	85 c0                	test   %eax,%eax
8010161d:	75 0d                	jne    8010162c <bfree+0x89>
    panic("freeing free block");
8010161f:	83 ec 0c             	sub    $0xc,%esp
80101622:	68 f6 a1 10 80       	push   $0x8010a1f6
80101627:	e8 7d ef ff ff       	call   801005a9 <panic>
  bp->data[bi/8] &= ~m;
8010162c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010162f:	8d 50 07             	lea    0x7(%eax),%edx
80101632:	85 c0                	test   %eax,%eax
80101634:	0f 48 c2             	cmovs  %edx,%eax
80101637:	c1 f8 03             	sar    $0x3,%eax
8010163a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010163d:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101642:	89 d1                	mov    %edx,%ecx
80101644:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101647:	f7 d2                	not    %edx
80101649:	21 ca                	and    %ecx,%edx
8010164b:	89 d1                	mov    %edx,%ecx
8010164d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101650:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101654:	83 ec 0c             	sub    $0xc,%esp
80101657:	ff 75 f4             	push   -0xc(%ebp)
8010165a:	e8 11 1c 00 00       	call   80103270 <log_write>
8010165f:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101662:	83 ec 0c             	sub    $0xc,%esp
80101665:	ff 75 f4             	push   -0xc(%ebp)
80101668:	e8 16 ec ff ff       	call   80100283 <brelse>
8010166d:	83 c4 10             	add    $0x10,%esp
}
80101670:	90                   	nop
80101671:	c9                   	leave  
80101672:	c3                   	ret    

80101673 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101673:	55                   	push   %ebp
80101674:	89 e5                	mov    %esp,%ebp
80101676:	57                   	push   %edi
80101677:	56                   	push   %esi
80101678:	53                   	push   %ebx
80101679:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
8010167c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101683:	83 ec 08             	sub    $0x8,%esp
80101686:	68 09 a2 10 80       	push   $0x8010a209
8010168b:	68 60 24 19 80       	push   $0x80192460
80101690:	e8 7f 31 00 00       	call   80104814 <initlock>
80101695:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
80101698:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010169f:	eb 2d                	jmp    801016ce <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
801016a1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801016a4:	89 d0                	mov    %edx,%eax
801016a6:	c1 e0 03             	shl    $0x3,%eax
801016a9:	01 d0                	add    %edx,%eax
801016ab:	c1 e0 04             	shl    $0x4,%eax
801016ae:	83 c0 30             	add    $0x30,%eax
801016b1:	05 60 24 19 80       	add    $0x80192460,%eax
801016b6:	83 c0 10             	add    $0x10,%eax
801016b9:	83 ec 08             	sub    $0x8,%esp
801016bc:	68 10 a2 10 80       	push   $0x8010a210
801016c1:	50                   	push   %eax
801016c2:	e8 f0 2f 00 00       	call   801046b7 <initsleeplock>
801016c7:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016ca:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801016ce:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016d2:	7e cd                	jle    801016a1 <iinit+0x2e>
  }

  readsb(dev, &sb);
801016d4:	83 ec 08             	sub    $0x8,%esp
801016d7:	68 40 24 19 80       	push   $0x80192440
801016dc:	ff 75 08             	push   0x8(%ebp)
801016df:	e8 e5 fc ff ff       	call   801013c9 <readsb>
801016e4:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016e7:	a1 58 24 19 80       	mov    0x80192458,%eax
801016ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801016ef:	8b 3d 54 24 19 80    	mov    0x80192454,%edi
801016f5:	8b 35 50 24 19 80    	mov    0x80192450,%esi
801016fb:	8b 1d 4c 24 19 80    	mov    0x8019244c,%ebx
80101701:	8b 0d 48 24 19 80    	mov    0x80192448,%ecx
80101707:	8b 15 44 24 19 80    	mov    0x80192444,%edx
8010170d:	a1 40 24 19 80       	mov    0x80192440,%eax
80101712:	ff 75 d4             	push   -0x2c(%ebp)
80101715:	57                   	push   %edi
80101716:	56                   	push   %esi
80101717:	53                   	push   %ebx
80101718:	51                   	push   %ecx
80101719:	52                   	push   %edx
8010171a:	50                   	push   %eax
8010171b:	68 18 a2 10 80       	push   $0x8010a218
80101720:	e8 cf ec ff ff       	call   801003f4 <cprintf>
80101725:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
80101728:	90                   	nop
80101729:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010172c:	5b                   	pop    %ebx
8010172d:	5e                   	pop    %esi
8010172e:	5f                   	pop    %edi
8010172f:	5d                   	pop    %ebp
80101730:	c3                   	ret    

80101731 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101731:	55                   	push   %ebp
80101732:	89 e5                	mov    %esp,%ebp
80101734:	83 ec 28             	sub    $0x28,%esp
80101737:	8b 45 0c             	mov    0xc(%ebp),%eax
8010173a:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010173e:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101745:	e9 9e 00 00 00       	jmp    801017e8 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
8010174a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010174d:	c1 e8 03             	shr    $0x3,%eax
80101750:	89 c2                	mov    %eax,%edx
80101752:	a1 54 24 19 80       	mov    0x80192454,%eax
80101757:	01 d0                	add    %edx,%eax
80101759:	83 ec 08             	sub    $0x8,%esp
8010175c:	50                   	push   %eax
8010175d:	ff 75 08             	push   0x8(%ebp)
80101760:	e8 9c ea ff ff       	call   80100201 <bread>
80101765:	83 c4 10             	add    $0x10,%esp
80101768:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
8010176b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010176e:	8d 50 5c             	lea    0x5c(%eax),%edx
80101771:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101774:	83 e0 07             	and    $0x7,%eax
80101777:	c1 e0 06             	shl    $0x6,%eax
8010177a:	01 d0                	add    %edx,%eax
8010177c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010177f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101782:	0f b7 00             	movzwl (%eax),%eax
80101785:	66 85 c0             	test   %ax,%ax
80101788:	75 4c                	jne    801017d6 <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
8010178a:	83 ec 04             	sub    $0x4,%esp
8010178d:	6a 40                	push   $0x40
8010178f:	6a 00                	push   $0x0
80101791:	ff 75 ec             	push   -0x14(%ebp)
80101794:	e8 13 33 00 00       	call   80104aac <memset>
80101799:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
8010179c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010179f:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017a3:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017a6:	83 ec 0c             	sub    $0xc,%esp
801017a9:	ff 75 f0             	push   -0x10(%ebp)
801017ac:	e8 bf 1a 00 00       	call   80103270 <log_write>
801017b1:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017b4:	83 ec 0c             	sub    $0xc,%esp
801017b7:	ff 75 f0             	push   -0x10(%ebp)
801017ba:	e8 c4 ea ff ff       	call   80100283 <brelse>
801017bf:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017c5:	83 ec 08             	sub    $0x8,%esp
801017c8:	50                   	push   %eax
801017c9:	ff 75 08             	push   0x8(%ebp)
801017cc:	e8 f8 00 00 00       	call   801018c9 <iget>
801017d1:	83 c4 10             	add    $0x10,%esp
801017d4:	eb 30                	jmp    80101806 <ialloc+0xd5>
    }
    brelse(bp);
801017d6:	83 ec 0c             	sub    $0xc,%esp
801017d9:	ff 75 f0             	push   -0x10(%ebp)
801017dc:	e8 a2 ea ff ff       	call   80100283 <brelse>
801017e1:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801017e4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801017e8:	8b 15 48 24 19 80    	mov    0x80192448,%edx
801017ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f1:	39 c2                	cmp    %eax,%edx
801017f3:	0f 87 51 ff ff ff    	ja     8010174a <ialloc+0x19>
  }
  panic("ialloc: no inodes");
801017f9:	83 ec 0c             	sub    $0xc,%esp
801017fc:	68 6b a2 10 80       	push   $0x8010a26b
80101801:	e8 a3 ed ff ff       	call   801005a9 <panic>
}
80101806:	c9                   	leave  
80101807:	c3                   	ret    

80101808 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101808:	55                   	push   %ebp
80101809:	89 e5                	mov    %esp,%ebp
8010180b:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010180e:	8b 45 08             	mov    0x8(%ebp),%eax
80101811:	8b 40 04             	mov    0x4(%eax),%eax
80101814:	c1 e8 03             	shr    $0x3,%eax
80101817:	89 c2                	mov    %eax,%edx
80101819:	a1 54 24 19 80       	mov    0x80192454,%eax
8010181e:	01 c2                	add    %eax,%edx
80101820:	8b 45 08             	mov    0x8(%ebp),%eax
80101823:	8b 00                	mov    (%eax),%eax
80101825:	83 ec 08             	sub    $0x8,%esp
80101828:	52                   	push   %edx
80101829:	50                   	push   %eax
8010182a:	e8 d2 e9 ff ff       	call   80100201 <bread>
8010182f:	83 c4 10             	add    $0x10,%esp
80101832:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101838:	8d 50 5c             	lea    0x5c(%eax),%edx
8010183b:	8b 45 08             	mov    0x8(%ebp),%eax
8010183e:	8b 40 04             	mov    0x4(%eax),%eax
80101841:	83 e0 07             	and    $0x7,%eax
80101844:	c1 e0 06             	shl    $0x6,%eax
80101847:	01 d0                	add    %edx,%eax
80101849:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
8010184c:	8b 45 08             	mov    0x8(%ebp),%eax
8010184f:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101853:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101856:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101859:	8b 45 08             	mov    0x8(%ebp),%eax
8010185c:	0f b7 50 52          	movzwl 0x52(%eax),%edx
80101860:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101863:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101867:	8b 45 08             	mov    0x8(%ebp),%eax
8010186a:	0f b7 50 54          	movzwl 0x54(%eax),%edx
8010186e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101871:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101875:	8b 45 08             	mov    0x8(%ebp),%eax
80101878:	0f b7 50 56          	movzwl 0x56(%eax),%edx
8010187c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010187f:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101883:	8b 45 08             	mov    0x8(%ebp),%eax
80101886:	8b 50 58             	mov    0x58(%eax),%edx
80101889:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010188c:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010188f:	8b 45 08             	mov    0x8(%ebp),%eax
80101892:	8d 50 5c             	lea    0x5c(%eax),%edx
80101895:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101898:	83 c0 0c             	add    $0xc,%eax
8010189b:	83 ec 04             	sub    $0x4,%esp
8010189e:	6a 34                	push   $0x34
801018a0:	52                   	push   %edx
801018a1:	50                   	push   %eax
801018a2:	e8 c4 32 00 00       	call   80104b6b <memmove>
801018a7:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018aa:	83 ec 0c             	sub    $0xc,%esp
801018ad:	ff 75 f4             	push   -0xc(%ebp)
801018b0:	e8 bb 19 00 00       	call   80103270 <log_write>
801018b5:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018b8:	83 ec 0c             	sub    $0xc,%esp
801018bb:	ff 75 f4             	push   -0xc(%ebp)
801018be:	e8 c0 e9 ff ff       	call   80100283 <brelse>
801018c3:	83 c4 10             	add    $0x10,%esp
}
801018c6:	90                   	nop
801018c7:	c9                   	leave  
801018c8:	c3                   	ret    

801018c9 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018c9:	55                   	push   %ebp
801018ca:	89 e5                	mov    %esp,%ebp
801018cc:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801018cf:	83 ec 0c             	sub    $0xc,%esp
801018d2:	68 60 24 19 80       	push   $0x80192460
801018d7:	e8 5a 2f 00 00       	call   80104836 <acquire>
801018dc:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801018df:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018e6:	c7 45 f4 94 24 19 80 	movl   $0x80192494,-0xc(%ebp)
801018ed:	eb 60                	jmp    8010194f <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801018ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f2:	8b 40 08             	mov    0x8(%eax),%eax
801018f5:	85 c0                	test   %eax,%eax
801018f7:	7e 39                	jle    80101932 <iget+0x69>
801018f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018fc:	8b 00                	mov    (%eax),%eax
801018fe:	39 45 08             	cmp    %eax,0x8(%ebp)
80101901:	75 2f                	jne    80101932 <iget+0x69>
80101903:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101906:	8b 40 04             	mov    0x4(%eax),%eax
80101909:	39 45 0c             	cmp    %eax,0xc(%ebp)
8010190c:	75 24                	jne    80101932 <iget+0x69>
      ip->ref++;
8010190e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101911:	8b 40 08             	mov    0x8(%eax),%eax
80101914:	8d 50 01             	lea    0x1(%eax),%edx
80101917:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010191a:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
8010191d:	83 ec 0c             	sub    $0xc,%esp
80101920:	68 60 24 19 80       	push   $0x80192460
80101925:	e8 7a 2f 00 00       	call   801048a4 <release>
8010192a:	83 c4 10             	add    $0x10,%esp
      return ip;
8010192d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101930:	eb 77                	jmp    801019a9 <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101932:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101936:	75 10                	jne    80101948 <iget+0x7f>
80101938:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010193b:	8b 40 08             	mov    0x8(%eax),%eax
8010193e:	85 c0                	test   %eax,%eax
80101940:	75 06                	jne    80101948 <iget+0x7f>
      empty = ip;
80101942:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101945:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101948:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
8010194f:	81 7d f4 b4 40 19 80 	cmpl   $0x801940b4,-0xc(%ebp)
80101956:	72 97                	jb     801018ef <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101958:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010195c:	75 0d                	jne    8010196b <iget+0xa2>
    panic("iget: no inodes");
8010195e:	83 ec 0c             	sub    $0xc,%esp
80101961:	68 7d a2 10 80       	push   $0x8010a27d
80101966:	e8 3e ec ff ff       	call   801005a9 <panic>

  ip = empty;
8010196b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010196e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101971:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101974:	8b 55 08             	mov    0x8(%ebp),%edx
80101977:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101979:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010197c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010197f:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101982:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101985:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
8010198c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010198f:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101996:	83 ec 0c             	sub    $0xc,%esp
80101999:	68 60 24 19 80       	push   $0x80192460
8010199e:	e8 01 2f 00 00       	call   801048a4 <release>
801019a3:	83 c4 10             	add    $0x10,%esp

  return ip;
801019a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801019a9:	c9                   	leave  
801019aa:	c3                   	ret    

801019ab <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801019ab:	55                   	push   %ebp
801019ac:	89 e5                	mov    %esp,%ebp
801019ae:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801019b1:	83 ec 0c             	sub    $0xc,%esp
801019b4:	68 60 24 19 80       	push   $0x80192460
801019b9:	e8 78 2e 00 00       	call   80104836 <acquire>
801019be:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019c1:	8b 45 08             	mov    0x8(%ebp),%eax
801019c4:	8b 40 08             	mov    0x8(%eax),%eax
801019c7:	8d 50 01             	lea    0x1(%eax),%edx
801019ca:	8b 45 08             	mov    0x8(%ebp),%eax
801019cd:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019d0:	83 ec 0c             	sub    $0xc,%esp
801019d3:	68 60 24 19 80       	push   $0x80192460
801019d8:	e8 c7 2e 00 00       	call   801048a4 <release>
801019dd:	83 c4 10             	add    $0x10,%esp
  return ip;
801019e0:	8b 45 08             	mov    0x8(%ebp),%eax
}
801019e3:	c9                   	leave  
801019e4:	c3                   	ret    

801019e5 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801019e5:	55                   	push   %ebp
801019e6:	89 e5                	mov    %esp,%ebp
801019e8:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801019eb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019ef:	74 0a                	je     801019fb <ilock+0x16>
801019f1:	8b 45 08             	mov    0x8(%ebp),%eax
801019f4:	8b 40 08             	mov    0x8(%eax),%eax
801019f7:	85 c0                	test   %eax,%eax
801019f9:	7f 0d                	jg     80101a08 <ilock+0x23>
    panic("ilock");
801019fb:	83 ec 0c             	sub    $0xc,%esp
801019fe:	68 8d a2 10 80       	push   $0x8010a28d
80101a03:	e8 a1 eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a08:	8b 45 08             	mov    0x8(%ebp),%eax
80101a0b:	83 c0 0c             	add    $0xc,%eax
80101a0e:	83 ec 0c             	sub    $0xc,%esp
80101a11:	50                   	push   %eax
80101a12:	e8 dc 2c 00 00       	call   801046f3 <acquiresleep>
80101a17:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101a1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a1d:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a20:	85 c0                	test   %eax,%eax
80101a22:	0f 85 cd 00 00 00    	jne    80101af5 <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a28:	8b 45 08             	mov    0x8(%ebp),%eax
80101a2b:	8b 40 04             	mov    0x4(%eax),%eax
80101a2e:	c1 e8 03             	shr    $0x3,%eax
80101a31:	89 c2                	mov    %eax,%edx
80101a33:	a1 54 24 19 80       	mov    0x80192454,%eax
80101a38:	01 c2                	add    %eax,%edx
80101a3a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a3d:	8b 00                	mov    (%eax),%eax
80101a3f:	83 ec 08             	sub    $0x8,%esp
80101a42:	52                   	push   %edx
80101a43:	50                   	push   %eax
80101a44:	e8 b8 e7 ff ff       	call   80100201 <bread>
80101a49:	83 c4 10             	add    $0x10,%esp
80101a4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a52:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a55:	8b 45 08             	mov    0x8(%ebp),%eax
80101a58:	8b 40 04             	mov    0x4(%eax),%eax
80101a5b:	83 e0 07             	and    $0x7,%eax
80101a5e:	c1 e0 06             	shl    $0x6,%eax
80101a61:	01 d0                	add    %edx,%eax
80101a63:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a69:	0f b7 10             	movzwl (%eax),%edx
80101a6c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6f:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101a73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a76:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a7a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a7d:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101a81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a84:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a88:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8b:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101a8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a92:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a96:	8b 45 08             	mov    0x8(%ebp),%eax
80101a99:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101a9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aa0:	8b 50 08             	mov    0x8(%eax),%edx
80101aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa6:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101aa9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aac:	8d 50 0c             	lea    0xc(%eax),%edx
80101aaf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab2:	83 c0 5c             	add    $0x5c,%eax
80101ab5:	83 ec 04             	sub    $0x4,%esp
80101ab8:	6a 34                	push   $0x34
80101aba:	52                   	push   %edx
80101abb:	50                   	push   %eax
80101abc:	e8 aa 30 00 00       	call   80104b6b <memmove>
80101ac1:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ac4:	83 ec 0c             	sub    $0xc,%esp
80101ac7:	ff 75 f4             	push   -0xc(%ebp)
80101aca:	e8 b4 e7 ff ff       	call   80100283 <brelse>
80101acf:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101ad2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad5:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101adc:	8b 45 08             	mov    0x8(%ebp),%eax
80101adf:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ae3:	66 85 c0             	test   %ax,%ax
80101ae6:	75 0d                	jne    80101af5 <ilock+0x110>
      panic("ilock: no type");
80101ae8:	83 ec 0c             	sub    $0xc,%esp
80101aeb:	68 93 a2 10 80       	push   $0x8010a293
80101af0:	e8 b4 ea ff ff       	call   801005a9 <panic>
  }
}
80101af5:	90                   	nop
80101af6:	c9                   	leave  
80101af7:	c3                   	ret    

80101af8 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101af8:	55                   	push   %ebp
80101af9:	89 e5                	mov    %esp,%ebp
80101afb:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101afe:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b02:	74 20                	je     80101b24 <iunlock+0x2c>
80101b04:	8b 45 08             	mov    0x8(%ebp),%eax
80101b07:	83 c0 0c             	add    $0xc,%eax
80101b0a:	83 ec 0c             	sub    $0xc,%esp
80101b0d:	50                   	push   %eax
80101b0e:	e8 92 2c 00 00       	call   801047a5 <holdingsleep>
80101b13:	83 c4 10             	add    $0x10,%esp
80101b16:	85 c0                	test   %eax,%eax
80101b18:	74 0a                	je     80101b24 <iunlock+0x2c>
80101b1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b1d:	8b 40 08             	mov    0x8(%eax),%eax
80101b20:	85 c0                	test   %eax,%eax
80101b22:	7f 0d                	jg     80101b31 <iunlock+0x39>
    panic("iunlock");
80101b24:	83 ec 0c             	sub    $0xc,%esp
80101b27:	68 a2 a2 10 80       	push   $0x8010a2a2
80101b2c:	e8 78 ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b31:	8b 45 08             	mov    0x8(%ebp),%eax
80101b34:	83 c0 0c             	add    $0xc,%eax
80101b37:	83 ec 0c             	sub    $0xc,%esp
80101b3a:	50                   	push   %eax
80101b3b:	e8 17 2c 00 00       	call   80104757 <releasesleep>
80101b40:	83 c4 10             	add    $0x10,%esp
}
80101b43:	90                   	nop
80101b44:	c9                   	leave  
80101b45:	c3                   	ret    

80101b46 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b46:	55                   	push   %ebp
80101b47:	89 e5                	mov    %esp,%ebp
80101b49:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101b4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4f:	83 c0 0c             	add    $0xc,%eax
80101b52:	83 ec 0c             	sub    $0xc,%esp
80101b55:	50                   	push   %eax
80101b56:	e8 98 2b 00 00       	call   801046f3 <acquiresleep>
80101b5b:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101b5e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b61:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b64:	85 c0                	test   %eax,%eax
80101b66:	74 6a                	je     80101bd2 <iput+0x8c>
80101b68:	8b 45 08             	mov    0x8(%ebp),%eax
80101b6b:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101b6f:	66 85 c0             	test   %ax,%ax
80101b72:	75 5e                	jne    80101bd2 <iput+0x8c>
    acquire(&icache.lock);
80101b74:	83 ec 0c             	sub    $0xc,%esp
80101b77:	68 60 24 19 80       	push   $0x80192460
80101b7c:	e8 b5 2c 00 00       	call   80104836 <acquire>
80101b81:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b84:	8b 45 08             	mov    0x8(%ebp),%eax
80101b87:	8b 40 08             	mov    0x8(%eax),%eax
80101b8a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b8d:	83 ec 0c             	sub    $0xc,%esp
80101b90:	68 60 24 19 80       	push   $0x80192460
80101b95:	e8 0a 2d 00 00       	call   801048a4 <release>
80101b9a:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101b9d:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101ba1:	75 2f                	jne    80101bd2 <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101ba3:	83 ec 0c             	sub    $0xc,%esp
80101ba6:	ff 75 08             	push   0x8(%ebp)
80101ba9:	e8 ad 01 00 00       	call   80101d5b <itrunc>
80101bae:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101bb1:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb4:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101bba:	83 ec 0c             	sub    $0xc,%esp
80101bbd:	ff 75 08             	push   0x8(%ebp)
80101bc0:	e8 43 fc ff ff       	call   80101808 <iupdate>
80101bc5:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101bc8:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcb:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101bd2:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd5:	83 c0 0c             	add    $0xc,%eax
80101bd8:	83 ec 0c             	sub    $0xc,%esp
80101bdb:	50                   	push   %eax
80101bdc:	e8 76 2b 00 00       	call   80104757 <releasesleep>
80101be1:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101be4:	83 ec 0c             	sub    $0xc,%esp
80101be7:	68 60 24 19 80       	push   $0x80192460
80101bec:	e8 45 2c 00 00       	call   80104836 <acquire>
80101bf1:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101bf4:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf7:	8b 40 08             	mov    0x8(%eax),%eax
80101bfa:	8d 50 ff             	lea    -0x1(%eax),%edx
80101bfd:	8b 45 08             	mov    0x8(%ebp),%eax
80101c00:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c03:	83 ec 0c             	sub    $0xc,%esp
80101c06:	68 60 24 19 80       	push   $0x80192460
80101c0b:	e8 94 2c 00 00       	call   801048a4 <release>
80101c10:	83 c4 10             	add    $0x10,%esp
}
80101c13:	90                   	nop
80101c14:	c9                   	leave  
80101c15:	c3                   	ret    

80101c16 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c16:	55                   	push   %ebp
80101c17:	89 e5                	mov    %esp,%ebp
80101c19:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c1c:	83 ec 0c             	sub    $0xc,%esp
80101c1f:	ff 75 08             	push   0x8(%ebp)
80101c22:	e8 d1 fe ff ff       	call   80101af8 <iunlock>
80101c27:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c2a:	83 ec 0c             	sub    $0xc,%esp
80101c2d:	ff 75 08             	push   0x8(%ebp)
80101c30:	e8 11 ff ff ff       	call   80101b46 <iput>
80101c35:	83 c4 10             	add    $0x10,%esp
}
80101c38:	90                   	nop
80101c39:	c9                   	leave  
80101c3a:	c3                   	ret    

80101c3b <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c3b:	55                   	push   %ebp
80101c3c:	89 e5                	mov    %esp,%ebp
80101c3e:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c41:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c45:	77 42                	ja     80101c89 <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101c47:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4a:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c4d:	83 c2 14             	add    $0x14,%edx
80101c50:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c54:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c57:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c5b:	75 24                	jne    80101c81 <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c60:	8b 00                	mov    (%eax),%eax
80101c62:	83 ec 0c             	sub    $0xc,%esp
80101c65:	50                   	push   %eax
80101c66:	e8 f4 f7 ff ff       	call   8010145f <balloc>
80101c6b:	83 c4 10             	add    $0x10,%esp
80101c6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c71:	8b 45 08             	mov    0x8(%ebp),%eax
80101c74:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c77:	8d 4a 14             	lea    0x14(%edx),%ecx
80101c7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c7d:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c84:	e9 d0 00 00 00       	jmp    80101d59 <bmap+0x11e>
  }
  bn -= NDIRECT;
80101c89:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c8d:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c91:	0f 87 b5 00 00 00    	ja     80101d4c <bmap+0x111>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101c97:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9a:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101ca0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ca3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101ca7:	75 20                	jne    80101cc9 <bmap+0x8e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101ca9:	8b 45 08             	mov    0x8(%ebp),%eax
80101cac:	8b 00                	mov    (%eax),%eax
80101cae:	83 ec 0c             	sub    $0xc,%esp
80101cb1:	50                   	push   %eax
80101cb2:	e8 a8 f7 ff ff       	call   8010145f <balloc>
80101cb7:	83 c4 10             	add    $0x10,%esp
80101cba:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cbd:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cc3:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101cc9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ccc:	8b 00                	mov    (%eax),%eax
80101cce:	83 ec 08             	sub    $0x8,%esp
80101cd1:	ff 75 f4             	push   -0xc(%ebp)
80101cd4:	50                   	push   %eax
80101cd5:	e8 27 e5 ff ff       	call   80100201 <bread>
80101cda:	83 c4 10             	add    $0x10,%esp
80101cdd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101ce0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ce3:	83 c0 5c             	add    $0x5c,%eax
80101ce6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101ce9:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cec:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cf3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cf6:	01 d0                	add    %edx,%eax
80101cf8:	8b 00                	mov    (%eax),%eax
80101cfa:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cfd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d01:	75 36                	jne    80101d39 <bmap+0xfe>
      a[bn] = addr = balloc(ip->dev);
80101d03:	8b 45 08             	mov    0x8(%ebp),%eax
80101d06:	8b 00                	mov    (%eax),%eax
80101d08:	83 ec 0c             	sub    $0xc,%esp
80101d0b:	50                   	push   %eax
80101d0c:	e8 4e f7 ff ff       	call   8010145f <balloc>
80101d11:	83 c4 10             	add    $0x10,%esp
80101d14:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d17:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d1a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d21:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d24:	01 c2                	add    %eax,%edx
80101d26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d29:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d2b:	83 ec 0c             	sub    $0xc,%esp
80101d2e:	ff 75 f0             	push   -0x10(%ebp)
80101d31:	e8 3a 15 00 00       	call   80103270 <log_write>
80101d36:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d39:	83 ec 0c             	sub    $0xc,%esp
80101d3c:	ff 75 f0             	push   -0x10(%ebp)
80101d3f:	e8 3f e5 ff ff       	call   80100283 <brelse>
80101d44:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d4a:	eb 0d                	jmp    80101d59 <bmap+0x11e>
  }

  panic("bmap: out of range");
80101d4c:	83 ec 0c             	sub    $0xc,%esp
80101d4f:	68 aa a2 10 80       	push   $0x8010a2aa
80101d54:	e8 50 e8 ff ff       	call   801005a9 <panic>
}
80101d59:	c9                   	leave  
80101d5a:	c3                   	ret    

80101d5b <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d5b:	55                   	push   %ebp
80101d5c:	89 e5                	mov    %esp,%ebp
80101d5e:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d61:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d68:	eb 45                	jmp    80101daf <itrunc+0x54>
    if(ip->addrs[i]){
80101d6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d70:	83 c2 14             	add    $0x14,%edx
80101d73:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d77:	85 c0                	test   %eax,%eax
80101d79:	74 30                	je     80101dab <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d7e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d81:	83 c2 14             	add    $0x14,%edx
80101d84:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d88:	8b 55 08             	mov    0x8(%ebp),%edx
80101d8b:	8b 12                	mov    (%edx),%edx
80101d8d:	83 ec 08             	sub    $0x8,%esp
80101d90:	50                   	push   %eax
80101d91:	52                   	push   %edx
80101d92:	e8 0c f8 ff ff       	call   801015a3 <bfree>
80101d97:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101d9a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101da0:	83 c2 14             	add    $0x14,%edx
80101da3:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101daa:	00 
  for(i = 0; i < NDIRECT; i++){
80101dab:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101daf:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101db3:	7e b5                	jle    80101d6a <itrunc+0xf>
    }
  }

  if(ip->addrs[NDIRECT]){
80101db5:	8b 45 08             	mov    0x8(%ebp),%eax
80101db8:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101dbe:	85 c0                	test   %eax,%eax
80101dc0:	0f 84 aa 00 00 00    	je     80101e70 <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dc6:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc9:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101dcf:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd2:	8b 00                	mov    (%eax),%eax
80101dd4:	83 ec 08             	sub    $0x8,%esp
80101dd7:	52                   	push   %edx
80101dd8:	50                   	push   %eax
80101dd9:	e8 23 e4 ff ff       	call   80100201 <bread>
80101dde:	83 c4 10             	add    $0x10,%esp
80101de1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101de4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101de7:	83 c0 5c             	add    $0x5c,%eax
80101dea:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101ded:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101df4:	eb 3c                	jmp    80101e32 <itrunc+0xd7>
      if(a[j])
80101df6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101df9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e00:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e03:	01 d0                	add    %edx,%eax
80101e05:	8b 00                	mov    (%eax),%eax
80101e07:	85 c0                	test   %eax,%eax
80101e09:	74 23                	je     80101e2e <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101e0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e0e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e15:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e18:	01 d0                	add    %edx,%eax
80101e1a:	8b 00                	mov    (%eax),%eax
80101e1c:	8b 55 08             	mov    0x8(%ebp),%edx
80101e1f:	8b 12                	mov    (%edx),%edx
80101e21:	83 ec 08             	sub    $0x8,%esp
80101e24:	50                   	push   %eax
80101e25:	52                   	push   %edx
80101e26:	e8 78 f7 ff ff       	call   801015a3 <bfree>
80101e2b:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101e2e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e35:	83 f8 7f             	cmp    $0x7f,%eax
80101e38:	76 bc                	jbe    80101df6 <itrunc+0x9b>
    }
    brelse(bp);
80101e3a:	83 ec 0c             	sub    $0xc,%esp
80101e3d:	ff 75 ec             	push   -0x14(%ebp)
80101e40:	e8 3e e4 ff ff       	call   80100283 <brelse>
80101e45:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e48:	8b 45 08             	mov    0x8(%ebp),%eax
80101e4b:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e51:	8b 55 08             	mov    0x8(%ebp),%edx
80101e54:	8b 12                	mov    (%edx),%edx
80101e56:	83 ec 08             	sub    $0x8,%esp
80101e59:	50                   	push   %eax
80101e5a:	52                   	push   %edx
80101e5b:	e8 43 f7 ff ff       	call   801015a3 <bfree>
80101e60:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e63:	8b 45 08             	mov    0x8(%ebp),%eax
80101e66:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101e6d:	00 00 00 
  }

  ip->size = 0;
80101e70:	8b 45 08             	mov    0x8(%ebp),%eax
80101e73:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101e7a:	83 ec 0c             	sub    $0xc,%esp
80101e7d:	ff 75 08             	push   0x8(%ebp)
80101e80:	e8 83 f9 ff ff       	call   80101808 <iupdate>
80101e85:	83 c4 10             	add    $0x10,%esp
}
80101e88:	90                   	nop
80101e89:	c9                   	leave  
80101e8a:	c3                   	ret    

80101e8b <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101e8b:	55                   	push   %ebp
80101e8c:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e91:	8b 00                	mov    (%eax),%eax
80101e93:	89 c2                	mov    %eax,%edx
80101e95:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e98:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101e9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e9e:	8b 50 04             	mov    0x4(%eax),%edx
80101ea1:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ea4:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101ea7:	8b 45 08             	mov    0x8(%ebp),%eax
80101eaa:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101eae:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb1:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101eb4:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb7:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101ebb:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ebe:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ec2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec5:	8b 50 58             	mov    0x58(%eax),%edx
80101ec8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ecb:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ece:	90                   	nop
80101ecf:	5d                   	pop    %ebp
80101ed0:	c3                   	ret    

80101ed1 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ed1:	55                   	push   %ebp
80101ed2:	89 e5                	mov    %esp,%ebp
80101ed4:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ed7:	8b 45 08             	mov    0x8(%ebp),%eax
80101eda:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ede:	66 83 f8 03          	cmp    $0x3,%ax
80101ee2:	75 5c                	jne    80101f40 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101ee4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee7:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101eeb:	66 85 c0             	test   %ax,%ax
80101eee:	78 20                	js     80101f10 <readi+0x3f>
80101ef0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef3:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101ef7:	66 83 f8 09          	cmp    $0x9,%ax
80101efb:	7f 13                	jg     80101f10 <readi+0x3f>
80101efd:	8b 45 08             	mov    0x8(%ebp),%eax
80101f00:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f04:	98                   	cwtl   
80101f05:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f0c:	85 c0                	test   %eax,%eax
80101f0e:	75 0a                	jne    80101f1a <readi+0x49>
      return -1;
80101f10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f15:	e9 0a 01 00 00       	jmp    80102024 <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f1d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f21:	98                   	cwtl   
80101f22:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f29:	8b 55 14             	mov    0x14(%ebp),%edx
80101f2c:	83 ec 04             	sub    $0x4,%esp
80101f2f:	52                   	push   %edx
80101f30:	ff 75 0c             	push   0xc(%ebp)
80101f33:	ff 75 08             	push   0x8(%ebp)
80101f36:	ff d0                	call   *%eax
80101f38:	83 c4 10             	add    $0x10,%esp
80101f3b:	e9 e4 00 00 00       	jmp    80102024 <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80101f40:	8b 45 08             	mov    0x8(%ebp),%eax
80101f43:	8b 40 58             	mov    0x58(%eax),%eax
80101f46:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f49:	77 0d                	ja     80101f58 <readi+0x87>
80101f4b:	8b 55 10             	mov    0x10(%ebp),%edx
80101f4e:	8b 45 14             	mov    0x14(%ebp),%eax
80101f51:	01 d0                	add    %edx,%eax
80101f53:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f56:	76 0a                	jbe    80101f62 <readi+0x91>
    return -1;
80101f58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f5d:	e9 c2 00 00 00       	jmp    80102024 <readi+0x153>
  if(off + n > ip->size)
80101f62:	8b 55 10             	mov    0x10(%ebp),%edx
80101f65:	8b 45 14             	mov    0x14(%ebp),%eax
80101f68:	01 c2                	add    %eax,%edx
80101f6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f6d:	8b 40 58             	mov    0x58(%eax),%eax
80101f70:	39 c2                	cmp    %eax,%edx
80101f72:	76 0c                	jbe    80101f80 <readi+0xaf>
    n = ip->size - off;
80101f74:	8b 45 08             	mov    0x8(%ebp),%eax
80101f77:	8b 40 58             	mov    0x58(%eax),%eax
80101f7a:	2b 45 10             	sub    0x10(%ebp),%eax
80101f7d:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f80:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f87:	e9 89 00 00 00       	jmp    80102015 <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f8c:	8b 45 10             	mov    0x10(%ebp),%eax
80101f8f:	c1 e8 09             	shr    $0x9,%eax
80101f92:	83 ec 08             	sub    $0x8,%esp
80101f95:	50                   	push   %eax
80101f96:	ff 75 08             	push   0x8(%ebp)
80101f99:	e8 9d fc ff ff       	call   80101c3b <bmap>
80101f9e:	83 c4 10             	add    $0x10,%esp
80101fa1:	8b 55 08             	mov    0x8(%ebp),%edx
80101fa4:	8b 12                	mov    (%edx),%edx
80101fa6:	83 ec 08             	sub    $0x8,%esp
80101fa9:	50                   	push   %eax
80101faa:	52                   	push   %edx
80101fab:	e8 51 e2 ff ff       	call   80100201 <bread>
80101fb0:	83 c4 10             	add    $0x10,%esp
80101fb3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fb6:	8b 45 10             	mov    0x10(%ebp),%eax
80101fb9:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fbe:	ba 00 02 00 00       	mov    $0x200,%edx
80101fc3:	29 c2                	sub    %eax,%edx
80101fc5:	8b 45 14             	mov    0x14(%ebp),%eax
80101fc8:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fcb:	39 c2                	cmp    %eax,%edx
80101fcd:	0f 46 c2             	cmovbe %edx,%eax
80101fd0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fd6:	8d 50 5c             	lea    0x5c(%eax),%edx
80101fd9:	8b 45 10             	mov    0x10(%ebp),%eax
80101fdc:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fe1:	01 d0                	add    %edx,%eax
80101fe3:	83 ec 04             	sub    $0x4,%esp
80101fe6:	ff 75 ec             	push   -0x14(%ebp)
80101fe9:	50                   	push   %eax
80101fea:	ff 75 0c             	push   0xc(%ebp)
80101fed:	e8 79 2b 00 00       	call   80104b6b <memmove>
80101ff2:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ff5:	83 ec 0c             	sub    $0xc,%esp
80101ff8:	ff 75 f0             	push   -0x10(%ebp)
80101ffb:	e8 83 e2 ff ff       	call   80100283 <brelse>
80102000:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102003:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102006:	01 45 f4             	add    %eax,-0xc(%ebp)
80102009:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010200c:	01 45 10             	add    %eax,0x10(%ebp)
8010200f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102012:	01 45 0c             	add    %eax,0xc(%ebp)
80102015:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102018:	3b 45 14             	cmp    0x14(%ebp),%eax
8010201b:	0f 82 6b ff ff ff    	jb     80101f8c <readi+0xbb>
  }
  return n;
80102021:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102024:	c9                   	leave  
80102025:	c3                   	ret    

80102026 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102026:	55                   	push   %ebp
80102027:	89 e5                	mov    %esp,%ebp
80102029:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010202c:	8b 45 08             	mov    0x8(%ebp),%eax
8010202f:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102033:	66 83 f8 03          	cmp    $0x3,%ax
80102037:	75 5c                	jne    80102095 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102039:	8b 45 08             	mov    0x8(%ebp),%eax
8010203c:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102040:	66 85 c0             	test   %ax,%ax
80102043:	78 20                	js     80102065 <writei+0x3f>
80102045:	8b 45 08             	mov    0x8(%ebp),%eax
80102048:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010204c:	66 83 f8 09          	cmp    $0x9,%ax
80102050:	7f 13                	jg     80102065 <writei+0x3f>
80102052:	8b 45 08             	mov    0x8(%ebp),%eax
80102055:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102059:	98                   	cwtl   
8010205a:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
80102061:	85 c0                	test   %eax,%eax
80102063:	75 0a                	jne    8010206f <writei+0x49>
      return -1;
80102065:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010206a:	e9 3b 01 00 00       	jmp    801021aa <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
8010206f:	8b 45 08             	mov    0x8(%ebp),%eax
80102072:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102076:	98                   	cwtl   
80102077:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
8010207e:	8b 55 14             	mov    0x14(%ebp),%edx
80102081:	83 ec 04             	sub    $0x4,%esp
80102084:	52                   	push   %edx
80102085:	ff 75 0c             	push   0xc(%ebp)
80102088:	ff 75 08             	push   0x8(%ebp)
8010208b:	ff d0                	call   *%eax
8010208d:	83 c4 10             	add    $0x10,%esp
80102090:	e9 15 01 00 00       	jmp    801021aa <writei+0x184>
  }

  if(off > ip->size || off + n < off)
80102095:	8b 45 08             	mov    0x8(%ebp),%eax
80102098:	8b 40 58             	mov    0x58(%eax),%eax
8010209b:	39 45 10             	cmp    %eax,0x10(%ebp)
8010209e:	77 0d                	ja     801020ad <writei+0x87>
801020a0:	8b 55 10             	mov    0x10(%ebp),%edx
801020a3:	8b 45 14             	mov    0x14(%ebp),%eax
801020a6:	01 d0                	add    %edx,%eax
801020a8:	39 45 10             	cmp    %eax,0x10(%ebp)
801020ab:	76 0a                	jbe    801020b7 <writei+0x91>
    return -1;
801020ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020b2:	e9 f3 00 00 00       	jmp    801021aa <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
801020b7:	8b 55 10             	mov    0x10(%ebp),%edx
801020ba:	8b 45 14             	mov    0x14(%ebp),%eax
801020bd:	01 d0                	add    %edx,%eax
801020bf:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020c4:	76 0a                	jbe    801020d0 <writei+0xaa>
    return -1;
801020c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020cb:	e9 da 00 00 00       	jmp    801021aa <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020d7:	e9 97 00 00 00       	jmp    80102173 <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020dc:	8b 45 10             	mov    0x10(%ebp),%eax
801020df:	c1 e8 09             	shr    $0x9,%eax
801020e2:	83 ec 08             	sub    $0x8,%esp
801020e5:	50                   	push   %eax
801020e6:	ff 75 08             	push   0x8(%ebp)
801020e9:	e8 4d fb ff ff       	call   80101c3b <bmap>
801020ee:	83 c4 10             	add    $0x10,%esp
801020f1:	8b 55 08             	mov    0x8(%ebp),%edx
801020f4:	8b 12                	mov    (%edx),%edx
801020f6:	83 ec 08             	sub    $0x8,%esp
801020f9:	50                   	push   %eax
801020fa:	52                   	push   %edx
801020fb:	e8 01 e1 ff ff       	call   80100201 <bread>
80102100:	83 c4 10             	add    $0x10,%esp
80102103:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102106:	8b 45 10             	mov    0x10(%ebp),%eax
80102109:	25 ff 01 00 00       	and    $0x1ff,%eax
8010210e:	ba 00 02 00 00       	mov    $0x200,%edx
80102113:	29 c2                	sub    %eax,%edx
80102115:	8b 45 14             	mov    0x14(%ebp),%eax
80102118:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010211b:	39 c2                	cmp    %eax,%edx
8010211d:	0f 46 c2             	cmovbe %edx,%eax
80102120:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102123:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102126:	8d 50 5c             	lea    0x5c(%eax),%edx
80102129:	8b 45 10             	mov    0x10(%ebp),%eax
8010212c:	25 ff 01 00 00       	and    $0x1ff,%eax
80102131:	01 d0                	add    %edx,%eax
80102133:	83 ec 04             	sub    $0x4,%esp
80102136:	ff 75 ec             	push   -0x14(%ebp)
80102139:	ff 75 0c             	push   0xc(%ebp)
8010213c:	50                   	push   %eax
8010213d:	e8 29 2a 00 00       	call   80104b6b <memmove>
80102142:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102145:	83 ec 0c             	sub    $0xc,%esp
80102148:	ff 75 f0             	push   -0x10(%ebp)
8010214b:	e8 20 11 00 00       	call   80103270 <log_write>
80102150:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102153:	83 ec 0c             	sub    $0xc,%esp
80102156:	ff 75 f0             	push   -0x10(%ebp)
80102159:	e8 25 e1 ff ff       	call   80100283 <brelse>
8010215e:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102161:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102164:	01 45 f4             	add    %eax,-0xc(%ebp)
80102167:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010216a:	01 45 10             	add    %eax,0x10(%ebp)
8010216d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102170:	01 45 0c             	add    %eax,0xc(%ebp)
80102173:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102176:	3b 45 14             	cmp    0x14(%ebp),%eax
80102179:	0f 82 5d ff ff ff    	jb     801020dc <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
8010217f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102183:	74 22                	je     801021a7 <writei+0x181>
80102185:	8b 45 08             	mov    0x8(%ebp),%eax
80102188:	8b 40 58             	mov    0x58(%eax),%eax
8010218b:	39 45 10             	cmp    %eax,0x10(%ebp)
8010218e:	76 17                	jbe    801021a7 <writei+0x181>
    ip->size = off;
80102190:	8b 45 08             	mov    0x8(%ebp),%eax
80102193:	8b 55 10             	mov    0x10(%ebp),%edx
80102196:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
80102199:	83 ec 0c             	sub    $0xc,%esp
8010219c:	ff 75 08             	push   0x8(%ebp)
8010219f:	e8 64 f6 ff ff       	call   80101808 <iupdate>
801021a4:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021a7:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021aa:	c9                   	leave  
801021ab:	c3                   	ret    

801021ac <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021ac:	55                   	push   %ebp
801021ad:	89 e5                	mov    %esp,%ebp
801021af:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021b2:	83 ec 04             	sub    $0x4,%esp
801021b5:	6a 0e                	push   $0xe
801021b7:	ff 75 0c             	push   0xc(%ebp)
801021ba:	ff 75 08             	push   0x8(%ebp)
801021bd:	e8 3f 2a 00 00       	call   80104c01 <strncmp>
801021c2:	83 c4 10             	add    $0x10,%esp
}
801021c5:	c9                   	leave  
801021c6:	c3                   	ret    

801021c7 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021c7:	55                   	push   %ebp
801021c8:	89 e5                	mov    %esp,%ebp
801021ca:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021cd:	8b 45 08             	mov    0x8(%ebp),%eax
801021d0:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801021d4:	66 83 f8 01          	cmp    $0x1,%ax
801021d8:	74 0d                	je     801021e7 <dirlookup+0x20>
    panic("dirlookup not DIR");
801021da:	83 ec 0c             	sub    $0xc,%esp
801021dd:	68 bd a2 10 80       	push   $0x8010a2bd
801021e2:	e8 c2 e3 ff ff       	call   801005a9 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021e7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021ee:	eb 7b                	jmp    8010226b <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021f0:	6a 10                	push   $0x10
801021f2:	ff 75 f4             	push   -0xc(%ebp)
801021f5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021f8:	50                   	push   %eax
801021f9:	ff 75 08             	push   0x8(%ebp)
801021fc:	e8 d0 fc ff ff       	call   80101ed1 <readi>
80102201:	83 c4 10             	add    $0x10,%esp
80102204:	83 f8 10             	cmp    $0x10,%eax
80102207:	74 0d                	je     80102216 <dirlookup+0x4f>
      panic("dirlookup read");
80102209:	83 ec 0c             	sub    $0xc,%esp
8010220c:	68 cf a2 10 80       	push   $0x8010a2cf
80102211:	e8 93 e3 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
80102216:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010221a:	66 85 c0             	test   %ax,%ax
8010221d:	74 47                	je     80102266 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
8010221f:	83 ec 08             	sub    $0x8,%esp
80102222:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102225:	83 c0 02             	add    $0x2,%eax
80102228:	50                   	push   %eax
80102229:	ff 75 0c             	push   0xc(%ebp)
8010222c:	e8 7b ff ff ff       	call   801021ac <namecmp>
80102231:	83 c4 10             	add    $0x10,%esp
80102234:	85 c0                	test   %eax,%eax
80102236:	75 2f                	jne    80102267 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
80102238:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010223c:	74 08                	je     80102246 <dirlookup+0x7f>
        *poff = off;
8010223e:	8b 45 10             	mov    0x10(%ebp),%eax
80102241:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102244:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102246:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010224a:	0f b7 c0             	movzwl %ax,%eax
8010224d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102250:	8b 45 08             	mov    0x8(%ebp),%eax
80102253:	8b 00                	mov    (%eax),%eax
80102255:	83 ec 08             	sub    $0x8,%esp
80102258:	ff 75 f0             	push   -0x10(%ebp)
8010225b:	50                   	push   %eax
8010225c:	e8 68 f6 ff ff       	call   801018c9 <iget>
80102261:	83 c4 10             	add    $0x10,%esp
80102264:	eb 19                	jmp    8010227f <dirlookup+0xb8>
      continue;
80102266:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
80102267:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010226b:	8b 45 08             	mov    0x8(%ebp),%eax
8010226e:	8b 40 58             	mov    0x58(%eax),%eax
80102271:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102274:	0f 82 76 ff ff ff    	jb     801021f0 <dirlookup+0x29>
    }
  }

  return 0;
8010227a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010227f:	c9                   	leave  
80102280:	c3                   	ret    

80102281 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102281:	55                   	push   %ebp
80102282:	89 e5                	mov    %esp,%ebp
80102284:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102287:	83 ec 04             	sub    $0x4,%esp
8010228a:	6a 00                	push   $0x0
8010228c:	ff 75 0c             	push   0xc(%ebp)
8010228f:	ff 75 08             	push   0x8(%ebp)
80102292:	e8 30 ff ff ff       	call   801021c7 <dirlookup>
80102297:	83 c4 10             	add    $0x10,%esp
8010229a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010229d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022a1:	74 18                	je     801022bb <dirlink+0x3a>
    iput(ip);
801022a3:	83 ec 0c             	sub    $0xc,%esp
801022a6:	ff 75 f0             	push   -0x10(%ebp)
801022a9:	e8 98 f8 ff ff       	call   80101b46 <iput>
801022ae:	83 c4 10             	add    $0x10,%esp
    return -1;
801022b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022b6:	e9 9c 00 00 00       	jmp    80102357 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022bb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022c2:	eb 39                	jmp    801022fd <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022c7:	6a 10                	push   $0x10
801022c9:	50                   	push   %eax
801022ca:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022cd:	50                   	push   %eax
801022ce:	ff 75 08             	push   0x8(%ebp)
801022d1:	e8 fb fb ff ff       	call   80101ed1 <readi>
801022d6:	83 c4 10             	add    $0x10,%esp
801022d9:	83 f8 10             	cmp    $0x10,%eax
801022dc:	74 0d                	je     801022eb <dirlink+0x6a>
      panic("dirlink read");
801022de:	83 ec 0c             	sub    $0xc,%esp
801022e1:	68 de a2 10 80       	push   $0x8010a2de
801022e6:	e8 be e2 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
801022eb:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022ef:	66 85 c0             	test   %ax,%ax
801022f2:	74 18                	je     8010230c <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
801022f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022f7:	83 c0 10             	add    $0x10,%eax
801022fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
801022fd:	8b 45 08             	mov    0x8(%ebp),%eax
80102300:	8b 50 58             	mov    0x58(%eax),%edx
80102303:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102306:	39 c2                	cmp    %eax,%edx
80102308:	77 ba                	ja     801022c4 <dirlink+0x43>
8010230a:	eb 01                	jmp    8010230d <dirlink+0x8c>
      break;
8010230c:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
8010230d:	83 ec 04             	sub    $0x4,%esp
80102310:	6a 0e                	push   $0xe
80102312:	ff 75 0c             	push   0xc(%ebp)
80102315:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102318:	83 c0 02             	add    $0x2,%eax
8010231b:	50                   	push   %eax
8010231c:	e8 36 29 00 00       	call   80104c57 <strncpy>
80102321:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102324:	8b 45 10             	mov    0x10(%ebp),%eax
80102327:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010232b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010232e:	6a 10                	push   $0x10
80102330:	50                   	push   %eax
80102331:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102334:	50                   	push   %eax
80102335:	ff 75 08             	push   0x8(%ebp)
80102338:	e8 e9 fc ff ff       	call   80102026 <writei>
8010233d:	83 c4 10             	add    $0x10,%esp
80102340:	83 f8 10             	cmp    $0x10,%eax
80102343:	74 0d                	je     80102352 <dirlink+0xd1>
    panic("dirlink");
80102345:	83 ec 0c             	sub    $0xc,%esp
80102348:	68 eb a2 10 80       	push   $0x8010a2eb
8010234d:	e8 57 e2 ff ff       	call   801005a9 <panic>

  return 0;
80102352:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102357:	c9                   	leave  
80102358:	c3                   	ret    

80102359 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102359:	55                   	push   %ebp
8010235a:	89 e5                	mov    %esp,%ebp
8010235c:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010235f:	eb 04                	jmp    80102365 <skipelem+0xc>
    path++;
80102361:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102365:	8b 45 08             	mov    0x8(%ebp),%eax
80102368:	0f b6 00             	movzbl (%eax),%eax
8010236b:	3c 2f                	cmp    $0x2f,%al
8010236d:	74 f2                	je     80102361 <skipelem+0x8>
  if(*path == 0)
8010236f:	8b 45 08             	mov    0x8(%ebp),%eax
80102372:	0f b6 00             	movzbl (%eax),%eax
80102375:	84 c0                	test   %al,%al
80102377:	75 07                	jne    80102380 <skipelem+0x27>
    return 0;
80102379:	b8 00 00 00 00       	mov    $0x0,%eax
8010237e:	eb 77                	jmp    801023f7 <skipelem+0x9e>
  s = path;
80102380:	8b 45 08             	mov    0x8(%ebp),%eax
80102383:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102386:	eb 04                	jmp    8010238c <skipelem+0x33>
    path++;
80102388:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
8010238c:	8b 45 08             	mov    0x8(%ebp),%eax
8010238f:	0f b6 00             	movzbl (%eax),%eax
80102392:	3c 2f                	cmp    $0x2f,%al
80102394:	74 0a                	je     801023a0 <skipelem+0x47>
80102396:	8b 45 08             	mov    0x8(%ebp),%eax
80102399:	0f b6 00             	movzbl (%eax),%eax
8010239c:	84 c0                	test   %al,%al
8010239e:	75 e8                	jne    80102388 <skipelem+0x2f>
  len = path - s;
801023a0:	8b 45 08             	mov    0x8(%ebp),%eax
801023a3:	2b 45 f4             	sub    -0xc(%ebp),%eax
801023a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023a9:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023ad:	7e 15                	jle    801023c4 <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
801023af:	83 ec 04             	sub    $0x4,%esp
801023b2:	6a 0e                	push   $0xe
801023b4:	ff 75 f4             	push   -0xc(%ebp)
801023b7:	ff 75 0c             	push   0xc(%ebp)
801023ba:	e8 ac 27 00 00       	call   80104b6b <memmove>
801023bf:	83 c4 10             	add    $0x10,%esp
801023c2:	eb 26                	jmp    801023ea <skipelem+0x91>
  else {
    memmove(name, s, len);
801023c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023c7:	83 ec 04             	sub    $0x4,%esp
801023ca:	50                   	push   %eax
801023cb:	ff 75 f4             	push   -0xc(%ebp)
801023ce:	ff 75 0c             	push   0xc(%ebp)
801023d1:	e8 95 27 00 00       	call   80104b6b <memmove>
801023d6:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023d9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023dc:	8b 45 0c             	mov    0xc(%ebp),%eax
801023df:	01 d0                	add    %edx,%eax
801023e1:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023e4:	eb 04                	jmp    801023ea <skipelem+0x91>
    path++;
801023e6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801023ea:	8b 45 08             	mov    0x8(%ebp),%eax
801023ed:	0f b6 00             	movzbl (%eax),%eax
801023f0:	3c 2f                	cmp    $0x2f,%al
801023f2:	74 f2                	je     801023e6 <skipelem+0x8d>
  return path;
801023f4:	8b 45 08             	mov    0x8(%ebp),%eax
}
801023f7:	c9                   	leave  
801023f8:	c3                   	ret    

801023f9 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801023f9:	55                   	push   %ebp
801023fa:	89 e5                	mov    %esp,%ebp
801023fc:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801023ff:	8b 45 08             	mov    0x8(%ebp),%eax
80102402:	0f b6 00             	movzbl (%eax),%eax
80102405:	3c 2f                	cmp    $0x2f,%al
80102407:	75 17                	jne    80102420 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
80102409:	83 ec 08             	sub    $0x8,%esp
8010240c:	6a 01                	push   $0x1
8010240e:	6a 01                	push   $0x1
80102410:	e8 b4 f4 ff ff       	call   801018c9 <iget>
80102415:	83 c4 10             	add    $0x10,%esp
80102418:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010241b:	e9 ba 00 00 00       	jmp    801024da <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
80102420:	e8 06 16 00 00       	call   80103a2b <myproc>
80102425:	8b 40 68             	mov    0x68(%eax),%eax
80102428:	83 ec 0c             	sub    $0xc,%esp
8010242b:	50                   	push   %eax
8010242c:	e8 7a f5 ff ff       	call   801019ab <idup>
80102431:	83 c4 10             	add    $0x10,%esp
80102434:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102437:	e9 9e 00 00 00       	jmp    801024da <namex+0xe1>
    ilock(ip);
8010243c:	83 ec 0c             	sub    $0xc,%esp
8010243f:	ff 75 f4             	push   -0xc(%ebp)
80102442:	e8 9e f5 ff ff       	call   801019e5 <ilock>
80102447:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010244a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010244d:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102451:	66 83 f8 01          	cmp    $0x1,%ax
80102455:	74 18                	je     8010246f <namex+0x76>
      iunlockput(ip);
80102457:	83 ec 0c             	sub    $0xc,%esp
8010245a:	ff 75 f4             	push   -0xc(%ebp)
8010245d:	e8 b4 f7 ff ff       	call   80101c16 <iunlockput>
80102462:	83 c4 10             	add    $0x10,%esp
      return 0;
80102465:	b8 00 00 00 00       	mov    $0x0,%eax
8010246a:	e9 a7 00 00 00       	jmp    80102516 <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
8010246f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102473:	74 20                	je     80102495 <namex+0x9c>
80102475:	8b 45 08             	mov    0x8(%ebp),%eax
80102478:	0f b6 00             	movzbl (%eax),%eax
8010247b:	84 c0                	test   %al,%al
8010247d:	75 16                	jne    80102495 <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
8010247f:	83 ec 0c             	sub    $0xc,%esp
80102482:	ff 75 f4             	push   -0xc(%ebp)
80102485:	e8 6e f6 ff ff       	call   80101af8 <iunlock>
8010248a:	83 c4 10             	add    $0x10,%esp
      return ip;
8010248d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102490:	e9 81 00 00 00       	jmp    80102516 <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102495:	83 ec 04             	sub    $0x4,%esp
80102498:	6a 00                	push   $0x0
8010249a:	ff 75 10             	push   0x10(%ebp)
8010249d:	ff 75 f4             	push   -0xc(%ebp)
801024a0:	e8 22 fd ff ff       	call   801021c7 <dirlookup>
801024a5:	83 c4 10             	add    $0x10,%esp
801024a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024ab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024af:	75 15                	jne    801024c6 <namex+0xcd>
      iunlockput(ip);
801024b1:	83 ec 0c             	sub    $0xc,%esp
801024b4:	ff 75 f4             	push   -0xc(%ebp)
801024b7:	e8 5a f7 ff ff       	call   80101c16 <iunlockput>
801024bc:	83 c4 10             	add    $0x10,%esp
      return 0;
801024bf:	b8 00 00 00 00       	mov    $0x0,%eax
801024c4:	eb 50                	jmp    80102516 <namex+0x11d>
    }
    iunlockput(ip);
801024c6:	83 ec 0c             	sub    $0xc,%esp
801024c9:	ff 75 f4             	push   -0xc(%ebp)
801024cc:	e8 45 f7 ff ff       	call   80101c16 <iunlockput>
801024d1:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801024da:	83 ec 08             	sub    $0x8,%esp
801024dd:	ff 75 10             	push   0x10(%ebp)
801024e0:	ff 75 08             	push   0x8(%ebp)
801024e3:	e8 71 fe ff ff       	call   80102359 <skipelem>
801024e8:	83 c4 10             	add    $0x10,%esp
801024eb:	89 45 08             	mov    %eax,0x8(%ebp)
801024ee:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024f2:	0f 85 44 ff ff ff    	jne    8010243c <namex+0x43>
  }
  if(nameiparent){
801024f8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801024fc:	74 15                	je     80102513 <namex+0x11a>
    iput(ip);
801024fe:	83 ec 0c             	sub    $0xc,%esp
80102501:	ff 75 f4             	push   -0xc(%ebp)
80102504:	e8 3d f6 ff ff       	call   80101b46 <iput>
80102509:	83 c4 10             	add    $0x10,%esp
    return 0;
8010250c:	b8 00 00 00 00       	mov    $0x0,%eax
80102511:	eb 03                	jmp    80102516 <namex+0x11d>
  }
  return ip;
80102513:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102516:	c9                   	leave  
80102517:	c3                   	ret    

80102518 <namei>:

struct inode*
namei(char *path)
{
80102518:	55                   	push   %ebp
80102519:	89 e5                	mov    %esp,%ebp
8010251b:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010251e:	83 ec 04             	sub    $0x4,%esp
80102521:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102524:	50                   	push   %eax
80102525:	6a 00                	push   $0x0
80102527:	ff 75 08             	push   0x8(%ebp)
8010252a:	e8 ca fe ff ff       	call   801023f9 <namex>
8010252f:	83 c4 10             	add    $0x10,%esp
}
80102532:	c9                   	leave  
80102533:	c3                   	ret    

80102534 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102534:	55                   	push   %ebp
80102535:	89 e5                	mov    %esp,%ebp
80102537:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010253a:	83 ec 04             	sub    $0x4,%esp
8010253d:	ff 75 0c             	push   0xc(%ebp)
80102540:	6a 01                	push   $0x1
80102542:	ff 75 08             	push   0x8(%ebp)
80102545:	e8 af fe ff ff       	call   801023f9 <namex>
8010254a:	83 c4 10             	add    $0x10,%esp
}
8010254d:	c9                   	leave  
8010254e:	c3                   	ret    

8010254f <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
8010254f:	55                   	push   %ebp
80102550:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102552:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102557:	8b 55 08             	mov    0x8(%ebp),%edx
8010255a:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
8010255c:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102561:	8b 40 10             	mov    0x10(%eax),%eax
}
80102564:	5d                   	pop    %ebp
80102565:	c3                   	ret    

80102566 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102566:	55                   	push   %ebp
80102567:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102569:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010256e:	8b 55 08             	mov    0x8(%ebp),%edx
80102571:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102573:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102578:	8b 55 0c             	mov    0xc(%ebp),%edx
8010257b:	89 50 10             	mov    %edx,0x10(%eax)
}
8010257e:	90                   	nop
8010257f:	5d                   	pop    %ebp
80102580:	c3                   	ret    

80102581 <ioapicinit>:

void
ioapicinit(void)
{
80102581:	55                   	push   %ebp
80102582:	89 e5                	mov    %esp,%ebp
80102584:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102587:	c7 05 b4 40 19 80 00 	movl   $0xfec00000,0x801940b4
8010258e:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102591:	6a 01                	push   $0x1
80102593:	e8 b7 ff ff ff       	call   8010254f <ioapicread>
80102598:	83 c4 04             	add    $0x4,%esp
8010259b:	c1 e8 10             	shr    $0x10,%eax
8010259e:	25 ff 00 00 00       	and    $0xff,%eax
801025a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801025a6:	6a 00                	push   $0x0
801025a8:	e8 a2 ff ff ff       	call   8010254f <ioapicread>
801025ad:	83 c4 04             	add    $0x4,%esp
801025b0:	c1 e8 18             	shr    $0x18,%eax
801025b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801025b6:	0f b6 05 44 6d 19 80 	movzbl 0x80196d44,%eax
801025bd:	0f b6 c0             	movzbl %al,%eax
801025c0:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801025c3:	74 10                	je     801025d5 <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801025c5:	83 ec 0c             	sub    $0xc,%esp
801025c8:	68 f4 a2 10 80       	push   $0x8010a2f4
801025cd:	e8 22 de ff ff       	call   801003f4 <cprintf>
801025d2:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801025d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025dc:	eb 3f                	jmp    8010261d <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801025de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025e1:	83 c0 20             	add    $0x20,%eax
801025e4:	0d 00 00 01 00       	or     $0x10000,%eax
801025e9:	89 c2                	mov    %eax,%edx
801025eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025ee:	83 c0 08             	add    $0x8,%eax
801025f1:	01 c0                	add    %eax,%eax
801025f3:	83 ec 08             	sub    $0x8,%esp
801025f6:	52                   	push   %edx
801025f7:	50                   	push   %eax
801025f8:	e8 69 ff ff ff       	call   80102566 <ioapicwrite>
801025fd:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102600:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102603:	83 c0 08             	add    $0x8,%eax
80102606:	01 c0                	add    %eax,%eax
80102608:	83 c0 01             	add    $0x1,%eax
8010260b:	83 ec 08             	sub    $0x8,%esp
8010260e:	6a 00                	push   $0x0
80102610:	50                   	push   %eax
80102611:	e8 50 ff ff ff       	call   80102566 <ioapicwrite>
80102616:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102619:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010261d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102620:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102623:	7e b9                	jle    801025de <ioapicinit+0x5d>
  }
}
80102625:	90                   	nop
80102626:	90                   	nop
80102627:	c9                   	leave  
80102628:	c3                   	ret    

80102629 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102629:	55                   	push   %ebp
8010262a:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
8010262c:	8b 45 08             	mov    0x8(%ebp),%eax
8010262f:	83 c0 20             	add    $0x20,%eax
80102632:	89 c2                	mov    %eax,%edx
80102634:	8b 45 08             	mov    0x8(%ebp),%eax
80102637:	83 c0 08             	add    $0x8,%eax
8010263a:	01 c0                	add    %eax,%eax
8010263c:	52                   	push   %edx
8010263d:	50                   	push   %eax
8010263e:	e8 23 ff ff ff       	call   80102566 <ioapicwrite>
80102643:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102646:	8b 45 0c             	mov    0xc(%ebp),%eax
80102649:	c1 e0 18             	shl    $0x18,%eax
8010264c:	89 c2                	mov    %eax,%edx
8010264e:	8b 45 08             	mov    0x8(%ebp),%eax
80102651:	83 c0 08             	add    $0x8,%eax
80102654:	01 c0                	add    %eax,%eax
80102656:	83 c0 01             	add    $0x1,%eax
80102659:	52                   	push   %edx
8010265a:	50                   	push   %eax
8010265b:	e8 06 ff ff ff       	call   80102566 <ioapicwrite>
80102660:	83 c4 08             	add    $0x8,%esp
}
80102663:	90                   	nop
80102664:	c9                   	leave  
80102665:	c3                   	ret    

80102666 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102666:	55                   	push   %ebp
80102667:	89 e5                	mov    %esp,%ebp
80102669:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
8010266c:	83 ec 08             	sub    $0x8,%esp
8010266f:	68 26 a3 10 80       	push   $0x8010a326
80102674:	68 c0 40 19 80       	push   $0x801940c0
80102679:	e8 96 21 00 00       	call   80104814 <initlock>
8010267e:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102681:	c7 05 f4 40 19 80 00 	movl   $0x0,0x801940f4
80102688:	00 00 00 
  freerange(vstart, vend);
8010268b:	83 ec 08             	sub    $0x8,%esp
8010268e:	ff 75 0c             	push   0xc(%ebp)
80102691:	ff 75 08             	push   0x8(%ebp)
80102694:	e8 2a 00 00 00       	call   801026c3 <freerange>
80102699:	83 c4 10             	add    $0x10,%esp
}
8010269c:	90                   	nop
8010269d:	c9                   	leave  
8010269e:	c3                   	ret    

8010269f <kinit2>:

void
kinit2(void *vstart, void *vend)
{
8010269f:	55                   	push   %ebp
801026a0:	89 e5                	mov    %esp,%ebp
801026a2:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
801026a5:	83 ec 08             	sub    $0x8,%esp
801026a8:	ff 75 0c             	push   0xc(%ebp)
801026ab:	ff 75 08             	push   0x8(%ebp)
801026ae:	e8 10 00 00 00       	call   801026c3 <freerange>
801026b3:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
801026b6:	c7 05 f4 40 19 80 01 	movl   $0x1,0x801940f4
801026bd:	00 00 00 
}
801026c0:	90                   	nop
801026c1:	c9                   	leave  
801026c2:	c3                   	ret    

801026c3 <freerange>:

void
freerange(void *vstart, void *vend)
{
801026c3:	55                   	push   %ebp
801026c4:	89 e5                	mov    %esp,%ebp
801026c6:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801026c9:	8b 45 08             	mov    0x8(%ebp),%eax
801026cc:	05 ff 0f 00 00       	add    $0xfff,%eax
801026d1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801026d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026d9:	eb 15                	jmp    801026f0 <freerange+0x2d>
    kfree(p);
801026db:	83 ec 0c             	sub    $0xc,%esp
801026de:	ff 75 f4             	push   -0xc(%ebp)
801026e1:	e8 1b 00 00 00       	call   80102701 <kfree>
801026e6:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026e9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801026f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026f3:	05 00 10 00 00       	add    $0x1000,%eax
801026f8:	39 45 0c             	cmp    %eax,0xc(%ebp)
801026fb:	73 de                	jae    801026db <freerange+0x18>
}
801026fd:	90                   	nop
801026fe:	90                   	nop
801026ff:	c9                   	leave  
80102700:	c3                   	ret    

80102701 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102701:	55                   	push   %ebp
80102702:	89 e5                	mov    %esp,%ebp
80102704:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102707:	8b 45 08             	mov    0x8(%ebp),%eax
8010270a:	25 ff 0f 00 00       	and    $0xfff,%eax
8010270f:	85 c0                	test   %eax,%eax
80102711:	75 18                	jne    8010272b <kfree+0x2a>
80102713:	81 7d 08 00 90 19 80 	cmpl   $0x80199000,0x8(%ebp)
8010271a:	72 0f                	jb     8010272b <kfree+0x2a>
8010271c:	8b 45 08             	mov    0x8(%ebp),%eax
8010271f:	05 00 00 00 80       	add    $0x80000000,%eax
80102724:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
80102729:	76 0d                	jbe    80102738 <kfree+0x37>
    panic("kfree");
8010272b:	83 ec 0c             	sub    $0xc,%esp
8010272e:	68 2b a3 10 80       	push   $0x8010a32b
80102733:	e8 71 de ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102738:	83 ec 04             	sub    $0x4,%esp
8010273b:	68 00 10 00 00       	push   $0x1000
80102740:	6a 01                	push   $0x1
80102742:	ff 75 08             	push   0x8(%ebp)
80102745:	e8 62 23 00 00       	call   80104aac <memset>
8010274a:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
8010274d:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102752:	85 c0                	test   %eax,%eax
80102754:	74 10                	je     80102766 <kfree+0x65>
    acquire(&kmem.lock);
80102756:	83 ec 0c             	sub    $0xc,%esp
80102759:	68 c0 40 19 80       	push   $0x801940c0
8010275e:	e8 d3 20 00 00       	call   80104836 <acquire>
80102763:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102766:	8b 45 08             	mov    0x8(%ebp),%eax
80102769:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
8010276c:	8b 15 f8 40 19 80    	mov    0x801940f8,%edx
80102772:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102775:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010277a:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
8010277f:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102784:	85 c0                	test   %eax,%eax
80102786:	74 10                	je     80102798 <kfree+0x97>
    release(&kmem.lock);
80102788:	83 ec 0c             	sub    $0xc,%esp
8010278b:	68 c0 40 19 80       	push   $0x801940c0
80102790:	e8 0f 21 00 00       	call   801048a4 <release>
80102795:	83 c4 10             	add    $0x10,%esp
}
80102798:	90                   	nop
80102799:	c9                   	leave  
8010279a:	c3                   	ret    

8010279b <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
8010279b:	55                   	push   %ebp
8010279c:	89 e5                	mov    %esp,%ebp
8010279e:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
801027a1:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027a6:	85 c0                	test   %eax,%eax
801027a8:	74 10                	je     801027ba <kalloc+0x1f>
    acquire(&kmem.lock);
801027aa:	83 ec 0c             	sub    $0xc,%esp
801027ad:	68 c0 40 19 80       	push   $0x801940c0
801027b2:	e8 7f 20 00 00       	call   80104836 <acquire>
801027b7:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801027ba:	a1 f8 40 19 80       	mov    0x801940f8,%eax
801027bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801027c2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027c6:	74 0a                	je     801027d2 <kalloc+0x37>
    kmem.freelist = r->next;
801027c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027cb:	8b 00                	mov    (%eax),%eax
801027cd:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
801027d2:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027d7:	85 c0                	test   %eax,%eax
801027d9:	74 10                	je     801027eb <kalloc+0x50>
    release(&kmem.lock);
801027db:	83 ec 0c             	sub    $0xc,%esp
801027de:	68 c0 40 19 80       	push   $0x801940c0
801027e3:	e8 bc 20 00 00       	call   801048a4 <release>
801027e8:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801027eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801027ee:	c9                   	leave  
801027ef:	c3                   	ret    

801027f0 <inb>:
{
801027f0:	55                   	push   %ebp
801027f1:	89 e5                	mov    %esp,%ebp
801027f3:	83 ec 14             	sub    $0x14,%esp
801027f6:	8b 45 08             	mov    0x8(%ebp),%eax
801027f9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801027fd:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102801:	89 c2                	mov    %eax,%edx
80102803:	ec                   	in     (%dx),%al
80102804:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102807:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010280b:	c9                   	leave  
8010280c:	c3                   	ret    

8010280d <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
8010280d:	55                   	push   %ebp
8010280e:	89 e5                	mov    %esp,%ebp
80102810:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102813:	6a 64                	push   $0x64
80102815:	e8 d6 ff ff ff       	call   801027f0 <inb>
8010281a:	83 c4 04             	add    $0x4,%esp
8010281d:	0f b6 c0             	movzbl %al,%eax
80102820:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102823:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102826:	83 e0 01             	and    $0x1,%eax
80102829:	85 c0                	test   %eax,%eax
8010282b:	75 0a                	jne    80102837 <kbdgetc+0x2a>
    return -1;
8010282d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102832:	e9 23 01 00 00       	jmp    8010295a <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102837:	6a 60                	push   $0x60
80102839:	e8 b2 ff ff ff       	call   801027f0 <inb>
8010283e:	83 c4 04             	add    $0x4,%esp
80102841:	0f b6 c0             	movzbl %al,%eax
80102844:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102847:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
8010284e:	75 17                	jne    80102867 <kbdgetc+0x5a>
    shift |= E0ESC;
80102850:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102855:	83 c8 40             	or     $0x40,%eax
80102858:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
8010285d:	b8 00 00 00 00       	mov    $0x0,%eax
80102862:	e9 f3 00 00 00       	jmp    8010295a <kbdgetc+0x14d>
  } else if(data & 0x80){
80102867:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010286a:	25 80 00 00 00       	and    $0x80,%eax
8010286f:	85 c0                	test   %eax,%eax
80102871:	74 45                	je     801028b8 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102873:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102878:	83 e0 40             	and    $0x40,%eax
8010287b:	85 c0                	test   %eax,%eax
8010287d:	75 08                	jne    80102887 <kbdgetc+0x7a>
8010287f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102882:	83 e0 7f             	and    $0x7f,%eax
80102885:	eb 03                	jmp    8010288a <kbdgetc+0x7d>
80102887:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010288a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
8010288d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102890:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102895:	0f b6 00             	movzbl (%eax),%eax
80102898:	83 c8 40             	or     $0x40,%eax
8010289b:	0f b6 c0             	movzbl %al,%eax
8010289e:	f7 d0                	not    %eax
801028a0:	89 c2                	mov    %eax,%edx
801028a2:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028a7:	21 d0                	and    %edx,%eax
801028a9:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
801028ae:	b8 00 00 00 00       	mov    $0x0,%eax
801028b3:	e9 a2 00 00 00       	jmp    8010295a <kbdgetc+0x14d>
  } else if(shift & E0ESC){
801028b8:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028bd:	83 e0 40             	and    $0x40,%eax
801028c0:	85 c0                	test   %eax,%eax
801028c2:	74 14                	je     801028d8 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801028c4:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801028cb:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028d0:	83 e0 bf             	and    $0xffffffbf,%eax
801028d3:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  }

  shift |= shiftcode[data];
801028d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028db:	05 20 d0 10 80       	add    $0x8010d020,%eax
801028e0:	0f b6 00             	movzbl (%eax),%eax
801028e3:	0f b6 d0             	movzbl %al,%edx
801028e6:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028eb:	09 d0                	or     %edx,%eax
801028ed:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  shift ^= togglecode[data];
801028f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028f5:	05 20 d1 10 80       	add    $0x8010d120,%eax
801028fa:	0f b6 00             	movzbl (%eax),%eax
801028fd:	0f b6 d0             	movzbl %al,%edx
80102900:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102905:	31 d0                	xor    %edx,%eax
80102907:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  c = charcode[shift & (CTL | SHIFT)][data];
8010290c:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102911:	83 e0 03             	and    $0x3,%eax
80102914:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
8010291b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010291e:	01 d0                	add    %edx,%eax
80102920:	0f b6 00             	movzbl (%eax),%eax
80102923:	0f b6 c0             	movzbl %al,%eax
80102926:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102929:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010292e:	83 e0 08             	and    $0x8,%eax
80102931:	85 c0                	test   %eax,%eax
80102933:	74 22                	je     80102957 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102935:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102939:	76 0c                	jbe    80102947 <kbdgetc+0x13a>
8010293b:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
8010293f:	77 06                	ja     80102947 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102941:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102945:	eb 10                	jmp    80102957 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102947:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
8010294b:	76 0a                	jbe    80102957 <kbdgetc+0x14a>
8010294d:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102951:	77 04                	ja     80102957 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102953:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102957:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010295a:	c9                   	leave  
8010295b:	c3                   	ret    

8010295c <kbdintr>:

void
kbdintr(void)
{
8010295c:	55                   	push   %ebp
8010295d:	89 e5                	mov    %esp,%ebp
8010295f:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102962:	83 ec 0c             	sub    $0xc,%esp
80102965:	68 0d 28 10 80       	push   $0x8010280d
8010296a:	e8 67 de ff ff       	call   801007d6 <consoleintr>
8010296f:	83 c4 10             	add    $0x10,%esp
}
80102972:	90                   	nop
80102973:	c9                   	leave  
80102974:	c3                   	ret    

80102975 <inb>:
{
80102975:	55                   	push   %ebp
80102976:	89 e5                	mov    %esp,%ebp
80102978:	83 ec 14             	sub    $0x14,%esp
8010297b:	8b 45 08             	mov    0x8(%ebp),%eax
8010297e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102982:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102986:	89 c2                	mov    %eax,%edx
80102988:	ec                   	in     (%dx),%al
80102989:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010298c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102990:	c9                   	leave  
80102991:	c3                   	ret    

80102992 <outb>:
{
80102992:	55                   	push   %ebp
80102993:	89 e5                	mov    %esp,%ebp
80102995:	83 ec 08             	sub    $0x8,%esp
80102998:	8b 45 08             	mov    0x8(%ebp),%eax
8010299b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010299e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801029a2:	89 d0                	mov    %edx,%eax
801029a4:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801029a7:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801029ab:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801029af:	ee                   	out    %al,(%dx)
}
801029b0:	90                   	nop
801029b1:	c9                   	leave  
801029b2:	c3                   	ret    

801029b3 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
801029b3:	55                   	push   %ebp
801029b4:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801029b6:	8b 15 00 41 19 80    	mov    0x80194100,%edx
801029bc:	8b 45 08             	mov    0x8(%ebp),%eax
801029bf:	c1 e0 02             	shl    $0x2,%eax
801029c2:	01 c2                	add    %eax,%edx
801029c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801029c7:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801029c9:	a1 00 41 19 80       	mov    0x80194100,%eax
801029ce:	83 c0 20             	add    $0x20,%eax
801029d1:	8b 00                	mov    (%eax),%eax
}
801029d3:	90                   	nop
801029d4:	5d                   	pop    %ebp
801029d5:	c3                   	ret    

801029d6 <lapicinit>:

void
lapicinit(void)
{
801029d6:	55                   	push   %ebp
801029d7:	89 e5                	mov    %esp,%ebp
  if(!lapic)
801029d9:	a1 00 41 19 80       	mov    0x80194100,%eax
801029de:	85 c0                	test   %eax,%eax
801029e0:	0f 84 0c 01 00 00    	je     80102af2 <lapicinit+0x11c>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801029e6:	68 3f 01 00 00       	push   $0x13f
801029eb:	6a 3c                	push   $0x3c
801029ed:	e8 c1 ff ff ff       	call   801029b3 <lapicw>
801029f2:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801029f5:	6a 0b                	push   $0xb
801029f7:	68 f8 00 00 00       	push   $0xf8
801029fc:	e8 b2 ff ff ff       	call   801029b3 <lapicw>
80102a01:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102a04:	68 20 00 02 00       	push   $0x20020
80102a09:	68 c8 00 00 00       	push   $0xc8
80102a0e:	e8 a0 ff ff ff       	call   801029b3 <lapicw>
80102a13:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102a16:	68 80 96 98 00       	push   $0x989680
80102a1b:	68 e0 00 00 00       	push   $0xe0
80102a20:	e8 8e ff ff ff       	call   801029b3 <lapicw>
80102a25:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102a28:	68 00 00 01 00       	push   $0x10000
80102a2d:	68 d4 00 00 00       	push   $0xd4
80102a32:	e8 7c ff ff ff       	call   801029b3 <lapicw>
80102a37:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102a3a:	68 00 00 01 00       	push   $0x10000
80102a3f:	68 d8 00 00 00       	push   $0xd8
80102a44:	e8 6a ff ff ff       	call   801029b3 <lapicw>
80102a49:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102a4c:	a1 00 41 19 80       	mov    0x80194100,%eax
80102a51:	83 c0 30             	add    $0x30,%eax
80102a54:	8b 00                	mov    (%eax),%eax
80102a56:	c1 e8 10             	shr    $0x10,%eax
80102a59:	25 fc 00 00 00       	and    $0xfc,%eax
80102a5e:	85 c0                	test   %eax,%eax
80102a60:	74 12                	je     80102a74 <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
80102a62:	68 00 00 01 00       	push   $0x10000
80102a67:	68 d0 00 00 00       	push   $0xd0
80102a6c:	e8 42 ff ff ff       	call   801029b3 <lapicw>
80102a71:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102a74:	6a 33                	push   $0x33
80102a76:	68 dc 00 00 00       	push   $0xdc
80102a7b:	e8 33 ff ff ff       	call   801029b3 <lapicw>
80102a80:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102a83:	6a 00                	push   $0x0
80102a85:	68 a0 00 00 00       	push   $0xa0
80102a8a:	e8 24 ff ff ff       	call   801029b3 <lapicw>
80102a8f:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102a92:	6a 00                	push   $0x0
80102a94:	68 a0 00 00 00       	push   $0xa0
80102a99:	e8 15 ff ff ff       	call   801029b3 <lapicw>
80102a9e:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102aa1:	6a 00                	push   $0x0
80102aa3:	6a 2c                	push   $0x2c
80102aa5:	e8 09 ff ff ff       	call   801029b3 <lapicw>
80102aaa:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102aad:	6a 00                	push   $0x0
80102aaf:	68 c4 00 00 00       	push   $0xc4
80102ab4:	e8 fa fe ff ff       	call   801029b3 <lapicw>
80102ab9:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102abc:	68 00 85 08 00       	push   $0x88500
80102ac1:	68 c0 00 00 00       	push   $0xc0
80102ac6:	e8 e8 fe ff ff       	call   801029b3 <lapicw>
80102acb:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102ace:	90                   	nop
80102acf:	a1 00 41 19 80       	mov    0x80194100,%eax
80102ad4:	05 00 03 00 00       	add    $0x300,%eax
80102ad9:	8b 00                	mov    (%eax),%eax
80102adb:	25 00 10 00 00       	and    $0x1000,%eax
80102ae0:	85 c0                	test   %eax,%eax
80102ae2:	75 eb                	jne    80102acf <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102ae4:	6a 00                	push   $0x0
80102ae6:	6a 20                	push   $0x20
80102ae8:	e8 c6 fe ff ff       	call   801029b3 <lapicw>
80102aed:	83 c4 08             	add    $0x8,%esp
80102af0:	eb 01                	jmp    80102af3 <lapicinit+0x11d>
    return;
80102af2:	90                   	nop
}
80102af3:	c9                   	leave  
80102af4:	c3                   	ret    

80102af5 <lapicid>:

int
lapicid(void)
{
80102af5:	55                   	push   %ebp
80102af6:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102af8:	a1 00 41 19 80       	mov    0x80194100,%eax
80102afd:	85 c0                	test   %eax,%eax
80102aff:	75 07                	jne    80102b08 <lapicid+0x13>
    return 0;
80102b01:	b8 00 00 00 00       	mov    $0x0,%eax
80102b06:	eb 0d                	jmp    80102b15 <lapicid+0x20>
  }
  return lapic[ID] >> 24;
80102b08:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b0d:	83 c0 20             	add    $0x20,%eax
80102b10:	8b 00                	mov    (%eax),%eax
80102b12:	c1 e8 18             	shr    $0x18,%eax
}
80102b15:	5d                   	pop    %ebp
80102b16:	c3                   	ret    

80102b17 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102b17:	55                   	push   %ebp
80102b18:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102b1a:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b1f:	85 c0                	test   %eax,%eax
80102b21:	74 0c                	je     80102b2f <lapiceoi+0x18>
    lapicw(EOI, 0);
80102b23:	6a 00                	push   $0x0
80102b25:	6a 2c                	push   $0x2c
80102b27:	e8 87 fe ff ff       	call   801029b3 <lapicw>
80102b2c:	83 c4 08             	add    $0x8,%esp
}
80102b2f:	90                   	nop
80102b30:	c9                   	leave  
80102b31:	c3                   	ret    

80102b32 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102b32:	55                   	push   %ebp
80102b33:	89 e5                	mov    %esp,%ebp
}
80102b35:	90                   	nop
80102b36:	5d                   	pop    %ebp
80102b37:	c3                   	ret    

80102b38 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102b38:	55                   	push   %ebp
80102b39:	89 e5                	mov    %esp,%ebp
80102b3b:	83 ec 14             	sub    $0x14,%esp
80102b3e:	8b 45 08             	mov    0x8(%ebp),%eax
80102b41:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102b44:	6a 0f                	push   $0xf
80102b46:	6a 70                	push   $0x70
80102b48:	e8 45 fe ff ff       	call   80102992 <outb>
80102b4d:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102b50:	6a 0a                	push   $0xa
80102b52:	6a 71                	push   $0x71
80102b54:	e8 39 fe ff ff       	call   80102992 <outb>
80102b59:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102b5c:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102b63:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b66:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102b6b:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b6e:	c1 e8 04             	shr    $0x4,%eax
80102b71:	89 c2                	mov    %eax,%edx
80102b73:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b76:	83 c0 02             	add    $0x2,%eax
80102b79:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102b7c:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102b80:	c1 e0 18             	shl    $0x18,%eax
80102b83:	50                   	push   %eax
80102b84:	68 c4 00 00 00       	push   $0xc4
80102b89:	e8 25 fe ff ff       	call   801029b3 <lapicw>
80102b8e:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102b91:	68 00 c5 00 00       	push   $0xc500
80102b96:	68 c0 00 00 00       	push   $0xc0
80102b9b:	e8 13 fe ff ff       	call   801029b3 <lapicw>
80102ba0:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102ba3:	68 c8 00 00 00       	push   $0xc8
80102ba8:	e8 85 ff ff ff       	call   80102b32 <microdelay>
80102bad:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102bb0:	68 00 85 00 00       	push   $0x8500
80102bb5:	68 c0 00 00 00       	push   $0xc0
80102bba:	e8 f4 fd ff ff       	call   801029b3 <lapicw>
80102bbf:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102bc2:	6a 64                	push   $0x64
80102bc4:	e8 69 ff ff ff       	call   80102b32 <microdelay>
80102bc9:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102bcc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102bd3:	eb 3d                	jmp    80102c12 <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
80102bd5:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102bd9:	c1 e0 18             	shl    $0x18,%eax
80102bdc:	50                   	push   %eax
80102bdd:	68 c4 00 00 00       	push   $0xc4
80102be2:	e8 cc fd ff ff       	call   801029b3 <lapicw>
80102be7:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102bea:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bed:	c1 e8 0c             	shr    $0xc,%eax
80102bf0:	80 cc 06             	or     $0x6,%ah
80102bf3:	50                   	push   %eax
80102bf4:	68 c0 00 00 00       	push   $0xc0
80102bf9:	e8 b5 fd ff ff       	call   801029b3 <lapicw>
80102bfe:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102c01:	68 c8 00 00 00       	push   $0xc8
80102c06:	e8 27 ff ff ff       	call   80102b32 <microdelay>
80102c0b:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102c0e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102c12:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102c16:	7e bd                	jle    80102bd5 <lapicstartap+0x9d>
  }
}
80102c18:	90                   	nop
80102c19:	90                   	nop
80102c1a:	c9                   	leave  
80102c1b:	c3                   	ret    

80102c1c <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102c1c:	55                   	push   %ebp
80102c1d:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102c1f:	8b 45 08             	mov    0x8(%ebp),%eax
80102c22:	0f b6 c0             	movzbl %al,%eax
80102c25:	50                   	push   %eax
80102c26:	6a 70                	push   $0x70
80102c28:	e8 65 fd ff ff       	call   80102992 <outb>
80102c2d:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102c30:	68 c8 00 00 00       	push   $0xc8
80102c35:	e8 f8 fe ff ff       	call   80102b32 <microdelay>
80102c3a:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102c3d:	6a 71                	push   $0x71
80102c3f:	e8 31 fd ff ff       	call   80102975 <inb>
80102c44:	83 c4 04             	add    $0x4,%esp
80102c47:	0f b6 c0             	movzbl %al,%eax
}
80102c4a:	c9                   	leave  
80102c4b:	c3                   	ret    

80102c4c <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102c4c:	55                   	push   %ebp
80102c4d:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102c4f:	6a 00                	push   $0x0
80102c51:	e8 c6 ff ff ff       	call   80102c1c <cmos_read>
80102c56:	83 c4 04             	add    $0x4,%esp
80102c59:	8b 55 08             	mov    0x8(%ebp),%edx
80102c5c:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102c5e:	6a 02                	push   $0x2
80102c60:	e8 b7 ff ff ff       	call   80102c1c <cmos_read>
80102c65:	83 c4 04             	add    $0x4,%esp
80102c68:	8b 55 08             	mov    0x8(%ebp),%edx
80102c6b:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102c6e:	6a 04                	push   $0x4
80102c70:	e8 a7 ff ff ff       	call   80102c1c <cmos_read>
80102c75:	83 c4 04             	add    $0x4,%esp
80102c78:	8b 55 08             	mov    0x8(%ebp),%edx
80102c7b:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102c7e:	6a 07                	push   $0x7
80102c80:	e8 97 ff ff ff       	call   80102c1c <cmos_read>
80102c85:	83 c4 04             	add    $0x4,%esp
80102c88:	8b 55 08             	mov    0x8(%ebp),%edx
80102c8b:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102c8e:	6a 08                	push   $0x8
80102c90:	e8 87 ff ff ff       	call   80102c1c <cmos_read>
80102c95:	83 c4 04             	add    $0x4,%esp
80102c98:	8b 55 08             	mov    0x8(%ebp),%edx
80102c9b:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102c9e:	6a 09                	push   $0x9
80102ca0:	e8 77 ff ff ff       	call   80102c1c <cmos_read>
80102ca5:	83 c4 04             	add    $0x4,%esp
80102ca8:	8b 55 08             	mov    0x8(%ebp),%edx
80102cab:	89 42 14             	mov    %eax,0x14(%edx)
}
80102cae:	90                   	nop
80102caf:	c9                   	leave  
80102cb0:	c3                   	ret    

80102cb1 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102cb1:	55                   	push   %ebp
80102cb2:	89 e5                	mov    %esp,%ebp
80102cb4:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102cb7:	6a 0b                	push   $0xb
80102cb9:	e8 5e ff ff ff       	call   80102c1c <cmos_read>
80102cbe:	83 c4 04             	add    $0x4,%esp
80102cc1:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102cc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cc7:	83 e0 04             	and    $0x4,%eax
80102cca:	85 c0                	test   %eax,%eax
80102ccc:	0f 94 c0             	sete   %al
80102ccf:	0f b6 c0             	movzbl %al,%eax
80102cd2:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102cd5:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102cd8:	50                   	push   %eax
80102cd9:	e8 6e ff ff ff       	call   80102c4c <fill_rtcdate>
80102cde:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102ce1:	6a 0a                	push   $0xa
80102ce3:	e8 34 ff ff ff       	call   80102c1c <cmos_read>
80102ce8:	83 c4 04             	add    $0x4,%esp
80102ceb:	25 80 00 00 00       	and    $0x80,%eax
80102cf0:	85 c0                	test   %eax,%eax
80102cf2:	75 27                	jne    80102d1b <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80102cf4:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102cf7:	50                   	push   %eax
80102cf8:	e8 4f ff ff ff       	call   80102c4c <fill_rtcdate>
80102cfd:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102d00:	83 ec 04             	sub    $0x4,%esp
80102d03:	6a 18                	push   $0x18
80102d05:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102d08:	50                   	push   %eax
80102d09:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102d0c:	50                   	push   %eax
80102d0d:	e8 01 1e 00 00       	call   80104b13 <memcmp>
80102d12:	83 c4 10             	add    $0x10,%esp
80102d15:	85 c0                	test   %eax,%eax
80102d17:	74 05                	je     80102d1e <cmostime+0x6d>
80102d19:	eb ba                	jmp    80102cd5 <cmostime+0x24>
        continue;
80102d1b:	90                   	nop
    fill_rtcdate(&t1);
80102d1c:	eb b7                	jmp    80102cd5 <cmostime+0x24>
      break;
80102d1e:	90                   	nop
  }

  // convert
  if(bcd) {
80102d1f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102d23:	0f 84 b4 00 00 00    	je     80102ddd <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102d29:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d2c:	c1 e8 04             	shr    $0x4,%eax
80102d2f:	89 c2                	mov    %eax,%edx
80102d31:	89 d0                	mov    %edx,%eax
80102d33:	c1 e0 02             	shl    $0x2,%eax
80102d36:	01 d0                	add    %edx,%eax
80102d38:	01 c0                	add    %eax,%eax
80102d3a:	89 c2                	mov    %eax,%edx
80102d3c:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d3f:	83 e0 0f             	and    $0xf,%eax
80102d42:	01 d0                	add    %edx,%eax
80102d44:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102d47:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d4a:	c1 e8 04             	shr    $0x4,%eax
80102d4d:	89 c2                	mov    %eax,%edx
80102d4f:	89 d0                	mov    %edx,%eax
80102d51:	c1 e0 02             	shl    $0x2,%eax
80102d54:	01 d0                	add    %edx,%eax
80102d56:	01 c0                	add    %eax,%eax
80102d58:	89 c2                	mov    %eax,%edx
80102d5a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d5d:	83 e0 0f             	and    $0xf,%eax
80102d60:	01 d0                	add    %edx,%eax
80102d62:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102d65:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d68:	c1 e8 04             	shr    $0x4,%eax
80102d6b:	89 c2                	mov    %eax,%edx
80102d6d:	89 d0                	mov    %edx,%eax
80102d6f:	c1 e0 02             	shl    $0x2,%eax
80102d72:	01 d0                	add    %edx,%eax
80102d74:	01 c0                	add    %eax,%eax
80102d76:	89 c2                	mov    %eax,%edx
80102d78:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d7b:	83 e0 0f             	and    $0xf,%eax
80102d7e:	01 d0                	add    %edx,%eax
80102d80:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102d83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d86:	c1 e8 04             	shr    $0x4,%eax
80102d89:	89 c2                	mov    %eax,%edx
80102d8b:	89 d0                	mov    %edx,%eax
80102d8d:	c1 e0 02             	shl    $0x2,%eax
80102d90:	01 d0                	add    %edx,%eax
80102d92:	01 c0                	add    %eax,%eax
80102d94:	89 c2                	mov    %eax,%edx
80102d96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d99:	83 e0 0f             	and    $0xf,%eax
80102d9c:	01 d0                	add    %edx,%eax
80102d9e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102da1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102da4:	c1 e8 04             	shr    $0x4,%eax
80102da7:	89 c2                	mov    %eax,%edx
80102da9:	89 d0                	mov    %edx,%eax
80102dab:	c1 e0 02             	shl    $0x2,%eax
80102dae:	01 d0                	add    %edx,%eax
80102db0:	01 c0                	add    %eax,%eax
80102db2:	89 c2                	mov    %eax,%edx
80102db4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102db7:	83 e0 0f             	and    $0xf,%eax
80102dba:	01 d0                	add    %edx,%eax
80102dbc:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102dbf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dc2:	c1 e8 04             	shr    $0x4,%eax
80102dc5:	89 c2                	mov    %eax,%edx
80102dc7:	89 d0                	mov    %edx,%eax
80102dc9:	c1 e0 02             	shl    $0x2,%eax
80102dcc:	01 d0                	add    %edx,%eax
80102dce:	01 c0                	add    %eax,%eax
80102dd0:	89 c2                	mov    %eax,%edx
80102dd2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dd5:	83 e0 0f             	and    $0xf,%eax
80102dd8:	01 d0                	add    %edx,%eax
80102dda:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102ddd:	8b 45 08             	mov    0x8(%ebp),%eax
80102de0:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102de3:	89 10                	mov    %edx,(%eax)
80102de5:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102de8:	89 50 04             	mov    %edx,0x4(%eax)
80102deb:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102dee:	89 50 08             	mov    %edx,0x8(%eax)
80102df1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102df4:	89 50 0c             	mov    %edx,0xc(%eax)
80102df7:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102dfa:	89 50 10             	mov    %edx,0x10(%eax)
80102dfd:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102e00:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102e03:	8b 45 08             	mov    0x8(%ebp),%eax
80102e06:	8b 40 14             	mov    0x14(%eax),%eax
80102e09:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102e0f:	8b 45 08             	mov    0x8(%ebp),%eax
80102e12:	89 50 14             	mov    %edx,0x14(%eax)
}
80102e15:	90                   	nop
80102e16:	c9                   	leave  
80102e17:	c3                   	ret    

80102e18 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102e18:	55                   	push   %ebp
80102e19:	89 e5                	mov    %esp,%ebp
80102e1b:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102e1e:	83 ec 08             	sub    $0x8,%esp
80102e21:	68 31 a3 10 80       	push   $0x8010a331
80102e26:	68 20 41 19 80       	push   $0x80194120
80102e2b:	e8 e4 19 00 00       	call   80104814 <initlock>
80102e30:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80102e33:	83 ec 08             	sub    $0x8,%esp
80102e36:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102e39:	50                   	push   %eax
80102e3a:	ff 75 08             	push   0x8(%ebp)
80102e3d:	e8 87 e5 ff ff       	call   801013c9 <readsb>
80102e42:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80102e45:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102e48:	a3 54 41 19 80       	mov    %eax,0x80194154
  log.size = sb.nlog;
80102e4d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102e50:	a3 58 41 19 80       	mov    %eax,0x80194158
  log.dev = dev;
80102e55:	8b 45 08             	mov    0x8(%ebp),%eax
80102e58:	a3 64 41 19 80       	mov    %eax,0x80194164
  recover_from_log();
80102e5d:	e8 b3 01 00 00       	call   80103015 <recover_from_log>
}
80102e62:	90                   	nop
80102e63:	c9                   	leave  
80102e64:	c3                   	ret    

80102e65 <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102e65:	55                   	push   %ebp
80102e66:	89 e5                	mov    %esp,%ebp
80102e68:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102e6b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e72:	e9 95 00 00 00       	jmp    80102f0c <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102e77:	8b 15 54 41 19 80    	mov    0x80194154,%edx
80102e7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e80:	01 d0                	add    %edx,%eax
80102e82:	83 c0 01             	add    $0x1,%eax
80102e85:	89 c2                	mov    %eax,%edx
80102e87:	a1 64 41 19 80       	mov    0x80194164,%eax
80102e8c:	83 ec 08             	sub    $0x8,%esp
80102e8f:	52                   	push   %edx
80102e90:	50                   	push   %eax
80102e91:	e8 6b d3 ff ff       	call   80100201 <bread>
80102e96:	83 c4 10             	add    $0x10,%esp
80102e99:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102e9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e9f:	83 c0 10             	add    $0x10,%eax
80102ea2:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
80102ea9:	89 c2                	mov    %eax,%edx
80102eab:	a1 64 41 19 80       	mov    0x80194164,%eax
80102eb0:	83 ec 08             	sub    $0x8,%esp
80102eb3:	52                   	push   %edx
80102eb4:	50                   	push   %eax
80102eb5:	e8 47 d3 ff ff       	call   80100201 <bread>
80102eba:	83 c4 10             	add    $0x10,%esp
80102ebd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102ec0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ec3:	8d 50 5c             	lea    0x5c(%eax),%edx
80102ec6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ec9:	83 c0 5c             	add    $0x5c,%eax
80102ecc:	83 ec 04             	sub    $0x4,%esp
80102ecf:	68 00 02 00 00       	push   $0x200
80102ed4:	52                   	push   %edx
80102ed5:	50                   	push   %eax
80102ed6:	e8 90 1c 00 00       	call   80104b6b <memmove>
80102edb:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80102ede:	83 ec 0c             	sub    $0xc,%esp
80102ee1:	ff 75 ec             	push   -0x14(%ebp)
80102ee4:	e8 51 d3 ff ff       	call   8010023a <bwrite>
80102ee9:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80102eec:	83 ec 0c             	sub    $0xc,%esp
80102eef:	ff 75 f0             	push   -0x10(%ebp)
80102ef2:	e8 8c d3 ff ff       	call   80100283 <brelse>
80102ef7:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80102efa:	83 ec 0c             	sub    $0xc,%esp
80102efd:	ff 75 ec             	push   -0x14(%ebp)
80102f00:	e8 7e d3 ff ff       	call   80100283 <brelse>
80102f05:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80102f08:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f0c:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f11:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f14:	0f 8c 5d ff ff ff    	jl     80102e77 <install_trans+0x12>
  }
}
80102f1a:	90                   	nop
80102f1b:	90                   	nop
80102f1c:	c9                   	leave  
80102f1d:	c3                   	ret    

80102f1e <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80102f1e:	55                   	push   %ebp
80102f1f:	89 e5                	mov    %esp,%ebp
80102f21:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f24:	a1 54 41 19 80       	mov    0x80194154,%eax
80102f29:	89 c2                	mov    %eax,%edx
80102f2b:	a1 64 41 19 80       	mov    0x80194164,%eax
80102f30:	83 ec 08             	sub    $0x8,%esp
80102f33:	52                   	push   %edx
80102f34:	50                   	push   %eax
80102f35:	e8 c7 d2 ff ff       	call   80100201 <bread>
80102f3a:	83 c4 10             	add    $0x10,%esp
80102f3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80102f40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f43:	83 c0 5c             	add    $0x5c,%eax
80102f46:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80102f49:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f4c:	8b 00                	mov    (%eax),%eax
80102f4e:	a3 68 41 19 80       	mov    %eax,0x80194168
  for (i = 0; i < log.lh.n; i++) {
80102f53:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102f5a:	eb 1b                	jmp    80102f77 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80102f5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f62:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80102f66:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f69:	83 c2 10             	add    $0x10,%edx
80102f6c:	89 04 95 2c 41 19 80 	mov    %eax,-0x7fe6bed4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102f73:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f77:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f7c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f7f:	7c db                	jl     80102f5c <read_head+0x3e>
  }
  brelse(buf);
80102f81:	83 ec 0c             	sub    $0xc,%esp
80102f84:	ff 75 f0             	push   -0x10(%ebp)
80102f87:	e8 f7 d2 ff ff       	call   80100283 <brelse>
80102f8c:	83 c4 10             	add    $0x10,%esp
}
80102f8f:	90                   	nop
80102f90:	c9                   	leave  
80102f91:	c3                   	ret    

80102f92 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102f92:	55                   	push   %ebp
80102f93:	89 e5                	mov    %esp,%ebp
80102f95:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f98:	a1 54 41 19 80       	mov    0x80194154,%eax
80102f9d:	89 c2                	mov    %eax,%edx
80102f9f:	a1 64 41 19 80       	mov    0x80194164,%eax
80102fa4:	83 ec 08             	sub    $0x8,%esp
80102fa7:	52                   	push   %edx
80102fa8:	50                   	push   %eax
80102fa9:	e8 53 d2 ff ff       	call   80100201 <bread>
80102fae:	83 c4 10             	add    $0x10,%esp
80102fb1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80102fb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fb7:	83 c0 5c             	add    $0x5c,%eax
80102fba:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80102fbd:	8b 15 68 41 19 80    	mov    0x80194168,%edx
80102fc3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fc6:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102fc8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102fcf:	eb 1b                	jmp    80102fec <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80102fd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fd4:	83 c0 10             	add    $0x10,%eax
80102fd7:	8b 0c 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%ecx
80102fde:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fe1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102fe4:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102fe8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102fec:	a1 68 41 19 80       	mov    0x80194168,%eax
80102ff1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102ff4:	7c db                	jl     80102fd1 <write_head+0x3f>
  }
  bwrite(buf);
80102ff6:	83 ec 0c             	sub    $0xc,%esp
80102ff9:	ff 75 f0             	push   -0x10(%ebp)
80102ffc:	e8 39 d2 ff ff       	call   8010023a <bwrite>
80103001:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103004:	83 ec 0c             	sub    $0xc,%esp
80103007:	ff 75 f0             	push   -0x10(%ebp)
8010300a:	e8 74 d2 ff ff       	call   80100283 <brelse>
8010300f:	83 c4 10             	add    $0x10,%esp
}
80103012:	90                   	nop
80103013:	c9                   	leave  
80103014:	c3                   	ret    

80103015 <recover_from_log>:

static void
recover_from_log(void)
{
80103015:	55                   	push   %ebp
80103016:	89 e5                	mov    %esp,%ebp
80103018:	83 ec 08             	sub    $0x8,%esp
  read_head();
8010301b:	e8 fe fe ff ff       	call   80102f1e <read_head>
  install_trans(); // if committed, copy from log to disk
80103020:	e8 40 fe ff ff       	call   80102e65 <install_trans>
  log.lh.n = 0;
80103025:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
8010302c:	00 00 00 
  write_head(); // clear the log
8010302f:	e8 5e ff ff ff       	call   80102f92 <write_head>
}
80103034:	90                   	nop
80103035:	c9                   	leave  
80103036:	c3                   	ret    

80103037 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103037:	55                   	push   %ebp
80103038:	89 e5                	mov    %esp,%ebp
8010303a:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
8010303d:	83 ec 0c             	sub    $0xc,%esp
80103040:	68 20 41 19 80       	push   $0x80194120
80103045:	e8 ec 17 00 00       	call   80104836 <acquire>
8010304a:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
8010304d:	a1 60 41 19 80       	mov    0x80194160,%eax
80103052:	85 c0                	test   %eax,%eax
80103054:	74 17                	je     8010306d <begin_op+0x36>
      sleep(&log, &log.lock);
80103056:	83 ec 08             	sub    $0x8,%esp
80103059:	68 20 41 19 80       	push   $0x80194120
8010305e:	68 20 41 19 80       	push   $0x80194120
80103063:	e8 6c 12 00 00       	call   801042d4 <sleep>
80103068:	83 c4 10             	add    $0x10,%esp
8010306b:	eb e0                	jmp    8010304d <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
8010306d:	8b 0d 68 41 19 80    	mov    0x80194168,%ecx
80103073:	a1 5c 41 19 80       	mov    0x8019415c,%eax
80103078:	8d 50 01             	lea    0x1(%eax),%edx
8010307b:	89 d0                	mov    %edx,%eax
8010307d:	c1 e0 02             	shl    $0x2,%eax
80103080:	01 d0                	add    %edx,%eax
80103082:	01 c0                	add    %eax,%eax
80103084:	01 c8                	add    %ecx,%eax
80103086:	83 f8 1e             	cmp    $0x1e,%eax
80103089:	7e 17                	jle    801030a2 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
8010308b:	83 ec 08             	sub    $0x8,%esp
8010308e:	68 20 41 19 80       	push   $0x80194120
80103093:	68 20 41 19 80       	push   $0x80194120
80103098:	e8 37 12 00 00       	call   801042d4 <sleep>
8010309d:	83 c4 10             	add    $0x10,%esp
801030a0:	eb ab                	jmp    8010304d <begin_op+0x16>
    } else {
      log.outstanding += 1;
801030a2:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030a7:	83 c0 01             	add    $0x1,%eax
801030aa:	a3 5c 41 19 80       	mov    %eax,0x8019415c
      release(&log.lock);
801030af:	83 ec 0c             	sub    $0xc,%esp
801030b2:	68 20 41 19 80       	push   $0x80194120
801030b7:	e8 e8 17 00 00       	call   801048a4 <release>
801030bc:	83 c4 10             	add    $0x10,%esp
      break;
801030bf:	90                   	nop
    }
  }
}
801030c0:	90                   	nop
801030c1:	c9                   	leave  
801030c2:	c3                   	ret    

801030c3 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801030c3:	55                   	push   %ebp
801030c4:	89 e5                	mov    %esp,%ebp
801030c6:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801030c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801030d0:	83 ec 0c             	sub    $0xc,%esp
801030d3:	68 20 41 19 80       	push   $0x80194120
801030d8:	e8 59 17 00 00       	call   80104836 <acquire>
801030dd:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801030e0:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030e5:	83 e8 01             	sub    $0x1,%eax
801030e8:	a3 5c 41 19 80       	mov    %eax,0x8019415c
  if(log.committing)
801030ed:	a1 60 41 19 80       	mov    0x80194160,%eax
801030f2:	85 c0                	test   %eax,%eax
801030f4:	74 0d                	je     80103103 <end_op+0x40>
    panic("log.committing");
801030f6:	83 ec 0c             	sub    $0xc,%esp
801030f9:	68 35 a3 10 80       	push   $0x8010a335
801030fe:	e8 a6 d4 ff ff       	call   801005a9 <panic>
  if(log.outstanding == 0){
80103103:	a1 5c 41 19 80       	mov    0x8019415c,%eax
80103108:	85 c0                	test   %eax,%eax
8010310a:	75 13                	jne    8010311f <end_op+0x5c>
    do_commit = 1;
8010310c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103113:	c7 05 60 41 19 80 01 	movl   $0x1,0x80194160
8010311a:	00 00 00 
8010311d:	eb 10                	jmp    8010312f <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
8010311f:	83 ec 0c             	sub    $0xc,%esp
80103122:	68 20 41 19 80       	push   $0x80194120
80103127:	e8 8f 12 00 00       	call   801043bb <wakeup>
8010312c:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
8010312f:	83 ec 0c             	sub    $0xc,%esp
80103132:	68 20 41 19 80       	push   $0x80194120
80103137:	e8 68 17 00 00       	call   801048a4 <release>
8010313c:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
8010313f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103143:	74 3f                	je     80103184 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103145:	e8 f6 00 00 00       	call   80103240 <commit>
    acquire(&log.lock);
8010314a:	83 ec 0c             	sub    $0xc,%esp
8010314d:	68 20 41 19 80       	push   $0x80194120
80103152:	e8 df 16 00 00       	call   80104836 <acquire>
80103157:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010315a:	c7 05 60 41 19 80 00 	movl   $0x0,0x80194160
80103161:	00 00 00 
    wakeup(&log);
80103164:	83 ec 0c             	sub    $0xc,%esp
80103167:	68 20 41 19 80       	push   $0x80194120
8010316c:	e8 4a 12 00 00       	call   801043bb <wakeup>
80103171:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103174:	83 ec 0c             	sub    $0xc,%esp
80103177:	68 20 41 19 80       	push   $0x80194120
8010317c:	e8 23 17 00 00       	call   801048a4 <release>
80103181:	83 c4 10             	add    $0x10,%esp
  }
}
80103184:	90                   	nop
80103185:	c9                   	leave  
80103186:	c3                   	ret    

80103187 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103187:	55                   	push   %ebp
80103188:	89 e5                	mov    %esp,%ebp
8010318a:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010318d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103194:	e9 95 00 00 00       	jmp    8010322e <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103199:	8b 15 54 41 19 80    	mov    0x80194154,%edx
8010319f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031a2:	01 d0                	add    %edx,%eax
801031a4:	83 c0 01             	add    $0x1,%eax
801031a7:	89 c2                	mov    %eax,%edx
801031a9:	a1 64 41 19 80       	mov    0x80194164,%eax
801031ae:	83 ec 08             	sub    $0x8,%esp
801031b1:	52                   	push   %edx
801031b2:	50                   	push   %eax
801031b3:	e8 49 d0 ff ff       	call   80100201 <bread>
801031b8:	83 c4 10             	add    $0x10,%esp
801031bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801031be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031c1:	83 c0 10             	add    $0x10,%eax
801031c4:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801031cb:	89 c2                	mov    %eax,%edx
801031cd:	a1 64 41 19 80       	mov    0x80194164,%eax
801031d2:	83 ec 08             	sub    $0x8,%esp
801031d5:	52                   	push   %edx
801031d6:	50                   	push   %eax
801031d7:	e8 25 d0 ff ff       	call   80100201 <bread>
801031dc:	83 c4 10             	add    $0x10,%esp
801031df:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801031e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031e5:	8d 50 5c             	lea    0x5c(%eax),%edx
801031e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031eb:	83 c0 5c             	add    $0x5c,%eax
801031ee:	83 ec 04             	sub    $0x4,%esp
801031f1:	68 00 02 00 00       	push   $0x200
801031f6:	52                   	push   %edx
801031f7:	50                   	push   %eax
801031f8:	e8 6e 19 00 00       	call   80104b6b <memmove>
801031fd:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103200:	83 ec 0c             	sub    $0xc,%esp
80103203:	ff 75 f0             	push   -0x10(%ebp)
80103206:	e8 2f d0 ff ff       	call   8010023a <bwrite>
8010320b:	83 c4 10             	add    $0x10,%esp
    brelse(from);
8010320e:	83 ec 0c             	sub    $0xc,%esp
80103211:	ff 75 ec             	push   -0x14(%ebp)
80103214:	e8 6a d0 ff ff       	call   80100283 <brelse>
80103219:	83 c4 10             	add    $0x10,%esp
    brelse(to);
8010321c:	83 ec 0c             	sub    $0xc,%esp
8010321f:	ff 75 f0             	push   -0x10(%ebp)
80103222:	e8 5c d0 ff ff       	call   80100283 <brelse>
80103227:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
8010322a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010322e:	a1 68 41 19 80       	mov    0x80194168,%eax
80103233:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103236:	0f 8c 5d ff ff ff    	jl     80103199 <write_log+0x12>
  }
}
8010323c:	90                   	nop
8010323d:	90                   	nop
8010323e:	c9                   	leave  
8010323f:	c3                   	ret    

80103240 <commit>:

static void
commit()
{
80103240:	55                   	push   %ebp
80103241:	89 e5                	mov    %esp,%ebp
80103243:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103246:	a1 68 41 19 80       	mov    0x80194168,%eax
8010324b:	85 c0                	test   %eax,%eax
8010324d:	7e 1e                	jle    8010326d <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
8010324f:	e8 33 ff ff ff       	call   80103187 <write_log>
    write_head();    // Write header to disk -- the real commit
80103254:	e8 39 fd ff ff       	call   80102f92 <write_head>
    install_trans(); // Now install writes to home locations
80103259:	e8 07 fc ff ff       	call   80102e65 <install_trans>
    log.lh.n = 0;
8010325e:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
80103265:	00 00 00 
    write_head();    // Erase the transaction from the log
80103268:	e8 25 fd ff ff       	call   80102f92 <write_head>
  }
}
8010326d:	90                   	nop
8010326e:	c9                   	leave  
8010326f:	c3                   	ret    

80103270 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103270:	55                   	push   %ebp
80103271:	89 e5                	mov    %esp,%ebp
80103273:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103276:	a1 68 41 19 80       	mov    0x80194168,%eax
8010327b:	83 f8 1d             	cmp    $0x1d,%eax
8010327e:	7f 12                	jg     80103292 <log_write+0x22>
80103280:	a1 68 41 19 80       	mov    0x80194168,%eax
80103285:	8b 15 58 41 19 80    	mov    0x80194158,%edx
8010328b:	83 ea 01             	sub    $0x1,%edx
8010328e:	39 d0                	cmp    %edx,%eax
80103290:	7c 0d                	jl     8010329f <log_write+0x2f>
    panic("too big a transaction");
80103292:	83 ec 0c             	sub    $0xc,%esp
80103295:	68 44 a3 10 80       	push   $0x8010a344
8010329a:	e8 0a d3 ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
8010329f:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801032a4:	85 c0                	test   %eax,%eax
801032a6:	7f 0d                	jg     801032b5 <log_write+0x45>
    panic("log_write outside of trans");
801032a8:	83 ec 0c             	sub    $0xc,%esp
801032ab:	68 5a a3 10 80       	push   $0x8010a35a
801032b0:	e8 f4 d2 ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
801032b5:	83 ec 0c             	sub    $0xc,%esp
801032b8:	68 20 41 19 80       	push   $0x80194120
801032bd:	e8 74 15 00 00       	call   80104836 <acquire>
801032c2:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801032c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032cc:	eb 1d                	jmp    801032eb <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801032ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032d1:	83 c0 10             	add    $0x10,%eax
801032d4:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801032db:	89 c2                	mov    %eax,%edx
801032dd:	8b 45 08             	mov    0x8(%ebp),%eax
801032e0:	8b 40 08             	mov    0x8(%eax),%eax
801032e3:	39 c2                	cmp    %eax,%edx
801032e5:	74 10                	je     801032f7 <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
801032e7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801032eb:	a1 68 41 19 80       	mov    0x80194168,%eax
801032f0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801032f3:	7c d9                	jl     801032ce <log_write+0x5e>
801032f5:	eb 01                	jmp    801032f8 <log_write+0x88>
      break;
801032f7:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801032f8:	8b 45 08             	mov    0x8(%ebp),%eax
801032fb:	8b 40 08             	mov    0x8(%eax),%eax
801032fe:	89 c2                	mov    %eax,%edx
80103300:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103303:	83 c0 10             	add    $0x10,%eax
80103306:	89 14 85 2c 41 19 80 	mov    %edx,-0x7fe6bed4(,%eax,4)
  if (i == log.lh.n)
8010330d:	a1 68 41 19 80       	mov    0x80194168,%eax
80103312:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103315:	75 0d                	jne    80103324 <log_write+0xb4>
    log.lh.n++;
80103317:	a1 68 41 19 80       	mov    0x80194168,%eax
8010331c:	83 c0 01             	add    $0x1,%eax
8010331f:	a3 68 41 19 80       	mov    %eax,0x80194168
  b->flags |= B_DIRTY; // prevent eviction
80103324:	8b 45 08             	mov    0x8(%ebp),%eax
80103327:	8b 00                	mov    (%eax),%eax
80103329:	83 c8 04             	or     $0x4,%eax
8010332c:	89 c2                	mov    %eax,%edx
8010332e:	8b 45 08             	mov    0x8(%ebp),%eax
80103331:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103333:	83 ec 0c             	sub    $0xc,%esp
80103336:	68 20 41 19 80       	push   $0x80194120
8010333b:	e8 64 15 00 00       	call   801048a4 <release>
80103340:	83 c4 10             	add    $0x10,%esp
}
80103343:	90                   	nop
80103344:	c9                   	leave  
80103345:	c3                   	ret    

80103346 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103346:	55                   	push   %ebp
80103347:	89 e5                	mov    %esp,%ebp
80103349:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010334c:	8b 55 08             	mov    0x8(%ebp),%edx
8010334f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103352:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103355:	f0 87 02             	lock xchg %eax,(%edx)
80103358:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010335b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010335e:	c9                   	leave  
8010335f:	c3                   	ret    

80103360 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103360:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103364:	83 e4 f0             	and    $0xfffffff0,%esp
80103367:	ff 71 fc             	push   -0x4(%ecx)
8010336a:	55                   	push   %ebp
8010336b:	89 e5                	mov    %esp,%ebp
8010336d:	51                   	push   %ecx
8010336e:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
80103371:	e8 38 4b 00 00       	call   80107eae <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103376:	83 ec 08             	sub    $0x8,%esp
80103379:	68 00 00 40 80       	push   $0x80400000
8010337e:	68 00 90 19 80       	push   $0x80199000
80103383:	e8 de f2 ff ff       	call   80102666 <kinit1>
80103388:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
8010338b:	e8 4b 41 00 00       	call   801074db <kvmalloc>
  mpinit_uefi();
80103390:	e8 df 48 00 00       	call   80107c74 <mpinit_uefi>
  lapicinit();     // interrupt controller
80103395:	e8 3c f6 ff ff       	call   801029d6 <lapicinit>
  seginit();       // segment descriptors
8010339a:	e8 d4 3b 00 00       	call   80106f73 <seginit>
  picinit();    // disable pic
8010339f:	e8 9d 01 00 00       	call   80103541 <picinit>
  ioapicinit();    // another interrupt controller
801033a4:	e8 d8 f1 ff ff       	call   80102581 <ioapicinit>
  consoleinit();   // console hardware
801033a9:	e8 51 d7 ff ff       	call   80100aff <consoleinit>
  uartinit();      // serial port
801033ae:	e8 59 2f 00 00       	call   8010630c <uartinit>
  pinit();         // process table
801033b3:	e8 c2 05 00 00       	call   8010397a <pinit>
  tvinit();        // trap vectors
801033b8:	e8 93 2a 00 00       	call   80105e50 <tvinit>
  binit();         // buffer cache
801033bd:	e8 a4 cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033c2:	e8 f3 db ff ff       	call   80100fba <fileinit>
  ideinit();       // disk 
801033c7:	e8 23 6c 00 00       	call   80109fef <ideinit>
  startothers();   // start other processors
801033cc:	e8 8a 00 00 00       	call   8010345b <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033d1:	83 ec 08             	sub    $0x8,%esp
801033d4:	68 00 00 00 a0       	push   $0xa0000000
801033d9:	68 00 00 40 80       	push   $0x80400000
801033de:	e8 bc f2 ff ff       	call   8010269f <kinit2>
801033e3:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033e6:	e8 1c 4d 00 00       	call   80108107 <pci_init>
  arp_scan();
801033eb:	e8 53 5a 00 00       	call   80108e43 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801033f0:	e8 63 07 00 00       	call   80103b58 <userinit>

  mpmain();        // finish this processor's setup
801033f5:	e8 1a 00 00 00       	call   80103414 <mpmain>

801033fa <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801033fa:	55                   	push   %ebp
801033fb:	89 e5                	mov    %esp,%ebp
801033fd:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103400:	e8 ee 40 00 00       	call   801074f3 <switchkvm>
  seginit();
80103405:	e8 69 3b 00 00       	call   80106f73 <seginit>
  lapicinit();
8010340a:	e8 c7 f5 ff ff       	call   801029d6 <lapicinit>
  mpmain();
8010340f:	e8 00 00 00 00       	call   80103414 <mpmain>

80103414 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103414:	55                   	push   %ebp
80103415:	89 e5                	mov    %esp,%ebp
80103417:	53                   	push   %ebx
80103418:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
8010341b:	e8 78 05 00 00       	call   80103998 <cpuid>
80103420:	89 c3                	mov    %eax,%ebx
80103422:	e8 71 05 00 00       	call   80103998 <cpuid>
80103427:	83 ec 04             	sub    $0x4,%esp
8010342a:	53                   	push   %ebx
8010342b:	50                   	push   %eax
8010342c:	68 75 a3 10 80       	push   $0x8010a375
80103431:	e8 be cf ff ff       	call   801003f4 <cprintf>
80103436:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103439:	e8 88 2b 00 00       	call   80105fc6 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
8010343e:	e8 70 05 00 00       	call   801039b3 <mycpu>
80103443:	05 a0 00 00 00       	add    $0xa0,%eax
80103448:	83 ec 08             	sub    $0x8,%esp
8010344b:	6a 01                	push   $0x1
8010344d:	50                   	push   %eax
8010344e:	e8 f3 fe ff ff       	call   80103346 <xchg>
80103453:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103456:	e8 88 0c 00 00       	call   801040e3 <scheduler>

8010345b <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
8010345b:	55                   	push   %ebp
8010345c:	89 e5                	mov    %esp,%ebp
8010345e:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103461:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103468:	b8 8a 00 00 00       	mov    $0x8a,%eax
8010346d:	83 ec 04             	sub    $0x4,%esp
80103470:	50                   	push   %eax
80103471:	68 18 f5 10 80       	push   $0x8010f518
80103476:	ff 75 f0             	push   -0x10(%ebp)
80103479:	e8 ed 16 00 00       	call   80104b6b <memmove>
8010347e:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103481:	c7 45 f4 80 6a 19 80 	movl   $0x80196a80,-0xc(%ebp)
80103488:	eb 79                	jmp    80103503 <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
8010348a:	e8 24 05 00 00       	call   801039b3 <mycpu>
8010348f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103492:	74 67                	je     801034fb <startothers+0xa0>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103494:	e8 02 f3 ff ff       	call   8010279b <kalloc>
80103499:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
8010349c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010349f:	83 e8 04             	sub    $0x4,%eax
801034a2:	8b 55 ec             	mov    -0x14(%ebp),%edx
801034a5:	81 c2 00 10 00 00    	add    $0x1000,%edx
801034ab:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801034ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034b0:	83 e8 08             	sub    $0x8,%eax
801034b3:	c7 00 fa 33 10 80    	movl   $0x801033fa,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801034b9:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
801034be:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034c7:	83 e8 0c             	sub    $0xc,%eax
801034ca:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801034cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034cf:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034d8:	0f b6 00             	movzbl (%eax),%eax
801034db:	0f b6 c0             	movzbl %al,%eax
801034de:	83 ec 08             	sub    $0x8,%esp
801034e1:	52                   	push   %edx
801034e2:	50                   	push   %eax
801034e3:	e8 50 f6 ff ff       	call   80102b38 <lapicstartap>
801034e8:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801034eb:	90                   	nop
801034ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034ef:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801034f5:	85 c0                	test   %eax,%eax
801034f7:	74 f3                	je     801034ec <startothers+0x91>
801034f9:	eb 01                	jmp    801034fc <startothers+0xa1>
      continue;
801034fb:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
801034fc:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103503:	a1 40 6d 19 80       	mov    0x80196d40,%eax
80103508:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010350e:	05 80 6a 19 80       	add    $0x80196a80,%eax
80103513:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103516:	0f 82 6e ff ff ff    	jb     8010348a <startothers+0x2f>
      ;
  }
}
8010351c:	90                   	nop
8010351d:	90                   	nop
8010351e:	c9                   	leave  
8010351f:	c3                   	ret    

80103520 <outb>:
{
80103520:	55                   	push   %ebp
80103521:	89 e5                	mov    %esp,%ebp
80103523:	83 ec 08             	sub    $0x8,%esp
80103526:	8b 45 08             	mov    0x8(%ebp),%eax
80103529:	8b 55 0c             	mov    0xc(%ebp),%edx
8010352c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103530:	89 d0                	mov    %edx,%eax
80103532:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103535:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103539:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010353d:	ee                   	out    %al,(%dx)
}
8010353e:	90                   	nop
8010353f:	c9                   	leave  
80103540:	c3                   	ret    

80103541 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103541:	55                   	push   %ebp
80103542:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103544:	68 ff 00 00 00       	push   $0xff
80103549:	6a 21                	push   $0x21
8010354b:	e8 d0 ff ff ff       	call   80103520 <outb>
80103550:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103553:	68 ff 00 00 00       	push   $0xff
80103558:	68 a1 00 00 00       	push   $0xa1
8010355d:	e8 be ff ff ff       	call   80103520 <outb>
80103562:	83 c4 08             	add    $0x8,%esp
}
80103565:	90                   	nop
80103566:	c9                   	leave  
80103567:	c3                   	ret    

80103568 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103568:	55                   	push   %ebp
80103569:	89 e5                	mov    %esp,%ebp
8010356b:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
8010356e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103575:	8b 45 0c             	mov    0xc(%ebp),%eax
80103578:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
8010357e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103581:	8b 10                	mov    (%eax),%edx
80103583:	8b 45 08             	mov    0x8(%ebp),%eax
80103586:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103588:	e8 4b da ff ff       	call   80100fd8 <filealloc>
8010358d:	8b 55 08             	mov    0x8(%ebp),%edx
80103590:	89 02                	mov    %eax,(%edx)
80103592:	8b 45 08             	mov    0x8(%ebp),%eax
80103595:	8b 00                	mov    (%eax),%eax
80103597:	85 c0                	test   %eax,%eax
80103599:	0f 84 c8 00 00 00    	je     80103667 <pipealloc+0xff>
8010359f:	e8 34 da ff ff       	call   80100fd8 <filealloc>
801035a4:	8b 55 0c             	mov    0xc(%ebp),%edx
801035a7:	89 02                	mov    %eax,(%edx)
801035a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801035ac:	8b 00                	mov    (%eax),%eax
801035ae:	85 c0                	test   %eax,%eax
801035b0:	0f 84 b1 00 00 00    	je     80103667 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801035b6:	e8 e0 f1 ff ff       	call   8010279b <kalloc>
801035bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801035be:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035c2:	0f 84 a2 00 00 00    	je     8010366a <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
801035c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035cb:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801035d2:	00 00 00 
  p->writeopen = 1;
801035d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035d8:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801035df:	00 00 00 
  p->nwrite = 0;
801035e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035e5:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801035ec:	00 00 00 
  p->nread = 0;
801035ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035f2:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801035f9:	00 00 00 
  initlock(&p->lock, "pipe");
801035fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035ff:	83 ec 08             	sub    $0x8,%esp
80103602:	68 89 a3 10 80       	push   $0x8010a389
80103607:	50                   	push   %eax
80103608:	e8 07 12 00 00       	call   80104814 <initlock>
8010360d:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103610:	8b 45 08             	mov    0x8(%ebp),%eax
80103613:	8b 00                	mov    (%eax),%eax
80103615:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
8010361b:	8b 45 08             	mov    0x8(%ebp),%eax
8010361e:	8b 00                	mov    (%eax),%eax
80103620:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103624:	8b 45 08             	mov    0x8(%ebp),%eax
80103627:	8b 00                	mov    (%eax),%eax
80103629:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
8010362d:	8b 45 08             	mov    0x8(%ebp),%eax
80103630:	8b 00                	mov    (%eax),%eax
80103632:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103635:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103638:	8b 45 0c             	mov    0xc(%ebp),%eax
8010363b:	8b 00                	mov    (%eax),%eax
8010363d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103643:	8b 45 0c             	mov    0xc(%ebp),%eax
80103646:	8b 00                	mov    (%eax),%eax
80103648:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
8010364c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010364f:	8b 00                	mov    (%eax),%eax
80103651:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103655:	8b 45 0c             	mov    0xc(%ebp),%eax
80103658:	8b 00                	mov    (%eax),%eax
8010365a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010365d:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103660:	b8 00 00 00 00       	mov    $0x0,%eax
80103665:	eb 51                	jmp    801036b8 <pipealloc+0x150>
    goto bad;
80103667:	90                   	nop
80103668:	eb 01                	jmp    8010366b <pipealloc+0x103>
    goto bad;
8010366a:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
8010366b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010366f:	74 0e                	je     8010367f <pipealloc+0x117>
    kfree((char*)p);
80103671:	83 ec 0c             	sub    $0xc,%esp
80103674:	ff 75 f4             	push   -0xc(%ebp)
80103677:	e8 85 f0 ff ff       	call   80102701 <kfree>
8010367c:	83 c4 10             	add    $0x10,%esp
  if(*f0)
8010367f:	8b 45 08             	mov    0x8(%ebp),%eax
80103682:	8b 00                	mov    (%eax),%eax
80103684:	85 c0                	test   %eax,%eax
80103686:	74 11                	je     80103699 <pipealloc+0x131>
    fileclose(*f0);
80103688:	8b 45 08             	mov    0x8(%ebp),%eax
8010368b:	8b 00                	mov    (%eax),%eax
8010368d:	83 ec 0c             	sub    $0xc,%esp
80103690:	50                   	push   %eax
80103691:	e8 00 da ff ff       	call   80101096 <fileclose>
80103696:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103699:	8b 45 0c             	mov    0xc(%ebp),%eax
8010369c:	8b 00                	mov    (%eax),%eax
8010369e:	85 c0                	test   %eax,%eax
801036a0:	74 11                	je     801036b3 <pipealloc+0x14b>
    fileclose(*f1);
801036a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801036a5:	8b 00                	mov    (%eax),%eax
801036a7:	83 ec 0c             	sub    $0xc,%esp
801036aa:	50                   	push   %eax
801036ab:	e8 e6 d9 ff ff       	call   80101096 <fileclose>
801036b0:	83 c4 10             	add    $0x10,%esp
  return -1;
801036b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801036b8:	c9                   	leave  
801036b9:	c3                   	ret    

801036ba <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801036ba:	55                   	push   %ebp
801036bb:	89 e5                	mov    %esp,%ebp
801036bd:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801036c0:	8b 45 08             	mov    0x8(%ebp),%eax
801036c3:	83 ec 0c             	sub    $0xc,%esp
801036c6:	50                   	push   %eax
801036c7:	e8 6a 11 00 00       	call   80104836 <acquire>
801036cc:	83 c4 10             	add    $0x10,%esp
  if(writable){
801036cf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801036d3:	74 23                	je     801036f8 <pipeclose+0x3e>
    p->writeopen = 0;
801036d5:	8b 45 08             	mov    0x8(%ebp),%eax
801036d8:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801036df:	00 00 00 
    wakeup(&p->nread);
801036e2:	8b 45 08             	mov    0x8(%ebp),%eax
801036e5:	05 34 02 00 00       	add    $0x234,%eax
801036ea:	83 ec 0c             	sub    $0xc,%esp
801036ed:	50                   	push   %eax
801036ee:	e8 c8 0c 00 00       	call   801043bb <wakeup>
801036f3:	83 c4 10             	add    $0x10,%esp
801036f6:	eb 21                	jmp    80103719 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801036f8:	8b 45 08             	mov    0x8(%ebp),%eax
801036fb:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103702:	00 00 00 
    wakeup(&p->nwrite);
80103705:	8b 45 08             	mov    0x8(%ebp),%eax
80103708:	05 38 02 00 00       	add    $0x238,%eax
8010370d:	83 ec 0c             	sub    $0xc,%esp
80103710:	50                   	push   %eax
80103711:	e8 a5 0c 00 00       	call   801043bb <wakeup>
80103716:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103719:	8b 45 08             	mov    0x8(%ebp),%eax
8010371c:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103722:	85 c0                	test   %eax,%eax
80103724:	75 2c                	jne    80103752 <pipeclose+0x98>
80103726:	8b 45 08             	mov    0x8(%ebp),%eax
80103729:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010372f:	85 c0                	test   %eax,%eax
80103731:	75 1f                	jne    80103752 <pipeclose+0x98>
    release(&p->lock);
80103733:	8b 45 08             	mov    0x8(%ebp),%eax
80103736:	83 ec 0c             	sub    $0xc,%esp
80103739:	50                   	push   %eax
8010373a:	e8 65 11 00 00       	call   801048a4 <release>
8010373f:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103742:	83 ec 0c             	sub    $0xc,%esp
80103745:	ff 75 08             	push   0x8(%ebp)
80103748:	e8 b4 ef ff ff       	call   80102701 <kfree>
8010374d:	83 c4 10             	add    $0x10,%esp
80103750:	eb 10                	jmp    80103762 <pipeclose+0xa8>
  } else
    release(&p->lock);
80103752:	8b 45 08             	mov    0x8(%ebp),%eax
80103755:	83 ec 0c             	sub    $0xc,%esp
80103758:	50                   	push   %eax
80103759:	e8 46 11 00 00       	call   801048a4 <release>
8010375e:	83 c4 10             	add    $0x10,%esp
}
80103761:	90                   	nop
80103762:	90                   	nop
80103763:	c9                   	leave  
80103764:	c3                   	ret    

80103765 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103765:	55                   	push   %ebp
80103766:	89 e5                	mov    %esp,%ebp
80103768:	53                   	push   %ebx
80103769:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
8010376c:	8b 45 08             	mov    0x8(%ebp),%eax
8010376f:	83 ec 0c             	sub    $0xc,%esp
80103772:	50                   	push   %eax
80103773:	e8 be 10 00 00       	call   80104836 <acquire>
80103778:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
8010377b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103782:	e9 ad 00 00 00       	jmp    80103834 <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
80103787:	8b 45 08             	mov    0x8(%ebp),%eax
8010378a:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103790:	85 c0                	test   %eax,%eax
80103792:	74 0c                	je     801037a0 <pipewrite+0x3b>
80103794:	e8 92 02 00 00       	call   80103a2b <myproc>
80103799:	8b 40 24             	mov    0x24(%eax),%eax
8010379c:	85 c0                	test   %eax,%eax
8010379e:	74 19                	je     801037b9 <pipewrite+0x54>
        release(&p->lock);
801037a0:	8b 45 08             	mov    0x8(%ebp),%eax
801037a3:	83 ec 0c             	sub    $0xc,%esp
801037a6:	50                   	push   %eax
801037a7:	e8 f8 10 00 00       	call   801048a4 <release>
801037ac:	83 c4 10             	add    $0x10,%esp
        return -1;
801037af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801037b4:	e9 a9 00 00 00       	jmp    80103862 <pipewrite+0xfd>
      }
      wakeup(&p->nread);
801037b9:	8b 45 08             	mov    0x8(%ebp),%eax
801037bc:	05 34 02 00 00       	add    $0x234,%eax
801037c1:	83 ec 0c             	sub    $0xc,%esp
801037c4:	50                   	push   %eax
801037c5:	e8 f1 0b 00 00       	call   801043bb <wakeup>
801037ca:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037cd:	8b 45 08             	mov    0x8(%ebp),%eax
801037d0:	8b 55 08             	mov    0x8(%ebp),%edx
801037d3:	81 c2 38 02 00 00    	add    $0x238,%edx
801037d9:	83 ec 08             	sub    $0x8,%esp
801037dc:	50                   	push   %eax
801037dd:	52                   	push   %edx
801037de:	e8 f1 0a 00 00       	call   801042d4 <sleep>
801037e3:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801037e6:	8b 45 08             	mov    0x8(%ebp),%eax
801037e9:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801037ef:	8b 45 08             	mov    0x8(%ebp),%eax
801037f2:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801037f8:	05 00 02 00 00       	add    $0x200,%eax
801037fd:	39 c2                	cmp    %eax,%edx
801037ff:	74 86                	je     80103787 <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103801:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103804:	8b 45 0c             	mov    0xc(%ebp),%eax
80103807:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010380a:	8b 45 08             	mov    0x8(%ebp),%eax
8010380d:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103813:	8d 48 01             	lea    0x1(%eax),%ecx
80103816:	8b 55 08             	mov    0x8(%ebp),%edx
80103819:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
8010381f:	25 ff 01 00 00       	and    $0x1ff,%eax
80103824:	89 c1                	mov    %eax,%ecx
80103826:	0f b6 13             	movzbl (%ebx),%edx
80103829:	8b 45 08             	mov    0x8(%ebp),%eax
8010382c:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103830:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103834:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103837:	3b 45 10             	cmp    0x10(%ebp),%eax
8010383a:	7c aa                	jl     801037e6 <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
8010383c:	8b 45 08             	mov    0x8(%ebp),%eax
8010383f:	05 34 02 00 00       	add    $0x234,%eax
80103844:	83 ec 0c             	sub    $0xc,%esp
80103847:	50                   	push   %eax
80103848:	e8 6e 0b 00 00       	call   801043bb <wakeup>
8010384d:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103850:	8b 45 08             	mov    0x8(%ebp),%eax
80103853:	83 ec 0c             	sub    $0xc,%esp
80103856:	50                   	push   %eax
80103857:	e8 48 10 00 00       	call   801048a4 <release>
8010385c:	83 c4 10             	add    $0x10,%esp
  return n;
8010385f:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103862:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103865:	c9                   	leave  
80103866:	c3                   	ret    

80103867 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103867:	55                   	push   %ebp
80103868:	89 e5                	mov    %esp,%ebp
8010386a:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
8010386d:	8b 45 08             	mov    0x8(%ebp),%eax
80103870:	83 ec 0c             	sub    $0xc,%esp
80103873:	50                   	push   %eax
80103874:	e8 bd 0f 00 00       	call   80104836 <acquire>
80103879:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010387c:	eb 3e                	jmp    801038bc <piperead+0x55>
    if(myproc()->killed){
8010387e:	e8 a8 01 00 00       	call   80103a2b <myproc>
80103883:	8b 40 24             	mov    0x24(%eax),%eax
80103886:	85 c0                	test   %eax,%eax
80103888:	74 19                	je     801038a3 <piperead+0x3c>
      release(&p->lock);
8010388a:	8b 45 08             	mov    0x8(%ebp),%eax
8010388d:	83 ec 0c             	sub    $0xc,%esp
80103890:	50                   	push   %eax
80103891:	e8 0e 10 00 00       	call   801048a4 <release>
80103896:	83 c4 10             	add    $0x10,%esp
      return -1;
80103899:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010389e:	e9 be 00 00 00       	jmp    80103961 <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801038a3:	8b 45 08             	mov    0x8(%ebp),%eax
801038a6:	8b 55 08             	mov    0x8(%ebp),%edx
801038a9:	81 c2 34 02 00 00    	add    $0x234,%edx
801038af:	83 ec 08             	sub    $0x8,%esp
801038b2:	50                   	push   %eax
801038b3:	52                   	push   %edx
801038b4:	e8 1b 0a 00 00       	call   801042d4 <sleep>
801038b9:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801038bc:	8b 45 08             	mov    0x8(%ebp),%eax
801038bf:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038c5:	8b 45 08             	mov    0x8(%ebp),%eax
801038c8:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038ce:	39 c2                	cmp    %eax,%edx
801038d0:	75 0d                	jne    801038df <piperead+0x78>
801038d2:	8b 45 08             	mov    0x8(%ebp),%eax
801038d5:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801038db:	85 c0                	test   %eax,%eax
801038dd:	75 9f                	jne    8010387e <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801038df:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038e6:	eb 48                	jmp    80103930 <piperead+0xc9>
    if(p->nread == p->nwrite)
801038e8:	8b 45 08             	mov    0x8(%ebp),%eax
801038eb:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038f1:	8b 45 08             	mov    0x8(%ebp),%eax
801038f4:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038fa:	39 c2                	cmp    %eax,%edx
801038fc:	74 3c                	je     8010393a <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801038fe:	8b 45 08             	mov    0x8(%ebp),%eax
80103901:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103907:	8d 48 01             	lea    0x1(%eax),%ecx
8010390a:	8b 55 08             	mov    0x8(%ebp),%edx
8010390d:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103913:	25 ff 01 00 00       	and    $0x1ff,%eax
80103918:	89 c1                	mov    %eax,%ecx
8010391a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010391d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103920:	01 c2                	add    %eax,%edx
80103922:	8b 45 08             	mov    0x8(%ebp),%eax
80103925:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
8010392a:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010392c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103930:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103933:	3b 45 10             	cmp    0x10(%ebp),%eax
80103936:	7c b0                	jl     801038e8 <piperead+0x81>
80103938:	eb 01                	jmp    8010393b <piperead+0xd4>
      break;
8010393a:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010393b:	8b 45 08             	mov    0x8(%ebp),%eax
8010393e:	05 38 02 00 00       	add    $0x238,%eax
80103943:	83 ec 0c             	sub    $0xc,%esp
80103946:	50                   	push   %eax
80103947:	e8 6f 0a 00 00       	call   801043bb <wakeup>
8010394c:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
8010394f:	8b 45 08             	mov    0x8(%ebp),%eax
80103952:	83 ec 0c             	sub    $0xc,%esp
80103955:	50                   	push   %eax
80103956:	e8 49 0f 00 00       	call   801048a4 <release>
8010395b:	83 c4 10             	add    $0x10,%esp
  return i;
8010395e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103961:	c9                   	leave  
80103962:	c3                   	ret    

80103963 <readeflags>:
{
80103963:	55                   	push   %ebp
80103964:	89 e5                	mov    %esp,%ebp
80103966:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103969:	9c                   	pushf  
8010396a:	58                   	pop    %eax
8010396b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010396e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103971:	c9                   	leave  
80103972:	c3                   	ret    

80103973 <sti>:
{
80103973:	55                   	push   %ebp
80103974:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103976:	fb                   	sti    
}
80103977:	90                   	nop
80103978:	5d                   	pop    %ebp
80103979:	c3                   	ret    

8010397a <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010397a:	55                   	push   %ebp
8010397b:	89 e5                	mov    %esp,%ebp
8010397d:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103980:	83 ec 08             	sub    $0x8,%esp
80103983:	68 90 a3 10 80       	push   $0x8010a390
80103988:	68 00 42 19 80       	push   $0x80194200
8010398d:	e8 82 0e 00 00       	call   80104814 <initlock>
80103992:	83 c4 10             	add    $0x10,%esp
}
80103995:	90                   	nop
80103996:	c9                   	leave  
80103997:	c3                   	ret    

80103998 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80103998:	55                   	push   %ebp
80103999:	89 e5                	mov    %esp,%ebp
8010399b:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
8010399e:	e8 10 00 00 00       	call   801039b3 <mycpu>
801039a3:	2d 80 6a 19 80       	sub    $0x80196a80,%eax
801039a8:	c1 f8 04             	sar    $0x4,%eax
801039ab:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801039b1:	c9                   	leave  
801039b2:	c3                   	ret    

801039b3 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801039b3:	55                   	push   %ebp
801039b4:	89 e5                	mov    %esp,%ebp
801039b6:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
801039b9:	e8 a5 ff ff ff       	call   80103963 <readeflags>
801039be:	25 00 02 00 00       	and    $0x200,%eax
801039c3:	85 c0                	test   %eax,%eax
801039c5:	74 0d                	je     801039d4 <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
801039c7:	83 ec 0c             	sub    $0xc,%esp
801039ca:	68 98 a3 10 80       	push   $0x8010a398
801039cf:	e8 d5 cb ff ff       	call   801005a9 <panic>
  }

  apicid = lapicid();
801039d4:	e8 1c f1 ff ff       	call   80102af5 <lapicid>
801039d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801039dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801039e3:	eb 2d                	jmp    80103a12 <mycpu+0x5f>
    if (cpus[i].apicid == apicid){
801039e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039e8:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801039ee:	05 80 6a 19 80       	add    $0x80196a80,%eax
801039f3:	0f b6 00             	movzbl (%eax),%eax
801039f6:	0f b6 c0             	movzbl %al,%eax
801039f9:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801039fc:	75 10                	jne    80103a0e <mycpu+0x5b>
      return &cpus[i];
801039fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a01:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103a07:	05 80 6a 19 80       	add    $0x80196a80,%eax
80103a0c:	eb 1b                	jmp    80103a29 <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103a0e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a12:	a1 40 6d 19 80       	mov    0x80196d40,%eax
80103a17:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a1a:	7c c9                	jl     801039e5 <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103a1c:	83 ec 0c             	sub    $0xc,%esp
80103a1f:	68 be a3 10 80       	push   $0x8010a3be
80103a24:	e8 80 cb ff ff       	call   801005a9 <panic>
}
80103a29:	c9                   	leave  
80103a2a:	c3                   	ret    

80103a2b <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103a2b:	55                   	push   %ebp
80103a2c:	89 e5                	mov    %esp,%ebp
80103a2e:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103a31:	e8 6b 0f 00 00       	call   801049a1 <pushcli>
  c = mycpu();
80103a36:	e8 78 ff ff ff       	call   801039b3 <mycpu>
80103a3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103a3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a41:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a47:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103a4a:	e8 9f 0f 00 00       	call   801049ee <popcli>
  return p;
80103a4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103a52:	c9                   	leave  
80103a53:	c3                   	ret    

80103a54 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103a54:	55                   	push   %ebp
80103a55:	89 e5                	mov    %esp,%ebp
80103a57:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103a5a:	83 ec 0c             	sub    $0xc,%esp
80103a5d:	68 00 42 19 80       	push   $0x80194200
80103a62:	e8 cf 0d 00 00       	call   80104836 <acquire>
80103a67:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a6a:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103a71:	eb 0e                	jmp    80103a81 <allocproc+0x2d>
    if(p->state == UNUSED){
80103a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a76:	8b 40 0c             	mov    0xc(%eax),%eax
80103a79:	85 c0                	test   %eax,%eax
80103a7b:	74 27                	je     80103aa4 <allocproc+0x50>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a7d:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80103a81:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
80103a88:	72 e9                	jb     80103a73 <allocproc+0x1f>
      goto found;
    }

  release(&ptable.lock);
80103a8a:	83 ec 0c             	sub    $0xc,%esp
80103a8d:	68 00 42 19 80       	push   $0x80194200
80103a92:	e8 0d 0e 00 00       	call   801048a4 <release>
80103a97:	83 c4 10             	add    $0x10,%esp
  return 0;
80103a9a:	b8 00 00 00 00       	mov    $0x0,%eax
80103a9f:	e9 b2 00 00 00       	jmp    80103b56 <allocproc+0x102>
      goto found;
80103aa4:	90                   	nop

found:
  p->state = EMBRYO;
80103aa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aa8:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103aaf:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103ab4:	8d 50 01             	lea    0x1(%eax),%edx
80103ab7:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103abd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ac0:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80103ac3:	83 ec 0c             	sub    $0xc,%esp
80103ac6:	68 00 42 19 80       	push   $0x80194200
80103acb:	e8 d4 0d 00 00       	call   801048a4 <release>
80103ad0:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103ad3:	e8 c3 ec ff ff       	call   8010279b <kalloc>
80103ad8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103adb:	89 42 08             	mov    %eax,0x8(%edx)
80103ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae1:	8b 40 08             	mov    0x8(%eax),%eax
80103ae4:	85 c0                	test   %eax,%eax
80103ae6:	75 11                	jne    80103af9 <allocproc+0xa5>
    p->state = UNUSED;
80103ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aeb:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103af2:	b8 00 00 00 00       	mov    $0x0,%eax
80103af7:	eb 5d                	jmp    80103b56 <allocproc+0x102>
  }
  sp = p->kstack + KSTACKSIZE;
80103af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103afc:	8b 40 08             	mov    0x8(%eax),%eax
80103aff:	05 00 10 00 00       	add    $0x1000,%eax
80103b04:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103b07:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b0e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b11:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103b14:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103b18:	ba 0a 5e 10 80       	mov    $0x80105e0a,%edx
80103b1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b20:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103b22:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80103b26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b29:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b2c:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103b2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b32:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b35:	83 ec 04             	sub    $0x4,%esp
80103b38:	6a 14                	push   $0x14
80103b3a:	6a 00                	push   $0x0
80103b3c:	50                   	push   %eax
80103b3d:	e8 6a 0f 00 00       	call   80104aac <memset>
80103b42:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b48:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b4b:	ba 8e 42 10 80       	mov    $0x8010428e,%edx
80103b50:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103b56:	c9                   	leave  
80103b57:	c3                   	ret    

80103b58 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103b58:	55                   	push   %ebp
80103b59:	89 e5                	mov    %esp,%ebp
80103b5b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103b5e:	e8 f1 fe ff ff       	call   80103a54 <allocproc>
80103b63:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103b66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b69:	a3 34 62 19 80       	mov    %eax,0x80196234
  if((p->pgdir = setupkvm()) == 0){
80103b6e:	e8 7c 38 00 00       	call   801073ef <setupkvm>
80103b73:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b76:	89 42 04             	mov    %eax,0x4(%edx)
80103b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b7c:	8b 40 04             	mov    0x4(%eax),%eax
80103b7f:	85 c0                	test   %eax,%eax
80103b81:	75 0d                	jne    80103b90 <userinit+0x38>
    panic("userinit: out of memory?");
80103b83:	83 ec 0c             	sub    $0xc,%esp
80103b86:	68 ce a3 10 80       	push   $0x8010a3ce
80103b8b:	e8 19 ca ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103b90:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103b95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b98:	8b 40 04             	mov    0x4(%eax),%eax
80103b9b:	83 ec 04             	sub    $0x4,%esp
80103b9e:	52                   	push   %edx
80103b9f:	68 ec f4 10 80       	push   $0x8010f4ec
80103ba4:	50                   	push   %eax
80103ba5:	e8 01 3b 00 00       	call   801076ab <inituvm>
80103baa:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103bad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb0:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103bb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb9:	8b 40 18             	mov    0x18(%eax),%eax
80103bbc:	83 ec 04             	sub    $0x4,%esp
80103bbf:	6a 4c                	push   $0x4c
80103bc1:	6a 00                	push   $0x0
80103bc3:	50                   	push   %eax
80103bc4:	e8 e3 0e 00 00       	call   80104aac <memset>
80103bc9:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103bcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bcf:	8b 40 18             	mov    0x18(%eax),%eax
80103bd2:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103bd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bdb:	8b 40 18             	mov    0x18(%eax),%eax
80103bde:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be7:	8b 50 18             	mov    0x18(%eax),%edx
80103bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bed:	8b 40 18             	mov    0x18(%eax),%eax
80103bf0:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103bf4:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bfb:	8b 50 18             	mov    0x18(%eax),%edx
80103bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c01:	8b 40 18             	mov    0x18(%eax),%eax
80103c04:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c08:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c0f:	8b 40 18             	mov    0x18(%eax),%eax
80103c12:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103c19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c1c:	8b 40 18             	mov    0x18(%eax),%eax
80103c1f:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103c26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c29:	8b 40 18             	mov    0x18(%eax),%eax
80103c2c:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c36:	83 c0 6c             	add    $0x6c,%eax
80103c39:	83 ec 04             	sub    $0x4,%esp
80103c3c:	6a 10                	push   $0x10
80103c3e:	68 e7 a3 10 80       	push   $0x8010a3e7
80103c43:	50                   	push   %eax
80103c44:	e8 66 10 00 00       	call   80104caf <safestrcpy>
80103c49:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103c4c:	83 ec 0c             	sub    $0xc,%esp
80103c4f:	68 f0 a3 10 80       	push   $0x8010a3f0
80103c54:	e8 bf e8 ff ff       	call   80102518 <namei>
80103c59:	83 c4 10             	add    $0x10,%esp
80103c5c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c5f:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103c62:	83 ec 0c             	sub    $0xc,%esp
80103c65:	68 00 42 19 80       	push   $0x80194200
80103c6a:	e8 c7 0b 00 00       	call   80104836 <acquire>
80103c6f:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c75:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103c7c:	83 ec 0c             	sub    $0xc,%esp
80103c7f:	68 00 42 19 80       	push   $0x80194200
80103c84:	e8 1b 0c 00 00       	call   801048a4 <release>
80103c89:	83 c4 10             	add    $0x10,%esp
}
80103c8c:	90                   	nop
80103c8d:	c9                   	leave  
80103c8e:	c3                   	ret    

80103c8f <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103c8f:	55                   	push   %ebp
80103c90:	89 e5                	mov    %esp,%ebp
80103c92:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103c95:	e8 91 fd ff ff       	call   80103a2b <myproc>
80103c9a:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103c9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ca0:	8b 00                	mov    (%eax),%eax
80103ca2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103ca5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103ca9:	7e 2e                	jle    80103cd9 <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103cab:	8b 55 08             	mov    0x8(%ebp),%edx
80103cae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb1:	01 c2                	add    %eax,%edx
80103cb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cb6:	8b 40 04             	mov    0x4(%eax),%eax
80103cb9:	83 ec 04             	sub    $0x4,%esp
80103cbc:	52                   	push   %edx
80103cbd:	ff 75 f4             	push   -0xc(%ebp)
80103cc0:	50                   	push   %eax
80103cc1:	e8 22 3b 00 00       	call   801077e8 <allocuvm>
80103cc6:	83 c4 10             	add    $0x10,%esp
80103cc9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ccc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103cd0:	75 3b                	jne    80103d0d <growproc+0x7e>
      return -1;
80103cd2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103cd7:	eb 4f                	jmp    80103d28 <growproc+0x99>
  } else if(n < 0){
80103cd9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103cdd:	79 2e                	jns    80103d0d <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103cdf:	8b 55 08             	mov    0x8(%ebp),%edx
80103ce2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ce5:	01 c2                	add    %eax,%edx
80103ce7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cea:	8b 40 04             	mov    0x4(%eax),%eax
80103ced:	83 ec 04             	sub    $0x4,%esp
80103cf0:	52                   	push   %edx
80103cf1:	ff 75 f4             	push   -0xc(%ebp)
80103cf4:	50                   	push   %eax
80103cf5:	e8 f5 3b 00 00       	call   801078ef <deallocuvm>
80103cfa:	83 c4 10             	add    $0x10,%esp
80103cfd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d00:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d04:	75 07                	jne    80103d0d <growproc+0x7e>
      return -1;
80103d06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d0b:	eb 1b                	jmp    80103d28 <growproc+0x99>
  }
  curproc->sz = sz;
80103d0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d10:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d13:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103d15:	83 ec 0c             	sub    $0xc,%esp
80103d18:	ff 75 f0             	push   -0x10(%ebp)
80103d1b:	e8 ec 37 00 00       	call   8010750c <switchuvm>
80103d20:	83 c4 10             	add    $0x10,%esp
  return 0;
80103d23:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103d28:	c9                   	leave  
80103d29:	c3                   	ret    

80103d2a <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103d2a:	55                   	push   %ebp
80103d2b:	89 e5                	mov    %esp,%ebp
80103d2d:	57                   	push   %edi
80103d2e:	56                   	push   %esi
80103d2f:	53                   	push   %ebx
80103d30:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103d33:	e8 f3 fc ff ff       	call   80103a2b <myproc>
80103d38:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103d3b:	e8 14 fd ff ff       	call   80103a54 <allocproc>
80103d40:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103d43:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103d47:	75 0a                	jne    80103d53 <fork+0x29>
    return -1;
80103d49:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d4e:	e9 48 01 00 00       	jmp    80103e9b <fork+0x171>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103d53:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d56:	8b 10                	mov    (%eax),%edx
80103d58:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d5b:	8b 40 04             	mov    0x4(%eax),%eax
80103d5e:	83 ec 08             	sub    $0x8,%esp
80103d61:	52                   	push   %edx
80103d62:	50                   	push   %eax
80103d63:	e8 25 3d 00 00       	call   80107a8d <copyuvm>
80103d68:	83 c4 10             	add    $0x10,%esp
80103d6b:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103d6e:	89 42 04             	mov    %eax,0x4(%edx)
80103d71:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d74:	8b 40 04             	mov    0x4(%eax),%eax
80103d77:	85 c0                	test   %eax,%eax
80103d79:	75 30                	jne    80103dab <fork+0x81>
    kfree(np->kstack);
80103d7b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d7e:	8b 40 08             	mov    0x8(%eax),%eax
80103d81:	83 ec 0c             	sub    $0xc,%esp
80103d84:	50                   	push   %eax
80103d85:	e8 77 e9 ff ff       	call   80102701 <kfree>
80103d8a:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103d8d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d90:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103d97:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d9a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103da1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103da6:	e9 f0 00 00 00       	jmp    80103e9b <fork+0x171>
  }
  np->sz = curproc->sz;
80103dab:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dae:	8b 10                	mov    (%eax),%edx
80103db0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103db3:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103db5:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103db8:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103dbb:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103dbe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dc1:	8b 48 18             	mov    0x18(%eax),%ecx
80103dc4:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dc7:	8b 40 18             	mov    0x18(%eax),%eax
80103dca:	89 c2                	mov    %eax,%edx
80103dcc:	89 cb                	mov    %ecx,%ebx
80103dce:	b8 13 00 00 00       	mov    $0x13,%eax
80103dd3:	89 d7                	mov    %edx,%edi
80103dd5:	89 de                	mov    %ebx,%esi
80103dd7:	89 c1                	mov    %eax,%ecx
80103dd9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103ddb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dde:	8b 40 18             	mov    0x18(%eax),%eax
80103de1:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80103de8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103def:	eb 3b                	jmp    80103e2c <fork+0x102>
    if(curproc->ofile[i])
80103df1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103df4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103df7:	83 c2 08             	add    $0x8,%edx
80103dfa:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103dfe:	85 c0                	test   %eax,%eax
80103e00:	74 26                	je     80103e28 <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103e02:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e05:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e08:	83 c2 08             	add    $0x8,%edx
80103e0b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e0f:	83 ec 0c             	sub    $0xc,%esp
80103e12:	50                   	push   %eax
80103e13:	e8 2d d2 ff ff       	call   80101045 <filedup>
80103e18:	83 c4 10             	add    $0x10,%esp
80103e1b:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e1e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103e21:	83 c1 08             	add    $0x8,%ecx
80103e24:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80103e28:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103e2c:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103e30:	7e bf                	jle    80103df1 <fork+0xc7>
  np->cwd = idup(curproc->cwd);
80103e32:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e35:	8b 40 68             	mov    0x68(%eax),%eax
80103e38:	83 ec 0c             	sub    $0xc,%esp
80103e3b:	50                   	push   %eax
80103e3c:	e8 6a db ff ff       	call   801019ab <idup>
80103e41:	83 c4 10             	add    $0x10,%esp
80103e44:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e47:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103e4a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e4d:	8d 50 6c             	lea    0x6c(%eax),%edx
80103e50:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e53:	83 c0 6c             	add    $0x6c,%eax
80103e56:	83 ec 04             	sub    $0x4,%esp
80103e59:	6a 10                	push   $0x10
80103e5b:	52                   	push   %edx
80103e5c:	50                   	push   %eax
80103e5d:	e8 4d 0e 00 00       	call   80104caf <safestrcpy>
80103e62:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103e65:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e68:	8b 40 10             	mov    0x10(%eax),%eax
80103e6b:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103e6e:	83 ec 0c             	sub    $0xc,%esp
80103e71:	68 00 42 19 80       	push   $0x80194200
80103e76:	e8 bb 09 00 00       	call   80104836 <acquire>
80103e7b:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80103e7e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e81:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103e88:	83 ec 0c             	sub    $0xc,%esp
80103e8b:	68 00 42 19 80       	push   $0x80194200
80103e90:	e8 0f 0a 00 00       	call   801048a4 <release>
80103e95:	83 c4 10             	add    $0x10,%esp

  return pid;
80103e98:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80103e9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103e9e:	5b                   	pop    %ebx
80103e9f:	5e                   	pop    %esi
80103ea0:	5f                   	pop    %edi
80103ea1:	5d                   	pop    %ebp
80103ea2:	c3                   	ret    

80103ea3 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80103ea3:	55                   	push   %ebp
80103ea4:	89 e5                	mov    %esp,%ebp
80103ea6:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80103ea9:	e8 7d fb ff ff       	call   80103a2b <myproc>
80103eae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80103eb1:	a1 34 62 19 80       	mov    0x80196234,%eax
80103eb6:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103eb9:	75 0d                	jne    80103ec8 <exit+0x25>
    panic("init exiting");
80103ebb:	83 ec 0c             	sub    $0xc,%esp
80103ebe:	68 f2 a3 10 80       	push   $0x8010a3f2
80103ec3:	e8 e1 c6 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80103ec8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80103ecf:	eb 3f                	jmp    80103f10 <exit+0x6d>
    if(curproc->ofile[fd]){
80103ed1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ed4:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103ed7:	83 c2 08             	add    $0x8,%edx
80103eda:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103ede:	85 c0                	test   %eax,%eax
80103ee0:	74 2a                	je     80103f0c <exit+0x69>
      fileclose(curproc->ofile[fd]);
80103ee2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ee5:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103ee8:	83 c2 08             	add    $0x8,%edx
80103eeb:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103eef:	83 ec 0c             	sub    $0xc,%esp
80103ef2:	50                   	push   %eax
80103ef3:	e8 9e d1 ff ff       	call   80101096 <fileclose>
80103ef8:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80103efb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103efe:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f01:	83 c2 08             	add    $0x8,%edx
80103f04:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80103f0b:	00 
  for(fd = 0; fd < NOFILE; fd++){
80103f0c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80103f10:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80103f14:	7e bb                	jle    80103ed1 <exit+0x2e>
    }
  }

  begin_op();
80103f16:	e8 1c f1 ff ff       	call   80103037 <begin_op>
  iput(curproc->cwd);
80103f1b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f1e:	8b 40 68             	mov    0x68(%eax),%eax
80103f21:	83 ec 0c             	sub    $0xc,%esp
80103f24:	50                   	push   %eax
80103f25:	e8 1c dc ff ff       	call   80101b46 <iput>
80103f2a:	83 c4 10             	add    $0x10,%esp
  end_op();
80103f2d:	e8 91 f1 ff ff       	call   801030c3 <end_op>
  curproc->cwd = 0;
80103f32:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f35:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80103f3c:	83 ec 0c             	sub    $0xc,%esp
80103f3f:	68 00 42 19 80       	push   $0x80194200
80103f44:	e8 ed 08 00 00       	call   80104836 <acquire>
80103f49:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80103f4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f4f:	8b 40 14             	mov    0x14(%eax),%eax
80103f52:	83 ec 0c             	sub    $0xc,%esp
80103f55:	50                   	push   %eax
80103f56:	e8 20 04 00 00       	call   8010437b <wakeup1>
80103f5b:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f5e:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103f65:	eb 37                	jmp    80103f9e <exit+0xfb>
    if(p->parent == curproc){
80103f67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f6a:	8b 40 14             	mov    0x14(%eax),%eax
80103f6d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103f70:	75 28                	jne    80103f9a <exit+0xf7>
      p->parent = initproc;
80103f72:	8b 15 34 62 19 80    	mov    0x80196234,%edx
80103f78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f7b:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80103f7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f81:	8b 40 0c             	mov    0xc(%eax),%eax
80103f84:	83 f8 05             	cmp    $0x5,%eax
80103f87:	75 11                	jne    80103f9a <exit+0xf7>
        wakeup1(initproc);
80103f89:	a1 34 62 19 80       	mov    0x80196234,%eax
80103f8e:	83 ec 0c             	sub    $0xc,%esp
80103f91:	50                   	push   %eax
80103f92:	e8 e4 03 00 00       	call   8010437b <wakeup1>
80103f97:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f9a:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80103f9e:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
80103fa5:	72 c0                	jb     80103f67 <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80103fa7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103faa:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80103fb1:	e8 e5 01 00 00       	call   8010419b <sched>
  panic("zombie exit");
80103fb6:	83 ec 0c             	sub    $0xc,%esp
80103fb9:	68 ff a3 10 80       	push   $0x8010a3ff
80103fbe:	e8 e6 c5 ff ff       	call   801005a9 <panic>

80103fc3 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80103fc3:	55                   	push   %ebp
80103fc4:	89 e5                	mov    %esp,%ebp
80103fc6:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80103fc9:	e8 5d fa ff ff       	call   80103a2b <myproc>
80103fce:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80103fd1:	83 ec 0c             	sub    $0xc,%esp
80103fd4:	68 00 42 19 80       	push   $0x80194200
80103fd9:	e8 58 08 00 00       	call   80104836 <acquire>
80103fde:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80103fe1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103fe8:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103fef:	e9 a1 00 00 00       	jmp    80104095 <wait+0xd2>
      if(p->parent != curproc)
80103ff4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ff7:	8b 40 14             	mov    0x14(%eax),%eax
80103ffa:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103ffd:	0f 85 8d 00 00 00    	jne    80104090 <wait+0xcd>
        continue;
      havekids = 1;
80104003:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010400a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010400d:	8b 40 0c             	mov    0xc(%eax),%eax
80104010:	83 f8 05             	cmp    $0x5,%eax
80104013:	75 7c                	jne    80104091 <wait+0xce>
        // Found one.
        pid = p->pid;
80104015:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104018:	8b 40 10             	mov    0x10(%eax),%eax
8010401b:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
8010401e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104021:	8b 40 08             	mov    0x8(%eax),%eax
80104024:	83 ec 0c             	sub    $0xc,%esp
80104027:	50                   	push   %eax
80104028:	e8 d4 e6 ff ff       	call   80102701 <kfree>
8010402d:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104030:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104033:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010403a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010403d:	8b 40 04             	mov    0x4(%eax),%eax
80104040:	83 ec 0c             	sub    $0xc,%esp
80104043:	50                   	push   %eax
80104044:	e8 6a 39 00 00       	call   801079b3 <freevm>
80104049:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
8010404c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010404f:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104056:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104059:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104060:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104063:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104067:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010406a:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104074:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
8010407b:	83 ec 0c             	sub    $0xc,%esp
8010407e:	68 00 42 19 80       	push   $0x80194200
80104083:	e8 1c 08 00 00       	call   801048a4 <release>
80104088:	83 c4 10             	add    $0x10,%esp
        return pid;
8010408b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010408e:	eb 51                	jmp    801040e1 <wait+0x11e>
        continue;
80104090:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104091:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104095:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
8010409c:	0f 82 52 ff ff ff    	jb     80103ff4 <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801040a2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801040a6:	74 0a                	je     801040b2 <wait+0xef>
801040a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040ab:	8b 40 24             	mov    0x24(%eax),%eax
801040ae:	85 c0                	test   %eax,%eax
801040b0:	74 17                	je     801040c9 <wait+0x106>
      release(&ptable.lock);
801040b2:	83 ec 0c             	sub    $0xc,%esp
801040b5:	68 00 42 19 80       	push   $0x80194200
801040ba:	e8 e5 07 00 00       	call   801048a4 <release>
801040bf:	83 c4 10             	add    $0x10,%esp
      return -1;
801040c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040c7:	eb 18                	jmp    801040e1 <wait+0x11e>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801040c9:	83 ec 08             	sub    $0x8,%esp
801040cc:	68 00 42 19 80       	push   $0x80194200
801040d1:	ff 75 ec             	push   -0x14(%ebp)
801040d4:	e8 fb 01 00 00       	call   801042d4 <sleep>
801040d9:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801040dc:	e9 00 ff ff ff       	jmp    80103fe1 <wait+0x1e>
  }
}
801040e1:	c9                   	leave  
801040e2:	c3                   	ret    

801040e3 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801040e3:	55                   	push   %ebp
801040e4:	89 e5                	mov    %esp,%ebp
801040e6:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801040e9:	e8 c5 f8 ff ff       	call   801039b3 <mycpu>
801040ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
801040f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040f4:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801040fb:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
801040fe:	e8 70 f8 ff ff       	call   80103973 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104103:	83 ec 0c             	sub    $0xc,%esp
80104106:	68 00 42 19 80       	push   $0x80194200
8010410b:	e8 26 07 00 00       	call   80104836 <acquire>
80104110:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104113:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
8010411a:	eb 61                	jmp    8010417d <scheduler+0x9a>
      if(p->state != RUNNABLE)
8010411c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010411f:	8b 40 0c             	mov    0xc(%eax),%eax
80104122:	83 f8 03             	cmp    $0x3,%eax
80104125:	75 51                	jne    80104178 <scheduler+0x95>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104127:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010412a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010412d:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104133:	83 ec 0c             	sub    $0xc,%esp
80104136:	ff 75 f4             	push   -0xc(%ebp)
80104139:	e8 ce 33 00 00       	call   8010750c <switchuvm>
8010413e:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104141:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104144:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
8010414b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010414e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104151:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104154:	83 c2 04             	add    $0x4,%edx
80104157:	83 ec 08             	sub    $0x8,%esp
8010415a:	50                   	push   %eax
8010415b:	52                   	push   %edx
8010415c:	e8 c0 0b 00 00       	call   80104d21 <swtch>
80104161:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104164:	e8 8a 33 00 00       	call   801074f3 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104169:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010416c:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104173:	00 00 00 
80104176:	eb 01                	jmp    80104179 <scheduler+0x96>
        continue;
80104178:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104179:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
8010417d:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
80104184:	72 96                	jb     8010411c <scheduler+0x39>
    }
    release(&ptable.lock);
80104186:	83 ec 0c             	sub    $0xc,%esp
80104189:	68 00 42 19 80       	push   $0x80194200
8010418e:	e8 11 07 00 00       	call   801048a4 <release>
80104193:	83 c4 10             	add    $0x10,%esp
    sti();
80104196:	e9 63 ff ff ff       	jmp    801040fe <scheduler+0x1b>

8010419b <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
8010419b:	55                   	push   %ebp
8010419c:	89 e5                	mov    %esp,%ebp
8010419e:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
801041a1:	e8 85 f8 ff ff       	call   80103a2b <myproc>
801041a6:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
801041a9:	83 ec 0c             	sub    $0xc,%esp
801041ac:	68 00 42 19 80       	push   $0x80194200
801041b1:	e8 bb 07 00 00       	call   80104971 <holding>
801041b6:	83 c4 10             	add    $0x10,%esp
801041b9:	85 c0                	test   %eax,%eax
801041bb:	75 0d                	jne    801041ca <sched+0x2f>
    panic("sched ptable.lock");
801041bd:	83 ec 0c             	sub    $0xc,%esp
801041c0:	68 0b a4 10 80       	push   $0x8010a40b
801041c5:	e8 df c3 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
801041ca:	e8 e4 f7 ff ff       	call   801039b3 <mycpu>
801041cf:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801041d5:	83 f8 01             	cmp    $0x1,%eax
801041d8:	74 0d                	je     801041e7 <sched+0x4c>
    panic("sched locks");
801041da:	83 ec 0c             	sub    $0xc,%esp
801041dd:	68 1d a4 10 80       	push   $0x8010a41d
801041e2:	e8 c2 c3 ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
801041e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041ea:	8b 40 0c             	mov    0xc(%eax),%eax
801041ed:	83 f8 04             	cmp    $0x4,%eax
801041f0:	75 0d                	jne    801041ff <sched+0x64>
    panic("sched running");
801041f2:	83 ec 0c             	sub    $0xc,%esp
801041f5:	68 29 a4 10 80       	push   $0x8010a429
801041fa:	e8 aa c3 ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
801041ff:	e8 5f f7 ff ff       	call   80103963 <readeflags>
80104204:	25 00 02 00 00       	and    $0x200,%eax
80104209:	85 c0                	test   %eax,%eax
8010420b:	74 0d                	je     8010421a <sched+0x7f>
    panic("sched interruptible");
8010420d:	83 ec 0c             	sub    $0xc,%esp
80104210:	68 37 a4 10 80       	push   $0x8010a437
80104215:	e8 8f c3 ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
8010421a:	e8 94 f7 ff ff       	call   801039b3 <mycpu>
8010421f:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104225:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104228:	e8 86 f7 ff ff       	call   801039b3 <mycpu>
8010422d:	8b 40 04             	mov    0x4(%eax),%eax
80104230:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104233:	83 c2 1c             	add    $0x1c,%edx
80104236:	83 ec 08             	sub    $0x8,%esp
80104239:	50                   	push   %eax
8010423a:	52                   	push   %edx
8010423b:	e8 e1 0a 00 00       	call   80104d21 <swtch>
80104240:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104243:	e8 6b f7 ff ff       	call   801039b3 <mycpu>
80104248:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010424b:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104251:	90                   	nop
80104252:	c9                   	leave  
80104253:	c3                   	ret    

80104254 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104254:	55                   	push   %ebp
80104255:	89 e5                	mov    %esp,%ebp
80104257:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
8010425a:	83 ec 0c             	sub    $0xc,%esp
8010425d:	68 00 42 19 80       	push   $0x80194200
80104262:	e8 cf 05 00 00       	call   80104836 <acquire>
80104267:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
8010426a:	e8 bc f7 ff ff       	call   80103a2b <myproc>
8010426f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104276:	e8 20 ff ff ff       	call   8010419b <sched>
  release(&ptable.lock);
8010427b:	83 ec 0c             	sub    $0xc,%esp
8010427e:	68 00 42 19 80       	push   $0x80194200
80104283:	e8 1c 06 00 00       	call   801048a4 <release>
80104288:	83 c4 10             	add    $0x10,%esp
}
8010428b:	90                   	nop
8010428c:	c9                   	leave  
8010428d:	c3                   	ret    

8010428e <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010428e:	55                   	push   %ebp
8010428f:	89 e5                	mov    %esp,%ebp
80104291:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104294:	83 ec 0c             	sub    $0xc,%esp
80104297:	68 00 42 19 80       	push   $0x80194200
8010429c:	e8 03 06 00 00       	call   801048a4 <release>
801042a1:	83 c4 10             	add    $0x10,%esp

  if (first) {
801042a4:	a1 04 f0 10 80       	mov    0x8010f004,%eax
801042a9:	85 c0                	test   %eax,%eax
801042ab:	74 24                	je     801042d1 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801042ad:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
801042b4:	00 00 00 
    iinit(ROOTDEV);
801042b7:	83 ec 0c             	sub    $0xc,%esp
801042ba:	6a 01                	push   $0x1
801042bc:	e8 b2 d3 ff ff       	call   80101673 <iinit>
801042c1:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801042c4:	83 ec 0c             	sub    $0xc,%esp
801042c7:	6a 01                	push   $0x1
801042c9:	e8 4a eb ff ff       	call   80102e18 <initlog>
801042ce:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801042d1:	90                   	nop
801042d2:	c9                   	leave  
801042d3:	c3                   	ret    

801042d4 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801042d4:	55                   	push   %ebp
801042d5:	89 e5                	mov    %esp,%ebp
801042d7:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
801042da:	e8 4c f7 ff ff       	call   80103a2b <myproc>
801042df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
801042e2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801042e6:	75 0d                	jne    801042f5 <sleep+0x21>
    panic("sleep");
801042e8:	83 ec 0c             	sub    $0xc,%esp
801042eb:	68 4b a4 10 80       	push   $0x8010a44b
801042f0:	e8 b4 c2 ff ff       	call   801005a9 <panic>

  if(lk == 0)
801042f5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801042f9:	75 0d                	jne    80104308 <sleep+0x34>
    panic("sleep without lk");
801042fb:	83 ec 0c             	sub    $0xc,%esp
801042fe:	68 51 a4 10 80       	push   $0x8010a451
80104303:	e8 a1 c2 ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104308:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
8010430f:	74 1e                	je     8010432f <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104311:	83 ec 0c             	sub    $0xc,%esp
80104314:	68 00 42 19 80       	push   $0x80194200
80104319:	e8 18 05 00 00       	call   80104836 <acquire>
8010431e:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104321:	83 ec 0c             	sub    $0xc,%esp
80104324:	ff 75 0c             	push   0xc(%ebp)
80104327:	e8 78 05 00 00       	call   801048a4 <release>
8010432c:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
8010432f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104332:	8b 55 08             	mov    0x8(%ebp),%edx
80104335:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104338:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010433b:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104342:	e8 54 fe ff ff       	call   8010419b <sched>

  // Tidy up.
  p->chan = 0;
80104347:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010434a:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104351:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
80104358:	74 1e                	je     80104378 <sleep+0xa4>
    release(&ptable.lock);
8010435a:	83 ec 0c             	sub    $0xc,%esp
8010435d:	68 00 42 19 80       	push   $0x80194200
80104362:	e8 3d 05 00 00       	call   801048a4 <release>
80104367:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
8010436a:	83 ec 0c             	sub    $0xc,%esp
8010436d:	ff 75 0c             	push   0xc(%ebp)
80104370:	e8 c1 04 00 00       	call   80104836 <acquire>
80104375:	83 c4 10             	add    $0x10,%esp
  }
}
80104378:	90                   	nop
80104379:	c9                   	leave  
8010437a:	c3                   	ret    

8010437b <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
8010437b:	55                   	push   %ebp
8010437c:	89 e5                	mov    %esp,%ebp
8010437e:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104381:	c7 45 fc 34 42 19 80 	movl   $0x80194234,-0x4(%ebp)
80104388:	eb 24                	jmp    801043ae <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
8010438a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010438d:	8b 40 0c             	mov    0xc(%eax),%eax
80104390:	83 f8 02             	cmp    $0x2,%eax
80104393:	75 15                	jne    801043aa <wakeup1+0x2f>
80104395:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104398:	8b 40 20             	mov    0x20(%eax),%eax
8010439b:	39 45 08             	cmp    %eax,0x8(%ebp)
8010439e:	75 0a                	jne    801043aa <wakeup1+0x2f>
      p->state = RUNNABLE;
801043a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801043a3:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043aa:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
801043ae:	81 7d fc 34 62 19 80 	cmpl   $0x80196234,-0x4(%ebp)
801043b5:	72 d3                	jb     8010438a <wakeup1+0xf>
}
801043b7:	90                   	nop
801043b8:	90                   	nop
801043b9:	c9                   	leave  
801043ba:	c3                   	ret    

801043bb <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801043bb:	55                   	push   %ebp
801043bc:	89 e5                	mov    %esp,%ebp
801043be:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801043c1:	83 ec 0c             	sub    $0xc,%esp
801043c4:	68 00 42 19 80       	push   $0x80194200
801043c9:	e8 68 04 00 00       	call   80104836 <acquire>
801043ce:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801043d1:	83 ec 0c             	sub    $0xc,%esp
801043d4:	ff 75 08             	push   0x8(%ebp)
801043d7:	e8 9f ff ff ff       	call   8010437b <wakeup1>
801043dc:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801043df:	83 ec 0c             	sub    $0xc,%esp
801043e2:	68 00 42 19 80       	push   $0x80194200
801043e7:	e8 b8 04 00 00       	call   801048a4 <release>
801043ec:	83 c4 10             	add    $0x10,%esp
}
801043ef:	90                   	nop
801043f0:	c9                   	leave  
801043f1:	c3                   	ret    

801043f2 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801043f2:	55                   	push   %ebp
801043f3:	89 e5                	mov    %esp,%ebp
801043f5:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801043f8:	83 ec 0c             	sub    $0xc,%esp
801043fb:	68 00 42 19 80       	push   $0x80194200
80104400:	e8 31 04 00 00       	call   80104836 <acquire>
80104405:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104408:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
8010440f:	eb 45                	jmp    80104456 <kill+0x64>
    if(p->pid == pid){
80104411:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104414:	8b 40 10             	mov    0x10(%eax),%eax
80104417:	39 45 08             	cmp    %eax,0x8(%ebp)
8010441a:	75 36                	jne    80104452 <kill+0x60>
      p->killed = 1;
8010441c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010441f:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104426:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104429:	8b 40 0c             	mov    0xc(%eax),%eax
8010442c:	83 f8 02             	cmp    $0x2,%eax
8010442f:	75 0a                	jne    8010443b <kill+0x49>
        p->state = RUNNABLE;
80104431:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104434:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
8010443b:	83 ec 0c             	sub    $0xc,%esp
8010443e:	68 00 42 19 80       	push   $0x80194200
80104443:	e8 5c 04 00 00       	call   801048a4 <release>
80104448:	83 c4 10             	add    $0x10,%esp
      return 0;
8010444b:	b8 00 00 00 00       	mov    $0x0,%eax
80104450:	eb 22                	jmp    80104474 <kill+0x82>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104452:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104456:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
8010445d:	72 b2                	jb     80104411 <kill+0x1f>
    }
  }
  release(&ptable.lock);
8010445f:	83 ec 0c             	sub    $0xc,%esp
80104462:	68 00 42 19 80       	push   $0x80194200
80104467:	e8 38 04 00 00       	call   801048a4 <release>
8010446c:	83 c4 10             	add    $0x10,%esp
  return -1;
8010446f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104474:	c9                   	leave  
80104475:	c3                   	ret    

80104476 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104476:	55                   	push   %ebp
80104477:	89 e5                	mov    %esp,%ebp
80104479:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010447c:	c7 45 f0 34 42 19 80 	movl   $0x80194234,-0x10(%ebp)
80104483:	e9 d7 00 00 00       	jmp    8010455f <procdump+0xe9>
    if(p->state == UNUSED)
80104488:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010448b:	8b 40 0c             	mov    0xc(%eax),%eax
8010448e:	85 c0                	test   %eax,%eax
80104490:	0f 84 c4 00 00 00    	je     8010455a <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104496:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104499:	8b 40 0c             	mov    0xc(%eax),%eax
8010449c:	83 f8 05             	cmp    $0x5,%eax
8010449f:	77 23                	ja     801044c4 <procdump+0x4e>
801044a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044a4:	8b 40 0c             	mov    0xc(%eax),%eax
801044a7:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801044ae:	85 c0                	test   %eax,%eax
801044b0:	74 12                	je     801044c4 <procdump+0x4e>
      state = states[p->state];
801044b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044b5:	8b 40 0c             	mov    0xc(%eax),%eax
801044b8:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801044bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
801044c2:	eb 07                	jmp    801044cb <procdump+0x55>
    else
      state = "???";
801044c4:	c7 45 ec 62 a4 10 80 	movl   $0x8010a462,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801044cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044ce:	8d 50 6c             	lea    0x6c(%eax),%edx
801044d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044d4:	8b 40 10             	mov    0x10(%eax),%eax
801044d7:	52                   	push   %edx
801044d8:	ff 75 ec             	push   -0x14(%ebp)
801044db:	50                   	push   %eax
801044dc:	68 66 a4 10 80       	push   $0x8010a466
801044e1:	e8 0e bf ff ff       	call   801003f4 <cprintf>
801044e6:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801044e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044ec:	8b 40 0c             	mov    0xc(%eax),%eax
801044ef:	83 f8 02             	cmp    $0x2,%eax
801044f2:	75 54                	jne    80104548 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801044f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044f7:	8b 40 1c             	mov    0x1c(%eax),%eax
801044fa:	8b 40 0c             	mov    0xc(%eax),%eax
801044fd:	83 c0 08             	add    $0x8,%eax
80104500:	89 c2                	mov    %eax,%edx
80104502:	83 ec 08             	sub    $0x8,%esp
80104505:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104508:	50                   	push   %eax
80104509:	52                   	push   %edx
8010450a:	e8 e7 03 00 00       	call   801048f6 <getcallerpcs>
8010450f:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104512:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104519:	eb 1c                	jmp    80104537 <procdump+0xc1>
        cprintf(" %p", pc[i]);
8010451b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451e:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104522:	83 ec 08             	sub    $0x8,%esp
80104525:	50                   	push   %eax
80104526:	68 6f a4 10 80       	push   $0x8010a46f
8010452b:	e8 c4 be ff ff       	call   801003f4 <cprintf>
80104530:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104533:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104537:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010453b:	7f 0b                	jg     80104548 <procdump+0xd2>
8010453d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104540:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104544:	85 c0                	test   %eax,%eax
80104546:	75 d3                	jne    8010451b <procdump+0xa5>
    }
    cprintf("\n");
80104548:	83 ec 0c             	sub    $0xc,%esp
8010454b:	68 73 a4 10 80       	push   $0x8010a473
80104550:	e8 9f be ff ff       	call   801003f4 <cprintf>
80104555:	83 c4 10             	add    $0x10,%esp
80104558:	eb 01                	jmp    8010455b <procdump+0xe5>
      continue;
8010455a:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010455b:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
8010455f:	81 7d f0 34 62 19 80 	cmpl   $0x80196234,-0x10(%ebp)
80104566:	0f 82 1c ff ff ff    	jb     80104488 <procdump+0x12>
  }
}
8010456c:	90                   	nop
8010456d:	90                   	nop
8010456e:	c9                   	leave  
8010456f:	c3                   	ret    

80104570 <printpt>:

int
printpt(int pid)
{
80104570:	55                   	push   %ebp
80104571:	89 e5                	mov    %esp,%ebp
80104573:	53                   	push   %ebx
80104574:	83 ec 14             	sub    $0x14,%esp
  pde_t* pgdir = myproc()->pgdir;
80104577:	e8 af f4 ff ff       	call   80103a2b <myproc>
8010457c:	8b 40 04             	mov    0x4(%eax),%eax
8010457f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  cprintf("START PAGE TABLE (pid %d)\n", pid);
80104582:	83 ec 08             	sub    $0x8,%esp
80104585:	ff 75 08             	push   0x8(%ebp)
80104588:	68 75 a4 10 80       	push   $0x8010a475
8010458d:	e8 62 be ff ff       	call   801003f4 <cprintf>
80104592:	83 c4 10             	add    $0x10,%esp
  
  // 유저영역의 페이지 디렉토리를 조사한다.
  for (uint i = 0; i < NPDENTRIES / 2; i++) {
80104595:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010459c:	e9 ef 00 00 00       	jmp    80104690 <printpt+0x120>

    // 활성화 된 페이지 디렉토리이면
    if (pgdir[i] & PTE_P) {
801045a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801045ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
801045ae:	01 d0                	add    %edx,%eax
801045b0:	8b 00                	mov    (%eax),%eax
801045b2:	83 e0 01             	and    $0x1,%eax
801045b5:	85 c0                	test   %eax,%eax
801045b7:	0f 84 cf 00 00 00    	je     8010468c <printpt+0x11c>
      
      // 해당 주소의 페이지 테이블을 가져온다.
      pte_t* pgtab = (pte_t*)P2V(PTE_ADDR(pgdir[i]));
801045bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801045c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801045ca:	01 d0                	add    %edx,%eax
801045cc:	8b 00                	mov    (%eax),%eax
801045ce:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801045d3:	05 00 00 00 80       	add    $0x80000000,%eax
801045d8:	89 45 e8             	mov    %eax,-0x18(%ebp)
      
      // 페이지 테이블의 개수 1024개를 모두 조사한다.
      for (uint j = 0; j < NPTENTRIES; j++) {
801045db:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801045e2:	e9 98 00 00 00       	jmp    8010467f <printpt+0x10f>
        
        if (pgtab[j] & PTE_P) {
801045e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045ea:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801045f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801045f4:	01 d0                	add    %edx,%eax
801045f6:	8b 00                	mov    (%eax),%eax
801045f8:	83 e0 01             	and    $0x1,%eax
801045fb:	85 c0                	test   %eax,%eax
801045fd:	74 7c                	je     8010467b <printpt+0x10b>
          cprintf("%x %s %s %s %x\n", j, "P", (pgtab[j] & PTE_U) ? "U" : "K", (pgtab[j] & PTE_W) ? "W" : "-", PTX(pgtab[j]));
801045ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104602:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104609:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010460c:	01 d0                	add    %edx,%eax
8010460e:	8b 00                	mov    (%eax),%eax
80104610:	c1 e8 0c             	shr    $0xc,%eax
80104613:	25 ff 03 00 00       	and    $0x3ff,%eax
80104618:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010461b:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
80104622:	8b 55 e8             	mov    -0x18(%ebp),%edx
80104625:	01 ca                	add    %ecx,%edx
80104627:	8b 12                	mov    (%edx),%edx
80104629:	83 e2 02             	and    $0x2,%edx
8010462c:	85 d2                	test   %edx,%edx
8010462e:	74 07                	je     80104637 <printpt+0xc7>
80104630:	b9 90 a4 10 80       	mov    $0x8010a490,%ecx
80104635:	eb 05                	jmp    8010463c <printpt+0xcc>
80104637:	b9 92 a4 10 80       	mov    $0x8010a492,%ecx
8010463c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010463f:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
80104646:	8b 55 e8             	mov    -0x18(%ebp),%edx
80104649:	01 da                	add    %ebx,%edx
8010464b:	8b 12                	mov    (%edx),%edx
8010464d:	83 e2 04             	and    $0x4,%edx
80104650:	85 d2                	test   %edx,%edx
80104652:	74 07                	je     8010465b <printpt+0xeb>
80104654:	ba 94 a4 10 80       	mov    $0x8010a494,%edx
80104659:	eb 05                	jmp    80104660 <printpt+0xf0>
8010465b:	ba 96 a4 10 80       	mov    $0x8010a496,%edx
80104660:	83 ec 08             	sub    $0x8,%esp
80104663:	50                   	push   %eax
80104664:	51                   	push   %ecx
80104665:	52                   	push   %edx
80104666:	68 98 a4 10 80       	push   $0x8010a498
8010466b:	ff 75 f0             	push   -0x10(%ebp)
8010466e:	68 9a a4 10 80       	push   $0x8010a49a
80104673:	e8 7c bd ff ff       	call   801003f4 <cprintf>
80104678:	83 c4 20             	add    $0x20,%esp
      for (uint j = 0; j < NPTENTRIES; j++) {
8010467b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010467f:	81 7d f0 ff 03 00 00 	cmpl   $0x3ff,-0x10(%ebp)
80104686:	0f 86 5b ff ff ff    	jbe    801045e7 <printpt+0x77>
  for (uint i = 0; i < NPDENTRIES / 2; i++) {
8010468c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104690:	81 7d f4 ff 01 00 00 	cmpl   $0x1ff,-0xc(%ebp)
80104697:	0f 86 04 ff ff ff    	jbe    801045a1 <printpt+0x31>
        }
      }
    }
  }
  cprintf("END PAGE TABLE\n");
8010469d:	83 ec 0c             	sub    $0xc,%esp
801046a0:	68 aa a4 10 80       	push   $0x8010a4aa
801046a5:	e8 4a bd ff ff       	call   801003f4 <cprintf>
801046aa:	83 c4 10             	add    $0x10,%esp
  return 0;
801046ad:	b8 00 00 00 00       	mov    $0x0,%eax
801046b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801046b5:	c9                   	leave  
801046b6:	c3                   	ret    

801046b7 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801046b7:	55                   	push   %ebp
801046b8:	89 e5                	mov    %esp,%ebp
801046ba:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
801046bd:	8b 45 08             	mov    0x8(%ebp),%eax
801046c0:	83 c0 04             	add    $0x4,%eax
801046c3:	83 ec 08             	sub    $0x8,%esp
801046c6:	68 e4 a4 10 80       	push   $0x8010a4e4
801046cb:	50                   	push   %eax
801046cc:	e8 43 01 00 00       	call   80104814 <initlock>
801046d1:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
801046d4:	8b 45 08             	mov    0x8(%ebp),%eax
801046d7:	8b 55 0c             	mov    0xc(%ebp),%edx
801046da:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
801046dd:	8b 45 08             	mov    0x8(%ebp),%eax
801046e0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801046e6:	8b 45 08             	mov    0x8(%ebp),%eax
801046e9:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
801046f0:	90                   	nop
801046f1:	c9                   	leave  
801046f2:	c3                   	ret    

801046f3 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801046f3:	55                   	push   %ebp
801046f4:	89 e5                	mov    %esp,%ebp
801046f6:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801046f9:	8b 45 08             	mov    0x8(%ebp),%eax
801046fc:	83 c0 04             	add    $0x4,%eax
801046ff:	83 ec 0c             	sub    $0xc,%esp
80104702:	50                   	push   %eax
80104703:	e8 2e 01 00 00       	call   80104836 <acquire>
80104708:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
8010470b:	eb 15                	jmp    80104722 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
8010470d:	8b 45 08             	mov    0x8(%ebp),%eax
80104710:	83 c0 04             	add    $0x4,%eax
80104713:	83 ec 08             	sub    $0x8,%esp
80104716:	50                   	push   %eax
80104717:	ff 75 08             	push   0x8(%ebp)
8010471a:	e8 b5 fb ff ff       	call   801042d4 <sleep>
8010471f:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104722:	8b 45 08             	mov    0x8(%ebp),%eax
80104725:	8b 00                	mov    (%eax),%eax
80104727:	85 c0                	test   %eax,%eax
80104729:	75 e2                	jne    8010470d <acquiresleep+0x1a>
  }
  lk->locked = 1;
8010472b:	8b 45 08             	mov    0x8(%ebp),%eax
8010472e:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104734:	e8 f2 f2 ff ff       	call   80103a2b <myproc>
80104739:	8b 50 10             	mov    0x10(%eax),%edx
8010473c:	8b 45 08             	mov    0x8(%ebp),%eax
8010473f:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104742:	8b 45 08             	mov    0x8(%ebp),%eax
80104745:	83 c0 04             	add    $0x4,%eax
80104748:	83 ec 0c             	sub    $0xc,%esp
8010474b:	50                   	push   %eax
8010474c:	e8 53 01 00 00       	call   801048a4 <release>
80104751:	83 c4 10             	add    $0x10,%esp
}
80104754:	90                   	nop
80104755:	c9                   	leave  
80104756:	c3                   	ret    

80104757 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104757:	55                   	push   %ebp
80104758:	89 e5                	mov    %esp,%ebp
8010475a:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
8010475d:	8b 45 08             	mov    0x8(%ebp),%eax
80104760:	83 c0 04             	add    $0x4,%eax
80104763:	83 ec 0c             	sub    $0xc,%esp
80104766:	50                   	push   %eax
80104767:	e8 ca 00 00 00       	call   80104836 <acquire>
8010476c:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
8010476f:	8b 45 08             	mov    0x8(%ebp),%eax
80104772:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104778:	8b 45 08             	mov    0x8(%ebp),%eax
8010477b:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104782:	83 ec 0c             	sub    $0xc,%esp
80104785:	ff 75 08             	push   0x8(%ebp)
80104788:	e8 2e fc ff ff       	call   801043bb <wakeup>
8010478d:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104790:	8b 45 08             	mov    0x8(%ebp),%eax
80104793:	83 c0 04             	add    $0x4,%eax
80104796:	83 ec 0c             	sub    $0xc,%esp
80104799:	50                   	push   %eax
8010479a:	e8 05 01 00 00       	call   801048a4 <release>
8010479f:	83 c4 10             	add    $0x10,%esp
}
801047a2:	90                   	nop
801047a3:	c9                   	leave  
801047a4:	c3                   	ret    

801047a5 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801047a5:	55                   	push   %ebp
801047a6:	89 e5                	mov    %esp,%ebp
801047a8:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
801047ab:	8b 45 08             	mov    0x8(%ebp),%eax
801047ae:	83 c0 04             	add    $0x4,%eax
801047b1:	83 ec 0c             	sub    $0xc,%esp
801047b4:	50                   	push   %eax
801047b5:	e8 7c 00 00 00       	call   80104836 <acquire>
801047ba:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
801047bd:	8b 45 08             	mov    0x8(%ebp),%eax
801047c0:	8b 00                	mov    (%eax),%eax
801047c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
801047c5:	8b 45 08             	mov    0x8(%ebp),%eax
801047c8:	83 c0 04             	add    $0x4,%eax
801047cb:	83 ec 0c             	sub    $0xc,%esp
801047ce:	50                   	push   %eax
801047cf:	e8 d0 00 00 00       	call   801048a4 <release>
801047d4:	83 c4 10             	add    $0x10,%esp
  return r;
801047d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801047da:	c9                   	leave  
801047db:	c3                   	ret    

801047dc <readeflags>:
{
801047dc:	55                   	push   %ebp
801047dd:	89 e5                	mov    %esp,%ebp
801047df:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801047e2:	9c                   	pushf  
801047e3:	58                   	pop    %eax
801047e4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801047e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801047ea:	c9                   	leave  
801047eb:	c3                   	ret    

801047ec <cli>:
{
801047ec:	55                   	push   %ebp
801047ed:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801047ef:	fa                   	cli    
}
801047f0:	90                   	nop
801047f1:	5d                   	pop    %ebp
801047f2:	c3                   	ret    

801047f3 <sti>:
{
801047f3:	55                   	push   %ebp
801047f4:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801047f6:	fb                   	sti    
}
801047f7:	90                   	nop
801047f8:	5d                   	pop    %ebp
801047f9:	c3                   	ret    

801047fa <xchg>:
{
801047fa:	55                   	push   %ebp
801047fb:	89 e5                	mov    %esp,%ebp
801047fd:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104800:	8b 55 08             	mov    0x8(%ebp),%edx
80104803:	8b 45 0c             	mov    0xc(%ebp),%eax
80104806:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104809:	f0 87 02             	lock xchg %eax,(%edx)
8010480c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
8010480f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104812:	c9                   	leave  
80104813:	c3                   	ret    

80104814 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104814:	55                   	push   %ebp
80104815:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104817:	8b 45 08             	mov    0x8(%ebp),%eax
8010481a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010481d:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104820:	8b 45 08             	mov    0x8(%ebp),%eax
80104823:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104829:	8b 45 08             	mov    0x8(%ebp),%eax
8010482c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104833:	90                   	nop
80104834:	5d                   	pop    %ebp
80104835:	c3                   	ret    

80104836 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104836:	55                   	push   %ebp
80104837:	89 e5                	mov    %esp,%ebp
80104839:	53                   	push   %ebx
8010483a:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010483d:	e8 5f 01 00 00       	call   801049a1 <pushcli>
  if(holding(lk)){
80104842:	8b 45 08             	mov    0x8(%ebp),%eax
80104845:	83 ec 0c             	sub    $0xc,%esp
80104848:	50                   	push   %eax
80104849:	e8 23 01 00 00       	call   80104971 <holding>
8010484e:	83 c4 10             	add    $0x10,%esp
80104851:	85 c0                	test   %eax,%eax
80104853:	74 0d                	je     80104862 <acquire+0x2c>
    panic("acquire");
80104855:	83 ec 0c             	sub    $0xc,%esp
80104858:	68 ef a4 10 80       	push   $0x8010a4ef
8010485d:	e8 47 bd ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104862:	90                   	nop
80104863:	8b 45 08             	mov    0x8(%ebp),%eax
80104866:	83 ec 08             	sub    $0x8,%esp
80104869:	6a 01                	push   $0x1
8010486b:	50                   	push   %eax
8010486c:	e8 89 ff ff ff       	call   801047fa <xchg>
80104871:	83 c4 10             	add    $0x10,%esp
80104874:	85 c0                	test   %eax,%eax
80104876:	75 eb                	jne    80104863 <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104878:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
8010487d:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104880:	e8 2e f1 ff ff       	call   801039b3 <mycpu>
80104885:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104888:	8b 45 08             	mov    0x8(%ebp),%eax
8010488b:	83 c0 0c             	add    $0xc,%eax
8010488e:	83 ec 08             	sub    $0x8,%esp
80104891:	50                   	push   %eax
80104892:	8d 45 08             	lea    0x8(%ebp),%eax
80104895:	50                   	push   %eax
80104896:	e8 5b 00 00 00       	call   801048f6 <getcallerpcs>
8010489b:	83 c4 10             	add    $0x10,%esp
}
8010489e:	90                   	nop
8010489f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801048a2:	c9                   	leave  
801048a3:	c3                   	ret    

801048a4 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801048a4:	55                   	push   %ebp
801048a5:	89 e5                	mov    %esp,%ebp
801048a7:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801048aa:	83 ec 0c             	sub    $0xc,%esp
801048ad:	ff 75 08             	push   0x8(%ebp)
801048b0:	e8 bc 00 00 00       	call   80104971 <holding>
801048b5:	83 c4 10             	add    $0x10,%esp
801048b8:	85 c0                	test   %eax,%eax
801048ba:	75 0d                	jne    801048c9 <release+0x25>
    panic("release");
801048bc:	83 ec 0c             	sub    $0xc,%esp
801048bf:	68 f7 a4 10 80       	push   $0x8010a4f7
801048c4:	e8 e0 bc ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
801048c9:	8b 45 08             	mov    0x8(%ebp),%eax
801048cc:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801048d3:	8b 45 08             	mov    0x8(%ebp),%eax
801048d6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801048dd:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801048e2:	8b 45 08             	mov    0x8(%ebp),%eax
801048e5:	8b 55 08             	mov    0x8(%ebp),%edx
801048e8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
801048ee:	e8 fb 00 00 00       	call   801049ee <popcli>
}
801048f3:	90                   	nop
801048f4:	c9                   	leave  
801048f5:	c3                   	ret    

801048f6 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801048f6:	55                   	push   %ebp
801048f7:	89 e5                	mov    %esp,%ebp
801048f9:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801048fc:	8b 45 08             	mov    0x8(%ebp),%eax
801048ff:	83 e8 08             	sub    $0x8,%eax
80104902:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104905:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010490c:	eb 38                	jmp    80104946 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
8010490e:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104912:	74 53                	je     80104967 <getcallerpcs+0x71>
80104914:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
8010491b:	76 4a                	jbe    80104967 <getcallerpcs+0x71>
8010491d:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104921:	74 44                	je     80104967 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104923:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104926:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010492d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104930:	01 c2                	add    %eax,%edx
80104932:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104935:	8b 40 04             	mov    0x4(%eax),%eax
80104938:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
8010493a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010493d:	8b 00                	mov    (%eax),%eax
8010493f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104942:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104946:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010494a:	7e c2                	jle    8010490e <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
8010494c:	eb 19                	jmp    80104967 <getcallerpcs+0x71>
    pcs[i] = 0;
8010494e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104951:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104958:	8b 45 0c             	mov    0xc(%ebp),%eax
8010495b:	01 d0                	add    %edx,%eax
8010495d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104963:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104967:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010496b:	7e e1                	jle    8010494e <getcallerpcs+0x58>
}
8010496d:	90                   	nop
8010496e:	90                   	nop
8010496f:	c9                   	leave  
80104970:	c3                   	ret    

80104971 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104971:	55                   	push   %ebp
80104972:	89 e5                	mov    %esp,%ebp
80104974:	53                   	push   %ebx
80104975:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104978:	8b 45 08             	mov    0x8(%ebp),%eax
8010497b:	8b 00                	mov    (%eax),%eax
8010497d:	85 c0                	test   %eax,%eax
8010497f:	74 16                	je     80104997 <holding+0x26>
80104981:	8b 45 08             	mov    0x8(%ebp),%eax
80104984:	8b 58 08             	mov    0x8(%eax),%ebx
80104987:	e8 27 f0 ff ff       	call   801039b3 <mycpu>
8010498c:	39 c3                	cmp    %eax,%ebx
8010498e:	75 07                	jne    80104997 <holding+0x26>
80104990:	b8 01 00 00 00       	mov    $0x1,%eax
80104995:	eb 05                	jmp    8010499c <holding+0x2b>
80104997:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010499c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010499f:	c9                   	leave  
801049a0:	c3                   	ret    

801049a1 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801049a1:	55                   	push   %ebp
801049a2:	89 e5                	mov    %esp,%ebp
801049a4:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
801049a7:	e8 30 fe ff ff       	call   801047dc <readeflags>
801049ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
801049af:	e8 38 fe ff ff       	call   801047ec <cli>
  if(mycpu()->ncli == 0)
801049b4:	e8 fa ef ff ff       	call   801039b3 <mycpu>
801049b9:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801049bf:	85 c0                	test   %eax,%eax
801049c1:	75 14                	jne    801049d7 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
801049c3:	e8 eb ef ff ff       	call   801039b3 <mycpu>
801049c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049cb:	81 e2 00 02 00 00    	and    $0x200,%edx
801049d1:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
801049d7:	e8 d7 ef ff ff       	call   801039b3 <mycpu>
801049dc:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801049e2:	83 c2 01             	add    $0x1,%edx
801049e5:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
801049eb:	90                   	nop
801049ec:	c9                   	leave  
801049ed:	c3                   	ret    

801049ee <popcli>:

void
popcli(void)
{
801049ee:	55                   	push   %ebp
801049ef:	89 e5                	mov    %esp,%ebp
801049f1:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
801049f4:	e8 e3 fd ff ff       	call   801047dc <readeflags>
801049f9:	25 00 02 00 00       	and    $0x200,%eax
801049fe:	85 c0                	test   %eax,%eax
80104a00:	74 0d                	je     80104a0f <popcli+0x21>
    panic("popcli - interruptible");
80104a02:	83 ec 0c             	sub    $0xc,%esp
80104a05:	68 ff a4 10 80       	push   $0x8010a4ff
80104a0a:	e8 9a bb ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
80104a0f:	e8 9f ef ff ff       	call   801039b3 <mycpu>
80104a14:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104a1a:	83 ea 01             	sub    $0x1,%edx
80104a1d:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104a23:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104a29:	85 c0                	test   %eax,%eax
80104a2b:	79 0d                	jns    80104a3a <popcli+0x4c>
    panic("popcli");
80104a2d:	83 ec 0c             	sub    $0xc,%esp
80104a30:	68 16 a5 10 80       	push   $0x8010a516
80104a35:	e8 6f bb ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104a3a:	e8 74 ef ff ff       	call   801039b3 <mycpu>
80104a3f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104a45:	85 c0                	test   %eax,%eax
80104a47:	75 14                	jne    80104a5d <popcli+0x6f>
80104a49:	e8 65 ef ff ff       	call   801039b3 <mycpu>
80104a4e:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104a54:	85 c0                	test   %eax,%eax
80104a56:	74 05                	je     80104a5d <popcli+0x6f>
    sti();
80104a58:	e8 96 fd ff ff       	call   801047f3 <sti>
}
80104a5d:	90                   	nop
80104a5e:	c9                   	leave  
80104a5f:	c3                   	ret    

80104a60 <stosb>:
{
80104a60:	55                   	push   %ebp
80104a61:	89 e5                	mov    %esp,%ebp
80104a63:	57                   	push   %edi
80104a64:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104a65:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104a68:	8b 55 10             	mov    0x10(%ebp),%edx
80104a6b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a6e:	89 cb                	mov    %ecx,%ebx
80104a70:	89 df                	mov    %ebx,%edi
80104a72:	89 d1                	mov    %edx,%ecx
80104a74:	fc                   	cld    
80104a75:	f3 aa                	rep stos %al,%es:(%edi)
80104a77:	89 ca                	mov    %ecx,%edx
80104a79:	89 fb                	mov    %edi,%ebx
80104a7b:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104a7e:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104a81:	90                   	nop
80104a82:	5b                   	pop    %ebx
80104a83:	5f                   	pop    %edi
80104a84:	5d                   	pop    %ebp
80104a85:	c3                   	ret    

80104a86 <stosl>:
{
80104a86:	55                   	push   %ebp
80104a87:	89 e5                	mov    %esp,%ebp
80104a89:	57                   	push   %edi
80104a8a:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104a8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104a8e:	8b 55 10             	mov    0x10(%ebp),%edx
80104a91:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a94:	89 cb                	mov    %ecx,%ebx
80104a96:	89 df                	mov    %ebx,%edi
80104a98:	89 d1                	mov    %edx,%ecx
80104a9a:	fc                   	cld    
80104a9b:	f3 ab                	rep stos %eax,%es:(%edi)
80104a9d:	89 ca                	mov    %ecx,%edx
80104a9f:	89 fb                	mov    %edi,%ebx
80104aa1:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104aa4:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104aa7:	90                   	nop
80104aa8:	5b                   	pop    %ebx
80104aa9:	5f                   	pop    %edi
80104aaa:	5d                   	pop    %ebp
80104aab:	c3                   	ret    

80104aac <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104aac:	55                   	push   %ebp
80104aad:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104aaf:	8b 45 08             	mov    0x8(%ebp),%eax
80104ab2:	83 e0 03             	and    $0x3,%eax
80104ab5:	85 c0                	test   %eax,%eax
80104ab7:	75 43                	jne    80104afc <memset+0x50>
80104ab9:	8b 45 10             	mov    0x10(%ebp),%eax
80104abc:	83 e0 03             	and    $0x3,%eax
80104abf:	85 c0                	test   %eax,%eax
80104ac1:	75 39                	jne    80104afc <memset+0x50>
    c &= 0xFF;
80104ac3:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104aca:	8b 45 10             	mov    0x10(%ebp),%eax
80104acd:	c1 e8 02             	shr    $0x2,%eax
80104ad0:	89 c2                	mov    %eax,%edx
80104ad2:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ad5:	c1 e0 18             	shl    $0x18,%eax
80104ad8:	89 c1                	mov    %eax,%ecx
80104ada:	8b 45 0c             	mov    0xc(%ebp),%eax
80104add:	c1 e0 10             	shl    $0x10,%eax
80104ae0:	09 c1                	or     %eax,%ecx
80104ae2:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ae5:	c1 e0 08             	shl    $0x8,%eax
80104ae8:	09 c8                	or     %ecx,%eax
80104aea:	0b 45 0c             	or     0xc(%ebp),%eax
80104aed:	52                   	push   %edx
80104aee:	50                   	push   %eax
80104aef:	ff 75 08             	push   0x8(%ebp)
80104af2:	e8 8f ff ff ff       	call   80104a86 <stosl>
80104af7:	83 c4 0c             	add    $0xc,%esp
80104afa:	eb 12                	jmp    80104b0e <memset+0x62>
  } else
    stosb(dst, c, n);
80104afc:	8b 45 10             	mov    0x10(%ebp),%eax
80104aff:	50                   	push   %eax
80104b00:	ff 75 0c             	push   0xc(%ebp)
80104b03:	ff 75 08             	push   0x8(%ebp)
80104b06:	e8 55 ff ff ff       	call   80104a60 <stosb>
80104b0b:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104b0e:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104b11:	c9                   	leave  
80104b12:	c3                   	ret    

80104b13 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104b13:	55                   	push   %ebp
80104b14:	89 e5                	mov    %esp,%ebp
80104b16:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104b19:	8b 45 08             	mov    0x8(%ebp),%eax
80104b1c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104b1f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b22:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104b25:	eb 30                	jmp    80104b57 <memcmp+0x44>
    if(*s1 != *s2)
80104b27:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b2a:	0f b6 10             	movzbl (%eax),%edx
80104b2d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104b30:	0f b6 00             	movzbl (%eax),%eax
80104b33:	38 c2                	cmp    %al,%dl
80104b35:	74 18                	je     80104b4f <memcmp+0x3c>
      return *s1 - *s2;
80104b37:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b3a:	0f b6 00             	movzbl (%eax),%eax
80104b3d:	0f b6 d0             	movzbl %al,%edx
80104b40:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104b43:	0f b6 00             	movzbl (%eax),%eax
80104b46:	0f b6 c8             	movzbl %al,%ecx
80104b49:	89 d0                	mov    %edx,%eax
80104b4b:	29 c8                	sub    %ecx,%eax
80104b4d:	eb 1a                	jmp    80104b69 <memcmp+0x56>
    s1++, s2++;
80104b4f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104b53:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104b57:	8b 45 10             	mov    0x10(%ebp),%eax
80104b5a:	8d 50 ff             	lea    -0x1(%eax),%edx
80104b5d:	89 55 10             	mov    %edx,0x10(%ebp)
80104b60:	85 c0                	test   %eax,%eax
80104b62:	75 c3                	jne    80104b27 <memcmp+0x14>
  }

  return 0;
80104b64:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b69:	c9                   	leave  
80104b6a:	c3                   	ret    

80104b6b <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104b6b:	55                   	push   %ebp
80104b6c:	89 e5                	mov    %esp,%ebp
80104b6e:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104b71:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b74:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104b77:	8b 45 08             	mov    0x8(%ebp),%eax
80104b7a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104b7d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b80:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104b83:	73 54                	jae    80104bd9 <memmove+0x6e>
80104b85:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104b88:	8b 45 10             	mov    0x10(%ebp),%eax
80104b8b:	01 d0                	add    %edx,%eax
80104b8d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104b90:	73 47                	jae    80104bd9 <memmove+0x6e>
    s += n;
80104b92:	8b 45 10             	mov    0x10(%ebp),%eax
80104b95:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104b98:	8b 45 10             	mov    0x10(%ebp),%eax
80104b9b:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104b9e:	eb 13                	jmp    80104bb3 <memmove+0x48>
      *--d = *--s;
80104ba0:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104ba4:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104ba8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bab:	0f b6 10             	movzbl (%eax),%edx
80104bae:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104bb1:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104bb3:	8b 45 10             	mov    0x10(%ebp),%eax
80104bb6:	8d 50 ff             	lea    -0x1(%eax),%edx
80104bb9:	89 55 10             	mov    %edx,0x10(%ebp)
80104bbc:	85 c0                	test   %eax,%eax
80104bbe:	75 e0                	jne    80104ba0 <memmove+0x35>
  if(s < d && s + n > d){
80104bc0:	eb 24                	jmp    80104be6 <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104bc2:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104bc5:	8d 42 01             	lea    0x1(%edx),%eax
80104bc8:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104bcb:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104bce:	8d 48 01             	lea    0x1(%eax),%ecx
80104bd1:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104bd4:	0f b6 12             	movzbl (%edx),%edx
80104bd7:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104bd9:	8b 45 10             	mov    0x10(%ebp),%eax
80104bdc:	8d 50 ff             	lea    -0x1(%eax),%edx
80104bdf:	89 55 10             	mov    %edx,0x10(%ebp)
80104be2:	85 c0                	test   %eax,%eax
80104be4:	75 dc                	jne    80104bc2 <memmove+0x57>

  return dst;
80104be6:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104be9:	c9                   	leave  
80104bea:	c3                   	ret    

80104beb <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104beb:	55                   	push   %ebp
80104bec:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104bee:	ff 75 10             	push   0x10(%ebp)
80104bf1:	ff 75 0c             	push   0xc(%ebp)
80104bf4:	ff 75 08             	push   0x8(%ebp)
80104bf7:	e8 6f ff ff ff       	call   80104b6b <memmove>
80104bfc:	83 c4 0c             	add    $0xc,%esp
}
80104bff:	c9                   	leave  
80104c00:	c3                   	ret    

80104c01 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104c01:	55                   	push   %ebp
80104c02:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104c04:	eb 0c                	jmp    80104c12 <strncmp+0x11>
    n--, p++, q++;
80104c06:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104c0a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104c0e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104c12:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104c16:	74 1a                	je     80104c32 <strncmp+0x31>
80104c18:	8b 45 08             	mov    0x8(%ebp),%eax
80104c1b:	0f b6 00             	movzbl (%eax),%eax
80104c1e:	84 c0                	test   %al,%al
80104c20:	74 10                	je     80104c32 <strncmp+0x31>
80104c22:	8b 45 08             	mov    0x8(%ebp),%eax
80104c25:	0f b6 10             	movzbl (%eax),%edx
80104c28:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c2b:	0f b6 00             	movzbl (%eax),%eax
80104c2e:	38 c2                	cmp    %al,%dl
80104c30:	74 d4                	je     80104c06 <strncmp+0x5>
  if(n == 0)
80104c32:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104c36:	75 07                	jne    80104c3f <strncmp+0x3e>
    return 0;
80104c38:	b8 00 00 00 00       	mov    $0x0,%eax
80104c3d:	eb 16                	jmp    80104c55 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80104c3f:	8b 45 08             	mov    0x8(%ebp),%eax
80104c42:	0f b6 00             	movzbl (%eax),%eax
80104c45:	0f b6 d0             	movzbl %al,%edx
80104c48:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c4b:	0f b6 00             	movzbl (%eax),%eax
80104c4e:	0f b6 c8             	movzbl %al,%ecx
80104c51:	89 d0                	mov    %edx,%eax
80104c53:	29 c8                	sub    %ecx,%eax
}
80104c55:	5d                   	pop    %ebp
80104c56:	c3                   	ret    

80104c57 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104c57:	55                   	push   %ebp
80104c58:	89 e5                	mov    %esp,%ebp
80104c5a:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104c5d:	8b 45 08             	mov    0x8(%ebp),%eax
80104c60:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104c63:	90                   	nop
80104c64:	8b 45 10             	mov    0x10(%ebp),%eax
80104c67:	8d 50 ff             	lea    -0x1(%eax),%edx
80104c6a:	89 55 10             	mov    %edx,0x10(%ebp)
80104c6d:	85 c0                	test   %eax,%eax
80104c6f:	7e 2c                	jle    80104c9d <strncpy+0x46>
80104c71:	8b 55 0c             	mov    0xc(%ebp),%edx
80104c74:	8d 42 01             	lea    0x1(%edx),%eax
80104c77:	89 45 0c             	mov    %eax,0xc(%ebp)
80104c7a:	8b 45 08             	mov    0x8(%ebp),%eax
80104c7d:	8d 48 01             	lea    0x1(%eax),%ecx
80104c80:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104c83:	0f b6 12             	movzbl (%edx),%edx
80104c86:	88 10                	mov    %dl,(%eax)
80104c88:	0f b6 00             	movzbl (%eax),%eax
80104c8b:	84 c0                	test   %al,%al
80104c8d:	75 d5                	jne    80104c64 <strncpy+0xd>
    ;
  while(n-- > 0)
80104c8f:	eb 0c                	jmp    80104c9d <strncpy+0x46>
    *s++ = 0;
80104c91:	8b 45 08             	mov    0x8(%ebp),%eax
80104c94:	8d 50 01             	lea    0x1(%eax),%edx
80104c97:	89 55 08             	mov    %edx,0x8(%ebp)
80104c9a:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104c9d:	8b 45 10             	mov    0x10(%ebp),%eax
80104ca0:	8d 50 ff             	lea    -0x1(%eax),%edx
80104ca3:	89 55 10             	mov    %edx,0x10(%ebp)
80104ca6:	85 c0                	test   %eax,%eax
80104ca8:	7f e7                	jg     80104c91 <strncpy+0x3a>
  return os;
80104caa:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104cad:	c9                   	leave  
80104cae:	c3                   	ret    

80104caf <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104caf:	55                   	push   %ebp
80104cb0:	89 e5                	mov    %esp,%ebp
80104cb2:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104cb5:	8b 45 08             	mov    0x8(%ebp),%eax
80104cb8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104cbb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104cbf:	7f 05                	jg     80104cc6 <safestrcpy+0x17>
    return os;
80104cc1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cc4:	eb 32                	jmp    80104cf8 <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80104cc6:	90                   	nop
80104cc7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104ccb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104ccf:	7e 1e                	jle    80104cef <safestrcpy+0x40>
80104cd1:	8b 55 0c             	mov    0xc(%ebp),%edx
80104cd4:	8d 42 01             	lea    0x1(%edx),%eax
80104cd7:	89 45 0c             	mov    %eax,0xc(%ebp)
80104cda:	8b 45 08             	mov    0x8(%ebp),%eax
80104cdd:	8d 48 01             	lea    0x1(%eax),%ecx
80104ce0:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104ce3:	0f b6 12             	movzbl (%edx),%edx
80104ce6:	88 10                	mov    %dl,(%eax)
80104ce8:	0f b6 00             	movzbl (%eax),%eax
80104ceb:	84 c0                	test   %al,%al
80104ced:	75 d8                	jne    80104cc7 <safestrcpy+0x18>
    ;
  *s = 0;
80104cef:	8b 45 08             	mov    0x8(%ebp),%eax
80104cf2:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104cf5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104cf8:	c9                   	leave  
80104cf9:	c3                   	ret    

80104cfa <strlen>:

int
strlen(const char *s)
{
80104cfa:	55                   	push   %ebp
80104cfb:	89 e5                	mov    %esp,%ebp
80104cfd:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104d00:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104d07:	eb 04                	jmp    80104d0d <strlen+0x13>
80104d09:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104d0d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104d10:	8b 45 08             	mov    0x8(%ebp),%eax
80104d13:	01 d0                	add    %edx,%eax
80104d15:	0f b6 00             	movzbl (%eax),%eax
80104d18:	84 c0                	test   %al,%al
80104d1a:	75 ed                	jne    80104d09 <strlen+0xf>
    ;
  return n;
80104d1c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d1f:	c9                   	leave  
80104d20:	c3                   	ret    

80104d21 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104d21:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104d25:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104d29:	55                   	push   %ebp
  pushl %ebx
80104d2a:	53                   	push   %ebx
  pushl %esi
80104d2b:	56                   	push   %esi
  pushl %edi
80104d2c:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104d2d:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104d2f:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104d31:	5f                   	pop    %edi
  popl %esi
80104d32:	5e                   	pop    %esi
  popl %ebx
80104d33:	5b                   	pop    %ebx
  popl %ebp
80104d34:	5d                   	pop    %ebp
  ret
80104d35:	c3                   	ret    

80104d36 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104d36:	55                   	push   %ebp
80104d37:	89 e5                	mov    %esp,%ebp
  //struct proc *curproc = myproc();

  /*if(addr >= curproc->sz || addr+4 > curproc->sz)
    return -1;*/
  *ip = *(int*)(addr);
80104d39:	8b 45 08             	mov    0x8(%ebp),%eax
80104d3c:	8b 10                	mov    (%eax),%edx
80104d3e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d41:	89 10                	mov    %edx,(%eax)
  return 0;
80104d43:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d48:	5d                   	pop    %ebp
80104d49:	c3                   	ret    

80104d4a <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104d4a:	55                   	push   %ebp
80104d4b:	89 e5                	mov    %esp,%ebp
80104d4d:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80104d50:	e8 d6 ec ff ff       	call   80103a2b <myproc>
80104d55:	89 45 f0             	mov    %eax,-0x10(%ebp)

  /*if(addr >= curproc->sz)
    return -1;*/
  *pp = (char*)addr;
80104d58:	8b 55 08             	mov    0x8(%ebp),%edx
80104d5b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d5e:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80104d60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d63:	8b 00                	mov    (%eax),%eax
80104d65:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80104d68:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d6b:	8b 00                	mov    (%eax),%eax
80104d6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104d70:	eb 1a                	jmp    80104d8c <fetchstr+0x42>
    if(*s == 0)
80104d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d75:	0f b6 00             	movzbl (%eax),%eax
80104d78:	84 c0                	test   %al,%al
80104d7a:	75 0c                	jne    80104d88 <fetchstr+0x3e>
      return s - *pp;
80104d7c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d7f:	8b 10                	mov    (%eax),%edx
80104d81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d84:	29 d0                	sub    %edx,%eax
80104d86:	eb 11                	jmp    80104d99 <fetchstr+0x4f>
  for(s = *pp; s < ep; s++){
80104d88:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104d8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d8f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104d92:	72 de                	jb     80104d72 <fetchstr+0x28>
  }
  return -1;
80104d94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104d99:	c9                   	leave  
80104d9a:	c3                   	ret    

80104d9b <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104d9b:	55                   	push   %ebp
80104d9c:	89 e5                	mov    %esp,%ebp
80104d9e:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104da1:	e8 85 ec ff ff       	call   80103a2b <myproc>
80104da6:	8b 40 18             	mov    0x18(%eax),%eax
80104da9:	8b 50 44             	mov    0x44(%eax),%edx
80104dac:	8b 45 08             	mov    0x8(%ebp),%eax
80104daf:	c1 e0 02             	shl    $0x2,%eax
80104db2:	01 d0                	add    %edx,%eax
80104db4:	83 c0 04             	add    $0x4,%eax
80104db7:	83 ec 08             	sub    $0x8,%esp
80104dba:	ff 75 0c             	push   0xc(%ebp)
80104dbd:	50                   	push   %eax
80104dbe:	e8 73 ff ff ff       	call   80104d36 <fetchint>
80104dc3:	83 c4 10             	add    $0x10,%esp
}
80104dc6:	c9                   	leave  
80104dc7:	c3                   	ret    

80104dc8 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104dc8:	55                   	push   %ebp
80104dc9:	89 e5                	mov    %esp,%ebp
80104dcb:	83 ec 18             	sub    $0x18,%esp
  int i;
  //struct proc *curproc = myproc();
 
  if(argint(n, &i) < 0)
80104dce:	83 ec 08             	sub    $0x8,%esp
80104dd1:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104dd4:	50                   	push   %eax
80104dd5:	ff 75 08             	push   0x8(%ebp)
80104dd8:	e8 be ff ff ff       	call   80104d9b <argint>
80104ddd:	83 c4 10             	add    $0x10,%esp
80104de0:	85 c0                	test   %eax,%eax
80104de2:	79 07                	jns    80104deb <argptr+0x23>
    return -1;
80104de4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104de9:	eb 1c                	jmp    80104e07 <argptr+0x3f>
  if(size < 0 /*|| (uint)i >= curproc->sz || (uint)i+size > curproc->sz*/)
80104deb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104def:	79 07                	jns    80104df8 <argptr+0x30>
    return -1;
80104df1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104df6:	eb 0f                	jmp    80104e07 <argptr+0x3f>
  *pp = (char*)i;
80104df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dfb:	89 c2                	mov    %eax,%edx
80104dfd:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e00:	89 10                	mov    %edx,(%eax)
  return 0;
80104e02:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e07:	c9                   	leave  
80104e08:	c3                   	ret    

80104e09 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104e09:	55                   	push   %ebp
80104e0a:	89 e5                	mov    %esp,%ebp
80104e0c:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104e0f:	83 ec 08             	sub    $0x8,%esp
80104e12:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e15:	50                   	push   %eax
80104e16:	ff 75 08             	push   0x8(%ebp)
80104e19:	e8 7d ff ff ff       	call   80104d9b <argint>
80104e1e:	83 c4 10             	add    $0x10,%esp
80104e21:	85 c0                	test   %eax,%eax
80104e23:	79 07                	jns    80104e2c <argstr+0x23>
    return -1;
80104e25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e2a:	eb 12                	jmp    80104e3e <argstr+0x35>
  return fetchstr(addr, pp);
80104e2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e2f:	83 ec 08             	sub    $0x8,%esp
80104e32:	ff 75 0c             	push   0xc(%ebp)
80104e35:	50                   	push   %eax
80104e36:	e8 0f ff ff ff       	call   80104d4a <fetchstr>
80104e3b:	83 c4 10             	add    $0x10,%esp
}
80104e3e:	c9                   	leave  
80104e3f:	c3                   	ret    

80104e40 <syscall>:
[SYS_printpt] sys_printpt,
};

void
syscall(void)
{
80104e40:	55                   	push   %ebp
80104e41:	89 e5                	mov    %esp,%ebp
80104e43:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80104e46:	e8 e0 eb ff ff       	call   80103a2b <myproc>
80104e4b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80104e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e51:	8b 40 18             	mov    0x18(%eax),%eax
80104e54:	8b 40 1c             	mov    0x1c(%eax),%eax
80104e57:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104e5a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104e5e:	7e 2f                	jle    80104e8f <syscall+0x4f>
80104e60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e63:	83 f8 16             	cmp    $0x16,%eax
80104e66:	77 27                	ja     80104e8f <syscall+0x4f>
80104e68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e6b:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104e72:	85 c0                	test   %eax,%eax
80104e74:	74 19                	je     80104e8f <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80104e76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e79:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104e80:	ff d0                	call   *%eax
80104e82:	89 c2                	mov    %eax,%edx
80104e84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e87:	8b 40 18             	mov    0x18(%eax),%eax
80104e8a:	89 50 1c             	mov    %edx,0x1c(%eax)
80104e8d:	eb 2c                	jmp    80104ebb <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80104e8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e92:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104e95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e98:	8b 40 10             	mov    0x10(%eax),%eax
80104e9b:	ff 75 f0             	push   -0x10(%ebp)
80104e9e:	52                   	push   %edx
80104e9f:	50                   	push   %eax
80104ea0:	68 1d a5 10 80       	push   $0x8010a51d
80104ea5:	e8 4a b5 ff ff       	call   801003f4 <cprintf>
80104eaa:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80104ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eb0:	8b 40 18             	mov    0x18(%eax),%eax
80104eb3:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80104eba:	90                   	nop
80104ebb:	90                   	nop
80104ebc:	c9                   	leave  
80104ebd:	c3                   	ret    

80104ebe <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104ebe:	55                   	push   %ebp
80104ebf:	89 e5                	mov    %esp,%ebp
80104ec1:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104ec4:	83 ec 08             	sub    $0x8,%esp
80104ec7:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104eca:	50                   	push   %eax
80104ecb:	ff 75 08             	push   0x8(%ebp)
80104ece:	e8 c8 fe ff ff       	call   80104d9b <argint>
80104ed3:	83 c4 10             	add    $0x10,%esp
80104ed6:	85 c0                	test   %eax,%eax
80104ed8:	79 07                	jns    80104ee1 <argfd+0x23>
    return -1;
80104eda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104edf:	eb 4f                	jmp    80104f30 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104ee1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ee4:	85 c0                	test   %eax,%eax
80104ee6:	78 20                	js     80104f08 <argfd+0x4a>
80104ee8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104eeb:	83 f8 0f             	cmp    $0xf,%eax
80104eee:	7f 18                	jg     80104f08 <argfd+0x4a>
80104ef0:	e8 36 eb ff ff       	call   80103a2b <myproc>
80104ef5:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104ef8:	83 c2 08             	add    $0x8,%edx
80104efb:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104eff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104f02:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104f06:	75 07                	jne    80104f0f <argfd+0x51>
    return -1;
80104f08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f0d:	eb 21                	jmp    80104f30 <argfd+0x72>
  if(pfd)
80104f0f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104f13:	74 08                	je     80104f1d <argfd+0x5f>
    *pfd = fd;
80104f15:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f18:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f1b:	89 10                	mov    %edx,(%eax)
  if(pf)
80104f1d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f21:	74 08                	je     80104f2b <argfd+0x6d>
    *pf = f;
80104f23:	8b 45 10             	mov    0x10(%ebp),%eax
80104f26:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f29:	89 10                	mov    %edx,(%eax)
  return 0;
80104f2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f30:	c9                   	leave  
80104f31:	c3                   	ret    

80104f32 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80104f32:	55                   	push   %ebp
80104f33:	89 e5                	mov    %esp,%ebp
80104f35:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80104f38:	e8 ee ea ff ff       	call   80103a2b <myproc>
80104f3d:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80104f40:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104f47:	eb 2a                	jmp    80104f73 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80104f49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f4f:	83 c2 08             	add    $0x8,%edx
80104f52:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104f56:	85 c0                	test   %eax,%eax
80104f58:	75 15                	jne    80104f6f <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80104f5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f5d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f60:	8d 4a 08             	lea    0x8(%edx),%ecx
80104f63:	8b 55 08             	mov    0x8(%ebp),%edx
80104f66:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80104f6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f6d:	eb 0f                	jmp    80104f7e <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
80104f6f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104f73:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104f77:	7e d0                	jle    80104f49 <fdalloc+0x17>
    }
  }
  return -1;
80104f79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f7e:	c9                   	leave  
80104f7f:	c3                   	ret    

80104f80 <sys_dup>:

int
sys_dup(void)
{
80104f80:	55                   	push   %ebp
80104f81:	89 e5                	mov    %esp,%ebp
80104f83:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80104f86:	83 ec 04             	sub    $0x4,%esp
80104f89:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104f8c:	50                   	push   %eax
80104f8d:	6a 00                	push   $0x0
80104f8f:	6a 00                	push   $0x0
80104f91:	e8 28 ff ff ff       	call   80104ebe <argfd>
80104f96:	83 c4 10             	add    $0x10,%esp
80104f99:	85 c0                	test   %eax,%eax
80104f9b:	79 07                	jns    80104fa4 <sys_dup+0x24>
    return -1;
80104f9d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fa2:	eb 31                	jmp    80104fd5 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80104fa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fa7:	83 ec 0c             	sub    $0xc,%esp
80104faa:	50                   	push   %eax
80104fab:	e8 82 ff ff ff       	call   80104f32 <fdalloc>
80104fb0:	83 c4 10             	add    $0x10,%esp
80104fb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104fb6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104fba:	79 07                	jns    80104fc3 <sys_dup+0x43>
    return -1;
80104fbc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fc1:	eb 12                	jmp    80104fd5 <sys_dup+0x55>
  filedup(f);
80104fc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fc6:	83 ec 0c             	sub    $0xc,%esp
80104fc9:	50                   	push   %eax
80104fca:	e8 76 c0 ff ff       	call   80101045 <filedup>
80104fcf:	83 c4 10             	add    $0x10,%esp
  return fd;
80104fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104fd5:	c9                   	leave  
80104fd6:	c3                   	ret    

80104fd7 <sys_read>:

int
sys_read(void)
{
80104fd7:	55                   	push   %ebp
80104fd8:	89 e5                	mov    %esp,%ebp
80104fda:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104fdd:	83 ec 04             	sub    $0x4,%esp
80104fe0:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104fe3:	50                   	push   %eax
80104fe4:	6a 00                	push   $0x0
80104fe6:	6a 00                	push   $0x0
80104fe8:	e8 d1 fe ff ff       	call   80104ebe <argfd>
80104fed:	83 c4 10             	add    $0x10,%esp
80104ff0:	85 c0                	test   %eax,%eax
80104ff2:	78 2e                	js     80105022 <sys_read+0x4b>
80104ff4:	83 ec 08             	sub    $0x8,%esp
80104ff7:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104ffa:	50                   	push   %eax
80104ffb:	6a 02                	push   $0x2
80104ffd:	e8 99 fd ff ff       	call   80104d9b <argint>
80105002:	83 c4 10             	add    $0x10,%esp
80105005:	85 c0                	test   %eax,%eax
80105007:	78 19                	js     80105022 <sys_read+0x4b>
80105009:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010500c:	83 ec 04             	sub    $0x4,%esp
8010500f:	50                   	push   %eax
80105010:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105013:	50                   	push   %eax
80105014:	6a 01                	push   $0x1
80105016:	e8 ad fd ff ff       	call   80104dc8 <argptr>
8010501b:	83 c4 10             	add    $0x10,%esp
8010501e:	85 c0                	test   %eax,%eax
80105020:	79 07                	jns    80105029 <sys_read+0x52>
    return -1;
80105022:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105027:	eb 17                	jmp    80105040 <sys_read+0x69>
  return fileread(f, p, n);
80105029:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010502c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010502f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105032:	83 ec 04             	sub    $0x4,%esp
80105035:	51                   	push   %ecx
80105036:	52                   	push   %edx
80105037:	50                   	push   %eax
80105038:	e8 98 c1 ff ff       	call   801011d5 <fileread>
8010503d:	83 c4 10             	add    $0x10,%esp
}
80105040:	c9                   	leave  
80105041:	c3                   	ret    

80105042 <sys_write>:

int
sys_write(void)
{
80105042:	55                   	push   %ebp
80105043:	89 e5                	mov    %esp,%ebp
80105045:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105048:	83 ec 04             	sub    $0x4,%esp
8010504b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010504e:	50                   	push   %eax
8010504f:	6a 00                	push   $0x0
80105051:	6a 00                	push   $0x0
80105053:	e8 66 fe ff ff       	call   80104ebe <argfd>
80105058:	83 c4 10             	add    $0x10,%esp
8010505b:	85 c0                	test   %eax,%eax
8010505d:	78 2e                	js     8010508d <sys_write+0x4b>
8010505f:	83 ec 08             	sub    $0x8,%esp
80105062:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105065:	50                   	push   %eax
80105066:	6a 02                	push   $0x2
80105068:	e8 2e fd ff ff       	call   80104d9b <argint>
8010506d:	83 c4 10             	add    $0x10,%esp
80105070:	85 c0                	test   %eax,%eax
80105072:	78 19                	js     8010508d <sys_write+0x4b>
80105074:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105077:	83 ec 04             	sub    $0x4,%esp
8010507a:	50                   	push   %eax
8010507b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010507e:	50                   	push   %eax
8010507f:	6a 01                	push   $0x1
80105081:	e8 42 fd ff ff       	call   80104dc8 <argptr>
80105086:	83 c4 10             	add    $0x10,%esp
80105089:	85 c0                	test   %eax,%eax
8010508b:	79 07                	jns    80105094 <sys_write+0x52>
    return -1;
8010508d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105092:	eb 17                	jmp    801050ab <sys_write+0x69>
  return filewrite(f, p, n);
80105094:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105097:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010509a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010509d:	83 ec 04             	sub    $0x4,%esp
801050a0:	51                   	push   %ecx
801050a1:	52                   	push   %edx
801050a2:	50                   	push   %eax
801050a3:	e8 e5 c1 ff ff       	call   8010128d <filewrite>
801050a8:	83 c4 10             	add    $0x10,%esp
}
801050ab:	c9                   	leave  
801050ac:	c3                   	ret    

801050ad <sys_close>:

int
sys_close(void)
{
801050ad:	55                   	push   %ebp
801050ae:	89 e5                	mov    %esp,%ebp
801050b0:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801050b3:	83 ec 04             	sub    $0x4,%esp
801050b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801050b9:	50                   	push   %eax
801050ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
801050bd:	50                   	push   %eax
801050be:	6a 00                	push   $0x0
801050c0:	e8 f9 fd ff ff       	call   80104ebe <argfd>
801050c5:	83 c4 10             	add    $0x10,%esp
801050c8:	85 c0                	test   %eax,%eax
801050ca:	79 07                	jns    801050d3 <sys_close+0x26>
    return -1;
801050cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050d1:	eb 27                	jmp    801050fa <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
801050d3:	e8 53 e9 ff ff       	call   80103a2b <myproc>
801050d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801050db:	83 c2 08             	add    $0x8,%edx
801050de:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801050e5:	00 
  fileclose(f);
801050e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050e9:	83 ec 0c             	sub    $0xc,%esp
801050ec:	50                   	push   %eax
801050ed:	e8 a4 bf ff ff       	call   80101096 <fileclose>
801050f2:	83 c4 10             	add    $0x10,%esp
  return 0;
801050f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801050fa:	c9                   	leave  
801050fb:	c3                   	ret    

801050fc <sys_fstat>:

int
sys_fstat(void)
{
801050fc:	55                   	push   %ebp
801050fd:	89 e5                	mov    %esp,%ebp
801050ff:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105102:	83 ec 04             	sub    $0x4,%esp
80105105:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105108:	50                   	push   %eax
80105109:	6a 00                	push   $0x0
8010510b:	6a 00                	push   $0x0
8010510d:	e8 ac fd ff ff       	call   80104ebe <argfd>
80105112:	83 c4 10             	add    $0x10,%esp
80105115:	85 c0                	test   %eax,%eax
80105117:	78 17                	js     80105130 <sys_fstat+0x34>
80105119:	83 ec 04             	sub    $0x4,%esp
8010511c:	6a 14                	push   $0x14
8010511e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105121:	50                   	push   %eax
80105122:	6a 01                	push   $0x1
80105124:	e8 9f fc ff ff       	call   80104dc8 <argptr>
80105129:	83 c4 10             	add    $0x10,%esp
8010512c:	85 c0                	test   %eax,%eax
8010512e:	79 07                	jns    80105137 <sys_fstat+0x3b>
    return -1;
80105130:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105135:	eb 13                	jmp    8010514a <sys_fstat+0x4e>
  return filestat(f, st);
80105137:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010513a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010513d:	83 ec 08             	sub    $0x8,%esp
80105140:	52                   	push   %edx
80105141:	50                   	push   %eax
80105142:	e8 37 c0 ff ff       	call   8010117e <filestat>
80105147:	83 c4 10             	add    $0x10,%esp
}
8010514a:	c9                   	leave  
8010514b:	c3                   	ret    

8010514c <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
8010514c:	55                   	push   %ebp
8010514d:	89 e5                	mov    %esp,%ebp
8010514f:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105152:	83 ec 08             	sub    $0x8,%esp
80105155:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105158:	50                   	push   %eax
80105159:	6a 00                	push   $0x0
8010515b:	e8 a9 fc ff ff       	call   80104e09 <argstr>
80105160:	83 c4 10             	add    $0x10,%esp
80105163:	85 c0                	test   %eax,%eax
80105165:	78 15                	js     8010517c <sys_link+0x30>
80105167:	83 ec 08             	sub    $0x8,%esp
8010516a:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010516d:	50                   	push   %eax
8010516e:	6a 01                	push   $0x1
80105170:	e8 94 fc ff ff       	call   80104e09 <argstr>
80105175:	83 c4 10             	add    $0x10,%esp
80105178:	85 c0                	test   %eax,%eax
8010517a:	79 0a                	jns    80105186 <sys_link+0x3a>
    return -1;
8010517c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105181:	e9 68 01 00 00       	jmp    801052ee <sys_link+0x1a2>

  begin_op();
80105186:	e8 ac de ff ff       	call   80103037 <begin_op>
  if((ip = namei(old)) == 0){
8010518b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010518e:	83 ec 0c             	sub    $0xc,%esp
80105191:	50                   	push   %eax
80105192:	e8 81 d3 ff ff       	call   80102518 <namei>
80105197:	83 c4 10             	add    $0x10,%esp
8010519a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010519d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801051a1:	75 0f                	jne    801051b2 <sys_link+0x66>
    end_op();
801051a3:	e8 1b df ff ff       	call   801030c3 <end_op>
    return -1;
801051a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051ad:	e9 3c 01 00 00       	jmp    801052ee <sys_link+0x1a2>
  }

  ilock(ip);
801051b2:	83 ec 0c             	sub    $0xc,%esp
801051b5:	ff 75 f4             	push   -0xc(%ebp)
801051b8:	e8 28 c8 ff ff       	call   801019e5 <ilock>
801051bd:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801051c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051c3:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801051c7:	66 83 f8 01          	cmp    $0x1,%ax
801051cb:	75 1d                	jne    801051ea <sys_link+0x9e>
    iunlockput(ip);
801051cd:	83 ec 0c             	sub    $0xc,%esp
801051d0:	ff 75 f4             	push   -0xc(%ebp)
801051d3:	e8 3e ca ff ff       	call   80101c16 <iunlockput>
801051d8:	83 c4 10             	add    $0x10,%esp
    end_op();
801051db:	e8 e3 de ff ff       	call   801030c3 <end_op>
    return -1;
801051e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051e5:	e9 04 01 00 00       	jmp    801052ee <sys_link+0x1a2>
  }

  ip->nlink++;
801051ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051ed:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801051f1:	83 c0 01             	add    $0x1,%eax
801051f4:	89 c2                	mov    %eax,%edx
801051f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051f9:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801051fd:	83 ec 0c             	sub    $0xc,%esp
80105200:	ff 75 f4             	push   -0xc(%ebp)
80105203:	e8 00 c6 ff ff       	call   80101808 <iupdate>
80105208:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
8010520b:	83 ec 0c             	sub    $0xc,%esp
8010520e:	ff 75 f4             	push   -0xc(%ebp)
80105211:	e8 e2 c8 ff ff       	call   80101af8 <iunlock>
80105216:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105219:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010521c:	83 ec 08             	sub    $0x8,%esp
8010521f:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105222:	52                   	push   %edx
80105223:	50                   	push   %eax
80105224:	e8 0b d3 ff ff       	call   80102534 <nameiparent>
80105229:	83 c4 10             	add    $0x10,%esp
8010522c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010522f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105233:	74 71                	je     801052a6 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105235:	83 ec 0c             	sub    $0xc,%esp
80105238:	ff 75 f0             	push   -0x10(%ebp)
8010523b:	e8 a5 c7 ff ff       	call   801019e5 <ilock>
80105240:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105243:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105246:	8b 10                	mov    (%eax),%edx
80105248:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010524b:	8b 00                	mov    (%eax),%eax
8010524d:	39 c2                	cmp    %eax,%edx
8010524f:	75 1d                	jne    8010526e <sys_link+0x122>
80105251:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105254:	8b 40 04             	mov    0x4(%eax),%eax
80105257:	83 ec 04             	sub    $0x4,%esp
8010525a:	50                   	push   %eax
8010525b:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010525e:	50                   	push   %eax
8010525f:	ff 75 f0             	push   -0x10(%ebp)
80105262:	e8 1a d0 ff ff       	call   80102281 <dirlink>
80105267:	83 c4 10             	add    $0x10,%esp
8010526a:	85 c0                	test   %eax,%eax
8010526c:	79 10                	jns    8010527e <sys_link+0x132>
    iunlockput(dp);
8010526e:	83 ec 0c             	sub    $0xc,%esp
80105271:	ff 75 f0             	push   -0x10(%ebp)
80105274:	e8 9d c9 ff ff       	call   80101c16 <iunlockput>
80105279:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010527c:	eb 29                	jmp    801052a7 <sys_link+0x15b>
  }
  iunlockput(dp);
8010527e:	83 ec 0c             	sub    $0xc,%esp
80105281:	ff 75 f0             	push   -0x10(%ebp)
80105284:	e8 8d c9 ff ff       	call   80101c16 <iunlockput>
80105289:	83 c4 10             	add    $0x10,%esp
  iput(ip);
8010528c:	83 ec 0c             	sub    $0xc,%esp
8010528f:	ff 75 f4             	push   -0xc(%ebp)
80105292:	e8 af c8 ff ff       	call   80101b46 <iput>
80105297:	83 c4 10             	add    $0x10,%esp

  end_op();
8010529a:	e8 24 de ff ff       	call   801030c3 <end_op>

  return 0;
8010529f:	b8 00 00 00 00       	mov    $0x0,%eax
801052a4:	eb 48                	jmp    801052ee <sys_link+0x1a2>
    goto bad;
801052a6:	90                   	nop

bad:
  ilock(ip);
801052a7:	83 ec 0c             	sub    $0xc,%esp
801052aa:	ff 75 f4             	push   -0xc(%ebp)
801052ad:	e8 33 c7 ff ff       	call   801019e5 <ilock>
801052b2:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801052b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052b8:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801052bc:	83 e8 01             	sub    $0x1,%eax
801052bf:	89 c2                	mov    %eax,%edx
801052c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052c4:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801052c8:	83 ec 0c             	sub    $0xc,%esp
801052cb:	ff 75 f4             	push   -0xc(%ebp)
801052ce:	e8 35 c5 ff ff       	call   80101808 <iupdate>
801052d3:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801052d6:	83 ec 0c             	sub    $0xc,%esp
801052d9:	ff 75 f4             	push   -0xc(%ebp)
801052dc:	e8 35 c9 ff ff       	call   80101c16 <iunlockput>
801052e1:	83 c4 10             	add    $0x10,%esp
  end_op();
801052e4:	e8 da dd ff ff       	call   801030c3 <end_op>
  return -1;
801052e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801052ee:	c9                   	leave  
801052ef:	c3                   	ret    

801052f0 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801052f0:	55                   	push   %ebp
801052f1:	89 e5                	mov    %esp,%ebp
801052f3:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801052f6:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801052fd:	eb 40                	jmp    8010533f <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801052ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105302:	6a 10                	push   $0x10
80105304:	50                   	push   %eax
80105305:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105308:	50                   	push   %eax
80105309:	ff 75 08             	push   0x8(%ebp)
8010530c:	e8 c0 cb ff ff       	call   80101ed1 <readi>
80105311:	83 c4 10             	add    $0x10,%esp
80105314:	83 f8 10             	cmp    $0x10,%eax
80105317:	74 0d                	je     80105326 <isdirempty+0x36>
      panic("isdirempty: readi");
80105319:	83 ec 0c             	sub    $0xc,%esp
8010531c:	68 39 a5 10 80       	push   $0x8010a539
80105321:	e8 83 b2 ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
80105326:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
8010532a:	66 85 c0             	test   %ax,%ax
8010532d:	74 07                	je     80105336 <isdirempty+0x46>
      return 0;
8010532f:	b8 00 00 00 00       	mov    $0x0,%eax
80105334:	eb 1b                	jmp    80105351 <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105336:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105339:	83 c0 10             	add    $0x10,%eax
8010533c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010533f:	8b 45 08             	mov    0x8(%ebp),%eax
80105342:	8b 50 58             	mov    0x58(%eax),%edx
80105345:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105348:	39 c2                	cmp    %eax,%edx
8010534a:	77 b3                	ja     801052ff <isdirempty+0xf>
  }
  return 1;
8010534c:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105351:	c9                   	leave  
80105352:	c3                   	ret    

80105353 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105353:	55                   	push   %ebp
80105354:	89 e5                	mov    %esp,%ebp
80105356:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105359:	83 ec 08             	sub    $0x8,%esp
8010535c:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010535f:	50                   	push   %eax
80105360:	6a 00                	push   $0x0
80105362:	e8 a2 fa ff ff       	call   80104e09 <argstr>
80105367:	83 c4 10             	add    $0x10,%esp
8010536a:	85 c0                	test   %eax,%eax
8010536c:	79 0a                	jns    80105378 <sys_unlink+0x25>
    return -1;
8010536e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105373:	e9 bf 01 00 00       	jmp    80105537 <sys_unlink+0x1e4>

  begin_op();
80105378:	e8 ba dc ff ff       	call   80103037 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
8010537d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105380:	83 ec 08             	sub    $0x8,%esp
80105383:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105386:	52                   	push   %edx
80105387:	50                   	push   %eax
80105388:	e8 a7 d1 ff ff       	call   80102534 <nameiparent>
8010538d:	83 c4 10             	add    $0x10,%esp
80105390:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105393:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105397:	75 0f                	jne    801053a8 <sys_unlink+0x55>
    end_op();
80105399:	e8 25 dd ff ff       	call   801030c3 <end_op>
    return -1;
8010539e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053a3:	e9 8f 01 00 00       	jmp    80105537 <sys_unlink+0x1e4>
  }

  ilock(dp);
801053a8:	83 ec 0c             	sub    $0xc,%esp
801053ab:	ff 75 f4             	push   -0xc(%ebp)
801053ae:	e8 32 c6 ff ff       	call   801019e5 <ilock>
801053b3:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801053b6:	83 ec 08             	sub    $0x8,%esp
801053b9:	68 4b a5 10 80       	push   $0x8010a54b
801053be:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801053c1:	50                   	push   %eax
801053c2:	e8 e5 cd ff ff       	call   801021ac <namecmp>
801053c7:	83 c4 10             	add    $0x10,%esp
801053ca:	85 c0                	test   %eax,%eax
801053cc:	0f 84 49 01 00 00    	je     8010551b <sys_unlink+0x1c8>
801053d2:	83 ec 08             	sub    $0x8,%esp
801053d5:	68 4d a5 10 80       	push   $0x8010a54d
801053da:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801053dd:	50                   	push   %eax
801053de:	e8 c9 cd ff ff       	call   801021ac <namecmp>
801053e3:	83 c4 10             	add    $0x10,%esp
801053e6:	85 c0                	test   %eax,%eax
801053e8:	0f 84 2d 01 00 00    	je     8010551b <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801053ee:	83 ec 04             	sub    $0x4,%esp
801053f1:	8d 45 c8             	lea    -0x38(%ebp),%eax
801053f4:	50                   	push   %eax
801053f5:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801053f8:	50                   	push   %eax
801053f9:	ff 75 f4             	push   -0xc(%ebp)
801053fc:	e8 c6 cd ff ff       	call   801021c7 <dirlookup>
80105401:	83 c4 10             	add    $0x10,%esp
80105404:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105407:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010540b:	0f 84 0d 01 00 00    	je     8010551e <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105411:	83 ec 0c             	sub    $0xc,%esp
80105414:	ff 75 f0             	push   -0x10(%ebp)
80105417:	e8 c9 c5 ff ff       	call   801019e5 <ilock>
8010541c:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
8010541f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105422:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105426:	66 85 c0             	test   %ax,%ax
80105429:	7f 0d                	jg     80105438 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
8010542b:	83 ec 0c             	sub    $0xc,%esp
8010542e:	68 50 a5 10 80       	push   $0x8010a550
80105433:	e8 71 b1 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105438:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010543b:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010543f:	66 83 f8 01          	cmp    $0x1,%ax
80105443:	75 25                	jne    8010546a <sys_unlink+0x117>
80105445:	83 ec 0c             	sub    $0xc,%esp
80105448:	ff 75 f0             	push   -0x10(%ebp)
8010544b:	e8 a0 fe ff ff       	call   801052f0 <isdirempty>
80105450:	83 c4 10             	add    $0x10,%esp
80105453:	85 c0                	test   %eax,%eax
80105455:	75 13                	jne    8010546a <sys_unlink+0x117>
    iunlockput(ip);
80105457:	83 ec 0c             	sub    $0xc,%esp
8010545a:	ff 75 f0             	push   -0x10(%ebp)
8010545d:	e8 b4 c7 ff ff       	call   80101c16 <iunlockput>
80105462:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105465:	e9 b5 00 00 00       	jmp    8010551f <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
8010546a:	83 ec 04             	sub    $0x4,%esp
8010546d:	6a 10                	push   $0x10
8010546f:	6a 00                	push   $0x0
80105471:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105474:	50                   	push   %eax
80105475:	e8 32 f6 ff ff       	call   80104aac <memset>
8010547a:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010547d:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105480:	6a 10                	push   $0x10
80105482:	50                   	push   %eax
80105483:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105486:	50                   	push   %eax
80105487:	ff 75 f4             	push   -0xc(%ebp)
8010548a:	e8 97 cb ff ff       	call   80102026 <writei>
8010548f:	83 c4 10             	add    $0x10,%esp
80105492:	83 f8 10             	cmp    $0x10,%eax
80105495:	74 0d                	je     801054a4 <sys_unlink+0x151>
    panic("unlink: writei");
80105497:	83 ec 0c             	sub    $0xc,%esp
8010549a:	68 62 a5 10 80       	push   $0x8010a562
8010549f:	e8 05 b1 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
801054a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054a7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801054ab:	66 83 f8 01          	cmp    $0x1,%ax
801054af:	75 21                	jne    801054d2 <sys_unlink+0x17f>
    dp->nlink--;
801054b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054b4:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801054b8:	83 e8 01             	sub    $0x1,%eax
801054bb:	89 c2                	mov    %eax,%edx
801054bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054c0:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801054c4:	83 ec 0c             	sub    $0xc,%esp
801054c7:	ff 75 f4             	push   -0xc(%ebp)
801054ca:	e8 39 c3 ff ff       	call   80101808 <iupdate>
801054cf:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
801054d2:	83 ec 0c             	sub    $0xc,%esp
801054d5:	ff 75 f4             	push   -0xc(%ebp)
801054d8:	e8 39 c7 ff ff       	call   80101c16 <iunlockput>
801054dd:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
801054e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054e3:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801054e7:	83 e8 01             	sub    $0x1,%eax
801054ea:	89 c2                	mov    %eax,%edx
801054ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054ef:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801054f3:	83 ec 0c             	sub    $0xc,%esp
801054f6:	ff 75 f0             	push   -0x10(%ebp)
801054f9:	e8 0a c3 ff ff       	call   80101808 <iupdate>
801054fe:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105501:	83 ec 0c             	sub    $0xc,%esp
80105504:	ff 75 f0             	push   -0x10(%ebp)
80105507:	e8 0a c7 ff ff       	call   80101c16 <iunlockput>
8010550c:	83 c4 10             	add    $0x10,%esp

  end_op();
8010550f:	e8 af db ff ff       	call   801030c3 <end_op>

  return 0;
80105514:	b8 00 00 00 00       	mov    $0x0,%eax
80105519:	eb 1c                	jmp    80105537 <sys_unlink+0x1e4>
    goto bad;
8010551b:	90                   	nop
8010551c:	eb 01                	jmp    8010551f <sys_unlink+0x1cc>
    goto bad;
8010551e:	90                   	nop

bad:
  iunlockput(dp);
8010551f:	83 ec 0c             	sub    $0xc,%esp
80105522:	ff 75 f4             	push   -0xc(%ebp)
80105525:	e8 ec c6 ff ff       	call   80101c16 <iunlockput>
8010552a:	83 c4 10             	add    $0x10,%esp
  end_op();
8010552d:	e8 91 db ff ff       	call   801030c3 <end_op>
  return -1;
80105532:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105537:	c9                   	leave  
80105538:	c3                   	ret    

80105539 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105539:	55                   	push   %ebp
8010553a:	89 e5                	mov    %esp,%ebp
8010553c:	83 ec 38             	sub    $0x38,%esp
8010553f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105542:	8b 55 10             	mov    0x10(%ebp),%edx
80105545:	8b 45 14             	mov    0x14(%ebp),%eax
80105548:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010554c:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105550:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105554:	83 ec 08             	sub    $0x8,%esp
80105557:	8d 45 de             	lea    -0x22(%ebp),%eax
8010555a:	50                   	push   %eax
8010555b:	ff 75 08             	push   0x8(%ebp)
8010555e:	e8 d1 cf ff ff       	call   80102534 <nameiparent>
80105563:	83 c4 10             	add    $0x10,%esp
80105566:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105569:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010556d:	75 0a                	jne    80105579 <create+0x40>
    return 0;
8010556f:	b8 00 00 00 00       	mov    $0x0,%eax
80105574:	e9 90 01 00 00       	jmp    80105709 <create+0x1d0>
  ilock(dp);
80105579:	83 ec 0c             	sub    $0xc,%esp
8010557c:	ff 75 f4             	push   -0xc(%ebp)
8010557f:	e8 61 c4 ff ff       	call   801019e5 <ilock>
80105584:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105587:	83 ec 04             	sub    $0x4,%esp
8010558a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010558d:	50                   	push   %eax
8010558e:	8d 45 de             	lea    -0x22(%ebp),%eax
80105591:	50                   	push   %eax
80105592:	ff 75 f4             	push   -0xc(%ebp)
80105595:	e8 2d cc ff ff       	call   801021c7 <dirlookup>
8010559a:	83 c4 10             	add    $0x10,%esp
8010559d:	89 45 f0             	mov    %eax,-0x10(%ebp)
801055a0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801055a4:	74 50                	je     801055f6 <create+0xbd>
    iunlockput(dp);
801055a6:	83 ec 0c             	sub    $0xc,%esp
801055a9:	ff 75 f4             	push   -0xc(%ebp)
801055ac:	e8 65 c6 ff ff       	call   80101c16 <iunlockput>
801055b1:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801055b4:	83 ec 0c             	sub    $0xc,%esp
801055b7:	ff 75 f0             	push   -0x10(%ebp)
801055ba:	e8 26 c4 ff ff       	call   801019e5 <ilock>
801055bf:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
801055c2:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801055c7:	75 15                	jne    801055de <create+0xa5>
801055c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055cc:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801055d0:	66 83 f8 02          	cmp    $0x2,%ax
801055d4:	75 08                	jne    801055de <create+0xa5>
      return ip;
801055d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055d9:	e9 2b 01 00 00       	jmp    80105709 <create+0x1d0>
    iunlockput(ip);
801055de:	83 ec 0c             	sub    $0xc,%esp
801055e1:	ff 75 f0             	push   -0x10(%ebp)
801055e4:	e8 2d c6 ff ff       	call   80101c16 <iunlockput>
801055e9:	83 c4 10             	add    $0x10,%esp
    return 0;
801055ec:	b8 00 00 00 00       	mov    $0x0,%eax
801055f1:	e9 13 01 00 00       	jmp    80105709 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801055f6:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801055fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055fd:	8b 00                	mov    (%eax),%eax
801055ff:	83 ec 08             	sub    $0x8,%esp
80105602:	52                   	push   %edx
80105603:	50                   	push   %eax
80105604:	e8 28 c1 ff ff       	call   80101731 <ialloc>
80105609:	83 c4 10             	add    $0x10,%esp
8010560c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010560f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105613:	75 0d                	jne    80105622 <create+0xe9>
    panic("create: ialloc");
80105615:	83 ec 0c             	sub    $0xc,%esp
80105618:	68 71 a5 10 80       	push   $0x8010a571
8010561d:	e8 87 af ff ff       	call   801005a9 <panic>

  ilock(ip);
80105622:	83 ec 0c             	sub    $0xc,%esp
80105625:	ff 75 f0             	push   -0x10(%ebp)
80105628:	e8 b8 c3 ff ff       	call   801019e5 <ilock>
8010562d:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105630:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105633:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105637:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
8010563b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010563e:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105642:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105646:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105649:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
8010564f:	83 ec 0c             	sub    $0xc,%esp
80105652:	ff 75 f0             	push   -0x10(%ebp)
80105655:	e8 ae c1 ff ff       	call   80101808 <iupdate>
8010565a:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
8010565d:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105662:	75 6a                	jne    801056ce <create+0x195>
    dp->nlink++;  // for ".."
80105664:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105667:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010566b:	83 c0 01             	add    $0x1,%eax
8010566e:	89 c2                	mov    %eax,%edx
80105670:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105673:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105677:	83 ec 0c             	sub    $0xc,%esp
8010567a:	ff 75 f4             	push   -0xc(%ebp)
8010567d:	e8 86 c1 ff ff       	call   80101808 <iupdate>
80105682:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105685:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105688:	8b 40 04             	mov    0x4(%eax),%eax
8010568b:	83 ec 04             	sub    $0x4,%esp
8010568e:	50                   	push   %eax
8010568f:	68 4b a5 10 80       	push   $0x8010a54b
80105694:	ff 75 f0             	push   -0x10(%ebp)
80105697:	e8 e5 cb ff ff       	call   80102281 <dirlink>
8010569c:	83 c4 10             	add    $0x10,%esp
8010569f:	85 c0                	test   %eax,%eax
801056a1:	78 1e                	js     801056c1 <create+0x188>
801056a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056a6:	8b 40 04             	mov    0x4(%eax),%eax
801056a9:	83 ec 04             	sub    $0x4,%esp
801056ac:	50                   	push   %eax
801056ad:	68 4d a5 10 80       	push   $0x8010a54d
801056b2:	ff 75 f0             	push   -0x10(%ebp)
801056b5:	e8 c7 cb ff ff       	call   80102281 <dirlink>
801056ba:	83 c4 10             	add    $0x10,%esp
801056bd:	85 c0                	test   %eax,%eax
801056bf:	79 0d                	jns    801056ce <create+0x195>
      panic("create dots");
801056c1:	83 ec 0c             	sub    $0xc,%esp
801056c4:	68 80 a5 10 80       	push   $0x8010a580
801056c9:	e8 db ae ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801056ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056d1:	8b 40 04             	mov    0x4(%eax),%eax
801056d4:	83 ec 04             	sub    $0x4,%esp
801056d7:	50                   	push   %eax
801056d8:	8d 45 de             	lea    -0x22(%ebp),%eax
801056db:	50                   	push   %eax
801056dc:	ff 75 f4             	push   -0xc(%ebp)
801056df:	e8 9d cb ff ff       	call   80102281 <dirlink>
801056e4:	83 c4 10             	add    $0x10,%esp
801056e7:	85 c0                	test   %eax,%eax
801056e9:	79 0d                	jns    801056f8 <create+0x1bf>
    panic("create: dirlink");
801056eb:	83 ec 0c             	sub    $0xc,%esp
801056ee:	68 8c a5 10 80       	push   $0x8010a58c
801056f3:	e8 b1 ae ff ff       	call   801005a9 <panic>

  iunlockput(dp);
801056f8:	83 ec 0c             	sub    $0xc,%esp
801056fb:	ff 75 f4             	push   -0xc(%ebp)
801056fe:	e8 13 c5 ff ff       	call   80101c16 <iunlockput>
80105703:	83 c4 10             	add    $0x10,%esp

  return ip;
80105706:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105709:	c9                   	leave  
8010570a:	c3                   	ret    

8010570b <sys_open>:

int
sys_open(void)
{
8010570b:	55                   	push   %ebp
8010570c:	89 e5                	mov    %esp,%ebp
8010570e:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105711:	83 ec 08             	sub    $0x8,%esp
80105714:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105717:	50                   	push   %eax
80105718:	6a 00                	push   $0x0
8010571a:	e8 ea f6 ff ff       	call   80104e09 <argstr>
8010571f:	83 c4 10             	add    $0x10,%esp
80105722:	85 c0                	test   %eax,%eax
80105724:	78 15                	js     8010573b <sys_open+0x30>
80105726:	83 ec 08             	sub    $0x8,%esp
80105729:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010572c:	50                   	push   %eax
8010572d:	6a 01                	push   $0x1
8010572f:	e8 67 f6 ff ff       	call   80104d9b <argint>
80105734:	83 c4 10             	add    $0x10,%esp
80105737:	85 c0                	test   %eax,%eax
80105739:	79 0a                	jns    80105745 <sys_open+0x3a>
    return -1;
8010573b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105740:	e9 61 01 00 00       	jmp    801058a6 <sys_open+0x19b>

  begin_op();
80105745:	e8 ed d8 ff ff       	call   80103037 <begin_op>

  if(omode & O_CREATE){
8010574a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010574d:	25 00 02 00 00       	and    $0x200,%eax
80105752:	85 c0                	test   %eax,%eax
80105754:	74 2a                	je     80105780 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105756:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105759:	6a 00                	push   $0x0
8010575b:	6a 00                	push   $0x0
8010575d:	6a 02                	push   $0x2
8010575f:	50                   	push   %eax
80105760:	e8 d4 fd ff ff       	call   80105539 <create>
80105765:	83 c4 10             	add    $0x10,%esp
80105768:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
8010576b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010576f:	75 75                	jne    801057e6 <sys_open+0xdb>
      end_op();
80105771:	e8 4d d9 ff ff       	call   801030c3 <end_op>
      return -1;
80105776:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010577b:	e9 26 01 00 00       	jmp    801058a6 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105780:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105783:	83 ec 0c             	sub    $0xc,%esp
80105786:	50                   	push   %eax
80105787:	e8 8c cd ff ff       	call   80102518 <namei>
8010578c:	83 c4 10             	add    $0x10,%esp
8010578f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105792:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105796:	75 0f                	jne    801057a7 <sys_open+0x9c>
      end_op();
80105798:	e8 26 d9 ff ff       	call   801030c3 <end_op>
      return -1;
8010579d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057a2:	e9 ff 00 00 00       	jmp    801058a6 <sys_open+0x19b>
    }
    ilock(ip);
801057a7:	83 ec 0c             	sub    $0xc,%esp
801057aa:	ff 75 f4             	push   -0xc(%ebp)
801057ad:	e8 33 c2 ff ff       	call   801019e5 <ilock>
801057b2:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
801057b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057b8:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801057bc:	66 83 f8 01          	cmp    $0x1,%ax
801057c0:	75 24                	jne    801057e6 <sys_open+0xdb>
801057c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801057c5:	85 c0                	test   %eax,%eax
801057c7:	74 1d                	je     801057e6 <sys_open+0xdb>
      iunlockput(ip);
801057c9:	83 ec 0c             	sub    $0xc,%esp
801057cc:	ff 75 f4             	push   -0xc(%ebp)
801057cf:	e8 42 c4 ff ff       	call   80101c16 <iunlockput>
801057d4:	83 c4 10             	add    $0x10,%esp
      end_op();
801057d7:	e8 e7 d8 ff ff       	call   801030c3 <end_op>
      return -1;
801057dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057e1:	e9 c0 00 00 00       	jmp    801058a6 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801057e6:	e8 ed b7 ff ff       	call   80100fd8 <filealloc>
801057eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
801057ee:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801057f2:	74 17                	je     8010580b <sys_open+0x100>
801057f4:	83 ec 0c             	sub    $0xc,%esp
801057f7:	ff 75 f0             	push   -0x10(%ebp)
801057fa:	e8 33 f7 ff ff       	call   80104f32 <fdalloc>
801057ff:	83 c4 10             	add    $0x10,%esp
80105802:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105805:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105809:	79 2e                	jns    80105839 <sys_open+0x12e>
    if(f)
8010580b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010580f:	74 0e                	je     8010581f <sys_open+0x114>
      fileclose(f);
80105811:	83 ec 0c             	sub    $0xc,%esp
80105814:	ff 75 f0             	push   -0x10(%ebp)
80105817:	e8 7a b8 ff ff       	call   80101096 <fileclose>
8010581c:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010581f:	83 ec 0c             	sub    $0xc,%esp
80105822:	ff 75 f4             	push   -0xc(%ebp)
80105825:	e8 ec c3 ff ff       	call   80101c16 <iunlockput>
8010582a:	83 c4 10             	add    $0x10,%esp
    end_op();
8010582d:	e8 91 d8 ff ff       	call   801030c3 <end_op>
    return -1;
80105832:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105837:	eb 6d                	jmp    801058a6 <sys_open+0x19b>
  }
  iunlock(ip);
80105839:	83 ec 0c             	sub    $0xc,%esp
8010583c:	ff 75 f4             	push   -0xc(%ebp)
8010583f:	e8 b4 c2 ff ff       	call   80101af8 <iunlock>
80105844:	83 c4 10             	add    $0x10,%esp
  end_op();
80105847:	e8 77 d8 ff ff       	call   801030c3 <end_op>

  f->type = FD_INODE;
8010584c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010584f:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105855:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105858:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010585b:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010585e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105861:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105868:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010586b:	83 e0 01             	and    $0x1,%eax
8010586e:	85 c0                	test   %eax,%eax
80105870:	0f 94 c0             	sete   %al
80105873:	89 c2                	mov    %eax,%edx
80105875:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105878:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010587b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010587e:	83 e0 01             	and    $0x1,%eax
80105881:	85 c0                	test   %eax,%eax
80105883:	75 0a                	jne    8010588f <sys_open+0x184>
80105885:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105888:	83 e0 02             	and    $0x2,%eax
8010588b:	85 c0                	test   %eax,%eax
8010588d:	74 07                	je     80105896 <sys_open+0x18b>
8010588f:	b8 01 00 00 00       	mov    $0x1,%eax
80105894:	eb 05                	jmp    8010589b <sys_open+0x190>
80105896:	b8 00 00 00 00       	mov    $0x0,%eax
8010589b:	89 c2                	mov    %eax,%edx
8010589d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058a0:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801058a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801058a6:	c9                   	leave  
801058a7:	c3                   	ret    

801058a8 <sys_mkdir>:

int
sys_mkdir(void)
{
801058a8:	55                   	push   %ebp
801058a9:	89 e5                	mov    %esp,%ebp
801058ab:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801058ae:	e8 84 d7 ff ff       	call   80103037 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801058b3:	83 ec 08             	sub    $0x8,%esp
801058b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058b9:	50                   	push   %eax
801058ba:	6a 00                	push   $0x0
801058bc:	e8 48 f5 ff ff       	call   80104e09 <argstr>
801058c1:	83 c4 10             	add    $0x10,%esp
801058c4:	85 c0                	test   %eax,%eax
801058c6:	78 1b                	js     801058e3 <sys_mkdir+0x3b>
801058c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058cb:	6a 00                	push   $0x0
801058cd:	6a 00                	push   $0x0
801058cf:	6a 01                	push   $0x1
801058d1:	50                   	push   %eax
801058d2:	e8 62 fc ff ff       	call   80105539 <create>
801058d7:	83 c4 10             	add    $0x10,%esp
801058da:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058e1:	75 0c                	jne    801058ef <sys_mkdir+0x47>
    end_op();
801058e3:	e8 db d7 ff ff       	call   801030c3 <end_op>
    return -1;
801058e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058ed:	eb 18                	jmp    80105907 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
801058ef:	83 ec 0c             	sub    $0xc,%esp
801058f2:	ff 75 f4             	push   -0xc(%ebp)
801058f5:	e8 1c c3 ff ff       	call   80101c16 <iunlockput>
801058fa:	83 c4 10             	add    $0x10,%esp
  end_op();
801058fd:	e8 c1 d7 ff ff       	call   801030c3 <end_op>
  return 0;
80105902:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105907:	c9                   	leave  
80105908:	c3                   	ret    

80105909 <sys_mknod>:

int
sys_mknod(void)
{
80105909:	55                   	push   %ebp
8010590a:	89 e5                	mov    %esp,%ebp
8010590c:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
8010590f:	e8 23 d7 ff ff       	call   80103037 <begin_op>
  if((argstr(0, &path)) < 0 ||
80105914:	83 ec 08             	sub    $0x8,%esp
80105917:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010591a:	50                   	push   %eax
8010591b:	6a 00                	push   $0x0
8010591d:	e8 e7 f4 ff ff       	call   80104e09 <argstr>
80105922:	83 c4 10             	add    $0x10,%esp
80105925:	85 c0                	test   %eax,%eax
80105927:	78 4f                	js     80105978 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80105929:	83 ec 08             	sub    $0x8,%esp
8010592c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010592f:	50                   	push   %eax
80105930:	6a 01                	push   $0x1
80105932:	e8 64 f4 ff ff       	call   80104d9b <argint>
80105937:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
8010593a:	85 c0                	test   %eax,%eax
8010593c:	78 3a                	js     80105978 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
8010593e:	83 ec 08             	sub    $0x8,%esp
80105941:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105944:	50                   	push   %eax
80105945:	6a 02                	push   $0x2
80105947:	e8 4f f4 ff ff       	call   80104d9b <argint>
8010594c:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
8010594f:	85 c0                	test   %eax,%eax
80105951:	78 25                	js     80105978 <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105953:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105956:	0f bf c8             	movswl %ax,%ecx
80105959:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010595c:	0f bf d0             	movswl %ax,%edx
8010595f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105962:	51                   	push   %ecx
80105963:	52                   	push   %edx
80105964:	6a 03                	push   $0x3
80105966:	50                   	push   %eax
80105967:	e8 cd fb ff ff       	call   80105539 <create>
8010596c:	83 c4 10             	add    $0x10,%esp
8010596f:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105972:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105976:	75 0c                	jne    80105984 <sys_mknod+0x7b>
    end_op();
80105978:	e8 46 d7 ff ff       	call   801030c3 <end_op>
    return -1;
8010597d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105982:	eb 18                	jmp    8010599c <sys_mknod+0x93>
  }
  iunlockput(ip);
80105984:	83 ec 0c             	sub    $0xc,%esp
80105987:	ff 75 f4             	push   -0xc(%ebp)
8010598a:	e8 87 c2 ff ff       	call   80101c16 <iunlockput>
8010598f:	83 c4 10             	add    $0x10,%esp
  end_op();
80105992:	e8 2c d7 ff ff       	call   801030c3 <end_op>
  return 0;
80105997:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010599c:	c9                   	leave  
8010599d:	c3                   	ret    

8010599e <sys_chdir>:

int
sys_chdir(void)
{
8010599e:	55                   	push   %ebp
8010599f:	89 e5                	mov    %esp,%ebp
801059a1:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801059a4:	e8 82 e0 ff ff       	call   80103a2b <myproc>
801059a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
801059ac:	e8 86 d6 ff ff       	call   80103037 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801059b1:	83 ec 08             	sub    $0x8,%esp
801059b4:	8d 45 ec             	lea    -0x14(%ebp),%eax
801059b7:	50                   	push   %eax
801059b8:	6a 00                	push   $0x0
801059ba:	e8 4a f4 ff ff       	call   80104e09 <argstr>
801059bf:	83 c4 10             	add    $0x10,%esp
801059c2:	85 c0                	test   %eax,%eax
801059c4:	78 18                	js     801059de <sys_chdir+0x40>
801059c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801059c9:	83 ec 0c             	sub    $0xc,%esp
801059cc:	50                   	push   %eax
801059cd:	e8 46 cb ff ff       	call   80102518 <namei>
801059d2:	83 c4 10             	add    $0x10,%esp
801059d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801059d8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059dc:	75 0c                	jne    801059ea <sys_chdir+0x4c>
    end_op();
801059de:	e8 e0 d6 ff ff       	call   801030c3 <end_op>
    return -1;
801059e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059e8:	eb 68                	jmp    80105a52 <sys_chdir+0xb4>
  }
  ilock(ip);
801059ea:	83 ec 0c             	sub    $0xc,%esp
801059ed:	ff 75 f0             	push   -0x10(%ebp)
801059f0:	e8 f0 bf ff ff       	call   801019e5 <ilock>
801059f5:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
801059f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059fb:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801059ff:	66 83 f8 01          	cmp    $0x1,%ax
80105a03:	74 1a                	je     80105a1f <sys_chdir+0x81>
    iunlockput(ip);
80105a05:	83 ec 0c             	sub    $0xc,%esp
80105a08:	ff 75 f0             	push   -0x10(%ebp)
80105a0b:	e8 06 c2 ff ff       	call   80101c16 <iunlockput>
80105a10:	83 c4 10             	add    $0x10,%esp
    end_op();
80105a13:	e8 ab d6 ff ff       	call   801030c3 <end_op>
    return -1;
80105a18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a1d:	eb 33                	jmp    80105a52 <sys_chdir+0xb4>
  }
  iunlock(ip);
80105a1f:	83 ec 0c             	sub    $0xc,%esp
80105a22:	ff 75 f0             	push   -0x10(%ebp)
80105a25:	e8 ce c0 ff ff       	call   80101af8 <iunlock>
80105a2a:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105a2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a30:	8b 40 68             	mov    0x68(%eax),%eax
80105a33:	83 ec 0c             	sub    $0xc,%esp
80105a36:	50                   	push   %eax
80105a37:	e8 0a c1 ff ff       	call   80101b46 <iput>
80105a3c:	83 c4 10             	add    $0x10,%esp
  end_op();
80105a3f:	e8 7f d6 ff ff       	call   801030c3 <end_op>
  curproc->cwd = ip;
80105a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a47:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a4a:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105a4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a52:	c9                   	leave  
80105a53:	c3                   	ret    

80105a54 <sys_exec>:

int
sys_exec(void)
{
80105a54:	55                   	push   %ebp
80105a55:	89 e5                	mov    %esp,%ebp
80105a57:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105a5d:	83 ec 08             	sub    $0x8,%esp
80105a60:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a63:	50                   	push   %eax
80105a64:	6a 00                	push   $0x0
80105a66:	e8 9e f3 ff ff       	call   80104e09 <argstr>
80105a6b:	83 c4 10             	add    $0x10,%esp
80105a6e:	85 c0                	test   %eax,%eax
80105a70:	78 18                	js     80105a8a <sys_exec+0x36>
80105a72:	83 ec 08             	sub    $0x8,%esp
80105a75:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105a7b:	50                   	push   %eax
80105a7c:	6a 01                	push   $0x1
80105a7e:	e8 18 f3 ff ff       	call   80104d9b <argint>
80105a83:	83 c4 10             	add    $0x10,%esp
80105a86:	85 c0                	test   %eax,%eax
80105a88:	79 0a                	jns    80105a94 <sys_exec+0x40>
    return -1;
80105a8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a8f:	e9 c6 00 00 00       	jmp    80105b5a <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80105a94:	83 ec 04             	sub    $0x4,%esp
80105a97:	68 80 00 00 00       	push   $0x80
80105a9c:	6a 00                	push   $0x0
80105a9e:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105aa4:	50                   	push   %eax
80105aa5:	e8 02 f0 ff ff       	call   80104aac <memset>
80105aaa:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105aad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ab7:	83 f8 1f             	cmp    $0x1f,%eax
80105aba:	76 0a                	jbe    80105ac6 <sys_exec+0x72>
      return -1;
80105abc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ac1:	e9 94 00 00 00       	jmp    80105b5a <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ac9:	c1 e0 02             	shl    $0x2,%eax
80105acc:	89 c2                	mov    %eax,%edx
80105ace:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105ad4:	01 c2                	add    %eax,%edx
80105ad6:	83 ec 08             	sub    $0x8,%esp
80105ad9:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105adf:	50                   	push   %eax
80105ae0:	52                   	push   %edx
80105ae1:	e8 50 f2 ff ff       	call   80104d36 <fetchint>
80105ae6:	83 c4 10             	add    $0x10,%esp
80105ae9:	85 c0                	test   %eax,%eax
80105aeb:	79 07                	jns    80105af4 <sys_exec+0xa0>
      return -1;
80105aed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105af2:	eb 66                	jmp    80105b5a <sys_exec+0x106>
    if(uarg == 0){
80105af4:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105afa:	85 c0                	test   %eax,%eax
80105afc:	75 27                	jne    80105b25 <sys_exec+0xd1>
      argv[i] = 0;
80105afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b01:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105b08:	00 00 00 00 
      break;
80105b0c:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105b0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b10:	83 ec 08             	sub    $0x8,%esp
80105b13:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105b19:	52                   	push   %edx
80105b1a:	50                   	push   %eax
80105b1b:	e8 60 b0 ff ff       	call   80100b80 <exec>
80105b20:	83 c4 10             	add    $0x10,%esp
80105b23:	eb 35                	jmp    80105b5a <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105b25:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b2e:	c1 e0 02             	shl    $0x2,%eax
80105b31:	01 c2                	add    %eax,%edx
80105b33:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105b39:	83 ec 08             	sub    $0x8,%esp
80105b3c:	52                   	push   %edx
80105b3d:	50                   	push   %eax
80105b3e:	e8 07 f2 ff ff       	call   80104d4a <fetchstr>
80105b43:	83 c4 10             	add    $0x10,%esp
80105b46:	85 c0                	test   %eax,%eax
80105b48:	79 07                	jns    80105b51 <sys_exec+0xfd>
      return -1;
80105b4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b4f:	eb 09                	jmp    80105b5a <sys_exec+0x106>
  for(i=0;; i++){
80105b51:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105b55:	e9 5a ff ff ff       	jmp    80105ab4 <sys_exec+0x60>
}
80105b5a:	c9                   	leave  
80105b5b:	c3                   	ret    

80105b5c <sys_pipe>:

int
sys_pipe(void)
{
80105b5c:	55                   	push   %ebp
80105b5d:	89 e5                	mov    %esp,%ebp
80105b5f:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105b62:	83 ec 04             	sub    $0x4,%esp
80105b65:	6a 08                	push   $0x8
80105b67:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b6a:	50                   	push   %eax
80105b6b:	6a 00                	push   $0x0
80105b6d:	e8 56 f2 ff ff       	call   80104dc8 <argptr>
80105b72:	83 c4 10             	add    $0x10,%esp
80105b75:	85 c0                	test   %eax,%eax
80105b77:	79 0a                	jns    80105b83 <sys_pipe+0x27>
    return -1;
80105b79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b7e:	e9 ae 00 00 00       	jmp    80105c31 <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105b83:	83 ec 08             	sub    $0x8,%esp
80105b86:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105b89:	50                   	push   %eax
80105b8a:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105b8d:	50                   	push   %eax
80105b8e:	e8 d5 d9 ff ff       	call   80103568 <pipealloc>
80105b93:	83 c4 10             	add    $0x10,%esp
80105b96:	85 c0                	test   %eax,%eax
80105b98:	79 0a                	jns    80105ba4 <sys_pipe+0x48>
    return -1;
80105b9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b9f:	e9 8d 00 00 00       	jmp    80105c31 <sys_pipe+0xd5>
  fd0 = -1;
80105ba4:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105bab:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105bae:	83 ec 0c             	sub    $0xc,%esp
80105bb1:	50                   	push   %eax
80105bb2:	e8 7b f3 ff ff       	call   80104f32 <fdalloc>
80105bb7:	83 c4 10             	add    $0x10,%esp
80105bba:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bbd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bc1:	78 18                	js     80105bdb <sys_pipe+0x7f>
80105bc3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105bc6:	83 ec 0c             	sub    $0xc,%esp
80105bc9:	50                   	push   %eax
80105bca:	e8 63 f3 ff ff       	call   80104f32 <fdalloc>
80105bcf:	83 c4 10             	add    $0x10,%esp
80105bd2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105bd5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105bd9:	79 3e                	jns    80105c19 <sys_pipe+0xbd>
    if(fd0 >= 0)
80105bdb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bdf:	78 13                	js     80105bf4 <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105be1:	e8 45 de ff ff       	call   80103a2b <myproc>
80105be6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105be9:	83 c2 08             	add    $0x8,%edx
80105bec:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105bf3:	00 
    fileclose(rf);
80105bf4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105bf7:	83 ec 0c             	sub    $0xc,%esp
80105bfa:	50                   	push   %eax
80105bfb:	e8 96 b4 ff ff       	call   80101096 <fileclose>
80105c00:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105c03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c06:	83 ec 0c             	sub    $0xc,%esp
80105c09:	50                   	push   %eax
80105c0a:	e8 87 b4 ff ff       	call   80101096 <fileclose>
80105c0f:	83 c4 10             	add    $0x10,%esp
    return -1;
80105c12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c17:	eb 18                	jmp    80105c31 <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80105c19:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105c1c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c1f:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105c21:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105c24:	8d 50 04             	lea    0x4(%eax),%edx
80105c27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c2a:	89 02                	mov    %eax,(%edx)
  return 0;
80105c2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c31:	c9                   	leave  
80105c32:	c3                   	ret    

80105c33 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80105c33:	55                   	push   %ebp
80105c34:	89 e5                	mov    %esp,%ebp
80105c36:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105c39:	e8 ec e0 ff ff       	call   80103d2a <fork>
}
80105c3e:	c9                   	leave  
80105c3f:	c3                   	ret    

80105c40 <sys_exit>:

int
sys_exit(void)
{
80105c40:	55                   	push   %ebp
80105c41:	89 e5                	mov    %esp,%ebp
80105c43:	83 ec 08             	sub    $0x8,%esp
  exit();
80105c46:	e8 58 e2 ff ff       	call   80103ea3 <exit>
  return 0;  // not reached
80105c4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c50:	c9                   	leave  
80105c51:	c3                   	ret    

80105c52 <sys_wait>:

int
sys_wait(void)
{
80105c52:	55                   	push   %ebp
80105c53:	89 e5                	mov    %esp,%ebp
80105c55:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105c58:	e8 66 e3 ff ff       	call   80103fc3 <wait>
}
80105c5d:	c9                   	leave  
80105c5e:	c3                   	ret    

80105c5f <sys_kill>:

int
sys_kill(void)
{
80105c5f:	55                   	push   %ebp
80105c60:	89 e5                	mov    %esp,%ebp
80105c62:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105c65:	83 ec 08             	sub    $0x8,%esp
80105c68:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c6b:	50                   	push   %eax
80105c6c:	6a 00                	push   $0x0
80105c6e:	e8 28 f1 ff ff       	call   80104d9b <argint>
80105c73:	83 c4 10             	add    $0x10,%esp
80105c76:	85 c0                	test   %eax,%eax
80105c78:	79 07                	jns    80105c81 <sys_kill+0x22>
    return -1;
80105c7a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c7f:	eb 0f                	jmp    80105c90 <sys_kill+0x31>
  return kill(pid);
80105c81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c84:	83 ec 0c             	sub    $0xc,%esp
80105c87:	50                   	push   %eax
80105c88:	e8 65 e7 ff ff       	call   801043f2 <kill>
80105c8d:	83 c4 10             	add    $0x10,%esp
}
80105c90:	c9                   	leave  
80105c91:	c3                   	ret    

80105c92 <sys_getpid>:

int
sys_getpid(void)
{
80105c92:	55                   	push   %ebp
80105c93:	89 e5                	mov    %esp,%ebp
80105c95:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105c98:	e8 8e dd ff ff       	call   80103a2b <myproc>
80105c9d:	8b 40 10             	mov    0x10(%eax),%eax
}
80105ca0:	c9                   	leave  
80105ca1:	c3                   	ret    

80105ca2 <sys_sbrk>:

int
sys_sbrk(void)
{
80105ca2:	55                   	push   %ebp
80105ca3:	89 e5                	mov    %esp,%ebp
80105ca5:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105ca8:	83 ec 08             	sub    $0x8,%esp
80105cab:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105cae:	50                   	push   %eax
80105caf:	6a 00                	push   $0x0
80105cb1:	e8 e5 f0 ff ff       	call   80104d9b <argint>
80105cb6:	83 c4 10             	add    $0x10,%esp
80105cb9:	85 c0                	test   %eax,%eax
80105cbb:	79 07                	jns    80105cc4 <sys_sbrk+0x22>
    return -1;
80105cbd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cc2:	eb 27                	jmp    80105ceb <sys_sbrk+0x49>
  addr = myproc()->sz;
80105cc4:	e8 62 dd ff ff       	call   80103a2b <myproc>
80105cc9:	8b 00                	mov    (%eax),%eax
80105ccb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80105cce:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cd1:	83 ec 0c             	sub    $0xc,%esp
80105cd4:	50                   	push   %eax
80105cd5:	e8 b5 df ff ff       	call   80103c8f <growproc>
80105cda:	83 c4 10             	add    $0x10,%esp
80105cdd:	85 c0                	test   %eax,%eax
80105cdf:	79 07                	jns    80105ce8 <sys_sbrk+0x46>
    return -1;
80105ce1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ce6:	eb 03                	jmp    80105ceb <sys_sbrk+0x49>
  return addr;
80105ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105ceb:	c9                   	leave  
80105cec:	c3                   	ret    

80105ced <sys_sleep>:

int
sys_sleep(void)
{
80105ced:	55                   	push   %ebp
80105cee:	89 e5                	mov    %esp,%ebp
80105cf0:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105cf3:	83 ec 08             	sub    $0x8,%esp
80105cf6:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105cf9:	50                   	push   %eax
80105cfa:	6a 00                	push   $0x0
80105cfc:	e8 9a f0 ff ff       	call   80104d9b <argint>
80105d01:	83 c4 10             	add    $0x10,%esp
80105d04:	85 c0                	test   %eax,%eax
80105d06:	79 07                	jns    80105d0f <sys_sleep+0x22>
    return -1;
80105d08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d0d:	eb 76                	jmp    80105d85 <sys_sleep+0x98>
  acquire(&tickslock);
80105d0f:	83 ec 0c             	sub    $0xc,%esp
80105d12:	68 40 6a 19 80       	push   $0x80196a40
80105d17:	e8 1a eb ff ff       	call   80104836 <acquire>
80105d1c:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80105d1f:	a1 74 6a 19 80       	mov    0x80196a74,%eax
80105d24:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80105d27:	eb 38                	jmp    80105d61 <sys_sleep+0x74>
    if(myproc()->killed){
80105d29:	e8 fd dc ff ff       	call   80103a2b <myproc>
80105d2e:	8b 40 24             	mov    0x24(%eax),%eax
80105d31:	85 c0                	test   %eax,%eax
80105d33:	74 17                	je     80105d4c <sys_sleep+0x5f>
      release(&tickslock);
80105d35:	83 ec 0c             	sub    $0xc,%esp
80105d38:	68 40 6a 19 80       	push   $0x80196a40
80105d3d:	e8 62 eb ff ff       	call   801048a4 <release>
80105d42:	83 c4 10             	add    $0x10,%esp
      return -1;
80105d45:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d4a:	eb 39                	jmp    80105d85 <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80105d4c:	83 ec 08             	sub    $0x8,%esp
80105d4f:	68 40 6a 19 80       	push   $0x80196a40
80105d54:	68 74 6a 19 80       	push   $0x80196a74
80105d59:	e8 76 e5 ff ff       	call   801042d4 <sleep>
80105d5e:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80105d61:	a1 74 6a 19 80       	mov    0x80196a74,%eax
80105d66:	2b 45 f4             	sub    -0xc(%ebp),%eax
80105d69:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d6c:	39 d0                	cmp    %edx,%eax
80105d6e:	72 b9                	jb     80105d29 <sys_sleep+0x3c>
  }
  release(&tickslock);
80105d70:	83 ec 0c             	sub    $0xc,%esp
80105d73:	68 40 6a 19 80       	push   $0x80196a40
80105d78:	e8 27 eb ff ff       	call   801048a4 <release>
80105d7d:	83 c4 10             	add    $0x10,%esp
  return 0;
80105d80:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d85:	c9                   	leave  
80105d86:	c3                   	ret    

80105d87 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105d87:	55                   	push   %ebp
80105d88:	89 e5                	mov    %esp,%ebp
80105d8a:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80105d8d:	83 ec 0c             	sub    $0xc,%esp
80105d90:	68 40 6a 19 80       	push   $0x80196a40
80105d95:	e8 9c ea ff ff       	call   80104836 <acquire>
80105d9a:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80105d9d:	a1 74 6a 19 80       	mov    0x80196a74,%eax
80105da2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80105da5:	83 ec 0c             	sub    $0xc,%esp
80105da8:	68 40 6a 19 80       	push   $0x80196a40
80105dad:	e8 f2 ea ff ff       	call   801048a4 <release>
80105db2:	83 c4 10             	add    $0x10,%esp
  return xticks;
80105db5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105db8:	c9                   	leave  
80105db9:	c3                   	ret    

80105dba <sys_printpt>:

int sys_printpt(int pid)
{
80105dba:	55                   	push   %ebp
80105dbb:	89 e5                	mov    %esp,%ebp
80105dbd:	83 ec 18             	sub    $0x18,%esp
  int n;
  if (argint(0, &n) < 0)
80105dc0:	83 ec 08             	sub    $0x8,%esp
80105dc3:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105dc6:	50                   	push   %eax
80105dc7:	6a 00                	push   $0x0
80105dc9:	e8 cd ef ff ff       	call   80104d9b <argint>
80105dce:	83 c4 10             	add    $0x10,%esp
80105dd1:	85 c0                	test   %eax,%eax
80105dd3:	79 07                	jns    80105ddc <sys_printpt+0x22>
    return -1;
80105dd5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dda:	eb 14                	jmp    80105df0 <sys_printpt+0x36>
  printpt(n);
80105ddc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ddf:	83 ec 0c             	sub    $0xc,%esp
80105de2:	50                   	push   %eax
80105de3:	e8 88 e7 ff ff       	call   80104570 <printpt>
80105de8:	83 c4 10             	add    $0x10,%esp
  return 0;
80105deb:	b8 00 00 00 00       	mov    $0x0,%eax
80105df0:	c9                   	leave  
80105df1:	c3                   	ret    

80105df2 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80105df2:	1e                   	push   %ds
  pushl %es
80105df3:	06                   	push   %es
  pushl %fs
80105df4:	0f a0                	push   %fs
  pushl %gs
80105df6:	0f a8                	push   %gs
  pushal
80105df8:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80105df9:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80105dfd:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80105dff:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80105e01:	54                   	push   %esp
  call trap
80105e02:	e8 d7 01 00 00       	call   80105fde <trap>
  addl $4, %esp
80105e07:	83 c4 04             	add    $0x4,%esp

80105e0a <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80105e0a:	61                   	popa   
  popl %gs
80105e0b:	0f a9                	pop    %gs
  popl %fs
80105e0d:	0f a1                	pop    %fs
  popl %es
80105e0f:	07                   	pop    %es
  popl %ds
80105e10:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80105e11:	83 c4 08             	add    $0x8,%esp
  iret
80105e14:	cf                   	iret   

80105e15 <lidt>:
{
80105e15:	55                   	push   %ebp
80105e16:	89 e5                	mov    %esp,%ebp
80105e18:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80105e1b:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e1e:	83 e8 01             	sub    $0x1,%eax
80105e21:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80105e25:	8b 45 08             	mov    0x8(%ebp),%eax
80105e28:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105e2c:	8b 45 08             	mov    0x8(%ebp),%eax
80105e2f:	c1 e8 10             	shr    $0x10,%eax
80105e32:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105e36:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105e39:	0f 01 18             	lidtl  (%eax)
}
80105e3c:	90                   	nop
80105e3d:	c9                   	leave  
80105e3e:	c3                   	ret    

80105e3f <rcr2>:

static inline uint
rcr2(void)
{
80105e3f:	55                   	push   %ebp
80105e40:	89 e5                	mov    %esp,%ebp
80105e42:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105e45:	0f 20 d0             	mov    %cr2,%eax
80105e48:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80105e4b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105e4e:	c9                   	leave  
80105e4f:	c3                   	ret    

80105e50 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80105e50:	55                   	push   %ebp
80105e51:	89 e5                	mov    %esp,%ebp
80105e53:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80105e56:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105e5d:	e9 c3 00 00 00       	jmp    80105f25 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80105e62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e65:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
80105e6c:	89 c2                	mov    %eax,%edx
80105e6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e71:	66 89 14 c5 40 62 19 	mov    %dx,-0x7fe69dc0(,%eax,8)
80105e78:	80 
80105e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e7c:	66 c7 04 c5 42 62 19 	movw   $0x8,-0x7fe69dbe(,%eax,8)
80105e83:	80 08 00 
80105e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e89:	0f b6 14 c5 44 62 19 	movzbl -0x7fe69dbc(,%eax,8),%edx
80105e90:	80 
80105e91:	83 e2 e0             	and    $0xffffffe0,%edx
80105e94:	88 14 c5 44 62 19 80 	mov    %dl,-0x7fe69dbc(,%eax,8)
80105e9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e9e:	0f b6 14 c5 44 62 19 	movzbl -0x7fe69dbc(,%eax,8),%edx
80105ea5:	80 
80105ea6:	83 e2 1f             	and    $0x1f,%edx
80105ea9:	88 14 c5 44 62 19 80 	mov    %dl,-0x7fe69dbc(,%eax,8)
80105eb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eb3:	0f b6 14 c5 45 62 19 	movzbl -0x7fe69dbb(,%eax,8),%edx
80105eba:	80 
80105ebb:	83 e2 f0             	and    $0xfffffff0,%edx
80105ebe:	83 ca 0e             	or     $0xe,%edx
80105ec1:	88 14 c5 45 62 19 80 	mov    %dl,-0x7fe69dbb(,%eax,8)
80105ec8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ecb:	0f b6 14 c5 45 62 19 	movzbl -0x7fe69dbb(,%eax,8),%edx
80105ed2:	80 
80105ed3:	83 e2 ef             	and    $0xffffffef,%edx
80105ed6:	88 14 c5 45 62 19 80 	mov    %dl,-0x7fe69dbb(,%eax,8)
80105edd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ee0:	0f b6 14 c5 45 62 19 	movzbl -0x7fe69dbb(,%eax,8),%edx
80105ee7:	80 
80105ee8:	83 e2 9f             	and    $0xffffff9f,%edx
80105eeb:	88 14 c5 45 62 19 80 	mov    %dl,-0x7fe69dbb(,%eax,8)
80105ef2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ef5:	0f b6 14 c5 45 62 19 	movzbl -0x7fe69dbb(,%eax,8),%edx
80105efc:	80 
80105efd:	83 ca 80             	or     $0xffffff80,%edx
80105f00:	88 14 c5 45 62 19 80 	mov    %dl,-0x7fe69dbb(,%eax,8)
80105f07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f0a:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
80105f11:	c1 e8 10             	shr    $0x10,%eax
80105f14:	89 c2                	mov    %eax,%edx
80105f16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f19:	66 89 14 c5 46 62 19 	mov    %dx,-0x7fe69dba(,%eax,8)
80105f20:	80 
  for(i = 0; i < 256; i++)
80105f21:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105f25:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80105f2c:	0f 8e 30 ff ff ff    	jle    80105e62 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105f32:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
80105f37:	66 a3 40 64 19 80    	mov    %ax,0x80196440
80105f3d:	66 c7 05 42 64 19 80 	movw   $0x8,0x80196442
80105f44:	08 00 
80105f46:	0f b6 05 44 64 19 80 	movzbl 0x80196444,%eax
80105f4d:	83 e0 e0             	and    $0xffffffe0,%eax
80105f50:	a2 44 64 19 80       	mov    %al,0x80196444
80105f55:	0f b6 05 44 64 19 80 	movzbl 0x80196444,%eax
80105f5c:	83 e0 1f             	and    $0x1f,%eax
80105f5f:	a2 44 64 19 80       	mov    %al,0x80196444
80105f64:	0f b6 05 45 64 19 80 	movzbl 0x80196445,%eax
80105f6b:	83 c8 0f             	or     $0xf,%eax
80105f6e:	a2 45 64 19 80       	mov    %al,0x80196445
80105f73:	0f b6 05 45 64 19 80 	movzbl 0x80196445,%eax
80105f7a:	83 e0 ef             	and    $0xffffffef,%eax
80105f7d:	a2 45 64 19 80       	mov    %al,0x80196445
80105f82:	0f b6 05 45 64 19 80 	movzbl 0x80196445,%eax
80105f89:	83 c8 60             	or     $0x60,%eax
80105f8c:	a2 45 64 19 80       	mov    %al,0x80196445
80105f91:	0f b6 05 45 64 19 80 	movzbl 0x80196445,%eax
80105f98:	83 c8 80             	or     $0xffffff80,%eax
80105f9b:	a2 45 64 19 80       	mov    %al,0x80196445
80105fa0:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
80105fa5:	c1 e8 10             	shr    $0x10,%eax
80105fa8:	66 a3 46 64 19 80    	mov    %ax,0x80196446

  initlock(&tickslock, "time");
80105fae:	83 ec 08             	sub    $0x8,%esp
80105fb1:	68 9c a5 10 80       	push   $0x8010a59c
80105fb6:	68 40 6a 19 80       	push   $0x80196a40
80105fbb:	e8 54 e8 ff ff       	call   80104814 <initlock>
80105fc0:	83 c4 10             	add    $0x10,%esp
}
80105fc3:	90                   	nop
80105fc4:	c9                   	leave  
80105fc5:	c3                   	ret    

80105fc6 <idtinit>:

void
idtinit(void)
{
80105fc6:	55                   	push   %ebp
80105fc7:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80105fc9:	68 00 08 00 00       	push   $0x800
80105fce:	68 40 62 19 80       	push   $0x80196240
80105fd3:	e8 3d fe ff ff       	call   80105e15 <lidt>
80105fd8:	83 c4 08             	add    $0x8,%esp
}
80105fdb:	90                   	nop
80105fdc:	c9                   	leave  
80105fdd:	c3                   	ret    

80105fde <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80105fde:	55                   	push   %ebp
80105fdf:	89 e5                	mov    %esp,%ebp
80105fe1:	57                   	push   %edi
80105fe2:	56                   	push   %esi
80105fe3:	53                   	push   %ebx
80105fe4:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
80105fe7:	8b 45 08             	mov    0x8(%ebp),%eax
80105fea:	8b 40 30             	mov    0x30(%eax),%eax
80105fed:	83 f8 40             	cmp    $0x40,%eax
80105ff0:	75 3b                	jne    8010602d <trap+0x4f>
    if(myproc()->killed)
80105ff2:	e8 34 da ff ff       	call   80103a2b <myproc>
80105ff7:	8b 40 24             	mov    0x24(%eax),%eax
80105ffa:	85 c0                	test   %eax,%eax
80105ffc:	74 05                	je     80106003 <trap+0x25>
      exit();
80105ffe:	e8 a0 de ff ff       	call   80103ea3 <exit>
    myproc()->tf = tf;
80106003:	e8 23 da ff ff       	call   80103a2b <myproc>
80106008:	8b 55 08             	mov    0x8(%ebp),%edx
8010600b:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
8010600e:	e8 2d ee ff ff       	call   80104e40 <syscall>
    if(myproc()->killed)
80106013:	e8 13 da ff ff       	call   80103a2b <myproc>
80106018:	8b 40 24             	mov    0x24(%eax),%eax
8010601b:	85 c0                	test   %eax,%eax
8010601d:	0f 84 a2 02 00 00    	je     801062c5 <trap+0x2e7>
      exit();
80106023:	e8 7b de ff ff       	call   80103ea3 <exit>
    return;
80106028:	e9 98 02 00 00       	jmp    801062c5 <trap+0x2e7>
  }

  switch(tf->trapno){
8010602d:	8b 45 08             	mov    0x8(%ebp),%eax
80106030:	8b 40 30             	mov    0x30(%eax),%eax
80106033:	83 e8 0e             	sub    $0xe,%eax
80106036:	83 f8 31             	cmp    $0x31,%eax
80106039:	0f 87 51 01 00 00    	ja     80106190 <trap+0x1b2>
8010603f:	8b 04 85 78 a6 10 80 	mov    -0x7fef5988(,%eax,4),%eax
80106046:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106048:	e8 4b d9 ff ff       	call   80103998 <cpuid>
8010604d:	85 c0                	test   %eax,%eax
8010604f:	75 3d                	jne    8010608e <trap+0xb0>
      acquire(&tickslock);
80106051:	83 ec 0c             	sub    $0xc,%esp
80106054:	68 40 6a 19 80       	push   $0x80196a40
80106059:	e8 d8 e7 ff ff       	call   80104836 <acquire>
8010605e:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106061:	a1 74 6a 19 80       	mov    0x80196a74,%eax
80106066:	83 c0 01             	add    $0x1,%eax
80106069:	a3 74 6a 19 80       	mov    %eax,0x80196a74
      wakeup(&ticks);
8010606e:	83 ec 0c             	sub    $0xc,%esp
80106071:	68 74 6a 19 80       	push   $0x80196a74
80106076:	e8 40 e3 ff ff       	call   801043bb <wakeup>
8010607b:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
8010607e:	83 ec 0c             	sub    $0xc,%esp
80106081:	68 40 6a 19 80       	push   $0x80196a40
80106086:	e8 19 e8 ff ff       	call   801048a4 <release>
8010608b:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
8010608e:	e8 84 ca ff ff       	call   80102b17 <lapiceoi>
    break;
80106093:	e9 ad 01 00 00       	jmp    80106245 <trap+0x267>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106098:	e8 6f 3f 00 00       	call   8010a00c <ideintr>
    lapiceoi();
8010609d:	e8 75 ca ff ff       	call   80102b17 <lapiceoi>
    break;
801060a2:	e9 9e 01 00 00       	jmp    80106245 <trap+0x267>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801060a7:	e8 b0 c8 ff ff       	call   8010295c <kbdintr>
    lapiceoi();
801060ac:	e8 66 ca ff ff       	call   80102b17 <lapiceoi>
    break;
801060b1:	e9 8f 01 00 00       	jmp    80106245 <trap+0x267>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801060b6:	e8 e0 03 00 00       	call   8010649b <uartintr>
    lapiceoi();
801060bb:	e8 57 ca ff ff       	call   80102b17 <lapiceoi>
    break;
801060c0:	e9 80 01 00 00       	jmp    80106245 <trap+0x267>
  case T_IRQ0 + 0xB:
    i8254_intr();
801060c5:	e8 f5 2b 00 00       	call   80108cbf <i8254_intr>
    lapiceoi();
801060ca:	e8 48 ca ff ff       	call   80102b17 <lapiceoi>
    break;
801060cf:	e9 71 01 00 00       	jmp    80106245 <trap+0x267>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801060d4:	8b 45 08             	mov    0x8(%ebp),%eax
801060d7:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
801060da:	8b 45 08             	mov    0x8(%ebp),%eax
801060dd:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801060e1:	0f b7 d8             	movzwl %ax,%ebx
801060e4:	e8 af d8 ff ff       	call   80103998 <cpuid>
801060e9:	56                   	push   %esi
801060ea:	53                   	push   %ebx
801060eb:	50                   	push   %eax
801060ec:	68 a4 a5 10 80       	push   $0x8010a5a4
801060f1:	e8 fe a2 ff ff       	call   801003f4 <cprintf>
801060f6:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
801060f9:	e8 19 ca ff ff       	call   80102b17 <lapiceoi>
    break;
801060fe:	e9 42 01 00 00       	jmp    80106245 <trap+0x267>

  case T_PGFLT:
    uint sz = KERNBASE - PGSIZE * (myproc()->stackcnt + 1);
80106103:	e8 23 d9 ff ff       	call   80103a2b <myproc>
80106108:	8b 50 7c             	mov    0x7c(%eax),%edx
8010610b:	b8 ff ff 07 00       	mov    $0x7ffff,%eax
80106110:	29 d0                	sub    %edx,%eax
80106112:	c1 e0 0c             	shl    $0xc,%eax
80106115:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    
    // fail stack allocation
    if ((sz = allocuvm(myproc()->pgdir, sz, sz + PGSIZE)) == 0) 
80106118:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010611b:	8d 98 00 10 00 00    	lea    0x1000(%eax),%ebx
80106121:	e8 05 d9 ff ff       	call   80103a2b <myproc>
80106126:	8b 40 04             	mov    0x4(%eax),%eax
80106129:	83 ec 04             	sub    $0x4,%esp
8010612c:	53                   	push   %ebx
8010612d:	ff 75 e4             	push   -0x1c(%ebp)
80106130:	50                   	push   %eax
80106131:	e8 b2 16 00 00       	call   801077e8 <allocuvm>
80106136:	83 c4 10             	add    $0x10,%esp
80106139:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010613c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80106140:	75 3b                	jne    8010617d <trap+0x19f>
      cprintf("faild stack allocation\n");
80106142:	83 ec 0c             	sub    $0xc,%esp
80106145:	68 c8 a5 10 80       	push   $0x8010a5c8
8010614a:	e8 a5 a2 ff ff       	call   801003f4 <cprintf>
8010614f:	83 c4 10             	add    $0x10,%esp
    else { 
      myproc()->stackcnt++;
      break;
    }
    
80106152:	8b 45 08             	mov    0x8(%ebp),%eax
80106155:	8b 70 44             	mov    0x44(%eax),%esi
80106158:	e8 ce d8 ff ff       	call   80103a2b <myproc>
8010615d:	8b 40 18             	mov    0x18(%eax),%eax
80106160:	8b 58 44             	mov    0x44(%eax),%ebx
80106163:	e8 c3 d8 ff ff       	call   80103a2b <myproc>
80106168:	8b 40 7c             	mov    0x7c(%eax),%eax
8010616b:	56                   	push   %esi
8010616c:	53                   	push   %ebx
8010616d:	50                   	push   %eax
8010616e:	68 df a5 10 80       	push   $0x8010a5df
80106173:	e8 7c a2 ff ff       	call   801003f4 <cprintf>
80106178:	83 c4 10             	add    $0x10,%esp
8010617b:	eb 13                	jmp    80106190 <trap+0x1b2>
      myproc()->stackcnt++;
8010617d:	e8 a9 d8 ff ff       	call   80103a2b <myproc>
80106182:	8b 50 7c             	mov    0x7c(%eax),%edx
80106185:	83 c2 01             	add    $0x1,%edx
80106188:	89 50 7c             	mov    %edx,0x7c(%eax)
      break;
8010618b:	e9 b5 00 00 00       	jmp    80106245 <trap+0x267>
  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
80106190:	e8 96 d8 ff ff       	call   80103a2b <myproc>
80106195:	85 c0                	test   %eax,%eax
80106197:	74 11                	je     801061aa <trap+0x1cc>
80106199:	8b 45 08             	mov    0x8(%ebp),%eax
8010619c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801061a0:	0f b7 c0             	movzwl %ax,%eax
801061a3:	83 e0 03             	and    $0x3,%eax
801061a6:	85 c0                	test   %eax,%eax
801061a8:	75 39                	jne    801061e3 <trap+0x205>
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
801061aa:	e8 90 fc ff ff       	call   80105e3f <rcr2>
801061af:	89 c3                	mov    %eax,%ebx
801061b1:	8b 45 08             	mov    0x8(%ebp),%eax
801061b4:	8b 70 38             	mov    0x38(%eax),%esi
801061b7:	e8 dc d7 ff ff       	call   80103998 <cpuid>
801061bc:	8b 55 08             	mov    0x8(%ebp),%edx
801061bf:	8b 52 30             	mov    0x30(%edx),%edx
801061c2:	83 ec 0c             	sub    $0xc,%esp
801061c5:	53                   	push   %ebx
801061c6:	56                   	push   %esi
801061c7:	50                   	push   %eax
801061c8:	52                   	push   %edx
801061c9:	68 fc a5 10 80       	push   $0x8010a5fc
801061ce:	e8 21 a2 ff ff       	call   801003f4 <cprintf>
801061d3:	83 c4 20             	add    $0x20,%esp
      panic("trap");
    }
801061d6:	83 ec 0c             	sub    $0xc,%esp
801061d9:	68 2e a6 10 80       	push   $0x8010a62e
801061de:	e8 c6 a3 ff ff       	call   801005a9 <panic>
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
            "eip 0x%x addr 0x%x--kill proc\n",
801061e3:	e8 57 fc ff ff       	call   80105e3f <rcr2>
801061e8:	89 c6                	mov    %eax,%esi
801061ea:	8b 45 08             	mov    0x8(%ebp),%eax
801061ed:	8b 40 38             	mov    0x38(%eax),%eax
801061f0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801061f3:	e8 a0 d7 ff ff       	call   80103998 <cpuid>
801061f8:	89 c3                	mov    %eax,%ebx
801061fa:	8b 45 08             	mov    0x8(%ebp),%eax
801061fd:	8b 48 34             	mov    0x34(%eax),%ecx
80106200:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106203:	8b 45 08             	mov    0x8(%ebp),%eax
80106206:	8b 78 30             	mov    0x30(%eax),%edi
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
80106209:	e8 1d d8 ff ff       	call   80103a2b <myproc>
8010620e:	8d 50 6c             	lea    0x6c(%eax),%edx
80106211:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106214:	e8 12 d8 ff ff       	call   80103a2b <myproc>
            "eip 0x%x addr 0x%x--kill proc\n",
80106219:	8b 40 10             	mov    0x10(%eax),%eax
8010621c:	56                   	push   %esi
8010621d:	ff 75 d4             	push   -0x2c(%ebp)
80106220:	53                   	push   %ebx
80106221:	ff 75 d0             	push   -0x30(%ebp)
80106224:	57                   	push   %edi
80106225:	ff 75 cc             	push   -0x34(%ebp)
80106228:	50                   	push   %eax
80106229:	68 34 a6 10 80       	push   $0x8010a634
8010622e:	e8 c1 a1 ff ff       	call   801003f4 <cprintf>
80106233:	83 c4 20             	add    $0x20,%esp
    myproc()->killed = 1;
  }
80106236:	e8 f0 d7 ff ff       	call   80103a2b <myproc>
8010623b:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106242:	eb 01                	jmp    80106245 <trap+0x267>
    break;
80106244:	90                   	nop

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();
80106245:	e8 e1 d7 ff ff       	call   80103a2b <myproc>
8010624a:	85 c0                	test   %eax,%eax
8010624c:	74 23                	je     80106271 <trap+0x293>
8010624e:	e8 d8 d7 ff ff       	call   80103a2b <myproc>
80106253:	8b 40 24             	mov    0x24(%eax),%eax
80106256:	85 c0                	test   %eax,%eax
80106258:	74 17                	je     80106271 <trap+0x293>
8010625a:	8b 45 08             	mov    0x8(%ebp),%eax
8010625d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106261:	0f b7 c0             	movzwl %ax,%eax
80106264:	83 e0 03             	and    $0x3,%eax
80106267:	83 f8 03             	cmp    $0x3,%eax
8010626a:	75 05                	jne    80106271 <trap+0x293>

8010626c:	e8 32 dc ff ff       	call   80103ea3 <exit>
  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106271:	e8 b5 d7 ff ff       	call   80103a2b <myproc>
80106276:	85 c0                	test   %eax,%eax
80106278:	74 1d                	je     80106297 <trap+0x2b9>
8010627a:	e8 ac d7 ff ff       	call   80103a2b <myproc>
8010627f:	8b 40 0c             	mov    0xc(%eax),%eax
80106282:	83 f8 04             	cmp    $0x4,%eax
80106285:	75 10                	jne    80106297 <trap+0x2b9>
    yield();
80106287:	8b 45 08             	mov    0x8(%ebp),%eax
8010628a:	8b 40 30             	mov    0x30(%eax),%eax
     tf->trapno == T_IRQ0+IRQ_TIMER)
8010628d:	83 f8 20             	cmp    $0x20,%eax
80106290:	75 05                	jne    80106297 <trap+0x2b9>

80106292:	e8 bd df ff ff       	call   80104254 <yield>
  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();
80106297:	e8 8f d7 ff ff       	call   80103a2b <myproc>
8010629c:	85 c0                	test   %eax,%eax
8010629e:	74 26                	je     801062c6 <trap+0x2e8>
801062a0:	e8 86 d7 ff ff       	call   80103a2b <myproc>
801062a5:	8b 40 24             	mov    0x24(%eax),%eax
801062a8:	85 c0                	test   %eax,%eax
801062aa:	74 1a                	je     801062c6 <trap+0x2e8>
801062ac:	8b 45 08             	mov    0x8(%ebp),%eax
801062af:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801062b3:	0f b7 c0             	movzwl %ax,%eax
801062b6:	83 e0 03             	and    $0x3,%eax
801062b9:	83 f8 03             	cmp    $0x3,%eax
801062bc:	75 08                	jne    801062c6 <trap+0x2e8>
}
801062be:	e8 e0 db ff ff       	call   80103ea3 <exit>
801062c3:	eb 01                	jmp    801062c6 <trap+0x2e8>
    return;
801062c5:	90                   	nop
801062c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801062c9:	5b                   	pop    %ebx
801062ca:	5e                   	pop    %esi
801062cb:	5f                   	pop    %edi
801062cc:	5d                   	pop    %ebp
801062cd:	c3                   	ret    

801062ce <inb>:
{
801062ce:	55                   	push   %ebp
801062cf:	89 e5                	mov    %esp,%ebp
801062d1:	83 ec 14             	sub    $0x14,%esp
801062d4:	8b 45 08             	mov    0x8(%ebp),%eax
801062d7:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801062db:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801062df:	89 c2                	mov    %eax,%edx
801062e1:	ec                   	in     (%dx),%al
801062e2:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801062e5:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801062e9:	c9                   	leave  
801062ea:	c3                   	ret    

801062eb <outb>:
{
801062eb:	55                   	push   %ebp
801062ec:	89 e5                	mov    %esp,%ebp
801062ee:	83 ec 08             	sub    $0x8,%esp
801062f1:	8b 45 08             	mov    0x8(%ebp),%eax
801062f4:	8b 55 0c             	mov    0xc(%ebp),%edx
801062f7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801062fb:	89 d0                	mov    %edx,%eax
801062fd:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106300:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106304:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106308:	ee                   	out    %al,(%dx)
}
80106309:	90                   	nop
8010630a:	c9                   	leave  
8010630b:	c3                   	ret    

8010630c <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
8010630c:	55                   	push   %ebp
8010630d:	89 e5                	mov    %esp,%ebp
8010630f:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106312:	6a 00                	push   $0x0
80106314:	68 fa 03 00 00       	push   $0x3fa
80106319:	e8 cd ff ff ff       	call   801062eb <outb>
8010631e:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106321:	68 80 00 00 00       	push   $0x80
80106326:	68 fb 03 00 00       	push   $0x3fb
8010632b:	e8 bb ff ff ff       	call   801062eb <outb>
80106330:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106333:	6a 0c                	push   $0xc
80106335:	68 f8 03 00 00       	push   $0x3f8
8010633a:	e8 ac ff ff ff       	call   801062eb <outb>
8010633f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106342:	6a 00                	push   $0x0
80106344:	68 f9 03 00 00       	push   $0x3f9
80106349:	e8 9d ff ff ff       	call   801062eb <outb>
8010634e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106351:	6a 03                	push   $0x3
80106353:	68 fb 03 00 00       	push   $0x3fb
80106358:	e8 8e ff ff ff       	call   801062eb <outb>
8010635d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106360:	6a 00                	push   $0x0
80106362:	68 fc 03 00 00       	push   $0x3fc
80106367:	e8 7f ff ff ff       	call   801062eb <outb>
8010636c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
8010636f:	6a 01                	push   $0x1
80106371:	68 f9 03 00 00       	push   $0x3f9
80106376:	e8 70 ff ff ff       	call   801062eb <outb>
8010637b:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
8010637e:	68 fd 03 00 00       	push   $0x3fd
80106383:	e8 46 ff ff ff       	call   801062ce <inb>
80106388:	83 c4 04             	add    $0x4,%esp
8010638b:	3c ff                	cmp    $0xff,%al
8010638d:	74 61                	je     801063f0 <uartinit+0xe4>
    return;
  uart = 1;
8010638f:	c7 05 78 6a 19 80 01 	movl   $0x1,0x80196a78
80106396:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106399:	68 fa 03 00 00       	push   $0x3fa
8010639e:	e8 2b ff ff ff       	call   801062ce <inb>
801063a3:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801063a6:	68 f8 03 00 00       	push   $0x3f8
801063ab:	e8 1e ff ff ff       	call   801062ce <inb>
801063b0:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
801063b3:	83 ec 08             	sub    $0x8,%esp
801063b6:	6a 00                	push   $0x0
801063b8:	6a 04                	push   $0x4
801063ba:	e8 6a c2 ff ff       	call   80102629 <ioapicenable>
801063bf:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801063c2:	c7 45 f4 40 a7 10 80 	movl   $0x8010a740,-0xc(%ebp)
801063c9:	eb 19                	jmp    801063e4 <uartinit+0xd8>
    uartputc(*p);
801063cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063ce:	0f b6 00             	movzbl (%eax),%eax
801063d1:	0f be c0             	movsbl %al,%eax
801063d4:	83 ec 0c             	sub    $0xc,%esp
801063d7:	50                   	push   %eax
801063d8:	e8 16 00 00 00       	call   801063f3 <uartputc>
801063dd:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
801063e0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801063e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063e7:	0f b6 00             	movzbl (%eax),%eax
801063ea:	84 c0                	test   %al,%al
801063ec:	75 dd                	jne    801063cb <uartinit+0xbf>
801063ee:	eb 01                	jmp    801063f1 <uartinit+0xe5>
    return;
801063f0:	90                   	nop
}
801063f1:	c9                   	leave  
801063f2:	c3                   	ret    

801063f3 <uartputc>:

void
uartputc(int c)
{
801063f3:	55                   	push   %ebp
801063f4:	89 e5                	mov    %esp,%ebp
801063f6:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801063f9:	a1 78 6a 19 80       	mov    0x80196a78,%eax
801063fe:	85 c0                	test   %eax,%eax
80106400:	74 53                	je     80106455 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106402:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106409:	eb 11                	jmp    8010641c <uartputc+0x29>
    microdelay(10);
8010640b:	83 ec 0c             	sub    $0xc,%esp
8010640e:	6a 0a                	push   $0xa
80106410:	e8 1d c7 ff ff       	call   80102b32 <microdelay>
80106415:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106418:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010641c:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106420:	7f 1a                	jg     8010643c <uartputc+0x49>
80106422:	83 ec 0c             	sub    $0xc,%esp
80106425:	68 fd 03 00 00       	push   $0x3fd
8010642a:	e8 9f fe ff ff       	call   801062ce <inb>
8010642f:	83 c4 10             	add    $0x10,%esp
80106432:	0f b6 c0             	movzbl %al,%eax
80106435:	83 e0 20             	and    $0x20,%eax
80106438:	85 c0                	test   %eax,%eax
8010643a:	74 cf                	je     8010640b <uartputc+0x18>
  outb(COM1+0, c);
8010643c:	8b 45 08             	mov    0x8(%ebp),%eax
8010643f:	0f b6 c0             	movzbl %al,%eax
80106442:	83 ec 08             	sub    $0x8,%esp
80106445:	50                   	push   %eax
80106446:	68 f8 03 00 00       	push   $0x3f8
8010644b:	e8 9b fe ff ff       	call   801062eb <outb>
80106450:	83 c4 10             	add    $0x10,%esp
80106453:	eb 01                	jmp    80106456 <uartputc+0x63>
    return;
80106455:	90                   	nop
}
80106456:	c9                   	leave  
80106457:	c3                   	ret    

80106458 <uartgetc>:

static int
uartgetc(void)
{
80106458:	55                   	push   %ebp
80106459:	89 e5                	mov    %esp,%ebp
  if(!uart)
8010645b:	a1 78 6a 19 80       	mov    0x80196a78,%eax
80106460:	85 c0                	test   %eax,%eax
80106462:	75 07                	jne    8010646b <uartgetc+0x13>
    return -1;
80106464:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106469:	eb 2e                	jmp    80106499 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
8010646b:	68 fd 03 00 00       	push   $0x3fd
80106470:	e8 59 fe ff ff       	call   801062ce <inb>
80106475:	83 c4 04             	add    $0x4,%esp
80106478:	0f b6 c0             	movzbl %al,%eax
8010647b:	83 e0 01             	and    $0x1,%eax
8010647e:	85 c0                	test   %eax,%eax
80106480:	75 07                	jne    80106489 <uartgetc+0x31>
    return -1;
80106482:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106487:	eb 10                	jmp    80106499 <uartgetc+0x41>
  return inb(COM1+0);
80106489:	68 f8 03 00 00       	push   $0x3f8
8010648e:	e8 3b fe ff ff       	call   801062ce <inb>
80106493:	83 c4 04             	add    $0x4,%esp
80106496:	0f b6 c0             	movzbl %al,%eax
}
80106499:	c9                   	leave  
8010649a:	c3                   	ret    

8010649b <uartintr>:

void
uartintr(void)
{
8010649b:	55                   	push   %ebp
8010649c:	89 e5                	mov    %esp,%ebp
8010649e:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
801064a1:	83 ec 0c             	sub    $0xc,%esp
801064a4:	68 58 64 10 80       	push   $0x80106458
801064a9:	e8 28 a3 ff ff       	call   801007d6 <consoleintr>
801064ae:	83 c4 10             	add    $0x10,%esp
}
801064b1:	90                   	nop
801064b2:	c9                   	leave  
801064b3:	c3                   	ret    

801064b4 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801064b4:	6a 00                	push   $0x0
  pushl $0
801064b6:	6a 00                	push   $0x0
  jmp alltraps
801064b8:	e9 35 f9 ff ff       	jmp    80105df2 <alltraps>

801064bd <vector1>:
.globl vector1
vector1:
  pushl $0
801064bd:	6a 00                	push   $0x0
  pushl $1
801064bf:	6a 01                	push   $0x1
  jmp alltraps
801064c1:	e9 2c f9 ff ff       	jmp    80105df2 <alltraps>

801064c6 <vector2>:
.globl vector2
vector2:
  pushl $0
801064c6:	6a 00                	push   $0x0
  pushl $2
801064c8:	6a 02                	push   $0x2
  jmp alltraps
801064ca:	e9 23 f9 ff ff       	jmp    80105df2 <alltraps>

801064cf <vector3>:
.globl vector3
vector3:
  pushl $0
801064cf:	6a 00                	push   $0x0
  pushl $3
801064d1:	6a 03                	push   $0x3
  jmp alltraps
801064d3:	e9 1a f9 ff ff       	jmp    80105df2 <alltraps>

801064d8 <vector4>:
.globl vector4
vector4:
  pushl $0
801064d8:	6a 00                	push   $0x0
  pushl $4
801064da:	6a 04                	push   $0x4
  jmp alltraps
801064dc:	e9 11 f9 ff ff       	jmp    80105df2 <alltraps>

801064e1 <vector5>:
.globl vector5
vector5:
  pushl $0
801064e1:	6a 00                	push   $0x0
  pushl $5
801064e3:	6a 05                	push   $0x5
  jmp alltraps
801064e5:	e9 08 f9 ff ff       	jmp    80105df2 <alltraps>

801064ea <vector6>:
.globl vector6
vector6:
  pushl $0
801064ea:	6a 00                	push   $0x0
  pushl $6
801064ec:	6a 06                	push   $0x6
  jmp alltraps
801064ee:	e9 ff f8 ff ff       	jmp    80105df2 <alltraps>

801064f3 <vector7>:
.globl vector7
vector7:
  pushl $0
801064f3:	6a 00                	push   $0x0
  pushl $7
801064f5:	6a 07                	push   $0x7
  jmp alltraps
801064f7:	e9 f6 f8 ff ff       	jmp    80105df2 <alltraps>

801064fc <vector8>:
.globl vector8
vector8:
  pushl $8
801064fc:	6a 08                	push   $0x8
  jmp alltraps
801064fe:	e9 ef f8 ff ff       	jmp    80105df2 <alltraps>

80106503 <vector9>:
.globl vector9
vector9:
  pushl $0
80106503:	6a 00                	push   $0x0
  pushl $9
80106505:	6a 09                	push   $0x9
  jmp alltraps
80106507:	e9 e6 f8 ff ff       	jmp    80105df2 <alltraps>

8010650c <vector10>:
.globl vector10
vector10:
  pushl $10
8010650c:	6a 0a                	push   $0xa
  jmp alltraps
8010650e:	e9 df f8 ff ff       	jmp    80105df2 <alltraps>

80106513 <vector11>:
.globl vector11
vector11:
  pushl $11
80106513:	6a 0b                	push   $0xb
  jmp alltraps
80106515:	e9 d8 f8 ff ff       	jmp    80105df2 <alltraps>

8010651a <vector12>:
.globl vector12
vector12:
  pushl $12
8010651a:	6a 0c                	push   $0xc
  jmp alltraps
8010651c:	e9 d1 f8 ff ff       	jmp    80105df2 <alltraps>

80106521 <vector13>:
.globl vector13
vector13:
  pushl $13
80106521:	6a 0d                	push   $0xd
  jmp alltraps
80106523:	e9 ca f8 ff ff       	jmp    80105df2 <alltraps>

80106528 <vector14>:
.globl vector14
vector14:
  pushl $14
80106528:	6a 0e                	push   $0xe
  jmp alltraps
8010652a:	e9 c3 f8 ff ff       	jmp    80105df2 <alltraps>

8010652f <vector15>:
.globl vector15
vector15:
  pushl $0
8010652f:	6a 00                	push   $0x0
  pushl $15
80106531:	6a 0f                	push   $0xf
  jmp alltraps
80106533:	e9 ba f8 ff ff       	jmp    80105df2 <alltraps>

80106538 <vector16>:
.globl vector16
vector16:
  pushl $0
80106538:	6a 00                	push   $0x0
  pushl $16
8010653a:	6a 10                	push   $0x10
  jmp alltraps
8010653c:	e9 b1 f8 ff ff       	jmp    80105df2 <alltraps>

80106541 <vector17>:
.globl vector17
vector17:
  pushl $17
80106541:	6a 11                	push   $0x11
  jmp alltraps
80106543:	e9 aa f8 ff ff       	jmp    80105df2 <alltraps>

80106548 <vector18>:
.globl vector18
vector18:
  pushl $0
80106548:	6a 00                	push   $0x0
  pushl $18
8010654a:	6a 12                	push   $0x12
  jmp alltraps
8010654c:	e9 a1 f8 ff ff       	jmp    80105df2 <alltraps>

80106551 <vector19>:
.globl vector19
vector19:
  pushl $0
80106551:	6a 00                	push   $0x0
  pushl $19
80106553:	6a 13                	push   $0x13
  jmp alltraps
80106555:	e9 98 f8 ff ff       	jmp    80105df2 <alltraps>

8010655a <vector20>:
.globl vector20
vector20:
  pushl $0
8010655a:	6a 00                	push   $0x0
  pushl $20
8010655c:	6a 14                	push   $0x14
  jmp alltraps
8010655e:	e9 8f f8 ff ff       	jmp    80105df2 <alltraps>

80106563 <vector21>:
.globl vector21
vector21:
  pushl $0
80106563:	6a 00                	push   $0x0
  pushl $21
80106565:	6a 15                	push   $0x15
  jmp alltraps
80106567:	e9 86 f8 ff ff       	jmp    80105df2 <alltraps>

8010656c <vector22>:
.globl vector22
vector22:
  pushl $0
8010656c:	6a 00                	push   $0x0
  pushl $22
8010656e:	6a 16                	push   $0x16
  jmp alltraps
80106570:	e9 7d f8 ff ff       	jmp    80105df2 <alltraps>

80106575 <vector23>:
.globl vector23
vector23:
  pushl $0
80106575:	6a 00                	push   $0x0
  pushl $23
80106577:	6a 17                	push   $0x17
  jmp alltraps
80106579:	e9 74 f8 ff ff       	jmp    80105df2 <alltraps>

8010657e <vector24>:
.globl vector24
vector24:
  pushl $0
8010657e:	6a 00                	push   $0x0
  pushl $24
80106580:	6a 18                	push   $0x18
  jmp alltraps
80106582:	e9 6b f8 ff ff       	jmp    80105df2 <alltraps>

80106587 <vector25>:
.globl vector25
vector25:
  pushl $0
80106587:	6a 00                	push   $0x0
  pushl $25
80106589:	6a 19                	push   $0x19
  jmp alltraps
8010658b:	e9 62 f8 ff ff       	jmp    80105df2 <alltraps>

80106590 <vector26>:
.globl vector26
vector26:
  pushl $0
80106590:	6a 00                	push   $0x0
  pushl $26
80106592:	6a 1a                	push   $0x1a
  jmp alltraps
80106594:	e9 59 f8 ff ff       	jmp    80105df2 <alltraps>

80106599 <vector27>:
.globl vector27
vector27:
  pushl $0
80106599:	6a 00                	push   $0x0
  pushl $27
8010659b:	6a 1b                	push   $0x1b
  jmp alltraps
8010659d:	e9 50 f8 ff ff       	jmp    80105df2 <alltraps>

801065a2 <vector28>:
.globl vector28
vector28:
  pushl $0
801065a2:	6a 00                	push   $0x0
  pushl $28
801065a4:	6a 1c                	push   $0x1c
  jmp alltraps
801065a6:	e9 47 f8 ff ff       	jmp    80105df2 <alltraps>

801065ab <vector29>:
.globl vector29
vector29:
  pushl $0
801065ab:	6a 00                	push   $0x0
  pushl $29
801065ad:	6a 1d                	push   $0x1d
  jmp alltraps
801065af:	e9 3e f8 ff ff       	jmp    80105df2 <alltraps>

801065b4 <vector30>:
.globl vector30
vector30:
  pushl $0
801065b4:	6a 00                	push   $0x0
  pushl $30
801065b6:	6a 1e                	push   $0x1e
  jmp alltraps
801065b8:	e9 35 f8 ff ff       	jmp    80105df2 <alltraps>

801065bd <vector31>:
.globl vector31
vector31:
  pushl $0
801065bd:	6a 00                	push   $0x0
  pushl $31
801065bf:	6a 1f                	push   $0x1f
  jmp alltraps
801065c1:	e9 2c f8 ff ff       	jmp    80105df2 <alltraps>

801065c6 <vector32>:
.globl vector32
vector32:
  pushl $0
801065c6:	6a 00                	push   $0x0
  pushl $32
801065c8:	6a 20                	push   $0x20
  jmp alltraps
801065ca:	e9 23 f8 ff ff       	jmp    80105df2 <alltraps>

801065cf <vector33>:
.globl vector33
vector33:
  pushl $0
801065cf:	6a 00                	push   $0x0
  pushl $33
801065d1:	6a 21                	push   $0x21
  jmp alltraps
801065d3:	e9 1a f8 ff ff       	jmp    80105df2 <alltraps>

801065d8 <vector34>:
.globl vector34
vector34:
  pushl $0
801065d8:	6a 00                	push   $0x0
  pushl $34
801065da:	6a 22                	push   $0x22
  jmp alltraps
801065dc:	e9 11 f8 ff ff       	jmp    80105df2 <alltraps>

801065e1 <vector35>:
.globl vector35
vector35:
  pushl $0
801065e1:	6a 00                	push   $0x0
  pushl $35
801065e3:	6a 23                	push   $0x23
  jmp alltraps
801065e5:	e9 08 f8 ff ff       	jmp    80105df2 <alltraps>

801065ea <vector36>:
.globl vector36
vector36:
  pushl $0
801065ea:	6a 00                	push   $0x0
  pushl $36
801065ec:	6a 24                	push   $0x24
  jmp alltraps
801065ee:	e9 ff f7 ff ff       	jmp    80105df2 <alltraps>

801065f3 <vector37>:
.globl vector37
vector37:
  pushl $0
801065f3:	6a 00                	push   $0x0
  pushl $37
801065f5:	6a 25                	push   $0x25
  jmp alltraps
801065f7:	e9 f6 f7 ff ff       	jmp    80105df2 <alltraps>

801065fc <vector38>:
.globl vector38
vector38:
  pushl $0
801065fc:	6a 00                	push   $0x0
  pushl $38
801065fe:	6a 26                	push   $0x26
  jmp alltraps
80106600:	e9 ed f7 ff ff       	jmp    80105df2 <alltraps>

80106605 <vector39>:
.globl vector39
vector39:
  pushl $0
80106605:	6a 00                	push   $0x0
  pushl $39
80106607:	6a 27                	push   $0x27
  jmp alltraps
80106609:	e9 e4 f7 ff ff       	jmp    80105df2 <alltraps>

8010660e <vector40>:
.globl vector40
vector40:
  pushl $0
8010660e:	6a 00                	push   $0x0
  pushl $40
80106610:	6a 28                	push   $0x28
  jmp alltraps
80106612:	e9 db f7 ff ff       	jmp    80105df2 <alltraps>

80106617 <vector41>:
.globl vector41
vector41:
  pushl $0
80106617:	6a 00                	push   $0x0
  pushl $41
80106619:	6a 29                	push   $0x29
  jmp alltraps
8010661b:	e9 d2 f7 ff ff       	jmp    80105df2 <alltraps>

80106620 <vector42>:
.globl vector42
vector42:
  pushl $0
80106620:	6a 00                	push   $0x0
  pushl $42
80106622:	6a 2a                	push   $0x2a
  jmp alltraps
80106624:	e9 c9 f7 ff ff       	jmp    80105df2 <alltraps>

80106629 <vector43>:
.globl vector43
vector43:
  pushl $0
80106629:	6a 00                	push   $0x0
  pushl $43
8010662b:	6a 2b                	push   $0x2b
  jmp alltraps
8010662d:	e9 c0 f7 ff ff       	jmp    80105df2 <alltraps>

80106632 <vector44>:
.globl vector44
vector44:
  pushl $0
80106632:	6a 00                	push   $0x0
  pushl $44
80106634:	6a 2c                	push   $0x2c
  jmp alltraps
80106636:	e9 b7 f7 ff ff       	jmp    80105df2 <alltraps>

8010663b <vector45>:
.globl vector45
vector45:
  pushl $0
8010663b:	6a 00                	push   $0x0
  pushl $45
8010663d:	6a 2d                	push   $0x2d
  jmp alltraps
8010663f:	e9 ae f7 ff ff       	jmp    80105df2 <alltraps>

80106644 <vector46>:
.globl vector46
vector46:
  pushl $0
80106644:	6a 00                	push   $0x0
  pushl $46
80106646:	6a 2e                	push   $0x2e
  jmp alltraps
80106648:	e9 a5 f7 ff ff       	jmp    80105df2 <alltraps>

8010664d <vector47>:
.globl vector47
vector47:
  pushl $0
8010664d:	6a 00                	push   $0x0
  pushl $47
8010664f:	6a 2f                	push   $0x2f
  jmp alltraps
80106651:	e9 9c f7 ff ff       	jmp    80105df2 <alltraps>

80106656 <vector48>:
.globl vector48
vector48:
  pushl $0
80106656:	6a 00                	push   $0x0
  pushl $48
80106658:	6a 30                	push   $0x30
  jmp alltraps
8010665a:	e9 93 f7 ff ff       	jmp    80105df2 <alltraps>

8010665f <vector49>:
.globl vector49
vector49:
  pushl $0
8010665f:	6a 00                	push   $0x0
  pushl $49
80106661:	6a 31                	push   $0x31
  jmp alltraps
80106663:	e9 8a f7 ff ff       	jmp    80105df2 <alltraps>

80106668 <vector50>:
.globl vector50
vector50:
  pushl $0
80106668:	6a 00                	push   $0x0
  pushl $50
8010666a:	6a 32                	push   $0x32
  jmp alltraps
8010666c:	e9 81 f7 ff ff       	jmp    80105df2 <alltraps>

80106671 <vector51>:
.globl vector51
vector51:
  pushl $0
80106671:	6a 00                	push   $0x0
  pushl $51
80106673:	6a 33                	push   $0x33
  jmp alltraps
80106675:	e9 78 f7 ff ff       	jmp    80105df2 <alltraps>

8010667a <vector52>:
.globl vector52
vector52:
  pushl $0
8010667a:	6a 00                	push   $0x0
  pushl $52
8010667c:	6a 34                	push   $0x34
  jmp alltraps
8010667e:	e9 6f f7 ff ff       	jmp    80105df2 <alltraps>

80106683 <vector53>:
.globl vector53
vector53:
  pushl $0
80106683:	6a 00                	push   $0x0
  pushl $53
80106685:	6a 35                	push   $0x35
  jmp alltraps
80106687:	e9 66 f7 ff ff       	jmp    80105df2 <alltraps>

8010668c <vector54>:
.globl vector54
vector54:
  pushl $0
8010668c:	6a 00                	push   $0x0
  pushl $54
8010668e:	6a 36                	push   $0x36
  jmp alltraps
80106690:	e9 5d f7 ff ff       	jmp    80105df2 <alltraps>

80106695 <vector55>:
.globl vector55
vector55:
  pushl $0
80106695:	6a 00                	push   $0x0
  pushl $55
80106697:	6a 37                	push   $0x37
  jmp alltraps
80106699:	e9 54 f7 ff ff       	jmp    80105df2 <alltraps>

8010669e <vector56>:
.globl vector56
vector56:
  pushl $0
8010669e:	6a 00                	push   $0x0
  pushl $56
801066a0:	6a 38                	push   $0x38
  jmp alltraps
801066a2:	e9 4b f7 ff ff       	jmp    80105df2 <alltraps>

801066a7 <vector57>:
.globl vector57
vector57:
  pushl $0
801066a7:	6a 00                	push   $0x0
  pushl $57
801066a9:	6a 39                	push   $0x39
  jmp alltraps
801066ab:	e9 42 f7 ff ff       	jmp    80105df2 <alltraps>

801066b0 <vector58>:
.globl vector58
vector58:
  pushl $0
801066b0:	6a 00                	push   $0x0
  pushl $58
801066b2:	6a 3a                	push   $0x3a
  jmp alltraps
801066b4:	e9 39 f7 ff ff       	jmp    80105df2 <alltraps>

801066b9 <vector59>:
.globl vector59
vector59:
  pushl $0
801066b9:	6a 00                	push   $0x0
  pushl $59
801066bb:	6a 3b                	push   $0x3b
  jmp alltraps
801066bd:	e9 30 f7 ff ff       	jmp    80105df2 <alltraps>

801066c2 <vector60>:
.globl vector60
vector60:
  pushl $0
801066c2:	6a 00                	push   $0x0
  pushl $60
801066c4:	6a 3c                	push   $0x3c
  jmp alltraps
801066c6:	e9 27 f7 ff ff       	jmp    80105df2 <alltraps>

801066cb <vector61>:
.globl vector61
vector61:
  pushl $0
801066cb:	6a 00                	push   $0x0
  pushl $61
801066cd:	6a 3d                	push   $0x3d
  jmp alltraps
801066cf:	e9 1e f7 ff ff       	jmp    80105df2 <alltraps>

801066d4 <vector62>:
.globl vector62
vector62:
  pushl $0
801066d4:	6a 00                	push   $0x0
  pushl $62
801066d6:	6a 3e                	push   $0x3e
  jmp alltraps
801066d8:	e9 15 f7 ff ff       	jmp    80105df2 <alltraps>

801066dd <vector63>:
.globl vector63
vector63:
  pushl $0
801066dd:	6a 00                	push   $0x0
  pushl $63
801066df:	6a 3f                	push   $0x3f
  jmp alltraps
801066e1:	e9 0c f7 ff ff       	jmp    80105df2 <alltraps>

801066e6 <vector64>:
.globl vector64
vector64:
  pushl $0
801066e6:	6a 00                	push   $0x0
  pushl $64
801066e8:	6a 40                	push   $0x40
  jmp alltraps
801066ea:	e9 03 f7 ff ff       	jmp    80105df2 <alltraps>

801066ef <vector65>:
.globl vector65
vector65:
  pushl $0
801066ef:	6a 00                	push   $0x0
  pushl $65
801066f1:	6a 41                	push   $0x41
  jmp alltraps
801066f3:	e9 fa f6 ff ff       	jmp    80105df2 <alltraps>

801066f8 <vector66>:
.globl vector66
vector66:
  pushl $0
801066f8:	6a 00                	push   $0x0
  pushl $66
801066fa:	6a 42                	push   $0x42
  jmp alltraps
801066fc:	e9 f1 f6 ff ff       	jmp    80105df2 <alltraps>

80106701 <vector67>:
.globl vector67
vector67:
  pushl $0
80106701:	6a 00                	push   $0x0
  pushl $67
80106703:	6a 43                	push   $0x43
  jmp alltraps
80106705:	e9 e8 f6 ff ff       	jmp    80105df2 <alltraps>

8010670a <vector68>:
.globl vector68
vector68:
  pushl $0
8010670a:	6a 00                	push   $0x0
  pushl $68
8010670c:	6a 44                	push   $0x44
  jmp alltraps
8010670e:	e9 df f6 ff ff       	jmp    80105df2 <alltraps>

80106713 <vector69>:
.globl vector69
vector69:
  pushl $0
80106713:	6a 00                	push   $0x0
  pushl $69
80106715:	6a 45                	push   $0x45
  jmp alltraps
80106717:	e9 d6 f6 ff ff       	jmp    80105df2 <alltraps>

8010671c <vector70>:
.globl vector70
vector70:
  pushl $0
8010671c:	6a 00                	push   $0x0
  pushl $70
8010671e:	6a 46                	push   $0x46
  jmp alltraps
80106720:	e9 cd f6 ff ff       	jmp    80105df2 <alltraps>

80106725 <vector71>:
.globl vector71
vector71:
  pushl $0
80106725:	6a 00                	push   $0x0
  pushl $71
80106727:	6a 47                	push   $0x47
  jmp alltraps
80106729:	e9 c4 f6 ff ff       	jmp    80105df2 <alltraps>

8010672e <vector72>:
.globl vector72
vector72:
  pushl $0
8010672e:	6a 00                	push   $0x0
  pushl $72
80106730:	6a 48                	push   $0x48
  jmp alltraps
80106732:	e9 bb f6 ff ff       	jmp    80105df2 <alltraps>

80106737 <vector73>:
.globl vector73
vector73:
  pushl $0
80106737:	6a 00                	push   $0x0
  pushl $73
80106739:	6a 49                	push   $0x49
  jmp alltraps
8010673b:	e9 b2 f6 ff ff       	jmp    80105df2 <alltraps>

80106740 <vector74>:
.globl vector74
vector74:
  pushl $0
80106740:	6a 00                	push   $0x0
  pushl $74
80106742:	6a 4a                	push   $0x4a
  jmp alltraps
80106744:	e9 a9 f6 ff ff       	jmp    80105df2 <alltraps>

80106749 <vector75>:
.globl vector75
vector75:
  pushl $0
80106749:	6a 00                	push   $0x0
  pushl $75
8010674b:	6a 4b                	push   $0x4b
  jmp alltraps
8010674d:	e9 a0 f6 ff ff       	jmp    80105df2 <alltraps>

80106752 <vector76>:
.globl vector76
vector76:
  pushl $0
80106752:	6a 00                	push   $0x0
  pushl $76
80106754:	6a 4c                	push   $0x4c
  jmp alltraps
80106756:	e9 97 f6 ff ff       	jmp    80105df2 <alltraps>

8010675b <vector77>:
.globl vector77
vector77:
  pushl $0
8010675b:	6a 00                	push   $0x0
  pushl $77
8010675d:	6a 4d                	push   $0x4d
  jmp alltraps
8010675f:	e9 8e f6 ff ff       	jmp    80105df2 <alltraps>

80106764 <vector78>:
.globl vector78
vector78:
  pushl $0
80106764:	6a 00                	push   $0x0
  pushl $78
80106766:	6a 4e                	push   $0x4e
  jmp alltraps
80106768:	e9 85 f6 ff ff       	jmp    80105df2 <alltraps>

8010676d <vector79>:
.globl vector79
vector79:
  pushl $0
8010676d:	6a 00                	push   $0x0
  pushl $79
8010676f:	6a 4f                	push   $0x4f
  jmp alltraps
80106771:	e9 7c f6 ff ff       	jmp    80105df2 <alltraps>

80106776 <vector80>:
.globl vector80
vector80:
  pushl $0
80106776:	6a 00                	push   $0x0
  pushl $80
80106778:	6a 50                	push   $0x50
  jmp alltraps
8010677a:	e9 73 f6 ff ff       	jmp    80105df2 <alltraps>

8010677f <vector81>:
.globl vector81
vector81:
  pushl $0
8010677f:	6a 00                	push   $0x0
  pushl $81
80106781:	6a 51                	push   $0x51
  jmp alltraps
80106783:	e9 6a f6 ff ff       	jmp    80105df2 <alltraps>

80106788 <vector82>:
.globl vector82
vector82:
  pushl $0
80106788:	6a 00                	push   $0x0
  pushl $82
8010678a:	6a 52                	push   $0x52
  jmp alltraps
8010678c:	e9 61 f6 ff ff       	jmp    80105df2 <alltraps>

80106791 <vector83>:
.globl vector83
vector83:
  pushl $0
80106791:	6a 00                	push   $0x0
  pushl $83
80106793:	6a 53                	push   $0x53
  jmp alltraps
80106795:	e9 58 f6 ff ff       	jmp    80105df2 <alltraps>

8010679a <vector84>:
.globl vector84
vector84:
  pushl $0
8010679a:	6a 00                	push   $0x0
  pushl $84
8010679c:	6a 54                	push   $0x54
  jmp alltraps
8010679e:	e9 4f f6 ff ff       	jmp    80105df2 <alltraps>

801067a3 <vector85>:
.globl vector85
vector85:
  pushl $0
801067a3:	6a 00                	push   $0x0
  pushl $85
801067a5:	6a 55                	push   $0x55
  jmp alltraps
801067a7:	e9 46 f6 ff ff       	jmp    80105df2 <alltraps>

801067ac <vector86>:
.globl vector86
vector86:
  pushl $0
801067ac:	6a 00                	push   $0x0
  pushl $86
801067ae:	6a 56                	push   $0x56
  jmp alltraps
801067b0:	e9 3d f6 ff ff       	jmp    80105df2 <alltraps>

801067b5 <vector87>:
.globl vector87
vector87:
  pushl $0
801067b5:	6a 00                	push   $0x0
  pushl $87
801067b7:	6a 57                	push   $0x57
  jmp alltraps
801067b9:	e9 34 f6 ff ff       	jmp    80105df2 <alltraps>

801067be <vector88>:
.globl vector88
vector88:
  pushl $0
801067be:	6a 00                	push   $0x0
  pushl $88
801067c0:	6a 58                	push   $0x58
  jmp alltraps
801067c2:	e9 2b f6 ff ff       	jmp    80105df2 <alltraps>

801067c7 <vector89>:
.globl vector89
vector89:
  pushl $0
801067c7:	6a 00                	push   $0x0
  pushl $89
801067c9:	6a 59                	push   $0x59
  jmp alltraps
801067cb:	e9 22 f6 ff ff       	jmp    80105df2 <alltraps>

801067d0 <vector90>:
.globl vector90
vector90:
  pushl $0
801067d0:	6a 00                	push   $0x0
  pushl $90
801067d2:	6a 5a                	push   $0x5a
  jmp alltraps
801067d4:	e9 19 f6 ff ff       	jmp    80105df2 <alltraps>

801067d9 <vector91>:
.globl vector91
vector91:
  pushl $0
801067d9:	6a 00                	push   $0x0
  pushl $91
801067db:	6a 5b                	push   $0x5b
  jmp alltraps
801067dd:	e9 10 f6 ff ff       	jmp    80105df2 <alltraps>

801067e2 <vector92>:
.globl vector92
vector92:
  pushl $0
801067e2:	6a 00                	push   $0x0
  pushl $92
801067e4:	6a 5c                	push   $0x5c
  jmp alltraps
801067e6:	e9 07 f6 ff ff       	jmp    80105df2 <alltraps>

801067eb <vector93>:
.globl vector93
vector93:
  pushl $0
801067eb:	6a 00                	push   $0x0
  pushl $93
801067ed:	6a 5d                	push   $0x5d
  jmp alltraps
801067ef:	e9 fe f5 ff ff       	jmp    80105df2 <alltraps>

801067f4 <vector94>:
.globl vector94
vector94:
  pushl $0
801067f4:	6a 00                	push   $0x0
  pushl $94
801067f6:	6a 5e                	push   $0x5e
  jmp alltraps
801067f8:	e9 f5 f5 ff ff       	jmp    80105df2 <alltraps>

801067fd <vector95>:
.globl vector95
vector95:
  pushl $0
801067fd:	6a 00                	push   $0x0
  pushl $95
801067ff:	6a 5f                	push   $0x5f
  jmp alltraps
80106801:	e9 ec f5 ff ff       	jmp    80105df2 <alltraps>

80106806 <vector96>:
.globl vector96
vector96:
  pushl $0
80106806:	6a 00                	push   $0x0
  pushl $96
80106808:	6a 60                	push   $0x60
  jmp alltraps
8010680a:	e9 e3 f5 ff ff       	jmp    80105df2 <alltraps>

8010680f <vector97>:
.globl vector97
vector97:
  pushl $0
8010680f:	6a 00                	push   $0x0
  pushl $97
80106811:	6a 61                	push   $0x61
  jmp alltraps
80106813:	e9 da f5 ff ff       	jmp    80105df2 <alltraps>

80106818 <vector98>:
.globl vector98
vector98:
  pushl $0
80106818:	6a 00                	push   $0x0
  pushl $98
8010681a:	6a 62                	push   $0x62
  jmp alltraps
8010681c:	e9 d1 f5 ff ff       	jmp    80105df2 <alltraps>

80106821 <vector99>:
.globl vector99
vector99:
  pushl $0
80106821:	6a 00                	push   $0x0
  pushl $99
80106823:	6a 63                	push   $0x63
  jmp alltraps
80106825:	e9 c8 f5 ff ff       	jmp    80105df2 <alltraps>

8010682a <vector100>:
.globl vector100
vector100:
  pushl $0
8010682a:	6a 00                	push   $0x0
  pushl $100
8010682c:	6a 64                	push   $0x64
  jmp alltraps
8010682e:	e9 bf f5 ff ff       	jmp    80105df2 <alltraps>

80106833 <vector101>:
.globl vector101
vector101:
  pushl $0
80106833:	6a 00                	push   $0x0
  pushl $101
80106835:	6a 65                	push   $0x65
  jmp alltraps
80106837:	e9 b6 f5 ff ff       	jmp    80105df2 <alltraps>

8010683c <vector102>:
.globl vector102
vector102:
  pushl $0
8010683c:	6a 00                	push   $0x0
  pushl $102
8010683e:	6a 66                	push   $0x66
  jmp alltraps
80106840:	e9 ad f5 ff ff       	jmp    80105df2 <alltraps>

80106845 <vector103>:
.globl vector103
vector103:
  pushl $0
80106845:	6a 00                	push   $0x0
  pushl $103
80106847:	6a 67                	push   $0x67
  jmp alltraps
80106849:	e9 a4 f5 ff ff       	jmp    80105df2 <alltraps>

8010684e <vector104>:
.globl vector104
vector104:
  pushl $0
8010684e:	6a 00                	push   $0x0
  pushl $104
80106850:	6a 68                	push   $0x68
  jmp alltraps
80106852:	e9 9b f5 ff ff       	jmp    80105df2 <alltraps>

80106857 <vector105>:
.globl vector105
vector105:
  pushl $0
80106857:	6a 00                	push   $0x0
  pushl $105
80106859:	6a 69                	push   $0x69
  jmp alltraps
8010685b:	e9 92 f5 ff ff       	jmp    80105df2 <alltraps>

80106860 <vector106>:
.globl vector106
vector106:
  pushl $0
80106860:	6a 00                	push   $0x0
  pushl $106
80106862:	6a 6a                	push   $0x6a
  jmp alltraps
80106864:	e9 89 f5 ff ff       	jmp    80105df2 <alltraps>

80106869 <vector107>:
.globl vector107
vector107:
  pushl $0
80106869:	6a 00                	push   $0x0
  pushl $107
8010686b:	6a 6b                	push   $0x6b
  jmp alltraps
8010686d:	e9 80 f5 ff ff       	jmp    80105df2 <alltraps>

80106872 <vector108>:
.globl vector108
vector108:
  pushl $0
80106872:	6a 00                	push   $0x0
  pushl $108
80106874:	6a 6c                	push   $0x6c
  jmp alltraps
80106876:	e9 77 f5 ff ff       	jmp    80105df2 <alltraps>

8010687b <vector109>:
.globl vector109
vector109:
  pushl $0
8010687b:	6a 00                	push   $0x0
  pushl $109
8010687d:	6a 6d                	push   $0x6d
  jmp alltraps
8010687f:	e9 6e f5 ff ff       	jmp    80105df2 <alltraps>

80106884 <vector110>:
.globl vector110
vector110:
  pushl $0
80106884:	6a 00                	push   $0x0
  pushl $110
80106886:	6a 6e                	push   $0x6e
  jmp alltraps
80106888:	e9 65 f5 ff ff       	jmp    80105df2 <alltraps>

8010688d <vector111>:
.globl vector111
vector111:
  pushl $0
8010688d:	6a 00                	push   $0x0
  pushl $111
8010688f:	6a 6f                	push   $0x6f
  jmp alltraps
80106891:	e9 5c f5 ff ff       	jmp    80105df2 <alltraps>

80106896 <vector112>:
.globl vector112
vector112:
  pushl $0
80106896:	6a 00                	push   $0x0
  pushl $112
80106898:	6a 70                	push   $0x70
  jmp alltraps
8010689a:	e9 53 f5 ff ff       	jmp    80105df2 <alltraps>

8010689f <vector113>:
.globl vector113
vector113:
  pushl $0
8010689f:	6a 00                	push   $0x0
  pushl $113
801068a1:	6a 71                	push   $0x71
  jmp alltraps
801068a3:	e9 4a f5 ff ff       	jmp    80105df2 <alltraps>

801068a8 <vector114>:
.globl vector114
vector114:
  pushl $0
801068a8:	6a 00                	push   $0x0
  pushl $114
801068aa:	6a 72                	push   $0x72
  jmp alltraps
801068ac:	e9 41 f5 ff ff       	jmp    80105df2 <alltraps>

801068b1 <vector115>:
.globl vector115
vector115:
  pushl $0
801068b1:	6a 00                	push   $0x0
  pushl $115
801068b3:	6a 73                	push   $0x73
  jmp alltraps
801068b5:	e9 38 f5 ff ff       	jmp    80105df2 <alltraps>

801068ba <vector116>:
.globl vector116
vector116:
  pushl $0
801068ba:	6a 00                	push   $0x0
  pushl $116
801068bc:	6a 74                	push   $0x74
  jmp alltraps
801068be:	e9 2f f5 ff ff       	jmp    80105df2 <alltraps>

801068c3 <vector117>:
.globl vector117
vector117:
  pushl $0
801068c3:	6a 00                	push   $0x0
  pushl $117
801068c5:	6a 75                	push   $0x75
  jmp alltraps
801068c7:	e9 26 f5 ff ff       	jmp    80105df2 <alltraps>

801068cc <vector118>:
.globl vector118
vector118:
  pushl $0
801068cc:	6a 00                	push   $0x0
  pushl $118
801068ce:	6a 76                	push   $0x76
  jmp alltraps
801068d0:	e9 1d f5 ff ff       	jmp    80105df2 <alltraps>

801068d5 <vector119>:
.globl vector119
vector119:
  pushl $0
801068d5:	6a 00                	push   $0x0
  pushl $119
801068d7:	6a 77                	push   $0x77
  jmp alltraps
801068d9:	e9 14 f5 ff ff       	jmp    80105df2 <alltraps>

801068de <vector120>:
.globl vector120
vector120:
  pushl $0
801068de:	6a 00                	push   $0x0
  pushl $120
801068e0:	6a 78                	push   $0x78
  jmp alltraps
801068e2:	e9 0b f5 ff ff       	jmp    80105df2 <alltraps>

801068e7 <vector121>:
.globl vector121
vector121:
  pushl $0
801068e7:	6a 00                	push   $0x0
  pushl $121
801068e9:	6a 79                	push   $0x79
  jmp alltraps
801068eb:	e9 02 f5 ff ff       	jmp    80105df2 <alltraps>

801068f0 <vector122>:
.globl vector122
vector122:
  pushl $0
801068f0:	6a 00                	push   $0x0
  pushl $122
801068f2:	6a 7a                	push   $0x7a
  jmp alltraps
801068f4:	e9 f9 f4 ff ff       	jmp    80105df2 <alltraps>

801068f9 <vector123>:
.globl vector123
vector123:
  pushl $0
801068f9:	6a 00                	push   $0x0
  pushl $123
801068fb:	6a 7b                	push   $0x7b
  jmp alltraps
801068fd:	e9 f0 f4 ff ff       	jmp    80105df2 <alltraps>

80106902 <vector124>:
.globl vector124
vector124:
  pushl $0
80106902:	6a 00                	push   $0x0
  pushl $124
80106904:	6a 7c                	push   $0x7c
  jmp alltraps
80106906:	e9 e7 f4 ff ff       	jmp    80105df2 <alltraps>

8010690b <vector125>:
.globl vector125
vector125:
  pushl $0
8010690b:	6a 00                	push   $0x0
  pushl $125
8010690d:	6a 7d                	push   $0x7d
  jmp alltraps
8010690f:	e9 de f4 ff ff       	jmp    80105df2 <alltraps>

80106914 <vector126>:
.globl vector126
vector126:
  pushl $0
80106914:	6a 00                	push   $0x0
  pushl $126
80106916:	6a 7e                	push   $0x7e
  jmp alltraps
80106918:	e9 d5 f4 ff ff       	jmp    80105df2 <alltraps>

8010691d <vector127>:
.globl vector127
vector127:
  pushl $0
8010691d:	6a 00                	push   $0x0
  pushl $127
8010691f:	6a 7f                	push   $0x7f
  jmp alltraps
80106921:	e9 cc f4 ff ff       	jmp    80105df2 <alltraps>

80106926 <vector128>:
.globl vector128
vector128:
  pushl $0
80106926:	6a 00                	push   $0x0
  pushl $128
80106928:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010692d:	e9 c0 f4 ff ff       	jmp    80105df2 <alltraps>

80106932 <vector129>:
.globl vector129
vector129:
  pushl $0
80106932:	6a 00                	push   $0x0
  pushl $129
80106934:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106939:	e9 b4 f4 ff ff       	jmp    80105df2 <alltraps>

8010693e <vector130>:
.globl vector130
vector130:
  pushl $0
8010693e:	6a 00                	push   $0x0
  pushl $130
80106940:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106945:	e9 a8 f4 ff ff       	jmp    80105df2 <alltraps>

8010694a <vector131>:
.globl vector131
vector131:
  pushl $0
8010694a:	6a 00                	push   $0x0
  pushl $131
8010694c:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106951:	e9 9c f4 ff ff       	jmp    80105df2 <alltraps>

80106956 <vector132>:
.globl vector132
vector132:
  pushl $0
80106956:	6a 00                	push   $0x0
  pushl $132
80106958:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010695d:	e9 90 f4 ff ff       	jmp    80105df2 <alltraps>

80106962 <vector133>:
.globl vector133
vector133:
  pushl $0
80106962:	6a 00                	push   $0x0
  pushl $133
80106964:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106969:	e9 84 f4 ff ff       	jmp    80105df2 <alltraps>

8010696e <vector134>:
.globl vector134
vector134:
  pushl $0
8010696e:	6a 00                	push   $0x0
  pushl $134
80106970:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106975:	e9 78 f4 ff ff       	jmp    80105df2 <alltraps>

8010697a <vector135>:
.globl vector135
vector135:
  pushl $0
8010697a:	6a 00                	push   $0x0
  pushl $135
8010697c:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106981:	e9 6c f4 ff ff       	jmp    80105df2 <alltraps>

80106986 <vector136>:
.globl vector136
vector136:
  pushl $0
80106986:	6a 00                	push   $0x0
  pushl $136
80106988:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010698d:	e9 60 f4 ff ff       	jmp    80105df2 <alltraps>

80106992 <vector137>:
.globl vector137
vector137:
  pushl $0
80106992:	6a 00                	push   $0x0
  pushl $137
80106994:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106999:	e9 54 f4 ff ff       	jmp    80105df2 <alltraps>

8010699e <vector138>:
.globl vector138
vector138:
  pushl $0
8010699e:	6a 00                	push   $0x0
  pushl $138
801069a0:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801069a5:	e9 48 f4 ff ff       	jmp    80105df2 <alltraps>

801069aa <vector139>:
.globl vector139
vector139:
  pushl $0
801069aa:	6a 00                	push   $0x0
  pushl $139
801069ac:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801069b1:	e9 3c f4 ff ff       	jmp    80105df2 <alltraps>

801069b6 <vector140>:
.globl vector140
vector140:
  pushl $0
801069b6:	6a 00                	push   $0x0
  pushl $140
801069b8:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801069bd:	e9 30 f4 ff ff       	jmp    80105df2 <alltraps>

801069c2 <vector141>:
.globl vector141
vector141:
  pushl $0
801069c2:	6a 00                	push   $0x0
  pushl $141
801069c4:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801069c9:	e9 24 f4 ff ff       	jmp    80105df2 <alltraps>

801069ce <vector142>:
.globl vector142
vector142:
  pushl $0
801069ce:	6a 00                	push   $0x0
  pushl $142
801069d0:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801069d5:	e9 18 f4 ff ff       	jmp    80105df2 <alltraps>

801069da <vector143>:
.globl vector143
vector143:
  pushl $0
801069da:	6a 00                	push   $0x0
  pushl $143
801069dc:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801069e1:	e9 0c f4 ff ff       	jmp    80105df2 <alltraps>

801069e6 <vector144>:
.globl vector144
vector144:
  pushl $0
801069e6:	6a 00                	push   $0x0
  pushl $144
801069e8:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801069ed:	e9 00 f4 ff ff       	jmp    80105df2 <alltraps>

801069f2 <vector145>:
.globl vector145
vector145:
  pushl $0
801069f2:	6a 00                	push   $0x0
  pushl $145
801069f4:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801069f9:	e9 f4 f3 ff ff       	jmp    80105df2 <alltraps>

801069fe <vector146>:
.globl vector146
vector146:
  pushl $0
801069fe:	6a 00                	push   $0x0
  pushl $146
80106a00:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106a05:	e9 e8 f3 ff ff       	jmp    80105df2 <alltraps>

80106a0a <vector147>:
.globl vector147
vector147:
  pushl $0
80106a0a:	6a 00                	push   $0x0
  pushl $147
80106a0c:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106a11:	e9 dc f3 ff ff       	jmp    80105df2 <alltraps>

80106a16 <vector148>:
.globl vector148
vector148:
  pushl $0
80106a16:	6a 00                	push   $0x0
  pushl $148
80106a18:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106a1d:	e9 d0 f3 ff ff       	jmp    80105df2 <alltraps>

80106a22 <vector149>:
.globl vector149
vector149:
  pushl $0
80106a22:	6a 00                	push   $0x0
  pushl $149
80106a24:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106a29:	e9 c4 f3 ff ff       	jmp    80105df2 <alltraps>

80106a2e <vector150>:
.globl vector150
vector150:
  pushl $0
80106a2e:	6a 00                	push   $0x0
  pushl $150
80106a30:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106a35:	e9 b8 f3 ff ff       	jmp    80105df2 <alltraps>

80106a3a <vector151>:
.globl vector151
vector151:
  pushl $0
80106a3a:	6a 00                	push   $0x0
  pushl $151
80106a3c:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106a41:	e9 ac f3 ff ff       	jmp    80105df2 <alltraps>

80106a46 <vector152>:
.globl vector152
vector152:
  pushl $0
80106a46:	6a 00                	push   $0x0
  pushl $152
80106a48:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106a4d:	e9 a0 f3 ff ff       	jmp    80105df2 <alltraps>

80106a52 <vector153>:
.globl vector153
vector153:
  pushl $0
80106a52:	6a 00                	push   $0x0
  pushl $153
80106a54:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106a59:	e9 94 f3 ff ff       	jmp    80105df2 <alltraps>

80106a5e <vector154>:
.globl vector154
vector154:
  pushl $0
80106a5e:	6a 00                	push   $0x0
  pushl $154
80106a60:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106a65:	e9 88 f3 ff ff       	jmp    80105df2 <alltraps>

80106a6a <vector155>:
.globl vector155
vector155:
  pushl $0
80106a6a:	6a 00                	push   $0x0
  pushl $155
80106a6c:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106a71:	e9 7c f3 ff ff       	jmp    80105df2 <alltraps>

80106a76 <vector156>:
.globl vector156
vector156:
  pushl $0
80106a76:	6a 00                	push   $0x0
  pushl $156
80106a78:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106a7d:	e9 70 f3 ff ff       	jmp    80105df2 <alltraps>

80106a82 <vector157>:
.globl vector157
vector157:
  pushl $0
80106a82:	6a 00                	push   $0x0
  pushl $157
80106a84:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106a89:	e9 64 f3 ff ff       	jmp    80105df2 <alltraps>

80106a8e <vector158>:
.globl vector158
vector158:
  pushl $0
80106a8e:	6a 00                	push   $0x0
  pushl $158
80106a90:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106a95:	e9 58 f3 ff ff       	jmp    80105df2 <alltraps>

80106a9a <vector159>:
.globl vector159
vector159:
  pushl $0
80106a9a:	6a 00                	push   $0x0
  pushl $159
80106a9c:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106aa1:	e9 4c f3 ff ff       	jmp    80105df2 <alltraps>

80106aa6 <vector160>:
.globl vector160
vector160:
  pushl $0
80106aa6:	6a 00                	push   $0x0
  pushl $160
80106aa8:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106aad:	e9 40 f3 ff ff       	jmp    80105df2 <alltraps>

80106ab2 <vector161>:
.globl vector161
vector161:
  pushl $0
80106ab2:	6a 00                	push   $0x0
  pushl $161
80106ab4:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106ab9:	e9 34 f3 ff ff       	jmp    80105df2 <alltraps>

80106abe <vector162>:
.globl vector162
vector162:
  pushl $0
80106abe:	6a 00                	push   $0x0
  pushl $162
80106ac0:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106ac5:	e9 28 f3 ff ff       	jmp    80105df2 <alltraps>

80106aca <vector163>:
.globl vector163
vector163:
  pushl $0
80106aca:	6a 00                	push   $0x0
  pushl $163
80106acc:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106ad1:	e9 1c f3 ff ff       	jmp    80105df2 <alltraps>

80106ad6 <vector164>:
.globl vector164
vector164:
  pushl $0
80106ad6:	6a 00                	push   $0x0
  pushl $164
80106ad8:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106add:	e9 10 f3 ff ff       	jmp    80105df2 <alltraps>

80106ae2 <vector165>:
.globl vector165
vector165:
  pushl $0
80106ae2:	6a 00                	push   $0x0
  pushl $165
80106ae4:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106ae9:	e9 04 f3 ff ff       	jmp    80105df2 <alltraps>

80106aee <vector166>:
.globl vector166
vector166:
  pushl $0
80106aee:	6a 00                	push   $0x0
  pushl $166
80106af0:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106af5:	e9 f8 f2 ff ff       	jmp    80105df2 <alltraps>

80106afa <vector167>:
.globl vector167
vector167:
  pushl $0
80106afa:	6a 00                	push   $0x0
  pushl $167
80106afc:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106b01:	e9 ec f2 ff ff       	jmp    80105df2 <alltraps>

80106b06 <vector168>:
.globl vector168
vector168:
  pushl $0
80106b06:	6a 00                	push   $0x0
  pushl $168
80106b08:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106b0d:	e9 e0 f2 ff ff       	jmp    80105df2 <alltraps>

80106b12 <vector169>:
.globl vector169
vector169:
  pushl $0
80106b12:	6a 00                	push   $0x0
  pushl $169
80106b14:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106b19:	e9 d4 f2 ff ff       	jmp    80105df2 <alltraps>

80106b1e <vector170>:
.globl vector170
vector170:
  pushl $0
80106b1e:	6a 00                	push   $0x0
  pushl $170
80106b20:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106b25:	e9 c8 f2 ff ff       	jmp    80105df2 <alltraps>

80106b2a <vector171>:
.globl vector171
vector171:
  pushl $0
80106b2a:	6a 00                	push   $0x0
  pushl $171
80106b2c:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106b31:	e9 bc f2 ff ff       	jmp    80105df2 <alltraps>

80106b36 <vector172>:
.globl vector172
vector172:
  pushl $0
80106b36:	6a 00                	push   $0x0
  pushl $172
80106b38:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106b3d:	e9 b0 f2 ff ff       	jmp    80105df2 <alltraps>

80106b42 <vector173>:
.globl vector173
vector173:
  pushl $0
80106b42:	6a 00                	push   $0x0
  pushl $173
80106b44:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106b49:	e9 a4 f2 ff ff       	jmp    80105df2 <alltraps>

80106b4e <vector174>:
.globl vector174
vector174:
  pushl $0
80106b4e:	6a 00                	push   $0x0
  pushl $174
80106b50:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106b55:	e9 98 f2 ff ff       	jmp    80105df2 <alltraps>

80106b5a <vector175>:
.globl vector175
vector175:
  pushl $0
80106b5a:	6a 00                	push   $0x0
  pushl $175
80106b5c:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106b61:	e9 8c f2 ff ff       	jmp    80105df2 <alltraps>

80106b66 <vector176>:
.globl vector176
vector176:
  pushl $0
80106b66:	6a 00                	push   $0x0
  pushl $176
80106b68:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106b6d:	e9 80 f2 ff ff       	jmp    80105df2 <alltraps>

80106b72 <vector177>:
.globl vector177
vector177:
  pushl $0
80106b72:	6a 00                	push   $0x0
  pushl $177
80106b74:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106b79:	e9 74 f2 ff ff       	jmp    80105df2 <alltraps>

80106b7e <vector178>:
.globl vector178
vector178:
  pushl $0
80106b7e:	6a 00                	push   $0x0
  pushl $178
80106b80:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106b85:	e9 68 f2 ff ff       	jmp    80105df2 <alltraps>

80106b8a <vector179>:
.globl vector179
vector179:
  pushl $0
80106b8a:	6a 00                	push   $0x0
  pushl $179
80106b8c:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106b91:	e9 5c f2 ff ff       	jmp    80105df2 <alltraps>

80106b96 <vector180>:
.globl vector180
vector180:
  pushl $0
80106b96:	6a 00                	push   $0x0
  pushl $180
80106b98:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106b9d:	e9 50 f2 ff ff       	jmp    80105df2 <alltraps>

80106ba2 <vector181>:
.globl vector181
vector181:
  pushl $0
80106ba2:	6a 00                	push   $0x0
  pushl $181
80106ba4:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106ba9:	e9 44 f2 ff ff       	jmp    80105df2 <alltraps>

80106bae <vector182>:
.globl vector182
vector182:
  pushl $0
80106bae:	6a 00                	push   $0x0
  pushl $182
80106bb0:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106bb5:	e9 38 f2 ff ff       	jmp    80105df2 <alltraps>

80106bba <vector183>:
.globl vector183
vector183:
  pushl $0
80106bba:	6a 00                	push   $0x0
  pushl $183
80106bbc:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106bc1:	e9 2c f2 ff ff       	jmp    80105df2 <alltraps>

80106bc6 <vector184>:
.globl vector184
vector184:
  pushl $0
80106bc6:	6a 00                	push   $0x0
  pushl $184
80106bc8:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106bcd:	e9 20 f2 ff ff       	jmp    80105df2 <alltraps>

80106bd2 <vector185>:
.globl vector185
vector185:
  pushl $0
80106bd2:	6a 00                	push   $0x0
  pushl $185
80106bd4:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106bd9:	e9 14 f2 ff ff       	jmp    80105df2 <alltraps>

80106bde <vector186>:
.globl vector186
vector186:
  pushl $0
80106bde:	6a 00                	push   $0x0
  pushl $186
80106be0:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106be5:	e9 08 f2 ff ff       	jmp    80105df2 <alltraps>

80106bea <vector187>:
.globl vector187
vector187:
  pushl $0
80106bea:	6a 00                	push   $0x0
  pushl $187
80106bec:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106bf1:	e9 fc f1 ff ff       	jmp    80105df2 <alltraps>

80106bf6 <vector188>:
.globl vector188
vector188:
  pushl $0
80106bf6:	6a 00                	push   $0x0
  pushl $188
80106bf8:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106bfd:	e9 f0 f1 ff ff       	jmp    80105df2 <alltraps>

80106c02 <vector189>:
.globl vector189
vector189:
  pushl $0
80106c02:	6a 00                	push   $0x0
  pushl $189
80106c04:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106c09:	e9 e4 f1 ff ff       	jmp    80105df2 <alltraps>

80106c0e <vector190>:
.globl vector190
vector190:
  pushl $0
80106c0e:	6a 00                	push   $0x0
  pushl $190
80106c10:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106c15:	e9 d8 f1 ff ff       	jmp    80105df2 <alltraps>

80106c1a <vector191>:
.globl vector191
vector191:
  pushl $0
80106c1a:	6a 00                	push   $0x0
  pushl $191
80106c1c:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106c21:	e9 cc f1 ff ff       	jmp    80105df2 <alltraps>

80106c26 <vector192>:
.globl vector192
vector192:
  pushl $0
80106c26:	6a 00                	push   $0x0
  pushl $192
80106c28:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106c2d:	e9 c0 f1 ff ff       	jmp    80105df2 <alltraps>

80106c32 <vector193>:
.globl vector193
vector193:
  pushl $0
80106c32:	6a 00                	push   $0x0
  pushl $193
80106c34:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106c39:	e9 b4 f1 ff ff       	jmp    80105df2 <alltraps>

80106c3e <vector194>:
.globl vector194
vector194:
  pushl $0
80106c3e:	6a 00                	push   $0x0
  pushl $194
80106c40:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106c45:	e9 a8 f1 ff ff       	jmp    80105df2 <alltraps>

80106c4a <vector195>:
.globl vector195
vector195:
  pushl $0
80106c4a:	6a 00                	push   $0x0
  pushl $195
80106c4c:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106c51:	e9 9c f1 ff ff       	jmp    80105df2 <alltraps>

80106c56 <vector196>:
.globl vector196
vector196:
  pushl $0
80106c56:	6a 00                	push   $0x0
  pushl $196
80106c58:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106c5d:	e9 90 f1 ff ff       	jmp    80105df2 <alltraps>

80106c62 <vector197>:
.globl vector197
vector197:
  pushl $0
80106c62:	6a 00                	push   $0x0
  pushl $197
80106c64:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106c69:	e9 84 f1 ff ff       	jmp    80105df2 <alltraps>

80106c6e <vector198>:
.globl vector198
vector198:
  pushl $0
80106c6e:	6a 00                	push   $0x0
  pushl $198
80106c70:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106c75:	e9 78 f1 ff ff       	jmp    80105df2 <alltraps>

80106c7a <vector199>:
.globl vector199
vector199:
  pushl $0
80106c7a:	6a 00                	push   $0x0
  pushl $199
80106c7c:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106c81:	e9 6c f1 ff ff       	jmp    80105df2 <alltraps>

80106c86 <vector200>:
.globl vector200
vector200:
  pushl $0
80106c86:	6a 00                	push   $0x0
  pushl $200
80106c88:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106c8d:	e9 60 f1 ff ff       	jmp    80105df2 <alltraps>

80106c92 <vector201>:
.globl vector201
vector201:
  pushl $0
80106c92:	6a 00                	push   $0x0
  pushl $201
80106c94:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80106c99:	e9 54 f1 ff ff       	jmp    80105df2 <alltraps>

80106c9e <vector202>:
.globl vector202
vector202:
  pushl $0
80106c9e:	6a 00                	push   $0x0
  pushl $202
80106ca0:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106ca5:	e9 48 f1 ff ff       	jmp    80105df2 <alltraps>

80106caa <vector203>:
.globl vector203
vector203:
  pushl $0
80106caa:	6a 00                	push   $0x0
  pushl $203
80106cac:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106cb1:	e9 3c f1 ff ff       	jmp    80105df2 <alltraps>

80106cb6 <vector204>:
.globl vector204
vector204:
  pushl $0
80106cb6:	6a 00                	push   $0x0
  pushl $204
80106cb8:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106cbd:	e9 30 f1 ff ff       	jmp    80105df2 <alltraps>

80106cc2 <vector205>:
.globl vector205
vector205:
  pushl $0
80106cc2:	6a 00                	push   $0x0
  pushl $205
80106cc4:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106cc9:	e9 24 f1 ff ff       	jmp    80105df2 <alltraps>

80106cce <vector206>:
.globl vector206
vector206:
  pushl $0
80106cce:	6a 00                	push   $0x0
  pushl $206
80106cd0:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106cd5:	e9 18 f1 ff ff       	jmp    80105df2 <alltraps>

80106cda <vector207>:
.globl vector207
vector207:
  pushl $0
80106cda:	6a 00                	push   $0x0
  pushl $207
80106cdc:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106ce1:	e9 0c f1 ff ff       	jmp    80105df2 <alltraps>

80106ce6 <vector208>:
.globl vector208
vector208:
  pushl $0
80106ce6:	6a 00                	push   $0x0
  pushl $208
80106ce8:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106ced:	e9 00 f1 ff ff       	jmp    80105df2 <alltraps>

80106cf2 <vector209>:
.globl vector209
vector209:
  pushl $0
80106cf2:	6a 00                	push   $0x0
  pushl $209
80106cf4:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106cf9:	e9 f4 f0 ff ff       	jmp    80105df2 <alltraps>

80106cfe <vector210>:
.globl vector210
vector210:
  pushl $0
80106cfe:	6a 00                	push   $0x0
  pushl $210
80106d00:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106d05:	e9 e8 f0 ff ff       	jmp    80105df2 <alltraps>

80106d0a <vector211>:
.globl vector211
vector211:
  pushl $0
80106d0a:	6a 00                	push   $0x0
  pushl $211
80106d0c:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106d11:	e9 dc f0 ff ff       	jmp    80105df2 <alltraps>

80106d16 <vector212>:
.globl vector212
vector212:
  pushl $0
80106d16:	6a 00                	push   $0x0
  pushl $212
80106d18:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106d1d:	e9 d0 f0 ff ff       	jmp    80105df2 <alltraps>

80106d22 <vector213>:
.globl vector213
vector213:
  pushl $0
80106d22:	6a 00                	push   $0x0
  pushl $213
80106d24:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80106d29:	e9 c4 f0 ff ff       	jmp    80105df2 <alltraps>

80106d2e <vector214>:
.globl vector214
vector214:
  pushl $0
80106d2e:	6a 00                	push   $0x0
  pushl $214
80106d30:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106d35:	e9 b8 f0 ff ff       	jmp    80105df2 <alltraps>

80106d3a <vector215>:
.globl vector215
vector215:
  pushl $0
80106d3a:	6a 00                	push   $0x0
  pushl $215
80106d3c:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106d41:	e9 ac f0 ff ff       	jmp    80105df2 <alltraps>

80106d46 <vector216>:
.globl vector216
vector216:
  pushl $0
80106d46:	6a 00                	push   $0x0
  pushl $216
80106d48:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106d4d:	e9 a0 f0 ff ff       	jmp    80105df2 <alltraps>

80106d52 <vector217>:
.globl vector217
vector217:
  pushl $0
80106d52:	6a 00                	push   $0x0
  pushl $217
80106d54:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80106d59:	e9 94 f0 ff ff       	jmp    80105df2 <alltraps>

80106d5e <vector218>:
.globl vector218
vector218:
  pushl $0
80106d5e:	6a 00                	push   $0x0
  pushl $218
80106d60:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106d65:	e9 88 f0 ff ff       	jmp    80105df2 <alltraps>

80106d6a <vector219>:
.globl vector219
vector219:
  pushl $0
80106d6a:	6a 00                	push   $0x0
  pushl $219
80106d6c:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106d71:	e9 7c f0 ff ff       	jmp    80105df2 <alltraps>

80106d76 <vector220>:
.globl vector220
vector220:
  pushl $0
80106d76:	6a 00                	push   $0x0
  pushl $220
80106d78:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80106d7d:	e9 70 f0 ff ff       	jmp    80105df2 <alltraps>

80106d82 <vector221>:
.globl vector221
vector221:
  pushl $0
80106d82:	6a 00                	push   $0x0
  pushl $221
80106d84:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80106d89:	e9 64 f0 ff ff       	jmp    80105df2 <alltraps>

80106d8e <vector222>:
.globl vector222
vector222:
  pushl $0
80106d8e:	6a 00                	push   $0x0
  pushl $222
80106d90:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80106d95:	e9 58 f0 ff ff       	jmp    80105df2 <alltraps>

80106d9a <vector223>:
.globl vector223
vector223:
  pushl $0
80106d9a:	6a 00                	push   $0x0
  pushl $223
80106d9c:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106da1:	e9 4c f0 ff ff       	jmp    80105df2 <alltraps>

80106da6 <vector224>:
.globl vector224
vector224:
  pushl $0
80106da6:	6a 00                	push   $0x0
  pushl $224
80106da8:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80106dad:	e9 40 f0 ff ff       	jmp    80105df2 <alltraps>

80106db2 <vector225>:
.globl vector225
vector225:
  pushl $0
80106db2:	6a 00                	push   $0x0
  pushl $225
80106db4:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80106db9:	e9 34 f0 ff ff       	jmp    80105df2 <alltraps>

80106dbe <vector226>:
.globl vector226
vector226:
  pushl $0
80106dbe:	6a 00                	push   $0x0
  pushl $226
80106dc0:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80106dc5:	e9 28 f0 ff ff       	jmp    80105df2 <alltraps>

80106dca <vector227>:
.globl vector227
vector227:
  pushl $0
80106dca:	6a 00                	push   $0x0
  pushl $227
80106dcc:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80106dd1:	e9 1c f0 ff ff       	jmp    80105df2 <alltraps>

80106dd6 <vector228>:
.globl vector228
vector228:
  pushl $0
80106dd6:	6a 00                	push   $0x0
  pushl $228
80106dd8:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80106ddd:	e9 10 f0 ff ff       	jmp    80105df2 <alltraps>

80106de2 <vector229>:
.globl vector229
vector229:
  pushl $0
80106de2:	6a 00                	push   $0x0
  pushl $229
80106de4:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80106de9:	e9 04 f0 ff ff       	jmp    80105df2 <alltraps>

80106dee <vector230>:
.globl vector230
vector230:
  pushl $0
80106dee:	6a 00                	push   $0x0
  pushl $230
80106df0:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80106df5:	e9 f8 ef ff ff       	jmp    80105df2 <alltraps>

80106dfa <vector231>:
.globl vector231
vector231:
  pushl $0
80106dfa:	6a 00                	push   $0x0
  pushl $231
80106dfc:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80106e01:	e9 ec ef ff ff       	jmp    80105df2 <alltraps>

80106e06 <vector232>:
.globl vector232
vector232:
  pushl $0
80106e06:	6a 00                	push   $0x0
  pushl $232
80106e08:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80106e0d:	e9 e0 ef ff ff       	jmp    80105df2 <alltraps>

80106e12 <vector233>:
.globl vector233
vector233:
  pushl $0
80106e12:	6a 00                	push   $0x0
  pushl $233
80106e14:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80106e19:	e9 d4 ef ff ff       	jmp    80105df2 <alltraps>

80106e1e <vector234>:
.globl vector234
vector234:
  pushl $0
80106e1e:	6a 00                	push   $0x0
  pushl $234
80106e20:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80106e25:	e9 c8 ef ff ff       	jmp    80105df2 <alltraps>

80106e2a <vector235>:
.globl vector235
vector235:
  pushl $0
80106e2a:	6a 00                	push   $0x0
  pushl $235
80106e2c:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80106e31:	e9 bc ef ff ff       	jmp    80105df2 <alltraps>

80106e36 <vector236>:
.globl vector236
vector236:
  pushl $0
80106e36:	6a 00                	push   $0x0
  pushl $236
80106e38:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80106e3d:	e9 b0 ef ff ff       	jmp    80105df2 <alltraps>

80106e42 <vector237>:
.globl vector237
vector237:
  pushl $0
80106e42:	6a 00                	push   $0x0
  pushl $237
80106e44:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80106e49:	e9 a4 ef ff ff       	jmp    80105df2 <alltraps>

80106e4e <vector238>:
.globl vector238
vector238:
  pushl $0
80106e4e:	6a 00                	push   $0x0
  pushl $238
80106e50:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80106e55:	e9 98 ef ff ff       	jmp    80105df2 <alltraps>

80106e5a <vector239>:
.globl vector239
vector239:
  pushl $0
80106e5a:	6a 00                	push   $0x0
  pushl $239
80106e5c:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80106e61:	e9 8c ef ff ff       	jmp    80105df2 <alltraps>

80106e66 <vector240>:
.globl vector240
vector240:
  pushl $0
80106e66:	6a 00                	push   $0x0
  pushl $240
80106e68:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80106e6d:	e9 80 ef ff ff       	jmp    80105df2 <alltraps>

80106e72 <vector241>:
.globl vector241
vector241:
  pushl $0
80106e72:	6a 00                	push   $0x0
  pushl $241
80106e74:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80106e79:	e9 74 ef ff ff       	jmp    80105df2 <alltraps>

80106e7e <vector242>:
.globl vector242
vector242:
  pushl $0
80106e7e:	6a 00                	push   $0x0
  pushl $242
80106e80:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80106e85:	e9 68 ef ff ff       	jmp    80105df2 <alltraps>

80106e8a <vector243>:
.globl vector243
vector243:
  pushl $0
80106e8a:	6a 00                	push   $0x0
  pushl $243
80106e8c:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80106e91:	e9 5c ef ff ff       	jmp    80105df2 <alltraps>

80106e96 <vector244>:
.globl vector244
vector244:
  pushl $0
80106e96:	6a 00                	push   $0x0
  pushl $244
80106e98:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80106e9d:	e9 50 ef ff ff       	jmp    80105df2 <alltraps>

80106ea2 <vector245>:
.globl vector245
vector245:
  pushl $0
80106ea2:	6a 00                	push   $0x0
  pushl $245
80106ea4:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80106ea9:	e9 44 ef ff ff       	jmp    80105df2 <alltraps>

80106eae <vector246>:
.globl vector246
vector246:
  pushl $0
80106eae:	6a 00                	push   $0x0
  pushl $246
80106eb0:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80106eb5:	e9 38 ef ff ff       	jmp    80105df2 <alltraps>

80106eba <vector247>:
.globl vector247
vector247:
  pushl $0
80106eba:	6a 00                	push   $0x0
  pushl $247
80106ebc:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80106ec1:	e9 2c ef ff ff       	jmp    80105df2 <alltraps>

80106ec6 <vector248>:
.globl vector248
vector248:
  pushl $0
80106ec6:	6a 00                	push   $0x0
  pushl $248
80106ec8:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80106ecd:	e9 20 ef ff ff       	jmp    80105df2 <alltraps>

80106ed2 <vector249>:
.globl vector249
vector249:
  pushl $0
80106ed2:	6a 00                	push   $0x0
  pushl $249
80106ed4:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80106ed9:	e9 14 ef ff ff       	jmp    80105df2 <alltraps>

80106ede <vector250>:
.globl vector250
vector250:
  pushl $0
80106ede:	6a 00                	push   $0x0
  pushl $250
80106ee0:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80106ee5:	e9 08 ef ff ff       	jmp    80105df2 <alltraps>

80106eea <vector251>:
.globl vector251
vector251:
  pushl $0
80106eea:	6a 00                	push   $0x0
  pushl $251
80106eec:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80106ef1:	e9 fc ee ff ff       	jmp    80105df2 <alltraps>

80106ef6 <vector252>:
.globl vector252
vector252:
  pushl $0
80106ef6:	6a 00                	push   $0x0
  pushl $252
80106ef8:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80106efd:	e9 f0 ee ff ff       	jmp    80105df2 <alltraps>

80106f02 <vector253>:
.globl vector253
vector253:
  pushl $0
80106f02:	6a 00                	push   $0x0
  pushl $253
80106f04:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80106f09:	e9 e4 ee ff ff       	jmp    80105df2 <alltraps>

80106f0e <vector254>:
.globl vector254
vector254:
  pushl $0
80106f0e:	6a 00                	push   $0x0
  pushl $254
80106f10:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80106f15:	e9 d8 ee ff ff       	jmp    80105df2 <alltraps>

80106f1a <vector255>:
.globl vector255
vector255:
  pushl $0
80106f1a:	6a 00                	push   $0x0
  pushl $255
80106f1c:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80106f21:	e9 cc ee ff ff       	jmp    80105df2 <alltraps>

80106f26 <lgdt>:
{
80106f26:	55                   	push   %ebp
80106f27:	89 e5                	mov    %esp,%ebp
80106f29:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106f2c:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f2f:	83 e8 01             	sub    $0x1,%eax
80106f32:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106f36:	8b 45 08             	mov    0x8(%ebp),%eax
80106f39:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106f3d:	8b 45 08             	mov    0x8(%ebp),%eax
80106f40:	c1 e8 10             	shr    $0x10,%eax
80106f43:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80106f47:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106f4a:	0f 01 10             	lgdtl  (%eax)
}
80106f4d:	90                   	nop
80106f4e:	c9                   	leave  
80106f4f:	c3                   	ret    

80106f50 <ltr>:
{
80106f50:	55                   	push   %ebp
80106f51:	89 e5                	mov    %esp,%ebp
80106f53:	83 ec 04             	sub    $0x4,%esp
80106f56:	8b 45 08             	mov    0x8(%ebp),%eax
80106f59:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80106f5d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80106f61:	0f 00 d8             	ltr    %ax
}
80106f64:	90                   	nop
80106f65:	c9                   	leave  
80106f66:	c3                   	ret    

80106f67 <lcr3>:

static inline void
lcr3(uint val)
{
80106f67:	55                   	push   %ebp
80106f68:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106f6a:	8b 45 08             	mov    0x8(%ebp),%eax
80106f6d:	0f 22 d8             	mov    %eax,%cr3
}
80106f70:	90                   	nop
80106f71:	5d                   	pop    %ebp
80106f72:	c3                   	ret    

80106f73 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80106f73:	55                   	push   %ebp
80106f74:	89 e5                	mov    %esp,%ebp
80106f76:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80106f79:	e8 1a ca ff ff       	call   80103998 <cpuid>
80106f7e:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80106f84:	05 80 6a 19 80       	add    $0x80196a80,%eax
80106f89:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80106f8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f8f:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80106f95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f98:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80106f9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fa1:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80106fa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fa8:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106fac:	83 e2 f0             	and    $0xfffffff0,%edx
80106faf:	83 ca 0a             	or     $0xa,%edx
80106fb2:	88 50 7d             	mov    %dl,0x7d(%eax)
80106fb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fb8:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106fbc:	83 ca 10             	or     $0x10,%edx
80106fbf:	88 50 7d             	mov    %dl,0x7d(%eax)
80106fc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fc5:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106fc9:	83 e2 9f             	and    $0xffffff9f,%edx
80106fcc:	88 50 7d             	mov    %dl,0x7d(%eax)
80106fcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fd2:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106fd6:	83 ca 80             	or     $0xffffff80,%edx
80106fd9:	88 50 7d             	mov    %dl,0x7d(%eax)
80106fdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fdf:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106fe3:	83 ca 0f             	or     $0xf,%edx
80106fe6:	88 50 7e             	mov    %dl,0x7e(%eax)
80106fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fec:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106ff0:	83 e2 ef             	and    $0xffffffef,%edx
80106ff3:	88 50 7e             	mov    %dl,0x7e(%eax)
80106ff6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ff9:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106ffd:	83 e2 df             	and    $0xffffffdf,%edx
80107000:	88 50 7e             	mov    %dl,0x7e(%eax)
80107003:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107006:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010700a:	83 ca 40             	or     $0x40,%edx
8010700d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107010:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107013:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107017:	83 ca 80             	or     $0xffffff80,%edx
8010701a:	88 50 7e             	mov    %dl,0x7e(%eax)
8010701d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107020:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107024:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107027:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010702e:	ff ff 
80107030:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107033:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010703a:	00 00 
8010703c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010703f:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107046:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107049:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107050:	83 e2 f0             	and    $0xfffffff0,%edx
80107053:	83 ca 02             	or     $0x2,%edx
80107056:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010705c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010705f:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107066:	83 ca 10             	or     $0x10,%edx
80107069:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010706f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107072:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107079:	83 e2 9f             	and    $0xffffff9f,%edx
8010707c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107085:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010708c:	83 ca 80             	or     $0xffffff80,%edx
8010708f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107095:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107098:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010709f:	83 ca 0f             	or     $0xf,%edx
801070a2:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801070a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070ab:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801070b2:	83 e2 ef             	and    $0xffffffef,%edx
801070b5:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801070bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070be:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801070c5:	83 e2 df             	and    $0xffffffdf,%edx
801070c8:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801070ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070d1:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801070d8:	83 ca 40             	or     $0x40,%edx
801070db:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801070e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070e4:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801070eb:	83 ca 80             	or     $0xffffff80,%edx
801070ee:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801070f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070f7:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801070fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107101:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107108:	ff ff 
8010710a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010710d:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107114:	00 00 
80107116:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107119:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107120:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107123:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010712a:	83 e2 f0             	and    $0xfffffff0,%edx
8010712d:	83 ca 0a             	or     $0xa,%edx
80107130:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107136:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107139:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107140:	83 ca 10             	or     $0x10,%edx
80107143:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107149:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010714c:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107153:	83 ca 60             	or     $0x60,%edx
80107156:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010715c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010715f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107166:	83 ca 80             	or     $0xffffff80,%edx
80107169:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010716f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107172:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107179:	83 ca 0f             	or     $0xf,%edx
8010717c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107185:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010718c:	83 e2 ef             	and    $0xffffffef,%edx
8010718f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107198:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010719f:	83 e2 df             	and    $0xffffffdf,%edx
801071a2:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801071a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071ab:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801071b2:	83 ca 40             	or     $0x40,%edx
801071b5:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801071bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071be:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801071c5:	83 ca 80             	or     $0xffffff80,%edx
801071c8:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801071ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071d1:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801071d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071db:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801071e2:	ff ff 
801071e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071e7:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801071ee:	00 00 
801071f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071f3:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801071fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071fd:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107204:	83 e2 f0             	and    $0xfffffff0,%edx
80107207:	83 ca 02             	or     $0x2,%edx
8010720a:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107210:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107213:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010721a:	83 ca 10             	or     $0x10,%edx
8010721d:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107223:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107226:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010722d:	83 ca 60             	or     $0x60,%edx
80107230:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107236:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107239:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107240:	83 ca 80             	or     $0xffffff80,%edx
80107243:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107249:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010724c:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107253:	83 ca 0f             	or     $0xf,%edx
80107256:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010725c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010725f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107266:	83 e2 ef             	and    $0xffffffef,%edx
80107269:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010726f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107272:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107279:	83 e2 df             	and    $0xffffffdf,%edx
8010727c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107282:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107285:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010728c:	83 ca 40             	or     $0x40,%edx
8010728f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107295:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107298:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010729f:	83 ca 80             	or     $0xffffff80,%edx
801072a2:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801072a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072ab:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801072b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072b5:	83 c0 70             	add    $0x70,%eax
801072b8:	83 ec 08             	sub    $0x8,%esp
801072bb:	6a 30                	push   $0x30
801072bd:	50                   	push   %eax
801072be:	e8 63 fc ff ff       	call   80106f26 <lgdt>
801072c3:	83 c4 10             	add    $0x10,%esp
}
801072c6:	90                   	nop
801072c7:	c9                   	leave  
801072c8:	c3                   	ret    

801072c9 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801072c9:	55                   	push   %ebp
801072ca:	89 e5                	mov    %esp,%ebp
801072cc:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801072cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801072d2:	c1 e8 16             	shr    $0x16,%eax
801072d5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801072dc:	8b 45 08             	mov    0x8(%ebp),%eax
801072df:	01 d0                	add    %edx,%eax
801072e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801072e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801072e7:	8b 00                	mov    (%eax),%eax
801072e9:	83 e0 01             	and    $0x1,%eax
801072ec:	85 c0                	test   %eax,%eax
801072ee:	74 14                	je     80107304 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801072f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801072f3:	8b 00                	mov    (%eax),%eax
801072f5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801072fa:	05 00 00 00 80       	add    $0x80000000,%eax
801072ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107302:	eb 42                	jmp    80107346 <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107304:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107308:	74 0e                	je     80107318 <walkpgdir+0x4f>
8010730a:	e8 8c b4 ff ff       	call   8010279b <kalloc>
8010730f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107312:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107316:	75 07                	jne    8010731f <walkpgdir+0x56>
      return 0;
80107318:	b8 00 00 00 00       	mov    $0x0,%eax
8010731d:	eb 3e                	jmp    8010735d <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    //cprintf("walkpgdir : make New Page\n");
    memset(pgtab, 0, PGSIZE);
8010731f:	83 ec 04             	sub    $0x4,%esp
80107322:	68 00 10 00 00       	push   $0x1000
80107327:	6a 00                	push   $0x0
80107329:	ff 75 f4             	push   -0xc(%ebp)
8010732c:	e8 7b d7 ff ff       	call   80104aac <memset>
80107331:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107334:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107337:	05 00 00 00 80       	add    $0x80000000,%eax
8010733c:	83 c8 07             	or     $0x7,%eax
8010733f:	89 c2                	mov    %eax,%edx
80107341:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107344:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107346:	8b 45 0c             	mov    0xc(%ebp),%eax
80107349:	c1 e8 0c             	shr    $0xc,%eax
8010734c:	25 ff 03 00 00       	and    $0x3ff,%eax
80107351:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107358:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010735b:	01 d0                	add    %edx,%eax
}
8010735d:	c9                   	leave  
8010735e:	c3                   	ret    

8010735f <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010735f:	55                   	push   %ebp
80107360:	89 e5                	mov    %esp,%ebp
80107362:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107365:	8b 45 0c             	mov    0xc(%ebp),%eax
80107368:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010736d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107370:	8b 55 0c             	mov    0xc(%ebp),%edx
80107373:	8b 45 10             	mov    0x10(%ebp),%eax
80107376:	01 d0                	add    %edx,%eax
80107378:	83 e8 01             	sub    $0x1,%eax
8010737b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107380:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107383:	83 ec 04             	sub    $0x4,%esp
80107386:	6a 01                	push   $0x1
80107388:	ff 75 f4             	push   -0xc(%ebp)
8010738b:	ff 75 08             	push   0x8(%ebp)
8010738e:	e8 36 ff ff ff       	call   801072c9 <walkpgdir>
80107393:	83 c4 10             	add    $0x10,%esp
80107396:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107399:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010739d:	75 07                	jne    801073a6 <mappages+0x47>
      return -1;
8010739f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073a4:	eb 47                	jmp    801073ed <mappages+0x8e>
    if(*pte & PTE_P)
801073a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801073a9:	8b 00                	mov    (%eax),%eax
801073ab:	83 e0 01             	and    $0x1,%eax
801073ae:	85 c0                	test   %eax,%eax
801073b0:	74 0d                	je     801073bf <mappages+0x60>
      panic("remap");
801073b2:	83 ec 0c             	sub    $0xc,%esp
801073b5:	68 48 a7 10 80       	push   $0x8010a748
801073ba:	e8 ea 91 ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
801073bf:	8b 45 18             	mov    0x18(%ebp),%eax
801073c2:	0b 45 14             	or     0x14(%ebp),%eax
801073c5:	83 c8 01             	or     $0x1,%eax
801073c8:	89 c2                	mov    %eax,%edx
801073ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
801073cd:	89 10                	mov    %edx,(%eax)
    if(a == last)
801073cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073d2:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801073d5:	74 10                	je     801073e7 <mappages+0x88>
      break;
    a += PGSIZE;
801073d7:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801073de:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801073e5:	eb 9c                	jmp    80107383 <mappages+0x24>
      break;
801073e7:	90                   	nop
  }
  return 0;
801073e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801073ed:	c9                   	leave  
801073ee:	c3                   	ret    

801073ef <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801073ef:	55                   	push   %ebp
801073f0:	89 e5                	mov    %esp,%ebp
801073f2:	53                   	push   %ebx
801073f3:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
801073f6:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
801073fd:	8b 15 50 6d 19 80    	mov    0x80196d50,%edx
80107403:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
80107408:	29 d0                	sub    %edx,%eax
8010740a:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010740d:	a1 48 6d 19 80       	mov    0x80196d48,%eax
80107412:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107415:	8b 15 48 6d 19 80    	mov    0x80196d48,%edx
8010741b:	a1 50 6d 19 80       	mov    0x80196d50,%eax
80107420:	01 d0                	add    %edx,%eax
80107422:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107425:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
8010742c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010742f:	83 c0 30             	add    $0x30,%eax
80107432:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107435:	89 10                	mov    %edx,(%eax)
80107437:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010743a:	89 50 04             	mov    %edx,0x4(%eax)
8010743d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107440:	89 50 08             	mov    %edx,0x8(%eax)
80107443:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107446:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107449:	e8 4d b3 ff ff       	call   8010279b <kalloc>
8010744e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107451:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107455:	75 07                	jne    8010745e <setupkvm+0x6f>
    return 0;
80107457:	b8 00 00 00 00       	mov    $0x0,%eax
8010745c:	eb 78                	jmp    801074d6 <setupkvm+0xe7>
  }
  memset(pgdir, 0, PGSIZE);
8010745e:	83 ec 04             	sub    $0x4,%esp
80107461:	68 00 10 00 00       	push   $0x1000
80107466:	6a 00                	push   $0x0
80107468:	ff 75 f0             	push   -0x10(%ebp)
8010746b:	e8 3c d6 ff ff       	call   80104aac <memset>
80107470:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107473:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
8010747a:	eb 4e                	jmp    801074ca <setupkvm+0xdb>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010747c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010747f:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107482:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107485:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107488:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010748b:	8b 58 08             	mov    0x8(%eax),%ebx
8010748e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107491:	8b 40 04             	mov    0x4(%eax),%eax
80107494:	29 c3                	sub    %eax,%ebx
80107496:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107499:	8b 00                	mov    (%eax),%eax
8010749b:	83 ec 0c             	sub    $0xc,%esp
8010749e:	51                   	push   %ecx
8010749f:	52                   	push   %edx
801074a0:	53                   	push   %ebx
801074a1:	50                   	push   %eax
801074a2:	ff 75 f0             	push   -0x10(%ebp)
801074a5:	e8 b5 fe ff ff       	call   8010735f <mappages>
801074aa:	83 c4 20             	add    $0x20,%esp
801074ad:	85 c0                	test   %eax,%eax
801074af:	79 15                	jns    801074c6 <setupkvm+0xd7>
      freevm(pgdir);
801074b1:	83 ec 0c             	sub    $0xc,%esp
801074b4:	ff 75 f0             	push   -0x10(%ebp)
801074b7:	e8 f7 04 00 00       	call   801079b3 <freevm>
801074bc:	83 c4 10             	add    $0x10,%esp
      return 0;
801074bf:	b8 00 00 00 00       	mov    $0x0,%eax
801074c4:	eb 10                	jmp    801074d6 <setupkvm+0xe7>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801074c6:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801074ca:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
801074d1:	72 a9                	jb     8010747c <setupkvm+0x8d>
    }
  return pgdir;
801074d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801074d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801074d9:	c9                   	leave  
801074da:	c3                   	ret    

801074db <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801074db:	55                   	push   %ebp
801074dc:	89 e5                	mov    %esp,%ebp
801074de:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801074e1:	e8 09 ff ff ff       	call   801073ef <setupkvm>
801074e6:	a3 7c 6a 19 80       	mov    %eax,0x80196a7c
  switchkvm();
801074eb:	e8 03 00 00 00       	call   801074f3 <switchkvm>
}
801074f0:	90                   	nop
801074f1:	c9                   	leave  
801074f2:	c3                   	ret    

801074f3 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801074f3:	55                   	push   %ebp
801074f4:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801074f6:	a1 7c 6a 19 80       	mov    0x80196a7c,%eax
801074fb:	05 00 00 00 80       	add    $0x80000000,%eax
80107500:	50                   	push   %eax
80107501:	e8 61 fa ff ff       	call   80106f67 <lcr3>
80107506:	83 c4 04             	add    $0x4,%esp
}
80107509:	90                   	nop
8010750a:	c9                   	leave  
8010750b:	c3                   	ret    

8010750c <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
8010750c:	55                   	push   %ebp
8010750d:	89 e5                	mov    %esp,%ebp
8010750f:	56                   	push   %esi
80107510:	53                   	push   %ebx
80107511:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107514:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107518:	75 0d                	jne    80107527 <switchuvm+0x1b>
    panic("switchuvm: no process");
8010751a:	83 ec 0c             	sub    $0xc,%esp
8010751d:	68 4e a7 10 80       	push   $0x8010a74e
80107522:	e8 82 90 ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
80107527:	8b 45 08             	mov    0x8(%ebp),%eax
8010752a:	8b 40 08             	mov    0x8(%eax),%eax
8010752d:	85 c0                	test   %eax,%eax
8010752f:	75 0d                	jne    8010753e <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107531:	83 ec 0c             	sub    $0xc,%esp
80107534:	68 64 a7 10 80       	push   $0x8010a764
80107539:	e8 6b 90 ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
8010753e:	8b 45 08             	mov    0x8(%ebp),%eax
80107541:	8b 40 04             	mov    0x4(%eax),%eax
80107544:	85 c0                	test   %eax,%eax
80107546:	75 0d                	jne    80107555 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80107548:	83 ec 0c             	sub    $0xc,%esp
8010754b:	68 79 a7 10 80       	push   $0x8010a779
80107550:	e8 54 90 ff ff       	call   801005a9 <panic>

  pushcli();
80107555:	e8 47 d4 ff ff       	call   801049a1 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
8010755a:	e8 54 c4 ff ff       	call   801039b3 <mycpu>
8010755f:	89 c3                	mov    %eax,%ebx
80107561:	e8 4d c4 ff ff       	call   801039b3 <mycpu>
80107566:	83 c0 08             	add    $0x8,%eax
80107569:	89 c6                	mov    %eax,%esi
8010756b:	e8 43 c4 ff ff       	call   801039b3 <mycpu>
80107570:	83 c0 08             	add    $0x8,%eax
80107573:	c1 e8 10             	shr    $0x10,%eax
80107576:	88 45 f7             	mov    %al,-0x9(%ebp)
80107579:	e8 35 c4 ff ff       	call   801039b3 <mycpu>
8010757e:	83 c0 08             	add    $0x8,%eax
80107581:	c1 e8 18             	shr    $0x18,%eax
80107584:	89 c2                	mov    %eax,%edx
80107586:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
8010758d:	67 00 
8010758f:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107596:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
8010759a:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
801075a0:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801075a7:	83 e0 f0             	and    $0xfffffff0,%eax
801075aa:	83 c8 09             	or     $0x9,%eax
801075ad:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801075b3:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801075ba:	83 c8 10             	or     $0x10,%eax
801075bd:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801075c3:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801075ca:	83 e0 9f             	and    $0xffffff9f,%eax
801075cd:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801075d3:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801075da:	83 c8 80             	or     $0xffffff80,%eax
801075dd:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801075e3:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801075ea:	83 e0 f0             	and    $0xfffffff0,%eax
801075ed:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801075f3:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801075fa:	83 e0 ef             	and    $0xffffffef,%eax
801075fd:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107603:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010760a:	83 e0 df             	and    $0xffffffdf,%eax
8010760d:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107613:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010761a:	83 c8 40             	or     $0x40,%eax
8010761d:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107623:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010762a:	83 e0 7f             	and    $0x7f,%eax
8010762d:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107633:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107639:	e8 75 c3 ff ff       	call   801039b3 <mycpu>
8010763e:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107645:	83 e2 ef             	and    $0xffffffef,%edx
80107648:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
8010764e:	e8 60 c3 ff ff       	call   801039b3 <mycpu>
80107653:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107659:	8b 45 08             	mov    0x8(%ebp),%eax
8010765c:	8b 40 08             	mov    0x8(%eax),%eax
8010765f:	89 c3                	mov    %eax,%ebx
80107661:	e8 4d c3 ff ff       	call   801039b3 <mycpu>
80107666:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
8010766c:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
8010766f:	e8 3f c3 ff ff       	call   801039b3 <mycpu>
80107674:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
8010767a:	83 ec 0c             	sub    $0xc,%esp
8010767d:	6a 28                	push   $0x28
8010767f:	e8 cc f8 ff ff       	call   80106f50 <ltr>
80107684:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107687:	8b 45 08             	mov    0x8(%ebp),%eax
8010768a:	8b 40 04             	mov    0x4(%eax),%eax
8010768d:	05 00 00 00 80       	add    $0x80000000,%eax
80107692:	83 ec 0c             	sub    $0xc,%esp
80107695:	50                   	push   %eax
80107696:	e8 cc f8 ff ff       	call   80106f67 <lcr3>
8010769b:	83 c4 10             	add    $0x10,%esp
  popcli();
8010769e:	e8 4b d3 ff ff       	call   801049ee <popcli>
}
801076a3:	90                   	nop
801076a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801076a7:	5b                   	pop    %ebx
801076a8:	5e                   	pop    %esi
801076a9:	5d                   	pop    %ebp
801076aa:	c3                   	ret    

801076ab <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801076ab:	55                   	push   %ebp
801076ac:	89 e5                	mov    %esp,%ebp
801076ae:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
801076b1:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801076b8:	76 0d                	jbe    801076c7 <inituvm+0x1c>
    panic("inituvm: more than a page");
801076ba:	83 ec 0c             	sub    $0xc,%esp
801076bd:	68 8d a7 10 80       	push   $0x8010a78d
801076c2:	e8 e2 8e ff ff       	call   801005a9 <panic>
  mem = kalloc();
801076c7:	e8 cf b0 ff ff       	call   8010279b <kalloc>
801076cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801076cf:	83 ec 04             	sub    $0x4,%esp
801076d2:	68 00 10 00 00       	push   $0x1000
801076d7:	6a 00                	push   $0x0
801076d9:	ff 75 f4             	push   -0xc(%ebp)
801076dc:	e8 cb d3 ff ff       	call   80104aac <memset>
801076e1:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801076e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076e7:	05 00 00 00 80       	add    $0x80000000,%eax
801076ec:	83 ec 0c             	sub    $0xc,%esp
801076ef:	6a 06                	push   $0x6
801076f1:	50                   	push   %eax
801076f2:	68 00 10 00 00       	push   $0x1000
801076f7:	6a 00                	push   $0x0
801076f9:	ff 75 08             	push   0x8(%ebp)
801076fc:	e8 5e fc ff ff       	call   8010735f <mappages>
80107701:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107704:	83 ec 04             	sub    $0x4,%esp
80107707:	ff 75 10             	push   0x10(%ebp)
8010770a:	ff 75 0c             	push   0xc(%ebp)
8010770d:	ff 75 f4             	push   -0xc(%ebp)
80107710:	e8 56 d4 ff ff       	call   80104b6b <memmove>
80107715:	83 c4 10             	add    $0x10,%esp
}
80107718:	90                   	nop
80107719:	c9                   	leave  
8010771a:	c3                   	ret    

8010771b <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010771b:	55                   	push   %ebp
8010771c:	89 e5                	mov    %esp,%ebp
8010771e:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107721:	8b 45 0c             	mov    0xc(%ebp),%eax
80107724:	25 ff 0f 00 00       	and    $0xfff,%eax
80107729:	85 c0                	test   %eax,%eax
8010772b:	74 0d                	je     8010773a <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
8010772d:	83 ec 0c             	sub    $0xc,%esp
80107730:	68 a8 a7 10 80       	push   $0x8010a7a8
80107735:	e8 6f 8e ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
8010773a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107741:	e9 8f 00 00 00       	jmp    801077d5 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107746:	8b 55 0c             	mov    0xc(%ebp),%edx
80107749:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010774c:	01 d0                	add    %edx,%eax
8010774e:	83 ec 04             	sub    $0x4,%esp
80107751:	6a 00                	push   $0x0
80107753:	50                   	push   %eax
80107754:	ff 75 08             	push   0x8(%ebp)
80107757:	e8 6d fb ff ff       	call   801072c9 <walkpgdir>
8010775c:	83 c4 10             	add    $0x10,%esp
8010775f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107762:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107766:	75 0d                	jne    80107775 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80107768:	83 ec 0c             	sub    $0xc,%esp
8010776b:	68 cb a7 10 80       	push   $0x8010a7cb
80107770:	e8 34 8e ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107775:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107778:	8b 00                	mov    (%eax),%eax
8010777a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010777f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107782:	8b 45 18             	mov    0x18(%ebp),%eax
80107785:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107788:	3d ff 0f 00 00       	cmp    $0xfff,%eax
8010778d:	77 0b                	ja     8010779a <loaduvm+0x7f>
      n = sz - i;
8010778f:	8b 45 18             	mov    0x18(%ebp),%eax
80107792:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107795:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107798:	eb 07                	jmp    801077a1 <loaduvm+0x86>
    else
      n = PGSIZE;
8010779a:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
801077a1:	8b 55 14             	mov    0x14(%ebp),%edx
801077a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077a7:	01 d0                	add    %edx,%eax
801077a9:	8b 55 e8             	mov    -0x18(%ebp),%edx
801077ac:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801077b2:	ff 75 f0             	push   -0x10(%ebp)
801077b5:	50                   	push   %eax
801077b6:	52                   	push   %edx
801077b7:	ff 75 10             	push   0x10(%ebp)
801077ba:	e8 12 a7 ff ff       	call   80101ed1 <readi>
801077bf:	83 c4 10             	add    $0x10,%esp
801077c2:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801077c5:	74 07                	je     801077ce <loaduvm+0xb3>
      return -1;
801077c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801077cc:	eb 18                	jmp    801077e6 <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
801077ce:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801077d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077d8:	3b 45 18             	cmp    0x18(%ebp),%eax
801077db:	0f 82 65 ff ff ff    	jb     80107746 <loaduvm+0x2b>
  }
  return 0;
801077e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801077e6:	c9                   	leave  
801077e7:	c3                   	ret    

801077e8 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801077e8:	55                   	push   %ebp
801077e9:	89 e5                	mov    %esp,%ebp
801077eb:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz > KERNBASE)
801077ee:	81 7d 10 00 00 00 80 	cmpl   $0x80000000,0x10(%ebp)
801077f5:	76 0a                	jbe    80107801 <allocuvm+0x19>
    return 0;
801077f7:	b8 00 00 00 00       	mov    $0x0,%eax
801077fc:	e9 ec 00 00 00       	jmp    801078ed <allocuvm+0x105>
  if(newsz < oldsz)
80107801:	8b 45 10             	mov    0x10(%ebp),%eax
80107804:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107807:	73 08                	jae    80107811 <allocuvm+0x29>
    return oldsz;
80107809:	8b 45 0c             	mov    0xc(%ebp),%eax
8010780c:	e9 dc 00 00 00       	jmp    801078ed <allocuvm+0x105>

  a = PGROUNDUP(oldsz);
80107811:	8b 45 0c             	mov    0xc(%ebp),%eax
80107814:	05 ff 0f 00 00       	add    $0xfff,%eax
80107819:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010781e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107821:	e9 b8 00 00 00       	jmp    801078de <allocuvm+0xf6>
    mem = kalloc();
80107826:	e8 70 af ff ff       	call   8010279b <kalloc>
8010782b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010782e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107832:	75 2e                	jne    80107862 <allocuvm+0x7a>
      cprintf("allocuvm out of memory\n");
80107834:	83 ec 0c             	sub    $0xc,%esp
80107837:	68 e9 a7 10 80       	push   $0x8010a7e9
8010783c:	e8 b3 8b ff ff       	call   801003f4 <cprintf>
80107841:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107844:	83 ec 04             	sub    $0x4,%esp
80107847:	ff 75 0c             	push   0xc(%ebp)
8010784a:	ff 75 10             	push   0x10(%ebp)
8010784d:	ff 75 08             	push   0x8(%ebp)
80107850:	e8 9a 00 00 00       	call   801078ef <deallocuvm>
80107855:	83 c4 10             	add    $0x10,%esp
      return 0;
80107858:	b8 00 00 00 00       	mov    $0x0,%eax
8010785d:	e9 8b 00 00 00       	jmp    801078ed <allocuvm+0x105>
    }
    memset(mem, 0, PGSIZE);
80107862:	83 ec 04             	sub    $0x4,%esp
80107865:	68 00 10 00 00       	push   $0x1000
8010786a:	6a 00                	push   $0x0
8010786c:	ff 75 f0             	push   -0x10(%ebp)
8010786f:	e8 38 d2 ff ff       	call   80104aac <memset>
80107874:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107877:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010787a:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107880:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107883:	83 ec 0c             	sub    $0xc,%esp
80107886:	6a 06                	push   $0x6
80107888:	52                   	push   %edx
80107889:	68 00 10 00 00       	push   $0x1000
8010788e:	50                   	push   %eax
8010788f:	ff 75 08             	push   0x8(%ebp)
80107892:	e8 c8 fa ff ff       	call   8010735f <mappages>
80107897:	83 c4 20             	add    $0x20,%esp
8010789a:	85 c0                	test   %eax,%eax
8010789c:	79 39                	jns    801078d7 <allocuvm+0xef>
      cprintf("allocuvm out of memory (2)\n");
8010789e:	83 ec 0c             	sub    $0xc,%esp
801078a1:	68 01 a8 10 80       	push   $0x8010a801
801078a6:	e8 49 8b ff ff       	call   801003f4 <cprintf>
801078ab:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801078ae:	83 ec 04             	sub    $0x4,%esp
801078b1:	ff 75 0c             	push   0xc(%ebp)
801078b4:	ff 75 10             	push   0x10(%ebp)
801078b7:	ff 75 08             	push   0x8(%ebp)
801078ba:	e8 30 00 00 00       	call   801078ef <deallocuvm>
801078bf:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
801078c2:	83 ec 0c             	sub    $0xc,%esp
801078c5:	ff 75 f0             	push   -0x10(%ebp)
801078c8:	e8 34 ae ff ff       	call   80102701 <kfree>
801078cd:	83 c4 10             	add    $0x10,%esp
      return 0;
801078d0:	b8 00 00 00 00       	mov    $0x0,%eax
801078d5:	eb 16                	jmp    801078ed <allocuvm+0x105>
  for(; a < newsz; a += PGSIZE){
801078d7:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801078de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e1:	3b 45 10             	cmp    0x10(%ebp),%eax
801078e4:	0f 82 3c ff ff ff    	jb     80107826 <allocuvm+0x3e>
    }
  }
  return newsz;
801078ea:	8b 45 10             	mov    0x10(%ebp),%eax
}
801078ed:	c9                   	leave  
801078ee:	c3                   	ret    

801078ef <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801078ef:	55                   	push   %ebp
801078f0:	89 e5                	mov    %esp,%ebp
801078f2:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801078f5:	8b 45 10             	mov    0x10(%ebp),%eax
801078f8:	3b 45 0c             	cmp    0xc(%ebp),%eax
801078fb:	72 08                	jb     80107905 <deallocuvm+0x16>
    return oldsz;
801078fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80107900:	e9 ac 00 00 00       	jmp    801079b1 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80107905:	8b 45 10             	mov    0x10(%ebp),%eax
80107908:	05 ff 0f 00 00       	add    $0xfff,%eax
8010790d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107912:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107915:	e9 88 00 00 00       	jmp    801079a2 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010791a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010791d:	83 ec 04             	sub    $0x4,%esp
80107920:	6a 00                	push   $0x0
80107922:	50                   	push   %eax
80107923:	ff 75 08             	push   0x8(%ebp)
80107926:	e8 9e f9 ff ff       	call   801072c9 <walkpgdir>
8010792b:	83 c4 10             	add    $0x10,%esp
8010792e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107931:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107935:	75 16                	jne    8010794d <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107937:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010793a:	c1 e8 16             	shr    $0x16,%eax
8010793d:	83 c0 01             	add    $0x1,%eax
80107940:	c1 e0 16             	shl    $0x16,%eax
80107943:	2d 00 10 00 00       	sub    $0x1000,%eax
80107948:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010794b:	eb 4e                	jmp    8010799b <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
8010794d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107950:	8b 00                	mov    (%eax),%eax
80107952:	83 e0 01             	and    $0x1,%eax
80107955:	85 c0                	test   %eax,%eax
80107957:	74 42                	je     8010799b <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80107959:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010795c:	8b 00                	mov    (%eax),%eax
8010795e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107963:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107966:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010796a:	75 0d                	jne    80107979 <deallocuvm+0x8a>
        panic("kfree");
8010796c:	83 ec 0c             	sub    $0xc,%esp
8010796f:	68 1d a8 10 80       	push   $0x8010a81d
80107974:	e8 30 8c ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
80107979:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010797c:	05 00 00 00 80       	add    $0x80000000,%eax
80107981:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107984:	83 ec 0c             	sub    $0xc,%esp
80107987:	ff 75 e8             	push   -0x18(%ebp)
8010798a:	e8 72 ad ff ff       	call   80102701 <kfree>
8010798f:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107992:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107995:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
8010799b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801079a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a5:	3b 45 0c             	cmp    0xc(%ebp),%eax
801079a8:	0f 82 6c ff ff ff    	jb     8010791a <deallocuvm+0x2b>
    }
  }
  return newsz;
801079ae:	8b 45 10             	mov    0x10(%ebp),%eax
}
801079b1:	c9                   	leave  
801079b2:	c3                   	ret    

801079b3 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801079b3:	55                   	push   %ebp
801079b4:	89 e5                	mov    %esp,%ebp
801079b6:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801079b9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801079bd:	75 0d                	jne    801079cc <freevm+0x19>
    panic("freevm: no pgdir");
801079bf:	83 ec 0c             	sub    $0xc,%esp
801079c2:	68 23 a8 10 80       	push   $0x8010a823
801079c7:	e8 dd 8b ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801079cc:	83 ec 04             	sub    $0x4,%esp
801079cf:	6a 00                	push   $0x0
801079d1:	68 00 00 00 80       	push   $0x80000000
801079d6:	ff 75 08             	push   0x8(%ebp)
801079d9:	e8 11 ff ff ff       	call   801078ef <deallocuvm>
801079de:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801079e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801079e8:	eb 48                	jmp    80107a32 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
801079ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ed:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801079f4:	8b 45 08             	mov    0x8(%ebp),%eax
801079f7:	01 d0                	add    %edx,%eax
801079f9:	8b 00                	mov    (%eax),%eax
801079fb:	83 e0 01             	and    $0x1,%eax
801079fe:	85 c0                	test   %eax,%eax
80107a00:	74 2c                	je     80107a2e <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107a02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a05:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107a0c:	8b 45 08             	mov    0x8(%ebp),%eax
80107a0f:	01 d0                	add    %edx,%eax
80107a11:	8b 00                	mov    (%eax),%eax
80107a13:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107a18:	05 00 00 00 80       	add    $0x80000000,%eax
80107a1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107a20:	83 ec 0c             	sub    $0xc,%esp
80107a23:	ff 75 f0             	push   -0x10(%ebp)
80107a26:	e8 d6 ac ff ff       	call   80102701 <kfree>
80107a2b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107a2e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107a32:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107a39:	76 af                	jbe    801079ea <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80107a3b:	83 ec 0c             	sub    $0xc,%esp
80107a3e:	ff 75 08             	push   0x8(%ebp)
80107a41:	e8 bb ac ff ff       	call   80102701 <kfree>
80107a46:	83 c4 10             	add    $0x10,%esp
}
80107a49:	90                   	nop
80107a4a:	c9                   	leave  
80107a4b:	c3                   	ret    

80107a4c <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107a4c:	55                   	push   %ebp
80107a4d:	89 e5                	mov    %esp,%ebp
80107a4f:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107a52:	83 ec 04             	sub    $0x4,%esp
80107a55:	6a 00                	push   $0x0
80107a57:	ff 75 0c             	push   0xc(%ebp)
80107a5a:	ff 75 08             	push   0x8(%ebp)
80107a5d:	e8 67 f8 ff ff       	call   801072c9 <walkpgdir>
80107a62:	83 c4 10             	add    $0x10,%esp
80107a65:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107a68:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107a6c:	75 0d                	jne    80107a7b <clearpteu+0x2f>
    panic("clearpteu");
80107a6e:	83 ec 0c             	sub    $0xc,%esp
80107a71:	68 34 a8 10 80       	push   $0x8010a834
80107a76:	e8 2e 8b ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
80107a7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7e:	8b 00                	mov    (%eax),%eax
80107a80:	83 e0 fb             	and    $0xfffffffb,%eax
80107a83:	89 c2                	mov    %eax,%edx
80107a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a88:	89 10                	mov    %edx,(%eax)
}
80107a8a:	90                   	nop
80107a8b:	c9                   	leave  
80107a8c:	c3                   	ret    

80107a8d <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107a8d:	55                   	push   %ebp
80107a8e:	89 e5                	mov    %esp,%ebp
80107a90:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107a93:	e8 57 f9 ff ff       	call   801073ef <setupkvm>
80107a98:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107a9b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107a9f:	75 0a                	jne    80107aab <copyuvm+0x1e>
    return 0;
80107aa1:	b8 00 00 00 00       	mov    $0x0,%eax
80107aa6:	e9 d6 00 00 00       	jmp    80107b81 <copyuvm+0xf4>
  for(i = 0; i < KERNBASE; i += PGSIZE){
80107aab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107ab2:	e9 a3 00 00 00       	jmp    80107b5a <copyuvm+0xcd>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107ab7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aba:	83 ec 04             	sub    $0x4,%esp
80107abd:	6a 00                	push   $0x0
80107abf:	50                   	push   %eax
80107ac0:	ff 75 08             	push   0x8(%ebp)
80107ac3:	e8 01 f8 ff ff       	call   801072c9 <walkpgdir>
80107ac8:	83 c4 10             	add    $0x10,%esp
80107acb:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107ace:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107ad2:	74 7b                	je     80107b4f <copyuvm+0xc2>
    {
      //panic("copyuvm: pte should exist");
      continue;
    }
    if(!(*pte & PTE_P))
80107ad4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ad7:	8b 00                	mov    (%eax),%eax
80107ad9:	83 e0 01             	and    $0x1,%eax
80107adc:	85 c0                	test   %eax,%eax
80107ade:	74 72                	je     80107b52 <copyuvm+0xc5>
    {
      //panic("copyuvm: page not present");
      continue;
    }
    pa = PTE_ADDR(*pte);
80107ae0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ae3:	8b 00                	mov    (%eax),%eax
80107ae5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107aea:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107aed:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107af0:	8b 00                	mov    (%eax),%eax
80107af2:	25 ff 0f 00 00       	and    $0xfff,%eax
80107af7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107afa:	e8 9c ac ff ff       	call   8010279b <kalloc>
80107aff:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107b02:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107b06:	74 62                	je     80107b6a <copyuvm+0xdd>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107b08:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107b0b:	05 00 00 00 80       	add    $0x80000000,%eax
80107b10:	83 ec 04             	sub    $0x4,%esp
80107b13:	68 00 10 00 00       	push   $0x1000
80107b18:	50                   	push   %eax
80107b19:	ff 75 e0             	push   -0x20(%ebp)
80107b1c:	e8 4a d0 ff ff       	call   80104b6b <memmove>
80107b21:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107b24:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107b27:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107b2a:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b33:	83 ec 0c             	sub    $0xc,%esp
80107b36:	52                   	push   %edx
80107b37:	51                   	push   %ecx
80107b38:	68 00 10 00 00       	push   $0x1000
80107b3d:	50                   	push   %eax
80107b3e:	ff 75 f0             	push   -0x10(%ebp)
80107b41:	e8 19 f8 ff ff       	call   8010735f <mappages>
80107b46:	83 c4 20             	add    $0x20,%esp
80107b49:	85 c0                	test   %eax,%eax
80107b4b:	78 20                	js     80107b6d <copyuvm+0xe0>
80107b4d:	eb 04                	jmp    80107b53 <copyuvm+0xc6>
      continue;
80107b4f:	90                   	nop
80107b50:	eb 01                	jmp    80107b53 <copyuvm+0xc6>
      continue;
80107b52:	90                   	nop
  for(i = 0; i < KERNBASE; i += PGSIZE){
80107b53:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b5d:	85 c0                	test   %eax,%eax
80107b5f:	0f 89 52 ff ff ff    	jns    80107ab7 <copyuvm+0x2a>
      goto bad;
  }
  return d;
80107b65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b68:	eb 17                	jmp    80107b81 <copyuvm+0xf4>
      goto bad;
80107b6a:	90                   	nop
80107b6b:	eb 01                	jmp    80107b6e <copyuvm+0xe1>
      goto bad;
80107b6d:	90                   	nop

bad:
  freevm(d);
80107b6e:	83 ec 0c             	sub    $0xc,%esp
80107b71:	ff 75 f0             	push   -0x10(%ebp)
80107b74:	e8 3a fe ff ff       	call   801079b3 <freevm>
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
80107b94:	e8 30 f7 ff ff       	call   801072c9 <walkpgdir>
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
80107c44:	e8 22 cf ff ff       	call   80104b6b <memmove>
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
80107ca1:	c7 05 40 6d 19 80 00 	movl   $0x0,0x80196d40
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
80107cce:	8b 04 85 40 a8 10 80 	mov    -0x7fef57c0(,%eax,4),%eax
80107cd5:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80107cd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cda:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80107cdd:	a1 40 6d 19 80       	mov    0x80196d40,%eax
80107ce2:	83 f8 03             	cmp    $0x3,%eax
80107ce5:	7f 28                	jg     80107d0f <mpinit_uefi+0x9b>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80107ce7:	8b 15 40 6d 19 80    	mov    0x80196d40,%edx
80107ced:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107cf0:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80107cf4:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80107cfa:	81 c2 80 6a 19 80    	add    $0x80196a80,%edx
80107d00:	88 02                	mov    %al,(%edx)
          ncpu++;
80107d02:	a1 40 6d 19 80       	mov    0x80196d40,%eax
80107d07:	83 c0 01             	add    $0x1,%eax
80107d0a:	a3 40 6d 19 80       	mov    %eax,0x80196d40
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
80107d2b:	a2 44 6d 19 80       	mov    %al,0x80196d44
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
80107e36:	e8 f7 ac ff ff       	call   80102b32 <microdelay>
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
80107ec4:	a3 48 6d 19 80       	mov    %eax,0x80196d48
  gpu.vram_size = boot_param->graphic_config.frame_size;
80107ec9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107ecc:	8b 50 1c             	mov    0x1c(%eax),%edx
80107ecf:	8b 40 18             	mov    0x18(%eax),%eax
80107ed2:	a3 50 6d 19 80       	mov    %eax,0x80196d50
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80107ed7:	8b 15 50 6d 19 80    	mov    0x80196d50,%edx
80107edd:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
80107ee2:	29 d0                	sub    %edx,%eax
80107ee4:	a3 4c 6d 19 80       	mov    %eax,0x80196d4c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80107ee9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107eec:	8b 50 24             	mov    0x24(%eax),%edx
80107eef:	8b 40 20             	mov    0x20(%eax),%eax
80107ef2:	a3 54 6d 19 80       	mov    %eax,0x80196d54
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80107ef7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107efa:	8b 50 2c             	mov    0x2c(%eax),%edx
80107efd:	8b 40 28             	mov    0x28(%eax),%eax
80107f00:	a3 58 6d 19 80       	mov    %eax,0x80196d58
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80107f05:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107f08:	8b 50 34             	mov    0x34(%eax),%edx
80107f0b:	8b 40 30             	mov    0x30(%eax),%eax
80107f0e:	a3 5c 6d 19 80       	mov    %eax,0x80196d5c
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
80107f1c:	8b 15 5c 6d 19 80    	mov    0x80196d5c,%edx
80107f22:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f25:	0f af d0             	imul   %eax,%edx
80107f28:	8b 45 08             	mov    0x8(%ebp),%eax
80107f2b:	01 d0                	add    %edx,%eax
80107f2d:	c1 e0 02             	shl    $0x2,%eax
80107f30:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80107f33:	8b 15 4c 6d 19 80    	mov    0x80196d4c,%edx
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
80107f6f:	8b 15 5c 6d 19 80    	mov    0x80196d5c,%edx
80107f75:	8b 45 08             	mov    0x8(%ebp),%eax
80107f78:	0f af c2             	imul   %edx,%eax
80107f7b:	c1 e0 02             	shl    $0x2,%eax
80107f7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80107f81:	a1 50 6d 19 80       	mov    0x80196d50,%eax
80107f86:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107f89:	29 d0                	sub    %edx,%eax
80107f8b:	8b 0d 4c 6d 19 80    	mov    0x80196d4c,%ecx
80107f91:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107f94:	01 ca                	add    %ecx,%edx
80107f96:	89 d1                	mov    %edx,%ecx
80107f98:	8b 15 4c 6d 19 80    	mov    0x80196d4c,%edx
80107f9e:	83 ec 04             	sub    $0x4,%esp
80107fa1:	50                   	push   %eax
80107fa2:	51                   	push   %ecx
80107fa3:	52                   	push   %edx
80107fa4:	e8 c2 cb ff ff       	call   80104b6b <memmove>
80107fa9:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80107fac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107faf:	8b 0d 4c 6d 19 80    	mov    0x80196d4c,%ecx
80107fb5:	8b 15 50 6d 19 80    	mov    0x80196d50,%edx
80107fbb:	01 ca                	add    %ecx,%edx
80107fbd:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80107fc0:	29 ca                	sub    %ecx,%edx
80107fc2:	83 ec 04             	sub    $0x4,%esp
80107fc5:	50                   	push   %eax
80107fc6:	6a 00                	push   $0x0
80107fc8:	52                   	push   %edx
80107fc9:	e8 de ca ff ff       	call   80104aac <memset>
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
80108001:	0f b7 84 00 60 a8 10 	movzwl -0x7fef57a0(%eax,%eax,1),%eax
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
80108077:	68 60 6d 19 80       	push   $0x80196d60
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
801081cb:	e8 62 a9 ff ff       	call   80102b32 <microdelay>
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
801082a8:	a2 64 6d 19 80       	mov    %al,0x80196d64
  dev.device_num = device_num;
801082ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801082b0:	a2 65 6d 19 80       	mov    %al,0x80196d65
  dev.function_num = function_num;
801082b5:	8b 45 10             	mov    0x10(%ebp),%eax
801082b8:	a2 66 6d 19 80       	mov    %al,0x80196d66
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
801082bd:	ff 75 10             	push   0x10(%ebp)
801082c0:	ff 75 0c             	push   0xc(%ebp)
801082c3:	ff 75 08             	push   0x8(%ebp)
801082c6:	68 a4 be 10 80       	push   $0x8010bea4
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
80108304:	a3 68 6d 19 80       	mov    %eax,0x80196d68
  dev.vendor_id = vendor_id;
80108309:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010830c:	a3 6c 6d 19 80       	mov    %eax,0x80196d6c
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108311:	83 ec 04             	sub    $0x4,%esp
80108314:	ff 75 f0             	push   -0x10(%ebp)
80108317:	ff 75 f4             	push   -0xc(%ebp)
8010831a:	68 d8 be 10 80       	push   $0x8010bed8
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
80108366:	68 fc be 10 80       	push   $0x8010befc
8010836b:	e8 84 80 ff ff       	call   801003f4 <cprintf>
80108370:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108373:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108376:	c1 e8 18             	shr    $0x18,%eax
80108379:	a2 70 6d 19 80       	mov    %al,0x80196d70
  dev.sub_class = (data>>16)&0xFF;
8010837e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108381:	c1 e8 10             	shr    $0x10,%eax
80108384:	a2 71 6d 19 80       	mov    %al,0x80196d71
  dev.interface = (data>>8)&0xFF;
80108389:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010838c:	c1 e8 08             	shr    $0x8,%eax
8010838f:	a2 72 6d 19 80       	mov    %al,0x80196d72
  dev.revision_id = data&0xFF;
80108394:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108397:	a2 73 6d 19 80       	mov    %al,0x80196d73
  
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
801083b9:	a3 74 6d 19 80       	mov    %eax,0x80196d74
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
801083db:	a3 78 6d 19 80       	mov    %eax,0x80196d78
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
801083e0:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
801083e7:	75 5a                	jne    80108443 <pci_init_device+0x1a5>
801083e9:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
801083f0:	75 51                	jne    80108443 <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
801083f2:	83 ec 0c             	sub    $0xc,%esp
801083f5:	68 41 bf 10 80       	push   $0x8010bf41
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
80108426:	68 5b bf 10 80       	push   $0x8010bf5b
8010842b:	e8 c4 7f ff ff       	call   801003f4 <cprintf>
80108430:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108433:	83 ec 0c             	sub    $0xc,%esp
80108436:	68 64 6d 19 80       	push   $0x80196d64
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
801084c6:	a3 7c 6d 19 80       	mov    %eax,0x80196d7c
  uint *ctrl = (uint *)base_addr;
801084cb:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801084d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
801084d3:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
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
8010851f:	68 70 bf 10 80       	push   $0x8010bf70
80108524:	e8 cb 7e ff ff       	call   801003f4 <cprintf>
80108529:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
8010852c:	e8 6a a2 ff ff       	call   8010279b <kalloc>
80108531:	a3 88 6d 19 80       	mov    %eax,0x80196d88
  *intr_addr = 0;
80108536:	a1 88 6d 19 80       	mov    0x80196d88,%eax
8010853b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108541:	a1 88 6d 19 80       	mov    0x80196d88,%eax
80108546:	83 ec 08             	sub    $0x8,%esp
80108549:	50                   	push   %eax
8010854a:	68 92 bf 10 80       	push   $0x8010bf92
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
80108590:	68 a0 bf 10 80       	push   $0x8010bfa0
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
801085c8:	a2 80 6d 19 80       	mov    %al,0x80196d80
  mac_addr[1] = data_l>>8;
801085cd:	8b 45 d8             	mov    -0x28(%ebp),%eax
801085d0:	c1 e8 08             	shr    $0x8,%eax
801085d3:	a2 81 6d 19 80       	mov    %al,0x80196d81
  uint data_m = i8254_read_eeprom(0x1);
801085d8:	83 ec 0c             	sub    $0xc,%esp
801085db:	6a 01                	push   $0x1
801085dd:	e8 c5 04 00 00       	call   80108aa7 <i8254_read_eeprom>
801085e2:	83 c4 10             	add    $0x10,%esp
801085e5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
801085e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801085eb:	a2 82 6d 19 80       	mov    %al,0x80196d82
  mac_addr[3] = data_m>>8;
801085f0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801085f3:	c1 e8 08             	shr    $0x8,%eax
801085f6:	a2 83 6d 19 80       	mov    %al,0x80196d83
  uint data_h = i8254_read_eeprom(0x2);
801085fb:	83 ec 0c             	sub    $0xc,%esp
801085fe:	6a 02                	push   $0x2
80108600:	e8 a2 04 00 00       	call   80108aa7 <i8254_read_eeprom>
80108605:	83 c4 10             	add    $0x10,%esp
80108608:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
8010860b:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010860e:	a2 84 6d 19 80       	mov    %al,0x80196d84
  mac_addr[5] = data_h>>8;
80108613:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108616:	c1 e8 08             	shr    $0x8,%eax
80108619:	a2 85 6d 19 80       	mov    %al,0x80196d85
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
8010861e:	0f b6 05 85 6d 19 80 	movzbl 0x80196d85,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108625:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108628:	0f b6 05 84 6d 19 80 	movzbl 0x80196d84,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010862f:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108632:	0f b6 05 83 6d 19 80 	movzbl 0x80196d83,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108639:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
8010863c:	0f b6 05 82 6d 19 80 	movzbl 0x80196d82,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108643:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108646:	0f b6 05 81 6d 19 80 	movzbl 0x80196d81,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010864d:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108650:	0f b6 05 80 6d 19 80 	movzbl 0x80196d80,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108657:	0f b6 c0             	movzbl %al,%eax
8010865a:	83 ec 04             	sub    $0x4,%esp
8010865d:	57                   	push   %edi
8010865e:	56                   	push   %esi
8010865f:	53                   	push   %ebx
80108660:	51                   	push   %ecx
80108661:	52                   	push   %edx
80108662:	50                   	push   %eax
80108663:	68 b8 bf 10 80       	push   $0x8010bfb8
80108668:	e8 87 7d ff ff       	call   801003f4 <cprintf>
8010866d:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108670:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108675:	05 00 54 00 00       	add    $0x5400,%eax
8010867a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
8010867d:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
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
801086a9:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
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
801086de:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801086e3:	05 d0 00 00 00       	add    $0xd0,%eax
801086e8:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
801086eb:	8b 45 c0             	mov    -0x40(%ebp),%eax
801086ee:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
801086f4:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801086f9:	05 c8 00 00 00       	add    $0xc8,%eax
801086fe:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108701:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108704:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
8010870a:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
8010870f:	05 28 28 00 00       	add    $0x2828,%eax
80108714:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108717:	8b 45 b8             	mov    -0x48(%ebp),%eax
8010871a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108720:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108725:	05 00 01 00 00       	add    $0x100,%eax
8010872a:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
8010872d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108730:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108736:	e8 60 a0 ff ff       	call   8010279b <kalloc>
8010873b:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
8010873e:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108743:	05 00 28 00 00       	add    $0x2800,%eax
80108748:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
8010874b:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108750:	05 04 28 00 00       	add    $0x2804,%eax
80108755:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108758:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
8010875d:	05 08 28 00 00       	add    $0x2808,%eax
80108762:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108765:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
8010876a:	05 10 28 00 00       	add    $0x2810,%eax
8010876f:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108772:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
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
80108845:	e8 51 9f ff ff       	call   8010279b <kalloc>
8010884a:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
8010884d:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108851:	75 12                	jne    80108865 <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80108853:	83 ec 0c             	sub    $0xc,%esp
80108856:	68 d8 bf 10 80       	push   $0x8010bfd8
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
801088b4:	68 f8 bf 10 80       	push   $0x8010bff8
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
801088d0:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801088d5:	05 28 38 00 00       	add    $0x3828,%eax
801088da:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
801088dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088e0:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
801088e6:	e8 b0 9e ff ff       	call   8010279b <kalloc>
801088eb:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
801088ee:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801088f3:	05 00 38 00 00       	add    $0x3800,%eax
801088f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
801088fb:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108900:	05 04 38 00 00       	add    $0x3804,%eax
80108905:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108908:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
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
80108935:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
8010893a:	05 10 38 00 00       	add    $0x3810,%eax
8010893f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108942:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
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
80108a0b:	e8 8b 9d ff ff       	call   8010279b <kalloc>
80108a10:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108a13:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108a17:	75 12                	jne    80108a2b <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
80108a19:	83 ec 0c             	sub    $0xc,%esp
80108a1c:	68 d8 bf 10 80       	push   $0x8010bfd8
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
80108a68:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108a6d:	05 00 04 00 00       	add    $0x400,%eax
80108a72:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108a75:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108a78:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108a7e:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108a83:	05 10 04 00 00       	add    $0x410,%eax
80108a88:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108a8b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108a8e:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108a94:	83 ec 0c             	sub    $0xc,%esp
80108a97:	68 18 c0 10 80       	push   $0x8010c018
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
80108aad:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
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
80108ace:	68 38 c0 10 80       	push   $0x8010c038
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
80108b00:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108b05:	05 10 28 00 00       	add    $0x2810,%eax
80108b0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108b0d:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108b12:	05 18 28 00 00       	add    $0x2818,%eax
80108b17:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108b1a:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
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
80108baa:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108baf:	05 10 38 00 00       	add    $0x3810,%eax
80108bb4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108bb7:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108bbc:	05 18 38 00 00       	add    $0x3818,%eax
80108bc1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108bc4:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
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
80108c30:	e8 36 bf ff ff       	call   80104b6b <memmove>
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
80108cc2:	a1 88 6d 19 80       	mov    0x80196d88,%eax
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
80108d44:	e8 ca bd ff ff       	call   80104b13 <memcmp>
80108d49:	83 c4 10             	add    $0x10,%esp
80108d4c:	85 c0                	test   %eax,%eax
80108d4e:	74 27                	je     80108d77 <arp_proc+0xa7>
80108d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d53:	83 c0 0e             	add    $0xe,%eax
80108d56:	83 ec 04             	sub    $0x4,%esp
80108d59:	6a 04                	push   $0x4
80108d5b:	50                   	push   %eax
80108d5c:	68 e4 f4 10 80       	push   $0x8010f4e4
80108d61:	e8 ad bd ff ff       	call   80104b13 <memcmp>
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
80108d95:	e8 79 bd ff ff       	call   80104b13 <memcmp>
80108d9a:	83 c4 10             	add    $0x10,%esp
80108d9d:	85 c0                	test   %eax,%eax
80108d9f:	75 4c                	jne    80108ded <arp_proc+0x11d>
    uint send = (uint)kalloc();
80108da1:	e8 f5 99 ff ff       	call   8010279b <kalloc>
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
80108dde:	e8 1e 99 ff ff       	call   80102701 <kfree>
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
80108e0b:	e8 03 bd ff ff       	call   80104b13 <memcmp>
80108e10:	83 c4 10             	add    $0x10,%esp
80108e13:	85 c0                	test   %eax,%eax
80108e15:	75 25                	jne    80108e3c <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
80108e17:	83 ec 0c             	sub    $0xc,%esp
80108e1a:	68 3c c0 10 80       	push   $0x8010c03c
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
80108e52:	e8 44 99 ff ff       	call   8010279b <kalloc>
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
80108e8b:	e8 a2 9c ff ff       	call   80102b32 <microdelay>
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
80108eb5:	e8 47 98 ff ff       	call   80102701 <kfree>
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
80108f33:	e8 33 bc ff ff       	call   80104b6b <memmove>
80108f38:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80108f3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f3e:	83 c0 06             	add    $0x6,%eax
80108f41:	83 ec 04             	sub    $0x4,%esp
80108f44:	6a 06                	push   $0x6
80108f46:	68 80 6d 19 80       	push   $0x80196d80
80108f4b:	50                   	push   %eax
80108f4c:	e8 1a bc ff ff       	call   80104b6b <memmove>
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
80108f8c:	e8 da bb ff ff       	call   80104b6b <memmove>
80108f91:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80108f94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f97:	8d 50 18             	lea    0x18(%eax),%edx
80108f9a:	83 ec 04             	sub    $0x4,%esp
80108f9d:	6a 04                	push   $0x4
80108f9f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108fa2:	50                   	push   %eax
80108fa3:	52                   	push   %edx
80108fa4:	e8 c2 bb ff ff       	call   80104b6b <memmove>
80108fa9:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80108fac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108faf:	83 c0 08             	add    $0x8,%eax
80108fb2:	83 ec 04             	sub    $0x4,%esp
80108fb5:	6a 06                	push   $0x6
80108fb7:	68 80 6d 19 80       	push   $0x80196d80
80108fbc:	50                   	push   %eax
80108fbd:	e8 a9 bb ff ff       	call   80104b6b <memmove>
80108fc2:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80108fc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fc8:	83 c0 0e             	add    $0xe,%eax
80108fcb:	83 ec 04             	sub    $0x4,%esp
80108fce:	6a 04                	push   $0x4
80108fd0:	68 e4 f4 10 80       	push   $0x8010f4e4
80108fd5:	50                   	push   %eax
80108fd6:	e8 90 bb ff ff       	call   80104b6b <memmove>
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
80109016:	05 a0 6d 19 80       	add    $0x80196da0,%eax
8010901b:	83 c0 04             	add    $0x4,%eax
8010901e:	83 ec 04             	sub    $0x4,%esp
80109021:	6a 06                	push   $0x6
80109023:	51                   	push   %ecx
80109024:	50                   	push   %eax
80109025:	e8 41 bb ff ff       	call   80104b6b <memmove>
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
8010904a:	05 a0 6d 19 80       	add    $0x80196da0,%eax
8010904f:	83 c0 04             	add    $0x4,%eax
80109052:	83 ec 04             	sub    $0x4,%esp
80109055:	6a 06                	push   $0x6
80109057:	51                   	push   %ecx
80109058:	50                   	push   %eax
80109059:	e8 0d bb ff ff       	call   80104b6b <memmove>
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
80109075:	05 a0 6d 19 80       	add    $0x80196da0,%eax
8010907a:	83 ec 04             	sub    $0x4,%esp
8010907d:	6a 04                	push   $0x4
8010907f:	51                   	push   %ecx
80109080:	50                   	push   %eax
80109081:	e8 e5 ba ff ff       	call   80104b6b <memmove>
80109086:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80109089:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010908c:	89 d0                	mov    %edx,%eax
8010908e:	c1 e0 02             	shl    $0x2,%eax
80109091:	01 d0                	add    %edx,%eax
80109093:	01 c0                	add    %eax,%eax
80109095:	01 d0                	add    %edx,%eax
80109097:	05 aa 6d 19 80       	add    $0x80196daa,%eax
8010909c:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
8010909f:	83 ec 0c             	sub    $0xc,%esp
801090a2:	68 a0 6d 19 80       	push   $0x80196da0
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
801090d6:	05 a0 6d 19 80       	add    $0x80196da0,%eax
801090db:	83 ec 04             	sub    $0x4,%esp
801090de:	6a 04                	push   $0x4
801090e0:	ff 75 08             	push   0x8(%ebp)
801090e3:	50                   	push   %eax
801090e4:	e8 2a ba ff ff       	call   80104b13 <memcmp>
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
80109103:	05 aa 6d 19 80       	add    $0x80196daa,%eax
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
8010914f:	05 aa 6d 19 80       	add    $0x80196daa,%eax
80109154:	0f b6 00             	movzbl (%eax),%eax
80109157:	84 c0                	test   %al,%al
80109159:	74 74                	je     801091cf <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
8010915b:	83 ec 08             	sub    $0x8,%esp
8010915e:	ff 75 f4             	push   -0xc(%ebp)
80109161:	68 4f c0 10 80       	push   $0x8010c04f
80109166:	e8 89 72 ff ff       	call   801003f4 <cprintf>
8010916b:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
8010916e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109171:	89 d0                	mov    %edx,%eax
80109173:	c1 e0 02             	shl    $0x2,%eax
80109176:	01 d0                	add    %edx,%eax
80109178:	01 c0                	add    %eax,%eax
8010917a:	01 d0                	add    %edx,%eax
8010917c:	05 a0 6d 19 80       	add    $0x80196da0,%eax
80109181:	83 ec 0c             	sub    $0xc,%esp
80109184:	50                   	push   %eax
80109185:	e8 54 02 00 00       	call   801093de <print_ipv4>
8010918a:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
8010918d:	83 ec 0c             	sub    $0xc,%esp
80109190:	68 5e c0 10 80       	push   $0x8010c05e
80109195:	e8 5a 72 ff ff       	call   801003f4 <cprintf>
8010919a:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
8010919d:	8b 55 f4             	mov    -0xc(%ebp),%edx
801091a0:	89 d0                	mov    %edx,%eax
801091a2:	c1 e0 02             	shl    $0x2,%eax
801091a5:	01 d0                	add    %edx,%eax
801091a7:	01 c0                	add    %eax,%eax
801091a9:	01 d0                	add    %edx,%eax
801091ab:	05 a0 6d 19 80       	add    $0x80196da0,%eax
801091b0:	83 c0 04             	add    $0x4,%eax
801091b3:	83 ec 0c             	sub    $0xc,%esp
801091b6:	50                   	push   %eax
801091b7:	e8 70 02 00 00       	call   8010942c <print_mac>
801091bc:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
801091bf:	83 ec 0c             	sub    $0xc,%esp
801091c2:	68 60 c0 10 80       	push   $0x8010c060
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
8010921d:	e8 49 b9 ff ff       	call   80104b6b <memmove>
80109222:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109225:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109228:	83 c0 06             	add    $0x6,%eax
8010922b:	83 ec 04             	sub    $0x4,%esp
8010922e:	6a 06                	push   $0x6
80109230:	68 80 6d 19 80       	push   $0x80196d80
80109235:	50                   	push   %eax
80109236:	e8 30 b9 ff ff       	call   80104b6b <memmove>
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
80109279:	e8 ed b8 ff ff       	call   80104b6b <memmove>
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
80109294:	e8 d2 b8 ff ff       	call   80104b6b <memmove>
80109299:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
8010929c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010929f:	83 c0 08             	add    $0x8,%eax
801092a2:	83 ec 04             	sub    $0x4,%esp
801092a5:	6a 06                	push   $0x6
801092a7:	68 80 6d 19 80       	push   $0x80196d80
801092ac:	50                   	push   %eax
801092ad:	e8 b9 b8 ff ff       	call   80104b6b <memmove>
801092b2:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801092b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092b8:	83 c0 0e             	add    $0xe,%eax
801092bb:	83 ec 04             	sub    $0x4,%esp
801092be:	6a 04                	push   $0x4
801092c0:	68 e4 f4 10 80       	push   $0x8010f4e4
801092c5:	50                   	push   %eax
801092c6:	e8 a0 b8 ff ff       	call   80104b6b <memmove>
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
801092da:	68 62 c0 10 80       	push   $0x8010c062
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
801092fc:	68 60 c0 10 80       	push   $0x8010c060
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
8010931e:	68 60 c0 10 80       	push   $0x8010c060
80109323:	e8 cc 70 ff ff       	call   801003f4 <cprintf>
80109328:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
8010932b:	83 ec 0c             	sub    $0xc,%esp
8010932e:	68 79 c0 10 80       	push   $0x8010c079
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
80109350:	68 60 c0 10 80       	push   $0x8010c060
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
80109372:	68 60 c0 10 80       	push   $0x8010c060
80109377:	e8 78 70 ff ff       	call   801003f4 <cprintf>
8010937c:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
8010937f:	83 ec 0c             	sub    $0xc,%esp
80109382:	68 90 c0 10 80       	push   $0x8010c090
80109387:	e8 68 70 ff ff       	call   801003f4 <cprintf>
8010938c:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
8010938f:	8b 45 08             	mov    0x8(%ebp),%eax
80109392:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109396:	66 3d 00 01          	cmp    $0x100,%ax
8010939a:	75 12                	jne    801093ae <print_arp_info+0xdd>
8010939c:	83 ec 0c             	sub    $0xc,%esp
8010939f:	68 9c c0 10 80       	push   $0x8010c09c
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
801093be:	68 a5 c0 10 80       	push   $0x8010c0a5
801093c3:	e8 2c 70 ff ff       	call   801003f4 <cprintf>
801093c8:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
801093cb:	83 ec 0c             	sub    $0xc,%esp
801093ce:	68 60 c0 10 80       	push   $0x8010c060
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
80109419:	68 ac c0 10 80       	push   $0x8010c0ac
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
80109483:	68 c4 c0 10 80       	push   $0x8010c0c4
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
801095cb:	e8 43 b5 ff ff       	call   80104b13 <memcmp>
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
801096dc:	e8 ba 90 ff ff       	call   8010279b <kalloc>
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
80109719:	e8 e3 8f ff ff       	call   80102701 <kfree>
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
80109762:	68 e3 c0 10 80       	push   $0x8010c0e3
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
801097d4:	e8 92 b3 ff ff       	call   80104b6b <memmove>
801097d9:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
801097dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801097df:	83 c0 06             	add    $0x6,%eax
801097e2:	83 ec 04             	sub    $0x4,%esp
801097e5:	6a 06                	push   $0x6
801097e7:	68 80 6d 19 80       	push   $0x80196d80
801097ec:	50                   	push   %eax
801097ed:	e8 79 b3 ff ff       	call   80104b6b <memmove>
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
80109824:	0f b7 15 60 70 19 80 	movzwl 0x80197060,%edx
8010982b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010982e:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109832:	0f b7 05 60 70 19 80 	movzwl 0x80197060,%eax
80109839:	83 c0 01             	add    $0x1,%eax
8010983c:	66 a3 60 70 19 80    	mov    %ax,0x80197060
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
80109878:	e8 ee b2 ff ff       	call   80104b6b <memmove>
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
80109893:	e8 d3 b2 ff ff       	call   80104b6b <memmove>
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
80109905:	e8 61 b2 ff ff       	call   80104b6b <memmove>
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
80109920:	e8 46 b2 ff ff       	call   80104b6b <memmove>
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
801099fb:	e8 9b 8d ff ff       	call   8010279b <kalloc>
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
80109a46:	a1 64 70 19 80       	mov    0x80197064,%eax
80109a4b:	83 c0 01             	add    $0x1,%eax
80109a4e:	a3 64 70 19 80       	mov    %eax,0x80197064
80109a53:	e9 69 01 00 00       	jmp    80109bc1 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109a58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a5b:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109a5f:	3c 18                	cmp    $0x18,%al
80109a61:	0f 85 10 01 00 00    	jne    80109b77 <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
80109a67:	83 ec 04             	sub    $0x4,%esp
80109a6a:	6a 03                	push   $0x3
80109a6c:	68 fe c0 10 80       	push   $0x8010c0fe
80109a71:	ff 75 ec             	push   -0x14(%ebp)
80109a74:	e8 9a b0 ff ff       	call   80104b13 <memcmp>
80109a79:	83 c4 10             	add    $0x10,%esp
80109a7c:	85 c0                	test   %eax,%eax
80109a7e:	74 74                	je     80109af4 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
80109a80:	83 ec 0c             	sub    $0xc,%esp
80109a83:	68 02 c1 10 80       	push   $0x8010c102
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
80109b68:	a1 64 70 19 80       	mov    0x80197064,%eax
80109b6d:	83 c0 01             	add    $0x1,%eax
80109b70:	a3 64 70 19 80       	mov    %eax,0x80197064
80109b75:	eb 4a                	jmp    80109bc1 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
80109b77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b7a:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109b7e:	3c 10                	cmp    $0x10,%al
80109b80:	75 3f                	jne    80109bc1 <tcp_proc+0x1f7>
    if(fin_flag == 1){
80109b82:	a1 68 70 19 80       	mov    0x80197068,%eax
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
80109bb7:	c7 05 68 70 19 80 00 	movl   $0x0,0x80197068
80109bbe:	00 00 00 
    }
  }
  kfree((char *)send_addr);
80109bc1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109bc4:	83 ec 0c             	sub    $0xc,%esp
80109bc7:	50                   	push   %eax
80109bc8:	e8 34 8b ff ff       	call   80102701 <kfree>
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
80109c34:	e8 32 af ff ff       	call   80104b6b <memmove>
80109c39:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109c3c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c3f:	83 c0 06             	add    $0x6,%eax
80109c42:	83 ec 04             	sub    $0x4,%esp
80109c45:	6a 06                	push   $0x6
80109c47:	68 80 6d 19 80       	push   $0x80196d80
80109c4c:	50                   	push   %eax
80109c4d:	e8 19 af ff ff       	call   80104b6b <memmove>
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
80109c8c:	0f b7 15 60 70 19 80 	movzwl 0x80197060,%edx
80109c93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c96:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109c9a:	0f b7 05 60 70 19 80 	movzwl 0x80197060,%eax
80109ca1:	83 c0 01             	add    $0x1,%eax
80109ca4:	66 a3 60 70 19 80    	mov    %ax,0x80197060
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
80109cdd:	e8 89 ae ff ff       	call   80104b6b <memmove>
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
80109cf8:	e8 6e ae ff ff       	call   80104b6b <memmove>
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
80109d48:	a1 64 70 19 80       	mov    0x80197064,%eax
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
80109e08:	e8 5e ad ff ff       	call   80104b6b <memmove>
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
80109e23:	e8 43 ad ff ff       	call   80104b6b <memmove>
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
80109f21:	c7 05 68 70 19 80 01 	movl   $0x1,0x80197068
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
80109f3c:	68 0b c1 10 80       	push   $0x8010c10b
80109f41:	50                   	push   %eax
80109f42:	e8 65 00 00 00       	call   80109fac <http_strcpy>
80109f47:	83 c4 10             	add    $0x10,%esp
80109f4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
80109f4d:	8b 45 10             	mov    0x10(%ebp),%eax
80109f50:	83 ec 04             	sub    $0x4,%esp
80109f53:	ff 75 f4             	push   -0xc(%ebp)
80109f56:	68 1e c1 10 80       	push   $0x8010c11e
80109f5b:	50                   	push   %eax
80109f5c:	e8 4b 00 00 00       	call   80109fac <http_strcpy>
80109f61:	83 c4 10             	add    $0x10,%esp
80109f64:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
80109f67:	8b 45 10             	mov    0x10(%ebp),%eax
80109f6a:	83 ec 04             	sub    $0x4,%esp
80109f6d:	ff 75 f4             	push   -0xc(%ebp)
80109f70:	68 39 c1 10 80       	push   $0x8010c139
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
80109ff2:	c7 05 70 70 19 80 a2 	movl   $0x8010f5a2,0x80197070
80109ff9:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
80109ffc:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a001:	c1 e8 09             	shr    $0x9,%eax
8010a004:	a3 6c 70 19 80       	mov    %eax,0x8019706c
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
8010a022:	e8 7e a7 ff ff       	call   801047a5 <holdingsleep>
8010a027:	83 c4 10             	add    $0x10,%esp
8010a02a:	85 c0                	test   %eax,%eax
8010a02c:	75 0d                	jne    8010a03b <iderw+0x29>
    panic("iderw: buf not locked");
8010a02e:	83 ec 0c             	sub    $0xc,%esp
8010a031:	68 4a c1 10 80       	push   $0x8010c14a
8010a036:	e8 6e 65 ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a03b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a03e:	8b 00                	mov    (%eax),%eax
8010a040:	83 e0 06             	and    $0x6,%eax
8010a043:	83 f8 02             	cmp    $0x2,%eax
8010a046:	75 0d                	jne    8010a055 <iderw+0x43>
    panic("iderw: nothing to do");
8010a048:	83 ec 0c             	sub    $0xc,%esp
8010a04b:	68 60 c1 10 80       	push   $0x8010c160
8010a050:	e8 54 65 ff ff       	call   801005a9 <panic>
  if(b->dev != 1)
8010a055:	8b 45 08             	mov    0x8(%ebp),%eax
8010a058:	8b 40 04             	mov    0x4(%eax),%eax
8010a05b:	83 f8 01             	cmp    $0x1,%eax
8010a05e:	74 0d                	je     8010a06d <iderw+0x5b>
    panic("iderw: request not for disk 1");
8010a060:	83 ec 0c             	sub    $0xc,%esp
8010a063:	68 75 c1 10 80       	push   $0x8010c175
8010a068:	e8 3c 65 ff ff       	call   801005a9 <panic>
  if(b->blockno >= disksize)
8010a06d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a070:	8b 40 08             	mov    0x8(%eax),%eax
8010a073:	8b 15 6c 70 19 80    	mov    0x8019706c,%edx
8010a079:	39 d0                	cmp    %edx,%eax
8010a07b:	72 0d                	jb     8010a08a <iderw+0x78>
    panic("iderw: block out of range");
8010a07d:	83 ec 0c             	sub    $0xc,%esp
8010a080:	68 93 c1 10 80       	push   $0x8010c193
8010a085:	e8 1f 65 ff ff       	call   801005a9 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a08a:	8b 15 70 70 19 80    	mov    0x80197070,%edx
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
8010a0cb:	e8 9b aa ff ff       	call   80104b6b <memmove>
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
8010a0e7:	e8 7f aa ff ff       	call   80104b6b <memmove>
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
