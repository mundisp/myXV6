
user/_time1:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user.h"
#include "kernel/stat.h"
#include "kernel/pstat.h"

main(int argCount, char **arg){
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	1800                	addi	s0,sp,48
    
    if (argCount < 2){
   c:	4785                	li	a5,1
   e:	04a7dc63          	bge	a5,a0,66 <main+0x66>
  12:	84ae                	mv	s1,a1
        printf("Missing arguments\n");
        exit(1);
    }
    
    uint start = uptime();
  14:	00000097          	auipc	ra,0x0
  18:	3c4080e7          	jalr	964(ra) # 3d8 <uptime>
  1c:	892a                	mv	s2,a0
    int pid = fork();
  1e:	00000097          	auipc	ra,0x0
  22:	31a080e7          	jalr	794(ra) # 338 <fork>

    if (pid == 0){
  26:	cd29                	beqz	a0,80 <main+0x80>
        exec(arg[1], arg+1);
        printf("Child process executing\n");       
        exit(1);
        
    }
    else if (pid == -1){
  28:	57fd                	li	a5,-1
  2a:	06f50f63          	beq	a0,a5,a8 <main+0xa8>
        printf("Error: no child process created\n");
        exit(1);
    }

    int status;
    wait(&status);
  2e:	fdc40513          	addi	a0,s0,-36
  32:	00000097          	auipc	ra,0x0
  36:	316080e7          	jalr	790(ra) # 348 <wait>

    uint end = uptime();
  3a:	00000097          	auipc	ra,0x0
  3e:	39e080e7          	jalr	926(ra) # 3d8 <uptime>

    if(status == 0){
  42:	fdc42783          	lw	a5,-36(s0)
  46:	efb5                	bnez	a5,c2 <main+0xc2>
    printf("Time elapsed: %d ticks\n", end - start);
  48:	412505bb          	subw	a1,a0,s2
  4c:	00001517          	auipc	a0,0x1
  50:	87450513          	addi	a0,a0,-1932 # 8c0 <malloc+0x146>
  54:	00000097          	auipc	ra,0x0
  58:	66e080e7          	jalr	1646(ra) # 6c2 <printf>
    }else{
        printf("Error: invalid arguments\n");
    }
    exit(0);
  5c:	4501                	li	a0,0
  5e:	00000097          	auipc	ra,0x0
  62:	2e2080e7          	jalr	738(ra) # 340 <exit>
        printf("Missing arguments\n");
  66:	00000517          	auipc	a0,0x0
  6a:	7fa50513          	addi	a0,a0,2042 # 860 <malloc+0xe6>
  6e:	00000097          	auipc	ra,0x0
  72:	654080e7          	jalr	1620(ra) # 6c2 <printf>
        exit(1);
  76:	4505                	li	a0,1
  78:	00000097          	auipc	ra,0x0
  7c:	2c8080e7          	jalr	712(ra) # 340 <exit>
        exec(arg[1], arg+1);
  80:	00848593          	addi	a1,s1,8
  84:	6488                	ld	a0,8(s1)
  86:	00000097          	auipc	ra,0x0
  8a:	2f2080e7          	jalr	754(ra) # 378 <exec>
        printf("Child process executing\n");       
  8e:	00000517          	auipc	a0,0x0
  92:	7ea50513          	addi	a0,a0,2026 # 878 <malloc+0xfe>
  96:	00000097          	auipc	ra,0x0
  9a:	62c080e7          	jalr	1580(ra) # 6c2 <printf>
        exit(1);
  9e:	4505                	li	a0,1
  a0:	00000097          	auipc	ra,0x0
  a4:	2a0080e7          	jalr	672(ra) # 340 <exit>
        printf("Error: no child process created\n");
  a8:	00000517          	auipc	a0,0x0
  ac:	7f050513          	addi	a0,a0,2032 # 898 <malloc+0x11e>
  b0:	00000097          	auipc	ra,0x0
  b4:	612080e7          	jalr	1554(ra) # 6c2 <printf>
        exit(1);
  b8:	4505                	li	a0,1
  ba:	00000097          	auipc	ra,0x0
  be:	286080e7          	jalr	646(ra) # 340 <exit>
        printf("Error: invalid arguments\n");
  c2:	00001517          	auipc	a0,0x1
  c6:	81650513          	addi	a0,a0,-2026 # 8d8 <malloc+0x15e>
  ca:	00000097          	auipc	ra,0x0
  ce:	5f8080e7          	jalr	1528(ra) # 6c2 <printf>
  d2:	b769                	j	5c <main+0x5c>

00000000000000d4 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  d4:	1141                	addi	sp,sp,-16
  d6:	e422                	sd	s0,8(sp)
  d8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  da:	87aa                	mv	a5,a0
  dc:	0585                	addi	a1,a1,1
  de:	0785                	addi	a5,a5,1
  e0:	fff5c703          	lbu	a4,-1(a1)
  e4:	fee78fa3          	sb	a4,-1(a5)
  e8:	fb75                	bnez	a4,dc <strcpy+0x8>
    ;
  return os;
}
  ea:	6422                	ld	s0,8(sp)
  ec:	0141                	addi	sp,sp,16
  ee:	8082                	ret

00000000000000f0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  f0:	1141                	addi	sp,sp,-16
  f2:	e422                	sd	s0,8(sp)
  f4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  f6:	00054783          	lbu	a5,0(a0)
  fa:	cb91                	beqz	a5,10e <strcmp+0x1e>
  fc:	0005c703          	lbu	a4,0(a1)
 100:	00f71763          	bne	a4,a5,10e <strcmp+0x1e>
    p++, q++;
 104:	0505                	addi	a0,a0,1
 106:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 108:	00054783          	lbu	a5,0(a0)
 10c:	fbe5                	bnez	a5,fc <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 10e:	0005c503          	lbu	a0,0(a1)
}
 112:	40a7853b          	subw	a0,a5,a0
 116:	6422                	ld	s0,8(sp)
 118:	0141                	addi	sp,sp,16
 11a:	8082                	ret

000000000000011c <strlen>:

uint
strlen(const char *s)
{
 11c:	1141                	addi	sp,sp,-16
 11e:	e422                	sd	s0,8(sp)
 120:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 122:	00054783          	lbu	a5,0(a0)
 126:	cf91                	beqz	a5,142 <strlen+0x26>
 128:	0505                	addi	a0,a0,1
 12a:	87aa                	mv	a5,a0
 12c:	4685                	li	a3,1
 12e:	9e89                	subw	a3,a3,a0
 130:	00f6853b          	addw	a0,a3,a5
 134:	0785                	addi	a5,a5,1
 136:	fff7c703          	lbu	a4,-1(a5)
 13a:	fb7d                	bnez	a4,130 <strlen+0x14>
    ;
  return n;
}
 13c:	6422                	ld	s0,8(sp)
 13e:	0141                	addi	sp,sp,16
 140:	8082                	ret
  for(n = 0; s[n]; n++)
 142:	4501                	li	a0,0
 144:	bfe5                	j	13c <strlen+0x20>

0000000000000146 <memset>:

void*
memset(void *dst, int c, uint n)
{
 146:	1141                	addi	sp,sp,-16
 148:	e422                	sd	s0,8(sp)
 14a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 14c:	ca19                	beqz	a2,162 <memset+0x1c>
 14e:	87aa                	mv	a5,a0
 150:	1602                	slli	a2,a2,0x20
 152:	9201                	srli	a2,a2,0x20
 154:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 158:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 15c:	0785                	addi	a5,a5,1
 15e:	fee79de3          	bne	a5,a4,158 <memset+0x12>
  }
  return dst;
}
 162:	6422                	ld	s0,8(sp)
 164:	0141                	addi	sp,sp,16
 166:	8082                	ret

0000000000000168 <strchr>:

char*
strchr(const char *s, char c)
{
 168:	1141                	addi	sp,sp,-16
 16a:	e422                	sd	s0,8(sp)
 16c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 16e:	00054783          	lbu	a5,0(a0)
 172:	cb99                	beqz	a5,188 <strchr+0x20>
    if(*s == c)
 174:	00f58763          	beq	a1,a5,182 <strchr+0x1a>
  for(; *s; s++)
 178:	0505                	addi	a0,a0,1
 17a:	00054783          	lbu	a5,0(a0)
 17e:	fbfd                	bnez	a5,174 <strchr+0xc>
      return (char*)s;
  return 0;
 180:	4501                	li	a0,0
}
 182:	6422                	ld	s0,8(sp)
 184:	0141                	addi	sp,sp,16
 186:	8082                	ret
  return 0;
 188:	4501                	li	a0,0
 18a:	bfe5                	j	182 <strchr+0x1a>

000000000000018c <gets>:

char*
gets(char *buf, int max)
{
 18c:	711d                	addi	sp,sp,-96
 18e:	ec86                	sd	ra,88(sp)
 190:	e8a2                	sd	s0,80(sp)
 192:	e4a6                	sd	s1,72(sp)
 194:	e0ca                	sd	s2,64(sp)
 196:	fc4e                	sd	s3,56(sp)
 198:	f852                	sd	s4,48(sp)
 19a:	f456                	sd	s5,40(sp)
 19c:	f05a                	sd	s6,32(sp)
 19e:	ec5e                	sd	s7,24(sp)
 1a0:	1080                	addi	s0,sp,96
 1a2:	8baa                	mv	s7,a0
 1a4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1a6:	892a                	mv	s2,a0
 1a8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1aa:	4aa9                	li	s5,10
 1ac:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1ae:	89a6                	mv	s3,s1
 1b0:	2485                	addiw	s1,s1,1
 1b2:	0344d863          	bge	s1,s4,1e2 <gets+0x56>
    cc = read(0, &c, 1);
 1b6:	4605                	li	a2,1
 1b8:	faf40593          	addi	a1,s0,-81
 1bc:	4501                	li	a0,0
 1be:	00000097          	auipc	ra,0x0
 1c2:	19a080e7          	jalr	410(ra) # 358 <read>
    if(cc < 1)
 1c6:	00a05e63          	blez	a0,1e2 <gets+0x56>
    buf[i++] = c;
 1ca:	faf44783          	lbu	a5,-81(s0)
 1ce:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1d2:	01578763          	beq	a5,s5,1e0 <gets+0x54>
 1d6:	0905                	addi	s2,s2,1
 1d8:	fd679be3          	bne	a5,s6,1ae <gets+0x22>
  for(i=0; i+1 < max; ){
 1dc:	89a6                	mv	s3,s1
 1de:	a011                	j	1e2 <gets+0x56>
 1e0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1e2:	99de                	add	s3,s3,s7
 1e4:	00098023          	sb	zero,0(s3)
  return buf;
}
 1e8:	855e                	mv	a0,s7
 1ea:	60e6                	ld	ra,88(sp)
 1ec:	6446                	ld	s0,80(sp)
 1ee:	64a6                	ld	s1,72(sp)
 1f0:	6906                	ld	s2,64(sp)
 1f2:	79e2                	ld	s3,56(sp)
 1f4:	7a42                	ld	s4,48(sp)
 1f6:	7aa2                	ld	s5,40(sp)
 1f8:	7b02                	ld	s6,32(sp)
 1fa:	6be2                	ld	s7,24(sp)
 1fc:	6125                	addi	sp,sp,96
 1fe:	8082                	ret

0000000000000200 <stat>:

int
stat(const char *n, struct stat *st)
{
 200:	1101                	addi	sp,sp,-32
 202:	ec06                	sd	ra,24(sp)
 204:	e822                	sd	s0,16(sp)
 206:	e426                	sd	s1,8(sp)
 208:	e04a                	sd	s2,0(sp)
 20a:	1000                	addi	s0,sp,32
 20c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 20e:	4581                	li	a1,0
 210:	00000097          	auipc	ra,0x0
 214:	170080e7          	jalr	368(ra) # 380 <open>
  if(fd < 0)
 218:	02054563          	bltz	a0,242 <stat+0x42>
 21c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 21e:	85ca                	mv	a1,s2
 220:	00000097          	auipc	ra,0x0
 224:	178080e7          	jalr	376(ra) # 398 <fstat>
 228:	892a                	mv	s2,a0
  close(fd);
 22a:	8526                	mv	a0,s1
 22c:	00000097          	auipc	ra,0x0
 230:	13c080e7          	jalr	316(ra) # 368 <close>
  return r;
}
 234:	854a                	mv	a0,s2
 236:	60e2                	ld	ra,24(sp)
 238:	6442                	ld	s0,16(sp)
 23a:	64a2                	ld	s1,8(sp)
 23c:	6902                	ld	s2,0(sp)
 23e:	6105                	addi	sp,sp,32
 240:	8082                	ret
    return -1;
 242:	597d                	li	s2,-1
 244:	bfc5                	j	234 <stat+0x34>

0000000000000246 <atoi>:

int
atoi(const char *s)
{
 246:	1141                	addi	sp,sp,-16
 248:	e422                	sd	s0,8(sp)
 24a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 24c:	00054683          	lbu	a3,0(a0)
 250:	fd06879b          	addiw	a5,a3,-48
 254:	0ff7f793          	zext.b	a5,a5
 258:	4625                	li	a2,9
 25a:	02f66863          	bltu	a2,a5,28a <atoi+0x44>
 25e:	872a                	mv	a4,a0
  n = 0;
 260:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 262:	0705                	addi	a4,a4,1
 264:	0025179b          	slliw	a5,a0,0x2
 268:	9fa9                	addw	a5,a5,a0
 26a:	0017979b          	slliw	a5,a5,0x1
 26e:	9fb5                	addw	a5,a5,a3
 270:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 274:	00074683          	lbu	a3,0(a4)
 278:	fd06879b          	addiw	a5,a3,-48
 27c:	0ff7f793          	zext.b	a5,a5
 280:	fef671e3          	bgeu	a2,a5,262 <atoi+0x1c>
  return n;
}
 284:	6422                	ld	s0,8(sp)
 286:	0141                	addi	sp,sp,16
 288:	8082                	ret
  n = 0;
 28a:	4501                	li	a0,0
 28c:	bfe5                	j	284 <atoi+0x3e>

000000000000028e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 28e:	1141                	addi	sp,sp,-16
 290:	e422                	sd	s0,8(sp)
 292:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 294:	02b57463          	bgeu	a0,a1,2bc <memmove+0x2e>
    while(n-- > 0)
 298:	00c05f63          	blez	a2,2b6 <memmove+0x28>
 29c:	1602                	slli	a2,a2,0x20
 29e:	9201                	srli	a2,a2,0x20
 2a0:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2a4:	872a                	mv	a4,a0
      *dst++ = *src++;
 2a6:	0585                	addi	a1,a1,1
 2a8:	0705                	addi	a4,a4,1
 2aa:	fff5c683          	lbu	a3,-1(a1)
 2ae:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2b2:	fee79ae3          	bne	a5,a4,2a6 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2b6:	6422                	ld	s0,8(sp)
 2b8:	0141                	addi	sp,sp,16
 2ba:	8082                	ret
    dst += n;
 2bc:	00c50733          	add	a4,a0,a2
    src += n;
 2c0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2c2:	fec05ae3          	blez	a2,2b6 <memmove+0x28>
 2c6:	fff6079b          	addiw	a5,a2,-1
 2ca:	1782                	slli	a5,a5,0x20
 2cc:	9381                	srli	a5,a5,0x20
 2ce:	fff7c793          	not	a5,a5
 2d2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2d4:	15fd                	addi	a1,a1,-1
 2d6:	177d                	addi	a4,a4,-1
 2d8:	0005c683          	lbu	a3,0(a1)
 2dc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2e0:	fee79ae3          	bne	a5,a4,2d4 <memmove+0x46>
 2e4:	bfc9                	j	2b6 <memmove+0x28>

00000000000002e6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2e6:	1141                	addi	sp,sp,-16
 2e8:	e422                	sd	s0,8(sp)
 2ea:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2ec:	ca05                	beqz	a2,31c <memcmp+0x36>
 2ee:	fff6069b          	addiw	a3,a2,-1
 2f2:	1682                	slli	a3,a3,0x20
 2f4:	9281                	srli	a3,a3,0x20
 2f6:	0685                	addi	a3,a3,1
 2f8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2fa:	00054783          	lbu	a5,0(a0)
 2fe:	0005c703          	lbu	a4,0(a1)
 302:	00e79863          	bne	a5,a4,312 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 306:	0505                	addi	a0,a0,1
    p2++;
 308:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 30a:	fed518e3          	bne	a0,a3,2fa <memcmp+0x14>
  }
  return 0;
 30e:	4501                	li	a0,0
 310:	a019                	j	316 <memcmp+0x30>
      return *p1 - *p2;
 312:	40e7853b          	subw	a0,a5,a4
}
 316:	6422                	ld	s0,8(sp)
 318:	0141                	addi	sp,sp,16
 31a:	8082                	ret
  return 0;
 31c:	4501                	li	a0,0
 31e:	bfe5                	j	316 <memcmp+0x30>

0000000000000320 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 320:	1141                	addi	sp,sp,-16
 322:	e406                	sd	ra,8(sp)
 324:	e022                	sd	s0,0(sp)
 326:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 328:	00000097          	auipc	ra,0x0
 32c:	f66080e7          	jalr	-154(ra) # 28e <memmove>
}
 330:	60a2                	ld	ra,8(sp)
 332:	6402                	ld	s0,0(sp)
 334:	0141                	addi	sp,sp,16
 336:	8082                	ret

0000000000000338 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 338:	4885                	li	a7,1
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <exit>:
.global exit
exit:
 li a7, SYS_exit
 340:	4889                	li	a7,2
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <wait>:
.global wait
wait:
 li a7, SYS_wait
 348:	488d                	li	a7,3
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 350:	4891                	li	a7,4
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <read>:
.global read
read:
 li a7, SYS_read
 358:	4895                	li	a7,5
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <write>:
.global write
write:
 li a7, SYS_write
 360:	48c1                	li	a7,16
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <close>:
.global close
close:
 li a7, SYS_close
 368:	48d5                	li	a7,21
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <kill>:
.global kill
kill:
 li a7, SYS_kill
 370:	4899                	li	a7,6
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <exec>:
.global exec
exec:
 li a7, SYS_exec
 378:	489d                	li	a7,7
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <open>:
.global open
open:
 li a7, SYS_open
 380:	48bd                	li	a7,15
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 388:	48c5                	li	a7,17
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 390:	48c9                	li	a7,18
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 398:	48a1                	li	a7,8
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <link>:
.global link
link:
 li a7, SYS_link
 3a0:	48cd                	li	a7,19
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3a8:	48d1                	li	a7,20
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3b0:	48a5                	li	a7,9
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3b8:	48a9                	li	a7,10
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3c0:	48ad                	li	a7,11
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3c8:	48b1                	li	a7,12
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3d0:	48b5                	li	a7,13
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3d8:	48b9                	li	a7,14
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <wait2>:
.global wait2
wait2:
 li a7, SYS_wait2
 3e0:	48d9                	li	a7,22
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3e8:	1101                	addi	sp,sp,-32
 3ea:	ec06                	sd	ra,24(sp)
 3ec:	e822                	sd	s0,16(sp)
 3ee:	1000                	addi	s0,sp,32
 3f0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3f4:	4605                	li	a2,1
 3f6:	fef40593          	addi	a1,s0,-17
 3fa:	00000097          	auipc	ra,0x0
 3fe:	f66080e7          	jalr	-154(ra) # 360 <write>
}
 402:	60e2                	ld	ra,24(sp)
 404:	6442                	ld	s0,16(sp)
 406:	6105                	addi	sp,sp,32
 408:	8082                	ret

000000000000040a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 40a:	7139                	addi	sp,sp,-64
 40c:	fc06                	sd	ra,56(sp)
 40e:	f822                	sd	s0,48(sp)
 410:	f426                	sd	s1,40(sp)
 412:	f04a                	sd	s2,32(sp)
 414:	ec4e                	sd	s3,24(sp)
 416:	0080                	addi	s0,sp,64
 418:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 41a:	c299                	beqz	a3,420 <printint+0x16>
 41c:	0805c963          	bltz	a1,4ae <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 420:	2581                	sext.w	a1,a1
  neg = 0;
 422:	4881                	li	a7,0
 424:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 428:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 42a:	2601                	sext.w	a2,a2
 42c:	00000517          	auipc	a0,0x0
 430:	52c50513          	addi	a0,a0,1324 # 958 <digits>
 434:	883a                	mv	a6,a4
 436:	2705                	addiw	a4,a4,1
 438:	02c5f7bb          	remuw	a5,a1,a2
 43c:	1782                	slli	a5,a5,0x20
 43e:	9381                	srli	a5,a5,0x20
 440:	97aa                	add	a5,a5,a0
 442:	0007c783          	lbu	a5,0(a5)
 446:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 44a:	0005879b          	sext.w	a5,a1
 44e:	02c5d5bb          	divuw	a1,a1,a2
 452:	0685                	addi	a3,a3,1
 454:	fec7f0e3          	bgeu	a5,a2,434 <printint+0x2a>
  if(neg)
 458:	00088c63          	beqz	a7,470 <printint+0x66>
    buf[i++] = '-';
 45c:	fd070793          	addi	a5,a4,-48
 460:	00878733          	add	a4,a5,s0
 464:	02d00793          	li	a5,45
 468:	fef70823          	sb	a5,-16(a4)
 46c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 470:	02e05863          	blez	a4,4a0 <printint+0x96>
 474:	fc040793          	addi	a5,s0,-64
 478:	00e78933          	add	s2,a5,a4
 47c:	fff78993          	addi	s3,a5,-1
 480:	99ba                	add	s3,s3,a4
 482:	377d                	addiw	a4,a4,-1
 484:	1702                	slli	a4,a4,0x20
 486:	9301                	srli	a4,a4,0x20
 488:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 48c:	fff94583          	lbu	a1,-1(s2)
 490:	8526                	mv	a0,s1
 492:	00000097          	auipc	ra,0x0
 496:	f56080e7          	jalr	-170(ra) # 3e8 <putc>
  while(--i >= 0)
 49a:	197d                	addi	s2,s2,-1
 49c:	ff3918e3          	bne	s2,s3,48c <printint+0x82>
}
 4a0:	70e2                	ld	ra,56(sp)
 4a2:	7442                	ld	s0,48(sp)
 4a4:	74a2                	ld	s1,40(sp)
 4a6:	7902                	ld	s2,32(sp)
 4a8:	69e2                	ld	s3,24(sp)
 4aa:	6121                	addi	sp,sp,64
 4ac:	8082                	ret
    x = -xx;
 4ae:	40b005bb          	negw	a1,a1
    neg = 1;
 4b2:	4885                	li	a7,1
    x = -xx;
 4b4:	bf85                	j	424 <printint+0x1a>

00000000000004b6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4b6:	7119                	addi	sp,sp,-128
 4b8:	fc86                	sd	ra,120(sp)
 4ba:	f8a2                	sd	s0,112(sp)
 4bc:	f4a6                	sd	s1,104(sp)
 4be:	f0ca                	sd	s2,96(sp)
 4c0:	ecce                	sd	s3,88(sp)
 4c2:	e8d2                	sd	s4,80(sp)
 4c4:	e4d6                	sd	s5,72(sp)
 4c6:	e0da                	sd	s6,64(sp)
 4c8:	fc5e                	sd	s7,56(sp)
 4ca:	f862                	sd	s8,48(sp)
 4cc:	f466                	sd	s9,40(sp)
 4ce:	f06a                	sd	s10,32(sp)
 4d0:	ec6e                	sd	s11,24(sp)
 4d2:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4d4:	0005c903          	lbu	s2,0(a1)
 4d8:	18090f63          	beqz	s2,676 <vprintf+0x1c0>
 4dc:	8aaa                	mv	s5,a0
 4de:	8b32                	mv	s6,a2
 4e0:	00158493          	addi	s1,a1,1
  state = 0;
 4e4:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4e6:	02500a13          	li	s4,37
 4ea:	4c55                	li	s8,21
 4ec:	00000c97          	auipc	s9,0x0
 4f0:	414c8c93          	addi	s9,s9,1044 # 900 <malloc+0x186>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 4f4:	02800d93          	li	s11,40
  putc(fd, 'x');
 4f8:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4fa:	00000b97          	auipc	s7,0x0
 4fe:	45eb8b93          	addi	s7,s7,1118 # 958 <digits>
 502:	a839                	j	520 <vprintf+0x6a>
        putc(fd, c);
 504:	85ca                	mv	a1,s2
 506:	8556                	mv	a0,s5
 508:	00000097          	auipc	ra,0x0
 50c:	ee0080e7          	jalr	-288(ra) # 3e8 <putc>
 510:	a019                	j	516 <vprintf+0x60>
    } else if(state == '%'){
 512:	01498d63          	beq	s3,s4,52c <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 516:	0485                	addi	s1,s1,1
 518:	fff4c903          	lbu	s2,-1(s1)
 51c:	14090d63          	beqz	s2,676 <vprintf+0x1c0>
    if(state == 0){
 520:	fe0999e3          	bnez	s3,512 <vprintf+0x5c>
      if(c == '%'){
 524:	ff4910e3          	bne	s2,s4,504 <vprintf+0x4e>
        state = '%';
 528:	89d2                	mv	s3,s4
 52a:	b7f5                	j	516 <vprintf+0x60>
      if(c == 'd'){
 52c:	11490c63          	beq	s2,s4,644 <vprintf+0x18e>
 530:	f9d9079b          	addiw	a5,s2,-99
 534:	0ff7f793          	zext.b	a5,a5
 538:	10fc6e63          	bltu	s8,a5,654 <vprintf+0x19e>
 53c:	f9d9079b          	addiw	a5,s2,-99
 540:	0ff7f713          	zext.b	a4,a5
 544:	10ec6863          	bltu	s8,a4,654 <vprintf+0x19e>
 548:	00271793          	slli	a5,a4,0x2
 54c:	97e6                	add	a5,a5,s9
 54e:	439c                	lw	a5,0(a5)
 550:	97e6                	add	a5,a5,s9
 552:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 554:	008b0913          	addi	s2,s6,8
 558:	4685                	li	a3,1
 55a:	4629                	li	a2,10
 55c:	000b2583          	lw	a1,0(s6)
 560:	8556                	mv	a0,s5
 562:	00000097          	auipc	ra,0x0
 566:	ea8080e7          	jalr	-344(ra) # 40a <printint>
 56a:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 56c:	4981                	li	s3,0
 56e:	b765                	j	516 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 570:	008b0913          	addi	s2,s6,8
 574:	4681                	li	a3,0
 576:	4629                	li	a2,10
 578:	000b2583          	lw	a1,0(s6)
 57c:	8556                	mv	a0,s5
 57e:	00000097          	auipc	ra,0x0
 582:	e8c080e7          	jalr	-372(ra) # 40a <printint>
 586:	8b4a                	mv	s6,s2
      state = 0;
 588:	4981                	li	s3,0
 58a:	b771                	j	516 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 58c:	008b0913          	addi	s2,s6,8
 590:	4681                	li	a3,0
 592:	866a                	mv	a2,s10
 594:	000b2583          	lw	a1,0(s6)
 598:	8556                	mv	a0,s5
 59a:	00000097          	auipc	ra,0x0
 59e:	e70080e7          	jalr	-400(ra) # 40a <printint>
 5a2:	8b4a                	mv	s6,s2
      state = 0;
 5a4:	4981                	li	s3,0
 5a6:	bf85                	j	516 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 5a8:	008b0793          	addi	a5,s6,8
 5ac:	f8f43423          	sd	a5,-120(s0)
 5b0:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 5b4:	03000593          	li	a1,48
 5b8:	8556                	mv	a0,s5
 5ba:	00000097          	auipc	ra,0x0
 5be:	e2e080e7          	jalr	-466(ra) # 3e8 <putc>
  putc(fd, 'x');
 5c2:	07800593          	li	a1,120
 5c6:	8556                	mv	a0,s5
 5c8:	00000097          	auipc	ra,0x0
 5cc:	e20080e7          	jalr	-480(ra) # 3e8 <putc>
 5d0:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5d2:	03c9d793          	srli	a5,s3,0x3c
 5d6:	97de                	add	a5,a5,s7
 5d8:	0007c583          	lbu	a1,0(a5)
 5dc:	8556                	mv	a0,s5
 5de:	00000097          	auipc	ra,0x0
 5e2:	e0a080e7          	jalr	-502(ra) # 3e8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5e6:	0992                	slli	s3,s3,0x4
 5e8:	397d                	addiw	s2,s2,-1
 5ea:	fe0914e3          	bnez	s2,5d2 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 5ee:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 5f2:	4981                	li	s3,0
 5f4:	b70d                	j	516 <vprintf+0x60>
        s = va_arg(ap, char*);
 5f6:	008b0913          	addi	s2,s6,8
 5fa:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 5fe:	02098163          	beqz	s3,620 <vprintf+0x16a>
        while(*s != 0){
 602:	0009c583          	lbu	a1,0(s3)
 606:	c5ad                	beqz	a1,670 <vprintf+0x1ba>
          putc(fd, *s);
 608:	8556                	mv	a0,s5
 60a:	00000097          	auipc	ra,0x0
 60e:	dde080e7          	jalr	-546(ra) # 3e8 <putc>
          s++;
 612:	0985                	addi	s3,s3,1
        while(*s != 0){
 614:	0009c583          	lbu	a1,0(s3)
 618:	f9e5                	bnez	a1,608 <vprintf+0x152>
        s = va_arg(ap, char*);
 61a:	8b4a                	mv	s6,s2
      state = 0;
 61c:	4981                	li	s3,0
 61e:	bde5                	j	516 <vprintf+0x60>
          s = "(null)";
 620:	00000997          	auipc	s3,0x0
 624:	2d898993          	addi	s3,s3,728 # 8f8 <malloc+0x17e>
        while(*s != 0){
 628:	85ee                	mv	a1,s11
 62a:	bff9                	j	608 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 62c:	008b0913          	addi	s2,s6,8
 630:	000b4583          	lbu	a1,0(s6)
 634:	8556                	mv	a0,s5
 636:	00000097          	auipc	ra,0x0
 63a:	db2080e7          	jalr	-590(ra) # 3e8 <putc>
 63e:	8b4a                	mv	s6,s2
      state = 0;
 640:	4981                	li	s3,0
 642:	bdd1                	j	516 <vprintf+0x60>
        putc(fd, c);
 644:	85d2                	mv	a1,s4
 646:	8556                	mv	a0,s5
 648:	00000097          	auipc	ra,0x0
 64c:	da0080e7          	jalr	-608(ra) # 3e8 <putc>
      state = 0;
 650:	4981                	li	s3,0
 652:	b5d1                	j	516 <vprintf+0x60>
        putc(fd, '%');
 654:	85d2                	mv	a1,s4
 656:	8556                	mv	a0,s5
 658:	00000097          	auipc	ra,0x0
 65c:	d90080e7          	jalr	-624(ra) # 3e8 <putc>
        putc(fd, c);
 660:	85ca                	mv	a1,s2
 662:	8556                	mv	a0,s5
 664:	00000097          	auipc	ra,0x0
 668:	d84080e7          	jalr	-636(ra) # 3e8 <putc>
      state = 0;
 66c:	4981                	li	s3,0
 66e:	b565                	j	516 <vprintf+0x60>
        s = va_arg(ap, char*);
 670:	8b4a                	mv	s6,s2
      state = 0;
 672:	4981                	li	s3,0
 674:	b54d                	j	516 <vprintf+0x60>
    }
  }
}
 676:	70e6                	ld	ra,120(sp)
 678:	7446                	ld	s0,112(sp)
 67a:	74a6                	ld	s1,104(sp)
 67c:	7906                	ld	s2,96(sp)
 67e:	69e6                	ld	s3,88(sp)
 680:	6a46                	ld	s4,80(sp)
 682:	6aa6                	ld	s5,72(sp)
 684:	6b06                	ld	s6,64(sp)
 686:	7be2                	ld	s7,56(sp)
 688:	7c42                	ld	s8,48(sp)
 68a:	7ca2                	ld	s9,40(sp)
 68c:	7d02                	ld	s10,32(sp)
 68e:	6de2                	ld	s11,24(sp)
 690:	6109                	addi	sp,sp,128
 692:	8082                	ret

0000000000000694 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 694:	715d                	addi	sp,sp,-80
 696:	ec06                	sd	ra,24(sp)
 698:	e822                	sd	s0,16(sp)
 69a:	1000                	addi	s0,sp,32
 69c:	e010                	sd	a2,0(s0)
 69e:	e414                	sd	a3,8(s0)
 6a0:	e818                	sd	a4,16(s0)
 6a2:	ec1c                	sd	a5,24(s0)
 6a4:	03043023          	sd	a6,32(s0)
 6a8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6ac:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6b0:	8622                	mv	a2,s0
 6b2:	00000097          	auipc	ra,0x0
 6b6:	e04080e7          	jalr	-508(ra) # 4b6 <vprintf>
}
 6ba:	60e2                	ld	ra,24(sp)
 6bc:	6442                	ld	s0,16(sp)
 6be:	6161                	addi	sp,sp,80
 6c0:	8082                	ret

00000000000006c2 <printf>:

void
printf(const char *fmt, ...)
{
 6c2:	711d                	addi	sp,sp,-96
 6c4:	ec06                	sd	ra,24(sp)
 6c6:	e822                	sd	s0,16(sp)
 6c8:	1000                	addi	s0,sp,32
 6ca:	e40c                	sd	a1,8(s0)
 6cc:	e810                	sd	a2,16(s0)
 6ce:	ec14                	sd	a3,24(s0)
 6d0:	f018                	sd	a4,32(s0)
 6d2:	f41c                	sd	a5,40(s0)
 6d4:	03043823          	sd	a6,48(s0)
 6d8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6dc:	00840613          	addi	a2,s0,8
 6e0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6e4:	85aa                	mv	a1,a0
 6e6:	4505                	li	a0,1
 6e8:	00000097          	auipc	ra,0x0
 6ec:	dce080e7          	jalr	-562(ra) # 4b6 <vprintf>
}
 6f0:	60e2                	ld	ra,24(sp)
 6f2:	6442                	ld	s0,16(sp)
 6f4:	6125                	addi	sp,sp,96
 6f6:	8082                	ret

00000000000006f8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6f8:	1141                	addi	sp,sp,-16
 6fa:	e422                	sd	s0,8(sp)
 6fc:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6fe:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 702:	00000797          	auipc	a5,0x0
 706:	26e7b783          	ld	a5,622(a5) # 970 <freep>
 70a:	a02d                	j	734 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 70c:	4618                	lw	a4,8(a2)
 70e:	9f2d                	addw	a4,a4,a1
 710:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 714:	6398                	ld	a4,0(a5)
 716:	6310                	ld	a2,0(a4)
 718:	a83d                	j	756 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 71a:	ff852703          	lw	a4,-8(a0)
 71e:	9f31                	addw	a4,a4,a2
 720:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 722:	ff053683          	ld	a3,-16(a0)
 726:	a091                	j	76a <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 728:	6398                	ld	a4,0(a5)
 72a:	00e7e463          	bltu	a5,a4,732 <free+0x3a>
 72e:	00e6ea63          	bltu	a3,a4,742 <free+0x4a>
{
 732:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 734:	fed7fae3          	bgeu	a5,a3,728 <free+0x30>
 738:	6398                	ld	a4,0(a5)
 73a:	00e6e463          	bltu	a3,a4,742 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 73e:	fee7eae3          	bltu	a5,a4,732 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 742:	ff852583          	lw	a1,-8(a0)
 746:	6390                	ld	a2,0(a5)
 748:	02059813          	slli	a6,a1,0x20
 74c:	01c85713          	srli	a4,a6,0x1c
 750:	9736                	add	a4,a4,a3
 752:	fae60de3          	beq	a2,a4,70c <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 756:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 75a:	4790                	lw	a2,8(a5)
 75c:	02061593          	slli	a1,a2,0x20
 760:	01c5d713          	srli	a4,a1,0x1c
 764:	973e                	add	a4,a4,a5
 766:	fae68ae3          	beq	a3,a4,71a <free+0x22>
    p->s.ptr = bp->s.ptr;
 76a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 76c:	00000717          	auipc	a4,0x0
 770:	20f73223          	sd	a5,516(a4) # 970 <freep>
}
 774:	6422                	ld	s0,8(sp)
 776:	0141                	addi	sp,sp,16
 778:	8082                	ret

000000000000077a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 77a:	7139                	addi	sp,sp,-64
 77c:	fc06                	sd	ra,56(sp)
 77e:	f822                	sd	s0,48(sp)
 780:	f426                	sd	s1,40(sp)
 782:	f04a                	sd	s2,32(sp)
 784:	ec4e                	sd	s3,24(sp)
 786:	e852                	sd	s4,16(sp)
 788:	e456                	sd	s5,8(sp)
 78a:	e05a                	sd	s6,0(sp)
 78c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 78e:	02051493          	slli	s1,a0,0x20
 792:	9081                	srli	s1,s1,0x20
 794:	04bd                	addi	s1,s1,15
 796:	8091                	srli	s1,s1,0x4
 798:	0014899b          	addiw	s3,s1,1
 79c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 79e:	00000517          	auipc	a0,0x0
 7a2:	1d253503          	ld	a0,466(a0) # 970 <freep>
 7a6:	c515                	beqz	a0,7d2 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7a8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7aa:	4798                	lw	a4,8(a5)
 7ac:	02977f63          	bgeu	a4,s1,7ea <malloc+0x70>
 7b0:	8a4e                	mv	s4,s3
 7b2:	0009871b          	sext.w	a4,s3
 7b6:	6685                	lui	a3,0x1
 7b8:	00d77363          	bgeu	a4,a3,7be <malloc+0x44>
 7bc:	6a05                	lui	s4,0x1
 7be:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7c2:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7c6:	00000917          	auipc	s2,0x0
 7ca:	1aa90913          	addi	s2,s2,426 # 970 <freep>
  if(p == (char*)-1)
 7ce:	5afd                	li	s5,-1
 7d0:	a895                	j	844 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 7d2:	00000797          	auipc	a5,0x0
 7d6:	1a678793          	addi	a5,a5,422 # 978 <base>
 7da:	00000717          	auipc	a4,0x0
 7de:	18f73b23          	sd	a5,406(a4) # 970 <freep>
 7e2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7e4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7e8:	b7e1                	j	7b0 <malloc+0x36>
      if(p->s.size == nunits)
 7ea:	02e48c63          	beq	s1,a4,822 <malloc+0xa8>
        p->s.size -= nunits;
 7ee:	4137073b          	subw	a4,a4,s3
 7f2:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7f4:	02071693          	slli	a3,a4,0x20
 7f8:	01c6d713          	srli	a4,a3,0x1c
 7fc:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7fe:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 802:	00000717          	auipc	a4,0x0
 806:	16a73723          	sd	a0,366(a4) # 970 <freep>
      return (void*)(p + 1);
 80a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 80e:	70e2                	ld	ra,56(sp)
 810:	7442                	ld	s0,48(sp)
 812:	74a2                	ld	s1,40(sp)
 814:	7902                	ld	s2,32(sp)
 816:	69e2                	ld	s3,24(sp)
 818:	6a42                	ld	s4,16(sp)
 81a:	6aa2                	ld	s5,8(sp)
 81c:	6b02                	ld	s6,0(sp)
 81e:	6121                	addi	sp,sp,64
 820:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 822:	6398                	ld	a4,0(a5)
 824:	e118                	sd	a4,0(a0)
 826:	bff1                	j	802 <malloc+0x88>
  hp->s.size = nu;
 828:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 82c:	0541                	addi	a0,a0,16
 82e:	00000097          	auipc	ra,0x0
 832:	eca080e7          	jalr	-310(ra) # 6f8 <free>
  return freep;
 836:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 83a:	d971                	beqz	a0,80e <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 83c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 83e:	4798                	lw	a4,8(a5)
 840:	fa9775e3          	bgeu	a4,s1,7ea <malloc+0x70>
    if(p == freep)
 844:	00093703          	ld	a4,0(s2)
 848:	853e                	mv	a0,a5
 84a:	fef719e3          	bne	a4,a5,83c <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 84e:	8552                	mv	a0,s4
 850:	00000097          	auipc	ra,0x0
 854:	b78080e7          	jalr	-1160(ra) # 3c8 <sbrk>
  if(p == (char*)-1)
 858:	fd5518e3          	bne	a0,s5,828 <malloc+0xae>
        return 0;
 85c:	4501                	li	a0,0
 85e:	bf45                	j	80e <malloc+0x94>
