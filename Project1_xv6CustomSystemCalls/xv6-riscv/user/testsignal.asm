
user/_testsignal:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"
#include "kernel/syscall.h"

int main() {
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	1800                	addi	s0,sp,48
    int pid = fork();
   8:	342000ef          	jal	34a <fork>

    if (pid == 0) {
   c:	ed1d                	bnez	a0,4a <main+0x4a>
   e:	ec26                	sd	s1,24(sp)
  10:	e84a                	sd	s2,16(sp)
  12:	e44e                	sd	s3,8(sp)
  14:	e052                	sd	s4,0(sp)
        // Child process
        for (int i = 1; i <= 5; i++) {
  16:	4485                	li	s1,1
            printf("Child running iteration %d...\n", i);
  18:	00001a17          	auipc	s4,0x1
  1c:	918a0a13          	addi	s4,s4,-1768 # 930 <malloc+0xf4>
            sleep(3);  // Simulate some work
  20:	498d                	li	s3,3
        for (int i = 1; i <= 5; i++) {
  22:	4919                	li	s2,6
            printf("Child running iteration %d...\n", i);
  24:	85a6                	mv	a1,s1
  26:	8552                	mv	a0,s4
  28:	75c000ef          	jal	784 <printf>
            sleep(3);  // Simulate some work
  2c:	854e                	mv	a0,s3
  2e:	3b4000ef          	jal	3e2 <sleep>
        for (int i = 1; i <= 5; i++) {
  32:	2485                	addiw	s1,s1,1
  34:	ff2498e3          	bne	s1,s2,24 <main+0x24>
        }
        printf("Child completed its task\n");
  38:	00001517          	auipc	a0,0x1
  3c:	92050513          	addi	a0,a0,-1760 # 958 <malloc+0x11c>
  40:	744000ef          	jal	784 <printf>
        exit(0);  // Exit gracefully
  44:	4501                	li	a0,0
  46:	30c000ef          	jal	352 <exit>
  4a:	ec26                	sd	s1,24(sp)
  4c:	e84a                	sd	s2,16(sp)
  4e:	e44e                	sd	s3,8(sp)
  50:	e052                	sd	s4,0(sp)
  52:	84aa                	mv	s1,a0
    } else if (pid > 0) {
  54:	04a05963          	blez	a0,a6 <main+0xa6>
        // Parent process
        sleep(8);  // Let the child run for a while
  58:	4521                	li	a0,8
  5a:	388000ef          	jal	3e2 <sleep>
        printf("Parent sending SIGSTOP to child %d\n", pid);
  5e:	85a6                	mv	a1,s1
  60:	00001517          	auipc	a0,0x1
  64:	91850513          	addi	a0,a0,-1768 # 978 <malloc+0x13c>
  68:	71c000ef          	jal	784 <printf>
        sigstop(pid);  // Stop the child process
  6c:	8526                	mv	a0,s1
  6e:	3a4000ef          	jal	412 <sigstop>

        sleep(5);  // Wait for a while before continuing the child
  72:	4515                	li	a0,5
  74:	36e000ef          	jal	3e2 <sleep>
        printf("Parent sending SIGCONT to child %d\n", pid);
  78:	85a6                	mv	a1,s1
  7a:	00001517          	auipc	a0,0x1
  7e:	92650513          	addi	a0,a0,-1754 # 9a0 <malloc+0x164>
  82:	702000ef          	jal	784 <printf>
        sigcont(pid);  // Continue the child process
  86:	8526                	mv	a0,s1
  88:	392000ef          	jal	41a <sigcont>

        wait(0);  // Wait for child process to exit
  8c:	4501                	li	a0,0
  8e:	2cc000ef          	jal	35a <wait>
        printf("Parent: Child process %d finished\n", pid);
  92:	85a6                	mv	a1,s1
  94:	00001517          	auipc	a0,0x1
  98:	93450513          	addi	a0,a0,-1740 # 9c8 <malloc+0x18c>
  9c:	6e8000ef          	jal	784 <printf>
    } else {
        // Error in fork
        printf("Fork failed\n");
    }

    exit(0);
  a0:	4501                	li	a0,0
  a2:	2b0000ef          	jal	352 <exit>
        printf("Fork failed\n");
  a6:	00001517          	auipc	a0,0x1
  aa:	94a50513          	addi	a0,a0,-1718 # 9f0 <malloc+0x1b4>
  ae:	6d6000ef          	jal	784 <printf>
  b2:	b7fd                	j	a0 <main+0xa0>

00000000000000b4 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
  b4:	1141                	addi	sp,sp,-16
  b6:	e406                	sd	ra,8(sp)
  b8:	e022                	sd	s0,0(sp)
  ba:	0800                	addi	s0,sp,16
  extern int main();
  main();
  bc:	f45ff0ef          	jal	0 <main>
  exit(0);
  c0:	4501                	li	a0,0
  c2:	290000ef          	jal	352 <exit>

00000000000000c6 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  c6:	1141                	addi	sp,sp,-16
  c8:	e406                	sd	ra,8(sp)
  ca:	e022                	sd	s0,0(sp)
  cc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  ce:	87aa                	mv	a5,a0
  d0:	0585                	addi	a1,a1,1
  d2:	0785                	addi	a5,a5,1
  d4:	fff5c703          	lbu	a4,-1(a1)
  d8:	fee78fa3          	sb	a4,-1(a5)
  dc:	fb75                	bnez	a4,d0 <strcpy+0xa>
    ;
  return os;
}
  de:	60a2                	ld	ra,8(sp)
  e0:	6402                	ld	s0,0(sp)
  e2:	0141                	addi	sp,sp,16
  e4:	8082                	ret

00000000000000e6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  e6:	1141                	addi	sp,sp,-16
  e8:	e406                	sd	ra,8(sp)
  ea:	e022                	sd	s0,0(sp)
  ec:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  ee:	00054783          	lbu	a5,0(a0)
  f2:	cb91                	beqz	a5,106 <strcmp+0x20>
  f4:	0005c703          	lbu	a4,0(a1)
  f8:	00f71763          	bne	a4,a5,106 <strcmp+0x20>
    p++, q++;
  fc:	0505                	addi	a0,a0,1
  fe:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 100:	00054783          	lbu	a5,0(a0)
 104:	fbe5                	bnez	a5,f4 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 106:	0005c503          	lbu	a0,0(a1)
}
 10a:	40a7853b          	subw	a0,a5,a0
 10e:	60a2                	ld	ra,8(sp)
 110:	6402                	ld	s0,0(sp)
 112:	0141                	addi	sp,sp,16
 114:	8082                	ret

0000000000000116 <strlen>:

uint
strlen(const char *s)
{
 116:	1141                	addi	sp,sp,-16
 118:	e406                	sd	ra,8(sp)
 11a:	e022                	sd	s0,0(sp)
 11c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 11e:	00054783          	lbu	a5,0(a0)
 122:	cf99                	beqz	a5,140 <strlen+0x2a>
 124:	0505                	addi	a0,a0,1
 126:	87aa                	mv	a5,a0
 128:	86be                	mv	a3,a5
 12a:	0785                	addi	a5,a5,1
 12c:	fff7c703          	lbu	a4,-1(a5)
 130:	ff65                	bnez	a4,128 <strlen+0x12>
 132:	40a6853b          	subw	a0,a3,a0
 136:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 138:	60a2                	ld	ra,8(sp)
 13a:	6402                	ld	s0,0(sp)
 13c:	0141                	addi	sp,sp,16
 13e:	8082                	ret
  for(n = 0; s[n]; n++)
 140:	4501                	li	a0,0
 142:	bfdd                	j	138 <strlen+0x22>

0000000000000144 <memset>:

void*
memset(void *dst, int c, uint n)
{
 144:	1141                	addi	sp,sp,-16
 146:	e406                	sd	ra,8(sp)
 148:	e022                	sd	s0,0(sp)
 14a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 14c:	ca19                	beqz	a2,162 <memset+0x1e>
 14e:	87aa                	mv	a5,a0
 150:	1602                	slli	a2,a2,0x20
 152:	9201                	srli	a2,a2,0x20
 154:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 158:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 15c:	0785                	addi	a5,a5,1
 15e:	fee79de3          	bne	a5,a4,158 <memset+0x14>
  }
  return dst;
}
 162:	60a2                	ld	ra,8(sp)
 164:	6402                	ld	s0,0(sp)
 166:	0141                	addi	sp,sp,16
 168:	8082                	ret

000000000000016a <strchr>:

char*
strchr(const char *s, char c)
{
 16a:	1141                	addi	sp,sp,-16
 16c:	e406                	sd	ra,8(sp)
 16e:	e022                	sd	s0,0(sp)
 170:	0800                	addi	s0,sp,16
  for(; *s; s++)
 172:	00054783          	lbu	a5,0(a0)
 176:	cf81                	beqz	a5,18e <strchr+0x24>
    if(*s == c)
 178:	00f58763          	beq	a1,a5,186 <strchr+0x1c>
  for(; *s; s++)
 17c:	0505                	addi	a0,a0,1
 17e:	00054783          	lbu	a5,0(a0)
 182:	fbfd                	bnez	a5,178 <strchr+0xe>
      return (char*)s;
  return 0;
 184:	4501                	li	a0,0
}
 186:	60a2                	ld	ra,8(sp)
 188:	6402                	ld	s0,0(sp)
 18a:	0141                	addi	sp,sp,16
 18c:	8082                	ret
  return 0;
 18e:	4501                	li	a0,0
 190:	bfdd                	j	186 <strchr+0x1c>

0000000000000192 <gets>:

char*
gets(char *buf, int max)
{
 192:	7159                	addi	sp,sp,-112
 194:	f486                	sd	ra,104(sp)
 196:	f0a2                	sd	s0,96(sp)
 198:	eca6                	sd	s1,88(sp)
 19a:	e8ca                	sd	s2,80(sp)
 19c:	e4ce                	sd	s3,72(sp)
 19e:	e0d2                	sd	s4,64(sp)
 1a0:	fc56                	sd	s5,56(sp)
 1a2:	f85a                	sd	s6,48(sp)
 1a4:	f45e                	sd	s7,40(sp)
 1a6:	f062                	sd	s8,32(sp)
 1a8:	ec66                	sd	s9,24(sp)
 1aa:	e86a                	sd	s10,16(sp)
 1ac:	1880                	addi	s0,sp,112
 1ae:	8caa                	mv	s9,a0
 1b0:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1b2:	892a                	mv	s2,a0
 1b4:	4481                	li	s1,0
    cc = read(0, &c, 1);
 1b6:	f9f40b13          	addi	s6,s0,-97
 1ba:	4a85                	li	s5,1
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1bc:	4ba9                	li	s7,10
 1be:	4c35                	li	s8,13
  for(i=0; i+1 < max; ){
 1c0:	8d26                	mv	s10,s1
 1c2:	0014899b          	addiw	s3,s1,1
 1c6:	84ce                	mv	s1,s3
 1c8:	0349d563          	bge	s3,s4,1f2 <gets+0x60>
    cc = read(0, &c, 1);
 1cc:	8656                	mv	a2,s5
 1ce:	85da                	mv	a1,s6
 1d0:	4501                	li	a0,0
 1d2:	198000ef          	jal	36a <read>
    if(cc < 1)
 1d6:	00a05e63          	blez	a0,1f2 <gets+0x60>
    buf[i++] = c;
 1da:	f9f44783          	lbu	a5,-97(s0)
 1de:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1e2:	01778763          	beq	a5,s7,1f0 <gets+0x5e>
 1e6:	0905                	addi	s2,s2,1
 1e8:	fd879ce3          	bne	a5,s8,1c0 <gets+0x2e>
    buf[i++] = c;
 1ec:	8d4e                	mv	s10,s3
 1ee:	a011                	j	1f2 <gets+0x60>
 1f0:	8d4e                	mv	s10,s3
      break;
  }
  buf[i] = '\0';
 1f2:	9d66                	add	s10,s10,s9
 1f4:	000d0023          	sb	zero,0(s10)
  return buf;
}
 1f8:	8566                	mv	a0,s9
 1fa:	70a6                	ld	ra,104(sp)
 1fc:	7406                	ld	s0,96(sp)
 1fe:	64e6                	ld	s1,88(sp)
 200:	6946                	ld	s2,80(sp)
 202:	69a6                	ld	s3,72(sp)
 204:	6a06                	ld	s4,64(sp)
 206:	7ae2                	ld	s5,56(sp)
 208:	7b42                	ld	s6,48(sp)
 20a:	7ba2                	ld	s7,40(sp)
 20c:	7c02                	ld	s8,32(sp)
 20e:	6ce2                	ld	s9,24(sp)
 210:	6d42                	ld	s10,16(sp)
 212:	6165                	addi	sp,sp,112
 214:	8082                	ret

0000000000000216 <stat>:

int
stat(const char *n, struct stat *st)
{
 216:	1101                	addi	sp,sp,-32
 218:	ec06                	sd	ra,24(sp)
 21a:	e822                	sd	s0,16(sp)
 21c:	e04a                	sd	s2,0(sp)
 21e:	1000                	addi	s0,sp,32
 220:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 222:	4581                	li	a1,0
 224:	16e000ef          	jal	392 <open>
  if(fd < 0)
 228:	02054263          	bltz	a0,24c <stat+0x36>
 22c:	e426                	sd	s1,8(sp)
 22e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 230:	85ca                	mv	a1,s2
 232:	178000ef          	jal	3aa <fstat>
 236:	892a                	mv	s2,a0
  close(fd);
 238:	8526                	mv	a0,s1
 23a:	140000ef          	jal	37a <close>
  return r;
 23e:	64a2                	ld	s1,8(sp)
}
 240:	854a                	mv	a0,s2
 242:	60e2                	ld	ra,24(sp)
 244:	6442                	ld	s0,16(sp)
 246:	6902                	ld	s2,0(sp)
 248:	6105                	addi	sp,sp,32
 24a:	8082                	ret
    return -1;
 24c:	597d                	li	s2,-1
 24e:	bfcd                	j	240 <stat+0x2a>

0000000000000250 <atoi>:

int
atoi(const char *s)
{
 250:	1141                	addi	sp,sp,-16
 252:	e406                	sd	ra,8(sp)
 254:	e022                	sd	s0,0(sp)
 256:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 258:	00054683          	lbu	a3,0(a0)
 25c:	fd06879b          	addiw	a5,a3,-48
 260:	0ff7f793          	zext.b	a5,a5
 264:	4625                	li	a2,9
 266:	02f66963          	bltu	a2,a5,298 <atoi+0x48>
 26a:	872a                	mv	a4,a0
  n = 0;
 26c:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 26e:	0705                	addi	a4,a4,1
 270:	0025179b          	slliw	a5,a0,0x2
 274:	9fa9                	addw	a5,a5,a0
 276:	0017979b          	slliw	a5,a5,0x1
 27a:	9fb5                	addw	a5,a5,a3
 27c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 280:	00074683          	lbu	a3,0(a4)
 284:	fd06879b          	addiw	a5,a3,-48
 288:	0ff7f793          	zext.b	a5,a5
 28c:	fef671e3          	bgeu	a2,a5,26e <atoi+0x1e>
  return n;
}
 290:	60a2                	ld	ra,8(sp)
 292:	6402                	ld	s0,0(sp)
 294:	0141                	addi	sp,sp,16
 296:	8082                	ret
  n = 0;
 298:	4501                	li	a0,0
 29a:	bfdd                	j	290 <atoi+0x40>

000000000000029c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 29c:	1141                	addi	sp,sp,-16
 29e:	e406                	sd	ra,8(sp)
 2a0:	e022                	sd	s0,0(sp)
 2a2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2a4:	02b57563          	bgeu	a0,a1,2ce <memmove+0x32>
    while(n-- > 0)
 2a8:	00c05f63          	blez	a2,2c6 <memmove+0x2a>
 2ac:	1602                	slli	a2,a2,0x20
 2ae:	9201                	srli	a2,a2,0x20
 2b0:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2b4:	872a                	mv	a4,a0
      *dst++ = *src++;
 2b6:	0585                	addi	a1,a1,1
 2b8:	0705                	addi	a4,a4,1
 2ba:	fff5c683          	lbu	a3,-1(a1)
 2be:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2c2:	fee79ae3          	bne	a5,a4,2b6 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2c6:	60a2                	ld	ra,8(sp)
 2c8:	6402                	ld	s0,0(sp)
 2ca:	0141                	addi	sp,sp,16
 2cc:	8082                	ret
    dst += n;
 2ce:	00c50733          	add	a4,a0,a2
    src += n;
 2d2:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2d4:	fec059e3          	blez	a2,2c6 <memmove+0x2a>
 2d8:	fff6079b          	addiw	a5,a2,-1
 2dc:	1782                	slli	a5,a5,0x20
 2de:	9381                	srli	a5,a5,0x20
 2e0:	fff7c793          	not	a5,a5
 2e4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2e6:	15fd                	addi	a1,a1,-1
 2e8:	177d                	addi	a4,a4,-1
 2ea:	0005c683          	lbu	a3,0(a1)
 2ee:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2f2:	fef71ae3          	bne	a4,a5,2e6 <memmove+0x4a>
 2f6:	bfc1                	j	2c6 <memmove+0x2a>

00000000000002f8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2f8:	1141                	addi	sp,sp,-16
 2fa:	e406                	sd	ra,8(sp)
 2fc:	e022                	sd	s0,0(sp)
 2fe:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 300:	ca0d                	beqz	a2,332 <memcmp+0x3a>
 302:	fff6069b          	addiw	a3,a2,-1
 306:	1682                	slli	a3,a3,0x20
 308:	9281                	srli	a3,a3,0x20
 30a:	0685                	addi	a3,a3,1
 30c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 30e:	00054783          	lbu	a5,0(a0)
 312:	0005c703          	lbu	a4,0(a1)
 316:	00e79863          	bne	a5,a4,326 <memcmp+0x2e>
      return *p1 - *p2;
    }
    p1++;
 31a:	0505                	addi	a0,a0,1
    p2++;
 31c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 31e:	fed518e3          	bne	a0,a3,30e <memcmp+0x16>
  }
  return 0;
 322:	4501                	li	a0,0
 324:	a019                	j	32a <memcmp+0x32>
      return *p1 - *p2;
 326:	40e7853b          	subw	a0,a5,a4
}
 32a:	60a2                	ld	ra,8(sp)
 32c:	6402                	ld	s0,0(sp)
 32e:	0141                	addi	sp,sp,16
 330:	8082                	ret
  return 0;
 332:	4501                	li	a0,0
 334:	bfdd                	j	32a <memcmp+0x32>

0000000000000336 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 336:	1141                	addi	sp,sp,-16
 338:	e406                	sd	ra,8(sp)
 33a:	e022                	sd	s0,0(sp)
 33c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 33e:	f5fff0ef          	jal	29c <memmove>
}
 342:	60a2                	ld	ra,8(sp)
 344:	6402                	ld	s0,0(sp)
 346:	0141                	addi	sp,sp,16
 348:	8082                	ret

000000000000034a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 34a:	4885                	li	a7,1
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <exit>:
.global exit
exit:
 li a7, SYS_exit
 352:	4889                	li	a7,2
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <wait>:
.global wait
wait:
 li a7, SYS_wait
 35a:	488d                	li	a7,3
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 362:	4891                	li	a7,4
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <read>:
.global read
read:
 li a7, SYS_read
 36a:	4895                	li	a7,5
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <write>:
.global write
write:
 li a7, SYS_write
 372:	48c1                	li	a7,16
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <close>:
.global close
close:
 li a7, SYS_close
 37a:	48d5                	li	a7,21
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <kill>:
.global kill
kill:
 li a7, SYS_kill
 382:	4899                	li	a7,6
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <exec>:
.global exec
exec:
 li a7, SYS_exec
 38a:	489d                	li	a7,7
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <open>:
.global open
open:
 li a7, SYS_open
 392:	48bd                	li	a7,15
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 39a:	48c5                	li	a7,17
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3a2:	48c9                	li	a7,18
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3aa:	48a1                	li	a7,8
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <link>:
.global link
link:
 li a7, SYS_link
 3b2:	48cd                	li	a7,19
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3ba:	48d1                	li	a7,20
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3c2:	48a5                	li	a7,9
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <dup>:
.global dup
dup:
 li a7, SYS_dup
 3ca:	48a9                	li	a7,10
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3d2:	48ad                	li	a7,11
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3da:	48b1                	li	a7,12
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3e2:	48b5                	li	a7,13
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3ea:	48b9                	li	a7,14
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <forex>:
.global forex
forex:
 li a7, SYS_forex
 3f2:	48d9                	li	a7,22
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 3fa:	48dd                	li	a7,23
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <usleep>:
.global usleep
usleep:
 li a7, SYS_usleep
 402:	48e1                	li	a7,24
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 40a:	48e5                	li	a7,25
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <sigstop>:
.global sigstop
sigstop:
 li a7, SYS_sigstop
 412:	48e9                	li	a7,26
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <sigcont>:
.global sigcont
sigcont:
 li a7, SYS_sigcont
 41a:	48ed                	li	a7,27
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 422:	1101                	addi	sp,sp,-32
 424:	ec06                	sd	ra,24(sp)
 426:	e822                	sd	s0,16(sp)
 428:	1000                	addi	s0,sp,32
 42a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 42e:	4605                	li	a2,1
 430:	fef40593          	addi	a1,s0,-17
 434:	f3fff0ef          	jal	372 <write>
}
 438:	60e2                	ld	ra,24(sp)
 43a:	6442                	ld	s0,16(sp)
 43c:	6105                	addi	sp,sp,32
 43e:	8082                	ret

0000000000000440 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 440:	7139                	addi	sp,sp,-64
 442:	fc06                	sd	ra,56(sp)
 444:	f822                	sd	s0,48(sp)
 446:	f426                	sd	s1,40(sp)
 448:	f04a                	sd	s2,32(sp)
 44a:	ec4e                	sd	s3,24(sp)
 44c:	0080                	addi	s0,sp,64
 44e:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 450:	c299                	beqz	a3,456 <printint+0x16>
 452:	0605ce63          	bltz	a1,4ce <printint+0x8e>
  neg = 0;
 456:	4e01                	li	t3,0
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 458:	fc040313          	addi	t1,s0,-64
  neg = 0;
 45c:	869a                	mv	a3,t1
  i = 0;
 45e:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 460:	00000817          	auipc	a6,0x0
 464:	5a880813          	addi	a6,a6,1448 # a08 <digits>
 468:	88be                	mv	a7,a5
 46a:	0017851b          	addiw	a0,a5,1
 46e:	87aa                	mv	a5,a0
 470:	02c5f73b          	remuw	a4,a1,a2
 474:	1702                	slli	a4,a4,0x20
 476:	9301                	srli	a4,a4,0x20
 478:	9742                	add	a4,a4,a6
 47a:	00074703          	lbu	a4,0(a4)
 47e:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 482:	872e                	mv	a4,a1
 484:	02c5d5bb          	divuw	a1,a1,a2
 488:	0685                	addi	a3,a3,1
 48a:	fcc77fe3          	bgeu	a4,a2,468 <printint+0x28>
  if(neg)
 48e:	000e0c63          	beqz	t3,4a6 <printint+0x66>
    buf[i++] = '-';
 492:	fd050793          	addi	a5,a0,-48
 496:	00878533          	add	a0,a5,s0
 49a:	02d00793          	li	a5,45
 49e:	fef50823          	sb	a5,-16(a0)
 4a2:	0028879b          	addiw	a5,a7,2

  while(--i >= 0)
 4a6:	fff7899b          	addiw	s3,a5,-1
 4aa:	006784b3          	add	s1,a5,t1
    putc(fd, buf[i]);
 4ae:	fff4c583          	lbu	a1,-1(s1)
 4b2:	854a                	mv	a0,s2
 4b4:	f6fff0ef          	jal	422 <putc>
  while(--i >= 0)
 4b8:	39fd                	addiw	s3,s3,-1
 4ba:	14fd                	addi	s1,s1,-1
 4bc:	fe09d9e3          	bgez	s3,4ae <printint+0x6e>
}
 4c0:	70e2                	ld	ra,56(sp)
 4c2:	7442                	ld	s0,48(sp)
 4c4:	74a2                	ld	s1,40(sp)
 4c6:	7902                	ld	s2,32(sp)
 4c8:	69e2                	ld	s3,24(sp)
 4ca:	6121                	addi	sp,sp,64
 4cc:	8082                	ret
    x = -xx;
 4ce:	40b005bb          	negw	a1,a1
    neg = 1;
 4d2:	4e05                	li	t3,1
    x = -xx;
 4d4:	b751                	j	458 <printint+0x18>

00000000000004d6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4d6:	711d                	addi	sp,sp,-96
 4d8:	ec86                	sd	ra,88(sp)
 4da:	e8a2                	sd	s0,80(sp)
 4dc:	e4a6                	sd	s1,72(sp)
 4de:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4e0:	0005c483          	lbu	s1,0(a1)
 4e4:	26048663          	beqz	s1,750 <vprintf+0x27a>
 4e8:	e0ca                	sd	s2,64(sp)
 4ea:	fc4e                	sd	s3,56(sp)
 4ec:	f852                	sd	s4,48(sp)
 4ee:	f456                	sd	s5,40(sp)
 4f0:	f05a                	sd	s6,32(sp)
 4f2:	ec5e                	sd	s7,24(sp)
 4f4:	e862                	sd	s8,16(sp)
 4f6:	e466                	sd	s9,8(sp)
 4f8:	8b2a                	mv	s6,a0
 4fa:	8a2e                	mv	s4,a1
 4fc:	8bb2                	mv	s7,a2
  state = 0;
 4fe:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 500:	4901                	li	s2,0
 502:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 504:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 508:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 50c:	06c00c93          	li	s9,108
 510:	a00d                	j	532 <vprintf+0x5c>
        putc(fd, c0);
 512:	85a6                	mv	a1,s1
 514:	855a                	mv	a0,s6
 516:	f0dff0ef          	jal	422 <putc>
 51a:	a019                	j	520 <vprintf+0x4a>
    } else if(state == '%'){
 51c:	03598363          	beq	s3,s5,542 <vprintf+0x6c>
  for(i = 0; fmt[i]; i++){
 520:	0019079b          	addiw	a5,s2,1
 524:	893e                	mv	s2,a5
 526:	873e                	mv	a4,a5
 528:	97d2                	add	a5,a5,s4
 52a:	0007c483          	lbu	s1,0(a5)
 52e:	20048963          	beqz	s1,740 <vprintf+0x26a>
    c0 = fmt[i] & 0xff;
 532:	0004879b          	sext.w	a5,s1
    if(state == 0){
 536:	fe0993e3          	bnez	s3,51c <vprintf+0x46>
      if(c0 == '%'){
 53a:	fd579ce3          	bne	a5,s5,512 <vprintf+0x3c>
        state = '%';
 53e:	89be                	mv	s3,a5
 540:	b7c5                	j	520 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 542:	00ea06b3          	add	a3,s4,a4
 546:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 54a:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 54c:	c681                	beqz	a3,554 <vprintf+0x7e>
 54e:	9752                	add	a4,a4,s4
 550:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 554:	03878e63          	beq	a5,s8,590 <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 558:	05978863          	beq	a5,s9,5a8 <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 55c:	07500713          	li	a4,117
 560:	0ee78263          	beq	a5,a4,644 <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 564:	07800713          	li	a4,120
 568:	12e78463          	beq	a5,a4,690 <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 56c:	07000713          	li	a4,112
 570:	14e78963          	beq	a5,a4,6c2 <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 574:	07300713          	li	a4,115
 578:	18e78863          	beq	a5,a4,708 <vprintf+0x232>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 57c:	02500713          	li	a4,37
 580:	04e79463          	bne	a5,a4,5c8 <vprintf+0xf2>
        putc(fd, '%');
 584:	85ba                	mv	a1,a4
 586:	855a                	mv	a0,s6
 588:	e9bff0ef          	jal	422 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 58c:	4981                	li	s3,0
 58e:	bf49                	j	520 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 590:	008b8493          	addi	s1,s7,8
 594:	4685                	li	a3,1
 596:	4629                	li	a2,10
 598:	000ba583          	lw	a1,0(s7)
 59c:	855a                	mv	a0,s6
 59e:	ea3ff0ef          	jal	440 <printint>
 5a2:	8ba6                	mv	s7,s1
      state = 0;
 5a4:	4981                	li	s3,0
 5a6:	bfad                	j	520 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 5a8:	06400793          	li	a5,100
 5ac:	02f68963          	beq	a3,a5,5de <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5b0:	06c00793          	li	a5,108
 5b4:	04f68263          	beq	a3,a5,5f8 <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 5b8:	07500793          	li	a5,117
 5bc:	0af68063          	beq	a3,a5,65c <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 5c0:	07800793          	li	a5,120
 5c4:	0ef68263          	beq	a3,a5,6a8 <vprintf+0x1d2>
        putc(fd, '%');
 5c8:	02500593          	li	a1,37
 5cc:	855a                	mv	a0,s6
 5ce:	e55ff0ef          	jal	422 <putc>
        putc(fd, c0);
 5d2:	85a6                	mv	a1,s1
 5d4:	855a                	mv	a0,s6
 5d6:	e4dff0ef          	jal	422 <putc>
      state = 0;
 5da:	4981                	li	s3,0
 5dc:	b791                	j	520 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5de:	008b8493          	addi	s1,s7,8
 5e2:	4685                	li	a3,1
 5e4:	4629                	li	a2,10
 5e6:	000ba583          	lw	a1,0(s7)
 5ea:	855a                	mv	a0,s6
 5ec:	e55ff0ef          	jal	440 <printint>
        i += 1;
 5f0:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5f2:	8ba6                	mv	s7,s1
      state = 0;
 5f4:	4981                	li	s3,0
        i += 1;
 5f6:	b72d                	j	520 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5f8:	06400793          	li	a5,100
 5fc:	02f60763          	beq	a2,a5,62a <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 600:	07500793          	li	a5,117
 604:	06f60963          	beq	a2,a5,676 <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 608:	07800793          	li	a5,120
 60c:	faf61ee3          	bne	a2,a5,5c8 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 610:	008b8493          	addi	s1,s7,8
 614:	4681                	li	a3,0
 616:	4641                	li	a2,16
 618:	000ba583          	lw	a1,0(s7)
 61c:	855a                	mv	a0,s6
 61e:	e23ff0ef          	jal	440 <printint>
        i += 2;
 622:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 624:	8ba6                	mv	s7,s1
      state = 0;
 626:	4981                	li	s3,0
        i += 2;
 628:	bde5                	j	520 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 62a:	008b8493          	addi	s1,s7,8
 62e:	4685                	li	a3,1
 630:	4629                	li	a2,10
 632:	000ba583          	lw	a1,0(s7)
 636:	855a                	mv	a0,s6
 638:	e09ff0ef          	jal	440 <printint>
        i += 2;
 63c:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 63e:	8ba6                	mv	s7,s1
      state = 0;
 640:	4981                	li	s3,0
        i += 2;
 642:	bdf9                	j	520 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 644:	008b8493          	addi	s1,s7,8
 648:	4681                	li	a3,0
 64a:	4629                	li	a2,10
 64c:	000ba583          	lw	a1,0(s7)
 650:	855a                	mv	a0,s6
 652:	defff0ef          	jal	440 <printint>
 656:	8ba6                	mv	s7,s1
      state = 0;
 658:	4981                	li	s3,0
 65a:	b5d9                	j	520 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 65c:	008b8493          	addi	s1,s7,8
 660:	4681                	li	a3,0
 662:	4629                	li	a2,10
 664:	000ba583          	lw	a1,0(s7)
 668:	855a                	mv	a0,s6
 66a:	dd7ff0ef          	jal	440 <printint>
        i += 1;
 66e:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 670:	8ba6                	mv	s7,s1
      state = 0;
 672:	4981                	li	s3,0
        i += 1;
 674:	b575                	j	520 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 676:	008b8493          	addi	s1,s7,8
 67a:	4681                	li	a3,0
 67c:	4629                	li	a2,10
 67e:	000ba583          	lw	a1,0(s7)
 682:	855a                	mv	a0,s6
 684:	dbdff0ef          	jal	440 <printint>
        i += 2;
 688:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 68a:	8ba6                	mv	s7,s1
      state = 0;
 68c:	4981                	li	s3,0
        i += 2;
 68e:	bd49                	j	520 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 690:	008b8493          	addi	s1,s7,8
 694:	4681                	li	a3,0
 696:	4641                	li	a2,16
 698:	000ba583          	lw	a1,0(s7)
 69c:	855a                	mv	a0,s6
 69e:	da3ff0ef          	jal	440 <printint>
 6a2:	8ba6                	mv	s7,s1
      state = 0;
 6a4:	4981                	li	s3,0
 6a6:	bdad                	j	520 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6a8:	008b8493          	addi	s1,s7,8
 6ac:	4681                	li	a3,0
 6ae:	4641                	li	a2,16
 6b0:	000ba583          	lw	a1,0(s7)
 6b4:	855a                	mv	a0,s6
 6b6:	d8bff0ef          	jal	440 <printint>
        i += 1;
 6ba:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6bc:	8ba6                	mv	s7,s1
      state = 0;
 6be:	4981                	li	s3,0
        i += 1;
 6c0:	b585                	j	520 <vprintf+0x4a>
 6c2:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 6c4:	008b8d13          	addi	s10,s7,8
 6c8:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6cc:	03000593          	li	a1,48
 6d0:	855a                	mv	a0,s6
 6d2:	d51ff0ef          	jal	422 <putc>
  putc(fd, 'x');
 6d6:	07800593          	li	a1,120
 6da:	855a                	mv	a0,s6
 6dc:	d47ff0ef          	jal	422 <putc>
 6e0:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6e2:	00000b97          	auipc	s7,0x0
 6e6:	326b8b93          	addi	s7,s7,806 # a08 <digits>
 6ea:	03c9d793          	srli	a5,s3,0x3c
 6ee:	97de                	add	a5,a5,s7
 6f0:	0007c583          	lbu	a1,0(a5)
 6f4:	855a                	mv	a0,s6
 6f6:	d2dff0ef          	jal	422 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6fa:	0992                	slli	s3,s3,0x4
 6fc:	34fd                	addiw	s1,s1,-1
 6fe:	f4f5                	bnez	s1,6ea <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 700:	8bea                	mv	s7,s10
      state = 0;
 702:	4981                	li	s3,0
 704:	6d02                	ld	s10,0(sp)
 706:	bd29                	j	520 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 708:	008b8993          	addi	s3,s7,8
 70c:	000bb483          	ld	s1,0(s7)
 710:	cc91                	beqz	s1,72c <vprintf+0x256>
        for(; *s; s++)
 712:	0004c583          	lbu	a1,0(s1)
 716:	c195                	beqz	a1,73a <vprintf+0x264>
          putc(fd, *s);
 718:	855a                	mv	a0,s6
 71a:	d09ff0ef          	jal	422 <putc>
        for(; *s; s++)
 71e:	0485                	addi	s1,s1,1
 720:	0004c583          	lbu	a1,0(s1)
 724:	f9f5                	bnez	a1,718 <vprintf+0x242>
        if((s = va_arg(ap, char*)) == 0)
 726:	8bce                	mv	s7,s3
      state = 0;
 728:	4981                	li	s3,0
 72a:	bbdd                	j	520 <vprintf+0x4a>
          s = "(null)";
 72c:	00000497          	auipc	s1,0x0
 730:	2d448493          	addi	s1,s1,724 # a00 <malloc+0x1c4>
        for(; *s; s++)
 734:	02800593          	li	a1,40
 738:	b7c5                	j	718 <vprintf+0x242>
        if((s = va_arg(ap, char*)) == 0)
 73a:	8bce                	mv	s7,s3
      state = 0;
 73c:	4981                	li	s3,0
 73e:	b3cd                	j	520 <vprintf+0x4a>
 740:	6906                	ld	s2,64(sp)
 742:	79e2                	ld	s3,56(sp)
 744:	7a42                	ld	s4,48(sp)
 746:	7aa2                	ld	s5,40(sp)
 748:	7b02                	ld	s6,32(sp)
 74a:	6be2                	ld	s7,24(sp)
 74c:	6c42                	ld	s8,16(sp)
 74e:	6ca2                	ld	s9,8(sp)
    }
  }
}
 750:	60e6                	ld	ra,88(sp)
 752:	6446                	ld	s0,80(sp)
 754:	64a6                	ld	s1,72(sp)
 756:	6125                	addi	sp,sp,96
 758:	8082                	ret

000000000000075a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 75a:	715d                	addi	sp,sp,-80
 75c:	ec06                	sd	ra,24(sp)
 75e:	e822                	sd	s0,16(sp)
 760:	1000                	addi	s0,sp,32
 762:	e010                	sd	a2,0(s0)
 764:	e414                	sd	a3,8(s0)
 766:	e818                	sd	a4,16(s0)
 768:	ec1c                	sd	a5,24(s0)
 76a:	03043023          	sd	a6,32(s0)
 76e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 772:	8622                	mv	a2,s0
 774:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 778:	d5fff0ef          	jal	4d6 <vprintf>
}
 77c:	60e2                	ld	ra,24(sp)
 77e:	6442                	ld	s0,16(sp)
 780:	6161                	addi	sp,sp,80
 782:	8082                	ret

0000000000000784 <printf>:

void
printf(const char *fmt, ...)
{
 784:	711d                	addi	sp,sp,-96
 786:	ec06                	sd	ra,24(sp)
 788:	e822                	sd	s0,16(sp)
 78a:	1000                	addi	s0,sp,32
 78c:	e40c                	sd	a1,8(s0)
 78e:	e810                	sd	a2,16(s0)
 790:	ec14                	sd	a3,24(s0)
 792:	f018                	sd	a4,32(s0)
 794:	f41c                	sd	a5,40(s0)
 796:	03043823          	sd	a6,48(s0)
 79a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 79e:	00840613          	addi	a2,s0,8
 7a2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7a6:	85aa                	mv	a1,a0
 7a8:	4505                	li	a0,1
 7aa:	d2dff0ef          	jal	4d6 <vprintf>
}
 7ae:	60e2                	ld	ra,24(sp)
 7b0:	6442                	ld	s0,16(sp)
 7b2:	6125                	addi	sp,sp,96
 7b4:	8082                	ret

00000000000007b6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7b6:	1141                	addi	sp,sp,-16
 7b8:	e406                	sd	ra,8(sp)
 7ba:	e022                	sd	s0,0(sp)
 7bc:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7be:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c2:	00001797          	auipc	a5,0x1
 7c6:	83e7b783          	ld	a5,-1986(a5) # 1000 <freep>
 7ca:	a02d                	j	7f4 <free+0x3e>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7cc:	4618                	lw	a4,8(a2)
 7ce:	9f2d                	addw	a4,a4,a1
 7d0:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7d4:	6398                	ld	a4,0(a5)
 7d6:	6310                	ld	a2,0(a4)
 7d8:	a83d                	j	816 <free+0x60>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7da:	ff852703          	lw	a4,-8(a0)
 7de:	9f31                	addw	a4,a4,a2
 7e0:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7e2:	ff053683          	ld	a3,-16(a0)
 7e6:	a091                	j	82a <free+0x74>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7e8:	6398                	ld	a4,0(a5)
 7ea:	00e7e463          	bltu	a5,a4,7f2 <free+0x3c>
 7ee:	00e6ea63          	bltu	a3,a4,802 <free+0x4c>
{
 7f2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7f4:	fed7fae3          	bgeu	a5,a3,7e8 <free+0x32>
 7f8:	6398                	ld	a4,0(a5)
 7fa:	00e6e463          	bltu	a3,a4,802 <free+0x4c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7fe:	fee7eae3          	bltu	a5,a4,7f2 <free+0x3c>
  if(bp + bp->s.size == p->s.ptr){
 802:	ff852583          	lw	a1,-8(a0)
 806:	6390                	ld	a2,0(a5)
 808:	02059813          	slli	a6,a1,0x20
 80c:	01c85713          	srli	a4,a6,0x1c
 810:	9736                	add	a4,a4,a3
 812:	fae60de3          	beq	a2,a4,7cc <free+0x16>
    bp->s.ptr = p->s.ptr->s.ptr;
 816:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 81a:	4790                	lw	a2,8(a5)
 81c:	02061593          	slli	a1,a2,0x20
 820:	01c5d713          	srli	a4,a1,0x1c
 824:	973e                	add	a4,a4,a5
 826:	fae68ae3          	beq	a3,a4,7da <free+0x24>
    p->s.ptr = bp->s.ptr;
 82a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 82c:	00000717          	auipc	a4,0x0
 830:	7cf73a23          	sd	a5,2004(a4) # 1000 <freep>
}
 834:	60a2                	ld	ra,8(sp)
 836:	6402                	ld	s0,0(sp)
 838:	0141                	addi	sp,sp,16
 83a:	8082                	ret

000000000000083c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 83c:	7139                	addi	sp,sp,-64
 83e:	fc06                	sd	ra,56(sp)
 840:	f822                	sd	s0,48(sp)
 842:	f04a                	sd	s2,32(sp)
 844:	ec4e                	sd	s3,24(sp)
 846:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 848:	02051993          	slli	s3,a0,0x20
 84c:	0209d993          	srli	s3,s3,0x20
 850:	09bd                	addi	s3,s3,15
 852:	0049d993          	srli	s3,s3,0x4
 856:	2985                	addiw	s3,s3,1
 858:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 85a:	00000517          	auipc	a0,0x0
 85e:	7a653503          	ld	a0,1958(a0) # 1000 <freep>
 862:	c905                	beqz	a0,892 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 864:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 866:	4798                	lw	a4,8(a5)
 868:	09377663          	bgeu	a4,s3,8f4 <malloc+0xb8>
 86c:	f426                	sd	s1,40(sp)
 86e:	e852                	sd	s4,16(sp)
 870:	e456                	sd	s5,8(sp)
 872:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 874:	8a4e                	mv	s4,s3
 876:	6705                	lui	a4,0x1
 878:	00e9f363          	bgeu	s3,a4,87e <malloc+0x42>
 87c:	6a05                	lui	s4,0x1
 87e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 882:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 886:	00000497          	auipc	s1,0x0
 88a:	77a48493          	addi	s1,s1,1914 # 1000 <freep>
  if(p == (char*)-1)
 88e:	5afd                	li	s5,-1
 890:	a83d                	j	8ce <malloc+0x92>
 892:	f426                	sd	s1,40(sp)
 894:	e852                	sd	s4,16(sp)
 896:	e456                	sd	s5,8(sp)
 898:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 89a:	00000797          	auipc	a5,0x0
 89e:	77678793          	addi	a5,a5,1910 # 1010 <base>
 8a2:	00000717          	auipc	a4,0x0
 8a6:	74f73f23          	sd	a5,1886(a4) # 1000 <freep>
 8aa:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8ac:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8b0:	b7d1                	j	874 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 8b2:	6398                	ld	a4,0(a5)
 8b4:	e118                	sd	a4,0(a0)
 8b6:	a899                	j	90c <malloc+0xd0>
  hp->s.size = nu;
 8b8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8bc:	0541                	addi	a0,a0,16
 8be:	ef9ff0ef          	jal	7b6 <free>
  return freep;
 8c2:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 8c4:	c125                	beqz	a0,924 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8c8:	4798                	lw	a4,8(a5)
 8ca:	03277163          	bgeu	a4,s2,8ec <malloc+0xb0>
    if(p == freep)
 8ce:	6098                	ld	a4,0(s1)
 8d0:	853e                	mv	a0,a5
 8d2:	fef71ae3          	bne	a4,a5,8c6 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 8d6:	8552                	mv	a0,s4
 8d8:	b03ff0ef          	jal	3da <sbrk>
  if(p == (char*)-1)
 8dc:	fd551ee3          	bne	a0,s5,8b8 <malloc+0x7c>
        return 0;
 8e0:	4501                	li	a0,0
 8e2:	74a2                	ld	s1,40(sp)
 8e4:	6a42                	ld	s4,16(sp)
 8e6:	6aa2                	ld	s5,8(sp)
 8e8:	6b02                	ld	s6,0(sp)
 8ea:	a03d                	j	918 <malloc+0xdc>
 8ec:	74a2                	ld	s1,40(sp)
 8ee:	6a42                	ld	s4,16(sp)
 8f0:	6aa2                	ld	s5,8(sp)
 8f2:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8f4:	fae90fe3          	beq	s2,a4,8b2 <malloc+0x76>
        p->s.size -= nunits;
 8f8:	4137073b          	subw	a4,a4,s3
 8fc:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8fe:	02071693          	slli	a3,a4,0x20
 902:	01c6d713          	srli	a4,a3,0x1c
 906:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 908:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 90c:	00000717          	auipc	a4,0x0
 910:	6ea73a23          	sd	a0,1780(a4) # 1000 <freep>
      return (void*)(p + 1);
 914:	01078513          	addi	a0,a5,16
  }
}
 918:	70e2                	ld	ra,56(sp)
 91a:	7442                	ld	s0,48(sp)
 91c:	7902                	ld	s2,32(sp)
 91e:	69e2                	ld	s3,24(sp)
 920:	6121                	addi	sp,sp,64
 922:	8082                	ret
 924:	74a2                	ld	s1,40(sp)
 926:	6a42                	ld	s4,16(sp)
 928:	6aa2                	ld	s5,8(sp)
 92a:	6b02                	ld	s6,0(sp)
 92c:	b7f5                	j	918 <malloc+0xdc>
