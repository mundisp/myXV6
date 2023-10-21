
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	87013103          	ld	sp,-1936(sp) # 80008870 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	ff070713          	addi	a4,a4,-16 # 80009040 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	c9e78793          	addi	a5,a5,-866 # 80005d00 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd87ff>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	dc678793          	addi	a5,a5,-570 # 80000e72 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	32e080e7          	jalr	814(ra) # 80002458 <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	77e080e7          	jalr	1918(ra) # 800008b8 <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	ff650513          	addi	a0,a0,-10 # 80011180 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a3e080e7          	jalr	-1474(ra) # 80000bd0 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	fe648493          	addi	s1,s1,-26 # 80011180 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	07690913          	addi	s2,s2,118 # 80011218 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001aa:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001ae:	4ca9                	li	s9,10
  while(n > 0){
    800001b0:	07305863          	blez	s3,80000220 <consoleread+0xbc>
    while(cons.r == cons.w){
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71463          	bne	a4,a5,800001e4 <consoleread+0x80>
      if(myproc()->killed){
    800001c0:	00001097          	auipc	ra,0x1
    800001c4:	7d6080e7          	jalr	2006(ra) # 80001996 <myproc>
    800001c8:	551c                	lw	a5,40(a0)
    800001ca:	e7b5                	bnez	a5,80000236 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001cc:	85a6                	mv	a1,s1
    800001ce:	854a                	mv	a0,s2
    800001d0:	00002097          	auipc	ra,0x2
    800001d4:	e8e080e7          	jalr	-370(ra) # 8000205e <sleep>
    while(cons.r == cons.w){
    800001d8:	0984a783          	lw	a5,152(s1)
    800001dc:	09c4a703          	lw	a4,156(s1)
    800001e0:	fef700e3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001e4:	0017871b          	addiw	a4,a5,1
    800001e8:	08e4ac23          	sw	a4,152(s1)
    800001ec:	07f7f713          	andi	a4,a5,127
    800001f0:	9726                	add	a4,a4,s1
    800001f2:	01874703          	lbu	a4,24(a4)
    800001f6:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    800001fa:	077d0563          	beq	s10,s7,80000264 <consoleread+0x100>
    cbuf = c;
    800001fe:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000202:	4685                	li	a3,1
    80000204:	f9f40613          	addi	a2,s0,-97
    80000208:	85d2                	mv	a1,s4
    8000020a:	8556                	mv	a0,s5
    8000020c:	00002097          	auipc	ra,0x2
    80000210:	1f6080e7          	jalr	502(ra) # 80002402 <either_copyout>
    80000214:	01850663          	beq	a0,s8,80000220 <consoleread+0xbc>
    dst++;
    80000218:	0a05                	addi	s4,s4,1
    --n;
    8000021a:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    8000021c:	f99d1ae3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000220:	00011517          	auipc	a0,0x11
    80000224:	f6050513          	addi	a0,a0,-160 # 80011180 <cons>
    80000228:	00001097          	auipc	ra,0x1
    8000022c:	a5c080e7          	jalr	-1444(ra) # 80000c84 <release>

  return target - n;
    80000230:	413b053b          	subw	a0,s6,s3
    80000234:	a811                	j	80000248 <consoleread+0xe4>
        release(&cons.lock);
    80000236:	00011517          	auipc	a0,0x11
    8000023a:	f4a50513          	addi	a0,a0,-182 # 80011180 <cons>
    8000023e:	00001097          	auipc	ra,0x1
    80000242:	a46080e7          	jalr	-1466(ra) # 80000c84 <release>
        return -1;
    80000246:	557d                	li	a0,-1
}
    80000248:	70a6                	ld	ra,104(sp)
    8000024a:	7406                	ld	s0,96(sp)
    8000024c:	64e6                	ld	s1,88(sp)
    8000024e:	6946                	ld	s2,80(sp)
    80000250:	69a6                	ld	s3,72(sp)
    80000252:	6a06                	ld	s4,64(sp)
    80000254:	7ae2                	ld	s5,56(sp)
    80000256:	7b42                	ld	s6,48(sp)
    80000258:	7ba2                	ld	s7,40(sp)
    8000025a:	7c02                	ld	s8,32(sp)
    8000025c:	6ce2                	ld	s9,24(sp)
    8000025e:	6d42                	ld	s10,16(sp)
    80000260:	6165                	addi	sp,sp,112
    80000262:	8082                	ret
      if(n < target){
    80000264:	0009871b          	sext.w	a4,s3
    80000268:	fb677ce3          	bgeu	a4,s6,80000220 <consoleread+0xbc>
        cons.r--;
    8000026c:	00011717          	auipc	a4,0x11
    80000270:	faf72623          	sw	a5,-84(a4) # 80011218 <cons+0x98>
    80000274:	b775                	j	80000220 <consoleread+0xbc>

0000000080000276 <consputc>:
{
    80000276:	1141                	addi	sp,sp,-16
    80000278:	e406                	sd	ra,8(sp)
    8000027a:	e022                	sd	s0,0(sp)
    8000027c:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000027e:	10000793          	li	a5,256
    80000282:	00f50a63          	beq	a0,a5,80000296 <consputc+0x20>
    uartputc_sync(c);
    80000286:	00000097          	auipc	ra,0x0
    8000028a:	560080e7          	jalr	1376(ra) # 800007e6 <uartputc_sync>
}
    8000028e:	60a2                	ld	ra,8(sp)
    80000290:	6402                	ld	s0,0(sp)
    80000292:	0141                	addi	sp,sp,16
    80000294:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000296:	4521                	li	a0,8
    80000298:	00000097          	auipc	ra,0x0
    8000029c:	54e080e7          	jalr	1358(ra) # 800007e6 <uartputc_sync>
    800002a0:	02000513          	li	a0,32
    800002a4:	00000097          	auipc	ra,0x0
    800002a8:	542080e7          	jalr	1346(ra) # 800007e6 <uartputc_sync>
    800002ac:	4521                	li	a0,8
    800002ae:	00000097          	auipc	ra,0x0
    800002b2:	538080e7          	jalr	1336(ra) # 800007e6 <uartputc_sync>
    800002b6:	bfe1                	j	8000028e <consputc+0x18>

00000000800002b8 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002b8:	1101                	addi	sp,sp,-32
    800002ba:	ec06                	sd	ra,24(sp)
    800002bc:	e822                	sd	s0,16(sp)
    800002be:	e426                	sd	s1,8(sp)
    800002c0:	e04a                	sd	s2,0(sp)
    800002c2:	1000                	addi	s0,sp,32
    800002c4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c6:	00011517          	auipc	a0,0x11
    800002ca:	eba50513          	addi	a0,a0,-326 # 80011180 <cons>
    800002ce:	00001097          	auipc	ra,0x1
    800002d2:	902080e7          	jalr	-1790(ra) # 80000bd0 <acquire>

  switch(c){
    800002d6:	47d5                	li	a5,21
    800002d8:	0af48663          	beq	s1,a5,80000384 <consoleintr+0xcc>
    800002dc:	0297ca63          	blt	a5,s1,80000310 <consoleintr+0x58>
    800002e0:	47a1                	li	a5,8
    800002e2:	0ef48763          	beq	s1,a5,800003d0 <consoleintr+0x118>
    800002e6:	47c1                	li	a5,16
    800002e8:	10f49a63          	bne	s1,a5,800003fc <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002ec:	00002097          	auipc	ra,0x2
    800002f0:	1c2080e7          	jalr	450(ra) # 800024ae <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f4:	00011517          	auipc	a0,0x11
    800002f8:	e8c50513          	addi	a0,a0,-372 # 80011180 <cons>
    800002fc:	00001097          	auipc	ra,0x1
    80000300:	988080e7          	jalr	-1656(ra) # 80000c84 <release>
}
    80000304:	60e2                	ld	ra,24(sp)
    80000306:	6442                	ld	s0,16(sp)
    80000308:	64a2                	ld	s1,8(sp)
    8000030a:	6902                	ld	s2,0(sp)
    8000030c:	6105                	addi	sp,sp,32
    8000030e:	8082                	ret
  switch(c){
    80000310:	07f00793          	li	a5,127
    80000314:	0af48e63          	beq	s1,a5,800003d0 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000318:	00011717          	auipc	a4,0x11
    8000031c:	e6870713          	addi	a4,a4,-408 # 80011180 <cons>
    80000320:	0a072783          	lw	a5,160(a4)
    80000324:	09872703          	lw	a4,152(a4)
    80000328:	9f99                	subw	a5,a5,a4
    8000032a:	07f00713          	li	a4,127
    8000032e:	fcf763e3          	bltu	a4,a5,800002f4 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000332:	47b5                	li	a5,13
    80000334:	0cf48763          	beq	s1,a5,80000402 <consoleintr+0x14a>
      consputc(c);
    80000338:	8526                	mv	a0,s1
    8000033a:	00000097          	auipc	ra,0x0
    8000033e:	f3c080e7          	jalr	-196(ra) # 80000276 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000342:	00011797          	auipc	a5,0x11
    80000346:	e3e78793          	addi	a5,a5,-450 # 80011180 <cons>
    8000034a:	0a07a703          	lw	a4,160(a5)
    8000034e:	0017069b          	addiw	a3,a4,1
    80000352:	0006861b          	sext.w	a2,a3
    80000356:	0ad7a023          	sw	a3,160(a5)
    8000035a:	07f77713          	andi	a4,a4,127
    8000035e:	97ba                	add	a5,a5,a4
    80000360:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000364:	47a9                	li	a5,10
    80000366:	0cf48563          	beq	s1,a5,80000430 <consoleintr+0x178>
    8000036a:	4791                	li	a5,4
    8000036c:	0cf48263          	beq	s1,a5,80000430 <consoleintr+0x178>
    80000370:	00011797          	auipc	a5,0x11
    80000374:	ea87a783          	lw	a5,-344(a5) # 80011218 <cons+0x98>
    80000378:	0807879b          	addiw	a5,a5,128
    8000037c:	f6f61ce3          	bne	a2,a5,800002f4 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000380:	863e                	mv	a2,a5
    80000382:	a07d                	j	80000430 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000384:	00011717          	auipc	a4,0x11
    80000388:	dfc70713          	addi	a4,a4,-516 # 80011180 <cons>
    8000038c:	0a072783          	lw	a5,160(a4)
    80000390:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000394:	00011497          	auipc	s1,0x11
    80000398:	dec48493          	addi	s1,s1,-532 # 80011180 <cons>
    while(cons.e != cons.w &&
    8000039c:	4929                	li	s2,10
    8000039e:	f4f70be3          	beq	a4,a5,800002f4 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003a2:	37fd                	addiw	a5,a5,-1
    800003a4:	07f7f713          	andi	a4,a5,127
    800003a8:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003aa:	01874703          	lbu	a4,24(a4)
    800003ae:	f52703e3          	beq	a4,s2,800002f4 <consoleintr+0x3c>
      cons.e--;
    800003b2:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003b6:	10000513          	li	a0,256
    800003ba:	00000097          	auipc	ra,0x0
    800003be:	ebc080e7          	jalr	-324(ra) # 80000276 <consputc>
    while(cons.e != cons.w &&
    800003c2:	0a04a783          	lw	a5,160(s1)
    800003c6:	09c4a703          	lw	a4,156(s1)
    800003ca:	fcf71ce3          	bne	a4,a5,800003a2 <consoleintr+0xea>
    800003ce:	b71d                	j	800002f4 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d0:	00011717          	auipc	a4,0x11
    800003d4:	db070713          	addi	a4,a4,-592 # 80011180 <cons>
    800003d8:	0a072783          	lw	a5,160(a4)
    800003dc:	09c72703          	lw	a4,156(a4)
    800003e0:	f0f70ae3          	beq	a4,a5,800002f4 <consoleintr+0x3c>
      cons.e--;
    800003e4:	37fd                	addiw	a5,a5,-1
    800003e6:	00011717          	auipc	a4,0x11
    800003ea:	e2f72d23          	sw	a5,-454(a4) # 80011220 <cons+0xa0>
      consputc(BACKSPACE);
    800003ee:	10000513          	li	a0,256
    800003f2:	00000097          	auipc	ra,0x0
    800003f6:	e84080e7          	jalr	-380(ra) # 80000276 <consputc>
    800003fa:	bded                	j	800002f4 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    800003fc:	ee048ce3          	beqz	s1,800002f4 <consoleintr+0x3c>
    80000400:	bf21                	j	80000318 <consoleintr+0x60>
      consputc(c);
    80000402:	4529                	li	a0,10
    80000404:	00000097          	auipc	ra,0x0
    80000408:	e72080e7          	jalr	-398(ra) # 80000276 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000040c:	00011797          	auipc	a5,0x11
    80000410:	d7478793          	addi	a5,a5,-652 # 80011180 <cons>
    80000414:	0a07a703          	lw	a4,160(a5)
    80000418:	0017069b          	addiw	a3,a4,1
    8000041c:	0006861b          	sext.w	a2,a3
    80000420:	0ad7a023          	sw	a3,160(a5)
    80000424:	07f77713          	andi	a4,a4,127
    80000428:	97ba                	add	a5,a5,a4
    8000042a:	4729                	li	a4,10
    8000042c:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000430:	00011797          	auipc	a5,0x11
    80000434:	dec7a623          	sw	a2,-532(a5) # 8001121c <cons+0x9c>
        wakeup(&cons.r);
    80000438:	00011517          	auipc	a0,0x11
    8000043c:	de050513          	addi	a0,a0,-544 # 80011218 <cons+0x98>
    80000440:	00002097          	auipc	ra,0x2
    80000444:	daa080e7          	jalr	-598(ra) # 800021ea <wakeup>
    80000448:	b575                	j	800002f4 <consoleintr+0x3c>

000000008000044a <consoleinit>:

void
consoleinit(void)
{
    8000044a:	1141                	addi	sp,sp,-16
    8000044c:	e406                	sd	ra,8(sp)
    8000044e:	e022                	sd	s0,0(sp)
    80000450:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000452:	00008597          	auipc	a1,0x8
    80000456:	bbe58593          	addi	a1,a1,-1090 # 80008010 <etext+0x10>
    8000045a:	00011517          	auipc	a0,0x11
    8000045e:	d2650513          	addi	a0,a0,-730 # 80011180 <cons>
    80000462:	00000097          	auipc	ra,0x0
    80000466:	6de080e7          	jalr	1758(ra) # 80000b40 <initlock>

  uartinit();
    8000046a:	00000097          	auipc	ra,0x0
    8000046e:	32c080e7          	jalr	812(ra) # 80000796 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000472:	00021797          	auipc	a5,0x21
    80000476:	ea678793          	addi	a5,a5,-346 # 80021318 <devsw>
    8000047a:	00000717          	auipc	a4,0x0
    8000047e:	cea70713          	addi	a4,a4,-790 # 80000164 <consoleread>
    80000482:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000484:	00000717          	auipc	a4,0x0
    80000488:	c7c70713          	addi	a4,a4,-900 # 80000100 <consolewrite>
    8000048c:	ef98                	sd	a4,24(a5)
}
    8000048e:	60a2                	ld	ra,8(sp)
    80000490:	6402                	ld	s0,0(sp)
    80000492:	0141                	addi	sp,sp,16
    80000494:	8082                	ret

0000000080000496 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000496:	7179                	addi	sp,sp,-48
    80000498:	f406                	sd	ra,40(sp)
    8000049a:	f022                	sd	s0,32(sp)
    8000049c:	ec26                	sd	s1,24(sp)
    8000049e:	e84a                	sd	s2,16(sp)
    800004a0:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a2:	c219                	beqz	a2,800004a8 <printint+0x12>
    800004a4:	08054763          	bltz	a0,80000532 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004a8:	2501                	sext.w	a0,a0
    800004aa:	4881                	li	a7,0
    800004ac:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b0:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b2:	2581                	sext.w	a1,a1
    800004b4:	00008617          	auipc	a2,0x8
    800004b8:	b8c60613          	addi	a2,a2,-1140 # 80008040 <digits>
    800004bc:	883a                	mv	a6,a4
    800004be:	2705                	addiw	a4,a4,1
    800004c0:	02b577bb          	remuw	a5,a0,a1
    800004c4:	1782                	slli	a5,a5,0x20
    800004c6:	9381                	srli	a5,a5,0x20
    800004c8:	97b2                	add	a5,a5,a2
    800004ca:	0007c783          	lbu	a5,0(a5)
    800004ce:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d2:	0005079b          	sext.w	a5,a0
    800004d6:	02b5553b          	divuw	a0,a0,a1
    800004da:	0685                	addi	a3,a3,1
    800004dc:	feb7f0e3          	bgeu	a5,a1,800004bc <printint+0x26>

  if(sign)
    800004e0:	00088c63          	beqz	a7,800004f8 <printint+0x62>
    buf[i++] = '-';
    800004e4:	fe070793          	addi	a5,a4,-32
    800004e8:	00878733          	add	a4,a5,s0
    800004ec:	02d00793          	li	a5,45
    800004f0:	fef70823          	sb	a5,-16(a4)
    800004f4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004f8:	02e05763          	blez	a4,80000526 <printint+0x90>
    800004fc:	fd040793          	addi	a5,s0,-48
    80000500:	00e784b3          	add	s1,a5,a4
    80000504:	fff78913          	addi	s2,a5,-1
    80000508:	993a                	add	s2,s2,a4
    8000050a:	377d                	addiw	a4,a4,-1
    8000050c:	1702                	slli	a4,a4,0x20
    8000050e:	9301                	srli	a4,a4,0x20
    80000510:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000514:	fff4c503          	lbu	a0,-1(s1)
    80000518:	00000097          	auipc	ra,0x0
    8000051c:	d5e080e7          	jalr	-674(ra) # 80000276 <consputc>
  while(--i >= 0)
    80000520:	14fd                	addi	s1,s1,-1
    80000522:	ff2499e3          	bne	s1,s2,80000514 <printint+0x7e>
}
    80000526:	70a2                	ld	ra,40(sp)
    80000528:	7402                	ld	s0,32(sp)
    8000052a:	64e2                	ld	s1,24(sp)
    8000052c:	6942                	ld	s2,16(sp)
    8000052e:	6145                	addi	sp,sp,48
    80000530:	8082                	ret
    x = -xx;
    80000532:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000536:	4885                	li	a7,1
    x = -xx;
    80000538:	bf95                	j	800004ac <printint+0x16>

000000008000053a <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053a:	1101                	addi	sp,sp,-32
    8000053c:	ec06                	sd	ra,24(sp)
    8000053e:	e822                	sd	s0,16(sp)
    80000540:	e426                	sd	s1,8(sp)
    80000542:	1000                	addi	s0,sp,32
    80000544:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000546:	00011797          	auipc	a5,0x11
    8000054a:	ce07ad23          	sw	zero,-774(a5) # 80011240 <pr+0x18>
  printf("panic: ");
    8000054e:	00008517          	auipc	a0,0x8
    80000552:	aca50513          	addi	a0,a0,-1334 # 80008018 <etext+0x18>
    80000556:	00000097          	auipc	ra,0x0
    8000055a:	02e080e7          	jalr	46(ra) # 80000584 <printf>
  printf(s);
    8000055e:	8526                	mv	a0,s1
    80000560:	00000097          	auipc	ra,0x0
    80000564:	024080e7          	jalr	36(ra) # 80000584 <printf>
  printf("\n");
    80000568:	00008517          	auipc	a0,0x8
    8000056c:	b6050513          	addi	a0,a0,-1184 # 800080c8 <digits+0x88>
    80000570:	00000097          	auipc	ra,0x0
    80000574:	014080e7          	jalr	20(ra) # 80000584 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000578:	4785                	li	a5,1
    8000057a:	00009717          	auipc	a4,0x9
    8000057e:	a8f72323          	sw	a5,-1402(a4) # 80009000 <panicked>
  for(;;)
    80000582:	a001                	j	80000582 <panic+0x48>

0000000080000584 <printf>:
{
    80000584:	7131                	addi	sp,sp,-192
    80000586:	fc86                	sd	ra,120(sp)
    80000588:	f8a2                	sd	s0,112(sp)
    8000058a:	f4a6                	sd	s1,104(sp)
    8000058c:	f0ca                	sd	s2,96(sp)
    8000058e:	ecce                	sd	s3,88(sp)
    80000590:	e8d2                	sd	s4,80(sp)
    80000592:	e4d6                	sd	s5,72(sp)
    80000594:	e0da                	sd	s6,64(sp)
    80000596:	fc5e                	sd	s7,56(sp)
    80000598:	f862                	sd	s8,48(sp)
    8000059a:	f466                	sd	s9,40(sp)
    8000059c:	f06a                	sd	s10,32(sp)
    8000059e:	ec6e                	sd	s11,24(sp)
    800005a0:	0100                	addi	s0,sp,128
    800005a2:	8a2a                	mv	s4,a0
    800005a4:	e40c                	sd	a1,8(s0)
    800005a6:	e810                	sd	a2,16(s0)
    800005a8:	ec14                	sd	a3,24(s0)
    800005aa:	f018                	sd	a4,32(s0)
    800005ac:	f41c                	sd	a5,40(s0)
    800005ae:	03043823          	sd	a6,48(s0)
    800005b2:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005b6:	00011d97          	auipc	s11,0x11
    800005ba:	c8adad83          	lw	s11,-886(s11) # 80011240 <pr+0x18>
  if(locking)
    800005be:	020d9b63          	bnez	s11,800005f4 <printf+0x70>
  if (fmt == 0)
    800005c2:	040a0263          	beqz	s4,80000606 <printf+0x82>
  va_start(ap, fmt);
    800005c6:	00840793          	addi	a5,s0,8
    800005ca:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005ce:	000a4503          	lbu	a0,0(s4)
    800005d2:	14050f63          	beqz	a0,80000730 <printf+0x1ac>
    800005d6:	4981                	li	s3,0
    if(c != '%'){
    800005d8:	02500a93          	li	s5,37
    switch(c){
    800005dc:	07000b93          	li	s7,112
  consputc('x');
    800005e0:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e2:	00008b17          	auipc	s6,0x8
    800005e6:	a5eb0b13          	addi	s6,s6,-1442 # 80008040 <digits>
    switch(c){
    800005ea:	07300c93          	li	s9,115
    800005ee:	06400c13          	li	s8,100
    800005f2:	a82d                	j	8000062c <printf+0xa8>
    acquire(&pr.lock);
    800005f4:	00011517          	auipc	a0,0x11
    800005f8:	c3450513          	addi	a0,a0,-972 # 80011228 <pr>
    800005fc:	00000097          	auipc	ra,0x0
    80000600:	5d4080e7          	jalr	1492(ra) # 80000bd0 <acquire>
    80000604:	bf7d                	j	800005c2 <printf+0x3e>
    panic("null fmt");
    80000606:	00008517          	auipc	a0,0x8
    8000060a:	a2250513          	addi	a0,a0,-1502 # 80008028 <etext+0x28>
    8000060e:	00000097          	auipc	ra,0x0
    80000612:	f2c080e7          	jalr	-212(ra) # 8000053a <panic>
      consputc(c);
    80000616:	00000097          	auipc	ra,0x0
    8000061a:	c60080e7          	jalr	-928(ra) # 80000276 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000061e:	2985                	addiw	s3,s3,1
    80000620:	013a07b3          	add	a5,s4,s3
    80000624:	0007c503          	lbu	a0,0(a5)
    80000628:	10050463          	beqz	a0,80000730 <printf+0x1ac>
    if(c != '%'){
    8000062c:	ff5515e3          	bne	a0,s5,80000616 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000630:	2985                	addiw	s3,s3,1
    80000632:	013a07b3          	add	a5,s4,s3
    80000636:	0007c783          	lbu	a5,0(a5)
    8000063a:	0007849b          	sext.w	s1,a5
    if(c == 0)
    8000063e:	cbed                	beqz	a5,80000730 <printf+0x1ac>
    switch(c){
    80000640:	05778a63          	beq	a5,s7,80000694 <printf+0x110>
    80000644:	02fbf663          	bgeu	s7,a5,80000670 <printf+0xec>
    80000648:	09978863          	beq	a5,s9,800006d8 <printf+0x154>
    8000064c:	07800713          	li	a4,120
    80000650:	0ce79563          	bne	a5,a4,8000071a <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000654:	f8843783          	ld	a5,-120(s0)
    80000658:	00878713          	addi	a4,a5,8
    8000065c:	f8e43423          	sd	a4,-120(s0)
    80000660:	4605                	li	a2,1
    80000662:	85ea                	mv	a1,s10
    80000664:	4388                	lw	a0,0(a5)
    80000666:	00000097          	auipc	ra,0x0
    8000066a:	e30080e7          	jalr	-464(ra) # 80000496 <printint>
      break;
    8000066e:	bf45                	j	8000061e <printf+0x9a>
    switch(c){
    80000670:	09578f63          	beq	a5,s5,8000070e <printf+0x18a>
    80000674:	0b879363          	bne	a5,s8,8000071a <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80000678:	f8843783          	ld	a5,-120(s0)
    8000067c:	00878713          	addi	a4,a5,8
    80000680:	f8e43423          	sd	a4,-120(s0)
    80000684:	4605                	li	a2,1
    80000686:	45a9                	li	a1,10
    80000688:	4388                	lw	a0,0(a5)
    8000068a:	00000097          	auipc	ra,0x0
    8000068e:	e0c080e7          	jalr	-500(ra) # 80000496 <printint>
      break;
    80000692:	b771                	j	8000061e <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000694:	f8843783          	ld	a5,-120(s0)
    80000698:	00878713          	addi	a4,a5,8
    8000069c:	f8e43423          	sd	a4,-120(s0)
    800006a0:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a4:	03000513          	li	a0,48
    800006a8:	00000097          	auipc	ra,0x0
    800006ac:	bce080e7          	jalr	-1074(ra) # 80000276 <consputc>
  consputc('x');
    800006b0:	07800513          	li	a0,120
    800006b4:	00000097          	auipc	ra,0x0
    800006b8:	bc2080e7          	jalr	-1086(ra) # 80000276 <consputc>
    800006bc:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006be:	03c95793          	srli	a5,s2,0x3c
    800006c2:	97da                	add	a5,a5,s6
    800006c4:	0007c503          	lbu	a0,0(a5)
    800006c8:	00000097          	auipc	ra,0x0
    800006cc:	bae080e7          	jalr	-1106(ra) # 80000276 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d0:	0912                	slli	s2,s2,0x4
    800006d2:	34fd                	addiw	s1,s1,-1
    800006d4:	f4ed                	bnez	s1,800006be <printf+0x13a>
    800006d6:	b7a1                	j	8000061e <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006d8:	f8843783          	ld	a5,-120(s0)
    800006dc:	00878713          	addi	a4,a5,8
    800006e0:	f8e43423          	sd	a4,-120(s0)
    800006e4:	6384                	ld	s1,0(a5)
    800006e6:	cc89                	beqz	s1,80000700 <printf+0x17c>
      for(; *s; s++)
    800006e8:	0004c503          	lbu	a0,0(s1)
    800006ec:	d90d                	beqz	a0,8000061e <printf+0x9a>
        consputc(*s);
    800006ee:	00000097          	auipc	ra,0x0
    800006f2:	b88080e7          	jalr	-1144(ra) # 80000276 <consputc>
      for(; *s; s++)
    800006f6:	0485                	addi	s1,s1,1
    800006f8:	0004c503          	lbu	a0,0(s1)
    800006fc:	f96d                	bnez	a0,800006ee <printf+0x16a>
    800006fe:	b705                	j	8000061e <printf+0x9a>
        s = "(null)";
    80000700:	00008497          	auipc	s1,0x8
    80000704:	92048493          	addi	s1,s1,-1760 # 80008020 <etext+0x20>
      for(; *s; s++)
    80000708:	02800513          	li	a0,40
    8000070c:	b7cd                	j	800006ee <printf+0x16a>
      consputc('%');
    8000070e:	8556                	mv	a0,s5
    80000710:	00000097          	auipc	ra,0x0
    80000714:	b66080e7          	jalr	-1178(ra) # 80000276 <consputc>
      break;
    80000718:	b719                	j	8000061e <printf+0x9a>
      consputc('%');
    8000071a:	8556                	mv	a0,s5
    8000071c:	00000097          	auipc	ra,0x0
    80000720:	b5a080e7          	jalr	-1190(ra) # 80000276 <consputc>
      consputc(c);
    80000724:	8526                	mv	a0,s1
    80000726:	00000097          	auipc	ra,0x0
    8000072a:	b50080e7          	jalr	-1200(ra) # 80000276 <consputc>
      break;
    8000072e:	bdc5                	j	8000061e <printf+0x9a>
  if(locking)
    80000730:	020d9163          	bnez	s11,80000752 <printf+0x1ce>
}
    80000734:	70e6                	ld	ra,120(sp)
    80000736:	7446                	ld	s0,112(sp)
    80000738:	74a6                	ld	s1,104(sp)
    8000073a:	7906                	ld	s2,96(sp)
    8000073c:	69e6                	ld	s3,88(sp)
    8000073e:	6a46                	ld	s4,80(sp)
    80000740:	6aa6                	ld	s5,72(sp)
    80000742:	6b06                	ld	s6,64(sp)
    80000744:	7be2                	ld	s7,56(sp)
    80000746:	7c42                	ld	s8,48(sp)
    80000748:	7ca2                	ld	s9,40(sp)
    8000074a:	7d02                	ld	s10,32(sp)
    8000074c:	6de2                	ld	s11,24(sp)
    8000074e:	6129                	addi	sp,sp,192
    80000750:	8082                	ret
    release(&pr.lock);
    80000752:	00011517          	auipc	a0,0x11
    80000756:	ad650513          	addi	a0,a0,-1322 # 80011228 <pr>
    8000075a:	00000097          	auipc	ra,0x0
    8000075e:	52a080e7          	jalr	1322(ra) # 80000c84 <release>
}
    80000762:	bfc9                	j	80000734 <printf+0x1b0>

0000000080000764 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000764:	1101                	addi	sp,sp,-32
    80000766:	ec06                	sd	ra,24(sp)
    80000768:	e822                	sd	s0,16(sp)
    8000076a:	e426                	sd	s1,8(sp)
    8000076c:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000076e:	00011497          	auipc	s1,0x11
    80000772:	aba48493          	addi	s1,s1,-1350 # 80011228 <pr>
    80000776:	00008597          	auipc	a1,0x8
    8000077a:	8c258593          	addi	a1,a1,-1854 # 80008038 <etext+0x38>
    8000077e:	8526                	mv	a0,s1
    80000780:	00000097          	auipc	ra,0x0
    80000784:	3c0080e7          	jalr	960(ra) # 80000b40 <initlock>
  pr.locking = 1;
    80000788:	4785                	li	a5,1
    8000078a:	cc9c                	sw	a5,24(s1)
}
    8000078c:	60e2                	ld	ra,24(sp)
    8000078e:	6442                	ld	s0,16(sp)
    80000790:	64a2                	ld	s1,8(sp)
    80000792:	6105                	addi	sp,sp,32
    80000794:	8082                	ret

0000000080000796 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000796:	1141                	addi	sp,sp,-16
    80000798:	e406                	sd	ra,8(sp)
    8000079a:	e022                	sd	s0,0(sp)
    8000079c:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000079e:	100007b7          	lui	a5,0x10000
    800007a2:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007a6:	f8000713          	li	a4,-128
    800007aa:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007ae:	470d                	li	a4,3
    800007b0:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b4:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007b8:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007bc:	469d                	li	a3,7
    800007be:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c2:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007c6:	00008597          	auipc	a1,0x8
    800007ca:	89258593          	addi	a1,a1,-1902 # 80008058 <digits+0x18>
    800007ce:	00011517          	auipc	a0,0x11
    800007d2:	a7a50513          	addi	a0,a0,-1414 # 80011248 <uart_tx_lock>
    800007d6:	00000097          	auipc	ra,0x0
    800007da:	36a080e7          	jalr	874(ra) # 80000b40 <initlock>
}
    800007de:	60a2                	ld	ra,8(sp)
    800007e0:	6402                	ld	s0,0(sp)
    800007e2:	0141                	addi	sp,sp,16
    800007e4:	8082                	ret

00000000800007e6 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007e6:	1101                	addi	sp,sp,-32
    800007e8:	ec06                	sd	ra,24(sp)
    800007ea:	e822                	sd	s0,16(sp)
    800007ec:	e426                	sd	s1,8(sp)
    800007ee:	1000                	addi	s0,sp,32
    800007f0:	84aa                	mv	s1,a0
  push_off();
    800007f2:	00000097          	auipc	ra,0x0
    800007f6:	392080e7          	jalr	914(ra) # 80000b84 <push_off>

  if(panicked){
    800007fa:	00009797          	auipc	a5,0x9
    800007fe:	8067a783          	lw	a5,-2042(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000802:	10000737          	lui	a4,0x10000
  if(panicked){
    80000806:	c391                	beqz	a5,8000080a <uartputc_sync+0x24>
    for(;;)
    80000808:	a001                	j	80000808 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080a:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000080e:	0207f793          	andi	a5,a5,32
    80000812:	dfe5                	beqz	a5,8000080a <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000814:	0ff4f513          	zext.b	a0,s1
    80000818:	100007b7          	lui	a5,0x10000
    8000081c:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000820:	00000097          	auipc	ra,0x0
    80000824:	404080e7          	jalr	1028(ra) # 80000c24 <pop_off>
}
    80000828:	60e2                	ld	ra,24(sp)
    8000082a:	6442                	ld	s0,16(sp)
    8000082c:	64a2                	ld	s1,8(sp)
    8000082e:	6105                	addi	sp,sp,32
    80000830:	8082                	ret

0000000080000832 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000832:	00008797          	auipc	a5,0x8
    80000836:	7d67b783          	ld	a5,2006(a5) # 80009008 <uart_tx_r>
    8000083a:	00008717          	auipc	a4,0x8
    8000083e:	7d673703          	ld	a4,2006(a4) # 80009010 <uart_tx_w>
    80000842:	06f70a63          	beq	a4,a5,800008b6 <uartstart+0x84>
{
    80000846:	7139                	addi	sp,sp,-64
    80000848:	fc06                	sd	ra,56(sp)
    8000084a:	f822                	sd	s0,48(sp)
    8000084c:	f426                	sd	s1,40(sp)
    8000084e:	f04a                	sd	s2,32(sp)
    80000850:	ec4e                	sd	s3,24(sp)
    80000852:	e852                	sd	s4,16(sp)
    80000854:	e456                	sd	s5,8(sp)
    80000856:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000858:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000085c:	00011a17          	auipc	s4,0x11
    80000860:	9eca0a13          	addi	s4,s4,-1556 # 80011248 <uart_tx_lock>
    uart_tx_r += 1;
    80000864:	00008497          	auipc	s1,0x8
    80000868:	7a448493          	addi	s1,s1,1956 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086c:	00008997          	auipc	s3,0x8
    80000870:	7a498993          	addi	s3,s3,1956 # 80009010 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000874:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000878:	02077713          	andi	a4,a4,32
    8000087c:	c705                	beqz	a4,800008a4 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000087e:	01f7f713          	andi	a4,a5,31
    80000882:	9752                	add	a4,a4,s4
    80000884:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    80000888:	0785                	addi	a5,a5,1
    8000088a:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000088c:	8526                	mv	a0,s1
    8000088e:	00002097          	auipc	ra,0x2
    80000892:	95c080e7          	jalr	-1700(ra) # 800021ea <wakeup>
    
    WriteReg(THR, c);
    80000896:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089a:	609c                	ld	a5,0(s1)
    8000089c:	0009b703          	ld	a4,0(s3)
    800008a0:	fcf71ae3          	bne	a4,a5,80000874 <uartstart+0x42>
  }
}
    800008a4:	70e2                	ld	ra,56(sp)
    800008a6:	7442                	ld	s0,48(sp)
    800008a8:	74a2                	ld	s1,40(sp)
    800008aa:	7902                	ld	s2,32(sp)
    800008ac:	69e2                	ld	s3,24(sp)
    800008ae:	6a42                	ld	s4,16(sp)
    800008b0:	6aa2                	ld	s5,8(sp)
    800008b2:	6121                	addi	sp,sp,64
    800008b4:	8082                	ret
    800008b6:	8082                	ret

00000000800008b8 <uartputc>:
{
    800008b8:	7179                	addi	sp,sp,-48
    800008ba:	f406                	sd	ra,40(sp)
    800008bc:	f022                	sd	s0,32(sp)
    800008be:	ec26                	sd	s1,24(sp)
    800008c0:	e84a                	sd	s2,16(sp)
    800008c2:	e44e                	sd	s3,8(sp)
    800008c4:	e052                	sd	s4,0(sp)
    800008c6:	1800                	addi	s0,sp,48
    800008c8:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008ca:	00011517          	auipc	a0,0x11
    800008ce:	97e50513          	addi	a0,a0,-1666 # 80011248 <uart_tx_lock>
    800008d2:	00000097          	auipc	ra,0x0
    800008d6:	2fe080e7          	jalr	766(ra) # 80000bd0 <acquire>
  if(panicked){
    800008da:	00008797          	auipc	a5,0x8
    800008de:	7267a783          	lw	a5,1830(a5) # 80009000 <panicked>
    800008e2:	c391                	beqz	a5,800008e6 <uartputc+0x2e>
    for(;;)
    800008e4:	a001                	j	800008e4 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e6:	00008717          	auipc	a4,0x8
    800008ea:	72a73703          	ld	a4,1834(a4) # 80009010 <uart_tx_w>
    800008ee:	00008797          	auipc	a5,0x8
    800008f2:	71a7b783          	ld	a5,1818(a5) # 80009008 <uart_tx_r>
    800008f6:	02078793          	addi	a5,a5,32
    800008fa:	02e79b63          	bne	a5,a4,80000930 <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    800008fe:	00011997          	auipc	s3,0x11
    80000902:	94a98993          	addi	s3,s3,-1718 # 80011248 <uart_tx_lock>
    80000906:	00008497          	auipc	s1,0x8
    8000090a:	70248493          	addi	s1,s1,1794 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090e:	00008917          	auipc	s2,0x8
    80000912:	70290913          	addi	s2,s2,1794 # 80009010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000916:	85ce                	mv	a1,s3
    80000918:	8526                	mv	a0,s1
    8000091a:	00001097          	auipc	ra,0x1
    8000091e:	744080e7          	jalr	1860(ra) # 8000205e <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000922:	00093703          	ld	a4,0(s2)
    80000926:	609c                	ld	a5,0(s1)
    80000928:	02078793          	addi	a5,a5,32
    8000092c:	fee785e3          	beq	a5,a4,80000916 <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000930:	00011497          	auipc	s1,0x11
    80000934:	91848493          	addi	s1,s1,-1768 # 80011248 <uart_tx_lock>
    80000938:	01f77793          	andi	a5,a4,31
    8000093c:	97a6                	add	a5,a5,s1
    8000093e:	01478c23          	sb	s4,24(a5)
      uart_tx_w += 1;
    80000942:	0705                	addi	a4,a4,1
    80000944:	00008797          	auipc	a5,0x8
    80000948:	6ce7b623          	sd	a4,1740(a5) # 80009010 <uart_tx_w>
      uartstart();
    8000094c:	00000097          	auipc	ra,0x0
    80000950:	ee6080e7          	jalr	-282(ra) # 80000832 <uartstart>
      release(&uart_tx_lock);
    80000954:	8526                	mv	a0,s1
    80000956:	00000097          	auipc	ra,0x0
    8000095a:	32e080e7          	jalr	814(ra) # 80000c84 <release>
}
    8000095e:	70a2                	ld	ra,40(sp)
    80000960:	7402                	ld	s0,32(sp)
    80000962:	64e2                	ld	s1,24(sp)
    80000964:	6942                	ld	s2,16(sp)
    80000966:	69a2                	ld	s3,8(sp)
    80000968:	6a02                	ld	s4,0(sp)
    8000096a:	6145                	addi	sp,sp,48
    8000096c:	8082                	ret

000000008000096e <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000096e:	1141                	addi	sp,sp,-16
    80000970:	e422                	sd	s0,8(sp)
    80000972:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000974:	100007b7          	lui	a5,0x10000
    80000978:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000097c:	8b85                	andi	a5,a5,1
    8000097e:	cb81                	beqz	a5,8000098e <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000980:	100007b7          	lui	a5,0x10000
    80000984:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    80000988:	6422                	ld	s0,8(sp)
    8000098a:	0141                	addi	sp,sp,16
    8000098c:	8082                	ret
    return -1;
    8000098e:	557d                	li	a0,-1
    80000990:	bfe5                	j	80000988 <uartgetc+0x1a>

0000000080000992 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    80000992:	1101                	addi	sp,sp,-32
    80000994:	ec06                	sd	ra,24(sp)
    80000996:	e822                	sd	s0,16(sp)
    80000998:	e426                	sd	s1,8(sp)
    8000099a:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000099c:	54fd                	li	s1,-1
    8000099e:	a029                	j	800009a8 <uartintr+0x16>
      break;
    consoleintr(c);
    800009a0:	00000097          	auipc	ra,0x0
    800009a4:	918080e7          	jalr	-1768(ra) # 800002b8 <consoleintr>
    int c = uartgetc();
    800009a8:	00000097          	auipc	ra,0x0
    800009ac:	fc6080e7          	jalr	-58(ra) # 8000096e <uartgetc>
    if(c == -1)
    800009b0:	fe9518e3          	bne	a0,s1,800009a0 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009b4:	00011497          	auipc	s1,0x11
    800009b8:	89448493          	addi	s1,s1,-1900 # 80011248 <uart_tx_lock>
    800009bc:	8526                	mv	a0,s1
    800009be:	00000097          	auipc	ra,0x0
    800009c2:	212080e7          	jalr	530(ra) # 80000bd0 <acquire>
  uartstart();
    800009c6:	00000097          	auipc	ra,0x0
    800009ca:	e6c080e7          	jalr	-404(ra) # 80000832 <uartstart>
  release(&uart_tx_lock);
    800009ce:	8526                	mv	a0,s1
    800009d0:	00000097          	auipc	ra,0x0
    800009d4:	2b4080e7          	jalr	692(ra) # 80000c84 <release>
}
    800009d8:	60e2                	ld	ra,24(sp)
    800009da:	6442                	ld	s0,16(sp)
    800009dc:	64a2                	ld	s1,8(sp)
    800009de:	6105                	addi	sp,sp,32
    800009e0:	8082                	ret

00000000800009e2 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e2:	1101                	addi	sp,sp,-32
    800009e4:	ec06                	sd	ra,24(sp)
    800009e6:	e822                	sd	s0,16(sp)
    800009e8:	e426                	sd	s1,8(sp)
    800009ea:	e04a                	sd	s2,0(sp)
    800009ec:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009ee:	03451793          	slli	a5,a0,0x34
    800009f2:	ebb9                	bnez	a5,80000a48 <kfree+0x66>
    800009f4:	84aa                	mv	s1,a0
    800009f6:	00025797          	auipc	a5,0x25
    800009fa:	60a78793          	addi	a5,a5,1546 # 80026000 <end>
    800009fe:	04f56563          	bltu	a0,a5,80000a48 <kfree+0x66>
    80000a02:	47c5                	li	a5,17
    80000a04:	07ee                	slli	a5,a5,0x1b
    80000a06:	04f57163          	bgeu	a0,a5,80000a48 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a0a:	6605                	lui	a2,0x1
    80000a0c:	4585                	li	a1,1
    80000a0e:	00000097          	auipc	ra,0x0
    80000a12:	2be080e7          	jalr	702(ra) # 80000ccc <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a16:	00011917          	auipc	s2,0x11
    80000a1a:	86a90913          	addi	s2,s2,-1942 # 80011280 <kmem>
    80000a1e:	854a                	mv	a0,s2
    80000a20:	00000097          	auipc	ra,0x0
    80000a24:	1b0080e7          	jalr	432(ra) # 80000bd0 <acquire>
  r->next = kmem.freelist;
    80000a28:	01893783          	ld	a5,24(s2)
    80000a2c:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a2e:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a32:	854a                	mv	a0,s2
    80000a34:	00000097          	auipc	ra,0x0
    80000a38:	250080e7          	jalr	592(ra) # 80000c84 <release>
}
    80000a3c:	60e2                	ld	ra,24(sp)
    80000a3e:	6442                	ld	s0,16(sp)
    80000a40:	64a2                	ld	s1,8(sp)
    80000a42:	6902                	ld	s2,0(sp)
    80000a44:	6105                	addi	sp,sp,32
    80000a46:	8082                	ret
    panic("kfree");
    80000a48:	00007517          	auipc	a0,0x7
    80000a4c:	61850513          	addi	a0,a0,1560 # 80008060 <digits+0x20>
    80000a50:	00000097          	auipc	ra,0x0
    80000a54:	aea080e7          	jalr	-1302(ra) # 8000053a <panic>

0000000080000a58 <freerange>:
{
    80000a58:	7179                	addi	sp,sp,-48
    80000a5a:	f406                	sd	ra,40(sp)
    80000a5c:	f022                	sd	s0,32(sp)
    80000a5e:	ec26                	sd	s1,24(sp)
    80000a60:	e84a                	sd	s2,16(sp)
    80000a62:	e44e                	sd	s3,8(sp)
    80000a64:	e052                	sd	s4,0(sp)
    80000a66:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a68:	6785                	lui	a5,0x1
    80000a6a:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a6e:	00e504b3          	add	s1,a0,a4
    80000a72:	777d                	lui	a4,0xfffff
    80000a74:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a76:	94be                	add	s1,s1,a5
    80000a78:	0095ee63          	bltu	a1,s1,80000a94 <freerange+0x3c>
    80000a7c:	892e                	mv	s2,a1
    kfree(p);
    80000a7e:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a80:	6985                	lui	s3,0x1
    kfree(p);
    80000a82:	01448533          	add	a0,s1,s4
    80000a86:	00000097          	auipc	ra,0x0
    80000a8a:	f5c080e7          	jalr	-164(ra) # 800009e2 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a8e:	94ce                	add	s1,s1,s3
    80000a90:	fe9979e3          	bgeu	s2,s1,80000a82 <freerange+0x2a>
}
    80000a94:	70a2                	ld	ra,40(sp)
    80000a96:	7402                	ld	s0,32(sp)
    80000a98:	64e2                	ld	s1,24(sp)
    80000a9a:	6942                	ld	s2,16(sp)
    80000a9c:	69a2                	ld	s3,8(sp)
    80000a9e:	6a02                	ld	s4,0(sp)
    80000aa0:	6145                	addi	sp,sp,48
    80000aa2:	8082                	ret

0000000080000aa4 <kinit>:
{
    80000aa4:	1141                	addi	sp,sp,-16
    80000aa6:	e406                	sd	ra,8(sp)
    80000aa8:	e022                	sd	s0,0(sp)
    80000aaa:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000aac:	00007597          	auipc	a1,0x7
    80000ab0:	5bc58593          	addi	a1,a1,1468 # 80008068 <digits+0x28>
    80000ab4:	00010517          	auipc	a0,0x10
    80000ab8:	7cc50513          	addi	a0,a0,1996 # 80011280 <kmem>
    80000abc:	00000097          	auipc	ra,0x0
    80000ac0:	084080e7          	jalr	132(ra) # 80000b40 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ac4:	45c5                	li	a1,17
    80000ac6:	05ee                	slli	a1,a1,0x1b
    80000ac8:	00025517          	auipc	a0,0x25
    80000acc:	53850513          	addi	a0,a0,1336 # 80026000 <end>
    80000ad0:	00000097          	auipc	ra,0x0
    80000ad4:	f88080e7          	jalr	-120(ra) # 80000a58 <freerange>
}
    80000ad8:	60a2                	ld	ra,8(sp)
    80000ada:	6402                	ld	s0,0(sp)
    80000adc:	0141                	addi	sp,sp,16
    80000ade:	8082                	ret

0000000080000ae0 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae0:	1101                	addi	sp,sp,-32
    80000ae2:	ec06                	sd	ra,24(sp)
    80000ae4:	e822                	sd	s0,16(sp)
    80000ae6:	e426                	sd	s1,8(sp)
    80000ae8:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000aea:	00010497          	auipc	s1,0x10
    80000aee:	79648493          	addi	s1,s1,1942 # 80011280 <kmem>
    80000af2:	8526                	mv	a0,s1
    80000af4:	00000097          	auipc	ra,0x0
    80000af8:	0dc080e7          	jalr	220(ra) # 80000bd0 <acquire>
  r = kmem.freelist;
    80000afc:	6c84                	ld	s1,24(s1)
  if(r)
    80000afe:	c885                	beqz	s1,80000b2e <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b00:	609c                	ld	a5,0(s1)
    80000b02:	00010517          	auipc	a0,0x10
    80000b06:	77e50513          	addi	a0,a0,1918 # 80011280 <kmem>
    80000b0a:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b0c:	00000097          	auipc	ra,0x0
    80000b10:	178080e7          	jalr	376(ra) # 80000c84 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b14:	6605                	lui	a2,0x1
    80000b16:	4595                	li	a1,5
    80000b18:	8526                	mv	a0,s1
    80000b1a:	00000097          	auipc	ra,0x0
    80000b1e:	1b2080e7          	jalr	434(ra) # 80000ccc <memset>
  return (void*)r;
}
    80000b22:	8526                	mv	a0,s1
    80000b24:	60e2                	ld	ra,24(sp)
    80000b26:	6442                	ld	s0,16(sp)
    80000b28:	64a2                	ld	s1,8(sp)
    80000b2a:	6105                	addi	sp,sp,32
    80000b2c:	8082                	ret
  release(&kmem.lock);
    80000b2e:	00010517          	auipc	a0,0x10
    80000b32:	75250513          	addi	a0,a0,1874 # 80011280 <kmem>
    80000b36:	00000097          	auipc	ra,0x0
    80000b3a:	14e080e7          	jalr	334(ra) # 80000c84 <release>
  if(r)
    80000b3e:	b7d5                	j	80000b22 <kalloc+0x42>

0000000080000b40 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b40:	1141                	addi	sp,sp,-16
    80000b42:	e422                	sd	s0,8(sp)
    80000b44:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b46:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b48:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b4c:	00053823          	sd	zero,16(a0)
}
    80000b50:	6422                	ld	s0,8(sp)
    80000b52:	0141                	addi	sp,sp,16
    80000b54:	8082                	ret

0000000080000b56 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b56:	411c                	lw	a5,0(a0)
    80000b58:	e399                	bnez	a5,80000b5e <holding+0x8>
    80000b5a:	4501                	li	a0,0
  return r;
}
    80000b5c:	8082                	ret
{
    80000b5e:	1101                	addi	sp,sp,-32
    80000b60:	ec06                	sd	ra,24(sp)
    80000b62:	e822                	sd	s0,16(sp)
    80000b64:	e426                	sd	s1,8(sp)
    80000b66:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b68:	6904                	ld	s1,16(a0)
    80000b6a:	00001097          	auipc	ra,0x1
    80000b6e:	e10080e7          	jalr	-496(ra) # 8000197a <mycpu>
    80000b72:	40a48533          	sub	a0,s1,a0
    80000b76:	00153513          	seqz	a0,a0
}
    80000b7a:	60e2                	ld	ra,24(sp)
    80000b7c:	6442                	ld	s0,16(sp)
    80000b7e:	64a2                	ld	s1,8(sp)
    80000b80:	6105                	addi	sp,sp,32
    80000b82:	8082                	ret

0000000080000b84 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b84:	1101                	addi	sp,sp,-32
    80000b86:	ec06                	sd	ra,24(sp)
    80000b88:	e822                	sd	s0,16(sp)
    80000b8a:	e426                	sd	s1,8(sp)
    80000b8c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b8e:	100024f3          	csrr	s1,sstatus
    80000b92:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b96:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b98:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b9c:	00001097          	auipc	ra,0x1
    80000ba0:	dde080e7          	jalr	-546(ra) # 8000197a <mycpu>
    80000ba4:	5d3c                	lw	a5,120(a0)
    80000ba6:	cf89                	beqz	a5,80000bc0 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000ba8:	00001097          	auipc	ra,0x1
    80000bac:	dd2080e7          	jalr	-558(ra) # 8000197a <mycpu>
    80000bb0:	5d3c                	lw	a5,120(a0)
    80000bb2:	2785                	addiw	a5,a5,1
    80000bb4:	dd3c                	sw	a5,120(a0)
}
    80000bb6:	60e2                	ld	ra,24(sp)
    80000bb8:	6442                	ld	s0,16(sp)
    80000bba:	64a2                	ld	s1,8(sp)
    80000bbc:	6105                	addi	sp,sp,32
    80000bbe:	8082                	ret
    mycpu()->intena = old;
    80000bc0:	00001097          	auipc	ra,0x1
    80000bc4:	dba080e7          	jalr	-582(ra) # 8000197a <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bc8:	8085                	srli	s1,s1,0x1
    80000bca:	8885                	andi	s1,s1,1
    80000bcc:	dd64                	sw	s1,124(a0)
    80000bce:	bfe9                	j	80000ba8 <push_off+0x24>

0000000080000bd0 <acquire>:
{
    80000bd0:	1101                	addi	sp,sp,-32
    80000bd2:	ec06                	sd	ra,24(sp)
    80000bd4:	e822                	sd	s0,16(sp)
    80000bd6:	e426                	sd	s1,8(sp)
    80000bd8:	1000                	addi	s0,sp,32
    80000bda:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bdc:	00000097          	auipc	ra,0x0
    80000be0:	fa8080e7          	jalr	-88(ra) # 80000b84 <push_off>
  if(holding(lk))
    80000be4:	8526                	mv	a0,s1
    80000be6:	00000097          	auipc	ra,0x0
    80000bea:	f70080e7          	jalr	-144(ra) # 80000b56 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bee:	4705                	li	a4,1
  if(holding(lk))
    80000bf0:	e115                	bnez	a0,80000c14 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf2:	87ba                	mv	a5,a4
    80000bf4:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bf8:	2781                	sext.w	a5,a5
    80000bfa:	ffe5                	bnez	a5,80000bf2 <acquire+0x22>
  __sync_synchronize();
    80000bfc:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c00:	00001097          	auipc	ra,0x1
    80000c04:	d7a080e7          	jalr	-646(ra) # 8000197a <mycpu>
    80000c08:	e888                	sd	a0,16(s1)
}
    80000c0a:	60e2                	ld	ra,24(sp)
    80000c0c:	6442                	ld	s0,16(sp)
    80000c0e:	64a2                	ld	s1,8(sp)
    80000c10:	6105                	addi	sp,sp,32
    80000c12:	8082                	ret
    panic("acquire");
    80000c14:	00007517          	auipc	a0,0x7
    80000c18:	45c50513          	addi	a0,a0,1116 # 80008070 <digits+0x30>
    80000c1c:	00000097          	auipc	ra,0x0
    80000c20:	91e080e7          	jalr	-1762(ra) # 8000053a <panic>

0000000080000c24 <pop_off>:

void
pop_off(void)
{
    80000c24:	1141                	addi	sp,sp,-16
    80000c26:	e406                	sd	ra,8(sp)
    80000c28:	e022                	sd	s0,0(sp)
    80000c2a:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c2c:	00001097          	auipc	ra,0x1
    80000c30:	d4e080e7          	jalr	-690(ra) # 8000197a <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c34:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c38:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c3a:	e78d                	bnez	a5,80000c64 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c3c:	5d3c                	lw	a5,120(a0)
    80000c3e:	02f05b63          	blez	a5,80000c74 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c42:	37fd                	addiw	a5,a5,-1
    80000c44:	0007871b          	sext.w	a4,a5
    80000c48:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c4a:	eb09                	bnez	a4,80000c5c <pop_off+0x38>
    80000c4c:	5d7c                	lw	a5,124(a0)
    80000c4e:	c799                	beqz	a5,80000c5c <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c50:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c54:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c58:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c5c:	60a2                	ld	ra,8(sp)
    80000c5e:	6402                	ld	s0,0(sp)
    80000c60:	0141                	addi	sp,sp,16
    80000c62:	8082                	ret
    panic("pop_off - interruptible");
    80000c64:	00007517          	auipc	a0,0x7
    80000c68:	41450513          	addi	a0,a0,1044 # 80008078 <digits+0x38>
    80000c6c:	00000097          	auipc	ra,0x0
    80000c70:	8ce080e7          	jalr	-1842(ra) # 8000053a <panic>
    panic("pop_off");
    80000c74:	00007517          	auipc	a0,0x7
    80000c78:	41c50513          	addi	a0,a0,1052 # 80008090 <digits+0x50>
    80000c7c:	00000097          	auipc	ra,0x0
    80000c80:	8be080e7          	jalr	-1858(ra) # 8000053a <panic>

0000000080000c84 <release>:
{
    80000c84:	1101                	addi	sp,sp,-32
    80000c86:	ec06                	sd	ra,24(sp)
    80000c88:	e822                	sd	s0,16(sp)
    80000c8a:	e426                	sd	s1,8(sp)
    80000c8c:	1000                	addi	s0,sp,32
    80000c8e:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c90:	00000097          	auipc	ra,0x0
    80000c94:	ec6080e7          	jalr	-314(ra) # 80000b56 <holding>
    80000c98:	c115                	beqz	a0,80000cbc <release+0x38>
  lk->cpu = 0;
    80000c9a:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c9e:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca2:	0f50000f          	fence	iorw,ow
    80000ca6:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000caa:	00000097          	auipc	ra,0x0
    80000cae:	f7a080e7          	jalr	-134(ra) # 80000c24 <pop_off>
}
    80000cb2:	60e2                	ld	ra,24(sp)
    80000cb4:	6442                	ld	s0,16(sp)
    80000cb6:	64a2                	ld	s1,8(sp)
    80000cb8:	6105                	addi	sp,sp,32
    80000cba:	8082                	ret
    panic("release");
    80000cbc:	00007517          	auipc	a0,0x7
    80000cc0:	3dc50513          	addi	a0,a0,988 # 80008098 <digits+0x58>
    80000cc4:	00000097          	auipc	ra,0x0
    80000cc8:	876080e7          	jalr	-1930(ra) # 8000053a <panic>

0000000080000ccc <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000ccc:	1141                	addi	sp,sp,-16
    80000cce:	e422                	sd	s0,8(sp)
    80000cd0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd2:	ca19                	beqz	a2,80000ce8 <memset+0x1c>
    80000cd4:	87aa                	mv	a5,a0
    80000cd6:	1602                	slli	a2,a2,0x20
    80000cd8:	9201                	srli	a2,a2,0x20
    80000cda:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cde:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce2:	0785                	addi	a5,a5,1
    80000ce4:	fee79de3          	bne	a5,a4,80000cde <memset+0x12>
  }
  return dst;
}
    80000ce8:	6422                	ld	s0,8(sp)
    80000cea:	0141                	addi	sp,sp,16
    80000cec:	8082                	ret

0000000080000cee <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cee:	1141                	addi	sp,sp,-16
    80000cf0:	e422                	sd	s0,8(sp)
    80000cf2:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf4:	ca05                	beqz	a2,80000d24 <memcmp+0x36>
    80000cf6:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cfa:	1682                	slli	a3,a3,0x20
    80000cfc:	9281                	srli	a3,a3,0x20
    80000cfe:	0685                	addi	a3,a3,1
    80000d00:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d02:	00054783          	lbu	a5,0(a0)
    80000d06:	0005c703          	lbu	a4,0(a1)
    80000d0a:	00e79863          	bne	a5,a4,80000d1a <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d0e:	0505                	addi	a0,a0,1
    80000d10:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d12:	fed518e3          	bne	a0,a3,80000d02 <memcmp+0x14>
  }

  return 0;
    80000d16:	4501                	li	a0,0
    80000d18:	a019                	j	80000d1e <memcmp+0x30>
      return *s1 - *s2;
    80000d1a:	40e7853b          	subw	a0,a5,a4
}
    80000d1e:	6422                	ld	s0,8(sp)
    80000d20:	0141                	addi	sp,sp,16
    80000d22:	8082                	ret
  return 0;
    80000d24:	4501                	li	a0,0
    80000d26:	bfe5                	j	80000d1e <memcmp+0x30>

0000000080000d28 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d28:	1141                	addi	sp,sp,-16
    80000d2a:	e422                	sd	s0,8(sp)
    80000d2c:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d2e:	c205                	beqz	a2,80000d4e <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d30:	02a5e263          	bltu	a1,a0,80000d54 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d34:	1602                	slli	a2,a2,0x20
    80000d36:	9201                	srli	a2,a2,0x20
    80000d38:	00c587b3          	add	a5,a1,a2
{
    80000d3c:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d3e:	0585                	addi	a1,a1,1
    80000d40:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffd9001>
    80000d42:	fff5c683          	lbu	a3,-1(a1)
    80000d46:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d4a:	fef59ae3          	bne	a1,a5,80000d3e <memmove+0x16>

  return dst;
}
    80000d4e:	6422                	ld	s0,8(sp)
    80000d50:	0141                	addi	sp,sp,16
    80000d52:	8082                	ret
  if(s < d && s + n > d){
    80000d54:	02061693          	slli	a3,a2,0x20
    80000d58:	9281                	srli	a3,a3,0x20
    80000d5a:	00d58733          	add	a4,a1,a3
    80000d5e:	fce57be3          	bgeu	a0,a4,80000d34 <memmove+0xc>
    d += n;
    80000d62:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d64:	fff6079b          	addiw	a5,a2,-1
    80000d68:	1782                	slli	a5,a5,0x20
    80000d6a:	9381                	srli	a5,a5,0x20
    80000d6c:	fff7c793          	not	a5,a5
    80000d70:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d72:	177d                	addi	a4,a4,-1
    80000d74:	16fd                	addi	a3,a3,-1
    80000d76:	00074603          	lbu	a2,0(a4)
    80000d7a:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d7e:	fee79ae3          	bne	a5,a4,80000d72 <memmove+0x4a>
    80000d82:	b7f1                	j	80000d4e <memmove+0x26>

0000000080000d84 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d84:	1141                	addi	sp,sp,-16
    80000d86:	e406                	sd	ra,8(sp)
    80000d88:	e022                	sd	s0,0(sp)
    80000d8a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d8c:	00000097          	auipc	ra,0x0
    80000d90:	f9c080e7          	jalr	-100(ra) # 80000d28 <memmove>
}
    80000d94:	60a2                	ld	ra,8(sp)
    80000d96:	6402                	ld	s0,0(sp)
    80000d98:	0141                	addi	sp,sp,16
    80000d9a:	8082                	ret

0000000080000d9c <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d9c:	1141                	addi	sp,sp,-16
    80000d9e:	e422                	sd	s0,8(sp)
    80000da0:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da2:	ce11                	beqz	a2,80000dbe <strncmp+0x22>
    80000da4:	00054783          	lbu	a5,0(a0)
    80000da8:	cf89                	beqz	a5,80000dc2 <strncmp+0x26>
    80000daa:	0005c703          	lbu	a4,0(a1)
    80000dae:	00f71a63          	bne	a4,a5,80000dc2 <strncmp+0x26>
    n--, p++, q++;
    80000db2:	367d                	addiw	a2,a2,-1
    80000db4:	0505                	addi	a0,a0,1
    80000db6:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000db8:	f675                	bnez	a2,80000da4 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dba:	4501                	li	a0,0
    80000dbc:	a809                	j	80000dce <strncmp+0x32>
    80000dbe:	4501                	li	a0,0
    80000dc0:	a039                	j	80000dce <strncmp+0x32>
  if(n == 0)
    80000dc2:	ca09                	beqz	a2,80000dd4 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dc4:	00054503          	lbu	a0,0(a0)
    80000dc8:	0005c783          	lbu	a5,0(a1)
    80000dcc:	9d1d                	subw	a0,a0,a5
}
    80000dce:	6422                	ld	s0,8(sp)
    80000dd0:	0141                	addi	sp,sp,16
    80000dd2:	8082                	ret
    return 0;
    80000dd4:	4501                	li	a0,0
    80000dd6:	bfe5                	j	80000dce <strncmp+0x32>

0000000080000dd8 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dd8:	1141                	addi	sp,sp,-16
    80000dda:	e422                	sd	s0,8(sp)
    80000ddc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dde:	872a                	mv	a4,a0
    80000de0:	8832                	mv	a6,a2
    80000de2:	367d                	addiw	a2,a2,-1
    80000de4:	01005963          	blez	a6,80000df6 <strncpy+0x1e>
    80000de8:	0705                	addi	a4,a4,1
    80000dea:	0005c783          	lbu	a5,0(a1)
    80000dee:	fef70fa3          	sb	a5,-1(a4)
    80000df2:	0585                	addi	a1,a1,1
    80000df4:	f7f5                	bnez	a5,80000de0 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000df6:	86ba                	mv	a3,a4
    80000df8:	00c05c63          	blez	a2,80000e10 <strncpy+0x38>
    *s++ = 0;
    80000dfc:	0685                	addi	a3,a3,1
    80000dfe:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e02:	40d707bb          	subw	a5,a4,a3
    80000e06:	37fd                	addiw	a5,a5,-1
    80000e08:	010787bb          	addw	a5,a5,a6
    80000e0c:	fef048e3          	bgtz	a5,80000dfc <strncpy+0x24>
  return os;
}
    80000e10:	6422                	ld	s0,8(sp)
    80000e12:	0141                	addi	sp,sp,16
    80000e14:	8082                	ret

0000000080000e16 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e16:	1141                	addi	sp,sp,-16
    80000e18:	e422                	sd	s0,8(sp)
    80000e1a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e1c:	02c05363          	blez	a2,80000e42 <safestrcpy+0x2c>
    80000e20:	fff6069b          	addiw	a3,a2,-1
    80000e24:	1682                	slli	a3,a3,0x20
    80000e26:	9281                	srli	a3,a3,0x20
    80000e28:	96ae                	add	a3,a3,a1
    80000e2a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e2c:	00d58963          	beq	a1,a3,80000e3e <safestrcpy+0x28>
    80000e30:	0585                	addi	a1,a1,1
    80000e32:	0785                	addi	a5,a5,1
    80000e34:	fff5c703          	lbu	a4,-1(a1)
    80000e38:	fee78fa3          	sb	a4,-1(a5)
    80000e3c:	fb65                	bnez	a4,80000e2c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e3e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e42:	6422                	ld	s0,8(sp)
    80000e44:	0141                	addi	sp,sp,16
    80000e46:	8082                	ret

0000000080000e48 <strlen>:

int
strlen(const char *s)
{
    80000e48:	1141                	addi	sp,sp,-16
    80000e4a:	e422                	sd	s0,8(sp)
    80000e4c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e4e:	00054783          	lbu	a5,0(a0)
    80000e52:	cf91                	beqz	a5,80000e6e <strlen+0x26>
    80000e54:	0505                	addi	a0,a0,1
    80000e56:	87aa                	mv	a5,a0
    80000e58:	4685                	li	a3,1
    80000e5a:	9e89                	subw	a3,a3,a0
    80000e5c:	00f6853b          	addw	a0,a3,a5
    80000e60:	0785                	addi	a5,a5,1
    80000e62:	fff7c703          	lbu	a4,-1(a5)
    80000e66:	fb7d                	bnez	a4,80000e5c <strlen+0x14>
    ;
  return n;
}
    80000e68:	6422                	ld	s0,8(sp)
    80000e6a:	0141                	addi	sp,sp,16
    80000e6c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e6e:	4501                	li	a0,0
    80000e70:	bfe5                	j	80000e68 <strlen+0x20>

0000000080000e72 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e72:	1141                	addi	sp,sp,-16
    80000e74:	e406                	sd	ra,8(sp)
    80000e76:	e022                	sd	s0,0(sp)
    80000e78:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e7a:	00001097          	auipc	ra,0x1
    80000e7e:	af0080e7          	jalr	-1296(ra) # 8000196a <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e82:	00008717          	auipc	a4,0x8
    80000e86:	19670713          	addi	a4,a4,406 # 80009018 <started>
  if(cpuid() == 0){
    80000e8a:	c139                	beqz	a0,80000ed0 <main+0x5e>
    while(started == 0)
    80000e8c:	431c                	lw	a5,0(a4)
    80000e8e:	2781                	sext.w	a5,a5
    80000e90:	dff5                	beqz	a5,80000e8c <main+0x1a>
      ;
    __sync_synchronize();
    80000e92:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e96:	00001097          	auipc	ra,0x1
    80000e9a:	ad4080e7          	jalr	-1324(ra) # 8000196a <cpuid>
    80000e9e:	85aa                	mv	a1,a0
    80000ea0:	00007517          	auipc	a0,0x7
    80000ea4:	21850513          	addi	a0,a0,536 # 800080b8 <digits+0x78>
    80000ea8:	fffff097          	auipc	ra,0xfffff
    80000eac:	6dc080e7          	jalr	1756(ra) # 80000584 <printf>
    kvminithart();    // turn on paging
    80000eb0:	00000097          	auipc	ra,0x0
    80000eb4:	0d8080e7          	jalr	216(ra) # 80000f88 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb8:	00002097          	auipc	ra,0x2
    80000ebc:	8a6080e7          	jalr	-1882(ra) # 8000275e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec0:	00005097          	auipc	ra,0x5
    80000ec4:	e80080e7          	jalr	-384(ra) # 80005d40 <plicinithart>
  }

  scheduler();        
    80000ec8:	00001097          	auipc	ra,0x1
    80000ecc:	fe4080e7          	jalr	-28(ra) # 80001eac <scheduler>
    consoleinit();
    80000ed0:	fffff097          	auipc	ra,0xfffff
    80000ed4:	57a080e7          	jalr	1402(ra) # 8000044a <consoleinit>
    printfinit();
    80000ed8:	00000097          	auipc	ra,0x0
    80000edc:	88c080e7          	jalr	-1908(ra) # 80000764 <printfinit>
    printf("\n");
    80000ee0:	00007517          	auipc	a0,0x7
    80000ee4:	1e850513          	addi	a0,a0,488 # 800080c8 <digits+0x88>
    80000ee8:	fffff097          	auipc	ra,0xfffff
    80000eec:	69c080e7          	jalr	1692(ra) # 80000584 <printf>
    printf("xv6 kernel is booting\n");
    80000ef0:	00007517          	auipc	a0,0x7
    80000ef4:	1b050513          	addi	a0,a0,432 # 800080a0 <digits+0x60>
    80000ef8:	fffff097          	auipc	ra,0xfffff
    80000efc:	68c080e7          	jalr	1676(ra) # 80000584 <printf>
    printf("\n");
    80000f00:	00007517          	auipc	a0,0x7
    80000f04:	1c850513          	addi	a0,a0,456 # 800080c8 <digits+0x88>
    80000f08:	fffff097          	auipc	ra,0xfffff
    80000f0c:	67c080e7          	jalr	1660(ra) # 80000584 <printf>
    kinit();         // physical page allocator
    80000f10:	00000097          	auipc	ra,0x0
    80000f14:	b94080e7          	jalr	-1132(ra) # 80000aa4 <kinit>
    kvminit();       // create kernel page table
    80000f18:	00000097          	auipc	ra,0x0
    80000f1c:	322080e7          	jalr	802(ra) # 8000123a <kvminit>
    kvminithart();   // turn on paging
    80000f20:	00000097          	auipc	ra,0x0
    80000f24:	068080e7          	jalr	104(ra) # 80000f88 <kvminithart>
    procinit();      // process table
    80000f28:	00001097          	auipc	ra,0x1
    80000f2c:	992080e7          	jalr	-1646(ra) # 800018ba <procinit>
    trapinit();      // trap vectors
    80000f30:	00002097          	auipc	ra,0x2
    80000f34:	806080e7          	jalr	-2042(ra) # 80002736 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f38:	00002097          	auipc	ra,0x2
    80000f3c:	826080e7          	jalr	-2010(ra) # 8000275e <trapinithart>
    plicinit();      // set up interrupt controller
    80000f40:	00005097          	auipc	ra,0x5
    80000f44:	dea080e7          	jalr	-534(ra) # 80005d2a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f48:	00005097          	auipc	ra,0x5
    80000f4c:	df8080e7          	jalr	-520(ra) # 80005d40 <plicinithart>
    binit();         // buffer cache
    80000f50:	00002097          	auipc	ra,0x2
    80000f54:	fba080e7          	jalr	-70(ra) # 80002f0a <binit>
    iinit();         // inode table
    80000f58:	00002097          	auipc	ra,0x2
    80000f5c:	648080e7          	jalr	1608(ra) # 800035a0 <iinit>
    fileinit();      // file table
    80000f60:	00003097          	auipc	ra,0x3
    80000f64:	5fa080e7          	jalr	1530(ra) # 8000455a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f68:	00005097          	auipc	ra,0x5
    80000f6c:	ef8080e7          	jalr	-264(ra) # 80005e60 <virtio_disk_init>
    userinit();      // first user process
    80000f70:	00001097          	auipc	ra,0x1
    80000f74:	d02080e7          	jalr	-766(ra) # 80001c72 <userinit>
    __sync_synchronize();
    80000f78:	0ff0000f          	fence
    started = 1;
    80000f7c:	4785                	li	a5,1
    80000f7e:	00008717          	auipc	a4,0x8
    80000f82:	08f72d23          	sw	a5,154(a4) # 80009018 <started>
    80000f86:	b789                	j	80000ec8 <main+0x56>

0000000080000f88 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f88:	1141                	addi	sp,sp,-16
    80000f8a:	e422                	sd	s0,8(sp)
    80000f8c:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000f8e:	00008797          	auipc	a5,0x8
    80000f92:	0927b783          	ld	a5,146(a5) # 80009020 <kernel_pagetable>
    80000f96:	83b1                	srli	a5,a5,0xc
    80000f98:	577d                	li	a4,-1
    80000f9a:	177e                	slli	a4,a4,0x3f
    80000f9c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f9e:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fa2:	12000073          	sfence.vma
  sfence_vma();
}
    80000fa6:	6422                	ld	s0,8(sp)
    80000fa8:	0141                	addi	sp,sp,16
    80000faa:	8082                	ret

0000000080000fac <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fac:	7139                	addi	sp,sp,-64
    80000fae:	fc06                	sd	ra,56(sp)
    80000fb0:	f822                	sd	s0,48(sp)
    80000fb2:	f426                	sd	s1,40(sp)
    80000fb4:	f04a                	sd	s2,32(sp)
    80000fb6:	ec4e                	sd	s3,24(sp)
    80000fb8:	e852                	sd	s4,16(sp)
    80000fba:	e456                	sd	s5,8(sp)
    80000fbc:	e05a                	sd	s6,0(sp)
    80000fbe:	0080                	addi	s0,sp,64
    80000fc0:	84aa                	mv	s1,a0
    80000fc2:	89ae                	mv	s3,a1
    80000fc4:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fc6:	57fd                	li	a5,-1
    80000fc8:	83e9                	srli	a5,a5,0x1a
    80000fca:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fcc:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fce:	04b7f263          	bgeu	a5,a1,80001012 <walk+0x66>
    panic("walk");
    80000fd2:	00007517          	auipc	a0,0x7
    80000fd6:	0fe50513          	addi	a0,a0,254 # 800080d0 <digits+0x90>
    80000fda:	fffff097          	auipc	ra,0xfffff
    80000fde:	560080e7          	jalr	1376(ra) # 8000053a <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fe2:	060a8663          	beqz	s5,8000104e <walk+0xa2>
    80000fe6:	00000097          	auipc	ra,0x0
    80000fea:	afa080e7          	jalr	-1286(ra) # 80000ae0 <kalloc>
    80000fee:	84aa                	mv	s1,a0
    80000ff0:	c529                	beqz	a0,8000103a <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ff2:	6605                	lui	a2,0x1
    80000ff4:	4581                	li	a1,0
    80000ff6:	00000097          	auipc	ra,0x0
    80000ffa:	cd6080e7          	jalr	-810(ra) # 80000ccc <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000ffe:	00c4d793          	srli	a5,s1,0xc
    80001002:	07aa                	slli	a5,a5,0xa
    80001004:	0017e793          	ori	a5,a5,1
    80001008:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000100c:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffd8ff7>
    8000100e:	036a0063          	beq	s4,s6,8000102e <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001012:	0149d933          	srl	s2,s3,s4
    80001016:	1ff97913          	andi	s2,s2,511
    8000101a:	090e                	slli	s2,s2,0x3
    8000101c:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000101e:	00093483          	ld	s1,0(s2)
    80001022:	0014f793          	andi	a5,s1,1
    80001026:	dfd5                	beqz	a5,80000fe2 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001028:	80a9                	srli	s1,s1,0xa
    8000102a:	04b2                	slli	s1,s1,0xc
    8000102c:	b7c5                	j	8000100c <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000102e:	00c9d513          	srli	a0,s3,0xc
    80001032:	1ff57513          	andi	a0,a0,511
    80001036:	050e                	slli	a0,a0,0x3
    80001038:	9526                	add	a0,a0,s1
}
    8000103a:	70e2                	ld	ra,56(sp)
    8000103c:	7442                	ld	s0,48(sp)
    8000103e:	74a2                	ld	s1,40(sp)
    80001040:	7902                	ld	s2,32(sp)
    80001042:	69e2                	ld	s3,24(sp)
    80001044:	6a42                	ld	s4,16(sp)
    80001046:	6aa2                	ld	s5,8(sp)
    80001048:	6b02                	ld	s6,0(sp)
    8000104a:	6121                	addi	sp,sp,64
    8000104c:	8082                	ret
        return 0;
    8000104e:	4501                	li	a0,0
    80001050:	b7ed                	j	8000103a <walk+0x8e>

0000000080001052 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001052:	57fd                	li	a5,-1
    80001054:	83e9                	srli	a5,a5,0x1a
    80001056:	00b7f463          	bgeu	a5,a1,8000105e <walkaddr+0xc>
    return 0;
    8000105a:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000105c:	8082                	ret
{
    8000105e:	1141                	addi	sp,sp,-16
    80001060:	e406                	sd	ra,8(sp)
    80001062:	e022                	sd	s0,0(sp)
    80001064:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001066:	4601                	li	a2,0
    80001068:	00000097          	auipc	ra,0x0
    8000106c:	f44080e7          	jalr	-188(ra) # 80000fac <walk>
  if(pte == 0)
    80001070:	c105                	beqz	a0,80001090 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001072:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001074:	0117f693          	andi	a3,a5,17
    80001078:	4745                	li	a4,17
    return 0;
    8000107a:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000107c:	00e68663          	beq	a3,a4,80001088 <walkaddr+0x36>
}
    80001080:	60a2                	ld	ra,8(sp)
    80001082:	6402                	ld	s0,0(sp)
    80001084:	0141                	addi	sp,sp,16
    80001086:	8082                	ret
  pa = PTE2PA(*pte);
    80001088:	83a9                	srli	a5,a5,0xa
    8000108a:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000108e:	bfcd                	j	80001080 <walkaddr+0x2e>
    return 0;
    80001090:	4501                	li	a0,0
    80001092:	b7fd                	j	80001080 <walkaddr+0x2e>

0000000080001094 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001094:	715d                	addi	sp,sp,-80
    80001096:	e486                	sd	ra,72(sp)
    80001098:	e0a2                	sd	s0,64(sp)
    8000109a:	fc26                	sd	s1,56(sp)
    8000109c:	f84a                	sd	s2,48(sp)
    8000109e:	f44e                	sd	s3,40(sp)
    800010a0:	f052                	sd	s4,32(sp)
    800010a2:	ec56                	sd	s5,24(sp)
    800010a4:	e85a                	sd	s6,16(sp)
    800010a6:	e45e                	sd	s7,8(sp)
    800010a8:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010aa:	c639                	beqz	a2,800010f8 <mappages+0x64>
    800010ac:	8aaa                	mv	s5,a0
    800010ae:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010b0:	777d                	lui	a4,0xfffff
    800010b2:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010b6:	fff58993          	addi	s3,a1,-1
    800010ba:	99b2                	add	s3,s3,a2
    800010bc:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010c0:	893e                	mv	s2,a5
    800010c2:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010c6:	6b85                	lui	s7,0x1
    800010c8:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010cc:	4605                	li	a2,1
    800010ce:	85ca                	mv	a1,s2
    800010d0:	8556                	mv	a0,s5
    800010d2:	00000097          	auipc	ra,0x0
    800010d6:	eda080e7          	jalr	-294(ra) # 80000fac <walk>
    800010da:	cd1d                	beqz	a0,80001118 <mappages+0x84>
    if(*pte & PTE_V)
    800010dc:	611c                	ld	a5,0(a0)
    800010de:	8b85                	andi	a5,a5,1
    800010e0:	e785                	bnez	a5,80001108 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010e2:	80b1                	srli	s1,s1,0xc
    800010e4:	04aa                	slli	s1,s1,0xa
    800010e6:	0164e4b3          	or	s1,s1,s6
    800010ea:	0014e493          	ori	s1,s1,1
    800010ee:	e104                	sd	s1,0(a0)
    if(a == last)
    800010f0:	05390063          	beq	s2,s3,80001130 <mappages+0x9c>
    a += PGSIZE;
    800010f4:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010f6:	bfc9                	j	800010c8 <mappages+0x34>
    panic("mappages: size");
    800010f8:	00007517          	auipc	a0,0x7
    800010fc:	fe050513          	addi	a0,a0,-32 # 800080d8 <digits+0x98>
    80001100:	fffff097          	auipc	ra,0xfffff
    80001104:	43a080e7          	jalr	1082(ra) # 8000053a <panic>
      panic("mappages: remap");
    80001108:	00007517          	auipc	a0,0x7
    8000110c:	fe050513          	addi	a0,a0,-32 # 800080e8 <digits+0xa8>
    80001110:	fffff097          	auipc	ra,0xfffff
    80001114:	42a080e7          	jalr	1066(ra) # 8000053a <panic>
      return -1;
    80001118:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000111a:	60a6                	ld	ra,72(sp)
    8000111c:	6406                	ld	s0,64(sp)
    8000111e:	74e2                	ld	s1,56(sp)
    80001120:	7942                	ld	s2,48(sp)
    80001122:	79a2                	ld	s3,40(sp)
    80001124:	7a02                	ld	s4,32(sp)
    80001126:	6ae2                	ld	s5,24(sp)
    80001128:	6b42                	ld	s6,16(sp)
    8000112a:	6ba2                	ld	s7,8(sp)
    8000112c:	6161                	addi	sp,sp,80
    8000112e:	8082                	ret
  return 0;
    80001130:	4501                	li	a0,0
    80001132:	b7e5                	j	8000111a <mappages+0x86>

0000000080001134 <kvmmap>:
{
    80001134:	1141                	addi	sp,sp,-16
    80001136:	e406                	sd	ra,8(sp)
    80001138:	e022                	sd	s0,0(sp)
    8000113a:	0800                	addi	s0,sp,16
    8000113c:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000113e:	86b2                	mv	a3,a2
    80001140:	863e                	mv	a2,a5
    80001142:	00000097          	auipc	ra,0x0
    80001146:	f52080e7          	jalr	-174(ra) # 80001094 <mappages>
    8000114a:	e509                	bnez	a0,80001154 <kvmmap+0x20>
}
    8000114c:	60a2                	ld	ra,8(sp)
    8000114e:	6402                	ld	s0,0(sp)
    80001150:	0141                	addi	sp,sp,16
    80001152:	8082                	ret
    panic("kvmmap");
    80001154:	00007517          	auipc	a0,0x7
    80001158:	fa450513          	addi	a0,a0,-92 # 800080f8 <digits+0xb8>
    8000115c:	fffff097          	auipc	ra,0xfffff
    80001160:	3de080e7          	jalr	990(ra) # 8000053a <panic>

0000000080001164 <kvmmake>:
{
    80001164:	1101                	addi	sp,sp,-32
    80001166:	ec06                	sd	ra,24(sp)
    80001168:	e822                	sd	s0,16(sp)
    8000116a:	e426                	sd	s1,8(sp)
    8000116c:	e04a                	sd	s2,0(sp)
    8000116e:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001170:	00000097          	auipc	ra,0x0
    80001174:	970080e7          	jalr	-1680(ra) # 80000ae0 <kalloc>
    80001178:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000117a:	6605                	lui	a2,0x1
    8000117c:	4581                	li	a1,0
    8000117e:	00000097          	auipc	ra,0x0
    80001182:	b4e080e7          	jalr	-1202(ra) # 80000ccc <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001186:	4719                	li	a4,6
    80001188:	6685                	lui	a3,0x1
    8000118a:	10000637          	lui	a2,0x10000
    8000118e:	100005b7          	lui	a1,0x10000
    80001192:	8526                	mv	a0,s1
    80001194:	00000097          	auipc	ra,0x0
    80001198:	fa0080e7          	jalr	-96(ra) # 80001134 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000119c:	4719                	li	a4,6
    8000119e:	6685                	lui	a3,0x1
    800011a0:	10001637          	lui	a2,0x10001
    800011a4:	100015b7          	lui	a1,0x10001
    800011a8:	8526                	mv	a0,s1
    800011aa:	00000097          	auipc	ra,0x0
    800011ae:	f8a080e7          	jalr	-118(ra) # 80001134 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011b2:	4719                	li	a4,6
    800011b4:	004006b7          	lui	a3,0x400
    800011b8:	0c000637          	lui	a2,0xc000
    800011bc:	0c0005b7          	lui	a1,0xc000
    800011c0:	8526                	mv	a0,s1
    800011c2:	00000097          	auipc	ra,0x0
    800011c6:	f72080e7          	jalr	-142(ra) # 80001134 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011ca:	00007917          	auipc	s2,0x7
    800011ce:	e3690913          	addi	s2,s2,-458 # 80008000 <etext>
    800011d2:	4729                	li	a4,10
    800011d4:	80007697          	auipc	a3,0x80007
    800011d8:	e2c68693          	addi	a3,a3,-468 # 8000 <_entry-0x7fff8000>
    800011dc:	4605                	li	a2,1
    800011de:	067e                	slli	a2,a2,0x1f
    800011e0:	85b2                	mv	a1,a2
    800011e2:	8526                	mv	a0,s1
    800011e4:	00000097          	auipc	ra,0x0
    800011e8:	f50080e7          	jalr	-176(ra) # 80001134 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011ec:	4719                	li	a4,6
    800011ee:	46c5                	li	a3,17
    800011f0:	06ee                	slli	a3,a3,0x1b
    800011f2:	412686b3          	sub	a3,a3,s2
    800011f6:	864a                	mv	a2,s2
    800011f8:	85ca                	mv	a1,s2
    800011fa:	8526                	mv	a0,s1
    800011fc:	00000097          	auipc	ra,0x0
    80001200:	f38080e7          	jalr	-200(ra) # 80001134 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001204:	4729                	li	a4,10
    80001206:	6685                	lui	a3,0x1
    80001208:	00006617          	auipc	a2,0x6
    8000120c:	df860613          	addi	a2,a2,-520 # 80007000 <_trampoline>
    80001210:	040005b7          	lui	a1,0x4000
    80001214:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001216:	05b2                	slli	a1,a1,0xc
    80001218:	8526                	mv	a0,s1
    8000121a:	00000097          	auipc	ra,0x0
    8000121e:	f1a080e7          	jalr	-230(ra) # 80001134 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001222:	8526                	mv	a0,s1
    80001224:	00000097          	auipc	ra,0x0
    80001228:	600080e7          	jalr	1536(ra) # 80001824 <proc_mapstacks>
}
    8000122c:	8526                	mv	a0,s1
    8000122e:	60e2                	ld	ra,24(sp)
    80001230:	6442                	ld	s0,16(sp)
    80001232:	64a2                	ld	s1,8(sp)
    80001234:	6902                	ld	s2,0(sp)
    80001236:	6105                	addi	sp,sp,32
    80001238:	8082                	ret

000000008000123a <kvminit>:
{
    8000123a:	1141                	addi	sp,sp,-16
    8000123c:	e406                	sd	ra,8(sp)
    8000123e:	e022                	sd	s0,0(sp)
    80001240:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001242:	00000097          	auipc	ra,0x0
    80001246:	f22080e7          	jalr	-222(ra) # 80001164 <kvmmake>
    8000124a:	00008797          	auipc	a5,0x8
    8000124e:	dca7bb23          	sd	a0,-554(a5) # 80009020 <kernel_pagetable>
}
    80001252:	60a2                	ld	ra,8(sp)
    80001254:	6402                	ld	s0,0(sp)
    80001256:	0141                	addi	sp,sp,16
    80001258:	8082                	ret

000000008000125a <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000125a:	715d                	addi	sp,sp,-80
    8000125c:	e486                	sd	ra,72(sp)
    8000125e:	e0a2                	sd	s0,64(sp)
    80001260:	fc26                	sd	s1,56(sp)
    80001262:	f84a                	sd	s2,48(sp)
    80001264:	f44e                	sd	s3,40(sp)
    80001266:	f052                	sd	s4,32(sp)
    80001268:	ec56                	sd	s5,24(sp)
    8000126a:	e85a                	sd	s6,16(sp)
    8000126c:	e45e                	sd	s7,8(sp)
    8000126e:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001270:	03459793          	slli	a5,a1,0x34
    80001274:	e795                	bnez	a5,800012a0 <uvmunmap+0x46>
    80001276:	8a2a                	mv	s4,a0
    80001278:	892e                	mv	s2,a1
    8000127a:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000127c:	0632                	slli	a2,a2,0xc
    8000127e:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001282:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001284:	6b05                	lui	s6,0x1
    80001286:	0735e263          	bltu	a1,s3,800012ea <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000128a:	60a6                	ld	ra,72(sp)
    8000128c:	6406                	ld	s0,64(sp)
    8000128e:	74e2                	ld	s1,56(sp)
    80001290:	7942                	ld	s2,48(sp)
    80001292:	79a2                	ld	s3,40(sp)
    80001294:	7a02                	ld	s4,32(sp)
    80001296:	6ae2                	ld	s5,24(sp)
    80001298:	6b42                	ld	s6,16(sp)
    8000129a:	6ba2                	ld	s7,8(sp)
    8000129c:	6161                	addi	sp,sp,80
    8000129e:	8082                	ret
    panic("uvmunmap: not aligned");
    800012a0:	00007517          	auipc	a0,0x7
    800012a4:	e6050513          	addi	a0,a0,-416 # 80008100 <digits+0xc0>
    800012a8:	fffff097          	auipc	ra,0xfffff
    800012ac:	292080e7          	jalr	658(ra) # 8000053a <panic>
      panic("uvmunmap: walk");
    800012b0:	00007517          	auipc	a0,0x7
    800012b4:	e6850513          	addi	a0,a0,-408 # 80008118 <digits+0xd8>
    800012b8:	fffff097          	auipc	ra,0xfffff
    800012bc:	282080e7          	jalr	642(ra) # 8000053a <panic>
      panic("uvmunmap: not mapped");
    800012c0:	00007517          	auipc	a0,0x7
    800012c4:	e6850513          	addi	a0,a0,-408 # 80008128 <digits+0xe8>
    800012c8:	fffff097          	auipc	ra,0xfffff
    800012cc:	272080e7          	jalr	626(ra) # 8000053a <panic>
      panic("uvmunmap: not a leaf");
    800012d0:	00007517          	auipc	a0,0x7
    800012d4:	e7050513          	addi	a0,a0,-400 # 80008140 <digits+0x100>
    800012d8:	fffff097          	auipc	ra,0xfffff
    800012dc:	262080e7          	jalr	610(ra) # 8000053a <panic>
    *pte = 0;
    800012e0:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012e4:	995a                	add	s2,s2,s6
    800012e6:	fb3972e3          	bgeu	s2,s3,8000128a <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012ea:	4601                	li	a2,0
    800012ec:	85ca                	mv	a1,s2
    800012ee:	8552                	mv	a0,s4
    800012f0:	00000097          	auipc	ra,0x0
    800012f4:	cbc080e7          	jalr	-836(ra) # 80000fac <walk>
    800012f8:	84aa                	mv	s1,a0
    800012fa:	d95d                	beqz	a0,800012b0 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800012fc:	6108                	ld	a0,0(a0)
    800012fe:	00157793          	andi	a5,a0,1
    80001302:	dfdd                	beqz	a5,800012c0 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001304:	3ff57793          	andi	a5,a0,1023
    80001308:	fd7784e3          	beq	a5,s7,800012d0 <uvmunmap+0x76>
    if(do_free){
    8000130c:	fc0a8ae3          	beqz	s5,800012e0 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001310:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001312:	0532                	slli	a0,a0,0xc
    80001314:	fffff097          	auipc	ra,0xfffff
    80001318:	6ce080e7          	jalr	1742(ra) # 800009e2 <kfree>
    8000131c:	b7d1                	j	800012e0 <uvmunmap+0x86>

000000008000131e <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000131e:	1101                	addi	sp,sp,-32
    80001320:	ec06                	sd	ra,24(sp)
    80001322:	e822                	sd	s0,16(sp)
    80001324:	e426                	sd	s1,8(sp)
    80001326:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001328:	fffff097          	auipc	ra,0xfffff
    8000132c:	7b8080e7          	jalr	1976(ra) # 80000ae0 <kalloc>
    80001330:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001332:	c519                	beqz	a0,80001340 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001334:	6605                	lui	a2,0x1
    80001336:	4581                	li	a1,0
    80001338:	00000097          	auipc	ra,0x0
    8000133c:	994080e7          	jalr	-1644(ra) # 80000ccc <memset>
  return pagetable;
}
    80001340:	8526                	mv	a0,s1
    80001342:	60e2                	ld	ra,24(sp)
    80001344:	6442                	ld	s0,16(sp)
    80001346:	64a2                	ld	s1,8(sp)
    80001348:	6105                	addi	sp,sp,32
    8000134a:	8082                	ret

000000008000134c <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    8000134c:	7179                	addi	sp,sp,-48
    8000134e:	f406                	sd	ra,40(sp)
    80001350:	f022                	sd	s0,32(sp)
    80001352:	ec26                	sd	s1,24(sp)
    80001354:	e84a                	sd	s2,16(sp)
    80001356:	e44e                	sd	s3,8(sp)
    80001358:	e052                	sd	s4,0(sp)
    8000135a:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000135c:	6785                	lui	a5,0x1
    8000135e:	04f67863          	bgeu	a2,a5,800013ae <uvminit+0x62>
    80001362:	8a2a                	mv	s4,a0
    80001364:	89ae                	mv	s3,a1
    80001366:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001368:	fffff097          	auipc	ra,0xfffff
    8000136c:	778080e7          	jalr	1912(ra) # 80000ae0 <kalloc>
    80001370:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001372:	6605                	lui	a2,0x1
    80001374:	4581                	li	a1,0
    80001376:	00000097          	auipc	ra,0x0
    8000137a:	956080e7          	jalr	-1706(ra) # 80000ccc <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000137e:	4779                	li	a4,30
    80001380:	86ca                	mv	a3,s2
    80001382:	6605                	lui	a2,0x1
    80001384:	4581                	li	a1,0
    80001386:	8552                	mv	a0,s4
    80001388:	00000097          	auipc	ra,0x0
    8000138c:	d0c080e7          	jalr	-756(ra) # 80001094 <mappages>
  memmove(mem, src, sz);
    80001390:	8626                	mv	a2,s1
    80001392:	85ce                	mv	a1,s3
    80001394:	854a                	mv	a0,s2
    80001396:	00000097          	auipc	ra,0x0
    8000139a:	992080e7          	jalr	-1646(ra) # 80000d28 <memmove>
}
    8000139e:	70a2                	ld	ra,40(sp)
    800013a0:	7402                	ld	s0,32(sp)
    800013a2:	64e2                	ld	s1,24(sp)
    800013a4:	6942                	ld	s2,16(sp)
    800013a6:	69a2                	ld	s3,8(sp)
    800013a8:	6a02                	ld	s4,0(sp)
    800013aa:	6145                	addi	sp,sp,48
    800013ac:	8082                	ret
    panic("inituvm: more than a page");
    800013ae:	00007517          	auipc	a0,0x7
    800013b2:	daa50513          	addi	a0,a0,-598 # 80008158 <digits+0x118>
    800013b6:	fffff097          	auipc	ra,0xfffff
    800013ba:	184080e7          	jalr	388(ra) # 8000053a <panic>

00000000800013be <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013be:	1101                	addi	sp,sp,-32
    800013c0:	ec06                	sd	ra,24(sp)
    800013c2:	e822                	sd	s0,16(sp)
    800013c4:	e426                	sd	s1,8(sp)
    800013c6:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013c8:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013ca:	00b67d63          	bgeu	a2,a1,800013e4 <uvmdealloc+0x26>
    800013ce:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013d0:	6785                	lui	a5,0x1
    800013d2:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013d4:	00f60733          	add	a4,a2,a5
    800013d8:	76fd                	lui	a3,0xfffff
    800013da:	8f75                	and	a4,a4,a3
    800013dc:	97ae                	add	a5,a5,a1
    800013de:	8ff5                	and	a5,a5,a3
    800013e0:	00f76863          	bltu	a4,a5,800013f0 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013e4:	8526                	mv	a0,s1
    800013e6:	60e2                	ld	ra,24(sp)
    800013e8:	6442                	ld	s0,16(sp)
    800013ea:	64a2                	ld	s1,8(sp)
    800013ec:	6105                	addi	sp,sp,32
    800013ee:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013f0:	8f99                	sub	a5,a5,a4
    800013f2:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013f4:	4685                	li	a3,1
    800013f6:	0007861b          	sext.w	a2,a5
    800013fa:	85ba                	mv	a1,a4
    800013fc:	00000097          	auipc	ra,0x0
    80001400:	e5e080e7          	jalr	-418(ra) # 8000125a <uvmunmap>
    80001404:	b7c5                	j	800013e4 <uvmdealloc+0x26>

0000000080001406 <uvmalloc>:
  if(newsz < oldsz)
    80001406:	0ab66163          	bltu	a2,a1,800014a8 <uvmalloc+0xa2>
{
    8000140a:	7139                	addi	sp,sp,-64
    8000140c:	fc06                	sd	ra,56(sp)
    8000140e:	f822                	sd	s0,48(sp)
    80001410:	f426                	sd	s1,40(sp)
    80001412:	f04a                	sd	s2,32(sp)
    80001414:	ec4e                	sd	s3,24(sp)
    80001416:	e852                	sd	s4,16(sp)
    80001418:	e456                	sd	s5,8(sp)
    8000141a:	0080                	addi	s0,sp,64
    8000141c:	8aaa                	mv	s5,a0
    8000141e:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001420:	6785                	lui	a5,0x1
    80001422:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001424:	95be                	add	a1,a1,a5
    80001426:	77fd                	lui	a5,0xfffff
    80001428:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000142c:	08c9f063          	bgeu	s3,a2,800014ac <uvmalloc+0xa6>
    80001430:	894e                	mv	s2,s3
    mem = kalloc();
    80001432:	fffff097          	auipc	ra,0xfffff
    80001436:	6ae080e7          	jalr	1710(ra) # 80000ae0 <kalloc>
    8000143a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000143c:	c51d                	beqz	a0,8000146a <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000143e:	6605                	lui	a2,0x1
    80001440:	4581                	li	a1,0
    80001442:	00000097          	auipc	ra,0x0
    80001446:	88a080e7          	jalr	-1910(ra) # 80000ccc <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    8000144a:	4779                	li	a4,30
    8000144c:	86a6                	mv	a3,s1
    8000144e:	6605                	lui	a2,0x1
    80001450:	85ca                	mv	a1,s2
    80001452:	8556                	mv	a0,s5
    80001454:	00000097          	auipc	ra,0x0
    80001458:	c40080e7          	jalr	-960(ra) # 80001094 <mappages>
    8000145c:	e905                	bnez	a0,8000148c <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000145e:	6785                	lui	a5,0x1
    80001460:	993e                	add	s2,s2,a5
    80001462:	fd4968e3          	bltu	s2,s4,80001432 <uvmalloc+0x2c>
  return newsz;
    80001466:	8552                	mv	a0,s4
    80001468:	a809                	j	8000147a <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    8000146a:	864e                	mv	a2,s3
    8000146c:	85ca                	mv	a1,s2
    8000146e:	8556                	mv	a0,s5
    80001470:	00000097          	auipc	ra,0x0
    80001474:	f4e080e7          	jalr	-178(ra) # 800013be <uvmdealloc>
      return 0;
    80001478:	4501                	li	a0,0
}
    8000147a:	70e2                	ld	ra,56(sp)
    8000147c:	7442                	ld	s0,48(sp)
    8000147e:	74a2                	ld	s1,40(sp)
    80001480:	7902                	ld	s2,32(sp)
    80001482:	69e2                	ld	s3,24(sp)
    80001484:	6a42                	ld	s4,16(sp)
    80001486:	6aa2                	ld	s5,8(sp)
    80001488:	6121                	addi	sp,sp,64
    8000148a:	8082                	ret
      kfree(mem);
    8000148c:	8526                	mv	a0,s1
    8000148e:	fffff097          	auipc	ra,0xfffff
    80001492:	554080e7          	jalr	1364(ra) # 800009e2 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001496:	864e                	mv	a2,s3
    80001498:	85ca                	mv	a1,s2
    8000149a:	8556                	mv	a0,s5
    8000149c:	00000097          	auipc	ra,0x0
    800014a0:	f22080e7          	jalr	-222(ra) # 800013be <uvmdealloc>
      return 0;
    800014a4:	4501                	li	a0,0
    800014a6:	bfd1                	j	8000147a <uvmalloc+0x74>
    return oldsz;
    800014a8:	852e                	mv	a0,a1
}
    800014aa:	8082                	ret
  return newsz;
    800014ac:	8532                	mv	a0,a2
    800014ae:	b7f1                	j	8000147a <uvmalloc+0x74>

00000000800014b0 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014b0:	7179                	addi	sp,sp,-48
    800014b2:	f406                	sd	ra,40(sp)
    800014b4:	f022                	sd	s0,32(sp)
    800014b6:	ec26                	sd	s1,24(sp)
    800014b8:	e84a                	sd	s2,16(sp)
    800014ba:	e44e                	sd	s3,8(sp)
    800014bc:	e052                	sd	s4,0(sp)
    800014be:	1800                	addi	s0,sp,48
    800014c0:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014c2:	84aa                	mv	s1,a0
    800014c4:	6905                	lui	s2,0x1
    800014c6:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014c8:	4985                	li	s3,1
    800014ca:	a829                	j	800014e4 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014cc:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014ce:	00c79513          	slli	a0,a5,0xc
    800014d2:	00000097          	auipc	ra,0x0
    800014d6:	fde080e7          	jalr	-34(ra) # 800014b0 <freewalk>
      pagetable[i] = 0;
    800014da:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014de:	04a1                	addi	s1,s1,8
    800014e0:	03248163          	beq	s1,s2,80001502 <freewalk+0x52>
    pte_t pte = pagetable[i];
    800014e4:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014e6:	00f7f713          	andi	a4,a5,15
    800014ea:	ff3701e3          	beq	a4,s3,800014cc <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014ee:	8b85                	andi	a5,a5,1
    800014f0:	d7fd                	beqz	a5,800014de <freewalk+0x2e>
      panic("freewalk: leaf");
    800014f2:	00007517          	auipc	a0,0x7
    800014f6:	c8650513          	addi	a0,a0,-890 # 80008178 <digits+0x138>
    800014fa:	fffff097          	auipc	ra,0xfffff
    800014fe:	040080e7          	jalr	64(ra) # 8000053a <panic>
    }
  }
  kfree((void*)pagetable);
    80001502:	8552                	mv	a0,s4
    80001504:	fffff097          	auipc	ra,0xfffff
    80001508:	4de080e7          	jalr	1246(ra) # 800009e2 <kfree>
}
    8000150c:	70a2                	ld	ra,40(sp)
    8000150e:	7402                	ld	s0,32(sp)
    80001510:	64e2                	ld	s1,24(sp)
    80001512:	6942                	ld	s2,16(sp)
    80001514:	69a2                	ld	s3,8(sp)
    80001516:	6a02                	ld	s4,0(sp)
    80001518:	6145                	addi	sp,sp,48
    8000151a:	8082                	ret

000000008000151c <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000151c:	1101                	addi	sp,sp,-32
    8000151e:	ec06                	sd	ra,24(sp)
    80001520:	e822                	sd	s0,16(sp)
    80001522:	e426                	sd	s1,8(sp)
    80001524:	1000                	addi	s0,sp,32
    80001526:	84aa                	mv	s1,a0
  if(sz > 0)
    80001528:	e999                	bnez	a1,8000153e <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000152a:	8526                	mv	a0,s1
    8000152c:	00000097          	auipc	ra,0x0
    80001530:	f84080e7          	jalr	-124(ra) # 800014b0 <freewalk>
}
    80001534:	60e2                	ld	ra,24(sp)
    80001536:	6442                	ld	s0,16(sp)
    80001538:	64a2                	ld	s1,8(sp)
    8000153a:	6105                	addi	sp,sp,32
    8000153c:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000153e:	6785                	lui	a5,0x1
    80001540:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001542:	95be                	add	a1,a1,a5
    80001544:	4685                	li	a3,1
    80001546:	00c5d613          	srli	a2,a1,0xc
    8000154a:	4581                	li	a1,0
    8000154c:	00000097          	auipc	ra,0x0
    80001550:	d0e080e7          	jalr	-754(ra) # 8000125a <uvmunmap>
    80001554:	bfd9                	j	8000152a <uvmfree+0xe>

0000000080001556 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001556:	c679                	beqz	a2,80001624 <uvmcopy+0xce>
{
    80001558:	715d                	addi	sp,sp,-80
    8000155a:	e486                	sd	ra,72(sp)
    8000155c:	e0a2                	sd	s0,64(sp)
    8000155e:	fc26                	sd	s1,56(sp)
    80001560:	f84a                	sd	s2,48(sp)
    80001562:	f44e                	sd	s3,40(sp)
    80001564:	f052                	sd	s4,32(sp)
    80001566:	ec56                	sd	s5,24(sp)
    80001568:	e85a                	sd	s6,16(sp)
    8000156a:	e45e                	sd	s7,8(sp)
    8000156c:	0880                	addi	s0,sp,80
    8000156e:	8b2a                	mv	s6,a0
    80001570:	8aae                	mv	s5,a1
    80001572:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001574:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001576:	4601                	li	a2,0
    80001578:	85ce                	mv	a1,s3
    8000157a:	855a                	mv	a0,s6
    8000157c:	00000097          	auipc	ra,0x0
    80001580:	a30080e7          	jalr	-1488(ra) # 80000fac <walk>
    80001584:	c531                	beqz	a0,800015d0 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001586:	6118                	ld	a4,0(a0)
    80001588:	00177793          	andi	a5,a4,1
    8000158c:	cbb1                	beqz	a5,800015e0 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000158e:	00a75593          	srli	a1,a4,0xa
    80001592:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001596:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    8000159a:	fffff097          	auipc	ra,0xfffff
    8000159e:	546080e7          	jalr	1350(ra) # 80000ae0 <kalloc>
    800015a2:	892a                	mv	s2,a0
    800015a4:	c939                	beqz	a0,800015fa <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015a6:	6605                	lui	a2,0x1
    800015a8:	85de                	mv	a1,s7
    800015aa:	fffff097          	auipc	ra,0xfffff
    800015ae:	77e080e7          	jalr	1918(ra) # 80000d28 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015b2:	8726                	mv	a4,s1
    800015b4:	86ca                	mv	a3,s2
    800015b6:	6605                	lui	a2,0x1
    800015b8:	85ce                	mv	a1,s3
    800015ba:	8556                	mv	a0,s5
    800015bc:	00000097          	auipc	ra,0x0
    800015c0:	ad8080e7          	jalr	-1320(ra) # 80001094 <mappages>
    800015c4:	e515                	bnez	a0,800015f0 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015c6:	6785                	lui	a5,0x1
    800015c8:	99be                	add	s3,s3,a5
    800015ca:	fb49e6e3          	bltu	s3,s4,80001576 <uvmcopy+0x20>
    800015ce:	a081                	j	8000160e <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015d0:	00007517          	auipc	a0,0x7
    800015d4:	bb850513          	addi	a0,a0,-1096 # 80008188 <digits+0x148>
    800015d8:	fffff097          	auipc	ra,0xfffff
    800015dc:	f62080e7          	jalr	-158(ra) # 8000053a <panic>
      panic("uvmcopy: page not present");
    800015e0:	00007517          	auipc	a0,0x7
    800015e4:	bc850513          	addi	a0,a0,-1080 # 800081a8 <digits+0x168>
    800015e8:	fffff097          	auipc	ra,0xfffff
    800015ec:	f52080e7          	jalr	-174(ra) # 8000053a <panic>
      kfree(mem);
    800015f0:	854a                	mv	a0,s2
    800015f2:	fffff097          	auipc	ra,0xfffff
    800015f6:	3f0080e7          	jalr	1008(ra) # 800009e2 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800015fa:	4685                	li	a3,1
    800015fc:	00c9d613          	srli	a2,s3,0xc
    80001600:	4581                	li	a1,0
    80001602:	8556                	mv	a0,s5
    80001604:	00000097          	auipc	ra,0x0
    80001608:	c56080e7          	jalr	-938(ra) # 8000125a <uvmunmap>
  return -1;
    8000160c:	557d                	li	a0,-1
}
    8000160e:	60a6                	ld	ra,72(sp)
    80001610:	6406                	ld	s0,64(sp)
    80001612:	74e2                	ld	s1,56(sp)
    80001614:	7942                	ld	s2,48(sp)
    80001616:	79a2                	ld	s3,40(sp)
    80001618:	7a02                	ld	s4,32(sp)
    8000161a:	6ae2                	ld	s5,24(sp)
    8000161c:	6b42                	ld	s6,16(sp)
    8000161e:	6ba2                	ld	s7,8(sp)
    80001620:	6161                	addi	sp,sp,80
    80001622:	8082                	ret
  return 0;
    80001624:	4501                	li	a0,0
}
    80001626:	8082                	ret

0000000080001628 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001628:	1141                	addi	sp,sp,-16
    8000162a:	e406                	sd	ra,8(sp)
    8000162c:	e022                	sd	s0,0(sp)
    8000162e:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001630:	4601                	li	a2,0
    80001632:	00000097          	auipc	ra,0x0
    80001636:	97a080e7          	jalr	-1670(ra) # 80000fac <walk>
  if(pte == 0)
    8000163a:	c901                	beqz	a0,8000164a <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000163c:	611c                	ld	a5,0(a0)
    8000163e:	9bbd                	andi	a5,a5,-17
    80001640:	e11c                	sd	a5,0(a0)
}
    80001642:	60a2                	ld	ra,8(sp)
    80001644:	6402                	ld	s0,0(sp)
    80001646:	0141                	addi	sp,sp,16
    80001648:	8082                	ret
    panic("uvmclear");
    8000164a:	00007517          	auipc	a0,0x7
    8000164e:	b7e50513          	addi	a0,a0,-1154 # 800081c8 <digits+0x188>
    80001652:	fffff097          	auipc	ra,0xfffff
    80001656:	ee8080e7          	jalr	-280(ra) # 8000053a <panic>

000000008000165a <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000165a:	c6bd                	beqz	a3,800016c8 <copyout+0x6e>
{
    8000165c:	715d                	addi	sp,sp,-80
    8000165e:	e486                	sd	ra,72(sp)
    80001660:	e0a2                	sd	s0,64(sp)
    80001662:	fc26                	sd	s1,56(sp)
    80001664:	f84a                	sd	s2,48(sp)
    80001666:	f44e                	sd	s3,40(sp)
    80001668:	f052                	sd	s4,32(sp)
    8000166a:	ec56                	sd	s5,24(sp)
    8000166c:	e85a                	sd	s6,16(sp)
    8000166e:	e45e                	sd	s7,8(sp)
    80001670:	e062                	sd	s8,0(sp)
    80001672:	0880                	addi	s0,sp,80
    80001674:	8b2a                	mv	s6,a0
    80001676:	8c2e                	mv	s8,a1
    80001678:	8a32                	mv	s4,a2
    8000167a:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000167c:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000167e:	6a85                	lui	s5,0x1
    80001680:	a015                	j	800016a4 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001682:	9562                	add	a0,a0,s8
    80001684:	0004861b          	sext.w	a2,s1
    80001688:	85d2                	mv	a1,s4
    8000168a:	41250533          	sub	a0,a0,s2
    8000168e:	fffff097          	auipc	ra,0xfffff
    80001692:	69a080e7          	jalr	1690(ra) # 80000d28 <memmove>

    len -= n;
    80001696:	409989b3          	sub	s3,s3,s1
    src += n;
    8000169a:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    8000169c:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016a0:	02098263          	beqz	s3,800016c4 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016a4:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016a8:	85ca                	mv	a1,s2
    800016aa:	855a                	mv	a0,s6
    800016ac:	00000097          	auipc	ra,0x0
    800016b0:	9a6080e7          	jalr	-1626(ra) # 80001052 <walkaddr>
    if(pa0 == 0)
    800016b4:	cd01                	beqz	a0,800016cc <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016b6:	418904b3          	sub	s1,s2,s8
    800016ba:	94d6                	add	s1,s1,s5
    800016bc:	fc99f3e3          	bgeu	s3,s1,80001682 <copyout+0x28>
    800016c0:	84ce                	mv	s1,s3
    800016c2:	b7c1                	j	80001682 <copyout+0x28>
  }
  return 0;
    800016c4:	4501                	li	a0,0
    800016c6:	a021                	j	800016ce <copyout+0x74>
    800016c8:	4501                	li	a0,0
}
    800016ca:	8082                	ret
      return -1;
    800016cc:	557d                	li	a0,-1
}
    800016ce:	60a6                	ld	ra,72(sp)
    800016d0:	6406                	ld	s0,64(sp)
    800016d2:	74e2                	ld	s1,56(sp)
    800016d4:	7942                	ld	s2,48(sp)
    800016d6:	79a2                	ld	s3,40(sp)
    800016d8:	7a02                	ld	s4,32(sp)
    800016da:	6ae2                	ld	s5,24(sp)
    800016dc:	6b42                	ld	s6,16(sp)
    800016de:	6ba2                	ld	s7,8(sp)
    800016e0:	6c02                	ld	s8,0(sp)
    800016e2:	6161                	addi	sp,sp,80
    800016e4:	8082                	ret

00000000800016e6 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016e6:	caa5                	beqz	a3,80001756 <copyin+0x70>
{
    800016e8:	715d                	addi	sp,sp,-80
    800016ea:	e486                	sd	ra,72(sp)
    800016ec:	e0a2                	sd	s0,64(sp)
    800016ee:	fc26                	sd	s1,56(sp)
    800016f0:	f84a                	sd	s2,48(sp)
    800016f2:	f44e                	sd	s3,40(sp)
    800016f4:	f052                	sd	s4,32(sp)
    800016f6:	ec56                	sd	s5,24(sp)
    800016f8:	e85a                	sd	s6,16(sp)
    800016fa:	e45e                	sd	s7,8(sp)
    800016fc:	e062                	sd	s8,0(sp)
    800016fe:	0880                	addi	s0,sp,80
    80001700:	8b2a                	mv	s6,a0
    80001702:	8a2e                	mv	s4,a1
    80001704:	8c32                	mv	s8,a2
    80001706:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001708:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000170a:	6a85                	lui	s5,0x1
    8000170c:	a01d                	j	80001732 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000170e:	018505b3          	add	a1,a0,s8
    80001712:	0004861b          	sext.w	a2,s1
    80001716:	412585b3          	sub	a1,a1,s2
    8000171a:	8552                	mv	a0,s4
    8000171c:	fffff097          	auipc	ra,0xfffff
    80001720:	60c080e7          	jalr	1548(ra) # 80000d28 <memmove>

    len -= n;
    80001724:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001728:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000172a:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000172e:	02098263          	beqz	s3,80001752 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001732:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001736:	85ca                	mv	a1,s2
    80001738:	855a                	mv	a0,s6
    8000173a:	00000097          	auipc	ra,0x0
    8000173e:	918080e7          	jalr	-1768(ra) # 80001052 <walkaddr>
    if(pa0 == 0)
    80001742:	cd01                	beqz	a0,8000175a <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001744:	418904b3          	sub	s1,s2,s8
    80001748:	94d6                	add	s1,s1,s5
    8000174a:	fc99f2e3          	bgeu	s3,s1,8000170e <copyin+0x28>
    8000174e:	84ce                	mv	s1,s3
    80001750:	bf7d                	j	8000170e <copyin+0x28>
  }
  return 0;
    80001752:	4501                	li	a0,0
    80001754:	a021                	j	8000175c <copyin+0x76>
    80001756:	4501                	li	a0,0
}
    80001758:	8082                	ret
      return -1;
    8000175a:	557d                	li	a0,-1
}
    8000175c:	60a6                	ld	ra,72(sp)
    8000175e:	6406                	ld	s0,64(sp)
    80001760:	74e2                	ld	s1,56(sp)
    80001762:	7942                	ld	s2,48(sp)
    80001764:	79a2                	ld	s3,40(sp)
    80001766:	7a02                	ld	s4,32(sp)
    80001768:	6ae2                	ld	s5,24(sp)
    8000176a:	6b42                	ld	s6,16(sp)
    8000176c:	6ba2                	ld	s7,8(sp)
    8000176e:	6c02                	ld	s8,0(sp)
    80001770:	6161                	addi	sp,sp,80
    80001772:	8082                	ret

0000000080001774 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001774:	c2dd                	beqz	a3,8000181a <copyinstr+0xa6>
{
    80001776:	715d                	addi	sp,sp,-80
    80001778:	e486                	sd	ra,72(sp)
    8000177a:	e0a2                	sd	s0,64(sp)
    8000177c:	fc26                	sd	s1,56(sp)
    8000177e:	f84a                	sd	s2,48(sp)
    80001780:	f44e                	sd	s3,40(sp)
    80001782:	f052                	sd	s4,32(sp)
    80001784:	ec56                	sd	s5,24(sp)
    80001786:	e85a                	sd	s6,16(sp)
    80001788:	e45e                	sd	s7,8(sp)
    8000178a:	0880                	addi	s0,sp,80
    8000178c:	8a2a                	mv	s4,a0
    8000178e:	8b2e                	mv	s6,a1
    80001790:	8bb2                	mv	s7,a2
    80001792:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001794:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001796:	6985                	lui	s3,0x1
    80001798:	a02d                	j	800017c2 <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000179a:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000179e:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017a0:	37fd                	addiw	a5,a5,-1
    800017a2:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017a6:	60a6                	ld	ra,72(sp)
    800017a8:	6406                	ld	s0,64(sp)
    800017aa:	74e2                	ld	s1,56(sp)
    800017ac:	7942                	ld	s2,48(sp)
    800017ae:	79a2                	ld	s3,40(sp)
    800017b0:	7a02                	ld	s4,32(sp)
    800017b2:	6ae2                	ld	s5,24(sp)
    800017b4:	6b42                	ld	s6,16(sp)
    800017b6:	6ba2                	ld	s7,8(sp)
    800017b8:	6161                	addi	sp,sp,80
    800017ba:	8082                	ret
    srcva = va0 + PGSIZE;
    800017bc:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017c0:	c8a9                	beqz	s1,80001812 <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017c2:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017c6:	85ca                	mv	a1,s2
    800017c8:	8552                	mv	a0,s4
    800017ca:	00000097          	auipc	ra,0x0
    800017ce:	888080e7          	jalr	-1912(ra) # 80001052 <walkaddr>
    if(pa0 == 0)
    800017d2:	c131                	beqz	a0,80001816 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017d4:	417906b3          	sub	a3,s2,s7
    800017d8:	96ce                	add	a3,a3,s3
    800017da:	00d4f363          	bgeu	s1,a3,800017e0 <copyinstr+0x6c>
    800017de:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017e0:	955e                	add	a0,a0,s7
    800017e2:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017e6:	daf9                	beqz	a3,800017bc <copyinstr+0x48>
    800017e8:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017ea:	41650633          	sub	a2,a0,s6
    800017ee:	fff48593          	addi	a1,s1,-1
    800017f2:	95da                	add	a1,a1,s6
    while(n > 0){
    800017f4:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    800017f6:	00f60733          	add	a4,a2,a5
    800017fa:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd9000>
    800017fe:	df51                	beqz	a4,8000179a <copyinstr+0x26>
        *dst = *p;
    80001800:	00e78023          	sb	a4,0(a5)
      --max;
    80001804:	40f584b3          	sub	s1,a1,a5
      dst++;
    80001808:	0785                	addi	a5,a5,1
    while(n > 0){
    8000180a:	fed796e3          	bne	a5,a3,800017f6 <copyinstr+0x82>
      dst++;
    8000180e:	8b3e                	mv	s6,a5
    80001810:	b775                	j	800017bc <copyinstr+0x48>
    80001812:	4781                	li	a5,0
    80001814:	b771                	j	800017a0 <copyinstr+0x2c>
      return -1;
    80001816:	557d                	li	a0,-1
    80001818:	b779                	j	800017a6 <copyinstr+0x32>
  int got_null = 0;
    8000181a:	4781                	li	a5,0
  if(got_null){
    8000181c:	37fd                	addiw	a5,a5,-1
    8000181e:	0007851b          	sext.w	a0,a5
}
    80001822:	8082                	ret

0000000080001824 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    80001824:	7139                	addi	sp,sp,-64
    80001826:	fc06                	sd	ra,56(sp)
    80001828:	f822                	sd	s0,48(sp)
    8000182a:	f426                	sd	s1,40(sp)
    8000182c:	f04a                	sd	s2,32(sp)
    8000182e:	ec4e                	sd	s3,24(sp)
    80001830:	e852                	sd	s4,16(sp)
    80001832:	e456                	sd	s5,8(sp)
    80001834:	e05a                	sd	s6,0(sp)
    80001836:	0080                	addi	s0,sp,64
    80001838:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000183a:	00010497          	auipc	s1,0x10
    8000183e:	e9648493          	addi	s1,s1,-362 # 800116d0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001842:	8b26                	mv	s6,s1
    80001844:	00006a97          	auipc	s5,0x6
    80001848:	7bca8a93          	addi	s5,s5,1980 # 80008000 <etext>
    8000184c:	04000937          	lui	s2,0x4000
    80001850:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001852:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001854:	00016a17          	auipc	s4,0x16
    80001858:	87ca0a13          	addi	s4,s4,-1924 # 800170d0 <tickslock>
    char *pa = kalloc();
    8000185c:	fffff097          	auipc	ra,0xfffff
    80001860:	284080e7          	jalr	644(ra) # 80000ae0 <kalloc>
    80001864:	862a                	mv	a2,a0
    if(pa == 0)
    80001866:	c131                	beqz	a0,800018aa <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001868:	416485b3          	sub	a1,s1,s6
    8000186c:	858d                	srai	a1,a1,0x3
    8000186e:	000ab783          	ld	a5,0(s5)
    80001872:	02f585b3          	mul	a1,a1,a5
    80001876:	2585                	addiw	a1,a1,1
    80001878:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000187c:	4719                	li	a4,6
    8000187e:	6685                	lui	a3,0x1
    80001880:	40b905b3          	sub	a1,s2,a1
    80001884:	854e                	mv	a0,s3
    80001886:	00000097          	auipc	ra,0x0
    8000188a:	8ae080e7          	jalr	-1874(ra) # 80001134 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000188e:	16848493          	addi	s1,s1,360
    80001892:	fd4495e3          	bne	s1,s4,8000185c <proc_mapstacks+0x38>
  }
}
    80001896:	70e2                	ld	ra,56(sp)
    80001898:	7442                	ld	s0,48(sp)
    8000189a:	74a2                	ld	s1,40(sp)
    8000189c:	7902                	ld	s2,32(sp)
    8000189e:	69e2                	ld	s3,24(sp)
    800018a0:	6a42                	ld	s4,16(sp)
    800018a2:	6aa2                	ld	s5,8(sp)
    800018a4:	6b02                	ld	s6,0(sp)
    800018a6:	6121                	addi	sp,sp,64
    800018a8:	8082                	ret
      panic("kalloc");
    800018aa:	00007517          	auipc	a0,0x7
    800018ae:	92e50513          	addi	a0,a0,-1746 # 800081d8 <digits+0x198>
    800018b2:	fffff097          	auipc	ra,0xfffff
    800018b6:	c88080e7          	jalr	-888(ra) # 8000053a <panic>

00000000800018ba <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    800018ba:	7139                	addi	sp,sp,-64
    800018bc:	fc06                	sd	ra,56(sp)
    800018be:	f822                	sd	s0,48(sp)
    800018c0:	f426                	sd	s1,40(sp)
    800018c2:	f04a                	sd	s2,32(sp)
    800018c4:	ec4e                	sd	s3,24(sp)
    800018c6:	e852                	sd	s4,16(sp)
    800018c8:	e456                	sd	s5,8(sp)
    800018ca:	e05a                	sd	s6,0(sp)
    800018cc:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018ce:	00007597          	auipc	a1,0x7
    800018d2:	91258593          	addi	a1,a1,-1774 # 800081e0 <digits+0x1a0>
    800018d6:	00010517          	auipc	a0,0x10
    800018da:	9ca50513          	addi	a0,a0,-1590 # 800112a0 <pid_lock>
    800018de:	fffff097          	auipc	ra,0xfffff
    800018e2:	262080e7          	jalr	610(ra) # 80000b40 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018e6:	00007597          	auipc	a1,0x7
    800018ea:	90258593          	addi	a1,a1,-1790 # 800081e8 <digits+0x1a8>
    800018ee:	00010517          	auipc	a0,0x10
    800018f2:	9ca50513          	addi	a0,a0,-1590 # 800112b8 <wait_lock>
    800018f6:	fffff097          	auipc	ra,0xfffff
    800018fa:	24a080e7          	jalr	586(ra) # 80000b40 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018fe:	00010497          	auipc	s1,0x10
    80001902:	dd248493          	addi	s1,s1,-558 # 800116d0 <proc>
      initlock(&p->lock, "proc");
    80001906:	00007b17          	auipc	s6,0x7
    8000190a:	8f2b0b13          	addi	s6,s6,-1806 # 800081f8 <digits+0x1b8>
      p->kstack = KSTACK((int) (p - proc));
    8000190e:	8aa6                	mv	s5,s1
    80001910:	00006a17          	auipc	s4,0x6
    80001914:	6f0a0a13          	addi	s4,s4,1776 # 80008000 <etext>
    80001918:	04000937          	lui	s2,0x4000
    8000191c:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    8000191e:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001920:	00015997          	auipc	s3,0x15
    80001924:	7b098993          	addi	s3,s3,1968 # 800170d0 <tickslock>
      initlock(&p->lock, "proc");
    80001928:	85da                	mv	a1,s6
    8000192a:	8526                	mv	a0,s1
    8000192c:	fffff097          	auipc	ra,0xfffff
    80001930:	214080e7          	jalr	532(ra) # 80000b40 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    80001934:	415487b3          	sub	a5,s1,s5
    80001938:	878d                	srai	a5,a5,0x3
    8000193a:	000a3703          	ld	a4,0(s4)
    8000193e:	02e787b3          	mul	a5,a5,a4
    80001942:	2785                	addiw	a5,a5,1
    80001944:	00d7979b          	slliw	a5,a5,0xd
    80001948:	40f907b3          	sub	a5,s2,a5
    8000194c:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000194e:	16848493          	addi	s1,s1,360
    80001952:	fd349be3          	bne	s1,s3,80001928 <procinit+0x6e>
  }
}
    80001956:	70e2                	ld	ra,56(sp)
    80001958:	7442                	ld	s0,48(sp)
    8000195a:	74a2                	ld	s1,40(sp)
    8000195c:	7902                	ld	s2,32(sp)
    8000195e:	69e2                	ld	s3,24(sp)
    80001960:	6a42                	ld	s4,16(sp)
    80001962:	6aa2                	ld	s5,8(sp)
    80001964:	6b02                	ld	s6,0(sp)
    80001966:	6121                	addi	sp,sp,64
    80001968:	8082                	ret

000000008000196a <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    8000196a:	1141                	addi	sp,sp,-16
    8000196c:	e422                	sd	s0,8(sp)
    8000196e:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001970:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001972:	2501                	sext.w	a0,a0
    80001974:	6422                	ld	s0,8(sp)
    80001976:	0141                	addi	sp,sp,16
    80001978:	8082                	ret

000000008000197a <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    8000197a:	1141                	addi	sp,sp,-16
    8000197c:	e422                	sd	s0,8(sp)
    8000197e:	0800                	addi	s0,sp,16
    80001980:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001982:	2781                	sext.w	a5,a5
    80001984:	079e                	slli	a5,a5,0x7
  return c;
}
    80001986:	00010517          	auipc	a0,0x10
    8000198a:	94a50513          	addi	a0,a0,-1718 # 800112d0 <cpus>
    8000198e:	953e                	add	a0,a0,a5
    80001990:	6422                	ld	s0,8(sp)
    80001992:	0141                	addi	sp,sp,16
    80001994:	8082                	ret

0000000080001996 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80001996:	1101                	addi	sp,sp,-32
    80001998:	ec06                	sd	ra,24(sp)
    8000199a:	e822                	sd	s0,16(sp)
    8000199c:	e426                	sd	s1,8(sp)
    8000199e:	1000                	addi	s0,sp,32
  push_off();
    800019a0:	fffff097          	auipc	ra,0xfffff
    800019a4:	1e4080e7          	jalr	484(ra) # 80000b84 <push_off>
    800019a8:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019aa:	2781                	sext.w	a5,a5
    800019ac:	079e                	slli	a5,a5,0x7
    800019ae:	00010717          	auipc	a4,0x10
    800019b2:	8f270713          	addi	a4,a4,-1806 # 800112a0 <pid_lock>
    800019b6:	97ba                	add	a5,a5,a4
    800019b8:	7b84                	ld	s1,48(a5)
  pop_off();
    800019ba:	fffff097          	auipc	ra,0xfffff
    800019be:	26a080e7          	jalr	618(ra) # 80000c24 <pop_off>
  return p;
}
    800019c2:	8526                	mv	a0,s1
    800019c4:	60e2                	ld	ra,24(sp)
    800019c6:	6442                	ld	s0,16(sp)
    800019c8:	64a2                	ld	s1,8(sp)
    800019ca:	6105                	addi	sp,sp,32
    800019cc:	8082                	ret

00000000800019ce <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019ce:	1141                	addi	sp,sp,-16
    800019d0:	e406                	sd	ra,8(sp)
    800019d2:	e022                	sd	s0,0(sp)
    800019d4:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019d6:	00000097          	auipc	ra,0x0
    800019da:	fc0080e7          	jalr	-64(ra) # 80001996 <myproc>
    800019de:	fffff097          	auipc	ra,0xfffff
    800019e2:	2a6080e7          	jalr	678(ra) # 80000c84 <release>

  if (first) {
    800019e6:	00007797          	auipc	a5,0x7
    800019ea:	e3a7a783          	lw	a5,-454(a5) # 80008820 <first.1>
    800019ee:	eb89                	bnez	a5,80001a00 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    800019f0:	00001097          	auipc	ra,0x1
    800019f4:	d86080e7          	jalr	-634(ra) # 80002776 <usertrapret>
}
    800019f8:	60a2                	ld	ra,8(sp)
    800019fa:	6402                	ld	s0,0(sp)
    800019fc:	0141                	addi	sp,sp,16
    800019fe:	8082                	ret
    first = 0;
    80001a00:	00007797          	auipc	a5,0x7
    80001a04:	e207a023          	sw	zero,-480(a5) # 80008820 <first.1>
    fsinit(ROOTDEV);
    80001a08:	4505                	li	a0,1
    80001a0a:	00002097          	auipc	ra,0x2
    80001a0e:	b16080e7          	jalr	-1258(ra) # 80003520 <fsinit>
    80001a12:	bff9                	j	800019f0 <forkret+0x22>

0000000080001a14 <allocpid>:
allocpid() {
    80001a14:	1101                	addi	sp,sp,-32
    80001a16:	ec06                	sd	ra,24(sp)
    80001a18:	e822                	sd	s0,16(sp)
    80001a1a:	e426                	sd	s1,8(sp)
    80001a1c:	e04a                	sd	s2,0(sp)
    80001a1e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a20:	00010917          	auipc	s2,0x10
    80001a24:	88090913          	addi	s2,s2,-1920 # 800112a0 <pid_lock>
    80001a28:	854a                	mv	a0,s2
    80001a2a:	fffff097          	auipc	ra,0xfffff
    80001a2e:	1a6080e7          	jalr	422(ra) # 80000bd0 <acquire>
  pid = nextpid;
    80001a32:	00007797          	auipc	a5,0x7
    80001a36:	df278793          	addi	a5,a5,-526 # 80008824 <nextpid>
    80001a3a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a3c:	0014871b          	addiw	a4,s1,1
    80001a40:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a42:	854a                	mv	a0,s2
    80001a44:	fffff097          	auipc	ra,0xfffff
    80001a48:	240080e7          	jalr	576(ra) # 80000c84 <release>
}
    80001a4c:	8526                	mv	a0,s1
    80001a4e:	60e2                	ld	ra,24(sp)
    80001a50:	6442                	ld	s0,16(sp)
    80001a52:	64a2                	ld	s1,8(sp)
    80001a54:	6902                	ld	s2,0(sp)
    80001a56:	6105                	addi	sp,sp,32
    80001a58:	8082                	ret

0000000080001a5a <proc_pagetable>:
{
    80001a5a:	1101                	addi	sp,sp,-32
    80001a5c:	ec06                	sd	ra,24(sp)
    80001a5e:	e822                	sd	s0,16(sp)
    80001a60:	e426                	sd	s1,8(sp)
    80001a62:	e04a                	sd	s2,0(sp)
    80001a64:	1000                	addi	s0,sp,32
    80001a66:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a68:	00000097          	auipc	ra,0x0
    80001a6c:	8b6080e7          	jalr	-1866(ra) # 8000131e <uvmcreate>
    80001a70:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a72:	c121                	beqz	a0,80001ab2 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a74:	4729                	li	a4,10
    80001a76:	00005697          	auipc	a3,0x5
    80001a7a:	58a68693          	addi	a3,a3,1418 # 80007000 <_trampoline>
    80001a7e:	6605                	lui	a2,0x1
    80001a80:	040005b7          	lui	a1,0x4000
    80001a84:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a86:	05b2                	slli	a1,a1,0xc
    80001a88:	fffff097          	auipc	ra,0xfffff
    80001a8c:	60c080e7          	jalr	1548(ra) # 80001094 <mappages>
    80001a90:	02054863          	bltz	a0,80001ac0 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001a94:	4719                	li	a4,6
    80001a96:	05893683          	ld	a3,88(s2)
    80001a9a:	6605                	lui	a2,0x1
    80001a9c:	020005b7          	lui	a1,0x2000
    80001aa0:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001aa2:	05b6                	slli	a1,a1,0xd
    80001aa4:	8526                	mv	a0,s1
    80001aa6:	fffff097          	auipc	ra,0xfffff
    80001aaa:	5ee080e7          	jalr	1518(ra) # 80001094 <mappages>
    80001aae:	02054163          	bltz	a0,80001ad0 <proc_pagetable+0x76>
}
    80001ab2:	8526                	mv	a0,s1
    80001ab4:	60e2                	ld	ra,24(sp)
    80001ab6:	6442                	ld	s0,16(sp)
    80001ab8:	64a2                	ld	s1,8(sp)
    80001aba:	6902                	ld	s2,0(sp)
    80001abc:	6105                	addi	sp,sp,32
    80001abe:	8082                	ret
    uvmfree(pagetable, 0);
    80001ac0:	4581                	li	a1,0
    80001ac2:	8526                	mv	a0,s1
    80001ac4:	00000097          	auipc	ra,0x0
    80001ac8:	a58080e7          	jalr	-1448(ra) # 8000151c <uvmfree>
    return 0;
    80001acc:	4481                	li	s1,0
    80001ace:	b7d5                	j	80001ab2 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ad0:	4681                	li	a3,0
    80001ad2:	4605                	li	a2,1
    80001ad4:	040005b7          	lui	a1,0x4000
    80001ad8:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ada:	05b2                	slli	a1,a1,0xc
    80001adc:	8526                	mv	a0,s1
    80001ade:	fffff097          	auipc	ra,0xfffff
    80001ae2:	77c080e7          	jalr	1916(ra) # 8000125a <uvmunmap>
    uvmfree(pagetable, 0);
    80001ae6:	4581                	li	a1,0
    80001ae8:	8526                	mv	a0,s1
    80001aea:	00000097          	auipc	ra,0x0
    80001aee:	a32080e7          	jalr	-1486(ra) # 8000151c <uvmfree>
    return 0;
    80001af2:	4481                	li	s1,0
    80001af4:	bf7d                	j	80001ab2 <proc_pagetable+0x58>

0000000080001af6 <proc_freepagetable>:
{
    80001af6:	1101                	addi	sp,sp,-32
    80001af8:	ec06                	sd	ra,24(sp)
    80001afa:	e822                	sd	s0,16(sp)
    80001afc:	e426                	sd	s1,8(sp)
    80001afe:	e04a                	sd	s2,0(sp)
    80001b00:	1000                	addi	s0,sp,32
    80001b02:	84aa                	mv	s1,a0
    80001b04:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b06:	4681                	li	a3,0
    80001b08:	4605                	li	a2,1
    80001b0a:	040005b7          	lui	a1,0x4000
    80001b0e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b10:	05b2                	slli	a1,a1,0xc
    80001b12:	fffff097          	auipc	ra,0xfffff
    80001b16:	748080e7          	jalr	1864(ra) # 8000125a <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b1a:	4681                	li	a3,0
    80001b1c:	4605                	li	a2,1
    80001b1e:	020005b7          	lui	a1,0x2000
    80001b22:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b24:	05b6                	slli	a1,a1,0xd
    80001b26:	8526                	mv	a0,s1
    80001b28:	fffff097          	auipc	ra,0xfffff
    80001b2c:	732080e7          	jalr	1842(ra) # 8000125a <uvmunmap>
  uvmfree(pagetable, sz);
    80001b30:	85ca                	mv	a1,s2
    80001b32:	8526                	mv	a0,s1
    80001b34:	00000097          	auipc	ra,0x0
    80001b38:	9e8080e7          	jalr	-1560(ra) # 8000151c <uvmfree>
}
    80001b3c:	60e2                	ld	ra,24(sp)
    80001b3e:	6442                	ld	s0,16(sp)
    80001b40:	64a2                	ld	s1,8(sp)
    80001b42:	6902                	ld	s2,0(sp)
    80001b44:	6105                	addi	sp,sp,32
    80001b46:	8082                	ret

0000000080001b48 <freeproc>:
{
    80001b48:	1101                	addi	sp,sp,-32
    80001b4a:	ec06                	sd	ra,24(sp)
    80001b4c:	e822                	sd	s0,16(sp)
    80001b4e:	e426                	sd	s1,8(sp)
    80001b50:	1000                	addi	s0,sp,32
    80001b52:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b54:	6d28                	ld	a0,88(a0)
    80001b56:	c509                	beqz	a0,80001b60 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b58:	fffff097          	auipc	ra,0xfffff
    80001b5c:	e8a080e7          	jalr	-374(ra) # 800009e2 <kfree>
  p->trapframe = 0;
    80001b60:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b64:	68a8                	ld	a0,80(s1)
    80001b66:	c511                	beqz	a0,80001b72 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b68:	64ac                	ld	a1,72(s1)
    80001b6a:	00000097          	auipc	ra,0x0
    80001b6e:	f8c080e7          	jalr	-116(ra) # 80001af6 <proc_freepagetable>
  p->pagetable = 0;
    80001b72:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b76:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b7a:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b7e:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b82:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b86:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b8a:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b8e:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001b92:	0004ac23          	sw	zero,24(s1)
}
    80001b96:	60e2                	ld	ra,24(sp)
    80001b98:	6442                	ld	s0,16(sp)
    80001b9a:	64a2                	ld	s1,8(sp)
    80001b9c:	6105                	addi	sp,sp,32
    80001b9e:	8082                	ret

0000000080001ba0 <allocproc>:
{
    80001ba0:	1101                	addi	sp,sp,-32
    80001ba2:	ec06                	sd	ra,24(sp)
    80001ba4:	e822                	sd	s0,16(sp)
    80001ba6:	e426                	sd	s1,8(sp)
    80001ba8:	e04a                	sd	s2,0(sp)
    80001baa:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bac:	00010497          	auipc	s1,0x10
    80001bb0:	b2448493          	addi	s1,s1,-1244 # 800116d0 <proc>
    80001bb4:	00015917          	auipc	s2,0x15
    80001bb8:	51c90913          	addi	s2,s2,1308 # 800170d0 <tickslock>
    acquire(&p->lock);
    80001bbc:	8526                	mv	a0,s1
    80001bbe:	fffff097          	auipc	ra,0xfffff
    80001bc2:	012080e7          	jalr	18(ra) # 80000bd0 <acquire>
    if(p->state == UNUSED) {
    80001bc6:	4c9c                	lw	a5,24(s1)
    80001bc8:	cf91                	beqz	a5,80001be4 <allocproc+0x44>
      release(&p->lock);
    80001bca:	8526                	mv	a0,s1
    80001bcc:	fffff097          	auipc	ra,0xfffff
    80001bd0:	0b8080e7          	jalr	184(ra) # 80000c84 <release>
    p->cputime = 0;
    80001bd4:	0204aa23          	sw	zero,52(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bd8:	16848493          	addi	s1,s1,360
    80001bdc:	ff2490e3          	bne	s1,s2,80001bbc <allocproc+0x1c>
  return 0;
    80001be0:	4481                	li	s1,0
    80001be2:	a889                	j	80001c34 <allocproc+0x94>
  p->pid = allocpid();
    80001be4:	00000097          	auipc	ra,0x0
    80001be8:	e30080e7          	jalr	-464(ra) # 80001a14 <allocpid>
    80001bec:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001bee:	4785                	li	a5,1
    80001bf0:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001bf2:	fffff097          	auipc	ra,0xfffff
    80001bf6:	eee080e7          	jalr	-274(ra) # 80000ae0 <kalloc>
    80001bfa:	892a                	mv	s2,a0
    80001bfc:	eca8                	sd	a0,88(s1)
    80001bfe:	c131                	beqz	a0,80001c42 <allocproc+0xa2>
  p->pagetable = proc_pagetable(p);
    80001c00:	8526                	mv	a0,s1
    80001c02:	00000097          	auipc	ra,0x0
    80001c06:	e58080e7          	jalr	-424(ra) # 80001a5a <proc_pagetable>
    80001c0a:	892a                	mv	s2,a0
    80001c0c:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c0e:	c531                	beqz	a0,80001c5a <allocproc+0xba>
  memset(&p->context, 0, sizeof(p->context));
    80001c10:	07000613          	li	a2,112
    80001c14:	4581                	li	a1,0
    80001c16:	06048513          	addi	a0,s1,96
    80001c1a:	fffff097          	auipc	ra,0xfffff
    80001c1e:	0b2080e7          	jalr	178(ra) # 80000ccc <memset>
  p->context.ra = (uint64)forkret;
    80001c22:	00000797          	auipc	a5,0x0
    80001c26:	dac78793          	addi	a5,a5,-596 # 800019ce <forkret>
    80001c2a:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c2c:	60bc                	ld	a5,64(s1)
    80001c2e:	6705                	lui	a4,0x1
    80001c30:	97ba                	add	a5,a5,a4
    80001c32:	f4bc                	sd	a5,104(s1)
}
    80001c34:	8526                	mv	a0,s1
    80001c36:	60e2                	ld	ra,24(sp)
    80001c38:	6442                	ld	s0,16(sp)
    80001c3a:	64a2                	ld	s1,8(sp)
    80001c3c:	6902                	ld	s2,0(sp)
    80001c3e:	6105                	addi	sp,sp,32
    80001c40:	8082                	ret
    freeproc(p);
    80001c42:	8526                	mv	a0,s1
    80001c44:	00000097          	auipc	ra,0x0
    80001c48:	f04080e7          	jalr	-252(ra) # 80001b48 <freeproc>
    release(&p->lock);
    80001c4c:	8526                	mv	a0,s1
    80001c4e:	fffff097          	auipc	ra,0xfffff
    80001c52:	036080e7          	jalr	54(ra) # 80000c84 <release>
    return 0;
    80001c56:	84ca                	mv	s1,s2
    80001c58:	bff1                	j	80001c34 <allocproc+0x94>
    freeproc(p);
    80001c5a:	8526                	mv	a0,s1
    80001c5c:	00000097          	auipc	ra,0x0
    80001c60:	eec080e7          	jalr	-276(ra) # 80001b48 <freeproc>
    release(&p->lock);
    80001c64:	8526                	mv	a0,s1
    80001c66:	fffff097          	auipc	ra,0xfffff
    80001c6a:	01e080e7          	jalr	30(ra) # 80000c84 <release>
    return 0;
    80001c6e:	84ca                	mv	s1,s2
    80001c70:	b7d1                	j	80001c34 <allocproc+0x94>

0000000080001c72 <userinit>:
{
    80001c72:	1101                	addi	sp,sp,-32
    80001c74:	ec06                	sd	ra,24(sp)
    80001c76:	e822                	sd	s0,16(sp)
    80001c78:	e426                	sd	s1,8(sp)
    80001c7a:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c7c:	00000097          	auipc	ra,0x0
    80001c80:	f24080e7          	jalr	-220(ra) # 80001ba0 <allocproc>
    80001c84:	84aa                	mv	s1,a0
  initproc = p;
    80001c86:	00007797          	auipc	a5,0x7
    80001c8a:	3aa7b123          	sd	a0,930(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001c8e:	03400613          	li	a2,52
    80001c92:	00007597          	auipc	a1,0x7
    80001c96:	b9e58593          	addi	a1,a1,-1122 # 80008830 <initcode>
    80001c9a:	6928                	ld	a0,80(a0)
    80001c9c:	fffff097          	auipc	ra,0xfffff
    80001ca0:	6b0080e7          	jalr	1712(ra) # 8000134c <uvminit>
  p->sz = PGSIZE;
    80001ca4:	6785                	lui	a5,0x1
    80001ca6:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001ca8:	6cb8                	ld	a4,88(s1)
    80001caa:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cae:	6cb8                	ld	a4,88(s1)
    80001cb0:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cb2:	4641                	li	a2,16
    80001cb4:	00006597          	auipc	a1,0x6
    80001cb8:	54c58593          	addi	a1,a1,1356 # 80008200 <digits+0x1c0>
    80001cbc:	15848513          	addi	a0,s1,344
    80001cc0:	fffff097          	auipc	ra,0xfffff
    80001cc4:	156080e7          	jalr	342(ra) # 80000e16 <safestrcpy>
  p->cwd = namei("/");
    80001cc8:	00006517          	auipc	a0,0x6
    80001ccc:	54850513          	addi	a0,a0,1352 # 80008210 <digits+0x1d0>
    80001cd0:	00002097          	auipc	ra,0x2
    80001cd4:	286080e7          	jalr	646(ra) # 80003f56 <namei>
    80001cd8:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001cdc:	478d                	li	a5,3
    80001cde:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001ce0:	8526                	mv	a0,s1
    80001ce2:	fffff097          	auipc	ra,0xfffff
    80001ce6:	fa2080e7          	jalr	-94(ra) # 80000c84 <release>
}
    80001cea:	60e2                	ld	ra,24(sp)
    80001cec:	6442                	ld	s0,16(sp)
    80001cee:	64a2                	ld	s1,8(sp)
    80001cf0:	6105                	addi	sp,sp,32
    80001cf2:	8082                	ret

0000000080001cf4 <growproc>:
{
    80001cf4:	1101                	addi	sp,sp,-32
    80001cf6:	ec06                	sd	ra,24(sp)
    80001cf8:	e822                	sd	s0,16(sp)
    80001cfa:	e426                	sd	s1,8(sp)
    80001cfc:	e04a                	sd	s2,0(sp)
    80001cfe:	1000                	addi	s0,sp,32
    80001d00:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d02:	00000097          	auipc	ra,0x0
    80001d06:	c94080e7          	jalr	-876(ra) # 80001996 <myproc>
    80001d0a:	892a                	mv	s2,a0
  sz = p->sz;
    80001d0c:	652c                	ld	a1,72(a0)
    80001d0e:	0005879b          	sext.w	a5,a1
  if(n > 0){
    80001d12:	00904f63          	bgtz	s1,80001d30 <growproc+0x3c>
  } else if(n < 0){
    80001d16:	0204cd63          	bltz	s1,80001d50 <growproc+0x5c>
  p->sz = sz;
    80001d1a:	1782                	slli	a5,a5,0x20
    80001d1c:	9381                	srli	a5,a5,0x20
    80001d1e:	04f93423          	sd	a5,72(s2)
  return 0;
    80001d22:	4501                	li	a0,0
}
    80001d24:	60e2                	ld	ra,24(sp)
    80001d26:	6442                	ld	s0,16(sp)
    80001d28:	64a2                	ld	s1,8(sp)
    80001d2a:	6902                	ld	s2,0(sp)
    80001d2c:	6105                	addi	sp,sp,32
    80001d2e:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001d30:	00f4863b          	addw	a2,s1,a5
    80001d34:	1602                	slli	a2,a2,0x20
    80001d36:	9201                	srli	a2,a2,0x20
    80001d38:	1582                	slli	a1,a1,0x20
    80001d3a:	9181                	srli	a1,a1,0x20
    80001d3c:	6928                	ld	a0,80(a0)
    80001d3e:	fffff097          	auipc	ra,0xfffff
    80001d42:	6c8080e7          	jalr	1736(ra) # 80001406 <uvmalloc>
    80001d46:	0005079b          	sext.w	a5,a0
    80001d4a:	fbe1                	bnez	a5,80001d1a <growproc+0x26>
      return -1;
    80001d4c:	557d                	li	a0,-1
    80001d4e:	bfd9                	j	80001d24 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d50:	00f4863b          	addw	a2,s1,a5
    80001d54:	1602                	slli	a2,a2,0x20
    80001d56:	9201                	srli	a2,a2,0x20
    80001d58:	1582                	slli	a1,a1,0x20
    80001d5a:	9181                	srli	a1,a1,0x20
    80001d5c:	6928                	ld	a0,80(a0)
    80001d5e:	fffff097          	auipc	ra,0xfffff
    80001d62:	660080e7          	jalr	1632(ra) # 800013be <uvmdealloc>
    80001d66:	0005079b          	sext.w	a5,a0
    80001d6a:	bf45                	j	80001d1a <growproc+0x26>

0000000080001d6c <fork>:
{
    80001d6c:	7139                	addi	sp,sp,-64
    80001d6e:	fc06                	sd	ra,56(sp)
    80001d70:	f822                	sd	s0,48(sp)
    80001d72:	f426                	sd	s1,40(sp)
    80001d74:	f04a                	sd	s2,32(sp)
    80001d76:	ec4e                	sd	s3,24(sp)
    80001d78:	e852                	sd	s4,16(sp)
    80001d7a:	e456                	sd	s5,8(sp)
    80001d7c:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d7e:	00000097          	auipc	ra,0x0
    80001d82:	c18080e7          	jalr	-1000(ra) # 80001996 <myproc>
    80001d86:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001d88:	00000097          	auipc	ra,0x0
    80001d8c:	e18080e7          	jalr	-488(ra) # 80001ba0 <allocproc>
    80001d90:	10050c63          	beqz	a0,80001ea8 <fork+0x13c>
    80001d94:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001d96:	048ab603          	ld	a2,72(s5)
    80001d9a:	692c                	ld	a1,80(a0)
    80001d9c:	050ab503          	ld	a0,80(s5)
    80001da0:	fffff097          	auipc	ra,0xfffff
    80001da4:	7b6080e7          	jalr	1974(ra) # 80001556 <uvmcopy>
    80001da8:	04054863          	bltz	a0,80001df8 <fork+0x8c>
  np->sz = p->sz;
    80001dac:	048ab783          	ld	a5,72(s5)
    80001db0:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001db4:	058ab683          	ld	a3,88(s5)
    80001db8:	87b6                	mv	a5,a3
    80001dba:	058a3703          	ld	a4,88(s4)
    80001dbe:	12068693          	addi	a3,a3,288
    80001dc2:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001dc6:	6788                	ld	a0,8(a5)
    80001dc8:	6b8c                	ld	a1,16(a5)
    80001dca:	6f90                	ld	a2,24(a5)
    80001dcc:	01073023          	sd	a6,0(a4)
    80001dd0:	e708                	sd	a0,8(a4)
    80001dd2:	eb0c                	sd	a1,16(a4)
    80001dd4:	ef10                	sd	a2,24(a4)
    80001dd6:	02078793          	addi	a5,a5,32
    80001dda:	02070713          	addi	a4,a4,32
    80001dde:	fed792e3          	bne	a5,a3,80001dc2 <fork+0x56>
  np->trapframe->a0 = 0;
    80001de2:	058a3783          	ld	a5,88(s4)
    80001de6:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001dea:	0d0a8493          	addi	s1,s5,208
    80001dee:	0d0a0913          	addi	s2,s4,208
    80001df2:	150a8993          	addi	s3,s5,336
    80001df6:	a00d                	j	80001e18 <fork+0xac>
    freeproc(np);
    80001df8:	8552                	mv	a0,s4
    80001dfa:	00000097          	auipc	ra,0x0
    80001dfe:	d4e080e7          	jalr	-690(ra) # 80001b48 <freeproc>
    release(&np->lock);
    80001e02:	8552                	mv	a0,s4
    80001e04:	fffff097          	auipc	ra,0xfffff
    80001e08:	e80080e7          	jalr	-384(ra) # 80000c84 <release>
    return -1;
    80001e0c:	597d                	li	s2,-1
    80001e0e:	a059                	j	80001e94 <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001e10:	04a1                	addi	s1,s1,8
    80001e12:	0921                	addi	s2,s2,8
    80001e14:	01348b63          	beq	s1,s3,80001e2a <fork+0xbe>
    if(p->ofile[i])
    80001e18:	6088                	ld	a0,0(s1)
    80001e1a:	d97d                	beqz	a0,80001e10 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e1c:	00002097          	auipc	ra,0x2
    80001e20:	7d0080e7          	jalr	2000(ra) # 800045ec <filedup>
    80001e24:	00a93023          	sd	a0,0(s2)
    80001e28:	b7e5                	j	80001e10 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e2a:	150ab503          	ld	a0,336(s5)
    80001e2e:	00002097          	auipc	ra,0x2
    80001e32:	92e080e7          	jalr	-1746(ra) # 8000375c <idup>
    80001e36:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e3a:	4641                	li	a2,16
    80001e3c:	158a8593          	addi	a1,s5,344
    80001e40:	158a0513          	addi	a0,s4,344
    80001e44:	fffff097          	auipc	ra,0xfffff
    80001e48:	fd2080e7          	jalr	-46(ra) # 80000e16 <safestrcpy>
  pid = np->pid;
    80001e4c:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001e50:	8552                	mv	a0,s4
    80001e52:	fffff097          	auipc	ra,0xfffff
    80001e56:	e32080e7          	jalr	-462(ra) # 80000c84 <release>
  acquire(&wait_lock);
    80001e5a:	0000f497          	auipc	s1,0xf
    80001e5e:	45e48493          	addi	s1,s1,1118 # 800112b8 <wait_lock>
    80001e62:	8526                	mv	a0,s1
    80001e64:	fffff097          	auipc	ra,0xfffff
    80001e68:	d6c080e7          	jalr	-660(ra) # 80000bd0 <acquire>
  np->parent = p;
    80001e6c:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001e70:	8526                	mv	a0,s1
    80001e72:	fffff097          	auipc	ra,0xfffff
    80001e76:	e12080e7          	jalr	-494(ra) # 80000c84 <release>
  acquire(&np->lock);
    80001e7a:	8552                	mv	a0,s4
    80001e7c:	fffff097          	auipc	ra,0xfffff
    80001e80:	d54080e7          	jalr	-684(ra) # 80000bd0 <acquire>
  np->state = RUNNABLE;
    80001e84:	478d                	li	a5,3
    80001e86:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001e8a:	8552                	mv	a0,s4
    80001e8c:	fffff097          	auipc	ra,0xfffff
    80001e90:	df8080e7          	jalr	-520(ra) # 80000c84 <release>
}
    80001e94:	854a                	mv	a0,s2
    80001e96:	70e2                	ld	ra,56(sp)
    80001e98:	7442                	ld	s0,48(sp)
    80001e9a:	74a2                	ld	s1,40(sp)
    80001e9c:	7902                	ld	s2,32(sp)
    80001e9e:	69e2                	ld	s3,24(sp)
    80001ea0:	6a42                	ld	s4,16(sp)
    80001ea2:	6aa2                	ld	s5,8(sp)
    80001ea4:	6121                	addi	sp,sp,64
    80001ea6:	8082                	ret
    return -1;
    80001ea8:	597d                	li	s2,-1
    80001eaa:	b7ed                	j	80001e94 <fork+0x128>

0000000080001eac <scheduler>:
{
    80001eac:	7139                	addi	sp,sp,-64
    80001eae:	fc06                	sd	ra,56(sp)
    80001eb0:	f822                	sd	s0,48(sp)
    80001eb2:	f426                	sd	s1,40(sp)
    80001eb4:	f04a                	sd	s2,32(sp)
    80001eb6:	ec4e                	sd	s3,24(sp)
    80001eb8:	e852                	sd	s4,16(sp)
    80001eba:	e456                	sd	s5,8(sp)
    80001ebc:	e05a                	sd	s6,0(sp)
    80001ebe:	0080                	addi	s0,sp,64
    80001ec0:	8792                	mv	a5,tp
  int id = r_tp();
    80001ec2:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001ec4:	00779a93          	slli	s5,a5,0x7
    80001ec8:	0000f717          	auipc	a4,0xf
    80001ecc:	3d870713          	addi	a4,a4,984 # 800112a0 <pid_lock>
    80001ed0:	9756                	add	a4,a4,s5
    80001ed2:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001ed6:	0000f717          	auipc	a4,0xf
    80001eda:	40270713          	addi	a4,a4,1026 # 800112d8 <cpus+0x8>
    80001ede:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001ee0:	498d                	li	s3,3
        p->state = RUNNING;
    80001ee2:	4b11                	li	s6,4
        c->proc = p;
    80001ee4:	079e                	slli	a5,a5,0x7
    80001ee6:	0000fa17          	auipc	s4,0xf
    80001eea:	3baa0a13          	addi	s4,s4,954 # 800112a0 <pid_lock>
    80001eee:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001ef0:	00015917          	auipc	s2,0x15
    80001ef4:	1e090913          	addi	s2,s2,480 # 800170d0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ef8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001efc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f00:	10079073          	csrw	sstatus,a5
    80001f04:	0000f497          	auipc	s1,0xf
    80001f08:	7cc48493          	addi	s1,s1,1996 # 800116d0 <proc>
    80001f0c:	a811                	j	80001f20 <scheduler+0x74>
      release(&p->lock);
    80001f0e:	8526                	mv	a0,s1
    80001f10:	fffff097          	auipc	ra,0xfffff
    80001f14:	d74080e7          	jalr	-652(ra) # 80000c84 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f18:	16848493          	addi	s1,s1,360
    80001f1c:	fd248ee3          	beq	s1,s2,80001ef8 <scheduler+0x4c>
      acquire(&p->lock);
    80001f20:	8526                	mv	a0,s1
    80001f22:	fffff097          	auipc	ra,0xfffff
    80001f26:	cae080e7          	jalr	-850(ra) # 80000bd0 <acquire>
      if(p->state == RUNNABLE) {
    80001f2a:	4c9c                	lw	a5,24(s1)
    80001f2c:	ff3791e3          	bne	a5,s3,80001f0e <scheduler+0x62>
        p->state = RUNNING;
    80001f30:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001f34:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001f38:	06048593          	addi	a1,s1,96
    80001f3c:	8556                	mv	a0,s5
    80001f3e:	00000097          	auipc	ra,0x0
    80001f42:	78e080e7          	jalr	1934(ra) # 800026cc <swtch>
        c->proc = 0;
    80001f46:	020a3823          	sd	zero,48(s4)
    80001f4a:	b7d1                	j	80001f0e <scheduler+0x62>

0000000080001f4c <sched>:
{
    80001f4c:	7179                	addi	sp,sp,-48
    80001f4e:	f406                	sd	ra,40(sp)
    80001f50:	f022                	sd	s0,32(sp)
    80001f52:	ec26                	sd	s1,24(sp)
    80001f54:	e84a                	sd	s2,16(sp)
    80001f56:	e44e                	sd	s3,8(sp)
    80001f58:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f5a:	00000097          	auipc	ra,0x0
    80001f5e:	a3c080e7          	jalr	-1476(ra) # 80001996 <myproc>
    80001f62:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001f64:	fffff097          	auipc	ra,0xfffff
    80001f68:	bf2080e7          	jalr	-1038(ra) # 80000b56 <holding>
    80001f6c:	c93d                	beqz	a0,80001fe2 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f6e:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001f70:	2781                	sext.w	a5,a5
    80001f72:	079e                	slli	a5,a5,0x7
    80001f74:	0000f717          	auipc	a4,0xf
    80001f78:	32c70713          	addi	a4,a4,812 # 800112a0 <pid_lock>
    80001f7c:	97ba                	add	a5,a5,a4
    80001f7e:	0a87a703          	lw	a4,168(a5)
    80001f82:	4785                	li	a5,1
    80001f84:	06f71763          	bne	a4,a5,80001ff2 <sched+0xa6>
  if(p->state == RUNNING)
    80001f88:	4c98                	lw	a4,24(s1)
    80001f8a:	4791                	li	a5,4
    80001f8c:	06f70b63          	beq	a4,a5,80002002 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f90:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f94:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001f96:	efb5                	bnez	a5,80002012 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f98:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f9a:	0000f917          	auipc	s2,0xf
    80001f9e:	30690913          	addi	s2,s2,774 # 800112a0 <pid_lock>
    80001fa2:	2781                	sext.w	a5,a5
    80001fa4:	079e                	slli	a5,a5,0x7
    80001fa6:	97ca                	add	a5,a5,s2
    80001fa8:	0ac7a983          	lw	s3,172(a5)
    80001fac:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001fae:	2781                	sext.w	a5,a5
    80001fb0:	079e                	slli	a5,a5,0x7
    80001fb2:	0000f597          	auipc	a1,0xf
    80001fb6:	32658593          	addi	a1,a1,806 # 800112d8 <cpus+0x8>
    80001fba:	95be                	add	a1,a1,a5
    80001fbc:	06048513          	addi	a0,s1,96
    80001fc0:	00000097          	auipc	ra,0x0
    80001fc4:	70c080e7          	jalr	1804(ra) # 800026cc <swtch>
    80001fc8:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001fca:	2781                	sext.w	a5,a5
    80001fcc:	079e                	slli	a5,a5,0x7
    80001fce:	993e                	add	s2,s2,a5
    80001fd0:	0b392623          	sw	s3,172(s2)
}
    80001fd4:	70a2                	ld	ra,40(sp)
    80001fd6:	7402                	ld	s0,32(sp)
    80001fd8:	64e2                	ld	s1,24(sp)
    80001fda:	6942                	ld	s2,16(sp)
    80001fdc:	69a2                	ld	s3,8(sp)
    80001fde:	6145                	addi	sp,sp,48
    80001fe0:	8082                	ret
    panic("sched p->lock");
    80001fe2:	00006517          	auipc	a0,0x6
    80001fe6:	23650513          	addi	a0,a0,566 # 80008218 <digits+0x1d8>
    80001fea:	ffffe097          	auipc	ra,0xffffe
    80001fee:	550080e7          	jalr	1360(ra) # 8000053a <panic>
    panic("sched locks");
    80001ff2:	00006517          	auipc	a0,0x6
    80001ff6:	23650513          	addi	a0,a0,566 # 80008228 <digits+0x1e8>
    80001ffa:	ffffe097          	auipc	ra,0xffffe
    80001ffe:	540080e7          	jalr	1344(ra) # 8000053a <panic>
    panic("sched running");
    80002002:	00006517          	auipc	a0,0x6
    80002006:	23650513          	addi	a0,a0,566 # 80008238 <digits+0x1f8>
    8000200a:	ffffe097          	auipc	ra,0xffffe
    8000200e:	530080e7          	jalr	1328(ra) # 8000053a <panic>
    panic("sched interruptible");
    80002012:	00006517          	auipc	a0,0x6
    80002016:	23650513          	addi	a0,a0,566 # 80008248 <digits+0x208>
    8000201a:	ffffe097          	auipc	ra,0xffffe
    8000201e:	520080e7          	jalr	1312(ra) # 8000053a <panic>

0000000080002022 <yield>:
{
    80002022:	1101                	addi	sp,sp,-32
    80002024:	ec06                	sd	ra,24(sp)
    80002026:	e822                	sd	s0,16(sp)
    80002028:	e426                	sd	s1,8(sp)
    8000202a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000202c:	00000097          	auipc	ra,0x0
    80002030:	96a080e7          	jalr	-1686(ra) # 80001996 <myproc>
    80002034:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002036:	fffff097          	auipc	ra,0xfffff
    8000203a:	b9a080e7          	jalr	-1126(ra) # 80000bd0 <acquire>
  p->state = RUNNABLE;
    8000203e:	478d                	li	a5,3
    80002040:	cc9c                	sw	a5,24(s1)
  sched();
    80002042:	00000097          	auipc	ra,0x0
    80002046:	f0a080e7          	jalr	-246(ra) # 80001f4c <sched>
  release(&p->lock);
    8000204a:	8526                	mv	a0,s1
    8000204c:	fffff097          	auipc	ra,0xfffff
    80002050:	c38080e7          	jalr	-968(ra) # 80000c84 <release>
}
    80002054:	60e2                	ld	ra,24(sp)
    80002056:	6442                	ld	s0,16(sp)
    80002058:	64a2                	ld	s1,8(sp)
    8000205a:	6105                	addi	sp,sp,32
    8000205c:	8082                	ret

000000008000205e <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000205e:	7179                	addi	sp,sp,-48
    80002060:	f406                	sd	ra,40(sp)
    80002062:	f022                	sd	s0,32(sp)
    80002064:	ec26                	sd	s1,24(sp)
    80002066:	e84a                	sd	s2,16(sp)
    80002068:	e44e                	sd	s3,8(sp)
    8000206a:	1800                	addi	s0,sp,48
    8000206c:	89aa                	mv	s3,a0
    8000206e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002070:	00000097          	auipc	ra,0x0
    80002074:	926080e7          	jalr	-1754(ra) # 80001996 <myproc>
    80002078:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000207a:	fffff097          	auipc	ra,0xfffff
    8000207e:	b56080e7          	jalr	-1194(ra) # 80000bd0 <acquire>
  release(lk);
    80002082:	854a                	mv	a0,s2
    80002084:	fffff097          	auipc	ra,0xfffff
    80002088:	c00080e7          	jalr	-1024(ra) # 80000c84 <release>

  // Go to sleep.
  p->chan = chan;
    8000208c:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002090:	4789                	li	a5,2
    80002092:	cc9c                	sw	a5,24(s1)

  sched();
    80002094:	00000097          	auipc	ra,0x0
    80002098:	eb8080e7          	jalr	-328(ra) # 80001f4c <sched>

  // Tidy up.
  p->chan = 0;
    8000209c:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800020a0:	8526                	mv	a0,s1
    800020a2:	fffff097          	auipc	ra,0xfffff
    800020a6:	be2080e7          	jalr	-1054(ra) # 80000c84 <release>
  acquire(lk);
    800020aa:	854a                	mv	a0,s2
    800020ac:	fffff097          	auipc	ra,0xfffff
    800020b0:	b24080e7          	jalr	-1244(ra) # 80000bd0 <acquire>
}
    800020b4:	70a2                	ld	ra,40(sp)
    800020b6:	7402                	ld	s0,32(sp)
    800020b8:	64e2                	ld	s1,24(sp)
    800020ba:	6942                	ld	s2,16(sp)
    800020bc:	69a2                	ld	s3,8(sp)
    800020be:	6145                	addi	sp,sp,48
    800020c0:	8082                	ret

00000000800020c2 <wait>:
{
    800020c2:	715d                	addi	sp,sp,-80
    800020c4:	e486                	sd	ra,72(sp)
    800020c6:	e0a2                	sd	s0,64(sp)
    800020c8:	fc26                	sd	s1,56(sp)
    800020ca:	f84a                	sd	s2,48(sp)
    800020cc:	f44e                	sd	s3,40(sp)
    800020ce:	f052                	sd	s4,32(sp)
    800020d0:	ec56                	sd	s5,24(sp)
    800020d2:	e85a                	sd	s6,16(sp)
    800020d4:	e45e                	sd	s7,8(sp)
    800020d6:	e062                	sd	s8,0(sp)
    800020d8:	0880                	addi	s0,sp,80
    800020da:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800020dc:	00000097          	auipc	ra,0x0
    800020e0:	8ba080e7          	jalr	-1862(ra) # 80001996 <myproc>
    800020e4:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800020e6:	0000f517          	auipc	a0,0xf
    800020ea:	1d250513          	addi	a0,a0,466 # 800112b8 <wait_lock>
    800020ee:	fffff097          	auipc	ra,0xfffff
    800020f2:	ae2080e7          	jalr	-1310(ra) # 80000bd0 <acquire>
    havekids = 0;
    800020f6:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800020f8:	4a15                	li	s4,5
        havekids = 1;
    800020fa:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    800020fc:	00015997          	auipc	s3,0x15
    80002100:	fd498993          	addi	s3,s3,-44 # 800170d0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002104:	0000fc17          	auipc	s8,0xf
    80002108:	1b4c0c13          	addi	s8,s8,436 # 800112b8 <wait_lock>
    havekids = 0;
    8000210c:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    8000210e:	0000f497          	auipc	s1,0xf
    80002112:	5c248493          	addi	s1,s1,1474 # 800116d0 <proc>
    80002116:	a0bd                	j	80002184 <wait+0xc2>
          pid = np->pid;
    80002118:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000211c:	000b0e63          	beqz	s6,80002138 <wait+0x76>
    80002120:	4691                	li	a3,4
    80002122:	02c48613          	addi	a2,s1,44
    80002126:	85da                	mv	a1,s6
    80002128:	05093503          	ld	a0,80(s2)
    8000212c:	fffff097          	auipc	ra,0xfffff
    80002130:	52e080e7          	jalr	1326(ra) # 8000165a <copyout>
    80002134:	02054563          	bltz	a0,8000215e <wait+0x9c>
          freeproc(np);
    80002138:	8526                	mv	a0,s1
    8000213a:	00000097          	auipc	ra,0x0
    8000213e:	a0e080e7          	jalr	-1522(ra) # 80001b48 <freeproc>
          release(&np->lock);
    80002142:	8526                	mv	a0,s1
    80002144:	fffff097          	auipc	ra,0xfffff
    80002148:	b40080e7          	jalr	-1216(ra) # 80000c84 <release>
          release(&wait_lock);
    8000214c:	0000f517          	auipc	a0,0xf
    80002150:	16c50513          	addi	a0,a0,364 # 800112b8 <wait_lock>
    80002154:	fffff097          	auipc	ra,0xfffff
    80002158:	b30080e7          	jalr	-1232(ra) # 80000c84 <release>
          return pid;
    8000215c:	a09d                	j	800021c2 <wait+0x100>
            release(&np->lock);
    8000215e:	8526                	mv	a0,s1
    80002160:	fffff097          	auipc	ra,0xfffff
    80002164:	b24080e7          	jalr	-1244(ra) # 80000c84 <release>
            release(&wait_lock);
    80002168:	0000f517          	auipc	a0,0xf
    8000216c:	15050513          	addi	a0,a0,336 # 800112b8 <wait_lock>
    80002170:	fffff097          	auipc	ra,0xfffff
    80002174:	b14080e7          	jalr	-1260(ra) # 80000c84 <release>
            return -1;
    80002178:	59fd                	li	s3,-1
    8000217a:	a0a1                	j	800021c2 <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    8000217c:	16848493          	addi	s1,s1,360
    80002180:	03348463          	beq	s1,s3,800021a8 <wait+0xe6>
      if(np->parent == p){
    80002184:	7c9c                	ld	a5,56(s1)
    80002186:	ff279be3          	bne	a5,s2,8000217c <wait+0xba>
        acquire(&np->lock);
    8000218a:	8526                	mv	a0,s1
    8000218c:	fffff097          	auipc	ra,0xfffff
    80002190:	a44080e7          	jalr	-1468(ra) # 80000bd0 <acquire>
        if(np->state == ZOMBIE){
    80002194:	4c9c                	lw	a5,24(s1)
    80002196:	f94781e3          	beq	a5,s4,80002118 <wait+0x56>
        release(&np->lock);
    8000219a:	8526                	mv	a0,s1
    8000219c:	fffff097          	auipc	ra,0xfffff
    800021a0:	ae8080e7          	jalr	-1304(ra) # 80000c84 <release>
        havekids = 1;
    800021a4:	8756                	mv	a4,s5
    800021a6:	bfd9                	j	8000217c <wait+0xba>
    if(!havekids || p->killed){
    800021a8:	c701                	beqz	a4,800021b0 <wait+0xee>
    800021aa:	02892783          	lw	a5,40(s2)
    800021ae:	c79d                	beqz	a5,800021dc <wait+0x11a>
      release(&wait_lock);
    800021b0:	0000f517          	auipc	a0,0xf
    800021b4:	10850513          	addi	a0,a0,264 # 800112b8 <wait_lock>
    800021b8:	fffff097          	auipc	ra,0xfffff
    800021bc:	acc080e7          	jalr	-1332(ra) # 80000c84 <release>
      return -1;
    800021c0:	59fd                	li	s3,-1
}
    800021c2:	854e                	mv	a0,s3
    800021c4:	60a6                	ld	ra,72(sp)
    800021c6:	6406                	ld	s0,64(sp)
    800021c8:	74e2                	ld	s1,56(sp)
    800021ca:	7942                	ld	s2,48(sp)
    800021cc:	79a2                	ld	s3,40(sp)
    800021ce:	7a02                	ld	s4,32(sp)
    800021d0:	6ae2                	ld	s5,24(sp)
    800021d2:	6b42                	ld	s6,16(sp)
    800021d4:	6ba2                	ld	s7,8(sp)
    800021d6:	6c02                	ld	s8,0(sp)
    800021d8:	6161                	addi	sp,sp,80
    800021da:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021dc:	85e2                	mv	a1,s8
    800021de:	854a                	mv	a0,s2
    800021e0:	00000097          	auipc	ra,0x0
    800021e4:	e7e080e7          	jalr	-386(ra) # 8000205e <sleep>
    havekids = 0;
    800021e8:	b715                	j	8000210c <wait+0x4a>

00000000800021ea <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800021ea:	7139                	addi	sp,sp,-64
    800021ec:	fc06                	sd	ra,56(sp)
    800021ee:	f822                	sd	s0,48(sp)
    800021f0:	f426                	sd	s1,40(sp)
    800021f2:	f04a                	sd	s2,32(sp)
    800021f4:	ec4e                	sd	s3,24(sp)
    800021f6:	e852                	sd	s4,16(sp)
    800021f8:	e456                	sd	s5,8(sp)
    800021fa:	0080                	addi	s0,sp,64
    800021fc:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800021fe:	0000f497          	auipc	s1,0xf
    80002202:	4d248493          	addi	s1,s1,1234 # 800116d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002206:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002208:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000220a:	00015917          	auipc	s2,0x15
    8000220e:	ec690913          	addi	s2,s2,-314 # 800170d0 <tickslock>
    80002212:	a811                	j	80002226 <wakeup+0x3c>
      }
      release(&p->lock);
    80002214:	8526                	mv	a0,s1
    80002216:	fffff097          	auipc	ra,0xfffff
    8000221a:	a6e080e7          	jalr	-1426(ra) # 80000c84 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000221e:	16848493          	addi	s1,s1,360
    80002222:	03248663          	beq	s1,s2,8000224e <wakeup+0x64>
    if(p != myproc()){
    80002226:	fffff097          	auipc	ra,0xfffff
    8000222a:	770080e7          	jalr	1904(ra) # 80001996 <myproc>
    8000222e:	fea488e3          	beq	s1,a0,8000221e <wakeup+0x34>
      acquire(&p->lock);
    80002232:	8526                	mv	a0,s1
    80002234:	fffff097          	auipc	ra,0xfffff
    80002238:	99c080e7          	jalr	-1636(ra) # 80000bd0 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000223c:	4c9c                	lw	a5,24(s1)
    8000223e:	fd379be3          	bne	a5,s3,80002214 <wakeup+0x2a>
    80002242:	709c                	ld	a5,32(s1)
    80002244:	fd4798e3          	bne	a5,s4,80002214 <wakeup+0x2a>
        p->state = RUNNABLE;
    80002248:	0154ac23          	sw	s5,24(s1)
    8000224c:	b7e1                	j	80002214 <wakeup+0x2a>
    }
  }
}
    8000224e:	70e2                	ld	ra,56(sp)
    80002250:	7442                	ld	s0,48(sp)
    80002252:	74a2                	ld	s1,40(sp)
    80002254:	7902                	ld	s2,32(sp)
    80002256:	69e2                	ld	s3,24(sp)
    80002258:	6a42                	ld	s4,16(sp)
    8000225a:	6aa2                	ld	s5,8(sp)
    8000225c:	6121                	addi	sp,sp,64
    8000225e:	8082                	ret

0000000080002260 <reparent>:
{
    80002260:	7179                	addi	sp,sp,-48
    80002262:	f406                	sd	ra,40(sp)
    80002264:	f022                	sd	s0,32(sp)
    80002266:	ec26                	sd	s1,24(sp)
    80002268:	e84a                	sd	s2,16(sp)
    8000226a:	e44e                	sd	s3,8(sp)
    8000226c:	e052                	sd	s4,0(sp)
    8000226e:	1800                	addi	s0,sp,48
    80002270:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002272:	0000f497          	auipc	s1,0xf
    80002276:	45e48493          	addi	s1,s1,1118 # 800116d0 <proc>
      pp->parent = initproc;
    8000227a:	00007a17          	auipc	s4,0x7
    8000227e:	daea0a13          	addi	s4,s4,-594 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002282:	00015997          	auipc	s3,0x15
    80002286:	e4e98993          	addi	s3,s3,-434 # 800170d0 <tickslock>
    8000228a:	a029                	j	80002294 <reparent+0x34>
    8000228c:	16848493          	addi	s1,s1,360
    80002290:	01348d63          	beq	s1,s3,800022aa <reparent+0x4a>
    if(pp->parent == p){
    80002294:	7c9c                	ld	a5,56(s1)
    80002296:	ff279be3          	bne	a5,s2,8000228c <reparent+0x2c>
      pp->parent = initproc;
    8000229a:	000a3503          	ld	a0,0(s4)
    8000229e:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800022a0:	00000097          	auipc	ra,0x0
    800022a4:	f4a080e7          	jalr	-182(ra) # 800021ea <wakeup>
    800022a8:	b7d5                	j	8000228c <reparent+0x2c>
}
    800022aa:	70a2                	ld	ra,40(sp)
    800022ac:	7402                	ld	s0,32(sp)
    800022ae:	64e2                	ld	s1,24(sp)
    800022b0:	6942                	ld	s2,16(sp)
    800022b2:	69a2                	ld	s3,8(sp)
    800022b4:	6a02                	ld	s4,0(sp)
    800022b6:	6145                	addi	sp,sp,48
    800022b8:	8082                	ret

00000000800022ba <exit>:
{
    800022ba:	7179                	addi	sp,sp,-48
    800022bc:	f406                	sd	ra,40(sp)
    800022be:	f022                	sd	s0,32(sp)
    800022c0:	ec26                	sd	s1,24(sp)
    800022c2:	e84a                	sd	s2,16(sp)
    800022c4:	e44e                	sd	s3,8(sp)
    800022c6:	e052                	sd	s4,0(sp)
    800022c8:	1800                	addi	s0,sp,48
    800022ca:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800022cc:	fffff097          	auipc	ra,0xfffff
    800022d0:	6ca080e7          	jalr	1738(ra) # 80001996 <myproc>
    800022d4:	89aa                	mv	s3,a0
  if(p == initproc)
    800022d6:	00007797          	auipc	a5,0x7
    800022da:	d527b783          	ld	a5,-686(a5) # 80009028 <initproc>
    800022de:	0d050493          	addi	s1,a0,208
    800022e2:	15050913          	addi	s2,a0,336
    800022e6:	02a79363          	bne	a5,a0,8000230c <exit+0x52>
    panic("init exiting");
    800022ea:	00006517          	auipc	a0,0x6
    800022ee:	f7650513          	addi	a0,a0,-138 # 80008260 <digits+0x220>
    800022f2:	ffffe097          	auipc	ra,0xffffe
    800022f6:	248080e7          	jalr	584(ra) # 8000053a <panic>
      fileclose(f);
    800022fa:	00002097          	auipc	ra,0x2
    800022fe:	344080e7          	jalr	836(ra) # 8000463e <fileclose>
      p->ofile[fd] = 0;
    80002302:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002306:	04a1                	addi	s1,s1,8
    80002308:	01248563          	beq	s1,s2,80002312 <exit+0x58>
    if(p->ofile[fd]){
    8000230c:	6088                	ld	a0,0(s1)
    8000230e:	f575                	bnez	a0,800022fa <exit+0x40>
    80002310:	bfdd                	j	80002306 <exit+0x4c>
  begin_op();
    80002312:	00002097          	auipc	ra,0x2
    80002316:	e64080e7          	jalr	-412(ra) # 80004176 <begin_op>
  iput(p->cwd);
    8000231a:	1509b503          	ld	a0,336(s3)
    8000231e:	00001097          	auipc	ra,0x1
    80002322:	636080e7          	jalr	1590(ra) # 80003954 <iput>
  end_op();
    80002326:	00002097          	auipc	ra,0x2
    8000232a:	ece080e7          	jalr	-306(ra) # 800041f4 <end_op>
  p->cwd = 0;
    8000232e:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002332:	0000f497          	auipc	s1,0xf
    80002336:	f8648493          	addi	s1,s1,-122 # 800112b8 <wait_lock>
    8000233a:	8526                	mv	a0,s1
    8000233c:	fffff097          	auipc	ra,0xfffff
    80002340:	894080e7          	jalr	-1900(ra) # 80000bd0 <acquire>
  reparent(p);
    80002344:	854e                	mv	a0,s3
    80002346:	00000097          	auipc	ra,0x0
    8000234a:	f1a080e7          	jalr	-230(ra) # 80002260 <reparent>
  wakeup(p->parent);
    8000234e:	0389b503          	ld	a0,56(s3)
    80002352:	00000097          	auipc	ra,0x0
    80002356:	e98080e7          	jalr	-360(ra) # 800021ea <wakeup>
  acquire(&p->lock);
    8000235a:	854e                	mv	a0,s3
    8000235c:	fffff097          	auipc	ra,0xfffff
    80002360:	874080e7          	jalr	-1932(ra) # 80000bd0 <acquire>
  p->xstate = status;
    80002364:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002368:	4795                	li	a5,5
    8000236a:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000236e:	8526                	mv	a0,s1
    80002370:	fffff097          	auipc	ra,0xfffff
    80002374:	914080e7          	jalr	-1772(ra) # 80000c84 <release>
  sched();
    80002378:	00000097          	auipc	ra,0x0
    8000237c:	bd4080e7          	jalr	-1068(ra) # 80001f4c <sched>
  panic("zombie exit");
    80002380:	00006517          	auipc	a0,0x6
    80002384:	ef050513          	addi	a0,a0,-272 # 80008270 <digits+0x230>
    80002388:	ffffe097          	auipc	ra,0xffffe
    8000238c:	1b2080e7          	jalr	434(ra) # 8000053a <panic>

0000000080002390 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002390:	7179                	addi	sp,sp,-48
    80002392:	f406                	sd	ra,40(sp)
    80002394:	f022                	sd	s0,32(sp)
    80002396:	ec26                	sd	s1,24(sp)
    80002398:	e84a                	sd	s2,16(sp)
    8000239a:	e44e                	sd	s3,8(sp)
    8000239c:	1800                	addi	s0,sp,48
    8000239e:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800023a0:	0000f497          	auipc	s1,0xf
    800023a4:	33048493          	addi	s1,s1,816 # 800116d0 <proc>
    800023a8:	00015997          	auipc	s3,0x15
    800023ac:	d2898993          	addi	s3,s3,-728 # 800170d0 <tickslock>
    acquire(&p->lock);
    800023b0:	8526                	mv	a0,s1
    800023b2:	fffff097          	auipc	ra,0xfffff
    800023b6:	81e080e7          	jalr	-2018(ra) # 80000bd0 <acquire>
    if(p->pid == pid){
    800023ba:	589c                	lw	a5,48(s1)
    800023bc:	01278d63          	beq	a5,s2,800023d6 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800023c0:	8526                	mv	a0,s1
    800023c2:	fffff097          	auipc	ra,0xfffff
    800023c6:	8c2080e7          	jalr	-1854(ra) # 80000c84 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800023ca:	16848493          	addi	s1,s1,360
    800023ce:	ff3491e3          	bne	s1,s3,800023b0 <kill+0x20>
  }
  return -1;
    800023d2:	557d                	li	a0,-1
    800023d4:	a829                	j	800023ee <kill+0x5e>
      p->killed = 1;
    800023d6:	4785                	li	a5,1
    800023d8:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800023da:	4c98                	lw	a4,24(s1)
    800023dc:	4789                	li	a5,2
    800023de:	00f70f63          	beq	a4,a5,800023fc <kill+0x6c>
      release(&p->lock);
    800023e2:	8526                	mv	a0,s1
    800023e4:	fffff097          	auipc	ra,0xfffff
    800023e8:	8a0080e7          	jalr	-1888(ra) # 80000c84 <release>
      return 0;
    800023ec:	4501                	li	a0,0
}
    800023ee:	70a2                	ld	ra,40(sp)
    800023f0:	7402                	ld	s0,32(sp)
    800023f2:	64e2                	ld	s1,24(sp)
    800023f4:	6942                	ld	s2,16(sp)
    800023f6:	69a2                	ld	s3,8(sp)
    800023f8:	6145                	addi	sp,sp,48
    800023fa:	8082                	ret
        p->state = RUNNABLE;
    800023fc:	478d                	li	a5,3
    800023fe:	cc9c                	sw	a5,24(s1)
    80002400:	b7cd                	j	800023e2 <kill+0x52>

0000000080002402 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002402:	7179                	addi	sp,sp,-48
    80002404:	f406                	sd	ra,40(sp)
    80002406:	f022                	sd	s0,32(sp)
    80002408:	ec26                	sd	s1,24(sp)
    8000240a:	e84a                	sd	s2,16(sp)
    8000240c:	e44e                	sd	s3,8(sp)
    8000240e:	e052                	sd	s4,0(sp)
    80002410:	1800                	addi	s0,sp,48
    80002412:	84aa                	mv	s1,a0
    80002414:	892e                	mv	s2,a1
    80002416:	89b2                	mv	s3,a2
    80002418:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000241a:	fffff097          	auipc	ra,0xfffff
    8000241e:	57c080e7          	jalr	1404(ra) # 80001996 <myproc>
  if(user_dst){
    80002422:	c08d                	beqz	s1,80002444 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002424:	86d2                	mv	a3,s4
    80002426:	864e                	mv	a2,s3
    80002428:	85ca                	mv	a1,s2
    8000242a:	6928                	ld	a0,80(a0)
    8000242c:	fffff097          	auipc	ra,0xfffff
    80002430:	22e080e7          	jalr	558(ra) # 8000165a <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002434:	70a2                	ld	ra,40(sp)
    80002436:	7402                	ld	s0,32(sp)
    80002438:	64e2                	ld	s1,24(sp)
    8000243a:	6942                	ld	s2,16(sp)
    8000243c:	69a2                	ld	s3,8(sp)
    8000243e:	6a02                	ld	s4,0(sp)
    80002440:	6145                	addi	sp,sp,48
    80002442:	8082                	ret
    memmove((char *)dst, src, len);
    80002444:	000a061b          	sext.w	a2,s4
    80002448:	85ce                	mv	a1,s3
    8000244a:	854a                	mv	a0,s2
    8000244c:	fffff097          	auipc	ra,0xfffff
    80002450:	8dc080e7          	jalr	-1828(ra) # 80000d28 <memmove>
    return 0;
    80002454:	8526                	mv	a0,s1
    80002456:	bff9                	j	80002434 <either_copyout+0x32>

0000000080002458 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002458:	7179                	addi	sp,sp,-48
    8000245a:	f406                	sd	ra,40(sp)
    8000245c:	f022                	sd	s0,32(sp)
    8000245e:	ec26                	sd	s1,24(sp)
    80002460:	e84a                	sd	s2,16(sp)
    80002462:	e44e                	sd	s3,8(sp)
    80002464:	e052                	sd	s4,0(sp)
    80002466:	1800                	addi	s0,sp,48
    80002468:	892a                	mv	s2,a0
    8000246a:	84ae                	mv	s1,a1
    8000246c:	89b2                	mv	s3,a2
    8000246e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002470:	fffff097          	auipc	ra,0xfffff
    80002474:	526080e7          	jalr	1318(ra) # 80001996 <myproc>
  if(user_src){
    80002478:	c08d                	beqz	s1,8000249a <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    8000247a:	86d2                	mv	a3,s4
    8000247c:	864e                	mv	a2,s3
    8000247e:	85ca                	mv	a1,s2
    80002480:	6928                	ld	a0,80(a0)
    80002482:	fffff097          	auipc	ra,0xfffff
    80002486:	264080e7          	jalr	612(ra) # 800016e6 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000248a:	70a2                	ld	ra,40(sp)
    8000248c:	7402                	ld	s0,32(sp)
    8000248e:	64e2                	ld	s1,24(sp)
    80002490:	6942                	ld	s2,16(sp)
    80002492:	69a2                	ld	s3,8(sp)
    80002494:	6a02                	ld	s4,0(sp)
    80002496:	6145                	addi	sp,sp,48
    80002498:	8082                	ret
    memmove(dst, (char*)src, len);
    8000249a:	000a061b          	sext.w	a2,s4
    8000249e:	85ce                	mv	a1,s3
    800024a0:	854a                	mv	a0,s2
    800024a2:	fffff097          	auipc	ra,0xfffff
    800024a6:	886080e7          	jalr	-1914(ra) # 80000d28 <memmove>
    return 0;
    800024aa:	8526                	mv	a0,s1
    800024ac:	bff9                	j	8000248a <either_copyin+0x32>

00000000800024ae <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800024ae:	715d                	addi	sp,sp,-80
    800024b0:	e486                	sd	ra,72(sp)
    800024b2:	e0a2                	sd	s0,64(sp)
    800024b4:	fc26                	sd	s1,56(sp)
    800024b6:	f84a                	sd	s2,48(sp)
    800024b8:	f44e                	sd	s3,40(sp)
    800024ba:	f052                	sd	s4,32(sp)
    800024bc:	ec56                	sd	s5,24(sp)
    800024be:	e85a                	sd	s6,16(sp)
    800024c0:	e45e                	sd	s7,8(sp)
    800024c2:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800024c4:	00006517          	auipc	a0,0x6
    800024c8:	c0450513          	addi	a0,a0,-1020 # 800080c8 <digits+0x88>
    800024cc:	ffffe097          	auipc	ra,0xffffe
    800024d0:	0b8080e7          	jalr	184(ra) # 80000584 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800024d4:	0000f497          	auipc	s1,0xf
    800024d8:	35448493          	addi	s1,s1,852 # 80011828 <proc+0x158>
    800024dc:	00015917          	auipc	s2,0x15
    800024e0:	d4c90913          	addi	s2,s2,-692 # 80017228 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800024e4:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800024e6:	00006997          	auipc	s3,0x6
    800024ea:	d9a98993          	addi	s3,s3,-614 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    800024ee:	00006a97          	auipc	s5,0x6
    800024f2:	d9aa8a93          	addi	s5,s5,-614 # 80008288 <digits+0x248>
    printf("\n");
    800024f6:	00006a17          	auipc	s4,0x6
    800024fa:	bd2a0a13          	addi	s4,s4,-1070 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800024fe:	00006b97          	auipc	s7,0x6
    80002502:	dc2b8b93          	addi	s7,s7,-574 # 800082c0 <states.0>
    80002506:	a00d                	j	80002528 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002508:	ed86a583          	lw	a1,-296(a3)
    8000250c:	8556                	mv	a0,s5
    8000250e:	ffffe097          	auipc	ra,0xffffe
    80002512:	076080e7          	jalr	118(ra) # 80000584 <printf>
    printf("\n");
    80002516:	8552                	mv	a0,s4
    80002518:	ffffe097          	auipc	ra,0xffffe
    8000251c:	06c080e7          	jalr	108(ra) # 80000584 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002520:	16848493          	addi	s1,s1,360
    80002524:	03248263          	beq	s1,s2,80002548 <procdump+0x9a>
    if(p->state == UNUSED)
    80002528:	86a6                	mv	a3,s1
    8000252a:	ec04a783          	lw	a5,-320(s1)
    8000252e:	dbed                	beqz	a5,80002520 <procdump+0x72>
      state = "???";
    80002530:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002532:	fcfb6be3          	bltu	s6,a5,80002508 <procdump+0x5a>
    80002536:	02079713          	slli	a4,a5,0x20
    8000253a:	01d75793          	srli	a5,a4,0x1d
    8000253e:	97de                	add	a5,a5,s7
    80002540:	6390                	ld	a2,0(a5)
    80002542:	f279                	bnez	a2,80002508 <procdump+0x5a>
      state = "???";
    80002544:	864e                	mv	a2,s3
    80002546:	b7c9                	j	80002508 <procdump+0x5a>
  }
}
    80002548:	60a6                	ld	ra,72(sp)
    8000254a:	6406                	ld	s0,64(sp)
    8000254c:	74e2                	ld	s1,56(sp)
    8000254e:	7942                	ld	s2,48(sp)
    80002550:	79a2                	ld	s3,40(sp)
    80002552:	7a02                	ld	s4,32(sp)
    80002554:	6ae2                	ld	s5,24(sp)
    80002556:	6b42                	ld	s6,16(sp)
    80002558:	6ba2                	ld	s7,8(sp)
    8000255a:	6161                	addi	sp,sp,80
    8000255c:	8082                	ret

000000008000255e <wait2>:


int
wait2(uint64 addr, uint64 addr2)
{
    8000255e:	7159                	addi	sp,sp,-112
    80002560:	f486                	sd	ra,104(sp)
    80002562:	f0a2                	sd	s0,96(sp)
    80002564:	eca6                	sd	s1,88(sp)
    80002566:	e8ca                	sd	s2,80(sp)
    80002568:	e4ce                	sd	s3,72(sp)
    8000256a:	e0d2                	sd	s4,64(sp)
    8000256c:	fc56                	sd	s5,56(sp)
    8000256e:	f85a                	sd	s6,48(sp)
    80002570:	f45e                	sd	s7,40(sp)
    80002572:	f062                	sd	s8,32(sp)
    80002574:	ec66                	sd	s9,24(sp)
    80002576:	1880                	addi	s0,sp,112
    80002578:	8baa                	mv	s7,a0
    8000257a:	8b2e                	mv	s6,a1
  struct rusage cru;
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    8000257c:	fffff097          	auipc	ra,0xfffff
    80002580:	41a080e7          	jalr	1050(ra) # 80001996 <myproc>
    80002584:	892a                	mv	s2,a0

  acquire(&wait_lock);
    80002586:	0000f517          	auipc	a0,0xf
    8000258a:	d3250513          	addi	a0,a0,-718 # 800112b8 <wait_lock>
    8000258e:	ffffe097          	auipc	ra,0xffffe
    80002592:	642080e7          	jalr	1602(ra) # 80000bd0 <acquire>

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    80002596:	4c01                	li	s8,0
      if(np->parent == p){
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if(np->state == ZOMBIE){
    80002598:	4a15                	li	s4,5
        havekids = 1;
    8000259a:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    8000259c:	00015997          	auipc	s3,0x15
    800025a0:	b3498993          	addi	s3,s3,-1228 # 800170d0 <tickslock>
      release(&wait_lock);
      return -1;
    }
    
    // Wait for a child to exit.
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800025a4:	0000fc97          	auipc	s9,0xf
    800025a8:	d14c8c93          	addi	s9,s9,-748 # 800112b8 <wait_lock>
    havekids = 0;
    800025ac:	8762                	mv	a4,s8
    for(np = proc; np < &proc[NPROC]; np++){
    800025ae:	0000f497          	auipc	s1,0xf
    800025b2:	12248493          	addi	s1,s1,290 # 800116d0 <proc>
    800025b6:	a07d                	j	80002664 <wait2+0x106>
          pid = np->pid;
    800025b8:	0304a983          	lw	s3,48(s1)
          cru.cputime = np->cputime;
    800025bc:	58dc                	lw	a5,52(s1)
    800025be:	f8f42c23          	sw	a5,-104(s0)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800025c2:	040b9363          	bnez	s7,80002608 <wait2+0xaa>
          if(addr2 != 0 && copyout(p->pagetable, addr2, (char *)&cru,
    800025c6:	000b0e63          	beqz	s6,800025e2 <wait2+0x84>
    800025ca:	4691                	li	a3,4
    800025cc:	f9840613          	addi	a2,s0,-104
    800025d0:	85da                	mv	a1,s6
    800025d2:	05093503          	ld	a0,80(s2)
    800025d6:	fffff097          	auipc	ra,0xfffff
    800025da:	084080e7          	jalr	132(ra) # 8000165a <copyout>
    800025de:	06054063          	bltz	a0,8000263e <wait2+0xe0>
          freeproc(np);
    800025e2:	8526                	mv	a0,s1
    800025e4:	fffff097          	auipc	ra,0xfffff
    800025e8:	564080e7          	jalr	1380(ra) # 80001b48 <freeproc>
          release(&np->lock);
    800025ec:	8526                	mv	a0,s1
    800025ee:	ffffe097          	auipc	ra,0xffffe
    800025f2:	696080e7          	jalr	1686(ra) # 80000c84 <release>
          release(&wait_lock);
    800025f6:	0000f517          	auipc	a0,0xf
    800025fa:	cc250513          	addi	a0,a0,-830 # 800112b8 <wait_lock>
    800025fe:	ffffe097          	auipc	ra,0xffffe
    80002602:	686080e7          	jalr	1670(ra) # 80000c84 <release>
          return pid;
    80002606:	a871                	j	800026a2 <wait2+0x144>
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002608:	4691                	li	a3,4
    8000260a:	02c48613          	addi	a2,s1,44
    8000260e:	85de                	mv	a1,s7
    80002610:	05093503          	ld	a0,80(s2)
    80002614:	fffff097          	auipc	ra,0xfffff
    80002618:	046080e7          	jalr	70(ra) # 8000165a <copyout>
    8000261c:	fa0555e3          	bgez	a0,800025c6 <wait2+0x68>
            release(&np->lock);
    80002620:	8526                	mv	a0,s1
    80002622:	ffffe097          	auipc	ra,0xffffe
    80002626:	662080e7          	jalr	1634(ra) # 80000c84 <release>
            release(&wait_lock);
    8000262a:	0000f517          	auipc	a0,0xf
    8000262e:	c8e50513          	addi	a0,a0,-882 # 800112b8 <wait_lock>
    80002632:	ffffe097          	auipc	ra,0xffffe
    80002636:	652080e7          	jalr	1618(ra) # 80000c84 <release>
            return -1;
    8000263a:	59fd                	li	s3,-1
    8000263c:	a09d                	j	800026a2 <wait2+0x144>
            release(&np->lock);
    8000263e:	8526                	mv	a0,s1
    80002640:	ffffe097          	auipc	ra,0xffffe
    80002644:	644080e7          	jalr	1604(ra) # 80000c84 <release>
            release(&wait_lock);
    80002648:	0000f517          	auipc	a0,0xf
    8000264c:	c7050513          	addi	a0,a0,-912 # 800112b8 <wait_lock>
    80002650:	ffffe097          	auipc	ra,0xffffe
    80002654:	634080e7          	jalr	1588(ra) # 80000c84 <release>
            return -1;
    80002658:	59fd                	li	s3,-1
    8000265a:	a0a1                	j	800026a2 <wait2+0x144>
    for(np = proc; np < &proc[NPROC]; np++){
    8000265c:	16848493          	addi	s1,s1,360
    80002660:	03348463          	beq	s1,s3,80002688 <wait2+0x12a>
      if(np->parent == p){
    80002664:	7c9c                	ld	a5,56(s1)
    80002666:	ff279be3          	bne	a5,s2,8000265c <wait2+0xfe>
        acquire(&np->lock);
    8000266a:	8526                	mv	a0,s1
    8000266c:	ffffe097          	auipc	ra,0xffffe
    80002670:	564080e7          	jalr	1380(ra) # 80000bd0 <acquire>
        if(np->state == ZOMBIE){
    80002674:	4c9c                	lw	a5,24(s1)
    80002676:	f54781e3          	beq	a5,s4,800025b8 <wait2+0x5a>
        release(&np->lock);
    8000267a:	8526                	mv	a0,s1
    8000267c:	ffffe097          	auipc	ra,0xffffe
    80002680:	608080e7          	jalr	1544(ra) # 80000c84 <release>
        havekids = 1;
    80002684:	8756                	mv	a4,s5
    80002686:	bfd9                	j	8000265c <wait2+0xfe>
    if(!havekids || p->killed){
    80002688:	c701                	beqz	a4,80002690 <wait2+0x132>
    8000268a:	02892783          	lw	a5,40(s2)
    8000268e:	cb85                	beqz	a5,800026be <wait2+0x160>
      release(&wait_lock);
    80002690:	0000f517          	auipc	a0,0xf
    80002694:	c2850513          	addi	a0,a0,-984 # 800112b8 <wait_lock>
    80002698:	ffffe097          	auipc	ra,0xffffe
    8000269c:	5ec080e7          	jalr	1516(ra) # 80000c84 <release>
      return -1;
    800026a0:	59fd                	li	s3,-1
  }
}
    800026a2:	854e                	mv	a0,s3
    800026a4:	70a6                	ld	ra,104(sp)
    800026a6:	7406                	ld	s0,96(sp)
    800026a8:	64e6                	ld	s1,88(sp)
    800026aa:	6946                	ld	s2,80(sp)
    800026ac:	69a6                	ld	s3,72(sp)
    800026ae:	6a06                	ld	s4,64(sp)
    800026b0:	7ae2                	ld	s5,56(sp)
    800026b2:	7b42                	ld	s6,48(sp)
    800026b4:	7ba2                	ld	s7,40(sp)
    800026b6:	7c02                	ld	s8,32(sp)
    800026b8:	6ce2                	ld	s9,24(sp)
    800026ba:	6165                	addi	sp,sp,112
    800026bc:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800026be:	85e6                	mv	a1,s9
    800026c0:	854a                	mv	a0,s2
    800026c2:	00000097          	auipc	ra,0x0
    800026c6:	99c080e7          	jalr	-1636(ra) # 8000205e <sleep>
    havekids = 0;
    800026ca:	b5cd                	j	800025ac <wait2+0x4e>

00000000800026cc <swtch>:
    800026cc:	00153023          	sd	ra,0(a0)
    800026d0:	00253423          	sd	sp,8(a0)
    800026d4:	e900                	sd	s0,16(a0)
    800026d6:	ed04                	sd	s1,24(a0)
    800026d8:	03253023          	sd	s2,32(a0)
    800026dc:	03353423          	sd	s3,40(a0)
    800026e0:	03453823          	sd	s4,48(a0)
    800026e4:	03553c23          	sd	s5,56(a0)
    800026e8:	05653023          	sd	s6,64(a0)
    800026ec:	05753423          	sd	s7,72(a0)
    800026f0:	05853823          	sd	s8,80(a0)
    800026f4:	05953c23          	sd	s9,88(a0)
    800026f8:	07a53023          	sd	s10,96(a0)
    800026fc:	07b53423          	sd	s11,104(a0)
    80002700:	0005b083          	ld	ra,0(a1)
    80002704:	0085b103          	ld	sp,8(a1)
    80002708:	6980                	ld	s0,16(a1)
    8000270a:	6d84                	ld	s1,24(a1)
    8000270c:	0205b903          	ld	s2,32(a1)
    80002710:	0285b983          	ld	s3,40(a1)
    80002714:	0305ba03          	ld	s4,48(a1)
    80002718:	0385ba83          	ld	s5,56(a1)
    8000271c:	0405bb03          	ld	s6,64(a1)
    80002720:	0485bb83          	ld	s7,72(a1)
    80002724:	0505bc03          	ld	s8,80(a1)
    80002728:	0585bc83          	ld	s9,88(a1)
    8000272c:	0605bd03          	ld	s10,96(a1)
    80002730:	0685bd83          	ld	s11,104(a1)
    80002734:	8082                	ret

0000000080002736 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002736:	1141                	addi	sp,sp,-16
    80002738:	e406                	sd	ra,8(sp)
    8000273a:	e022                	sd	s0,0(sp)
    8000273c:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000273e:	00006597          	auipc	a1,0x6
    80002742:	bb258593          	addi	a1,a1,-1102 # 800082f0 <states.0+0x30>
    80002746:	00015517          	auipc	a0,0x15
    8000274a:	98a50513          	addi	a0,a0,-1654 # 800170d0 <tickslock>
    8000274e:	ffffe097          	auipc	ra,0xffffe
    80002752:	3f2080e7          	jalr	1010(ra) # 80000b40 <initlock>
}
    80002756:	60a2                	ld	ra,8(sp)
    80002758:	6402                	ld	s0,0(sp)
    8000275a:	0141                	addi	sp,sp,16
    8000275c:	8082                	ret

000000008000275e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000275e:	1141                	addi	sp,sp,-16
    80002760:	e422                	sd	s0,8(sp)
    80002762:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002764:	00003797          	auipc	a5,0x3
    80002768:	50c78793          	addi	a5,a5,1292 # 80005c70 <kernelvec>
    8000276c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002770:	6422                	ld	s0,8(sp)
    80002772:	0141                	addi	sp,sp,16
    80002774:	8082                	ret

0000000080002776 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002776:	1141                	addi	sp,sp,-16
    80002778:	e406                	sd	ra,8(sp)
    8000277a:	e022                	sd	s0,0(sp)
    8000277c:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000277e:	fffff097          	auipc	ra,0xfffff
    80002782:	218080e7          	jalr	536(ra) # 80001996 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002786:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000278a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000278c:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002790:	00005697          	auipc	a3,0x5
    80002794:	87068693          	addi	a3,a3,-1936 # 80007000 <_trampoline>
    80002798:	00005717          	auipc	a4,0x5
    8000279c:	86870713          	addi	a4,a4,-1944 # 80007000 <_trampoline>
    800027a0:	8f15                	sub	a4,a4,a3
    800027a2:	040007b7          	lui	a5,0x4000
    800027a6:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800027a8:	07b2                	slli	a5,a5,0xc
    800027aa:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027ac:	10571073          	csrw	stvec,a4

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800027b0:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800027b2:	18002673          	csrr	a2,satp
    800027b6:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800027b8:	6d30                	ld	a2,88(a0)
    800027ba:	6138                	ld	a4,64(a0)
    800027bc:	6585                	lui	a1,0x1
    800027be:	972e                	add	a4,a4,a1
    800027c0:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800027c2:	6d38                	ld	a4,88(a0)
    800027c4:	00000617          	auipc	a2,0x0
    800027c8:	13860613          	addi	a2,a2,312 # 800028fc <usertrap>
    800027cc:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800027ce:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800027d0:	8612                	mv	a2,tp
    800027d2:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027d4:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800027d8:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800027dc:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027e0:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800027e4:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800027e6:	6f18                	ld	a4,24(a4)
    800027e8:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800027ec:	692c                	ld	a1,80(a0)
    800027ee:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800027f0:	00005717          	auipc	a4,0x5
    800027f4:	8a070713          	addi	a4,a4,-1888 # 80007090 <userret>
    800027f8:	8f15                	sub	a4,a4,a3
    800027fa:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    800027fc:	577d                	li	a4,-1
    800027fe:	177e                	slli	a4,a4,0x3f
    80002800:	8dd9                	or	a1,a1,a4
    80002802:	02000537          	lui	a0,0x2000
    80002806:	157d                	addi	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    80002808:	0536                	slli	a0,a0,0xd
    8000280a:	9782                	jalr	a5
}
    8000280c:	60a2                	ld	ra,8(sp)
    8000280e:	6402                	ld	s0,0(sp)
    80002810:	0141                	addi	sp,sp,16
    80002812:	8082                	ret

0000000080002814 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002814:	1101                	addi	sp,sp,-32
    80002816:	ec06                	sd	ra,24(sp)
    80002818:	e822                	sd	s0,16(sp)
    8000281a:	e426                	sd	s1,8(sp)
    8000281c:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000281e:	00015497          	auipc	s1,0x15
    80002822:	8b248493          	addi	s1,s1,-1870 # 800170d0 <tickslock>
    80002826:	8526                	mv	a0,s1
    80002828:	ffffe097          	auipc	ra,0xffffe
    8000282c:	3a8080e7          	jalr	936(ra) # 80000bd0 <acquire>
  ticks++;
    80002830:	00007517          	auipc	a0,0x7
    80002834:	80050513          	addi	a0,a0,-2048 # 80009030 <ticks>
    80002838:	411c                	lw	a5,0(a0)
    8000283a:	2785                	addiw	a5,a5,1
    8000283c:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000283e:	00000097          	auipc	ra,0x0
    80002842:	9ac080e7          	jalr	-1620(ra) # 800021ea <wakeup>
  release(&tickslock);
    80002846:	8526                	mv	a0,s1
    80002848:	ffffe097          	auipc	ra,0xffffe
    8000284c:	43c080e7          	jalr	1084(ra) # 80000c84 <release>
}
    80002850:	60e2                	ld	ra,24(sp)
    80002852:	6442                	ld	s0,16(sp)
    80002854:	64a2                	ld	s1,8(sp)
    80002856:	6105                	addi	sp,sp,32
    80002858:	8082                	ret

000000008000285a <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000285a:	1101                	addi	sp,sp,-32
    8000285c:	ec06                	sd	ra,24(sp)
    8000285e:	e822                	sd	s0,16(sp)
    80002860:	e426                	sd	s1,8(sp)
    80002862:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002864:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002868:	00074d63          	bltz	a4,80002882 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    8000286c:	57fd                	li	a5,-1
    8000286e:	17fe                	slli	a5,a5,0x3f
    80002870:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002872:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002874:	06f70363          	beq	a4,a5,800028da <devintr+0x80>
  }
}
    80002878:	60e2                	ld	ra,24(sp)
    8000287a:	6442                	ld	s0,16(sp)
    8000287c:	64a2                	ld	s1,8(sp)
    8000287e:	6105                	addi	sp,sp,32
    80002880:	8082                	ret
     (scause & 0xff) == 9){
    80002882:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    80002886:	46a5                	li	a3,9
    80002888:	fed792e3          	bne	a5,a3,8000286c <devintr+0x12>
    int irq = plic_claim();
    8000288c:	00003097          	auipc	ra,0x3
    80002890:	4ec080e7          	jalr	1260(ra) # 80005d78 <plic_claim>
    80002894:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002896:	47a9                	li	a5,10
    80002898:	02f50763          	beq	a0,a5,800028c6 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    8000289c:	4785                	li	a5,1
    8000289e:	02f50963          	beq	a0,a5,800028d0 <devintr+0x76>
    return 1;
    800028a2:	4505                	li	a0,1
    } else if(irq){
    800028a4:	d8f1                	beqz	s1,80002878 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800028a6:	85a6                	mv	a1,s1
    800028a8:	00006517          	auipc	a0,0x6
    800028ac:	a5050513          	addi	a0,a0,-1456 # 800082f8 <states.0+0x38>
    800028b0:	ffffe097          	auipc	ra,0xffffe
    800028b4:	cd4080e7          	jalr	-812(ra) # 80000584 <printf>
      plic_complete(irq);
    800028b8:	8526                	mv	a0,s1
    800028ba:	00003097          	auipc	ra,0x3
    800028be:	4e2080e7          	jalr	1250(ra) # 80005d9c <plic_complete>
    return 1;
    800028c2:	4505                	li	a0,1
    800028c4:	bf55                	j	80002878 <devintr+0x1e>
      uartintr();
    800028c6:	ffffe097          	auipc	ra,0xffffe
    800028ca:	0cc080e7          	jalr	204(ra) # 80000992 <uartintr>
    800028ce:	b7ed                	j	800028b8 <devintr+0x5e>
      virtio_disk_intr();
    800028d0:	00004097          	auipc	ra,0x4
    800028d4:	958080e7          	jalr	-1704(ra) # 80006228 <virtio_disk_intr>
    800028d8:	b7c5                	j	800028b8 <devintr+0x5e>
    if(cpuid() == 0){
    800028da:	fffff097          	auipc	ra,0xfffff
    800028de:	090080e7          	jalr	144(ra) # 8000196a <cpuid>
    800028e2:	c901                	beqz	a0,800028f2 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800028e4:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800028e8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800028ea:	14479073          	csrw	sip,a5
    return 2;
    800028ee:	4509                	li	a0,2
    800028f0:	b761                	j	80002878 <devintr+0x1e>
      clockintr();
    800028f2:	00000097          	auipc	ra,0x0
    800028f6:	f22080e7          	jalr	-222(ra) # 80002814 <clockintr>
    800028fa:	b7ed                	j	800028e4 <devintr+0x8a>

00000000800028fc <usertrap>:
{
    800028fc:	1101                	addi	sp,sp,-32
    800028fe:	ec06                	sd	ra,24(sp)
    80002900:	e822                	sd	s0,16(sp)
    80002902:	e426                	sd	s1,8(sp)
    80002904:	e04a                	sd	s2,0(sp)
    80002906:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002908:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000290c:	1007f793          	andi	a5,a5,256
    80002910:	e7ad                	bnez	a5,8000297a <usertrap+0x7e>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002912:	00003797          	auipc	a5,0x3
    80002916:	35e78793          	addi	a5,a5,862 # 80005c70 <kernelvec>
    8000291a:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000291e:	fffff097          	auipc	ra,0xfffff
    80002922:	078080e7          	jalr	120(ra) # 80001996 <myproc>
    80002926:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002928:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000292a:	14102773          	csrr	a4,sepc
    8000292e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002930:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002934:	47a1                	li	a5,8
    80002936:	06f71063          	bne	a4,a5,80002996 <usertrap+0x9a>
    if(p->killed)
    8000293a:	551c                	lw	a5,40(a0)
    8000293c:	e7b9                	bnez	a5,8000298a <usertrap+0x8e>
    p->trapframe->epc += 4;
    8000293e:	6cb8                	ld	a4,88(s1)
    80002940:	6f1c                	ld	a5,24(a4)
    80002942:	0791                	addi	a5,a5,4
    80002944:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002946:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000294a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000294e:	10079073          	csrw	sstatus,a5
    syscall();
    80002952:	00000097          	auipc	ra,0x0
    80002956:	2fe080e7          	jalr	766(ra) # 80002c50 <syscall>
  if(p->killed)
    8000295a:	549c                	lw	a5,40(s1)
    8000295c:	ebd9                	bnez	a5,800029f2 <usertrap+0xf6>
    yield();
    8000295e:	fffff097          	auipc	ra,0xfffff
    80002962:	6c4080e7          	jalr	1732(ra) # 80002022 <yield>
  usertrapret();
    80002966:	00000097          	auipc	ra,0x0
    8000296a:	e10080e7          	jalr	-496(ra) # 80002776 <usertrapret>
}
    8000296e:	60e2                	ld	ra,24(sp)
    80002970:	6442                	ld	s0,16(sp)
    80002972:	64a2                	ld	s1,8(sp)
    80002974:	6902                	ld	s2,0(sp)
    80002976:	6105                	addi	sp,sp,32
    80002978:	8082                	ret
    panic("usertrap: not from user mode");
    8000297a:	00006517          	auipc	a0,0x6
    8000297e:	99e50513          	addi	a0,a0,-1634 # 80008318 <states.0+0x58>
    80002982:	ffffe097          	auipc	ra,0xffffe
    80002986:	bb8080e7          	jalr	-1096(ra) # 8000053a <panic>
      exit(-1);
    8000298a:	557d                	li	a0,-1
    8000298c:	00000097          	auipc	ra,0x0
    80002990:	92e080e7          	jalr	-1746(ra) # 800022ba <exit>
    80002994:	b76d                	j	8000293e <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002996:	00000097          	auipc	ra,0x0
    8000299a:	ec4080e7          	jalr	-316(ra) # 8000285a <devintr>
    8000299e:	892a                	mv	s2,a0
    800029a0:	c501                	beqz	a0,800029a8 <usertrap+0xac>
  if(p->killed)
    800029a2:	549c                	lw	a5,40(s1)
    800029a4:	c3a1                	beqz	a5,800029e4 <usertrap+0xe8>
    800029a6:	a815                	j	800029da <usertrap+0xde>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029a8:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800029ac:	5890                	lw	a2,48(s1)
    800029ae:	00006517          	auipc	a0,0x6
    800029b2:	98a50513          	addi	a0,a0,-1654 # 80008338 <states.0+0x78>
    800029b6:	ffffe097          	auipc	ra,0xffffe
    800029ba:	bce080e7          	jalr	-1074(ra) # 80000584 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029be:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029c2:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029c6:	00006517          	auipc	a0,0x6
    800029ca:	9a250513          	addi	a0,a0,-1630 # 80008368 <states.0+0xa8>
    800029ce:	ffffe097          	auipc	ra,0xffffe
    800029d2:	bb6080e7          	jalr	-1098(ra) # 80000584 <printf>
    p->killed = 1;
    800029d6:	4785                	li	a5,1
    800029d8:	d49c                	sw	a5,40(s1)
    exit(-1);
    800029da:	557d                	li	a0,-1
    800029dc:	00000097          	auipc	ra,0x0
    800029e0:	8de080e7          	jalr	-1826(ra) # 800022ba <exit>
  if(which_dev == 2)
    800029e4:	4789                	li	a5,2
    800029e6:	f6f91ce3          	bne	s2,a5,8000295e <usertrap+0x62>
   p->cputime += 1; 
    800029ea:	58dc                	lw	a5,52(s1)
    800029ec:	2785                	addiw	a5,a5,1
    800029ee:	d8dc                	sw	a5,52(s1)
    800029f0:	b7bd                	j	8000295e <usertrap+0x62>
  int which_dev = 0;
    800029f2:	4901                	li	s2,0
    800029f4:	b7dd                	j	800029da <usertrap+0xde>

00000000800029f6 <kerneltrap>:
{
    800029f6:	7179                	addi	sp,sp,-48
    800029f8:	f406                	sd	ra,40(sp)
    800029fa:	f022                	sd	s0,32(sp)
    800029fc:	ec26                	sd	s1,24(sp)
    800029fe:	e84a                	sd	s2,16(sp)
    80002a00:	e44e                	sd	s3,8(sp)
    80002a02:	e052                	sd	s4,0(sp)
    80002a04:	1800                	addi	s0,sp,48
  struct proc *p = myproc();     
    80002a06:	fffff097          	auipc	ra,0xfffff
    80002a0a:	f90080e7          	jalr	-112(ra) # 80001996 <myproc>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a0e:	141029f3          	csrr	s3,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a12:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a16:	14202a73          	csrr	s4,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002a1a:	1004f793          	andi	a5,s1,256
    80002a1e:	cb95                	beqz	a5,80002a52 <kerneltrap+0x5c>
    80002a20:	892a                	mv	s2,a0
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a22:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002a26:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002a28:	ef8d                	bnez	a5,80002a62 <kerneltrap+0x6c>
  if((which_dev = devintr()) == 0){
    80002a2a:	00000097          	auipc	ra,0x0
    80002a2e:	e30080e7          	jalr	-464(ra) # 8000285a <devintr>
    80002a32:	c121                	beqz	a0,80002a72 <kerneltrap+0x7c>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING){
    80002a34:	4789                	li	a5,2
    80002a36:	06f50b63          	beq	a0,a5,80002aac <kerneltrap+0xb6>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a3a:	14199073          	csrw	sepc,s3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a3e:	10049073          	csrw	sstatus,s1
}
    80002a42:	70a2                	ld	ra,40(sp)
    80002a44:	7402                	ld	s0,32(sp)
    80002a46:	64e2                	ld	s1,24(sp)
    80002a48:	6942                	ld	s2,16(sp)
    80002a4a:	69a2                	ld	s3,8(sp)
    80002a4c:	6a02                	ld	s4,0(sp)
    80002a4e:	6145                	addi	sp,sp,48
    80002a50:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002a52:	00006517          	auipc	a0,0x6
    80002a56:	93650513          	addi	a0,a0,-1738 # 80008388 <states.0+0xc8>
    80002a5a:	ffffe097          	auipc	ra,0xffffe
    80002a5e:	ae0080e7          	jalr	-1312(ra) # 8000053a <panic>
    panic("kerneltrap: interrupts enabled");
    80002a62:	00006517          	auipc	a0,0x6
    80002a66:	94e50513          	addi	a0,a0,-1714 # 800083b0 <states.0+0xf0>
    80002a6a:	ffffe097          	auipc	ra,0xffffe
    80002a6e:	ad0080e7          	jalr	-1328(ra) # 8000053a <panic>
    printf("scause %p\n", scause);
    80002a72:	85d2                	mv	a1,s4
    80002a74:	00006517          	auipc	a0,0x6
    80002a78:	95c50513          	addi	a0,a0,-1700 # 800083d0 <states.0+0x110>
    80002a7c:	ffffe097          	auipc	ra,0xffffe
    80002a80:	b08080e7          	jalr	-1272(ra) # 80000584 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a84:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a88:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a8c:	00006517          	auipc	a0,0x6
    80002a90:	95450513          	addi	a0,a0,-1708 # 800083e0 <states.0+0x120>
    80002a94:	ffffe097          	auipc	ra,0xffffe
    80002a98:	af0080e7          	jalr	-1296(ra) # 80000584 <printf>
    panic("kerneltrap");
    80002a9c:	00006517          	auipc	a0,0x6
    80002aa0:	95c50513          	addi	a0,a0,-1700 # 800083f8 <states.0+0x138>
    80002aa4:	ffffe097          	auipc	ra,0xffffe
    80002aa8:	a96080e7          	jalr	-1386(ra) # 8000053a <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING){
    80002aac:	fffff097          	auipc	ra,0xfffff
    80002ab0:	eea080e7          	jalr	-278(ra) # 80001996 <myproc>
    80002ab4:	d159                	beqz	a0,80002a3a <kerneltrap+0x44>
    80002ab6:	fffff097          	auipc	ra,0xfffff
    80002aba:	ee0080e7          	jalr	-288(ra) # 80001996 <myproc>
    80002abe:	4d18                	lw	a4,24(a0)
    80002ac0:	4791                	li	a5,4
    80002ac2:	f6f71ce3          	bne	a4,a5,80002a3a <kerneltrap+0x44>
    p->cputime += 1; 
    80002ac6:	03492783          	lw	a5,52(s2)
    80002aca:	2785                	addiw	a5,a5,1
    80002acc:	02f92a23          	sw	a5,52(s2)
    yield();
    80002ad0:	fffff097          	auipc	ra,0xfffff
    80002ad4:	552080e7          	jalr	1362(ra) # 80002022 <yield>
    80002ad8:	b78d                	j	80002a3a <kerneltrap+0x44>

0000000080002ada <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002ada:	1101                	addi	sp,sp,-32
    80002adc:	ec06                	sd	ra,24(sp)
    80002ade:	e822                	sd	s0,16(sp)
    80002ae0:	e426                	sd	s1,8(sp)
    80002ae2:	1000                	addi	s0,sp,32
    80002ae4:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002ae6:	fffff097          	auipc	ra,0xfffff
    80002aea:	eb0080e7          	jalr	-336(ra) # 80001996 <myproc>
  switch (n) {
    80002aee:	4795                	li	a5,5
    80002af0:	0497e163          	bltu	a5,s1,80002b32 <argraw+0x58>
    80002af4:	048a                	slli	s1,s1,0x2
    80002af6:	00006717          	auipc	a4,0x6
    80002afa:	93a70713          	addi	a4,a4,-1734 # 80008430 <states.0+0x170>
    80002afe:	94ba                	add	s1,s1,a4
    80002b00:	409c                	lw	a5,0(s1)
    80002b02:	97ba                	add	a5,a5,a4
    80002b04:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002b06:	6d3c                	ld	a5,88(a0)
    80002b08:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002b0a:	60e2                	ld	ra,24(sp)
    80002b0c:	6442                	ld	s0,16(sp)
    80002b0e:	64a2                	ld	s1,8(sp)
    80002b10:	6105                	addi	sp,sp,32
    80002b12:	8082                	ret
    return p->trapframe->a1;
    80002b14:	6d3c                	ld	a5,88(a0)
    80002b16:	7fa8                	ld	a0,120(a5)
    80002b18:	bfcd                	j	80002b0a <argraw+0x30>
    return p->trapframe->a2;
    80002b1a:	6d3c                	ld	a5,88(a0)
    80002b1c:	63c8                	ld	a0,128(a5)
    80002b1e:	b7f5                	j	80002b0a <argraw+0x30>
    return p->trapframe->a3;
    80002b20:	6d3c                	ld	a5,88(a0)
    80002b22:	67c8                	ld	a0,136(a5)
    80002b24:	b7dd                	j	80002b0a <argraw+0x30>
    return p->trapframe->a4;
    80002b26:	6d3c                	ld	a5,88(a0)
    80002b28:	6bc8                	ld	a0,144(a5)
    80002b2a:	b7c5                	j	80002b0a <argraw+0x30>
    return p->trapframe->a5;
    80002b2c:	6d3c                	ld	a5,88(a0)
    80002b2e:	6fc8                	ld	a0,152(a5)
    80002b30:	bfe9                	j	80002b0a <argraw+0x30>
  panic("argraw");
    80002b32:	00006517          	auipc	a0,0x6
    80002b36:	8d650513          	addi	a0,a0,-1834 # 80008408 <states.0+0x148>
    80002b3a:	ffffe097          	auipc	ra,0xffffe
    80002b3e:	a00080e7          	jalr	-1536(ra) # 8000053a <panic>

0000000080002b42 <fetchaddr>:
{
    80002b42:	1101                	addi	sp,sp,-32
    80002b44:	ec06                	sd	ra,24(sp)
    80002b46:	e822                	sd	s0,16(sp)
    80002b48:	e426                	sd	s1,8(sp)
    80002b4a:	e04a                	sd	s2,0(sp)
    80002b4c:	1000                	addi	s0,sp,32
    80002b4e:	84aa                	mv	s1,a0
    80002b50:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002b52:	fffff097          	auipc	ra,0xfffff
    80002b56:	e44080e7          	jalr	-444(ra) # 80001996 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002b5a:	653c                	ld	a5,72(a0)
    80002b5c:	02f4f863          	bgeu	s1,a5,80002b8c <fetchaddr+0x4a>
    80002b60:	00848713          	addi	a4,s1,8
    80002b64:	02e7e663          	bltu	a5,a4,80002b90 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002b68:	46a1                	li	a3,8
    80002b6a:	8626                	mv	a2,s1
    80002b6c:	85ca                	mv	a1,s2
    80002b6e:	6928                	ld	a0,80(a0)
    80002b70:	fffff097          	auipc	ra,0xfffff
    80002b74:	b76080e7          	jalr	-1162(ra) # 800016e6 <copyin>
    80002b78:	00a03533          	snez	a0,a0
    80002b7c:	40a00533          	neg	a0,a0
}
    80002b80:	60e2                	ld	ra,24(sp)
    80002b82:	6442                	ld	s0,16(sp)
    80002b84:	64a2                	ld	s1,8(sp)
    80002b86:	6902                	ld	s2,0(sp)
    80002b88:	6105                	addi	sp,sp,32
    80002b8a:	8082                	ret
    return -1;
    80002b8c:	557d                	li	a0,-1
    80002b8e:	bfcd                	j	80002b80 <fetchaddr+0x3e>
    80002b90:	557d                	li	a0,-1
    80002b92:	b7fd                	j	80002b80 <fetchaddr+0x3e>

0000000080002b94 <fetchstr>:
{
    80002b94:	7179                	addi	sp,sp,-48
    80002b96:	f406                	sd	ra,40(sp)
    80002b98:	f022                	sd	s0,32(sp)
    80002b9a:	ec26                	sd	s1,24(sp)
    80002b9c:	e84a                	sd	s2,16(sp)
    80002b9e:	e44e                	sd	s3,8(sp)
    80002ba0:	1800                	addi	s0,sp,48
    80002ba2:	892a                	mv	s2,a0
    80002ba4:	84ae                	mv	s1,a1
    80002ba6:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002ba8:	fffff097          	auipc	ra,0xfffff
    80002bac:	dee080e7          	jalr	-530(ra) # 80001996 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002bb0:	86ce                	mv	a3,s3
    80002bb2:	864a                	mv	a2,s2
    80002bb4:	85a6                	mv	a1,s1
    80002bb6:	6928                	ld	a0,80(a0)
    80002bb8:	fffff097          	auipc	ra,0xfffff
    80002bbc:	bbc080e7          	jalr	-1092(ra) # 80001774 <copyinstr>
  if(err < 0)
    80002bc0:	00054763          	bltz	a0,80002bce <fetchstr+0x3a>
  return strlen(buf);
    80002bc4:	8526                	mv	a0,s1
    80002bc6:	ffffe097          	auipc	ra,0xffffe
    80002bca:	282080e7          	jalr	642(ra) # 80000e48 <strlen>
}
    80002bce:	70a2                	ld	ra,40(sp)
    80002bd0:	7402                	ld	s0,32(sp)
    80002bd2:	64e2                	ld	s1,24(sp)
    80002bd4:	6942                	ld	s2,16(sp)
    80002bd6:	69a2                	ld	s3,8(sp)
    80002bd8:	6145                	addi	sp,sp,48
    80002bda:	8082                	ret

0000000080002bdc <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002bdc:	1101                	addi	sp,sp,-32
    80002bde:	ec06                	sd	ra,24(sp)
    80002be0:	e822                	sd	s0,16(sp)
    80002be2:	e426                	sd	s1,8(sp)
    80002be4:	1000                	addi	s0,sp,32
    80002be6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002be8:	00000097          	auipc	ra,0x0
    80002bec:	ef2080e7          	jalr	-270(ra) # 80002ada <argraw>
    80002bf0:	c088                	sw	a0,0(s1)
  return 0;
}
    80002bf2:	4501                	li	a0,0
    80002bf4:	60e2                	ld	ra,24(sp)
    80002bf6:	6442                	ld	s0,16(sp)
    80002bf8:	64a2                	ld	s1,8(sp)
    80002bfa:	6105                	addi	sp,sp,32
    80002bfc:	8082                	ret

0000000080002bfe <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002bfe:	1101                	addi	sp,sp,-32
    80002c00:	ec06                	sd	ra,24(sp)
    80002c02:	e822                	sd	s0,16(sp)
    80002c04:	e426                	sd	s1,8(sp)
    80002c06:	1000                	addi	s0,sp,32
    80002c08:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c0a:	00000097          	auipc	ra,0x0
    80002c0e:	ed0080e7          	jalr	-304(ra) # 80002ada <argraw>
    80002c12:	e088                	sd	a0,0(s1)
  return 0;
}
    80002c14:	4501                	li	a0,0
    80002c16:	60e2                	ld	ra,24(sp)
    80002c18:	6442                	ld	s0,16(sp)
    80002c1a:	64a2                	ld	s1,8(sp)
    80002c1c:	6105                	addi	sp,sp,32
    80002c1e:	8082                	ret

0000000080002c20 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002c20:	1101                	addi	sp,sp,-32
    80002c22:	ec06                	sd	ra,24(sp)
    80002c24:	e822                	sd	s0,16(sp)
    80002c26:	e426                	sd	s1,8(sp)
    80002c28:	e04a                	sd	s2,0(sp)
    80002c2a:	1000                	addi	s0,sp,32
    80002c2c:	84ae                	mv	s1,a1
    80002c2e:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002c30:	00000097          	auipc	ra,0x0
    80002c34:	eaa080e7          	jalr	-342(ra) # 80002ada <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002c38:	864a                	mv	a2,s2
    80002c3a:	85a6                	mv	a1,s1
    80002c3c:	00000097          	auipc	ra,0x0
    80002c40:	f58080e7          	jalr	-168(ra) # 80002b94 <fetchstr>
}
    80002c44:	60e2                	ld	ra,24(sp)
    80002c46:	6442                	ld	s0,16(sp)
    80002c48:	64a2                	ld	s1,8(sp)
    80002c4a:	6902                	ld	s2,0(sp)
    80002c4c:	6105                	addi	sp,sp,32
    80002c4e:	8082                	ret

0000000080002c50 <syscall>:
[SYS_wait2]   sys_wait2,
};

void
syscall(void)
{
    80002c50:	1101                	addi	sp,sp,-32
    80002c52:	ec06                	sd	ra,24(sp)
    80002c54:	e822                	sd	s0,16(sp)
    80002c56:	e426                	sd	s1,8(sp)
    80002c58:	e04a                	sd	s2,0(sp)
    80002c5a:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002c5c:	fffff097          	auipc	ra,0xfffff
    80002c60:	d3a080e7          	jalr	-710(ra) # 80001996 <myproc>
    80002c64:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002c66:	05853903          	ld	s2,88(a0)
    80002c6a:	0a893783          	ld	a5,168(s2)
    80002c6e:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002c72:	37fd                	addiw	a5,a5,-1
    80002c74:	4755                	li	a4,21
    80002c76:	00f76f63          	bltu	a4,a5,80002c94 <syscall+0x44>
    80002c7a:	00369713          	slli	a4,a3,0x3
    80002c7e:	00005797          	auipc	a5,0x5
    80002c82:	7ca78793          	addi	a5,a5,1994 # 80008448 <syscalls>
    80002c86:	97ba                	add	a5,a5,a4
    80002c88:	639c                	ld	a5,0(a5)
    80002c8a:	c789                	beqz	a5,80002c94 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002c8c:	9782                	jalr	a5
    80002c8e:	06a93823          	sd	a0,112(s2)
    80002c92:	a839                	j	80002cb0 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002c94:	15848613          	addi	a2,s1,344
    80002c98:	588c                	lw	a1,48(s1)
    80002c9a:	00005517          	auipc	a0,0x5
    80002c9e:	77650513          	addi	a0,a0,1910 # 80008410 <states.0+0x150>
    80002ca2:	ffffe097          	auipc	ra,0xffffe
    80002ca6:	8e2080e7          	jalr	-1822(ra) # 80000584 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002caa:	6cbc                	ld	a5,88(s1)
    80002cac:	577d                	li	a4,-1
    80002cae:	fbb8                	sd	a4,112(a5)
  }
}
    80002cb0:	60e2                	ld	ra,24(sp)
    80002cb2:	6442                	ld	s0,16(sp)
    80002cb4:	64a2                	ld	s1,8(sp)
    80002cb6:	6902                	ld	s2,0(sp)
    80002cb8:	6105                	addi	sp,sp,32
    80002cba:	8082                	ret

0000000080002cbc <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002cbc:	1101                	addi	sp,sp,-32
    80002cbe:	ec06                	sd	ra,24(sp)
    80002cc0:	e822                	sd	s0,16(sp)
    80002cc2:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002cc4:	fec40593          	addi	a1,s0,-20
    80002cc8:	4501                	li	a0,0
    80002cca:	00000097          	auipc	ra,0x0
    80002cce:	f12080e7          	jalr	-238(ra) # 80002bdc <argint>
    return -1;
    80002cd2:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002cd4:	00054963          	bltz	a0,80002ce6 <sys_exit+0x2a>
  exit(n);
    80002cd8:	fec42503          	lw	a0,-20(s0)
    80002cdc:	fffff097          	auipc	ra,0xfffff
    80002ce0:	5de080e7          	jalr	1502(ra) # 800022ba <exit>
  return 0;  // not reached
    80002ce4:	4781                	li	a5,0
}
    80002ce6:	853e                	mv	a0,a5
    80002ce8:	60e2                	ld	ra,24(sp)
    80002cea:	6442                	ld	s0,16(sp)
    80002cec:	6105                	addi	sp,sp,32
    80002cee:	8082                	ret

0000000080002cf0 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002cf0:	1141                	addi	sp,sp,-16
    80002cf2:	e406                	sd	ra,8(sp)
    80002cf4:	e022                	sd	s0,0(sp)
    80002cf6:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002cf8:	fffff097          	auipc	ra,0xfffff
    80002cfc:	c9e080e7          	jalr	-866(ra) # 80001996 <myproc>
}
    80002d00:	5908                	lw	a0,48(a0)
    80002d02:	60a2                	ld	ra,8(sp)
    80002d04:	6402                	ld	s0,0(sp)
    80002d06:	0141                	addi	sp,sp,16
    80002d08:	8082                	ret

0000000080002d0a <sys_fork>:

uint64
sys_fork(void)
{
    80002d0a:	1141                	addi	sp,sp,-16
    80002d0c:	e406                	sd	ra,8(sp)
    80002d0e:	e022                	sd	s0,0(sp)
    80002d10:	0800                	addi	s0,sp,16
  return fork();
    80002d12:	fffff097          	auipc	ra,0xfffff
    80002d16:	05a080e7          	jalr	90(ra) # 80001d6c <fork>
}
    80002d1a:	60a2                	ld	ra,8(sp)
    80002d1c:	6402                	ld	s0,0(sp)
    80002d1e:	0141                	addi	sp,sp,16
    80002d20:	8082                	ret

0000000080002d22 <sys_wait>:

uint64
sys_wait(void)
{
    80002d22:	1101                	addi	sp,sp,-32
    80002d24:	ec06                	sd	ra,24(sp)
    80002d26:	e822                	sd	s0,16(sp)
    80002d28:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002d2a:	fe840593          	addi	a1,s0,-24
    80002d2e:	4501                	li	a0,0
    80002d30:	00000097          	auipc	ra,0x0
    80002d34:	ece080e7          	jalr	-306(ra) # 80002bfe <argaddr>
    80002d38:	87aa                	mv	a5,a0
    return -1;
    80002d3a:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002d3c:	0007c863          	bltz	a5,80002d4c <sys_wait+0x2a>
  return wait(p);
    80002d40:	fe843503          	ld	a0,-24(s0)
    80002d44:	fffff097          	auipc	ra,0xfffff
    80002d48:	37e080e7          	jalr	894(ra) # 800020c2 <wait>
}
    80002d4c:	60e2                	ld	ra,24(sp)
    80002d4e:	6442                	ld	s0,16(sp)
    80002d50:	6105                	addi	sp,sp,32
    80002d52:	8082                	ret

0000000080002d54 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002d54:	7179                	addi	sp,sp,-48
    80002d56:	f406                	sd	ra,40(sp)
    80002d58:	f022                	sd	s0,32(sp)
    80002d5a:	ec26                	sd	s1,24(sp)
    80002d5c:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002d5e:	fdc40593          	addi	a1,s0,-36
    80002d62:	4501                	li	a0,0
    80002d64:	00000097          	auipc	ra,0x0
    80002d68:	e78080e7          	jalr	-392(ra) # 80002bdc <argint>
    80002d6c:	87aa                	mv	a5,a0
    return -1;
    80002d6e:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002d70:	0207c063          	bltz	a5,80002d90 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002d74:	fffff097          	auipc	ra,0xfffff
    80002d78:	c22080e7          	jalr	-990(ra) # 80001996 <myproc>
    80002d7c:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002d7e:	fdc42503          	lw	a0,-36(s0)
    80002d82:	fffff097          	auipc	ra,0xfffff
    80002d86:	f72080e7          	jalr	-142(ra) # 80001cf4 <growproc>
    80002d8a:	00054863          	bltz	a0,80002d9a <sys_sbrk+0x46>
    return -1;
  return addr;
    80002d8e:	8526                	mv	a0,s1
}
    80002d90:	70a2                	ld	ra,40(sp)
    80002d92:	7402                	ld	s0,32(sp)
    80002d94:	64e2                	ld	s1,24(sp)
    80002d96:	6145                	addi	sp,sp,48
    80002d98:	8082                	ret
    return -1;
    80002d9a:	557d                	li	a0,-1
    80002d9c:	bfd5                	j	80002d90 <sys_sbrk+0x3c>

0000000080002d9e <sys_sleep>:

uint64
sys_sleep(void)
{
    80002d9e:	7139                	addi	sp,sp,-64
    80002da0:	fc06                	sd	ra,56(sp)
    80002da2:	f822                	sd	s0,48(sp)
    80002da4:	f426                	sd	s1,40(sp)
    80002da6:	f04a                	sd	s2,32(sp)
    80002da8:	ec4e                	sd	s3,24(sp)
    80002daa:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002dac:	fcc40593          	addi	a1,s0,-52
    80002db0:	4501                	li	a0,0
    80002db2:	00000097          	auipc	ra,0x0
    80002db6:	e2a080e7          	jalr	-470(ra) # 80002bdc <argint>
    return -1;
    80002dba:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002dbc:	06054563          	bltz	a0,80002e26 <sys_sleep+0x88>
  acquire(&tickslock);
    80002dc0:	00014517          	auipc	a0,0x14
    80002dc4:	31050513          	addi	a0,a0,784 # 800170d0 <tickslock>
    80002dc8:	ffffe097          	auipc	ra,0xffffe
    80002dcc:	e08080e7          	jalr	-504(ra) # 80000bd0 <acquire>
  ticks0 = ticks;
    80002dd0:	00006917          	auipc	s2,0x6
    80002dd4:	26092903          	lw	s2,608(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    80002dd8:	fcc42783          	lw	a5,-52(s0)
    80002ddc:	cf85                	beqz	a5,80002e14 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002dde:	00014997          	auipc	s3,0x14
    80002de2:	2f298993          	addi	s3,s3,754 # 800170d0 <tickslock>
    80002de6:	00006497          	auipc	s1,0x6
    80002dea:	24a48493          	addi	s1,s1,586 # 80009030 <ticks>
    if(myproc()->killed){
    80002dee:	fffff097          	auipc	ra,0xfffff
    80002df2:	ba8080e7          	jalr	-1112(ra) # 80001996 <myproc>
    80002df6:	551c                	lw	a5,40(a0)
    80002df8:	ef9d                	bnez	a5,80002e36 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002dfa:	85ce                	mv	a1,s3
    80002dfc:	8526                	mv	a0,s1
    80002dfe:	fffff097          	auipc	ra,0xfffff
    80002e02:	260080e7          	jalr	608(ra) # 8000205e <sleep>
  while(ticks - ticks0 < n){
    80002e06:	409c                	lw	a5,0(s1)
    80002e08:	412787bb          	subw	a5,a5,s2
    80002e0c:	fcc42703          	lw	a4,-52(s0)
    80002e10:	fce7efe3          	bltu	a5,a4,80002dee <sys_sleep+0x50>
  }
  release(&tickslock);
    80002e14:	00014517          	auipc	a0,0x14
    80002e18:	2bc50513          	addi	a0,a0,700 # 800170d0 <tickslock>
    80002e1c:	ffffe097          	auipc	ra,0xffffe
    80002e20:	e68080e7          	jalr	-408(ra) # 80000c84 <release>
  return 0;
    80002e24:	4781                	li	a5,0
}
    80002e26:	853e                	mv	a0,a5
    80002e28:	70e2                	ld	ra,56(sp)
    80002e2a:	7442                	ld	s0,48(sp)
    80002e2c:	74a2                	ld	s1,40(sp)
    80002e2e:	7902                	ld	s2,32(sp)
    80002e30:	69e2                	ld	s3,24(sp)
    80002e32:	6121                	addi	sp,sp,64
    80002e34:	8082                	ret
      release(&tickslock);
    80002e36:	00014517          	auipc	a0,0x14
    80002e3a:	29a50513          	addi	a0,a0,666 # 800170d0 <tickslock>
    80002e3e:	ffffe097          	auipc	ra,0xffffe
    80002e42:	e46080e7          	jalr	-442(ra) # 80000c84 <release>
      return -1;
    80002e46:	57fd                	li	a5,-1
    80002e48:	bff9                	j	80002e26 <sys_sleep+0x88>

0000000080002e4a <sys_kill>:

uint64
sys_kill(void)
{
    80002e4a:	1101                	addi	sp,sp,-32
    80002e4c:	ec06                	sd	ra,24(sp)
    80002e4e:	e822                	sd	s0,16(sp)
    80002e50:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002e52:	fec40593          	addi	a1,s0,-20
    80002e56:	4501                	li	a0,0
    80002e58:	00000097          	auipc	ra,0x0
    80002e5c:	d84080e7          	jalr	-636(ra) # 80002bdc <argint>
    80002e60:	87aa                	mv	a5,a0
    return -1;
    80002e62:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002e64:	0007c863          	bltz	a5,80002e74 <sys_kill+0x2a>
  return kill(pid);
    80002e68:	fec42503          	lw	a0,-20(s0)
    80002e6c:	fffff097          	auipc	ra,0xfffff
    80002e70:	524080e7          	jalr	1316(ra) # 80002390 <kill>
}
    80002e74:	60e2                	ld	ra,24(sp)
    80002e76:	6442                	ld	s0,16(sp)
    80002e78:	6105                	addi	sp,sp,32
    80002e7a:	8082                	ret

0000000080002e7c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002e7c:	1101                	addi	sp,sp,-32
    80002e7e:	ec06                	sd	ra,24(sp)
    80002e80:	e822                	sd	s0,16(sp)
    80002e82:	e426                	sd	s1,8(sp)
    80002e84:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002e86:	00014517          	auipc	a0,0x14
    80002e8a:	24a50513          	addi	a0,a0,586 # 800170d0 <tickslock>
    80002e8e:	ffffe097          	auipc	ra,0xffffe
    80002e92:	d42080e7          	jalr	-702(ra) # 80000bd0 <acquire>
  xticks = ticks;
    80002e96:	00006497          	auipc	s1,0x6
    80002e9a:	19a4a483          	lw	s1,410(s1) # 80009030 <ticks>
  release(&tickslock);
    80002e9e:	00014517          	auipc	a0,0x14
    80002ea2:	23250513          	addi	a0,a0,562 # 800170d0 <tickslock>
    80002ea6:	ffffe097          	auipc	ra,0xffffe
    80002eaa:	dde080e7          	jalr	-546(ra) # 80000c84 <release>
  return xticks;
}
    80002eae:	02049513          	slli	a0,s1,0x20
    80002eb2:	9101                	srli	a0,a0,0x20
    80002eb4:	60e2                	ld	ra,24(sp)
    80002eb6:	6442                	ld	s0,16(sp)
    80002eb8:	64a2                	ld	s1,8(sp)
    80002eba:	6105                	addi	sp,sp,32
    80002ebc:	8082                	ret

0000000080002ebe <sys_wait2>:


uint64
sys_wait2(void)
{
    80002ebe:	1101                	addi	sp,sp,-32
    80002ec0:	ec06                	sd	ra,24(sp)
    80002ec2:	e822                	sd	s0,16(sp)
    80002ec4:	1000                	addi	s0,sp,32
  uint64 p;
  uint64 p2;
  if(argaddr(0, &p) < 0){
    80002ec6:	fe840593          	addi	a1,s0,-24
    80002eca:	4501                	li	a0,0
    80002ecc:	00000097          	auipc	ra,0x0
    80002ed0:	d32080e7          	jalr	-718(ra) # 80002bfe <argaddr>
    return -1;
    80002ed4:	57fd                	li	a5,-1
  if(argaddr(0, &p) < 0){
    80002ed6:	02054563          	bltz	a0,80002f00 <sys_wait2+0x42>
  }
  if(argaddr(1,&p2) < 0){
    80002eda:	fe040593          	addi	a1,s0,-32
    80002ede:	4505                	li	a0,1
    80002ee0:	00000097          	auipc	ra,0x0
    80002ee4:	d1e080e7          	jalr	-738(ra) # 80002bfe <argaddr>
  return -1;
    80002ee8:	57fd                	li	a5,-1
  if(argaddr(1,&p2) < 0){
    80002eea:	00054b63          	bltz	a0,80002f00 <sys_wait2+0x42>
  }
  return wait2(p,p2);
    80002eee:	fe043583          	ld	a1,-32(s0)
    80002ef2:	fe843503          	ld	a0,-24(s0)
    80002ef6:	fffff097          	auipc	ra,0xfffff
    80002efa:	668080e7          	jalr	1640(ra) # 8000255e <wait2>
    80002efe:	87aa                	mv	a5,a0
}
    80002f00:	853e                	mv	a0,a5
    80002f02:	60e2                	ld	ra,24(sp)
    80002f04:	6442                	ld	s0,16(sp)
    80002f06:	6105                	addi	sp,sp,32
    80002f08:	8082                	ret

0000000080002f0a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002f0a:	7179                	addi	sp,sp,-48
    80002f0c:	f406                	sd	ra,40(sp)
    80002f0e:	f022                	sd	s0,32(sp)
    80002f10:	ec26                	sd	s1,24(sp)
    80002f12:	e84a                	sd	s2,16(sp)
    80002f14:	e44e                	sd	s3,8(sp)
    80002f16:	e052                	sd	s4,0(sp)
    80002f18:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002f1a:	00005597          	auipc	a1,0x5
    80002f1e:	5e658593          	addi	a1,a1,1510 # 80008500 <syscalls+0xb8>
    80002f22:	00014517          	auipc	a0,0x14
    80002f26:	1c650513          	addi	a0,a0,454 # 800170e8 <bcache>
    80002f2a:	ffffe097          	auipc	ra,0xffffe
    80002f2e:	c16080e7          	jalr	-1002(ra) # 80000b40 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002f32:	0001c797          	auipc	a5,0x1c
    80002f36:	1b678793          	addi	a5,a5,438 # 8001f0e8 <bcache+0x8000>
    80002f3a:	0001c717          	auipc	a4,0x1c
    80002f3e:	41670713          	addi	a4,a4,1046 # 8001f350 <bcache+0x8268>
    80002f42:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002f46:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f4a:	00014497          	auipc	s1,0x14
    80002f4e:	1b648493          	addi	s1,s1,438 # 80017100 <bcache+0x18>
    b->next = bcache.head.next;
    80002f52:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002f54:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002f56:	00005a17          	auipc	s4,0x5
    80002f5a:	5b2a0a13          	addi	s4,s4,1458 # 80008508 <syscalls+0xc0>
    b->next = bcache.head.next;
    80002f5e:	2b893783          	ld	a5,696(s2)
    80002f62:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002f64:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002f68:	85d2                	mv	a1,s4
    80002f6a:	01048513          	addi	a0,s1,16
    80002f6e:	00001097          	auipc	ra,0x1
    80002f72:	4c2080e7          	jalr	1218(ra) # 80004430 <initsleeplock>
    bcache.head.next->prev = b;
    80002f76:	2b893783          	ld	a5,696(s2)
    80002f7a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002f7c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f80:	45848493          	addi	s1,s1,1112
    80002f84:	fd349de3          	bne	s1,s3,80002f5e <binit+0x54>
  }
}
    80002f88:	70a2                	ld	ra,40(sp)
    80002f8a:	7402                	ld	s0,32(sp)
    80002f8c:	64e2                	ld	s1,24(sp)
    80002f8e:	6942                	ld	s2,16(sp)
    80002f90:	69a2                	ld	s3,8(sp)
    80002f92:	6a02                	ld	s4,0(sp)
    80002f94:	6145                	addi	sp,sp,48
    80002f96:	8082                	ret

0000000080002f98 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002f98:	7179                	addi	sp,sp,-48
    80002f9a:	f406                	sd	ra,40(sp)
    80002f9c:	f022                	sd	s0,32(sp)
    80002f9e:	ec26                	sd	s1,24(sp)
    80002fa0:	e84a                	sd	s2,16(sp)
    80002fa2:	e44e                	sd	s3,8(sp)
    80002fa4:	1800                	addi	s0,sp,48
    80002fa6:	892a                	mv	s2,a0
    80002fa8:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002faa:	00014517          	auipc	a0,0x14
    80002fae:	13e50513          	addi	a0,a0,318 # 800170e8 <bcache>
    80002fb2:	ffffe097          	auipc	ra,0xffffe
    80002fb6:	c1e080e7          	jalr	-994(ra) # 80000bd0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002fba:	0001c497          	auipc	s1,0x1c
    80002fbe:	3e64b483          	ld	s1,998(s1) # 8001f3a0 <bcache+0x82b8>
    80002fc2:	0001c797          	auipc	a5,0x1c
    80002fc6:	38e78793          	addi	a5,a5,910 # 8001f350 <bcache+0x8268>
    80002fca:	02f48f63          	beq	s1,a5,80003008 <bread+0x70>
    80002fce:	873e                	mv	a4,a5
    80002fd0:	a021                	j	80002fd8 <bread+0x40>
    80002fd2:	68a4                	ld	s1,80(s1)
    80002fd4:	02e48a63          	beq	s1,a4,80003008 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002fd8:	449c                	lw	a5,8(s1)
    80002fda:	ff279ce3          	bne	a5,s2,80002fd2 <bread+0x3a>
    80002fde:	44dc                	lw	a5,12(s1)
    80002fe0:	ff3799e3          	bne	a5,s3,80002fd2 <bread+0x3a>
      b->refcnt++;
    80002fe4:	40bc                	lw	a5,64(s1)
    80002fe6:	2785                	addiw	a5,a5,1
    80002fe8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002fea:	00014517          	auipc	a0,0x14
    80002fee:	0fe50513          	addi	a0,a0,254 # 800170e8 <bcache>
    80002ff2:	ffffe097          	auipc	ra,0xffffe
    80002ff6:	c92080e7          	jalr	-878(ra) # 80000c84 <release>
      acquiresleep(&b->lock);
    80002ffa:	01048513          	addi	a0,s1,16
    80002ffe:	00001097          	auipc	ra,0x1
    80003002:	46c080e7          	jalr	1132(ra) # 8000446a <acquiresleep>
      return b;
    80003006:	a8b9                	j	80003064 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003008:	0001c497          	auipc	s1,0x1c
    8000300c:	3904b483          	ld	s1,912(s1) # 8001f398 <bcache+0x82b0>
    80003010:	0001c797          	auipc	a5,0x1c
    80003014:	34078793          	addi	a5,a5,832 # 8001f350 <bcache+0x8268>
    80003018:	00f48863          	beq	s1,a5,80003028 <bread+0x90>
    8000301c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000301e:	40bc                	lw	a5,64(s1)
    80003020:	cf81                	beqz	a5,80003038 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003022:	64a4                	ld	s1,72(s1)
    80003024:	fee49de3          	bne	s1,a4,8000301e <bread+0x86>
  panic("bget: no buffers");
    80003028:	00005517          	auipc	a0,0x5
    8000302c:	4e850513          	addi	a0,a0,1256 # 80008510 <syscalls+0xc8>
    80003030:	ffffd097          	auipc	ra,0xffffd
    80003034:	50a080e7          	jalr	1290(ra) # 8000053a <panic>
      b->dev = dev;
    80003038:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000303c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003040:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003044:	4785                	li	a5,1
    80003046:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003048:	00014517          	auipc	a0,0x14
    8000304c:	0a050513          	addi	a0,a0,160 # 800170e8 <bcache>
    80003050:	ffffe097          	auipc	ra,0xffffe
    80003054:	c34080e7          	jalr	-972(ra) # 80000c84 <release>
      acquiresleep(&b->lock);
    80003058:	01048513          	addi	a0,s1,16
    8000305c:	00001097          	auipc	ra,0x1
    80003060:	40e080e7          	jalr	1038(ra) # 8000446a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003064:	409c                	lw	a5,0(s1)
    80003066:	cb89                	beqz	a5,80003078 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003068:	8526                	mv	a0,s1
    8000306a:	70a2                	ld	ra,40(sp)
    8000306c:	7402                	ld	s0,32(sp)
    8000306e:	64e2                	ld	s1,24(sp)
    80003070:	6942                	ld	s2,16(sp)
    80003072:	69a2                	ld	s3,8(sp)
    80003074:	6145                	addi	sp,sp,48
    80003076:	8082                	ret
    virtio_disk_rw(b, 0);
    80003078:	4581                	li	a1,0
    8000307a:	8526                	mv	a0,s1
    8000307c:	00003097          	auipc	ra,0x3
    80003080:	f26080e7          	jalr	-218(ra) # 80005fa2 <virtio_disk_rw>
    b->valid = 1;
    80003084:	4785                	li	a5,1
    80003086:	c09c                	sw	a5,0(s1)
  return b;
    80003088:	b7c5                	j	80003068 <bread+0xd0>

000000008000308a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000308a:	1101                	addi	sp,sp,-32
    8000308c:	ec06                	sd	ra,24(sp)
    8000308e:	e822                	sd	s0,16(sp)
    80003090:	e426                	sd	s1,8(sp)
    80003092:	1000                	addi	s0,sp,32
    80003094:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003096:	0541                	addi	a0,a0,16
    80003098:	00001097          	auipc	ra,0x1
    8000309c:	46c080e7          	jalr	1132(ra) # 80004504 <holdingsleep>
    800030a0:	cd01                	beqz	a0,800030b8 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800030a2:	4585                	li	a1,1
    800030a4:	8526                	mv	a0,s1
    800030a6:	00003097          	auipc	ra,0x3
    800030aa:	efc080e7          	jalr	-260(ra) # 80005fa2 <virtio_disk_rw>
}
    800030ae:	60e2                	ld	ra,24(sp)
    800030b0:	6442                	ld	s0,16(sp)
    800030b2:	64a2                	ld	s1,8(sp)
    800030b4:	6105                	addi	sp,sp,32
    800030b6:	8082                	ret
    panic("bwrite");
    800030b8:	00005517          	auipc	a0,0x5
    800030bc:	47050513          	addi	a0,a0,1136 # 80008528 <syscalls+0xe0>
    800030c0:	ffffd097          	auipc	ra,0xffffd
    800030c4:	47a080e7          	jalr	1146(ra) # 8000053a <panic>

00000000800030c8 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800030c8:	1101                	addi	sp,sp,-32
    800030ca:	ec06                	sd	ra,24(sp)
    800030cc:	e822                	sd	s0,16(sp)
    800030ce:	e426                	sd	s1,8(sp)
    800030d0:	e04a                	sd	s2,0(sp)
    800030d2:	1000                	addi	s0,sp,32
    800030d4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800030d6:	01050913          	addi	s2,a0,16
    800030da:	854a                	mv	a0,s2
    800030dc:	00001097          	auipc	ra,0x1
    800030e0:	428080e7          	jalr	1064(ra) # 80004504 <holdingsleep>
    800030e4:	c92d                	beqz	a0,80003156 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800030e6:	854a                	mv	a0,s2
    800030e8:	00001097          	auipc	ra,0x1
    800030ec:	3d8080e7          	jalr	984(ra) # 800044c0 <releasesleep>

  acquire(&bcache.lock);
    800030f0:	00014517          	auipc	a0,0x14
    800030f4:	ff850513          	addi	a0,a0,-8 # 800170e8 <bcache>
    800030f8:	ffffe097          	auipc	ra,0xffffe
    800030fc:	ad8080e7          	jalr	-1320(ra) # 80000bd0 <acquire>
  b->refcnt--;
    80003100:	40bc                	lw	a5,64(s1)
    80003102:	37fd                	addiw	a5,a5,-1
    80003104:	0007871b          	sext.w	a4,a5
    80003108:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000310a:	eb05                	bnez	a4,8000313a <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000310c:	68bc                	ld	a5,80(s1)
    8000310e:	64b8                	ld	a4,72(s1)
    80003110:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003112:	64bc                	ld	a5,72(s1)
    80003114:	68b8                	ld	a4,80(s1)
    80003116:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003118:	0001c797          	auipc	a5,0x1c
    8000311c:	fd078793          	addi	a5,a5,-48 # 8001f0e8 <bcache+0x8000>
    80003120:	2b87b703          	ld	a4,696(a5)
    80003124:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003126:	0001c717          	auipc	a4,0x1c
    8000312a:	22a70713          	addi	a4,a4,554 # 8001f350 <bcache+0x8268>
    8000312e:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003130:	2b87b703          	ld	a4,696(a5)
    80003134:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003136:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000313a:	00014517          	auipc	a0,0x14
    8000313e:	fae50513          	addi	a0,a0,-82 # 800170e8 <bcache>
    80003142:	ffffe097          	auipc	ra,0xffffe
    80003146:	b42080e7          	jalr	-1214(ra) # 80000c84 <release>
}
    8000314a:	60e2                	ld	ra,24(sp)
    8000314c:	6442                	ld	s0,16(sp)
    8000314e:	64a2                	ld	s1,8(sp)
    80003150:	6902                	ld	s2,0(sp)
    80003152:	6105                	addi	sp,sp,32
    80003154:	8082                	ret
    panic("brelse");
    80003156:	00005517          	auipc	a0,0x5
    8000315a:	3da50513          	addi	a0,a0,986 # 80008530 <syscalls+0xe8>
    8000315e:	ffffd097          	auipc	ra,0xffffd
    80003162:	3dc080e7          	jalr	988(ra) # 8000053a <panic>

0000000080003166 <bpin>:

void
bpin(struct buf *b) {
    80003166:	1101                	addi	sp,sp,-32
    80003168:	ec06                	sd	ra,24(sp)
    8000316a:	e822                	sd	s0,16(sp)
    8000316c:	e426                	sd	s1,8(sp)
    8000316e:	1000                	addi	s0,sp,32
    80003170:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003172:	00014517          	auipc	a0,0x14
    80003176:	f7650513          	addi	a0,a0,-138 # 800170e8 <bcache>
    8000317a:	ffffe097          	auipc	ra,0xffffe
    8000317e:	a56080e7          	jalr	-1450(ra) # 80000bd0 <acquire>
  b->refcnt++;
    80003182:	40bc                	lw	a5,64(s1)
    80003184:	2785                	addiw	a5,a5,1
    80003186:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003188:	00014517          	auipc	a0,0x14
    8000318c:	f6050513          	addi	a0,a0,-160 # 800170e8 <bcache>
    80003190:	ffffe097          	auipc	ra,0xffffe
    80003194:	af4080e7          	jalr	-1292(ra) # 80000c84 <release>
}
    80003198:	60e2                	ld	ra,24(sp)
    8000319a:	6442                	ld	s0,16(sp)
    8000319c:	64a2                	ld	s1,8(sp)
    8000319e:	6105                	addi	sp,sp,32
    800031a0:	8082                	ret

00000000800031a2 <bunpin>:

void
bunpin(struct buf *b) {
    800031a2:	1101                	addi	sp,sp,-32
    800031a4:	ec06                	sd	ra,24(sp)
    800031a6:	e822                	sd	s0,16(sp)
    800031a8:	e426                	sd	s1,8(sp)
    800031aa:	1000                	addi	s0,sp,32
    800031ac:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800031ae:	00014517          	auipc	a0,0x14
    800031b2:	f3a50513          	addi	a0,a0,-198 # 800170e8 <bcache>
    800031b6:	ffffe097          	auipc	ra,0xffffe
    800031ba:	a1a080e7          	jalr	-1510(ra) # 80000bd0 <acquire>
  b->refcnt--;
    800031be:	40bc                	lw	a5,64(s1)
    800031c0:	37fd                	addiw	a5,a5,-1
    800031c2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800031c4:	00014517          	auipc	a0,0x14
    800031c8:	f2450513          	addi	a0,a0,-220 # 800170e8 <bcache>
    800031cc:	ffffe097          	auipc	ra,0xffffe
    800031d0:	ab8080e7          	jalr	-1352(ra) # 80000c84 <release>
}
    800031d4:	60e2                	ld	ra,24(sp)
    800031d6:	6442                	ld	s0,16(sp)
    800031d8:	64a2                	ld	s1,8(sp)
    800031da:	6105                	addi	sp,sp,32
    800031dc:	8082                	ret

00000000800031de <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800031de:	1101                	addi	sp,sp,-32
    800031e0:	ec06                	sd	ra,24(sp)
    800031e2:	e822                	sd	s0,16(sp)
    800031e4:	e426                	sd	s1,8(sp)
    800031e6:	e04a                	sd	s2,0(sp)
    800031e8:	1000                	addi	s0,sp,32
    800031ea:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800031ec:	00d5d59b          	srliw	a1,a1,0xd
    800031f0:	0001c797          	auipc	a5,0x1c
    800031f4:	5d47a783          	lw	a5,1492(a5) # 8001f7c4 <sb+0x1c>
    800031f8:	9dbd                	addw	a1,a1,a5
    800031fa:	00000097          	auipc	ra,0x0
    800031fe:	d9e080e7          	jalr	-610(ra) # 80002f98 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003202:	0074f713          	andi	a4,s1,7
    80003206:	4785                	li	a5,1
    80003208:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000320c:	14ce                	slli	s1,s1,0x33
    8000320e:	90d9                	srli	s1,s1,0x36
    80003210:	00950733          	add	a4,a0,s1
    80003214:	05874703          	lbu	a4,88(a4)
    80003218:	00e7f6b3          	and	a3,a5,a4
    8000321c:	c69d                	beqz	a3,8000324a <bfree+0x6c>
    8000321e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003220:	94aa                	add	s1,s1,a0
    80003222:	fff7c793          	not	a5,a5
    80003226:	8f7d                	and	a4,a4,a5
    80003228:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000322c:	00001097          	auipc	ra,0x1
    80003230:	120080e7          	jalr	288(ra) # 8000434c <log_write>
  brelse(bp);
    80003234:	854a                	mv	a0,s2
    80003236:	00000097          	auipc	ra,0x0
    8000323a:	e92080e7          	jalr	-366(ra) # 800030c8 <brelse>
}
    8000323e:	60e2                	ld	ra,24(sp)
    80003240:	6442                	ld	s0,16(sp)
    80003242:	64a2                	ld	s1,8(sp)
    80003244:	6902                	ld	s2,0(sp)
    80003246:	6105                	addi	sp,sp,32
    80003248:	8082                	ret
    panic("freeing free block");
    8000324a:	00005517          	auipc	a0,0x5
    8000324e:	2ee50513          	addi	a0,a0,750 # 80008538 <syscalls+0xf0>
    80003252:	ffffd097          	auipc	ra,0xffffd
    80003256:	2e8080e7          	jalr	744(ra) # 8000053a <panic>

000000008000325a <balloc>:
{
    8000325a:	711d                	addi	sp,sp,-96
    8000325c:	ec86                	sd	ra,88(sp)
    8000325e:	e8a2                	sd	s0,80(sp)
    80003260:	e4a6                	sd	s1,72(sp)
    80003262:	e0ca                	sd	s2,64(sp)
    80003264:	fc4e                	sd	s3,56(sp)
    80003266:	f852                	sd	s4,48(sp)
    80003268:	f456                	sd	s5,40(sp)
    8000326a:	f05a                	sd	s6,32(sp)
    8000326c:	ec5e                	sd	s7,24(sp)
    8000326e:	e862                	sd	s8,16(sp)
    80003270:	e466                	sd	s9,8(sp)
    80003272:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003274:	0001c797          	auipc	a5,0x1c
    80003278:	5387a783          	lw	a5,1336(a5) # 8001f7ac <sb+0x4>
    8000327c:	cbc1                	beqz	a5,8000330c <balloc+0xb2>
    8000327e:	8baa                	mv	s7,a0
    80003280:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003282:	0001cb17          	auipc	s6,0x1c
    80003286:	526b0b13          	addi	s6,s6,1318 # 8001f7a8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000328a:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000328c:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000328e:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003290:	6c89                	lui	s9,0x2
    80003292:	a831                	j	800032ae <balloc+0x54>
    brelse(bp);
    80003294:	854a                	mv	a0,s2
    80003296:	00000097          	auipc	ra,0x0
    8000329a:	e32080e7          	jalr	-462(ra) # 800030c8 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000329e:	015c87bb          	addw	a5,s9,s5
    800032a2:	00078a9b          	sext.w	s5,a5
    800032a6:	004b2703          	lw	a4,4(s6)
    800032aa:	06eaf163          	bgeu	s5,a4,8000330c <balloc+0xb2>
    bp = bread(dev, BBLOCK(b, sb));
    800032ae:	41fad79b          	sraiw	a5,s5,0x1f
    800032b2:	0137d79b          	srliw	a5,a5,0x13
    800032b6:	015787bb          	addw	a5,a5,s5
    800032ba:	40d7d79b          	sraiw	a5,a5,0xd
    800032be:	01cb2583          	lw	a1,28(s6)
    800032c2:	9dbd                	addw	a1,a1,a5
    800032c4:	855e                	mv	a0,s7
    800032c6:	00000097          	auipc	ra,0x0
    800032ca:	cd2080e7          	jalr	-814(ra) # 80002f98 <bread>
    800032ce:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032d0:	004b2503          	lw	a0,4(s6)
    800032d4:	000a849b          	sext.w	s1,s5
    800032d8:	8762                	mv	a4,s8
    800032da:	faa4fde3          	bgeu	s1,a0,80003294 <balloc+0x3a>
      m = 1 << (bi % 8);
    800032de:	00777693          	andi	a3,a4,7
    800032e2:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800032e6:	41f7579b          	sraiw	a5,a4,0x1f
    800032ea:	01d7d79b          	srliw	a5,a5,0x1d
    800032ee:	9fb9                	addw	a5,a5,a4
    800032f0:	4037d79b          	sraiw	a5,a5,0x3
    800032f4:	00f90633          	add	a2,s2,a5
    800032f8:	05864603          	lbu	a2,88(a2)
    800032fc:	00c6f5b3          	and	a1,a3,a2
    80003300:	cd91                	beqz	a1,8000331c <balloc+0xc2>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003302:	2705                	addiw	a4,a4,1
    80003304:	2485                	addiw	s1,s1,1
    80003306:	fd471ae3          	bne	a4,s4,800032da <balloc+0x80>
    8000330a:	b769                	j	80003294 <balloc+0x3a>
  panic("balloc: out of blocks");
    8000330c:	00005517          	auipc	a0,0x5
    80003310:	24450513          	addi	a0,a0,580 # 80008550 <syscalls+0x108>
    80003314:	ffffd097          	auipc	ra,0xffffd
    80003318:	226080e7          	jalr	550(ra) # 8000053a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000331c:	97ca                	add	a5,a5,s2
    8000331e:	8e55                	or	a2,a2,a3
    80003320:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003324:	854a                	mv	a0,s2
    80003326:	00001097          	auipc	ra,0x1
    8000332a:	026080e7          	jalr	38(ra) # 8000434c <log_write>
        brelse(bp);
    8000332e:	854a                	mv	a0,s2
    80003330:	00000097          	auipc	ra,0x0
    80003334:	d98080e7          	jalr	-616(ra) # 800030c8 <brelse>
  bp = bread(dev, bno);
    80003338:	85a6                	mv	a1,s1
    8000333a:	855e                	mv	a0,s7
    8000333c:	00000097          	auipc	ra,0x0
    80003340:	c5c080e7          	jalr	-932(ra) # 80002f98 <bread>
    80003344:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003346:	40000613          	li	a2,1024
    8000334a:	4581                	li	a1,0
    8000334c:	05850513          	addi	a0,a0,88
    80003350:	ffffe097          	auipc	ra,0xffffe
    80003354:	97c080e7          	jalr	-1668(ra) # 80000ccc <memset>
  log_write(bp);
    80003358:	854a                	mv	a0,s2
    8000335a:	00001097          	auipc	ra,0x1
    8000335e:	ff2080e7          	jalr	-14(ra) # 8000434c <log_write>
  brelse(bp);
    80003362:	854a                	mv	a0,s2
    80003364:	00000097          	auipc	ra,0x0
    80003368:	d64080e7          	jalr	-668(ra) # 800030c8 <brelse>
}
    8000336c:	8526                	mv	a0,s1
    8000336e:	60e6                	ld	ra,88(sp)
    80003370:	6446                	ld	s0,80(sp)
    80003372:	64a6                	ld	s1,72(sp)
    80003374:	6906                	ld	s2,64(sp)
    80003376:	79e2                	ld	s3,56(sp)
    80003378:	7a42                	ld	s4,48(sp)
    8000337a:	7aa2                	ld	s5,40(sp)
    8000337c:	7b02                	ld	s6,32(sp)
    8000337e:	6be2                	ld	s7,24(sp)
    80003380:	6c42                	ld	s8,16(sp)
    80003382:	6ca2                	ld	s9,8(sp)
    80003384:	6125                	addi	sp,sp,96
    80003386:	8082                	ret

0000000080003388 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003388:	7179                	addi	sp,sp,-48
    8000338a:	f406                	sd	ra,40(sp)
    8000338c:	f022                	sd	s0,32(sp)
    8000338e:	ec26                	sd	s1,24(sp)
    80003390:	e84a                	sd	s2,16(sp)
    80003392:	e44e                	sd	s3,8(sp)
    80003394:	e052                	sd	s4,0(sp)
    80003396:	1800                	addi	s0,sp,48
    80003398:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000339a:	47ad                	li	a5,11
    8000339c:	04b7fe63          	bgeu	a5,a1,800033f8 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800033a0:	ff45849b          	addiw	s1,a1,-12
    800033a4:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800033a8:	0ff00793          	li	a5,255
    800033ac:	0ae7e463          	bltu	a5,a4,80003454 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800033b0:	08052583          	lw	a1,128(a0)
    800033b4:	c5b5                	beqz	a1,80003420 <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800033b6:	00092503          	lw	a0,0(s2)
    800033ba:	00000097          	auipc	ra,0x0
    800033be:	bde080e7          	jalr	-1058(ra) # 80002f98 <bread>
    800033c2:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800033c4:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800033c8:	02049713          	slli	a4,s1,0x20
    800033cc:	01e75593          	srli	a1,a4,0x1e
    800033d0:	00b784b3          	add	s1,a5,a1
    800033d4:	0004a983          	lw	s3,0(s1)
    800033d8:	04098e63          	beqz	s3,80003434 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800033dc:	8552                	mv	a0,s4
    800033de:	00000097          	auipc	ra,0x0
    800033e2:	cea080e7          	jalr	-790(ra) # 800030c8 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800033e6:	854e                	mv	a0,s3
    800033e8:	70a2                	ld	ra,40(sp)
    800033ea:	7402                	ld	s0,32(sp)
    800033ec:	64e2                	ld	s1,24(sp)
    800033ee:	6942                	ld	s2,16(sp)
    800033f0:	69a2                	ld	s3,8(sp)
    800033f2:	6a02                	ld	s4,0(sp)
    800033f4:	6145                	addi	sp,sp,48
    800033f6:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800033f8:	02059793          	slli	a5,a1,0x20
    800033fc:	01e7d593          	srli	a1,a5,0x1e
    80003400:	00b504b3          	add	s1,a0,a1
    80003404:	0504a983          	lw	s3,80(s1)
    80003408:	fc099fe3          	bnez	s3,800033e6 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    8000340c:	4108                	lw	a0,0(a0)
    8000340e:	00000097          	auipc	ra,0x0
    80003412:	e4c080e7          	jalr	-436(ra) # 8000325a <balloc>
    80003416:	0005099b          	sext.w	s3,a0
    8000341a:	0534a823          	sw	s3,80(s1)
    8000341e:	b7e1                	j	800033e6 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003420:	4108                	lw	a0,0(a0)
    80003422:	00000097          	auipc	ra,0x0
    80003426:	e38080e7          	jalr	-456(ra) # 8000325a <balloc>
    8000342a:	0005059b          	sext.w	a1,a0
    8000342e:	08b92023          	sw	a1,128(s2)
    80003432:	b751                	j	800033b6 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003434:	00092503          	lw	a0,0(s2)
    80003438:	00000097          	auipc	ra,0x0
    8000343c:	e22080e7          	jalr	-478(ra) # 8000325a <balloc>
    80003440:	0005099b          	sext.w	s3,a0
    80003444:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003448:	8552                	mv	a0,s4
    8000344a:	00001097          	auipc	ra,0x1
    8000344e:	f02080e7          	jalr	-254(ra) # 8000434c <log_write>
    80003452:	b769                	j	800033dc <bmap+0x54>
  panic("bmap: out of range");
    80003454:	00005517          	auipc	a0,0x5
    80003458:	11450513          	addi	a0,a0,276 # 80008568 <syscalls+0x120>
    8000345c:	ffffd097          	auipc	ra,0xffffd
    80003460:	0de080e7          	jalr	222(ra) # 8000053a <panic>

0000000080003464 <iget>:
{
    80003464:	7179                	addi	sp,sp,-48
    80003466:	f406                	sd	ra,40(sp)
    80003468:	f022                	sd	s0,32(sp)
    8000346a:	ec26                	sd	s1,24(sp)
    8000346c:	e84a                	sd	s2,16(sp)
    8000346e:	e44e                	sd	s3,8(sp)
    80003470:	e052                	sd	s4,0(sp)
    80003472:	1800                	addi	s0,sp,48
    80003474:	89aa                	mv	s3,a0
    80003476:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003478:	0001c517          	auipc	a0,0x1c
    8000347c:	35050513          	addi	a0,a0,848 # 8001f7c8 <itable>
    80003480:	ffffd097          	auipc	ra,0xffffd
    80003484:	750080e7          	jalr	1872(ra) # 80000bd0 <acquire>
  empty = 0;
    80003488:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000348a:	0001c497          	auipc	s1,0x1c
    8000348e:	35648493          	addi	s1,s1,854 # 8001f7e0 <itable+0x18>
    80003492:	0001e697          	auipc	a3,0x1e
    80003496:	dde68693          	addi	a3,a3,-546 # 80021270 <log>
    8000349a:	a039                	j	800034a8 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000349c:	02090b63          	beqz	s2,800034d2 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800034a0:	08848493          	addi	s1,s1,136
    800034a4:	02d48a63          	beq	s1,a3,800034d8 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800034a8:	449c                	lw	a5,8(s1)
    800034aa:	fef059e3          	blez	a5,8000349c <iget+0x38>
    800034ae:	4098                	lw	a4,0(s1)
    800034b0:	ff3716e3          	bne	a4,s3,8000349c <iget+0x38>
    800034b4:	40d8                	lw	a4,4(s1)
    800034b6:	ff4713e3          	bne	a4,s4,8000349c <iget+0x38>
      ip->ref++;
    800034ba:	2785                	addiw	a5,a5,1
    800034bc:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800034be:	0001c517          	auipc	a0,0x1c
    800034c2:	30a50513          	addi	a0,a0,778 # 8001f7c8 <itable>
    800034c6:	ffffd097          	auipc	ra,0xffffd
    800034ca:	7be080e7          	jalr	1982(ra) # 80000c84 <release>
      return ip;
    800034ce:	8926                	mv	s2,s1
    800034d0:	a03d                	j	800034fe <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800034d2:	f7f9                	bnez	a5,800034a0 <iget+0x3c>
    800034d4:	8926                	mv	s2,s1
    800034d6:	b7e9                	j	800034a0 <iget+0x3c>
  if(empty == 0)
    800034d8:	02090c63          	beqz	s2,80003510 <iget+0xac>
  ip->dev = dev;
    800034dc:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800034e0:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800034e4:	4785                	li	a5,1
    800034e6:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800034ea:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800034ee:	0001c517          	auipc	a0,0x1c
    800034f2:	2da50513          	addi	a0,a0,730 # 8001f7c8 <itable>
    800034f6:	ffffd097          	auipc	ra,0xffffd
    800034fa:	78e080e7          	jalr	1934(ra) # 80000c84 <release>
}
    800034fe:	854a                	mv	a0,s2
    80003500:	70a2                	ld	ra,40(sp)
    80003502:	7402                	ld	s0,32(sp)
    80003504:	64e2                	ld	s1,24(sp)
    80003506:	6942                	ld	s2,16(sp)
    80003508:	69a2                	ld	s3,8(sp)
    8000350a:	6a02                	ld	s4,0(sp)
    8000350c:	6145                	addi	sp,sp,48
    8000350e:	8082                	ret
    panic("iget: no inodes");
    80003510:	00005517          	auipc	a0,0x5
    80003514:	07050513          	addi	a0,a0,112 # 80008580 <syscalls+0x138>
    80003518:	ffffd097          	auipc	ra,0xffffd
    8000351c:	022080e7          	jalr	34(ra) # 8000053a <panic>

0000000080003520 <fsinit>:
fsinit(int dev) {
    80003520:	7179                	addi	sp,sp,-48
    80003522:	f406                	sd	ra,40(sp)
    80003524:	f022                	sd	s0,32(sp)
    80003526:	ec26                	sd	s1,24(sp)
    80003528:	e84a                	sd	s2,16(sp)
    8000352a:	e44e                	sd	s3,8(sp)
    8000352c:	1800                	addi	s0,sp,48
    8000352e:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003530:	4585                	li	a1,1
    80003532:	00000097          	auipc	ra,0x0
    80003536:	a66080e7          	jalr	-1434(ra) # 80002f98 <bread>
    8000353a:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000353c:	0001c997          	auipc	s3,0x1c
    80003540:	26c98993          	addi	s3,s3,620 # 8001f7a8 <sb>
    80003544:	02000613          	li	a2,32
    80003548:	05850593          	addi	a1,a0,88
    8000354c:	854e                	mv	a0,s3
    8000354e:	ffffd097          	auipc	ra,0xffffd
    80003552:	7da080e7          	jalr	2010(ra) # 80000d28 <memmove>
  brelse(bp);
    80003556:	8526                	mv	a0,s1
    80003558:	00000097          	auipc	ra,0x0
    8000355c:	b70080e7          	jalr	-1168(ra) # 800030c8 <brelse>
  if(sb.magic != FSMAGIC)
    80003560:	0009a703          	lw	a4,0(s3)
    80003564:	102037b7          	lui	a5,0x10203
    80003568:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000356c:	02f71263          	bne	a4,a5,80003590 <fsinit+0x70>
  initlog(dev, &sb);
    80003570:	0001c597          	auipc	a1,0x1c
    80003574:	23858593          	addi	a1,a1,568 # 8001f7a8 <sb>
    80003578:	854a                	mv	a0,s2
    8000357a:	00001097          	auipc	ra,0x1
    8000357e:	b56080e7          	jalr	-1194(ra) # 800040d0 <initlog>
}
    80003582:	70a2                	ld	ra,40(sp)
    80003584:	7402                	ld	s0,32(sp)
    80003586:	64e2                	ld	s1,24(sp)
    80003588:	6942                	ld	s2,16(sp)
    8000358a:	69a2                	ld	s3,8(sp)
    8000358c:	6145                	addi	sp,sp,48
    8000358e:	8082                	ret
    panic("invalid file system");
    80003590:	00005517          	auipc	a0,0x5
    80003594:	00050513          	mv	a0,a0
    80003598:	ffffd097          	auipc	ra,0xffffd
    8000359c:	fa2080e7          	jalr	-94(ra) # 8000053a <panic>

00000000800035a0 <iinit>:
{
    800035a0:	7179                	addi	sp,sp,-48
    800035a2:	f406                	sd	ra,40(sp)
    800035a4:	f022                	sd	s0,32(sp)
    800035a6:	ec26                	sd	s1,24(sp)
    800035a8:	e84a                	sd	s2,16(sp)
    800035aa:	e44e                	sd	s3,8(sp)
    800035ac:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800035ae:	00005597          	auipc	a1,0x5
    800035b2:	ffa58593          	addi	a1,a1,-6 # 800085a8 <syscalls+0x160>
    800035b6:	0001c517          	auipc	a0,0x1c
    800035ba:	21250513          	addi	a0,a0,530 # 8001f7c8 <itable>
    800035be:	ffffd097          	auipc	ra,0xffffd
    800035c2:	582080e7          	jalr	1410(ra) # 80000b40 <initlock>
  for(i = 0; i < NINODE; i++) {
    800035c6:	0001c497          	auipc	s1,0x1c
    800035ca:	22a48493          	addi	s1,s1,554 # 8001f7f0 <itable+0x28>
    800035ce:	0001e997          	auipc	s3,0x1e
    800035d2:	cb298993          	addi	s3,s3,-846 # 80021280 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800035d6:	00005917          	auipc	s2,0x5
    800035da:	fda90913          	addi	s2,s2,-38 # 800085b0 <syscalls+0x168>
    800035de:	85ca                	mv	a1,s2
    800035e0:	8526                	mv	a0,s1
    800035e2:	00001097          	auipc	ra,0x1
    800035e6:	e4e080e7          	jalr	-434(ra) # 80004430 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800035ea:	08848493          	addi	s1,s1,136
    800035ee:	ff3498e3          	bne	s1,s3,800035de <iinit+0x3e>
}
    800035f2:	70a2                	ld	ra,40(sp)
    800035f4:	7402                	ld	s0,32(sp)
    800035f6:	64e2                	ld	s1,24(sp)
    800035f8:	6942                	ld	s2,16(sp)
    800035fa:	69a2                	ld	s3,8(sp)
    800035fc:	6145                	addi	sp,sp,48
    800035fe:	8082                	ret

0000000080003600 <ialloc>:
{
    80003600:	715d                	addi	sp,sp,-80
    80003602:	e486                	sd	ra,72(sp)
    80003604:	e0a2                	sd	s0,64(sp)
    80003606:	fc26                	sd	s1,56(sp)
    80003608:	f84a                	sd	s2,48(sp)
    8000360a:	f44e                	sd	s3,40(sp)
    8000360c:	f052                	sd	s4,32(sp)
    8000360e:	ec56                	sd	s5,24(sp)
    80003610:	e85a                	sd	s6,16(sp)
    80003612:	e45e                	sd	s7,8(sp)
    80003614:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003616:	0001c717          	auipc	a4,0x1c
    8000361a:	19e72703          	lw	a4,414(a4) # 8001f7b4 <sb+0xc>
    8000361e:	4785                	li	a5,1
    80003620:	04e7fa63          	bgeu	a5,a4,80003674 <ialloc+0x74>
    80003624:	8aaa                	mv	s5,a0
    80003626:	8bae                	mv	s7,a1
    80003628:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000362a:	0001ca17          	auipc	s4,0x1c
    8000362e:	17ea0a13          	addi	s4,s4,382 # 8001f7a8 <sb>
    80003632:	00048b1b          	sext.w	s6,s1
    80003636:	0044d593          	srli	a1,s1,0x4
    8000363a:	018a2783          	lw	a5,24(s4)
    8000363e:	9dbd                	addw	a1,a1,a5
    80003640:	8556                	mv	a0,s5
    80003642:	00000097          	auipc	ra,0x0
    80003646:	956080e7          	jalr	-1706(ra) # 80002f98 <bread>
    8000364a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000364c:	05850993          	addi	s3,a0,88
    80003650:	00f4f793          	andi	a5,s1,15
    80003654:	079a                	slli	a5,a5,0x6
    80003656:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003658:	00099783          	lh	a5,0(s3)
    8000365c:	c785                	beqz	a5,80003684 <ialloc+0x84>
    brelse(bp);
    8000365e:	00000097          	auipc	ra,0x0
    80003662:	a6a080e7          	jalr	-1430(ra) # 800030c8 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003666:	0485                	addi	s1,s1,1
    80003668:	00ca2703          	lw	a4,12(s4)
    8000366c:	0004879b          	sext.w	a5,s1
    80003670:	fce7e1e3          	bltu	a5,a4,80003632 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003674:	00005517          	auipc	a0,0x5
    80003678:	f4450513          	addi	a0,a0,-188 # 800085b8 <syscalls+0x170>
    8000367c:	ffffd097          	auipc	ra,0xffffd
    80003680:	ebe080e7          	jalr	-322(ra) # 8000053a <panic>
      memset(dip, 0, sizeof(*dip));
    80003684:	04000613          	li	a2,64
    80003688:	4581                	li	a1,0
    8000368a:	854e                	mv	a0,s3
    8000368c:	ffffd097          	auipc	ra,0xffffd
    80003690:	640080e7          	jalr	1600(ra) # 80000ccc <memset>
      dip->type = type;
    80003694:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003698:	854a                	mv	a0,s2
    8000369a:	00001097          	auipc	ra,0x1
    8000369e:	cb2080e7          	jalr	-846(ra) # 8000434c <log_write>
      brelse(bp);
    800036a2:	854a                	mv	a0,s2
    800036a4:	00000097          	auipc	ra,0x0
    800036a8:	a24080e7          	jalr	-1500(ra) # 800030c8 <brelse>
      return iget(dev, inum);
    800036ac:	85da                	mv	a1,s6
    800036ae:	8556                	mv	a0,s5
    800036b0:	00000097          	auipc	ra,0x0
    800036b4:	db4080e7          	jalr	-588(ra) # 80003464 <iget>
}
    800036b8:	60a6                	ld	ra,72(sp)
    800036ba:	6406                	ld	s0,64(sp)
    800036bc:	74e2                	ld	s1,56(sp)
    800036be:	7942                	ld	s2,48(sp)
    800036c0:	79a2                	ld	s3,40(sp)
    800036c2:	7a02                	ld	s4,32(sp)
    800036c4:	6ae2                	ld	s5,24(sp)
    800036c6:	6b42                	ld	s6,16(sp)
    800036c8:	6ba2                	ld	s7,8(sp)
    800036ca:	6161                	addi	sp,sp,80
    800036cc:	8082                	ret

00000000800036ce <iupdate>:
{
    800036ce:	1101                	addi	sp,sp,-32
    800036d0:	ec06                	sd	ra,24(sp)
    800036d2:	e822                	sd	s0,16(sp)
    800036d4:	e426                	sd	s1,8(sp)
    800036d6:	e04a                	sd	s2,0(sp)
    800036d8:	1000                	addi	s0,sp,32
    800036da:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800036dc:	415c                	lw	a5,4(a0)
    800036de:	0047d79b          	srliw	a5,a5,0x4
    800036e2:	0001c597          	auipc	a1,0x1c
    800036e6:	0de5a583          	lw	a1,222(a1) # 8001f7c0 <sb+0x18>
    800036ea:	9dbd                	addw	a1,a1,a5
    800036ec:	4108                	lw	a0,0(a0)
    800036ee:	00000097          	auipc	ra,0x0
    800036f2:	8aa080e7          	jalr	-1878(ra) # 80002f98 <bread>
    800036f6:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036f8:	05850793          	addi	a5,a0,88
    800036fc:	40d8                	lw	a4,4(s1)
    800036fe:	8b3d                	andi	a4,a4,15
    80003700:	071a                	slli	a4,a4,0x6
    80003702:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003704:	04449703          	lh	a4,68(s1)
    80003708:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000370c:	04649703          	lh	a4,70(s1)
    80003710:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003714:	04849703          	lh	a4,72(s1)
    80003718:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000371c:	04a49703          	lh	a4,74(s1)
    80003720:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003724:	44f8                	lw	a4,76(s1)
    80003726:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003728:	03400613          	li	a2,52
    8000372c:	05048593          	addi	a1,s1,80
    80003730:	00c78513          	addi	a0,a5,12
    80003734:	ffffd097          	auipc	ra,0xffffd
    80003738:	5f4080e7          	jalr	1524(ra) # 80000d28 <memmove>
  log_write(bp);
    8000373c:	854a                	mv	a0,s2
    8000373e:	00001097          	auipc	ra,0x1
    80003742:	c0e080e7          	jalr	-1010(ra) # 8000434c <log_write>
  brelse(bp);
    80003746:	854a                	mv	a0,s2
    80003748:	00000097          	auipc	ra,0x0
    8000374c:	980080e7          	jalr	-1664(ra) # 800030c8 <brelse>
}
    80003750:	60e2                	ld	ra,24(sp)
    80003752:	6442                	ld	s0,16(sp)
    80003754:	64a2                	ld	s1,8(sp)
    80003756:	6902                	ld	s2,0(sp)
    80003758:	6105                	addi	sp,sp,32
    8000375a:	8082                	ret

000000008000375c <idup>:
{
    8000375c:	1101                	addi	sp,sp,-32
    8000375e:	ec06                	sd	ra,24(sp)
    80003760:	e822                	sd	s0,16(sp)
    80003762:	e426                	sd	s1,8(sp)
    80003764:	1000                	addi	s0,sp,32
    80003766:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003768:	0001c517          	auipc	a0,0x1c
    8000376c:	06050513          	addi	a0,a0,96 # 8001f7c8 <itable>
    80003770:	ffffd097          	auipc	ra,0xffffd
    80003774:	460080e7          	jalr	1120(ra) # 80000bd0 <acquire>
  ip->ref++;
    80003778:	449c                	lw	a5,8(s1)
    8000377a:	2785                	addiw	a5,a5,1
    8000377c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000377e:	0001c517          	auipc	a0,0x1c
    80003782:	04a50513          	addi	a0,a0,74 # 8001f7c8 <itable>
    80003786:	ffffd097          	auipc	ra,0xffffd
    8000378a:	4fe080e7          	jalr	1278(ra) # 80000c84 <release>
}
    8000378e:	8526                	mv	a0,s1
    80003790:	60e2                	ld	ra,24(sp)
    80003792:	6442                	ld	s0,16(sp)
    80003794:	64a2                	ld	s1,8(sp)
    80003796:	6105                	addi	sp,sp,32
    80003798:	8082                	ret

000000008000379a <ilock>:
{
    8000379a:	1101                	addi	sp,sp,-32
    8000379c:	ec06                	sd	ra,24(sp)
    8000379e:	e822                	sd	s0,16(sp)
    800037a0:	e426                	sd	s1,8(sp)
    800037a2:	e04a                	sd	s2,0(sp)
    800037a4:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800037a6:	c115                	beqz	a0,800037ca <ilock+0x30>
    800037a8:	84aa                	mv	s1,a0
    800037aa:	451c                	lw	a5,8(a0)
    800037ac:	00f05f63          	blez	a5,800037ca <ilock+0x30>
  acquiresleep(&ip->lock);
    800037b0:	0541                	addi	a0,a0,16
    800037b2:	00001097          	auipc	ra,0x1
    800037b6:	cb8080e7          	jalr	-840(ra) # 8000446a <acquiresleep>
  if(ip->valid == 0){
    800037ba:	40bc                	lw	a5,64(s1)
    800037bc:	cf99                	beqz	a5,800037da <ilock+0x40>
}
    800037be:	60e2                	ld	ra,24(sp)
    800037c0:	6442                	ld	s0,16(sp)
    800037c2:	64a2                	ld	s1,8(sp)
    800037c4:	6902                	ld	s2,0(sp)
    800037c6:	6105                	addi	sp,sp,32
    800037c8:	8082                	ret
    panic("ilock");
    800037ca:	00005517          	auipc	a0,0x5
    800037ce:	e0650513          	addi	a0,a0,-506 # 800085d0 <syscalls+0x188>
    800037d2:	ffffd097          	auipc	ra,0xffffd
    800037d6:	d68080e7          	jalr	-664(ra) # 8000053a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037da:	40dc                	lw	a5,4(s1)
    800037dc:	0047d79b          	srliw	a5,a5,0x4
    800037e0:	0001c597          	auipc	a1,0x1c
    800037e4:	fe05a583          	lw	a1,-32(a1) # 8001f7c0 <sb+0x18>
    800037e8:	9dbd                	addw	a1,a1,a5
    800037ea:	4088                	lw	a0,0(s1)
    800037ec:	fffff097          	auipc	ra,0xfffff
    800037f0:	7ac080e7          	jalr	1964(ra) # 80002f98 <bread>
    800037f4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037f6:	05850593          	addi	a1,a0,88
    800037fa:	40dc                	lw	a5,4(s1)
    800037fc:	8bbd                	andi	a5,a5,15
    800037fe:	079a                	slli	a5,a5,0x6
    80003800:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003802:	00059783          	lh	a5,0(a1)
    80003806:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000380a:	00259783          	lh	a5,2(a1)
    8000380e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003812:	00459783          	lh	a5,4(a1)
    80003816:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000381a:	00659783          	lh	a5,6(a1)
    8000381e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003822:	459c                	lw	a5,8(a1)
    80003824:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003826:	03400613          	li	a2,52
    8000382a:	05b1                	addi	a1,a1,12
    8000382c:	05048513          	addi	a0,s1,80
    80003830:	ffffd097          	auipc	ra,0xffffd
    80003834:	4f8080e7          	jalr	1272(ra) # 80000d28 <memmove>
    brelse(bp);
    80003838:	854a                	mv	a0,s2
    8000383a:	00000097          	auipc	ra,0x0
    8000383e:	88e080e7          	jalr	-1906(ra) # 800030c8 <brelse>
    ip->valid = 1;
    80003842:	4785                	li	a5,1
    80003844:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003846:	04449783          	lh	a5,68(s1)
    8000384a:	fbb5                	bnez	a5,800037be <ilock+0x24>
      panic("ilock: no type");
    8000384c:	00005517          	auipc	a0,0x5
    80003850:	d8c50513          	addi	a0,a0,-628 # 800085d8 <syscalls+0x190>
    80003854:	ffffd097          	auipc	ra,0xffffd
    80003858:	ce6080e7          	jalr	-794(ra) # 8000053a <panic>

000000008000385c <iunlock>:
{
    8000385c:	1101                	addi	sp,sp,-32
    8000385e:	ec06                	sd	ra,24(sp)
    80003860:	e822                	sd	s0,16(sp)
    80003862:	e426                	sd	s1,8(sp)
    80003864:	e04a                	sd	s2,0(sp)
    80003866:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003868:	c905                	beqz	a0,80003898 <iunlock+0x3c>
    8000386a:	84aa                	mv	s1,a0
    8000386c:	01050913          	addi	s2,a0,16
    80003870:	854a                	mv	a0,s2
    80003872:	00001097          	auipc	ra,0x1
    80003876:	c92080e7          	jalr	-878(ra) # 80004504 <holdingsleep>
    8000387a:	cd19                	beqz	a0,80003898 <iunlock+0x3c>
    8000387c:	449c                	lw	a5,8(s1)
    8000387e:	00f05d63          	blez	a5,80003898 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003882:	854a                	mv	a0,s2
    80003884:	00001097          	auipc	ra,0x1
    80003888:	c3c080e7          	jalr	-964(ra) # 800044c0 <releasesleep>
}
    8000388c:	60e2                	ld	ra,24(sp)
    8000388e:	6442                	ld	s0,16(sp)
    80003890:	64a2                	ld	s1,8(sp)
    80003892:	6902                	ld	s2,0(sp)
    80003894:	6105                	addi	sp,sp,32
    80003896:	8082                	ret
    panic("iunlock");
    80003898:	00005517          	auipc	a0,0x5
    8000389c:	d5050513          	addi	a0,a0,-688 # 800085e8 <syscalls+0x1a0>
    800038a0:	ffffd097          	auipc	ra,0xffffd
    800038a4:	c9a080e7          	jalr	-870(ra) # 8000053a <panic>

00000000800038a8 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800038a8:	7179                	addi	sp,sp,-48
    800038aa:	f406                	sd	ra,40(sp)
    800038ac:	f022                	sd	s0,32(sp)
    800038ae:	ec26                	sd	s1,24(sp)
    800038b0:	e84a                	sd	s2,16(sp)
    800038b2:	e44e                	sd	s3,8(sp)
    800038b4:	e052                	sd	s4,0(sp)
    800038b6:	1800                	addi	s0,sp,48
    800038b8:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800038ba:	05050493          	addi	s1,a0,80
    800038be:	08050913          	addi	s2,a0,128
    800038c2:	a021                	j	800038ca <itrunc+0x22>
    800038c4:	0491                	addi	s1,s1,4
    800038c6:	01248d63          	beq	s1,s2,800038e0 <itrunc+0x38>
    if(ip->addrs[i]){
    800038ca:	408c                	lw	a1,0(s1)
    800038cc:	dde5                	beqz	a1,800038c4 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800038ce:	0009a503          	lw	a0,0(s3)
    800038d2:	00000097          	auipc	ra,0x0
    800038d6:	90c080e7          	jalr	-1780(ra) # 800031de <bfree>
      ip->addrs[i] = 0;
    800038da:	0004a023          	sw	zero,0(s1)
    800038de:	b7dd                	j	800038c4 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800038e0:	0809a583          	lw	a1,128(s3)
    800038e4:	e185                	bnez	a1,80003904 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800038e6:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800038ea:	854e                	mv	a0,s3
    800038ec:	00000097          	auipc	ra,0x0
    800038f0:	de2080e7          	jalr	-542(ra) # 800036ce <iupdate>
}
    800038f4:	70a2                	ld	ra,40(sp)
    800038f6:	7402                	ld	s0,32(sp)
    800038f8:	64e2                	ld	s1,24(sp)
    800038fa:	6942                	ld	s2,16(sp)
    800038fc:	69a2                	ld	s3,8(sp)
    800038fe:	6a02                	ld	s4,0(sp)
    80003900:	6145                	addi	sp,sp,48
    80003902:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003904:	0009a503          	lw	a0,0(s3)
    80003908:	fffff097          	auipc	ra,0xfffff
    8000390c:	690080e7          	jalr	1680(ra) # 80002f98 <bread>
    80003910:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003912:	05850493          	addi	s1,a0,88
    80003916:	45850913          	addi	s2,a0,1112
    8000391a:	a021                	j	80003922 <itrunc+0x7a>
    8000391c:	0491                	addi	s1,s1,4
    8000391e:	01248b63          	beq	s1,s2,80003934 <itrunc+0x8c>
      if(a[j])
    80003922:	408c                	lw	a1,0(s1)
    80003924:	dde5                	beqz	a1,8000391c <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003926:	0009a503          	lw	a0,0(s3)
    8000392a:	00000097          	auipc	ra,0x0
    8000392e:	8b4080e7          	jalr	-1868(ra) # 800031de <bfree>
    80003932:	b7ed                	j	8000391c <itrunc+0x74>
    brelse(bp);
    80003934:	8552                	mv	a0,s4
    80003936:	fffff097          	auipc	ra,0xfffff
    8000393a:	792080e7          	jalr	1938(ra) # 800030c8 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000393e:	0809a583          	lw	a1,128(s3)
    80003942:	0009a503          	lw	a0,0(s3)
    80003946:	00000097          	auipc	ra,0x0
    8000394a:	898080e7          	jalr	-1896(ra) # 800031de <bfree>
    ip->addrs[NDIRECT] = 0;
    8000394e:	0809a023          	sw	zero,128(s3)
    80003952:	bf51                	j	800038e6 <itrunc+0x3e>

0000000080003954 <iput>:
{
    80003954:	1101                	addi	sp,sp,-32
    80003956:	ec06                	sd	ra,24(sp)
    80003958:	e822                	sd	s0,16(sp)
    8000395a:	e426                	sd	s1,8(sp)
    8000395c:	e04a                	sd	s2,0(sp)
    8000395e:	1000                	addi	s0,sp,32
    80003960:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003962:	0001c517          	auipc	a0,0x1c
    80003966:	e6650513          	addi	a0,a0,-410 # 8001f7c8 <itable>
    8000396a:	ffffd097          	auipc	ra,0xffffd
    8000396e:	266080e7          	jalr	614(ra) # 80000bd0 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003972:	4498                	lw	a4,8(s1)
    80003974:	4785                	li	a5,1
    80003976:	02f70363          	beq	a4,a5,8000399c <iput+0x48>
  ip->ref--;
    8000397a:	449c                	lw	a5,8(s1)
    8000397c:	37fd                	addiw	a5,a5,-1
    8000397e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003980:	0001c517          	auipc	a0,0x1c
    80003984:	e4850513          	addi	a0,a0,-440 # 8001f7c8 <itable>
    80003988:	ffffd097          	auipc	ra,0xffffd
    8000398c:	2fc080e7          	jalr	764(ra) # 80000c84 <release>
}
    80003990:	60e2                	ld	ra,24(sp)
    80003992:	6442                	ld	s0,16(sp)
    80003994:	64a2                	ld	s1,8(sp)
    80003996:	6902                	ld	s2,0(sp)
    80003998:	6105                	addi	sp,sp,32
    8000399a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000399c:	40bc                	lw	a5,64(s1)
    8000399e:	dff1                	beqz	a5,8000397a <iput+0x26>
    800039a0:	04a49783          	lh	a5,74(s1)
    800039a4:	fbf9                	bnez	a5,8000397a <iput+0x26>
    acquiresleep(&ip->lock);
    800039a6:	01048913          	addi	s2,s1,16
    800039aa:	854a                	mv	a0,s2
    800039ac:	00001097          	auipc	ra,0x1
    800039b0:	abe080e7          	jalr	-1346(ra) # 8000446a <acquiresleep>
    release(&itable.lock);
    800039b4:	0001c517          	auipc	a0,0x1c
    800039b8:	e1450513          	addi	a0,a0,-492 # 8001f7c8 <itable>
    800039bc:	ffffd097          	auipc	ra,0xffffd
    800039c0:	2c8080e7          	jalr	712(ra) # 80000c84 <release>
    itrunc(ip);
    800039c4:	8526                	mv	a0,s1
    800039c6:	00000097          	auipc	ra,0x0
    800039ca:	ee2080e7          	jalr	-286(ra) # 800038a8 <itrunc>
    ip->type = 0;
    800039ce:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800039d2:	8526                	mv	a0,s1
    800039d4:	00000097          	auipc	ra,0x0
    800039d8:	cfa080e7          	jalr	-774(ra) # 800036ce <iupdate>
    ip->valid = 0;
    800039dc:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800039e0:	854a                	mv	a0,s2
    800039e2:	00001097          	auipc	ra,0x1
    800039e6:	ade080e7          	jalr	-1314(ra) # 800044c0 <releasesleep>
    acquire(&itable.lock);
    800039ea:	0001c517          	auipc	a0,0x1c
    800039ee:	dde50513          	addi	a0,a0,-546 # 8001f7c8 <itable>
    800039f2:	ffffd097          	auipc	ra,0xffffd
    800039f6:	1de080e7          	jalr	478(ra) # 80000bd0 <acquire>
    800039fa:	b741                	j	8000397a <iput+0x26>

00000000800039fc <iunlockput>:
{
    800039fc:	1101                	addi	sp,sp,-32
    800039fe:	ec06                	sd	ra,24(sp)
    80003a00:	e822                	sd	s0,16(sp)
    80003a02:	e426                	sd	s1,8(sp)
    80003a04:	1000                	addi	s0,sp,32
    80003a06:	84aa                	mv	s1,a0
  iunlock(ip);
    80003a08:	00000097          	auipc	ra,0x0
    80003a0c:	e54080e7          	jalr	-428(ra) # 8000385c <iunlock>
  iput(ip);
    80003a10:	8526                	mv	a0,s1
    80003a12:	00000097          	auipc	ra,0x0
    80003a16:	f42080e7          	jalr	-190(ra) # 80003954 <iput>
}
    80003a1a:	60e2                	ld	ra,24(sp)
    80003a1c:	6442                	ld	s0,16(sp)
    80003a1e:	64a2                	ld	s1,8(sp)
    80003a20:	6105                	addi	sp,sp,32
    80003a22:	8082                	ret

0000000080003a24 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003a24:	1141                	addi	sp,sp,-16
    80003a26:	e422                	sd	s0,8(sp)
    80003a28:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003a2a:	411c                	lw	a5,0(a0)
    80003a2c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003a2e:	415c                	lw	a5,4(a0)
    80003a30:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003a32:	04451783          	lh	a5,68(a0)
    80003a36:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003a3a:	04a51783          	lh	a5,74(a0)
    80003a3e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003a42:	04c56783          	lwu	a5,76(a0)
    80003a46:	e99c                	sd	a5,16(a1)
}
    80003a48:	6422                	ld	s0,8(sp)
    80003a4a:	0141                	addi	sp,sp,16
    80003a4c:	8082                	ret

0000000080003a4e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a4e:	457c                	lw	a5,76(a0)
    80003a50:	0ed7e963          	bltu	a5,a3,80003b42 <readi+0xf4>
{
    80003a54:	7159                	addi	sp,sp,-112
    80003a56:	f486                	sd	ra,104(sp)
    80003a58:	f0a2                	sd	s0,96(sp)
    80003a5a:	eca6                	sd	s1,88(sp)
    80003a5c:	e8ca                	sd	s2,80(sp)
    80003a5e:	e4ce                	sd	s3,72(sp)
    80003a60:	e0d2                	sd	s4,64(sp)
    80003a62:	fc56                	sd	s5,56(sp)
    80003a64:	f85a                	sd	s6,48(sp)
    80003a66:	f45e                	sd	s7,40(sp)
    80003a68:	f062                	sd	s8,32(sp)
    80003a6a:	ec66                	sd	s9,24(sp)
    80003a6c:	e86a                	sd	s10,16(sp)
    80003a6e:	e46e                	sd	s11,8(sp)
    80003a70:	1880                	addi	s0,sp,112
    80003a72:	8baa                	mv	s7,a0
    80003a74:	8c2e                	mv	s8,a1
    80003a76:	8ab2                	mv	s5,a2
    80003a78:	84b6                	mv	s1,a3
    80003a7a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003a7c:	9f35                	addw	a4,a4,a3
    return 0;
    80003a7e:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003a80:	0ad76063          	bltu	a4,a3,80003b20 <readi+0xd2>
  if(off + n > ip->size)
    80003a84:	00e7f463          	bgeu	a5,a4,80003a8c <readi+0x3e>
    n = ip->size - off;
    80003a88:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a8c:	0a0b0963          	beqz	s6,80003b3e <readi+0xf0>
    80003a90:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a92:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003a96:	5cfd                	li	s9,-1
    80003a98:	a82d                	j	80003ad2 <readi+0x84>
    80003a9a:	020a1d93          	slli	s11,s4,0x20
    80003a9e:	020ddd93          	srli	s11,s11,0x20
    80003aa2:	05890613          	addi	a2,s2,88
    80003aa6:	86ee                	mv	a3,s11
    80003aa8:	963a                	add	a2,a2,a4
    80003aaa:	85d6                	mv	a1,s5
    80003aac:	8562                	mv	a0,s8
    80003aae:	fffff097          	auipc	ra,0xfffff
    80003ab2:	954080e7          	jalr	-1708(ra) # 80002402 <either_copyout>
    80003ab6:	05950d63          	beq	a0,s9,80003b10 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003aba:	854a                	mv	a0,s2
    80003abc:	fffff097          	auipc	ra,0xfffff
    80003ac0:	60c080e7          	jalr	1548(ra) # 800030c8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ac4:	013a09bb          	addw	s3,s4,s3
    80003ac8:	009a04bb          	addw	s1,s4,s1
    80003acc:	9aee                	add	s5,s5,s11
    80003ace:	0569f763          	bgeu	s3,s6,80003b1c <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003ad2:	000ba903          	lw	s2,0(s7)
    80003ad6:	00a4d59b          	srliw	a1,s1,0xa
    80003ada:	855e                	mv	a0,s7
    80003adc:	00000097          	auipc	ra,0x0
    80003ae0:	8ac080e7          	jalr	-1876(ra) # 80003388 <bmap>
    80003ae4:	0005059b          	sext.w	a1,a0
    80003ae8:	854a                	mv	a0,s2
    80003aea:	fffff097          	auipc	ra,0xfffff
    80003aee:	4ae080e7          	jalr	1198(ra) # 80002f98 <bread>
    80003af2:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003af4:	3ff4f713          	andi	a4,s1,1023
    80003af8:	40ed07bb          	subw	a5,s10,a4
    80003afc:	413b06bb          	subw	a3,s6,s3
    80003b00:	8a3e                	mv	s4,a5
    80003b02:	2781                	sext.w	a5,a5
    80003b04:	0006861b          	sext.w	a2,a3
    80003b08:	f8f679e3          	bgeu	a2,a5,80003a9a <readi+0x4c>
    80003b0c:	8a36                	mv	s4,a3
    80003b0e:	b771                	j	80003a9a <readi+0x4c>
      brelse(bp);
    80003b10:	854a                	mv	a0,s2
    80003b12:	fffff097          	auipc	ra,0xfffff
    80003b16:	5b6080e7          	jalr	1462(ra) # 800030c8 <brelse>
      tot = -1;
    80003b1a:	59fd                	li	s3,-1
  }
  return tot;
    80003b1c:	0009851b          	sext.w	a0,s3
}
    80003b20:	70a6                	ld	ra,104(sp)
    80003b22:	7406                	ld	s0,96(sp)
    80003b24:	64e6                	ld	s1,88(sp)
    80003b26:	6946                	ld	s2,80(sp)
    80003b28:	69a6                	ld	s3,72(sp)
    80003b2a:	6a06                	ld	s4,64(sp)
    80003b2c:	7ae2                	ld	s5,56(sp)
    80003b2e:	7b42                	ld	s6,48(sp)
    80003b30:	7ba2                	ld	s7,40(sp)
    80003b32:	7c02                	ld	s8,32(sp)
    80003b34:	6ce2                	ld	s9,24(sp)
    80003b36:	6d42                	ld	s10,16(sp)
    80003b38:	6da2                	ld	s11,8(sp)
    80003b3a:	6165                	addi	sp,sp,112
    80003b3c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b3e:	89da                	mv	s3,s6
    80003b40:	bff1                	j	80003b1c <readi+0xce>
    return 0;
    80003b42:	4501                	li	a0,0
}
    80003b44:	8082                	ret

0000000080003b46 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b46:	457c                	lw	a5,76(a0)
    80003b48:	10d7e863          	bltu	a5,a3,80003c58 <writei+0x112>
{
    80003b4c:	7159                	addi	sp,sp,-112
    80003b4e:	f486                	sd	ra,104(sp)
    80003b50:	f0a2                	sd	s0,96(sp)
    80003b52:	eca6                	sd	s1,88(sp)
    80003b54:	e8ca                	sd	s2,80(sp)
    80003b56:	e4ce                	sd	s3,72(sp)
    80003b58:	e0d2                	sd	s4,64(sp)
    80003b5a:	fc56                	sd	s5,56(sp)
    80003b5c:	f85a                	sd	s6,48(sp)
    80003b5e:	f45e                	sd	s7,40(sp)
    80003b60:	f062                	sd	s8,32(sp)
    80003b62:	ec66                	sd	s9,24(sp)
    80003b64:	e86a                	sd	s10,16(sp)
    80003b66:	e46e                	sd	s11,8(sp)
    80003b68:	1880                	addi	s0,sp,112
    80003b6a:	8b2a                	mv	s6,a0
    80003b6c:	8c2e                	mv	s8,a1
    80003b6e:	8ab2                	mv	s5,a2
    80003b70:	8936                	mv	s2,a3
    80003b72:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003b74:	00e687bb          	addw	a5,a3,a4
    80003b78:	0ed7e263          	bltu	a5,a3,80003c5c <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003b7c:	00043737          	lui	a4,0x43
    80003b80:	0ef76063          	bltu	a4,a5,80003c60 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b84:	0c0b8863          	beqz	s7,80003c54 <writei+0x10e>
    80003b88:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b8a:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003b8e:	5cfd                	li	s9,-1
    80003b90:	a091                	j	80003bd4 <writei+0x8e>
    80003b92:	02099d93          	slli	s11,s3,0x20
    80003b96:	020ddd93          	srli	s11,s11,0x20
    80003b9a:	05848513          	addi	a0,s1,88
    80003b9e:	86ee                	mv	a3,s11
    80003ba0:	8656                	mv	a2,s5
    80003ba2:	85e2                	mv	a1,s8
    80003ba4:	953a                	add	a0,a0,a4
    80003ba6:	fffff097          	auipc	ra,0xfffff
    80003baa:	8b2080e7          	jalr	-1870(ra) # 80002458 <either_copyin>
    80003bae:	07950263          	beq	a0,s9,80003c12 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003bb2:	8526                	mv	a0,s1
    80003bb4:	00000097          	auipc	ra,0x0
    80003bb8:	798080e7          	jalr	1944(ra) # 8000434c <log_write>
    brelse(bp);
    80003bbc:	8526                	mv	a0,s1
    80003bbe:	fffff097          	auipc	ra,0xfffff
    80003bc2:	50a080e7          	jalr	1290(ra) # 800030c8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003bc6:	01498a3b          	addw	s4,s3,s4
    80003bca:	0129893b          	addw	s2,s3,s2
    80003bce:	9aee                	add	s5,s5,s11
    80003bd0:	057a7663          	bgeu	s4,s7,80003c1c <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003bd4:	000b2483          	lw	s1,0(s6)
    80003bd8:	00a9559b          	srliw	a1,s2,0xa
    80003bdc:	855a                	mv	a0,s6
    80003bde:	fffff097          	auipc	ra,0xfffff
    80003be2:	7aa080e7          	jalr	1962(ra) # 80003388 <bmap>
    80003be6:	0005059b          	sext.w	a1,a0
    80003bea:	8526                	mv	a0,s1
    80003bec:	fffff097          	auipc	ra,0xfffff
    80003bf0:	3ac080e7          	jalr	940(ra) # 80002f98 <bread>
    80003bf4:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bf6:	3ff97713          	andi	a4,s2,1023
    80003bfa:	40ed07bb          	subw	a5,s10,a4
    80003bfe:	414b86bb          	subw	a3,s7,s4
    80003c02:	89be                	mv	s3,a5
    80003c04:	2781                	sext.w	a5,a5
    80003c06:	0006861b          	sext.w	a2,a3
    80003c0a:	f8f674e3          	bgeu	a2,a5,80003b92 <writei+0x4c>
    80003c0e:	89b6                	mv	s3,a3
    80003c10:	b749                	j	80003b92 <writei+0x4c>
      brelse(bp);
    80003c12:	8526                	mv	a0,s1
    80003c14:	fffff097          	auipc	ra,0xfffff
    80003c18:	4b4080e7          	jalr	1204(ra) # 800030c8 <brelse>
  }

  if(off > ip->size)
    80003c1c:	04cb2783          	lw	a5,76(s6)
    80003c20:	0127f463          	bgeu	a5,s2,80003c28 <writei+0xe2>
    ip->size = off;
    80003c24:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003c28:	855a                	mv	a0,s6
    80003c2a:	00000097          	auipc	ra,0x0
    80003c2e:	aa4080e7          	jalr	-1372(ra) # 800036ce <iupdate>

  return tot;
    80003c32:	000a051b          	sext.w	a0,s4
}
    80003c36:	70a6                	ld	ra,104(sp)
    80003c38:	7406                	ld	s0,96(sp)
    80003c3a:	64e6                	ld	s1,88(sp)
    80003c3c:	6946                	ld	s2,80(sp)
    80003c3e:	69a6                	ld	s3,72(sp)
    80003c40:	6a06                	ld	s4,64(sp)
    80003c42:	7ae2                	ld	s5,56(sp)
    80003c44:	7b42                	ld	s6,48(sp)
    80003c46:	7ba2                	ld	s7,40(sp)
    80003c48:	7c02                	ld	s8,32(sp)
    80003c4a:	6ce2                	ld	s9,24(sp)
    80003c4c:	6d42                	ld	s10,16(sp)
    80003c4e:	6da2                	ld	s11,8(sp)
    80003c50:	6165                	addi	sp,sp,112
    80003c52:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c54:	8a5e                	mv	s4,s7
    80003c56:	bfc9                	j	80003c28 <writei+0xe2>
    return -1;
    80003c58:	557d                	li	a0,-1
}
    80003c5a:	8082                	ret
    return -1;
    80003c5c:	557d                	li	a0,-1
    80003c5e:	bfe1                	j	80003c36 <writei+0xf0>
    return -1;
    80003c60:	557d                	li	a0,-1
    80003c62:	bfd1                	j	80003c36 <writei+0xf0>

0000000080003c64 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003c64:	1141                	addi	sp,sp,-16
    80003c66:	e406                	sd	ra,8(sp)
    80003c68:	e022                	sd	s0,0(sp)
    80003c6a:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003c6c:	4639                	li	a2,14
    80003c6e:	ffffd097          	auipc	ra,0xffffd
    80003c72:	12e080e7          	jalr	302(ra) # 80000d9c <strncmp>
}
    80003c76:	60a2                	ld	ra,8(sp)
    80003c78:	6402                	ld	s0,0(sp)
    80003c7a:	0141                	addi	sp,sp,16
    80003c7c:	8082                	ret

0000000080003c7e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003c7e:	7139                	addi	sp,sp,-64
    80003c80:	fc06                	sd	ra,56(sp)
    80003c82:	f822                	sd	s0,48(sp)
    80003c84:	f426                	sd	s1,40(sp)
    80003c86:	f04a                	sd	s2,32(sp)
    80003c88:	ec4e                	sd	s3,24(sp)
    80003c8a:	e852                	sd	s4,16(sp)
    80003c8c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003c8e:	04451703          	lh	a4,68(a0)
    80003c92:	4785                	li	a5,1
    80003c94:	00f71a63          	bne	a4,a5,80003ca8 <dirlookup+0x2a>
    80003c98:	892a                	mv	s2,a0
    80003c9a:	89ae                	mv	s3,a1
    80003c9c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c9e:	457c                	lw	a5,76(a0)
    80003ca0:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003ca2:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ca4:	e79d                	bnez	a5,80003cd2 <dirlookup+0x54>
    80003ca6:	a8a5                	j	80003d1e <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003ca8:	00005517          	auipc	a0,0x5
    80003cac:	94850513          	addi	a0,a0,-1720 # 800085f0 <syscalls+0x1a8>
    80003cb0:	ffffd097          	auipc	ra,0xffffd
    80003cb4:	88a080e7          	jalr	-1910(ra) # 8000053a <panic>
      panic("dirlookup read");
    80003cb8:	00005517          	auipc	a0,0x5
    80003cbc:	95050513          	addi	a0,a0,-1712 # 80008608 <syscalls+0x1c0>
    80003cc0:	ffffd097          	auipc	ra,0xffffd
    80003cc4:	87a080e7          	jalr	-1926(ra) # 8000053a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003cc8:	24c1                	addiw	s1,s1,16
    80003cca:	04c92783          	lw	a5,76(s2)
    80003cce:	04f4f763          	bgeu	s1,a5,80003d1c <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003cd2:	4741                	li	a4,16
    80003cd4:	86a6                	mv	a3,s1
    80003cd6:	fc040613          	addi	a2,s0,-64
    80003cda:	4581                	li	a1,0
    80003cdc:	854a                	mv	a0,s2
    80003cde:	00000097          	auipc	ra,0x0
    80003ce2:	d70080e7          	jalr	-656(ra) # 80003a4e <readi>
    80003ce6:	47c1                	li	a5,16
    80003ce8:	fcf518e3          	bne	a0,a5,80003cb8 <dirlookup+0x3a>
    if(de.inum == 0)
    80003cec:	fc045783          	lhu	a5,-64(s0)
    80003cf0:	dfe1                	beqz	a5,80003cc8 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003cf2:	fc240593          	addi	a1,s0,-62
    80003cf6:	854e                	mv	a0,s3
    80003cf8:	00000097          	auipc	ra,0x0
    80003cfc:	f6c080e7          	jalr	-148(ra) # 80003c64 <namecmp>
    80003d00:	f561                	bnez	a0,80003cc8 <dirlookup+0x4a>
      if(poff)
    80003d02:	000a0463          	beqz	s4,80003d0a <dirlookup+0x8c>
        *poff = off;
    80003d06:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003d0a:	fc045583          	lhu	a1,-64(s0)
    80003d0e:	00092503          	lw	a0,0(s2)
    80003d12:	fffff097          	auipc	ra,0xfffff
    80003d16:	752080e7          	jalr	1874(ra) # 80003464 <iget>
    80003d1a:	a011                	j	80003d1e <dirlookup+0xa0>
  return 0;
    80003d1c:	4501                	li	a0,0
}
    80003d1e:	70e2                	ld	ra,56(sp)
    80003d20:	7442                	ld	s0,48(sp)
    80003d22:	74a2                	ld	s1,40(sp)
    80003d24:	7902                	ld	s2,32(sp)
    80003d26:	69e2                	ld	s3,24(sp)
    80003d28:	6a42                	ld	s4,16(sp)
    80003d2a:	6121                	addi	sp,sp,64
    80003d2c:	8082                	ret

0000000080003d2e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003d2e:	711d                	addi	sp,sp,-96
    80003d30:	ec86                	sd	ra,88(sp)
    80003d32:	e8a2                	sd	s0,80(sp)
    80003d34:	e4a6                	sd	s1,72(sp)
    80003d36:	e0ca                	sd	s2,64(sp)
    80003d38:	fc4e                	sd	s3,56(sp)
    80003d3a:	f852                	sd	s4,48(sp)
    80003d3c:	f456                	sd	s5,40(sp)
    80003d3e:	f05a                	sd	s6,32(sp)
    80003d40:	ec5e                	sd	s7,24(sp)
    80003d42:	e862                	sd	s8,16(sp)
    80003d44:	e466                	sd	s9,8(sp)
    80003d46:	e06a                	sd	s10,0(sp)
    80003d48:	1080                	addi	s0,sp,96
    80003d4a:	84aa                	mv	s1,a0
    80003d4c:	8b2e                	mv	s6,a1
    80003d4e:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003d50:	00054703          	lbu	a4,0(a0)
    80003d54:	02f00793          	li	a5,47
    80003d58:	02f70363          	beq	a4,a5,80003d7e <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003d5c:	ffffe097          	auipc	ra,0xffffe
    80003d60:	c3a080e7          	jalr	-966(ra) # 80001996 <myproc>
    80003d64:	15053503          	ld	a0,336(a0)
    80003d68:	00000097          	auipc	ra,0x0
    80003d6c:	9f4080e7          	jalr	-1548(ra) # 8000375c <idup>
    80003d70:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003d72:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003d76:	4cb5                	li	s9,13
  len = path - s;
    80003d78:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003d7a:	4c05                	li	s8,1
    80003d7c:	a87d                	j	80003e3a <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80003d7e:	4585                	li	a1,1
    80003d80:	4505                	li	a0,1
    80003d82:	fffff097          	auipc	ra,0xfffff
    80003d86:	6e2080e7          	jalr	1762(ra) # 80003464 <iget>
    80003d8a:	8a2a                	mv	s4,a0
    80003d8c:	b7dd                	j	80003d72 <namex+0x44>
      iunlockput(ip);
    80003d8e:	8552                	mv	a0,s4
    80003d90:	00000097          	auipc	ra,0x0
    80003d94:	c6c080e7          	jalr	-916(ra) # 800039fc <iunlockput>
      return 0;
    80003d98:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003d9a:	8552                	mv	a0,s4
    80003d9c:	60e6                	ld	ra,88(sp)
    80003d9e:	6446                	ld	s0,80(sp)
    80003da0:	64a6                	ld	s1,72(sp)
    80003da2:	6906                	ld	s2,64(sp)
    80003da4:	79e2                	ld	s3,56(sp)
    80003da6:	7a42                	ld	s4,48(sp)
    80003da8:	7aa2                	ld	s5,40(sp)
    80003daa:	7b02                	ld	s6,32(sp)
    80003dac:	6be2                	ld	s7,24(sp)
    80003dae:	6c42                	ld	s8,16(sp)
    80003db0:	6ca2                	ld	s9,8(sp)
    80003db2:	6d02                	ld	s10,0(sp)
    80003db4:	6125                	addi	sp,sp,96
    80003db6:	8082                	ret
      iunlock(ip);
    80003db8:	8552                	mv	a0,s4
    80003dba:	00000097          	auipc	ra,0x0
    80003dbe:	aa2080e7          	jalr	-1374(ra) # 8000385c <iunlock>
      return ip;
    80003dc2:	bfe1                	j	80003d9a <namex+0x6c>
      iunlockput(ip);
    80003dc4:	8552                	mv	a0,s4
    80003dc6:	00000097          	auipc	ra,0x0
    80003dca:	c36080e7          	jalr	-970(ra) # 800039fc <iunlockput>
      return 0;
    80003dce:	8a4e                	mv	s4,s3
    80003dd0:	b7e9                	j	80003d9a <namex+0x6c>
  len = path - s;
    80003dd2:	40998633          	sub	a2,s3,s1
    80003dd6:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003dda:	09acd863          	bge	s9,s10,80003e6a <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80003dde:	4639                	li	a2,14
    80003de0:	85a6                	mv	a1,s1
    80003de2:	8556                	mv	a0,s5
    80003de4:	ffffd097          	auipc	ra,0xffffd
    80003de8:	f44080e7          	jalr	-188(ra) # 80000d28 <memmove>
    80003dec:	84ce                	mv	s1,s3
  while(*path == '/')
    80003dee:	0004c783          	lbu	a5,0(s1)
    80003df2:	01279763          	bne	a5,s2,80003e00 <namex+0xd2>
    path++;
    80003df6:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003df8:	0004c783          	lbu	a5,0(s1)
    80003dfc:	ff278de3          	beq	a5,s2,80003df6 <namex+0xc8>
    ilock(ip);
    80003e00:	8552                	mv	a0,s4
    80003e02:	00000097          	auipc	ra,0x0
    80003e06:	998080e7          	jalr	-1640(ra) # 8000379a <ilock>
    if(ip->type != T_DIR){
    80003e0a:	044a1783          	lh	a5,68(s4)
    80003e0e:	f98790e3          	bne	a5,s8,80003d8e <namex+0x60>
    if(nameiparent && *path == '\0'){
    80003e12:	000b0563          	beqz	s6,80003e1c <namex+0xee>
    80003e16:	0004c783          	lbu	a5,0(s1)
    80003e1a:	dfd9                	beqz	a5,80003db8 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003e1c:	865e                	mv	a2,s7
    80003e1e:	85d6                	mv	a1,s5
    80003e20:	8552                	mv	a0,s4
    80003e22:	00000097          	auipc	ra,0x0
    80003e26:	e5c080e7          	jalr	-420(ra) # 80003c7e <dirlookup>
    80003e2a:	89aa                	mv	s3,a0
    80003e2c:	dd41                	beqz	a0,80003dc4 <namex+0x96>
    iunlockput(ip);
    80003e2e:	8552                	mv	a0,s4
    80003e30:	00000097          	auipc	ra,0x0
    80003e34:	bcc080e7          	jalr	-1076(ra) # 800039fc <iunlockput>
    ip = next;
    80003e38:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003e3a:	0004c783          	lbu	a5,0(s1)
    80003e3e:	01279763          	bne	a5,s2,80003e4c <namex+0x11e>
    path++;
    80003e42:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003e44:	0004c783          	lbu	a5,0(s1)
    80003e48:	ff278de3          	beq	a5,s2,80003e42 <namex+0x114>
  if(*path == 0)
    80003e4c:	cb9d                	beqz	a5,80003e82 <namex+0x154>
  while(*path != '/' && *path != 0)
    80003e4e:	0004c783          	lbu	a5,0(s1)
    80003e52:	89a6                	mv	s3,s1
  len = path - s;
    80003e54:	8d5e                	mv	s10,s7
    80003e56:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003e58:	01278963          	beq	a5,s2,80003e6a <namex+0x13c>
    80003e5c:	dbbd                	beqz	a5,80003dd2 <namex+0xa4>
    path++;
    80003e5e:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003e60:	0009c783          	lbu	a5,0(s3)
    80003e64:	ff279ce3          	bne	a5,s2,80003e5c <namex+0x12e>
    80003e68:	b7ad                	j	80003dd2 <namex+0xa4>
    memmove(name, s, len);
    80003e6a:	2601                	sext.w	a2,a2
    80003e6c:	85a6                	mv	a1,s1
    80003e6e:	8556                	mv	a0,s5
    80003e70:	ffffd097          	auipc	ra,0xffffd
    80003e74:	eb8080e7          	jalr	-328(ra) # 80000d28 <memmove>
    name[len] = 0;
    80003e78:	9d56                	add	s10,s10,s5
    80003e7a:	000d0023          	sb	zero,0(s10)
    80003e7e:	84ce                	mv	s1,s3
    80003e80:	b7bd                	j	80003dee <namex+0xc0>
  if(nameiparent){
    80003e82:	f00b0ce3          	beqz	s6,80003d9a <namex+0x6c>
    iput(ip);
    80003e86:	8552                	mv	a0,s4
    80003e88:	00000097          	auipc	ra,0x0
    80003e8c:	acc080e7          	jalr	-1332(ra) # 80003954 <iput>
    return 0;
    80003e90:	4a01                	li	s4,0
    80003e92:	b721                	j	80003d9a <namex+0x6c>

0000000080003e94 <dirlink>:
{
    80003e94:	7139                	addi	sp,sp,-64
    80003e96:	fc06                	sd	ra,56(sp)
    80003e98:	f822                	sd	s0,48(sp)
    80003e9a:	f426                	sd	s1,40(sp)
    80003e9c:	f04a                	sd	s2,32(sp)
    80003e9e:	ec4e                	sd	s3,24(sp)
    80003ea0:	e852                	sd	s4,16(sp)
    80003ea2:	0080                	addi	s0,sp,64
    80003ea4:	892a                	mv	s2,a0
    80003ea6:	8a2e                	mv	s4,a1
    80003ea8:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003eaa:	4601                	li	a2,0
    80003eac:	00000097          	auipc	ra,0x0
    80003eb0:	dd2080e7          	jalr	-558(ra) # 80003c7e <dirlookup>
    80003eb4:	e93d                	bnez	a0,80003f2a <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003eb6:	04c92483          	lw	s1,76(s2)
    80003eba:	c49d                	beqz	s1,80003ee8 <dirlink+0x54>
    80003ebc:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ebe:	4741                	li	a4,16
    80003ec0:	86a6                	mv	a3,s1
    80003ec2:	fc040613          	addi	a2,s0,-64
    80003ec6:	4581                	li	a1,0
    80003ec8:	854a                	mv	a0,s2
    80003eca:	00000097          	auipc	ra,0x0
    80003ece:	b84080e7          	jalr	-1148(ra) # 80003a4e <readi>
    80003ed2:	47c1                	li	a5,16
    80003ed4:	06f51163          	bne	a0,a5,80003f36 <dirlink+0xa2>
    if(de.inum == 0)
    80003ed8:	fc045783          	lhu	a5,-64(s0)
    80003edc:	c791                	beqz	a5,80003ee8 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ede:	24c1                	addiw	s1,s1,16
    80003ee0:	04c92783          	lw	a5,76(s2)
    80003ee4:	fcf4ede3          	bltu	s1,a5,80003ebe <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003ee8:	4639                	li	a2,14
    80003eea:	85d2                	mv	a1,s4
    80003eec:	fc240513          	addi	a0,s0,-62
    80003ef0:	ffffd097          	auipc	ra,0xffffd
    80003ef4:	ee8080e7          	jalr	-280(ra) # 80000dd8 <strncpy>
  de.inum = inum;
    80003ef8:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003efc:	4741                	li	a4,16
    80003efe:	86a6                	mv	a3,s1
    80003f00:	fc040613          	addi	a2,s0,-64
    80003f04:	4581                	li	a1,0
    80003f06:	854a                	mv	a0,s2
    80003f08:	00000097          	auipc	ra,0x0
    80003f0c:	c3e080e7          	jalr	-962(ra) # 80003b46 <writei>
    80003f10:	872a                	mv	a4,a0
    80003f12:	47c1                	li	a5,16
  return 0;
    80003f14:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f16:	02f71863          	bne	a4,a5,80003f46 <dirlink+0xb2>
}
    80003f1a:	70e2                	ld	ra,56(sp)
    80003f1c:	7442                	ld	s0,48(sp)
    80003f1e:	74a2                	ld	s1,40(sp)
    80003f20:	7902                	ld	s2,32(sp)
    80003f22:	69e2                	ld	s3,24(sp)
    80003f24:	6a42                	ld	s4,16(sp)
    80003f26:	6121                	addi	sp,sp,64
    80003f28:	8082                	ret
    iput(ip);
    80003f2a:	00000097          	auipc	ra,0x0
    80003f2e:	a2a080e7          	jalr	-1494(ra) # 80003954 <iput>
    return -1;
    80003f32:	557d                	li	a0,-1
    80003f34:	b7dd                	j	80003f1a <dirlink+0x86>
      panic("dirlink read");
    80003f36:	00004517          	auipc	a0,0x4
    80003f3a:	6e250513          	addi	a0,a0,1762 # 80008618 <syscalls+0x1d0>
    80003f3e:	ffffc097          	auipc	ra,0xffffc
    80003f42:	5fc080e7          	jalr	1532(ra) # 8000053a <panic>
    panic("dirlink");
    80003f46:	00004517          	auipc	a0,0x4
    80003f4a:	7e250513          	addi	a0,a0,2018 # 80008728 <syscalls+0x2e0>
    80003f4e:	ffffc097          	auipc	ra,0xffffc
    80003f52:	5ec080e7          	jalr	1516(ra) # 8000053a <panic>

0000000080003f56 <namei>:

struct inode*
namei(char *path)
{
    80003f56:	1101                	addi	sp,sp,-32
    80003f58:	ec06                	sd	ra,24(sp)
    80003f5a:	e822                	sd	s0,16(sp)
    80003f5c:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003f5e:	fe040613          	addi	a2,s0,-32
    80003f62:	4581                	li	a1,0
    80003f64:	00000097          	auipc	ra,0x0
    80003f68:	dca080e7          	jalr	-566(ra) # 80003d2e <namex>
}
    80003f6c:	60e2                	ld	ra,24(sp)
    80003f6e:	6442                	ld	s0,16(sp)
    80003f70:	6105                	addi	sp,sp,32
    80003f72:	8082                	ret

0000000080003f74 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003f74:	1141                	addi	sp,sp,-16
    80003f76:	e406                	sd	ra,8(sp)
    80003f78:	e022                	sd	s0,0(sp)
    80003f7a:	0800                	addi	s0,sp,16
    80003f7c:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003f7e:	4585                	li	a1,1
    80003f80:	00000097          	auipc	ra,0x0
    80003f84:	dae080e7          	jalr	-594(ra) # 80003d2e <namex>
}
    80003f88:	60a2                	ld	ra,8(sp)
    80003f8a:	6402                	ld	s0,0(sp)
    80003f8c:	0141                	addi	sp,sp,16
    80003f8e:	8082                	ret

0000000080003f90 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003f90:	1101                	addi	sp,sp,-32
    80003f92:	ec06                	sd	ra,24(sp)
    80003f94:	e822                	sd	s0,16(sp)
    80003f96:	e426                	sd	s1,8(sp)
    80003f98:	e04a                	sd	s2,0(sp)
    80003f9a:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003f9c:	0001d917          	auipc	s2,0x1d
    80003fa0:	2d490913          	addi	s2,s2,724 # 80021270 <log>
    80003fa4:	01892583          	lw	a1,24(s2)
    80003fa8:	02892503          	lw	a0,40(s2)
    80003fac:	fffff097          	auipc	ra,0xfffff
    80003fb0:	fec080e7          	jalr	-20(ra) # 80002f98 <bread>
    80003fb4:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003fb6:	02c92683          	lw	a3,44(s2)
    80003fba:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003fbc:	02d05863          	blez	a3,80003fec <write_head+0x5c>
    80003fc0:	0001d797          	auipc	a5,0x1d
    80003fc4:	2e078793          	addi	a5,a5,736 # 800212a0 <log+0x30>
    80003fc8:	05c50713          	addi	a4,a0,92
    80003fcc:	36fd                	addiw	a3,a3,-1
    80003fce:	02069613          	slli	a2,a3,0x20
    80003fd2:	01e65693          	srli	a3,a2,0x1e
    80003fd6:	0001d617          	auipc	a2,0x1d
    80003fda:	2ce60613          	addi	a2,a2,718 # 800212a4 <log+0x34>
    80003fde:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003fe0:	4390                	lw	a2,0(a5)
    80003fe2:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003fe4:	0791                	addi	a5,a5,4
    80003fe6:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80003fe8:	fed79ce3          	bne	a5,a3,80003fe0 <write_head+0x50>
  }
  bwrite(buf);
    80003fec:	8526                	mv	a0,s1
    80003fee:	fffff097          	auipc	ra,0xfffff
    80003ff2:	09c080e7          	jalr	156(ra) # 8000308a <bwrite>
  brelse(buf);
    80003ff6:	8526                	mv	a0,s1
    80003ff8:	fffff097          	auipc	ra,0xfffff
    80003ffc:	0d0080e7          	jalr	208(ra) # 800030c8 <brelse>
}
    80004000:	60e2                	ld	ra,24(sp)
    80004002:	6442                	ld	s0,16(sp)
    80004004:	64a2                	ld	s1,8(sp)
    80004006:	6902                	ld	s2,0(sp)
    80004008:	6105                	addi	sp,sp,32
    8000400a:	8082                	ret

000000008000400c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000400c:	0001d797          	auipc	a5,0x1d
    80004010:	2907a783          	lw	a5,656(a5) # 8002129c <log+0x2c>
    80004014:	0af05d63          	blez	a5,800040ce <install_trans+0xc2>
{
    80004018:	7139                	addi	sp,sp,-64
    8000401a:	fc06                	sd	ra,56(sp)
    8000401c:	f822                	sd	s0,48(sp)
    8000401e:	f426                	sd	s1,40(sp)
    80004020:	f04a                	sd	s2,32(sp)
    80004022:	ec4e                	sd	s3,24(sp)
    80004024:	e852                	sd	s4,16(sp)
    80004026:	e456                	sd	s5,8(sp)
    80004028:	e05a                	sd	s6,0(sp)
    8000402a:	0080                	addi	s0,sp,64
    8000402c:	8b2a                	mv	s6,a0
    8000402e:	0001da97          	auipc	s5,0x1d
    80004032:	272a8a93          	addi	s5,s5,626 # 800212a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004036:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004038:	0001d997          	auipc	s3,0x1d
    8000403c:	23898993          	addi	s3,s3,568 # 80021270 <log>
    80004040:	a00d                	j	80004062 <install_trans+0x56>
    brelse(lbuf);
    80004042:	854a                	mv	a0,s2
    80004044:	fffff097          	auipc	ra,0xfffff
    80004048:	084080e7          	jalr	132(ra) # 800030c8 <brelse>
    brelse(dbuf);
    8000404c:	8526                	mv	a0,s1
    8000404e:	fffff097          	auipc	ra,0xfffff
    80004052:	07a080e7          	jalr	122(ra) # 800030c8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004056:	2a05                	addiw	s4,s4,1
    80004058:	0a91                	addi	s5,s5,4
    8000405a:	02c9a783          	lw	a5,44(s3)
    8000405e:	04fa5e63          	bge	s4,a5,800040ba <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004062:	0189a583          	lw	a1,24(s3)
    80004066:	014585bb          	addw	a1,a1,s4
    8000406a:	2585                	addiw	a1,a1,1
    8000406c:	0289a503          	lw	a0,40(s3)
    80004070:	fffff097          	auipc	ra,0xfffff
    80004074:	f28080e7          	jalr	-216(ra) # 80002f98 <bread>
    80004078:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000407a:	000aa583          	lw	a1,0(s5)
    8000407e:	0289a503          	lw	a0,40(s3)
    80004082:	fffff097          	auipc	ra,0xfffff
    80004086:	f16080e7          	jalr	-234(ra) # 80002f98 <bread>
    8000408a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000408c:	40000613          	li	a2,1024
    80004090:	05890593          	addi	a1,s2,88
    80004094:	05850513          	addi	a0,a0,88
    80004098:	ffffd097          	auipc	ra,0xffffd
    8000409c:	c90080e7          	jalr	-880(ra) # 80000d28 <memmove>
    bwrite(dbuf);  // write dst to disk
    800040a0:	8526                	mv	a0,s1
    800040a2:	fffff097          	auipc	ra,0xfffff
    800040a6:	fe8080e7          	jalr	-24(ra) # 8000308a <bwrite>
    if(recovering == 0)
    800040aa:	f80b1ce3          	bnez	s6,80004042 <install_trans+0x36>
      bunpin(dbuf);
    800040ae:	8526                	mv	a0,s1
    800040b0:	fffff097          	auipc	ra,0xfffff
    800040b4:	0f2080e7          	jalr	242(ra) # 800031a2 <bunpin>
    800040b8:	b769                	j	80004042 <install_trans+0x36>
}
    800040ba:	70e2                	ld	ra,56(sp)
    800040bc:	7442                	ld	s0,48(sp)
    800040be:	74a2                	ld	s1,40(sp)
    800040c0:	7902                	ld	s2,32(sp)
    800040c2:	69e2                	ld	s3,24(sp)
    800040c4:	6a42                	ld	s4,16(sp)
    800040c6:	6aa2                	ld	s5,8(sp)
    800040c8:	6b02                	ld	s6,0(sp)
    800040ca:	6121                	addi	sp,sp,64
    800040cc:	8082                	ret
    800040ce:	8082                	ret

00000000800040d0 <initlog>:
{
    800040d0:	7179                	addi	sp,sp,-48
    800040d2:	f406                	sd	ra,40(sp)
    800040d4:	f022                	sd	s0,32(sp)
    800040d6:	ec26                	sd	s1,24(sp)
    800040d8:	e84a                	sd	s2,16(sp)
    800040da:	e44e                	sd	s3,8(sp)
    800040dc:	1800                	addi	s0,sp,48
    800040de:	892a                	mv	s2,a0
    800040e0:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800040e2:	0001d497          	auipc	s1,0x1d
    800040e6:	18e48493          	addi	s1,s1,398 # 80021270 <log>
    800040ea:	00004597          	auipc	a1,0x4
    800040ee:	53e58593          	addi	a1,a1,1342 # 80008628 <syscalls+0x1e0>
    800040f2:	8526                	mv	a0,s1
    800040f4:	ffffd097          	auipc	ra,0xffffd
    800040f8:	a4c080e7          	jalr	-1460(ra) # 80000b40 <initlock>
  log.start = sb->logstart;
    800040fc:	0149a583          	lw	a1,20(s3)
    80004100:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004102:	0109a783          	lw	a5,16(s3)
    80004106:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004108:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000410c:	854a                	mv	a0,s2
    8000410e:	fffff097          	auipc	ra,0xfffff
    80004112:	e8a080e7          	jalr	-374(ra) # 80002f98 <bread>
  log.lh.n = lh->n;
    80004116:	4d34                	lw	a3,88(a0)
    80004118:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000411a:	02d05663          	blez	a3,80004146 <initlog+0x76>
    8000411e:	05c50793          	addi	a5,a0,92
    80004122:	0001d717          	auipc	a4,0x1d
    80004126:	17e70713          	addi	a4,a4,382 # 800212a0 <log+0x30>
    8000412a:	36fd                	addiw	a3,a3,-1
    8000412c:	02069613          	slli	a2,a3,0x20
    80004130:	01e65693          	srli	a3,a2,0x1e
    80004134:	06050613          	addi	a2,a0,96
    80004138:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000413a:	4390                	lw	a2,0(a5)
    8000413c:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000413e:	0791                	addi	a5,a5,4
    80004140:	0711                	addi	a4,a4,4
    80004142:	fed79ce3          	bne	a5,a3,8000413a <initlog+0x6a>
  brelse(buf);
    80004146:	fffff097          	auipc	ra,0xfffff
    8000414a:	f82080e7          	jalr	-126(ra) # 800030c8 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000414e:	4505                	li	a0,1
    80004150:	00000097          	auipc	ra,0x0
    80004154:	ebc080e7          	jalr	-324(ra) # 8000400c <install_trans>
  log.lh.n = 0;
    80004158:	0001d797          	auipc	a5,0x1d
    8000415c:	1407a223          	sw	zero,324(a5) # 8002129c <log+0x2c>
  write_head(); // clear the log
    80004160:	00000097          	auipc	ra,0x0
    80004164:	e30080e7          	jalr	-464(ra) # 80003f90 <write_head>
}
    80004168:	70a2                	ld	ra,40(sp)
    8000416a:	7402                	ld	s0,32(sp)
    8000416c:	64e2                	ld	s1,24(sp)
    8000416e:	6942                	ld	s2,16(sp)
    80004170:	69a2                	ld	s3,8(sp)
    80004172:	6145                	addi	sp,sp,48
    80004174:	8082                	ret

0000000080004176 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004176:	1101                	addi	sp,sp,-32
    80004178:	ec06                	sd	ra,24(sp)
    8000417a:	e822                	sd	s0,16(sp)
    8000417c:	e426                	sd	s1,8(sp)
    8000417e:	e04a                	sd	s2,0(sp)
    80004180:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004182:	0001d517          	auipc	a0,0x1d
    80004186:	0ee50513          	addi	a0,a0,238 # 80021270 <log>
    8000418a:	ffffd097          	auipc	ra,0xffffd
    8000418e:	a46080e7          	jalr	-1466(ra) # 80000bd0 <acquire>
  while(1){
    if(log.committing){
    80004192:	0001d497          	auipc	s1,0x1d
    80004196:	0de48493          	addi	s1,s1,222 # 80021270 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000419a:	4979                	li	s2,30
    8000419c:	a039                	j	800041aa <begin_op+0x34>
      sleep(&log, &log.lock);
    8000419e:	85a6                	mv	a1,s1
    800041a0:	8526                	mv	a0,s1
    800041a2:	ffffe097          	auipc	ra,0xffffe
    800041a6:	ebc080e7          	jalr	-324(ra) # 8000205e <sleep>
    if(log.committing){
    800041aa:	50dc                	lw	a5,36(s1)
    800041ac:	fbed                	bnez	a5,8000419e <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800041ae:	5098                	lw	a4,32(s1)
    800041b0:	2705                	addiw	a4,a4,1
    800041b2:	0007069b          	sext.w	a3,a4
    800041b6:	0027179b          	slliw	a5,a4,0x2
    800041ba:	9fb9                	addw	a5,a5,a4
    800041bc:	0017979b          	slliw	a5,a5,0x1
    800041c0:	54d8                	lw	a4,44(s1)
    800041c2:	9fb9                	addw	a5,a5,a4
    800041c4:	00f95963          	bge	s2,a5,800041d6 <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800041c8:	85a6                	mv	a1,s1
    800041ca:	8526                	mv	a0,s1
    800041cc:	ffffe097          	auipc	ra,0xffffe
    800041d0:	e92080e7          	jalr	-366(ra) # 8000205e <sleep>
    800041d4:	bfd9                	j	800041aa <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800041d6:	0001d517          	auipc	a0,0x1d
    800041da:	09a50513          	addi	a0,a0,154 # 80021270 <log>
    800041de:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800041e0:	ffffd097          	auipc	ra,0xffffd
    800041e4:	aa4080e7          	jalr	-1372(ra) # 80000c84 <release>
      break;
    }
  }
}
    800041e8:	60e2                	ld	ra,24(sp)
    800041ea:	6442                	ld	s0,16(sp)
    800041ec:	64a2                	ld	s1,8(sp)
    800041ee:	6902                	ld	s2,0(sp)
    800041f0:	6105                	addi	sp,sp,32
    800041f2:	8082                	ret

00000000800041f4 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800041f4:	7139                	addi	sp,sp,-64
    800041f6:	fc06                	sd	ra,56(sp)
    800041f8:	f822                	sd	s0,48(sp)
    800041fa:	f426                	sd	s1,40(sp)
    800041fc:	f04a                	sd	s2,32(sp)
    800041fe:	ec4e                	sd	s3,24(sp)
    80004200:	e852                	sd	s4,16(sp)
    80004202:	e456                	sd	s5,8(sp)
    80004204:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004206:	0001d497          	auipc	s1,0x1d
    8000420a:	06a48493          	addi	s1,s1,106 # 80021270 <log>
    8000420e:	8526                	mv	a0,s1
    80004210:	ffffd097          	auipc	ra,0xffffd
    80004214:	9c0080e7          	jalr	-1600(ra) # 80000bd0 <acquire>
  log.outstanding -= 1;
    80004218:	509c                	lw	a5,32(s1)
    8000421a:	37fd                	addiw	a5,a5,-1
    8000421c:	0007891b          	sext.w	s2,a5
    80004220:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004222:	50dc                	lw	a5,36(s1)
    80004224:	e7b9                	bnez	a5,80004272 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004226:	04091e63          	bnez	s2,80004282 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000422a:	0001d497          	auipc	s1,0x1d
    8000422e:	04648493          	addi	s1,s1,70 # 80021270 <log>
    80004232:	4785                	li	a5,1
    80004234:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004236:	8526                	mv	a0,s1
    80004238:	ffffd097          	auipc	ra,0xffffd
    8000423c:	a4c080e7          	jalr	-1460(ra) # 80000c84 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004240:	54dc                	lw	a5,44(s1)
    80004242:	06f04763          	bgtz	a5,800042b0 <end_op+0xbc>
    acquire(&log.lock);
    80004246:	0001d497          	auipc	s1,0x1d
    8000424a:	02a48493          	addi	s1,s1,42 # 80021270 <log>
    8000424e:	8526                	mv	a0,s1
    80004250:	ffffd097          	auipc	ra,0xffffd
    80004254:	980080e7          	jalr	-1664(ra) # 80000bd0 <acquire>
    log.committing = 0;
    80004258:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000425c:	8526                	mv	a0,s1
    8000425e:	ffffe097          	auipc	ra,0xffffe
    80004262:	f8c080e7          	jalr	-116(ra) # 800021ea <wakeup>
    release(&log.lock);
    80004266:	8526                	mv	a0,s1
    80004268:	ffffd097          	auipc	ra,0xffffd
    8000426c:	a1c080e7          	jalr	-1508(ra) # 80000c84 <release>
}
    80004270:	a03d                	j	8000429e <end_op+0xaa>
    panic("log.committing");
    80004272:	00004517          	auipc	a0,0x4
    80004276:	3be50513          	addi	a0,a0,958 # 80008630 <syscalls+0x1e8>
    8000427a:	ffffc097          	auipc	ra,0xffffc
    8000427e:	2c0080e7          	jalr	704(ra) # 8000053a <panic>
    wakeup(&log);
    80004282:	0001d497          	auipc	s1,0x1d
    80004286:	fee48493          	addi	s1,s1,-18 # 80021270 <log>
    8000428a:	8526                	mv	a0,s1
    8000428c:	ffffe097          	auipc	ra,0xffffe
    80004290:	f5e080e7          	jalr	-162(ra) # 800021ea <wakeup>
  release(&log.lock);
    80004294:	8526                	mv	a0,s1
    80004296:	ffffd097          	auipc	ra,0xffffd
    8000429a:	9ee080e7          	jalr	-1554(ra) # 80000c84 <release>
}
    8000429e:	70e2                	ld	ra,56(sp)
    800042a0:	7442                	ld	s0,48(sp)
    800042a2:	74a2                	ld	s1,40(sp)
    800042a4:	7902                	ld	s2,32(sp)
    800042a6:	69e2                	ld	s3,24(sp)
    800042a8:	6a42                	ld	s4,16(sp)
    800042aa:	6aa2                	ld	s5,8(sp)
    800042ac:	6121                	addi	sp,sp,64
    800042ae:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800042b0:	0001da97          	auipc	s5,0x1d
    800042b4:	ff0a8a93          	addi	s5,s5,-16 # 800212a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800042b8:	0001da17          	auipc	s4,0x1d
    800042bc:	fb8a0a13          	addi	s4,s4,-72 # 80021270 <log>
    800042c0:	018a2583          	lw	a1,24(s4)
    800042c4:	012585bb          	addw	a1,a1,s2
    800042c8:	2585                	addiw	a1,a1,1
    800042ca:	028a2503          	lw	a0,40(s4)
    800042ce:	fffff097          	auipc	ra,0xfffff
    800042d2:	cca080e7          	jalr	-822(ra) # 80002f98 <bread>
    800042d6:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800042d8:	000aa583          	lw	a1,0(s5)
    800042dc:	028a2503          	lw	a0,40(s4)
    800042e0:	fffff097          	auipc	ra,0xfffff
    800042e4:	cb8080e7          	jalr	-840(ra) # 80002f98 <bread>
    800042e8:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800042ea:	40000613          	li	a2,1024
    800042ee:	05850593          	addi	a1,a0,88
    800042f2:	05848513          	addi	a0,s1,88
    800042f6:	ffffd097          	auipc	ra,0xffffd
    800042fa:	a32080e7          	jalr	-1486(ra) # 80000d28 <memmove>
    bwrite(to);  // write the log
    800042fe:	8526                	mv	a0,s1
    80004300:	fffff097          	auipc	ra,0xfffff
    80004304:	d8a080e7          	jalr	-630(ra) # 8000308a <bwrite>
    brelse(from);
    80004308:	854e                	mv	a0,s3
    8000430a:	fffff097          	auipc	ra,0xfffff
    8000430e:	dbe080e7          	jalr	-578(ra) # 800030c8 <brelse>
    brelse(to);
    80004312:	8526                	mv	a0,s1
    80004314:	fffff097          	auipc	ra,0xfffff
    80004318:	db4080e7          	jalr	-588(ra) # 800030c8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000431c:	2905                	addiw	s2,s2,1
    8000431e:	0a91                	addi	s5,s5,4
    80004320:	02ca2783          	lw	a5,44(s4)
    80004324:	f8f94ee3          	blt	s2,a5,800042c0 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004328:	00000097          	auipc	ra,0x0
    8000432c:	c68080e7          	jalr	-920(ra) # 80003f90 <write_head>
    install_trans(0); // Now install writes to home locations
    80004330:	4501                	li	a0,0
    80004332:	00000097          	auipc	ra,0x0
    80004336:	cda080e7          	jalr	-806(ra) # 8000400c <install_trans>
    log.lh.n = 0;
    8000433a:	0001d797          	auipc	a5,0x1d
    8000433e:	f607a123          	sw	zero,-158(a5) # 8002129c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004342:	00000097          	auipc	ra,0x0
    80004346:	c4e080e7          	jalr	-946(ra) # 80003f90 <write_head>
    8000434a:	bdf5                	j	80004246 <end_op+0x52>

000000008000434c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000434c:	1101                	addi	sp,sp,-32
    8000434e:	ec06                	sd	ra,24(sp)
    80004350:	e822                	sd	s0,16(sp)
    80004352:	e426                	sd	s1,8(sp)
    80004354:	e04a                	sd	s2,0(sp)
    80004356:	1000                	addi	s0,sp,32
    80004358:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000435a:	0001d917          	auipc	s2,0x1d
    8000435e:	f1690913          	addi	s2,s2,-234 # 80021270 <log>
    80004362:	854a                	mv	a0,s2
    80004364:	ffffd097          	auipc	ra,0xffffd
    80004368:	86c080e7          	jalr	-1940(ra) # 80000bd0 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000436c:	02c92603          	lw	a2,44(s2)
    80004370:	47f5                	li	a5,29
    80004372:	06c7c563          	blt	a5,a2,800043dc <log_write+0x90>
    80004376:	0001d797          	auipc	a5,0x1d
    8000437a:	f167a783          	lw	a5,-234(a5) # 8002128c <log+0x1c>
    8000437e:	37fd                	addiw	a5,a5,-1
    80004380:	04f65e63          	bge	a2,a5,800043dc <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004384:	0001d797          	auipc	a5,0x1d
    80004388:	f0c7a783          	lw	a5,-244(a5) # 80021290 <log+0x20>
    8000438c:	06f05063          	blez	a5,800043ec <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004390:	4781                	li	a5,0
    80004392:	06c05563          	blez	a2,800043fc <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004396:	44cc                	lw	a1,12(s1)
    80004398:	0001d717          	auipc	a4,0x1d
    8000439c:	f0870713          	addi	a4,a4,-248 # 800212a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800043a0:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800043a2:	4314                	lw	a3,0(a4)
    800043a4:	04b68c63          	beq	a3,a1,800043fc <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800043a8:	2785                	addiw	a5,a5,1
    800043aa:	0711                	addi	a4,a4,4
    800043ac:	fef61be3          	bne	a2,a5,800043a2 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800043b0:	0621                	addi	a2,a2,8
    800043b2:	060a                	slli	a2,a2,0x2
    800043b4:	0001d797          	auipc	a5,0x1d
    800043b8:	ebc78793          	addi	a5,a5,-324 # 80021270 <log>
    800043bc:	97b2                	add	a5,a5,a2
    800043be:	44d8                	lw	a4,12(s1)
    800043c0:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800043c2:	8526                	mv	a0,s1
    800043c4:	fffff097          	auipc	ra,0xfffff
    800043c8:	da2080e7          	jalr	-606(ra) # 80003166 <bpin>
    log.lh.n++;
    800043cc:	0001d717          	auipc	a4,0x1d
    800043d0:	ea470713          	addi	a4,a4,-348 # 80021270 <log>
    800043d4:	575c                	lw	a5,44(a4)
    800043d6:	2785                	addiw	a5,a5,1
    800043d8:	d75c                	sw	a5,44(a4)
    800043da:	a82d                	j	80004414 <log_write+0xc8>
    panic("too big a transaction");
    800043dc:	00004517          	auipc	a0,0x4
    800043e0:	26450513          	addi	a0,a0,612 # 80008640 <syscalls+0x1f8>
    800043e4:	ffffc097          	auipc	ra,0xffffc
    800043e8:	156080e7          	jalr	342(ra) # 8000053a <panic>
    panic("log_write outside of trans");
    800043ec:	00004517          	auipc	a0,0x4
    800043f0:	26c50513          	addi	a0,a0,620 # 80008658 <syscalls+0x210>
    800043f4:	ffffc097          	auipc	ra,0xffffc
    800043f8:	146080e7          	jalr	326(ra) # 8000053a <panic>
  log.lh.block[i] = b->blockno;
    800043fc:	00878693          	addi	a3,a5,8
    80004400:	068a                	slli	a3,a3,0x2
    80004402:	0001d717          	auipc	a4,0x1d
    80004406:	e6e70713          	addi	a4,a4,-402 # 80021270 <log>
    8000440a:	9736                	add	a4,a4,a3
    8000440c:	44d4                	lw	a3,12(s1)
    8000440e:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004410:	faf609e3          	beq	a2,a5,800043c2 <log_write+0x76>
  }
  release(&log.lock);
    80004414:	0001d517          	auipc	a0,0x1d
    80004418:	e5c50513          	addi	a0,a0,-420 # 80021270 <log>
    8000441c:	ffffd097          	auipc	ra,0xffffd
    80004420:	868080e7          	jalr	-1944(ra) # 80000c84 <release>
}
    80004424:	60e2                	ld	ra,24(sp)
    80004426:	6442                	ld	s0,16(sp)
    80004428:	64a2                	ld	s1,8(sp)
    8000442a:	6902                	ld	s2,0(sp)
    8000442c:	6105                	addi	sp,sp,32
    8000442e:	8082                	ret

0000000080004430 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004430:	1101                	addi	sp,sp,-32
    80004432:	ec06                	sd	ra,24(sp)
    80004434:	e822                	sd	s0,16(sp)
    80004436:	e426                	sd	s1,8(sp)
    80004438:	e04a                	sd	s2,0(sp)
    8000443a:	1000                	addi	s0,sp,32
    8000443c:	84aa                	mv	s1,a0
    8000443e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004440:	00004597          	auipc	a1,0x4
    80004444:	23858593          	addi	a1,a1,568 # 80008678 <syscalls+0x230>
    80004448:	0521                	addi	a0,a0,8
    8000444a:	ffffc097          	auipc	ra,0xffffc
    8000444e:	6f6080e7          	jalr	1782(ra) # 80000b40 <initlock>
  lk->name = name;
    80004452:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004456:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000445a:	0204a423          	sw	zero,40(s1)
}
    8000445e:	60e2                	ld	ra,24(sp)
    80004460:	6442                	ld	s0,16(sp)
    80004462:	64a2                	ld	s1,8(sp)
    80004464:	6902                	ld	s2,0(sp)
    80004466:	6105                	addi	sp,sp,32
    80004468:	8082                	ret

000000008000446a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000446a:	1101                	addi	sp,sp,-32
    8000446c:	ec06                	sd	ra,24(sp)
    8000446e:	e822                	sd	s0,16(sp)
    80004470:	e426                	sd	s1,8(sp)
    80004472:	e04a                	sd	s2,0(sp)
    80004474:	1000                	addi	s0,sp,32
    80004476:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004478:	00850913          	addi	s2,a0,8
    8000447c:	854a                	mv	a0,s2
    8000447e:	ffffc097          	auipc	ra,0xffffc
    80004482:	752080e7          	jalr	1874(ra) # 80000bd0 <acquire>
  while (lk->locked) {
    80004486:	409c                	lw	a5,0(s1)
    80004488:	cb89                	beqz	a5,8000449a <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000448a:	85ca                	mv	a1,s2
    8000448c:	8526                	mv	a0,s1
    8000448e:	ffffe097          	auipc	ra,0xffffe
    80004492:	bd0080e7          	jalr	-1072(ra) # 8000205e <sleep>
  while (lk->locked) {
    80004496:	409c                	lw	a5,0(s1)
    80004498:	fbed                	bnez	a5,8000448a <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000449a:	4785                	li	a5,1
    8000449c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000449e:	ffffd097          	auipc	ra,0xffffd
    800044a2:	4f8080e7          	jalr	1272(ra) # 80001996 <myproc>
    800044a6:	591c                	lw	a5,48(a0)
    800044a8:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800044aa:	854a                	mv	a0,s2
    800044ac:	ffffc097          	auipc	ra,0xffffc
    800044b0:	7d8080e7          	jalr	2008(ra) # 80000c84 <release>
}
    800044b4:	60e2                	ld	ra,24(sp)
    800044b6:	6442                	ld	s0,16(sp)
    800044b8:	64a2                	ld	s1,8(sp)
    800044ba:	6902                	ld	s2,0(sp)
    800044bc:	6105                	addi	sp,sp,32
    800044be:	8082                	ret

00000000800044c0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800044c0:	1101                	addi	sp,sp,-32
    800044c2:	ec06                	sd	ra,24(sp)
    800044c4:	e822                	sd	s0,16(sp)
    800044c6:	e426                	sd	s1,8(sp)
    800044c8:	e04a                	sd	s2,0(sp)
    800044ca:	1000                	addi	s0,sp,32
    800044cc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800044ce:	00850913          	addi	s2,a0,8
    800044d2:	854a                	mv	a0,s2
    800044d4:	ffffc097          	auipc	ra,0xffffc
    800044d8:	6fc080e7          	jalr	1788(ra) # 80000bd0 <acquire>
  lk->locked = 0;
    800044dc:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800044e0:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800044e4:	8526                	mv	a0,s1
    800044e6:	ffffe097          	auipc	ra,0xffffe
    800044ea:	d04080e7          	jalr	-764(ra) # 800021ea <wakeup>
  release(&lk->lk);
    800044ee:	854a                	mv	a0,s2
    800044f0:	ffffc097          	auipc	ra,0xffffc
    800044f4:	794080e7          	jalr	1940(ra) # 80000c84 <release>
}
    800044f8:	60e2                	ld	ra,24(sp)
    800044fa:	6442                	ld	s0,16(sp)
    800044fc:	64a2                	ld	s1,8(sp)
    800044fe:	6902                	ld	s2,0(sp)
    80004500:	6105                	addi	sp,sp,32
    80004502:	8082                	ret

0000000080004504 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004504:	7179                	addi	sp,sp,-48
    80004506:	f406                	sd	ra,40(sp)
    80004508:	f022                	sd	s0,32(sp)
    8000450a:	ec26                	sd	s1,24(sp)
    8000450c:	e84a                	sd	s2,16(sp)
    8000450e:	e44e                	sd	s3,8(sp)
    80004510:	1800                	addi	s0,sp,48
    80004512:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004514:	00850913          	addi	s2,a0,8
    80004518:	854a                	mv	a0,s2
    8000451a:	ffffc097          	auipc	ra,0xffffc
    8000451e:	6b6080e7          	jalr	1718(ra) # 80000bd0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004522:	409c                	lw	a5,0(s1)
    80004524:	ef99                	bnez	a5,80004542 <holdingsleep+0x3e>
    80004526:	4481                	li	s1,0
  release(&lk->lk);
    80004528:	854a                	mv	a0,s2
    8000452a:	ffffc097          	auipc	ra,0xffffc
    8000452e:	75a080e7          	jalr	1882(ra) # 80000c84 <release>
  return r;
}
    80004532:	8526                	mv	a0,s1
    80004534:	70a2                	ld	ra,40(sp)
    80004536:	7402                	ld	s0,32(sp)
    80004538:	64e2                	ld	s1,24(sp)
    8000453a:	6942                	ld	s2,16(sp)
    8000453c:	69a2                	ld	s3,8(sp)
    8000453e:	6145                	addi	sp,sp,48
    80004540:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004542:	0284a983          	lw	s3,40(s1)
    80004546:	ffffd097          	auipc	ra,0xffffd
    8000454a:	450080e7          	jalr	1104(ra) # 80001996 <myproc>
    8000454e:	5904                	lw	s1,48(a0)
    80004550:	413484b3          	sub	s1,s1,s3
    80004554:	0014b493          	seqz	s1,s1
    80004558:	bfc1                	j	80004528 <holdingsleep+0x24>

000000008000455a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000455a:	1141                	addi	sp,sp,-16
    8000455c:	e406                	sd	ra,8(sp)
    8000455e:	e022                	sd	s0,0(sp)
    80004560:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004562:	00004597          	auipc	a1,0x4
    80004566:	12658593          	addi	a1,a1,294 # 80008688 <syscalls+0x240>
    8000456a:	0001d517          	auipc	a0,0x1d
    8000456e:	e4e50513          	addi	a0,a0,-434 # 800213b8 <ftable>
    80004572:	ffffc097          	auipc	ra,0xffffc
    80004576:	5ce080e7          	jalr	1486(ra) # 80000b40 <initlock>
}
    8000457a:	60a2                	ld	ra,8(sp)
    8000457c:	6402                	ld	s0,0(sp)
    8000457e:	0141                	addi	sp,sp,16
    80004580:	8082                	ret

0000000080004582 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004582:	1101                	addi	sp,sp,-32
    80004584:	ec06                	sd	ra,24(sp)
    80004586:	e822                	sd	s0,16(sp)
    80004588:	e426                	sd	s1,8(sp)
    8000458a:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000458c:	0001d517          	auipc	a0,0x1d
    80004590:	e2c50513          	addi	a0,a0,-468 # 800213b8 <ftable>
    80004594:	ffffc097          	auipc	ra,0xffffc
    80004598:	63c080e7          	jalr	1596(ra) # 80000bd0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000459c:	0001d497          	auipc	s1,0x1d
    800045a0:	e3448493          	addi	s1,s1,-460 # 800213d0 <ftable+0x18>
    800045a4:	0001e717          	auipc	a4,0x1e
    800045a8:	dcc70713          	addi	a4,a4,-564 # 80022370 <ftable+0xfb8>
    if(f->ref == 0){
    800045ac:	40dc                	lw	a5,4(s1)
    800045ae:	cf99                	beqz	a5,800045cc <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800045b0:	02848493          	addi	s1,s1,40
    800045b4:	fee49ce3          	bne	s1,a4,800045ac <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800045b8:	0001d517          	auipc	a0,0x1d
    800045bc:	e0050513          	addi	a0,a0,-512 # 800213b8 <ftable>
    800045c0:	ffffc097          	auipc	ra,0xffffc
    800045c4:	6c4080e7          	jalr	1732(ra) # 80000c84 <release>
  return 0;
    800045c8:	4481                	li	s1,0
    800045ca:	a819                	j	800045e0 <filealloc+0x5e>
      f->ref = 1;
    800045cc:	4785                	li	a5,1
    800045ce:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800045d0:	0001d517          	auipc	a0,0x1d
    800045d4:	de850513          	addi	a0,a0,-536 # 800213b8 <ftable>
    800045d8:	ffffc097          	auipc	ra,0xffffc
    800045dc:	6ac080e7          	jalr	1708(ra) # 80000c84 <release>
}
    800045e0:	8526                	mv	a0,s1
    800045e2:	60e2                	ld	ra,24(sp)
    800045e4:	6442                	ld	s0,16(sp)
    800045e6:	64a2                	ld	s1,8(sp)
    800045e8:	6105                	addi	sp,sp,32
    800045ea:	8082                	ret

00000000800045ec <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800045ec:	1101                	addi	sp,sp,-32
    800045ee:	ec06                	sd	ra,24(sp)
    800045f0:	e822                	sd	s0,16(sp)
    800045f2:	e426                	sd	s1,8(sp)
    800045f4:	1000                	addi	s0,sp,32
    800045f6:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800045f8:	0001d517          	auipc	a0,0x1d
    800045fc:	dc050513          	addi	a0,a0,-576 # 800213b8 <ftable>
    80004600:	ffffc097          	auipc	ra,0xffffc
    80004604:	5d0080e7          	jalr	1488(ra) # 80000bd0 <acquire>
  if(f->ref < 1)
    80004608:	40dc                	lw	a5,4(s1)
    8000460a:	02f05263          	blez	a5,8000462e <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000460e:	2785                	addiw	a5,a5,1
    80004610:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004612:	0001d517          	auipc	a0,0x1d
    80004616:	da650513          	addi	a0,a0,-602 # 800213b8 <ftable>
    8000461a:	ffffc097          	auipc	ra,0xffffc
    8000461e:	66a080e7          	jalr	1642(ra) # 80000c84 <release>
  return f;
}
    80004622:	8526                	mv	a0,s1
    80004624:	60e2                	ld	ra,24(sp)
    80004626:	6442                	ld	s0,16(sp)
    80004628:	64a2                	ld	s1,8(sp)
    8000462a:	6105                	addi	sp,sp,32
    8000462c:	8082                	ret
    panic("filedup");
    8000462e:	00004517          	auipc	a0,0x4
    80004632:	06250513          	addi	a0,a0,98 # 80008690 <syscalls+0x248>
    80004636:	ffffc097          	auipc	ra,0xffffc
    8000463a:	f04080e7          	jalr	-252(ra) # 8000053a <panic>

000000008000463e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000463e:	7139                	addi	sp,sp,-64
    80004640:	fc06                	sd	ra,56(sp)
    80004642:	f822                	sd	s0,48(sp)
    80004644:	f426                	sd	s1,40(sp)
    80004646:	f04a                	sd	s2,32(sp)
    80004648:	ec4e                	sd	s3,24(sp)
    8000464a:	e852                	sd	s4,16(sp)
    8000464c:	e456                	sd	s5,8(sp)
    8000464e:	0080                	addi	s0,sp,64
    80004650:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004652:	0001d517          	auipc	a0,0x1d
    80004656:	d6650513          	addi	a0,a0,-666 # 800213b8 <ftable>
    8000465a:	ffffc097          	auipc	ra,0xffffc
    8000465e:	576080e7          	jalr	1398(ra) # 80000bd0 <acquire>
  if(f->ref < 1)
    80004662:	40dc                	lw	a5,4(s1)
    80004664:	06f05163          	blez	a5,800046c6 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004668:	37fd                	addiw	a5,a5,-1
    8000466a:	0007871b          	sext.w	a4,a5
    8000466e:	c0dc                	sw	a5,4(s1)
    80004670:	06e04363          	bgtz	a4,800046d6 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004674:	0004a903          	lw	s2,0(s1)
    80004678:	0094ca83          	lbu	s5,9(s1)
    8000467c:	0104ba03          	ld	s4,16(s1)
    80004680:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004684:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004688:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000468c:	0001d517          	auipc	a0,0x1d
    80004690:	d2c50513          	addi	a0,a0,-724 # 800213b8 <ftable>
    80004694:	ffffc097          	auipc	ra,0xffffc
    80004698:	5f0080e7          	jalr	1520(ra) # 80000c84 <release>

  if(ff.type == FD_PIPE){
    8000469c:	4785                	li	a5,1
    8000469e:	04f90d63          	beq	s2,a5,800046f8 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800046a2:	3979                	addiw	s2,s2,-2
    800046a4:	4785                	li	a5,1
    800046a6:	0527e063          	bltu	a5,s2,800046e6 <fileclose+0xa8>
    begin_op();
    800046aa:	00000097          	auipc	ra,0x0
    800046ae:	acc080e7          	jalr	-1332(ra) # 80004176 <begin_op>
    iput(ff.ip);
    800046b2:	854e                	mv	a0,s3
    800046b4:	fffff097          	auipc	ra,0xfffff
    800046b8:	2a0080e7          	jalr	672(ra) # 80003954 <iput>
    end_op();
    800046bc:	00000097          	auipc	ra,0x0
    800046c0:	b38080e7          	jalr	-1224(ra) # 800041f4 <end_op>
    800046c4:	a00d                	j	800046e6 <fileclose+0xa8>
    panic("fileclose");
    800046c6:	00004517          	auipc	a0,0x4
    800046ca:	fd250513          	addi	a0,a0,-46 # 80008698 <syscalls+0x250>
    800046ce:	ffffc097          	auipc	ra,0xffffc
    800046d2:	e6c080e7          	jalr	-404(ra) # 8000053a <panic>
    release(&ftable.lock);
    800046d6:	0001d517          	auipc	a0,0x1d
    800046da:	ce250513          	addi	a0,a0,-798 # 800213b8 <ftable>
    800046de:	ffffc097          	auipc	ra,0xffffc
    800046e2:	5a6080e7          	jalr	1446(ra) # 80000c84 <release>
  }
}
    800046e6:	70e2                	ld	ra,56(sp)
    800046e8:	7442                	ld	s0,48(sp)
    800046ea:	74a2                	ld	s1,40(sp)
    800046ec:	7902                	ld	s2,32(sp)
    800046ee:	69e2                	ld	s3,24(sp)
    800046f0:	6a42                	ld	s4,16(sp)
    800046f2:	6aa2                	ld	s5,8(sp)
    800046f4:	6121                	addi	sp,sp,64
    800046f6:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800046f8:	85d6                	mv	a1,s5
    800046fa:	8552                	mv	a0,s4
    800046fc:	00000097          	auipc	ra,0x0
    80004700:	34c080e7          	jalr	844(ra) # 80004a48 <pipeclose>
    80004704:	b7cd                	j	800046e6 <fileclose+0xa8>

0000000080004706 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004706:	715d                	addi	sp,sp,-80
    80004708:	e486                	sd	ra,72(sp)
    8000470a:	e0a2                	sd	s0,64(sp)
    8000470c:	fc26                	sd	s1,56(sp)
    8000470e:	f84a                	sd	s2,48(sp)
    80004710:	f44e                	sd	s3,40(sp)
    80004712:	0880                	addi	s0,sp,80
    80004714:	84aa                	mv	s1,a0
    80004716:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004718:	ffffd097          	auipc	ra,0xffffd
    8000471c:	27e080e7          	jalr	638(ra) # 80001996 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004720:	409c                	lw	a5,0(s1)
    80004722:	37f9                	addiw	a5,a5,-2
    80004724:	4705                	li	a4,1
    80004726:	04f76763          	bltu	a4,a5,80004774 <filestat+0x6e>
    8000472a:	892a                	mv	s2,a0
    ilock(f->ip);
    8000472c:	6c88                	ld	a0,24(s1)
    8000472e:	fffff097          	auipc	ra,0xfffff
    80004732:	06c080e7          	jalr	108(ra) # 8000379a <ilock>
    stati(f->ip, &st);
    80004736:	fb840593          	addi	a1,s0,-72
    8000473a:	6c88                	ld	a0,24(s1)
    8000473c:	fffff097          	auipc	ra,0xfffff
    80004740:	2e8080e7          	jalr	744(ra) # 80003a24 <stati>
    iunlock(f->ip);
    80004744:	6c88                	ld	a0,24(s1)
    80004746:	fffff097          	auipc	ra,0xfffff
    8000474a:	116080e7          	jalr	278(ra) # 8000385c <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000474e:	46e1                	li	a3,24
    80004750:	fb840613          	addi	a2,s0,-72
    80004754:	85ce                	mv	a1,s3
    80004756:	05093503          	ld	a0,80(s2)
    8000475a:	ffffd097          	auipc	ra,0xffffd
    8000475e:	f00080e7          	jalr	-256(ra) # 8000165a <copyout>
    80004762:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004766:	60a6                	ld	ra,72(sp)
    80004768:	6406                	ld	s0,64(sp)
    8000476a:	74e2                	ld	s1,56(sp)
    8000476c:	7942                	ld	s2,48(sp)
    8000476e:	79a2                	ld	s3,40(sp)
    80004770:	6161                	addi	sp,sp,80
    80004772:	8082                	ret
  return -1;
    80004774:	557d                	li	a0,-1
    80004776:	bfc5                	j	80004766 <filestat+0x60>

0000000080004778 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004778:	7179                	addi	sp,sp,-48
    8000477a:	f406                	sd	ra,40(sp)
    8000477c:	f022                	sd	s0,32(sp)
    8000477e:	ec26                	sd	s1,24(sp)
    80004780:	e84a                	sd	s2,16(sp)
    80004782:	e44e                	sd	s3,8(sp)
    80004784:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004786:	00854783          	lbu	a5,8(a0)
    8000478a:	c3d5                	beqz	a5,8000482e <fileread+0xb6>
    8000478c:	84aa                	mv	s1,a0
    8000478e:	89ae                	mv	s3,a1
    80004790:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004792:	411c                	lw	a5,0(a0)
    80004794:	4705                	li	a4,1
    80004796:	04e78963          	beq	a5,a4,800047e8 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000479a:	470d                	li	a4,3
    8000479c:	04e78d63          	beq	a5,a4,800047f6 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800047a0:	4709                	li	a4,2
    800047a2:	06e79e63          	bne	a5,a4,8000481e <fileread+0xa6>
    ilock(f->ip);
    800047a6:	6d08                	ld	a0,24(a0)
    800047a8:	fffff097          	auipc	ra,0xfffff
    800047ac:	ff2080e7          	jalr	-14(ra) # 8000379a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800047b0:	874a                	mv	a4,s2
    800047b2:	5094                	lw	a3,32(s1)
    800047b4:	864e                	mv	a2,s3
    800047b6:	4585                	li	a1,1
    800047b8:	6c88                	ld	a0,24(s1)
    800047ba:	fffff097          	auipc	ra,0xfffff
    800047be:	294080e7          	jalr	660(ra) # 80003a4e <readi>
    800047c2:	892a                	mv	s2,a0
    800047c4:	00a05563          	blez	a0,800047ce <fileread+0x56>
      f->off += r;
    800047c8:	509c                	lw	a5,32(s1)
    800047ca:	9fa9                	addw	a5,a5,a0
    800047cc:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800047ce:	6c88                	ld	a0,24(s1)
    800047d0:	fffff097          	auipc	ra,0xfffff
    800047d4:	08c080e7          	jalr	140(ra) # 8000385c <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800047d8:	854a                	mv	a0,s2
    800047da:	70a2                	ld	ra,40(sp)
    800047dc:	7402                	ld	s0,32(sp)
    800047de:	64e2                	ld	s1,24(sp)
    800047e0:	6942                	ld	s2,16(sp)
    800047e2:	69a2                	ld	s3,8(sp)
    800047e4:	6145                	addi	sp,sp,48
    800047e6:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800047e8:	6908                	ld	a0,16(a0)
    800047ea:	00000097          	auipc	ra,0x0
    800047ee:	3c0080e7          	jalr	960(ra) # 80004baa <piperead>
    800047f2:	892a                	mv	s2,a0
    800047f4:	b7d5                	j	800047d8 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800047f6:	02451783          	lh	a5,36(a0)
    800047fa:	03079693          	slli	a3,a5,0x30
    800047fe:	92c1                	srli	a3,a3,0x30
    80004800:	4725                	li	a4,9
    80004802:	02d76863          	bltu	a4,a3,80004832 <fileread+0xba>
    80004806:	0792                	slli	a5,a5,0x4
    80004808:	0001d717          	auipc	a4,0x1d
    8000480c:	b1070713          	addi	a4,a4,-1264 # 80021318 <devsw>
    80004810:	97ba                	add	a5,a5,a4
    80004812:	639c                	ld	a5,0(a5)
    80004814:	c38d                	beqz	a5,80004836 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004816:	4505                	li	a0,1
    80004818:	9782                	jalr	a5
    8000481a:	892a                	mv	s2,a0
    8000481c:	bf75                	j	800047d8 <fileread+0x60>
    panic("fileread");
    8000481e:	00004517          	auipc	a0,0x4
    80004822:	e8a50513          	addi	a0,a0,-374 # 800086a8 <syscalls+0x260>
    80004826:	ffffc097          	auipc	ra,0xffffc
    8000482a:	d14080e7          	jalr	-748(ra) # 8000053a <panic>
    return -1;
    8000482e:	597d                	li	s2,-1
    80004830:	b765                	j	800047d8 <fileread+0x60>
      return -1;
    80004832:	597d                	li	s2,-1
    80004834:	b755                	j	800047d8 <fileread+0x60>
    80004836:	597d                	li	s2,-1
    80004838:	b745                	j	800047d8 <fileread+0x60>

000000008000483a <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    8000483a:	715d                	addi	sp,sp,-80
    8000483c:	e486                	sd	ra,72(sp)
    8000483e:	e0a2                	sd	s0,64(sp)
    80004840:	fc26                	sd	s1,56(sp)
    80004842:	f84a                	sd	s2,48(sp)
    80004844:	f44e                	sd	s3,40(sp)
    80004846:	f052                	sd	s4,32(sp)
    80004848:	ec56                	sd	s5,24(sp)
    8000484a:	e85a                	sd	s6,16(sp)
    8000484c:	e45e                	sd	s7,8(sp)
    8000484e:	e062                	sd	s8,0(sp)
    80004850:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004852:	00954783          	lbu	a5,9(a0)
    80004856:	10078663          	beqz	a5,80004962 <filewrite+0x128>
    8000485a:	892a                	mv	s2,a0
    8000485c:	8b2e                	mv	s6,a1
    8000485e:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004860:	411c                	lw	a5,0(a0)
    80004862:	4705                	li	a4,1
    80004864:	02e78263          	beq	a5,a4,80004888 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004868:	470d                	li	a4,3
    8000486a:	02e78663          	beq	a5,a4,80004896 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000486e:	4709                	li	a4,2
    80004870:	0ee79163          	bne	a5,a4,80004952 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004874:	0ac05d63          	blez	a2,8000492e <filewrite+0xf4>
    int i = 0;
    80004878:	4981                	li	s3,0
    8000487a:	6b85                	lui	s7,0x1
    8000487c:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004880:	6c05                	lui	s8,0x1
    80004882:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004886:	a861                	j	8000491e <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004888:	6908                	ld	a0,16(a0)
    8000488a:	00000097          	auipc	ra,0x0
    8000488e:	22e080e7          	jalr	558(ra) # 80004ab8 <pipewrite>
    80004892:	8a2a                	mv	s4,a0
    80004894:	a045                	j	80004934 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004896:	02451783          	lh	a5,36(a0)
    8000489a:	03079693          	slli	a3,a5,0x30
    8000489e:	92c1                	srli	a3,a3,0x30
    800048a0:	4725                	li	a4,9
    800048a2:	0cd76263          	bltu	a4,a3,80004966 <filewrite+0x12c>
    800048a6:	0792                	slli	a5,a5,0x4
    800048a8:	0001d717          	auipc	a4,0x1d
    800048ac:	a7070713          	addi	a4,a4,-1424 # 80021318 <devsw>
    800048b0:	97ba                	add	a5,a5,a4
    800048b2:	679c                	ld	a5,8(a5)
    800048b4:	cbdd                	beqz	a5,8000496a <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    800048b6:	4505                	li	a0,1
    800048b8:	9782                	jalr	a5
    800048ba:	8a2a                	mv	s4,a0
    800048bc:	a8a5                	j	80004934 <filewrite+0xfa>
    800048be:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800048c2:	00000097          	auipc	ra,0x0
    800048c6:	8b4080e7          	jalr	-1868(ra) # 80004176 <begin_op>
      ilock(f->ip);
    800048ca:	01893503          	ld	a0,24(s2)
    800048ce:	fffff097          	auipc	ra,0xfffff
    800048d2:	ecc080e7          	jalr	-308(ra) # 8000379a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800048d6:	8756                	mv	a4,s5
    800048d8:	02092683          	lw	a3,32(s2)
    800048dc:	01698633          	add	a2,s3,s6
    800048e0:	4585                	li	a1,1
    800048e2:	01893503          	ld	a0,24(s2)
    800048e6:	fffff097          	auipc	ra,0xfffff
    800048ea:	260080e7          	jalr	608(ra) # 80003b46 <writei>
    800048ee:	84aa                	mv	s1,a0
    800048f0:	00a05763          	blez	a0,800048fe <filewrite+0xc4>
        f->off += r;
    800048f4:	02092783          	lw	a5,32(s2)
    800048f8:	9fa9                	addw	a5,a5,a0
    800048fa:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800048fe:	01893503          	ld	a0,24(s2)
    80004902:	fffff097          	auipc	ra,0xfffff
    80004906:	f5a080e7          	jalr	-166(ra) # 8000385c <iunlock>
      end_op();
    8000490a:	00000097          	auipc	ra,0x0
    8000490e:	8ea080e7          	jalr	-1814(ra) # 800041f4 <end_op>

      if(r != n1){
    80004912:	009a9f63          	bne	s5,s1,80004930 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004916:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000491a:	0149db63          	bge	s3,s4,80004930 <filewrite+0xf6>
      int n1 = n - i;
    8000491e:	413a04bb          	subw	s1,s4,s3
    80004922:	0004879b          	sext.w	a5,s1
    80004926:	f8fbdce3          	bge	s7,a5,800048be <filewrite+0x84>
    8000492a:	84e2                	mv	s1,s8
    8000492c:	bf49                	j	800048be <filewrite+0x84>
    int i = 0;
    8000492e:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004930:	013a1f63          	bne	s4,s3,8000494e <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004934:	8552                	mv	a0,s4
    80004936:	60a6                	ld	ra,72(sp)
    80004938:	6406                	ld	s0,64(sp)
    8000493a:	74e2                	ld	s1,56(sp)
    8000493c:	7942                	ld	s2,48(sp)
    8000493e:	79a2                	ld	s3,40(sp)
    80004940:	7a02                	ld	s4,32(sp)
    80004942:	6ae2                	ld	s5,24(sp)
    80004944:	6b42                	ld	s6,16(sp)
    80004946:	6ba2                	ld	s7,8(sp)
    80004948:	6c02                	ld	s8,0(sp)
    8000494a:	6161                	addi	sp,sp,80
    8000494c:	8082                	ret
    ret = (i == n ? n : -1);
    8000494e:	5a7d                	li	s4,-1
    80004950:	b7d5                	j	80004934 <filewrite+0xfa>
    panic("filewrite");
    80004952:	00004517          	auipc	a0,0x4
    80004956:	d6650513          	addi	a0,a0,-666 # 800086b8 <syscalls+0x270>
    8000495a:	ffffc097          	auipc	ra,0xffffc
    8000495e:	be0080e7          	jalr	-1056(ra) # 8000053a <panic>
    return -1;
    80004962:	5a7d                	li	s4,-1
    80004964:	bfc1                	j	80004934 <filewrite+0xfa>
      return -1;
    80004966:	5a7d                	li	s4,-1
    80004968:	b7f1                	j	80004934 <filewrite+0xfa>
    8000496a:	5a7d                	li	s4,-1
    8000496c:	b7e1                	j	80004934 <filewrite+0xfa>

000000008000496e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000496e:	7179                	addi	sp,sp,-48
    80004970:	f406                	sd	ra,40(sp)
    80004972:	f022                	sd	s0,32(sp)
    80004974:	ec26                	sd	s1,24(sp)
    80004976:	e84a                	sd	s2,16(sp)
    80004978:	e44e                	sd	s3,8(sp)
    8000497a:	e052                	sd	s4,0(sp)
    8000497c:	1800                	addi	s0,sp,48
    8000497e:	84aa                	mv	s1,a0
    80004980:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004982:	0005b023          	sd	zero,0(a1)
    80004986:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000498a:	00000097          	auipc	ra,0x0
    8000498e:	bf8080e7          	jalr	-1032(ra) # 80004582 <filealloc>
    80004992:	e088                	sd	a0,0(s1)
    80004994:	c551                	beqz	a0,80004a20 <pipealloc+0xb2>
    80004996:	00000097          	auipc	ra,0x0
    8000499a:	bec080e7          	jalr	-1044(ra) # 80004582 <filealloc>
    8000499e:	00aa3023          	sd	a0,0(s4)
    800049a2:	c92d                	beqz	a0,80004a14 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800049a4:	ffffc097          	auipc	ra,0xffffc
    800049a8:	13c080e7          	jalr	316(ra) # 80000ae0 <kalloc>
    800049ac:	892a                	mv	s2,a0
    800049ae:	c125                	beqz	a0,80004a0e <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800049b0:	4985                	li	s3,1
    800049b2:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800049b6:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800049ba:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800049be:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800049c2:	00004597          	auipc	a1,0x4
    800049c6:	d0658593          	addi	a1,a1,-762 # 800086c8 <syscalls+0x280>
    800049ca:	ffffc097          	auipc	ra,0xffffc
    800049ce:	176080e7          	jalr	374(ra) # 80000b40 <initlock>
  (*f0)->type = FD_PIPE;
    800049d2:	609c                	ld	a5,0(s1)
    800049d4:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800049d8:	609c                	ld	a5,0(s1)
    800049da:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800049de:	609c                	ld	a5,0(s1)
    800049e0:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800049e4:	609c                	ld	a5,0(s1)
    800049e6:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800049ea:	000a3783          	ld	a5,0(s4)
    800049ee:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800049f2:	000a3783          	ld	a5,0(s4)
    800049f6:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800049fa:	000a3783          	ld	a5,0(s4)
    800049fe:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004a02:	000a3783          	ld	a5,0(s4)
    80004a06:	0127b823          	sd	s2,16(a5)
  return 0;
    80004a0a:	4501                	li	a0,0
    80004a0c:	a025                	j	80004a34 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004a0e:	6088                	ld	a0,0(s1)
    80004a10:	e501                	bnez	a0,80004a18 <pipealloc+0xaa>
    80004a12:	a039                	j	80004a20 <pipealloc+0xb2>
    80004a14:	6088                	ld	a0,0(s1)
    80004a16:	c51d                	beqz	a0,80004a44 <pipealloc+0xd6>
    fileclose(*f0);
    80004a18:	00000097          	auipc	ra,0x0
    80004a1c:	c26080e7          	jalr	-986(ra) # 8000463e <fileclose>
  if(*f1)
    80004a20:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004a24:	557d                	li	a0,-1
  if(*f1)
    80004a26:	c799                	beqz	a5,80004a34 <pipealloc+0xc6>
    fileclose(*f1);
    80004a28:	853e                	mv	a0,a5
    80004a2a:	00000097          	auipc	ra,0x0
    80004a2e:	c14080e7          	jalr	-1004(ra) # 8000463e <fileclose>
  return -1;
    80004a32:	557d                	li	a0,-1
}
    80004a34:	70a2                	ld	ra,40(sp)
    80004a36:	7402                	ld	s0,32(sp)
    80004a38:	64e2                	ld	s1,24(sp)
    80004a3a:	6942                	ld	s2,16(sp)
    80004a3c:	69a2                	ld	s3,8(sp)
    80004a3e:	6a02                	ld	s4,0(sp)
    80004a40:	6145                	addi	sp,sp,48
    80004a42:	8082                	ret
  return -1;
    80004a44:	557d                	li	a0,-1
    80004a46:	b7fd                	j	80004a34 <pipealloc+0xc6>

0000000080004a48 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004a48:	1101                	addi	sp,sp,-32
    80004a4a:	ec06                	sd	ra,24(sp)
    80004a4c:	e822                	sd	s0,16(sp)
    80004a4e:	e426                	sd	s1,8(sp)
    80004a50:	e04a                	sd	s2,0(sp)
    80004a52:	1000                	addi	s0,sp,32
    80004a54:	84aa                	mv	s1,a0
    80004a56:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004a58:	ffffc097          	auipc	ra,0xffffc
    80004a5c:	178080e7          	jalr	376(ra) # 80000bd0 <acquire>
  if(writable){
    80004a60:	02090d63          	beqz	s2,80004a9a <pipeclose+0x52>
    pi->writeopen = 0;
    80004a64:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004a68:	21848513          	addi	a0,s1,536
    80004a6c:	ffffd097          	auipc	ra,0xffffd
    80004a70:	77e080e7          	jalr	1918(ra) # 800021ea <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004a74:	2204b783          	ld	a5,544(s1)
    80004a78:	eb95                	bnez	a5,80004aac <pipeclose+0x64>
    release(&pi->lock);
    80004a7a:	8526                	mv	a0,s1
    80004a7c:	ffffc097          	auipc	ra,0xffffc
    80004a80:	208080e7          	jalr	520(ra) # 80000c84 <release>
    kfree((char*)pi);
    80004a84:	8526                	mv	a0,s1
    80004a86:	ffffc097          	auipc	ra,0xffffc
    80004a8a:	f5c080e7          	jalr	-164(ra) # 800009e2 <kfree>
  } else
    release(&pi->lock);
}
    80004a8e:	60e2                	ld	ra,24(sp)
    80004a90:	6442                	ld	s0,16(sp)
    80004a92:	64a2                	ld	s1,8(sp)
    80004a94:	6902                	ld	s2,0(sp)
    80004a96:	6105                	addi	sp,sp,32
    80004a98:	8082                	ret
    pi->readopen = 0;
    80004a9a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004a9e:	21c48513          	addi	a0,s1,540
    80004aa2:	ffffd097          	auipc	ra,0xffffd
    80004aa6:	748080e7          	jalr	1864(ra) # 800021ea <wakeup>
    80004aaa:	b7e9                	j	80004a74 <pipeclose+0x2c>
    release(&pi->lock);
    80004aac:	8526                	mv	a0,s1
    80004aae:	ffffc097          	auipc	ra,0xffffc
    80004ab2:	1d6080e7          	jalr	470(ra) # 80000c84 <release>
}
    80004ab6:	bfe1                	j	80004a8e <pipeclose+0x46>

0000000080004ab8 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004ab8:	711d                	addi	sp,sp,-96
    80004aba:	ec86                	sd	ra,88(sp)
    80004abc:	e8a2                	sd	s0,80(sp)
    80004abe:	e4a6                	sd	s1,72(sp)
    80004ac0:	e0ca                	sd	s2,64(sp)
    80004ac2:	fc4e                	sd	s3,56(sp)
    80004ac4:	f852                	sd	s4,48(sp)
    80004ac6:	f456                	sd	s5,40(sp)
    80004ac8:	f05a                	sd	s6,32(sp)
    80004aca:	ec5e                	sd	s7,24(sp)
    80004acc:	e862                	sd	s8,16(sp)
    80004ace:	1080                	addi	s0,sp,96
    80004ad0:	84aa                	mv	s1,a0
    80004ad2:	8aae                	mv	s5,a1
    80004ad4:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004ad6:	ffffd097          	auipc	ra,0xffffd
    80004ada:	ec0080e7          	jalr	-320(ra) # 80001996 <myproc>
    80004ade:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004ae0:	8526                	mv	a0,s1
    80004ae2:	ffffc097          	auipc	ra,0xffffc
    80004ae6:	0ee080e7          	jalr	238(ra) # 80000bd0 <acquire>
  while(i < n){
    80004aea:	0b405363          	blez	s4,80004b90 <pipewrite+0xd8>
  int i = 0;
    80004aee:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004af0:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004af2:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004af6:	21c48b93          	addi	s7,s1,540
    80004afa:	a089                	j	80004b3c <pipewrite+0x84>
      release(&pi->lock);
    80004afc:	8526                	mv	a0,s1
    80004afe:	ffffc097          	auipc	ra,0xffffc
    80004b02:	186080e7          	jalr	390(ra) # 80000c84 <release>
      return -1;
    80004b06:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004b08:	854a                	mv	a0,s2
    80004b0a:	60e6                	ld	ra,88(sp)
    80004b0c:	6446                	ld	s0,80(sp)
    80004b0e:	64a6                	ld	s1,72(sp)
    80004b10:	6906                	ld	s2,64(sp)
    80004b12:	79e2                	ld	s3,56(sp)
    80004b14:	7a42                	ld	s4,48(sp)
    80004b16:	7aa2                	ld	s5,40(sp)
    80004b18:	7b02                	ld	s6,32(sp)
    80004b1a:	6be2                	ld	s7,24(sp)
    80004b1c:	6c42                	ld	s8,16(sp)
    80004b1e:	6125                	addi	sp,sp,96
    80004b20:	8082                	ret
      wakeup(&pi->nread);
    80004b22:	8562                	mv	a0,s8
    80004b24:	ffffd097          	auipc	ra,0xffffd
    80004b28:	6c6080e7          	jalr	1734(ra) # 800021ea <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004b2c:	85a6                	mv	a1,s1
    80004b2e:	855e                	mv	a0,s7
    80004b30:	ffffd097          	auipc	ra,0xffffd
    80004b34:	52e080e7          	jalr	1326(ra) # 8000205e <sleep>
  while(i < n){
    80004b38:	05495d63          	bge	s2,s4,80004b92 <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    80004b3c:	2204a783          	lw	a5,544(s1)
    80004b40:	dfd5                	beqz	a5,80004afc <pipewrite+0x44>
    80004b42:	0289a783          	lw	a5,40(s3)
    80004b46:	fbdd                	bnez	a5,80004afc <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004b48:	2184a783          	lw	a5,536(s1)
    80004b4c:	21c4a703          	lw	a4,540(s1)
    80004b50:	2007879b          	addiw	a5,a5,512
    80004b54:	fcf707e3          	beq	a4,a5,80004b22 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004b58:	4685                	li	a3,1
    80004b5a:	01590633          	add	a2,s2,s5
    80004b5e:	faf40593          	addi	a1,s0,-81
    80004b62:	0509b503          	ld	a0,80(s3)
    80004b66:	ffffd097          	auipc	ra,0xffffd
    80004b6a:	b80080e7          	jalr	-1152(ra) # 800016e6 <copyin>
    80004b6e:	03650263          	beq	a0,s6,80004b92 <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004b72:	21c4a783          	lw	a5,540(s1)
    80004b76:	0017871b          	addiw	a4,a5,1
    80004b7a:	20e4ae23          	sw	a4,540(s1)
    80004b7e:	1ff7f793          	andi	a5,a5,511
    80004b82:	97a6                	add	a5,a5,s1
    80004b84:	faf44703          	lbu	a4,-81(s0)
    80004b88:	00e78c23          	sb	a4,24(a5)
      i++;
    80004b8c:	2905                	addiw	s2,s2,1
    80004b8e:	b76d                	j	80004b38 <pipewrite+0x80>
  int i = 0;
    80004b90:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004b92:	21848513          	addi	a0,s1,536
    80004b96:	ffffd097          	auipc	ra,0xffffd
    80004b9a:	654080e7          	jalr	1620(ra) # 800021ea <wakeup>
  release(&pi->lock);
    80004b9e:	8526                	mv	a0,s1
    80004ba0:	ffffc097          	auipc	ra,0xffffc
    80004ba4:	0e4080e7          	jalr	228(ra) # 80000c84 <release>
  return i;
    80004ba8:	b785                	j	80004b08 <pipewrite+0x50>

0000000080004baa <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004baa:	715d                	addi	sp,sp,-80
    80004bac:	e486                	sd	ra,72(sp)
    80004bae:	e0a2                	sd	s0,64(sp)
    80004bb0:	fc26                	sd	s1,56(sp)
    80004bb2:	f84a                	sd	s2,48(sp)
    80004bb4:	f44e                	sd	s3,40(sp)
    80004bb6:	f052                	sd	s4,32(sp)
    80004bb8:	ec56                	sd	s5,24(sp)
    80004bba:	e85a                	sd	s6,16(sp)
    80004bbc:	0880                	addi	s0,sp,80
    80004bbe:	84aa                	mv	s1,a0
    80004bc0:	892e                	mv	s2,a1
    80004bc2:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004bc4:	ffffd097          	auipc	ra,0xffffd
    80004bc8:	dd2080e7          	jalr	-558(ra) # 80001996 <myproc>
    80004bcc:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004bce:	8526                	mv	a0,s1
    80004bd0:	ffffc097          	auipc	ra,0xffffc
    80004bd4:	000080e7          	jalr	ra # 80000bd0 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004bd8:	2184a703          	lw	a4,536(s1)
    80004bdc:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004be0:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004be4:	02f71463          	bne	a4,a5,80004c0c <piperead+0x62>
    80004be8:	2244a783          	lw	a5,548(s1)
    80004bec:	c385                	beqz	a5,80004c0c <piperead+0x62>
    if(pr->killed){
    80004bee:	028a2783          	lw	a5,40(s4)
    80004bf2:	ebc9                	bnez	a5,80004c84 <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004bf4:	85a6                	mv	a1,s1
    80004bf6:	854e                	mv	a0,s3
    80004bf8:	ffffd097          	auipc	ra,0xffffd
    80004bfc:	466080e7          	jalr	1126(ra) # 8000205e <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c00:	2184a703          	lw	a4,536(s1)
    80004c04:	21c4a783          	lw	a5,540(s1)
    80004c08:	fef700e3          	beq	a4,a5,80004be8 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c0c:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004c0e:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c10:	05505463          	blez	s5,80004c58 <piperead+0xae>
    if(pi->nread == pi->nwrite)
    80004c14:	2184a783          	lw	a5,536(s1)
    80004c18:	21c4a703          	lw	a4,540(s1)
    80004c1c:	02f70e63          	beq	a4,a5,80004c58 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004c20:	0017871b          	addiw	a4,a5,1
    80004c24:	20e4ac23          	sw	a4,536(s1)
    80004c28:	1ff7f793          	andi	a5,a5,511
    80004c2c:	97a6                	add	a5,a5,s1
    80004c2e:	0187c783          	lbu	a5,24(a5)
    80004c32:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004c36:	4685                	li	a3,1
    80004c38:	fbf40613          	addi	a2,s0,-65
    80004c3c:	85ca                	mv	a1,s2
    80004c3e:	050a3503          	ld	a0,80(s4)
    80004c42:	ffffd097          	auipc	ra,0xffffd
    80004c46:	a18080e7          	jalr	-1512(ra) # 8000165a <copyout>
    80004c4a:	01650763          	beq	a0,s6,80004c58 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c4e:	2985                	addiw	s3,s3,1
    80004c50:	0905                	addi	s2,s2,1
    80004c52:	fd3a91e3          	bne	s5,s3,80004c14 <piperead+0x6a>
    80004c56:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004c58:	21c48513          	addi	a0,s1,540
    80004c5c:	ffffd097          	auipc	ra,0xffffd
    80004c60:	58e080e7          	jalr	1422(ra) # 800021ea <wakeup>
  release(&pi->lock);
    80004c64:	8526                	mv	a0,s1
    80004c66:	ffffc097          	auipc	ra,0xffffc
    80004c6a:	01e080e7          	jalr	30(ra) # 80000c84 <release>
  return i;
}
    80004c6e:	854e                	mv	a0,s3
    80004c70:	60a6                	ld	ra,72(sp)
    80004c72:	6406                	ld	s0,64(sp)
    80004c74:	74e2                	ld	s1,56(sp)
    80004c76:	7942                	ld	s2,48(sp)
    80004c78:	79a2                	ld	s3,40(sp)
    80004c7a:	7a02                	ld	s4,32(sp)
    80004c7c:	6ae2                	ld	s5,24(sp)
    80004c7e:	6b42                	ld	s6,16(sp)
    80004c80:	6161                	addi	sp,sp,80
    80004c82:	8082                	ret
      release(&pi->lock);
    80004c84:	8526                	mv	a0,s1
    80004c86:	ffffc097          	auipc	ra,0xffffc
    80004c8a:	ffe080e7          	jalr	-2(ra) # 80000c84 <release>
      return -1;
    80004c8e:	59fd                	li	s3,-1
    80004c90:	bff9                	j	80004c6e <piperead+0xc4>

0000000080004c92 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004c92:	de010113          	addi	sp,sp,-544
    80004c96:	20113c23          	sd	ra,536(sp)
    80004c9a:	20813823          	sd	s0,528(sp)
    80004c9e:	20913423          	sd	s1,520(sp)
    80004ca2:	21213023          	sd	s2,512(sp)
    80004ca6:	ffce                	sd	s3,504(sp)
    80004ca8:	fbd2                	sd	s4,496(sp)
    80004caa:	f7d6                	sd	s5,488(sp)
    80004cac:	f3da                	sd	s6,480(sp)
    80004cae:	efde                	sd	s7,472(sp)
    80004cb0:	ebe2                	sd	s8,464(sp)
    80004cb2:	e7e6                	sd	s9,456(sp)
    80004cb4:	e3ea                	sd	s10,448(sp)
    80004cb6:	ff6e                	sd	s11,440(sp)
    80004cb8:	1400                	addi	s0,sp,544
    80004cba:	892a                	mv	s2,a0
    80004cbc:	dea43423          	sd	a0,-536(s0)
    80004cc0:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004cc4:	ffffd097          	auipc	ra,0xffffd
    80004cc8:	cd2080e7          	jalr	-814(ra) # 80001996 <myproc>
    80004ccc:	84aa                	mv	s1,a0

  begin_op();
    80004cce:	fffff097          	auipc	ra,0xfffff
    80004cd2:	4a8080e7          	jalr	1192(ra) # 80004176 <begin_op>

  if((ip = namei(path)) == 0){
    80004cd6:	854a                	mv	a0,s2
    80004cd8:	fffff097          	auipc	ra,0xfffff
    80004cdc:	27e080e7          	jalr	638(ra) # 80003f56 <namei>
    80004ce0:	c93d                	beqz	a0,80004d56 <exec+0xc4>
    80004ce2:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004ce4:	fffff097          	auipc	ra,0xfffff
    80004ce8:	ab6080e7          	jalr	-1354(ra) # 8000379a <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004cec:	04000713          	li	a4,64
    80004cf0:	4681                	li	a3,0
    80004cf2:	e5040613          	addi	a2,s0,-432
    80004cf6:	4581                	li	a1,0
    80004cf8:	8556                	mv	a0,s5
    80004cfa:	fffff097          	auipc	ra,0xfffff
    80004cfe:	d54080e7          	jalr	-684(ra) # 80003a4e <readi>
    80004d02:	04000793          	li	a5,64
    80004d06:	00f51a63          	bne	a0,a5,80004d1a <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004d0a:	e5042703          	lw	a4,-432(s0)
    80004d0e:	464c47b7          	lui	a5,0x464c4
    80004d12:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004d16:	04f70663          	beq	a4,a5,80004d62 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004d1a:	8556                	mv	a0,s5
    80004d1c:	fffff097          	auipc	ra,0xfffff
    80004d20:	ce0080e7          	jalr	-800(ra) # 800039fc <iunlockput>
    end_op();
    80004d24:	fffff097          	auipc	ra,0xfffff
    80004d28:	4d0080e7          	jalr	1232(ra) # 800041f4 <end_op>
  }
  return -1;
    80004d2c:	557d                	li	a0,-1
}
    80004d2e:	21813083          	ld	ra,536(sp)
    80004d32:	21013403          	ld	s0,528(sp)
    80004d36:	20813483          	ld	s1,520(sp)
    80004d3a:	20013903          	ld	s2,512(sp)
    80004d3e:	79fe                	ld	s3,504(sp)
    80004d40:	7a5e                	ld	s4,496(sp)
    80004d42:	7abe                	ld	s5,488(sp)
    80004d44:	7b1e                	ld	s6,480(sp)
    80004d46:	6bfe                	ld	s7,472(sp)
    80004d48:	6c5e                	ld	s8,464(sp)
    80004d4a:	6cbe                	ld	s9,456(sp)
    80004d4c:	6d1e                	ld	s10,448(sp)
    80004d4e:	7dfa                	ld	s11,440(sp)
    80004d50:	22010113          	addi	sp,sp,544
    80004d54:	8082                	ret
    end_op();
    80004d56:	fffff097          	auipc	ra,0xfffff
    80004d5a:	49e080e7          	jalr	1182(ra) # 800041f4 <end_op>
    return -1;
    80004d5e:	557d                	li	a0,-1
    80004d60:	b7f9                	j	80004d2e <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004d62:	8526                	mv	a0,s1
    80004d64:	ffffd097          	auipc	ra,0xffffd
    80004d68:	cf6080e7          	jalr	-778(ra) # 80001a5a <proc_pagetable>
    80004d6c:	8b2a                	mv	s6,a0
    80004d6e:	d555                	beqz	a0,80004d1a <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d70:	e7042783          	lw	a5,-400(s0)
    80004d74:	e8845703          	lhu	a4,-376(s0)
    80004d78:	c735                	beqz	a4,80004de4 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004d7a:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d7c:	e0043423          	sd	zero,-504(s0)
    if((ph.vaddr % PGSIZE) != 0)
    80004d80:	6a05                	lui	s4,0x1
    80004d82:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004d86:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004d8a:	6d85                	lui	s11,0x1
    80004d8c:	7d7d                	lui	s10,0xfffff
    80004d8e:	ac1d                	j	80004fc4 <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004d90:	00004517          	auipc	a0,0x4
    80004d94:	94050513          	addi	a0,a0,-1728 # 800086d0 <syscalls+0x288>
    80004d98:	ffffb097          	auipc	ra,0xffffb
    80004d9c:	7a2080e7          	jalr	1954(ra) # 8000053a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004da0:	874a                	mv	a4,s2
    80004da2:	009c86bb          	addw	a3,s9,s1
    80004da6:	4581                	li	a1,0
    80004da8:	8556                	mv	a0,s5
    80004daa:	fffff097          	auipc	ra,0xfffff
    80004dae:	ca4080e7          	jalr	-860(ra) # 80003a4e <readi>
    80004db2:	2501                	sext.w	a0,a0
    80004db4:	1aa91863          	bne	s2,a0,80004f64 <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    80004db8:	009d84bb          	addw	s1,s11,s1
    80004dbc:	013d09bb          	addw	s3,s10,s3
    80004dc0:	1f74f263          	bgeu	s1,s7,80004fa4 <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    80004dc4:	02049593          	slli	a1,s1,0x20
    80004dc8:	9181                	srli	a1,a1,0x20
    80004dca:	95e2                	add	a1,a1,s8
    80004dcc:	855a                	mv	a0,s6
    80004dce:	ffffc097          	auipc	ra,0xffffc
    80004dd2:	284080e7          	jalr	644(ra) # 80001052 <walkaddr>
    80004dd6:	862a                	mv	a2,a0
    if(pa == 0)
    80004dd8:	dd45                	beqz	a0,80004d90 <exec+0xfe>
      n = PGSIZE;
    80004dda:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004ddc:	fd49f2e3          	bgeu	s3,s4,80004da0 <exec+0x10e>
      n = sz - i;
    80004de0:	894e                	mv	s2,s3
    80004de2:	bf7d                	j	80004da0 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004de4:	4481                	li	s1,0
  iunlockput(ip);
    80004de6:	8556                	mv	a0,s5
    80004de8:	fffff097          	auipc	ra,0xfffff
    80004dec:	c14080e7          	jalr	-1004(ra) # 800039fc <iunlockput>
  end_op();
    80004df0:	fffff097          	auipc	ra,0xfffff
    80004df4:	404080e7          	jalr	1028(ra) # 800041f4 <end_op>
  p = myproc();
    80004df8:	ffffd097          	auipc	ra,0xffffd
    80004dfc:	b9e080e7          	jalr	-1122(ra) # 80001996 <myproc>
    80004e00:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004e02:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004e06:	6785                	lui	a5,0x1
    80004e08:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80004e0a:	97a6                	add	a5,a5,s1
    80004e0c:	777d                	lui	a4,0xfffff
    80004e0e:	8ff9                	and	a5,a5,a4
    80004e10:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004e14:	6609                	lui	a2,0x2
    80004e16:	963e                	add	a2,a2,a5
    80004e18:	85be                	mv	a1,a5
    80004e1a:	855a                	mv	a0,s6
    80004e1c:	ffffc097          	auipc	ra,0xffffc
    80004e20:	5ea080e7          	jalr	1514(ra) # 80001406 <uvmalloc>
    80004e24:	8c2a                	mv	s8,a0
  ip = 0;
    80004e26:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004e28:	12050e63          	beqz	a0,80004f64 <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004e2c:	75f9                	lui	a1,0xffffe
    80004e2e:	95aa                	add	a1,a1,a0
    80004e30:	855a                	mv	a0,s6
    80004e32:	ffffc097          	auipc	ra,0xffffc
    80004e36:	7f6080e7          	jalr	2038(ra) # 80001628 <uvmclear>
  stackbase = sp - PGSIZE;
    80004e3a:	7afd                	lui	s5,0xfffff
    80004e3c:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004e3e:	df043783          	ld	a5,-528(s0)
    80004e42:	6388                	ld	a0,0(a5)
    80004e44:	c925                	beqz	a0,80004eb4 <exec+0x222>
    80004e46:	e9040993          	addi	s3,s0,-368
    80004e4a:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004e4e:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004e50:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004e52:	ffffc097          	auipc	ra,0xffffc
    80004e56:	ff6080e7          	jalr	-10(ra) # 80000e48 <strlen>
    80004e5a:	0015079b          	addiw	a5,a0,1
    80004e5e:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004e62:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004e66:	13596363          	bltu	s2,s5,80004f8c <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004e6a:	df043d83          	ld	s11,-528(s0)
    80004e6e:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004e72:	8552                	mv	a0,s4
    80004e74:	ffffc097          	auipc	ra,0xffffc
    80004e78:	fd4080e7          	jalr	-44(ra) # 80000e48 <strlen>
    80004e7c:	0015069b          	addiw	a3,a0,1
    80004e80:	8652                	mv	a2,s4
    80004e82:	85ca                	mv	a1,s2
    80004e84:	855a                	mv	a0,s6
    80004e86:	ffffc097          	auipc	ra,0xffffc
    80004e8a:	7d4080e7          	jalr	2004(ra) # 8000165a <copyout>
    80004e8e:	10054363          	bltz	a0,80004f94 <exec+0x302>
    ustack[argc] = sp;
    80004e92:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004e96:	0485                	addi	s1,s1,1
    80004e98:	008d8793          	addi	a5,s11,8
    80004e9c:	def43823          	sd	a5,-528(s0)
    80004ea0:	008db503          	ld	a0,8(s11)
    80004ea4:	c911                	beqz	a0,80004eb8 <exec+0x226>
    if(argc >= MAXARG)
    80004ea6:	09a1                	addi	s3,s3,8
    80004ea8:	fb3c95e3          	bne	s9,s3,80004e52 <exec+0x1c0>
  sz = sz1;
    80004eac:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004eb0:	4a81                	li	s5,0
    80004eb2:	a84d                	j	80004f64 <exec+0x2d2>
  sp = sz;
    80004eb4:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004eb6:	4481                	li	s1,0
  ustack[argc] = 0;
    80004eb8:	00349793          	slli	a5,s1,0x3
    80004ebc:	f9078793          	addi	a5,a5,-112
    80004ec0:	97a2                	add	a5,a5,s0
    80004ec2:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004ec6:	00148693          	addi	a3,s1,1
    80004eca:	068e                	slli	a3,a3,0x3
    80004ecc:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004ed0:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004ed4:	01597663          	bgeu	s2,s5,80004ee0 <exec+0x24e>
  sz = sz1;
    80004ed8:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004edc:	4a81                	li	s5,0
    80004ede:	a059                	j	80004f64 <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004ee0:	e9040613          	addi	a2,s0,-368
    80004ee4:	85ca                	mv	a1,s2
    80004ee6:	855a                	mv	a0,s6
    80004ee8:	ffffc097          	auipc	ra,0xffffc
    80004eec:	772080e7          	jalr	1906(ra) # 8000165a <copyout>
    80004ef0:	0a054663          	bltz	a0,80004f9c <exec+0x30a>
  p->trapframe->a1 = sp;
    80004ef4:	058bb783          	ld	a5,88(s7)
    80004ef8:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004efc:	de843783          	ld	a5,-536(s0)
    80004f00:	0007c703          	lbu	a4,0(a5)
    80004f04:	cf11                	beqz	a4,80004f20 <exec+0x28e>
    80004f06:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004f08:	02f00693          	li	a3,47
    80004f0c:	a039                	j	80004f1a <exec+0x288>
      last = s+1;
    80004f0e:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80004f12:	0785                	addi	a5,a5,1
    80004f14:	fff7c703          	lbu	a4,-1(a5)
    80004f18:	c701                	beqz	a4,80004f20 <exec+0x28e>
    if(*s == '/')
    80004f1a:	fed71ce3          	bne	a4,a3,80004f12 <exec+0x280>
    80004f1e:	bfc5                	j	80004f0e <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    80004f20:	4641                	li	a2,16
    80004f22:	de843583          	ld	a1,-536(s0)
    80004f26:	158b8513          	addi	a0,s7,344
    80004f2a:	ffffc097          	auipc	ra,0xffffc
    80004f2e:	eec080e7          	jalr	-276(ra) # 80000e16 <safestrcpy>
  oldpagetable = p->pagetable;
    80004f32:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80004f36:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004f3a:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004f3e:	058bb783          	ld	a5,88(s7)
    80004f42:	e6843703          	ld	a4,-408(s0)
    80004f46:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004f48:	058bb783          	ld	a5,88(s7)
    80004f4c:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004f50:	85ea                	mv	a1,s10
    80004f52:	ffffd097          	auipc	ra,0xffffd
    80004f56:	ba4080e7          	jalr	-1116(ra) # 80001af6 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004f5a:	0004851b          	sext.w	a0,s1
    80004f5e:	bbc1                	j	80004d2e <exec+0x9c>
    80004f60:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004f64:	df843583          	ld	a1,-520(s0)
    80004f68:	855a                	mv	a0,s6
    80004f6a:	ffffd097          	auipc	ra,0xffffd
    80004f6e:	b8c080e7          	jalr	-1140(ra) # 80001af6 <proc_freepagetable>
  if(ip){
    80004f72:	da0a94e3          	bnez	s5,80004d1a <exec+0x88>
  return -1;
    80004f76:	557d                	li	a0,-1
    80004f78:	bb5d                	j	80004d2e <exec+0x9c>
    80004f7a:	de943c23          	sd	s1,-520(s0)
    80004f7e:	b7dd                	j	80004f64 <exec+0x2d2>
    80004f80:	de943c23          	sd	s1,-520(s0)
    80004f84:	b7c5                	j	80004f64 <exec+0x2d2>
    80004f86:	de943c23          	sd	s1,-520(s0)
    80004f8a:	bfe9                	j	80004f64 <exec+0x2d2>
  sz = sz1;
    80004f8c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004f90:	4a81                	li	s5,0
    80004f92:	bfc9                	j	80004f64 <exec+0x2d2>
  sz = sz1;
    80004f94:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004f98:	4a81                	li	s5,0
    80004f9a:	b7e9                	j	80004f64 <exec+0x2d2>
  sz = sz1;
    80004f9c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004fa0:	4a81                	li	s5,0
    80004fa2:	b7c9                	j	80004f64 <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004fa4:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004fa8:	e0843783          	ld	a5,-504(s0)
    80004fac:	0017869b          	addiw	a3,a5,1
    80004fb0:	e0d43423          	sd	a3,-504(s0)
    80004fb4:	e0043783          	ld	a5,-512(s0)
    80004fb8:	0387879b          	addiw	a5,a5,56
    80004fbc:	e8845703          	lhu	a4,-376(s0)
    80004fc0:	e2e6d3e3          	bge	a3,a4,80004de6 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004fc4:	2781                	sext.w	a5,a5
    80004fc6:	e0f43023          	sd	a5,-512(s0)
    80004fca:	03800713          	li	a4,56
    80004fce:	86be                	mv	a3,a5
    80004fd0:	e1840613          	addi	a2,s0,-488
    80004fd4:	4581                	li	a1,0
    80004fd6:	8556                	mv	a0,s5
    80004fd8:	fffff097          	auipc	ra,0xfffff
    80004fdc:	a76080e7          	jalr	-1418(ra) # 80003a4e <readi>
    80004fe0:	03800793          	li	a5,56
    80004fe4:	f6f51ee3          	bne	a0,a5,80004f60 <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    80004fe8:	e1842783          	lw	a5,-488(s0)
    80004fec:	4705                	li	a4,1
    80004fee:	fae79de3          	bne	a5,a4,80004fa8 <exec+0x316>
    if(ph.memsz < ph.filesz)
    80004ff2:	e4043603          	ld	a2,-448(s0)
    80004ff6:	e3843783          	ld	a5,-456(s0)
    80004ffa:	f8f660e3          	bltu	a2,a5,80004f7a <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004ffe:	e2843783          	ld	a5,-472(s0)
    80005002:	963e                	add	a2,a2,a5
    80005004:	f6f66ee3          	bltu	a2,a5,80004f80 <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005008:	85a6                	mv	a1,s1
    8000500a:	855a                	mv	a0,s6
    8000500c:	ffffc097          	auipc	ra,0xffffc
    80005010:	3fa080e7          	jalr	1018(ra) # 80001406 <uvmalloc>
    80005014:	dea43c23          	sd	a0,-520(s0)
    80005018:	d53d                	beqz	a0,80004f86 <exec+0x2f4>
    if((ph.vaddr % PGSIZE) != 0)
    8000501a:	e2843c03          	ld	s8,-472(s0)
    8000501e:	de043783          	ld	a5,-544(s0)
    80005022:	00fc77b3          	and	a5,s8,a5
    80005026:	ff9d                	bnez	a5,80004f64 <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005028:	e2042c83          	lw	s9,-480(s0)
    8000502c:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005030:	f60b8ae3          	beqz	s7,80004fa4 <exec+0x312>
    80005034:	89de                	mv	s3,s7
    80005036:	4481                	li	s1,0
    80005038:	b371                	j	80004dc4 <exec+0x132>

000000008000503a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000503a:	7179                	addi	sp,sp,-48
    8000503c:	f406                	sd	ra,40(sp)
    8000503e:	f022                	sd	s0,32(sp)
    80005040:	ec26                	sd	s1,24(sp)
    80005042:	e84a                	sd	s2,16(sp)
    80005044:	1800                	addi	s0,sp,48
    80005046:	892e                	mv	s2,a1
    80005048:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    8000504a:	fdc40593          	addi	a1,s0,-36
    8000504e:	ffffe097          	auipc	ra,0xffffe
    80005052:	b8e080e7          	jalr	-1138(ra) # 80002bdc <argint>
    80005056:	04054063          	bltz	a0,80005096 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000505a:	fdc42703          	lw	a4,-36(s0)
    8000505e:	47bd                	li	a5,15
    80005060:	02e7ed63          	bltu	a5,a4,8000509a <argfd+0x60>
    80005064:	ffffd097          	auipc	ra,0xffffd
    80005068:	932080e7          	jalr	-1742(ra) # 80001996 <myproc>
    8000506c:	fdc42703          	lw	a4,-36(s0)
    80005070:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffd901a>
    80005074:	078e                	slli	a5,a5,0x3
    80005076:	953e                	add	a0,a0,a5
    80005078:	611c                	ld	a5,0(a0)
    8000507a:	c395                	beqz	a5,8000509e <argfd+0x64>
    return -1;
  if(pfd)
    8000507c:	00090463          	beqz	s2,80005084 <argfd+0x4a>
    *pfd = fd;
    80005080:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005084:	4501                	li	a0,0
  if(pf)
    80005086:	c091                	beqz	s1,8000508a <argfd+0x50>
    *pf = f;
    80005088:	e09c                	sd	a5,0(s1)
}
    8000508a:	70a2                	ld	ra,40(sp)
    8000508c:	7402                	ld	s0,32(sp)
    8000508e:	64e2                	ld	s1,24(sp)
    80005090:	6942                	ld	s2,16(sp)
    80005092:	6145                	addi	sp,sp,48
    80005094:	8082                	ret
    return -1;
    80005096:	557d                	li	a0,-1
    80005098:	bfcd                	j	8000508a <argfd+0x50>
    return -1;
    8000509a:	557d                	li	a0,-1
    8000509c:	b7fd                	j	8000508a <argfd+0x50>
    8000509e:	557d                	li	a0,-1
    800050a0:	b7ed                	j	8000508a <argfd+0x50>

00000000800050a2 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800050a2:	1101                	addi	sp,sp,-32
    800050a4:	ec06                	sd	ra,24(sp)
    800050a6:	e822                	sd	s0,16(sp)
    800050a8:	e426                	sd	s1,8(sp)
    800050aa:	1000                	addi	s0,sp,32
    800050ac:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800050ae:	ffffd097          	auipc	ra,0xffffd
    800050b2:	8e8080e7          	jalr	-1816(ra) # 80001996 <myproc>
    800050b6:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800050b8:	0d050793          	addi	a5,a0,208
    800050bc:	4501                	li	a0,0
    800050be:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800050c0:	6398                	ld	a4,0(a5)
    800050c2:	cb19                	beqz	a4,800050d8 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800050c4:	2505                	addiw	a0,a0,1
    800050c6:	07a1                	addi	a5,a5,8
    800050c8:	fed51ce3          	bne	a0,a3,800050c0 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800050cc:	557d                	li	a0,-1
}
    800050ce:	60e2                	ld	ra,24(sp)
    800050d0:	6442                	ld	s0,16(sp)
    800050d2:	64a2                	ld	s1,8(sp)
    800050d4:	6105                	addi	sp,sp,32
    800050d6:	8082                	ret
      p->ofile[fd] = f;
    800050d8:	01a50793          	addi	a5,a0,26
    800050dc:	078e                	slli	a5,a5,0x3
    800050de:	963e                	add	a2,a2,a5
    800050e0:	e204                	sd	s1,0(a2)
      return fd;
    800050e2:	b7f5                	j	800050ce <fdalloc+0x2c>

00000000800050e4 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800050e4:	715d                	addi	sp,sp,-80
    800050e6:	e486                	sd	ra,72(sp)
    800050e8:	e0a2                	sd	s0,64(sp)
    800050ea:	fc26                	sd	s1,56(sp)
    800050ec:	f84a                	sd	s2,48(sp)
    800050ee:	f44e                	sd	s3,40(sp)
    800050f0:	f052                	sd	s4,32(sp)
    800050f2:	ec56                	sd	s5,24(sp)
    800050f4:	0880                	addi	s0,sp,80
    800050f6:	89ae                	mv	s3,a1
    800050f8:	8ab2                	mv	s5,a2
    800050fa:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800050fc:	fb040593          	addi	a1,s0,-80
    80005100:	fffff097          	auipc	ra,0xfffff
    80005104:	e74080e7          	jalr	-396(ra) # 80003f74 <nameiparent>
    80005108:	892a                	mv	s2,a0
    8000510a:	12050e63          	beqz	a0,80005246 <create+0x162>
    return 0;

  ilock(dp);
    8000510e:	ffffe097          	auipc	ra,0xffffe
    80005112:	68c080e7          	jalr	1676(ra) # 8000379a <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005116:	4601                	li	a2,0
    80005118:	fb040593          	addi	a1,s0,-80
    8000511c:	854a                	mv	a0,s2
    8000511e:	fffff097          	auipc	ra,0xfffff
    80005122:	b60080e7          	jalr	-1184(ra) # 80003c7e <dirlookup>
    80005126:	84aa                	mv	s1,a0
    80005128:	c921                	beqz	a0,80005178 <create+0x94>
    iunlockput(dp);
    8000512a:	854a                	mv	a0,s2
    8000512c:	fffff097          	auipc	ra,0xfffff
    80005130:	8d0080e7          	jalr	-1840(ra) # 800039fc <iunlockput>
    ilock(ip);
    80005134:	8526                	mv	a0,s1
    80005136:	ffffe097          	auipc	ra,0xffffe
    8000513a:	664080e7          	jalr	1636(ra) # 8000379a <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000513e:	2981                	sext.w	s3,s3
    80005140:	4789                	li	a5,2
    80005142:	02f99463          	bne	s3,a5,8000516a <create+0x86>
    80005146:	0444d783          	lhu	a5,68(s1)
    8000514a:	37f9                	addiw	a5,a5,-2
    8000514c:	17c2                	slli	a5,a5,0x30
    8000514e:	93c1                	srli	a5,a5,0x30
    80005150:	4705                	li	a4,1
    80005152:	00f76c63          	bltu	a4,a5,8000516a <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005156:	8526                	mv	a0,s1
    80005158:	60a6                	ld	ra,72(sp)
    8000515a:	6406                	ld	s0,64(sp)
    8000515c:	74e2                	ld	s1,56(sp)
    8000515e:	7942                	ld	s2,48(sp)
    80005160:	79a2                	ld	s3,40(sp)
    80005162:	7a02                	ld	s4,32(sp)
    80005164:	6ae2                	ld	s5,24(sp)
    80005166:	6161                	addi	sp,sp,80
    80005168:	8082                	ret
    iunlockput(ip);
    8000516a:	8526                	mv	a0,s1
    8000516c:	fffff097          	auipc	ra,0xfffff
    80005170:	890080e7          	jalr	-1904(ra) # 800039fc <iunlockput>
    return 0;
    80005174:	4481                	li	s1,0
    80005176:	b7c5                	j	80005156 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005178:	85ce                	mv	a1,s3
    8000517a:	00092503          	lw	a0,0(s2)
    8000517e:	ffffe097          	auipc	ra,0xffffe
    80005182:	482080e7          	jalr	1154(ra) # 80003600 <ialloc>
    80005186:	84aa                	mv	s1,a0
    80005188:	c521                	beqz	a0,800051d0 <create+0xec>
  ilock(ip);
    8000518a:	ffffe097          	auipc	ra,0xffffe
    8000518e:	610080e7          	jalr	1552(ra) # 8000379a <ilock>
  ip->major = major;
    80005192:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005196:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    8000519a:	4a05                	li	s4,1
    8000519c:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    800051a0:	8526                	mv	a0,s1
    800051a2:	ffffe097          	auipc	ra,0xffffe
    800051a6:	52c080e7          	jalr	1324(ra) # 800036ce <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800051aa:	2981                	sext.w	s3,s3
    800051ac:	03498a63          	beq	s3,s4,800051e0 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800051b0:	40d0                	lw	a2,4(s1)
    800051b2:	fb040593          	addi	a1,s0,-80
    800051b6:	854a                	mv	a0,s2
    800051b8:	fffff097          	auipc	ra,0xfffff
    800051bc:	cdc080e7          	jalr	-804(ra) # 80003e94 <dirlink>
    800051c0:	06054b63          	bltz	a0,80005236 <create+0x152>
  iunlockput(dp);
    800051c4:	854a                	mv	a0,s2
    800051c6:	fffff097          	auipc	ra,0xfffff
    800051ca:	836080e7          	jalr	-1994(ra) # 800039fc <iunlockput>
  return ip;
    800051ce:	b761                	j	80005156 <create+0x72>
    panic("create: ialloc");
    800051d0:	00003517          	auipc	a0,0x3
    800051d4:	52050513          	addi	a0,a0,1312 # 800086f0 <syscalls+0x2a8>
    800051d8:	ffffb097          	auipc	ra,0xffffb
    800051dc:	362080e7          	jalr	866(ra) # 8000053a <panic>
    dp->nlink++;  // for ".."
    800051e0:	04a95783          	lhu	a5,74(s2)
    800051e4:	2785                	addiw	a5,a5,1
    800051e6:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800051ea:	854a                	mv	a0,s2
    800051ec:	ffffe097          	auipc	ra,0xffffe
    800051f0:	4e2080e7          	jalr	1250(ra) # 800036ce <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800051f4:	40d0                	lw	a2,4(s1)
    800051f6:	00003597          	auipc	a1,0x3
    800051fa:	50a58593          	addi	a1,a1,1290 # 80008700 <syscalls+0x2b8>
    800051fe:	8526                	mv	a0,s1
    80005200:	fffff097          	auipc	ra,0xfffff
    80005204:	c94080e7          	jalr	-876(ra) # 80003e94 <dirlink>
    80005208:	00054f63          	bltz	a0,80005226 <create+0x142>
    8000520c:	00492603          	lw	a2,4(s2)
    80005210:	00003597          	auipc	a1,0x3
    80005214:	4f858593          	addi	a1,a1,1272 # 80008708 <syscalls+0x2c0>
    80005218:	8526                	mv	a0,s1
    8000521a:	fffff097          	auipc	ra,0xfffff
    8000521e:	c7a080e7          	jalr	-902(ra) # 80003e94 <dirlink>
    80005222:	f80557e3          	bgez	a0,800051b0 <create+0xcc>
      panic("create dots");
    80005226:	00003517          	auipc	a0,0x3
    8000522a:	4ea50513          	addi	a0,a0,1258 # 80008710 <syscalls+0x2c8>
    8000522e:	ffffb097          	auipc	ra,0xffffb
    80005232:	30c080e7          	jalr	780(ra) # 8000053a <panic>
    panic("create: dirlink");
    80005236:	00003517          	auipc	a0,0x3
    8000523a:	4ea50513          	addi	a0,a0,1258 # 80008720 <syscalls+0x2d8>
    8000523e:	ffffb097          	auipc	ra,0xffffb
    80005242:	2fc080e7          	jalr	764(ra) # 8000053a <panic>
    return 0;
    80005246:	84aa                	mv	s1,a0
    80005248:	b739                	j	80005156 <create+0x72>

000000008000524a <sys_dup>:
{
    8000524a:	7179                	addi	sp,sp,-48
    8000524c:	f406                	sd	ra,40(sp)
    8000524e:	f022                	sd	s0,32(sp)
    80005250:	ec26                	sd	s1,24(sp)
    80005252:	e84a                	sd	s2,16(sp)
    80005254:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005256:	fd840613          	addi	a2,s0,-40
    8000525a:	4581                	li	a1,0
    8000525c:	4501                	li	a0,0
    8000525e:	00000097          	auipc	ra,0x0
    80005262:	ddc080e7          	jalr	-548(ra) # 8000503a <argfd>
    return -1;
    80005266:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005268:	02054363          	bltz	a0,8000528e <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    8000526c:	fd843903          	ld	s2,-40(s0)
    80005270:	854a                	mv	a0,s2
    80005272:	00000097          	auipc	ra,0x0
    80005276:	e30080e7          	jalr	-464(ra) # 800050a2 <fdalloc>
    8000527a:	84aa                	mv	s1,a0
    return -1;
    8000527c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000527e:	00054863          	bltz	a0,8000528e <sys_dup+0x44>
  filedup(f);
    80005282:	854a                	mv	a0,s2
    80005284:	fffff097          	auipc	ra,0xfffff
    80005288:	368080e7          	jalr	872(ra) # 800045ec <filedup>
  return fd;
    8000528c:	87a6                	mv	a5,s1
}
    8000528e:	853e                	mv	a0,a5
    80005290:	70a2                	ld	ra,40(sp)
    80005292:	7402                	ld	s0,32(sp)
    80005294:	64e2                	ld	s1,24(sp)
    80005296:	6942                	ld	s2,16(sp)
    80005298:	6145                	addi	sp,sp,48
    8000529a:	8082                	ret

000000008000529c <sys_read>:
{
    8000529c:	7179                	addi	sp,sp,-48
    8000529e:	f406                	sd	ra,40(sp)
    800052a0:	f022                	sd	s0,32(sp)
    800052a2:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052a4:	fe840613          	addi	a2,s0,-24
    800052a8:	4581                	li	a1,0
    800052aa:	4501                	li	a0,0
    800052ac:	00000097          	auipc	ra,0x0
    800052b0:	d8e080e7          	jalr	-626(ra) # 8000503a <argfd>
    return -1;
    800052b4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052b6:	04054163          	bltz	a0,800052f8 <sys_read+0x5c>
    800052ba:	fe440593          	addi	a1,s0,-28
    800052be:	4509                	li	a0,2
    800052c0:	ffffe097          	auipc	ra,0xffffe
    800052c4:	91c080e7          	jalr	-1764(ra) # 80002bdc <argint>
    return -1;
    800052c8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052ca:	02054763          	bltz	a0,800052f8 <sys_read+0x5c>
    800052ce:	fd840593          	addi	a1,s0,-40
    800052d2:	4505                	li	a0,1
    800052d4:	ffffe097          	auipc	ra,0xffffe
    800052d8:	92a080e7          	jalr	-1750(ra) # 80002bfe <argaddr>
    return -1;
    800052dc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052de:	00054d63          	bltz	a0,800052f8 <sys_read+0x5c>
  return fileread(f, p, n);
    800052e2:	fe442603          	lw	a2,-28(s0)
    800052e6:	fd843583          	ld	a1,-40(s0)
    800052ea:	fe843503          	ld	a0,-24(s0)
    800052ee:	fffff097          	auipc	ra,0xfffff
    800052f2:	48a080e7          	jalr	1162(ra) # 80004778 <fileread>
    800052f6:	87aa                	mv	a5,a0
}
    800052f8:	853e                	mv	a0,a5
    800052fa:	70a2                	ld	ra,40(sp)
    800052fc:	7402                	ld	s0,32(sp)
    800052fe:	6145                	addi	sp,sp,48
    80005300:	8082                	ret

0000000080005302 <sys_write>:
{
    80005302:	7179                	addi	sp,sp,-48
    80005304:	f406                	sd	ra,40(sp)
    80005306:	f022                	sd	s0,32(sp)
    80005308:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000530a:	fe840613          	addi	a2,s0,-24
    8000530e:	4581                	li	a1,0
    80005310:	4501                	li	a0,0
    80005312:	00000097          	auipc	ra,0x0
    80005316:	d28080e7          	jalr	-728(ra) # 8000503a <argfd>
    return -1;
    8000531a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000531c:	04054163          	bltz	a0,8000535e <sys_write+0x5c>
    80005320:	fe440593          	addi	a1,s0,-28
    80005324:	4509                	li	a0,2
    80005326:	ffffe097          	auipc	ra,0xffffe
    8000532a:	8b6080e7          	jalr	-1866(ra) # 80002bdc <argint>
    return -1;
    8000532e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005330:	02054763          	bltz	a0,8000535e <sys_write+0x5c>
    80005334:	fd840593          	addi	a1,s0,-40
    80005338:	4505                	li	a0,1
    8000533a:	ffffe097          	auipc	ra,0xffffe
    8000533e:	8c4080e7          	jalr	-1852(ra) # 80002bfe <argaddr>
    return -1;
    80005342:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005344:	00054d63          	bltz	a0,8000535e <sys_write+0x5c>
  return filewrite(f, p, n);
    80005348:	fe442603          	lw	a2,-28(s0)
    8000534c:	fd843583          	ld	a1,-40(s0)
    80005350:	fe843503          	ld	a0,-24(s0)
    80005354:	fffff097          	auipc	ra,0xfffff
    80005358:	4e6080e7          	jalr	1254(ra) # 8000483a <filewrite>
    8000535c:	87aa                	mv	a5,a0
}
    8000535e:	853e                	mv	a0,a5
    80005360:	70a2                	ld	ra,40(sp)
    80005362:	7402                	ld	s0,32(sp)
    80005364:	6145                	addi	sp,sp,48
    80005366:	8082                	ret

0000000080005368 <sys_close>:
{
    80005368:	1101                	addi	sp,sp,-32
    8000536a:	ec06                	sd	ra,24(sp)
    8000536c:	e822                	sd	s0,16(sp)
    8000536e:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005370:	fe040613          	addi	a2,s0,-32
    80005374:	fec40593          	addi	a1,s0,-20
    80005378:	4501                	li	a0,0
    8000537a:	00000097          	auipc	ra,0x0
    8000537e:	cc0080e7          	jalr	-832(ra) # 8000503a <argfd>
    return -1;
    80005382:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005384:	02054463          	bltz	a0,800053ac <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005388:	ffffc097          	auipc	ra,0xffffc
    8000538c:	60e080e7          	jalr	1550(ra) # 80001996 <myproc>
    80005390:	fec42783          	lw	a5,-20(s0)
    80005394:	07e9                	addi	a5,a5,26
    80005396:	078e                	slli	a5,a5,0x3
    80005398:	953e                	add	a0,a0,a5
    8000539a:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000539e:	fe043503          	ld	a0,-32(s0)
    800053a2:	fffff097          	auipc	ra,0xfffff
    800053a6:	29c080e7          	jalr	668(ra) # 8000463e <fileclose>
  return 0;
    800053aa:	4781                	li	a5,0
}
    800053ac:	853e                	mv	a0,a5
    800053ae:	60e2                	ld	ra,24(sp)
    800053b0:	6442                	ld	s0,16(sp)
    800053b2:	6105                	addi	sp,sp,32
    800053b4:	8082                	ret

00000000800053b6 <sys_fstat>:
{
    800053b6:	1101                	addi	sp,sp,-32
    800053b8:	ec06                	sd	ra,24(sp)
    800053ba:	e822                	sd	s0,16(sp)
    800053bc:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800053be:	fe840613          	addi	a2,s0,-24
    800053c2:	4581                	li	a1,0
    800053c4:	4501                	li	a0,0
    800053c6:	00000097          	auipc	ra,0x0
    800053ca:	c74080e7          	jalr	-908(ra) # 8000503a <argfd>
    return -1;
    800053ce:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800053d0:	02054563          	bltz	a0,800053fa <sys_fstat+0x44>
    800053d4:	fe040593          	addi	a1,s0,-32
    800053d8:	4505                	li	a0,1
    800053da:	ffffe097          	auipc	ra,0xffffe
    800053de:	824080e7          	jalr	-2012(ra) # 80002bfe <argaddr>
    return -1;
    800053e2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800053e4:	00054b63          	bltz	a0,800053fa <sys_fstat+0x44>
  return filestat(f, st);
    800053e8:	fe043583          	ld	a1,-32(s0)
    800053ec:	fe843503          	ld	a0,-24(s0)
    800053f0:	fffff097          	auipc	ra,0xfffff
    800053f4:	316080e7          	jalr	790(ra) # 80004706 <filestat>
    800053f8:	87aa                	mv	a5,a0
}
    800053fa:	853e                	mv	a0,a5
    800053fc:	60e2                	ld	ra,24(sp)
    800053fe:	6442                	ld	s0,16(sp)
    80005400:	6105                	addi	sp,sp,32
    80005402:	8082                	ret

0000000080005404 <sys_link>:
{
    80005404:	7169                	addi	sp,sp,-304
    80005406:	f606                	sd	ra,296(sp)
    80005408:	f222                	sd	s0,288(sp)
    8000540a:	ee26                	sd	s1,280(sp)
    8000540c:	ea4a                	sd	s2,272(sp)
    8000540e:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005410:	08000613          	li	a2,128
    80005414:	ed040593          	addi	a1,s0,-304
    80005418:	4501                	li	a0,0
    8000541a:	ffffe097          	auipc	ra,0xffffe
    8000541e:	806080e7          	jalr	-2042(ra) # 80002c20 <argstr>
    return -1;
    80005422:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005424:	10054e63          	bltz	a0,80005540 <sys_link+0x13c>
    80005428:	08000613          	li	a2,128
    8000542c:	f5040593          	addi	a1,s0,-176
    80005430:	4505                	li	a0,1
    80005432:	ffffd097          	auipc	ra,0xffffd
    80005436:	7ee080e7          	jalr	2030(ra) # 80002c20 <argstr>
    return -1;
    8000543a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000543c:	10054263          	bltz	a0,80005540 <sys_link+0x13c>
  begin_op();
    80005440:	fffff097          	auipc	ra,0xfffff
    80005444:	d36080e7          	jalr	-714(ra) # 80004176 <begin_op>
  if((ip = namei(old)) == 0){
    80005448:	ed040513          	addi	a0,s0,-304
    8000544c:	fffff097          	auipc	ra,0xfffff
    80005450:	b0a080e7          	jalr	-1270(ra) # 80003f56 <namei>
    80005454:	84aa                	mv	s1,a0
    80005456:	c551                	beqz	a0,800054e2 <sys_link+0xde>
  ilock(ip);
    80005458:	ffffe097          	auipc	ra,0xffffe
    8000545c:	342080e7          	jalr	834(ra) # 8000379a <ilock>
  if(ip->type == T_DIR){
    80005460:	04449703          	lh	a4,68(s1)
    80005464:	4785                	li	a5,1
    80005466:	08f70463          	beq	a4,a5,800054ee <sys_link+0xea>
  ip->nlink++;
    8000546a:	04a4d783          	lhu	a5,74(s1)
    8000546e:	2785                	addiw	a5,a5,1
    80005470:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005474:	8526                	mv	a0,s1
    80005476:	ffffe097          	auipc	ra,0xffffe
    8000547a:	258080e7          	jalr	600(ra) # 800036ce <iupdate>
  iunlock(ip);
    8000547e:	8526                	mv	a0,s1
    80005480:	ffffe097          	auipc	ra,0xffffe
    80005484:	3dc080e7          	jalr	988(ra) # 8000385c <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005488:	fd040593          	addi	a1,s0,-48
    8000548c:	f5040513          	addi	a0,s0,-176
    80005490:	fffff097          	auipc	ra,0xfffff
    80005494:	ae4080e7          	jalr	-1308(ra) # 80003f74 <nameiparent>
    80005498:	892a                	mv	s2,a0
    8000549a:	c935                	beqz	a0,8000550e <sys_link+0x10a>
  ilock(dp);
    8000549c:	ffffe097          	auipc	ra,0xffffe
    800054a0:	2fe080e7          	jalr	766(ra) # 8000379a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800054a4:	00092703          	lw	a4,0(s2)
    800054a8:	409c                	lw	a5,0(s1)
    800054aa:	04f71d63          	bne	a4,a5,80005504 <sys_link+0x100>
    800054ae:	40d0                	lw	a2,4(s1)
    800054b0:	fd040593          	addi	a1,s0,-48
    800054b4:	854a                	mv	a0,s2
    800054b6:	fffff097          	auipc	ra,0xfffff
    800054ba:	9de080e7          	jalr	-1570(ra) # 80003e94 <dirlink>
    800054be:	04054363          	bltz	a0,80005504 <sys_link+0x100>
  iunlockput(dp);
    800054c2:	854a                	mv	a0,s2
    800054c4:	ffffe097          	auipc	ra,0xffffe
    800054c8:	538080e7          	jalr	1336(ra) # 800039fc <iunlockput>
  iput(ip);
    800054cc:	8526                	mv	a0,s1
    800054ce:	ffffe097          	auipc	ra,0xffffe
    800054d2:	486080e7          	jalr	1158(ra) # 80003954 <iput>
  end_op();
    800054d6:	fffff097          	auipc	ra,0xfffff
    800054da:	d1e080e7          	jalr	-738(ra) # 800041f4 <end_op>
  return 0;
    800054de:	4781                	li	a5,0
    800054e0:	a085                	j	80005540 <sys_link+0x13c>
    end_op();
    800054e2:	fffff097          	auipc	ra,0xfffff
    800054e6:	d12080e7          	jalr	-750(ra) # 800041f4 <end_op>
    return -1;
    800054ea:	57fd                	li	a5,-1
    800054ec:	a891                	j	80005540 <sys_link+0x13c>
    iunlockput(ip);
    800054ee:	8526                	mv	a0,s1
    800054f0:	ffffe097          	auipc	ra,0xffffe
    800054f4:	50c080e7          	jalr	1292(ra) # 800039fc <iunlockput>
    end_op();
    800054f8:	fffff097          	auipc	ra,0xfffff
    800054fc:	cfc080e7          	jalr	-772(ra) # 800041f4 <end_op>
    return -1;
    80005500:	57fd                	li	a5,-1
    80005502:	a83d                	j	80005540 <sys_link+0x13c>
    iunlockput(dp);
    80005504:	854a                	mv	a0,s2
    80005506:	ffffe097          	auipc	ra,0xffffe
    8000550a:	4f6080e7          	jalr	1270(ra) # 800039fc <iunlockput>
  ilock(ip);
    8000550e:	8526                	mv	a0,s1
    80005510:	ffffe097          	auipc	ra,0xffffe
    80005514:	28a080e7          	jalr	650(ra) # 8000379a <ilock>
  ip->nlink--;
    80005518:	04a4d783          	lhu	a5,74(s1)
    8000551c:	37fd                	addiw	a5,a5,-1
    8000551e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005522:	8526                	mv	a0,s1
    80005524:	ffffe097          	auipc	ra,0xffffe
    80005528:	1aa080e7          	jalr	426(ra) # 800036ce <iupdate>
  iunlockput(ip);
    8000552c:	8526                	mv	a0,s1
    8000552e:	ffffe097          	auipc	ra,0xffffe
    80005532:	4ce080e7          	jalr	1230(ra) # 800039fc <iunlockput>
  end_op();
    80005536:	fffff097          	auipc	ra,0xfffff
    8000553a:	cbe080e7          	jalr	-834(ra) # 800041f4 <end_op>
  return -1;
    8000553e:	57fd                	li	a5,-1
}
    80005540:	853e                	mv	a0,a5
    80005542:	70b2                	ld	ra,296(sp)
    80005544:	7412                	ld	s0,288(sp)
    80005546:	64f2                	ld	s1,280(sp)
    80005548:	6952                	ld	s2,272(sp)
    8000554a:	6155                	addi	sp,sp,304
    8000554c:	8082                	ret

000000008000554e <sys_unlink>:
{
    8000554e:	7151                	addi	sp,sp,-240
    80005550:	f586                	sd	ra,232(sp)
    80005552:	f1a2                	sd	s0,224(sp)
    80005554:	eda6                	sd	s1,216(sp)
    80005556:	e9ca                	sd	s2,208(sp)
    80005558:	e5ce                	sd	s3,200(sp)
    8000555a:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000555c:	08000613          	li	a2,128
    80005560:	f3040593          	addi	a1,s0,-208
    80005564:	4501                	li	a0,0
    80005566:	ffffd097          	auipc	ra,0xffffd
    8000556a:	6ba080e7          	jalr	1722(ra) # 80002c20 <argstr>
    8000556e:	18054163          	bltz	a0,800056f0 <sys_unlink+0x1a2>
  begin_op();
    80005572:	fffff097          	auipc	ra,0xfffff
    80005576:	c04080e7          	jalr	-1020(ra) # 80004176 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000557a:	fb040593          	addi	a1,s0,-80
    8000557e:	f3040513          	addi	a0,s0,-208
    80005582:	fffff097          	auipc	ra,0xfffff
    80005586:	9f2080e7          	jalr	-1550(ra) # 80003f74 <nameiparent>
    8000558a:	84aa                	mv	s1,a0
    8000558c:	c979                	beqz	a0,80005662 <sys_unlink+0x114>
  ilock(dp);
    8000558e:	ffffe097          	auipc	ra,0xffffe
    80005592:	20c080e7          	jalr	524(ra) # 8000379a <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005596:	00003597          	auipc	a1,0x3
    8000559a:	16a58593          	addi	a1,a1,362 # 80008700 <syscalls+0x2b8>
    8000559e:	fb040513          	addi	a0,s0,-80
    800055a2:	ffffe097          	auipc	ra,0xffffe
    800055a6:	6c2080e7          	jalr	1730(ra) # 80003c64 <namecmp>
    800055aa:	14050a63          	beqz	a0,800056fe <sys_unlink+0x1b0>
    800055ae:	00003597          	auipc	a1,0x3
    800055b2:	15a58593          	addi	a1,a1,346 # 80008708 <syscalls+0x2c0>
    800055b6:	fb040513          	addi	a0,s0,-80
    800055ba:	ffffe097          	auipc	ra,0xffffe
    800055be:	6aa080e7          	jalr	1706(ra) # 80003c64 <namecmp>
    800055c2:	12050e63          	beqz	a0,800056fe <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800055c6:	f2c40613          	addi	a2,s0,-212
    800055ca:	fb040593          	addi	a1,s0,-80
    800055ce:	8526                	mv	a0,s1
    800055d0:	ffffe097          	auipc	ra,0xffffe
    800055d4:	6ae080e7          	jalr	1710(ra) # 80003c7e <dirlookup>
    800055d8:	892a                	mv	s2,a0
    800055da:	12050263          	beqz	a0,800056fe <sys_unlink+0x1b0>
  ilock(ip);
    800055de:	ffffe097          	auipc	ra,0xffffe
    800055e2:	1bc080e7          	jalr	444(ra) # 8000379a <ilock>
  if(ip->nlink < 1)
    800055e6:	04a91783          	lh	a5,74(s2)
    800055ea:	08f05263          	blez	a5,8000566e <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800055ee:	04491703          	lh	a4,68(s2)
    800055f2:	4785                	li	a5,1
    800055f4:	08f70563          	beq	a4,a5,8000567e <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800055f8:	4641                	li	a2,16
    800055fa:	4581                	li	a1,0
    800055fc:	fc040513          	addi	a0,s0,-64
    80005600:	ffffb097          	auipc	ra,0xffffb
    80005604:	6cc080e7          	jalr	1740(ra) # 80000ccc <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005608:	4741                	li	a4,16
    8000560a:	f2c42683          	lw	a3,-212(s0)
    8000560e:	fc040613          	addi	a2,s0,-64
    80005612:	4581                	li	a1,0
    80005614:	8526                	mv	a0,s1
    80005616:	ffffe097          	auipc	ra,0xffffe
    8000561a:	530080e7          	jalr	1328(ra) # 80003b46 <writei>
    8000561e:	47c1                	li	a5,16
    80005620:	0af51563          	bne	a0,a5,800056ca <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005624:	04491703          	lh	a4,68(s2)
    80005628:	4785                	li	a5,1
    8000562a:	0af70863          	beq	a4,a5,800056da <sys_unlink+0x18c>
  iunlockput(dp);
    8000562e:	8526                	mv	a0,s1
    80005630:	ffffe097          	auipc	ra,0xffffe
    80005634:	3cc080e7          	jalr	972(ra) # 800039fc <iunlockput>
  ip->nlink--;
    80005638:	04a95783          	lhu	a5,74(s2)
    8000563c:	37fd                	addiw	a5,a5,-1
    8000563e:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005642:	854a                	mv	a0,s2
    80005644:	ffffe097          	auipc	ra,0xffffe
    80005648:	08a080e7          	jalr	138(ra) # 800036ce <iupdate>
  iunlockput(ip);
    8000564c:	854a                	mv	a0,s2
    8000564e:	ffffe097          	auipc	ra,0xffffe
    80005652:	3ae080e7          	jalr	942(ra) # 800039fc <iunlockput>
  end_op();
    80005656:	fffff097          	auipc	ra,0xfffff
    8000565a:	b9e080e7          	jalr	-1122(ra) # 800041f4 <end_op>
  return 0;
    8000565e:	4501                	li	a0,0
    80005660:	a84d                	j	80005712 <sys_unlink+0x1c4>
    end_op();
    80005662:	fffff097          	auipc	ra,0xfffff
    80005666:	b92080e7          	jalr	-1134(ra) # 800041f4 <end_op>
    return -1;
    8000566a:	557d                	li	a0,-1
    8000566c:	a05d                	j	80005712 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    8000566e:	00003517          	auipc	a0,0x3
    80005672:	0c250513          	addi	a0,a0,194 # 80008730 <syscalls+0x2e8>
    80005676:	ffffb097          	auipc	ra,0xffffb
    8000567a:	ec4080e7          	jalr	-316(ra) # 8000053a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000567e:	04c92703          	lw	a4,76(s2)
    80005682:	02000793          	li	a5,32
    80005686:	f6e7f9e3          	bgeu	a5,a4,800055f8 <sys_unlink+0xaa>
    8000568a:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000568e:	4741                	li	a4,16
    80005690:	86ce                	mv	a3,s3
    80005692:	f1840613          	addi	a2,s0,-232
    80005696:	4581                	li	a1,0
    80005698:	854a                	mv	a0,s2
    8000569a:	ffffe097          	auipc	ra,0xffffe
    8000569e:	3b4080e7          	jalr	948(ra) # 80003a4e <readi>
    800056a2:	47c1                	li	a5,16
    800056a4:	00f51b63          	bne	a0,a5,800056ba <sys_unlink+0x16c>
    if(de.inum != 0)
    800056a8:	f1845783          	lhu	a5,-232(s0)
    800056ac:	e7a1                	bnez	a5,800056f4 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800056ae:	29c1                	addiw	s3,s3,16
    800056b0:	04c92783          	lw	a5,76(s2)
    800056b4:	fcf9ede3          	bltu	s3,a5,8000568e <sys_unlink+0x140>
    800056b8:	b781                	j	800055f8 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800056ba:	00003517          	auipc	a0,0x3
    800056be:	08e50513          	addi	a0,a0,142 # 80008748 <syscalls+0x300>
    800056c2:	ffffb097          	auipc	ra,0xffffb
    800056c6:	e78080e7          	jalr	-392(ra) # 8000053a <panic>
    panic("unlink: writei");
    800056ca:	00003517          	auipc	a0,0x3
    800056ce:	09650513          	addi	a0,a0,150 # 80008760 <syscalls+0x318>
    800056d2:	ffffb097          	auipc	ra,0xffffb
    800056d6:	e68080e7          	jalr	-408(ra) # 8000053a <panic>
    dp->nlink--;
    800056da:	04a4d783          	lhu	a5,74(s1)
    800056de:	37fd                	addiw	a5,a5,-1
    800056e0:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800056e4:	8526                	mv	a0,s1
    800056e6:	ffffe097          	auipc	ra,0xffffe
    800056ea:	fe8080e7          	jalr	-24(ra) # 800036ce <iupdate>
    800056ee:	b781                	j	8000562e <sys_unlink+0xe0>
    return -1;
    800056f0:	557d                	li	a0,-1
    800056f2:	a005                	j	80005712 <sys_unlink+0x1c4>
    iunlockput(ip);
    800056f4:	854a                	mv	a0,s2
    800056f6:	ffffe097          	auipc	ra,0xffffe
    800056fa:	306080e7          	jalr	774(ra) # 800039fc <iunlockput>
  iunlockput(dp);
    800056fe:	8526                	mv	a0,s1
    80005700:	ffffe097          	auipc	ra,0xffffe
    80005704:	2fc080e7          	jalr	764(ra) # 800039fc <iunlockput>
  end_op();
    80005708:	fffff097          	auipc	ra,0xfffff
    8000570c:	aec080e7          	jalr	-1300(ra) # 800041f4 <end_op>
  return -1;
    80005710:	557d                	li	a0,-1
}
    80005712:	70ae                	ld	ra,232(sp)
    80005714:	740e                	ld	s0,224(sp)
    80005716:	64ee                	ld	s1,216(sp)
    80005718:	694e                	ld	s2,208(sp)
    8000571a:	69ae                	ld	s3,200(sp)
    8000571c:	616d                	addi	sp,sp,240
    8000571e:	8082                	ret

0000000080005720 <sys_open>:

uint64
sys_open(void)
{
    80005720:	7131                	addi	sp,sp,-192
    80005722:	fd06                	sd	ra,184(sp)
    80005724:	f922                	sd	s0,176(sp)
    80005726:	f526                	sd	s1,168(sp)
    80005728:	f14a                	sd	s2,160(sp)
    8000572a:	ed4e                	sd	s3,152(sp)
    8000572c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000572e:	08000613          	li	a2,128
    80005732:	f5040593          	addi	a1,s0,-176
    80005736:	4501                	li	a0,0
    80005738:	ffffd097          	auipc	ra,0xffffd
    8000573c:	4e8080e7          	jalr	1256(ra) # 80002c20 <argstr>
    return -1;
    80005740:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005742:	0c054163          	bltz	a0,80005804 <sys_open+0xe4>
    80005746:	f4c40593          	addi	a1,s0,-180
    8000574a:	4505                	li	a0,1
    8000574c:	ffffd097          	auipc	ra,0xffffd
    80005750:	490080e7          	jalr	1168(ra) # 80002bdc <argint>
    80005754:	0a054863          	bltz	a0,80005804 <sys_open+0xe4>

  begin_op();
    80005758:	fffff097          	auipc	ra,0xfffff
    8000575c:	a1e080e7          	jalr	-1506(ra) # 80004176 <begin_op>

  if(omode & O_CREATE){
    80005760:	f4c42783          	lw	a5,-180(s0)
    80005764:	2007f793          	andi	a5,a5,512
    80005768:	cbdd                	beqz	a5,8000581e <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    8000576a:	4681                	li	a3,0
    8000576c:	4601                	li	a2,0
    8000576e:	4589                	li	a1,2
    80005770:	f5040513          	addi	a0,s0,-176
    80005774:	00000097          	auipc	ra,0x0
    80005778:	970080e7          	jalr	-1680(ra) # 800050e4 <create>
    8000577c:	892a                	mv	s2,a0
    if(ip == 0){
    8000577e:	c959                	beqz	a0,80005814 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005780:	04491703          	lh	a4,68(s2)
    80005784:	478d                	li	a5,3
    80005786:	00f71763          	bne	a4,a5,80005794 <sys_open+0x74>
    8000578a:	04695703          	lhu	a4,70(s2)
    8000578e:	47a5                	li	a5,9
    80005790:	0ce7ec63          	bltu	a5,a4,80005868 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005794:	fffff097          	auipc	ra,0xfffff
    80005798:	dee080e7          	jalr	-530(ra) # 80004582 <filealloc>
    8000579c:	89aa                	mv	s3,a0
    8000579e:	10050263          	beqz	a0,800058a2 <sys_open+0x182>
    800057a2:	00000097          	auipc	ra,0x0
    800057a6:	900080e7          	jalr	-1792(ra) # 800050a2 <fdalloc>
    800057aa:	84aa                	mv	s1,a0
    800057ac:	0e054663          	bltz	a0,80005898 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800057b0:	04491703          	lh	a4,68(s2)
    800057b4:	478d                	li	a5,3
    800057b6:	0cf70463          	beq	a4,a5,8000587e <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800057ba:	4789                	li	a5,2
    800057bc:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800057c0:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800057c4:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    800057c8:	f4c42783          	lw	a5,-180(s0)
    800057cc:	0017c713          	xori	a4,a5,1
    800057d0:	8b05                	andi	a4,a4,1
    800057d2:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800057d6:	0037f713          	andi	a4,a5,3
    800057da:	00e03733          	snez	a4,a4
    800057de:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800057e2:	4007f793          	andi	a5,a5,1024
    800057e6:	c791                	beqz	a5,800057f2 <sys_open+0xd2>
    800057e8:	04491703          	lh	a4,68(s2)
    800057ec:	4789                	li	a5,2
    800057ee:	08f70f63          	beq	a4,a5,8000588c <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    800057f2:	854a                	mv	a0,s2
    800057f4:	ffffe097          	auipc	ra,0xffffe
    800057f8:	068080e7          	jalr	104(ra) # 8000385c <iunlock>
  end_op();
    800057fc:	fffff097          	auipc	ra,0xfffff
    80005800:	9f8080e7          	jalr	-1544(ra) # 800041f4 <end_op>

  return fd;
}
    80005804:	8526                	mv	a0,s1
    80005806:	70ea                	ld	ra,184(sp)
    80005808:	744a                	ld	s0,176(sp)
    8000580a:	74aa                	ld	s1,168(sp)
    8000580c:	790a                	ld	s2,160(sp)
    8000580e:	69ea                	ld	s3,152(sp)
    80005810:	6129                	addi	sp,sp,192
    80005812:	8082                	ret
      end_op();
    80005814:	fffff097          	auipc	ra,0xfffff
    80005818:	9e0080e7          	jalr	-1568(ra) # 800041f4 <end_op>
      return -1;
    8000581c:	b7e5                	j	80005804 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    8000581e:	f5040513          	addi	a0,s0,-176
    80005822:	ffffe097          	auipc	ra,0xffffe
    80005826:	734080e7          	jalr	1844(ra) # 80003f56 <namei>
    8000582a:	892a                	mv	s2,a0
    8000582c:	c905                	beqz	a0,8000585c <sys_open+0x13c>
    ilock(ip);
    8000582e:	ffffe097          	auipc	ra,0xffffe
    80005832:	f6c080e7          	jalr	-148(ra) # 8000379a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005836:	04491703          	lh	a4,68(s2)
    8000583a:	4785                	li	a5,1
    8000583c:	f4f712e3          	bne	a4,a5,80005780 <sys_open+0x60>
    80005840:	f4c42783          	lw	a5,-180(s0)
    80005844:	dba1                	beqz	a5,80005794 <sys_open+0x74>
      iunlockput(ip);
    80005846:	854a                	mv	a0,s2
    80005848:	ffffe097          	auipc	ra,0xffffe
    8000584c:	1b4080e7          	jalr	436(ra) # 800039fc <iunlockput>
      end_op();
    80005850:	fffff097          	auipc	ra,0xfffff
    80005854:	9a4080e7          	jalr	-1628(ra) # 800041f4 <end_op>
      return -1;
    80005858:	54fd                	li	s1,-1
    8000585a:	b76d                	j	80005804 <sys_open+0xe4>
      end_op();
    8000585c:	fffff097          	auipc	ra,0xfffff
    80005860:	998080e7          	jalr	-1640(ra) # 800041f4 <end_op>
      return -1;
    80005864:	54fd                	li	s1,-1
    80005866:	bf79                	j	80005804 <sys_open+0xe4>
    iunlockput(ip);
    80005868:	854a                	mv	a0,s2
    8000586a:	ffffe097          	auipc	ra,0xffffe
    8000586e:	192080e7          	jalr	402(ra) # 800039fc <iunlockput>
    end_op();
    80005872:	fffff097          	auipc	ra,0xfffff
    80005876:	982080e7          	jalr	-1662(ra) # 800041f4 <end_op>
    return -1;
    8000587a:	54fd                	li	s1,-1
    8000587c:	b761                	j	80005804 <sys_open+0xe4>
    f->type = FD_DEVICE;
    8000587e:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005882:	04691783          	lh	a5,70(s2)
    80005886:	02f99223          	sh	a5,36(s3)
    8000588a:	bf2d                	j	800057c4 <sys_open+0xa4>
    itrunc(ip);
    8000588c:	854a                	mv	a0,s2
    8000588e:	ffffe097          	auipc	ra,0xffffe
    80005892:	01a080e7          	jalr	26(ra) # 800038a8 <itrunc>
    80005896:	bfb1                	j	800057f2 <sys_open+0xd2>
      fileclose(f);
    80005898:	854e                	mv	a0,s3
    8000589a:	fffff097          	auipc	ra,0xfffff
    8000589e:	da4080e7          	jalr	-604(ra) # 8000463e <fileclose>
    iunlockput(ip);
    800058a2:	854a                	mv	a0,s2
    800058a4:	ffffe097          	auipc	ra,0xffffe
    800058a8:	158080e7          	jalr	344(ra) # 800039fc <iunlockput>
    end_op();
    800058ac:	fffff097          	auipc	ra,0xfffff
    800058b0:	948080e7          	jalr	-1720(ra) # 800041f4 <end_op>
    return -1;
    800058b4:	54fd                	li	s1,-1
    800058b6:	b7b9                	j	80005804 <sys_open+0xe4>

00000000800058b8 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800058b8:	7175                	addi	sp,sp,-144
    800058ba:	e506                	sd	ra,136(sp)
    800058bc:	e122                	sd	s0,128(sp)
    800058be:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800058c0:	fffff097          	auipc	ra,0xfffff
    800058c4:	8b6080e7          	jalr	-1866(ra) # 80004176 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800058c8:	08000613          	li	a2,128
    800058cc:	f7040593          	addi	a1,s0,-144
    800058d0:	4501                	li	a0,0
    800058d2:	ffffd097          	auipc	ra,0xffffd
    800058d6:	34e080e7          	jalr	846(ra) # 80002c20 <argstr>
    800058da:	02054963          	bltz	a0,8000590c <sys_mkdir+0x54>
    800058de:	4681                	li	a3,0
    800058e0:	4601                	li	a2,0
    800058e2:	4585                	li	a1,1
    800058e4:	f7040513          	addi	a0,s0,-144
    800058e8:	fffff097          	auipc	ra,0xfffff
    800058ec:	7fc080e7          	jalr	2044(ra) # 800050e4 <create>
    800058f0:	cd11                	beqz	a0,8000590c <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800058f2:	ffffe097          	auipc	ra,0xffffe
    800058f6:	10a080e7          	jalr	266(ra) # 800039fc <iunlockput>
  end_op();
    800058fa:	fffff097          	auipc	ra,0xfffff
    800058fe:	8fa080e7          	jalr	-1798(ra) # 800041f4 <end_op>
  return 0;
    80005902:	4501                	li	a0,0
}
    80005904:	60aa                	ld	ra,136(sp)
    80005906:	640a                	ld	s0,128(sp)
    80005908:	6149                	addi	sp,sp,144
    8000590a:	8082                	ret
    end_op();
    8000590c:	fffff097          	auipc	ra,0xfffff
    80005910:	8e8080e7          	jalr	-1816(ra) # 800041f4 <end_op>
    return -1;
    80005914:	557d                	li	a0,-1
    80005916:	b7fd                	j	80005904 <sys_mkdir+0x4c>

0000000080005918 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005918:	7135                	addi	sp,sp,-160
    8000591a:	ed06                	sd	ra,152(sp)
    8000591c:	e922                	sd	s0,144(sp)
    8000591e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005920:	fffff097          	auipc	ra,0xfffff
    80005924:	856080e7          	jalr	-1962(ra) # 80004176 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005928:	08000613          	li	a2,128
    8000592c:	f7040593          	addi	a1,s0,-144
    80005930:	4501                	li	a0,0
    80005932:	ffffd097          	auipc	ra,0xffffd
    80005936:	2ee080e7          	jalr	750(ra) # 80002c20 <argstr>
    8000593a:	04054a63          	bltz	a0,8000598e <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    8000593e:	f6c40593          	addi	a1,s0,-148
    80005942:	4505                	li	a0,1
    80005944:	ffffd097          	auipc	ra,0xffffd
    80005948:	298080e7          	jalr	664(ra) # 80002bdc <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000594c:	04054163          	bltz	a0,8000598e <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005950:	f6840593          	addi	a1,s0,-152
    80005954:	4509                	li	a0,2
    80005956:	ffffd097          	auipc	ra,0xffffd
    8000595a:	286080e7          	jalr	646(ra) # 80002bdc <argint>
     argint(1, &major) < 0 ||
    8000595e:	02054863          	bltz	a0,8000598e <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005962:	f6841683          	lh	a3,-152(s0)
    80005966:	f6c41603          	lh	a2,-148(s0)
    8000596a:	458d                	li	a1,3
    8000596c:	f7040513          	addi	a0,s0,-144
    80005970:	fffff097          	auipc	ra,0xfffff
    80005974:	774080e7          	jalr	1908(ra) # 800050e4 <create>
     argint(2, &minor) < 0 ||
    80005978:	c919                	beqz	a0,8000598e <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000597a:	ffffe097          	auipc	ra,0xffffe
    8000597e:	082080e7          	jalr	130(ra) # 800039fc <iunlockput>
  end_op();
    80005982:	fffff097          	auipc	ra,0xfffff
    80005986:	872080e7          	jalr	-1934(ra) # 800041f4 <end_op>
  return 0;
    8000598a:	4501                	li	a0,0
    8000598c:	a031                	j	80005998 <sys_mknod+0x80>
    end_op();
    8000598e:	fffff097          	auipc	ra,0xfffff
    80005992:	866080e7          	jalr	-1946(ra) # 800041f4 <end_op>
    return -1;
    80005996:	557d                	li	a0,-1
}
    80005998:	60ea                	ld	ra,152(sp)
    8000599a:	644a                	ld	s0,144(sp)
    8000599c:	610d                	addi	sp,sp,160
    8000599e:	8082                	ret

00000000800059a0 <sys_chdir>:

uint64
sys_chdir(void)
{
    800059a0:	7135                	addi	sp,sp,-160
    800059a2:	ed06                	sd	ra,152(sp)
    800059a4:	e922                	sd	s0,144(sp)
    800059a6:	e526                	sd	s1,136(sp)
    800059a8:	e14a                	sd	s2,128(sp)
    800059aa:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800059ac:	ffffc097          	auipc	ra,0xffffc
    800059b0:	fea080e7          	jalr	-22(ra) # 80001996 <myproc>
    800059b4:	892a                	mv	s2,a0
  
  begin_op();
    800059b6:	ffffe097          	auipc	ra,0xffffe
    800059ba:	7c0080e7          	jalr	1984(ra) # 80004176 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800059be:	08000613          	li	a2,128
    800059c2:	f6040593          	addi	a1,s0,-160
    800059c6:	4501                	li	a0,0
    800059c8:	ffffd097          	auipc	ra,0xffffd
    800059cc:	258080e7          	jalr	600(ra) # 80002c20 <argstr>
    800059d0:	04054b63          	bltz	a0,80005a26 <sys_chdir+0x86>
    800059d4:	f6040513          	addi	a0,s0,-160
    800059d8:	ffffe097          	auipc	ra,0xffffe
    800059dc:	57e080e7          	jalr	1406(ra) # 80003f56 <namei>
    800059e0:	84aa                	mv	s1,a0
    800059e2:	c131                	beqz	a0,80005a26 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800059e4:	ffffe097          	auipc	ra,0xffffe
    800059e8:	db6080e7          	jalr	-586(ra) # 8000379a <ilock>
  if(ip->type != T_DIR){
    800059ec:	04449703          	lh	a4,68(s1)
    800059f0:	4785                	li	a5,1
    800059f2:	04f71063          	bne	a4,a5,80005a32 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800059f6:	8526                	mv	a0,s1
    800059f8:	ffffe097          	auipc	ra,0xffffe
    800059fc:	e64080e7          	jalr	-412(ra) # 8000385c <iunlock>
  iput(p->cwd);
    80005a00:	15093503          	ld	a0,336(s2)
    80005a04:	ffffe097          	auipc	ra,0xffffe
    80005a08:	f50080e7          	jalr	-176(ra) # 80003954 <iput>
  end_op();
    80005a0c:	ffffe097          	auipc	ra,0xffffe
    80005a10:	7e8080e7          	jalr	2024(ra) # 800041f4 <end_op>
  p->cwd = ip;
    80005a14:	14993823          	sd	s1,336(s2)
  return 0;
    80005a18:	4501                	li	a0,0
}
    80005a1a:	60ea                	ld	ra,152(sp)
    80005a1c:	644a                	ld	s0,144(sp)
    80005a1e:	64aa                	ld	s1,136(sp)
    80005a20:	690a                	ld	s2,128(sp)
    80005a22:	610d                	addi	sp,sp,160
    80005a24:	8082                	ret
    end_op();
    80005a26:	ffffe097          	auipc	ra,0xffffe
    80005a2a:	7ce080e7          	jalr	1998(ra) # 800041f4 <end_op>
    return -1;
    80005a2e:	557d                	li	a0,-1
    80005a30:	b7ed                	j	80005a1a <sys_chdir+0x7a>
    iunlockput(ip);
    80005a32:	8526                	mv	a0,s1
    80005a34:	ffffe097          	auipc	ra,0xffffe
    80005a38:	fc8080e7          	jalr	-56(ra) # 800039fc <iunlockput>
    end_op();
    80005a3c:	ffffe097          	auipc	ra,0xffffe
    80005a40:	7b8080e7          	jalr	1976(ra) # 800041f4 <end_op>
    return -1;
    80005a44:	557d                	li	a0,-1
    80005a46:	bfd1                	j	80005a1a <sys_chdir+0x7a>

0000000080005a48 <sys_exec>:

uint64
sys_exec(void)
{
    80005a48:	7145                	addi	sp,sp,-464
    80005a4a:	e786                	sd	ra,456(sp)
    80005a4c:	e3a2                	sd	s0,448(sp)
    80005a4e:	ff26                	sd	s1,440(sp)
    80005a50:	fb4a                	sd	s2,432(sp)
    80005a52:	f74e                	sd	s3,424(sp)
    80005a54:	f352                	sd	s4,416(sp)
    80005a56:	ef56                	sd	s5,408(sp)
    80005a58:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005a5a:	08000613          	li	a2,128
    80005a5e:	f4040593          	addi	a1,s0,-192
    80005a62:	4501                	li	a0,0
    80005a64:	ffffd097          	auipc	ra,0xffffd
    80005a68:	1bc080e7          	jalr	444(ra) # 80002c20 <argstr>
    return -1;
    80005a6c:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005a6e:	0c054b63          	bltz	a0,80005b44 <sys_exec+0xfc>
    80005a72:	e3840593          	addi	a1,s0,-456
    80005a76:	4505                	li	a0,1
    80005a78:	ffffd097          	auipc	ra,0xffffd
    80005a7c:	186080e7          	jalr	390(ra) # 80002bfe <argaddr>
    80005a80:	0c054263          	bltz	a0,80005b44 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    80005a84:	10000613          	li	a2,256
    80005a88:	4581                	li	a1,0
    80005a8a:	e4040513          	addi	a0,s0,-448
    80005a8e:	ffffb097          	auipc	ra,0xffffb
    80005a92:	23e080e7          	jalr	574(ra) # 80000ccc <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005a96:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005a9a:	89a6                	mv	s3,s1
    80005a9c:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005a9e:	02000a13          	li	s4,32
    80005aa2:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005aa6:	00391513          	slli	a0,s2,0x3
    80005aaa:	e3040593          	addi	a1,s0,-464
    80005aae:	e3843783          	ld	a5,-456(s0)
    80005ab2:	953e                	add	a0,a0,a5
    80005ab4:	ffffd097          	auipc	ra,0xffffd
    80005ab8:	08e080e7          	jalr	142(ra) # 80002b42 <fetchaddr>
    80005abc:	02054a63          	bltz	a0,80005af0 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005ac0:	e3043783          	ld	a5,-464(s0)
    80005ac4:	c3b9                	beqz	a5,80005b0a <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005ac6:	ffffb097          	auipc	ra,0xffffb
    80005aca:	01a080e7          	jalr	26(ra) # 80000ae0 <kalloc>
    80005ace:	85aa                	mv	a1,a0
    80005ad0:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005ad4:	cd11                	beqz	a0,80005af0 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005ad6:	6605                	lui	a2,0x1
    80005ad8:	e3043503          	ld	a0,-464(s0)
    80005adc:	ffffd097          	auipc	ra,0xffffd
    80005ae0:	0b8080e7          	jalr	184(ra) # 80002b94 <fetchstr>
    80005ae4:	00054663          	bltz	a0,80005af0 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005ae8:	0905                	addi	s2,s2,1
    80005aea:	09a1                	addi	s3,s3,8
    80005aec:	fb491be3          	bne	s2,s4,80005aa2 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005af0:	f4040913          	addi	s2,s0,-192
    80005af4:	6088                	ld	a0,0(s1)
    80005af6:	c531                	beqz	a0,80005b42 <sys_exec+0xfa>
    kfree(argv[i]);
    80005af8:	ffffb097          	auipc	ra,0xffffb
    80005afc:	eea080e7          	jalr	-278(ra) # 800009e2 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b00:	04a1                	addi	s1,s1,8
    80005b02:	ff2499e3          	bne	s1,s2,80005af4 <sys_exec+0xac>
  return -1;
    80005b06:	597d                	li	s2,-1
    80005b08:	a835                	j	80005b44 <sys_exec+0xfc>
      argv[i] = 0;
    80005b0a:	0a8e                	slli	s5,s5,0x3
    80005b0c:	fc0a8793          	addi	a5,s5,-64 # ffffffffffffefc0 <end+0xffffffff7ffd8fc0>
    80005b10:	00878ab3          	add	s5,a5,s0
    80005b14:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005b18:	e4040593          	addi	a1,s0,-448
    80005b1c:	f4040513          	addi	a0,s0,-192
    80005b20:	fffff097          	auipc	ra,0xfffff
    80005b24:	172080e7          	jalr	370(ra) # 80004c92 <exec>
    80005b28:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b2a:	f4040993          	addi	s3,s0,-192
    80005b2e:	6088                	ld	a0,0(s1)
    80005b30:	c911                	beqz	a0,80005b44 <sys_exec+0xfc>
    kfree(argv[i]);
    80005b32:	ffffb097          	auipc	ra,0xffffb
    80005b36:	eb0080e7          	jalr	-336(ra) # 800009e2 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b3a:	04a1                	addi	s1,s1,8
    80005b3c:	ff3499e3          	bne	s1,s3,80005b2e <sys_exec+0xe6>
    80005b40:	a011                	j	80005b44 <sys_exec+0xfc>
  return -1;
    80005b42:	597d                	li	s2,-1
}
    80005b44:	854a                	mv	a0,s2
    80005b46:	60be                	ld	ra,456(sp)
    80005b48:	641e                	ld	s0,448(sp)
    80005b4a:	74fa                	ld	s1,440(sp)
    80005b4c:	795a                	ld	s2,432(sp)
    80005b4e:	79ba                	ld	s3,424(sp)
    80005b50:	7a1a                	ld	s4,416(sp)
    80005b52:	6afa                	ld	s5,408(sp)
    80005b54:	6179                	addi	sp,sp,464
    80005b56:	8082                	ret

0000000080005b58 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005b58:	7139                	addi	sp,sp,-64
    80005b5a:	fc06                	sd	ra,56(sp)
    80005b5c:	f822                	sd	s0,48(sp)
    80005b5e:	f426                	sd	s1,40(sp)
    80005b60:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005b62:	ffffc097          	auipc	ra,0xffffc
    80005b66:	e34080e7          	jalr	-460(ra) # 80001996 <myproc>
    80005b6a:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005b6c:	fd840593          	addi	a1,s0,-40
    80005b70:	4501                	li	a0,0
    80005b72:	ffffd097          	auipc	ra,0xffffd
    80005b76:	08c080e7          	jalr	140(ra) # 80002bfe <argaddr>
    return -1;
    80005b7a:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005b7c:	0e054063          	bltz	a0,80005c5c <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005b80:	fc840593          	addi	a1,s0,-56
    80005b84:	fd040513          	addi	a0,s0,-48
    80005b88:	fffff097          	auipc	ra,0xfffff
    80005b8c:	de6080e7          	jalr	-538(ra) # 8000496e <pipealloc>
    return -1;
    80005b90:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005b92:	0c054563          	bltz	a0,80005c5c <sys_pipe+0x104>
  fd0 = -1;
    80005b96:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005b9a:	fd043503          	ld	a0,-48(s0)
    80005b9e:	fffff097          	auipc	ra,0xfffff
    80005ba2:	504080e7          	jalr	1284(ra) # 800050a2 <fdalloc>
    80005ba6:	fca42223          	sw	a0,-60(s0)
    80005baa:	08054c63          	bltz	a0,80005c42 <sys_pipe+0xea>
    80005bae:	fc843503          	ld	a0,-56(s0)
    80005bb2:	fffff097          	auipc	ra,0xfffff
    80005bb6:	4f0080e7          	jalr	1264(ra) # 800050a2 <fdalloc>
    80005bba:	fca42023          	sw	a0,-64(s0)
    80005bbe:	06054963          	bltz	a0,80005c30 <sys_pipe+0xd8>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005bc2:	4691                	li	a3,4
    80005bc4:	fc440613          	addi	a2,s0,-60
    80005bc8:	fd843583          	ld	a1,-40(s0)
    80005bcc:	68a8                	ld	a0,80(s1)
    80005bce:	ffffc097          	auipc	ra,0xffffc
    80005bd2:	a8c080e7          	jalr	-1396(ra) # 8000165a <copyout>
    80005bd6:	02054063          	bltz	a0,80005bf6 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005bda:	4691                	li	a3,4
    80005bdc:	fc040613          	addi	a2,s0,-64
    80005be0:	fd843583          	ld	a1,-40(s0)
    80005be4:	0591                	addi	a1,a1,4
    80005be6:	68a8                	ld	a0,80(s1)
    80005be8:	ffffc097          	auipc	ra,0xffffc
    80005bec:	a72080e7          	jalr	-1422(ra) # 8000165a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005bf0:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005bf2:	06055563          	bgez	a0,80005c5c <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005bf6:	fc442783          	lw	a5,-60(s0)
    80005bfa:	07e9                	addi	a5,a5,26
    80005bfc:	078e                	slli	a5,a5,0x3
    80005bfe:	97a6                	add	a5,a5,s1
    80005c00:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005c04:	fc042783          	lw	a5,-64(s0)
    80005c08:	07e9                	addi	a5,a5,26
    80005c0a:	078e                	slli	a5,a5,0x3
    80005c0c:	00f48533          	add	a0,s1,a5
    80005c10:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005c14:	fd043503          	ld	a0,-48(s0)
    80005c18:	fffff097          	auipc	ra,0xfffff
    80005c1c:	a26080e7          	jalr	-1498(ra) # 8000463e <fileclose>
    fileclose(wf);
    80005c20:	fc843503          	ld	a0,-56(s0)
    80005c24:	fffff097          	auipc	ra,0xfffff
    80005c28:	a1a080e7          	jalr	-1510(ra) # 8000463e <fileclose>
    return -1;
    80005c2c:	57fd                	li	a5,-1
    80005c2e:	a03d                	j	80005c5c <sys_pipe+0x104>
    if(fd0 >= 0)
    80005c30:	fc442783          	lw	a5,-60(s0)
    80005c34:	0007c763          	bltz	a5,80005c42 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005c38:	07e9                	addi	a5,a5,26
    80005c3a:	078e                	slli	a5,a5,0x3
    80005c3c:	97a6                	add	a5,a5,s1
    80005c3e:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005c42:	fd043503          	ld	a0,-48(s0)
    80005c46:	fffff097          	auipc	ra,0xfffff
    80005c4a:	9f8080e7          	jalr	-1544(ra) # 8000463e <fileclose>
    fileclose(wf);
    80005c4e:	fc843503          	ld	a0,-56(s0)
    80005c52:	fffff097          	auipc	ra,0xfffff
    80005c56:	9ec080e7          	jalr	-1556(ra) # 8000463e <fileclose>
    return -1;
    80005c5a:	57fd                	li	a5,-1
}
    80005c5c:	853e                	mv	a0,a5
    80005c5e:	70e2                	ld	ra,56(sp)
    80005c60:	7442                	ld	s0,48(sp)
    80005c62:	74a2                	ld	s1,40(sp)
    80005c64:	6121                	addi	sp,sp,64
    80005c66:	8082                	ret
	...

0000000080005c70 <kernelvec>:
    80005c70:	7111                	addi	sp,sp,-256
    80005c72:	e006                	sd	ra,0(sp)
    80005c74:	e40a                	sd	sp,8(sp)
    80005c76:	e80e                	sd	gp,16(sp)
    80005c78:	ec12                	sd	tp,24(sp)
    80005c7a:	f016                	sd	t0,32(sp)
    80005c7c:	f41a                	sd	t1,40(sp)
    80005c7e:	f81e                	sd	t2,48(sp)
    80005c80:	fc22                	sd	s0,56(sp)
    80005c82:	e0a6                	sd	s1,64(sp)
    80005c84:	e4aa                	sd	a0,72(sp)
    80005c86:	e8ae                	sd	a1,80(sp)
    80005c88:	ecb2                	sd	a2,88(sp)
    80005c8a:	f0b6                	sd	a3,96(sp)
    80005c8c:	f4ba                	sd	a4,104(sp)
    80005c8e:	f8be                	sd	a5,112(sp)
    80005c90:	fcc2                	sd	a6,120(sp)
    80005c92:	e146                	sd	a7,128(sp)
    80005c94:	e54a                	sd	s2,136(sp)
    80005c96:	e94e                	sd	s3,144(sp)
    80005c98:	ed52                	sd	s4,152(sp)
    80005c9a:	f156                	sd	s5,160(sp)
    80005c9c:	f55a                	sd	s6,168(sp)
    80005c9e:	f95e                	sd	s7,176(sp)
    80005ca0:	fd62                	sd	s8,184(sp)
    80005ca2:	e1e6                	sd	s9,192(sp)
    80005ca4:	e5ea                	sd	s10,200(sp)
    80005ca6:	e9ee                	sd	s11,208(sp)
    80005ca8:	edf2                	sd	t3,216(sp)
    80005caa:	f1f6                	sd	t4,224(sp)
    80005cac:	f5fa                	sd	t5,232(sp)
    80005cae:	f9fe                	sd	t6,240(sp)
    80005cb0:	d47fc0ef          	jal	ra,800029f6 <kerneltrap>
    80005cb4:	6082                	ld	ra,0(sp)
    80005cb6:	6122                	ld	sp,8(sp)
    80005cb8:	61c2                	ld	gp,16(sp)
    80005cba:	7282                	ld	t0,32(sp)
    80005cbc:	7322                	ld	t1,40(sp)
    80005cbe:	73c2                	ld	t2,48(sp)
    80005cc0:	7462                	ld	s0,56(sp)
    80005cc2:	6486                	ld	s1,64(sp)
    80005cc4:	6526                	ld	a0,72(sp)
    80005cc6:	65c6                	ld	a1,80(sp)
    80005cc8:	6666                	ld	a2,88(sp)
    80005cca:	7686                	ld	a3,96(sp)
    80005ccc:	7726                	ld	a4,104(sp)
    80005cce:	77c6                	ld	a5,112(sp)
    80005cd0:	7866                	ld	a6,120(sp)
    80005cd2:	688a                	ld	a7,128(sp)
    80005cd4:	692a                	ld	s2,136(sp)
    80005cd6:	69ca                	ld	s3,144(sp)
    80005cd8:	6a6a                	ld	s4,152(sp)
    80005cda:	7a8a                	ld	s5,160(sp)
    80005cdc:	7b2a                	ld	s6,168(sp)
    80005cde:	7bca                	ld	s7,176(sp)
    80005ce0:	7c6a                	ld	s8,184(sp)
    80005ce2:	6c8e                	ld	s9,192(sp)
    80005ce4:	6d2e                	ld	s10,200(sp)
    80005ce6:	6dce                	ld	s11,208(sp)
    80005ce8:	6e6e                	ld	t3,216(sp)
    80005cea:	7e8e                	ld	t4,224(sp)
    80005cec:	7f2e                	ld	t5,232(sp)
    80005cee:	7fce                	ld	t6,240(sp)
    80005cf0:	6111                	addi	sp,sp,256
    80005cf2:	10200073          	sret
    80005cf6:	00000013          	nop
    80005cfa:	00000013          	nop
    80005cfe:	0001                	nop

0000000080005d00 <timervec>:
    80005d00:	34051573          	csrrw	a0,mscratch,a0
    80005d04:	e10c                	sd	a1,0(a0)
    80005d06:	e510                	sd	a2,8(a0)
    80005d08:	e914                	sd	a3,16(a0)
    80005d0a:	6d0c                	ld	a1,24(a0)
    80005d0c:	7110                	ld	a2,32(a0)
    80005d0e:	6194                	ld	a3,0(a1)
    80005d10:	96b2                	add	a3,a3,a2
    80005d12:	e194                	sd	a3,0(a1)
    80005d14:	4589                	li	a1,2
    80005d16:	14459073          	csrw	sip,a1
    80005d1a:	6914                	ld	a3,16(a0)
    80005d1c:	6510                	ld	a2,8(a0)
    80005d1e:	610c                	ld	a1,0(a0)
    80005d20:	34051573          	csrrw	a0,mscratch,a0
    80005d24:	30200073          	mret
	...

0000000080005d2a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005d2a:	1141                	addi	sp,sp,-16
    80005d2c:	e422                	sd	s0,8(sp)
    80005d2e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005d30:	0c0007b7          	lui	a5,0xc000
    80005d34:	4705                	li	a4,1
    80005d36:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005d38:	c3d8                	sw	a4,4(a5)
}
    80005d3a:	6422                	ld	s0,8(sp)
    80005d3c:	0141                	addi	sp,sp,16
    80005d3e:	8082                	ret

0000000080005d40 <plicinithart>:

void
plicinithart(void)
{
    80005d40:	1141                	addi	sp,sp,-16
    80005d42:	e406                	sd	ra,8(sp)
    80005d44:	e022                	sd	s0,0(sp)
    80005d46:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d48:	ffffc097          	auipc	ra,0xffffc
    80005d4c:	c22080e7          	jalr	-990(ra) # 8000196a <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005d50:	0085171b          	slliw	a4,a0,0x8
    80005d54:	0c0027b7          	lui	a5,0xc002
    80005d58:	97ba                	add	a5,a5,a4
    80005d5a:	40200713          	li	a4,1026
    80005d5e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005d62:	00d5151b          	slliw	a0,a0,0xd
    80005d66:	0c2017b7          	lui	a5,0xc201
    80005d6a:	97aa                	add	a5,a5,a0
    80005d6c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005d70:	60a2                	ld	ra,8(sp)
    80005d72:	6402                	ld	s0,0(sp)
    80005d74:	0141                	addi	sp,sp,16
    80005d76:	8082                	ret

0000000080005d78 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005d78:	1141                	addi	sp,sp,-16
    80005d7a:	e406                	sd	ra,8(sp)
    80005d7c:	e022                	sd	s0,0(sp)
    80005d7e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d80:	ffffc097          	auipc	ra,0xffffc
    80005d84:	bea080e7          	jalr	-1046(ra) # 8000196a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005d88:	00d5151b          	slliw	a0,a0,0xd
    80005d8c:	0c2017b7          	lui	a5,0xc201
    80005d90:	97aa                	add	a5,a5,a0
  return irq;
}
    80005d92:	43c8                	lw	a0,4(a5)
    80005d94:	60a2                	ld	ra,8(sp)
    80005d96:	6402                	ld	s0,0(sp)
    80005d98:	0141                	addi	sp,sp,16
    80005d9a:	8082                	ret

0000000080005d9c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005d9c:	1101                	addi	sp,sp,-32
    80005d9e:	ec06                	sd	ra,24(sp)
    80005da0:	e822                	sd	s0,16(sp)
    80005da2:	e426                	sd	s1,8(sp)
    80005da4:	1000                	addi	s0,sp,32
    80005da6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005da8:	ffffc097          	auipc	ra,0xffffc
    80005dac:	bc2080e7          	jalr	-1086(ra) # 8000196a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005db0:	00d5151b          	slliw	a0,a0,0xd
    80005db4:	0c2017b7          	lui	a5,0xc201
    80005db8:	97aa                	add	a5,a5,a0
    80005dba:	c3c4                	sw	s1,4(a5)
}
    80005dbc:	60e2                	ld	ra,24(sp)
    80005dbe:	6442                	ld	s0,16(sp)
    80005dc0:	64a2                	ld	s1,8(sp)
    80005dc2:	6105                	addi	sp,sp,32
    80005dc4:	8082                	ret

0000000080005dc6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005dc6:	1141                	addi	sp,sp,-16
    80005dc8:	e406                	sd	ra,8(sp)
    80005dca:	e022                	sd	s0,0(sp)
    80005dcc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005dce:	479d                	li	a5,7
    80005dd0:	06a7c863          	blt	a5,a0,80005e40 <free_desc+0x7a>
    panic("free_desc 1");
  if(disk.free[i])
    80005dd4:	0001d717          	auipc	a4,0x1d
    80005dd8:	22c70713          	addi	a4,a4,556 # 80023000 <disk>
    80005ddc:	972a                	add	a4,a4,a0
    80005dde:	6789                	lui	a5,0x2
    80005de0:	97ba                	add	a5,a5,a4
    80005de2:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005de6:	e7ad                	bnez	a5,80005e50 <free_desc+0x8a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005de8:	00451793          	slli	a5,a0,0x4
    80005dec:	0001f717          	auipc	a4,0x1f
    80005df0:	21470713          	addi	a4,a4,532 # 80025000 <disk+0x2000>
    80005df4:	6314                	ld	a3,0(a4)
    80005df6:	96be                	add	a3,a3,a5
    80005df8:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005dfc:	6314                	ld	a3,0(a4)
    80005dfe:	96be                	add	a3,a3,a5
    80005e00:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80005e04:	6314                	ld	a3,0(a4)
    80005e06:	96be                	add	a3,a3,a5
    80005e08:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80005e0c:	6318                	ld	a4,0(a4)
    80005e0e:	97ba                	add	a5,a5,a4
    80005e10:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80005e14:	0001d717          	auipc	a4,0x1d
    80005e18:	1ec70713          	addi	a4,a4,492 # 80023000 <disk>
    80005e1c:	972a                	add	a4,a4,a0
    80005e1e:	6789                	lui	a5,0x2
    80005e20:	97ba                	add	a5,a5,a4
    80005e22:	4705                	li	a4,1
    80005e24:	00e78c23          	sb	a4,24(a5) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005e28:	0001f517          	auipc	a0,0x1f
    80005e2c:	1f050513          	addi	a0,a0,496 # 80025018 <disk+0x2018>
    80005e30:	ffffc097          	auipc	ra,0xffffc
    80005e34:	3ba080e7          	jalr	954(ra) # 800021ea <wakeup>
}
    80005e38:	60a2                	ld	ra,8(sp)
    80005e3a:	6402                	ld	s0,0(sp)
    80005e3c:	0141                	addi	sp,sp,16
    80005e3e:	8082                	ret
    panic("free_desc 1");
    80005e40:	00003517          	auipc	a0,0x3
    80005e44:	93050513          	addi	a0,a0,-1744 # 80008770 <syscalls+0x328>
    80005e48:	ffffa097          	auipc	ra,0xffffa
    80005e4c:	6f2080e7          	jalr	1778(ra) # 8000053a <panic>
    panic("free_desc 2");
    80005e50:	00003517          	auipc	a0,0x3
    80005e54:	93050513          	addi	a0,a0,-1744 # 80008780 <syscalls+0x338>
    80005e58:	ffffa097          	auipc	ra,0xffffa
    80005e5c:	6e2080e7          	jalr	1762(ra) # 8000053a <panic>

0000000080005e60 <virtio_disk_init>:
{
    80005e60:	1101                	addi	sp,sp,-32
    80005e62:	ec06                	sd	ra,24(sp)
    80005e64:	e822                	sd	s0,16(sp)
    80005e66:	e426                	sd	s1,8(sp)
    80005e68:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005e6a:	00003597          	auipc	a1,0x3
    80005e6e:	92658593          	addi	a1,a1,-1754 # 80008790 <syscalls+0x348>
    80005e72:	0001f517          	auipc	a0,0x1f
    80005e76:	2b650513          	addi	a0,a0,694 # 80025128 <disk+0x2128>
    80005e7a:	ffffb097          	auipc	ra,0xffffb
    80005e7e:	cc6080e7          	jalr	-826(ra) # 80000b40 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e82:	100017b7          	lui	a5,0x10001
    80005e86:	4398                	lw	a4,0(a5)
    80005e88:	2701                	sext.w	a4,a4
    80005e8a:	747277b7          	lui	a5,0x74727
    80005e8e:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005e92:	0ef71063          	bne	a4,a5,80005f72 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005e96:	100017b7          	lui	a5,0x10001
    80005e9a:	43dc                	lw	a5,4(a5)
    80005e9c:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e9e:	4705                	li	a4,1
    80005ea0:	0ce79963          	bne	a5,a4,80005f72 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005ea4:	100017b7          	lui	a5,0x10001
    80005ea8:	479c                	lw	a5,8(a5)
    80005eaa:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005eac:	4709                	li	a4,2
    80005eae:	0ce79263          	bne	a5,a4,80005f72 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005eb2:	100017b7          	lui	a5,0x10001
    80005eb6:	47d8                	lw	a4,12(a5)
    80005eb8:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005eba:	554d47b7          	lui	a5,0x554d4
    80005ebe:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005ec2:	0af71863          	bne	a4,a5,80005f72 <virtio_disk_init+0x112>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ec6:	100017b7          	lui	a5,0x10001
    80005eca:	4705                	li	a4,1
    80005ecc:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ece:	470d                	li	a4,3
    80005ed0:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005ed2:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005ed4:	c7ffe6b7          	lui	a3,0xc7ffe
    80005ed8:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    80005edc:	8f75                	and	a4,a4,a3
    80005ede:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ee0:	472d                	li	a4,11
    80005ee2:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ee4:	473d                	li	a4,15
    80005ee6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005ee8:	6705                	lui	a4,0x1
    80005eea:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005eec:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005ef0:	5bdc                	lw	a5,52(a5)
    80005ef2:	2781                	sext.w	a5,a5
  if(max == 0)
    80005ef4:	c7d9                	beqz	a5,80005f82 <virtio_disk_init+0x122>
  if(max < NUM)
    80005ef6:	471d                	li	a4,7
    80005ef8:	08f77d63          	bgeu	a4,a5,80005f92 <virtio_disk_init+0x132>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005efc:	100014b7          	lui	s1,0x10001
    80005f00:	47a1                	li	a5,8
    80005f02:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80005f04:	6609                	lui	a2,0x2
    80005f06:	4581                	li	a1,0
    80005f08:	0001d517          	auipc	a0,0x1d
    80005f0c:	0f850513          	addi	a0,a0,248 # 80023000 <disk>
    80005f10:	ffffb097          	auipc	ra,0xffffb
    80005f14:	dbc080e7          	jalr	-580(ra) # 80000ccc <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80005f18:	0001d717          	auipc	a4,0x1d
    80005f1c:	0e870713          	addi	a4,a4,232 # 80023000 <disk>
    80005f20:	00c75793          	srli	a5,a4,0xc
    80005f24:	2781                	sext.w	a5,a5
    80005f26:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80005f28:	0001f797          	auipc	a5,0x1f
    80005f2c:	0d878793          	addi	a5,a5,216 # 80025000 <disk+0x2000>
    80005f30:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80005f32:	0001d717          	auipc	a4,0x1d
    80005f36:	14e70713          	addi	a4,a4,334 # 80023080 <disk+0x80>
    80005f3a:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80005f3c:	0001e717          	auipc	a4,0x1e
    80005f40:	0c470713          	addi	a4,a4,196 # 80024000 <disk+0x1000>
    80005f44:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80005f46:	4705                	li	a4,1
    80005f48:	00e78c23          	sb	a4,24(a5)
    80005f4c:	00e78ca3          	sb	a4,25(a5)
    80005f50:	00e78d23          	sb	a4,26(a5)
    80005f54:	00e78da3          	sb	a4,27(a5)
    80005f58:	00e78e23          	sb	a4,28(a5)
    80005f5c:	00e78ea3          	sb	a4,29(a5)
    80005f60:	00e78f23          	sb	a4,30(a5)
    80005f64:	00e78fa3          	sb	a4,31(a5)
}
    80005f68:	60e2                	ld	ra,24(sp)
    80005f6a:	6442                	ld	s0,16(sp)
    80005f6c:	64a2                	ld	s1,8(sp)
    80005f6e:	6105                	addi	sp,sp,32
    80005f70:	8082                	ret
    panic("could not find virtio disk");
    80005f72:	00003517          	auipc	a0,0x3
    80005f76:	82e50513          	addi	a0,a0,-2002 # 800087a0 <syscalls+0x358>
    80005f7a:	ffffa097          	auipc	ra,0xffffa
    80005f7e:	5c0080e7          	jalr	1472(ra) # 8000053a <panic>
    panic("virtio disk has no queue 0");
    80005f82:	00003517          	auipc	a0,0x3
    80005f86:	83e50513          	addi	a0,a0,-1986 # 800087c0 <syscalls+0x378>
    80005f8a:	ffffa097          	auipc	ra,0xffffa
    80005f8e:	5b0080e7          	jalr	1456(ra) # 8000053a <panic>
    panic("virtio disk max queue too short");
    80005f92:	00003517          	auipc	a0,0x3
    80005f96:	84e50513          	addi	a0,a0,-1970 # 800087e0 <syscalls+0x398>
    80005f9a:	ffffa097          	auipc	ra,0xffffa
    80005f9e:	5a0080e7          	jalr	1440(ra) # 8000053a <panic>

0000000080005fa2 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005fa2:	7119                	addi	sp,sp,-128
    80005fa4:	fc86                	sd	ra,120(sp)
    80005fa6:	f8a2                	sd	s0,112(sp)
    80005fa8:	f4a6                	sd	s1,104(sp)
    80005faa:	f0ca                	sd	s2,96(sp)
    80005fac:	ecce                	sd	s3,88(sp)
    80005fae:	e8d2                	sd	s4,80(sp)
    80005fb0:	e4d6                	sd	s5,72(sp)
    80005fb2:	e0da                	sd	s6,64(sp)
    80005fb4:	fc5e                	sd	s7,56(sp)
    80005fb6:	f862                	sd	s8,48(sp)
    80005fb8:	f466                	sd	s9,40(sp)
    80005fba:	f06a                	sd	s10,32(sp)
    80005fbc:	ec6e                	sd	s11,24(sp)
    80005fbe:	0100                	addi	s0,sp,128
    80005fc0:	8aaa                	mv	s5,a0
    80005fc2:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005fc4:	00c52c83          	lw	s9,12(a0)
    80005fc8:	001c9c9b          	slliw	s9,s9,0x1
    80005fcc:	1c82                	slli	s9,s9,0x20
    80005fce:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005fd2:	0001f517          	auipc	a0,0x1f
    80005fd6:	15650513          	addi	a0,a0,342 # 80025128 <disk+0x2128>
    80005fda:	ffffb097          	auipc	ra,0xffffb
    80005fde:	bf6080e7          	jalr	-1034(ra) # 80000bd0 <acquire>
  for(int i = 0; i < 3; i++){
    80005fe2:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005fe4:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005fe6:	0001dc17          	auipc	s8,0x1d
    80005fea:	01ac0c13          	addi	s8,s8,26 # 80023000 <disk>
    80005fee:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80005ff0:	4b0d                	li	s6,3
    80005ff2:	a0ad                	j	8000605c <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80005ff4:	00fc0733          	add	a4,s8,a5
    80005ff8:	975e                	add	a4,a4,s7
    80005ffa:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005ffe:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006000:	0207c563          	bltz	a5,8000602a <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006004:	2905                	addiw	s2,s2,1
    80006006:	0611                	addi	a2,a2,4 # 2004 <_entry-0x7fffdffc>
    80006008:	19690c63          	beq	s2,s6,800061a0 <virtio_disk_rw+0x1fe>
    idx[i] = alloc_desc();
    8000600c:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    8000600e:	0001f717          	auipc	a4,0x1f
    80006012:	00a70713          	addi	a4,a4,10 # 80025018 <disk+0x2018>
    80006016:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006018:	00074683          	lbu	a3,0(a4)
    8000601c:	fee1                	bnez	a3,80005ff4 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    8000601e:	2785                	addiw	a5,a5,1
    80006020:	0705                	addi	a4,a4,1
    80006022:	fe979be3          	bne	a5,s1,80006018 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006026:	57fd                	li	a5,-1
    80006028:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000602a:	01205d63          	blez	s2,80006044 <virtio_disk_rw+0xa2>
    8000602e:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006030:	000a2503          	lw	a0,0(s4)
    80006034:	00000097          	auipc	ra,0x0
    80006038:	d92080e7          	jalr	-622(ra) # 80005dc6 <free_desc>
      for(int j = 0; j < i; j++)
    8000603c:	2d85                	addiw	s11,s11,1
    8000603e:	0a11                	addi	s4,s4,4
    80006040:	ff2d98e3          	bne	s11,s2,80006030 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006044:	0001f597          	auipc	a1,0x1f
    80006048:	0e458593          	addi	a1,a1,228 # 80025128 <disk+0x2128>
    8000604c:	0001f517          	auipc	a0,0x1f
    80006050:	fcc50513          	addi	a0,a0,-52 # 80025018 <disk+0x2018>
    80006054:	ffffc097          	auipc	ra,0xffffc
    80006058:	00a080e7          	jalr	10(ra) # 8000205e <sleep>
  for(int i = 0; i < 3; i++){
    8000605c:	f8040a13          	addi	s4,s0,-128
{
    80006060:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006062:	894e                	mv	s2,s3
    80006064:	b765                	j	8000600c <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006066:	0001f697          	auipc	a3,0x1f
    8000606a:	f9a6b683          	ld	a3,-102(a3) # 80025000 <disk+0x2000>
    8000606e:	96ba                	add	a3,a3,a4
    80006070:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006074:	0001d817          	auipc	a6,0x1d
    80006078:	f8c80813          	addi	a6,a6,-116 # 80023000 <disk>
    8000607c:	0001f697          	auipc	a3,0x1f
    80006080:	f8468693          	addi	a3,a3,-124 # 80025000 <disk+0x2000>
    80006084:	6290                	ld	a2,0(a3)
    80006086:	963a                	add	a2,a2,a4
    80006088:	00c65583          	lhu	a1,12(a2)
    8000608c:	0015e593          	ori	a1,a1,1
    80006090:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80006094:	f8842603          	lw	a2,-120(s0)
    80006098:	628c                	ld	a1,0(a3)
    8000609a:	972e                	add	a4,a4,a1
    8000609c:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800060a0:	20050593          	addi	a1,a0,512
    800060a4:	0592                	slli	a1,a1,0x4
    800060a6:	95c2                	add	a1,a1,a6
    800060a8:	577d                	li	a4,-1
    800060aa:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800060ae:	00461713          	slli	a4,a2,0x4
    800060b2:	6290                	ld	a2,0(a3)
    800060b4:	963a                	add	a2,a2,a4
    800060b6:	03078793          	addi	a5,a5,48
    800060ba:	97c2                	add	a5,a5,a6
    800060bc:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    800060be:	629c                	ld	a5,0(a3)
    800060c0:	97ba                	add	a5,a5,a4
    800060c2:	4605                	li	a2,1
    800060c4:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800060c6:	629c                	ld	a5,0(a3)
    800060c8:	97ba                	add	a5,a5,a4
    800060ca:	4809                	li	a6,2
    800060cc:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    800060d0:	629c                	ld	a5,0(a3)
    800060d2:	97ba                	add	a5,a5,a4
    800060d4:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800060d8:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800060dc:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800060e0:	6698                	ld	a4,8(a3)
    800060e2:	00275783          	lhu	a5,2(a4)
    800060e6:	8b9d                	andi	a5,a5,7
    800060e8:	0786                	slli	a5,a5,0x1
    800060ea:	973e                	add	a4,a4,a5
    800060ec:	00a71223          	sh	a0,4(a4)

  __sync_synchronize();
    800060f0:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800060f4:	6698                	ld	a4,8(a3)
    800060f6:	00275783          	lhu	a5,2(a4)
    800060fa:	2785                	addiw	a5,a5,1
    800060fc:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006100:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006104:	100017b7          	lui	a5,0x10001
    80006108:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000610c:	004aa783          	lw	a5,4(s5)
    80006110:	02c79163          	bne	a5,a2,80006132 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80006114:	0001f917          	auipc	s2,0x1f
    80006118:	01490913          	addi	s2,s2,20 # 80025128 <disk+0x2128>
  while(b->disk == 1) {
    8000611c:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    8000611e:	85ca                	mv	a1,s2
    80006120:	8556                	mv	a0,s5
    80006122:	ffffc097          	auipc	ra,0xffffc
    80006126:	f3c080e7          	jalr	-196(ra) # 8000205e <sleep>
  while(b->disk == 1) {
    8000612a:	004aa783          	lw	a5,4(s5)
    8000612e:	fe9788e3          	beq	a5,s1,8000611e <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80006132:	f8042903          	lw	s2,-128(s0)
    80006136:	20090713          	addi	a4,s2,512
    8000613a:	0712                	slli	a4,a4,0x4
    8000613c:	0001d797          	auipc	a5,0x1d
    80006140:	ec478793          	addi	a5,a5,-316 # 80023000 <disk>
    80006144:	97ba                	add	a5,a5,a4
    80006146:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    8000614a:	0001f997          	auipc	s3,0x1f
    8000614e:	eb698993          	addi	s3,s3,-330 # 80025000 <disk+0x2000>
    80006152:	00491713          	slli	a4,s2,0x4
    80006156:	0009b783          	ld	a5,0(s3)
    8000615a:	97ba                	add	a5,a5,a4
    8000615c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006160:	854a                	mv	a0,s2
    80006162:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006166:	00000097          	auipc	ra,0x0
    8000616a:	c60080e7          	jalr	-928(ra) # 80005dc6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000616e:	8885                	andi	s1,s1,1
    80006170:	f0ed                	bnez	s1,80006152 <virtio_disk_rw+0x1b0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006172:	0001f517          	auipc	a0,0x1f
    80006176:	fb650513          	addi	a0,a0,-74 # 80025128 <disk+0x2128>
    8000617a:	ffffb097          	auipc	ra,0xffffb
    8000617e:	b0a080e7          	jalr	-1270(ra) # 80000c84 <release>
}
    80006182:	70e6                	ld	ra,120(sp)
    80006184:	7446                	ld	s0,112(sp)
    80006186:	74a6                	ld	s1,104(sp)
    80006188:	7906                	ld	s2,96(sp)
    8000618a:	69e6                	ld	s3,88(sp)
    8000618c:	6a46                	ld	s4,80(sp)
    8000618e:	6aa6                	ld	s5,72(sp)
    80006190:	6b06                	ld	s6,64(sp)
    80006192:	7be2                	ld	s7,56(sp)
    80006194:	7c42                	ld	s8,48(sp)
    80006196:	7ca2                	ld	s9,40(sp)
    80006198:	7d02                	ld	s10,32(sp)
    8000619a:	6de2                	ld	s11,24(sp)
    8000619c:	6109                	addi	sp,sp,128
    8000619e:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800061a0:	f8042503          	lw	a0,-128(s0)
    800061a4:	20050793          	addi	a5,a0,512
    800061a8:	0792                	slli	a5,a5,0x4
  if(write)
    800061aa:	0001d817          	auipc	a6,0x1d
    800061ae:	e5680813          	addi	a6,a6,-426 # 80023000 <disk>
    800061b2:	00f80733          	add	a4,a6,a5
    800061b6:	01a036b3          	snez	a3,s10
    800061ba:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    800061be:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    800061c2:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    800061c6:	7679                	lui	a2,0xffffe
    800061c8:	963e                	add	a2,a2,a5
    800061ca:	0001f697          	auipc	a3,0x1f
    800061ce:	e3668693          	addi	a3,a3,-458 # 80025000 <disk+0x2000>
    800061d2:	6298                	ld	a4,0(a3)
    800061d4:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800061d6:	0a878593          	addi	a1,a5,168
    800061da:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    800061dc:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800061de:	6298                	ld	a4,0(a3)
    800061e0:	9732                	add	a4,a4,a2
    800061e2:	45c1                	li	a1,16
    800061e4:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800061e6:	6298                	ld	a4,0(a3)
    800061e8:	9732                	add	a4,a4,a2
    800061ea:	4585                	li	a1,1
    800061ec:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    800061f0:	f8442703          	lw	a4,-124(s0)
    800061f4:	628c                	ld	a1,0(a3)
    800061f6:	962e                	add	a2,a2,a1
    800061f8:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd800e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    800061fc:	0712                	slli	a4,a4,0x4
    800061fe:	6290                	ld	a2,0(a3)
    80006200:	963a                	add	a2,a2,a4
    80006202:	058a8593          	addi	a1,s5,88
    80006206:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006208:	6294                	ld	a3,0(a3)
    8000620a:	96ba                	add	a3,a3,a4
    8000620c:	40000613          	li	a2,1024
    80006210:	c690                	sw	a2,8(a3)
  if(write)
    80006212:	e40d1ae3          	bnez	s10,80006066 <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006216:	0001f697          	auipc	a3,0x1f
    8000621a:	dea6b683          	ld	a3,-534(a3) # 80025000 <disk+0x2000>
    8000621e:	96ba                	add	a3,a3,a4
    80006220:	4609                	li	a2,2
    80006222:	00c69623          	sh	a2,12(a3)
    80006226:	b5b9                	j	80006074 <virtio_disk_rw+0xd2>

0000000080006228 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006228:	1101                	addi	sp,sp,-32
    8000622a:	ec06                	sd	ra,24(sp)
    8000622c:	e822                	sd	s0,16(sp)
    8000622e:	e426                	sd	s1,8(sp)
    80006230:	e04a                	sd	s2,0(sp)
    80006232:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006234:	0001f517          	auipc	a0,0x1f
    80006238:	ef450513          	addi	a0,a0,-268 # 80025128 <disk+0x2128>
    8000623c:	ffffb097          	auipc	ra,0xffffb
    80006240:	994080e7          	jalr	-1644(ra) # 80000bd0 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006244:	10001737          	lui	a4,0x10001
    80006248:	533c                	lw	a5,96(a4)
    8000624a:	8b8d                	andi	a5,a5,3
    8000624c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000624e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006252:	0001f797          	auipc	a5,0x1f
    80006256:	dae78793          	addi	a5,a5,-594 # 80025000 <disk+0x2000>
    8000625a:	6b94                	ld	a3,16(a5)
    8000625c:	0207d703          	lhu	a4,32(a5)
    80006260:	0026d783          	lhu	a5,2(a3)
    80006264:	06f70163          	beq	a4,a5,800062c6 <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006268:	0001d917          	auipc	s2,0x1d
    8000626c:	d9890913          	addi	s2,s2,-616 # 80023000 <disk>
    80006270:	0001f497          	auipc	s1,0x1f
    80006274:	d9048493          	addi	s1,s1,-624 # 80025000 <disk+0x2000>
    __sync_synchronize();
    80006278:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000627c:	6898                	ld	a4,16(s1)
    8000627e:	0204d783          	lhu	a5,32(s1)
    80006282:	8b9d                	andi	a5,a5,7
    80006284:	078e                	slli	a5,a5,0x3
    80006286:	97ba                	add	a5,a5,a4
    80006288:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    8000628a:	20078713          	addi	a4,a5,512
    8000628e:	0712                	slli	a4,a4,0x4
    80006290:	974a                	add	a4,a4,s2
    80006292:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    80006296:	e731                	bnez	a4,800062e2 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006298:	20078793          	addi	a5,a5,512
    8000629c:	0792                	slli	a5,a5,0x4
    8000629e:	97ca                	add	a5,a5,s2
    800062a0:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    800062a2:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800062a6:	ffffc097          	auipc	ra,0xffffc
    800062aa:	f44080e7          	jalr	-188(ra) # 800021ea <wakeup>

    disk.used_idx += 1;
    800062ae:	0204d783          	lhu	a5,32(s1)
    800062b2:	2785                	addiw	a5,a5,1
    800062b4:	17c2                	slli	a5,a5,0x30
    800062b6:	93c1                	srli	a5,a5,0x30
    800062b8:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800062bc:	6898                	ld	a4,16(s1)
    800062be:	00275703          	lhu	a4,2(a4)
    800062c2:	faf71be3          	bne	a4,a5,80006278 <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    800062c6:	0001f517          	auipc	a0,0x1f
    800062ca:	e6250513          	addi	a0,a0,-414 # 80025128 <disk+0x2128>
    800062ce:	ffffb097          	auipc	ra,0xffffb
    800062d2:	9b6080e7          	jalr	-1610(ra) # 80000c84 <release>
}
    800062d6:	60e2                	ld	ra,24(sp)
    800062d8:	6442                	ld	s0,16(sp)
    800062da:	64a2                	ld	s1,8(sp)
    800062dc:	6902                	ld	s2,0(sp)
    800062de:	6105                	addi	sp,sp,32
    800062e0:	8082                	ret
      panic("virtio_disk_intr status");
    800062e2:	00002517          	auipc	a0,0x2
    800062e6:	51e50513          	addi	a0,a0,1310 # 80008800 <syscalls+0x3b8>
    800062ea:	ffffa097          	auipc	ra,0xffffa
    800062ee:	250080e7          	jalr	592(ra) # 8000053a <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
