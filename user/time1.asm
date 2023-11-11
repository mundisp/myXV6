
user/_time1:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

//struct &rusage;

char *argv_sec[1000];

int main(int argc, char **argv){
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32

//we will do a traverse through argv, shiftting through 
for(int i = 1; i < sizeof(argv); i++){
   c:	05a1                	addi	a1,a1,8
   e:	00001797          	auipc	a5,0x1
  12:	94a78793          	addi	a5,a5,-1718 # 958 <argv_sec>
  16:	00001697          	auipc	a3,0x1
  1a:	97a68693          	addi	a3,a3,-1670 # 990 <argv_sec+0x38>
	argv_sec[i-1] = argv[i];
  1e:	6198                	ld	a4,0(a1)
  20:	e398                	sd	a4,0(a5)
for(int i = 1; i < sizeof(argv); i++){
  22:	05a1                	addi	a1,a1,8
  24:	07a1                	addi	a5,a5,8
  26:	fed79ce3          	bne	a5,a3,1e <main+0x1e>
}

argv_sec[sizeof(argv)] = 0;
  2a:	00001797          	auipc	a5,0x1
  2e:	9607b723          	sd	zero,-1682(a5) # 998 <argv_sec+0x40>

//put uptime in a variable
int time1 = uptime();
  32:	00000097          	auipc	ra,0x0
  36:	3b0080e7          	jalr	944(ra) # 3e2 <uptime>
  3a:	892a                	mv	s2,a0

//put fork in variable pid
int pid = fork();
  3c:	00000097          	auipc	ra,0x0
  40:	306080e7          	jalr	774(ra) # 342 <fork>
  44:	84aa                	mv	s1,a0

if(pid < 0){
  46:	02054963          	bltz	a0,78 <main+0x78>
	printf("time1: failure in fork\n");
	exit(1);
}
else if(pid == 0){
  4a:	e521                	bnez	a0,92 <main+0x92>
	//we will call exec() with argv1[0] and argv1
	exec(argv_sec[0], argv_sec);
  4c:	00001597          	auipc	a1,0x1
  50:	90c58593          	addi	a1,a1,-1780 # 958 <argv_sec>
  54:	6188                	ld	a0,0(a1)
  56:	00000097          	auipc	ra,0x0
  5a:	32c080e7          	jalr	812(ra) # 382 <exec>
	printf("elapsed time failed\n");
  5e:	00001517          	auipc	a0,0x1
  62:	84a50513          	addi	a0,a0,-1974 # 8a8 <malloc+0x104>
  66:	00000097          	auipc	ra,0x0
  6a:	686080e7          	jalr	1670(ra) # 6ec <printf>
	exit(1);
  6e:	4505                	li	a0,1
  70:	00000097          	auipc	ra,0x0
  74:	2da080e7          	jalr	730(ra) # 34a <exit>
	printf("time1: failure in fork\n");
  78:	00001517          	auipc	a0,0x1
  7c:	81850513          	addi	a0,a0,-2024 # 890 <malloc+0xec>
  80:	00000097          	auipc	ra,0x0
  84:	66c080e7          	jalr	1644(ra) # 6ec <printf>
	exit(1);
  88:	4505                	li	a0,1
  8a:	00000097          	auipc	ra,0x0
  8e:	2c0080e7          	jalr	704(ra) # 34a <exit>
}
else{
		int wpid = wait((int *) 0);
  92:	4501                	li	a0,0
  94:	00000097          	auipc	ra,0x0
  98:	2be080e7          	jalr	702(ra) # 352 <wait>
		if(wpid == pid){ 
  9c:	00a48963          	beq	s1,a0,ae <main+0xae>
			printf("elapsed time: %d ticks\n", uptime() - time1);
			
			//we will exit the shell and restart it
			exit(1);
		}
		else if(wpid < 0){
  a0:	02054a63          	bltz	a0,d4 <main+0xd4>
		else{
			//we will do nothing since it did not have a parent proccess
			
		}
	}
	exit(0);
  a4:	4501                	li	a0,0
  a6:	00000097          	auipc	ra,0x0
  aa:	2a4080e7          	jalr	676(ra) # 34a <exit>
			printf("elapsed time: %d ticks\n", uptime() - time1);
  ae:	00000097          	auipc	ra,0x0
  b2:	334080e7          	jalr	820(ra) # 3e2 <uptime>
  b6:	412505bb          	subw	a1,a0,s2
  ba:	00001517          	auipc	a0,0x1
  be:	80650513          	addi	a0,a0,-2042 # 8c0 <malloc+0x11c>
  c2:	00000097          	auipc	ra,0x0
  c6:	62a080e7          	jalr	1578(ra) # 6ec <printf>
			exit(1);
  ca:	4505                	li	a0,1
  cc:	00000097          	auipc	ra,0x0
  d0:	27e080e7          	jalr	638(ra) # 34a <exit>
			exit(1);
  d4:	4505                	li	a0,1
  d6:	00000097          	auipc	ra,0x0
  da:	274080e7          	jalr	628(ra) # 34a <exit>

00000000000000de <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  de:	1141                	addi	sp,sp,-16
  e0:	e422                	sd	s0,8(sp)
  e2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  e4:	87aa                	mv	a5,a0
  e6:	0585                	addi	a1,a1,1
  e8:	0785                	addi	a5,a5,1
  ea:	fff5c703          	lbu	a4,-1(a1)
  ee:	fee78fa3          	sb	a4,-1(a5)
  f2:	fb75                	bnez	a4,e6 <strcpy+0x8>
    ;
  return os;
}
  f4:	6422                	ld	s0,8(sp)
  f6:	0141                	addi	sp,sp,16
  f8:	8082                	ret

00000000000000fa <strcmp>:

int
strcmp(const char *p, const char *q)
{
  fa:	1141                	addi	sp,sp,-16
  fc:	e422                	sd	s0,8(sp)
  fe:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 100:	00054783          	lbu	a5,0(a0)
 104:	cb91                	beqz	a5,118 <strcmp+0x1e>
 106:	0005c703          	lbu	a4,0(a1)
 10a:	00f71763          	bne	a4,a5,118 <strcmp+0x1e>
    p++, q++;
 10e:	0505                	addi	a0,a0,1
 110:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 112:	00054783          	lbu	a5,0(a0)
 116:	fbe5                	bnez	a5,106 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 118:	0005c503          	lbu	a0,0(a1)
}
 11c:	40a7853b          	subw	a0,a5,a0
 120:	6422                	ld	s0,8(sp)
 122:	0141                	addi	sp,sp,16
 124:	8082                	ret

0000000000000126 <strlen>:

uint
strlen(const char *s)
{
 126:	1141                	addi	sp,sp,-16
 128:	e422                	sd	s0,8(sp)
 12a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 12c:	00054783          	lbu	a5,0(a0)
 130:	cf91                	beqz	a5,14c <strlen+0x26>
 132:	0505                	addi	a0,a0,1
 134:	87aa                	mv	a5,a0
 136:	4685                	li	a3,1
 138:	9e89                	subw	a3,a3,a0
 13a:	00f6853b          	addw	a0,a3,a5
 13e:	0785                	addi	a5,a5,1
 140:	fff7c703          	lbu	a4,-1(a5)
 144:	fb7d                	bnez	a4,13a <strlen+0x14>
    ;
  return n;
}
 146:	6422                	ld	s0,8(sp)
 148:	0141                	addi	sp,sp,16
 14a:	8082                	ret
  for(n = 0; s[n]; n++)
 14c:	4501                	li	a0,0
 14e:	bfe5                	j	146 <strlen+0x20>

0000000000000150 <memset>:

void*
memset(void *dst, int c, uint n)
{
 150:	1141                	addi	sp,sp,-16
 152:	e422                	sd	s0,8(sp)
 154:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 156:	ca19                	beqz	a2,16c <memset+0x1c>
 158:	87aa                	mv	a5,a0
 15a:	1602                	slli	a2,a2,0x20
 15c:	9201                	srli	a2,a2,0x20
 15e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 162:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 166:	0785                	addi	a5,a5,1
 168:	fee79de3          	bne	a5,a4,162 <memset+0x12>
  }
  return dst;
}
 16c:	6422                	ld	s0,8(sp)
 16e:	0141                	addi	sp,sp,16
 170:	8082                	ret

0000000000000172 <strchr>:

char*
strchr(const char *s, char c)
{
 172:	1141                	addi	sp,sp,-16
 174:	e422                	sd	s0,8(sp)
 176:	0800                	addi	s0,sp,16
  for(; *s; s++)
 178:	00054783          	lbu	a5,0(a0)
 17c:	cb99                	beqz	a5,192 <strchr+0x20>
    if(*s == c)
 17e:	00f58763          	beq	a1,a5,18c <strchr+0x1a>
  for(; *s; s++)
 182:	0505                	addi	a0,a0,1
 184:	00054783          	lbu	a5,0(a0)
 188:	fbfd                	bnez	a5,17e <strchr+0xc>
      return (char*)s;
  return 0;
 18a:	4501                	li	a0,0
}
 18c:	6422                	ld	s0,8(sp)
 18e:	0141                	addi	sp,sp,16
 190:	8082                	ret
  return 0;
 192:	4501                	li	a0,0
 194:	bfe5                	j	18c <strchr+0x1a>

0000000000000196 <gets>:

char*
gets(char *buf, int max)
{
 196:	711d                	addi	sp,sp,-96
 198:	ec86                	sd	ra,88(sp)
 19a:	e8a2                	sd	s0,80(sp)
 19c:	e4a6                	sd	s1,72(sp)
 19e:	e0ca                	sd	s2,64(sp)
 1a0:	fc4e                	sd	s3,56(sp)
 1a2:	f852                	sd	s4,48(sp)
 1a4:	f456                	sd	s5,40(sp)
 1a6:	f05a                	sd	s6,32(sp)
 1a8:	ec5e                	sd	s7,24(sp)
 1aa:	1080                	addi	s0,sp,96
 1ac:	8baa                	mv	s7,a0
 1ae:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1b0:	892a                	mv	s2,a0
 1b2:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1b4:	4aa9                	li	s5,10
 1b6:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1b8:	89a6                	mv	s3,s1
 1ba:	2485                	addiw	s1,s1,1
 1bc:	0344d863          	bge	s1,s4,1ec <gets+0x56>
    cc = read(0, &c, 1);
 1c0:	4605                	li	a2,1
 1c2:	faf40593          	addi	a1,s0,-81
 1c6:	4501                	li	a0,0
 1c8:	00000097          	auipc	ra,0x0
 1cc:	19a080e7          	jalr	410(ra) # 362 <read>
    if(cc < 1)
 1d0:	00a05e63          	blez	a0,1ec <gets+0x56>
    buf[i++] = c;
 1d4:	faf44783          	lbu	a5,-81(s0)
 1d8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1dc:	01578763          	beq	a5,s5,1ea <gets+0x54>
 1e0:	0905                	addi	s2,s2,1
 1e2:	fd679be3          	bne	a5,s6,1b8 <gets+0x22>
  for(i=0; i+1 < max; ){
 1e6:	89a6                	mv	s3,s1
 1e8:	a011                	j	1ec <gets+0x56>
 1ea:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1ec:	99de                	add	s3,s3,s7
 1ee:	00098023          	sb	zero,0(s3)
  return buf;
}
 1f2:	855e                	mv	a0,s7
 1f4:	60e6                	ld	ra,88(sp)
 1f6:	6446                	ld	s0,80(sp)
 1f8:	64a6                	ld	s1,72(sp)
 1fa:	6906                	ld	s2,64(sp)
 1fc:	79e2                	ld	s3,56(sp)
 1fe:	7a42                	ld	s4,48(sp)
 200:	7aa2                	ld	s5,40(sp)
 202:	7b02                	ld	s6,32(sp)
 204:	6be2                	ld	s7,24(sp)
 206:	6125                	addi	sp,sp,96
 208:	8082                	ret

000000000000020a <stat>:

int
stat(const char *n, struct stat *st)
{
 20a:	1101                	addi	sp,sp,-32
 20c:	ec06                	sd	ra,24(sp)
 20e:	e822                	sd	s0,16(sp)
 210:	e426                	sd	s1,8(sp)
 212:	e04a                	sd	s2,0(sp)
 214:	1000                	addi	s0,sp,32
 216:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 218:	4581                	li	a1,0
 21a:	00000097          	auipc	ra,0x0
 21e:	170080e7          	jalr	368(ra) # 38a <open>
  if(fd < 0)
 222:	02054563          	bltz	a0,24c <stat+0x42>
 226:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 228:	85ca                	mv	a1,s2
 22a:	00000097          	auipc	ra,0x0
 22e:	178080e7          	jalr	376(ra) # 3a2 <fstat>
 232:	892a                	mv	s2,a0
  close(fd);
 234:	8526                	mv	a0,s1
 236:	00000097          	auipc	ra,0x0
 23a:	13c080e7          	jalr	316(ra) # 372 <close>
  return r;
}
 23e:	854a                	mv	a0,s2
 240:	60e2                	ld	ra,24(sp)
 242:	6442                	ld	s0,16(sp)
 244:	64a2                	ld	s1,8(sp)
 246:	6902                	ld	s2,0(sp)
 248:	6105                	addi	sp,sp,32
 24a:	8082                	ret
    return -1;
 24c:	597d                	li	s2,-1
 24e:	bfc5                	j	23e <stat+0x34>

0000000000000250 <atoi>:

int
atoi(const char *s)
{
 250:	1141                	addi	sp,sp,-16
 252:	e422                	sd	s0,8(sp)
 254:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 256:	00054683          	lbu	a3,0(a0)
 25a:	fd06879b          	addiw	a5,a3,-48
 25e:	0ff7f793          	zext.b	a5,a5
 262:	4625                	li	a2,9
 264:	02f66863          	bltu	a2,a5,294 <atoi+0x44>
 268:	872a                	mv	a4,a0
  n = 0;
 26a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 26c:	0705                	addi	a4,a4,1
 26e:	0025179b          	slliw	a5,a0,0x2
 272:	9fa9                	addw	a5,a5,a0
 274:	0017979b          	slliw	a5,a5,0x1
 278:	9fb5                	addw	a5,a5,a3
 27a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 27e:	00074683          	lbu	a3,0(a4)
 282:	fd06879b          	addiw	a5,a3,-48
 286:	0ff7f793          	zext.b	a5,a5
 28a:	fef671e3          	bgeu	a2,a5,26c <atoi+0x1c>
  return n;
}
 28e:	6422                	ld	s0,8(sp)
 290:	0141                	addi	sp,sp,16
 292:	8082                	ret
  n = 0;
 294:	4501                	li	a0,0
 296:	bfe5                	j	28e <atoi+0x3e>

0000000000000298 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 298:	1141                	addi	sp,sp,-16
 29a:	e422                	sd	s0,8(sp)
 29c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 29e:	02b57463          	bgeu	a0,a1,2c6 <memmove+0x2e>
    while(n-- > 0)
 2a2:	00c05f63          	blez	a2,2c0 <memmove+0x28>
 2a6:	1602                	slli	a2,a2,0x20
 2a8:	9201                	srli	a2,a2,0x20
 2aa:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2ae:	872a                	mv	a4,a0
      *dst++ = *src++;
 2b0:	0585                	addi	a1,a1,1
 2b2:	0705                	addi	a4,a4,1
 2b4:	fff5c683          	lbu	a3,-1(a1)
 2b8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2bc:	fee79ae3          	bne	a5,a4,2b0 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2c0:	6422                	ld	s0,8(sp)
 2c2:	0141                	addi	sp,sp,16
 2c4:	8082                	ret
    dst += n;
 2c6:	00c50733          	add	a4,a0,a2
    src += n;
 2ca:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2cc:	fec05ae3          	blez	a2,2c0 <memmove+0x28>
 2d0:	fff6079b          	addiw	a5,a2,-1
 2d4:	1782                	slli	a5,a5,0x20
 2d6:	9381                	srli	a5,a5,0x20
 2d8:	fff7c793          	not	a5,a5
 2dc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2de:	15fd                	addi	a1,a1,-1
 2e0:	177d                	addi	a4,a4,-1
 2e2:	0005c683          	lbu	a3,0(a1)
 2e6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2ea:	fee79ae3          	bne	a5,a4,2de <memmove+0x46>
 2ee:	bfc9                	j	2c0 <memmove+0x28>

00000000000002f0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2f0:	1141                	addi	sp,sp,-16
 2f2:	e422                	sd	s0,8(sp)
 2f4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2f6:	ca05                	beqz	a2,326 <memcmp+0x36>
 2f8:	fff6069b          	addiw	a3,a2,-1
 2fc:	1682                	slli	a3,a3,0x20
 2fe:	9281                	srli	a3,a3,0x20
 300:	0685                	addi	a3,a3,1
 302:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 304:	00054783          	lbu	a5,0(a0)
 308:	0005c703          	lbu	a4,0(a1)
 30c:	00e79863          	bne	a5,a4,31c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 310:	0505                	addi	a0,a0,1
    p2++;
 312:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 314:	fed518e3          	bne	a0,a3,304 <memcmp+0x14>
  }
  return 0;
 318:	4501                	li	a0,0
 31a:	a019                	j	320 <memcmp+0x30>
      return *p1 - *p2;
 31c:	40e7853b          	subw	a0,a5,a4
}
 320:	6422                	ld	s0,8(sp)
 322:	0141                	addi	sp,sp,16
 324:	8082                	ret
  return 0;
 326:	4501                	li	a0,0
 328:	bfe5                	j	320 <memcmp+0x30>

000000000000032a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 32a:	1141                	addi	sp,sp,-16
 32c:	e406                	sd	ra,8(sp)
 32e:	e022                	sd	s0,0(sp)
 330:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 332:	00000097          	auipc	ra,0x0
 336:	f66080e7          	jalr	-154(ra) # 298 <memmove>
}
 33a:	60a2                	ld	ra,8(sp)
 33c:	6402                	ld	s0,0(sp)
 33e:	0141                	addi	sp,sp,16
 340:	8082                	ret

0000000000000342 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 342:	4885                	li	a7,1
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <exit>:
.global exit
exit:
 li a7, SYS_exit
 34a:	4889                	li	a7,2
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <wait>:
.global wait
wait:
 li a7, SYS_wait
 352:	488d                	li	a7,3
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 35a:	4891                	li	a7,4
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <read>:
.global read
read:
 li a7, SYS_read
 362:	4895                	li	a7,5
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <write>:
.global write
write:
 li a7, SYS_write
 36a:	48c1                	li	a7,16
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <close>:
.global close
close:
 li a7, SYS_close
 372:	48d5                	li	a7,21
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <kill>:
.global kill
kill:
 li a7, SYS_kill
 37a:	4899                	li	a7,6
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <exec>:
.global exec
exec:
 li a7, SYS_exec
 382:	489d                	li	a7,7
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <open>:
.global open
open:
 li a7, SYS_open
 38a:	48bd                	li	a7,15
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 392:	48c5                	li	a7,17
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 39a:	48c9                	li	a7,18
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3a2:	48a1                	li	a7,8
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <link>:
.global link
link:
 li a7, SYS_link
 3aa:	48cd                	li	a7,19
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3b2:	48d1                	li	a7,20
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3ba:	48a5                	li	a7,9
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3c2:	48a9                	li	a7,10
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3ca:	48ad                	li	a7,11
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3d2:	48b1                	li	a7,12
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3da:	48b5                	li	a7,13
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3e2:	48b9                	li	a7,14
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <getprocs>:
.global getprocs
getprocs:
 li a7, SYS_getprocs
 3ea:	48d9                	li	a7,22
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <wait2>:
.global wait2
wait2:
 li a7, SYS_wait2
 3f2:	48dd                	li	a7,23
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
 3fa:	48e5                	li	a7,25
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <getpriority>:
.global getpriority
getpriority:
 li a7, SYS_getpriority
 402:	48e1                	li	a7,24
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <freepmem>:
.global freepmem
freepmem:
 li a7, SYS_freepmem
 40a:	48e9                	li	a7,26
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 412:	1101                	addi	sp,sp,-32
 414:	ec06                	sd	ra,24(sp)
 416:	e822                	sd	s0,16(sp)
 418:	1000                	addi	s0,sp,32
 41a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 41e:	4605                	li	a2,1
 420:	fef40593          	addi	a1,s0,-17
 424:	00000097          	auipc	ra,0x0
 428:	f46080e7          	jalr	-186(ra) # 36a <write>
}
 42c:	60e2                	ld	ra,24(sp)
 42e:	6442                	ld	s0,16(sp)
 430:	6105                	addi	sp,sp,32
 432:	8082                	ret

0000000000000434 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 434:	7139                	addi	sp,sp,-64
 436:	fc06                	sd	ra,56(sp)
 438:	f822                	sd	s0,48(sp)
 43a:	f426                	sd	s1,40(sp)
 43c:	f04a                	sd	s2,32(sp)
 43e:	ec4e                	sd	s3,24(sp)
 440:	0080                	addi	s0,sp,64
 442:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 444:	c299                	beqz	a3,44a <printint+0x16>
 446:	0805c963          	bltz	a1,4d8 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 44a:	2581                	sext.w	a1,a1
  neg = 0;
 44c:	4881                	li	a7,0
 44e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 452:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 454:	2601                	sext.w	a2,a2
 456:	00000517          	auipc	a0,0x0
 45a:	4e250513          	addi	a0,a0,1250 # 938 <digits>
 45e:	883a                	mv	a6,a4
 460:	2705                	addiw	a4,a4,1
 462:	02c5f7bb          	remuw	a5,a1,a2
 466:	1782                	slli	a5,a5,0x20
 468:	9381                	srli	a5,a5,0x20
 46a:	97aa                	add	a5,a5,a0
 46c:	0007c783          	lbu	a5,0(a5)
 470:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 474:	0005879b          	sext.w	a5,a1
 478:	02c5d5bb          	divuw	a1,a1,a2
 47c:	0685                	addi	a3,a3,1
 47e:	fec7f0e3          	bgeu	a5,a2,45e <printint+0x2a>
  if(neg)
 482:	00088c63          	beqz	a7,49a <printint+0x66>
    buf[i++] = '-';
 486:	fd070793          	addi	a5,a4,-48
 48a:	00878733          	add	a4,a5,s0
 48e:	02d00793          	li	a5,45
 492:	fef70823          	sb	a5,-16(a4)
 496:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 49a:	02e05863          	blez	a4,4ca <printint+0x96>
 49e:	fc040793          	addi	a5,s0,-64
 4a2:	00e78933          	add	s2,a5,a4
 4a6:	fff78993          	addi	s3,a5,-1
 4aa:	99ba                	add	s3,s3,a4
 4ac:	377d                	addiw	a4,a4,-1
 4ae:	1702                	slli	a4,a4,0x20
 4b0:	9301                	srli	a4,a4,0x20
 4b2:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4b6:	fff94583          	lbu	a1,-1(s2)
 4ba:	8526                	mv	a0,s1
 4bc:	00000097          	auipc	ra,0x0
 4c0:	f56080e7          	jalr	-170(ra) # 412 <putc>
  while(--i >= 0)
 4c4:	197d                	addi	s2,s2,-1
 4c6:	ff3918e3          	bne	s2,s3,4b6 <printint+0x82>
}
 4ca:	70e2                	ld	ra,56(sp)
 4cc:	7442                	ld	s0,48(sp)
 4ce:	74a2                	ld	s1,40(sp)
 4d0:	7902                	ld	s2,32(sp)
 4d2:	69e2                	ld	s3,24(sp)
 4d4:	6121                	addi	sp,sp,64
 4d6:	8082                	ret
    x = -xx;
 4d8:	40b005bb          	negw	a1,a1
    neg = 1;
 4dc:	4885                	li	a7,1
    x = -xx;
 4de:	bf85                	j	44e <printint+0x1a>

00000000000004e0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4e0:	7119                	addi	sp,sp,-128
 4e2:	fc86                	sd	ra,120(sp)
 4e4:	f8a2                	sd	s0,112(sp)
 4e6:	f4a6                	sd	s1,104(sp)
 4e8:	f0ca                	sd	s2,96(sp)
 4ea:	ecce                	sd	s3,88(sp)
 4ec:	e8d2                	sd	s4,80(sp)
 4ee:	e4d6                	sd	s5,72(sp)
 4f0:	e0da                	sd	s6,64(sp)
 4f2:	fc5e                	sd	s7,56(sp)
 4f4:	f862                	sd	s8,48(sp)
 4f6:	f466                	sd	s9,40(sp)
 4f8:	f06a                	sd	s10,32(sp)
 4fa:	ec6e                	sd	s11,24(sp)
 4fc:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4fe:	0005c903          	lbu	s2,0(a1)
 502:	18090f63          	beqz	s2,6a0 <vprintf+0x1c0>
 506:	8aaa                	mv	s5,a0
 508:	8b32                	mv	s6,a2
 50a:	00158493          	addi	s1,a1,1
  state = 0;
 50e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 510:	02500a13          	li	s4,37
 514:	4c55                	li	s8,21
 516:	00000c97          	auipc	s9,0x0
 51a:	3cac8c93          	addi	s9,s9,970 # 8e0 <malloc+0x13c>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 51e:	02800d93          	li	s11,40
  putc(fd, 'x');
 522:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 524:	00000b97          	auipc	s7,0x0
 528:	414b8b93          	addi	s7,s7,1044 # 938 <digits>
 52c:	a839                	j	54a <vprintf+0x6a>
        putc(fd, c);
 52e:	85ca                	mv	a1,s2
 530:	8556                	mv	a0,s5
 532:	00000097          	auipc	ra,0x0
 536:	ee0080e7          	jalr	-288(ra) # 412 <putc>
 53a:	a019                	j	540 <vprintf+0x60>
    } else if(state == '%'){
 53c:	01498d63          	beq	s3,s4,556 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 540:	0485                	addi	s1,s1,1
 542:	fff4c903          	lbu	s2,-1(s1)
 546:	14090d63          	beqz	s2,6a0 <vprintf+0x1c0>
    if(state == 0){
 54a:	fe0999e3          	bnez	s3,53c <vprintf+0x5c>
      if(c == '%'){
 54e:	ff4910e3          	bne	s2,s4,52e <vprintf+0x4e>
        state = '%';
 552:	89d2                	mv	s3,s4
 554:	b7f5                	j	540 <vprintf+0x60>
      if(c == 'd'){
 556:	11490c63          	beq	s2,s4,66e <vprintf+0x18e>
 55a:	f9d9079b          	addiw	a5,s2,-99
 55e:	0ff7f793          	zext.b	a5,a5
 562:	10fc6e63          	bltu	s8,a5,67e <vprintf+0x19e>
 566:	f9d9079b          	addiw	a5,s2,-99
 56a:	0ff7f713          	zext.b	a4,a5
 56e:	10ec6863          	bltu	s8,a4,67e <vprintf+0x19e>
 572:	00271793          	slli	a5,a4,0x2
 576:	97e6                	add	a5,a5,s9
 578:	439c                	lw	a5,0(a5)
 57a:	97e6                	add	a5,a5,s9
 57c:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 57e:	008b0913          	addi	s2,s6,8
 582:	4685                	li	a3,1
 584:	4629                	li	a2,10
 586:	000b2583          	lw	a1,0(s6)
 58a:	8556                	mv	a0,s5
 58c:	00000097          	auipc	ra,0x0
 590:	ea8080e7          	jalr	-344(ra) # 434 <printint>
 594:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 596:	4981                	li	s3,0
 598:	b765                	j	540 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 59a:	008b0913          	addi	s2,s6,8
 59e:	4681                	li	a3,0
 5a0:	4629                	li	a2,10
 5a2:	000b2583          	lw	a1,0(s6)
 5a6:	8556                	mv	a0,s5
 5a8:	00000097          	auipc	ra,0x0
 5ac:	e8c080e7          	jalr	-372(ra) # 434 <printint>
 5b0:	8b4a                	mv	s6,s2
      state = 0;
 5b2:	4981                	li	s3,0
 5b4:	b771                	j	540 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5b6:	008b0913          	addi	s2,s6,8
 5ba:	4681                	li	a3,0
 5bc:	866a                	mv	a2,s10
 5be:	000b2583          	lw	a1,0(s6)
 5c2:	8556                	mv	a0,s5
 5c4:	00000097          	auipc	ra,0x0
 5c8:	e70080e7          	jalr	-400(ra) # 434 <printint>
 5cc:	8b4a                	mv	s6,s2
      state = 0;
 5ce:	4981                	li	s3,0
 5d0:	bf85                	j	540 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 5d2:	008b0793          	addi	a5,s6,8
 5d6:	f8f43423          	sd	a5,-120(s0)
 5da:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 5de:	03000593          	li	a1,48
 5e2:	8556                	mv	a0,s5
 5e4:	00000097          	auipc	ra,0x0
 5e8:	e2e080e7          	jalr	-466(ra) # 412 <putc>
  putc(fd, 'x');
 5ec:	07800593          	li	a1,120
 5f0:	8556                	mv	a0,s5
 5f2:	00000097          	auipc	ra,0x0
 5f6:	e20080e7          	jalr	-480(ra) # 412 <putc>
 5fa:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5fc:	03c9d793          	srli	a5,s3,0x3c
 600:	97de                	add	a5,a5,s7
 602:	0007c583          	lbu	a1,0(a5)
 606:	8556                	mv	a0,s5
 608:	00000097          	auipc	ra,0x0
 60c:	e0a080e7          	jalr	-502(ra) # 412 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 610:	0992                	slli	s3,s3,0x4
 612:	397d                	addiw	s2,s2,-1
 614:	fe0914e3          	bnez	s2,5fc <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 618:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 61c:	4981                	li	s3,0
 61e:	b70d                	j	540 <vprintf+0x60>
        s = va_arg(ap, char*);
 620:	008b0913          	addi	s2,s6,8
 624:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 628:	02098163          	beqz	s3,64a <vprintf+0x16a>
        while(*s != 0){
 62c:	0009c583          	lbu	a1,0(s3)
 630:	c5ad                	beqz	a1,69a <vprintf+0x1ba>
          putc(fd, *s);
 632:	8556                	mv	a0,s5
 634:	00000097          	auipc	ra,0x0
 638:	dde080e7          	jalr	-546(ra) # 412 <putc>
          s++;
 63c:	0985                	addi	s3,s3,1
        while(*s != 0){
 63e:	0009c583          	lbu	a1,0(s3)
 642:	f9e5                	bnez	a1,632 <vprintf+0x152>
        s = va_arg(ap, char*);
 644:	8b4a                	mv	s6,s2
      state = 0;
 646:	4981                	li	s3,0
 648:	bde5                	j	540 <vprintf+0x60>
          s = "(null)";
 64a:	00000997          	auipc	s3,0x0
 64e:	28e98993          	addi	s3,s3,654 # 8d8 <malloc+0x134>
        while(*s != 0){
 652:	85ee                	mv	a1,s11
 654:	bff9                	j	632 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 656:	008b0913          	addi	s2,s6,8
 65a:	000b4583          	lbu	a1,0(s6)
 65e:	8556                	mv	a0,s5
 660:	00000097          	auipc	ra,0x0
 664:	db2080e7          	jalr	-590(ra) # 412 <putc>
 668:	8b4a                	mv	s6,s2
      state = 0;
 66a:	4981                	li	s3,0
 66c:	bdd1                	j	540 <vprintf+0x60>
        putc(fd, c);
 66e:	85d2                	mv	a1,s4
 670:	8556                	mv	a0,s5
 672:	00000097          	auipc	ra,0x0
 676:	da0080e7          	jalr	-608(ra) # 412 <putc>
      state = 0;
 67a:	4981                	li	s3,0
 67c:	b5d1                	j	540 <vprintf+0x60>
        putc(fd, '%');
 67e:	85d2                	mv	a1,s4
 680:	8556                	mv	a0,s5
 682:	00000097          	auipc	ra,0x0
 686:	d90080e7          	jalr	-624(ra) # 412 <putc>
        putc(fd, c);
 68a:	85ca                	mv	a1,s2
 68c:	8556                	mv	a0,s5
 68e:	00000097          	auipc	ra,0x0
 692:	d84080e7          	jalr	-636(ra) # 412 <putc>
      state = 0;
 696:	4981                	li	s3,0
 698:	b565                	j	540 <vprintf+0x60>
        s = va_arg(ap, char*);
 69a:	8b4a                	mv	s6,s2
      state = 0;
 69c:	4981                	li	s3,0
 69e:	b54d                	j	540 <vprintf+0x60>
    }
  }
}
 6a0:	70e6                	ld	ra,120(sp)
 6a2:	7446                	ld	s0,112(sp)
 6a4:	74a6                	ld	s1,104(sp)
 6a6:	7906                	ld	s2,96(sp)
 6a8:	69e6                	ld	s3,88(sp)
 6aa:	6a46                	ld	s4,80(sp)
 6ac:	6aa6                	ld	s5,72(sp)
 6ae:	6b06                	ld	s6,64(sp)
 6b0:	7be2                	ld	s7,56(sp)
 6b2:	7c42                	ld	s8,48(sp)
 6b4:	7ca2                	ld	s9,40(sp)
 6b6:	7d02                	ld	s10,32(sp)
 6b8:	6de2                	ld	s11,24(sp)
 6ba:	6109                	addi	sp,sp,128
 6bc:	8082                	ret

00000000000006be <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6be:	715d                	addi	sp,sp,-80
 6c0:	ec06                	sd	ra,24(sp)
 6c2:	e822                	sd	s0,16(sp)
 6c4:	1000                	addi	s0,sp,32
 6c6:	e010                	sd	a2,0(s0)
 6c8:	e414                	sd	a3,8(s0)
 6ca:	e818                	sd	a4,16(s0)
 6cc:	ec1c                	sd	a5,24(s0)
 6ce:	03043023          	sd	a6,32(s0)
 6d2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6d6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6da:	8622                	mv	a2,s0
 6dc:	00000097          	auipc	ra,0x0
 6e0:	e04080e7          	jalr	-508(ra) # 4e0 <vprintf>
}
 6e4:	60e2                	ld	ra,24(sp)
 6e6:	6442                	ld	s0,16(sp)
 6e8:	6161                	addi	sp,sp,80
 6ea:	8082                	ret

00000000000006ec <printf>:

void
printf(const char *fmt, ...)
{
 6ec:	711d                	addi	sp,sp,-96
 6ee:	ec06                	sd	ra,24(sp)
 6f0:	e822                	sd	s0,16(sp)
 6f2:	1000                	addi	s0,sp,32
 6f4:	e40c                	sd	a1,8(s0)
 6f6:	e810                	sd	a2,16(s0)
 6f8:	ec14                	sd	a3,24(s0)
 6fa:	f018                	sd	a4,32(s0)
 6fc:	f41c                	sd	a5,40(s0)
 6fe:	03043823          	sd	a6,48(s0)
 702:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 706:	00840613          	addi	a2,s0,8
 70a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 70e:	85aa                	mv	a1,a0
 710:	4505                	li	a0,1
 712:	00000097          	auipc	ra,0x0
 716:	dce080e7          	jalr	-562(ra) # 4e0 <vprintf>
}
 71a:	60e2                	ld	ra,24(sp)
 71c:	6442                	ld	s0,16(sp)
 71e:	6125                	addi	sp,sp,96
 720:	8082                	ret

0000000000000722 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 722:	1141                	addi	sp,sp,-16
 724:	e422                	sd	s0,8(sp)
 726:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 728:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 72c:	00000797          	auipc	a5,0x0
 730:	2247b783          	ld	a5,548(a5) # 950 <freep>
 734:	a02d                	j	75e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 736:	4618                	lw	a4,8(a2)
 738:	9f2d                	addw	a4,a4,a1
 73a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 73e:	6398                	ld	a4,0(a5)
 740:	6310                	ld	a2,0(a4)
 742:	a83d                	j	780 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 744:	ff852703          	lw	a4,-8(a0)
 748:	9f31                	addw	a4,a4,a2
 74a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 74c:	ff053683          	ld	a3,-16(a0)
 750:	a091                	j	794 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 752:	6398                	ld	a4,0(a5)
 754:	00e7e463          	bltu	a5,a4,75c <free+0x3a>
 758:	00e6ea63          	bltu	a3,a4,76c <free+0x4a>
{
 75c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 75e:	fed7fae3          	bgeu	a5,a3,752 <free+0x30>
 762:	6398                	ld	a4,0(a5)
 764:	00e6e463          	bltu	a3,a4,76c <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 768:	fee7eae3          	bltu	a5,a4,75c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 76c:	ff852583          	lw	a1,-8(a0)
 770:	6390                	ld	a2,0(a5)
 772:	02059813          	slli	a6,a1,0x20
 776:	01c85713          	srli	a4,a6,0x1c
 77a:	9736                	add	a4,a4,a3
 77c:	fae60de3          	beq	a2,a4,736 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 780:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 784:	4790                	lw	a2,8(a5)
 786:	02061593          	slli	a1,a2,0x20
 78a:	01c5d713          	srli	a4,a1,0x1c
 78e:	973e                	add	a4,a4,a5
 790:	fae68ae3          	beq	a3,a4,744 <free+0x22>
    p->s.ptr = bp->s.ptr;
 794:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 796:	00000717          	auipc	a4,0x0
 79a:	1af73d23          	sd	a5,442(a4) # 950 <freep>
}
 79e:	6422                	ld	s0,8(sp)
 7a0:	0141                	addi	sp,sp,16
 7a2:	8082                	ret

00000000000007a4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7a4:	7139                	addi	sp,sp,-64
 7a6:	fc06                	sd	ra,56(sp)
 7a8:	f822                	sd	s0,48(sp)
 7aa:	f426                	sd	s1,40(sp)
 7ac:	f04a                	sd	s2,32(sp)
 7ae:	ec4e                	sd	s3,24(sp)
 7b0:	e852                	sd	s4,16(sp)
 7b2:	e456                	sd	s5,8(sp)
 7b4:	e05a                	sd	s6,0(sp)
 7b6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7b8:	02051493          	slli	s1,a0,0x20
 7bc:	9081                	srli	s1,s1,0x20
 7be:	04bd                	addi	s1,s1,15
 7c0:	8091                	srli	s1,s1,0x4
 7c2:	0014899b          	addiw	s3,s1,1
 7c6:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7c8:	00000517          	auipc	a0,0x0
 7cc:	18853503          	ld	a0,392(a0) # 950 <freep>
 7d0:	c515                	beqz	a0,7fc <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7d2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7d4:	4798                	lw	a4,8(a5)
 7d6:	02977f63          	bgeu	a4,s1,814 <malloc+0x70>
 7da:	8a4e                	mv	s4,s3
 7dc:	0009871b          	sext.w	a4,s3
 7e0:	6685                	lui	a3,0x1
 7e2:	00d77363          	bgeu	a4,a3,7e8 <malloc+0x44>
 7e6:	6a05                	lui	s4,0x1
 7e8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7ec:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7f0:	00000917          	auipc	s2,0x0
 7f4:	16090913          	addi	s2,s2,352 # 950 <freep>
  if(p == (char*)-1)
 7f8:	5afd                	li	s5,-1
 7fa:	a895                	j	86e <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 7fc:	00002797          	auipc	a5,0x2
 800:	09c78793          	addi	a5,a5,156 # 2898 <base>
 804:	00000717          	auipc	a4,0x0
 808:	14f73623          	sd	a5,332(a4) # 950 <freep>
 80c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 80e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 812:	b7e1                	j	7da <malloc+0x36>
      if(p->s.size == nunits)
 814:	02e48c63          	beq	s1,a4,84c <malloc+0xa8>
        p->s.size -= nunits;
 818:	4137073b          	subw	a4,a4,s3
 81c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 81e:	02071693          	slli	a3,a4,0x20
 822:	01c6d713          	srli	a4,a3,0x1c
 826:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 828:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 82c:	00000717          	auipc	a4,0x0
 830:	12a73223          	sd	a0,292(a4) # 950 <freep>
      return (void*)(p + 1);
 834:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 838:	70e2                	ld	ra,56(sp)
 83a:	7442                	ld	s0,48(sp)
 83c:	74a2                	ld	s1,40(sp)
 83e:	7902                	ld	s2,32(sp)
 840:	69e2                	ld	s3,24(sp)
 842:	6a42                	ld	s4,16(sp)
 844:	6aa2                	ld	s5,8(sp)
 846:	6b02                	ld	s6,0(sp)
 848:	6121                	addi	sp,sp,64
 84a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 84c:	6398                	ld	a4,0(a5)
 84e:	e118                	sd	a4,0(a0)
 850:	bff1                	j	82c <malloc+0x88>
  hp->s.size = nu;
 852:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 856:	0541                	addi	a0,a0,16
 858:	00000097          	auipc	ra,0x0
 85c:	eca080e7          	jalr	-310(ra) # 722 <free>
  return freep;
 860:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 864:	d971                	beqz	a0,838 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 866:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 868:	4798                	lw	a4,8(a5)
 86a:	fa9775e3          	bgeu	a4,s1,814 <malloc+0x70>
    if(p == freep)
 86e:	00093703          	ld	a4,0(s2)
 872:	853e                	mv	a0,a5
 874:	fef719e3          	bne	a4,a5,866 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 878:	8552                	mv	a0,s4
 87a:	00000097          	auipc	ra,0x0
 87e:	b58080e7          	jalr	-1192(ra) # 3d2 <sbrk>
  if(p == (char*)-1)
 882:	fd5518e3          	bne	a0,s5,852 <malloc+0xae>
        return 0;
 886:	4501                	li	a0,0
 888:	bf45                	j	838 <malloc+0x94>
