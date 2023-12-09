
user/_private:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <producer>:
} buffer_t;

buffer_t *buffer;

void producer()
{
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
    while(1) {
        if (buffer->num_produced >= MAX)
   6:	00001797          	auipc	a5,0x1
   a:	94a7b783          	ld	a5,-1718(a5) # 950 <buffer>
   e:	5b98                	lw	a4,48(a5)
  10:	46a5                	li	a3,9
	    return;
	buffer->num_produced++;
	buffer->buf[buffer->nextin++] = buffer->num_produced;
	buffer->nextin %= BSIZE;
  12:	00001817          	auipc	a6,0x1
  16:	93e80813          	addi	a6,a6,-1730 # 950 <buffer>
  1a:	4529                	li	a0,10
        if (buffer->num_produced >= MAX)
  1c:	45a5                	li	a1,9
  1e:	02e6c463          	blt	a3,a4,46 <producer+0x46>
	buffer->num_produced++;
  22:	2705                	addiw	a4,a4,1
  24:	db98                	sw	a4,48(a5)
	buffer->buf[buffer->nextin++] = buffer->num_produced;
  26:	5794                	lw	a3,40(a5)
  28:	0016861b          	addiw	a2,a3,1
  2c:	d790                	sw	a2,40(a5)
  2e:	068a                	slli	a3,a3,0x2
  30:	97b6                	add	a5,a5,a3
  32:	c398                	sw	a4,0(a5)
	buffer->nextin %= BSIZE;
  34:	00083783          	ld	a5,0(a6)
  38:	5798                	lw	a4,40(a5)
  3a:	02a7673b          	remw	a4,a4,a0
  3e:	d798                	sw	a4,40(a5)
        if (buffer->num_produced >= MAX)
  40:	5b98                	lw	a4,48(a5)
  42:	fee5d0e3          	bge	a1,a4,22 <producer+0x22>
    }
}
  46:	6422                	ld	s0,8(sp)
  48:	0141                	addi	sp,sp,16
  4a:	8082                	ret

000000000000004c <consumer>:

void consumer()
{
  4c:	1141                	addi	sp,sp,-16
  4e:	e422                	sd	s0,8(sp)
  50:	0800                	addi	s0,sp,16
    while(1) {
        if (buffer->num_consumed >= MAX) 
  52:	00001597          	auipc	a1,0x1
  56:	8fe5b583          	ld	a1,-1794(a1) # 950 <buffer>
  5a:	59d4                	lw	a3,52(a1)
  5c:	47a5                	li	a5,9
  5e:	02d7c663          	blt	a5,a3,8a <consumer+0x3e>
  62:	55dc                	lw	a5,44(a1)
  64:	5d90                	lw	a2,56(a1)
  66:	2685                	addiw	a3,a3,1
	    return;
	buffer->total += buffer->buf[buffer->nextout++];
	buffer->nextout %= BSIZE;
  68:	4829                	li	a6,10
        if (buffer->num_consumed >= MAX) 
  6a:	452d                	li	a0,11
	buffer->total += buffer->buf[buffer->nextout++];
  6c:	00279713          	slli	a4,a5,0x2
  70:	972e                	add	a4,a4,a1
  72:	4318                	lw	a4,0(a4)
  74:	9e39                	addw	a2,a2,a4
  76:	2785                	addiw	a5,a5,1
	buffer->nextout %= BSIZE;
  78:	0307e7bb          	remw	a5,a5,a6
        if (buffer->num_consumed >= MAX) 
  7c:	2685                	addiw	a3,a3,1
  7e:	fea697e3          	bne	a3,a0,6c <consumer+0x20>
  82:	dd90                	sw	a2,56(a1)
  84:	d5dc                	sw	a5,44(a1)
  86:	47a9                	li	a5,10
  88:	d9dc                	sw	a5,52(a1)
	buffer->num_consumed++;
    }
}
  8a:	6422                	ld	s0,8(sp)
  8c:	0141                	addi	sp,sp,16
  8e:	8082                	ret

0000000000000090 <main>:

int
main(int argc, char *argv[])
{
  90:	1101                	addi	sp,sp,-32
  92:	ec06                	sd	ra,24(sp)
  94:	e822                	sd	s0,16(sp)
  96:	e426                	sd	s1,8(sp)
  98:	1000                	addi	s0,sp,32
    buffer = (buffer_t *) mmap(NULL, sizeof(buffer_t),
  9a:	4781                	li	a5,0
  9c:	577d                	li	a4,-1
  9e:	02200693          	li	a3,34
  a2:	4619                	li	a2,6
  a4:	03c00593          	li	a1,60
  a8:	4501                	li	a0,0
  aa:	00000097          	auipc	ra,0x0
  ae:	370080e7          	jalr	880(ra) # 41a <mmap>
  b2:	00001497          	auipc	s1,0x1
  b6:	89e48493          	addi	s1,s1,-1890 # 950 <buffer>
  ba:	e088                	sd	a0,0(s1)
		               PROT_READ | PROT_WRITE,
			       MAP_ANONYMOUS | MAP_PRIVATE,
			       -1, 0);
    buffer->nextin = 0;
  bc:	02052423          	sw	zero,40(a0)
    buffer->nextout = 0;
  c0:	02052623          	sw	zero,44(a0)
    buffer->num_produced = 0;
  c4:	02052823          	sw	zero,48(a0)
    buffer->num_consumed = 0;
  c8:	02052a23          	sw	zero,52(a0)
    buffer->total = 0;
  cc:	02052c23          	sw	zero,56(a0)

    producer();
  d0:	00000097          	auipc	ra,0x0
  d4:	f30080e7          	jalr	-208(ra) # 0 <producer>
    consumer();
  d8:	00000097          	auipc	ra,0x0
  dc:	f74080e7          	jalr	-140(ra) # 4c <consumer>

    printf("total = %d\n", buffer->total);
  e0:	609c                	ld	a5,0(s1)
  e2:	5f8c                	lw	a1,56(a5)
  e4:	00000517          	auipc	a0,0x0
  e8:	7e450513          	addi	a0,a0,2020 # 8c8 <malloc+0xec>
  ec:	00000097          	auipc	ra,0x0
  f0:	638080e7          	jalr	1592(ra) # 724 <printf>

    //munmap(buffer, sizeof(buffer_t));

    exit(0);
  f4:	4501                	li	a0,0
  f6:	00000097          	auipc	ra,0x0
  fa:	274080e7          	jalr	628(ra) # 36a <exit>

00000000000000fe <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  fe:	1141                	addi	sp,sp,-16
 100:	e422                	sd	s0,8(sp)
 102:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 104:	87aa                	mv	a5,a0
 106:	0585                	addi	a1,a1,1
 108:	0785                	addi	a5,a5,1
 10a:	fff5c703          	lbu	a4,-1(a1)
 10e:	fee78fa3          	sb	a4,-1(a5)
 112:	fb75                	bnez	a4,106 <strcpy+0x8>
    ;
  return os;
}
 114:	6422                	ld	s0,8(sp)
 116:	0141                	addi	sp,sp,16
 118:	8082                	ret

000000000000011a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 11a:	1141                	addi	sp,sp,-16
 11c:	e422                	sd	s0,8(sp)
 11e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 120:	00054783          	lbu	a5,0(a0)
 124:	cb91                	beqz	a5,138 <strcmp+0x1e>
 126:	0005c703          	lbu	a4,0(a1)
 12a:	00f71763          	bne	a4,a5,138 <strcmp+0x1e>
    p++, q++;
 12e:	0505                	addi	a0,a0,1
 130:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 132:	00054783          	lbu	a5,0(a0)
 136:	fbe5                	bnez	a5,126 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 138:	0005c503          	lbu	a0,0(a1)
}
 13c:	40a7853b          	subw	a0,a5,a0
 140:	6422                	ld	s0,8(sp)
 142:	0141                	addi	sp,sp,16
 144:	8082                	ret

0000000000000146 <strlen>:

uint
strlen(const char *s)
{
 146:	1141                	addi	sp,sp,-16
 148:	e422                	sd	s0,8(sp)
 14a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 14c:	00054783          	lbu	a5,0(a0)
 150:	cf91                	beqz	a5,16c <strlen+0x26>
 152:	0505                	addi	a0,a0,1
 154:	87aa                	mv	a5,a0
 156:	4685                	li	a3,1
 158:	9e89                	subw	a3,a3,a0
 15a:	00f6853b          	addw	a0,a3,a5
 15e:	0785                	addi	a5,a5,1
 160:	fff7c703          	lbu	a4,-1(a5)
 164:	fb7d                	bnez	a4,15a <strlen+0x14>
    ;
  return n;
}
 166:	6422                	ld	s0,8(sp)
 168:	0141                	addi	sp,sp,16
 16a:	8082                	ret
  for(n = 0; s[n]; n++)
 16c:	4501                	li	a0,0
 16e:	bfe5                	j	166 <strlen+0x20>

0000000000000170 <memset>:

void*
memset(void *dst, int c, uint n)
{
 170:	1141                	addi	sp,sp,-16
 172:	e422                	sd	s0,8(sp)
 174:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 176:	ca19                	beqz	a2,18c <memset+0x1c>
 178:	87aa                	mv	a5,a0
 17a:	1602                	slli	a2,a2,0x20
 17c:	9201                	srli	a2,a2,0x20
 17e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 182:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 186:	0785                	addi	a5,a5,1
 188:	fee79de3          	bne	a5,a4,182 <memset+0x12>
  }
  return dst;
}
 18c:	6422                	ld	s0,8(sp)
 18e:	0141                	addi	sp,sp,16
 190:	8082                	ret

0000000000000192 <strchr>:

char*
strchr(const char *s, char c)
{
 192:	1141                	addi	sp,sp,-16
 194:	e422                	sd	s0,8(sp)
 196:	0800                	addi	s0,sp,16
  for(; *s; s++)
 198:	00054783          	lbu	a5,0(a0)
 19c:	cb99                	beqz	a5,1b2 <strchr+0x20>
    if(*s == c)
 19e:	00f58763          	beq	a1,a5,1ac <strchr+0x1a>
  for(; *s; s++)
 1a2:	0505                	addi	a0,a0,1
 1a4:	00054783          	lbu	a5,0(a0)
 1a8:	fbfd                	bnez	a5,19e <strchr+0xc>
      return (char*)s;
  return 0;
 1aa:	4501                	li	a0,0
}
 1ac:	6422                	ld	s0,8(sp)
 1ae:	0141                	addi	sp,sp,16
 1b0:	8082                	ret
  return 0;
 1b2:	4501                	li	a0,0
 1b4:	bfe5                	j	1ac <strchr+0x1a>

00000000000001b6 <gets>:

char*
gets(char *buf, int max)
{
 1b6:	711d                	addi	sp,sp,-96
 1b8:	ec86                	sd	ra,88(sp)
 1ba:	e8a2                	sd	s0,80(sp)
 1bc:	e4a6                	sd	s1,72(sp)
 1be:	e0ca                	sd	s2,64(sp)
 1c0:	fc4e                	sd	s3,56(sp)
 1c2:	f852                	sd	s4,48(sp)
 1c4:	f456                	sd	s5,40(sp)
 1c6:	f05a                	sd	s6,32(sp)
 1c8:	ec5e                	sd	s7,24(sp)
 1ca:	1080                	addi	s0,sp,96
 1cc:	8baa                	mv	s7,a0
 1ce:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1d0:	892a                	mv	s2,a0
 1d2:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1d4:	4aa9                	li	s5,10
 1d6:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1d8:	89a6                	mv	s3,s1
 1da:	2485                	addiw	s1,s1,1
 1dc:	0344d863          	bge	s1,s4,20c <gets+0x56>
    cc = read(0, &c, 1);
 1e0:	4605                	li	a2,1
 1e2:	faf40593          	addi	a1,s0,-81
 1e6:	4501                	li	a0,0
 1e8:	00000097          	auipc	ra,0x0
 1ec:	19a080e7          	jalr	410(ra) # 382 <read>
    if(cc < 1)
 1f0:	00a05e63          	blez	a0,20c <gets+0x56>
    buf[i++] = c;
 1f4:	faf44783          	lbu	a5,-81(s0)
 1f8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1fc:	01578763          	beq	a5,s5,20a <gets+0x54>
 200:	0905                	addi	s2,s2,1
 202:	fd679be3          	bne	a5,s6,1d8 <gets+0x22>
  for(i=0; i+1 < max; ){
 206:	89a6                	mv	s3,s1
 208:	a011                	j	20c <gets+0x56>
 20a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 20c:	99de                	add	s3,s3,s7
 20e:	00098023          	sb	zero,0(s3)
  return buf;
}
 212:	855e                	mv	a0,s7
 214:	60e6                	ld	ra,88(sp)
 216:	6446                	ld	s0,80(sp)
 218:	64a6                	ld	s1,72(sp)
 21a:	6906                	ld	s2,64(sp)
 21c:	79e2                	ld	s3,56(sp)
 21e:	7a42                	ld	s4,48(sp)
 220:	7aa2                	ld	s5,40(sp)
 222:	7b02                	ld	s6,32(sp)
 224:	6be2                	ld	s7,24(sp)
 226:	6125                	addi	sp,sp,96
 228:	8082                	ret

000000000000022a <stat>:

int
stat(const char *n, struct stat *st)
{
 22a:	1101                	addi	sp,sp,-32
 22c:	ec06                	sd	ra,24(sp)
 22e:	e822                	sd	s0,16(sp)
 230:	e426                	sd	s1,8(sp)
 232:	e04a                	sd	s2,0(sp)
 234:	1000                	addi	s0,sp,32
 236:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 238:	4581                	li	a1,0
 23a:	00000097          	auipc	ra,0x0
 23e:	170080e7          	jalr	368(ra) # 3aa <open>
  if(fd < 0)
 242:	02054563          	bltz	a0,26c <stat+0x42>
 246:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 248:	85ca                	mv	a1,s2
 24a:	00000097          	auipc	ra,0x0
 24e:	178080e7          	jalr	376(ra) # 3c2 <fstat>
 252:	892a                	mv	s2,a0
  close(fd);
 254:	8526                	mv	a0,s1
 256:	00000097          	auipc	ra,0x0
 25a:	13c080e7          	jalr	316(ra) # 392 <close>
  return r;
}
 25e:	854a                	mv	a0,s2
 260:	60e2                	ld	ra,24(sp)
 262:	6442                	ld	s0,16(sp)
 264:	64a2                	ld	s1,8(sp)
 266:	6902                	ld	s2,0(sp)
 268:	6105                	addi	sp,sp,32
 26a:	8082                	ret
    return -1;
 26c:	597d                	li	s2,-1
 26e:	bfc5                	j	25e <stat+0x34>

0000000000000270 <atoi>:

int
atoi(const char *s)
{
 270:	1141                	addi	sp,sp,-16
 272:	e422                	sd	s0,8(sp)
 274:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 276:	00054683          	lbu	a3,0(a0)
 27a:	fd06879b          	addiw	a5,a3,-48
 27e:	0ff7f793          	zext.b	a5,a5
 282:	4625                	li	a2,9
 284:	02f66863          	bltu	a2,a5,2b4 <atoi+0x44>
 288:	872a                	mv	a4,a0
  n = 0;
 28a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 28c:	0705                	addi	a4,a4,1
 28e:	0025179b          	slliw	a5,a0,0x2
 292:	9fa9                	addw	a5,a5,a0
 294:	0017979b          	slliw	a5,a5,0x1
 298:	9fb5                	addw	a5,a5,a3
 29a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 29e:	00074683          	lbu	a3,0(a4)
 2a2:	fd06879b          	addiw	a5,a3,-48
 2a6:	0ff7f793          	zext.b	a5,a5
 2aa:	fef671e3          	bgeu	a2,a5,28c <atoi+0x1c>
  return n;
}
 2ae:	6422                	ld	s0,8(sp)
 2b0:	0141                	addi	sp,sp,16
 2b2:	8082                	ret
  n = 0;
 2b4:	4501                	li	a0,0
 2b6:	bfe5                	j	2ae <atoi+0x3e>

00000000000002b8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2b8:	1141                	addi	sp,sp,-16
 2ba:	e422                	sd	s0,8(sp)
 2bc:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2be:	02b57463          	bgeu	a0,a1,2e6 <memmove+0x2e>
    while(n-- > 0)
 2c2:	00c05f63          	blez	a2,2e0 <memmove+0x28>
 2c6:	1602                	slli	a2,a2,0x20
 2c8:	9201                	srli	a2,a2,0x20
 2ca:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2ce:	872a                	mv	a4,a0
      *dst++ = *src++;
 2d0:	0585                	addi	a1,a1,1
 2d2:	0705                	addi	a4,a4,1
 2d4:	fff5c683          	lbu	a3,-1(a1)
 2d8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2dc:	fee79ae3          	bne	a5,a4,2d0 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2e0:	6422                	ld	s0,8(sp)
 2e2:	0141                	addi	sp,sp,16
 2e4:	8082                	ret
    dst += n;
 2e6:	00c50733          	add	a4,a0,a2
    src += n;
 2ea:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2ec:	fec05ae3          	blez	a2,2e0 <memmove+0x28>
 2f0:	fff6079b          	addiw	a5,a2,-1
 2f4:	1782                	slli	a5,a5,0x20
 2f6:	9381                	srli	a5,a5,0x20
 2f8:	fff7c793          	not	a5,a5
 2fc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2fe:	15fd                	addi	a1,a1,-1
 300:	177d                	addi	a4,a4,-1
 302:	0005c683          	lbu	a3,0(a1)
 306:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 30a:	fee79ae3          	bne	a5,a4,2fe <memmove+0x46>
 30e:	bfc9                	j	2e0 <memmove+0x28>

0000000000000310 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 310:	1141                	addi	sp,sp,-16
 312:	e422                	sd	s0,8(sp)
 314:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 316:	ca05                	beqz	a2,346 <memcmp+0x36>
 318:	fff6069b          	addiw	a3,a2,-1
 31c:	1682                	slli	a3,a3,0x20
 31e:	9281                	srli	a3,a3,0x20
 320:	0685                	addi	a3,a3,1
 322:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 324:	00054783          	lbu	a5,0(a0)
 328:	0005c703          	lbu	a4,0(a1)
 32c:	00e79863          	bne	a5,a4,33c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 330:	0505                	addi	a0,a0,1
    p2++;
 332:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 334:	fed518e3          	bne	a0,a3,324 <memcmp+0x14>
  }
  return 0;
 338:	4501                	li	a0,0
 33a:	a019                	j	340 <memcmp+0x30>
      return *p1 - *p2;
 33c:	40e7853b          	subw	a0,a5,a4
}
 340:	6422                	ld	s0,8(sp)
 342:	0141                	addi	sp,sp,16
 344:	8082                	ret
  return 0;
 346:	4501                	li	a0,0
 348:	bfe5                	j	340 <memcmp+0x30>

000000000000034a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 34a:	1141                	addi	sp,sp,-16
 34c:	e406                	sd	ra,8(sp)
 34e:	e022                	sd	s0,0(sp)
 350:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 352:	00000097          	auipc	ra,0x0
 356:	f66080e7          	jalr	-154(ra) # 2b8 <memmove>
}
 35a:	60a2                	ld	ra,8(sp)
 35c:	6402                	ld	s0,0(sp)
 35e:	0141                	addi	sp,sp,16
 360:	8082                	ret

0000000000000362 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 362:	4885                	li	a7,1
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <exit>:
.global exit
exit:
 li a7, SYS_exit
 36a:	4889                	li	a7,2
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <wait>:
.global wait
wait:
 li a7, SYS_wait
 372:	488d                	li	a7,3
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 37a:	4891                	li	a7,4
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <read>:
.global read
read:
 li a7, SYS_read
 382:	4895                	li	a7,5
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <write>:
.global write
write:
 li a7, SYS_write
 38a:	48c1                	li	a7,16
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <close>:
.global close
close:
 li a7, SYS_close
 392:	48d5                	li	a7,21
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <kill>:
.global kill
kill:
 li a7, SYS_kill
 39a:	4899                	li	a7,6
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3a2:	489d                	li	a7,7
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <open>:
.global open
open:
 li a7, SYS_open
 3aa:	48bd                	li	a7,15
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3b2:	48c5                	li	a7,17
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3ba:	48c9                	li	a7,18
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3c2:	48a1                	li	a7,8
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <link>:
.global link
link:
 li a7, SYS_link
 3ca:	48cd                	li	a7,19
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3d2:	48d1                	li	a7,20
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3da:	48a5                	li	a7,9
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3e2:	48a9                	li	a7,10
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3ea:	48ad                	li	a7,11
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3f2:	48b1                	li	a7,12
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3fa:	48b5                	li	a7,13
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 402:	48b9                	li	a7,14
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <getprocs>:
.global getprocs
getprocs:
 li a7, SYS_getprocs
 40a:	48d9                	li	a7,22
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <freepmem>:
.global freepmem
freepmem:
 li a7, SYS_freepmem
 412:	48dd                	li	a7,23
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 41a:	48e1                	li	a7,24
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 422:	48e5                	li	a7,25
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <sem_init>:
.global sem_init
sem_init:
 li a7, SYS_sem_init
 42a:	48e9                	li	a7,26
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <sem_destroy>:
.global sem_destroy
sem_destroy:
 li a7, SYS_sem_destroy
 432:	48ed                	li	a7,27
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 43a:	48f1                	li	a7,28
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 442:	48f5                	li	a7,29
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 44a:	1101                	addi	sp,sp,-32
 44c:	ec06                	sd	ra,24(sp)
 44e:	e822                	sd	s0,16(sp)
 450:	1000                	addi	s0,sp,32
 452:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 456:	4605                	li	a2,1
 458:	fef40593          	addi	a1,s0,-17
 45c:	00000097          	auipc	ra,0x0
 460:	f2e080e7          	jalr	-210(ra) # 38a <write>
}
 464:	60e2                	ld	ra,24(sp)
 466:	6442                	ld	s0,16(sp)
 468:	6105                	addi	sp,sp,32
 46a:	8082                	ret

000000000000046c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 46c:	7139                	addi	sp,sp,-64
 46e:	fc06                	sd	ra,56(sp)
 470:	f822                	sd	s0,48(sp)
 472:	f426                	sd	s1,40(sp)
 474:	f04a                	sd	s2,32(sp)
 476:	ec4e                	sd	s3,24(sp)
 478:	0080                	addi	s0,sp,64
 47a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 47c:	c299                	beqz	a3,482 <printint+0x16>
 47e:	0805c963          	bltz	a1,510 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 482:	2581                	sext.w	a1,a1
  neg = 0;
 484:	4881                	li	a7,0
 486:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 48a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 48c:	2601                	sext.w	a2,a2
 48e:	00000517          	auipc	a0,0x0
 492:	4aa50513          	addi	a0,a0,1194 # 938 <digits>
 496:	883a                	mv	a6,a4
 498:	2705                	addiw	a4,a4,1
 49a:	02c5f7bb          	remuw	a5,a1,a2
 49e:	1782                	slli	a5,a5,0x20
 4a0:	9381                	srli	a5,a5,0x20
 4a2:	97aa                	add	a5,a5,a0
 4a4:	0007c783          	lbu	a5,0(a5)
 4a8:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4ac:	0005879b          	sext.w	a5,a1
 4b0:	02c5d5bb          	divuw	a1,a1,a2
 4b4:	0685                	addi	a3,a3,1
 4b6:	fec7f0e3          	bgeu	a5,a2,496 <printint+0x2a>
  if(neg)
 4ba:	00088c63          	beqz	a7,4d2 <printint+0x66>
    buf[i++] = '-';
 4be:	fd070793          	addi	a5,a4,-48
 4c2:	00878733          	add	a4,a5,s0
 4c6:	02d00793          	li	a5,45
 4ca:	fef70823          	sb	a5,-16(a4)
 4ce:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4d2:	02e05863          	blez	a4,502 <printint+0x96>
 4d6:	fc040793          	addi	a5,s0,-64
 4da:	00e78933          	add	s2,a5,a4
 4de:	fff78993          	addi	s3,a5,-1
 4e2:	99ba                	add	s3,s3,a4
 4e4:	377d                	addiw	a4,a4,-1
 4e6:	1702                	slli	a4,a4,0x20
 4e8:	9301                	srli	a4,a4,0x20
 4ea:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4ee:	fff94583          	lbu	a1,-1(s2)
 4f2:	8526                	mv	a0,s1
 4f4:	00000097          	auipc	ra,0x0
 4f8:	f56080e7          	jalr	-170(ra) # 44a <putc>
  while(--i >= 0)
 4fc:	197d                	addi	s2,s2,-1
 4fe:	ff3918e3          	bne	s2,s3,4ee <printint+0x82>
}
 502:	70e2                	ld	ra,56(sp)
 504:	7442                	ld	s0,48(sp)
 506:	74a2                	ld	s1,40(sp)
 508:	7902                	ld	s2,32(sp)
 50a:	69e2                	ld	s3,24(sp)
 50c:	6121                	addi	sp,sp,64
 50e:	8082                	ret
    x = -xx;
 510:	40b005bb          	negw	a1,a1
    neg = 1;
 514:	4885                	li	a7,1
    x = -xx;
 516:	bf85                	j	486 <printint+0x1a>

0000000000000518 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 518:	7119                	addi	sp,sp,-128
 51a:	fc86                	sd	ra,120(sp)
 51c:	f8a2                	sd	s0,112(sp)
 51e:	f4a6                	sd	s1,104(sp)
 520:	f0ca                	sd	s2,96(sp)
 522:	ecce                	sd	s3,88(sp)
 524:	e8d2                	sd	s4,80(sp)
 526:	e4d6                	sd	s5,72(sp)
 528:	e0da                	sd	s6,64(sp)
 52a:	fc5e                	sd	s7,56(sp)
 52c:	f862                	sd	s8,48(sp)
 52e:	f466                	sd	s9,40(sp)
 530:	f06a                	sd	s10,32(sp)
 532:	ec6e                	sd	s11,24(sp)
 534:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 536:	0005c903          	lbu	s2,0(a1)
 53a:	18090f63          	beqz	s2,6d8 <vprintf+0x1c0>
 53e:	8aaa                	mv	s5,a0
 540:	8b32                	mv	s6,a2
 542:	00158493          	addi	s1,a1,1
  state = 0;
 546:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 548:	02500a13          	li	s4,37
 54c:	4c55                	li	s8,21
 54e:	00000c97          	auipc	s9,0x0
 552:	392c8c93          	addi	s9,s9,914 # 8e0 <malloc+0x104>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 556:	02800d93          	li	s11,40
  putc(fd, 'x');
 55a:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 55c:	00000b97          	auipc	s7,0x0
 560:	3dcb8b93          	addi	s7,s7,988 # 938 <digits>
 564:	a839                	j	582 <vprintf+0x6a>
        putc(fd, c);
 566:	85ca                	mv	a1,s2
 568:	8556                	mv	a0,s5
 56a:	00000097          	auipc	ra,0x0
 56e:	ee0080e7          	jalr	-288(ra) # 44a <putc>
 572:	a019                	j	578 <vprintf+0x60>
    } else if(state == '%'){
 574:	01498d63          	beq	s3,s4,58e <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 578:	0485                	addi	s1,s1,1
 57a:	fff4c903          	lbu	s2,-1(s1)
 57e:	14090d63          	beqz	s2,6d8 <vprintf+0x1c0>
    if(state == 0){
 582:	fe0999e3          	bnez	s3,574 <vprintf+0x5c>
      if(c == '%'){
 586:	ff4910e3          	bne	s2,s4,566 <vprintf+0x4e>
        state = '%';
 58a:	89d2                	mv	s3,s4
 58c:	b7f5                	j	578 <vprintf+0x60>
      if(c == 'd'){
 58e:	11490c63          	beq	s2,s4,6a6 <vprintf+0x18e>
 592:	f9d9079b          	addiw	a5,s2,-99
 596:	0ff7f793          	zext.b	a5,a5
 59a:	10fc6e63          	bltu	s8,a5,6b6 <vprintf+0x19e>
 59e:	f9d9079b          	addiw	a5,s2,-99
 5a2:	0ff7f713          	zext.b	a4,a5
 5a6:	10ec6863          	bltu	s8,a4,6b6 <vprintf+0x19e>
 5aa:	00271793          	slli	a5,a4,0x2
 5ae:	97e6                	add	a5,a5,s9
 5b0:	439c                	lw	a5,0(a5)
 5b2:	97e6                	add	a5,a5,s9
 5b4:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5b6:	008b0913          	addi	s2,s6,8
 5ba:	4685                	li	a3,1
 5bc:	4629                	li	a2,10
 5be:	000b2583          	lw	a1,0(s6)
 5c2:	8556                	mv	a0,s5
 5c4:	00000097          	auipc	ra,0x0
 5c8:	ea8080e7          	jalr	-344(ra) # 46c <printint>
 5cc:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5ce:	4981                	li	s3,0
 5d0:	b765                	j	578 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5d2:	008b0913          	addi	s2,s6,8
 5d6:	4681                	li	a3,0
 5d8:	4629                	li	a2,10
 5da:	000b2583          	lw	a1,0(s6)
 5de:	8556                	mv	a0,s5
 5e0:	00000097          	auipc	ra,0x0
 5e4:	e8c080e7          	jalr	-372(ra) # 46c <printint>
 5e8:	8b4a                	mv	s6,s2
      state = 0;
 5ea:	4981                	li	s3,0
 5ec:	b771                	j	578 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5ee:	008b0913          	addi	s2,s6,8
 5f2:	4681                	li	a3,0
 5f4:	866a                	mv	a2,s10
 5f6:	000b2583          	lw	a1,0(s6)
 5fa:	8556                	mv	a0,s5
 5fc:	00000097          	auipc	ra,0x0
 600:	e70080e7          	jalr	-400(ra) # 46c <printint>
 604:	8b4a                	mv	s6,s2
      state = 0;
 606:	4981                	li	s3,0
 608:	bf85                	j	578 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 60a:	008b0793          	addi	a5,s6,8
 60e:	f8f43423          	sd	a5,-120(s0)
 612:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 616:	03000593          	li	a1,48
 61a:	8556                	mv	a0,s5
 61c:	00000097          	auipc	ra,0x0
 620:	e2e080e7          	jalr	-466(ra) # 44a <putc>
  putc(fd, 'x');
 624:	07800593          	li	a1,120
 628:	8556                	mv	a0,s5
 62a:	00000097          	auipc	ra,0x0
 62e:	e20080e7          	jalr	-480(ra) # 44a <putc>
 632:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 634:	03c9d793          	srli	a5,s3,0x3c
 638:	97de                	add	a5,a5,s7
 63a:	0007c583          	lbu	a1,0(a5)
 63e:	8556                	mv	a0,s5
 640:	00000097          	auipc	ra,0x0
 644:	e0a080e7          	jalr	-502(ra) # 44a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 648:	0992                	slli	s3,s3,0x4
 64a:	397d                	addiw	s2,s2,-1
 64c:	fe0914e3          	bnez	s2,634 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 650:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 654:	4981                	li	s3,0
 656:	b70d                	j	578 <vprintf+0x60>
        s = va_arg(ap, char*);
 658:	008b0913          	addi	s2,s6,8
 65c:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 660:	02098163          	beqz	s3,682 <vprintf+0x16a>
        while(*s != 0){
 664:	0009c583          	lbu	a1,0(s3)
 668:	c5ad                	beqz	a1,6d2 <vprintf+0x1ba>
          putc(fd, *s);
 66a:	8556                	mv	a0,s5
 66c:	00000097          	auipc	ra,0x0
 670:	dde080e7          	jalr	-546(ra) # 44a <putc>
          s++;
 674:	0985                	addi	s3,s3,1
        while(*s != 0){
 676:	0009c583          	lbu	a1,0(s3)
 67a:	f9e5                	bnez	a1,66a <vprintf+0x152>
        s = va_arg(ap, char*);
 67c:	8b4a                	mv	s6,s2
      state = 0;
 67e:	4981                	li	s3,0
 680:	bde5                	j	578 <vprintf+0x60>
          s = "(null)";
 682:	00000997          	auipc	s3,0x0
 686:	25698993          	addi	s3,s3,598 # 8d8 <malloc+0xfc>
        while(*s != 0){
 68a:	85ee                	mv	a1,s11
 68c:	bff9                	j	66a <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 68e:	008b0913          	addi	s2,s6,8
 692:	000b4583          	lbu	a1,0(s6)
 696:	8556                	mv	a0,s5
 698:	00000097          	auipc	ra,0x0
 69c:	db2080e7          	jalr	-590(ra) # 44a <putc>
 6a0:	8b4a                	mv	s6,s2
      state = 0;
 6a2:	4981                	li	s3,0
 6a4:	bdd1                	j	578 <vprintf+0x60>
        putc(fd, c);
 6a6:	85d2                	mv	a1,s4
 6a8:	8556                	mv	a0,s5
 6aa:	00000097          	auipc	ra,0x0
 6ae:	da0080e7          	jalr	-608(ra) # 44a <putc>
      state = 0;
 6b2:	4981                	li	s3,0
 6b4:	b5d1                	j	578 <vprintf+0x60>
        putc(fd, '%');
 6b6:	85d2                	mv	a1,s4
 6b8:	8556                	mv	a0,s5
 6ba:	00000097          	auipc	ra,0x0
 6be:	d90080e7          	jalr	-624(ra) # 44a <putc>
        putc(fd, c);
 6c2:	85ca                	mv	a1,s2
 6c4:	8556                	mv	a0,s5
 6c6:	00000097          	auipc	ra,0x0
 6ca:	d84080e7          	jalr	-636(ra) # 44a <putc>
      state = 0;
 6ce:	4981                	li	s3,0
 6d0:	b565                	j	578 <vprintf+0x60>
        s = va_arg(ap, char*);
 6d2:	8b4a                	mv	s6,s2
      state = 0;
 6d4:	4981                	li	s3,0
 6d6:	b54d                	j	578 <vprintf+0x60>
    }
  }
}
 6d8:	70e6                	ld	ra,120(sp)
 6da:	7446                	ld	s0,112(sp)
 6dc:	74a6                	ld	s1,104(sp)
 6de:	7906                	ld	s2,96(sp)
 6e0:	69e6                	ld	s3,88(sp)
 6e2:	6a46                	ld	s4,80(sp)
 6e4:	6aa6                	ld	s5,72(sp)
 6e6:	6b06                	ld	s6,64(sp)
 6e8:	7be2                	ld	s7,56(sp)
 6ea:	7c42                	ld	s8,48(sp)
 6ec:	7ca2                	ld	s9,40(sp)
 6ee:	7d02                	ld	s10,32(sp)
 6f0:	6de2                	ld	s11,24(sp)
 6f2:	6109                	addi	sp,sp,128
 6f4:	8082                	ret

00000000000006f6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6f6:	715d                	addi	sp,sp,-80
 6f8:	ec06                	sd	ra,24(sp)
 6fa:	e822                	sd	s0,16(sp)
 6fc:	1000                	addi	s0,sp,32
 6fe:	e010                	sd	a2,0(s0)
 700:	e414                	sd	a3,8(s0)
 702:	e818                	sd	a4,16(s0)
 704:	ec1c                	sd	a5,24(s0)
 706:	03043023          	sd	a6,32(s0)
 70a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 70e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 712:	8622                	mv	a2,s0
 714:	00000097          	auipc	ra,0x0
 718:	e04080e7          	jalr	-508(ra) # 518 <vprintf>
}
 71c:	60e2                	ld	ra,24(sp)
 71e:	6442                	ld	s0,16(sp)
 720:	6161                	addi	sp,sp,80
 722:	8082                	ret

0000000000000724 <printf>:

void
printf(const char *fmt, ...)
{
 724:	711d                	addi	sp,sp,-96
 726:	ec06                	sd	ra,24(sp)
 728:	e822                	sd	s0,16(sp)
 72a:	1000                	addi	s0,sp,32
 72c:	e40c                	sd	a1,8(s0)
 72e:	e810                	sd	a2,16(s0)
 730:	ec14                	sd	a3,24(s0)
 732:	f018                	sd	a4,32(s0)
 734:	f41c                	sd	a5,40(s0)
 736:	03043823          	sd	a6,48(s0)
 73a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 73e:	00840613          	addi	a2,s0,8
 742:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 746:	85aa                	mv	a1,a0
 748:	4505                	li	a0,1
 74a:	00000097          	auipc	ra,0x0
 74e:	dce080e7          	jalr	-562(ra) # 518 <vprintf>
}
 752:	60e2                	ld	ra,24(sp)
 754:	6442                	ld	s0,16(sp)
 756:	6125                	addi	sp,sp,96
 758:	8082                	ret

000000000000075a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 75a:	1141                	addi	sp,sp,-16
 75c:	e422                	sd	s0,8(sp)
 75e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 760:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 764:	00000797          	auipc	a5,0x0
 768:	1f47b783          	ld	a5,500(a5) # 958 <freep>
 76c:	a02d                	j	796 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 76e:	4618                	lw	a4,8(a2)
 770:	9f2d                	addw	a4,a4,a1
 772:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 776:	6398                	ld	a4,0(a5)
 778:	6310                	ld	a2,0(a4)
 77a:	a83d                	j	7b8 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 77c:	ff852703          	lw	a4,-8(a0)
 780:	9f31                	addw	a4,a4,a2
 782:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 784:	ff053683          	ld	a3,-16(a0)
 788:	a091                	j	7cc <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 78a:	6398                	ld	a4,0(a5)
 78c:	00e7e463          	bltu	a5,a4,794 <free+0x3a>
 790:	00e6ea63          	bltu	a3,a4,7a4 <free+0x4a>
{
 794:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 796:	fed7fae3          	bgeu	a5,a3,78a <free+0x30>
 79a:	6398                	ld	a4,0(a5)
 79c:	00e6e463          	bltu	a3,a4,7a4 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7a0:	fee7eae3          	bltu	a5,a4,794 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7a4:	ff852583          	lw	a1,-8(a0)
 7a8:	6390                	ld	a2,0(a5)
 7aa:	02059813          	slli	a6,a1,0x20
 7ae:	01c85713          	srli	a4,a6,0x1c
 7b2:	9736                	add	a4,a4,a3
 7b4:	fae60de3          	beq	a2,a4,76e <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7b8:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7bc:	4790                	lw	a2,8(a5)
 7be:	02061593          	slli	a1,a2,0x20
 7c2:	01c5d713          	srli	a4,a1,0x1c
 7c6:	973e                	add	a4,a4,a5
 7c8:	fae68ae3          	beq	a3,a4,77c <free+0x22>
    p->s.ptr = bp->s.ptr;
 7cc:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7ce:	00000717          	auipc	a4,0x0
 7d2:	18f73523          	sd	a5,394(a4) # 958 <freep>
}
 7d6:	6422                	ld	s0,8(sp)
 7d8:	0141                	addi	sp,sp,16
 7da:	8082                	ret

00000000000007dc <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7dc:	7139                	addi	sp,sp,-64
 7de:	fc06                	sd	ra,56(sp)
 7e0:	f822                	sd	s0,48(sp)
 7e2:	f426                	sd	s1,40(sp)
 7e4:	f04a                	sd	s2,32(sp)
 7e6:	ec4e                	sd	s3,24(sp)
 7e8:	e852                	sd	s4,16(sp)
 7ea:	e456                	sd	s5,8(sp)
 7ec:	e05a                	sd	s6,0(sp)
 7ee:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7f0:	02051493          	slli	s1,a0,0x20
 7f4:	9081                	srli	s1,s1,0x20
 7f6:	04bd                	addi	s1,s1,15
 7f8:	8091                	srli	s1,s1,0x4
 7fa:	0014899b          	addiw	s3,s1,1
 7fe:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 800:	00000517          	auipc	a0,0x0
 804:	15853503          	ld	a0,344(a0) # 958 <freep>
 808:	c515                	beqz	a0,834 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 80a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 80c:	4798                	lw	a4,8(a5)
 80e:	02977f63          	bgeu	a4,s1,84c <malloc+0x70>
 812:	8a4e                	mv	s4,s3
 814:	0009871b          	sext.w	a4,s3
 818:	6685                	lui	a3,0x1
 81a:	00d77363          	bgeu	a4,a3,820 <malloc+0x44>
 81e:	6a05                	lui	s4,0x1
 820:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 824:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 828:	00000917          	auipc	s2,0x0
 82c:	13090913          	addi	s2,s2,304 # 958 <freep>
  if(p == (char*)-1)
 830:	5afd                	li	s5,-1
 832:	a895                	j	8a6 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 834:	00000797          	auipc	a5,0x0
 838:	12c78793          	addi	a5,a5,300 # 960 <base>
 83c:	00000717          	auipc	a4,0x0
 840:	10f73e23          	sd	a5,284(a4) # 958 <freep>
 844:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 846:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 84a:	b7e1                	j	812 <malloc+0x36>
      if(p->s.size == nunits)
 84c:	02e48c63          	beq	s1,a4,884 <malloc+0xa8>
        p->s.size -= nunits;
 850:	4137073b          	subw	a4,a4,s3
 854:	c798                	sw	a4,8(a5)
        p += p->s.size;
 856:	02071693          	slli	a3,a4,0x20
 85a:	01c6d713          	srli	a4,a3,0x1c
 85e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 860:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 864:	00000717          	auipc	a4,0x0
 868:	0ea73a23          	sd	a0,244(a4) # 958 <freep>
      return (void*)(p + 1);
 86c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 870:	70e2                	ld	ra,56(sp)
 872:	7442                	ld	s0,48(sp)
 874:	74a2                	ld	s1,40(sp)
 876:	7902                	ld	s2,32(sp)
 878:	69e2                	ld	s3,24(sp)
 87a:	6a42                	ld	s4,16(sp)
 87c:	6aa2                	ld	s5,8(sp)
 87e:	6b02                	ld	s6,0(sp)
 880:	6121                	addi	sp,sp,64
 882:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 884:	6398                	ld	a4,0(a5)
 886:	e118                	sd	a4,0(a0)
 888:	bff1                	j	864 <malloc+0x88>
  hp->s.size = nu;
 88a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 88e:	0541                	addi	a0,a0,16
 890:	00000097          	auipc	ra,0x0
 894:	eca080e7          	jalr	-310(ra) # 75a <free>
  return freep;
 898:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 89c:	d971                	beqz	a0,870 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 89e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8a0:	4798                	lw	a4,8(a5)
 8a2:	fa9775e3          	bgeu	a4,s1,84c <malloc+0x70>
    if(p == freep)
 8a6:	00093703          	ld	a4,0(s2)
 8aa:	853e                	mv	a0,a5
 8ac:	fef719e3          	bne	a4,a5,89e <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 8b0:	8552                	mv	a0,s4
 8b2:	00000097          	auipc	ra,0x0
 8b6:	b40080e7          	jalr	-1216(ra) # 3f2 <sbrk>
  if(p == (char*)-1)
 8ba:	fd5518e3          	bne	a0,s5,88a <malloc+0xae>
        return 0;
 8be:	4501                	li	a0,0
 8c0:	bf45                	j	870 <malloc+0x94>
