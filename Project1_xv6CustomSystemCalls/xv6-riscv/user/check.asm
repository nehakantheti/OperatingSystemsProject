
user/_check:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "../kernel/types.h"
#include "user/user.h"
int main()
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
	printf("Replaced content of this child process through exec!!\n");
   8:	00001517          	auipc	a0,0x1
   c:	8a850513          	addi	a0,a0,-1880 # 8b0 <malloc+0xfe>
  10:	6ea000ef          	jal	6fa <printf>
	printf("Hello World\n");
  14:	00001517          	auipc	a0,0x1
  18:	8d450513          	addi	a0,a0,-1836 # 8e8 <malloc+0x136>
  1c:	6de000ef          	jal	6fa <printf>
	return 0;
}
  20:	4501                	li	a0,0
  22:	60a2                	ld	ra,8(sp)
  24:	6402                	ld	s0,0(sp)
  26:	0141                	addi	sp,sp,16
  28:	8082                	ret

000000000000002a <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
  2a:	1141                	addi	sp,sp,-16
  2c:	e406                	sd	ra,8(sp)
  2e:	e022                	sd	s0,0(sp)
  30:	0800                	addi	s0,sp,16
  extern int main();
  main();
  32:	fcfff0ef          	jal	0 <main>
  exit(0);
  36:	4501                	li	a0,0
  38:	290000ef          	jal	2c8 <exit>

000000000000003c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  3c:	1141                	addi	sp,sp,-16
  3e:	e406                	sd	ra,8(sp)
  40:	e022                	sd	s0,0(sp)
  42:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  44:	87aa                	mv	a5,a0
  46:	0585                	addi	a1,a1,1
  48:	0785                	addi	a5,a5,1
  4a:	fff5c703          	lbu	a4,-1(a1)
  4e:	fee78fa3          	sb	a4,-1(a5)
  52:	fb75                	bnez	a4,46 <strcpy+0xa>
    ;
  return os;
}
  54:	60a2                	ld	ra,8(sp)
  56:	6402                	ld	s0,0(sp)
  58:	0141                	addi	sp,sp,16
  5a:	8082                	ret

000000000000005c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  5c:	1141                	addi	sp,sp,-16
  5e:	e406                	sd	ra,8(sp)
  60:	e022                	sd	s0,0(sp)
  62:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  64:	00054783          	lbu	a5,0(a0)
  68:	cb91                	beqz	a5,7c <strcmp+0x20>
  6a:	0005c703          	lbu	a4,0(a1)
  6e:	00f71763          	bne	a4,a5,7c <strcmp+0x20>
    p++, q++;
  72:	0505                	addi	a0,a0,1
  74:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  76:	00054783          	lbu	a5,0(a0)
  7a:	fbe5                	bnez	a5,6a <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  7c:	0005c503          	lbu	a0,0(a1)
}
  80:	40a7853b          	subw	a0,a5,a0
  84:	60a2                	ld	ra,8(sp)
  86:	6402                	ld	s0,0(sp)
  88:	0141                	addi	sp,sp,16
  8a:	8082                	ret

000000000000008c <strlen>:

uint
strlen(const char *s)
{
  8c:	1141                	addi	sp,sp,-16
  8e:	e406                	sd	ra,8(sp)
  90:	e022                	sd	s0,0(sp)
  92:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  94:	00054783          	lbu	a5,0(a0)
  98:	cf99                	beqz	a5,b6 <strlen+0x2a>
  9a:	0505                	addi	a0,a0,1
  9c:	87aa                	mv	a5,a0
  9e:	86be                	mv	a3,a5
  a0:	0785                	addi	a5,a5,1
  a2:	fff7c703          	lbu	a4,-1(a5)
  a6:	ff65                	bnez	a4,9e <strlen+0x12>
  a8:	40a6853b          	subw	a0,a3,a0
  ac:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  ae:	60a2                	ld	ra,8(sp)
  b0:	6402                	ld	s0,0(sp)
  b2:	0141                	addi	sp,sp,16
  b4:	8082                	ret
  for(n = 0; s[n]; n++)
  b6:	4501                	li	a0,0
  b8:	bfdd                	j	ae <strlen+0x22>

00000000000000ba <memset>:

void*
memset(void *dst, int c, uint n)
{
  ba:	1141                	addi	sp,sp,-16
  bc:	e406                	sd	ra,8(sp)
  be:	e022                	sd	s0,0(sp)
  c0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  c2:	ca19                	beqz	a2,d8 <memset+0x1e>
  c4:	87aa                	mv	a5,a0
  c6:	1602                	slli	a2,a2,0x20
  c8:	9201                	srli	a2,a2,0x20
  ca:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  ce:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  d2:	0785                	addi	a5,a5,1
  d4:	fee79de3          	bne	a5,a4,ce <memset+0x14>
  }
  return dst;
}
  d8:	60a2                	ld	ra,8(sp)
  da:	6402                	ld	s0,0(sp)
  dc:	0141                	addi	sp,sp,16
  de:	8082                	ret

00000000000000e0 <strchr>:

char*
strchr(const char *s, char c)
{
  e0:	1141                	addi	sp,sp,-16
  e2:	e406                	sd	ra,8(sp)
  e4:	e022                	sd	s0,0(sp)
  e6:	0800                	addi	s0,sp,16
  for(; *s; s++)
  e8:	00054783          	lbu	a5,0(a0)
  ec:	cf81                	beqz	a5,104 <strchr+0x24>
    if(*s == c)
  ee:	00f58763          	beq	a1,a5,fc <strchr+0x1c>
  for(; *s; s++)
  f2:	0505                	addi	a0,a0,1
  f4:	00054783          	lbu	a5,0(a0)
  f8:	fbfd                	bnez	a5,ee <strchr+0xe>
      return (char*)s;
  return 0;
  fa:	4501                	li	a0,0
}
  fc:	60a2                	ld	ra,8(sp)
  fe:	6402                	ld	s0,0(sp)
 100:	0141                	addi	sp,sp,16
 102:	8082                	ret
  return 0;
 104:	4501                	li	a0,0
 106:	bfdd                	j	fc <strchr+0x1c>

0000000000000108 <gets>:

char*
gets(char *buf, int max)
{
 108:	7159                	addi	sp,sp,-112
 10a:	f486                	sd	ra,104(sp)
 10c:	f0a2                	sd	s0,96(sp)
 10e:	eca6                	sd	s1,88(sp)
 110:	e8ca                	sd	s2,80(sp)
 112:	e4ce                	sd	s3,72(sp)
 114:	e0d2                	sd	s4,64(sp)
 116:	fc56                	sd	s5,56(sp)
 118:	f85a                	sd	s6,48(sp)
 11a:	f45e                	sd	s7,40(sp)
 11c:	f062                	sd	s8,32(sp)
 11e:	ec66                	sd	s9,24(sp)
 120:	e86a                	sd	s10,16(sp)
 122:	1880                	addi	s0,sp,112
 124:	8caa                	mv	s9,a0
 126:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 128:	892a                	mv	s2,a0
 12a:	4481                	li	s1,0
    cc = read(0, &c, 1);
 12c:	f9f40b13          	addi	s6,s0,-97
 130:	4a85                	li	s5,1
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 132:	4ba9                	li	s7,10
 134:	4c35                	li	s8,13
  for(i=0; i+1 < max; ){
 136:	8d26                	mv	s10,s1
 138:	0014899b          	addiw	s3,s1,1
 13c:	84ce                	mv	s1,s3
 13e:	0349d563          	bge	s3,s4,168 <gets+0x60>
    cc = read(0, &c, 1);
 142:	8656                	mv	a2,s5
 144:	85da                	mv	a1,s6
 146:	4501                	li	a0,0
 148:	198000ef          	jal	2e0 <read>
    if(cc < 1)
 14c:	00a05e63          	blez	a0,168 <gets+0x60>
    buf[i++] = c;
 150:	f9f44783          	lbu	a5,-97(s0)
 154:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 158:	01778763          	beq	a5,s7,166 <gets+0x5e>
 15c:	0905                	addi	s2,s2,1
 15e:	fd879ce3          	bne	a5,s8,136 <gets+0x2e>
    buf[i++] = c;
 162:	8d4e                	mv	s10,s3
 164:	a011                	j	168 <gets+0x60>
 166:	8d4e                	mv	s10,s3
      break;
  }
  buf[i] = '\0';
 168:	9d66                	add	s10,s10,s9
 16a:	000d0023          	sb	zero,0(s10)
  return buf;
}
 16e:	8566                	mv	a0,s9
 170:	70a6                	ld	ra,104(sp)
 172:	7406                	ld	s0,96(sp)
 174:	64e6                	ld	s1,88(sp)
 176:	6946                	ld	s2,80(sp)
 178:	69a6                	ld	s3,72(sp)
 17a:	6a06                	ld	s4,64(sp)
 17c:	7ae2                	ld	s5,56(sp)
 17e:	7b42                	ld	s6,48(sp)
 180:	7ba2                	ld	s7,40(sp)
 182:	7c02                	ld	s8,32(sp)
 184:	6ce2                	ld	s9,24(sp)
 186:	6d42                	ld	s10,16(sp)
 188:	6165                	addi	sp,sp,112
 18a:	8082                	ret

000000000000018c <stat>:

int
stat(const char *n, struct stat *st)
{
 18c:	1101                	addi	sp,sp,-32
 18e:	ec06                	sd	ra,24(sp)
 190:	e822                	sd	s0,16(sp)
 192:	e04a                	sd	s2,0(sp)
 194:	1000                	addi	s0,sp,32
 196:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 198:	4581                	li	a1,0
 19a:	16e000ef          	jal	308 <open>
  if(fd < 0)
 19e:	02054263          	bltz	a0,1c2 <stat+0x36>
 1a2:	e426                	sd	s1,8(sp)
 1a4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1a6:	85ca                	mv	a1,s2
 1a8:	178000ef          	jal	320 <fstat>
 1ac:	892a                	mv	s2,a0
  close(fd);
 1ae:	8526                	mv	a0,s1
 1b0:	140000ef          	jal	2f0 <close>
  return r;
 1b4:	64a2                	ld	s1,8(sp)
}
 1b6:	854a                	mv	a0,s2
 1b8:	60e2                	ld	ra,24(sp)
 1ba:	6442                	ld	s0,16(sp)
 1bc:	6902                	ld	s2,0(sp)
 1be:	6105                	addi	sp,sp,32
 1c0:	8082                	ret
    return -1;
 1c2:	597d                	li	s2,-1
 1c4:	bfcd                	j	1b6 <stat+0x2a>

00000000000001c6 <atoi>:

int
atoi(const char *s)
{
 1c6:	1141                	addi	sp,sp,-16
 1c8:	e406                	sd	ra,8(sp)
 1ca:	e022                	sd	s0,0(sp)
 1cc:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1ce:	00054683          	lbu	a3,0(a0)
 1d2:	fd06879b          	addiw	a5,a3,-48
 1d6:	0ff7f793          	zext.b	a5,a5
 1da:	4625                	li	a2,9
 1dc:	02f66963          	bltu	a2,a5,20e <atoi+0x48>
 1e0:	872a                	mv	a4,a0
  n = 0;
 1e2:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1e4:	0705                	addi	a4,a4,1
 1e6:	0025179b          	slliw	a5,a0,0x2
 1ea:	9fa9                	addw	a5,a5,a0
 1ec:	0017979b          	slliw	a5,a5,0x1
 1f0:	9fb5                	addw	a5,a5,a3
 1f2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1f6:	00074683          	lbu	a3,0(a4)
 1fa:	fd06879b          	addiw	a5,a3,-48
 1fe:	0ff7f793          	zext.b	a5,a5
 202:	fef671e3          	bgeu	a2,a5,1e4 <atoi+0x1e>
  return n;
}
 206:	60a2                	ld	ra,8(sp)
 208:	6402                	ld	s0,0(sp)
 20a:	0141                	addi	sp,sp,16
 20c:	8082                	ret
  n = 0;
 20e:	4501                	li	a0,0
 210:	bfdd                	j	206 <atoi+0x40>

0000000000000212 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 212:	1141                	addi	sp,sp,-16
 214:	e406                	sd	ra,8(sp)
 216:	e022                	sd	s0,0(sp)
 218:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 21a:	02b57563          	bgeu	a0,a1,244 <memmove+0x32>
    while(n-- > 0)
 21e:	00c05f63          	blez	a2,23c <memmove+0x2a>
 222:	1602                	slli	a2,a2,0x20
 224:	9201                	srli	a2,a2,0x20
 226:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 22a:	872a                	mv	a4,a0
      *dst++ = *src++;
 22c:	0585                	addi	a1,a1,1
 22e:	0705                	addi	a4,a4,1
 230:	fff5c683          	lbu	a3,-1(a1)
 234:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 238:	fee79ae3          	bne	a5,a4,22c <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 23c:	60a2                	ld	ra,8(sp)
 23e:	6402                	ld	s0,0(sp)
 240:	0141                	addi	sp,sp,16
 242:	8082                	ret
    dst += n;
 244:	00c50733          	add	a4,a0,a2
    src += n;
 248:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 24a:	fec059e3          	blez	a2,23c <memmove+0x2a>
 24e:	fff6079b          	addiw	a5,a2,-1
 252:	1782                	slli	a5,a5,0x20
 254:	9381                	srli	a5,a5,0x20
 256:	fff7c793          	not	a5,a5
 25a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 25c:	15fd                	addi	a1,a1,-1
 25e:	177d                	addi	a4,a4,-1
 260:	0005c683          	lbu	a3,0(a1)
 264:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 268:	fef71ae3          	bne	a4,a5,25c <memmove+0x4a>
 26c:	bfc1                	j	23c <memmove+0x2a>

000000000000026e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 26e:	1141                	addi	sp,sp,-16
 270:	e406                	sd	ra,8(sp)
 272:	e022                	sd	s0,0(sp)
 274:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 276:	ca0d                	beqz	a2,2a8 <memcmp+0x3a>
 278:	fff6069b          	addiw	a3,a2,-1
 27c:	1682                	slli	a3,a3,0x20
 27e:	9281                	srli	a3,a3,0x20
 280:	0685                	addi	a3,a3,1
 282:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 284:	00054783          	lbu	a5,0(a0)
 288:	0005c703          	lbu	a4,0(a1)
 28c:	00e79863          	bne	a5,a4,29c <memcmp+0x2e>
      return *p1 - *p2;
    }
    p1++;
 290:	0505                	addi	a0,a0,1
    p2++;
 292:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 294:	fed518e3          	bne	a0,a3,284 <memcmp+0x16>
  }
  return 0;
 298:	4501                	li	a0,0
 29a:	a019                	j	2a0 <memcmp+0x32>
      return *p1 - *p2;
 29c:	40e7853b          	subw	a0,a5,a4
}
 2a0:	60a2                	ld	ra,8(sp)
 2a2:	6402                	ld	s0,0(sp)
 2a4:	0141                	addi	sp,sp,16
 2a6:	8082                	ret
  return 0;
 2a8:	4501                	li	a0,0
 2aa:	bfdd                	j	2a0 <memcmp+0x32>

00000000000002ac <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2ac:	1141                	addi	sp,sp,-16
 2ae:	e406                	sd	ra,8(sp)
 2b0:	e022                	sd	s0,0(sp)
 2b2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2b4:	f5fff0ef          	jal	212 <memmove>
}
 2b8:	60a2                	ld	ra,8(sp)
 2ba:	6402                	ld	s0,0(sp)
 2bc:	0141                	addi	sp,sp,16
 2be:	8082                	ret

00000000000002c0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2c0:	4885                	li	a7,1
 ecall
 2c2:	00000073          	ecall
 ret
 2c6:	8082                	ret

00000000000002c8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2c8:	4889                	li	a7,2
 ecall
 2ca:	00000073          	ecall
 ret
 2ce:	8082                	ret

00000000000002d0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2d0:	488d                	li	a7,3
 ecall
 2d2:	00000073          	ecall
 ret
 2d6:	8082                	ret

00000000000002d8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2d8:	4891                	li	a7,4
 ecall
 2da:	00000073          	ecall
 ret
 2de:	8082                	ret

00000000000002e0 <read>:
.global read
read:
 li a7, SYS_read
 2e0:	4895                	li	a7,5
 ecall
 2e2:	00000073          	ecall
 ret
 2e6:	8082                	ret

00000000000002e8 <write>:
.global write
write:
 li a7, SYS_write
 2e8:	48c1                	li	a7,16
 ecall
 2ea:	00000073          	ecall
 ret
 2ee:	8082                	ret

00000000000002f0 <close>:
.global close
close:
 li a7, SYS_close
 2f0:	48d5                	li	a7,21
 ecall
 2f2:	00000073          	ecall
 ret
 2f6:	8082                	ret

00000000000002f8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2f8:	4899                	li	a7,6
 ecall
 2fa:	00000073          	ecall
 ret
 2fe:	8082                	ret

0000000000000300 <exec>:
.global exec
exec:
 li a7, SYS_exec
 300:	489d                	li	a7,7
 ecall
 302:	00000073          	ecall
 ret
 306:	8082                	ret

0000000000000308 <open>:
.global open
open:
 li a7, SYS_open
 308:	48bd                	li	a7,15
 ecall
 30a:	00000073          	ecall
 ret
 30e:	8082                	ret

0000000000000310 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 310:	48c5                	li	a7,17
 ecall
 312:	00000073          	ecall
 ret
 316:	8082                	ret

0000000000000318 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 318:	48c9                	li	a7,18
 ecall
 31a:	00000073          	ecall
 ret
 31e:	8082                	ret

0000000000000320 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 320:	48a1                	li	a7,8
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <link>:
.global link
link:
 li a7, SYS_link
 328:	48cd                	li	a7,19
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 330:	48d1                	li	a7,20
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 338:	48a5                	li	a7,9
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <dup>:
.global dup
dup:
 li a7, SYS_dup
 340:	48a9                	li	a7,10
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 348:	48ad                	li	a7,11
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 350:	48b1                	li	a7,12
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 358:	48b5                	li	a7,13
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 360:	48b9                	li	a7,14
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <forex>:
.global forex
forex:
 li a7, SYS_forex
 368:	48d9                	li	a7,22
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 370:	48dd                	li	a7,23
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <usleep>:
.global usleep
usleep:
 li a7, SYS_usleep
 378:	48e1                	li	a7,24
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 380:	48e5                	li	a7,25
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <sigstop>:
.global sigstop
sigstop:
 li a7, SYS_sigstop
 388:	48e9                	li	a7,26
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <sigcont>:
.global sigcont
sigcont:
 li a7, SYS_sigcont
 390:	48ed                	li	a7,27
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 398:	1101                	addi	sp,sp,-32
 39a:	ec06                	sd	ra,24(sp)
 39c:	e822                	sd	s0,16(sp)
 39e:	1000                	addi	s0,sp,32
 3a0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3a4:	4605                	li	a2,1
 3a6:	fef40593          	addi	a1,s0,-17
 3aa:	f3fff0ef          	jal	2e8 <write>
}
 3ae:	60e2                	ld	ra,24(sp)
 3b0:	6442                	ld	s0,16(sp)
 3b2:	6105                	addi	sp,sp,32
 3b4:	8082                	ret

00000000000003b6 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3b6:	7139                	addi	sp,sp,-64
 3b8:	fc06                	sd	ra,56(sp)
 3ba:	f822                	sd	s0,48(sp)
 3bc:	f426                	sd	s1,40(sp)
 3be:	f04a                	sd	s2,32(sp)
 3c0:	ec4e                	sd	s3,24(sp)
 3c2:	0080                	addi	s0,sp,64
 3c4:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3c6:	c299                	beqz	a3,3cc <printint+0x16>
 3c8:	0605ce63          	bltz	a1,444 <printint+0x8e>
  neg = 0;
 3cc:	4e01                	li	t3,0
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 3ce:	fc040313          	addi	t1,s0,-64
  neg = 0;
 3d2:	869a                	mv	a3,t1
  i = 0;
 3d4:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 3d6:	00000817          	auipc	a6,0x0
 3da:	52a80813          	addi	a6,a6,1322 # 900 <digits>
 3de:	88be                	mv	a7,a5
 3e0:	0017851b          	addiw	a0,a5,1
 3e4:	87aa                	mv	a5,a0
 3e6:	02c5f73b          	remuw	a4,a1,a2
 3ea:	1702                	slli	a4,a4,0x20
 3ec:	9301                	srli	a4,a4,0x20
 3ee:	9742                	add	a4,a4,a6
 3f0:	00074703          	lbu	a4,0(a4)
 3f4:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 3f8:	872e                	mv	a4,a1
 3fa:	02c5d5bb          	divuw	a1,a1,a2
 3fe:	0685                	addi	a3,a3,1
 400:	fcc77fe3          	bgeu	a4,a2,3de <printint+0x28>
  if(neg)
 404:	000e0c63          	beqz	t3,41c <printint+0x66>
    buf[i++] = '-';
 408:	fd050793          	addi	a5,a0,-48
 40c:	00878533          	add	a0,a5,s0
 410:	02d00793          	li	a5,45
 414:	fef50823          	sb	a5,-16(a0)
 418:	0028879b          	addiw	a5,a7,2

  while(--i >= 0)
 41c:	fff7899b          	addiw	s3,a5,-1
 420:	006784b3          	add	s1,a5,t1
    putc(fd, buf[i]);
 424:	fff4c583          	lbu	a1,-1(s1)
 428:	854a                	mv	a0,s2
 42a:	f6fff0ef          	jal	398 <putc>
  while(--i >= 0)
 42e:	39fd                	addiw	s3,s3,-1
 430:	14fd                	addi	s1,s1,-1
 432:	fe09d9e3          	bgez	s3,424 <printint+0x6e>
}
 436:	70e2                	ld	ra,56(sp)
 438:	7442                	ld	s0,48(sp)
 43a:	74a2                	ld	s1,40(sp)
 43c:	7902                	ld	s2,32(sp)
 43e:	69e2                	ld	s3,24(sp)
 440:	6121                	addi	sp,sp,64
 442:	8082                	ret
    x = -xx;
 444:	40b005bb          	negw	a1,a1
    neg = 1;
 448:	4e05                	li	t3,1
    x = -xx;
 44a:	b751                	j	3ce <printint+0x18>

000000000000044c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 44c:	711d                	addi	sp,sp,-96
 44e:	ec86                	sd	ra,88(sp)
 450:	e8a2                	sd	s0,80(sp)
 452:	e4a6                	sd	s1,72(sp)
 454:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 456:	0005c483          	lbu	s1,0(a1)
 45a:	26048663          	beqz	s1,6c6 <vprintf+0x27a>
 45e:	e0ca                	sd	s2,64(sp)
 460:	fc4e                	sd	s3,56(sp)
 462:	f852                	sd	s4,48(sp)
 464:	f456                	sd	s5,40(sp)
 466:	f05a                	sd	s6,32(sp)
 468:	ec5e                	sd	s7,24(sp)
 46a:	e862                	sd	s8,16(sp)
 46c:	e466                	sd	s9,8(sp)
 46e:	8b2a                	mv	s6,a0
 470:	8a2e                	mv	s4,a1
 472:	8bb2                	mv	s7,a2
  state = 0;
 474:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 476:	4901                	li	s2,0
 478:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 47a:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 47e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 482:	06c00c93          	li	s9,108
 486:	a00d                	j	4a8 <vprintf+0x5c>
        putc(fd, c0);
 488:	85a6                	mv	a1,s1
 48a:	855a                	mv	a0,s6
 48c:	f0dff0ef          	jal	398 <putc>
 490:	a019                	j	496 <vprintf+0x4a>
    } else if(state == '%'){
 492:	03598363          	beq	s3,s5,4b8 <vprintf+0x6c>
  for(i = 0; fmt[i]; i++){
 496:	0019079b          	addiw	a5,s2,1
 49a:	893e                	mv	s2,a5
 49c:	873e                	mv	a4,a5
 49e:	97d2                	add	a5,a5,s4
 4a0:	0007c483          	lbu	s1,0(a5)
 4a4:	20048963          	beqz	s1,6b6 <vprintf+0x26a>
    c0 = fmt[i] & 0xff;
 4a8:	0004879b          	sext.w	a5,s1
    if(state == 0){
 4ac:	fe0993e3          	bnez	s3,492 <vprintf+0x46>
      if(c0 == '%'){
 4b0:	fd579ce3          	bne	a5,s5,488 <vprintf+0x3c>
        state = '%';
 4b4:	89be                	mv	s3,a5
 4b6:	b7c5                	j	496 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 4b8:	00ea06b3          	add	a3,s4,a4
 4bc:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 4c0:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 4c2:	c681                	beqz	a3,4ca <vprintf+0x7e>
 4c4:	9752                	add	a4,a4,s4
 4c6:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 4ca:	03878e63          	beq	a5,s8,506 <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 4ce:	05978863          	beq	a5,s9,51e <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4d2:	07500713          	li	a4,117
 4d6:	0ee78263          	beq	a5,a4,5ba <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 4da:	07800713          	li	a4,120
 4de:	12e78463          	beq	a5,a4,606 <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 4e2:	07000713          	li	a4,112
 4e6:	14e78963          	beq	a5,a4,638 <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 4ea:	07300713          	li	a4,115
 4ee:	18e78863          	beq	a5,a4,67e <vprintf+0x232>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 4f2:	02500713          	li	a4,37
 4f6:	04e79463          	bne	a5,a4,53e <vprintf+0xf2>
        putc(fd, '%');
 4fa:	85ba                	mv	a1,a4
 4fc:	855a                	mv	a0,s6
 4fe:	e9bff0ef          	jal	398 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 502:	4981                	li	s3,0
 504:	bf49                	j	496 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 506:	008b8493          	addi	s1,s7,8
 50a:	4685                	li	a3,1
 50c:	4629                	li	a2,10
 50e:	000ba583          	lw	a1,0(s7)
 512:	855a                	mv	a0,s6
 514:	ea3ff0ef          	jal	3b6 <printint>
 518:	8ba6                	mv	s7,s1
      state = 0;
 51a:	4981                	li	s3,0
 51c:	bfad                	j	496 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 51e:	06400793          	li	a5,100
 522:	02f68963          	beq	a3,a5,554 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 526:	06c00793          	li	a5,108
 52a:	04f68263          	beq	a3,a5,56e <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 52e:	07500793          	li	a5,117
 532:	0af68063          	beq	a3,a5,5d2 <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 536:	07800793          	li	a5,120
 53a:	0ef68263          	beq	a3,a5,61e <vprintf+0x1d2>
        putc(fd, '%');
 53e:	02500593          	li	a1,37
 542:	855a                	mv	a0,s6
 544:	e55ff0ef          	jal	398 <putc>
        putc(fd, c0);
 548:	85a6                	mv	a1,s1
 54a:	855a                	mv	a0,s6
 54c:	e4dff0ef          	jal	398 <putc>
      state = 0;
 550:	4981                	li	s3,0
 552:	b791                	j	496 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 554:	008b8493          	addi	s1,s7,8
 558:	4685                	li	a3,1
 55a:	4629                	li	a2,10
 55c:	000ba583          	lw	a1,0(s7)
 560:	855a                	mv	a0,s6
 562:	e55ff0ef          	jal	3b6 <printint>
        i += 1;
 566:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 568:	8ba6                	mv	s7,s1
      state = 0;
 56a:	4981                	li	s3,0
        i += 1;
 56c:	b72d                	j	496 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 56e:	06400793          	li	a5,100
 572:	02f60763          	beq	a2,a5,5a0 <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 576:	07500793          	li	a5,117
 57a:	06f60963          	beq	a2,a5,5ec <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 57e:	07800793          	li	a5,120
 582:	faf61ee3          	bne	a2,a5,53e <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 586:	008b8493          	addi	s1,s7,8
 58a:	4681                	li	a3,0
 58c:	4641                	li	a2,16
 58e:	000ba583          	lw	a1,0(s7)
 592:	855a                	mv	a0,s6
 594:	e23ff0ef          	jal	3b6 <printint>
        i += 2;
 598:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 59a:	8ba6                	mv	s7,s1
      state = 0;
 59c:	4981                	li	s3,0
        i += 2;
 59e:	bde5                	j	496 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5a0:	008b8493          	addi	s1,s7,8
 5a4:	4685                	li	a3,1
 5a6:	4629                	li	a2,10
 5a8:	000ba583          	lw	a1,0(s7)
 5ac:	855a                	mv	a0,s6
 5ae:	e09ff0ef          	jal	3b6 <printint>
        i += 2;
 5b2:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5b4:	8ba6                	mv	s7,s1
      state = 0;
 5b6:	4981                	li	s3,0
        i += 2;
 5b8:	bdf9                	j	496 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 5ba:	008b8493          	addi	s1,s7,8
 5be:	4681                	li	a3,0
 5c0:	4629                	li	a2,10
 5c2:	000ba583          	lw	a1,0(s7)
 5c6:	855a                	mv	a0,s6
 5c8:	defff0ef          	jal	3b6 <printint>
 5cc:	8ba6                	mv	s7,s1
      state = 0;
 5ce:	4981                	li	s3,0
 5d0:	b5d9                	j	496 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5d2:	008b8493          	addi	s1,s7,8
 5d6:	4681                	li	a3,0
 5d8:	4629                	li	a2,10
 5da:	000ba583          	lw	a1,0(s7)
 5de:	855a                	mv	a0,s6
 5e0:	dd7ff0ef          	jal	3b6 <printint>
        i += 1;
 5e4:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5e6:	8ba6                	mv	s7,s1
      state = 0;
 5e8:	4981                	li	s3,0
        i += 1;
 5ea:	b575                	j	496 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ec:	008b8493          	addi	s1,s7,8
 5f0:	4681                	li	a3,0
 5f2:	4629                	li	a2,10
 5f4:	000ba583          	lw	a1,0(s7)
 5f8:	855a                	mv	a0,s6
 5fa:	dbdff0ef          	jal	3b6 <printint>
        i += 2;
 5fe:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 600:	8ba6                	mv	s7,s1
      state = 0;
 602:	4981                	li	s3,0
        i += 2;
 604:	bd49                	j	496 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 606:	008b8493          	addi	s1,s7,8
 60a:	4681                	li	a3,0
 60c:	4641                	li	a2,16
 60e:	000ba583          	lw	a1,0(s7)
 612:	855a                	mv	a0,s6
 614:	da3ff0ef          	jal	3b6 <printint>
 618:	8ba6                	mv	s7,s1
      state = 0;
 61a:	4981                	li	s3,0
 61c:	bdad                	j	496 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 61e:	008b8493          	addi	s1,s7,8
 622:	4681                	li	a3,0
 624:	4641                	li	a2,16
 626:	000ba583          	lw	a1,0(s7)
 62a:	855a                	mv	a0,s6
 62c:	d8bff0ef          	jal	3b6 <printint>
        i += 1;
 630:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 632:	8ba6                	mv	s7,s1
      state = 0;
 634:	4981                	li	s3,0
        i += 1;
 636:	b585                	j	496 <vprintf+0x4a>
 638:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 63a:	008b8d13          	addi	s10,s7,8
 63e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 642:	03000593          	li	a1,48
 646:	855a                	mv	a0,s6
 648:	d51ff0ef          	jal	398 <putc>
  putc(fd, 'x');
 64c:	07800593          	li	a1,120
 650:	855a                	mv	a0,s6
 652:	d47ff0ef          	jal	398 <putc>
 656:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 658:	00000b97          	auipc	s7,0x0
 65c:	2a8b8b93          	addi	s7,s7,680 # 900 <digits>
 660:	03c9d793          	srli	a5,s3,0x3c
 664:	97de                	add	a5,a5,s7
 666:	0007c583          	lbu	a1,0(a5)
 66a:	855a                	mv	a0,s6
 66c:	d2dff0ef          	jal	398 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 670:	0992                	slli	s3,s3,0x4
 672:	34fd                	addiw	s1,s1,-1
 674:	f4f5                	bnez	s1,660 <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 676:	8bea                	mv	s7,s10
      state = 0;
 678:	4981                	li	s3,0
 67a:	6d02                	ld	s10,0(sp)
 67c:	bd29                	j	496 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 67e:	008b8993          	addi	s3,s7,8
 682:	000bb483          	ld	s1,0(s7)
 686:	cc91                	beqz	s1,6a2 <vprintf+0x256>
        for(; *s; s++)
 688:	0004c583          	lbu	a1,0(s1)
 68c:	c195                	beqz	a1,6b0 <vprintf+0x264>
          putc(fd, *s);
 68e:	855a                	mv	a0,s6
 690:	d09ff0ef          	jal	398 <putc>
        for(; *s; s++)
 694:	0485                	addi	s1,s1,1
 696:	0004c583          	lbu	a1,0(s1)
 69a:	f9f5                	bnez	a1,68e <vprintf+0x242>
        if((s = va_arg(ap, char*)) == 0)
 69c:	8bce                	mv	s7,s3
      state = 0;
 69e:	4981                	li	s3,0
 6a0:	bbdd                	j	496 <vprintf+0x4a>
          s = "(null)";
 6a2:	00000497          	auipc	s1,0x0
 6a6:	25648493          	addi	s1,s1,598 # 8f8 <malloc+0x146>
        for(; *s; s++)
 6aa:	02800593          	li	a1,40
 6ae:	b7c5                	j	68e <vprintf+0x242>
        if((s = va_arg(ap, char*)) == 0)
 6b0:	8bce                	mv	s7,s3
      state = 0;
 6b2:	4981                	li	s3,0
 6b4:	b3cd                	j	496 <vprintf+0x4a>
 6b6:	6906                	ld	s2,64(sp)
 6b8:	79e2                	ld	s3,56(sp)
 6ba:	7a42                	ld	s4,48(sp)
 6bc:	7aa2                	ld	s5,40(sp)
 6be:	7b02                	ld	s6,32(sp)
 6c0:	6be2                	ld	s7,24(sp)
 6c2:	6c42                	ld	s8,16(sp)
 6c4:	6ca2                	ld	s9,8(sp)
    }
  }
}
 6c6:	60e6                	ld	ra,88(sp)
 6c8:	6446                	ld	s0,80(sp)
 6ca:	64a6                	ld	s1,72(sp)
 6cc:	6125                	addi	sp,sp,96
 6ce:	8082                	ret

00000000000006d0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6d0:	715d                	addi	sp,sp,-80
 6d2:	ec06                	sd	ra,24(sp)
 6d4:	e822                	sd	s0,16(sp)
 6d6:	1000                	addi	s0,sp,32
 6d8:	e010                	sd	a2,0(s0)
 6da:	e414                	sd	a3,8(s0)
 6dc:	e818                	sd	a4,16(s0)
 6de:	ec1c                	sd	a5,24(s0)
 6e0:	03043023          	sd	a6,32(s0)
 6e4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6e8:	8622                	mv	a2,s0
 6ea:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6ee:	d5fff0ef          	jal	44c <vprintf>
}
 6f2:	60e2                	ld	ra,24(sp)
 6f4:	6442                	ld	s0,16(sp)
 6f6:	6161                	addi	sp,sp,80
 6f8:	8082                	ret

00000000000006fa <printf>:

void
printf(const char *fmt, ...)
{
 6fa:	711d                	addi	sp,sp,-96
 6fc:	ec06                	sd	ra,24(sp)
 6fe:	e822                	sd	s0,16(sp)
 700:	1000                	addi	s0,sp,32
 702:	e40c                	sd	a1,8(s0)
 704:	e810                	sd	a2,16(s0)
 706:	ec14                	sd	a3,24(s0)
 708:	f018                	sd	a4,32(s0)
 70a:	f41c                	sd	a5,40(s0)
 70c:	03043823          	sd	a6,48(s0)
 710:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 714:	00840613          	addi	a2,s0,8
 718:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 71c:	85aa                	mv	a1,a0
 71e:	4505                	li	a0,1
 720:	d2dff0ef          	jal	44c <vprintf>
}
 724:	60e2                	ld	ra,24(sp)
 726:	6442                	ld	s0,16(sp)
 728:	6125                	addi	sp,sp,96
 72a:	8082                	ret

000000000000072c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 72c:	1141                	addi	sp,sp,-16
 72e:	e406                	sd	ra,8(sp)
 730:	e022                	sd	s0,0(sp)
 732:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 734:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 738:	00001797          	auipc	a5,0x1
 73c:	8c87b783          	ld	a5,-1848(a5) # 1000 <freep>
 740:	a02d                	j	76a <free+0x3e>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 742:	4618                	lw	a4,8(a2)
 744:	9f2d                	addw	a4,a4,a1
 746:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 74a:	6398                	ld	a4,0(a5)
 74c:	6310                	ld	a2,0(a4)
 74e:	a83d                	j	78c <free+0x60>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 750:	ff852703          	lw	a4,-8(a0)
 754:	9f31                	addw	a4,a4,a2
 756:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 758:	ff053683          	ld	a3,-16(a0)
 75c:	a091                	j	7a0 <free+0x74>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 75e:	6398                	ld	a4,0(a5)
 760:	00e7e463          	bltu	a5,a4,768 <free+0x3c>
 764:	00e6ea63          	bltu	a3,a4,778 <free+0x4c>
{
 768:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 76a:	fed7fae3          	bgeu	a5,a3,75e <free+0x32>
 76e:	6398                	ld	a4,0(a5)
 770:	00e6e463          	bltu	a3,a4,778 <free+0x4c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 774:	fee7eae3          	bltu	a5,a4,768 <free+0x3c>
  if(bp + bp->s.size == p->s.ptr){
 778:	ff852583          	lw	a1,-8(a0)
 77c:	6390                	ld	a2,0(a5)
 77e:	02059813          	slli	a6,a1,0x20
 782:	01c85713          	srli	a4,a6,0x1c
 786:	9736                	add	a4,a4,a3
 788:	fae60de3          	beq	a2,a4,742 <free+0x16>
    bp->s.ptr = p->s.ptr->s.ptr;
 78c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 790:	4790                	lw	a2,8(a5)
 792:	02061593          	slli	a1,a2,0x20
 796:	01c5d713          	srli	a4,a1,0x1c
 79a:	973e                	add	a4,a4,a5
 79c:	fae68ae3          	beq	a3,a4,750 <free+0x24>
    p->s.ptr = bp->s.ptr;
 7a0:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7a2:	00001717          	auipc	a4,0x1
 7a6:	84f73f23          	sd	a5,-1954(a4) # 1000 <freep>
}
 7aa:	60a2                	ld	ra,8(sp)
 7ac:	6402                	ld	s0,0(sp)
 7ae:	0141                	addi	sp,sp,16
 7b0:	8082                	ret

00000000000007b2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7b2:	7139                	addi	sp,sp,-64
 7b4:	fc06                	sd	ra,56(sp)
 7b6:	f822                	sd	s0,48(sp)
 7b8:	f04a                	sd	s2,32(sp)
 7ba:	ec4e                	sd	s3,24(sp)
 7bc:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7be:	02051993          	slli	s3,a0,0x20
 7c2:	0209d993          	srli	s3,s3,0x20
 7c6:	09bd                	addi	s3,s3,15
 7c8:	0049d993          	srli	s3,s3,0x4
 7cc:	2985                	addiw	s3,s3,1
 7ce:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 7d0:	00001517          	auipc	a0,0x1
 7d4:	83053503          	ld	a0,-2000(a0) # 1000 <freep>
 7d8:	c905                	beqz	a0,808 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7da:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7dc:	4798                	lw	a4,8(a5)
 7de:	09377663          	bgeu	a4,s3,86a <malloc+0xb8>
 7e2:	f426                	sd	s1,40(sp)
 7e4:	e852                	sd	s4,16(sp)
 7e6:	e456                	sd	s5,8(sp)
 7e8:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 7ea:	8a4e                	mv	s4,s3
 7ec:	6705                	lui	a4,0x1
 7ee:	00e9f363          	bgeu	s3,a4,7f4 <malloc+0x42>
 7f2:	6a05                	lui	s4,0x1
 7f4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7f8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7fc:	00001497          	auipc	s1,0x1
 800:	80448493          	addi	s1,s1,-2044 # 1000 <freep>
  if(p == (char*)-1)
 804:	5afd                	li	s5,-1
 806:	a83d                	j	844 <malloc+0x92>
 808:	f426                	sd	s1,40(sp)
 80a:	e852                	sd	s4,16(sp)
 80c:	e456                	sd	s5,8(sp)
 80e:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 810:	00001797          	auipc	a5,0x1
 814:	80078793          	addi	a5,a5,-2048 # 1010 <base>
 818:	00000717          	auipc	a4,0x0
 81c:	7ef73423          	sd	a5,2024(a4) # 1000 <freep>
 820:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 822:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 826:	b7d1                	j	7ea <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 828:	6398                	ld	a4,0(a5)
 82a:	e118                	sd	a4,0(a0)
 82c:	a899                	j	882 <malloc+0xd0>
  hp->s.size = nu;
 82e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 832:	0541                	addi	a0,a0,16
 834:	ef9ff0ef          	jal	72c <free>
  return freep;
 838:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 83a:	c125                	beqz	a0,89a <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 83c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 83e:	4798                	lw	a4,8(a5)
 840:	03277163          	bgeu	a4,s2,862 <malloc+0xb0>
    if(p == freep)
 844:	6098                	ld	a4,0(s1)
 846:	853e                	mv	a0,a5
 848:	fef71ae3          	bne	a4,a5,83c <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 84c:	8552                	mv	a0,s4
 84e:	b03ff0ef          	jal	350 <sbrk>
  if(p == (char*)-1)
 852:	fd551ee3          	bne	a0,s5,82e <malloc+0x7c>
        return 0;
 856:	4501                	li	a0,0
 858:	74a2                	ld	s1,40(sp)
 85a:	6a42                	ld	s4,16(sp)
 85c:	6aa2                	ld	s5,8(sp)
 85e:	6b02                	ld	s6,0(sp)
 860:	a03d                	j	88e <malloc+0xdc>
 862:	74a2                	ld	s1,40(sp)
 864:	6a42                	ld	s4,16(sp)
 866:	6aa2                	ld	s5,8(sp)
 868:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 86a:	fae90fe3          	beq	s2,a4,828 <malloc+0x76>
        p->s.size -= nunits;
 86e:	4137073b          	subw	a4,a4,s3
 872:	c798                	sw	a4,8(a5)
        p += p->s.size;
 874:	02071693          	slli	a3,a4,0x20
 878:	01c6d713          	srli	a4,a3,0x1c
 87c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 87e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 882:	00000717          	auipc	a4,0x0
 886:	76a73f23          	sd	a0,1918(a4) # 1000 <freep>
      return (void*)(p + 1);
 88a:	01078513          	addi	a0,a5,16
  }
}
 88e:	70e2                	ld	ra,56(sp)
 890:	7442                	ld	s0,48(sp)
 892:	7902                	ld	s2,32(sp)
 894:	69e2                	ld	s3,24(sp)
 896:	6121                	addi	sp,sp,64
 898:	8082                	ret
 89a:	74a2                	ld	s1,40(sp)
 89c:	6a42                	ld	s4,16(sp)
 89e:	6aa2                	ld	s5,8(sp)
 8a0:	6b02                	ld	s6,0(sp)
 8a2:	b7f5                	j	88e <malloc+0xdc>
