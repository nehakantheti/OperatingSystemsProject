
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	65013103          	ld	sp,1616(sp) # 8000a650 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	04e000ef          	jal	80000064 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e406                	sd	ra,8(sp)
    80000020:	e022                	sd	s0,0(sp)
    80000022:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000024:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000028:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002c:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80000030:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000034:	577d                	li	a4,-1
    80000036:	177e                	slli	a4,a4,0x3f
    80000038:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    8000003a:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003e:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000042:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000046:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    8000004a:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004e:	000f4737          	lui	a4,0xf4
    80000052:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000056:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000058:	14d79073          	csrw	stimecmp,a5
}
    8000005c:	60a2                	ld	ra,8(sp)
    8000005e:	6402                	ld	s0,0(sp)
    80000060:	0141                	addi	sp,sp,16
    80000062:	8082                	ret

0000000080000064 <start>:
{
    80000064:	1141                	addi	sp,sp,-16
    80000066:	e406                	sd	ra,8(sp)
    80000068:	e022                	sd	s0,0(sp)
    8000006a:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006c:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000070:	7779                	lui	a4,0xffffe
    80000072:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdae1f>
    80000076:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000078:	6705                	lui	a4,0x1
    8000007a:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000080:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000084:	00001797          	auipc	a5,0x1
    80000088:	e3878793          	addi	a5,a5,-456 # 80000ebc <main>
    8000008c:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80000090:	4781                	li	a5,0
    80000092:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000096:	67c1                	lui	a5,0x10
    80000098:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000009a:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009e:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000a2:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000a6:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000aa:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000ae:	57fd                	li	a5,-1
    800000b0:	83a9                	srli	a5,a5,0xa
    800000b2:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b6:	47bd                	li	a5,15
    800000b8:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000bc:	f61ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000c0:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c4:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c6:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c8:	30200073          	mret
}
    800000cc:	60a2                	ld	ra,8(sp)
    800000ce:	6402                	ld	s0,0(sp)
    800000d0:	0141                	addi	sp,sp,16
    800000d2:	8082                	ret

00000000800000d4 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d4:	711d                	addi	sp,sp,-96
    800000d6:	ec86                	sd	ra,88(sp)
    800000d8:	e8a2                	sd	s0,80(sp)
    800000da:	e0ca                	sd	s2,64(sp)
    800000dc:	1080                	addi	s0,sp,96
  int i;

  for(i = 0; i < n; i++){
    800000de:	04c05863          	blez	a2,8000012e <consolewrite+0x5a>
    800000e2:	e4a6                	sd	s1,72(sp)
    800000e4:	fc4e                	sd	s3,56(sp)
    800000e6:	f852                	sd	s4,48(sp)
    800000e8:	f456                	sd	s5,40(sp)
    800000ea:	f05a                	sd	s6,32(sp)
    800000ec:	ec5e                	sd	s7,24(sp)
    800000ee:	8a2a                	mv	s4,a0
    800000f0:	84ae                	mv	s1,a1
    800000f2:	89b2                	mv	s3,a2
    800000f4:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    800000f6:	faf40b93          	addi	s7,s0,-81
    800000fa:	4b05                	li	s6,1
    800000fc:	5afd                	li	s5,-1
    800000fe:	86da                	mv	a3,s6
    80000100:	8626                	mv	a2,s1
    80000102:	85d2                	mv	a1,s4
    80000104:	855e                	mv	a0,s7
    80000106:	17c020ef          	jal	80002282 <either_copyin>
    8000010a:	03550463          	beq	a0,s5,80000132 <consolewrite+0x5e>
      break;
    uartputc(c);
    8000010e:	faf44503          	lbu	a0,-81(s0)
    80000112:	065000ef          	jal	80000976 <uartputc>
  for(i = 0; i < n; i++){
    80000116:	2905                	addiw	s2,s2,1
    80000118:	0485                	addi	s1,s1,1
    8000011a:	ff2992e3          	bne	s3,s2,800000fe <consolewrite+0x2a>
    8000011e:	894e                	mv	s2,s3
    80000120:	64a6                	ld	s1,72(sp)
    80000122:	79e2                	ld	s3,56(sp)
    80000124:	7a42                	ld	s4,48(sp)
    80000126:	7aa2                	ld	s5,40(sp)
    80000128:	7b02                	ld	s6,32(sp)
    8000012a:	6be2                	ld	s7,24(sp)
    8000012c:	a809                	j	8000013e <consolewrite+0x6a>
    8000012e:	4901                	li	s2,0
    80000130:	a039                	j	8000013e <consolewrite+0x6a>
    80000132:	64a6                	ld	s1,72(sp)
    80000134:	79e2                	ld	s3,56(sp)
    80000136:	7a42                	ld	s4,48(sp)
    80000138:	7aa2                	ld	s5,40(sp)
    8000013a:	7b02                	ld	s6,32(sp)
    8000013c:	6be2                	ld	s7,24(sp)
  }

  return i;
}
    8000013e:	854a                	mv	a0,s2
    80000140:	60e6                	ld	ra,88(sp)
    80000142:	6446                	ld	s0,80(sp)
    80000144:	6906                	ld	s2,64(sp)
    80000146:	6125                	addi	sp,sp,96
    80000148:	8082                	ret

000000008000014a <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000014a:	711d                	addi	sp,sp,-96
    8000014c:	ec86                	sd	ra,88(sp)
    8000014e:	e8a2                	sd	s0,80(sp)
    80000150:	e4a6                	sd	s1,72(sp)
    80000152:	e0ca                	sd	s2,64(sp)
    80000154:	fc4e                	sd	s3,56(sp)
    80000156:	f852                	sd	s4,48(sp)
    80000158:	f456                	sd	s5,40(sp)
    8000015a:	f05a                	sd	s6,32(sp)
    8000015c:	1080                	addi	s0,sp,96
    8000015e:	8aaa                	mv	s5,a0
    80000160:	8a2e                	mv	s4,a1
    80000162:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000164:	8b32                	mv	s6,a2
  acquire(&cons.lock);
    80000166:	00012517          	auipc	a0,0x12
    8000016a:	54a50513          	addi	a0,a0,1354 # 800126b0 <cons>
    8000016e:	2c9000ef          	jal	80000c36 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000172:	00012497          	auipc	s1,0x12
    80000176:	53e48493          	addi	s1,s1,1342 # 800126b0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000017a:	00012917          	auipc	s2,0x12
    8000017e:	5ce90913          	addi	s2,s2,1486 # 80012748 <cons+0x98>
  while(n > 0){
    80000182:	0b305b63          	blez	s3,80000238 <consoleread+0xee>
    while(cons.r == cons.w){
    80000186:	0984a783          	lw	a5,152(s1)
    8000018a:	09c4a703          	lw	a4,156(s1)
    8000018e:	0af71063          	bne	a4,a5,8000022e <consoleread+0xe4>
      if(killed(myproc())){
    80000192:	782010ef          	jal	80001914 <myproc>
    80000196:	785010ef          	jal	8000211a <killed>
    8000019a:	e12d                	bnez	a0,800001fc <consoleread+0xb2>
      sleep(&cons.r, &cons.lock);
    8000019c:	85a6                	mv	a1,s1
    8000019e:	854a                	mv	a0,s2
    800001a0:	543010ef          	jal	80001ee2 <sleep>
    while(cons.r == cons.w){
    800001a4:	0984a783          	lw	a5,152(s1)
    800001a8:	09c4a703          	lw	a4,156(s1)
    800001ac:	fef703e3          	beq	a4,a5,80000192 <consoleread+0x48>
    800001b0:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001b2:	00012717          	auipc	a4,0x12
    800001b6:	4fe70713          	addi	a4,a4,1278 # 800126b0 <cons>
    800001ba:	0017869b          	addiw	a3,a5,1
    800001be:	08d72c23          	sw	a3,152(a4)
    800001c2:	07f7f693          	andi	a3,a5,127
    800001c6:	9736                	add	a4,a4,a3
    800001c8:	01874703          	lbu	a4,24(a4)
    800001cc:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001d0:	4691                	li	a3,4
    800001d2:	04db8663          	beq	s7,a3,8000021e <consoleread+0xd4>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001d6:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001da:	4685                	li	a3,1
    800001dc:	faf40613          	addi	a2,s0,-81
    800001e0:	85d2                	mv	a1,s4
    800001e2:	8556                	mv	a0,s5
    800001e4:	054020ef          	jal	80002238 <either_copyout>
    800001e8:	57fd                	li	a5,-1
    800001ea:	04f50663          	beq	a0,a5,80000236 <consoleread+0xec>
      break;

    dst++;
    800001ee:	0a05                	addi	s4,s4,1
    --n;
    800001f0:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    800001f2:	47a9                	li	a5,10
    800001f4:	04fb8b63          	beq	s7,a5,8000024a <consoleread+0x100>
    800001f8:	6be2                	ld	s7,24(sp)
    800001fa:	b761                	j	80000182 <consoleread+0x38>
        release(&cons.lock);
    800001fc:	00012517          	auipc	a0,0x12
    80000200:	4b450513          	addi	a0,a0,1204 # 800126b0 <cons>
    80000204:	2c7000ef          	jal	80000cca <release>
        return -1;
    80000208:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    8000020a:	60e6                	ld	ra,88(sp)
    8000020c:	6446                	ld	s0,80(sp)
    8000020e:	64a6                	ld	s1,72(sp)
    80000210:	6906                	ld	s2,64(sp)
    80000212:	79e2                	ld	s3,56(sp)
    80000214:	7a42                	ld	s4,48(sp)
    80000216:	7aa2                	ld	s5,40(sp)
    80000218:	7b02                	ld	s6,32(sp)
    8000021a:	6125                	addi	sp,sp,96
    8000021c:	8082                	ret
      if(n < target){
    8000021e:	0169fa63          	bgeu	s3,s6,80000232 <consoleread+0xe8>
        cons.r--;
    80000222:	00012717          	auipc	a4,0x12
    80000226:	52f72323          	sw	a5,1318(a4) # 80012748 <cons+0x98>
    8000022a:	6be2                	ld	s7,24(sp)
    8000022c:	a031                	j	80000238 <consoleread+0xee>
    8000022e:	ec5e                	sd	s7,24(sp)
    80000230:	b749                	j	800001b2 <consoleread+0x68>
    80000232:	6be2                	ld	s7,24(sp)
    80000234:	a011                	j	80000238 <consoleread+0xee>
    80000236:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000238:	00012517          	auipc	a0,0x12
    8000023c:	47850513          	addi	a0,a0,1144 # 800126b0 <cons>
    80000240:	28b000ef          	jal	80000cca <release>
  return target - n;
    80000244:	413b053b          	subw	a0,s6,s3
    80000248:	b7c9                	j	8000020a <consoleread+0xc0>
    8000024a:	6be2                	ld	s7,24(sp)
    8000024c:	b7f5                	j	80000238 <consoleread+0xee>

000000008000024e <microdelay>:
void microdelay(int us){
    8000024e:	1101                	addi	sp,sp,-32
    80000250:	ec06                	sd	ra,24(sp)
    80000252:	e822                	sd	s0,16(sp)
    80000254:	1000                	addi	s0,sp,32
  volatile uint64 i = 0;
    80000256:	fe043423          	sd	zero,-24(s0)
  while(i < us*12){     // Adjust multiplier based on your CPU speed
    8000025a:	0015171b          	slliw	a4,a0,0x1
    8000025e:	9f29                	addw	a4,a4,a0
    80000260:	0027171b          	slliw	a4,a4,0x2
    80000264:	fe843783          	ld	a5,-24(s0)
    80000268:	00e7fb63          	bgeu	a5,a4,8000027e <microdelay+0x30>
    i++;
    8000026c:	fe843783          	ld	a5,-24(s0)
    80000270:	0785                	addi	a5,a5,1
    80000272:	fef43423          	sd	a5,-24(s0)
  while(i < us*12){     // Adjust multiplier based on your CPU speed
    80000276:	fe843783          	ld	a5,-24(s0)
    8000027a:	fee7e9e3          	bltu	a5,a4,8000026c <microdelay+0x1e>
}
    8000027e:	60e2                	ld	ra,24(sp)
    80000280:	6442                	ld	s0,16(sp)
    80000282:	6105                	addi	sp,sp,32
    80000284:	8082                	ret

0000000080000286 <consputc>:
{
    80000286:	1141                	addi	sp,sp,-16
    80000288:	e406                	sd	ra,8(sp)
    8000028a:	e022                	sd	s0,0(sp)
    8000028c:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000028e:	10000793          	li	a5,256
    80000292:	00f50863          	beq	a0,a5,800002a2 <consputc+0x1c>
    uartputc_sync(c);
    80000296:	5fe000ef          	jal	80000894 <uartputc_sync>
}
    8000029a:	60a2                	ld	ra,8(sp)
    8000029c:	6402                	ld	s0,0(sp)
    8000029e:	0141                	addi	sp,sp,16
    800002a0:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002a2:	4521                	li	a0,8
    800002a4:	5f0000ef          	jal	80000894 <uartputc_sync>
    800002a8:	02000513          	li	a0,32
    800002ac:	5e8000ef          	jal	80000894 <uartputc_sync>
    800002b0:	4521                	li	a0,8
    800002b2:	5e2000ef          	jal	80000894 <uartputc_sync>
    800002b6:	b7d5                	j	8000029a <consputc+0x14>

00000000800002b8 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002b8:	7179                	addi	sp,sp,-48
    800002ba:	f406                	sd	ra,40(sp)
    800002bc:	f022                	sd	s0,32(sp)
    800002be:	ec26                	sd	s1,24(sp)
    800002c0:	1800                	addi	s0,sp,48
    800002c2:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c4:	00012517          	auipc	a0,0x12
    800002c8:	3ec50513          	addi	a0,a0,1004 # 800126b0 <cons>
    800002cc:	16b000ef          	jal	80000c36 <acquire>

  switch(c){
    800002d0:	47d5                	li	a5,21
    800002d2:	08f48e63          	beq	s1,a5,8000036e <consoleintr+0xb6>
    800002d6:	0297c563          	blt	a5,s1,80000300 <consoleintr+0x48>
    800002da:	47a1                	li	a5,8
    800002dc:	0ef48863          	beq	s1,a5,800003cc <consoleintr+0x114>
    800002e0:	47c1                	li	a5,16
    800002e2:	10f49963          	bne	s1,a5,800003f4 <consoleintr+0x13c>
  case C('P'):  // Print process list.
    procdump();
    800002e6:	7e7010ef          	jal	800022cc <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002ea:	00012517          	auipc	a0,0x12
    800002ee:	3c650513          	addi	a0,a0,966 # 800126b0 <cons>
    800002f2:	1d9000ef          	jal	80000cca <release>
}
    800002f6:	70a2                	ld	ra,40(sp)
    800002f8:	7402                	ld	s0,32(sp)
    800002fa:	64e2                	ld	s1,24(sp)
    800002fc:	6145                	addi	sp,sp,48
    800002fe:	8082                	ret
  switch(c){
    80000300:	07f00793          	li	a5,127
    80000304:	0cf48463          	beq	s1,a5,800003cc <consoleintr+0x114>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000308:	00012717          	auipc	a4,0x12
    8000030c:	3a870713          	addi	a4,a4,936 # 800126b0 <cons>
    80000310:	0a072783          	lw	a5,160(a4)
    80000314:	09872703          	lw	a4,152(a4)
    80000318:	9f99                	subw	a5,a5,a4
    8000031a:	07f00713          	li	a4,127
    8000031e:	fcf766e3          	bltu	a4,a5,800002ea <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000322:	47b5                	li	a5,13
    80000324:	0cf48b63          	beq	s1,a5,800003fa <consoleintr+0x142>
      consputc(c);
    80000328:	8526                	mv	a0,s1
    8000032a:	f5dff0ef          	jal	80000286 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000032e:	00012797          	auipc	a5,0x12
    80000332:	38278793          	addi	a5,a5,898 # 800126b0 <cons>
    80000336:	0a07a683          	lw	a3,160(a5)
    8000033a:	0016871b          	addiw	a4,a3,1
    8000033e:	863a                	mv	a2,a4
    80000340:	0ae7a023          	sw	a4,160(a5)
    80000344:	07f6f693          	andi	a3,a3,127
    80000348:	97b6                	add	a5,a5,a3
    8000034a:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000034e:	47a9                	li	a5,10
    80000350:	0cf48963          	beq	s1,a5,80000422 <consoleintr+0x16a>
    80000354:	4791                	li	a5,4
    80000356:	0cf48663          	beq	s1,a5,80000422 <consoleintr+0x16a>
    8000035a:	00012797          	auipc	a5,0x12
    8000035e:	3ee7a783          	lw	a5,1006(a5) # 80012748 <cons+0x98>
    80000362:	9f1d                	subw	a4,a4,a5
    80000364:	08000793          	li	a5,128
    80000368:	f8f711e3          	bne	a4,a5,800002ea <consoleintr+0x32>
    8000036c:	a85d                	j	80000422 <consoleintr+0x16a>
    8000036e:	e84a                	sd	s2,16(sp)
    80000370:	e44e                	sd	s3,8(sp)
    while(cons.e != cons.w &&
    80000372:	00012717          	auipc	a4,0x12
    80000376:	33e70713          	addi	a4,a4,830 # 800126b0 <cons>
    8000037a:	0a072783          	lw	a5,160(a4)
    8000037e:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000382:	00012497          	auipc	s1,0x12
    80000386:	32e48493          	addi	s1,s1,814 # 800126b0 <cons>
    while(cons.e != cons.w &&
    8000038a:	4929                	li	s2,10
      consputc(BACKSPACE);
    8000038c:	10000993          	li	s3,256
    while(cons.e != cons.w &&
    80000390:	02f70863          	beq	a4,a5,800003c0 <consoleintr+0x108>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000394:	37fd                	addiw	a5,a5,-1
    80000396:	07f7f713          	andi	a4,a5,127
    8000039a:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    8000039c:	01874703          	lbu	a4,24(a4)
    800003a0:	03270363          	beq	a4,s2,800003c6 <consoleintr+0x10e>
      cons.e--;
    800003a4:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003a8:	854e                	mv	a0,s3
    800003aa:	eddff0ef          	jal	80000286 <consputc>
    while(cons.e != cons.w &&
    800003ae:	0a04a783          	lw	a5,160(s1)
    800003b2:	09c4a703          	lw	a4,156(s1)
    800003b6:	fcf71fe3          	bne	a4,a5,80000394 <consoleintr+0xdc>
    800003ba:	6942                	ld	s2,16(sp)
    800003bc:	69a2                	ld	s3,8(sp)
    800003be:	b735                	j	800002ea <consoleintr+0x32>
    800003c0:	6942                	ld	s2,16(sp)
    800003c2:	69a2                	ld	s3,8(sp)
    800003c4:	b71d                	j	800002ea <consoleintr+0x32>
    800003c6:	6942                	ld	s2,16(sp)
    800003c8:	69a2                	ld	s3,8(sp)
    800003ca:	b705                	j	800002ea <consoleintr+0x32>
    if(cons.e != cons.w){
    800003cc:	00012717          	auipc	a4,0x12
    800003d0:	2e470713          	addi	a4,a4,740 # 800126b0 <cons>
    800003d4:	0a072783          	lw	a5,160(a4)
    800003d8:	09c72703          	lw	a4,156(a4)
    800003dc:	f0f707e3          	beq	a4,a5,800002ea <consoleintr+0x32>
      cons.e--;
    800003e0:	37fd                	addiw	a5,a5,-1
    800003e2:	00012717          	auipc	a4,0x12
    800003e6:	36f72723          	sw	a5,878(a4) # 80012750 <cons+0xa0>
      consputc(BACKSPACE);
    800003ea:	10000513          	li	a0,256
    800003ee:	e99ff0ef          	jal	80000286 <consputc>
    800003f2:	bde5                	j	800002ea <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003f4:	ee048be3          	beqz	s1,800002ea <consoleintr+0x32>
    800003f8:	bf01                	j	80000308 <consoleintr+0x50>
      consputc(c);
    800003fa:	4529                	li	a0,10
    800003fc:	e8bff0ef          	jal	80000286 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000400:	00012797          	auipc	a5,0x12
    80000404:	2b078793          	addi	a5,a5,688 # 800126b0 <cons>
    80000408:	0a07a703          	lw	a4,160(a5)
    8000040c:	0017069b          	addiw	a3,a4,1
    80000410:	8636                	mv	a2,a3
    80000412:	0ad7a023          	sw	a3,160(a5)
    80000416:	07f77713          	andi	a4,a4,127
    8000041a:	97ba                	add	a5,a5,a4
    8000041c:	4729                	li	a4,10
    8000041e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000422:	00012797          	auipc	a5,0x12
    80000426:	32c7a523          	sw	a2,810(a5) # 8001274c <cons+0x9c>
        wakeup(&cons.r);
    8000042a:	00012517          	auipc	a0,0x12
    8000042e:	31e50513          	addi	a0,a0,798 # 80012748 <cons+0x98>
    80000432:	2fd010ef          	jal	80001f2e <wakeup>
    80000436:	bd55                	j	800002ea <consoleintr+0x32>

0000000080000438 <consoleinit>:

void
consoleinit(void)
{
    80000438:	1141                	addi	sp,sp,-16
    8000043a:	e406                	sd	ra,8(sp)
    8000043c:	e022                	sd	s0,0(sp)
    8000043e:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000440:	00007597          	auipc	a1,0x7
    80000444:	bc058593          	addi	a1,a1,-1088 # 80007000 <etext>
    80000448:	00012517          	auipc	a0,0x12
    8000044c:	26850513          	addi	a0,a0,616 # 800126b0 <cons>
    80000450:	762000ef          	jal	80000bb2 <initlock>

  uartinit();
    80000454:	3ea000ef          	jal	8000083e <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000458:	00022797          	auipc	a5,0x22
    8000045c:	3f078793          	addi	a5,a5,1008 # 80022848 <devsw>
    80000460:	00000717          	auipc	a4,0x0
    80000464:	cea70713          	addi	a4,a4,-790 # 8000014a <consoleread>
    80000468:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000046a:	00000717          	auipc	a4,0x0
    8000046e:	c6a70713          	addi	a4,a4,-918 # 800000d4 <consolewrite>
    80000472:	ef98                	sd	a4,24(a5)
}
    80000474:	60a2                	ld	ra,8(sp)
    80000476:	6402                	ld	s0,0(sp)
    80000478:	0141                	addi	sp,sp,16
    8000047a:	8082                	ret

000000008000047c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    8000047c:	7179                	addi	sp,sp,-48
    8000047e:	f406                	sd	ra,40(sp)
    80000480:	f022                	sd	s0,32(sp)
    80000482:	ec26                	sd	s1,24(sp)
    80000484:	e84a                	sd	s2,16(sp)
    80000486:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000488:	c219                	beqz	a2,8000048e <printint+0x12>
    8000048a:	06054a63          	bltz	a0,800004fe <printint+0x82>
    x = -xx;
  else
    x = xx;
    8000048e:	4e01                	li	t3,0

  i = 0;
    80000490:	fd040313          	addi	t1,s0,-48
    x = xx;
    80000494:	869a                	mv	a3,t1
  i = 0;
    80000496:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80000498:	00007817          	auipc	a6,0x7
    8000049c:	2d880813          	addi	a6,a6,728 # 80007770 <digits>
    800004a0:	88be                	mv	a7,a5
    800004a2:	0017861b          	addiw	a2,a5,1
    800004a6:	87b2                	mv	a5,a2
    800004a8:	02b57733          	remu	a4,a0,a1
    800004ac:	9742                	add	a4,a4,a6
    800004ae:	00074703          	lbu	a4,0(a4)
    800004b2:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    800004b6:	872a                	mv	a4,a0
    800004b8:	02b55533          	divu	a0,a0,a1
    800004bc:	0685                	addi	a3,a3,1
    800004be:	feb771e3          	bgeu	a4,a1,800004a0 <printint+0x24>

  if(sign)
    800004c2:	000e0c63          	beqz	t3,800004da <printint+0x5e>
    buf[i++] = '-';
    800004c6:	fe060793          	addi	a5,a2,-32
    800004ca:	00878633          	add	a2,a5,s0
    800004ce:	02d00793          	li	a5,45
    800004d2:	fef60823          	sb	a5,-16(a2)
    800004d6:	0028879b          	addiw	a5,a7,2

  while(--i >= 0)
    800004da:	fff7891b          	addiw	s2,a5,-1
    800004de:	006784b3          	add	s1,a5,t1
    consputc(buf[i]);
    800004e2:	fff4c503          	lbu	a0,-1(s1)
    800004e6:	da1ff0ef          	jal	80000286 <consputc>
  while(--i >= 0)
    800004ea:	397d                	addiw	s2,s2,-1
    800004ec:	14fd                	addi	s1,s1,-1
    800004ee:	fe095ae3          	bgez	s2,800004e2 <printint+0x66>
}
    800004f2:	70a2                	ld	ra,40(sp)
    800004f4:	7402                	ld	s0,32(sp)
    800004f6:	64e2                	ld	s1,24(sp)
    800004f8:	6942                	ld	s2,16(sp)
    800004fa:	6145                	addi	sp,sp,48
    800004fc:	8082                	ret
    x = -xx;
    800004fe:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    80000502:	4e05                	li	t3,1
    x = -xx;
    80000504:	b771                	j	80000490 <printint+0x14>

0000000080000506 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    80000506:	7155                	addi	sp,sp,-208
    80000508:	e506                	sd	ra,136(sp)
    8000050a:	e122                	sd	s0,128(sp)
    8000050c:	f0d2                	sd	s4,96(sp)
    8000050e:	0900                	addi	s0,sp,144
    80000510:	8a2a                	mv	s4,a0
    80000512:	e40c                	sd	a1,8(s0)
    80000514:	e810                	sd	a2,16(s0)
    80000516:	ec14                	sd	a3,24(s0)
    80000518:	f018                	sd	a4,32(s0)
    8000051a:	f41c                	sd	a5,40(s0)
    8000051c:	03043823          	sd	a6,48(s0)
    80000520:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    80000524:	00012797          	auipc	a5,0x12
    80000528:	24c7a783          	lw	a5,588(a5) # 80012770 <pr+0x18>
    8000052c:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    80000530:	e3a1                	bnez	a5,80000570 <printf+0x6a>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000532:	00840793          	addi	a5,s0,8
    80000536:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000053a:	00054503          	lbu	a0,0(a0)
    8000053e:	26050663          	beqz	a0,800007aa <printf+0x2a4>
    80000542:	fca6                	sd	s1,120(sp)
    80000544:	f8ca                	sd	s2,112(sp)
    80000546:	f4ce                	sd	s3,104(sp)
    80000548:	ecd6                	sd	s5,88(sp)
    8000054a:	e8da                	sd	s6,80(sp)
    8000054c:	e0e2                	sd	s8,64(sp)
    8000054e:	fc66                	sd	s9,56(sp)
    80000550:	f86a                	sd	s10,48(sp)
    80000552:	f46e                	sd	s11,40(sp)
    80000554:	4981                	li	s3,0
    if(cx != '%'){
    80000556:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    8000055a:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000055e:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    80000562:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000566:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    8000056a:	07000d93          	li	s11,112
    8000056e:	a80d                	j	800005a0 <printf+0x9a>
    acquire(&pr.lock);
    80000570:	00012517          	auipc	a0,0x12
    80000574:	1e850513          	addi	a0,a0,488 # 80012758 <pr>
    80000578:	6be000ef          	jal	80000c36 <acquire>
  va_start(ap, fmt);
    8000057c:	00840793          	addi	a5,s0,8
    80000580:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000584:	000a4503          	lbu	a0,0(s4)
    80000588:	fd4d                	bnez	a0,80000542 <printf+0x3c>
    8000058a:	ac3d                	j	800007c8 <printf+0x2c2>
      consputc(cx);
    8000058c:	cfbff0ef          	jal	80000286 <consputc>
      continue;
    80000590:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000592:	2485                	addiw	s1,s1,1
    80000594:	89a6                	mv	s3,s1
    80000596:	94d2                	add	s1,s1,s4
    80000598:	0004c503          	lbu	a0,0(s1)
    8000059c:	1e050b63          	beqz	a0,80000792 <printf+0x28c>
    if(cx != '%'){
    800005a0:	ff5516e3          	bne	a0,s5,8000058c <printf+0x86>
    i++;
    800005a4:	0019879b          	addiw	a5,s3,1
    800005a8:	84be                	mv	s1,a5
    c0 = fmt[i+0] & 0xff;
    800005aa:	00fa0733          	add	a4,s4,a5
    800005ae:	00074903          	lbu	s2,0(a4)
    if(c0) c1 = fmt[i+1] & 0xff;
    800005b2:	1e090063          	beqz	s2,80000792 <printf+0x28c>
    800005b6:	00174703          	lbu	a4,1(a4)
    c1 = c2 = 0;
    800005ba:	86ba                	mv	a3,a4
    if(c1) c2 = fmt[i+2] & 0xff;
    800005bc:	c701                	beqz	a4,800005c4 <printf+0xbe>
    800005be:	97d2                	add	a5,a5,s4
    800005c0:	0027c683          	lbu	a3,2(a5)
    if(c0 == 'd'){
    800005c4:	03690763          	beq	s2,s6,800005f2 <printf+0xec>
    } else if(c0 == 'l' && c1 == 'd'){
    800005c8:	05890163          	beq	s2,s8,8000060a <printf+0x104>
    } else if(c0 == 'u'){
    800005cc:	0d990b63          	beq	s2,s9,800006a2 <printf+0x19c>
    } else if(c0 == 'x'){
    800005d0:	13a90163          	beq	s2,s10,800006f2 <printf+0x1ec>
    } else if(c0 == 'p'){
    800005d4:	13b90b63          	beq	s2,s11,8000070a <printf+0x204>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 's'){
    800005d8:	07300793          	li	a5,115
    800005dc:	16f90a63          	beq	s2,a5,80000750 <printf+0x24a>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    800005e0:	1b590463          	beq	s2,s5,80000788 <printf+0x282>
      consputc('%');
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800005e4:	8556                	mv	a0,s5
    800005e6:	ca1ff0ef          	jal	80000286 <consputc>
      consputc(c0);
    800005ea:	854a                	mv	a0,s2
    800005ec:	c9bff0ef          	jal	80000286 <consputc>
    800005f0:	b74d                	j	80000592 <printf+0x8c>
      printint(va_arg(ap, int), 10, 1);
    800005f2:	f8843783          	ld	a5,-120(s0)
    800005f6:	00878713          	addi	a4,a5,8
    800005fa:	f8e43423          	sd	a4,-120(s0)
    800005fe:	4605                	li	a2,1
    80000600:	45a9                	li	a1,10
    80000602:	4388                	lw	a0,0(a5)
    80000604:	e79ff0ef          	jal	8000047c <printint>
    80000608:	b769                	j	80000592 <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'd'){
    8000060a:	03670663          	beq	a4,s6,80000636 <printf+0x130>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    8000060e:	05870263          	beq	a4,s8,80000652 <printf+0x14c>
    } else if(c0 == 'l' && c1 == 'u'){
    80000612:	0b970463          	beq	a4,s9,800006ba <printf+0x1b4>
    } else if(c0 == 'l' && c1 == 'x'){
    80000616:	fda717e3          	bne	a4,s10,800005e4 <printf+0xde>
      printint(va_arg(ap, uint64), 16, 0);
    8000061a:	f8843783          	ld	a5,-120(s0)
    8000061e:	00878713          	addi	a4,a5,8
    80000622:	f8e43423          	sd	a4,-120(s0)
    80000626:	4601                	li	a2,0
    80000628:	45c1                	li	a1,16
    8000062a:	6388                	ld	a0,0(a5)
    8000062c:	e51ff0ef          	jal	8000047c <printint>
      i += 1;
    80000630:	0029849b          	addiw	s1,s3,2
    80000634:	bfb9                	j	80000592 <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    80000636:	f8843783          	ld	a5,-120(s0)
    8000063a:	00878713          	addi	a4,a5,8
    8000063e:	f8e43423          	sd	a4,-120(s0)
    80000642:	4605                	li	a2,1
    80000644:	45a9                	li	a1,10
    80000646:	6388                	ld	a0,0(a5)
    80000648:	e35ff0ef          	jal	8000047c <printint>
      i += 1;
    8000064c:	0029849b          	addiw	s1,s3,2
    80000650:	b789                	j	80000592 <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80000652:	06400793          	li	a5,100
    80000656:	02f68863          	beq	a3,a5,80000686 <printf+0x180>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    8000065a:	07500793          	li	a5,117
    8000065e:	06f68c63          	beq	a3,a5,800006d6 <printf+0x1d0>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    80000662:	07800793          	li	a5,120
    80000666:	f6f69fe3          	bne	a3,a5,800005e4 <printf+0xde>
      printint(va_arg(ap, uint64), 16, 0);
    8000066a:	f8843783          	ld	a5,-120(s0)
    8000066e:	00878713          	addi	a4,a5,8
    80000672:	f8e43423          	sd	a4,-120(s0)
    80000676:	4601                	li	a2,0
    80000678:	45c1                	li	a1,16
    8000067a:	6388                	ld	a0,0(a5)
    8000067c:	e01ff0ef          	jal	8000047c <printint>
      i += 2;
    80000680:	0039849b          	addiw	s1,s3,3
    80000684:	b739                	j	80000592 <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    80000686:	f8843783          	ld	a5,-120(s0)
    8000068a:	00878713          	addi	a4,a5,8
    8000068e:	f8e43423          	sd	a4,-120(s0)
    80000692:	4605                	li	a2,1
    80000694:	45a9                	li	a1,10
    80000696:	6388                	ld	a0,0(a5)
    80000698:	de5ff0ef          	jal	8000047c <printint>
      i += 2;
    8000069c:	0039849b          	addiw	s1,s3,3
    800006a0:	bdcd                	j	80000592 <printf+0x8c>
      printint(va_arg(ap, int), 10, 0);
    800006a2:	f8843783          	ld	a5,-120(s0)
    800006a6:	00878713          	addi	a4,a5,8
    800006aa:	f8e43423          	sd	a4,-120(s0)
    800006ae:	4601                	li	a2,0
    800006b0:	45a9                	li	a1,10
    800006b2:	4388                	lw	a0,0(a5)
    800006b4:	dc9ff0ef          	jal	8000047c <printint>
    800006b8:	bde9                	j	80000592 <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    800006ba:	f8843783          	ld	a5,-120(s0)
    800006be:	00878713          	addi	a4,a5,8
    800006c2:	f8e43423          	sd	a4,-120(s0)
    800006c6:	4601                	li	a2,0
    800006c8:	45a9                	li	a1,10
    800006ca:	6388                	ld	a0,0(a5)
    800006cc:	db1ff0ef          	jal	8000047c <printint>
      i += 1;
    800006d0:	0029849b          	addiw	s1,s3,2
    800006d4:	bd7d                	j	80000592 <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    800006d6:	f8843783          	ld	a5,-120(s0)
    800006da:	00878713          	addi	a4,a5,8
    800006de:	f8e43423          	sd	a4,-120(s0)
    800006e2:	4601                	li	a2,0
    800006e4:	45a9                	li	a1,10
    800006e6:	6388                	ld	a0,0(a5)
    800006e8:	d95ff0ef          	jal	8000047c <printint>
      i += 2;
    800006ec:	0039849b          	addiw	s1,s3,3
    800006f0:	b54d                	j	80000592 <printf+0x8c>
      printint(va_arg(ap, int), 16, 0);
    800006f2:	f8843783          	ld	a5,-120(s0)
    800006f6:	00878713          	addi	a4,a5,8
    800006fa:	f8e43423          	sd	a4,-120(s0)
    800006fe:	4601                	li	a2,0
    80000700:	45c1                	li	a1,16
    80000702:	4388                	lw	a0,0(a5)
    80000704:	d79ff0ef          	jal	8000047c <printint>
    80000708:	b569                	j	80000592 <printf+0x8c>
    8000070a:	e4de                	sd	s7,72(sp)
      printptr(va_arg(ap, uint64));
    8000070c:	f8843783          	ld	a5,-120(s0)
    80000710:	00878713          	addi	a4,a5,8
    80000714:	f8e43423          	sd	a4,-120(s0)
    80000718:	0007b983          	ld	s3,0(a5)
  consputc('0');
    8000071c:	03000513          	li	a0,48
    80000720:	b67ff0ef          	jal	80000286 <consputc>
  consputc('x');
    80000724:	07800513          	li	a0,120
    80000728:	b5fff0ef          	jal	80000286 <consputc>
    8000072c:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000072e:	00007b97          	auipc	s7,0x7
    80000732:	042b8b93          	addi	s7,s7,66 # 80007770 <digits>
    80000736:	03c9d793          	srli	a5,s3,0x3c
    8000073a:	97de                	add	a5,a5,s7
    8000073c:	0007c503          	lbu	a0,0(a5)
    80000740:	b47ff0ef          	jal	80000286 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000744:	0992                	slli	s3,s3,0x4
    80000746:	397d                	addiw	s2,s2,-1
    80000748:	fe0917e3          	bnez	s2,80000736 <printf+0x230>
    8000074c:	6ba6                	ld	s7,72(sp)
    8000074e:	b591                	j	80000592 <printf+0x8c>
      if((s = va_arg(ap, char*)) == 0)
    80000750:	f8843783          	ld	a5,-120(s0)
    80000754:	00878713          	addi	a4,a5,8
    80000758:	f8e43423          	sd	a4,-120(s0)
    8000075c:	0007b903          	ld	s2,0(a5)
    80000760:	00090d63          	beqz	s2,8000077a <printf+0x274>
      for(; *s; s++)
    80000764:	00094503          	lbu	a0,0(s2)
    80000768:	e20505e3          	beqz	a0,80000592 <printf+0x8c>
        consputc(*s);
    8000076c:	b1bff0ef          	jal	80000286 <consputc>
      for(; *s; s++)
    80000770:	0905                	addi	s2,s2,1
    80000772:	00094503          	lbu	a0,0(s2)
    80000776:	f97d                	bnez	a0,8000076c <printf+0x266>
    80000778:	bd29                	j	80000592 <printf+0x8c>
        s = "(null)";
    8000077a:	00007917          	auipc	s2,0x7
    8000077e:	88e90913          	addi	s2,s2,-1906 # 80007008 <etext+0x8>
      for(; *s; s++)
    80000782:	02800513          	li	a0,40
    80000786:	b7dd                	j	8000076c <printf+0x266>
      consputc('%');
    80000788:	02500513          	li	a0,37
    8000078c:	afbff0ef          	jal	80000286 <consputc>
    80000790:	b509                	j	80000592 <printf+0x8c>
    }
#endif
  }
  va_end(ap);

  if(locking)
    80000792:	f7843783          	ld	a5,-136(s0)
    80000796:	e385                	bnez	a5,800007b6 <printf+0x2b0>
    80000798:	74e6                	ld	s1,120(sp)
    8000079a:	7946                	ld	s2,112(sp)
    8000079c:	79a6                	ld	s3,104(sp)
    8000079e:	6ae6                	ld	s5,88(sp)
    800007a0:	6b46                	ld	s6,80(sp)
    800007a2:	6c06                	ld	s8,64(sp)
    800007a4:	7ce2                	ld	s9,56(sp)
    800007a6:	7d42                	ld	s10,48(sp)
    800007a8:	7da2                	ld	s11,40(sp)
    release(&pr.lock);

  return 0;
}
    800007aa:	4501                	li	a0,0
    800007ac:	60aa                	ld	ra,136(sp)
    800007ae:	640a                	ld	s0,128(sp)
    800007b0:	7a06                	ld	s4,96(sp)
    800007b2:	6169                	addi	sp,sp,208
    800007b4:	8082                	ret
    800007b6:	74e6                	ld	s1,120(sp)
    800007b8:	7946                	ld	s2,112(sp)
    800007ba:	79a6                	ld	s3,104(sp)
    800007bc:	6ae6                	ld	s5,88(sp)
    800007be:	6b46                	ld	s6,80(sp)
    800007c0:	6c06                	ld	s8,64(sp)
    800007c2:	7ce2                	ld	s9,56(sp)
    800007c4:	7d42                	ld	s10,48(sp)
    800007c6:	7da2                	ld	s11,40(sp)
    release(&pr.lock);
    800007c8:	00012517          	auipc	a0,0x12
    800007cc:	f9050513          	addi	a0,a0,-112 # 80012758 <pr>
    800007d0:	4fa000ef          	jal	80000cca <release>
    800007d4:	bfd9                	j	800007aa <printf+0x2a4>

00000000800007d6 <panic>:

void
panic(char *s)
{
    800007d6:	1101                	addi	sp,sp,-32
    800007d8:	ec06                	sd	ra,24(sp)
    800007da:	e822                	sd	s0,16(sp)
    800007dc:	e426                	sd	s1,8(sp)
    800007de:	1000                	addi	s0,sp,32
    800007e0:	84aa                	mv	s1,a0
  pr.locking = 0;
    800007e2:	00012797          	auipc	a5,0x12
    800007e6:	f807a723          	sw	zero,-114(a5) # 80012770 <pr+0x18>
  printf("panic: ");
    800007ea:	00007517          	auipc	a0,0x7
    800007ee:	82e50513          	addi	a0,a0,-2002 # 80007018 <etext+0x18>
    800007f2:	d15ff0ef          	jal	80000506 <printf>
  printf("%s\n", s);
    800007f6:	85a6                	mv	a1,s1
    800007f8:	00007517          	auipc	a0,0x7
    800007fc:	82850513          	addi	a0,a0,-2008 # 80007020 <etext+0x20>
    80000800:	d07ff0ef          	jal	80000506 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000804:	4785                	li	a5,1
    80000806:	0000a717          	auipc	a4,0xa
    8000080a:	e6f72523          	sw	a5,-406(a4) # 8000a670 <panicked>
  for(;;)
    8000080e:	a001                	j	8000080e <panic+0x38>

0000000080000810 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000810:	1101                	addi	sp,sp,-32
    80000812:	ec06                	sd	ra,24(sp)
    80000814:	e822                	sd	s0,16(sp)
    80000816:	e426                	sd	s1,8(sp)
    80000818:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000081a:	00012497          	auipc	s1,0x12
    8000081e:	f3e48493          	addi	s1,s1,-194 # 80012758 <pr>
    80000822:	00007597          	auipc	a1,0x7
    80000826:	80658593          	addi	a1,a1,-2042 # 80007028 <etext+0x28>
    8000082a:	8526                	mv	a0,s1
    8000082c:	386000ef          	jal	80000bb2 <initlock>
  pr.locking = 1;
    80000830:	4785                	li	a5,1
    80000832:	cc9c                	sw	a5,24(s1)
}
    80000834:	60e2                	ld	ra,24(sp)
    80000836:	6442                	ld	s0,16(sp)
    80000838:	64a2                	ld	s1,8(sp)
    8000083a:	6105                	addi	sp,sp,32
    8000083c:	8082                	ret

000000008000083e <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000083e:	1141                	addi	sp,sp,-16
    80000840:	e406                	sd	ra,8(sp)
    80000842:	e022                	sd	s0,0(sp)
    80000844:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000846:	100007b7          	lui	a5,0x10000
    8000084a:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000084e:	10000737          	lui	a4,0x10000
    80000852:	f8000693          	li	a3,-128
    80000856:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000085a:	468d                	li	a3,3
    8000085c:	10000637          	lui	a2,0x10000
    80000860:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000864:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000868:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000086c:	8732                	mv	a4,a2
    8000086e:	461d                	li	a2,7
    80000870:	00c70123          	sb	a2,2(a4)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000874:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000878:	00006597          	auipc	a1,0x6
    8000087c:	7b858593          	addi	a1,a1,1976 # 80007030 <etext+0x30>
    80000880:	00012517          	auipc	a0,0x12
    80000884:	ef850513          	addi	a0,a0,-264 # 80012778 <uart_tx_lock>
    80000888:	32a000ef          	jal	80000bb2 <initlock>
}
    8000088c:	60a2                	ld	ra,8(sp)
    8000088e:	6402                	ld	s0,0(sp)
    80000890:	0141                	addi	sp,sp,16
    80000892:	8082                	ret

0000000080000894 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000894:	1101                	addi	sp,sp,-32
    80000896:	ec06                	sd	ra,24(sp)
    80000898:	e822                	sd	s0,16(sp)
    8000089a:	e426                	sd	s1,8(sp)
    8000089c:	1000                	addi	s0,sp,32
    8000089e:	84aa                	mv	s1,a0
  push_off();
    800008a0:	356000ef          	jal	80000bf6 <push_off>

  if(panicked){
    800008a4:	0000a797          	auipc	a5,0xa
    800008a8:	dcc7a783          	lw	a5,-564(a5) # 8000a670 <panicked>
    800008ac:	e795                	bnez	a5,800008d8 <uartputc_sync+0x44>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800008ae:	10000737          	lui	a4,0x10000
    800008b2:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    800008b4:	00074783          	lbu	a5,0(a4)
    800008b8:	0207f793          	andi	a5,a5,32
    800008bc:	dfe5                	beqz	a5,800008b4 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    800008be:	0ff4f513          	zext.b	a0,s1
    800008c2:	100007b7          	lui	a5,0x10000
    800008c6:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    800008ca:	3b0000ef          	jal	80000c7a <pop_off>
}
    800008ce:	60e2                	ld	ra,24(sp)
    800008d0:	6442                	ld	s0,16(sp)
    800008d2:	64a2                	ld	s1,8(sp)
    800008d4:	6105                	addi	sp,sp,32
    800008d6:	8082                	ret
    for(;;)
    800008d8:	a001                	j	800008d8 <uartputc_sync+0x44>

00000000800008da <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    800008da:	0000a797          	auipc	a5,0xa
    800008de:	d9e7b783          	ld	a5,-610(a5) # 8000a678 <uart_tx_r>
    800008e2:	0000a717          	auipc	a4,0xa
    800008e6:	d9e73703          	ld	a4,-610(a4) # 8000a680 <uart_tx_w>
    800008ea:	08f70163          	beq	a4,a5,8000096c <uartstart+0x92>
{
    800008ee:	7139                	addi	sp,sp,-64
    800008f0:	fc06                	sd	ra,56(sp)
    800008f2:	f822                	sd	s0,48(sp)
    800008f4:	f426                	sd	s1,40(sp)
    800008f6:	f04a                	sd	s2,32(sp)
    800008f8:	ec4e                	sd	s3,24(sp)
    800008fa:	e852                	sd	s4,16(sp)
    800008fc:	e456                	sd	s5,8(sp)
    800008fe:	e05a                	sd	s6,0(sp)
    80000900:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000902:	10000937          	lui	s2,0x10000
    80000906:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000908:	00012a97          	auipc	s5,0x12
    8000090c:	e70a8a93          	addi	s5,s5,-400 # 80012778 <uart_tx_lock>
    uart_tx_r += 1;
    80000910:	0000a497          	auipc	s1,0xa
    80000914:	d6848493          	addi	s1,s1,-664 # 8000a678 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    80000918:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    8000091c:	0000a997          	auipc	s3,0xa
    80000920:	d6498993          	addi	s3,s3,-668 # 8000a680 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000924:	00094703          	lbu	a4,0(s2)
    80000928:	02077713          	andi	a4,a4,32
    8000092c:	c715                	beqz	a4,80000958 <uartstart+0x7e>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000092e:	01f7f713          	andi	a4,a5,31
    80000932:	9756                	add	a4,a4,s5
    80000934:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    80000938:	0785                	addi	a5,a5,1
    8000093a:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    8000093c:	8526                	mv	a0,s1
    8000093e:	5f0010ef          	jal	80001f2e <wakeup>
    WriteReg(THR, c);
    80000942:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    80000946:	609c                	ld	a5,0(s1)
    80000948:	0009b703          	ld	a4,0(s3)
    8000094c:	fcf71ce3          	bne	a4,a5,80000924 <uartstart+0x4a>
      ReadReg(ISR);
    80000950:	100007b7          	lui	a5,0x10000
    80000954:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>
  }
}
    80000958:	70e2                	ld	ra,56(sp)
    8000095a:	7442                	ld	s0,48(sp)
    8000095c:	74a2                	ld	s1,40(sp)
    8000095e:	7902                	ld	s2,32(sp)
    80000960:	69e2                	ld	s3,24(sp)
    80000962:	6a42                	ld	s4,16(sp)
    80000964:	6aa2                	ld	s5,8(sp)
    80000966:	6b02                	ld	s6,0(sp)
    80000968:	6121                	addi	sp,sp,64
    8000096a:	8082                	ret
      ReadReg(ISR);
    8000096c:	100007b7          	lui	a5,0x10000
    80000970:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>
      return;
    80000974:	8082                	ret

0000000080000976 <uartputc>:
{
    80000976:	7179                	addi	sp,sp,-48
    80000978:	f406                	sd	ra,40(sp)
    8000097a:	f022                	sd	s0,32(sp)
    8000097c:	ec26                	sd	s1,24(sp)
    8000097e:	e84a                	sd	s2,16(sp)
    80000980:	e44e                	sd	s3,8(sp)
    80000982:	e052                	sd	s4,0(sp)
    80000984:	1800                	addi	s0,sp,48
    80000986:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    80000988:	00012517          	auipc	a0,0x12
    8000098c:	df050513          	addi	a0,a0,-528 # 80012778 <uart_tx_lock>
    80000990:	2a6000ef          	jal	80000c36 <acquire>
  if(panicked){
    80000994:	0000a797          	auipc	a5,0xa
    80000998:	cdc7a783          	lw	a5,-804(a5) # 8000a670 <panicked>
    8000099c:	efbd                	bnez	a5,80000a1a <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000099e:	0000a717          	auipc	a4,0xa
    800009a2:	ce273703          	ld	a4,-798(a4) # 8000a680 <uart_tx_w>
    800009a6:	0000a797          	auipc	a5,0xa
    800009aa:	cd27b783          	ld	a5,-814(a5) # 8000a678 <uart_tx_r>
    800009ae:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800009b2:	00012997          	auipc	s3,0x12
    800009b6:	dc698993          	addi	s3,s3,-570 # 80012778 <uart_tx_lock>
    800009ba:	0000a497          	auipc	s1,0xa
    800009be:	cbe48493          	addi	s1,s1,-834 # 8000a678 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800009c2:	0000a917          	auipc	s2,0xa
    800009c6:	cbe90913          	addi	s2,s2,-834 # 8000a680 <uart_tx_w>
    800009ca:	00e79d63          	bne	a5,a4,800009e4 <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    800009ce:	85ce                	mv	a1,s3
    800009d0:	8526                	mv	a0,s1
    800009d2:	510010ef          	jal	80001ee2 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800009d6:	00093703          	ld	a4,0(s2)
    800009da:	609c                	ld	a5,0(s1)
    800009dc:	02078793          	addi	a5,a5,32
    800009e0:	fee787e3          	beq	a5,a4,800009ce <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009e4:	00012497          	auipc	s1,0x12
    800009e8:	d9448493          	addi	s1,s1,-620 # 80012778 <uart_tx_lock>
    800009ec:	01f77793          	andi	a5,a4,31
    800009f0:	97a6                	add	a5,a5,s1
    800009f2:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009f6:	0705                	addi	a4,a4,1
    800009f8:	0000a797          	auipc	a5,0xa
    800009fc:	c8e7b423          	sd	a4,-888(a5) # 8000a680 <uart_tx_w>
  uartstart();
    80000a00:	edbff0ef          	jal	800008da <uartstart>
  release(&uart_tx_lock);
    80000a04:	8526                	mv	a0,s1
    80000a06:	2c4000ef          	jal	80000cca <release>
}
    80000a0a:	70a2                	ld	ra,40(sp)
    80000a0c:	7402                	ld	s0,32(sp)
    80000a0e:	64e2                	ld	s1,24(sp)
    80000a10:	6942                	ld	s2,16(sp)
    80000a12:	69a2                	ld	s3,8(sp)
    80000a14:	6a02                	ld	s4,0(sp)
    80000a16:	6145                	addi	sp,sp,48
    80000a18:	8082                	ret
    for(;;)
    80000a1a:	a001                	j	80000a1a <uartputc+0xa4>

0000000080000a1c <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000a1c:	1141                	addi	sp,sp,-16
    80000a1e:	e406                	sd	ra,8(sp)
    80000a20:	e022                	sd	s0,0(sp)
    80000a22:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000a24:	100007b7          	lui	a5,0x10000
    80000a28:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000a2c:	8b85                	andi	a5,a5,1
    80000a2e:	cb89                	beqz	a5,80000a40 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000a30:	100007b7          	lui	a5,0x10000
    80000a34:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    80000a38:	60a2                	ld	ra,8(sp)
    80000a3a:	6402                	ld	s0,0(sp)
    80000a3c:	0141                	addi	sp,sp,16
    80000a3e:	8082                	ret
    return -1;
    80000a40:	557d                	li	a0,-1
    80000a42:	bfdd                	j	80000a38 <uartgetc+0x1c>

0000000080000a44 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000a44:	1101                	addi	sp,sp,-32
    80000a46:	ec06                	sd	ra,24(sp)
    80000a48:	e822                	sd	s0,16(sp)
    80000a4a:	e426                	sd	s1,8(sp)
    80000a4c:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a4e:	54fd                	li	s1,-1
    int c = uartgetc();
    80000a50:	fcdff0ef          	jal	80000a1c <uartgetc>
    if(c == -1)
    80000a54:	00950563          	beq	a0,s1,80000a5e <uartintr+0x1a>
      break;
    consoleintr(c);
    80000a58:	861ff0ef          	jal	800002b8 <consoleintr>
  while(1){
    80000a5c:	bfd5                	j	80000a50 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a5e:	00012497          	auipc	s1,0x12
    80000a62:	d1a48493          	addi	s1,s1,-742 # 80012778 <uart_tx_lock>
    80000a66:	8526                	mv	a0,s1
    80000a68:	1ce000ef          	jal	80000c36 <acquire>
  uartstart();
    80000a6c:	e6fff0ef          	jal	800008da <uartstart>
  release(&uart_tx_lock);
    80000a70:	8526                	mv	a0,s1
    80000a72:	258000ef          	jal	80000cca <release>
}
    80000a76:	60e2                	ld	ra,24(sp)
    80000a78:	6442                	ld	s0,16(sp)
    80000a7a:	64a2                	ld	s1,8(sp)
    80000a7c:	6105                	addi	sp,sp,32
    80000a7e:	8082                	ret

0000000080000a80 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a80:	1101                	addi	sp,sp,-32
    80000a82:	ec06                	sd	ra,24(sp)
    80000a84:	e822                	sd	s0,16(sp)
    80000a86:	e426                	sd	s1,8(sp)
    80000a88:	e04a                	sd	s2,0(sp)
    80000a8a:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a8c:	03451793          	slli	a5,a0,0x34
    80000a90:	e7a9                	bnez	a5,80000ada <kfree+0x5a>
    80000a92:	84aa                	mv	s1,a0
    80000a94:	00023797          	auipc	a5,0x23
    80000a98:	f4c78793          	addi	a5,a5,-180 # 800239e0 <end>
    80000a9c:	02f56f63          	bltu	a0,a5,80000ada <kfree+0x5a>
    80000aa0:	47c5                	li	a5,17
    80000aa2:	07ee                	slli	a5,a5,0x1b
    80000aa4:	02f57b63          	bgeu	a0,a5,80000ada <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000aa8:	6605                	lui	a2,0x1
    80000aaa:	4585                	li	a1,1
    80000aac:	25a000ef          	jal	80000d06 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000ab0:	00012917          	auipc	s2,0x12
    80000ab4:	d0090913          	addi	s2,s2,-768 # 800127b0 <kmem>
    80000ab8:	854a                	mv	a0,s2
    80000aba:	17c000ef          	jal	80000c36 <acquire>
  r->next = kmem.freelist;
    80000abe:	01893783          	ld	a5,24(s2)
    80000ac2:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000ac4:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000ac8:	854a                	mv	a0,s2
    80000aca:	200000ef          	jal	80000cca <release>
}
    80000ace:	60e2                	ld	ra,24(sp)
    80000ad0:	6442                	ld	s0,16(sp)
    80000ad2:	64a2                	ld	s1,8(sp)
    80000ad4:	6902                	ld	s2,0(sp)
    80000ad6:	6105                	addi	sp,sp,32
    80000ad8:	8082                	ret
    panic("kfree");
    80000ada:	00006517          	auipc	a0,0x6
    80000ade:	55e50513          	addi	a0,a0,1374 # 80007038 <etext+0x38>
    80000ae2:	cf5ff0ef          	jal	800007d6 <panic>

0000000080000ae6 <freerange>:
{
    80000ae6:	7179                	addi	sp,sp,-48
    80000ae8:	f406                	sd	ra,40(sp)
    80000aea:	f022                	sd	s0,32(sp)
    80000aec:	ec26                	sd	s1,24(sp)
    80000aee:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000af0:	6785                	lui	a5,0x1
    80000af2:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000af6:	00e504b3          	add	s1,a0,a4
    80000afa:	777d                	lui	a4,0xfffff
    80000afc:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000afe:	94be                	add	s1,s1,a5
    80000b00:	0295e263          	bltu	a1,s1,80000b24 <freerange+0x3e>
    80000b04:	e84a                	sd	s2,16(sp)
    80000b06:	e44e                	sd	s3,8(sp)
    80000b08:	e052                	sd	s4,0(sp)
    80000b0a:	892e                	mv	s2,a1
    kfree(p);
    80000b0c:	8a3a                	mv	s4,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b0e:	89be                	mv	s3,a5
    kfree(p);
    80000b10:	01448533          	add	a0,s1,s4
    80000b14:	f6dff0ef          	jal	80000a80 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b18:	94ce                	add	s1,s1,s3
    80000b1a:	fe997be3          	bgeu	s2,s1,80000b10 <freerange+0x2a>
    80000b1e:	6942                	ld	s2,16(sp)
    80000b20:	69a2                	ld	s3,8(sp)
    80000b22:	6a02                	ld	s4,0(sp)
}
    80000b24:	70a2                	ld	ra,40(sp)
    80000b26:	7402                	ld	s0,32(sp)
    80000b28:	64e2                	ld	s1,24(sp)
    80000b2a:	6145                	addi	sp,sp,48
    80000b2c:	8082                	ret

0000000080000b2e <kinit>:
{
    80000b2e:	1141                	addi	sp,sp,-16
    80000b30:	e406                	sd	ra,8(sp)
    80000b32:	e022                	sd	s0,0(sp)
    80000b34:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b36:	00006597          	auipc	a1,0x6
    80000b3a:	50a58593          	addi	a1,a1,1290 # 80007040 <etext+0x40>
    80000b3e:	00012517          	auipc	a0,0x12
    80000b42:	c7250513          	addi	a0,a0,-910 # 800127b0 <kmem>
    80000b46:	06c000ef          	jal	80000bb2 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b4a:	45c5                	li	a1,17
    80000b4c:	05ee                	slli	a1,a1,0x1b
    80000b4e:	00023517          	auipc	a0,0x23
    80000b52:	e9250513          	addi	a0,a0,-366 # 800239e0 <end>
    80000b56:	f91ff0ef          	jal	80000ae6 <freerange>
}
    80000b5a:	60a2                	ld	ra,8(sp)
    80000b5c:	6402                	ld	s0,0(sp)
    80000b5e:	0141                	addi	sp,sp,16
    80000b60:	8082                	ret

0000000080000b62 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b62:	1101                	addi	sp,sp,-32
    80000b64:	ec06                	sd	ra,24(sp)
    80000b66:	e822                	sd	s0,16(sp)
    80000b68:	e426                	sd	s1,8(sp)
    80000b6a:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b6c:	00012497          	auipc	s1,0x12
    80000b70:	c4448493          	addi	s1,s1,-956 # 800127b0 <kmem>
    80000b74:	8526                	mv	a0,s1
    80000b76:	0c0000ef          	jal	80000c36 <acquire>
  r = kmem.freelist;
    80000b7a:	6c84                	ld	s1,24(s1)
  if(r)
    80000b7c:	c485                	beqz	s1,80000ba4 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b7e:	609c                	ld	a5,0(s1)
    80000b80:	00012517          	auipc	a0,0x12
    80000b84:	c3050513          	addi	a0,a0,-976 # 800127b0 <kmem>
    80000b88:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b8a:	140000ef          	jal	80000cca <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b8e:	6605                	lui	a2,0x1
    80000b90:	4595                	li	a1,5
    80000b92:	8526                	mv	a0,s1
    80000b94:	172000ef          	jal	80000d06 <memset>
  return (void*)r;
}
    80000b98:	8526                	mv	a0,s1
    80000b9a:	60e2                	ld	ra,24(sp)
    80000b9c:	6442                	ld	s0,16(sp)
    80000b9e:	64a2                	ld	s1,8(sp)
    80000ba0:	6105                	addi	sp,sp,32
    80000ba2:	8082                	ret
  release(&kmem.lock);
    80000ba4:	00012517          	auipc	a0,0x12
    80000ba8:	c0c50513          	addi	a0,a0,-1012 # 800127b0 <kmem>
    80000bac:	11e000ef          	jal	80000cca <release>
  if(r)
    80000bb0:	b7e5                	j	80000b98 <kalloc+0x36>

0000000080000bb2 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000bb2:	1141                	addi	sp,sp,-16
    80000bb4:	e406                	sd	ra,8(sp)
    80000bb6:	e022                	sd	s0,0(sp)
    80000bb8:	0800                	addi	s0,sp,16
  lk->name = name;
    80000bba:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bbc:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bc0:	00053823          	sd	zero,16(a0)
}
    80000bc4:	60a2                	ld	ra,8(sp)
    80000bc6:	6402                	ld	s0,0(sp)
    80000bc8:	0141                	addi	sp,sp,16
    80000bca:	8082                	ret

0000000080000bcc <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bcc:	411c                	lw	a5,0(a0)
    80000bce:	e399                	bnez	a5,80000bd4 <holding+0x8>
    80000bd0:	4501                	li	a0,0
  return r;
}
    80000bd2:	8082                	ret
{
    80000bd4:	1101                	addi	sp,sp,-32
    80000bd6:	ec06                	sd	ra,24(sp)
    80000bd8:	e822                	sd	s0,16(sp)
    80000bda:	e426                	sd	s1,8(sp)
    80000bdc:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bde:	6904                	ld	s1,16(a0)
    80000be0:	515000ef          	jal	800018f4 <mycpu>
    80000be4:	40a48533          	sub	a0,s1,a0
    80000be8:	00153513          	seqz	a0,a0
}
    80000bec:	60e2                	ld	ra,24(sp)
    80000bee:	6442                	ld	s0,16(sp)
    80000bf0:	64a2                	ld	s1,8(sp)
    80000bf2:	6105                	addi	sp,sp,32
    80000bf4:	8082                	ret

0000000080000bf6 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bf6:	1101                	addi	sp,sp,-32
    80000bf8:	ec06                	sd	ra,24(sp)
    80000bfa:	e822                	sd	s0,16(sp)
    80000bfc:	e426                	sd	s1,8(sp)
    80000bfe:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c00:	100024f3          	csrr	s1,sstatus
    80000c04:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c08:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c0a:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c0e:	4e7000ef          	jal	800018f4 <mycpu>
    80000c12:	5d3c                	lw	a5,120(a0)
    80000c14:	cb99                	beqz	a5,80000c2a <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c16:	4df000ef          	jal	800018f4 <mycpu>
    80000c1a:	5d3c                	lw	a5,120(a0)
    80000c1c:	2785                	addiw	a5,a5,1
    80000c1e:	dd3c                	sw	a5,120(a0)
}
    80000c20:	60e2                	ld	ra,24(sp)
    80000c22:	6442                	ld	s0,16(sp)
    80000c24:	64a2                	ld	s1,8(sp)
    80000c26:	6105                	addi	sp,sp,32
    80000c28:	8082                	ret
    mycpu()->intena = old;
    80000c2a:	4cb000ef          	jal	800018f4 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c2e:	8085                	srli	s1,s1,0x1
    80000c30:	8885                	andi	s1,s1,1
    80000c32:	dd64                	sw	s1,124(a0)
    80000c34:	b7cd                	j	80000c16 <push_off+0x20>

0000000080000c36 <acquire>:
{
    80000c36:	1101                	addi	sp,sp,-32
    80000c38:	ec06                	sd	ra,24(sp)
    80000c3a:	e822                	sd	s0,16(sp)
    80000c3c:	e426                	sd	s1,8(sp)
    80000c3e:	1000                	addi	s0,sp,32
    80000c40:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c42:	fb5ff0ef          	jal	80000bf6 <push_off>
  if(holding(lk))
    80000c46:	8526                	mv	a0,s1
    80000c48:	f85ff0ef          	jal	80000bcc <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c4c:	4705                	li	a4,1
  if(holding(lk))
    80000c4e:	e105                	bnez	a0,80000c6e <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c50:	87ba                	mv	a5,a4
    80000c52:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c56:	2781                	sext.w	a5,a5
    80000c58:	ffe5                	bnez	a5,80000c50 <acquire+0x1a>
  __sync_synchronize();
    80000c5a:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000c5e:	497000ef          	jal	800018f4 <mycpu>
    80000c62:	e888                	sd	a0,16(s1)
}
    80000c64:	60e2                	ld	ra,24(sp)
    80000c66:	6442                	ld	s0,16(sp)
    80000c68:	64a2                	ld	s1,8(sp)
    80000c6a:	6105                	addi	sp,sp,32
    80000c6c:	8082                	ret
    panic("acquire");
    80000c6e:	00006517          	auipc	a0,0x6
    80000c72:	3da50513          	addi	a0,a0,986 # 80007048 <etext+0x48>
    80000c76:	b61ff0ef          	jal	800007d6 <panic>

0000000080000c7a <pop_off>:

void
pop_off(void)
{
    80000c7a:	1141                	addi	sp,sp,-16
    80000c7c:	e406                	sd	ra,8(sp)
    80000c7e:	e022                	sd	s0,0(sp)
    80000c80:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c82:	473000ef          	jal	800018f4 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c86:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c8a:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c8c:	e39d                	bnez	a5,80000cb2 <pop_off+0x38>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c8e:	5d3c                	lw	a5,120(a0)
    80000c90:	02f05763          	blez	a5,80000cbe <pop_off+0x44>
    panic("pop_off");
  c->noff -= 1;
    80000c94:	37fd                	addiw	a5,a5,-1
    80000c96:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c98:	eb89                	bnez	a5,80000caa <pop_off+0x30>
    80000c9a:	5d7c                	lw	a5,124(a0)
    80000c9c:	c799                	beqz	a5,80000caa <pop_off+0x30>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c9e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000ca2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000ca6:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000caa:	60a2                	ld	ra,8(sp)
    80000cac:	6402                	ld	s0,0(sp)
    80000cae:	0141                	addi	sp,sp,16
    80000cb0:	8082                	ret
    panic("pop_off - interruptible");
    80000cb2:	00006517          	auipc	a0,0x6
    80000cb6:	39e50513          	addi	a0,a0,926 # 80007050 <etext+0x50>
    80000cba:	b1dff0ef          	jal	800007d6 <panic>
    panic("pop_off");
    80000cbe:	00006517          	auipc	a0,0x6
    80000cc2:	3aa50513          	addi	a0,a0,938 # 80007068 <etext+0x68>
    80000cc6:	b11ff0ef          	jal	800007d6 <panic>

0000000080000cca <release>:
{
    80000cca:	1101                	addi	sp,sp,-32
    80000ccc:	ec06                	sd	ra,24(sp)
    80000cce:	e822                	sd	s0,16(sp)
    80000cd0:	e426                	sd	s1,8(sp)
    80000cd2:	1000                	addi	s0,sp,32
    80000cd4:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cd6:	ef7ff0ef          	jal	80000bcc <holding>
    80000cda:	c105                	beqz	a0,80000cfa <release+0x30>
  lk->cpu = 0;
    80000cdc:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ce0:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000ce4:	0310000f          	fence	rw,w
    80000ce8:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000cec:	f8fff0ef          	jal	80000c7a <pop_off>
}
    80000cf0:	60e2                	ld	ra,24(sp)
    80000cf2:	6442                	ld	s0,16(sp)
    80000cf4:	64a2                	ld	s1,8(sp)
    80000cf6:	6105                	addi	sp,sp,32
    80000cf8:	8082                	ret
    panic("release");
    80000cfa:	00006517          	auipc	a0,0x6
    80000cfe:	37650513          	addi	a0,a0,886 # 80007070 <etext+0x70>
    80000d02:	ad5ff0ef          	jal	800007d6 <panic>

0000000080000d06 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d06:	1141                	addi	sp,sp,-16
    80000d08:	e406                	sd	ra,8(sp)
    80000d0a:	e022                	sd	s0,0(sp)
    80000d0c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d0e:	ca19                	beqz	a2,80000d24 <memset+0x1e>
    80000d10:	87aa                	mv	a5,a0
    80000d12:	1602                	slli	a2,a2,0x20
    80000d14:	9201                	srli	a2,a2,0x20
    80000d16:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d1a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d1e:	0785                	addi	a5,a5,1
    80000d20:	fee79de3          	bne	a5,a4,80000d1a <memset+0x14>
  }
  return dst;
}
    80000d24:	60a2                	ld	ra,8(sp)
    80000d26:	6402                	ld	s0,0(sp)
    80000d28:	0141                	addi	sp,sp,16
    80000d2a:	8082                	ret

0000000080000d2c <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d2c:	1141                	addi	sp,sp,-16
    80000d2e:	e406                	sd	ra,8(sp)
    80000d30:	e022                	sd	s0,0(sp)
    80000d32:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d34:	ca0d                	beqz	a2,80000d66 <memcmp+0x3a>
    80000d36:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d3a:	1682                	slli	a3,a3,0x20
    80000d3c:	9281                	srli	a3,a3,0x20
    80000d3e:	0685                	addi	a3,a3,1
    80000d40:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d42:	00054783          	lbu	a5,0(a0)
    80000d46:	0005c703          	lbu	a4,0(a1)
    80000d4a:	00e79863          	bne	a5,a4,80000d5a <memcmp+0x2e>
      return *s1 - *s2;
    s1++, s2++;
    80000d4e:	0505                	addi	a0,a0,1
    80000d50:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d52:	fed518e3          	bne	a0,a3,80000d42 <memcmp+0x16>
  }

  return 0;
    80000d56:	4501                	li	a0,0
    80000d58:	a019                	j	80000d5e <memcmp+0x32>
      return *s1 - *s2;
    80000d5a:	40e7853b          	subw	a0,a5,a4
}
    80000d5e:	60a2                	ld	ra,8(sp)
    80000d60:	6402                	ld	s0,0(sp)
    80000d62:	0141                	addi	sp,sp,16
    80000d64:	8082                	ret
  return 0;
    80000d66:	4501                	li	a0,0
    80000d68:	bfdd                	j	80000d5e <memcmp+0x32>

0000000080000d6a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d6a:	1141                	addi	sp,sp,-16
    80000d6c:	e406                	sd	ra,8(sp)
    80000d6e:	e022                	sd	s0,0(sp)
    80000d70:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d72:	c205                	beqz	a2,80000d92 <memmove+0x28>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d74:	02a5e363          	bltu	a1,a0,80000d9a <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d78:	1602                	slli	a2,a2,0x20
    80000d7a:	9201                	srli	a2,a2,0x20
    80000d7c:	00c587b3          	add	a5,a1,a2
{
    80000d80:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d82:	0585                	addi	a1,a1,1
    80000d84:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdb621>
    80000d86:	fff5c683          	lbu	a3,-1(a1)
    80000d8a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d8e:	feb79ae3          	bne	a5,a1,80000d82 <memmove+0x18>

  return dst;
}
    80000d92:	60a2                	ld	ra,8(sp)
    80000d94:	6402                	ld	s0,0(sp)
    80000d96:	0141                	addi	sp,sp,16
    80000d98:	8082                	ret
  if(s < d && s + n > d){
    80000d9a:	02061693          	slli	a3,a2,0x20
    80000d9e:	9281                	srli	a3,a3,0x20
    80000da0:	00d58733          	add	a4,a1,a3
    80000da4:	fce57ae3          	bgeu	a0,a4,80000d78 <memmove+0xe>
    d += n;
    80000da8:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000daa:	fff6079b          	addiw	a5,a2,-1
    80000dae:	1782                	slli	a5,a5,0x20
    80000db0:	9381                	srli	a5,a5,0x20
    80000db2:	fff7c793          	not	a5,a5
    80000db6:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000db8:	177d                	addi	a4,a4,-1
    80000dba:	16fd                	addi	a3,a3,-1
    80000dbc:	00074603          	lbu	a2,0(a4)
    80000dc0:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000dc4:	fee79ae3          	bne	a5,a4,80000db8 <memmove+0x4e>
    80000dc8:	b7e9                	j	80000d92 <memmove+0x28>

0000000080000dca <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000dca:	1141                	addi	sp,sp,-16
    80000dcc:	e406                	sd	ra,8(sp)
    80000dce:	e022                	sd	s0,0(sp)
    80000dd0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000dd2:	f99ff0ef          	jal	80000d6a <memmove>
}
    80000dd6:	60a2                	ld	ra,8(sp)
    80000dd8:	6402                	ld	s0,0(sp)
    80000dda:	0141                	addi	sp,sp,16
    80000ddc:	8082                	ret

0000000080000dde <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000dde:	1141                	addi	sp,sp,-16
    80000de0:	e406                	sd	ra,8(sp)
    80000de2:	e022                	sd	s0,0(sp)
    80000de4:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000de6:	ce11                	beqz	a2,80000e02 <strncmp+0x24>
    80000de8:	00054783          	lbu	a5,0(a0)
    80000dec:	cf89                	beqz	a5,80000e06 <strncmp+0x28>
    80000dee:	0005c703          	lbu	a4,0(a1)
    80000df2:	00f71a63          	bne	a4,a5,80000e06 <strncmp+0x28>
    n--, p++, q++;
    80000df6:	367d                	addiw	a2,a2,-1
    80000df8:	0505                	addi	a0,a0,1
    80000dfa:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dfc:	f675                	bnez	a2,80000de8 <strncmp+0xa>
  if(n == 0)
    return 0;
    80000dfe:	4501                	li	a0,0
    80000e00:	a801                	j	80000e10 <strncmp+0x32>
    80000e02:	4501                	li	a0,0
    80000e04:	a031                	j	80000e10 <strncmp+0x32>
  return (uchar)*p - (uchar)*q;
    80000e06:	00054503          	lbu	a0,0(a0)
    80000e0a:	0005c783          	lbu	a5,0(a1)
    80000e0e:	9d1d                	subw	a0,a0,a5
}
    80000e10:	60a2                	ld	ra,8(sp)
    80000e12:	6402                	ld	s0,0(sp)
    80000e14:	0141                	addi	sp,sp,16
    80000e16:	8082                	ret

0000000080000e18 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e18:	1141                	addi	sp,sp,-16
    80000e1a:	e406                	sd	ra,8(sp)
    80000e1c:	e022                	sd	s0,0(sp)
    80000e1e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e20:	87aa                	mv	a5,a0
    80000e22:	86b2                	mv	a3,a2
    80000e24:	367d                	addiw	a2,a2,-1
    80000e26:	02d05563          	blez	a3,80000e50 <strncpy+0x38>
    80000e2a:	0785                	addi	a5,a5,1
    80000e2c:	0005c703          	lbu	a4,0(a1)
    80000e30:	fee78fa3          	sb	a4,-1(a5)
    80000e34:	0585                	addi	a1,a1,1
    80000e36:	f775                	bnez	a4,80000e22 <strncpy+0xa>
    ;
  while(n-- > 0)
    80000e38:	873e                	mv	a4,a5
    80000e3a:	00c05b63          	blez	a2,80000e50 <strncpy+0x38>
    80000e3e:	9fb5                	addw	a5,a5,a3
    80000e40:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000e42:	0705                	addi	a4,a4,1
    80000e44:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e48:	40e786bb          	subw	a3,a5,a4
    80000e4c:	fed04be3          	bgtz	a3,80000e42 <strncpy+0x2a>
  return os;
}
    80000e50:	60a2                	ld	ra,8(sp)
    80000e52:	6402                	ld	s0,0(sp)
    80000e54:	0141                	addi	sp,sp,16
    80000e56:	8082                	ret

0000000080000e58 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e58:	1141                	addi	sp,sp,-16
    80000e5a:	e406                	sd	ra,8(sp)
    80000e5c:	e022                	sd	s0,0(sp)
    80000e5e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e60:	02c05363          	blez	a2,80000e86 <safestrcpy+0x2e>
    80000e64:	fff6069b          	addiw	a3,a2,-1
    80000e68:	1682                	slli	a3,a3,0x20
    80000e6a:	9281                	srli	a3,a3,0x20
    80000e6c:	96ae                	add	a3,a3,a1
    80000e6e:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e70:	00d58963          	beq	a1,a3,80000e82 <safestrcpy+0x2a>
    80000e74:	0585                	addi	a1,a1,1
    80000e76:	0785                	addi	a5,a5,1
    80000e78:	fff5c703          	lbu	a4,-1(a1)
    80000e7c:	fee78fa3          	sb	a4,-1(a5)
    80000e80:	fb65                	bnez	a4,80000e70 <safestrcpy+0x18>
    ;
  *s = 0;
    80000e82:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e86:	60a2                	ld	ra,8(sp)
    80000e88:	6402                	ld	s0,0(sp)
    80000e8a:	0141                	addi	sp,sp,16
    80000e8c:	8082                	ret

0000000080000e8e <strlen>:

int
strlen(const char *s)
{
    80000e8e:	1141                	addi	sp,sp,-16
    80000e90:	e406                	sd	ra,8(sp)
    80000e92:	e022                	sd	s0,0(sp)
    80000e94:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e96:	00054783          	lbu	a5,0(a0)
    80000e9a:	cf99                	beqz	a5,80000eb8 <strlen+0x2a>
    80000e9c:	0505                	addi	a0,a0,1
    80000e9e:	87aa                	mv	a5,a0
    80000ea0:	86be                	mv	a3,a5
    80000ea2:	0785                	addi	a5,a5,1
    80000ea4:	fff7c703          	lbu	a4,-1(a5)
    80000ea8:	ff65                	bnez	a4,80000ea0 <strlen+0x12>
    80000eaa:	40a6853b          	subw	a0,a3,a0
    80000eae:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000eb0:	60a2                	ld	ra,8(sp)
    80000eb2:	6402                	ld	s0,0(sp)
    80000eb4:	0141                	addi	sp,sp,16
    80000eb6:	8082                	ret
  for(n = 0; s[n]; n++)
    80000eb8:	4501                	li	a0,0
    80000eba:	bfdd                	j	80000eb0 <strlen+0x22>

0000000080000ebc <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000ebc:	1141                	addi	sp,sp,-16
    80000ebe:	e406                	sd	ra,8(sp)
    80000ec0:	e022                	sd	s0,0(sp)
    80000ec2:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000ec4:	21d000ef          	jal	800018e0 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000ec8:	00009717          	auipc	a4,0x9
    80000ecc:	7c070713          	addi	a4,a4,1984 # 8000a688 <started>
  if(cpuid() == 0){
    80000ed0:	c51d                	beqz	a0,80000efe <main+0x42>
    while(started == 0)
    80000ed2:	431c                	lw	a5,0(a4)
    80000ed4:	2781                	sext.w	a5,a5
    80000ed6:	dff5                	beqz	a5,80000ed2 <main+0x16>
      ;
    __sync_synchronize();
    80000ed8:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000edc:	205000ef          	jal	800018e0 <cpuid>
    80000ee0:	85aa                	mv	a1,a0
    80000ee2:	00006517          	auipc	a0,0x6
    80000ee6:	1b650513          	addi	a0,a0,438 # 80007098 <etext+0x98>
    80000eea:	e1cff0ef          	jal	80000506 <printf>
    kvminithart();    // turn on paging
    80000eee:	080000ef          	jal	80000f6e <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ef2:	714010ef          	jal	80002606 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ef6:	363040ef          	jal	80005a58 <plicinithart>
  }

  scheduler();        
    80000efa:	64f000ef          	jal	80001d48 <scheduler>
    consoleinit();
    80000efe:	d3aff0ef          	jal	80000438 <consoleinit>
    printfinit();
    80000f02:	90fff0ef          	jal	80000810 <printfinit>
    printf("\n");
    80000f06:	00006517          	auipc	a0,0x6
    80000f0a:	17250513          	addi	a0,a0,370 # 80007078 <etext+0x78>
    80000f0e:	df8ff0ef          	jal	80000506 <printf>
    printf("xv6 kernel is booting\n");
    80000f12:	00006517          	auipc	a0,0x6
    80000f16:	16e50513          	addi	a0,a0,366 # 80007080 <etext+0x80>
    80000f1a:	decff0ef          	jal	80000506 <printf>
    printf("\n");
    80000f1e:	00006517          	auipc	a0,0x6
    80000f22:	15a50513          	addi	a0,a0,346 # 80007078 <etext+0x78>
    80000f26:	de0ff0ef          	jal	80000506 <printf>
    kinit();         // physical page allocator
    80000f2a:	c05ff0ef          	jal	80000b2e <kinit>
    kvminit();       // create kernel page table
    80000f2e:	2ce000ef          	jal	800011fc <kvminit>
    kvminithart();   // turn on paging
    80000f32:	03c000ef          	jal	80000f6e <kvminithart>
    procinit();      // process table
    80000f36:	0fb000ef          	jal	80001830 <procinit>
    trapinit();      // trap vectors
    80000f3a:	6a8010ef          	jal	800025e2 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	6c8010ef          	jal	80002606 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f42:	2fd040ef          	jal	80005a3e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f46:	313040ef          	jal	80005a58 <plicinithart>
    binit();         // buffer cache
    80000f4a:	6b3010ef          	jal	80002dfc <binit>
    iinit();         // inode table
    80000f4e:	47e020ef          	jal	800033cc <iinit>
    fileinit();      // file table
    80000f52:	24c030ef          	jal	8000419e <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f56:	3f3040ef          	jal	80005b48 <virtio_disk_init>
    userinit();      // first user process
    80000f5a:	423000ef          	jal	80001b7c <userinit>
    __sync_synchronize();
    80000f5e:	0330000f          	fence	rw,rw
    started = 1;
    80000f62:	4785                	li	a5,1
    80000f64:	00009717          	auipc	a4,0x9
    80000f68:	72f72223          	sw	a5,1828(a4) # 8000a688 <started>
    80000f6c:	b779                	j	80000efa <main+0x3e>

0000000080000f6e <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f6e:	1141                	addi	sp,sp,-16
    80000f70:	e406                	sd	ra,8(sp)
    80000f72:	e022                	sd	s0,0(sp)
    80000f74:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f76:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f7a:	00009797          	auipc	a5,0x9
    80000f7e:	7167b783          	ld	a5,1814(a5) # 8000a690 <kernel_pagetable>
    80000f82:	83b1                	srli	a5,a5,0xc
    80000f84:	577d                	li	a4,-1
    80000f86:	177e                	slli	a4,a4,0x3f
    80000f88:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f8a:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f8e:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f92:	60a2                	ld	ra,8(sp)
    80000f94:	6402                	ld	s0,0(sp)
    80000f96:	0141                	addi	sp,sp,16
    80000f98:	8082                	ret

0000000080000f9a <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f9a:	7139                	addi	sp,sp,-64
    80000f9c:	fc06                	sd	ra,56(sp)
    80000f9e:	f822                	sd	s0,48(sp)
    80000fa0:	f426                	sd	s1,40(sp)
    80000fa2:	f04a                	sd	s2,32(sp)
    80000fa4:	ec4e                	sd	s3,24(sp)
    80000fa6:	e852                	sd	s4,16(sp)
    80000fa8:	e456                	sd	s5,8(sp)
    80000faa:	e05a                	sd	s6,0(sp)
    80000fac:	0080                	addi	s0,sp,64
    80000fae:	84aa                	mv	s1,a0
    80000fb0:	89ae                	mv	s3,a1
    80000fb2:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fb4:	57fd                	li	a5,-1
    80000fb6:	83e9                	srli	a5,a5,0x1a
    80000fb8:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fba:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fbc:	04b7e263          	bltu	a5,a1,80001000 <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    80000fc0:	0149d933          	srl	s2,s3,s4
    80000fc4:	1ff97913          	andi	s2,s2,511
    80000fc8:	090e                	slli	s2,s2,0x3
    80000fca:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000fcc:	00093483          	ld	s1,0(s2)
    80000fd0:	0014f793          	andi	a5,s1,1
    80000fd4:	cf85                	beqz	a5,8000100c <walk+0x72>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000fd6:	80a9                	srli	s1,s1,0xa
    80000fd8:	04b2                	slli	s1,s1,0xc
  for(int level = 2; level > 0; level--) {
    80000fda:	3a5d                	addiw	s4,s4,-9
    80000fdc:	ff6a12e3          	bne	s4,s6,80000fc0 <walk+0x26>
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
    80000fe0:	00c9d513          	srli	a0,s3,0xc
    80000fe4:	1ff57513          	andi	a0,a0,511
    80000fe8:	050e                	slli	a0,a0,0x3
    80000fea:	9526                	add	a0,a0,s1
}
    80000fec:	70e2                	ld	ra,56(sp)
    80000fee:	7442                	ld	s0,48(sp)
    80000ff0:	74a2                	ld	s1,40(sp)
    80000ff2:	7902                	ld	s2,32(sp)
    80000ff4:	69e2                	ld	s3,24(sp)
    80000ff6:	6a42                	ld	s4,16(sp)
    80000ff8:	6aa2                	ld	s5,8(sp)
    80000ffa:	6b02                	ld	s6,0(sp)
    80000ffc:	6121                	addi	sp,sp,64
    80000ffe:	8082                	ret
    panic("walk");
    80001000:	00006517          	auipc	a0,0x6
    80001004:	0b050513          	addi	a0,a0,176 # 800070b0 <etext+0xb0>
    80001008:	fceff0ef          	jal	800007d6 <panic>
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000100c:	020a8263          	beqz	s5,80001030 <walk+0x96>
    80001010:	b53ff0ef          	jal	80000b62 <kalloc>
    80001014:	84aa                	mv	s1,a0
    80001016:	d979                	beqz	a0,80000fec <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    80001018:	6605                	lui	a2,0x1
    8000101a:	4581                	li	a1,0
    8000101c:	cebff0ef          	jal	80000d06 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001020:	00c4d793          	srli	a5,s1,0xc
    80001024:	07aa                	slli	a5,a5,0xa
    80001026:	0017e793          	ori	a5,a5,1
    8000102a:	00f93023          	sd	a5,0(s2)
    8000102e:	b775                	j	80000fda <walk+0x40>
        return 0;
    80001030:	4501                	li	a0,0
    80001032:	bf6d                	j	80000fec <walk+0x52>

0000000080001034 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001034:	57fd                	li	a5,-1
    80001036:	83e9                	srli	a5,a5,0x1a
    80001038:	00b7f463          	bgeu	a5,a1,80001040 <walkaddr+0xc>
    return 0;
    8000103c:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000103e:	8082                	ret
{
    80001040:	1141                	addi	sp,sp,-16
    80001042:	e406                	sd	ra,8(sp)
    80001044:	e022                	sd	s0,0(sp)
    80001046:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001048:	4601                	li	a2,0
    8000104a:	f51ff0ef          	jal	80000f9a <walk>
  if(pte == 0)
    8000104e:	c105                	beqz	a0,8000106e <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80001050:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001052:	0117f693          	andi	a3,a5,17
    80001056:	4745                	li	a4,17
    return 0;
    80001058:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000105a:	00e68663          	beq	a3,a4,80001066 <walkaddr+0x32>
}
    8000105e:	60a2                	ld	ra,8(sp)
    80001060:	6402                	ld	s0,0(sp)
    80001062:	0141                	addi	sp,sp,16
    80001064:	8082                	ret
  pa = PTE2PA(*pte);
    80001066:	83a9                	srli	a5,a5,0xa
    80001068:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000106c:	bfcd                	j	8000105e <walkaddr+0x2a>
    return 0;
    8000106e:	4501                	li	a0,0
    80001070:	b7fd                	j	8000105e <walkaddr+0x2a>

0000000080001072 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001072:	715d                	addi	sp,sp,-80
    80001074:	e486                	sd	ra,72(sp)
    80001076:	e0a2                	sd	s0,64(sp)
    80001078:	fc26                	sd	s1,56(sp)
    8000107a:	f84a                	sd	s2,48(sp)
    8000107c:	f44e                	sd	s3,40(sp)
    8000107e:	f052                	sd	s4,32(sp)
    80001080:	ec56                	sd	s5,24(sp)
    80001082:	e85a                	sd	s6,16(sp)
    80001084:	e45e                	sd	s7,8(sp)
    80001086:	e062                	sd	s8,0(sp)
    80001088:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000108a:	03459793          	slli	a5,a1,0x34
    8000108e:	e7b1                	bnez	a5,800010da <mappages+0x68>
    80001090:	8aaa                	mv	s5,a0
    80001092:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001094:	03461793          	slli	a5,a2,0x34
    80001098:	e7b9                	bnez	a5,800010e6 <mappages+0x74>
    panic("mappages: size not aligned");

  if(size == 0)
    8000109a:	ce21                	beqz	a2,800010f2 <mappages+0x80>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    8000109c:	77fd                	lui	a5,0xfffff
    8000109e:	963e                	add	a2,a2,a5
    800010a0:	00b609b3          	add	s3,a2,a1
  a = va;
    800010a4:	892e                	mv	s2,a1
    800010a6:	40b68a33          	sub	s4,a3,a1
  for(;;){
    if((pte = walk(pagetable, a, 1)) == 0)
    800010aa:	4b85                	li	s7,1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010ac:	6c05                	lui	s8,0x1
    800010ae:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    800010b2:	865e                	mv	a2,s7
    800010b4:	85ca                	mv	a1,s2
    800010b6:	8556                	mv	a0,s5
    800010b8:	ee3ff0ef          	jal	80000f9a <walk>
    800010bc:	c539                	beqz	a0,8000110a <mappages+0x98>
    if(*pte & PTE_V)
    800010be:	611c                	ld	a5,0(a0)
    800010c0:	8b85                	andi	a5,a5,1
    800010c2:	ef95                	bnez	a5,800010fe <mappages+0x8c>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010c4:	80b1                	srli	s1,s1,0xc
    800010c6:	04aa                	slli	s1,s1,0xa
    800010c8:	0164e4b3          	or	s1,s1,s6
    800010cc:	0014e493          	ori	s1,s1,1
    800010d0:	e104                	sd	s1,0(a0)
    if(a == last)
    800010d2:	05390963          	beq	s2,s3,80001124 <mappages+0xb2>
    a += PGSIZE;
    800010d6:	9962                	add	s2,s2,s8
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d8:	bfd9                	j	800010ae <mappages+0x3c>
    panic("mappages: va not aligned");
    800010da:	00006517          	auipc	a0,0x6
    800010de:	fde50513          	addi	a0,a0,-34 # 800070b8 <etext+0xb8>
    800010e2:	ef4ff0ef          	jal	800007d6 <panic>
    panic("mappages: size not aligned");
    800010e6:	00006517          	auipc	a0,0x6
    800010ea:	ff250513          	addi	a0,a0,-14 # 800070d8 <etext+0xd8>
    800010ee:	ee8ff0ef          	jal	800007d6 <panic>
    panic("mappages: size");
    800010f2:	00006517          	auipc	a0,0x6
    800010f6:	00650513          	addi	a0,a0,6 # 800070f8 <etext+0xf8>
    800010fa:	edcff0ef          	jal	800007d6 <panic>
      panic("mappages: remap");
    800010fe:	00006517          	auipc	a0,0x6
    80001102:	00a50513          	addi	a0,a0,10 # 80007108 <etext+0x108>
    80001106:	ed0ff0ef          	jal	800007d6 <panic>
      return -1;
    8000110a:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000110c:	60a6                	ld	ra,72(sp)
    8000110e:	6406                	ld	s0,64(sp)
    80001110:	74e2                	ld	s1,56(sp)
    80001112:	7942                	ld	s2,48(sp)
    80001114:	79a2                	ld	s3,40(sp)
    80001116:	7a02                	ld	s4,32(sp)
    80001118:	6ae2                	ld	s5,24(sp)
    8000111a:	6b42                	ld	s6,16(sp)
    8000111c:	6ba2                	ld	s7,8(sp)
    8000111e:	6c02                	ld	s8,0(sp)
    80001120:	6161                	addi	sp,sp,80
    80001122:	8082                	ret
  return 0;
    80001124:	4501                	li	a0,0
    80001126:	b7dd                	j	8000110c <mappages+0x9a>

0000000080001128 <kvmmap>:
{
    80001128:	1141                	addi	sp,sp,-16
    8000112a:	e406                	sd	ra,8(sp)
    8000112c:	e022                	sd	s0,0(sp)
    8000112e:	0800                	addi	s0,sp,16
    80001130:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001132:	86b2                	mv	a3,a2
    80001134:	863e                	mv	a2,a5
    80001136:	f3dff0ef          	jal	80001072 <mappages>
    8000113a:	e509                	bnez	a0,80001144 <kvmmap+0x1c>
}
    8000113c:	60a2                	ld	ra,8(sp)
    8000113e:	6402                	ld	s0,0(sp)
    80001140:	0141                	addi	sp,sp,16
    80001142:	8082                	ret
    panic("kvmmap");
    80001144:	00006517          	auipc	a0,0x6
    80001148:	fd450513          	addi	a0,a0,-44 # 80007118 <etext+0x118>
    8000114c:	e8aff0ef          	jal	800007d6 <panic>

0000000080001150 <kvmmake>:
{
    80001150:	1101                	addi	sp,sp,-32
    80001152:	ec06                	sd	ra,24(sp)
    80001154:	e822                	sd	s0,16(sp)
    80001156:	e426                	sd	s1,8(sp)
    80001158:	e04a                	sd	s2,0(sp)
    8000115a:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000115c:	a07ff0ef          	jal	80000b62 <kalloc>
    80001160:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001162:	6605                	lui	a2,0x1
    80001164:	4581                	li	a1,0
    80001166:	ba1ff0ef          	jal	80000d06 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000116a:	4719                	li	a4,6
    8000116c:	6685                	lui	a3,0x1
    8000116e:	10000637          	lui	a2,0x10000
    80001172:	85b2                	mv	a1,a2
    80001174:	8526                	mv	a0,s1
    80001176:	fb3ff0ef          	jal	80001128 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000117a:	4719                	li	a4,6
    8000117c:	6685                	lui	a3,0x1
    8000117e:	10001637          	lui	a2,0x10001
    80001182:	85b2                	mv	a1,a2
    80001184:	8526                	mv	a0,s1
    80001186:	fa3ff0ef          	jal	80001128 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    8000118a:	4719                	li	a4,6
    8000118c:	040006b7          	lui	a3,0x4000
    80001190:	0c000637          	lui	a2,0xc000
    80001194:	85b2                	mv	a1,a2
    80001196:	8526                	mv	a0,s1
    80001198:	f91ff0ef          	jal	80001128 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000119c:	00006917          	auipc	s2,0x6
    800011a0:	e6490913          	addi	s2,s2,-412 # 80007000 <etext>
    800011a4:	4729                	li	a4,10
    800011a6:	80006697          	auipc	a3,0x80006
    800011aa:	e5a68693          	addi	a3,a3,-422 # 7000 <_entry-0x7fff9000>
    800011ae:	4605                	li	a2,1
    800011b0:	067e                	slli	a2,a2,0x1f
    800011b2:	85b2                	mv	a1,a2
    800011b4:	8526                	mv	a0,s1
    800011b6:	f73ff0ef          	jal	80001128 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011ba:	4719                	li	a4,6
    800011bc:	46c5                	li	a3,17
    800011be:	06ee                	slli	a3,a3,0x1b
    800011c0:	412686b3          	sub	a3,a3,s2
    800011c4:	864a                	mv	a2,s2
    800011c6:	85ca                	mv	a1,s2
    800011c8:	8526                	mv	a0,s1
    800011ca:	f5fff0ef          	jal	80001128 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011ce:	4729                	li	a4,10
    800011d0:	6685                	lui	a3,0x1
    800011d2:	00005617          	auipc	a2,0x5
    800011d6:	e2e60613          	addi	a2,a2,-466 # 80006000 <_trampoline>
    800011da:	040005b7          	lui	a1,0x4000
    800011de:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800011e0:	05b2                	slli	a1,a1,0xc
    800011e2:	8526                	mv	a0,s1
    800011e4:	f45ff0ef          	jal	80001128 <kvmmap>
  proc_mapstacks(kpgtbl);
    800011e8:	8526                	mv	a0,s1
    800011ea:	5a8000ef          	jal	80001792 <proc_mapstacks>
}
    800011ee:	8526                	mv	a0,s1
    800011f0:	60e2                	ld	ra,24(sp)
    800011f2:	6442                	ld	s0,16(sp)
    800011f4:	64a2                	ld	s1,8(sp)
    800011f6:	6902                	ld	s2,0(sp)
    800011f8:	6105                	addi	sp,sp,32
    800011fa:	8082                	ret

00000000800011fc <kvminit>:
{
    800011fc:	1141                	addi	sp,sp,-16
    800011fe:	e406                	sd	ra,8(sp)
    80001200:	e022                	sd	s0,0(sp)
    80001202:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001204:	f4dff0ef          	jal	80001150 <kvmmake>
    80001208:	00009797          	auipc	a5,0x9
    8000120c:	48a7b423          	sd	a0,1160(a5) # 8000a690 <kernel_pagetable>
}
    80001210:	60a2                	ld	ra,8(sp)
    80001212:	6402                	ld	s0,0(sp)
    80001214:	0141                	addi	sp,sp,16
    80001216:	8082                	ret

0000000080001218 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001218:	715d                	addi	sp,sp,-80
    8000121a:	e486                	sd	ra,72(sp)
    8000121c:	e0a2                	sd	s0,64(sp)
    8000121e:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001220:	03459793          	slli	a5,a1,0x34
    80001224:	e39d                	bnez	a5,8000124a <uvmunmap+0x32>
    80001226:	f84a                	sd	s2,48(sp)
    80001228:	f44e                	sd	s3,40(sp)
    8000122a:	f052                	sd	s4,32(sp)
    8000122c:	ec56                	sd	s5,24(sp)
    8000122e:	e85a                	sd	s6,16(sp)
    80001230:	e45e                	sd	s7,8(sp)
    80001232:	8a2a                	mv	s4,a0
    80001234:	892e                	mv	s2,a1
    80001236:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001238:	0632                	slli	a2,a2,0xc
    8000123a:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000123e:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001240:	6b05                	lui	s6,0x1
    80001242:	0735ff63          	bgeu	a1,s3,800012c0 <uvmunmap+0xa8>
    80001246:	fc26                	sd	s1,56(sp)
    80001248:	a0a9                	j	80001292 <uvmunmap+0x7a>
    8000124a:	fc26                	sd	s1,56(sp)
    8000124c:	f84a                	sd	s2,48(sp)
    8000124e:	f44e                	sd	s3,40(sp)
    80001250:	f052                	sd	s4,32(sp)
    80001252:	ec56                	sd	s5,24(sp)
    80001254:	e85a                	sd	s6,16(sp)
    80001256:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    80001258:	00006517          	auipc	a0,0x6
    8000125c:	ec850513          	addi	a0,a0,-312 # 80007120 <etext+0x120>
    80001260:	d76ff0ef          	jal	800007d6 <panic>
      panic("uvmunmap: walk");
    80001264:	00006517          	auipc	a0,0x6
    80001268:	ed450513          	addi	a0,a0,-300 # 80007138 <etext+0x138>
    8000126c:	d6aff0ef          	jal	800007d6 <panic>
      panic("uvmunmap: not mapped");
    80001270:	00006517          	auipc	a0,0x6
    80001274:	ed850513          	addi	a0,a0,-296 # 80007148 <etext+0x148>
    80001278:	d5eff0ef          	jal	800007d6 <panic>
      panic("uvmunmap: not a leaf");
    8000127c:	00006517          	auipc	a0,0x6
    80001280:	ee450513          	addi	a0,a0,-284 # 80007160 <etext+0x160>
    80001284:	d52ff0ef          	jal	800007d6 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    80001288:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000128c:	995a                	add	s2,s2,s6
    8000128e:	03397863          	bgeu	s2,s3,800012be <uvmunmap+0xa6>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001292:	4601                	li	a2,0
    80001294:	85ca                	mv	a1,s2
    80001296:	8552                	mv	a0,s4
    80001298:	d03ff0ef          	jal	80000f9a <walk>
    8000129c:	84aa                	mv	s1,a0
    8000129e:	d179                	beqz	a0,80001264 <uvmunmap+0x4c>
    if((*pte & PTE_V) == 0)
    800012a0:	6108                	ld	a0,0(a0)
    800012a2:	00157793          	andi	a5,a0,1
    800012a6:	d7e9                	beqz	a5,80001270 <uvmunmap+0x58>
    if(PTE_FLAGS(*pte) == PTE_V)
    800012a8:	3ff57793          	andi	a5,a0,1023
    800012ac:	fd7788e3          	beq	a5,s7,8000127c <uvmunmap+0x64>
    if(do_free){
    800012b0:	fc0a8ce3          	beqz	s5,80001288 <uvmunmap+0x70>
      uint64 pa = PTE2PA(*pte);
    800012b4:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800012b6:	0532                	slli	a0,a0,0xc
    800012b8:	fc8ff0ef          	jal	80000a80 <kfree>
    800012bc:	b7f1                	j	80001288 <uvmunmap+0x70>
    800012be:	74e2                	ld	s1,56(sp)
    800012c0:	7942                	ld	s2,48(sp)
    800012c2:	79a2                	ld	s3,40(sp)
    800012c4:	7a02                	ld	s4,32(sp)
    800012c6:	6ae2                	ld	s5,24(sp)
    800012c8:	6b42                	ld	s6,16(sp)
    800012ca:	6ba2                	ld	s7,8(sp)
  }
}
    800012cc:	60a6                	ld	ra,72(sp)
    800012ce:	6406                	ld	s0,64(sp)
    800012d0:	6161                	addi	sp,sp,80
    800012d2:	8082                	ret

00000000800012d4 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800012d4:	1101                	addi	sp,sp,-32
    800012d6:	ec06                	sd	ra,24(sp)
    800012d8:	e822                	sd	s0,16(sp)
    800012da:	e426                	sd	s1,8(sp)
    800012dc:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800012de:	885ff0ef          	jal	80000b62 <kalloc>
    800012e2:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800012e4:	c509                	beqz	a0,800012ee <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800012e6:	6605                	lui	a2,0x1
    800012e8:	4581                	li	a1,0
    800012ea:	a1dff0ef          	jal	80000d06 <memset>
  return pagetable;
}
    800012ee:	8526                	mv	a0,s1
    800012f0:	60e2                	ld	ra,24(sp)
    800012f2:	6442                	ld	s0,16(sp)
    800012f4:	64a2                	ld	s1,8(sp)
    800012f6:	6105                	addi	sp,sp,32
    800012f8:	8082                	ret

00000000800012fa <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800012fa:	7179                	addi	sp,sp,-48
    800012fc:	f406                	sd	ra,40(sp)
    800012fe:	f022                	sd	s0,32(sp)
    80001300:	ec26                	sd	s1,24(sp)
    80001302:	e84a                	sd	s2,16(sp)
    80001304:	e44e                	sd	s3,8(sp)
    80001306:	e052                	sd	s4,0(sp)
    80001308:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000130a:	6785                	lui	a5,0x1
    8000130c:	04f67063          	bgeu	a2,a5,8000134c <uvmfirst+0x52>
    80001310:	8a2a                	mv	s4,a0
    80001312:	89ae                	mv	s3,a1
    80001314:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001316:	84dff0ef          	jal	80000b62 <kalloc>
    8000131a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000131c:	6605                	lui	a2,0x1
    8000131e:	4581                	li	a1,0
    80001320:	9e7ff0ef          	jal	80000d06 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001324:	4779                	li	a4,30
    80001326:	86ca                	mv	a3,s2
    80001328:	6605                	lui	a2,0x1
    8000132a:	4581                	li	a1,0
    8000132c:	8552                	mv	a0,s4
    8000132e:	d45ff0ef          	jal	80001072 <mappages>
  memmove(mem, src, sz);
    80001332:	8626                	mv	a2,s1
    80001334:	85ce                	mv	a1,s3
    80001336:	854a                	mv	a0,s2
    80001338:	a33ff0ef          	jal	80000d6a <memmove>
}
    8000133c:	70a2                	ld	ra,40(sp)
    8000133e:	7402                	ld	s0,32(sp)
    80001340:	64e2                	ld	s1,24(sp)
    80001342:	6942                	ld	s2,16(sp)
    80001344:	69a2                	ld	s3,8(sp)
    80001346:	6a02                	ld	s4,0(sp)
    80001348:	6145                	addi	sp,sp,48
    8000134a:	8082                	ret
    panic("uvmfirst: more than a page");
    8000134c:	00006517          	auipc	a0,0x6
    80001350:	e2c50513          	addi	a0,a0,-468 # 80007178 <etext+0x178>
    80001354:	c82ff0ef          	jal	800007d6 <panic>

0000000080001358 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001358:	1101                	addi	sp,sp,-32
    8000135a:	ec06                	sd	ra,24(sp)
    8000135c:	e822                	sd	s0,16(sp)
    8000135e:	e426                	sd	s1,8(sp)
    80001360:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001362:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001364:	00b67d63          	bgeu	a2,a1,8000137e <uvmdealloc+0x26>
    80001368:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000136a:	6785                	lui	a5,0x1
    8000136c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000136e:	00f60733          	add	a4,a2,a5
    80001372:	76fd                	lui	a3,0xfffff
    80001374:	8f75                	and	a4,a4,a3
    80001376:	97ae                	add	a5,a5,a1
    80001378:	8ff5                	and	a5,a5,a3
    8000137a:	00f76863          	bltu	a4,a5,8000138a <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000137e:	8526                	mv	a0,s1
    80001380:	60e2                	ld	ra,24(sp)
    80001382:	6442                	ld	s0,16(sp)
    80001384:	64a2                	ld	s1,8(sp)
    80001386:	6105                	addi	sp,sp,32
    80001388:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000138a:	8f99                	sub	a5,a5,a4
    8000138c:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000138e:	4685                	li	a3,1
    80001390:	0007861b          	sext.w	a2,a5
    80001394:	85ba                	mv	a1,a4
    80001396:	e83ff0ef          	jal	80001218 <uvmunmap>
    8000139a:	b7d5                	j	8000137e <uvmdealloc+0x26>

000000008000139c <uvmalloc>:
  if(newsz < oldsz)
    8000139c:	0ab66363          	bltu	a2,a1,80001442 <uvmalloc+0xa6>
{
    800013a0:	715d                	addi	sp,sp,-80
    800013a2:	e486                	sd	ra,72(sp)
    800013a4:	e0a2                	sd	s0,64(sp)
    800013a6:	f052                	sd	s4,32(sp)
    800013a8:	ec56                	sd	s5,24(sp)
    800013aa:	e85a                	sd	s6,16(sp)
    800013ac:	0880                	addi	s0,sp,80
    800013ae:	8b2a                	mv	s6,a0
    800013b0:	8ab2                	mv	s5,a2
  oldsz = PGROUNDUP(oldsz);
    800013b2:	6785                	lui	a5,0x1
    800013b4:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013b6:	95be                	add	a1,a1,a5
    800013b8:	77fd                	lui	a5,0xfffff
    800013ba:	00f5fa33          	and	s4,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    800013be:	08ca7463          	bgeu	s4,a2,80001446 <uvmalloc+0xaa>
    800013c2:	fc26                	sd	s1,56(sp)
    800013c4:	f84a                	sd	s2,48(sp)
    800013c6:	f44e                	sd	s3,40(sp)
    800013c8:	e45e                	sd	s7,8(sp)
    800013ca:	8952                	mv	s2,s4
    memset(mem, 0, PGSIZE);
    800013cc:	6985                	lui	s3,0x1
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800013ce:	0126eb93          	ori	s7,a3,18
    mem = kalloc();
    800013d2:	f90ff0ef          	jal	80000b62 <kalloc>
    800013d6:	84aa                	mv	s1,a0
    if(mem == 0){
    800013d8:	c515                	beqz	a0,80001404 <uvmalloc+0x68>
    memset(mem, 0, PGSIZE);
    800013da:	864e                	mv	a2,s3
    800013dc:	4581                	li	a1,0
    800013de:	929ff0ef          	jal	80000d06 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800013e2:	875e                	mv	a4,s7
    800013e4:	86a6                	mv	a3,s1
    800013e6:	864e                	mv	a2,s3
    800013e8:	85ca                	mv	a1,s2
    800013ea:	855a                	mv	a0,s6
    800013ec:	c87ff0ef          	jal	80001072 <mappages>
    800013f0:	e91d                	bnez	a0,80001426 <uvmalloc+0x8a>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800013f2:	994e                	add	s2,s2,s3
    800013f4:	fd596fe3          	bltu	s2,s5,800013d2 <uvmalloc+0x36>
  return newsz;
    800013f8:	8556                	mv	a0,s5
    800013fa:	74e2                	ld	s1,56(sp)
    800013fc:	7942                	ld	s2,48(sp)
    800013fe:	79a2                	ld	s3,40(sp)
    80001400:	6ba2                	ld	s7,8(sp)
    80001402:	a819                	j	80001418 <uvmalloc+0x7c>
      uvmdealloc(pagetable, a, oldsz);
    80001404:	8652                	mv	a2,s4
    80001406:	85ca                	mv	a1,s2
    80001408:	855a                	mv	a0,s6
    8000140a:	f4fff0ef          	jal	80001358 <uvmdealloc>
      return 0;
    8000140e:	4501                	li	a0,0
    80001410:	74e2                	ld	s1,56(sp)
    80001412:	7942                	ld	s2,48(sp)
    80001414:	79a2                	ld	s3,40(sp)
    80001416:	6ba2                	ld	s7,8(sp)
}
    80001418:	60a6                	ld	ra,72(sp)
    8000141a:	6406                	ld	s0,64(sp)
    8000141c:	7a02                	ld	s4,32(sp)
    8000141e:	6ae2                	ld	s5,24(sp)
    80001420:	6b42                	ld	s6,16(sp)
    80001422:	6161                	addi	sp,sp,80
    80001424:	8082                	ret
      kfree(mem);
    80001426:	8526                	mv	a0,s1
    80001428:	e58ff0ef          	jal	80000a80 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000142c:	8652                	mv	a2,s4
    8000142e:	85ca                	mv	a1,s2
    80001430:	855a                	mv	a0,s6
    80001432:	f27ff0ef          	jal	80001358 <uvmdealloc>
      return 0;
    80001436:	4501                	li	a0,0
    80001438:	74e2                	ld	s1,56(sp)
    8000143a:	7942                	ld	s2,48(sp)
    8000143c:	79a2                	ld	s3,40(sp)
    8000143e:	6ba2                	ld	s7,8(sp)
    80001440:	bfe1                	j	80001418 <uvmalloc+0x7c>
    return oldsz;
    80001442:	852e                	mv	a0,a1
}
    80001444:	8082                	ret
  return newsz;
    80001446:	8532                	mv	a0,a2
    80001448:	bfc1                	j	80001418 <uvmalloc+0x7c>

000000008000144a <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000144a:	7179                	addi	sp,sp,-48
    8000144c:	f406                	sd	ra,40(sp)
    8000144e:	f022                	sd	s0,32(sp)
    80001450:	ec26                	sd	s1,24(sp)
    80001452:	e84a                	sd	s2,16(sp)
    80001454:	e44e                	sd	s3,8(sp)
    80001456:	e052                	sd	s4,0(sp)
    80001458:	1800                	addi	s0,sp,48
    8000145a:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000145c:	84aa                	mv	s1,a0
    8000145e:	6905                	lui	s2,0x1
    80001460:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001462:	4985                	li	s3,1
    80001464:	a819                	j	8000147a <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001466:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001468:	00c79513          	slli	a0,a5,0xc
    8000146c:	fdfff0ef          	jal	8000144a <freewalk>
      pagetable[i] = 0;
    80001470:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001474:	04a1                	addi	s1,s1,8
    80001476:	01248f63          	beq	s1,s2,80001494 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    8000147a:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000147c:	00f7f713          	andi	a4,a5,15
    80001480:	ff3703e3          	beq	a4,s3,80001466 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001484:	8b85                	andi	a5,a5,1
    80001486:	d7fd                	beqz	a5,80001474 <freewalk+0x2a>
      panic("freewalk: leaf");
    80001488:	00006517          	auipc	a0,0x6
    8000148c:	d1050513          	addi	a0,a0,-752 # 80007198 <etext+0x198>
    80001490:	b46ff0ef          	jal	800007d6 <panic>
    }
  }
  kfree((void*)pagetable);
    80001494:	8552                	mv	a0,s4
    80001496:	deaff0ef          	jal	80000a80 <kfree>
}
    8000149a:	70a2                	ld	ra,40(sp)
    8000149c:	7402                	ld	s0,32(sp)
    8000149e:	64e2                	ld	s1,24(sp)
    800014a0:	6942                	ld	s2,16(sp)
    800014a2:	69a2                	ld	s3,8(sp)
    800014a4:	6a02                	ld	s4,0(sp)
    800014a6:	6145                	addi	sp,sp,48
    800014a8:	8082                	ret

00000000800014aa <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800014aa:	1101                	addi	sp,sp,-32
    800014ac:	ec06                	sd	ra,24(sp)
    800014ae:	e822                	sd	s0,16(sp)
    800014b0:	e426                	sd	s1,8(sp)
    800014b2:	1000                	addi	s0,sp,32
    800014b4:	84aa                	mv	s1,a0
  if(sz > 0)
    800014b6:	e989                	bnez	a1,800014c8 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800014b8:	8526                	mv	a0,s1
    800014ba:	f91ff0ef          	jal	8000144a <freewalk>
}
    800014be:	60e2                	ld	ra,24(sp)
    800014c0:	6442                	ld	s0,16(sp)
    800014c2:	64a2                	ld	s1,8(sp)
    800014c4:	6105                	addi	sp,sp,32
    800014c6:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800014c8:	6785                	lui	a5,0x1
    800014ca:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800014cc:	95be                	add	a1,a1,a5
    800014ce:	4685                	li	a3,1
    800014d0:	00c5d613          	srli	a2,a1,0xc
    800014d4:	4581                	li	a1,0
    800014d6:	d43ff0ef          	jal	80001218 <uvmunmap>
    800014da:	bff9                	j	800014b8 <uvmfree+0xe>

00000000800014dc <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800014dc:	ca4d                	beqz	a2,8000158e <uvmcopy+0xb2>
{
    800014de:	715d                	addi	sp,sp,-80
    800014e0:	e486                	sd	ra,72(sp)
    800014e2:	e0a2                	sd	s0,64(sp)
    800014e4:	fc26                	sd	s1,56(sp)
    800014e6:	f84a                	sd	s2,48(sp)
    800014e8:	f44e                	sd	s3,40(sp)
    800014ea:	f052                	sd	s4,32(sp)
    800014ec:	ec56                	sd	s5,24(sp)
    800014ee:	e85a                	sd	s6,16(sp)
    800014f0:	e45e                	sd	s7,8(sp)
    800014f2:	e062                	sd	s8,0(sp)
    800014f4:	0880                	addi	s0,sp,80
    800014f6:	8baa                	mv	s7,a0
    800014f8:	8b2e                	mv	s6,a1
    800014fa:	8ab2                	mv	s5,a2
  for(i = 0; i < sz; i += PGSIZE){
    800014fc:	4981                	li	s3,0
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800014fe:	6a05                	lui	s4,0x1
    if((pte = walk(old, i, 0)) == 0)
    80001500:	4601                	li	a2,0
    80001502:	85ce                	mv	a1,s3
    80001504:	855e                	mv	a0,s7
    80001506:	a95ff0ef          	jal	80000f9a <walk>
    8000150a:	cd1d                	beqz	a0,80001548 <uvmcopy+0x6c>
    if((*pte & PTE_V) == 0)
    8000150c:	6118                	ld	a4,0(a0)
    8000150e:	00177793          	andi	a5,a4,1
    80001512:	c3a9                	beqz	a5,80001554 <uvmcopy+0x78>
    pa = PTE2PA(*pte);
    80001514:	00a75593          	srli	a1,a4,0xa
    80001518:	00c59c13          	slli	s8,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000151c:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001520:	e42ff0ef          	jal	80000b62 <kalloc>
    80001524:	892a                	mv	s2,a0
    80001526:	c121                	beqz	a0,80001566 <uvmcopy+0x8a>
    memmove(mem, (char*)pa, PGSIZE);
    80001528:	8652                	mv	a2,s4
    8000152a:	85e2                	mv	a1,s8
    8000152c:	83fff0ef          	jal	80000d6a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001530:	8726                	mv	a4,s1
    80001532:	86ca                	mv	a3,s2
    80001534:	8652                	mv	a2,s4
    80001536:	85ce                	mv	a1,s3
    80001538:	855a                	mv	a0,s6
    8000153a:	b39ff0ef          	jal	80001072 <mappages>
    8000153e:	e10d                	bnez	a0,80001560 <uvmcopy+0x84>
  for(i = 0; i < sz; i += PGSIZE){
    80001540:	99d2                	add	s3,s3,s4
    80001542:	fb59efe3          	bltu	s3,s5,80001500 <uvmcopy+0x24>
    80001546:	a805                	j	80001576 <uvmcopy+0x9a>
      panic("uvmcopy: pte should exist");
    80001548:	00006517          	auipc	a0,0x6
    8000154c:	c6050513          	addi	a0,a0,-928 # 800071a8 <etext+0x1a8>
    80001550:	a86ff0ef          	jal	800007d6 <panic>
      panic("uvmcopy: page not present");
    80001554:	00006517          	auipc	a0,0x6
    80001558:	c7450513          	addi	a0,a0,-908 # 800071c8 <etext+0x1c8>
    8000155c:	a7aff0ef          	jal	800007d6 <panic>
      kfree(mem);
    80001560:	854a                	mv	a0,s2
    80001562:	d1eff0ef          	jal	80000a80 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001566:	4685                	li	a3,1
    80001568:	00c9d613          	srli	a2,s3,0xc
    8000156c:	4581                	li	a1,0
    8000156e:	855a                	mv	a0,s6
    80001570:	ca9ff0ef          	jal	80001218 <uvmunmap>
  return -1;
    80001574:	557d                	li	a0,-1
}
    80001576:	60a6                	ld	ra,72(sp)
    80001578:	6406                	ld	s0,64(sp)
    8000157a:	74e2                	ld	s1,56(sp)
    8000157c:	7942                	ld	s2,48(sp)
    8000157e:	79a2                	ld	s3,40(sp)
    80001580:	7a02                	ld	s4,32(sp)
    80001582:	6ae2                	ld	s5,24(sp)
    80001584:	6b42                	ld	s6,16(sp)
    80001586:	6ba2                	ld	s7,8(sp)
    80001588:	6c02                	ld	s8,0(sp)
    8000158a:	6161                	addi	sp,sp,80
    8000158c:	8082                	ret
  return 0;
    8000158e:	4501                	li	a0,0
}
    80001590:	8082                	ret

0000000080001592 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001592:	1141                	addi	sp,sp,-16
    80001594:	e406                	sd	ra,8(sp)
    80001596:	e022                	sd	s0,0(sp)
    80001598:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000159a:	4601                	li	a2,0
    8000159c:	9ffff0ef          	jal	80000f9a <walk>
  if(pte == 0)
    800015a0:	c901                	beqz	a0,800015b0 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800015a2:	611c                	ld	a5,0(a0)
    800015a4:	9bbd                	andi	a5,a5,-17
    800015a6:	e11c                	sd	a5,0(a0)
}
    800015a8:	60a2                	ld	ra,8(sp)
    800015aa:	6402                	ld	s0,0(sp)
    800015ac:	0141                	addi	sp,sp,16
    800015ae:	8082                	ret
    panic("uvmclear");
    800015b0:	00006517          	auipc	a0,0x6
    800015b4:	c3850513          	addi	a0,a0,-968 # 800071e8 <etext+0x1e8>
    800015b8:	a1eff0ef          	jal	800007d6 <panic>

00000000800015bc <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    800015bc:	c2d9                	beqz	a3,80001642 <copyout+0x86>
{
    800015be:	711d                	addi	sp,sp,-96
    800015c0:	ec86                	sd	ra,88(sp)
    800015c2:	e8a2                	sd	s0,80(sp)
    800015c4:	e4a6                	sd	s1,72(sp)
    800015c6:	e0ca                	sd	s2,64(sp)
    800015c8:	fc4e                	sd	s3,56(sp)
    800015ca:	f852                	sd	s4,48(sp)
    800015cc:	f456                	sd	s5,40(sp)
    800015ce:	f05a                	sd	s6,32(sp)
    800015d0:	ec5e                	sd	s7,24(sp)
    800015d2:	e862                	sd	s8,16(sp)
    800015d4:	e466                	sd	s9,8(sp)
    800015d6:	e06a                	sd	s10,0(sp)
    800015d8:	1080                	addi	s0,sp,96
    800015da:	8c2a                	mv	s8,a0
    800015dc:	892e                	mv	s2,a1
    800015de:	8ab2                	mv	s5,a2
    800015e0:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    800015e2:	7cfd                	lui	s9,0xfffff
    if(va0 >= MAXVA)
    800015e4:	5bfd                	li	s7,-1
    800015e6:	01abdb93          	srli	s7,s7,0x1a
      return -1;
    pte = walk(pagetable, va0, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    800015ea:	4d55                	li	s10,21
       (*pte & PTE_W) == 0)
      return -1;
    pa0 = PTE2PA(*pte);
    n = PGSIZE - (dstva - va0);
    800015ec:	6b05                	lui	s6,0x1
    800015ee:	a015                	j	80001612 <copyout+0x56>
    pa0 = PTE2PA(*pte);
    800015f0:	83a9                	srli	a5,a5,0xa
    800015f2:	07b2                	slli	a5,a5,0xc
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800015f4:	41390533          	sub	a0,s2,s3
    800015f8:	0004861b          	sext.w	a2,s1
    800015fc:	85d6                	mv	a1,s5
    800015fe:	953e                	add	a0,a0,a5
    80001600:	f6aff0ef          	jal	80000d6a <memmove>

    len -= n;
    80001604:	409a0a33          	sub	s4,s4,s1
    src += n;
    80001608:	9aa6                	add	s5,s5,s1
    dstva = va0 + PGSIZE;
    8000160a:	01698933          	add	s2,s3,s6
  while(len > 0){
    8000160e:	020a0863          	beqz	s4,8000163e <copyout+0x82>
    va0 = PGROUNDDOWN(dstva);
    80001612:	019979b3          	and	s3,s2,s9
    if(va0 >= MAXVA)
    80001616:	033be863          	bltu	s7,s3,80001646 <copyout+0x8a>
    pte = walk(pagetable, va0, 0);
    8000161a:	4601                	li	a2,0
    8000161c:	85ce                	mv	a1,s3
    8000161e:	8562                	mv	a0,s8
    80001620:	97bff0ef          	jal	80000f9a <walk>
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    80001624:	c121                	beqz	a0,80001664 <copyout+0xa8>
    80001626:	611c                	ld	a5,0(a0)
    80001628:	0157f713          	andi	a4,a5,21
    8000162c:	03a71e63          	bne	a4,s10,80001668 <copyout+0xac>
    n = PGSIZE - (dstva - va0);
    80001630:	412984b3          	sub	s1,s3,s2
    80001634:	94da                	add	s1,s1,s6
    if(n > len)
    80001636:	fa9a7de3          	bgeu	s4,s1,800015f0 <copyout+0x34>
    8000163a:	84d2                	mv	s1,s4
    8000163c:	bf55                	j	800015f0 <copyout+0x34>
  }
  return 0;
    8000163e:	4501                	li	a0,0
    80001640:	a021                	j	80001648 <copyout+0x8c>
    80001642:	4501                	li	a0,0
}
    80001644:	8082                	ret
      return -1;
    80001646:	557d                	li	a0,-1
}
    80001648:	60e6                	ld	ra,88(sp)
    8000164a:	6446                	ld	s0,80(sp)
    8000164c:	64a6                	ld	s1,72(sp)
    8000164e:	6906                	ld	s2,64(sp)
    80001650:	79e2                	ld	s3,56(sp)
    80001652:	7a42                	ld	s4,48(sp)
    80001654:	7aa2                	ld	s5,40(sp)
    80001656:	7b02                	ld	s6,32(sp)
    80001658:	6be2                	ld	s7,24(sp)
    8000165a:	6c42                	ld	s8,16(sp)
    8000165c:	6ca2                	ld	s9,8(sp)
    8000165e:	6d02                	ld	s10,0(sp)
    80001660:	6125                	addi	sp,sp,96
    80001662:	8082                	ret
      return -1;
    80001664:	557d                	li	a0,-1
    80001666:	b7cd                	j	80001648 <copyout+0x8c>
    80001668:	557d                	li	a0,-1
    8000166a:	bff9                	j	80001648 <copyout+0x8c>

000000008000166c <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000166c:	c6a5                	beqz	a3,800016d4 <copyin+0x68>
{
    8000166e:	715d                	addi	sp,sp,-80
    80001670:	e486                	sd	ra,72(sp)
    80001672:	e0a2                	sd	s0,64(sp)
    80001674:	fc26                	sd	s1,56(sp)
    80001676:	f84a                	sd	s2,48(sp)
    80001678:	f44e                	sd	s3,40(sp)
    8000167a:	f052                	sd	s4,32(sp)
    8000167c:	ec56                	sd	s5,24(sp)
    8000167e:	e85a                	sd	s6,16(sp)
    80001680:	e45e                	sd	s7,8(sp)
    80001682:	e062                	sd	s8,0(sp)
    80001684:	0880                	addi	s0,sp,80
    80001686:	8b2a                	mv	s6,a0
    80001688:	8a2e                	mv	s4,a1
    8000168a:	8c32                	mv	s8,a2
    8000168c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000168e:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001690:	6a85                	lui	s5,0x1
    80001692:	a00d                	j	800016b4 <copyin+0x48>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001694:	018505b3          	add	a1,a0,s8
    80001698:	0004861b          	sext.w	a2,s1
    8000169c:	412585b3          	sub	a1,a1,s2
    800016a0:	8552                	mv	a0,s4
    800016a2:	ec8ff0ef          	jal	80000d6a <memmove>

    len -= n;
    800016a6:	409989b3          	sub	s3,s3,s1
    dst += n;
    800016aa:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800016ac:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016b0:	02098063          	beqz	s3,800016d0 <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    800016b4:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016b8:	85ca                	mv	a1,s2
    800016ba:	855a                	mv	a0,s6
    800016bc:	979ff0ef          	jal	80001034 <walkaddr>
    if(pa0 == 0)
    800016c0:	cd01                	beqz	a0,800016d8 <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    800016c2:	418904b3          	sub	s1,s2,s8
    800016c6:	94d6                	add	s1,s1,s5
    if(n > len)
    800016c8:	fc99f6e3          	bgeu	s3,s1,80001694 <copyin+0x28>
    800016cc:	84ce                	mv	s1,s3
    800016ce:	b7d9                	j	80001694 <copyin+0x28>
  }
  return 0;
    800016d0:	4501                	li	a0,0
    800016d2:	a021                	j	800016da <copyin+0x6e>
    800016d4:	4501                	li	a0,0
}
    800016d6:	8082                	ret
      return -1;
    800016d8:	557d                	li	a0,-1
}
    800016da:	60a6                	ld	ra,72(sp)
    800016dc:	6406                	ld	s0,64(sp)
    800016de:	74e2                	ld	s1,56(sp)
    800016e0:	7942                	ld	s2,48(sp)
    800016e2:	79a2                	ld	s3,40(sp)
    800016e4:	7a02                	ld	s4,32(sp)
    800016e6:	6ae2                	ld	s5,24(sp)
    800016e8:	6b42                	ld	s6,16(sp)
    800016ea:	6ba2                	ld	s7,8(sp)
    800016ec:	6c02                	ld	s8,0(sp)
    800016ee:	6161                	addi	sp,sp,80
    800016f0:	8082                	ret

00000000800016f2 <copyinstr>:
// Copy bytes to dst from virtual address srcva in a given page table,
// until a '\0', or max.
// Return 0 on success, -1 on error.
int
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
    800016f2:	715d                	addi	sp,sp,-80
    800016f4:	e486                	sd	ra,72(sp)
    800016f6:	e0a2                	sd	s0,64(sp)
    800016f8:	fc26                	sd	s1,56(sp)
    800016fa:	f84a                	sd	s2,48(sp)
    800016fc:	f44e                	sd	s3,40(sp)
    800016fe:	f052                	sd	s4,32(sp)
    80001700:	ec56                	sd	s5,24(sp)
    80001702:	e85a                	sd	s6,16(sp)
    80001704:	e45e                	sd	s7,8(sp)
    80001706:	0880                	addi	s0,sp,80
    80001708:	8aaa                	mv	s5,a0
    8000170a:	89ae                	mv	s3,a1
    8000170c:	8bb2                	mv	s7,a2
    8000170e:	84b6                	mv	s1,a3
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    va0 = PGROUNDDOWN(srcva);
    80001710:	7b7d                	lui	s6,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001712:	6a05                	lui	s4,0x1
    80001714:	a02d                	j	8000173e <copyinstr+0x4c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001716:	00078023          	sb	zero,0(a5)
    8000171a:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000171c:	0017c793          	xori	a5,a5,1
    80001720:	40f0053b          	negw	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001724:	60a6                	ld	ra,72(sp)
    80001726:	6406                	ld	s0,64(sp)
    80001728:	74e2                	ld	s1,56(sp)
    8000172a:	7942                	ld	s2,48(sp)
    8000172c:	79a2                	ld	s3,40(sp)
    8000172e:	7a02                	ld	s4,32(sp)
    80001730:	6ae2                	ld	s5,24(sp)
    80001732:	6b42                	ld	s6,16(sp)
    80001734:	6ba2                	ld	s7,8(sp)
    80001736:	6161                	addi	sp,sp,80
    80001738:	8082                	ret
    srcva = va0 + PGSIZE;
    8000173a:	01490bb3          	add	s7,s2,s4
  while(got_null == 0 && max > 0){
    8000173e:	c4b1                	beqz	s1,8000178a <copyinstr+0x98>
    va0 = PGROUNDDOWN(srcva);
    80001740:	016bf933          	and	s2,s7,s6
    pa0 = walkaddr(pagetable, va0);
    80001744:	85ca                	mv	a1,s2
    80001746:	8556                	mv	a0,s5
    80001748:	8edff0ef          	jal	80001034 <walkaddr>
    if(pa0 == 0)
    8000174c:	c129                	beqz	a0,8000178e <copyinstr+0x9c>
    n = PGSIZE - (srcva - va0);
    8000174e:	41790633          	sub	a2,s2,s7
    80001752:	9652                	add	a2,a2,s4
    if(n > max)
    80001754:	00c4f363          	bgeu	s1,a2,8000175a <copyinstr+0x68>
    80001758:	8626                	mv	a2,s1
    char *p = (char *) (pa0 + (srcva - va0));
    8000175a:	412b8bb3          	sub	s7,s7,s2
    8000175e:	9baa                	add	s7,s7,a0
    while(n > 0){
    80001760:	de69                	beqz	a2,8000173a <copyinstr+0x48>
    80001762:	87ce                	mv	a5,s3
      if(*p == '\0'){
    80001764:	413b86b3          	sub	a3,s7,s3
    while(n > 0){
    80001768:	964e                	add	a2,a2,s3
    8000176a:	85be                	mv	a1,a5
      if(*p == '\0'){
    8000176c:	00f68733          	add	a4,a3,a5
    80001770:	00074703          	lbu	a4,0(a4)
    80001774:	d34d                	beqz	a4,80001716 <copyinstr+0x24>
        *dst = *p;
    80001776:	00e78023          	sb	a4,0(a5)
      dst++;
    8000177a:	0785                	addi	a5,a5,1
    while(n > 0){
    8000177c:	fec797e3          	bne	a5,a2,8000176a <copyinstr+0x78>
    80001780:	14fd                	addi	s1,s1,-1
    80001782:	94ce                	add	s1,s1,s3
      --max;
    80001784:	8c8d                	sub	s1,s1,a1
    80001786:	89be                	mv	s3,a5
    80001788:	bf4d                	j	8000173a <copyinstr+0x48>
    8000178a:	4781                	li	a5,0
    8000178c:	bf41                	j	8000171c <copyinstr+0x2a>
      return -1;
    8000178e:	557d                	li	a0,-1
    80001790:	bf51                	j	80001724 <copyinstr+0x32>

0000000080001792 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001792:	715d                	addi	sp,sp,-80
    80001794:	e486                	sd	ra,72(sp)
    80001796:	e0a2                	sd	s0,64(sp)
    80001798:	fc26                	sd	s1,56(sp)
    8000179a:	f84a                	sd	s2,48(sp)
    8000179c:	f44e                	sd	s3,40(sp)
    8000179e:	f052                	sd	s4,32(sp)
    800017a0:	ec56                	sd	s5,24(sp)
    800017a2:	e85a                	sd	s6,16(sp)
    800017a4:	e45e                	sd	s7,8(sp)
    800017a6:	e062                	sd	s8,0(sp)
    800017a8:	0880                	addi	s0,sp,80
    800017aa:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800017ac:	00011497          	auipc	s1,0x11
    800017b0:	45448493          	addi	s1,s1,1108 # 80012c00 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800017b4:	8c26                	mv	s8,s1
    800017b6:	a4fa57b7          	lui	a5,0xa4fa5
    800017ba:	fa578793          	addi	a5,a5,-91 # ffffffffa4fa4fa5 <end+0xffffffff24f815c5>
    800017be:	4fa50937          	lui	s2,0x4fa50
    800017c2:	a5090913          	addi	s2,s2,-1456 # 4fa4fa50 <_entry-0x305b05b0>
    800017c6:	1902                	slli	s2,s2,0x20
    800017c8:	993e                	add	s2,s2,a5
    800017ca:	040009b7          	lui	s3,0x4000
    800017ce:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017d0:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017d2:	4b99                	li	s7,6
    800017d4:	6b05                	lui	s6,0x1
  for(p = proc; p < &proc[NPROC]; p++) {
    800017d6:	00017a97          	auipc	s5,0x17
    800017da:	e2aa8a93          	addi	s5,s5,-470 # 80018600 <tickslock>
    char *pa = kalloc();
    800017de:	b84ff0ef          	jal	80000b62 <kalloc>
    800017e2:	862a                	mv	a2,a0
    if(pa == 0)
    800017e4:	c121                	beqz	a0,80001824 <proc_mapstacks+0x92>
    uint64 va = KSTACK((int) (p - proc));
    800017e6:	418485b3          	sub	a1,s1,s8
    800017ea:	858d                	srai	a1,a1,0x3
    800017ec:	032585b3          	mul	a1,a1,s2
    800017f0:	2585                	addiw	a1,a1,1
    800017f2:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017f6:	875e                	mv	a4,s7
    800017f8:	86da                	mv	a3,s6
    800017fa:	40b985b3          	sub	a1,s3,a1
    800017fe:	8552                	mv	a0,s4
    80001800:	929ff0ef          	jal	80001128 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001804:	16848493          	addi	s1,s1,360
    80001808:	fd549be3          	bne	s1,s5,800017de <proc_mapstacks+0x4c>
  }
}
    8000180c:	60a6                	ld	ra,72(sp)
    8000180e:	6406                	ld	s0,64(sp)
    80001810:	74e2                	ld	s1,56(sp)
    80001812:	7942                	ld	s2,48(sp)
    80001814:	79a2                	ld	s3,40(sp)
    80001816:	7a02                	ld	s4,32(sp)
    80001818:	6ae2                	ld	s5,24(sp)
    8000181a:	6b42                	ld	s6,16(sp)
    8000181c:	6ba2                	ld	s7,8(sp)
    8000181e:	6c02                	ld	s8,0(sp)
    80001820:	6161                	addi	sp,sp,80
    80001822:	8082                	ret
      panic("kalloc");
    80001824:	00006517          	auipc	a0,0x6
    80001828:	9d450513          	addi	a0,a0,-1580 # 800071f8 <etext+0x1f8>
    8000182c:	fabfe0ef          	jal	800007d6 <panic>

0000000080001830 <procinit>:


// initialize the proc table.
void
procinit(void)
{
    80001830:	7139                	addi	sp,sp,-64
    80001832:	fc06                	sd	ra,56(sp)
    80001834:	f822                	sd	s0,48(sp)
    80001836:	f426                	sd	s1,40(sp)
    80001838:	f04a                	sd	s2,32(sp)
    8000183a:	ec4e                	sd	s3,24(sp)
    8000183c:	e852                	sd	s4,16(sp)
    8000183e:	e456                	sd	s5,8(sp)
    80001840:	e05a                	sd	s6,0(sp)
    80001842:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001844:	00006597          	auipc	a1,0x6
    80001848:	9bc58593          	addi	a1,a1,-1604 # 80007200 <etext+0x200>
    8000184c:	00011517          	auipc	a0,0x11
    80001850:	f8450513          	addi	a0,a0,-124 # 800127d0 <pid_lock>
    80001854:	b5eff0ef          	jal	80000bb2 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001858:	00006597          	auipc	a1,0x6
    8000185c:	9b058593          	addi	a1,a1,-1616 # 80007208 <etext+0x208>
    80001860:	00011517          	auipc	a0,0x11
    80001864:	f8850513          	addi	a0,a0,-120 # 800127e8 <wait_lock>
    80001868:	b4aff0ef          	jal	80000bb2 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000186c:	00011497          	auipc	s1,0x11
    80001870:	39448493          	addi	s1,s1,916 # 80012c00 <proc>
      initlock(&p->lock, "proc");
    80001874:	00006b17          	auipc	s6,0x6
    80001878:	9a4b0b13          	addi	s6,s6,-1628 # 80007218 <etext+0x218>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000187c:	8aa6                	mv	s5,s1
    8000187e:	a4fa57b7          	lui	a5,0xa4fa5
    80001882:	fa578793          	addi	a5,a5,-91 # ffffffffa4fa4fa5 <end+0xffffffff24f815c5>
    80001886:	4fa50937          	lui	s2,0x4fa50
    8000188a:	a5090913          	addi	s2,s2,-1456 # 4fa4fa50 <_entry-0x305b05b0>
    8000188e:	1902                	slli	s2,s2,0x20
    80001890:	993e                	add	s2,s2,a5
    80001892:	040009b7          	lui	s3,0x4000
    80001896:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001898:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000189a:	00017a17          	auipc	s4,0x17
    8000189e:	d66a0a13          	addi	s4,s4,-666 # 80018600 <tickslock>
      initlock(&p->lock, "proc");
    800018a2:	85da                	mv	a1,s6
    800018a4:	8526                	mv	a0,s1
    800018a6:	b0cff0ef          	jal	80000bb2 <initlock>
      p->state = UNUSED;
    800018aa:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800018ae:	415487b3          	sub	a5,s1,s5
    800018b2:	878d                	srai	a5,a5,0x3
    800018b4:	032787b3          	mul	a5,a5,s2
    800018b8:	2785                	addiw	a5,a5,1
    800018ba:	00d7979b          	slliw	a5,a5,0xd
    800018be:	40f987b3          	sub	a5,s3,a5
    800018c2:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800018c4:	16848493          	addi	s1,s1,360
    800018c8:	fd449de3          	bne	s1,s4,800018a2 <procinit+0x72>
  }
}
    800018cc:	70e2                	ld	ra,56(sp)
    800018ce:	7442                	ld	s0,48(sp)
    800018d0:	74a2                	ld	s1,40(sp)
    800018d2:	7902                	ld	s2,32(sp)
    800018d4:	69e2                	ld	s3,24(sp)
    800018d6:	6a42                	ld	s4,16(sp)
    800018d8:	6aa2                	ld	s5,8(sp)
    800018da:	6b02                	ld	s6,0(sp)
    800018dc:	6121                	addi	sp,sp,64
    800018de:	8082                	ret

00000000800018e0 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018e0:	1141                	addi	sp,sp,-16
    800018e2:	e406                	sd	ra,8(sp)
    800018e4:	e022                	sd	s0,0(sp)
    800018e6:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800018e8:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018ea:	2501                	sext.w	a0,a0
    800018ec:	60a2                	ld	ra,8(sp)
    800018ee:	6402                	ld	s0,0(sp)
    800018f0:	0141                	addi	sp,sp,16
    800018f2:	8082                	ret

00000000800018f4 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800018f4:	1141                	addi	sp,sp,-16
    800018f6:	e406                	sd	ra,8(sp)
    800018f8:	e022                	sd	s0,0(sp)
    800018fa:	0800                	addi	s0,sp,16
    800018fc:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018fe:	2781                	sext.w	a5,a5
    80001900:	079e                	slli	a5,a5,0x7
  return c;
}
    80001902:	00011517          	auipc	a0,0x11
    80001906:	efe50513          	addi	a0,a0,-258 # 80012800 <cpus>
    8000190a:	953e                	add	a0,a0,a5
    8000190c:	60a2                	ld	ra,8(sp)
    8000190e:	6402                	ld	s0,0(sp)
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
    8000191e:	ad8ff0ef          	jal	80000bf6 <push_off>
    80001922:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001924:	2781                	sext.w	a5,a5
    80001926:	079e                	slli	a5,a5,0x7
    80001928:	00011717          	auipc	a4,0x11
    8000192c:	ea870713          	addi	a4,a4,-344 # 800127d0 <pid_lock>
    80001930:	97ba                	add	a5,a5,a4
    80001932:	7b84                	ld	s1,48(a5)
  pop_off();
    80001934:	b46ff0ef          	jal	80000c7a <pop_off>
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
    80001950:	b7aff0ef          	jal	80000cca <release>

  if (first) {
    80001954:	00009797          	auipc	a5,0x9
    80001958:	cac7a783          	lw	a5,-852(a5) # 8000a600 <first.1>
    8000195c:	e799                	bnez	a5,8000196a <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    8000195e:	4c5000ef          	jal	80002622 <usertrapret>
}
    80001962:	60a2                	ld	ra,8(sp)
    80001964:	6402                	ld	s0,0(sp)
    80001966:	0141                	addi	sp,sp,16
    80001968:	8082                	ret
    fsinit(ROOTDEV);
    8000196a:	4505                	li	a0,1
    8000196c:	1f5010ef          	jal	80003360 <fsinit>
    first = 0;
    80001970:	00009797          	auipc	a5,0x9
    80001974:	c807a823          	sw	zero,-880(a5) # 8000a600 <first.1>
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
    8000198e:	e4690913          	addi	s2,s2,-442 # 800127d0 <pid_lock>
    80001992:	854a                	mv	a0,s2
    80001994:	aa2ff0ef          	jal	80000c36 <acquire>
  pid = nextpid;
    80001998:	00009797          	auipc	a5,0x9
    8000199c:	c6c78793          	addi	a5,a5,-916 # 8000a604 <nextpid>
    800019a0:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800019a2:	0014871b          	addiw	a4,s1,1
    800019a6:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800019a8:	854a                	mv	a0,s2
    800019aa:	b20ff0ef          	jal	80000cca <release>
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
    800019ca:	90bff0ef          	jal	800012d4 <uvmcreate>
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
    800019e6:	e8cff0ef          	jal	80001072 <mappages>
    800019ea:	02054663          	bltz	a0,80001a16 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    800019ee:	4719                	li	a4,6
    800019f0:	05893683          	ld	a3,88(s2)
    800019f4:	6605                	lui	a2,0x1
    800019f6:	020005b7          	lui	a1,0x2000
    800019fa:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800019fc:	05b6                	slli	a1,a1,0xd
    800019fe:	8526                	mv	a0,s1
    80001a00:	e72ff0ef          	jal	80001072 <mappages>
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
    80001a1a:	a91ff0ef          	jal	800014aa <uvmfree>
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
    80001a30:	fe8ff0ef          	jal	80001218 <uvmunmap>
    uvmfree(pagetable, 0);
    80001a34:	4581                	li	a1,0
    80001a36:	8526                	mv	a0,s1
    80001a38:	a73ff0ef          	jal	800014aa <uvmfree>
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
    80001a5c:	fbcff0ef          	jal	80001218 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a60:	4681                	li	a3,0
    80001a62:	4605                	li	a2,1
    80001a64:	020005b7          	lui	a1,0x2000
    80001a68:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a6a:	05b6                	slli	a1,a1,0xd
    80001a6c:	8526                	mv	a0,s1
    80001a6e:	faaff0ef          	jal	80001218 <uvmunmap>
  uvmfree(pagetable, sz);
    80001a72:	85ca                	mv	a1,s2
    80001a74:	8526                	mv	a0,s1
    80001a76:	a35ff0ef          	jal	800014aa <uvmfree>
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
    80001a96:	febfe0ef          	jal	80000a80 <kfree>
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
    80001ae6:	11e48493          	addi	s1,s1,286 # 80012c00 <proc>
    80001aea:	00017917          	auipc	s2,0x17
    80001aee:	b1690913          	addi	s2,s2,-1258 # 80018600 <tickslock>
    acquire(&p->lock);
    80001af2:	8526                	mv	a0,s1
    80001af4:	942ff0ef          	jal	80000c36 <acquire>
    if(p->state == UNUSED) {
    80001af8:	4c9c                	lw	a5,24(s1)
    80001afa:	cb91                	beqz	a5,80001b0e <allocproc+0x38>
      release(&p->lock);
    80001afc:	8526                	mv	a0,s1
    80001afe:	9ccff0ef          	jal	80000cca <release>
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
    80001b18:	84aff0ef          	jal	80000b62 <kalloc>
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
    80001b38:	9ceff0ef          	jal	80000d06 <memset>
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
    80001b64:	966ff0ef          	jal	80000cca <release>
    return 0;
    80001b68:	84ca                	mv	s1,s2
    80001b6a:	b7d5                	j	80001b4e <allocproc+0x78>
    freeproc(p);
    80001b6c:	8526                	mv	a0,s1
    80001b6e:	f19ff0ef          	jal	80001a86 <freeproc>
    release(&p->lock);
    80001b72:	8526                	mv	a0,s1
    80001b74:	956ff0ef          	jal	80000cca <release>
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
    80001b90:	b0a7b623          	sd	a0,-1268(a5) # 8000a698 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001b94:	03400613          	li	a2,52
    80001b98:	00009597          	auipc	a1,0x9
    80001b9c:	a7858593          	addi	a1,a1,-1416 # 8000a610 <initcode>
    80001ba0:	6928                	ld	a0,80(a0)
    80001ba2:	f58ff0ef          	jal	800012fa <uvmfirst>
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
    80001bc2:	a96ff0ef          	jal	80000e58 <safestrcpy>
  p->cwd = namei("/");
    80001bc6:	00005517          	auipc	a0,0x5
    80001bca:	66a50513          	addi	a0,a0,1642 # 80007230 <etext+0x230>
    80001bce:	0b6020ef          	jal	80003c84 <namei>
    80001bd2:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001bd6:	478d                	li	a5,3
    80001bd8:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001bda:	8526                	mv	a0,s1
    80001bdc:	8eeff0ef          	jal	80000cca <release>
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
    80001c20:	f7cff0ef          	jal	8000139c <uvmalloc>
    80001c24:	85aa                	mv	a1,a0
    80001c26:	f16d                	bnez	a0,80001c08 <growproc+0x1e>
      return -1;
    80001c28:	557d                	li	a0,-1
    80001c2a:	b7cd                	j	80001c0c <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c2c:	00b90633          	add	a2,s2,a1
    80001c30:	6928                	ld	a0,80(a0)
    80001c32:	f26ff0ef          	jal	80001358 <uvmdealloc>
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
    80001c62:	87bff0ef          	jal	800014dc <uvmcopy>
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
    80001cc2:	808ff0ef          	jal	80000cca <release>
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
    80001cd8:	548020ef          	jal	80004220 <filedup>
    80001cdc:	00a93023          	sd	a0,0(s2)
    80001ce0:	b7f5                	j	80001ccc <fork+0x92>
  np->cwd = idup(p->cwd);
    80001ce2:	150ab503          	ld	a0,336(s5)
    80001ce6:	079010ef          	jal	8000355e <idup>
    80001cea:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001cee:	4641                	li	a2,16
    80001cf0:	158a8593          	addi	a1,s5,344
    80001cf4:	158a0513          	addi	a0,s4,344
    80001cf8:	960ff0ef          	jal	80000e58 <safestrcpy>
  pid = np->pid;
    80001cfc:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001d00:	8552                	mv	a0,s4
    80001d02:	fc9fe0ef          	jal	80000cca <release>
  acquire(&wait_lock);
    80001d06:	00011497          	auipc	s1,0x11
    80001d0a:	ae248493          	addi	s1,s1,-1310 # 800127e8 <wait_lock>
    80001d0e:	8526                	mv	a0,s1
    80001d10:	f27fe0ef          	jal	80000c36 <acquire>
  np->parent = p;
    80001d14:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001d18:	8526                	mv	a0,s1
    80001d1a:	fb1fe0ef          	jal	80000cca <release>
  acquire(&np->lock);
    80001d1e:	8552                	mv	a0,s4
    80001d20:	f17fe0ef          	jal	80000c36 <acquire>
  np->state = RUNNABLE;
    80001d24:	478d                	li	a5,3
    80001d26:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001d2a:	8552                	mv	a0,s4
    80001d2c:	f9ffe0ef          	jal	80000cca <release>
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
    80001d6c:	a6870713          	addi	a4,a4,-1432 # 800127d0 <pid_lock>
    80001d70:	975a                	add	a4,a4,s6
    80001d72:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001d76:	00011717          	auipc	a4,0x11
    80001d7a:	a9270713          	addi	a4,a4,-1390 # 80012808 <cpus+0x8>
    80001d7e:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001d80:	4c11                	li	s8,4
        c->proc = p;
    80001d82:	079e                	slli	a5,a5,0x7
    80001d84:	00011a17          	auipc	s4,0x11
    80001d88:	a4ca0a13          	addi	s4,s4,-1460 # 800127d0 <pid_lock>
    80001d8c:	9a3e                	add	s4,s4,a5
        found = 1;
    80001d8e:	4b85                	li	s7,1
    80001d90:	a0a9                	j	80001dda <scheduler+0x92>
      release(&p->lock);
    80001d92:	8526                	mv	a0,s1
    80001d94:	f37fe0ef          	jal	80000cca <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d98:	16848493          	addi	s1,s1,360
    80001d9c:	03248563          	beq	s1,s2,80001dc6 <scheduler+0x7e>
      acquire(&p->lock);
    80001da0:	8526                	mv	a0,s1
    80001da2:	e95fe0ef          	jal	80000c36 <acquire>
      if(p->state == RUNNABLE) {
    80001da6:	4c9c                	lw	a5,24(s1)
    80001da8:	ff3795e3          	bne	a5,s3,80001d92 <scheduler+0x4a>
        p->state = RUNNING;
    80001dac:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001db0:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001db4:	06048593          	addi	a1,s1,96
    80001db8:	855a                	mv	a0,s6
    80001dba:	7be000ef          	jal	80002578 <swtch>
        c->proc = 0;
    80001dbe:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001dc2:	8ade                	mv	s5,s7
    80001dc4:	b7f9                	j	80001d92 <scheduler+0x4a>
    if(found == 0) {
    80001dc6:	000a9a63          	bnez	s5,80001dda <scheduler+0x92>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dca:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001dce:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001dd2:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001dd6:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dda:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001dde:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001de2:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001de6:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001de8:	00011497          	auipc	s1,0x11
    80001dec:	e1848493          	addi	s1,s1,-488 # 80012c00 <proc>
      if(p->state == RUNNABLE) {
    80001df0:	498d                	li	s3,3
    for(p = proc; p < &proc[NPROC]; p++) {
    80001df2:	00017917          	auipc	s2,0x17
    80001df6:	80e90913          	addi	s2,s2,-2034 # 80018600 <tickslock>
    80001dfa:	b75d                	j	80001da0 <scheduler+0x58>

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
    80001e10:	dbdfe0ef          	jal	80000bcc <holding>
    80001e14:	c92d                	beqz	a0,80001e86 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e16:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001e18:	2781                	sext.w	a5,a5
    80001e1a:	079e                	slli	a5,a5,0x7
    80001e1c:	00011717          	auipc	a4,0x11
    80001e20:	9b470713          	addi	a4,a4,-1612 # 800127d0 <pid_lock>
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
    80001e42:	00011917          	auipc	s2,0x11
    80001e46:	98e90913          	addi	s2,s2,-1650 # 800127d0 <pid_lock>
    80001e4a:	2781                	sext.w	a5,a5
    80001e4c:	079e                	slli	a5,a5,0x7
    80001e4e:	97ca                	add	a5,a5,s2
    80001e50:	0ac7a983          	lw	s3,172(a5)
    80001e54:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e56:	2781                	sext.w	a5,a5
    80001e58:	079e                	slli	a5,a5,0x7
    80001e5a:	00011597          	auipc	a1,0x11
    80001e5e:	9ae58593          	addi	a1,a1,-1618 # 80012808 <cpus+0x8>
    80001e62:	95be                	add	a1,a1,a5
    80001e64:	06048513          	addi	a0,s1,96
    80001e68:	710000ef          	jal	80002578 <swtch>
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
    80001e8e:	949fe0ef          	jal	800007d6 <panic>
    panic("sched locks");
    80001e92:	00005517          	auipc	a0,0x5
    80001e96:	3b650513          	addi	a0,a0,950 # 80007248 <etext+0x248>
    80001e9a:	93dfe0ef          	jal	800007d6 <panic>
    panic("sched running");
    80001e9e:	00005517          	auipc	a0,0x5
    80001ea2:	3ba50513          	addi	a0,a0,954 # 80007258 <etext+0x258>
    80001ea6:	931fe0ef          	jal	800007d6 <panic>
    panic("sched interruptible");
    80001eaa:	00005517          	auipc	a0,0x5
    80001eae:	3be50513          	addi	a0,a0,958 # 80007268 <etext+0x268>
    80001eb2:	925fe0ef          	jal	800007d6 <panic>

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
    80001ec6:	d71fe0ef          	jal	80000c36 <acquire>
  p->state = RUNNABLE;
    80001eca:	478d                	li	a5,3
    80001ecc:	cc9c                	sw	a5,24(s1)
  sched();
    80001ece:	f2fff0ef          	jal	80001dfc <sched>
  release(&p->lock);
    80001ed2:	8526                	mv	a0,s1
    80001ed4:	df7fe0ef          	jal	80000cca <release>
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
    80001efa:	d3dfe0ef          	jal	80000c36 <acquire>
  release(lk);
    80001efe:	854a                	mv	a0,s2
    80001f00:	dcbfe0ef          	jal	80000cca <release>

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
    80001f16:	db5fe0ef          	jal	80000cca <release>
  acquire(lk);
    80001f1a:	854a                	mv	a0,s2
    80001f1c:	d1bfe0ef          	jal	80000c36 <acquire>
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
    80001f46:	cbe48493          	addi	s1,s1,-834 # 80012c00 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001f4a:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f4c:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f4e:	00016917          	auipc	s2,0x16
    80001f52:	6b290913          	addi	s2,s2,1714 # 80018600 <tickslock>
    80001f56:	a801                	j	80001f66 <wakeup+0x38>
      }
      release(&p->lock);
    80001f58:	8526                	mv	a0,s1
    80001f5a:	d71fe0ef          	jal	80000cca <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f5e:	16848493          	addi	s1,s1,360
    80001f62:	03248263          	beq	s1,s2,80001f86 <wakeup+0x58>
    if(p != myproc()){
    80001f66:	9afff0ef          	jal	80001914 <myproc>
    80001f6a:	fea48ae3          	beq	s1,a0,80001f5e <wakeup+0x30>
      acquire(&p->lock);
    80001f6e:	8526                	mv	a0,s1
    80001f70:	cc7fe0ef          	jal	80000c36 <acquire>
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
    80001fae:	c5648493          	addi	s1,s1,-938 # 80012c00 <proc>
      pp->parent = initproc;
    80001fb2:	00008a17          	auipc	s4,0x8
    80001fb6:	6e6a0a13          	addi	s4,s4,1766 # 8000a698 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001fba:	00016997          	auipc	s3,0x16
    80001fbe:	64698993          	addi	s3,s3,1606 # 80018600 <tickslock>
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
    8000200a:	6927b783          	ld	a5,1682(a5) # 8000a698 <initproc>
    8000200e:	0d050493          	addi	s1,a0,208
    80002012:	15050913          	addi	s2,a0,336
    80002016:	00a79b63          	bne	a5,a0,8000202c <exit+0x3e>
    panic("init exiting");
    8000201a:	00005517          	auipc	a0,0x5
    8000201e:	26650513          	addi	a0,a0,614 # 80007280 <etext+0x280>
    80002022:	fb4fe0ef          	jal	800007d6 <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    80002026:	04a1                	addi	s1,s1,8
    80002028:	01248963          	beq	s1,s2,8000203a <exit+0x4c>
    if(p->ofile[fd]){
    8000202c:	6088                	ld	a0,0(s1)
    8000202e:	dd65                	beqz	a0,80002026 <exit+0x38>
      fileclose(f);
    80002030:	236020ef          	jal	80004266 <fileclose>
      p->ofile[fd] = 0;
    80002034:	0004b023          	sd	zero,0(s1)
    80002038:	b7fd                	j	80002026 <exit+0x38>
  begin_op();
    8000203a:	60d010ef          	jal	80003e46 <begin_op>
  iput(p->cwd);
    8000203e:	1509b503          	ld	a0,336(s3)
    80002042:	6d4010ef          	jal	80003716 <iput>
  end_op();
    80002046:	66b010ef          	jal	80003eb0 <end_op>
  p->cwd = 0;
    8000204a:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000204e:	00010497          	auipc	s1,0x10
    80002052:	79a48493          	addi	s1,s1,1946 # 800127e8 <wait_lock>
    80002056:	8526                	mv	a0,s1
    80002058:	bdffe0ef          	jal	80000c36 <acquire>
  reparent(p);
    8000205c:	854e                	mv	a0,s3
    8000205e:	f3bff0ef          	jal	80001f98 <reparent>
  wakeup(p->parent);
    80002062:	0389b503          	ld	a0,56(s3)
    80002066:	ec9ff0ef          	jal	80001f2e <wakeup>
  acquire(&p->lock);
    8000206a:	854e                	mv	a0,s3
    8000206c:	bcbfe0ef          	jal	80000c36 <acquire>
  p->xstate = status;
    80002070:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002074:	4795                	li	a5,5
    80002076:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000207a:	8526                	mv	a0,s1
    8000207c:	c4ffe0ef          	jal	80000cca <release>
  sched();
    80002080:	d7dff0ef          	jal	80001dfc <sched>
  panic("zombie exit");
    80002084:	00005517          	auipc	a0,0x5
    80002088:	20c50513          	addi	a0,a0,524 # 80007290 <etext+0x290>
    8000208c:	f4afe0ef          	jal	800007d6 <panic>

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
    800020a4:	b6048493          	addi	s1,s1,-1184 # 80012c00 <proc>
    800020a8:	00016997          	auipc	s3,0x16
    800020ac:	55898993          	addi	s3,s3,1368 # 80018600 <tickslock>
    acquire(&p->lock);
    800020b0:	8526                	mv	a0,s1
    800020b2:	b85fe0ef          	jal	80000c36 <acquire>
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
    800020be:	c0dfe0ef          	jal	80000cca <release>
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
    800020dc:	beffe0ef          	jal	80000cca <release>
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
    80002102:	b35fe0ef          	jal	80000c36 <acquire>
  p->killed = 1;
    80002106:	4785                	li	a5,1
    80002108:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000210a:	8526                	mv	a0,s1
    8000210c:	bbffe0ef          	jal	80000cca <release>
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
    80002128:	b0ffe0ef          	jal	80000c36 <acquire>
  k = p->killed;
    8000212c:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002130:	8526                	mv	a0,s1
    80002132:	b99fe0ef          	jal	80000cca <release>
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
    80002158:	0880                	addi	s0,sp,80
    8000215a:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000215c:	fb8ff0ef          	jal	80001914 <myproc>
    80002160:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002162:	00010517          	auipc	a0,0x10
    80002166:	68650513          	addi	a0,a0,1670 # 800127e8 <wait_lock>
    8000216a:	acdfe0ef          	jal	80000c36 <acquire>
        if(pp->state == ZOMBIE){
    8000216e:	4a15                	li	s4,5
        havekids = 1;
    80002170:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002172:	00016997          	auipc	s3,0x16
    80002176:	48e98993          	addi	s3,s3,1166 # 80018600 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000217a:	00010b97          	auipc	s7,0x10
    8000217e:	66eb8b93          	addi	s7,s7,1646 # 800127e8 <wait_lock>
    80002182:	a869                	j	8000221c <wait+0xd8>
          pid = pp->pid;
    80002184:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002188:	000b0c63          	beqz	s6,800021a0 <wait+0x5c>
    8000218c:	4691                	li	a3,4
    8000218e:	02c48613          	addi	a2,s1,44
    80002192:	85da                	mv	a1,s6
    80002194:	05093503          	ld	a0,80(s2)
    80002198:	c24ff0ef          	jal	800015bc <copyout>
    8000219c:	02054a63          	bltz	a0,800021d0 <wait+0x8c>
          freeproc(pp);
    800021a0:	8526                	mv	a0,s1
    800021a2:	8e5ff0ef          	jal	80001a86 <freeproc>
          release(&pp->lock);
    800021a6:	8526                	mv	a0,s1
    800021a8:	b23fe0ef          	jal	80000cca <release>
          release(&wait_lock);
    800021ac:	00010517          	auipc	a0,0x10
    800021b0:	63c50513          	addi	a0,a0,1596 # 800127e8 <wait_lock>
    800021b4:	b17fe0ef          	jal	80000cca <release>
}
    800021b8:	854e                	mv	a0,s3
    800021ba:	60a6                	ld	ra,72(sp)
    800021bc:	6406                	ld	s0,64(sp)
    800021be:	74e2                	ld	s1,56(sp)
    800021c0:	7942                	ld	s2,48(sp)
    800021c2:	79a2                	ld	s3,40(sp)
    800021c4:	7a02                	ld	s4,32(sp)
    800021c6:	6ae2                	ld	s5,24(sp)
    800021c8:	6b42                	ld	s6,16(sp)
    800021ca:	6ba2                	ld	s7,8(sp)
    800021cc:	6161                	addi	sp,sp,80
    800021ce:	8082                	ret
            release(&pp->lock);
    800021d0:	8526                	mv	a0,s1
    800021d2:	af9fe0ef          	jal	80000cca <release>
            release(&wait_lock);
    800021d6:	00010517          	auipc	a0,0x10
    800021da:	61250513          	addi	a0,a0,1554 # 800127e8 <wait_lock>
    800021de:	aedfe0ef          	jal	80000cca <release>
            return -1;
    800021e2:	59fd                	li	s3,-1
    800021e4:	bfd1                	j	800021b8 <wait+0x74>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021e6:	16848493          	addi	s1,s1,360
    800021ea:	03348063          	beq	s1,s3,8000220a <wait+0xc6>
      if(pp->parent == p){
    800021ee:	7c9c                	ld	a5,56(s1)
    800021f0:	ff279be3          	bne	a5,s2,800021e6 <wait+0xa2>
        acquire(&pp->lock);
    800021f4:	8526                	mv	a0,s1
    800021f6:	a41fe0ef          	jal	80000c36 <acquire>
        if(pp->state == ZOMBIE){
    800021fa:	4c9c                	lw	a5,24(s1)
    800021fc:	f94784e3          	beq	a5,s4,80002184 <wait+0x40>
        release(&pp->lock);
    80002200:	8526                	mv	a0,s1
    80002202:	ac9fe0ef          	jal	80000cca <release>
        havekids = 1;
    80002206:	8756                	mv	a4,s5
    80002208:	bff9                	j	800021e6 <wait+0xa2>
    if(!havekids || killed(p)){
    8000220a:	cf19                	beqz	a4,80002228 <wait+0xe4>
    8000220c:	854a                	mv	a0,s2
    8000220e:	f0dff0ef          	jal	8000211a <killed>
    80002212:	e919                	bnez	a0,80002228 <wait+0xe4>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002214:	85de                	mv	a1,s7
    80002216:	854a                	mv	a0,s2
    80002218:	ccbff0ef          	jal	80001ee2 <sleep>
    havekids = 0;
    8000221c:	4701                	li	a4,0
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000221e:	00011497          	auipc	s1,0x11
    80002222:	9e248493          	addi	s1,s1,-1566 # 80012c00 <proc>
    80002226:	b7e1                	j	800021ee <wait+0xaa>
      release(&wait_lock);
    80002228:	00010517          	auipc	a0,0x10
    8000222c:	5c050513          	addi	a0,a0,1472 # 800127e8 <wait_lock>
    80002230:	a9bfe0ef          	jal	80000cca <release>
      return -1;
    80002234:	59fd                	li	s3,-1
    80002236:	b749                	j	800021b8 <wait+0x74>

0000000080002238 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002238:	7179                	addi	sp,sp,-48
    8000223a:	f406                	sd	ra,40(sp)
    8000223c:	f022                	sd	s0,32(sp)
    8000223e:	ec26                	sd	s1,24(sp)
    80002240:	e84a                	sd	s2,16(sp)
    80002242:	e44e                	sd	s3,8(sp)
    80002244:	e052                	sd	s4,0(sp)
    80002246:	1800                	addi	s0,sp,48
    80002248:	84aa                	mv	s1,a0
    8000224a:	892e                	mv	s2,a1
    8000224c:	89b2                	mv	s3,a2
    8000224e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002250:	ec4ff0ef          	jal	80001914 <myproc>
  if(user_dst){
    80002254:	cc99                	beqz	s1,80002272 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002256:	86d2                	mv	a3,s4
    80002258:	864e                	mv	a2,s3
    8000225a:	85ca                	mv	a1,s2
    8000225c:	6928                	ld	a0,80(a0)
    8000225e:	b5eff0ef          	jal	800015bc <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002262:	70a2                	ld	ra,40(sp)
    80002264:	7402                	ld	s0,32(sp)
    80002266:	64e2                	ld	s1,24(sp)
    80002268:	6942                	ld	s2,16(sp)
    8000226a:	69a2                	ld	s3,8(sp)
    8000226c:	6a02                	ld	s4,0(sp)
    8000226e:	6145                	addi	sp,sp,48
    80002270:	8082                	ret
    memmove((char *)dst, src, len);
    80002272:	000a061b          	sext.w	a2,s4
    80002276:	85ce                	mv	a1,s3
    80002278:	854a                	mv	a0,s2
    8000227a:	af1fe0ef          	jal	80000d6a <memmove>
    return 0;
    8000227e:	8526                	mv	a0,s1
    80002280:	b7cd                	j	80002262 <either_copyout+0x2a>

0000000080002282 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002282:	7179                	addi	sp,sp,-48
    80002284:	f406                	sd	ra,40(sp)
    80002286:	f022                	sd	s0,32(sp)
    80002288:	ec26                	sd	s1,24(sp)
    8000228a:	e84a                	sd	s2,16(sp)
    8000228c:	e44e                	sd	s3,8(sp)
    8000228e:	e052                	sd	s4,0(sp)
    80002290:	1800                	addi	s0,sp,48
    80002292:	892a                	mv	s2,a0
    80002294:	84ae                	mv	s1,a1
    80002296:	89b2                	mv	s3,a2
    80002298:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000229a:	e7aff0ef          	jal	80001914 <myproc>
  if(user_src){
    8000229e:	cc99                	beqz	s1,800022bc <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800022a0:	86d2                	mv	a3,s4
    800022a2:	864e                	mv	a2,s3
    800022a4:	85ca                	mv	a1,s2
    800022a6:	6928                	ld	a0,80(a0)
    800022a8:	bc4ff0ef          	jal	8000166c <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800022ac:	70a2                	ld	ra,40(sp)
    800022ae:	7402                	ld	s0,32(sp)
    800022b0:	64e2                	ld	s1,24(sp)
    800022b2:	6942                	ld	s2,16(sp)
    800022b4:	69a2                	ld	s3,8(sp)
    800022b6:	6a02                	ld	s4,0(sp)
    800022b8:	6145                	addi	sp,sp,48
    800022ba:	8082                	ret
    memmove(dst, (char*)src, len);
    800022bc:	000a061b          	sext.w	a2,s4
    800022c0:	85ce                	mv	a1,s3
    800022c2:	854a                	mv	a0,s2
    800022c4:	aa7fe0ef          	jal	80000d6a <memmove>
    return 0;
    800022c8:	8526                	mv	a0,s1
    800022ca:	b7cd                	j	800022ac <either_copyin+0x2a>

00000000800022cc <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800022cc:	715d                	addi	sp,sp,-80
    800022ce:	e486                	sd	ra,72(sp)
    800022d0:	e0a2                	sd	s0,64(sp)
    800022d2:	fc26                	sd	s1,56(sp)
    800022d4:	f84a                	sd	s2,48(sp)
    800022d6:	f44e                	sd	s3,40(sp)
    800022d8:	f052                	sd	s4,32(sp)
    800022da:	ec56                	sd	s5,24(sp)
    800022dc:	e85a                	sd	s6,16(sp)
    800022de:	e45e                	sd	s7,8(sp)
    800022e0:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800022e2:	00005517          	auipc	a0,0x5
    800022e6:	d9650513          	addi	a0,a0,-618 # 80007078 <etext+0x78>
    800022ea:	a1cfe0ef          	jal	80000506 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800022ee:	00011497          	auipc	s1,0x11
    800022f2:	a6a48493          	addi	s1,s1,-1430 # 80012d58 <proc+0x158>
    800022f6:	00016917          	auipc	s2,0x16
    800022fa:	46290913          	addi	s2,s2,1122 # 80018758 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022fe:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002300:	00005997          	auipc	s3,0x5
    80002304:	fa098993          	addi	s3,s3,-96 # 800072a0 <etext+0x2a0>
    printf("%d %s %s", p->pid, state, p->name);
    80002308:	00005a97          	auipc	s5,0x5
    8000230c:	fa0a8a93          	addi	s5,s5,-96 # 800072a8 <etext+0x2a8>
    printf("\n");
    80002310:	00005a17          	auipc	s4,0x5
    80002314:	d68a0a13          	addi	s4,s4,-664 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002318:	00005b97          	auipc	s7,0x5
    8000231c:	470b8b93          	addi	s7,s7,1136 # 80007788 <states.0>
    80002320:	a829                	j	8000233a <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002322:	ed86a583          	lw	a1,-296(a3)
    80002326:	8556                	mv	a0,s5
    80002328:	9defe0ef          	jal	80000506 <printf>
    printf("\n");
    8000232c:	8552                	mv	a0,s4
    8000232e:	9d8fe0ef          	jal	80000506 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002332:	16848493          	addi	s1,s1,360
    80002336:	03248263          	beq	s1,s2,8000235a <procdump+0x8e>
    if(p->state == UNUSED)
    8000233a:	86a6                	mv	a3,s1
    8000233c:	ec04a783          	lw	a5,-320(s1)
    80002340:	dbed                	beqz	a5,80002332 <procdump+0x66>
      state = "???";
    80002342:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002344:	fcfb6fe3          	bltu	s6,a5,80002322 <procdump+0x56>
    80002348:	02079713          	slli	a4,a5,0x20
    8000234c:	01d75793          	srli	a5,a4,0x1d
    80002350:	97de                	add	a5,a5,s7
    80002352:	6390                	ld	a2,0(a5)
    80002354:	f679                	bnez	a2,80002322 <procdump+0x56>
      state = "???";
    80002356:	864e                	mv	a2,s3
    80002358:	b7e9                	j	80002322 <procdump+0x56>
  }
}
    8000235a:	60a6                	ld	ra,72(sp)
    8000235c:	6406                	ld	s0,64(sp)
    8000235e:	74e2                	ld	s1,56(sp)
    80002360:	7942                	ld	s2,48(sp)
    80002362:	79a2                	ld	s3,40(sp)
    80002364:	7a02                	ld	s4,32(sp)
    80002366:	6ae2                	ld	s5,24(sp)
    80002368:	6b42                	ld	s6,16(sp)
    8000236a:	6ba2                	ld	s7,8(sp)
    8000236c:	6161                	addi	sp,sp,80
    8000236e:	8082                	ret

0000000080002370 <waitpid>:



int waitpid(int pid, uint64 addr) {
    80002370:	715d                	addi	sp,sp,-80
    80002372:	e486                	sd	ra,72(sp)
    80002374:	e0a2                	sd	s0,64(sp)
    80002376:	fc26                	sd	s1,56(sp)
    80002378:	f84a                	sd	s2,48(sp)
    8000237a:	f44e                	sd	s3,40(sp)
    8000237c:	f052                	sd	s4,32(sp)
    8000237e:	ec56                	sd	s5,24(sp)
    80002380:	e85a                	sd	s6,16(sp)
    80002382:	e45e                	sd	s7,8(sp)
    80002384:	e062                	sd	s8,0(sp)
    80002386:	0880                	addi	s0,sp,80
    80002388:	892a                	mv	s2,a0
    8000238a:	8bae                	mv	s7,a1
  struct proc *pp;
  int havekids;
  struct proc *p = myproc();
    8000238c:	d88ff0ef          	jal	80001914 <myproc>
    80002390:	8b2a                	mv	s6,a0

  acquire(&wait_lock);
    80002392:	00010517          	auipc	a0,0x10
    80002396:	45650513          	addi	a0,a0,1110 # 800127e8 <wait_lock>
    8000239a:	89dfe0ef          	jal	80000c36 <acquire>
      if(pp->pid == pid){
        // make sure the child isn't still in exit() or swtch().
        acquire(&pp->lock);

        havekids = 1;
        if(pp->state == ZOMBIE){
    8000239e:	4a15                	li	s4,5
        havekids = 1;
    800023a0:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023a2:	00016997          	auipc	s3,0x16
    800023a6:	25e98993          	addi	s3,s3,606 # 80018600 <tickslock>
      release(&wait_lock);
      return -1;
    }
    
    // Wait for a child to exit.
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800023aa:	00010c17          	auipc	s8,0x10
    800023ae:	43ec0c13          	addi	s8,s8,1086 # 800127e8 <wait_lock>
    800023b2:	a871                	j	8000244e <waitpid+0xde>
          pid = pp->pid;
    800023b4:	0304a903          	lw	s2,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800023b8:	000b8c63          	beqz	s7,800023d0 <waitpid+0x60>
    800023bc:	4691                	li	a3,4
    800023be:	02c48613          	addi	a2,s1,44
    800023c2:	85de                	mv	a1,s7
    800023c4:	050b3503          	ld	a0,80(s6)
    800023c8:	9f4ff0ef          	jal	800015bc <copyout>
    800023cc:	02054b63          	bltz	a0,80002402 <waitpid+0x92>
          freeproc(pp);
    800023d0:	8526                	mv	a0,s1
    800023d2:	eb4ff0ef          	jal	80001a86 <freeproc>
          release(&pp->lock);
    800023d6:	8526                	mv	a0,s1
    800023d8:	8f3fe0ef          	jal	80000cca <release>
          release(&wait_lock);
    800023dc:	00010517          	auipc	a0,0x10
    800023e0:	40c50513          	addi	a0,a0,1036 # 800127e8 <wait_lock>
    800023e4:	8e7fe0ef          	jal	80000cca <release>

  
  }
}
    800023e8:	854a                	mv	a0,s2
    800023ea:	60a6                	ld	ra,72(sp)
    800023ec:	6406                	ld	s0,64(sp)
    800023ee:	74e2                	ld	s1,56(sp)
    800023f0:	7942                	ld	s2,48(sp)
    800023f2:	79a2                	ld	s3,40(sp)
    800023f4:	7a02                	ld	s4,32(sp)
    800023f6:	6ae2                	ld	s5,24(sp)
    800023f8:	6b42                	ld	s6,16(sp)
    800023fa:	6ba2                	ld	s7,8(sp)
    800023fc:	6c02                	ld	s8,0(sp)
    800023fe:	6161                	addi	sp,sp,80
    80002400:	8082                	ret
            release(&pp->lock);
    80002402:	8526                	mv	a0,s1
    80002404:	8c7fe0ef          	jal	80000cca <release>
            release(&wait_lock);
    80002408:	00010517          	auipc	a0,0x10
    8000240c:	3e050513          	addi	a0,a0,992 # 800127e8 <wait_lock>
    80002410:	8bbfe0ef          	jal	80000cca <release>
            return -1;
    80002414:	597d                	li	s2,-1
    80002416:	bfc9                	j	800023e8 <waitpid+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002418:	16848493          	addi	s1,s1,360
    8000241c:	03348063          	beq	s1,s3,8000243c <waitpid+0xcc>
      if(pp->pid == pid){
    80002420:	589c                	lw	a5,48(s1)
    80002422:	ff279be3          	bne	a5,s2,80002418 <waitpid+0xa8>
        acquire(&pp->lock);
    80002426:	8526                	mv	a0,s1
    80002428:	80ffe0ef          	jal	80000c36 <acquire>
        if(pp->state == ZOMBIE){
    8000242c:	4c9c                	lw	a5,24(s1)
    8000242e:	f94783e3          	beq	a5,s4,800023b4 <waitpid+0x44>
        release(&pp->lock);
    80002432:	8526                	mv	a0,s1
    80002434:	897fe0ef          	jal	80000cca <release>
        havekids = 1;
    80002438:	8756                	mv	a4,s5
    8000243a:	bff9                	j	80002418 <waitpid+0xa8>
    if(!havekids || killed(p)){
    8000243c:	cf19                	beqz	a4,8000245a <waitpid+0xea>
    8000243e:	855a                	mv	a0,s6
    80002440:	cdbff0ef          	jal	8000211a <killed>
    80002444:	e919                	bnez	a0,8000245a <waitpid+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002446:	85e2                	mv	a1,s8
    80002448:	855a                	mv	a0,s6
    8000244a:	a99ff0ef          	jal	80001ee2 <sleep>
    havekids = 0;
    8000244e:	4701                	li	a4,0
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002450:	00010497          	auipc	s1,0x10
    80002454:	7b048493          	addi	s1,s1,1968 # 80012c00 <proc>
    80002458:	b7e1                	j	80002420 <waitpid+0xb0>
      release(&wait_lock);
    8000245a:	00010517          	auipc	a0,0x10
    8000245e:	38e50513          	addi	a0,a0,910 # 800127e8 <wait_lock>
    80002462:	869fe0ef          	jal	80000cca <release>
      return -1;
    80002466:	597d                	li	s2,-1
    80002468:	b741                	j	800023e8 <waitpid+0x78>

000000008000246a <find_proc>:

struct proc* find_proc(int pid) {
    8000246a:	7179                	addi	sp,sp,-48
    8000246c:	f406                	sd	ra,40(sp)
    8000246e:	f022                	sd	s0,32(sp)
    80002470:	ec26                	sd	s1,24(sp)
    80002472:	e84a                	sd	s2,16(sp)
    80002474:	e44e                	sd	s3,8(sp)
    80002476:	1800                	addi	s0,sp,48
    80002478:	892a                	mv	s2,a0
    struct proc *p;
    for (p = proc; p < &proc[NPROC]; p++) {
    8000247a:	00010497          	auipc	s1,0x10
    8000247e:	78648493          	addi	s1,s1,1926 # 80012c00 <proc>
    80002482:	00016997          	auipc	s3,0x16
    80002486:	17e98993          	addi	s3,s3,382 # 80018600 <tickslock>
    8000248a:	a801                	j	8000249a <find_proc+0x30>
        acquire(&p->lock);  // Lock the process
        if (p->pid == pid && p->state != UNUSED) {
            return p;  // Return with lock held
        }
        release(&p->lock);  // Unlock if not the target process
    8000248c:	8526                	mv	a0,s1
    8000248e:	83dfe0ef          	jal	80000cca <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80002492:	16848493          	addi	s1,s1,360
    80002496:	03348263          	beq	s1,s3,800024ba <find_proc+0x50>
        acquire(&p->lock);  // Lock the process
    8000249a:	8526                	mv	a0,s1
    8000249c:	f9afe0ef          	jal	80000c36 <acquire>
        if (p->pid == pid && p->state != UNUSED) {
    800024a0:	589c                	lw	a5,48(s1)
    800024a2:	ff2795e3          	bne	a5,s2,8000248c <find_proc+0x22>
    800024a6:	4c9c                	lw	a5,24(s1)
    800024a8:	d3f5                	beqz	a5,8000248c <find_proc+0x22>
    }
    return 0;  // Process not found
}
    800024aa:	8526                	mv	a0,s1
    800024ac:	70a2                	ld	ra,40(sp)
    800024ae:	7402                	ld	s0,32(sp)
    800024b0:	64e2                	ld	s1,24(sp)
    800024b2:	6942                	ld	s2,16(sp)
    800024b4:	69a2                	ld	s3,8(sp)
    800024b6:	6145                	addi	sp,sp,48
    800024b8:	8082                	ret
    return 0;  // Process not found
    800024ba:	4481                	li	s1,0
    800024bc:	b7fd                	j	800024aa <find_proc+0x40>

00000000800024be <sigstop>:


int sigstop(int pid){
    800024be:	7179                	addi	sp,sp,-48
    800024c0:	f406                	sd	ra,40(sp)
    800024c2:	f022                	sd	s0,32(sp)
    800024c4:	ec26                	sd	s1,24(sp)
    800024c6:	e84a                	sd	s2,16(sp)
    800024c8:	e44e                	sd	s3,8(sp)
    800024ca:	1800                	addi	s0,sp,48
    800024cc:	892a                	mv	s2,a0
  struct proc *p;

    for(p = proc; p < &proc[NPROC]; p++){
    800024ce:	00010497          	auipc	s1,0x10
    800024d2:	73248493          	addi	s1,s1,1842 # 80012c00 <proc>
    800024d6:	00016997          	auipc	s3,0x16
    800024da:	12a98993          	addi	s3,s3,298 # 80018600 <tickslock>
        acquire(&p->lock);
    800024de:	8526                	mv	a0,s1
    800024e0:	f56fe0ef          	jal	80000c36 <acquire>
        if(p->pid == pid){
    800024e4:	589c                	lw	a5,48(s1)
    800024e6:	01278b63          	beq	a5,s2,800024fc <sigstop+0x3e>
            // Set process state to STOPPED or SLEEPING (suspend execution).
            p->state = SLEEPING;  // or STOPPED if you have a STOPPED state.
            release(&p->lock);
            return 0;
        }
        release(&p->lock);
    800024ea:	8526                	mv	a0,s1
    800024ec:	fdefe0ef          	jal	80000cca <release>
    for(p = proc; p < &proc[NPROC]; p++){
    800024f0:	16848493          	addi	s1,s1,360
    800024f4:	ff3495e3          	bne	s1,s3,800024de <sigstop+0x20>
    }
    return -1;
    800024f8:	557d                	li	a0,-1
    800024fa:	a039                	j	80002508 <sigstop+0x4a>
            p->state = SLEEPING;  // or STOPPED if you have a STOPPED state.
    800024fc:	4789                	li	a5,2
    800024fe:	cc9c                	sw	a5,24(s1)
            release(&p->lock);
    80002500:	8526                	mv	a0,s1
    80002502:	fc8fe0ef          	jal	80000cca <release>
            return 0;
    80002506:	4501                	li	a0,0
}
    80002508:	70a2                	ld	ra,40(sp)
    8000250a:	7402                	ld	s0,32(sp)
    8000250c:	64e2                	ld	s1,24(sp)
    8000250e:	6942                	ld	s2,16(sp)
    80002510:	69a2                	ld	s3,8(sp)
    80002512:	6145                	addi	sp,sp,48
    80002514:	8082                	ret

0000000080002516 <sigcont>:

int sigcont(int pid){
    80002516:	7179                	addi	sp,sp,-48
    80002518:	f406                	sd	ra,40(sp)
    8000251a:	f022                	sd	s0,32(sp)
    8000251c:	ec26                	sd	s1,24(sp)
    8000251e:	e84a                	sd	s2,16(sp)
    80002520:	e44e                	sd	s3,8(sp)
    80002522:	1800                	addi	s0,sp,48
    80002524:	892a                	mv	s2,a0
  struct proc *p;

    for(p = proc; p < &proc[NPROC]; p++){
    80002526:	00010497          	auipc	s1,0x10
    8000252a:	6da48493          	addi	s1,s1,1754 # 80012c00 <proc>
    8000252e:	00016997          	auipc	s3,0x16
    80002532:	0d298993          	addi	s3,s3,210 # 80018600 <tickslock>
        acquire(&p->lock);
    80002536:	8526                	mv	a0,s1
    80002538:	efefe0ef          	jal	80000c36 <acquire>
        if(p->pid == pid){
    8000253c:	589c                	lw	a5,48(s1)
    8000253e:	01278b63          	beq	a5,s2,80002554 <sigcont+0x3e>
                p->state = RUNNABLE;
            }
            release(&p->lock);
            return 0;
        }
        release(&p->lock);
    80002542:	8526                	mv	a0,s1
    80002544:	f86fe0ef          	jal	80000cca <release>
    for(p = proc; p < &proc[NPROC]; p++){
    80002548:	16848493          	addi	s1,s1,360
    8000254c:	ff3495e3          	bne	s1,s3,80002536 <sigcont+0x20>
    }
    return -1;
    80002550:	557d                	li	a0,-1
    80002552:	a809                	j	80002564 <sigcont+0x4e>
            if(p->state == SLEEPING) 
    80002554:	4c98                	lw	a4,24(s1)
    80002556:	4789                	li	a5,2
    80002558:	00f70d63          	beq	a4,a5,80002572 <sigcont+0x5c>
            release(&p->lock);
    8000255c:	8526                	mv	a0,s1
    8000255e:	f6cfe0ef          	jal	80000cca <release>
            return 0;
    80002562:	4501                	li	a0,0
    80002564:	70a2                	ld	ra,40(sp)
    80002566:	7402                	ld	s0,32(sp)
    80002568:	64e2                	ld	s1,24(sp)
    8000256a:	6942                	ld	s2,16(sp)
    8000256c:	69a2                	ld	s3,8(sp)
    8000256e:	6145                	addi	sp,sp,48
    80002570:	8082                	ret
                p->state = RUNNABLE;
    80002572:	478d                	li	a5,3
    80002574:	cc9c                	sw	a5,24(s1)
    80002576:	b7dd                	j	8000255c <sigcont+0x46>

0000000080002578 <swtch>:
    80002578:	00153023          	sd	ra,0(a0)
    8000257c:	00253423          	sd	sp,8(a0)
    80002580:	e900                	sd	s0,16(a0)
    80002582:	ed04                	sd	s1,24(a0)
    80002584:	03253023          	sd	s2,32(a0)
    80002588:	03353423          	sd	s3,40(a0)
    8000258c:	03453823          	sd	s4,48(a0)
    80002590:	03553c23          	sd	s5,56(a0)
    80002594:	05653023          	sd	s6,64(a0)
    80002598:	05753423          	sd	s7,72(a0)
    8000259c:	05853823          	sd	s8,80(a0)
    800025a0:	05953c23          	sd	s9,88(a0)
    800025a4:	07a53023          	sd	s10,96(a0)
    800025a8:	07b53423          	sd	s11,104(a0)
    800025ac:	0005b083          	ld	ra,0(a1)
    800025b0:	0085b103          	ld	sp,8(a1)
    800025b4:	6980                	ld	s0,16(a1)
    800025b6:	6d84                	ld	s1,24(a1)
    800025b8:	0205b903          	ld	s2,32(a1)
    800025bc:	0285b983          	ld	s3,40(a1)
    800025c0:	0305ba03          	ld	s4,48(a1)
    800025c4:	0385ba83          	ld	s5,56(a1)
    800025c8:	0405bb03          	ld	s6,64(a1)
    800025cc:	0485bb83          	ld	s7,72(a1)
    800025d0:	0505bc03          	ld	s8,80(a1)
    800025d4:	0585bc83          	ld	s9,88(a1)
    800025d8:	0605bd03          	ld	s10,96(a1)
    800025dc:	0685bd83          	ld	s11,104(a1)
    800025e0:	8082                	ret

00000000800025e2 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800025e2:	1141                	addi	sp,sp,-16
    800025e4:	e406                	sd	ra,8(sp)
    800025e6:	e022                	sd	s0,0(sp)
    800025e8:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800025ea:	00005597          	auipc	a1,0x5
    800025ee:	cfe58593          	addi	a1,a1,-770 # 800072e8 <etext+0x2e8>
    800025f2:	00016517          	auipc	a0,0x16
    800025f6:	00e50513          	addi	a0,a0,14 # 80018600 <tickslock>
    800025fa:	db8fe0ef          	jal	80000bb2 <initlock>
}
    800025fe:	60a2                	ld	ra,8(sp)
    80002600:	6402                	ld	s0,0(sp)
    80002602:	0141                	addi	sp,sp,16
    80002604:	8082                	ret

0000000080002606 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002606:	1141                	addi	sp,sp,-16
    80002608:	e406                	sd	ra,8(sp)
    8000260a:	e022                	sd	s0,0(sp)
    8000260c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000260e:	00003797          	auipc	a5,0x3
    80002612:	3d278793          	addi	a5,a5,978 # 800059e0 <kernelvec>
    80002616:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000261a:	60a2                	ld	ra,8(sp)
    8000261c:	6402                	ld	s0,0(sp)
    8000261e:	0141                	addi	sp,sp,16
    80002620:	8082                	ret

0000000080002622 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002622:	1141                	addi	sp,sp,-16
    80002624:	e406                	sd	ra,8(sp)
    80002626:	e022                	sd	s0,0(sp)
    80002628:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000262a:	aeaff0ef          	jal	80001914 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000262e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002632:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002634:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002638:	00004697          	auipc	a3,0x4
    8000263c:	9c868693          	addi	a3,a3,-1592 # 80006000 <_trampoline>
    80002640:	00004717          	auipc	a4,0x4
    80002644:	9c070713          	addi	a4,a4,-1600 # 80006000 <_trampoline>
    80002648:	8f15                	sub	a4,a4,a3
    8000264a:	040007b7          	lui	a5,0x4000
    8000264e:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002650:	07b2                	slli	a5,a5,0xc
    80002652:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002654:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002658:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000265a:	18002673          	csrr	a2,satp
    8000265e:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002660:	6d30                	ld	a2,88(a0)
    80002662:	6138                	ld	a4,64(a0)
    80002664:	6585                	lui	a1,0x1
    80002666:	972e                	add	a4,a4,a1
    80002668:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000266a:	6d38                	ld	a4,88(a0)
    8000266c:	00000617          	auipc	a2,0x0
    80002670:	11060613          	addi	a2,a2,272 # 8000277c <usertrap>
    80002674:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002676:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002678:	8612                	mv	a2,tp
    8000267a:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000267c:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002680:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002684:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002688:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000268c:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000268e:	6f18                	ld	a4,24(a4)
    80002690:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002694:	6928                	ld	a0,80(a0)
    80002696:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002698:	00004717          	auipc	a4,0x4
    8000269c:	a0470713          	addi	a4,a4,-1532 # 8000609c <userret>
    800026a0:	8f15                	sub	a4,a4,a3
    800026a2:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800026a4:	577d                	li	a4,-1
    800026a6:	177e                	slli	a4,a4,0x3f
    800026a8:	8d59                	or	a0,a0,a4
    800026aa:	9782                	jalr	a5
}
    800026ac:	60a2                	ld	ra,8(sp)
    800026ae:	6402                	ld	s0,0(sp)
    800026b0:	0141                	addi	sp,sp,16
    800026b2:	8082                	ret

00000000800026b4 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800026b4:	1101                	addi	sp,sp,-32
    800026b6:	ec06                	sd	ra,24(sp)
    800026b8:	e822                	sd	s0,16(sp)
    800026ba:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    800026bc:	a24ff0ef          	jal	800018e0 <cpuid>
    800026c0:	cd11                	beqz	a0,800026dc <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    800026c2:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800026c6:	000f4737          	lui	a4,0xf4
    800026ca:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800026ce:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800026d0:	14d79073          	csrw	stimecmp,a5
}
    800026d4:	60e2                	ld	ra,24(sp)
    800026d6:	6442                	ld	s0,16(sp)
    800026d8:	6105                	addi	sp,sp,32
    800026da:	8082                	ret
    800026dc:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800026de:	00016497          	auipc	s1,0x16
    800026e2:	f2248493          	addi	s1,s1,-222 # 80018600 <tickslock>
    800026e6:	8526                	mv	a0,s1
    800026e8:	d4efe0ef          	jal	80000c36 <acquire>
    ticks++;
    800026ec:	00008517          	auipc	a0,0x8
    800026f0:	fb450513          	addi	a0,a0,-76 # 8000a6a0 <ticks>
    800026f4:	411c                	lw	a5,0(a0)
    800026f6:	2785                	addiw	a5,a5,1
    800026f8:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800026fa:	835ff0ef          	jal	80001f2e <wakeup>
    release(&tickslock);
    800026fe:	8526                	mv	a0,s1
    80002700:	dcafe0ef          	jal	80000cca <release>
    80002704:	64a2                	ld	s1,8(sp)
    80002706:	bf75                	j	800026c2 <clockintr+0xe>

0000000080002708 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002708:	1101                	addi	sp,sp,-32
    8000270a:	ec06                	sd	ra,24(sp)
    8000270c:	e822                	sd	s0,16(sp)
    8000270e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002710:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002714:	57fd                	li	a5,-1
    80002716:	17fe                	slli	a5,a5,0x3f
    80002718:	07a5                	addi	a5,a5,9
    8000271a:	00f70c63          	beq	a4,a5,80002732 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    8000271e:	57fd                	li	a5,-1
    80002720:	17fe                	slli	a5,a5,0x3f
    80002722:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002724:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002726:	04f70763          	beq	a4,a5,80002774 <devintr+0x6c>
  }
}
    8000272a:	60e2                	ld	ra,24(sp)
    8000272c:	6442                	ld	s0,16(sp)
    8000272e:	6105                	addi	sp,sp,32
    80002730:	8082                	ret
    80002732:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002734:	358030ef          	jal	80005a8c <plic_claim>
    80002738:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000273a:	47a9                	li	a5,10
    8000273c:	00f50963          	beq	a0,a5,8000274e <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002740:	4785                	li	a5,1
    80002742:	00f50963          	beq	a0,a5,80002754 <devintr+0x4c>
    return 1;
    80002746:	4505                	li	a0,1
    } else if(irq){
    80002748:	e889                	bnez	s1,8000275a <devintr+0x52>
    8000274a:	64a2                	ld	s1,8(sp)
    8000274c:	bff9                	j	8000272a <devintr+0x22>
      uartintr();
    8000274e:	af6fe0ef          	jal	80000a44 <uartintr>
    if(irq)
    80002752:	a819                	j	80002768 <devintr+0x60>
      virtio_disk_intr();
    80002754:	7c8030ef          	jal	80005f1c <virtio_disk_intr>
    if(irq)
    80002758:	a801                	j	80002768 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    8000275a:	85a6                	mv	a1,s1
    8000275c:	00005517          	auipc	a0,0x5
    80002760:	b9450513          	addi	a0,a0,-1132 # 800072f0 <etext+0x2f0>
    80002764:	da3fd0ef          	jal	80000506 <printf>
      plic_complete(irq);
    80002768:	8526                	mv	a0,s1
    8000276a:	342030ef          	jal	80005aac <plic_complete>
    return 1;
    8000276e:	4505                	li	a0,1
    80002770:	64a2                	ld	s1,8(sp)
    80002772:	bf65                	j	8000272a <devintr+0x22>
    clockintr();
    80002774:	f41ff0ef          	jal	800026b4 <clockintr>
    return 2;
    80002778:	4509                	li	a0,2
    8000277a:	bf45                	j	8000272a <devintr+0x22>

000000008000277c <usertrap>:
{
    8000277c:	1101                	addi	sp,sp,-32
    8000277e:	ec06                	sd	ra,24(sp)
    80002780:	e822                	sd	s0,16(sp)
    80002782:	e426                	sd	s1,8(sp)
    80002784:	e04a                	sd	s2,0(sp)
    80002786:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002788:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000278c:	1007f793          	andi	a5,a5,256
    80002790:	ef85                	bnez	a5,800027c8 <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002792:	00003797          	auipc	a5,0x3
    80002796:	24e78793          	addi	a5,a5,590 # 800059e0 <kernelvec>
    8000279a:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000279e:	976ff0ef          	jal	80001914 <myproc>
    800027a2:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800027a4:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800027a6:	14102773          	csrr	a4,sepc
    800027aa:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027ac:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800027b0:	47a1                	li	a5,8
    800027b2:	02f70163          	beq	a4,a5,800027d4 <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    800027b6:	f53ff0ef          	jal	80002708 <devintr>
    800027ba:	892a                	mv	s2,a0
    800027bc:	c135                	beqz	a0,80002820 <usertrap+0xa4>
  if(killed(p))
    800027be:	8526                	mv	a0,s1
    800027c0:	95bff0ef          	jal	8000211a <killed>
    800027c4:	cd1d                	beqz	a0,80002802 <usertrap+0x86>
    800027c6:	a81d                	j	800027fc <usertrap+0x80>
    panic("usertrap: not from user mode");
    800027c8:	00005517          	auipc	a0,0x5
    800027cc:	b4850513          	addi	a0,a0,-1208 # 80007310 <etext+0x310>
    800027d0:	806fe0ef          	jal	800007d6 <panic>
    if(killed(p))
    800027d4:	947ff0ef          	jal	8000211a <killed>
    800027d8:	e121                	bnez	a0,80002818 <usertrap+0x9c>
    p->trapframe->epc += 4;
    800027da:	6cb8                	ld	a4,88(s1)
    800027dc:	6f1c                	ld	a5,24(a4)
    800027de:	0791                	addi	a5,a5,4
    800027e0:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027e2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800027e6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027ea:	10079073          	csrw	sstatus,a5
    syscall();
    800027ee:	240000ef          	jal	80002a2e <syscall>
  if(killed(p))
    800027f2:	8526                	mv	a0,s1
    800027f4:	927ff0ef          	jal	8000211a <killed>
    800027f8:	c901                	beqz	a0,80002808 <usertrap+0x8c>
    800027fa:	4901                	li	s2,0
    exit(-1);
    800027fc:	557d                	li	a0,-1
    800027fe:	ff0ff0ef          	jal	80001fee <exit>
  if(which_dev == 2)
    80002802:	4789                	li	a5,2
    80002804:	04f90563          	beq	s2,a5,8000284e <usertrap+0xd2>
  usertrapret();
    80002808:	e1bff0ef          	jal	80002622 <usertrapret>
}
    8000280c:	60e2                	ld	ra,24(sp)
    8000280e:	6442                	ld	s0,16(sp)
    80002810:	64a2                	ld	s1,8(sp)
    80002812:	6902                	ld	s2,0(sp)
    80002814:	6105                	addi	sp,sp,32
    80002816:	8082                	ret
      exit(-1);
    80002818:	557d                	li	a0,-1
    8000281a:	fd4ff0ef          	jal	80001fee <exit>
    8000281e:	bf75                	j	800027da <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002820:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002824:	5890                	lw	a2,48(s1)
    80002826:	00005517          	auipc	a0,0x5
    8000282a:	b0a50513          	addi	a0,a0,-1270 # 80007330 <etext+0x330>
    8000282e:	cd9fd0ef          	jal	80000506 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002832:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002836:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    8000283a:	00005517          	auipc	a0,0x5
    8000283e:	b2650513          	addi	a0,a0,-1242 # 80007360 <etext+0x360>
    80002842:	cc5fd0ef          	jal	80000506 <printf>
    setkilled(p);
    80002846:	8526                	mv	a0,s1
    80002848:	8afff0ef          	jal	800020f6 <setkilled>
    8000284c:	b75d                	j	800027f2 <usertrap+0x76>
    yield();
    8000284e:	e68ff0ef          	jal	80001eb6 <yield>
    80002852:	bf5d                	j	80002808 <usertrap+0x8c>

0000000080002854 <kerneltrap>:
{
    80002854:	7179                	addi	sp,sp,-48
    80002856:	f406                	sd	ra,40(sp)
    80002858:	f022                	sd	s0,32(sp)
    8000285a:	ec26                	sd	s1,24(sp)
    8000285c:	e84a                	sd	s2,16(sp)
    8000285e:	e44e                	sd	s3,8(sp)
    80002860:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002862:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002866:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000286a:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000286e:	1004f793          	andi	a5,s1,256
    80002872:	c795                	beqz	a5,8000289e <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002874:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002878:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000287a:	eb85                	bnez	a5,800028aa <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    8000287c:	e8dff0ef          	jal	80002708 <devintr>
    80002880:	c91d                	beqz	a0,800028b6 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002882:	4789                	li	a5,2
    80002884:	04f50a63          	beq	a0,a5,800028d8 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002888:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000288c:	10049073          	csrw	sstatus,s1
}
    80002890:	70a2                	ld	ra,40(sp)
    80002892:	7402                	ld	s0,32(sp)
    80002894:	64e2                	ld	s1,24(sp)
    80002896:	6942                	ld	s2,16(sp)
    80002898:	69a2                	ld	s3,8(sp)
    8000289a:	6145                	addi	sp,sp,48
    8000289c:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000289e:	00005517          	auipc	a0,0x5
    800028a2:	aea50513          	addi	a0,a0,-1302 # 80007388 <etext+0x388>
    800028a6:	f31fd0ef          	jal	800007d6 <panic>
    panic("kerneltrap: interrupts enabled");
    800028aa:	00005517          	auipc	a0,0x5
    800028ae:	b0650513          	addi	a0,a0,-1274 # 800073b0 <etext+0x3b0>
    800028b2:	f25fd0ef          	jal	800007d6 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028b6:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028ba:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    800028be:	85ce                	mv	a1,s3
    800028c0:	00005517          	auipc	a0,0x5
    800028c4:	b1050513          	addi	a0,a0,-1264 # 800073d0 <etext+0x3d0>
    800028c8:	c3ffd0ef          	jal	80000506 <printf>
    panic("kerneltrap");
    800028cc:	00005517          	auipc	a0,0x5
    800028d0:	b2c50513          	addi	a0,a0,-1236 # 800073f8 <etext+0x3f8>
    800028d4:	f03fd0ef          	jal	800007d6 <panic>
  if(which_dev == 2 && myproc() != 0)
    800028d8:	83cff0ef          	jal	80001914 <myproc>
    800028dc:	d555                	beqz	a0,80002888 <kerneltrap+0x34>
    yield();
    800028de:	dd8ff0ef          	jal	80001eb6 <yield>
    800028e2:	b75d                	j	80002888 <kerneltrap+0x34>

00000000800028e4 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800028e4:	1101                	addi	sp,sp,-32
    800028e6:	ec06                	sd	ra,24(sp)
    800028e8:	e822                	sd	s0,16(sp)
    800028ea:	e426                	sd	s1,8(sp)
    800028ec:	1000                	addi	s0,sp,32
    800028ee:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800028f0:	824ff0ef          	jal	80001914 <myproc>
  switch (n) {
    800028f4:	4795                	li	a5,5
    800028f6:	0497e163          	bltu	a5,s1,80002938 <argraw+0x54>
    800028fa:	048a                	slli	s1,s1,0x2
    800028fc:	00005717          	auipc	a4,0x5
    80002900:	ebc70713          	addi	a4,a4,-324 # 800077b8 <states.0+0x30>
    80002904:	94ba                	add	s1,s1,a4
    80002906:	409c                	lw	a5,0(s1)
    80002908:	97ba                	add	a5,a5,a4
    8000290a:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000290c:	6d3c                	ld	a5,88(a0)
    8000290e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002910:	60e2                	ld	ra,24(sp)
    80002912:	6442                	ld	s0,16(sp)
    80002914:	64a2                	ld	s1,8(sp)
    80002916:	6105                	addi	sp,sp,32
    80002918:	8082                	ret
    return p->trapframe->a1;
    8000291a:	6d3c                	ld	a5,88(a0)
    8000291c:	7fa8                	ld	a0,120(a5)
    8000291e:	bfcd                	j	80002910 <argraw+0x2c>
    return p->trapframe->a2;
    80002920:	6d3c                	ld	a5,88(a0)
    80002922:	63c8                	ld	a0,128(a5)
    80002924:	b7f5                	j	80002910 <argraw+0x2c>
    return p->trapframe->a3;
    80002926:	6d3c                	ld	a5,88(a0)
    80002928:	67c8                	ld	a0,136(a5)
    8000292a:	b7dd                	j	80002910 <argraw+0x2c>
    return p->trapframe->a4;
    8000292c:	6d3c                	ld	a5,88(a0)
    8000292e:	6bc8                	ld	a0,144(a5)
    80002930:	b7c5                	j	80002910 <argraw+0x2c>
    return p->trapframe->a5;
    80002932:	6d3c                	ld	a5,88(a0)
    80002934:	6fc8                	ld	a0,152(a5)
    80002936:	bfe9                	j	80002910 <argraw+0x2c>
  panic("argraw");
    80002938:	00005517          	auipc	a0,0x5
    8000293c:	ad050513          	addi	a0,a0,-1328 # 80007408 <etext+0x408>
    80002940:	e97fd0ef          	jal	800007d6 <panic>

0000000080002944 <fetchaddr>:
{
    80002944:	1101                	addi	sp,sp,-32
    80002946:	ec06                	sd	ra,24(sp)
    80002948:	e822                	sd	s0,16(sp)
    8000294a:	e426                	sd	s1,8(sp)
    8000294c:	e04a                	sd	s2,0(sp)
    8000294e:	1000                	addi	s0,sp,32
    80002950:	84aa                	mv	s1,a0
    80002952:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002954:	fc1fe0ef          	jal	80001914 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002958:	653c                	ld	a5,72(a0)
    8000295a:	02f4f663          	bgeu	s1,a5,80002986 <fetchaddr+0x42>
    8000295e:	00848713          	addi	a4,s1,8
    80002962:	02e7e463          	bltu	a5,a4,8000298a <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002966:	46a1                	li	a3,8
    80002968:	8626                	mv	a2,s1
    8000296a:	85ca                	mv	a1,s2
    8000296c:	6928                	ld	a0,80(a0)
    8000296e:	cfffe0ef          	jal	8000166c <copyin>
    80002972:	00a03533          	snez	a0,a0
    80002976:	40a0053b          	negw	a0,a0
}
    8000297a:	60e2                	ld	ra,24(sp)
    8000297c:	6442                	ld	s0,16(sp)
    8000297e:	64a2                	ld	s1,8(sp)
    80002980:	6902                	ld	s2,0(sp)
    80002982:	6105                	addi	sp,sp,32
    80002984:	8082                	ret
    return -1;
    80002986:	557d                	li	a0,-1
    80002988:	bfcd                	j	8000297a <fetchaddr+0x36>
    8000298a:	557d                	li	a0,-1
    8000298c:	b7fd                	j	8000297a <fetchaddr+0x36>

000000008000298e <fetchstr>:
{
    8000298e:	7179                	addi	sp,sp,-48
    80002990:	f406                	sd	ra,40(sp)
    80002992:	f022                	sd	s0,32(sp)
    80002994:	ec26                	sd	s1,24(sp)
    80002996:	e84a                	sd	s2,16(sp)
    80002998:	e44e                	sd	s3,8(sp)
    8000299a:	1800                	addi	s0,sp,48
    8000299c:	892a                	mv	s2,a0
    8000299e:	84ae                	mv	s1,a1
    800029a0:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800029a2:	f73fe0ef          	jal	80001914 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800029a6:	86ce                	mv	a3,s3
    800029a8:	864a                	mv	a2,s2
    800029aa:	85a6                	mv	a1,s1
    800029ac:	6928                	ld	a0,80(a0)
    800029ae:	d45fe0ef          	jal	800016f2 <copyinstr>
    800029b2:	00054c63          	bltz	a0,800029ca <fetchstr+0x3c>
  return strlen(buf);
    800029b6:	8526                	mv	a0,s1
    800029b8:	cd6fe0ef          	jal	80000e8e <strlen>
}
    800029bc:	70a2                	ld	ra,40(sp)
    800029be:	7402                	ld	s0,32(sp)
    800029c0:	64e2                	ld	s1,24(sp)
    800029c2:	6942                	ld	s2,16(sp)
    800029c4:	69a2                	ld	s3,8(sp)
    800029c6:	6145                	addi	sp,sp,48
    800029c8:	8082                	ret
    return -1;
    800029ca:	557d                	li	a0,-1
    800029cc:	bfc5                	j	800029bc <fetchstr+0x2e>

00000000800029ce <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800029ce:	1101                	addi	sp,sp,-32
    800029d0:	ec06                	sd	ra,24(sp)
    800029d2:	e822                	sd	s0,16(sp)
    800029d4:	e426                	sd	s1,8(sp)
    800029d6:	1000                	addi	s0,sp,32
    800029d8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800029da:	f0bff0ef          	jal	800028e4 <argraw>
    800029de:	c088                	sw	a0,0(s1)
}
    800029e0:	60e2                	ld	ra,24(sp)
    800029e2:	6442                	ld	s0,16(sp)
    800029e4:	64a2                	ld	s1,8(sp)
    800029e6:	6105                	addi	sp,sp,32
    800029e8:	8082                	ret

00000000800029ea <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800029ea:	1101                	addi	sp,sp,-32
    800029ec:	ec06                	sd	ra,24(sp)
    800029ee:	e822                	sd	s0,16(sp)
    800029f0:	e426                	sd	s1,8(sp)
    800029f2:	1000                	addi	s0,sp,32
    800029f4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800029f6:	eefff0ef          	jal	800028e4 <argraw>
    800029fa:	e088                	sd	a0,0(s1)
}
    800029fc:	60e2                	ld	ra,24(sp)
    800029fe:	6442                	ld	s0,16(sp)
    80002a00:	64a2                	ld	s1,8(sp)
    80002a02:	6105                	addi	sp,sp,32
    80002a04:	8082                	ret

0000000080002a06 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002a06:	1101                	addi	sp,sp,-32
    80002a08:	ec06                	sd	ra,24(sp)
    80002a0a:	e822                	sd	s0,16(sp)
    80002a0c:	e426                	sd	s1,8(sp)
    80002a0e:	e04a                	sd	s2,0(sp)
    80002a10:	1000                	addi	s0,sp,32
    80002a12:	84ae                	mv	s1,a1
    80002a14:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002a16:	ecfff0ef          	jal	800028e4 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002a1a:	864a                	mv	a2,s2
    80002a1c:	85a6                	mv	a1,s1
    80002a1e:	f71ff0ef          	jal	8000298e <fetchstr>
}
    80002a22:	60e2                	ld	ra,24(sp)
    80002a24:	6442                	ld	s0,16(sp)
    80002a26:	64a2                	ld	s1,8(sp)
    80002a28:	6902                	ld	s2,0(sp)
    80002a2a:	6105                	addi	sp,sp,32
    80002a2c:	8082                	ret

0000000080002a2e <syscall>:
[SYS_sigcont] sys_sigcont,
};

void
syscall(void)
{
    80002a2e:	1101                	addi	sp,sp,-32
    80002a30:	ec06                	sd	ra,24(sp)
    80002a32:	e822                	sd	s0,16(sp)
    80002a34:	e426                	sd	s1,8(sp)
    80002a36:	e04a                	sd	s2,0(sp)
    80002a38:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002a3a:	edbfe0ef          	jal	80001914 <myproc>
    80002a3e:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002a40:	05853903          	ld	s2,88(a0)
    80002a44:	0a893783          	ld	a5,168(s2)
    80002a48:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002a4c:	37fd                	addiw	a5,a5,-1
    80002a4e:	4769                	li	a4,26
    80002a50:	00f76f63          	bltu	a4,a5,80002a6e <syscall+0x40>
    80002a54:	00369713          	slli	a4,a3,0x3
    80002a58:	00005797          	auipc	a5,0x5
    80002a5c:	d7878793          	addi	a5,a5,-648 # 800077d0 <syscalls>
    80002a60:	97ba                	add	a5,a5,a4
    80002a62:	639c                	ld	a5,0(a5)
    80002a64:	c789                	beqz	a5,80002a6e <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002a66:	9782                	jalr	a5
    80002a68:	06a93823          	sd	a0,112(s2)
    80002a6c:	a829                	j	80002a86 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002a6e:	15848613          	addi	a2,s1,344
    80002a72:	588c                	lw	a1,48(s1)
    80002a74:	00005517          	auipc	a0,0x5
    80002a78:	99c50513          	addi	a0,a0,-1636 # 80007410 <etext+0x410>
    80002a7c:	a8bfd0ef          	jal	80000506 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002a80:	6cbc                	ld	a5,88(s1)
    80002a82:	577d                	li	a4,-1
    80002a84:	fbb8                	sd	a4,112(a5)
  }
}
    80002a86:	60e2                	ld	ra,24(sp)
    80002a88:	6442                	ld	s0,16(sp)
    80002a8a:	64a2                	ld	s1,8(sp)
    80002a8c:	6902                	ld	s2,0(sp)
    80002a8e:	6105                	addi	sp,sp,32
    80002a90:	8082                	ret

0000000080002a92 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002a92:	1101                	addi	sp,sp,-32
    80002a94:	ec06                	sd	ra,24(sp)
    80002a96:	e822                	sd	s0,16(sp)
    80002a98:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002a9a:	fec40593          	addi	a1,s0,-20
    80002a9e:	4501                	li	a0,0
    80002aa0:	f2fff0ef          	jal	800029ce <argint>
  exit(n);
    80002aa4:	fec42503          	lw	a0,-20(s0)
    80002aa8:	d46ff0ef          	jal	80001fee <exit>
  return 0;  // not reached
}
    80002aac:	4501                	li	a0,0
    80002aae:	60e2                	ld	ra,24(sp)
    80002ab0:	6442                	ld	s0,16(sp)
    80002ab2:	6105                	addi	sp,sp,32
    80002ab4:	8082                	ret

0000000080002ab6 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002ab6:	1141                	addi	sp,sp,-16
    80002ab8:	e406                	sd	ra,8(sp)
    80002aba:	e022                	sd	s0,0(sp)
    80002abc:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002abe:	e57fe0ef          	jal	80001914 <myproc>
}
    80002ac2:	5908                	lw	a0,48(a0)
    80002ac4:	60a2                	ld	ra,8(sp)
    80002ac6:	6402                	ld	s0,0(sp)
    80002ac8:	0141                	addi	sp,sp,16
    80002aca:	8082                	ret

0000000080002acc <sys_fork>:

uint64
sys_fork(void)
{
    80002acc:	1141                	addi	sp,sp,-16
    80002ace:	e406                	sd	ra,8(sp)
    80002ad0:	e022                	sd	s0,0(sp)
    80002ad2:	0800                	addi	s0,sp,16
  return fork();
    80002ad4:	966ff0ef          	jal	80001c3a <fork>
}
    80002ad8:	60a2                	ld	ra,8(sp)
    80002ada:	6402                	ld	s0,0(sp)
    80002adc:	0141                	addi	sp,sp,16
    80002ade:	8082                	ret

0000000080002ae0 <sys_wait>:

uint64
sys_wait(void)
{
    80002ae0:	1101                	addi	sp,sp,-32
    80002ae2:	ec06                	sd	ra,24(sp)
    80002ae4:	e822                	sd	s0,16(sp)
    80002ae6:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002ae8:	fe840593          	addi	a1,s0,-24
    80002aec:	4501                	li	a0,0
    80002aee:	efdff0ef          	jal	800029ea <argaddr>
  return wait(p);
    80002af2:	fe843503          	ld	a0,-24(s0)
    80002af6:	e4eff0ef          	jal	80002144 <wait>
}
    80002afa:	60e2                	ld	ra,24(sp)
    80002afc:	6442                	ld	s0,16(sp)
    80002afe:	6105                	addi	sp,sp,32
    80002b00:	8082                	ret

0000000080002b02 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002b02:	7179                	addi	sp,sp,-48
    80002b04:	f406                	sd	ra,40(sp)
    80002b06:	f022                	sd	s0,32(sp)
    80002b08:	ec26                	sd	s1,24(sp)
    80002b0a:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002b0c:	fdc40593          	addi	a1,s0,-36
    80002b10:	4501                	li	a0,0
    80002b12:	ebdff0ef          	jal	800029ce <argint>
  addr = myproc()->sz;
    80002b16:	dfffe0ef          	jal	80001914 <myproc>
    80002b1a:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002b1c:	fdc42503          	lw	a0,-36(s0)
    80002b20:	8caff0ef          	jal	80001bea <growproc>
    80002b24:	00054863          	bltz	a0,80002b34 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80002b28:	8526                	mv	a0,s1
    80002b2a:	70a2                	ld	ra,40(sp)
    80002b2c:	7402                	ld	s0,32(sp)
    80002b2e:	64e2                	ld	s1,24(sp)
    80002b30:	6145                	addi	sp,sp,48
    80002b32:	8082                	ret
    return -1;
    80002b34:	54fd                	li	s1,-1
    80002b36:	bfcd                	j	80002b28 <sys_sbrk+0x26>

0000000080002b38 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002b38:	7139                	addi	sp,sp,-64
    80002b3a:	fc06                	sd	ra,56(sp)
    80002b3c:	f822                	sd	s0,48(sp)
    80002b3e:	f04a                	sd	s2,32(sp)
    80002b40:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002b42:	fcc40593          	addi	a1,s0,-52
    80002b46:	4501                	li	a0,0
    80002b48:	e87ff0ef          	jal	800029ce <argint>
  if(n < 0)
    80002b4c:	fcc42783          	lw	a5,-52(s0)
    80002b50:	0607c763          	bltz	a5,80002bbe <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80002b54:	00016517          	auipc	a0,0x16
    80002b58:	aac50513          	addi	a0,a0,-1364 # 80018600 <tickslock>
    80002b5c:	8dafe0ef          	jal	80000c36 <acquire>
  ticks0 = ticks;
    80002b60:	00008917          	auipc	s2,0x8
    80002b64:	b4092903          	lw	s2,-1216(s2) # 8000a6a0 <ticks>
  while(ticks - ticks0 < n){
    80002b68:	fcc42783          	lw	a5,-52(s0)
    80002b6c:	cf8d                	beqz	a5,80002ba6 <sys_sleep+0x6e>
    80002b6e:	f426                	sd	s1,40(sp)
    80002b70:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002b72:	00016997          	auipc	s3,0x16
    80002b76:	a8e98993          	addi	s3,s3,-1394 # 80018600 <tickslock>
    80002b7a:	00008497          	auipc	s1,0x8
    80002b7e:	b2648493          	addi	s1,s1,-1242 # 8000a6a0 <ticks>
    if(killed(myproc())){
    80002b82:	d93fe0ef          	jal	80001914 <myproc>
    80002b86:	d94ff0ef          	jal	8000211a <killed>
    80002b8a:	ed0d                	bnez	a0,80002bc4 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    80002b8c:	85ce                	mv	a1,s3
    80002b8e:	8526                	mv	a0,s1
    80002b90:	b52ff0ef          	jal	80001ee2 <sleep>
  while(ticks - ticks0 < n){
    80002b94:	409c                	lw	a5,0(s1)
    80002b96:	412787bb          	subw	a5,a5,s2
    80002b9a:	fcc42703          	lw	a4,-52(s0)
    80002b9e:	fee7e2e3          	bltu	a5,a4,80002b82 <sys_sleep+0x4a>
    80002ba2:	74a2                	ld	s1,40(sp)
    80002ba4:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002ba6:	00016517          	auipc	a0,0x16
    80002baa:	a5a50513          	addi	a0,a0,-1446 # 80018600 <tickslock>
    80002bae:	91cfe0ef          	jal	80000cca <release>
  return 0;
    80002bb2:	4501                	li	a0,0
}
    80002bb4:	70e2                	ld	ra,56(sp)
    80002bb6:	7442                	ld	s0,48(sp)
    80002bb8:	7902                	ld	s2,32(sp)
    80002bba:	6121                	addi	sp,sp,64
    80002bbc:	8082                	ret
    n = 0;
    80002bbe:	fc042623          	sw	zero,-52(s0)
    80002bc2:	bf49                	j	80002b54 <sys_sleep+0x1c>
      release(&tickslock);
    80002bc4:	00016517          	auipc	a0,0x16
    80002bc8:	a3c50513          	addi	a0,a0,-1476 # 80018600 <tickslock>
    80002bcc:	8fefe0ef          	jal	80000cca <release>
      return -1;
    80002bd0:	557d                	li	a0,-1
    80002bd2:	74a2                	ld	s1,40(sp)
    80002bd4:	69e2                	ld	s3,24(sp)
    80002bd6:	bff9                	j	80002bb4 <sys_sleep+0x7c>

0000000080002bd8 <sys_kill>:

uint64
sys_kill(void)
{
    80002bd8:	1101                	addi	sp,sp,-32
    80002bda:	ec06                	sd	ra,24(sp)
    80002bdc:	e822                	sd	s0,16(sp)
    80002bde:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002be0:	fec40593          	addi	a1,s0,-20
    80002be4:	4501                	li	a0,0
    80002be6:	de9ff0ef          	jal	800029ce <argint>
  return kill(pid);
    80002bea:	fec42503          	lw	a0,-20(s0)
    80002bee:	ca2ff0ef          	jal	80002090 <kill>
}
    80002bf2:	60e2                	ld	ra,24(sp)
    80002bf4:	6442                	ld	s0,16(sp)
    80002bf6:	6105                	addi	sp,sp,32
    80002bf8:	8082                	ret

0000000080002bfa <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002bfa:	1101                	addi	sp,sp,-32
    80002bfc:	ec06                	sd	ra,24(sp)
    80002bfe:	e822                	sd	s0,16(sp)
    80002c00:	e426                	sd	s1,8(sp)
    80002c02:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002c04:	00016517          	auipc	a0,0x16
    80002c08:	9fc50513          	addi	a0,a0,-1540 # 80018600 <tickslock>
    80002c0c:	82afe0ef          	jal	80000c36 <acquire>
  xticks = ticks;
    80002c10:	00008497          	auipc	s1,0x8
    80002c14:	a904a483          	lw	s1,-1392(s1) # 8000a6a0 <ticks>
  release(&tickslock);
    80002c18:	00016517          	auipc	a0,0x16
    80002c1c:	9e850513          	addi	a0,a0,-1560 # 80018600 <tickslock>
    80002c20:	8aafe0ef          	jal	80000cca <release>
  return xticks;
}
    80002c24:	02049513          	slli	a0,s1,0x20
    80002c28:	9101                	srli	a0,a0,0x20
    80002c2a:	60e2                	ld	ra,24(sp)
    80002c2c:	6442                	ld	s0,16(sp)
    80002c2e:	64a2                	ld	s1,8(sp)
    80002c30:	6105                	addi	sp,sp,32
    80002c32:	8082                	ret

0000000080002c34 <sys_forex>:

uint64
sys_forex(void)
{
    80002c34:	716d                	addi	sp,sp,-272
    80002c36:	e606                	sd	ra,264(sp)
    80002c38:	e222                	sd	s0,256(sp)
    80002c3a:	0a00                	addi	s0,sp,272
    char filename[128]; // Buffer for the filename

    // Fetch the filename argument from user space
    if (argstr(0, filename, sizeof(filename)) < 0) {
    80002c3c:	08000613          	li	a2,128
    80002c40:	f7040593          	addi	a1,s0,-144
    80002c44:	4501                	li	a0,0
    80002c46:	dc1ff0ef          	jal	80002a06 <argstr>
    80002c4a:	04054b63          	bltz	a0,80002ca0 <sys_forex+0x6c>
        filename[0] = '\0'; // Set to an empty string if no argument is provided
    }

    if (filename[0] == '\0') {
    80002c4e:	f7044703          	lbu	a4,-144(s0)
    80002c52:	cb29                	beqz	a4,80002ca4 <sys_forex+0x70>
        return fork();
    } else {
        char full_path[128];
        int i = 0;

        if (filename[0] != '/') {
    80002c54:	02f00693          	li	a3,47
        int i = 0;
    80002c58:	4781                	li	a5,0
        if (filename[0] != '/') {
    80002c5a:	00d70563          	beq	a4,a3,80002c64 <sys_forex+0x30>
            full_path[i++] = '/';
    80002c5e:	eed40823          	sb	a3,-272(s0)
    80002c62:	4785                	li	a5,1
        }

        for (int j = 0; filename[j] != '\0'; j++, i++) {
    80002c64:	0785                	addi	a5,a5,1
    80002c66:	f7140693          	addi	a3,s0,-143
            full_path[i] = filename[j];
    80002c6a:	ef040593          	addi	a1,s0,-272
    80002c6e:	00f58633          	add	a2,a1,a5
    80002c72:	fee60fa3          	sb	a4,-1(a2)
        for (int j = 0; filename[j] != '\0'; j++, i++) {
    80002c76:	0006c703          	lbu	a4,0(a3)
    80002c7a:	863e                	mv	a2,a5
    80002c7c:	0785                	addi	a5,a5,1
    80002c7e:	0685                	addi	a3,a3,1
    80002c80:	f77d                	bnez	a4,80002c6e <sys_forex+0x3a>
        }

        full_path[i] = '\0';
    80002c82:	2601                	sext.w	a2,a2
    80002c84:	ff060793          	addi	a5,a2,-16
    80002c88:	00878633          	add	a2,a5,s0
    80002c8c:	f0060023          	sb	zero,-256(a2)
        return spawn(full_path);
    80002c90:	ef040513          	addi	a0,s0,-272
    80002c94:	761010ef          	jal	80004bf4 <spawn>
    }
}
    80002c98:	60b2                	ld	ra,264(sp)
    80002c9a:	6412                	ld	s0,256(sp)
    80002c9c:	6151                	addi	sp,sp,272
    80002c9e:	8082                	ret
        filename[0] = '\0'; // Set to an empty string if no argument is provided
    80002ca0:	f6040823          	sb	zero,-144(s0)
        return fork();
    80002ca4:	f97fe0ef          	jal	80001c3a <fork>
    80002ca8:	bfc5                	j	80002c98 <sys_forex+0x64>

0000000080002caa <sys_getppid>:

uint64 
sys_getppid(void) {
    80002caa:	1141                	addi	sp,sp,-16
    80002cac:	e406                	sd	ra,8(sp)
    80002cae:	e022                	sd	s0,0(sp)
    80002cb0:	0800                	addi	s0,sp,16
    struct proc *p = myproc();  // Get the current process
    80002cb2:	c63fe0ef          	jal	80001914 <myproc>
    return p->parent ? p->parent->pid : 0;  // Return the parent's PID, or 0 if no parent
    80002cb6:	7d1c                	ld	a5,56(a0)
    80002cb8:	4501                	li	a0,0
    80002cba:	c391                	beqz	a5,80002cbe <sys_getppid+0x14>
    80002cbc:	5b88                	lw	a0,48(a5)
}
    80002cbe:	60a2                	ld	ra,8(sp)
    80002cc0:	6402                	ld	s0,0(sp)
    80002cc2:	0141                	addi	sp,sp,16
    80002cc4:	8082                	ret

0000000080002cc6 <sys_usleep>:

int 
sys_usleep(void) {
    80002cc6:	7139                	addi	sp,sp,-64
    80002cc8:	fc06                	sd	ra,56(sp)
    80002cca:	f822                	sd	s0,48(sp)
    80002ccc:	0080                	addi	s0,sp,64
    int microseconds;
    argint(0, &microseconds);
    80002cce:	fcc40593          	addi	a1,s0,-52
    80002cd2:	4501                	li	a0,0
    80002cd4:	cfbff0ef          	jal	800029ce <argint>
    if (microseconds < 0) {
    80002cd8:	fcc42503          	lw	a0,-52(s0)
    80002cdc:	08054e63          	bltz	a0,80002d78 <sys_usleep+0xb2>
        return -1;
    }

    // For very small delays, use microdelay
    if (microseconds < 1000) {
    80002ce0:	3e700793          	li	a5,999
    80002ce4:	08a7d663          	bge	a5,a0,80002d70 <sys_usleep+0xaa>
    80002ce8:	f426                	sd	s1,40(sp)
    80002cea:	f04a                	sd	s2,32(sp)
    80002cec:	ec4e                	sd	s3,24(sp)
    80002cee:	e852                	sd	s4,16(sp)
        microdelay(microseconds);
        return 0;
    }

    // For larger delays, use the sleep mechanism
    uint ticks = microseconds / 1000; // Convert to milliseconds
    80002cf0:	106254b7          	lui	s1,0x10625
    80002cf4:	dd348493          	addi	s1,s1,-557 # 10624dd3 <_entry-0x6f9db22d>
    80002cf8:	029504b3          	mul	s1,a0,s1
    80002cfc:	9499                	srai	s1,s1,0x26
    80002cfe:	41f5551b          	sraiw	a0,a0,0x1f
    80002d02:	9c89                	subw	s1,s1,a0
    80002d04:	fc942423          	sw	s1,-56(s0)
    uint start_ticks = ticks;
    acquire(&tickslock);
    80002d08:	00016517          	auipc	a0,0x16
    80002d0c:	8f850513          	addi	a0,a0,-1800 # 80018600 <tickslock>
    80002d10:	f27fd0ef          	jal	80000c36 <acquire>
    while (ticks > 0 && ticks - start_ticks < microseconds / 1000) {
    80002d14:	fc842703          	lw	a4,-56(s0)
    80002d18:	10625937          	lui	s2,0x10625
    80002d1c:	dd390913          	addi	s2,s2,-557 # 10624dd3 <_entry-0x6f9db22d>
        sleep(&ticks, &tickslock);
    80002d20:	fc840a13          	addi	s4,s0,-56
    80002d24:	00016997          	auipc	s3,0x16
    80002d28:	8dc98993          	addi	s3,s3,-1828 # 80018600 <tickslock>
    while (ticks > 0 && ticks - start_ticks < microseconds / 1000) {
    80002d2c:	c31d                	beqz	a4,80002d52 <sys_usleep+0x8c>
    80002d2e:	fcc42683          	lw	a3,-52(s0)
    80002d32:	032687b3          	mul	a5,a3,s2
    80002d36:	9799                	srai	a5,a5,0x26
    80002d38:	41f6d69b          	sraiw	a3,a3,0x1f
    80002d3c:	9f05                	subw	a4,a4,s1
    80002d3e:	9f95                	subw	a5,a5,a3
    80002d40:	00f77963          	bgeu	a4,a5,80002d52 <sys_usleep+0x8c>
        sleep(&ticks, &tickslock);
    80002d44:	85ce                	mv	a1,s3
    80002d46:	8552                	mv	a0,s4
    80002d48:	99aff0ef          	jal	80001ee2 <sleep>
    while (ticks > 0 && ticks - start_ticks < microseconds / 1000) {
    80002d4c:	fc842703          	lw	a4,-56(s0)
    80002d50:	ff79                	bnez	a4,80002d2e <sys_usleep+0x68>
    }
    release(&tickslock);
    80002d52:	00016517          	auipc	a0,0x16
    80002d56:	8ae50513          	addi	a0,a0,-1874 # 80018600 <tickslock>
    80002d5a:	f71fd0ef          	jal	80000cca <release>

    return 0;
    80002d5e:	4501                	li	a0,0
    80002d60:	74a2                	ld	s1,40(sp)
    80002d62:	7902                	ld	s2,32(sp)
    80002d64:	69e2                	ld	s3,24(sp)
    80002d66:	6a42                	ld	s4,16(sp)
}
    80002d68:	70e2                	ld	ra,56(sp)
    80002d6a:	7442                	ld	s0,48(sp)
    80002d6c:	6121                	addi	sp,sp,64
    80002d6e:	8082                	ret
        microdelay(microseconds);
    80002d70:	cdefd0ef          	jal	8000024e <microdelay>
        return 0;
    80002d74:	4501                	li	a0,0
    80002d76:	bfcd                	j	80002d68 <sys_usleep+0xa2>
        return -1;
    80002d78:	557d                	li	a0,-1
    80002d7a:	b7fd                	j	80002d68 <sys_usleep+0xa2>

0000000080002d7c <sys_waitpid>:

uint64
sys_waitpid(void)
{
    80002d7c:	1101                	addi	sp,sp,-32
    80002d7e:	ec06                	sd	ra,24(sp)
    80002d80:	e822                	sd	s0,16(sp)
    80002d82:	1000                	addi	s0,sp,32
    int pid;
    uint64 status;

    // Get arguments from user space
    argint(0, &pid);
    80002d84:	fec40593          	addi	a1,s0,-20
    80002d88:	4501                	li	a0,0
    80002d8a:	c45ff0ef          	jal	800029ce <argint>
    argaddr(1, &status);
    80002d8e:	fe040593          	addi	a1,s0,-32
    80002d92:	4505                	li	a0,1
    80002d94:	c57ff0ef          	jal	800029ea <argaddr>

    return waitpid(pid, status);
    80002d98:	fe043583          	ld	a1,-32(s0)
    80002d9c:	fec42503          	lw	a0,-20(s0)
    80002da0:	dd0ff0ef          	jal	80002370 <waitpid>
}
    80002da4:	60e2                	ld	ra,24(sp)
    80002da6:	6442                	ld	s0,16(sp)
    80002da8:	6105                	addi	sp,sp,32
    80002daa:	8082                	ret

0000000080002dac <sys_sigstop>:


uint64 sys_sigstop(void) {
    80002dac:	1101                	addi	sp,sp,-32
    80002dae:	ec06                	sd	ra,24(sp)
    80002db0:	e822                	sd	s0,16(sp)
    80002db2:	1000                	addi	s0,sp,32
    int pid;
    //int ret;
    // Capture the return value of argint
    argint(0, &pid);
    80002db4:	fec40593          	addi	a1,s0,-20
    80002db8:	4501                	li	a0,0
    80002dba:	c15ff0ef          	jal	800029ce <argint>
    if (pid == 0)  
    80002dbe:	fec42783          	lw	a5,-20(s0)
        return -1; // If argint fails, return -1
    80002dc2:	557d                	li	a0,-1
    if (pid == 0)  
    80002dc4:	c781                	beqz	a5,80002dcc <sys_sigstop+0x20>
    return sigstop(pid);
    80002dc6:	853e                	mv	a0,a5
    80002dc8:	ef6ff0ef          	jal	800024be <sigstop>
    //         return 0;
    //     }
    //     release(&p->lock);
    // }
    // return -1;
}
    80002dcc:	60e2                	ld	ra,24(sp)
    80002dce:	6442                	ld	s0,16(sp)
    80002dd0:	6105                	addi	sp,sp,32
    80002dd2:	8082                	ret

0000000080002dd4 <sys_sigcont>:

uint64 sys_sigcont(void) {
    80002dd4:	1101                	addi	sp,sp,-32
    80002dd6:	ec06                	sd	ra,24(sp)
    80002dd8:	e822                	sd	s0,16(sp)
    80002dda:	1000                	addi	s0,sp,32
    int pid;
    //int ret;
    // Capture the return value of argint
    argint(0, &pid);
    80002ddc:	fec40593          	addi	a1,s0,-20
    80002de0:	4501                	li	a0,0
    80002de2:	bedff0ef          	jal	800029ce <argint>
    if (pid== 0)  
    80002de6:	fec42783          	lw	a5,-20(s0)
        return -1; // If argint fails, return -1
    80002dea:	557d                	li	a0,-1
    if (pid== 0)  
    80002dec:	c781                	beqz	a5,80002df4 <sys_sigcont+0x20>
    return sigcont(pid);
    80002dee:	853e                	mv	a0,a5
    80002df0:	f26ff0ef          	jal	80002516 <sigcont>
}
    80002df4:	60e2                	ld	ra,24(sp)
    80002df6:	6442                	ld	s0,16(sp)
    80002df8:	6105                	addi	sp,sp,32
    80002dfa:	8082                	ret

0000000080002dfc <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002dfc:	7179                	addi	sp,sp,-48
    80002dfe:	f406                	sd	ra,40(sp)
    80002e00:	f022                	sd	s0,32(sp)
    80002e02:	ec26                	sd	s1,24(sp)
    80002e04:	e84a                	sd	s2,16(sp)
    80002e06:	e44e                	sd	s3,8(sp)
    80002e08:	e052                	sd	s4,0(sp)
    80002e0a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002e0c:	00004597          	auipc	a1,0x4
    80002e10:	62458593          	addi	a1,a1,1572 # 80007430 <etext+0x430>
    80002e14:	00016517          	auipc	a0,0x16
    80002e18:	80450513          	addi	a0,a0,-2044 # 80018618 <bcache>
    80002e1c:	d97fd0ef          	jal	80000bb2 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002e20:	0001d797          	auipc	a5,0x1d
    80002e24:	7f878793          	addi	a5,a5,2040 # 80020618 <bcache+0x8000>
    80002e28:	0001e717          	auipc	a4,0x1e
    80002e2c:	a5870713          	addi	a4,a4,-1448 # 80020880 <bcache+0x8268>
    80002e30:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002e34:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e38:	00015497          	auipc	s1,0x15
    80002e3c:	7f848493          	addi	s1,s1,2040 # 80018630 <bcache+0x18>
    b->next = bcache.head.next;
    80002e40:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002e42:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002e44:	00004a17          	auipc	s4,0x4
    80002e48:	5f4a0a13          	addi	s4,s4,1524 # 80007438 <etext+0x438>
    b->next = bcache.head.next;
    80002e4c:	2b893783          	ld	a5,696(s2)
    80002e50:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002e52:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002e56:	85d2                	mv	a1,s4
    80002e58:	01048513          	addi	a0,s1,16
    80002e5c:	244010ef          	jal	800040a0 <initsleeplock>
    bcache.head.next->prev = b;
    80002e60:	2b893783          	ld	a5,696(s2)
    80002e64:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002e66:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e6a:	45848493          	addi	s1,s1,1112
    80002e6e:	fd349fe3          	bne	s1,s3,80002e4c <binit+0x50>
  }
}
    80002e72:	70a2                	ld	ra,40(sp)
    80002e74:	7402                	ld	s0,32(sp)
    80002e76:	64e2                	ld	s1,24(sp)
    80002e78:	6942                	ld	s2,16(sp)
    80002e7a:	69a2                	ld	s3,8(sp)
    80002e7c:	6a02                	ld	s4,0(sp)
    80002e7e:	6145                	addi	sp,sp,48
    80002e80:	8082                	ret

0000000080002e82 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002e82:	7179                	addi	sp,sp,-48
    80002e84:	f406                	sd	ra,40(sp)
    80002e86:	f022                	sd	s0,32(sp)
    80002e88:	ec26                	sd	s1,24(sp)
    80002e8a:	e84a                	sd	s2,16(sp)
    80002e8c:	e44e                	sd	s3,8(sp)
    80002e8e:	1800                	addi	s0,sp,48
    80002e90:	892a                	mv	s2,a0
    80002e92:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002e94:	00015517          	auipc	a0,0x15
    80002e98:	78450513          	addi	a0,a0,1924 # 80018618 <bcache>
    80002e9c:	d9bfd0ef          	jal	80000c36 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002ea0:	0001e497          	auipc	s1,0x1e
    80002ea4:	a304b483          	ld	s1,-1488(s1) # 800208d0 <bcache+0x82b8>
    80002ea8:	0001e797          	auipc	a5,0x1e
    80002eac:	9d878793          	addi	a5,a5,-1576 # 80020880 <bcache+0x8268>
    80002eb0:	02f48b63          	beq	s1,a5,80002ee6 <bread+0x64>
    80002eb4:	873e                	mv	a4,a5
    80002eb6:	a021                	j	80002ebe <bread+0x3c>
    80002eb8:	68a4                	ld	s1,80(s1)
    80002eba:	02e48663          	beq	s1,a4,80002ee6 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002ebe:	449c                	lw	a5,8(s1)
    80002ec0:	ff279ce3          	bne	a5,s2,80002eb8 <bread+0x36>
    80002ec4:	44dc                	lw	a5,12(s1)
    80002ec6:	ff3799e3          	bne	a5,s3,80002eb8 <bread+0x36>
      b->refcnt++;
    80002eca:	40bc                	lw	a5,64(s1)
    80002ecc:	2785                	addiw	a5,a5,1
    80002ece:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ed0:	00015517          	auipc	a0,0x15
    80002ed4:	74850513          	addi	a0,a0,1864 # 80018618 <bcache>
    80002ed8:	df3fd0ef          	jal	80000cca <release>
      acquiresleep(&b->lock);
    80002edc:	01048513          	addi	a0,s1,16
    80002ee0:	1f6010ef          	jal	800040d6 <acquiresleep>
      return b;
    80002ee4:	a889                	j	80002f36 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002ee6:	0001e497          	auipc	s1,0x1e
    80002eea:	9e24b483          	ld	s1,-1566(s1) # 800208c8 <bcache+0x82b0>
    80002eee:	0001e797          	auipc	a5,0x1e
    80002ef2:	99278793          	addi	a5,a5,-1646 # 80020880 <bcache+0x8268>
    80002ef6:	00f48863          	beq	s1,a5,80002f06 <bread+0x84>
    80002efa:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002efc:	40bc                	lw	a5,64(s1)
    80002efe:	cb91                	beqz	a5,80002f12 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f00:	64a4                	ld	s1,72(s1)
    80002f02:	fee49de3          	bne	s1,a4,80002efc <bread+0x7a>
  panic("bget: no buffers");
    80002f06:	00004517          	auipc	a0,0x4
    80002f0a:	53a50513          	addi	a0,a0,1338 # 80007440 <etext+0x440>
    80002f0e:	8c9fd0ef          	jal	800007d6 <panic>
      b->dev = dev;
    80002f12:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002f16:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002f1a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002f1e:	4785                	li	a5,1
    80002f20:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f22:	00015517          	auipc	a0,0x15
    80002f26:	6f650513          	addi	a0,a0,1782 # 80018618 <bcache>
    80002f2a:	da1fd0ef          	jal	80000cca <release>
      acquiresleep(&b->lock);
    80002f2e:	01048513          	addi	a0,s1,16
    80002f32:	1a4010ef          	jal	800040d6 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002f36:	409c                	lw	a5,0(s1)
    80002f38:	cb89                	beqz	a5,80002f4a <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002f3a:	8526                	mv	a0,s1
    80002f3c:	70a2                	ld	ra,40(sp)
    80002f3e:	7402                	ld	s0,32(sp)
    80002f40:	64e2                	ld	s1,24(sp)
    80002f42:	6942                	ld	s2,16(sp)
    80002f44:	69a2                	ld	s3,8(sp)
    80002f46:	6145                	addi	sp,sp,48
    80002f48:	8082                	ret
    virtio_disk_rw(b, 0);
    80002f4a:	4581                	li	a1,0
    80002f4c:	8526                	mv	a0,s1
    80002f4e:	5c3020ef          	jal	80005d10 <virtio_disk_rw>
    b->valid = 1;
    80002f52:	4785                	li	a5,1
    80002f54:	c09c                	sw	a5,0(s1)
  return b;
    80002f56:	b7d5                	j	80002f3a <bread+0xb8>

0000000080002f58 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002f58:	1101                	addi	sp,sp,-32
    80002f5a:	ec06                	sd	ra,24(sp)
    80002f5c:	e822                	sd	s0,16(sp)
    80002f5e:	e426                	sd	s1,8(sp)
    80002f60:	1000                	addi	s0,sp,32
    80002f62:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f64:	0541                	addi	a0,a0,16
    80002f66:	1ee010ef          	jal	80004154 <holdingsleep>
    80002f6a:	c911                	beqz	a0,80002f7e <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002f6c:	4585                	li	a1,1
    80002f6e:	8526                	mv	a0,s1
    80002f70:	5a1020ef          	jal	80005d10 <virtio_disk_rw>
}
    80002f74:	60e2                	ld	ra,24(sp)
    80002f76:	6442                	ld	s0,16(sp)
    80002f78:	64a2                	ld	s1,8(sp)
    80002f7a:	6105                	addi	sp,sp,32
    80002f7c:	8082                	ret
    panic("bwrite");
    80002f7e:	00004517          	auipc	a0,0x4
    80002f82:	4da50513          	addi	a0,a0,1242 # 80007458 <etext+0x458>
    80002f86:	851fd0ef          	jal	800007d6 <panic>

0000000080002f8a <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002f8a:	1101                	addi	sp,sp,-32
    80002f8c:	ec06                	sd	ra,24(sp)
    80002f8e:	e822                	sd	s0,16(sp)
    80002f90:	e426                	sd	s1,8(sp)
    80002f92:	e04a                	sd	s2,0(sp)
    80002f94:	1000                	addi	s0,sp,32
    80002f96:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f98:	01050913          	addi	s2,a0,16
    80002f9c:	854a                	mv	a0,s2
    80002f9e:	1b6010ef          	jal	80004154 <holdingsleep>
    80002fa2:	c125                	beqz	a0,80003002 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002fa4:	854a                	mv	a0,s2
    80002fa6:	176010ef          	jal	8000411c <releasesleep>

  acquire(&bcache.lock);
    80002faa:	00015517          	auipc	a0,0x15
    80002fae:	66e50513          	addi	a0,a0,1646 # 80018618 <bcache>
    80002fb2:	c85fd0ef          	jal	80000c36 <acquire>
  b->refcnt--;
    80002fb6:	40bc                	lw	a5,64(s1)
    80002fb8:	37fd                	addiw	a5,a5,-1
    80002fba:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002fbc:	e79d                	bnez	a5,80002fea <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002fbe:	68b8                	ld	a4,80(s1)
    80002fc0:	64bc                	ld	a5,72(s1)
    80002fc2:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002fc4:	68b8                	ld	a4,80(s1)
    80002fc6:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002fc8:	0001d797          	auipc	a5,0x1d
    80002fcc:	65078793          	addi	a5,a5,1616 # 80020618 <bcache+0x8000>
    80002fd0:	2b87b703          	ld	a4,696(a5)
    80002fd4:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002fd6:	0001e717          	auipc	a4,0x1e
    80002fda:	8aa70713          	addi	a4,a4,-1878 # 80020880 <bcache+0x8268>
    80002fde:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002fe0:	2b87b703          	ld	a4,696(a5)
    80002fe4:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002fe6:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002fea:	00015517          	auipc	a0,0x15
    80002fee:	62e50513          	addi	a0,a0,1582 # 80018618 <bcache>
    80002ff2:	cd9fd0ef          	jal	80000cca <release>
}
    80002ff6:	60e2                	ld	ra,24(sp)
    80002ff8:	6442                	ld	s0,16(sp)
    80002ffa:	64a2                	ld	s1,8(sp)
    80002ffc:	6902                	ld	s2,0(sp)
    80002ffe:	6105                	addi	sp,sp,32
    80003000:	8082                	ret
    panic("brelse");
    80003002:	00004517          	auipc	a0,0x4
    80003006:	45e50513          	addi	a0,a0,1118 # 80007460 <etext+0x460>
    8000300a:	fccfd0ef          	jal	800007d6 <panic>

000000008000300e <bpin>:

void
bpin(struct buf *b) {
    8000300e:	1101                	addi	sp,sp,-32
    80003010:	ec06                	sd	ra,24(sp)
    80003012:	e822                	sd	s0,16(sp)
    80003014:	e426                	sd	s1,8(sp)
    80003016:	1000                	addi	s0,sp,32
    80003018:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000301a:	00015517          	auipc	a0,0x15
    8000301e:	5fe50513          	addi	a0,a0,1534 # 80018618 <bcache>
    80003022:	c15fd0ef          	jal	80000c36 <acquire>
  b->refcnt++;
    80003026:	40bc                	lw	a5,64(s1)
    80003028:	2785                	addiw	a5,a5,1
    8000302a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000302c:	00015517          	auipc	a0,0x15
    80003030:	5ec50513          	addi	a0,a0,1516 # 80018618 <bcache>
    80003034:	c97fd0ef          	jal	80000cca <release>
}
    80003038:	60e2                	ld	ra,24(sp)
    8000303a:	6442                	ld	s0,16(sp)
    8000303c:	64a2                	ld	s1,8(sp)
    8000303e:	6105                	addi	sp,sp,32
    80003040:	8082                	ret

0000000080003042 <bunpin>:

void
bunpin(struct buf *b) {
    80003042:	1101                	addi	sp,sp,-32
    80003044:	ec06                	sd	ra,24(sp)
    80003046:	e822                	sd	s0,16(sp)
    80003048:	e426                	sd	s1,8(sp)
    8000304a:	1000                	addi	s0,sp,32
    8000304c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000304e:	00015517          	auipc	a0,0x15
    80003052:	5ca50513          	addi	a0,a0,1482 # 80018618 <bcache>
    80003056:	be1fd0ef          	jal	80000c36 <acquire>
  b->refcnt--;
    8000305a:	40bc                	lw	a5,64(s1)
    8000305c:	37fd                	addiw	a5,a5,-1
    8000305e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003060:	00015517          	auipc	a0,0x15
    80003064:	5b850513          	addi	a0,a0,1464 # 80018618 <bcache>
    80003068:	c63fd0ef          	jal	80000cca <release>
}
    8000306c:	60e2                	ld	ra,24(sp)
    8000306e:	6442                	ld	s0,16(sp)
    80003070:	64a2                	ld	s1,8(sp)
    80003072:	6105                	addi	sp,sp,32
    80003074:	8082                	ret

0000000080003076 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003076:	1101                	addi	sp,sp,-32
    80003078:	ec06                	sd	ra,24(sp)
    8000307a:	e822                	sd	s0,16(sp)
    8000307c:	e426                	sd	s1,8(sp)
    8000307e:	e04a                	sd	s2,0(sp)
    80003080:	1000                	addi	s0,sp,32
    80003082:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003084:	00d5d79b          	srliw	a5,a1,0xd
    80003088:	0001e597          	auipc	a1,0x1e
    8000308c:	c6c5a583          	lw	a1,-916(a1) # 80020cf4 <sb+0x1c>
    80003090:	9dbd                	addw	a1,a1,a5
    80003092:	df1ff0ef          	jal	80002e82 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003096:	0074f713          	andi	a4,s1,7
    8000309a:	4785                	li	a5,1
    8000309c:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    800030a0:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    800030a2:	90d9                	srli	s1,s1,0x36
    800030a4:	00950733          	add	a4,a0,s1
    800030a8:	05874703          	lbu	a4,88(a4)
    800030ac:	00e7f6b3          	and	a3,a5,a4
    800030b0:	c29d                	beqz	a3,800030d6 <bfree+0x60>
    800030b2:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800030b4:	94aa                	add	s1,s1,a0
    800030b6:	fff7c793          	not	a5,a5
    800030ba:	8f7d                	and	a4,a4,a5
    800030bc:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800030c0:	711000ef          	jal	80003fd0 <log_write>
  brelse(bp);
    800030c4:	854a                	mv	a0,s2
    800030c6:	ec5ff0ef          	jal	80002f8a <brelse>
}
    800030ca:	60e2                	ld	ra,24(sp)
    800030cc:	6442                	ld	s0,16(sp)
    800030ce:	64a2                	ld	s1,8(sp)
    800030d0:	6902                	ld	s2,0(sp)
    800030d2:	6105                	addi	sp,sp,32
    800030d4:	8082                	ret
    panic("freeing free block");
    800030d6:	00004517          	auipc	a0,0x4
    800030da:	39250513          	addi	a0,a0,914 # 80007468 <etext+0x468>
    800030de:	ef8fd0ef          	jal	800007d6 <panic>

00000000800030e2 <balloc>:
{
    800030e2:	715d                	addi	sp,sp,-80
    800030e4:	e486                	sd	ra,72(sp)
    800030e6:	e0a2                	sd	s0,64(sp)
    800030e8:	fc26                	sd	s1,56(sp)
    800030ea:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    800030ec:	0001e797          	auipc	a5,0x1e
    800030f0:	bf07a783          	lw	a5,-1040(a5) # 80020cdc <sb+0x4>
    800030f4:	0e078863          	beqz	a5,800031e4 <balloc+0x102>
    800030f8:	f84a                	sd	s2,48(sp)
    800030fa:	f44e                	sd	s3,40(sp)
    800030fc:	f052                	sd	s4,32(sp)
    800030fe:	ec56                	sd	s5,24(sp)
    80003100:	e85a                	sd	s6,16(sp)
    80003102:	e45e                	sd	s7,8(sp)
    80003104:	e062                	sd	s8,0(sp)
    80003106:	8baa                	mv	s7,a0
    80003108:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000310a:	0001eb17          	auipc	s6,0x1e
    8000310e:	bceb0b13          	addi	s6,s6,-1074 # 80020cd8 <sb>
      m = 1 << (bi % 8);
    80003112:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003114:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003116:	6c09                	lui	s8,0x2
    80003118:	a09d                	j	8000317e <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000311a:	97ca                	add	a5,a5,s2
    8000311c:	8e55                	or	a2,a2,a3
    8000311e:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003122:	854a                	mv	a0,s2
    80003124:	6ad000ef          	jal	80003fd0 <log_write>
        brelse(bp);
    80003128:	854a                	mv	a0,s2
    8000312a:	e61ff0ef          	jal	80002f8a <brelse>
  bp = bread(dev, bno);
    8000312e:	85a6                	mv	a1,s1
    80003130:	855e                	mv	a0,s7
    80003132:	d51ff0ef          	jal	80002e82 <bread>
    80003136:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003138:	40000613          	li	a2,1024
    8000313c:	4581                	li	a1,0
    8000313e:	05850513          	addi	a0,a0,88
    80003142:	bc5fd0ef          	jal	80000d06 <memset>
  log_write(bp);
    80003146:	854a                	mv	a0,s2
    80003148:	689000ef          	jal	80003fd0 <log_write>
  brelse(bp);
    8000314c:	854a                	mv	a0,s2
    8000314e:	e3dff0ef          	jal	80002f8a <brelse>
}
    80003152:	7942                	ld	s2,48(sp)
    80003154:	79a2                	ld	s3,40(sp)
    80003156:	7a02                	ld	s4,32(sp)
    80003158:	6ae2                	ld	s5,24(sp)
    8000315a:	6b42                	ld	s6,16(sp)
    8000315c:	6ba2                	ld	s7,8(sp)
    8000315e:	6c02                	ld	s8,0(sp)
}
    80003160:	8526                	mv	a0,s1
    80003162:	60a6                	ld	ra,72(sp)
    80003164:	6406                	ld	s0,64(sp)
    80003166:	74e2                	ld	s1,56(sp)
    80003168:	6161                	addi	sp,sp,80
    8000316a:	8082                	ret
    brelse(bp);
    8000316c:	854a                	mv	a0,s2
    8000316e:	e1dff0ef          	jal	80002f8a <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003172:	015c0abb          	addw	s5,s8,s5
    80003176:	004b2783          	lw	a5,4(s6)
    8000317a:	04fafe63          	bgeu	s5,a5,800031d6 <balloc+0xf4>
    bp = bread(dev, BBLOCK(b, sb));
    8000317e:	41fad79b          	sraiw	a5,s5,0x1f
    80003182:	0137d79b          	srliw	a5,a5,0x13
    80003186:	015787bb          	addw	a5,a5,s5
    8000318a:	40d7d79b          	sraiw	a5,a5,0xd
    8000318e:	01cb2583          	lw	a1,28(s6)
    80003192:	9dbd                	addw	a1,a1,a5
    80003194:	855e                	mv	a0,s7
    80003196:	cedff0ef          	jal	80002e82 <bread>
    8000319a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000319c:	004b2503          	lw	a0,4(s6)
    800031a0:	84d6                	mv	s1,s5
    800031a2:	4701                	li	a4,0
    800031a4:	fca4f4e3          	bgeu	s1,a0,8000316c <balloc+0x8a>
      m = 1 << (bi % 8);
    800031a8:	00777693          	andi	a3,a4,7
    800031ac:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800031b0:	41f7579b          	sraiw	a5,a4,0x1f
    800031b4:	01d7d79b          	srliw	a5,a5,0x1d
    800031b8:	9fb9                	addw	a5,a5,a4
    800031ba:	4037d79b          	sraiw	a5,a5,0x3
    800031be:	00f90633          	add	a2,s2,a5
    800031c2:	05864603          	lbu	a2,88(a2)
    800031c6:	00c6f5b3          	and	a1,a3,a2
    800031ca:	d9a1                	beqz	a1,8000311a <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031cc:	2705                	addiw	a4,a4,1
    800031ce:	2485                	addiw	s1,s1,1
    800031d0:	fd471ae3          	bne	a4,s4,800031a4 <balloc+0xc2>
    800031d4:	bf61                	j	8000316c <balloc+0x8a>
    800031d6:	7942                	ld	s2,48(sp)
    800031d8:	79a2                	ld	s3,40(sp)
    800031da:	7a02                	ld	s4,32(sp)
    800031dc:	6ae2                	ld	s5,24(sp)
    800031de:	6b42                	ld	s6,16(sp)
    800031e0:	6ba2                	ld	s7,8(sp)
    800031e2:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    800031e4:	00004517          	auipc	a0,0x4
    800031e8:	29c50513          	addi	a0,a0,668 # 80007480 <etext+0x480>
    800031ec:	b1afd0ef          	jal	80000506 <printf>
  return 0;
    800031f0:	4481                	li	s1,0
    800031f2:	b7bd                	j	80003160 <balloc+0x7e>

00000000800031f4 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800031f4:	7179                	addi	sp,sp,-48
    800031f6:	f406                	sd	ra,40(sp)
    800031f8:	f022                	sd	s0,32(sp)
    800031fa:	ec26                	sd	s1,24(sp)
    800031fc:	e84a                	sd	s2,16(sp)
    800031fe:	e44e                	sd	s3,8(sp)
    80003200:	1800                	addi	s0,sp,48
    80003202:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003204:	47ad                	li	a5,11
    80003206:	02b7e363          	bltu	a5,a1,8000322c <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    8000320a:	02059793          	slli	a5,a1,0x20
    8000320e:	01e7d593          	srli	a1,a5,0x1e
    80003212:	00b504b3          	add	s1,a0,a1
    80003216:	0504a903          	lw	s2,80(s1)
    8000321a:	06091363          	bnez	s2,80003280 <bmap+0x8c>
      addr = balloc(ip->dev);
    8000321e:	4108                	lw	a0,0(a0)
    80003220:	ec3ff0ef          	jal	800030e2 <balloc>
    80003224:	892a                	mv	s2,a0
      if(addr == 0)
    80003226:	cd29                	beqz	a0,80003280 <bmap+0x8c>
        return 0;
      ip->addrs[bn] = addr;
    80003228:	c8a8                	sw	a0,80(s1)
    8000322a:	a899                	j	80003280 <bmap+0x8c>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000322c:	ff45849b          	addiw	s1,a1,-12

  if(bn < NINDIRECT){
    80003230:	0ff00793          	li	a5,255
    80003234:	0697e963          	bltu	a5,s1,800032a6 <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003238:	08052903          	lw	s2,128(a0)
    8000323c:	00091b63          	bnez	s2,80003252 <bmap+0x5e>
      addr = balloc(ip->dev);
    80003240:	4108                	lw	a0,0(a0)
    80003242:	ea1ff0ef          	jal	800030e2 <balloc>
    80003246:	892a                	mv	s2,a0
      if(addr == 0)
    80003248:	cd05                	beqz	a0,80003280 <bmap+0x8c>
    8000324a:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000324c:	08a9a023          	sw	a0,128(s3)
    80003250:	a011                	j	80003254 <bmap+0x60>
    80003252:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003254:	85ca                	mv	a1,s2
    80003256:	0009a503          	lw	a0,0(s3)
    8000325a:	c29ff0ef          	jal	80002e82 <bread>
    8000325e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003260:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003264:	02049713          	slli	a4,s1,0x20
    80003268:	01e75593          	srli	a1,a4,0x1e
    8000326c:	00b784b3          	add	s1,a5,a1
    80003270:	0004a903          	lw	s2,0(s1)
    80003274:	00090e63          	beqz	s2,80003290 <bmap+0x9c>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003278:	8552                	mv	a0,s4
    8000327a:	d11ff0ef          	jal	80002f8a <brelse>
    return addr;
    8000327e:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003280:	854a                	mv	a0,s2
    80003282:	70a2                	ld	ra,40(sp)
    80003284:	7402                	ld	s0,32(sp)
    80003286:	64e2                	ld	s1,24(sp)
    80003288:	6942                	ld	s2,16(sp)
    8000328a:	69a2                	ld	s3,8(sp)
    8000328c:	6145                	addi	sp,sp,48
    8000328e:	8082                	ret
      addr = balloc(ip->dev);
    80003290:	0009a503          	lw	a0,0(s3)
    80003294:	e4fff0ef          	jal	800030e2 <balloc>
    80003298:	892a                	mv	s2,a0
      if(addr){
    8000329a:	dd79                	beqz	a0,80003278 <bmap+0x84>
        a[bn] = addr;
    8000329c:	c088                	sw	a0,0(s1)
        log_write(bp);
    8000329e:	8552                	mv	a0,s4
    800032a0:	531000ef          	jal	80003fd0 <log_write>
    800032a4:	bfd1                	j	80003278 <bmap+0x84>
    800032a6:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800032a8:	00004517          	auipc	a0,0x4
    800032ac:	1f050513          	addi	a0,a0,496 # 80007498 <etext+0x498>
    800032b0:	d26fd0ef          	jal	800007d6 <panic>

00000000800032b4 <iget>:
{
    800032b4:	7179                	addi	sp,sp,-48
    800032b6:	f406                	sd	ra,40(sp)
    800032b8:	f022                	sd	s0,32(sp)
    800032ba:	ec26                	sd	s1,24(sp)
    800032bc:	e84a                	sd	s2,16(sp)
    800032be:	e44e                	sd	s3,8(sp)
    800032c0:	e052                	sd	s4,0(sp)
    800032c2:	1800                	addi	s0,sp,48
    800032c4:	89aa                	mv	s3,a0
    800032c6:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800032c8:	0001e517          	auipc	a0,0x1e
    800032cc:	a3050513          	addi	a0,a0,-1488 # 80020cf8 <itable>
    800032d0:	967fd0ef          	jal	80000c36 <acquire>
  empty = 0;
    800032d4:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800032d6:	0001e497          	auipc	s1,0x1e
    800032da:	a3a48493          	addi	s1,s1,-1478 # 80020d10 <itable+0x18>
    800032de:	0001f697          	auipc	a3,0x1f
    800032e2:	4c268693          	addi	a3,a3,1218 # 800227a0 <log>
    800032e6:	a039                	j	800032f4 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800032e8:	02090963          	beqz	s2,8000331a <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800032ec:	08848493          	addi	s1,s1,136
    800032f0:	02d48863          	beq	s1,a3,80003320 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800032f4:	449c                	lw	a5,8(s1)
    800032f6:	fef059e3          	blez	a5,800032e8 <iget+0x34>
    800032fa:	4098                	lw	a4,0(s1)
    800032fc:	ff3716e3          	bne	a4,s3,800032e8 <iget+0x34>
    80003300:	40d8                	lw	a4,4(s1)
    80003302:	ff4713e3          	bne	a4,s4,800032e8 <iget+0x34>
      ip->ref++;
    80003306:	2785                	addiw	a5,a5,1
    80003308:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000330a:	0001e517          	auipc	a0,0x1e
    8000330e:	9ee50513          	addi	a0,a0,-1554 # 80020cf8 <itable>
    80003312:	9b9fd0ef          	jal	80000cca <release>
      return ip;
    80003316:	8926                	mv	s2,s1
    80003318:	a02d                	j	80003342 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000331a:	fbe9                	bnez	a5,800032ec <iget+0x38>
      empty = ip;
    8000331c:	8926                	mv	s2,s1
    8000331e:	b7f9                	j	800032ec <iget+0x38>
  if(empty == 0)
    80003320:	02090a63          	beqz	s2,80003354 <iget+0xa0>
  ip->dev = dev;
    80003324:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003328:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000332c:	4785                	li	a5,1
    8000332e:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003332:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003336:	0001e517          	auipc	a0,0x1e
    8000333a:	9c250513          	addi	a0,a0,-1598 # 80020cf8 <itable>
    8000333e:	98dfd0ef          	jal	80000cca <release>
}
    80003342:	854a                	mv	a0,s2
    80003344:	70a2                	ld	ra,40(sp)
    80003346:	7402                	ld	s0,32(sp)
    80003348:	64e2                	ld	s1,24(sp)
    8000334a:	6942                	ld	s2,16(sp)
    8000334c:	69a2                	ld	s3,8(sp)
    8000334e:	6a02                	ld	s4,0(sp)
    80003350:	6145                	addi	sp,sp,48
    80003352:	8082                	ret
    panic("iget: no inodes");
    80003354:	00004517          	auipc	a0,0x4
    80003358:	15c50513          	addi	a0,a0,348 # 800074b0 <etext+0x4b0>
    8000335c:	c7afd0ef          	jal	800007d6 <panic>

0000000080003360 <fsinit>:
fsinit(int dev) {
    80003360:	7179                	addi	sp,sp,-48
    80003362:	f406                	sd	ra,40(sp)
    80003364:	f022                	sd	s0,32(sp)
    80003366:	ec26                	sd	s1,24(sp)
    80003368:	e84a                	sd	s2,16(sp)
    8000336a:	e44e                	sd	s3,8(sp)
    8000336c:	1800                	addi	s0,sp,48
    8000336e:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003370:	4585                	li	a1,1
    80003372:	b11ff0ef          	jal	80002e82 <bread>
    80003376:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003378:	0001e997          	auipc	s3,0x1e
    8000337c:	96098993          	addi	s3,s3,-1696 # 80020cd8 <sb>
    80003380:	02000613          	li	a2,32
    80003384:	05850593          	addi	a1,a0,88
    80003388:	854e                	mv	a0,s3
    8000338a:	9e1fd0ef          	jal	80000d6a <memmove>
  brelse(bp);
    8000338e:	8526                	mv	a0,s1
    80003390:	bfbff0ef          	jal	80002f8a <brelse>
  if(sb.magic != FSMAGIC)
    80003394:	0009a703          	lw	a4,0(s3)
    80003398:	102037b7          	lui	a5,0x10203
    8000339c:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800033a0:	02f71063          	bne	a4,a5,800033c0 <fsinit+0x60>
  initlog(dev, &sb);
    800033a4:	0001e597          	auipc	a1,0x1e
    800033a8:	93458593          	addi	a1,a1,-1740 # 80020cd8 <sb>
    800033ac:	854a                	mv	a0,s2
    800033ae:	215000ef          	jal	80003dc2 <initlog>
}
    800033b2:	70a2                	ld	ra,40(sp)
    800033b4:	7402                	ld	s0,32(sp)
    800033b6:	64e2                	ld	s1,24(sp)
    800033b8:	6942                	ld	s2,16(sp)
    800033ba:	69a2                	ld	s3,8(sp)
    800033bc:	6145                	addi	sp,sp,48
    800033be:	8082                	ret
    panic("invalid file system");
    800033c0:	00004517          	auipc	a0,0x4
    800033c4:	10050513          	addi	a0,a0,256 # 800074c0 <etext+0x4c0>
    800033c8:	c0efd0ef          	jal	800007d6 <panic>

00000000800033cc <iinit>:
{
    800033cc:	7179                	addi	sp,sp,-48
    800033ce:	f406                	sd	ra,40(sp)
    800033d0:	f022                	sd	s0,32(sp)
    800033d2:	ec26                	sd	s1,24(sp)
    800033d4:	e84a                	sd	s2,16(sp)
    800033d6:	e44e                	sd	s3,8(sp)
    800033d8:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800033da:	00004597          	auipc	a1,0x4
    800033de:	0fe58593          	addi	a1,a1,254 # 800074d8 <etext+0x4d8>
    800033e2:	0001e517          	auipc	a0,0x1e
    800033e6:	91650513          	addi	a0,a0,-1770 # 80020cf8 <itable>
    800033ea:	fc8fd0ef          	jal	80000bb2 <initlock>
  for(i = 0; i < NINODE; i++) {
    800033ee:	0001e497          	auipc	s1,0x1e
    800033f2:	93248493          	addi	s1,s1,-1742 # 80020d20 <itable+0x28>
    800033f6:	0001f997          	auipc	s3,0x1f
    800033fa:	3ba98993          	addi	s3,s3,954 # 800227b0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800033fe:	00004917          	auipc	s2,0x4
    80003402:	0e290913          	addi	s2,s2,226 # 800074e0 <etext+0x4e0>
    80003406:	85ca                	mv	a1,s2
    80003408:	8526                	mv	a0,s1
    8000340a:	497000ef          	jal	800040a0 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000340e:	08848493          	addi	s1,s1,136
    80003412:	ff349ae3          	bne	s1,s3,80003406 <iinit+0x3a>
}
    80003416:	70a2                	ld	ra,40(sp)
    80003418:	7402                	ld	s0,32(sp)
    8000341a:	64e2                	ld	s1,24(sp)
    8000341c:	6942                	ld	s2,16(sp)
    8000341e:	69a2                	ld	s3,8(sp)
    80003420:	6145                	addi	sp,sp,48
    80003422:	8082                	ret

0000000080003424 <ialloc>:
{
    80003424:	7139                	addi	sp,sp,-64
    80003426:	fc06                	sd	ra,56(sp)
    80003428:	f822                	sd	s0,48(sp)
    8000342a:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    8000342c:	0001e717          	auipc	a4,0x1e
    80003430:	8b872703          	lw	a4,-1864(a4) # 80020ce4 <sb+0xc>
    80003434:	4785                	li	a5,1
    80003436:	06e7f063          	bgeu	a5,a4,80003496 <ialloc+0x72>
    8000343a:	f426                	sd	s1,40(sp)
    8000343c:	f04a                	sd	s2,32(sp)
    8000343e:	ec4e                	sd	s3,24(sp)
    80003440:	e852                	sd	s4,16(sp)
    80003442:	e456                	sd	s5,8(sp)
    80003444:	e05a                	sd	s6,0(sp)
    80003446:	8aaa                	mv	s5,a0
    80003448:	8b2e                	mv	s6,a1
    8000344a:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    8000344c:	0001ea17          	auipc	s4,0x1e
    80003450:	88ca0a13          	addi	s4,s4,-1908 # 80020cd8 <sb>
    80003454:	00495593          	srli	a1,s2,0x4
    80003458:	018a2783          	lw	a5,24(s4)
    8000345c:	9dbd                	addw	a1,a1,a5
    8000345e:	8556                	mv	a0,s5
    80003460:	a23ff0ef          	jal	80002e82 <bread>
    80003464:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003466:	05850993          	addi	s3,a0,88
    8000346a:	00f97793          	andi	a5,s2,15
    8000346e:	079a                	slli	a5,a5,0x6
    80003470:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003472:	00099783          	lh	a5,0(s3)
    80003476:	cb9d                	beqz	a5,800034ac <ialloc+0x88>
    brelse(bp);
    80003478:	b13ff0ef          	jal	80002f8a <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000347c:	0905                	addi	s2,s2,1
    8000347e:	00ca2703          	lw	a4,12(s4)
    80003482:	0009079b          	sext.w	a5,s2
    80003486:	fce7e7e3          	bltu	a5,a4,80003454 <ialloc+0x30>
    8000348a:	74a2                	ld	s1,40(sp)
    8000348c:	7902                	ld	s2,32(sp)
    8000348e:	69e2                	ld	s3,24(sp)
    80003490:	6a42                	ld	s4,16(sp)
    80003492:	6aa2                	ld	s5,8(sp)
    80003494:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003496:	00004517          	auipc	a0,0x4
    8000349a:	05250513          	addi	a0,a0,82 # 800074e8 <etext+0x4e8>
    8000349e:	868fd0ef          	jal	80000506 <printf>
  return 0;
    800034a2:	4501                	li	a0,0
}
    800034a4:	70e2                	ld	ra,56(sp)
    800034a6:	7442                	ld	s0,48(sp)
    800034a8:	6121                	addi	sp,sp,64
    800034aa:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800034ac:	04000613          	li	a2,64
    800034b0:	4581                	li	a1,0
    800034b2:	854e                	mv	a0,s3
    800034b4:	853fd0ef          	jal	80000d06 <memset>
      dip->type = type;
    800034b8:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800034bc:	8526                	mv	a0,s1
    800034be:	313000ef          	jal	80003fd0 <log_write>
      brelse(bp);
    800034c2:	8526                	mv	a0,s1
    800034c4:	ac7ff0ef          	jal	80002f8a <brelse>
      return iget(dev, inum);
    800034c8:	0009059b          	sext.w	a1,s2
    800034cc:	8556                	mv	a0,s5
    800034ce:	de7ff0ef          	jal	800032b4 <iget>
    800034d2:	74a2                	ld	s1,40(sp)
    800034d4:	7902                	ld	s2,32(sp)
    800034d6:	69e2                	ld	s3,24(sp)
    800034d8:	6a42                	ld	s4,16(sp)
    800034da:	6aa2                	ld	s5,8(sp)
    800034dc:	6b02                	ld	s6,0(sp)
    800034de:	b7d9                	j	800034a4 <ialloc+0x80>

00000000800034e0 <iupdate>:
{
    800034e0:	1101                	addi	sp,sp,-32
    800034e2:	ec06                	sd	ra,24(sp)
    800034e4:	e822                	sd	s0,16(sp)
    800034e6:	e426                	sd	s1,8(sp)
    800034e8:	e04a                	sd	s2,0(sp)
    800034ea:	1000                	addi	s0,sp,32
    800034ec:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800034ee:	415c                	lw	a5,4(a0)
    800034f0:	0047d79b          	srliw	a5,a5,0x4
    800034f4:	0001d597          	auipc	a1,0x1d
    800034f8:	7fc5a583          	lw	a1,2044(a1) # 80020cf0 <sb+0x18>
    800034fc:	9dbd                	addw	a1,a1,a5
    800034fe:	4108                	lw	a0,0(a0)
    80003500:	983ff0ef          	jal	80002e82 <bread>
    80003504:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003506:	05850793          	addi	a5,a0,88
    8000350a:	40d8                	lw	a4,4(s1)
    8000350c:	8b3d                	andi	a4,a4,15
    8000350e:	071a                	slli	a4,a4,0x6
    80003510:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003512:	04449703          	lh	a4,68(s1)
    80003516:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000351a:	04649703          	lh	a4,70(s1)
    8000351e:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003522:	04849703          	lh	a4,72(s1)
    80003526:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000352a:	04a49703          	lh	a4,74(s1)
    8000352e:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003532:	44f8                	lw	a4,76(s1)
    80003534:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003536:	03400613          	li	a2,52
    8000353a:	05048593          	addi	a1,s1,80
    8000353e:	00c78513          	addi	a0,a5,12
    80003542:	829fd0ef          	jal	80000d6a <memmove>
  log_write(bp);
    80003546:	854a                	mv	a0,s2
    80003548:	289000ef          	jal	80003fd0 <log_write>
  brelse(bp);
    8000354c:	854a                	mv	a0,s2
    8000354e:	a3dff0ef          	jal	80002f8a <brelse>
}
    80003552:	60e2                	ld	ra,24(sp)
    80003554:	6442                	ld	s0,16(sp)
    80003556:	64a2                	ld	s1,8(sp)
    80003558:	6902                	ld	s2,0(sp)
    8000355a:	6105                	addi	sp,sp,32
    8000355c:	8082                	ret

000000008000355e <idup>:
{
    8000355e:	1101                	addi	sp,sp,-32
    80003560:	ec06                	sd	ra,24(sp)
    80003562:	e822                	sd	s0,16(sp)
    80003564:	e426                	sd	s1,8(sp)
    80003566:	1000                	addi	s0,sp,32
    80003568:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000356a:	0001d517          	auipc	a0,0x1d
    8000356e:	78e50513          	addi	a0,a0,1934 # 80020cf8 <itable>
    80003572:	ec4fd0ef          	jal	80000c36 <acquire>
  ip->ref++;
    80003576:	449c                	lw	a5,8(s1)
    80003578:	2785                	addiw	a5,a5,1
    8000357a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000357c:	0001d517          	auipc	a0,0x1d
    80003580:	77c50513          	addi	a0,a0,1916 # 80020cf8 <itable>
    80003584:	f46fd0ef          	jal	80000cca <release>
}
    80003588:	8526                	mv	a0,s1
    8000358a:	60e2                	ld	ra,24(sp)
    8000358c:	6442                	ld	s0,16(sp)
    8000358e:	64a2                	ld	s1,8(sp)
    80003590:	6105                	addi	sp,sp,32
    80003592:	8082                	ret

0000000080003594 <ilock>:
{
    80003594:	1101                	addi	sp,sp,-32
    80003596:	ec06                	sd	ra,24(sp)
    80003598:	e822                	sd	s0,16(sp)
    8000359a:	e426                	sd	s1,8(sp)
    8000359c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000359e:	cd19                	beqz	a0,800035bc <ilock+0x28>
    800035a0:	84aa                	mv	s1,a0
    800035a2:	451c                	lw	a5,8(a0)
    800035a4:	00f05c63          	blez	a5,800035bc <ilock+0x28>
  acquiresleep(&ip->lock);
    800035a8:	0541                	addi	a0,a0,16
    800035aa:	32d000ef          	jal	800040d6 <acquiresleep>
  if(ip->valid == 0){
    800035ae:	40bc                	lw	a5,64(s1)
    800035b0:	cf89                	beqz	a5,800035ca <ilock+0x36>
}
    800035b2:	60e2                	ld	ra,24(sp)
    800035b4:	6442                	ld	s0,16(sp)
    800035b6:	64a2                	ld	s1,8(sp)
    800035b8:	6105                	addi	sp,sp,32
    800035ba:	8082                	ret
    800035bc:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800035be:	00004517          	auipc	a0,0x4
    800035c2:	f4250513          	addi	a0,a0,-190 # 80007500 <etext+0x500>
    800035c6:	a10fd0ef          	jal	800007d6 <panic>
    800035ca:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800035cc:	40dc                	lw	a5,4(s1)
    800035ce:	0047d79b          	srliw	a5,a5,0x4
    800035d2:	0001d597          	auipc	a1,0x1d
    800035d6:	71e5a583          	lw	a1,1822(a1) # 80020cf0 <sb+0x18>
    800035da:	9dbd                	addw	a1,a1,a5
    800035dc:	4088                	lw	a0,0(s1)
    800035de:	8a5ff0ef          	jal	80002e82 <bread>
    800035e2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800035e4:	05850593          	addi	a1,a0,88
    800035e8:	40dc                	lw	a5,4(s1)
    800035ea:	8bbd                	andi	a5,a5,15
    800035ec:	079a                	slli	a5,a5,0x6
    800035ee:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800035f0:	00059783          	lh	a5,0(a1)
    800035f4:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800035f8:	00259783          	lh	a5,2(a1)
    800035fc:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003600:	00459783          	lh	a5,4(a1)
    80003604:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003608:	00659783          	lh	a5,6(a1)
    8000360c:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003610:	459c                	lw	a5,8(a1)
    80003612:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003614:	03400613          	li	a2,52
    80003618:	05b1                	addi	a1,a1,12
    8000361a:	05048513          	addi	a0,s1,80
    8000361e:	f4cfd0ef          	jal	80000d6a <memmove>
    brelse(bp);
    80003622:	854a                	mv	a0,s2
    80003624:	967ff0ef          	jal	80002f8a <brelse>
    ip->valid = 1;
    80003628:	4785                	li	a5,1
    8000362a:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000362c:	04449783          	lh	a5,68(s1)
    80003630:	c399                	beqz	a5,80003636 <ilock+0xa2>
    80003632:	6902                	ld	s2,0(sp)
    80003634:	bfbd                	j	800035b2 <ilock+0x1e>
      panic("ilock: no type");
    80003636:	00004517          	auipc	a0,0x4
    8000363a:	ed250513          	addi	a0,a0,-302 # 80007508 <etext+0x508>
    8000363e:	998fd0ef          	jal	800007d6 <panic>

0000000080003642 <iunlock>:
{
    80003642:	1101                	addi	sp,sp,-32
    80003644:	ec06                	sd	ra,24(sp)
    80003646:	e822                	sd	s0,16(sp)
    80003648:	e426                	sd	s1,8(sp)
    8000364a:	e04a                	sd	s2,0(sp)
    8000364c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000364e:	c505                	beqz	a0,80003676 <iunlock+0x34>
    80003650:	84aa                	mv	s1,a0
    80003652:	01050913          	addi	s2,a0,16
    80003656:	854a                	mv	a0,s2
    80003658:	2fd000ef          	jal	80004154 <holdingsleep>
    8000365c:	cd09                	beqz	a0,80003676 <iunlock+0x34>
    8000365e:	449c                	lw	a5,8(s1)
    80003660:	00f05b63          	blez	a5,80003676 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003664:	854a                	mv	a0,s2
    80003666:	2b7000ef          	jal	8000411c <releasesleep>
}
    8000366a:	60e2                	ld	ra,24(sp)
    8000366c:	6442                	ld	s0,16(sp)
    8000366e:	64a2                	ld	s1,8(sp)
    80003670:	6902                	ld	s2,0(sp)
    80003672:	6105                	addi	sp,sp,32
    80003674:	8082                	ret
    panic("iunlock");
    80003676:	00004517          	auipc	a0,0x4
    8000367a:	ea250513          	addi	a0,a0,-350 # 80007518 <etext+0x518>
    8000367e:	958fd0ef          	jal	800007d6 <panic>

0000000080003682 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003682:	7179                	addi	sp,sp,-48
    80003684:	f406                	sd	ra,40(sp)
    80003686:	f022                	sd	s0,32(sp)
    80003688:	ec26                	sd	s1,24(sp)
    8000368a:	e84a                	sd	s2,16(sp)
    8000368c:	e44e                	sd	s3,8(sp)
    8000368e:	1800                	addi	s0,sp,48
    80003690:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003692:	05050493          	addi	s1,a0,80
    80003696:	08050913          	addi	s2,a0,128
    8000369a:	a021                	j	800036a2 <itrunc+0x20>
    8000369c:	0491                	addi	s1,s1,4
    8000369e:	01248b63          	beq	s1,s2,800036b4 <itrunc+0x32>
    if(ip->addrs[i]){
    800036a2:	408c                	lw	a1,0(s1)
    800036a4:	dde5                	beqz	a1,8000369c <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800036a6:	0009a503          	lw	a0,0(s3)
    800036aa:	9cdff0ef          	jal	80003076 <bfree>
      ip->addrs[i] = 0;
    800036ae:	0004a023          	sw	zero,0(s1)
    800036b2:	b7ed                	j	8000369c <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800036b4:	0809a583          	lw	a1,128(s3)
    800036b8:	ed89                	bnez	a1,800036d2 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800036ba:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800036be:	854e                	mv	a0,s3
    800036c0:	e21ff0ef          	jal	800034e0 <iupdate>
}
    800036c4:	70a2                	ld	ra,40(sp)
    800036c6:	7402                	ld	s0,32(sp)
    800036c8:	64e2                	ld	s1,24(sp)
    800036ca:	6942                	ld	s2,16(sp)
    800036cc:	69a2                	ld	s3,8(sp)
    800036ce:	6145                	addi	sp,sp,48
    800036d0:	8082                	ret
    800036d2:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800036d4:	0009a503          	lw	a0,0(s3)
    800036d8:	faaff0ef          	jal	80002e82 <bread>
    800036dc:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800036de:	05850493          	addi	s1,a0,88
    800036e2:	45850913          	addi	s2,a0,1112
    800036e6:	a021                	j	800036ee <itrunc+0x6c>
    800036e8:	0491                	addi	s1,s1,4
    800036ea:	01248963          	beq	s1,s2,800036fc <itrunc+0x7a>
      if(a[j])
    800036ee:	408c                	lw	a1,0(s1)
    800036f0:	dde5                	beqz	a1,800036e8 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    800036f2:	0009a503          	lw	a0,0(s3)
    800036f6:	981ff0ef          	jal	80003076 <bfree>
    800036fa:	b7fd                	j	800036e8 <itrunc+0x66>
    brelse(bp);
    800036fc:	8552                	mv	a0,s4
    800036fe:	88dff0ef          	jal	80002f8a <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003702:	0809a583          	lw	a1,128(s3)
    80003706:	0009a503          	lw	a0,0(s3)
    8000370a:	96dff0ef          	jal	80003076 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000370e:	0809a023          	sw	zero,128(s3)
    80003712:	6a02                	ld	s4,0(sp)
    80003714:	b75d                	j	800036ba <itrunc+0x38>

0000000080003716 <iput>:
{
    80003716:	1101                	addi	sp,sp,-32
    80003718:	ec06                	sd	ra,24(sp)
    8000371a:	e822                	sd	s0,16(sp)
    8000371c:	e426                	sd	s1,8(sp)
    8000371e:	1000                	addi	s0,sp,32
    80003720:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003722:	0001d517          	auipc	a0,0x1d
    80003726:	5d650513          	addi	a0,a0,1494 # 80020cf8 <itable>
    8000372a:	d0cfd0ef          	jal	80000c36 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000372e:	4498                	lw	a4,8(s1)
    80003730:	4785                	li	a5,1
    80003732:	02f70063          	beq	a4,a5,80003752 <iput+0x3c>
  ip->ref--;
    80003736:	449c                	lw	a5,8(s1)
    80003738:	37fd                	addiw	a5,a5,-1
    8000373a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000373c:	0001d517          	auipc	a0,0x1d
    80003740:	5bc50513          	addi	a0,a0,1468 # 80020cf8 <itable>
    80003744:	d86fd0ef          	jal	80000cca <release>
}
    80003748:	60e2                	ld	ra,24(sp)
    8000374a:	6442                	ld	s0,16(sp)
    8000374c:	64a2                	ld	s1,8(sp)
    8000374e:	6105                	addi	sp,sp,32
    80003750:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003752:	40bc                	lw	a5,64(s1)
    80003754:	d3ed                	beqz	a5,80003736 <iput+0x20>
    80003756:	04a49783          	lh	a5,74(s1)
    8000375a:	fff1                	bnez	a5,80003736 <iput+0x20>
    8000375c:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    8000375e:	01048913          	addi	s2,s1,16
    80003762:	854a                	mv	a0,s2
    80003764:	173000ef          	jal	800040d6 <acquiresleep>
    release(&itable.lock);
    80003768:	0001d517          	auipc	a0,0x1d
    8000376c:	59050513          	addi	a0,a0,1424 # 80020cf8 <itable>
    80003770:	d5afd0ef          	jal	80000cca <release>
    itrunc(ip);
    80003774:	8526                	mv	a0,s1
    80003776:	f0dff0ef          	jal	80003682 <itrunc>
    ip->type = 0;
    8000377a:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000377e:	8526                	mv	a0,s1
    80003780:	d61ff0ef          	jal	800034e0 <iupdate>
    ip->valid = 0;
    80003784:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003788:	854a                	mv	a0,s2
    8000378a:	193000ef          	jal	8000411c <releasesleep>
    acquire(&itable.lock);
    8000378e:	0001d517          	auipc	a0,0x1d
    80003792:	56a50513          	addi	a0,a0,1386 # 80020cf8 <itable>
    80003796:	ca0fd0ef          	jal	80000c36 <acquire>
    8000379a:	6902                	ld	s2,0(sp)
    8000379c:	bf69                	j	80003736 <iput+0x20>

000000008000379e <iunlockput>:
{
    8000379e:	1101                	addi	sp,sp,-32
    800037a0:	ec06                	sd	ra,24(sp)
    800037a2:	e822                	sd	s0,16(sp)
    800037a4:	e426                	sd	s1,8(sp)
    800037a6:	1000                	addi	s0,sp,32
    800037a8:	84aa                	mv	s1,a0
  iunlock(ip);
    800037aa:	e99ff0ef          	jal	80003642 <iunlock>
  iput(ip);
    800037ae:	8526                	mv	a0,s1
    800037b0:	f67ff0ef          	jal	80003716 <iput>
}
    800037b4:	60e2                	ld	ra,24(sp)
    800037b6:	6442                	ld	s0,16(sp)
    800037b8:	64a2                	ld	s1,8(sp)
    800037ba:	6105                	addi	sp,sp,32
    800037bc:	8082                	ret

00000000800037be <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800037be:	1141                	addi	sp,sp,-16
    800037c0:	e406                	sd	ra,8(sp)
    800037c2:	e022                	sd	s0,0(sp)
    800037c4:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800037c6:	411c                	lw	a5,0(a0)
    800037c8:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800037ca:	415c                	lw	a5,4(a0)
    800037cc:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800037ce:	04451783          	lh	a5,68(a0)
    800037d2:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800037d6:	04a51783          	lh	a5,74(a0)
    800037da:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800037de:	04c56783          	lwu	a5,76(a0)
    800037e2:	e99c                	sd	a5,16(a1)
}
    800037e4:	60a2                	ld	ra,8(sp)
    800037e6:	6402                	ld	s0,0(sp)
    800037e8:	0141                	addi	sp,sp,16
    800037ea:	8082                	ret

00000000800037ec <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800037ec:	457c                	lw	a5,76(a0)
    800037ee:	0ed7e663          	bltu	a5,a3,800038da <readi+0xee>
{
    800037f2:	7159                	addi	sp,sp,-112
    800037f4:	f486                	sd	ra,104(sp)
    800037f6:	f0a2                	sd	s0,96(sp)
    800037f8:	eca6                	sd	s1,88(sp)
    800037fa:	e0d2                	sd	s4,64(sp)
    800037fc:	fc56                	sd	s5,56(sp)
    800037fe:	f85a                	sd	s6,48(sp)
    80003800:	f45e                	sd	s7,40(sp)
    80003802:	1880                	addi	s0,sp,112
    80003804:	8b2a                	mv	s6,a0
    80003806:	8bae                	mv	s7,a1
    80003808:	8a32                	mv	s4,a2
    8000380a:	84b6                	mv	s1,a3
    8000380c:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    8000380e:	9f35                	addw	a4,a4,a3
    return 0;
    80003810:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003812:	0ad76b63          	bltu	a4,a3,800038c8 <readi+0xdc>
    80003816:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003818:	00e7f463          	bgeu	a5,a4,80003820 <readi+0x34>
    n = ip->size - off;
    8000381c:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003820:	080a8b63          	beqz	s5,800038b6 <readi+0xca>
    80003824:	e8ca                	sd	s2,80(sp)
    80003826:	f062                	sd	s8,32(sp)
    80003828:	ec66                	sd	s9,24(sp)
    8000382a:	e86a                	sd	s10,16(sp)
    8000382c:	e46e                	sd	s11,8(sp)
    8000382e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003830:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003834:	5c7d                	li	s8,-1
    80003836:	a80d                	j	80003868 <readi+0x7c>
    80003838:	020d1d93          	slli	s11,s10,0x20
    8000383c:	020ddd93          	srli	s11,s11,0x20
    80003840:	05890613          	addi	a2,s2,88
    80003844:	86ee                	mv	a3,s11
    80003846:	963e                	add	a2,a2,a5
    80003848:	85d2                	mv	a1,s4
    8000384a:	855e                	mv	a0,s7
    8000384c:	9edfe0ef          	jal	80002238 <either_copyout>
    80003850:	05850363          	beq	a0,s8,80003896 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003854:	854a                	mv	a0,s2
    80003856:	f34ff0ef          	jal	80002f8a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000385a:	013d09bb          	addw	s3,s10,s3
    8000385e:	009d04bb          	addw	s1,s10,s1
    80003862:	9a6e                	add	s4,s4,s11
    80003864:	0559f363          	bgeu	s3,s5,800038aa <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003868:	00a4d59b          	srliw	a1,s1,0xa
    8000386c:	855a                	mv	a0,s6
    8000386e:	987ff0ef          	jal	800031f4 <bmap>
    80003872:	85aa                	mv	a1,a0
    if(addr == 0)
    80003874:	c139                	beqz	a0,800038ba <readi+0xce>
    bp = bread(ip->dev, addr);
    80003876:	000b2503          	lw	a0,0(s6)
    8000387a:	e08ff0ef          	jal	80002e82 <bread>
    8000387e:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003880:	3ff4f793          	andi	a5,s1,1023
    80003884:	40fc873b          	subw	a4,s9,a5
    80003888:	413a86bb          	subw	a3,s5,s3
    8000388c:	8d3a                	mv	s10,a4
    8000388e:	fae6f5e3          	bgeu	a3,a4,80003838 <readi+0x4c>
    80003892:	8d36                	mv	s10,a3
    80003894:	b755                	j	80003838 <readi+0x4c>
      brelse(bp);
    80003896:	854a                	mv	a0,s2
    80003898:	ef2ff0ef          	jal	80002f8a <brelse>
      tot = -1;
    8000389c:	59fd                	li	s3,-1
      break;
    8000389e:	6946                	ld	s2,80(sp)
    800038a0:	7c02                	ld	s8,32(sp)
    800038a2:	6ce2                	ld	s9,24(sp)
    800038a4:	6d42                	ld	s10,16(sp)
    800038a6:	6da2                	ld	s11,8(sp)
    800038a8:	a831                	j	800038c4 <readi+0xd8>
    800038aa:	6946                	ld	s2,80(sp)
    800038ac:	7c02                	ld	s8,32(sp)
    800038ae:	6ce2                	ld	s9,24(sp)
    800038b0:	6d42                	ld	s10,16(sp)
    800038b2:	6da2                	ld	s11,8(sp)
    800038b4:	a801                	j	800038c4 <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800038b6:	89d6                	mv	s3,s5
    800038b8:	a031                	j	800038c4 <readi+0xd8>
    800038ba:	6946                	ld	s2,80(sp)
    800038bc:	7c02                	ld	s8,32(sp)
    800038be:	6ce2                	ld	s9,24(sp)
    800038c0:	6d42                	ld	s10,16(sp)
    800038c2:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800038c4:	854e                	mv	a0,s3
    800038c6:	69a6                	ld	s3,72(sp)
}
    800038c8:	70a6                	ld	ra,104(sp)
    800038ca:	7406                	ld	s0,96(sp)
    800038cc:	64e6                	ld	s1,88(sp)
    800038ce:	6a06                	ld	s4,64(sp)
    800038d0:	7ae2                	ld	s5,56(sp)
    800038d2:	7b42                	ld	s6,48(sp)
    800038d4:	7ba2                	ld	s7,40(sp)
    800038d6:	6165                	addi	sp,sp,112
    800038d8:	8082                	ret
    return 0;
    800038da:	4501                	li	a0,0
}
    800038dc:	8082                	ret

00000000800038de <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800038de:	457c                	lw	a5,76(a0)
    800038e0:	0ed7eb63          	bltu	a5,a3,800039d6 <writei+0xf8>
{
    800038e4:	7159                	addi	sp,sp,-112
    800038e6:	f486                	sd	ra,104(sp)
    800038e8:	f0a2                	sd	s0,96(sp)
    800038ea:	e8ca                	sd	s2,80(sp)
    800038ec:	e0d2                	sd	s4,64(sp)
    800038ee:	fc56                	sd	s5,56(sp)
    800038f0:	f85a                	sd	s6,48(sp)
    800038f2:	f45e                	sd	s7,40(sp)
    800038f4:	1880                	addi	s0,sp,112
    800038f6:	8aaa                	mv	s5,a0
    800038f8:	8bae                	mv	s7,a1
    800038fa:	8a32                	mv	s4,a2
    800038fc:	8936                	mv	s2,a3
    800038fe:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003900:	00e687bb          	addw	a5,a3,a4
    80003904:	0cd7eb63          	bltu	a5,a3,800039da <writei+0xfc>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003908:	00043737          	lui	a4,0x43
    8000390c:	0cf76963          	bltu	a4,a5,800039de <writei+0x100>
    80003910:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003912:	0a0b0a63          	beqz	s6,800039c6 <writei+0xe8>
    80003916:	eca6                	sd	s1,88(sp)
    80003918:	f062                	sd	s8,32(sp)
    8000391a:	ec66                	sd	s9,24(sp)
    8000391c:	e86a                	sd	s10,16(sp)
    8000391e:	e46e                	sd	s11,8(sp)
    80003920:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003922:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003926:	5c7d                	li	s8,-1
    80003928:	a825                	j	80003960 <writei+0x82>
    8000392a:	020d1d93          	slli	s11,s10,0x20
    8000392e:	020ddd93          	srli	s11,s11,0x20
    80003932:	05848513          	addi	a0,s1,88
    80003936:	86ee                	mv	a3,s11
    80003938:	8652                	mv	a2,s4
    8000393a:	85de                	mv	a1,s7
    8000393c:	953e                	add	a0,a0,a5
    8000393e:	945fe0ef          	jal	80002282 <either_copyin>
    80003942:	05850663          	beq	a0,s8,8000398e <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003946:	8526                	mv	a0,s1
    80003948:	688000ef          	jal	80003fd0 <log_write>
    brelse(bp);
    8000394c:	8526                	mv	a0,s1
    8000394e:	e3cff0ef          	jal	80002f8a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003952:	013d09bb          	addw	s3,s10,s3
    80003956:	012d093b          	addw	s2,s10,s2
    8000395a:	9a6e                	add	s4,s4,s11
    8000395c:	0369fc63          	bgeu	s3,s6,80003994 <writei+0xb6>
    uint addr = bmap(ip, off/BSIZE);
    80003960:	00a9559b          	srliw	a1,s2,0xa
    80003964:	8556                	mv	a0,s5
    80003966:	88fff0ef          	jal	800031f4 <bmap>
    8000396a:	85aa                	mv	a1,a0
    if(addr == 0)
    8000396c:	c505                	beqz	a0,80003994 <writei+0xb6>
    bp = bread(ip->dev, addr);
    8000396e:	000aa503          	lw	a0,0(s5)
    80003972:	d10ff0ef          	jal	80002e82 <bread>
    80003976:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003978:	3ff97793          	andi	a5,s2,1023
    8000397c:	40fc873b          	subw	a4,s9,a5
    80003980:	413b06bb          	subw	a3,s6,s3
    80003984:	8d3a                	mv	s10,a4
    80003986:	fae6f2e3          	bgeu	a3,a4,8000392a <writei+0x4c>
    8000398a:	8d36                	mv	s10,a3
    8000398c:	bf79                	j	8000392a <writei+0x4c>
      brelse(bp);
    8000398e:	8526                	mv	a0,s1
    80003990:	dfaff0ef          	jal	80002f8a <brelse>
  }

  if(off > ip->size)
    80003994:	04caa783          	lw	a5,76(s5)
    80003998:	0327f963          	bgeu	a5,s2,800039ca <writei+0xec>
    ip->size = off;
    8000399c:	052aa623          	sw	s2,76(s5)
    800039a0:	64e6                	ld	s1,88(sp)
    800039a2:	7c02                	ld	s8,32(sp)
    800039a4:	6ce2                	ld	s9,24(sp)
    800039a6:	6d42                	ld	s10,16(sp)
    800039a8:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800039aa:	8556                	mv	a0,s5
    800039ac:	b35ff0ef          	jal	800034e0 <iupdate>

  return tot;
    800039b0:	854e                	mv	a0,s3
    800039b2:	69a6                	ld	s3,72(sp)
}
    800039b4:	70a6                	ld	ra,104(sp)
    800039b6:	7406                	ld	s0,96(sp)
    800039b8:	6946                	ld	s2,80(sp)
    800039ba:	6a06                	ld	s4,64(sp)
    800039bc:	7ae2                	ld	s5,56(sp)
    800039be:	7b42                	ld	s6,48(sp)
    800039c0:	7ba2                	ld	s7,40(sp)
    800039c2:	6165                	addi	sp,sp,112
    800039c4:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800039c6:	89da                	mv	s3,s6
    800039c8:	b7cd                	j	800039aa <writei+0xcc>
    800039ca:	64e6                	ld	s1,88(sp)
    800039cc:	7c02                	ld	s8,32(sp)
    800039ce:	6ce2                	ld	s9,24(sp)
    800039d0:	6d42                	ld	s10,16(sp)
    800039d2:	6da2                	ld	s11,8(sp)
    800039d4:	bfd9                	j	800039aa <writei+0xcc>
    return -1;
    800039d6:	557d                	li	a0,-1
}
    800039d8:	8082                	ret
    return -1;
    800039da:	557d                	li	a0,-1
    800039dc:	bfe1                	j	800039b4 <writei+0xd6>
    return -1;
    800039de:	557d                	li	a0,-1
    800039e0:	bfd1                	j	800039b4 <writei+0xd6>

00000000800039e2 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800039e2:	1141                	addi	sp,sp,-16
    800039e4:	e406                	sd	ra,8(sp)
    800039e6:	e022                	sd	s0,0(sp)
    800039e8:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800039ea:	4639                	li	a2,14
    800039ec:	bf2fd0ef          	jal	80000dde <strncmp>
}
    800039f0:	60a2                	ld	ra,8(sp)
    800039f2:	6402                	ld	s0,0(sp)
    800039f4:	0141                	addi	sp,sp,16
    800039f6:	8082                	ret

00000000800039f8 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800039f8:	711d                	addi	sp,sp,-96
    800039fa:	ec86                	sd	ra,88(sp)
    800039fc:	e8a2                	sd	s0,80(sp)
    800039fe:	e4a6                	sd	s1,72(sp)
    80003a00:	e0ca                	sd	s2,64(sp)
    80003a02:	fc4e                	sd	s3,56(sp)
    80003a04:	f852                	sd	s4,48(sp)
    80003a06:	f456                	sd	s5,40(sp)
    80003a08:	f05a                	sd	s6,32(sp)
    80003a0a:	ec5e                	sd	s7,24(sp)
    80003a0c:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003a0e:	04451703          	lh	a4,68(a0)
    80003a12:	4785                	li	a5,1
    80003a14:	00f71f63          	bne	a4,a5,80003a32 <dirlookup+0x3a>
    80003a18:	892a                	mv	s2,a0
    80003a1a:	8aae                	mv	s5,a1
    80003a1c:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a1e:	457c                	lw	a5,76(a0)
    80003a20:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a22:	fa040a13          	addi	s4,s0,-96
    80003a26:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    80003a28:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003a2c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a2e:	e39d                	bnez	a5,80003a54 <dirlookup+0x5c>
    80003a30:	a8b9                	j	80003a8e <dirlookup+0x96>
    panic("dirlookup not DIR");
    80003a32:	00004517          	auipc	a0,0x4
    80003a36:	aee50513          	addi	a0,a0,-1298 # 80007520 <etext+0x520>
    80003a3a:	d9dfc0ef          	jal	800007d6 <panic>
      panic("dirlookup read");
    80003a3e:	00004517          	auipc	a0,0x4
    80003a42:	afa50513          	addi	a0,a0,-1286 # 80007538 <etext+0x538>
    80003a46:	d91fc0ef          	jal	800007d6 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a4a:	24c1                	addiw	s1,s1,16
    80003a4c:	04c92783          	lw	a5,76(s2)
    80003a50:	02f4fe63          	bgeu	s1,a5,80003a8c <dirlookup+0x94>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a54:	874e                	mv	a4,s3
    80003a56:	86a6                	mv	a3,s1
    80003a58:	8652                	mv	a2,s4
    80003a5a:	4581                	li	a1,0
    80003a5c:	854a                	mv	a0,s2
    80003a5e:	d8fff0ef          	jal	800037ec <readi>
    80003a62:	fd351ee3          	bne	a0,s3,80003a3e <dirlookup+0x46>
    if(de.inum == 0)
    80003a66:	fa045783          	lhu	a5,-96(s0)
    80003a6a:	d3e5                	beqz	a5,80003a4a <dirlookup+0x52>
    if(namecmp(name, de.name) == 0){
    80003a6c:	85da                	mv	a1,s6
    80003a6e:	8556                	mv	a0,s5
    80003a70:	f73ff0ef          	jal	800039e2 <namecmp>
    80003a74:	f979                	bnez	a0,80003a4a <dirlookup+0x52>
      if(poff)
    80003a76:	000b8463          	beqz	s7,80003a7e <dirlookup+0x86>
        *poff = off;
    80003a7a:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80003a7e:	fa045583          	lhu	a1,-96(s0)
    80003a82:	00092503          	lw	a0,0(s2)
    80003a86:	82fff0ef          	jal	800032b4 <iget>
    80003a8a:	a011                	j	80003a8e <dirlookup+0x96>
  return 0;
    80003a8c:	4501                	li	a0,0
}
    80003a8e:	60e6                	ld	ra,88(sp)
    80003a90:	6446                	ld	s0,80(sp)
    80003a92:	64a6                	ld	s1,72(sp)
    80003a94:	6906                	ld	s2,64(sp)
    80003a96:	79e2                	ld	s3,56(sp)
    80003a98:	7a42                	ld	s4,48(sp)
    80003a9a:	7aa2                	ld	s5,40(sp)
    80003a9c:	7b02                	ld	s6,32(sp)
    80003a9e:	6be2                	ld	s7,24(sp)
    80003aa0:	6125                	addi	sp,sp,96
    80003aa2:	8082                	ret

0000000080003aa4 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003aa4:	711d                	addi	sp,sp,-96
    80003aa6:	ec86                	sd	ra,88(sp)
    80003aa8:	e8a2                	sd	s0,80(sp)
    80003aaa:	e4a6                	sd	s1,72(sp)
    80003aac:	e0ca                	sd	s2,64(sp)
    80003aae:	fc4e                	sd	s3,56(sp)
    80003ab0:	f852                	sd	s4,48(sp)
    80003ab2:	f456                	sd	s5,40(sp)
    80003ab4:	f05a                	sd	s6,32(sp)
    80003ab6:	ec5e                	sd	s7,24(sp)
    80003ab8:	e862                	sd	s8,16(sp)
    80003aba:	e466                	sd	s9,8(sp)
    80003abc:	e06a                	sd	s10,0(sp)
    80003abe:	1080                	addi	s0,sp,96
    80003ac0:	84aa                	mv	s1,a0
    80003ac2:	8b2e                	mv	s6,a1
    80003ac4:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003ac6:	00054703          	lbu	a4,0(a0)
    80003aca:	02f00793          	li	a5,47
    80003ace:	00f70f63          	beq	a4,a5,80003aec <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003ad2:	e43fd0ef          	jal	80001914 <myproc>
    80003ad6:	15053503          	ld	a0,336(a0)
    80003ada:	a85ff0ef          	jal	8000355e <idup>
    80003ade:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003ae0:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003ae4:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003ae6:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003ae8:	4b85                	li	s7,1
    80003aea:	a879                	j	80003b88 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80003aec:	4585                	li	a1,1
    80003aee:	852e                	mv	a0,a1
    80003af0:	fc4ff0ef          	jal	800032b4 <iget>
    80003af4:	8a2a                	mv	s4,a0
    80003af6:	b7ed                	j	80003ae0 <namex+0x3c>
      iunlockput(ip);
    80003af8:	8552                	mv	a0,s4
    80003afa:	ca5ff0ef          	jal	8000379e <iunlockput>
      return 0;
    80003afe:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003b00:	8552                	mv	a0,s4
    80003b02:	60e6                	ld	ra,88(sp)
    80003b04:	6446                	ld	s0,80(sp)
    80003b06:	64a6                	ld	s1,72(sp)
    80003b08:	6906                	ld	s2,64(sp)
    80003b0a:	79e2                	ld	s3,56(sp)
    80003b0c:	7a42                	ld	s4,48(sp)
    80003b0e:	7aa2                	ld	s5,40(sp)
    80003b10:	7b02                	ld	s6,32(sp)
    80003b12:	6be2                	ld	s7,24(sp)
    80003b14:	6c42                	ld	s8,16(sp)
    80003b16:	6ca2                	ld	s9,8(sp)
    80003b18:	6d02                	ld	s10,0(sp)
    80003b1a:	6125                	addi	sp,sp,96
    80003b1c:	8082                	ret
      iunlock(ip);
    80003b1e:	8552                	mv	a0,s4
    80003b20:	b23ff0ef          	jal	80003642 <iunlock>
      return ip;
    80003b24:	bff1                	j	80003b00 <namex+0x5c>
      iunlockput(ip);
    80003b26:	8552                	mv	a0,s4
    80003b28:	c77ff0ef          	jal	8000379e <iunlockput>
      return 0;
    80003b2c:	8a4e                	mv	s4,s3
    80003b2e:	bfc9                	j	80003b00 <namex+0x5c>
  len = path - s;
    80003b30:	40998633          	sub	a2,s3,s1
    80003b34:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003b38:	09ac5063          	bge	s8,s10,80003bb8 <namex+0x114>
    memmove(name, s, DIRSIZ);
    80003b3c:	8666                	mv	a2,s9
    80003b3e:	85a6                	mv	a1,s1
    80003b40:	8556                	mv	a0,s5
    80003b42:	a28fd0ef          	jal	80000d6a <memmove>
    80003b46:	84ce                	mv	s1,s3
  while(*path == '/')
    80003b48:	0004c783          	lbu	a5,0(s1)
    80003b4c:	01279763          	bne	a5,s2,80003b5a <namex+0xb6>
    path++;
    80003b50:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003b52:	0004c783          	lbu	a5,0(s1)
    80003b56:	ff278de3          	beq	a5,s2,80003b50 <namex+0xac>
    ilock(ip);
    80003b5a:	8552                	mv	a0,s4
    80003b5c:	a39ff0ef          	jal	80003594 <ilock>
    if(ip->type != T_DIR){
    80003b60:	044a1783          	lh	a5,68(s4)
    80003b64:	f9779ae3          	bne	a5,s7,80003af8 <namex+0x54>
    if(nameiparent && *path == '\0'){
    80003b68:	000b0563          	beqz	s6,80003b72 <namex+0xce>
    80003b6c:	0004c783          	lbu	a5,0(s1)
    80003b70:	d7dd                	beqz	a5,80003b1e <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003b72:	4601                	li	a2,0
    80003b74:	85d6                	mv	a1,s5
    80003b76:	8552                	mv	a0,s4
    80003b78:	e81ff0ef          	jal	800039f8 <dirlookup>
    80003b7c:	89aa                	mv	s3,a0
    80003b7e:	d545                	beqz	a0,80003b26 <namex+0x82>
    iunlockput(ip);
    80003b80:	8552                	mv	a0,s4
    80003b82:	c1dff0ef          	jal	8000379e <iunlockput>
    ip = next;
    80003b86:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003b88:	0004c783          	lbu	a5,0(s1)
    80003b8c:	01279763          	bne	a5,s2,80003b9a <namex+0xf6>
    path++;
    80003b90:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003b92:	0004c783          	lbu	a5,0(s1)
    80003b96:	ff278de3          	beq	a5,s2,80003b90 <namex+0xec>
  if(*path == 0)
    80003b9a:	cb8d                	beqz	a5,80003bcc <namex+0x128>
  while(*path != '/' && *path != 0)
    80003b9c:	0004c783          	lbu	a5,0(s1)
    80003ba0:	89a6                	mv	s3,s1
  len = path - s;
    80003ba2:	4d01                	li	s10,0
    80003ba4:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003ba6:	01278963          	beq	a5,s2,80003bb8 <namex+0x114>
    80003baa:	d3d9                	beqz	a5,80003b30 <namex+0x8c>
    path++;
    80003bac:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003bae:	0009c783          	lbu	a5,0(s3)
    80003bb2:	ff279ce3          	bne	a5,s2,80003baa <namex+0x106>
    80003bb6:	bfad                	j	80003b30 <namex+0x8c>
    memmove(name, s, len);
    80003bb8:	2601                	sext.w	a2,a2
    80003bba:	85a6                	mv	a1,s1
    80003bbc:	8556                	mv	a0,s5
    80003bbe:	9acfd0ef          	jal	80000d6a <memmove>
    name[len] = 0;
    80003bc2:	9d56                	add	s10,s10,s5
    80003bc4:	000d0023          	sb	zero,0(s10)
    80003bc8:	84ce                	mv	s1,s3
    80003bca:	bfbd                	j	80003b48 <namex+0xa4>
  if(nameiparent){
    80003bcc:	f20b0ae3          	beqz	s6,80003b00 <namex+0x5c>
    iput(ip);
    80003bd0:	8552                	mv	a0,s4
    80003bd2:	b45ff0ef          	jal	80003716 <iput>
    return 0;
    80003bd6:	4a01                	li	s4,0
    80003bd8:	b725                	j	80003b00 <namex+0x5c>

0000000080003bda <dirlink>:
{
    80003bda:	715d                	addi	sp,sp,-80
    80003bdc:	e486                	sd	ra,72(sp)
    80003bde:	e0a2                	sd	s0,64(sp)
    80003be0:	f84a                	sd	s2,48(sp)
    80003be2:	ec56                	sd	s5,24(sp)
    80003be4:	e85a                	sd	s6,16(sp)
    80003be6:	0880                	addi	s0,sp,80
    80003be8:	892a                	mv	s2,a0
    80003bea:	8aae                	mv	s5,a1
    80003bec:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003bee:	4601                	li	a2,0
    80003bf0:	e09ff0ef          	jal	800039f8 <dirlookup>
    80003bf4:	ed1d                	bnez	a0,80003c32 <dirlink+0x58>
    80003bf6:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bf8:	04c92483          	lw	s1,76(s2)
    80003bfc:	c4b9                	beqz	s1,80003c4a <dirlink+0x70>
    80003bfe:	f44e                	sd	s3,40(sp)
    80003c00:	f052                	sd	s4,32(sp)
    80003c02:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c04:	fb040a13          	addi	s4,s0,-80
    80003c08:	49c1                	li	s3,16
    80003c0a:	874e                	mv	a4,s3
    80003c0c:	86a6                	mv	a3,s1
    80003c0e:	8652                	mv	a2,s4
    80003c10:	4581                	li	a1,0
    80003c12:	854a                	mv	a0,s2
    80003c14:	bd9ff0ef          	jal	800037ec <readi>
    80003c18:	03351163          	bne	a0,s3,80003c3a <dirlink+0x60>
    if(de.inum == 0)
    80003c1c:	fb045783          	lhu	a5,-80(s0)
    80003c20:	c39d                	beqz	a5,80003c46 <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c22:	24c1                	addiw	s1,s1,16
    80003c24:	04c92783          	lw	a5,76(s2)
    80003c28:	fef4e1e3          	bltu	s1,a5,80003c0a <dirlink+0x30>
    80003c2c:	79a2                	ld	s3,40(sp)
    80003c2e:	7a02                	ld	s4,32(sp)
    80003c30:	a829                	j	80003c4a <dirlink+0x70>
    iput(ip);
    80003c32:	ae5ff0ef          	jal	80003716 <iput>
    return -1;
    80003c36:	557d                	li	a0,-1
    80003c38:	a83d                	j	80003c76 <dirlink+0x9c>
      panic("dirlink read");
    80003c3a:	00004517          	auipc	a0,0x4
    80003c3e:	90e50513          	addi	a0,a0,-1778 # 80007548 <etext+0x548>
    80003c42:	b95fc0ef          	jal	800007d6 <panic>
    80003c46:	79a2                	ld	s3,40(sp)
    80003c48:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003c4a:	4639                	li	a2,14
    80003c4c:	85d6                	mv	a1,s5
    80003c4e:	fb240513          	addi	a0,s0,-78
    80003c52:	9c6fd0ef          	jal	80000e18 <strncpy>
  de.inum = inum;
    80003c56:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c5a:	4741                	li	a4,16
    80003c5c:	86a6                	mv	a3,s1
    80003c5e:	fb040613          	addi	a2,s0,-80
    80003c62:	4581                	li	a1,0
    80003c64:	854a                	mv	a0,s2
    80003c66:	c79ff0ef          	jal	800038de <writei>
    80003c6a:	1541                	addi	a0,a0,-16
    80003c6c:	00a03533          	snez	a0,a0
    80003c70:	40a0053b          	negw	a0,a0
    80003c74:	74e2                	ld	s1,56(sp)
}
    80003c76:	60a6                	ld	ra,72(sp)
    80003c78:	6406                	ld	s0,64(sp)
    80003c7a:	7942                	ld	s2,48(sp)
    80003c7c:	6ae2                	ld	s5,24(sp)
    80003c7e:	6b42                	ld	s6,16(sp)
    80003c80:	6161                	addi	sp,sp,80
    80003c82:	8082                	ret

0000000080003c84 <namei>:

struct inode*
namei(char *path)
{
    80003c84:	1101                	addi	sp,sp,-32
    80003c86:	ec06                	sd	ra,24(sp)
    80003c88:	e822                	sd	s0,16(sp)
    80003c8a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003c8c:	fe040613          	addi	a2,s0,-32
    80003c90:	4581                	li	a1,0
    80003c92:	e13ff0ef          	jal	80003aa4 <namex>
}
    80003c96:	60e2                	ld	ra,24(sp)
    80003c98:	6442                	ld	s0,16(sp)
    80003c9a:	6105                	addi	sp,sp,32
    80003c9c:	8082                	ret

0000000080003c9e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003c9e:	1141                	addi	sp,sp,-16
    80003ca0:	e406                	sd	ra,8(sp)
    80003ca2:	e022                	sd	s0,0(sp)
    80003ca4:	0800                	addi	s0,sp,16
    80003ca6:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003ca8:	4585                	li	a1,1
    80003caa:	dfbff0ef          	jal	80003aa4 <namex>
}
    80003cae:	60a2                	ld	ra,8(sp)
    80003cb0:	6402                	ld	s0,0(sp)
    80003cb2:	0141                	addi	sp,sp,16
    80003cb4:	8082                	ret

0000000080003cb6 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003cb6:	1101                	addi	sp,sp,-32
    80003cb8:	ec06                	sd	ra,24(sp)
    80003cba:	e822                	sd	s0,16(sp)
    80003cbc:	e426                	sd	s1,8(sp)
    80003cbe:	e04a                	sd	s2,0(sp)
    80003cc0:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003cc2:	0001f917          	auipc	s2,0x1f
    80003cc6:	ade90913          	addi	s2,s2,-1314 # 800227a0 <log>
    80003cca:	01892583          	lw	a1,24(s2)
    80003cce:	02892503          	lw	a0,40(s2)
    80003cd2:	9b0ff0ef          	jal	80002e82 <bread>
    80003cd6:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003cd8:	02c92603          	lw	a2,44(s2)
    80003cdc:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003cde:	00c05f63          	blez	a2,80003cfc <write_head+0x46>
    80003ce2:	0001f717          	auipc	a4,0x1f
    80003ce6:	aee70713          	addi	a4,a4,-1298 # 800227d0 <log+0x30>
    80003cea:	87aa                	mv	a5,a0
    80003cec:	060a                	slli	a2,a2,0x2
    80003cee:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003cf0:	4314                	lw	a3,0(a4)
    80003cf2:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003cf4:	0711                	addi	a4,a4,4
    80003cf6:	0791                	addi	a5,a5,4
    80003cf8:	fec79ce3          	bne	a5,a2,80003cf0 <write_head+0x3a>
  }
  bwrite(buf);
    80003cfc:	8526                	mv	a0,s1
    80003cfe:	a5aff0ef          	jal	80002f58 <bwrite>
  brelse(buf);
    80003d02:	8526                	mv	a0,s1
    80003d04:	a86ff0ef          	jal	80002f8a <brelse>
}
    80003d08:	60e2                	ld	ra,24(sp)
    80003d0a:	6442                	ld	s0,16(sp)
    80003d0c:	64a2                	ld	s1,8(sp)
    80003d0e:	6902                	ld	s2,0(sp)
    80003d10:	6105                	addi	sp,sp,32
    80003d12:	8082                	ret

0000000080003d14 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d14:	0001f797          	auipc	a5,0x1f
    80003d18:	ab87a783          	lw	a5,-1352(a5) # 800227cc <log+0x2c>
    80003d1c:	0af05263          	blez	a5,80003dc0 <install_trans+0xac>
{
    80003d20:	715d                	addi	sp,sp,-80
    80003d22:	e486                	sd	ra,72(sp)
    80003d24:	e0a2                	sd	s0,64(sp)
    80003d26:	fc26                	sd	s1,56(sp)
    80003d28:	f84a                	sd	s2,48(sp)
    80003d2a:	f44e                	sd	s3,40(sp)
    80003d2c:	f052                	sd	s4,32(sp)
    80003d2e:	ec56                	sd	s5,24(sp)
    80003d30:	e85a                	sd	s6,16(sp)
    80003d32:	e45e                	sd	s7,8(sp)
    80003d34:	0880                	addi	s0,sp,80
    80003d36:	8b2a                	mv	s6,a0
    80003d38:	0001fa97          	auipc	s5,0x1f
    80003d3c:	a98a8a93          	addi	s5,s5,-1384 # 800227d0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d40:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003d42:	0001f997          	auipc	s3,0x1f
    80003d46:	a5e98993          	addi	s3,s3,-1442 # 800227a0 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003d4a:	40000b93          	li	s7,1024
    80003d4e:	a829                	j	80003d68 <install_trans+0x54>
    brelse(lbuf);
    80003d50:	854a                	mv	a0,s2
    80003d52:	a38ff0ef          	jal	80002f8a <brelse>
    brelse(dbuf);
    80003d56:	8526                	mv	a0,s1
    80003d58:	a32ff0ef          	jal	80002f8a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d5c:	2a05                	addiw	s4,s4,1
    80003d5e:	0a91                	addi	s5,s5,4
    80003d60:	02c9a783          	lw	a5,44(s3)
    80003d64:	04fa5363          	bge	s4,a5,80003daa <install_trans+0x96>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003d68:	0189a583          	lw	a1,24(s3)
    80003d6c:	014585bb          	addw	a1,a1,s4
    80003d70:	2585                	addiw	a1,a1,1
    80003d72:	0289a503          	lw	a0,40(s3)
    80003d76:	90cff0ef          	jal	80002e82 <bread>
    80003d7a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003d7c:	000aa583          	lw	a1,0(s5)
    80003d80:	0289a503          	lw	a0,40(s3)
    80003d84:	8feff0ef          	jal	80002e82 <bread>
    80003d88:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003d8a:	865e                	mv	a2,s7
    80003d8c:	05890593          	addi	a1,s2,88
    80003d90:	05850513          	addi	a0,a0,88
    80003d94:	fd7fc0ef          	jal	80000d6a <memmove>
    bwrite(dbuf);  // write dst to disk
    80003d98:	8526                	mv	a0,s1
    80003d9a:	9beff0ef          	jal	80002f58 <bwrite>
    if(recovering == 0)
    80003d9e:	fa0b19e3          	bnez	s6,80003d50 <install_trans+0x3c>
      bunpin(dbuf);
    80003da2:	8526                	mv	a0,s1
    80003da4:	a9eff0ef          	jal	80003042 <bunpin>
    80003da8:	b765                	j	80003d50 <install_trans+0x3c>
}
    80003daa:	60a6                	ld	ra,72(sp)
    80003dac:	6406                	ld	s0,64(sp)
    80003dae:	74e2                	ld	s1,56(sp)
    80003db0:	7942                	ld	s2,48(sp)
    80003db2:	79a2                	ld	s3,40(sp)
    80003db4:	7a02                	ld	s4,32(sp)
    80003db6:	6ae2                	ld	s5,24(sp)
    80003db8:	6b42                	ld	s6,16(sp)
    80003dba:	6ba2                	ld	s7,8(sp)
    80003dbc:	6161                	addi	sp,sp,80
    80003dbe:	8082                	ret
    80003dc0:	8082                	ret

0000000080003dc2 <initlog>:
{
    80003dc2:	7179                	addi	sp,sp,-48
    80003dc4:	f406                	sd	ra,40(sp)
    80003dc6:	f022                	sd	s0,32(sp)
    80003dc8:	ec26                	sd	s1,24(sp)
    80003dca:	e84a                	sd	s2,16(sp)
    80003dcc:	e44e                	sd	s3,8(sp)
    80003dce:	1800                	addi	s0,sp,48
    80003dd0:	892a                	mv	s2,a0
    80003dd2:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003dd4:	0001f497          	auipc	s1,0x1f
    80003dd8:	9cc48493          	addi	s1,s1,-1588 # 800227a0 <log>
    80003ddc:	00003597          	auipc	a1,0x3
    80003de0:	77c58593          	addi	a1,a1,1916 # 80007558 <etext+0x558>
    80003de4:	8526                	mv	a0,s1
    80003de6:	dcdfc0ef          	jal	80000bb2 <initlock>
  log.start = sb->logstart;
    80003dea:	0149a583          	lw	a1,20(s3)
    80003dee:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003df0:	0109a783          	lw	a5,16(s3)
    80003df4:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003df6:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003dfa:	854a                	mv	a0,s2
    80003dfc:	886ff0ef          	jal	80002e82 <bread>
  log.lh.n = lh->n;
    80003e00:	4d30                	lw	a2,88(a0)
    80003e02:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003e04:	00c05f63          	blez	a2,80003e22 <initlog+0x60>
    80003e08:	87aa                	mv	a5,a0
    80003e0a:	0001f717          	auipc	a4,0x1f
    80003e0e:	9c670713          	addi	a4,a4,-1594 # 800227d0 <log+0x30>
    80003e12:	060a                	slli	a2,a2,0x2
    80003e14:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003e16:	4ff4                	lw	a3,92(a5)
    80003e18:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003e1a:	0791                	addi	a5,a5,4
    80003e1c:	0711                	addi	a4,a4,4
    80003e1e:	fec79ce3          	bne	a5,a2,80003e16 <initlog+0x54>
  brelse(buf);
    80003e22:	968ff0ef          	jal	80002f8a <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003e26:	4505                	li	a0,1
    80003e28:	eedff0ef          	jal	80003d14 <install_trans>
  log.lh.n = 0;
    80003e2c:	0001f797          	auipc	a5,0x1f
    80003e30:	9a07a023          	sw	zero,-1632(a5) # 800227cc <log+0x2c>
  write_head(); // clear the log
    80003e34:	e83ff0ef          	jal	80003cb6 <write_head>
}
    80003e38:	70a2                	ld	ra,40(sp)
    80003e3a:	7402                	ld	s0,32(sp)
    80003e3c:	64e2                	ld	s1,24(sp)
    80003e3e:	6942                	ld	s2,16(sp)
    80003e40:	69a2                	ld	s3,8(sp)
    80003e42:	6145                	addi	sp,sp,48
    80003e44:	8082                	ret

0000000080003e46 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003e46:	1101                	addi	sp,sp,-32
    80003e48:	ec06                	sd	ra,24(sp)
    80003e4a:	e822                	sd	s0,16(sp)
    80003e4c:	e426                	sd	s1,8(sp)
    80003e4e:	e04a                	sd	s2,0(sp)
    80003e50:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003e52:	0001f517          	auipc	a0,0x1f
    80003e56:	94e50513          	addi	a0,a0,-1714 # 800227a0 <log>
    80003e5a:	dddfc0ef          	jal	80000c36 <acquire>
  while(1){
    if(log.committing){
    80003e5e:	0001f497          	auipc	s1,0x1f
    80003e62:	94248493          	addi	s1,s1,-1726 # 800227a0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003e66:	4979                	li	s2,30
    80003e68:	a029                	j	80003e72 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003e6a:	85a6                	mv	a1,s1
    80003e6c:	8526                	mv	a0,s1
    80003e6e:	874fe0ef          	jal	80001ee2 <sleep>
    if(log.committing){
    80003e72:	50dc                	lw	a5,36(s1)
    80003e74:	fbfd                	bnez	a5,80003e6a <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003e76:	5098                	lw	a4,32(s1)
    80003e78:	2705                	addiw	a4,a4,1
    80003e7a:	0027179b          	slliw	a5,a4,0x2
    80003e7e:	9fb9                	addw	a5,a5,a4
    80003e80:	0017979b          	slliw	a5,a5,0x1
    80003e84:	54d4                	lw	a3,44(s1)
    80003e86:	9fb5                	addw	a5,a5,a3
    80003e88:	00f95763          	bge	s2,a5,80003e96 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003e8c:	85a6                	mv	a1,s1
    80003e8e:	8526                	mv	a0,s1
    80003e90:	852fe0ef          	jal	80001ee2 <sleep>
    80003e94:	bff9                	j	80003e72 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003e96:	0001f517          	auipc	a0,0x1f
    80003e9a:	90a50513          	addi	a0,a0,-1782 # 800227a0 <log>
    80003e9e:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80003ea0:	e2bfc0ef          	jal	80000cca <release>
      break;
    }
  }
}
    80003ea4:	60e2                	ld	ra,24(sp)
    80003ea6:	6442                	ld	s0,16(sp)
    80003ea8:	64a2                	ld	s1,8(sp)
    80003eaa:	6902                	ld	s2,0(sp)
    80003eac:	6105                	addi	sp,sp,32
    80003eae:	8082                	ret

0000000080003eb0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003eb0:	7139                	addi	sp,sp,-64
    80003eb2:	fc06                	sd	ra,56(sp)
    80003eb4:	f822                	sd	s0,48(sp)
    80003eb6:	f426                	sd	s1,40(sp)
    80003eb8:	f04a                	sd	s2,32(sp)
    80003eba:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003ebc:	0001f497          	auipc	s1,0x1f
    80003ec0:	8e448493          	addi	s1,s1,-1820 # 800227a0 <log>
    80003ec4:	8526                	mv	a0,s1
    80003ec6:	d71fc0ef          	jal	80000c36 <acquire>
  log.outstanding -= 1;
    80003eca:	509c                	lw	a5,32(s1)
    80003ecc:	37fd                	addiw	a5,a5,-1
    80003ece:	893e                	mv	s2,a5
    80003ed0:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003ed2:	50dc                	lw	a5,36(s1)
    80003ed4:	ef9d                	bnez	a5,80003f12 <end_op+0x62>
    panic("log.committing");
  if(log.outstanding == 0){
    80003ed6:	04091863          	bnez	s2,80003f26 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003eda:	0001f497          	auipc	s1,0x1f
    80003ede:	8c648493          	addi	s1,s1,-1850 # 800227a0 <log>
    80003ee2:	4785                	li	a5,1
    80003ee4:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003ee6:	8526                	mv	a0,s1
    80003ee8:	de3fc0ef          	jal	80000cca <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003eec:	54dc                	lw	a5,44(s1)
    80003eee:	04f04c63          	bgtz	a5,80003f46 <end_op+0x96>
    acquire(&log.lock);
    80003ef2:	0001f497          	auipc	s1,0x1f
    80003ef6:	8ae48493          	addi	s1,s1,-1874 # 800227a0 <log>
    80003efa:	8526                	mv	a0,s1
    80003efc:	d3bfc0ef          	jal	80000c36 <acquire>
    log.committing = 0;
    80003f00:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003f04:	8526                	mv	a0,s1
    80003f06:	828fe0ef          	jal	80001f2e <wakeup>
    release(&log.lock);
    80003f0a:	8526                	mv	a0,s1
    80003f0c:	dbffc0ef          	jal	80000cca <release>
}
    80003f10:	a02d                	j	80003f3a <end_op+0x8a>
    80003f12:	ec4e                	sd	s3,24(sp)
    80003f14:	e852                	sd	s4,16(sp)
    80003f16:	e456                	sd	s5,8(sp)
    80003f18:	e05a                	sd	s6,0(sp)
    panic("log.committing");
    80003f1a:	00003517          	auipc	a0,0x3
    80003f1e:	64650513          	addi	a0,a0,1606 # 80007560 <etext+0x560>
    80003f22:	8b5fc0ef          	jal	800007d6 <panic>
    wakeup(&log);
    80003f26:	0001f497          	auipc	s1,0x1f
    80003f2a:	87a48493          	addi	s1,s1,-1926 # 800227a0 <log>
    80003f2e:	8526                	mv	a0,s1
    80003f30:	ffffd0ef          	jal	80001f2e <wakeup>
  release(&log.lock);
    80003f34:	8526                	mv	a0,s1
    80003f36:	d95fc0ef          	jal	80000cca <release>
}
    80003f3a:	70e2                	ld	ra,56(sp)
    80003f3c:	7442                	ld	s0,48(sp)
    80003f3e:	74a2                	ld	s1,40(sp)
    80003f40:	7902                	ld	s2,32(sp)
    80003f42:	6121                	addi	sp,sp,64
    80003f44:	8082                	ret
    80003f46:	ec4e                	sd	s3,24(sp)
    80003f48:	e852                	sd	s4,16(sp)
    80003f4a:	e456                	sd	s5,8(sp)
    80003f4c:	e05a                	sd	s6,0(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f4e:	0001fa97          	auipc	s5,0x1f
    80003f52:	882a8a93          	addi	s5,s5,-1918 # 800227d0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003f56:	0001fa17          	auipc	s4,0x1f
    80003f5a:	84aa0a13          	addi	s4,s4,-1974 # 800227a0 <log>
    memmove(to->data, from->data, BSIZE);
    80003f5e:	40000b13          	li	s6,1024
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003f62:	018a2583          	lw	a1,24(s4)
    80003f66:	012585bb          	addw	a1,a1,s2
    80003f6a:	2585                	addiw	a1,a1,1
    80003f6c:	028a2503          	lw	a0,40(s4)
    80003f70:	f13fe0ef          	jal	80002e82 <bread>
    80003f74:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003f76:	000aa583          	lw	a1,0(s5)
    80003f7a:	028a2503          	lw	a0,40(s4)
    80003f7e:	f05fe0ef          	jal	80002e82 <bread>
    80003f82:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003f84:	865a                	mv	a2,s6
    80003f86:	05850593          	addi	a1,a0,88
    80003f8a:	05848513          	addi	a0,s1,88
    80003f8e:	dddfc0ef          	jal	80000d6a <memmove>
    bwrite(to);  // write the log
    80003f92:	8526                	mv	a0,s1
    80003f94:	fc5fe0ef          	jal	80002f58 <bwrite>
    brelse(from);
    80003f98:	854e                	mv	a0,s3
    80003f9a:	ff1fe0ef          	jal	80002f8a <brelse>
    brelse(to);
    80003f9e:	8526                	mv	a0,s1
    80003fa0:	febfe0ef          	jal	80002f8a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fa4:	2905                	addiw	s2,s2,1
    80003fa6:	0a91                	addi	s5,s5,4
    80003fa8:	02ca2783          	lw	a5,44(s4)
    80003fac:	faf94be3          	blt	s2,a5,80003f62 <end_op+0xb2>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003fb0:	d07ff0ef          	jal	80003cb6 <write_head>
    install_trans(0); // Now install writes to home locations
    80003fb4:	4501                	li	a0,0
    80003fb6:	d5fff0ef          	jal	80003d14 <install_trans>
    log.lh.n = 0;
    80003fba:	0001f797          	auipc	a5,0x1f
    80003fbe:	8007a923          	sw	zero,-2030(a5) # 800227cc <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003fc2:	cf5ff0ef          	jal	80003cb6 <write_head>
    80003fc6:	69e2                	ld	s3,24(sp)
    80003fc8:	6a42                	ld	s4,16(sp)
    80003fca:	6aa2                	ld	s5,8(sp)
    80003fcc:	6b02                	ld	s6,0(sp)
    80003fce:	b715                	j	80003ef2 <end_op+0x42>

0000000080003fd0 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003fd0:	1101                	addi	sp,sp,-32
    80003fd2:	ec06                	sd	ra,24(sp)
    80003fd4:	e822                	sd	s0,16(sp)
    80003fd6:	e426                	sd	s1,8(sp)
    80003fd8:	e04a                	sd	s2,0(sp)
    80003fda:	1000                	addi	s0,sp,32
    80003fdc:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003fde:	0001e917          	auipc	s2,0x1e
    80003fe2:	7c290913          	addi	s2,s2,1986 # 800227a0 <log>
    80003fe6:	854a                	mv	a0,s2
    80003fe8:	c4ffc0ef          	jal	80000c36 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003fec:	02c92603          	lw	a2,44(s2)
    80003ff0:	47f5                	li	a5,29
    80003ff2:	06c7c363          	blt	a5,a2,80004058 <log_write+0x88>
    80003ff6:	0001e797          	auipc	a5,0x1e
    80003ffa:	7c67a783          	lw	a5,1990(a5) # 800227bc <log+0x1c>
    80003ffe:	37fd                	addiw	a5,a5,-1
    80004000:	04f65c63          	bge	a2,a5,80004058 <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004004:	0001e797          	auipc	a5,0x1e
    80004008:	7bc7a783          	lw	a5,1980(a5) # 800227c0 <log+0x20>
    8000400c:	04f05c63          	blez	a5,80004064 <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004010:	4781                	li	a5,0
    80004012:	04c05f63          	blez	a2,80004070 <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004016:	44cc                	lw	a1,12(s1)
    80004018:	0001e717          	auipc	a4,0x1e
    8000401c:	7b870713          	addi	a4,a4,1976 # 800227d0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004020:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004022:	4314                	lw	a3,0(a4)
    80004024:	04b68663          	beq	a3,a1,80004070 <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80004028:	2785                	addiw	a5,a5,1
    8000402a:	0711                	addi	a4,a4,4
    8000402c:	fef61be3          	bne	a2,a5,80004022 <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004030:	0621                	addi	a2,a2,8
    80004032:	060a                	slli	a2,a2,0x2
    80004034:	0001e797          	auipc	a5,0x1e
    80004038:	76c78793          	addi	a5,a5,1900 # 800227a0 <log>
    8000403c:	97b2                	add	a5,a5,a2
    8000403e:	44d8                	lw	a4,12(s1)
    80004040:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004042:	8526                	mv	a0,s1
    80004044:	fcbfe0ef          	jal	8000300e <bpin>
    log.lh.n++;
    80004048:	0001e717          	auipc	a4,0x1e
    8000404c:	75870713          	addi	a4,a4,1880 # 800227a0 <log>
    80004050:	575c                	lw	a5,44(a4)
    80004052:	2785                	addiw	a5,a5,1
    80004054:	d75c                	sw	a5,44(a4)
    80004056:	a80d                	j	80004088 <log_write+0xb8>
    panic("too big a transaction");
    80004058:	00003517          	auipc	a0,0x3
    8000405c:	51850513          	addi	a0,a0,1304 # 80007570 <etext+0x570>
    80004060:	f76fc0ef          	jal	800007d6 <panic>
    panic("log_write outside of trans");
    80004064:	00003517          	auipc	a0,0x3
    80004068:	52450513          	addi	a0,a0,1316 # 80007588 <etext+0x588>
    8000406c:	f6afc0ef          	jal	800007d6 <panic>
  log.lh.block[i] = b->blockno;
    80004070:	00878693          	addi	a3,a5,8
    80004074:	068a                	slli	a3,a3,0x2
    80004076:	0001e717          	auipc	a4,0x1e
    8000407a:	72a70713          	addi	a4,a4,1834 # 800227a0 <log>
    8000407e:	9736                	add	a4,a4,a3
    80004080:	44d4                	lw	a3,12(s1)
    80004082:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004084:	faf60fe3          	beq	a2,a5,80004042 <log_write+0x72>
  }
  release(&log.lock);
    80004088:	0001e517          	auipc	a0,0x1e
    8000408c:	71850513          	addi	a0,a0,1816 # 800227a0 <log>
    80004090:	c3bfc0ef          	jal	80000cca <release>
}
    80004094:	60e2                	ld	ra,24(sp)
    80004096:	6442                	ld	s0,16(sp)
    80004098:	64a2                	ld	s1,8(sp)
    8000409a:	6902                	ld	s2,0(sp)
    8000409c:	6105                	addi	sp,sp,32
    8000409e:	8082                	ret

00000000800040a0 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800040a0:	1101                	addi	sp,sp,-32
    800040a2:	ec06                	sd	ra,24(sp)
    800040a4:	e822                	sd	s0,16(sp)
    800040a6:	e426                	sd	s1,8(sp)
    800040a8:	e04a                	sd	s2,0(sp)
    800040aa:	1000                	addi	s0,sp,32
    800040ac:	84aa                	mv	s1,a0
    800040ae:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800040b0:	00003597          	auipc	a1,0x3
    800040b4:	4f858593          	addi	a1,a1,1272 # 800075a8 <etext+0x5a8>
    800040b8:	0521                	addi	a0,a0,8
    800040ba:	af9fc0ef          	jal	80000bb2 <initlock>
  lk->name = name;
    800040be:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800040c2:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800040c6:	0204a423          	sw	zero,40(s1)
}
    800040ca:	60e2                	ld	ra,24(sp)
    800040cc:	6442                	ld	s0,16(sp)
    800040ce:	64a2                	ld	s1,8(sp)
    800040d0:	6902                	ld	s2,0(sp)
    800040d2:	6105                	addi	sp,sp,32
    800040d4:	8082                	ret

00000000800040d6 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800040d6:	1101                	addi	sp,sp,-32
    800040d8:	ec06                	sd	ra,24(sp)
    800040da:	e822                	sd	s0,16(sp)
    800040dc:	e426                	sd	s1,8(sp)
    800040de:	e04a                	sd	s2,0(sp)
    800040e0:	1000                	addi	s0,sp,32
    800040e2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800040e4:	00850913          	addi	s2,a0,8
    800040e8:	854a                	mv	a0,s2
    800040ea:	b4dfc0ef          	jal	80000c36 <acquire>
  while (lk->locked) {
    800040ee:	409c                	lw	a5,0(s1)
    800040f0:	c799                	beqz	a5,800040fe <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    800040f2:	85ca                	mv	a1,s2
    800040f4:	8526                	mv	a0,s1
    800040f6:	dedfd0ef          	jal	80001ee2 <sleep>
  while (lk->locked) {
    800040fa:	409c                	lw	a5,0(s1)
    800040fc:	fbfd                	bnez	a5,800040f2 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800040fe:	4785                	li	a5,1
    80004100:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004102:	813fd0ef          	jal	80001914 <myproc>
    80004106:	591c                	lw	a5,48(a0)
    80004108:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000410a:	854a                	mv	a0,s2
    8000410c:	bbffc0ef          	jal	80000cca <release>
}
    80004110:	60e2                	ld	ra,24(sp)
    80004112:	6442                	ld	s0,16(sp)
    80004114:	64a2                	ld	s1,8(sp)
    80004116:	6902                	ld	s2,0(sp)
    80004118:	6105                	addi	sp,sp,32
    8000411a:	8082                	ret

000000008000411c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000411c:	1101                	addi	sp,sp,-32
    8000411e:	ec06                	sd	ra,24(sp)
    80004120:	e822                	sd	s0,16(sp)
    80004122:	e426                	sd	s1,8(sp)
    80004124:	e04a                	sd	s2,0(sp)
    80004126:	1000                	addi	s0,sp,32
    80004128:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000412a:	00850913          	addi	s2,a0,8
    8000412e:	854a                	mv	a0,s2
    80004130:	b07fc0ef          	jal	80000c36 <acquire>
  lk->locked = 0;
    80004134:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004138:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000413c:	8526                	mv	a0,s1
    8000413e:	df1fd0ef          	jal	80001f2e <wakeup>
  release(&lk->lk);
    80004142:	854a                	mv	a0,s2
    80004144:	b87fc0ef          	jal	80000cca <release>
}
    80004148:	60e2                	ld	ra,24(sp)
    8000414a:	6442                	ld	s0,16(sp)
    8000414c:	64a2                	ld	s1,8(sp)
    8000414e:	6902                	ld	s2,0(sp)
    80004150:	6105                	addi	sp,sp,32
    80004152:	8082                	ret

0000000080004154 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004154:	7179                	addi	sp,sp,-48
    80004156:	f406                	sd	ra,40(sp)
    80004158:	f022                	sd	s0,32(sp)
    8000415a:	ec26                	sd	s1,24(sp)
    8000415c:	e84a                	sd	s2,16(sp)
    8000415e:	1800                	addi	s0,sp,48
    80004160:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004162:	00850913          	addi	s2,a0,8
    80004166:	854a                	mv	a0,s2
    80004168:	acffc0ef          	jal	80000c36 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000416c:	409c                	lw	a5,0(s1)
    8000416e:	ef81                	bnez	a5,80004186 <holdingsleep+0x32>
    80004170:	4481                	li	s1,0
  release(&lk->lk);
    80004172:	854a                	mv	a0,s2
    80004174:	b57fc0ef          	jal	80000cca <release>
  return r;
}
    80004178:	8526                	mv	a0,s1
    8000417a:	70a2                	ld	ra,40(sp)
    8000417c:	7402                	ld	s0,32(sp)
    8000417e:	64e2                	ld	s1,24(sp)
    80004180:	6942                	ld	s2,16(sp)
    80004182:	6145                	addi	sp,sp,48
    80004184:	8082                	ret
    80004186:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004188:	0284a983          	lw	s3,40(s1)
    8000418c:	f88fd0ef          	jal	80001914 <myproc>
    80004190:	5904                	lw	s1,48(a0)
    80004192:	413484b3          	sub	s1,s1,s3
    80004196:	0014b493          	seqz	s1,s1
    8000419a:	69a2                	ld	s3,8(sp)
    8000419c:	bfd9                	j	80004172 <holdingsleep+0x1e>

000000008000419e <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000419e:	1141                	addi	sp,sp,-16
    800041a0:	e406                	sd	ra,8(sp)
    800041a2:	e022                	sd	s0,0(sp)
    800041a4:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800041a6:	00003597          	auipc	a1,0x3
    800041aa:	41258593          	addi	a1,a1,1042 # 800075b8 <etext+0x5b8>
    800041ae:	0001e517          	auipc	a0,0x1e
    800041b2:	73a50513          	addi	a0,a0,1850 # 800228e8 <ftable>
    800041b6:	9fdfc0ef          	jal	80000bb2 <initlock>
}
    800041ba:	60a2                	ld	ra,8(sp)
    800041bc:	6402                	ld	s0,0(sp)
    800041be:	0141                	addi	sp,sp,16
    800041c0:	8082                	ret

00000000800041c2 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800041c2:	1101                	addi	sp,sp,-32
    800041c4:	ec06                	sd	ra,24(sp)
    800041c6:	e822                	sd	s0,16(sp)
    800041c8:	e426                	sd	s1,8(sp)
    800041ca:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800041cc:	0001e517          	auipc	a0,0x1e
    800041d0:	71c50513          	addi	a0,a0,1820 # 800228e8 <ftable>
    800041d4:	a63fc0ef          	jal	80000c36 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800041d8:	0001e497          	auipc	s1,0x1e
    800041dc:	72848493          	addi	s1,s1,1832 # 80022900 <ftable+0x18>
    800041e0:	0001f717          	auipc	a4,0x1f
    800041e4:	6c070713          	addi	a4,a4,1728 # 800238a0 <disk>
    if(f->ref == 0){
    800041e8:	40dc                	lw	a5,4(s1)
    800041ea:	cf89                	beqz	a5,80004204 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800041ec:	02848493          	addi	s1,s1,40
    800041f0:	fee49ce3          	bne	s1,a4,800041e8 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800041f4:	0001e517          	auipc	a0,0x1e
    800041f8:	6f450513          	addi	a0,a0,1780 # 800228e8 <ftable>
    800041fc:	acffc0ef          	jal	80000cca <release>
  return 0;
    80004200:	4481                	li	s1,0
    80004202:	a809                	j	80004214 <filealloc+0x52>
      f->ref = 1;
    80004204:	4785                	li	a5,1
    80004206:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004208:	0001e517          	auipc	a0,0x1e
    8000420c:	6e050513          	addi	a0,a0,1760 # 800228e8 <ftable>
    80004210:	abbfc0ef          	jal	80000cca <release>
}
    80004214:	8526                	mv	a0,s1
    80004216:	60e2                	ld	ra,24(sp)
    80004218:	6442                	ld	s0,16(sp)
    8000421a:	64a2                	ld	s1,8(sp)
    8000421c:	6105                	addi	sp,sp,32
    8000421e:	8082                	ret

0000000080004220 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004220:	1101                	addi	sp,sp,-32
    80004222:	ec06                	sd	ra,24(sp)
    80004224:	e822                	sd	s0,16(sp)
    80004226:	e426                	sd	s1,8(sp)
    80004228:	1000                	addi	s0,sp,32
    8000422a:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000422c:	0001e517          	auipc	a0,0x1e
    80004230:	6bc50513          	addi	a0,a0,1724 # 800228e8 <ftable>
    80004234:	a03fc0ef          	jal	80000c36 <acquire>
  if(f->ref < 1)
    80004238:	40dc                	lw	a5,4(s1)
    8000423a:	02f05063          	blez	a5,8000425a <filedup+0x3a>
    panic("filedup");
  f->ref++;
    8000423e:	2785                	addiw	a5,a5,1
    80004240:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004242:	0001e517          	auipc	a0,0x1e
    80004246:	6a650513          	addi	a0,a0,1702 # 800228e8 <ftable>
    8000424a:	a81fc0ef          	jal	80000cca <release>
  return f;
}
    8000424e:	8526                	mv	a0,s1
    80004250:	60e2                	ld	ra,24(sp)
    80004252:	6442                	ld	s0,16(sp)
    80004254:	64a2                	ld	s1,8(sp)
    80004256:	6105                	addi	sp,sp,32
    80004258:	8082                	ret
    panic("filedup");
    8000425a:	00003517          	auipc	a0,0x3
    8000425e:	36650513          	addi	a0,a0,870 # 800075c0 <etext+0x5c0>
    80004262:	d74fc0ef          	jal	800007d6 <panic>

0000000080004266 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004266:	7139                	addi	sp,sp,-64
    80004268:	fc06                	sd	ra,56(sp)
    8000426a:	f822                	sd	s0,48(sp)
    8000426c:	f426                	sd	s1,40(sp)
    8000426e:	0080                	addi	s0,sp,64
    80004270:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004272:	0001e517          	auipc	a0,0x1e
    80004276:	67650513          	addi	a0,a0,1654 # 800228e8 <ftable>
    8000427a:	9bdfc0ef          	jal	80000c36 <acquire>
  if(f->ref < 1)
    8000427e:	40dc                	lw	a5,4(s1)
    80004280:	04f05863          	blez	a5,800042d0 <fileclose+0x6a>
    panic("fileclose");
  if(--f->ref > 0){
    80004284:	37fd                	addiw	a5,a5,-1
    80004286:	c0dc                	sw	a5,4(s1)
    80004288:	04f04e63          	bgtz	a5,800042e4 <fileclose+0x7e>
    8000428c:	f04a                	sd	s2,32(sp)
    8000428e:	ec4e                	sd	s3,24(sp)
    80004290:	e852                	sd	s4,16(sp)
    80004292:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004294:	0004a903          	lw	s2,0(s1)
    80004298:	0094ca83          	lbu	s5,9(s1)
    8000429c:	0104ba03          	ld	s4,16(s1)
    800042a0:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800042a4:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800042a8:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800042ac:	0001e517          	auipc	a0,0x1e
    800042b0:	63c50513          	addi	a0,a0,1596 # 800228e8 <ftable>
    800042b4:	a17fc0ef          	jal	80000cca <release>

  if(ff.type == FD_PIPE){
    800042b8:	4785                	li	a5,1
    800042ba:	04f90063          	beq	s2,a5,800042fa <fileclose+0x94>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800042be:	3979                	addiw	s2,s2,-2
    800042c0:	4785                	li	a5,1
    800042c2:	0527f563          	bgeu	a5,s2,8000430c <fileclose+0xa6>
    800042c6:	7902                	ld	s2,32(sp)
    800042c8:	69e2                	ld	s3,24(sp)
    800042ca:	6a42                	ld	s4,16(sp)
    800042cc:	6aa2                	ld	s5,8(sp)
    800042ce:	a00d                	j	800042f0 <fileclose+0x8a>
    800042d0:	f04a                	sd	s2,32(sp)
    800042d2:	ec4e                	sd	s3,24(sp)
    800042d4:	e852                	sd	s4,16(sp)
    800042d6:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800042d8:	00003517          	auipc	a0,0x3
    800042dc:	2f050513          	addi	a0,a0,752 # 800075c8 <etext+0x5c8>
    800042e0:	cf6fc0ef          	jal	800007d6 <panic>
    release(&ftable.lock);
    800042e4:	0001e517          	auipc	a0,0x1e
    800042e8:	60450513          	addi	a0,a0,1540 # 800228e8 <ftable>
    800042ec:	9dffc0ef          	jal	80000cca <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800042f0:	70e2                	ld	ra,56(sp)
    800042f2:	7442                	ld	s0,48(sp)
    800042f4:	74a2                	ld	s1,40(sp)
    800042f6:	6121                	addi	sp,sp,64
    800042f8:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800042fa:	85d6                	mv	a1,s5
    800042fc:	8552                	mv	a0,s4
    800042fe:	340000ef          	jal	8000463e <pipeclose>
    80004302:	7902                	ld	s2,32(sp)
    80004304:	69e2                	ld	s3,24(sp)
    80004306:	6a42                	ld	s4,16(sp)
    80004308:	6aa2                	ld	s5,8(sp)
    8000430a:	b7dd                	j	800042f0 <fileclose+0x8a>
    begin_op();
    8000430c:	b3bff0ef          	jal	80003e46 <begin_op>
    iput(ff.ip);
    80004310:	854e                	mv	a0,s3
    80004312:	c04ff0ef          	jal	80003716 <iput>
    end_op();
    80004316:	b9bff0ef          	jal	80003eb0 <end_op>
    8000431a:	7902                	ld	s2,32(sp)
    8000431c:	69e2                	ld	s3,24(sp)
    8000431e:	6a42                	ld	s4,16(sp)
    80004320:	6aa2                	ld	s5,8(sp)
    80004322:	b7f9                	j	800042f0 <fileclose+0x8a>

0000000080004324 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004324:	715d                	addi	sp,sp,-80
    80004326:	e486                	sd	ra,72(sp)
    80004328:	e0a2                	sd	s0,64(sp)
    8000432a:	fc26                	sd	s1,56(sp)
    8000432c:	f44e                	sd	s3,40(sp)
    8000432e:	0880                	addi	s0,sp,80
    80004330:	84aa                	mv	s1,a0
    80004332:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004334:	de0fd0ef          	jal	80001914 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004338:	409c                	lw	a5,0(s1)
    8000433a:	37f9                	addiw	a5,a5,-2
    8000433c:	4705                	li	a4,1
    8000433e:	04f76263          	bltu	a4,a5,80004382 <filestat+0x5e>
    80004342:	f84a                	sd	s2,48(sp)
    80004344:	f052                	sd	s4,32(sp)
    80004346:	892a                	mv	s2,a0
    ilock(f->ip);
    80004348:	6c88                	ld	a0,24(s1)
    8000434a:	a4aff0ef          	jal	80003594 <ilock>
    stati(f->ip, &st);
    8000434e:	fb840a13          	addi	s4,s0,-72
    80004352:	85d2                	mv	a1,s4
    80004354:	6c88                	ld	a0,24(s1)
    80004356:	c68ff0ef          	jal	800037be <stati>
    iunlock(f->ip);
    8000435a:	6c88                	ld	a0,24(s1)
    8000435c:	ae6ff0ef          	jal	80003642 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004360:	46e1                	li	a3,24
    80004362:	8652                	mv	a2,s4
    80004364:	85ce                	mv	a1,s3
    80004366:	05093503          	ld	a0,80(s2)
    8000436a:	a52fd0ef          	jal	800015bc <copyout>
    8000436e:	41f5551b          	sraiw	a0,a0,0x1f
    80004372:	7942                	ld	s2,48(sp)
    80004374:	7a02                	ld	s4,32(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004376:	60a6                	ld	ra,72(sp)
    80004378:	6406                	ld	s0,64(sp)
    8000437a:	74e2                	ld	s1,56(sp)
    8000437c:	79a2                	ld	s3,40(sp)
    8000437e:	6161                	addi	sp,sp,80
    80004380:	8082                	ret
  return -1;
    80004382:	557d                	li	a0,-1
    80004384:	bfcd                	j	80004376 <filestat+0x52>

0000000080004386 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004386:	7179                	addi	sp,sp,-48
    80004388:	f406                	sd	ra,40(sp)
    8000438a:	f022                	sd	s0,32(sp)
    8000438c:	e84a                	sd	s2,16(sp)
    8000438e:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004390:	00854783          	lbu	a5,8(a0)
    80004394:	cfd1                	beqz	a5,80004430 <fileread+0xaa>
    80004396:	ec26                	sd	s1,24(sp)
    80004398:	e44e                	sd	s3,8(sp)
    8000439a:	84aa                	mv	s1,a0
    8000439c:	89ae                	mv	s3,a1
    8000439e:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800043a0:	411c                	lw	a5,0(a0)
    800043a2:	4705                	li	a4,1
    800043a4:	04e78363          	beq	a5,a4,800043ea <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800043a8:	470d                	li	a4,3
    800043aa:	04e78763          	beq	a5,a4,800043f8 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800043ae:	4709                	li	a4,2
    800043b0:	06e79a63          	bne	a5,a4,80004424 <fileread+0x9e>
    ilock(f->ip);
    800043b4:	6d08                	ld	a0,24(a0)
    800043b6:	9deff0ef          	jal	80003594 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800043ba:	874a                	mv	a4,s2
    800043bc:	5094                	lw	a3,32(s1)
    800043be:	864e                	mv	a2,s3
    800043c0:	4585                	li	a1,1
    800043c2:	6c88                	ld	a0,24(s1)
    800043c4:	c28ff0ef          	jal	800037ec <readi>
    800043c8:	892a                	mv	s2,a0
    800043ca:	00a05563          	blez	a0,800043d4 <fileread+0x4e>
      f->off += r;
    800043ce:	509c                	lw	a5,32(s1)
    800043d0:	9fa9                	addw	a5,a5,a0
    800043d2:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800043d4:	6c88                	ld	a0,24(s1)
    800043d6:	a6cff0ef          	jal	80003642 <iunlock>
    800043da:	64e2                	ld	s1,24(sp)
    800043dc:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800043de:	854a                	mv	a0,s2
    800043e0:	70a2                	ld	ra,40(sp)
    800043e2:	7402                	ld	s0,32(sp)
    800043e4:	6942                	ld	s2,16(sp)
    800043e6:	6145                	addi	sp,sp,48
    800043e8:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800043ea:	6908                	ld	a0,16(a0)
    800043ec:	3a2000ef          	jal	8000478e <piperead>
    800043f0:	892a                	mv	s2,a0
    800043f2:	64e2                	ld	s1,24(sp)
    800043f4:	69a2                	ld	s3,8(sp)
    800043f6:	b7e5                	j	800043de <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800043f8:	02451783          	lh	a5,36(a0)
    800043fc:	03079693          	slli	a3,a5,0x30
    80004400:	92c1                	srli	a3,a3,0x30
    80004402:	4725                	li	a4,9
    80004404:	02d76863          	bltu	a4,a3,80004434 <fileread+0xae>
    80004408:	0792                	slli	a5,a5,0x4
    8000440a:	0001e717          	auipc	a4,0x1e
    8000440e:	43e70713          	addi	a4,a4,1086 # 80022848 <devsw>
    80004412:	97ba                	add	a5,a5,a4
    80004414:	639c                	ld	a5,0(a5)
    80004416:	c39d                	beqz	a5,8000443c <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    80004418:	4505                	li	a0,1
    8000441a:	9782                	jalr	a5
    8000441c:	892a                	mv	s2,a0
    8000441e:	64e2                	ld	s1,24(sp)
    80004420:	69a2                	ld	s3,8(sp)
    80004422:	bf75                	j	800043de <fileread+0x58>
    panic("fileread");
    80004424:	00003517          	auipc	a0,0x3
    80004428:	1b450513          	addi	a0,a0,436 # 800075d8 <etext+0x5d8>
    8000442c:	baafc0ef          	jal	800007d6 <panic>
    return -1;
    80004430:	597d                	li	s2,-1
    80004432:	b775                	j	800043de <fileread+0x58>
      return -1;
    80004434:	597d                	li	s2,-1
    80004436:	64e2                	ld	s1,24(sp)
    80004438:	69a2                	ld	s3,8(sp)
    8000443a:	b755                	j	800043de <fileread+0x58>
    8000443c:	597d                	li	s2,-1
    8000443e:	64e2                	ld	s1,24(sp)
    80004440:	69a2                	ld	s3,8(sp)
    80004442:	bf71                	j	800043de <fileread+0x58>

0000000080004444 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004444:	00954783          	lbu	a5,9(a0)
    80004448:	10078e63          	beqz	a5,80004564 <filewrite+0x120>
{
    8000444c:	711d                	addi	sp,sp,-96
    8000444e:	ec86                	sd	ra,88(sp)
    80004450:	e8a2                	sd	s0,80(sp)
    80004452:	e0ca                	sd	s2,64(sp)
    80004454:	f456                	sd	s5,40(sp)
    80004456:	f05a                	sd	s6,32(sp)
    80004458:	1080                	addi	s0,sp,96
    8000445a:	892a                	mv	s2,a0
    8000445c:	8b2e                	mv	s6,a1
    8000445e:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    80004460:	411c                	lw	a5,0(a0)
    80004462:	4705                	li	a4,1
    80004464:	02e78963          	beq	a5,a4,80004496 <filewrite+0x52>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004468:	470d                	li	a4,3
    8000446a:	02e78a63          	beq	a5,a4,8000449e <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000446e:	4709                	li	a4,2
    80004470:	0ce79e63          	bne	a5,a4,8000454c <filewrite+0x108>
    80004474:	f852                	sd	s4,48(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004476:	0ac05963          	blez	a2,80004528 <filewrite+0xe4>
    8000447a:	e4a6                	sd	s1,72(sp)
    8000447c:	fc4e                	sd	s3,56(sp)
    8000447e:	ec5e                	sd	s7,24(sp)
    80004480:	e862                	sd	s8,16(sp)
    80004482:	e466                	sd	s9,8(sp)
    int i = 0;
    80004484:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    80004486:	6b85                	lui	s7,0x1
    80004488:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000448c:	6c85                	lui	s9,0x1
    8000448e:	c00c8c9b          	addiw	s9,s9,-1024 # c00 <_entry-0x7ffff400>
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004492:	4c05                	li	s8,1
    80004494:	a8ad                	j	8000450e <filewrite+0xca>
    ret = pipewrite(f->pipe, addr, n);
    80004496:	6908                	ld	a0,16(a0)
    80004498:	1fe000ef          	jal	80004696 <pipewrite>
    8000449c:	a04d                	j	8000453e <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000449e:	02451783          	lh	a5,36(a0)
    800044a2:	03079693          	slli	a3,a5,0x30
    800044a6:	92c1                	srli	a3,a3,0x30
    800044a8:	4725                	li	a4,9
    800044aa:	0ad76f63          	bltu	a4,a3,80004568 <filewrite+0x124>
    800044ae:	0792                	slli	a5,a5,0x4
    800044b0:	0001e717          	auipc	a4,0x1e
    800044b4:	39870713          	addi	a4,a4,920 # 80022848 <devsw>
    800044b8:	97ba                	add	a5,a5,a4
    800044ba:	679c                	ld	a5,8(a5)
    800044bc:	cbc5                	beqz	a5,8000456c <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    800044be:	4505                	li	a0,1
    800044c0:	9782                	jalr	a5
    800044c2:	a8b5                	j	8000453e <filewrite+0xfa>
      if(n1 > max)
    800044c4:	2981                	sext.w	s3,s3
      begin_op();
    800044c6:	981ff0ef          	jal	80003e46 <begin_op>
      ilock(f->ip);
    800044ca:	01893503          	ld	a0,24(s2)
    800044ce:	8c6ff0ef          	jal	80003594 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800044d2:	874e                	mv	a4,s3
    800044d4:	02092683          	lw	a3,32(s2)
    800044d8:	016a0633          	add	a2,s4,s6
    800044dc:	85e2                	mv	a1,s8
    800044de:	01893503          	ld	a0,24(s2)
    800044e2:	bfcff0ef          	jal	800038de <writei>
    800044e6:	84aa                	mv	s1,a0
    800044e8:	00a05763          	blez	a0,800044f6 <filewrite+0xb2>
        f->off += r;
    800044ec:	02092783          	lw	a5,32(s2)
    800044f0:	9fa9                	addw	a5,a5,a0
    800044f2:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800044f6:	01893503          	ld	a0,24(s2)
    800044fa:	948ff0ef          	jal	80003642 <iunlock>
      end_op();
    800044fe:	9b3ff0ef          	jal	80003eb0 <end_op>

      if(r != n1){
    80004502:	02999563          	bne	s3,s1,8000452c <filewrite+0xe8>
        // error from writei
        break;
      }
      i += r;
    80004506:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    8000450a:	015a5963          	bge	s4,s5,8000451c <filewrite+0xd8>
      int n1 = n - i;
    8000450e:	414a87bb          	subw	a5,s5,s4
    80004512:	89be                	mv	s3,a5
      if(n1 > max)
    80004514:	fafbd8e3          	bge	s7,a5,800044c4 <filewrite+0x80>
    80004518:	89e6                	mv	s3,s9
    8000451a:	b76d                	j	800044c4 <filewrite+0x80>
    8000451c:	64a6                	ld	s1,72(sp)
    8000451e:	79e2                	ld	s3,56(sp)
    80004520:	6be2                	ld	s7,24(sp)
    80004522:	6c42                	ld	s8,16(sp)
    80004524:	6ca2                	ld	s9,8(sp)
    80004526:	a801                	j	80004536 <filewrite+0xf2>
    int i = 0;
    80004528:	4a01                	li	s4,0
    8000452a:	a031                	j	80004536 <filewrite+0xf2>
    8000452c:	64a6                	ld	s1,72(sp)
    8000452e:	79e2                	ld	s3,56(sp)
    80004530:	6be2                	ld	s7,24(sp)
    80004532:	6c42                	ld	s8,16(sp)
    80004534:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    80004536:	034a9d63          	bne	s5,s4,80004570 <filewrite+0x12c>
    8000453a:	8556                	mv	a0,s5
    8000453c:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000453e:	60e6                	ld	ra,88(sp)
    80004540:	6446                	ld	s0,80(sp)
    80004542:	6906                	ld	s2,64(sp)
    80004544:	7aa2                	ld	s5,40(sp)
    80004546:	7b02                	ld	s6,32(sp)
    80004548:	6125                	addi	sp,sp,96
    8000454a:	8082                	ret
    8000454c:	e4a6                	sd	s1,72(sp)
    8000454e:	fc4e                	sd	s3,56(sp)
    80004550:	f852                	sd	s4,48(sp)
    80004552:	ec5e                	sd	s7,24(sp)
    80004554:	e862                	sd	s8,16(sp)
    80004556:	e466                	sd	s9,8(sp)
    panic("filewrite");
    80004558:	00003517          	auipc	a0,0x3
    8000455c:	09050513          	addi	a0,a0,144 # 800075e8 <etext+0x5e8>
    80004560:	a76fc0ef          	jal	800007d6 <panic>
    return -1;
    80004564:	557d                	li	a0,-1
}
    80004566:	8082                	ret
      return -1;
    80004568:	557d                	li	a0,-1
    8000456a:	bfd1                	j	8000453e <filewrite+0xfa>
    8000456c:	557d                	li	a0,-1
    8000456e:	bfc1                	j	8000453e <filewrite+0xfa>
    ret = (i == n ? n : -1);
    80004570:	557d                	li	a0,-1
    80004572:	7a42                	ld	s4,48(sp)
    80004574:	b7e9                	j	8000453e <filewrite+0xfa>

0000000080004576 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004576:	7179                	addi	sp,sp,-48
    80004578:	f406                	sd	ra,40(sp)
    8000457a:	f022                	sd	s0,32(sp)
    8000457c:	ec26                	sd	s1,24(sp)
    8000457e:	e052                	sd	s4,0(sp)
    80004580:	1800                	addi	s0,sp,48
    80004582:	84aa                	mv	s1,a0
    80004584:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004586:	0005b023          	sd	zero,0(a1)
    8000458a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000458e:	c35ff0ef          	jal	800041c2 <filealloc>
    80004592:	e088                	sd	a0,0(s1)
    80004594:	c549                	beqz	a0,8000461e <pipealloc+0xa8>
    80004596:	c2dff0ef          	jal	800041c2 <filealloc>
    8000459a:	00aa3023          	sd	a0,0(s4)
    8000459e:	cd25                	beqz	a0,80004616 <pipealloc+0xa0>
    800045a0:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800045a2:	dc0fc0ef          	jal	80000b62 <kalloc>
    800045a6:	892a                	mv	s2,a0
    800045a8:	c12d                	beqz	a0,8000460a <pipealloc+0x94>
    800045aa:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800045ac:	4985                	li	s3,1
    800045ae:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800045b2:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800045b6:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800045ba:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800045be:	00003597          	auipc	a1,0x3
    800045c2:	03a58593          	addi	a1,a1,58 # 800075f8 <etext+0x5f8>
    800045c6:	decfc0ef          	jal	80000bb2 <initlock>
  (*f0)->type = FD_PIPE;
    800045ca:	609c                	ld	a5,0(s1)
    800045cc:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800045d0:	609c                	ld	a5,0(s1)
    800045d2:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800045d6:	609c                	ld	a5,0(s1)
    800045d8:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800045dc:	609c                	ld	a5,0(s1)
    800045de:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800045e2:	000a3783          	ld	a5,0(s4)
    800045e6:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800045ea:	000a3783          	ld	a5,0(s4)
    800045ee:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800045f2:	000a3783          	ld	a5,0(s4)
    800045f6:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800045fa:	000a3783          	ld	a5,0(s4)
    800045fe:	0127b823          	sd	s2,16(a5)
  return 0;
    80004602:	4501                	li	a0,0
    80004604:	6942                	ld	s2,16(sp)
    80004606:	69a2                	ld	s3,8(sp)
    80004608:	a01d                	j	8000462e <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000460a:	6088                	ld	a0,0(s1)
    8000460c:	c119                	beqz	a0,80004612 <pipealloc+0x9c>
    8000460e:	6942                	ld	s2,16(sp)
    80004610:	a029                	j	8000461a <pipealloc+0xa4>
    80004612:	6942                	ld	s2,16(sp)
    80004614:	a029                	j	8000461e <pipealloc+0xa8>
    80004616:	6088                	ld	a0,0(s1)
    80004618:	c10d                	beqz	a0,8000463a <pipealloc+0xc4>
    fileclose(*f0);
    8000461a:	c4dff0ef          	jal	80004266 <fileclose>
  if(*f1)
    8000461e:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004622:	557d                	li	a0,-1
  if(*f1)
    80004624:	c789                	beqz	a5,8000462e <pipealloc+0xb8>
    fileclose(*f1);
    80004626:	853e                	mv	a0,a5
    80004628:	c3fff0ef          	jal	80004266 <fileclose>
  return -1;
    8000462c:	557d                	li	a0,-1
}
    8000462e:	70a2                	ld	ra,40(sp)
    80004630:	7402                	ld	s0,32(sp)
    80004632:	64e2                	ld	s1,24(sp)
    80004634:	6a02                	ld	s4,0(sp)
    80004636:	6145                	addi	sp,sp,48
    80004638:	8082                	ret
  return -1;
    8000463a:	557d                	li	a0,-1
    8000463c:	bfcd                	j	8000462e <pipealloc+0xb8>

000000008000463e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000463e:	1101                	addi	sp,sp,-32
    80004640:	ec06                	sd	ra,24(sp)
    80004642:	e822                	sd	s0,16(sp)
    80004644:	e426                	sd	s1,8(sp)
    80004646:	e04a                	sd	s2,0(sp)
    80004648:	1000                	addi	s0,sp,32
    8000464a:	84aa                	mv	s1,a0
    8000464c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000464e:	de8fc0ef          	jal	80000c36 <acquire>
  if(writable){
    80004652:	02090763          	beqz	s2,80004680 <pipeclose+0x42>
    pi->writeopen = 0;
    80004656:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000465a:	21848513          	addi	a0,s1,536
    8000465e:	8d1fd0ef          	jal	80001f2e <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004662:	2204b783          	ld	a5,544(s1)
    80004666:	e785                	bnez	a5,8000468e <pipeclose+0x50>
    release(&pi->lock);
    80004668:	8526                	mv	a0,s1
    8000466a:	e60fc0ef          	jal	80000cca <release>
    kfree((char*)pi);
    8000466e:	8526                	mv	a0,s1
    80004670:	c10fc0ef          	jal	80000a80 <kfree>
  } else
    release(&pi->lock);
}
    80004674:	60e2                	ld	ra,24(sp)
    80004676:	6442                	ld	s0,16(sp)
    80004678:	64a2                	ld	s1,8(sp)
    8000467a:	6902                	ld	s2,0(sp)
    8000467c:	6105                	addi	sp,sp,32
    8000467e:	8082                	ret
    pi->readopen = 0;
    80004680:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004684:	21c48513          	addi	a0,s1,540
    80004688:	8a7fd0ef          	jal	80001f2e <wakeup>
    8000468c:	bfd9                	j	80004662 <pipeclose+0x24>
    release(&pi->lock);
    8000468e:	8526                	mv	a0,s1
    80004690:	e3afc0ef          	jal	80000cca <release>
}
    80004694:	b7c5                	j	80004674 <pipeclose+0x36>

0000000080004696 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004696:	7159                	addi	sp,sp,-112
    80004698:	f486                	sd	ra,104(sp)
    8000469a:	f0a2                	sd	s0,96(sp)
    8000469c:	eca6                	sd	s1,88(sp)
    8000469e:	e8ca                	sd	s2,80(sp)
    800046a0:	e4ce                	sd	s3,72(sp)
    800046a2:	e0d2                	sd	s4,64(sp)
    800046a4:	fc56                	sd	s5,56(sp)
    800046a6:	1880                	addi	s0,sp,112
    800046a8:	84aa                	mv	s1,a0
    800046aa:	8aae                	mv	s5,a1
    800046ac:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800046ae:	a66fd0ef          	jal	80001914 <myproc>
    800046b2:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800046b4:	8526                	mv	a0,s1
    800046b6:	d80fc0ef          	jal	80000c36 <acquire>
  while(i < n){
    800046ba:	0d405263          	blez	s4,8000477e <pipewrite+0xe8>
    800046be:	f85a                	sd	s6,48(sp)
    800046c0:	f45e                	sd	s7,40(sp)
    800046c2:	f062                	sd	s8,32(sp)
    800046c4:	ec66                	sd	s9,24(sp)
    800046c6:	e86a                	sd	s10,16(sp)
  int i = 0;
    800046c8:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800046ca:	f9f40c13          	addi	s8,s0,-97
    800046ce:	4b85                	li	s7,1
    800046d0:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800046d2:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800046d6:	21c48c93          	addi	s9,s1,540
    800046da:	a82d                	j	80004714 <pipewrite+0x7e>
      release(&pi->lock);
    800046dc:	8526                	mv	a0,s1
    800046de:	decfc0ef          	jal	80000cca <release>
      return -1;
    800046e2:	597d                	li	s2,-1
    800046e4:	7b42                	ld	s6,48(sp)
    800046e6:	7ba2                	ld	s7,40(sp)
    800046e8:	7c02                	ld	s8,32(sp)
    800046ea:	6ce2                	ld	s9,24(sp)
    800046ec:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800046ee:	854a                	mv	a0,s2
    800046f0:	70a6                	ld	ra,104(sp)
    800046f2:	7406                	ld	s0,96(sp)
    800046f4:	64e6                	ld	s1,88(sp)
    800046f6:	6946                	ld	s2,80(sp)
    800046f8:	69a6                	ld	s3,72(sp)
    800046fa:	6a06                	ld	s4,64(sp)
    800046fc:	7ae2                	ld	s5,56(sp)
    800046fe:	6165                	addi	sp,sp,112
    80004700:	8082                	ret
      wakeup(&pi->nread);
    80004702:	856a                	mv	a0,s10
    80004704:	82bfd0ef          	jal	80001f2e <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004708:	85a6                	mv	a1,s1
    8000470a:	8566                	mv	a0,s9
    8000470c:	fd6fd0ef          	jal	80001ee2 <sleep>
  while(i < n){
    80004710:	05495a63          	bge	s2,s4,80004764 <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    80004714:	2204a783          	lw	a5,544(s1)
    80004718:	d3f1                	beqz	a5,800046dc <pipewrite+0x46>
    8000471a:	854e                	mv	a0,s3
    8000471c:	9fffd0ef          	jal	8000211a <killed>
    80004720:	fd55                	bnez	a0,800046dc <pipewrite+0x46>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004722:	2184a783          	lw	a5,536(s1)
    80004726:	21c4a703          	lw	a4,540(s1)
    8000472a:	2007879b          	addiw	a5,a5,512
    8000472e:	fcf70ae3          	beq	a4,a5,80004702 <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004732:	86de                	mv	a3,s7
    80004734:	01590633          	add	a2,s2,s5
    80004738:	85e2                	mv	a1,s8
    8000473a:	0509b503          	ld	a0,80(s3)
    8000473e:	f2ffc0ef          	jal	8000166c <copyin>
    80004742:	05650063          	beq	a0,s6,80004782 <pipewrite+0xec>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004746:	21c4a783          	lw	a5,540(s1)
    8000474a:	0017871b          	addiw	a4,a5,1
    8000474e:	20e4ae23          	sw	a4,540(s1)
    80004752:	1ff7f793          	andi	a5,a5,511
    80004756:	97a6                	add	a5,a5,s1
    80004758:	f9f44703          	lbu	a4,-97(s0)
    8000475c:	00e78c23          	sb	a4,24(a5)
      i++;
    80004760:	2905                	addiw	s2,s2,1
    80004762:	b77d                	j	80004710 <pipewrite+0x7a>
    80004764:	7b42                	ld	s6,48(sp)
    80004766:	7ba2                	ld	s7,40(sp)
    80004768:	7c02                	ld	s8,32(sp)
    8000476a:	6ce2                	ld	s9,24(sp)
    8000476c:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    8000476e:	21848513          	addi	a0,s1,536
    80004772:	fbcfd0ef          	jal	80001f2e <wakeup>
  release(&pi->lock);
    80004776:	8526                	mv	a0,s1
    80004778:	d52fc0ef          	jal	80000cca <release>
  return i;
    8000477c:	bf8d                	j	800046ee <pipewrite+0x58>
  int i = 0;
    8000477e:	4901                	li	s2,0
    80004780:	b7fd                	j	8000476e <pipewrite+0xd8>
    80004782:	7b42                	ld	s6,48(sp)
    80004784:	7ba2                	ld	s7,40(sp)
    80004786:	7c02                	ld	s8,32(sp)
    80004788:	6ce2                	ld	s9,24(sp)
    8000478a:	6d42                	ld	s10,16(sp)
    8000478c:	b7cd                	j	8000476e <pipewrite+0xd8>

000000008000478e <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000478e:	711d                	addi	sp,sp,-96
    80004790:	ec86                	sd	ra,88(sp)
    80004792:	e8a2                	sd	s0,80(sp)
    80004794:	e4a6                	sd	s1,72(sp)
    80004796:	e0ca                	sd	s2,64(sp)
    80004798:	fc4e                	sd	s3,56(sp)
    8000479a:	f852                	sd	s4,48(sp)
    8000479c:	f456                	sd	s5,40(sp)
    8000479e:	1080                	addi	s0,sp,96
    800047a0:	84aa                	mv	s1,a0
    800047a2:	892e                	mv	s2,a1
    800047a4:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800047a6:	96efd0ef          	jal	80001914 <myproc>
    800047aa:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800047ac:	8526                	mv	a0,s1
    800047ae:	c88fc0ef          	jal	80000c36 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800047b2:	2184a703          	lw	a4,536(s1)
    800047b6:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800047ba:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800047be:	02f71763          	bne	a4,a5,800047ec <piperead+0x5e>
    800047c2:	2244a783          	lw	a5,548(s1)
    800047c6:	cf85                	beqz	a5,800047fe <piperead+0x70>
    if(killed(pr)){
    800047c8:	8552                	mv	a0,s4
    800047ca:	951fd0ef          	jal	8000211a <killed>
    800047ce:	e11d                	bnez	a0,800047f4 <piperead+0x66>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800047d0:	85a6                	mv	a1,s1
    800047d2:	854e                	mv	a0,s3
    800047d4:	f0efd0ef          	jal	80001ee2 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800047d8:	2184a703          	lw	a4,536(s1)
    800047dc:	21c4a783          	lw	a5,540(s1)
    800047e0:	fef701e3          	beq	a4,a5,800047c2 <piperead+0x34>
    800047e4:	f05a                	sd	s6,32(sp)
    800047e6:	ec5e                	sd	s7,24(sp)
    800047e8:	e862                	sd	s8,16(sp)
    800047ea:	a829                	j	80004804 <piperead+0x76>
    800047ec:	f05a                	sd	s6,32(sp)
    800047ee:	ec5e                	sd	s7,24(sp)
    800047f0:	e862                	sd	s8,16(sp)
    800047f2:	a809                	j	80004804 <piperead+0x76>
      release(&pi->lock);
    800047f4:	8526                	mv	a0,s1
    800047f6:	cd4fc0ef          	jal	80000cca <release>
      return -1;
    800047fa:	59fd                	li	s3,-1
    800047fc:	a0a5                	j	80004864 <piperead+0xd6>
    800047fe:	f05a                	sd	s6,32(sp)
    80004800:	ec5e                	sd	s7,24(sp)
    80004802:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004804:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004806:	faf40c13          	addi	s8,s0,-81
    8000480a:	4b85                	li	s7,1
    8000480c:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000480e:	05505163          	blez	s5,80004850 <piperead+0xc2>
    if(pi->nread == pi->nwrite)
    80004812:	2184a783          	lw	a5,536(s1)
    80004816:	21c4a703          	lw	a4,540(s1)
    8000481a:	02f70b63          	beq	a4,a5,80004850 <piperead+0xc2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000481e:	0017871b          	addiw	a4,a5,1
    80004822:	20e4ac23          	sw	a4,536(s1)
    80004826:	1ff7f793          	andi	a5,a5,511
    8000482a:	97a6                	add	a5,a5,s1
    8000482c:	0187c783          	lbu	a5,24(a5)
    80004830:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004834:	86de                	mv	a3,s7
    80004836:	8662                	mv	a2,s8
    80004838:	85ca                	mv	a1,s2
    8000483a:	050a3503          	ld	a0,80(s4)
    8000483e:	d7ffc0ef          	jal	800015bc <copyout>
    80004842:	01650763          	beq	a0,s6,80004850 <piperead+0xc2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004846:	2985                	addiw	s3,s3,1
    80004848:	0905                	addi	s2,s2,1
    8000484a:	fd3a94e3          	bne	s5,s3,80004812 <piperead+0x84>
    8000484e:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004850:	21c48513          	addi	a0,s1,540
    80004854:	edafd0ef          	jal	80001f2e <wakeup>
  release(&pi->lock);
    80004858:	8526                	mv	a0,s1
    8000485a:	c70fc0ef          	jal	80000cca <release>
    8000485e:	7b02                	ld	s6,32(sp)
    80004860:	6be2                	ld	s7,24(sp)
    80004862:	6c42                	ld	s8,16(sp)
  return i;
}
    80004864:	854e                	mv	a0,s3
    80004866:	60e6                	ld	ra,88(sp)
    80004868:	6446                	ld	s0,80(sp)
    8000486a:	64a6                	ld	s1,72(sp)
    8000486c:	6906                	ld	s2,64(sp)
    8000486e:	79e2                	ld	s3,56(sp)
    80004870:	7a42                	ld	s4,48(sp)
    80004872:	7aa2                	ld	s5,40(sp)
    80004874:	6125                	addi	sp,sp,96
    80004876:	8082                	ret

0000000080004878 <loadseg>:
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004878:	cf2d                	beqz	a4,800048f2 <loadseg+0x7a>
{
    8000487a:	711d                	addi	sp,sp,-96
    8000487c:	ec86                	sd	ra,88(sp)
    8000487e:	e8a2                	sd	s0,80(sp)
    80004880:	e4a6                	sd	s1,72(sp)
    80004882:	e0ca                	sd	s2,64(sp)
    80004884:	fc4e                	sd	s3,56(sp)
    80004886:	f852                	sd	s4,48(sp)
    80004888:	f456                	sd	s5,40(sp)
    8000488a:	f05a                	sd	s6,32(sp)
    8000488c:	ec5e                	sd	s7,24(sp)
    8000488e:	e862                	sd	s8,16(sp)
    80004890:	e466                	sd	s9,8(sp)
    80004892:	1080                	addi	s0,sp,96
    80004894:	8aaa                	mv	s5,a0
    80004896:	8b2e                	mv	s6,a1
    80004898:	8bb2                	mv	s7,a2
    8000489a:	8c36                	mv	s8,a3
    8000489c:	89ba                	mv	s3,a4
  for(i = 0; i < sz; i += PGSIZE){
    8000489e:	4481                	li	s1,0
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    800048a0:	6c85                	lui	s9,0x1
    800048a2:	6a05                	lui	s4,0x1
    800048a4:	a02d                	j	800048ce <loadseg+0x56>
      panic("loadseg: address should exist");
    800048a6:	00003517          	auipc	a0,0x3
    800048aa:	d5a50513          	addi	a0,a0,-678 # 80007600 <etext+0x600>
    800048ae:	f29fb0ef          	jal	800007d6 <panic>
    if(sz - i < PGSIZE)
    800048b2:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800048b4:	874a                	mv	a4,s2
    800048b6:	009c06bb          	addw	a3,s8,s1
    800048ba:	4581                	li	a1,0
    800048bc:	855e                	mv	a0,s7
    800048be:	f2ffe0ef          	jal	800037ec <readi>
    800048c2:	03251a63          	bne	a0,s2,800048f6 <loadseg+0x7e>
  for(i = 0; i < sz; i += PGSIZE){
    800048c6:	009a04bb          	addw	s1,s4,s1
    800048ca:	0334f263          	bgeu	s1,s3,800048ee <loadseg+0x76>
    pa = walkaddr(pagetable, va + i);
    800048ce:	02049593          	slli	a1,s1,0x20
    800048d2:	9181                	srli	a1,a1,0x20
    800048d4:	95da                	add	a1,a1,s6
    800048d6:	8556                	mv	a0,s5
    800048d8:	f5cfc0ef          	jal	80001034 <walkaddr>
    800048dc:	862a                	mv	a2,a0
    if(pa == 0)
    800048de:	d561                	beqz	a0,800048a6 <loadseg+0x2e>
    if(sz - i < PGSIZE)
    800048e0:	409987bb          	subw	a5,s3,s1
    800048e4:	893e                	mv	s2,a5
    800048e6:	fcfcf6e3          	bgeu	s9,a5,800048b2 <loadseg+0x3a>
    800048ea:	8952                	mv	s2,s4
    800048ec:	b7d9                	j	800048b2 <loadseg+0x3a>
      return -1;
  }
  
  return 0;
    800048ee:	4501                	li	a0,0
    800048f0:	a021                	j	800048f8 <loadseg+0x80>
    800048f2:	4501                	li	a0,0
}
    800048f4:	8082                	ret
      return -1;
    800048f6:	557d                	li	a0,-1
}
    800048f8:	60e6                	ld	ra,88(sp)
    800048fa:	6446                	ld	s0,80(sp)
    800048fc:	64a6                	ld	s1,72(sp)
    800048fe:	6906                	ld	s2,64(sp)
    80004900:	79e2                	ld	s3,56(sp)
    80004902:	7a42                	ld	s4,48(sp)
    80004904:	7aa2                	ld	s5,40(sp)
    80004906:	7b02                	ld	s6,32(sp)
    80004908:	6be2                	ld	s7,24(sp)
    8000490a:	6c42                	ld	s8,16(sp)
    8000490c:	6ca2                	ld	s9,8(sp)
    8000490e:	6125                	addi	sp,sp,96
    80004910:	8082                	ret

0000000080004912 <flags2perm>:
{
    80004912:	1141                	addi	sp,sp,-16
    80004914:	e406                	sd	ra,8(sp)
    80004916:	e022                	sd	s0,0(sp)
    80004918:	0800                	addi	s0,sp,16
    8000491a:	87aa                	mv	a5,a0
    if(flags & 0x1)
    8000491c:	0035151b          	slliw	a0,a0,0x3
    80004920:	8921                	andi	a0,a0,8
    if(flags & 0x2)
    80004922:	8b89                	andi	a5,a5,2
    80004924:	c399                	beqz	a5,8000492a <flags2perm+0x18>
      perm |= PTE_W;
    80004926:	00456513          	ori	a0,a0,4
}
    8000492a:	60a2                	ld	ra,8(sp)
    8000492c:	6402                	ld	s0,0(sp)
    8000492e:	0141                	addi	sp,sp,16
    80004930:	8082                	ret

0000000080004932 <exec>:
{
    80004932:	7101                	addi	sp,sp,-512
    80004934:	ff86                	sd	ra,504(sp)
    80004936:	fba2                	sd	s0,496(sp)
    80004938:	f3ca                	sd	s2,480(sp)
    8000493a:	ebd2                	sd	s4,464(sp)
    8000493c:	0400                	addi	s0,sp,512
    8000493e:	8a2a                	mv	s4,a0
    80004940:	e0b43423          	sd	a1,-504(s0)
  struct proc *p = myproc();
    80004944:	fd1fc0ef          	jal	80001914 <myproc>
    80004948:	892a                	mv	s2,a0
  begin_op();
    8000494a:	cfcff0ef          	jal	80003e46 <begin_op>
  if((ip = namei(path)) == 0){
    8000494e:	8552                	mv	a0,s4
    80004950:	b34ff0ef          	jal	80003c84 <namei>
    80004954:	c921                	beqz	a0,800049a4 <exec+0x72>
    80004956:	f7a6                	sd	s1,488(sp)
    80004958:	84aa                	mv	s1,a0
  ilock(ip);
    8000495a:	c3bfe0ef          	jal	80003594 <ilock>
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000495e:	04000713          	li	a4,64
    80004962:	4681                	li	a3,0
    80004964:	e5040613          	addi	a2,s0,-432
    80004968:	4581                	li	a1,0
    8000496a:	8526                	mv	a0,s1
    8000496c:	e81fe0ef          	jal	800037ec <readi>
    80004970:	04000793          	li	a5,64
    80004974:	00f51a63          	bne	a0,a5,80004988 <exec+0x56>
  if(elf.magic != ELF_MAGIC)
    80004978:	e5042703          	lw	a4,-432(s0)
    8000497c:	464c47b7          	lui	a5,0x464c4
    80004980:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004984:	02f70463          	beq	a4,a5,800049ac <exec+0x7a>
    iunlockput(ip);
    80004988:	8526                	mv	a0,s1
    8000498a:	e15fe0ef          	jal	8000379e <iunlockput>
    end_op();
    8000498e:	d22ff0ef          	jal	80003eb0 <end_op>
  return -1;
    80004992:	557d                	li	a0,-1
    80004994:	74be                	ld	s1,488(sp)
}
    80004996:	70fe                	ld	ra,504(sp)
    80004998:	745e                	ld	s0,496(sp)
    8000499a:	791e                	ld	s2,480(sp)
    8000499c:	6a5e                	ld	s4,464(sp)
    8000499e:	20010113          	addi	sp,sp,512
    800049a2:	8082                	ret
    end_op();
    800049a4:	d0cff0ef          	jal	80003eb0 <end_op>
    return -1;
    800049a8:	557d                	li	a0,-1
    800049aa:	b7f5                	j	80004996 <exec+0x64>
    800049ac:	ff5e                	sd	s7,440(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    800049ae:	854a                	mv	a0,s2
    800049b0:	80cfd0ef          	jal	800019bc <proc_pagetable>
    800049b4:	8baa                	mv	s7,a0
    800049b6:	20050b63          	beqz	a0,80004bcc <exec+0x29a>
    800049ba:	efce                	sd	s3,472(sp)
    800049bc:	e7d6                	sd	s5,456(sp)
    800049be:	e3da                	sd	s6,448(sp)
    800049c0:	fb62                	sd	s8,432(sp)
    800049c2:	f766                	sd	s9,424(sp)
    800049c4:	f36a                	sd	s10,416(sp)
    800049c6:	ef6e                	sd	s11,408(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800049c8:	e7042683          	lw	a3,-400(s0)
    800049cc:	e8845783          	lhu	a5,-376(s0)
    800049d0:	cbc9                	beqz	a5,80004a62 <exec+0x130>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800049d2:	4d01                	li	s10,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800049d4:	4981                	li	s3,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800049d6:	e1840c13          	addi	s8,s0,-488
    800049da:	03800a93          	li	s5,56
    if(ph.type != ELF_PROG_LOAD)
    800049de:	4c85                	li	s9,1
    if(ph.vaddr % PGSIZE != 0)
    800049e0:	6d85                	lui	s11,0x1
    800049e2:	1dfd                	addi	s11,s11,-1 # fff <_entry-0x7ffff001>
    800049e4:	a801                	j	800049f4 <exec+0xc2>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800049e6:	2985                	addiw	s3,s3,1
    800049e8:	038b069b          	addiw	a3,s6,56
    800049ec:	e8845783          	lhu	a5,-376(s0)
    800049f0:	06f9da63          	bge	s3,a5,80004a64 <exec+0x132>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800049f4:	8b36                	mv	s6,a3
    800049f6:	8756                	mv	a4,s5
    800049f8:	8662                	mv	a2,s8
    800049fa:	4581                	li	a1,0
    800049fc:	8526                	mv	a0,s1
    800049fe:	deffe0ef          	jal	800037ec <readi>
    80004a02:	1d551863          	bne	a0,s5,80004bd2 <exec+0x2a0>
    if(ph.type != ELF_PROG_LOAD)
    80004a06:	e1842783          	lw	a5,-488(s0)
    80004a0a:	fd979ee3          	bne	a5,s9,800049e6 <exec+0xb4>
    if(ph.memsz < ph.filesz)
    80004a0e:	e4043903          	ld	s2,-448(s0)
    80004a12:	e3843783          	ld	a5,-456(s0)
    80004a16:	1af96e63          	bltu	s2,a5,80004bd2 <exec+0x2a0>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004a1a:	e2843783          	ld	a5,-472(s0)
    80004a1e:	993e                	add	s2,s2,a5
    80004a20:	1af96963          	bltu	s2,a5,80004bd2 <exec+0x2a0>
    if(ph.vaddr % PGSIZE != 0)
    80004a24:	01b7f7b3          	and	a5,a5,s11
    80004a28:	1a079563          	bnez	a5,80004bd2 <exec+0x2a0>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004a2c:	e1c42503          	lw	a0,-484(s0)
    80004a30:	ee3ff0ef          	jal	80004912 <flags2perm>
    80004a34:	86aa                	mv	a3,a0
    80004a36:	864a                	mv	a2,s2
    80004a38:	85ea                	mv	a1,s10
    80004a3a:	855e                	mv	a0,s7
    80004a3c:	961fc0ef          	jal	8000139c <uvmalloc>
    80004a40:	892a                	mv	s2,a0
    80004a42:	18050863          	beqz	a0,80004bd2 <exec+0x2a0>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004a46:	e3842703          	lw	a4,-456(s0)
    80004a4a:	e2042683          	lw	a3,-480(s0)
    80004a4e:	8626                	mv	a2,s1
    80004a50:	e2843583          	ld	a1,-472(s0)
    80004a54:	855e                	mv	a0,s7
    80004a56:	e23ff0ef          	jal	80004878 <loadseg>
    80004a5a:	16054b63          	bltz	a0,80004bd0 <exec+0x29e>
    sz = sz1;
    80004a5e:	8d4a                	mv	s10,s2
    80004a60:	b759                	j	800049e6 <exec+0xb4>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004a62:	4d01                	li	s10,0
  iunlockput(ip);
    80004a64:	8526                	mv	a0,s1
    80004a66:	d39fe0ef          	jal	8000379e <iunlockput>
  end_op();
    80004a6a:	c46ff0ef          	jal	80003eb0 <end_op>
  p = myproc();
    80004a6e:	ea7fc0ef          	jal	80001914 <myproc>
    80004a72:	8caa                	mv	s9,a0
  uint64 oldsz = p->sz;
    80004a74:	04853d83          	ld	s11,72(a0)
  sz = PGROUNDUP(sz);
    80004a78:	6985                	lui	s3,0x1
    80004a7a:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004a7c:	99ea                	add	s3,s3,s10
    80004a7e:	77fd                	lui	a5,0xfffff
    80004a80:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004a84:	4691                	li	a3,4
    80004a86:	6609                	lui	a2,0x2
    80004a88:	964e                	add	a2,a2,s3
    80004a8a:	85ce                	mv	a1,s3
    80004a8c:	855e                	mv	a0,s7
    80004a8e:	90ffc0ef          	jal	8000139c <uvmalloc>
    80004a92:	8aaa                	mv	s5,a0
    80004a94:	e105                	bnez	a0,80004ab4 <exec+0x182>
    proc_freepagetable(pagetable, sz);
    80004a96:	85ce                	mv	a1,s3
    80004a98:	855e                	mv	a0,s7
    80004a9a:	fa7fc0ef          	jal	80001a40 <proc_freepagetable>
  return -1;
    80004a9e:	557d                	li	a0,-1
    80004aa0:	74be                	ld	s1,488(sp)
    80004aa2:	69fe                	ld	s3,472(sp)
    80004aa4:	6abe                	ld	s5,456(sp)
    80004aa6:	6b1e                	ld	s6,448(sp)
    80004aa8:	7bfa                	ld	s7,440(sp)
    80004aaa:	7c5a                	ld	s8,432(sp)
    80004aac:	7cba                	ld	s9,424(sp)
    80004aae:	7d1a                	ld	s10,416(sp)
    80004ab0:	6dfa                	ld	s11,408(sp)
    80004ab2:	b5d5                	j	80004996 <exec+0x64>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004ab4:	75f9                	lui	a1,0xffffe
    80004ab6:	95aa                	add	a1,a1,a0
    80004ab8:	855e                	mv	a0,s7
    80004aba:	ad9fc0ef          	jal	80001592 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004abe:	7b7d                	lui	s6,0xfffff
    80004ac0:	9b56                	add	s6,s6,s5
  for(argc = 0; argv[argc]; argc++) {
    80004ac2:	e0843783          	ld	a5,-504(s0)
    80004ac6:	6388                	ld	a0,0(a5)
  sp = sz;
    80004ac8:	8956                	mv	s2,s5
  for(argc = 0; argv[argc]; argc++) {
    80004aca:	4481                	li	s1,0
    ustack[argc] = sp;
    80004acc:	e9040c13          	addi	s8,s0,-368
    if(argc >= MAXARG)
    80004ad0:	02000d13          	li	s10,32
  for(argc = 0; argv[argc]; argc++) {
    80004ad4:	c939                	beqz	a0,80004b2a <exec+0x1f8>
    sp -= strlen(argv[argc]) + 1;
    80004ad6:	bb8fc0ef          	jal	80000e8e <strlen>
    80004ada:	2505                	addiw	a0,a0,1
    80004adc:	40a90533          	sub	a0,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004ae0:	ff057913          	andi	s2,a0,-16
    if(sp < stackbase)
    80004ae4:	11696463          	bltu	s2,s6,80004bec <exec+0x2ba>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004ae8:	e0843783          	ld	a5,-504(s0)
    80004aec:	0007b983          	ld	s3,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb620>
    80004af0:	854e                	mv	a0,s3
    80004af2:	b9cfc0ef          	jal	80000e8e <strlen>
    80004af6:	0015069b          	addiw	a3,a0,1
    80004afa:	864e                	mv	a2,s3
    80004afc:	85ca                	mv	a1,s2
    80004afe:	855e                	mv	a0,s7
    80004b00:	abdfc0ef          	jal	800015bc <copyout>
    80004b04:	0e054663          	bltz	a0,80004bf0 <exec+0x2be>
    ustack[argc] = sp;
    80004b08:	00349793          	slli	a5,s1,0x3
    80004b0c:	97e2                	add	a5,a5,s8
    80004b0e:	0127b023          	sd	s2,0(a5)
  for(argc = 0; argv[argc]; argc++) {
    80004b12:	0485                	addi	s1,s1,1
    80004b14:	e0843783          	ld	a5,-504(s0)
    80004b18:	07a1                	addi	a5,a5,8
    80004b1a:	e0f43423          	sd	a5,-504(s0)
    80004b1e:	6388                	ld	a0,0(a5)
    80004b20:	c509                	beqz	a0,80004b2a <exec+0x1f8>
    if(argc >= MAXARG)
    80004b22:	fba49ae3          	bne	s1,s10,80004ad6 <exec+0x1a4>
  sz = sz1;
    80004b26:	89d6                	mv	s3,s5
    80004b28:	b7bd                	j	80004a96 <exec+0x164>
  ustack[argc] = 0;
    80004b2a:	00349793          	slli	a5,s1,0x3
    80004b2e:	f9078793          	addi	a5,a5,-112
    80004b32:	97a2                	add	a5,a5,s0
    80004b34:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004b38:	00148693          	addi	a3,s1,1
    80004b3c:	068e                	slli	a3,a3,0x3
    80004b3e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004b42:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004b46:	89d6                	mv	s3,s5
  if(sp < stackbase)
    80004b48:	f56967e3          	bltu	s2,s6,80004a96 <exec+0x164>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004b4c:	e9040613          	addi	a2,s0,-368
    80004b50:	85ca                	mv	a1,s2
    80004b52:	855e                	mv	a0,s7
    80004b54:	a69fc0ef          	jal	800015bc <copyout>
    80004b58:	f2054fe3          	bltz	a0,80004a96 <exec+0x164>
  p->trapframe->a1 = sp;
    80004b5c:	058cb783          	ld	a5,88(s9) # 1058 <_entry-0x7fffefa8>
    80004b60:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004b64:	000a4703          	lbu	a4,0(s4) # 1000 <_entry-0x7ffff000>
    80004b68:	cf11                	beqz	a4,80004b84 <exec+0x252>
    80004b6a:	001a0793          	addi	a5,s4,1
    if(*s == '/')
    80004b6e:	02f00693          	li	a3,47
    80004b72:	a029                	j	80004b7c <exec+0x24a>
  for(last=s=path; *s; s++)
    80004b74:	0785                	addi	a5,a5,1
    80004b76:	fff7c703          	lbu	a4,-1(a5)
    80004b7a:	c709                	beqz	a4,80004b84 <exec+0x252>
    if(*s == '/')
    80004b7c:	fed71ce3          	bne	a4,a3,80004b74 <exec+0x242>
      last = s+1;
    80004b80:	8a3e                	mv	s4,a5
    80004b82:	bfcd                	j	80004b74 <exec+0x242>
  safestrcpy(p->name, last, sizeof(p->name));
    80004b84:	4641                	li	a2,16
    80004b86:	85d2                	mv	a1,s4
    80004b88:	158c8513          	addi	a0,s9,344
    80004b8c:	accfc0ef          	jal	80000e58 <safestrcpy>
  oldpagetable = p->pagetable;
    80004b90:	050cb503          	ld	a0,80(s9)
  p->pagetable = pagetable;
    80004b94:	057cb823          	sd	s7,80(s9)
  p->sz = sz;
    80004b98:	055cb423          	sd	s5,72(s9)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004b9c:	058cb783          	ld	a5,88(s9)
    80004ba0:	e6843703          	ld	a4,-408(s0)
    80004ba4:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004ba6:	058cb783          	ld	a5,88(s9)
    80004baa:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004bae:	85ee                	mv	a1,s11
    80004bb0:	e91fc0ef          	jal	80001a40 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004bb4:	0004851b          	sext.w	a0,s1
    80004bb8:	74be                	ld	s1,488(sp)
    80004bba:	69fe                	ld	s3,472(sp)
    80004bbc:	6abe                	ld	s5,456(sp)
    80004bbe:	6b1e                	ld	s6,448(sp)
    80004bc0:	7bfa                	ld	s7,440(sp)
    80004bc2:	7c5a                	ld	s8,432(sp)
    80004bc4:	7cba                	ld	s9,424(sp)
    80004bc6:	7d1a                	ld	s10,416(sp)
    80004bc8:	6dfa                	ld	s11,408(sp)
    80004bca:	b3f1                	j	80004996 <exec+0x64>
    80004bcc:	7bfa                	ld	s7,440(sp)
    80004bce:	bb6d                	j	80004988 <exec+0x56>
    sz = sz1;
    80004bd0:	8d4a                	mv	s10,s2
    proc_freepagetable(pagetable, sz);
    80004bd2:	85ea                	mv	a1,s10
    80004bd4:	855e                	mv	a0,s7
    80004bd6:	e6bfc0ef          	jal	80001a40 <proc_freepagetable>
  if(ip){
    80004bda:	69fe                	ld	s3,472(sp)
    80004bdc:	6abe                	ld	s5,456(sp)
    80004bde:	6b1e                	ld	s6,448(sp)
    80004be0:	7bfa                	ld	s7,440(sp)
    80004be2:	7c5a                	ld	s8,432(sp)
    80004be4:	7cba                	ld	s9,424(sp)
    80004be6:	7d1a                	ld	s10,416(sp)
    80004be8:	6dfa                	ld	s11,408(sp)
    80004bea:	bb79                	j	80004988 <exec+0x56>
  sz = sz1;
    80004bec:	89d6                	mv	s3,s5
    80004bee:	b565                	j	80004a96 <exec+0x164>
    80004bf0:	89d6                	mv	s3,s5
    80004bf2:	b555                	j	80004a96 <exec+0x164>

0000000080004bf4 <spawn>:

int
spawn(char *path)
{
    80004bf4:	df010113          	addi	sp,sp,-528
    80004bf8:	20113423          	sd	ra,520(sp)
    80004bfc:	20813023          	sd	s0,512(sp)
    80004c00:	ffa6                	sd	s1,504(sp)
    80004c02:	0c00                	addi	s0,sp,528
    80004c04:	84aa                	mv	s1,a0
    80004c06:	dea43c23          	sd	a0,-520(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0;
  struct proc *p = myproc();
    80004c0a:	d0bfc0ef          	jal	80001914 <myproc>
  struct proc *np;

  if((np = allocproc()) == 0){
    80004c0e:	ec9fc0ef          	jal	80001ad6 <allocproc>
    80004c12:	2e050d63          	beqz	a0,80004f0c <spawn+0x318>
    80004c16:	f7ce                	sd	s3,488(sp)
    80004c18:	fb6a                	sd	s10,432(sp)
    80004c1a:	8d2a                	mv	s10,a0
    return -1;
  }
  // Release lock immediately since it will not be scheduled until RUNNABLE
  release(&np->lock);
    80004c1c:	8aefc0ef          	jal	80000cca <release>

  char *argv[2];
  argv[0] = path;
  argv[1] = 0;
    80004c20:	e0043823          	sd	zero,-496(s0)

  begin_op();
    80004c24:	a22ff0ef          	jal	80003e46 <begin_op>

  if((ip = namei(path)) == 0){
    80004c28:	8526                	mv	a0,s1
    80004c2a:	85aff0ef          	jal	80003c84 <namei>
    80004c2e:	89aa                	mv	s3,a0
    80004c30:	c135                	beqz	a0,80004c94 <spawn+0xa0>
    acquire(&np->lock);
    freeproc(np);
    release(&np->lock);
    return -1;
  }
  ilock(ip);
    80004c32:	963fe0ef          	jal	80003594 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004c36:	04000713          	li	a4,64
    80004c3a:	4681                	li	a3,0
    80004c3c:	e5040613          	addi	a2,s0,-432
    80004c40:	4581                	li	a1,0
    80004c42:	854e                	mv	a0,s3
    80004c44:	ba9fe0ef          	jal	800037ec <readi>
    80004c48:	04000793          	li	a5,64
    80004c4c:	30f51c63          	bne	a0,a5,80004f64 <spawn+0x370>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004c50:	e5042703          	lw	a4,-432(s0)
    80004c54:	464c47b7          	lui	a5,0x464c4
    80004c58:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004c5c:	30f71463          	bne	a4,a5,80004f64 <spawn+0x370>
    80004c60:	fbca                	sd	s2,496(sp)
    80004c62:	f3d2                	sd	s4,480(sp)
    80004c64:	efd6                	sd	s5,472(sp)
    80004c66:	ebda                	sd	s6,464(sp)
    80004c68:	e7de                	sd	s7,456(sp)
    80004c6a:	e3e2                	sd	s8,448(sp)
    80004c6c:	ff66                	sd	s9,440(sp)
    goto bad;

  // np->pagetable was already initialized by allocproc, we can just use it directly!
  pagetable = np->pagetable;
    80004c6e:	050d3b03          	ld	s6,80(s10)

  // Load program into memory.
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c72:	e7042683          	lw	a3,-400(s0)
    80004c76:	e8845783          	lhu	a5,-376(s0)
    80004c7a:	18078263          	beqz	a5,80004dfe <spawn+0x20a>
    80004c7e:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004c80:	4b81                	li	s7,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c82:	4901                	li	s2,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004c84:	e1840c13          	addi	s8,s0,-488
    80004c88:	03800a13          	li	s4,56
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
    80004c8c:	4c85                	li	s9,1
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
    80004c8e:	6d85                	lui	s11,0x1
    80004c90:	1dfd                	addi	s11,s11,-1 # fff <_entry-0x7ffff001>
    80004c92:	a03d                	j	80004cc0 <spawn+0xcc>
    end_op();
    80004c94:	a1cff0ef          	jal	80003eb0 <end_op>
    acquire(&np->lock);
    80004c98:	856a                	mv	a0,s10
    80004c9a:	f9dfb0ef          	jal	80000c36 <acquire>
    freeproc(np);
    80004c9e:	856a                	mv	a0,s10
    80004ca0:	de7fc0ef          	jal	80001a86 <freeproc>
    release(&np->lock);
    80004ca4:	856a                	mv	a0,s10
    80004ca6:	824fc0ef          	jal	80000cca <release>
    return -1;
    80004caa:	54fd                	li	s1,-1
    80004cac:	79be                	ld	s3,488(sp)
    80004cae:	7d5a                	ld	s10,432(sp)
    80004cb0:	acf9                	j	80004f8e <spawn+0x39a>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004cb2:	2905                	addiw	s2,s2,1
    80004cb4:	038a869b          	addiw	a3,s5,56
    80004cb8:	e8845783          	lhu	a5,-376(s0)
    80004cbc:	06f95963          	bge	s2,a5,80004d2e <spawn+0x13a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004cc0:	8ab6                	mv	s5,a3
    80004cc2:	8752                	mv	a4,s4
    80004cc4:	8662                	mv	a2,s8
    80004cc6:	4581                	li	a1,0
    80004cc8:	854e                	mv	a0,s3
    80004cca:	b23fe0ef          	jal	800037ec <readi>
    80004cce:	27451263          	bne	a0,s4,80004f32 <spawn+0x33e>
    if(ph.type != ELF_PROG_LOAD)
    80004cd2:	e1842783          	lw	a5,-488(s0)
    80004cd6:	fd979ee3          	bne	a5,s9,80004cb2 <spawn+0xbe>
    if(ph.memsz < ph.filesz)
    80004cda:	e4043483          	ld	s1,-448(s0)
    80004cde:	e3843783          	ld	a5,-456(s0)
    80004ce2:	24f4e863          	bltu	s1,a5,80004f32 <spawn+0x33e>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004ce6:	e2843783          	ld	a5,-472(s0)
    80004cea:	94be                	add	s1,s1,a5
    80004cec:	24f4e363          	bltu	s1,a5,80004f32 <spawn+0x33e>
    if(ph.vaddr % PGSIZE != 0)
    80004cf0:	01b7f7b3          	and	a5,a5,s11
    80004cf4:	22079f63          	bnez	a5,80004f32 <spawn+0x33e>
      goto bad;
    uint64 sz1;
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004cf8:	e1c42503          	lw	a0,-484(s0)
    80004cfc:	c17ff0ef          	jal	80004912 <flags2perm>
    80004d00:	86aa                	mv	a3,a0
    80004d02:	8626                	mv	a2,s1
    80004d04:	85de                	mv	a1,s7
    80004d06:	855a                	mv	a0,s6
    80004d08:	e94fc0ef          	jal	8000139c <uvmalloc>
    80004d0c:	84aa                	mv	s1,a0
    80004d0e:	22050263          	beqz	a0,80004f32 <spawn+0x33e>
      goto bad;
    sz = sz1;
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004d12:	e3842703          	lw	a4,-456(s0)
    80004d16:	e2042683          	lw	a3,-480(s0)
    80004d1a:	864e                	mv	a2,s3
    80004d1c:	e2843583          	ld	a1,-472(s0)
    80004d20:	855a                	mv	a0,s6
    80004d22:	b57ff0ef          	jal	80004878 <loadseg>
    80004d26:	20054563          	bltz	a0,80004f30 <spawn+0x33c>
    sz = sz1;
    80004d2a:	8ba6                	mv	s7,s1
    80004d2c:	b759                	j	80004cb2 <spawn+0xbe>
    80004d2e:	7dba                	ld	s11,424(sp)
      goto bad;
  }
  iunlockput(ip);
    80004d30:	854e                	mv	a0,s3
    80004d32:	a6dfe0ef          	jal	8000379e <iunlockput>
  end_op();
    80004d36:	97aff0ef          	jal	80003eb0 <end_op>
  ip = 0;

  p = myproc();
    80004d3a:	bdbfc0ef          	jal	80001914 <myproc>
    80004d3e:	8c2a                	mv	s8,a0

  sz = PGROUNDUP(sz);
    80004d40:	6485                	lui	s1,0x1
    80004d42:	14fd                	addi	s1,s1,-1 # fff <_entry-0x7ffff001>
    80004d44:	94de                	add	s1,s1,s7
    80004d46:	77fd                	lui	a5,0xfffff
    80004d48:	8cfd                	and	s1,s1,a5
  uint64 sz1;
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004d4a:	4691                	li	a3,4
    80004d4c:	6609                	lui	a2,0x2
    80004d4e:	9626                	add	a2,a2,s1
    80004d50:	85a6                	mv	a1,s1
    80004d52:	855a                	mv	a0,s6
    80004d54:	e48fc0ef          	jal	8000139c <uvmalloc>
    80004d58:	8baa                	mv	s7,a0
    80004d5a:	1a050c63          	beqz	a0,80004f12 <spawn+0x31e>
    goto bad;
  sz = sz1;
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004d5e:	75f9                	lui	a1,0xffffe
    80004d60:	95aa                	add	a1,a1,a0
    80004d62:	855a                	mv	a0,s6
    80004d64:	82ffc0ef          	jal	80001592 <uvmclear>
  sp = sz;
  stackbase = sp - USERSTACK*PGSIZE;
    80004d68:	7a7d                	lui	s4,0xfffff
    80004d6a:	9a5e                	add	s4,s4,s7

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    80004d6c:	df843483          	ld	s1,-520(s0)
    80004d70:	c8c9                	beqz	s1,80004e02 <spawn+0x20e>
    80004d72:	e9040993          	addi	s3,s0,-368
  sp = sz;
    80004d76:	8cde                	mv	s9,s7
  for(argc = 0; argv[argc]; argc++) {
    80004d78:	4901                	li	s2,0
    80004d7a:	e0840a93          	addi	s5,s0,-504
    if(argc >= MAXARG)
      goto bad;
    sp -= strlen(argv[argc]) + 1;
    80004d7e:	8526                	mv	a0,s1
    80004d80:	90efc0ef          	jal	80000e8e <strlen>
    80004d84:	0015059b          	addiw	a1,a0,1
    80004d88:	40bc85b3          	sub	a1,s9,a1
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004d8c:	ff05fc93          	andi	s9,a1,-16
    if(sp < stackbase)
    80004d90:	214ce863          	bltu	s9,s4,80004fa0 <spawn+0x3ac>
      goto bad;
    // copyout DOES NOT assume myproc(), it manually resolves pagetable
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004d94:	8526                	mv	a0,s1
    80004d96:	8f8fc0ef          	jal	80000e8e <strlen>
    80004d9a:	0015069b          	addiw	a3,a0,1
    80004d9e:	8626                	mv	a2,s1
    80004da0:	85e6                	mv	a1,s9
    80004da2:	855a                	mv	a0,s6
    80004da4:	819fc0ef          	jal	800015bc <copyout>
    80004da8:	1e054c63          	bltz	a0,80004fa0 <spawn+0x3ac>
      goto bad;
    ustack[argc] = sp;
    80004dac:	0199b023          	sd	s9,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004db0:	0905                	addi	s2,s2,1
    80004db2:	00391793          	slli	a5,s2,0x3
    80004db6:	97d6                	add	a5,a5,s5
    80004db8:	6384                	ld	s1,0(a5)
    80004dba:	09a1                	addi	s3,s3,8
    80004dbc:	f0e9                	bnez	s1,80004d7e <spawn+0x18a>
  }
  ustack[argc] = 0;
    80004dbe:	00391793          	slli	a5,s2,0x3
    80004dc2:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdb5b0>
    80004dc6:	97a2                	add	a5,a5,s0
    80004dc8:	f007b023          	sd	zero,-256(a5)

  // push the array of argv[] pointers.
  sp -= (argc+1) * sizeof(uint64);
    80004dcc:	00190693          	addi	a3,s2,1
    80004dd0:	068e                	slli	a3,a3,0x3
    80004dd2:	40dc84b3          	sub	s1,s9,a3
  sp -= sp % 16;
    80004dd6:	98c1                	andi	s1,s1,-16
  if(sp < stackbase)
    80004dd8:	1344ec63          	bltu	s1,s4,80004f10 <spawn+0x31c>
    goto bad;
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004ddc:	e9040613          	addi	a2,s0,-368
    80004de0:	85a6                	mv	a1,s1
    80004de2:	855a                	mv	a0,s6
    80004de4:	fd8fc0ef          	jal	800015bc <copyout>
    80004de8:	12054a63          	bltz	a0,80004f1c <spawn+0x328>
    goto bad;

  // Save program name
  for(last=s=path; *s; s++)
    80004dec:	df843783          	ld	a5,-520(s0)
    80004df0:	0007c703          	lbu	a4,0(a5)
    80004df4:	c31d                	beqz	a4,80004e1a <spawn+0x226>
    80004df6:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004df8:	02f00693          	li	a3,47
    80004dfc:	a811                	j	80004e10 <spawn+0x21c>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004dfe:	4b81                	li	s7,0
    80004e00:	bf05                	j	80004d30 <spawn+0x13c>
  sp = sz;
    80004e02:	8cde                	mv	s9,s7
  for(argc = 0; argv[argc]; argc++) {
    80004e04:	4901                	li	s2,0
    80004e06:	bf65                	j	80004dbe <spawn+0x1ca>
  for(last=s=path; *s; s++)
    80004e08:	0785                	addi	a5,a5,1
    80004e0a:	fff7c703          	lbu	a4,-1(a5)
    80004e0e:	c711                	beqz	a4,80004e1a <spawn+0x226>
    if(*s == '/')
    80004e10:	fed71ce3          	bne	a4,a3,80004e08 <spawn+0x214>
      last = s+1;
    80004e14:	def43c23          	sd	a5,-520(s0)
    80004e18:	bfc5                	j	80004e08 <spawn+0x214>
  safestrcpy(np->name, last, sizeof(np->name));
    80004e1a:	158d0993          	addi	s3,s10,344
    80004e1e:	4641                	li	a2,16
    80004e20:	df843583          	ld	a1,-520(s0)
    80004e24:	854e                	mv	a0,s3
    80004e26:	832fc0ef          	jal	80000e58 <safestrcpy>
    
  *(np->trapframe) = *(p->trapframe);
    80004e2a:	058c3683          	ld	a3,88(s8) # 2058 <_entry-0x7fffdfa8>
    80004e2e:	87b6                	mv	a5,a3
    80004e30:	058d3703          	ld	a4,88(s10)
    80004e34:	12068693          	addi	a3,a3,288
    80004e38:	0007b803          	ld	a6,0(a5)
    80004e3c:	6788                	ld	a0,8(a5)
    80004e3e:	6b8c                	ld	a1,16(a5)
    80004e40:	6f90                	ld	a2,24(a5)
    80004e42:	01073023          	sd	a6,0(a4)
    80004e46:	e708                	sd	a0,8(a4)
    80004e48:	eb0c                	sd	a1,16(a4)
    80004e4a:	ef10                	sd	a2,24(a4)
    80004e4c:	02078793          	addi	a5,a5,32
    80004e50:	02070713          	addi	a4,a4,32
    80004e54:	fed792e3          	bne	a5,a3,80004e38 <spawn+0x244>

  // arguments to user main(argc, argv)
  np->trapframe->a1 = sp;
    80004e58:	058d3783          	ld	a5,88(s10)
    80004e5c:	ffa4                	sd	s1,120(a5)

  np->sz = sz;
    80004e5e:	057d3423          	sd	s7,72(s10)
  np->trapframe->epc = elf.entry;  // initial program counter = main
    80004e62:	058d3783          	ld	a5,88(s10)
    80004e66:	e6843703          	ld	a4,-408(s0)
    80004e6a:	ef98                	sd	a4,24(a5)
  np->trapframe->sp = sp; // initial stack pointer
    80004e6c:	058d3783          	ld	a5,88(s10)
    80004e70:	fb84                	sd	s1,48(a5)

  np->trapframe->a0 = argc;
    80004e72:	058d3783          	ld	a5,88(s10)
    80004e76:	0727b823          	sd	s2,112(a5)

  // increment reference counts on open file descriptors.
  for(i = 0; i < NOFILE; i++)
    80004e7a:	0d0c0493          	addi	s1,s8,208
    80004e7e:	0d0d0913          	addi	s2,s10,208
    80004e82:	150c0a13          	addi	s4,s8,336
    80004e86:	a029                	j	80004e90 <spawn+0x29c>
    80004e88:	04a1                	addi	s1,s1,8
    80004e8a:	0921                	addi	s2,s2,8
    80004e8c:	01448963          	beq	s1,s4,80004e9e <spawn+0x2aa>
    if(p->ofile[i])
    80004e90:	6088                	ld	a0,0(s1)
    80004e92:	d97d                	beqz	a0,80004e88 <spawn+0x294>
      np->ofile[i] = filedup(p->ofile[i]);
    80004e94:	b8cff0ef          	jal	80004220 <filedup>
    80004e98:	00a93023          	sd	a0,0(s2)
    80004e9c:	b7f5                	j	80004e88 <spawn+0x294>
  np->cwd = idup(p->cwd);
    80004e9e:	150c3503          	ld	a0,336(s8)
    80004ea2:	ebcfe0ef          	jal	8000355e <idup>
    80004ea6:	14ad3823          	sd	a0,336(s10)

  safestrcpy(np->name, last, sizeof(np->name));
    80004eaa:	4641                	li	a2,16
    80004eac:	df843583          	ld	a1,-520(s0)
    80004eb0:	854e                	mv	a0,s3
    80004eb2:	fa7fb0ef          	jal	80000e58 <safestrcpy>

  int pid = np->pid;
    80004eb6:	030d2483          	lw	s1,48(s10)

  acquire(&wait_lock);
    80004eba:	0000e517          	auipc	a0,0xe
    80004ebe:	92e50513          	addi	a0,a0,-1746 # 800127e8 <wait_lock>
    80004ec2:	d75fb0ef          	jal	80000c36 <acquire>
  np->parent = p;
    80004ec6:	038d3c23          	sd	s8,56(s10)
  release(&wait_lock);
    80004eca:	0000e517          	auipc	a0,0xe
    80004ece:	91e50513          	addi	a0,a0,-1762 # 800127e8 <wait_lock>
    80004ed2:	df9fb0ef          	jal	80000cca <release>

  acquire(&np->lock);
    80004ed6:	856a                	mv	a0,s10
    80004ed8:	d5ffb0ef          	jal	80000c36 <acquire>
  np->state = RUNNABLE;
    80004edc:	478d                	li	a5,3
    80004ede:	00fd2c23          	sw	a5,24(s10)
  release(&np->lock);
    80004ee2:	856a                	mv	a0,s10
    80004ee4:	de7fb0ef          	jal	80000cca <release>

  return pid;
    80004ee8:	795e                	ld	s2,496(sp)
    80004eea:	79be                	ld	s3,488(sp)
    80004eec:	7a1e                	ld	s4,480(sp)
    80004eee:	6afe                	ld	s5,472(sp)
    80004ef0:	6b5e                	ld	s6,464(sp)
    80004ef2:	6bbe                	ld	s7,456(sp)
    80004ef4:	6c1e                	ld	s8,448(sp)
    80004ef6:	7cfa                	ld	s9,440(sp)
    80004ef8:	7d5a                	ld	s10,432(sp)
    80004efa:	a851                	j	80004f8e <spawn+0x39a>
    80004efc:	795e                	ld	s2,496(sp)
    80004efe:	7a1e                	ld	s4,480(sp)
    80004f00:	6afe                	ld	s5,472(sp)
    80004f02:	6b5e                	ld	s6,464(sp)
    80004f04:	6bbe                	ld	s7,456(sp)
    80004f06:	6c1e                	ld	s8,448(sp)
    80004f08:	7cfa                	ld	s9,440(sp)
    80004f0a:	a8a9                	j	80004f64 <spawn+0x370>
    return -1;
    80004f0c:	54fd                	li	s1,-1
    80004f0e:	a041                	j	80004f8e <spawn+0x39a>
  sz = sz1;
    80004f10:	84de                	mv	s1,s7

 bad:
  if(pagetable)
    80004f12:	000b0763          	beqz	s6,80004f20 <spawn+0x32c>
    80004f16:	8ba6                	mv	s7,s1
    80004f18:	4981                	li	s3,0
    80004f1a:	a839                	j	80004f38 <spawn+0x344>
  sz = sz1;
    80004f1c:	84de                	mv	s1,s7
    80004f1e:	bfd5                	j	80004f12 <spawn+0x31e>
    80004f20:	795e                	ld	s2,496(sp)
    80004f22:	7a1e                	ld	s4,480(sp)
    80004f24:	6afe                	ld	s5,472(sp)
    80004f26:	6b5e                	ld	s6,464(sp)
    80004f28:	6bbe                	ld	s7,456(sp)
    80004f2a:	6c1e                	ld	s8,448(sp)
    80004f2c:	7cfa                	ld	s9,440(sp)
    80004f2e:	a081                	j	80004f6e <spawn+0x37a>
    sz = sz1;
    80004f30:	8ba6                	mv	s7,s1
  if(pagetable)
    80004f32:	020b0163          	beqz	s6,80004f54 <spawn+0x360>
    80004f36:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004f38:	85de                	mv	a1,s7
    80004f3a:	855a                	mv	a0,s6
    80004f3c:	b05fc0ef          	jal	80001a40 <proc_freepagetable>
  if(ip){
    80004f40:	fa099ee3          	bnez	s3,80004efc <spawn+0x308>
    80004f44:	795e                	ld	s2,496(sp)
    80004f46:	7a1e                	ld	s4,480(sp)
    80004f48:	6afe                	ld	s5,472(sp)
    80004f4a:	6b5e                	ld	s6,464(sp)
    80004f4c:	6bbe                	ld	s7,456(sp)
    80004f4e:	6c1e                	ld	s8,448(sp)
    80004f50:	7cfa                	ld	s9,440(sp)
    80004f52:	a831                	j	80004f6e <spawn+0x37a>
    80004f54:	795e                	ld	s2,496(sp)
    80004f56:	7a1e                	ld	s4,480(sp)
    80004f58:	6afe                	ld	s5,472(sp)
    80004f5a:	6b5e                	ld	s6,464(sp)
    80004f5c:	6bbe                	ld	s7,456(sp)
    80004f5e:	6c1e                	ld	s8,448(sp)
    80004f60:	7cfa                	ld	s9,440(sp)
    80004f62:	7dba                	ld	s11,424(sp)
    iunlockput(ip);
    80004f64:	854e                	mv	a0,s3
    80004f66:	839fe0ef          	jal	8000379e <iunlockput>
    end_op();
    80004f6a:	f47fe0ef          	jal	80003eb0 <end_op>
  }
  acquire(&np->lock);
    80004f6e:	856a                	mv	a0,s10
    80004f70:	cc7fb0ef          	jal	80000c36 <acquire>
  // since freeproc frees pagetable, we need to clear pagetable since we already freed it
  np->pagetable = 0;
    80004f74:	040d3823          	sd	zero,80(s10)
  np->sz = 0;
    80004f78:	040d3423          	sd	zero,72(s10)
  freeproc(np);
    80004f7c:	856a                	mv	a0,s10
    80004f7e:	b09fc0ef          	jal	80001a86 <freeproc>
  release(&np->lock);
    80004f82:	856a                	mv	a0,s10
    80004f84:	d47fb0ef          	jal	80000cca <release>
  return -1;
    80004f88:	54fd                	li	s1,-1
    80004f8a:	79be                	ld	s3,488(sp)
    80004f8c:	7d5a                	ld	s10,432(sp)
}
    80004f8e:	8526                	mv	a0,s1
    80004f90:	20813083          	ld	ra,520(sp)
    80004f94:	20013403          	ld	s0,512(sp)
    80004f98:	74fe                	ld	s1,504(sp)
    80004f9a:	21010113          	addi	sp,sp,528
    80004f9e:	8082                	ret
  if(pagetable)
    80004fa0:	4981                	li	s3,0
    80004fa2:	f80b1be3          	bnez	s6,80004f38 <spawn+0x344>
    80004fa6:	795e                	ld	s2,496(sp)
    80004fa8:	7a1e                	ld	s4,480(sp)
    80004faa:	6afe                	ld	s5,472(sp)
    80004fac:	6b5e                	ld	s6,464(sp)
    80004fae:	6bbe                	ld	s7,456(sp)
    80004fb0:	6c1e                	ld	s8,448(sp)
    80004fb2:	7cfa                	ld	s9,440(sp)
    80004fb4:	bf6d                	j	80004f6e <spawn+0x37a>

0000000080004fb6 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004fb6:	7179                	addi	sp,sp,-48
    80004fb8:	f406                	sd	ra,40(sp)
    80004fba:	f022                	sd	s0,32(sp)
    80004fbc:	ec26                	sd	s1,24(sp)
    80004fbe:	e84a                	sd	s2,16(sp)
    80004fc0:	1800                	addi	s0,sp,48
    80004fc2:	892e                	mv	s2,a1
    80004fc4:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004fc6:	fdc40593          	addi	a1,s0,-36
    80004fca:	a05fd0ef          	jal	800029ce <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004fce:	fdc42703          	lw	a4,-36(s0)
    80004fd2:	47bd                	li	a5,15
    80004fd4:	02e7e963          	bltu	a5,a4,80005006 <argfd+0x50>
    80004fd8:	93dfc0ef          	jal	80001914 <myproc>
    80004fdc:	fdc42703          	lw	a4,-36(s0)
    80004fe0:	01a70793          	addi	a5,a4,26
    80004fe4:	078e                	slli	a5,a5,0x3
    80004fe6:	953e                	add	a0,a0,a5
    80004fe8:	611c                	ld	a5,0(a0)
    80004fea:	c385                	beqz	a5,8000500a <argfd+0x54>
    return -1;
  if(pfd)
    80004fec:	00090463          	beqz	s2,80004ff4 <argfd+0x3e>
    *pfd = fd;
    80004ff0:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004ff4:	4501                	li	a0,0
  if(pf)
    80004ff6:	c091                	beqz	s1,80004ffa <argfd+0x44>
    *pf = f;
    80004ff8:	e09c                	sd	a5,0(s1)
}
    80004ffa:	70a2                	ld	ra,40(sp)
    80004ffc:	7402                	ld	s0,32(sp)
    80004ffe:	64e2                	ld	s1,24(sp)
    80005000:	6942                	ld	s2,16(sp)
    80005002:	6145                	addi	sp,sp,48
    80005004:	8082                	ret
    return -1;
    80005006:	557d                	li	a0,-1
    80005008:	bfcd                	j	80004ffa <argfd+0x44>
    8000500a:	557d                	li	a0,-1
    8000500c:	b7fd                	j	80004ffa <argfd+0x44>

000000008000500e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000500e:	1101                	addi	sp,sp,-32
    80005010:	ec06                	sd	ra,24(sp)
    80005012:	e822                	sd	s0,16(sp)
    80005014:	e426                	sd	s1,8(sp)
    80005016:	1000                	addi	s0,sp,32
    80005018:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000501a:	8fbfc0ef          	jal	80001914 <myproc>
    8000501e:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005020:	0d050793          	addi	a5,a0,208
    80005024:	4501                	li	a0,0
    80005026:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005028:	6398                	ld	a4,0(a5)
    8000502a:	cb19                	beqz	a4,80005040 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    8000502c:	2505                	addiw	a0,a0,1
    8000502e:	07a1                	addi	a5,a5,8
    80005030:	fed51ce3          	bne	a0,a3,80005028 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005034:	557d                	li	a0,-1
}
    80005036:	60e2                	ld	ra,24(sp)
    80005038:	6442                	ld	s0,16(sp)
    8000503a:	64a2                	ld	s1,8(sp)
    8000503c:	6105                	addi	sp,sp,32
    8000503e:	8082                	ret
      p->ofile[fd] = f;
    80005040:	01a50793          	addi	a5,a0,26
    80005044:	078e                	slli	a5,a5,0x3
    80005046:	963e                	add	a2,a2,a5
    80005048:	e204                	sd	s1,0(a2)
      return fd;
    8000504a:	b7f5                	j	80005036 <fdalloc+0x28>

000000008000504c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000504c:	715d                	addi	sp,sp,-80
    8000504e:	e486                	sd	ra,72(sp)
    80005050:	e0a2                	sd	s0,64(sp)
    80005052:	fc26                	sd	s1,56(sp)
    80005054:	f84a                	sd	s2,48(sp)
    80005056:	f44e                	sd	s3,40(sp)
    80005058:	ec56                	sd	s5,24(sp)
    8000505a:	e85a                	sd	s6,16(sp)
    8000505c:	0880                	addi	s0,sp,80
    8000505e:	8b2e                	mv	s6,a1
    80005060:	89b2                	mv	s3,a2
    80005062:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005064:	fb040593          	addi	a1,s0,-80
    80005068:	c37fe0ef          	jal	80003c9e <nameiparent>
    8000506c:	84aa                	mv	s1,a0
    8000506e:	10050a63          	beqz	a0,80005182 <create+0x136>
    return 0;

  ilock(dp);
    80005072:	d22fe0ef          	jal	80003594 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005076:	4601                	li	a2,0
    80005078:	fb040593          	addi	a1,s0,-80
    8000507c:	8526                	mv	a0,s1
    8000507e:	97bfe0ef          	jal	800039f8 <dirlookup>
    80005082:	8aaa                	mv	s5,a0
    80005084:	c129                	beqz	a0,800050c6 <create+0x7a>
    iunlockput(dp);
    80005086:	8526                	mv	a0,s1
    80005088:	f16fe0ef          	jal	8000379e <iunlockput>
    ilock(ip);
    8000508c:	8556                	mv	a0,s5
    8000508e:	d06fe0ef          	jal	80003594 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005092:	4789                	li	a5,2
    80005094:	02fb1463          	bne	s6,a5,800050bc <create+0x70>
    80005098:	044ad783          	lhu	a5,68(s5)
    8000509c:	37f9                	addiw	a5,a5,-2
    8000509e:	17c2                	slli	a5,a5,0x30
    800050a0:	93c1                	srli	a5,a5,0x30
    800050a2:	4705                	li	a4,1
    800050a4:	00f76c63          	bltu	a4,a5,800050bc <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800050a8:	8556                	mv	a0,s5
    800050aa:	60a6                	ld	ra,72(sp)
    800050ac:	6406                	ld	s0,64(sp)
    800050ae:	74e2                	ld	s1,56(sp)
    800050b0:	7942                	ld	s2,48(sp)
    800050b2:	79a2                	ld	s3,40(sp)
    800050b4:	6ae2                	ld	s5,24(sp)
    800050b6:	6b42                	ld	s6,16(sp)
    800050b8:	6161                	addi	sp,sp,80
    800050ba:	8082                	ret
    iunlockput(ip);
    800050bc:	8556                	mv	a0,s5
    800050be:	ee0fe0ef          	jal	8000379e <iunlockput>
    return 0;
    800050c2:	4a81                	li	s5,0
    800050c4:	b7d5                	j	800050a8 <create+0x5c>
    800050c6:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    800050c8:	85da                	mv	a1,s6
    800050ca:	4088                	lw	a0,0(s1)
    800050cc:	b58fe0ef          	jal	80003424 <ialloc>
    800050d0:	8a2a                	mv	s4,a0
    800050d2:	cd15                	beqz	a0,8000510e <create+0xc2>
  ilock(ip);
    800050d4:	cc0fe0ef          	jal	80003594 <ilock>
  ip->major = major;
    800050d8:	053a1323          	sh	s3,70(s4) # fffffffffffff046 <end+0xffffffff7ffdb666>
  ip->minor = minor;
    800050dc:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800050e0:	4905                	li	s2,1
    800050e2:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800050e6:	8552                	mv	a0,s4
    800050e8:	bf8fe0ef          	jal	800034e0 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800050ec:	032b0763          	beq	s6,s2,8000511a <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    800050f0:	004a2603          	lw	a2,4(s4)
    800050f4:	fb040593          	addi	a1,s0,-80
    800050f8:	8526                	mv	a0,s1
    800050fa:	ae1fe0ef          	jal	80003bda <dirlink>
    800050fe:	06054563          	bltz	a0,80005168 <create+0x11c>
  iunlockput(dp);
    80005102:	8526                	mv	a0,s1
    80005104:	e9afe0ef          	jal	8000379e <iunlockput>
  return ip;
    80005108:	8ad2                	mv	s5,s4
    8000510a:	7a02                	ld	s4,32(sp)
    8000510c:	bf71                	j	800050a8 <create+0x5c>
    iunlockput(dp);
    8000510e:	8526                	mv	a0,s1
    80005110:	e8efe0ef          	jal	8000379e <iunlockput>
    return 0;
    80005114:	8ad2                	mv	s5,s4
    80005116:	7a02                	ld	s4,32(sp)
    80005118:	bf41                	j	800050a8 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000511a:	004a2603          	lw	a2,4(s4)
    8000511e:	00002597          	auipc	a1,0x2
    80005122:	50258593          	addi	a1,a1,1282 # 80007620 <etext+0x620>
    80005126:	8552                	mv	a0,s4
    80005128:	ab3fe0ef          	jal	80003bda <dirlink>
    8000512c:	02054e63          	bltz	a0,80005168 <create+0x11c>
    80005130:	40d0                	lw	a2,4(s1)
    80005132:	00002597          	auipc	a1,0x2
    80005136:	4f658593          	addi	a1,a1,1270 # 80007628 <etext+0x628>
    8000513a:	8552                	mv	a0,s4
    8000513c:	a9ffe0ef          	jal	80003bda <dirlink>
    80005140:	02054463          	bltz	a0,80005168 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80005144:	004a2603          	lw	a2,4(s4)
    80005148:	fb040593          	addi	a1,s0,-80
    8000514c:	8526                	mv	a0,s1
    8000514e:	a8dfe0ef          	jal	80003bda <dirlink>
    80005152:	00054b63          	bltz	a0,80005168 <create+0x11c>
    dp->nlink++;  // for ".."
    80005156:	04a4d783          	lhu	a5,74(s1)
    8000515a:	2785                	addiw	a5,a5,1
    8000515c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005160:	8526                	mv	a0,s1
    80005162:	b7efe0ef          	jal	800034e0 <iupdate>
    80005166:	bf71                	j	80005102 <create+0xb6>
  ip->nlink = 0;
    80005168:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000516c:	8552                	mv	a0,s4
    8000516e:	b72fe0ef          	jal	800034e0 <iupdate>
  iunlockput(ip);
    80005172:	8552                	mv	a0,s4
    80005174:	e2afe0ef          	jal	8000379e <iunlockput>
  iunlockput(dp);
    80005178:	8526                	mv	a0,s1
    8000517a:	e24fe0ef          	jal	8000379e <iunlockput>
  return 0;
    8000517e:	7a02                	ld	s4,32(sp)
    80005180:	b725                	j	800050a8 <create+0x5c>
    return 0;
    80005182:	8aaa                	mv	s5,a0
    80005184:	b715                	j	800050a8 <create+0x5c>

0000000080005186 <sys_dup>:
{
    80005186:	7179                	addi	sp,sp,-48
    80005188:	f406                	sd	ra,40(sp)
    8000518a:	f022                	sd	s0,32(sp)
    8000518c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000518e:	fd840613          	addi	a2,s0,-40
    80005192:	4581                	li	a1,0
    80005194:	4501                	li	a0,0
    80005196:	e21ff0ef          	jal	80004fb6 <argfd>
    return -1;
    8000519a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000519c:	02054363          	bltz	a0,800051c2 <sys_dup+0x3c>
    800051a0:	ec26                	sd	s1,24(sp)
    800051a2:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    800051a4:	fd843903          	ld	s2,-40(s0)
    800051a8:	854a                	mv	a0,s2
    800051aa:	e65ff0ef          	jal	8000500e <fdalloc>
    800051ae:	84aa                	mv	s1,a0
    return -1;
    800051b0:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800051b2:	00054d63          	bltz	a0,800051cc <sys_dup+0x46>
  filedup(f);
    800051b6:	854a                	mv	a0,s2
    800051b8:	868ff0ef          	jal	80004220 <filedup>
  return fd;
    800051bc:	87a6                	mv	a5,s1
    800051be:	64e2                	ld	s1,24(sp)
    800051c0:	6942                	ld	s2,16(sp)
}
    800051c2:	853e                	mv	a0,a5
    800051c4:	70a2                	ld	ra,40(sp)
    800051c6:	7402                	ld	s0,32(sp)
    800051c8:	6145                	addi	sp,sp,48
    800051ca:	8082                	ret
    800051cc:	64e2                	ld	s1,24(sp)
    800051ce:	6942                	ld	s2,16(sp)
    800051d0:	bfcd                	j	800051c2 <sys_dup+0x3c>

00000000800051d2 <sys_read>:
{
    800051d2:	7179                	addi	sp,sp,-48
    800051d4:	f406                	sd	ra,40(sp)
    800051d6:	f022                	sd	s0,32(sp)
    800051d8:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800051da:	fd840593          	addi	a1,s0,-40
    800051de:	4505                	li	a0,1
    800051e0:	80bfd0ef          	jal	800029ea <argaddr>
  argint(2, &n);
    800051e4:	fe440593          	addi	a1,s0,-28
    800051e8:	4509                	li	a0,2
    800051ea:	fe4fd0ef          	jal	800029ce <argint>
  if(argfd(0, 0, &f) < 0)
    800051ee:	fe840613          	addi	a2,s0,-24
    800051f2:	4581                	li	a1,0
    800051f4:	4501                	li	a0,0
    800051f6:	dc1ff0ef          	jal	80004fb6 <argfd>
    800051fa:	87aa                	mv	a5,a0
    return -1;
    800051fc:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800051fe:	0007ca63          	bltz	a5,80005212 <sys_read+0x40>
  return fileread(f, p, n);
    80005202:	fe442603          	lw	a2,-28(s0)
    80005206:	fd843583          	ld	a1,-40(s0)
    8000520a:	fe843503          	ld	a0,-24(s0)
    8000520e:	978ff0ef          	jal	80004386 <fileread>
}
    80005212:	70a2                	ld	ra,40(sp)
    80005214:	7402                	ld	s0,32(sp)
    80005216:	6145                	addi	sp,sp,48
    80005218:	8082                	ret

000000008000521a <sys_write>:
{
    8000521a:	7179                	addi	sp,sp,-48
    8000521c:	f406                	sd	ra,40(sp)
    8000521e:	f022                	sd	s0,32(sp)
    80005220:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005222:	fd840593          	addi	a1,s0,-40
    80005226:	4505                	li	a0,1
    80005228:	fc2fd0ef          	jal	800029ea <argaddr>
  argint(2, &n);
    8000522c:	fe440593          	addi	a1,s0,-28
    80005230:	4509                	li	a0,2
    80005232:	f9cfd0ef          	jal	800029ce <argint>
  if(argfd(0, 0, &f) < 0)
    80005236:	fe840613          	addi	a2,s0,-24
    8000523a:	4581                	li	a1,0
    8000523c:	4501                	li	a0,0
    8000523e:	d79ff0ef          	jal	80004fb6 <argfd>
    80005242:	87aa                	mv	a5,a0
    return -1;
    80005244:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005246:	0007ca63          	bltz	a5,8000525a <sys_write+0x40>
  return filewrite(f, p, n);
    8000524a:	fe442603          	lw	a2,-28(s0)
    8000524e:	fd843583          	ld	a1,-40(s0)
    80005252:	fe843503          	ld	a0,-24(s0)
    80005256:	9eeff0ef          	jal	80004444 <filewrite>
}
    8000525a:	70a2                	ld	ra,40(sp)
    8000525c:	7402                	ld	s0,32(sp)
    8000525e:	6145                	addi	sp,sp,48
    80005260:	8082                	ret

0000000080005262 <sys_close>:
{
    80005262:	1101                	addi	sp,sp,-32
    80005264:	ec06                	sd	ra,24(sp)
    80005266:	e822                	sd	s0,16(sp)
    80005268:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000526a:	fe040613          	addi	a2,s0,-32
    8000526e:	fec40593          	addi	a1,s0,-20
    80005272:	4501                	li	a0,0
    80005274:	d43ff0ef          	jal	80004fb6 <argfd>
    return -1;
    80005278:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000527a:	02054063          	bltz	a0,8000529a <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    8000527e:	e96fc0ef          	jal	80001914 <myproc>
    80005282:	fec42783          	lw	a5,-20(s0)
    80005286:	07e9                	addi	a5,a5,26
    80005288:	078e                	slli	a5,a5,0x3
    8000528a:	953e                	add	a0,a0,a5
    8000528c:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005290:	fe043503          	ld	a0,-32(s0)
    80005294:	fd3fe0ef          	jal	80004266 <fileclose>
  return 0;
    80005298:	4781                	li	a5,0
}
    8000529a:	853e                	mv	a0,a5
    8000529c:	60e2                	ld	ra,24(sp)
    8000529e:	6442                	ld	s0,16(sp)
    800052a0:	6105                	addi	sp,sp,32
    800052a2:	8082                	ret

00000000800052a4 <sys_fstat>:
{
    800052a4:	1101                	addi	sp,sp,-32
    800052a6:	ec06                	sd	ra,24(sp)
    800052a8:	e822                	sd	s0,16(sp)
    800052aa:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800052ac:	fe040593          	addi	a1,s0,-32
    800052b0:	4505                	li	a0,1
    800052b2:	f38fd0ef          	jal	800029ea <argaddr>
  if(argfd(0, 0, &f) < 0)
    800052b6:	fe840613          	addi	a2,s0,-24
    800052ba:	4581                	li	a1,0
    800052bc:	4501                	li	a0,0
    800052be:	cf9ff0ef          	jal	80004fb6 <argfd>
    800052c2:	87aa                	mv	a5,a0
    return -1;
    800052c4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800052c6:	0007c863          	bltz	a5,800052d6 <sys_fstat+0x32>
  return filestat(f, st);
    800052ca:	fe043583          	ld	a1,-32(s0)
    800052ce:	fe843503          	ld	a0,-24(s0)
    800052d2:	852ff0ef          	jal	80004324 <filestat>
}
    800052d6:	60e2                	ld	ra,24(sp)
    800052d8:	6442                	ld	s0,16(sp)
    800052da:	6105                	addi	sp,sp,32
    800052dc:	8082                	ret

00000000800052de <sys_link>:
{
    800052de:	7169                	addi	sp,sp,-304
    800052e0:	f606                	sd	ra,296(sp)
    800052e2:	f222                	sd	s0,288(sp)
    800052e4:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052e6:	08000613          	li	a2,128
    800052ea:	ed040593          	addi	a1,s0,-304
    800052ee:	4501                	li	a0,0
    800052f0:	f16fd0ef          	jal	80002a06 <argstr>
    return -1;
    800052f4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052f6:	0c054e63          	bltz	a0,800053d2 <sys_link+0xf4>
    800052fa:	08000613          	li	a2,128
    800052fe:	f5040593          	addi	a1,s0,-176
    80005302:	4505                	li	a0,1
    80005304:	f02fd0ef          	jal	80002a06 <argstr>
    return -1;
    80005308:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000530a:	0c054463          	bltz	a0,800053d2 <sys_link+0xf4>
    8000530e:	ee26                	sd	s1,280(sp)
  begin_op();
    80005310:	b37fe0ef          	jal	80003e46 <begin_op>
  if((ip = namei(old)) == 0){
    80005314:	ed040513          	addi	a0,s0,-304
    80005318:	96dfe0ef          	jal	80003c84 <namei>
    8000531c:	84aa                	mv	s1,a0
    8000531e:	c53d                	beqz	a0,8000538c <sys_link+0xae>
  ilock(ip);
    80005320:	a74fe0ef          	jal	80003594 <ilock>
  if(ip->type == T_DIR){
    80005324:	04449703          	lh	a4,68(s1)
    80005328:	4785                	li	a5,1
    8000532a:	06f70663          	beq	a4,a5,80005396 <sys_link+0xb8>
    8000532e:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005330:	04a4d783          	lhu	a5,74(s1)
    80005334:	2785                	addiw	a5,a5,1
    80005336:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000533a:	8526                	mv	a0,s1
    8000533c:	9a4fe0ef          	jal	800034e0 <iupdate>
  iunlock(ip);
    80005340:	8526                	mv	a0,s1
    80005342:	b00fe0ef          	jal	80003642 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005346:	fd040593          	addi	a1,s0,-48
    8000534a:	f5040513          	addi	a0,s0,-176
    8000534e:	951fe0ef          	jal	80003c9e <nameiparent>
    80005352:	892a                	mv	s2,a0
    80005354:	cd21                	beqz	a0,800053ac <sys_link+0xce>
  ilock(dp);
    80005356:	a3efe0ef          	jal	80003594 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000535a:	00092703          	lw	a4,0(s2)
    8000535e:	409c                	lw	a5,0(s1)
    80005360:	04f71363          	bne	a4,a5,800053a6 <sys_link+0xc8>
    80005364:	40d0                	lw	a2,4(s1)
    80005366:	fd040593          	addi	a1,s0,-48
    8000536a:	854a                	mv	a0,s2
    8000536c:	86ffe0ef          	jal	80003bda <dirlink>
    80005370:	02054b63          	bltz	a0,800053a6 <sys_link+0xc8>
  iunlockput(dp);
    80005374:	854a                	mv	a0,s2
    80005376:	c28fe0ef          	jal	8000379e <iunlockput>
  iput(ip);
    8000537a:	8526                	mv	a0,s1
    8000537c:	b9afe0ef          	jal	80003716 <iput>
  end_op();
    80005380:	b31fe0ef          	jal	80003eb0 <end_op>
  return 0;
    80005384:	4781                	li	a5,0
    80005386:	64f2                	ld	s1,280(sp)
    80005388:	6952                	ld	s2,272(sp)
    8000538a:	a0a1                	j	800053d2 <sys_link+0xf4>
    end_op();
    8000538c:	b25fe0ef          	jal	80003eb0 <end_op>
    return -1;
    80005390:	57fd                	li	a5,-1
    80005392:	64f2                	ld	s1,280(sp)
    80005394:	a83d                	j	800053d2 <sys_link+0xf4>
    iunlockput(ip);
    80005396:	8526                	mv	a0,s1
    80005398:	c06fe0ef          	jal	8000379e <iunlockput>
    end_op();
    8000539c:	b15fe0ef          	jal	80003eb0 <end_op>
    return -1;
    800053a0:	57fd                	li	a5,-1
    800053a2:	64f2                	ld	s1,280(sp)
    800053a4:	a03d                	j	800053d2 <sys_link+0xf4>
    iunlockput(dp);
    800053a6:	854a                	mv	a0,s2
    800053a8:	bf6fe0ef          	jal	8000379e <iunlockput>
  ilock(ip);
    800053ac:	8526                	mv	a0,s1
    800053ae:	9e6fe0ef          	jal	80003594 <ilock>
  ip->nlink--;
    800053b2:	04a4d783          	lhu	a5,74(s1)
    800053b6:	37fd                	addiw	a5,a5,-1
    800053b8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800053bc:	8526                	mv	a0,s1
    800053be:	922fe0ef          	jal	800034e0 <iupdate>
  iunlockput(ip);
    800053c2:	8526                	mv	a0,s1
    800053c4:	bdafe0ef          	jal	8000379e <iunlockput>
  end_op();
    800053c8:	ae9fe0ef          	jal	80003eb0 <end_op>
  return -1;
    800053cc:	57fd                	li	a5,-1
    800053ce:	64f2                	ld	s1,280(sp)
    800053d0:	6952                	ld	s2,272(sp)
}
    800053d2:	853e                	mv	a0,a5
    800053d4:	70b2                	ld	ra,296(sp)
    800053d6:	7412                	ld	s0,288(sp)
    800053d8:	6155                	addi	sp,sp,304
    800053da:	8082                	ret

00000000800053dc <sys_unlink>:
{
    800053dc:	7111                	addi	sp,sp,-256
    800053de:	fd86                	sd	ra,248(sp)
    800053e0:	f9a2                	sd	s0,240(sp)
    800053e2:	0200                	addi	s0,sp,256
  if(argstr(0, path, MAXPATH) < 0)
    800053e4:	08000613          	li	a2,128
    800053e8:	f2040593          	addi	a1,s0,-224
    800053ec:	4501                	li	a0,0
    800053ee:	e18fd0ef          	jal	80002a06 <argstr>
    800053f2:	16054663          	bltz	a0,8000555e <sys_unlink+0x182>
    800053f6:	f5a6                	sd	s1,232(sp)
  begin_op();
    800053f8:	a4ffe0ef          	jal	80003e46 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800053fc:	fa040593          	addi	a1,s0,-96
    80005400:	f2040513          	addi	a0,s0,-224
    80005404:	89bfe0ef          	jal	80003c9e <nameiparent>
    80005408:	84aa                	mv	s1,a0
    8000540a:	c955                	beqz	a0,800054be <sys_unlink+0xe2>
  ilock(dp);
    8000540c:	988fe0ef          	jal	80003594 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005410:	00002597          	auipc	a1,0x2
    80005414:	21058593          	addi	a1,a1,528 # 80007620 <etext+0x620>
    80005418:	fa040513          	addi	a0,s0,-96
    8000541c:	dc6fe0ef          	jal	800039e2 <namecmp>
    80005420:	12050463          	beqz	a0,80005548 <sys_unlink+0x16c>
    80005424:	00002597          	auipc	a1,0x2
    80005428:	20458593          	addi	a1,a1,516 # 80007628 <etext+0x628>
    8000542c:	fa040513          	addi	a0,s0,-96
    80005430:	db2fe0ef          	jal	800039e2 <namecmp>
    80005434:	10050a63          	beqz	a0,80005548 <sys_unlink+0x16c>
    80005438:	f1ca                	sd	s2,224(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000543a:	f1c40613          	addi	a2,s0,-228
    8000543e:	fa040593          	addi	a1,s0,-96
    80005442:	8526                	mv	a0,s1
    80005444:	db4fe0ef          	jal	800039f8 <dirlookup>
    80005448:	892a                	mv	s2,a0
    8000544a:	0e050e63          	beqz	a0,80005546 <sys_unlink+0x16a>
    8000544e:	edce                	sd	s3,216(sp)
  ilock(ip);
    80005450:	944fe0ef          	jal	80003594 <ilock>
  if(ip->nlink < 1)
    80005454:	04a91783          	lh	a5,74(s2)
    80005458:	06f05863          	blez	a5,800054c8 <sys_unlink+0xec>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000545c:	04491703          	lh	a4,68(s2)
    80005460:	4785                	li	a5,1
    80005462:	06f70b63          	beq	a4,a5,800054d8 <sys_unlink+0xfc>
  memset(&de, 0, sizeof(de));
    80005466:	fb040993          	addi	s3,s0,-80
    8000546a:	4641                	li	a2,16
    8000546c:	4581                	li	a1,0
    8000546e:	854e                	mv	a0,s3
    80005470:	897fb0ef          	jal	80000d06 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005474:	4741                	li	a4,16
    80005476:	f1c42683          	lw	a3,-228(s0)
    8000547a:	864e                	mv	a2,s3
    8000547c:	4581                	li	a1,0
    8000547e:	8526                	mv	a0,s1
    80005480:	c5efe0ef          	jal	800038de <writei>
    80005484:	47c1                	li	a5,16
    80005486:	08f51f63          	bne	a0,a5,80005524 <sys_unlink+0x148>
  if(ip->type == T_DIR){
    8000548a:	04491703          	lh	a4,68(s2)
    8000548e:	4785                	li	a5,1
    80005490:	0af70263          	beq	a4,a5,80005534 <sys_unlink+0x158>
  iunlockput(dp);
    80005494:	8526                	mv	a0,s1
    80005496:	b08fe0ef          	jal	8000379e <iunlockput>
  ip->nlink--;
    8000549a:	04a95783          	lhu	a5,74(s2)
    8000549e:	37fd                	addiw	a5,a5,-1
    800054a0:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800054a4:	854a                	mv	a0,s2
    800054a6:	83afe0ef          	jal	800034e0 <iupdate>
  iunlockput(ip);
    800054aa:	854a                	mv	a0,s2
    800054ac:	af2fe0ef          	jal	8000379e <iunlockput>
  end_op();
    800054b0:	a01fe0ef          	jal	80003eb0 <end_op>
  return 0;
    800054b4:	4501                	li	a0,0
    800054b6:	74ae                	ld	s1,232(sp)
    800054b8:	790e                	ld	s2,224(sp)
    800054ba:	69ee                	ld	s3,216(sp)
    800054bc:	a869                	j	80005556 <sys_unlink+0x17a>
    end_op();
    800054be:	9f3fe0ef          	jal	80003eb0 <end_op>
    return -1;
    800054c2:	557d                	li	a0,-1
    800054c4:	74ae                	ld	s1,232(sp)
    800054c6:	a841                	j	80005556 <sys_unlink+0x17a>
    800054c8:	e9d2                	sd	s4,208(sp)
    800054ca:	e5d6                	sd	s5,200(sp)
    panic("unlink: nlink < 1");
    800054cc:	00002517          	auipc	a0,0x2
    800054d0:	16450513          	addi	a0,a0,356 # 80007630 <etext+0x630>
    800054d4:	b02fb0ef          	jal	800007d6 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800054d8:	04c92703          	lw	a4,76(s2)
    800054dc:	02000793          	li	a5,32
    800054e0:	f8e7f3e3          	bgeu	a5,a4,80005466 <sys_unlink+0x8a>
    800054e4:	e9d2                	sd	s4,208(sp)
    800054e6:	e5d6                	sd	s5,200(sp)
    800054e8:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800054ea:	f0840a93          	addi	s5,s0,-248
    800054ee:	4a41                	li	s4,16
    800054f0:	8752                	mv	a4,s4
    800054f2:	86ce                	mv	a3,s3
    800054f4:	8656                	mv	a2,s5
    800054f6:	4581                	li	a1,0
    800054f8:	854a                	mv	a0,s2
    800054fa:	af2fe0ef          	jal	800037ec <readi>
    800054fe:	01451d63          	bne	a0,s4,80005518 <sys_unlink+0x13c>
    if(de.inum != 0)
    80005502:	f0845783          	lhu	a5,-248(s0)
    80005506:	efb1                	bnez	a5,80005562 <sys_unlink+0x186>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005508:	29c1                	addiw	s3,s3,16
    8000550a:	04c92783          	lw	a5,76(s2)
    8000550e:	fef9e1e3          	bltu	s3,a5,800054f0 <sys_unlink+0x114>
    80005512:	6a4e                	ld	s4,208(sp)
    80005514:	6aae                	ld	s5,200(sp)
    80005516:	bf81                	j	80005466 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80005518:	00002517          	auipc	a0,0x2
    8000551c:	13050513          	addi	a0,a0,304 # 80007648 <etext+0x648>
    80005520:	ab6fb0ef          	jal	800007d6 <panic>
    80005524:	e9d2                	sd	s4,208(sp)
    80005526:	e5d6                	sd	s5,200(sp)
    panic("unlink: writei");
    80005528:	00002517          	auipc	a0,0x2
    8000552c:	13850513          	addi	a0,a0,312 # 80007660 <etext+0x660>
    80005530:	aa6fb0ef          	jal	800007d6 <panic>
    dp->nlink--;
    80005534:	04a4d783          	lhu	a5,74(s1)
    80005538:	37fd                	addiw	a5,a5,-1
    8000553a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000553e:	8526                	mv	a0,s1
    80005540:	fa1fd0ef          	jal	800034e0 <iupdate>
    80005544:	bf81                	j	80005494 <sys_unlink+0xb8>
    80005546:	790e                	ld	s2,224(sp)
  iunlockput(dp);
    80005548:	8526                	mv	a0,s1
    8000554a:	a54fe0ef          	jal	8000379e <iunlockput>
  end_op();
    8000554e:	963fe0ef          	jal	80003eb0 <end_op>
  return -1;
    80005552:	557d                	li	a0,-1
    80005554:	74ae                	ld	s1,232(sp)
}
    80005556:	70ee                	ld	ra,248(sp)
    80005558:	744e                	ld	s0,240(sp)
    8000555a:	6111                	addi	sp,sp,256
    8000555c:	8082                	ret
    return -1;
    8000555e:	557d                	li	a0,-1
    80005560:	bfdd                	j	80005556 <sys_unlink+0x17a>
    iunlockput(ip);
    80005562:	854a                	mv	a0,s2
    80005564:	a3afe0ef          	jal	8000379e <iunlockput>
    goto bad;
    80005568:	790e                	ld	s2,224(sp)
    8000556a:	69ee                	ld	s3,216(sp)
    8000556c:	6a4e                	ld	s4,208(sp)
    8000556e:	6aae                	ld	s5,200(sp)
    80005570:	bfe1                	j	80005548 <sys_unlink+0x16c>

0000000080005572 <sys_open>:

uint64
sys_open(void)
{
    80005572:	7131                	addi	sp,sp,-192
    80005574:	fd06                	sd	ra,184(sp)
    80005576:	f922                	sd	s0,176(sp)
    80005578:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000557a:	f4c40593          	addi	a1,s0,-180
    8000557e:	4505                	li	a0,1
    80005580:	c4efd0ef          	jal	800029ce <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005584:	08000613          	li	a2,128
    80005588:	f5040593          	addi	a1,s0,-176
    8000558c:	4501                	li	a0,0
    8000558e:	c78fd0ef          	jal	80002a06 <argstr>
    80005592:	87aa                	mv	a5,a0
    return -1;
    80005594:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005596:	0a07c363          	bltz	a5,8000563c <sys_open+0xca>
    8000559a:	f526                	sd	s1,168(sp)

  begin_op();
    8000559c:	8abfe0ef          	jal	80003e46 <begin_op>

  if(omode & O_CREATE){
    800055a0:	f4c42783          	lw	a5,-180(s0)
    800055a4:	2007f793          	andi	a5,a5,512
    800055a8:	c3dd                	beqz	a5,8000564e <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    800055aa:	4681                	li	a3,0
    800055ac:	4601                	li	a2,0
    800055ae:	4589                	li	a1,2
    800055b0:	f5040513          	addi	a0,s0,-176
    800055b4:	a99ff0ef          	jal	8000504c <create>
    800055b8:	84aa                	mv	s1,a0
    if(ip == 0){
    800055ba:	c549                	beqz	a0,80005644 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800055bc:	04449703          	lh	a4,68(s1)
    800055c0:	478d                	li	a5,3
    800055c2:	00f71763          	bne	a4,a5,800055d0 <sys_open+0x5e>
    800055c6:	0464d703          	lhu	a4,70(s1)
    800055ca:	47a5                	li	a5,9
    800055cc:	0ae7ee63          	bltu	a5,a4,80005688 <sys_open+0x116>
    800055d0:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800055d2:	bf1fe0ef          	jal	800041c2 <filealloc>
    800055d6:	892a                	mv	s2,a0
    800055d8:	c561                	beqz	a0,800056a0 <sys_open+0x12e>
    800055da:	ed4e                	sd	s3,152(sp)
    800055dc:	a33ff0ef          	jal	8000500e <fdalloc>
    800055e0:	89aa                	mv	s3,a0
    800055e2:	0a054b63          	bltz	a0,80005698 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800055e6:	04449703          	lh	a4,68(s1)
    800055ea:	478d                	li	a5,3
    800055ec:	0cf70363          	beq	a4,a5,800056b2 <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800055f0:	4789                	li	a5,2
    800055f2:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800055f6:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800055fa:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800055fe:	f4c42783          	lw	a5,-180(s0)
    80005602:	0017f713          	andi	a4,a5,1
    80005606:	00174713          	xori	a4,a4,1
    8000560a:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000560e:	0037f713          	andi	a4,a5,3
    80005612:	00e03733          	snez	a4,a4
    80005616:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000561a:	4007f793          	andi	a5,a5,1024
    8000561e:	c791                	beqz	a5,8000562a <sys_open+0xb8>
    80005620:	04449703          	lh	a4,68(s1)
    80005624:	4789                	li	a5,2
    80005626:	08f70d63          	beq	a4,a5,800056c0 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    8000562a:	8526                	mv	a0,s1
    8000562c:	816fe0ef          	jal	80003642 <iunlock>
  end_op();
    80005630:	881fe0ef          	jal	80003eb0 <end_op>

  return fd;
    80005634:	854e                	mv	a0,s3
    80005636:	74aa                	ld	s1,168(sp)
    80005638:	790a                	ld	s2,160(sp)
    8000563a:	69ea                	ld	s3,152(sp)
}
    8000563c:	70ea                	ld	ra,184(sp)
    8000563e:	744a                	ld	s0,176(sp)
    80005640:	6129                	addi	sp,sp,192
    80005642:	8082                	ret
      end_op();
    80005644:	86dfe0ef          	jal	80003eb0 <end_op>
      return -1;
    80005648:	557d                	li	a0,-1
    8000564a:	74aa                	ld	s1,168(sp)
    8000564c:	bfc5                	j	8000563c <sys_open+0xca>
    if((ip = namei(path)) == 0){
    8000564e:	f5040513          	addi	a0,s0,-176
    80005652:	e32fe0ef          	jal	80003c84 <namei>
    80005656:	84aa                	mv	s1,a0
    80005658:	c11d                	beqz	a0,8000567e <sys_open+0x10c>
    ilock(ip);
    8000565a:	f3bfd0ef          	jal	80003594 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000565e:	04449703          	lh	a4,68(s1)
    80005662:	4785                	li	a5,1
    80005664:	f4f71ce3          	bne	a4,a5,800055bc <sys_open+0x4a>
    80005668:	f4c42783          	lw	a5,-180(s0)
    8000566c:	d3b5                	beqz	a5,800055d0 <sys_open+0x5e>
      iunlockput(ip);
    8000566e:	8526                	mv	a0,s1
    80005670:	92efe0ef          	jal	8000379e <iunlockput>
      end_op();
    80005674:	83dfe0ef          	jal	80003eb0 <end_op>
      return -1;
    80005678:	557d                	li	a0,-1
    8000567a:	74aa                	ld	s1,168(sp)
    8000567c:	b7c1                	j	8000563c <sys_open+0xca>
      end_op();
    8000567e:	833fe0ef          	jal	80003eb0 <end_op>
      return -1;
    80005682:	557d                	li	a0,-1
    80005684:	74aa                	ld	s1,168(sp)
    80005686:	bf5d                	j	8000563c <sys_open+0xca>
    iunlockput(ip);
    80005688:	8526                	mv	a0,s1
    8000568a:	914fe0ef          	jal	8000379e <iunlockput>
    end_op();
    8000568e:	823fe0ef          	jal	80003eb0 <end_op>
    return -1;
    80005692:	557d                	li	a0,-1
    80005694:	74aa                	ld	s1,168(sp)
    80005696:	b75d                	j	8000563c <sys_open+0xca>
      fileclose(f);
    80005698:	854a                	mv	a0,s2
    8000569a:	bcdfe0ef          	jal	80004266 <fileclose>
    8000569e:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800056a0:	8526                	mv	a0,s1
    800056a2:	8fcfe0ef          	jal	8000379e <iunlockput>
    end_op();
    800056a6:	80bfe0ef          	jal	80003eb0 <end_op>
    return -1;
    800056aa:	557d                	li	a0,-1
    800056ac:	74aa                	ld	s1,168(sp)
    800056ae:	790a                	ld	s2,160(sp)
    800056b0:	b771                	j	8000563c <sys_open+0xca>
    f->type = FD_DEVICE;
    800056b2:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    800056b6:	04649783          	lh	a5,70(s1)
    800056ba:	02f91223          	sh	a5,36(s2)
    800056be:	bf35                	j	800055fa <sys_open+0x88>
    itrunc(ip);
    800056c0:	8526                	mv	a0,s1
    800056c2:	fc1fd0ef          	jal	80003682 <itrunc>
    800056c6:	b795                	j	8000562a <sys_open+0xb8>

00000000800056c8 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800056c8:	7175                	addi	sp,sp,-144
    800056ca:	e506                	sd	ra,136(sp)
    800056cc:	e122                	sd	s0,128(sp)
    800056ce:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800056d0:	f76fe0ef          	jal	80003e46 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800056d4:	08000613          	li	a2,128
    800056d8:	f7040593          	addi	a1,s0,-144
    800056dc:	4501                	li	a0,0
    800056de:	b28fd0ef          	jal	80002a06 <argstr>
    800056e2:	02054363          	bltz	a0,80005708 <sys_mkdir+0x40>
    800056e6:	4681                	li	a3,0
    800056e8:	4601                	li	a2,0
    800056ea:	4585                	li	a1,1
    800056ec:	f7040513          	addi	a0,s0,-144
    800056f0:	95dff0ef          	jal	8000504c <create>
    800056f4:	c911                	beqz	a0,80005708 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800056f6:	8a8fe0ef          	jal	8000379e <iunlockput>
  end_op();
    800056fa:	fb6fe0ef          	jal	80003eb0 <end_op>
  return 0;
    800056fe:	4501                	li	a0,0
}
    80005700:	60aa                	ld	ra,136(sp)
    80005702:	640a                	ld	s0,128(sp)
    80005704:	6149                	addi	sp,sp,144
    80005706:	8082                	ret
    end_op();
    80005708:	fa8fe0ef          	jal	80003eb0 <end_op>
    return -1;
    8000570c:	557d                	li	a0,-1
    8000570e:	bfcd                	j	80005700 <sys_mkdir+0x38>

0000000080005710 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005710:	7135                	addi	sp,sp,-160
    80005712:	ed06                	sd	ra,152(sp)
    80005714:	e922                	sd	s0,144(sp)
    80005716:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005718:	f2efe0ef          	jal	80003e46 <begin_op>
  argint(1, &major);
    8000571c:	f6c40593          	addi	a1,s0,-148
    80005720:	4505                	li	a0,1
    80005722:	aacfd0ef          	jal	800029ce <argint>
  argint(2, &minor);
    80005726:	f6840593          	addi	a1,s0,-152
    8000572a:	4509                	li	a0,2
    8000572c:	aa2fd0ef          	jal	800029ce <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005730:	08000613          	li	a2,128
    80005734:	f7040593          	addi	a1,s0,-144
    80005738:	4501                	li	a0,0
    8000573a:	accfd0ef          	jal	80002a06 <argstr>
    8000573e:	02054563          	bltz	a0,80005768 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005742:	f6841683          	lh	a3,-152(s0)
    80005746:	f6c41603          	lh	a2,-148(s0)
    8000574a:	458d                	li	a1,3
    8000574c:	f7040513          	addi	a0,s0,-144
    80005750:	8fdff0ef          	jal	8000504c <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005754:	c911                	beqz	a0,80005768 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005756:	848fe0ef          	jal	8000379e <iunlockput>
  end_op();
    8000575a:	f56fe0ef          	jal	80003eb0 <end_op>
  return 0;
    8000575e:	4501                	li	a0,0
}
    80005760:	60ea                	ld	ra,152(sp)
    80005762:	644a                	ld	s0,144(sp)
    80005764:	610d                	addi	sp,sp,160
    80005766:	8082                	ret
    end_op();
    80005768:	f48fe0ef          	jal	80003eb0 <end_op>
    return -1;
    8000576c:	557d                	li	a0,-1
    8000576e:	bfcd                	j	80005760 <sys_mknod+0x50>

0000000080005770 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005770:	7135                	addi	sp,sp,-160
    80005772:	ed06                	sd	ra,152(sp)
    80005774:	e922                	sd	s0,144(sp)
    80005776:	e14a                	sd	s2,128(sp)
    80005778:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000577a:	99afc0ef          	jal	80001914 <myproc>
    8000577e:	892a                	mv	s2,a0
  
  begin_op();
    80005780:	ec6fe0ef          	jal	80003e46 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005784:	08000613          	li	a2,128
    80005788:	f6040593          	addi	a1,s0,-160
    8000578c:	4501                	li	a0,0
    8000578e:	a78fd0ef          	jal	80002a06 <argstr>
    80005792:	04054363          	bltz	a0,800057d8 <sys_chdir+0x68>
    80005796:	e526                	sd	s1,136(sp)
    80005798:	f6040513          	addi	a0,s0,-160
    8000579c:	ce8fe0ef          	jal	80003c84 <namei>
    800057a0:	84aa                	mv	s1,a0
    800057a2:	c915                	beqz	a0,800057d6 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800057a4:	df1fd0ef          	jal	80003594 <ilock>
  if(ip->type != T_DIR){
    800057a8:	04449703          	lh	a4,68(s1)
    800057ac:	4785                	li	a5,1
    800057ae:	02f71963          	bne	a4,a5,800057e0 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800057b2:	8526                	mv	a0,s1
    800057b4:	e8ffd0ef          	jal	80003642 <iunlock>
  iput(p->cwd);
    800057b8:	15093503          	ld	a0,336(s2)
    800057bc:	f5bfd0ef          	jal	80003716 <iput>
  end_op();
    800057c0:	ef0fe0ef          	jal	80003eb0 <end_op>
  p->cwd = ip;
    800057c4:	14993823          	sd	s1,336(s2)
  return 0;
    800057c8:	4501                	li	a0,0
    800057ca:	64aa                	ld	s1,136(sp)
}
    800057cc:	60ea                	ld	ra,152(sp)
    800057ce:	644a                	ld	s0,144(sp)
    800057d0:	690a                	ld	s2,128(sp)
    800057d2:	610d                	addi	sp,sp,160
    800057d4:	8082                	ret
    800057d6:	64aa                	ld	s1,136(sp)
    end_op();
    800057d8:	ed8fe0ef          	jal	80003eb0 <end_op>
    return -1;
    800057dc:	557d                	li	a0,-1
    800057de:	b7fd                	j	800057cc <sys_chdir+0x5c>
    iunlockput(ip);
    800057e0:	8526                	mv	a0,s1
    800057e2:	fbdfd0ef          	jal	8000379e <iunlockput>
    end_op();
    800057e6:	ecafe0ef          	jal	80003eb0 <end_op>
    return -1;
    800057ea:	557d                	li	a0,-1
    800057ec:	64aa                	ld	s1,136(sp)
    800057ee:	bff9                	j	800057cc <sys_chdir+0x5c>

00000000800057f0 <sys_exec>:

uint64
sys_exec(void)
{
    800057f0:	7105                	addi	sp,sp,-480
    800057f2:	ef86                	sd	ra,472(sp)
    800057f4:	eba2                	sd	s0,464(sp)
    800057f6:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800057f8:	e2840593          	addi	a1,s0,-472
    800057fc:	4505                	li	a0,1
    800057fe:	9ecfd0ef          	jal	800029ea <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005802:	08000613          	li	a2,128
    80005806:	f3040593          	addi	a1,s0,-208
    8000580a:	4501                	li	a0,0
    8000580c:	9fafd0ef          	jal	80002a06 <argstr>
    80005810:	87aa                	mv	a5,a0
    return -1;
    80005812:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005814:	0e07c063          	bltz	a5,800058f4 <sys_exec+0x104>
    80005818:	e7a6                	sd	s1,456(sp)
    8000581a:	e3ca                	sd	s2,448(sp)
    8000581c:	ff4e                	sd	s3,440(sp)
    8000581e:	fb52                	sd	s4,432(sp)
    80005820:	f756                	sd	s5,424(sp)
    80005822:	f35a                	sd	s6,416(sp)
    80005824:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005826:	e3040a13          	addi	s4,s0,-464
    8000582a:	10000613          	li	a2,256
    8000582e:	4581                	li	a1,0
    80005830:	8552                	mv	a0,s4
    80005832:	cd4fb0ef          	jal	80000d06 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005836:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    80005838:	89d2                	mv	s3,s4
    8000583a:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000583c:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005840:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    80005842:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005846:	00391513          	slli	a0,s2,0x3
    8000584a:	85d6                	mv	a1,s5
    8000584c:	e2843783          	ld	a5,-472(s0)
    80005850:	953e                	add	a0,a0,a5
    80005852:	8f2fd0ef          	jal	80002944 <fetchaddr>
    80005856:	02054663          	bltz	a0,80005882 <sys_exec+0x92>
    if(uarg == 0){
    8000585a:	e2043783          	ld	a5,-480(s0)
    8000585e:	c7a1                	beqz	a5,800058a6 <sys_exec+0xb6>
    argv[i] = kalloc();
    80005860:	b02fb0ef          	jal	80000b62 <kalloc>
    80005864:	85aa                	mv	a1,a0
    80005866:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000586a:	cd01                	beqz	a0,80005882 <sys_exec+0x92>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000586c:	865a                	mv	a2,s6
    8000586e:	e2043503          	ld	a0,-480(s0)
    80005872:	91cfd0ef          	jal	8000298e <fetchstr>
    80005876:	00054663          	bltz	a0,80005882 <sys_exec+0x92>
    if(i >= NELEM(argv)){
    8000587a:	0905                	addi	s2,s2,1
    8000587c:	09a1                	addi	s3,s3,8
    8000587e:	fd7914e3          	bne	s2,s7,80005846 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005882:	100a0a13          	addi	s4,s4,256
    80005886:	6088                	ld	a0,0(s1)
    80005888:	cd31                	beqz	a0,800058e4 <sys_exec+0xf4>
    kfree(argv[i]);
    8000588a:	9f6fb0ef          	jal	80000a80 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000588e:	04a1                	addi	s1,s1,8
    80005890:	ff449be3          	bne	s1,s4,80005886 <sys_exec+0x96>
  return -1;
    80005894:	557d                	li	a0,-1
    80005896:	64be                	ld	s1,456(sp)
    80005898:	691e                	ld	s2,448(sp)
    8000589a:	79fa                	ld	s3,440(sp)
    8000589c:	7a5a                	ld	s4,432(sp)
    8000589e:	7aba                	ld	s5,424(sp)
    800058a0:	7b1a                	ld	s6,416(sp)
    800058a2:	6bfa                	ld	s7,408(sp)
    800058a4:	a881                	j	800058f4 <sys_exec+0x104>
      argv[i] = 0;
    800058a6:	0009079b          	sext.w	a5,s2
    800058aa:	e3040593          	addi	a1,s0,-464
    800058ae:	078e                	slli	a5,a5,0x3
    800058b0:	97ae                	add	a5,a5,a1
    800058b2:	0007b023          	sd	zero,0(a5)
  int ret = exec(path, argv);
    800058b6:	f3040513          	addi	a0,s0,-208
    800058ba:	878ff0ef          	jal	80004932 <exec>
    800058be:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800058c0:	100a0a13          	addi	s4,s4,256
    800058c4:	6088                	ld	a0,0(s1)
    800058c6:	c511                	beqz	a0,800058d2 <sys_exec+0xe2>
    kfree(argv[i]);
    800058c8:	9b8fb0ef          	jal	80000a80 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800058cc:	04a1                	addi	s1,s1,8
    800058ce:	ff449be3          	bne	s1,s4,800058c4 <sys_exec+0xd4>
  return ret;
    800058d2:	854a                	mv	a0,s2
    800058d4:	64be                	ld	s1,456(sp)
    800058d6:	691e                	ld	s2,448(sp)
    800058d8:	79fa                	ld	s3,440(sp)
    800058da:	7a5a                	ld	s4,432(sp)
    800058dc:	7aba                	ld	s5,424(sp)
    800058de:	7b1a                	ld	s6,416(sp)
    800058e0:	6bfa                	ld	s7,408(sp)
    800058e2:	a809                	j	800058f4 <sys_exec+0x104>
  return -1;
    800058e4:	557d                	li	a0,-1
    800058e6:	64be                	ld	s1,456(sp)
    800058e8:	691e                	ld	s2,448(sp)
    800058ea:	79fa                	ld	s3,440(sp)
    800058ec:	7a5a                	ld	s4,432(sp)
    800058ee:	7aba                	ld	s5,424(sp)
    800058f0:	7b1a                	ld	s6,416(sp)
    800058f2:	6bfa                	ld	s7,408(sp)
}
    800058f4:	60fe                	ld	ra,472(sp)
    800058f6:	645e                	ld	s0,464(sp)
    800058f8:	613d                	addi	sp,sp,480
    800058fa:	8082                	ret

00000000800058fc <sys_pipe>:

uint64
sys_pipe(void)
{
    800058fc:	7139                	addi	sp,sp,-64
    800058fe:	fc06                	sd	ra,56(sp)
    80005900:	f822                	sd	s0,48(sp)
    80005902:	f426                	sd	s1,40(sp)
    80005904:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005906:	80efc0ef          	jal	80001914 <myproc>
    8000590a:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000590c:	fd840593          	addi	a1,s0,-40
    80005910:	4501                	li	a0,0
    80005912:	8d8fd0ef          	jal	800029ea <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005916:	fc840593          	addi	a1,s0,-56
    8000591a:	fd040513          	addi	a0,s0,-48
    8000591e:	c59fe0ef          	jal	80004576 <pipealloc>
    return -1;
    80005922:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005924:	0a054463          	bltz	a0,800059cc <sys_pipe+0xd0>
  fd0 = -1;
    80005928:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000592c:	fd043503          	ld	a0,-48(s0)
    80005930:	edeff0ef          	jal	8000500e <fdalloc>
    80005934:	fca42223          	sw	a0,-60(s0)
    80005938:	08054163          	bltz	a0,800059ba <sys_pipe+0xbe>
    8000593c:	fc843503          	ld	a0,-56(s0)
    80005940:	eceff0ef          	jal	8000500e <fdalloc>
    80005944:	fca42023          	sw	a0,-64(s0)
    80005948:	06054063          	bltz	a0,800059a8 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000594c:	4691                	li	a3,4
    8000594e:	fc440613          	addi	a2,s0,-60
    80005952:	fd843583          	ld	a1,-40(s0)
    80005956:	68a8                	ld	a0,80(s1)
    80005958:	c65fb0ef          	jal	800015bc <copyout>
    8000595c:	00054e63          	bltz	a0,80005978 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005960:	4691                	li	a3,4
    80005962:	fc040613          	addi	a2,s0,-64
    80005966:	fd843583          	ld	a1,-40(s0)
    8000596a:	95b6                	add	a1,a1,a3
    8000596c:	68a8                	ld	a0,80(s1)
    8000596e:	c4ffb0ef          	jal	800015bc <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005972:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005974:	04055c63          	bgez	a0,800059cc <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005978:	fc442783          	lw	a5,-60(s0)
    8000597c:	07e9                	addi	a5,a5,26
    8000597e:	078e                	slli	a5,a5,0x3
    80005980:	97a6                	add	a5,a5,s1
    80005982:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005986:	fc042783          	lw	a5,-64(s0)
    8000598a:	07e9                	addi	a5,a5,26
    8000598c:	078e                	slli	a5,a5,0x3
    8000598e:	94be                	add	s1,s1,a5
    80005990:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005994:	fd043503          	ld	a0,-48(s0)
    80005998:	8cffe0ef          	jal	80004266 <fileclose>
    fileclose(wf);
    8000599c:	fc843503          	ld	a0,-56(s0)
    800059a0:	8c7fe0ef          	jal	80004266 <fileclose>
    return -1;
    800059a4:	57fd                	li	a5,-1
    800059a6:	a01d                	j	800059cc <sys_pipe+0xd0>
    if(fd0 >= 0)
    800059a8:	fc442783          	lw	a5,-60(s0)
    800059ac:	0007c763          	bltz	a5,800059ba <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800059b0:	07e9                	addi	a5,a5,26
    800059b2:	078e                	slli	a5,a5,0x3
    800059b4:	97a6                	add	a5,a5,s1
    800059b6:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800059ba:	fd043503          	ld	a0,-48(s0)
    800059be:	8a9fe0ef          	jal	80004266 <fileclose>
    fileclose(wf);
    800059c2:	fc843503          	ld	a0,-56(s0)
    800059c6:	8a1fe0ef          	jal	80004266 <fileclose>
    return -1;
    800059ca:	57fd                	li	a5,-1
}
    800059cc:	853e                	mv	a0,a5
    800059ce:	70e2                	ld	ra,56(sp)
    800059d0:	7442                	ld	s0,48(sp)
    800059d2:	74a2                	ld	s1,40(sp)
    800059d4:	6121                	addi	sp,sp,64
    800059d6:	8082                	ret
	...

00000000800059e0 <kernelvec>:
    800059e0:	7111                	addi	sp,sp,-256
    800059e2:	e006                	sd	ra,0(sp)
    800059e4:	e40a                	sd	sp,8(sp)
    800059e6:	e80e                	sd	gp,16(sp)
    800059e8:	ec12                	sd	tp,24(sp)
    800059ea:	f016                	sd	t0,32(sp)
    800059ec:	f41a                	sd	t1,40(sp)
    800059ee:	f81e                	sd	t2,48(sp)
    800059f0:	e4aa                	sd	a0,72(sp)
    800059f2:	e8ae                	sd	a1,80(sp)
    800059f4:	ecb2                	sd	a2,88(sp)
    800059f6:	f0b6                	sd	a3,96(sp)
    800059f8:	f4ba                	sd	a4,104(sp)
    800059fa:	f8be                	sd	a5,112(sp)
    800059fc:	fcc2                	sd	a6,120(sp)
    800059fe:	e146                	sd	a7,128(sp)
    80005a00:	edf2                	sd	t3,216(sp)
    80005a02:	f1f6                	sd	t4,224(sp)
    80005a04:	f5fa                	sd	t5,232(sp)
    80005a06:	f9fe                	sd	t6,240(sp)
    80005a08:	e4dfc0ef          	jal	80002854 <kerneltrap>
    80005a0c:	6082                	ld	ra,0(sp)
    80005a0e:	6122                	ld	sp,8(sp)
    80005a10:	61c2                	ld	gp,16(sp)
    80005a12:	7282                	ld	t0,32(sp)
    80005a14:	7322                	ld	t1,40(sp)
    80005a16:	73c2                	ld	t2,48(sp)
    80005a18:	6526                	ld	a0,72(sp)
    80005a1a:	65c6                	ld	a1,80(sp)
    80005a1c:	6666                	ld	a2,88(sp)
    80005a1e:	7686                	ld	a3,96(sp)
    80005a20:	7726                	ld	a4,104(sp)
    80005a22:	77c6                	ld	a5,112(sp)
    80005a24:	7866                	ld	a6,120(sp)
    80005a26:	688a                	ld	a7,128(sp)
    80005a28:	6e6e                	ld	t3,216(sp)
    80005a2a:	7e8e                	ld	t4,224(sp)
    80005a2c:	7f2e                	ld	t5,232(sp)
    80005a2e:	7fce                	ld	t6,240(sp)
    80005a30:	6111                	addi	sp,sp,256
    80005a32:	10200073          	sret
    80005a36:	00000013          	nop
    80005a3a:	00000013          	nop

0000000080005a3e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005a3e:	1141                	addi	sp,sp,-16
    80005a40:	e406                	sd	ra,8(sp)
    80005a42:	e022                	sd	s0,0(sp)
    80005a44:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005a46:	0c000737          	lui	a4,0xc000
    80005a4a:	4785                	li	a5,1
    80005a4c:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005a4e:	c35c                	sw	a5,4(a4)
}
    80005a50:	60a2                	ld	ra,8(sp)
    80005a52:	6402                	ld	s0,0(sp)
    80005a54:	0141                	addi	sp,sp,16
    80005a56:	8082                	ret

0000000080005a58 <plicinithart>:

void
plicinithart(void)
{
    80005a58:	1141                	addi	sp,sp,-16
    80005a5a:	e406                	sd	ra,8(sp)
    80005a5c:	e022                	sd	s0,0(sp)
    80005a5e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005a60:	e81fb0ef          	jal	800018e0 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005a64:	0085171b          	slliw	a4,a0,0x8
    80005a68:	0c0027b7          	lui	a5,0xc002
    80005a6c:	97ba                	add	a5,a5,a4
    80005a6e:	40200713          	li	a4,1026
    80005a72:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005a76:	00d5151b          	slliw	a0,a0,0xd
    80005a7a:	0c2017b7          	lui	a5,0xc201
    80005a7e:	97aa                	add	a5,a5,a0
    80005a80:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005a84:	60a2                	ld	ra,8(sp)
    80005a86:	6402                	ld	s0,0(sp)
    80005a88:	0141                	addi	sp,sp,16
    80005a8a:	8082                	ret

0000000080005a8c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005a8c:	1141                	addi	sp,sp,-16
    80005a8e:	e406                	sd	ra,8(sp)
    80005a90:	e022                	sd	s0,0(sp)
    80005a92:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005a94:	e4dfb0ef          	jal	800018e0 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005a98:	00d5151b          	slliw	a0,a0,0xd
    80005a9c:	0c2017b7          	lui	a5,0xc201
    80005aa0:	97aa                	add	a5,a5,a0
  return irq;
}
    80005aa2:	43c8                	lw	a0,4(a5)
    80005aa4:	60a2                	ld	ra,8(sp)
    80005aa6:	6402                	ld	s0,0(sp)
    80005aa8:	0141                	addi	sp,sp,16
    80005aaa:	8082                	ret

0000000080005aac <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005aac:	1101                	addi	sp,sp,-32
    80005aae:	ec06                	sd	ra,24(sp)
    80005ab0:	e822                	sd	s0,16(sp)
    80005ab2:	e426                	sd	s1,8(sp)
    80005ab4:	1000                	addi	s0,sp,32
    80005ab6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005ab8:	e29fb0ef          	jal	800018e0 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005abc:	00d5179b          	slliw	a5,a0,0xd
    80005ac0:	0c201737          	lui	a4,0xc201
    80005ac4:	97ba                	add	a5,a5,a4
    80005ac6:	c3c4                	sw	s1,4(a5)
}
    80005ac8:	60e2                	ld	ra,24(sp)
    80005aca:	6442                	ld	s0,16(sp)
    80005acc:	64a2                	ld	s1,8(sp)
    80005ace:	6105                	addi	sp,sp,32
    80005ad0:	8082                	ret

0000000080005ad2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005ad2:	1141                	addi	sp,sp,-16
    80005ad4:	e406                	sd	ra,8(sp)
    80005ad6:	e022                	sd	s0,0(sp)
    80005ad8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005ada:	479d                	li	a5,7
    80005adc:	04a7ca63          	blt	a5,a0,80005b30 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005ae0:	0001e797          	auipc	a5,0x1e
    80005ae4:	dc078793          	addi	a5,a5,-576 # 800238a0 <disk>
    80005ae8:	97aa                	add	a5,a5,a0
    80005aea:	0187c783          	lbu	a5,24(a5)
    80005aee:	e7b9                	bnez	a5,80005b3c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005af0:	00451693          	slli	a3,a0,0x4
    80005af4:	0001e797          	auipc	a5,0x1e
    80005af8:	dac78793          	addi	a5,a5,-596 # 800238a0 <disk>
    80005afc:	6398                	ld	a4,0(a5)
    80005afe:	9736                	add	a4,a4,a3
    80005b00:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    80005b04:	6398                	ld	a4,0(a5)
    80005b06:	9736                	add	a4,a4,a3
    80005b08:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005b0c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005b10:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005b14:	97aa                	add	a5,a5,a0
    80005b16:	4705                	li	a4,1
    80005b18:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005b1c:	0001e517          	auipc	a0,0x1e
    80005b20:	d9c50513          	addi	a0,a0,-612 # 800238b8 <disk+0x18>
    80005b24:	c0afc0ef          	jal	80001f2e <wakeup>
}
    80005b28:	60a2                	ld	ra,8(sp)
    80005b2a:	6402                	ld	s0,0(sp)
    80005b2c:	0141                	addi	sp,sp,16
    80005b2e:	8082                	ret
    panic("free_desc 1");
    80005b30:	00002517          	auipc	a0,0x2
    80005b34:	b4050513          	addi	a0,a0,-1216 # 80007670 <etext+0x670>
    80005b38:	c9ffa0ef          	jal	800007d6 <panic>
    panic("free_desc 2");
    80005b3c:	00002517          	auipc	a0,0x2
    80005b40:	b4450513          	addi	a0,a0,-1212 # 80007680 <etext+0x680>
    80005b44:	c93fa0ef          	jal	800007d6 <panic>

0000000080005b48 <virtio_disk_init>:
{
    80005b48:	1101                	addi	sp,sp,-32
    80005b4a:	ec06                	sd	ra,24(sp)
    80005b4c:	e822                	sd	s0,16(sp)
    80005b4e:	e426                	sd	s1,8(sp)
    80005b50:	e04a                	sd	s2,0(sp)
    80005b52:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005b54:	00002597          	auipc	a1,0x2
    80005b58:	b3c58593          	addi	a1,a1,-1220 # 80007690 <etext+0x690>
    80005b5c:	0001e517          	auipc	a0,0x1e
    80005b60:	e6c50513          	addi	a0,a0,-404 # 800239c8 <disk+0x128>
    80005b64:	84efb0ef          	jal	80000bb2 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005b68:	100017b7          	lui	a5,0x10001
    80005b6c:	4398                	lw	a4,0(a5)
    80005b6e:	2701                	sext.w	a4,a4
    80005b70:	747277b7          	lui	a5,0x74727
    80005b74:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005b78:	14f71863          	bne	a4,a5,80005cc8 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005b7c:	100017b7          	lui	a5,0x10001
    80005b80:	43dc                	lw	a5,4(a5)
    80005b82:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005b84:	4709                	li	a4,2
    80005b86:	14e79163          	bne	a5,a4,80005cc8 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005b8a:	100017b7          	lui	a5,0x10001
    80005b8e:	479c                	lw	a5,8(a5)
    80005b90:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005b92:	12e79b63          	bne	a5,a4,80005cc8 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005b96:	100017b7          	lui	a5,0x10001
    80005b9a:	47d8                	lw	a4,12(a5)
    80005b9c:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005b9e:	554d47b7          	lui	a5,0x554d4
    80005ba2:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005ba6:	12f71163          	bne	a4,a5,80005cc8 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005baa:	100017b7          	lui	a5,0x10001
    80005bae:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005bb2:	4705                	li	a4,1
    80005bb4:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005bb6:	470d                	li	a4,3
    80005bb8:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005bba:	10001737          	lui	a4,0x10001
    80005bbe:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005bc0:	c7ffe6b7          	lui	a3,0xc7ffe
    80005bc4:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdad7f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005bc8:	8f75                	and	a4,a4,a3
    80005bca:	100016b7          	lui	a3,0x10001
    80005bce:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005bd0:	472d                	li	a4,11
    80005bd2:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005bd4:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005bd8:	439c                	lw	a5,0(a5)
    80005bda:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005bde:	8ba1                	andi	a5,a5,8
    80005be0:	0e078a63          	beqz	a5,80005cd4 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005be4:	100017b7          	lui	a5,0x10001
    80005be8:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005bec:	43fc                	lw	a5,68(a5)
    80005bee:	2781                	sext.w	a5,a5
    80005bf0:	0e079863          	bnez	a5,80005ce0 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005bf4:	100017b7          	lui	a5,0x10001
    80005bf8:	5bdc                	lw	a5,52(a5)
    80005bfa:	2781                	sext.w	a5,a5
  if(max == 0)
    80005bfc:	0e078863          	beqz	a5,80005cec <virtio_disk_init+0x1a4>
  if(max < NUM)
    80005c00:	471d                	li	a4,7
    80005c02:	0ef77b63          	bgeu	a4,a5,80005cf8 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    80005c06:	f5dfa0ef          	jal	80000b62 <kalloc>
    80005c0a:	0001e497          	auipc	s1,0x1e
    80005c0e:	c9648493          	addi	s1,s1,-874 # 800238a0 <disk>
    80005c12:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005c14:	f4ffa0ef          	jal	80000b62 <kalloc>
    80005c18:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005c1a:	f49fa0ef          	jal	80000b62 <kalloc>
    80005c1e:	87aa                	mv	a5,a0
    80005c20:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005c22:	6088                	ld	a0,0(s1)
    80005c24:	0e050063          	beqz	a0,80005d04 <virtio_disk_init+0x1bc>
    80005c28:	0001e717          	auipc	a4,0x1e
    80005c2c:	c8073703          	ld	a4,-896(a4) # 800238a8 <disk+0x8>
    80005c30:	cb71                	beqz	a4,80005d04 <virtio_disk_init+0x1bc>
    80005c32:	cbe9                	beqz	a5,80005d04 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80005c34:	6605                	lui	a2,0x1
    80005c36:	4581                	li	a1,0
    80005c38:	8cefb0ef          	jal	80000d06 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005c3c:	0001e497          	auipc	s1,0x1e
    80005c40:	c6448493          	addi	s1,s1,-924 # 800238a0 <disk>
    80005c44:	6605                	lui	a2,0x1
    80005c46:	4581                	li	a1,0
    80005c48:	6488                	ld	a0,8(s1)
    80005c4a:	8bcfb0ef          	jal	80000d06 <memset>
  memset(disk.used, 0, PGSIZE);
    80005c4e:	6605                	lui	a2,0x1
    80005c50:	4581                	li	a1,0
    80005c52:	6888                	ld	a0,16(s1)
    80005c54:	8b2fb0ef          	jal	80000d06 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005c58:	100017b7          	lui	a5,0x10001
    80005c5c:	4721                	li	a4,8
    80005c5e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005c60:	4098                	lw	a4,0(s1)
    80005c62:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005c66:	40d8                	lw	a4,4(s1)
    80005c68:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005c6c:	649c                	ld	a5,8(s1)
    80005c6e:	0007869b          	sext.w	a3,a5
    80005c72:	10001737          	lui	a4,0x10001
    80005c76:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005c7a:	9781                	srai	a5,a5,0x20
    80005c7c:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005c80:	689c                	ld	a5,16(s1)
    80005c82:	0007869b          	sext.w	a3,a5
    80005c86:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005c8a:	9781                	srai	a5,a5,0x20
    80005c8c:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005c90:	4785                	li	a5,1
    80005c92:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005c94:	00f48c23          	sb	a5,24(s1)
    80005c98:	00f48ca3          	sb	a5,25(s1)
    80005c9c:	00f48d23          	sb	a5,26(s1)
    80005ca0:	00f48da3          	sb	a5,27(s1)
    80005ca4:	00f48e23          	sb	a5,28(s1)
    80005ca8:	00f48ea3          	sb	a5,29(s1)
    80005cac:	00f48f23          	sb	a5,30(s1)
    80005cb0:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005cb4:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005cb8:	07272823          	sw	s2,112(a4)
}
    80005cbc:	60e2                	ld	ra,24(sp)
    80005cbe:	6442                	ld	s0,16(sp)
    80005cc0:	64a2                	ld	s1,8(sp)
    80005cc2:	6902                	ld	s2,0(sp)
    80005cc4:	6105                	addi	sp,sp,32
    80005cc6:	8082                	ret
    panic("could not find virtio disk");
    80005cc8:	00002517          	auipc	a0,0x2
    80005ccc:	9d850513          	addi	a0,a0,-1576 # 800076a0 <etext+0x6a0>
    80005cd0:	b07fa0ef          	jal	800007d6 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005cd4:	00002517          	auipc	a0,0x2
    80005cd8:	9ec50513          	addi	a0,a0,-1556 # 800076c0 <etext+0x6c0>
    80005cdc:	afbfa0ef          	jal	800007d6 <panic>
    panic("virtio disk should not be ready");
    80005ce0:	00002517          	auipc	a0,0x2
    80005ce4:	a0050513          	addi	a0,a0,-1536 # 800076e0 <etext+0x6e0>
    80005ce8:	aeffa0ef          	jal	800007d6 <panic>
    panic("virtio disk has no queue 0");
    80005cec:	00002517          	auipc	a0,0x2
    80005cf0:	a1450513          	addi	a0,a0,-1516 # 80007700 <etext+0x700>
    80005cf4:	ae3fa0ef          	jal	800007d6 <panic>
    panic("virtio disk max queue too short");
    80005cf8:	00002517          	auipc	a0,0x2
    80005cfc:	a2850513          	addi	a0,a0,-1496 # 80007720 <etext+0x720>
    80005d00:	ad7fa0ef          	jal	800007d6 <panic>
    panic("virtio disk kalloc");
    80005d04:	00002517          	auipc	a0,0x2
    80005d08:	a3c50513          	addi	a0,a0,-1476 # 80007740 <etext+0x740>
    80005d0c:	acbfa0ef          	jal	800007d6 <panic>

0000000080005d10 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005d10:	711d                	addi	sp,sp,-96
    80005d12:	ec86                	sd	ra,88(sp)
    80005d14:	e8a2                	sd	s0,80(sp)
    80005d16:	e4a6                	sd	s1,72(sp)
    80005d18:	e0ca                	sd	s2,64(sp)
    80005d1a:	fc4e                	sd	s3,56(sp)
    80005d1c:	f852                	sd	s4,48(sp)
    80005d1e:	f456                	sd	s5,40(sp)
    80005d20:	f05a                	sd	s6,32(sp)
    80005d22:	ec5e                	sd	s7,24(sp)
    80005d24:	e862                	sd	s8,16(sp)
    80005d26:	1080                	addi	s0,sp,96
    80005d28:	89aa                	mv	s3,a0
    80005d2a:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005d2c:	00c52b83          	lw	s7,12(a0)
    80005d30:	001b9b9b          	slliw	s7,s7,0x1
    80005d34:	1b82                	slli	s7,s7,0x20
    80005d36:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80005d3a:	0001e517          	auipc	a0,0x1e
    80005d3e:	c8e50513          	addi	a0,a0,-882 # 800239c8 <disk+0x128>
    80005d42:	ef5fa0ef          	jal	80000c36 <acquire>
  for(int i = 0; i < NUM; i++){
    80005d46:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005d48:	0001ea97          	auipc	s5,0x1e
    80005d4c:	b58a8a93          	addi	s5,s5,-1192 # 800238a0 <disk>
  for(int i = 0; i < 3; i++){
    80005d50:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005d52:	5c7d                	li	s8,-1
    80005d54:	a095                	j	80005db8 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    80005d56:	00fa8733          	add	a4,s5,a5
    80005d5a:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005d5e:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005d60:	0207c563          	bltz	a5,80005d8a <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    80005d64:	2905                	addiw	s2,s2,1
    80005d66:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005d68:	05490c63          	beq	s2,s4,80005dc0 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    80005d6c:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005d6e:	0001e717          	auipc	a4,0x1e
    80005d72:	b3270713          	addi	a4,a4,-1230 # 800238a0 <disk>
    80005d76:	4781                	li	a5,0
    if(disk.free[i]){
    80005d78:	01874683          	lbu	a3,24(a4)
    80005d7c:	fee9                	bnez	a3,80005d56 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    80005d7e:	2785                	addiw	a5,a5,1
    80005d80:	0705                	addi	a4,a4,1
    80005d82:	fe979be3          	bne	a5,s1,80005d78 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005d86:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    80005d8a:	01205d63          	blez	s2,80005da4 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005d8e:	fa042503          	lw	a0,-96(s0)
    80005d92:	d41ff0ef          	jal	80005ad2 <free_desc>
      for(int j = 0; j < i; j++)
    80005d96:	4785                	li	a5,1
    80005d98:	0127d663          	bge	a5,s2,80005da4 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005d9c:	fa442503          	lw	a0,-92(s0)
    80005da0:	d33ff0ef          	jal	80005ad2 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005da4:	0001e597          	auipc	a1,0x1e
    80005da8:	c2458593          	addi	a1,a1,-988 # 800239c8 <disk+0x128>
    80005dac:	0001e517          	auipc	a0,0x1e
    80005db0:	b0c50513          	addi	a0,a0,-1268 # 800238b8 <disk+0x18>
    80005db4:	92efc0ef          	jal	80001ee2 <sleep>
  for(int i = 0; i < 3; i++){
    80005db8:	fa040613          	addi	a2,s0,-96
    80005dbc:	4901                	li	s2,0
    80005dbe:	b77d                	j	80005d6c <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005dc0:	fa042503          	lw	a0,-96(s0)
    80005dc4:	00451693          	slli	a3,a0,0x4

  if(write)
    80005dc8:	0001e797          	auipc	a5,0x1e
    80005dcc:	ad878793          	addi	a5,a5,-1320 # 800238a0 <disk>
    80005dd0:	00a50713          	addi	a4,a0,10
    80005dd4:	0712                	slli	a4,a4,0x4
    80005dd6:	973e                	add	a4,a4,a5
    80005dd8:	01603633          	snez	a2,s6
    80005ddc:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005dde:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005de2:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005de6:	6398                	ld	a4,0(a5)
    80005de8:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005dea:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005dee:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005df0:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005df2:	6390                	ld	a2,0(a5)
    80005df4:	00d605b3          	add	a1,a2,a3
    80005df8:	4741                	li	a4,16
    80005dfa:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005dfc:	4805                	li	a6,1
    80005dfe:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005e02:	fa442703          	lw	a4,-92(s0)
    80005e06:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005e0a:	0712                	slli	a4,a4,0x4
    80005e0c:	963a                	add	a2,a2,a4
    80005e0e:	05898593          	addi	a1,s3,88
    80005e12:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005e14:	0007b883          	ld	a7,0(a5)
    80005e18:	9746                	add	a4,a4,a7
    80005e1a:	40000613          	li	a2,1024
    80005e1e:	c710                	sw	a2,8(a4)
  if(write)
    80005e20:	001b3613          	seqz	a2,s6
    80005e24:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005e28:	01066633          	or	a2,a2,a6
    80005e2c:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005e30:	fa842583          	lw	a1,-88(s0)
    80005e34:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005e38:	00250613          	addi	a2,a0,2
    80005e3c:	0612                	slli	a2,a2,0x4
    80005e3e:	963e                	add	a2,a2,a5
    80005e40:	577d                	li	a4,-1
    80005e42:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005e46:	0592                	slli	a1,a1,0x4
    80005e48:	98ae                	add	a7,a7,a1
    80005e4a:	03068713          	addi	a4,a3,48
    80005e4e:	973e                	add	a4,a4,a5
    80005e50:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005e54:	6398                	ld	a4,0(a5)
    80005e56:	972e                	add	a4,a4,a1
    80005e58:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005e5c:	4689                	li	a3,2
    80005e5e:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005e62:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005e66:	0109a223          	sw	a6,4(s3)
  disk.info[idx[0]].b = b;
    80005e6a:	01363423          	sd	s3,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005e6e:	6794                	ld	a3,8(a5)
    80005e70:	0026d703          	lhu	a4,2(a3)
    80005e74:	8b1d                	andi	a4,a4,7
    80005e76:	0706                	slli	a4,a4,0x1
    80005e78:	96ba                	add	a3,a3,a4
    80005e7a:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005e7e:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005e82:	6798                	ld	a4,8(a5)
    80005e84:	00275783          	lhu	a5,2(a4)
    80005e88:	2785                	addiw	a5,a5,1
    80005e8a:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005e8e:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005e92:	100017b7          	lui	a5,0x10001
    80005e96:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005e9a:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    80005e9e:	0001e917          	auipc	s2,0x1e
    80005ea2:	b2a90913          	addi	s2,s2,-1238 # 800239c8 <disk+0x128>
  while(b->disk == 1) {
    80005ea6:	84c2                	mv	s1,a6
    80005ea8:	01079a63          	bne	a5,a6,80005ebc <virtio_disk_rw+0x1ac>
    sleep(b, &disk.vdisk_lock);
    80005eac:	85ca                	mv	a1,s2
    80005eae:	854e                	mv	a0,s3
    80005eb0:	832fc0ef          	jal	80001ee2 <sleep>
  while(b->disk == 1) {
    80005eb4:	0049a783          	lw	a5,4(s3)
    80005eb8:	fe978ae3          	beq	a5,s1,80005eac <virtio_disk_rw+0x19c>
  }

  disk.info[idx[0]].b = 0;
    80005ebc:	fa042903          	lw	s2,-96(s0)
    80005ec0:	00290713          	addi	a4,s2,2
    80005ec4:	0712                	slli	a4,a4,0x4
    80005ec6:	0001e797          	auipc	a5,0x1e
    80005eca:	9da78793          	addi	a5,a5,-1574 # 800238a0 <disk>
    80005ece:	97ba                	add	a5,a5,a4
    80005ed0:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005ed4:	0001e997          	auipc	s3,0x1e
    80005ed8:	9cc98993          	addi	s3,s3,-1588 # 800238a0 <disk>
    80005edc:	00491713          	slli	a4,s2,0x4
    80005ee0:	0009b783          	ld	a5,0(s3)
    80005ee4:	97ba                	add	a5,a5,a4
    80005ee6:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005eea:	854a                	mv	a0,s2
    80005eec:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005ef0:	be3ff0ef          	jal	80005ad2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005ef4:	8885                	andi	s1,s1,1
    80005ef6:	f0fd                	bnez	s1,80005edc <virtio_disk_rw+0x1cc>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005ef8:	0001e517          	auipc	a0,0x1e
    80005efc:	ad050513          	addi	a0,a0,-1328 # 800239c8 <disk+0x128>
    80005f00:	dcbfa0ef          	jal	80000cca <release>
}
    80005f04:	60e6                	ld	ra,88(sp)
    80005f06:	6446                	ld	s0,80(sp)
    80005f08:	64a6                	ld	s1,72(sp)
    80005f0a:	6906                	ld	s2,64(sp)
    80005f0c:	79e2                	ld	s3,56(sp)
    80005f0e:	7a42                	ld	s4,48(sp)
    80005f10:	7aa2                	ld	s5,40(sp)
    80005f12:	7b02                	ld	s6,32(sp)
    80005f14:	6be2                	ld	s7,24(sp)
    80005f16:	6c42                	ld	s8,16(sp)
    80005f18:	6125                	addi	sp,sp,96
    80005f1a:	8082                	ret

0000000080005f1c <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005f1c:	1101                	addi	sp,sp,-32
    80005f1e:	ec06                	sd	ra,24(sp)
    80005f20:	e822                	sd	s0,16(sp)
    80005f22:	e426                	sd	s1,8(sp)
    80005f24:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005f26:	0001e497          	auipc	s1,0x1e
    80005f2a:	97a48493          	addi	s1,s1,-1670 # 800238a0 <disk>
    80005f2e:	0001e517          	auipc	a0,0x1e
    80005f32:	a9a50513          	addi	a0,a0,-1382 # 800239c8 <disk+0x128>
    80005f36:	d01fa0ef          	jal	80000c36 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005f3a:	100017b7          	lui	a5,0x10001
    80005f3e:	53bc                	lw	a5,96(a5)
    80005f40:	8b8d                	andi	a5,a5,3
    80005f42:	10001737          	lui	a4,0x10001
    80005f46:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005f48:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005f4c:	689c                	ld	a5,16(s1)
    80005f4e:	0204d703          	lhu	a4,32(s1)
    80005f52:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005f56:	04f70663          	beq	a4,a5,80005fa2 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005f5a:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005f5e:	6898                	ld	a4,16(s1)
    80005f60:	0204d783          	lhu	a5,32(s1)
    80005f64:	8b9d                	andi	a5,a5,7
    80005f66:	078e                	slli	a5,a5,0x3
    80005f68:	97ba                	add	a5,a5,a4
    80005f6a:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005f6c:	00278713          	addi	a4,a5,2
    80005f70:	0712                	slli	a4,a4,0x4
    80005f72:	9726                	add	a4,a4,s1
    80005f74:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80005f78:	e321                	bnez	a4,80005fb8 <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005f7a:	0789                	addi	a5,a5,2
    80005f7c:	0792                	slli	a5,a5,0x4
    80005f7e:	97a6                	add	a5,a5,s1
    80005f80:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005f82:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005f86:	fa9fb0ef          	jal	80001f2e <wakeup>

    disk.used_idx += 1;
    80005f8a:	0204d783          	lhu	a5,32(s1)
    80005f8e:	2785                	addiw	a5,a5,1
    80005f90:	17c2                	slli	a5,a5,0x30
    80005f92:	93c1                	srli	a5,a5,0x30
    80005f94:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005f98:	6898                	ld	a4,16(s1)
    80005f9a:	00275703          	lhu	a4,2(a4)
    80005f9e:	faf71ee3          	bne	a4,a5,80005f5a <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005fa2:	0001e517          	auipc	a0,0x1e
    80005fa6:	a2650513          	addi	a0,a0,-1498 # 800239c8 <disk+0x128>
    80005faa:	d21fa0ef          	jal	80000cca <release>
}
    80005fae:	60e2                	ld	ra,24(sp)
    80005fb0:	6442                	ld	s0,16(sp)
    80005fb2:	64a2                	ld	s1,8(sp)
    80005fb4:	6105                	addi	sp,sp,32
    80005fb6:	8082                	ret
      panic("virtio_disk_intr status");
    80005fb8:	00001517          	auipc	a0,0x1
    80005fbc:	7a050513          	addi	a0,a0,1952 # 80007758 <etext+0x758>
    80005fc0:	817fa0ef          	jal	800007d6 <panic>
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
