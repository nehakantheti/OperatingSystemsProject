
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	43013103          	ld	sp,1072(sp) # 8000a430 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	04a000ef          	jal	80000060 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000056:	14d79073          	csrw	stimecmp,a5
}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb03f>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	e1678793          	addi	a5,a5,-490 # 80000e96 <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000a2:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	addi	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	715d                	addi	sp,sp,-80
    800000d2:	e486                	sd	ra,72(sp)
    800000d4:	e0a2                	sd	s0,64(sp)
    800000d6:	f84a                	sd	s2,48(sp)
    800000d8:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    800000da:	04c05263          	blez	a2,8000011e <consolewrite+0x4e>
    800000de:	fc26                	sd	s1,56(sp)
    800000e0:	f44e                	sd	s3,40(sp)
    800000e2:	f052                	sd	s4,32(sp)
    800000e4:	ec56                	sd	s5,24(sp)
    800000e6:	8a2a                	mv	s4,a0
    800000e8:	84ae                	mv	s1,a1
    800000ea:	89b2                	mv	s3,a2
    800000ec:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    800000ee:	5afd                	li	s5,-1
    800000f0:	4685                	li	a3,1
    800000f2:	8626                	mv	a2,s1
    800000f4:	85d2                	mv	a1,s4
    800000f6:	fbf40513          	addi	a0,s0,-65
    800000fa:	18e020ef          	jal	80002288 <either_copyin>
    800000fe:	03550263          	beq	a0,s5,80000122 <consolewrite+0x52>
      break;
    uartputc(c);
    80000102:	fbf44503          	lbu	a0,-65(s0)
    80000106:	069000ef          	jal	8000096e <uartputc>
  for(i = 0; i < n; i++){
    8000010a:	2905                	addiw	s2,s2,1
    8000010c:	0485                	addi	s1,s1,1
    8000010e:	ff2991e3          	bne	s3,s2,800000f0 <consolewrite+0x20>
    80000112:	894e                	mv	s2,s3
    80000114:	74e2                	ld	s1,56(sp)
    80000116:	79a2                	ld	s3,40(sp)
    80000118:	7a02                	ld	s4,32(sp)
    8000011a:	6ae2                	ld	s5,24(sp)
    8000011c:	a039                	j	8000012a <consolewrite+0x5a>
    8000011e:	4901                	li	s2,0
    80000120:	a029                	j	8000012a <consolewrite+0x5a>
    80000122:	74e2                	ld	s1,56(sp)
    80000124:	79a2                	ld	s3,40(sp)
    80000126:	7a02                	ld	s4,32(sp)
    80000128:	6ae2                	ld	s5,24(sp)
  }

  return i;
}
    8000012a:	854a                	mv	a0,s2
    8000012c:	60a6                	ld	ra,72(sp)
    8000012e:	6406                	ld	s0,64(sp)
    80000130:	7942                	ld	s2,48(sp)
    80000132:	6161                	addi	sp,sp,80
    80000134:	8082                	ret

0000000080000136 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000136:	711d                	addi	sp,sp,-96
    80000138:	ec86                	sd	ra,88(sp)
    8000013a:	e8a2                	sd	s0,80(sp)
    8000013c:	e4a6                	sd	s1,72(sp)
    8000013e:	e0ca                	sd	s2,64(sp)
    80000140:	fc4e                	sd	s3,56(sp)
    80000142:	f852                	sd	s4,48(sp)
    80000144:	f456                	sd	s5,40(sp)
    80000146:	f05a                	sd	s6,32(sp)
    80000148:	1080                	addi	s0,sp,96
    8000014a:	8aaa                	mv	s5,a0
    8000014c:	8a2e                	mv	s4,a1
    8000014e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000150:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000154:	00012517          	auipc	a0,0x12
    80000158:	33c50513          	addi	a0,a0,828 # 80012490 <cons>
    8000015c:	2cd000ef          	jal	80000c28 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000160:	00012497          	auipc	s1,0x12
    80000164:	33048493          	addi	s1,s1,816 # 80012490 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000168:	00012917          	auipc	s2,0x12
    8000016c:	3c090913          	addi	s2,s2,960 # 80012528 <cons+0x98>
  while(n > 0){
    80000170:	0b305d63          	blez	s3,8000022a <consoleread+0xf4>
    while(cons.r == cons.w){
    80000174:	0984a783          	lw	a5,152(s1)
    80000178:	09c4a703          	lw	a4,156(s1)
    8000017c:	0af71263          	bne	a4,a5,80000220 <consoleread+0xea>
      if(killed(myproc())){
    80000180:	794010ef          	jal	80001914 <myproc>
    80000184:	797010ef          	jal	8000211a <killed>
    80000188:	e12d                	bnez	a0,800001ea <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    8000018a:	85a6                	mv	a1,s1
    8000018c:	854a                	mv	a0,s2
    8000018e:	555010ef          	jal	80001ee2 <sleep>
    while(cons.r == cons.w){
    80000192:	0984a783          	lw	a5,152(s1)
    80000196:	09c4a703          	lw	a4,156(s1)
    8000019a:	fef703e3          	beq	a4,a5,80000180 <consoleread+0x4a>
    8000019e:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001a0:	00012717          	auipc	a4,0x12
    800001a4:	2f070713          	addi	a4,a4,752 # 80012490 <cons>
    800001a8:	0017869b          	addiw	a3,a5,1
    800001ac:	08d72c23          	sw	a3,152(a4)
    800001b0:	07f7f693          	andi	a3,a5,127
    800001b4:	9736                	add	a4,a4,a3
    800001b6:	01874703          	lbu	a4,24(a4)
    800001ba:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001be:	4691                	li	a3,4
    800001c0:	04db8663          	beq	s7,a3,8000020c <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001c4:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001c8:	4685                	li	a3,1
    800001ca:	faf40613          	addi	a2,s0,-81
    800001ce:	85d2                	mv	a1,s4
    800001d0:	8556                	mv	a0,s5
    800001d2:	06c020ef          	jal	8000223e <either_copyout>
    800001d6:	57fd                	li	a5,-1
    800001d8:	04f50863          	beq	a0,a5,80000228 <consoleread+0xf2>
      break;

    dst++;
    800001dc:	0a05                	addi	s4,s4,1
    --n;
    800001de:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    800001e0:	47a9                	li	a5,10
    800001e2:	04fb8d63          	beq	s7,a5,8000023c <consoleread+0x106>
    800001e6:	6be2                	ld	s7,24(sp)
    800001e8:	b761                	j	80000170 <consoleread+0x3a>
        release(&cons.lock);
    800001ea:	00012517          	auipc	a0,0x12
    800001ee:	2a650513          	addi	a0,a0,678 # 80012490 <cons>
    800001f2:	2cf000ef          	jal	80000cc0 <release>
        return -1;
    800001f6:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    800001f8:	60e6                	ld	ra,88(sp)
    800001fa:	6446                	ld	s0,80(sp)
    800001fc:	64a6                	ld	s1,72(sp)
    800001fe:	6906                	ld	s2,64(sp)
    80000200:	79e2                	ld	s3,56(sp)
    80000202:	7a42                	ld	s4,48(sp)
    80000204:	7aa2                	ld	s5,40(sp)
    80000206:	7b02                	ld	s6,32(sp)
    80000208:	6125                	addi	sp,sp,96
    8000020a:	8082                	ret
      if(n < target){
    8000020c:	0009871b          	sext.w	a4,s3
    80000210:	01677a63          	bgeu	a4,s6,80000224 <consoleread+0xee>
        cons.r--;
    80000214:	00012717          	auipc	a4,0x12
    80000218:	30f72a23          	sw	a5,788(a4) # 80012528 <cons+0x98>
    8000021c:	6be2                	ld	s7,24(sp)
    8000021e:	a031                	j	8000022a <consoleread+0xf4>
    80000220:	ec5e                	sd	s7,24(sp)
    80000222:	bfbd                	j	800001a0 <consoleread+0x6a>
    80000224:	6be2                	ld	s7,24(sp)
    80000226:	a011                	j	8000022a <consoleread+0xf4>
    80000228:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    8000022a:	00012517          	auipc	a0,0x12
    8000022e:	26650513          	addi	a0,a0,614 # 80012490 <cons>
    80000232:	28f000ef          	jal	80000cc0 <release>
  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	bf7d                	j	800001f8 <consoleread+0xc2>
    8000023c:	6be2                	ld	s7,24(sp)
    8000023e:	b7f5                	j	8000022a <consoleread+0xf4>

0000000080000240 <microdelay>:
void microdelay(int us){
    80000240:	1101                	addi	sp,sp,-32
    80000242:	ec22                	sd	s0,24(sp)
    80000244:	1000                	addi	s0,sp,32
  volatile uint64 i = 0;
    80000246:	fe043423          	sd	zero,-24(s0)
  while(i < us*12){     // Adjust multiplier based on your CPU speed
    8000024a:	0015179b          	slliw	a5,a0,0x1
    8000024e:	9d3d                	addw	a0,a0,a5
    80000250:	0025151b          	slliw	a0,a0,0x2
    80000254:	fe843783          	ld	a5,-24(s0)
    80000258:	00a7fb63          	bgeu	a5,a0,8000026e <microdelay+0x2e>
    i++;
    8000025c:	fe843783          	ld	a5,-24(s0)
    80000260:	0785                	addi	a5,a5,1
    80000262:	fef43423          	sd	a5,-24(s0)
  while(i < us*12){     // Adjust multiplier based on your CPU speed
    80000266:	fe843783          	ld	a5,-24(s0)
    8000026a:	fea7e9e3          	bltu	a5,a0,8000025c <microdelay+0x1c>
}
    8000026e:	6462                	ld	s0,24(sp)
    80000270:	6105                	addi	sp,sp,32
    80000272:	8082                	ret

0000000080000274 <consputc>:
{
    80000274:	1141                	addi	sp,sp,-16
    80000276:	e406                	sd	ra,8(sp)
    80000278:	e022                	sd	s0,0(sp)
    8000027a:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000027c:	10000793          	li	a5,256
    80000280:	00f50863          	beq	a0,a5,80000290 <consputc+0x1c>
    uartputc_sync(c);
    80000284:	604000ef          	jal	80000888 <uartputc_sync>
}
    80000288:	60a2                	ld	ra,8(sp)
    8000028a:	6402                	ld	s0,0(sp)
    8000028c:	0141                	addi	sp,sp,16
    8000028e:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000290:	4521                	li	a0,8
    80000292:	5f6000ef          	jal	80000888 <uartputc_sync>
    80000296:	02000513          	li	a0,32
    8000029a:	5ee000ef          	jal	80000888 <uartputc_sync>
    8000029e:	4521                	li	a0,8
    800002a0:	5e8000ef          	jal	80000888 <uartputc_sync>
    800002a4:	b7d5                	j	80000288 <consputc+0x14>

00000000800002a6 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002a6:	1101                	addi	sp,sp,-32
    800002a8:	ec06                	sd	ra,24(sp)
    800002aa:	e822                	sd	s0,16(sp)
    800002ac:	e426                	sd	s1,8(sp)
    800002ae:	1000                	addi	s0,sp,32
    800002b0:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002b2:	00012517          	auipc	a0,0x12
    800002b6:	1de50513          	addi	a0,a0,478 # 80012490 <cons>
    800002ba:	16f000ef          	jal	80000c28 <acquire>

  switch(c){
    800002be:	47d5                	li	a5,21
    800002c0:	08f48f63          	beq	s1,a5,8000035e <consoleintr+0xb8>
    800002c4:	0297c563          	blt	a5,s1,800002ee <consoleintr+0x48>
    800002c8:	47a1                	li	a5,8
    800002ca:	0ef48463          	beq	s1,a5,800003b2 <consoleintr+0x10c>
    800002ce:	47c1                	li	a5,16
    800002d0:	10f49563          	bne	s1,a5,800003da <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800002d4:	7ff010ef          	jal	800022d2 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002d8:	00012517          	auipc	a0,0x12
    800002dc:	1b850513          	addi	a0,a0,440 # 80012490 <cons>
    800002e0:	1e1000ef          	jal	80000cc0 <release>
}
    800002e4:	60e2                	ld	ra,24(sp)
    800002e6:	6442                	ld	s0,16(sp)
    800002e8:	64a2                	ld	s1,8(sp)
    800002ea:	6105                	addi	sp,sp,32
    800002ec:	8082                	ret
  switch(c){
    800002ee:	07f00793          	li	a5,127
    800002f2:	0cf48063          	beq	s1,a5,800003b2 <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002f6:	00012717          	auipc	a4,0x12
    800002fa:	19a70713          	addi	a4,a4,410 # 80012490 <cons>
    800002fe:	0a072783          	lw	a5,160(a4)
    80000302:	09872703          	lw	a4,152(a4)
    80000306:	9f99                	subw	a5,a5,a4
    80000308:	07f00713          	li	a4,127
    8000030c:	fcf766e3          	bltu	a4,a5,800002d8 <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000310:	47b5                	li	a5,13
    80000312:	0cf48763          	beq	s1,a5,800003e0 <consoleintr+0x13a>
      consputc(c);
    80000316:	8526                	mv	a0,s1
    80000318:	f5dff0ef          	jal	80000274 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000031c:	00012797          	auipc	a5,0x12
    80000320:	17478793          	addi	a5,a5,372 # 80012490 <cons>
    80000324:	0a07a683          	lw	a3,160(a5)
    80000328:	0016871b          	addiw	a4,a3,1
    8000032c:	0007061b          	sext.w	a2,a4
    80000330:	0ae7a023          	sw	a4,160(a5)
    80000334:	07f6f693          	andi	a3,a3,127
    80000338:	97b6                	add	a5,a5,a3
    8000033a:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000033e:	47a9                	li	a5,10
    80000340:	0cf48563          	beq	s1,a5,8000040a <consoleintr+0x164>
    80000344:	4791                	li	a5,4
    80000346:	0cf48263          	beq	s1,a5,8000040a <consoleintr+0x164>
    8000034a:	00012797          	auipc	a5,0x12
    8000034e:	1de7a783          	lw	a5,478(a5) # 80012528 <cons+0x98>
    80000352:	9f1d                	subw	a4,a4,a5
    80000354:	08000793          	li	a5,128
    80000358:	f8f710e3          	bne	a4,a5,800002d8 <consoleintr+0x32>
    8000035c:	a07d                	j	8000040a <consoleintr+0x164>
    8000035e:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000360:	00012717          	auipc	a4,0x12
    80000364:	13070713          	addi	a4,a4,304 # 80012490 <cons>
    80000368:	0a072783          	lw	a5,160(a4)
    8000036c:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000370:	00012497          	auipc	s1,0x12
    80000374:	12048493          	addi	s1,s1,288 # 80012490 <cons>
    while(cons.e != cons.w &&
    80000378:	4929                	li	s2,10
    8000037a:	02f70863          	beq	a4,a5,800003aa <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000037e:	37fd                	addiw	a5,a5,-1
    80000380:	07f7f713          	andi	a4,a5,127
    80000384:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80000386:	01874703          	lbu	a4,24(a4)
    8000038a:	03270263          	beq	a4,s2,800003ae <consoleintr+0x108>
      cons.e--;
    8000038e:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80000392:	10000513          	li	a0,256
    80000396:	edfff0ef          	jal	80000274 <consputc>
    while(cons.e != cons.w &&
    8000039a:	0a04a783          	lw	a5,160(s1)
    8000039e:	09c4a703          	lw	a4,156(s1)
    800003a2:	fcf71ee3          	bne	a4,a5,8000037e <consoleintr+0xd8>
    800003a6:	6902                	ld	s2,0(sp)
    800003a8:	bf05                	j	800002d8 <consoleintr+0x32>
    800003aa:	6902                	ld	s2,0(sp)
    800003ac:	b735                	j	800002d8 <consoleintr+0x32>
    800003ae:	6902                	ld	s2,0(sp)
    800003b0:	b725                	j	800002d8 <consoleintr+0x32>
    if(cons.e != cons.w){
    800003b2:	00012717          	auipc	a4,0x12
    800003b6:	0de70713          	addi	a4,a4,222 # 80012490 <cons>
    800003ba:	0a072783          	lw	a5,160(a4)
    800003be:	09c72703          	lw	a4,156(a4)
    800003c2:	f0f70be3          	beq	a4,a5,800002d8 <consoleintr+0x32>
      cons.e--;
    800003c6:	37fd                	addiw	a5,a5,-1
    800003c8:	00012717          	auipc	a4,0x12
    800003cc:	16f72423          	sw	a5,360(a4) # 80012530 <cons+0xa0>
      consputc(BACKSPACE);
    800003d0:	10000513          	li	a0,256
    800003d4:	ea1ff0ef          	jal	80000274 <consputc>
    800003d8:	b701                	j	800002d8 <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003da:	ee048fe3          	beqz	s1,800002d8 <consoleintr+0x32>
    800003de:	bf21                	j	800002f6 <consoleintr+0x50>
      consputc(c);
    800003e0:	4529                	li	a0,10
    800003e2:	e93ff0ef          	jal	80000274 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003e6:	00012797          	auipc	a5,0x12
    800003ea:	0aa78793          	addi	a5,a5,170 # 80012490 <cons>
    800003ee:	0a07a703          	lw	a4,160(a5)
    800003f2:	0017069b          	addiw	a3,a4,1
    800003f6:	0006861b          	sext.w	a2,a3
    800003fa:	0ad7a023          	sw	a3,160(a5)
    800003fe:	07f77713          	andi	a4,a4,127
    80000402:	97ba                	add	a5,a5,a4
    80000404:	4729                	li	a4,10
    80000406:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000040a:	00012797          	auipc	a5,0x12
    8000040e:	12c7a123          	sw	a2,290(a5) # 8001252c <cons+0x9c>
        wakeup(&cons.r);
    80000412:	00012517          	auipc	a0,0x12
    80000416:	11650513          	addi	a0,a0,278 # 80012528 <cons+0x98>
    8000041a:	315010ef          	jal	80001f2e <wakeup>
    8000041e:	bd6d                	j	800002d8 <consoleintr+0x32>

0000000080000420 <consoleinit>:

void
consoleinit(void)
{
    80000420:	1141                	addi	sp,sp,-16
    80000422:	e406                	sd	ra,8(sp)
    80000424:	e022                	sd	s0,0(sp)
    80000426:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000428:	00007597          	auipc	a1,0x7
    8000042c:	bd858593          	addi	a1,a1,-1064 # 80007000 <etext>
    80000430:	00012517          	auipc	a0,0x12
    80000434:	06050513          	addi	a0,a0,96 # 80012490 <cons>
    80000438:	770000ef          	jal	80000ba8 <initlock>

  uartinit();
    8000043c:	3f4000ef          	jal	80000830 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000440:	00022797          	auipc	a5,0x22
    80000444:	1e878793          	addi	a5,a5,488 # 80022628 <devsw>
    80000448:	00000717          	auipc	a4,0x0
    8000044c:	cee70713          	addi	a4,a4,-786 # 80000136 <consoleread>
    80000450:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000452:	00000717          	auipc	a4,0x0
    80000456:	c7e70713          	addi	a4,a4,-898 # 800000d0 <consolewrite>
    8000045a:	ef98                	sd	a4,24(a5)
}
    8000045c:	60a2                	ld	ra,8(sp)
    8000045e:	6402                	ld	s0,0(sp)
    80000460:	0141                	addi	sp,sp,16
    80000462:	8082                	ret

0000000080000464 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000464:	7179                	addi	sp,sp,-48
    80000466:	f406                	sd	ra,40(sp)
    80000468:	f022                	sd	s0,32(sp)
    8000046a:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    8000046c:	c219                	beqz	a2,80000472 <printint+0xe>
    8000046e:	08054063          	bltz	a0,800004ee <printint+0x8a>
    x = -xx;
  else
    x = xx;
    80000472:	4881                	li	a7,0
    80000474:	fd040693          	addi	a3,s0,-48

  i = 0;
    80000478:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    8000047a:	00007617          	auipc	a2,0x7
    8000047e:	30e60613          	addi	a2,a2,782 # 80007788 <digits>
    80000482:	883e                	mv	a6,a5
    80000484:	2785                	addiw	a5,a5,1
    80000486:	02b57733          	remu	a4,a0,a1
    8000048a:	9732                	add	a4,a4,a2
    8000048c:	00074703          	lbu	a4,0(a4)
    80000490:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000494:	872a                	mv	a4,a0
    80000496:	02b55533          	divu	a0,a0,a1
    8000049a:	0685                	addi	a3,a3,1
    8000049c:	feb773e3          	bgeu	a4,a1,80000482 <printint+0x1e>

  if(sign)
    800004a0:	00088a63          	beqz	a7,800004b4 <printint+0x50>
    buf[i++] = '-';
    800004a4:	1781                	addi	a5,a5,-32
    800004a6:	97a2                	add	a5,a5,s0
    800004a8:	02d00713          	li	a4,45
    800004ac:	fee78823          	sb	a4,-16(a5)
    800004b0:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    800004b4:	02f05963          	blez	a5,800004e6 <printint+0x82>
    800004b8:	ec26                	sd	s1,24(sp)
    800004ba:	e84a                	sd	s2,16(sp)
    800004bc:	fd040713          	addi	a4,s0,-48
    800004c0:	00f704b3          	add	s1,a4,a5
    800004c4:	fff70913          	addi	s2,a4,-1
    800004c8:	993e                	add	s2,s2,a5
    800004ca:	37fd                	addiw	a5,a5,-1
    800004cc:	1782                	slli	a5,a5,0x20
    800004ce:	9381                	srli	a5,a5,0x20
    800004d0:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004d4:	fff4c503          	lbu	a0,-1(s1)
    800004d8:	d9dff0ef          	jal	80000274 <consputc>
  while(--i >= 0)
    800004dc:	14fd                	addi	s1,s1,-1
    800004de:	ff249be3          	bne	s1,s2,800004d4 <printint+0x70>
    800004e2:	64e2                	ld	s1,24(sp)
    800004e4:	6942                	ld	s2,16(sp)
}
    800004e6:	70a2                	ld	ra,40(sp)
    800004e8:	7402                	ld	s0,32(sp)
    800004ea:	6145                	addi	sp,sp,48
    800004ec:	8082                	ret
    x = -xx;
    800004ee:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004f2:	4885                	li	a7,1
    x = -xx;
    800004f4:	b741                	j	80000474 <printint+0x10>

00000000800004f6 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004f6:	7155                	addi	sp,sp,-208
    800004f8:	e506                	sd	ra,136(sp)
    800004fa:	e122                	sd	s0,128(sp)
    800004fc:	f0d2                	sd	s4,96(sp)
    800004fe:	0900                	addi	s0,sp,144
    80000500:	8a2a                	mv	s4,a0
    80000502:	e40c                	sd	a1,8(s0)
    80000504:	e810                	sd	a2,16(s0)
    80000506:	ec14                	sd	a3,24(s0)
    80000508:	f018                	sd	a4,32(s0)
    8000050a:	f41c                	sd	a5,40(s0)
    8000050c:	03043823          	sd	a6,48(s0)
    80000510:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    80000514:	00012797          	auipc	a5,0x12
    80000518:	03c7a783          	lw	a5,60(a5) # 80012550 <pr+0x18>
    8000051c:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    80000520:	e3a1                	bnez	a5,80000560 <printf+0x6a>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000522:	00840793          	addi	a5,s0,8
    80000526:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000052a:	00054503          	lbu	a0,0(a0)
    8000052e:	26050763          	beqz	a0,8000079c <printf+0x2a6>
    80000532:	fca6                	sd	s1,120(sp)
    80000534:	f8ca                	sd	s2,112(sp)
    80000536:	f4ce                	sd	s3,104(sp)
    80000538:	ecd6                	sd	s5,88(sp)
    8000053a:	e8da                	sd	s6,80(sp)
    8000053c:	e0e2                	sd	s8,64(sp)
    8000053e:	fc66                	sd	s9,56(sp)
    80000540:	f86a                	sd	s10,48(sp)
    80000542:	f46e                	sd	s11,40(sp)
    80000544:	4981                	li	s3,0
    if(cx != '%'){
    80000546:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    8000054a:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000054e:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    80000552:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000556:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    8000055a:	07000d93          	li	s11,112
    8000055e:	a815                	j	80000592 <printf+0x9c>
    acquire(&pr.lock);
    80000560:	00012517          	auipc	a0,0x12
    80000564:	fd850513          	addi	a0,a0,-40 # 80012538 <pr>
    80000568:	6c0000ef          	jal	80000c28 <acquire>
  va_start(ap, fmt);
    8000056c:	00840793          	addi	a5,s0,8
    80000570:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000574:	000a4503          	lbu	a0,0(s4)
    80000578:	fd4d                	bnez	a0,80000532 <printf+0x3c>
    8000057a:	a481                	j	800007ba <printf+0x2c4>
      consputc(cx);
    8000057c:	cf9ff0ef          	jal	80000274 <consputc>
      continue;
    80000580:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000582:	0014899b          	addiw	s3,s1,1
    80000586:	013a07b3          	add	a5,s4,s3
    8000058a:	0007c503          	lbu	a0,0(a5)
    8000058e:	1e050b63          	beqz	a0,80000784 <printf+0x28e>
    if(cx != '%'){
    80000592:	ff5515e3          	bne	a0,s5,8000057c <printf+0x86>
    i++;
    80000596:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    8000059a:	009a07b3          	add	a5,s4,s1
    8000059e:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    800005a2:	1e090163          	beqz	s2,80000784 <printf+0x28e>
    800005a6:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    800005aa:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    800005ac:	c789                	beqz	a5,800005b6 <printf+0xc0>
    800005ae:	009a0733          	add	a4,s4,s1
    800005b2:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    800005b6:	03690763          	beq	s2,s6,800005e4 <printf+0xee>
    } else if(c0 == 'l' && c1 == 'd'){
    800005ba:	05890163          	beq	s2,s8,800005fc <printf+0x106>
    } else if(c0 == 'u'){
    800005be:	0d990b63          	beq	s2,s9,80000694 <printf+0x19e>
    } else if(c0 == 'x'){
    800005c2:	13a90163          	beq	s2,s10,800006e4 <printf+0x1ee>
    } else if(c0 == 'p'){
    800005c6:	13b90b63          	beq	s2,s11,800006fc <printf+0x206>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 's'){
    800005ca:	07300793          	li	a5,115
    800005ce:	16f90a63          	beq	s2,a5,80000742 <printf+0x24c>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    800005d2:	1b590463          	beq	s2,s5,8000077a <printf+0x284>
      consputc('%');
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800005d6:	8556                	mv	a0,s5
    800005d8:	c9dff0ef          	jal	80000274 <consputc>
      consputc(c0);
    800005dc:	854a                	mv	a0,s2
    800005de:	c97ff0ef          	jal	80000274 <consputc>
    800005e2:	b745                	j	80000582 <printf+0x8c>
      printint(va_arg(ap, int), 10, 1);
    800005e4:	f8843783          	ld	a5,-120(s0)
    800005e8:	00878713          	addi	a4,a5,8
    800005ec:	f8e43423          	sd	a4,-120(s0)
    800005f0:	4605                	li	a2,1
    800005f2:	45a9                	li	a1,10
    800005f4:	4388                	lw	a0,0(a5)
    800005f6:	e6fff0ef          	jal	80000464 <printint>
    800005fa:	b761                	j	80000582 <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'd'){
    800005fc:	03678663          	beq	a5,s6,80000628 <printf+0x132>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80000600:	05878263          	beq	a5,s8,80000644 <printf+0x14e>
    } else if(c0 == 'l' && c1 == 'u'){
    80000604:	0b978463          	beq	a5,s9,800006ac <printf+0x1b6>
    } else if(c0 == 'l' && c1 == 'x'){
    80000608:	fda797e3          	bne	a5,s10,800005d6 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    8000060c:	f8843783          	ld	a5,-120(s0)
    80000610:	00878713          	addi	a4,a5,8
    80000614:	f8e43423          	sd	a4,-120(s0)
    80000618:	4601                	li	a2,0
    8000061a:	45c1                	li	a1,16
    8000061c:	6388                	ld	a0,0(a5)
    8000061e:	e47ff0ef          	jal	80000464 <printint>
      i += 1;
    80000622:	0029849b          	addiw	s1,s3,2
    80000626:	bfb1                	j	80000582 <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    80000628:	f8843783          	ld	a5,-120(s0)
    8000062c:	00878713          	addi	a4,a5,8
    80000630:	f8e43423          	sd	a4,-120(s0)
    80000634:	4605                	li	a2,1
    80000636:	45a9                	li	a1,10
    80000638:	6388                	ld	a0,0(a5)
    8000063a:	e2bff0ef          	jal	80000464 <printint>
      i += 1;
    8000063e:	0029849b          	addiw	s1,s3,2
    80000642:	b781                	j	80000582 <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80000644:	06400793          	li	a5,100
    80000648:	02f68863          	beq	a3,a5,80000678 <printf+0x182>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    8000064c:	07500793          	li	a5,117
    80000650:	06f68c63          	beq	a3,a5,800006c8 <printf+0x1d2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    80000654:	07800793          	li	a5,120
    80000658:	f6f69fe3          	bne	a3,a5,800005d6 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    8000065c:	f8843783          	ld	a5,-120(s0)
    80000660:	00878713          	addi	a4,a5,8
    80000664:	f8e43423          	sd	a4,-120(s0)
    80000668:	4601                	li	a2,0
    8000066a:	45c1                	li	a1,16
    8000066c:	6388                	ld	a0,0(a5)
    8000066e:	df7ff0ef          	jal	80000464 <printint>
      i += 2;
    80000672:	0039849b          	addiw	s1,s3,3
    80000676:	b731                	j	80000582 <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    80000678:	f8843783          	ld	a5,-120(s0)
    8000067c:	00878713          	addi	a4,a5,8
    80000680:	f8e43423          	sd	a4,-120(s0)
    80000684:	4605                	li	a2,1
    80000686:	45a9                	li	a1,10
    80000688:	6388                	ld	a0,0(a5)
    8000068a:	ddbff0ef          	jal	80000464 <printint>
      i += 2;
    8000068e:	0039849b          	addiw	s1,s3,3
    80000692:	bdc5                	j	80000582 <printf+0x8c>
      printint(va_arg(ap, int), 10, 0);
    80000694:	f8843783          	ld	a5,-120(s0)
    80000698:	00878713          	addi	a4,a5,8
    8000069c:	f8e43423          	sd	a4,-120(s0)
    800006a0:	4601                	li	a2,0
    800006a2:	45a9                	li	a1,10
    800006a4:	4388                	lw	a0,0(a5)
    800006a6:	dbfff0ef          	jal	80000464 <printint>
    800006aa:	bde1                	j	80000582 <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    800006ac:	f8843783          	ld	a5,-120(s0)
    800006b0:	00878713          	addi	a4,a5,8
    800006b4:	f8e43423          	sd	a4,-120(s0)
    800006b8:	4601                	li	a2,0
    800006ba:	45a9                	li	a1,10
    800006bc:	6388                	ld	a0,0(a5)
    800006be:	da7ff0ef          	jal	80000464 <printint>
      i += 1;
    800006c2:	0029849b          	addiw	s1,s3,2
    800006c6:	bd75                	j	80000582 <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    800006c8:	f8843783          	ld	a5,-120(s0)
    800006cc:	00878713          	addi	a4,a5,8
    800006d0:	f8e43423          	sd	a4,-120(s0)
    800006d4:	4601                	li	a2,0
    800006d6:	45a9                	li	a1,10
    800006d8:	6388                	ld	a0,0(a5)
    800006da:	d8bff0ef          	jal	80000464 <printint>
      i += 2;
    800006de:	0039849b          	addiw	s1,s3,3
    800006e2:	b545                	j	80000582 <printf+0x8c>
      printint(va_arg(ap, int), 16, 0);
    800006e4:	f8843783          	ld	a5,-120(s0)
    800006e8:	00878713          	addi	a4,a5,8
    800006ec:	f8e43423          	sd	a4,-120(s0)
    800006f0:	4601                	li	a2,0
    800006f2:	45c1                	li	a1,16
    800006f4:	4388                	lw	a0,0(a5)
    800006f6:	d6fff0ef          	jal	80000464 <printint>
    800006fa:	b561                	j	80000582 <printf+0x8c>
    800006fc:	e4de                	sd	s7,72(sp)
      printptr(va_arg(ap, uint64));
    800006fe:	f8843783          	ld	a5,-120(s0)
    80000702:	00878713          	addi	a4,a5,8
    80000706:	f8e43423          	sd	a4,-120(s0)
    8000070a:	0007b983          	ld	s3,0(a5)
  consputc('0');
    8000070e:	03000513          	li	a0,48
    80000712:	b63ff0ef          	jal	80000274 <consputc>
  consputc('x');
    80000716:	07800513          	li	a0,120
    8000071a:	b5bff0ef          	jal	80000274 <consputc>
    8000071e:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000720:	00007b97          	auipc	s7,0x7
    80000724:	068b8b93          	addi	s7,s7,104 # 80007788 <digits>
    80000728:	03c9d793          	srli	a5,s3,0x3c
    8000072c:	97de                	add	a5,a5,s7
    8000072e:	0007c503          	lbu	a0,0(a5)
    80000732:	b43ff0ef          	jal	80000274 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000736:	0992                	slli	s3,s3,0x4
    80000738:	397d                	addiw	s2,s2,-1
    8000073a:	fe0917e3          	bnez	s2,80000728 <printf+0x232>
    8000073e:	6ba6                	ld	s7,72(sp)
    80000740:	b589                	j	80000582 <printf+0x8c>
      if((s = va_arg(ap, char*)) == 0)
    80000742:	f8843783          	ld	a5,-120(s0)
    80000746:	00878713          	addi	a4,a5,8
    8000074a:	f8e43423          	sd	a4,-120(s0)
    8000074e:	0007b903          	ld	s2,0(a5)
    80000752:	00090d63          	beqz	s2,8000076c <printf+0x276>
      for(; *s; s++)
    80000756:	00094503          	lbu	a0,0(s2)
    8000075a:	e20504e3          	beqz	a0,80000582 <printf+0x8c>
        consputc(*s);
    8000075e:	b17ff0ef          	jal	80000274 <consputc>
      for(; *s; s++)
    80000762:	0905                	addi	s2,s2,1
    80000764:	00094503          	lbu	a0,0(s2)
    80000768:	f97d                	bnez	a0,8000075e <printf+0x268>
    8000076a:	bd21                	j	80000582 <printf+0x8c>
        s = "(null)";
    8000076c:	00007917          	auipc	s2,0x7
    80000770:	89c90913          	addi	s2,s2,-1892 # 80007008 <etext+0x8>
      for(; *s; s++)
    80000774:	02800513          	li	a0,40
    80000778:	b7dd                	j	8000075e <printf+0x268>
      consputc('%');
    8000077a:	02500513          	li	a0,37
    8000077e:	af7ff0ef          	jal	80000274 <consputc>
    80000782:	b501                	j	80000582 <printf+0x8c>
    }
#endif
  }
  va_end(ap);

  if(locking)
    80000784:	f7843783          	ld	a5,-136(s0)
    80000788:	e385                	bnez	a5,800007a8 <printf+0x2b2>
    8000078a:	74e6                	ld	s1,120(sp)
    8000078c:	7946                	ld	s2,112(sp)
    8000078e:	79a6                	ld	s3,104(sp)
    80000790:	6ae6                	ld	s5,88(sp)
    80000792:	6b46                	ld	s6,80(sp)
    80000794:	6c06                	ld	s8,64(sp)
    80000796:	7ce2                	ld	s9,56(sp)
    80000798:	7d42                	ld	s10,48(sp)
    8000079a:	7da2                	ld	s11,40(sp)
    release(&pr.lock);

  return 0;
}
    8000079c:	4501                	li	a0,0
    8000079e:	60aa                	ld	ra,136(sp)
    800007a0:	640a                	ld	s0,128(sp)
    800007a2:	7a06                	ld	s4,96(sp)
    800007a4:	6169                	addi	sp,sp,208
    800007a6:	8082                	ret
    800007a8:	74e6                	ld	s1,120(sp)
    800007aa:	7946                	ld	s2,112(sp)
    800007ac:	79a6                	ld	s3,104(sp)
    800007ae:	6ae6                	ld	s5,88(sp)
    800007b0:	6b46                	ld	s6,80(sp)
    800007b2:	6c06                	ld	s8,64(sp)
    800007b4:	7ce2                	ld	s9,56(sp)
    800007b6:	7d42                	ld	s10,48(sp)
    800007b8:	7da2                	ld	s11,40(sp)
    release(&pr.lock);
    800007ba:	00012517          	auipc	a0,0x12
    800007be:	d7e50513          	addi	a0,a0,-642 # 80012538 <pr>
    800007c2:	4fe000ef          	jal	80000cc0 <release>
    800007c6:	bfd9                	j	8000079c <printf+0x2a6>

00000000800007c8 <panic>:

void
panic(char *s)
{
    800007c8:	1101                	addi	sp,sp,-32
    800007ca:	ec06                	sd	ra,24(sp)
    800007cc:	e822                	sd	s0,16(sp)
    800007ce:	e426                	sd	s1,8(sp)
    800007d0:	1000                	addi	s0,sp,32
    800007d2:	84aa                	mv	s1,a0
  pr.locking = 0;
    800007d4:	00012797          	auipc	a5,0x12
    800007d8:	d607ae23          	sw	zero,-644(a5) # 80012550 <pr+0x18>
  printf("panic: ");
    800007dc:	00007517          	auipc	a0,0x7
    800007e0:	83c50513          	addi	a0,a0,-1988 # 80007018 <etext+0x18>
    800007e4:	d13ff0ef          	jal	800004f6 <printf>
  printf("%s\n", s);
    800007e8:	85a6                	mv	a1,s1
    800007ea:	00007517          	auipc	a0,0x7
    800007ee:	83650513          	addi	a0,a0,-1994 # 80007020 <etext+0x20>
    800007f2:	d05ff0ef          	jal	800004f6 <printf>
  panicked = 1; // freeze uart output from other CPUs
    800007f6:	4785                	li	a5,1
    800007f8:	0000a717          	auipc	a4,0xa
    800007fc:	c4f72c23          	sw	a5,-936(a4) # 8000a450 <panicked>
  for(;;)
    80000800:	a001                	j	80000800 <panic+0x38>

0000000080000802 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000802:	1101                	addi	sp,sp,-32
    80000804:	ec06                	sd	ra,24(sp)
    80000806:	e822                	sd	s0,16(sp)
    80000808:	e426                	sd	s1,8(sp)
    8000080a:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000080c:	00012497          	auipc	s1,0x12
    80000810:	d2c48493          	addi	s1,s1,-724 # 80012538 <pr>
    80000814:	00007597          	auipc	a1,0x7
    80000818:	81458593          	addi	a1,a1,-2028 # 80007028 <etext+0x28>
    8000081c:	8526                	mv	a0,s1
    8000081e:	38a000ef          	jal	80000ba8 <initlock>
  pr.locking = 1;
    80000822:	4785                	li	a5,1
    80000824:	cc9c                	sw	a5,24(s1)
}
    80000826:	60e2                	ld	ra,24(sp)
    80000828:	6442                	ld	s0,16(sp)
    8000082a:	64a2                	ld	s1,8(sp)
    8000082c:	6105                	addi	sp,sp,32
    8000082e:	8082                	ret

0000000080000830 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000830:	1141                	addi	sp,sp,-16
    80000832:	e406                	sd	ra,8(sp)
    80000834:	e022                	sd	s0,0(sp)
    80000836:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000838:	100007b7          	lui	a5,0x10000
    8000083c:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000840:	10000737          	lui	a4,0x10000
    80000844:	f8000693          	li	a3,-128
    80000848:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000084c:	468d                	li	a3,3
    8000084e:	10000637          	lui	a2,0x10000
    80000852:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000856:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000085a:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000085e:	10000737          	lui	a4,0x10000
    80000862:	461d                	li	a2,7
    80000864:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000868:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    8000086c:	00006597          	auipc	a1,0x6
    80000870:	7c458593          	addi	a1,a1,1988 # 80007030 <etext+0x30>
    80000874:	00012517          	auipc	a0,0x12
    80000878:	ce450513          	addi	a0,a0,-796 # 80012558 <uart_tx_lock>
    8000087c:	32c000ef          	jal	80000ba8 <initlock>
}
    80000880:	60a2                	ld	ra,8(sp)
    80000882:	6402                	ld	s0,0(sp)
    80000884:	0141                	addi	sp,sp,16
    80000886:	8082                	ret

0000000080000888 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000888:	1101                	addi	sp,sp,-32
    8000088a:	ec06                	sd	ra,24(sp)
    8000088c:	e822                	sd	s0,16(sp)
    8000088e:	e426                	sd	s1,8(sp)
    80000890:	1000                	addi	s0,sp,32
    80000892:	84aa                	mv	s1,a0
  push_off();
    80000894:	354000ef          	jal	80000be8 <push_off>

  if(panicked){
    80000898:	0000a797          	auipc	a5,0xa
    8000089c:	bb87a783          	lw	a5,-1096(a5) # 8000a450 <panicked>
    800008a0:	e795                	bnez	a5,800008cc <uartputc_sync+0x44>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800008a2:	10000737          	lui	a4,0x10000
    800008a6:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    800008a8:	00074783          	lbu	a5,0(a4)
    800008ac:	0207f793          	andi	a5,a5,32
    800008b0:	dfe5                	beqz	a5,800008a8 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    800008b2:	0ff4f513          	zext.b	a0,s1
    800008b6:	100007b7          	lui	a5,0x10000
    800008ba:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    800008be:	3ae000ef          	jal	80000c6c <pop_off>
}
    800008c2:	60e2                	ld	ra,24(sp)
    800008c4:	6442                	ld	s0,16(sp)
    800008c6:	64a2                	ld	s1,8(sp)
    800008c8:	6105                	addi	sp,sp,32
    800008ca:	8082                	ret
    for(;;)
    800008cc:	a001                	j	800008cc <uartputc_sync+0x44>

00000000800008ce <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    800008ce:	0000a797          	auipc	a5,0xa
    800008d2:	b8a7b783          	ld	a5,-1142(a5) # 8000a458 <uart_tx_r>
    800008d6:	0000a717          	auipc	a4,0xa
    800008da:	b8a73703          	ld	a4,-1142(a4) # 8000a460 <uart_tx_w>
    800008de:	08f70263          	beq	a4,a5,80000962 <uartstart+0x94>
{
    800008e2:	7139                	addi	sp,sp,-64
    800008e4:	fc06                	sd	ra,56(sp)
    800008e6:	f822                	sd	s0,48(sp)
    800008e8:	f426                	sd	s1,40(sp)
    800008ea:	f04a                	sd	s2,32(sp)
    800008ec:	ec4e                	sd	s3,24(sp)
    800008ee:	e852                	sd	s4,16(sp)
    800008f0:	e456                	sd	s5,8(sp)
    800008f2:	e05a                	sd	s6,0(sp)
    800008f4:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008f6:	10000937          	lui	s2,0x10000
    800008fa:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008fc:	00012a97          	auipc	s5,0x12
    80000900:	c5ca8a93          	addi	s5,s5,-932 # 80012558 <uart_tx_lock>
    uart_tx_r += 1;
    80000904:	0000a497          	auipc	s1,0xa
    80000908:	b5448493          	addi	s1,s1,-1196 # 8000a458 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    8000090c:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    80000910:	0000a997          	auipc	s3,0xa
    80000914:	b5098993          	addi	s3,s3,-1200 # 8000a460 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000918:	00094703          	lbu	a4,0(s2)
    8000091c:	02077713          	andi	a4,a4,32
    80000920:	c71d                	beqz	a4,8000094e <uartstart+0x80>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000922:	01f7f713          	andi	a4,a5,31
    80000926:	9756                	add	a4,a4,s5
    80000928:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    8000092c:	0785                	addi	a5,a5,1
    8000092e:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    80000930:	8526                	mv	a0,s1
    80000932:	5fc010ef          	jal	80001f2e <wakeup>
    WriteReg(THR, c);
    80000936:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    8000093a:	609c                	ld	a5,0(s1)
    8000093c:	0009b703          	ld	a4,0(s3)
    80000940:	fcf71ce3          	bne	a4,a5,80000918 <uartstart+0x4a>
      ReadReg(ISR);
    80000944:	100007b7          	lui	a5,0x10000
    80000948:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    8000094a:	0007c783          	lbu	a5,0(a5)
  }
}
    8000094e:	70e2                	ld	ra,56(sp)
    80000950:	7442                	ld	s0,48(sp)
    80000952:	74a2                	ld	s1,40(sp)
    80000954:	7902                	ld	s2,32(sp)
    80000956:	69e2                	ld	s3,24(sp)
    80000958:	6a42                	ld	s4,16(sp)
    8000095a:	6aa2                	ld	s5,8(sp)
    8000095c:	6b02                	ld	s6,0(sp)
    8000095e:	6121                	addi	sp,sp,64
    80000960:	8082                	ret
      ReadReg(ISR);
    80000962:	100007b7          	lui	a5,0x10000
    80000966:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000968:	0007c783          	lbu	a5,0(a5)
      return;
    8000096c:	8082                	ret

000000008000096e <uartputc>:
{
    8000096e:	7179                	addi	sp,sp,-48
    80000970:	f406                	sd	ra,40(sp)
    80000972:	f022                	sd	s0,32(sp)
    80000974:	ec26                	sd	s1,24(sp)
    80000976:	e84a                	sd	s2,16(sp)
    80000978:	e44e                	sd	s3,8(sp)
    8000097a:	e052                	sd	s4,0(sp)
    8000097c:	1800                	addi	s0,sp,48
    8000097e:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    80000980:	00012517          	auipc	a0,0x12
    80000984:	bd850513          	addi	a0,a0,-1064 # 80012558 <uart_tx_lock>
    80000988:	2a0000ef          	jal	80000c28 <acquire>
  if(panicked){
    8000098c:	0000a797          	auipc	a5,0xa
    80000990:	ac47a783          	lw	a5,-1340(a5) # 8000a450 <panicked>
    80000994:	efbd                	bnez	a5,80000a12 <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000996:	0000a717          	auipc	a4,0xa
    8000099a:	aca73703          	ld	a4,-1334(a4) # 8000a460 <uart_tx_w>
    8000099e:	0000a797          	auipc	a5,0xa
    800009a2:	aba7b783          	ld	a5,-1350(a5) # 8000a458 <uart_tx_r>
    800009a6:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800009aa:	00012997          	auipc	s3,0x12
    800009ae:	bae98993          	addi	s3,s3,-1106 # 80012558 <uart_tx_lock>
    800009b2:	0000a497          	auipc	s1,0xa
    800009b6:	aa648493          	addi	s1,s1,-1370 # 8000a458 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800009ba:	0000a917          	auipc	s2,0xa
    800009be:	aa690913          	addi	s2,s2,-1370 # 8000a460 <uart_tx_w>
    800009c2:	00e79d63          	bne	a5,a4,800009dc <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    800009c6:	85ce                	mv	a1,s3
    800009c8:	8526                	mv	a0,s1
    800009ca:	518010ef          	jal	80001ee2 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800009ce:	00093703          	ld	a4,0(s2)
    800009d2:	609c                	ld	a5,0(s1)
    800009d4:	02078793          	addi	a5,a5,32
    800009d8:	fee787e3          	beq	a5,a4,800009c6 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009dc:	00012497          	auipc	s1,0x12
    800009e0:	b7c48493          	addi	s1,s1,-1156 # 80012558 <uart_tx_lock>
    800009e4:	01f77793          	andi	a5,a4,31
    800009e8:	97a6                	add	a5,a5,s1
    800009ea:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009ee:	0705                	addi	a4,a4,1
    800009f0:	0000a797          	auipc	a5,0xa
    800009f4:	a6e7b823          	sd	a4,-1424(a5) # 8000a460 <uart_tx_w>
  uartstart();
    800009f8:	ed7ff0ef          	jal	800008ce <uartstart>
  release(&uart_tx_lock);
    800009fc:	8526                	mv	a0,s1
    800009fe:	2c2000ef          	jal	80000cc0 <release>
}
    80000a02:	70a2                	ld	ra,40(sp)
    80000a04:	7402                	ld	s0,32(sp)
    80000a06:	64e2                	ld	s1,24(sp)
    80000a08:	6942                	ld	s2,16(sp)
    80000a0a:	69a2                	ld	s3,8(sp)
    80000a0c:	6a02                	ld	s4,0(sp)
    80000a0e:	6145                	addi	sp,sp,48
    80000a10:	8082                	ret
    for(;;)
    80000a12:	a001                	j	80000a12 <uartputc+0xa4>

0000000080000a14 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000a14:	1141                	addi	sp,sp,-16
    80000a16:	e422                	sd	s0,8(sp)
    80000a18:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000a1a:	100007b7          	lui	a5,0x10000
    80000a1e:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    80000a20:	0007c783          	lbu	a5,0(a5)
    80000a24:	8b85                	andi	a5,a5,1
    80000a26:	cb81                	beqz	a5,80000a36 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    80000a28:	100007b7          	lui	a5,0x10000
    80000a2c:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    80000a30:	6422                	ld	s0,8(sp)
    80000a32:	0141                	addi	sp,sp,16
    80000a34:	8082                	ret
    return -1;
    80000a36:	557d                	li	a0,-1
    80000a38:	bfe5                	j	80000a30 <uartgetc+0x1c>

0000000080000a3a <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000a3a:	1101                	addi	sp,sp,-32
    80000a3c:	ec06                	sd	ra,24(sp)
    80000a3e:	e822                	sd	s0,16(sp)
    80000a40:	e426                	sd	s1,8(sp)
    80000a42:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a44:	54fd                	li	s1,-1
    80000a46:	a019                	j	80000a4c <uartintr+0x12>
      break;
    consoleintr(c);
    80000a48:	85fff0ef          	jal	800002a6 <consoleintr>
    int c = uartgetc();
    80000a4c:	fc9ff0ef          	jal	80000a14 <uartgetc>
    if(c == -1)
    80000a50:	fe951ce3          	bne	a0,s1,80000a48 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a54:	00012497          	auipc	s1,0x12
    80000a58:	b0448493          	addi	s1,s1,-1276 # 80012558 <uart_tx_lock>
    80000a5c:	8526                	mv	a0,s1
    80000a5e:	1ca000ef          	jal	80000c28 <acquire>
  uartstart();
    80000a62:	e6dff0ef          	jal	800008ce <uartstart>
  release(&uart_tx_lock);
    80000a66:	8526                	mv	a0,s1
    80000a68:	258000ef          	jal	80000cc0 <release>
}
    80000a6c:	60e2                	ld	ra,24(sp)
    80000a6e:	6442                	ld	s0,16(sp)
    80000a70:	64a2                	ld	s1,8(sp)
    80000a72:	6105                	addi	sp,sp,32
    80000a74:	8082                	ret

0000000080000a76 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a76:	1101                	addi	sp,sp,-32
    80000a78:	ec06                	sd	ra,24(sp)
    80000a7a:	e822                	sd	s0,16(sp)
    80000a7c:	e426                	sd	s1,8(sp)
    80000a7e:	e04a                	sd	s2,0(sp)
    80000a80:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a82:	03451793          	slli	a5,a0,0x34
    80000a86:	e7a9                	bnez	a5,80000ad0 <kfree+0x5a>
    80000a88:	84aa                	mv	s1,a0
    80000a8a:	00023797          	auipc	a5,0x23
    80000a8e:	d3678793          	addi	a5,a5,-714 # 800237c0 <end>
    80000a92:	02f56f63          	bltu	a0,a5,80000ad0 <kfree+0x5a>
    80000a96:	47c5                	li	a5,17
    80000a98:	07ee                	slli	a5,a5,0x1b
    80000a9a:	02f57b63          	bgeu	a0,a5,80000ad0 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a9e:	6605                	lui	a2,0x1
    80000aa0:	4585                	li	a1,1
    80000aa2:	25a000ef          	jal	80000cfc <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000aa6:	00012917          	auipc	s2,0x12
    80000aaa:	aea90913          	addi	s2,s2,-1302 # 80012590 <kmem>
    80000aae:	854a                	mv	a0,s2
    80000ab0:	178000ef          	jal	80000c28 <acquire>
  r->next = kmem.freelist;
    80000ab4:	01893783          	ld	a5,24(s2)
    80000ab8:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000aba:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000abe:	854a                	mv	a0,s2
    80000ac0:	200000ef          	jal	80000cc0 <release>
}
    80000ac4:	60e2                	ld	ra,24(sp)
    80000ac6:	6442                	ld	s0,16(sp)
    80000ac8:	64a2                	ld	s1,8(sp)
    80000aca:	6902                	ld	s2,0(sp)
    80000acc:	6105                	addi	sp,sp,32
    80000ace:	8082                	ret
    panic("kfree");
    80000ad0:	00006517          	auipc	a0,0x6
    80000ad4:	56850513          	addi	a0,a0,1384 # 80007038 <etext+0x38>
    80000ad8:	cf1ff0ef          	jal	800007c8 <panic>

0000000080000adc <freerange>:
{
    80000adc:	7179                	addi	sp,sp,-48
    80000ade:	f406                	sd	ra,40(sp)
    80000ae0:	f022                	sd	s0,32(sp)
    80000ae2:	ec26                	sd	s1,24(sp)
    80000ae4:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ae6:	6785                	lui	a5,0x1
    80000ae8:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000aec:	00e504b3          	add	s1,a0,a4
    80000af0:	777d                	lui	a4,0xfffff
    80000af2:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000af4:	94be                	add	s1,s1,a5
    80000af6:	0295e263          	bltu	a1,s1,80000b1a <freerange+0x3e>
    80000afa:	e84a                	sd	s2,16(sp)
    80000afc:	e44e                	sd	s3,8(sp)
    80000afe:	e052                	sd	s4,0(sp)
    80000b00:	892e                	mv	s2,a1
    kfree(p);
    80000b02:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b04:	6985                	lui	s3,0x1
    kfree(p);
    80000b06:	01448533          	add	a0,s1,s4
    80000b0a:	f6dff0ef          	jal	80000a76 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b0e:	94ce                	add	s1,s1,s3
    80000b10:	fe997be3          	bgeu	s2,s1,80000b06 <freerange+0x2a>
    80000b14:	6942                	ld	s2,16(sp)
    80000b16:	69a2                	ld	s3,8(sp)
    80000b18:	6a02                	ld	s4,0(sp)
}
    80000b1a:	70a2                	ld	ra,40(sp)
    80000b1c:	7402                	ld	s0,32(sp)
    80000b1e:	64e2                	ld	s1,24(sp)
    80000b20:	6145                	addi	sp,sp,48
    80000b22:	8082                	ret

0000000080000b24 <kinit>:
{
    80000b24:	1141                	addi	sp,sp,-16
    80000b26:	e406                	sd	ra,8(sp)
    80000b28:	e022                	sd	s0,0(sp)
    80000b2a:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b2c:	00006597          	auipc	a1,0x6
    80000b30:	51458593          	addi	a1,a1,1300 # 80007040 <etext+0x40>
    80000b34:	00012517          	auipc	a0,0x12
    80000b38:	a5c50513          	addi	a0,a0,-1444 # 80012590 <kmem>
    80000b3c:	06c000ef          	jal	80000ba8 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b40:	45c5                	li	a1,17
    80000b42:	05ee                	slli	a1,a1,0x1b
    80000b44:	00023517          	auipc	a0,0x23
    80000b48:	c7c50513          	addi	a0,a0,-900 # 800237c0 <end>
    80000b4c:	f91ff0ef          	jal	80000adc <freerange>
}
    80000b50:	60a2                	ld	ra,8(sp)
    80000b52:	6402                	ld	s0,0(sp)
    80000b54:	0141                	addi	sp,sp,16
    80000b56:	8082                	ret

0000000080000b58 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b58:	1101                	addi	sp,sp,-32
    80000b5a:	ec06                	sd	ra,24(sp)
    80000b5c:	e822                	sd	s0,16(sp)
    80000b5e:	e426                	sd	s1,8(sp)
    80000b60:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b62:	00012497          	auipc	s1,0x12
    80000b66:	a2e48493          	addi	s1,s1,-1490 # 80012590 <kmem>
    80000b6a:	8526                	mv	a0,s1
    80000b6c:	0bc000ef          	jal	80000c28 <acquire>
  r = kmem.freelist;
    80000b70:	6c84                	ld	s1,24(s1)
  if(r)
    80000b72:	c485                	beqz	s1,80000b9a <kalloc+0x42>
    kmem.freelist = r->next;
    80000b74:	609c                	ld	a5,0(s1)
    80000b76:	00012517          	auipc	a0,0x12
    80000b7a:	a1a50513          	addi	a0,a0,-1510 # 80012590 <kmem>
    80000b7e:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b80:	140000ef          	jal	80000cc0 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b84:	6605                	lui	a2,0x1
    80000b86:	4595                	li	a1,5
    80000b88:	8526                	mv	a0,s1
    80000b8a:	172000ef          	jal	80000cfc <memset>
  return (void*)r;
}
    80000b8e:	8526                	mv	a0,s1
    80000b90:	60e2                	ld	ra,24(sp)
    80000b92:	6442                	ld	s0,16(sp)
    80000b94:	64a2                	ld	s1,8(sp)
    80000b96:	6105                	addi	sp,sp,32
    80000b98:	8082                	ret
  release(&kmem.lock);
    80000b9a:	00012517          	auipc	a0,0x12
    80000b9e:	9f650513          	addi	a0,a0,-1546 # 80012590 <kmem>
    80000ba2:	11e000ef          	jal	80000cc0 <release>
  if(r)
    80000ba6:	b7e5                	j	80000b8e <kalloc+0x36>

0000000080000ba8 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000ba8:	1141                	addi	sp,sp,-16
    80000baa:	e422                	sd	s0,8(sp)
    80000bac:	0800                	addi	s0,sp,16
  lk->name = name;
    80000bae:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bb0:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bb4:	00053823          	sd	zero,16(a0)
}
    80000bb8:	6422                	ld	s0,8(sp)
    80000bba:	0141                	addi	sp,sp,16
    80000bbc:	8082                	ret

0000000080000bbe <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bbe:	411c                	lw	a5,0(a0)
    80000bc0:	e399                	bnez	a5,80000bc6 <holding+0x8>
    80000bc2:	4501                	li	a0,0
  return r;
}
    80000bc4:	8082                	ret
{
    80000bc6:	1101                	addi	sp,sp,-32
    80000bc8:	ec06                	sd	ra,24(sp)
    80000bca:	e822                	sd	s0,16(sp)
    80000bcc:	e426                	sd	s1,8(sp)
    80000bce:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bd0:	6904                	ld	s1,16(a0)
    80000bd2:	527000ef          	jal	800018f8 <mycpu>
    80000bd6:	40a48533          	sub	a0,s1,a0
    80000bda:	00153513          	seqz	a0,a0
}
    80000bde:	60e2                	ld	ra,24(sp)
    80000be0:	6442                	ld	s0,16(sp)
    80000be2:	64a2                	ld	s1,8(sp)
    80000be4:	6105                	addi	sp,sp,32
    80000be6:	8082                	ret

0000000080000be8 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000be8:	1101                	addi	sp,sp,-32
    80000bea:	ec06                	sd	ra,24(sp)
    80000bec:	e822                	sd	s0,16(sp)
    80000bee:	e426                	sd	s1,8(sp)
    80000bf0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bf2:	100024f3          	csrr	s1,sstatus
    80000bf6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bfa:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bfc:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c00:	4f9000ef          	jal	800018f8 <mycpu>
    80000c04:	5d3c                	lw	a5,120(a0)
    80000c06:	cb99                	beqz	a5,80000c1c <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c08:	4f1000ef          	jal	800018f8 <mycpu>
    80000c0c:	5d3c                	lw	a5,120(a0)
    80000c0e:	2785                	addiw	a5,a5,1
    80000c10:	dd3c                	sw	a5,120(a0)
}
    80000c12:	60e2                	ld	ra,24(sp)
    80000c14:	6442                	ld	s0,16(sp)
    80000c16:	64a2                	ld	s1,8(sp)
    80000c18:	6105                	addi	sp,sp,32
    80000c1a:	8082                	ret
    mycpu()->intena = old;
    80000c1c:	4dd000ef          	jal	800018f8 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c20:	8085                	srli	s1,s1,0x1
    80000c22:	8885                	andi	s1,s1,1
    80000c24:	dd64                	sw	s1,124(a0)
    80000c26:	b7cd                	j	80000c08 <push_off+0x20>

0000000080000c28 <acquire>:
{
    80000c28:	1101                	addi	sp,sp,-32
    80000c2a:	ec06                	sd	ra,24(sp)
    80000c2c:	e822                	sd	s0,16(sp)
    80000c2e:	e426                	sd	s1,8(sp)
    80000c30:	1000                	addi	s0,sp,32
    80000c32:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c34:	fb5ff0ef          	jal	80000be8 <push_off>
  if(holding(lk))
    80000c38:	8526                	mv	a0,s1
    80000c3a:	f85ff0ef          	jal	80000bbe <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c3e:	4705                	li	a4,1
  if(holding(lk))
    80000c40:	e105                	bnez	a0,80000c60 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c42:	87ba                	mv	a5,a4
    80000c44:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c48:	2781                	sext.w	a5,a5
    80000c4a:	ffe5                	bnez	a5,80000c42 <acquire+0x1a>
  __sync_synchronize();
    80000c4c:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000c50:	4a9000ef          	jal	800018f8 <mycpu>
    80000c54:	e888                	sd	a0,16(s1)
}
    80000c56:	60e2                	ld	ra,24(sp)
    80000c58:	6442                	ld	s0,16(sp)
    80000c5a:	64a2                	ld	s1,8(sp)
    80000c5c:	6105                	addi	sp,sp,32
    80000c5e:	8082                	ret
    panic("acquire");
    80000c60:	00006517          	auipc	a0,0x6
    80000c64:	3e850513          	addi	a0,a0,1000 # 80007048 <etext+0x48>
    80000c68:	b61ff0ef          	jal	800007c8 <panic>

0000000080000c6c <pop_off>:

void
pop_off(void)
{
    80000c6c:	1141                	addi	sp,sp,-16
    80000c6e:	e406                	sd	ra,8(sp)
    80000c70:	e022                	sd	s0,0(sp)
    80000c72:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c74:	485000ef          	jal	800018f8 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c78:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c7c:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c7e:	e78d                	bnez	a5,80000ca8 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c80:	5d3c                	lw	a5,120(a0)
    80000c82:	02f05963          	blez	a5,80000cb4 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000c86:	37fd                	addiw	a5,a5,-1
    80000c88:	0007871b          	sext.w	a4,a5
    80000c8c:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c8e:	eb09                	bnez	a4,80000ca0 <pop_off+0x34>
    80000c90:	5d7c                	lw	a5,124(a0)
    80000c92:	c799                	beqz	a5,80000ca0 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c94:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c98:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c9c:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000ca0:	60a2                	ld	ra,8(sp)
    80000ca2:	6402                	ld	s0,0(sp)
    80000ca4:	0141                	addi	sp,sp,16
    80000ca6:	8082                	ret
    panic("pop_off - interruptible");
    80000ca8:	00006517          	auipc	a0,0x6
    80000cac:	3a850513          	addi	a0,a0,936 # 80007050 <etext+0x50>
    80000cb0:	b19ff0ef          	jal	800007c8 <panic>
    panic("pop_off");
    80000cb4:	00006517          	auipc	a0,0x6
    80000cb8:	3b450513          	addi	a0,a0,948 # 80007068 <etext+0x68>
    80000cbc:	b0dff0ef          	jal	800007c8 <panic>

0000000080000cc0 <release>:
{
    80000cc0:	1101                	addi	sp,sp,-32
    80000cc2:	ec06                	sd	ra,24(sp)
    80000cc4:	e822                	sd	s0,16(sp)
    80000cc6:	e426                	sd	s1,8(sp)
    80000cc8:	1000                	addi	s0,sp,32
    80000cca:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000ccc:	ef3ff0ef          	jal	80000bbe <holding>
    80000cd0:	c105                	beqz	a0,80000cf0 <release+0x30>
  lk->cpu = 0;
    80000cd2:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cd6:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000cda:	0310000f          	fence	rw,w
    80000cde:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000ce2:	f8bff0ef          	jal	80000c6c <pop_off>
}
    80000ce6:	60e2                	ld	ra,24(sp)
    80000ce8:	6442                	ld	s0,16(sp)
    80000cea:	64a2                	ld	s1,8(sp)
    80000cec:	6105                	addi	sp,sp,32
    80000cee:	8082                	ret
    panic("release");
    80000cf0:	00006517          	auipc	a0,0x6
    80000cf4:	38050513          	addi	a0,a0,896 # 80007070 <etext+0x70>
    80000cf8:	ad1ff0ef          	jal	800007c8 <panic>

0000000080000cfc <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cfc:	1141                	addi	sp,sp,-16
    80000cfe:	e422                	sd	s0,8(sp)
    80000d00:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d02:	ca19                	beqz	a2,80000d18 <memset+0x1c>
    80000d04:	87aa                	mv	a5,a0
    80000d06:	1602                	slli	a2,a2,0x20
    80000d08:	9201                	srli	a2,a2,0x20
    80000d0a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d0e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d12:	0785                	addi	a5,a5,1
    80000d14:	fee79de3          	bne	a5,a4,80000d0e <memset+0x12>
  }
  return dst;
}
    80000d18:	6422                	ld	s0,8(sp)
    80000d1a:	0141                	addi	sp,sp,16
    80000d1c:	8082                	ret

0000000080000d1e <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d1e:	1141                	addi	sp,sp,-16
    80000d20:	e422                	sd	s0,8(sp)
    80000d22:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d24:	ca05                	beqz	a2,80000d54 <memcmp+0x36>
    80000d26:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d2a:	1682                	slli	a3,a3,0x20
    80000d2c:	9281                	srli	a3,a3,0x20
    80000d2e:	0685                	addi	a3,a3,1
    80000d30:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d32:	00054783          	lbu	a5,0(a0)
    80000d36:	0005c703          	lbu	a4,0(a1)
    80000d3a:	00e79863          	bne	a5,a4,80000d4a <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d3e:	0505                	addi	a0,a0,1
    80000d40:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d42:	fed518e3          	bne	a0,a3,80000d32 <memcmp+0x14>
  }

  return 0;
    80000d46:	4501                	li	a0,0
    80000d48:	a019                	j	80000d4e <memcmp+0x30>
      return *s1 - *s2;
    80000d4a:	40e7853b          	subw	a0,a5,a4
}
    80000d4e:	6422                	ld	s0,8(sp)
    80000d50:	0141                	addi	sp,sp,16
    80000d52:	8082                	ret
  return 0;
    80000d54:	4501                	li	a0,0
    80000d56:	bfe5                	j	80000d4e <memcmp+0x30>

0000000080000d58 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d58:	1141                	addi	sp,sp,-16
    80000d5a:	e422                	sd	s0,8(sp)
    80000d5c:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d5e:	c205                	beqz	a2,80000d7e <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d60:	02a5e263          	bltu	a1,a0,80000d84 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d64:	1602                	slli	a2,a2,0x20
    80000d66:	9201                	srli	a2,a2,0x20
    80000d68:	00c587b3          	add	a5,a1,a2
{
    80000d6c:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d6e:	0585                	addi	a1,a1,1
    80000d70:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdb841>
    80000d72:	fff5c683          	lbu	a3,-1(a1)
    80000d76:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d7a:	feb79ae3          	bne	a5,a1,80000d6e <memmove+0x16>

  return dst;
}
    80000d7e:	6422                	ld	s0,8(sp)
    80000d80:	0141                	addi	sp,sp,16
    80000d82:	8082                	ret
  if(s < d && s + n > d){
    80000d84:	02061693          	slli	a3,a2,0x20
    80000d88:	9281                	srli	a3,a3,0x20
    80000d8a:	00d58733          	add	a4,a1,a3
    80000d8e:	fce57be3          	bgeu	a0,a4,80000d64 <memmove+0xc>
    d += n;
    80000d92:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d94:	fff6079b          	addiw	a5,a2,-1
    80000d98:	1782                	slli	a5,a5,0x20
    80000d9a:	9381                	srli	a5,a5,0x20
    80000d9c:	fff7c793          	not	a5,a5
    80000da0:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000da2:	177d                	addi	a4,a4,-1
    80000da4:	16fd                	addi	a3,a3,-1
    80000da6:	00074603          	lbu	a2,0(a4)
    80000daa:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000dae:	fef71ae3          	bne	a4,a5,80000da2 <memmove+0x4a>
    80000db2:	b7f1                	j	80000d7e <memmove+0x26>

0000000080000db4 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000db4:	1141                	addi	sp,sp,-16
    80000db6:	e406                	sd	ra,8(sp)
    80000db8:	e022                	sd	s0,0(sp)
    80000dba:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000dbc:	f9dff0ef          	jal	80000d58 <memmove>
}
    80000dc0:	60a2                	ld	ra,8(sp)
    80000dc2:	6402                	ld	s0,0(sp)
    80000dc4:	0141                	addi	sp,sp,16
    80000dc6:	8082                	ret

0000000080000dc8 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000dc8:	1141                	addi	sp,sp,-16
    80000dca:	e422                	sd	s0,8(sp)
    80000dcc:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dce:	ce11                	beqz	a2,80000dea <strncmp+0x22>
    80000dd0:	00054783          	lbu	a5,0(a0)
    80000dd4:	cf89                	beqz	a5,80000dee <strncmp+0x26>
    80000dd6:	0005c703          	lbu	a4,0(a1)
    80000dda:	00f71a63          	bne	a4,a5,80000dee <strncmp+0x26>
    n--, p++, q++;
    80000dde:	367d                	addiw	a2,a2,-1
    80000de0:	0505                	addi	a0,a0,1
    80000de2:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000de4:	f675                	bnez	a2,80000dd0 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000de6:	4501                	li	a0,0
    80000de8:	a801                	j	80000df8 <strncmp+0x30>
    80000dea:	4501                	li	a0,0
    80000dec:	a031                	j	80000df8 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000dee:	00054503          	lbu	a0,0(a0)
    80000df2:	0005c783          	lbu	a5,0(a1)
    80000df6:	9d1d                	subw	a0,a0,a5
}
    80000df8:	6422                	ld	s0,8(sp)
    80000dfa:	0141                	addi	sp,sp,16
    80000dfc:	8082                	ret

0000000080000dfe <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dfe:	1141                	addi	sp,sp,-16
    80000e00:	e422                	sd	s0,8(sp)
    80000e02:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e04:	87aa                	mv	a5,a0
    80000e06:	86b2                	mv	a3,a2
    80000e08:	367d                	addiw	a2,a2,-1
    80000e0a:	02d05563          	blez	a3,80000e34 <strncpy+0x36>
    80000e0e:	0785                	addi	a5,a5,1
    80000e10:	0005c703          	lbu	a4,0(a1)
    80000e14:	fee78fa3          	sb	a4,-1(a5)
    80000e18:	0585                	addi	a1,a1,1
    80000e1a:	f775                	bnez	a4,80000e06 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e1c:	873e                	mv	a4,a5
    80000e1e:	9fb5                	addw	a5,a5,a3
    80000e20:	37fd                	addiw	a5,a5,-1
    80000e22:	00c05963          	blez	a2,80000e34 <strncpy+0x36>
    *s++ = 0;
    80000e26:	0705                	addi	a4,a4,1
    80000e28:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e2c:	40e786bb          	subw	a3,a5,a4
    80000e30:	fed04be3          	bgtz	a3,80000e26 <strncpy+0x28>
  return os;
}
    80000e34:	6422                	ld	s0,8(sp)
    80000e36:	0141                	addi	sp,sp,16
    80000e38:	8082                	ret

0000000080000e3a <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e3a:	1141                	addi	sp,sp,-16
    80000e3c:	e422                	sd	s0,8(sp)
    80000e3e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e40:	02c05363          	blez	a2,80000e66 <safestrcpy+0x2c>
    80000e44:	fff6069b          	addiw	a3,a2,-1
    80000e48:	1682                	slli	a3,a3,0x20
    80000e4a:	9281                	srli	a3,a3,0x20
    80000e4c:	96ae                	add	a3,a3,a1
    80000e4e:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e50:	00d58963          	beq	a1,a3,80000e62 <safestrcpy+0x28>
    80000e54:	0585                	addi	a1,a1,1
    80000e56:	0785                	addi	a5,a5,1
    80000e58:	fff5c703          	lbu	a4,-1(a1)
    80000e5c:	fee78fa3          	sb	a4,-1(a5)
    80000e60:	fb65                	bnez	a4,80000e50 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e62:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e66:	6422                	ld	s0,8(sp)
    80000e68:	0141                	addi	sp,sp,16
    80000e6a:	8082                	ret

0000000080000e6c <strlen>:

int
strlen(const char *s)
{
    80000e6c:	1141                	addi	sp,sp,-16
    80000e6e:	e422                	sd	s0,8(sp)
    80000e70:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e72:	00054783          	lbu	a5,0(a0)
    80000e76:	cf91                	beqz	a5,80000e92 <strlen+0x26>
    80000e78:	0505                	addi	a0,a0,1
    80000e7a:	87aa                	mv	a5,a0
    80000e7c:	86be                	mv	a3,a5
    80000e7e:	0785                	addi	a5,a5,1
    80000e80:	fff7c703          	lbu	a4,-1(a5)
    80000e84:	ff65                	bnez	a4,80000e7c <strlen+0x10>
    80000e86:	40a6853b          	subw	a0,a3,a0
    80000e8a:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e8c:	6422                	ld	s0,8(sp)
    80000e8e:	0141                	addi	sp,sp,16
    80000e90:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e92:	4501                	li	a0,0
    80000e94:	bfe5                	j	80000e8c <strlen+0x20>

0000000080000e96 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e96:	1141                	addi	sp,sp,-16
    80000e98:	e406                	sd	ra,8(sp)
    80000e9a:	e022                	sd	s0,0(sp)
    80000e9c:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e9e:	24b000ef          	jal	800018e8 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000ea2:	00009717          	auipc	a4,0x9
    80000ea6:	5c670713          	addi	a4,a4,1478 # 8000a468 <started>
  if(cpuid() == 0){
    80000eaa:	c51d                	beqz	a0,80000ed8 <main+0x42>
    while(started == 0)
    80000eac:	431c                	lw	a5,0(a4)
    80000eae:	2781                	sext.w	a5,a5
    80000eb0:	dff5                	beqz	a5,80000eac <main+0x16>
      ;
    __sync_synchronize();
    80000eb2:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000eb6:	233000ef          	jal	800018e8 <cpuid>
    80000eba:	85aa                	mv	a1,a0
    80000ebc:	00006517          	auipc	a0,0x6
    80000ec0:	1dc50513          	addi	a0,a0,476 # 80007098 <etext+0x98>
    80000ec4:	e32ff0ef          	jal	800004f6 <printf>
    kvminithart();    // turn on paging
    80000ec8:	080000ef          	jal	80000f48 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ecc:	746010ef          	jal	80002612 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ed0:	7a8040ef          	jal	80005678 <plicinithart>
  }

  scheduler();        
    80000ed4:	675000ef          	jal	80001d48 <scheduler>
    consoleinit();
    80000ed8:	d48ff0ef          	jal	80000420 <consoleinit>
    printfinit();
    80000edc:	927ff0ef          	jal	80000802 <printfinit>
    printf("\n");
    80000ee0:	00006517          	auipc	a0,0x6
    80000ee4:	19850513          	addi	a0,a0,408 # 80007078 <etext+0x78>
    80000ee8:	e0eff0ef          	jal	800004f6 <printf>
    printf("xv6 kernel is booting\n");
    80000eec:	00006517          	auipc	a0,0x6
    80000ef0:	19450513          	addi	a0,a0,404 # 80007080 <etext+0x80>
    80000ef4:	e02ff0ef          	jal	800004f6 <printf>
    printf("\n");
    80000ef8:	00006517          	auipc	a0,0x6
    80000efc:	18050513          	addi	a0,a0,384 # 80007078 <etext+0x78>
    80000f00:	df6ff0ef          	jal	800004f6 <printf>
    kinit();         // physical page allocator
    80000f04:	c21ff0ef          	jal	80000b24 <kinit>
    kvminit();       // create kernel page table
    80000f08:	2ca000ef          	jal	800011d2 <kvminit>
    kvminithart();   // turn on paging
    80000f0c:	03c000ef          	jal	80000f48 <kvminithart>
    procinit();      // process table
    80000f10:	123000ef          	jal	80001832 <procinit>
    trapinit();      // trap vectors
    80000f14:	6da010ef          	jal	800025ee <trapinit>
    trapinithart();  // install kernel trap vector
    80000f18:	6fa010ef          	jal	80002612 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f1c:	742040ef          	jal	8000565e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f20:	758040ef          	jal	80005678 <plicinithart>
    binit();         // buffer cache
    80000f24:	6ff010ef          	jal	80002e22 <binit>
    iinit();         // inode table
    80000f28:	4f0020ef          	jal	80003418 <iinit>
    fileinit();      // file table
    80000f2c:	29c030ef          	jal	800041c8 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f30:	039040ef          	jal	80005768 <virtio_disk_init>
    userinit();      // first user process
    80000f34:	449000ef          	jal	80001b7c <userinit>
    __sync_synchronize();
    80000f38:	0330000f          	fence	rw,rw
    started = 1;
    80000f3c:	4785                	li	a5,1
    80000f3e:	00009717          	auipc	a4,0x9
    80000f42:	52f72523          	sw	a5,1322(a4) # 8000a468 <started>
    80000f46:	b779                	j	80000ed4 <main+0x3e>

0000000080000f48 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f48:	1141                	addi	sp,sp,-16
    80000f4a:	e422                	sd	s0,8(sp)
    80000f4c:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f4e:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f52:	00009797          	auipc	a5,0x9
    80000f56:	51e7b783          	ld	a5,1310(a5) # 8000a470 <kernel_pagetable>
    80000f5a:	83b1                	srli	a5,a5,0xc
    80000f5c:	577d                	li	a4,-1
    80000f5e:	177e                	slli	a4,a4,0x3f
    80000f60:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f62:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f66:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f6a:	6422                	ld	s0,8(sp)
    80000f6c:	0141                	addi	sp,sp,16
    80000f6e:	8082                	ret

0000000080000f70 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f70:	7139                	addi	sp,sp,-64
    80000f72:	fc06                	sd	ra,56(sp)
    80000f74:	f822                	sd	s0,48(sp)
    80000f76:	f426                	sd	s1,40(sp)
    80000f78:	f04a                	sd	s2,32(sp)
    80000f7a:	ec4e                	sd	s3,24(sp)
    80000f7c:	e852                	sd	s4,16(sp)
    80000f7e:	e456                	sd	s5,8(sp)
    80000f80:	e05a                	sd	s6,0(sp)
    80000f82:	0080                	addi	s0,sp,64
    80000f84:	84aa                	mv	s1,a0
    80000f86:	89ae                	mv	s3,a1
    80000f88:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000f8a:	57fd                	li	a5,-1
    80000f8c:	83e9                	srli	a5,a5,0x1a
    80000f8e:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000f90:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000f92:	02b7fc63          	bgeu	a5,a1,80000fca <walk+0x5a>
    panic("walk");
    80000f96:	00006517          	auipc	a0,0x6
    80000f9a:	11a50513          	addi	a0,a0,282 # 800070b0 <etext+0xb0>
    80000f9e:	82bff0ef          	jal	800007c8 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fa2:	060a8263          	beqz	s5,80001006 <walk+0x96>
    80000fa6:	bb3ff0ef          	jal	80000b58 <kalloc>
    80000faa:	84aa                	mv	s1,a0
    80000fac:	c139                	beqz	a0,80000ff2 <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000fae:	6605                	lui	a2,0x1
    80000fb0:	4581                	li	a1,0
    80000fb2:	d4bff0ef          	jal	80000cfc <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000fb6:	00c4d793          	srli	a5,s1,0xc
    80000fba:	07aa                	slli	a5,a5,0xa
    80000fbc:	0017e793          	ori	a5,a5,1
    80000fc0:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000fc4:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdb837>
    80000fc6:	036a0063          	beq	s4,s6,80000fe6 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000fca:	0149d933          	srl	s2,s3,s4
    80000fce:	1ff97913          	andi	s2,s2,511
    80000fd2:	090e                	slli	s2,s2,0x3
    80000fd4:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000fd6:	00093483          	ld	s1,0(s2)
    80000fda:	0014f793          	andi	a5,s1,1
    80000fde:	d3f1                	beqz	a5,80000fa2 <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000fe0:	80a9                	srli	s1,s1,0xa
    80000fe2:	04b2                	slli	s1,s1,0xc
    80000fe4:	b7c5                	j	80000fc4 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000fe6:	00c9d513          	srli	a0,s3,0xc
    80000fea:	1ff57513          	andi	a0,a0,511
    80000fee:	050e                	slli	a0,a0,0x3
    80000ff0:	9526                	add	a0,a0,s1
}
    80000ff2:	70e2                	ld	ra,56(sp)
    80000ff4:	7442                	ld	s0,48(sp)
    80000ff6:	74a2                	ld	s1,40(sp)
    80000ff8:	7902                	ld	s2,32(sp)
    80000ffa:	69e2                	ld	s3,24(sp)
    80000ffc:	6a42                	ld	s4,16(sp)
    80000ffe:	6aa2                	ld	s5,8(sp)
    80001000:	6b02                	ld	s6,0(sp)
    80001002:	6121                	addi	sp,sp,64
    80001004:	8082                	ret
        return 0;
    80001006:	4501                	li	a0,0
    80001008:	b7ed                	j	80000ff2 <walk+0x82>

000000008000100a <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000100a:	57fd                	li	a5,-1
    8000100c:	83e9                	srli	a5,a5,0x1a
    8000100e:	00b7f463          	bgeu	a5,a1,80001016 <walkaddr+0xc>
    return 0;
    80001012:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001014:	8082                	ret
{
    80001016:	1141                	addi	sp,sp,-16
    80001018:	e406                	sd	ra,8(sp)
    8000101a:	e022                	sd	s0,0(sp)
    8000101c:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000101e:	4601                	li	a2,0
    80001020:	f51ff0ef          	jal	80000f70 <walk>
  if(pte == 0)
    80001024:	c105                	beqz	a0,80001044 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80001026:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001028:	0117f693          	andi	a3,a5,17
    8000102c:	4745                	li	a4,17
    return 0;
    8000102e:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001030:	00e68663          	beq	a3,a4,8000103c <walkaddr+0x32>
}
    80001034:	60a2                	ld	ra,8(sp)
    80001036:	6402                	ld	s0,0(sp)
    80001038:	0141                	addi	sp,sp,16
    8000103a:	8082                	ret
  pa = PTE2PA(*pte);
    8000103c:	83a9                	srli	a5,a5,0xa
    8000103e:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001042:	bfcd                	j	80001034 <walkaddr+0x2a>
    return 0;
    80001044:	4501                	li	a0,0
    80001046:	b7fd                	j	80001034 <walkaddr+0x2a>

0000000080001048 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001048:	715d                	addi	sp,sp,-80
    8000104a:	e486                	sd	ra,72(sp)
    8000104c:	e0a2                	sd	s0,64(sp)
    8000104e:	fc26                	sd	s1,56(sp)
    80001050:	f84a                	sd	s2,48(sp)
    80001052:	f44e                	sd	s3,40(sp)
    80001054:	f052                	sd	s4,32(sp)
    80001056:	ec56                	sd	s5,24(sp)
    80001058:	e85a                	sd	s6,16(sp)
    8000105a:	e45e                	sd	s7,8(sp)
    8000105c:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000105e:	03459793          	slli	a5,a1,0x34
    80001062:	e7a9                	bnez	a5,800010ac <mappages+0x64>
    80001064:	8aaa                	mv	s5,a0
    80001066:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001068:	03461793          	slli	a5,a2,0x34
    8000106c:	e7b1                	bnez	a5,800010b8 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    8000106e:	ca39                	beqz	a2,800010c4 <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80001070:	77fd                	lui	a5,0xfffff
    80001072:	963e                	add	a2,a2,a5
    80001074:	00b609b3          	add	s3,a2,a1
  a = va;
    80001078:	892e                	mv	s2,a1
    8000107a:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000107e:	6b85                	lui	s7,0x1
    80001080:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80001084:	4605                	li	a2,1
    80001086:	85ca                	mv	a1,s2
    80001088:	8556                	mv	a0,s5
    8000108a:	ee7ff0ef          	jal	80000f70 <walk>
    8000108e:	c539                	beqz	a0,800010dc <mappages+0x94>
    if(*pte & PTE_V)
    80001090:	611c                	ld	a5,0(a0)
    80001092:	8b85                	andi	a5,a5,1
    80001094:	ef95                	bnez	a5,800010d0 <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001096:	80b1                	srli	s1,s1,0xc
    80001098:	04aa                	slli	s1,s1,0xa
    8000109a:	0164e4b3          	or	s1,s1,s6
    8000109e:	0014e493          	ori	s1,s1,1
    800010a2:	e104                	sd	s1,0(a0)
    if(a == last)
    800010a4:	05390863          	beq	s2,s3,800010f4 <mappages+0xac>
    a += PGSIZE;
    800010a8:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010aa:	bfd9                	j	80001080 <mappages+0x38>
    panic("mappages: va not aligned");
    800010ac:	00006517          	auipc	a0,0x6
    800010b0:	00c50513          	addi	a0,a0,12 # 800070b8 <etext+0xb8>
    800010b4:	f14ff0ef          	jal	800007c8 <panic>
    panic("mappages: size not aligned");
    800010b8:	00006517          	auipc	a0,0x6
    800010bc:	02050513          	addi	a0,a0,32 # 800070d8 <etext+0xd8>
    800010c0:	f08ff0ef          	jal	800007c8 <panic>
    panic("mappages: size");
    800010c4:	00006517          	auipc	a0,0x6
    800010c8:	03450513          	addi	a0,a0,52 # 800070f8 <etext+0xf8>
    800010cc:	efcff0ef          	jal	800007c8 <panic>
      panic("mappages: remap");
    800010d0:	00006517          	auipc	a0,0x6
    800010d4:	03850513          	addi	a0,a0,56 # 80007108 <etext+0x108>
    800010d8:	ef0ff0ef          	jal	800007c8 <panic>
      return -1;
    800010dc:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010de:	60a6                	ld	ra,72(sp)
    800010e0:	6406                	ld	s0,64(sp)
    800010e2:	74e2                	ld	s1,56(sp)
    800010e4:	7942                	ld	s2,48(sp)
    800010e6:	79a2                	ld	s3,40(sp)
    800010e8:	7a02                	ld	s4,32(sp)
    800010ea:	6ae2                	ld	s5,24(sp)
    800010ec:	6b42                	ld	s6,16(sp)
    800010ee:	6ba2                	ld	s7,8(sp)
    800010f0:	6161                	addi	sp,sp,80
    800010f2:	8082                	ret
  return 0;
    800010f4:	4501                	li	a0,0
    800010f6:	b7e5                	j	800010de <mappages+0x96>

00000000800010f8 <kvmmap>:
{
    800010f8:	1141                	addi	sp,sp,-16
    800010fa:	e406                	sd	ra,8(sp)
    800010fc:	e022                	sd	s0,0(sp)
    800010fe:	0800                	addi	s0,sp,16
    80001100:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001102:	86b2                	mv	a3,a2
    80001104:	863e                	mv	a2,a5
    80001106:	f43ff0ef          	jal	80001048 <mappages>
    8000110a:	e509                	bnez	a0,80001114 <kvmmap+0x1c>
}
    8000110c:	60a2                	ld	ra,8(sp)
    8000110e:	6402                	ld	s0,0(sp)
    80001110:	0141                	addi	sp,sp,16
    80001112:	8082                	ret
    panic("kvmmap");
    80001114:	00006517          	auipc	a0,0x6
    80001118:	00450513          	addi	a0,a0,4 # 80007118 <etext+0x118>
    8000111c:	eacff0ef          	jal	800007c8 <panic>

0000000080001120 <kvmmake>:
{
    80001120:	1101                	addi	sp,sp,-32
    80001122:	ec06                	sd	ra,24(sp)
    80001124:	e822                	sd	s0,16(sp)
    80001126:	e426                	sd	s1,8(sp)
    80001128:	e04a                	sd	s2,0(sp)
    8000112a:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000112c:	a2dff0ef          	jal	80000b58 <kalloc>
    80001130:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001132:	6605                	lui	a2,0x1
    80001134:	4581                	li	a1,0
    80001136:	bc7ff0ef          	jal	80000cfc <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000113a:	4719                	li	a4,6
    8000113c:	6685                	lui	a3,0x1
    8000113e:	10000637          	lui	a2,0x10000
    80001142:	100005b7          	lui	a1,0x10000
    80001146:	8526                	mv	a0,s1
    80001148:	fb1ff0ef          	jal	800010f8 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000114c:	4719                	li	a4,6
    8000114e:	6685                	lui	a3,0x1
    80001150:	10001637          	lui	a2,0x10001
    80001154:	100015b7          	lui	a1,0x10001
    80001158:	8526                	mv	a0,s1
    8000115a:	f9fff0ef          	jal	800010f8 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    8000115e:	4719                	li	a4,6
    80001160:	040006b7          	lui	a3,0x4000
    80001164:	0c000637          	lui	a2,0xc000
    80001168:	0c0005b7          	lui	a1,0xc000
    8000116c:	8526                	mv	a0,s1
    8000116e:	f8bff0ef          	jal	800010f8 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001172:	00006917          	auipc	s2,0x6
    80001176:	e8e90913          	addi	s2,s2,-370 # 80007000 <etext>
    8000117a:	4729                	li	a4,10
    8000117c:	80006697          	auipc	a3,0x80006
    80001180:	e8468693          	addi	a3,a3,-380 # 7000 <_entry-0x7fff9000>
    80001184:	4605                	li	a2,1
    80001186:	067e                	slli	a2,a2,0x1f
    80001188:	85b2                	mv	a1,a2
    8000118a:	8526                	mv	a0,s1
    8000118c:	f6dff0ef          	jal	800010f8 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001190:	46c5                	li	a3,17
    80001192:	06ee                	slli	a3,a3,0x1b
    80001194:	4719                	li	a4,6
    80001196:	412686b3          	sub	a3,a3,s2
    8000119a:	864a                	mv	a2,s2
    8000119c:	85ca                	mv	a1,s2
    8000119e:	8526                	mv	a0,s1
    800011a0:	f59ff0ef          	jal	800010f8 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011a4:	4729                	li	a4,10
    800011a6:	6685                	lui	a3,0x1
    800011a8:	00005617          	auipc	a2,0x5
    800011ac:	e5860613          	addi	a2,a2,-424 # 80006000 <_trampoline>
    800011b0:	040005b7          	lui	a1,0x4000
    800011b4:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800011b6:	05b2                	slli	a1,a1,0xc
    800011b8:	8526                	mv	a0,s1
    800011ba:	f3fff0ef          	jal	800010f8 <kvmmap>
  proc_mapstacks(kpgtbl);
    800011be:	8526                	mv	a0,s1
    800011c0:	5da000ef          	jal	8000179a <proc_mapstacks>
}
    800011c4:	8526                	mv	a0,s1
    800011c6:	60e2                	ld	ra,24(sp)
    800011c8:	6442                	ld	s0,16(sp)
    800011ca:	64a2                	ld	s1,8(sp)
    800011cc:	6902                	ld	s2,0(sp)
    800011ce:	6105                	addi	sp,sp,32
    800011d0:	8082                	ret

00000000800011d2 <kvminit>:
{
    800011d2:	1141                	addi	sp,sp,-16
    800011d4:	e406                	sd	ra,8(sp)
    800011d6:	e022                	sd	s0,0(sp)
    800011d8:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011da:	f47ff0ef          	jal	80001120 <kvmmake>
    800011de:	00009797          	auipc	a5,0x9
    800011e2:	28a7b923          	sd	a0,658(a5) # 8000a470 <kernel_pagetable>
}
    800011e6:	60a2                	ld	ra,8(sp)
    800011e8:	6402                	ld	s0,0(sp)
    800011ea:	0141                	addi	sp,sp,16
    800011ec:	8082                	ret

00000000800011ee <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011ee:	715d                	addi	sp,sp,-80
    800011f0:	e486                	sd	ra,72(sp)
    800011f2:	e0a2                	sd	s0,64(sp)
    800011f4:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800011f6:	03459793          	slli	a5,a1,0x34
    800011fa:	e39d                	bnez	a5,80001220 <uvmunmap+0x32>
    800011fc:	f84a                	sd	s2,48(sp)
    800011fe:	f44e                	sd	s3,40(sp)
    80001200:	f052                	sd	s4,32(sp)
    80001202:	ec56                	sd	s5,24(sp)
    80001204:	e85a                	sd	s6,16(sp)
    80001206:	e45e                	sd	s7,8(sp)
    80001208:	8a2a                	mv	s4,a0
    8000120a:	892e                	mv	s2,a1
    8000120c:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000120e:	0632                	slli	a2,a2,0xc
    80001210:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001214:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001216:	6b05                	lui	s6,0x1
    80001218:	0735ff63          	bgeu	a1,s3,80001296 <uvmunmap+0xa8>
    8000121c:	fc26                	sd	s1,56(sp)
    8000121e:	a0a9                	j	80001268 <uvmunmap+0x7a>
    80001220:	fc26                	sd	s1,56(sp)
    80001222:	f84a                	sd	s2,48(sp)
    80001224:	f44e                	sd	s3,40(sp)
    80001226:	f052                	sd	s4,32(sp)
    80001228:	ec56                	sd	s5,24(sp)
    8000122a:	e85a                	sd	s6,16(sp)
    8000122c:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    8000122e:	00006517          	auipc	a0,0x6
    80001232:	ef250513          	addi	a0,a0,-270 # 80007120 <etext+0x120>
    80001236:	d92ff0ef          	jal	800007c8 <panic>
      panic("uvmunmap: walk");
    8000123a:	00006517          	auipc	a0,0x6
    8000123e:	efe50513          	addi	a0,a0,-258 # 80007138 <etext+0x138>
    80001242:	d86ff0ef          	jal	800007c8 <panic>
      panic("uvmunmap: not mapped");
    80001246:	00006517          	auipc	a0,0x6
    8000124a:	f0250513          	addi	a0,a0,-254 # 80007148 <etext+0x148>
    8000124e:	d7aff0ef          	jal	800007c8 <panic>
      panic("uvmunmap: not a leaf");
    80001252:	00006517          	auipc	a0,0x6
    80001256:	f0e50513          	addi	a0,a0,-242 # 80007160 <etext+0x160>
    8000125a:	d6eff0ef          	jal	800007c8 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    8000125e:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001262:	995a                	add	s2,s2,s6
    80001264:	03397863          	bgeu	s2,s3,80001294 <uvmunmap+0xa6>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001268:	4601                	li	a2,0
    8000126a:	85ca                	mv	a1,s2
    8000126c:	8552                	mv	a0,s4
    8000126e:	d03ff0ef          	jal	80000f70 <walk>
    80001272:	84aa                	mv	s1,a0
    80001274:	d179                	beqz	a0,8000123a <uvmunmap+0x4c>
    if((*pte & PTE_V) == 0)
    80001276:	6108                	ld	a0,0(a0)
    80001278:	00157793          	andi	a5,a0,1
    8000127c:	d7e9                	beqz	a5,80001246 <uvmunmap+0x58>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000127e:	3ff57793          	andi	a5,a0,1023
    80001282:	fd7788e3          	beq	a5,s7,80001252 <uvmunmap+0x64>
    if(do_free){
    80001286:	fc0a8ce3          	beqz	s5,8000125e <uvmunmap+0x70>
      uint64 pa = PTE2PA(*pte);
    8000128a:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000128c:	0532                	slli	a0,a0,0xc
    8000128e:	fe8ff0ef          	jal	80000a76 <kfree>
    80001292:	b7f1                	j	8000125e <uvmunmap+0x70>
    80001294:	74e2                	ld	s1,56(sp)
    80001296:	7942                	ld	s2,48(sp)
    80001298:	79a2                	ld	s3,40(sp)
    8000129a:	7a02                	ld	s4,32(sp)
    8000129c:	6ae2                	ld	s5,24(sp)
    8000129e:	6b42                	ld	s6,16(sp)
    800012a0:	6ba2                	ld	s7,8(sp)
  }
}
    800012a2:	60a6                	ld	ra,72(sp)
    800012a4:	6406                	ld	s0,64(sp)
    800012a6:	6161                	addi	sp,sp,80
    800012a8:	8082                	ret

00000000800012aa <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800012aa:	1101                	addi	sp,sp,-32
    800012ac:	ec06                	sd	ra,24(sp)
    800012ae:	e822                	sd	s0,16(sp)
    800012b0:	e426                	sd	s1,8(sp)
    800012b2:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800012b4:	8a5ff0ef          	jal	80000b58 <kalloc>
    800012b8:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800012ba:	c509                	beqz	a0,800012c4 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800012bc:	6605                	lui	a2,0x1
    800012be:	4581                	li	a1,0
    800012c0:	a3dff0ef          	jal	80000cfc <memset>
  return pagetable;
}
    800012c4:	8526                	mv	a0,s1
    800012c6:	60e2                	ld	ra,24(sp)
    800012c8:	6442                	ld	s0,16(sp)
    800012ca:	64a2                	ld	s1,8(sp)
    800012cc:	6105                	addi	sp,sp,32
    800012ce:	8082                	ret

00000000800012d0 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800012d0:	7179                	addi	sp,sp,-48
    800012d2:	f406                	sd	ra,40(sp)
    800012d4:	f022                	sd	s0,32(sp)
    800012d6:	ec26                	sd	s1,24(sp)
    800012d8:	e84a                	sd	s2,16(sp)
    800012da:	e44e                	sd	s3,8(sp)
    800012dc:	e052                	sd	s4,0(sp)
    800012de:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800012e0:	6785                	lui	a5,0x1
    800012e2:	04f67063          	bgeu	a2,a5,80001322 <uvmfirst+0x52>
    800012e6:	8a2a                	mv	s4,a0
    800012e8:	89ae                	mv	s3,a1
    800012ea:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800012ec:	86dff0ef          	jal	80000b58 <kalloc>
    800012f0:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800012f2:	6605                	lui	a2,0x1
    800012f4:	4581                	li	a1,0
    800012f6:	a07ff0ef          	jal	80000cfc <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800012fa:	4779                	li	a4,30
    800012fc:	86ca                	mv	a3,s2
    800012fe:	6605                	lui	a2,0x1
    80001300:	4581                	li	a1,0
    80001302:	8552                	mv	a0,s4
    80001304:	d45ff0ef          	jal	80001048 <mappages>
  memmove(mem, src, sz);
    80001308:	8626                	mv	a2,s1
    8000130a:	85ce                	mv	a1,s3
    8000130c:	854a                	mv	a0,s2
    8000130e:	a4bff0ef          	jal	80000d58 <memmove>
}
    80001312:	70a2                	ld	ra,40(sp)
    80001314:	7402                	ld	s0,32(sp)
    80001316:	64e2                	ld	s1,24(sp)
    80001318:	6942                	ld	s2,16(sp)
    8000131a:	69a2                	ld	s3,8(sp)
    8000131c:	6a02                	ld	s4,0(sp)
    8000131e:	6145                	addi	sp,sp,48
    80001320:	8082                	ret
    panic("uvmfirst: more than a page");
    80001322:	00006517          	auipc	a0,0x6
    80001326:	e5650513          	addi	a0,a0,-426 # 80007178 <etext+0x178>
    8000132a:	c9eff0ef          	jal	800007c8 <panic>

000000008000132e <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000132e:	1101                	addi	sp,sp,-32
    80001330:	ec06                	sd	ra,24(sp)
    80001332:	e822                	sd	s0,16(sp)
    80001334:	e426                	sd	s1,8(sp)
    80001336:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001338:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000133a:	00b67d63          	bgeu	a2,a1,80001354 <uvmdealloc+0x26>
    8000133e:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001340:	6785                	lui	a5,0x1
    80001342:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001344:	00f60733          	add	a4,a2,a5
    80001348:	76fd                	lui	a3,0xfffff
    8000134a:	8f75                	and	a4,a4,a3
    8000134c:	97ae                	add	a5,a5,a1
    8000134e:	8ff5                	and	a5,a5,a3
    80001350:	00f76863          	bltu	a4,a5,80001360 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001354:	8526                	mv	a0,s1
    80001356:	60e2                	ld	ra,24(sp)
    80001358:	6442                	ld	s0,16(sp)
    8000135a:	64a2                	ld	s1,8(sp)
    8000135c:	6105                	addi	sp,sp,32
    8000135e:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001360:	8f99                	sub	a5,a5,a4
    80001362:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001364:	4685                	li	a3,1
    80001366:	0007861b          	sext.w	a2,a5
    8000136a:	85ba                	mv	a1,a4
    8000136c:	e83ff0ef          	jal	800011ee <uvmunmap>
    80001370:	b7d5                	j	80001354 <uvmdealloc+0x26>

0000000080001372 <uvmalloc>:
  if(newsz < oldsz)
    80001372:	08b66f63          	bltu	a2,a1,80001410 <uvmalloc+0x9e>
{
    80001376:	7139                	addi	sp,sp,-64
    80001378:	fc06                	sd	ra,56(sp)
    8000137a:	f822                	sd	s0,48(sp)
    8000137c:	ec4e                	sd	s3,24(sp)
    8000137e:	e852                	sd	s4,16(sp)
    80001380:	e456                	sd	s5,8(sp)
    80001382:	0080                	addi	s0,sp,64
    80001384:	8aaa                	mv	s5,a0
    80001386:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001388:	6785                	lui	a5,0x1
    8000138a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000138c:	95be                	add	a1,a1,a5
    8000138e:	77fd                	lui	a5,0xfffff
    80001390:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001394:	08c9f063          	bgeu	s3,a2,80001414 <uvmalloc+0xa2>
    80001398:	f426                	sd	s1,40(sp)
    8000139a:	f04a                	sd	s2,32(sp)
    8000139c:	e05a                	sd	s6,0(sp)
    8000139e:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800013a0:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800013a4:	fb4ff0ef          	jal	80000b58 <kalloc>
    800013a8:	84aa                	mv	s1,a0
    if(mem == 0){
    800013aa:	c515                	beqz	a0,800013d6 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800013ac:	6605                	lui	a2,0x1
    800013ae:	4581                	li	a1,0
    800013b0:	94dff0ef          	jal	80000cfc <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800013b4:	875a                	mv	a4,s6
    800013b6:	86a6                	mv	a3,s1
    800013b8:	6605                	lui	a2,0x1
    800013ba:	85ca                	mv	a1,s2
    800013bc:	8556                	mv	a0,s5
    800013be:	c8bff0ef          	jal	80001048 <mappages>
    800013c2:	e915                	bnez	a0,800013f6 <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800013c4:	6785                	lui	a5,0x1
    800013c6:	993e                	add	s2,s2,a5
    800013c8:	fd496ee3          	bltu	s2,s4,800013a4 <uvmalloc+0x32>
  return newsz;
    800013cc:	8552                	mv	a0,s4
    800013ce:	74a2                	ld	s1,40(sp)
    800013d0:	7902                	ld	s2,32(sp)
    800013d2:	6b02                	ld	s6,0(sp)
    800013d4:	a811                	j	800013e8 <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    800013d6:	864e                	mv	a2,s3
    800013d8:	85ca                	mv	a1,s2
    800013da:	8556                	mv	a0,s5
    800013dc:	f53ff0ef          	jal	8000132e <uvmdealloc>
      return 0;
    800013e0:	4501                	li	a0,0
    800013e2:	74a2                	ld	s1,40(sp)
    800013e4:	7902                	ld	s2,32(sp)
    800013e6:	6b02                	ld	s6,0(sp)
}
    800013e8:	70e2                	ld	ra,56(sp)
    800013ea:	7442                	ld	s0,48(sp)
    800013ec:	69e2                	ld	s3,24(sp)
    800013ee:	6a42                	ld	s4,16(sp)
    800013f0:	6aa2                	ld	s5,8(sp)
    800013f2:	6121                	addi	sp,sp,64
    800013f4:	8082                	ret
      kfree(mem);
    800013f6:	8526                	mv	a0,s1
    800013f8:	e7eff0ef          	jal	80000a76 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800013fc:	864e                	mv	a2,s3
    800013fe:	85ca                	mv	a1,s2
    80001400:	8556                	mv	a0,s5
    80001402:	f2dff0ef          	jal	8000132e <uvmdealloc>
      return 0;
    80001406:	4501                	li	a0,0
    80001408:	74a2                	ld	s1,40(sp)
    8000140a:	7902                	ld	s2,32(sp)
    8000140c:	6b02                	ld	s6,0(sp)
    8000140e:	bfe9                	j	800013e8 <uvmalloc+0x76>
    return oldsz;
    80001410:	852e                	mv	a0,a1
}
    80001412:	8082                	ret
  return newsz;
    80001414:	8532                	mv	a0,a2
    80001416:	bfc9                	j	800013e8 <uvmalloc+0x76>

0000000080001418 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001418:	7179                	addi	sp,sp,-48
    8000141a:	f406                	sd	ra,40(sp)
    8000141c:	f022                	sd	s0,32(sp)
    8000141e:	ec26                	sd	s1,24(sp)
    80001420:	e84a                	sd	s2,16(sp)
    80001422:	e44e                	sd	s3,8(sp)
    80001424:	e052                	sd	s4,0(sp)
    80001426:	1800                	addi	s0,sp,48
    80001428:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000142a:	84aa                	mv	s1,a0
    8000142c:	6905                	lui	s2,0x1
    8000142e:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001430:	4985                	li	s3,1
    80001432:	a819                	j	80001448 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001434:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001436:	00c79513          	slli	a0,a5,0xc
    8000143a:	fdfff0ef          	jal	80001418 <freewalk>
      pagetable[i] = 0;
    8000143e:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001442:	04a1                	addi	s1,s1,8
    80001444:	01248f63          	beq	s1,s2,80001462 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80001448:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000144a:	00f7f713          	andi	a4,a5,15
    8000144e:	ff3703e3          	beq	a4,s3,80001434 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001452:	8b85                	andi	a5,a5,1
    80001454:	d7fd                	beqz	a5,80001442 <freewalk+0x2a>
      panic("freewalk: leaf");
    80001456:	00006517          	auipc	a0,0x6
    8000145a:	d4250513          	addi	a0,a0,-702 # 80007198 <etext+0x198>
    8000145e:	b6aff0ef          	jal	800007c8 <panic>
    }
  }
  kfree((void*)pagetable);
    80001462:	8552                	mv	a0,s4
    80001464:	e12ff0ef          	jal	80000a76 <kfree>
}
    80001468:	70a2                	ld	ra,40(sp)
    8000146a:	7402                	ld	s0,32(sp)
    8000146c:	64e2                	ld	s1,24(sp)
    8000146e:	6942                	ld	s2,16(sp)
    80001470:	69a2                	ld	s3,8(sp)
    80001472:	6a02                	ld	s4,0(sp)
    80001474:	6145                	addi	sp,sp,48
    80001476:	8082                	ret

0000000080001478 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001478:	1101                	addi	sp,sp,-32
    8000147a:	ec06                	sd	ra,24(sp)
    8000147c:	e822                	sd	s0,16(sp)
    8000147e:	e426                	sd	s1,8(sp)
    80001480:	1000                	addi	s0,sp,32
    80001482:	84aa                	mv	s1,a0
  if(sz > 0)
    80001484:	e989                	bnez	a1,80001496 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001486:	8526                	mv	a0,s1
    80001488:	f91ff0ef          	jal	80001418 <freewalk>
}
    8000148c:	60e2                	ld	ra,24(sp)
    8000148e:	6442                	ld	s0,16(sp)
    80001490:	64a2                	ld	s1,8(sp)
    80001492:	6105                	addi	sp,sp,32
    80001494:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001496:	6785                	lui	a5,0x1
    80001498:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000149a:	95be                	add	a1,a1,a5
    8000149c:	4685                	li	a3,1
    8000149e:	00c5d613          	srli	a2,a1,0xc
    800014a2:	4581                	li	a1,0
    800014a4:	d4bff0ef          	jal	800011ee <uvmunmap>
    800014a8:	bff9                	j	80001486 <uvmfree+0xe>

00000000800014aa <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800014aa:	c65d                	beqz	a2,80001558 <uvmcopy+0xae>
{
    800014ac:	715d                	addi	sp,sp,-80
    800014ae:	e486                	sd	ra,72(sp)
    800014b0:	e0a2                	sd	s0,64(sp)
    800014b2:	fc26                	sd	s1,56(sp)
    800014b4:	f84a                	sd	s2,48(sp)
    800014b6:	f44e                	sd	s3,40(sp)
    800014b8:	f052                	sd	s4,32(sp)
    800014ba:	ec56                	sd	s5,24(sp)
    800014bc:	e85a                	sd	s6,16(sp)
    800014be:	e45e                	sd	s7,8(sp)
    800014c0:	0880                	addi	s0,sp,80
    800014c2:	8b2a                	mv	s6,a0
    800014c4:	8aae                	mv	s5,a1
    800014c6:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800014c8:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800014ca:	4601                	li	a2,0
    800014cc:	85ce                	mv	a1,s3
    800014ce:	855a                	mv	a0,s6
    800014d0:	aa1ff0ef          	jal	80000f70 <walk>
    800014d4:	c121                	beqz	a0,80001514 <uvmcopy+0x6a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800014d6:	6118                	ld	a4,0(a0)
    800014d8:	00177793          	andi	a5,a4,1
    800014dc:	c3b1                	beqz	a5,80001520 <uvmcopy+0x76>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800014de:	00a75593          	srli	a1,a4,0xa
    800014e2:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800014e6:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800014ea:	e6eff0ef          	jal	80000b58 <kalloc>
    800014ee:	892a                	mv	s2,a0
    800014f0:	c129                	beqz	a0,80001532 <uvmcopy+0x88>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800014f2:	6605                	lui	a2,0x1
    800014f4:	85de                	mv	a1,s7
    800014f6:	863ff0ef          	jal	80000d58 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800014fa:	8726                	mv	a4,s1
    800014fc:	86ca                	mv	a3,s2
    800014fe:	6605                	lui	a2,0x1
    80001500:	85ce                	mv	a1,s3
    80001502:	8556                	mv	a0,s5
    80001504:	b45ff0ef          	jal	80001048 <mappages>
    80001508:	e115                	bnez	a0,8000152c <uvmcopy+0x82>
  for(i = 0; i < sz; i += PGSIZE){
    8000150a:	6785                	lui	a5,0x1
    8000150c:	99be                	add	s3,s3,a5
    8000150e:	fb49eee3          	bltu	s3,s4,800014ca <uvmcopy+0x20>
    80001512:	a805                	j	80001542 <uvmcopy+0x98>
      panic("uvmcopy: pte should exist");
    80001514:	00006517          	auipc	a0,0x6
    80001518:	c9450513          	addi	a0,a0,-876 # 800071a8 <etext+0x1a8>
    8000151c:	aacff0ef          	jal	800007c8 <panic>
      panic("uvmcopy: page not present");
    80001520:	00006517          	auipc	a0,0x6
    80001524:	ca850513          	addi	a0,a0,-856 # 800071c8 <etext+0x1c8>
    80001528:	aa0ff0ef          	jal	800007c8 <panic>
      kfree(mem);
    8000152c:	854a                	mv	a0,s2
    8000152e:	d48ff0ef          	jal	80000a76 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001532:	4685                	li	a3,1
    80001534:	00c9d613          	srli	a2,s3,0xc
    80001538:	4581                	li	a1,0
    8000153a:	8556                	mv	a0,s5
    8000153c:	cb3ff0ef          	jal	800011ee <uvmunmap>
  return -1;
    80001540:	557d                	li	a0,-1
}
    80001542:	60a6                	ld	ra,72(sp)
    80001544:	6406                	ld	s0,64(sp)
    80001546:	74e2                	ld	s1,56(sp)
    80001548:	7942                	ld	s2,48(sp)
    8000154a:	79a2                	ld	s3,40(sp)
    8000154c:	7a02                	ld	s4,32(sp)
    8000154e:	6ae2                	ld	s5,24(sp)
    80001550:	6b42                	ld	s6,16(sp)
    80001552:	6ba2                	ld	s7,8(sp)
    80001554:	6161                	addi	sp,sp,80
    80001556:	8082                	ret
  return 0;
    80001558:	4501                	li	a0,0
}
    8000155a:	8082                	ret

000000008000155c <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000155c:	1141                	addi	sp,sp,-16
    8000155e:	e406                	sd	ra,8(sp)
    80001560:	e022                	sd	s0,0(sp)
    80001562:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001564:	4601                	li	a2,0
    80001566:	a0bff0ef          	jal	80000f70 <walk>
  if(pte == 0)
    8000156a:	c901                	beqz	a0,8000157a <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000156c:	611c                	ld	a5,0(a0)
    8000156e:	9bbd                	andi	a5,a5,-17
    80001570:	e11c                	sd	a5,0(a0)
}
    80001572:	60a2                	ld	ra,8(sp)
    80001574:	6402                	ld	s0,0(sp)
    80001576:	0141                	addi	sp,sp,16
    80001578:	8082                	ret
    panic("uvmclear");
    8000157a:	00006517          	auipc	a0,0x6
    8000157e:	c6e50513          	addi	a0,a0,-914 # 800071e8 <etext+0x1e8>
    80001582:	a46ff0ef          	jal	800007c8 <panic>

0000000080001586 <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    80001586:	cad1                	beqz	a3,8000161a <copyout+0x94>
{
    80001588:	711d                	addi	sp,sp,-96
    8000158a:	ec86                	sd	ra,88(sp)
    8000158c:	e8a2                	sd	s0,80(sp)
    8000158e:	e4a6                	sd	s1,72(sp)
    80001590:	fc4e                	sd	s3,56(sp)
    80001592:	f456                	sd	s5,40(sp)
    80001594:	f05a                	sd	s6,32(sp)
    80001596:	ec5e                	sd	s7,24(sp)
    80001598:	1080                	addi	s0,sp,96
    8000159a:	8baa                	mv	s7,a0
    8000159c:	8aae                	mv	s5,a1
    8000159e:	8b32                	mv	s6,a2
    800015a0:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800015a2:	74fd                	lui	s1,0xfffff
    800015a4:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    800015a6:	57fd                	li	a5,-1
    800015a8:	83e9                	srli	a5,a5,0x1a
    800015aa:	0697ea63          	bltu	a5,s1,8000161e <copyout+0x98>
    800015ae:	e0ca                	sd	s2,64(sp)
    800015b0:	f852                	sd	s4,48(sp)
    800015b2:	e862                	sd	s8,16(sp)
    800015b4:	e466                	sd	s9,8(sp)
    800015b6:	e06a                	sd	s10,0(sp)
      return -1;
    pte = walk(pagetable, va0, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    800015b8:	4cd5                	li	s9,21
    800015ba:	6d05                	lui	s10,0x1
    if(va0 >= MAXVA)
    800015bc:	8c3e                	mv	s8,a5
    800015be:	a025                	j	800015e6 <copyout+0x60>
       (*pte & PTE_W) == 0)
      return -1;
    pa0 = PTE2PA(*pte);
    800015c0:	83a9                	srli	a5,a5,0xa
    800015c2:	07b2                	slli	a5,a5,0xc
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800015c4:	409a8533          	sub	a0,s5,s1
    800015c8:	0009061b          	sext.w	a2,s2
    800015cc:	85da                	mv	a1,s6
    800015ce:	953e                	add	a0,a0,a5
    800015d0:	f88ff0ef          	jal	80000d58 <memmove>

    len -= n;
    800015d4:	412989b3          	sub	s3,s3,s2
    src += n;
    800015d8:	9b4a                	add	s6,s6,s2
  while(len > 0){
    800015da:	02098963          	beqz	s3,8000160c <copyout+0x86>
    if(va0 >= MAXVA)
    800015de:	054c6263          	bltu	s8,s4,80001622 <copyout+0x9c>
    800015e2:	84d2                	mv	s1,s4
    800015e4:	8ad2                	mv	s5,s4
    pte = walk(pagetable, va0, 0);
    800015e6:	4601                	li	a2,0
    800015e8:	85a6                	mv	a1,s1
    800015ea:	855e                	mv	a0,s7
    800015ec:	985ff0ef          	jal	80000f70 <walk>
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    800015f0:	c121                	beqz	a0,80001630 <copyout+0xaa>
    800015f2:	611c                	ld	a5,0(a0)
    800015f4:	0157f713          	andi	a4,a5,21
    800015f8:	05971b63          	bne	a4,s9,8000164e <copyout+0xc8>
    n = PGSIZE - (dstva - va0);
    800015fc:	01a48a33          	add	s4,s1,s10
    80001600:	415a0933          	sub	s2,s4,s5
    if(n > len)
    80001604:	fb29fee3          	bgeu	s3,s2,800015c0 <copyout+0x3a>
    80001608:	894e                	mv	s2,s3
    8000160a:	bf5d                	j	800015c0 <copyout+0x3a>
    dstva = va0 + PGSIZE;
  }
  return 0;
    8000160c:	4501                	li	a0,0
    8000160e:	6906                	ld	s2,64(sp)
    80001610:	7a42                	ld	s4,48(sp)
    80001612:	6c42                	ld	s8,16(sp)
    80001614:	6ca2                	ld	s9,8(sp)
    80001616:	6d02                	ld	s10,0(sp)
    80001618:	a015                	j	8000163c <copyout+0xb6>
    8000161a:	4501                	li	a0,0
}
    8000161c:	8082                	ret
      return -1;
    8000161e:	557d                	li	a0,-1
    80001620:	a831                	j	8000163c <copyout+0xb6>
    80001622:	557d                	li	a0,-1
    80001624:	6906                	ld	s2,64(sp)
    80001626:	7a42                	ld	s4,48(sp)
    80001628:	6c42                	ld	s8,16(sp)
    8000162a:	6ca2                	ld	s9,8(sp)
    8000162c:	6d02                	ld	s10,0(sp)
    8000162e:	a039                	j	8000163c <copyout+0xb6>
      return -1;
    80001630:	557d                	li	a0,-1
    80001632:	6906                	ld	s2,64(sp)
    80001634:	7a42                	ld	s4,48(sp)
    80001636:	6c42                	ld	s8,16(sp)
    80001638:	6ca2                	ld	s9,8(sp)
    8000163a:	6d02                	ld	s10,0(sp)
}
    8000163c:	60e6                	ld	ra,88(sp)
    8000163e:	6446                	ld	s0,80(sp)
    80001640:	64a6                	ld	s1,72(sp)
    80001642:	79e2                	ld	s3,56(sp)
    80001644:	7aa2                	ld	s5,40(sp)
    80001646:	7b02                	ld	s6,32(sp)
    80001648:	6be2                	ld	s7,24(sp)
    8000164a:	6125                	addi	sp,sp,96
    8000164c:	8082                	ret
      return -1;
    8000164e:	557d                	li	a0,-1
    80001650:	6906                	ld	s2,64(sp)
    80001652:	7a42                	ld	s4,48(sp)
    80001654:	6c42                	ld	s8,16(sp)
    80001656:	6ca2                	ld	s9,8(sp)
    80001658:	6d02                	ld	s10,0(sp)
    8000165a:	b7cd                	j	8000163c <copyout+0xb6>

000000008000165c <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000165c:	c6a5                	beqz	a3,800016c4 <copyin+0x68>
{
    8000165e:	715d                	addi	sp,sp,-80
    80001660:	e486                	sd	ra,72(sp)
    80001662:	e0a2                	sd	s0,64(sp)
    80001664:	fc26                	sd	s1,56(sp)
    80001666:	f84a                	sd	s2,48(sp)
    80001668:	f44e                	sd	s3,40(sp)
    8000166a:	f052                	sd	s4,32(sp)
    8000166c:	ec56                	sd	s5,24(sp)
    8000166e:	e85a                	sd	s6,16(sp)
    80001670:	e45e                	sd	s7,8(sp)
    80001672:	e062                	sd	s8,0(sp)
    80001674:	0880                	addi	s0,sp,80
    80001676:	8b2a                	mv	s6,a0
    80001678:	8a2e                	mv	s4,a1
    8000167a:	8c32                	mv	s8,a2
    8000167c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000167e:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001680:	6a85                	lui	s5,0x1
    80001682:	a00d                	j	800016a4 <copyin+0x48>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001684:	018505b3          	add	a1,a0,s8
    80001688:	0004861b          	sext.w	a2,s1
    8000168c:	412585b3          	sub	a1,a1,s2
    80001690:	8552                	mv	a0,s4
    80001692:	ec6ff0ef          	jal	80000d58 <memmove>

    len -= n;
    80001696:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000169a:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000169c:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016a0:	02098063          	beqz	s3,800016c0 <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    800016a4:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016a8:	85ca                	mv	a1,s2
    800016aa:	855a                	mv	a0,s6
    800016ac:	95fff0ef          	jal	8000100a <walkaddr>
    if(pa0 == 0)
    800016b0:	cd01                	beqz	a0,800016c8 <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    800016b2:	418904b3          	sub	s1,s2,s8
    800016b6:	94d6                	add	s1,s1,s5
    if(n > len)
    800016b8:	fc99f6e3          	bgeu	s3,s1,80001684 <copyin+0x28>
    800016bc:	84ce                	mv	s1,s3
    800016be:	b7d9                	j	80001684 <copyin+0x28>
  }
  return 0;
    800016c0:	4501                	li	a0,0
    800016c2:	a021                	j	800016ca <copyin+0x6e>
    800016c4:	4501                	li	a0,0
}
    800016c6:	8082                	ret
      return -1;
    800016c8:	557d                	li	a0,-1
}
    800016ca:	60a6                	ld	ra,72(sp)
    800016cc:	6406                	ld	s0,64(sp)
    800016ce:	74e2                	ld	s1,56(sp)
    800016d0:	7942                	ld	s2,48(sp)
    800016d2:	79a2                	ld	s3,40(sp)
    800016d4:	7a02                	ld	s4,32(sp)
    800016d6:	6ae2                	ld	s5,24(sp)
    800016d8:	6b42                	ld	s6,16(sp)
    800016da:	6ba2                	ld	s7,8(sp)
    800016dc:	6c02                	ld	s8,0(sp)
    800016de:	6161                	addi	sp,sp,80
    800016e0:	8082                	ret

00000000800016e2 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800016e2:	c6dd                	beqz	a3,80001790 <copyinstr+0xae>
{
    800016e4:	715d                	addi	sp,sp,-80
    800016e6:	e486                	sd	ra,72(sp)
    800016e8:	e0a2                	sd	s0,64(sp)
    800016ea:	fc26                	sd	s1,56(sp)
    800016ec:	f84a                	sd	s2,48(sp)
    800016ee:	f44e                	sd	s3,40(sp)
    800016f0:	f052                	sd	s4,32(sp)
    800016f2:	ec56                	sd	s5,24(sp)
    800016f4:	e85a                	sd	s6,16(sp)
    800016f6:	e45e                	sd	s7,8(sp)
    800016f8:	0880                	addi	s0,sp,80
    800016fa:	8a2a                	mv	s4,a0
    800016fc:	8b2e                	mv	s6,a1
    800016fe:	8bb2                	mv	s7,a2
    80001700:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    80001702:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001704:	6985                	lui	s3,0x1
    80001706:	a825                	j	8000173e <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001708:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000170c:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000170e:	37fd                	addiw	a5,a5,-1
    80001710:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001714:	60a6                	ld	ra,72(sp)
    80001716:	6406                	ld	s0,64(sp)
    80001718:	74e2                	ld	s1,56(sp)
    8000171a:	7942                	ld	s2,48(sp)
    8000171c:	79a2                	ld	s3,40(sp)
    8000171e:	7a02                	ld	s4,32(sp)
    80001720:	6ae2                	ld	s5,24(sp)
    80001722:	6b42                	ld	s6,16(sp)
    80001724:	6ba2                	ld	s7,8(sp)
    80001726:	6161                	addi	sp,sp,80
    80001728:	8082                	ret
    8000172a:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    8000172e:	9742                	add	a4,a4,a6
      --max;
    80001730:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80001734:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80001738:	04e58463          	beq	a1,a4,80001780 <copyinstr+0x9e>
{
    8000173c:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    8000173e:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001742:	85a6                	mv	a1,s1
    80001744:	8552                	mv	a0,s4
    80001746:	8c5ff0ef          	jal	8000100a <walkaddr>
    if(pa0 == 0)
    8000174a:	cd0d                	beqz	a0,80001784 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    8000174c:	417486b3          	sub	a3,s1,s7
    80001750:	96ce                	add	a3,a3,s3
    if(n > max)
    80001752:	00d97363          	bgeu	s2,a3,80001758 <copyinstr+0x76>
    80001756:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80001758:	955e                	add	a0,a0,s7
    8000175a:	8d05                	sub	a0,a0,s1
    while(n > 0){
    8000175c:	c695                	beqz	a3,80001788 <copyinstr+0xa6>
    8000175e:	87da                	mv	a5,s6
    80001760:	885a                	mv	a6,s6
      if(*p == '\0'){
    80001762:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001766:	96da                	add	a3,a3,s6
    80001768:	85be                	mv	a1,a5
      if(*p == '\0'){
    8000176a:	00f60733          	add	a4,a2,a5
    8000176e:	00074703          	lbu	a4,0(a4)
    80001772:	db59                	beqz	a4,80001708 <copyinstr+0x26>
        *dst = *p;
    80001774:	00e78023          	sb	a4,0(a5)
      dst++;
    80001778:	0785                	addi	a5,a5,1
    while(n > 0){
    8000177a:	fed797e3          	bne	a5,a3,80001768 <copyinstr+0x86>
    8000177e:	b775                	j	8000172a <copyinstr+0x48>
    80001780:	4781                	li	a5,0
    80001782:	b771                	j	8000170e <copyinstr+0x2c>
      return -1;
    80001784:	557d                	li	a0,-1
    80001786:	b779                	j	80001714 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    80001788:	6b85                	lui	s7,0x1
    8000178a:	9ba6                	add	s7,s7,s1
    8000178c:	87da                	mv	a5,s6
    8000178e:	b77d                	j	8000173c <copyinstr+0x5a>
  int got_null = 0;
    80001790:	4781                	li	a5,0
  if(got_null){
    80001792:	37fd                	addiw	a5,a5,-1
    80001794:	0007851b          	sext.w	a0,a5
}
    80001798:	8082                	ret

000000008000179a <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    8000179a:	7139                	addi	sp,sp,-64
    8000179c:	fc06                	sd	ra,56(sp)
    8000179e:	f822                	sd	s0,48(sp)
    800017a0:	f426                	sd	s1,40(sp)
    800017a2:	f04a                	sd	s2,32(sp)
    800017a4:	ec4e                	sd	s3,24(sp)
    800017a6:	e852                	sd	s4,16(sp)
    800017a8:	e456                	sd	s5,8(sp)
    800017aa:	e05a                	sd	s6,0(sp)
    800017ac:	0080                	addi	s0,sp,64
    800017ae:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800017b0:	00011497          	auipc	s1,0x11
    800017b4:	23048493          	addi	s1,s1,560 # 800129e0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800017b8:	8b26                	mv	s6,s1
    800017ba:	04fa5937          	lui	s2,0x4fa5
    800017be:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    800017c2:	0932                	slli	s2,s2,0xc
    800017c4:	fa590913          	addi	s2,s2,-91
    800017c8:	0932                	slli	s2,s2,0xc
    800017ca:	fa590913          	addi	s2,s2,-91
    800017ce:	0932                	slli	s2,s2,0xc
    800017d0:	fa590913          	addi	s2,s2,-91
    800017d4:	040009b7          	lui	s3,0x4000
    800017d8:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017da:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800017dc:	00017a97          	auipc	s5,0x17
    800017e0:	c04a8a93          	addi	s5,s5,-1020 # 800183e0 <tickslock>
    char *pa = kalloc();
    800017e4:	b74ff0ef          	jal	80000b58 <kalloc>
    800017e8:	862a                	mv	a2,a0
    if(pa == 0)
    800017ea:	cd15                	beqz	a0,80001826 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    800017ec:	416485b3          	sub	a1,s1,s6
    800017f0:	858d                	srai	a1,a1,0x3
    800017f2:	032585b3          	mul	a1,a1,s2
    800017f6:	2585                	addiw	a1,a1,1
    800017f8:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017fc:	4719                	li	a4,6
    800017fe:	6685                	lui	a3,0x1
    80001800:	40b985b3          	sub	a1,s3,a1
    80001804:	8552                	mv	a0,s4
    80001806:	8f3ff0ef          	jal	800010f8 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000180a:	16848493          	addi	s1,s1,360
    8000180e:	fd549be3          	bne	s1,s5,800017e4 <proc_mapstacks+0x4a>
  }
}
    80001812:	70e2                	ld	ra,56(sp)
    80001814:	7442                	ld	s0,48(sp)
    80001816:	74a2                	ld	s1,40(sp)
    80001818:	7902                	ld	s2,32(sp)
    8000181a:	69e2                	ld	s3,24(sp)
    8000181c:	6a42                	ld	s4,16(sp)
    8000181e:	6aa2                	ld	s5,8(sp)
    80001820:	6b02                	ld	s6,0(sp)
    80001822:	6121                	addi	sp,sp,64
    80001824:	8082                	ret
      panic("kalloc");
    80001826:	00006517          	auipc	a0,0x6
    8000182a:	9d250513          	addi	a0,a0,-1582 # 800071f8 <etext+0x1f8>
    8000182e:	f9bfe0ef          	jal	800007c8 <panic>

0000000080001832 <procinit>:


// initialize the proc table.
void
procinit(void)
{
    80001832:	7139                	addi	sp,sp,-64
    80001834:	fc06                	sd	ra,56(sp)
    80001836:	f822                	sd	s0,48(sp)
    80001838:	f426                	sd	s1,40(sp)
    8000183a:	f04a                	sd	s2,32(sp)
    8000183c:	ec4e                	sd	s3,24(sp)
    8000183e:	e852                	sd	s4,16(sp)
    80001840:	e456                	sd	s5,8(sp)
    80001842:	e05a                	sd	s6,0(sp)
    80001844:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001846:	00006597          	auipc	a1,0x6
    8000184a:	9ba58593          	addi	a1,a1,-1606 # 80007200 <etext+0x200>
    8000184e:	00011517          	auipc	a0,0x11
    80001852:	d6250513          	addi	a0,a0,-670 # 800125b0 <pid_lock>
    80001856:	b52ff0ef          	jal	80000ba8 <initlock>
  initlock(&wait_lock, "wait_lock");
    8000185a:	00006597          	auipc	a1,0x6
    8000185e:	9ae58593          	addi	a1,a1,-1618 # 80007208 <etext+0x208>
    80001862:	00011517          	auipc	a0,0x11
    80001866:	d6650513          	addi	a0,a0,-666 # 800125c8 <wait_lock>
    8000186a:	b3eff0ef          	jal	80000ba8 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000186e:	00011497          	auipc	s1,0x11
    80001872:	17248493          	addi	s1,s1,370 # 800129e0 <proc>
      initlock(&p->lock, "proc");
    80001876:	00006b17          	auipc	s6,0x6
    8000187a:	9a2b0b13          	addi	s6,s6,-1630 # 80007218 <etext+0x218>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000187e:	8aa6                	mv	s5,s1
    80001880:	04fa5937          	lui	s2,0x4fa5
    80001884:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001888:	0932                	slli	s2,s2,0xc
    8000188a:	fa590913          	addi	s2,s2,-91
    8000188e:	0932                	slli	s2,s2,0xc
    80001890:	fa590913          	addi	s2,s2,-91
    80001894:	0932                	slli	s2,s2,0xc
    80001896:	fa590913          	addi	s2,s2,-91
    8000189a:	040009b7          	lui	s3,0x4000
    8000189e:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800018a0:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800018a2:	00017a17          	auipc	s4,0x17
    800018a6:	b3ea0a13          	addi	s4,s4,-1218 # 800183e0 <tickslock>
      initlock(&p->lock, "proc");
    800018aa:	85da                	mv	a1,s6
    800018ac:	8526                	mv	a0,s1
    800018ae:	afaff0ef          	jal	80000ba8 <initlock>
      p->state = UNUSED;
    800018b2:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800018b6:	415487b3          	sub	a5,s1,s5
    800018ba:	878d                	srai	a5,a5,0x3
    800018bc:	032787b3          	mul	a5,a5,s2
    800018c0:	2785                	addiw	a5,a5,1
    800018c2:	00d7979b          	slliw	a5,a5,0xd
    800018c6:	40f987b3          	sub	a5,s3,a5
    800018ca:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800018cc:	16848493          	addi	s1,s1,360
    800018d0:	fd449de3          	bne	s1,s4,800018aa <procinit+0x78>
  }
}
    800018d4:	70e2                	ld	ra,56(sp)
    800018d6:	7442                	ld	s0,48(sp)
    800018d8:	74a2                	ld	s1,40(sp)
    800018da:	7902                	ld	s2,32(sp)
    800018dc:	69e2                	ld	s3,24(sp)
    800018de:	6a42                	ld	s4,16(sp)
    800018e0:	6aa2                	ld	s5,8(sp)
    800018e2:	6b02                	ld	s6,0(sp)
    800018e4:	6121                	addi	sp,sp,64
    800018e6:	8082                	ret

00000000800018e8 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018e8:	1141                	addi	sp,sp,-16
    800018ea:	e422                	sd	s0,8(sp)
    800018ec:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800018ee:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018f0:	2501                	sext.w	a0,a0
    800018f2:	6422                	ld	s0,8(sp)
    800018f4:	0141                	addi	sp,sp,16
    800018f6:	8082                	ret

00000000800018f8 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800018f8:	1141                	addi	sp,sp,-16
    800018fa:	e422                	sd	s0,8(sp)
    800018fc:	0800                	addi	s0,sp,16
    800018fe:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001900:	2781                	sext.w	a5,a5
    80001902:	079e                	slli	a5,a5,0x7
  return c;
}
    80001904:	00011517          	auipc	a0,0x11
    80001908:	cdc50513          	addi	a0,a0,-804 # 800125e0 <cpus>
    8000190c:	953e                	add	a0,a0,a5
    8000190e:	6422                	ld	s0,8(sp)
    80001910:	0141                	addi	sp,sp,16
    80001912:	8082                	ret

0000000080001914 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001914:	1101                	addi	sp,sp,-32
    80001916:	ec06                	sd	ra,24(sp)
    80001918:	e822                	sd	s0,16(sp)
    8000191a:	e426                	sd	s1,8(sp)
    8000191c:	1000                	addi	s0,sp,32
  push_off();
    8000191e:	acaff0ef          	jal	80000be8 <push_off>
    80001922:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001924:	2781                	sext.w	a5,a5
    80001926:	079e                	slli	a5,a5,0x7
    80001928:	00011717          	auipc	a4,0x11
    8000192c:	c8870713          	addi	a4,a4,-888 # 800125b0 <pid_lock>
    80001930:	97ba                	add	a5,a5,a4
    80001932:	7b84                	ld	s1,48(a5)
  pop_off();
    80001934:	b38ff0ef          	jal	80000c6c <pop_off>
  return p;
}
    80001938:	8526                	mv	a0,s1
    8000193a:	60e2                	ld	ra,24(sp)
    8000193c:	6442                	ld	s0,16(sp)
    8000193e:	64a2                	ld	s1,8(sp)
    80001940:	6105                	addi	sp,sp,32
    80001942:	8082                	ret

0000000080001944 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001944:	1141                	addi	sp,sp,-16
    80001946:	e406                	sd	ra,8(sp)
    80001948:	e022                	sd	s0,0(sp)
    8000194a:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    8000194c:	fc9ff0ef          	jal	80001914 <myproc>
    80001950:	b70ff0ef          	jal	80000cc0 <release>

  if (first) {
    80001954:	00009797          	auipc	a5,0x9
    80001958:	a8c7a783          	lw	a5,-1396(a5) # 8000a3e0 <first.1>
    8000195c:	e799                	bnez	a5,8000196a <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    8000195e:	4cd000ef          	jal	8000262a <usertrapret>
}
    80001962:	60a2                	ld	ra,8(sp)
    80001964:	6402                	ld	s0,0(sp)
    80001966:	0141                	addi	sp,sp,16
    80001968:	8082                	ret
    fsinit(ROOTDEV);
    8000196a:	4505                	li	a0,1
    8000196c:	241010ef          	jal	800033ac <fsinit>
    first = 0;
    80001970:	00009797          	auipc	a5,0x9
    80001974:	a607a823          	sw	zero,-1424(a5) # 8000a3e0 <first.1>
    __sync_synchronize();
    80001978:	0330000f          	fence	rw,rw
    8000197c:	b7cd                	j	8000195e <forkret+0x1a>

000000008000197e <allocpid>:
{
    8000197e:	1101                	addi	sp,sp,-32
    80001980:	ec06                	sd	ra,24(sp)
    80001982:	e822                	sd	s0,16(sp)
    80001984:	e426                	sd	s1,8(sp)
    80001986:	e04a                	sd	s2,0(sp)
    80001988:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    8000198a:	00011917          	auipc	s2,0x11
    8000198e:	c2690913          	addi	s2,s2,-986 # 800125b0 <pid_lock>
    80001992:	854a                	mv	a0,s2
    80001994:	a94ff0ef          	jal	80000c28 <acquire>
  pid = nextpid;
    80001998:	00009797          	auipc	a5,0x9
    8000199c:	a4c78793          	addi	a5,a5,-1460 # 8000a3e4 <nextpid>
    800019a0:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800019a2:	0014871b          	addiw	a4,s1,1
    800019a6:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800019a8:	854a                	mv	a0,s2
    800019aa:	b16ff0ef          	jal	80000cc0 <release>
}
    800019ae:	8526                	mv	a0,s1
    800019b0:	60e2                	ld	ra,24(sp)
    800019b2:	6442                	ld	s0,16(sp)
    800019b4:	64a2                	ld	s1,8(sp)
    800019b6:	6902                	ld	s2,0(sp)
    800019b8:	6105                	addi	sp,sp,32
    800019ba:	8082                	ret

00000000800019bc <proc_pagetable>:
{
    800019bc:	1101                	addi	sp,sp,-32
    800019be:	ec06                	sd	ra,24(sp)
    800019c0:	e822                	sd	s0,16(sp)
    800019c2:	e426                	sd	s1,8(sp)
    800019c4:	e04a                	sd	s2,0(sp)
    800019c6:	1000                	addi	s0,sp,32
    800019c8:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    800019ca:	8e1ff0ef          	jal	800012aa <uvmcreate>
    800019ce:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800019d0:	cd05                	beqz	a0,80001a08 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    800019d2:	4729                	li	a4,10
    800019d4:	00004697          	auipc	a3,0x4
    800019d8:	62c68693          	addi	a3,a3,1580 # 80006000 <_trampoline>
    800019dc:	6605                	lui	a2,0x1
    800019de:	040005b7          	lui	a1,0x4000
    800019e2:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019e4:	05b2                	slli	a1,a1,0xc
    800019e6:	e62ff0ef          	jal	80001048 <mappages>
    800019ea:	02054663          	bltz	a0,80001a16 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    800019ee:	4719                	li	a4,6
    800019f0:	05893683          	ld	a3,88(s2)
    800019f4:	6605                	lui	a2,0x1
    800019f6:	020005b7          	lui	a1,0x2000
    800019fa:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800019fc:	05b6                	slli	a1,a1,0xd
    800019fe:	8526                	mv	a0,s1
    80001a00:	e48ff0ef          	jal	80001048 <mappages>
    80001a04:	00054f63          	bltz	a0,80001a22 <proc_pagetable+0x66>
}
    80001a08:	8526                	mv	a0,s1
    80001a0a:	60e2                	ld	ra,24(sp)
    80001a0c:	6442                	ld	s0,16(sp)
    80001a0e:	64a2                	ld	s1,8(sp)
    80001a10:	6902                	ld	s2,0(sp)
    80001a12:	6105                	addi	sp,sp,32
    80001a14:	8082                	ret
    uvmfree(pagetable, 0);
    80001a16:	4581                	li	a1,0
    80001a18:	8526                	mv	a0,s1
    80001a1a:	a5fff0ef          	jal	80001478 <uvmfree>
    return 0;
    80001a1e:	4481                	li	s1,0
    80001a20:	b7e5                	j	80001a08 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a22:	4681                	li	a3,0
    80001a24:	4605                	li	a2,1
    80001a26:	040005b7          	lui	a1,0x4000
    80001a2a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a2c:	05b2                	slli	a1,a1,0xc
    80001a2e:	8526                	mv	a0,s1
    80001a30:	fbeff0ef          	jal	800011ee <uvmunmap>
    uvmfree(pagetable, 0);
    80001a34:	4581                	li	a1,0
    80001a36:	8526                	mv	a0,s1
    80001a38:	a41ff0ef          	jal	80001478 <uvmfree>
    return 0;
    80001a3c:	4481                	li	s1,0
    80001a3e:	b7e9                	j	80001a08 <proc_pagetable+0x4c>

0000000080001a40 <proc_freepagetable>:
{
    80001a40:	1101                	addi	sp,sp,-32
    80001a42:	ec06                	sd	ra,24(sp)
    80001a44:	e822                	sd	s0,16(sp)
    80001a46:	e426                	sd	s1,8(sp)
    80001a48:	e04a                	sd	s2,0(sp)
    80001a4a:	1000                	addi	s0,sp,32
    80001a4c:	84aa                	mv	s1,a0
    80001a4e:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a50:	4681                	li	a3,0
    80001a52:	4605                	li	a2,1
    80001a54:	040005b7          	lui	a1,0x4000
    80001a58:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a5a:	05b2                	slli	a1,a1,0xc
    80001a5c:	f92ff0ef          	jal	800011ee <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a60:	4681                	li	a3,0
    80001a62:	4605                	li	a2,1
    80001a64:	020005b7          	lui	a1,0x2000
    80001a68:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a6a:	05b6                	slli	a1,a1,0xd
    80001a6c:	8526                	mv	a0,s1
    80001a6e:	f80ff0ef          	jal	800011ee <uvmunmap>
  uvmfree(pagetable, sz);
    80001a72:	85ca                	mv	a1,s2
    80001a74:	8526                	mv	a0,s1
    80001a76:	a03ff0ef          	jal	80001478 <uvmfree>
}
    80001a7a:	60e2                	ld	ra,24(sp)
    80001a7c:	6442                	ld	s0,16(sp)
    80001a7e:	64a2                	ld	s1,8(sp)
    80001a80:	6902                	ld	s2,0(sp)
    80001a82:	6105                	addi	sp,sp,32
    80001a84:	8082                	ret

0000000080001a86 <freeproc>:
{
    80001a86:	1101                	addi	sp,sp,-32
    80001a88:	ec06                	sd	ra,24(sp)
    80001a8a:	e822                	sd	s0,16(sp)
    80001a8c:	e426                	sd	s1,8(sp)
    80001a8e:	1000                	addi	s0,sp,32
    80001a90:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001a92:	6d28                	ld	a0,88(a0)
    80001a94:	c119                	beqz	a0,80001a9a <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001a96:	fe1fe0ef          	jal	80000a76 <kfree>
  p->trapframe = 0;
    80001a9a:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001a9e:	68a8                	ld	a0,80(s1)
    80001aa0:	c501                	beqz	a0,80001aa8 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001aa2:	64ac                	ld	a1,72(s1)
    80001aa4:	f9dff0ef          	jal	80001a40 <proc_freepagetable>
  p->pagetable = 0;
    80001aa8:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001aac:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001ab0:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001ab4:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001ab8:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001abc:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ac0:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001ac4:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001ac8:	0004ac23          	sw	zero,24(s1)
}
    80001acc:	60e2                	ld	ra,24(sp)
    80001ace:	6442                	ld	s0,16(sp)
    80001ad0:	64a2                	ld	s1,8(sp)
    80001ad2:	6105                	addi	sp,sp,32
    80001ad4:	8082                	ret

0000000080001ad6 <allocproc>:
{
    80001ad6:	1101                	addi	sp,sp,-32
    80001ad8:	ec06                	sd	ra,24(sp)
    80001ada:	e822                	sd	s0,16(sp)
    80001adc:	e426                	sd	s1,8(sp)
    80001ade:	e04a                	sd	s2,0(sp)
    80001ae0:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ae2:	00011497          	auipc	s1,0x11
    80001ae6:	efe48493          	addi	s1,s1,-258 # 800129e0 <proc>
    80001aea:	00017917          	auipc	s2,0x17
    80001aee:	8f690913          	addi	s2,s2,-1802 # 800183e0 <tickslock>
    acquire(&p->lock);
    80001af2:	8526                	mv	a0,s1
    80001af4:	934ff0ef          	jal	80000c28 <acquire>
    if(p->state == UNUSED) {
    80001af8:	4c9c                	lw	a5,24(s1)
    80001afa:	cb91                	beqz	a5,80001b0e <allocproc+0x38>
      release(&p->lock);
    80001afc:	8526                	mv	a0,s1
    80001afe:	9c2ff0ef          	jal	80000cc0 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b02:	16848493          	addi	s1,s1,360
    80001b06:	ff2496e3          	bne	s1,s2,80001af2 <allocproc+0x1c>
  return 0;
    80001b0a:	4481                	li	s1,0
    80001b0c:	a089                	j	80001b4e <allocproc+0x78>
  p->pid = allocpid();
    80001b0e:	e71ff0ef          	jal	8000197e <allocpid>
    80001b12:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001b14:	4785                	li	a5,1
    80001b16:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001b18:	840ff0ef          	jal	80000b58 <kalloc>
    80001b1c:	892a                	mv	s2,a0
    80001b1e:	eca8                	sd	a0,88(s1)
    80001b20:	cd15                	beqz	a0,80001b5c <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001b22:	8526                	mv	a0,s1
    80001b24:	e99ff0ef          	jal	800019bc <proc_pagetable>
    80001b28:	892a                	mv	s2,a0
    80001b2a:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001b2c:	c121                	beqz	a0,80001b6c <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001b2e:	07000613          	li	a2,112
    80001b32:	4581                	li	a1,0
    80001b34:	06048513          	addi	a0,s1,96
    80001b38:	9c4ff0ef          	jal	80000cfc <memset>
  p->context.ra = (uint64)forkret;
    80001b3c:	00000797          	auipc	a5,0x0
    80001b40:	e0878793          	addi	a5,a5,-504 # 80001944 <forkret>
    80001b44:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b46:	60bc                	ld	a5,64(s1)
    80001b48:	6705                	lui	a4,0x1
    80001b4a:	97ba                	add	a5,a5,a4
    80001b4c:	f4bc                	sd	a5,104(s1)
}
    80001b4e:	8526                	mv	a0,s1
    80001b50:	60e2                	ld	ra,24(sp)
    80001b52:	6442                	ld	s0,16(sp)
    80001b54:	64a2                	ld	s1,8(sp)
    80001b56:	6902                	ld	s2,0(sp)
    80001b58:	6105                	addi	sp,sp,32
    80001b5a:	8082                	ret
    freeproc(p);
    80001b5c:	8526                	mv	a0,s1
    80001b5e:	f29ff0ef          	jal	80001a86 <freeproc>
    release(&p->lock);
    80001b62:	8526                	mv	a0,s1
    80001b64:	95cff0ef          	jal	80000cc0 <release>
    return 0;
    80001b68:	84ca                	mv	s1,s2
    80001b6a:	b7d5                	j	80001b4e <allocproc+0x78>
    freeproc(p);
    80001b6c:	8526                	mv	a0,s1
    80001b6e:	f19ff0ef          	jal	80001a86 <freeproc>
    release(&p->lock);
    80001b72:	8526                	mv	a0,s1
    80001b74:	94cff0ef          	jal	80000cc0 <release>
    return 0;
    80001b78:	84ca                	mv	s1,s2
    80001b7a:	bfd1                	j	80001b4e <allocproc+0x78>

0000000080001b7c <userinit>:
{
    80001b7c:	1101                	addi	sp,sp,-32
    80001b7e:	ec06                	sd	ra,24(sp)
    80001b80:	e822                	sd	s0,16(sp)
    80001b82:	e426                	sd	s1,8(sp)
    80001b84:	1000                	addi	s0,sp,32
  p = allocproc();
    80001b86:	f51ff0ef          	jal	80001ad6 <allocproc>
    80001b8a:	84aa                	mv	s1,a0
  initproc = p;
    80001b8c:	00009797          	auipc	a5,0x9
    80001b90:	8ea7b623          	sd	a0,-1812(a5) # 8000a478 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001b94:	03400613          	li	a2,52
    80001b98:	00009597          	auipc	a1,0x9
    80001b9c:	85858593          	addi	a1,a1,-1960 # 8000a3f0 <initcode>
    80001ba0:	6928                	ld	a0,80(a0)
    80001ba2:	f2eff0ef          	jal	800012d0 <uvmfirst>
  p->sz = PGSIZE;
    80001ba6:	6785                	lui	a5,0x1
    80001ba8:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001baa:	6cb8                	ld	a4,88(s1)
    80001bac:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001bb0:	6cb8                	ld	a4,88(s1)
    80001bb2:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001bb4:	4641                	li	a2,16
    80001bb6:	00005597          	auipc	a1,0x5
    80001bba:	66a58593          	addi	a1,a1,1642 # 80007220 <etext+0x220>
    80001bbe:	15848513          	addi	a0,s1,344
    80001bc2:	a78ff0ef          	jal	80000e3a <safestrcpy>
  p->cwd = namei("/");
    80001bc6:	00005517          	auipc	a0,0x5
    80001bca:	66a50513          	addi	a0,a0,1642 # 80007230 <etext+0x230>
    80001bce:	0ec020ef          	jal	80003cba <namei>
    80001bd2:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001bd6:	478d                	li	a5,3
    80001bd8:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001bda:	8526                	mv	a0,s1
    80001bdc:	8e4ff0ef          	jal	80000cc0 <release>
}
    80001be0:	60e2                	ld	ra,24(sp)
    80001be2:	6442                	ld	s0,16(sp)
    80001be4:	64a2                	ld	s1,8(sp)
    80001be6:	6105                	addi	sp,sp,32
    80001be8:	8082                	ret

0000000080001bea <growproc>:
{
    80001bea:	1101                	addi	sp,sp,-32
    80001bec:	ec06                	sd	ra,24(sp)
    80001bee:	e822                	sd	s0,16(sp)
    80001bf0:	e426                	sd	s1,8(sp)
    80001bf2:	e04a                	sd	s2,0(sp)
    80001bf4:	1000                	addi	s0,sp,32
    80001bf6:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001bf8:	d1dff0ef          	jal	80001914 <myproc>
    80001bfc:	84aa                	mv	s1,a0
  sz = p->sz;
    80001bfe:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001c00:	01204c63          	bgtz	s2,80001c18 <growproc+0x2e>
  } else if(n < 0){
    80001c04:	02094463          	bltz	s2,80001c2c <growproc+0x42>
  p->sz = sz;
    80001c08:	e4ac                	sd	a1,72(s1)
  return 0;
    80001c0a:	4501                	li	a0,0
}
    80001c0c:	60e2                	ld	ra,24(sp)
    80001c0e:	6442                	ld	s0,16(sp)
    80001c10:	64a2                	ld	s1,8(sp)
    80001c12:	6902                	ld	s2,0(sp)
    80001c14:	6105                	addi	sp,sp,32
    80001c16:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c18:	4691                	li	a3,4
    80001c1a:	00b90633          	add	a2,s2,a1
    80001c1e:	6928                	ld	a0,80(a0)
    80001c20:	f52ff0ef          	jal	80001372 <uvmalloc>
    80001c24:	85aa                	mv	a1,a0
    80001c26:	f16d                	bnez	a0,80001c08 <growproc+0x1e>
      return -1;
    80001c28:	557d                	li	a0,-1
    80001c2a:	b7cd                	j	80001c0c <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c2c:	00b90633          	add	a2,s2,a1
    80001c30:	6928                	ld	a0,80(a0)
    80001c32:	efcff0ef          	jal	8000132e <uvmdealloc>
    80001c36:	85aa                	mv	a1,a0
    80001c38:	bfc1                	j	80001c08 <growproc+0x1e>

0000000080001c3a <fork>:
{
    80001c3a:	7139                	addi	sp,sp,-64
    80001c3c:	fc06                	sd	ra,56(sp)
    80001c3e:	f822                	sd	s0,48(sp)
    80001c40:	f04a                	sd	s2,32(sp)
    80001c42:	e456                	sd	s5,8(sp)
    80001c44:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c46:	ccfff0ef          	jal	80001914 <myproc>
    80001c4a:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001c4c:	e8bff0ef          	jal	80001ad6 <allocproc>
    80001c50:	0e050a63          	beqz	a0,80001d44 <fork+0x10a>
    80001c54:	e852                	sd	s4,16(sp)
    80001c56:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001c58:	048ab603          	ld	a2,72(s5)
    80001c5c:	692c                	ld	a1,80(a0)
    80001c5e:	050ab503          	ld	a0,80(s5)
    80001c62:	849ff0ef          	jal	800014aa <uvmcopy>
    80001c66:	04054a63          	bltz	a0,80001cba <fork+0x80>
    80001c6a:	f426                	sd	s1,40(sp)
    80001c6c:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001c6e:	048ab783          	ld	a5,72(s5)
    80001c72:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001c76:	058ab683          	ld	a3,88(s5)
    80001c7a:	87b6                	mv	a5,a3
    80001c7c:	058a3703          	ld	a4,88(s4)
    80001c80:	12068693          	addi	a3,a3,288
    80001c84:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001c88:	6788                	ld	a0,8(a5)
    80001c8a:	6b8c                	ld	a1,16(a5)
    80001c8c:	6f90                	ld	a2,24(a5)
    80001c8e:	01073023          	sd	a6,0(a4)
    80001c92:	e708                	sd	a0,8(a4)
    80001c94:	eb0c                	sd	a1,16(a4)
    80001c96:	ef10                	sd	a2,24(a4)
    80001c98:	02078793          	addi	a5,a5,32
    80001c9c:	02070713          	addi	a4,a4,32
    80001ca0:	fed792e3          	bne	a5,a3,80001c84 <fork+0x4a>
  np->trapframe->a0 = 0;
    80001ca4:	058a3783          	ld	a5,88(s4)
    80001ca8:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001cac:	0d0a8493          	addi	s1,s5,208
    80001cb0:	0d0a0913          	addi	s2,s4,208
    80001cb4:	150a8993          	addi	s3,s5,336
    80001cb8:	a831                	j	80001cd4 <fork+0x9a>
    freeproc(np);
    80001cba:	8552                	mv	a0,s4
    80001cbc:	dcbff0ef          	jal	80001a86 <freeproc>
    release(&np->lock);
    80001cc0:	8552                	mv	a0,s4
    80001cc2:	ffffe0ef          	jal	80000cc0 <release>
    return -1;
    80001cc6:	597d                	li	s2,-1
    80001cc8:	6a42                	ld	s4,16(sp)
    80001cca:	a0b5                	j	80001d36 <fork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001ccc:	04a1                	addi	s1,s1,8
    80001cce:	0921                	addi	s2,s2,8
    80001cd0:	01348963          	beq	s1,s3,80001ce2 <fork+0xa8>
    if(p->ofile[i])
    80001cd4:	6088                	ld	a0,0(s1)
    80001cd6:	d97d                	beqz	a0,80001ccc <fork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001cd8:	572020ef          	jal	8000424a <filedup>
    80001cdc:	00a93023          	sd	a0,0(s2)
    80001ce0:	b7f5                	j	80001ccc <fork+0x92>
  np->cwd = idup(p->cwd);
    80001ce2:	150ab503          	ld	a0,336(s5)
    80001ce6:	0c5010ef          	jal	800035aa <idup>
    80001cea:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001cee:	4641                	li	a2,16
    80001cf0:	158a8593          	addi	a1,s5,344
    80001cf4:	158a0513          	addi	a0,s4,344
    80001cf8:	942ff0ef          	jal	80000e3a <safestrcpy>
  pid = np->pid;
    80001cfc:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001d00:	8552                	mv	a0,s4
    80001d02:	fbffe0ef          	jal	80000cc0 <release>
  acquire(&wait_lock);
    80001d06:	00011497          	auipc	s1,0x11
    80001d0a:	8c248493          	addi	s1,s1,-1854 # 800125c8 <wait_lock>
    80001d0e:	8526                	mv	a0,s1
    80001d10:	f19fe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001d14:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001d18:	8526                	mv	a0,s1
    80001d1a:	fa7fe0ef          	jal	80000cc0 <release>
  acquire(&np->lock);
    80001d1e:	8552                	mv	a0,s4
    80001d20:	f09fe0ef          	jal	80000c28 <acquire>
  np->state = RUNNABLE;
    80001d24:	478d                	li	a5,3
    80001d26:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001d2a:	8552                	mv	a0,s4
    80001d2c:	f95fe0ef          	jal	80000cc0 <release>
  return pid;
    80001d30:	74a2                	ld	s1,40(sp)
    80001d32:	69e2                	ld	s3,24(sp)
    80001d34:	6a42                	ld	s4,16(sp)
}
    80001d36:	854a                	mv	a0,s2
    80001d38:	70e2                	ld	ra,56(sp)
    80001d3a:	7442                	ld	s0,48(sp)
    80001d3c:	7902                	ld	s2,32(sp)
    80001d3e:	6aa2                	ld	s5,8(sp)
    80001d40:	6121                	addi	sp,sp,64
    80001d42:	8082                	ret
    return -1;
    80001d44:	597d                	li	s2,-1
    80001d46:	bfc5                	j	80001d36 <fork+0xfc>

0000000080001d48 <scheduler>:
{
    80001d48:	715d                	addi	sp,sp,-80
    80001d4a:	e486                	sd	ra,72(sp)
    80001d4c:	e0a2                	sd	s0,64(sp)
    80001d4e:	fc26                	sd	s1,56(sp)
    80001d50:	f84a                	sd	s2,48(sp)
    80001d52:	f44e                	sd	s3,40(sp)
    80001d54:	f052                	sd	s4,32(sp)
    80001d56:	ec56                	sd	s5,24(sp)
    80001d58:	e85a                	sd	s6,16(sp)
    80001d5a:	e45e                	sd	s7,8(sp)
    80001d5c:	e062                	sd	s8,0(sp)
    80001d5e:	0880                	addi	s0,sp,80
    80001d60:	8792                	mv	a5,tp
  int id = r_tp();
    80001d62:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d64:	00779b13          	slli	s6,a5,0x7
    80001d68:	00011717          	auipc	a4,0x11
    80001d6c:	84870713          	addi	a4,a4,-1976 # 800125b0 <pid_lock>
    80001d70:	975a                	add	a4,a4,s6
    80001d72:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001d76:	00011717          	auipc	a4,0x11
    80001d7a:	87270713          	addi	a4,a4,-1934 # 800125e8 <cpus+0x8>
    80001d7e:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001d80:	4c11                	li	s8,4
        c->proc = p;
    80001d82:	079e                	slli	a5,a5,0x7
    80001d84:	00011a17          	auipc	s4,0x11
    80001d88:	82ca0a13          	addi	s4,s4,-2004 # 800125b0 <pid_lock>
    80001d8c:	9a3e                	add	s4,s4,a5
        found = 1;
    80001d8e:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d90:	00016997          	auipc	s3,0x16
    80001d94:	65098993          	addi	s3,s3,1616 # 800183e0 <tickslock>
    80001d98:	a0a9                	j	80001de2 <scheduler+0x9a>
      release(&p->lock);
    80001d9a:	8526                	mv	a0,s1
    80001d9c:	f25fe0ef          	jal	80000cc0 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001da0:	16848493          	addi	s1,s1,360
    80001da4:	03348563          	beq	s1,s3,80001dce <scheduler+0x86>
      acquire(&p->lock);
    80001da8:	8526                	mv	a0,s1
    80001daa:	e7ffe0ef          	jal	80000c28 <acquire>
      if(p->state == RUNNABLE) {
    80001dae:	4c9c                	lw	a5,24(s1)
    80001db0:	ff2795e3          	bne	a5,s2,80001d9a <scheduler+0x52>
        p->state = RUNNING;
    80001db4:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001db8:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001dbc:	06048593          	addi	a1,s1,96
    80001dc0:	855a                	mv	a0,s6
    80001dc2:	7c2000ef          	jal	80002584 <swtch>
        c->proc = 0;
    80001dc6:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001dca:	8ade                	mv	s5,s7
    80001dcc:	b7f9                	j	80001d9a <scheduler+0x52>
    if(found == 0) {
    80001dce:	000a9a63          	bnez	s5,80001de2 <scheduler+0x9a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dd2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001dd6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001dda:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001dde:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001de2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001de6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001dea:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001dee:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001df0:	00011497          	auipc	s1,0x11
    80001df4:	bf048493          	addi	s1,s1,-1040 # 800129e0 <proc>
      if(p->state == RUNNABLE) {
    80001df8:	490d                	li	s2,3
    80001dfa:	b77d                	j	80001da8 <scheduler+0x60>

0000000080001dfc <sched>:
{
    80001dfc:	7179                	addi	sp,sp,-48
    80001dfe:	f406                	sd	ra,40(sp)
    80001e00:	f022                	sd	s0,32(sp)
    80001e02:	ec26                	sd	s1,24(sp)
    80001e04:	e84a                	sd	s2,16(sp)
    80001e06:	e44e                	sd	s3,8(sp)
    80001e08:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e0a:	b0bff0ef          	jal	80001914 <myproc>
    80001e0e:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001e10:	daffe0ef          	jal	80000bbe <holding>
    80001e14:	c92d                	beqz	a0,80001e86 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e16:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001e18:	2781                	sext.w	a5,a5
    80001e1a:	079e                	slli	a5,a5,0x7
    80001e1c:	00010717          	auipc	a4,0x10
    80001e20:	79470713          	addi	a4,a4,1940 # 800125b0 <pid_lock>
    80001e24:	97ba                	add	a5,a5,a4
    80001e26:	0a87a703          	lw	a4,168(a5)
    80001e2a:	4785                	li	a5,1
    80001e2c:	06f71363          	bne	a4,a5,80001e92 <sched+0x96>
  if(p->state == RUNNING)
    80001e30:	4c98                	lw	a4,24(s1)
    80001e32:	4791                	li	a5,4
    80001e34:	06f70563          	beq	a4,a5,80001e9e <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e38:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e3c:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e3e:	e7b5                	bnez	a5,80001eaa <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e40:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e42:	00010917          	auipc	s2,0x10
    80001e46:	76e90913          	addi	s2,s2,1902 # 800125b0 <pid_lock>
    80001e4a:	2781                	sext.w	a5,a5
    80001e4c:	079e                	slli	a5,a5,0x7
    80001e4e:	97ca                	add	a5,a5,s2
    80001e50:	0ac7a983          	lw	s3,172(a5)
    80001e54:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e56:	2781                	sext.w	a5,a5
    80001e58:	079e                	slli	a5,a5,0x7
    80001e5a:	00010597          	auipc	a1,0x10
    80001e5e:	78e58593          	addi	a1,a1,1934 # 800125e8 <cpus+0x8>
    80001e62:	95be                	add	a1,a1,a5
    80001e64:	06048513          	addi	a0,s1,96
    80001e68:	71c000ef          	jal	80002584 <swtch>
    80001e6c:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e6e:	2781                	sext.w	a5,a5
    80001e70:	079e                	slli	a5,a5,0x7
    80001e72:	993e                	add	s2,s2,a5
    80001e74:	0b392623          	sw	s3,172(s2)
}
    80001e78:	70a2                	ld	ra,40(sp)
    80001e7a:	7402                	ld	s0,32(sp)
    80001e7c:	64e2                	ld	s1,24(sp)
    80001e7e:	6942                	ld	s2,16(sp)
    80001e80:	69a2                	ld	s3,8(sp)
    80001e82:	6145                	addi	sp,sp,48
    80001e84:	8082                	ret
    panic("sched p->lock");
    80001e86:	00005517          	auipc	a0,0x5
    80001e8a:	3b250513          	addi	a0,a0,946 # 80007238 <etext+0x238>
    80001e8e:	93bfe0ef          	jal	800007c8 <panic>
    panic("sched locks");
    80001e92:	00005517          	auipc	a0,0x5
    80001e96:	3b650513          	addi	a0,a0,950 # 80007248 <etext+0x248>
    80001e9a:	92ffe0ef          	jal	800007c8 <panic>
    panic("sched running");
    80001e9e:	00005517          	auipc	a0,0x5
    80001ea2:	3ba50513          	addi	a0,a0,954 # 80007258 <etext+0x258>
    80001ea6:	923fe0ef          	jal	800007c8 <panic>
    panic("sched interruptible");
    80001eaa:	00005517          	auipc	a0,0x5
    80001eae:	3be50513          	addi	a0,a0,958 # 80007268 <etext+0x268>
    80001eb2:	917fe0ef          	jal	800007c8 <panic>

0000000080001eb6 <yield>:
{
    80001eb6:	1101                	addi	sp,sp,-32
    80001eb8:	ec06                	sd	ra,24(sp)
    80001eba:	e822                	sd	s0,16(sp)
    80001ebc:	e426                	sd	s1,8(sp)
    80001ebe:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001ec0:	a55ff0ef          	jal	80001914 <myproc>
    80001ec4:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001ec6:	d63fe0ef          	jal	80000c28 <acquire>
  p->state = RUNNABLE;
    80001eca:	478d                	li	a5,3
    80001ecc:	cc9c                	sw	a5,24(s1)
  sched();
    80001ece:	f2fff0ef          	jal	80001dfc <sched>
  release(&p->lock);
    80001ed2:	8526                	mv	a0,s1
    80001ed4:	dedfe0ef          	jal	80000cc0 <release>
}
    80001ed8:	60e2                	ld	ra,24(sp)
    80001eda:	6442                	ld	s0,16(sp)
    80001edc:	64a2                	ld	s1,8(sp)
    80001ede:	6105                	addi	sp,sp,32
    80001ee0:	8082                	ret

0000000080001ee2 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001ee2:	7179                	addi	sp,sp,-48
    80001ee4:	f406                	sd	ra,40(sp)
    80001ee6:	f022                	sd	s0,32(sp)
    80001ee8:	ec26                	sd	s1,24(sp)
    80001eea:	e84a                	sd	s2,16(sp)
    80001eec:	e44e                	sd	s3,8(sp)
    80001eee:	1800                	addi	s0,sp,48
    80001ef0:	89aa                	mv	s3,a0
    80001ef2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001ef4:	a21ff0ef          	jal	80001914 <myproc>
    80001ef8:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001efa:	d2ffe0ef          	jal	80000c28 <acquire>
  release(lk);
    80001efe:	854a                	mv	a0,s2
    80001f00:	dc1fe0ef          	jal	80000cc0 <release>

  // Go to sleep.
  p->chan = chan;
    80001f04:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001f08:	4789                	li	a5,2
    80001f0a:	cc9c                	sw	a5,24(s1)

  sched();
    80001f0c:	ef1ff0ef          	jal	80001dfc <sched>

  // Tidy up.
  p->chan = 0;
    80001f10:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001f14:	8526                	mv	a0,s1
    80001f16:	dabfe0ef          	jal	80000cc0 <release>
  acquire(lk);
    80001f1a:	854a                	mv	a0,s2
    80001f1c:	d0dfe0ef          	jal	80000c28 <acquire>
}
    80001f20:	70a2                	ld	ra,40(sp)
    80001f22:	7402                	ld	s0,32(sp)
    80001f24:	64e2                	ld	s1,24(sp)
    80001f26:	6942                	ld	s2,16(sp)
    80001f28:	69a2                	ld	s3,8(sp)
    80001f2a:	6145                	addi	sp,sp,48
    80001f2c:	8082                	ret

0000000080001f2e <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001f2e:	7139                	addi	sp,sp,-64
    80001f30:	fc06                	sd	ra,56(sp)
    80001f32:	f822                	sd	s0,48(sp)
    80001f34:	f426                	sd	s1,40(sp)
    80001f36:	f04a                	sd	s2,32(sp)
    80001f38:	ec4e                	sd	s3,24(sp)
    80001f3a:	e852                	sd	s4,16(sp)
    80001f3c:	e456                	sd	s5,8(sp)
    80001f3e:	0080                	addi	s0,sp,64
    80001f40:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001f42:	00011497          	auipc	s1,0x11
    80001f46:	a9e48493          	addi	s1,s1,-1378 # 800129e0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001f4a:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f4c:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f4e:	00016917          	auipc	s2,0x16
    80001f52:	49290913          	addi	s2,s2,1170 # 800183e0 <tickslock>
    80001f56:	a801                	j	80001f66 <wakeup+0x38>
      }
      release(&p->lock);
    80001f58:	8526                	mv	a0,s1
    80001f5a:	d67fe0ef          	jal	80000cc0 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f5e:	16848493          	addi	s1,s1,360
    80001f62:	03248263          	beq	s1,s2,80001f86 <wakeup+0x58>
    if(p != myproc()){
    80001f66:	9afff0ef          	jal	80001914 <myproc>
    80001f6a:	fea48ae3          	beq	s1,a0,80001f5e <wakeup+0x30>
      acquire(&p->lock);
    80001f6e:	8526                	mv	a0,s1
    80001f70:	cb9fe0ef          	jal	80000c28 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001f74:	4c9c                	lw	a5,24(s1)
    80001f76:	ff3791e3          	bne	a5,s3,80001f58 <wakeup+0x2a>
    80001f7a:	709c                	ld	a5,32(s1)
    80001f7c:	fd479ee3          	bne	a5,s4,80001f58 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001f80:	0154ac23          	sw	s5,24(s1)
    80001f84:	bfd1                	j	80001f58 <wakeup+0x2a>
    }
  }
}
    80001f86:	70e2                	ld	ra,56(sp)
    80001f88:	7442                	ld	s0,48(sp)
    80001f8a:	74a2                	ld	s1,40(sp)
    80001f8c:	7902                	ld	s2,32(sp)
    80001f8e:	69e2                	ld	s3,24(sp)
    80001f90:	6a42                	ld	s4,16(sp)
    80001f92:	6aa2                	ld	s5,8(sp)
    80001f94:	6121                	addi	sp,sp,64
    80001f96:	8082                	ret

0000000080001f98 <reparent>:
{
    80001f98:	7179                	addi	sp,sp,-48
    80001f9a:	f406                	sd	ra,40(sp)
    80001f9c:	f022                	sd	s0,32(sp)
    80001f9e:	ec26                	sd	s1,24(sp)
    80001fa0:	e84a                	sd	s2,16(sp)
    80001fa2:	e44e                	sd	s3,8(sp)
    80001fa4:	e052                	sd	s4,0(sp)
    80001fa6:	1800                	addi	s0,sp,48
    80001fa8:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001faa:	00011497          	auipc	s1,0x11
    80001fae:	a3648493          	addi	s1,s1,-1482 # 800129e0 <proc>
      pp->parent = initproc;
    80001fb2:	00008a17          	auipc	s4,0x8
    80001fb6:	4c6a0a13          	addi	s4,s4,1222 # 8000a478 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001fba:	00016997          	auipc	s3,0x16
    80001fbe:	42698993          	addi	s3,s3,1062 # 800183e0 <tickslock>
    80001fc2:	a029                	j	80001fcc <reparent+0x34>
    80001fc4:	16848493          	addi	s1,s1,360
    80001fc8:	01348b63          	beq	s1,s3,80001fde <reparent+0x46>
    if(pp->parent == p){
    80001fcc:	7c9c                	ld	a5,56(s1)
    80001fce:	ff279be3          	bne	a5,s2,80001fc4 <reparent+0x2c>
      pp->parent = initproc;
    80001fd2:	000a3503          	ld	a0,0(s4)
    80001fd6:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001fd8:	f57ff0ef          	jal	80001f2e <wakeup>
    80001fdc:	b7e5                	j	80001fc4 <reparent+0x2c>
}
    80001fde:	70a2                	ld	ra,40(sp)
    80001fe0:	7402                	ld	s0,32(sp)
    80001fe2:	64e2                	ld	s1,24(sp)
    80001fe4:	6942                	ld	s2,16(sp)
    80001fe6:	69a2                	ld	s3,8(sp)
    80001fe8:	6a02                	ld	s4,0(sp)
    80001fea:	6145                	addi	sp,sp,48
    80001fec:	8082                	ret

0000000080001fee <exit>:
{
    80001fee:	7179                	addi	sp,sp,-48
    80001ff0:	f406                	sd	ra,40(sp)
    80001ff2:	f022                	sd	s0,32(sp)
    80001ff4:	ec26                	sd	s1,24(sp)
    80001ff6:	e84a                	sd	s2,16(sp)
    80001ff8:	e44e                	sd	s3,8(sp)
    80001ffa:	e052                	sd	s4,0(sp)
    80001ffc:	1800                	addi	s0,sp,48
    80001ffe:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002000:	915ff0ef          	jal	80001914 <myproc>
    80002004:	89aa                	mv	s3,a0
  if(p == initproc)
    80002006:	00008797          	auipc	a5,0x8
    8000200a:	4727b783          	ld	a5,1138(a5) # 8000a478 <initproc>
    8000200e:	0d050493          	addi	s1,a0,208
    80002012:	15050913          	addi	s2,a0,336
    80002016:	00a79f63          	bne	a5,a0,80002034 <exit+0x46>
    panic("init exiting");
    8000201a:	00005517          	auipc	a0,0x5
    8000201e:	26650513          	addi	a0,a0,614 # 80007280 <etext+0x280>
    80002022:	fa6fe0ef          	jal	800007c8 <panic>
      fileclose(f);
    80002026:	26a020ef          	jal	80004290 <fileclose>
      p->ofile[fd] = 0;
    8000202a:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000202e:	04a1                	addi	s1,s1,8
    80002030:	01248563          	beq	s1,s2,8000203a <exit+0x4c>
    if(p->ofile[fd]){
    80002034:	6088                	ld	a0,0(s1)
    80002036:	f965                	bnez	a0,80002026 <exit+0x38>
    80002038:	bfdd                	j	8000202e <exit+0x40>
  begin_op();
    8000203a:	63d010ef          	jal	80003e76 <begin_op>
  iput(p->cwd);
    8000203e:	1509b503          	ld	a0,336(s3)
    80002042:	720010ef          	jal	80003762 <iput>
  end_op();
    80002046:	69b010ef          	jal	80003ee0 <end_op>
  p->cwd = 0;
    8000204a:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000204e:	00010497          	auipc	s1,0x10
    80002052:	57a48493          	addi	s1,s1,1402 # 800125c8 <wait_lock>
    80002056:	8526                	mv	a0,s1
    80002058:	bd1fe0ef          	jal	80000c28 <acquire>
  reparent(p);
    8000205c:	854e                	mv	a0,s3
    8000205e:	f3bff0ef          	jal	80001f98 <reparent>
  wakeup(p->parent);
    80002062:	0389b503          	ld	a0,56(s3)
    80002066:	ec9ff0ef          	jal	80001f2e <wakeup>
  acquire(&p->lock);
    8000206a:	854e                	mv	a0,s3
    8000206c:	bbdfe0ef          	jal	80000c28 <acquire>
  p->xstate = status;
    80002070:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002074:	4795                	li	a5,5
    80002076:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000207a:	8526                	mv	a0,s1
    8000207c:	c45fe0ef          	jal	80000cc0 <release>
  sched();
    80002080:	d7dff0ef          	jal	80001dfc <sched>
  panic("zombie exit");
    80002084:	00005517          	auipc	a0,0x5
    80002088:	20c50513          	addi	a0,a0,524 # 80007290 <etext+0x290>
    8000208c:	f3cfe0ef          	jal	800007c8 <panic>

0000000080002090 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002090:	7179                	addi	sp,sp,-48
    80002092:	f406                	sd	ra,40(sp)
    80002094:	f022                	sd	s0,32(sp)
    80002096:	ec26                	sd	s1,24(sp)
    80002098:	e84a                	sd	s2,16(sp)
    8000209a:	e44e                	sd	s3,8(sp)
    8000209c:	1800                	addi	s0,sp,48
    8000209e:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800020a0:	00011497          	auipc	s1,0x11
    800020a4:	94048493          	addi	s1,s1,-1728 # 800129e0 <proc>
    800020a8:	00016997          	auipc	s3,0x16
    800020ac:	33898993          	addi	s3,s3,824 # 800183e0 <tickslock>
    acquire(&p->lock);
    800020b0:	8526                	mv	a0,s1
    800020b2:	b77fe0ef          	jal	80000c28 <acquire>
    if(p->pid == pid){
    800020b6:	589c                	lw	a5,48(s1)
    800020b8:	01278b63          	beq	a5,s2,800020ce <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800020bc:	8526                	mv	a0,s1
    800020be:	c03fe0ef          	jal	80000cc0 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800020c2:	16848493          	addi	s1,s1,360
    800020c6:	ff3495e3          	bne	s1,s3,800020b0 <kill+0x20>
  }
  return -1;
    800020ca:	557d                	li	a0,-1
    800020cc:	a819                	j	800020e2 <kill+0x52>
      p->killed = 1;
    800020ce:	4785                	li	a5,1
    800020d0:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800020d2:	4c98                	lw	a4,24(s1)
    800020d4:	4789                	li	a5,2
    800020d6:	00f70d63          	beq	a4,a5,800020f0 <kill+0x60>
      release(&p->lock);
    800020da:	8526                	mv	a0,s1
    800020dc:	be5fe0ef          	jal	80000cc0 <release>
      return 0;
    800020e0:	4501                	li	a0,0
}
    800020e2:	70a2                	ld	ra,40(sp)
    800020e4:	7402                	ld	s0,32(sp)
    800020e6:	64e2                	ld	s1,24(sp)
    800020e8:	6942                	ld	s2,16(sp)
    800020ea:	69a2                	ld	s3,8(sp)
    800020ec:	6145                	addi	sp,sp,48
    800020ee:	8082                	ret
        p->state = RUNNABLE;
    800020f0:	478d                	li	a5,3
    800020f2:	cc9c                	sw	a5,24(s1)
    800020f4:	b7dd                	j	800020da <kill+0x4a>

00000000800020f6 <setkilled>:

void
setkilled(struct proc *p)
{
    800020f6:	1101                	addi	sp,sp,-32
    800020f8:	ec06                	sd	ra,24(sp)
    800020fa:	e822                	sd	s0,16(sp)
    800020fc:	e426                	sd	s1,8(sp)
    800020fe:	1000                	addi	s0,sp,32
    80002100:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002102:	b27fe0ef          	jal	80000c28 <acquire>
  p->killed = 1;
    80002106:	4785                	li	a5,1
    80002108:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000210a:	8526                	mv	a0,s1
    8000210c:	bb5fe0ef          	jal	80000cc0 <release>
}
    80002110:	60e2                	ld	ra,24(sp)
    80002112:	6442                	ld	s0,16(sp)
    80002114:	64a2                	ld	s1,8(sp)
    80002116:	6105                	addi	sp,sp,32
    80002118:	8082                	ret

000000008000211a <killed>:

int
killed(struct proc *p)
{
    8000211a:	1101                	addi	sp,sp,-32
    8000211c:	ec06                	sd	ra,24(sp)
    8000211e:	e822                	sd	s0,16(sp)
    80002120:	e426                	sd	s1,8(sp)
    80002122:	e04a                	sd	s2,0(sp)
    80002124:	1000                	addi	s0,sp,32
    80002126:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002128:	b01fe0ef          	jal	80000c28 <acquire>
  k = p->killed;
    8000212c:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002130:	8526                	mv	a0,s1
    80002132:	b8ffe0ef          	jal	80000cc0 <release>
  return k;
}
    80002136:	854a                	mv	a0,s2
    80002138:	60e2                	ld	ra,24(sp)
    8000213a:	6442                	ld	s0,16(sp)
    8000213c:	64a2                	ld	s1,8(sp)
    8000213e:	6902                	ld	s2,0(sp)
    80002140:	6105                	addi	sp,sp,32
    80002142:	8082                	ret

0000000080002144 <wait>:
{
    80002144:	715d                	addi	sp,sp,-80
    80002146:	e486                	sd	ra,72(sp)
    80002148:	e0a2                	sd	s0,64(sp)
    8000214a:	fc26                	sd	s1,56(sp)
    8000214c:	f84a                	sd	s2,48(sp)
    8000214e:	f44e                	sd	s3,40(sp)
    80002150:	f052                	sd	s4,32(sp)
    80002152:	ec56                	sd	s5,24(sp)
    80002154:	e85a                	sd	s6,16(sp)
    80002156:	e45e                	sd	s7,8(sp)
    80002158:	e062                	sd	s8,0(sp)
    8000215a:	0880                	addi	s0,sp,80
    8000215c:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000215e:	fb6ff0ef          	jal	80001914 <myproc>
    80002162:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002164:	00010517          	auipc	a0,0x10
    80002168:	46450513          	addi	a0,a0,1124 # 800125c8 <wait_lock>
    8000216c:	abdfe0ef          	jal	80000c28 <acquire>
    havekids = 0;
    80002170:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002172:	4a15                	li	s4,5
        havekids = 1;
    80002174:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002176:	00016997          	auipc	s3,0x16
    8000217a:	26a98993          	addi	s3,s3,618 # 800183e0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000217e:	00010c17          	auipc	s8,0x10
    80002182:	44ac0c13          	addi	s8,s8,1098 # 800125c8 <wait_lock>
    80002186:	a871                	j	80002222 <wait+0xde>
          pid = pp->pid;
    80002188:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000218c:	000b0c63          	beqz	s6,800021a4 <wait+0x60>
    80002190:	4691                	li	a3,4
    80002192:	02c48613          	addi	a2,s1,44
    80002196:	85da                	mv	a1,s6
    80002198:	05093503          	ld	a0,80(s2)
    8000219c:	beaff0ef          	jal	80001586 <copyout>
    800021a0:	02054b63          	bltz	a0,800021d6 <wait+0x92>
          freeproc(pp);
    800021a4:	8526                	mv	a0,s1
    800021a6:	8e1ff0ef          	jal	80001a86 <freeproc>
          release(&pp->lock);
    800021aa:	8526                	mv	a0,s1
    800021ac:	b15fe0ef          	jal	80000cc0 <release>
          release(&wait_lock);
    800021b0:	00010517          	auipc	a0,0x10
    800021b4:	41850513          	addi	a0,a0,1048 # 800125c8 <wait_lock>
    800021b8:	b09fe0ef          	jal	80000cc0 <release>
}
    800021bc:	854e                	mv	a0,s3
    800021be:	60a6                	ld	ra,72(sp)
    800021c0:	6406                	ld	s0,64(sp)
    800021c2:	74e2                	ld	s1,56(sp)
    800021c4:	7942                	ld	s2,48(sp)
    800021c6:	79a2                	ld	s3,40(sp)
    800021c8:	7a02                	ld	s4,32(sp)
    800021ca:	6ae2                	ld	s5,24(sp)
    800021cc:	6b42                	ld	s6,16(sp)
    800021ce:	6ba2                	ld	s7,8(sp)
    800021d0:	6c02                	ld	s8,0(sp)
    800021d2:	6161                	addi	sp,sp,80
    800021d4:	8082                	ret
            release(&pp->lock);
    800021d6:	8526                	mv	a0,s1
    800021d8:	ae9fe0ef          	jal	80000cc0 <release>
            release(&wait_lock);
    800021dc:	00010517          	auipc	a0,0x10
    800021e0:	3ec50513          	addi	a0,a0,1004 # 800125c8 <wait_lock>
    800021e4:	addfe0ef          	jal	80000cc0 <release>
            return -1;
    800021e8:	59fd                	li	s3,-1
    800021ea:	bfc9                	j	800021bc <wait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021ec:	16848493          	addi	s1,s1,360
    800021f0:	03348063          	beq	s1,s3,80002210 <wait+0xcc>
      if(pp->parent == p){
    800021f4:	7c9c                	ld	a5,56(s1)
    800021f6:	ff279be3          	bne	a5,s2,800021ec <wait+0xa8>
        acquire(&pp->lock);
    800021fa:	8526                	mv	a0,s1
    800021fc:	a2dfe0ef          	jal	80000c28 <acquire>
        if(pp->state == ZOMBIE){
    80002200:	4c9c                	lw	a5,24(s1)
    80002202:	f94783e3          	beq	a5,s4,80002188 <wait+0x44>
        release(&pp->lock);
    80002206:	8526                	mv	a0,s1
    80002208:	ab9fe0ef          	jal	80000cc0 <release>
        havekids = 1;
    8000220c:	8756                	mv	a4,s5
    8000220e:	bff9                	j	800021ec <wait+0xa8>
    if(!havekids || killed(p)){
    80002210:	cf19                	beqz	a4,8000222e <wait+0xea>
    80002212:	854a                	mv	a0,s2
    80002214:	f07ff0ef          	jal	8000211a <killed>
    80002218:	e919                	bnez	a0,8000222e <wait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000221a:	85e2                	mv	a1,s8
    8000221c:	854a                	mv	a0,s2
    8000221e:	cc5ff0ef          	jal	80001ee2 <sleep>
    havekids = 0;
    80002222:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002224:	00010497          	auipc	s1,0x10
    80002228:	7bc48493          	addi	s1,s1,1980 # 800129e0 <proc>
    8000222c:	b7e1                	j	800021f4 <wait+0xb0>
      release(&wait_lock);
    8000222e:	00010517          	auipc	a0,0x10
    80002232:	39a50513          	addi	a0,a0,922 # 800125c8 <wait_lock>
    80002236:	a8bfe0ef          	jal	80000cc0 <release>
      return -1;
    8000223a:	59fd                	li	s3,-1
    8000223c:	b741                	j	800021bc <wait+0x78>

000000008000223e <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000223e:	7179                	addi	sp,sp,-48
    80002240:	f406                	sd	ra,40(sp)
    80002242:	f022                	sd	s0,32(sp)
    80002244:	ec26                	sd	s1,24(sp)
    80002246:	e84a                	sd	s2,16(sp)
    80002248:	e44e                	sd	s3,8(sp)
    8000224a:	e052                	sd	s4,0(sp)
    8000224c:	1800                	addi	s0,sp,48
    8000224e:	84aa                	mv	s1,a0
    80002250:	892e                	mv	s2,a1
    80002252:	89b2                	mv	s3,a2
    80002254:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002256:	ebeff0ef          	jal	80001914 <myproc>
  if(user_dst){
    8000225a:	cc99                	beqz	s1,80002278 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    8000225c:	86d2                	mv	a3,s4
    8000225e:	864e                	mv	a2,s3
    80002260:	85ca                	mv	a1,s2
    80002262:	6928                	ld	a0,80(a0)
    80002264:	b22ff0ef          	jal	80001586 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002268:	70a2                	ld	ra,40(sp)
    8000226a:	7402                	ld	s0,32(sp)
    8000226c:	64e2                	ld	s1,24(sp)
    8000226e:	6942                	ld	s2,16(sp)
    80002270:	69a2                	ld	s3,8(sp)
    80002272:	6a02                	ld	s4,0(sp)
    80002274:	6145                	addi	sp,sp,48
    80002276:	8082                	ret
    memmove((char *)dst, src, len);
    80002278:	000a061b          	sext.w	a2,s4
    8000227c:	85ce                	mv	a1,s3
    8000227e:	854a                	mv	a0,s2
    80002280:	ad9fe0ef          	jal	80000d58 <memmove>
    return 0;
    80002284:	8526                	mv	a0,s1
    80002286:	b7cd                	j	80002268 <either_copyout+0x2a>

0000000080002288 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002288:	7179                	addi	sp,sp,-48
    8000228a:	f406                	sd	ra,40(sp)
    8000228c:	f022                	sd	s0,32(sp)
    8000228e:	ec26                	sd	s1,24(sp)
    80002290:	e84a                	sd	s2,16(sp)
    80002292:	e44e                	sd	s3,8(sp)
    80002294:	e052                	sd	s4,0(sp)
    80002296:	1800                	addi	s0,sp,48
    80002298:	892a                	mv	s2,a0
    8000229a:	84ae                	mv	s1,a1
    8000229c:	89b2                	mv	s3,a2
    8000229e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800022a0:	e74ff0ef          	jal	80001914 <myproc>
  if(user_src){
    800022a4:	cc99                	beqz	s1,800022c2 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800022a6:	86d2                	mv	a3,s4
    800022a8:	864e                	mv	a2,s3
    800022aa:	85ca                	mv	a1,s2
    800022ac:	6928                	ld	a0,80(a0)
    800022ae:	baeff0ef          	jal	8000165c <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800022b2:	70a2                	ld	ra,40(sp)
    800022b4:	7402                	ld	s0,32(sp)
    800022b6:	64e2                	ld	s1,24(sp)
    800022b8:	6942                	ld	s2,16(sp)
    800022ba:	69a2                	ld	s3,8(sp)
    800022bc:	6a02                	ld	s4,0(sp)
    800022be:	6145                	addi	sp,sp,48
    800022c0:	8082                	ret
    memmove(dst, (char*)src, len);
    800022c2:	000a061b          	sext.w	a2,s4
    800022c6:	85ce                	mv	a1,s3
    800022c8:	854a                	mv	a0,s2
    800022ca:	a8ffe0ef          	jal	80000d58 <memmove>
    return 0;
    800022ce:	8526                	mv	a0,s1
    800022d0:	b7cd                	j	800022b2 <either_copyin+0x2a>

00000000800022d2 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800022d2:	715d                	addi	sp,sp,-80
    800022d4:	e486                	sd	ra,72(sp)
    800022d6:	e0a2                	sd	s0,64(sp)
    800022d8:	fc26                	sd	s1,56(sp)
    800022da:	f84a                	sd	s2,48(sp)
    800022dc:	f44e                	sd	s3,40(sp)
    800022de:	f052                	sd	s4,32(sp)
    800022e0:	ec56                	sd	s5,24(sp)
    800022e2:	e85a                	sd	s6,16(sp)
    800022e4:	e45e                	sd	s7,8(sp)
    800022e6:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800022e8:	00005517          	auipc	a0,0x5
    800022ec:	d9050513          	addi	a0,a0,-624 # 80007078 <etext+0x78>
    800022f0:	a06fe0ef          	jal	800004f6 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800022f4:	00011497          	auipc	s1,0x11
    800022f8:	84448493          	addi	s1,s1,-1980 # 80012b38 <proc+0x158>
    800022fc:	00016917          	auipc	s2,0x16
    80002300:	23c90913          	addi	s2,s2,572 # 80018538 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002304:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002306:	00005997          	auipc	s3,0x5
    8000230a:	f9a98993          	addi	s3,s3,-102 # 800072a0 <etext+0x2a0>
    printf("%d %s %s", p->pid, state, p->name);
    8000230e:	00005a97          	auipc	s5,0x5
    80002312:	f9aa8a93          	addi	s5,s5,-102 # 800072a8 <etext+0x2a8>
    printf("\n");
    80002316:	00005a17          	auipc	s4,0x5
    8000231a:	d62a0a13          	addi	s4,s4,-670 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000231e:	00005b97          	auipc	s7,0x5
    80002322:	482b8b93          	addi	s7,s7,1154 # 800077a0 <states.0>
    80002326:	a829                	j	80002340 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002328:	ed86a583          	lw	a1,-296(a3)
    8000232c:	8556                	mv	a0,s5
    8000232e:	9c8fe0ef          	jal	800004f6 <printf>
    printf("\n");
    80002332:	8552                	mv	a0,s4
    80002334:	9c2fe0ef          	jal	800004f6 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002338:	16848493          	addi	s1,s1,360
    8000233c:	03248263          	beq	s1,s2,80002360 <procdump+0x8e>
    if(p->state == UNUSED)
    80002340:	86a6                	mv	a3,s1
    80002342:	ec04a783          	lw	a5,-320(s1)
    80002346:	dbed                	beqz	a5,80002338 <procdump+0x66>
      state = "???";
    80002348:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000234a:	fcfb6fe3          	bltu	s6,a5,80002328 <procdump+0x56>
    8000234e:	02079713          	slli	a4,a5,0x20
    80002352:	01d75793          	srli	a5,a4,0x1d
    80002356:	97de                	add	a5,a5,s7
    80002358:	6390                	ld	a2,0(a5)
    8000235a:	f679                	bnez	a2,80002328 <procdump+0x56>
      state = "???";
    8000235c:	864e                	mv	a2,s3
    8000235e:	b7e9                	j	80002328 <procdump+0x56>
  }
}
    80002360:	60a6                	ld	ra,72(sp)
    80002362:	6406                	ld	s0,64(sp)
    80002364:	74e2                	ld	s1,56(sp)
    80002366:	7942                	ld	s2,48(sp)
    80002368:	79a2                	ld	s3,40(sp)
    8000236a:	7a02                	ld	s4,32(sp)
    8000236c:	6ae2                	ld	s5,24(sp)
    8000236e:	6b42                	ld	s6,16(sp)
    80002370:	6ba2                	ld	s7,8(sp)
    80002372:	6161                	addi	sp,sp,80
    80002374:	8082                	ret

0000000080002376 <waitpid>:



int waitpid(int pid, uint64 addr) {
    80002376:	711d                	addi	sp,sp,-96
    80002378:	ec86                	sd	ra,88(sp)
    8000237a:	e8a2                	sd	s0,80(sp)
    8000237c:	e4a6                	sd	s1,72(sp)
    8000237e:	e0ca                	sd	s2,64(sp)
    80002380:	fc4e                	sd	s3,56(sp)
    80002382:	f852                	sd	s4,48(sp)
    80002384:	f456                	sd	s5,40(sp)
    80002386:	f05a                	sd	s6,32(sp)
    80002388:	ec5e                	sd	s7,24(sp)
    8000238a:	e862                	sd	s8,16(sp)
    8000238c:	e466                	sd	s9,8(sp)
    8000238e:	1080                	addi	s0,sp,96
    80002390:	892a                	mv	s2,a0
    80002392:	8bae                	mv	s7,a1
  struct proc *pp;
  int havekids;
  struct proc *p = myproc();
    80002394:	d80ff0ef          	jal	80001914 <myproc>
    80002398:	8b2a                	mv	s6,a0

  acquire(&wait_lock);
    8000239a:	00010517          	auipc	a0,0x10
    8000239e:	22e50513          	addi	a0,a0,558 # 800125c8 <wait_lock>
    800023a2:	887fe0ef          	jal	80000c28 <acquire>

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    800023a6:	4c01                	li	s8,0
      if(pp->pid == pid){
        // make sure the child isn't still in exit() or swtch().
        acquire(&pp->lock);

        havekids = 1;
        if(pp->state == ZOMBIE){
    800023a8:	4a15                	li	s4,5
        havekids = 1;
    800023aa:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023ac:	00016997          	auipc	s3,0x16
    800023b0:	03498993          	addi	s3,s3,52 # 800183e0 <tickslock>
      release(&wait_lock);
      return -1;
    }
    
    // Wait for a child to exit.
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800023b4:	00010c97          	auipc	s9,0x10
    800023b8:	214c8c93          	addi	s9,s9,532 # 800125c8 <wait_lock>
    800023bc:	a879                	j	8000245a <waitpid+0xe4>
          pid = pp->pid;
    800023be:	0304a903          	lw	s2,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800023c2:	000b8c63          	beqz	s7,800023da <waitpid+0x64>
    800023c6:	4691                	li	a3,4
    800023c8:	02c48613          	addi	a2,s1,44
    800023cc:	85de                	mv	a1,s7
    800023ce:	050b3503          	ld	a0,80(s6)
    800023d2:	9b4ff0ef          	jal	80001586 <copyout>
    800023d6:	02054c63          	bltz	a0,8000240e <waitpid+0x98>
          freeproc(pp);
    800023da:	8526                	mv	a0,s1
    800023dc:	eaaff0ef          	jal	80001a86 <freeproc>
          release(&pp->lock);
    800023e0:	8526                	mv	a0,s1
    800023e2:	8dffe0ef          	jal	80000cc0 <release>
          release(&wait_lock);
    800023e6:	00010517          	auipc	a0,0x10
    800023ea:	1e250513          	addi	a0,a0,482 # 800125c8 <wait_lock>
    800023ee:	8d3fe0ef          	jal	80000cc0 <release>

  
  }
}
    800023f2:	854a                	mv	a0,s2
    800023f4:	60e6                	ld	ra,88(sp)
    800023f6:	6446                	ld	s0,80(sp)
    800023f8:	64a6                	ld	s1,72(sp)
    800023fa:	6906                	ld	s2,64(sp)
    800023fc:	79e2                	ld	s3,56(sp)
    800023fe:	7a42                	ld	s4,48(sp)
    80002400:	7aa2                	ld	s5,40(sp)
    80002402:	7b02                	ld	s6,32(sp)
    80002404:	6be2                	ld	s7,24(sp)
    80002406:	6c42                	ld	s8,16(sp)
    80002408:	6ca2                	ld	s9,8(sp)
    8000240a:	6125                	addi	sp,sp,96
    8000240c:	8082                	ret
            release(&pp->lock);
    8000240e:	8526                	mv	a0,s1
    80002410:	8b1fe0ef          	jal	80000cc0 <release>
            release(&wait_lock);
    80002414:	00010517          	auipc	a0,0x10
    80002418:	1b450513          	addi	a0,a0,436 # 800125c8 <wait_lock>
    8000241c:	8a5fe0ef          	jal	80000cc0 <release>
            return -1;
    80002420:	597d                	li	s2,-1
    80002422:	bfc1                	j	800023f2 <waitpid+0x7c>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002424:	16848493          	addi	s1,s1,360
    80002428:	03348063          	beq	s1,s3,80002448 <waitpid+0xd2>
      if(pp->pid == pid){
    8000242c:	589c                	lw	a5,48(s1)
    8000242e:	ff279be3          	bne	a5,s2,80002424 <waitpid+0xae>
        acquire(&pp->lock);
    80002432:	8526                	mv	a0,s1
    80002434:	ff4fe0ef          	jal	80000c28 <acquire>
        if(pp->state == ZOMBIE){
    80002438:	4c9c                	lw	a5,24(s1)
    8000243a:	f94782e3          	beq	a5,s4,800023be <waitpid+0x48>
        release(&pp->lock);
    8000243e:	8526                	mv	a0,s1
    80002440:	881fe0ef          	jal	80000cc0 <release>
        havekids = 1;
    80002444:	8756                	mv	a4,s5
    80002446:	bff9                	j	80002424 <waitpid+0xae>
    if(!havekids || killed(p)){
    80002448:	cf19                	beqz	a4,80002466 <waitpid+0xf0>
    8000244a:	855a                	mv	a0,s6
    8000244c:	ccfff0ef          	jal	8000211a <killed>
    80002450:	e919                	bnez	a0,80002466 <waitpid+0xf0>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002452:	85e6                	mv	a1,s9
    80002454:	855a                	mv	a0,s6
    80002456:	a8dff0ef          	jal	80001ee2 <sleep>
    havekids = 0;
    8000245a:	8762                	mv	a4,s8
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000245c:	00010497          	auipc	s1,0x10
    80002460:	58448493          	addi	s1,s1,1412 # 800129e0 <proc>
    80002464:	b7e1                	j	8000242c <waitpid+0xb6>
      release(&wait_lock);
    80002466:	00010517          	auipc	a0,0x10
    8000246a:	16250513          	addi	a0,a0,354 # 800125c8 <wait_lock>
    8000246e:	853fe0ef          	jal	80000cc0 <release>
      return -1;
    80002472:	597d                	li	s2,-1
    80002474:	bfbd                	j	800023f2 <waitpid+0x7c>

0000000080002476 <find_proc>:

struct proc* find_proc(int pid) {
    80002476:	7179                	addi	sp,sp,-48
    80002478:	f406                	sd	ra,40(sp)
    8000247a:	f022                	sd	s0,32(sp)
    8000247c:	ec26                	sd	s1,24(sp)
    8000247e:	e84a                	sd	s2,16(sp)
    80002480:	e44e                	sd	s3,8(sp)
    80002482:	1800                	addi	s0,sp,48
    80002484:	892a                	mv	s2,a0
    struct proc *p;
    for (p = proc; p < &proc[NPROC]; p++) {
    80002486:	00010497          	auipc	s1,0x10
    8000248a:	55a48493          	addi	s1,s1,1370 # 800129e0 <proc>
    8000248e:	00016997          	auipc	s3,0x16
    80002492:	f5298993          	addi	s3,s3,-174 # 800183e0 <tickslock>
    80002496:	a801                	j	800024a6 <find_proc+0x30>
        acquire(&p->lock);  // Lock the process
        if (p->pid == pid && p->state != UNUSED) {
            return p;  // Return with lock held
        }
        release(&p->lock);  // Unlock if not the target process
    80002498:	8526                	mv	a0,s1
    8000249a:	827fe0ef          	jal	80000cc0 <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    8000249e:	16848493          	addi	s1,s1,360
    800024a2:	03348263          	beq	s1,s3,800024c6 <find_proc+0x50>
        acquire(&p->lock);  // Lock the process
    800024a6:	8526                	mv	a0,s1
    800024a8:	f80fe0ef          	jal	80000c28 <acquire>
        if (p->pid == pid && p->state != UNUSED) {
    800024ac:	589c                	lw	a5,48(s1)
    800024ae:	ff2795e3          	bne	a5,s2,80002498 <find_proc+0x22>
    800024b2:	4c9c                	lw	a5,24(s1)
    800024b4:	d3f5                	beqz	a5,80002498 <find_proc+0x22>
    }
    return 0;  // Process not found
}
    800024b6:	8526                	mv	a0,s1
    800024b8:	70a2                	ld	ra,40(sp)
    800024ba:	7402                	ld	s0,32(sp)
    800024bc:	64e2                	ld	s1,24(sp)
    800024be:	6942                	ld	s2,16(sp)
    800024c0:	69a2                	ld	s3,8(sp)
    800024c2:	6145                	addi	sp,sp,48
    800024c4:	8082                	ret
    return 0;  // Process not found
    800024c6:	4481                	li	s1,0
    800024c8:	b7fd                	j	800024b6 <find_proc+0x40>

00000000800024ca <sigstop>:


int sigstop(int pid){
    800024ca:	7179                	addi	sp,sp,-48
    800024cc:	f406                	sd	ra,40(sp)
    800024ce:	f022                	sd	s0,32(sp)
    800024d0:	ec26                	sd	s1,24(sp)
    800024d2:	e84a                	sd	s2,16(sp)
    800024d4:	e44e                	sd	s3,8(sp)
    800024d6:	1800                	addi	s0,sp,48
    800024d8:	892a                	mv	s2,a0
  struct proc *p;

    for(p = proc; p < &proc[NPROC]; p++){
    800024da:	00010497          	auipc	s1,0x10
    800024de:	50648493          	addi	s1,s1,1286 # 800129e0 <proc>
    800024e2:	00016997          	auipc	s3,0x16
    800024e6:	efe98993          	addi	s3,s3,-258 # 800183e0 <tickslock>
        acquire(&p->lock);
    800024ea:	8526                	mv	a0,s1
    800024ec:	f3cfe0ef          	jal	80000c28 <acquire>
        if(p->pid == pid){
    800024f0:	589c                	lw	a5,48(s1)
    800024f2:	01278b63          	beq	a5,s2,80002508 <sigstop+0x3e>
            // Set process state to STOPPED or SLEEPING (suspend execution).
            p->state = SLEEPING;  // or STOPPED if you have a STOPPED state.
            release(&p->lock);
            return 0;
        }
        release(&p->lock);
    800024f6:	8526                	mv	a0,s1
    800024f8:	fc8fe0ef          	jal	80000cc0 <release>
    for(p = proc; p < &proc[NPROC]; p++){
    800024fc:	16848493          	addi	s1,s1,360
    80002500:	ff3495e3          	bne	s1,s3,800024ea <sigstop+0x20>
    }
    return -1;
    80002504:	557d                	li	a0,-1
    80002506:	a039                	j	80002514 <sigstop+0x4a>
            p->state = SLEEPING;  // or STOPPED if you have a STOPPED state.
    80002508:	4789                	li	a5,2
    8000250a:	cc9c                	sw	a5,24(s1)
            release(&p->lock);
    8000250c:	8526                	mv	a0,s1
    8000250e:	fb2fe0ef          	jal	80000cc0 <release>
            return 0;
    80002512:	4501                	li	a0,0
}
    80002514:	70a2                	ld	ra,40(sp)
    80002516:	7402                	ld	s0,32(sp)
    80002518:	64e2                	ld	s1,24(sp)
    8000251a:	6942                	ld	s2,16(sp)
    8000251c:	69a2                	ld	s3,8(sp)
    8000251e:	6145                	addi	sp,sp,48
    80002520:	8082                	ret

0000000080002522 <sigcont>:

int sigcont(int pid){
    80002522:	7179                	addi	sp,sp,-48
    80002524:	f406                	sd	ra,40(sp)
    80002526:	f022                	sd	s0,32(sp)
    80002528:	ec26                	sd	s1,24(sp)
    8000252a:	e84a                	sd	s2,16(sp)
    8000252c:	e44e                	sd	s3,8(sp)
    8000252e:	1800                	addi	s0,sp,48
    80002530:	892a                	mv	s2,a0
  struct proc *p;

    for(p = proc; p < &proc[NPROC]; p++){
    80002532:	00010497          	auipc	s1,0x10
    80002536:	4ae48493          	addi	s1,s1,1198 # 800129e0 <proc>
    8000253a:	00016997          	auipc	s3,0x16
    8000253e:	ea698993          	addi	s3,s3,-346 # 800183e0 <tickslock>
        acquire(&p->lock);
    80002542:	8526                	mv	a0,s1
    80002544:	ee4fe0ef          	jal	80000c28 <acquire>
        if(p->pid == pid){
    80002548:	589c                	lw	a5,48(s1)
    8000254a:	01278b63          	beq	a5,s2,80002560 <sigcont+0x3e>
                p->state = RUNNABLE;
            }
            release(&p->lock);
            return 0;
        }
        release(&p->lock);
    8000254e:	8526                	mv	a0,s1
    80002550:	f70fe0ef          	jal	80000cc0 <release>
    for(p = proc; p < &proc[NPROC]; p++){
    80002554:	16848493          	addi	s1,s1,360
    80002558:	ff3495e3          	bne	s1,s3,80002542 <sigcont+0x20>
    }
    return -1;
    8000255c:	557d                	li	a0,-1
    8000255e:	a809                	j	80002570 <sigcont+0x4e>
            if(p->state == SLEEPING) 
    80002560:	4c98                	lw	a4,24(s1)
    80002562:	4789                	li	a5,2
    80002564:	00f70d63          	beq	a4,a5,8000257e <sigcont+0x5c>
            release(&p->lock);
    80002568:	8526                	mv	a0,s1
    8000256a:	f56fe0ef          	jal	80000cc0 <release>
            return 0;
    8000256e:	4501                	li	a0,0
    80002570:	70a2                	ld	ra,40(sp)
    80002572:	7402                	ld	s0,32(sp)
    80002574:	64e2                	ld	s1,24(sp)
    80002576:	6942                	ld	s2,16(sp)
    80002578:	69a2                	ld	s3,8(sp)
    8000257a:	6145                	addi	sp,sp,48
    8000257c:	8082                	ret
                p->state = RUNNABLE;
    8000257e:	478d                	li	a5,3
    80002580:	cc9c                	sw	a5,24(s1)
    80002582:	b7dd                	j	80002568 <sigcont+0x46>

0000000080002584 <swtch>:
    80002584:	00153023          	sd	ra,0(a0)
    80002588:	00253423          	sd	sp,8(a0)
    8000258c:	e900                	sd	s0,16(a0)
    8000258e:	ed04                	sd	s1,24(a0)
    80002590:	03253023          	sd	s2,32(a0)
    80002594:	03353423          	sd	s3,40(a0)
    80002598:	03453823          	sd	s4,48(a0)
    8000259c:	03553c23          	sd	s5,56(a0)
    800025a0:	05653023          	sd	s6,64(a0)
    800025a4:	05753423          	sd	s7,72(a0)
    800025a8:	05853823          	sd	s8,80(a0)
    800025ac:	05953c23          	sd	s9,88(a0)
    800025b0:	07a53023          	sd	s10,96(a0)
    800025b4:	07b53423          	sd	s11,104(a0)
    800025b8:	0005b083          	ld	ra,0(a1)
    800025bc:	0085b103          	ld	sp,8(a1)
    800025c0:	6980                	ld	s0,16(a1)
    800025c2:	6d84                	ld	s1,24(a1)
    800025c4:	0205b903          	ld	s2,32(a1)
    800025c8:	0285b983          	ld	s3,40(a1)
    800025cc:	0305ba03          	ld	s4,48(a1)
    800025d0:	0385ba83          	ld	s5,56(a1)
    800025d4:	0405bb03          	ld	s6,64(a1)
    800025d8:	0485bb83          	ld	s7,72(a1)
    800025dc:	0505bc03          	ld	s8,80(a1)
    800025e0:	0585bc83          	ld	s9,88(a1)
    800025e4:	0605bd03          	ld	s10,96(a1)
    800025e8:	0685bd83          	ld	s11,104(a1)
    800025ec:	8082                	ret

00000000800025ee <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800025ee:	1141                	addi	sp,sp,-16
    800025f0:	e406                	sd	ra,8(sp)
    800025f2:	e022                	sd	s0,0(sp)
    800025f4:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800025f6:	00005597          	auipc	a1,0x5
    800025fa:	cf258593          	addi	a1,a1,-782 # 800072e8 <etext+0x2e8>
    800025fe:	00016517          	auipc	a0,0x16
    80002602:	de250513          	addi	a0,a0,-542 # 800183e0 <tickslock>
    80002606:	da2fe0ef          	jal	80000ba8 <initlock>
}
    8000260a:	60a2                	ld	ra,8(sp)
    8000260c:	6402                	ld	s0,0(sp)
    8000260e:	0141                	addi	sp,sp,16
    80002610:	8082                	ret

0000000080002612 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002612:	1141                	addi	sp,sp,-16
    80002614:	e422                	sd	s0,8(sp)
    80002616:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002618:	00003797          	auipc	a5,0x3
    8000261c:	fe878793          	addi	a5,a5,-24 # 80005600 <kernelvec>
    80002620:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002624:	6422                	ld	s0,8(sp)
    80002626:	0141                	addi	sp,sp,16
    80002628:	8082                	ret

000000008000262a <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000262a:	1141                	addi	sp,sp,-16
    8000262c:	e406                	sd	ra,8(sp)
    8000262e:	e022                	sd	s0,0(sp)
    80002630:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002632:	ae2ff0ef          	jal	80001914 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002636:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000263a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000263c:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002640:	00004697          	auipc	a3,0x4
    80002644:	9c068693          	addi	a3,a3,-1600 # 80006000 <_trampoline>
    80002648:	00004717          	auipc	a4,0x4
    8000264c:	9b870713          	addi	a4,a4,-1608 # 80006000 <_trampoline>
    80002650:	8f15                	sub	a4,a4,a3
    80002652:	040007b7          	lui	a5,0x4000
    80002656:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002658:	07b2                	slli	a5,a5,0xc
    8000265a:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000265c:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002660:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002662:	18002673          	csrr	a2,satp
    80002666:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002668:	6d30                	ld	a2,88(a0)
    8000266a:	6138                	ld	a4,64(a0)
    8000266c:	6585                	lui	a1,0x1
    8000266e:	972e                	add	a4,a4,a1
    80002670:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002672:	6d38                	ld	a4,88(a0)
    80002674:	00000617          	auipc	a2,0x0
    80002678:	11060613          	addi	a2,a2,272 # 80002784 <usertrap>
    8000267c:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000267e:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002680:	8612                	mv	a2,tp
    80002682:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002684:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002688:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000268c:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002690:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002694:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002696:	6f18                	ld	a4,24(a4)
    80002698:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000269c:	6928                	ld	a0,80(a0)
    8000269e:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800026a0:	00004717          	auipc	a4,0x4
    800026a4:	9fc70713          	addi	a4,a4,-1540 # 8000609c <userret>
    800026a8:	8f15                	sub	a4,a4,a3
    800026aa:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800026ac:	577d                	li	a4,-1
    800026ae:	177e                	slli	a4,a4,0x3f
    800026b0:	8d59                	or	a0,a0,a4
    800026b2:	9782                	jalr	a5
}
    800026b4:	60a2                	ld	ra,8(sp)
    800026b6:	6402                	ld	s0,0(sp)
    800026b8:	0141                	addi	sp,sp,16
    800026ba:	8082                	ret

00000000800026bc <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800026bc:	1101                	addi	sp,sp,-32
    800026be:	ec06                	sd	ra,24(sp)
    800026c0:	e822                	sd	s0,16(sp)
    800026c2:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    800026c4:	a24ff0ef          	jal	800018e8 <cpuid>
    800026c8:	cd11                	beqz	a0,800026e4 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    800026ca:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800026ce:	000f4737          	lui	a4,0xf4
    800026d2:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800026d6:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800026d8:	14d79073          	csrw	stimecmp,a5
}
    800026dc:	60e2                	ld	ra,24(sp)
    800026de:	6442                	ld	s0,16(sp)
    800026e0:	6105                	addi	sp,sp,32
    800026e2:	8082                	ret
    800026e4:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800026e6:	00016497          	auipc	s1,0x16
    800026ea:	cfa48493          	addi	s1,s1,-774 # 800183e0 <tickslock>
    800026ee:	8526                	mv	a0,s1
    800026f0:	d38fe0ef          	jal	80000c28 <acquire>
    ticks++;
    800026f4:	00008517          	auipc	a0,0x8
    800026f8:	d8c50513          	addi	a0,a0,-628 # 8000a480 <ticks>
    800026fc:	411c                	lw	a5,0(a0)
    800026fe:	2785                	addiw	a5,a5,1
    80002700:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80002702:	82dff0ef          	jal	80001f2e <wakeup>
    release(&tickslock);
    80002706:	8526                	mv	a0,s1
    80002708:	db8fe0ef          	jal	80000cc0 <release>
    8000270c:	64a2                	ld	s1,8(sp)
    8000270e:	bf75                	j	800026ca <clockintr+0xe>

0000000080002710 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002710:	1101                	addi	sp,sp,-32
    80002712:	ec06                	sd	ra,24(sp)
    80002714:	e822                	sd	s0,16(sp)
    80002716:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002718:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    8000271c:	57fd                	li	a5,-1
    8000271e:	17fe                	slli	a5,a5,0x3f
    80002720:	07a5                	addi	a5,a5,9
    80002722:	00f70c63          	beq	a4,a5,8000273a <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002726:	57fd                	li	a5,-1
    80002728:	17fe                	slli	a5,a5,0x3f
    8000272a:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    8000272c:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    8000272e:	04f70763          	beq	a4,a5,8000277c <devintr+0x6c>
  }
}
    80002732:	60e2                	ld	ra,24(sp)
    80002734:	6442                	ld	s0,16(sp)
    80002736:	6105                	addi	sp,sp,32
    80002738:	8082                	ret
    8000273a:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    8000273c:	771020ef          	jal	800056ac <plic_claim>
    80002740:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002742:	47a9                	li	a5,10
    80002744:	00f50963          	beq	a0,a5,80002756 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002748:	4785                	li	a5,1
    8000274a:	00f50963          	beq	a0,a5,8000275c <devintr+0x4c>
    return 1;
    8000274e:	4505                	li	a0,1
    } else if(irq){
    80002750:	e889                	bnez	s1,80002762 <devintr+0x52>
    80002752:	64a2                	ld	s1,8(sp)
    80002754:	bff9                	j	80002732 <devintr+0x22>
      uartintr();
    80002756:	ae4fe0ef          	jal	80000a3a <uartintr>
    if(irq)
    8000275a:	a819                	j	80002770 <devintr+0x60>
      virtio_disk_intr();
    8000275c:	416030ef          	jal	80005b72 <virtio_disk_intr>
    if(irq)
    80002760:	a801                	j	80002770 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80002762:	85a6                	mv	a1,s1
    80002764:	00005517          	auipc	a0,0x5
    80002768:	b8c50513          	addi	a0,a0,-1140 # 800072f0 <etext+0x2f0>
    8000276c:	d8bfd0ef          	jal	800004f6 <printf>
      plic_complete(irq);
    80002770:	8526                	mv	a0,s1
    80002772:	75b020ef          	jal	800056cc <plic_complete>
    return 1;
    80002776:	4505                	li	a0,1
    80002778:	64a2                	ld	s1,8(sp)
    8000277a:	bf65                	j	80002732 <devintr+0x22>
    clockintr();
    8000277c:	f41ff0ef          	jal	800026bc <clockintr>
    return 2;
    80002780:	4509                	li	a0,2
    80002782:	bf45                	j	80002732 <devintr+0x22>

0000000080002784 <usertrap>:
{
    80002784:	1101                	addi	sp,sp,-32
    80002786:	ec06                	sd	ra,24(sp)
    80002788:	e822                	sd	s0,16(sp)
    8000278a:	e426                	sd	s1,8(sp)
    8000278c:	e04a                	sd	s2,0(sp)
    8000278e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002790:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002794:	1007f793          	andi	a5,a5,256
    80002798:	ef85                	bnez	a5,800027d0 <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000279a:	00003797          	auipc	a5,0x3
    8000279e:	e6678793          	addi	a5,a5,-410 # 80005600 <kernelvec>
    800027a2:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800027a6:	96eff0ef          	jal	80001914 <myproc>
    800027aa:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800027ac:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800027ae:	14102773          	csrr	a4,sepc
    800027b2:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027b4:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800027b8:	47a1                	li	a5,8
    800027ba:	02f70163          	beq	a4,a5,800027dc <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    800027be:	f53ff0ef          	jal	80002710 <devintr>
    800027c2:	892a                	mv	s2,a0
    800027c4:	c135                	beqz	a0,80002828 <usertrap+0xa4>
  if(killed(p))
    800027c6:	8526                	mv	a0,s1
    800027c8:	953ff0ef          	jal	8000211a <killed>
    800027cc:	cd1d                	beqz	a0,8000280a <usertrap+0x86>
    800027ce:	a81d                	j	80002804 <usertrap+0x80>
    panic("usertrap: not from user mode");
    800027d0:	00005517          	auipc	a0,0x5
    800027d4:	b4050513          	addi	a0,a0,-1216 # 80007310 <etext+0x310>
    800027d8:	ff1fd0ef          	jal	800007c8 <panic>
    if(killed(p))
    800027dc:	93fff0ef          	jal	8000211a <killed>
    800027e0:	e121                	bnez	a0,80002820 <usertrap+0x9c>
    p->trapframe->epc += 4;
    800027e2:	6cb8                	ld	a4,88(s1)
    800027e4:	6f1c                	ld	a5,24(a4)
    800027e6:	0791                	addi	a5,a5,4
    800027e8:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027ea:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800027ee:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027f2:	10079073          	csrw	sstatus,a5
    syscall();
    800027f6:	248000ef          	jal	80002a3e <syscall>
  if(killed(p))
    800027fa:	8526                	mv	a0,s1
    800027fc:	91fff0ef          	jal	8000211a <killed>
    80002800:	c901                	beqz	a0,80002810 <usertrap+0x8c>
    80002802:	4901                	li	s2,0
    exit(-1);
    80002804:	557d                	li	a0,-1
    80002806:	fe8ff0ef          	jal	80001fee <exit>
  if(which_dev == 2)
    8000280a:	4789                	li	a5,2
    8000280c:	04f90563          	beq	s2,a5,80002856 <usertrap+0xd2>
  usertrapret();
    80002810:	e1bff0ef          	jal	8000262a <usertrapret>
}
    80002814:	60e2                	ld	ra,24(sp)
    80002816:	6442                	ld	s0,16(sp)
    80002818:	64a2                	ld	s1,8(sp)
    8000281a:	6902                	ld	s2,0(sp)
    8000281c:	6105                	addi	sp,sp,32
    8000281e:	8082                	ret
      exit(-1);
    80002820:	557d                	li	a0,-1
    80002822:	fccff0ef          	jal	80001fee <exit>
    80002826:	bf75                	j	800027e2 <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002828:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    8000282c:	5890                	lw	a2,48(s1)
    8000282e:	00005517          	auipc	a0,0x5
    80002832:	b0250513          	addi	a0,a0,-1278 # 80007330 <etext+0x330>
    80002836:	cc1fd0ef          	jal	800004f6 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000283a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000283e:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002842:	00005517          	auipc	a0,0x5
    80002846:	b1e50513          	addi	a0,a0,-1250 # 80007360 <etext+0x360>
    8000284a:	cadfd0ef          	jal	800004f6 <printf>
    setkilled(p);
    8000284e:	8526                	mv	a0,s1
    80002850:	8a7ff0ef          	jal	800020f6 <setkilled>
    80002854:	b75d                	j	800027fa <usertrap+0x76>
    yield();
    80002856:	e60ff0ef          	jal	80001eb6 <yield>
    8000285a:	bf5d                	j	80002810 <usertrap+0x8c>

000000008000285c <kerneltrap>:
{
    8000285c:	7179                	addi	sp,sp,-48
    8000285e:	f406                	sd	ra,40(sp)
    80002860:	f022                	sd	s0,32(sp)
    80002862:	ec26                	sd	s1,24(sp)
    80002864:	e84a                	sd	s2,16(sp)
    80002866:	e44e                	sd	s3,8(sp)
    80002868:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000286a:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000286e:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002872:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002876:	1004f793          	andi	a5,s1,256
    8000287a:	c795                	beqz	a5,800028a6 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000287c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002880:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002882:	eb85                	bnez	a5,800028b2 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002884:	e8dff0ef          	jal	80002710 <devintr>
    80002888:	c91d                	beqz	a0,800028be <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    8000288a:	4789                	li	a5,2
    8000288c:	04f50a63          	beq	a0,a5,800028e0 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002890:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002894:	10049073          	csrw	sstatus,s1
}
    80002898:	70a2                	ld	ra,40(sp)
    8000289a:	7402                	ld	s0,32(sp)
    8000289c:	64e2                	ld	s1,24(sp)
    8000289e:	6942                	ld	s2,16(sp)
    800028a0:	69a2                	ld	s3,8(sp)
    800028a2:	6145                	addi	sp,sp,48
    800028a4:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800028a6:	00005517          	auipc	a0,0x5
    800028aa:	ae250513          	addi	a0,a0,-1310 # 80007388 <etext+0x388>
    800028ae:	f1bfd0ef          	jal	800007c8 <panic>
    panic("kerneltrap: interrupts enabled");
    800028b2:	00005517          	auipc	a0,0x5
    800028b6:	afe50513          	addi	a0,a0,-1282 # 800073b0 <etext+0x3b0>
    800028ba:	f0ffd0ef          	jal	800007c8 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028be:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028c2:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    800028c6:	85ce                	mv	a1,s3
    800028c8:	00005517          	auipc	a0,0x5
    800028cc:	b0850513          	addi	a0,a0,-1272 # 800073d0 <etext+0x3d0>
    800028d0:	c27fd0ef          	jal	800004f6 <printf>
    panic("kerneltrap");
    800028d4:	00005517          	auipc	a0,0x5
    800028d8:	b2450513          	addi	a0,a0,-1244 # 800073f8 <etext+0x3f8>
    800028dc:	eedfd0ef          	jal	800007c8 <panic>
  if(which_dev == 2 && myproc() != 0)
    800028e0:	834ff0ef          	jal	80001914 <myproc>
    800028e4:	d555                	beqz	a0,80002890 <kerneltrap+0x34>
    yield();
    800028e6:	dd0ff0ef          	jal	80001eb6 <yield>
    800028ea:	b75d                	j	80002890 <kerneltrap+0x34>

00000000800028ec <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800028ec:	1101                	addi	sp,sp,-32
    800028ee:	ec06                	sd	ra,24(sp)
    800028f0:	e822                	sd	s0,16(sp)
    800028f2:	e426                	sd	s1,8(sp)
    800028f4:	1000                	addi	s0,sp,32
    800028f6:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800028f8:	81cff0ef          	jal	80001914 <myproc>
  switch (n) {
    800028fc:	4795                	li	a5,5
    800028fe:	0497e163          	bltu	a5,s1,80002940 <argraw+0x54>
    80002902:	048a                	slli	s1,s1,0x2
    80002904:	00005717          	auipc	a4,0x5
    80002908:	ecc70713          	addi	a4,a4,-308 # 800077d0 <states.0+0x30>
    8000290c:	94ba                	add	s1,s1,a4
    8000290e:	409c                	lw	a5,0(s1)
    80002910:	97ba                	add	a5,a5,a4
    80002912:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002914:	6d3c                	ld	a5,88(a0)
    80002916:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002918:	60e2                	ld	ra,24(sp)
    8000291a:	6442                	ld	s0,16(sp)
    8000291c:	64a2                	ld	s1,8(sp)
    8000291e:	6105                	addi	sp,sp,32
    80002920:	8082                	ret
    return p->trapframe->a1;
    80002922:	6d3c                	ld	a5,88(a0)
    80002924:	7fa8                	ld	a0,120(a5)
    80002926:	bfcd                	j	80002918 <argraw+0x2c>
    return p->trapframe->a2;
    80002928:	6d3c                	ld	a5,88(a0)
    8000292a:	63c8                	ld	a0,128(a5)
    8000292c:	b7f5                	j	80002918 <argraw+0x2c>
    return p->trapframe->a3;
    8000292e:	6d3c                	ld	a5,88(a0)
    80002930:	67c8                	ld	a0,136(a5)
    80002932:	b7dd                	j	80002918 <argraw+0x2c>
    return p->trapframe->a4;
    80002934:	6d3c                	ld	a5,88(a0)
    80002936:	6bc8                	ld	a0,144(a5)
    80002938:	b7c5                	j	80002918 <argraw+0x2c>
    return p->trapframe->a5;
    8000293a:	6d3c                	ld	a5,88(a0)
    8000293c:	6fc8                	ld	a0,152(a5)
    8000293e:	bfe9                	j	80002918 <argraw+0x2c>
  panic("argraw");
    80002940:	00005517          	auipc	a0,0x5
    80002944:	ac850513          	addi	a0,a0,-1336 # 80007408 <etext+0x408>
    80002948:	e81fd0ef          	jal	800007c8 <panic>

000000008000294c <fetchaddr>:
{
    8000294c:	1101                	addi	sp,sp,-32
    8000294e:	ec06                	sd	ra,24(sp)
    80002950:	e822                	sd	s0,16(sp)
    80002952:	e426                	sd	s1,8(sp)
    80002954:	e04a                	sd	s2,0(sp)
    80002956:	1000                	addi	s0,sp,32
    80002958:	84aa                	mv	s1,a0
    8000295a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000295c:	fb9fe0ef          	jal	80001914 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002960:	653c                	ld	a5,72(a0)
    80002962:	02f4f663          	bgeu	s1,a5,8000298e <fetchaddr+0x42>
    80002966:	00848713          	addi	a4,s1,8
    8000296a:	02e7e463          	bltu	a5,a4,80002992 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000296e:	46a1                	li	a3,8
    80002970:	8626                	mv	a2,s1
    80002972:	85ca                	mv	a1,s2
    80002974:	6928                	ld	a0,80(a0)
    80002976:	ce7fe0ef          	jal	8000165c <copyin>
    8000297a:	00a03533          	snez	a0,a0
    8000297e:	40a00533          	neg	a0,a0
}
    80002982:	60e2                	ld	ra,24(sp)
    80002984:	6442                	ld	s0,16(sp)
    80002986:	64a2                	ld	s1,8(sp)
    80002988:	6902                	ld	s2,0(sp)
    8000298a:	6105                	addi	sp,sp,32
    8000298c:	8082                	ret
    return -1;
    8000298e:	557d                	li	a0,-1
    80002990:	bfcd                	j	80002982 <fetchaddr+0x36>
    80002992:	557d                	li	a0,-1
    80002994:	b7fd                	j	80002982 <fetchaddr+0x36>

0000000080002996 <fetchstr>:
{
    80002996:	7179                	addi	sp,sp,-48
    80002998:	f406                	sd	ra,40(sp)
    8000299a:	f022                	sd	s0,32(sp)
    8000299c:	ec26                	sd	s1,24(sp)
    8000299e:	e84a                	sd	s2,16(sp)
    800029a0:	e44e                	sd	s3,8(sp)
    800029a2:	1800                	addi	s0,sp,48
    800029a4:	892a                	mv	s2,a0
    800029a6:	84ae                	mv	s1,a1
    800029a8:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800029aa:	f6bfe0ef          	jal	80001914 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800029ae:	86ce                	mv	a3,s3
    800029b0:	864a                	mv	a2,s2
    800029b2:	85a6                	mv	a1,s1
    800029b4:	6928                	ld	a0,80(a0)
    800029b6:	d2dfe0ef          	jal	800016e2 <copyinstr>
    800029ba:	00054c63          	bltz	a0,800029d2 <fetchstr+0x3c>
  return strlen(buf);
    800029be:	8526                	mv	a0,s1
    800029c0:	cacfe0ef          	jal	80000e6c <strlen>
}
    800029c4:	70a2                	ld	ra,40(sp)
    800029c6:	7402                	ld	s0,32(sp)
    800029c8:	64e2                	ld	s1,24(sp)
    800029ca:	6942                	ld	s2,16(sp)
    800029cc:	69a2                	ld	s3,8(sp)
    800029ce:	6145                	addi	sp,sp,48
    800029d0:	8082                	ret
    return -1;
    800029d2:	557d                	li	a0,-1
    800029d4:	bfc5                	j	800029c4 <fetchstr+0x2e>

00000000800029d6 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800029d6:	1101                	addi	sp,sp,-32
    800029d8:	ec06                	sd	ra,24(sp)
    800029da:	e822                	sd	s0,16(sp)
    800029dc:	e426                	sd	s1,8(sp)
    800029de:	1000                	addi	s0,sp,32
    800029e0:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800029e2:	f0bff0ef          	jal	800028ec <argraw>
    800029e6:	c088                	sw	a0,0(s1)
}
    800029e8:	60e2                	ld	ra,24(sp)
    800029ea:	6442                	ld	s0,16(sp)
    800029ec:	64a2                	ld	s1,8(sp)
    800029ee:	6105                	addi	sp,sp,32
    800029f0:	8082                	ret

00000000800029f2 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800029f2:	1101                	addi	sp,sp,-32
    800029f4:	ec06                	sd	ra,24(sp)
    800029f6:	e822                	sd	s0,16(sp)
    800029f8:	e426                	sd	s1,8(sp)
    800029fa:	1000                	addi	s0,sp,32
    800029fc:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800029fe:	eefff0ef          	jal	800028ec <argraw>
    80002a02:	e088                	sd	a0,0(s1)
}
    80002a04:	60e2                	ld	ra,24(sp)
    80002a06:	6442                	ld	s0,16(sp)
    80002a08:	64a2                	ld	s1,8(sp)
    80002a0a:	6105                	addi	sp,sp,32
    80002a0c:	8082                	ret

0000000080002a0e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002a0e:	7179                	addi	sp,sp,-48
    80002a10:	f406                	sd	ra,40(sp)
    80002a12:	f022                	sd	s0,32(sp)
    80002a14:	ec26                	sd	s1,24(sp)
    80002a16:	e84a                	sd	s2,16(sp)
    80002a18:	1800                	addi	s0,sp,48
    80002a1a:	84ae                	mv	s1,a1
    80002a1c:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002a1e:	fd840593          	addi	a1,s0,-40
    80002a22:	fd1ff0ef          	jal	800029f2 <argaddr>
  return fetchstr(addr, buf, max);
    80002a26:	864a                	mv	a2,s2
    80002a28:	85a6                	mv	a1,s1
    80002a2a:	fd843503          	ld	a0,-40(s0)
    80002a2e:	f69ff0ef          	jal	80002996 <fetchstr>
}
    80002a32:	70a2                	ld	ra,40(sp)
    80002a34:	7402                	ld	s0,32(sp)
    80002a36:	64e2                	ld	s1,24(sp)
    80002a38:	6942                	ld	s2,16(sp)
    80002a3a:	6145                	addi	sp,sp,48
    80002a3c:	8082                	ret

0000000080002a3e <syscall>:
[SYS_sigcont] sys_sigcont,
};

void
syscall(void)
{
    80002a3e:	1101                	addi	sp,sp,-32
    80002a40:	ec06                	sd	ra,24(sp)
    80002a42:	e822                	sd	s0,16(sp)
    80002a44:	e426                	sd	s1,8(sp)
    80002a46:	e04a                	sd	s2,0(sp)
    80002a48:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002a4a:	ecbfe0ef          	jal	80001914 <myproc>
    80002a4e:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002a50:	05853903          	ld	s2,88(a0)
    80002a54:	0a893783          	ld	a5,168(s2)
    80002a58:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002a5c:	37fd                	addiw	a5,a5,-1
    80002a5e:	4769                	li	a4,26
    80002a60:	00f76f63          	bltu	a4,a5,80002a7e <syscall+0x40>
    80002a64:	00369713          	slli	a4,a3,0x3
    80002a68:	00005797          	auipc	a5,0x5
    80002a6c:	d8078793          	addi	a5,a5,-640 # 800077e8 <syscalls>
    80002a70:	97ba                	add	a5,a5,a4
    80002a72:	639c                	ld	a5,0(a5)
    80002a74:	c789                	beqz	a5,80002a7e <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002a76:	9782                	jalr	a5
    80002a78:	06a93823          	sd	a0,112(s2)
    80002a7c:	a829                	j	80002a96 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002a7e:	15848613          	addi	a2,s1,344
    80002a82:	588c                	lw	a1,48(s1)
    80002a84:	00005517          	auipc	a0,0x5
    80002a88:	98c50513          	addi	a0,a0,-1652 # 80007410 <etext+0x410>
    80002a8c:	a6bfd0ef          	jal	800004f6 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002a90:	6cbc                	ld	a5,88(s1)
    80002a92:	577d                	li	a4,-1
    80002a94:	fbb8                	sd	a4,112(a5)
  }
}
    80002a96:	60e2                	ld	ra,24(sp)
    80002a98:	6442                	ld	s0,16(sp)
    80002a9a:	64a2                	ld	s1,8(sp)
    80002a9c:	6902                	ld	s2,0(sp)
    80002a9e:	6105                	addi	sp,sp,32
    80002aa0:	8082                	ret

0000000080002aa2 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002aa2:	1101                	addi	sp,sp,-32
    80002aa4:	ec06                	sd	ra,24(sp)
    80002aa6:	e822                	sd	s0,16(sp)
    80002aa8:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002aaa:	fec40593          	addi	a1,s0,-20
    80002aae:	4501                	li	a0,0
    80002ab0:	f27ff0ef          	jal	800029d6 <argint>
  exit(n);
    80002ab4:	fec42503          	lw	a0,-20(s0)
    80002ab8:	d36ff0ef          	jal	80001fee <exit>
  return 0;  // not reached
}
    80002abc:	4501                	li	a0,0
    80002abe:	60e2                	ld	ra,24(sp)
    80002ac0:	6442                	ld	s0,16(sp)
    80002ac2:	6105                	addi	sp,sp,32
    80002ac4:	8082                	ret

0000000080002ac6 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002ac6:	1141                	addi	sp,sp,-16
    80002ac8:	e406                	sd	ra,8(sp)
    80002aca:	e022                	sd	s0,0(sp)
    80002acc:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002ace:	e47fe0ef          	jal	80001914 <myproc>
}
    80002ad2:	5908                	lw	a0,48(a0)
    80002ad4:	60a2                	ld	ra,8(sp)
    80002ad6:	6402                	ld	s0,0(sp)
    80002ad8:	0141                	addi	sp,sp,16
    80002ada:	8082                	ret

0000000080002adc <sys_fork>:

uint64
sys_fork(void)
{
    80002adc:	1141                	addi	sp,sp,-16
    80002ade:	e406                	sd	ra,8(sp)
    80002ae0:	e022                	sd	s0,0(sp)
    80002ae2:	0800                	addi	s0,sp,16
  return fork();
    80002ae4:	956ff0ef          	jal	80001c3a <fork>
}
    80002ae8:	60a2                	ld	ra,8(sp)
    80002aea:	6402                	ld	s0,0(sp)
    80002aec:	0141                	addi	sp,sp,16
    80002aee:	8082                	ret

0000000080002af0 <sys_wait>:

uint64
sys_wait(void)
{
    80002af0:	1101                	addi	sp,sp,-32
    80002af2:	ec06                	sd	ra,24(sp)
    80002af4:	e822                	sd	s0,16(sp)
    80002af6:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002af8:	fe840593          	addi	a1,s0,-24
    80002afc:	4501                	li	a0,0
    80002afe:	ef5ff0ef          	jal	800029f2 <argaddr>
  return wait(p);
    80002b02:	fe843503          	ld	a0,-24(s0)
    80002b06:	e3eff0ef          	jal	80002144 <wait>
}
    80002b0a:	60e2                	ld	ra,24(sp)
    80002b0c:	6442                	ld	s0,16(sp)
    80002b0e:	6105                	addi	sp,sp,32
    80002b10:	8082                	ret

0000000080002b12 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002b12:	7179                	addi	sp,sp,-48
    80002b14:	f406                	sd	ra,40(sp)
    80002b16:	f022                	sd	s0,32(sp)
    80002b18:	ec26                	sd	s1,24(sp)
    80002b1a:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002b1c:	fdc40593          	addi	a1,s0,-36
    80002b20:	4501                	li	a0,0
    80002b22:	eb5ff0ef          	jal	800029d6 <argint>
  addr = myproc()->sz;
    80002b26:	deffe0ef          	jal	80001914 <myproc>
    80002b2a:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002b2c:	fdc42503          	lw	a0,-36(s0)
    80002b30:	8baff0ef          	jal	80001bea <growproc>
    80002b34:	00054863          	bltz	a0,80002b44 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80002b38:	8526                	mv	a0,s1
    80002b3a:	70a2                	ld	ra,40(sp)
    80002b3c:	7402                	ld	s0,32(sp)
    80002b3e:	64e2                	ld	s1,24(sp)
    80002b40:	6145                	addi	sp,sp,48
    80002b42:	8082                	ret
    return -1;
    80002b44:	54fd                	li	s1,-1
    80002b46:	bfcd                	j	80002b38 <sys_sbrk+0x26>

0000000080002b48 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002b48:	7139                	addi	sp,sp,-64
    80002b4a:	fc06                	sd	ra,56(sp)
    80002b4c:	f822                	sd	s0,48(sp)
    80002b4e:	f04a                	sd	s2,32(sp)
    80002b50:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002b52:	fcc40593          	addi	a1,s0,-52
    80002b56:	4501                	li	a0,0
    80002b58:	e7fff0ef          	jal	800029d6 <argint>
  if(n < 0)
    80002b5c:	fcc42783          	lw	a5,-52(s0)
    80002b60:	0607c763          	bltz	a5,80002bce <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80002b64:	00016517          	auipc	a0,0x16
    80002b68:	87c50513          	addi	a0,a0,-1924 # 800183e0 <tickslock>
    80002b6c:	8bcfe0ef          	jal	80000c28 <acquire>
  ticks0 = ticks;
    80002b70:	00008917          	auipc	s2,0x8
    80002b74:	91092903          	lw	s2,-1776(s2) # 8000a480 <ticks>
  while(ticks - ticks0 < n){
    80002b78:	fcc42783          	lw	a5,-52(s0)
    80002b7c:	cf8d                	beqz	a5,80002bb6 <sys_sleep+0x6e>
    80002b7e:	f426                	sd	s1,40(sp)
    80002b80:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002b82:	00016997          	auipc	s3,0x16
    80002b86:	85e98993          	addi	s3,s3,-1954 # 800183e0 <tickslock>
    80002b8a:	00008497          	auipc	s1,0x8
    80002b8e:	8f648493          	addi	s1,s1,-1802 # 8000a480 <ticks>
    if(killed(myproc())){
    80002b92:	d83fe0ef          	jal	80001914 <myproc>
    80002b96:	d84ff0ef          	jal	8000211a <killed>
    80002b9a:	ed0d                	bnez	a0,80002bd4 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    80002b9c:	85ce                	mv	a1,s3
    80002b9e:	8526                	mv	a0,s1
    80002ba0:	b42ff0ef          	jal	80001ee2 <sleep>
  while(ticks - ticks0 < n){
    80002ba4:	409c                	lw	a5,0(s1)
    80002ba6:	412787bb          	subw	a5,a5,s2
    80002baa:	fcc42703          	lw	a4,-52(s0)
    80002bae:	fee7e2e3          	bltu	a5,a4,80002b92 <sys_sleep+0x4a>
    80002bb2:	74a2                	ld	s1,40(sp)
    80002bb4:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002bb6:	00016517          	auipc	a0,0x16
    80002bba:	82a50513          	addi	a0,a0,-2006 # 800183e0 <tickslock>
    80002bbe:	902fe0ef          	jal	80000cc0 <release>
  return 0;
    80002bc2:	4501                	li	a0,0
}
    80002bc4:	70e2                	ld	ra,56(sp)
    80002bc6:	7442                	ld	s0,48(sp)
    80002bc8:	7902                	ld	s2,32(sp)
    80002bca:	6121                	addi	sp,sp,64
    80002bcc:	8082                	ret
    n = 0;
    80002bce:	fc042623          	sw	zero,-52(s0)
    80002bd2:	bf49                	j	80002b64 <sys_sleep+0x1c>
      release(&tickslock);
    80002bd4:	00016517          	auipc	a0,0x16
    80002bd8:	80c50513          	addi	a0,a0,-2036 # 800183e0 <tickslock>
    80002bdc:	8e4fe0ef          	jal	80000cc0 <release>
      return -1;
    80002be0:	557d                	li	a0,-1
    80002be2:	74a2                	ld	s1,40(sp)
    80002be4:	69e2                	ld	s3,24(sp)
    80002be6:	bff9                	j	80002bc4 <sys_sleep+0x7c>

0000000080002be8 <sys_kill>:

uint64
sys_kill(void)
{
    80002be8:	1101                	addi	sp,sp,-32
    80002bea:	ec06                	sd	ra,24(sp)
    80002bec:	e822                	sd	s0,16(sp)
    80002bee:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002bf0:	fec40593          	addi	a1,s0,-20
    80002bf4:	4501                	li	a0,0
    80002bf6:	de1ff0ef          	jal	800029d6 <argint>
  return kill(pid);
    80002bfa:	fec42503          	lw	a0,-20(s0)
    80002bfe:	c92ff0ef          	jal	80002090 <kill>
}
    80002c02:	60e2                	ld	ra,24(sp)
    80002c04:	6442                	ld	s0,16(sp)
    80002c06:	6105                	addi	sp,sp,32
    80002c08:	8082                	ret

0000000080002c0a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002c0a:	1101                	addi	sp,sp,-32
    80002c0c:	ec06                	sd	ra,24(sp)
    80002c0e:	e822                	sd	s0,16(sp)
    80002c10:	e426                	sd	s1,8(sp)
    80002c12:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002c14:	00015517          	auipc	a0,0x15
    80002c18:	7cc50513          	addi	a0,a0,1996 # 800183e0 <tickslock>
    80002c1c:	80cfe0ef          	jal	80000c28 <acquire>
  xticks = ticks;
    80002c20:	00008497          	auipc	s1,0x8
    80002c24:	8604a483          	lw	s1,-1952(s1) # 8000a480 <ticks>
  release(&tickslock);
    80002c28:	00015517          	auipc	a0,0x15
    80002c2c:	7b850513          	addi	a0,a0,1976 # 800183e0 <tickslock>
    80002c30:	890fe0ef          	jal	80000cc0 <release>
  return xticks;
}
    80002c34:	02049513          	slli	a0,s1,0x20
    80002c38:	9101                	srli	a0,a0,0x20
    80002c3a:	60e2                	ld	ra,24(sp)
    80002c3c:	6442                	ld	s0,16(sp)
    80002c3e:	64a2                	ld	s1,8(sp)
    80002c40:	6105                	addi	sp,sp,32
    80002c42:	8082                	ret

0000000080002c44 <sys_forex>:

uint64
sys_forex(void)
{
    80002c44:	716d                	addi	sp,sp,-272
    80002c46:	e606                	sd	ra,264(sp)
    80002c48:	e222                	sd	s0,256(sp)
    80002c4a:	fda6                	sd	s1,248(sp)
    80002c4c:	0a00                	addi	s0,sp,272
    char filename[128]; // Buffer for the filename
    int pid;

    // Fetch the filename argument from user space
    if (argstr(0, filename, sizeof(filename)) < 0) {
    80002c4e:	08000613          	li	a2,128
    80002c52:	f6040593          	addi	a1,s0,-160
    80002c56:	4501                	li	a0,0
    80002c58:	db7ff0ef          	jal	80002a0e <argstr>
    80002c5c:	04054d63          	bltz	a0,80002cb6 <sys_forex+0x72>
    }
    char full_path[100];
    int i = 0;

    // Add the '/' to the path
    full_path[i++] = '/';
    80002c60:	02f00793          	li	a5,47
    80002c64:	eef40c23          	sb	a5,-264(s0)

    // Copy the filename to the full_path starting after the '/'
    for (int j = 0; filename[j] != '\0'; j++, i++) {
    80002c68:	f6044703          	lbu	a4,-160(s0)
    80002c6c:	cb21                	beqz	a4,80002cbc <sys_forex+0x78>
    80002c6e:	4789                	li	a5,2
        full_path[i] = filename[j];
    80002c70:	ef840693          	addi	a3,s0,-264
    80002c74:	96be                	add	a3,a3,a5
    80002c76:	fee68fa3          	sb	a4,-1(a3)
    for (int j = 0; filename[j] != '\0'; j++, i++) {
    80002c7a:	86be                	mv	a3,a5
    80002c7c:	0785                	addi	a5,a5,1
    80002c7e:	f6040713          	addi	a4,s0,-160
    80002c82:	973e                	add	a4,a4,a5
    80002c84:	ffe74703          	lbu	a4,-2(a4)
    80002c88:	f765                	bnez	a4,80002c70 <sys_forex+0x2c>
    80002c8a:	2681                	sext.w	a3,a3
    }

    // Null-terminate the string
    full_path[i] = '\0';
    80002c8c:	fe068793          	addi	a5,a3,-32
    80002c90:	008786b3          	add	a3,a5,s0
    80002c94:	f0068c23          	sb	zero,-232(a3)
    pid = fork();
    80002c98:	fa3fe0ef          	jal	80001c3a <fork>
    80002c9c:	84aa                	mv	s1,a0
    if (pid < 0) 
    80002c9e:	04054363          	bltz	a0,80002ce4 <sys_forex+0xa0>
    {
      return -1; // Fork failed
    }
    if (pid == 0) 
    80002ca2:	e501                	bnez	a0,80002caa <sys_forex+0x66>
    {
      // In child process
      if (filename[0] != '\0') 
    80002ca4:	f6044783          	lbu	a5,-160(s0)
    80002ca8:	ef81                	bnez	a5,80002cc0 <sys_forex+0x7c>
        exit(0); // Exit if exec fails
      }
      // If no filename is provided, continue as a normal forked process
    }
    // In parent process, return the PID of the child
    return pid;
    80002caa:	8526                	mv	a0,s1
}
    80002cac:	60b2                	ld	ra,264(sp)
    80002cae:	6412                	ld	s0,256(sp)
    80002cb0:	74ee                	ld	s1,248(sp)
    80002cb2:	6151                	addi	sp,sp,272
    80002cb4:	8082                	ret
        filename[0] = '\0'; // Set to an empty string if no argument is provided
    80002cb6:	f6040023          	sb	zero,-160(s0)
    80002cba:	b75d                	j	80002c60 <sys_forex+0x1c>
    full_path[i++] = '/';
    80002cbc:	4685                	li	a3,1
    80002cbe:	b7f9                	j	80002c8c <sys_forex+0x48>
        if(exec(full_path, 0)<0)
    80002cc0:	4581                	li	a1,0
    80002cc2:	ef840513          	addi	a0,s0,-264
    80002cc6:	3c9010ef          	jal	8000488e <exec>
    80002cca:	00054663          	bltz	a0,80002cd6 <sys_forex+0x92>
        exit(0); // Exit if exec fails
    80002cce:	4501                	li	a0,0
    80002cd0:	b1eff0ef          	jal	80001fee <exit>
    80002cd4:	bfd9                	j	80002caa <sys_forex+0x66>
        	printf("File not opening!\n");
    80002cd6:	00004517          	auipc	a0,0x4
    80002cda:	75a50513          	addi	a0,a0,1882 # 80007430 <etext+0x430>
    80002cde:	819fd0ef          	jal	800004f6 <printf>
    80002ce2:	b7f5                	j	80002cce <sys_forex+0x8a>
      return -1; // Fork failed
    80002ce4:	557d                	li	a0,-1
    80002ce6:	b7d9                	j	80002cac <sys_forex+0x68>

0000000080002ce8 <sys_getppid>:

uint64 
sys_getppid(void) {
    80002ce8:	1141                	addi	sp,sp,-16
    80002cea:	e406                	sd	ra,8(sp)
    80002cec:	e022                	sd	s0,0(sp)
    80002cee:	0800                	addi	s0,sp,16
    struct proc *p = myproc();  // Get the current process
    80002cf0:	c25fe0ef          	jal	80001914 <myproc>
    return p->parent ? p->parent->pid : 0;  // Return the parent's PID, or 0 if no parent
    80002cf4:	7d1c                	ld	a5,56(a0)
    80002cf6:	4501                	li	a0,0
    80002cf8:	c391                	beqz	a5,80002cfc <sys_getppid+0x14>
    80002cfa:	5b88                	lw	a0,48(a5)
}
    80002cfc:	60a2                	ld	ra,8(sp)
    80002cfe:	6402                	ld	s0,0(sp)
    80002d00:	0141                	addi	sp,sp,16
    80002d02:	8082                	ret

0000000080002d04 <sys_usleep>:

int 
sys_usleep(void) {
    80002d04:	7139                	addi	sp,sp,-64
    80002d06:	fc06                	sd	ra,56(sp)
    80002d08:	f822                	sd	s0,48(sp)
    80002d0a:	0080                	addi	s0,sp,64
    int microseconds;
    argint(0, &microseconds);
    80002d0c:	fcc40593          	addi	a1,s0,-52
    80002d10:	4501                	li	a0,0
    80002d12:	cc5ff0ef          	jal	800029d6 <argint>
    if (microseconds < 0) {
    80002d16:	fcc42503          	lw	a0,-52(s0)
    80002d1a:	08054263          	bltz	a0,80002d9e <sys_usleep+0x9a>
        return -1;
    }

    // For very small delays, use microdelay
    if (microseconds < 1000) {
    80002d1e:	3e700793          	li	a5,999
    80002d22:	06a7da63          	bge	a5,a0,80002d96 <sys_usleep+0x92>
    80002d26:	f426                	sd	s1,40(sp)
    80002d28:	f04a                	sd	s2,32(sp)
    80002d2a:	ec4e                	sd	s3,24(sp)
        microdelay(microseconds);
        return 0;
    }

    // For larger delays, use the sleep mechanism
    uint ticks = microseconds / 1000; // Convert to milliseconds
    80002d2c:	3e800793          	li	a5,1000
    80002d30:	02f5453b          	divw	a0,a0,a5
    80002d34:	0005091b          	sext.w	s2,a0
    80002d38:	fca42423          	sw	a0,-56(s0)
    uint start_ticks = ticks;
    acquire(&tickslock);
    80002d3c:	00015517          	auipc	a0,0x15
    80002d40:	6a450513          	addi	a0,a0,1700 # 800183e0 <tickslock>
    80002d44:	ee5fd0ef          	jal	80000c28 <acquire>
    while (ticks > 0 && ticks - start_ticks < microseconds / 1000) {
    80002d48:	fc842783          	lw	a5,-56(s0)
    80002d4c:	3e800493          	li	s1,1000
        sleep(&ticks, &tickslock);
    80002d50:	00015997          	auipc	s3,0x15
    80002d54:	69098993          	addi	s3,s3,1680 # 800183e0 <tickslock>
    while (ticks > 0 && ticks - start_ticks < microseconds / 1000) {
    80002d58:	c38d                	beqz	a5,80002d7a <sys_usleep+0x76>
    80002d5a:	fcc42703          	lw	a4,-52(s0)
    80002d5e:	412787bb          	subw	a5,a5,s2
    80002d62:	0297473b          	divw	a4,a4,s1
    80002d66:	00e7fa63          	bgeu	a5,a4,80002d7a <sys_usleep+0x76>
        sleep(&ticks, &tickslock);
    80002d6a:	85ce                	mv	a1,s3
    80002d6c:	fc840513          	addi	a0,s0,-56
    80002d70:	972ff0ef          	jal	80001ee2 <sleep>
    while (ticks > 0 && ticks - start_ticks < microseconds / 1000) {
    80002d74:	fc842783          	lw	a5,-56(s0)
    80002d78:	f3ed                	bnez	a5,80002d5a <sys_usleep+0x56>
    }
    release(&tickslock);
    80002d7a:	00015517          	auipc	a0,0x15
    80002d7e:	66650513          	addi	a0,a0,1638 # 800183e0 <tickslock>
    80002d82:	f3ffd0ef          	jal	80000cc0 <release>

    return 0;
    80002d86:	4501                	li	a0,0
    80002d88:	74a2                	ld	s1,40(sp)
    80002d8a:	7902                	ld	s2,32(sp)
    80002d8c:	69e2                	ld	s3,24(sp)
}
    80002d8e:	70e2                	ld	ra,56(sp)
    80002d90:	7442                	ld	s0,48(sp)
    80002d92:	6121                	addi	sp,sp,64
    80002d94:	8082                	ret
        microdelay(microseconds);
    80002d96:	caafd0ef          	jal	80000240 <microdelay>
        return 0;
    80002d9a:	4501                	li	a0,0
    80002d9c:	bfcd                	j	80002d8e <sys_usleep+0x8a>
        return -1;
    80002d9e:	557d                	li	a0,-1
    80002da0:	b7fd                	j	80002d8e <sys_usleep+0x8a>

0000000080002da2 <sys_waitpid>:

uint64
sys_waitpid(void)
{
    80002da2:	1101                	addi	sp,sp,-32
    80002da4:	ec06                	sd	ra,24(sp)
    80002da6:	e822                	sd	s0,16(sp)
    80002da8:	1000                	addi	s0,sp,32
    int pid;
    uint64 status;

    // Get arguments from user space
    argint(0, &pid);
    80002daa:	fec40593          	addi	a1,s0,-20
    80002dae:	4501                	li	a0,0
    80002db0:	c27ff0ef          	jal	800029d6 <argint>
    argaddr(1, &status);
    80002db4:	fe040593          	addi	a1,s0,-32
    80002db8:	4505                	li	a0,1
    80002dba:	c39ff0ef          	jal	800029f2 <argaddr>

    return waitpid(pid, status);
    80002dbe:	fe043583          	ld	a1,-32(s0)
    80002dc2:	fec42503          	lw	a0,-20(s0)
    80002dc6:	db0ff0ef          	jal	80002376 <waitpid>
}
    80002dca:	60e2                	ld	ra,24(sp)
    80002dcc:	6442                	ld	s0,16(sp)
    80002dce:	6105                	addi	sp,sp,32
    80002dd0:	8082                	ret

0000000080002dd2 <sys_sigstop>:


uint64 sys_sigstop(void) {
    80002dd2:	1101                	addi	sp,sp,-32
    80002dd4:	ec06                	sd	ra,24(sp)
    80002dd6:	e822                	sd	s0,16(sp)
    80002dd8:	1000                	addi	s0,sp,32
    int pid;
    //int ret;
    // Capture the return value of argint
    argint(0, &pid);
    80002dda:	fec40593          	addi	a1,s0,-20
    80002dde:	4501                	li	a0,0
    80002de0:	bf7ff0ef          	jal	800029d6 <argint>
    if (pid == 0)  
    80002de4:	fec42783          	lw	a5,-20(s0)
        return -1; // If argint fails, return -1
    80002de8:	557d                	li	a0,-1
    if (pid == 0)  
    80002dea:	c781                	beqz	a5,80002df2 <sys_sigstop+0x20>
    return sigstop(pid);
    80002dec:	853e                	mv	a0,a5
    80002dee:	edcff0ef          	jal	800024ca <sigstop>
    //         return 0;
    //     }
    //     release(&p->lock);
    // }
    // return -1;
}
    80002df2:	60e2                	ld	ra,24(sp)
    80002df4:	6442                	ld	s0,16(sp)
    80002df6:	6105                	addi	sp,sp,32
    80002df8:	8082                	ret

0000000080002dfa <sys_sigcont>:

uint64 sys_sigcont(void) {
    80002dfa:	1101                	addi	sp,sp,-32
    80002dfc:	ec06                	sd	ra,24(sp)
    80002dfe:	e822                	sd	s0,16(sp)
    80002e00:	1000                	addi	s0,sp,32
    int pid;
    //int ret;
    // Capture the return value of argint
    argint(0, &pid);
    80002e02:	fec40593          	addi	a1,s0,-20
    80002e06:	4501                	li	a0,0
    80002e08:	bcfff0ef          	jal	800029d6 <argint>
    if (pid== 0)  
    80002e0c:	fec42783          	lw	a5,-20(s0)
        return -1; // If argint fails, return -1
    80002e10:	557d                	li	a0,-1
    if (pid== 0)  
    80002e12:	c781                	beqz	a5,80002e1a <sys_sigcont+0x20>
    return sigcont(pid);
    80002e14:	853e                	mv	a0,a5
    80002e16:	f0cff0ef          	jal	80002522 <sigcont>
}
    80002e1a:	60e2                	ld	ra,24(sp)
    80002e1c:	6442                	ld	s0,16(sp)
    80002e1e:	6105                	addi	sp,sp,32
    80002e20:	8082                	ret

0000000080002e22 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002e22:	7179                	addi	sp,sp,-48
    80002e24:	f406                	sd	ra,40(sp)
    80002e26:	f022                	sd	s0,32(sp)
    80002e28:	ec26                	sd	s1,24(sp)
    80002e2a:	e84a                	sd	s2,16(sp)
    80002e2c:	e44e                	sd	s3,8(sp)
    80002e2e:	e052                	sd	s4,0(sp)
    80002e30:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002e32:	00004597          	auipc	a1,0x4
    80002e36:	61658593          	addi	a1,a1,1558 # 80007448 <etext+0x448>
    80002e3a:	00015517          	auipc	a0,0x15
    80002e3e:	5be50513          	addi	a0,a0,1470 # 800183f8 <bcache>
    80002e42:	d67fd0ef          	jal	80000ba8 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002e46:	0001d797          	auipc	a5,0x1d
    80002e4a:	5b278793          	addi	a5,a5,1458 # 800203f8 <bcache+0x8000>
    80002e4e:	0001e717          	auipc	a4,0x1e
    80002e52:	81270713          	addi	a4,a4,-2030 # 80020660 <bcache+0x8268>
    80002e56:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002e5a:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e5e:	00015497          	auipc	s1,0x15
    80002e62:	5b248493          	addi	s1,s1,1458 # 80018410 <bcache+0x18>
    b->next = bcache.head.next;
    80002e66:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002e68:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002e6a:	00004a17          	auipc	s4,0x4
    80002e6e:	5e6a0a13          	addi	s4,s4,1510 # 80007450 <etext+0x450>
    b->next = bcache.head.next;
    80002e72:	2b893783          	ld	a5,696(s2)
    80002e76:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002e78:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002e7c:	85d2                	mv	a1,s4
    80002e7e:	01048513          	addi	a0,s1,16
    80002e82:	248010ef          	jal	800040ca <initsleeplock>
    bcache.head.next->prev = b;
    80002e86:	2b893783          	ld	a5,696(s2)
    80002e8a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002e8c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e90:	45848493          	addi	s1,s1,1112
    80002e94:	fd349fe3          	bne	s1,s3,80002e72 <binit+0x50>
  }
}
    80002e98:	70a2                	ld	ra,40(sp)
    80002e9a:	7402                	ld	s0,32(sp)
    80002e9c:	64e2                	ld	s1,24(sp)
    80002e9e:	6942                	ld	s2,16(sp)
    80002ea0:	69a2                	ld	s3,8(sp)
    80002ea2:	6a02                	ld	s4,0(sp)
    80002ea4:	6145                	addi	sp,sp,48
    80002ea6:	8082                	ret

0000000080002ea8 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002ea8:	7179                	addi	sp,sp,-48
    80002eaa:	f406                	sd	ra,40(sp)
    80002eac:	f022                	sd	s0,32(sp)
    80002eae:	ec26                	sd	s1,24(sp)
    80002eb0:	e84a                	sd	s2,16(sp)
    80002eb2:	e44e                	sd	s3,8(sp)
    80002eb4:	1800                	addi	s0,sp,48
    80002eb6:	892a                	mv	s2,a0
    80002eb8:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002eba:	00015517          	auipc	a0,0x15
    80002ebe:	53e50513          	addi	a0,a0,1342 # 800183f8 <bcache>
    80002ec2:	d67fd0ef          	jal	80000c28 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002ec6:	0001d497          	auipc	s1,0x1d
    80002eca:	7ea4b483          	ld	s1,2026(s1) # 800206b0 <bcache+0x82b8>
    80002ece:	0001d797          	auipc	a5,0x1d
    80002ed2:	79278793          	addi	a5,a5,1938 # 80020660 <bcache+0x8268>
    80002ed6:	02f48b63          	beq	s1,a5,80002f0c <bread+0x64>
    80002eda:	873e                	mv	a4,a5
    80002edc:	a021                	j	80002ee4 <bread+0x3c>
    80002ede:	68a4                	ld	s1,80(s1)
    80002ee0:	02e48663          	beq	s1,a4,80002f0c <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002ee4:	449c                	lw	a5,8(s1)
    80002ee6:	ff279ce3          	bne	a5,s2,80002ede <bread+0x36>
    80002eea:	44dc                	lw	a5,12(s1)
    80002eec:	ff3799e3          	bne	a5,s3,80002ede <bread+0x36>
      b->refcnt++;
    80002ef0:	40bc                	lw	a5,64(s1)
    80002ef2:	2785                	addiw	a5,a5,1
    80002ef4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ef6:	00015517          	auipc	a0,0x15
    80002efa:	50250513          	addi	a0,a0,1282 # 800183f8 <bcache>
    80002efe:	dc3fd0ef          	jal	80000cc0 <release>
      acquiresleep(&b->lock);
    80002f02:	01048513          	addi	a0,s1,16
    80002f06:	1fa010ef          	jal	80004100 <acquiresleep>
      return b;
    80002f0a:	a889                	j	80002f5c <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f0c:	0001d497          	auipc	s1,0x1d
    80002f10:	79c4b483          	ld	s1,1948(s1) # 800206a8 <bcache+0x82b0>
    80002f14:	0001d797          	auipc	a5,0x1d
    80002f18:	74c78793          	addi	a5,a5,1868 # 80020660 <bcache+0x8268>
    80002f1c:	00f48863          	beq	s1,a5,80002f2c <bread+0x84>
    80002f20:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002f22:	40bc                	lw	a5,64(s1)
    80002f24:	cb91                	beqz	a5,80002f38 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f26:	64a4                	ld	s1,72(s1)
    80002f28:	fee49de3          	bne	s1,a4,80002f22 <bread+0x7a>
  panic("bget: no buffers");
    80002f2c:	00004517          	auipc	a0,0x4
    80002f30:	52c50513          	addi	a0,a0,1324 # 80007458 <etext+0x458>
    80002f34:	895fd0ef          	jal	800007c8 <panic>
      b->dev = dev;
    80002f38:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002f3c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002f40:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002f44:	4785                	li	a5,1
    80002f46:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f48:	00015517          	auipc	a0,0x15
    80002f4c:	4b050513          	addi	a0,a0,1200 # 800183f8 <bcache>
    80002f50:	d71fd0ef          	jal	80000cc0 <release>
      acquiresleep(&b->lock);
    80002f54:	01048513          	addi	a0,s1,16
    80002f58:	1a8010ef          	jal	80004100 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002f5c:	409c                	lw	a5,0(s1)
    80002f5e:	cb89                	beqz	a5,80002f70 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002f60:	8526                	mv	a0,s1
    80002f62:	70a2                	ld	ra,40(sp)
    80002f64:	7402                	ld	s0,32(sp)
    80002f66:	64e2                	ld	s1,24(sp)
    80002f68:	6942                	ld	s2,16(sp)
    80002f6a:	69a2                	ld	s3,8(sp)
    80002f6c:	6145                	addi	sp,sp,48
    80002f6e:	8082                	ret
    virtio_disk_rw(b, 0);
    80002f70:	4581                	li	a1,0
    80002f72:	8526                	mv	a0,s1
    80002f74:	1ed020ef          	jal	80005960 <virtio_disk_rw>
    b->valid = 1;
    80002f78:	4785                	li	a5,1
    80002f7a:	c09c                	sw	a5,0(s1)
  return b;
    80002f7c:	b7d5                	j	80002f60 <bread+0xb8>

0000000080002f7e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002f7e:	1101                	addi	sp,sp,-32
    80002f80:	ec06                	sd	ra,24(sp)
    80002f82:	e822                	sd	s0,16(sp)
    80002f84:	e426                	sd	s1,8(sp)
    80002f86:	1000                	addi	s0,sp,32
    80002f88:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f8a:	0541                	addi	a0,a0,16
    80002f8c:	1f2010ef          	jal	8000417e <holdingsleep>
    80002f90:	c911                	beqz	a0,80002fa4 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002f92:	4585                	li	a1,1
    80002f94:	8526                	mv	a0,s1
    80002f96:	1cb020ef          	jal	80005960 <virtio_disk_rw>
}
    80002f9a:	60e2                	ld	ra,24(sp)
    80002f9c:	6442                	ld	s0,16(sp)
    80002f9e:	64a2                	ld	s1,8(sp)
    80002fa0:	6105                	addi	sp,sp,32
    80002fa2:	8082                	ret
    panic("bwrite");
    80002fa4:	00004517          	auipc	a0,0x4
    80002fa8:	4cc50513          	addi	a0,a0,1228 # 80007470 <etext+0x470>
    80002fac:	81dfd0ef          	jal	800007c8 <panic>

0000000080002fb0 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002fb0:	1101                	addi	sp,sp,-32
    80002fb2:	ec06                	sd	ra,24(sp)
    80002fb4:	e822                	sd	s0,16(sp)
    80002fb6:	e426                	sd	s1,8(sp)
    80002fb8:	e04a                	sd	s2,0(sp)
    80002fba:	1000                	addi	s0,sp,32
    80002fbc:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002fbe:	01050913          	addi	s2,a0,16
    80002fc2:	854a                	mv	a0,s2
    80002fc4:	1ba010ef          	jal	8000417e <holdingsleep>
    80002fc8:	c135                	beqz	a0,8000302c <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002fca:	854a                	mv	a0,s2
    80002fcc:	17a010ef          	jal	80004146 <releasesleep>

  acquire(&bcache.lock);
    80002fd0:	00015517          	auipc	a0,0x15
    80002fd4:	42850513          	addi	a0,a0,1064 # 800183f8 <bcache>
    80002fd8:	c51fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002fdc:	40bc                	lw	a5,64(s1)
    80002fde:	37fd                	addiw	a5,a5,-1
    80002fe0:	0007871b          	sext.w	a4,a5
    80002fe4:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002fe6:	e71d                	bnez	a4,80003014 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002fe8:	68b8                	ld	a4,80(s1)
    80002fea:	64bc                	ld	a5,72(s1)
    80002fec:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002fee:	68b8                	ld	a4,80(s1)
    80002ff0:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002ff2:	0001d797          	auipc	a5,0x1d
    80002ff6:	40678793          	addi	a5,a5,1030 # 800203f8 <bcache+0x8000>
    80002ffa:	2b87b703          	ld	a4,696(a5)
    80002ffe:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003000:	0001d717          	auipc	a4,0x1d
    80003004:	66070713          	addi	a4,a4,1632 # 80020660 <bcache+0x8268>
    80003008:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000300a:	2b87b703          	ld	a4,696(a5)
    8000300e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003010:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003014:	00015517          	auipc	a0,0x15
    80003018:	3e450513          	addi	a0,a0,996 # 800183f8 <bcache>
    8000301c:	ca5fd0ef          	jal	80000cc0 <release>
}
    80003020:	60e2                	ld	ra,24(sp)
    80003022:	6442                	ld	s0,16(sp)
    80003024:	64a2                	ld	s1,8(sp)
    80003026:	6902                	ld	s2,0(sp)
    80003028:	6105                	addi	sp,sp,32
    8000302a:	8082                	ret
    panic("brelse");
    8000302c:	00004517          	auipc	a0,0x4
    80003030:	44c50513          	addi	a0,a0,1100 # 80007478 <etext+0x478>
    80003034:	f94fd0ef          	jal	800007c8 <panic>

0000000080003038 <bpin>:

void
bpin(struct buf *b) {
    80003038:	1101                	addi	sp,sp,-32
    8000303a:	ec06                	sd	ra,24(sp)
    8000303c:	e822                	sd	s0,16(sp)
    8000303e:	e426                	sd	s1,8(sp)
    80003040:	1000                	addi	s0,sp,32
    80003042:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003044:	00015517          	auipc	a0,0x15
    80003048:	3b450513          	addi	a0,a0,948 # 800183f8 <bcache>
    8000304c:	bddfd0ef          	jal	80000c28 <acquire>
  b->refcnt++;
    80003050:	40bc                	lw	a5,64(s1)
    80003052:	2785                	addiw	a5,a5,1
    80003054:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003056:	00015517          	auipc	a0,0x15
    8000305a:	3a250513          	addi	a0,a0,930 # 800183f8 <bcache>
    8000305e:	c63fd0ef          	jal	80000cc0 <release>
}
    80003062:	60e2                	ld	ra,24(sp)
    80003064:	6442                	ld	s0,16(sp)
    80003066:	64a2                	ld	s1,8(sp)
    80003068:	6105                	addi	sp,sp,32
    8000306a:	8082                	ret

000000008000306c <bunpin>:

void
bunpin(struct buf *b) {
    8000306c:	1101                	addi	sp,sp,-32
    8000306e:	ec06                	sd	ra,24(sp)
    80003070:	e822                	sd	s0,16(sp)
    80003072:	e426                	sd	s1,8(sp)
    80003074:	1000                	addi	s0,sp,32
    80003076:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003078:	00015517          	auipc	a0,0x15
    8000307c:	38050513          	addi	a0,a0,896 # 800183f8 <bcache>
    80003080:	ba9fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80003084:	40bc                	lw	a5,64(s1)
    80003086:	37fd                	addiw	a5,a5,-1
    80003088:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000308a:	00015517          	auipc	a0,0x15
    8000308e:	36e50513          	addi	a0,a0,878 # 800183f8 <bcache>
    80003092:	c2ffd0ef          	jal	80000cc0 <release>
}
    80003096:	60e2                	ld	ra,24(sp)
    80003098:	6442                	ld	s0,16(sp)
    8000309a:	64a2                	ld	s1,8(sp)
    8000309c:	6105                	addi	sp,sp,32
    8000309e:	8082                	ret

00000000800030a0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800030a0:	1101                	addi	sp,sp,-32
    800030a2:	ec06                	sd	ra,24(sp)
    800030a4:	e822                	sd	s0,16(sp)
    800030a6:	e426                	sd	s1,8(sp)
    800030a8:	e04a                	sd	s2,0(sp)
    800030aa:	1000                	addi	s0,sp,32
    800030ac:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800030ae:	00d5d59b          	srliw	a1,a1,0xd
    800030b2:	0001e797          	auipc	a5,0x1e
    800030b6:	a227a783          	lw	a5,-1502(a5) # 80020ad4 <sb+0x1c>
    800030ba:	9dbd                	addw	a1,a1,a5
    800030bc:	dedff0ef          	jal	80002ea8 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800030c0:	0074f713          	andi	a4,s1,7
    800030c4:	4785                	li	a5,1
    800030c6:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800030ca:	14ce                	slli	s1,s1,0x33
    800030cc:	90d9                	srli	s1,s1,0x36
    800030ce:	00950733          	add	a4,a0,s1
    800030d2:	05874703          	lbu	a4,88(a4)
    800030d6:	00e7f6b3          	and	a3,a5,a4
    800030da:	c29d                	beqz	a3,80003100 <bfree+0x60>
    800030dc:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800030de:	94aa                	add	s1,s1,a0
    800030e0:	fff7c793          	not	a5,a5
    800030e4:	8f7d                	and	a4,a4,a5
    800030e6:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800030ea:	711000ef          	jal	80003ffa <log_write>
  brelse(bp);
    800030ee:	854a                	mv	a0,s2
    800030f0:	ec1ff0ef          	jal	80002fb0 <brelse>
}
    800030f4:	60e2                	ld	ra,24(sp)
    800030f6:	6442                	ld	s0,16(sp)
    800030f8:	64a2                	ld	s1,8(sp)
    800030fa:	6902                	ld	s2,0(sp)
    800030fc:	6105                	addi	sp,sp,32
    800030fe:	8082                	ret
    panic("freeing free block");
    80003100:	00004517          	auipc	a0,0x4
    80003104:	38050513          	addi	a0,a0,896 # 80007480 <etext+0x480>
    80003108:	ec0fd0ef          	jal	800007c8 <panic>

000000008000310c <balloc>:
{
    8000310c:	711d                	addi	sp,sp,-96
    8000310e:	ec86                	sd	ra,88(sp)
    80003110:	e8a2                	sd	s0,80(sp)
    80003112:	e4a6                	sd	s1,72(sp)
    80003114:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003116:	0001e797          	auipc	a5,0x1e
    8000311a:	9a67a783          	lw	a5,-1626(a5) # 80020abc <sb+0x4>
    8000311e:	0e078f63          	beqz	a5,8000321c <balloc+0x110>
    80003122:	e0ca                	sd	s2,64(sp)
    80003124:	fc4e                	sd	s3,56(sp)
    80003126:	f852                	sd	s4,48(sp)
    80003128:	f456                	sd	s5,40(sp)
    8000312a:	f05a                	sd	s6,32(sp)
    8000312c:	ec5e                	sd	s7,24(sp)
    8000312e:	e862                	sd	s8,16(sp)
    80003130:	e466                	sd	s9,8(sp)
    80003132:	8baa                	mv	s7,a0
    80003134:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003136:	0001eb17          	auipc	s6,0x1e
    8000313a:	982b0b13          	addi	s6,s6,-1662 # 80020ab8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000313e:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003140:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003142:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003144:	6c89                	lui	s9,0x2
    80003146:	a0b5                	j	800031b2 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003148:	97ca                	add	a5,a5,s2
    8000314a:	8e55                	or	a2,a2,a3
    8000314c:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003150:	854a                	mv	a0,s2
    80003152:	6a9000ef          	jal	80003ffa <log_write>
        brelse(bp);
    80003156:	854a                	mv	a0,s2
    80003158:	e59ff0ef          	jal	80002fb0 <brelse>
  bp = bread(dev, bno);
    8000315c:	85a6                	mv	a1,s1
    8000315e:	855e                	mv	a0,s7
    80003160:	d49ff0ef          	jal	80002ea8 <bread>
    80003164:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003166:	40000613          	li	a2,1024
    8000316a:	4581                	li	a1,0
    8000316c:	05850513          	addi	a0,a0,88
    80003170:	b8dfd0ef          	jal	80000cfc <memset>
  log_write(bp);
    80003174:	854a                	mv	a0,s2
    80003176:	685000ef          	jal	80003ffa <log_write>
  brelse(bp);
    8000317a:	854a                	mv	a0,s2
    8000317c:	e35ff0ef          	jal	80002fb0 <brelse>
}
    80003180:	6906                	ld	s2,64(sp)
    80003182:	79e2                	ld	s3,56(sp)
    80003184:	7a42                	ld	s4,48(sp)
    80003186:	7aa2                	ld	s5,40(sp)
    80003188:	7b02                	ld	s6,32(sp)
    8000318a:	6be2                	ld	s7,24(sp)
    8000318c:	6c42                	ld	s8,16(sp)
    8000318e:	6ca2                	ld	s9,8(sp)
}
    80003190:	8526                	mv	a0,s1
    80003192:	60e6                	ld	ra,88(sp)
    80003194:	6446                	ld	s0,80(sp)
    80003196:	64a6                	ld	s1,72(sp)
    80003198:	6125                	addi	sp,sp,96
    8000319a:	8082                	ret
    brelse(bp);
    8000319c:	854a                	mv	a0,s2
    8000319e:	e13ff0ef          	jal	80002fb0 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800031a2:	015c87bb          	addw	a5,s9,s5
    800031a6:	00078a9b          	sext.w	s5,a5
    800031aa:	004b2703          	lw	a4,4(s6)
    800031ae:	04eaff63          	bgeu	s5,a4,8000320c <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    800031b2:	41fad79b          	sraiw	a5,s5,0x1f
    800031b6:	0137d79b          	srliw	a5,a5,0x13
    800031ba:	015787bb          	addw	a5,a5,s5
    800031be:	40d7d79b          	sraiw	a5,a5,0xd
    800031c2:	01cb2583          	lw	a1,28(s6)
    800031c6:	9dbd                	addw	a1,a1,a5
    800031c8:	855e                	mv	a0,s7
    800031ca:	cdfff0ef          	jal	80002ea8 <bread>
    800031ce:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031d0:	004b2503          	lw	a0,4(s6)
    800031d4:	000a849b          	sext.w	s1,s5
    800031d8:	8762                	mv	a4,s8
    800031da:	fca4f1e3          	bgeu	s1,a0,8000319c <balloc+0x90>
      m = 1 << (bi % 8);
    800031de:	00777693          	andi	a3,a4,7
    800031e2:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800031e6:	41f7579b          	sraiw	a5,a4,0x1f
    800031ea:	01d7d79b          	srliw	a5,a5,0x1d
    800031ee:	9fb9                	addw	a5,a5,a4
    800031f0:	4037d79b          	sraiw	a5,a5,0x3
    800031f4:	00f90633          	add	a2,s2,a5
    800031f8:	05864603          	lbu	a2,88(a2)
    800031fc:	00c6f5b3          	and	a1,a3,a2
    80003200:	d5a1                	beqz	a1,80003148 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003202:	2705                	addiw	a4,a4,1
    80003204:	2485                	addiw	s1,s1,1
    80003206:	fd471ae3          	bne	a4,s4,800031da <balloc+0xce>
    8000320a:	bf49                	j	8000319c <balloc+0x90>
    8000320c:	6906                	ld	s2,64(sp)
    8000320e:	79e2                	ld	s3,56(sp)
    80003210:	7a42                	ld	s4,48(sp)
    80003212:	7aa2                	ld	s5,40(sp)
    80003214:	7b02                	ld	s6,32(sp)
    80003216:	6be2                	ld	s7,24(sp)
    80003218:	6c42                	ld	s8,16(sp)
    8000321a:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    8000321c:	00004517          	auipc	a0,0x4
    80003220:	27c50513          	addi	a0,a0,636 # 80007498 <etext+0x498>
    80003224:	ad2fd0ef          	jal	800004f6 <printf>
  return 0;
    80003228:	4481                	li	s1,0
    8000322a:	b79d                	j	80003190 <balloc+0x84>

000000008000322c <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000322c:	7179                	addi	sp,sp,-48
    8000322e:	f406                	sd	ra,40(sp)
    80003230:	f022                	sd	s0,32(sp)
    80003232:	ec26                	sd	s1,24(sp)
    80003234:	e84a                	sd	s2,16(sp)
    80003236:	e44e                	sd	s3,8(sp)
    80003238:	1800                	addi	s0,sp,48
    8000323a:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000323c:	47ad                	li	a5,11
    8000323e:	02b7e663          	bltu	a5,a1,8000326a <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80003242:	02059793          	slli	a5,a1,0x20
    80003246:	01e7d593          	srli	a1,a5,0x1e
    8000324a:	00b504b3          	add	s1,a0,a1
    8000324e:	0504a903          	lw	s2,80(s1)
    80003252:	06091a63          	bnez	s2,800032c6 <bmap+0x9a>
      addr = balloc(ip->dev);
    80003256:	4108                	lw	a0,0(a0)
    80003258:	eb5ff0ef          	jal	8000310c <balloc>
    8000325c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003260:	06090363          	beqz	s2,800032c6 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80003264:	0524a823          	sw	s2,80(s1)
    80003268:	a8b9                	j	800032c6 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000326a:	ff45849b          	addiw	s1,a1,-12
    8000326e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003272:	0ff00793          	li	a5,255
    80003276:	06e7ee63          	bltu	a5,a4,800032f2 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000327a:	08052903          	lw	s2,128(a0)
    8000327e:	00091d63          	bnez	s2,80003298 <bmap+0x6c>
      addr = balloc(ip->dev);
    80003282:	4108                	lw	a0,0(a0)
    80003284:	e89ff0ef          	jal	8000310c <balloc>
    80003288:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000328c:	02090d63          	beqz	s2,800032c6 <bmap+0x9a>
    80003290:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003292:	0929a023          	sw	s2,128(s3)
    80003296:	a011                	j	8000329a <bmap+0x6e>
    80003298:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    8000329a:	85ca                	mv	a1,s2
    8000329c:	0009a503          	lw	a0,0(s3)
    800032a0:	c09ff0ef          	jal	80002ea8 <bread>
    800032a4:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800032a6:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800032aa:	02049713          	slli	a4,s1,0x20
    800032ae:	01e75593          	srli	a1,a4,0x1e
    800032b2:	00b784b3          	add	s1,a5,a1
    800032b6:	0004a903          	lw	s2,0(s1)
    800032ba:	00090e63          	beqz	s2,800032d6 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800032be:	8552                	mv	a0,s4
    800032c0:	cf1ff0ef          	jal	80002fb0 <brelse>
    return addr;
    800032c4:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800032c6:	854a                	mv	a0,s2
    800032c8:	70a2                	ld	ra,40(sp)
    800032ca:	7402                	ld	s0,32(sp)
    800032cc:	64e2                	ld	s1,24(sp)
    800032ce:	6942                	ld	s2,16(sp)
    800032d0:	69a2                	ld	s3,8(sp)
    800032d2:	6145                	addi	sp,sp,48
    800032d4:	8082                	ret
      addr = balloc(ip->dev);
    800032d6:	0009a503          	lw	a0,0(s3)
    800032da:	e33ff0ef          	jal	8000310c <balloc>
    800032de:	0005091b          	sext.w	s2,a0
      if(addr){
    800032e2:	fc090ee3          	beqz	s2,800032be <bmap+0x92>
        a[bn] = addr;
    800032e6:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800032ea:	8552                	mv	a0,s4
    800032ec:	50f000ef          	jal	80003ffa <log_write>
    800032f0:	b7f9                	j	800032be <bmap+0x92>
    800032f2:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800032f4:	00004517          	auipc	a0,0x4
    800032f8:	1bc50513          	addi	a0,a0,444 # 800074b0 <etext+0x4b0>
    800032fc:	cccfd0ef          	jal	800007c8 <panic>

0000000080003300 <iget>:
{
    80003300:	7179                	addi	sp,sp,-48
    80003302:	f406                	sd	ra,40(sp)
    80003304:	f022                	sd	s0,32(sp)
    80003306:	ec26                	sd	s1,24(sp)
    80003308:	e84a                	sd	s2,16(sp)
    8000330a:	e44e                	sd	s3,8(sp)
    8000330c:	e052                	sd	s4,0(sp)
    8000330e:	1800                	addi	s0,sp,48
    80003310:	89aa                	mv	s3,a0
    80003312:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003314:	0001d517          	auipc	a0,0x1d
    80003318:	7c450513          	addi	a0,a0,1988 # 80020ad8 <itable>
    8000331c:	90dfd0ef          	jal	80000c28 <acquire>
  empty = 0;
    80003320:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003322:	0001d497          	auipc	s1,0x1d
    80003326:	7ce48493          	addi	s1,s1,1998 # 80020af0 <itable+0x18>
    8000332a:	0001f697          	auipc	a3,0x1f
    8000332e:	25668693          	addi	a3,a3,598 # 80022580 <log>
    80003332:	a039                	j	80003340 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003334:	02090963          	beqz	s2,80003366 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003338:	08848493          	addi	s1,s1,136
    8000333c:	02d48863          	beq	s1,a3,8000336c <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003340:	449c                	lw	a5,8(s1)
    80003342:	fef059e3          	blez	a5,80003334 <iget+0x34>
    80003346:	4098                	lw	a4,0(s1)
    80003348:	ff3716e3          	bne	a4,s3,80003334 <iget+0x34>
    8000334c:	40d8                	lw	a4,4(s1)
    8000334e:	ff4713e3          	bne	a4,s4,80003334 <iget+0x34>
      ip->ref++;
    80003352:	2785                	addiw	a5,a5,1
    80003354:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003356:	0001d517          	auipc	a0,0x1d
    8000335a:	78250513          	addi	a0,a0,1922 # 80020ad8 <itable>
    8000335e:	963fd0ef          	jal	80000cc0 <release>
      return ip;
    80003362:	8926                	mv	s2,s1
    80003364:	a02d                	j	8000338e <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003366:	fbe9                	bnez	a5,80003338 <iget+0x38>
      empty = ip;
    80003368:	8926                	mv	s2,s1
    8000336a:	b7f9                	j	80003338 <iget+0x38>
  if(empty == 0)
    8000336c:	02090a63          	beqz	s2,800033a0 <iget+0xa0>
  ip->dev = dev;
    80003370:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003374:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003378:	4785                	li	a5,1
    8000337a:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000337e:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003382:	0001d517          	auipc	a0,0x1d
    80003386:	75650513          	addi	a0,a0,1878 # 80020ad8 <itable>
    8000338a:	937fd0ef          	jal	80000cc0 <release>
}
    8000338e:	854a                	mv	a0,s2
    80003390:	70a2                	ld	ra,40(sp)
    80003392:	7402                	ld	s0,32(sp)
    80003394:	64e2                	ld	s1,24(sp)
    80003396:	6942                	ld	s2,16(sp)
    80003398:	69a2                	ld	s3,8(sp)
    8000339a:	6a02                	ld	s4,0(sp)
    8000339c:	6145                	addi	sp,sp,48
    8000339e:	8082                	ret
    panic("iget: no inodes");
    800033a0:	00004517          	auipc	a0,0x4
    800033a4:	12850513          	addi	a0,a0,296 # 800074c8 <etext+0x4c8>
    800033a8:	c20fd0ef          	jal	800007c8 <panic>

00000000800033ac <fsinit>:
fsinit(int dev) {
    800033ac:	7179                	addi	sp,sp,-48
    800033ae:	f406                	sd	ra,40(sp)
    800033b0:	f022                	sd	s0,32(sp)
    800033b2:	ec26                	sd	s1,24(sp)
    800033b4:	e84a                	sd	s2,16(sp)
    800033b6:	e44e                	sd	s3,8(sp)
    800033b8:	1800                	addi	s0,sp,48
    800033ba:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800033bc:	4585                	li	a1,1
    800033be:	aebff0ef          	jal	80002ea8 <bread>
    800033c2:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800033c4:	0001d997          	auipc	s3,0x1d
    800033c8:	6f498993          	addi	s3,s3,1780 # 80020ab8 <sb>
    800033cc:	02000613          	li	a2,32
    800033d0:	05850593          	addi	a1,a0,88
    800033d4:	854e                	mv	a0,s3
    800033d6:	983fd0ef          	jal	80000d58 <memmove>
  brelse(bp);
    800033da:	8526                	mv	a0,s1
    800033dc:	bd5ff0ef          	jal	80002fb0 <brelse>
  if(sb.magic != FSMAGIC)
    800033e0:	0009a703          	lw	a4,0(s3)
    800033e4:	102037b7          	lui	a5,0x10203
    800033e8:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800033ec:	02f71063          	bne	a4,a5,8000340c <fsinit+0x60>
  initlog(dev, &sb);
    800033f0:	0001d597          	auipc	a1,0x1d
    800033f4:	6c858593          	addi	a1,a1,1736 # 80020ab8 <sb>
    800033f8:	854a                	mv	a0,s2
    800033fa:	1f9000ef          	jal	80003df2 <initlog>
}
    800033fe:	70a2                	ld	ra,40(sp)
    80003400:	7402                	ld	s0,32(sp)
    80003402:	64e2                	ld	s1,24(sp)
    80003404:	6942                	ld	s2,16(sp)
    80003406:	69a2                	ld	s3,8(sp)
    80003408:	6145                	addi	sp,sp,48
    8000340a:	8082                	ret
    panic("invalid file system");
    8000340c:	00004517          	auipc	a0,0x4
    80003410:	0cc50513          	addi	a0,a0,204 # 800074d8 <etext+0x4d8>
    80003414:	bb4fd0ef          	jal	800007c8 <panic>

0000000080003418 <iinit>:
{
    80003418:	7179                	addi	sp,sp,-48
    8000341a:	f406                	sd	ra,40(sp)
    8000341c:	f022                	sd	s0,32(sp)
    8000341e:	ec26                	sd	s1,24(sp)
    80003420:	e84a                	sd	s2,16(sp)
    80003422:	e44e                	sd	s3,8(sp)
    80003424:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003426:	00004597          	auipc	a1,0x4
    8000342a:	0ca58593          	addi	a1,a1,202 # 800074f0 <etext+0x4f0>
    8000342e:	0001d517          	auipc	a0,0x1d
    80003432:	6aa50513          	addi	a0,a0,1706 # 80020ad8 <itable>
    80003436:	f72fd0ef          	jal	80000ba8 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000343a:	0001d497          	auipc	s1,0x1d
    8000343e:	6c648493          	addi	s1,s1,1734 # 80020b00 <itable+0x28>
    80003442:	0001f997          	auipc	s3,0x1f
    80003446:	14e98993          	addi	s3,s3,334 # 80022590 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000344a:	00004917          	auipc	s2,0x4
    8000344e:	0ae90913          	addi	s2,s2,174 # 800074f8 <etext+0x4f8>
    80003452:	85ca                	mv	a1,s2
    80003454:	8526                	mv	a0,s1
    80003456:	475000ef          	jal	800040ca <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000345a:	08848493          	addi	s1,s1,136
    8000345e:	ff349ae3          	bne	s1,s3,80003452 <iinit+0x3a>
}
    80003462:	70a2                	ld	ra,40(sp)
    80003464:	7402                	ld	s0,32(sp)
    80003466:	64e2                	ld	s1,24(sp)
    80003468:	6942                	ld	s2,16(sp)
    8000346a:	69a2                	ld	s3,8(sp)
    8000346c:	6145                	addi	sp,sp,48
    8000346e:	8082                	ret

0000000080003470 <ialloc>:
{
    80003470:	7139                	addi	sp,sp,-64
    80003472:	fc06                	sd	ra,56(sp)
    80003474:	f822                	sd	s0,48(sp)
    80003476:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003478:	0001d717          	auipc	a4,0x1d
    8000347c:	64c72703          	lw	a4,1612(a4) # 80020ac4 <sb+0xc>
    80003480:	4785                	li	a5,1
    80003482:	06e7f063          	bgeu	a5,a4,800034e2 <ialloc+0x72>
    80003486:	f426                	sd	s1,40(sp)
    80003488:	f04a                	sd	s2,32(sp)
    8000348a:	ec4e                	sd	s3,24(sp)
    8000348c:	e852                	sd	s4,16(sp)
    8000348e:	e456                	sd	s5,8(sp)
    80003490:	e05a                	sd	s6,0(sp)
    80003492:	8aaa                	mv	s5,a0
    80003494:	8b2e                	mv	s6,a1
    80003496:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003498:	0001da17          	auipc	s4,0x1d
    8000349c:	620a0a13          	addi	s4,s4,1568 # 80020ab8 <sb>
    800034a0:	00495593          	srli	a1,s2,0x4
    800034a4:	018a2783          	lw	a5,24(s4)
    800034a8:	9dbd                	addw	a1,a1,a5
    800034aa:	8556                	mv	a0,s5
    800034ac:	9fdff0ef          	jal	80002ea8 <bread>
    800034b0:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800034b2:	05850993          	addi	s3,a0,88
    800034b6:	00f97793          	andi	a5,s2,15
    800034ba:	079a                	slli	a5,a5,0x6
    800034bc:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800034be:	00099783          	lh	a5,0(s3)
    800034c2:	cb9d                	beqz	a5,800034f8 <ialloc+0x88>
    brelse(bp);
    800034c4:	aedff0ef          	jal	80002fb0 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800034c8:	0905                	addi	s2,s2,1
    800034ca:	00ca2703          	lw	a4,12(s4)
    800034ce:	0009079b          	sext.w	a5,s2
    800034d2:	fce7e7e3          	bltu	a5,a4,800034a0 <ialloc+0x30>
    800034d6:	74a2                	ld	s1,40(sp)
    800034d8:	7902                	ld	s2,32(sp)
    800034da:	69e2                	ld	s3,24(sp)
    800034dc:	6a42                	ld	s4,16(sp)
    800034de:	6aa2                	ld	s5,8(sp)
    800034e0:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800034e2:	00004517          	auipc	a0,0x4
    800034e6:	01e50513          	addi	a0,a0,30 # 80007500 <etext+0x500>
    800034ea:	80cfd0ef          	jal	800004f6 <printf>
  return 0;
    800034ee:	4501                	li	a0,0
}
    800034f0:	70e2                	ld	ra,56(sp)
    800034f2:	7442                	ld	s0,48(sp)
    800034f4:	6121                	addi	sp,sp,64
    800034f6:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800034f8:	04000613          	li	a2,64
    800034fc:	4581                	li	a1,0
    800034fe:	854e                	mv	a0,s3
    80003500:	ffcfd0ef          	jal	80000cfc <memset>
      dip->type = type;
    80003504:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003508:	8526                	mv	a0,s1
    8000350a:	2f1000ef          	jal	80003ffa <log_write>
      brelse(bp);
    8000350e:	8526                	mv	a0,s1
    80003510:	aa1ff0ef          	jal	80002fb0 <brelse>
      return iget(dev, inum);
    80003514:	0009059b          	sext.w	a1,s2
    80003518:	8556                	mv	a0,s5
    8000351a:	de7ff0ef          	jal	80003300 <iget>
    8000351e:	74a2                	ld	s1,40(sp)
    80003520:	7902                	ld	s2,32(sp)
    80003522:	69e2                	ld	s3,24(sp)
    80003524:	6a42                	ld	s4,16(sp)
    80003526:	6aa2                	ld	s5,8(sp)
    80003528:	6b02                	ld	s6,0(sp)
    8000352a:	b7d9                	j	800034f0 <ialloc+0x80>

000000008000352c <iupdate>:
{
    8000352c:	1101                	addi	sp,sp,-32
    8000352e:	ec06                	sd	ra,24(sp)
    80003530:	e822                	sd	s0,16(sp)
    80003532:	e426                	sd	s1,8(sp)
    80003534:	e04a                	sd	s2,0(sp)
    80003536:	1000                	addi	s0,sp,32
    80003538:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000353a:	415c                	lw	a5,4(a0)
    8000353c:	0047d79b          	srliw	a5,a5,0x4
    80003540:	0001d597          	auipc	a1,0x1d
    80003544:	5905a583          	lw	a1,1424(a1) # 80020ad0 <sb+0x18>
    80003548:	9dbd                	addw	a1,a1,a5
    8000354a:	4108                	lw	a0,0(a0)
    8000354c:	95dff0ef          	jal	80002ea8 <bread>
    80003550:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003552:	05850793          	addi	a5,a0,88
    80003556:	40d8                	lw	a4,4(s1)
    80003558:	8b3d                	andi	a4,a4,15
    8000355a:	071a                	slli	a4,a4,0x6
    8000355c:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000355e:	04449703          	lh	a4,68(s1)
    80003562:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003566:	04649703          	lh	a4,70(s1)
    8000356a:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000356e:	04849703          	lh	a4,72(s1)
    80003572:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003576:	04a49703          	lh	a4,74(s1)
    8000357a:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000357e:	44f8                	lw	a4,76(s1)
    80003580:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003582:	03400613          	li	a2,52
    80003586:	05048593          	addi	a1,s1,80
    8000358a:	00c78513          	addi	a0,a5,12
    8000358e:	fcafd0ef          	jal	80000d58 <memmove>
  log_write(bp);
    80003592:	854a                	mv	a0,s2
    80003594:	267000ef          	jal	80003ffa <log_write>
  brelse(bp);
    80003598:	854a                	mv	a0,s2
    8000359a:	a17ff0ef          	jal	80002fb0 <brelse>
}
    8000359e:	60e2                	ld	ra,24(sp)
    800035a0:	6442                	ld	s0,16(sp)
    800035a2:	64a2                	ld	s1,8(sp)
    800035a4:	6902                	ld	s2,0(sp)
    800035a6:	6105                	addi	sp,sp,32
    800035a8:	8082                	ret

00000000800035aa <idup>:
{
    800035aa:	1101                	addi	sp,sp,-32
    800035ac:	ec06                	sd	ra,24(sp)
    800035ae:	e822                	sd	s0,16(sp)
    800035b0:	e426                	sd	s1,8(sp)
    800035b2:	1000                	addi	s0,sp,32
    800035b4:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800035b6:	0001d517          	auipc	a0,0x1d
    800035ba:	52250513          	addi	a0,a0,1314 # 80020ad8 <itable>
    800035be:	e6afd0ef          	jal	80000c28 <acquire>
  ip->ref++;
    800035c2:	449c                	lw	a5,8(s1)
    800035c4:	2785                	addiw	a5,a5,1
    800035c6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800035c8:	0001d517          	auipc	a0,0x1d
    800035cc:	51050513          	addi	a0,a0,1296 # 80020ad8 <itable>
    800035d0:	ef0fd0ef          	jal	80000cc0 <release>
}
    800035d4:	8526                	mv	a0,s1
    800035d6:	60e2                	ld	ra,24(sp)
    800035d8:	6442                	ld	s0,16(sp)
    800035da:	64a2                	ld	s1,8(sp)
    800035dc:	6105                	addi	sp,sp,32
    800035de:	8082                	ret

00000000800035e0 <ilock>:
{
    800035e0:	1101                	addi	sp,sp,-32
    800035e2:	ec06                	sd	ra,24(sp)
    800035e4:	e822                	sd	s0,16(sp)
    800035e6:	e426                	sd	s1,8(sp)
    800035e8:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800035ea:	cd19                	beqz	a0,80003608 <ilock+0x28>
    800035ec:	84aa                	mv	s1,a0
    800035ee:	451c                	lw	a5,8(a0)
    800035f0:	00f05c63          	blez	a5,80003608 <ilock+0x28>
  acquiresleep(&ip->lock);
    800035f4:	0541                	addi	a0,a0,16
    800035f6:	30b000ef          	jal	80004100 <acquiresleep>
  if(ip->valid == 0){
    800035fa:	40bc                	lw	a5,64(s1)
    800035fc:	cf89                	beqz	a5,80003616 <ilock+0x36>
}
    800035fe:	60e2                	ld	ra,24(sp)
    80003600:	6442                	ld	s0,16(sp)
    80003602:	64a2                	ld	s1,8(sp)
    80003604:	6105                	addi	sp,sp,32
    80003606:	8082                	ret
    80003608:	e04a                	sd	s2,0(sp)
    panic("ilock");
    8000360a:	00004517          	auipc	a0,0x4
    8000360e:	f0e50513          	addi	a0,a0,-242 # 80007518 <etext+0x518>
    80003612:	9b6fd0ef          	jal	800007c8 <panic>
    80003616:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003618:	40dc                	lw	a5,4(s1)
    8000361a:	0047d79b          	srliw	a5,a5,0x4
    8000361e:	0001d597          	auipc	a1,0x1d
    80003622:	4b25a583          	lw	a1,1202(a1) # 80020ad0 <sb+0x18>
    80003626:	9dbd                	addw	a1,a1,a5
    80003628:	4088                	lw	a0,0(s1)
    8000362a:	87fff0ef          	jal	80002ea8 <bread>
    8000362e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003630:	05850593          	addi	a1,a0,88
    80003634:	40dc                	lw	a5,4(s1)
    80003636:	8bbd                	andi	a5,a5,15
    80003638:	079a                	slli	a5,a5,0x6
    8000363a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000363c:	00059783          	lh	a5,0(a1)
    80003640:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003644:	00259783          	lh	a5,2(a1)
    80003648:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000364c:	00459783          	lh	a5,4(a1)
    80003650:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003654:	00659783          	lh	a5,6(a1)
    80003658:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000365c:	459c                	lw	a5,8(a1)
    8000365e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003660:	03400613          	li	a2,52
    80003664:	05b1                	addi	a1,a1,12
    80003666:	05048513          	addi	a0,s1,80
    8000366a:	eeefd0ef          	jal	80000d58 <memmove>
    brelse(bp);
    8000366e:	854a                	mv	a0,s2
    80003670:	941ff0ef          	jal	80002fb0 <brelse>
    ip->valid = 1;
    80003674:	4785                	li	a5,1
    80003676:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003678:	04449783          	lh	a5,68(s1)
    8000367c:	c399                	beqz	a5,80003682 <ilock+0xa2>
    8000367e:	6902                	ld	s2,0(sp)
    80003680:	bfbd                	j	800035fe <ilock+0x1e>
      panic("ilock: no type");
    80003682:	00004517          	auipc	a0,0x4
    80003686:	e9e50513          	addi	a0,a0,-354 # 80007520 <etext+0x520>
    8000368a:	93efd0ef          	jal	800007c8 <panic>

000000008000368e <iunlock>:
{
    8000368e:	1101                	addi	sp,sp,-32
    80003690:	ec06                	sd	ra,24(sp)
    80003692:	e822                	sd	s0,16(sp)
    80003694:	e426                	sd	s1,8(sp)
    80003696:	e04a                	sd	s2,0(sp)
    80003698:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000369a:	c505                	beqz	a0,800036c2 <iunlock+0x34>
    8000369c:	84aa                	mv	s1,a0
    8000369e:	01050913          	addi	s2,a0,16
    800036a2:	854a                	mv	a0,s2
    800036a4:	2db000ef          	jal	8000417e <holdingsleep>
    800036a8:	cd09                	beqz	a0,800036c2 <iunlock+0x34>
    800036aa:	449c                	lw	a5,8(s1)
    800036ac:	00f05b63          	blez	a5,800036c2 <iunlock+0x34>
  releasesleep(&ip->lock);
    800036b0:	854a                	mv	a0,s2
    800036b2:	295000ef          	jal	80004146 <releasesleep>
}
    800036b6:	60e2                	ld	ra,24(sp)
    800036b8:	6442                	ld	s0,16(sp)
    800036ba:	64a2                	ld	s1,8(sp)
    800036bc:	6902                	ld	s2,0(sp)
    800036be:	6105                	addi	sp,sp,32
    800036c0:	8082                	ret
    panic("iunlock");
    800036c2:	00004517          	auipc	a0,0x4
    800036c6:	e6e50513          	addi	a0,a0,-402 # 80007530 <etext+0x530>
    800036ca:	8fefd0ef          	jal	800007c8 <panic>

00000000800036ce <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800036ce:	7179                	addi	sp,sp,-48
    800036d0:	f406                	sd	ra,40(sp)
    800036d2:	f022                	sd	s0,32(sp)
    800036d4:	ec26                	sd	s1,24(sp)
    800036d6:	e84a                	sd	s2,16(sp)
    800036d8:	e44e                	sd	s3,8(sp)
    800036da:	1800                	addi	s0,sp,48
    800036dc:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800036de:	05050493          	addi	s1,a0,80
    800036e2:	08050913          	addi	s2,a0,128
    800036e6:	a021                	j	800036ee <itrunc+0x20>
    800036e8:	0491                	addi	s1,s1,4
    800036ea:	01248b63          	beq	s1,s2,80003700 <itrunc+0x32>
    if(ip->addrs[i]){
    800036ee:	408c                	lw	a1,0(s1)
    800036f0:	dde5                	beqz	a1,800036e8 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800036f2:	0009a503          	lw	a0,0(s3)
    800036f6:	9abff0ef          	jal	800030a0 <bfree>
      ip->addrs[i] = 0;
    800036fa:	0004a023          	sw	zero,0(s1)
    800036fe:	b7ed                	j	800036e8 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003700:	0809a583          	lw	a1,128(s3)
    80003704:	ed89                	bnez	a1,8000371e <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003706:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000370a:	854e                	mv	a0,s3
    8000370c:	e21ff0ef          	jal	8000352c <iupdate>
}
    80003710:	70a2                	ld	ra,40(sp)
    80003712:	7402                	ld	s0,32(sp)
    80003714:	64e2                	ld	s1,24(sp)
    80003716:	6942                	ld	s2,16(sp)
    80003718:	69a2                	ld	s3,8(sp)
    8000371a:	6145                	addi	sp,sp,48
    8000371c:	8082                	ret
    8000371e:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003720:	0009a503          	lw	a0,0(s3)
    80003724:	f84ff0ef          	jal	80002ea8 <bread>
    80003728:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000372a:	05850493          	addi	s1,a0,88
    8000372e:	45850913          	addi	s2,a0,1112
    80003732:	a021                	j	8000373a <itrunc+0x6c>
    80003734:	0491                	addi	s1,s1,4
    80003736:	01248963          	beq	s1,s2,80003748 <itrunc+0x7a>
      if(a[j])
    8000373a:	408c                	lw	a1,0(s1)
    8000373c:	dde5                	beqz	a1,80003734 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    8000373e:	0009a503          	lw	a0,0(s3)
    80003742:	95fff0ef          	jal	800030a0 <bfree>
    80003746:	b7fd                	j	80003734 <itrunc+0x66>
    brelse(bp);
    80003748:	8552                	mv	a0,s4
    8000374a:	867ff0ef          	jal	80002fb0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000374e:	0809a583          	lw	a1,128(s3)
    80003752:	0009a503          	lw	a0,0(s3)
    80003756:	94bff0ef          	jal	800030a0 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000375a:	0809a023          	sw	zero,128(s3)
    8000375e:	6a02                	ld	s4,0(sp)
    80003760:	b75d                	j	80003706 <itrunc+0x38>

0000000080003762 <iput>:
{
    80003762:	1101                	addi	sp,sp,-32
    80003764:	ec06                	sd	ra,24(sp)
    80003766:	e822                	sd	s0,16(sp)
    80003768:	e426                	sd	s1,8(sp)
    8000376a:	1000                	addi	s0,sp,32
    8000376c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000376e:	0001d517          	auipc	a0,0x1d
    80003772:	36a50513          	addi	a0,a0,874 # 80020ad8 <itable>
    80003776:	cb2fd0ef          	jal	80000c28 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000377a:	4498                	lw	a4,8(s1)
    8000377c:	4785                	li	a5,1
    8000377e:	02f70063          	beq	a4,a5,8000379e <iput+0x3c>
  ip->ref--;
    80003782:	449c                	lw	a5,8(s1)
    80003784:	37fd                	addiw	a5,a5,-1
    80003786:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003788:	0001d517          	auipc	a0,0x1d
    8000378c:	35050513          	addi	a0,a0,848 # 80020ad8 <itable>
    80003790:	d30fd0ef          	jal	80000cc0 <release>
}
    80003794:	60e2                	ld	ra,24(sp)
    80003796:	6442                	ld	s0,16(sp)
    80003798:	64a2                	ld	s1,8(sp)
    8000379a:	6105                	addi	sp,sp,32
    8000379c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000379e:	40bc                	lw	a5,64(s1)
    800037a0:	d3ed                	beqz	a5,80003782 <iput+0x20>
    800037a2:	04a49783          	lh	a5,74(s1)
    800037a6:	fff1                	bnez	a5,80003782 <iput+0x20>
    800037a8:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800037aa:	01048913          	addi	s2,s1,16
    800037ae:	854a                	mv	a0,s2
    800037b0:	151000ef          	jal	80004100 <acquiresleep>
    release(&itable.lock);
    800037b4:	0001d517          	auipc	a0,0x1d
    800037b8:	32450513          	addi	a0,a0,804 # 80020ad8 <itable>
    800037bc:	d04fd0ef          	jal	80000cc0 <release>
    itrunc(ip);
    800037c0:	8526                	mv	a0,s1
    800037c2:	f0dff0ef          	jal	800036ce <itrunc>
    ip->type = 0;
    800037c6:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800037ca:	8526                	mv	a0,s1
    800037cc:	d61ff0ef          	jal	8000352c <iupdate>
    ip->valid = 0;
    800037d0:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800037d4:	854a                	mv	a0,s2
    800037d6:	171000ef          	jal	80004146 <releasesleep>
    acquire(&itable.lock);
    800037da:	0001d517          	auipc	a0,0x1d
    800037de:	2fe50513          	addi	a0,a0,766 # 80020ad8 <itable>
    800037e2:	c46fd0ef          	jal	80000c28 <acquire>
    800037e6:	6902                	ld	s2,0(sp)
    800037e8:	bf69                	j	80003782 <iput+0x20>

00000000800037ea <iunlockput>:
{
    800037ea:	1101                	addi	sp,sp,-32
    800037ec:	ec06                	sd	ra,24(sp)
    800037ee:	e822                	sd	s0,16(sp)
    800037f0:	e426                	sd	s1,8(sp)
    800037f2:	1000                	addi	s0,sp,32
    800037f4:	84aa                	mv	s1,a0
  iunlock(ip);
    800037f6:	e99ff0ef          	jal	8000368e <iunlock>
  iput(ip);
    800037fa:	8526                	mv	a0,s1
    800037fc:	f67ff0ef          	jal	80003762 <iput>
}
    80003800:	60e2                	ld	ra,24(sp)
    80003802:	6442                	ld	s0,16(sp)
    80003804:	64a2                	ld	s1,8(sp)
    80003806:	6105                	addi	sp,sp,32
    80003808:	8082                	ret

000000008000380a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000380a:	1141                	addi	sp,sp,-16
    8000380c:	e422                	sd	s0,8(sp)
    8000380e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003810:	411c                	lw	a5,0(a0)
    80003812:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003814:	415c                	lw	a5,4(a0)
    80003816:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003818:	04451783          	lh	a5,68(a0)
    8000381c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003820:	04a51783          	lh	a5,74(a0)
    80003824:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003828:	04c56783          	lwu	a5,76(a0)
    8000382c:	e99c                	sd	a5,16(a1)
}
    8000382e:	6422                	ld	s0,8(sp)
    80003830:	0141                	addi	sp,sp,16
    80003832:	8082                	ret

0000000080003834 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003834:	457c                	lw	a5,76(a0)
    80003836:	0ed7eb63          	bltu	a5,a3,8000392c <readi+0xf8>
{
    8000383a:	7159                	addi	sp,sp,-112
    8000383c:	f486                	sd	ra,104(sp)
    8000383e:	f0a2                	sd	s0,96(sp)
    80003840:	eca6                	sd	s1,88(sp)
    80003842:	e0d2                	sd	s4,64(sp)
    80003844:	fc56                	sd	s5,56(sp)
    80003846:	f85a                	sd	s6,48(sp)
    80003848:	f45e                	sd	s7,40(sp)
    8000384a:	1880                	addi	s0,sp,112
    8000384c:	8b2a                	mv	s6,a0
    8000384e:	8bae                	mv	s7,a1
    80003850:	8a32                	mv	s4,a2
    80003852:	84b6                	mv	s1,a3
    80003854:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003856:	9f35                	addw	a4,a4,a3
    return 0;
    80003858:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000385a:	0cd76063          	bltu	a4,a3,8000391a <readi+0xe6>
    8000385e:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003860:	00e7f463          	bgeu	a5,a4,80003868 <readi+0x34>
    n = ip->size - off;
    80003864:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003868:	080a8f63          	beqz	s5,80003906 <readi+0xd2>
    8000386c:	e8ca                	sd	s2,80(sp)
    8000386e:	f062                	sd	s8,32(sp)
    80003870:	ec66                	sd	s9,24(sp)
    80003872:	e86a                	sd	s10,16(sp)
    80003874:	e46e                	sd	s11,8(sp)
    80003876:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003878:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000387c:	5c7d                	li	s8,-1
    8000387e:	a80d                	j	800038b0 <readi+0x7c>
    80003880:	020d1d93          	slli	s11,s10,0x20
    80003884:	020ddd93          	srli	s11,s11,0x20
    80003888:	05890613          	addi	a2,s2,88
    8000388c:	86ee                	mv	a3,s11
    8000388e:	963a                	add	a2,a2,a4
    80003890:	85d2                	mv	a1,s4
    80003892:	855e                	mv	a0,s7
    80003894:	9abfe0ef          	jal	8000223e <either_copyout>
    80003898:	05850763          	beq	a0,s8,800038e6 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000389c:	854a                	mv	a0,s2
    8000389e:	f12ff0ef          	jal	80002fb0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800038a2:	013d09bb          	addw	s3,s10,s3
    800038a6:	009d04bb          	addw	s1,s10,s1
    800038aa:	9a6e                	add	s4,s4,s11
    800038ac:	0559f763          	bgeu	s3,s5,800038fa <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    800038b0:	00a4d59b          	srliw	a1,s1,0xa
    800038b4:	855a                	mv	a0,s6
    800038b6:	977ff0ef          	jal	8000322c <bmap>
    800038ba:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800038be:	c5b1                	beqz	a1,8000390a <readi+0xd6>
    bp = bread(ip->dev, addr);
    800038c0:	000b2503          	lw	a0,0(s6)
    800038c4:	de4ff0ef          	jal	80002ea8 <bread>
    800038c8:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800038ca:	3ff4f713          	andi	a4,s1,1023
    800038ce:	40ec87bb          	subw	a5,s9,a4
    800038d2:	413a86bb          	subw	a3,s5,s3
    800038d6:	8d3e                	mv	s10,a5
    800038d8:	2781                	sext.w	a5,a5
    800038da:	0006861b          	sext.w	a2,a3
    800038de:	faf671e3          	bgeu	a2,a5,80003880 <readi+0x4c>
    800038e2:	8d36                	mv	s10,a3
    800038e4:	bf71                	j	80003880 <readi+0x4c>
      brelse(bp);
    800038e6:	854a                	mv	a0,s2
    800038e8:	ec8ff0ef          	jal	80002fb0 <brelse>
      tot = -1;
    800038ec:	59fd                	li	s3,-1
      break;
    800038ee:	6946                	ld	s2,80(sp)
    800038f0:	7c02                	ld	s8,32(sp)
    800038f2:	6ce2                	ld	s9,24(sp)
    800038f4:	6d42                	ld	s10,16(sp)
    800038f6:	6da2                	ld	s11,8(sp)
    800038f8:	a831                	j	80003914 <readi+0xe0>
    800038fa:	6946                	ld	s2,80(sp)
    800038fc:	7c02                	ld	s8,32(sp)
    800038fe:	6ce2                	ld	s9,24(sp)
    80003900:	6d42                	ld	s10,16(sp)
    80003902:	6da2                	ld	s11,8(sp)
    80003904:	a801                	j	80003914 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003906:	89d6                	mv	s3,s5
    80003908:	a031                	j	80003914 <readi+0xe0>
    8000390a:	6946                	ld	s2,80(sp)
    8000390c:	7c02                	ld	s8,32(sp)
    8000390e:	6ce2                	ld	s9,24(sp)
    80003910:	6d42                	ld	s10,16(sp)
    80003912:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003914:	0009851b          	sext.w	a0,s3
    80003918:	69a6                	ld	s3,72(sp)
}
    8000391a:	70a6                	ld	ra,104(sp)
    8000391c:	7406                	ld	s0,96(sp)
    8000391e:	64e6                	ld	s1,88(sp)
    80003920:	6a06                	ld	s4,64(sp)
    80003922:	7ae2                	ld	s5,56(sp)
    80003924:	7b42                	ld	s6,48(sp)
    80003926:	7ba2                	ld	s7,40(sp)
    80003928:	6165                	addi	sp,sp,112
    8000392a:	8082                	ret
    return 0;
    8000392c:	4501                	li	a0,0
}
    8000392e:	8082                	ret

0000000080003930 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003930:	457c                	lw	a5,76(a0)
    80003932:	10d7e063          	bltu	a5,a3,80003a32 <writei+0x102>
{
    80003936:	7159                	addi	sp,sp,-112
    80003938:	f486                	sd	ra,104(sp)
    8000393a:	f0a2                	sd	s0,96(sp)
    8000393c:	e8ca                	sd	s2,80(sp)
    8000393e:	e0d2                	sd	s4,64(sp)
    80003940:	fc56                	sd	s5,56(sp)
    80003942:	f85a                	sd	s6,48(sp)
    80003944:	f45e                	sd	s7,40(sp)
    80003946:	1880                	addi	s0,sp,112
    80003948:	8aaa                	mv	s5,a0
    8000394a:	8bae                	mv	s7,a1
    8000394c:	8a32                	mv	s4,a2
    8000394e:	8936                	mv	s2,a3
    80003950:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003952:	00e687bb          	addw	a5,a3,a4
    80003956:	0ed7e063          	bltu	a5,a3,80003a36 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000395a:	00043737          	lui	a4,0x43
    8000395e:	0cf76e63          	bltu	a4,a5,80003a3a <writei+0x10a>
    80003962:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003964:	0a0b0f63          	beqz	s6,80003a22 <writei+0xf2>
    80003968:	eca6                	sd	s1,88(sp)
    8000396a:	f062                	sd	s8,32(sp)
    8000396c:	ec66                	sd	s9,24(sp)
    8000396e:	e86a                	sd	s10,16(sp)
    80003970:	e46e                	sd	s11,8(sp)
    80003972:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003974:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003978:	5c7d                	li	s8,-1
    8000397a:	a825                	j	800039b2 <writei+0x82>
    8000397c:	020d1d93          	slli	s11,s10,0x20
    80003980:	020ddd93          	srli	s11,s11,0x20
    80003984:	05848513          	addi	a0,s1,88
    80003988:	86ee                	mv	a3,s11
    8000398a:	8652                	mv	a2,s4
    8000398c:	85de                	mv	a1,s7
    8000398e:	953a                	add	a0,a0,a4
    80003990:	8f9fe0ef          	jal	80002288 <either_copyin>
    80003994:	05850a63          	beq	a0,s8,800039e8 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003998:	8526                	mv	a0,s1
    8000399a:	660000ef          	jal	80003ffa <log_write>
    brelse(bp);
    8000399e:	8526                	mv	a0,s1
    800039a0:	e10ff0ef          	jal	80002fb0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800039a4:	013d09bb          	addw	s3,s10,s3
    800039a8:	012d093b          	addw	s2,s10,s2
    800039ac:	9a6e                	add	s4,s4,s11
    800039ae:	0569f063          	bgeu	s3,s6,800039ee <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800039b2:	00a9559b          	srliw	a1,s2,0xa
    800039b6:	8556                	mv	a0,s5
    800039b8:	875ff0ef          	jal	8000322c <bmap>
    800039bc:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800039c0:	c59d                	beqz	a1,800039ee <writei+0xbe>
    bp = bread(ip->dev, addr);
    800039c2:	000aa503          	lw	a0,0(s5)
    800039c6:	ce2ff0ef          	jal	80002ea8 <bread>
    800039ca:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800039cc:	3ff97713          	andi	a4,s2,1023
    800039d0:	40ec87bb          	subw	a5,s9,a4
    800039d4:	413b06bb          	subw	a3,s6,s3
    800039d8:	8d3e                	mv	s10,a5
    800039da:	2781                	sext.w	a5,a5
    800039dc:	0006861b          	sext.w	a2,a3
    800039e0:	f8f67ee3          	bgeu	a2,a5,8000397c <writei+0x4c>
    800039e4:	8d36                	mv	s10,a3
    800039e6:	bf59                	j	8000397c <writei+0x4c>
      brelse(bp);
    800039e8:	8526                	mv	a0,s1
    800039ea:	dc6ff0ef          	jal	80002fb0 <brelse>
  }

  if(off > ip->size)
    800039ee:	04caa783          	lw	a5,76(s5)
    800039f2:	0327fa63          	bgeu	a5,s2,80003a26 <writei+0xf6>
    ip->size = off;
    800039f6:	052aa623          	sw	s2,76(s5)
    800039fa:	64e6                	ld	s1,88(sp)
    800039fc:	7c02                	ld	s8,32(sp)
    800039fe:	6ce2                	ld	s9,24(sp)
    80003a00:	6d42                	ld	s10,16(sp)
    80003a02:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003a04:	8556                	mv	a0,s5
    80003a06:	b27ff0ef          	jal	8000352c <iupdate>

  return tot;
    80003a0a:	0009851b          	sext.w	a0,s3
    80003a0e:	69a6                	ld	s3,72(sp)
}
    80003a10:	70a6                	ld	ra,104(sp)
    80003a12:	7406                	ld	s0,96(sp)
    80003a14:	6946                	ld	s2,80(sp)
    80003a16:	6a06                	ld	s4,64(sp)
    80003a18:	7ae2                	ld	s5,56(sp)
    80003a1a:	7b42                	ld	s6,48(sp)
    80003a1c:	7ba2                	ld	s7,40(sp)
    80003a1e:	6165                	addi	sp,sp,112
    80003a20:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a22:	89da                	mv	s3,s6
    80003a24:	b7c5                	j	80003a04 <writei+0xd4>
    80003a26:	64e6                	ld	s1,88(sp)
    80003a28:	7c02                	ld	s8,32(sp)
    80003a2a:	6ce2                	ld	s9,24(sp)
    80003a2c:	6d42                	ld	s10,16(sp)
    80003a2e:	6da2                	ld	s11,8(sp)
    80003a30:	bfd1                	j	80003a04 <writei+0xd4>
    return -1;
    80003a32:	557d                	li	a0,-1
}
    80003a34:	8082                	ret
    return -1;
    80003a36:	557d                	li	a0,-1
    80003a38:	bfe1                	j	80003a10 <writei+0xe0>
    return -1;
    80003a3a:	557d                	li	a0,-1
    80003a3c:	bfd1                	j	80003a10 <writei+0xe0>

0000000080003a3e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003a3e:	1141                	addi	sp,sp,-16
    80003a40:	e406                	sd	ra,8(sp)
    80003a42:	e022                	sd	s0,0(sp)
    80003a44:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003a46:	4639                	li	a2,14
    80003a48:	b80fd0ef          	jal	80000dc8 <strncmp>
}
    80003a4c:	60a2                	ld	ra,8(sp)
    80003a4e:	6402                	ld	s0,0(sp)
    80003a50:	0141                	addi	sp,sp,16
    80003a52:	8082                	ret

0000000080003a54 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003a54:	7139                	addi	sp,sp,-64
    80003a56:	fc06                	sd	ra,56(sp)
    80003a58:	f822                	sd	s0,48(sp)
    80003a5a:	f426                	sd	s1,40(sp)
    80003a5c:	f04a                	sd	s2,32(sp)
    80003a5e:	ec4e                	sd	s3,24(sp)
    80003a60:	e852                	sd	s4,16(sp)
    80003a62:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003a64:	04451703          	lh	a4,68(a0)
    80003a68:	4785                	li	a5,1
    80003a6a:	00f71a63          	bne	a4,a5,80003a7e <dirlookup+0x2a>
    80003a6e:	892a                	mv	s2,a0
    80003a70:	89ae                	mv	s3,a1
    80003a72:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a74:	457c                	lw	a5,76(a0)
    80003a76:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003a78:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a7a:	e39d                	bnez	a5,80003aa0 <dirlookup+0x4c>
    80003a7c:	a095                	j	80003ae0 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003a7e:	00004517          	auipc	a0,0x4
    80003a82:	aba50513          	addi	a0,a0,-1350 # 80007538 <etext+0x538>
    80003a86:	d43fc0ef          	jal	800007c8 <panic>
      panic("dirlookup read");
    80003a8a:	00004517          	auipc	a0,0x4
    80003a8e:	ac650513          	addi	a0,a0,-1338 # 80007550 <etext+0x550>
    80003a92:	d37fc0ef          	jal	800007c8 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a96:	24c1                	addiw	s1,s1,16
    80003a98:	04c92783          	lw	a5,76(s2)
    80003a9c:	04f4f163          	bgeu	s1,a5,80003ade <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003aa0:	4741                	li	a4,16
    80003aa2:	86a6                	mv	a3,s1
    80003aa4:	fc040613          	addi	a2,s0,-64
    80003aa8:	4581                	li	a1,0
    80003aaa:	854a                	mv	a0,s2
    80003aac:	d89ff0ef          	jal	80003834 <readi>
    80003ab0:	47c1                	li	a5,16
    80003ab2:	fcf51ce3          	bne	a0,a5,80003a8a <dirlookup+0x36>
    if(de.inum == 0)
    80003ab6:	fc045783          	lhu	a5,-64(s0)
    80003aba:	dff1                	beqz	a5,80003a96 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003abc:	fc240593          	addi	a1,s0,-62
    80003ac0:	854e                	mv	a0,s3
    80003ac2:	f7dff0ef          	jal	80003a3e <namecmp>
    80003ac6:	f961                	bnez	a0,80003a96 <dirlookup+0x42>
      if(poff)
    80003ac8:	000a0463          	beqz	s4,80003ad0 <dirlookup+0x7c>
        *poff = off;
    80003acc:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003ad0:	fc045583          	lhu	a1,-64(s0)
    80003ad4:	00092503          	lw	a0,0(s2)
    80003ad8:	829ff0ef          	jal	80003300 <iget>
    80003adc:	a011                	j	80003ae0 <dirlookup+0x8c>
  return 0;
    80003ade:	4501                	li	a0,0
}
    80003ae0:	70e2                	ld	ra,56(sp)
    80003ae2:	7442                	ld	s0,48(sp)
    80003ae4:	74a2                	ld	s1,40(sp)
    80003ae6:	7902                	ld	s2,32(sp)
    80003ae8:	69e2                	ld	s3,24(sp)
    80003aea:	6a42                	ld	s4,16(sp)
    80003aec:	6121                	addi	sp,sp,64
    80003aee:	8082                	ret

0000000080003af0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003af0:	711d                	addi	sp,sp,-96
    80003af2:	ec86                	sd	ra,88(sp)
    80003af4:	e8a2                	sd	s0,80(sp)
    80003af6:	e4a6                	sd	s1,72(sp)
    80003af8:	e0ca                	sd	s2,64(sp)
    80003afa:	fc4e                	sd	s3,56(sp)
    80003afc:	f852                	sd	s4,48(sp)
    80003afe:	f456                	sd	s5,40(sp)
    80003b00:	f05a                	sd	s6,32(sp)
    80003b02:	ec5e                	sd	s7,24(sp)
    80003b04:	e862                	sd	s8,16(sp)
    80003b06:	e466                	sd	s9,8(sp)
    80003b08:	1080                	addi	s0,sp,96
    80003b0a:	84aa                	mv	s1,a0
    80003b0c:	8b2e                	mv	s6,a1
    80003b0e:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003b10:	00054703          	lbu	a4,0(a0)
    80003b14:	02f00793          	li	a5,47
    80003b18:	00f70e63          	beq	a4,a5,80003b34 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003b1c:	df9fd0ef          	jal	80001914 <myproc>
    80003b20:	15053503          	ld	a0,336(a0)
    80003b24:	a87ff0ef          	jal	800035aa <idup>
    80003b28:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003b2a:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003b2e:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003b30:	4b85                	li	s7,1
    80003b32:	a871                	j	80003bce <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80003b34:	4585                	li	a1,1
    80003b36:	4505                	li	a0,1
    80003b38:	fc8ff0ef          	jal	80003300 <iget>
    80003b3c:	8a2a                	mv	s4,a0
    80003b3e:	b7f5                	j	80003b2a <namex+0x3a>
      iunlockput(ip);
    80003b40:	8552                	mv	a0,s4
    80003b42:	ca9ff0ef          	jal	800037ea <iunlockput>
      return 0;
    80003b46:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003b48:	8552                	mv	a0,s4
    80003b4a:	60e6                	ld	ra,88(sp)
    80003b4c:	6446                	ld	s0,80(sp)
    80003b4e:	64a6                	ld	s1,72(sp)
    80003b50:	6906                	ld	s2,64(sp)
    80003b52:	79e2                	ld	s3,56(sp)
    80003b54:	7a42                	ld	s4,48(sp)
    80003b56:	7aa2                	ld	s5,40(sp)
    80003b58:	7b02                	ld	s6,32(sp)
    80003b5a:	6be2                	ld	s7,24(sp)
    80003b5c:	6c42                	ld	s8,16(sp)
    80003b5e:	6ca2                	ld	s9,8(sp)
    80003b60:	6125                	addi	sp,sp,96
    80003b62:	8082                	ret
      iunlock(ip);
    80003b64:	8552                	mv	a0,s4
    80003b66:	b29ff0ef          	jal	8000368e <iunlock>
      return ip;
    80003b6a:	bff9                	j	80003b48 <namex+0x58>
      iunlockput(ip);
    80003b6c:	8552                	mv	a0,s4
    80003b6e:	c7dff0ef          	jal	800037ea <iunlockput>
      return 0;
    80003b72:	8a4e                	mv	s4,s3
    80003b74:	bfd1                	j	80003b48 <namex+0x58>
  len = path - s;
    80003b76:	40998633          	sub	a2,s3,s1
    80003b7a:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003b7e:	099c5063          	bge	s8,s9,80003bfe <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80003b82:	4639                	li	a2,14
    80003b84:	85a6                	mv	a1,s1
    80003b86:	8556                	mv	a0,s5
    80003b88:	9d0fd0ef          	jal	80000d58 <memmove>
    80003b8c:	84ce                	mv	s1,s3
  while(*path == '/')
    80003b8e:	0004c783          	lbu	a5,0(s1)
    80003b92:	01279763          	bne	a5,s2,80003ba0 <namex+0xb0>
    path++;
    80003b96:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003b98:	0004c783          	lbu	a5,0(s1)
    80003b9c:	ff278de3          	beq	a5,s2,80003b96 <namex+0xa6>
    ilock(ip);
    80003ba0:	8552                	mv	a0,s4
    80003ba2:	a3fff0ef          	jal	800035e0 <ilock>
    if(ip->type != T_DIR){
    80003ba6:	044a1783          	lh	a5,68(s4)
    80003baa:	f9779be3          	bne	a5,s7,80003b40 <namex+0x50>
    if(nameiparent && *path == '\0'){
    80003bae:	000b0563          	beqz	s6,80003bb8 <namex+0xc8>
    80003bb2:	0004c783          	lbu	a5,0(s1)
    80003bb6:	d7dd                	beqz	a5,80003b64 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003bb8:	4601                	li	a2,0
    80003bba:	85d6                	mv	a1,s5
    80003bbc:	8552                	mv	a0,s4
    80003bbe:	e97ff0ef          	jal	80003a54 <dirlookup>
    80003bc2:	89aa                	mv	s3,a0
    80003bc4:	d545                	beqz	a0,80003b6c <namex+0x7c>
    iunlockput(ip);
    80003bc6:	8552                	mv	a0,s4
    80003bc8:	c23ff0ef          	jal	800037ea <iunlockput>
    ip = next;
    80003bcc:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003bce:	0004c783          	lbu	a5,0(s1)
    80003bd2:	01279763          	bne	a5,s2,80003be0 <namex+0xf0>
    path++;
    80003bd6:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003bd8:	0004c783          	lbu	a5,0(s1)
    80003bdc:	ff278de3          	beq	a5,s2,80003bd6 <namex+0xe6>
  if(*path == 0)
    80003be0:	cb8d                	beqz	a5,80003c12 <namex+0x122>
  while(*path != '/' && *path != 0)
    80003be2:	0004c783          	lbu	a5,0(s1)
    80003be6:	89a6                	mv	s3,s1
  len = path - s;
    80003be8:	4c81                	li	s9,0
    80003bea:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003bec:	01278963          	beq	a5,s2,80003bfe <namex+0x10e>
    80003bf0:	d3d9                	beqz	a5,80003b76 <namex+0x86>
    path++;
    80003bf2:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003bf4:	0009c783          	lbu	a5,0(s3)
    80003bf8:	ff279ce3          	bne	a5,s2,80003bf0 <namex+0x100>
    80003bfc:	bfad                	j	80003b76 <namex+0x86>
    memmove(name, s, len);
    80003bfe:	2601                	sext.w	a2,a2
    80003c00:	85a6                	mv	a1,s1
    80003c02:	8556                	mv	a0,s5
    80003c04:	954fd0ef          	jal	80000d58 <memmove>
    name[len] = 0;
    80003c08:	9cd6                	add	s9,s9,s5
    80003c0a:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003c0e:	84ce                	mv	s1,s3
    80003c10:	bfbd                	j	80003b8e <namex+0x9e>
  if(nameiparent){
    80003c12:	f20b0be3          	beqz	s6,80003b48 <namex+0x58>
    iput(ip);
    80003c16:	8552                	mv	a0,s4
    80003c18:	b4bff0ef          	jal	80003762 <iput>
    return 0;
    80003c1c:	4a01                	li	s4,0
    80003c1e:	b72d                	j	80003b48 <namex+0x58>

0000000080003c20 <dirlink>:
{
    80003c20:	7139                	addi	sp,sp,-64
    80003c22:	fc06                	sd	ra,56(sp)
    80003c24:	f822                	sd	s0,48(sp)
    80003c26:	f04a                	sd	s2,32(sp)
    80003c28:	ec4e                	sd	s3,24(sp)
    80003c2a:	e852                	sd	s4,16(sp)
    80003c2c:	0080                	addi	s0,sp,64
    80003c2e:	892a                	mv	s2,a0
    80003c30:	8a2e                	mv	s4,a1
    80003c32:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003c34:	4601                	li	a2,0
    80003c36:	e1fff0ef          	jal	80003a54 <dirlookup>
    80003c3a:	e535                	bnez	a0,80003ca6 <dirlink+0x86>
    80003c3c:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c3e:	04c92483          	lw	s1,76(s2)
    80003c42:	c48d                	beqz	s1,80003c6c <dirlink+0x4c>
    80003c44:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c46:	4741                	li	a4,16
    80003c48:	86a6                	mv	a3,s1
    80003c4a:	fc040613          	addi	a2,s0,-64
    80003c4e:	4581                	li	a1,0
    80003c50:	854a                	mv	a0,s2
    80003c52:	be3ff0ef          	jal	80003834 <readi>
    80003c56:	47c1                	li	a5,16
    80003c58:	04f51b63          	bne	a0,a5,80003cae <dirlink+0x8e>
    if(de.inum == 0)
    80003c5c:	fc045783          	lhu	a5,-64(s0)
    80003c60:	c791                	beqz	a5,80003c6c <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c62:	24c1                	addiw	s1,s1,16
    80003c64:	04c92783          	lw	a5,76(s2)
    80003c68:	fcf4efe3          	bltu	s1,a5,80003c46 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003c6c:	4639                	li	a2,14
    80003c6e:	85d2                	mv	a1,s4
    80003c70:	fc240513          	addi	a0,s0,-62
    80003c74:	98afd0ef          	jal	80000dfe <strncpy>
  de.inum = inum;
    80003c78:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c7c:	4741                	li	a4,16
    80003c7e:	86a6                	mv	a3,s1
    80003c80:	fc040613          	addi	a2,s0,-64
    80003c84:	4581                	li	a1,0
    80003c86:	854a                	mv	a0,s2
    80003c88:	ca9ff0ef          	jal	80003930 <writei>
    80003c8c:	1541                	addi	a0,a0,-16
    80003c8e:	00a03533          	snez	a0,a0
    80003c92:	40a00533          	neg	a0,a0
    80003c96:	74a2                	ld	s1,40(sp)
}
    80003c98:	70e2                	ld	ra,56(sp)
    80003c9a:	7442                	ld	s0,48(sp)
    80003c9c:	7902                	ld	s2,32(sp)
    80003c9e:	69e2                	ld	s3,24(sp)
    80003ca0:	6a42                	ld	s4,16(sp)
    80003ca2:	6121                	addi	sp,sp,64
    80003ca4:	8082                	ret
    iput(ip);
    80003ca6:	abdff0ef          	jal	80003762 <iput>
    return -1;
    80003caa:	557d                	li	a0,-1
    80003cac:	b7f5                	j	80003c98 <dirlink+0x78>
      panic("dirlink read");
    80003cae:	00004517          	auipc	a0,0x4
    80003cb2:	8b250513          	addi	a0,a0,-1870 # 80007560 <etext+0x560>
    80003cb6:	b13fc0ef          	jal	800007c8 <panic>

0000000080003cba <namei>:

struct inode*
namei(char *path)
{
    80003cba:	1101                	addi	sp,sp,-32
    80003cbc:	ec06                	sd	ra,24(sp)
    80003cbe:	e822                	sd	s0,16(sp)
    80003cc0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003cc2:	fe040613          	addi	a2,s0,-32
    80003cc6:	4581                	li	a1,0
    80003cc8:	e29ff0ef          	jal	80003af0 <namex>
}
    80003ccc:	60e2                	ld	ra,24(sp)
    80003cce:	6442                	ld	s0,16(sp)
    80003cd0:	6105                	addi	sp,sp,32
    80003cd2:	8082                	ret

0000000080003cd4 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003cd4:	1141                	addi	sp,sp,-16
    80003cd6:	e406                	sd	ra,8(sp)
    80003cd8:	e022                	sd	s0,0(sp)
    80003cda:	0800                	addi	s0,sp,16
    80003cdc:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003cde:	4585                	li	a1,1
    80003ce0:	e11ff0ef          	jal	80003af0 <namex>
}
    80003ce4:	60a2                	ld	ra,8(sp)
    80003ce6:	6402                	ld	s0,0(sp)
    80003ce8:	0141                	addi	sp,sp,16
    80003cea:	8082                	ret

0000000080003cec <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003cec:	1101                	addi	sp,sp,-32
    80003cee:	ec06                	sd	ra,24(sp)
    80003cf0:	e822                	sd	s0,16(sp)
    80003cf2:	e426                	sd	s1,8(sp)
    80003cf4:	e04a                	sd	s2,0(sp)
    80003cf6:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003cf8:	0001f917          	auipc	s2,0x1f
    80003cfc:	88890913          	addi	s2,s2,-1912 # 80022580 <log>
    80003d00:	01892583          	lw	a1,24(s2)
    80003d04:	02892503          	lw	a0,40(s2)
    80003d08:	9a0ff0ef          	jal	80002ea8 <bread>
    80003d0c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003d0e:	02c92603          	lw	a2,44(s2)
    80003d12:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003d14:	00c05f63          	blez	a2,80003d32 <write_head+0x46>
    80003d18:	0001f717          	auipc	a4,0x1f
    80003d1c:	89870713          	addi	a4,a4,-1896 # 800225b0 <log+0x30>
    80003d20:	87aa                	mv	a5,a0
    80003d22:	060a                	slli	a2,a2,0x2
    80003d24:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003d26:	4314                	lw	a3,0(a4)
    80003d28:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003d2a:	0711                	addi	a4,a4,4
    80003d2c:	0791                	addi	a5,a5,4
    80003d2e:	fec79ce3          	bne	a5,a2,80003d26 <write_head+0x3a>
  }
  bwrite(buf);
    80003d32:	8526                	mv	a0,s1
    80003d34:	a4aff0ef          	jal	80002f7e <bwrite>
  brelse(buf);
    80003d38:	8526                	mv	a0,s1
    80003d3a:	a76ff0ef          	jal	80002fb0 <brelse>
}
    80003d3e:	60e2                	ld	ra,24(sp)
    80003d40:	6442                	ld	s0,16(sp)
    80003d42:	64a2                	ld	s1,8(sp)
    80003d44:	6902                	ld	s2,0(sp)
    80003d46:	6105                	addi	sp,sp,32
    80003d48:	8082                	ret

0000000080003d4a <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d4a:	0001f797          	auipc	a5,0x1f
    80003d4e:	8627a783          	lw	a5,-1950(a5) # 800225ac <log+0x2c>
    80003d52:	08f05f63          	blez	a5,80003df0 <install_trans+0xa6>
{
    80003d56:	7139                	addi	sp,sp,-64
    80003d58:	fc06                	sd	ra,56(sp)
    80003d5a:	f822                	sd	s0,48(sp)
    80003d5c:	f426                	sd	s1,40(sp)
    80003d5e:	f04a                	sd	s2,32(sp)
    80003d60:	ec4e                	sd	s3,24(sp)
    80003d62:	e852                	sd	s4,16(sp)
    80003d64:	e456                	sd	s5,8(sp)
    80003d66:	e05a                	sd	s6,0(sp)
    80003d68:	0080                	addi	s0,sp,64
    80003d6a:	8b2a                	mv	s6,a0
    80003d6c:	0001fa97          	auipc	s5,0x1f
    80003d70:	844a8a93          	addi	s5,s5,-1980 # 800225b0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d74:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003d76:	0001f997          	auipc	s3,0x1f
    80003d7a:	80a98993          	addi	s3,s3,-2038 # 80022580 <log>
    80003d7e:	a829                	j	80003d98 <install_trans+0x4e>
    brelse(lbuf);
    80003d80:	854a                	mv	a0,s2
    80003d82:	a2eff0ef          	jal	80002fb0 <brelse>
    brelse(dbuf);
    80003d86:	8526                	mv	a0,s1
    80003d88:	a28ff0ef          	jal	80002fb0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d8c:	2a05                	addiw	s4,s4,1
    80003d8e:	0a91                	addi	s5,s5,4
    80003d90:	02c9a783          	lw	a5,44(s3)
    80003d94:	04fa5463          	bge	s4,a5,80003ddc <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003d98:	0189a583          	lw	a1,24(s3)
    80003d9c:	014585bb          	addw	a1,a1,s4
    80003da0:	2585                	addiw	a1,a1,1
    80003da2:	0289a503          	lw	a0,40(s3)
    80003da6:	902ff0ef          	jal	80002ea8 <bread>
    80003daa:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003dac:	000aa583          	lw	a1,0(s5)
    80003db0:	0289a503          	lw	a0,40(s3)
    80003db4:	8f4ff0ef          	jal	80002ea8 <bread>
    80003db8:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003dba:	40000613          	li	a2,1024
    80003dbe:	05890593          	addi	a1,s2,88
    80003dc2:	05850513          	addi	a0,a0,88
    80003dc6:	f93fc0ef          	jal	80000d58 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003dca:	8526                	mv	a0,s1
    80003dcc:	9b2ff0ef          	jal	80002f7e <bwrite>
    if(recovering == 0)
    80003dd0:	fa0b18e3          	bnez	s6,80003d80 <install_trans+0x36>
      bunpin(dbuf);
    80003dd4:	8526                	mv	a0,s1
    80003dd6:	a96ff0ef          	jal	8000306c <bunpin>
    80003dda:	b75d                	j	80003d80 <install_trans+0x36>
}
    80003ddc:	70e2                	ld	ra,56(sp)
    80003dde:	7442                	ld	s0,48(sp)
    80003de0:	74a2                	ld	s1,40(sp)
    80003de2:	7902                	ld	s2,32(sp)
    80003de4:	69e2                	ld	s3,24(sp)
    80003de6:	6a42                	ld	s4,16(sp)
    80003de8:	6aa2                	ld	s5,8(sp)
    80003dea:	6b02                	ld	s6,0(sp)
    80003dec:	6121                	addi	sp,sp,64
    80003dee:	8082                	ret
    80003df0:	8082                	ret

0000000080003df2 <initlog>:
{
    80003df2:	7179                	addi	sp,sp,-48
    80003df4:	f406                	sd	ra,40(sp)
    80003df6:	f022                	sd	s0,32(sp)
    80003df8:	ec26                	sd	s1,24(sp)
    80003dfa:	e84a                	sd	s2,16(sp)
    80003dfc:	e44e                	sd	s3,8(sp)
    80003dfe:	1800                	addi	s0,sp,48
    80003e00:	892a                	mv	s2,a0
    80003e02:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003e04:	0001e497          	auipc	s1,0x1e
    80003e08:	77c48493          	addi	s1,s1,1916 # 80022580 <log>
    80003e0c:	00003597          	auipc	a1,0x3
    80003e10:	76458593          	addi	a1,a1,1892 # 80007570 <etext+0x570>
    80003e14:	8526                	mv	a0,s1
    80003e16:	d93fc0ef          	jal	80000ba8 <initlock>
  log.start = sb->logstart;
    80003e1a:	0149a583          	lw	a1,20(s3)
    80003e1e:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003e20:	0109a783          	lw	a5,16(s3)
    80003e24:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003e26:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003e2a:	854a                	mv	a0,s2
    80003e2c:	87cff0ef          	jal	80002ea8 <bread>
  log.lh.n = lh->n;
    80003e30:	4d30                	lw	a2,88(a0)
    80003e32:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003e34:	00c05f63          	blez	a2,80003e52 <initlog+0x60>
    80003e38:	87aa                	mv	a5,a0
    80003e3a:	0001e717          	auipc	a4,0x1e
    80003e3e:	77670713          	addi	a4,a4,1910 # 800225b0 <log+0x30>
    80003e42:	060a                	slli	a2,a2,0x2
    80003e44:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003e46:	4ff4                	lw	a3,92(a5)
    80003e48:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003e4a:	0791                	addi	a5,a5,4
    80003e4c:	0711                	addi	a4,a4,4
    80003e4e:	fec79ce3          	bne	a5,a2,80003e46 <initlog+0x54>
  brelse(buf);
    80003e52:	95eff0ef          	jal	80002fb0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003e56:	4505                	li	a0,1
    80003e58:	ef3ff0ef          	jal	80003d4a <install_trans>
  log.lh.n = 0;
    80003e5c:	0001e797          	auipc	a5,0x1e
    80003e60:	7407a823          	sw	zero,1872(a5) # 800225ac <log+0x2c>
  write_head(); // clear the log
    80003e64:	e89ff0ef          	jal	80003cec <write_head>
}
    80003e68:	70a2                	ld	ra,40(sp)
    80003e6a:	7402                	ld	s0,32(sp)
    80003e6c:	64e2                	ld	s1,24(sp)
    80003e6e:	6942                	ld	s2,16(sp)
    80003e70:	69a2                	ld	s3,8(sp)
    80003e72:	6145                	addi	sp,sp,48
    80003e74:	8082                	ret

0000000080003e76 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003e76:	1101                	addi	sp,sp,-32
    80003e78:	ec06                	sd	ra,24(sp)
    80003e7a:	e822                	sd	s0,16(sp)
    80003e7c:	e426                	sd	s1,8(sp)
    80003e7e:	e04a                	sd	s2,0(sp)
    80003e80:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003e82:	0001e517          	auipc	a0,0x1e
    80003e86:	6fe50513          	addi	a0,a0,1790 # 80022580 <log>
    80003e8a:	d9ffc0ef          	jal	80000c28 <acquire>
  while(1){
    if(log.committing){
    80003e8e:	0001e497          	auipc	s1,0x1e
    80003e92:	6f248493          	addi	s1,s1,1778 # 80022580 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003e96:	4979                	li	s2,30
    80003e98:	a029                	j	80003ea2 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003e9a:	85a6                	mv	a1,s1
    80003e9c:	8526                	mv	a0,s1
    80003e9e:	844fe0ef          	jal	80001ee2 <sleep>
    if(log.committing){
    80003ea2:	50dc                	lw	a5,36(s1)
    80003ea4:	fbfd                	bnez	a5,80003e9a <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003ea6:	5098                	lw	a4,32(s1)
    80003ea8:	2705                	addiw	a4,a4,1
    80003eaa:	0027179b          	slliw	a5,a4,0x2
    80003eae:	9fb9                	addw	a5,a5,a4
    80003eb0:	0017979b          	slliw	a5,a5,0x1
    80003eb4:	54d4                	lw	a3,44(s1)
    80003eb6:	9fb5                	addw	a5,a5,a3
    80003eb8:	00f95763          	bge	s2,a5,80003ec6 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003ebc:	85a6                	mv	a1,s1
    80003ebe:	8526                	mv	a0,s1
    80003ec0:	822fe0ef          	jal	80001ee2 <sleep>
    80003ec4:	bff9                	j	80003ea2 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003ec6:	0001e517          	auipc	a0,0x1e
    80003eca:	6ba50513          	addi	a0,a0,1722 # 80022580 <log>
    80003ece:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80003ed0:	df1fc0ef          	jal	80000cc0 <release>
      break;
    }
  }
}
    80003ed4:	60e2                	ld	ra,24(sp)
    80003ed6:	6442                	ld	s0,16(sp)
    80003ed8:	64a2                	ld	s1,8(sp)
    80003eda:	6902                	ld	s2,0(sp)
    80003edc:	6105                	addi	sp,sp,32
    80003ede:	8082                	ret

0000000080003ee0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003ee0:	7139                	addi	sp,sp,-64
    80003ee2:	fc06                	sd	ra,56(sp)
    80003ee4:	f822                	sd	s0,48(sp)
    80003ee6:	f426                	sd	s1,40(sp)
    80003ee8:	f04a                	sd	s2,32(sp)
    80003eea:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003eec:	0001e497          	auipc	s1,0x1e
    80003ef0:	69448493          	addi	s1,s1,1684 # 80022580 <log>
    80003ef4:	8526                	mv	a0,s1
    80003ef6:	d33fc0ef          	jal	80000c28 <acquire>
  log.outstanding -= 1;
    80003efa:	509c                	lw	a5,32(s1)
    80003efc:	37fd                	addiw	a5,a5,-1
    80003efe:	0007891b          	sext.w	s2,a5
    80003f02:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003f04:	50dc                	lw	a5,36(s1)
    80003f06:	ef9d                	bnez	a5,80003f44 <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003f08:	04091763          	bnez	s2,80003f56 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003f0c:	0001e497          	auipc	s1,0x1e
    80003f10:	67448493          	addi	s1,s1,1652 # 80022580 <log>
    80003f14:	4785                	li	a5,1
    80003f16:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003f18:	8526                	mv	a0,s1
    80003f1a:	da7fc0ef          	jal	80000cc0 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003f1e:	54dc                	lw	a5,44(s1)
    80003f20:	04f04b63          	bgtz	a5,80003f76 <end_op+0x96>
    acquire(&log.lock);
    80003f24:	0001e497          	auipc	s1,0x1e
    80003f28:	65c48493          	addi	s1,s1,1628 # 80022580 <log>
    80003f2c:	8526                	mv	a0,s1
    80003f2e:	cfbfc0ef          	jal	80000c28 <acquire>
    log.committing = 0;
    80003f32:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003f36:	8526                	mv	a0,s1
    80003f38:	ff7fd0ef          	jal	80001f2e <wakeup>
    release(&log.lock);
    80003f3c:	8526                	mv	a0,s1
    80003f3e:	d83fc0ef          	jal	80000cc0 <release>
}
    80003f42:	a025                	j	80003f6a <end_op+0x8a>
    80003f44:	ec4e                	sd	s3,24(sp)
    80003f46:	e852                	sd	s4,16(sp)
    80003f48:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003f4a:	00003517          	auipc	a0,0x3
    80003f4e:	62e50513          	addi	a0,a0,1582 # 80007578 <etext+0x578>
    80003f52:	877fc0ef          	jal	800007c8 <panic>
    wakeup(&log);
    80003f56:	0001e497          	auipc	s1,0x1e
    80003f5a:	62a48493          	addi	s1,s1,1578 # 80022580 <log>
    80003f5e:	8526                	mv	a0,s1
    80003f60:	fcffd0ef          	jal	80001f2e <wakeup>
  release(&log.lock);
    80003f64:	8526                	mv	a0,s1
    80003f66:	d5bfc0ef          	jal	80000cc0 <release>
}
    80003f6a:	70e2                	ld	ra,56(sp)
    80003f6c:	7442                	ld	s0,48(sp)
    80003f6e:	74a2                	ld	s1,40(sp)
    80003f70:	7902                	ld	s2,32(sp)
    80003f72:	6121                	addi	sp,sp,64
    80003f74:	8082                	ret
    80003f76:	ec4e                	sd	s3,24(sp)
    80003f78:	e852                	sd	s4,16(sp)
    80003f7a:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f7c:	0001ea97          	auipc	s5,0x1e
    80003f80:	634a8a93          	addi	s5,s5,1588 # 800225b0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003f84:	0001ea17          	auipc	s4,0x1e
    80003f88:	5fca0a13          	addi	s4,s4,1532 # 80022580 <log>
    80003f8c:	018a2583          	lw	a1,24(s4)
    80003f90:	012585bb          	addw	a1,a1,s2
    80003f94:	2585                	addiw	a1,a1,1
    80003f96:	028a2503          	lw	a0,40(s4)
    80003f9a:	f0ffe0ef          	jal	80002ea8 <bread>
    80003f9e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003fa0:	000aa583          	lw	a1,0(s5)
    80003fa4:	028a2503          	lw	a0,40(s4)
    80003fa8:	f01fe0ef          	jal	80002ea8 <bread>
    80003fac:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003fae:	40000613          	li	a2,1024
    80003fb2:	05850593          	addi	a1,a0,88
    80003fb6:	05848513          	addi	a0,s1,88
    80003fba:	d9ffc0ef          	jal	80000d58 <memmove>
    bwrite(to);  // write the log
    80003fbe:	8526                	mv	a0,s1
    80003fc0:	fbffe0ef          	jal	80002f7e <bwrite>
    brelse(from);
    80003fc4:	854e                	mv	a0,s3
    80003fc6:	febfe0ef          	jal	80002fb0 <brelse>
    brelse(to);
    80003fca:	8526                	mv	a0,s1
    80003fcc:	fe5fe0ef          	jal	80002fb0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fd0:	2905                	addiw	s2,s2,1
    80003fd2:	0a91                	addi	s5,s5,4
    80003fd4:	02ca2783          	lw	a5,44(s4)
    80003fd8:	faf94ae3          	blt	s2,a5,80003f8c <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003fdc:	d11ff0ef          	jal	80003cec <write_head>
    install_trans(0); // Now install writes to home locations
    80003fe0:	4501                	li	a0,0
    80003fe2:	d69ff0ef          	jal	80003d4a <install_trans>
    log.lh.n = 0;
    80003fe6:	0001e797          	auipc	a5,0x1e
    80003fea:	5c07a323          	sw	zero,1478(a5) # 800225ac <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003fee:	cffff0ef          	jal	80003cec <write_head>
    80003ff2:	69e2                	ld	s3,24(sp)
    80003ff4:	6a42                	ld	s4,16(sp)
    80003ff6:	6aa2                	ld	s5,8(sp)
    80003ff8:	b735                	j	80003f24 <end_op+0x44>

0000000080003ffa <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003ffa:	1101                	addi	sp,sp,-32
    80003ffc:	ec06                	sd	ra,24(sp)
    80003ffe:	e822                	sd	s0,16(sp)
    80004000:	e426                	sd	s1,8(sp)
    80004002:	e04a                	sd	s2,0(sp)
    80004004:	1000                	addi	s0,sp,32
    80004006:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004008:	0001e917          	auipc	s2,0x1e
    8000400c:	57890913          	addi	s2,s2,1400 # 80022580 <log>
    80004010:	854a                	mv	a0,s2
    80004012:	c17fc0ef          	jal	80000c28 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004016:	02c92603          	lw	a2,44(s2)
    8000401a:	47f5                	li	a5,29
    8000401c:	06c7c363          	blt	a5,a2,80004082 <log_write+0x88>
    80004020:	0001e797          	auipc	a5,0x1e
    80004024:	57c7a783          	lw	a5,1404(a5) # 8002259c <log+0x1c>
    80004028:	37fd                	addiw	a5,a5,-1
    8000402a:	04f65c63          	bge	a2,a5,80004082 <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000402e:	0001e797          	auipc	a5,0x1e
    80004032:	5727a783          	lw	a5,1394(a5) # 800225a0 <log+0x20>
    80004036:	04f05c63          	blez	a5,8000408e <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000403a:	4781                	li	a5,0
    8000403c:	04c05f63          	blez	a2,8000409a <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004040:	44cc                	lw	a1,12(s1)
    80004042:	0001e717          	auipc	a4,0x1e
    80004046:	56e70713          	addi	a4,a4,1390 # 800225b0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000404a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000404c:	4314                	lw	a3,0(a4)
    8000404e:	04b68663          	beq	a3,a1,8000409a <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80004052:	2785                	addiw	a5,a5,1
    80004054:	0711                	addi	a4,a4,4
    80004056:	fef61be3          	bne	a2,a5,8000404c <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000405a:	0621                	addi	a2,a2,8
    8000405c:	060a                	slli	a2,a2,0x2
    8000405e:	0001e797          	auipc	a5,0x1e
    80004062:	52278793          	addi	a5,a5,1314 # 80022580 <log>
    80004066:	97b2                	add	a5,a5,a2
    80004068:	44d8                	lw	a4,12(s1)
    8000406a:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000406c:	8526                	mv	a0,s1
    8000406e:	fcbfe0ef          	jal	80003038 <bpin>
    log.lh.n++;
    80004072:	0001e717          	auipc	a4,0x1e
    80004076:	50e70713          	addi	a4,a4,1294 # 80022580 <log>
    8000407a:	575c                	lw	a5,44(a4)
    8000407c:	2785                	addiw	a5,a5,1
    8000407e:	d75c                	sw	a5,44(a4)
    80004080:	a80d                	j	800040b2 <log_write+0xb8>
    panic("too big a transaction");
    80004082:	00003517          	auipc	a0,0x3
    80004086:	50650513          	addi	a0,a0,1286 # 80007588 <etext+0x588>
    8000408a:	f3efc0ef          	jal	800007c8 <panic>
    panic("log_write outside of trans");
    8000408e:	00003517          	auipc	a0,0x3
    80004092:	51250513          	addi	a0,a0,1298 # 800075a0 <etext+0x5a0>
    80004096:	f32fc0ef          	jal	800007c8 <panic>
  log.lh.block[i] = b->blockno;
    8000409a:	00878693          	addi	a3,a5,8
    8000409e:	068a                	slli	a3,a3,0x2
    800040a0:	0001e717          	auipc	a4,0x1e
    800040a4:	4e070713          	addi	a4,a4,1248 # 80022580 <log>
    800040a8:	9736                	add	a4,a4,a3
    800040aa:	44d4                	lw	a3,12(s1)
    800040ac:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800040ae:	faf60fe3          	beq	a2,a5,8000406c <log_write+0x72>
  }
  release(&log.lock);
    800040b2:	0001e517          	auipc	a0,0x1e
    800040b6:	4ce50513          	addi	a0,a0,1230 # 80022580 <log>
    800040ba:	c07fc0ef          	jal	80000cc0 <release>
}
    800040be:	60e2                	ld	ra,24(sp)
    800040c0:	6442                	ld	s0,16(sp)
    800040c2:	64a2                	ld	s1,8(sp)
    800040c4:	6902                	ld	s2,0(sp)
    800040c6:	6105                	addi	sp,sp,32
    800040c8:	8082                	ret

00000000800040ca <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800040ca:	1101                	addi	sp,sp,-32
    800040cc:	ec06                	sd	ra,24(sp)
    800040ce:	e822                	sd	s0,16(sp)
    800040d0:	e426                	sd	s1,8(sp)
    800040d2:	e04a                	sd	s2,0(sp)
    800040d4:	1000                	addi	s0,sp,32
    800040d6:	84aa                	mv	s1,a0
    800040d8:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800040da:	00003597          	auipc	a1,0x3
    800040de:	4e658593          	addi	a1,a1,1254 # 800075c0 <etext+0x5c0>
    800040e2:	0521                	addi	a0,a0,8
    800040e4:	ac5fc0ef          	jal	80000ba8 <initlock>
  lk->name = name;
    800040e8:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800040ec:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800040f0:	0204a423          	sw	zero,40(s1)
}
    800040f4:	60e2                	ld	ra,24(sp)
    800040f6:	6442                	ld	s0,16(sp)
    800040f8:	64a2                	ld	s1,8(sp)
    800040fa:	6902                	ld	s2,0(sp)
    800040fc:	6105                	addi	sp,sp,32
    800040fe:	8082                	ret

0000000080004100 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004100:	1101                	addi	sp,sp,-32
    80004102:	ec06                	sd	ra,24(sp)
    80004104:	e822                	sd	s0,16(sp)
    80004106:	e426                	sd	s1,8(sp)
    80004108:	e04a                	sd	s2,0(sp)
    8000410a:	1000                	addi	s0,sp,32
    8000410c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000410e:	00850913          	addi	s2,a0,8
    80004112:	854a                	mv	a0,s2
    80004114:	b15fc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    80004118:	409c                	lw	a5,0(s1)
    8000411a:	c799                	beqz	a5,80004128 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    8000411c:	85ca                	mv	a1,s2
    8000411e:	8526                	mv	a0,s1
    80004120:	dc3fd0ef          	jal	80001ee2 <sleep>
  while (lk->locked) {
    80004124:	409c                	lw	a5,0(s1)
    80004126:	fbfd                	bnez	a5,8000411c <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004128:	4785                	li	a5,1
    8000412a:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000412c:	fe8fd0ef          	jal	80001914 <myproc>
    80004130:	591c                	lw	a5,48(a0)
    80004132:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004134:	854a                	mv	a0,s2
    80004136:	b8bfc0ef          	jal	80000cc0 <release>
}
    8000413a:	60e2                	ld	ra,24(sp)
    8000413c:	6442                	ld	s0,16(sp)
    8000413e:	64a2                	ld	s1,8(sp)
    80004140:	6902                	ld	s2,0(sp)
    80004142:	6105                	addi	sp,sp,32
    80004144:	8082                	ret

0000000080004146 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004146:	1101                	addi	sp,sp,-32
    80004148:	ec06                	sd	ra,24(sp)
    8000414a:	e822                	sd	s0,16(sp)
    8000414c:	e426                	sd	s1,8(sp)
    8000414e:	e04a                	sd	s2,0(sp)
    80004150:	1000                	addi	s0,sp,32
    80004152:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004154:	00850913          	addi	s2,a0,8
    80004158:	854a                	mv	a0,s2
    8000415a:	acffc0ef          	jal	80000c28 <acquire>
  lk->locked = 0;
    8000415e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004162:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004166:	8526                	mv	a0,s1
    80004168:	dc7fd0ef          	jal	80001f2e <wakeup>
  release(&lk->lk);
    8000416c:	854a                	mv	a0,s2
    8000416e:	b53fc0ef          	jal	80000cc0 <release>
}
    80004172:	60e2                	ld	ra,24(sp)
    80004174:	6442                	ld	s0,16(sp)
    80004176:	64a2                	ld	s1,8(sp)
    80004178:	6902                	ld	s2,0(sp)
    8000417a:	6105                	addi	sp,sp,32
    8000417c:	8082                	ret

000000008000417e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000417e:	7179                	addi	sp,sp,-48
    80004180:	f406                	sd	ra,40(sp)
    80004182:	f022                	sd	s0,32(sp)
    80004184:	ec26                	sd	s1,24(sp)
    80004186:	e84a                	sd	s2,16(sp)
    80004188:	1800                	addi	s0,sp,48
    8000418a:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000418c:	00850913          	addi	s2,a0,8
    80004190:	854a                	mv	a0,s2
    80004192:	a97fc0ef          	jal	80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004196:	409c                	lw	a5,0(s1)
    80004198:	ef81                	bnez	a5,800041b0 <holdingsleep+0x32>
    8000419a:	4481                	li	s1,0
  release(&lk->lk);
    8000419c:	854a                	mv	a0,s2
    8000419e:	b23fc0ef          	jal	80000cc0 <release>
  return r;
}
    800041a2:	8526                	mv	a0,s1
    800041a4:	70a2                	ld	ra,40(sp)
    800041a6:	7402                	ld	s0,32(sp)
    800041a8:	64e2                	ld	s1,24(sp)
    800041aa:	6942                	ld	s2,16(sp)
    800041ac:	6145                	addi	sp,sp,48
    800041ae:	8082                	ret
    800041b0:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800041b2:	0284a983          	lw	s3,40(s1)
    800041b6:	f5efd0ef          	jal	80001914 <myproc>
    800041ba:	5904                	lw	s1,48(a0)
    800041bc:	413484b3          	sub	s1,s1,s3
    800041c0:	0014b493          	seqz	s1,s1
    800041c4:	69a2                	ld	s3,8(sp)
    800041c6:	bfd9                	j	8000419c <holdingsleep+0x1e>

00000000800041c8 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800041c8:	1141                	addi	sp,sp,-16
    800041ca:	e406                	sd	ra,8(sp)
    800041cc:	e022                	sd	s0,0(sp)
    800041ce:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800041d0:	00003597          	auipc	a1,0x3
    800041d4:	40058593          	addi	a1,a1,1024 # 800075d0 <etext+0x5d0>
    800041d8:	0001e517          	auipc	a0,0x1e
    800041dc:	4f050513          	addi	a0,a0,1264 # 800226c8 <ftable>
    800041e0:	9c9fc0ef          	jal	80000ba8 <initlock>
}
    800041e4:	60a2                	ld	ra,8(sp)
    800041e6:	6402                	ld	s0,0(sp)
    800041e8:	0141                	addi	sp,sp,16
    800041ea:	8082                	ret

00000000800041ec <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800041ec:	1101                	addi	sp,sp,-32
    800041ee:	ec06                	sd	ra,24(sp)
    800041f0:	e822                	sd	s0,16(sp)
    800041f2:	e426                	sd	s1,8(sp)
    800041f4:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800041f6:	0001e517          	auipc	a0,0x1e
    800041fa:	4d250513          	addi	a0,a0,1234 # 800226c8 <ftable>
    800041fe:	a2bfc0ef          	jal	80000c28 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004202:	0001e497          	auipc	s1,0x1e
    80004206:	4de48493          	addi	s1,s1,1246 # 800226e0 <ftable+0x18>
    8000420a:	0001f717          	auipc	a4,0x1f
    8000420e:	47670713          	addi	a4,a4,1142 # 80023680 <disk>
    if(f->ref == 0){
    80004212:	40dc                	lw	a5,4(s1)
    80004214:	cf89                	beqz	a5,8000422e <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004216:	02848493          	addi	s1,s1,40
    8000421a:	fee49ce3          	bne	s1,a4,80004212 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000421e:	0001e517          	auipc	a0,0x1e
    80004222:	4aa50513          	addi	a0,a0,1194 # 800226c8 <ftable>
    80004226:	a9bfc0ef          	jal	80000cc0 <release>
  return 0;
    8000422a:	4481                	li	s1,0
    8000422c:	a809                	j	8000423e <filealloc+0x52>
      f->ref = 1;
    8000422e:	4785                	li	a5,1
    80004230:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004232:	0001e517          	auipc	a0,0x1e
    80004236:	49650513          	addi	a0,a0,1174 # 800226c8 <ftable>
    8000423a:	a87fc0ef          	jal	80000cc0 <release>
}
    8000423e:	8526                	mv	a0,s1
    80004240:	60e2                	ld	ra,24(sp)
    80004242:	6442                	ld	s0,16(sp)
    80004244:	64a2                	ld	s1,8(sp)
    80004246:	6105                	addi	sp,sp,32
    80004248:	8082                	ret

000000008000424a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000424a:	1101                	addi	sp,sp,-32
    8000424c:	ec06                	sd	ra,24(sp)
    8000424e:	e822                	sd	s0,16(sp)
    80004250:	e426                	sd	s1,8(sp)
    80004252:	1000                	addi	s0,sp,32
    80004254:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004256:	0001e517          	auipc	a0,0x1e
    8000425a:	47250513          	addi	a0,a0,1138 # 800226c8 <ftable>
    8000425e:	9cbfc0ef          	jal	80000c28 <acquire>
  if(f->ref < 1)
    80004262:	40dc                	lw	a5,4(s1)
    80004264:	02f05063          	blez	a5,80004284 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004268:	2785                	addiw	a5,a5,1
    8000426a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000426c:	0001e517          	auipc	a0,0x1e
    80004270:	45c50513          	addi	a0,a0,1116 # 800226c8 <ftable>
    80004274:	a4dfc0ef          	jal	80000cc0 <release>
  return f;
}
    80004278:	8526                	mv	a0,s1
    8000427a:	60e2                	ld	ra,24(sp)
    8000427c:	6442                	ld	s0,16(sp)
    8000427e:	64a2                	ld	s1,8(sp)
    80004280:	6105                	addi	sp,sp,32
    80004282:	8082                	ret
    panic("filedup");
    80004284:	00003517          	auipc	a0,0x3
    80004288:	35450513          	addi	a0,a0,852 # 800075d8 <etext+0x5d8>
    8000428c:	d3cfc0ef          	jal	800007c8 <panic>

0000000080004290 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004290:	7139                	addi	sp,sp,-64
    80004292:	fc06                	sd	ra,56(sp)
    80004294:	f822                	sd	s0,48(sp)
    80004296:	f426                	sd	s1,40(sp)
    80004298:	0080                	addi	s0,sp,64
    8000429a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000429c:	0001e517          	auipc	a0,0x1e
    800042a0:	42c50513          	addi	a0,a0,1068 # 800226c8 <ftable>
    800042a4:	985fc0ef          	jal	80000c28 <acquire>
  if(f->ref < 1)
    800042a8:	40dc                	lw	a5,4(s1)
    800042aa:	04f05a63          	blez	a5,800042fe <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    800042ae:	37fd                	addiw	a5,a5,-1
    800042b0:	0007871b          	sext.w	a4,a5
    800042b4:	c0dc                	sw	a5,4(s1)
    800042b6:	04e04e63          	bgtz	a4,80004312 <fileclose+0x82>
    800042ba:	f04a                	sd	s2,32(sp)
    800042bc:	ec4e                	sd	s3,24(sp)
    800042be:	e852                	sd	s4,16(sp)
    800042c0:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800042c2:	0004a903          	lw	s2,0(s1)
    800042c6:	0094ca83          	lbu	s5,9(s1)
    800042ca:	0104ba03          	ld	s4,16(s1)
    800042ce:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800042d2:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800042d6:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800042da:	0001e517          	auipc	a0,0x1e
    800042de:	3ee50513          	addi	a0,a0,1006 # 800226c8 <ftable>
    800042e2:	9dffc0ef          	jal	80000cc0 <release>

  if(ff.type == FD_PIPE){
    800042e6:	4785                	li	a5,1
    800042e8:	04f90063          	beq	s2,a5,80004328 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800042ec:	3979                	addiw	s2,s2,-2
    800042ee:	4785                	li	a5,1
    800042f0:	0527f563          	bgeu	a5,s2,8000433a <fileclose+0xaa>
    800042f4:	7902                	ld	s2,32(sp)
    800042f6:	69e2                	ld	s3,24(sp)
    800042f8:	6a42                	ld	s4,16(sp)
    800042fa:	6aa2                	ld	s5,8(sp)
    800042fc:	a00d                	j	8000431e <fileclose+0x8e>
    800042fe:	f04a                	sd	s2,32(sp)
    80004300:	ec4e                	sd	s3,24(sp)
    80004302:	e852                	sd	s4,16(sp)
    80004304:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004306:	00003517          	auipc	a0,0x3
    8000430a:	2da50513          	addi	a0,a0,730 # 800075e0 <etext+0x5e0>
    8000430e:	cbafc0ef          	jal	800007c8 <panic>
    release(&ftable.lock);
    80004312:	0001e517          	auipc	a0,0x1e
    80004316:	3b650513          	addi	a0,a0,950 # 800226c8 <ftable>
    8000431a:	9a7fc0ef          	jal	80000cc0 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    8000431e:	70e2                	ld	ra,56(sp)
    80004320:	7442                	ld	s0,48(sp)
    80004322:	74a2                	ld	s1,40(sp)
    80004324:	6121                	addi	sp,sp,64
    80004326:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004328:	85d6                	mv	a1,s5
    8000432a:	8552                	mv	a0,s4
    8000432c:	336000ef          	jal	80004662 <pipeclose>
    80004330:	7902                	ld	s2,32(sp)
    80004332:	69e2                	ld	s3,24(sp)
    80004334:	6a42                	ld	s4,16(sp)
    80004336:	6aa2                	ld	s5,8(sp)
    80004338:	b7dd                	j	8000431e <fileclose+0x8e>
    begin_op();
    8000433a:	b3dff0ef          	jal	80003e76 <begin_op>
    iput(ff.ip);
    8000433e:	854e                	mv	a0,s3
    80004340:	c22ff0ef          	jal	80003762 <iput>
    end_op();
    80004344:	b9dff0ef          	jal	80003ee0 <end_op>
    80004348:	7902                	ld	s2,32(sp)
    8000434a:	69e2                	ld	s3,24(sp)
    8000434c:	6a42                	ld	s4,16(sp)
    8000434e:	6aa2                	ld	s5,8(sp)
    80004350:	b7f9                	j	8000431e <fileclose+0x8e>

0000000080004352 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004352:	715d                	addi	sp,sp,-80
    80004354:	e486                	sd	ra,72(sp)
    80004356:	e0a2                	sd	s0,64(sp)
    80004358:	fc26                	sd	s1,56(sp)
    8000435a:	f44e                	sd	s3,40(sp)
    8000435c:	0880                	addi	s0,sp,80
    8000435e:	84aa                	mv	s1,a0
    80004360:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004362:	db2fd0ef          	jal	80001914 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004366:	409c                	lw	a5,0(s1)
    80004368:	37f9                	addiw	a5,a5,-2
    8000436a:	4705                	li	a4,1
    8000436c:	04f76063          	bltu	a4,a5,800043ac <filestat+0x5a>
    80004370:	f84a                	sd	s2,48(sp)
    80004372:	892a                	mv	s2,a0
    ilock(f->ip);
    80004374:	6c88                	ld	a0,24(s1)
    80004376:	a6aff0ef          	jal	800035e0 <ilock>
    stati(f->ip, &st);
    8000437a:	fb840593          	addi	a1,s0,-72
    8000437e:	6c88                	ld	a0,24(s1)
    80004380:	c8aff0ef          	jal	8000380a <stati>
    iunlock(f->ip);
    80004384:	6c88                	ld	a0,24(s1)
    80004386:	b08ff0ef          	jal	8000368e <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000438a:	46e1                	li	a3,24
    8000438c:	fb840613          	addi	a2,s0,-72
    80004390:	85ce                	mv	a1,s3
    80004392:	05093503          	ld	a0,80(s2)
    80004396:	9f0fd0ef          	jal	80001586 <copyout>
    8000439a:	41f5551b          	sraiw	a0,a0,0x1f
    8000439e:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800043a0:	60a6                	ld	ra,72(sp)
    800043a2:	6406                	ld	s0,64(sp)
    800043a4:	74e2                	ld	s1,56(sp)
    800043a6:	79a2                	ld	s3,40(sp)
    800043a8:	6161                	addi	sp,sp,80
    800043aa:	8082                	ret
  return -1;
    800043ac:	557d                	li	a0,-1
    800043ae:	bfcd                	j	800043a0 <filestat+0x4e>

00000000800043b0 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800043b0:	7179                	addi	sp,sp,-48
    800043b2:	f406                	sd	ra,40(sp)
    800043b4:	f022                	sd	s0,32(sp)
    800043b6:	e84a                	sd	s2,16(sp)
    800043b8:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800043ba:	00854783          	lbu	a5,8(a0)
    800043be:	cfd1                	beqz	a5,8000445a <fileread+0xaa>
    800043c0:	ec26                	sd	s1,24(sp)
    800043c2:	e44e                	sd	s3,8(sp)
    800043c4:	84aa                	mv	s1,a0
    800043c6:	89ae                	mv	s3,a1
    800043c8:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800043ca:	411c                	lw	a5,0(a0)
    800043cc:	4705                	li	a4,1
    800043ce:	04e78363          	beq	a5,a4,80004414 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800043d2:	470d                	li	a4,3
    800043d4:	04e78763          	beq	a5,a4,80004422 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800043d8:	4709                	li	a4,2
    800043da:	06e79a63          	bne	a5,a4,8000444e <fileread+0x9e>
    ilock(f->ip);
    800043de:	6d08                	ld	a0,24(a0)
    800043e0:	a00ff0ef          	jal	800035e0 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800043e4:	874a                	mv	a4,s2
    800043e6:	5094                	lw	a3,32(s1)
    800043e8:	864e                	mv	a2,s3
    800043ea:	4585                	li	a1,1
    800043ec:	6c88                	ld	a0,24(s1)
    800043ee:	c46ff0ef          	jal	80003834 <readi>
    800043f2:	892a                	mv	s2,a0
    800043f4:	00a05563          	blez	a0,800043fe <fileread+0x4e>
      f->off += r;
    800043f8:	509c                	lw	a5,32(s1)
    800043fa:	9fa9                	addw	a5,a5,a0
    800043fc:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800043fe:	6c88                	ld	a0,24(s1)
    80004400:	a8eff0ef          	jal	8000368e <iunlock>
    80004404:	64e2                	ld	s1,24(sp)
    80004406:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004408:	854a                	mv	a0,s2
    8000440a:	70a2                	ld	ra,40(sp)
    8000440c:	7402                	ld	s0,32(sp)
    8000440e:	6942                	ld	s2,16(sp)
    80004410:	6145                	addi	sp,sp,48
    80004412:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004414:	6908                	ld	a0,16(a0)
    80004416:	388000ef          	jal	8000479e <piperead>
    8000441a:	892a                	mv	s2,a0
    8000441c:	64e2                	ld	s1,24(sp)
    8000441e:	69a2                	ld	s3,8(sp)
    80004420:	b7e5                	j	80004408 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004422:	02451783          	lh	a5,36(a0)
    80004426:	03079693          	slli	a3,a5,0x30
    8000442a:	92c1                	srli	a3,a3,0x30
    8000442c:	4725                	li	a4,9
    8000442e:	02d76863          	bltu	a4,a3,8000445e <fileread+0xae>
    80004432:	0792                	slli	a5,a5,0x4
    80004434:	0001e717          	auipc	a4,0x1e
    80004438:	1f470713          	addi	a4,a4,500 # 80022628 <devsw>
    8000443c:	97ba                	add	a5,a5,a4
    8000443e:	639c                	ld	a5,0(a5)
    80004440:	c39d                	beqz	a5,80004466 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    80004442:	4505                	li	a0,1
    80004444:	9782                	jalr	a5
    80004446:	892a                	mv	s2,a0
    80004448:	64e2                	ld	s1,24(sp)
    8000444a:	69a2                	ld	s3,8(sp)
    8000444c:	bf75                	j	80004408 <fileread+0x58>
    panic("fileread");
    8000444e:	00003517          	auipc	a0,0x3
    80004452:	1a250513          	addi	a0,a0,418 # 800075f0 <etext+0x5f0>
    80004456:	b72fc0ef          	jal	800007c8 <panic>
    return -1;
    8000445a:	597d                	li	s2,-1
    8000445c:	b775                	j	80004408 <fileread+0x58>
      return -1;
    8000445e:	597d                	li	s2,-1
    80004460:	64e2                	ld	s1,24(sp)
    80004462:	69a2                	ld	s3,8(sp)
    80004464:	b755                	j	80004408 <fileread+0x58>
    80004466:	597d                	li	s2,-1
    80004468:	64e2                	ld	s1,24(sp)
    8000446a:	69a2                	ld	s3,8(sp)
    8000446c:	bf71                	j	80004408 <fileread+0x58>

000000008000446e <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000446e:	00954783          	lbu	a5,9(a0)
    80004472:	10078b63          	beqz	a5,80004588 <filewrite+0x11a>
{
    80004476:	715d                	addi	sp,sp,-80
    80004478:	e486                	sd	ra,72(sp)
    8000447a:	e0a2                	sd	s0,64(sp)
    8000447c:	f84a                	sd	s2,48(sp)
    8000447e:	f052                	sd	s4,32(sp)
    80004480:	e85a                	sd	s6,16(sp)
    80004482:	0880                	addi	s0,sp,80
    80004484:	892a                	mv	s2,a0
    80004486:	8b2e                	mv	s6,a1
    80004488:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000448a:	411c                	lw	a5,0(a0)
    8000448c:	4705                	li	a4,1
    8000448e:	02e78763          	beq	a5,a4,800044bc <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004492:	470d                	li	a4,3
    80004494:	02e78863          	beq	a5,a4,800044c4 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004498:	4709                	li	a4,2
    8000449a:	0ce79c63          	bne	a5,a4,80004572 <filewrite+0x104>
    8000449e:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800044a0:	0ac05863          	blez	a2,80004550 <filewrite+0xe2>
    800044a4:	fc26                	sd	s1,56(sp)
    800044a6:	ec56                	sd	s5,24(sp)
    800044a8:	e45e                	sd	s7,8(sp)
    800044aa:	e062                	sd	s8,0(sp)
    int i = 0;
    800044ac:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800044ae:	6b85                	lui	s7,0x1
    800044b0:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800044b4:	6c05                	lui	s8,0x1
    800044b6:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800044ba:	a8b5                	j	80004536 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    800044bc:	6908                	ld	a0,16(a0)
    800044be:	1fc000ef          	jal	800046ba <pipewrite>
    800044c2:	a04d                	j	80004564 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800044c4:	02451783          	lh	a5,36(a0)
    800044c8:	03079693          	slli	a3,a5,0x30
    800044cc:	92c1                	srli	a3,a3,0x30
    800044ce:	4725                	li	a4,9
    800044d0:	0ad76e63          	bltu	a4,a3,8000458c <filewrite+0x11e>
    800044d4:	0792                	slli	a5,a5,0x4
    800044d6:	0001e717          	auipc	a4,0x1e
    800044da:	15270713          	addi	a4,a4,338 # 80022628 <devsw>
    800044de:	97ba                	add	a5,a5,a4
    800044e0:	679c                	ld	a5,8(a5)
    800044e2:	c7dd                	beqz	a5,80004590 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    800044e4:	4505                	li	a0,1
    800044e6:	9782                	jalr	a5
    800044e8:	a8b5                	j	80004564 <filewrite+0xf6>
      if(n1 > max)
    800044ea:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800044ee:	989ff0ef          	jal	80003e76 <begin_op>
      ilock(f->ip);
    800044f2:	01893503          	ld	a0,24(s2)
    800044f6:	8eaff0ef          	jal	800035e0 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800044fa:	8756                	mv	a4,s5
    800044fc:	02092683          	lw	a3,32(s2)
    80004500:	01698633          	add	a2,s3,s6
    80004504:	4585                	li	a1,1
    80004506:	01893503          	ld	a0,24(s2)
    8000450a:	c26ff0ef          	jal	80003930 <writei>
    8000450e:	84aa                	mv	s1,a0
    80004510:	00a05763          	blez	a0,8000451e <filewrite+0xb0>
        f->off += r;
    80004514:	02092783          	lw	a5,32(s2)
    80004518:	9fa9                	addw	a5,a5,a0
    8000451a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000451e:	01893503          	ld	a0,24(s2)
    80004522:	96cff0ef          	jal	8000368e <iunlock>
      end_op();
    80004526:	9bbff0ef          	jal	80003ee0 <end_op>

      if(r != n1){
    8000452a:	029a9563          	bne	s5,s1,80004554 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    8000452e:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004532:	0149da63          	bge	s3,s4,80004546 <filewrite+0xd8>
      int n1 = n - i;
    80004536:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    8000453a:	0004879b          	sext.w	a5,s1
    8000453e:	fafbd6e3          	bge	s7,a5,800044ea <filewrite+0x7c>
    80004542:	84e2                	mv	s1,s8
    80004544:	b75d                	j	800044ea <filewrite+0x7c>
    80004546:	74e2                	ld	s1,56(sp)
    80004548:	6ae2                	ld	s5,24(sp)
    8000454a:	6ba2                	ld	s7,8(sp)
    8000454c:	6c02                	ld	s8,0(sp)
    8000454e:	a039                	j	8000455c <filewrite+0xee>
    int i = 0;
    80004550:	4981                	li	s3,0
    80004552:	a029                	j	8000455c <filewrite+0xee>
    80004554:	74e2                	ld	s1,56(sp)
    80004556:	6ae2                	ld	s5,24(sp)
    80004558:	6ba2                	ld	s7,8(sp)
    8000455a:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    8000455c:	033a1c63          	bne	s4,s3,80004594 <filewrite+0x126>
    80004560:	8552                	mv	a0,s4
    80004562:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004564:	60a6                	ld	ra,72(sp)
    80004566:	6406                	ld	s0,64(sp)
    80004568:	7942                	ld	s2,48(sp)
    8000456a:	7a02                	ld	s4,32(sp)
    8000456c:	6b42                	ld	s6,16(sp)
    8000456e:	6161                	addi	sp,sp,80
    80004570:	8082                	ret
    80004572:	fc26                	sd	s1,56(sp)
    80004574:	f44e                	sd	s3,40(sp)
    80004576:	ec56                	sd	s5,24(sp)
    80004578:	e45e                	sd	s7,8(sp)
    8000457a:	e062                	sd	s8,0(sp)
    panic("filewrite");
    8000457c:	00003517          	auipc	a0,0x3
    80004580:	08450513          	addi	a0,a0,132 # 80007600 <etext+0x600>
    80004584:	a44fc0ef          	jal	800007c8 <panic>
    return -1;
    80004588:	557d                	li	a0,-1
}
    8000458a:	8082                	ret
      return -1;
    8000458c:	557d                	li	a0,-1
    8000458e:	bfd9                	j	80004564 <filewrite+0xf6>
    80004590:	557d                	li	a0,-1
    80004592:	bfc9                	j	80004564 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    80004594:	557d                	li	a0,-1
    80004596:	79a2                	ld	s3,40(sp)
    80004598:	b7f1                	j	80004564 <filewrite+0xf6>

000000008000459a <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000459a:	7179                	addi	sp,sp,-48
    8000459c:	f406                	sd	ra,40(sp)
    8000459e:	f022                	sd	s0,32(sp)
    800045a0:	ec26                	sd	s1,24(sp)
    800045a2:	e052                	sd	s4,0(sp)
    800045a4:	1800                	addi	s0,sp,48
    800045a6:	84aa                	mv	s1,a0
    800045a8:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800045aa:	0005b023          	sd	zero,0(a1)
    800045ae:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800045b2:	c3bff0ef          	jal	800041ec <filealloc>
    800045b6:	e088                	sd	a0,0(s1)
    800045b8:	c549                	beqz	a0,80004642 <pipealloc+0xa8>
    800045ba:	c33ff0ef          	jal	800041ec <filealloc>
    800045be:	00aa3023          	sd	a0,0(s4)
    800045c2:	cd25                	beqz	a0,8000463a <pipealloc+0xa0>
    800045c4:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800045c6:	d92fc0ef          	jal	80000b58 <kalloc>
    800045ca:	892a                	mv	s2,a0
    800045cc:	c12d                	beqz	a0,8000462e <pipealloc+0x94>
    800045ce:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800045d0:	4985                	li	s3,1
    800045d2:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800045d6:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800045da:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800045de:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800045e2:	00003597          	auipc	a1,0x3
    800045e6:	02e58593          	addi	a1,a1,46 # 80007610 <etext+0x610>
    800045ea:	dbefc0ef          	jal	80000ba8 <initlock>
  (*f0)->type = FD_PIPE;
    800045ee:	609c                	ld	a5,0(s1)
    800045f0:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800045f4:	609c                	ld	a5,0(s1)
    800045f6:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800045fa:	609c                	ld	a5,0(s1)
    800045fc:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004600:	609c                	ld	a5,0(s1)
    80004602:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004606:	000a3783          	ld	a5,0(s4)
    8000460a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000460e:	000a3783          	ld	a5,0(s4)
    80004612:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004616:	000a3783          	ld	a5,0(s4)
    8000461a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000461e:	000a3783          	ld	a5,0(s4)
    80004622:	0127b823          	sd	s2,16(a5)
  return 0;
    80004626:	4501                	li	a0,0
    80004628:	6942                	ld	s2,16(sp)
    8000462a:	69a2                	ld	s3,8(sp)
    8000462c:	a01d                	j	80004652 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000462e:	6088                	ld	a0,0(s1)
    80004630:	c119                	beqz	a0,80004636 <pipealloc+0x9c>
    80004632:	6942                	ld	s2,16(sp)
    80004634:	a029                	j	8000463e <pipealloc+0xa4>
    80004636:	6942                	ld	s2,16(sp)
    80004638:	a029                	j	80004642 <pipealloc+0xa8>
    8000463a:	6088                	ld	a0,0(s1)
    8000463c:	c10d                	beqz	a0,8000465e <pipealloc+0xc4>
    fileclose(*f0);
    8000463e:	c53ff0ef          	jal	80004290 <fileclose>
  if(*f1)
    80004642:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004646:	557d                	li	a0,-1
  if(*f1)
    80004648:	c789                	beqz	a5,80004652 <pipealloc+0xb8>
    fileclose(*f1);
    8000464a:	853e                	mv	a0,a5
    8000464c:	c45ff0ef          	jal	80004290 <fileclose>
  return -1;
    80004650:	557d                	li	a0,-1
}
    80004652:	70a2                	ld	ra,40(sp)
    80004654:	7402                	ld	s0,32(sp)
    80004656:	64e2                	ld	s1,24(sp)
    80004658:	6a02                	ld	s4,0(sp)
    8000465a:	6145                	addi	sp,sp,48
    8000465c:	8082                	ret
  return -1;
    8000465e:	557d                	li	a0,-1
    80004660:	bfcd                	j	80004652 <pipealloc+0xb8>

0000000080004662 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004662:	1101                	addi	sp,sp,-32
    80004664:	ec06                	sd	ra,24(sp)
    80004666:	e822                	sd	s0,16(sp)
    80004668:	e426                	sd	s1,8(sp)
    8000466a:	e04a                	sd	s2,0(sp)
    8000466c:	1000                	addi	s0,sp,32
    8000466e:	84aa                	mv	s1,a0
    80004670:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004672:	db6fc0ef          	jal	80000c28 <acquire>
  if(writable){
    80004676:	02090763          	beqz	s2,800046a4 <pipeclose+0x42>
    pi->writeopen = 0;
    8000467a:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000467e:	21848513          	addi	a0,s1,536
    80004682:	8adfd0ef          	jal	80001f2e <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004686:	2204b783          	ld	a5,544(s1)
    8000468a:	e785                	bnez	a5,800046b2 <pipeclose+0x50>
    release(&pi->lock);
    8000468c:	8526                	mv	a0,s1
    8000468e:	e32fc0ef          	jal	80000cc0 <release>
    kfree((char*)pi);
    80004692:	8526                	mv	a0,s1
    80004694:	be2fc0ef          	jal	80000a76 <kfree>
  } else
    release(&pi->lock);
}
    80004698:	60e2                	ld	ra,24(sp)
    8000469a:	6442                	ld	s0,16(sp)
    8000469c:	64a2                	ld	s1,8(sp)
    8000469e:	6902                	ld	s2,0(sp)
    800046a0:	6105                	addi	sp,sp,32
    800046a2:	8082                	ret
    pi->readopen = 0;
    800046a4:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800046a8:	21c48513          	addi	a0,s1,540
    800046ac:	883fd0ef          	jal	80001f2e <wakeup>
    800046b0:	bfd9                	j	80004686 <pipeclose+0x24>
    release(&pi->lock);
    800046b2:	8526                	mv	a0,s1
    800046b4:	e0cfc0ef          	jal	80000cc0 <release>
}
    800046b8:	b7c5                	j	80004698 <pipeclose+0x36>

00000000800046ba <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800046ba:	711d                	addi	sp,sp,-96
    800046bc:	ec86                	sd	ra,88(sp)
    800046be:	e8a2                	sd	s0,80(sp)
    800046c0:	e4a6                	sd	s1,72(sp)
    800046c2:	e0ca                	sd	s2,64(sp)
    800046c4:	fc4e                	sd	s3,56(sp)
    800046c6:	f852                	sd	s4,48(sp)
    800046c8:	f456                	sd	s5,40(sp)
    800046ca:	1080                	addi	s0,sp,96
    800046cc:	84aa                	mv	s1,a0
    800046ce:	8aae                	mv	s5,a1
    800046d0:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800046d2:	a42fd0ef          	jal	80001914 <myproc>
    800046d6:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800046d8:	8526                	mv	a0,s1
    800046da:	d4efc0ef          	jal	80000c28 <acquire>
  while(i < n){
    800046de:	0b405a63          	blez	s4,80004792 <pipewrite+0xd8>
    800046e2:	f05a                	sd	s6,32(sp)
    800046e4:	ec5e                	sd	s7,24(sp)
    800046e6:	e862                	sd	s8,16(sp)
  int i = 0;
    800046e8:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800046ea:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800046ec:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800046f0:	21c48b93          	addi	s7,s1,540
    800046f4:	a81d                	j	8000472a <pipewrite+0x70>
      release(&pi->lock);
    800046f6:	8526                	mv	a0,s1
    800046f8:	dc8fc0ef          	jal	80000cc0 <release>
      return -1;
    800046fc:	597d                	li	s2,-1
    800046fe:	7b02                	ld	s6,32(sp)
    80004700:	6be2                	ld	s7,24(sp)
    80004702:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004704:	854a                	mv	a0,s2
    80004706:	60e6                	ld	ra,88(sp)
    80004708:	6446                	ld	s0,80(sp)
    8000470a:	64a6                	ld	s1,72(sp)
    8000470c:	6906                	ld	s2,64(sp)
    8000470e:	79e2                	ld	s3,56(sp)
    80004710:	7a42                	ld	s4,48(sp)
    80004712:	7aa2                	ld	s5,40(sp)
    80004714:	6125                	addi	sp,sp,96
    80004716:	8082                	ret
      wakeup(&pi->nread);
    80004718:	8562                	mv	a0,s8
    8000471a:	815fd0ef          	jal	80001f2e <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000471e:	85a6                	mv	a1,s1
    80004720:	855e                	mv	a0,s7
    80004722:	fc0fd0ef          	jal	80001ee2 <sleep>
  while(i < n){
    80004726:	05495b63          	bge	s2,s4,8000477c <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    8000472a:	2204a783          	lw	a5,544(s1)
    8000472e:	d7e1                	beqz	a5,800046f6 <pipewrite+0x3c>
    80004730:	854e                	mv	a0,s3
    80004732:	9e9fd0ef          	jal	8000211a <killed>
    80004736:	f161                	bnez	a0,800046f6 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004738:	2184a783          	lw	a5,536(s1)
    8000473c:	21c4a703          	lw	a4,540(s1)
    80004740:	2007879b          	addiw	a5,a5,512
    80004744:	fcf70ae3          	beq	a4,a5,80004718 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004748:	4685                	li	a3,1
    8000474a:	01590633          	add	a2,s2,s5
    8000474e:	faf40593          	addi	a1,s0,-81
    80004752:	0509b503          	ld	a0,80(s3)
    80004756:	f07fc0ef          	jal	8000165c <copyin>
    8000475a:	03650e63          	beq	a0,s6,80004796 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000475e:	21c4a783          	lw	a5,540(s1)
    80004762:	0017871b          	addiw	a4,a5,1
    80004766:	20e4ae23          	sw	a4,540(s1)
    8000476a:	1ff7f793          	andi	a5,a5,511
    8000476e:	97a6                	add	a5,a5,s1
    80004770:	faf44703          	lbu	a4,-81(s0)
    80004774:	00e78c23          	sb	a4,24(a5)
      i++;
    80004778:	2905                	addiw	s2,s2,1
    8000477a:	b775                	j	80004726 <pipewrite+0x6c>
    8000477c:	7b02                	ld	s6,32(sp)
    8000477e:	6be2                	ld	s7,24(sp)
    80004780:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004782:	21848513          	addi	a0,s1,536
    80004786:	fa8fd0ef          	jal	80001f2e <wakeup>
  release(&pi->lock);
    8000478a:	8526                	mv	a0,s1
    8000478c:	d34fc0ef          	jal	80000cc0 <release>
  return i;
    80004790:	bf95                	j	80004704 <pipewrite+0x4a>
  int i = 0;
    80004792:	4901                	li	s2,0
    80004794:	b7fd                	j	80004782 <pipewrite+0xc8>
    80004796:	7b02                	ld	s6,32(sp)
    80004798:	6be2                	ld	s7,24(sp)
    8000479a:	6c42                	ld	s8,16(sp)
    8000479c:	b7dd                	j	80004782 <pipewrite+0xc8>

000000008000479e <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000479e:	715d                	addi	sp,sp,-80
    800047a0:	e486                	sd	ra,72(sp)
    800047a2:	e0a2                	sd	s0,64(sp)
    800047a4:	fc26                	sd	s1,56(sp)
    800047a6:	f84a                	sd	s2,48(sp)
    800047a8:	f44e                	sd	s3,40(sp)
    800047aa:	f052                	sd	s4,32(sp)
    800047ac:	ec56                	sd	s5,24(sp)
    800047ae:	0880                	addi	s0,sp,80
    800047b0:	84aa                	mv	s1,a0
    800047b2:	892e                	mv	s2,a1
    800047b4:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800047b6:	95efd0ef          	jal	80001914 <myproc>
    800047ba:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800047bc:	8526                	mv	a0,s1
    800047be:	c6afc0ef          	jal	80000c28 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800047c2:	2184a703          	lw	a4,536(s1)
    800047c6:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800047ca:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800047ce:	02f71563          	bne	a4,a5,800047f8 <piperead+0x5a>
    800047d2:	2244a783          	lw	a5,548(s1)
    800047d6:	cb85                	beqz	a5,80004806 <piperead+0x68>
    if(killed(pr)){
    800047d8:	8552                	mv	a0,s4
    800047da:	941fd0ef          	jal	8000211a <killed>
    800047de:	ed19                	bnez	a0,800047fc <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800047e0:	85a6                	mv	a1,s1
    800047e2:	854e                	mv	a0,s3
    800047e4:	efefd0ef          	jal	80001ee2 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800047e8:	2184a703          	lw	a4,536(s1)
    800047ec:	21c4a783          	lw	a5,540(s1)
    800047f0:	fef701e3          	beq	a4,a5,800047d2 <piperead+0x34>
    800047f4:	e85a                	sd	s6,16(sp)
    800047f6:	a809                	j	80004808 <piperead+0x6a>
    800047f8:	e85a                	sd	s6,16(sp)
    800047fa:	a039                	j	80004808 <piperead+0x6a>
      release(&pi->lock);
    800047fc:	8526                	mv	a0,s1
    800047fe:	cc2fc0ef          	jal	80000cc0 <release>
      return -1;
    80004802:	59fd                	li	s3,-1
    80004804:	a8b1                	j	80004860 <piperead+0xc2>
    80004806:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004808:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000480a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000480c:	05505263          	blez	s5,80004850 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004810:	2184a783          	lw	a5,536(s1)
    80004814:	21c4a703          	lw	a4,540(s1)
    80004818:	02f70c63          	beq	a4,a5,80004850 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000481c:	0017871b          	addiw	a4,a5,1
    80004820:	20e4ac23          	sw	a4,536(s1)
    80004824:	1ff7f793          	andi	a5,a5,511
    80004828:	97a6                	add	a5,a5,s1
    8000482a:	0187c783          	lbu	a5,24(a5)
    8000482e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004832:	4685                	li	a3,1
    80004834:	fbf40613          	addi	a2,s0,-65
    80004838:	85ca                	mv	a1,s2
    8000483a:	050a3503          	ld	a0,80(s4)
    8000483e:	d49fc0ef          	jal	80001586 <copyout>
    80004842:	01650763          	beq	a0,s6,80004850 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004846:	2985                	addiw	s3,s3,1
    80004848:	0905                	addi	s2,s2,1
    8000484a:	fd3a93e3          	bne	s5,s3,80004810 <piperead+0x72>
    8000484e:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004850:	21c48513          	addi	a0,s1,540
    80004854:	edafd0ef          	jal	80001f2e <wakeup>
  release(&pi->lock);
    80004858:	8526                	mv	a0,s1
    8000485a:	c66fc0ef          	jal	80000cc0 <release>
    8000485e:	6b42                	ld	s6,16(sp)
  return i;
}
    80004860:	854e                	mv	a0,s3
    80004862:	60a6                	ld	ra,72(sp)
    80004864:	6406                	ld	s0,64(sp)
    80004866:	74e2                	ld	s1,56(sp)
    80004868:	7942                	ld	s2,48(sp)
    8000486a:	79a2                	ld	s3,40(sp)
    8000486c:	7a02                	ld	s4,32(sp)
    8000486e:	6ae2                	ld	s5,24(sp)
    80004870:	6161                	addi	sp,sp,80
    80004872:	8082                	ret

0000000080004874 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004874:	1141                	addi	sp,sp,-16
    80004876:	e422                	sd	s0,8(sp)
    80004878:	0800                	addi	s0,sp,16
    8000487a:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000487c:	8905                	andi	a0,a0,1
    8000487e:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004880:	8b89                	andi	a5,a5,2
    80004882:	c399                	beqz	a5,80004888 <flags2perm+0x14>
      perm |= PTE_W;
    80004884:	00456513          	ori	a0,a0,4
    return perm;
}
    80004888:	6422                	ld	s0,8(sp)
    8000488a:	0141                	addi	sp,sp,16
    8000488c:	8082                	ret

000000008000488e <exec>:

int
exec(char *path, char **argv)
{
    8000488e:	df010113          	addi	sp,sp,-528
    80004892:	20113423          	sd	ra,520(sp)
    80004896:	20813023          	sd	s0,512(sp)
    8000489a:	ffa6                	sd	s1,504(sp)
    8000489c:	fbca                	sd	s2,496(sp)
    8000489e:	0c00                	addi	s0,sp,528
    800048a0:	892a                	mv	s2,a0
    800048a2:	dea43c23          	sd	a0,-520(s0)
    800048a6:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800048aa:	86afd0ef          	jal	80001914 <myproc>
    800048ae:	84aa                	mv	s1,a0

  begin_op();
    800048b0:	dc6ff0ef          	jal	80003e76 <begin_op>

  if((ip = namei(path)) == 0){
    800048b4:	854a                	mv	a0,s2
    800048b6:	c04ff0ef          	jal	80003cba <namei>
    800048ba:	c931                	beqz	a0,8000490e <exec+0x80>
    800048bc:	f3d2                	sd	s4,480(sp)
    800048be:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800048c0:	d21fe0ef          	jal	800035e0 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800048c4:	04000713          	li	a4,64
    800048c8:	4681                	li	a3,0
    800048ca:	e5040613          	addi	a2,s0,-432
    800048ce:	4581                	li	a1,0
    800048d0:	8552                	mv	a0,s4
    800048d2:	f63fe0ef          	jal	80003834 <readi>
    800048d6:	04000793          	li	a5,64
    800048da:	00f51a63          	bne	a0,a5,800048ee <exec+0x60>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800048de:	e5042703          	lw	a4,-432(s0)
    800048e2:	464c47b7          	lui	a5,0x464c4
    800048e6:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800048ea:	02f70663          	beq	a4,a5,80004916 <exec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800048ee:	8552                	mv	a0,s4
    800048f0:	efbfe0ef          	jal	800037ea <iunlockput>
    end_op();
    800048f4:	decff0ef          	jal	80003ee0 <end_op>
  }
  return -1;
    800048f8:	557d                	li	a0,-1
    800048fa:	7a1e                	ld	s4,480(sp)
}
    800048fc:	20813083          	ld	ra,520(sp)
    80004900:	20013403          	ld	s0,512(sp)
    80004904:	74fe                	ld	s1,504(sp)
    80004906:	795e                	ld	s2,496(sp)
    80004908:	21010113          	addi	sp,sp,528
    8000490c:	8082                	ret
    end_op();
    8000490e:	dd2ff0ef          	jal	80003ee0 <end_op>
    return -1;
    80004912:	557d                	li	a0,-1
    80004914:	b7e5                	j	800048fc <exec+0x6e>
    80004916:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004918:	8526                	mv	a0,s1
    8000491a:	8a2fd0ef          	jal	800019bc <proc_pagetable>
    8000491e:	8b2a                	mv	s6,a0
    80004920:	2c050b63          	beqz	a0,80004bf6 <exec+0x368>
    80004924:	f7ce                	sd	s3,488(sp)
    80004926:	efd6                	sd	s5,472(sp)
    80004928:	e7de                	sd	s7,456(sp)
    8000492a:	e3e2                	sd	s8,448(sp)
    8000492c:	ff66                	sd	s9,440(sp)
    8000492e:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004930:	e7042d03          	lw	s10,-400(s0)
    80004934:	e8845783          	lhu	a5,-376(s0)
    80004938:	12078963          	beqz	a5,80004a6a <exec+0x1dc>
    8000493c:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000493e:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004940:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004942:	6c85                	lui	s9,0x1
    80004944:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004948:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    8000494c:	6a85                	lui	s5,0x1
    8000494e:	a085                	j	800049ae <exec+0x120>
      panic("loadseg: address should exist");
    80004950:	00003517          	auipc	a0,0x3
    80004954:	cc850513          	addi	a0,a0,-824 # 80007618 <etext+0x618>
    80004958:	e71fb0ef          	jal	800007c8 <panic>
    if(sz - i < PGSIZE)
    8000495c:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000495e:	8726                	mv	a4,s1
    80004960:	012c06bb          	addw	a3,s8,s2
    80004964:	4581                	li	a1,0
    80004966:	8552                	mv	a0,s4
    80004968:	ecdfe0ef          	jal	80003834 <readi>
    8000496c:	2501                	sext.w	a0,a0
    8000496e:	24a49a63          	bne	s1,a0,80004bc2 <exec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80004972:	012a893b          	addw	s2,s5,s2
    80004976:	03397363          	bgeu	s2,s3,8000499c <exec+0x10e>
    pa = walkaddr(pagetable, va + i);
    8000497a:	02091593          	slli	a1,s2,0x20
    8000497e:	9181                	srli	a1,a1,0x20
    80004980:	95de                	add	a1,a1,s7
    80004982:	855a                	mv	a0,s6
    80004984:	e86fc0ef          	jal	8000100a <walkaddr>
    80004988:	862a                	mv	a2,a0
    if(pa == 0)
    8000498a:	d179                	beqz	a0,80004950 <exec+0xc2>
    if(sz - i < PGSIZE)
    8000498c:	412984bb          	subw	s1,s3,s2
    80004990:	0004879b          	sext.w	a5,s1
    80004994:	fcfcf4e3          	bgeu	s9,a5,8000495c <exec+0xce>
    80004998:	84d6                	mv	s1,s5
    8000499a:	b7c9                	j	8000495c <exec+0xce>
    sz = sz1;
    8000499c:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800049a0:	2d85                	addiw	s11,s11,1
    800049a2:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    800049a6:	e8845783          	lhu	a5,-376(s0)
    800049aa:	08fdd063          	bge	s11,a5,80004a2a <exec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800049ae:	2d01                	sext.w	s10,s10
    800049b0:	03800713          	li	a4,56
    800049b4:	86ea                	mv	a3,s10
    800049b6:	e1840613          	addi	a2,s0,-488
    800049ba:	4581                	li	a1,0
    800049bc:	8552                	mv	a0,s4
    800049be:	e77fe0ef          	jal	80003834 <readi>
    800049c2:	03800793          	li	a5,56
    800049c6:	1cf51663          	bne	a0,a5,80004b92 <exec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    800049ca:	e1842783          	lw	a5,-488(s0)
    800049ce:	4705                	li	a4,1
    800049d0:	fce798e3          	bne	a5,a4,800049a0 <exec+0x112>
    if(ph.memsz < ph.filesz)
    800049d4:	e4043483          	ld	s1,-448(s0)
    800049d8:	e3843783          	ld	a5,-456(s0)
    800049dc:	1af4ef63          	bltu	s1,a5,80004b9a <exec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800049e0:	e2843783          	ld	a5,-472(s0)
    800049e4:	94be                	add	s1,s1,a5
    800049e6:	1af4ee63          	bltu	s1,a5,80004ba2 <exec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    800049ea:	df043703          	ld	a4,-528(s0)
    800049ee:	8ff9                	and	a5,a5,a4
    800049f0:	1a079d63          	bnez	a5,80004baa <exec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800049f4:	e1c42503          	lw	a0,-484(s0)
    800049f8:	e7dff0ef          	jal	80004874 <flags2perm>
    800049fc:	86aa                	mv	a3,a0
    800049fe:	8626                	mv	a2,s1
    80004a00:	85ca                	mv	a1,s2
    80004a02:	855a                	mv	a0,s6
    80004a04:	96ffc0ef          	jal	80001372 <uvmalloc>
    80004a08:	e0a43423          	sd	a0,-504(s0)
    80004a0c:	1a050363          	beqz	a0,80004bb2 <exec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004a10:	e2843b83          	ld	s7,-472(s0)
    80004a14:	e2042c03          	lw	s8,-480(s0)
    80004a18:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004a1c:	00098463          	beqz	s3,80004a24 <exec+0x196>
    80004a20:	4901                	li	s2,0
    80004a22:	bfa1                	j	8000497a <exec+0xec>
    sz = sz1;
    80004a24:	e0843903          	ld	s2,-504(s0)
    80004a28:	bfa5                	j	800049a0 <exec+0x112>
    80004a2a:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80004a2c:	8552                	mv	a0,s4
    80004a2e:	dbdfe0ef          	jal	800037ea <iunlockput>
  end_op();
    80004a32:	caeff0ef          	jal	80003ee0 <end_op>
  p = myproc();
    80004a36:	edffc0ef          	jal	80001914 <myproc>
    80004a3a:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004a3c:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004a40:	6985                	lui	s3,0x1
    80004a42:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004a44:	99ca                	add	s3,s3,s2
    80004a46:	77fd                	lui	a5,0xfffff
    80004a48:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004a4c:	4691                	li	a3,4
    80004a4e:	6609                	lui	a2,0x2
    80004a50:	964e                	add	a2,a2,s3
    80004a52:	85ce                	mv	a1,s3
    80004a54:	855a                	mv	a0,s6
    80004a56:	91dfc0ef          	jal	80001372 <uvmalloc>
    80004a5a:	892a                	mv	s2,a0
    80004a5c:	e0a43423          	sd	a0,-504(s0)
    80004a60:	e519                	bnez	a0,80004a6e <exec+0x1e0>
  if(pagetable)
    80004a62:	e1343423          	sd	s3,-504(s0)
    80004a66:	4a01                	li	s4,0
    80004a68:	aab1                	j	80004bc4 <exec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004a6a:	4901                	li	s2,0
    80004a6c:	b7c1                	j	80004a2c <exec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004a6e:	75f9                	lui	a1,0xffffe
    80004a70:	95aa                	add	a1,a1,a0
    80004a72:	855a                	mv	a0,s6
    80004a74:	ae9fc0ef          	jal	8000155c <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004a78:	7bfd                	lui	s7,0xfffff
    80004a7a:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004a7c:	e0043783          	ld	a5,-512(s0)
    80004a80:	6388                	ld	a0,0(a5)
    80004a82:	cd39                	beqz	a0,80004ae0 <exec+0x252>
    80004a84:	e9040993          	addi	s3,s0,-368
    80004a88:	f9040c13          	addi	s8,s0,-112
    80004a8c:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004a8e:	bdefc0ef          	jal	80000e6c <strlen>
    80004a92:	0015079b          	addiw	a5,a0,1
    80004a96:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004a9a:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004a9e:	11796e63          	bltu	s2,s7,80004bba <exec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004aa2:	e0043d03          	ld	s10,-512(s0)
    80004aa6:	000d3a03          	ld	s4,0(s10)
    80004aaa:	8552                	mv	a0,s4
    80004aac:	bc0fc0ef          	jal	80000e6c <strlen>
    80004ab0:	0015069b          	addiw	a3,a0,1
    80004ab4:	8652                	mv	a2,s4
    80004ab6:	85ca                	mv	a1,s2
    80004ab8:	855a                	mv	a0,s6
    80004aba:	acdfc0ef          	jal	80001586 <copyout>
    80004abe:	10054063          	bltz	a0,80004bbe <exec+0x330>
    ustack[argc] = sp;
    80004ac2:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004ac6:	0485                	addi	s1,s1,1
    80004ac8:	008d0793          	addi	a5,s10,8
    80004acc:	e0f43023          	sd	a5,-512(s0)
    80004ad0:	008d3503          	ld	a0,8(s10)
    80004ad4:	c909                	beqz	a0,80004ae6 <exec+0x258>
    if(argc >= MAXARG)
    80004ad6:	09a1                	addi	s3,s3,8
    80004ad8:	fb899be3          	bne	s3,s8,80004a8e <exec+0x200>
  ip = 0;
    80004adc:	4a01                	li	s4,0
    80004ade:	a0dd                	j	80004bc4 <exec+0x336>
  sp = sz;
    80004ae0:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004ae4:	4481                	li	s1,0
  ustack[argc] = 0;
    80004ae6:	00349793          	slli	a5,s1,0x3
    80004aea:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdb7d0>
    80004aee:	97a2                	add	a5,a5,s0
    80004af0:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004af4:	00148693          	addi	a3,s1,1
    80004af8:	068e                	slli	a3,a3,0x3
    80004afa:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004afe:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004b02:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004b06:	f5796ee3          	bltu	s2,s7,80004a62 <exec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004b0a:	e9040613          	addi	a2,s0,-368
    80004b0e:	85ca                	mv	a1,s2
    80004b10:	855a                	mv	a0,s6
    80004b12:	a75fc0ef          	jal	80001586 <copyout>
    80004b16:	0e054263          	bltz	a0,80004bfa <exec+0x36c>
  p->trapframe->a1 = sp;
    80004b1a:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004b1e:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004b22:	df843783          	ld	a5,-520(s0)
    80004b26:	0007c703          	lbu	a4,0(a5)
    80004b2a:	cf11                	beqz	a4,80004b46 <exec+0x2b8>
    80004b2c:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004b2e:	02f00693          	li	a3,47
    80004b32:	a039                	j	80004b40 <exec+0x2b2>
      last = s+1;
    80004b34:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004b38:	0785                	addi	a5,a5,1
    80004b3a:	fff7c703          	lbu	a4,-1(a5)
    80004b3e:	c701                	beqz	a4,80004b46 <exec+0x2b8>
    if(*s == '/')
    80004b40:	fed71ce3          	bne	a4,a3,80004b38 <exec+0x2aa>
    80004b44:	bfc5                	j	80004b34 <exec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80004b46:	4641                	li	a2,16
    80004b48:	df843583          	ld	a1,-520(s0)
    80004b4c:	158a8513          	addi	a0,s5,344
    80004b50:	aeafc0ef          	jal	80000e3a <safestrcpy>
  oldpagetable = p->pagetable;
    80004b54:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004b58:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004b5c:	e0843783          	ld	a5,-504(s0)
    80004b60:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004b64:	058ab783          	ld	a5,88(s5)
    80004b68:	e6843703          	ld	a4,-408(s0)
    80004b6c:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004b6e:	058ab783          	ld	a5,88(s5)
    80004b72:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004b76:	85e6                	mv	a1,s9
    80004b78:	ec9fc0ef          	jal	80001a40 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004b7c:	0004851b          	sext.w	a0,s1
    80004b80:	79be                	ld	s3,488(sp)
    80004b82:	7a1e                	ld	s4,480(sp)
    80004b84:	6afe                	ld	s5,472(sp)
    80004b86:	6b5e                	ld	s6,464(sp)
    80004b88:	6bbe                	ld	s7,456(sp)
    80004b8a:	6c1e                	ld	s8,448(sp)
    80004b8c:	7cfa                	ld	s9,440(sp)
    80004b8e:	7d5a                	ld	s10,432(sp)
    80004b90:	b3b5                	j	800048fc <exec+0x6e>
    80004b92:	e1243423          	sd	s2,-504(s0)
    80004b96:	7dba                	ld	s11,424(sp)
    80004b98:	a035                	j	80004bc4 <exec+0x336>
    80004b9a:	e1243423          	sd	s2,-504(s0)
    80004b9e:	7dba                	ld	s11,424(sp)
    80004ba0:	a015                	j	80004bc4 <exec+0x336>
    80004ba2:	e1243423          	sd	s2,-504(s0)
    80004ba6:	7dba                	ld	s11,424(sp)
    80004ba8:	a831                	j	80004bc4 <exec+0x336>
    80004baa:	e1243423          	sd	s2,-504(s0)
    80004bae:	7dba                	ld	s11,424(sp)
    80004bb0:	a811                	j	80004bc4 <exec+0x336>
    80004bb2:	e1243423          	sd	s2,-504(s0)
    80004bb6:	7dba                	ld	s11,424(sp)
    80004bb8:	a031                	j	80004bc4 <exec+0x336>
  ip = 0;
    80004bba:	4a01                	li	s4,0
    80004bbc:	a021                	j	80004bc4 <exec+0x336>
    80004bbe:	4a01                	li	s4,0
  if(pagetable)
    80004bc0:	a011                	j	80004bc4 <exec+0x336>
    80004bc2:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004bc4:	e0843583          	ld	a1,-504(s0)
    80004bc8:	855a                	mv	a0,s6
    80004bca:	e77fc0ef          	jal	80001a40 <proc_freepagetable>
  return -1;
    80004bce:	557d                	li	a0,-1
  if(ip){
    80004bd0:	000a1b63          	bnez	s4,80004be6 <exec+0x358>
    80004bd4:	79be                	ld	s3,488(sp)
    80004bd6:	7a1e                	ld	s4,480(sp)
    80004bd8:	6afe                	ld	s5,472(sp)
    80004bda:	6b5e                	ld	s6,464(sp)
    80004bdc:	6bbe                	ld	s7,456(sp)
    80004bde:	6c1e                	ld	s8,448(sp)
    80004be0:	7cfa                	ld	s9,440(sp)
    80004be2:	7d5a                	ld	s10,432(sp)
    80004be4:	bb21                	j	800048fc <exec+0x6e>
    80004be6:	79be                	ld	s3,488(sp)
    80004be8:	6afe                	ld	s5,472(sp)
    80004bea:	6b5e                	ld	s6,464(sp)
    80004bec:	6bbe                	ld	s7,456(sp)
    80004bee:	6c1e                	ld	s8,448(sp)
    80004bf0:	7cfa                	ld	s9,440(sp)
    80004bf2:	7d5a                	ld	s10,432(sp)
    80004bf4:	b9ed                	j	800048ee <exec+0x60>
    80004bf6:	6b5e                	ld	s6,464(sp)
    80004bf8:	b9dd                	j	800048ee <exec+0x60>
  sz = sz1;
    80004bfa:	e0843983          	ld	s3,-504(s0)
    80004bfe:	b595                	j	80004a62 <exec+0x1d4>

0000000080004c00 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004c00:	7179                	addi	sp,sp,-48
    80004c02:	f406                	sd	ra,40(sp)
    80004c04:	f022                	sd	s0,32(sp)
    80004c06:	ec26                	sd	s1,24(sp)
    80004c08:	e84a                	sd	s2,16(sp)
    80004c0a:	1800                	addi	s0,sp,48
    80004c0c:	892e                	mv	s2,a1
    80004c0e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004c10:	fdc40593          	addi	a1,s0,-36
    80004c14:	dc3fd0ef          	jal	800029d6 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004c18:	fdc42703          	lw	a4,-36(s0)
    80004c1c:	47bd                	li	a5,15
    80004c1e:	02e7e963          	bltu	a5,a4,80004c50 <argfd+0x50>
    80004c22:	cf3fc0ef          	jal	80001914 <myproc>
    80004c26:	fdc42703          	lw	a4,-36(s0)
    80004c2a:	01a70793          	addi	a5,a4,26
    80004c2e:	078e                	slli	a5,a5,0x3
    80004c30:	953e                	add	a0,a0,a5
    80004c32:	611c                	ld	a5,0(a0)
    80004c34:	c385                	beqz	a5,80004c54 <argfd+0x54>
    return -1;
  if(pfd)
    80004c36:	00090463          	beqz	s2,80004c3e <argfd+0x3e>
    *pfd = fd;
    80004c3a:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004c3e:	4501                	li	a0,0
  if(pf)
    80004c40:	c091                	beqz	s1,80004c44 <argfd+0x44>
    *pf = f;
    80004c42:	e09c                	sd	a5,0(s1)
}
    80004c44:	70a2                	ld	ra,40(sp)
    80004c46:	7402                	ld	s0,32(sp)
    80004c48:	64e2                	ld	s1,24(sp)
    80004c4a:	6942                	ld	s2,16(sp)
    80004c4c:	6145                	addi	sp,sp,48
    80004c4e:	8082                	ret
    return -1;
    80004c50:	557d                	li	a0,-1
    80004c52:	bfcd                	j	80004c44 <argfd+0x44>
    80004c54:	557d                	li	a0,-1
    80004c56:	b7fd                	j	80004c44 <argfd+0x44>

0000000080004c58 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004c58:	1101                	addi	sp,sp,-32
    80004c5a:	ec06                	sd	ra,24(sp)
    80004c5c:	e822                	sd	s0,16(sp)
    80004c5e:	e426                	sd	s1,8(sp)
    80004c60:	1000                	addi	s0,sp,32
    80004c62:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004c64:	cb1fc0ef          	jal	80001914 <myproc>
    80004c68:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004c6a:	0d050793          	addi	a5,a0,208
    80004c6e:	4501                	li	a0,0
    80004c70:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004c72:	6398                	ld	a4,0(a5)
    80004c74:	cb19                	beqz	a4,80004c8a <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004c76:	2505                	addiw	a0,a0,1
    80004c78:	07a1                	addi	a5,a5,8
    80004c7a:	fed51ce3          	bne	a0,a3,80004c72 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004c7e:	557d                	li	a0,-1
}
    80004c80:	60e2                	ld	ra,24(sp)
    80004c82:	6442                	ld	s0,16(sp)
    80004c84:	64a2                	ld	s1,8(sp)
    80004c86:	6105                	addi	sp,sp,32
    80004c88:	8082                	ret
      p->ofile[fd] = f;
    80004c8a:	01a50793          	addi	a5,a0,26
    80004c8e:	078e                	slli	a5,a5,0x3
    80004c90:	963e                	add	a2,a2,a5
    80004c92:	e204                	sd	s1,0(a2)
      return fd;
    80004c94:	b7f5                	j	80004c80 <fdalloc+0x28>

0000000080004c96 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004c96:	715d                	addi	sp,sp,-80
    80004c98:	e486                	sd	ra,72(sp)
    80004c9a:	e0a2                	sd	s0,64(sp)
    80004c9c:	fc26                	sd	s1,56(sp)
    80004c9e:	f84a                	sd	s2,48(sp)
    80004ca0:	f44e                	sd	s3,40(sp)
    80004ca2:	ec56                	sd	s5,24(sp)
    80004ca4:	e85a                	sd	s6,16(sp)
    80004ca6:	0880                	addi	s0,sp,80
    80004ca8:	8b2e                	mv	s6,a1
    80004caa:	89b2                	mv	s3,a2
    80004cac:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004cae:	fb040593          	addi	a1,s0,-80
    80004cb2:	822ff0ef          	jal	80003cd4 <nameiparent>
    80004cb6:	84aa                	mv	s1,a0
    80004cb8:	10050a63          	beqz	a0,80004dcc <create+0x136>
    return 0;

  ilock(dp);
    80004cbc:	925fe0ef          	jal	800035e0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004cc0:	4601                	li	a2,0
    80004cc2:	fb040593          	addi	a1,s0,-80
    80004cc6:	8526                	mv	a0,s1
    80004cc8:	d8dfe0ef          	jal	80003a54 <dirlookup>
    80004ccc:	8aaa                	mv	s5,a0
    80004cce:	c129                	beqz	a0,80004d10 <create+0x7a>
    iunlockput(dp);
    80004cd0:	8526                	mv	a0,s1
    80004cd2:	b19fe0ef          	jal	800037ea <iunlockput>
    ilock(ip);
    80004cd6:	8556                	mv	a0,s5
    80004cd8:	909fe0ef          	jal	800035e0 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004cdc:	4789                	li	a5,2
    80004cde:	02fb1463          	bne	s6,a5,80004d06 <create+0x70>
    80004ce2:	044ad783          	lhu	a5,68(s5)
    80004ce6:	37f9                	addiw	a5,a5,-2
    80004ce8:	17c2                	slli	a5,a5,0x30
    80004cea:	93c1                	srli	a5,a5,0x30
    80004cec:	4705                	li	a4,1
    80004cee:	00f76c63          	bltu	a4,a5,80004d06 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004cf2:	8556                	mv	a0,s5
    80004cf4:	60a6                	ld	ra,72(sp)
    80004cf6:	6406                	ld	s0,64(sp)
    80004cf8:	74e2                	ld	s1,56(sp)
    80004cfa:	7942                	ld	s2,48(sp)
    80004cfc:	79a2                	ld	s3,40(sp)
    80004cfe:	6ae2                	ld	s5,24(sp)
    80004d00:	6b42                	ld	s6,16(sp)
    80004d02:	6161                	addi	sp,sp,80
    80004d04:	8082                	ret
    iunlockput(ip);
    80004d06:	8556                	mv	a0,s5
    80004d08:	ae3fe0ef          	jal	800037ea <iunlockput>
    return 0;
    80004d0c:	4a81                	li	s5,0
    80004d0e:	b7d5                	j	80004cf2 <create+0x5c>
    80004d10:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004d12:	85da                	mv	a1,s6
    80004d14:	4088                	lw	a0,0(s1)
    80004d16:	f5afe0ef          	jal	80003470 <ialloc>
    80004d1a:	8a2a                	mv	s4,a0
    80004d1c:	cd15                	beqz	a0,80004d58 <create+0xc2>
  ilock(ip);
    80004d1e:	8c3fe0ef          	jal	800035e0 <ilock>
  ip->major = major;
    80004d22:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004d26:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004d2a:	4905                	li	s2,1
    80004d2c:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004d30:	8552                	mv	a0,s4
    80004d32:	ffafe0ef          	jal	8000352c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004d36:	032b0763          	beq	s6,s2,80004d64 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004d3a:	004a2603          	lw	a2,4(s4)
    80004d3e:	fb040593          	addi	a1,s0,-80
    80004d42:	8526                	mv	a0,s1
    80004d44:	eddfe0ef          	jal	80003c20 <dirlink>
    80004d48:	06054563          	bltz	a0,80004db2 <create+0x11c>
  iunlockput(dp);
    80004d4c:	8526                	mv	a0,s1
    80004d4e:	a9dfe0ef          	jal	800037ea <iunlockput>
  return ip;
    80004d52:	8ad2                	mv	s5,s4
    80004d54:	7a02                	ld	s4,32(sp)
    80004d56:	bf71                	j	80004cf2 <create+0x5c>
    iunlockput(dp);
    80004d58:	8526                	mv	a0,s1
    80004d5a:	a91fe0ef          	jal	800037ea <iunlockput>
    return 0;
    80004d5e:	8ad2                	mv	s5,s4
    80004d60:	7a02                	ld	s4,32(sp)
    80004d62:	bf41                	j	80004cf2 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004d64:	004a2603          	lw	a2,4(s4)
    80004d68:	00003597          	auipc	a1,0x3
    80004d6c:	8d058593          	addi	a1,a1,-1840 # 80007638 <etext+0x638>
    80004d70:	8552                	mv	a0,s4
    80004d72:	eaffe0ef          	jal	80003c20 <dirlink>
    80004d76:	02054e63          	bltz	a0,80004db2 <create+0x11c>
    80004d7a:	40d0                	lw	a2,4(s1)
    80004d7c:	00003597          	auipc	a1,0x3
    80004d80:	8c458593          	addi	a1,a1,-1852 # 80007640 <etext+0x640>
    80004d84:	8552                	mv	a0,s4
    80004d86:	e9bfe0ef          	jal	80003c20 <dirlink>
    80004d8a:	02054463          	bltz	a0,80004db2 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004d8e:	004a2603          	lw	a2,4(s4)
    80004d92:	fb040593          	addi	a1,s0,-80
    80004d96:	8526                	mv	a0,s1
    80004d98:	e89fe0ef          	jal	80003c20 <dirlink>
    80004d9c:	00054b63          	bltz	a0,80004db2 <create+0x11c>
    dp->nlink++;  // for ".."
    80004da0:	04a4d783          	lhu	a5,74(s1)
    80004da4:	2785                	addiw	a5,a5,1
    80004da6:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004daa:	8526                	mv	a0,s1
    80004dac:	f80fe0ef          	jal	8000352c <iupdate>
    80004db0:	bf71                	j	80004d4c <create+0xb6>
  ip->nlink = 0;
    80004db2:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004db6:	8552                	mv	a0,s4
    80004db8:	f74fe0ef          	jal	8000352c <iupdate>
  iunlockput(ip);
    80004dbc:	8552                	mv	a0,s4
    80004dbe:	a2dfe0ef          	jal	800037ea <iunlockput>
  iunlockput(dp);
    80004dc2:	8526                	mv	a0,s1
    80004dc4:	a27fe0ef          	jal	800037ea <iunlockput>
  return 0;
    80004dc8:	7a02                	ld	s4,32(sp)
    80004dca:	b725                	j	80004cf2 <create+0x5c>
    return 0;
    80004dcc:	8aaa                	mv	s5,a0
    80004dce:	b715                	j	80004cf2 <create+0x5c>

0000000080004dd0 <sys_dup>:
{
    80004dd0:	7179                	addi	sp,sp,-48
    80004dd2:	f406                	sd	ra,40(sp)
    80004dd4:	f022                	sd	s0,32(sp)
    80004dd6:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004dd8:	fd840613          	addi	a2,s0,-40
    80004ddc:	4581                	li	a1,0
    80004dde:	4501                	li	a0,0
    80004de0:	e21ff0ef          	jal	80004c00 <argfd>
    return -1;
    80004de4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004de6:	02054363          	bltz	a0,80004e0c <sys_dup+0x3c>
    80004dea:	ec26                	sd	s1,24(sp)
    80004dec:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004dee:	fd843903          	ld	s2,-40(s0)
    80004df2:	854a                	mv	a0,s2
    80004df4:	e65ff0ef          	jal	80004c58 <fdalloc>
    80004df8:	84aa                	mv	s1,a0
    return -1;
    80004dfa:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004dfc:	00054d63          	bltz	a0,80004e16 <sys_dup+0x46>
  filedup(f);
    80004e00:	854a                	mv	a0,s2
    80004e02:	c48ff0ef          	jal	8000424a <filedup>
  return fd;
    80004e06:	87a6                	mv	a5,s1
    80004e08:	64e2                	ld	s1,24(sp)
    80004e0a:	6942                	ld	s2,16(sp)
}
    80004e0c:	853e                	mv	a0,a5
    80004e0e:	70a2                	ld	ra,40(sp)
    80004e10:	7402                	ld	s0,32(sp)
    80004e12:	6145                	addi	sp,sp,48
    80004e14:	8082                	ret
    80004e16:	64e2                	ld	s1,24(sp)
    80004e18:	6942                	ld	s2,16(sp)
    80004e1a:	bfcd                	j	80004e0c <sys_dup+0x3c>

0000000080004e1c <sys_read>:
{
    80004e1c:	7179                	addi	sp,sp,-48
    80004e1e:	f406                	sd	ra,40(sp)
    80004e20:	f022                	sd	s0,32(sp)
    80004e22:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004e24:	fd840593          	addi	a1,s0,-40
    80004e28:	4505                	li	a0,1
    80004e2a:	bc9fd0ef          	jal	800029f2 <argaddr>
  argint(2, &n);
    80004e2e:	fe440593          	addi	a1,s0,-28
    80004e32:	4509                	li	a0,2
    80004e34:	ba3fd0ef          	jal	800029d6 <argint>
  if(argfd(0, 0, &f) < 0)
    80004e38:	fe840613          	addi	a2,s0,-24
    80004e3c:	4581                	li	a1,0
    80004e3e:	4501                	li	a0,0
    80004e40:	dc1ff0ef          	jal	80004c00 <argfd>
    80004e44:	87aa                	mv	a5,a0
    return -1;
    80004e46:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004e48:	0007ca63          	bltz	a5,80004e5c <sys_read+0x40>
  return fileread(f, p, n);
    80004e4c:	fe442603          	lw	a2,-28(s0)
    80004e50:	fd843583          	ld	a1,-40(s0)
    80004e54:	fe843503          	ld	a0,-24(s0)
    80004e58:	d58ff0ef          	jal	800043b0 <fileread>
}
    80004e5c:	70a2                	ld	ra,40(sp)
    80004e5e:	7402                	ld	s0,32(sp)
    80004e60:	6145                	addi	sp,sp,48
    80004e62:	8082                	ret

0000000080004e64 <sys_write>:
{
    80004e64:	7179                	addi	sp,sp,-48
    80004e66:	f406                	sd	ra,40(sp)
    80004e68:	f022                	sd	s0,32(sp)
    80004e6a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004e6c:	fd840593          	addi	a1,s0,-40
    80004e70:	4505                	li	a0,1
    80004e72:	b81fd0ef          	jal	800029f2 <argaddr>
  argint(2, &n);
    80004e76:	fe440593          	addi	a1,s0,-28
    80004e7a:	4509                	li	a0,2
    80004e7c:	b5bfd0ef          	jal	800029d6 <argint>
  if(argfd(0, 0, &f) < 0)
    80004e80:	fe840613          	addi	a2,s0,-24
    80004e84:	4581                	li	a1,0
    80004e86:	4501                	li	a0,0
    80004e88:	d79ff0ef          	jal	80004c00 <argfd>
    80004e8c:	87aa                	mv	a5,a0
    return -1;
    80004e8e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004e90:	0007ca63          	bltz	a5,80004ea4 <sys_write+0x40>
  return filewrite(f, p, n);
    80004e94:	fe442603          	lw	a2,-28(s0)
    80004e98:	fd843583          	ld	a1,-40(s0)
    80004e9c:	fe843503          	ld	a0,-24(s0)
    80004ea0:	dceff0ef          	jal	8000446e <filewrite>
}
    80004ea4:	70a2                	ld	ra,40(sp)
    80004ea6:	7402                	ld	s0,32(sp)
    80004ea8:	6145                	addi	sp,sp,48
    80004eaa:	8082                	ret

0000000080004eac <sys_close>:
{
    80004eac:	1101                	addi	sp,sp,-32
    80004eae:	ec06                	sd	ra,24(sp)
    80004eb0:	e822                	sd	s0,16(sp)
    80004eb2:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004eb4:	fe040613          	addi	a2,s0,-32
    80004eb8:	fec40593          	addi	a1,s0,-20
    80004ebc:	4501                	li	a0,0
    80004ebe:	d43ff0ef          	jal	80004c00 <argfd>
    return -1;
    80004ec2:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004ec4:	02054063          	bltz	a0,80004ee4 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004ec8:	a4dfc0ef          	jal	80001914 <myproc>
    80004ecc:	fec42783          	lw	a5,-20(s0)
    80004ed0:	07e9                	addi	a5,a5,26
    80004ed2:	078e                	slli	a5,a5,0x3
    80004ed4:	953e                	add	a0,a0,a5
    80004ed6:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004eda:	fe043503          	ld	a0,-32(s0)
    80004ede:	bb2ff0ef          	jal	80004290 <fileclose>
  return 0;
    80004ee2:	4781                	li	a5,0
}
    80004ee4:	853e                	mv	a0,a5
    80004ee6:	60e2                	ld	ra,24(sp)
    80004ee8:	6442                	ld	s0,16(sp)
    80004eea:	6105                	addi	sp,sp,32
    80004eec:	8082                	ret

0000000080004eee <sys_fstat>:
{
    80004eee:	1101                	addi	sp,sp,-32
    80004ef0:	ec06                	sd	ra,24(sp)
    80004ef2:	e822                	sd	s0,16(sp)
    80004ef4:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004ef6:	fe040593          	addi	a1,s0,-32
    80004efa:	4505                	li	a0,1
    80004efc:	af7fd0ef          	jal	800029f2 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004f00:	fe840613          	addi	a2,s0,-24
    80004f04:	4581                	li	a1,0
    80004f06:	4501                	li	a0,0
    80004f08:	cf9ff0ef          	jal	80004c00 <argfd>
    80004f0c:	87aa                	mv	a5,a0
    return -1;
    80004f0e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004f10:	0007c863          	bltz	a5,80004f20 <sys_fstat+0x32>
  return filestat(f, st);
    80004f14:	fe043583          	ld	a1,-32(s0)
    80004f18:	fe843503          	ld	a0,-24(s0)
    80004f1c:	c36ff0ef          	jal	80004352 <filestat>
}
    80004f20:	60e2                	ld	ra,24(sp)
    80004f22:	6442                	ld	s0,16(sp)
    80004f24:	6105                	addi	sp,sp,32
    80004f26:	8082                	ret

0000000080004f28 <sys_link>:
{
    80004f28:	7169                	addi	sp,sp,-304
    80004f2a:	f606                	sd	ra,296(sp)
    80004f2c:	f222                	sd	s0,288(sp)
    80004f2e:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f30:	08000613          	li	a2,128
    80004f34:	ed040593          	addi	a1,s0,-304
    80004f38:	4501                	li	a0,0
    80004f3a:	ad5fd0ef          	jal	80002a0e <argstr>
    return -1;
    80004f3e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f40:	0c054e63          	bltz	a0,8000501c <sys_link+0xf4>
    80004f44:	08000613          	li	a2,128
    80004f48:	f5040593          	addi	a1,s0,-176
    80004f4c:	4505                	li	a0,1
    80004f4e:	ac1fd0ef          	jal	80002a0e <argstr>
    return -1;
    80004f52:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f54:	0c054463          	bltz	a0,8000501c <sys_link+0xf4>
    80004f58:	ee26                	sd	s1,280(sp)
  begin_op();
    80004f5a:	f1dfe0ef          	jal	80003e76 <begin_op>
  if((ip = namei(old)) == 0){
    80004f5e:	ed040513          	addi	a0,s0,-304
    80004f62:	d59fe0ef          	jal	80003cba <namei>
    80004f66:	84aa                	mv	s1,a0
    80004f68:	c53d                	beqz	a0,80004fd6 <sys_link+0xae>
  ilock(ip);
    80004f6a:	e76fe0ef          	jal	800035e0 <ilock>
  if(ip->type == T_DIR){
    80004f6e:	04449703          	lh	a4,68(s1)
    80004f72:	4785                	li	a5,1
    80004f74:	06f70663          	beq	a4,a5,80004fe0 <sys_link+0xb8>
    80004f78:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004f7a:	04a4d783          	lhu	a5,74(s1)
    80004f7e:	2785                	addiw	a5,a5,1
    80004f80:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004f84:	8526                	mv	a0,s1
    80004f86:	da6fe0ef          	jal	8000352c <iupdate>
  iunlock(ip);
    80004f8a:	8526                	mv	a0,s1
    80004f8c:	f02fe0ef          	jal	8000368e <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004f90:	fd040593          	addi	a1,s0,-48
    80004f94:	f5040513          	addi	a0,s0,-176
    80004f98:	d3dfe0ef          	jal	80003cd4 <nameiparent>
    80004f9c:	892a                	mv	s2,a0
    80004f9e:	cd21                	beqz	a0,80004ff6 <sys_link+0xce>
  ilock(dp);
    80004fa0:	e40fe0ef          	jal	800035e0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004fa4:	00092703          	lw	a4,0(s2)
    80004fa8:	409c                	lw	a5,0(s1)
    80004faa:	04f71363          	bne	a4,a5,80004ff0 <sys_link+0xc8>
    80004fae:	40d0                	lw	a2,4(s1)
    80004fb0:	fd040593          	addi	a1,s0,-48
    80004fb4:	854a                	mv	a0,s2
    80004fb6:	c6bfe0ef          	jal	80003c20 <dirlink>
    80004fba:	02054b63          	bltz	a0,80004ff0 <sys_link+0xc8>
  iunlockput(dp);
    80004fbe:	854a                	mv	a0,s2
    80004fc0:	82bfe0ef          	jal	800037ea <iunlockput>
  iput(ip);
    80004fc4:	8526                	mv	a0,s1
    80004fc6:	f9cfe0ef          	jal	80003762 <iput>
  end_op();
    80004fca:	f17fe0ef          	jal	80003ee0 <end_op>
  return 0;
    80004fce:	4781                	li	a5,0
    80004fd0:	64f2                	ld	s1,280(sp)
    80004fd2:	6952                	ld	s2,272(sp)
    80004fd4:	a0a1                	j	8000501c <sys_link+0xf4>
    end_op();
    80004fd6:	f0bfe0ef          	jal	80003ee0 <end_op>
    return -1;
    80004fda:	57fd                	li	a5,-1
    80004fdc:	64f2                	ld	s1,280(sp)
    80004fde:	a83d                	j	8000501c <sys_link+0xf4>
    iunlockput(ip);
    80004fe0:	8526                	mv	a0,s1
    80004fe2:	809fe0ef          	jal	800037ea <iunlockput>
    end_op();
    80004fe6:	efbfe0ef          	jal	80003ee0 <end_op>
    return -1;
    80004fea:	57fd                	li	a5,-1
    80004fec:	64f2                	ld	s1,280(sp)
    80004fee:	a03d                	j	8000501c <sys_link+0xf4>
    iunlockput(dp);
    80004ff0:	854a                	mv	a0,s2
    80004ff2:	ff8fe0ef          	jal	800037ea <iunlockput>
  ilock(ip);
    80004ff6:	8526                	mv	a0,s1
    80004ff8:	de8fe0ef          	jal	800035e0 <ilock>
  ip->nlink--;
    80004ffc:	04a4d783          	lhu	a5,74(s1)
    80005000:	37fd                	addiw	a5,a5,-1
    80005002:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005006:	8526                	mv	a0,s1
    80005008:	d24fe0ef          	jal	8000352c <iupdate>
  iunlockput(ip);
    8000500c:	8526                	mv	a0,s1
    8000500e:	fdcfe0ef          	jal	800037ea <iunlockput>
  end_op();
    80005012:	ecffe0ef          	jal	80003ee0 <end_op>
  return -1;
    80005016:	57fd                	li	a5,-1
    80005018:	64f2                	ld	s1,280(sp)
    8000501a:	6952                	ld	s2,272(sp)
}
    8000501c:	853e                	mv	a0,a5
    8000501e:	70b2                	ld	ra,296(sp)
    80005020:	7412                	ld	s0,288(sp)
    80005022:	6155                	addi	sp,sp,304
    80005024:	8082                	ret

0000000080005026 <sys_unlink>:
{
    80005026:	7151                	addi	sp,sp,-240
    80005028:	f586                	sd	ra,232(sp)
    8000502a:	f1a2                	sd	s0,224(sp)
    8000502c:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000502e:	08000613          	li	a2,128
    80005032:	f3040593          	addi	a1,s0,-208
    80005036:	4501                	li	a0,0
    80005038:	9d7fd0ef          	jal	80002a0e <argstr>
    8000503c:	16054063          	bltz	a0,8000519c <sys_unlink+0x176>
    80005040:	eda6                	sd	s1,216(sp)
  begin_op();
    80005042:	e35fe0ef          	jal	80003e76 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005046:	fb040593          	addi	a1,s0,-80
    8000504a:	f3040513          	addi	a0,s0,-208
    8000504e:	c87fe0ef          	jal	80003cd4 <nameiparent>
    80005052:	84aa                	mv	s1,a0
    80005054:	c945                	beqz	a0,80005104 <sys_unlink+0xde>
  ilock(dp);
    80005056:	d8afe0ef          	jal	800035e0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000505a:	00002597          	auipc	a1,0x2
    8000505e:	5de58593          	addi	a1,a1,1502 # 80007638 <etext+0x638>
    80005062:	fb040513          	addi	a0,s0,-80
    80005066:	9d9fe0ef          	jal	80003a3e <namecmp>
    8000506a:	10050e63          	beqz	a0,80005186 <sys_unlink+0x160>
    8000506e:	00002597          	auipc	a1,0x2
    80005072:	5d258593          	addi	a1,a1,1490 # 80007640 <etext+0x640>
    80005076:	fb040513          	addi	a0,s0,-80
    8000507a:	9c5fe0ef          	jal	80003a3e <namecmp>
    8000507e:	10050463          	beqz	a0,80005186 <sys_unlink+0x160>
    80005082:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005084:	f2c40613          	addi	a2,s0,-212
    80005088:	fb040593          	addi	a1,s0,-80
    8000508c:	8526                	mv	a0,s1
    8000508e:	9c7fe0ef          	jal	80003a54 <dirlookup>
    80005092:	892a                	mv	s2,a0
    80005094:	0e050863          	beqz	a0,80005184 <sys_unlink+0x15e>
  ilock(ip);
    80005098:	d48fe0ef          	jal	800035e0 <ilock>
  if(ip->nlink < 1)
    8000509c:	04a91783          	lh	a5,74(s2)
    800050a0:	06f05763          	blez	a5,8000510e <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800050a4:	04491703          	lh	a4,68(s2)
    800050a8:	4785                	li	a5,1
    800050aa:	06f70963          	beq	a4,a5,8000511c <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    800050ae:	4641                	li	a2,16
    800050b0:	4581                	li	a1,0
    800050b2:	fc040513          	addi	a0,s0,-64
    800050b6:	c47fb0ef          	jal	80000cfc <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800050ba:	4741                	li	a4,16
    800050bc:	f2c42683          	lw	a3,-212(s0)
    800050c0:	fc040613          	addi	a2,s0,-64
    800050c4:	4581                	li	a1,0
    800050c6:	8526                	mv	a0,s1
    800050c8:	869fe0ef          	jal	80003930 <writei>
    800050cc:	47c1                	li	a5,16
    800050ce:	08f51b63          	bne	a0,a5,80005164 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    800050d2:	04491703          	lh	a4,68(s2)
    800050d6:	4785                	li	a5,1
    800050d8:	08f70d63          	beq	a4,a5,80005172 <sys_unlink+0x14c>
  iunlockput(dp);
    800050dc:	8526                	mv	a0,s1
    800050de:	f0cfe0ef          	jal	800037ea <iunlockput>
  ip->nlink--;
    800050e2:	04a95783          	lhu	a5,74(s2)
    800050e6:	37fd                	addiw	a5,a5,-1
    800050e8:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800050ec:	854a                	mv	a0,s2
    800050ee:	c3efe0ef          	jal	8000352c <iupdate>
  iunlockput(ip);
    800050f2:	854a                	mv	a0,s2
    800050f4:	ef6fe0ef          	jal	800037ea <iunlockput>
  end_op();
    800050f8:	de9fe0ef          	jal	80003ee0 <end_op>
  return 0;
    800050fc:	4501                	li	a0,0
    800050fe:	64ee                	ld	s1,216(sp)
    80005100:	694e                	ld	s2,208(sp)
    80005102:	a849                	j	80005194 <sys_unlink+0x16e>
    end_op();
    80005104:	dddfe0ef          	jal	80003ee0 <end_op>
    return -1;
    80005108:	557d                	li	a0,-1
    8000510a:	64ee                	ld	s1,216(sp)
    8000510c:	a061                	j	80005194 <sys_unlink+0x16e>
    8000510e:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80005110:	00002517          	auipc	a0,0x2
    80005114:	53850513          	addi	a0,a0,1336 # 80007648 <etext+0x648>
    80005118:	eb0fb0ef          	jal	800007c8 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000511c:	04c92703          	lw	a4,76(s2)
    80005120:	02000793          	li	a5,32
    80005124:	f8e7f5e3          	bgeu	a5,a4,800050ae <sys_unlink+0x88>
    80005128:	e5ce                	sd	s3,200(sp)
    8000512a:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000512e:	4741                	li	a4,16
    80005130:	86ce                	mv	a3,s3
    80005132:	f1840613          	addi	a2,s0,-232
    80005136:	4581                	li	a1,0
    80005138:	854a                	mv	a0,s2
    8000513a:	efafe0ef          	jal	80003834 <readi>
    8000513e:	47c1                	li	a5,16
    80005140:	00f51c63          	bne	a0,a5,80005158 <sys_unlink+0x132>
    if(de.inum != 0)
    80005144:	f1845783          	lhu	a5,-232(s0)
    80005148:	efa1                	bnez	a5,800051a0 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000514a:	29c1                	addiw	s3,s3,16
    8000514c:	04c92783          	lw	a5,76(s2)
    80005150:	fcf9efe3          	bltu	s3,a5,8000512e <sys_unlink+0x108>
    80005154:	69ae                	ld	s3,200(sp)
    80005156:	bfa1                	j	800050ae <sys_unlink+0x88>
      panic("isdirempty: readi");
    80005158:	00002517          	auipc	a0,0x2
    8000515c:	50850513          	addi	a0,a0,1288 # 80007660 <etext+0x660>
    80005160:	e68fb0ef          	jal	800007c8 <panic>
    80005164:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80005166:	00002517          	auipc	a0,0x2
    8000516a:	51250513          	addi	a0,a0,1298 # 80007678 <etext+0x678>
    8000516e:	e5afb0ef          	jal	800007c8 <panic>
    dp->nlink--;
    80005172:	04a4d783          	lhu	a5,74(s1)
    80005176:	37fd                	addiw	a5,a5,-1
    80005178:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000517c:	8526                	mv	a0,s1
    8000517e:	baefe0ef          	jal	8000352c <iupdate>
    80005182:	bfa9                	j	800050dc <sys_unlink+0xb6>
    80005184:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005186:	8526                	mv	a0,s1
    80005188:	e62fe0ef          	jal	800037ea <iunlockput>
  end_op();
    8000518c:	d55fe0ef          	jal	80003ee0 <end_op>
  return -1;
    80005190:	557d                	li	a0,-1
    80005192:	64ee                	ld	s1,216(sp)
}
    80005194:	70ae                	ld	ra,232(sp)
    80005196:	740e                	ld	s0,224(sp)
    80005198:	616d                	addi	sp,sp,240
    8000519a:	8082                	ret
    return -1;
    8000519c:	557d                	li	a0,-1
    8000519e:	bfdd                	j	80005194 <sys_unlink+0x16e>
    iunlockput(ip);
    800051a0:	854a                	mv	a0,s2
    800051a2:	e48fe0ef          	jal	800037ea <iunlockput>
    goto bad;
    800051a6:	694e                	ld	s2,208(sp)
    800051a8:	69ae                	ld	s3,200(sp)
    800051aa:	bff1                	j	80005186 <sys_unlink+0x160>

00000000800051ac <sys_open>:

uint64
sys_open(void)
{
    800051ac:	7131                	addi	sp,sp,-192
    800051ae:	fd06                	sd	ra,184(sp)
    800051b0:	f922                	sd	s0,176(sp)
    800051b2:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800051b4:	f4c40593          	addi	a1,s0,-180
    800051b8:	4505                	li	a0,1
    800051ba:	81dfd0ef          	jal	800029d6 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800051be:	08000613          	li	a2,128
    800051c2:	f5040593          	addi	a1,s0,-176
    800051c6:	4501                	li	a0,0
    800051c8:	847fd0ef          	jal	80002a0e <argstr>
    800051cc:	87aa                	mv	a5,a0
    return -1;
    800051ce:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800051d0:	0a07c263          	bltz	a5,80005274 <sys_open+0xc8>
    800051d4:	f526                	sd	s1,168(sp)

  begin_op();
    800051d6:	ca1fe0ef          	jal	80003e76 <begin_op>

  if(omode & O_CREATE){
    800051da:	f4c42783          	lw	a5,-180(s0)
    800051de:	2007f793          	andi	a5,a5,512
    800051e2:	c3d5                	beqz	a5,80005286 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    800051e4:	4681                	li	a3,0
    800051e6:	4601                	li	a2,0
    800051e8:	4589                	li	a1,2
    800051ea:	f5040513          	addi	a0,s0,-176
    800051ee:	aa9ff0ef          	jal	80004c96 <create>
    800051f2:	84aa                	mv	s1,a0
    if(ip == 0){
    800051f4:	c541                	beqz	a0,8000527c <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800051f6:	04449703          	lh	a4,68(s1)
    800051fa:	478d                	li	a5,3
    800051fc:	00f71763          	bne	a4,a5,8000520a <sys_open+0x5e>
    80005200:	0464d703          	lhu	a4,70(s1)
    80005204:	47a5                	li	a5,9
    80005206:	0ae7ed63          	bltu	a5,a4,800052c0 <sys_open+0x114>
    8000520a:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000520c:	fe1fe0ef          	jal	800041ec <filealloc>
    80005210:	892a                	mv	s2,a0
    80005212:	c179                	beqz	a0,800052d8 <sys_open+0x12c>
    80005214:	ed4e                	sd	s3,152(sp)
    80005216:	a43ff0ef          	jal	80004c58 <fdalloc>
    8000521a:	89aa                	mv	s3,a0
    8000521c:	0a054a63          	bltz	a0,800052d0 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005220:	04449703          	lh	a4,68(s1)
    80005224:	478d                	li	a5,3
    80005226:	0cf70263          	beq	a4,a5,800052ea <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000522a:	4789                	li	a5,2
    8000522c:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005230:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005234:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005238:	f4c42783          	lw	a5,-180(s0)
    8000523c:	0017c713          	xori	a4,a5,1
    80005240:	8b05                	andi	a4,a4,1
    80005242:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005246:	0037f713          	andi	a4,a5,3
    8000524a:	00e03733          	snez	a4,a4
    8000524e:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005252:	4007f793          	andi	a5,a5,1024
    80005256:	c791                	beqz	a5,80005262 <sys_open+0xb6>
    80005258:	04449703          	lh	a4,68(s1)
    8000525c:	4789                	li	a5,2
    8000525e:	08f70d63          	beq	a4,a5,800052f8 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80005262:	8526                	mv	a0,s1
    80005264:	c2afe0ef          	jal	8000368e <iunlock>
  end_op();
    80005268:	c79fe0ef          	jal	80003ee0 <end_op>

  return fd;
    8000526c:	854e                	mv	a0,s3
    8000526e:	74aa                	ld	s1,168(sp)
    80005270:	790a                	ld	s2,160(sp)
    80005272:	69ea                	ld	s3,152(sp)
}
    80005274:	70ea                	ld	ra,184(sp)
    80005276:	744a                	ld	s0,176(sp)
    80005278:	6129                	addi	sp,sp,192
    8000527a:	8082                	ret
      end_op();
    8000527c:	c65fe0ef          	jal	80003ee0 <end_op>
      return -1;
    80005280:	557d                	li	a0,-1
    80005282:	74aa                	ld	s1,168(sp)
    80005284:	bfc5                	j	80005274 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    80005286:	f5040513          	addi	a0,s0,-176
    8000528a:	a31fe0ef          	jal	80003cba <namei>
    8000528e:	84aa                	mv	s1,a0
    80005290:	c11d                	beqz	a0,800052b6 <sys_open+0x10a>
    ilock(ip);
    80005292:	b4efe0ef          	jal	800035e0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005296:	04449703          	lh	a4,68(s1)
    8000529a:	4785                	li	a5,1
    8000529c:	f4f71de3          	bne	a4,a5,800051f6 <sys_open+0x4a>
    800052a0:	f4c42783          	lw	a5,-180(s0)
    800052a4:	d3bd                	beqz	a5,8000520a <sys_open+0x5e>
      iunlockput(ip);
    800052a6:	8526                	mv	a0,s1
    800052a8:	d42fe0ef          	jal	800037ea <iunlockput>
      end_op();
    800052ac:	c35fe0ef          	jal	80003ee0 <end_op>
      return -1;
    800052b0:	557d                	li	a0,-1
    800052b2:	74aa                	ld	s1,168(sp)
    800052b4:	b7c1                	j	80005274 <sys_open+0xc8>
      end_op();
    800052b6:	c2bfe0ef          	jal	80003ee0 <end_op>
      return -1;
    800052ba:	557d                	li	a0,-1
    800052bc:	74aa                	ld	s1,168(sp)
    800052be:	bf5d                	j	80005274 <sys_open+0xc8>
    iunlockput(ip);
    800052c0:	8526                	mv	a0,s1
    800052c2:	d28fe0ef          	jal	800037ea <iunlockput>
    end_op();
    800052c6:	c1bfe0ef          	jal	80003ee0 <end_op>
    return -1;
    800052ca:	557d                	li	a0,-1
    800052cc:	74aa                	ld	s1,168(sp)
    800052ce:	b75d                	j	80005274 <sys_open+0xc8>
      fileclose(f);
    800052d0:	854a                	mv	a0,s2
    800052d2:	fbffe0ef          	jal	80004290 <fileclose>
    800052d6:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800052d8:	8526                	mv	a0,s1
    800052da:	d10fe0ef          	jal	800037ea <iunlockput>
    end_op();
    800052de:	c03fe0ef          	jal	80003ee0 <end_op>
    return -1;
    800052e2:	557d                	li	a0,-1
    800052e4:	74aa                	ld	s1,168(sp)
    800052e6:	790a                	ld	s2,160(sp)
    800052e8:	b771                	j	80005274 <sys_open+0xc8>
    f->type = FD_DEVICE;
    800052ea:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    800052ee:	04649783          	lh	a5,70(s1)
    800052f2:	02f91223          	sh	a5,36(s2)
    800052f6:	bf3d                	j	80005234 <sys_open+0x88>
    itrunc(ip);
    800052f8:	8526                	mv	a0,s1
    800052fa:	bd4fe0ef          	jal	800036ce <itrunc>
    800052fe:	b795                	j	80005262 <sys_open+0xb6>

0000000080005300 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005300:	7175                	addi	sp,sp,-144
    80005302:	e506                	sd	ra,136(sp)
    80005304:	e122                	sd	s0,128(sp)
    80005306:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005308:	b6ffe0ef          	jal	80003e76 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000530c:	08000613          	li	a2,128
    80005310:	f7040593          	addi	a1,s0,-144
    80005314:	4501                	li	a0,0
    80005316:	ef8fd0ef          	jal	80002a0e <argstr>
    8000531a:	02054363          	bltz	a0,80005340 <sys_mkdir+0x40>
    8000531e:	4681                	li	a3,0
    80005320:	4601                	li	a2,0
    80005322:	4585                	li	a1,1
    80005324:	f7040513          	addi	a0,s0,-144
    80005328:	96fff0ef          	jal	80004c96 <create>
    8000532c:	c911                	beqz	a0,80005340 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000532e:	cbcfe0ef          	jal	800037ea <iunlockput>
  end_op();
    80005332:	baffe0ef          	jal	80003ee0 <end_op>
  return 0;
    80005336:	4501                	li	a0,0
}
    80005338:	60aa                	ld	ra,136(sp)
    8000533a:	640a                	ld	s0,128(sp)
    8000533c:	6149                	addi	sp,sp,144
    8000533e:	8082                	ret
    end_op();
    80005340:	ba1fe0ef          	jal	80003ee0 <end_op>
    return -1;
    80005344:	557d                	li	a0,-1
    80005346:	bfcd                	j	80005338 <sys_mkdir+0x38>

0000000080005348 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005348:	7135                	addi	sp,sp,-160
    8000534a:	ed06                	sd	ra,152(sp)
    8000534c:	e922                	sd	s0,144(sp)
    8000534e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005350:	b27fe0ef          	jal	80003e76 <begin_op>
  argint(1, &major);
    80005354:	f6c40593          	addi	a1,s0,-148
    80005358:	4505                	li	a0,1
    8000535a:	e7cfd0ef          	jal	800029d6 <argint>
  argint(2, &minor);
    8000535e:	f6840593          	addi	a1,s0,-152
    80005362:	4509                	li	a0,2
    80005364:	e72fd0ef          	jal	800029d6 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005368:	08000613          	li	a2,128
    8000536c:	f7040593          	addi	a1,s0,-144
    80005370:	4501                	li	a0,0
    80005372:	e9cfd0ef          	jal	80002a0e <argstr>
    80005376:	02054563          	bltz	a0,800053a0 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000537a:	f6841683          	lh	a3,-152(s0)
    8000537e:	f6c41603          	lh	a2,-148(s0)
    80005382:	458d                	li	a1,3
    80005384:	f7040513          	addi	a0,s0,-144
    80005388:	90fff0ef          	jal	80004c96 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000538c:	c911                	beqz	a0,800053a0 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000538e:	c5cfe0ef          	jal	800037ea <iunlockput>
  end_op();
    80005392:	b4ffe0ef          	jal	80003ee0 <end_op>
  return 0;
    80005396:	4501                	li	a0,0
}
    80005398:	60ea                	ld	ra,152(sp)
    8000539a:	644a                	ld	s0,144(sp)
    8000539c:	610d                	addi	sp,sp,160
    8000539e:	8082                	ret
    end_op();
    800053a0:	b41fe0ef          	jal	80003ee0 <end_op>
    return -1;
    800053a4:	557d                	li	a0,-1
    800053a6:	bfcd                	j	80005398 <sys_mknod+0x50>

00000000800053a8 <sys_chdir>:

uint64
sys_chdir(void)
{
    800053a8:	7135                	addi	sp,sp,-160
    800053aa:	ed06                	sd	ra,152(sp)
    800053ac:	e922                	sd	s0,144(sp)
    800053ae:	e14a                	sd	s2,128(sp)
    800053b0:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800053b2:	d62fc0ef          	jal	80001914 <myproc>
    800053b6:	892a                	mv	s2,a0
  
  begin_op();
    800053b8:	abffe0ef          	jal	80003e76 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800053bc:	08000613          	li	a2,128
    800053c0:	f6040593          	addi	a1,s0,-160
    800053c4:	4501                	li	a0,0
    800053c6:	e48fd0ef          	jal	80002a0e <argstr>
    800053ca:	04054363          	bltz	a0,80005410 <sys_chdir+0x68>
    800053ce:	e526                	sd	s1,136(sp)
    800053d0:	f6040513          	addi	a0,s0,-160
    800053d4:	8e7fe0ef          	jal	80003cba <namei>
    800053d8:	84aa                	mv	s1,a0
    800053da:	c915                	beqz	a0,8000540e <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800053dc:	a04fe0ef          	jal	800035e0 <ilock>
  if(ip->type != T_DIR){
    800053e0:	04449703          	lh	a4,68(s1)
    800053e4:	4785                	li	a5,1
    800053e6:	02f71963          	bne	a4,a5,80005418 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800053ea:	8526                	mv	a0,s1
    800053ec:	aa2fe0ef          	jal	8000368e <iunlock>
  iput(p->cwd);
    800053f0:	15093503          	ld	a0,336(s2)
    800053f4:	b6efe0ef          	jal	80003762 <iput>
  end_op();
    800053f8:	ae9fe0ef          	jal	80003ee0 <end_op>
  p->cwd = ip;
    800053fc:	14993823          	sd	s1,336(s2)
  return 0;
    80005400:	4501                	li	a0,0
    80005402:	64aa                	ld	s1,136(sp)
}
    80005404:	60ea                	ld	ra,152(sp)
    80005406:	644a                	ld	s0,144(sp)
    80005408:	690a                	ld	s2,128(sp)
    8000540a:	610d                	addi	sp,sp,160
    8000540c:	8082                	ret
    8000540e:	64aa                	ld	s1,136(sp)
    end_op();
    80005410:	ad1fe0ef          	jal	80003ee0 <end_op>
    return -1;
    80005414:	557d                	li	a0,-1
    80005416:	b7fd                	j	80005404 <sys_chdir+0x5c>
    iunlockput(ip);
    80005418:	8526                	mv	a0,s1
    8000541a:	bd0fe0ef          	jal	800037ea <iunlockput>
    end_op();
    8000541e:	ac3fe0ef          	jal	80003ee0 <end_op>
    return -1;
    80005422:	557d                	li	a0,-1
    80005424:	64aa                	ld	s1,136(sp)
    80005426:	bff9                	j	80005404 <sys_chdir+0x5c>

0000000080005428 <sys_exec>:

uint64
sys_exec(void)
{
    80005428:	7121                	addi	sp,sp,-448
    8000542a:	ff06                	sd	ra,440(sp)
    8000542c:	fb22                	sd	s0,432(sp)
    8000542e:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005430:	e4840593          	addi	a1,s0,-440
    80005434:	4505                	li	a0,1
    80005436:	dbcfd0ef          	jal	800029f2 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000543a:	08000613          	li	a2,128
    8000543e:	f5040593          	addi	a1,s0,-176
    80005442:	4501                	li	a0,0
    80005444:	dcafd0ef          	jal	80002a0e <argstr>
    80005448:	87aa                	mv	a5,a0
    return -1;
    8000544a:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000544c:	0c07c463          	bltz	a5,80005514 <sys_exec+0xec>
    80005450:	f726                	sd	s1,424(sp)
    80005452:	f34a                	sd	s2,416(sp)
    80005454:	ef4e                	sd	s3,408(sp)
    80005456:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005458:	10000613          	li	a2,256
    8000545c:	4581                	li	a1,0
    8000545e:	e5040513          	addi	a0,s0,-432
    80005462:	89bfb0ef          	jal	80000cfc <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005466:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    8000546a:	89a6                	mv	s3,s1
    8000546c:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000546e:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005472:	00391513          	slli	a0,s2,0x3
    80005476:	e4040593          	addi	a1,s0,-448
    8000547a:	e4843783          	ld	a5,-440(s0)
    8000547e:	953e                	add	a0,a0,a5
    80005480:	cccfd0ef          	jal	8000294c <fetchaddr>
    80005484:	02054663          	bltz	a0,800054b0 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    80005488:	e4043783          	ld	a5,-448(s0)
    8000548c:	c3a9                	beqz	a5,800054ce <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000548e:	ecafb0ef          	jal	80000b58 <kalloc>
    80005492:	85aa                	mv	a1,a0
    80005494:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005498:	cd01                	beqz	a0,800054b0 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000549a:	6605                	lui	a2,0x1
    8000549c:	e4043503          	ld	a0,-448(s0)
    800054a0:	cf6fd0ef          	jal	80002996 <fetchstr>
    800054a4:	00054663          	bltz	a0,800054b0 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    800054a8:	0905                	addi	s2,s2,1
    800054aa:	09a1                	addi	s3,s3,8
    800054ac:	fd4913e3          	bne	s2,s4,80005472 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800054b0:	f5040913          	addi	s2,s0,-176
    800054b4:	6088                	ld	a0,0(s1)
    800054b6:	c931                	beqz	a0,8000550a <sys_exec+0xe2>
    kfree(argv[i]);
    800054b8:	dbefb0ef          	jal	80000a76 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800054bc:	04a1                	addi	s1,s1,8
    800054be:	ff249be3          	bne	s1,s2,800054b4 <sys_exec+0x8c>
  return -1;
    800054c2:	557d                	li	a0,-1
    800054c4:	74ba                	ld	s1,424(sp)
    800054c6:	791a                	ld	s2,416(sp)
    800054c8:	69fa                	ld	s3,408(sp)
    800054ca:	6a5a                	ld	s4,400(sp)
    800054cc:	a0a1                	j	80005514 <sys_exec+0xec>
      argv[i] = 0;
    800054ce:	0009079b          	sext.w	a5,s2
    800054d2:	078e                	slli	a5,a5,0x3
    800054d4:	fd078793          	addi	a5,a5,-48
    800054d8:	97a2                	add	a5,a5,s0
    800054da:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    800054de:	e5040593          	addi	a1,s0,-432
    800054e2:	f5040513          	addi	a0,s0,-176
    800054e6:	ba8ff0ef          	jal	8000488e <exec>
    800054ea:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800054ec:	f5040993          	addi	s3,s0,-176
    800054f0:	6088                	ld	a0,0(s1)
    800054f2:	c511                	beqz	a0,800054fe <sys_exec+0xd6>
    kfree(argv[i]);
    800054f4:	d82fb0ef          	jal	80000a76 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800054f8:	04a1                	addi	s1,s1,8
    800054fa:	ff349be3          	bne	s1,s3,800054f0 <sys_exec+0xc8>
  return ret;
    800054fe:	854a                	mv	a0,s2
    80005500:	74ba                	ld	s1,424(sp)
    80005502:	791a                	ld	s2,416(sp)
    80005504:	69fa                	ld	s3,408(sp)
    80005506:	6a5a                	ld	s4,400(sp)
    80005508:	a031                	j	80005514 <sys_exec+0xec>
  return -1;
    8000550a:	557d                	li	a0,-1
    8000550c:	74ba                	ld	s1,424(sp)
    8000550e:	791a                	ld	s2,416(sp)
    80005510:	69fa                	ld	s3,408(sp)
    80005512:	6a5a                	ld	s4,400(sp)
}
    80005514:	70fa                	ld	ra,440(sp)
    80005516:	745a                	ld	s0,432(sp)
    80005518:	6139                	addi	sp,sp,448
    8000551a:	8082                	ret

000000008000551c <sys_pipe>:

uint64
sys_pipe(void)
{
    8000551c:	7139                	addi	sp,sp,-64
    8000551e:	fc06                	sd	ra,56(sp)
    80005520:	f822                	sd	s0,48(sp)
    80005522:	f426                	sd	s1,40(sp)
    80005524:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005526:	beefc0ef          	jal	80001914 <myproc>
    8000552a:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000552c:	fd840593          	addi	a1,s0,-40
    80005530:	4501                	li	a0,0
    80005532:	cc0fd0ef          	jal	800029f2 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005536:	fc840593          	addi	a1,s0,-56
    8000553a:	fd040513          	addi	a0,s0,-48
    8000553e:	85cff0ef          	jal	8000459a <pipealloc>
    return -1;
    80005542:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005544:	0a054463          	bltz	a0,800055ec <sys_pipe+0xd0>
  fd0 = -1;
    80005548:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000554c:	fd043503          	ld	a0,-48(s0)
    80005550:	f08ff0ef          	jal	80004c58 <fdalloc>
    80005554:	fca42223          	sw	a0,-60(s0)
    80005558:	08054163          	bltz	a0,800055da <sys_pipe+0xbe>
    8000555c:	fc843503          	ld	a0,-56(s0)
    80005560:	ef8ff0ef          	jal	80004c58 <fdalloc>
    80005564:	fca42023          	sw	a0,-64(s0)
    80005568:	06054063          	bltz	a0,800055c8 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000556c:	4691                	li	a3,4
    8000556e:	fc440613          	addi	a2,s0,-60
    80005572:	fd843583          	ld	a1,-40(s0)
    80005576:	68a8                	ld	a0,80(s1)
    80005578:	80efc0ef          	jal	80001586 <copyout>
    8000557c:	00054e63          	bltz	a0,80005598 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005580:	4691                	li	a3,4
    80005582:	fc040613          	addi	a2,s0,-64
    80005586:	fd843583          	ld	a1,-40(s0)
    8000558a:	0591                	addi	a1,a1,4
    8000558c:	68a8                	ld	a0,80(s1)
    8000558e:	ff9fb0ef          	jal	80001586 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005592:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005594:	04055c63          	bgez	a0,800055ec <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005598:	fc442783          	lw	a5,-60(s0)
    8000559c:	07e9                	addi	a5,a5,26
    8000559e:	078e                	slli	a5,a5,0x3
    800055a0:	97a6                	add	a5,a5,s1
    800055a2:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800055a6:	fc042783          	lw	a5,-64(s0)
    800055aa:	07e9                	addi	a5,a5,26
    800055ac:	078e                	slli	a5,a5,0x3
    800055ae:	94be                	add	s1,s1,a5
    800055b0:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800055b4:	fd043503          	ld	a0,-48(s0)
    800055b8:	cd9fe0ef          	jal	80004290 <fileclose>
    fileclose(wf);
    800055bc:	fc843503          	ld	a0,-56(s0)
    800055c0:	cd1fe0ef          	jal	80004290 <fileclose>
    return -1;
    800055c4:	57fd                	li	a5,-1
    800055c6:	a01d                	j	800055ec <sys_pipe+0xd0>
    if(fd0 >= 0)
    800055c8:	fc442783          	lw	a5,-60(s0)
    800055cc:	0007c763          	bltz	a5,800055da <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800055d0:	07e9                	addi	a5,a5,26
    800055d2:	078e                	slli	a5,a5,0x3
    800055d4:	97a6                	add	a5,a5,s1
    800055d6:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800055da:	fd043503          	ld	a0,-48(s0)
    800055de:	cb3fe0ef          	jal	80004290 <fileclose>
    fileclose(wf);
    800055e2:	fc843503          	ld	a0,-56(s0)
    800055e6:	cabfe0ef          	jal	80004290 <fileclose>
    return -1;
    800055ea:	57fd                	li	a5,-1
}
    800055ec:	853e                	mv	a0,a5
    800055ee:	70e2                	ld	ra,56(sp)
    800055f0:	7442                	ld	s0,48(sp)
    800055f2:	74a2                	ld	s1,40(sp)
    800055f4:	6121                	addi	sp,sp,64
    800055f6:	8082                	ret
	...

0000000080005600 <kernelvec>:
    80005600:	7111                	addi	sp,sp,-256
    80005602:	e006                	sd	ra,0(sp)
    80005604:	e40a                	sd	sp,8(sp)
    80005606:	e80e                	sd	gp,16(sp)
    80005608:	ec12                	sd	tp,24(sp)
    8000560a:	f016                	sd	t0,32(sp)
    8000560c:	f41a                	sd	t1,40(sp)
    8000560e:	f81e                	sd	t2,48(sp)
    80005610:	e4aa                	sd	a0,72(sp)
    80005612:	e8ae                	sd	a1,80(sp)
    80005614:	ecb2                	sd	a2,88(sp)
    80005616:	f0b6                	sd	a3,96(sp)
    80005618:	f4ba                	sd	a4,104(sp)
    8000561a:	f8be                	sd	a5,112(sp)
    8000561c:	fcc2                	sd	a6,120(sp)
    8000561e:	e146                	sd	a7,128(sp)
    80005620:	edf2                	sd	t3,216(sp)
    80005622:	f1f6                	sd	t4,224(sp)
    80005624:	f5fa                	sd	t5,232(sp)
    80005626:	f9fe                	sd	t6,240(sp)
    80005628:	a34fd0ef          	jal	8000285c <kerneltrap>
    8000562c:	6082                	ld	ra,0(sp)
    8000562e:	6122                	ld	sp,8(sp)
    80005630:	61c2                	ld	gp,16(sp)
    80005632:	7282                	ld	t0,32(sp)
    80005634:	7322                	ld	t1,40(sp)
    80005636:	73c2                	ld	t2,48(sp)
    80005638:	6526                	ld	a0,72(sp)
    8000563a:	65c6                	ld	a1,80(sp)
    8000563c:	6666                	ld	a2,88(sp)
    8000563e:	7686                	ld	a3,96(sp)
    80005640:	7726                	ld	a4,104(sp)
    80005642:	77c6                	ld	a5,112(sp)
    80005644:	7866                	ld	a6,120(sp)
    80005646:	688a                	ld	a7,128(sp)
    80005648:	6e6e                	ld	t3,216(sp)
    8000564a:	7e8e                	ld	t4,224(sp)
    8000564c:	7f2e                	ld	t5,232(sp)
    8000564e:	7fce                	ld	t6,240(sp)
    80005650:	6111                	addi	sp,sp,256
    80005652:	10200073          	sret
	...

000000008000565e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000565e:	1141                	addi	sp,sp,-16
    80005660:	e422                	sd	s0,8(sp)
    80005662:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005664:	0c0007b7          	lui	a5,0xc000
    80005668:	4705                	li	a4,1
    8000566a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000566c:	0c0007b7          	lui	a5,0xc000
    80005670:	c3d8                	sw	a4,4(a5)
}
    80005672:	6422                	ld	s0,8(sp)
    80005674:	0141                	addi	sp,sp,16
    80005676:	8082                	ret

0000000080005678 <plicinithart>:

void
plicinithart(void)
{
    80005678:	1141                	addi	sp,sp,-16
    8000567a:	e406                	sd	ra,8(sp)
    8000567c:	e022                	sd	s0,0(sp)
    8000567e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005680:	a68fc0ef          	jal	800018e8 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005684:	0085171b          	slliw	a4,a0,0x8
    80005688:	0c0027b7          	lui	a5,0xc002
    8000568c:	97ba                	add	a5,a5,a4
    8000568e:	40200713          	li	a4,1026
    80005692:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005696:	00d5151b          	slliw	a0,a0,0xd
    8000569a:	0c2017b7          	lui	a5,0xc201
    8000569e:	97aa                	add	a5,a5,a0
    800056a0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800056a4:	60a2                	ld	ra,8(sp)
    800056a6:	6402                	ld	s0,0(sp)
    800056a8:	0141                	addi	sp,sp,16
    800056aa:	8082                	ret

00000000800056ac <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800056ac:	1141                	addi	sp,sp,-16
    800056ae:	e406                	sd	ra,8(sp)
    800056b0:	e022                	sd	s0,0(sp)
    800056b2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800056b4:	a34fc0ef          	jal	800018e8 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800056b8:	00d5151b          	slliw	a0,a0,0xd
    800056bc:	0c2017b7          	lui	a5,0xc201
    800056c0:	97aa                	add	a5,a5,a0
  return irq;
}
    800056c2:	43c8                	lw	a0,4(a5)
    800056c4:	60a2                	ld	ra,8(sp)
    800056c6:	6402                	ld	s0,0(sp)
    800056c8:	0141                	addi	sp,sp,16
    800056ca:	8082                	ret

00000000800056cc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800056cc:	1101                	addi	sp,sp,-32
    800056ce:	ec06                	sd	ra,24(sp)
    800056d0:	e822                	sd	s0,16(sp)
    800056d2:	e426                	sd	s1,8(sp)
    800056d4:	1000                	addi	s0,sp,32
    800056d6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800056d8:	a10fc0ef          	jal	800018e8 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800056dc:	00d5151b          	slliw	a0,a0,0xd
    800056e0:	0c2017b7          	lui	a5,0xc201
    800056e4:	97aa                	add	a5,a5,a0
    800056e6:	c3c4                	sw	s1,4(a5)
}
    800056e8:	60e2                	ld	ra,24(sp)
    800056ea:	6442                	ld	s0,16(sp)
    800056ec:	64a2                	ld	s1,8(sp)
    800056ee:	6105                	addi	sp,sp,32
    800056f0:	8082                	ret

00000000800056f2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800056f2:	1141                	addi	sp,sp,-16
    800056f4:	e406                	sd	ra,8(sp)
    800056f6:	e022                	sd	s0,0(sp)
    800056f8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800056fa:	479d                	li	a5,7
    800056fc:	04a7ca63          	blt	a5,a0,80005750 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005700:	0001e797          	auipc	a5,0x1e
    80005704:	f8078793          	addi	a5,a5,-128 # 80023680 <disk>
    80005708:	97aa                	add	a5,a5,a0
    8000570a:	0187c783          	lbu	a5,24(a5)
    8000570e:	e7b9                	bnez	a5,8000575c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005710:	00451693          	slli	a3,a0,0x4
    80005714:	0001e797          	auipc	a5,0x1e
    80005718:	f6c78793          	addi	a5,a5,-148 # 80023680 <disk>
    8000571c:	6398                	ld	a4,0(a5)
    8000571e:	9736                	add	a4,a4,a3
    80005720:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005724:	6398                	ld	a4,0(a5)
    80005726:	9736                	add	a4,a4,a3
    80005728:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000572c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005730:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005734:	97aa                	add	a5,a5,a0
    80005736:	4705                	li	a4,1
    80005738:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000573c:	0001e517          	auipc	a0,0x1e
    80005740:	f5c50513          	addi	a0,a0,-164 # 80023698 <disk+0x18>
    80005744:	feafc0ef          	jal	80001f2e <wakeup>
}
    80005748:	60a2                	ld	ra,8(sp)
    8000574a:	6402                	ld	s0,0(sp)
    8000574c:	0141                	addi	sp,sp,16
    8000574e:	8082                	ret
    panic("free_desc 1");
    80005750:	00002517          	auipc	a0,0x2
    80005754:	f3850513          	addi	a0,a0,-200 # 80007688 <etext+0x688>
    80005758:	870fb0ef          	jal	800007c8 <panic>
    panic("free_desc 2");
    8000575c:	00002517          	auipc	a0,0x2
    80005760:	f3c50513          	addi	a0,a0,-196 # 80007698 <etext+0x698>
    80005764:	864fb0ef          	jal	800007c8 <panic>

0000000080005768 <virtio_disk_init>:
{
    80005768:	1101                	addi	sp,sp,-32
    8000576a:	ec06                	sd	ra,24(sp)
    8000576c:	e822                	sd	s0,16(sp)
    8000576e:	e426                	sd	s1,8(sp)
    80005770:	e04a                	sd	s2,0(sp)
    80005772:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005774:	00002597          	auipc	a1,0x2
    80005778:	f3458593          	addi	a1,a1,-204 # 800076a8 <etext+0x6a8>
    8000577c:	0001e517          	auipc	a0,0x1e
    80005780:	02c50513          	addi	a0,a0,44 # 800237a8 <disk+0x128>
    80005784:	c24fb0ef          	jal	80000ba8 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005788:	100017b7          	lui	a5,0x10001
    8000578c:	4398                	lw	a4,0(a5)
    8000578e:	2701                	sext.w	a4,a4
    80005790:	747277b7          	lui	a5,0x74727
    80005794:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005798:	18f71063          	bne	a4,a5,80005918 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000579c:	100017b7          	lui	a5,0x10001
    800057a0:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800057a2:	439c                	lw	a5,0(a5)
    800057a4:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800057a6:	4709                	li	a4,2
    800057a8:	16e79863          	bne	a5,a4,80005918 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800057ac:	100017b7          	lui	a5,0x10001
    800057b0:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800057b2:	439c                	lw	a5,0(a5)
    800057b4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800057b6:	16e79163          	bne	a5,a4,80005918 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800057ba:	100017b7          	lui	a5,0x10001
    800057be:	47d8                	lw	a4,12(a5)
    800057c0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800057c2:	554d47b7          	lui	a5,0x554d4
    800057c6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800057ca:	14f71763          	bne	a4,a5,80005918 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    800057ce:	100017b7          	lui	a5,0x10001
    800057d2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800057d6:	4705                	li	a4,1
    800057d8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800057da:	470d                	li	a4,3
    800057dc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800057de:	10001737          	lui	a4,0x10001
    800057e2:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800057e4:	c7ffe737          	lui	a4,0xc7ffe
    800057e8:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdaf9f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800057ec:	8ef9                	and	a3,a3,a4
    800057ee:	10001737          	lui	a4,0x10001
    800057f2:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    800057f4:	472d                	li	a4,11
    800057f6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800057f8:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800057fc:	439c                	lw	a5,0(a5)
    800057fe:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005802:	8ba1                	andi	a5,a5,8
    80005804:	12078063          	beqz	a5,80005924 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005808:	100017b7          	lui	a5,0x10001
    8000580c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005810:	100017b7          	lui	a5,0x10001
    80005814:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005818:	439c                	lw	a5,0(a5)
    8000581a:	2781                	sext.w	a5,a5
    8000581c:	10079a63          	bnez	a5,80005930 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005820:	100017b7          	lui	a5,0x10001
    80005824:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005828:	439c                	lw	a5,0(a5)
    8000582a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000582c:	10078863          	beqz	a5,8000593c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80005830:	471d                	li	a4,7
    80005832:	10f77b63          	bgeu	a4,a5,80005948 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80005836:	b22fb0ef          	jal	80000b58 <kalloc>
    8000583a:	0001e497          	auipc	s1,0x1e
    8000583e:	e4648493          	addi	s1,s1,-442 # 80023680 <disk>
    80005842:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005844:	b14fb0ef          	jal	80000b58 <kalloc>
    80005848:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000584a:	b0efb0ef          	jal	80000b58 <kalloc>
    8000584e:	87aa                	mv	a5,a0
    80005850:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005852:	6088                	ld	a0,0(s1)
    80005854:	10050063          	beqz	a0,80005954 <virtio_disk_init+0x1ec>
    80005858:	0001e717          	auipc	a4,0x1e
    8000585c:	e3073703          	ld	a4,-464(a4) # 80023688 <disk+0x8>
    80005860:	0e070a63          	beqz	a4,80005954 <virtio_disk_init+0x1ec>
    80005864:	0e078863          	beqz	a5,80005954 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005868:	6605                	lui	a2,0x1
    8000586a:	4581                	li	a1,0
    8000586c:	c90fb0ef          	jal	80000cfc <memset>
  memset(disk.avail, 0, PGSIZE);
    80005870:	0001e497          	auipc	s1,0x1e
    80005874:	e1048493          	addi	s1,s1,-496 # 80023680 <disk>
    80005878:	6605                	lui	a2,0x1
    8000587a:	4581                	li	a1,0
    8000587c:	6488                	ld	a0,8(s1)
    8000587e:	c7efb0ef          	jal	80000cfc <memset>
  memset(disk.used, 0, PGSIZE);
    80005882:	6605                	lui	a2,0x1
    80005884:	4581                	li	a1,0
    80005886:	6888                	ld	a0,16(s1)
    80005888:	c74fb0ef          	jal	80000cfc <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000588c:	100017b7          	lui	a5,0x10001
    80005890:	4721                	li	a4,8
    80005892:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005894:	4098                	lw	a4,0(s1)
    80005896:	100017b7          	lui	a5,0x10001
    8000589a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000589e:	40d8                	lw	a4,4(s1)
    800058a0:	100017b7          	lui	a5,0x10001
    800058a4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800058a8:	649c                	ld	a5,8(s1)
    800058aa:	0007869b          	sext.w	a3,a5
    800058ae:	10001737          	lui	a4,0x10001
    800058b2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800058b6:	9781                	srai	a5,a5,0x20
    800058b8:	10001737          	lui	a4,0x10001
    800058bc:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800058c0:	689c                	ld	a5,16(s1)
    800058c2:	0007869b          	sext.w	a3,a5
    800058c6:	10001737          	lui	a4,0x10001
    800058ca:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800058ce:	9781                	srai	a5,a5,0x20
    800058d0:	10001737          	lui	a4,0x10001
    800058d4:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800058d8:	10001737          	lui	a4,0x10001
    800058dc:	4785                	li	a5,1
    800058de:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800058e0:	00f48c23          	sb	a5,24(s1)
    800058e4:	00f48ca3          	sb	a5,25(s1)
    800058e8:	00f48d23          	sb	a5,26(s1)
    800058ec:	00f48da3          	sb	a5,27(s1)
    800058f0:	00f48e23          	sb	a5,28(s1)
    800058f4:	00f48ea3          	sb	a5,29(s1)
    800058f8:	00f48f23          	sb	a5,30(s1)
    800058fc:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005900:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005904:	100017b7          	lui	a5,0x10001
    80005908:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000590c:	60e2                	ld	ra,24(sp)
    8000590e:	6442                	ld	s0,16(sp)
    80005910:	64a2                	ld	s1,8(sp)
    80005912:	6902                	ld	s2,0(sp)
    80005914:	6105                	addi	sp,sp,32
    80005916:	8082                	ret
    panic("could not find virtio disk");
    80005918:	00002517          	auipc	a0,0x2
    8000591c:	da050513          	addi	a0,a0,-608 # 800076b8 <etext+0x6b8>
    80005920:	ea9fa0ef          	jal	800007c8 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005924:	00002517          	auipc	a0,0x2
    80005928:	db450513          	addi	a0,a0,-588 # 800076d8 <etext+0x6d8>
    8000592c:	e9dfa0ef          	jal	800007c8 <panic>
    panic("virtio disk should not be ready");
    80005930:	00002517          	auipc	a0,0x2
    80005934:	dc850513          	addi	a0,a0,-568 # 800076f8 <etext+0x6f8>
    80005938:	e91fa0ef          	jal	800007c8 <panic>
    panic("virtio disk has no queue 0");
    8000593c:	00002517          	auipc	a0,0x2
    80005940:	ddc50513          	addi	a0,a0,-548 # 80007718 <etext+0x718>
    80005944:	e85fa0ef          	jal	800007c8 <panic>
    panic("virtio disk max queue too short");
    80005948:	00002517          	auipc	a0,0x2
    8000594c:	df050513          	addi	a0,a0,-528 # 80007738 <etext+0x738>
    80005950:	e79fa0ef          	jal	800007c8 <panic>
    panic("virtio disk kalloc");
    80005954:	00002517          	auipc	a0,0x2
    80005958:	e0450513          	addi	a0,a0,-508 # 80007758 <etext+0x758>
    8000595c:	e6dfa0ef          	jal	800007c8 <panic>

0000000080005960 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005960:	7159                	addi	sp,sp,-112
    80005962:	f486                	sd	ra,104(sp)
    80005964:	f0a2                	sd	s0,96(sp)
    80005966:	eca6                	sd	s1,88(sp)
    80005968:	e8ca                	sd	s2,80(sp)
    8000596a:	e4ce                	sd	s3,72(sp)
    8000596c:	e0d2                	sd	s4,64(sp)
    8000596e:	fc56                	sd	s5,56(sp)
    80005970:	f85a                	sd	s6,48(sp)
    80005972:	f45e                	sd	s7,40(sp)
    80005974:	f062                	sd	s8,32(sp)
    80005976:	ec66                	sd	s9,24(sp)
    80005978:	1880                	addi	s0,sp,112
    8000597a:	8a2a                	mv	s4,a0
    8000597c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000597e:	00c52c83          	lw	s9,12(a0)
    80005982:	001c9c9b          	slliw	s9,s9,0x1
    80005986:	1c82                	slli	s9,s9,0x20
    80005988:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000598c:	0001e517          	auipc	a0,0x1e
    80005990:	e1c50513          	addi	a0,a0,-484 # 800237a8 <disk+0x128>
    80005994:	a94fb0ef          	jal	80000c28 <acquire>
  for(int i = 0; i < 3; i++){
    80005998:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000599a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000599c:	0001eb17          	auipc	s6,0x1e
    800059a0:	ce4b0b13          	addi	s6,s6,-796 # 80023680 <disk>
  for(int i = 0; i < 3; i++){
    800059a4:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800059a6:	0001ec17          	auipc	s8,0x1e
    800059aa:	e02c0c13          	addi	s8,s8,-510 # 800237a8 <disk+0x128>
    800059ae:	a8b9                	j	80005a0c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    800059b0:	00fb0733          	add	a4,s6,a5
    800059b4:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    800059b8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800059ba:	0207c563          	bltz	a5,800059e4 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    800059be:	2905                	addiw	s2,s2,1
    800059c0:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800059c2:	05590963          	beq	s2,s5,80005a14 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    800059c6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800059c8:	0001e717          	auipc	a4,0x1e
    800059cc:	cb870713          	addi	a4,a4,-840 # 80023680 <disk>
    800059d0:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800059d2:	01874683          	lbu	a3,24(a4)
    800059d6:	fee9                	bnez	a3,800059b0 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    800059d8:	2785                	addiw	a5,a5,1
    800059da:	0705                	addi	a4,a4,1
    800059dc:	fe979be3          	bne	a5,s1,800059d2 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    800059e0:	57fd                	li	a5,-1
    800059e2:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800059e4:	01205d63          	blez	s2,800059fe <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    800059e8:	f9042503          	lw	a0,-112(s0)
    800059ec:	d07ff0ef          	jal	800056f2 <free_desc>
      for(int j = 0; j < i; j++)
    800059f0:	4785                	li	a5,1
    800059f2:	0127d663          	bge	a5,s2,800059fe <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    800059f6:	f9442503          	lw	a0,-108(s0)
    800059fa:	cf9ff0ef          	jal	800056f2 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800059fe:	85e2                	mv	a1,s8
    80005a00:	0001e517          	auipc	a0,0x1e
    80005a04:	c9850513          	addi	a0,a0,-872 # 80023698 <disk+0x18>
    80005a08:	cdafc0ef          	jal	80001ee2 <sleep>
  for(int i = 0; i < 3; i++){
    80005a0c:	f9040613          	addi	a2,s0,-112
    80005a10:	894e                	mv	s2,s3
    80005a12:	bf55                	j	800059c6 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005a14:	f9042503          	lw	a0,-112(s0)
    80005a18:	00451693          	slli	a3,a0,0x4

  if(write)
    80005a1c:	0001e797          	auipc	a5,0x1e
    80005a20:	c6478793          	addi	a5,a5,-924 # 80023680 <disk>
    80005a24:	00a50713          	addi	a4,a0,10
    80005a28:	0712                	slli	a4,a4,0x4
    80005a2a:	973e                	add	a4,a4,a5
    80005a2c:	01703633          	snez	a2,s7
    80005a30:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005a32:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005a36:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005a3a:	6398                	ld	a4,0(a5)
    80005a3c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005a3e:	0a868613          	addi	a2,a3,168
    80005a42:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005a44:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005a46:	6390                	ld	a2,0(a5)
    80005a48:	00d605b3          	add	a1,a2,a3
    80005a4c:	4741                	li	a4,16
    80005a4e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005a50:	4805                	li	a6,1
    80005a52:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005a56:	f9442703          	lw	a4,-108(s0)
    80005a5a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005a5e:	0712                	slli	a4,a4,0x4
    80005a60:	963a                	add	a2,a2,a4
    80005a62:	058a0593          	addi	a1,s4,88
    80005a66:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005a68:	0007b883          	ld	a7,0(a5)
    80005a6c:	9746                	add	a4,a4,a7
    80005a6e:	40000613          	li	a2,1024
    80005a72:	c710                	sw	a2,8(a4)
  if(write)
    80005a74:	001bb613          	seqz	a2,s7
    80005a78:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005a7c:	00166613          	ori	a2,a2,1
    80005a80:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005a84:	f9842583          	lw	a1,-104(s0)
    80005a88:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005a8c:	00250613          	addi	a2,a0,2
    80005a90:	0612                	slli	a2,a2,0x4
    80005a92:	963e                	add	a2,a2,a5
    80005a94:	577d                	li	a4,-1
    80005a96:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005a9a:	0592                	slli	a1,a1,0x4
    80005a9c:	98ae                	add	a7,a7,a1
    80005a9e:	03068713          	addi	a4,a3,48
    80005aa2:	973e                	add	a4,a4,a5
    80005aa4:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005aa8:	6398                	ld	a4,0(a5)
    80005aaa:	972e                	add	a4,a4,a1
    80005aac:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005ab0:	4689                	li	a3,2
    80005ab2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005ab6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005aba:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80005abe:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005ac2:	6794                	ld	a3,8(a5)
    80005ac4:	0026d703          	lhu	a4,2(a3)
    80005ac8:	8b1d                	andi	a4,a4,7
    80005aca:	0706                	slli	a4,a4,0x1
    80005acc:	96ba                	add	a3,a3,a4
    80005ace:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005ad2:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005ad6:	6798                	ld	a4,8(a5)
    80005ad8:	00275783          	lhu	a5,2(a4)
    80005adc:	2785                	addiw	a5,a5,1
    80005ade:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005ae2:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005ae6:	100017b7          	lui	a5,0x10001
    80005aea:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005aee:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80005af2:	0001e917          	auipc	s2,0x1e
    80005af6:	cb690913          	addi	s2,s2,-842 # 800237a8 <disk+0x128>
  while(b->disk == 1) {
    80005afa:	4485                	li	s1,1
    80005afc:	01079a63          	bne	a5,a6,80005b10 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005b00:	85ca                	mv	a1,s2
    80005b02:	8552                	mv	a0,s4
    80005b04:	bdefc0ef          	jal	80001ee2 <sleep>
  while(b->disk == 1) {
    80005b08:	004a2783          	lw	a5,4(s4)
    80005b0c:	fe978ae3          	beq	a5,s1,80005b00 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005b10:	f9042903          	lw	s2,-112(s0)
    80005b14:	00290713          	addi	a4,s2,2
    80005b18:	0712                	slli	a4,a4,0x4
    80005b1a:	0001e797          	auipc	a5,0x1e
    80005b1e:	b6678793          	addi	a5,a5,-1178 # 80023680 <disk>
    80005b22:	97ba                	add	a5,a5,a4
    80005b24:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005b28:	0001e997          	auipc	s3,0x1e
    80005b2c:	b5898993          	addi	s3,s3,-1192 # 80023680 <disk>
    80005b30:	00491713          	slli	a4,s2,0x4
    80005b34:	0009b783          	ld	a5,0(s3)
    80005b38:	97ba                	add	a5,a5,a4
    80005b3a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005b3e:	854a                	mv	a0,s2
    80005b40:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005b44:	bafff0ef          	jal	800056f2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005b48:	8885                	andi	s1,s1,1
    80005b4a:	f0fd                	bnez	s1,80005b30 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005b4c:	0001e517          	auipc	a0,0x1e
    80005b50:	c5c50513          	addi	a0,a0,-932 # 800237a8 <disk+0x128>
    80005b54:	96cfb0ef          	jal	80000cc0 <release>
}
    80005b58:	70a6                	ld	ra,104(sp)
    80005b5a:	7406                	ld	s0,96(sp)
    80005b5c:	64e6                	ld	s1,88(sp)
    80005b5e:	6946                	ld	s2,80(sp)
    80005b60:	69a6                	ld	s3,72(sp)
    80005b62:	6a06                	ld	s4,64(sp)
    80005b64:	7ae2                	ld	s5,56(sp)
    80005b66:	7b42                	ld	s6,48(sp)
    80005b68:	7ba2                	ld	s7,40(sp)
    80005b6a:	7c02                	ld	s8,32(sp)
    80005b6c:	6ce2                	ld	s9,24(sp)
    80005b6e:	6165                	addi	sp,sp,112
    80005b70:	8082                	ret

0000000080005b72 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005b72:	1101                	addi	sp,sp,-32
    80005b74:	ec06                	sd	ra,24(sp)
    80005b76:	e822                	sd	s0,16(sp)
    80005b78:	e426                	sd	s1,8(sp)
    80005b7a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005b7c:	0001e497          	auipc	s1,0x1e
    80005b80:	b0448493          	addi	s1,s1,-1276 # 80023680 <disk>
    80005b84:	0001e517          	auipc	a0,0x1e
    80005b88:	c2450513          	addi	a0,a0,-988 # 800237a8 <disk+0x128>
    80005b8c:	89cfb0ef          	jal	80000c28 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005b90:	100017b7          	lui	a5,0x10001
    80005b94:	53b8                	lw	a4,96(a5)
    80005b96:	8b0d                	andi	a4,a4,3
    80005b98:	100017b7          	lui	a5,0x10001
    80005b9c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80005b9e:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005ba2:	689c                	ld	a5,16(s1)
    80005ba4:	0204d703          	lhu	a4,32(s1)
    80005ba8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005bac:	04f70663          	beq	a4,a5,80005bf8 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005bb0:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005bb4:	6898                	ld	a4,16(s1)
    80005bb6:	0204d783          	lhu	a5,32(s1)
    80005bba:	8b9d                	andi	a5,a5,7
    80005bbc:	078e                	slli	a5,a5,0x3
    80005bbe:	97ba                	add	a5,a5,a4
    80005bc0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005bc2:	00278713          	addi	a4,a5,2
    80005bc6:	0712                	slli	a4,a4,0x4
    80005bc8:	9726                	add	a4,a4,s1
    80005bca:	01074703          	lbu	a4,16(a4)
    80005bce:	e321                	bnez	a4,80005c0e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005bd0:	0789                	addi	a5,a5,2
    80005bd2:	0792                	slli	a5,a5,0x4
    80005bd4:	97a6                	add	a5,a5,s1
    80005bd6:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005bd8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005bdc:	b52fc0ef          	jal	80001f2e <wakeup>

    disk.used_idx += 1;
    80005be0:	0204d783          	lhu	a5,32(s1)
    80005be4:	2785                	addiw	a5,a5,1
    80005be6:	17c2                	slli	a5,a5,0x30
    80005be8:	93c1                	srli	a5,a5,0x30
    80005bea:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005bee:	6898                	ld	a4,16(s1)
    80005bf0:	00275703          	lhu	a4,2(a4)
    80005bf4:	faf71ee3          	bne	a4,a5,80005bb0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005bf8:	0001e517          	auipc	a0,0x1e
    80005bfc:	bb050513          	addi	a0,a0,-1104 # 800237a8 <disk+0x128>
    80005c00:	8c0fb0ef          	jal	80000cc0 <release>
}
    80005c04:	60e2                	ld	ra,24(sp)
    80005c06:	6442                	ld	s0,16(sp)
    80005c08:	64a2                	ld	s1,8(sp)
    80005c0a:	6105                	addi	sp,sp,32
    80005c0c:	8082                	ret
      panic("virtio_disk_intr status");
    80005c0e:	00002517          	auipc	a0,0x2
    80005c12:	b6250513          	addi	a0,a0,-1182 # 80007770 <etext+0x770>
    80005c16:	bb3fa0ef          	jal	800007c8 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	8282                	jr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
