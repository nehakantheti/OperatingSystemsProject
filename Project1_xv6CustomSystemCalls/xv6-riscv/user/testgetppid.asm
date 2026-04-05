
user/_testgetppid:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main() {
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32

    printf("In the initial process, Parent PID: %d\n", getppid());
   8:	404000ef          	jal	40c <getppid>
   c:	85aa                	mv	a1,a0
   e:	00001517          	auipc	a0,0x1
  12:	93250513          	addi	a0,a0,-1742 # 940 <malloc+0xf2>
  16:	780000ef          	jal	796 <printf>
    int pid = fork();  // Create a child process
  1a:	342000ef          	jal	35c <fork>

    if (pid < 0) {
  1e:	02054963          	bltz	a0,50 <main+0x50>
        // Error during fork
        printf("Fork failed!\n");
        exit(1);
    }

    if (pid == 0) {
  22:	ed35                	bnez	a0,9e <main+0x9e>
        int child_pid = fork();
  24:	338000ef          	jal	35c <fork>
        if (child_pid < 0) {
  28:	02054e63          	bltz	a0,64 <main+0x64>
  2c:	e426                	sd	s1,8(sp)
            // Error during fork
            printf("Child fork failed!\n");
            exit(1);
        }

        if (child_pid == 0) {
  2e:	e529                	bnez	a0,78 <main+0x78>
            // In the grandchild process
            printf("In the grandchild process (PID: %d), Parent PID: %d\n", getpid(), getppid());
  30:	3b4000ef          	jal	3e4 <getpid>
  34:	84aa                	mv	s1,a0
  36:	3d6000ef          	jal	40c <getppid>
  3a:	862a                	mv	a2,a0
  3c:	85a6                	mv	a1,s1
  3e:	00001517          	auipc	a0,0x1
  42:	95a50513          	addi	a0,a0,-1702 # 998 <malloc+0x14a>
  46:	750000ef          	jal	796 <printf>
            exit(0);  // Grandchild exits
  4a:	4501                	li	a0,0
  4c:	318000ef          	jal	364 <exit>
  50:	e426                	sd	s1,8(sp)
        printf("Fork failed!\n");
  52:	00001517          	auipc	a0,0x1
  56:	91650513          	addi	a0,a0,-1770 # 968 <malloc+0x11a>
  5a:	73c000ef          	jal	796 <printf>
        exit(1);
  5e:	4505                	li	a0,1
  60:	304000ef          	jal	364 <exit>
  64:	e426                	sd	s1,8(sp)
            printf("Child fork failed!\n");
  66:	00001517          	auipc	a0,0x1
  6a:	91a50513          	addi	a0,a0,-1766 # 980 <malloc+0x132>
  6e:	728000ef          	jal	796 <printf>
            exit(1);
  72:	4505                	li	a0,1
  74:	2f0000ef          	jal	364 <exit>
        }
        wait(0);
  78:	4501                	li	a0,0
  7a:	2f2000ef          	jal	36c <wait>
        printf("In the child process (PID: %d), Parent PID: %d\n", getpid(), getppid());
  7e:	366000ef          	jal	3e4 <getpid>
  82:	84aa                	mv	s1,a0
  84:	388000ef          	jal	40c <getppid>
  88:	862a                	mv	a2,a0
  8a:	85a6                	mv	a1,s1
  8c:	00001517          	auipc	a0,0x1
  90:	94450513          	addi	a0,a0,-1724 # 9d0 <malloc+0x182>
  94:	702000ef          	jal	796 <printf>
        exit(0);  // Child exits
  98:	4501                	li	a0,0
  9a:	2ca000ef          	jal	364 <exit>
  9e:	e426                	sd	s1,8(sp)
    }

    // Parent process
    wait(0);  // Wait for child processes to exit
  a0:	4501                	li	a0,0
  a2:	2ca000ef          	jal	36c <wait>

    printf("In the parent process (PID: %d), Parent PID: %d\n", getpid(), getppid());
  a6:	33e000ef          	jal	3e4 <getpid>
  aa:	84aa                	mv	s1,a0
  ac:	360000ef          	jal	40c <getppid>
  b0:	862a                	mv	a2,a0
  b2:	85a6                	mv	a1,s1
  b4:	00001517          	auipc	a0,0x1
  b8:	94c50513          	addi	a0,a0,-1716 # a00 <malloc+0x1b2>
  bc:	6da000ef          	jal	796 <printf>

    exit(0);  // Parent exits
  c0:	4501                	li	a0,0
  c2:	2a2000ef          	jal	364 <exit>

00000000000000c6 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
  c6:	1141                	addi	sp,sp,-16
  c8:	e406                	sd	ra,8(sp)
  ca:	e022                	sd	s0,0(sp)
  cc:	0800                	addi	s0,sp,16
  extern int main();
  main();
  ce:	f33ff0ef          	jal	0 <main>
  exit(0);
  d2:	4501                	li	a0,0
  d4:	290000ef          	jal	364 <exit>

00000000000000d8 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  d8:	1141                	addi	sp,sp,-16
  da:	e406                	sd	ra,8(sp)
  dc:	e022                	sd	s0,0(sp)
  de:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  e0:	87aa                	mv	a5,a0
  e2:	0585                	addi	a1,a1,1
  e4:	0785                	addi	a5,a5,1
  e6:	fff5c703          	lbu	a4,-1(a1)
  ea:	fee78fa3          	sb	a4,-1(a5)
  ee:	fb75                	bnez	a4,e2 <strcpy+0xa>
    ;
  return os;
}
  f0:	60a2                	ld	ra,8(sp)
  f2:	6402                	ld	s0,0(sp)
  f4:	0141                	addi	sp,sp,16
  f6:	8082                	ret

00000000000000f8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  f8:	1141                	addi	sp,sp,-16
  fa:	e406                	sd	ra,8(sp)
  fc:	e022                	sd	s0,0(sp)
  fe:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 100:	00054783          	lbu	a5,0(a0)
 104:	cb91                	beqz	a5,118 <strcmp+0x20>
 106:	0005c703          	lbu	a4,0(a1)
 10a:	00f71763          	bne	a4,a5,118 <strcmp+0x20>
    p++, q++;
 10e:	0505                	addi	a0,a0,1
 110:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 112:	00054783          	lbu	a5,0(a0)
 116:	fbe5                	bnez	a5,106 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 118:	0005c503          	lbu	a0,0(a1)
}
 11c:	40a7853b          	subw	a0,a5,a0
 120:	60a2                	ld	ra,8(sp)
 122:	6402                	ld	s0,0(sp)
 124:	0141                	addi	sp,sp,16
 126:	8082                	ret

0000000000000128 <strlen>:

uint
strlen(const char *s)
{
 128:	1141                	addi	sp,sp,-16
 12a:	e406                	sd	ra,8(sp)
 12c:	e022                	sd	s0,0(sp)
 12e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 130:	00054783          	lbu	a5,0(a0)
 134:	cf99                	beqz	a5,152 <strlen+0x2a>
 136:	0505                	addi	a0,a0,1
 138:	87aa                	mv	a5,a0
 13a:	86be                	mv	a3,a5
 13c:	0785                	addi	a5,a5,1
 13e:	fff7c703          	lbu	a4,-1(a5)
 142:	ff65                	bnez	a4,13a <strlen+0x12>
 144:	40a6853b          	subw	a0,a3,a0
 148:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 14a:	60a2                	ld	ra,8(sp)
 14c:	6402                	ld	s0,0(sp)
 14e:	0141                	addi	sp,sp,16
 150:	8082                	ret
  for(n = 0; s[n]; n++)
 152:	4501                	li	a0,0
 154:	bfdd                	j	14a <strlen+0x22>

0000000000000156 <memset>:

void*
memset(void *dst, int c, uint n)
{
 156:	1141                	addi	sp,sp,-16
 158:	e406                	sd	ra,8(sp)
 15a:	e022                	sd	s0,0(sp)
 15c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 15e:	ca19                	beqz	a2,174 <memset+0x1e>
 160:	87aa                	mv	a5,a0
 162:	1602                	slli	a2,a2,0x20
 164:	9201                	srli	a2,a2,0x20
 166:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 16a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 16e:	0785                	addi	a5,a5,1
 170:	fee79de3          	bne	a5,a4,16a <memset+0x14>
  }
  return dst;
}
 174:	60a2                	ld	ra,8(sp)
 176:	6402                	ld	s0,0(sp)
 178:	0141                	addi	sp,sp,16
 17a:	8082                	ret

000000000000017c <strchr>:

char*
strchr(const char *s, char c)
{
 17c:	1141                	addi	sp,sp,-16
 17e:	e406                	sd	ra,8(sp)
 180:	e022                	sd	s0,0(sp)
 182:	0800                	addi	s0,sp,16
  for(; *s; s++)
 184:	00054783          	lbu	a5,0(a0)
 188:	cf81                	beqz	a5,1a0 <strchr+0x24>
    if(*s == c)
 18a:	00f58763          	beq	a1,a5,198 <strchr+0x1c>
  for(; *s; s++)
 18e:	0505                	addi	a0,a0,1
 190:	00054783          	lbu	a5,0(a0)
 194:	fbfd                	bnez	a5,18a <strchr+0xe>
      return (char*)s;
  return 0;
 196:	4501                	li	a0,0
}
 198:	60a2                	ld	ra,8(sp)
 19a:	6402                	ld	s0,0(sp)
 19c:	0141                	addi	sp,sp,16
 19e:	8082                	ret
  return 0;
 1a0:	4501                	li	a0,0
 1a2:	bfdd                	j	198 <strchr+0x1c>

00000000000001a4 <gets>:

char*
gets(char *buf, int max)
{
 1a4:	7159                	addi	sp,sp,-112
 1a6:	f486                	sd	ra,104(sp)
 1a8:	f0a2                	sd	s0,96(sp)
 1aa:	eca6                	sd	s1,88(sp)
 1ac:	e8ca                	sd	s2,80(sp)
 1ae:	e4ce                	sd	s3,72(sp)
 1b0:	e0d2                	sd	s4,64(sp)
 1b2:	fc56                	sd	s5,56(sp)
 1b4:	f85a                	sd	s6,48(sp)
 1b6:	f45e                	sd	s7,40(sp)
 1b8:	f062                	sd	s8,32(sp)
 1ba:	ec66                	sd	s9,24(sp)
 1bc:	e86a                	sd	s10,16(sp)
 1be:	1880                	addi	s0,sp,112
 1c0:	8caa                	mv	s9,a0
 1c2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1c4:	892a                	mv	s2,a0
 1c6:	4481                	li	s1,0
    cc = read(0, &c, 1);
 1c8:	f9f40b13          	addi	s6,s0,-97
 1cc:	4a85                	li	s5,1
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1ce:	4ba9                	li	s7,10
 1d0:	4c35                	li	s8,13
  for(i=0; i+1 < max; ){
 1d2:	8d26                	mv	s10,s1
 1d4:	0014899b          	addiw	s3,s1,1
 1d8:	84ce                	mv	s1,s3
 1da:	0349d563          	bge	s3,s4,204 <gets+0x60>
    cc = read(0, &c, 1);
 1de:	8656                	mv	a2,s5
 1e0:	85da                	mv	a1,s6
 1e2:	4501                	li	a0,0
 1e4:	198000ef          	jal	37c <read>
    if(cc < 1)
 1e8:	00a05e63          	blez	a0,204 <gets+0x60>
    buf[i++] = c;
 1ec:	f9f44783          	lbu	a5,-97(s0)
 1f0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1f4:	01778763          	beq	a5,s7,202 <gets+0x5e>
 1f8:	0905                	addi	s2,s2,1
 1fa:	fd879ce3          	bne	a5,s8,1d2 <gets+0x2e>
    buf[i++] = c;
 1fe:	8d4e                	mv	s10,s3
 200:	a011                	j	204 <gets+0x60>
 202:	8d4e                	mv	s10,s3
      break;
  }
  buf[i] = '\0';
 204:	9d66                	add	s10,s10,s9
 206:	000d0023          	sb	zero,0(s10)
  return buf;
}
 20a:	8566                	mv	a0,s9
 20c:	70a6                	ld	ra,104(sp)
 20e:	7406                	ld	s0,96(sp)
 210:	64e6                	ld	s1,88(sp)
 212:	6946                	ld	s2,80(sp)
 214:	69a6                	ld	s3,72(sp)
 216:	6a06                	ld	s4,64(sp)
 218:	7ae2                	ld	s5,56(sp)
 21a:	7b42                	ld	s6,48(sp)
 21c:	7ba2                	ld	s7,40(sp)
 21e:	7c02                	ld	s8,32(sp)
 220:	6ce2                	ld	s9,24(sp)
 222:	6d42                	ld	s10,16(sp)
 224:	6165                	addi	sp,sp,112
 226:	8082                	ret

0000000000000228 <stat>:

int
stat(const char *n, struct stat *st)
{
 228:	1101                	addi	sp,sp,-32
 22a:	ec06                	sd	ra,24(sp)
 22c:	e822                	sd	s0,16(sp)
 22e:	e04a                	sd	s2,0(sp)
 230:	1000                	addi	s0,sp,32
 232:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 234:	4581                	li	a1,0
 236:	16e000ef          	jal	3a4 <open>
  if(fd < 0)
 23a:	02054263          	bltz	a0,25e <stat+0x36>
 23e:	e426                	sd	s1,8(sp)
 240:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 242:	85ca                	mv	a1,s2
 244:	178000ef          	jal	3bc <fstat>
 248:	892a                	mv	s2,a0
  close(fd);
 24a:	8526                	mv	a0,s1
 24c:	140000ef          	jal	38c <close>
  return r;
 250:	64a2                	ld	s1,8(sp)
}
 252:	854a                	mv	a0,s2
 254:	60e2                	ld	ra,24(sp)
 256:	6442                	ld	s0,16(sp)
 258:	6902                	ld	s2,0(sp)
 25a:	6105                	addi	sp,sp,32
 25c:	8082                	ret
    return -1;
 25e:	597d                	li	s2,-1
 260:	bfcd                	j	252 <stat+0x2a>

0000000000000262 <atoi>:

int
atoi(const char *s)
{
 262:	1141                	addi	sp,sp,-16
 264:	e406                	sd	ra,8(sp)
 266:	e022                	sd	s0,0(sp)
 268:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 26a:	00054683          	lbu	a3,0(a0)
 26e:	fd06879b          	addiw	a5,a3,-48
 272:	0ff7f793          	zext.b	a5,a5
 276:	4625                	li	a2,9
 278:	02f66963          	bltu	a2,a5,2aa <atoi+0x48>
 27c:	872a                	mv	a4,a0
  n = 0;
 27e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 280:	0705                	addi	a4,a4,1
 282:	0025179b          	slliw	a5,a0,0x2
 286:	9fa9                	addw	a5,a5,a0
 288:	0017979b          	slliw	a5,a5,0x1
 28c:	9fb5                	addw	a5,a5,a3
 28e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 292:	00074683          	lbu	a3,0(a4)
 296:	fd06879b          	addiw	a5,a3,-48
 29a:	0ff7f793          	zext.b	a5,a5
 29e:	fef671e3          	bgeu	a2,a5,280 <atoi+0x1e>
  return n;
}
 2a2:	60a2                	ld	ra,8(sp)
 2a4:	6402                	ld	s0,0(sp)
 2a6:	0141                	addi	sp,sp,16
 2a8:	8082                	ret
  n = 0;
 2aa:	4501                	li	a0,0
 2ac:	bfdd                	j	2a2 <atoi+0x40>

00000000000002ae <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2ae:	1141                	addi	sp,sp,-16
 2b0:	e406                	sd	ra,8(sp)
 2b2:	e022                	sd	s0,0(sp)
 2b4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2b6:	02b57563          	bgeu	a0,a1,2e0 <memmove+0x32>
    while(n-- > 0)
 2ba:	00c05f63          	blez	a2,2d8 <memmove+0x2a>
 2be:	1602                	slli	a2,a2,0x20
 2c0:	9201                	srli	a2,a2,0x20
 2c2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2c6:	872a                	mv	a4,a0
      *dst++ = *src++;
 2c8:	0585                	addi	a1,a1,1
 2ca:	0705                	addi	a4,a4,1
 2cc:	fff5c683          	lbu	a3,-1(a1)
 2d0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2d4:	fee79ae3          	bne	a5,a4,2c8 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2d8:	60a2                	ld	ra,8(sp)
 2da:	6402                	ld	s0,0(sp)
 2dc:	0141                	addi	sp,sp,16
 2de:	8082                	ret
    dst += n;
 2e0:	00c50733          	add	a4,a0,a2
    src += n;
 2e4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2e6:	fec059e3          	blez	a2,2d8 <memmove+0x2a>
 2ea:	fff6079b          	addiw	a5,a2,-1
 2ee:	1782                	slli	a5,a5,0x20
 2f0:	9381                	srli	a5,a5,0x20
 2f2:	fff7c793          	not	a5,a5
 2f6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2f8:	15fd                	addi	a1,a1,-1
 2fa:	177d                	addi	a4,a4,-1
 2fc:	0005c683          	lbu	a3,0(a1)
 300:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 304:	fef71ae3          	bne	a4,a5,2f8 <memmove+0x4a>
 308:	bfc1                	j	2d8 <memmove+0x2a>

000000000000030a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 30a:	1141                	addi	sp,sp,-16
 30c:	e406                	sd	ra,8(sp)
 30e:	e022                	sd	s0,0(sp)
 310:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 312:	ca0d                	beqz	a2,344 <memcmp+0x3a>
 314:	fff6069b          	addiw	a3,a2,-1
 318:	1682                	slli	a3,a3,0x20
 31a:	9281                	srli	a3,a3,0x20
 31c:	0685                	addi	a3,a3,1
 31e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 320:	00054783          	lbu	a5,0(a0)
 324:	0005c703          	lbu	a4,0(a1)
 328:	00e79863          	bne	a5,a4,338 <memcmp+0x2e>
      return *p1 - *p2;
    }
    p1++;
 32c:	0505                	addi	a0,a0,1
    p2++;
 32e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 330:	fed518e3          	bne	a0,a3,320 <memcmp+0x16>
  }
  return 0;
 334:	4501                	li	a0,0
 336:	a019                	j	33c <memcmp+0x32>
      return *p1 - *p2;
 338:	40e7853b          	subw	a0,a5,a4
}
 33c:	60a2                	ld	ra,8(sp)
 33e:	6402                	ld	s0,0(sp)
 340:	0141                	addi	sp,sp,16
 342:	8082                	ret
  return 0;
 344:	4501                	li	a0,0
 346:	bfdd                	j	33c <memcmp+0x32>

0000000000000348 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 348:	1141                	addi	sp,sp,-16
 34a:	e406                	sd	ra,8(sp)
 34c:	e022                	sd	s0,0(sp)
 34e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 350:	f5fff0ef          	jal	2ae <memmove>
}
 354:	60a2                	ld	ra,8(sp)
 356:	6402                	ld	s0,0(sp)
 358:	0141                	addi	sp,sp,16
 35a:	8082                	ret

000000000000035c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 35c:	4885                	li	a7,1
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <exit>:
.global exit
exit:
 li a7, SYS_exit
 364:	4889                	li	a7,2
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <wait>:
.global wait
wait:
 li a7, SYS_wait
 36c:	488d                	li	a7,3
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 374:	4891                	li	a7,4
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <read>:
.global read
read:
 li a7, SYS_read
 37c:	4895                	li	a7,5
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <write>:
.global write
write:
 li a7, SYS_write
 384:	48c1                	li	a7,16
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <close>:
.global close
close:
 li a7, SYS_close
 38c:	48d5                	li	a7,21
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <kill>:
.global kill
kill:
 li a7, SYS_kill
 394:	4899                	li	a7,6
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <exec>:
.global exec
exec:
 li a7, SYS_exec
 39c:	489d                	li	a7,7
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <open>:
.global open
open:
 li a7, SYS_open
 3a4:	48bd                	li	a7,15
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3ac:	48c5                	li	a7,17
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3b4:	48c9                	li	a7,18
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3bc:	48a1                	li	a7,8
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <link>:
.global link
link:
 li a7, SYS_link
 3c4:	48cd                	li	a7,19
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3cc:	48d1                	li	a7,20
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3d4:	48a5                	li	a7,9
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <dup>:
.global dup
dup:
 li a7, SYS_dup
 3dc:	48a9                	li	a7,10
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3e4:	48ad                	li	a7,11
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3ec:	48b1                	li	a7,12
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3f4:	48b5                	li	a7,13
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3fc:	48b9                	li	a7,14
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <forex>:
.global forex
forex:
 li a7, SYS_forex
 404:	48d9                	li	a7,22
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 40c:	48dd                	li	a7,23
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <usleep>:
.global usleep
usleep:
 li a7, SYS_usleep
 414:	48e1                	li	a7,24
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 41c:	48e5                	li	a7,25
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <sigstop>:
.global sigstop
sigstop:
 li a7, SYS_sigstop
 424:	48e9                	li	a7,26
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <sigcont>:
.global sigcont
sigcont:
 li a7, SYS_sigcont
 42c:	48ed                	li	a7,27
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 434:	1101                	addi	sp,sp,-32
 436:	ec06                	sd	ra,24(sp)
 438:	e822                	sd	s0,16(sp)
 43a:	1000                	addi	s0,sp,32
 43c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 440:	4605                	li	a2,1
 442:	fef40593          	addi	a1,s0,-17
 446:	f3fff0ef          	jal	384 <write>
}
 44a:	60e2                	ld	ra,24(sp)
 44c:	6442                	ld	s0,16(sp)
 44e:	6105                	addi	sp,sp,32
 450:	8082                	ret

0000000000000452 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 452:	7139                	addi	sp,sp,-64
 454:	fc06                	sd	ra,56(sp)
 456:	f822                	sd	s0,48(sp)
 458:	f426                	sd	s1,40(sp)
 45a:	f04a                	sd	s2,32(sp)
 45c:	ec4e                	sd	s3,24(sp)
 45e:	0080                	addi	s0,sp,64
 460:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 462:	c299                	beqz	a3,468 <printint+0x16>
 464:	0605ce63          	bltz	a1,4e0 <printint+0x8e>
  neg = 0;
 468:	4e01                	li	t3,0
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 46a:	fc040313          	addi	t1,s0,-64
  neg = 0;
 46e:	869a                	mv	a3,t1
  i = 0;
 470:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 472:	00000817          	auipc	a6,0x0
 476:	5ce80813          	addi	a6,a6,1486 # a40 <digits>
 47a:	88be                	mv	a7,a5
 47c:	0017851b          	addiw	a0,a5,1
 480:	87aa                	mv	a5,a0
 482:	02c5f73b          	remuw	a4,a1,a2
 486:	1702                	slli	a4,a4,0x20
 488:	9301                	srli	a4,a4,0x20
 48a:	9742                	add	a4,a4,a6
 48c:	00074703          	lbu	a4,0(a4)
 490:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 494:	872e                	mv	a4,a1
 496:	02c5d5bb          	divuw	a1,a1,a2
 49a:	0685                	addi	a3,a3,1
 49c:	fcc77fe3          	bgeu	a4,a2,47a <printint+0x28>
  if(neg)
 4a0:	000e0c63          	beqz	t3,4b8 <printint+0x66>
    buf[i++] = '-';
 4a4:	fd050793          	addi	a5,a0,-48
 4a8:	00878533          	add	a0,a5,s0
 4ac:	02d00793          	li	a5,45
 4b0:	fef50823          	sb	a5,-16(a0)
 4b4:	0028879b          	addiw	a5,a7,2

  while(--i >= 0)
 4b8:	fff7899b          	addiw	s3,a5,-1
 4bc:	006784b3          	add	s1,a5,t1
    putc(fd, buf[i]);
 4c0:	fff4c583          	lbu	a1,-1(s1)
 4c4:	854a                	mv	a0,s2
 4c6:	f6fff0ef          	jal	434 <putc>
  while(--i >= 0)
 4ca:	39fd                	addiw	s3,s3,-1
 4cc:	14fd                	addi	s1,s1,-1
 4ce:	fe09d9e3          	bgez	s3,4c0 <printint+0x6e>
}
 4d2:	70e2                	ld	ra,56(sp)
 4d4:	7442                	ld	s0,48(sp)
 4d6:	74a2                	ld	s1,40(sp)
 4d8:	7902                	ld	s2,32(sp)
 4da:	69e2                	ld	s3,24(sp)
 4dc:	6121                	addi	sp,sp,64
 4de:	8082                	ret
    x = -xx;
 4e0:	40b005bb          	negw	a1,a1
    neg = 1;
 4e4:	4e05                	li	t3,1
    x = -xx;
 4e6:	b751                	j	46a <printint+0x18>

00000000000004e8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4e8:	711d                	addi	sp,sp,-96
 4ea:	ec86                	sd	ra,88(sp)
 4ec:	e8a2                	sd	s0,80(sp)
 4ee:	e4a6                	sd	s1,72(sp)
 4f0:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4f2:	0005c483          	lbu	s1,0(a1)
 4f6:	26048663          	beqz	s1,762 <vprintf+0x27a>
 4fa:	e0ca                	sd	s2,64(sp)
 4fc:	fc4e                	sd	s3,56(sp)
 4fe:	f852                	sd	s4,48(sp)
 500:	f456                	sd	s5,40(sp)
 502:	f05a                	sd	s6,32(sp)
 504:	ec5e                	sd	s7,24(sp)
 506:	e862                	sd	s8,16(sp)
 508:	e466                	sd	s9,8(sp)
 50a:	8b2a                	mv	s6,a0
 50c:	8a2e                	mv	s4,a1
 50e:	8bb2                	mv	s7,a2
  state = 0;
 510:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 512:	4901                	li	s2,0
 514:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 516:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 51a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 51e:	06c00c93          	li	s9,108
 522:	a00d                	j	544 <vprintf+0x5c>
        putc(fd, c0);
 524:	85a6                	mv	a1,s1
 526:	855a                	mv	a0,s6
 528:	f0dff0ef          	jal	434 <putc>
 52c:	a019                	j	532 <vprintf+0x4a>
    } else if(state == '%'){
 52e:	03598363          	beq	s3,s5,554 <vprintf+0x6c>
  for(i = 0; fmt[i]; i++){
 532:	0019079b          	addiw	a5,s2,1
 536:	893e                	mv	s2,a5
 538:	873e                	mv	a4,a5
 53a:	97d2                	add	a5,a5,s4
 53c:	0007c483          	lbu	s1,0(a5)
 540:	20048963          	beqz	s1,752 <vprintf+0x26a>
    c0 = fmt[i] & 0xff;
 544:	0004879b          	sext.w	a5,s1
    if(state == 0){
 548:	fe0993e3          	bnez	s3,52e <vprintf+0x46>
      if(c0 == '%'){
 54c:	fd579ce3          	bne	a5,s5,524 <vprintf+0x3c>
        state = '%';
 550:	89be                	mv	s3,a5
 552:	b7c5                	j	532 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 554:	00ea06b3          	add	a3,s4,a4
 558:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 55c:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 55e:	c681                	beqz	a3,566 <vprintf+0x7e>
 560:	9752                	add	a4,a4,s4
 562:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 566:	03878e63          	beq	a5,s8,5a2 <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 56a:	05978863          	beq	a5,s9,5ba <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 56e:	07500713          	li	a4,117
 572:	0ee78263          	beq	a5,a4,656 <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 576:	07800713          	li	a4,120
 57a:	12e78463          	beq	a5,a4,6a2 <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 57e:	07000713          	li	a4,112
 582:	14e78963          	beq	a5,a4,6d4 <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 586:	07300713          	li	a4,115
 58a:	18e78863          	beq	a5,a4,71a <vprintf+0x232>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 58e:	02500713          	li	a4,37
 592:	04e79463          	bne	a5,a4,5da <vprintf+0xf2>
        putc(fd, '%');
 596:	85ba                	mv	a1,a4
 598:	855a                	mv	a0,s6
 59a:	e9bff0ef          	jal	434 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 59e:	4981                	li	s3,0
 5a0:	bf49                	j	532 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 5a2:	008b8493          	addi	s1,s7,8
 5a6:	4685                	li	a3,1
 5a8:	4629                	li	a2,10
 5aa:	000ba583          	lw	a1,0(s7)
 5ae:	855a                	mv	a0,s6
 5b0:	ea3ff0ef          	jal	452 <printint>
 5b4:	8ba6                	mv	s7,s1
      state = 0;
 5b6:	4981                	li	s3,0
 5b8:	bfad                	j	532 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 5ba:	06400793          	li	a5,100
 5be:	02f68963          	beq	a3,a5,5f0 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5c2:	06c00793          	li	a5,108
 5c6:	04f68263          	beq	a3,a5,60a <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 5ca:	07500793          	li	a5,117
 5ce:	0af68063          	beq	a3,a5,66e <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 5d2:	07800793          	li	a5,120
 5d6:	0ef68263          	beq	a3,a5,6ba <vprintf+0x1d2>
        putc(fd, '%');
 5da:	02500593          	li	a1,37
 5de:	855a                	mv	a0,s6
 5e0:	e55ff0ef          	jal	434 <putc>
        putc(fd, c0);
 5e4:	85a6                	mv	a1,s1
 5e6:	855a                	mv	a0,s6
 5e8:	e4dff0ef          	jal	434 <putc>
      state = 0;
 5ec:	4981                	li	s3,0
 5ee:	b791                	j	532 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5f0:	008b8493          	addi	s1,s7,8
 5f4:	4685                	li	a3,1
 5f6:	4629                	li	a2,10
 5f8:	000ba583          	lw	a1,0(s7)
 5fc:	855a                	mv	a0,s6
 5fe:	e55ff0ef          	jal	452 <printint>
        i += 1;
 602:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 604:	8ba6                	mv	s7,s1
      state = 0;
 606:	4981                	li	s3,0
        i += 1;
 608:	b72d                	j	532 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 60a:	06400793          	li	a5,100
 60e:	02f60763          	beq	a2,a5,63c <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 612:	07500793          	li	a5,117
 616:	06f60963          	beq	a2,a5,688 <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 61a:	07800793          	li	a5,120
 61e:	faf61ee3          	bne	a2,a5,5da <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 622:	008b8493          	addi	s1,s7,8
 626:	4681                	li	a3,0
 628:	4641                	li	a2,16
 62a:	000ba583          	lw	a1,0(s7)
 62e:	855a                	mv	a0,s6
 630:	e23ff0ef          	jal	452 <printint>
        i += 2;
 634:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 636:	8ba6                	mv	s7,s1
      state = 0;
 638:	4981                	li	s3,0
        i += 2;
 63a:	bde5                	j	532 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 63c:	008b8493          	addi	s1,s7,8
 640:	4685                	li	a3,1
 642:	4629                	li	a2,10
 644:	000ba583          	lw	a1,0(s7)
 648:	855a                	mv	a0,s6
 64a:	e09ff0ef          	jal	452 <printint>
        i += 2;
 64e:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 650:	8ba6                	mv	s7,s1
      state = 0;
 652:	4981                	li	s3,0
        i += 2;
 654:	bdf9                	j	532 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 656:	008b8493          	addi	s1,s7,8
 65a:	4681                	li	a3,0
 65c:	4629                	li	a2,10
 65e:	000ba583          	lw	a1,0(s7)
 662:	855a                	mv	a0,s6
 664:	defff0ef          	jal	452 <printint>
 668:	8ba6                	mv	s7,s1
      state = 0;
 66a:	4981                	li	s3,0
 66c:	b5d9                	j	532 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 66e:	008b8493          	addi	s1,s7,8
 672:	4681                	li	a3,0
 674:	4629                	li	a2,10
 676:	000ba583          	lw	a1,0(s7)
 67a:	855a                	mv	a0,s6
 67c:	dd7ff0ef          	jal	452 <printint>
        i += 1;
 680:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 682:	8ba6                	mv	s7,s1
      state = 0;
 684:	4981                	li	s3,0
        i += 1;
 686:	b575                	j	532 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 688:	008b8493          	addi	s1,s7,8
 68c:	4681                	li	a3,0
 68e:	4629                	li	a2,10
 690:	000ba583          	lw	a1,0(s7)
 694:	855a                	mv	a0,s6
 696:	dbdff0ef          	jal	452 <printint>
        i += 2;
 69a:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 69c:	8ba6                	mv	s7,s1
      state = 0;
 69e:	4981                	li	s3,0
        i += 2;
 6a0:	bd49                	j	532 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 6a2:	008b8493          	addi	s1,s7,8
 6a6:	4681                	li	a3,0
 6a8:	4641                	li	a2,16
 6aa:	000ba583          	lw	a1,0(s7)
 6ae:	855a                	mv	a0,s6
 6b0:	da3ff0ef          	jal	452 <printint>
 6b4:	8ba6                	mv	s7,s1
      state = 0;
 6b6:	4981                	li	s3,0
 6b8:	bdad                	j	532 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ba:	008b8493          	addi	s1,s7,8
 6be:	4681                	li	a3,0
 6c0:	4641                	li	a2,16
 6c2:	000ba583          	lw	a1,0(s7)
 6c6:	855a                	mv	a0,s6
 6c8:	d8bff0ef          	jal	452 <printint>
        i += 1;
 6cc:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ce:	8ba6                	mv	s7,s1
      state = 0;
 6d0:	4981                	li	s3,0
        i += 1;
 6d2:	b585                	j	532 <vprintf+0x4a>
 6d4:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 6d6:	008b8d13          	addi	s10,s7,8
 6da:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6de:	03000593          	li	a1,48
 6e2:	855a                	mv	a0,s6
 6e4:	d51ff0ef          	jal	434 <putc>
  putc(fd, 'x');
 6e8:	07800593          	li	a1,120
 6ec:	855a                	mv	a0,s6
 6ee:	d47ff0ef          	jal	434 <putc>
 6f2:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6f4:	00000b97          	auipc	s7,0x0
 6f8:	34cb8b93          	addi	s7,s7,844 # a40 <digits>
 6fc:	03c9d793          	srli	a5,s3,0x3c
 700:	97de                	add	a5,a5,s7
 702:	0007c583          	lbu	a1,0(a5)
 706:	855a                	mv	a0,s6
 708:	d2dff0ef          	jal	434 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 70c:	0992                	slli	s3,s3,0x4
 70e:	34fd                	addiw	s1,s1,-1
 710:	f4f5                	bnez	s1,6fc <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 712:	8bea                	mv	s7,s10
      state = 0;
 714:	4981                	li	s3,0
 716:	6d02                	ld	s10,0(sp)
 718:	bd29                	j	532 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 71a:	008b8993          	addi	s3,s7,8
 71e:	000bb483          	ld	s1,0(s7)
 722:	cc91                	beqz	s1,73e <vprintf+0x256>
        for(; *s; s++)
 724:	0004c583          	lbu	a1,0(s1)
 728:	c195                	beqz	a1,74c <vprintf+0x264>
          putc(fd, *s);
 72a:	855a                	mv	a0,s6
 72c:	d09ff0ef          	jal	434 <putc>
        for(; *s; s++)
 730:	0485                	addi	s1,s1,1
 732:	0004c583          	lbu	a1,0(s1)
 736:	f9f5                	bnez	a1,72a <vprintf+0x242>
        if((s = va_arg(ap, char*)) == 0)
 738:	8bce                	mv	s7,s3
      state = 0;
 73a:	4981                	li	s3,0
 73c:	bbdd                	j	532 <vprintf+0x4a>
          s = "(null)";
 73e:	00000497          	auipc	s1,0x0
 742:	2fa48493          	addi	s1,s1,762 # a38 <malloc+0x1ea>
        for(; *s; s++)
 746:	02800593          	li	a1,40
 74a:	b7c5                	j	72a <vprintf+0x242>
        if((s = va_arg(ap, char*)) == 0)
 74c:	8bce                	mv	s7,s3
      state = 0;
 74e:	4981                	li	s3,0
 750:	b3cd                	j	532 <vprintf+0x4a>
 752:	6906                	ld	s2,64(sp)
 754:	79e2                	ld	s3,56(sp)
 756:	7a42                	ld	s4,48(sp)
 758:	7aa2                	ld	s5,40(sp)
 75a:	7b02                	ld	s6,32(sp)
 75c:	6be2                	ld	s7,24(sp)
 75e:	6c42                	ld	s8,16(sp)
 760:	6ca2                	ld	s9,8(sp)
    }
  }
}
 762:	60e6                	ld	ra,88(sp)
 764:	6446                	ld	s0,80(sp)
 766:	64a6                	ld	s1,72(sp)
 768:	6125                	addi	sp,sp,96
 76a:	8082                	ret

000000000000076c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 76c:	715d                	addi	sp,sp,-80
 76e:	ec06                	sd	ra,24(sp)
 770:	e822                	sd	s0,16(sp)
 772:	1000                	addi	s0,sp,32
 774:	e010                	sd	a2,0(s0)
 776:	e414                	sd	a3,8(s0)
 778:	e818                	sd	a4,16(s0)
 77a:	ec1c                	sd	a5,24(s0)
 77c:	03043023          	sd	a6,32(s0)
 780:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 784:	8622                	mv	a2,s0
 786:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 78a:	d5fff0ef          	jal	4e8 <vprintf>
}
 78e:	60e2                	ld	ra,24(sp)
 790:	6442                	ld	s0,16(sp)
 792:	6161                	addi	sp,sp,80
 794:	8082                	ret

0000000000000796 <printf>:

void
printf(const char *fmt, ...)
{
 796:	711d                	addi	sp,sp,-96
 798:	ec06                	sd	ra,24(sp)
 79a:	e822                	sd	s0,16(sp)
 79c:	1000                	addi	s0,sp,32
 79e:	e40c                	sd	a1,8(s0)
 7a0:	e810                	sd	a2,16(s0)
 7a2:	ec14                	sd	a3,24(s0)
 7a4:	f018                	sd	a4,32(s0)
 7a6:	f41c                	sd	a5,40(s0)
 7a8:	03043823          	sd	a6,48(s0)
 7ac:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7b0:	00840613          	addi	a2,s0,8
 7b4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7b8:	85aa                	mv	a1,a0
 7ba:	4505                	li	a0,1
 7bc:	d2dff0ef          	jal	4e8 <vprintf>
}
 7c0:	60e2                	ld	ra,24(sp)
 7c2:	6442                	ld	s0,16(sp)
 7c4:	6125                	addi	sp,sp,96
 7c6:	8082                	ret

00000000000007c8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7c8:	1141                	addi	sp,sp,-16
 7ca:	e406                	sd	ra,8(sp)
 7cc:	e022                	sd	s0,0(sp)
 7ce:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7d0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d4:	00001797          	auipc	a5,0x1
 7d8:	82c7b783          	ld	a5,-2004(a5) # 1000 <freep>
 7dc:	a02d                	j	806 <free+0x3e>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7de:	4618                	lw	a4,8(a2)
 7e0:	9f2d                	addw	a4,a4,a1
 7e2:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7e6:	6398                	ld	a4,0(a5)
 7e8:	6310                	ld	a2,0(a4)
 7ea:	a83d                	j	828 <free+0x60>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7ec:	ff852703          	lw	a4,-8(a0)
 7f0:	9f31                	addw	a4,a4,a2
 7f2:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7f4:	ff053683          	ld	a3,-16(a0)
 7f8:	a091                	j	83c <free+0x74>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7fa:	6398                	ld	a4,0(a5)
 7fc:	00e7e463          	bltu	a5,a4,804 <free+0x3c>
 800:	00e6ea63          	bltu	a3,a4,814 <free+0x4c>
{
 804:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 806:	fed7fae3          	bgeu	a5,a3,7fa <free+0x32>
 80a:	6398                	ld	a4,0(a5)
 80c:	00e6e463          	bltu	a3,a4,814 <free+0x4c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 810:	fee7eae3          	bltu	a5,a4,804 <free+0x3c>
  if(bp + bp->s.size == p->s.ptr){
 814:	ff852583          	lw	a1,-8(a0)
 818:	6390                	ld	a2,0(a5)
 81a:	02059813          	slli	a6,a1,0x20
 81e:	01c85713          	srli	a4,a6,0x1c
 822:	9736                	add	a4,a4,a3
 824:	fae60de3          	beq	a2,a4,7de <free+0x16>
    bp->s.ptr = p->s.ptr->s.ptr;
 828:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 82c:	4790                	lw	a2,8(a5)
 82e:	02061593          	slli	a1,a2,0x20
 832:	01c5d713          	srli	a4,a1,0x1c
 836:	973e                	add	a4,a4,a5
 838:	fae68ae3          	beq	a3,a4,7ec <free+0x24>
    p->s.ptr = bp->s.ptr;
 83c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 83e:	00000717          	auipc	a4,0x0
 842:	7cf73123          	sd	a5,1986(a4) # 1000 <freep>
}
 846:	60a2                	ld	ra,8(sp)
 848:	6402                	ld	s0,0(sp)
 84a:	0141                	addi	sp,sp,16
 84c:	8082                	ret

000000000000084e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 84e:	7139                	addi	sp,sp,-64
 850:	fc06                	sd	ra,56(sp)
 852:	f822                	sd	s0,48(sp)
 854:	f04a                	sd	s2,32(sp)
 856:	ec4e                	sd	s3,24(sp)
 858:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 85a:	02051993          	slli	s3,a0,0x20
 85e:	0209d993          	srli	s3,s3,0x20
 862:	09bd                	addi	s3,s3,15
 864:	0049d993          	srli	s3,s3,0x4
 868:	2985                	addiw	s3,s3,1
 86a:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 86c:	00000517          	auipc	a0,0x0
 870:	79453503          	ld	a0,1940(a0) # 1000 <freep>
 874:	c905                	beqz	a0,8a4 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 876:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 878:	4798                	lw	a4,8(a5)
 87a:	09377663          	bgeu	a4,s3,906 <malloc+0xb8>
 87e:	f426                	sd	s1,40(sp)
 880:	e852                	sd	s4,16(sp)
 882:	e456                	sd	s5,8(sp)
 884:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 886:	8a4e                	mv	s4,s3
 888:	6705                	lui	a4,0x1
 88a:	00e9f363          	bgeu	s3,a4,890 <malloc+0x42>
 88e:	6a05                	lui	s4,0x1
 890:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 894:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 898:	00000497          	auipc	s1,0x0
 89c:	76848493          	addi	s1,s1,1896 # 1000 <freep>
  if(p == (char*)-1)
 8a0:	5afd                	li	s5,-1
 8a2:	a83d                	j	8e0 <malloc+0x92>
 8a4:	f426                	sd	s1,40(sp)
 8a6:	e852                	sd	s4,16(sp)
 8a8:	e456                	sd	s5,8(sp)
 8aa:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8ac:	00000797          	auipc	a5,0x0
 8b0:	76478793          	addi	a5,a5,1892 # 1010 <base>
 8b4:	00000717          	auipc	a4,0x0
 8b8:	74f73623          	sd	a5,1868(a4) # 1000 <freep>
 8bc:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8be:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8c2:	b7d1                	j	886 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 8c4:	6398                	ld	a4,0(a5)
 8c6:	e118                	sd	a4,0(a0)
 8c8:	a899                	j	91e <malloc+0xd0>
  hp->s.size = nu;
 8ca:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8ce:	0541                	addi	a0,a0,16
 8d0:	ef9ff0ef          	jal	7c8 <free>
  return freep;
 8d4:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 8d6:	c125                	beqz	a0,936 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8da:	4798                	lw	a4,8(a5)
 8dc:	03277163          	bgeu	a4,s2,8fe <malloc+0xb0>
    if(p == freep)
 8e0:	6098                	ld	a4,0(s1)
 8e2:	853e                	mv	a0,a5
 8e4:	fef71ae3          	bne	a4,a5,8d8 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 8e8:	8552                	mv	a0,s4
 8ea:	b03ff0ef          	jal	3ec <sbrk>
  if(p == (char*)-1)
 8ee:	fd551ee3          	bne	a0,s5,8ca <malloc+0x7c>
        return 0;
 8f2:	4501                	li	a0,0
 8f4:	74a2                	ld	s1,40(sp)
 8f6:	6a42                	ld	s4,16(sp)
 8f8:	6aa2                	ld	s5,8(sp)
 8fa:	6b02                	ld	s6,0(sp)
 8fc:	a03d                	j	92a <malloc+0xdc>
 8fe:	74a2                	ld	s1,40(sp)
 900:	6a42                	ld	s4,16(sp)
 902:	6aa2                	ld	s5,8(sp)
 904:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 906:	fae90fe3          	beq	s2,a4,8c4 <malloc+0x76>
        p->s.size -= nunits;
 90a:	4137073b          	subw	a4,a4,s3
 90e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 910:	02071693          	slli	a3,a4,0x20
 914:	01c6d713          	srli	a4,a3,0x1c
 918:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 91a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 91e:	00000717          	auipc	a4,0x0
 922:	6ea73123          	sd	a0,1762(a4) # 1000 <freep>
      return (void*)(p + 1);
 926:	01078513          	addi	a0,a5,16
  }
}
 92a:	70e2                	ld	ra,56(sp)
 92c:	7442                	ld	s0,48(sp)
 92e:	7902                	ld	s2,32(sp)
 930:	69e2                	ld	s3,24(sp)
 932:	6121                	addi	sp,sp,64
 934:	8082                	ret
 936:	74a2                	ld	s1,40(sp)
 938:	6a42                	ld	s4,16(sp)
 93a:	6aa2                	ld	s5,8(sp)
 93c:	6b02                	ld	s6,0(sp)
 93e:	b7f5                	j	92a <malloc+0xdc>
