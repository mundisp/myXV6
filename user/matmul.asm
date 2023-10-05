
user/_matmul:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "../user/user.h"

#define ROWS 1000
#define COLUMNS 1000

int main(int argc, char **argv) {
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	89aa                	mv	s3,a0
  10:	892e                	mv	s2,a1
  double a[ROWS][COLUMNS];
  double b[ROWS][COLUMNS];
  double c[ROWS][COLUMNS];
 
  /* Start timing */
  int start_time = uptime(); 
  12:	00000097          	auipc	ra,0x0
  16:	37a080e7          	jalr	890(ra) # 38c <uptime>
  1a:	84aa                	mv	s1,a0

  iterations = 1;
  if (argc == 2)
  1c:	4789                	li	a5,2
  iterations = 1;
  1e:	4605                	li	a2,1
  if (argc == 2)
  20:	04f98a63          	beq	s3,a5,74 <main+0x74>
  iterations = 1;
  24:	4581                	li	a1,0
int main(int argc, char **argv) {
  26:	3e800693          	li	a3,1000
  2a:	8736                	mv	a4,a3
  2c:	87b6                	mv	a5,a3
    iterations = atoi(argv[1]);

  for (ii = 0; ii < iterations; ii++) {
  /* Initialize */
  for (i=0; i<ROWS; i++) {
    for (j=0; j<COLUMNS; j++) {
  2e:	37fd                	addiw	a5,a5,-1
  30:	fffd                	bnez	a5,2e <main+0x2e>
  for (i=0; i<ROWS; i++) {
  32:	377d                	addiw	a4,a4,-1
  34:	ff65                	bnez	a4,2c <main+0x2c>
  36:	8536                	mv	a0,a3
int main(int argc, char **argv) {
  38:	8736                	mv	a4,a3
  3a:	87b6                	mv	a5,a3
    Multiply Matrices 
    (SQUARE)
  */
  for (i=0; i<ROWS; i++) {
    for (j=0; j<COLUMNS; j++) {
      for (k=0; k<COLUMNS; k++) {
  3c:	37fd                	addiw	a5,a5,-1
  3e:	fffd                	bnez	a5,3c <main+0x3c>
    for (j=0; j<COLUMNS; j++) {
  40:	377d                	addiw	a4,a4,-1
  42:	ff65                	bnez	a4,3a <main+0x3a>
  for (i=0; i<ROWS; i++) {
  44:	357d                	addiw	a0,a0,-1
  46:	f96d                	bnez	a0,38 <main+0x38>
  for (ii = 0; ii < iterations; ii++) {
  48:	2585                	addiw	a1,a1,1
  4a:	fec5c0e3          	blt	a1,a2,2a <main+0x2a>
      printf("\n");
    }
  }
  }
  /* Stop Timing */
  int end_time = uptime();
  4e:	00000097          	auipc	ra,0x0
  52:	33e080e7          	jalr	830(ra) # 38c <uptime>

  /* Report Time */
  printf("Time: %d ticks\n", end_time - start_time);
  56:	409505bb          	subw	a1,a0,s1
  5a:	00000517          	auipc	a0,0x0
  5e:	7be50513          	addi	a0,a0,1982 # 818 <malloc+0xea>
  62:	00000097          	auipc	ra,0x0
  66:	614080e7          	jalr	1556(ra) # 676 <printf>

  exit(0);
  6a:	4501                	li	a0,0
  6c:	00000097          	auipc	ra,0x0
  70:	288080e7          	jalr	648(ra) # 2f4 <exit>
    iterations = atoi(argv[1]);
  74:	00893503          	ld	a0,8(s2)
  78:	00000097          	auipc	ra,0x0
  7c:	182080e7          	jalr	386(ra) # 1fa <atoi>
  80:	862a                	mv	a2,a0
  for (ii = 0; ii < iterations; ii++) {
  82:	fca056e3          	blez	a0,4e <main+0x4e>
  86:	bf79                	j	24 <main+0x24>

0000000000000088 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  88:	1141                	addi	sp,sp,-16
  8a:	e422                	sd	s0,8(sp)
  8c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  8e:	87aa                	mv	a5,a0
  90:	0585                	addi	a1,a1,1
  92:	0785                	addi	a5,a5,1
  94:	fff5c703          	lbu	a4,-1(a1)
  98:	fee78fa3          	sb	a4,-1(a5)
  9c:	fb75                	bnez	a4,90 <strcpy+0x8>
    ;
  return os;
}
  9e:	6422                	ld	s0,8(sp)
  a0:	0141                	addi	sp,sp,16
  a2:	8082                	ret

00000000000000a4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  a4:	1141                	addi	sp,sp,-16
  a6:	e422                	sd	s0,8(sp)
  a8:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  aa:	00054783          	lbu	a5,0(a0)
  ae:	cb91                	beqz	a5,c2 <strcmp+0x1e>
  b0:	0005c703          	lbu	a4,0(a1)
  b4:	00f71763          	bne	a4,a5,c2 <strcmp+0x1e>
    p++, q++;
  b8:	0505                	addi	a0,a0,1
  ba:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  bc:	00054783          	lbu	a5,0(a0)
  c0:	fbe5                	bnez	a5,b0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  c2:	0005c503          	lbu	a0,0(a1)
}
  c6:	40a7853b          	subw	a0,a5,a0
  ca:	6422                	ld	s0,8(sp)
  cc:	0141                	addi	sp,sp,16
  ce:	8082                	ret

00000000000000d0 <strlen>:

uint
strlen(const char *s)
{
  d0:	1141                	addi	sp,sp,-16
  d2:	e422                	sd	s0,8(sp)
  d4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  d6:	00054783          	lbu	a5,0(a0)
  da:	cf91                	beqz	a5,f6 <strlen+0x26>
  dc:	0505                	addi	a0,a0,1
  de:	87aa                	mv	a5,a0
  e0:	4685                	li	a3,1
  e2:	9e89                	subw	a3,a3,a0
  e4:	00f6853b          	addw	a0,a3,a5
  e8:	0785                	addi	a5,a5,1
  ea:	fff7c703          	lbu	a4,-1(a5)
  ee:	fb7d                	bnez	a4,e4 <strlen+0x14>
    ;
  return n;
}
  f0:	6422                	ld	s0,8(sp)
  f2:	0141                	addi	sp,sp,16
  f4:	8082                	ret
  for(n = 0; s[n]; n++)
  f6:	4501                	li	a0,0
  f8:	bfe5                	j	f0 <strlen+0x20>

00000000000000fa <memset>:

void*
memset(void *dst, int c, uint n)
{
  fa:	1141                	addi	sp,sp,-16
  fc:	e422                	sd	s0,8(sp)
  fe:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 100:	ca19                	beqz	a2,116 <memset+0x1c>
 102:	87aa                	mv	a5,a0
 104:	1602                	slli	a2,a2,0x20
 106:	9201                	srli	a2,a2,0x20
 108:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 10c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 110:	0785                	addi	a5,a5,1
 112:	fee79de3          	bne	a5,a4,10c <memset+0x12>
  }
  return dst;
}
 116:	6422                	ld	s0,8(sp)
 118:	0141                	addi	sp,sp,16
 11a:	8082                	ret

000000000000011c <strchr>:

char*
strchr(const char *s, char c)
{
 11c:	1141                	addi	sp,sp,-16
 11e:	e422                	sd	s0,8(sp)
 120:	0800                	addi	s0,sp,16
  for(; *s; s++)
 122:	00054783          	lbu	a5,0(a0)
 126:	cb99                	beqz	a5,13c <strchr+0x20>
    if(*s == c)
 128:	00f58763          	beq	a1,a5,136 <strchr+0x1a>
  for(; *s; s++)
 12c:	0505                	addi	a0,a0,1
 12e:	00054783          	lbu	a5,0(a0)
 132:	fbfd                	bnez	a5,128 <strchr+0xc>
      return (char*)s;
  return 0;
 134:	4501                	li	a0,0
}
 136:	6422                	ld	s0,8(sp)
 138:	0141                	addi	sp,sp,16
 13a:	8082                	ret
  return 0;
 13c:	4501                	li	a0,0
 13e:	bfe5                	j	136 <strchr+0x1a>

0000000000000140 <gets>:

char*
gets(char *buf, int max)
{
 140:	711d                	addi	sp,sp,-96
 142:	ec86                	sd	ra,88(sp)
 144:	e8a2                	sd	s0,80(sp)
 146:	e4a6                	sd	s1,72(sp)
 148:	e0ca                	sd	s2,64(sp)
 14a:	fc4e                	sd	s3,56(sp)
 14c:	f852                	sd	s4,48(sp)
 14e:	f456                	sd	s5,40(sp)
 150:	f05a                	sd	s6,32(sp)
 152:	ec5e                	sd	s7,24(sp)
 154:	1080                	addi	s0,sp,96
 156:	8baa                	mv	s7,a0
 158:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 15a:	892a                	mv	s2,a0
 15c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 15e:	4aa9                	li	s5,10
 160:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 162:	89a6                	mv	s3,s1
 164:	2485                	addiw	s1,s1,1
 166:	0344d863          	bge	s1,s4,196 <gets+0x56>
    cc = read(0, &c, 1);
 16a:	4605                	li	a2,1
 16c:	faf40593          	addi	a1,s0,-81
 170:	4501                	li	a0,0
 172:	00000097          	auipc	ra,0x0
 176:	19a080e7          	jalr	410(ra) # 30c <read>
    if(cc < 1)
 17a:	00a05e63          	blez	a0,196 <gets+0x56>
    buf[i++] = c;
 17e:	faf44783          	lbu	a5,-81(s0)
 182:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 186:	01578763          	beq	a5,s5,194 <gets+0x54>
 18a:	0905                	addi	s2,s2,1
 18c:	fd679be3          	bne	a5,s6,162 <gets+0x22>
  for(i=0; i+1 < max; ){
 190:	89a6                	mv	s3,s1
 192:	a011                	j	196 <gets+0x56>
 194:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 196:	99de                	add	s3,s3,s7
 198:	00098023          	sb	zero,0(s3)
  return buf;
}
 19c:	855e                	mv	a0,s7
 19e:	60e6                	ld	ra,88(sp)
 1a0:	6446                	ld	s0,80(sp)
 1a2:	64a6                	ld	s1,72(sp)
 1a4:	6906                	ld	s2,64(sp)
 1a6:	79e2                	ld	s3,56(sp)
 1a8:	7a42                	ld	s4,48(sp)
 1aa:	7aa2                	ld	s5,40(sp)
 1ac:	7b02                	ld	s6,32(sp)
 1ae:	6be2                	ld	s7,24(sp)
 1b0:	6125                	addi	sp,sp,96
 1b2:	8082                	ret

00000000000001b4 <stat>:

int
stat(const char *n, struct stat *st)
{
 1b4:	1101                	addi	sp,sp,-32
 1b6:	ec06                	sd	ra,24(sp)
 1b8:	e822                	sd	s0,16(sp)
 1ba:	e426                	sd	s1,8(sp)
 1bc:	e04a                	sd	s2,0(sp)
 1be:	1000                	addi	s0,sp,32
 1c0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1c2:	4581                	li	a1,0
 1c4:	00000097          	auipc	ra,0x0
 1c8:	170080e7          	jalr	368(ra) # 334 <open>
  if(fd < 0)
 1cc:	02054563          	bltz	a0,1f6 <stat+0x42>
 1d0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1d2:	85ca                	mv	a1,s2
 1d4:	00000097          	auipc	ra,0x0
 1d8:	178080e7          	jalr	376(ra) # 34c <fstat>
 1dc:	892a                	mv	s2,a0
  close(fd);
 1de:	8526                	mv	a0,s1
 1e0:	00000097          	auipc	ra,0x0
 1e4:	13c080e7          	jalr	316(ra) # 31c <close>
  return r;
}
 1e8:	854a                	mv	a0,s2
 1ea:	60e2                	ld	ra,24(sp)
 1ec:	6442                	ld	s0,16(sp)
 1ee:	64a2                	ld	s1,8(sp)
 1f0:	6902                	ld	s2,0(sp)
 1f2:	6105                	addi	sp,sp,32
 1f4:	8082                	ret
    return -1;
 1f6:	597d                	li	s2,-1
 1f8:	bfc5                	j	1e8 <stat+0x34>

00000000000001fa <atoi>:

int
atoi(const char *s)
{
 1fa:	1141                	addi	sp,sp,-16
 1fc:	e422                	sd	s0,8(sp)
 1fe:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 200:	00054683          	lbu	a3,0(a0)
 204:	fd06879b          	addiw	a5,a3,-48
 208:	0ff7f793          	zext.b	a5,a5
 20c:	4625                	li	a2,9
 20e:	02f66863          	bltu	a2,a5,23e <atoi+0x44>
 212:	872a                	mv	a4,a0
  n = 0;
 214:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 216:	0705                	addi	a4,a4,1
 218:	0025179b          	slliw	a5,a0,0x2
 21c:	9fa9                	addw	a5,a5,a0
 21e:	0017979b          	slliw	a5,a5,0x1
 222:	9fb5                	addw	a5,a5,a3
 224:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 228:	00074683          	lbu	a3,0(a4)
 22c:	fd06879b          	addiw	a5,a3,-48
 230:	0ff7f793          	zext.b	a5,a5
 234:	fef671e3          	bgeu	a2,a5,216 <atoi+0x1c>
  return n;
}
 238:	6422                	ld	s0,8(sp)
 23a:	0141                	addi	sp,sp,16
 23c:	8082                	ret
  n = 0;
 23e:	4501                	li	a0,0
 240:	bfe5                	j	238 <atoi+0x3e>

0000000000000242 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 242:	1141                	addi	sp,sp,-16
 244:	e422                	sd	s0,8(sp)
 246:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 248:	02b57463          	bgeu	a0,a1,270 <memmove+0x2e>
    while(n-- > 0)
 24c:	00c05f63          	blez	a2,26a <memmove+0x28>
 250:	1602                	slli	a2,a2,0x20
 252:	9201                	srli	a2,a2,0x20
 254:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 258:	872a                	mv	a4,a0
      *dst++ = *src++;
 25a:	0585                	addi	a1,a1,1
 25c:	0705                	addi	a4,a4,1
 25e:	fff5c683          	lbu	a3,-1(a1)
 262:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 266:	fee79ae3          	bne	a5,a4,25a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 26a:	6422                	ld	s0,8(sp)
 26c:	0141                	addi	sp,sp,16
 26e:	8082                	ret
    dst += n;
 270:	00c50733          	add	a4,a0,a2
    src += n;
 274:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 276:	fec05ae3          	blez	a2,26a <memmove+0x28>
 27a:	fff6079b          	addiw	a5,a2,-1
 27e:	1782                	slli	a5,a5,0x20
 280:	9381                	srli	a5,a5,0x20
 282:	fff7c793          	not	a5,a5
 286:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 288:	15fd                	addi	a1,a1,-1
 28a:	177d                	addi	a4,a4,-1
 28c:	0005c683          	lbu	a3,0(a1)
 290:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 294:	fee79ae3          	bne	a5,a4,288 <memmove+0x46>
 298:	bfc9                	j	26a <memmove+0x28>

000000000000029a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 29a:	1141                	addi	sp,sp,-16
 29c:	e422                	sd	s0,8(sp)
 29e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2a0:	ca05                	beqz	a2,2d0 <memcmp+0x36>
 2a2:	fff6069b          	addiw	a3,a2,-1
 2a6:	1682                	slli	a3,a3,0x20
 2a8:	9281                	srli	a3,a3,0x20
 2aa:	0685                	addi	a3,a3,1
 2ac:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2ae:	00054783          	lbu	a5,0(a0)
 2b2:	0005c703          	lbu	a4,0(a1)
 2b6:	00e79863          	bne	a5,a4,2c6 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2ba:	0505                	addi	a0,a0,1
    p2++;
 2bc:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2be:	fed518e3          	bne	a0,a3,2ae <memcmp+0x14>
  }
  return 0;
 2c2:	4501                	li	a0,0
 2c4:	a019                	j	2ca <memcmp+0x30>
      return *p1 - *p2;
 2c6:	40e7853b          	subw	a0,a5,a4
}
 2ca:	6422                	ld	s0,8(sp)
 2cc:	0141                	addi	sp,sp,16
 2ce:	8082                	ret
  return 0;
 2d0:	4501                	li	a0,0
 2d2:	bfe5                	j	2ca <memcmp+0x30>

00000000000002d4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2d4:	1141                	addi	sp,sp,-16
 2d6:	e406                	sd	ra,8(sp)
 2d8:	e022                	sd	s0,0(sp)
 2da:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2dc:	00000097          	auipc	ra,0x0
 2e0:	f66080e7          	jalr	-154(ra) # 242 <memmove>
}
 2e4:	60a2                	ld	ra,8(sp)
 2e6:	6402                	ld	s0,0(sp)
 2e8:	0141                	addi	sp,sp,16
 2ea:	8082                	ret

00000000000002ec <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2ec:	4885                	li	a7,1
 ecall
 2ee:	00000073          	ecall
 ret
 2f2:	8082                	ret

00000000000002f4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2f4:	4889                	li	a7,2
 ecall
 2f6:	00000073          	ecall
 ret
 2fa:	8082                	ret

00000000000002fc <wait>:
.global wait
wait:
 li a7, SYS_wait
 2fc:	488d                	li	a7,3
 ecall
 2fe:	00000073          	ecall
 ret
 302:	8082                	ret

0000000000000304 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 304:	4891                	li	a7,4
 ecall
 306:	00000073          	ecall
 ret
 30a:	8082                	ret

000000000000030c <read>:
.global read
read:
 li a7, SYS_read
 30c:	4895                	li	a7,5
 ecall
 30e:	00000073          	ecall
 ret
 312:	8082                	ret

0000000000000314 <write>:
.global write
write:
 li a7, SYS_write
 314:	48c1                	li	a7,16
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <close>:
.global close
close:
 li a7, SYS_close
 31c:	48d5                	li	a7,21
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <kill>:
.global kill
kill:
 li a7, SYS_kill
 324:	4899                	li	a7,6
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <exec>:
.global exec
exec:
 li a7, SYS_exec
 32c:	489d                	li	a7,7
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <open>:
.global open
open:
 li a7, SYS_open
 334:	48bd                	li	a7,15
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 33c:	48c5                	li	a7,17
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 344:	48c9                	li	a7,18
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 34c:	48a1                	li	a7,8
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <link>:
.global link
link:
 li a7, SYS_link
 354:	48cd                	li	a7,19
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 35c:	48d1                	li	a7,20
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 364:	48a5                	li	a7,9
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <dup>:
.global dup
dup:
 li a7, SYS_dup
 36c:	48a9                	li	a7,10
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 374:	48ad                	li	a7,11
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 37c:	48b1                	li	a7,12
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 384:	48b5                	li	a7,13
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 38c:	48b9                	li	a7,14
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <wait2>:
.global wait2
wait2:
 li a7, SYS_wait2
 394:	48d9                	li	a7,22
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 39c:	1101                	addi	sp,sp,-32
 39e:	ec06                	sd	ra,24(sp)
 3a0:	e822                	sd	s0,16(sp)
 3a2:	1000                	addi	s0,sp,32
 3a4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3a8:	4605                	li	a2,1
 3aa:	fef40593          	addi	a1,s0,-17
 3ae:	00000097          	auipc	ra,0x0
 3b2:	f66080e7          	jalr	-154(ra) # 314 <write>
}
 3b6:	60e2                	ld	ra,24(sp)
 3b8:	6442                	ld	s0,16(sp)
 3ba:	6105                	addi	sp,sp,32
 3bc:	8082                	ret

00000000000003be <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3be:	7139                	addi	sp,sp,-64
 3c0:	fc06                	sd	ra,56(sp)
 3c2:	f822                	sd	s0,48(sp)
 3c4:	f426                	sd	s1,40(sp)
 3c6:	f04a                	sd	s2,32(sp)
 3c8:	ec4e                	sd	s3,24(sp)
 3ca:	0080                	addi	s0,sp,64
 3cc:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3ce:	c299                	beqz	a3,3d4 <printint+0x16>
 3d0:	0805c963          	bltz	a1,462 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3d4:	2581                	sext.w	a1,a1
  neg = 0;
 3d6:	4881                	li	a7,0
 3d8:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3dc:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3de:	2601                	sext.w	a2,a2
 3e0:	00000517          	auipc	a0,0x0
 3e4:	4a850513          	addi	a0,a0,1192 # 888 <digits>
 3e8:	883a                	mv	a6,a4
 3ea:	2705                	addiw	a4,a4,1
 3ec:	02c5f7bb          	remuw	a5,a1,a2
 3f0:	1782                	slli	a5,a5,0x20
 3f2:	9381                	srli	a5,a5,0x20
 3f4:	97aa                	add	a5,a5,a0
 3f6:	0007c783          	lbu	a5,0(a5)
 3fa:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3fe:	0005879b          	sext.w	a5,a1
 402:	02c5d5bb          	divuw	a1,a1,a2
 406:	0685                	addi	a3,a3,1
 408:	fec7f0e3          	bgeu	a5,a2,3e8 <printint+0x2a>
  if(neg)
 40c:	00088c63          	beqz	a7,424 <printint+0x66>
    buf[i++] = '-';
 410:	fd070793          	addi	a5,a4,-48
 414:	00878733          	add	a4,a5,s0
 418:	02d00793          	li	a5,45
 41c:	fef70823          	sb	a5,-16(a4)
 420:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 424:	02e05863          	blez	a4,454 <printint+0x96>
 428:	fc040793          	addi	a5,s0,-64
 42c:	00e78933          	add	s2,a5,a4
 430:	fff78993          	addi	s3,a5,-1
 434:	99ba                	add	s3,s3,a4
 436:	377d                	addiw	a4,a4,-1
 438:	1702                	slli	a4,a4,0x20
 43a:	9301                	srli	a4,a4,0x20
 43c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 440:	fff94583          	lbu	a1,-1(s2)
 444:	8526                	mv	a0,s1
 446:	00000097          	auipc	ra,0x0
 44a:	f56080e7          	jalr	-170(ra) # 39c <putc>
  while(--i >= 0)
 44e:	197d                	addi	s2,s2,-1
 450:	ff3918e3          	bne	s2,s3,440 <printint+0x82>
}
 454:	70e2                	ld	ra,56(sp)
 456:	7442                	ld	s0,48(sp)
 458:	74a2                	ld	s1,40(sp)
 45a:	7902                	ld	s2,32(sp)
 45c:	69e2                	ld	s3,24(sp)
 45e:	6121                	addi	sp,sp,64
 460:	8082                	ret
    x = -xx;
 462:	40b005bb          	negw	a1,a1
    neg = 1;
 466:	4885                	li	a7,1
    x = -xx;
 468:	bf85                	j	3d8 <printint+0x1a>

000000000000046a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 46a:	7119                	addi	sp,sp,-128
 46c:	fc86                	sd	ra,120(sp)
 46e:	f8a2                	sd	s0,112(sp)
 470:	f4a6                	sd	s1,104(sp)
 472:	f0ca                	sd	s2,96(sp)
 474:	ecce                	sd	s3,88(sp)
 476:	e8d2                	sd	s4,80(sp)
 478:	e4d6                	sd	s5,72(sp)
 47a:	e0da                	sd	s6,64(sp)
 47c:	fc5e                	sd	s7,56(sp)
 47e:	f862                	sd	s8,48(sp)
 480:	f466                	sd	s9,40(sp)
 482:	f06a                	sd	s10,32(sp)
 484:	ec6e                	sd	s11,24(sp)
 486:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 488:	0005c903          	lbu	s2,0(a1)
 48c:	18090f63          	beqz	s2,62a <vprintf+0x1c0>
 490:	8aaa                	mv	s5,a0
 492:	8b32                	mv	s6,a2
 494:	00158493          	addi	s1,a1,1
  state = 0;
 498:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 49a:	02500a13          	li	s4,37
 49e:	4c55                	li	s8,21
 4a0:	00000c97          	auipc	s9,0x0
 4a4:	390c8c93          	addi	s9,s9,912 # 830 <malloc+0x102>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 4a8:	02800d93          	li	s11,40
  putc(fd, 'x');
 4ac:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4ae:	00000b97          	auipc	s7,0x0
 4b2:	3dab8b93          	addi	s7,s7,986 # 888 <digits>
 4b6:	a839                	j	4d4 <vprintf+0x6a>
        putc(fd, c);
 4b8:	85ca                	mv	a1,s2
 4ba:	8556                	mv	a0,s5
 4bc:	00000097          	auipc	ra,0x0
 4c0:	ee0080e7          	jalr	-288(ra) # 39c <putc>
 4c4:	a019                	j	4ca <vprintf+0x60>
    } else if(state == '%'){
 4c6:	01498d63          	beq	s3,s4,4e0 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 4ca:	0485                	addi	s1,s1,1
 4cc:	fff4c903          	lbu	s2,-1(s1)
 4d0:	14090d63          	beqz	s2,62a <vprintf+0x1c0>
    if(state == 0){
 4d4:	fe0999e3          	bnez	s3,4c6 <vprintf+0x5c>
      if(c == '%'){
 4d8:	ff4910e3          	bne	s2,s4,4b8 <vprintf+0x4e>
        state = '%';
 4dc:	89d2                	mv	s3,s4
 4de:	b7f5                	j	4ca <vprintf+0x60>
      if(c == 'd'){
 4e0:	11490c63          	beq	s2,s4,5f8 <vprintf+0x18e>
 4e4:	f9d9079b          	addiw	a5,s2,-99
 4e8:	0ff7f793          	zext.b	a5,a5
 4ec:	10fc6e63          	bltu	s8,a5,608 <vprintf+0x19e>
 4f0:	f9d9079b          	addiw	a5,s2,-99
 4f4:	0ff7f713          	zext.b	a4,a5
 4f8:	10ec6863          	bltu	s8,a4,608 <vprintf+0x19e>
 4fc:	00271793          	slli	a5,a4,0x2
 500:	97e6                	add	a5,a5,s9
 502:	439c                	lw	a5,0(a5)
 504:	97e6                	add	a5,a5,s9
 506:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 508:	008b0913          	addi	s2,s6,8
 50c:	4685                	li	a3,1
 50e:	4629                	li	a2,10
 510:	000b2583          	lw	a1,0(s6)
 514:	8556                	mv	a0,s5
 516:	00000097          	auipc	ra,0x0
 51a:	ea8080e7          	jalr	-344(ra) # 3be <printint>
 51e:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 520:	4981                	li	s3,0
 522:	b765                	j	4ca <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 524:	008b0913          	addi	s2,s6,8
 528:	4681                	li	a3,0
 52a:	4629                	li	a2,10
 52c:	000b2583          	lw	a1,0(s6)
 530:	8556                	mv	a0,s5
 532:	00000097          	auipc	ra,0x0
 536:	e8c080e7          	jalr	-372(ra) # 3be <printint>
 53a:	8b4a                	mv	s6,s2
      state = 0;
 53c:	4981                	li	s3,0
 53e:	b771                	j	4ca <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 540:	008b0913          	addi	s2,s6,8
 544:	4681                	li	a3,0
 546:	866a                	mv	a2,s10
 548:	000b2583          	lw	a1,0(s6)
 54c:	8556                	mv	a0,s5
 54e:	00000097          	auipc	ra,0x0
 552:	e70080e7          	jalr	-400(ra) # 3be <printint>
 556:	8b4a                	mv	s6,s2
      state = 0;
 558:	4981                	li	s3,0
 55a:	bf85                	j	4ca <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 55c:	008b0793          	addi	a5,s6,8
 560:	f8f43423          	sd	a5,-120(s0)
 564:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 568:	03000593          	li	a1,48
 56c:	8556                	mv	a0,s5
 56e:	00000097          	auipc	ra,0x0
 572:	e2e080e7          	jalr	-466(ra) # 39c <putc>
  putc(fd, 'x');
 576:	07800593          	li	a1,120
 57a:	8556                	mv	a0,s5
 57c:	00000097          	auipc	ra,0x0
 580:	e20080e7          	jalr	-480(ra) # 39c <putc>
 584:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 586:	03c9d793          	srli	a5,s3,0x3c
 58a:	97de                	add	a5,a5,s7
 58c:	0007c583          	lbu	a1,0(a5)
 590:	8556                	mv	a0,s5
 592:	00000097          	auipc	ra,0x0
 596:	e0a080e7          	jalr	-502(ra) # 39c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 59a:	0992                	slli	s3,s3,0x4
 59c:	397d                	addiw	s2,s2,-1
 59e:	fe0914e3          	bnez	s2,586 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 5a2:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 5a6:	4981                	li	s3,0
 5a8:	b70d                	j	4ca <vprintf+0x60>
        s = va_arg(ap, char*);
 5aa:	008b0913          	addi	s2,s6,8
 5ae:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 5b2:	02098163          	beqz	s3,5d4 <vprintf+0x16a>
        while(*s != 0){
 5b6:	0009c583          	lbu	a1,0(s3)
 5ba:	c5ad                	beqz	a1,624 <vprintf+0x1ba>
          putc(fd, *s);
 5bc:	8556                	mv	a0,s5
 5be:	00000097          	auipc	ra,0x0
 5c2:	dde080e7          	jalr	-546(ra) # 39c <putc>
          s++;
 5c6:	0985                	addi	s3,s3,1
        while(*s != 0){
 5c8:	0009c583          	lbu	a1,0(s3)
 5cc:	f9e5                	bnez	a1,5bc <vprintf+0x152>
        s = va_arg(ap, char*);
 5ce:	8b4a                	mv	s6,s2
      state = 0;
 5d0:	4981                	li	s3,0
 5d2:	bde5                	j	4ca <vprintf+0x60>
          s = "(null)";
 5d4:	00000997          	auipc	s3,0x0
 5d8:	25498993          	addi	s3,s3,596 # 828 <malloc+0xfa>
        while(*s != 0){
 5dc:	85ee                	mv	a1,s11
 5de:	bff9                	j	5bc <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 5e0:	008b0913          	addi	s2,s6,8
 5e4:	000b4583          	lbu	a1,0(s6)
 5e8:	8556                	mv	a0,s5
 5ea:	00000097          	auipc	ra,0x0
 5ee:	db2080e7          	jalr	-590(ra) # 39c <putc>
 5f2:	8b4a                	mv	s6,s2
      state = 0;
 5f4:	4981                	li	s3,0
 5f6:	bdd1                	j	4ca <vprintf+0x60>
        putc(fd, c);
 5f8:	85d2                	mv	a1,s4
 5fa:	8556                	mv	a0,s5
 5fc:	00000097          	auipc	ra,0x0
 600:	da0080e7          	jalr	-608(ra) # 39c <putc>
      state = 0;
 604:	4981                	li	s3,0
 606:	b5d1                	j	4ca <vprintf+0x60>
        putc(fd, '%');
 608:	85d2                	mv	a1,s4
 60a:	8556                	mv	a0,s5
 60c:	00000097          	auipc	ra,0x0
 610:	d90080e7          	jalr	-624(ra) # 39c <putc>
        putc(fd, c);
 614:	85ca                	mv	a1,s2
 616:	8556                	mv	a0,s5
 618:	00000097          	auipc	ra,0x0
 61c:	d84080e7          	jalr	-636(ra) # 39c <putc>
      state = 0;
 620:	4981                	li	s3,0
 622:	b565                	j	4ca <vprintf+0x60>
        s = va_arg(ap, char*);
 624:	8b4a                	mv	s6,s2
      state = 0;
 626:	4981                	li	s3,0
 628:	b54d                	j	4ca <vprintf+0x60>
    }
  }
}
 62a:	70e6                	ld	ra,120(sp)
 62c:	7446                	ld	s0,112(sp)
 62e:	74a6                	ld	s1,104(sp)
 630:	7906                	ld	s2,96(sp)
 632:	69e6                	ld	s3,88(sp)
 634:	6a46                	ld	s4,80(sp)
 636:	6aa6                	ld	s5,72(sp)
 638:	6b06                	ld	s6,64(sp)
 63a:	7be2                	ld	s7,56(sp)
 63c:	7c42                	ld	s8,48(sp)
 63e:	7ca2                	ld	s9,40(sp)
 640:	7d02                	ld	s10,32(sp)
 642:	6de2                	ld	s11,24(sp)
 644:	6109                	addi	sp,sp,128
 646:	8082                	ret

0000000000000648 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 648:	715d                	addi	sp,sp,-80
 64a:	ec06                	sd	ra,24(sp)
 64c:	e822                	sd	s0,16(sp)
 64e:	1000                	addi	s0,sp,32
 650:	e010                	sd	a2,0(s0)
 652:	e414                	sd	a3,8(s0)
 654:	e818                	sd	a4,16(s0)
 656:	ec1c                	sd	a5,24(s0)
 658:	03043023          	sd	a6,32(s0)
 65c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 660:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 664:	8622                	mv	a2,s0
 666:	00000097          	auipc	ra,0x0
 66a:	e04080e7          	jalr	-508(ra) # 46a <vprintf>
}
 66e:	60e2                	ld	ra,24(sp)
 670:	6442                	ld	s0,16(sp)
 672:	6161                	addi	sp,sp,80
 674:	8082                	ret

0000000000000676 <printf>:

void
printf(const char *fmt, ...)
{
 676:	711d                	addi	sp,sp,-96
 678:	ec06                	sd	ra,24(sp)
 67a:	e822                	sd	s0,16(sp)
 67c:	1000                	addi	s0,sp,32
 67e:	e40c                	sd	a1,8(s0)
 680:	e810                	sd	a2,16(s0)
 682:	ec14                	sd	a3,24(s0)
 684:	f018                	sd	a4,32(s0)
 686:	f41c                	sd	a5,40(s0)
 688:	03043823          	sd	a6,48(s0)
 68c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 690:	00840613          	addi	a2,s0,8
 694:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 698:	85aa                	mv	a1,a0
 69a:	4505                	li	a0,1
 69c:	00000097          	auipc	ra,0x0
 6a0:	dce080e7          	jalr	-562(ra) # 46a <vprintf>
}
 6a4:	60e2                	ld	ra,24(sp)
 6a6:	6442                	ld	s0,16(sp)
 6a8:	6125                	addi	sp,sp,96
 6aa:	8082                	ret

00000000000006ac <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6ac:	1141                	addi	sp,sp,-16
 6ae:	e422                	sd	s0,8(sp)
 6b0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6b2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6b6:	00000797          	auipc	a5,0x0
 6ba:	1ea7b783          	ld	a5,490(a5) # 8a0 <freep>
 6be:	a02d                	j	6e8 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6c0:	4618                	lw	a4,8(a2)
 6c2:	9f2d                	addw	a4,a4,a1
 6c4:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6c8:	6398                	ld	a4,0(a5)
 6ca:	6310                	ld	a2,0(a4)
 6cc:	a83d                	j	70a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6ce:	ff852703          	lw	a4,-8(a0)
 6d2:	9f31                	addw	a4,a4,a2
 6d4:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6d6:	ff053683          	ld	a3,-16(a0)
 6da:	a091                	j	71e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6dc:	6398                	ld	a4,0(a5)
 6de:	00e7e463          	bltu	a5,a4,6e6 <free+0x3a>
 6e2:	00e6ea63          	bltu	a3,a4,6f6 <free+0x4a>
{
 6e6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6e8:	fed7fae3          	bgeu	a5,a3,6dc <free+0x30>
 6ec:	6398                	ld	a4,0(a5)
 6ee:	00e6e463          	bltu	a3,a4,6f6 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6f2:	fee7eae3          	bltu	a5,a4,6e6 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 6f6:	ff852583          	lw	a1,-8(a0)
 6fa:	6390                	ld	a2,0(a5)
 6fc:	02059813          	slli	a6,a1,0x20
 700:	01c85713          	srli	a4,a6,0x1c
 704:	9736                	add	a4,a4,a3
 706:	fae60de3          	beq	a2,a4,6c0 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 70a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 70e:	4790                	lw	a2,8(a5)
 710:	02061593          	slli	a1,a2,0x20
 714:	01c5d713          	srli	a4,a1,0x1c
 718:	973e                	add	a4,a4,a5
 71a:	fae68ae3          	beq	a3,a4,6ce <free+0x22>
    p->s.ptr = bp->s.ptr;
 71e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 720:	00000717          	auipc	a4,0x0
 724:	18f73023          	sd	a5,384(a4) # 8a0 <freep>
}
 728:	6422                	ld	s0,8(sp)
 72a:	0141                	addi	sp,sp,16
 72c:	8082                	ret

000000000000072e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 72e:	7139                	addi	sp,sp,-64
 730:	fc06                	sd	ra,56(sp)
 732:	f822                	sd	s0,48(sp)
 734:	f426                	sd	s1,40(sp)
 736:	f04a                	sd	s2,32(sp)
 738:	ec4e                	sd	s3,24(sp)
 73a:	e852                	sd	s4,16(sp)
 73c:	e456                	sd	s5,8(sp)
 73e:	e05a                	sd	s6,0(sp)
 740:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 742:	02051493          	slli	s1,a0,0x20
 746:	9081                	srli	s1,s1,0x20
 748:	04bd                	addi	s1,s1,15
 74a:	8091                	srli	s1,s1,0x4
 74c:	0014899b          	addiw	s3,s1,1
 750:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 752:	00000517          	auipc	a0,0x0
 756:	14e53503          	ld	a0,334(a0) # 8a0 <freep>
 75a:	c515                	beqz	a0,786 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 75c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 75e:	4798                	lw	a4,8(a5)
 760:	02977f63          	bgeu	a4,s1,79e <malloc+0x70>
 764:	8a4e                	mv	s4,s3
 766:	0009871b          	sext.w	a4,s3
 76a:	6685                	lui	a3,0x1
 76c:	00d77363          	bgeu	a4,a3,772 <malloc+0x44>
 770:	6a05                	lui	s4,0x1
 772:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 776:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 77a:	00000917          	auipc	s2,0x0
 77e:	12690913          	addi	s2,s2,294 # 8a0 <freep>
  if(p == (char*)-1)
 782:	5afd                	li	s5,-1
 784:	a895                	j	7f8 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 786:	00000797          	auipc	a5,0x0
 78a:	12278793          	addi	a5,a5,290 # 8a8 <base>
 78e:	00000717          	auipc	a4,0x0
 792:	10f73923          	sd	a5,274(a4) # 8a0 <freep>
 796:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 798:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 79c:	b7e1                	j	764 <malloc+0x36>
      if(p->s.size == nunits)
 79e:	02e48c63          	beq	s1,a4,7d6 <malloc+0xa8>
        p->s.size -= nunits;
 7a2:	4137073b          	subw	a4,a4,s3
 7a6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7a8:	02071693          	slli	a3,a4,0x20
 7ac:	01c6d713          	srli	a4,a3,0x1c
 7b0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7b2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7b6:	00000717          	auipc	a4,0x0
 7ba:	0ea73523          	sd	a0,234(a4) # 8a0 <freep>
      return (void*)(p + 1);
 7be:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7c2:	70e2                	ld	ra,56(sp)
 7c4:	7442                	ld	s0,48(sp)
 7c6:	74a2                	ld	s1,40(sp)
 7c8:	7902                	ld	s2,32(sp)
 7ca:	69e2                	ld	s3,24(sp)
 7cc:	6a42                	ld	s4,16(sp)
 7ce:	6aa2                	ld	s5,8(sp)
 7d0:	6b02                	ld	s6,0(sp)
 7d2:	6121                	addi	sp,sp,64
 7d4:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7d6:	6398                	ld	a4,0(a5)
 7d8:	e118                	sd	a4,0(a0)
 7da:	bff1                	j	7b6 <malloc+0x88>
  hp->s.size = nu;
 7dc:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7e0:	0541                	addi	a0,a0,16
 7e2:	00000097          	auipc	ra,0x0
 7e6:	eca080e7          	jalr	-310(ra) # 6ac <free>
  return freep;
 7ea:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7ee:	d971                	beqz	a0,7c2 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7f0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7f2:	4798                	lw	a4,8(a5)
 7f4:	fa9775e3          	bgeu	a4,s1,79e <malloc+0x70>
    if(p == freep)
 7f8:	00093703          	ld	a4,0(s2)
 7fc:	853e                	mv	a0,a5
 7fe:	fef719e3          	bne	a4,a5,7f0 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 802:	8552                	mv	a0,s4
 804:	00000097          	auipc	ra,0x0
 808:	b78080e7          	jalr	-1160(ra) # 37c <sbrk>
  if(p == (char*)-1)
 80c:	fd5518e3          	bne	a0,s5,7dc <malloc+0xae>
        return 0;
 810:	4501                	li	a0,0
 812:	bf45                	j	7c2 <malloc+0x94>
