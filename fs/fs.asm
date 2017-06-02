
obj/fs/fs:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 31 19 00 00       	call   801962 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	89 c1                	mov    %eax,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800039:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003e:	ec                   	in     (%dx),%al
  80003f:	89 c3                	mov    %eax,%ebx
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800041:	83 e0 c0             	and    $0xffffffc0,%eax
  800044:	3c 40                	cmp    $0x40,%al
  800046:	75 f6                	jne    80003e <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
		return -1;
	return 0;
  800048:	b8 00 00 00 00       	mov    $0x0,%eax
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80004d:	84 c9                	test   %cl,%cl
  80004f:	74 0b                	je     80005c <ide_wait_ready+0x29>
  800051:	f6 c3 21             	test   $0x21,%bl
  800054:	0f 95 c0             	setne  %al
  800057:	0f b6 c0             	movzbl %al,%eax
  80005a:	f7 d8                	neg    %eax
		return -1;
	return 0;
}
  80005c:	5b                   	pop    %ebx
  80005d:	5d                   	pop    %ebp
  80005e:	c3                   	ret    

0080005f <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  80005f:	55                   	push   %ebp
  800060:	89 e5                	mov    %esp,%ebp
  800062:	53                   	push   %ebx
  800063:	83 ec 04             	sub    $0x4,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  800066:	b8 00 00 00 00       	mov    $0x0,%eax
  80006b:	e8 c3 ff ff ff       	call   800033 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800070:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800075:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80007a:	ee                   	out    %al,(%dx)

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80007b:	b9 00 00 00 00       	mov    $0x0,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800080:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800085:	eb 0b                	jmp    800092 <ide_probe_disk1+0x33>
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  800087:	83 c1 01             	add    $0x1,%ecx

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80008a:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  800090:	74 05                	je     800097 <ide_probe_disk1+0x38>
  800092:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800093:	a8 a1                	test   $0xa1,%al
  800095:	75 f0                	jne    800087 <ide_probe_disk1+0x28>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800097:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80009c:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  8000a1:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000a2:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  8000a8:	0f 9e c3             	setle  %bl
  8000ab:	83 ec 08             	sub    $0x8,%esp
  8000ae:	0f b6 c3             	movzbl %bl,%eax
  8000b1:	50                   	push   %eax
  8000b2:	68 c0 3c 80 00       	push   $0x803cc0
  8000b7:	e8 df 19 00 00       	call   801a9b <cprintf>
	return (x < 1000);
}
  8000bc:	89 d8                	mov    %ebx,%eax
  8000be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c1:	c9                   	leave  
  8000c2:	c3                   	ret    

008000c3 <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	83 ec 08             	sub    $0x8,%esp
  8000c9:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000cc:	83 f8 01             	cmp    $0x1,%eax
  8000cf:	76 14                	jbe    8000e5 <ide_set_disk+0x22>
		panic("bad disk number");
  8000d1:	83 ec 04             	sub    $0x4,%esp
  8000d4:	68 d7 3c 80 00       	push   $0x803cd7
  8000d9:	6a 3a                	push   $0x3a
  8000db:	68 e7 3c 80 00       	push   $0x803ce7
  8000e0:	e8 dd 18 00 00       	call   8019c2 <_panic>
	diskno = d;
  8000e5:	a3 00 50 80 00       	mov    %eax,0x805000
}
  8000ea:	c9                   	leave  
  8000eb:	c3                   	ret    

008000ec <ide_read>:


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	57                   	push   %edi
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8000f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000fb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  8000fe:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  800104:	76 16                	jbe    80011c <ide_read+0x30>
  800106:	68 f0 3c 80 00       	push   $0x803cf0
  80010b:	68 fd 3c 80 00       	push   $0x803cfd
  800110:	6a 44                	push   $0x44
  800112:	68 e7 3c 80 00       	push   $0x803ce7
  800117:	e8 a6 18 00 00       	call   8019c2 <_panic>

	ide_wait_ready(0);
  80011c:	b8 00 00 00 00       	mov    $0x0,%eax
  800121:	e8 0d ff ff ff       	call   800033 <ide_wait_ready>
  800126:	ba f2 01 00 00       	mov    $0x1f2,%edx
  80012b:	89 f0                	mov    %esi,%eax
  80012d:	ee                   	out    %al,(%dx)
  80012e:	ba f3 01 00 00       	mov    $0x1f3,%edx
  800133:	89 f8                	mov    %edi,%eax
  800135:	ee                   	out    %al,(%dx)
  800136:	89 f8                	mov    %edi,%eax
  800138:	c1 e8 08             	shr    $0x8,%eax
  80013b:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800140:	ee                   	out    %al,(%dx)
  800141:	89 f8                	mov    %edi,%eax
  800143:	c1 e8 10             	shr    $0x10,%eax
  800146:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80014b:	ee                   	out    %al,(%dx)
  80014c:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800153:	83 e0 01             	and    $0x1,%eax
  800156:	c1 e0 04             	shl    $0x4,%eax
  800159:	83 c8 e0             	or     $0xffffffe0,%eax
  80015c:	c1 ef 18             	shr    $0x18,%edi
  80015f:	83 e7 0f             	and    $0xf,%edi
  800162:	09 f8                	or     %edi,%eax
  800164:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800169:	ee                   	out    %al,(%dx)
  80016a:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80016f:	b8 20 00 00 00       	mov    $0x20,%eax
  800174:	ee                   	out    %al,(%dx)
  800175:	c1 e6 09             	shl    $0x9,%esi
  800178:	01 de                	add    %ebx,%esi
  80017a:	eb 23                	jmp    80019f <ide_read+0xb3>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  80017c:	b8 01 00 00 00       	mov    $0x1,%eax
  800181:	e8 ad fe ff ff       	call   800033 <ide_wait_ready>
  800186:	85 c0                	test   %eax,%eax
  800188:	78 1e                	js     8001a8 <ide_read+0xbc>
}

static __inline void
insl(int port, void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\tinsl"			:
  80018a:	89 df                	mov    %ebx,%edi
  80018c:	b9 80 00 00 00       	mov    $0x80,%ecx
  800191:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800196:	fc                   	cld    
  800197:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  800199:	81 c3 00 02 00 00    	add    $0x200,%ebx
  80019f:	39 f3                	cmp    %esi,%ebx
  8001a1:	75 d9                	jne    80017c <ide_read+0x90>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  8001a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ab:	5b                   	pop    %ebx
  8001ac:	5e                   	pop    %esi
  8001ad:	5f                   	pop    %edi
  8001ae:	5d                   	pop    %ebp
  8001af:	c3                   	ret    

008001b0 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	57                   	push   %edi
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8001bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001bf:	8b 7d 10             	mov    0x10(%ebp),%edi
	int r;

	assert(nsecs <= 256);
  8001c2:	81 ff 00 01 00 00    	cmp    $0x100,%edi
  8001c8:	76 16                	jbe    8001e0 <ide_write+0x30>
  8001ca:	68 f0 3c 80 00       	push   $0x803cf0
  8001cf:	68 fd 3c 80 00       	push   $0x803cfd
  8001d4:	6a 5d                	push   $0x5d
  8001d6:	68 e7 3c 80 00       	push   $0x803ce7
  8001db:	e8 e2 17 00 00       	call   8019c2 <_panic>

	ide_wait_ready(0);
  8001e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001e5:	e8 49 fe ff ff       	call   800033 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001ea:	ba f2 01 00 00       	mov    $0x1f2,%edx
  8001ef:	89 f8                	mov    %edi,%eax
  8001f1:	ee                   	out    %al,(%dx)
  8001f2:	ba f3 01 00 00       	mov    $0x1f3,%edx
  8001f7:	89 f0                	mov    %esi,%eax
  8001f9:	ee                   	out    %al,(%dx)
  8001fa:	89 f0                	mov    %esi,%eax
  8001fc:	c1 e8 08             	shr    $0x8,%eax
  8001ff:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800204:	ee                   	out    %al,(%dx)
  800205:	89 f0                	mov    %esi,%eax
  800207:	c1 e8 10             	shr    $0x10,%eax
  80020a:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80020f:	ee                   	out    %al,(%dx)
  800210:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800217:	83 e0 01             	and    $0x1,%eax
  80021a:	c1 e0 04             	shl    $0x4,%eax
  80021d:	83 c8 e0             	or     $0xffffffe0,%eax
  800220:	c1 ee 18             	shr    $0x18,%esi
  800223:	83 e6 0f             	and    $0xf,%esi
  800226:	09 f0                	or     %esi,%eax
  800228:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80022d:	ee                   	out    %al,(%dx)
  80022e:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800233:	b8 30 00 00 00       	mov    $0x30,%eax
  800238:	ee                   	out    %al,(%dx)
  800239:	c1 e7 09             	shl    $0x9,%edi
  80023c:	01 df                	add    %ebx,%edi
  80023e:	eb 23                	jmp    800263 <ide_write+0xb3>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  800240:	b8 01 00 00 00       	mov    $0x1,%eax
  800245:	e8 e9 fd ff ff       	call   800033 <ide_wait_ready>
  80024a:	85 c0                	test   %eax,%eax
  80024c:	78 1e                	js     80026c <ide_write+0xbc>
}

static __inline void
outsl(int port, const void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\toutsl"		:
  80024e:	89 de                	mov    %ebx,%esi
  800250:	b9 80 00 00 00       	mov    $0x80,%ecx
  800255:	ba f0 01 00 00       	mov    $0x1f0,%edx
  80025a:	fc                   	cld    
  80025b:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  80025d:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800263:	39 fb                	cmp    %edi,%ebx
  800265:	75 d9                	jne    800240 <ide_write+0x90>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  800267:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80026c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5f                   	pop    %edi
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  80027c:	8b 1a                	mov    (%edx),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  80027e:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  800284:	89 c6                	mov    %eax,%esi
  800286:	c1 ee 0c             	shr    $0xc,%esi
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800289:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  80028e:	76 1b                	jbe    8002ab <bc_pgfault+0x37>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  800290:	83 ec 08             	sub    $0x8,%esp
  800293:	ff 72 04             	pushl  0x4(%edx)
  800296:	53                   	push   %ebx
  800297:	ff 72 28             	pushl  0x28(%edx)
  80029a:	68 14 3d 80 00       	push   $0x803d14
  80029f:	6a 27                	push   $0x27
  8002a1:	68 f4 3d 80 00       	push   $0x803df4
  8002a6:	e8 17 17 00 00       	call   8019c2 <_panic>
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002ab:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8002b0:	85 c0                	test   %eax,%eax
  8002b2:	74 17                	je     8002cb <bc_pgfault+0x57>
  8002b4:	3b 70 04             	cmp    0x4(%eax),%esi
  8002b7:	72 12                	jb     8002cb <bc_pgfault+0x57>
		panic("reading non-existent block %08x\n", blockno);
  8002b9:	56                   	push   %esi
  8002ba:	68 44 3d 80 00       	push   $0x803d44
  8002bf:	6a 2b                	push   $0x2b
  8002c1:	68 f4 3d 80 00       	push   $0x803df4
  8002c6:	e8 f7 16 00 00       	call   8019c2 <_panic>
	//
	// LAB 5: you code here:

	/* My code */
	// Round addr to make it page-aligned
	addr = (void*) ROUNDDOWN(addr, PGSIZE);
  8002cb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx

	// Allocate a page in the disk map region
	if((r = sys_page_alloc(0, addr, PTE_P | PTE_U | PTE_W)) < 0)
  8002d1:	83 ec 04             	sub    $0x4,%esp
  8002d4:	6a 07                	push   $0x7
  8002d6:	53                   	push   %ebx
  8002d7:	6a 00                	push   $0x0
  8002d9:	e8 45 21 00 00       	call   802423 <sys_page_alloc>
  8002de:	83 c4 10             	add    $0x10,%esp
  8002e1:	85 c0                	test   %eax,%eax
  8002e3:	79 12                	jns    8002f7 <bc_pgfault+0x83>
		panic("in bc_pgfault, sys_page_alloc: %e", r);
  8002e5:	50                   	push   %eax
  8002e6:	68 68 3d 80 00       	push   $0x803d68
  8002eb:	6a 3a                	push   $0x3a
  8002ed:	68 f4 3d 80 00       	push   $0x803df4
  8002f2:	e8 cb 16 00 00       	call   8019c2 <_panic>

	// Read the contents of the block in the disk, and put it
	// on the page just mapped
	if ((r = ide_read(blockno*BLKSECTS, addr, BLKSECTS)) < 0)
  8002f7:	83 ec 04             	sub    $0x4,%esp
  8002fa:	6a 08                	push   $0x8
  8002fc:	53                   	push   %ebx
  8002fd:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
  800304:	50                   	push   %eax
  800305:	e8 e2 fd ff ff       	call   8000ec <ide_read>
  80030a:	83 c4 10             	add    $0x10,%esp
  80030d:	85 c0                	test   %eax,%eax
  80030f:	79 12                	jns    800323 <bc_pgfault+0xaf>
		panic("in bc_pgfaul, ide_read: %e", r);
  800311:	50                   	push   %eax
  800312:	68 fc 3d 80 00       	push   $0x803dfc
  800317:	6a 3f                	push   $0x3f
  800319:	68 f4 3d 80 00       	push   $0x803df4
  80031e:	e8 9f 16 00 00       	call   8019c2 <_panic>
	/* End of my code */

	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  800323:	89 d8                	mov    %ebx,%eax
  800325:	c1 e8 0c             	shr    $0xc,%eax
  800328:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80032f:	83 ec 0c             	sub    $0xc,%esp
  800332:	25 07 0e 00 00       	and    $0xe07,%eax
  800337:	50                   	push   %eax
  800338:	53                   	push   %ebx
  800339:	6a 00                	push   $0x0
  80033b:	53                   	push   %ebx
  80033c:	6a 00                	push   $0x0
  80033e:	e8 23 21 00 00       	call   802466 <sys_page_map>
  800343:	83 c4 20             	add    $0x20,%esp
  800346:	85 c0                	test   %eax,%eax
  800348:	79 12                	jns    80035c <bc_pgfault+0xe8>
		panic("in bc_pgfault, sys_page_map: %e", r);
  80034a:	50                   	push   %eax
  80034b:	68 8c 3d 80 00       	push   $0x803d8c
  800350:	6a 45                	push   $0x45
  800352:	68 f4 3d 80 00       	push   $0x803df4
  800357:	e8 66 16 00 00       	call   8019c2 <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  80035c:	83 3d 08 a0 80 00 00 	cmpl   $0x0,0x80a008
  800363:	74 22                	je     800387 <bc_pgfault+0x113>
  800365:	83 ec 0c             	sub    $0xc,%esp
  800368:	56                   	push   %esi
  800369:	e8 83 03 00 00       	call   8006f1 <block_is_free>
  80036e:	83 c4 10             	add    $0x10,%esp
  800371:	84 c0                	test   %al,%al
  800373:	74 12                	je     800387 <bc_pgfault+0x113>
		panic("reading free block %08x\n", blockno);
  800375:	56                   	push   %esi
  800376:	68 17 3e 80 00       	push   $0x803e17
  80037b:	6a 4b                	push   $0x4b
  80037d:	68 f4 3d 80 00       	push   $0x803df4
  800382:	e8 3b 16 00 00       	call   8019c2 <_panic>
}
  800387:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80038a:	5b                   	pop    %ebx
  80038b:	5e                   	pop    %esi
  80038c:	5d                   	pop    %ebp
  80038d:	c3                   	ret    

0080038e <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	83 ec 08             	sub    $0x8,%esp
  800394:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  800397:	85 c0                	test   %eax,%eax
  800399:	74 0f                	je     8003aa <diskaddr+0x1c>
  80039b:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  8003a1:	85 d2                	test   %edx,%edx
  8003a3:	74 17                	je     8003bc <diskaddr+0x2e>
  8003a5:	3b 42 04             	cmp    0x4(%edx),%eax
  8003a8:	72 12                	jb     8003bc <diskaddr+0x2e>
		panic("bad block number %08x in diskaddr", blockno);
  8003aa:	50                   	push   %eax
  8003ab:	68 ac 3d 80 00       	push   $0x803dac
  8003b0:	6a 09                	push   $0x9
  8003b2:	68 f4 3d 80 00       	push   $0x803df4
  8003b7:	e8 06 16 00 00       	call   8019c2 <_panic>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  8003bc:	05 00 00 01 00       	add    $0x10000,%eax
  8003c1:	c1 e0 0c             	shl    $0xc,%eax
}
  8003c4:	c9                   	leave  
  8003c5:	c3                   	ret    

008003c6 <va_is_mapped>:

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  8003c6:	55                   	push   %ebp
  8003c7:	89 e5                	mov    %esp,%ebp
  8003c9:	8b 55 08             	mov    0x8(%ebp),%edx
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  8003cc:	89 d0                	mov    %edx,%eax
  8003ce:	c1 e8 16             	shr    $0x16,%eax
  8003d1:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  8003d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003dd:	f6 c1 01             	test   $0x1,%cl
  8003e0:	74 0d                	je     8003ef <va_is_mapped+0x29>
  8003e2:	c1 ea 0c             	shr    $0xc,%edx
  8003e5:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8003ec:	83 e0 01             	and    $0x1,%eax
  8003ef:	83 e0 01             	and    $0x1,%eax
}
  8003f2:	5d                   	pop    %ebp
  8003f3:	c3                   	ret    

008003f4 <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  8003f4:	55                   	push   %ebp
  8003f5:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  8003f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fa:	c1 e8 0c             	shr    $0xc,%eax
  8003fd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800404:	c1 e8 06             	shr    $0x6,%eax
  800407:	83 e0 01             	and    $0x1,%eax
}
  80040a:	5d                   	pop    %ebp
  80040b:	c3                   	ret    

0080040c <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	56                   	push   %esi
  800410:	53                   	push   %ebx
  800411:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800414:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  80041a:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  80041f:	76 12                	jbe    800433 <flush_block+0x27>
		panic("flush_block of bad va %08x", addr);
  800421:	53                   	push   %ebx
  800422:	68 30 3e 80 00       	push   $0x803e30
  800427:	6a 5b                	push   $0x5b
  800429:	68 f4 3d 80 00       	push   $0x803df4
  80042e:	e8 8f 15 00 00       	call   8019c2 <_panic>

	// LAB 5: Your code here.
	// Round addr to make it page-aligned
	addr = (void*) ROUNDDOWN(addr, PGSIZE);
  800433:	89 de                	mov    %ebx,%esi
  800435:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi

	// Checks if it needs to be flushed
	int r;
	if (va_is_mapped(addr) && va_is_dirty(addr)) {
  80043b:	83 ec 0c             	sub    $0xc,%esp
  80043e:	56                   	push   %esi
  80043f:	e8 82 ff ff ff       	call   8003c6 <va_is_mapped>
  800444:	83 c4 10             	add    $0x10,%esp
  800447:	84 c0                	test   %al,%al
  800449:	74 7a                	je     8004c5 <flush_block+0xb9>
  80044b:	83 ec 0c             	sub    $0xc,%esp
  80044e:	56                   	push   %esi
  80044f:	e8 a0 ff ff ff       	call   8003f4 <va_is_dirty>
  800454:	83 c4 10             	add    $0x10,%esp
  800457:	84 c0                	test   %al,%al
  800459:	74 6a                	je     8004c5 <flush_block+0xb9>
		// Copy block data to disk
		if ((r = ide_write(blockno*BLKSECTS, addr, BLKSECTS)) < 0)
  80045b:	83 ec 04             	sub    $0x4,%esp
  80045e:	6a 08                	push   $0x8
  800460:	56                   	push   %esi
  800461:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
  800467:	c1 eb 0c             	shr    $0xc,%ebx
  80046a:	c1 e3 03             	shl    $0x3,%ebx
  80046d:	53                   	push   %ebx
  80046e:	e8 3d fd ff ff       	call   8001b0 <ide_write>
  800473:	83 c4 10             	add    $0x10,%esp
  800476:	85 c0                	test   %eax,%eax
  800478:	79 12                	jns    80048c <flush_block+0x80>
			panic("in flush_block, ide_write: %e", r);
  80047a:	50                   	push   %eax
  80047b:	68 4b 3e 80 00       	push   $0x803e4b
  800480:	6a 66                	push   $0x66
  800482:	68 f4 3d 80 00       	push   $0x803df4
  800487:	e8 36 15 00 00       	call   8019c2 <_panic>
		// Clear the dirty bit of the page entry
		if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  80048c:	89 f0                	mov    %esi,%eax
  80048e:	c1 e8 0c             	shr    $0xc,%eax
  800491:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800498:	83 ec 0c             	sub    $0xc,%esp
  80049b:	25 07 0e 00 00       	and    $0xe07,%eax
  8004a0:	50                   	push   %eax
  8004a1:	56                   	push   %esi
  8004a2:	6a 00                	push   $0x0
  8004a4:	56                   	push   %esi
  8004a5:	6a 00                	push   $0x0
  8004a7:	e8 ba 1f 00 00       	call   802466 <sys_page_map>
  8004ac:	83 c4 20             	add    $0x20,%esp
  8004af:	85 c0                	test   %eax,%eax
  8004b1:	79 12                	jns    8004c5 <flush_block+0xb9>
			panic("in bc_pgfault, sys_page_map: %e", r);
  8004b3:	50                   	push   %eax
  8004b4:	68 8c 3d 80 00       	push   $0x803d8c
  8004b9:	6a 69                	push   $0x69
  8004bb:	68 f4 3d 80 00       	push   $0x803df4
  8004c0:	e8 fd 14 00 00       	call   8019c2 <_panic>
	}
}
  8004c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004c8:	5b                   	pop    %ebx
  8004c9:	5e                   	pop    %esi
  8004ca:	5d                   	pop    %ebp
  8004cb:	c3                   	ret    

008004cc <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  8004cc:	55                   	push   %ebp
  8004cd:	89 e5                	mov    %esp,%ebp
  8004cf:	81 ec 24 02 00 00    	sub    $0x224,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  8004d5:	68 74 02 80 00       	push   $0x800274
  8004da:	e8 19 22 00 00       	call   8026f8 <set_pgfault_handler>
check_bc(void)
{
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  8004df:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004e6:	e8 a3 fe ff ff       	call   80038e <diskaddr>
  8004eb:	83 c4 0c             	add    $0xc,%esp
  8004ee:	68 08 01 00 00       	push   $0x108
  8004f3:	50                   	push   %eax
  8004f4:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8004fa:	50                   	push   %eax
  8004fb:	e8 b2 1c 00 00       	call   8021b2 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  800500:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800507:	e8 82 fe ff ff       	call   80038e <diskaddr>
  80050c:	83 c4 08             	add    $0x8,%esp
  80050f:	68 69 3e 80 00       	push   $0x803e69
  800514:	50                   	push   %eax
  800515:	e8 06 1b 00 00       	call   802020 <strcpy>
	flush_block(diskaddr(1));
  80051a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800521:	e8 68 fe ff ff       	call   80038e <diskaddr>
  800526:	89 04 24             	mov    %eax,(%esp)
  800529:	e8 de fe ff ff       	call   80040c <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  80052e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800535:	e8 54 fe ff ff       	call   80038e <diskaddr>
  80053a:	89 04 24             	mov    %eax,(%esp)
  80053d:	e8 84 fe ff ff       	call   8003c6 <va_is_mapped>
  800542:	83 c4 10             	add    $0x10,%esp
  800545:	84 c0                	test   %al,%al
  800547:	75 16                	jne    80055f <bc_init+0x93>
  800549:	68 8b 3e 80 00       	push   $0x803e8b
  80054e:	68 fd 3c 80 00       	push   $0x803cfd
  800553:	6a 7a                	push   $0x7a
  800555:	68 f4 3d 80 00       	push   $0x803df4
  80055a:	e8 63 14 00 00       	call   8019c2 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  80055f:	83 ec 0c             	sub    $0xc,%esp
  800562:	6a 01                	push   $0x1
  800564:	e8 25 fe ff ff       	call   80038e <diskaddr>
  800569:	89 04 24             	mov    %eax,(%esp)
  80056c:	e8 83 fe ff ff       	call   8003f4 <va_is_dirty>
  800571:	83 c4 10             	add    $0x10,%esp
  800574:	84 c0                	test   %al,%al
  800576:	74 16                	je     80058e <bc_init+0xc2>
  800578:	68 70 3e 80 00       	push   $0x803e70
  80057d:	68 fd 3c 80 00       	push   $0x803cfd
  800582:	6a 7b                	push   $0x7b
  800584:	68 f4 3d 80 00       	push   $0x803df4
  800589:	e8 34 14 00 00       	call   8019c2 <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  80058e:	83 ec 0c             	sub    $0xc,%esp
  800591:	6a 01                	push   $0x1
  800593:	e8 f6 fd ff ff       	call   80038e <diskaddr>
  800598:	83 c4 08             	add    $0x8,%esp
  80059b:	50                   	push   %eax
  80059c:	6a 00                	push   $0x0
  80059e:	e8 05 1f 00 00       	call   8024a8 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  8005a3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005aa:	e8 df fd ff ff       	call   80038e <diskaddr>
  8005af:	89 04 24             	mov    %eax,(%esp)
  8005b2:	e8 0f fe ff ff       	call   8003c6 <va_is_mapped>
  8005b7:	83 c4 10             	add    $0x10,%esp
  8005ba:	84 c0                	test   %al,%al
  8005bc:	74 16                	je     8005d4 <bc_init+0x108>
  8005be:	68 8a 3e 80 00       	push   $0x803e8a
  8005c3:	68 fd 3c 80 00       	push   $0x803cfd
  8005c8:	6a 7f                	push   $0x7f
  8005ca:	68 f4 3d 80 00       	push   $0x803df4
  8005cf:	e8 ee 13 00 00       	call   8019c2 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8005d4:	83 ec 0c             	sub    $0xc,%esp
  8005d7:	6a 01                	push   $0x1
  8005d9:	e8 b0 fd ff ff       	call   80038e <diskaddr>
  8005de:	83 c4 08             	add    $0x8,%esp
  8005e1:	68 69 3e 80 00       	push   $0x803e69
  8005e6:	50                   	push   %eax
  8005e7:	e8 de 1a 00 00       	call   8020ca <strcmp>
  8005ec:	83 c4 10             	add    $0x10,%esp
  8005ef:	85 c0                	test   %eax,%eax
  8005f1:	74 19                	je     80060c <bc_init+0x140>
  8005f3:	68 d0 3d 80 00       	push   $0x803dd0
  8005f8:	68 fd 3c 80 00       	push   $0x803cfd
  8005fd:	68 82 00 00 00       	push   $0x82
  800602:	68 f4 3d 80 00       	push   $0x803df4
  800607:	e8 b6 13 00 00       	call   8019c2 <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  80060c:	83 ec 0c             	sub    $0xc,%esp
  80060f:	6a 01                	push   $0x1
  800611:	e8 78 fd ff ff       	call   80038e <diskaddr>
  800616:	83 c4 0c             	add    $0xc,%esp
  800619:	68 08 01 00 00       	push   $0x108
  80061e:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  800624:	52                   	push   %edx
  800625:	50                   	push   %eax
  800626:	e8 87 1b 00 00       	call   8021b2 <memmove>
	flush_block(diskaddr(1));
  80062b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800632:	e8 57 fd ff ff       	call   80038e <diskaddr>
  800637:	89 04 24             	mov    %eax,(%esp)
  80063a:	e8 cd fd ff ff       	call   80040c <flush_block>

	cprintf("block cache is good\n");
  80063f:	c7 04 24 a5 3e 80 00 	movl   $0x803ea5,(%esp)
  800646:	e8 50 14 00 00       	call   801a9b <cprintf>
	struct Super super;
	set_pgfault_handler(bc_pgfault);
	check_bc();

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  80064b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800652:	e8 37 fd ff ff       	call   80038e <diskaddr>
  800657:	83 c4 0c             	add    $0xc,%esp
  80065a:	68 08 01 00 00       	push   $0x108
  80065f:	50                   	push   %eax
  800660:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800666:	50                   	push   %eax
  800667:	e8 46 1b 00 00       	call   8021b2 <memmove>
}
  80066c:	83 c4 10             	add    $0x10,%esp
  80066f:	c9                   	leave  
  800670:	c3                   	ret    

00800671 <blockno_to_va>:

// Auxiliary function created by me
static void*
blockno_to_va(uint32_t blockno)
{
	if (blockno >= NDIRECT + NINDIRECT)
  800671:	3d 09 04 00 00       	cmp    $0x409,%eax
  800676:	76 1a                	jbe    800692 <blockno_to_va+0x21>
}

// Auxiliary function created by me
static void*
blockno_to_va(uint32_t blockno)
{
  800678:	55                   	push   %ebp
  800679:	89 e5                	mov    %esp,%ebp
  80067b:	83 ec 0c             	sub    $0xc,%esp
	if (blockno >= NDIRECT + NINDIRECT)
		panic("blockno_to_va: invalid blockno");
  80067e:	68 bc 3e 80 00       	push   $0x803ebc
  800683:	68 89 00 00 00       	push   $0x89
  800688:	68 02 3f 80 00       	push   $0x803f02
  80068d:	e8 30 13 00 00       	call   8019c2 <_panic>

	return (void*) (DISKMAP + blockno*BLKSIZE);
  800692:	05 00 00 01 00       	add    $0x10000,%eax
  800697:	c1 e0 0c             	shl    $0xc,%eax
}
  80069a:	c3                   	ret    

0080069b <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  80069b:	55                   	push   %ebp
  80069c:	89 e5                	mov    %esp,%ebp
  80069e:	83 ec 08             	sub    $0x8,%esp
	if (super->s_magic != FS_MAGIC)
  8006a1:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8006a6:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  8006ac:	74 14                	je     8006c2 <check_super+0x27>
		panic("bad file system magic number");
  8006ae:	83 ec 04             	sub    $0x4,%esp
  8006b1:	68 0a 3f 80 00       	push   $0x803f0a
  8006b6:	6a 0f                	push   $0xf
  8006b8:	68 02 3f 80 00       	push   $0x803f02
  8006bd:	e8 00 13 00 00       	call   8019c2 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  8006c2:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8006c9:	76 14                	jbe    8006df <check_super+0x44>
		panic("file system is too large");
  8006cb:	83 ec 04             	sub    $0x4,%esp
  8006ce:	68 27 3f 80 00       	push   $0x803f27
  8006d3:	6a 12                	push   $0x12
  8006d5:	68 02 3f 80 00       	push   $0x803f02
  8006da:	e8 e3 12 00 00       	call   8019c2 <_panic>

	cprintf("superblock is good\n");
  8006df:	83 ec 0c             	sub    $0xc,%esp
  8006e2:	68 40 3f 80 00       	push   $0x803f40
  8006e7:	e8 af 13 00 00       	call   801a9b <cprintf>
}
  8006ec:	83 c4 10             	add    $0x10,%esp
  8006ef:	c9                   	leave  
  8006f0:	c3                   	ret    

008006f1 <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  8006f1:	55                   	push   %ebp
  8006f2:	89 e5                	mov    %esp,%ebp
  8006f4:	53                   	push   %ebx
  8006f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  8006f8:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  8006fe:	85 d2                	test   %edx,%edx
  800700:	74 24                	je     800726 <block_is_free+0x35>
		return 0;
  800702:	b8 00 00 00 00       	mov    $0x0,%eax
// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
  800707:	39 4a 04             	cmp    %ecx,0x4(%edx)
  80070a:	76 1f                	jbe    80072b <block_is_free+0x3a>
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  80070c:	89 cb                	mov    %ecx,%ebx
  80070e:	c1 eb 05             	shr    $0x5,%ebx
  800711:	b8 01 00 00 00       	mov    $0x1,%eax
  800716:	d3 e0                	shl    %cl,%eax
  800718:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  80071e:	85 04 9a             	test   %eax,(%edx,%ebx,4)
  800721:	0f 95 c0             	setne  %al
  800724:	eb 05                	jmp    80072b <block_is_free+0x3a>
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
		return 0;
  800726:	b8 00 00 00 00       	mov    $0x0,%eax
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  80072b:	5b                   	pop    %ebx
  80072c:	5d                   	pop    %ebp
  80072d:	c3                   	ret    

0080072e <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  80072e:	55                   	push   %ebp
  80072f:	89 e5                	mov    %esp,%ebp
  800731:	53                   	push   %ebx
  800732:	83 ec 04             	sub    $0x4,%esp
  800735:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  800738:	85 c9                	test   %ecx,%ecx
  80073a:	75 14                	jne    800750 <free_block+0x22>
		panic("attempt to free zero block");
  80073c:	83 ec 04             	sub    $0x4,%esp
  80073f:	68 54 3f 80 00       	push   $0x803f54
  800744:	6a 2d                	push   $0x2d
  800746:	68 02 3f 80 00       	push   $0x803f02
  80074b:	e8 72 12 00 00       	call   8019c2 <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  800750:	89 cb                	mov    %ecx,%ebx
  800752:	c1 eb 05             	shr    $0x5,%ebx
  800755:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  80075b:	b8 01 00 00 00       	mov    $0x1,%eax
  800760:	d3 e0                	shl    %cl,%eax
  800762:	09 04 9a             	or     %eax,(%edx,%ebx,4)
}
  800765:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800768:	c9                   	leave  
  800769:	c3                   	ret    

0080076a <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  80076a:	55                   	push   %ebp
  80076b:	89 e5                	mov    %esp,%ebp
  80076d:	56                   	push   %esi
  80076e:	53                   	push   %ebx
	// The bitmap consists of one or more blocks.  A single bitmap block
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	if (!super)
  80076f:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  800774:	85 c0                	test   %eax,%eax
  800776:	74 0a                	je     800782 <alloc_block+0x18>
		panic("in alloc_block: super not initialized");

	// Loop through all possible blocks, checking if there is any free
	int blockno;
	for (blockno = 1; blockno < super->s_nblocks; blockno++) {
  800778:	8b 70 04             	mov    0x4(%eax),%esi
  80077b:	bb 01 00 00 00       	mov    $0x1,%ebx
  800780:	eb 6c                	jmp    8007ee <alloc_block+0x84>
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	if (!super)
		panic("in alloc_block: super not initialized");
  800782:	83 ec 04             	sub    $0x4,%esp
  800785:	68 dc 3e 80 00       	push   $0x803edc
  80078a:	6a 42                	push   $0x42
  80078c:	68 02 3f 80 00       	push   $0x803f02
  800791:	e8 2c 12 00 00       	call   8019c2 <_panic>

	// Loop through all possible blocks, checking if there is any free
	int blockno;
	for (blockno = 1; blockno < super->s_nblocks; blockno++) {
		// If find a free block, mark it used and flush the bitmap block
		if(block_is_free(blockno)) {
  800796:	83 ec 0c             	sub    $0xc,%esp
  800799:	53                   	push   %ebx
  80079a:	e8 52 ff ff ff       	call   8006f1 <block_is_free>
  80079f:	83 c4 10             	add    $0x10,%esp
  8007a2:	84 c0                	test   %al,%al
  8007a4:	74 45                	je     8007eb <alloc_block+0x81>
			bitmap[blockno / 32] &= ~(1<<(blockno%32));
  8007a6:	8d 43 1f             	lea    0x1f(%ebx),%eax
  8007a9:	85 db                	test   %ebx,%ebx
  8007ab:	0f 49 c3             	cmovns %ebx,%eax
  8007ae:	c1 f8 05             	sar    $0x5,%eax
  8007b1:	c1 e0 02             	shl    $0x2,%eax
  8007b4:	89 c2                	mov    %eax,%edx
  8007b6:	03 15 08 a0 80 00    	add    0x80a008,%edx
  8007bc:	89 de                	mov    %ebx,%esi
  8007be:	c1 fe 1f             	sar    $0x1f,%esi
  8007c1:	c1 ee 1b             	shr    $0x1b,%esi
  8007c4:	8d 0c 33             	lea    (%ebx,%esi,1),%ecx
  8007c7:	83 e1 1f             	and    $0x1f,%ecx
  8007ca:	29 f1                	sub    %esi,%ecx
  8007cc:	be fe ff ff ff       	mov    $0xfffffffe,%esi
  8007d1:	d3 c6                	rol    %cl,%esi
  8007d3:	21 32                	and    %esi,(%edx)
			flush_block(&bitmap[blockno/32]);
  8007d5:	83 ec 0c             	sub    $0xc,%esp
  8007d8:	03 05 08 a0 80 00    	add    0x80a008,%eax
  8007de:	50                   	push   %eax
  8007df:	e8 28 fc ff ff       	call   80040c <flush_block>
			return blockno;
  8007e4:	83 c4 10             	add    $0x10,%esp
  8007e7:	89 d8                	mov    %ebx,%eax
  8007e9:	eb 0c                	jmp    8007f7 <alloc_block+0x8d>
	if (!super)
		panic("in alloc_block: super not initialized");

	// Loop through all possible blocks, checking if there is any free
	int blockno;
	for (blockno = 1; blockno < super->s_nblocks; blockno++) {
  8007eb:	83 c3 01             	add    $0x1,%ebx
  8007ee:	39 de                	cmp    %ebx,%esi
  8007f0:	77 a4                	ja     800796 <alloc_block+0x2c>
			return blockno;
		}
	}

	// No block is free
	return -E_NO_DISK;
  8007f2:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
}
  8007f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007fa:	5b                   	pop    %ebx
  8007fb:	5e                   	pop    %esi
  8007fc:	5d                   	pop    %ebp
  8007fd:	c3                   	ret    

008007fe <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	57                   	push   %edi
  800802:	56                   	push   %esi
  800803:	53                   	push   %ebx
  800804:	83 ec 1c             	sub    $0x1c,%esp
  800807:	8b 7d 08             	mov    0x8(%ebp),%edi
       // LAB 5: Your code here.
	// Checks if filebno is valid
	if (filebno >= NDIRECT + NINDIRECT)
  80080a:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  800810:	77 6f                	ja     800881 <file_block_walk+0x83>
		return -E_INVAL;

	// Checks if it is one of the direct blocks
	if (filebno < NDIRECT) {
  800812:	83 fa 09             	cmp    $0x9,%edx
  800815:	77 10                	ja     800827 <file_block_walk+0x29>
		*ppdiskbno = &(f->f_direct[filebno]);
  800817:	8d 84 90 88 00 00 00 	lea    0x88(%eax,%edx,4),%eax
  80081e:	89 01                	mov    %eax,(%ecx)
		return 0;
  800820:	b8 00 00 00 00       	mov    $0x0,%eax
  800825:	eb 6d                	jmp    800894 <file_block_walk+0x96>
  800827:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80082a:	89 d3                	mov    %edx,%ebx
  80082c:	89 c6                	mov    %eax,%esi
	}

	// If we got here, filebno is in the indirect block
	// If there is no indirect block, try to allocate
	if (f->f_indirect == 0) {
  80082e:	83 b8 b0 00 00 00 00 	cmpl   $0x0,0xb0(%eax)
  800835:	75 2f                	jne    800866 <file_block_walk+0x68>
		if (alloc) {
  800837:	89 f8                	mov    %edi,%eax
  800839:	84 c0                	test   %al,%al
  80083b:	74 4b                	je     800888 <file_block_walk+0x8a>
			// Allocate the a new block
			int newblkno;
			if ((newblkno = alloc_block()) < 0)
  80083d:	e8 28 ff ff ff       	call   80076a <alloc_block>
  800842:	89 c7                	mov    %eax,%edi
  800844:	85 c0                	test   %eax,%eax
  800846:	78 47                	js     80088f <file_block_walk+0x91>
				return -E_NO_DISK;

			// Clear the allocated block
			memset(blockno_to_va(newblkno), 0, BLKSIZE);
  800848:	e8 24 fe ff ff       	call   800671 <blockno_to_va>
  80084d:	83 ec 04             	sub    $0x4,%esp
  800850:	68 00 10 00 00       	push   $0x1000
  800855:	6a 00                	push   $0x0
  800857:	50                   	push   %eax
  800858:	e8 08 19 00 00       	call   802165 <memset>

			// Make it the indirect block
			f->f_indirect = newblkno;
  80085d:	89 be b0 00 00 00    	mov    %edi,0xb0(%esi)
  800863:	83 c4 10             	add    $0x10,%esp
			return -E_NOT_FOUND;
		}
	}

	// Access the indirect block
	uint32_t *indirect_blk = (uint32_t *) blockno_to_va(f->f_indirect);
  800866:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  80086c:	e8 00 fe ff ff       	call   800671 <blockno_to_va>
	*ppdiskbno = &indirect_blk[filebno - NDIRECT];
  800871:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  800875:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800878:	89 03                	mov    %eax,(%ebx)
	return 0;
  80087a:	b8 00 00 00 00       	mov    $0x0,%eax
  80087f:	eb 13                	jmp    800894 <file_block_walk+0x96>
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
       // LAB 5: Your code here.
	// Checks if filebno is valid
	if (filebno >= NDIRECT + NINDIRECT)
		return -E_INVAL;
  800881:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800886:	eb 0c                	jmp    800894 <file_block_walk+0x96>
			memset(blockno_to_va(newblkno), 0, BLKSIZE);

			// Make it the indirect block
			f->f_indirect = newblkno;
		} else {
			return -E_NOT_FOUND;
  800888:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  80088d:	eb 05                	jmp    800894 <file_block_walk+0x96>
	if (f->f_indirect == 0) {
		if (alloc) {
			// Allocate the a new block
			int newblkno;
			if ((newblkno = alloc_block()) < 0)
				return -E_NO_DISK;
  80088f:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax

	// Access the indirect block
	uint32_t *indirect_blk = (uint32_t *) blockno_to_va(f->f_indirect);
	*ppdiskbno = &indirect_blk[filebno - NDIRECT];
	return 0;
}
  800894:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800897:	5b                   	pop    %ebx
  800898:	5e                   	pop    %esi
  800899:	5f                   	pop    %edi
  80089a:	5d                   	pop    %ebp
  80089b:	c3                   	ret    

0080089c <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	56                   	push   %esi
  8008a0:	53                   	push   %ebx
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  8008a1:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8008a6:	8b 70 04             	mov    0x4(%eax),%esi
  8008a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8008ae:	eb 29                	jmp    8008d9 <check_bitmap+0x3d>
		assert(!block_is_free(2+i));
  8008b0:	8d 43 02             	lea    0x2(%ebx),%eax
  8008b3:	50                   	push   %eax
  8008b4:	e8 38 fe ff ff       	call   8006f1 <block_is_free>
  8008b9:	83 c4 04             	add    $0x4,%esp
  8008bc:	84 c0                	test   %al,%al
  8008be:	74 16                	je     8008d6 <check_bitmap+0x3a>
  8008c0:	68 6f 3f 80 00       	push   $0x803f6f
  8008c5:	68 fd 3c 80 00       	push   $0x803cfd
  8008ca:	6a 5e                	push   $0x5e
  8008cc:	68 02 3f 80 00       	push   $0x803f02
  8008d1:	e8 ec 10 00 00       	call   8019c2 <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  8008d6:	83 c3 01             	add    $0x1,%ebx
  8008d9:	89 d8                	mov    %ebx,%eax
  8008db:	c1 e0 0f             	shl    $0xf,%eax
  8008de:	39 f0                	cmp    %esi,%eax
  8008e0:	72 ce                	jb     8008b0 <check_bitmap+0x14>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  8008e2:	83 ec 0c             	sub    $0xc,%esp
  8008e5:	6a 00                	push   $0x0
  8008e7:	e8 05 fe ff ff       	call   8006f1 <block_is_free>
  8008ec:	83 c4 10             	add    $0x10,%esp
  8008ef:	84 c0                	test   %al,%al
  8008f1:	74 16                	je     800909 <check_bitmap+0x6d>
  8008f3:	68 83 3f 80 00       	push   $0x803f83
  8008f8:	68 fd 3c 80 00       	push   $0x803cfd
  8008fd:	6a 61                	push   $0x61
  8008ff:	68 02 3f 80 00       	push   $0x803f02
  800904:	e8 b9 10 00 00       	call   8019c2 <_panic>
	assert(!block_is_free(1));
  800909:	83 ec 0c             	sub    $0xc,%esp
  80090c:	6a 01                	push   $0x1
  80090e:	e8 de fd ff ff       	call   8006f1 <block_is_free>
  800913:	83 c4 10             	add    $0x10,%esp
  800916:	84 c0                	test   %al,%al
  800918:	74 16                	je     800930 <check_bitmap+0x94>
  80091a:	68 95 3f 80 00       	push   $0x803f95
  80091f:	68 fd 3c 80 00       	push   $0x803cfd
  800924:	6a 62                	push   $0x62
  800926:	68 02 3f 80 00       	push   $0x803f02
  80092b:	e8 92 10 00 00       	call   8019c2 <_panic>

	cprintf("bitmap is good\n");
  800930:	83 ec 0c             	sub    $0xc,%esp
  800933:	68 a7 3f 80 00       	push   $0x803fa7
  800938:	e8 5e 11 00 00       	call   801a9b <cprintf>
}
  80093d:	83 c4 10             	add    $0x10,%esp
  800940:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800943:	5b                   	pop    %ebx
  800944:	5e                   	pop    %esi
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    

00800947 <fs_init>:


// Initialize the file system
void
fs_init(void)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	83 ec 08             	sub    $0x8,%esp
	static_assert(sizeof(struct File) == 256);

       // Find a JOS disk.  Use the second IDE disk (number 1) if availabl
       if (ide_probe_disk1())
  80094d:	e8 0d f7 ff ff       	call   80005f <ide_probe_disk1>
  800952:	84 c0                	test   %al,%al
  800954:	74 0f                	je     800965 <fs_init+0x1e>
               ide_set_disk(1);
  800956:	83 ec 0c             	sub    $0xc,%esp
  800959:	6a 01                	push   $0x1
  80095b:	e8 63 f7 ff ff       	call   8000c3 <ide_set_disk>
  800960:	83 c4 10             	add    $0x10,%esp
  800963:	eb 0d                	jmp    800972 <fs_init+0x2b>
       else
               ide_set_disk(0);
  800965:	83 ec 0c             	sub    $0xc,%esp
  800968:	6a 00                	push   $0x0
  80096a:	e8 54 f7 ff ff       	call   8000c3 <ide_set_disk>
  80096f:	83 c4 10             	add    $0x10,%esp
	bc_init();
  800972:	e8 55 fb ff ff       	call   8004cc <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  800977:	83 ec 0c             	sub    $0xc,%esp
  80097a:	6a 01                	push   $0x1
  80097c:	e8 0d fa ff ff       	call   80038e <diskaddr>
  800981:	a3 0c a0 80 00       	mov    %eax,0x80a00c
	check_super();
  800986:	e8 10 fd ff ff       	call   80069b <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  80098b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800992:	e8 f7 f9 ff ff       	call   80038e <diskaddr>
  800997:	a3 08 a0 80 00       	mov    %eax,0x80a008
	check_bitmap();
  80099c:	e8 fb fe ff ff       	call   80089c <check_bitmap>
	
}
  8009a1:	83 c4 10             	add    $0x10,%esp
  8009a4:	c9                   	leave  
  8009a5:	c3                   	ret    

008009a6 <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	53                   	push   %ebx
  8009aa:	83 ec 20             	sub    $0x20,%esp
       // LAB 5: Your code here.
	// Retrieve the blockno_entry of the 'filebno'th block of file 'f'
	uint32_t *blockno_entry;
	int r;
	if ((r = file_block_walk(f, filebno, &blockno_entry, 1)) < 0) {
  8009ad:	6a 01                	push   $0x1
  8009af:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  8009b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b8:	e8 41 fe ff ff       	call   8007fe <file_block_walk>
  8009bd:	83 c4 10             	add    $0x10,%esp
  8009c0:	85 c0                	test   %eax,%eax
  8009c2:	78 4b                	js     800a0f <file_get_block+0x69>
		return r; // -E_INVAL or -E_NO_DISK
	}

	// If the block is not allocated, allocate it
	if (*blockno_entry == 0) {
  8009c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009c7:	83 38 00             	cmpl   $0x0,(%eax)
  8009ca:	75 28                	jne    8009f4 <file_get_block+0x4e>
		// Tries to allocate a new block
		int newblkno;
		if ((newblkno = alloc_block()) < 0)
  8009cc:	e8 99 fd ff ff       	call   80076a <alloc_block>
  8009d1:	89 c3                	mov    %eax,%ebx
  8009d3:	85 c0                	test   %eax,%eax
  8009d5:	78 33                	js     800a0a <file_get_block+0x64>
			return -E_NO_DISK;

		// Clear the allocated block
		memset(blockno_to_va(newblkno), 0, BLKSIZE);
  8009d7:	e8 95 fc ff ff       	call   800671 <blockno_to_va>
  8009dc:	83 ec 04             	sub    $0x4,%esp
  8009df:	68 00 10 00 00       	push   $0x1000
  8009e4:	6a 00                	push   $0x0
  8009e6:	50                   	push   %eax
  8009e7:	e8 79 17 00 00       	call   802165 <memset>

		// Update the value
		*blockno_entry = newblkno;
  8009ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009ef:	89 18                	mov    %ebx,(%eax)
  8009f1:	83 c4 10             	add    $0x10,%esp
	}

	// Set *blk to the va where the block is mapped
	*blk = blockno_to_va(*blockno_entry);
  8009f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009f7:	8b 00                	mov    (%eax),%eax
  8009f9:	e8 73 fc ff ff       	call   800671 <blockno_to_va>
  8009fe:	8b 55 10             	mov    0x10(%ebp),%edx
  800a01:	89 02                	mov    %eax,(%edx)
	return 0;
  800a03:	b8 00 00 00 00       	mov    $0x0,%eax
  800a08:	eb 05                	jmp    800a0f <file_get_block+0x69>
	// If the block is not allocated, allocate it
	if (*blockno_entry == 0) {
		// Tries to allocate a new block
		int newblkno;
		if ((newblkno = alloc_block()) < 0)
			return -E_NO_DISK;
  800a0a:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
	}

	// Set *blk to the va where the block is mapped
	*blk = blockno_to_va(*blockno_entry);
	return 0;
}
  800a0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a12:	c9                   	leave  
  800a13:	c3                   	ret    

00800a14 <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	57                   	push   %edi
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
  800a1a:	81 ec bc 00 00 00    	sub    $0xbc,%esp
  800a20:	89 95 40 ff ff ff    	mov    %edx,-0xc0(%ebp)
  800a26:	89 8d 3c ff ff ff    	mov    %ecx,-0xc4(%ebp)
  800a2c:	eb 03                	jmp    800a31 <walk_path+0x1d>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800a2e:	83 c0 01             	add    $0x1,%eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800a31:	80 38 2f             	cmpb   $0x2f,(%eax)
  800a34:	74 f8                	je     800a2e <walk_path+0x1a>
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  800a36:	8b 0d 0c a0 80 00    	mov    0x80a00c,%ecx
  800a3c:	83 c1 08             	add    $0x8,%ecx
  800a3f:	89 8d 4c ff ff ff    	mov    %ecx,-0xb4(%ebp)
	dir = 0;
	name[0] = 0;
  800a45:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  800a4c:	8b 8d 40 ff ff ff    	mov    -0xc0(%ebp),%ecx
  800a52:	85 c9                	test   %ecx,%ecx
  800a54:	74 06                	je     800a5c <walk_path+0x48>
		*pdir = 0;
  800a56:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	*pf = 0;
  800a5c:	8b 8d 3c ff ff ff    	mov    -0xc4(%ebp),%ecx
  800a62:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
	dir = 0;
  800a68:	ba 00 00 00 00       	mov    $0x0,%edx
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800a6d:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800a73:	e9 5f 01 00 00       	jmp    800bd7 <walk_path+0x1c3>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  800a78:	83 c7 01             	add    $0x1,%edi
  800a7b:	eb 02                	jmp    800a7f <walk_path+0x6b>
  800a7d:	89 c7                	mov    %eax,%edi
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800a7f:	0f b6 17             	movzbl (%edi),%edx
  800a82:	80 fa 2f             	cmp    $0x2f,%dl
  800a85:	74 04                	je     800a8b <walk_path+0x77>
  800a87:	84 d2                	test   %dl,%dl
  800a89:	75 ed                	jne    800a78 <walk_path+0x64>
			path++;
		if (path - p >= MAXNAMELEN)
  800a8b:	89 fb                	mov    %edi,%ebx
  800a8d:	29 c3                	sub    %eax,%ebx
  800a8f:	83 fb 7f             	cmp    $0x7f,%ebx
  800a92:	0f 8f 69 01 00 00    	jg     800c01 <walk_path+0x1ed>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800a98:	83 ec 04             	sub    $0x4,%esp
  800a9b:	53                   	push   %ebx
  800a9c:	50                   	push   %eax
  800a9d:	56                   	push   %esi
  800a9e:	e8 0f 17 00 00       	call   8021b2 <memmove>
		name[path - p] = '\0';
  800aa3:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800aaa:	00 
  800aab:	83 c4 10             	add    $0x10,%esp
  800aae:	eb 03                	jmp    800ab3 <walk_path+0x9f>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800ab0:	83 c7 01             	add    $0x1,%edi

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800ab3:	80 3f 2f             	cmpb   $0x2f,(%edi)
  800ab6:	74 f8                	je     800ab0 <walk_path+0x9c>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
  800ab8:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800abe:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800ac5:	0f 85 3d 01 00 00    	jne    800c08 <walk_path+0x1f4>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800acb:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800ad1:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800ad6:	74 19                	je     800af1 <walk_path+0xdd>
  800ad8:	68 b7 3f 80 00       	push   $0x803fb7
  800add:	68 fd 3c 80 00       	push   $0x803cfd
  800ae2:	68 fa 00 00 00       	push   $0xfa
  800ae7:	68 02 3f 80 00       	push   $0x803f02
  800aec:	e8 d1 0e 00 00       	call   8019c2 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800af1:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800af7:	85 c0                	test   %eax,%eax
  800af9:	0f 48 c2             	cmovs  %edx,%eax
  800afc:	c1 f8 0c             	sar    $0xc,%eax
  800aff:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)
	for (i = 0; i < nblock; i++) {
  800b05:	c7 85 50 ff ff ff 00 	movl   $0x0,-0xb0(%ebp)
  800b0c:	00 00 00 
  800b0f:	89 bd 44 ff ff ff    	mov    %edi,-0xbc(%ebp)
  800b15:	eb 5e                	jmp    800b75 <walk_path+0x161>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800b17:	83 ec 04             	sub    $0x4,%esp
  800b1a:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800b20:	50                   	push   %eax
  800b21:	ff b5 50 ff ff ff    	pushl  -0xb0(%ebp)
  800b27:	ff b5 4c ff ff ff    	pushl  -0xb4(%ebp)
  800b2d:	e8 74 fe ff ff       	call   8009a6 <file_get_block>
  800b32:	83 c4 10             	add    $0x10,%esp
  800b35:	85 c0                	test   %eax,%eax
  800b37:	0f 88 ee 00 00 00    	js     800c2b <walk_path+0x217>
			return r;
		f = (struct File*) blk;
  800b3d:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
  800b43:	8d bb 00 10 00 00    	lea    0x1000(%ebx),%edi
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800b49:	89 9d 54 ff ff ff    	mov    %ebx,-0xac(%ebp)
  800b4f:	83 ec 08             	sub    $0x8,%esp
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
  800b54:	e8 71 15 00 00       	call   8020ca <strcmp>
  800b59:	83 c4 10             	add    $0x10,%esp
  800b5c:	85 c0                	test   %eax,%eax
  800b5e:	0f 84 ab 00 00 00    	je     800c0f <walk_path+0x1fb>
  800b64:	81 c3 00 01 00 00    	add    $0x100,%ebx
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800b6a:	39 fb                	cmp    %edi,%ebx
  800b6c:	75 db                	jne    800b49 <walk_path+0x135>
	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800b6e:	83 85 50 ff ff ff 01 	addl   $0x1,-0xb0(%ebp)
  800b75:	8b 8d 50 ff ff ff    	mov    -0xb0(%ebp),%ecx
  800b7b:	39 8d 48 ff ff ff    	cmp    %ecx,-0xb8(%ebp)
  800b81:	75 94                	jne    800b17 <walk_path+0x103>
  800b83:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  800b89:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800b8e:	80 3f 00             	cmpb   $0x0,(%edi)
  800b91:	0f 85 a3 00 00 00    	jne    800c3a <walk_path+0x226>
				if (pdir)
  800b97:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800b9d:	85 c0                	test   %eax,%eax
  800b9f:	74 08                	je     800ba9 <walk_path+0x195>
					*pdir = dir;
  800ba1:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800ba7:	89 08                	mov    %ecx,(%eax)
				if (lastelem)
  800ba9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800bad:	74 15                	je     800bc4 <walk_path+0x1b0>
					strcpy(lastelem, name);
  800baf:	83 ec 08             	sub    $0x8,%esp
  800bb2:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800bb8:	50                   	push   %eax
  800bb9:	ff 75 08             	pushl  0x8(%ebp)
  800bbc:	e8 5f 14 00 00       	call   802020 <strcpy>
  800bc1:	83 c4 10             	add    $0x10,%esp
				*pf = 0;
  800bc4:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800bca:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  800bd0:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800bd5:	eb 63                	jmp    800c3a <walk_path+0x226>
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800bd7:	80 38 00             	cmpb   $0x0,(%eax)
  800bda:	0f 85 9d fe ff ff    	jne    800a7d <walk_path+0x69>
			}
			return r;
		}
	}

	if (pdir)
  800be0:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800be6:	85 c0                	test   %eax,%eax
  800be8:	74 02                	je     800bec <walk_path+0x1d8>
		*pdir = dir;
  800bea:	89 10                	mov    %edx,(%eax)
	*pf = f;
  800bec:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800bf2:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800bf8:	89 08                	mov    %ecx,(%eax)
	return 0;
  800bfa:	b8 00 00 00 00       	mov    $0x0,%eax
  800bff:	eb 39                	jmp    800c3a <walk_path+0x226>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
  800c01:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800c06:	eb 32                	jmp    800c3a <walk_path+0x226>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;
  800c08:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800c0d:	eb 2b                	jmp    800c3a <walk_path+0x226>
  800c0f:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
  800c15:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800c1b:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800c21:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
  800c27:	89 f8                	mov    %edi,%eax
  800c29:	eb ac                	jmp    800bd7 <walk_path+0x1c3>
  800c2b:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800c31:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800c34:	0f 84 4f ff ff ff    	je     800b89 <walk_path+0x175>

	if (pdir)
		*pdir = dir;
	*pf = f;
	return 0;
}
  800c3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3d:	5b                   	pop    %ebx
  800c3e:	5e                   	pop    %esi
  800c3f:	5f                   	pop    %edi
  800c40:	5d                   	pop    %ebp
  800c41:	c3                   	ret    

00800c42 <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	83 ec 14             	sub    $0x14,%esp
	return walk_path(path, 0, pf, 0);
  800c48:	6a 00                	push   $0x0
  800c4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c52:	8b 45 08             	mov    0x8(%ebp),%eax
  800c55:	e8 ba fd ff ff       	call   800a14 <walk_path>
}
  800c5a:	c9                   	leave  
  800c5b:	c3                   	ret    

00800c5c <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	57                   	push   %edi
  800c60:	56                   	push   %esi
  800c61:	53                   	push   %ebx
  800c62:	83 ec 2c             	sub    $0x2c,%esp
  800c65:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c68:	8b 4d 14             	mov    0x14(%ebp),%ecx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800c6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6e:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
		return 0;
  800c74:	b8 00 00 00 00       	mov    $0x0,%eax
{
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800c79:	39 ca                	cmp    %ecx,%edx
  800c7b:	7e 7c                	jle    800cf9 <file_read+0x9d>
		return 0;

	count = MIN(count, f->f_size - offset);
  800c7d:	29 ca                	sub    %ecx,%edx
  800c7f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c82:	0f 47 55 10          	cmova  0x10(%ebp),%edx
  800c86:	89 55 d0             	mov    %edx,-0x30(%ebp)

	for (pos = offset; pos < offset + count; ) {
  800c89:	89 ce                	mov    %ecx,%esi
  800c8b:	01 d1                	add    %edx,%ecx
  800c8d:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800c90:	eb 5d                	jmp    800cef <file_read+0x93>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800c92:	83 ec 04             	sub    $0x4,%esp
  800c95:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800c98:	50                   	push   %eax
  800c99:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800c9f:	85 f6                	test   %esi,%esi
  800ca1:	0f 49 c6             	cmovns %esi,%eax
  800ca4:	c1 f8 0c             	sar    $0xc,%eax
  800ca7:	50                   	push   %eax
  800ca8:	ff 75 08             	pushl  0x8(%ebp)
  800cab:	e8 f6 fc ff ff       	call   8009a6 <file_get_block>
  800cb0:	83 c4 10             	add    $0x10,%esp
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	78 42                	js     800cf9 <file_read+0x9d>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800cb7:	89 f2                	mov    %esi,%edx
  800cb9:	c1 fa 1f             	sar    $0x1f,%edx
  800cbc:	c1 ea 14             	shr    $0x14,%edx
  800cbf:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800cc2:	25 ff 0f 00 00       	and    $0xfff,%eax
  800cc7:	29 d0                	sub    %edx,%eax
  800cc9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800ccc:	29 da                	sub    %ebx,%edx
  800cce:	bb 00 10 00 00       	mov    $0x1000,%ebx
  800cd3:	29 c3                	sub    %eax,%ebx
  800cd5:	39 da                	cmp    %ebx,%edx
  800cd7:	0f 46 da             	cmovbe %edx,%ebx
		memmove(buf, blk + pos % BLKSIZE, bn);
  800cda:	83 ec 04             	sub    $0x4,%esp
  800cdd:	53                   	push   %ebx
  800cde:	03 45 e4             	add    -0x1c(%ebp),%eax
  800ce1:	50                   	push   %eax
  800ce2:	57                   	push   %edi
  800ce3:	e8 ca 14 00 00       	call   8021b2 <memmove>
		pos += bn;
  800ce8:	01 de                	add    %ebx,%esi
		buf += bn;
  800cea:	01 df                	add    %ebx,%edi
  800cec:	83 c4 10             	add    $0x10,%esp
	if (offset >= f->f_size)
		return 0;

	count = MIN(count, f->f_size - offset);

	for (pos = offset; pos < offset + count; ) {
  800cef:	89 f3                	mov    %esi,%ebx
  800cf1:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800cf4:	77 9c                	ja     800c92 <file_read+0x36>
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800cf6:	8b 45 d0             	mov    -0x30(%ebp),%eax
}
  800cf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfc:	5b                   	pop    %ebx
  800cfd:	5e                   	pop    %esi
  800cfe:	5f                   	pop    %edi
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    

00800d01 <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800d01:	55                   	push   %ebp
  800d02:	89 e5                	mov    %esp,%ebp
  800d04:	57                   	push   %edi
  800d05:	56                   	push   %esi
  800d06:	53                   	push   %ebx
  800d07:	83 ec 2c             	sub    $0x2c,%esp
  800d0a:	8b 75 08             	mov    0x8(%ebp),%esi
	if (f->f_size > newsize)
  800d0d:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800d13:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800d16:	0f 8e a7 00 00 00    	jle    800dc3 <file_set_size+0xc2>
file_truncate_blocks(struct File *f, off_t newsize)
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800d1c:	8d b8 fe 1f 00 00    	lea    0x1ffe(%eax),%edi
  800d22:	05 ff 0f 00 00       	add    $0xfff,%eax
  800d27:	0f 49 f8             	cmovns %eax,%edi
  800d2a:	c1 ff 0c             	sar    $0xc,%edi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800d2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d30:	05 fe 1f 00 00       	add    $0x1ffe,%eax
  800d35:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d38:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800d3e:	0f 49 c2             	cmovns %edx,%eax
  800d41:	c1 f8 0c             	sar    $0xc,%eax
  800d44:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800d47:	89 c3                	mov    %eax,%ebx
  800d49:	eb 39                	jmp    800d84 <file_set_size+0x83>
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800d4b:	83 ec 0c             	sub    $0xc,%esp
  800d4e:	6a 00                	push   $0x0
  800d50:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800d53:	89 da                	mov    %ebx,%edx
  800d55:	89 f0                	mov    %esi,%eax
  800d57:	e8 a2 fa ff ff       	call   8007fe <file_block_walk>
  800d5c:	83 c4 10             	add    $0x10,%esp
  800d5f:	85 c0                	test   %eax,%eax
  800d61:	78 4d                	js     800db0 <file_set_size+0xaf>
		return r;
	if (*ptr) {
  800d63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d66:	8b 00                	mov    (%eax),%eax
  800d68:	85 c0                	test   %eax,%eax
  800d6a:	74 15                	je     800d81 <file_set_size+0x80>
		free_block(*ptr);
  800d6c:	83 ec 0c             	sub    $0xc,%esp
  800d6f:	50                   	push   %eax
  800d70:	e8 b9 f9 ff ff       	call   80072e <free_block>
		*ptr = 0;
  800d75:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d78:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800d7e:	83 c4 10             	add    $0x10,%esp
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800d81:	83 c3 01             	add    $0x1,%ebx
  800d84:	39 df                	cmp    %ebx,%edi
  800d86:	77 c3                	ja     800d4b <file_set_size+0x4a>
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800d88:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  800d8c:	77 35                	ja     800dc3 <file_set_size+0xc2>
  800d8e:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800d94:	85 c0                	test   %eax,%eax
  800d96:	74 2b                	je     800dc3 <file_set_size+0xc2>
		free_block(f->f_indirect);
  800d98:	83 ec 0c             	sub    $0xc,%esp
  800d9b:	50                   	push   %eax
  800d9c:	e8 8d f9 ff ff       	call   80072e <free_block>
		f->f_indirect = 0;
  800da1:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  800da8:	00 00 00 
  800dab:	83 c4 10             	add    $0x10,%esp
  800dae:	eb 13                	jmp    800dc3 <file_set_size+0xc2>

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);
  800db0:	83 ec 08             	sub    $0x8,%esp
  800db3:	50                   	push   %eax
  800db4:	68 d4 3f 80 00       	push   $0x803fd4
  800db9:	e8 dd 0c 00 00       	call   801a9b <cprintf>
  800dbe:	83 c4 10             	add    $0x10,%esp
  800dc1:	eb be                	jmp    800d81 <file_set_size+0x80>
int
file_set_size(struct File *f, off_t newsize)
{
	if (f->f_size > newsize)
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  800dc3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dc6:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	flush_block(f);
  800dcc:	83 ec 0c             	sub    $0xc,%esp
  800dcf:	56                   	push   %esi
  800dd0:	e8 37 f6 ff ff       	call   80040c <flush_block>
	return 0;
}
  800dd5:	b8 00 00 00 00       	mov    $0x0,%eax
  800dda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	57                   	push   %edi
  800de6:	56                   	push   %esi
  800de7:	53                   	push   %ebx
  800de8:	83 ec 2c             	sub    $0x2c,%esp
  800deb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800dee:	8b 75 14             	mov    0x14(%ebp),%esi
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  800df1:	89 f0                	mov    %esi,%eax
  800df3:	03 45 10             	add    0x10(%ebp),%eax
  800df6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800df9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dfc:	3b 81 80 00 00 00    	cmp    0x80(%ecx),%eax
  800e02:	76 72                	jbe    800e76 <file_write+0x94>
		if ((r = file_set_size(f, offset + count)) < 0)
  800e04:	83 ec 08             	sub    $0x8,%esp
  800e07:	50                   	push   %eax
  800e08:	51                   	push   %ecx
  800e09:	e8 f3 fe ff ff       	call   800d01 <file_set_size>
  800e0e:	83 c4 10             	add    $0x10,%esp
  800e11:	85 c0                	test   %eax,%eax
  800e13:	79 61                	jns    800e76 <file_write+0x94>
  800e15:	eb 69                	jmp    800e80 <file_write+0x9e>
			return r;

	for (pos = offset; pos < offset + count; ) {
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800e17:	83 ec 04             	sub    $0x4,%esp
  800e1a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800e1d:	50                   	push   %eax
  800e1e:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800e24:	85 f6                	test   %esi,%esi
  800e26:	0f 49 c6             	cmovns %esi,%eax
  800e29:	c1 f8 0c             	sar    $0xc,%eax
  800e2c:	50                   	push   %eax
  800e2d:	ff 75 08             	pushl  0x8(%ebp)
  800e30:	e8 71 fb ff ff       	call   8009a6 <file_get_block>
  800e35:	83 c4 10             	add    $0x10,%esp
  800e38:	85 c0                	test   %eax,%eax
  800e3a:	78 44                	js     800e80 <file_write+0x9e>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800e3c:	89 f2                	mov    %esi,%edx
  800e3e:	c1 fa 1f             	sar    $0x1f,%edx
  800e41:	c1 ea 14             	shr    $0x14,%edx
  800e44:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800e47:	25 ff 0f 00 00       	and    $0xfff,%eax
  800e4c:	29 d0                	sub    %edx,%eax
  800e4e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800e51:	29 d9                	sub    %ebx,%ecx
  800e53:	89 cb                	mov    %ecx,%ebx
  800e55:	ba 00 10 00 00       	mov    $0x1000,%edx
  800e5a:	29 c2                	sub    %eax,%edx
  800e5c:	39 d1                	cmp    %edx,%ecx
  800e5e:	0f 47 da             	cmova  %edx,%ebx
		memmove(blk + pos % BLKSIZE, buf, bn);
  800e61:	83 ec 04             	sub    $0x4,%esp
  800e64:	53                   	push   %ebx
  800e65:	57                   	push   %edi
  800e66:	03 45 e4             	add    -0x1c(%ebp),%eax
  800e69:	50                   	push   %eax
  800e6a:	e8 43 13 00 00       	call   8021b2 <memmove>
		pos += bn;
  800e6f:	01 de                	add    %ebx,%esi
		buf += bn;
  800e71:	01 df                	add    %ebx,%edi
  800e73:	83 c4 10             	add    $0x10,%esp
	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
  800e76:	89 f3                	mov    %esi,%ebx
  800e78:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800e7b:	77 9a                	ja     800e17 <file_write+0x35>
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800e7d:	8b 45 10             	mov    0x10(%ebp),%eax
}
  800e80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e83:	5b                   	pop    %ebx
  800e84:	5e                   	pop    %esi
  800e85:	5f                   	pop    %edi
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    

00800e88 <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	56                   	push   %esi
  800e8c:	53                   	push   %ebx
  800e8d:	83 ec 10             	sub    $0x10,%esp
  800e90:	8b 75 08             	mov    0x8(%ebp),%esi
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800e93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e98:	eb 3c                	jmp    800ed6 <file_flush+0x4e>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800e9a:	83 ec 0c             	sub    $0xc,%esp
  800e9d:	6a 00                	push   $0x0
  800e9f:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800ea2:	89 da                	mov    %ebx,%edx
  800ea4:	89 f0                	mov    %esi,%eax
  800ea6:	e8 53 f9 ff ff       	call   8007fe <file_block_walk>
  800eab:	83 c4 10             	add    $0x10,%esp
  800eae:	85 c0                	test   %eax,%eax
  800eb0:	78 21                	js     800ed3 <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  800eb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800eb5:	85 c0                	test   %eax,%eax
  800eb7:	74 1a                	je     800ed3 <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  800eb9:	8b 00                	mov    (%eax),%eax
  800ebb:	85 c0                	test   %eax,%eax
  800ebd:	74 14                	je     800ed3 <file_flush+0x4b>
			continue;
		flush_block(diskaddr(*pdiskbno));
  800ebf:	83 ec 0c             	sub    $0xc,%esp
  800ec2:	50                   	push   %eax
  800ec3:	e8 c6 f4 ff ff       	call   80038e <diskaddr>
  800ec8:	89 04 24             	mov    %eax,(%esp)
  800ecb:	e8 3c f5 ff ff       	call   80040c <flush_block>
  800ed0:	83 c4 10             	add    $0x10,%esp
file_flush(struct File *f)
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800ed3:	83 c3 01             	add    $0x1,%ebx
  800ed6:	8b 96 80 00 00 00    	mov    0x80(%esi),%edx
  800edc:	8d 8a ff 0f 00 00    	lea    0xfff(%edx),%ecx
  800ee2:	8d 82 fe 1f 00 00    	lea    0x1ffe(%edx),%eax
  800ee8:	85 c9                	test   %ecx,%ecx
  800eea:	0f 49 c1             	cmovns %ecx,%eax
  800eed:	c1 f8 0c             	sar    $0xc,%eax
  800ef0:	39 c3                	cmp    %eax,%ebx
  800ef2:	7c a6                	jl     800e9a <file_flush+0x12>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  800ef4:	83 ec 0c             	sub    $0xc,%esp
  800ef7:	56                   	push   %esi
  800ef8:	e8 0f f5 ff ff       	call   80040c <flush_block>
	if (f->f_indirect)
  800efd:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800f03:	83 c4 10             	add    $0x10,%esp
  800f06:	85 c0                	test   %eax,%eax
  800f08:	74 14                	je     800f1e <file_flush+0x96>
		flush_block(diskaddr(f->f_indirect));
  800f0a:	83 ec 0c             	sub    $0xc,%esp
  800f0d:	50                   	push   %eax
  800f0e:	e8 7b f4 ff ff       	call   80038e <diskaddr>
  800f13:	89 04 24             	mov    %eax,(%esp)
  800f16:	e8 f1 f4 ff ff       	call   80040c <flush_block>
  800f1b:	83 c4 10             	add    $0x10,%esp
}
  800f1e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f21:	5b                   	pop    %ebx
  800f22:	5e                   	pop    %esi
  800f23:	5d                   	pop    %ebp
  800f24:	c3                   	ret    

00800f25 <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  800f25:	55                   	push   %ebp
  800f26:	89 e5                	mov    %esp,%ebp
  800f28:	57                   	push   %edi
  800f29:	56                   	push   %esi
  800f2a:	53                   	push   %ebx
  800f2b:	81 ec b8 00 00 00    	sub    $0xb8,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  800f31:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800f37:	50                   	push   %eax
  800f38:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  800f3e:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  800f44:	8b 45 08             	mov    0x8(%ebp),%eax
  800f47:	e8 c8 fa ff ff       	call   800a14 <walk_path>
  800f4c:	83 c4 10             	add    $0x10,%esp
  800f4f:	85 c0                	test   %eax,%eax
  800f51:	0f 84 d1 00 00 00    	je     801028 <file_create+0x103>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  800f57:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800f5a:	0f 85 0c 01 00 00    	jne    80106c <file_create+0x147>
  800f60:	8b b5 64 ff ff ff    	mov    -0x9c(%ebp),%esi
  800f66:	85 f6                	test   %esi,%esi
  800f68:	0f 84 c1 00 00 00    	je     80102f <file_create+0x10a>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  800f6e:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800f74:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800f79:	74 19                	je     800f94 <file_create+0x6f>
  800f7b:	68 b7 3f 80 00       	push   $0x803fb7
  800f80:	68 fd 3c 80 00       	push   $0x803cfd
  800f85:	68 13 01 00 00       	push   $0x113
  800f8a:	68 02 3f 80 00       	push   $0x803f02
  800f8f:	e8 2e 0a 00 00       	call   8019c2 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800f94:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800f9a:	85 c0                	test   %eax,%eax
  800f9c:	0f 48 c2             	cmovs  %edx,%eax
  800f9f:	c1 f8 0c             	sar    $0xc,%eax
  800fa2:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
  800fa8:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800fad:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  800fb3:	eb 3b                	jmp    800ff0 <file_create+0xcb>
  800fb5:	83 ec 04             	sub    $0x4,%esp
  800fb8:	57                   	push   %edi
  800fb9:	53                   	push   %ebx
  800fba:	56                   	push   %esi
  800fbb:	e8 e6 f9 ff ff       	call   8009a6 <file_get_block>
  800fc0:	83 c4 10             	add    $0x10,%esp
  800fc3:	85 c0                	test   %eax,%eax
  800fc5:	0f 88 a1 00 00 00    	js     80106c <file_create+0x147>
			return r;
		f = (struct File*) blk;
  800fcb:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  800fd1:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
		for (j = 0; j < BLKFILES; j++)
			if (f[j].f_name[0] == '\0') {
  800fd7:	80 38 00             	cmpb   $0x0,(%eax)
  800fda:	75 08                	jne    800fe4 <file_create+0xbf>
				*file = &f[j];
  800fdc:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  800fe2:	eb 52                	jmp    801036 <file_create+0x111>
  800fe4:	05 00 01 00 00       	add    $0x100,%eax
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800fe9:	39 d0                	cmp    %edx,%eax
  800feb:	75 ea                	jne    800fd7 <file_create+0xb2>
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800fed:	83 c3 01             	add    $0x1,%ebx
  800ff0:	39 9d 54 ff ff ff    	cmp    %ebx,-0xac(%ebp)
  800ff6:	75 bd                	jne    800fb5 <file_create+0x90>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  800ff8:	81 86 80 00 00 00 00 	addl   $0x1000,0x80(%esi)
  800fff:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  801002:	83 ec 04             	sub    $0x4,%esp
  801005:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  80100b:	50                   	push   %eax
  80100c:	53                   	push   %ebx
  80100d:	56                   	push   %esi
  80100e:	e8 93 f9 ff ff       	call   8009a6 <file_get_block>
  801013:	83 c4 10             	add    $0x10,%esp
  801016:	85 c0                	test   %eax,%eax
  801018:	78 52                	js     80106c <file_create+0x147>
		return r;
	f = (struct File*) blk;
	*file = &f[0];
  80101a:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  801020:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  801026:	eb 0e                	jmp    801036 <file_create+0x111>
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
		return -E_FILE_EXISTS;
  801028:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  80102d:	eb 3d                	jmp    80106c <file_create+0x147>
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
  80102f:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  801034:	eb 36                	jmp    80106c <file_create+0x147>
	if ((r = dir_alloc_file(dir, &f)) < 0)
		return r;

	strcpy(f->f_name, name);
  801036:	83 ec 08             	sub    $0x8,%esp
  801039:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  80103f:	50                   	push   %eax
  801040:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
  801046:	e8 d5 0f 00 00       	call   802020 <strcpy>
	*pf = f;
  80104b:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  801051:	8b 45 0c             	mov    0xc(%ebp),%eax
  801054:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  801056:	83 c4 04             	add    $0x4,%esp
  801059:	ff b5 64 ff ff ff    	pushl  -0x9c(%ebp)
  80105f:	e8 24 fe ff ff       	call   800e88 <file_flush>
	return 0;
  801064:	83 c4 10             	add    $0x10,%esp
  801067:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80106c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80106f:	5b                   	pop    %ebx
  801070:	5e                   	pop    %esi
  801071:	5f                   	pop    %edi
  801072:	5d                   	pop    %ebp
  801073:	c3                   	ret    

00801074 <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  801074:	55                   	push   %ebp
  801075:	89 e5                	mov    %esp,%ebp
  801077:	53                   	push   %ebx
  801078:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  80107b:	bb 01 00 00 00       	mov    $0x1,%ebx
  801080:	eb 17                	jmp    801099 <fs_sync+0x25>
		flush_block(diskaddr(i));
  801082:	83 ec 0c             	sub    $0xc,%esp
  801085:	53                   	push   %ebx
  801086:	e8 03 f3 ff ff       	call   80038e <diskaddr>
  80108b:	89 04 24             	mov    %eax,(%esp)
  80108e:	e8 79 f3 ff ff       	call   80040c <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  801093:	83 c3 01             	add    $0x1,%ebx
  801096:	83 c4 10             	add    $0x10,%esp
  801099:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80109e:	39 58 04             	cmp    %ebx,0x4(%eax)
  8010a1:	77 df                	ja     801082 <fs_sync+0xe>
		flush_block(diskaddr(i));
}
  8010a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010a6:	c9                   	leave  
  8010a7:	c3                   	ret    

008010a8 <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  8010a8:	55                   	push   %ebp
  8010a9:	89 e5                	mov    %esp,%ebp
  8010ab:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  8010ae:	e8 c1 ff ff ff       	call   801074 <fs_sync>
	return 0;
}
  8010b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8010b8:	c9                   	leave  
  8010b9:	c3                   	ret    

008010ba <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  8010ba:	55                   	push   %ebp
  8010bb:	89 e5                	mov    %esp,%ebp
  8010bd:	ba 60 50 80 00       	mov    $0x805060,%edx
	int i;
	uintptr_t va = FILEVA;
  8010c2:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  8010c7:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  8010cc:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  8010ce:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  8010d1:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  8010d7:	83 c0 01             	add    $0x1,%eax
  8010da:	83 c2 10             	add    $0x10,%edx
  8010dd:	3d 00 04 00 00       	cmp    $0x400,%eax
  8010e2:	75 e8                	jne    8010cc <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  8010e4:	5d                   	pop    %ebp
  8010e5:	c3                   	ret    

008010e6 <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  8010e6:	55                   	push   %ebp
  8010e7:	89 e5                	mov    %esp,%ebp
  8010e9:	56                   	push   %esi
  8010ea:	53                   	push   %ebx
  8010eb:	8b 75 08             	mov    0x8(%ebp),%esi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  8010ee:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (pageref(opentab[i].o_fd)) {
  8010f3:	83 ec 0c             	sub    $0xc,%esp
  8010f6:	89 d8                	mov    %ebx,%eax
  8010f8:	c1 e0 04             	shl    $0x4,%eax
  8010fb:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  801101:	e8 92 1f 00 00       	call   803098 <pageref>
  801106:	83 c4 10             	add    $0x10,%esp
  801109:	85 c0                	test   %eax,%eax
  80110b:	74 07                	je     801114 <openfile_alloc+0x2e>
  80110d:	83 f8 01             	cmp    $0x1,%eax
  801110:	74 20                	je     801132 <openfile_alloc+0x4c>
  801112:	eb 51                	jmp    801165 <openfile_alloc+0x7f>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  801114:	83 ec 04             	sub    $0x4,%esp
  801117:	6a 07                	push   $0x7
  801119:	89 d8                	mov    %ebx,%eax
  80111b:	c1 e0 04             	shl    $0x4,%eax
  80111e:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  801124:	6a 00                	push   $0x0
  801126:	e8 f8 12 00 00       	call   802423 <sys_page_alloc>
  80112b:	83 c4 10             	add    $0x10,%esp
  80112e:	85 c0                	test   %eax,%eax
  801130:	78 43                	js     801175 <openfile_alloc+0x8f>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  801132:	c1 e3 04             	shl    $0x4,%ebx
  801135:	8d 83 60 50 80 00    	lea    0x805060(%ebx),%eax
  80113b:	81 83 60 50 80 00 00 	addl   $0x400,0x805060(%ebx)
  801142:	04 00 00 
			*o = &opentab[i];
  801145:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  801147:	83 ec 04             	sub    $0x4,%esp
  80114a:	68 00 10 00 00       	push   $0x1000
  80114f:	6a 00                	push   $0x0
  801151:	ff b3 6c 50 80 00    	pushl  0x80506c(%ebx)
  801157:	e8 09 10 00 00       	call   802165 <memset>
			return (*o)->o_fileid;
  80115c:	8b 06                	mov    (%esi),%eax
  80115e:	8b 00                	mov    (%eax),%eax
  801160:	83 c4 10             	add    $0x10,%esp
  801163:	eb 10                	jmp    801175 <openfile_alloc+0x8f>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  801165:	83 c3 01             	add    $0x1,%ebx
  801168:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  80116e:	75 83                	jne    8010f3 <openfile_alloc+0xd>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  801170:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801175:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801178:	5b                   	pop    %ebx
  801179:	5e                   	pop    %esi
  80117a:	5d                   	pop    %ebp
  80117b:	c3                   	ret    

0080117c <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  80117c:	55                   	push   %ebp
  80117d:	89 e5                	mov    %esp,%ebp
  80117f:	57                   	push   %edi
  801180:	56                   	push   %esi
  801181:	53                   	push   %ebx
  801182:	83 ec 18             	sub    $0x18,%esp
  801185:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  801188:	89 fb                	mov    %edi,%ebx
  80118a:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  801190:	89 de                	mov    %ebx,%esi
  801192:	c1 e6 04             	shl    $0x4,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  801195:	ff b6 6c 50 80 00    	pushl  0x80506c(%esi)
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  80119b:	81 c6 60 50 80 00    	add    $0x805060,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  8011a1:	e8 f2 1e 00 00       	call   803098 <pageref>
  8011a6:	83 c4 10             	add    $0x10,%esp
  8011a9:	83 f8 01             	cmp    $0x1,%eax
  8011ac:	7e 17                	jle    8011c5 <openfile_lookup+0x49>
  8011ae:	c1 e3 04             	shl    $0x4,%ebx
  8011b1:	3b bb 60 50 80 00    	cmp    0x805060(%ebx),%edi
  8011b7:	75 13                	jne    8011cc <openfile_lookup+0x50>
		return -E_INVAL;
	*po = o;
  8011b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8011bc:	89 30                	mov    %esi,(%eax)
	return 0;
  8011be:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c3:	eb 0c                	jmp    8011d1 <openfile_lookup+0x55>
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
		return -E_INVAL;
  8011c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ca:	eb 05                	jmp    8011d1 <openfile_lookup+0x55>
  8011cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  8011d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d4:	5b                   	pop    %ebx
  8011d5:	5e                   	pop    %esi
  8011d6:	5f                   	pop    %edi
  8011d7:	5d                   	pop    %ebp
  8011d8:	c3                   	ret    

008011d9 <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  8011d9:	55                   	push   %ebp
  8011da:	89 e5                	mov    %esp,%ebp
  8011dc:	53                   	push   %ebx
  8011dd:	83 ec 18             	sub    $0x18,%esp
  8011e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8011e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e6:	50                   	push   %eax
  8011e7:	ff 33                	pushl  (%ebx)
  8011e9:	ff 75 08             	pushl  0x8(%ebp)
  8011ec:	e8 8b ff ff ff       	call   80117c <openfile_lookup>
  8011f1:	83 c4 10             	add    $0x10,%esp
  8011f4:	85 c0                	test   %eax,%eax
  8011f6:	78 14                	js     80120c <serve_set_size+0x33>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  8011f8:	83 ec 08             	sub    $0x8,%esp
  8011fb:	ff 73 04             	pushl  0x4(%ebx)
  8011fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801201:	ff 70 04             	pushl  0x4(%eax)
  801204:	e8 f8 fa ff ff       	call   800d01 <file_set_size>
  801209:	83 c4 10             	add    $0x10,%esp
}
  80120c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80120f:	c9                   	leave  
  801210:	c3                   	ret    

00801211 <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  801211:	55                   	push   %ebp
  801212:	89 e5                	mov    %esp,%ebp
  801214:	53                   	push   %ebx
  801215:	83 ec 18             	sub    $0x18,%esp
  801218:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// Lab 5: Your code here:
	// First: Find the relevant open file
	struct OpenFile *o;
	int r;
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80121b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80121e:	50                   	push   %eax
  80121f:	ff 33                	pushl  (%ebx)
  801221:	ff 75 08             	pushl  0x8(%ebp)
  801224:	e8 53 ff ff ff       	call   80117c <openfile_lookup>
  801229:	83 c4 10             	add    $0x10,%esp
		return r;
  80122c:	89 c2                	mov    %eax,%edx

	// Lab 5: Your code here:
	// First: Find the relevant open file
	struct OpenFile *o;
	int r;
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80122e:	85 c0                	test   %eax,%eax
  801230:	78 2b                	js     80125d <serve_read+0x4c>
		return r;

	// Second: Call the relevant file system function, in this case file_read.
	// We put the data in ret (&ipc->readRet), which is in the shared page,
	// so the client has access to the data read.
	struct File *file_to_read = o->o_file;
  801232:	8b 45 f4             	mov    -0xc(%ebp),%eax
	size_t count = req->req_n;
	off_t offset = o->o_fd->fd_offset;
  801235:	8b 50 0c             	mov    0xc(%eax),%edx
	r = file_read(file_to_read, ret, count, offset);
  801238:	ff 72 04             	pushl  0x4(%edx)
  80123b:	ff 73 04             	pushl  0x4(%ebx)
  80123e:	53                   	push   %ebx
  80123f:	ff 70 04             	pushl  0x4(%eax)
  801242:	e8 15 fa ff ff       	call   800c5c <file_read>

	// On failure, return the error code to the client.
	if (r < 0) {
  801247:	83 c4 10             	add    $0x10,%esp
  80124a:	85 c0                	test   %eax,%eax
  80124c:	78 0d                	js     80125b <serve_read+0x4a>
		return r;
	// On success, update the seek position and return the number of bytes read
	} else {
		uint32_t bytes_read = r;
		o->o_fd->fd_offset += bytes_read;
  80124e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801251:	8b 52 0c             	mov    0xc(%edx),%edx
  801254:	01 42 04             	add    %eax,0x4(%edx)
		return bytes_read;
  801257:	89 c2                	mov    %eax,%edx
  801259:	eb 02                	jmp    80125d <serve_read+0x4c>
	off_t offset = o->o_fd->fd_offset;
	r = file_read(file_to_read, ret, count, offset);

	// On failure, return the error code to the client.
	if (r < 0) {
		return r;
  80125b:	89 c2                	mov    %eax,%edx
	} else {
		uint32_t bytes_read = r;
		o->o_fd->fd_offset += bytes_read;
		return bytes_read;
	}
}
  80125d:	89 d0                	mov    %edx,%eax
  80125f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801262:	c9                   	leave  
  801263:	c3                   	ret    

00801264 <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  801264:	55                   	push   %ebp
  801265:	89 e5                	mov    %esp,%ebp
  801267:	53                   	push   %ebx
  801268:	83 ec 18             	sub    $0x18,%esp
  80126b:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// LAB 5: Your code here.
	// First: Find the relevant open file
	struct OpenFile *o;
	int r;
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80126e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801271:	50                   	push   %eax
  801272:	ff 33                	pushl  (%ebx)
  801274:	ff 75 08             	pushl  0x8(%ebp)
  801277:	e8 00 ff ff ff       	call   80117c <openfile_lookup>
  80127c:	83 c4 10             	add    $0x10,%esp
		return r;
  80127f:	89 c2                	mov    %eax,%edx

	// LAB 5: Your code here.
	// First: Find the relevant open file
	struct OpenFile *o;
	int r;
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801281:	85 c0                	test   %eax,%eax
  801283:	78 2e                	js     8012b3 <serve_write+0x4f>
		return r;

	// Second: Call the relevant file system function, in this case file_write
	struct File *file_to_write = o->o_file;
  801285:	8b 45 f4             	mov    -0xc(%ebp),%eax
	size_t count = req->req_n;
	off_t offset = o->o_fd->fd_offset;
  801288:	8b 50 0c             	mov    0xc(%eax),%edx
	r = file_write(file_to_write, req->req_buf, count, offset);
  80128b:	ff 72 04             	pushl  0x4(%edx)
  80128e:	ff 73 04             	pushl  0x4(%ebx)
  801291:	83 c3 08             	add    $0x8,%ebx
  801294:	53                   	push   %ebx
  801295:	ff 70 04             	pushl  0x4(%eax)
  801298:	e8 45 fb ff ff       	call   800de2 <file_write>

	// On failure, return the error code to the client
	if (r < 0) {
  80129d:	83 c4 10             	add    $0x10,%esp
  8012a0:	85 c0                	test   %eax,%eax
  8012a2:	78 0d                	js     8012b1 <serve_write+0x4d>
		return r;
	// On success, update the seek position and return the number of bytes written
	} else {
		uint32_t bytes_written = r;
		o->o_fd->fd_offset += bytes_written;
  8012a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012a7:	8b 52 0c             	mov    0xc(%edx),%edx
  8012aa:	01 42 04             	add    %eax,0x4(%edx)
		return bytes_written;
  8012ad:	89 c2                	mov    %eax,%edx
  8012af:	eb 02                	jmp    8012b3 <serve_write+0x4f>
	off_t offset = o->o_fd->fd_offset;
	r = file_write(file_to_write, req->req_buf, count, offset);

	// On failure, return the error code to the client
	if (r < 0) {
		return r;
  8012b1:	89 c2                	mov    %eax,%edx
	} else {
		uint32_t bytes_written = r;
		o->o_fd->fd_offset += bytes_written;
		return bytes_written;
	}
}
  8012b3:	89 d0                	mov    %edx,%eax
  8012b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b8:	c9                   	leave  
  8012b9:	c3                   	ret    

008012ba <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  8012ba:	55                   	push   %ebp
  8012bb:	89 e5                	mov    %esp,%ebp
  8012bd:	53                   	push   %ebx
  8012be:	83 ec 18             	sub    $0x18,%esp
  8012c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8012c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c7:	50                   	push   %eax
  8012c8:	ff 33                	pushl  (%ebx)
  8012ca:	ff 75 08             	pushl  0x8(%ebp)
  8012cd:	e8 aa fe ff ff       	call   80117c <openfile_lookup>
  8012d2:	83 c4 10             	add    $0x10,%esp
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	78 3f                	js     801318 <serve_stat+0x5e>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  8012d9:	83 ec 08             	sub    $0x8,%esp
  8012dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012df:	ff 70 04             	pushl  0x4(%eax)
  8012e2:	53                   	push   %ebx
  8012e3:	e8 38 0d 00 00       	call   802020 <strcpy>
	ret->ret_size = o->o_file->f_size;
  8012e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012eb:	8b 50 04             	mov    0x4(%eax),%edx
  8012ee:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  8012f4:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  8012fa:	8b 40 04             	mov    0x4(%eax),%eax
  8012fd:	83 c4 10             	add    $0x10,%esp
  801300:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  801307:	0f 94 c0             	sete   %al
  80130a:	0f b6 c0             	movzbl %al,%eax
  80130d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801313:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801318:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80131b:	c9                   	leave  
  80131c:	c3                   	ret    

0080131d <serve_flush>:

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  80131d:	55                   	push   %ebp
  80131e:	89 e5                	mov    %esp,%ebp
  801320:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801323:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801326:	50                   	push   %eax
  801327:	8b 45 0c             	mov    0xc(%ebp),%eax
  80132a:	ff 30                	pushl  (%eax)
  80132c:	ff 75 08             	pushl  0x8(%ebp)
  80132f:	e8 48 fe ff ff       	call   80117c <openfile_lookup>
  801334:	83 c4 10             	add    $0x10,%esp
  801337:	85 c0                	test   %eax,%eax
  801339:	78 16                	js     801351 <serve_flush+0x34>
		return r;
	file_flush(o->o_file);
  80133b:	83 ec 0c             	sub    $0xc,%esp
  80133e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801341:	ff 70 04             	pushl  0x4(%eax)
  801344:	e8 3f fb ff ff       	call   800e88 <file_flush>
	return 0;
  801349:	83 c4 10             	add    $0x10,%esp
  80134c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801351:	c9                   	leave  
  801352:	c3                   	ret    

00801353 <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  801353:	55                   	push   %ebp
  801354:	89 e5                	mov    %esp,%ebp
  801356:	53                   	push   %ebx
  801357:	81 ec 18 04 00 00    	sub    $0x418,%esp
  80135d:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  801360:	68 00 04 00 00       	push   $0x400
  801365:	53                   	push   %ebx
  801366:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80136c:	50                   	push   %eax
  80136d:	e8 40 0e 00 00       	call   8021b2 <memmove>
	path[MAXPATHLEN-1] = 0;
  801372:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  801376:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  80137c:	89 04 24             	mov    %eax,(%esp)
  80137f:	e8 62 fd ff ff       	call   8010e6 <openfile_alloc>
  801384:	83 c4 10             	add    $0x10,%esp
  801387:	85 c0                	test   %eax,%eax
  801389:	0f 88 f0 00 00 00    	js     80147f <serve_open+0x12c>
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  80138f:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  801396:	74 33                	je     8013cb <serve_open+0x78>
		if ((r = file_create(path, &f)) < 0) {
  801398:	83 ec 08             	sub    $0x8,%esp
  80139b:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8013a1:	50                   	push   %eax
  8013a2:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8013a8:	50                   	push   %eax
  8013a9:	e8 77 fb ff ff       	call   800f25 <file_create>
  8013ae:	83 c4 10             	add    $0x10,%esp
  8013b1:	85 c0                	test   %eax,%eax
  8013b3:	79 37                	jns    8013ec <serve_open+0x99>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  8013b5:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  8013bc:	0f 85 bd 00 00 00    	jne    80147f <serve_open+0x12c>
  8013c2:	83 f8 f3             	cmp    $0xfffffff3,%eax
  8013c5:	0f 85 b4 00 00 00    	jne    80147f <serve_open+0x12c>
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  8013cb:	83 ec 08             	sub    $0x8,%esp
  8013ce:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8013d4:	50                   	push   %eax
  8013d5:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8013db:	50                   	push   %eax
  8013dc:	e8 61 f8 ff ff       	call   800c42 <file_open>
  8013e1:	83 c4 10             	add    $0x10,%esp
  8013e4:	85 c0                	test   %eax,%eax
  8013e6:	0f 88 93 00 00 00    	js     80147f <serve_open+0x12c>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  8013ec:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  8013f3:	74 17                	je     80140c <serve_open+0xb9>
		if ((r = file_set_size(f, 0)) < 0) {
  8013f5:	83 ec 08             	sub    $0x8,%esp
  8013f8:	6a 00                	push   $0x0
  8013fa:	ff b5 f4 fb ff ff    	pushl  -0x40c(%ebp)
  801400:	e8 fc f8 ff ff       	call   800d01 <file_set_size>
  801405:	83 c4 10             	add    $0x10,%esp
  801408:	85 c0                	test   %eax,%eax
  80140a:	78 73                	js     80147f <serve_open+0x12c>
			if (debug)
				cprintf("file_set_size failed: %e", r);
			return r;
		}
	}
	if ((r = file_open(path, &f)) < 0) {
  80140c:	83 ec 08             	sub    $0x8,%esp
  80140f:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801415:	50                   	push   %eax
  801416:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80141c:	50                   	push   %eax
  80141d:	e8 20 f8 ff ff       	call   800c42 <file_open>
  801422:	83 c4 10             	add    $0x10,%esp
  801425:	85 c0                	test   %eax,%eax
  801427:	78 56                	js     80147f <serve_open+0x12c>
			cprintf("file_open failed: %e", r);
		return r;
	}

	// Save the file pointer
	o->o_file = f;
  801429:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  80142f:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  801435:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  801438:	8b 50 0c             	mov    0xc(%eax),%edx
  80143b:	8b 08                	mov    (%eax),%ecx
  80143d:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  801440:	8b 48 0c             	mov    0xc(%eax),%ecx
  801443:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  801449:	83 e2 03             	and    $0x3,%edx
  80144c:	89 51 08             	mov    %edx,0x8(%ecx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  80144f:	8b 40 0c             	mov    0xc(%eax),%eax
  801452:	8b 15 64 90 80 00    	mov    0x809064,%edx
  801458:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  80145a:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801460:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  801466:	89 50 08             	mov    %edx,0x8(%eax)
	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  801469:	8b 50 0c             	mov    0xc(%eax),%edx
  80146c:	8b 45 10             	mov    0x10(%ebp),%eax
  80146f:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  801471:	8b 45 14             	mov    0x14(%ebp),%eax
  801474:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	return 0;
  80147a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80147f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801482:	c9                   	leave  
  801483:	c3                   	ret    

00801484 <serve>:
};
#define NHANDLERS (sizeof(handlers)/sizeof(handlers[0]))

void
serve(void)
{
  801484:	55                   	push   %ebp
  801485:	89 e5                	mov    %esp,%ebp
  801487:	56                   	push   %esi
  801488:	53                   	push   %ebx
  801489:	83 ec 10             	sub    $0x10,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  80148c:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  80148f:	8d 75 f4             	lea    -0xc(%ebp),%esi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  801492:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801499:	83 ec 04             	sub    $0x4,%esp
  80149c:	53                   	push   %ebx
  80149d:	ff 35 44 50 80 00    	pushl  0x805044
  8014a3:	56                   	push   %esi
  8014a4:	e8 c5 12 00 00       	call   80276e <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  8014a9:	83 c4 10             	add    $0x10,%esp
  8014ac:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  8014b0:	75 15                	jne    8014c7 <serve+0x43>
			cprintf("Invalid request from %08x: no argument page\n",
  8014b2:	83 ec 08             	sub    $0x8,%esp
  8014b5:	ff 75 f4             	pushl  -0xc(%ebp)
  8014b8:	68 f4 3f 80 00       	push   $0x803ff4
  8014bd:	e8 d9 05 00 00       	call   801a9b <cprintf>
				whom);
			continue; // just leave it hanging...
  8014c2:	83 c4 10             	add    $0x10,%esp
  8014c5:	eb cb                	jmp    801492 <serve+0xe>
		}

		pg = NULL;
  8014c7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  8014ce:	83 f8 01             	cmp    $0x1,%eax
  8014d1:	75 18                	jne    8014eb <serve+0x67>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  8014d3:	53                   	push   %ebx
  8014d4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8014d7:	50                   	push   %eax
  8014d8:	ff 35 44 50 80 00    	pushl  0x805044
  8014de:	ff 75 f4             	pushl  -0xc(%ebp)
  8014e1:	e8 6d fe ff ff       	call   801353 <serve_open>
  8014e6:	83 c4 10             	add    $0x10,%esp
  8014e9:	eb 3c                	jmp    801527 <serve+0xa3>
		} else if (req < NHANDLERS && handlers[req]) {
  8014eb:	83 f8 08             	cmp    $0x8,%eax
  8014ee:	77 1e                	ja     80150e <serve+0x8a>
  8014f0:	8b 14 85 20 50 80 00 	mov    0x805020(,%eax,4),%edx
  8014f7:	85 d2                	test   %edx,%edx
  8014f9:	74 13                	je     80150e <serve+0x8a>
			r = handlers[req](whom, fsreq);
  8014fb:	83 ec 08             	sub    $0x8,%esp
  8014fe:	ff 35 44 50 80 00    	pushl  0x805044
  801504:	ff 75 f4             	pushl  -0xc(%ebp)
  801507:	ff d2                	call   *%edx
  801509:	83 c4 10             	add    $0x10,%esp
  80150c:	eb 19                	jmp    801527 <serve+0xa3>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  80150e:	83 ec 04             	sub    $0x4,%esp
  801511:	ff 75 f4             	pushl  -0xc(%ebp)
  801514:	50                   	push   %eax
  801515:	68 24 40 80 00       	push   $0x804024
  80151a:	e8 7c 05 00 00       	call   801a9b <cprintf>
  80151f:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  801522:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  801527:	ff 75 f0             	pushl  -0x10(%ebp)
  80152a:	ff 75 ec             	pushl  -0x14(%ebp)
  80152d:	50                   	push   %eax
  80152e:	ff 75 f4             	pushl  -0xc(%ebp)
  801531:	e8 a1 12 00 00       	call   8027d7 <ipc_send>
		sys_page_unmap(0, fsreq);
  801536:	83 c4 08             	add    $0x8,%esp
  801539:	ff 35 44 50 80 00    	pushl  0x805044
  80153f:	6a 00                	push   $0x0
  801541:	e8 62 0f 00 00       	call   8024a8 <sys_page_unmap>
  801546:	83 c4 10             	add    $0x10,%esp
  801549:	e9 44 ff ff ff       	jmp    801492 <serve+0xe>

0080154e <umain>:
	}
}

void
umain(int argc, char **argv)
{
  80154e:	55                   	push   %ebp
  80154f:	89 e5                	mov    %esp,%ebp
  801551:	83 ec 14             	sub    $0x14,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  801554:	c7 05 60 90 80 00 47 	movl   $0x804047,0x809060
  80155b:	40 80 00 
	cprintf("FS is running\n");
  80155e:	68 4a 40 80 00       	push   $0x80404a
  801563:	e8 33 05 00 00       	call   801a9b <cprintf>
}

static __inline void
outw(int port, uint16_t data)
{
	__asm __volatile("outw %0,%w1" : : "a" (data), "d" (port));
  801568:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  80156d:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  801572:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  801574:	c7 04 24 59 40 80 00 	movl   $0x804059,(%esp)
  80157b:	e8 1b 05 00 00       	call   801a9b <cprintf>

	serve_init();
  801580:	e8 35 fb ff ff       	call   8010ba <serve_init>
	fs_init();
  801585:	e8 bd f3 ff ff       	call   800947 <fs_init>
	serve();
  80158a:	e8 f5 fe ff ff       	call   801484 <serve>

0080158f <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  80158f:	55                   	push   %ebp
  801590:	89 e5                	mov    %esp,%ebp
  801592:	53                   	push   %ebx
  801593:	83 ec 18             	sub    $0x18,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  801596:	6a 07                	push   $0x7
  801598:	68 00 10 00 00       	push   $0x1000
  80159d:	6a 00                	push   $0x0
  80159f:	e8 7f 0e 00 00       	call   802423 <sys_page_alloc>
  8015a4:	83 c4 10             	add    $0x10,%esp
  8015a7:	85 c0                	test   %eax,%eax
  8015a9:	79 12                	jns    8015bd <fs_test+0x2e>
		panic("sys_page_alloc: %e", r);
  8015ab:	50                   	push   %eax
  8015ac:	68 68 40 80 00       	push   $0x804068
  8015b1:	6a 12                	push   $0x12
  8015b3:	68 7b 40 80 00       	push   $0x80407b
  8015b8:	e8 05 04 00 00       	call   8019c2 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  8015bd:	83 ec 04             	sub    $0x4,%esp
  8015c0:	68 00 10 00 00       	push   $0x1000
  8015c5:	ff 35 08 a0 80 00    	pushl  0x80a008
  8015cb:	68 00 10 00 00       	push   $0x1000
  8015d0:	e8 dd 0b 00 00       	call   8021b2 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  8015d5:	e8 90 f1 ff ff       	call   80076a <alloc_block>
  8015da:	83 c4 10             	add    $0x10,%esp
  8015dd:	85 c0                	test   %eax,%eax
  8015df:	79 12                	jns    8015f3 <fs_test+0x64>
		panic("alloc_block: %e", r);
  8015e1:	50                   	push   %eax
  8015e2:	68 85 40 80 00       	push   $0x804085
  8015e7:	6a 17                	push   $0x17
  8015e9:	68 7b 40 80 00       	push   $0x80407b
  8015ee:	e8 cf 03 00 00       	call   8019c2 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  8015f3:	8d 50 1f             	lea    0x1f(%eax),%edx
  8015f6:	85 c0                	test   %eax,%eax
  8015f8:	0f 49 d0             	cmovns %eax,%edx
  8015fb:	c1 fa 05             	sar    $0x5,%edx
  8015fe:	89 c3                	mov    %eax,%ebx
  801600:	c1 fb 1f             	sar    $0x1f,%ebx
  801603:	c1 eb 1b             	shr    $0x1b,%ebx
  801606:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
  801609:	83 e1 1f             	and    $0x1f,%ecx
  80160c:	29 d9                	sub    %ebx,%ecx
  80160e:	b8 01 00 00 00       	mov    $0x1,%eax
  801613:	d3 e0                	shl    %cl,%eax
  801615:	85 04 95 00 10 00 00 	test   %eax,0x1000(,%edx,4)
  80161c:	75 16                	jne    801634 <fs_test+0xa5>
  80161e:	68 95 40 80 00       	push   $0x804095
  801623:	68 fd 3c 80 00       	push   $0x803cfd
  801628:	6a 19                	push   $0x19
  80162a:	68 7b 40 80 00       	push   $0x80407b
  80162f:	e8 8e 03 00 00       	call   8019c2 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  801634:	8b 0d 08 a0 80 00    	mov    0x80a008,%ecx
  80163a:	85 04 91             	test   %eax,(%ecx,%edx,4)
  80163d:	74 16                	je     801655 <fs_test+0xc6>
  80163f:	68 10 42 80 00       	push   $0x804210
  801644:	68 fd 3c 80 00       	push   $0x803cfd
  801649:	6a 1b                	push   $0x1b
  80164b:	68 7b 40 80 00       	push   $0x80407b
  801650:	e8 6d 03 00 00       	call   8019c2 <_panic>
	cprintf("alloc_block is good\n");
  801655:	83 ec 0c             	sub    $0xc,%esp
  801658:	68 b0 40 80 00       	push   $0x8040b0
  80165d:	e8 39 04 00 00       	call   801a9b <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  801662:	83 c4 08             	add    $0x8,%esp
  801665:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801668:	50                   	push   %eax
  801669:	68 c5 40 80 00       	push   $0x8040c5
  80166e:	e8 cf f5 ff ff       	call   800c42 <file_open>
  801673:	83 c4 10             	add    $0x10,%esp
  801676:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801679:	74 1b                	je     801696 <fs_test+0x107>
  80167b:	89 c2                	mov    %eax,%edx
  80167d:	c1 ea 1f             	shr    $0x1f,%edx
  801680:	84 d2                	test   %dl,%dl
  801682:	74 12                	je     801696 <fs_test+0x107>
		panic("file_open /not-found: %e", r);
  801684:	50                   	push   %eax
  801685:	68 d0 40 80 00       	push   $0x8040d0
  80168a:	6a 1f                	push   $0x1f
  80168c:	68 7b 40 80 00       	push   $0x80407b
  801691:	e8 2c 03 00 00       	call   8019c2 <_panic>
	else if (r == 0)
  801696:	85 c0                	test   %eax,%eax
  801698:	75 14                	jne    8016ae <fs_test+0x11f>
		panic("file_open /not-found succeeded!");
  80169a:	83 ec 04             	sub    $0x4,%esp
  80169d:	68 30 42 80 00       	push   $0x804230
  8016a2:	6a 21                	push   $0x21
  8016a4:	68 7b 40 80 00       	push   $0x80407b
  8016a9:	e8 14 03 00 00       	call   8019c2 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  8016ae:	83 ec 08             	sub    $0x8,%esp
  8016b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b4:	50                   	push   %eax
  8016b5:	68 e9 40 80 00       	push   $0x8040e9
  8016ba:	e8 83 f5 ff ff       	call   800c42 <file_open>
  8016bf:	83 c4 10             	add    $0x10,%esp
  8016c2:	85 c0                	test   %eax,%eax
  8016c4:	79 12                	jns    8016d8 <fs_test+0x149>
		panic("file_open /newmotd: %e", r);
  8016c6:	50                   	push   %eax
  8016c7:	68 f2 40 80 00       	push   $0x8040f2
  8016cc:	6a 23                	push   $0x23
  8016ce:	68 7b 40 80 00       	push   $0x80407b
  8016d3:	e8 ea 02 00 00       	call   8019c2 <_panic>
	cprintf("file_open is good\n");
  8016d8:	83 ec 0c             	sub    $0xc,%esp
  8016db:	68 09 41 80 00       	push   $0x804109
  8016e0:	e8 b6 03 00 00       	call   801a9b <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  8016e5:	83 c4 0c             	add    $0xc,%esp
  8016e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016eb:	50                   	push   %eax
  8016ec:	6a 00                	push   $0x0
  8016ee:	ff 75 f4             	pushl  -0xc(%ebp)
  8016f1:	e8 b0 f2 ff ff       	call   8009a6 <file_get_block>
  8016f6:	83 c4 10             	add    $0x10,%esp
  8016f9:	85 c0                	test   %eax,%eax
  8016fb:	79 12                	jns    80170f <fs_test+0x180>
		panic("file_get_block: %e", r);
  8016fd:	50                   	push   %eax
  8016fe:	68 1c 41 80 00       	push   $0x80411c
  801703:	6a 27                	push   $0x27
  801705:	68 7b 40 80 00       	push   $0x80407b
  80170a:	e8 b3 02 00 00       	call   8019c2 <_panic>
	if (strcmp(blk, msg) != 0)
  80170f:	83 ec 08             	sub    $0x8,%esp
  801712:	68 50 42 80 00       	push   $0x804250
  801717:	ff 75 f0             	pushl  -0x10(%ebp)
  80171a:	e8 ab 09 00 00       	call   8020ca <strcmp>
  80171f:	83 c4 10             	add    $0x10,%esp
  801722:	85 c0                	test   %eax,%eax
  801724:	74 14                	je     80173a <fs_test+0x1ab>
		panic("file_get_block returned wrong data");
  801726:	83 ec 04             	sub    $0x4,%esp
  801729:	68 78 42 80 00       	push   $0x804278
  80172e:	6a 29                	push   $0x29
  801730:	68 7b 40 80 00       	push   $0x80407b
  801735:	e8 88 02 00 00       	call   8019c2 <_panic>
	cprintf("file_get_block is good\n");
  80173a:	83 ec 0c             	sub    $0xc,%esp
  80173d:	68 2f 41 80 00       	push   $0x80412f
  801742:	e8 54 03 00 00       	call   801a9b <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  801747:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80174a:	0f b6 10             	movzbl (%eax),%edx
  80174d:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  80174f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801752:	c1 e8 0c             	shr    $0xc,%eax
  801755:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80175c:	83 c4 10             	add    $0x10,%esp
  80175f:	a8 40                	test   $0x40,%al
  801761:	75 16                	jne    801779 <fs_test+0x1ea>
  801763:	68 48 41 80 00       	push   $0x804148
  801768:	68 fd 3c 80 00       	push   $0x803cfd
  80176d:	6a 2d                	push   $0x2d
  80176f:	68 7b 40 80 00       	push   $0x80407b
  801774:	e8 49 02 00 00       	call   8019c2 <_panic>
	file_flush(f);
  801779:	83 ec 0c             	sub    $0xc,%esp
  80177c:	ff 75 f4             	pushl  -0xc(%ebp)
  80177f:	e8 04 f7 ff ff       	call   800e88 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801784:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801787:	c1 e8 0c             	shr    $0xc,%eax
  80178a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801791:	83 c4 10             	add    $0x10,%esp
  801794:	a8 40                	test   $0x40,%al
  801796:	74 16                	je     8017ae <fs_test+0x21f>
  801798:	68 47 41 80 00       	push   $0x804147
  80179d:	68 fd 3c 80 00       	push   $0x803cfd
  8017a2:	6a 2f                	push   $0x2f
  8017a4:	68 7b 40 80 00       	push   $0x80407b
  8017a9:	e8 14 02 00 00       	call   8019c2 <_panic>
	cprintf("file_flush is good\n");
  8017ae:	83 ec 0c             	sub    $0xc,%esp
  8017b1:	68 63 41 80 00       	push   $0x804163
  8017b6:	e8 e0 02 00 00       	call   801a9b <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  8017bb:	83 c4 08             	add    $0x8,%esp
  8017be:	6a 00                	push   $0x0
  8017c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8017c3:	e8 39 f5 ff ff       	call   800d01 <file_set_size>
  8017c8:	83 c4 10             	add    $0x10,%esp
  8017cb:	85 c0                	test   %eax,%eax
  8017cd:	79 12                	jns    8017e1 <fs_test+0x252>
		panic("file_set_size: %e", r);
  8017cf:	50                   	push   %eax
  8017d0:	68 77 41 80 00       	push   $0x804177
  8017d5:	6a 33                	push   $0x33
  8017d7:	68 7b 40 80 00       	push   $0x80407b
  8017dc:	e8 e1 01 00 00       	call   8019c2 <_panic>
	assert(f->f_direct[0] == 0);
  8017e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e4:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  8017eb:	74 16                	je     801803 <fs_test+0x274>
  8017ed:	68 89 41 80 00       	push   $0x804189
  8017f2:	68 fd 3c 80 00       	push   $0x803cfd
  8017f7:	6a 34                	push   $0x34
  8017f9:	68 7b 40 80 00       	push   $0x80407b
  8017fe:	e8 bf 01 00 00       	call   8019c2 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801803:	c1 e8 0c             	shr    $0xc,%eax
  801806:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80180d:	a8 40                	test   $0x40,%al
  80180f:	74 16                	je     801827 <fs_test+0x298>
  801811:	68 9d 41 80 00       	push   $0x80419d
  801816:	68 fd 3c 80 00       	push   $0x803cfd
  80181b:	6a 35                	push   $0x35
  80181d:	68 7b 40 80 00       	push   $0x80407b
  801822:	e8 9b 01 00 00       	call   8019c2 <_panic>
	cprintf("file_truncate is good\n");
  801827:	83 ec 0c             	sub    $0xc,%esp
  80182a:	68 b7 41 80 00       	push   $0x8041b7
  80182f:	e8 67 02 00 00       	call   801a9b <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  801834:	c7 04 24 50 42 80 00 	movl   $0x804250,(%esp)
  80183b:	e8 a7 07 00 00       	call   801fe7 <strlen>
  801840:	83 c4 08             	add    $0x8,%esp
  801843:	50                   	push   %eax
  801844:	ff 75 f4             	pushl  -0xc(%ebp)
  801847:	e8 b5 f4 ff ff       	call   800d01 <file_set_size>
  80184c:	83 c4 10             	add    $0x10,%esp
  80184f:	85 c0                	test   %eax,%eax
  801851:	79 12                	jns    801865 <fs_test+0x2d6>
		panic("file_set_size 2: %e", r);
  801853:	50                   	push   %eax
  801854:	68 ce 41 80 00       	push   $0x8041ce
  801859:	6a 39                	push   $0x39
  80185b:	68 7b 40 80 00       	push   $0x80407b
  801860:	e8 5d 01 00 00       	call   8019c2 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801865:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801868:	89 c2                	mov    %eax,%edx
  80186a:	c1 ea 0c             	shr    $0xc,%edx
  80186d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801874:	f6 c2 40             	test   $0x40,%dl
  801877:	74 16                	je     80188f <fs_test+0x300>
  801879:	68 9d 41 80 00       	push   $0x80419d
  80187e:	68 fd 3c 80 00       	push   $0x803cfd
  801883:	6a 3a                	push   $0x3a
  801885:	68 7b 40 80 00       	push   $0x80407b
  80188a:	e8 33 01 00 00       	call   8019c2 <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  80188f:	83 ec 04             	sub    $0x4,%esp
  801892:	8d 55 f0             	lea    -0x10(%ebp),%edx
  801895:	52                   	push   %edx
  801896:	6a 00                	push   $0x0
  801898:	50                   	push   %eax
  801899:	e8 08 f1 ff ff       	call   8009a6 <file_get_block>
  80189e:	83 c4 10             	add    $0x10,%esp
  8018a1:	85 c0                	test   %eax,%eax
  8018a3:	79 12                	jns    8018b7 <fs_test+0x328>
		panic("file_get_block 2: %e", r);
  8018a5:	50                   	push   %eax
  8018a6:	68 e2 41 80 00       	push   $0x8041e2
  8018ab:	6a 3c                	push   $0x3c
  8018ad:	68 7b 40 80 00       	push   $0x80407b
  8018b2:	e8 0b 01 00 00       	call   8019c2 <_panic>
	strcpy(blk, msg);
  8018b7:	83 ec 08             	sub    $0x8,%esp
  8018ba:	68 50 42 80 00       	push   $0x804250
  8018bf:	ff 75 f0             	pushl  -0x10(%ebp)
  8018c2:	e8 59 07 00 00       	call   802020 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  8018c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ca:	c1 e8 0c             	shr    $0xc,%eax
  8018cd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018d4:	83 c4 10             	add    $0x10,%esp
  8018d7:	a8 40                	test   $0x40,%al
  8018d9:	75 16                	jne    8018f1 <fs_test+0x362>
  8018db:	68 48 41 80 00       	push   $0x804148
  8018e0:	68 fd 3c 80 00       	push   $0x803cfd
  8018e5:	6a 3e                	push   $0x3e
  8018e7:	68 7b 40 80 00       	push   $0x80407b
  8018ec:	e8 d1 00 00 00       	call   8019c2 <_panic>
	file_flush(f);
  8018f1:	83 ec 0c             	sub    $0xc,%esp
  8018f4:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f7:	e8 8c f5 ff ff       	call   800e88 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8018fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ff:	c1 e8 0c             	shr    $0xc,%eax
  801902:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801909:	83 c4 10             	add    $0x10,%esp
  80190c:	a8 40                	test   $0x40,%al
  80190e:	74 16                	je     801926 <fs_test+0x397>
  801910:	68 47 41 80 00       	push   $0x804147
  801915:	68 fd 3c 80 00       	push   $0x803cfd
  80191a:	6a 40                	push   $0x40
  80191c:	68 7b 40 80 00       	push   $0x80407b
  801921:	e8 9c 00 00 00       	call   8019c2 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801926:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801929:	c1 e8 0c             	shr    $0xc,%eax
  80192c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801933:	a8 40                	test   $0x40,%al
  801935:	74 16                	je     80194d <fs_test+0x3be>
  801937:	68 9d 41 80 00       	push   $0x80419d
  80193c:	68 fd 3c 80 00       	push   $0x803cfd
  801941:	6a 41                	push   $0x41
  801943:	68 7b 40 80 00       	push   $0x80407b
  801948:	e8 75 00 00 00       	call   8019c2 <_panic>
	cprintf("file rewrite is good\n");
  80194d:	83 ec 0c             	sub    $0xc,%esp
  801950:	68 f7 41 80 00       	push   $0x8041f7
  801955:	e8 41 01 00 00       	call   801a9b <cprintf>
}
  80195a:	83 c4 10             	add    $0x10,%esp
  80195d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801960:	c9                   	leave  
  801961:	c3                   	ret    

00801962 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	56                   	push   %esi
  801966:	53                   	push   %ebx
  801967:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80196a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80196d:	e8 73 0a 00 00       	call   8023e5 <sys_getenvid>
  801972:	25 ff 03 00 00       	and    $0x3ff,%eax
  801977:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80197a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80197f:	a3 10 a0 80 00       	mov    %eax,0x80a010

	// save the name of the program so that panic() can use it
	if (argc > 0)
  801984:	85 db                	test   %ebx,%ebx
  801986:	7e 07                	jle    80198f <libmain+0x2d>
		binaryname = argv[0];
  801988:	8b 06                	mov    (%esi),%eax
  80198a:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  80198f:	83 ec 08             	sub    $0x8,%esp
  801992:	56                   	push   %esi
  801993:	53                   	push   %ebx
  801994:	e8 b5 fb ff ff       	call   80154e <umain>

	// exit gracefully
	exit();
  801999:	e8 0a 00 00 00       	call   8019a8 <exit>
}
  80199e:	83 c4 10             	add    $0x10,%esp
  8019a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019a4:	5b                   	pop    %ebx
  8019a5:	5e                   	pop    %esi
  8019a6:	5d                   	pop    %ebp
  8019a7:	c3                   	ret    

008019a8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8019a8:	55                   	push   %ebp
  8019a9:	89 e5                	mov    %esp,%ebp
  8019ab:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8019ae:	e8 7c 10 00 00       	call   802a2f <close_all>
	sys_env_destroy(0);
  8019b3:	83 ec 0c             	sub    $0xc,%esp
  8019b6:	6a 00                	push   $0x0
  8019b8:	e8 e7 09 00 00       	call   8023a4 <sys_env_destroy>
}
  8019bd:	83 c4 10             	add    $0x10,%esp
  8019c0:	c9                   	leave  
  8019c1:	c3                   	ret    

008019c2 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019c2:	55                   	push   %ebp
  8019c3:	89 e5                	mov    %esp,%ebp
  8019c5:	56                   	push   %esi
  8019c6:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019c7:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019ca:	8b 35 60 90 80 00    	mov    0x809060,%esi
  8019d0:	e8 10 0a 00 00       	call   8023e5 <sys_getenvid>
  8019d5:	83 ec 0c             	sub    $0xc,%esp
  8019d8:	ff 75 0c             	pushl  0xc(%ebp)
  8019db:	ff 75 08             	pushl  0x8(%ebp)
  8019de:	56                   	push   %esi
  8019df:	50                   	push   %eax
  8019e0:	68 a8 42 80 00       	push   $0x8042a8
  8019e5:	e8 b1 00 00 00       	call   801a9b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019ea:	83 c4 18             	add    $0x18,%esp
  8019ed:	53                   	push   %ebx
  8019ee:	ff 75 10             	pushl  0x10(%ebp)
  8019f1:	e8 54 00 00 00       	call   801a4a <vcprintf>
	cprintf("\n");
  8019f6:	c7 04 24 6e 3e 80 00 	movl   $0x803e6e,(%esp)
  8019fd:	e8 99 00 00 00       	call   801a9b <cprintf>
  801a02:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a05:	cc                   	int3   
  801a06:	eb fd                	jmp    801a05 <_panic+0x43>

00801a08 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801a08:	55                   	push   %ebp
  801a09:	89 e5                	mov    %esp,%ebp
  801a0b:	53                   	push   %ebx
  801a0c:	83 ec 04             	sub    $0x4,%esp
  801a0f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801a12:	8b 13                	mov    (%ebx),%edx
  801a14:	8d 42 01             	lea    0x1(%edx),%eax
  801a17:	89 03                	mov    %eax,(%ebx)
  801a19:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a1c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801a20:	3d ff 00 00 00       	cmp    $0xff,%eax
  801a25:	75 1a                	jne    801a41 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801a27:	83 ec 08             	sub    $0x8,%esp
  801a2a:	68 ff 00 00 00       	push   $0xff
  801a2f:	8d 43 08             	lea    0x8(%ebx),%eax
  801a32:	50                   	push   %eax
  801a33:	e8 2f 09 00 00       	call   802367 <sys_cputs>
		b->idx = 0;
  801a38:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a3e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801a41:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801a45:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a48:	c9                   	leave  
  801a49:	c3                   	ret    

00801a4a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801a4a:	55                   	push   %ebp
  801a4b:	89 e5                	mov    %esp,%ebp
  801a4d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801a53:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801a5a:	00 00 00 
	b.cnt = 0;
  801a5d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801a64:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801a67:	ff 75 0c             	pushl  0xc(%ebp)
  801a6a:	ff 75 08             	pushl  0x8(%ebp)
  801a6d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801a73:	50                   	push   %eax
  801a74:	68 08 1a 80 00       	push   $0x801a08
  801a79:	e8 54 01 00 00       	call   801bd2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801a7e:	83 c4 08             	add    $0x8,%esp
  801a81:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801a87:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801a8d:	50                   	push   %eax
  801a8e:	e8 d4 08 00 00       	call   802367 <sys_cputs>

	return b.cnt;
}
  801a93:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801a99:	c9                   	leave  
  801a9a:	c3                   	ret    

00801a9b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801a9b:	55                   	push   %ebp
  801a9c:	89 e5                	mov    %esp,%ebp
  801a9e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801aa1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801aa4:	50                   	push   %eax
  801aa5:	ff 75 08             	pushl  0x8(%ebp)
  801aa8:	e8 9d ff ff ff       	call   801a4a <vcprintf>
	va_end(ap);

	return cnt;
}
  801aad:	c9                   	leave  
  801aae:	c3                   	ret    

00801aaf <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801aaf:	55                   	push   %ebp
  801ab0:	89 e5                	mov    %esp,%ebp
  801ab2:	57                   	push   %edi
  801ab3:	56                   	push   %esi
  801ab4:	53                   	push   %ebx
  801ab5:	83 ec 1c             	sub    $0x1c,%esp
  801ab8:	89 c7                	mov    %eax,%edi
  801aba:	89 d6                	mov    %edx,%esi
  801abc:	8b 45 08             	mov    0x8(%ebp),%eax
  801abf:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ac2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801ac5:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801ac8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801acb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ad0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801ad3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801ad6:	39 d3                	cmp    %edx,%ebx
  801ad8:	72 05                	jb     801adf <printnum+0x30>
  801ada:	39 45 10             	cmp    %eax,0x10(%ebp)
  801add:	77 45                	ja     801b24 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801adf:	83 ec 0c             	sub    $0xc,%esp
  801ae2:	ff 75 18             	pushl  0x18(%ebp)
  801ae5:	8b 45 14             	mov    0x14(%ebp),%eax
  801ae8:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801aeb:	53                   	push   %ebx
  801aec:	ff 75 10             	pushl  0x10(%ebp)
  801aef:	83 ec 08             	sub    $0x8,%esp
  801af2:	ff 75 e4             	pushl  -0x1c(%ebp)
  801af5:	ff 75 e0             	pushl  -0x20(%ebp)
  801af8:	ff 75 dc             	pushl  -0x24(%ebp)
  801afb:	ff 75 d8             	pushl  -0x28(%ebp)
  801afe:	e8 1d 1f 00 00       	call   803a20 <__udivdi3>
  801b03:	83 c4 18             	add    $0x18,%esp
  801b06:	52                   	push   %edx
  801b07:	50                   	push   %eax
  801b08:	89 f2                	mov    %esi,%edx
  801b0a:	89 f8                	mov    %edi,%eax
  801b0c:	e8 9e ff ff ff       	call   801aaf <printnum>
  801b11:	83 c4 20             	add    $0x20,%esp
  801b14:	eb 18                	jmp    801b2e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801b16:	83 ec 08             	sub    $0x8,%esp
  801b19:	56                   	push   %esi
  801b1a:	ff 75 18             	pushl  0x18(%ebp)
  801b1d:	ff d7                	call   *%edi
  801b1f:	83 c4 10             	add    $0x10,%esp
  801b22:	eb 03                	jmp    801b27 <printnum+0x78>
  801b24:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801b27:	83 eb 01             	sub    $0x1,%ebx
  801b2a:	85 db                	test   %ebx,%ebx
  801b2c:	7f e8                	jg     801b16 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801b2e:	83 ec 08             	sub    $0x8,%esp
  801b31:	56                   	push   %esi
  801b32:	83 ec 04             	sub    $0x4,%esp
  801b35:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b38:	ff 75 e0             	pushl  -0x20(%ebp)
  801b3b:	ff 75 dc             	pushl  -0x24(%ebp)
  801b3e:	ff 75 d8             	pushl  -0x28(%ebp)
  801b41:	e8 0a 20 00 00       	call   803b50 <__umoddi3>
  801b46:	83 c4 14             	add    $0x14,%esp
  801b49:	0f be 80 cb 42 80 00 	movsbl 0x8042cb(%eax),%eax
  801b50:	50                   	push   %eax
  801b51:	ff d7                	call   *%edi
}
  801b53:	83 c4 10             	add    $0x10,%esp
  801b56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b59:	5b                   	pop    %ebx
  801b5a:	5e                   	pop    %esi
  801b5b:	5f                   	pop    %edi
  801b5c:	5d                   	pop    %ebp
  801b5d:	c3                   	ret    

00801b5e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801b5e:	55                   	push   %ebp
  801b5f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801b61:	83 fa 01             	cmp    $0x1,%edx
  801b64:	7e 0e                	jle    801b74 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801b66:	8b 10                	mov    (%eax),%edx
  801b68:	8d 4a 08             	lea    0x8(%edx),%ecx
  801b6b:	89 08                	mov    %ecx,(%eax)
  801b6d:	8b 02                	mov    (%edx),%eax
  801b6f:	8b 52 04             	mov    0x4(%edx),%edx
  801b72:	eb 22                	jmp    801b96 <getuint+0x38>
	else if (lflag)
  801b74:	85 d2                	test   %edx,%edx
  801b76:	74 10                	je     801b88 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801b78:	8b 10                	mov    (%eax),%edx
  801b7a:	8d 4a 04             	lea    0x4(%edx),%ecx
  801b7d:	89 08                	mov    %ecx,(%eax)
  801b7f:	8b 02                	mov    (%edx),%eax
  801b81:	ba 00 00 00 00       	mov    $0x0,%edx
  801b86:	eb 0e                	jmp    801b96 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801b88:	8b 10                	mov    (%eax),%edx
  801b8a:	8d 4a 04             	lea    0x4(%edx),%ecx
  801b8d:	89 08                	mov    %ecx,(%eax)
  801b8f:	8b 02                	mov    (%edx),%eax
  801b91:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801b96:	5d                   	pop    %ebp
  801b97:	c3                   	ret    

00801b98 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801b98:	55                   	push   %ebp
  801b99:	89 e5                	mov    %esp,%ebp
  801b9b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801b9e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801ba2:	8b 10                	mov    (%eax),%edx
  801ba4:	3b 50 04             	cmp    0x4(%eax),%edx
  801ba7:	73 0a                	jae    801bb3 <sprintputch+0x1b>
		*b->buf++ = ch;
  801ba9:	8d 4a 01             	lea    0x1(%edx),%ecx
  801bac:	89 08                	mov    %ecx,(%eax)
  801bae:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb1:	88 02                	mov    %al,(%edx)
}
  801bb3:	5d                   	pop    %ebp
  801bb4:	c3                   	ret    

00801bb5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801bb5:	55                   	push   %ebp
  801bb6:	89 e5                	mov    %esp,%ebp
  801bb8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801bbb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801bbe:	50                   	push   %eax
  801bbf:	ff 75 10             	pushl  0x10(%ebp)
  801bc2:	ff 75 0c             	pushl  0xc(%ebp)
  801bc5:	ff 75 08             	pushl  0x8(%ebp)
  801bc8:	e8 05 00 00 00       	call   801bd2 <vprintfmt>
	va_end(ap);
}
  801bcd:	83 c4 10             	add    $0x10,%esp
  801bd0:	c9                   	leave  
  801bd1:	c3                   	ret    

00801bd2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801bd2:	55                   	push   %ebp
  801bd3:	89 e5                	mov    %esp,%ebp
  801bd5:	57                   	push   %edi
  801bd6:	56                   	push   %esi
  801bd7:	53                   	push   %ebx
  801bd8:	83 ec 2c             	sub    $0x2c,%esp
  801bdb:	8b 75 08             	mov    0x8(%ebp),%esi
  801bde:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801be1:	8b 7d 10             	mov    0x10(%ebp),%edi
  801be4:	eb 12                	jmp    801bf8 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801be6:	85 c0                	test   %eax,%eax
  801be8:	0f 84 89 03 00 00    	je     801f77 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801bee:	83 ec 08             	sub    $0x8,%esp
  801bf1:	53                   	push   %ebx
  801bf2:	50                   	push   %eax
  801bf3:	ff d6                	call   *%esi
  801bf5:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801bf8:	83 c7 01             	add    $0x1,%edi
  801bfb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801bff:	83 f8 25             	cmp    $0x25,%eax
  801c02:	75 e2                	jne    801be6 <vprintfmt+0x14>
  801c04:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801c08:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801c0f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801c16:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801c1d:	ba 00 00 00 00       	mov    $0x0,%edx
  801c22:	eb 07                	jmp    801c2b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c24:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801c27:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c2b:	8d 47 01             	lea    0x1(%edi),%eax
  801c2e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801c31:	0f b6 07             	movzbl (%edi),%eax
  801c34:	0f b6 c8             	movzbl %al,%ecx
  801c37:	83 e8 23             	sub    $0x23,%eax
  801c3a:	3c 55                	cmp    $0x55,%al
  801c3c:	0f 87 1a 03 00 00    	ja     801f5c <vprintfmt+0x38a>
  801c42:	0f b6 c0             	movzbl %al,%eax
  801c45:	ff 24 85 00 44 80 00 	jmp    *0x804400(,%eax,4)
  801c4c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801c4f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801c53:	eb d6                	jmp    801c2b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c55:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c58:	b8 00 00 00 00       	mov    $0x0,%eax
  801c5d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801c60:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801c63:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801c67:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801c6a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801c6d:	83 fa 09             	cmp    $0x9,%edx
  801c70:	77 39                	ja     801cab <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801c72:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801c75:	eb e9                	jmp    801c60 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801c77:	8b 45 14             	mov    0x14(%ebp),%eax
  801c7a:	8d 48 04             	lea    0x4(%eax),%ecx
  801c7d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801c80:	8b 00                	mov    (%eax),%eax
  801c82:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c85:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801c88:	eb 27                	jmp    801cb1 <vprintfmt+0xdf>
  801c8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c8d:	85 c0                	test   %eax,%eax
  801c8f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801c94:	0f 49 c8             	cmovns %eax,%ecx
  801c97:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c9a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c9d:	eb 8c                	jmp    801c2b <vprintfmt+0x59>
  801c9f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801ca2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801ca9:	eb 80                	jmp    801c2b <vprintfmt+0x59>
  801cab:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801cae:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801cb1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801cb5:	0f 89 70 ff ff ff    	jns    801c2b <vprintfmt+0x59>
				width = precision, precision = -1;
  801cbb:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801cbe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801cc1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801cc8:	e9 5e ff ff ff       	jmp    801c2b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801ccd:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cd0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801cd3:	e9 53 ff ff ff       	jmp    801c2b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801cd8:	8b 45 14             	mov    0x14(%ebp),%eax
  801cdb:	8d 50 04             	lea    0x4(%eax),%edx
  801cde:	89 55 14             	mov    %edx,0x14(%ebp)
  801ce1:	83 ec 08             	sub    $0x8,%esp
  801ce4:	53                   	push   %ebx
  801ce5:	ff 30                	pushl  (%eax)
  801ce7:	ff d6                	call   *%esi
			break;
  801ce9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801cef:	e9 04 ff ff ff       	jmp    801bf8 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801cf4:	8b 45 14             	mov    0x14(%ebp),%eax
  801cf7:	8d 50 04             	lea    0x4(%eax),%edx
  801cfa:	89 55 14             	mov    %edx,0x14(%ebp)
  801cfd:	8b 00                	mov    (%eax),%eax
  801cff:	99                   	cltd   
  801d00:	31 d0                	xor    %edx,%eax
  801d02:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801d04:	83 f8 0f             	cmp    $0xf,%eax
  801d07:	7f 0b                	jg     801d14 <vprintfmt+0x142>
  801d09:	8b 14 85 60 45 80 00 	mov    0x804560(,%eax,4),%edx
  801d10:	85 d2                	test   %edx,%edx
  801d12:	75 18                	jne    801d2c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801d14:	50                   	push   %eax
  801d15:	68 e3 42 80 00       	push   $0x8042e3
  801d1a:	53                   	push   %ebx
  801d1b:	56                   	push   %esi
  801d1c:	e8 94 fe ff ff       	call   801bb5 <printfmt>
  801d21:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d24:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801d27:	e9 cc fe ff ff       	jmp    801bf8 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801d2c:	52                   	push   %edx
  801d2d:	68 0f 3d 80 00       	push   $0x803d0f
  801d32:	53                   	push   %ebx
  801d33:	56                   	push   %esi
  801d34:	e8 7c fe ff ff       	call   801bb5 <printfmt>
  801d39:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d3c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d3f:	e9 b4 fe ff ff       	jmp    801bf8 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801d44:	8b 45 14             	mov    0x14(%ebp),%eax
  801d47:	8d 50 04             	lea    0x4(%eax),%edx
  801d4a:	89 55 14             	mov    %edx,0x14(%ebp)
  801d4d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801d4f:	85 ff                	test   %edi,%edi
  801d51:	b8 dc 42 80 00       	mov    $0x8042dc,%eax
  801d56:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801d59:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801d5d:	0f 8e 94 00 00 00    	jle    801df7 <vprintfmt+0x225>
  801d63:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801d67:	0f 84 98 00 00 00    	je     801e05 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801d6d:	83 ec 08             	sub    $0x8,%esp
  801d70:	ff 75 d0             	pushl  -0x30(%ebp)
  801d73:	57                   	push   %edi
  801d74:	e8 86 02 00 00       	call   801fff <strnlen>
  801d79:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801d7c:	29 c1                	sub    %eax,%ecx
  801d7e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801d81:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801d84:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801d88:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d8b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801d8e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801d90:	eb 0f                	jmp    801da1 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801d92:	83 ec 08             	sub    $0x8,%esp
  801d95:	53                   	push   %ebx
  801d96:	ff 75 e0             	pushl  -0x20(%ebp)
  801d99:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801d9b:	83 ef 01             	sub    $0x1,%edi
  801d9e:	83 c4 10             	add    $0x10,%esp
  801da1:	85 ff                	test   %edi,%edi
  801da3:	7f ed                	jg     801d92 <vprintfmt+0x1c0>
  801da5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801da8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801dab:	85 c9                	test   %ecx,%ecx
  801dad:	b8 00 00 00 00       	mov    $0x0,%eax
  801db2:	0f 49 c1             	cmovns %ecx,%eax
  801db5:	29 c1                	sub    %eax,%ecx
  801db7:	89 75 08             	mov    %esi,0x8(%ebp)
  801dba:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801dbd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801dc0:	89 cb                	mov    %ecx,%ebx
  801dc2:	eb 4d                	jmp    801e11 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801dc4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801dc8:	74 1b                	je     801de5 <vprintfmt+0x213>
  801dca:	0f be c0             	movsbl %al,%eax
  801dcd:	83 e8 20             	sub    $0x20,%eax
  801dd0:	83 f8 5e             	cmp    $0x5e,%eax
  801dd3:	76 10                	jbe    801de5 <vprintfmt+0x213>
					putch('?', putdat);
  801dd5:	83 ec 08             	sub    $0x8,%esp
  801dd8:	ff 75 0c             	pushl  0xc(%ebp)
  801ddb:	6a 3f                	push   $0x3f
  801ddd:	ff 55 08             	call   *0x8(%ebp)
  801de0:	83 c4 10             	add    $0x10,%esp
  801de3:	eb 0d                	jmp    801df2 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801de5:	83 ec 08             	sub    $0x8,%esp
  801de8:	ff 75 0c             	pushl  0xc(%ebp)
  801deb:	52                   	push   %edx
  801dec:	ff 55 08             	call   *0x8(%ebp)
  801def:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801df2:	83 eb 01             	sub    $0x1,%ebx
  801df5:	eb 1a                	jmp    801e11 <vprintfmt+0x23f>
  801df7:	89 75 08             	mov    %esi,0x8(%ebp)
  801dfa:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801dfd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801e00:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801e03:	eb 0c                	jmp    801e11 <vprintfmt+0x23f>
  801e05:	89 75 08             	mov    %esi,0x8(%ebp)
  801e08:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801e0b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801e0e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801e11:	83 c7 01             	add    $0x1,%edi
  801e14:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801e18:	0f be d0             	movsbl %al,%edx
  801e1b:	85 d2                	test   %edx,%edx
  801e1d:	74 23                	je     801e42 <vprintfmt+0x270>
  801e1f:	85 f6                	test   %esi,%esi
  801e21:	78 a1                	js     801dc4 <vprintfmt+0x1f2>
  801e23:	83 ee 01             	sub    $0x1,%esi
  801e26:	79 9c                	jns    801dc4 <vprintfmt+0x1f2>
  801e28:	89 df                	mov    %ebx,%edi
  801e2a:	8b 75 08             	mov    0x8(%ebp),%esi
  801e2d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e30:	eb 18                	jmp    801e4a <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801e32:	83 ec 08             	sub    $0x8,%esp
  801e35:	53                   	push   %ebx
  801e36:	6a 20                	push   $0x20
  801e38:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801e3a:	83 ef 01             	sub    $0x1,%edi
  801e3d:	83 c4 10             	add    $0x10,%esp
  801e40:	eb 08                	jmp    801e4a <vprintfmt+0x278>
  801e42:	89 df                	mov    %ebx,%edi
  801e44:	8b 75 08             	mov    0x8(%ebp),%esi
  801e47:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e4a:	85 ff                	test   %edi,%edi
  801e4c:	7f e4                	jg     801e32 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e4e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e51:	e9 a2 fd ff ff       	jmp    801bf8 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801e56:	83 fa 01             	cmp    $0x1,%edx
  801e59:	7e 16                	jle    801e71 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801e5b:	8b 45 14             	mov    0x14(%ebp),%eax
  801e5e:	8d 50 08             	lea    0x8(%eax),%edx
  801e61:	89 55 14             	mov    %edx,0x14(%ebp)
  801e64:	8b 50 04             	mov    0x4(%eax),%edx
  801e67:	8b 00                	mov    (%eax),%eax
  801e69:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e6c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801e6f:	eb 32                	jmp    801ea3 <vprintfmt+0x2d1>
	else if (lflag)
  801e71:	85 d2                	test   %edx,%edx
  801e73:	74 18                	je     801e8d <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801e75:	8b 45 14             	mov    0x14(%ebp),%eax
  801e78:	8d 50 04             	lea    0x4(%eax),%edx
  801e7b:	89 55 14             	mov    %edx,0x14(%ebp)
  801e7e:	8b 00                	mov    (%eax),%eax
  801e80:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e83:	89 c1                	mov    %eax,%ecx
  801e85:	c1 f9 1f             	sar    $0x1f,%ecx
  801e88:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801e8b:	eb 16                	jmp    801ea3 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801e8d:	8b 45 14             	mov    0x14(%ebp),%eax
  801e90:	8d 50 04             	lea    0x4(%eax),%edx
  801e93:	89 55 14             	mov    %edx,0x14(%ebp)
  801e96:	8b 00                	mov    (%eax),%eax
  801e98:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e9b:	89 c1                	mov    %eax,%ecx
  801e9d:	c1 f9 1f             	sar    $0x1f,%ecx
  801ea0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801ea3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801ea6:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801ea9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801eae:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801eb2:	79 74                	jns    801f28 <vprintfmt+0x356>
				putch('-', putdat);
  801eb4:	83 ec 08             	sub    $0x8,%esp
  801eb7:	53                   	push   %ebx
  801eb8:	6a 2d                	push   $0x2d
  801eba:	ff d6                	call   *%esi
				num = -(long long) num;
  801ebc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801ebf:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801ec2:	f7 d8                	neg    %eax
  801ec4:	83 d2 00             	adc    $0x0,%edx
  801ec7:	f7 da                	neg    %edx
  801ec9:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801ecc:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801ed1:	eb 55                	jmp    801f28 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801ed3:	8d 45 14             	lea    0x14(%ebp),%eax
  801ed6:	e8 83 fc ff ff       	call   801b5e <getuint>
			base = 10;
  801edb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801ee0:	eb 46                	jmp    801f28 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801ee2:	8d 45 14             	lea    0x14(%ebp),%eax
  801ee5:	e8 74 fc ff ff       	call   801b5e <getuint>
                        base = 8;
  801eea:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801eef:	eb 37                	jmp    801f28 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801ef1:	83 ec 08             	sub    $0x8,%esp
  801ef4:	53                   	push   %ebx
  801ef5:	6a 30                	push   $0x30
  801ef7:	ff d6                	call   *%esi
			putch('x', putdat);
  801ef9:	83 c4 08             	add    $0x8,%esp
  801efc:	53                   	push   %ebx
  801efd:	6a 78                	push   $0x78
  801eff:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801f01:	8b 45 14             	mov    0x14(%ebp),%eax
  801f04:	8d 50 04             	lea    0x4(%eax),%edx
  801f07:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801f0a:	8b 00                	mov    (%eax),%eax
  801f0c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801f11:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801f14:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801f19:	eb 0d                	jmp    801f28 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801f1b:	8d 45 14             	lea    0x14(%ebp),%eax
  801f1e:	e8 3b fc ff ff       	call   801b5e <getuint>
			base = 16;
  801f23:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801f28:	83 ec 0c             	sub    $0xc,%esp
  801f2b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801f2f:	57                   	push   %edi
  801f30:	ff 75 e0             	pushl  -0x20(%ebp)
  801f33:	51                   	push   %ecx
  801f34:	52                   	push   %edx
  801f35:	50                   	push   %eax
  801f36:	89 da                	mov    %ebx,%edx
  801f38:	89 f0                	mov    %esi,%eax
  801f3a:	e8 70 fb ff ff       	call   801aaf <printnum>
			break;
  801f3f:	83 c4 20             	add    $0x20,%esp
  801f42:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801f45:	e9 ae fc ff ff       	jmp    801bf8 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801f4a:	83 ec 08             	sub    $0x8,%esp
  801f4d:	53                   	push   %ebx
  801f4e:	51                   	push   %ecx
  801f4f:	ff d6                	call   *%esi
			break;
  801f51:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f54:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801f57:	e9 9c fc ff ff       	jmp    801bf8 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801f5c:	83 ec 08             	sub    $0x8,%esp
  801f5f:	53                   	push   %ebx
  801f60:	6a 25                	push   $0x25
  801f62:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801f64:	83 c4 10             	add    $0x10,%esp
  801f67:	eb 03                	jmp    801f6c <vprintfmt+0x39a>
  801f69:	83 ef 01             	sub    $0x1,%edi
  801f6c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801f70:	75 f7                	jne    801f69 <vprintfmt+0x397>
  801f72:	e9 81 fc ff ff       	jmp    801bf8 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801f77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f7a:	5b                   	pop    %ebx
  801f7b:	5e                   	pop    %esi
  801f7c:	5f                   	pop    %edi
  801f7d:	5d                   	pop    %ebp
  801f7e:	c3                   	ret    

00801f7f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801f7f:	55                   	push   %ebp
  801f80:	89 e5                	mov    %esp,%ebp
  801f82:	83 ec 18             	sub    $0x18,%esp
  801f85:	8b 45 08             	mov    0x8(%ebp),%eax
  801f88:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801f8b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801f8e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801f92:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801f95:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801f9c:	85 c0                	test   %eax,%eax
  801f9e:	74 26                	je     801fc6 <vsnprintf+0x47>
  801fa0:	85 d2                	test   %edx,%edx
  801fa2:	7e 22                	jle    801fc6 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801fa4:	ff 75 14             	pushl  0x14(%ebp)
  801fa7:	ff 75 10             	pushl  0x10(%ebp)
  801faa:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801fad:	50                   	push   %eax
  801fae:	68 98 1b 80 00       	push   $0x801b98
  801fb3:	e8 1a fc ff ff       	call   801bd2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801fb8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801fbb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801fbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc1:	83 c4 10             	add    $0x10,%esp
  801fc4:	eb 05                	jmp    801fcb <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801fc6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801fcb:	c9                   	leave  
  801fcc:	c3                   	ret    

00801fcd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801fcd:	55                   	push   %ebp
  801fce:	89 e5                	mov    %esp,%ebp
  801fd0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801fd3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801fd6:	50                   	push   %eax
  801fd7:	ff 75 10             	pushl  0x10(%ebp)
  801fda:	ff 75 0c             	pushl  0xc(%ebp)
  801fdd:	ff 75 08             	pushl  0x8(%ebp)
  801fe0:	e8 9a ff ff ff       	call   801f7f <vsnprintf>
	va_end(ap);

	return rc;
}
  801fe5:	c9                   	leave  
  801fe6:	c3                   	ret    

00801fe7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801fe7:	55                   	push   %ebp
  801fe8:	89 e5                	mov    %esp,%ebp
  801fea:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801fed:	b8 00 00 00 00       	mov    $0x0,%eax
  801ff2:	eb 03                	jmp    801ff7 <strlen+0x10>
		n++;
  801ff4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801ff7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801ffb:	75 f7                	jne    801ff4 <strlen+0xd>
		n++;
	return n;
}
  801ffd:	5d                   	pop    %ebp
  801ffe:	c3                   	ret    

00801fff <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801fff:	55                   	push   %ebp
  802000:	89 e5                	mov    %esp,%ebp
  802002:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802005:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802008:	ba 00 00 00 00       	mov    $0x0,%edx
  80200d:	eb 03                	jmp    802012 <strnlen+0x13>
		n++;
  80200f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802012:	39 c2                	cmp    %eax,%edx
  802014:	74 08                	je     80201e <strnlen+0x1f>
  802016:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80201a:	75 f3                	jne    80200f <strnlen+0x10>
  80201c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80201e:	5d                   	pop    %ebp
  80201f:	c3                   	ret    

00802020 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  802020:	55                   	push   %ebp
  802021:	89 e5                	mov    %esp,%ebp
  802023:	53                   	push   %ebx
  802024:	8b 45 08             	mov    0x8(%ebp),%eax
  802027:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80202a:	89 c2                	mov    %eax,%edx
  80202c:	83 c2 01             	add    $0x1,%edx
  80202f:	83 c1 01             	add    $0x1,%ecx
  802032:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  802036:	88 5a ff             	mov    %bl,-0x1(%edx)
  802039:	84 db                	test   %bl,%bl
  80203b:	75 ef                	jne    80202c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80203d:	5b                   	pop    %ebx
  80203e:	5d                   	pop    %ebp
  80203f:	c3                   	ret    

00802040 <strcat>:

char *
strcat(char *dst, const char *src)
{
  802040:	55                   	push   %ebp
  802041:	89 e5                	mov    %esp,%ebp
  802043:	53                   	push   %ebx
  802044:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  802047:	53                   	push   %ebx
  802048:	e8 9a ff ff ff       	call   801fe7 <strlen>
  80204d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  802050:	ff 75 0c             	pushl  0xc(%ebp)
  802053:	01 d8                	add    %ebx,%eax
  802055:	50                   	push   %eax
  802056:	e8 c5 ff ff ff       	call   802020 <strcpy>
	return dst;
}
  80205b:	89 d8                	mov    %ebx,%eax
  80205d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802060:	c9                   	leave  
  802061:	c3                   	ret    

00802062 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  802062:	55                   	push   %ebp
  802063:	89 e5                	mov    %esp,%ebp
  802065:	56                   	push   %esi
  802066:	53                   	push   %ebx
  802067:	8b 75 08             	mov    0x8(%ebp),%esi
  80206a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80206d:	89 f3                	mov    %esi,%ebx
  80206f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802072:	89 f2                	mov    %esi,%edx
  802074:	eb 0f                	jmp    802085 <strncpy+0x23>
		*dst++ = *src;
  802076:	83 c2 01             	add    $0x1,%edx
  802079:	0f b6 01             	movzbl (%ecx),%eax
  80207c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80207f:	80 39 01             	cmpb   $0x1,(%ecx)
  802082:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802085:	39 da                	cmp    %ebx,%edx
  802087:	75 ed                	jne    802076 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  802089:	89 f0                	mov    %esi,%eax
  80208b:	5b                   	pop    %ebx
  80208c:	5e                   	pop    %esi
  80208d:	5d                   	pop    %ebp
  80208e:	c3                   	ret    

0080208f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80208f:	55                   	push   %ebp
  802090:	89 e5                	mov    %esp,%ebp
  802092:	56                   	push   %esi
  802093:	53                   	push   %ebx
  802094:	8b 75 08             	mov    0x8(%ebp),%esi
  802097:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80209a:	8b 55 10             	mov    0x10(%ebp),%edx
  80209d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80209f:	85 d2                	test   %edx,%edx
  8020a1:	74 21                	je     8020c4 <strlcpy+0x35>
  8020a3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8020a7:	89 f2                	mov    %esi,%edx
  8020a9:	eb 09                	jmp    8020b4 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8020ab:	83 c2 01             	add    $0x1,%edx
  8020ae:	83 c1 01             	add    $0x1,%ecx
  8020b1:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8020b4:	39 c2                	cmp    %eax,%edx
  8020b6:	74 09                	je     8020c1 <strlcpy+0x32>
  8020b8:	0f b6 19             	movzbl (%ecx),%ebx
  8020bb:	84 db                	test   %bl,%bl
  8020bd:	75 ec                	jne    8020ab <strlcpy+0x1c>
  8020bf:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8020c1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8020c4:	29 f0                	sub    %esi,%eax
}
  8020c6:	5b                   	pop    %ebx
  8020c7:	5e                   	pop    %esi
  8020c8:	5d                   	pop    %ebp
  8020c9:	c3                   	ret    

008020ca <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8020ca:	55                   	push   %ebp
  8020cb:	89 e5                	mov    %esp,%ebp
  8020cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020d0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8020d3:	eb 06                	jmp    8020db <strcmp+0x11>
		p++, q++;
  8020d5:	83 c1 01             	add    $0x1,%ecx
  8020d8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8020db:	0f b6 01             	movzbl (%ecx),%eax
  8020de:	84 c0                	test   %al,%al
  8020e0:	74 04                	je     8020e6 <strcmp+0x1c>
  8020e2:	3a 02                	cmp    (%edx),%al
  8020e4:	74 ef                	je     8020d5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8020e6:	0f b6 c0             	movzbl %al,%eax
  8020e9:	0f b6 12             	movzbl (%edx),%edx
  8020ec:	29 d0                	sub    %edx,%eax
}
  8020ee:	5d                   	pop    %ebp
  8020ef:	c3                   	ret    

008020f0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8020f0:	55                   	push   %ebp
  8020f1:	89 e5                	mov    %esp,%ebp
  8020f3:	53                   	push   %ebx
  8020f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020fa:	89 c3                	mov    %eax,%ebx
  8020fc:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8020ff:	eb 06                	jmp    802107 <strncmp+0x17>
		n--, p++, q++;
  802101:	83 c0 01             	add    $0x1,%eax
  802104:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  802107:	39 d8                	cmp    %ebx,%eax
  802109:	74 15                	je     802120 <strncmp+0x30>
  80210b:	0f b6 08             	movzbl (%eax),%ecx
  80210e:	84 c9                	test   %cl,%cl
  802110:	74 04                	je     802116 <strncmp+0x26>
  802112:	3a 0a                	cmp    (%edx),%cl
  802114:	74 eb                	je     802101 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  802116:	0f b6 00             	movzbl (%eax),%eax
  802119:	0f b6 12             	movzbl (%edx),%edx
  80211c:	29 d0                	sub    %edx,%eax
  80211e:	eb 05                	jmp    802125 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  802120:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  802125:	5b                   	pop    %ebx
  802126:	5d                   	pop    %ebp
  802127:	c3                   	ret    

00802128 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  802128:	55                   	push   %ebp
  802129:	89 e5                	mov    %esp,%ebp
  80212b:	8b 45 08             	mov    0x8(%ebp),%eax
  80212e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802132:	eb 07                	jmp    80213b <strchr+0x13>
		if (*s == c)
  802134:	38 ca                	cmp    %cl,%dl
  802136:	74 0f                	je     802147 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  802138:	83 c0 01             	add    $0x1,%eax
  80213b:	0f b6 10             	movzbl (%eax),%edx
  80213e:	84 d2                	test   %dl,%dl
  802140:	75 f2                	jne    802134 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  802142:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802147:	5d                   	pop    %ebp
  802148:	c3                   	ret    

00802149 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  802149:	55                   	push   %ebp
  80214a:	89 e5                	mov    %esp,%ebp
  80214c:	8b 45 08             	mov    0x8(%ebp),%eax
  80214f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802153:	eb 03                	jmp    802158 <strfind+0xf>
  802155:	83 c0 01             	add    $0x1,%eax
  802158:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80215b:	38 ca                	cmp    %cl,%dl
  80215d:	74 04                	je     802163 <strfind+0x1a>
  80215f:	84 d2                	test   %dl,%dl
  802161:	75 f2                	jne    802155 <strfind+0xc>
			break;
	return (char *) s;
}
  802163:	5d                   	pop    %ebp
  802164:	c3                   	ret    

00802165 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  802165:	55                   	push   %ebp
  802166:	89 e5                	mov    %esp,%ebp
  802168:	57                   	push   %edi
  802169:	56                   	push   %esi
  80216a:	53                   	push   %ebx
  80216b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80216e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  802171:	85 c9                	test   %ecx,%ecx
  802173:	74 36                	je     8021ab <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  802175:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80217b:	75 28                	jne    8021a5 <memset+0x40>
  80217d:	f6 c1 03             	test   $0x3,%cl
  802180:	75 23                	jne    8021a5 <memset+0x40>
		c &= 0xFF;
  802182:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  802186:	89 d3                	mov    %edx,%ebx
  802188:	c1 e3 08             	shl    $0x8,%ebx
  80218b:	89 d6                	mov    %edx,%esi
  80218d:	c1 e6 18             	shl    $0x18,%esi
  802190:	89 d0                	mov    %edx,%eax
  802192:	c1 e0 10             	shl    $0x10,%eax
  802195:	09 f0                	or     %esi,%eax
  802197:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  802199:	89 d8                	mov    %ebx,%eax
  80219b:	09 d0                	or     %edx,%eax
  80219d:	c1 e9 02             	shr    $0x2,%ecx
  8021a0:	fc                   	cld    
  8021a1:	f3 ab                	rep stos %eax,%es:(%edi)
  8021a3:	eb 06                	jmp    8021ab <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8021a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021a8:	fc                   	cld    
  8021a9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8021ab:	89 f8                	mov    %edi,%eax
  8021ad:	5b                   	pop    %ebx
  8021ae:	5e                   	pop    %esi
  8021af:	5f                   	pop    %edi
  8021b0:	5d                   	pop    %ebp
  8021b1:	c3                   	ret    

008021b2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8021b2:	55                   	push   %ebp
  8021b3:	89 e5                	mov    %esp,%ebp
  8021b5:	57                   	push   %edi
  8021b6:	56                   	push   %esi
  8021b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ba:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021bd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8021c0:	39 c6                	cmp    %eax,%esi
  8021c2:	73 35                	jae    8021f9 <memmove+0x47>
  8021c4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8021c7:	39 d0                	cmp    %edx,%eax
  8021c9:	73 2e                	jae    8021f9 <memmove+0x47>
		s += n;
		d += n;
  8021cb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8021ce:	89 d6                	mov    %edx,%esi
  8021d0:	09 fe                	or     %edi,%esi
  8021d2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8021d8:	75 13                	jne    8021ed <memmove+0x3b>
  8021da:	f6 c1 03             	test   $0x3,%cl
  8021dd:	75 0e                	jne    8021ed <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8021df:	83 ef 04             	sub    $0x4,%edi
  8021e2:	8d 72 fc             	lea    -0x4(%edx),%esi
  8021e5:	c1 e9 02             	shr    $0x2,%ecx
  8021e8:	fd                   	std    
  8021e9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8021eb:	eb 09                	jmp    8021f6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8021ed:	83 ef 01             	sub    $0x1,%edi
  8021f0:	8d 72 ff             	lea    -0x1(%edx),%esi
  8021f3:	fd                   	std    
  8021f4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8021f6:	fc                   	cld    
  8021f7:	eb 1d                	jmp    802216 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8021f9:	89 f2                	mov    %esi,%edx
  8021fb:	09 c2                	or     %eax,%edx
  8021fd:	f6 c2 03             	test   $0x3,%dl
  802200:	75 0f                	jne    802211 <memmove+0x5f>
  802202:	f6 c1 03             	test   $0x3,%cl
  802205:	75 0a                	jne    802211 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  802207:	c1 e9 02             	shr    $0x2,%ecx
  80220a:	89 c7                	mov    %eax,%edi
  80220c:	fc                   	cld    
  80220d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80220f:	eb 05                	jmp    802216 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  802211:	89 c7                	mov    %eax,%edi
  802213:	fc                   	cld    
  802214:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  802216:	5e                   	pop    %esi
  802217:	5f                   	pop    %edi
  802218:	5d                   	pop    %ebp
  802219:	c3                   	ret    

0080221a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80221a:	55                   	push   %ebp
  80221b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80221d:	ff 75 10             	pushl  0x10(%ebp)
  802220:	ff 75 0c             	pushl  0xc(%ebp)
  802223:	ff 75 08             	pushl  0x8(%ebp)
  802226:	e8 87 ff ff ff       	call   8021b2 <memmove>
}
  80222b:	c9                   	leave  
  80222c:	c3                   	ret    

0080222d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80222d:	55                   	push   %ebp
  80222e:	89 e5                	mov    %esp,%ebp
  802230:	56                   	push   %esi
  802231:	53                   	push   %ebx
  802232:	8b 45 08             	mov    0x8(%ebp),%eax
  802235:	8b 55 0c             	mov    0xc(%ebp),%edx
  802238:	89 c6                	mov    %eax,%esi
  80223a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80223d:	eb 1a                	jmp    802259 <memcmp+0x2c>
		if (*s1 != *s2)
  80223f:	0f b6 08             	movzbl (%eax),%ecx
  802242:	0f b6 1a             	movzbl (%edx),%ebx
  802245:	38 d9                	cmp    %bl,%cl
  802247:	74 0a                	je     802253 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  802249:	0f b6 c1             	movzbl %cl,%eax
  80224c:	0f b6 db             	movzbl %bl,%ebx
  80224f:	29 d8                	sub    %ebx,%eax
  802251:	eb 0f                	jmp    802262 <memcmp+0x35>
		s1++, s2++;
  802253:	83 c0 01             	add    $0x1,%eax
  802256:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802259:	39 f0                	cmp    %esi,%eax
  80225b:	75 e2                	jne    80223f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80225d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802262:	5b                   	pop    %ebx
  802263:	5e                   	pop    %esi
  802264:	5d                   	pop    %ebp
  802265:	c3                   	ret    

00802266 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  802266:	55                   	push   %ebp
  802267:	89 e5                	mov    %esp,%ebp
  802269:	53                   	push   %ebx
  80226a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80226d:	89 c1                	mov    %eax,%ecx
  80226f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  802272:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802276:	eb 0a                	jmp    802282 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  802278:	0f b6 10             	movzbl (%eax),%edx
  80227b:	39 da                	cmp    %ebx,%edx
  80227d:	74 07                	je     802286 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80227f:	83 c0 01             	add    $0x1,%eax
  802282:	39 c8                	cmp    %ecx,%eax
  802284:	72 f2                	jb     802278 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  802286:	5b                   	pop    %ebx
  802287:	5d                   	pop    %ebp
  802288:	c3                   	ret    

00802289 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  802289:	55                   	push   %ebp
  80228a:	89 e5                	mov    %esp,%ebp
  80228c:	57                   	push   %edi
  80228d:	56                   	push   %esi
  80228e:	53                   	push   %ebx
  80228f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802292:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802295:	eb 03                	jmp    80229a <strtol+0x11>
		s++;
  802297:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80229a:	0f b6 01             	movzbl (%ecx),%eax
  80229d:	3c 20                	cmp    $0x20,%al
  80229f:	74 f6                	je     802297 <strtol+0xe>
  8022a1:	3c 09                	cmp    $0x9,%al
  8022a3:	74 f2                	je     802297 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8022a5:	3c 2b                	cmp    $0x2b,%al
  8022a7:	75 0a                	jne    8022b3 <strtol+0x2a>
		s++;
  8022a9:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8022ac:	bf 00 00 00 00       	mov    $0x0,%edi
  8022b1:	eb 11                	jmp    8022c4 <strtol+0x3b>
  8022b3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8022b8:	3c 2d                	cmp    $0x2d,%al
  8022ba:	75 08                	jne    8022c4 <strtol+0x3b>
		s++, neg = 1;
  8022bc:	83 c1 01             	add    $0x1,%ecx
  8022bf:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8022c4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8022ca:	75 15                	jne    8022e1 <strtol+0x58>
  8022cc:	80 39 30             	cmpb   $0x30,(%ecx)
  8022cf:	75 10                	jne    8022e1 <strtol+0x58>
  8022d1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8022d5:	75 7c                	jne    802353 <strtol+0xca>
		s += 2, base = 16;
  8022d7:	83 c1 02             	add    $0x2,%ecx
  8022da:	bb 10 00 00 00       	mov    $0x10,%ebx
  8022df:	eb 16                	jmp    8022f7 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8022e1:	85 db                	test   %ebx,%ebx
  8022e3:	75 12                	jne    8022f7 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8022e5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8022ea:	80 39 30             	cmpb   $0x30,(%ecx)
  8022ed:	75 08                	jne    8022f7 <strtol+0x6e>
		s++, base = 8;
  8022ef:	83 c1 01             	add    $0x1,%ecx
  8022f2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8022f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8022fc:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8022ff:	0f b6 11             	movzbl (%ecx),%edx
  802302:	8d 72 d0             	lea    -0x30(%edx),%esi
  802305:	89 f3                	mov    %esi,%ebx
  802307:	80 fb 09             	cmp    $0x9,%bl
  80230a:	77 08                	ja     802314 <strtol+0x8b>
			dig = *s - '0';
  80230c:	0f be d2             	movsbl %dl,%edx
  80230f:	83 ea 30             	sub    $0x30,%edx
  802312:	eb 22                	jmp    802336 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  802314:	8d 72 9f             	lea    -0x61(%edx),%esi
  802317:	89 f3                	mov    %esi,%ebx
  802319:	80 fb 19             	cmp    $0x19,%bl
  80231c:	77 08                	ja     802326 <strtol+0x9d>
			dig = *s - 'a' + 10;
  80231e:	0f be d2             	movsbl %dl,%edx
  802321:	83 ea 57             	sub    $0x57,%edx
  802324:	eb 10                	jmp    802336 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  802326:	8d 72 bf             	lea    -0x41(%edx),%esi
  802329:	89 f3                	mov    %esi,%ebx
  80232b:	80 fb 19             	cmp    $0x19,%bl
  80232e:	77 16                	ja     802346 <strtol+0xbd>
			dig = *s - 'A' + 10;
  802330:	0f be d2             	movsbl %dl,%edx
  802333:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  802336:	3b 55 10             	cmp    0x10(%ebp),%edx
  802339:	7d 0b                	jge    802346 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  80233b:	83 c1 01             	add    $0x1,%ecx
  80233e:	0f af 45 10          	imul   0x10(%ebp),%eax
  802342:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  802344:	eb b9                	jmp    8022ff <strtol+0x76>

	if (endptr)
  802346:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80234a:	74 0d                	je     802359 <strtol+0xd0>
		*endptr = (char *) s;
  80234c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80234f:	89 0e                	mov    %ecx,(%esi)
  802351:	eb 06                	jmp    802359 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  802353:	85 db                	test   %ebx,%ebx
  802355:	74 98                	je     8022ef <strtol+0x66>
  802357:	eb 9e                	jmp    8022f7 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  802359:	89 c2                	mov    %eax,%edx
  80235b:	f7 da                	neg    %edx
  80235d:	85 ff                	test   %edi,%edi
  80235f:	0f 45 c2             	cmovne %edx,%eax
}
  802362:	5b                   	pop    %ebx
  802363:	5e                   	pop    %esi
  802364:	5f                   	pop    %edi
  802365:	5d                   	pop    %ebp
  802366:	c3                   	ret    

00802367 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  802367:	55                   	push   %ebp
  802368:	89 e5                	mov    %esp,%ebp
  80236a:	57                   	push   %edi
  80236b:	56                   	push   %esi
  80236c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80236d:	b8 00 00 00 00       	mov    $0x0,%eax
  802372:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802375:	8b 55 08             	mov    0x8(%ebp),%edx
  802378:	89 c3                	mov    %eax,%ebx
  80237a:	89 c7                	mov    %eax,%edi
  80237c:	89 c6                	mov    %eax,%esi
  80237e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  802380:	5b                   	pop    %ebx
  802381:	5e                   	pop    %esi
  802382:	5f                   	pop    %edi
  802383:	5d                   	pop    %ebp
  802384:	c3                   	ret    

00802385 <sys_cgetc>:

int
sys_cgetc(void)
{
  802385:	55                   	push   %ebp
  802386:	89 e5                	mov    %esp,%ebp
  802388:	57                   	push   %edi
  802389:	56                   	push   %esi
  80238a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80238b:	ba 00 00 00 00       	mov    $0x0,%edx
  802390:	b8 01 00 00 00       	mov    $0x1,%eax
  802395:	89 d1                	mov    %edx,%ecx
  802397:	89 d3                	mov    %edx,%ebx
  802399:	89 d7                	mov    %edx,%edi
  80239b:	89 d6                	mov    %edx,%esi
  80239d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80239f:	5b                   	pop    %ebx
  8023a0:	5e                   	pop    %esi
  8023a1:	5f                   	pop    %edi
  8023a2:	5d                   	pop    %ebp
  8023a3:	c3                   	ret    

008023a4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8023a4:	55                   	push   %ebp
  8023a5:	89 e5                	mov    %esp,%ebp
  8023a7:	57                   	push   %edi
  8023a8:	56                   	push   %esi
  8023a9:	53                   	push   %ebx
  8023aa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8023ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  8023b2:	b8 03 00 00 00       	mov    $0x3,%eax
  8023b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8023ba:	89 cb                	mov    %ecx,%ebx
  8023bc:	89 cf                	mov    %ecx,%edi
  8023be:	89 ce                	mov    %ecx,%esi
  8023c0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8023c2:	85 c0                	test   %eax,%eax
  8023c4:	7e 17                	jle    8023dd <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8023c6:	83 ec 0c             	sub    $0xc,%esp
  8023c9:	50                   	push   %eax
  8023ca:	6a 03                	push   $0x3
  8023cc:	68 bf 45 80 00       	push   $0x8045bf
  8023d1:	6a 23                	push   $0x23
  8023d3:	68 dc 45 80 00       	push   $0x8045dc
  8023d8:	e8 e5 f5 ff ff       	call   8019c2 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8023dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023e0:	5b                   	pop    %ebx
  8023e1:	5e                   	pop    %esi
  8023e2:	5f                   	pop    %edi
  8023e3:	5d                   	pop    %ebp
  8023e4:	c3                   	ret    

008023e5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8023e5:	55                   	push   %ebp
  8023e6:	89 e5                	mov    %esp,%ebp
  8023e8:	57                   	push   %edi
  8023e9:	56                   	push   %esi
  8023ea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8023eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8023f0:	b8 02 00 00 00       	mov    $0x2,%eax
  8023f5:	89 d1                	mov    %edx,%ecx
  8023f7:	89 d3                	mov    %edx,%ebx
  8023f9:	89 d7                	mov    %edx,%edi
  8023fb:	89 d6                	mov    %edx,%esi
  8023fd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8023ff:	5b                   	pop    %ebx
  802400:	5e                   	pop    %esi
  802401:	5f                   	pop    %edi
  802402:	5d                   	pop    %ebp
  802403:	c3                   	ret    

00802404 <sys_yield>:

void
sys_yield(void)
{
  802404:	55                   	push   %ebp
  802405:	89 e5                	mov    %esp,%ebp
  802407:	57                   	push   %edi
  802408:	56                   	push   %esi
  802409:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80240a:	ba 00 00 00 00       	mov    $0x0,%edx
  80240f:	b8 0b 00 00 00       	mov    $0xb,%eax
  802414:	89 d1                	mov    %edx,%ecx
  802416:	89 d3                	mov    %edx,%ebx
  802418:	89 d7                	mov    %edx,%edi
  80241a:	89 d6                	mov    %edx,%esi
  80241c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80241e:	5b                   	pop    %ebx
  80241f:	5e                   	pop    %esi
  802420:	5f                   	pop    %edi
  802421:	5d                   	pop    %ebp
  802422:	c3                   	ret    

00802423 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  802423:	55                   	push   %ebp
  802424:	89 e5                	mov    %esp,%ebp
  802426:	57                   	push   %edi
  802427:	56                   	push   %esi
  802428:	53                   	push   %ebx
  802429:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80242c:	be 00 00 00 00       	mov    $0x0,%esi
  802431:	b8 04 00 00 00       	mov    $0x4,%eax
  802436:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802439:	8b 55 08             	mov    0x8(%ebp),%edx
  80243c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80243f:	89 f7                	mov    %esi,%edi
  802441:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802443:	85 c0                	test   %eax,%eax
  802445:	7e 17                	jle    80245e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802447:	83 ec 0c             	sub    $0xc,%esp
  80244a:	50                   	push   %eax
  80244b:	6a 04                	push   $0x4
  80244d:	68 bf 45 80 00       	push   $0x8045bf
  802452:	6a 23                	push   $0x23
  802454:	68 dc 45 80 00       	push   $0x8045dc
  802459:	e8 64 f5 ff ff       	call   8019c2 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80245e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802461:	5b                   	pop    %ebx
  802462:	5e                   	pop    %esi
  802463:	5f                   	pop    %edi
  802464:	5d                   	pop    %ebp
  802465:	c3                   	ret    

00802466 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  802466:	55                   	push   %ebp
  802467:	89 e5                	mov    %esp,%ebp
  802469:	57                   	push   %edi
  80246a:	56                   	push   %esi
  80246b:	53                   	push   %ebx
  80246c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80246f:	b8 05 00 00 00       	mov    $0x5,%eax
  802474:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802477:	8b 55 08             	mov    0x8(%ebp),%edx
  80247a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80247d:	8b 7d 14             	mov    0x14(%ebp),%edi
  802480:	8b 75 18             	mov    0x18(%ebp),%esi
  802483:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802485:	85 c0                	test   %eax,%eax
  802487:	7e 17                	jle    8024a0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802489:	83 ec 0c             	sub    $0xc,%esp
  80248c:	50                   	push   %eax
  80248d:	6a 05                	push   $0x5
  80248f:	68 bf 45 80 00       	push   $0x8045bf
  802494:	6a 23                	push   $0x23
  802496:	68 dc 45 80 00       	push   $0x8045dc
  80249b:	e8 22 f5 ff ff       	call   8019c2 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8024a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024a3:	5b                   	pop    %ebx
  8024a4:	5e                   	pop    %esi
  8024a5:	5f                   	pop    %edi
  8024a6:	5d                   	pop    %ebp
  8024a7:	c3                   	ret    

008024a8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8024a8:	55                   	push   %ebp
  8024a9:	89 e5                	mov    %esp,%ebp
  8024ab:	57                   	push   %edi
  8024ac:	56                   	push   %esi
  8024ad:	53                   	push   %ebx
  8024ae:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024b1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024b6:	b8 06 00 00 00       	mov    $0x6,%eax
  8024bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024be:	8b 55 08             	mov    0x8(%ebp),%edx
  8024c1:	89 df                	mov    %ebx,%edi
  8024c3:	89 de                	mov    %ebx,%esi
  8024c5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8024c7:	85 c0                	test   %eax,%eax
  8024c9:	7e 17                	jle    8024e2 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8024cb:	83 ec 0c             	sub    $0xc,%esp
  8024ce:	50                   	push   %eax
  8024cf:	6a 06                	push   $0x6
  8024d1:	68 bf 45 80 00       	push   $0x8045bf
  8024d6:	6a 23                	push   $0x23
  8024d8:	68 dc 45 80 00       	push   $0x8045dc
  8024dd:	e8 e0 f4 ff ff       	call   8019c2 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8024e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024e5:	5b                   	pop    %ebx
  8024e6:	5e                   	pop    %esi
  8024e7:	5f                   	pop    %edi
  8024e8:	5d                   	pop    %ebp
  8024e9:	c3                   	ret    

008024ea <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8024ea:	55                   	push   %ebp
  8024eb:	89 e5                	mov    %esp,%ebp
  8024ed:	57                   	push   %edi
  8024ee:	56                   	push   %esi
  8024ef:	53                   	push   %ebx
  8024f0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024f3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024f8:	b8 08 00 00 00       	mov    $0x8,%eax
  8024fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802500:	8b 55 08             	mov    0x8(%ebp),%edx
  802503:	89 df                	mov    %ebx,%edi
  802505:	89 de                	mov    %ebx,%esi
  802507:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802509:	85 c0                	test   %eax,%eax
  80250b:	7e 17                	jle    802524 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80250d:	83 ec 0c             	sub    $0xc,%esp
  802510:	50                   	push   %eax
  802511:	6a 08                	push   $0x8
  802513:	68 bf 45 80 00       	push   $0x8045bf
  802518:	6a 23                	push   $0x23
  80251a:	68 dc 45 80 00       	push   $0x8045dc
  80251f:	e8 9e f4 ff ff       	call   8019c2 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  802524:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802527:	5b                   	pop    %ebx
  802528:	5e                   	pop    %esi
  802529:	5f                   	pop    %edi
  80252a:	5d                   	pop    %ebp
  80252b:	c3                   	ret    

0080252c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80252c:	55                   	push   %ebp
  80252d:	89 e5                	mov    %esp,%ebp
  80252f:	57                   	push   %edi
  802530:	56                   	push   %esi
  802531:	53                   	push   %ebx
  802532:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802535:	bb 00 00 00 00       	mov    $0x0,%ebx
  80253a:	b8 09 00 00 00       	mov    $0x9,%eax
  80253f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802542:	8b 55 08             	mov    0x8(%ebp),%edx
  802545:	89 df                	mov    %ebx,%edi
  802547:	89 de                	mov    %ebx,%esi
  802549:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80254b:	85 c0                	test   %eax,%eax
  80254d:	7e 17                	jle    802566 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80254f:	83 ec 0c             	sub    $0xc,%esp
  802552:	50                   	push   %eax
  802553:	6a 09                	push   $0x9
  802555:	68 bf 45 80 00       	push   $0x8045bf
  80255a:	6a 23                	push   $0x23
  80255c:	68 dc 45 80 00       	push   $0x8045dc
  802561:	e8 5c f4 ff ff       	call   8019c2 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  802566:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802569:	5b                   	pop    %ebx
  80256a:	5e                   	pop    %esi
  80256b:	5f                   	pop    %edi
  80256c:	5d                   	pop    %ebp
  80256d:	c3                   	ret    

0080256e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80256e:	55                   	push   %ebp
  80256f:	89 e5                	mov    %esp,%ebp
  802571:	57                   	push   %edi
  802572:	56                   	push   %esi
  802573:	53                   	push   %ebx
  802574:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802577:	bb 00 00 00 00       	mov    $0x0,%ebx
  80257c:	b8 0a 00 00 00       	mov    $0xa,%eax
  802581:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802584:	8b 55 08             	mov    0x8(%ebp),%edx
  802587:	89 df                	mov    %ebx,%edi
  802589:	89 de                	mov    %ebx,%esi
  80258b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80258d:	85 c0                	test   %eax,%eax
  80258f:	7e 17                	jle    8025a8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802591:	83 ec 0c             	sub    $0xc,%esp
  802594:	50                   	push   %eax
  802595:	6a 0a                	push   $0xa
  802597:	68 bf 45 80 00       	push   $0x8045bf
  80259c:	6a 23                	push   $0x23
  80259e:	68 dc 45 80 00       	push   $0x8045dc
  8025a3:	e8 1a f4 ff ff       	call   8019c2 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8025a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025ab:	5b                   	pop    %ebx
  8025ac:	5e                   	pop    %esi
  8025ad:	5f                   	pop    %edi
  8025ae:	5d                   	pop    %ebp
  8025af:	c3                   	ret    

008025b0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8025b0:	55                   	push   %ebp
  8025b1:	89 e5                	mov    %esp,%ebp
  8025b3:	57                   	push   %edi
  8025b4:	56                   	push   %esi
  8025b5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025b6:	be 00 00 00 00       	mov    $0x0,%esi
  8025bb:	b8 0c 00 00 00       	mov    $0xc,%eax
  8025c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8025c6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8025c9:	8b 7d 14             	mov    0x14(%ebp),%edi
  8025cc:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8025ce:	5b                   	pop    %ebx
  8025cf:	5e                   	pop    %esi
  8025d0:	5f                   	pop    %edi
  8025d1:	5d                   	pop    %ebp
  8025d2:	c3                   	ret    

008025d3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8025d3:	55                   	push   %ebp
  8025d4:	89 e5                	mov    %esp,%ebp
  8025d6:	57                   	push   %edi
  8025d7:	56                   	push   %esi
  8025d8:	53                   	push   %ebx
  8025d9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8025e1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8025e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8025e9:	89 cb                	mov    %ecx,%ebx
  8025eb:	89 cf                	mov    %ecx,%edi
  8025ed:	89 ce                	mov    %ecx,%esi
  8025ef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8025f1:	85 c0                	test   %eax,%eax
  8025f3:	7e 17                	jle    80260c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8025f5:	83 ec 0c             	sub    $0xc,%esp
  8025f8:	50                   	push   %eax
  8025f9:	6a 0d                	push   $0xd
  8025fb:	68 bf 45 80 00       	push   $0x8045bf
  802600:	6a 23                	push   $0x23
  802602:	68 dc 45 80 00       	push   $0x8045dc
  802607:	e8 b6 f3 ff ff       	call   8019c2 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80260c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80260f:	5b                   	pop    %ebx
  802610:	5e                   	pop    %esi
  802611:	5f                   	pop    %edi
  802612:	5d                   	pop    %ebp
  802613:	c3                   	ret    

00802614 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  802614:	55                   	push   %ebp
  802615:	89 e5                	mov    %esp,%ebp
  802617:	57                   	push   %edi
  802618:	56                   	push   %esi
  802619:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80261a:	ba 00 00 00 00       	mov    $0x0,%edx
  80261f:	b8 0e 00 00 00       	mov    $0xe,%eax
  802624:	89 d1                	mov    %edx,%ecx
  802626:	89 d3                	mov    %edx,%ebx
  802628:	89 d7                	mov    %edx,%edi
  80262a:	89 d6                	mov    %edx,%esi
  80262c:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80262e:	5b                   	pop    %ebx
  80262f:	5e                   	pop    %esi
  802630:	5f                   	pop    %edi
  802631:	5d                   	pop    %ebp
  802632:	c3                   	ret    

00802633 <sys_transmit_packet>:

int
sys_transmit_packet(void *buf, size_t size)
{
  802633:	55                   	push   %ebp
  802634:	89 e5                	mov    %esp,%ebp
  802636:	57                   	push   %edi
  802637:	56                   	push   %esi
  802638:	53                   	push   %ebx
  802639:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80263c:	bb 00 00 00 00       	mov    $0x0,%ebx
  802641:	b8 0f 00 00 00       	mov    $0xf,%eax
  802646:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802649:	8b 55 08             	mov    0x8(%ebp),%edx
  80264c:	89 df                	mov    %ebx,%edi
  80264e:	89 de                	mov    %ebx,%esi
  802650:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802652:	85 c0                	test   %eax,%eax
  802654:	7e 17                	jle    80266d <sys_transmit_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802656:	83 ec 0c             	sub    $0xc,%esp
  802659:	50                   	push   %eax
  80265a:	6a 0f                	push   $0xf
  80265c:	68 bf 45 80 00       	push   $0x8045bf
  802661:	6a 23                	push   $0x23
  802663:	68 dc 45 80 00       	push   $0x8045dc
  802668:	e8 55 f3 ff ff       	call   8019c2 <_panic>
int
sys_transmit_packet(void *buf, size_t size)
{
	return syscall(SYS_transmit_packet, 1,
		(uint32_t) buf, (uint32_t) size, 0, 0, 0);
}
  80266d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802670:	5b                   	pop    %ebx
  802671:	5e                   	pop    %esi
  802672:	5f                   	pop    %edi
  802673:	5d                   	pop    %ebp
  802674:	c3                   	ret    

00802675 <sys_receive_packet>:

int
sys_receive_packet(void *buf, size_t *size_store)
{
  802675:	55                   	push   %ebp
  802676:	89 e5                	mov    %esp,%ebp
  802678:	57                   	push   %edi
  802679:	56                   	push   %esi
  80267a:	53                   	push   %ebx
  80267b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80267e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802683:	b8 10 00 00 00       	mov    $0x10,%eax
  802688:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80268b:	8b 55 08             	mov    0x8(%ebp),%edx
  80268e:	89 df                	mov    %ebx,%edi
  802690:	89 de                	mov    %ebx,%esi
  802692:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802694:	85 c0                	test   %eax,%eax
  802696:	7e 17                	jle    8026af <sys_receive_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802698:	83 ec 0c             	sub    $0xc,%esp
  80269b:	50                   	push   %eax
  80269c:	6a 10                	push   $0x10
  80269e:	68 bf 45 80 00       	push   $0x8045bf
  8026a3:	6a 23                	push   $0x23
  8026a5:	68 dc 45 80 00       	push   $0x8045dc
  8026aa:	e8 13 f3 ff ff       	call   8019c2 <_panic>
int
sys_receive_packet(void *buf, size_t *size_store)
{
	return syscall(SYS_receive_packet, 1,
		(uint32_t) buf, (uint32_t) size_store, 0, 0, 0);
}
  8026af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026b2:	5b                   	pop    %ebx
  8026b3:	5e                   	pop    %esi
  8026b4:	5f                   	pop    %edi
  8026b5:	5d                   	pop    %ebp
  8026b6:	c3                   	ret    

008026b7 <sys_get_mac_address>:

int
sys_get_mac_address(void *buf)
{
  8026b7:	55                   	push   %ebp
  8026b8:	89 e5                	mov    %esp,%ebp
  8026ba:	57                   	push   %edi
  8026bb:	56                   	push   %esi
  8026bc:	53                   	push   %ebx
  8026bd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8026c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8026c5:	b8 11 00 00 00       	mov    $0x11,%eax
  8026ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8026cd:	89 cb                	mov    %ecx,%ebx
  8026cf:	89 cf                	mov    %ecx,%edi
  8026d1:	89 ce                	mov    %ecx,%esi
  8026d3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8026d5:	85 c0                	test   %eax,%eax
  8026d7:	7e 17                	jle    8026f0 <sys_get_mac_address+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8026d9:	83 ec 0c             	sub    $0xc,%esp
  8026dc:	50                   	push   %eax
  8026dd:	6a 11                	push   $0x11
  8026df:	68 bf 45 80 00       	push   $0x8045bf
  8026e4:	6a 23                	push   $0x23
  8026e6:	68 dc 45 80 00       	push   $0x8045dc
  8026eb:	e8 d2 f2 ff ff       	call   8019c2 <_panic>
int
sys_get_mac_address(void *buf)
{
	return syscall(SYS_get_mac_address, 1,
		(uint32_t) buf, 0, 0, 0, 0);
}
  8026f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026f3:	5b                   	pop    %ebx
  8026f4:	5e                   	pop    %esi
  8026f5:	5f                   	pop    %edi
  8026f6:	5d                   	pop    %ebp
  8026f7:	c3                   	ret    

008026f8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8026f8:	55                   	push   %ebp
  8026f9:	89 e5                	mov    %esp,%ebp
  8026fb:	53                   	push   %ebx
  8026fc:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  8026ff:	83 3d 14 a0 80 00 00 	cmpl   $0x0,0x80a014
  802706:	75 28                	jne    802730 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  802708:	e8 d8 fc ff ff       	call   8023e5 <sys_getenvid>
  80270d:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  80270f:	83 ec 04             	sub    $0x4,%esp
  802712:	6a 06                	push   $0x6
  802714:	68 00 f0 bf ee       	push   $0xeebff000
  802719:	50                   	push   %eax
  80271a:	e8 04 fd ff ff       	call   802423 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  80271f:	83 c4 08             	add    $0x8,%esp
  802722:	68 3d 27 80 00       	push   $0x80273d
  802727:	53                   	push   %ebx
  802728:	e8 41 fe ff ff       	call   80256e <sys_env_set_pgfault_upcall>
  80272d:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802730:	8b 45 08             	mov    0x8(%ebp),%eax
  802733:	a3 14 a0 80 00       	mov    %eax,0x80a014
}
  802738:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80273b:	c9                   	leave  
  80273c:	c3                   	ret    

0080273d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80273d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80273e:	a1 14 a0 80 00       	mov    0x80a014,%eax
	call *%eax
  802743:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802745:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  802748:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  80274a:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  80274d:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  802750:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  802753:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  802756:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  802759:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  80275c:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  80275f:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  802762:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  802765:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  802768:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  80276b:	61                   	popa   
	popfl
  80276c:	9d                   	popf   
	ret
  80276d:	c3                   	ret    

0080276e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80276e:	55                   	push   %ebp
  80276f:	89 e5                	mov    %esp,%ebp
  802771:	56                   	push   %esi
  802772:	53                   	push   %ebx
  802773:	8b 75 08             	mov    0x8(%ebp),%esi
  802776:	8b 45 0c             	mov    0xc(%ebp),%eax
  802779:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  80277c:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  80277e:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  802783:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  802786:	83 ec 0c             	sub    $0xc,%esp
  802789:	50                   	push   %eax
  80278a:	e8 44 fe ff ff       	call   8025d3 <sys_ipc_recv>

	if (r < 0) {
  80278f:	83 c4 10             	add    $0x10,%esp
  802792:	85 c0                	test   %eax,%eax
  802794:	79 16                	jns    8027ac <ipc_recv+0x3e>
		if (from_env_store)
  802796:	85 f6                	test   %esi,%esi
  802798:	74 06                	je     8027a0 <ipc_recv+0x32>
			*from_env_store = 0;
  80279a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  8027a0:	85 db                	test   %ebx,%ebx
  8027a2:	74 2c                	je     8027d0 <ipc_recv+0x62>
			*perm_store = 0;
  8027a4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8027aa:	eb 24                	jmp    8027d0 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  8027ac:	85 f6                	test   %esi,%esi
  8027ae:	74 0a                	je     8027ba <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  8027b0:	a1 10 a0 80 00       	mov    0x80a010,%eax
  8027b5:	8b 40 74             	mov    0x74(%eax),%eax
  8027b8:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  8027ba:	85 db                	test   %ebx,%ebx
  8027bc:	74 0a                	je     8027c8 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  8027be:	a1 10 a0 80 00       	mov    0x80a010,%eax
  8027c3:	8b 40 78             	mov    0x78(%eax),%eax
  8027c6:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  8027c8:	a1 10 a0 80 00       	mov    0x80a010,%eax
  8027cd:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  8027d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8027d3:	5b                   	pop    %ebx
  8027d4:	5e                   	pop    %esi
  8027d5:	5d                   	pop    %ebp
  8027d6:	c3                   	ret    

008027d7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8027d7:	55                   	push   %ebp
  8027d8:	89 e5                	mov    %esp,%ebp
  8027da:	57                   	push   %edi
  8027db:	56                   	push   %esi
  8027dc:	53                   	push   %ebx
  8027dd:	83 ec 0c             	sub    $0xc,%esp
  8027e0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8027e3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8027e6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  8027e9:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8027eb:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8027f0:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  8027f3:	ff 75 14             	pushl  0x14(%ebp)
  8027f6:	53                   	push   %ebx
  8027f7:	56                   	push   %esi
  8027f8:	57                   	push   %edi
  8027f9:	e8 b2 fd ff ff       	call   8025b0 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  8027fe:	83 c4 10             	add    $0x10,%esp
  802801:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802804:	75 07                	jne    80280d <ipc_send+0x36>
			sys_yield();
  802806:	e8 f9 fb ff ff       	call   802404 <sys_yield>
  80280b:	eb e6                	jmp    8027f3 <ipc_send+0x1c>
		} else if (r < 0) {
  80280d:	85 c0                	test   %eax,%eax
  80280f:	79 12                	jns    802823 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  802811:	50                   	push   %eax
  802812:	68 ea 45 80 00       	push   $0x8045ea
  802817:	6a 51                	push   $0x51
  802819:	68 f7 45 80 00       	push   $0x8045f7
  80281e:	e8 9f f1 ff ff       	call   8019c2 <_panic>
		}
	}
}
  802823:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802826:	5b                   	pop    %ebx
  802827:	5e                   	pop    %esi
  802828:	5f                   	pop    %edi
  802829:	5d                   	pop    %ebp
  80282a:	c3                   	ret    

0080282b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80282b:	55                   	push   %ebp
  80282c:	89 e5                	mov    %esp,%ebp
  80282e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802831:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802836:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802839:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80283f:	8b 52 50             	mov    0x50(%edx),%edx
  802842:	39 ca                	cmp    %ecx,%edx
  802844:	75 0d                	jne    802853 <ipc_find_env+0x28>
			return envs[i].env_id;
  802846:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802849:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80284e:	8b 40 48             	mov    0x48(%eax),%eax
  802851:	eb 0f                	jmp    802862 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802853:	83 c0 01             	add    $0x1,%eax
  802856:	3d 00 04 00 00       	cmp    $0x400,%eax
  80285b:	75 d9                	jne    802836 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80285d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802862:	5d                   	pop    %ebp
  802863:	c3                   	ret    

00802864 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  802864:	55                   	push   %ebp
  802865:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802867:	8b 45 08             	mov    0x8(%ebp),%eax
  80286a:	05 00 00 00 30       	add    $0x30000000,%eax
  80286f:	c1 e8 0c             	shr    $0xc,%eax
}
  802872:	5d                   	pop    %ebp
  802873:	c3                   	ret    

00802874 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802874:	55                   	push   %ebp
  802875:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  802877:	8b 45 08             	mov    0x8(%ebp),%eax
  80287a:	05 00 00 00 30       	add    $0x30000000,%eax
  80287f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  802884:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  802889:	5d                   	pop    %ebp
  80288a:	c3                   	ret    

0080288b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80288b:	55                   	push   %ebp
  80288c:	89 e5                	mov    %esp,%ebp
  80288e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802891:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  802896:	89 c2                	mov    %eax,%edx
  802898:	c1 ea 16             	shr    $0x16,%edx
  80289b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8028a2:	f6 c2 01             	test   $0x1,%dl
  8028a5:	74 11                	je     8028b8 <fd_alloc+0x2d>
  8028a7:	89 c2                	mov    %eax,%edx
  8028a9:	c1 ea 0c             	shr    $0xc,%edx
  8028ac:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8028b3:	f6 c2 01             	test   $0x1,%dl
  8028b6:	75 09                	jne    8028c1 <fd_alloc+0x36>
			*fd_store = fd;
  8028b8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8028ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8028bf:	eb 17                	jmp    8028d8 <fd_alloc+0x4d>
  8028c1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8028c6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8028cb:	75 c9                	jne    802896 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8028cd:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8028d3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8028d8:	5d                   	pop    %ebp
  8028d9:	c3                   	ret    

008028da <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8028da:	55                   	push   %ebp
  8028db:	89 e5                	mov    %esp,%ebp
  8028dd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8028e0:	83 f8 1f             	cmp    $0x1f,%eax
  8028e3:	77 36                	ja     80291b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8028e5:	c1 e0 0c             	shl    $0xc,%eax
  8028e8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8028ed:	89 c2                	mov    %eax,%edx
  8028ef:	c1 ea 16             	shr    $0x16,%edx
  8028f2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8028f9:	f6 c2 01             	test   $0x1,%dl
  8028fc:	74 24                	je     802922 <fd_lookup+0x48>
  8028fe:	89 c2                	mov    %eax,%edx
  802900:	c1 ea 0c             	shr    $0xc,%edx
  802903:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80290a:	f6 c2 01             	test   $0x1,%dl
  80290d:	74 1a                	je     802929 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80290f:	8b 55 0c             	mov    0xc(%ebp),%edx
  802912:	89 02                	mov    %eax,(%edx)
	return 0;
  802914:	b8 00 00 00 00       	mov    $0x0,%eax
  802919:	eb 13                	jmp    80292e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80291b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802920:	eb 0c                	jmp    80292e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802922:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802927:	eb 05                	jmp    80292e <fd_lookup+0x54>
  802929:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80292e:	5d                   	pop    %ebp
  80292f:	c3                   	ret    

00802930 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802930:	55                   	push   %ebp
  802931:	89 e5                	mov    %esp,%ebp
  802933:	83 ec 08             	sub    $0x8,%esp
  802936:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802939:	ba 84 46 80 00       	mov    $0x804684,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80293e:	eb 13                	jmp    802953 <dev_lookup+0x23>
  802940:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  802943:	39 08                	cmp    %ecx,(%eax)
  802945:	75 0c                	jne    802953 <dev_lookup+0x23>
			*dev = devtab[i];
  802947:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80294a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80294c:	b8 00 00 00 00       	mov    $0x0,%eax
  802951:	eb 2e                	jmp    802981 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  802953:	8b 02                	mov    (%edx),%eax
  802955:	85 c0                	test   %eax,%eax
  802957:	75 e7                	jne    802940 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  802959:	a1 10 a0 80 00       	mov    0x80a010,%eax
  80295e:	8b 40 48             	mov    0x48(%eax),%eax
  802961:	83 ec 04             	sub    $0x4,%esp
  802964:	51                   	push   %ecx
  802965:	50                   	push   %eax
  802966:	68 04 46 80 00       	push   $0x804604
  80296b:	e8 2b f1 ff ff       	call   801a9b <cprintf>
	*dev = 0;
  802970:	8b 45 0c             	mov    0xc(%ebp),%eax
  802973:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  802979:	83 c4 10             	add    $0x10,%esp
  80297c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802981:	c9                   	leave  
  802982:	c3                   	ret    

00802983 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  802983:	55                   	push   %ebp
  802984:	89 e5                	mov    %esp,%ebp
  802986:	56                   	push   %esi
  802987:	53                   	push   %ebx
  802988:	83 ec 10             	sub    $0x10,%esp
  80298b:	8b 75 08             	mov    0x8(%ebp),%esi
  80298e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802991:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802994:	50                   	push   %eax
  802995:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80299b:	c1 e8 0c             	shr    $0xc,%eax
  80299e:	50                   	push   %eax
  80299f:	e8 36 ff ff ff       	call   8028da <fd_lookup>
  8029a4:	83 c4 08             	add    $0x8,%esp
  8029a7:	85 c0                	test   %eax,%eax
  8029a9:	78 05                	js     8029b0 <fd_close+0x2d>
	    || fd != fd2)
  8029ab:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8029ae:	74 0c                	je     8029bc <fd_close+0x39>
		return (must_exist ? r : 0);
  8029b0:	84 db                	test   %bl,%bl
  8029b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8029b7:	0f 44 c2             	cmove  %edx,%eax
  8029ba:	eb 41                	jmp    8029fd <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8029bc:	83 ec 08             	sub    $0x8,%esp
  8029bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8029c2:	50                   	push   %eax
  8029c3:	ff 36                	pushl  (%esi)
  8029c5:	e8 66 ff ff ff       	call   802930 <dev_lookup>
  8029ca:	89 c3                	mov    %eax,%ebx
  8029cc:	83 c4 10             	add    $0x10,%esp
  8029cf:	85 c0                	test   %eax,%eax
  8029d1:	78 1a                	js     8029ed <fd_close+0x6a>
		if (dev->dev_close)
  8029d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8029d6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8029d9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8029de:	85 c0                	test   %eax,%eax
  8029e0:	74 0b                	je     8029ed <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8029e2:	83 ec 0c             	sub    $0xc,%esp
  8029e5:	56                   	push   %esi
  8029e6:	ff d0                	call   *%eax
  8029e8:	89 c3                	mov    %eax,%ebx
  8029ea:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8029ed:	83 ec 08             	sub    $0x8,%esp
  8029f0:	56                   	push   %esi
  8029f1:	6a 00                	push   $0x0
  8029f3:	e8 b0 fa ff ff       	call   8024a8 <sys_page_unmap>
	return r;
  8029f8:	83 c4 10             	add    $0x10,%esp
  8029fb:	89 d8                	mov    %ebx,%eax
}
  8029fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802a00:	5b                   	pop    %ebx
  802a01:	5e                   	pop    %esi
  802a02:	5d                   	pop    %ebp
  802a03:	c3                   	ret    

00802a04 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  802a04:	55                   	push   %ebp
  802a05:	89 e5                	mov    %esp,%ebp
  802a07:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802a0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802a0d:	50                   	push   %eax
  802a0e:	ff 75 08             	pushl  0x8(%ebp)
  802a11:	e8 c4 fe ff ff       	call   8028da <fd_lookup>
  802a16:	83 c4 08             	add    $0x8,%esp
  802a19:	85 c0                	test   %eax,%eax
  802a1b:	78 10                	js     802a2d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  802a1d:	83 ec 08             	sub    $0x8,%esp
  802a20:	6a 01                	push   $0x1
  802a22:	ff 75 f4             	pushl  -0xc(%ebp)
  802a25:	e8 59 ff ff ff       	call   802983 <fd_close>
  802a2a:	83 c4 10             	add    $0x10,%esp
}
  802a2d:	c9                   	leave  
  802a2e:	c3                   	ret    

00802a2f <close_all>:

void
close_all(void)
{
  802a2f:	55                   	push   %ebp
  802a30:	89 e5                	mov    %esp,%ebp
  802a32:	53                   	push   %ebx
  802a33:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802a36:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802a3b:	83 ec 0c             	sub    $0xc,%esp
  802a3e:	53                   	push   %ebx
  802a3f:	e8 c0 ff ff ff       	call   802a04 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  802a44:	83 c3 01             	add    $0x1,%ebx
  802a47:	83 c4 10             	add    $0x10,%esp
  802a4a:	83 fb 20             	cmp    $0x20,%ebx
  802a4d:	75 ec                	jne    802a3b <close_all+0xc>
		close(i);
}
  802a4f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802a52:	c9                   	leave  
  802a53:	c3                   	ret    

00802a54 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802a54:	55                   	push   %ebp
  802a55:	89 e5                	mov    %esp,%ebp
  802a57:	57                   	push   %edi
  802a58:	56                   	push   %esi
  802a59:	53                   	push   %ebx
  802a5a:	83 ec 2c             	sub    $0x2c,%esp
  802a5d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802a60:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802a63:	50                   	push   %eax
  802a64:	ff 75 08             	pushl  0x8(%ebp)
  802a67:	e8 6e fe ff ff       	call   8028da <fd_lookup>
  802a6c:	83 c4 08             	add    $0x8,%esp
  802a6f:	85 c0                	test   %eax,%eax
  802a71:	0f 88 c1 00 00 00    	js     802b38 <dup+0xe4>
		return r;
	close(newfdnum);
  802a77:	83 ec 0c             	sub    $0xc,%esp
  802a7a:	56                   	push   %esi
  802a7b:	e8 84 ff ff ff       	call   802a04 <close>

	newfd = INDEX2FD(newfdnum);
  802a80:	89 f3                	mov    %esi,%ebx
  802a82:	c1 e3 0c             	shl    $0xc,%ebx
  802a85:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  802a8b:	83 c4 04             	add    $0x4,%esp
  802a8e:	ff 75 e4             	pushl  -0x1c(%ebp)
  802a91:	e8 de fd ff ff       	call   802874 <fd2data>
  802a96:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  802a98:	89 1c 24             	mov    %ebx,(%esp)
  802a9b:	e8 d4 fd ff ff       	call   802874 <fd2data>
  802aa0:	83 c4 10             	add    $0x10,%esp
  802aa3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802aa6:	89 f8                	mov    %edi,%eax
  802aa8:	c1 e8 16             	shr    $0x16,%eax
  802aab:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802ab2:	a8 01                	test   $0x1,%al
  802ab4:	74 37                	je     802aed <dup+0x99>
  802ab6:	89 f8                	mov    %edi,%eax
  802ab8:	c1 e8 0c             	shr    $0xc,%eax
  802abb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802ac2:	f6 c2 01             	test   $0x1,%dl
  802ac5:	74 26                	je     802aed <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802ac7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802ace:	83 ec 0c             	sub    $0xc,%esp
  802ad1:	25 07 0e 00 00       	and    $0xe07,%eax
  802ad6:	50                   	push   %eax
  802ad7:	ff 75 d4             	pushl  -0x2c(%ebp)
  802ada:	6a 00                	push   $0x0
  802adc:	57                   	push   %edi
  802add:	6a 00                	push   $0x0
  802adf:	e8 82 f9 ff ff       	call   802466 <sys_page_map>
  802ae4:	89 c7                	mov    %eax,%edi
  802ae6:	83 c4 20             	add    $0x20,%esp
  802ae9:	85 c0                	test   %eax,%eax
  802aeb:	78 2e                	js     802b1b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802aed:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802af0:	89 d0                	mov    %edx,%eax
  802af2:	c1 e8 0c             	shr    $0xc,%eax
  802af5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802afc:	83 ec 0c             	sub    $0xc,%esp
  802aff:	25 07 0e 00 00       	and    $0xe07,%eax
  802b04:	50                   	push   %eax
  802b05:	53                   	push   %ebx
  802b06:	6a 00                	push   $0x0
  802b08:	52                   	push   %edx
  802b09:	6a 00                	push   $0x0
  802b0b:	e8 56 f9 ff ff       	call   802466 <sys_page_map>
  802b10:	89 c7                	mov    %eax,%edi
  802b12:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  802b15:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802b17:	85 ff                	test   %edi,%edi
  802b19:	79 1d                	jns    802b38 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802b1b:	83 ec 08             	sub    $0x8,%esp
  802b1e:	53                   	push   %ebx
  802b1f:	6a 00                	push   $0x0
  802b21:	e8 82 f9 ff ff       	call   8024a8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802b26:	83 c4 08             	add    $0x8,%esp
  802b29:	ff 75 d4             	pushl  -0x2c(%ebp)
  802b2c:	6a 00                	push   $0x0
  802b2e:	e8 75 f9 ff ff       	call   8024a8 <sys_page_unmap>
	return r;
  802b33:	83 c4 10             	add    $0x10,%esp
  802b36:	89 f8                	mov    %edi,%eax
}
  802b38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b3b:	5b                   	pop    %ebx
  802b3c:	5e                   	pop    %esi
  802b3d:	5f                   	pop    %edi
  802b3e:	5d                   	pop    %ebp
  802b3f:	c3                   	ret    

00802b40 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802b40:	55                   	push   %ebp
  802b41:	89 e5                	mov    %esp,%ebp
  802b43:	53                   	push   %ebx
  802b44:	83 ec 14             	sub    $0x14,%esp
  802b47:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802b4a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802b4d:	50                   	push   %eax
  802b4e:	53                   	push   %ebx
  802b4f:	e8 86 fd ff ff       	call   8028da <fd_lookup>
  802b54:	83 c4 08             	add    $0x8,%esp
  802b57:	89 c2                	mov    %eax,%edx
  802b59:	85 c0                	test   %eax,%eax
  802b5b:	78 6d                	js     802bca <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802b5d:	83 ec 08             	sub    $0x8,%esp
  802b60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802b63:	50                   	push   %eax
  802b64:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802b67:	ff 30                	pushl  (%eax)
  802b69:	e8 c2 fd ff ff       	call   802930 <dev_lookup>
  802b6e:	83 c4 10             	add    $0x10,%esp
  802b71:	85 c0                	test   %eax,%eax
  802b73:	78 4c                	js     802bc1 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802b75:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802b78:	8b 42 08             	mov    0x8(%edx),%eax
  802b7b:	83 e0 03             	and    $0x3,%eax
  802b7e:	83 f8 01             	cmp    $0x1,%eax
  802b81:	75 21                	jne    802ba4 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802b83:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802b88:	8b 40 48             	mov    0x48(%eax),%eax
  802b8b:	83 ec 04             	sub    $0x4,%esp
  802b8e:	53                   	push   %ebx
  802b8f:	50                   	push   %eax
  802b90:	68 48 46 80 00       	push   $0x804648
  802b95:	e8 01 ef ff ff       	call   801a9b <cprintf>
		return -E_INVAL;
  802b9a:	83 c4 10             	add    $0x10,%esp
  802b9d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802ba2:	eb 26                	jmp    802bca <read+0x8a>
	}
	if (!dev->dev_read)
  802ba4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802ba7:	8b 40 08             	mov    0x8(%eax),%eax
  802baa:	85 c0                	test   %eax,%eax
  802bac:	74 17                	je     802bc5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802bae:	83 ec 04             	sub    $0x4,%esp
  802bb1:	ff 75 10             	pushl  0x10(%ebp)
  802bb4:	ff 75 0c             	pushl  0xc(%ebp)
  802bb7:	52                   	push   %edx
  802bb8:	ff d0                	call   *%eax
  802bba:	89 c2                	mov    %eax,%edx
  802bbc:	83 c4 10             	add    $0x10,%esp
  802bbf:	eb 09                	jmp    802bca <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802bc1:	89 c2                	mov    %eax,%edx
  802bc3:	eb 05                	jmp    802bca <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802bc5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  802bca:	89 d0                	mov    %edx,%eax
  802bcc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802bcf:	c9                   	leave  
  802bd0:	c3                   	ret    

00802bd1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802bd1:	55                   	push   %ebp
  802bd2:	89 e5                	mov    %esp,%ebp
  802bd4:	57                   	push   %edi
  802bd5:	56                   	push   %esi
  802bd6:	53                   	push   %ebx
  802bd7:	83 ec 0c             	sub    $0xc,%esp
  802bda:	8b 7d 08             	mov    0x8(%ebp),%edi
  802bdd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802be0:	bb 00 00 00 00       	mov    $0x0,%ebx
  802be5:	eb 21                	jmp    802c08 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802be7:	83 ec 04             	sub    $0x4,%esp
  802bea:	89 f0                	mov    %esi,%eax
  802bec:	29 d8                	sub    %ebx,%eax
  802bee:	50                   	push   %eax
  802bef:	89 d8                	mov    %ebx,%eax
  802bf1:	03 45 0c             	add    0xc(%ebp),%eax
  802bf4:	50                   	push   %eax
  802bf5:	57                   	push   %edi
  802bf6:	e8 45 ff ff ff       	call   802b40 <read>
		if (m < 0)
  802bfb:	83 c4 10             	add    $0x10,%esp
  802bfe:	85 c0                	test   %eax,%eax
  802c00:	78 10                	js     802c12 <readn+0x41>
			return m;
		if (m == 0)
  802c02:	85 c0                	test   %eax,%eax
  802c04:	74 0a                	je     802c10 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802c06:	01 c3                	add    %eax,%ebx
  802c08:	39 f3                	cmp    %esi,%ebx
  802c0a:	72 db                	jb     802be7 <readn+0x16>
  802c0c:	89 d8                	mov    %ebx,%eax
  802c0e:	eb 02                	jmp    802c12 <readn+0x41>
  802c10:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  802c12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c15:	5b                   	pop    %ebx
  802c16:	5e                   	pop    %esi
  802c17:	5f                   	pop    %edi
  802c18:	5d                   	pop    %ebp
  802c19:	c3                   	ret    

00802c1a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802c1a:	55                   	push   %ebp
  802c1b:	89 e5                	mov    %esp,%ebp
  802c1d:	53                   	push   %ebx
  802c1e:	83 ec 14             	sub    $0x14,%esp
  802c21:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802c24:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802c27:	50                   	push   %eax
  802c28:	53                   	push   %ebx
  802c29:	e8 ac fc ff ff       	call   8028da <fd_lookup>
  802c2e:	83 c4 08             	add    $0x8,%esp
  802c31:	89 c2                	mov    %eax,%edx
  802c33:	85 c0                	test   %eax,%eax
  802c35:	78 68                	js     802c9f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c37:	83 ec 08             	sub    $0x8,%esp
  802c3a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c3d:	50                   	push   %eax
  802c3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c41:	ff 30                	pushl  (%eax)
  802c43:	e8 e8 fc ff ff       	call   802930 <dev_lookup>
  802c48:	83 c4 10             	add    $0x10,%esp
  802c4b:	85 c0                	test   %eax,%eax
  802c4d:	78 47                	js     802c96 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802c4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c52:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802c56:	75 21                	jne    802c79 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802c58:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802c5d:	8b 40 48             	mov    0x48(%eax),%eax
  802c60:	83 ec 04             	sub    $0x4,%esp
  802c63:	53                   	push   %ebx
  802c64:	50                   	push   %eax
  802c65:	68 64 46 80 00       	push   $0x804664
  802c6a:	e8 2c ee ff ff       	call   801a9b <cprintf>
		return -E_INVAL;
  802c6f:	83 c4 10             	add    $0x10,%esp
  802c72:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802c77:	eb 26                	jmp    802c9f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802c79:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802c7c:	8b 52 0c             	mov    0xc(%edx),%edx
  802c7f:	85 d2                	test   %edx,%edx
  802c81:	74 17                	je     802c9a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802c83:	83 ec 04             	sub    $0x4,%esp
  802c86:	ff 75 10             	pushl  0x10(%ebp)
  802c89:	ff 75 0c             	pushl  0xc(%ebp)
  802c8c:	50                   	push   %eax
  802c8d:	ff d2                	call   *%edx
  802c8f:	89 c2                	mov    %eax,%edx
  802c91:	83 c4 10             	add    $0x10,%esp
  802c94:	eb 09                	jmp    802c9f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c96:	89 c2                	mov    %eax,%edx
  802c98:	eb 05                	jmp    802c9f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802c9a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802c9f:	89 d0                	mov    %edx,%eax
  802ca1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802ca4:	c9                   	leave  
  802ca5:	c3                   	ret    

00802ca6 <seek>:

int
seek(int fdnum, off_t offset)
{
  802ca6:	55                   	push   %ebp
  802ca7:	89 e5                	mov    %esp,%ebp
  802ca9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802cac:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802caf:	50                   	push   %eax
  802cb0:	ff 75 08             	pushl  0x8(%ebp)
  802cb3:	e8 22 fc ff ff       	call   8028da <fd_lookup>
  802cb8:	83 c4 08             	add    $0x8,%esp
  802cbb:	85 c0                	test   %eax,%eax
  802cbd:	78 0e                	js     802ccd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802cbf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802cc2:	8b 55 0c             	mov    0xc(%ebp),%edx
  802cc5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802cc8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802ccd:	c9                   	leave  
  802cce:	c3                   	ret    

00802ccf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802ccf:	55                   	push   %ebp
  802cd0:	89 e5                	mov    %esp,%ebp
  802cd2:	53                   	push   %ebx
  802cd3:	83 ec 14             	sub    $0x14,%esp
  802cd6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802cd9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802cdc:	50                   	push   %eax
  802cdd:	53                   	push   %ebx
  802cde:	e8 f7 fb ff ff       	call   8028da <fd_lookup>
  802ce3:	83 c4 08             	add    $0x8,%esp
  802ce6:	89 c2                	mov    %eax,%edx
  802ce8:	85 c0                	test   %eax,%eax
  802cea:	78 65                	js     802d51 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802cec:	83 ec 08             	sub    $0x8,%esp
  802cef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802cf2:	50                   	push   %eax
  802cf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802cf6:	ff 30                	pushl  (%eax)
  802cf8:	e8 33 fc ff ff       	call   802930 <dev_lookup>
  802cfd:	83 c4 10             	add    $0x10,%esp
  802d00:	85 c0                	test   %eax,%eax
  802d02:	78 44                	js     802d48 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802d04:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d07:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802d0b:	75 21                	jne    802d2e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802d0d:	a1 10 a0 80 00       	mov    0x80a010,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802d12:	8b 40 48             	mov    0x48(%eax),%eax
  802d15:	83 ec 04             	sub    $0x4,%esp
  802d18:	53                   	push   %ebx
  802d19:	50                   	push   %eax
  802d1a:	68 24 46 80 00       	push   $0x804624
  802d1f:	e8 77 ed ff ff       	call   801a9b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802d24:	83 c4 10             	add    $0x10,%esp
  802d27:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802d2c:	eb 23                	jmp    802d51 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802d2e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802d31:	8b 52 18             	mov    0x18(%edx),%edx
  802d34:	85 d2                	test   %edx,%edx
  802d36:	74 14                	je     802d4c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802d38:	83 ec 08             	sub    $0x8,%esp
  802d3b:	ff 75 0c             	pushl  0xc(%ebp)
  802d3e:	50                   	push   %eax
  802d3f:	ff d2                	call   *%edx
  802d41:	89 c2                	mov    %eax,%edx
  802d43:	83 c4 10             	add    $0x10,%esp
  802d46:	eb 09                	jmp    802d51 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d48:	89 c2                	mov    %eax,%edx
  802d4a:	eb 05                	jmp    802d51 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802d4c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802d51:	89 d0                	mov    %edx,%eax
  802d53:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802d56:	c9                   	leave  
  802d57:	c3                   	ret    

00802d58 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802d58:	55                   	push   %ebp
  802d59:	89 e5                	mov    %esp,%ebp
  802d5b:	53                   	push   %ebx
  802d5c:	83 ec 14             	sub    $0x14,%esp
  802d5f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802d62:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d65:	50                   	push   %eax
  802d66:	ff 75 08             	pushl  0x8(%ebp)
  802d69:	e8 6c fb ff ff       	call   8028da <fd_lookup>
  802d6e:	83 c4 08             	add    $0x8,%esp
  802d71:	89 c2                	mov    %eax,%edx
  802d73:	85 c0                	test   %eax,%eax
  802d75:	78 58                	js     802dcf <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d77:	83 ec 08             	sub    $0x8,%esp
  802d7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d7d:	50                   	push   %eax
  802d7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d81:	ff 30                	pushl  (%eax)
  802d83:	e8 a8 fb ff ff       	call   802930 <dev_lookup>
  802d88:	83 c4 10             	add    $0x10,%esp
  802d8b:	85 c0                	test   %eax,%eax
  802d8d:	78 37                	js     802dc6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802d8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d92:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802d96:	74 32                	je     802dca <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802d98:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802d9b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802da2:	00 00 00 
	stat->st_isdir = 0;
  802da5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802dac:	00 00 00 
	stat->st_dev = dev;
  802daf:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802db5:	83 ec 08             	sub    $0x8,%esp
  802db8:	53                   	push   %ebx
  802db9:	ff 75 f0             	pushl  -0x10(%ebp)
  802dbc:	ff 50 14             	call   *0x14(%eax)
  802dbf:	89 c2                	mov    %eax,%edx
  802dc1:	83 c4 10             	add    $0x10,%esp
  802dc4:	eb 09                	jmp    802dcf <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802dc6:	89 c2                	mov    %eax,%edx
  802dc8:	eb 05                	jmp    802dcf <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802dca:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802dcf:	89 d0                	mov    %edx,%eax
  802dd1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802dd4:	c9                   	leave  
  802dd5:	c3                   	ret    

00802dd6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802dd6:	55                   	push   %ebp
  802dd7:	89 e5                	mov    %esp,%ebp
  802dd9:	56                   	push   %esi
  802dda:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802ddb:	83 ec 08             	sub    $0x8,%esp
  802dde:	6a 00                	push   $0x0
  802de0:	ff 75 08             	pushl  0x8(%ebp)
  802de3:	e8 0c 02 00 00       	call   802ff4 <open>
  802de8:	89 c3                	mov    %eax,%ebx
  802dea:	83 c4 10             	add    $0x10,%esp
  802ded:	85 c0                	test   %eax,%eax
  802def:	78 1b                	js     802e0c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802df1:	83 ec 08             	sub    $0x8,%esp
  802df4:	ff 75 0c             	pushl  0xc(%ebp)
  802df7:	50                   	push   %eax
  802df8:	e8 5b ff ff ff       	call   802d58 <fstat>
  802dfd:	89 c6                	mov    %eax,%esi
	close(fd);
  802dff:	89 1c 24             	mov    %ebx,(%esp)
  802e02:	e8 fd fb ff ff       	call   802a04 <close>
	return r;
  802e07:	83 c4 10             	add    $0x10,%esp
  802e0a:	89 f0                	mov    %esi,%eax
}
  802e0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802e0f:	5b                   	pop    %ebx
  802e10:	5e                   	pop    %esi
  802e11:	5d                   	pop    %ebp
  802e12:	c3                   	ret    

00802e13 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802e13:	55                   	push   %ebp
  802e14:	89 e5                	mov    %esp,%ebp
  802e16:	56                   	push   %esi
  802e17:	53                   	push   %ebx
  802e18:	89 c6                	mov    %eax,%esi
  802e1a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802e1c:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  802e23:	75 12                	jne    802e37 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802e25:	83 ec 0c             	sub    $0xc,%esp
  802e28:	6a 01                	push   $0x1
  802e2a:	e8 fc f9 ff ff       	call   80282b <ipc_find_env>
  802e2f:	a3 00 a0 80 00       	mov    %eax,0x80a000
  802e34:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802e37:	6a 07                	push   $0x7
  802e39:	68 00 b0 80 00       	push   $0x80b000
  802e3e:	56                   	push   %esi
  802e3f:	ff 35 00 a0 80 00    	pushl  0x80a000
  802e45:	e8 8d f9 ff ff       	call   8027d7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802e4a:	83 c4 0c             	add    $0xc,%esp
  802e4d:	6a 00                	push   $0x0
  802e4f:	53                   	push   %ebx
  802e50:	6a 00                	push   $0x0
  802e52:	e8 17 f9 ff ff       	call   80276e <ipc_recv>
}
  802e57:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802e5a:	5b                   	pop    %ebx
  802e5b:	5e                   	pop    %esi
  802e5c:	5d                   	pop    %ebp
  802e5d:	c3                   	ret    

00802e5e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802e5e:	55                   	push   %ebp
  802e5f:	89 e5                	mov    %esp,%ebp
  802e61:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802e64:	8b 45 08             	mov    0x8(%ebp),%eax
  802e67:	8b 40 0c             	mov    0xc(%eax),%eax
  802e6a:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  802e6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e72:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802e77:	ba 00 00 00 00       	mov    $0x0,%edx
  802e7c:	b8 02 00 00 00       	mov    $0x2,%eax
  802e81:	e8 8d ff ff ff       	call   802e13 <fsipc>
}
  802e86:	c9                   	leave  
  802e87:	c3                   	ret    

00802e88 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802e88:	55                   	push   %ebp
  802e89:	89 e5                	mov    %esp,%ebp
  802e8b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802e8e:	8b 45 08             	mov    0x8(%ebp),%eax
  802e91:	8b 40 0c             	mov    0xc(%eax),%eax
  802e94:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  802e99:	ba 00 00 00 00       	mov    $0x0,%edx
  802e9e:	b8 06 00 00 00       	mov    $0x6,%eax
  802ea3:	e8 6b ff ff ff       	call   802e13 <fsipc>
}
  802ea8:	c9                   	leave  
  802ea9:	c3                   	ret    

00802eaa <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802eaa:	55                   	push   %ebp
  802eab:	89 e5                	mov    %esp,%ebp
  802ead:	53                   	push   %ebx
  802eae:	83 ec 04             	sub    $0x4,%esp
  802eb1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802eb4:	8b 45 08             	mov    0x8(%ebp),%eax
  802eb7:	8b 40 0c             	mov    0xc(%eax),%eax
  802eba:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802ebf:	ba 00 00 00 00       	mov    $0x0,%edx
  802ec4:	b8 05 00 00 00       	mov    $0x5,%eax
  802ec9:	e8 45 ff ff ff       	call   802e13 <fsipc>
  802ece:	85 c0                	test   %eax,%eax
  802ed0:	78 2c                	js     802efe <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802ed2:	83 ec 08             	sub    $0x8,%esp
  802ed5:	68 00 b0 80 00       	push   $0x80b000
  802eda:	53                   	push   %ebx
  802edb:	e8 40 f1 ff ff       	call   802020 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802ee0:	a1 80 b0 80 00       	mov    0x80b080,%eax
  802ee5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802eeb:	a1 84 b0 80 00       	mov    0x80b084,%eax
  802ef0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802ef6:	83 c4 10             	add    $0x10,%esp
  802ef9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802efe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f01:	c9                   	leave  
  802f02:	c3                   	ret    

00802f03 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802f03:	55                   	push   %ebp
  802f04:	89 e5                	mov    %esp,%ebp
  802f06:	53                   	push   %ebx
  802f07:	83 ec 08             	sub    $0x8,%esp
  802f0a:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here

	// Build up arguments of the write request
	// The file to write is stored in the request req_fileid
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  802f0d:	8b 55 08             	mov    0x8(%ebp),%edx
  802f10:	8b 52 0c             	mov    0xc(%edx),%edx
  802f13:	89 15 00 b0 80 00    	mov    %edx,0x80b000
  802f19:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  802f1e:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  802f23:	0f 46 d8             	cmovbe %eax,%ebx
	// The size is capped to the size of the request buffer
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  802f26:	89 1d 04 b0 80 00    	mov    %ebx,0x80b004
	// The data to write is stored in the request buffer
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  802f2c:	53                   	push   %ebx
  802f2d:	ff 75 0c             	pushl  0xc(%ebp)
  802f30:	68 08 b0 80 00       	push   $0x80b008
  802f35:	e8 78 f2 ff ff       	call   8021b2 <memmove>

	// Send request via fsipc
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) // Error occurred
  802f3a:	ba 00 00 00 00       	mov    $0x0,%edx
  802f3f:	b8 04 00 00 00       	mov    $0x4,%eax
  802f44:	e8 ca fe ff ff       	call   802e13 <fsipc>
  802f49:	83 c4 10             	add    $0x10,%esp
  802f4c:	85 c0                	test   %eax,%eax
  802f4e:	78 1d                	js     802f6d <devfile_write+0x6a>
		return r;
	assert(r <= n_real); // Number of bytes written should be <= n_real
  802f50:	39 d8                	cmp    %ebx,%eax
  802f52:	76 19                	jbe    802f6d <devfile_write+0x6a>
  802f54:	68 98 46 80 00       	push   $0x804698
  802f59:	68 fd 3c 80 00       	push   $0x803cfd
  802f5e:	68 a5 00 00 00       	push   $0xa5
  802f63:	68 a4 46 80 00       	push   $0x8046a4
  802f68:	e8 55 ea ff ff       	call   8019c2 <_panic>
	return r;
}
  802f6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f70:	c9                   	leave  
  802f71:	c3                   	ret    

00802f72 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802f72:	55                   	push   %ebp
  802f73:	89 e5                	mov    %esp,%ebp
  802f75:	56                   	push   %esi
  802f76:	53                   	push   %ebx
  802f77:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802f7a:	8b 45 08             	mov    0x8(%ebp),%eax
  802f7d:	8b 40 0c             	mov    0xc(%eax),%eax
  802f80:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  802f85:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802f8b:	ba 00 00 00 00       	mov    $0x0,%edx
  802f90:	b8 03 00 00 00       	mov    $0x3,%eax
  802f95:	e8 79 fe ff ff       	call   802e13 <fsipc>
  802f9a:	89 c3                	mov    %eax,%ebx
  802f9c:	85 c0                	test   %eax,%eax
  802f9e:	78 4b                	js     802feb <devfile_read+0x79>
		return r;
	assert(r <= n);
  802fa0:	39 c6                	cmp    %eax,%esi
  802fa2:	73 16                	jae    802fba <devfile_read+0x48>
  802fa4:	68 af 46 80 00       	push   $0x8046af
  802fa9:	68 fd 3c 80 00       	push   $0x803cfd
  802fae:	6a 7c                	push   $0x7c
  802fb0:	68 a4 46 80 00       	push   $0x8046a4
  802fb5:	e8 08 ea ff ff       	call   8019c2 <_panic>
	assert(r <= PGSIZE);
  802fba:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802fbf:	7e 16                	jle    802fd7 <devfile_read+0x65>
  802fc1:	68 b6 46 80 00       	push   $0x8046b6
  802fc6:	68 fd 3c 80 00       	push   $0x803cfd
  802fcb:	6a 7d                	push   $0x7d
  802fcd:	68 a4 46 80 00       	push   $0x8046a4
  802fd2:	e8 eb e9 ff ff       	call   8019c2 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802fd7:	83 ec 04             	sub    $0x4,%esp
  802fda:	50                   	push   %eax
  802fdb:	68 00 b0 80 00       	push   $0x80b000
  802fe0:	ff 75 0c             	pushl  0xc(%ebp)
  802fe3:	e8 ca f1 ff ff       	call   8021b2 <memmove>
	return r;
  802fe8:	83 c4 10             	add    $0x10,%esp
}
  802feb:	89 d8                	mov    %ebx,%eax
  802fed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ff0:	5b                   	pop    %ebx
  802ff1:	5e                   	pop    %esi
  802ff2:	5d                   	pop    %ebp
  802ff3:	c3                   	ret    

00802ff4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802ff4:	55                   	push   %ebp
  802ff5:	89 e5                	mov    %esp,%ebp
  802ff7:	53                   	push   %ebx
  802ff8:	83 ec 20             	sub    $0x20,%esp
  802ffb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802ffe:	53                   	push   %ebx
  802fff:	e8 e3 ef ff ff       	call   801fe7 <strlen>
  803004:	83 c4 10             	add    $0x10,%esp
  803007:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80300c:	7f 67                	jg     803075 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80300e:	83 ec 0c             	sub    $0xc,%esp
  803011:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803014:	50                   	push   %eax
  803015:	e8 71 f8 ff ff       	call   80288b <fd_alloc>
  80301a:	83 c4 10             	add    $0x10,%esp
		return r;
  80301d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80301f:	85 c0                	test   %eax,%eax
  803021:	78 57                	js     80307a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  803023:	83 ec 08             	sub    $0x8,%esp
  803026:	53                   	push   %ebx
  803027:	68 00 b0 80 00       	push   $0x80b000
  80302c:	e8 ef ef ff ff       	call   802020 <strcpy>
	fsipcbuf.open.req_omode = mode;
  803031:	8b 45 0c             	mov    0xc(%ebp),%eax
  803034:	a3 00 b4 80 00       	mov    %eax,0x80b400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  803039:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80303c:	b8 01 00 00 00       	mov    $0x1,%eax
  803041:	e8 cd fd ff ff       	call   802e13 <fsipc>
  803046:	89 c3                	mov    %eax,%ebx
  803048:	83 c4 10             	add    $0x10,%esp
  80304b:	85 c0                	test   %eax,%eax
  80304d:	79 14                	jns    803063 <open+0x6f>
		fd_close(fd, 0);
  80304f:	83 ec 08             	sub    $0x8,%esp
  803052:	6a 00                	push   $0x0
  803054:	ff 75 f4             	pushl  -0xc(%ebp)
  803057:	e8 27 f9 ff ff       	call   802983 <fd_close>
		return r;
  80305c:	83 c4 10             	add    $0x10,%esp
  80305f:	89 da                	mov    %ebx,%edx
  803061:	eb 17                	jmp    80307a <open+0x86>
	}

	return fd2num(fd);
  803063:	83 ec 0c             	sub    $0xc,%esp
  803066:	ff 75 f4             	pushl  -0xc(%ebp)
  803069:	e8 f6 f7 ff ff       	call   802864 <fd2num>
  80306e:	89 c2                	mov    %eax,%edx
  803070:	83 c4 10             	add    $0x10,%esp
  803073:	eb 05                	jmp    80307a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  803075:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80307a:	89 d0                	mov    %edx,%eax
  80307c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80307f:	c9                   	leave  
  803080:	c3                   	ret    

00803081 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  803081:	55                   	push   %ebp
  803082:	89 e5                	mov    %esp,%ebp
  803084:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  803087:	ba 00 00 00 00       	mov    $0x0,%edx
  80308c:	b8 08 00 00 00       	mov    $0x8,%eax
  803091:	e8 7d fd ff ff       	call   802e13 <fsipc>
}
  803096:	c9                   	leave  
  803097:	c3                   	ret    

00803098 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803098:	55                   	push   %ebp
  803099:	89 e5                	mov    %esp,%ebp
  80309b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80309e:	89 d0                	mov    %edx,%eax
  8030a0:	c1 e8 16             	shr    $0x16,%eax
  8030a3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8030aa:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8030af:	f6 c1 01             	test   $0x1,%cl
  8030b2:	74 1d                	je     8030d1 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8030b4:	c1 ea 0c             	shr    $0xc,%edx
  8030b7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8030be:	f6 c2 01             	test   $0x1,%dl
  8030c1:	74 0e                	je     8030d1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8030c3:	c1 ea 0c             	shr    $0xc,%edx
  8030c6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8030cd:	ef 
  8030ce:	0f b7 c0             	movzwl %ax,%eax
}
  8030d1:	5d                   	pop    %ebp
  8030d2:	c3                   	ret    

008030d3 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8030d3:	55                   	push   %ebp
  8030d4:	89 e5                	mov    %esp,%ebp
  8030d6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8030d9:	68 c2 46 80 00       	push   $0x8046c2
  8030de:	ff 75 0c             	pushl  0xc(%ebp)
  8030e1:	e8 3a ef ff ff       	call   802020 <strcpy>
	return 0;
}
  8030e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8030eb:	c9                   	leave  
  8030ec:	c3                   	ret    

008030ed <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8030ed:	55                   	push   %ebp
  8030ee:	89 e5                	mov    %esp,%ebp
  8030f0:	53                   	push   %ebx
  8030f1:	83 ec 10             	sub    $0x10,%esp
  8030f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8030f7:	53                   	push   %ebx
  8030f8:	e8 9b ff ff ff       	call   803098 <pageref>
  8030fd:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  803100:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  803105:	83 f8 01             	cmp    $0x1,%eax
  803108:	75 10                	jne    80311a <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80310a:	83 ec 0c             	sub    $0xc,%esp
  80310d:	ff 73 0c             	pushl  0xc(%ebx)
  803110:	e8 c0 02 00 00       	call   8033d5 <nsipc_close>
  803115:	89 c2                	mov    %eax,%edx
  803117:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80311a:	89 d0                	mov    %edx,%eax
  80311c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80311f:	c9                   	leave  
  803120:	c3                   	ret    

00803121 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  803121:	55                   	push   %ebp
  803122:	89 e5                	mov    %esp,%ebp
  803124:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  803127:	6a 00                	push   $0x0
  803129:	ff 75 10             	pushl  0x10(%ebp)
  80312c:	ff 75 0c             	pushl  0xc(%ebp)
  80312f:	8b 45 08             	mov    0x8(%ebp),%eax
  803132:	ff 70 0c             	pushl  0xc(%eax)
  803135:	e8 78 03 00 00       	call   8034b2 <nsipc_send>
}
  80313a:	c9                   	leave  
  80313b:	c3                   	ret    

0080313c <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80313c:	55                   	push   %ebp
  80313d:	89 e5                	mov    %esp,%ebp
  80313f:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  803142:	6a 00                	push   $0x0
  803144:	ff 75 10             	pushl  0x10(%ebp)
  803147:	ff 75 0c             	pushl  0xc(%ebp)
  80314a:	8b 45 08             	mov    0x8(%ebp),%eax
  80314d:	ff 70 0c             	pushl  0xc(%eax)
  803150:	e8 f1 02 00 00       	call   803446 <nsipc_recv>
}
  803155:	c9                   	leave  
  803156:	c3                   	ret    

00803157 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  803157:	55                   	push   %ebp
  803158:	89 e5                	mov    %esp,%ebp
  80315a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80315d:	8d 55 f4             	lea    -0xc(%ebp),%edx
  803160:	52                   	push   %edx
  803161:	50                   	push   %eax
  803162:	e8 73 f7 ff ff       	call   8028da <fd_lookup>
  803167:	83 c4 10             	add    $0x10,%esp
  80316a:	85 c0                	test   %eax,%eax
  80316c:	78 17                	js     803185 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  80316e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803171:	8b 0d 80 90 80 00    	mov    0x809080,%ecx
  803177:	39 08                	cmp    %ecx,(%eax)
  803179:	75 05                	jne    803180 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80317b:	8b 40 0c             	mov    0xc(%eax),%eax
  80317e:	eb 05                	jmp    803185 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  803180:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  803185:	c9                   	leave  
  803186:	c3                   	ret    

00803187 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  803187:	55                   	push   %ebp
  803188:	89 e5                	mov    %esp,%ebp
  80318a:	56                   	push   %esi
  80318b:	53                   	push   %ebx
  80318c:	83 ec 1c             	sub    $0x1c,%esp
  80318f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  803191:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803194:	50                   	push   %eax
  803195:	e8 f1 f6 ff ff       	call   80288b <fd_alloc>
  80319a:	89 c3                	mov    %eax,%ebx
  80319c:	83 c4 10             	add    $0x10,%esp
  80319f:	85 c0                	test   %eax,%eax
  8031a1:	78 1b                	js     8031be <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8031a3:	83 ec 04             	sub    $0x4,%esp
  8031a6:	68 07 04 00 00       	push   $0x407
  8031ab:	ff 75 f4             	pushl  -0xc(%ebp)
  8031ae:	6a 00                	push   $0x0
  8031b0:	e8 6e f2 ff ff       	call   802423 <sys_page_alloc>
  8031b5:	89 c3                	mov    %eax,%ebx
  8031b7:	83 c4 10             	add    $0x10,%esp
  8031ba:	85 c0                	test   %eax,%eax
  8031bc:	79 10                	jns    8031ce <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8031be:	83 ec 0c             	sub    $0xc,%esp
  8031c1:	56                   	push   %esi
  8031c2:	e8 0e 02 00 00       	call   8033d5 <nsipc_close>
		return r;
  8031c7:	83 c4 10             	add    $0x10,%esp
  8031ca:	89 d8                	mov    %ebx,%eax
  8031cc:	eb 24                	jmp    8031f2 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8031ce:	8b 15 80 90 80 00    	mov    0x809080,%edx
  8031d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8031d7:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8031d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8031dc:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8031e3:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8031e6:	83 ec 0c             	sub    $0xc,%esp
  8031e9:	50                   	push   %eax
  8031ea:	e8 75 f6 ff ff       	call   802864 <fd2num>
  8031ef:	83 c4 10             	add    $0x10,%esp
}
  8031f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8031f5:	5b                   	pop    %ebx
  8031f6:	5e                   	pop    %esi
  8031f7:	5d                   	pop    %ebp
  8031f8:	c3                   	ret    

008031f9 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8031f9:	55                   	push   %ebp
  8031fa:	89 e5                	mov    %esp,%ebp
  8031fc:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8031ff:	8b 45 08             	mov    0x8(%ebp),%eax
  803202:	e8 50 ff ff ff       	call   803157 <fd2sockid>
		return r;
  803207:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  803209:	85 c0                	test   %eax,%eax
  80320b:	78 1f                	js     80322c <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80320d:	83 ec 04             	sub    $0x4,%esp
  803210:	ff 75 10             	pushl  0x10(%ebp)
  803213:	ff 75 0c             	pushl  0xc(%ebp)
  803216:	50                   	push   %eax
  803217:	e8 12 01 00 00       	call   80332e <nsipc_accept>
  80321c:	83 c4 10             	add    $0x10,%esp
		return r;
  80321f:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  803221:	85 c0                	test   %eax,%eax
  803223:	78 07                	js     80322c <accept+0x33>
		return r;
	return alloc_sockfd(r);
  803225:	e8 5d ff ff ff       	call   803187 <alloc_sockfd>
  80322a:	89 c1                	mov    %eax,%ecx
}
  80322c:	89 c8                	mov    %ecx,%eax
  80322e:	c9                   	leave  
  80322f:	c3                   	ret    

00803230 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  803230:	55                   	push   %ebp
  803231:	89 e5                	mov    %esp,%ebp
  803233:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  803236:	8b 45 08             	mov    0x8(%ebp),%eax
  803239:	e8 19 ff ff ff       	call   803157 <fd2sockid>
  80323e:	85 c0                	test   %eax,%eax
  803240:	78 12                	js     803254 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  803242:	83 ec 04             	sub    $0x4,%esp
  803245:	ff 75 10             	pushl  0x10(%ebp)
  803248:	ff 75 0c             	pushl  0xc(%ebp)
  80324b:	50                   	push   %eax
  80324c:	e8 2d 01 00 00       	call   80337e <nsipc_bind>
  803251:	83 c4 10             	add    $0x10,%esp
}
  803254:	c9                   	leave  
  803255:	c3                   	ret    

00803256 <shutdown>:

int
shutdown(int s, int how)
{
  803256:	55                   	push   %ebp
  803257:	89 e5                	mov    %esp,%ebp
  803259:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80325c:	8b 45 08             	mov    0x8(%ebp),%eax
  80325f:	e8 f3 fe ff ff       	call   803157 <fd2sockid>
  803264:	85 c0                	test   %eax,%eax
  803266:	78 0f                	js     803277 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  803268:	83 ec 08             	sub    $0x8,%esp
  80326b:	ff 75 0c             	pushl  0xc(%ebp)
  80326e:	50                   	push   %eax
  80326f:	e8 3f 01 00 00       	call   8033b3 <nsipc_shutdown>
  803274:	83 c4 10             	add    $0x10,%esp
}
  803277:	c9                   	leave  
  803278:	c3                   	ret    

00803279 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  803279:	55                   	push   %ebp
  80327a:	89 e5                	mov    %esp,%ebp
  80327c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80327f:	8b 45 08             	mov    0x8(%ebp),%eax
  803282:	e8 d0 fe ff ff       	call   803157 <fd2sockid>
  803287:	85 c0                	test   %eax,%eax
  803289:	78 12                	js     80329d <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  80328b:	83 ec 04             	sub    $0x4,%esp
  80328e:	ff 75 10             	pushl  0x10(%ebp)
  803291:	ff 75 0c             	pushl  0xc(%ebp)
  803294:	50                   	push   %eax
  803295:	e8 55 01 00 00       	call   8033ef <nsipc_connect>
  80329a:	83 c4 10             	add    $0x10,%esp
}
  80329d:	c9                   	leave  
  80329e:	c3                   	ret    

0080329f <listen>:

int
listen(int s, int backlog)
{
  80329f:	55                   	push   %ebp
  8032a0:	89 e5                	mov    %esp,%ebp
  8032a2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8032a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8032a8:	e8 aa fe ff ff       	call   803157 <fd2sockid>
  8032ad:	85 c0                	test   %eax,%eax
  8032af:	78 0f                	js     8032c0 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8032b1:	83 ec 08             	sub    $0x8,%esp
  8032b4:	ff 75 0c             	pushl  0xc(%ebp)
  8032b7:	50                   	push   %eax
  8032b8:	e8 67 01 00 00       	call   803424 <nsipc_listen>
  8032bd:	83 c4 10             	add    $0x10,%esp
}
  8032c0:	c9                   	leave  
  8032c1:	c3                   	ret    

008032c2 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8032c2:	55                   	push   %ebp
  8032c3:	89 e5                	mov    %esp,%ebp
  8032c5:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8032c8:	ff 75 10             	pushl  0x10(%ebp)
  8032cb:	ff 75 0c             	pushl  0xc(%ebp)
  8032ce:	ff 75 08             	pushl  0x8(%ebp)
  8032d1:	e8 3a 02 00 00       	call   803510 <nsipc_socket>
  8032d6:	83 c4 10             	add    $0x10,%esp
  8032d9:	85 c0                	test   %eax,%eax
  8032db:	78 05                	js     8032e2 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8032dd:	e8 a5 fe ff ff       	call   803187 <alloc_sockfd>
}
  8032e2:	c9                   	leave  
  8032e3:	c3                   	ret    

008032e4 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8032e4:	55                   	push   %ebp
  8032e5:	89 e5                	mov    %esp,%ebp
  8032e7:	53                   	push   %ebx
  8032e8:	83 ec 04             	sub    $0x4,%esp
  8032eb:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8032ed:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  8032f4:	75 12                	jne    803308 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8032f6:	83 ec 0c             	sub    $0xc,%esp
  8032f9:	6a 02                	push   $0x2
  8032fb:	e8 2b f5 ff ff       	call   80282b <ipc_find_env>
  803300:	a3 04 a0 80 00       	mov    %eax,0x80a004
  803305:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  803308:	6a 07                	push   $0x7
  80330a:	68 00 c0 80 00       	push   $0x80c000
  80330f:	53                   	push   %ebx
  803310:	ff 35 04 a0 80 00    	pushl  0x80a004
  803316:	e8 bc f4 ff ff       	call   8027d7 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80331b:	83 c4 0c             	add    $0xc,%esp
  80331e:	6a 00                	push   $0x0
  803320:	6a 00                	push   $0x0
  803322:	6a 00                	push   $0x0
  803324:	e8 45 f4 ff ff       	call   80276e <ipc_recv>
}
  803329:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80332c:	c9                   	leave  
  80332d:	c3                   	ret    

0080332e <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80332e:	55                   	push   %ebp
  80332f:	89 e5                	mov    %esp,%ebp
  803331:	56                   	push   %esi
  803332:	53                   	push   %ebx
  803333:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  803336:	8b 45 08             	mov    0x8(%ebp),%eax
  803339:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80333e:	8b 06                	mov    (%esi),%eax
  803340:	a3 04 c0 80 00       	mov    %eax,0x80c004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  803345:	b8 01 00 00 00       	mov    $0x1,%eax
  80334a:	e8 95 ff ff ff       	call   8032e4 <nsipc>
  80334f:	89 c3                	mov    %eax,%ebx
  803351:	85 c0                	test   %eax,%eax
  803353:	78 20                	js     803375 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  803355:	83 ec 04             	sub    $0x4,%esp
  803358:	ff 35 10 c0 80 00    	pushl  0x80c010
  80335e:	68 00 c0 80 00       	push   $0x80c000
  803363:	ff 75 0c             	pushl  0xc(%ebp)
  803366:	e8 47 ee ff ff       	call   8021b2 <memmove>
		*addrlen = ret->ret_addrlen;
  80336b:	a1 10 c0 80 00       	mov    0x80c010,%eax
  803370:	89 06                	mov    %eax,(%esi)
  803372:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  803375:	89 d8                	mov    %ebx,%eax
  803377:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80337a:	5b                   	pop    %ebx
  80337b:	5e                   	pop    %esi
  80337c:	5d                   	pop    %ebp
  80337d:	c3                   	ret    

0080337e <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80337e:	55                   	push   %ebp
  80337f:	89 e5                	mov    %esp,%ebp
  803381:	53                   	push   %ebx
  803382:	83 ec 08             	sub    $0x8,%esp
  803385:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  803388:	8b 45 08             	mov    0x8(%ebp),%eax
  80338b:	a3 00 c0 80 00       	mov    %eax,0x80c000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  803390:	53                   	push   %ebx
  803391:	ff 75 0c             	pushl  0xc(%ebp)
  803394:	68 04 c0 80 00       	push   $0x80c004
  803399:	e8 14 ee ff ff       	call   8021b2 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80339e:	89 1d 14 c0 80 00    	mov    %ebx,0x80c014
	return nsipc(NSREQ_BIND);
  8033a4:	b8 02 00 00 00       	mov    $0x2,%eax
  8033a9:	e8 36 ff ff ff       	call   8032e4 <nsipc>
}
  8033ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8033b1:	c9                   	leave  
  8033b2:	c3                   	ret    

008033b3 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8033b3:	55                   	push   %ebp
  8033b4:	89 e5                	mov    %esp,%ebp
  8033b6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8033b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8033bc:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.shutdown.req_how = how;
  8033c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8033c4:	a3 04 c0 80 00       	mov    %eax,0x80c004
	return nsipc(NSREQ_SHUTDOWN);
  8033c9:	b8 03 00 00 00       	mov    $0x3,%eax
  8033ce:	e8 11 ff ff ff       	call   8032e4 <nsipc>
}
  8033d3:	c9                   	leave  
  8033d4:	c3                   	ret    

008033d5 <nsipc_close>:

int
nsipc_close(int s)
{
  8033d5:	55                   	push   %ebp
  8033d6:	89 e5                	mov    %esp,%ebp
  8033d8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8033db:	8b 45 08             	mov    0x8(%ebp),%eax
  8033de:	a3 00 c0 80 00       	mov    %eax,0x80c000
	return nsipc(NSREQ_CLOSE);
  8033e3:	b8 04 00 00 00       	mov    $0x4,%eax
  8033e8:	e8 f7 fe ff ff       	call   8032e4 <nsipc>
}
  8033ed:	c9                   	leave  
  8033ee:	c3                   	ret    

008033ef <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8033ef:	55                   	push   %ebp
  8033f0:	89 e5                	mov    %esp,%ebp
  8033f2:	53                   	push   %ebx
  8033f3:	83 ec 08             	sub    $0x8,%esp
  8033f6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8033f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8033fc:	a3 00 c0 80 00       	mov    %eax,0x80c000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  803401:	53                   	push   %ebx
  803402:	ff 75 0c             	pushl  0xc(%ebp)
  803405:	68 04 c0 80 00       	push   $0x80c004
  80340a:	e8 a3 ed ff ff       	call   8021b2 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80340f:	89 1d 14 c0 80 00    	mov    %ebx,0x80c014
	return nsipc(NSREQ_CONNECT);
  803415:	b8 05 00 00 00       	mov    $0x5,%eax
  80341a:	e8 c5 fe ff ff       	call   8032e4 <nsipc>
}
  80341f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803422:	c9                   	leave  
  803423:	c3                   	ret    

00803424 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  803424:	55                   	push   %ebp
  803425:	89 e5                	mov    %esp,%ebp
  803427:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80342a:	8b 45 08             	mov    0x8(%ebp),%eax
  80342d:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.listen.req_backlog = backlog;
  803432:	8b 45 0c             	mov    0xc(%ebp),%eax
  803435:	a3 04 c0 80 00       	mov    %eax,0x80c004
	return nsipc(NSREQ_LISTEN);
  80343a:	b8 06 00 00 00       	mov    $0x6,%eax
  80343f:	e8 a0 fe ff ff       	call   8032e4 <nsipc>
}
  803444:	c9                   	leave  
  803445:	c3                   	ret    

00803446 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  803446:	55                   	push   %ebp
  803447:	89 e5                	mov    %esp,%ebp
  803449:	56                   	push   %esi
  80344a:	53                   	push   %ebx
  80344b:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80344e:	8b 45 08             	mov    0x8(%ebp),%eax
  803451:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.recv.req_len = len;
  803456:	89 35 04 c0 80 00    	mov    %esi,0x80c004
	nsipcbuf.recv.req_flags = flags;
  80345c:	8b 45 14             	mov    0x14(%ebp),%eax
  80345f:	a3 08 c0 80 00       	mov    %eax,0x80c008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  803464:	b8 07 00 00 00       	mov    $0x7,%eax
  803469:	e8 76 fe ff ff       	call   8032e4 <nsipc>
  80346e:	89 c3                	mov    %eax,%ebx
  803470:	85 c0                	test   %eax,%eax
  803472:	78 35                	js     8034a9 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  803474:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  803479:	7f 04                	jg     80347f <nsipc_recv+0x39>
  80347b:	39 c6                	cmp    %eax,%esi
  80347d:	7d 16                	jge    803495 <nsipc_recv+0x4f>
  80347f:	68 ce 46 80 00       	push   $0x8046ce
  803484:	68 fd 3c 80 00       	push   $0x803cfd
  803489:	6a 62                	push   $0x62
  80348b:	68 e3 46 80 00       	push   $0x8046e3
  803490:	e8 2d e5 ff ff       	call   8019c2 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  803495:	83 ec 04             	sub    $0x4,%esp
  803498:	50                   	push   %eax
  803499:	68 00 c0 80 00       	push   $0x80c000
  80349e:	ff 75 0c             	pushl  0xc(%ebp)
  8034a1:	e8 0c ed ff ff       	call   8021b2 <memmove>
  8034a6:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8034a9:	89 d8                	mov    %ebx,%eax
  8034ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8034ae:	5b                   	pop    %ebx
  8034af:	5e                   	pop    %esi
  8034b0:	5d                   	pop    %ebp
  8034b1:	c3                   	ret    

008034b2 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8034b2:	55                   	push   %ebp
  8034b3:	89 e5                	mov    %esp,%ebp
  8034b5:	53                   	push   %ebx
  8034b6:	83 ec 04             	sub    $0x4,%esp
  8034b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8034bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8034bf:	a3 00 c0 80 00       	mov    %eax,0x80c000
	assert(size < 1600);
  8034c4:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8034ca:	7e 16                	jle    8034e2 <nsipc_send+0x30>
  8034cc:	68 ef 46 80 00       	push   $0x8046ef
  8034d1:	68 fd 3c 80 00       	push   $0x803cfd
  8034d6:	6a 6d                	push   $0x6d
  8034d8:	68 e3 46 80 00       	push   $0x8046e3
  8034dd:	e8 e0 e4 ff ff       	call   8019c2 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8034e2:	83 ec 04             	sub    $0x4,%esp
  8034e5:	53                   	push   %ebx
  8034e6:	ff 75 0c             	pushl  0xc(%ebp)
  8034e9:	68 0c c0 80 00       	push   $0x80c00c
  8034ee:	e8 bf ec ff ff       	call   8021b2 <memmove>
	nsipcbuf.send.req_size = size;
  8034f3:	89 1d 04 c0 80 00    	mov    %ebx,0x80c004
	nsipcbuf.send.req_flags = flags;
  8034f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8034fc:	a3 08 c0 80 00       	mov    %eax,0x80c008
	return nsipc(NSREQ_SEND);
  803501:	b8 08 00 00 00       	mov    $0x8,%eax
  803506:	e8 d9 fd ff ff       	call   8032e4 <nsipc>
}
  80350b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80350e:	c9                   	leave  
  80350f:	c3                   	ret    

00803510 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  803510:	55                   	push   %ebp
  803511:	89 e5                	mov    %esp,%ebp
  803513:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  803516:	8b 45 08             	mov    0x8(%ebp),%eax
  803519:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.socket.req_type = type;
  80351e:	8b 45 0c             	mov    0xc(%ebp),%eax
  803521:	a3 04 c0 80 00       	mov    %eax,0x80c004
	nsipcbuf.socket.req_protocol = protocol;
  803526:	8b 45 10             	mov    0x10(%ebp),%eax
  803529:	a3 08 c0 80 00       	mov    %eax,0x80c008
	return nsipc(NSREQ_SOCKET);
  80352e:	b8 09 00 00 00       	mov    $0x9,%eax
  803533:	e8 ac fd ff ff       	call   8032e4 <nsipc>
}
  803538:	c9                   	leave  
  803539:	c3                   	ret    

0080353a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80353a:	55                   	push   %ebp
  80353b:	89 e5                	mov    %esp,%ebp
  80353d:	56                   	push   %esi
  80353e:	53                   	push   %ebx
  80353f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  803542:	83 ec 0c             	sub    $0xc,%esp
  803545:	ff 75 08             	pushl  0x8(%ebp)
  803548:	e8 27 f3 ff ff       	call   802874 <fd2data>
  80354d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80354f:	83 c4 08             	add    $0x8,%esp
  803552:	68 fb 46 80 00       	push   $0x8046fb
  803557:	53                   	push   %ebx
  803558:	e8 c3 ea ff ff       	call   802020 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80355d:	8b 46 04             	mov    0x4(%esi),%eax
  803560:	2b 06                	sub    (%esi),%eax
  803562:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  803568:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80356f:	00 00 00 
	stat->st_dev = &devpipe;
  803572:	c7 83 88 00 00 00 9c 	movl   $0x80909c,0x88(%ebx)
  803579:	90 80 00 
	return 0;
}
  80357c:	b8 00 00 00 00       	mov    $0x0,%eax
  803581:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803584:	5b                   	pop    %ebx
  803585:	5e                   	pop    %esi
  803586:	5d                   	pop    %ebp
  803587:	c3                   	ret    

00803588 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  803588:	55                   	push   %ebp
  803589:	89 e5                	mov    %esp,%ebp
  80358b:	53                   	push   %ebx
  80358c:	83 ec 0c             	sub    $0xc,%esp
  80358f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  803592:	53                   	push   %ebx
  803593:	6a 00                	push   $0x0
  803595:	e8 0e ef ff ff       	call   8024a8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80359a:	89 1c 24             	mov    %ebx,(%esp)
  80359d:	e8 d2 f2 ff ff       	call   802874 <fd2data>
  8035a2:	83 c4 08             	add    $0x8,%esp
  8035a5:	50                   	push   %eax
  8035a6:	6a 00                	push   $0x0
  8035a8:	e8 fb ee ff ff       	call   8024a8 <sys_page_unmap>
}
  8035ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8035b0:	c9                   	leave  
  8035b1:	c3                   	ret    

008035b2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8035b2:	55                   	push   %ebp
  8035b3:	89 e5                	mov    %esp,%ebp
  8035b5:	57                   	push   %edi
  8035b6:	56                   	push   %esi
  8035b7:	53                   	push   %ebx
  8035b8:	83 ec 1c             	sub    $0x1c,%esp
  8035bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8035be:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8035c0:	a1 10 a0 80 00       	mov    0x80a010,%eax
  8035c5:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8035c8:	83 ec 0c             	sub    $0xc,%esp
  8035cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8035ce:	e8 c5 fa ff ff       	call   803098 <pageref>
  8035d3:	89 c3                	mov    %eax,%ebx
  8035d5:	89 3c 24             	mov    %edi,(%esp)
  8035d8:	e8 bb fa ff ff       	call   803098 <pageref>
  8035dd:	83 c4 10             	add    $0x10,%esp
  8035e0:	39 c3                	cmp    %eax,%ebx
  8035e2:	0f 94 c1             	sete   %cl
  8035e5:	0f b6 c9             	movzbl %cl,%ecx
  8035e8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8035eb:	8b 15 10 a0 80 00    	mov    0x80a010,%edx
  8035f1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8035f4:	39 ce                	cmp    %ecx,%esi
  8035f6:	74 1b                	je     803613 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8035f8:	39 c3                	cmp    %eax,%ebx
  8035fa:	75 c4                	jne    8035c0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8035fc:	8b 42 58             	mov    0x58(%edx),%eax
  8035ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  803602:	50                   	push   %eax
  803603:	56                   	push   %esi
  803604:	68 02 47 80 00       	push   $0x804702
  803609:	e8 8d e4 ff ff       	call   801a9b <cprintf>
  80360e:	83 c4 10             	add    $0x10,%esp
  803611:	eb ad                	jmp    8035c0 <_pipeisclosed+0xe>
	}
}
  803613:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803616:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803619:	5b                   	pop    %ebx
  80361a:	5e                   	pop    %esi
  80361b:	5f                   	pop    %edi
  80361c:	5d                   	pop    %ebp
  80361d:	c3                   	ret    

0080361e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80361e:	55                   	push   %ebp
  80361f:	89 e5                	mov    %esp,%ebp
  803621:	57                   	push   %edi
  803622:	56                   	push   %esi
  803623:	53                   	push   %ebx
  803624:	83 ec 28             	sub    $0x28,%esp
  803627:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80362a:	56                   	push   %esi
  80362b:	e8 44 f2 ff ff       	call   802874 <fd2data>
  803630:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803632:	83 c4 10             	add    $0x10,%esp
  803635:	bf 00 00 00 00       	mov    $0x0,%edi
  80363a:	eb 4b                	jmp    803687 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80363c:	89 da                	mov    %ebx,%edx
  80363e:	89 f0                	mov    %esi,%eax
  803640:	e8 6d ff ff ff       	call   8035b2 <_pipeisclosed>
  803645:	85 c0                	test   %eax,%eax
  803647:	75 48                	jne    803691 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  803649:	e8 b6 ed ff ff       	call   802404 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80364e:	8b 43 04             	mov    0x4(%ebx),%eax
  803651:	8b 0b                	mov    (%ebx),%ecx
  803653:	8d 51 20             	lea    0x20(%ecx),%edx
  803656:	39 d0                	cmp    %edx,%eax
  803658:	73 e2                	jae    80363c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80365a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80365d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  803661:	88 4d e7             	mov    %cl,-0x19(%ebp)
  803664:	89 c2                	mov    %eax,%edx
  803666:	c1 fa 1f             	sar    $0x1f,%edx
  803669:	89 d1                	mov    %edx,%ecx
  80366b:	c1 e9 1b             	shr    $0x1b,%ecx
  80366e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  803671:	83 e2 1f             	and    $0x1f,%edx
  803674:	29 ca                	sub    %ecx,%edx
  803676:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80367a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80367e:	83 c0 01             	add    $0x1,%eax
  803681:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803684:	83 c7 01             	add    $0x1,%edi
  803687:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80368a:	75 c2                	jne    80364e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80368c:	8b 45 10             	mov    0x10(%ebp),%eax
  80368f:	eb 05                	jmp    803696 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803691:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  803696:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803699:	5b                   	pop    %ebx
  80369a:	5e                   	pop    %esi
  80369b:	5f                   	pop    %edi
  80369c:	5d                   	pop    %ebp
  80369d:	c3                   	ret    

0080369e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80369e:	55                   	push   %ebp
  80369f:	89 e5                	mov    %esp,%ebp
  8036a1:	57                   	push   %edi
  8036a2:	56                   	push   %esi
  8036a3:	53                   	push   %ebx
  8036a4:	83 ec 18             	sub    $0x18,%esp
  8036a7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8036aa:	57                   	push   %edi
  8036ab:	e8 c4 f1 ff ff       	call   802874 <fd2data>
  8036b0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8036b2:	83 c4 10             	add    $0x10,%esp
  8036b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8036ba:	eb 3d                	jmp    8036f9 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8036bc:	85 db                	test   %ebx,%ebx
  8036be:	74 04                	je     8036c4 <devpipe_read+0x26>
				return i;
  8036c0:	89 d8                	mov    %ebx,%eax
  8036c2:	eb 44                	jmp    803708 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8036c4:	89 f2                	mov    %esi,%edx
  8036c6:	89 f8                	mov    %edi,%eax
  8036c8:	e8 e5 fe ff ff       	call   8035b2 <_pipeisclosed>
  8036cd:	85 c0                	test   %eax,%eax
  8036cf:	75 32                	jne    803703 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8036d1:	e8 2e ed ff ff       	call   802404 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8036d6:	8b 06                	mov    (%esi),%eax
  8036d8:	3b 46 04             	cmp    0x4(%esi),%eax
  8036db:	74 df                	je     8036bc <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8036dd:	99                   	cltd   
  8036de:	c1 ea 1b             	shr    $0x1b,%edx
  8036e1:	01 d0                	add    %edx,%eax
  8036e3:	83 e0 1f             	and    $0x1f,%eax
  8036e6:	29 d0                	sub    %edx,%eax
  8036e8:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8036ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8036f0:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8036f3:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8036f6:	83 c3 01             	add    $0x1,%ebx
  8036f9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8036fc:	75 d8                	jne    8036d6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8036fe:	8b 45 10             	mov    0x10(%ebp),%eax
  803701:	eb 05                	jmp    803708 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803703:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  803708:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80370b:	5b                   	pop    %ebx
  80370c:	5e                   	pop    %esi
  80370d:	5f                   	pop    %edi
  80370e:	5d                   	pop    %ebp
  80370f:	c3                   	ret    

00803710 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  803710:	55                   	push   %ebp
  803711:	89 e5                	mov    %esp,%ebp
  803713:	56                   	push   %esi
  803714:	53                   	push   %ebx
  803715:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  803718:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80371b:	50                   	push   %eax
  80371c:	e8 6a f1 ff ff       	call   80288b <fd_alloc>
  803721:	83 c4 10             	add    $0x10,%esp
  803724:	89 c2                	mov    %eax,%edx
  803726:	85 c0                	test   %eax,%eax
  803728:	0f 88 2c 01 00 00    	js     80385a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80372e:	83 ec 04             	sub    $0x4,%esp
  803731:	68 07 04 00 00       	push   $0x407
  803736:	ff 75 f4             	pushl  -0xc(%ebp)
  803739:	6a 00                	push   $0x0
  80373b:	e8 e3 ec ff ff       	call   802423 <sys_page_alloc>
  803740:	83 c4 10             	add    $0x10,%esp
  803743:	89 c2                	mov    %eax,%edx
  803745:	85 c0                	test   %eax,%eax
  803747:	0f 88 0d 01 00 00    	js     80385a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80374d:	83 ec 0c             	sub    $0xc,%esp
  803750:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803753:	50                   	push   %eax
  803754:	e8 32 f1 ff ff       	call   80288b <fd_alloc>
  803759:	89 c3                	mov    %eax,%ebx
  80375b:	83 c4 10             	add    $0x10,%esp
  80375e:	85 c0                	test   %eax,%eax
  803760:	0f 88 e2 00 00 00    	js     803848 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803766:	83 ec 04             	sub    $0x4,%esp
  803769:	68 07 04 00 00       	push   $0x407
  80376e:	ff 75 f0             	pushl  -0x10(%ebp)
  803771:	6a 00                	push   $0x0
  803773:	e8 ab ec ff ff       	call   802423 <sys_page_alloc>
  803778:	89 c3                	mov    %eax,%ebx
  80377a:	83 c4 10             	add    $0x10,%esp
  80377d:	85 c0                	test   %eax,%eax
  80377f:	0f 88 c3 00 00 00    	js     803848 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  803785:	83 ec 0c             	sub    $0xc,%esp
  803788:	ff 75 f4             	pushl  -0xc(%ebp)
  80378b:	e8 e4 f0 ff ff       	call   802874 <fd2data>
  803790:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803792:	83 c4 0c             	add    $0xc,%esp
  803795:	68 07 04 00 00       	push   $0x407
  80379a:	50                   	push   %eax
  80379b:	6a 00                	push   $0x0
  80379d:	e8 81 ec ff ff       	call   802423 <sys_page_alloc>
  8037a2:	89 c3                	mov    %eax,%ebx
  8037a4:	83 c4 10             	add    $0x10,%esp
  8037a7:	85 c0                	test   %eax,%eax
  8037a9:	0f 88 89 00 00 00    	js     803838 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8037af:	83 ec 0c             	sub    $0xc,%esp
  8037b2:	ff 75 f0             	pushl  -0x10(%ebp)
  8037b5:	e8 ba f0 ff ff       	call   802874 <fd2data>
  8037ba:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8037c1:	50                   	push   %eax
  8037c2:	6a 00                	push   $0x0
  8037c4:	56                   	push   %esi
  8037c5:	6a 00                	push   $0x0
  8037c7:	e8 9a ec ff ff       	call   802466 <sys_page_map>
  8037cc:	89 c3                	mov    %eax,%ebx
  8037ce:	83 c4 20             	add    $0x20,%esp
  8037d1:	85 c0                	test   %eax,%eax
  8037d3:	78 55                	js     80382a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8037d5:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  8037db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8037de:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8037e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8037e3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8037ea:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  8037f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8037f3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8037f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8037f8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8037ff:	83 ec 0c             	sub    $0xc,%esp
  803802:	ff 75 f4             	pushl  -0xc(%ebp)
  803805:	e8 5a f0 ff ff       	call   802864 <fd2num>
  80380a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80380d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80380f:	83 c4 04             	add    $0x4,%esp
  803812:	ff 75 f0             	pushl  -0x10(%ebp)
  803815:	e8 4a f0 ff ff       	call   802864 <fd2num>
  80381a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80381d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  803820:	83 c4 10             	add    $0x10,%esp
  803823:	ba 00 00 00 00       	mov    $0x0,%edx
  803828:	eb 30                	jmp    80385a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80382a:	83 ec 08             	sub    $0x8,%esp
  80382d:	56                   	push   %esi
  80382e:	6a 00                	push   $0x0
  803830:	e8 73 ec ff ff       	call   8024a8 <sys_page_unmap>
  803835:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  803838:	83 ec 08             	sub    $0x8,%esp
  80383b:	ff 75 f0             	pushl  -0x10(%ebp)
  80383e:	6a 00                	push   $0x0
  803840:	e8 63 ec ff ff       	call   8024a8 <sys_page_unmap>
  803845:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  803848:	83 ec 08             	sub    $0x8,%esp
  80384b:	ff 75 f4             	pushl  -0xc(%ebp)
  80384e:	6a 00                	push   $0x0
  803850:	e8 53 ec ff ff       	call   8024a8 <sys_page_unmap>
  803855:	83 c4 10             	add    $0x10,%esp
  803858:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80385a:	89 d0                	mov    %edx,%eax
  80385c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80385f:	5b                   	pop    %ebx
  803860:	5e                   	pop    %esi
  803861:	5d                   	pop    %ebp
  803862:	c3                   	ret    

00803863 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  803863:	55                   	push   %ebp
  803864:	89 e5                	mov    %esp,%ebp
  803866:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803869:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80386c:	50                   	push   %eax
  80386d:	ff 75 08             	pushl  0x8(%ebp)
  803870:	e8 65 f0 ff ff       	call   8028da <fd_lookup>
  803875:	83 c4 10             	add    $0x10,%esp
  803878:	85 c0                	test   %eax,%eax
  80387a:	78 18                	js     803894 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80387c:	83 ec 0c             	sub    $0xc,%esp
  80387f:	ff 75 f4             	pushl  -0xc(%ebp)
  803882:	e8 ed ef ff ff       	call   802874 <fd2data>
	return _pipeisclosed(fd, p);
  803887:	89 c2                	mov    %eax,%edx
  803889:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80388c:	e8 21 fd ff ff       	call   8035b2 <_pipeisclosed>
  803891:	83 c4 10             	add    $0x10,%esp
}
  803894:	c9                   	leave  
  803895:	c3                   	ret    

00803896 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  803896:	55                   	push   %ebp
  803897:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  803899:	b8 00 00 00 00       	mov    $0x0,%eax
  80389e:	5d                   	pop    %ebp
  80389f:	c3                   	ret    

008038a0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8038a0:	55                   	push   %ebp
  8038a1:	89 e5                	mov    %esp,%ebp
  8038a3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8038a6:	68 1a 47 80 00       	push   $0x80471a
  8038ab:	ff 75 0c             	pushl  0xc(%ebp)
  8038ae:	e8 6d e7 ff ff       	call   802020 <strcpy>
	return 0;
}
  8038b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8038b8:	c9                   	leave  
  8038b9:	c3                   	ret    

008038ba <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8038ba:	55                   	push   %ebp
  8038bb:	89 e5                	mov    %esp,%ebp
  8038bd:	57                   	push   %edi
  8038be:	56                   	push   %esi
  8038bf:	53                   	push   %ebx
  8038c0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8038c6:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8038cb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8038d1:	eb 2d                	jmp    803900 <devcons_write+0x46>
		m = n - tot;
  8038d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8038d6:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8038d8:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8038db:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8038e0:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8038e3:	83 ec 04             	sub    $0x4,%esp
  8038e6:	53                   	push   %ebx
  8038e7:	03 45 0c             	add    0xc(%ebp),%eax
  8038ea:	50                   	push   %eax
  8038eb:	57                   	push   %edi
  8038ec:	e8 c1 e8 ff ff       	call   8021b2 <memmove>
		sys_cputs(buf, m);
  8038f1:	83 c4 08             	add    $0x8,%esp
  8038f4:	53                   	push   %ebx
  8038f5:	57                   	push   %edi
  8038f6:	e8 6c ea ff ff       	call   802367 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8038fb:	01 de                	add    %ebx,%esi
  8038fd:	83 c4 10             	add    $0x10,%esp
  803900:	89 f0                	mov    %esi,%eax
  803902:	3b 75 10             	cmp    0x10(%ebp),%esi
  803905:	72 cc                	jb     8038d3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  803907:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80390a:	5b                   	pop    %ebx
  80390b:	5e                   	pop    %esi
  80390c:	5f                   	pop    %edi
  80390d:	5d                   	pop    %ebp
  80390e:	c3                   	ret    

0080390f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80390f:	55                   	push   %ebp
  803910:	89 e5                	mov    %esp,%ebp
  803912:	83 ec 08             	sub    $0x8,%esp
  803915:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80391a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80391e:	74 2a                	je     80394a <devcons_read+0x3b>
  803920:	eb 05                	jmp    803927 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  803922:	e8 dd ea ff ff       	call   802404 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  803927:	e8 59 ea ff ff       	call   802385 <sys_cgetc>
  80392c:	85 c0                	test   %eax,%eax
  80392e:	74 f2                	je     803922 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  803930:	85 c0                	test   %eax,%eax
  803932:	78 16                	js     80394a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  803934:	83 f8 04             	cmp    $0x4,%eax
  803937:	74 0c                	je     803945 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  803939:	8b 55 0c             	mov    0xc(%ebp),%edx
  80393c:	88 02                	mov    %al,(%edx)
	return 1;
  80393e:	b8 01 00 00 00       	mov    $0x1,%eax
  803943:	eb 05                	jmp    80394a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  803945:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80394a:	c9                   	leave  
  80394b:	c3                   	ret    

0080394c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80394c:	55                   	push   %ebp
  80394d:	89 e5                	mov    %esp,%ebp
  80394f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  803952:	8b 45 08             	mov    0x8(%ebp),%eax
  803955:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  803958:	6a 01                	push   $0x1
  80395a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80395d:	50                   	push   %eax
  80395e:	e8 04 ea ff ff       	call   802367 <sys_cputs>
}
  803963:	83 c4 10             	add    $0x10,%esp
  803966:	c9                   	leave  
  803967:	c3                   	ret    

00803968 <getchar>:

int
getchar(void)
{
  803968:	55                   	push   %ebp
  803969:	89 e5                	mov    %esp,%ebp
  80396b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80396e:	6a 01                	push   $0x1
  803970:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803973:	50                   	push   %eax
  803974:	6a 00                	push   $0x0
  803976:	e8 c5 f1 ff ff       	call   802b40 <read>
	if (r < 0)
  80397b:	83 c4 10             	add    $0x10,%esp
  80397e:	85 c0                	test   %eax,%eax
  803980:	78 0f                	js     803991 <getchar+0x29>
		return r;
	if (r < 1)
  803982:	85 c0                	test   %eax,%eax
  803984:	7e 06                	jle    80398c <getchar+0x24>
		return -E_EOF;
	return c;
  803986:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80398a:	eb 05                	jmp    803991 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80398c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  803991:	c9                   	leave  
  803992:	c3                   	ret    

00803993 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  803993:	55                   	push   %ebp
  803994:	89 e5                	mov    %esp,%ebp
  803996:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803999:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80399c:	50                   	push   %eax
  80399d:	ff 75 08             	pushl  0x8(%ebp)
  8039a0:	e8 35 ef ff ff       	call   8028da <fd_lookup>
  8039a5:	83 c4 10             	add    $0x10,%esp
  8039a8:	85 c0                	test   %eax,%eax
  8039aa:	78 11                	js     8039bd <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8039ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8039af:	8b 15 b8 90 80 00    	mov    0x8090b8,%edx
  8039b5:	39 10                	cmp    %edx,(%eax)
  8039b7:	0f 94 c0             	sete   %al
  8039ba:	0f b6 c0             	movzbl %al,%eax
}
  8039bd:	c9                   	leave  
  8039be:	c3                   	ret    

008039bf <opencons>:

int
opencons(void)
{
  8039bf:	55                   	push   %ebp
  8039c0:	89 e5                	mov    %esp,%ebp
  8039c2:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8039c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8039c8:	50                   	push   %eax
  8039c9:	e8 bd ee ff ff       	call   80288b <fd_alloc>
  8039ce:	83 c4 10             	add    $0x10,%esp
		return r;
  8039d1:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8039d3:	85 c0                	test   %eax,%eax
  8039d5:	78 3e                	js     803a15 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8039d7:	83 ec 04             	sub    $0x4,%esp
  8039da:	68 07 04 00 00       	push   $0x407
  8039df:	ff 75 f4             	pushl  -0xc(%ebp)
  8039e2:	6a 00                	push   $0x0
  8039e4:	e8 3a ea ff ff       	call   802423 <sys_page_alloc>
  8039e9:	83 c4 10             	add    $0x10,%esp
		return r;
  8039ec:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8039ee:	85 c0                	test   %eax,%eax
  8039f0:	78 23                	js     803a15 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8039f2:	8b 15 b8 90 80 00    	mov    0x8090b8,%edx
  8039f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8039fb:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8039fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803a00:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  803a07:	83 ec 0c             	sub    $0xc,%esp
  803a0a:	50                   	push   %eax
  803a0b:	e8 54 ee ff ff       	call   802864 <fd2num>
  803a10:	89 c2                	mov    %eax,%edx
  803a12:	83 c4 10             	add    $0x10,%esp
}
  803a15:	89 d0                	mov    %edx,%eax
  803a17:	c9                   	leave  
  803a18:	c3                   	ret    
  803a19:	66 90                	xchg   %ax,%ax
  803a1b:	66 90                	xchg   %ax,%ax
  803a1d:	66 90                	xchg   %ax,%ax
  803a1f:	90                   	nop

00803a20 <__udivdi3>:
  803a20:	55                   	push   %ebp
  803a21:	57                   	push   %edi
  803a22:	56                   	push   %esi
  803a23:	53                   	push   %ebx
  803a24:	83 ec 1c             	sub    $0x1c,%esp
  803a27:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  803a2b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  803a2f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  803a33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803a37:	85 f6                	test   %esi,%esi
  803a39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803a3d:	89 ca                	mov    %ecx,%edx
  803a3f:	89 f8                	mov    %edi,%eax
  803a41:	75 3d                	jne    803a80 <__udivdi3+0x60>
  803a43:	39 cf                	cmp    %ecx,%edi
  803a45:	0f 87 c5 00 00 00    	ja     803b10 <__udivdi3+0xf0>
  803a4b:	85 ff                	test   %edi,%edi
  803a4d:	89 fd                	mov    %edi,%ebp
  803a4f:	75 0b                	jne    803a5c <__udivdi3+0x3c>
  803a51:	b8 01 00 00 00       	mov    $0x1,%eax
  803a56:	31 d2                	xor    %edx,%edx
  803a58:	f7 f7                	div    %edi
  803a5a:	89 c5                	mov    %eax,%ebp
  803a5c:	89 c8                	mov    %ecx,%eax
  803a5e:	31 d2                	xor    %edx,%edx
  803a60:	f7 f5                	div    %ebp
  803a62:	89 c1                	mov    %eax,%ecx
  803a64:	89 d8                	mov    %ebx,%eax
  803a66:	89 cf                	mov    %ecx,%edi
  803a68:	f7 f5                	div    %ebp
  803a6a:	89 c3                	mov    %eax,%ebx
  803a6c:	89 d8                	mov    %ebx,%eax
  803a6e:	89 fa                	mov    %edi,%edx
  803a70:	83 c4 1c             	add    $0x1c,%esp
  803a73:	5b                   	pop    %ebx
  803a74:	5e                   	pop    %esi
  803a75:	5f                   	pop    %edi
  803a76:	5d                   	pop    %ebp
  803a77:	c3                   	ret    
  803a78:	90                   	nop
  803a79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803a80:	39 ce                	cmp    %ecx,%esi
  803a82:	77 74                	ja     803af8 <__udivdi3+0xd8>
  803a84:	0f bd fe             	bsr    %esi,%edi
  803a87:	83 f7 1f             	xor    $0x1f,%edi
  803a8a:	0f 84 98 00 00 00    	je     803b28 <__udivdi3+0x108>
  803a90:	bb 20 00 00 00       	mov    $0x20,%ebx
  803a95:	89 f9                	mov    %edi,%ecx
  803a97:	89 c5                	mov    %eax,%ebp
  803a99:	29 fb                	sub    %edi,%ebx
  803a9b:	d3 e6                	shl    %cl,%esi
  803a9d:	89 d9                	mov    %ebx,%ecx
  803a9f:	d3 ed                	shr    %cl,%ebp
  803aa1:	89 f9                	mov    %edi,%ecx
  803aa3:	d3 e0                	shl    %cl,%eax
  803aa5:	09 ee                	or     %ebp,%esi
  803aa7:	89 d9                	mov    %ebx,%ecx
  803aa9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803aad:	89 d5                	mov    %edx,%ebp
  803aaf:	8b 44 24 08          	mov    0x8(%esp),%eax
  803ab3:	d3 ed                	shr    %cl,%ebp
  803ab5:	89 f9                	mov    %edi,%ecx
  803ab7:	d3 e2                	shl    %cl,%edx
  803ab9:	89 d9                	mov    %ebx,%ecx
  803abb:	d3 e8                	shr    %cl,%eax
  803abd:	09 c2                	or     %eax,%edx
  803abf:	89 d0                	mov    %edx,%eax
  803ac1:	89 ea                	mov    %ebp,%edx
  803ac3:	f7 f6                	div    %esi
  803ac5:	89 d5                	mov    %edx,%ebp
  803ac7:	89 c3                	mov    %eax,%ebx
  803ac9:	f7 64 24 0c          	mull   0xc(%esp)
  803acd:	39 d5                	cmp    %edx,%ebp
  803acf:	72 10                	jb     803ae1 <__udivdi3+0xc1>
  803ad1:	8b 74 24 08          	mov    0x8(%esp),%esi
  803ad5:	89 f9                	mov    %edi,%ecx
  803ad7:	d3 e6                	shl    %cl,%esi
  803ad9:	39 c6                	cmp    %eax,%esi
  803adb:	73 07                	jae    803ae4 <__udivdi3+0xc4>
  803add:	39 d5                	cmp    %edx,%ebp
  803adf:	75 03                	jne    803ae4 <__udivdi3+0xc4>
  803ae1:	83 eb 01             	sub    $0x1,%ebx
  803ae4:	31 ff                	xor    %edi,%edi
  803ae6:	89 d8                	mov    %ebx,%eax
  803ae8:	89 fa                	mov    %edi,%edx
  803aea:	83 c4 1c             	add    $0x1c,%esp
  803aed:	5b                   	pop    %ebx
  803aee:	5e                   	pop    %esi
  803aef:	5f                   	pop    %edi
  803af0:	5d                   	pop    %ebp
  803af1:	c3                   	ret    
  803af2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803af8:	31 ff                	xor    %edi,%edi
  803afa:	31 db                	xor    %ebx,%ebx
  803afc:	89 d8                	mov    %ebx,%eax
  803afe:	89 fa                	mov    %edi,%edx
  803b00:	83 c4 1c             	add    $0x1c,%esp
  803b03:	5b                   	pop    %ebx
  803b04:	5e                   	pop    %esi
  803b05:	5f                   	pop    %edi
  803b06:	5d                   	pop    %ebp
  803b07:	c3                   	ret    
  803b08:	90                   	nop
  803b09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803b10:	89 d8                	mov    %ebx,%eax
  803b12:	f7 f7                	div    %edi
  803b14:	31 ff                	xor    %edi,%edi
  803b16:	89 c3                	mov    %eax,%ebx
  803b18:	89 d8                	mov    %ebx,%eax
  803b1a:	89 fa                	mov    %edi,%edx
  803b1c:	83 c4 1c             	add    $0x1c,%esp
  803b1f:	5b                   	pop    %ebx
  803b20:	5e                   	pop    %esi
  803b21:	5f                   	pop    %edi
  803b22:	5d                   	pop    %ebp
  803b23:	c3                   	ret    
  803b24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803b28:	39 ce                	cmp    %ecx,%esi
  803b2a:	72 0c                	jb     803b38 <__udivdi3+0x118>
  803b2c:	31 db                	xor    %ebx,%ebx
  803b2e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803b32:	0f 87 34 ff ff ff    	ja     803a6c <__udivdi3+0x4c>
  803b38:	bb 01 00 00 00       	mov    $0x1,%ebx
  803b3d:	e9 2a ff ff ff       	jmp    803a6c <__udivdi3+0x4c>
  803b42:	66 90                	xchg   %ax,%ax
  803b44:	66 90                	xchg   %ax,%ax
  803b46:	66 90                	xchg   %ax,%ax
  803b48:	66 90                	xchg   %ax,%ax
  803b4a:	66 90                	xchg   %ax,%ax
  803b4c:	66 90                	xchg   %ax,%ax
  803b4e:	66 90                	xchg   %ax,%ax

00803b50 <__umoddi3>:
  803b50:	55                   	push   %ebp
  803b51:	57                   	push   %edi
  803b52:	56                   	push   %esi
  803b53:	53                   	push   %ebx
  803b54:	83 ec 1c             	sub    $0x1c,%esp
  803b57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  803b5b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  803b5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  803b63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803b67:	85 d2                	test   %edx,%edx
  803b69:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  803b6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803b71:	89 f3                	mov    %esi,%ebx
  803b73:	89 3c 24             	mov    %edi,(%esp)
  803b76:	89 74 24 04          	mov    %esi,0x4(%esp)
  803b7a:	75 1c                	jne    803b98 <__umoddi3+0x48>
  803b7c:	39 f7                	cmp    %esi,%edi
  803b7e:	76 50                	jbe    803bd0 <__umoddi3+0x80>
  803b80:	89 c8                	mov    %ecx,%eax
  803b82:	89 f2                	mov    %esi,%edx
  803b84:	f7 f7                	div    %edi
  803b86:	89 d0                	mov    %edx,%eax
  803b88:	31 d2                	xor    %edx,%edx
  803b8a:	83 c4 1c             	add    $0x1c,%esp
  803b8d:	5b                   	pop    %ebx
  803b8e:	5e                   	pop    %esi
  803b8f:	5f                   	pop    %edi
  803b90:	5d                   	pop    %ebp
  803b91:	c3                   	ret    
  803b92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803b98:	39 f2                	cmp    %esi,%edx
  803b9a:	89 d0                	mov    %edx,%eax
  803b9c:	77 52                	ja     803bf0 <__umoddi3+0xa0>
  803b9e:	0f bd ea             	bsr    %edx,%ebp
  803ba1:	83 f5 1f             	xor    $0x1f,%ebp
  803ba4:	75 5a                	jne    803c00 <__umoddi3+0xb0>
  803ba6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  803baa:	0f 82 e0 00 00 00    	jb     803c90 <__umoddi3+0x140>
  803bb0:	39 0c 24             	cmp    %ecx,(%esp)
  803bb3:	0f 86 d7 00 00 00    	jbe    803c90 <__umoddi3+0x140>
  803bb9:	8b 44 24 08          	mov    0x8(%esp),%eax
  803bbd:	8b 54 24 04          	mov    0x4(%esp),%edx
  803bc1:	83 c4 1c             	add    $0x1c,%esp
  803bc4:	5b                   	pop    %ebx
  803bc5:	5e                   	pop    %esi
  803bc6:	5f                   	pop    %edi
  803bc7:	5d                   	pop    %ebp
  803bc8:	c3                   	ret    
  803bc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803bd0:	85 ff                	test   %edi,%edi
  803bd2:	89 fd                	mov    %edi,%ebp
  803bd4:	75 0b                	jne    803be1 <__umoddi3+0x91>
  803bd6:	b8 01 00 00 00       	mov    $0x1,%eax
  803bdb:	31 d2                	xor    %edx,%edx
  803bdd:	f7 f7                	div    %edi
  803bdf:	89 c5                	mov    %eax,%ebp
  803be1:	89 f0                	mov    %esi,%eax
  803be3:	31 d2                	xor    %edx,%edx
  803be5:	f7 f5                	div    %ebp
  803be7:	89 c8                	mov    %ecx,%eax
  803be9:	f7 f5                	div    %ebp
  803beb:	89 d0                	mov    %edx,%eax
  803bed:	eb 99                	jmp    803b88 <__umoddi3+0x38>
  803bef:	90                   	nop
  803bf0:	89 c8                	mov    %ecx,%eax
  803bf2:	89 f2                	mov    %esi,%edx
  803bf4:	83 c4 1c             	add    $0x1c,%esp
  803bf7:	5b                   	pop    %ebx
  803bf8:	5e                   	pop    %esi
  803bf9:	5f                   	pop    %edi
  803bfa:	5d                   	pop    %ebp
  803bfb:	c3                   	ret    
  803bfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803c00:	8b 34 24             	mov    (%esp),%esi
  803c03:	bf 20 00 00 00       	mov    $0x20,%edi
  803c08:	89 e9                	mov    %ebp,%ecx
  803c0a:	29 ef                	sub    %ebp,%edi
  803c0c:	d3 e0                	shl    %cl,%eax
  803c0e:	89 f9                	mov    %edi,%ecx
  803c10:	89 f2                	mov    %esi,%edx
  803c12:	d3 ea                	shr    %cl,%edx
  803c14:	89 e9                	mov    %ebp,%ecx
  803c16:	09 c2                	or     %eax,%edx
  803c18:	89 d8                	mov    %ebx,%eax
  803c1a:	89 14 24             	mov    %edx,(%esp)
  803c1d:	89 f2                	mov    %esi,%edx
  803c1f:	d3 e2                	shl    %cl,%edx
  803c21:	89 f9                	mov    %edi,%ecx
  803c23:	89 54 24 04          	mov    %edx,0x4(%esp)
  803c27:	8b 54 24 0c          	mov    0xc(%esp),%edx
  803c2b:	d3 e8                	shr    %cl,%eax
  803c2d:	89 e9                	mov    %ebp,%ecx
  803c2f:	89 c6                	mov    %eax,%esi
  803c31:	d3 e3                	shl    %cl,%ebx
  803c33:	89 f9                	mov    %edi,%ecx
  803c35:	89 d0                	mov    %edx,%eax
  803c37:	d3 e8                	shr    %cl,%eax
  803c39:	89 e9                	mov    %ebp,%ecx
  803c3b:	09 d8                	or     %ebx,%eax
  803c3d:	89 d3                	mov    %edx,%ebx
  803c3f:	89 f2                	mov    %esi,%edx
  803c41:	f7 34 24             	divl   (%esp)
  803c44:	89 d6                	mov    %edx,%esi
  803c46:	d3 e3                	shl    %cl,%ebx
  803c48:	f7 64 24 04          	mull   0x4(%esp)
  803c4c:	39 d6                	cmp    %edx,%esi
  803c4e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803c52:	89 d1                	mov    %edx,%ecx
  803c54:	89 c3                	mov    %eax,%ebx
  803c56:	72 08                	jb     803c60 <__umoddi3+0x110>
  803c58:	75 11                	jne    803c6b <__umoddi3+0x11b>
  803c5a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  803c5e:	73 0b                	jae    803c6b <__umoddi3+0x11b>
  803c60:	2b 44 24 04          	sub    0x4(%esp),%eax
  803c64:	1b 14 24             	sbb    (%esp),%edx
  803c67:	89 d1                	mov    %edx,%ecx
  803c69:	89 c3                	mov    %eax,%ebx
  803c6b:	8b 54 24 08          	mov    0x8(%esp),%edx
  803c6f:	29 da                	sub    %ebx,%edx
  803c71:	19 ce                	sbb    %ecx,%esi
  803c73:	89 f9                	mov    %edi,%ecx
  803c75:	89 f0                	mov    %esi,%eax
  803c77:	d3 e0                	shl    %cl,%eax
  803c79:	89 e9                	mov    %ebp,%ecx
  803c7b:	d3 ea                	shr    %cl,%edx
  803c7d:	89 e9                	mov    %ebp,%ecx
  803c7f:	d3 ee                	shr    %cl,%esi
  803c81:	09 d0                	or     %edx,%eax
  803c83:	89 f2                	mov    %esi,%edx
  803c85:	83 c4 1c             	add    $0x1c,%esp
  803c88:	5b                   	pop    %ebx
  803c89:	5e                   	pop    %esi
  803c8a:	5f                   	pop    %edi
  803c8b:	5d                   	pop    %ebp
  803c8c:	c3                   	ret    
  803c8d:	8d 76 00             	lea    0x0(%esi),%esi
  803c90:	29 f9                	sub    %edi,%ecx
  803c92:	19 d6                	sbb    %edx,%esi
  803c94:	89 74 24 04          	mov    %esi,0x4(%esp)
  803c98:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803c9c:	e9 18 ff ff ff       	jmp    803bb9 <__umoddi3+0x69>
