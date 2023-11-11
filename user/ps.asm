
user/_ps:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/pstat.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
   0:	81010113          	addi	sp,sp,-2032
   4:	7e113423          	sd	ra,2024(sp)
   8:	7e813023          	sd	s0,2016(sp)
   c:	7c913c23          	sd	s1,2008(sp)
  10:	7d213823          	sd	s2,2000(sp)
  14:	7d313423          	sd	s3,1992(sp)
  18:	7d413023          	sd	s4,1984(sp)
  1c:	7b513c23          	sd	s5,1976(sp)
  20:	7b613823          	sd	s6,1968(sp)
  24:	7b713423          	sd	s7,1960(sp)
  28:	7b813023          	sd	s8,1952(sp)
  2c:	79913c23          	sd	s9,1944(sp)
  30:	79a13823          	sd	s10,1936(sp)
  34:	79b13423          	sd	s11,1928(sp)
  38:	7f010413          	addi	s0,sp,2032
  3c:	97010113          	addi	sp,sp,-1680
    [RUNNABLE]  "runnable",
    [RUNNING]   "running ",
    [ZOMBIE]    "zombie  "
  };

  nprocs = getprocs(uproc);
  40:	757d                	lui	a0,0xfffff
  42:	19050793          	addi	a5,a0,400 # fffffffffffff190 <__global_pointer$+0xffffffffffffdf5f>
  46:	00878533          	add	a0,a5,s0
  4a:	00000097          	auipc	ra,0x0
  4e:	3fe080e7          	jalr	1022(ra) # 448 <getprocs>
  if (nprocs < 0)
  52:	04054c63          	bltz	a0,aa <main+0xaa>
  56:	892a                	mv	s2,a0
    exit(-1);
 
  printf("pid\tstate\t\tsize\tppid\tname\tpriority\tcputime\tage\n");
  58:	00001517          	auipc	a0,0x1
  5c:	89050513          	addi	a0,a0,-1904 # 8e8 <malloc+0xe6>
  60:	00000097          	auipc	ra,0x0
  64:	6ea080e7          	jalr	1770(ra) # 74a <printf>
  for (i=0; i<nprocs; i++) {
  68:	0d205563          	blez	s2,132 <main+0x132>
  6c:	77fd                	lui	a5,0xfffff
  6e:	19078793          	addi	a5,a5,400 # fffffffffffff190 <__global_pointer$+0xffffffffffffdf5f>
  72:	97a2                	add	a5,a5,s0
  74:	01c78493          	addi	s1,a5,28
  78:	397d                	addiw	s2,s2,-1
  7a:	1902                	slli	s2,s2,0x20
  7c:	02095913          	srli	s2,s2,0x20
  80:	03800713          	li	a4,56
  84:	02e90933          	mul	s2,s2,a4
  88:	05478793          	addi	a5,a5,84
  8c:	993e                	add	s2,s2,a5
    state = states[uproc[i].state];
  8e:	00001a17          	auipc	s4,0x1
  92:	902a0a13          	addi	s4,s4,-1790 # 990 <states.0>
    
    if(uproc[i].state == RUNNING){
  96:	4991                	li	s3,4
    	printf("%d\t%s\t%l\t%d\t%s\t%d\t%d\t%d\n", uproc[i].pid, state,
                   uproc[i].size, uproc[i].ppid, uproc[i].name, uproc[i].priority, uproc[i].cputime, (uptime() - uproc[i].readytime));
    }
    else{
        printf("%d\t%s\t%l\t%d\t%s\t%d\t%d\n", uproc[i].pid, state, 
  98:	00001a97          	auipc	s5,0x1
  9c:	8b0a8a93          	addi	s5,s5,-1872 # 948 <malloc+0x146>
    	printf("%d\t%s\t%l\t%d\t%s\t%d\t%d\t%d\n", uproc[i].pid, state,
  a0:	00001d97          	auipc	s11,0x1
  a4:	878d8d93          	addi	s11,s11,-1928 # 918 <malloc+0x116>
  a8:	a815                	j	dc <main+0xdc>
    exit(-1);
  aa:	557d                	li	a0,-1
  ac:	00000097          	auipc	ra,0x0
  b0:	2fc080e7          	jalr	764(ra) # 3a8 <exit>
        printf("%d\t%s\t%l\t%d\t%s\t%d\t%d\n", uproc[i].pid, state, 
  b4:	0144a883          	lw	a7,20(s1)
  b8:	fe84a803          	lw	a6,-24(s1)
  bc:	87a6                	mv	a5,s1
  be:	ffc4a703          	lw	a4,-4(s1)
  c2:	ff44b683          	ld	a3,-12(s1)
  c6:	fe44a583          	lw	a1,-28(s1)
  ca:	8556                	mv	a0,s5
  cc:	00000097          	auipc	ra,0x0
  d0:	67e080e7          	jalr	1662(ra) # 74a <printf>
  for (i=0; i<nprocs; i++) {
  d4:	03848493          	addi	s1,s1,56
  d8:	05248d63          	beq	s1,s2,132 <main+0x132>
    state = states[uproc[i].state];
  dc:	fec4a703          	lw	a4,-20(s1)
  e0:	02071693          	slli	a3,a4,0x20
  e4:	01d6d793          	srli	a5,a3,0x1d
  e8:	97d2                	add	a5,a5,s4
  ea:	6390                	ld	a2,0(a5)
    if(uproc[i].state == RUNNING){
  ec:	fd3714e3          	bne	a4,s3,b4 <main+0xb4>
    	printf("%d\t%s\t%l\t%d\t%s\t%d\t%d\t%d\n", uproc[i].pid, state,
  f0:	fe44ab03          	lw	s6,-28(s1)
  f4:	ff44bb83          	ld	s7,-12(s1)
  f8:	ffc4ac03          	lw	s8,-4(s1)
  fc:	fe84ac83          	lw	s9,-24(s1)
 100:	0144ad03          	lw	s10,20(s1)
                   uproc[i].size, uproc[i].ppid, uproc[i].name, uproc[i].priority, uproc[i].cputime, (uptime() - uproc[i].readytime));
 104:	00000097          	auipc	ra,0x0
 108:	33c080e7          	jalr	828(ra) # 440 <uptime>
    	printf("%d\t%s\t%l\t%d\t%s\t%d\t%d\t%d\n", uproc[i].pid, state,
 10c:	489c                	lw	a5,16(s1)
 10e:	9d1d                	subw	a0,a0,a5
 110:	e02a                	sd	a0,0(sp)
 112:	88ea                	mv	a7,s10
 114:	8866                	mv	a6,s9
 116:	87a6                	mv	a5,s1
 118:	8762                	mv	a4,s8
 11a:	86de                	mv	a3,s7
 11c:	866e                	mv	a2,s11
 11e:	85da                	mv	a1,s6
 120:	00001517          	auipc	a0,0x1
 124:	80850513          	addi	a0,a0,-2040 # 928 <malloc+0x126>
 128:	00000097          	auipc	ra,0x0
 12c:	622080e7          	jalr	1570(ra) # 74a <printf>
 130:	b755                	j	d4 <main+0xd4>
        	   uproc[i].size, uproc[i].ppid, uproc[i].name, uproc[i].priority, uproc[i].cputime);
    }
  }

  exit(0);
 132:	4501                	li	a0,0
 134:	00000097          	auipc	ra,0x0
 138:	274080e7          	jalr	628(ra) # 3a8 <exit>

000000000000013c <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 13c:	1141                	addi	sp,sp,-16
 13e:	e422                	sd	s0,8(sp)
 140:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 142:	87aa                	mv	a5,a0
 144:	0585                	addi	a1,a1,1
 146:	0785                	addi	a5,a5,1
 148:	fff5c703          	lbu	a4,-1(a1)
 14c:	fee78fa3          	sb	a4,-1(a5)
 150:	fb75                	bnez	a4,144 <strcpy+0x8>
    ;
  return os;
}
 152:	6422                	ld	s0,8(sp)
 154:	0141                	addi	sp,sp,16
 156:	8082                	ret

0000000000000158 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 158:	1141                	addi	sp,sp,-16
 15a:	e422                	sd	s0,8(sp)
 15c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 15e:	00054783          	lbu	a5,0(a0)
 162:	cb91                	beqz	a5,176 <strcmp+0x1e>
 164:	0005c703          	lbu	a4,0(a1)
 168:	00f71763          	bne	a4,a5,176 <strcmp+0x1e>
    p++, q++;
 16c:	0505                	addi	a0,a0,1
 16e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 170:	00054783          	lbu	a5,0(a0)
 174:	fbe5                	bnez	a5,164 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 176:	0005c503          	lbu	a0,0(a1)
}
 17a:	40a7853b          	subw	a0,a5,a0
 17e:	6422                	ld	s0,8(sp)
 180:	0141                	addi	sp,sp,16
 182:	8082                	ret

0000000000000184 <strlen>:

uint
strlen(const char *s)
{
 184:	1141                	addi	sp,sp,-16
 186:	e422                	sd	s0,8(sp)
 188:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 18a:	00054783          	lbu	a5,0(a0)
 18e:	cf91                	beqz	a5,1aa <strlen+0x26>
 190:	0505                	addi	a0,a0,1
 192:	87aa                	mv	a5,a0
 194:	4685                	li	a3,1
 196:	9e89                	subw	a3,a3,a0
 198:	00f6853b          	addw	a0,a3,a5
 19c:	0785                	addi	a5,a5,1
 19e:	fff7c703          	lbu	a4,-1(a5)
 1a2:	fb7d                	bnez	a4,198 <strlen+0x14>
    ;
  return n;
}
 1a4:	6422                	ld	s0,8(sp)
 1a6:	0141                	addi	sp,sp,16
 1a8:	8082                	ret
  for(n = 0; s[n]; n++)
 1aa:	4501                	li	a0,0
 1ac:	bfe5                	j	1a4 <strlen+0x20>

00000000000001ae <memset>:

void*
memset(void *dst, int c, uint n)
{
 1ae:	1141                	addi	sp,sp,-16
 1b0:	e422                	sd	s0,8(sp)
 1b2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1b4:	ca19                	beqz	a2,1ca <memset+0x1c>
 1b6:	87aa                	mv	a5,a0
 1b8:	1602                	slli	a2,a2,0x20
 1ba:	9201                	srli	a2,a2,0x20
 1bc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1c0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1c4:	0785                	addi	a5,a5,1
 1c6:	fee79de3          	bne	a5,a4,1c0 <memset+0x12>
  }
  return dst;
}
 1ca:	6422                	ld	s0,8(sp)
 1cc:	0141                	addi	sp,sp,16
 1ce:	8082                	ret

00000000000001d0 <strchr>:

char*
strchr(const char *s, char c)
{
 1d0:	1141                	addi	sp,sp,-16
 1d2:	e422                	sd	s0,8(sp)
 1d4:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1d6:	00054783          	lbu	a5,0(a0)
 1da:	cb99                	beqz	a5,1f0 <strchr+0x20>
    if(*s == c)
 1dc:	00f58763          	beq	a1,a5,1ea <strchr+0x1a>
  for(; *s; s++)
 1e0:	0505                	addi	a0,a0,1
 1e2:	00054783          	lbu	a5,0(a0)
 1e6:	fbfd                	bnez	a5,1dc <strchr+0xc>
      return (char*)s;
  return 0;
 1e8:	4501                	li	a0,0
}
 1ea:	6422                	ld	s0,8(sp)
 1ec:	0141                	addi	sp,sp,16
 1ee:	8082                	ret
  return 0;
 1f0:	4501                	li	a0,0
 1f2:	bfe5                	j	1ea <strchr+0x1a>

00000000000001f4 <gets>:

char*
gets(char *buf, int max)
{
 1f4:	711d                	addi	sp,sp,-96
 1f6:	ec86                	sd	ra,88(sp)
 1f8:	e8a2                	sd	s0,80(sp)
 1fa:	e4a6                	sd	s1,72(sp)
 1fc:	e0ca                	sd	s2,64(sp)
 1fe:	fc4e                	sd	s3,56(sp)
 200:	f852                	sd	s4,48(sp)
 202:	f456                	sd	s5,40(sp)
 204:	f05a                	sd	s6,32(sp)
 206:	ec5e                	sd	s7,24(sp)
 208:	1080                	addi	s0,sp,96
 20a:	8baa                	mv	s7,a0
 20c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 20e:	892a                	mv	s2,a0
 210:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 212:	4aa9                	li	s5,10
 214:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 216:	89a6                	mv	s3,s1
 218:	2485                	addiw	s1,s1,1
 21a:	0344d863          	bge	s1,s4,24a <gets+0x56>
    cc = read(0, &c, 1);
 21e:	4605                	li	a2,1
 220:	faf40593          	addi	a1,s0,-81
 224:	4501                	li	a0,0
 226:	00000097          	auipc	ra,0x0
 22a:	19a080e7          	jalr	410(ra) # 3c0 <read>
    if(cc < 1)
 22e:	00a05e63          	blez	a0,24a <gets+0x56>
    buf[i++] = c;
 232:	faf44783          	lbu	a5,-81(s0)
 236:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 23a:	01578763          	beq	a5,s5,248 <gets+0x54>
 23e:	0905                	addi	s2,s2,1
 240:	fd679be3          	bne	a5,s6,216 <gets+0x22>
  for(i=0; i+1 < max; ){
 244:	89a6                	mv	s3,s1
 246:	a011                	j	24a <gets+0x56>
 248:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 24a:	99de                	add	s3,s3,s7
 24c:	00098023          	sb	zero,0(s3)
  return buf;
}
 250:	855e                	mv	a0,s7
 252:	60e6                	ld	ra,88(sp)
 254:	6446                	ld	s0,80(sp)
 256:	64a6                	ld	s1,72(sp)
 258:	6906                	ld	s2,64(sp)
 25a:	79e2                	ld	s3,56(sp)
 25c:	7a42                	ld	s4,48(sp)
 25e:	7aa2                	ld	s5,40(sp)
 260:	7b02                	ld	s6,32(sp)
 262:	6be2                	ld	s7,24(sp)
 264:	6125                	addi	sp,sp,96
 266:	8082                	ret

0000000000000268 <stat>:

int
stat(const char *n, struct stat *st)
{
 268:	1101                	addi	sp,sp,-32
 26a:	ec06                	sd	ra,24(sp)
 26c:	e822                	sd	s0,16(sp)
 26e:	e426                	sd	s1,8(sp)
 270:	e04a                	sd	s2,0(sp)
 272:	1000                	addi	s0,sp,32
 274:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 276:	4581                	li	a1,0
 278:	00000097          	auipc	ra,0x0
 27c:	170080e7          	jalr	368(ra) # 3e8 <open>
  if(fd < 0)
 280:	02054563          	bltz	a0,2aa <stat+0x42>
 284:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 286:	85ca                	mv	a1,s2
 288:	00000097          	auipc	ra,0x0
 28c:	178080e7          	jalr	376(ra) # 400 <fstat>
 290:	892a                	mv	s2,a0
  close(fd);
 292:	8526                	mv	a0,s1
 294:	00000097          	auipc	ra,0x0
 298:	13c080e7          	jalr	316(ra) # 3d0 <close>
  return r;
}
 29c:	854a                	mv	a0,s2
 29e:	60e2                	ld	ra,24(sp)
 2a0:	6442                	ld	s0,16(sp)
 2a2:	64a2                	ld	s1,8(sp)
 2a4:	6902                	ld	s2,0(sp)
 2a6:	6105                	addi	sp,sp,32
 2a8:	8082                	ret
    return -1;
 2aa:	597d                	li	s2,-1
 2ac:	bfc5                	j	29c <stat+0x34>

00000000000002ae <atoi>:

int
atoi(const char *s)
{
 2ae:	1141                	addi	sp,sp,-16
 2b0:	e422                	sd	s0,8(sp)
 2b2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2b4:	00054683          	lbu	a3,0(a0)
 2b8:	fd06879b          	addiw	a5,a3,-48
 2bc:	0ff7f793          	zext.b	a5,a5
 2c0:	4625                	li	a2,9
 2c2:	02f66863          	bltu	a2,a5,2f2 <atoi+0x44>
 2c6:	872a                	mv	a4,a0
  n = 0;
 2c8:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2ca:	0705                	addi	a4,a4,1
 2cc:	0025179b          	slliw	a5,a0,0x2
 2d0:	9fa9                	addw	a5,a5,a0
 2d2:	0017979b          	slliw	a5,a5,0x1
 2d6:	9fb5                	addw	a5,a5,a3
 2d8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2dc:	00074683          	lbu	a3,0(a4)
 2e0:	fd06879b          	addiw	a5,a3,-48
 2e4:	0ff7f793          	zext.b	a5,a5
 2e8:	fef671e3          	bgeu	a2,a5,2ca <atoi+0x1c>
  return n;
}
 2ec:	6422                	ld	s0,8(sp)
 2ee:	0141                	addi	sp,sp,16
 2f0:	8082                	ret
  n = 0;
 2f2:	4501                	li	a0,0
 2f4:	bfe5                	j	2ec <atoi+0x3e>

00000000000002f6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2f6:	1141                	addi	sp,sp,-16
 2f8:	e422                	sd	s0,8(sp)
 2fa:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2fc:	02b57463          	bgeu	a0,a1,324 <memmove+0x2e>
    while(n-- > 0)
 300:	00c05f63          	blez	a2,31e <memmove+0x28>
 304:	1602                	slli	a2,a2,0x20
 306:	9201                	srli	a2,a2,0x20
 308:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 30c:	872a                	mv	a4,a0
      *dst++ = *src++;
 30e:	0585                	addi	a1,a1,1
 310:	0705                	addi	a4,a4,1
 312:	fff5c683          	lbu	a3,-1(a1)
 316:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 31a:	fee79ae3          	bne	a5,a4,30e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 31e:	6422                	ld	s0,8(sp)
 320:	0141                	addi	sp,sp,16
 322:	8082                	ret
    dst += n;
 324:	00c50733          	add	a4,a0,a2
    src += n;
 328:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 32a:	fec05ae3          	blez	a2,31e <memmove+0x28>
 32e:	fff6079b          	addiw	a5,a2,-1
 332:	1782                	slli	a5,a5,0x20
 334:	9381                	srli	a5,a5,0x20
 336:	fff7c793          	not	a5,a5
 33a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 33c:	15fd                	addi	a1,a1,-1
 33e:	177d                	addi	a4,a4,-1
 340:	0005c683          	lbu	a3,0(a1)
 344:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 348:	fee79ae3          	bne	a5,a4,33c <memmove+0x46>
 34c:	bfc9                	j	31e <memmove+0x28>

000000000000034e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 34e:	1141                	addi	sp,sp,-16
 350:	e422                	sd	s0,8(sp)
 352:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 354:	ca05                	beqz	a2,384 <memcmp+0x36>
 356:	fff6069b          	addiw	a3,a2,-1
 35a:	1682                	slli	a3,a3,0x20
 35c:	9281                	srli	a3,a3,0x20
 35e:	0685                	addi	a3,a3,1
 360:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 362:	00054783          	lbu	a5,0(a0)
 366:	0005c703          	lbu	a4,0(a1)
 36a:	00e79863          	bne	a5,a4,37a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 36e:	0505                	addi	a0,a0,1
    p2++;
 370:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 372:	fed518e3          	bne	a0,a3,362 <memcmp+0x14>
  }
  return 0;
 376:	4501                	li	a0,0
 378:	a019                	j	37e <memcmp+0x30>
      return *p1 - *p2;
 37a:	40e7853b          	subw	a0,a5,a4
}
 37e:	6422                	ld	s0,8(sp)
 380:	0141                	addi	sp,sp,16
 382:	8082                	ret
  return 0;
 384:	4501                	li	a0,0
 386:	bfe5                	j	37e <memcmp+0x30>

0000000000000388 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 388:	1141                	addi	sp,sp,-16
 38a:	e406                	sd	ra,8(sp)
 38c:	e022                	sd	s0,0(sp)
 38e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 390:	00000097          	auipc	ra,0x0
 394:	f66080e7          	jalr	-154(ra) # 2f6 <memmove>
}
 398:	60a2                	ld	ra,8(sp)
 39a:	6402                	ld	s0,0(sp)
 39c:	0141                	addi	sp,sp,16
 39e:	8082                	ret

00000000000003a0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3a0:	4885                	li	a7,1
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3a8:	4889                	li	a7,2
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3b0:	488d                	li	a7,3
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3b8:	4891                	li	a7,4
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <read>:
.global read
read:
 li a7, SYS_read
 3c0:	4895                	li	a7,5
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <write>:
.global write
write:
 li a7, SYS_write
 3c8:	48c1                	li	a7,16
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <close>:
.global close
close:
 li a7, SYS_close
 3d0:	48d5                	li	a7,21
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3d8:	4899                	li	a7,6
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3e0:	489d                	li	a7,7
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <open>:
.global open
open:
 li a7, SYS_open
 3e8:	48bd                	li	a7,15
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3f0:	48c5                	li	a7,17
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3f8:	48c9                	li	a7,18
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 400:	48a1                	li	a7,8
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <link>:
.global link
link:
 li a7, SYS_link
 408:	48cd                	li	a7,19
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 410:	48d1                	li	a7,20
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 418:	48a5                	li	a7,9
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <dup>:
.global dup
dup:
 li a7, SYS_dup
 420:	48a9                	li	a7,10
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 428:	48ad                	li	a7,11
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 430:	48b1                	li	a7,12
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 438:	48b5                	li	a7,13
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 440:	48b9                	li	a7,14
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <getprocs>:
.global getprocs
getprocs:
 li a7, SYS_getprocs
 448:	48d9                	li	a7,22
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <wait2>:
.global wait2
wait2:
 li a7, SYS_wait2
 450:	48dd                	li	a7,23
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
 458:	48e5                	li	a7,25
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <getpriority>:
.global getpriority
getpriority:
 li a7, SYS_getpriority
 460:	48e1                	li	a7,24
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <freepmem>:
.global freepmem
freepmem:
 li a7, SYS_freepmem
 468:	48e9                	li	a7,26
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 470:	1101                	addi	sp,sp,-32
 472:	ec06                	sd	ra,24(sp)
 474:	e822                	sd	s0,16(sp)
 476:	1000                	addi	s0,sp,32
 478:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 47c:	4605                	li	a2,1
 47e:	fef40593          	addi	a1,s0,-17
 482:	00000097          	auipc	ra,0x0
 486:	f46080e7          	jalr	-186(ra) # 3c8 <write>
}
 48a:	60e2                	ld	ra,24(sp)
 48c:	6442                	ld	s0,16(sp)
 48e:	6105                	addi	sp,sp,32
 490:	8082                	ret

0000000000000492 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 492:	7139                	addi	sp,sp,-64
 494:	fc06                	sd	ra,56(sp)
 496:	f822                	sd	s0,48(sp)
 498:	f426                	sd	s1,40(sp)
 49a:	f04a                	sd	s2,32(sp)
 49c:	ec4e                	sd	s3,24(sp)
 49e:	0080                	addi	s0,sp,64
 4a0:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4a2:	c299                	beqz	a3,4a8 <printint+0x16>
 4a4:	0805c963          	bltz	a1,536 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4a8:	2581                	sext.w	a1,a1
  neg = 0;
 4aa:	4881                	li	a7,0
 4ac:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4b0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4b2:	2601                	sext.w	a2,a2
 4b4:	00000517          	auipc	a0,0x0
 4b8:	56c50513          	addi	a0,a0,1388 # a20 <digits>
 4bc:	883a                	mv	a6,a4
 4be:	2705                	addiw	a4,a4,1
 4c0:	02c5f7bb          	remuw	a5,a1,a2
 4c4:	1782                	slli	a5,a5,0x20
 4c6:	9381                	srli	a5,a5,0x20
 4c8:	97aa                	add	a5,a5,a0
 4ca:	0007c783          	lbu	a5,0(a5)
 4ce:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4d2:	0005879b          	sext.w	a5,a1
 4d6:	02c5d5bb          	divuw	a1,a1,a2
 4da:	0685                	addi	a3,a3,1
 4dc:	fec7f0e3          	bgeu	a5,a2,4bc <printint+0x2a>
  if(neg)
 4e0:	00088c63          	beqz	a7,4f8 <printint+0x66>
    buf[i++] = '-';
 4e4:	fd070793          	addi	a5,a4,-48
 4e8:	00878733          	add	a4,a5,s0
 4ec:	02d00793          	li	a5,45
 4f0:	fef70823          	sb	a5,-16(a4)
 4f4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4f8:	02e05863          	blez	a4,528 <printint+0x96>
 4fc:	fc040793          	addi	a5,s0,-64
 500:	00e78933          	add	s2,a5,a4
 504:	fff78993          	addi	s3,a5,-1
 508:	99ba                	add	s3,s3,a4
 50a:	377d                	addiw	a4,a4,-1
 50c:	1702                	slli	a4,a4,0x20
 50e:	9301                	srli	a4,a4,0x20
 510:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 514:	fff94583          	lbu	a1,-1(s2)
 518:	8526                	mv	a0,s1
 51a:	00000097          	auipc	ra,0x0
 51e:	f56080e7          	jalr	-170(ra) # 470 <putc>
  while(--i >= 0)
 522:	197d                	addi	s2,s2,-1
 524:	ff3918e3          	bne	s2,s3,514 <printint+0x82>
}
 528:	70e2                	ld	ra,56(sp)
 52a:	7442                	ld	s0,48(sp)
 52c:	74a2                	ld	s1,40(sp)
 52e:	7902                	ld	s2,32(sp)
 530:	69e2                	ld	s3,24(sp)
 532:	6121                	addi	sp,sp,64
 534:	8082                	ret
    x = -xx;
 536:	40b005bb          	negw	a1,a1
    neg = 1;
 53a:	4885                	li	a7,1
    x = -xx;
 53c:	bf85                	j	4ac <printint+0x1a>

000000000000053e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 53e:	7119                	addi	sp,sp,-128
 540:	fc86                	sd	ra,120(sp)
 542:	f8a2                	sd	s0,112(sp)
 544:	f4a6                	sd	s1,104(sp)
 546:	f0ca                	sd	s2,96(sp)
 548:	ecce                	sd	s3,88(sp)
 54a:	e8d2                	sd	s4,80(sp)
 54c:	e4d6                	sd	s5,72(sp)
 54e:	e0da                	sd	s6,64(sp)
 550:	fc5e                	sd	s7,56(sp)
 552:	f862                	sd	s8,48(sp)
 554:	f466                	sd	s9,40(sp)
 556:	f06a                	sd	s10,32(sp)
 558:	ec6e                	sd	s11,24(sp)
 55a:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 55c:	0005c903          	lbu	s2,0(a1)
 560:	18090f63          	beqz	s2,6fe <vprintf+0x1c0>
 564:	8aaa                	mv	s5,a0
 566:	8b32                	mv	s6,a2
 568:	00158493          	addi	s1,a1,1
  state = 0;
 56c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 56e:	02500a13          	li	s4,37
 572:	4c55                	li	s8,21
 574:	00000c97          	auipc	s9,0x0
 578:	454c8c93          	addi	s9,s9,1108 # 9c8 <states.0+0x38>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 57c:	02800d93          	li	s11,40
  putc(fd, 'x');
 580:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 582:	00000b97          	auipc	s7,0x0
 586:	49eb8b93          	addi	s7,s7,1182 # a20 <digits>
 58a:	a839                	j	5a8 <vprintf+0x6a>
        putc(fd, c);
 58c:	85ca                	mv	a1,s2
 58e:	8556                	mv	a0,s5
 590:	00000097          	auipc	ra,0x0
 594:	ee0080e7          	jalr	-288(ra) # 470 <putc>
 598:	a019                	j	59e <vprintf+0x60>
    } else if(state == '%'){
 59a:	01498d63          	beq	s3,s4,5b4 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 59e:	0485                	addi	s1,s1,1
 5a0:	fff4c903          	lbu	s2,-1(s1)
 5a4:	14090d63          	beqz	s2,6fe <vprintf+0x1c0>
    if(state == 0){
 5a8:	fe0999e3          	bnez	s3,59a <vprintf+0x5c>
      if(c == '%'){
 5ac:	ff4910e3          	bne	s2,s4,58c <vprintf+0x4e>
        state = '%';
 5b0:	89d2                	mv	s3,s4
 5b2:	b7f5                	j	59e <vprintf+0x60>
      if(c == 'd'){
 5b4:	11490c63          	beq	s2,s4,6cc <vprintf+0x18e>
 5b8:	f9d9079b          	addiw	a5,s2,-99
 5bc:	0ff7f793          	zext.b	a5,a5
 5c0:	10fc6e63          	bltu	s8,a5,6dc <vprintf+0x19e>
 5c4:	f9d9079b          	addiw	a5,s2,-99
 5c8:	0ff7f713          	zext.b	a4,a5
 5cc:	10ec6863          	bltu	s8,a4,6dc <vprintf+0x19e>
 5d0:	00271793          	slli	a5,a4,0x2
 5d4:	97e6                	add	a5,a5,s9
 5d6:	439c                	lw	a5,0(a5)
 5d8:	97e6                	add	a5,a5,s9
 5da:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5dc:	008b0913          	addi	s2,s6,8
 5e0:	4685                	li	a3,1
 5e2:	4629                	li	a2,10
 5e4:	000b2583          	lw	a1,0(s6)
 5e8:	8556                	mv	a0,s5
 5ea:	00000097          	auipc	ra,0x0
 5ee:	ea8080e7          	jalr	-344(ra) # 492 <printint>
 5f2:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5f4:	4981                	li	s3,0
 5f6:	b765                	j	59e <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5f8:	008b0913          	addi	s2,s6,8
 5fc:	4681                	li	a3,0
 5fe:	4629                	li	a2,10
 600:	000b2583          	lw	a1,0(s6)
 604:	8556                	mv	a0,s5
 606:	00000097          	auipc	ra,0x0
 60a:	e8c080e7          	jalr	-372(ra) # 492 <printint>
 60e:	8b4a                	mv	s6,s2
      state = 0;
 610:	4981                	li	s3,0
 612:	b771                	j	59e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 614:	008b0913          	addi	s2,s6,8
 618:	4681                	li	a3,0
 61a:	866a                	mv	a2,s10
 61c:	000b2583          	lw	a1,0(s6)
 620:	8556                	mv	a0,s5
 622:	00000097          	auipc	ra,0x0
 626:	e70080e7          	jalr	-400(ra) # 492 <printint>
 62a:	8b4a                	mv	s6,s2
      state = 0;
 62c:	4981                	li	s3,0
 62e:	bf85                	j	59e <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 630:	008b0793          	addi	a5,s6,8
 634:	f8f43423          	sd	a5,-120(s0)
 638:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 63c:	03000593          	li	a1,48
 640:	8556                	mv	a0,s5
 642:	00000097          	auipc	ra,0x0
 646:	e2e080e7          	jalr	-466(ra) # 470 <putc>
  putc(fd, 'x');
 64a:	07800593          	li	a1,120
 64e:	8556                	mv	a0,s5
 650:	00000097          	auipc	ra,0x0
 654:	e20080e7          	jalr	-480(ra) # 470 <putc>
 658:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 65a:	03c9d793          	srli	a5,s3,0x3c
 65e:	97de                	add	a5,a5,s7
 660:	0007c583          	lbu	a1,0(a5)
 664:	8556                	mv	a0,s5
 666:	00000097          	auipc	ra,0x0
 66a:	e0a080e7          	jalr	-502(ra) # 470 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 66e:	0992                	slli	s3,s3,0x4
 670:	397d                	addiw	s2,s2,-1
 672:	fe0914e3          	bnez	s2,65a <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 676:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 67a:	4981                	li	s3,0
 67c:	b70d                	j	59e <vprintf+0x60>
        s = va_arg(ap, char*);
 67e:	008b0913          	addi	s2,s6,8
 682:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 686:	02098163          	beqz	s3,6a8 <vprintf+0x16a>
        while(*s != 0){
 68a:	0009c583          	lbu	a1,0(s3)
 68e:	c5ad                	beqz	a1,6f8 <vprintf+0x1ba>
          putc(fd, *s);
 690:	8556                	mv	a0,s5
 692:	00000097          	auipc	ra,0x0
 696:	dde080e7          	jalr	-546(ra) # 470 <putc>
          s++;
 69a:	0985                	addi	s3,s3,1
        while(*s != 0){
 69c:	0009c583          	lbu	a1,0(s3)
 6a0:	f9e5                	bnez	a1,690 <vprintf+0x152>
        s = va_arg(ap, char*);
 6a2:	8b4a                	mv	s6,s2
      state = 0;
 6a4:	4981                	li	s3,0
 6a6:	bde5                	j	59e <vprintf+0x60>
          s = "(null)";
 6a8:	00000997          	auipc	s3,0x0
 6ac:	31898993          	addi	s3,s3,792 # 9c0 <states.0+0x30>
        while(*s != 0){
 6b0:	85ee                	mv	a1,s11
 6b2:	bff9                	j	690 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 6b4:	008b0913          	addi	s2,s6,8
 6b8:	000b4583          	lbu	a1,0(s6)
 6bc:	8556                	mv	a0,s5
 6be:	00000097          	auipc	ra,0x0
 6c2:	db2080e7          	jalr	-590(ra) # 470 <putc>
 6c6:	8b4a                	mv	s6,s2
      state = 0;
 6c8:	4981                	li	s3,0
 6ca:	bdd1                	j	59e <vprintf+0x60>
        putc(fd, c);
 6cc:	85d2                	mv	a1,s4
 6ce:	8556                	mv	a0,s5
 6d0:	00000097          	auipc	ra,0x0
 6d4:	da0080e7          	jalr	-608(ra) # 470 <putc>
      state = 0;
 6d8:	4981                	li	s3,0
 6da:	b5d1                	j	59e <vprintf+0x60>
        putc(fd, '%');
 6dc:	85d2                	mv	a1,s4
 6de:	8556                	mv	a0,s5
 6e0:	00000097          	auipc	ra,0x0
 6e4:	d90080e7          	jalr	-624(ra) # 470 <putc>
        putc(fd, c);
 6e8:	85ca                	mv	a1,s2
 6ea:	8556                	mv	a0,s5
 6ec:	00000097          	auipc	ra,0x0
 6f0:	d84080e7          	jalr	-636(ra) # 470 <putc>
      state = 0;
 6f4:	4981                	li	s3,0
 6f6:	b565                	j	59e <vprintf+0x60>
        s = va_arg(ap, char*);
 6f8:	8b4a                	mv	s6,s2
      state = 0;
 6fa:	4981                	li	s3,0
 6fc:	b54d                	j	59e <vprintf+0x60>
    }
  }
}
 6fe:	70e6                	ld	ra,120(sp)
 700:	7446                	ld	s0,112(sp)
 702:	74a6                	ld	s1,104(sp)
 704:	7906                	ld	s2,96(sp)
 706:	69e6                	ld	s3,88(sp)
 708:	6a46                	ld	s4,80(sp)
 70a:	6aa6                	ld	s5,72(sp)
 70c:	6b06                	ld	s6,64(sp)
 70e:	7be2                	ld	s7,56(sp)
 710:	7c42                	ld	s8,48(sp)
 712:	7ca2                	ld	s9,40(sp)
 714:	7d02                	ld	s10,32(sp)
 716:	6de2                	ld	s11,24(sp)
 718:	6109                	addi	sp,sp,128
 71a:	8082                	ret

000000000000071c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 71c:	715d                	addi	sp,sp,-80
 71e:	ec06                	sd	ra,24(sp)
 720:	e822                	sd	s0,16(sp)
 722:	1000                	addi	s0,sp,32
 724:	e010                	sd	a2,0(s0)
 726:	e414                	sd	a3,8(s0)
 728:	e818                	sd	a4,16(s0)
 72a:	ec1c                	sd	a5,24(s0)
 72c:	03043023          	sd	a6,32(s0)
 730:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 734:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 738:	8622                	mv	a2,s0
 73a:	00000097          	auipc	ra,0x0
 73e:	e04080e7          	jalr	-508(ra) # 53e <vprintf>
}
 742:	60e2                	ld	ra,24(sp)
 744:	6442                	ld	s0,16(sp)
 746:	6161                	addi	sp,sp,80
 748:	8082                	ret

000000000000074a <printf>:

void
printf(const char *fmt, ...)
{
 74a:	711d                	addi	sp,sp,-96
 74c:	ec06                	sd	ra,24(sp)
 74e:	e822                	sd	s0,16(sp)
 750:	1000                	addi	s0,sp,32
 752:	e40c                	sd	a1,8(s0)
 754:	e810                	sd	a2,16(s0)
 756:	ec14                	sd	a3,24(s0)
 758:	f018                	sd	a4,32(s0)
 75a:	f41c                	sd	a5,40(s0)
 75c:	03043823          	sd	a6,48(s0)
 760:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 764:	00840613          	addi	a2,s0,8
 768:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 76c:	85aa                	mv	a1,a0
 76e:	4505                	li	a0,1
 770:	00000097          	auipc	ra,0x0
 774:	dce080e7          	jalr	-562(ra) # 53e <vprintf>
}
 778:	60e2                	ld	ra,24(sp)
 77a:	6442                	ld	s0,16(sp)
 77c:	6125                	addi	sp,sp,96
 77e:	8082                	ret

0000000000000780 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 780:	1141                	addi	sp,sp,-16
 782:	e422                	sd	s0,8(sp)
 784:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 786:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 78a:	00000797          	auipc	a5,0x0
 78e:	2ae7b783          	ld	a5,686(a5) # a38 <freep>
 792:	a02d                	j	7bc <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 794:	4618                	lw	a4,8(a2)
 796:	9f2d                	addw	a4,a4,a1
 798:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 79c:	6398                	ld	a4,0(a5)
 79e:	6310                	ld	a2,0(a4)
 7a0:	a83d                	j	7de <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7a2:	ff852703          	lw	a4,-8(a0)
 7a6:	9f31                	addw	a4,a4,a2
 7a8:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7aa:	ff053683          	ld	a3,-16(a0)
 7ae:	a091                	j	7f2 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7b0:	6398                	ld	a4,0(a5)
 7b2:	00e7e463          	bltu	a5,a4,7ba <free+0x3a>
 7b6:	00e6ea63          	bltu	a3,a4,7ca <free+0x4a>
{
 7ba:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7bc:	fed7fae3          	bgeu	a5,a3,7b0 <free+0x30>
 7c0:	6398                	ld	a4,0(a5)
 7c2:	00e6e463          	bltu	a3,a4,7ca <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7c6:	fee7eae3          	bltu	a5,a4,7ba <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7ca:	ff852583          	lw	a1,-8(a0)
 7ce:	6390                	ld	a2,0(a5)
 7d0:	02059813          	slli	a6,a1,0x20
 7d4:	01c85713          	srli	a4,a6,0x1c
 7d8:	9736                	add	a4,a4,a3
 7da:	fae60de3          	beq	a2,a4,794 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7de:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7e2:	4790                	lw	a2,8(a5)
 7e4:	02061593          	slli	a1,a2,0x20
 7e8:	01c5d713          	srli	a4,a1,0x1c
 7ec:	973e                	add	a4,a4,a5
 7ee:	fae68ae3          	beq	a3,a4,7a2 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7f2:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7f4:	00000717          	auipc	a4,0x0
 7f8:	24f73223          	sd	a5,580(a4) # a38 <freep>
}
 7fc:	6422                	ld	s0,8(sp)
 7fe:	0141                	addi	sp,sp,16
 800:	8082                	ret

0000000000000802 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 802:	7139                	addi	sp,sp,-64
 804:	fc06                	sd	ra,56(sp)
 806:	f822                	sd	s0,48(sp)
 808:	f426                	sd	s1,40(sp)
 80a:	f04a                	sd	s2,32(sp)
 80c:	ec4e                	sd	s3,24(sp)
 80e:	e852                	sd	s4,16(sp)
 810:	e456                	sd	s5,8(sp)
 812:	e05a                	sd	s6,0(sp)
 814:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 816:	02051493          	slli	s1,a0,0x20
 81a:	9081                	srli	s1,s1,0x20
 81c:	04bd                	addi	s1,s1,15
 81e:	8091                	srli	s1,s1,0x4
 820:	0014899b          	addiw	s3,s1,1
 824:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 826:	00000517          	auipc	a0,0x0
 82a:	21253503          	ld	a0,530(a0) # a38 <freep>
 82e:	c515                	beqz	a0,85a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 830:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 832:	4798                	lw	a4,8(a5)
 834:	02977f63          	bgeu	a4,s1,872 <malloc+0x70>
 838:	8a4e                	mv	s4,s3
 83a:	0009871b          	sext.w	a4,s3
 83e:	6685                	lui	a3,0x1
 840:	00d77363          	bgeu	a4,a3,846 <malloc+0x44>
 844:	6a05                	lui	s4,0x1
 846:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 84a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 84e:	00000917          	auipc	s2,0x0
 852:	1ea90913          	addi	s2,s2,490 # a38 <freep>
  if(p == (char*)-1)
 856:	5afd                	li	s5,-1
 858:	a895                	j	8cc <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 85a:	00000797          	auipc	a5,0x0
 85e:	1e678793          	addi	a5,a5,486 # a40 <base>
 862:	00000717          	auipc	a4,0x0
 866:	1cf73b23          	sd	a5,470(a4) # a38 <freep>
 86a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 86c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 870:	b7e1                	j	838 <malloc+0x36>
      if(p->s.size == nunits)
 872:	02e48c63          	beq	s1,a4,8aa <malloc+0xa8>
        p->s.size -= nunits;
 876:	4137073b          	subw	a4,a4,s3
 87a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 87c:	02071693          	slli	a3,a4,0x20
 880:	01c6d713          	srli	a4,a3,0x1c
 884:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 886:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 88a:	00000717          	auipc	a4,0x0
 88e:	1aa73723          	sd	a0,430(a4) # a38 <freep>
      return (void*)(p + 1);
 892:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 896:	70e2                	ld	ra,56(sp)
 898:	7442                	ld	s0,48(sp)
 89a:	74a2                	ld	s1,40(sp)
 89c:	7902                	ld	s2,32(sp)
 89e:	69e2                	ld	s3,24(sp)
 8a0:	6a42                	ld	s4,16(sp)
 8a2:	6aa2                	ld	s5,8(sp)
 8a4:	6b02                	ld	s6,0(sp)
 8a6:	6121                	addi	sp,sp,64
 8a8:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8aa:	6398                	ld	a4,0(a5)
 8ac:	e118                	sd	a4,0(a0)
 8ae:	bff1                	j	88a <malloc+0x88>
  hp->s.size = nu;
 8b0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8b4:	0541                	addi	a0,a0,16
 8b6:	00000097          	auipc	ra,0x0
 8ba:	eca080e7          	jalr	-310(ra) # 780 <free>
  return freep;
 8be:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8c2:	d971                	beqz	a0,896 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8c6:	4798                	lw	a4,8(a5)
 8c8:	fa9775e3          	bgeu	a4,s1,872 <malloc+0x70>
    if(p == freep)
 8cc:	00093703          	ld	a4,0(s2)
 8d0:	853e                	mv	a0,a5
 8d2:	fef719e3          	bne	a4,a5,8c4 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 8d6:	8552                	mv	a0,s4
 8d8:	00000097          	auipc	ra,0x0
 8dc:	b58080e7          	jalr	-1192(ra) # 430 <sbrk>
  if(p == (char*)-1)
 8e0:	fd5518e3          	bne	a0,s5,8b0 <malloc+0xae>
        return 0;
 8e4:	4501                	li	a0,0
 8e6:	bf45                	j	896 <malloc+0x94>
