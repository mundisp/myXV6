
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	88013103          	ld	sp,-1920(sp) # 80008880 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000066:	dee78793          	addi	a5,a5,-530 # 80005e50 <timervec>
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
    8000012e:	338080e7          	jalr	824(ra) # 80002462 <either_copyin>
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
    80000210:	200080e7          	jalr	512(ra) # 8000240c <either_copyout>
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
    800002f0:	1cc080e7          	jalr	460(ra) # 800024b8 <procdump>
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
    80000476:	2a678793          	addi	a5,a5,678 # 80021718 <devsw>
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
    80000ebc:	96e080e7          	jalr	-1682(ra) # 80002826 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec0:	00005097          	auipc	ra,0x5
    80000ec4:	fd0080e7          	jalr	-48(ra) # 80005e90 <plicinithart>
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
    80000f34:	8ce080e7          	jalr	-1842(ra) # 800027fe <trapinit>
    trapinithart();  // install kernel trap vector
    80000f38:	00002097          	auipc	ra,0x2
    80000f3c:	8ee080e7          	jalr	-1810(ra) # 80002826 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f40:	00005097          	auipc	ra,0x5
    80000f44:	f3a080e7          	jalr	-198(ra) # 80005e7a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f48:	00005097          	auipc	ra,0x5
    80000f4c:	f48080e7          	jalr	-184(ra) # 80005e90 <plicinithart>
    binit();         // buffer cache
    80000f50:	00002097          	auipc	ra,0x2
    80000f54:	104080e7          	jalr	260(ra) # 80003054 <binit>
    iinit();         // inode table
    80000f58:	00002097          	auipc	ra,0x2
    80000f5c:	792080e7          	jalr	1938(ra) # 800036ea <iinit>
    fileinit();      // file table
    80000f60:	00003097          	auipc	ra,0x3
    80000f64:	744080e7          	jalr	1860(ra) # 800046a4 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f68:	00005097          	auipc	ra,0x5
    80000f6c:	048080e7          	jalr	72(ra) # 80005fb0 <virtio_disk_init>
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
    80001858:	c7ca0a13          	addi	s4,s4,-900 # 800174d0 <tickslock>
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
    8000188e:	17848493          	addi	s1,s1,376
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
    80001920:	00016997          	auipc	s3,0x16
    80001924:	bb098993          	addi	s3,s3,-1104 # 800174d0 <tickslock>
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
    8000194c:	e8bc                	sd	a5,80(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000194e:	17848493          	addi	s1,s1,376
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
    800019ea:	e4a7a783          	lw	a5,-438(a5) # 80008830 <first.1>
    800019ee:	eb89                	bnez	a5,80001a00 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    800019f0:	00001097          	auipc	ra,0x1
    800019f4:	e4e080e7          	jalr	-434(ra) # 8000283e <usertrapret>
}
    800019f8:	60a2                	ld	ra,8(sp)
    800019fa:	6402                	ld	s0,0(sp)
    800019fc:	0141                	addi	sp,sp,16
    800019fe:	8082                	ret
    first = 0;
    80001a00:	00007797          	auipc	a5,0x7
    80001a04:	e207a823          	sw	zero,-464(a5) # 80008830 <first.1>
    fsinit(ROOTDEV);
    80001a08:	4505                	li	a0,1
    80001a0a:	00002097          	auipc	ra,0x2
    80001a0e:	c60080e7          	jalr	-928(ra) # 8000366a <fsinit>
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
    80001a36:	e0278793          	addi	a5,a5,-510 # 80008834 <nextpid>
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
    80001a96:	06893683          	ld	a3,104(s2)
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
    80001b54:	7528                	ld	a0,104(a0)
    80001b56:	c509                	beqz	a0,80001b60 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b58:	fffff097          	auipc	ra,0xfffff
    80001b5c:	e8a080e7          	jalr	-374(ra) # 800009e2 <kfree>
  p->trapframe = 0;
    80001b60:	0604b423          	sd	zero,104(s1)
  if(p->pagetable)
    80001b64:	70a8                	ld	a0,96(s1)
    80001b66:	c511                	beqz	a0,80001b72 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b68:	6cac                	ld	a1,88(s1)
    80001b6a:	00000097          	auipc	ra,0x0
    80001b6e:	f8c080e7          	jalr	-116(ra) # 80001af6 <proc_freepagetable>
  p->pagetable = 0;
    80001b72:	0604b023          	sd	zero,96(s1)
  p->sz = 0;
    80001b76:	0404bc23          	sd	zero,88(s1)
  p->pid = 0;
    80001b7a:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b7e:	0404b423          	sd	zero,72(s1)
  p->name[0] = 0;
    80001b82:	16048423          	sb	zero,360(s1)
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
    80001bb4:	00016917          	auipc	s2,0x16
    80001bb8:	91c90913          	addi	s2,s2,-1764 # 800174d0 <tickslock>
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
    80001bd8:	17848493          	addi	s1,s1,376
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
    80001bfc:	f4a8                	sd	a0,104(s1)
    80001bfe:	c131                	beqz	a0,80001c42 <allocproc+0xa2>
  p->pagetable = proc_pagetable(p);
    80001c00:	8526                	mv	a0,s1
    80001c02:	00000097          	auipc	ra,0x0
    80001c06:	e58080e7          	jalr	-424(ra) # 80001a5a <proc_pagetable>
    80001c0a:	892a                	mv	s2,a0
    80001c0c:	f0a8                	sd	a0,96(s1)
  if(p->pagetable == 0){
    80001c0e:	c531                	beqz	a0,80001c5a <allocproc+0xba>
  memset(&p->context, 0, sizeof(p->context));
    80001c10:	07000613          	li	a2,112
    80001c14:	4581                	li	a1,0
    80001c16:	07048513          	addi	a0,s1,112
    80001c1a:	fffff097          	auipc	ra,0xfffff
    80001c1e:	0b2080e7          	jalr	178(ra) # 80000ccc <memset>
  p->context.ra = (uint64)forkret;
    80001c22:	00000797          	auipc	a5,0x0
    80001c26:	dac78793          	addi	a5,a5,-596 # 800019ce <forkret>
    80001c2a:	f8bc                	sd	a5,112(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c2c:	68bc                	ld	a5,80(s1)
    80001c2e:	6705                	lui	a4,0x1
    80001c30:	97ba                	add	a5,a5,a4
    80001c32:	fcbc                	sd	a5,120(s1)
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
    80001c96:	bae58593          	addi	a1,a1,-1106 # 80008840 <initcode>
    80001c9a:	7128                	ld	a0,96(a0)
    80001c9c:	fffff097          	auipc	ra,0xfffff
    80001ca0:	6b0080e7          	jalr	1712(ra) # 8000134c <uvminit>
  p->sz = PGSIZE;
    80001ca4:	6785                	lui	a5,0x1
    80001ca6:	ecbc                	sd	a5,88(s1)
  p->trapframe->epc = 0;      // user program counter
    80001ca8:	74b8                	ld	a4,104(s1)
    80001caa:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cae:	74b8                	ld	a4,104(s1)
    80001cb0:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cb2:	4641                	li	a2,16
    80001cb4:	00006597          	auipc	a1,0x6
    80001cb8:	54c58593          	addi	a1,a1,1356 # 80008200 <digits+0x1c0>
    80001cbc:	16848513          	addi	a0,s1,360
    80001cc0:	fffff097          	auipc	ra,0xfffff
    80001cc4:	156080e7          	jalr	342(ra) # 80000e16 <safestrcpy>
  p->cwd = namei("/");
    80001cc8:	00006517          	auipc	a0,0x6
    80001ccc:	54850513          	addi	a0,a0,1352 # 80008210 <digits+0x1d0>
    80001cd0:	00002097          	auipc	ra,0x2
    80001cd4:	3d0080e7          	jalr	976(ra) # 800040a0 <namei>
    80001cd8:	16a4b023          	sd	a0,352(s1)
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
    80001d0c:	6d2c                	ld	a1,88(a0)
    80001d0e:	0005879b          	sext.w	a5,a1
  if(n > 0){
    80001d12:	00904f63          	bgtz	s1,80001d30 <growproc+0x3c>
  } else if(n < 0){
    80001d16:	0204cd63          	bltz	s1,80001d50 <growproc+0x5c>
  p->sz = sz;
    80001d1a:	1782                	slli	a5,a5,0x20
    80001d1c:	9381                	srli	a5,a5,0x20
    80001d1e:	04f93c23          	sd	a5,88(s2)
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
    80001d3c:	7128                	ld	a0,96(a0)
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
    80001d5c:	7128                	ld	a0,96(a0)
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
    80001d96:	058ab603          	ld	a2,88(s5)
    80001d9a:	712c                	ld	a1,96(a0)
    80001d9c:	060ab503          	ld	a0,96(s5)
    80001da0:	fffff097          	auipc	ra,0xfffff
    80001da4:	7b6080e7          	jalr	1974(ra) # 80001556 <uvmcopy>
    80001da8:	04054863          	bltz	a0,80001df8 <fork+0x8c>
  np->sz = p->sz;
    80001dac:	058ab783          	ld	a5,88(s5)
    80001db0:	04fa3c23          	sd	a5,88(s4)
  *(np->trapframe) = *(p->trapframe);
    80001db4:	068ab683          	ld	a3,104(s5)
    80001db8:	87b6                	mv	a5,a3
    80001dba:	068a3703          	ld	a4,104(s4)
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
    80001de2:	068a3783          	ld	a5,104(s4)
    80001de6:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001dea:	0e0a8493          	addi	s1,s5,224
    80001dee:	0e0a0913          	addi	s2,s4,224
    80001df2:	160a8993          	addi	s3,s5,352
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
    80001e1c:	00003097          	auipc	ra,0x3
    80001e20:	91a080e7          	jalr	-1766(ra) # 80004736 <filedup>
    80001e24:	00a93023          	sd	a0,0(s2)
    80001e28:	b7e5                	j	80001e10 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e2a:	160ab503          	ld	a0,352(s5)
    80001e2e:	00002097          	auipc	ra,0x2
    80001e32:	a78080e7          	jalr	-1416(ra) # 800038a6 <idup>
    80001e36:	16aa3023          	sd	a0,352(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e3a:	4641                	li	a2,16
    80001e3c:	168a8593          	addi	a1,s5,360
    80001e40:	168a0513          	addi	a0,s4,360
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
    80001e6c:	055a3423          	sd	s5,72(s4)
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
    80001ef4:	5e090913          	addi	s2,s2,1504 # 800174d0 <tickslock>
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
    80001f18:	17848493          	addi	s1,s1,376
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
    80001f38:	07048593          	addi	a1,s1,112
    80001f3c:	8556                	mv	a0,s5
    80001f3e:	00001097          	auipc	ra,0x1
    80001f42:	856080e7          	jalr	-1962(ra) # 80002794 <swtch>
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
    80001fbc:	07048513          	addi	a0,s1,112
    80001fc0:	00000097          	auipc	ra,0x0
    80001fc4:	7d4080e7          	jalr	2004(ra) # 80002794 <swtch>
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
    80002100:	3d498993          	addi	s3,s3,980 # 800174d0 <tickslock>
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
    80002128:	06093503          	ld	a0,96(s2)
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
    8000217c:	17848493          	addi	s1,s1,376
    80002180:	03348463          	beq	s1,s3,800021a8 <wait+0xe6>
      if(np->parent == p){
    80002184:	64bc                	ld	a5,72(s1)
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
    8000220e:	2c690913          	addi	s2,s2,710 # 800174d0 <tickslock>
    80002212:	a811                	j	80002226 <wakeup+0x3c>
        p->readytime = sys_uptime();
      }
      release(&p->lock);
    80002214:	8526                	mv	a0,s1
    80002216:	fffff097          	auipc	ra,0xfffff
    8000221a:	a6e080e7          	jalr	-1426(ra) # 80000c84 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000221e:	17848493          	addi	s1,s1,376
    80002222:	03248b63          	beq	s1,s2,80002258 <wakeup+0x6e>
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
        p->readytime = sys_uptime();
    8000224c:	00001097          	auipc	ra,0x1
    80002250:	cf8080e7          	jalr	-776(ra) # 80002f44 <sys_uptime>
    80002254:	e0a8                	sd	a0,64(s1)
    80002256:	bf7d                	j	80002214 <wakeup+0x2a>
    }
  }
}
    80002258:	70e2                	ld	ra,56(sp)
    8000225a:	7442                	ld	s0,48(sp)
    8000225c:	74a2                	ld	s1,40(sp)
    8000225e:	7902                	ld	s2,32(sp)
    80002260:	69e2                	ld	s3,24(sp)
    80002262:	6a42                	ld	s4,16(sp)
    80002264:	6aa2                	ld	s5,8(sp)
    80002266:	6121                	addi	sp,sp,64
    80002268:	8082                	ret

000000008000226a <reparent>:
{
    8000226a:	7179                	addi	sp,sp,-48
    8000226c:	f406                	sd	ra,40(sp)
    8000226e:	f022                	sd	s0,32(sp)
    80002270:	ec26                	sd	s1,24(sp)
    80002272:	e84a                	sd	s2,16(sp)
    80002274:	e44e                	sd	s3,8(sp)
    80002276:	e052                	sd	s4,0(sp)
    80002278:	1800                	addi	s0,sp,48
    8000227a:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000227c:	0000f497          	auipc	s1,0xf
    80002280:	45448493          	addi	s1,s1,1108 # 800116d0 <proc>
      pp->parent = initproc;
    80002284:	00007a17          	auipc	s4,0x7
    80002288:	da4a0a13          	addi	s4,s4,-604 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000228c:	00015997          	auipc	s3,0x15
    80002290:	24498993          	addi	s3,s3,580 # 800174d0 <tickslock>
    80002294:	a029                	j	8000229e <reparent+0x34>
    80002296:	17848493          	addi	s1,s1,376
    8000229a:	01348d63          	beq	s1,s3,800022b4 <reparent+0x4a>
    if(pp->parent == p){
    8000229e:	64bc                	ld	a5,72(s1)
    800022a0:	ff279be3          	bne	a5,s2,80002296 <reparent+0x2c>
      pp->parent = initproc;
    800022a4:	000a3503          	ld	a0,0(s4)
    800022a8:	e4a8                	sd	a0,72(s1)
      wakeup(initproc);
    800022aa:	00000097          	auipc	ra,0x0
    800022ae:	f40080e7          	jalr	-192(ra) # 800021ea <wakeup>
    800022b2:	b7d5                	j	80002296 <reparent+0x2c>
}
    800022b4:	70a2                	ld	ra,40(sp)
    800022b6:	7402                	ld	s0,32(sp)
    800022b8:	64e2                	ld	s1,24(sp)
    800022ba:	6942                	ld	s2,16(sp)
    800022bc:	69a2                	ld	s3,8(sp)
    800022be:	6a02                	ld	s4,0(sp)
    800022c0:	6145                	addi	sp,sp,48
    800022c2:	8082                	ret

00000000800022c4 <exit>:
{
    800022c4:	7179                	addi	sp,sp,-48
    800022c6:	f406                	sd	ra,40(sp)
    800022c8:	f022                	sd	s0,32(sp)
    800022ca:	ec26                	sd	s1,24(sp)
    800022cc:	e84a                	sd	s2,16(sp)
    800022ce:	e44e                	sd	s3,8(sp)
    800022d0:	e052                	sd	s4,0(sp)
    800022d2:	1800                	addi	s0,sp,48
    800022d4:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800022d6:	fffff097          	auipc	ra,0xfffff
    800022da:	6c0080e7          	jalr	1728(ra) # 80001996 <myproc>
    800022de:	89aa                	mv	s3,a0
  if(p == initproc)
    800022e0:	00007797          	auipc	a5,0x7
    800022e4:	d487b783          	ld	a5,-696(a5) # 80009028 <initproc>
    800022e8:	0e050493          	addi	s1,a0,224
    800022ec:	16050913          	addi	s2,a0,352
    800022f0:	02a79363          	bne	a5,a0,80002316 <exit+0x52>
    panic("init exiting");
    800022f4:	00006517          	auipc	a0,0x6
    800022f8:	f6c50513          	addi	a0,a0,-148 # 80008260 <digits+0x220>
    800022fc:	ffffe097          	auipc	ra,0xffffe
    80002300:	23e080e7          	jalr	574(ra) # 8000053a <panic>
      fileclose(f);
    80002304:	00002097          	auipc	ra,0x2
    80002308:	484080e7          	jalr	1156(ra) # 80004788 <fileclose>
      p->ofile[fd] = 0;
    8000230c:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002310:	04a1                	addi	s1,s1,8
    80002312:	01248563          	beq	s1,s2,8000231c <exit+0x58>
    if(p->ofile[fd]){
    80002316:	6088                	ld	a0,0(s1)
    80002318:	f575                	bnez	a0,80002304 <exit+0x40>
    8000231a:	bfdd                	j	80002310 <exit+0x4c>
  begin_op();
    8000231c:	00002097          	auipc	ra,0x2
    80002320:	fa4080e7          	jalr	-92(ra) # 800042c0 <begin_op>
  iput(p->cwd);
    80002324:	1609b503          	ld	a0,352(s3)
    80002328:	00001097          	auipc	ra,0x1
    8000232c:	776080e7          	jalr	1910(ra) # 80003a9e <iput>
  end_op();
    80002330:	00002097          	auipc	ra,0x2
    80002334:	00e080e7          	jalr	14(ra) # 8000433e <end_op>
  p->cwd = 0;
    80002338:	1609b023          	sd	zero,352(s3)
  acquire(&wait_lock);
    8000233c:	0000f497          	auipc	s1,0xf
    80002340:	f7c48493          	addi	s1,s1,-132 # 800112b8 <wait_lock>
    80002344:	8526                	mv	a0,s1
    80002346:	fffff097          	auipc	ra,0xfffff
    8000234a:	88a080e7          	jalr	-1910(ra) # 80000bd0 <acquire>
  reparent(p);
    8000234e:	854e                	mv	a0,s3
    80002350:	00000097          	auipc	ra,0x0
    80002354:	f1a080e7          	jalr	-230(ra) # 8000226a <reparent>
  wakeup(p->parent);
    80002358:	0489b503          	ld	a0,72(s3)
    8000235c:	00000097          	auipc	ra,0x0
    80002360:	e8e080e7          	jalr	-370(ra) # 800021ea <wakeup>
  acquire(&p->lock);
    80002364:	854e                	mv	a0,s3
    80002366:	fffff097          	auipc	ra,0xfffff
    8000236a:	86a080e7          	jalr	-1942(ra) # 80000bd0 <acquire>
  p->xstate = status;
    8000236e:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002372:	4795                	li	a5,5
    80002374:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002378:	8526                	mv	a0,s1
    8000237a:	fffff097          	auipc	ra,0xfffff
    8000237e:	90a080e7          	jalr	-1782(ra) # 80000c84 <release>
  sched();
    80002382:	00000097          	auipc	ra,0x0
    80002386:	bca080e7          	jalr	-1078(ra) # 80001f4c <sched>
  panic("zombie exit");
    8000238a:	00006517          	auipc	a0,0x6
    8000238e:	ee650513          	addi	a0,a0,-282 # 80008270 <digits+0x230>
    80002392:	ffffe097          	auipc	ra,0xffffe
    80002396:	1a8080e7          	jalr	424(ra) # 8000053a <panic>

000000008000239a <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000239a:	7179                	addi	sp,sp,-48
    8000239c:	f406                	sd	ra,40(sp)
    8000239e:	f022                	sd	s0,32(sp)
    800023a0:	ec26                	sd	s1,24(sp)
    800023a2:	e84a                	sd	s2,16(sp)
    800023a4:	e44e                	sd	s3,8(sp)
    800023a6:	1800                	addi	s0,sp,48
    800023a8:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800023aa:	0000f497          	auipc	s1,0xf
    800023ae:	32648493          	addi	s1,s1,806 # 800116d0 <proc>
    800023b2:	00015997          	auipc	s3,0x15
    800023b6:	11e98993          	addi	s3,s3,286 # 800174d0 <tickslock>
    acquire(&p->lock);
    800023ba:	8526                	mv	a0,s1
    800023bc:	fffff097          	auipc	ra,0xfffff
    800023c0:	814080e7          	jalr	-2028(ra) # 80000bd0 <acquire>
    if(p->pid == pid){
    800023c4:	589c                	lw	a5,48(s1)
    800023c6:	01278d63          	beq	a5,s2,800023e0 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800023ca:	8526                	mv	a0,s1
    800023cc:	fffff097          	auipc	ra,0xfffff
    800023d0:	8b8080e7          	jalr	-1864(ra) # 80000c84 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800023d4:	17848493          	addi	s1,s1,376
    800023d8:	ff3491e3          	bne	s1,s3,800023ba <kill+0x20>
  }
  return -1;
    800023dc:	557d                	li	a0,-1
    800023de:	a829                	j	800023f8 <kill+0x5e>
      p->killed = 1;
    800023e0:	4785                	li	a5,1
    800023e2:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800023e4:	4c98                	lw	a4,24(s1)
    800023e6:	4789                	li	a5,2
    800023e8:	00f70f63          	beq	a4,a5,80002406 <kill+0x6c>
      release(&p->lock);
    800023ec:	8526                	mv	a0,s1
    800023ee:	fffff097          	auipc	ra,0xfffff
    800023f2:	896080e7          	jalr	-1898(ra) # 80000c84 <release>
      return 0;
    800023f6:	4501                	li	a0,0
}
    800023f8:	70a2                	ld	ra,40(sp)
    800023fa:	7402                	ld	s0,32(sp)
    800023fc:	64e2                	ld	s1,24(sp)
    800023fe:	6942                	ld	s2,16(sp)
    80002400:	69a2                	ld	s3,8(sp)
    80002402:	6145                	addi	sp,sp,48
    80002404:	8082                	ret
        p->state = RUNNABLE;
    80002406:	478d                	li	a5,3
    80002408:	cc9c                	sw	a5,24(s1)
    8000240a:	b7cd                	j	800023ec <kill+0x52>

000000008000240c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000240c:	7179                	addi	sp,sp,-48
    8000240e:	f406                	sd	ra,40(sp)
    80002410:	f022                	sd	s0,32(sp)
    80002412:	ec26                	sd	s1,24(sp)
    80002414:	e84a                	sd	s2,16(sp)
    80002416:	e44e                	sd	s3,8(sp)
    80002418:	e052                	sd	s4,0(sp)
    8000241a:	1800                	addi	s0,sp,48
    8000241c:	84aa                	mv	s1,a0
    8000241e:	892e                	mv	s2,a1
    80002420:	89b2                	mv	s3,a2
    80002422:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002424:	fffff097          	auipc	ra,0xfffff
    80002428:	572080e7          	jalr	1394(ra) # 80001996 <myproc>
  if(user_dst){
    8000242c:	c08d                	beqz	s1,8000244e <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000242e:	86d2                	mv	a3,s4
    80002430:	864e                	mv	a2,s3
    80002432:	85ca                	mv	a1,s2
    80002434:	7128                	ld	a0,96(a0)
    80002436:	fffff097          	auipc	ra,0xfffff
    8000243a:	224080e7          	jalr	548(ra) # 8000165a <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000243e:	70a2                	ld	ra,40(sp)
    80002440:	7402                	ld	s0,32(sp)
    80002442:	64e2                	ld	s1,24(sp)
    80002444:	6942                	ld	s2,16(sp)
    80002446:	69a2                	ld	s3,8(sp)
    80002448:	6a02                	ld	s4,0(sp)
    8000244a:	6145                	addi	sp,sp,48
    8000244c:	8082                	ret
    memmove((char *)dst, src, len);
    8000244e:	000a061b          	sext.w	a2,s4
    80002452:	85ce                	mv	a1,s3
    80002454:	854a                	mv	a0,s2
    80002456:	fffff097          	auipc	ra,0xfffff
    8000245a:	8d2080e7          	jalr	-1838(ra) # 80000d28 <memmove>
    return 0;
    8000245e:	8526                	mv	a0,s1
    80002460:	bff9                	j	8000243e <either_copyout+0x32>

0000000080002462 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002462:	7179                	addi	sp,sp,-48
    80002464:	f406                	sd	ra,40(sp)
    80002466:	f022                	sd	s0,32(sp)
    80002468:	ec26                	sd	s1,24(sp)
    8000246a:	e84a                	sd	s2,16(sp)
    8000246c:	e44e                	sd	s3,8(sp)
    8000246e:	e052                	sd	s4,0(sp)
    80002470:	1800                	addi	s0,sp,48
    80002472:	892a                	mv	s2,a0
    80002474:	84ae                	mv	s1,a1
    80002476:	89b2                	mv	s3,a2
    80002478:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000247a:	fffff097          	auipc	ra,0xfffff
    8000247e:	51c080e7          	jalr	1308(ra) # 80001996 <myproc>
  if(user_src){
    80002482:	c08d                	beqz	s1,800024a4 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002484:	86d2                	mv	a3,s4
    80002486:	864e                	mv	a2,s3
    80002488:	85ca                	mv	a1,s2
    8000248a:	7128                	ld	a0,96(a0)
    8000248c:	fffff097          	auipc	ra,0xfffff
    80002490:	25a080e7          	jalr	602(ra) # 800016e6 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002494:	70a2                	ld	ra,40(sp)
    80002496:	7402                	ld	s0,32(sp)
    80002498:	64e2                	ld	s1,24(sp)
    8000249a:	6942                	ld	s2,16(sp)
    8000249c:	69a2                	ld	s3,8(sp)
    8000249e:	6a02                	ld	s4,0(sp)
    800024a0:	6145                	addi	sp,sp,48
    800024a2:	8082                	ret
    memmove(dst, (char*)src, len);
    800024a4:	000a061b          	sext.w	a2,s4
    800024a8:	85ce                	mv	a1,s3
    800024aa:	854a                	mv	a0,s2
    800024ac:	fffff097          	auipc	ra,0xfffff
    800024b0:	87c080e7          	jalr	-1924(ra) # 80000d28 <memmove>
    return 0;
    800024b4:	8526                	mv	a0,s1
    800024b6:	bff9                	j	80002494 <either_copyin+0x32>

00000000800024b8 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800024b8:	715d                	addi	sp,sp,-80
    800024ba:	e486                	sd	ra,72(sp)
    800024bc:	e0a2                	sd	s0,64(sp)
    800024be:	fc26                	sd	s1,56(sp)
    800024c0:	f84a                	sd	s2,48(sp)
    800024c2:	f44e                	sd	s3,40(sp)
    800024c4:	f052                	sd	s4,32(sp)
    800024c6:	ec56                	sd	s5,24(sp)
    800024c8:	e85a                	sd	s6,16(sp)
    800024ca:	e45e                	sd	s7,8(sp)
    800024cc:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800024ce:	00006517          	auipc	a0,0x6
    800024d2:	bfa50513          	addi	a0,a0,-1030 # 800080c8 <digits+0x88>
    800024d6:	ffffe097          	auipc	ra,0xffffe
    800024da:	0ae080e7          	jalr	174(ra) # 80000584 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800024de:	0000f497          	auipc	s1,0xf
    800024e2:	35a48493          	addi	s1,s1,858 # 80011838 <proc+0x168>
    800024e6:	00015917          	auipc	s2,0x15
    800024ea:	15290913          	addi	s2,s2,338 # 80017638 <bcache+0x150>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800024ee:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800024f0:	00006997          	auipc	s3,0x6
    800024f4:	d9098993          	addi	s3,s3,-624 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    800024f8:	00006a97          	auipc	s5,0x6
    800024fc:	d90a8a93          	addi	s5,s5,-624 # 80008288 <digits+0x248>
    printf("\n");
    80002500:	00006a17          	auipc	s4,0x6
    80002504:	bc8a0a13          	addi	s4,s4,-1080 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002508:	00006b97          	auipc	s7,0x6
    8000250c:	db8b8b93          	addi	s7,s7,-584 # 800082c0 <states.0>
    80002510:	a00d                	j	80002532 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002512:	ec86a583          	lw	a1,-312(a3)
    80002516:	8556                	mv	a0,s5
    80002518:	ffffe097          	auipc	ra,0xffffe
    8000251c:	06c080e7          	jalr	108(ra) # 80000584 <printf>
    printf("\n");
    80002520:	8552                	mv	a0,s4
    80002522:	ffffe097          	auipc	ra,0xffffe
    80002526:	062080e7          	jalr	98(ra) # 80000584 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000252a:	17848493          	addi	s1,s1,376
    8000252e:	03248263          	beq	s1,s2,80002552 <procdump+0x9a>
    if(p->state == UNUSED)
    80002532:	86a6                	mv	a3,s1
    80002534:	eb04a783          	lw	a5,-336(s1)
    80002538:	dbed                	beqz	a5,8000252a <procdump+0x72>
      state = "???";
    8000253a:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000253c:	fcfb6be3          	bltu	s6,a5,80002512 <procdump+0x5a>
    80002540:	02079713          	slli	a4,a5,0x20
    80002544:	01d75793          	srli	a5,a4,0x1d
    80002548:	97de                	add	a5,a5,s7
    8000254a:	6390                	ld	a2,0(a5)
    8000254c:	f279                	bnez	a2,80002512 <procdump+0x5a>
      state = "???";
    8000254e:	864e                	mv	a2,s3
    80002550:	b7c9                	j	80002512 <procdump+0x5a>
  }
}
    80002552:	60a6                	ld	ra,72(sp)
    80002554:	6406                	ld	s0,64(sp)
    80002556:	74e2                	ld	s1,56(sp)
    80002558:	7942                	ld	s2,48(sp)
    8000255a:	79a2                	ld	s3,40(sp)
    8000255c:	7a02                	ld	s4,32(sp)
    8000255e:	6ae2                	ld	s5,24(sp)
    80002560:	6b42                	ld	s6,16(sp)
    80002562:	6ba2                	ld	s7,8(sp)
    80002564:	6161                	addi	sp,sp,80
    80002566:	8082                	ret

0000000080002568 <procinfo>:

int
procinfo(uint64 addr)
{
    80002568:	7175                	addi	sp,sp,-144
    8000256a:	e506                	sd	ra,136(sp)
    8000256c:	e122                	sd	s0,128(sp)
    8000256e:	fca6                	sd	s1,120(sp)
    80002570:	f8ca                	sd	s2,112(sp)
    80002572:	f4ce                	sd	s3,104(sp)
    80002574:	f0d2                	sd	s4,96(sp)
    80002576:	ecd6                	sd	s5,88(sp)
    80002578:	e8da                	sd	s6,80(sp)
    8000257a:	e4de                	sd	s7,72(sp)
    8000257c:	0900                	addi	s0,sp,144
    8000257e:	89aa                	mv	s3,a0
  struct proc *p;
  struct proc *thisproc = myproc();
    80002580:	fffff097          	auipc	ra,0xfffff
    80002584:	416080e7          	jalr	1046(ra) # 80001996 <myproc>
    80002588:	8b2a                	mv	s6,a0
  struct pstat procinfo;
  int nprocs = 0;
  for(p = proc; p < &proc[NPROC]; p++){ 
    8000258a:	0000f917          	auipc	s2,0xf
    8000258e:	2ae90913          	addi	s2,s2,686 # 80011838 <proc+0x168>
    80002592:	00015a17          	auipc	s4,0x15
    80002596:	0a6a0a13          	addi	s4,s4,166 # 80017638 <bcache+0x150>
  int nprocs = 0;
    8000259a:	4a81                	li	s5,0
    procinfo.state = p->state;
    procinfo.size = p->sz;
    if (p->parent)
      procinfo.ppid = (p->parent)->pid;
    else
      procinfo.ppid = 0;
    8000259c:	4b81                	li	s7,0
    8000259e:	fa440493          	addi	s1,s0,-92
    800025a2:	a089                	j	800025e4 <procinfo+0x7c>
    800025a4:	f8f42823          	sw	a5,-112(s0)
    for (int i=0; i<16; i++)
    800025a8:	f9440793          	addi	a5,s0,-108
      procinfo.ppid = 0;
    800025ac:	874a                	mv	a4,s2
      procinfo.name[i] = p->name[i];
    800025ae:	00074683          	lbu	a3,0(a4)
    800025b2:	00d78023          	sb	a3,0(a5)
    for (int i=0; i<16; i++)
    800025b6:	0705                	addi	a4,a4,1
    800025b8:	0785                	addi	a5,a5,1
    800025ba:	fe979ae3          	bne	a5,s1,800025ae <procinfo+0x46>
   if (copyout(thisproc->pagetable, addr, (char *)&procinfo, sizeof(procinfo)) < 0)
    800025be:	03800693          	li	a3,56
    800025c2:	f7840613          	addi	a2,s0,-136
    800025c6:	85ce                	mv	a1,s3
    800025c8:	060b3503          	ld	a0,96(s6)
    800025cc:	fffff097          	auipc	ra,0xfffff
    800025d0:	08e080e7          	jalr	142(ra) # 8000165a <copyout>
    800025d4:	02054c63          	bltz	a0,8000260c <procinfo+0xa4>
      return -1;
    addr += sizeof(procinfo);
    800025d8:	03898993          	addi	s3,s3,56
  for(p = proc; p < &proc[NPROC]; p++){ 
    800025dc:	17890913          	addi	s2,s2,376
    800025e0:	03490763          	beq	s2,s4,8000260e <procinfo+0xa6>
    if(p->state == UNUSED)
    800025e4:	eb092783          	lw	a5,-336(s2)
    800025e8:	dbf5                	beqz	a5,800025dc <procinfo+0x74>
    nprocs++;
    800025ea:	2a85                	addiw	s5,s5,1
    procinfo.pid = p->pid;
    800025ec:	ec892703          	lw	a4,-312(s2)
    800025f0:	f6e42e23          	sw	a4,-132(s0)
    procinfo.state = p->state;
    800025f4:	f8f42023          	sw	a5,-128(s0)
    procinfo.size = p->sz;
    800025f8:	ef093783          	ld	a5,-272(s2)
    800025fc:	f8f43423          	sd	a5,-120(s0)
    if (p->parent)
    80002600:	ee093703          	ld	a4,-288(s2)
      procinfo.ppid = 0;
    80002604:	87de                	mv	a5,s7
    if (p->parent)
    80002606:	df59                	beqz	a4,800025a4 <procinfo+0x3c>
      procinfo.ppid = (p->parent)->pid;
    80002608:	5b1c                	lw	a5,48(a4)
    8000260a:	bf69                	j	800025a4 <procinfo+0x3c>
      return -1;
    8000260c:	5afd                	li	s5,-1
  }
  return nprocs;
}
    8000260e:	8556                	mv	a0,s5
    80002610:	60aa                	ld	ra,136(sp)
    80002612:	640a                	ld	s0,128(sp)
    80002614:	74e6                	ld	s1,120(sp)
    80002616:	7946                	ld	s2,112(sp)
    80002618:	79a6                	ld	s3,104(sp)
    8000261a:	7a06                	ld	s4,96(sp)
    8000261c:	6ae6                	ld	s5,88(sp)
    8000261e:	6b46                	ld	s6,80(sp)
    80002620:	6ba6                	ld	s7,72(sp)
    80002622:	6149                	addi	sp,sp,144
    80002624:	8082                	ret

0000000080002626 <wait2>:



int
wait2(uint64 addr, uint64 addr2)
{
    80002626:	7159                	addi	sp,sp,-112
    80002628:	f486                	sd	ra,104(sp)
    8000262a:	f0a2                	sd	s0,96(sp)
    8000262c:	eca6                	sd	s1,88(sp)
    8000262e:	e8ca                	sd	s2,80(sp)
    80002630:	e4ce                	sd	s3,72(sp)
    80002632:	e0d2                	sd	s4,64(sp)
    80002634:	fc56                	sd	s5,56(sp)
    80002636:	f85a                	sd	s6,48(sp)
    80002638:	f45e                	sd	s7,40(sp)
    8000263a:	f062                	sd	s8,32(sp)
    8000263c:	ec66                	sd	s9,24(sp)
    8000263e:	1880                	addi	s0,sp,112
    80002640:	8baa                	mv	s7,a0
    80002642:	8b2e                	mv	s6,a1
  struct rusage cru;
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    80002644:	fffff097          	auipc	ra,0xfffff
    80002648:	352080e7          	jalr	850(ra) # 80001996 <myproc>
    8000264c:	892a                	mv	s2,a0

  acquire(&wait_lock);
    8000264e:	0000f517          	auipc	a0,0xf
    80002652:	c6a50513          	addi	a0,a0,-918 # 800112b8 <wait_lock>
    80002656:	ffffe097          	auipc	ra,0xffffe
    8000265a:	57a080e7          	jalr	1402(ra) # 80000bd0 <acquire>

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    8000265e:	4c01                	li	s8,0
      if(np->parent == p){
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if(np->state == ZOMBIE){
    80002660:	4a15                	li	s4,5
        havekids = 1;
    80002662:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002664:	00015997          	auipc	s3,0x15
    80002668:	e6c98993          	addi	s3,s3,-404 # 800174d0 <tickslock>
      release(&wait_lock);
      return -1;
    }
    
    // Wait for a child to exit.
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000266c:	0000fc97          	auipc	s9,0xf
    80002670:	c4cc8c93          	addi	s9,s9,-948 # 800112b8 <wait_lock>
    havekids = 0;
    80002674:	8762                	mv	a4,s8
    for(np = proc; np < &proc[NPROC]; np++){
    80002676:	0000f497          	auipc	s1,0xf
    8000267a:	05a48493          	addi	s1,s1,90 # 800116d0 <proc>
    8000267e:	a07d                	j	8000272c <wait2+0x106>
          pid = np->pid;
    80002680:	0304a983          	lw	s3,48(s1)
          cru.cputime = np->cputime;
    80002684:	58dc                	lw	a5,52(s1)
    80002686:	f8f42c23          	sw	a5,-104(s0)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000268a:	040b9363          	bnez	s7,800026d0 <wait2+0xaa>
          if(addr2 != 0 && copyout(p->pagetable, addr2, (char *)&cru,
    8000268e:	000b0e63          	beqz	s6,800026aa <wait2+0x84>
    80002692:	4691                	li	a3,4
    80002694:	f9840613          	addi	a2,s0,-104
    80002698:	85da                	mv	a1,s6
    8000269a:	06093503          	ld	a0,96(s2)
    8000269e:	fffff097          	auipc	ra,0xfffff
    800026a2:	fbc080e7          	jalr	-68(ra) # 8000165a <copyout>
    800026a6:	06054063          	bltz	a0,80002706 <wait2+0xe0>
          freeproc(np);
    800026aa:	8526                	mv	a0,s1
    800026ac:	fffff097          	auipc	ra,0xfffff
    800026b0:	49c080e7          	jalr	1180(ra) # 80001b48 <freeproc>
          release(&np->lock);
    800026b4:	8526                	mv	a0,s1
    800026b6:	ffffe097          	auipc	ra,0xffffe
    800026ba:	5ce080e7          	jalr	1486(ra) # 80000c84 <release>
          release(&wait_lock);
    800026be:	0000f517          	auipc	a0,0xf
    800026c2:	bfa50513          	addi	a0,a0,-1030 # 800112b8 <wait_lock>
    800026c6:	ffffe097          	auipc	ra,0xffffe
    800026ca:	5be080e7          	jalr	1470(ra) # 80000c84 <release>
          return pid;
    800026ce:	a871                	j	8000276a <wait2+0x144>
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800026d0:	4691                	li	a3,4
    800026d2:	02c48613          	addi	a2,s1,44
    800026d6:	85de                	mv	a1,s7
    800026d8:	06093503          	ld	a0,96(s2)
    800026dc:	fffff097          	auipc	ra,0xfffff
    800026e0:	f7e080e7          	jalr	-130(ra) # 8000165a <copyout>
    800026e4:	fa0555e3          	bgez	a0,8000268e <wait2+0x68>
            release(&np->lock);
    800026e8:	8526                	mv	a0,s1
    800026ea:	ffffe097          	auipc	ra,0xffffe
    800026ee:	59a080e7          	jalr	1434(ra) # 80000c84 <release>
            release(&wait_lock);
    800026f2:	0000f517          	auipc	a0,0xf
    800026f6:	bc650513          	addi	a0,a0,-1082 # 800112b8 <wait_lock>
    800026fa:	ffffe097          	auipc	ra,0xffffe
    800026fe:	58a080e7          	jalr	1418(ra) # 80000c84 <release>
            return -1;
    80002702:	59fd                	li	s3,-1
    80002704:	a09d                	j	8000276a <wait2+0x144>
            release(&np->lock);
    80002706:	8526                	mv	a0,s1
    80002708:	ffffe097          	auipc	ra,0xffffe
    8000270c:	57c080e7          	jalr	1404(ra) # 80000c84 <release>
            release(&wait_lock);
    80002710:	0000f517          	auipc	a0,0xf
    80002714:	ba850513          	addi	a0,a0,-1112 # 800112b8 <wait_lock>
    80002718:	ffffe097          	auipc	ra,0xffffe
    8000271c:	56c080e7          	jalr	1388(ra) # 80000c84 <release>
            return -1;
    80002720:	59fd                	li	s3,-1
    80002722:	a0a1                	j	8000276a <wait2+0x144>
    for(np = proc; np < &proc[NPROC]; np++){
    80002724:	17848493          	addi	s1,s1,376
    80002728:	03348463          	beq	s1,s3,80002750 <wait2+0x12a>
      if(np->parent == p){
    8000272c:	64bc                	ld	a5,72(s1)
    8000272e:	ff279be3          	bne	a5,s2,80002724 <wait2+0xfe>
        acquire(&np->lock);
    80002732:	8526                	mv	a0,s1
    80002734:	ffffe097          	auipc	ra,0xffffe
    80002738:	49c080e7          	jalr	1180(ra) # 80000bd0 <acquire>
        if(np->state == ZOMBIE){
    8000273c:	4c9c                	lw	a5,24(s1)
    8000273e:	f54781e3          	beq	a5,s4,80002680 <wait2+0x5a>
        release(&np->lock);
    80002742:	8526                	mv	a0,s1
    80002744:	ffffe097          	auipc	ra,0xffffe
    80002748:	540080e7          	jalr	1344(ra) # 80000c84 <release>
        havekids = 1;
    8000274c:	8756                	mv	a4,s5
    8000274e:	bfd9                	j	80002724 <wait2+0xfe>
    if(!havekids || p->killed){
    80002750:	c701                	beqz	a4,80002758 <wait2+0x132>
    80002752:	02892783          	lw	a5,40(s2)
    80002756:	cb85                	beqz	a5,80002786 <wait2+0x160>
      release(&wait_lock);
    80002758:	0000f517          	auipc	a0,0xf
    8000275c:	b6050513          	addi	a0,a0,-1184 # 800112b8 <wait_lock>
    80002760:	ffffe097          	auipc	ra,0xffffe
    80002764:	524080e7          	jalr	1316(ra) # 80000c84 <release>
      return -1;
    80002768:	59fd                	li	s3,-1
  }
}
    8000276a:	854e                	mv	a0,s3
    8000276c:	70a6                	ld	ra,104(sp)
    8000276e:	7406                	ld	s0,96(sp)
    80002770:	64e6                	ld	s1,88(sp)
    80002772:	6946                	ld	s2,80(sp)
    80002774:	69a6                	ld	s3,72(sp)
    80002776:	6a06                	ld	s4,64(sp)
    80002778:	7ae2                	ld	s5,56(sp)
    8000277a:	7b42                	ld	s6,48(sp)
    8000277c:	7ba2                	ld	s7,40(sp)
    8000277e:	7c02                	ld	s8,32(sp)
    80002780:	6ce2                	ld	s9,24(sp)
    80002782:	6165                	addi	sp,sp,112
    80002784:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002786:	85e6                	mv	a1,s9
    80002788:	854a                	mv	a0,s2
    8000278a:	00000097          	auipc	ra,0x0
    8000278e:	8d4080e7          	jalr	-1836(ra) # 8000205e <sleep>
    havekids = 0;
    80002792:	b5cd                	j	80002674 <wait2+0x4e>

0000000080002794 <swtch>:
    80002794:	00153023          	sd	ra,0(a0)
    80002798:	00253423          	sd	sp,8(a0)
    8000279c:	e900                	sd	s0,16(a0)
    8000279e:	ed04                	sd	s1,24(a0)
    800027a0:	03253023          	sd	s2,32(a0)
    800027a4:	03353423          	sd	s3,40(a0)
    800027a8:	03453823          	sd	s4,48(a0)
    800027ac:	03553c23          	sd	s5,56(a0)
    800027b0:	05653023          	sd	s6,64(a0)
    800027b4:	05753423          	sd	s7,72(a0)
    800027b8:	05853823          	sd	s8,80(a0)
    800027bc:	05953c23          	sd	s9,88(a0)
    800027c0:	07a53023          	sd	s10,96(a0)
    800027c4:	07b53423          	sd	s11,104(a0)
    800027c8:	0005b083          	ld	ra,0(a1)
    800027cc:	0085b103          	ld	sp,8(a1)
    800027d0:	6980                	ld	s0,16(a1)
    800027d2:	6d84                	ld	s1,24(a1)
    800027d4:	0205b903          	ld	s2,32(a1)
    800027d8:	0285b983          	ld	s3,40(a1)
    800027dc:	0305ba03          	ld	s4,48(a1)
    800027e0:	0385ba83          	ld	s5,56(a1)
    800027e4:	0405bb03          	ld	s6,64(a1)
    800027e8:	0485bb83          	ld	s7,72(a1)
    800027ec:	0505bc03          	ld	s8,80(a1)
    800027f0:	0585bc83          	ld	s9,88(a1)
    800027f4:	0605bd03          	ld	s10,96(a1)
    800027f8:	0685bd83          	ld	s11,104(a1)
    800027fc:	8082                	ret

00000000800027fe <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800027fe:	1141                	addi	sp,sp,-16
    80002800:	e406                	sd	ra,8(sp)
    80002802:	e022                	sd	s0,0(sp)
    80002804:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002806:	00006597          	auipc	a1,0x6
    8000280a:	aea58593          	addi	a1,a1,-1302 # 800082f0 <states.0+0x30>
    8000280e:	00015517          	auipc	a0,0x15
    80002812:	cc250513          	addi	a0,a0,-830 # 800174d0 <tickslock>
    80002816:	ffffe097          	auipc	ra,0xffffe
    8000281a:	32a080e7          	jalr	810(ra) # 80000b40 <initlock>
}
    8000281e:	60a2                	ld	ra,8(sp)
    80002820:	6402                	ld	s0,0(sp)
    80002822:	0141                	addi	sp,sp,16
    80002824:	8082                	ret

0000000080002826 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002826:	1141                	addi	sp,sp,-16
    80002828:	e422                	sd	s0,8(sp)
    8000282a:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000282c:	00003797          	auipc	a5,0x3
    80002830:	59478793          	addi	a5,a5,1428 # 80005dc0 <kernelvec>
    80002834:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002838:	6422                	ld	s0,8(sp)
    8000283a:	0141                	addi	sp,sp,16
    8000283c:	8082                	ret

000000008000283e <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000283e:	1141                	addi	sp,sp,-16
    80002840:	e406                	sd	ra,8(sp)
    80002842:	e022                	sd	s0,0(sp)
    80002844:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002846:	fffff097          	auipc	ra,0xfffff
    8000284a:	150080e7          	jalr	336(ra) # 80001996 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000284e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002852:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002854:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002858:	00004697          	auipc	a3,0x4
    8000285c:	7a868693          	addi	a3,a3,1960 # 80007000 <_trampoline>
    80002860:	00004717          	auipc	a4,0x4
    80002864:	7a070713          	addi	a4,a4,1952 # 80007000 <_trampoline>
    80002868:	8f15                	sub	a4,a4,a3
    8000286a:	040007b7          	lui	a5,0x4000
    8000286e:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002870:	07b2                	slli	a5,a5,0xc
    80002872:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002874:	10571073          	csrw	stvec,a4

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002878:	7538                	ld	a4,104(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000287a:	18002673          	csrr	a2,satp
    8000287e:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002880:	7530                	ld	a2,104(a0)
    80002882:	6938                	ld	a4,80(a0)
    80002884:	6585                	lui	a1,0x1
    80002886:	972e                	add	a4,a4,a1
    80002888:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000288a:	7538                	ld	a4,104(a0)
    8000288c:	00000617          	auipc	a2,0x0
    80002890:	13860613          	addi	a2,a2,312 # 800029c4 <usertrap>
    80002894:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002896:	7538                	ld	a4,104(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002898:	8612                	mv	a2,tp
    8000289a:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000289c:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800028a0:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800028a4:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028a8:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800028ac:	7538                	ld	a4,104(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800028ae:	6f18                	ld	a4,24(a4)
    800028b0:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800028b4:	712c                	ld	a1,96(a0)
    800028b6:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800028b8:	00004717          	auipc	a4,0x4
    800028bc:	7d870713          	addi	a4,a4,2008 # 80007090 <userret>
    800028c0:	8f15                	sub	a4,a4,a3
    800028c2:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    800028c4:	577d                	li	a4,-1
    800028c6:	177e                	slli	a4,a4,0x3f
    800028c8:	8dd9                	or	a1,a1,a4
    800028ca:	02000537          	lui	a0,0x2000
    800028ce:	157d                	addi	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800028d0:	0536                	slli	a0,a0,0xd
    800028d2:	9782                	jalr	a5
}
    800028d4:	60a2                	ld	ra,8(sp)
    800028d6:	6402                	ld	s0,0(sp)
    800028d8:	0141                	addi	sp,sp,16
    800028da:	8082                	ret

00000000800028dc <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800028dc:	1101                	addi	sp,sp,-32
    800028de:	ec06                	sd	ra,24(sp)
    800028e0:	e822                	sd	s0,16(sp)
    800028e2:	e426                	sd	s1,8(sp)
    800028e4:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800028e6:	00015497          	auipc	s1,0x15
    800028ea:	bea48493          	addi	s1,s1,-1046 # 800174d0 <tickslock>
    800028ee:	8526                	mv	a0,s1
    800028f0:	ffffe097          	auipc	ra,0xffffe
    800028f4:	2e0080e7          	jalr	736(ra) # 80000bd0 <acquire>
  ticks++;
    800028f8:	00006517          	auipc	a0,0x6
    800028fc:	73850513          	addi	a0,a0,1848 # 80009030 <ticks>
    80002900:	411c                	lw	a5,0(a0)
    80002902:	2785                	addiw	a5,a5,1
    80002904:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002906:	00000097          	auipc	ra,0x0
    8000290a:	8e4080e7          	jalr	-1820(ra) # 800021ea <wakeup>
  release(&tickslock);
    8000290e:	8526                	mv	a0,s1
    80002910:	ffffe097          	auipc	ra,0xffffe
    80002914:	374080e7          	jalr	884(ra) # 80000c84 <release>
}
    80002918:	60e2                	ld	ra,24(sp)
    8000291a:	6442                	ld	s0,16(sp)
    8000291c:	64a2                	ld	s1,8(sp)
    8000291e:	6105                	addi	sp,sp,32
    80002920:	8082                	ret

0000000080002922 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002922:	1101                	addi	sp,sp,-32
    80002924:	ec06                	sd	ra,24(sp)
    80002926:	e822                	sd	s0,16(sp)
    80002928:	e426                	sd	s1,8(sp)
    8000292a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000292c:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002930:	00074d63          	bltz	a4,8000294a <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002934:	57fd                	li	a5,-1
    80002936:	17fe                	slli	a5,a5,0x3f
    80002938:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    8000293a:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    8000293c:	06f70363          	beq	a4,a5,800029a2 <devintr+0x80>
  }
}
    80002940:	60e2                	ld	ra,24(sp)
    80002942:	6442                	ld	s0,16(sp)
    80002944:	64a2                	ld	s1,8(sp)
    80002946:	6105                	addi	sp,sp,32
    80002948:	8082                	ret
     (scause & 0xff) == 9){
    8000294a:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    8000294e:	46a5                	li	a3,9
    80002950:	fed792e3          	bne	a5,a3,80002934 <devintr+0x12>
    int irq = plic_claim();
    80002954:	00003097          	auipc	ra,0x3
    80002958:	574080e7          	jalr	1396(ra) # 80005ec8 <plic_claim>
    8000295c:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000295e:	47a9                	li	a5,10
    80002960:	02f50763          	beq	a0,a5,8000298e <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002964:	4785                	li	a5,1
    80002966:	02f50963          	beq	a0,a5,80002998 <devintr+0x76>
    return 1;
    8000296a:	4505                	li	a0,1
    } else if(irq){
    8000296c:	d8f1                	beqz	s1,80002940 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    8000296e:	85a6                	mv	a1,s1
    80002970:	00006517          	auipc	a0,0x6
    80002974:	98850513          	addi	a0,a0,-1656 # 800082f8 <states.0+0x38>
    80002978:	ffffe097          	auipc	ra,0xffffe
    8000297c:	c0c080e7          	jalr	-1012(ra) # 80000584 <printf>
      plic_complete(irq);
    80002980:	8526                	mv	a0,s1
    80002982:	00003097          	auipc	ra,0x3
    80002986:	56a080e7          	jalr	1386(ra) # 80005eec <plic_complete>
    return 1;
    8000298a:	4505                	li	a0,1
    8000298c:	bf55                	j	80002940 <devintr+0x1e>
      uartintr();
    8000298e:	ffffe097          	auipc	ra,0xffffe
    80002992:	004080e7          	jalr	4(ra) # 80000992 <uartintr>
    80002996:	b7ed                	j	80002980 <devintr+0x5e>
      virtio_disk_intr();
    80002998:	00004097          	auipc	ra,0x4
    8000299c:	9e0080e7          	jalr	-1568(ra) # 80006378 <virtio_disk_intr>
    800029a0:	b7c5                	j	80002980 <devintr+0x5e>
    if(cpuid() == 0){
    800029a2:	fffff097          	auipc	ra,0xfffff
    800029a6:	fc8080e7          	jalr	-56(ra) # 8000196a <cpuid>
    800029aa:	c901                	beqz	a0,800029ba <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800029ac:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800029b0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800029b2:	14479073          	csrw	sip,a5
    return 2;
    800029b6:	4509                	li	a0,2
    800029b8:	b761                	j	80002940 <devintr+0x1e>
      clockintr();
    800029ba:	00000097          	auipc	ra,0x0
    800029be:	f22080e7          	jalr	-222(ra) # 800028dc <clockintr>
    800029c2:	b7ed                	j	800029ac <devintr+0x8a>

00000000800029c4 <usertrap>:
{
    800029c4:	1101                	addi	sp,sp,-32
    800029c6:	ec06                	sd	ra,24(sp)
    800029c8:	e822                	sd	s0,16(sp)
    800029ca:	e426                	sd	s1,8(sp)
    800029cc:	e04a                	sd	s2,0(sp)
    800029ce:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029d0:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800029d4:	1007f793          	andi	a5,a5,256
    800029d8:	e7ad                	bnez	a5,80002a42 <usertrap+0x7e>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029da:	00003797          	auipc	a5,0x3
    800029de:	3e678793          	addi	a5,a5,998 # 80005dc0 <kernelvec>
    800029e2:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800029e6:	fffff097          	auipc	ra,0xfffff
    800029ea:	fb0080e7          	jalr	-80(ra) # 80001996 <myproc>
    800029ee:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800029f0:	753c                	ld	a5,104(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029f2:	14102773          	csrr	a4,sepc
    800029f6:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029f8:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800029fc:	47a1                	li	a5,8
    800029fe:	06f71063          	bne	a4,a5,80002a5e <usertrap+0x9a>
    if(p->killed)
    80002a02:	551c                	lw	a5,40(a0)
    80002a04:	e7b9                	bnez	a5,80002a52 <usertrap+0x8e>
    p->trapframe->epc += 4;
    80002a06:	74b8                	ld	a4,104(s1)
    80002a08:	6f1c                	ld	a5,24(a4)
    80002a0a:	0791                	addi	a5,a5,4
    80002a0c:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a0e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002a12:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a16:	10079073          	csrw	sstatus,a5
    syscall();
    80002a1a:	00000097          	auipc	ra,0x0
    80002a1e:	2fe080e7          	jalr	766(ra) # 80002d18 <syscall>
  if(p->killed)
    80002a22:	549c                	lw	a5,40(s1)
    80002a24:	ebd9                	bnez	a5,80002aba <usertrap+0xf6>
    yield();
    80002a26:	fffff097          	auipc	ra,0xfffff
    80002a2a:	5fc080e7          	jalr	1532(ra) # 80002022 <yield>
  usertrapret();
    80002a2e:	00000097          	auipc	ra,0x0
    80002a32:	e10080e7          	jalr	-496(ra) # 8000283e <usertrapret>
}
    80002a36:	60e2                	ld	ra,24(sp)
    80002a38:	6442                	ld	s0,16(sp)
    80002a3a:	64a2                	ld	s1,8(sp)
    80002a3c:	6902                	ld	s2,0(sp)
    80002a3e:	6105                	addi	sp,sp,32
    80002a40:	8082                	ret
    panic("usertrap: not from user mode");
    80002a42:	00006517          	auipc	a0,0x6
    80002a46:	8d650513          	addi	a0,a0,-1834 # 80008318 <states.0+0x58>
    80002a4a:	ffffe097          	auipc	ra,0xffffe
    80002a4e:	af0080e7          	jalr	-1296(ra) # 8000053a <panic>
      exit(-1);
    80002a52:	557d                	li	a0,-1
    80002a54:	00000097          	auipc	ra,0x0
    80002a58:	870080e7          	jalr	-1936(ra) # 800022c4 <exit>
    80002a5c:	b76d                	j	80002a06 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002a5e:	00000097          	auipc	ra,0x0
    80002a62:	ec4080e7          	jalr	-316(ra) # 80002922 <devintr>
    80002a66:	892a                	mv	s2,a0
    80002a68:	c501                	beqz	a0,80002a70 <usertrap+0xac>
  if(p->killed)
    80002a6a:	549c                	lw	a5,40(s1)
    80002a6c:	c3a1                	beqz	a5,80002aac <usertrap+0xe8>
    80002a6e:	a815                	j	80002aa2 <usertrap+0xde>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a70:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002a74:	5890                	lw	a2,48(s1)
    80002a76:	00006517          	auipc	a0,0x6
    80002a7a:	8c250513          	addi	a0,a0,-1854 # 80008338 <states.0+0x78>
    80002a7e:	ffffe097          	auipc	ra,0xffffe
    80002a82:	b06080e7          	jalr	-1274(ra) # 80000584 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a86:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a8a:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a8e:	00006517          	auipc	a0,0x6
    80002a92:	8da50513          	addi	a0,a0,-1830 # 80008368 <states.0+0xa8>
    80002a96:	ffffe097          	auipc	ra,0xffffe
    80002a9a:	aee080e7          	jalr	-1298(ra) # 80000584 <printf>
    p->killed = 1;
    80002a9e:	4785                	li	a5,1
    80002aa0:	d49c                	sw	a5,40(s1)
    exit(-1);
    80002aa2:	557d                	li	a0,-1
    80002aa4:	00000097          	auipc	ra,0x0
    80002aa8:	820080e7          	jalr	-2016(ra) # 800022c4 <exit>
  if(which_dev == 2)
    80002aac:	4789                	li	a5,2
    80002aae:	f6f91ce3          	bne	s2,a5,80002a26 <usertrap+0x62>
   p->cputime += 1; 
    80002ab2:	58dc                	lw	a5,52(s1)
    80002ab4:	2785                	addiw	a5,a5,1
    80002ab6:	d8dc                	sw	a5,52(s1)
    80002ab8:	b7bd                	j	80002a26 <usertrap+0x62>
  int which_dev = 0;
    80002aba:	4901                	li	s2,0
    80002abc:	b7dd                	j	80002aa2 <usertrap+0xde>

0000000080002abe <kerneltrap>:
{
    80002abe:	7179                	addi	sp,sp,-48
    80002ac0:	f406                	sd	ra,40(sp)
    80002ac2:	f022                	sd	s0,32(sp)
    80002ac4:	ec26                	sd	s1,24(sp)
    80002ac6:	e84a                	sd	s2,16(sp)
    80002ac8:	e44e                	sd	s3,8(sp)
    80002aca:	e052                	sd	s4,0(sp)
    80002acc:	1800                	addi	s0,sp,48
  struct proc *p = myproc();     
    80002ace:	fffff097          	auipc	ra,0xfffff
    80002ad2:	ec8080e7          	jalr	-312(ra) # 80001996 <myproc>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ad6:	141029f3          	csrr	s3,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ada:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ade:	14202a73          	csrr	s4,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002ae2:	1004f793          	andi	a5,s1,256
    80002ae6:	cb95                	beqz	a5,80002b1a <kerneltrap+0x5c>
    80002ae8:	892a                	mv	s2,a0
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002aea:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002aee:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002af0:	ef8d                	bnez	a5,80002b2a <kerneltrap+0x6c>
  if((which_dev = devintr()) == 0){
    80002af2:	00000097          	auipc	ra,0x0
    80002af6:	e30080e7          	jalr	-464(ra) # 80002922 <devintr>
    80002afa:	c121                	beqz	a0,80002b3a <kerneltrap+0x7c>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING){
    80002afc:	4789                	li	a5,2
    80002afe:	06f50b63          	beq	a0,a5,80002b74 <kerneltrap+0xb6>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b02:	14199073          	csrw	sepc,s3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b06:	10049073          	csrw	sstatus,s1
}
    80002b0a:	70a2                	ld	ra,40(sp)
    80002b0c:	7402                	ld	s0,32(sp)
    80002b0e:	64e2                	ld	s1,24(sp)
    80002b10:	6942                	ld	s2,16(sp)
    80002b12:	69a2                	ld	s3,8(sp)
    80002b14:	6a02                	ld	s4,0(sp)
    80002b16:	6145                	addi	sp,sp,48
    80002b18:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002b1a:	00006517          	auipc	a0,0x6
    80002b1e:	86e50513          	addi	a0,a0,-1938 # 80008388 <states.0+0xc8>
    80002b22:	ffffe097          	auipc	ra,0xffffe
    80002b26:	a18080e7          	jalr	-1512(ra) # 8000053a <panic>
    panic("kerneltrap: interrupts enabled");
    80002b2a:	00006517          	auipc	a0,0x6
    80002b2e:	88650513          	addi	a0,a0,-1914 # 800083b0 <states.0+0xf0>
    80002b32:	ffffe097          	auipc	ra,0xffffe
    80002b36:	a08080e7          	jalr	-1528(ra) # 8000053a <panic>
    printf("scause %p\n", scause);
    80002b3a:	85d2                	mv	a1,s4
    80002b3c:	00006517          	auipc	a0,0x6
    80002b40:	89450513          	addi	a0,a0,-1900 # 800083d0 <states.0+0x110>
    80002b44:	ffffe097          	auipc	ra,0xffffe
    80002b48:	a40080e7          	jalr	-1472(ra) # 80000584 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b4c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b50:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b54:	00006517          	auipc	a0,0x6
    80002b58:	88c50513          	addi	a0,a0,-1908 # 800083e0 <states.0+0x120>
    80002b5c:	ffffe097          	auipc	ra,0xffffe
    80002b60:	a28080e7          	jalr	-1496(ra) # 80000584 <printf>
    panic("kerneltrap");
    80002b64:	00006517          	auipc	a0,0x6
    80002b68:	89450513          	addi	a0,a0,-1900 # 800083f8 <states.0+0x138>
    80002b6c:	ffffe097          	auipc	ra,0xffffe
    80002b70:	9ce080e7          	jalr	-1586(ra) # 8000053a <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING){
    80002b74:	fffff097          	auipc	ra,0xfffff
    80002b78:	e22080e7          	jalr	-478(ra) # 80001996 <myproc>
    80002b7c:	d159                	beqz	a0,80002b02 <kerneltrap+0x44>
    80002b7e:	fffff097          	auipc	ra,0xfffff
    80002b82:	e18080e7          	jalr	-488(ra) # 80001996 <myproc>
    80002b86:	4d18                	lw	a4,24(a0)
    80002b88:	4791                	li	a5,4
    80002b8a:	f6f71ce3          	bne	a4,a5,80002b02 <kerneltrap+0x44>
    p->cputime += 1; 
    80002b8e:	03492783          	lw	a5,52(s2)
    80002b92:	2785                	addiw	a5,a5,1
    80002b94:	02f92a23          	sw	a5,52(s2)
    yield();
    80002b98:	fffff097          	auipc	ra,0xfffff
    80002b9c:	48a080e7          	jalr	1162(ra) # 80002022 <yield>
    80002ba0:	b78d                	j	80002b02 <kerneltrap+0x44>

0000000080002ba2 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002ba2:	1101                	addi	sp,sp,-32
    80002ba4:	ec06                	sd	ra,24(sp)
    80002ba6:	e822                	sd	s0,16(sp)
    80002ba8:	e426                	sd	s1,8(sp)
    80002baa:	1000                	addi	s0,sp,32
    80002bac:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002bae:	fffff097          	auipc	ra,0xfffff
    80002bb2:	de8080e7          	jalr	-536(ra) # 80001996 <myproc>
  switch (n) {
    80002bb6:	4795                	li	a5,5
    80002bb8:	0497e163          	bltu	a5,s1,80002bfa <argraw+0x58>
    80002bbc:	048a                	slli	s1,s1,0x2
    80002bbe:	00006717          	auipc	a4,0x6
    80002bc2:	87270713          	addi	a4,a4,-1934 # 80008430 <states.0+0x170>
    80002bc6:	94ba                	add	s1,s1,a4
    80002bc8:	409c                	lw	a5,0(s1)
    80002bca:	97ba                	add	a5,a5,a4
    80002bcc:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002bce:	753c                	ld	a5,104(a0)
    80002bd0:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002bd2:	60e2                	ld	ra,24(sp)
    80002bd4:	6442                	ld	s0,16(sp)
    80002bd6:	64a2                	ld	s1,8(sp)
    80002bd8:	6105                	addi	sp,sp,32
    80002bda:	8082                	ret
    return p->trapframe->a1;
    80002bdc:	753c                	ld	a5,104(a0)
    80002bde:	7fa8                	ld	a0,120(a5)
    80002be0:	bfcd                	j	80002bd2 <argraw+0x30>
    return p->trapframe->a2;
    80002be2:	753c                	ld	a5,104(a0)
    80002be4:	63c8                	ld	a0,128(a5)
    80002be6:	b7f5                	j	80002bd2 <argraw+0x30>
    return p->trapframe->a3;
    80002be8:	753c                	ld	a5,104(a0)
    80002bea:	67c8                	ld	a0,136(a5)
    80002bec:	b7dd                	j	80002bd2 <argraw+0x30>
    return p->trapframe->a4;
    80002bee:	753c                	ld	a5,104(a0)
    80002bf0:	6bc8                	ld	a0,144(a5)
    80002bf2:	b7c5                	j	80002bd2 <argraw+0x30>
    return p->trapframe->a5;
    80002bf4:	753c                	ld	a5,104(a0)
    80002bf6:	6fc8                	ld	a0,152(a5)
    80002bf8:	bfe9                	j	80002bd2 <argraw+0x30>
  panic("argraw");
    80002bfa:	00006517          	auipc	a0,0x6
    80002bfe:	80e50513          	addi	a0,a0,-2034 # 80008408 <states.0+0x148>
    80002c02:	ffffe097          	auipc	ra,0xffffe
    80002c06:	938080e7          	jalr	-1736(ra) # 8000053a <panic>

0000000080002c0a <fetchaddr>:
{
    80002c0a:	1101                	addi	sp,sp,-32
    80002c0c:	ec06                	sd	ra,24(sp)
    80002c0e:	e822                	sd	s0,16(sp)
    80002c10:	e426                	sd	s1,8(sp)
    80002c12:	e04a                	sd	s2,0(sp)
    80002c14:	1000                	addi	s0,sp,32
    80002c16:	84aa                	mv	s1,a0
    80002c18:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002c1a:	fffff097          	auipc	ra,0xfffff
    80002c1e:	d7c080e7          	jalr	-644(ra) # 80001996 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002c22:	6d3c                	ld	a5,88(a0)
    80002c24:	02f4f863          	bgeu	s1,a5,80002c54 <fetchaddr+0x4a>
    80002c28:	00848713          	addi	a4,s1,8
    80002c2c:	02e7e663          	bltu	a5,a4,80002c58 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002c30:	46a1                	li	a3,8
    80002c32:	8626                	mv	a2,s1
    80002c34:	85ca                	mv	a1,s2
    80002c36:	7128                	ld	a0,96(a0)
    80002c38:	fffff097          	auipc	ra,0xfffff
    80002c3c:	aae080e7          	jalr	-1362(ra) # 800016e6 <copyin>
    80002c40:	00a03533          	snez	a0,a0
    80002c44:	40a00533          	neg	a0,a0
}
    80002c48:	60e2                	ld	ra,24(sp)
    80002c4a:	6442                	ld	s0,16(sp)
    80002c4c:	64a2                	ld	s1,8(sp)
    80002c4e:	6902                	ld	s2,0(sp)
    80002c50:	6105                	addi	sp,sp,32
    80002c52:	8082                	ret
    return -1;
    80002c54:	557d                	li	a0,-1
    80002c56:	bfcd                	j	80002c48 <fetchaddr+0x3e>
    80002c58:	557d                	li	a0,-1
    80002c5a:	b7fd                	j	80002c48 <fetchaddr+0x3e>

0000000080002c5c <fetchstr>:
{
    80002c5c:	7179                	addi	sp,sp,-48
    80002c5e:	f406                	sd	ra,40(sp)
    80002c60:	f022                	sd	s0,32(sp)
    80002c62:	ec26                	sd	s1,24(sp)
    80002c64:	e84a                	sd	s2,16(sp)
    80002c66:	e44e                	sd	s3,8(sp)
    80002c68:	1800                	addi	s0,sp,48
    80002c6a:	892a                	mv	s2,a0
    80002c6c:	84ae                	mv	s1,a1
    80002c6e:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002c70:	fffff097          	auipc	ra,0xfffff
    80002c74:	d26080e7          	jalr	-730(ra) # 80001996 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002c78:	86ce                	mv	a3,s3
    80002c7a:	864a                	mv	a2,s2
    80002c7c:	85a6                	mv	a1,s1
    80002c7e:	7128                	ld	a0,96(a0)
    80002c80:	fffff097          	auipc	ra,0xfffff
    80002c84:	af4080e7          	jalr	-1292(ra) # 80001774 <copyinstr>
  if(err < 0)
    80002c88:	00054763          	bltz	a0,80002c96 <fetchstr+0x3a>
  return strlen(buf);
    80002c8c:	8526                	mv	a0,s1
    80002c8e:	ffffe097          	auipc	ra,0xffffe
    80002c92:	1ba080e7          	jalr	442(ra) # 80000e48 <strlen>
}
    80002c96:	70a2                	ld	ra,40(sp)
    80002c98:	7402                	ld	s0,32(sp)
    80002c9a:	64e2                	ld	s1,24(sp)
    80002c9c:	6942                	ld	s2,16(sp)
    80002c9e:	69a2                	ld	s3,8(sp)
    80002ca0:	6145                	addi	sp,sp,48
    80002ca2:	8082                	ret

0000000080002ca4 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002ca4:	1101                	addi	sp,sp,-32
    80002ca6:	ec06                	sd	ra,24(sp)
    80002ca8:	e822                	sd	s0,16(sp)
    80002caa:	e426                	sd	s1,8(sp)
    80002cac:	1000                	addi	s0,sp,32
    80002cae:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002cb0:	00000097          	auipc	ra,0x0
    80002cb4:	ef2080e7          	jalr	-270(ra) # 80002ba2 <argraw>
    80002cb8:	c088                	sw	a0,0(s1)
  return 0;
}
    80002cba:	4501                	li	a0,0
    80002cbc:	60e2                	ld	ra,24(sp)
    80002cbe:	6442                	ld	s0,16(sp)
    80002cc0:	64a2                	ld	s1,8(sp)
    80002cc2:	6105                	addi	sp,sp,32
    80002cc4:	8082                	ret

0000000080002cc6 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002cc6:	1101                	addi	sp,sp,-32
    80002cc8:	ec06                	sd	ra,24(sp)
    80002cca:	e822                	sd	s0,16(sp)
    80002ccc:	e426                	sd	s1,8(sp)
    80002cce:	1000                	addi	s0,sp,32
    80002cd0:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002cd2:	00000097          	auipc	ra,0x0
    80002cd6:	ed0080e7          	jalr	-304(ra) # 80002ba2 <argraw>
    80002cda:	e088                	sd	a0,0(s1)
  return 0;
}
    80002cdc:	4501                	li	a0,0
    80002cde:	60e2                	ld	ra,24(sp)
    80002ce0:	6442                	ld	s0,16(sp)
    80002ce2:	64a2                	ld	s1,8(sp)
    80002ce4:	6105                	addi	sp,sp,32
    80002ce6:	8082                	ret

0000000080002ce8 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002ce8:	1101                	addi	sp,sp,-32
    80002cea:	ec06                	sd	ra,24(sp)
    80002cec:	e822                	sd	s0,16(sp)
    80002cee:	e426                	sd	s1,8(sp)
    80002cf0:	e04a                	sd	s2,0(sp)
    80002cf2:	1000                	addi	s0,sp,32
    80002cf4:	84ae                	mv	s1,a1
    80002cf6:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002cf8:	00000097          	auipc	ra,0x0
    80002cfc:	eaa080e7          	jalr	-342(ra) # 80002ba2 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002d00:	864a                	mv	a2,s2
    80002d02:	85a6                	mv	a1,s1
    80002d04:	00000097          	auipc	ra,0x0
    80002d08:	f58080e7          	jalr	-168(ra) # 80002c5c <fetchstr>
}
    80002d0c:	60e2                	ld	ra,24(sp)
    80002d0e:	6442                	ld	s0,16(sp)
    80002d10:	64a2                	ld	s1,8(sp)
    80002d12:	6902                	ld	s2,0(sp)
    80002d14:	6105                	addi	sp,sp,32
    80002d16:	8082                	ret

0000000080002d18 <syscall>:
[SYS_setpriority] sys_setpriority,
};

void
syscall(void)
{
    80002d18:	1101                	addi	sp,sp,-32
    80002d1a:	ec06                	sd	ra,24(sp)
    80002d1c:	e822                	sd	s0,16(sp)
    80002d1e:	e426                	sd	s1,8(sp)
    80002d20:	e04a                	sd	s2,0(sp)
    80002d22:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002d24:	fffff097          	auipc	ra,0xfffff
    80002d28:	c72080e7          	jalr	-910(ra) # 80001996 <myproc>
    80002d2c:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002d2e:	06853903          	ld	s2,104(a0)
    80002d32:	0a893783          	ld	a5,168(s2)
    80002d36:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002d3a:	37fd                	addiw	a5,a5,-1
    80002d3c:	4761                	li	a4,24
    80002d3e:	00f76f63          	bltu	a4,a5,80002d5c <syscall+0x44>
    80002d42:	00369713          	slli	a4,a3,0x3
    80002d46:	00005797          	auipc	a5,0x5
    80002d4a:	70278793          	addi	a5,a5,1794 # 80008448 <syscalls>
    80002d4e:	97ba                	add	a5,a5,a4
    80002d50:	639c                	ld	a5,0(a5)
    80002d52:	c789                	beqz	a5,80002d5c <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002d54:	9782                	jalr	a5
    80002d56:	06a93823          	sd	a0,112(s2)
    80002d5a:	a839                	j	80002d78 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002d5c:	16848613          	addi	a2,s1,360
    80002d60:	588c                	lw	a1,48(s1)
    80002d62:	00005517          	auipc	a0,0x5
    80002d66:	6ae50513          	addi	a0,a0,1710 # 80008410 <states.0+0x150>
    80002d6a:	ffffe097          	auipc	ra,0xffffe
    80002d6e:	81a080e7          	jalr	-2022(ra) # 80000584 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002d72:	74bc                	ld	a5,104(s1)
    80002d74:	577d                	li	a4,-1
    80002d76:	fbb8                	sd	a4,112(a5)
  }
}
    80002d78:	60e2                	ld	ra,24(sp)
    80002d7a:	6442                	ld	s0,16(sp)
    80002d7c:	64a2                	ld	s1,8(sp)
    80002d7e:	6902                	ld	s2,0(sp)
    80002d80:	6105                	addi	sp,sp,32
    80002d82:	8082                	ret

0000000080002d84 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002d84:	1101                	addi	sp,sp,-32
    80002d86:	ec06                	sd	ra,24(sp)
    80002d88:	e822                	sd	s0,16(sp)
    80002d8a:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002d8c:	fec40593          	addi	a1,s0,-20
    80002d90:	4501                	li	a0,0
    80002d92:	00000097          	auipc	ra,0x0
    80002d96:	f12080e7          	jalr	-238(ra) # 80002ca4 <argint>
    return -1;
    80002d9a:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002d9c:	00054963          	bltz	a0,80002dae <sys_exit+0x2a>
  exit(n);
    80002da0:	fec42503          	lw	a0,-20(s0)
    80002da4:	fffff097          	auipc	ra,0xfffff
    80002da8:	520080e7          	jalr	1312(ra) # 800022c4 <exit>
  return 0;  // not reached
    80002dac:	4781                	li	a5,0
}
    80002dae:	853e                	mv	a0,a5
    80002db0:	60e2                	ld	ra,24(sp)
    80002db2:	6442                	ld	s0,16(sp)
    80002db4:	6105                	addi	sp,sp,32
    80002db6:	8082                	ret

0000000080002db8 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002db8:	1141                	addi	sp,sp,-16
    80002dba:	e406                	sd	ra,8(sp)
    80002dbc:	e022                	sd	s0,0(sp)
    80002dbe:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002dc0:	fffff097          	auipc	ra,0xfffff
    80002dc4:	bd6080e7          	jalr	-1066(ra) # 80001996 <myproc>
}
    80002dc8:	5908                	lw	a0,48(a0)
    80002dca:	60a2                	ld	ra,8(sp)
    80002dcc:	6402                	ld	s0,0(sp)
    80002dce:	0141                	addi	sp,sp,16
    80002dd0:	8082                	ret

0000000080002dd2 <sys_fork>:

uint64
sys_fork(void)
{
    80002dd2:	1141                	addi	sp,sp,-16
    80002dd4:	e406                	sd	ra,8(sp)
    80002dd6:	e022                	sd	s0,0(sp)
    80002dd8:	0800                	addi	s0,sp,16
  return fork();
    80002dda:	fffff097          	auipc	ra,0xfffff
    80002dde:	f92080e7          	jalr	-110(ra) # 80001d6c <fork>
}
    80002de2:	60a2                	ld	ra,8(sp)
    80002de4:	6402                	ld	s0,0(sp)
    80002de6:	0141                	addi	sp,sp,16
    80002de8:	8082                	ret

0000000080002dea <sys_wait>:

uint64
sys_wait(void)
{
    80002dea:	1101                	addi	sp,sp,-32
    80002dec:	ec06                	sd	ra,24(sp)
    80002dee:	e822                	sd	s0,16(sp)
    80002df0:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002df2:	fe840593          	addi	a1,s0,-24
    80002df6:	4501                	li	a0,0
    80002df8:	00000097          	auipc	ra,0x0
    80002dfc:	ece080e7          	jalr	-306(ra) # 80002cc6 <argaddr>
    80002e00:	87aa                	mv	a5,a0
    return -1;
    80002e02:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002e04:	0007c863          	bltz	a5,80002e14 <sys_wait+0x2a>
  return wait(p);
    80002e08:	fe843503          	ld	a0,-24(s0)
    80002e0c:	fffff097          	auipc	ra,0xfffff
    80002e10:	2b6080e7          	jalr	694(ra) # 800020c2 <wait>
}
    80002e14:	60e2                	ld	ra,24(sp)
    80002e16:	6442                	ld	s0,16(sp)
    80002e18:	6105                	addi	sp,sp,32
    80002e1a:	8082                	ret

0000000080002e1c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002e1c:	7179                	addi	sp,sp,-48
    80002e1e:	f406                	sd	ra,40(sp)
    80002e20:	f022                	sd	s0,32(sp)
    80002e22:	ec26                	sd	s1,24(sp)
    80002e24:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002e26:	fdc40593          	addi	a1,s0,-36
    80002e2a:	4501                	li	a0,0
    80002e2c:	00000097          	auipc	ra,0x0
    80002e30:	e78080e7          	jalr	-392(ra) # 80002ca4 <argint>
    80002e34:	87aa                	mv	a5,a0
    return -1;
    80002e36:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002e38:	0207c063          	bltz	a5,80002e58 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002e3c:	fffff097          	auipc	ra,0xfffff
    80002e40:	b5a080e7          	jalr	-1190(ra) # 80001996 <myproc>
    80002e44:	4d24                	lw	s1,88(a0)
  if(growproc(n) < 0)
    80002e46:	fdc42503          	lw	a0,-36(s0)
    80002e4a:	fffff097          	auipc	ra,0xfffff
    80002e4e:	eaa080e7          	jalr	-342(ra) # 80001cf4 <growproc>
    80002e52:	00054863          	bltz	a0,80002e62 <sys_sbrk+0x46>
    return -1;
  return addr;
    80002e56:	8526                	mv	a0,s1
}
    80002e58:	70a2                	ld	ra,40(sp)
    80002e5a:	7402                	ld	s0,32(sp)
    80002e5c:	64e2                	ld	s1,24(sp)
    80002e5e:	6145                	addi	sp,sp,48
    80002e60:	8082                	ret
    return -1;
    80002e62:	557d                	li	a0,-1
    80002e64:	bfd5                	j	80002e58 <sys_sbrk+0x3c>

0000000080002e66 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002e66:	7139                	addi	sp,sp,-64
    80002e68:	fc06                	sd	ra,56(sp)
    80002e6a:	f822                	sd	s0,48(sp)
    80002e6c:	f426                	sd	s1,40(sp)
    80002e6e:	f04a                	sd	s2,32(sp)
    80002e70:	ec4e                	sd	s3,24(sp)
    80002e72:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002e74:	fcc40593          	addi	a1,s0,-52
    80002e78:	4501                	li	a0,0
    80002e7a:	00000097          	auipc	ra,0x0
    80002e7e:	e2a080e7          	jalr	-470(ra) # 80002ca4 <argint>
    return -1;
    80002e82:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002e84:	06054563          	bltz	a0,80002eee <sys_sleep+0x88>
  acquire(&tickslock);
    80002e88:	00014517          	auipc	a0,0x14
    80002e8c:	64850513          	addi	a0,a0,1608 # 800174d0 <tickslock>
    80002e90:	ffffe097          	auipc	ra,0xffffe
    80002e94:	d40080e7          	jalr	-704(ra) # 80000bd0 <acquire>
  ticks0 = ticks;
    80002e98:	00006917          	auipc	s2,0x6
    80002e9c:	19892903          	lw	s2,408(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    80002ea0:	fcc42783          	lw	a5,-52(s0)
    80002ea4:	cf85                	beqz	a5,80002edc <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002ea6:	00014997          	auipc	s3,0x14
    80002eaa:	62a98993          	addi	s3,s3,1578 # 800174d0 <tickslock>
    80002eae:	00006497          	auipc	s1,0x6
    80002eb2:	18248493          	addi	s1,s1,386 # 80009030 <ticks>
    if(myproc()->killed){
    80002eb6:	fffff097          	auipc	ra,0xfffff
    80002eba:	ae0080e7          	jalr	-1312(ra) # 80001996 <myproc>
    80002ebe:	551c                	lw	a5,40(a0)
    80002ec0:	ef9d                	bnez	a5,80002efe <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002ec2:	85ce                	mv	a1,s3
    80002ec4:	8526                	mv	a0,s1
    80002ec6:	fffff097          	auipc	ra,0xfffff
    80002eca:	198080e7          	jalr	408(ra) # 8000205e <sleep>
  while(ticks - ticks0 < n){
    80002ece:	409c                	lw	a5,0(s1)
    80002ed0:	412787bb          	subw	a5,a5,s2
    80002ed4:	fcc42703          	lw	a4,-52(s0)
    80002ed8:	fce7efe3          	bltu	a5,a4,80002eb6 <sys_sleep+0x50>
  }
  release(&tickslock);
    80002edc:	00014517          	auipc	a0,0x14
    80002ee0:	5f450513          	addi	a0,a0,1524 # 800174d0 <tickslock>
    80002ee4:	ffffe097          	auipc	ra,0xffffe
    80002ee8:	da0080e7          	jalr	-608(ra) # 80000c84 <release>
  return 0;
    80002eec:	4781                	li	a5,0
}
    80002eee:	853e                	mv	a0,a5
    80002ef0:	70e2                	ld	ra,56(sp)
    80002ef2:	7442                	ld	s0,48(sp)
    80002ef4:	74a2                	ld	s1,40(sp)
    80002ef6:	7902                	ld	s2,32(sp)
    80002ef8:	69e2                	ld	s3,24(sp)
    80002efa:	6121                	addi	sp,sp,64
    80002efc:	8082                	ret
      release(&tickslock);
    80002efe:	00014517          	auipc	a0,0x14
    80002f02:	5d250513          	addi	a0,a0,1490 # 800174d0 <tickslock>
    80002f06:	ffffe097          	auipc	ra,0xffffe
    80002f0a:	d7e080e7          	jalr	-642(ra) # 80000c84 <release>
      return -1;
    80002f0e:	57fd                	li	a5,-1
    80002f10:	bff9                	j	80002eee <sys_sleep+0x88>

0000000080002f12 <sys_kill>:

uint64
sys_kill(void)
{
    80002f12:	1101                	addi	sp,sp,-32
    80002f14:	ec06                	sd	ra,24(sp)
    80002f16:	e822                	sd	s0,16(sp)
    80002f18:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002f1a:	fec40593          	addi	a1,s0,-20
    80002f1e:	4501                	li	a0,0
    80002f20:	00000097          	auipc	ra,0x0
    80002f24:	d84080e7          	jalr	-636(ra) # 80002ca4 <argint>
    80002f28:	87aa                	mv	a5,a0
    return -1;
    80002f2a:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002f2c:	0007c863          	bltz	a5,80002f3c <sys_kill+0x2a>
  return kill(pid);
    80002f30:	fec42503          	lw	a0,-20(s0)
    80002f34:	fffff097          	auipc	ra,0xfffff
    80002f38:	466080e7          	jalr	1126(ra) # 8000239a <kill>
}
    80002f3c:	60e2                	ld	ra,24(sp)
    80002f3e:	6442                	ld	s0,16(sp)
    80002f40:	6105                	addi	sp,sp,32
    80002f42:	8082                	ret

0000000080002f44 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002f44:	1101                	addi	sp,sp,-32
    80002f46:	ec06                	sd	ra,24(sp)
    80002f48:	e822                	sd	s0,16(sp)
    80002f4a:	e426                	sd	s1,8(sp)
    80002f4c:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002f4e:	00014517          	auipc	a0,0x14
    80002f52:	58250513          	addi	a0,a0,1410 # 800174d0 <tickslock>
    80002f56:	ffffe097          	auipc	ra,0xffffe
    80002f5a:	c7a080e7          	jalr	-902(ra) # 80000bd0 <acquire>
  xticks = ticks;
    80002f5e:	00006497          	auipc	s1,0x6
    80002f62:	0d24a483          	lw	s1,210(s1) # 80009030 <ticks>
  release(&tickslock);
    80002f66:	00014517          	auipc	a0,0x14
    80002f6a:	56a50513          	addi	a0,a0,1386 # 800174d0 <tickslock>
    80002f6e:	ffffe097          	auipc	ra,0xffffe
    80002f72:	d16080e7          	jalr	-746(ra) # 80000c84 <release>
  return xticks;
}
    80002f76:	02049513          	slli	a0,s1,0x20
    80002f7a:	9101                	srli	a0,a0,0x20
    80002f7c:	60e2                	ld	ra,24(sp)
    80002f7e:	6442                	ld	s0,16(sp)
    80002f80:	64a2                	ld	s1,8(sp)
    80002f82:	6105                	addi	sp,sp,32
    80002f84:	8082                	ret

0000000080002f86 <sys_wait2>:


uint64
sys_wait2(void)
{
    80002f86:	1101                	addi	sp,sp,-32
    80002f88:	ec06                	sd	ra,24(sp)
    80002f8a:	e822                	sd	s0,16(sp)
    80002f8c:	1000                	addi	s0,sp,32
  uint64 p;
  uint64 p2;
  if(argaddr(0, &p) < 0){
    80002f8e:	fe840593          	addi	a1,s0,-24
    80002f92:	4501                	li	a0,0
    80002f94:	00000097          	auipc	ra,0x0
    80002f98:	d32080e7          	jalr	-718(ra) # 80002cc6 <argaddr>
    return -1;
    80002f9c:	57fd                	li	a5,-1
  if(argaddr(0, &p) < 0){
    80002f9e:	02054563          	bltz	a0,80002fc8 <sys_wait2+0x42>
  }
  if(argaddr(1,&p2) < 0){
    80002fa2:	fe040593          	addi	a1,s0,-32
    80002fa6:	4505                	li	a0,1
    80002fa8:	00000097          	auipc	ra,0x0
    80002fac:	d1e080e7          	jalr	-738(ra) # 80002cc6 <argaddr>
  return -1;
    80002fb0:	57fd                	li	a5,-1
  if(argaddr(1,&p2) < 0){
    80002fb2:	00054b63          	bltz	a0,80002fc8 <sys_wait2+0x42>
  }
  return wait2(p,p2);
    80002fb6:	fe043583          	ld	a1,-32(s0)
    80002fba:	fe843503          	ld	a0,-24(s0)
    80002fbe:	fffff097          	auipc	ra,0xfffff
    80002fc2:	668080e7          	jalr	1640(ra) # 80002626 <wait2>
    80002fc6:	87aa                	mv	a5,a0
}
    80002fc8:	853e                	mv	a0,a5
    80002fca:	60e2                	ld	ra,24(sp)
    80002fcc:	6442                	ld	s0,16(sp)
    80002fce:	6105                	addi	sp,sp,32
    80002fd0:	8082                	ret

0000000080002fd2 <sys_getpriority>:

uint64 
sys_getpriority(void){
    80002fd2:	1141                	addi	sp,sp,-16
    80002fd4:	e406                	sd	ra,8(sp)
    80002fd6:	e022                	sd	s0,0(sp)
    80002fd8:	0800                	addi	s0,sp,16
    return myproc()->priority;
    80002fda:	fffff097          	auipc	ra,0xfffff
    80002fde:	9bc080e7          	jalr	-1604(ra) # 80001996 <myproc>
}
    80002fe2:	5d08                	lw	a0,56(a0)
    80002fe4:	60a2                	ld	ra,8(sp)
    80002fe6:	6402                	ld	s0,0(sp)
    80002fe8:	0141                	addi	sp,sp,16
    80002fea:	8082                	ret

0000000080002fec <sys_setpriority>:

uint64
sys_setpriority(void){
    80002fec:	1101                	addi	sp,sp,-32
    80002fee:	ec06                	sd	ra,24(sp)
    80002ff0:	e822                	sd	s0,16(sp)
    80002ff2:	1000                	addi	s0,sp,32

  int priority;
  if(argint(0, &priority)<0){
    80002ff4:	fec40593          	addi	a1,s0,-20
    80002ff8:	4501                	li	a0,0
    80002ffa:	00000097          	auipc	ra,0x0
    80002ffe:	caa080e7          	jalr	-854(ra) # 80002ca4 <argint>
    return -1;
    80003002:	57fd                	li	a5,-1
  if(argint(0, &priority)<0){
    80003004:	00054a63          	bltz	a0,80003018 <sys_setpriority+0x2c>
  }
  myproc() -> priority = priority;
    80003008:	fffff097          	auipc	ra,0xfffff
    8000300c:	98e080e7          	jalr	-1650(ra) # 80001996 <myproc>
    80003010:	fec42783          	lw	a5,-20(s0)
    80003014:	dd1c                	sw	a5,56(a0)
  return 0;
    80003016:	4781                	li	a5,0
}
    80003018:	853e                	mv	a0,a5
    8000301a:	60e2                	ld	ra,24(sp)
    8000301c:	6442                	ld	s0,16(sp)
    8000301e:	6105                	addi	sp,sp,32
    80003020:	8082                	ret

0000000080003022 <sys_getprocs>:

uint64
sys_getprocs(void){
    80003022:	1101                	addi	sp,sp,-32
    80003024:	ec06                	sd	ra,24(sp)
    80003026:	e822                	sd	s0,16(sp)
    80003028:	1000                	addi	s0,sp,32

  uint64 addr;

  if(argaddr(0, &addr) <0){
    8000302a:	fe840593          	addi	a1,s0,-24
    8000302e:	4501                	li	a0,0
    80003030:	00000097          	auipc	ra,0x0
    80003034:	c96080e7          	jalr	-874(ra) # 80002cc6 <argaddr>
    80003038:	87aa                	mv	a5,a0
    return -1;
    8000303a:	557d                	li	a0,-1
  if(argaddr(0, &addr) <0){
    8000303c:	0007c863          	bltz	a5,8000304c <sys_getprocs+0x2a>

  }

  return(procinfo(addr));
    80003040:	fe843503          	ld	a0,-24(s0)
    80003044:	fffff097          	auipc	ra,0xfffff
    80003048:	524080e7          	jalr	1316(ra) # 80002568 <procinfo>

}
    8000304c:	60e2                	ld	ra,24(sp)
    8000304e:	6442                	ld	s0,16(sp)
    80003050:	6105                	addi	sp,sp,32
    80003052:	8082                	ret

0000000080003054 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003054:	7179                	addi	sp,sp,-48
    80003056:	f406                	sd	ra,40(sp)
    80003058:	f022                	sd	s0,32(sp)
    8000305a:	ec26                	sd	s1,24(sp)
    8000305c:	e84a                	sd	s2,16(sp)
    8000305e:	e44e                	sd	s3,8(sp)
    80003060:	e052                	sd	s4,0(sp)
    80003062:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003064:	00005597          	auipc	a1,0x5
    80003068:	4b458593          	addi	a1,a1,1204 # 80008518 <syscalls+0xd0>
    8000306c:	00014517          	auipc	a0,0x14
    80003070:	47c50513          	addi	a0,a0,1148 # 800174e8 <bcache>
    80003074:	ffffe097          	auipc	ra,0xffffe
    80003078:	acc080e7          	jalr	-1332(ra) # 80000b40 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000307c:	0001c797          	auipc	a5,0x1c
    80003080:	46c78793          	addi	a5,a5,1132 # 8001f4e8 <bcache+0x8000>
    80003084:	0001c717          	auipc	a4,0x1c
    80003088:	6cc70713          	addi	a4,a4,1740 # 8001f750 <bcache+0x8268>
    8000308c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003090:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003094:	00014497          	auipc	s1,0x14
    80003098:	46c48493          	addi	s1,s1,1132 # 80017500 <bcache+0x18>
    b->next = bcache.head.next;
    8000309c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000309e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800030a0:	00005a17          	auipc	s4,0x5
    800030a4:	480a0a13          	addi	s4,s4,1152 # 80008520 <syscalls+0xd8>
    b->next = bcache.head.next;
    800030a8:	2b893783          	ld	a5,696(s2)
    800030ac:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800030ae:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800030b2:	85d2                	mv	a1,s4
    800030b4:	01048513          	addi	a0,s1,16
    800030b8:	00001097          	auipc	ra,0x1
    800030bc:	4c2080e7          	jalr	1218(ra) # 8000457a <initsleeplock>
    bcache.head.next->prev = b;
    800030c0:	2b893783          	ld	a5,696(s2)
    800030c4:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800030c6:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030ca:	45848493          	addi	s1,s1,1112
    800030ce:	fd349de3          	bne	s1,s3,800030a8 <binit+0x54>
  }
}
    800030d2:	70a2                	ld	ra,40(sp)
    800030d4:	7402                	ld	s0,32(sp)
    800030d6:	64e2                	ld	s1,24(sp)
    800030d8:	6942                	ld	s2,16(sp)
    800030da:	69a2                	ld	s3,8(sp)
    800030dc:	6a02                	ld	s4,0(sp)
    800030de:	6145                	addi	sp,sp,48
    800030e0:	8082                	ret

00000000800030e2 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800030e2:	7179                	addi	sp,sp,-48
    800030e4:	f406                	sd	ra,40(sp)
    800030e6:	f022                	sd	s0,32(sp)
    800030e8:	ec26                	sd	s1,24(sp)
    800030ea:	e84a                	sd	s2,16(sp)
    800030ec:	e44e                	sd	s3,8(sp)
    800030ee:	1800                	addi	s0,sp,48
    800030f0:	892a                	mv	s2,a0
    800030f2:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800030f4:	00014517          	auipc	a0,0x14
    800030f8:	3f450513          	addi	a0,a0,1012 # 800174e8 <bcache>
    800030fc:	ffffe097          	auipc	ra,0xffffe
    80003100:	ad4080e7          	jalr	-1324(ra) # 80000bd0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003104:	0001c497          	auipc	s1,0x1c
    80003108:	69c4b483          	ld	s1,1692(s1) # 8001f7a0 <bcache+0x82b8>
    8000310c:	0001c797          	auipc	a5,0x1c
    80003110:	64478793          	addi	a5,a5,1604 # 8001f750 <bcache+0x8268>
    80003114:	02f48f63          	beq	s1,a5,80003152 <bread+0x70>
    80003118:	873e                	mv	a4,a5
    8000311a:	a021                	j	80003122 <bread+0x40>
    8000311c:	68a4                	ld	s1,80(s1)
    8000311e:	02e48a63          	beq	s1,a4,80003152 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003122:	449c                	lw	a5,8(s1)
    80003124:	ff279ce3          	bne	a5,s2,8000311c <bread+0x3a>
    80003128:	44dc                	lw	a5,12(s1)
    8000312a:	ff3799e3          	bne	a5,s3,8000311c <bread+0x3a>
      b->refcnt++;
    8000312e:	40bc                	lw	a5,64(s1)
    80003130:	2785                	addiw	a5,a5,1
    80003132:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003134:	00014517          	auipc	a0,0x14
    80003138:	3b450513          	addi	a0,a0,948 # 800174e8 <bcache>
    8000313c:	ffffe097          	auipc	ra,0xffffe
    80003140:	b48080e7          	jalr	-1208(ra) # 80000c84 <release>
      acquiresleep(&b->lock);
    80003144:	01048513          	addi	a0,s1,16
    80003148:	00001097          	auipc	ra,0x1
    8000314c:	46c080e7          	jalr	1132(ra) # 800045b4 <acquiresleep>
      return b;
    80003150:	a8b9                	j	800031ae <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003152:	0001c497          	auipc	s1,0x1c
    80003156:	6464b483          	ld	s1,1606(s1) # 8001f798 <bcache+0x82b0>
    8000315a:	0001c797          	auipc	a5,0x1c
    8000315e:	5f678793          	addi	a5,a5,1526 # 8001f750 <bcache+0x8268>
    80003162:	00f48863          	beq	s1,a5,80003172 <bread+0x90>
    80003166:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003168:	40bc                	lw	a5,64(s1)
    8000316a:	cf81                	beqz	a5,80003182 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000316c:	64a4                	ld	s1,72(s1)
    8000316e:	fee49de3          	bne	s1,a4,80003168 <bread+0x86>
  panic("bget: no buffers");
    80003172:	00005517          	auipc	a0,0x5
    80003176:	3b650513          	addi	a0,a0,950 # 80008528 <syscalls+0xe0>
    8000317a:	ffffd097          	auipc	ra,0xffffd
    8000317e:	3c0080e7          	jalr	960(ra) # 8000053a <panic>
      b->dev = dev;
    80003182:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003186:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000318a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000318e:	4785                	li	a5,1
    80003190:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003192:	00014517          	auipc	a0,0x14
    80003196:	35650513          	addi	a0,a0,854 # 800174e8 <bcache>
    8000319a:	ffffe097          	auipc	ra,0xffffe
    8000319e:	aea080e7          	jalr	-1302(ra) # 80000c84 <release>
      acquiresleep(&b->lock);
    800031a2:	01048513          	addi	a0,s1,16
    800031a6:	00001097          	auipc	ra,0x1
    800031aa:	40e080e7          	jalr	1038(ra) # 800045b4 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800031ae:	409c                	lw	a5,0(s1)
    800031b0:	cb89                	beqz	a5,800031c2 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800031b2:	8526                	mv	a0,s1
    800031b4:	70a2                	ld	ra,40(sp)
    800031b6:	7402                	ld	s0,32(sp)
    800031b8:	64e2                	ld	s1,24(sp)
    800031ba:	6942                	ld	s2,16(sp)
    800031bc:	69a2                	ld	s3,8(sp)
    800031be:	6145                	addi	sp,sp,48
    800031c0:	8082                	ret
    virtio_disk_rw(b, 0);
    800031c2:	4581                	li	a1,0
    800031c4:	8526                	mv	a0,s1
    800031c6:	00003097          	auipc	ra,0x3
    800031ca:	f2c080e7          	jalr	-212(ra) # 800060f2 <virtio_disk_rw>
    b->valid = 1;
    800031ce:	4785                	li	a5,1
    800031d0:	c09c                	sw	a5,0(s1)
  return b;
    800031d2:	b7c5                	j	800031b2 <bread+0xd0>

00000000800031d4 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800031d4:	1101                	addi	sp,sp,-32
    800031d6:	ec06                	sd	ra,24(sp)
    800031d8:	e822                	sd	s0,16(sp)
    800031da:	e426                	sd	s1,8(sp)
    800031dc:	1000                	addi	s0,sp,32
    800031de:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800031e0:	0541                	addi	a0,a0,16
    800031e2:	00001097          	auipc	ra,0x1
    800031e6:	46c080e7          	jalr	1132(ra) # 8000464e <holdingsleep>
    800031ea:	cd01                	beqz	a0,80003202 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800031ec:	4585                	li	a1,1
    800031ee:	8526                	mv	a0,s1
    800031f0:	00003097          	auipc	ra,0x3
    800031f4:	f02080e7          	jalr	-254(ra) # 800060f2 <virtio_disk_rw>
}
    800031f8:	60e2                	ld	ra,24(sp)
    800031fa:	6442                	ld	s0,16(sp)
    800031fc:	64a2                	ld	s1,8(sp)
    800031fe:	6105                	addi	sp,sp,32
    80003200:	8082                	ret
    panic("bwrite");
    80003202:	00005517          	auipc	a0,0x5
    80003206:	33e50513          	addi	a0,a0,830 # 80008540 <syscalls+0xf8>
    8000320a:	ffffd097          	auipc	ra,0xffffd
    8000320e:	330080e7          	jalr	816(ra) # 8000053a <panic>

0000000080003212 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003212:	1101                	addi	sp,sp,-32
    80003214:	ec06                	sd	ra,24(sp)
    80003216:	e822                	sd	s0,16(sp)
    80003218:	e426                	sd	s1,8(sp)
    8000321a:	e04a                	sd	s2,0(sp)
    8000321c:	1000                	addi	s0,sp,32
    8000321e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003220:	01050913          	addi	s2,a0,16
    80003224:	854a                	mv	a0,s2
    80003226:	00001097          	auipc	ra,0x1
    8000322a:	428080e7          	jalr	1064(ra) # 8000464e <holdingsleep>
    8000322e:	c92d                	beqz	a0,800032a0 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003230:	854a                	mv	a0,s2
    80003232:	00001097          	auipc	ra,0x1
    80003236:	3d8080e7          	jalr	984(ra) # 8000460a <releasesleep>

  acquire(&bcache.lock);
    8000323a:	00014517          	auipc	a0,0x14
    8000323e:	2ae50513          	addi	a0,a0,686 # 800174e8 <bcache>
    80003242:	ffffe097          	auipc	ra,0xffffe
    80003246:	98e080e7          	jalr	-1650(ra) # 80000bd0 <acquire>
  b->refcnt--;
    8000324a:	40bc                	lw	a5,64(s1)
    8000324c:	37fd                	addiw	a5,a5,-1
    8000324e:	0007871b          	sext.w	a4,a5
    80003252:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003254:	eb05                	bnez	a4,80003284 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003256:	68bc                	ld	a5,80(s1)
    80003258:	64b8                	ld	a4,72(s1)
    8000325a:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000325c:	64bc                	ld	a5,72(s1)
    8000325e:	68b8                	ld	a4,80(s1)
    80003260:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003262:	0001c797          	auipc	a5,0x1c
    80003266:	28678793          	addi	a5,a5,646 # 8001f4e8 <bcache+0x8000>
    8000326a:	2b87b703          	ld	a4,696(a5)
    8000326e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003270:	0001c717          	auipc	a4,0x1c
    80003274:	4e070713          	addi	a4,a4,1248 # 8001f750 <bcache+0x8268>
    80003278:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000327a:	2b87b703          	ld	a4,696(a5)
    8000327e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003280:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003284:	00014517          	auipc	a0,0x14
    80003288:	26450513          	addi	a0,a0,612 # 800174e8 <bcache>
    8000328c:	ffffe097          	auipc	ra,0xffffe
    80003290:	9f8080e7          	jalr	-1544(ra) # 80000c84 <release>
}
    80003294:	60e2                	ld	ra,24(sp)
    80003296:	6442                	ld	s0,16(sp)
    80003298:	64a2                	ld	s1,8(sp)
    8000329a:	6902                	ld	s2,0(sp)
    8000329c:	6105                	addi	sp,sp,32
    8000329e:	8082                	ret
    panic("brelse");
    800032a0:	00005517          	auipc	a0,0x5
    800032a4:	2a850513          	addi	a0,a0,680 # 80008548 <syscalls+0x100>
    800032a8:	ffffd097          	auipc	ra,0xffffd
    800032ac:	292080e7          	jalr	658(ra) # 8000053a <panic>

00000000800032b0 <bpin>:

void
bpin(struct buf *b) {
    800032b0:	1101                	addi	sp,sp,-32
    800032b2:	ec06                	sd	ra,24(sp)
    800032b4:	e822                	sd	s0,16(sp)
    800032b6:	e426                	sd	s1,8(sp)
    800032b8:	1000                	addi	s0,sp,32
    800032ba:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032bc:	00014517          	auipc	a0,0x14
    800032c0:	22c50513          	addi	a0,a0,556 # 800174e8 <bcache>
    800032c4:	ffffe097          	auipc	ra,0xffffe
    800032c8:	90c080e7          	jalr	-1780(ra) # 80000bd0 <acquire>
  b->refcnt++;
    800032cc:	40bc                	lw	a5,64(s1)
    800032ce:	2785                	addiw	a5,a5,1
    800032d0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800032d2:	00014517          	auipc	a0,0x14
    800032d6:	21650513          	addi	a0,a0,534 # 800174e8 <bcache>
    800032da:	ffffe097          	auipc	ra,0xffffe
    800032de:	9aa080e7          	jalr	-1622(ra) # 80000c84 <release>
}
    800032e2:	60e2                	ld	ra,24(sp)
    800032e4:	6442                	ld	s0,16(sp)
    800032e6:	64a2                	ld	s1,8(sp)
    800032e8:	6105                	addi	sp,sp,32
    800032ea:	8082                	ret

00000000800032ec <bunpin>:

void
bunpin(struct buf *b) {
    800032ec:	1101                	addi	sp,sp,-32
    800032ee:	ec06                	sd	ra,24(sp)
    800032f0:	e822                	sd	s0,16(sp)
    800032f2:	e426                	sd	s1,8(sp)
    800032f4:	1000                	addi	s0,sp,32
    800032f6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032f8:	00014517          	auipc	a0,0x14
    800032fc:	1f050513          	addi	a0,a0,496 # 800174e8 <bcache>
    80003300:	ffffe097          	auipc	ra,0xffffe
    80003304:	8d0080e7          	jalr	-1840(ra) # 80000bd0 <acquire>
  b->refcnt--;
    80003308:	40bc                	lw	a5,64(s1)
    8000330a:	37fd                	addiw	a5,a5,-1
    8000330c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000330e:	00014517          	auipc	a0,0x14
    80003312:	1da50513          	addi	a0,a0,474 # 800174e8 <bcache>
    80003316:	ffffe097          	auipc	ra,0xffffe
    8000331a:	96e080e7          	jalr	-1682(ra) # 80000c84 <release>
}
    8000331e:	60e2                	ld	ra,24(sp)
    80003320:	6442                	ld	s0,16(sp)
    80003322:	64a2                	ld	s1,8(sp)
    80003324:	6105                	addi	sp,sp,32
    80003326:	8082                	ret

0000000080003328 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003328:	1101                	addi	sp,sp,-32
    8000332a:	ec06                	sd	ra,24(sp)
    8000332c:	e822                	sd	s0,16(sp)
    8000332e:	e426                	sd	s1,8(sp)
    80003330:	e04a                	sd	s2,0(sp)
    80003332:	1000                	addi	s0,sp,32
    80003334:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003336:	00d5d59b          	srliw	a1,a1,0xd
    8000333a:	0001d797          	auipc	a5,0x1d
    8000333e:	88a7a783          	lw	a5,-1910(a5) # 8001fbc4 <sb+0x1c>
    80003342:	9dbd                	addw	a1,a1,a5
    80003344:	00000097          	auipc	ra,0x0
    80003348:	d9e080e7          	jalr	-610(ra) # 800030e2 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000334c:	0074f713          	andi	a4,s1,7
    80003350:	4785                	li	a5,1
    80003352:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003356:	14ce                	slli	s1,s1,0x33
    80003358:	90d9                	srli	s1,s1,0x36
    8000335a:	00950733          	add	a4,a0,s1
    8000335e:	05874703          	lbu	a4,88(a4)
    80003362:	00e7f6b3          	and	a3,a5,a4
    80003366:	c69d                	beqz	a3,80003394 <bfree+0x6c>
    80003368:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000336a:	94aa                	add	s1,s1,a0
    8000336c:	fff7c793          	not	a5,a5
    80003370:	8f7d                	and	a4,a4,a5
    80003372:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003376:	00001097          	auipc	ra,0x1
    8000337a:	120080e7          	jalr	288(ra) # 80004496 <log_write>
  brelse(bp);
    8000337e:	854a                	mv	a0,s2
    80003380:	00000097          	auipc	ra,0x0
    80003384:	e92080e7          	jalr	-366(ra) # 80003212 <brelse>
}
    80003388:	60e2                	ld	ra,24(sp)
    8000338a:	6442                	ld	s0,16(sp)
    8000338c:	64a2                	ld	s1,8(sp)
    8000338e:	6902                	ld	s2,0(sp)
    80003390:	6105                	addi	sp,sp,32
    80003392:	8082                	ret
    panic("freeing free block");
    80003394:	00005517          	auipc	a0,0x5
    80003398:	1bc50513          	addi	a0,a0,444 # 80008550 <syscalls+0x108>
    8000339c:	ffffd097          	auipc	ra,0xffffd
    800033a0:	19e080e7          	jalr	414(ra) # 8000053a <panic>

00000000800033a4 <balloc>:
{
    800033a4:	711d                	addi	sp,sp,-96
    800033a6:	ec86                	sd	ra,88(sp)
    800033a8:	e8a2                	sd	s0,80(sp)
    800033aa:	e4a6                	sd	s1,72(sp)
    800033ac:	e0ca                	sd	s2,64(sp)
    800033ae:	fc4e                	sd	s3,56(sp)
    800033b0:	f852                	sd	s4,48(sp)
    800033b2:	f456                	sd	s5,40(sp)
    800033b4:	f05a                	sd	s6,32(sp)
    800033b6:	ec5e                	sd	s7,24(sp)
    800033b8:	e862                	sd	s8,16(sp)
    800033ba:	e466                	sd	s9,8(sp)
    800033bc:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800033be:	0001c797          	auipc	a5,0x1c
    800033c2:	7ee7a783          	lw	a5,2030(a5) # 8001fbac <sb+0x4>
    800033c6:	cbc1                	beqz	a5,80003456 <balloc+0xb2>
    800033c8:	8baa                	mv	s7,a0
    800033ca:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800033cc:	0001cb17          	auipc	s6,0x1c
    800033d0:	7dcb0b13          	addi	s6,s6,2012 # 8001fba8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033d4:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800033d6:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033d8:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800033da:	6c89                	lui	s9,0x2
    800033dc:	a831                	j	800033f8 <balloc+0x54>
    brelse(bp);
    800033de:	854a                	mv	a0,s2
    800033e0:	00000097          	auipc	ra,0x0
    800033e4:	e32080e7          	jalr	-462(ra) # 80003212 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800033e8:	015c87bb          	addw	a5,s9,s5
    800033ec:	00078a9b          	sext.w	s5,a5
    800033f0:	004b2703          	lw	a4,4(s6)
    800033f4:	06eaf163          	bgeu	s5,a4,80003456 <balloc+0xb2>
    bp = bread(dev, BBLOCK(b, sb));
    800033f8:	41fad79b          	sraiw	a5,s5,0x1f
    800033fc:	0137d79b          	srliw	a5,a5,0x13
    80003400:	015787bb          	addw	a5,a5,s5
    80003404:	40d7d79b          	sraiw	a5,a5,0xd
    80003408:	01cb2583          	lw	a1,28(s6)
    8000340c:	9dbd                	addw	a1,a1,a5
    8000340e:	855e                	mv	a0,s7
    80003410:	00000097          	auipc	ra,0x0
    80003414:	cd2080e7          	jalr	-814(ra) # 800030e2 <bread>
    80003418:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000341a:	004b2503          	lw	a0,4(s6)
    8000341e:	000a849b          	sext.w	s1,s5
    80003422:	8762                	mv	a4,s8
    80003424:	faa4fde3          	bgeu	s1,a0,800033de <balloc+0x3a>
      m = 1 << (bi % 8);
    80003428:	00777693          	andi	a3,a4,7
    8000342c:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003430:	41f7579b          	sraiw	a5,a4,0x1f
    80003434:	01d7d79b          	srliw	a5,a5,0x1d
    80003438:	9fb9                	addw	a5,a5,a4
    8000343a:	4037d79b          	sraiw	a5,a5,0x3
    8000343e:	00f90633          	add	a2,s2,a5
    80003442:	05864603          	lbu	a2,88(a2)
    80003446:	00c6f5b3          	and	a1,a3,a2
    8000344a:	cd91                	beqz	a1,80003466 <balloc+0xc2>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000344c:	2705                	addiw	a4,a4,1
    8000344e:	2485                	addiw	s1,s1,1
    80003450:	fd471ae3          	bne	a4,s4,80003424 <balloc+0x80>
    80003454:	b769                	j	800033de <balloc+0x3a>
  panic("balloc: out of blocks");
    80003456:	00005517          	auipc	a0,0x5
    8000345a:	11250513          	addi	a0,a0,274 # 80008568 <syscalls+0x120>
    8000345e:	ffffd097          	auipc	ra,0xffffd
    80003462:	0dc080e7          	jalr	220(ra) # 8000053a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003466:	97ca                	add	a5,a5,s2
    80003468:	8e55                	or	a2,a2,a3
    8000346a:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000346e:	854a                	mv	a0,s2
    80003470:	00001097          	auipc	ra,0x1
    80003474:	026080e7          	jalr	38(ra) # 80004496 <log_write>
        brelse(bp);
    80003478:	854a                	mv	a0,s2
    8000347a:	00000097          	auipc	ra,0x0
    8000347e:	d98080e7          	jalr	-616(ra) # 80003212 <brelse>
  bp = bread(dev, bno);
    80003482:	85a6                	mv	a1,s1
    80003484:	855e                	mv	a0,s7
    80003486:	00000097          	auipc	ra,0x0
    8000348a:	c5c080e7          	jalr	-932(ra) # 800030e2 <bread>
    8000348e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003490:	40000613          	li	a2,1024
    80003494:	4581                	li	a1,0
    80003496:	05850513          	addi	a0,a0,88
    8000349a:	ffffe097          	auipc	ra,0xffffe
    8000349e:	832080e7          	jalr	-1998(ra) # 80000ccc <memset>
  log_write(bp);
    800034a2:	854a                	mv	a0,s2
    800034a4:	00001097          	auipc	ra,0x1
    800034a8:	ff2080e7          	jalr	-14(ra) # 80004496 <log_write>
  brelse(bp);
    800034ac:	854a                	mv	a0,s2
    800034ae:	00000097          	auipc	ra,0x0
    800034b2:	d64080e7          	jalr	-668(ra) # 80003212 <brelse>
}
    800034b6:	8526                	mv	a0,s1
    800034b8:	60e6                	ld	ra,88(sp)
    800034ba:	6446                	ld	s0,80(sp)
    800034bc:	64a6                	ld	s1,72(sp)
    800034be:	6906                	ld	s2,64(sp)
    800034c0:	79e2                	ld	s3,56(sp)
    800034c2:	7a42                	ld	s4,48(sp)
    800034c4:	7aa2                	ld	s5,40(sp)
    800034c6:	7b02                	ld	s6,32(sp)
    800034c8:	6be2                	ld	s7,24(sp)
    800034ca:	6c42                	ld	s8,16(sp)
    800034cc:	6ca2                	ld	s9,8(sp)
    800034ce:	6125                	addi	sp,sp,96
    800034d0:	8082                	ret

00000000800034d2 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800034d2:	7179                	addi	sp,sp,-48
    800034d4:	f406                	sd	ra,40(sp)
    800034d6:	f022                	sd	s0,32(sp)
    800034d8:	ec26                	sd	s1,24(sp)
    800034da:	e84a                	sd	s2,16(sp)
    800034dc:	e44e                	sd	s3,8(sp)
    800034de:	e052                	sd	s4,0(sp)
    800034e0:	1800                	addi	s0,sp,48
    800034e2:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800034e4:	47ad                	li	a5,11
    800034e6:	04b7fe63          	bgeu	a5,a1,80003542 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800034ea:	ff45849b          	addiw	s1,a1,-12
    800034ee:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800034f2:	0ff00793          	li	a5,255
    800034f6:	0ae7e463          	bltu	a5,a4,8000359e <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800034fa:	08052583          	lw	a1,128(a0)
    800034fe:	c5b5                	beqz	a1,8000356a <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003500:	00092503          	lw	a0,0(s2)
    80003504:	00000097          	auipc	ra,0x0
    80003508:	bde080e7          	jalr	-1058(ra) # 800030e2 <bread>
    8000350c:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000350e:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003512:	02049713          	slli	a4,s1,0x20
    80003516:	01e75593          	srli	a1,a4,0x1e
    8000351a:	00b784b3          	add	s1,a5,a1
    8000351e:	0004a983          	lw	s3,0(s1)
    80003522:	04098e63          	beqz	s3,8000357e <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003526:	8552                	mv	a0,s4
    80003528:	00000097          	auipc	ra,0x0
    8000352c:	cea080e7          	jalr	-790(ra) # 80003212 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003530:	854e                	mv	a0,s3
    80003532:	70a2                	ld	ra,40(sp)
    80003534:	7402                	ld	s0,32(sp)
    80003536:	64e2                	ld	s1,24(sp)
    80003538:	6942                	ld	s2,16(sp)
    8000353a:	69a2                	ld	s3,8(sp)
    8000353c:	6a02                	ld	s4,0(sp)
    8000353e:	6145                	addi	sp,sp,48
    80003540:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003542:	02059793          	slli	a5,a1,0x20
    80003546:	01e7d593          	srli	a1,a5,0x1e
    8000354a:	00b504b3          	add	s1,a0,a1
    8000354e:	0504a983          	lw	s3,80(s1)
    80003552:	fc099fe3          	bnez	s3,80003530 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003556:	4108                	lw	a0,0(a0)
    80003558:	00000097          	auipc	ra,0x0
    8000355c:	e4c080e7          	jalr	-436(ra) # 800033a4 <balloc>
    80003560:	0005099b          	sext.w	s3,a0
    80003564:	0534a823          	sw	s3,80(s1)
    80003568:	b7e1                	j	80003530 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    8000356a:	4108                	lw	a0,0(a0)
    8000356c:	00000097          	auipc	ra,0x0
    80003570:	e38080e7          	jalr	-456(ra) # 800033a4 <balloc>
    80003574:	0005059b          	sext.w	a1,a0
    80003578:	08b92023          	sw	a1,128(s2)
    8000357c:	b751                	j	80003500 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    8000357e:	00092503          	lw	a0,0(s2)
    80003582:	00000097          	auipc	ra,0x0
    80003586:	e22080e7          	jalr	-478(ra) # 800033a4 <balloc>
    8000358a:	0005099b          	sext.w	s3,a0
    8000358e:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003592:	8552                	mv	a0,s4
    80003594:	00001097          	auipc	ra,0x1
    80003598:	f02080e7          	jalr	-254(ra) # 80004496 <log_write>
    8000359c:	b769                	j	80003526 <bmap+0x54>
  panic("bmap: out of range");
    8000359e:	00005517          	auipc	a0,0x5
    800035a2:	fe250513          	addi	a0,a0,-30 # 80008580 <syscalls+0x138>
    800035a6:	ffffd097          	auipc	ra,0xffffd
    800035aa:	f94080e7          	jalr	-108(ra) # 8000053a <panic>

00000000800035ae <iget>:
{
    800035ae:	7179                	addi	sp,sp,-48
    800035b0:	f406                	sd	ra,40(sp)
    800035b2:	f022                	sd	s0,32(sp)
    800035b4:	ec26                	sd	s1,24(sp)
    800035b6:	e84a                	sd	s2,16(sp)
    800035b8:	e44e                	sd	s3,8(sp)
    800035ba:	e052                	sd	s4,0(sp)
    800035bc:	1800                	addi	s0,sp,48
    800035be:	89aa                	mv	s3,a0
    800035c0:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800035c2:	0001c517          	auipc	a0,0x1c
    800035c6:	60650513          	addi	a0,a0,1542 # 8001fbc8 <itable>
    800035ca:	ffffd097          	auipc	ra,0xffffd
    800035ce:	606080e7          	jalr	1542(ra) # 80000bd0 <acquire>
  empty = 0;
    800035d2:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800035d4:	0001c497          	auipc	s1,0x1c
    800035d8:	60c48493          	addi	s1,s1,1548 # 8001fbe0 <itable+0x18>
    800035dc:	0001e697          	auipc	a3,0x1e
    800035e0:	09468693          	addi	a3,a3,148 # 80021670 <log>
    800035e4:	a039                	j	800035f2 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800035e6:	02090b63          	beqz	s2,8000361c <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800035ea:	08848493          	addi	s1,s1,136
    800035ee:	02d48a63          	beq	s1,a3,80003622 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800035f2:	449c                	lw	a5,8(s1)
    800035f4:	fef059e3          	blez	a5,800035e6 <iget+0x38>
    800035f8:	4098                	lw	a4,0(s1)
    800035fa:	ff3716e3          	bne	a4,s3,800035e6 <iget+0x38>
    800035fe:	40d8                	lw	a4,4(s1)
    80003600:	ff4713e3          	bne	a4,s4,800035e6 <iget+0x38>
      ip->ref++;
    80003604:	2785                	addiw	a5,a5,1
    80003606:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003608:	0001c517          	auipc	a0,0x1c
    8000360c:	5c050513          	addi	a0,a0,1472 # 8001fbc8 <itable>
    80003610:	ffffd097          	auipc	ra,0xffffd
    80003614:	674080e7          	jalr	1652(ra) # 80000c84 <release>
      return ip;
    80003618:	8926                	mv	s2,s1
    8000361a:	a03d                	j	80003648 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000361c:	f7f9                	bnez	a5,800035ea <iget+0x3c>
    8000361e:	8926                	mv	s2,s1
    80003620:	b7e9                	j	800035ea <iget+0x3c>
  if(empty == 0)
    80003622:	02090c63          	beqz	s2,8000365a <iget+0xac>
  ip->dev = dev;
    80003626:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000362a:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000362e:	4785                	li	a5,1
    80003630:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003634:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003638:	0001c517          	auipc	a0,0x1c
    8000363c:	59050513          	addi	a0,a0,1424 # 8001fbc8 <itable>
    80003640:	ffffd097          	auipc	ra,0xffffd
    80003644:	644080e7          	jalr	1604(ra) # 80000c84 <release>
}
    80003648:	854a                	mv	a0,s2
    8000364a:	70a2                	ld	ra,40(sp)
    8000364c:	7402                	ld	s0,32(sp)
    8000364e:	64e2                	ld	s1,24(sp)
    80003650:	6942                	ld	s2,16(sp)
    80003652:	69a2                	ld	s3,8(sp)
    80003654:	6a02                	ld	s4,0(sp)
    80003656:	6145                	addi	sp,sp,48
    80003658:	8082                	ret
    panic("iget: no inodes");
    8000365a:	00005517          	auipc	a0,0x5
    8000365e:	f3e50513          	addi	a0,a0,-194 # 80008598 <syscalls+0x150>
    80003662:	ffffd097          	auipc	ra,0xffffd
    80003666:	ed8080e7          	jalr	-296(ra) # 8000053a <panic>

000000008000366a <fsinit>:
fsinit(int dev) {
    8000366a:	7179                	addi	sp,sp,-48
    8000366c:	f406                	sd	ra,40(sp)
    8000366e:	f022                	sd	s0,32(sp)
    80003670:	ec26                	sd	s1,24(sp)
    80003672:	e84a                	sd	s2,16(sp)
    80003674:	e44e                	sd	s3,8(sp)
    80003676:	1800                	addi	s0,sp,48
    80003678:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000367a:	4585                	li	a1,1
    8000367c:	00000097          	auipc	ra,0x0
    80003680:	a66080e7          	jalr	-1434(ra) # 800030e2 <bread>
    80003684:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003686:	0001c997          	auipc	s3,0x1c
    8000368a:	52298993          	addi	s3,s3,1314 # 8001fba8 <sb>
    8000368e:	02000613          	li	a2,32
    80003692:	05850593          	addi	a1,a0,88
    80003696:	854e                	mv	a0,s3
    80003698:	ffffd097          	auipc	ra,0xffffd
    8000369c:	690080e7          	jalr	1680(ra) # 80000d28 <memmove>
  brelse(bp);
    800036a0:	8526                	mv	a0,s1
    800036a2:	00000097          	auipc	ra,0x0
    800036a6:	b70080e7          	jalr	-1168(ra) # 80003212 <brelse>
  if(sb.magic != FSMAGIC)
    800036aa:	0009a703          	lw	a4,0(s3)
    800036ae:	102037b7          	lui	a5,0x10203
    800036b2:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800036b6:	02f71263          	bne	a4,a5,800036da <fsinit+0x70>
  initlog(dev, &sb);
    800036ba:	0001c597          	auipc	a1,0x1c
    800036be:	4ee58593          	addi	a1,a1,1262 # 8001fba8 <sb>
    800036c2:	854a                	mv	a0,s2
    800036c4:	00001097          	auipc	ra,0x1
    800036c8:	b56080e7          	jalr	-1194(ra) # 8000421a <initlog>
}
    800036cc:	70a2                	ld	ra,40(sp)
    800036ce:	7402                	ld	s0,32(sp)
    800036d0:	64e2                	ld	s1,24(sp)
    800036d2:	6942                	ld	s2,16(sp)
    800036d4:	69a2                	ld	s3,8(sp)
    800036d6:	6145                	addi	sp,sp,48
    800036d8:	8082                	ret
    panic("invalid file system");
    800036da:	00005517          	auipc	a0,0x5
    800036de:	ece50513          	addi	a0,a0,-306 # 800085a8 <syscalls+0x160>
    800036e2:	ffffd097          	auipc	ra,0xffffd
    800036e6:	e58080e7          	jalr	-424(ra) # 8000053a <panic>

00000000800036ea <iinit>:
{
    800036ea:	7179                	addi	sp,sp,-48
    800036ec:	f406                	sd	ra,40(sp)
    800036ee:	f022                	sd	s0,32(sp)
    800036f0:	ec26                	sd	s1,24(sp)
    800036f2:	e84a                	sd	s2,16(sp)
    800036f4:	e44e                	sd	s3,8(sp)
    800036f6:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800036f8:	00005597          	auipc	a1,0x5
    800036fc:	ec858593          	addi	a1,a1,-312 # 800085c0 <syscalls+0x178>
    80003700:	0001c517          	auipc	a0,0x1c
    80003704:	4c850513          	addi	a0,a0,1224 # 8001fbc8 <itable>
    80003708:	ffffd097          	auipc	ra,0xffffd
    8000370c:	438080e7          	jalr	1080(ra) # 80000b40 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003710:	0001c497          	auipc	s1,0x1c
    80003714:	4e048493          	addi	s1,s1,1248 # 8001fbf0 <itable+0x28>
    80003718:	0001e997          	auipc	s3,0x1e
    8000371c:	f6898993          	addi	s3,s3,-152 # 80021680 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003720:	00005917          	auipc	s2,0x5
    80003724:	ea890913          	addi	s2,s2,-344 # 800085c8 <syscalls+0x180>
    80003728:	85ca                	mv	a1,s2
    8000372a:	8526                	mv	a0,s1
    8000372c:	00001097          	auipc	ra,0x1
    80003730:	e4e080e7          	jalr	-434(ra) # 8000457a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003734:	08848493          	addi	s1,s1,136
    80003738:	ff3498e3          	bne	s1,s3,80003728 <iinit+0x3e>
}
    8000373c:	70a2                	ld	ra,40(sp)
    8000373e:	7402                	ld	s0,32(sp)
    80003740:	64e2                	ld	s1,24(sp)
    80003742:	6942                	ld	s2,16(sp)
    80003744:	69a2                	ld	s3,8(sp)
    80003746:	6145                	addi	sp,sp,48
    80003748:	8082                	ret

000000008000374a <ialloc>:
{
    8000374a:	715d                	addi	sp,sp,-80
    8000374c:	e486                	sd	ra,72(sp)
    8000374e:	e0a2                	sd	s0,64(sp)
    80003750:	fc26                	sd	s1,56(sp)
    80003752:	f84a                	sd	s2,48(sp)
    80003754:	f44e                	sd	s3,40(sp)
    80003756:	f052                	sd	s4,32(sp)
    80003758:	ec56                	sd	s5,24(sp)
    8000375a:	e85a                	sd	s6,16(sp)
    8000375c:	e45e                	sd	s7,8(sp)
    8000375e:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003760:	0001c717          	auipc	a4,0x1c
    80003764:	45472703          	lw	a4,1108(a4) # 8001fbb4 <sb+0xc>
    80003768:	4785                	li	a5,1
    8000376a:	04e7fa63          	bgeu	a5,a4,800037be <ialloc+0x74>
    8000376e:	8aaa                	mv	s5,a0
    80003770:	8bae                	mv	s7,a1
    80003772:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003774:	0001ca17          	auipc	s4,0x1c
    80003778:	434a0a13          	addi	s4,s4,1076 # 8001fba8 <sb>
    8000377c:	00048b1b          	sext.w	s6,s1
    80003780:	0044d593          	srli	a1,s1,0x4
    80003784:	018a2783          	lw	a5,24(s4)
    80003788:	9dbd                	addw	a1,a1,a5
    8000378a:	8556                	mv	a0,s5
    8000378c:	00000097          	auipc	ra,0x0
    80003790:	956080e7          	jalr	-1706(ra) # 800030e2 <bread>
    80003794:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003796:	05850993          	addi	s3,a0,88
    8000379a:	00f4f793          	andi	a5,s1,15
    8000379e:	079a                	slli	a5,a5,0x6
    800037a0:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800037a2:	00099783          	lh	a5,0(s3)
    800037a6:	c785                	beqz	a5,800037ce <ialloc+0x84>
    brelse(bp);
    800037a8:	00000097          	auipc	ra,0x0
    800037ac:	a6a080e7          	jalr	-1430(ra) # 80003212 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800037b0:	0485                	addi	s1,s1,1
    800037b2:	00ca2703          	lw	a4,12(s4)
    800037b6:	0004879b          	sext.w	a5,s1
    800037ba:	fce7e1e3          	bltu	a5,a4,8000377c <ialloc+0x32>
  panic("ialloc: no inodes");
    800037be:	00005517          	auipc	a0,0x5
    800037c2:	e1250513          	addi	a0,a0,-494 # 800085d0 <syscalls+0x188>
    800037c6:	ffffd097          	auipc	ra,0xffffd
    800037ca:	d74080e7          	jalr	-652(ra) # 8000053a <panic>
      memset(dip, 0, sizeof(*dip));
    800037ce:	04000613          	li	a2,64
    800037d2:	4581                	li	a1,0
    800037d4:	854e                	mv	a0,s3
    800037d6:	ffffd097          	auipc	ra,0xffffd
    800037da:	4f6080e7          	jalr	1270(ra) # 80000ccc <memset>
      dip->type = type;
    800037de:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800037e2:	854a                	mv	a0,s2
    800037e4:	00001097          	auipc	ra,0x1
    800037e8:	cb2080e7          	jalr	-846(ra) # 80004496 <log_write>
      brelse(bp);
    800037ec:	854a                	mv	a0,s2
    800037ee:	00000097          	auipc	ra,0x0
    800037f2:	a24080e7          	jalr	-1500(ra) # 80003212 <brelse>
      return iget(dev, inum);
    800037f6:	85da                	mv	a1,s6
    800037f8:	8556                	mv	a0,s5
    800037fa:	00000097          	auipc	ra,0x0
    800037fe:	db4080e7          	jalr	-588(ra) # 800035ae <iget>
}
    80003802:	60a6                	ld	ra,72(sp)
    80003804:	6406                	ld	s0,64(sp)
    80003806:	74e2                	ld	s1,56(sp)
    80003808:	7942                	ld	s2,48(sp)
    8000380a:	79a2                	ld	s3,40(sp)
    8000380c:	7a02                	ld	s4,32(sp)
    8000380e:	6ae2                	ld	s5,24(sp)
    80003810:	6b42                	ld	s6,16(sp)
    80003812:	6ba2                	ld	s7,8(sp)
    80003814:	6161                	addi	sp,sp,80
    80003816:	8082                	ret

0000000080003818 <iupdate>:
{
    80003818:	1101                	addi	sp,sp,-32
    8000381a:	ec06                	sd	ra,24(sp)
    8000381c:	e822                	sd	s0,16(sp)
    8000381e:	e426                	sd	s1,8(sp)
    80003820:	e04a                	sd	s2,0(sp)
    80003822:	1000                	addi	s0,sp,32
    80003824:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003826:	415c                	lw	a5,4(a0)
    80003828:	0047d79b          	srliw	a5,a5,0x4
    8000382c:	0001c597          	auipc	a1,0x1c
    80003830:	3945a583          	lw	a1,916(a1) # 8001fbc0 <sb+0x18>
    80003834:	9dbd                	addw	a1,a1,a5
    80003836:	4108                	lw	a0,0(a0)
    80003838:	00000097          	auipc	ra,0x0
    8000383c:	8aa080e7          	jalr	-1878(ra) # 800030e2 <bread>
    80003840:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003842:	05850793          	addi	a5,a0,88
    80003846:	40d8                	lw	a4,4(s1)
    80003848:	8b3d                	andi	a4,a4,15
    8000384a:	071a                	slli	a4,a4,0x6
    8000384c:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000384e:	04449703          	lh	a4,68(s1)
    80003852:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003856:	04649703          	lh	a4,70(s1)
    8000385a:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000385e:	04849703          	lh	a4,72(s1)
    80003862:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003866:	04a49703          	lh	a4,74(s1)
    8000386a:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000386e:	44f8                	lw	a4,76(s1)
    80003870:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003872:	03400613          	li	a2,52
    80003876:	05048593          	addi	a1,s1,80
    8000387a:	00c78513          	addi	a0,a5,12
    8000387e:	ffffd097          	auipc	ra,0xffffd
    80003882:	4aa080e7          	jalr	1194(ra) # 80000d28 <memmove>
  log_write(bp);
    80003886:	854a                	mv	a0,s2
    80003888:	00001097          	auipc	ra,0x1
    8000388c:	c0e080e7          	jalr	-1010(ra) # 80004496 <log_write>
  brelse(bp);
    80003890:	854a                	mv	a0,s2
    80003892:	00000097          	auipc	ra,0x0
    80003896:	980080e7          	jalr	-1664(ra) # 80003212 <brelse>
}
    8000389a:	60e2                	ld	ra,24(sp)
    8000389c:	6442                	ld	s0,16(sp)
    8000389e:	64a2                	ld	s1,8(sp)
    800038a0:	6902                	ld	s2,0(sp)
    800038a2:	6105                	addi	sp,sp,32
    800038a4:	8082                	ret

00000000800038a6 <idup>:
{
    800038a6:	1101                	addi	sp,sp,-32
    800038a8:	ec06                	sd	ra,24(sp)
    800038aa:	e822                	sd	s0,16(sp)
    800038ac:	e426                	sd	s1,8(sp)
    800038ae:	1000                	addi	s0,sp,32
    800038b0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800038b2:	0001c517          	auipc	a0,0x1c
    800038b6:	31650513          	addi	a0,a0,790 # 8001fbc8 <itable>
    800038ba:	ffffd097          	auipc	ra,0xffffd
    800038be:	316080e7          	jalr	790(ra) # 80000bd0 <acquire>
  ip->ref++;
    800038c2:	449c                	lw	a5,8(s1)
    800038c4:	2785                	addiw	a5,a5,1
    800038c6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800038c8:	0001c517          	auipc	a0,0x1c
    800038cc:	30050513          	addi	a0,a0,768 # 8001fbc8 <itable>
    800038d0:	ffffd097          	auipc	ra,0xffffd
    800038d4:	3b4080e7          	jalr	948(ra) # 80000c84 <release>
}
    800038d8:	8526                	mv	a0,s1
    800038da:	60e2                	ld	ra,24(sp)
    800038dc:	6442                	ld	s0,16(sp)
    800038de:	64a2                	ld	s1,8(sp)
    800038e0:	6105                	addi	sp,sp,32
    800038e2:	8082                	ret

00000000800038e4 <ilock>:
{
    800038e4:	1101                	addi	sp,sp,-32
    800038e6:	ec06                	sd	ra,24(sp)
    800038e8:	e822                	sd	s0,16(sp)
    800038ea:	e426                	sd	s1,8(sp)
    800038ec:	e04a                	sd	s2,0(sp)
    800038ee:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800038f0:	c115                	beqz	a0,80003914 <ilock+0x30>
    800038f2:	84aa                	mv	s1,a0
    800038f4:	451c                	lw	a5,8(a0)
    800038f6:	00f05f63          	blez	a5,80003914 <ilock+0x30>
  acquiresleep(&ip->lock);
    800038fa:	0541                	addi	a0,a0,16
    800038fc:	00001097          	auipc	ra,0x1
    80003900:	cb8080e7          	jalr	-840(ra) # 800045b4 <acquiresleep>
  if(ip->valid == 0){
    80003904:	40bc                	lw	a5,64(s1)
    80003906:	cf99                	beqz	a5,80003924 <ilock+0x40>
}
    80003908:	60e2                	ld	ra,24(sp)
    8000390a:	6442                	ld	s0,16(sp)
    8000390c:	64a2                	ld	s1,8(sp)
    8000390e:	6902                	ld	s2,0(sp)
    80003910:	6105                	addi	sp,sp,32
    80003912:	8082                	ret
    panic("ilock");
    80003914:	00005517          	auipc	a0,0x5
    80003918:	cd450513          	addi	a0,a0,-812 # 800085e8 <syscalls+0x1a0>
    8000391c:	ffffd097          	auipc	ra,0xffffd
    80003920:	c1e080e7          	jalr	-994(ra) # 8000053a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003924:	40dc                	lw	a5,4(s1)
    80003926:	0047d79b          	srliw	a5,a5,0x4
    8000392a:	0001c597          	auipc	a1,0x1c
    8000392e:	2965a583          	lw	a1,662(a1) # 8001fbc0 <sb+0x18>
    80003932:	9dbd                	addw	a1,a1,a5
    80003934:	4088                	lw	a0,0(s1)
    80003936:	fffff097          	auipc	ra,0xfffff
    8000393a:	7ac080e7          	jalr	1964(ra) # 800030e2 <bread>
    8000393e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003940:	05850593          	addi	a1,a0,88
    80003944:	40dc                	lw	a5,4(s1)
    80003946:	8bbd                	andi	a5,a5,15
    80003948:	079a                	slli	a5,a5,0x6
    8000394a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000394c:	00059783          	lh	a5,0(a1)
    80003950:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003954:	00259783          	lh	a5,2(a1)
    80003958:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000395c:	00459783          	lh	a5,4(a1)
    80003960:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003964:	00659783          	lh	a5,6(a1)
    80003968:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000396c:	459c                	lw	a5,8(a1)
    8000396e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003970:	03400613          	li	a2,52
    80003974:	05b1                	addi	a1,a1,12
    80003976:	05048513          	addi	a0,s1,80
    8000397a:	ffffd097          	auipc	ra,0xffffd
    8000397e:	3ae080e7          	jalr	942(ra) # 80000d28 <memmove>
    brelse(bp);
    80003982:	854a                	mv	a0,s2
    80003984:	00000097          	auipc	ra,0x0
    80003988:	88e080e7          	jalr	-1906(ra) # 80003212 <brelse>
    ip->valid = 1;
    8000398c:	4785                	li	a5,1
    8000398e:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003990:	04449783          	lh	a5,68(s1)
    80003994:	fbb5                	bnez	a5,80003908 <ilock+0x24>
      panic("ilock: no type");
    80003996:	00005517          	auipc	a0,0x5
    8000399a:	c5a50513          	addi	a0,a0,-934 # 800085f0 <syscalls+0x1a8>
    8000399e:	ffffd097          	auipc	ra,0xffffd
    800039a2:	b9c080e7          	jalr	-1124(ra) # 8000053a <panic>

00000000800039a6 <iunlock>:
{
    800039a6:	1101                	addi	sp,sp,-32
    800039a8:	ec06                	sd	ra,24(sp)
    800039aa:	e822                	sd	s0,16(sp)
    800039ac:	e426                	sd	s1,8(sp)
    800039ae:	e04a                	sd	s2,0(sp)
    800039b0:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800039b2:	c905                	beqz	a0,800039e2 <iunlock+0x3c>
    800039b4:	84aa                	mv	s1,a0
    800039b6:	01050913          	addi	s2,a0,16
    800039ba:	854a                	mv	a0,s2
    800039bc:	00001097          	auipc	ra,0x1
    800039c0:	c92080e7          	jalr	-878(ra) # 8000464e <holdingsleep>
    800039c4:	cd19                	beqz	a0,800039e2 <iunlock+0x3c>
    800039c6:	449c                	lw	a5,8(s1)
    800039c8:	00f05d63          	blez	a5,800039e2 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800039cc:	854a                	mv	a0,s2
    800039ce:	00001097          	auipc	ra,0x1
    800039d2:	c3c080e7          	jalr	-964(ra) # 8000460a <releasesleep>
}
    800039d6:	60e2                	ld	ra,24(sp)
    800039d8:	6442                	ld	s0,16(sp)
    800039da:	64a2                	ld	s1,8(sp)
    800039dc:	6902                	ld	s2,0(sp)
    800039de:	6105                	addi	sp,sp,32
    800039e0:	8082                	ret
    panic("iunlock");
    800039e2:	00005517          	auipc	a0,0x5
    800039e6:	c1e50513          	addi	a0,a0,-994 # 80008600 <syscalls+0x1b8>
    800039ea:	ffffd097          	auipc	ra,0xffffd
    800039ee:	b50080e7          	jalr	-1200(ra) # 8000053a <panic>

00000000800039f2 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800039f2:	7179                	addi	sp,sp,-48
    800039f4:	f406                	sd	ra,40(sp)
    800039f6:	f022                	sd	s0,32(sp)
    800039f8:	ec26                	sd	s1,24(sp)
    800039fa:	e84a                	sd	s2,16(sp)
    800039fc:	e44e                	sd	s3,8(sp)
    800039fe:	e052                	sd	s4,0(sp)
    80003a00:	1800                	addi	s0,sp,48
    80003a02:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003a04:	05050493          	addi	s1,a0,80
    80003a08:	08050913          	addi	s2,a0,128
    80003a0c:	a021                	j	80003a14 <itrunc+0x22>
    80003a0e:	0491                	addi	s1,s1,4
    80003a10:	01248d63          	beq	s1,s2,80003a2a <itrunc+0x38>
    if(ip->addrs[i]){
    80003a14:	408c                	lw	a1,0(s1)
    80003a16:	dde5                	beqz	a1,80003a0e <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003a18:	0009a503          	lw	a0,0(s3)
    80003a1c:	00000097          	auipc	ra,0x0
    80003a20:	90c080e7          	jalr	-1780(ra) # 80003328 <bfree>
      ip->addrs[i] = 0;
    80003a24:	0004a023          	sw	zero,0(s1)
    80003a28:	b7dd                	j	80003a0e <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003a2a:	0809a583          	lw	a1,128(s3)
    80003a2e:	e185                	bnez	a1,80003a4e <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003a30:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003a34:	854e                	mv	a0,s3
    80003a36:	00000097          	auipc	ra,0x0
    80003a3a:	de2080e7          	jalr	-542(ra) # 80003818 <iupdate>
}
    80003a3e:	70a2                	ld	ra,40(sp)
    80003a40:	7402                	ld	s0,32(sp)
    80003a42:	64e2                	ld	s1,24(sp)
    80003a44:	6942                	ld	s2,16(sp)
    80003a46:	69a2                	ld	s3,8(sp)
    80003a48:	6a02                	ld	s4,0(sp)
    80003a4a:	6145                	addi	sp,sp,48
    80003a4c:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003a4e:	0009a503          	lw	a0,0(s3)
    80003a52:	fffff097          	auipc	ra,0xfffff
    80003a56:	690080e7          	jalr	1680(ra) # 800030e2 <bread>
    80003a5a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003a5c:	05850493          	addi	s1,a0,88
    80003a60:	45850913          	addi	s2,a0,1112
    80003a64:	a021                	j	80003a6c <itrunc+0x7a>
    80003a66:	0491                	addi	s1,s1,4
    80003a68:	01248b63          	beq	s1,s2,80003a7e <itrunc+0x8c>
      if(a[j])
    80003a6c:	408c                	lw	a1,0(s1)
    80003a6e:	dde5                	beqz	a1,80003a66 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003a70:	0009a503          	lw	a0,0(s3)
    80003a74:	00000097          	auipc	ra,0x0
    80003a78:	8b4080e7          	jalr	-1868(ra) # 80003328 <bfree>
    80003a7c:	b7ed                	j	80003a66 <itrunc+0x74>
    brelse(bp);
    80003a7e:	8552                	mv	a0,s4
    80003a80:	fffff097          	auipc	ra,0xfffff
    80003a84:	792080e7          	jalr	1938(ra) # 80003212 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003a88:	0809a583          	lw	a1,128(s3)
    80003a8c:	0009a503          	lw	a0,0(s3)
    80003a90:	00000097          	auipc	ra,0x0
    80003a94:	898080e7          	jalr	-1896(ra) # 80003328 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003a98:	0809a023          	sw	zero,128(s3)
    80003a9c:	bf51                	j	80003a30 <itrunc+0x3e>

0000000080003a9e <iput>:
{
    80003a9e:	1101                	addi	sp,sp,-32
    80003aa0:	ec06                	sd	ra,24(sp)
    80003aa2:	e822                	sd	s0,16(sp)
    80003aa4:	e426                	sd	s1,8(sp)
    80003aa6:	e04a                	sd	s2,0(sp)
    80003aa8:	1000                	addi	s0,sp,32
    80003aaa:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003aac:	0001c517          	auipc	a0,0x1c
    80003ab0:	11c50513          	addi	a0,a0,284 # 8001fbc8 <itable>
    80003ab4:	ffffd097          	auipc	ra,0xffffd
    80003ab8:	11c080e7          	jalr	284(ra) # 80000bd0 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003abc:	4498                	lw	a4,8(s1)
    80003abe:	4785                	li	a5,1
    80003ac0:	02f70363          	beq	a4,a5,80003ae6 <iput+0x48>
  ip->ref--;
    80003ac4:	449c                	lw	a5,8(s1)
    80003ac6:	37fd                	addiw	a5,a5,-1
    80003ac8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003aca:	0001c517          	auipc	a0,0x1c
    80003ace:	0fe50513          	addi	a0,a0,254 # 8001fbc8 <itable>
    80003ad2:	ffffd097          	auipc	ra,0xffffd
    80003ad6:	1b2080e7          	jalr	434(ra) # 80000c84 <release>
}
    80003ada:	60e2                	ld	ra,24(sp)
    80003adc:	6442                	ld	s0,16(sp)
    80003ade:	64a2                	ld	s1,8(sp)
    80003ae0:	6902                	ld	s2,0(sp)
    80003ae2:	6105                	addi	sp,sp,32
    80003ae4:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003ae6:	40bc                	lw	a5,64(s1)
    80003ae8:	dff1                	beqz	a5,80003ac4 <iput+0x26>
    80003aea:	04a49783          	lh	a5,74(s1)
    80003aee:	fbf9                	bnez	a5,80003ac4 <iput+0x26>
    acquiresleep(&ip->lock);
    80003af0:	01048913          	addi	s2,s1,16
    80003af4:	854a                	mv	a0,s2
    80003af6:	00001097          	auipc	ra,0x1
    80003afa:	abe080e7          	jalr	-1346(ra) # 800045b4 <acquiresleep>
    release(&itable.lock);
    80003afe:	0001c517          	auipc	a0,0x1c
    80003b02:	0ca50513          	addi	a0,a0,202 # 8001fbc8 <itable>
    80003b06:	ffffd097          	auipc	ra,0xffffd
    80003b0a:	17e080e7          	jalr	382(ra) # 80000c84 <release>
    itrunc(ip);
    80003b0e:	8526                	mv	a0,s1
    80003b10:	00000097          	auipc	ra,0x0
    80003b14:	ee2080e7          	jalr	-286(ra) # 800039f2 <itrunc>
    ip->type = 0;
    80003b18:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003b1c:	8526                	mv	a0,s1
    80003b1e:	00000097          	auipc	ra,0x0
    80003b22:	cfa080e7          	jalr	-774(ra) # 80003818 <iupdate>
    ip->valid = 0;
    80003b26:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003b2a:	854a                	mv	a0,s2
    80003b2c:	00001097          	auipc	ra,0x1
    80003b30:	ade080e7          	jalr	-1314(ra) # 8000460a <releasesleep>
    acquire(&itable.lock);
    80003b34:	0001c517          	auipc	a0,0x1c
    80003b38:	09450513          	addi	a0,a0,148 # 8001fbc8 <itable>
    80003b3c:	ffffd097          	auipc	ra,0xffffd
    80003b40:	094080e7          	jalr	148(ra) # 80000bd0 <acquire>
    80003b44:	b741                	j	80003ac4 <iput+0x26>

0000000080003b46 <iunlockput>:
{
    80003b46:	1101                	addi	sp,sp,-32
    80003b48:	ec06                	sd	ra,24(sp)
    80003b4a:	e822                	sd	s0,16(sp)
    80003b4c:	e426                	sd	s1,8(sp)
    80003b4e:	1000                	addi	s0,sp,32
    80003b50:	84aa                	mv	s1,a0
  iunlock(ip);
    80003b52:	00000097          	auipc	ra,0x0
    80003b56:	e54080e7          	jalr	-428(ra) # 800039a6 <iunlock>
  iput(ip);
    80003b5a:	8526                	mv	a0,s1
    80003b5c:	00000097          	auipc	ra,0x0
    80003b60:	f42080e7          	jalr	-190(ra) # 80003a9e <iput>
}
    80003b64:	60e2                	ld	ra,24(sp)
    80003b66:	6442                	ld	s0,16(sp)
    80003b68:	64a2                	ld	s1,8(sp)
    80003b6a:	6105                	addi	sp,sp,32
    80003b6c:	8082                	ret

0000000080003b6e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003b6e:	1141                	addi	sp,sp,-16
    80003b70:	e422                	sd	s0,8(sp)
    80003b72:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003b74:	411c                	lw	a5,0(a0)
    80003b76:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003b78:	415c                	lw	a5,4(a0)
    80003b7a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003b7c:	04451783          	lh	a5,68(a0)
    80003b80:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003b84:	04a51783          	lh	a5,74(a0)
    80003b88:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003b8c:	04c56783          	lwu	a5,76(a0)
    80003b90:	e99c                	sd	a5,16(a1)
}
    80003b92:	6422                	ld	s0,8(sp)
    80003b94:	0141                	addi	sp,sp,16
    80003b96:	8082                	ret

0000000080003b98 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b98:	457c                	lw	a5,76(a0)
    80003b9a:	0ed7e963          	bltu	a5,a3,80003c8c <readi+0xf4>
{
    80003b9e:	7159                	addi	sp,sp,-112
    80003ba0:	f486                	sd	ra,104(sp)
    80003ba2:	f0a2                	sd	s0,96(sp)
    80003ba4:	eca6                	sd	s1,88(sp)
    80003ba6:	e8ca                	sd	s2,80(sp)
    80003ba8:	e4ce                	sd	s3,72(sp)
    80003baa:	e0d2                	sd	s4,64(sp)
    80003bac:	fc56                	sd	s5,56(sp)
    80003bae:	f85a                	sd	s6,48(sp)
    80003bb0:	f45e                	sd	s7,40(sp)
    80003bb2:	f062                	sd	s8,32(sp)
    80003bb4:	ec66                	sd	s9,24(sp)
    80003bb6:	e86a                	sd	s10,16(sp)
    80003bb8:	e46e                	sd	s11,8(sp)
    80003bba:	1880                	addi	s0,sp,112
    80003bbc:	8baa                	mv	s7,a0
    80003bbe:	8c2e                	mv	s8,a1
    80003bc0:	8ab2                	mv	s5,a2
    80003bc2:	84b6                	mv	s1,a3
    80003bc4:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003bc6:	9f35                	addw	a4,a4,a3
    return 0;
    80003bc8:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003bca:	0ad76063          	bltu	a4,a3,80003c6a <readi+0xd2>
  if(off + n > ip->size)
    80003bce:	00e7f463          	bgeu	a5,a4,80003bd6 <readi+0x3e>
    n = ip->size - off;
    80003bd2:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003bd6:	0a0b0963          	beqz	s6,80003c88 <readi+0xf0>
    80003bda:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bdc:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003be0:	5cfd                	li	s9,-1
    80003be2:	a82d                	j	80003c1c <readi+0x84>
    80003be4:	020a1d93          	slli	s11,s4,0x20
    80003be8:	020ddd93          	srli	s11,s11,0x20
    80003bec:	05890613          	addi	a2,s2,88
    80003bf0:	86ee                	mv	a3,s11
    80003bf2:	963a                	add	a2,a2,a4
    80003bf4:	85d6                	mv	a1,s5
    80003bf6:	8562                	mv	a0,s8
    80003bf8:	fffff097          	auipc	ra,0xfffff
    80003bfc:	814080e7          	jalr	-2028(ra) # 8000240c <either_copyout>
    80003c00:	05950d63          	beq	a0,s9,80003c5a <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003c04:	854a                	mv	a0,s2
    80003c06:	fffff097          	auipc	ra,0xfffff
    80003c0a:	60c080e7          	jalr	1548(ra) # 80003212 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c0e:	013a09bb          	addw	s3,s4,s3
    80003c12:	009a04bb          	addw	s1,s4,s1
    80003c16:	9aee                	add	s5,s5,s11
    80003c18:	0569f763          	bgeu	s3,s6,80003c66 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003c1c:	000ba903          	lw	s2,0(s7)
    80003c20:	00a4d59b          	srliw	a1,s1,0xa
    80003c24:	855e                	mv	a0,s7
    80003c26:	00000097          	auipc	ra,0x0
    80003c2a:	8ac080e7          	jalr	-1876(ra) # 800034d2 <bmap>
    80003c2e:	0005059b          	sext.w	a1,a0
    80003c32:	854a                	mv	a0,s2
    80003c34:	fffff097          	auipc	ra,0xfffff
    80003c38:	4ae080e7          	jalr	1198(ra) # 800030e2 <bread>
    80003c3c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c3e:	3ff4f713          	andi	a4,s1,1023
    80003c42:	40ed07bb          	subw	a5,s10,a4
    80003c46:	413b06bb          	subw	a3,s6,s3
    80003c4a:	8a3e                	mv	s4,a5
    80003c4c:	2781                	sext.w	a5,a5
    80003c4e:	0006861b          	sext.w	a2,a3
    80003c52:	f8f679e3          	bgeu	a2,a5,80003be4 <readi+0x4c>
    80003c56:	8a36                	mv	s4,a3
    80003c58:	b771                	j	80003be4 <readi+0x4c>
      brelse(bp);
    80003c5a:	854a                	mv	a0,s2
    80003c5c:	fffff097          	auipc	ra,0xfffff
    80003c60:	5b6080e7          	jalr	1462(ra) # 80003212 <brelse>
      tot = -1;
    80003c64:	59fd                	li	s3,-1
  }
  return tot;
    80003c66:	0009851b          	sext.w	a0,s3
}
    80003c6a:	70a6                	ld	ra,104(sp)
    80003c6c:	7406                	ld	s0,96(sp)
    80003c6e:	64e6                	ld	s1,88(sp)
    80003c70:	6946                	ld	s2,80(sp)
    80003c72:	69a6                	ld	s3,72(sp)
    80003c74:	6a06                	ld	s4,64(sp)
    80003c76:	7ae2                	ld	s5,56(sp)
    80003c78:	7b42                	ld	s6,48(sp)
    80003c7a:	7ba2                	ld	s7,40(sp)
    80003c7c:	7c02                	ld	s8,32(sp)
    80003c7e:	6ce2                	ld	s9,24(sp)
    80003c80:	6d42                	ld	s10,16(sp)
    80003c82:	6da2                	ld	s11,8(sp)
    80003c84:	6165                	addi	sp,sp,112
    80003c86:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c88:	89da                	mv	s3,s6
    80003c8a:	bff1                	j	80003c66 <readi+0xce>
    return 0;
    80003c8c:	4501                	li	a0,0
}
    80003c8e:	8082                	ret

0000000080003c90 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c90:	457c                	lw	a5,76(a0)
    80003c92:	10d7e863          	bltu	a5,a3,80003da2 <writei+0x112>
{
    80003c96:	7159                	addi	sp,sp,-112
    80003c98:	f486                	sd	ra,104(sp)
    80003c9a:	f0a2                	sd	s0,96(sp)
    80003c9c:	eca6                	sd	s1,88(sp)
    80003c9e:	e8ca                	sd	s2,80(sp)
    80003ca0:	e4ce                	sd	s3,72(sp)
    80003ca2:	e0d2                	sd	s4,64(sp)
    80003ca4:	fc56                	sd	s5,56(sp)
    80003ca6:	f85a                	sd	s6,48(sp)
    80003ca8:	f45e                	sd	s7,40(sp)
    80003caa:	f062                	sd	s8,32(sp)
    80003cac:	ec66                	sd	s9,24(sp)
    80003cae:	e86a                	sd	s10,16(sp)
    80003cb0:	e46e                	sd	s11,8(sp)
    80003cb2:	1880                	addi	s0,sp,112
    80003cb4:	8b2a                	mv	s6,a0
    80003cb6:	8c2e                	mv	s8,a1
    80003cb8:	8ab2                	mv	s5,a2
    80003cba:	8936                	mv	s2,a3
    80003cbc:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003cbe:	00e687bb          	addw	a5,a3,a4
    80003cc2:	0ed7e263          	bltu	a5,a3,80003da6 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003cc6:	00043737          	lui	a4,0x43
    80003cca:	0ef76063          	bltu	a4,a5,80003daa <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003cce:	0c0b8863          	beqz	s7,80003d9e <writei+0x10e>
    80003cd2:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cd4:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003cd8:	5cfd                	li	s9,-1
    80003cda:	a091                	j	80003d1e <writei+0x8e>
    80003cdc:	02099d93          	slli	s11,s3,0x20
    80003ce0:	020ddd93          	srli	s11,s11,0x20
    80003ce4:	05848513          	addi	a0,s1,88
    80003ce8:	86ee                	mv	a3,s11
    80003cea:	8656                	mv	a2,s5
    80003cec:	85e2                	mv	a1,s8
    80003cee:	953a                	add	a0,a0,a4
    80003cf0:	ffffe097          	auipc	ra,0xffffe
    80003cf4:	772080e7          	jalr	1906(ra) # 80002462 <either_copyin>
    80003cf8:	07950263          	beq	a0,s9,80003d5c <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003cfc:	8526                	mv	a0,s1
    80003cfe:	00000097          	auipc	ra,0x0
    80003d02:	798080e7          	jalr	1944(ra) # 80004496 <log_write>
    brelse(bp);
    80003d06:	8526                	mv	a0,s1
    80003d08:	fffff097          	auipc	ra,0xfffff
    80003d0c:	50a080e7          	jalr	1290(ra) # 80003212 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d10:	01498a3b          	addw	s4,s3,s4
    80003d14:	0129893b          	addw	s2,s3,s2
    80003d18:	9aee                	add	s5,s5,s11
    80003d1a:	057a7663          	bgeu	s4,s7,80003d66 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003d1e:	000b2483          	lw	s1,0(s6)
    80003d22:	00a9559b          	srliw	a1,s2,0xa
    80003d26:	855a                	mv	a0,s6
    80003d28:	fffff097          	auipc	ra,0xfffff
    80003d2c:	7aa080e7          	jalr	1962(ra) # 800034d2 <bmap>
    80003d30:	0005059b          	sext.w	a1,a0
    80003d34:	8526                	mv	a0,s1
    80003d36:	fffff097          	auipc	ra,0xfffff
    80003d3a:	3ac080e7          	jalr	940(ra) # 800030e2 <bread>
    80003d3e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d40:	3ff97713          	andi	a4,s2,1023
    80003d44:	40ed07bb          	subw	a5,s10,a4
    80003d48:	414b86bb          	subw	a3,s7,s4
    80003d4c:	89be                	mv	s3,a5
    80003d4e:	2781                	sext.w	a5,a5
    80003d50:	0006861b          	sext.w	a2,a3
    80003d54:	f8f674e3          	bgeu	a2,a5,80003cdc <writei+0x4c>
    80003d58:	89b6                	mv	s3,a3
    80003d5a:	b749                	j	80003cdc <writei+0x4c>
      brelse(bp);
    80003d5c:	8526                	mv	a0,s1
    80003d5e:	fffff097          	auipc	ra,0xfffff
    80003d62:	4b4080e7          	jalr	1204(ra) # 80003212 <brelse>
  }

  if(off > ip->size)
    80003d66:	04cb2783          	lw	a5,76(s6)
    80003d6a:	0127f463          	bgeu	a5,s2,80003d72 <writei+0xe2>
    ip->size = off;
    80003d6e:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003d72:	855a                	mv	a0,s6
    80003d74:	00000097          	auipc	ra,0x0
    80003d78:	aa4080e7          	jalr	-1372(ra) # 80003818 <iupdate>

  return tot;
    80003d7c:	000a051b          	sext.w	a0,s4
}
    80003d80:	70a6                	ld	ra,104(sp)
    80003d82:	7406                	ld	s0,96(sp)
    80003d84:	64e6                	ld	s1,88(sp)
    80003d86:	6946                	ld	s2,80(sp)
    80003d88:	69a6                	ld	s3,72(sp)
    80003d8a:	6a06                	ld	s4,64(sp)
    80003d8c:	7ae2                	ld	s5,56(sp)
    80003d8e:	7b42                	ld	s6,48(sp)
    80003d90:	7ba2                	ld	s7,40(sp)
    80003d92:	7c02                	ld	s8,32(sp)
    80003d94:	6ce2                	ld	s9,24(sp)
    80003d96:	6d42                	ld	s10,16(sp)
    80003d98:	6da2                	ld	s11,8(sp)
    80003d9a:	6165                	addi	sp,sp,112
    80003d9c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d9e:	8a5e                	mv	s4,s7
    80003da0:	bfc9                	j	80003d72 <writei+0xe2>
    return -1;
    80003da2:	557d                	li	a0,-1
}
    80003da4:	8082                	ret
    return -1;
    80003da6:	557d                	li	a0,-1
    80003da8:	bfe1                	j	80003d80 <writei+0xf0>
    return -1;
    80003daa:	557d                	li	a0,-1
    80003dac:	bfd1                	j	80003d80 <writei+0xf0>

0000000080003dae <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003dae:	1141                	addi	sp,sp,-16
    80003db0:	e406                	sd	ra,8(sp)
    80003db2:	e022                	sd	s0,0(sp)
    80003db4:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003db6:	4639                	li	a2,14
    80003db8:	ffffd097          	auipc	ra,0xffffd
    80003dbc:	fe4080e7          	jalr	-28(ra) # 80000d9c <strncmp>
}
    80003dc0:	60a2                	ld	ra,8(sp)
    80003dc2:	6402                	ld	s0,0(sp)
    80003dc4:	0141                	addi	sp,sp,16
    80003dc6:	8082                	ret

0000000080003dc8 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003dc8:	7139                	addi	sp,sp,-64
    80003dca:	fc06                	sd	ra,56(sp)
    80003dcc:	f822                	sd	s0,48(sp)
    80003dce:	f426                	sd	s1,40(sp)
    80003dd0:	f04a                	sd	s2,32(sp)
    80003dd2:	ec4e                	sd	s3,24(sp)
    80003dd4:	e852                	sd	s4,16(sp)
    80003dd6:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003dd8:	04451703          	lh	a4,68(a0)
    80003ddc:	4785                	li	a5,1
    80003dde:	00f71a63          	bne	a4,a5,80003df2 <dirlookup+0x2a>
    80003de2:	892a                	mv	s2,a0
    80003de4:	89ae                	mv	s3,a1
    80003de6:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003de8:	457c                	lw	a5,76(a0)
    80003dea:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003dec:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dee:	e79d                	bnez	a5,80003e1c <dirlookup+0x54>
    80003df0:	a8a5                	j	80003e68 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003df2:	00005517          	auipc	a0,0x5
    80003df6:	81650513          	addi	a0,a0,-2026 # 80008608 <syscalls+0x1c0>
    80003dfa:	ffffc097          	auipc	ra,0xffffc
    80003dfe:	740080e7          	jalr	1856(ra) # 8000053a <panic>
      panic("dirlookup read");
    80003e02:	00005517          	auipc	a0,0x5
    80003e06:	81e50513          	addi	a0,a0,-2018 # 80008620 <syscalls+0x1d8>
    80003e0a:	ffffc097          	auipc	ra,0xffffc
    80003e0e:	730080e7          	jalr	1840(ra) # 8000053a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e12:	24c1                	addiw	s1,s1,16
    80003e14:	04c92783          	lw	a5,76(s2)
    80003e18:	04f4f763          	bgeu	s1,a5,80003e66 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e1c:	4741                	li	a4,16
    80003e1e:	86a6                	mv	a3,s1
    80003e20:	fc040613          	addi	a2,s0,-64
    80003e24:	4581                	li	a1,0
    80003e26:	854a                	mv	a0,s2
    80003e28:	00000097          	auipc	ra,0x0
    80003e2c:	d70080e7          	jalr	-656(ra) # 80003b98 <readi>
    80003e30:	47c1                	li	a5,16
    80003e32:	fcf518e3          	bne	a0,a5,80003e02 <dirlookup+0x3a>
    if(de.inum == 0)
    80003e36:	fc045783          	lhu	a5,-64(s0)
    80003e3a:	dfe1                	beqz	a5,80003e12 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003e3c:	fc240593          	addi	a1,s0,-62
    80003e40:	854e                	mv	a0,s3
    80003e42:	00000097          	auipc	ra,0x0
    80003e46:	f6c080e7          	jalr	-148(ra) # 80003dae <namecmp>
    80003e4a:	f561                	bnez	a0,80003e12 <dirlookup+0x4a>
      if(poff)
    80003e4c:	000a0463          	beqz	s4,80003e54 <dirlookup+0x8c>
        *poff = off;
    80003e50:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003e54:	fc045583          	lhu	a1,-64(s0)
    80003e58:	00092503          	lw	a0,0(s2)
    80003e5c:	fffff097          	auipc	ra,0xfffff
    80003e60:	752080e7          	jalr	1874(ra) # 800035ae <iget>
    80003e64:	a011                	j	80003e68 <dirlookup+0xa0>
  return 0;
    80003e66:	4501                	li	a0,0
}
    80003e68:	70e2                	ld	ra,56(sp)
    80003e6a:	7442                	ld	s0,48(sp)
    80003e6c:	74a2                	ld	s1,40(sp)
    80003e6e:	7902                	ld	s2,32(sp)
    80003e70:	69e2                	ld	s3,24(sp)
    80003e72:	6a42                	ld	s4,16(sp)
    80003e74:	6121                	addi	sp,sp,64
    80003e76:	8082                	ret

0000000080003e78 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003e78:	711d                	addi	sp,sp,-96
    80003e7a:	ec86                	sd	ra,88(sp)
    80003e7c:	e8a2                	sd	s0,80(sp)
    80003e7e:	e4a6                	sd	s1,72(sp)
    80003e80:	e0ca                	sd	s2,64(sp)
    80003e82:	fc4e                	sd	s3,56(sp)
    80003e84:	f852                	sd	s4,48(sp)
    80003e86:	f456                	sd	s5,40(sp)
    80003e88:	f05a                	sd	s6,32(sp)
    80003e8a:	ec5e                	sd	s7,24(sp)
    80003e8c:	e862                	sd	s8,16(sp)
    80003e8e:	e466                	sd	s9,8(sp)
    80003e90:	e06a                	sd	s10,0(sp)
    80003e92:	1080                	addi	s0,sp,96
    80003e94:	84aa                	mv	s1,a0
    80003e96:	8b2e                	mv	s6,a1
    80003e98:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003e9a:	00054703          	lbu	a4,0(a0)
    80003e9e:	02f00793          	li	a5,47
    80003ea2:	02f70363          	beq	a4,a5,80003ec8 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003ea6:	ffffe097          	auipc	ra,0xffffe
    80003eaa:	af0080e7          	jalr	-1296(ra) # 80001996 <myproc>
    80003eae:	16053503          	ld	a0,352(a0)
    80003eb2:	00000097          	auipc	ra,0x0
    80003eb6:	9f4080e7          	jalr	-1548(ra) # 800038a6 <idup>
    80003eba:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003ebc:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003ec0:	4cb5                	li	s9,13
  len = path - s;
    80003ec2:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003ec4:	4c05                	li	s8,1
    80003ec6:	a87d                	j	80003f84 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80003ec8:	4585                	li	a1,1
    80003eca:	4505                	li	a0,1
    80003ecc:	fffff097          	auipc	ra,0xfffff
    80003ed0:	6e2080e7          	jalr	1762(ra) # 800035ae <iget>
    80003ed4:	8a2a                	mv	s4,a0
    80003ed6:	b7dd                	j	80003ebc <namex+0x44>
      iunlockput(ip);
    80003ed8:	8552                	mv	a0,s4
    80003eda:	00000097          	auipc	ra,0x0
    80003ede:	c6c080e7          	jalr	-916(ra) # 80003b46 <iunlockput>
      return 0;
    80003ee2:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003ee4:	8552                	mv	a0,s4
    80003ee6:	60e6                	ld	ra,88(sp)
    80003ee8:	6446                	ld	s0,80(sp)
    80003eea:	64a6                	ld	s1,72(sp)
    80003eec:	6906                	ld	s2,64(sp)
    80003eee:	79e2                	ld	s3,56(sp)
    80003ef0:	7a42                	ld	s4,48(sp)
    80003ef2:	7aa2                	ld	s5,40(sp)
    80003ef4:	7b02                	ld	s6,32(sp)
    80003ef6:	6be2                	ld	s7,24(sp)
    80003ef8:	6c42                	ld	s8,16(sp)
    80003efa:	6ca2                	ld	s9,8(sp)
    80003efc:	6d02                	ld	s10,0(sp)
    80003efe:	6125                	addi	sp,sp,96
    80003f00:	8082                	ret
      iunlock(ip);
    80003f02:	8552                	mv	a0,s4
    80003f04:	00000097          	auipc	ra,0x0
    80003f08:	aa2080e7          	jalr	-1374(ra) # 800039a6 <iunlock>
      return ip;
    80003f0c:	bfe1                	j	80003ee4 <namex+0x6c>
      iunlockput(ip);
    80003f0e:	8552                	mv	a0,s4
    80003f10:	00000097          	auipc	ra,0x0
    80003f14:	c36080e7          	jalr	-970(ra) # 80003b46 <iunlockput>
      return 0;
    80003f18:	8a4e                	mv	s4,s3
    80003f1a:	b7e9                	j	80003ee4 <namex+0x6c>
  len = path - s;
    80003f1c:	40998633          	sub	a2,s3,s1
    80003f20:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003f24:	09acd863          	bge	s9,s10,80003fb4 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80003f28:	4639                	li	a2,14
    80003f2a:	85a6                	mv	a1,s1
    80003f2c:	8556                	mv	a0,s5
    80003f2e:	ffffd097          	auipc	ra,0xffffd
    80003f32:	dfa080e7          	jalr	-518(ra) # 80000d28 <memmove>
    80003f36:	84ce                	mv	s1,s3
  while(*path == '/')
    80003f38:	0004c783          	lbu	a5,0(s1)
    80003f3c:	01279763          	bne	a5,s2,80003f4a <namex+0xd2>
    path++;
    80003f40:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f42:	0004c783          	lbu	a5,0(s1)
    80003f46:	ff278de3          	beq	a5,s2,80003f40 <namex+0xc8>
    ilock(ip);
    80003f4a:	8552                	mv	a0,s4
    80003f4c:	00000097          	auipc	ra,0x0
    80003f50:	998080e7          	jalr	-1640(ra) # 800038e4 <ilock>
    if(ip->type != T_DIR){
    80003f54:	044a1783          	lh	a5,68(s4)
    80003f58:	f98790e3          	bne	a5,s8,80003ed8 <namex+0x60>
    if(nameiparent && *path == '\0'){
    80003f5c:	000b0563          	beqz	s6,80003f66 <namex+0xee>
    80003f60:	0004c783          	lbu	a5,0(s1)
    80003f64:	dfd9                	beqz	a5,80003f02 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003f66:	865e                	mv	a2,s7
    80003f68:	85d6                	mv	a1,s5
    80003f6a:	8552                	mv	a0,s4
    80003f6c:	00000097          	auipc	ra,0x0
    80003f70:	e5c080e7          	jalr	-420(ra) # 80003dc8 <dirlookup>
    80003f74:	89aa                	mv	s3,a0
    80003f76:	dd41                	beqz	a0,80003f0e <namex+0x96>
    iunlockput(ip);
    80003f78:	8552                	mv	a0,s4
    80003f7a:	00000097          	auipc	ra,0x0
    80003f7e:	bcc080e7          	jalr	-1076(ra) # 80003b46 <iunlockput>
    ip = next;
    80003f82:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003f84:	0004c783          	lbu	a5,0(s1)
    80003f88:	01279763          	bne	a5,s2,80003f96 <namex+0x11e>
    path++;
    80003f8c:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f8e:	0004c783          	lbu	a5,0(s1)
    80003f92:	ff278de3          	beq	a5,s2,80003f8c <namex+0x114>
  if(*path == 0)
    80003f96:	cb9d                	beqz	a5,80003fcc <namex+0x154>
  while(*path != '/' && *path != 0)
    80003f98:	0004c783          	lbu	a5,0(s1)
    80003f9c:	89a6                	mv	s3,s1
  len = path - s;
    80003f9e:	8d5e                	mv	s10,s7
    80003fa0:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003fa2:	01278963          	beq	a5,s2,80003fb4 <namex+0x13c>
    80003fa6:	dbbd                	beqz	a5,80003f1c <namex+0xa4>
    path++;
    80003fa8:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003faa:	0009c783          	lbu	a5,0(s3)
    80003fae:	ff279ce3          	bne	a5,s2,80003fa6 <namex+0x12e>
    80003fb2:	b7ad                	j	80003f1c <namex+0xa4>
    memmove(name, s, len);
    80003fb4:	2601                	sext.w	a2,a2
    80003fb6:	85a6                	mv	a1,s1
    80003fb8:	8556                	mv	a0,s5
    80003fba:	ffffd097          	auipc	ra,0xffffd
    80003fbe:	d6e080e7          	jalr	-658(ra) # 80000d28 <memmove>
    name[len] = 0;
    80003fc2:	9d56                	add	s10,s10,s5
    80003fc4:	000d0023          	sb	zero,0(s10)
    80003fc8:	84ce                	mv	s1,s3
    80003fca:	b7bd                	j	80003f38 <namex+0xc0>
  if(nameiparent){
    80003fcc:	f00b0ce3          	beqz	s6,80003ee4 <namex+0x6c>
    iput(ip);
    80003fd0:	8552                	mv	a0,s4
    80003fd2:	00000097          	auipc	ra,0x0
    80003fd6:	acc080e7          	jalr	-1332(ra) # 80003a9e <iput>
    return 0;
    80003fda:	4a01                	li	s4,0
    80003fdc:	b721                	j	80003ee4 <namex+0x6c>

0000000080003fde <dirlink>:
{
    80003fde:	7139                	addi	sp,sp,-64
    80003fe0:	fc06                	sd	ra,56(sp)
    80003fe2:	f822                	sd	s0,48(sp)
    80003fe4:	f426                	sd	s1,40(sp)
    80003fe6:	f04a                	sd	s2,32(sp)
    80003fe8:	ec4e                	sd	s3,24(sp)
    80003fea:	e852                	sd	s4,16(sp)
    80003fec:	0080                	addi	s0,sp,64
    80003fee:	892a                	mv	s2,a0
    80003ff0:	8a2e                	mv	s4,a1
    80003ff2:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003ff4:	4601                	li	a2,0
    80003ff6:	00000097          	auipc	ra,0x0
    80003ffa:	dd2080e7          	jalr	-558(ra) # 80003dc8 <dirlookup>
    80003ffe:	e93d                	bnez	a0,80004074 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004000:	04c92483          	lw	s1,76(s2)
    80004004:	c49d                	beqz	s1,80004032 <dirlink+0x54>
    80004006:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004008:	4741                	li	a4,16
    8000400a:	86a6                	mv	a3,s1
    8000400c:	fc040613          	addi	a2,s0,-64
    80004010:	4581                	li	a1,0
    80004012:	854a                	mv	a0,s2
    80004014:	00000097          	auipc	ra,0x0
    80004018:	b84080e7          	jalr	-1148(ra) # 80003b98 <readi>
    8000401c:	47c1                	li	a5,16
    8000401e:	06f51163          	bne	a0,a5,80004080 <dirlink+0xa2>
    if(de.inum == 0)
    80004022:	fc045783          	lhu	a5,-64(s0)
    80004026:	c791                	beqz	a5,80004032 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004028:	24c1                	addiw	s1,s1,16
    8000402a:	04c92783          	lw	a5,76(s2)
    8000402e:	fcf4ede3          	bltu	s1,a5,80004008 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004032:	4639                	li	a2,14
    80004034:	85d2                	mv	a1,s4
    80004036:	fc240513          	addi	a0,s0,-62
    8000403a:	ffffd097          	auipc	ra,0xffffd
    8000403e:	d9e080e7          	jalr	-610(ra) # 80000dd8 <strncpy>
  de.inum = inum;
    80004042:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004046:	4741                	li	a4,16
    80004048:	86a6                	mv	a3,s1
    8000404a:	fc040613          	addi	a2,s0,-64
    8000404e:	4581                	li	a1,0
    80004050:	854a                	mv	a0,s2
    80004052:	00000097          	auipc	ra,0x0
    80004056:	c3e080e7          	jalr	-962(ra) # 80003c90 <writei>
    8000405a:	872a                	mv	a4,a0
    8000405c:	47c1                	li	a5,16
  return 0;
    8000405e:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004060:	02f71863          	bne	a4,a5,80004090 <dirlink+0xb2>
}
    80004064:	70e2                	ld	ra,56(sp)
    80004066:	7442                	ld	s0,48(sp)
    80004068:	74a2                	ld	s1,40(sp)
    8000406a:	7902                	ld	s2,32(sp)
    8000406c:	69e2                	ld	s3,24(sp)
    8000406e:	6a42                	ld	s4,16(sp)
    80004070:	6121                	addi	sp,sp,64
    80004072:	8082                	ret
    iput(ip);
    80004074:	00000097          	auipc	ra,0x0
    80004078:	a2a080e7          	jalr	-1494(ra) # 80003a9e <iput>
    return -1;
    8000407c:	557d                	li	a0,-1
    8000407e:	b7dd                	j	80004064 <dirlink+0x86>
      panic("dirlink read");
    80004080:	00004517          	auipc	a0,0x4
    80004084:	5b050513          	addi	a0,a0,1456 # 80008630 <syscalls+0x1e8>
    80004088:	ffffc097          	auipc	ra,0xffffc
    8000408c:	4b2080e7          	jalr	1202(ra) # 8000053a <panic>
    panic("dirlink");
    80004090:	00004517          	auipc	a0,0x4
    80004094:	6b050513          	addi	a0,a0,1712 # 80008740 <syscalls+0x2f8>
    80004098:	ffffc097          	auipc	ra,0xffffc
    8000409c:	4a2080e7          	jalr	1186(ra) # 8000053a <panic>

00000000800040a0 <namei>:

struct inode*
namei(char *path)
{
    800040a0:	1101                	addi	sp,sp,-32
    800040a2:	ec06                	sd	ra,24(sp)
    800040a4:	e822                	sd	s0,16(sp)
    800040a6:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800040a8:	fe040613          	addi	a2,s0,-32
    800040ac:	4581                	li	a1,0
    800040ae:	00000097          	auipc	ra,0x0
    800040b2:	dca080e7          	jalr	-566(ra) # 80003e78 <namex>
}
    800040b6:	60e2                	ld	ra,24(sp)
    800040b8:	6442                	ld	s0,16(sp)
    800040ba:	6105                	addi	sp,sp,32
    800040bc:	8082                	ret

00000000800040be <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800040be:	1141                	addi	sp,sp,-16
    800040c0:	e406                	sd	ra,8(sp)
    800040c2:	e022                	sd	s0,0(sp)
    800040c4:	0800                	addi	s0,sp,16
    800040c6:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800040c8:	4585                	li	a1,1
    800040ca:	00000097          	auipc	ra,0x0
    800040ce:	dae080e7          	jalr	-594(ra) # 80003e78 <namex>
}
    800040d2:	60a2                	ld	ra,8(sp)
    800040d4:	6402                	ld	s0,0(sp)
    800040d6:	0141                	addi	sp,sp,16
    800040d8:	8082                	ret

00000000800040da <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800040da:	1101                	addi	sp,sp,-32
    800040dc:	ec06                	sd	ra,24(sp)
    800040de:	e822                	sd	s0,16(sp)
    800040e0:	e426                	sd	s1,8(sp)
    800040e2:	e04a                	sd	s2,0(sp)
    800040e4:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800040e6:	0001d917          	auipc	s2,0x1d
    800040ea:	58a90913          	addi	s2,s2,1418 # 80021670 <log>
    800040ee:	01892583          	lw	a1,24(s2)
    800040f2:	02892503          	lw	a0,40(s2)
    800040f6:	fffff097          	auipc	ra,0xfffff
    800040fa:	fec080e7          	jalr	-20(ra) # 800030e2 <bread>
    800040fe:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004100:	02c92683          	lw	a3,44(s2)
    80004104:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004106:	02d05863          	blez	a3,80004136 <write_head+0x5c>
    8000410a:	0001d797          	auipc	a5,0x1d
    8000410e:	59678793          	addi	a5,a5,1430 # 800216a0 <log+0x30>
    80004112:	05c50713          	addi	a4,a0,92
    80004116:	36fd                	addiw	a3,a3,-1
    80004118:	02069613          	slli	a2,a3,0x20
    8000411c:	01e65693          	srli	a3,a2,0x1e
    80004120:	0001d617          	auipc	a2,0x1d
    80004124:	58460613          	addi	a2,a2,1412 # 800216a4 <log+0x34>
    80004128:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    8000412a:	4390                	lw	a2,0(a5)
    8000412c:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000412e:	0791                	addi	a5,a5,4
    80004130:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80004132:	fed79ce3          	bne	a5,a3,8000412a <write_head+0x50>
  }
  bwrite(buf);
    80004136:	8526                	mv	a0,s1
    80004138:	fffff097          	auipc	ra,0xfffff
    8000413c:	09c080e7          	jalr	156(ra) # 800031d4 <bwrite>
  brelse(buf);
    80004140:	8526                	mv	a0,s1
    80004142:	fffff097          	auipc	ra,0xfffff
    80004146:	0d0080e7          	jalr	208(ra) # 80003212 <brelse>
}
    8000414a:	60e2                	ld	ra,24(sp)
    8000414c:	6442                	ld	s0,16(sp)
    8000414e:	64a2                	ld	s1,8(sp)
    80004150:	6902                	ld	s2,0(sp)
    80004152:	6105                	addi	sp,sp,32
    80004154:	8082                	ret

0000000080004156 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004156:	0001d797          	auipc	a5,0x1d
    8000415a:	5467a783          	lw	a5,1350(a5) # 8002169c <log+0x2c>
    8000415e:	0af05d63          	blez	a5,80004218 <install_trans+0xc2>
{
    80004162:	7139                	addi	sp,sp,-64
    80004164:	fc06                	sd	ra,56(sp)
    80004166:	f822                	sd	s0,48(sp)
    80004168:	f426                	sd	s1,40(sp)
    8000416a:	f04a                	sd	s2,32(sp)
    8000416c:	ec4e                	sd	s3,24(sp)
    8000416e:	e852                	sd	s4,16(sp)
    80004170:	e456                	sd	s5,8(sp)
    80004172:	e05a                	sd	s6,0(sp)
    80004174:	0080                	addi	s0,sp,64
    80004176:	8b2a                	mv	s6,a0
    80004178:	0001da97          	auipc	s5,0x1d
    8000417c:	528a8a93          	addi	s5,s5,1320 # 800216a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004180:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004182:	0001d997          	auipc	s3,0x1d
    80004186:	4ee98993          	addi	s3,s3,1262 # 80021670 <log>
    8000418a:	a00d                	j	800041ac <install_trans+0x56>
    brelse(lbuf);
    8000418c:	854a                	mv	a0,s2
    8000418e:	fffff097          	auipc	ra,0xfffff
    80004192:	084080e7          	jalr	132(ra) # 80003212 <brelse>
    brelse(dbuf);
    80004196:	8526                	mv	a0,s1
    80004198:	fffff097          	auipc	ra,0xfffff
    8000419c:	07a080e7          	jalr	122(ra) # 80003212 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041a0:	2a05                	addiw	s4,s4,1
    800041a2:	0a91                	addi	s5,s5,4
    800041a4:	02c9a783          	lw	a5,44(s3)
    800041a8:	04fa5e63          	bge	s4,a5,80004204 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800041ac:	0189a583          	lw	a1,24(s3)
    800041b0:	014585bb          	addw	a1,a1,s4
    800041b4:	2585                	addiw	a1,a1,1
    800041b6:	0289a503          	lw	a0,40(s3)
    800041ba:	fffff097          	auipc	ra,0xfffff
    800041be:	f28080e7          	jalr	-216(ra) # 800030e2 <bread>
    800041c2:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800041c4:	000aa583          	lw	a1,0(s5)
    800041c8:	0289a503          	lw	a0,40(s3)
    800041cc:	fffff097          	auipc	ra,0xfffff
    800041d0:	f16080e7          	jalr	-234(ra) # 800030e2 <bread>
    800041d4:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800041d6:	40000613          	li	a2,1024
    800041da:	05890593          	addi	a1,s2,88
    800041de:	05850513          	addi	a0,a0,88
    800041e2:	ffffd097          	auipc	ra,0xffffd
    800041e6:	b46080e7          	jalr	-1210(ra) # 80000d28 <memmove>
    bwrite(dbuf);  // write dst to disk
    800041ea:	8526                	mv	a0,s1
    800041ec:	fffff097          	auipc	ra,0xfffff
    800041f0:	fe8080e7          	jalr	-24(ra) # 800031d4 <bwrite>
    if(recovering == 0)
    800041f4:	f80b1ce3          	bnez	s6,8000418c <install_trans+0x36>
      bunpin(dbuf);
    800041f8:	8526                	mv	a0,s1
    800041fa:	fffff097          	auipc	ra,0xfffff
    800041fe:	0f2080e7          	jalr	242(ra) # 800032ec <bunpin>
    80004202:	b769                	j	8000418c <install_trans+0x36>
}
    80004204:	70e2                	ld	ra,56(sp)
    80004206:	7442                	ld	s0,48(sp)
    80004208:	74a2                	ld	s1,40(sp)
    8000420a:	7902                	ld	s2,32(sp)
    8000420c:	69e2                	ld	s3,24(sp)
    8000420e:	6a42                	ld	s4,16(sp)
    80004210:	6aa2                	ld	s5,8(sp)
    80004212:	6b02                	ld	s6,0(sp)
    80004214:	6121                	addi	sp,sp,64
    80004216:	8082                	ret
    80004218:	8082                	ret

000000008000421a <initlog>:
{
    8000421a:	7179                	addi	sp,sp,-48
    8000421c:	f406                	sd	ra,40(sp)
    8000421e:	f022                	sd	s0,32(sp)
    80004220:	ec26                	sd	s1,24(sp)
    80004222:	e84a                	sd	s2,16(sp)
    80004224:	e44e                	sd	s3,8(sp)
    80004226:	1800                	addi	s0,sp,48
    80004228:	892a                	mv	s2,a0
    8000422a:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000422c:	0001d497          	auipc	s1,0x1d
    80004230:	44448493          	addi	s1,s1,1092 # 80021670 <log>
    80004234:	00004597          	auipc	a1,0x4
    80004238:	40c58593          	addi	a1,a1,1036 # 80008640 <syscalls+0x1f8>
    8000423c:	8526                	mv	a0,s1
    8000423e:	ffffd097          	auipc	ra,0xffffd
    80004242:	902080e7          	jalr	-1790(ra) # 80000b40 <initlock>
  log.start = sb->logstart;
    80004246:	0149a583          	lw	a1,20(s3)
    8000424a:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000424c:	0109a783          	lw	a5,16(s3)
    80004250:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004252:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004256:	854a                	mv	a0,s2
    80004258:	fffff097          	auipc	ra,0xfffff
    8000425c:	e8a080e7          	jalr	-374(ra) # 800030e2 <bread>
  log.lh.n = lh->n;
    80004260:	4d34                	lw	a3,88(a0)
    80004262:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004264:	02d05663          	blez	a3,80004290 <initlog+0x76>
    80004268:	05c50793          	addi	a5,a0,92
    8000426c:	0001d717          	auipc	a4,0x1d
    80004270:	43470713          	addi	a4,a4,1076 # 800216a0 <log+0x30>
    80004274:	36fd                	addiw	a3,a3,-1
    80004276:	02069613          	slli	a2,a3,0x20
    8000427a:	01e65693          	srli	a3,a2,0x1e
    8000427e:	06050613          	addi	a2,a0,96
    80004282:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004284:	4390                	lw	a2,0(a5)
    80004286:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004288:	0791                	addi	a5,a5,4
    8000428a:	0711                	addi	a4,a4,4
    8000428c:	fed79ce3          	bne	a5,a3,80004284 <initlog+0x6a>
  brelse(buf);
    80004290:	fffff097          	auipc	ra,0xfffff
    80004294:	f82080e7          	jalr	-126(ra) # 80003212 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004298:	4505                	li	a0,1
    8000429a:	00000097          	auipc	ra,0x0
    8000429e:	ebc080e7          	jalr	-324(ra) # 80004156 <install_trans>
  log.lh.n = 0;
    800042a2:	0001d797          	auipc	a5,0x1d
    800042a6:	3e07ad23          	sw	zero,1018(a5) # 8002169c <log+0x2c>
  write_head(); // clear the log
    800042aa:	00000097          	auipc	ra,0x0
    800042ae:	e30080e7          	jalr	-464(ra) # 800040da <write_head>
}
    800042b2:	70a2                	ld	ra,40(sp)
    800042b4:	7402                	ld	s0,32(sp)
    800042b6:	64e2                	ld	s1,24(sp)
    800042b8:	6942                	ld	s2,16(sp)
    800042ba:	69a2                	ld	s3,8(sp)
    800042bc:	6145                	addi	sp,sp,48
    800042be:	8082                	ret

00000000800042c0 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800042c0:	1101                	addi	sp,sp,-32
    800042c2:	ec06                	sd	ra,24(sp)
    800042c4:	e822                	sd	s0,16(sp)
    800042c6:	e426                	sd	s1,8(sp)
    800042c8:	e04a                	sd	s2,0(sp)
    800042ca:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800042cc:	0001d517          	auipc	a0,0x1d
    800042d0:	3a450513          	addi	a0,a0,932 # 80021670 <log>
    800042d4:	ffffd097          	auipc	ra,0xffffd
    800042d8:	8fc080e7          	jalr	-1796(ra) # 80000bd0 <acquire>
  while(1){
    if(log.committing){
    800042dc:	0001d497          	auipc	s1,0x1d
    800042e0:	39448493          	addi	s1,s1,916 # 80021670 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800042e4:	4979                	li	s2,30
    800042e6:	a039                	j	800042f4 <begin_op+0x34>
      sleep(&log, &log.lock);
    800042e8:	85a6                	mv	a1,s1
    800042ea:	8526                	mv	a0,s1
    800042ec:	ffffe097          	auipc	ra,0xffffe
    800042f0:	d72080e7          	jalr	-654(ra) # 8000205e <sleep>
    if(log.committing){
    800042f4:	50dc                	lw	a5,36(s1)
    800042f6:	fbed                	bnez	a5,800042e8 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800042f8:	5098                	lw	a4,32(s1)
    800042fa:	2705                	addiw	a4,a4,1
    800042fc:	0007069b          	sext.w	a3,a4
    80004300:	0027179b          	slliw	a5,a4,0x2
    80004304:	9fb9                	addw	a5,a5,a4
    80004306:	0017979b          	slliw	a5,a5,0x1
    8000430a:	54d8                	lw	a4,44(s1)
    8000430c:	9fb9                	addw	a5,a5,a4
    8000430e:	00f95963          	bge	s2,a5,80004320 <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004312:	85a6                	mv	a1,s1
    80004314:	8526                	mv	a0,s1
    80004316:	ffffe097          	auipc	ra,0xffffe
    8000431a:	d48080e7          	jalr	-696(ra) # 8000205e <sleep>
    8000431e:	bfd9                	j	800042f4 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004320:	0001d517          	auipc	a0,0x1d
    80004324:	35050513          	addi	a0,a0,848 # 80021670 <log>
    80004328:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000432a:	ffffd097          	auipc	ra,0xffffd
    8000432e:	95a080e7          	jalr	-1702(ra) # 80000c84 <release>
      break;
    }
  }
}
    80004332:	60e2                	ld	ra,24(sp)
    80004334:	6442                	ld	s0,16(sp)
    80004336:	64a2                	ld	s1,8(sp)
    80004338:	6902                	ld	s2,0(sp)
    8000433a:	6105                	addi	sp,sp,32
    8000433c:	8082                	ret

000000008000433e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000433e:	7139                	addi	sp,sp,-64
    80004340:	fc06                	sd	ra,56(sp)
    80004342:	f822                	sd	s0,48(sp)
    80004344:	f426                	sd	s1,40(sp)
    80004346:	f04a                	sd	s2,32(sp)
    80004348:	ec4e                	sd	s3,24(sp)
    8000434a:	e852                	sd	s4,16(sp)
    8000434c:	e456                	sd	s5,8(sp)
    8000434e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004350:	0001d497          	auipc	s1,0x1d
    80004354:	32048493          	addi	s1,s1,800 # 80021670 <log>
    80004358:	8526                	mv	a0,s1
    8000435a:	ffffd097          	auipc	ra,0xffffd
    8000435e:	876080e7          	jalr	-1930(ra) # 80000bd0 <acquire>
  log.outstanding -= 1;
    80004362:	509c                	lw	a5,32(s1)
    80004364:	37fd                	addiw	a5,a5,-1
    80004366:	0007891b          	sext.w	s2,a5
    8000436a:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000436c:	50dc                	lw	a5,36(s1)
    8000436e:	e7b9                	bnez	a5,800043bc <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004370:	04091e63          	bnez	s2,800043cc <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004374:	0001d497          	auipc	s1,0x1d
    80004378:	2fc48493          	addi	s1,s1,764 # 80021670 <log>
    8000437c:	4785                	li	a5,1
    8000437e:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004380:	8526                	mv	a0,s1
    80004382:	ffffd097          	auipc	ra,0xffffd
    80004386:	902080e7          	jalr	-1790(ra) # 80000c84 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000438a:	54dc                	lw	a5,44(s1)
    8000438c:	06f04763          	bgtz	a5,800043fa <end_op+0xbc>
    acquire(&log.lock);
    80004390:	0001d497          	auipc	s1,0x1d
    80004394:	2e048493          	addi	s1,s1,736 # 80021670 <log>
    80004398:	8526                	mv	a0,s1
    8000439a:	ffffd097          	auipc	ra,0xffffd
    8000439e:	836080e7          	jalr	-1994(ra) # 80000bd0 <acquire>
    log.committing = 0;
    800043a2:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800043a6:	8526                	mv	a0,s1
    800043a8:	ffffe097          	auipc	ra,0xffffe
    800043ac:	e42080e7          	jalr	-446(ra) # 800021ea <wakeup>
    release(&log.lock);
    800043b0:	8526                	mv	a0,s1
    800043b2:	ffffd097          	auipc	ra,0xffffd
    800043b6:	8d2080e7          	jalr	-1838(ra) # 80000c84 <release>
}
    800043ba:	a03d                	j	800043e8 <end_op+0xaa>
    panic("log.committing");
    800043bc:	00004517          	auipc	a0,0x4
    800043c0:	28c50513          	addi	a0,a0,652 # 80008648 <syscalls+0x200>
    800043c4:	ffffc097          	auipc	ra,0xffffc
    800043c8:	176080e7          	jalr	374(ra) # 8000053a <panic>
    wakeup(&log);
    800043cc:	0001d497          	auipc	s1,0x1d
    800043d0:	2a448493          	addi	s1,s1,676 # 80021670 <log>
    800043d4:	8526                	mv	a0,s1
    800043d6:	ffffe097          	auipc	ra,0xffffe
    800043da:	e14080e7          	jalr	-492(ra) # 800021ea <wakeup>
  release(&log.lock);
    800043de:	8526                	mv	a0,s1
    800043e0:	ffffd097          	auipc	ra,0xffffd
    800043e4:	8a4080e7          	jalr	-1884(ra) # 80000c84 <release>
}
    800043e8:	70e2                	ld	ra,56(sp)
    800043ea:	7442                	ld	s0,48(sp)
    800043ec:	74a2                	ld	s1,40(sp)
    800043ee:	7902                	ld	s2,32(sp)
    800043f0:	69e2                	ld	s3,24(sp)
    800043f2:	6a42                	ld	s4,16(sp)
    800043f4:	6aa2                	ld	s5,8(sp)
    800043f6:	6121                	addi	sp,sp,64
    800043f8:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800043fa:	0001da97          	auipc	s5,0x1d
    800043fe:	2a6a8a93          	addi	s5,s5,678 # 800216a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004402:	0001da17          	auipc	s4,0x1d
    80004406:	26ea0a13          	addi	s4,s4,622 # 80021670 <log>
    8000440a:	018a2583          	lw	a1,24(s4)
    8000440e:	012585bb          	addw	a1,a1,s2
    80004412:	2585                	addiw	a1,a1,1
    80004414:	028a2503          	lw	a0,40(s4)
    80004418:	fffff097          	auipc	ra,0xfffff
    8000441c:	cca080e7          	jalr	-822(ra) # 800030e2 <bread>
    80004420:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004422:	000aa583          	lw	a1,0(s5)
    80004426:	028a2503          	lw	a0,40(s4)
    8000442a:	fffff097          	auipc	ra,0xfffff
    8000442e:	cb8080e7          	jalr	-840(ra) # 800030e2 <bread>
    80004432:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004434:	40000613          	li	a2,1024
    80004438:	05850593          	addi	a1,a0,88
    8000443c:	05848513          	addi	a0,s1,88
    80004440:	ffffd097          	auipc	ra,0xffffd
    80004444:	8e8080e7          	jalr	-1816(ra) # 80000d28 <memmove>
    bwrite(to);  // write the log
    80004448:	8526                	mv	a0,s1
    8000444a:	fffff097          	auipc	ra,0xfffff
    8000444e:	d8a080e7          	jalr	-630(ra) # 800031d4 <bwrite>
    brelse(from);
    80004452:	854e                	mv	a0,s3
    80004454:	fffff097          	auipc	ra,0xfffff
    80004458:	dbe080e7          	jalr	-578(ra) # 80003212 <brelse>
    brelse(to);
    8000445c:	8526                	mv	a0,s1
    8000445e:	fffff097          	auipc	ra,0xfffff
    80004462:	db4080e7          	jalr	-588(ra) # 80003212 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004466:	2905                	addiw	s2,s2,1
    80004468:	0a91                	addi	s5,s5,4
    8000446a:	02ca2783          	lw	a5,44(s4)
    8000446e:	f8f94ee3          	blt	s2,a5,8000440a <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004472:	00000097          	auipc	ra,0x0
    80004476:	c68080e7          	jalr	-920(ra) # 800040da <write_head>
    install_trans(0); // Now install writes to home locations
    8000447a:	4501                	li	a0,0
    8000447c:	00000097          	auipc	ra,0x0
    80004480:	cda080e7          	jalr	-806(ra) # 80004156 <install_trans>
    log.lh.n = 0;
    80004484:	0001d797          	auipc	a5,0x1d
    80004488:	2007ac23          	sw	zero,536(a5) # 8002169c <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000448c:	00000097          	auipc	ra,0x0
    80004490:	c4e080e7          	jalr	-946(ra) # 800040da <write_head>
    80004494:	bdf5                	j	80004390 <end_op+0x52>

0000000080004496 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004496:	1101                	addi	sp,sp,-32
    80004498:	ec06                	sd	ra,24(sp)
    8000449a:	e822                	sd	s0,16(sp)
    8000449c:	e426                	sd	s1,8(sp)
    8000449e:	e04a                	sd	s2,0(sp)
    800044a0:	1000                	addi	s0,sp,32
    800044a2:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800044a4:	0001d917          	auipc	s2,0x1d
    800044a8:	1cc90913          	addi	s2,s2,460 # 80021670 <log>
    800044ac:	854a                	mv	a0,s2
    800044ae:	ffffc097          	auipc	ra,0xffffc
    800044b2:	722080e7          	jalr	1826(ra) # 80000bd0 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800044b6:	02c92603          	lw	a2,44(s2)
    800044ba:	47f5                	li	a5,29
    800044bc:	06c7c563          	blt	a5,a2,80004526 <log_write+0x90>
    800044c0:	0001d797          	auipc	a5,0x1d
    800044c4:	1cc7a783          	lw	a5,460(a5) # 8002168c <log+0x1c>
    800044c8:	37fd                	addiw	a5,a5,-1
    800044ca:	04f65e63          	bge	a2,a5,80004526 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800044ce:	0001d797          	auipc	a5,0x1d
    800044d2:	1c27a783          	lw	a5,450(a5) # 80021690 <log+0x20>
    800044d6:	06f05063          	blez	a5,80004536 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800044da:	4781                	li	a5,0
    800044dc:	06c05563          	blez	a2,80004546 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800044e0:	44cc                	lw	a1,12(s1)
    800044e2:	0001d717          	auipc	a4,0x1d
    800044e6:	1be70713          	addi	a4,a4,446 # 800216a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800044ea:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800044ec:	4314                	lw	a3,0(a4)
    800044ee:	04b68c63          	beq	a3,a1,80004546 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800044f2:	2785                	addiw	a5,a5,1
    800044f4:	0711                	addi	a4,a4,4
    800044f6:	fef61be3          	bne	a2,a5,800044ec <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800044fa:	0621                	addi	a2,a2,8
    800044fc:	060a                	slli	a2,a2,0x2
    800044fe:	0001d797          	auipc	a5,0x1d
    80004502:	17278793          	addi	a5,a5,370 # 80021670 <log>
    80004506:	97b2                	add	a5,a5,a2
    80004508:	44d8                	lw	a4,12(s1)
    8000450a:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000450c:	8526                	mv	a0,s1
    8000450e:	fffff097          	auipc	ra,0xfffff
    80004512:	da2080e7          	jalr	-606(ra) # 800032b0 <bpin>
    log.lh.n++;
    80004516:	0001d717          	auipc	a4,0x1d
    8000451a:	15a70713          	addi	a4,a4,346 # 80021670 <log>
    8000451e:	575c                	lw	a5,44(a4)
    80004520:	2785                	addiw	a5,a5,1
    80004522:	d75c                	sw	a5,44(a4)
    80004524:	a82d                	j	8000455e <log_write+0xc8>
    panic("too big a transaction");
    80004526:	00004517          	auipc	a0,0x4
    8000452a:	13250513          	addi	a0,a0,306 # 80008658 <syscalls+0x210>
    8000452e:	ffffc097          	auipc	ra,0xffffc
    80004532:	00c080e7          	jalr	12(ra) # 8000053a <panic>
    panic("log_write outside of trans");
    80004536:	00004517          	auipc	a0,0x4
    8000453a:	13a50513          	addi	a0,a0,314 # 80008670 <syscalls+0x228>
    8000453e:	ffffc097          	auipc	ra,0xffffc
    80004542:	ffc080e7          	jalr	-4(ra) # 8000053a <panic>
  log.lh.block[i] = b->blockno;
    80004546:	00878693          	addi	a3,a5,8
    8000454a:	068a                	slli	a3,a3,0x2
    8000454c:	0001d717          	auipc	a4,0x1d
    80004550:	12470713          	addi	a4,a4,292 # 80021670 <log>
    80004554:	9736                	add	a4,a4,a3
    80004556:	44d4                	lw	a3,12(s1)
    80004558:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000455a:	faf609e3          	beq	a2,a5,8000450c <log_write+0x76>
  }
  release(&log.lock);
    8000455e:	0001d517          	auipc	a0,0x1d
    80004562:	11250513          	addi	a0,a0,274 # 80021670 <log>
    80004566:	ffffc097          	auipc	ra,0xffffc
    8000456a:	71e080e7          	jalr	1822(ra) # 80000c84 <release>
}
    8000456e:	60e2                	ld	ra,24(sp)
    80004570:	6442                	ld	s0,16(sp)
    80004572:	64a2                	ld	s1,8(sp)
    80004574:	6902                	ld	s2,0(sp)
    80004576:	6105                	addi	sp,sp,32
    80004578:	8082                	ret

000000008000457a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000457a:	1101                	addi	sp,sp,-32
    8000457c:	ec06                	sd	ra,24(sp)
    8000457e:	e822                	sd	s0,16(sp)
    80004580:	e426                	sd	s1,8(sp)
    80004582:	e04a                	sd	s2,0(sp)
    80004584:	1000                	addi	s0,sp,32
    80004586:	84aa                	mv	s1,a0
    80004588:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000458a:	00004597          	auipc	a1,0x4
    8000458e:	10658593          	addi	a1,a1,262 # 80008690 <syscalls+0x248>
    80004592:	0521                	addi	a0,a0,8
    80004594:	ffffc097          	auipc	ra,0xffffc
    80004598:	5ac080e7          	jalr	1452(ra) # 80000b40 <initlock>
  lk->name = name;
    8000459c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800045a0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800045a4:	0204a423          	sw	zero,40(s1)
}
    800045a8:	60e2                	ld	ra,24(sp)
    800045aa:	6442                	ld	s0,16(sp)
    800045ac:	64a2                	ld	s1,8(sp)
    800045ae:	6902                	ld	s2,0(sp)
    800045b0:	6105                	addi	sp,sp,32
    800045b2:	8082                	ret

00000000800045b4 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800045b4:	1101                	addi	sp,sp,-32
    800045b6:	ec06                	sd	ra,24(sp)
    800045b8:	e822                	sd	s0,16(sp)
    800045ba:	e426                	sd	s1,8(sp)
    800045bc:	e04a                	sd	s2,0(sp)
    800045be:	1000                	addi	s0,sp,32
    800045c0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800045c2:	00850913          	addi	s2,a0,8
    800045c6:	854a                	mv	a0,s2
    800045c8:	ffffc097          	auipc	ra,0xffffc
    800045cc:	608080e7          	jalr	1544(ra) # 80000bd0 <acquire>
  while (lk->locked) {
    800045d0:	409c                	lw	a5,0(s1)
    800045d2:	cb89                	beqz	a5,800045e4 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800045d4:	85ca                	mv	a1,s2
    800045d6:	8526                	mv	a0,s1
    800045d8:	ffffe097          	auipc	ra,0xffffe
    800045dc:	a86080e7          	jalr	-1402(ra) # 8000205e <sleep>
  while (lk->locked) {
    800045e0:	409c                	lw	a5,0(s1)
    800045e2:	fbed                	bnez	a5,800045d4 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800045e4:	4785                	li	a5,1
    800045e6:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800045e8:	ffffd097          	auipc	ra,0xffffd
    800045ec:	3ae080e7          	jalr	942(ra) # 80001996 <myproc>
    800045f0:	591c                	lw	a5,48(a0)
    800045f2:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800045f4:	854a                	mv	a0,s2
    800045f6:	ffffc097          	auipc	ra,0xffffc
    800045fa:	68e080e7          	jalr	1678(ra) # 80000c84 <release>
}
    800045fe:	60e2                	ld	ra,24(sp)
    80004600:	6442                	ld	s0,16(sp)
    80004602:	64a2                	ld	s1,8(sp)
    80004604:	6902                	ld	s2,0(sp)
    80004606:	6105                	addi	sp,sp,32
    80004608:	8082                	ret

000000008000460a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000460a:	1101                	addi	sp,sp,-32
    8000460c:	ec06                	sd	ra,24(sp)
    8000460e:	e822                	sd	s0,16(sp)
    80004610:	e426                	sd	s1,8(sp)
    80004612:	e04a                	sd	s2,0(sp)
    80004614:	1000                	addi	s0,sp,32
    80004616:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004618:	00850913          	addi	s2,a0,8
    8000461c:	854a                	mv	a0,s2
    8000461e:	ffffc097          	auipc	ra,0xffffc
    80004622:	5b2080e7          	jalr	1458(ra) # 80000bd0 <acquire>
  lk->locked = 0;
    80004626:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000462a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000462e:	8526                	mv	a0,s1
    80004630:	ffffe097          	auipc	ra,0xffffe
    80004634:	bba080e7          	jalr	-1094(ra) # 800021ea <wakeup>
  release(&lk->lk);
    80004638:	854a                	mv	a0,s2
    8000463a:	ffffc097          	auipc	ra,0xffffc
    8000463e:	64a080e7          	jalr	1610(ra) # 80000c84 <release>
}
    80004642:	60e2                	ld	ra,24(sp)
    80004644:	6442                	ld	s0,16(sp)
    80004646:	64a2                	ld	s1,8(sp)
    80004648:	6902                	ld	s2,0(sp)
    8000464a:	6105                	addi	sp,sp,32
    8000464c:	8082                	ret

000000008000464e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000464e:	7179                	addi	sp,sp,-48
    80004650:	f406                	sd	ra,40(sp)
    80004652:	f022                	sd	s0,32(sp)
    80004654:	ec26                	sd	s1,24(sp)
    80004656:	e84a                	sd	s2,16(sp)
    80004658:	e44e                	sd	s3,8(sp)
    8000465a:	1800                	addi	s0,sp,48
    8000465c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000465e:	00850913          	addi	s2,a0,8
    80004662:	854a                	mv	a0,s2
    80004664:	ffffc097          	auipc	ra,0xffffc
    80004668:	56c080e7          	jalr	1388(ra) # 80000bd0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000466c:	409c                	lw	a5,0(s1)
    8000466e:	ef99                	bnez	a5,8000468c <holdingsleep+0x3e>
    80004670:	4481                	li	s1,0
  release(&lk->lk);
    80004672:	854a                	mv	a0,s2
    80004674:	ffffc097          	auipc	ra,0xffffc
    80004678:	610080e7          	jalr	1552(ra) # 80000c84 <release>
  return r;
}
    8000467c:	8526                	mv	a0,s1
    8000467e:	70a2                	ld	ra,40(sp)
    80004680:	7402                	ld	s0,32(sp)
    80004682:	64e2                	ld	s1,24(sp)
    80004684:	6942                	ld	s2,16(sp)
    80004686:	69a2                	ld	s3,8(sp)
    80004688:	6145                	addi	sp,sp,48
    8000468a:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000468c:	0284a983          	lw	s3,40(s1)
    80004690:	ffffd097          	auipc	ra,0xffffd
    80004694:	306080e7          	jalr	774(ra) # 80001996 <myproc>
    80004698:	5904                	lw	s1,48(a0)
    8000469a:	413484b3          	sub	s1,s1,s3
    8000469e:	0014b493          	seqz	s1,s1
    800046a2:	bfc1                	j	80004672 <holdingsleep+0x24>

00000000800046a4 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800046a4:	1141                	addi	sp,sp,-16
    800046a6:	e406                	sd	ra,8(sp)
    800046a8:	e022                	sd	s0,0(sp)
    800046aa:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800046ac:	00004597          	auipc	a1,0x4
    800046b0:	ff458593          	addi	a1,a1,-12 # 800086a0 <syscalls+0x258>
    800046b4:	0001d517          	auipc	a0,0x1d
    800046b8:	10450513          	addi	a0,a0,260 # 800217b8 <ftable>
    800046bc:	ffffc097          	auipc	ra,0xffffc
    800046c0:	484080e7          	jalr	1156(ra) # 80000b40 <initlock>
}
    800046c4:	60a2                	ld	ra,8(sp)
    800046c6:	6402                	ld	s0,0(sp)
    800046c8:	0141                	addi	sp,sp,16
    800046ca:	8082                	ret

00000000800046cc <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800046cc:	1101                	addi	sp,sp,-32
    800046ce:	ec06                	sd	ra,24(sp)
    800046d0:	e822                	sd	s0,16(sp)
    800046d2:	e426                	sd	s1,8(sp)
    800046d4:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800046d6:	0001d517          	auipc	a0,0x1d
    800046da:	0e250513          	addi	a0,a0,226 # 800217b8 <ftable>
    800046de:	ffffc097          	auipc	ra,0xffffc
    800046e2:	4f2080e7          	jalr	1266(ra) # 80000bd0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046e6:	0001d497          	auipc	s1,0x1d
    800046ea:	0ea48493          	addi	s1,s1,234 # 800217d0 <ftable+0x18>
    800046ee:	0001e717          	auipc	a4,0x1e
    800046f2:	08270713          	addi	a4,a4,130 # 80022770 <ftable+0xfb8>
    if(f->ref == 0){
    800046f6:	40dc                	lw	a5,4(s1)
    800046f8:	cf99                	beqz	a5,80004716 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046fa:	02848493          	addi	s1,s1,40
    800046fe:	fee49ce3          	bne	s1,a4,800046f6 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004702:	0001d517          	auipc	a0,0x1d
    80004706:	0b650513          	addi	a0,a0,182 # 800217b8 <ftable>
    8000470a:	ffffc097          	auipc	ra,0xffffc
    8000470e:	57a080e7          	jalr	1402(ra) # 80000c84 <release>
  return 0;
    80004712:	4481                	li	s1,0
    80004714:	a819                	j	8000472a <filealloc+0x5e>
      f->ref = 1;
    80004716:	4785                	li	a5,1
    80004718:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000471a:	0001d517          	auipc	a0,0x1d
    8000471e:	09e50513          	addi	a0,a0,158 # 800217b8 <ftable>
    80004722:	ffffc097          	auipc	ra,0xffffc
    80004726:	562080e7          	jalr	1378(ra) # 80000c84 <release>
}
    8000472a:	8526                	mv	a0,s1
    8000472c:	60e2                	ld	ra,24(sp)
    8000472e:	6442                	ld	s0,16(sp)
    80004730:	64a2                	ld	s1,8(sp)
    80004732:	6105                	addi	sp,sp,32
    80004734:	8082                	ret

0000000080004736 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004736:	1101                	addi	sp,sp,-32
    80004738:	ec06                	sd	ra,24(sp)
    8000473a:	e822                	sd	s0,16(sp)
    8000473c:	e426                	sd	s1,8(sp)
    8000473e:	1000                	addi	s0,sp,32
    80004740:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004742:	0001d517          	auipc	a0,0x1d
    80004746:	07650513          	addi	a0,a0,118 # 800217b8 <ftable>
    8000474a:	ffffc097          	auipc	ra,0xffffc
    8000474e:	486080e7          	jalr	1158(ra) # 80000bd0 <acquire>
  if(f->ref < 1)
    80004752:	40dc                	lw	a5,4(s1)
    80004754:	02f05263          	blez	a5,80004778 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004758:	2785                	addiw	a5,a5,1
    8000475a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000475c:	0001d517          	auipc	a0,0x1d
    80004760:	05c50513          	addi	a0,a0,92 # 800217b8 <ftable>
    80004764:	ffffc097          	auipc	ra,0xffffc
    80004768:	520080e7          	jalr	1312(ra) # 80000c84 <release>
  return f;
}
    8000476c:	8526                	mv	a0,s1
    8000476e:	60e2                	ld	ra,24(sp)
    80004770:	6442                	ld	s0,16(sp)
    80004772:	64a2                	ld	s1,8(sp)
    80004774:	6105                	addi	sp,sp,32
    80004776:	8082                	ret
    panic("filedup");
    80004778:	00004517          	auipc	a0,0x4
    8000477c:	f3050513          	addi	a0,a0,-208 # 800086a8 <syscalls+0x260>
    80004780:	ffffc097          	auipc	ra,0xffffc
    80004784:	dba080e7          	jalr	-582(ra) # 8000053a <panic>

0000000080004788 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004788:	7139                	addi	sp,sp,-64
    8000478a:	fc06                	sd	ra,56(sp)
    8000478c:	f822                	sd	s0,48(sp)
    8000478e:	f426                	sd	s1,40(sp)
    80004790:	f04a                	sd	s2,32(sp)
    80004792:	ec4e                	sd	s3,24(sp)
    80004794:	e852                	sd	s4,16(sp)
    80004796:	e456                	sd	s5,8(sp)
    80004798:	0080                	addi	s0,sp,64
    8000479a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000479c:	0001d517          	auipc	a0,0x1d
    800047a0:	01c50513          	addi	a0,a0,28 # 800217b8 <ftable>
    800047a4:	ffffc097          	auipc	ra,0xffffc
    800047a8:	42c080e7          	jalr	1068(ra) # 80000bd0 <acquire>
  if(f->ref < 1)
    800047ac:	40dc                	lw	a5,4(s1)
    800047ae:	06f05163          	blez	a5,80004810 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800047b2:	37fd                	addiw	a5,a5,-1
    800047b4:	0007871b          	sext.w	a4,a5
    800047b8:	c0dc                	sw	a5,4(s1)
    800047ba:	06e04363          	bgtz	a4,80004820 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800047be:	0004a903          	lw	s2,0(s1)
    800047c2:	0094ca83          	lbu	s5,9(s1)
    800047c6:	0104ba03          	ld	s4,16(s1)
    800047ca:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800047ce:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800047d2:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800047d6:	0001d517          	auipc	a0,0x1d
    800047da:	fe250513          	addi	a0,a0,-30 # 800217b8 <ftable>
    800047de:	ffffc097          	auipc	ra,0xffffc
    800047e2:	4a6080e7          	jalr	1190(ra) # 80000c84 <release>

  if(ff.type == FD_PIPE){
    800047e6:	4785                	li	a5,1
    800047e8:	04f90d63          	beq	s2,a5,80004842 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800047ec:	3979                	addiw	s2,s2,-2
    800047ee:	4785                	li	a5,1
    800047f0:	0527e063          	bltu	a5,s2,80004830 <fileclose+0xa8>
    begin_op();
    800047f4:	00000097          	auipc	ra,0x0
    800047f8:	acc080e7          	jalr	-1332(ra) # 800042c0 <begin_op>
    iput(ff.ip);
    800047fc:	854e                	mv	a0,s3
    800047fe:	fffff097          	auipc	ra,0xfffff
    80004802:	2a0080e7          	jalr	672(ra) # 80003a9e <iput>
    end_op();
    80004806:	00000097          	auipc	ra,0x0
    8000480a:	b38080e7          	jalr	-1224(ra) # 8000433e <end_op>
    8000480e:	a00d                	j	80004830 <fileclose+0xa8>
    panic("fileclose");
    80004810:	00004517          	auipc	a0,0x4
    80004814:	ea050513          	addi	a0,a0,-352 # 800086b0 <syscalls+0x268>
    80004818:	ffffc097          	auipc	ra,0xffffc
    8000481c:	d22080e7          	jalr	-734(ra) # 8000053a <panic>
    release(&ftable.lock);
    80004820:	0001d517          	auipc	a0,0x1d
    80004824:	f9850513          	addi	a0,a0,-104 # 800217b8 <ftable>
    80004828:	ffffc097          	auipc	ra,0xffffc
    8000482c:	45c080e7          	jalr	1116(ra) # 80000c84 <release>
  }
}
    80004830:	70e2                	ld	ra,56(sp)
    80004832:	7442                	ld	s0,48(sp)
    80004834:	74a2                	ld	s1,40(sp)
    80004836:	7902                	ld	s2,32(sp)
    80004838:	69e2                	ld	s3,24(sp)
    8000483a:	6a42                	ld	s4,16(sp)
    8000483c:	6aa2                	ld	s5,8(sp)
    8000483e:	6121                	addi	sp,sp,64
    80004840:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004842:	85d6                	mv	a1,s5
    80004844:	8552                	mv	a0,s4
    80004846:	00000097          	auipc	ra,0x0
    8000484a:	34c080e7          	jalr	844(ra) # 80004b92 <pipeclose>
    8000484e:	b7cd                	j	80004830 <fileclose+0xa8>

0000000080004850 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004850:	715d                	addi	sp,sp,-80
    80004852:	e486                	sd	ra,72(sp)
    80004854:	e0a2                	sd	s0,64(sp)
    80004856:	fc26                	sd	s1,56(sp)
    80004858:	f84a                	sd	s2,48(sp)
    8000485a:	f44e                	sd	s3,40(sp)
    8000485c:	0880                	addi	s0,sp,80
    8000485e:	84aa                	mv	s1,a0
    80004860:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004862:	ffffd097          	auipc	ra,0xffffd
    80004866:	134080e7          	jalr	308(ra) # 80001996 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000486a:	409c                	lw	a5,0(s1)
    8000486c:	37f9                	addiw	a5,a5,-2
    8000486e:	4705                	li	a4,1
    80004870:	04f76763          	bltu	a4,a5,800048be <filestat+0x6e>
    80004874:	892a                	mv	s2,a0
    ilock(f->ip);
    80004876:	6c88                	ld	a0,24(s1)
    80004878:	fffff097          	auipc	ra,0xfffff
    8000487c:	06c080e7          	jalr	108(ra) # 800038e4 <ilock>
    stati(f->ip, &st);
    80004880:	fb840593          	addi	a1,s0,-72
    80004884:	6c88                	ld	a0,24(s1)
    80004886:	fffff097          	auipc	ra,0xfffff
    8000488a:	2e8080e7          	jalr	744(ra) # 80003b6e <stati>
    iunlock(f->ip);
    8000488e:	6c88                	ld	a0,24(s1)
    80004890:	fffff097          	auipc	ra,0xfffff
    80004894:	116080e7          	jalr	278(ra) # 800039a6 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004898:	46e1                	li	a3,24
    8000489a:	fb840613          	addi	a2,s0,-72
    8000489e:	85ce                	mv	a1,s3
    800048a0:	06093503          	ld	a0,96(s2)
    800048a4:	ffffd097          	auipc	ra,0xffffd
    800048a8:	db6080e7          	jalr	-586(ra) # 8000165a <copyout>
    800048ac:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800048b0:	60a6                	ld	ra,72(sp)
    800048b2:	6406                	ld	s0,64(sp)
    800048b4:	74e2                	ld	s1,56(sp)
    800048b6:	7942                	ld	s2,48(sp)
    800048b8:	79a2                	ld	s3,40(sp)
    800048ba:	6161                	addi	sp,sp,80
    800048bc:	8082                	ret
  return -1;
    800048be:	557d                	li	a0,-1
    800048c0:	bfc5                	j	800048b0 <filestat+0x60>

00000000800048c2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800048c2:	7179                	addi	sp,sp,-48
    800048c4:	f406                	sd	ra,40(sp)
    800048c6:	f022                	sd	s0,32(sp)
    800048c8:	ec26                	sd	s1,24(sp)
    800048ca:	e84a                	sd	s2,16(sp)
    800048cc:	e44e                	sd	s3,8(sp)
    800048ce:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800048d0:	00854783          	lbu	a5,8(a0)
    800048d4:	c3d5                	beqz	a5,80004978 <fileread+0xb6>
    800048d6:	84aa                	mv	s1,a0
    800048d8:	89ae                	mv	s3,a1
    800048da:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800048dc:	411c                	lw	a5,0(a0)
    800048de:	4705                	li	a4,1
    800048e0:	04e78963          	beq	a5,a4,80004932 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800048e4:	470d                	li	a4,3
    800048e6:	04e78d63          	beq	a5,a4,80004940 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800048ea:	4709                	li	a4,2
    800048ec:	06e79e63          	bne	a5,a4,80004968 <fileread+0xa6>
    ilock(f->ip);
    800048f0:	6d08                	ld	a0,24(a0)
    800048f2:	fffff097          	auipc	ra,0xfffff
    800048f6:	ff2080e7          	jalr	-14(ra) # 800038e4 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800048fa:	874a                	mv	a4,s2
    800048fc:	5094                	lw	a3,32(s1)
    800048fe:	864e                	mv	a2,s3
    80004900:	4585                	li	a1,1
    80004902:	6c88                	ld	a0,24(s1)
    80004904:	fffff097          	auipc	ra,0xfffff
    80004908:	294080e7          	jalr	660(ra) # 80003b98 <readi>
    8000490c:	892a                	mv	s2,a0
    8000490e:	00a05563          	blez	a0,80004918 <fileread+0x56>
      f->off += r;
    80004912:	509c                	lw	a5,32(s1)
    80004914:	9fa9                	addw	a5,a5,a0
    80004916:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004918:	6c88                	ld	a0,24(s1)
    8000491a:	fffff097          	auipc	ra,0xfffff
    8000491e:	08c080e7          	jalr	140(ra) # 800039a6 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004922:	854a                	mv	a0,s2
    80004924:	70a2                	ld	ra,40(sp)
    80004926:	7402                	ld	s0,32(sp)
    80004928:	64e2                	ld	s1,24(sp)
    8000492a:	6942                	ld	s2,16(sp)
    8000492c:	69a2                	ld	s3,8(sp)
    8000492e:	6145                	addi	sp,sp,48
    80004930:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004932:	6908                	ld	a0,16(a0)
    80004934:	00000097          	auipc	ra,0x0
    80004938:	3c0080e7          	jalr	960(ra) # 80004cf4 <piperead>
    8000493c:	892a                	mv	s2,a0
    8000493e:	b7d5                	j	80004922 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004940:	02451783          	lh	a5,36(a0)
    80004944:	03079693          	slli	a3,a5,0x30
    80004948:	92c1                	srli	a3,a3,0x30
    8000494a:	4725                	li	a4,9
    8000494c:	02d76863          	bltu	a4,a3,8000497c <fileread+0xba>
    80004950:	0792                	slli	a5,a5,0x4
    80004952:	0001d717          	auipc	a4,0x1d
    80004956:	dc670713          	addi	a4,a4,-570 # 80021718 <devsw>
    8000495a:	97ba                	add	a5,a5,a4
    8000495c:	639c                	ld	a5,0(a5)
    8000495e:	c38d                	beqz	a5,80004980 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004960:	4505                	li	a0,1
    80004962:	9782                	jalr	a5
    80004964:	892a                	mv	s2,a0
    80004966:	bf75                	j	80004922 <fileread+0x60>
    panic("fileread");
    80004968:	00004517          	auipc	a0,0x4
    8000496c:	d5850513          	addi	a0,a0,-680 # 800086c0 <syscalls+0x278>
    80004970:	ffffc097          	auipc	ra,0xffffc
    80004974:	bca080e7          	jalr	-1078(ra) # 8000053a <panic>
    return -1;
    80004978:	597d                	li	s2,-1
    8000497a:	b765                	j	80004922 <fileread+0x60>
      return -1;
    8000497c:	597d                	li	s2,-1
    8000497e:	b755                	j	80004922 <fileread+0x60>
    80004980:	597d                	li	s2,-1
    80004982:	b745                	j	80004922 <fileread+0x60>

0000000080004984 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004984:	715d                	addi	sp,sp,-80
    80004986:	e486                	sd	ra,72(sp)
    80004988:	e0a2                	sd	s0,64(sp)
    8000498a:	fc26                	sd	s1,56(sp)
    8000498c:	f84a                	sd	s2,48(sp)
    8000498e:	f44e                	sd	s3,40(sp)
    80004990:	f052                	sd	s4,32(sp)
    80004992:	ec56                	sd	s5,24(sp)
    80004994:	e85a                	sd	s6,16(sp)
    80004996:	e45e                	sd	s7,8(sp)
    80004998:	e062                	sd	s8,0(sp)
    8000499a:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    8000499c:	00954783          	lbu	a5,9(a0)
    800049a0:	10078663          	beqz	a5,80004aac <filewrite+0x128>
    800049a4:	892a                	mv	s2,a0
    800049a6:	8b2e                	mv	s6,a1
    800049a8:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800049aa:	411c                	lw	a5,0(a0)
    800049ac:	4705                	li	a4,1
    800049ae:	02e78263          	beq	a5,a4,800049d2 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800049b2:	470d                	li	a4,3
    800049b4:	02e78663          	beq	a5,a4,800049e0 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800049b8:	4709                	li	a4,2
    800049ba:	0ee79163          	bne	a5,a4,80004a9c <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800049be:	0ac05d63          	blez	a2,80004a78 <filewrite+0xf4>
    int i = 0;
    800049c2:	4981                	li	s3,0
    800049c4:	6b85                	lui	s7,0x1
    800049c6:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800049ca:	6c05                	lui	s8,0x1
    800049cc:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800049d0:	a861                	j	80004a68 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800049d2:	6908                	ld	a0,16(a0)
    800049d4:	00000097          	auipc	ra,0x0
    800049d8:	22e080e7          	jalr	558(ra) # 80004c02 <pipewrite>
    800049dc:	8a2a                	mv	s4,a0
    800049de:	a045                	j	80004a7e <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800049e0:	02451783          	lh	a5,36(a0)
    800049e4:	03079693          	slli	a3,a5,0x30
    800049e8:	92c1                	srli	a3,a3,0x30
    800049ea:	4725                	li	a4,9
    800049ec:	0cd76263          	bltu	a4,a3,80004ab0 <filewrite+0x12c>
    800049f0:	0792                	slli	a5,a5,0x4
    800049f2:	0001d717          	auipc	a4,0x1d
    800049f6:	d2670713          	addi	a4,a4,-730 # 80021718 <devsw>
    800049fa:	97ba                	add	a5,a5,a4
    800049fc:	679c                	ld	a5,8(a5)
    800049fe:	cbdd                	beqz	a5,80004ab4 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004a00:	4505                	li	a0,1
    80004a02:	9782                	jalr	a5
    80004a04:	8a2a                	mv	s4,a0
    80004a06:	a8a5                	j	80004a7e <filewrite+0xfa>
    80004a08:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004a0c:	00000097          	auipc	ra,0x0
    80004a10:	8b4080e7          	jalr	-1868(ra) # 800042c0 <begin_op>
      ilock(f->ip);
    80004a14:	01893503          	ld	a0,24(s2)
    80004a18:	fffff097          	auipc	ra,0xfffff
    80004a1c:	ecc080e7          	jalr	-308(ra) # 800038e4 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004a20:	8756                	mv	a4,s5
    80004a22:	02092683          	lw	a3,32(s2)
    80004a26:	01698633          	add	a2,s3,s6
    80004a2a:	4585                	li	a1,1
    80004a2c:	01893503          	ld	a0,24(s2)
    80004a30:	fffff097          	auipc	ra,0xfffff
    80004a34:	260080e7          	jalr	608(ra) # 80003c90 <writei>
    80004a38:	84aa                	mv	s1,a0
    80004a3a:	00a05763          	blez	a0,80004a48 <filewrite+0xc4>
        f->off += r;
    80004a3e:	02092783          	lw	a5,32(s2)
    80004a42:	9fa9                	addw	a5,a5,a0
    80004a44:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004a48:	01893503          	ld	a0,24(s2)
    80004a4c:	fffff097          	auipc	ra,0xfffff
    80004a50:	f5a080e7          	jalr	-166(ra) # 800039a6 <iunlock>
      end_op();
    80004a54:	00000097          	auipc	ra,0x0
    80004a58:	8ea080e7          	jalr	-1814(ra) # 8000433e <end_op>

      if(r != n1){
    80004a5c:	009a9f63          	bne	s5,s1,80004a7a <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004a60:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004a64:	0149db63          	bge	s3,s4,80004a7a <filewrite+0xf6>
      int n1 = n - i;
    80004a68:	413a04bb          	subw	s1,s4,s3
    80004a6c:	0004879b          	sext.w	a5,s1
    80004a70:	f8fbdce3          	bge	s7,a5,80004a08 <filewrite+0x84>
    80004a74:	84e2                	mv	s1,s8
    80004a76:	bf49                	j	80004a08 <filewrite+0x84>
    int i = 0;
    80004a78:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004a7a:	013a1f63          	bne	s4,s3,80004a98 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004a7e:	8552                	mv	a0,s4
    80004a80:	60a6                	ld	ra,72(sp)
    80004a82:	6406                	ld	s0,64(sp)
    80004a84:	74e2                	ld	s1,56(sp)
    80004a86:	7942                	ld	s2,48(sp)
    80004a88:	79a2                	ld	s3,40(sp)
    80004a8a:	7a02                	ld	s4,32(sp)
    80004a8c:	6ae2                	ld	s5,24(sp)
    80004a8e:	6b42                	ld	s6,16(sp)
    80004a90:	6ba2                	ld	s7,8(sp)
    80004a92:	6c02                	ld	s8,0(sp)
    80004a94:	6161                	addi	sp,sp,80
    80004a96:	8082                	ret
    ret = (i == n ? n : -1);
    80004a98:	5a7d                	li	s4,-1
    80004a9a:	b7d5                	j	80004a7e <filewrite+0xfa>
    panic("filewrite");
    80004a9c:	00004517          	auipc	a0,0x4
    80004aa0:	c3450513          	addi	a0,a0,-972 # 800086d0 <syscalls+0x288>
    80004aa4:	ffffc097          	auipc	ra,0xffffc
    80004aa8:	a96080e7          	jalr	-1386(ra) # 8000053a <panic>
    return -1;
    80004aac:	5a7d                	li	s4,-1
    80004aae:	bfc1                	j	80004a7e <filewrite+0xfa>
      return -1;
    80004ab0:	5a7d                	li	s4,-1
    80004ab2:	b7f1                	j	80004a7e <filewrite+0xfa>
    80004ab4:	5a7d                	li	s4,-1
    80004ab6:	b7e1                	j	80004a7e <filewrite+0xfa>

0000000080004ab8 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004ab8:	7179                	addi	sp,sp,-48
    80004aba:	f406                	sd	ra,40(sp)
    80004abc:	f022                	sd	s0,32(sp)
    80004abe:	ec26                	sd	s1,24(sp)
    80004ac0:	e84a                	sd	s2,16(sp)
    80004ac2:	e44e                	sd	s3,8(sp)
    80004ac4:	e052                	sd	s4,0(sp)
    80004ac6:	1800                	addi	s0,sp,48
    80004ac8:	84aa                	mv	s1,a0
    80004aca:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004acc:	0005b023          	sd	zero,0(a1)
    80004ad0:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004ad4:	00000097          	auipc	ra,0x0
    80004ad8:	bf8080e7          	jalr	-1032(ra) # 800046cc <filealloc>
    80004adc:	e088                	sd	a0,0(s1)
    80004ade:	c551                	beqz	a0,80004b6a <pipealloc+0xb2>
    80004ae0:	00000097          	auipc	ra,0x0
    80004ae4:	bec080e7          	jalr	-1044(ra) # 800046cc <filealloc>
    80004ae8:	00aa3023          	sd	a0,0(s4)
    80004aec:	c92d                	beqz	a0,80004b5e <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004aee:	ffffc097          	auipc	ra,0xffffc
    80004af2:	ff2080e7          	jalr	-14(ra) # 80000ae0 <kalloc>
    80004af6:	892a                	mv	s2,a0
    80004af8:	c125                	beqz	a0,80004b58 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004afa:	4985                	li	s3,1
    80004afc:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004b00:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004b04:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004b08:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004b0c:	00004597          	auipc	a1,0x4
    80004b10:	bd458593          	addi	a1,a1,-1068 # 800086e0 <syscalls+0x298>
    80004b14:	ffffc097          	auipc	ra,0xffffc
    80004b18:	02c080e7          	jalr	44(ra) # 80000b40 <initlock>
  (*f0)->type = FD_PIPE;
    80004b1c:	609c                	ld	a5,0(s1)
    80004b1e:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004b22:	609c                	ld	a5,0(s1)
    80004b24:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004b28:	609c                	ld	a5,0(s1)
    80004b2a:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004b2e:	609c                	ld	a5,0(s1)
    80004b30:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004b34:	000a3783          	ld	a5,0(s4)
    80004b38:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004b3c:	000a3783          	ld	a5,0(s4)
    80004b40:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004b44:	000a3783          	ld	a5,0(s4)
    80004b48:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004b4c:	000a3783          	ld	a5,0(s4)
    80004b50:	0127b823          	sd	s2,16(a5)
  return 0;
    80004b54:	4501                	li	a0,0
    80004b56:	a025                	j	80004b7e <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004b58:	6088                	ld	a0,0(s1)
    80004b5a:	e501                	bnez	a0,80004b62 <pipealloc+0xaa>
    80004b5c:	a039                	j	80004b6a <pipealloc+0xb2>
    80004b5e:	6088                	ld	a0,0(s1)
    80004b60:	c51d                	beqz	a0,80004b8e <pipealloc+0xd6>
    fileclose(*f0);
    80004b62:	00000097          	auipc	ra,0x0
    80004b66:	c26080e7          	jalr	-986(ra) # 80004788 <fileclose>
  if(*f1)
    80004b6a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004b6e:	557d                	li	a0,-1
  if(*f1)
    80004b70:	c799                	beqz	a5,80004b7e <pipealloc+0xc6>
    fileclose(*f1);
    80004b72:	853e                	mv	a0,a5
    80004b74:	00000097          	auipc	ra,0x0
    80004b78:	c14080e7          	jalr	-1004(ra) # 80004788 <fileclose>
  return -1;
    80004b7c:	557d                	li	a0,-1
}
    80004b7e:	70a2                	ld	ra,40(sp)
    80004b80:	7402                	ld	s0,32(sp)
    80004b82:	64e2                	ld	s1,24(sp)
    80004b84:	6942                	ld	s2,16(sp)
    80004b86:	69a2                	ld	s3,8(sp)
    80004b88:	6a02                	ld	s4,0(sp)
    80004b8a:	6145                	addi	sp,sp,48
    80004b8c:	8082                	ret
  return -1;
    80004b8e:	557d                	li	a0,-1
    80004b90:	b7fd                	j	80004b7e <pipealloc+0xc6>

0000000080004b92 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004b92:	1101                	addi	sp,sp,-32
    80004b94:	ec06                	sd	ra,24(sp)
    80004b96:	e822                	sd	s0,16(sp)
    80004b98:	e426                	sd	s1,8(sp)
    80004b9a:	e04a                	sd	s2,0(sp)
    80004b9c:	1000                	addi	s0,sp,32
    80004b9e:	84aa                	mv	s1,a0
    80004ba0:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004ba2:	ffffc097          	auipc	ra,0xffffc
    80004ba6:	02e080e7          	jalr	46(ra) # 80000bd0 <acquire>
  if(writable){
    80004baa:	02090d63          	beqz	s2,80004be4 <pipeclose+0x52>
    pi->writeopen = 0;
    80004bae:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004bb2:	21848513          	addi	a0,s1,536
    80004bb6:	ffffd097          	auipc	ra,0xffffd
    80004bba:	634080e7          	jalr	1588(ra) # 800021ea <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004bbe:	2204b783          	ld	a5,544(s1)
    80004bc2:	eb95                	bnez	a5,80004bf6 <pipeclose+0x64>
    release(&pi->lock);
    80004bc4:	8526                	mv	a0,s1
    80004bc6:	ffffc097          	auipc	ra,0xffffc
    80004bca:	0be080e7          	jalr	190(ra) # 80000c84 <release>
    kfree((char*)pi);
    80004bce:	8526                	mv	a0,s1
    80004bd0:	ffffc097          	auipc	ra,0xffffc
    80004bd4:	e12080e7          	jalr	-494(ra) # 800009e2 <kfree>
  } else
    release(&pi->lock);
}
    80004bd8:	60e2                	ld	ra,24(sp)
    80004bda:	6442                	ld	s0,16(sp)
    80004bdc:	64a2                	ld	s1,8(sp)
    80004bde:	6902                	ld	s2,0(sp)
    80004be0:	6105                	addi	sp,sp,32
    80004be2:	8082                	ret
    pi->readopen = 0;
    80004be4:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004be8:	21c48513          	addi	a0,s1,540
    80004bec:	ffffd097          	auipc	ra,0xffffd
    80004bf0:	5fe080e7          	jalr	1534(ra) # 800021ea <wakeup>
    80004bf4:	b7e9                	j	80004bbe <pipeclose+0x2c>
    release(&pi->lock);
    80004bf6:	8526                	mv	a0,s1
    80004bf8:	ffffc097          	auipc	ra,0xffffc
    80004bfc:	08c080e7          	jalr	140(ra) # 80000c84 <release>
}
    80004c00:	bfe1                	j	80004bd8 <pipeclose+0x46>

0000000080004c02 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004c02:	711d                	addi	sp,sp,-96
    80004c04:	ec86                	sd	ra,88(sp)
    80004c06:	e8a2                	sd	s0,80(sp)
    80004c08:	e4a6                	sd	s1,72(sp)
    80004c0a:	e0ca                	sd	s2,64(sp)
    80004c0c:	fc4e                	sd	s3,56(sp)
    80004c0e:	f852                	sd	s4,48(sp)
    80004c10:	f456                	sd	s5,40(sp)
    80004c12:	f05a                	sd	s6,32(sp)
    80004c14:	ec5e                	sd	s7,24(sp)
    80004c16:	e862                	sd	s8,16(sp)
    80004c18:	1080                	addi	s0,sp,96
    80004c1a:	84aa                	mv	s1,a0
    80004c1c:	8aae                	mv	s5,a1
    80004c1e:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004c20:	ffffd097          	auipc	ra,0xffffd
    80004c24:	d76080e7          	jalr	-650(ra) # 80001996 <myproc>
    80004c28:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004c2a:	8526                	mv	a0,s1
    80004c2c:	ffffc097          	auipc	ra,0xffffc
    80004c30:	fa4080e7          	jalr	-92(ra) # 80000bd0 <acquire>
  while(i < n){
    80004c34:	0b405363          	blez	s4,80004cda <pipewrite+0xd8>
  int i = 0;
    80004c38:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c3a:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004c3c:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004c40:	21c48b93          	addi	s7,s1,540
    80004c44:	a089                	j	80004c86 <pipewrite+0x84>
      release(&pi->lock);
    80004c46:	8526                	mv	a0,s1
    80004c48:	ffffc097          	auipc	ra,0xffffc
    80004c4c:	03c080e7          	jalr	60(ra) # 80000c84 <release>
      return -1;
    80004c50:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004c52:	854a                	mv	a0,s2
    80004c54:	60e6                	ld	ra,88(sp)
    80004c56:	6446                	ld	s0,80(sp)
    80004c58:	64a6                	ld	s1,72(sp)
    80004c5a:	6906                	ld	s2,64(sp)
    80004c5c:	79e2                	ld	s3,56(sp)
    80004c5e:	7a42                	ld	s4,48(sp)
    80004c60:	7aa2                	ld	s5,40(sp)
    80004c62:	7b02                	ld	s6,32(sp)
    80004c64:	6be2                	ld	s7,24(sp)
    80004c66:	6c42                	ld	s8,16(sp)
    80004c68:	6125                	addi	sp,sp,96
    80004c6a:	8082                	ret
      wakeup(&pi->nread);
    80004c6c:	8562                	mv	a0,s8
    80004c6e:	ffffd097          	auipc	ra,0xffffd
    80004c72:	57c080e7          	jalr	1404(ra) # 800021ea <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004c76:	85a6                	mv	a1,s1
    80004c78:	855e                	mv	a0,s7
    80004c7a:	ffffd097          	auipc	ra,0xffffd
    80004c7e:	3e4080e7          	jalr	996(ra) # 8000205e <sleep>
  while(i < n){
    80004c82:	05495d63          	bge	s2,s4,80004cdc <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    80004c86:	2204a783          	lw	a5,544(s1)
    80004c8a:	dfd5                	beqz	a5,80004c46 <pipewrite+0x44>
    80004c8c:	0289a783          	lw	a5,40(s3)
    80004c90:	fbdd                	bnez	a5,80004c46 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004c92:	2184a783          	lw	a5,536(s1)
    80004c96:	21c4a703          	lw	a4,540(s1)
    80004c9a:	2007879b          	addiw	a5,a5,512
    80004c9e:	fcf707e3          	beq	a4,a5,80004c6c <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ca2:	4685                	li	a3,1
    80004ca4:	01590633          	add	a2,s2,s5
    80004ca8:	faf40593          	addi	a1,s0,-81
    80004cac:	0609b503          	ld	a0,96(s3)
    80004cb0:	ffffd097          	auipc	ra,0xffffd
    80004cb4:	a36080e7          	jalr	-1482(ra) # 800016e6 <copyin>
    80004cb8:	03650263          	beq	a0,s6,80004cdc <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004cbc:	21c4a783          	lw	a5,540(s1)
    80004cc0:	0017871b          	addiw	a4,a5,1
    80004cc4:	20e4ae23          	sw	a4,540(s1)
    80004cc8:	1ff7f793          	andi	a5,a5,511
    80004ccc:	97a6                	add	a5,a5,s1
    80004cce:	faf44703          	lbu	a4,-81(s0)
    80004cd2:	00e78c23          	sb	a4,24(a5)
      i++;
    80004cd6:	2905                	addiw	s2,s2,1
    80004cd8:	b76d                	j	80004c82 <pipewrite+0x80>
  int i = 0;
    80004cda:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004cdc:	21848513          	addi	a0,s1,536
    80004ce0:	ffffd097          	auipc	ra,0xffffd
    80004ce4:	50a080e7          	jalr	1290(ra) # 800021ea <wakeup>
  release(&pi->lock);
    80004ce8:	8526                	mv	a0,s1
    80004cea:	ffffc097          	auipc	ra,0xffffc
    80004cee:	f9a080e7          	jalr	-102(ra) # 80000c84 <release>
  return i;
    80004cf2:	b785                	j	80004c52 <pipewrite+0x50>

0000000080004cf4 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004cf4:	715d                	addi	sp,sp,-80
    80004cf6:	e486                	sd	ra,72(sp)
    80004cf8:	e0a2                	sd	s0,64(sp)
    80004cfa:	fc26                	sd	s1,56(sp)
    80004cfc:	f84a                	sd	s2,48(sp)
    80004cfe:	f44e                	sd	s3,40(sp)
    80004d00:	f052                	sd	s4,32(sp)
    80004d02:	ec56                	sd	s5,24(sp)
    80004d04:	e85a                	sd	s6,16(sp)
    80004d06:	0880                	addi	s0,sp,80
    80004d08:	84aa                	mv	s1,a0
    80004d0a:	892e                	mv	s2,a1
    80004d0c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004d0e:	ffffd097          	auipc	ra,0xffffd
    80004d12:	c88080e7          	jalr	-888(ra) # 80001996 <myproc>
    80004d16:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004d18:	8526                	mv	a0,s1
    80004d1a:	ffffc097          	auipc	ra,0xffffc
    80004d1e:	eb6080e7          	jalr	-330(ra) # 80000bd0 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d22:	2184a703          	lw	a4,536(s1)
    80004d26:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d2a:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d2e:	02f71463          	bne	a4,a5,80004d56 <piperead+0x62>
    80004d32:	2244a783          	lw	a5,548(s1)
    80004d36:	c385                	beqz	a5,80004d56 <piperead+0x62>
    if(pr->killed){
    80004d38:	028a2783          	lw	a5,40(s4)
    80004d3c:	ebc9                	bnez	a5,80004dce <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d3e:	85a6                	mv	a1,s1
    80004d40:	854e                	mv	a0,s3
    80004d42:	ffffd097          	auipc	ra,0xffffd
    80004d46:	31c080e7          	jalr	796(ra) # 8000205e <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d4a:	2184a703          	lw	a4,536(s1)
    80004d4e:	21c4a783          	lw	a5,540(s1)
    80004d52:	fef700e3          	beq	a4,a5,80004d32 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d56:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d58:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d5a:	05505463          	blez	s5,80004da2 <piperead+0xae>
    if(pi->nread == pi->nwrite)
    80004d5e:	2184a783          	lw	a5,536(s1)
    80004d62:	21c4a703          	lw	a4,540(s1)
    80004d66:	02f70e63          	beq	a4,a5,80004da2 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004d6a:	0017871b          	addiw	a4,a5,1
    80004d6e:	20e4ac23          	sw	a4,536(s1)
    80004d72:	1ff7f793          	andi	a5,a5,511
    80004d76:	97a6                	add	a5,a5,s1
    80004d78:	0187c783          	lbu	a5,24(a5)
    80004d7c:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d80:	4685                	li	a3,1
    80004d82:	fbf40613          	addi	a2,s0,-65
    80004d86:	85ca                	mv	a1,s2
    80004d88:	060a3503          	ld	a0,96(s4)
    80004d8c:	ffffd097          	auipc	ra,0xffffd
    80004d90:	8ce080e7          	jalr	-1842(ra) # 8000165a <copyout>
    80004d94:	01650763          	beq	a0,s6,80004da2 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d98:	2985                	addiw	s3,s3,1
    80004d9a:	0905                	addi	s2,s2,1
    80004d9c:	fd3a91e3          	bne	s5,s3,80004d5e <piperead+0x6a>
    80004da0:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004da2:	21c48513          	addi	a0,s1,540
    80004da6:	ffffd097          	auipc	ra,0xffffd
    80004daa:	444080e7          	jalr	1092(ra) # 800021ea <wakeup>
  release(&pi->lock);
    80004dae:	8526                	mv	a0,s1
    80004db0:	ffffc097          	auipc	ra,0xffffc
    80004db4:	ed4080e7          	jalr	-300(ra) # 80000c84 <release>
  return i;
}
    80004db8:	854e                	mv	a0,s3
    80004dba:	60a6                	ld	ra,72(sp)
    80004dbc:	6406                	ld	s0,64(sp)
    80004dbe:	74e2                	ld	s1,56(sp)
    80004dc0:	7942                	ld	s2,48(sp)
    80004dc2:	79a2                	ld	s3,40(sp)
    80004dc4:	7a02                	ld	s4,32(sp)
    80004dc6:	6ae2                	ld	s5,24(sp)
    80004dc8:	6b42                	ld	s6,16(sp)
    80004dca:	6161                	addi	sp,sp,80
    80004dcc:	8082                	ret
      release(&pi->lock);
    80004dce:	8526                	mv	a0,s1
    80004dd0:	ffffc097          	auipc	ra,0xffffc
    80004dd4:	eb4080e7          	jalr	-332(ra) # 80000c84 <release>
      return -1;
    80004dd8:	59fd                	li	s3,-1
    80004dda:	bff9                	j	80004db8 <piperead+0xc4>

0000000080004ddc <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004ddc:	de010113          	addi	sp,sp,-544
    80004de0:	20113c23          	sd	ra,536(sp)
    80004de4:	20813823          	sd	s0,528(sp)
    80004de8:	20913423          	sd	s1,520(sp)
    80004dec:	21213023          	sd	s2,512(sp)
    80004df0:	ffce                	sd	s3,504(sp)
    80004df2:	fbd2                	sd	s4,496(sp)
    80004df4:	f7d6                	sd	s5,488(sp)
    80004df6:	f3da                	sd	s6,480(sp)
    80004df8:	efde                	sd	s7,472(sp)
    80004dfa:	ebe2                	sd	s8,464(sp)
    80004dfc:	e7e6                	sd	s9,456(sp)
    80004dfe:	e3ea                	sd	s10,448(sp)
    80004e00:	ff6e                	sd	s11,440(sp)
    80004e02:	1400                	addi	s0,sp,544
    80004e04:	892a                	mv	s2,a0
    80004e06:	dea43423          	sd	a0,-536(s0)
    80004e0a:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e0e:	ffffd097          	auipc	ra,0xffffd
    80004e12:	b88080e7          	jalr	-1144(ra) # 80001996 <myproc>
    80004e16:	84aa                	mv	s1,a0

  begin_op();
    80004e18:	fffff097          	auipc	ra,0xfffff
    80004e1c:	4a8080e7          	jalr	1192(ra) # 800042c0 <begin_op>

  if((ip = namei(path)) == 0){
    80004e20:	854a                	mv	a0,s2
    80004e22:	fffff097          	auipc	ra,0xfffff
    80004e26:	27e080e7          	jalr	638(ra) # 800040a0 <namei>
    80004e2a:	c93d                	beqz	a0,80004ea0 <exec+0xc4>
    80004e2c:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004e2e:	fffff097          	auipc	ra,0xfffff
    80004e32:	ab6080e7          	jalr	-1354(ra) # 800038e4 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004e36:	04000713          	li	a4,64
    80004e3a:	4681                	li	a3,0
    80004e3c:	e5040613          	addi	a2,s0,-432
    80004e40:	4581                	li	a1,0
    80004e42:	8556                	mv	a0,s5
    80004e44:	fffff097          	auipc	ra,0xfffff
    80004e48:	d54080e7          	jalr	-684(ra) # 80003b98 <readi>
    80004e4c:	04000793          	li	a5,64
    80004e50:	00f51a63          	bne	a0,a5,80004e64 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004e54:	e5042703          	lw	a4,-432(s0)
    80004e58:	464c47b7          	lui	a5,0x464c4
    80004e5c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004e60:	04f70663          	beq	a4,a5,80004eac <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004e64:	8556                	mv	a0,s5
    80004e66:	fffff097          	auipc	ra,0xfffff
    80004e6a:	ce0080e7          	jalr	-800(ra) # 80003b46 <iunlockput>
    end_op();
    80004e6e:	fffff097          	auipc	ra,0xfffff
    80004e72:	4d0080e7          	jalr	1232(ra) # 8000433e <end_op>
  }
  return -1;
    80004e76:	557d                	li	a0,-1
}
    80004e78:	21813083          	ld	ra,536(sp)
    80004e7c:	21013403          	ld	s0,528(sp)
    80004e80:	20813483          	ld	s1,520(sp)
    80004e84:	20013903          	ld	s2,512(sp)
    80004e88:	79fe                	ld	s3,504(sp)
    80004e8a:	7a5e                	ld	s4,496(sp)
    80004e8c:	7abe                	ld	s5,488(sp)
    80004e8e:	7b1e                	ld	s6,480(sp)
    80004e90:	6bfe                	ld	s7,472(sp)
    80004e92:	6c5e                	ld	s8,464(sp)
    80004e94:	6cbe                	ld	s9,456(sp)
    80004e96:	6d1e                	ld	s10,448(sp)
    80004e98:	7dfa                	ld	s11,440(sp)
    80004e9a:	22010113          	addi	sp,sp,544
    80004e9e:	8082                	ret
    end_op();
    80004ea0:	fffff097          	auipc	ra,0xfffff
    80004ea4:	49e080e7          	jalr	1182(ra) # 8000433e <end_op>
    return -1;
    80004ea8:	557d                	li	a0,-1
    80004eaa:	b7f9                	j	80004e78 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004eac:	8526                	mv	a0,s1
    80004eae:	ffffd097          	auipc	ra,0xffffd
    80004eb2:	bac080e7          	jalr	-1108(ra) # 80001a5a <proc_pagetable>
    80004eb6:	8b2a                	mv	s6,a0
    80004eb8:	d555                	beqz	a0,80004e64 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004eba:	e7042783          	lw	a5,-400(s0)
    80004ebe:	e8845703          	lhu	a4,-376(s0)
    80004ec2:	c735                	beqz	a4,80004f2e <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004ec4:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ec6:	e0043423          	sd	zero,-504(s0)
    if((ph.vaddr % PGSIZE) != 0)
    80004eca:	6a05                	lui	s4,0x1
    80004ecc:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004ed0:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004ed4:	6d85                	lui	s11,0x1
    80004ed6:	7d7d                	lui	s10,0xfffff
    80004ed8:	ac1d                	j	8000510e <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004eda:	00004517          	auipc	a0,0x4
    80004ede:	80e50513          	addi	a0,a0,-2034 # 800086e8 <syscalls+0x2a0>
    80004ee2:	ffffb097          	auipc	ra,0xffffb
    80004ee6:	658080e7          	jalr	1624(ra) # 8000053a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004eea:	874a                	mv	a4,s2
    80004eec:	009c86bb          	addw	a3,s9,s1
    80004ef0:	4581                	li	a1,0
    80004ef2:	8556                	mv	a0,s5
    80004ef4:	fffff097          	auipc	ra,0xfffff
    80004ef8:	ca4080e7          	jalr	-860(ra) # 80003b98 <readi>
    80004efc:	2501                	sext.w	a0,a0
    80004efe:	1aa91863          	bne	s2,a0,800050ae <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    80004f02:	009d84bb          	addw	s1,s11,s1
    80004f06:	013d09bb          	addw	s3,s10,s3
    80004f0a:	1f74f263          	bgeu	s1,s7,800050ee <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    80004f0e:	02049593          	slli	a1,s1,0x20
    80004f12:	9181                	srli	a1,a1,0x20
    80004f14:	95e2                	add	a1,a1,s8
    80004f16:	855a                	mv	a0,s6
    80004f18:	ffffc097          	auipc	ra,0xffffc
    80004f1c:	13a080e7          	jalr	314(ra) # 80001052 <walkaddr>
    80004f20:	862a                	mv	a2,a0
    if(pa == 0)
    80004f22:	dd45                	beqz	a0,80004eda <exec+0xfe>
      n = PGSIZE;
    80004f24:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004f26:	fd49f2e3          	bgeu	s3,s4,80004eea <exec+0x10e>
      n = sz - i;
    80004f2a:	894e                	mv	s2,s3
    80004f2c:	bf7d                	j	80004eea <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f2e:	4481                	li	s1,0
  iunlockput(ip);
    80004f30:	8556                	mv	a0,s5
    80004f32:	fffff097          	auipc	ra,0xfffff
    80004f36:	c14080e7          	jalr	-1004(ra) # 80003b46 <iunlockput>
  end_op();
    80004f3a:	fffff097          	auipc	ra,0xfffff
    80004f3e:	404080e7          	jalr	1028(ra) # 8000433e <end_op>
  p = myproc();
    80004f42:	ffffd097          	auipc	ra,0xffffd
    80004f46:	a54080e7          	jalr	-1452(ra) # 80001996 <myproc>
    80004f4a:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004f4c:	05853d03          	ld	s10,88(a0)
  sz = PGROUNDUP(sz);
    80004f50:	6785                	lui	a5,0x1
    80004f52:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80004f54:	97a6                	add	a5,a5,s1
    80004f56:	777d                	lui	a4,0xfffff
    80004f58:	8ff9                	and	a5,a5,a4
    80004f5a:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004f5e:	6609                	lui	a2,0x2
    80004f60:	963e                	add	a2,a2,a5
    80004f62:	85be                	mv	a1,a5
    80004f64:	855a                	mv	a0,s6
    80004f66:	ffffc097          	auipc	ra,0xffffc
    80004f6a:	4a0080e7          	jalr	1184(ra) # 80001406 <uvmalloc>
    80004f6e:	8c2a                	mv	s8,a0
  ip = 0;
    80004f70:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004f72:	12050e63          	beqz	a0,800050ae <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004f76:	75f9                	lui	a1,0xffffe
    80004f78:	95aa                	add	a1,a1,a0
    80004f7a:	855a                	mv	a0,s6
    80004f7c:	ffffc097          	auipc	ra,0xffffc
    80004f80:	6ac080e7          	jalr	1708(ra) # 80001628 <uvmclear>
  stackbase = sp - PGSIZE;
    80004f84:	7afd                	lui	s5,0xfffff
    80004f86:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004f88:	df043783          	ld	a5,-528(s0)
    80004f8c:	6388                	ld	a0,0(a5)
    80004f8e:	c925                	beqz	a0,80004ffe <exec+0x222>
    80004f90:	e9040993          	addi	s3,s0,-368
    80004f94:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004f98:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004f9a:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004f9c:	ffffc097          	auipc	ra,0xffffc
    80004fa0:	eac080e7          	jalr	-340(ra) # 80000e48 <strlen>
    80004fa4:	0015079b          	addiw	a5,a0,1
    80004fa8:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004fac:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004fb0:	13596363          	bltu	s2,s5,800050d6 <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004fb4:	df043d83          	ld	s11,-528(s0)
    80004fb8:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004fbc:	8552                	mv	a0,s4
    80004fbe:	ffffc097          	auipc	ra,0xffffc
    80004fc2:	e8a080e7          	jalr	-374(ra) # 80000e48 <strlen>
    80004fc6:	0015069b          	addiw	a3,a0,1
    80004fca:	8652                	mv	a2,s4
    80004fcc:	85ca                	mv	a1,s2
    80004fce:	855a                	mv	a0,s6
    80004fd0:	ffffc097          	auipc	ra,0xffffc
    80004fd4:	68a080e7          	jalr	1674(ra) # 8000165a <copyout>
    80004fd8:	10054363          	bltz	a0,800050de <exec+0x302>
    ustack[argc] = sp;
    80004fdc:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004fe0:	0485                	addi	s1,s1,1
    80004fe2:	008d8793          	addi	a5,s11,8
    80004fe6:	def43823          	sd	a5,-528(s0)
    80004fea:	008db503          	ld	a0,8(s11)
    80004fee:	c911                	beqz	a0,80005002 <exec+0x226>
    if(argc >= MAXARG)
    80004ff0:	09a1                	addi	s3,s3,8
    80004ff2:	fb3c95e3          	bne	s9,s3,80004f9c <exec+0x1c0>
  sz = sz1;
    80004ff6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004ffa:	4a81                	li	s5,0
    80004ffc:	a84d                	j	800050ae <exec+0x2d2>
  sp = sz;
    80004ffe:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005000:	4481                	li	s1,0
  ustack[argc] = 0;
    80005002:	00349793          	slli	a5,s1,0x3
    80005006:	f9078793          	addi	a5,a5,-112
    8000500a:	97a2                	add	a5,a5,s0
    8000500c:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005010:	00148693          	addi	a3,s1,1
    80005014:	068e                	slli	a3,a3,0x3
    80005016:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000501a:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    8000501e:	01597663          	bgeu	s2,s5,8000502a <exec+0x24e>
  sz = sz1;
    80005022:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005026:	4a81                	li	s5,0
    80005028:	a059                	j	800050ae <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000502a:	e9040613          	addi	a2,s0,-368
    8000502e:	85ca                	mv	a1,s2
    80005030:	855a                	mv	a0,s6
    80005032:	ffffc097          	auipc	ra,0xffffc
    80005036:	628080e7          	jalr	1576(ra) # 8000165a <copyout>
    8000503a:	0a054663          	bltz	a0,800050e6 <exec+0x30a>
  p->trapframe->a1 = sp;
    8000503e:	068bb783          	ld	a5,104(s7)
    80005042:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005046:	de843783          	ld	a5,-536(s0)
    8000504a:	0007c703          	lbu	a4,0(a5)
    8000504e:	cf11                	beqz	a4,8000506a <exec+0x28e>
    80005050:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005052:	02f00693          	li	a3,47
    80005056:	a039                	j	80005064 <exec+0x288>
      last = s+1;
    80005058:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    8000505c:	0785                	addi	a5,a5,1
    8000505e:	fff7c703          	lbu	a4,-1(a5)
    80005062:	c701                	beqz	a4,8000506a <exec+0x28e>
    if(*s == '/')
    80005064:	fed71ce3          	bne	a4,a3,8000505c <exec+0x280>
    80005068:	bfc5                	j	80005058 <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    8000506a:	4641                	li	a2,16
    8000506c:	de843583          	ld	a1,-536(s0)
    80005070:	168b8513          	addi	a0,s7,360
    80005074:	ffffc097          	auipc	ra,0xffffc
    80005078:	da2080e7          	jalr	-606(ra) # 80000e16 <safestrcpy>
  oldpagetable = p->pagetable;
    8000507c:	060bb503          	ld	a0,96(s7)
  p->pagetable = pagetable;
    80005080:	076bb023          	sd	s6,96(s7)
  p->sz = sz;
    80005084:	058bbc23          	sd	s8,88(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005088:	068bb783          	ld	a5,104(s7)
    8000508c:	e6843703          	ld	a4,-408(s0)
    80005090:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005092:	068bb783          	ld	a5,104(s7)
    80005096:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000509a:	85ea                	mv	a1,s10
    8000509c:	ffffd097          	auipc	ra,0xffffd
    800050a0:	a5a080e7          	jalr	-1446(ra) # 80001af6 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800050a4:	0004851b          	sext.w	a0,s1
    800050a8:	bbc1                	j	80004e78 <exec+0x9c>
    800050aa:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    800050ae:	df843583          	ld	a1,-520(s0)
    800050b2:	855a                	mv	a0,s6
    800050b4:	ffffd097          	auipc	ra,0xffffd
    800050b8:	a42080e7          	jalr	-1470(ra) # 80001af6 <proc_freepagetable>
  if(ip){
    800050bc:	da0a94e3          	bnez	s5,80004e64 <exec+0x88>
  return -1;
    800050c0:	557d                	li	a0,-1
    800050c2:	bb5d                	j	80004e78 <exec+0x9c>
    800050c4:	de943c23          	sd	s1,-520(s0)
    800050c8:	b7dd                	j	800050ae <exec+0x2d2>
    800050ca:	de943c23          	sd	s1,-520(s0)
    800050ce:	b7c5                	j	800050ae <exec+0x2d2>
    800050d0:	de943c23          	sd	s1,-520(s0)
    800050d4:	bfe9                	j	800050ae <exec+0x2d2>
  sz = sz1;
    800050d6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800050da:	4a81                	li	s5,0
    800050dc:	bfc9                	j	800050ae <exec+0x2d2>
  sz = sz1;
    800050de:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800050e2:	4a81                	li	s5,0
    800050e4:	b7e9                	j	800050ae <exec+0x2d2>
  sz = sz1;
    800050e6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800050ea:	4a81                	li	s5,0
    800050ec:	b7c9                	j	800050ae <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800050ee:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800050f2:	e0843783          	ld	a5,-504(s0)
    800050f6:	0017869b          	addiw	a3,a5,1
    800050fa:	e0d43423          	sd	a3,-504(s0)
    800050fe:	e0043783          	ld	a5,-512(s0)
    80005102:	0387879b          	addiw	a5,a5,56
    80005106:	e8845703          	lhu	a4,-376(s0)
    8000510a:	e2e6d3e3          	bge	a3,a4,80004f30 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000510e:	2781                	sext.w	a5,a5
    80005110:	e0f43023          	sd	a5,-512(s0)
    80005114:	03800713          	li	a4,56
    80005118:	86be                	mv	a3,a5
    8000511a:	e1840613          	addi	a2,s0,-488
    8000511e:	4581                	li	a1,0
    80005120:	8556                	mv	a0,s5
    80005122:	fffff097          	auipc	ra,0xfffff
    80005126:	a76080e7          	jalr	-1418(ra) # 80003b98 <readi>
    8000512a:	03800793          	li	a5,56
    8000512e:	f6f51ee3          	bne	a0,a5,800050aa <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    80005132:	e1842783          	lw	a5,-488(s0)
    80005136:	4705                	li	a4,1
    80005138:	fae79de3          	bne	a5,a4,800050f2 <exec+0x316>
    if(ph.memsz < ph.filesz)
    8000513c:	e4043603          	ld	a2,-448(s0)
    80005140:	e3843783          	ld	a5,-456(s0)
    80005144:	f8f660e3          	bltu	a2,a5,800050c4 <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005148:	e2843783          	ld	a5,-472(s0)
    8000514c:	963e                	add	a2,a2,a5
    8000514e:	f6f66ee3          	bltu	a2,a5,800050ca <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005152:	85a6                	mv	a1,s1
    80005154:	855a                	mv	a0,s6
    80005156:	ffffc097          	auipc	ra,0xffffc
    8000515a:	2b0080e7          	jalr	688(ra) # 80001406 <uvmalloc>
    8000515e:	dea43c23          	sd	a0,-520(s0)
    80005162:	d53d                	beqz	a0,800050d0 <exec+0x2f4>
    if((ph.vaddr % PGSIZE) != 0)
    80005164:	e2843c03          	ld	s8,-472(s0)
    80005168:	de043783          	ld	a5,-544(s0)
    8000516c:	00fc77b3          	and	a5,s8,a5
    80005170:	ff9d                	bnez	a5,800050ae <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005172:	e2042c83          	lw	s9,-480(s0)
    80005176:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000517a:	f60b8ae3          	beqz	s7,800050ee <exec+0x312>
    8000517e:	89de                	mv	s3,s7
    80005180:	4481                	li	s1,0
    80005182:	b371                	j	80004f0e <exec+0x132>

0000000080005184 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005184:	7179                	addi	sp,sp,-48
    80005186:	f406                	sd	ra,40(sp)
    80005188:	f022                	sd	s0,32(sp)
    8000518a:	ec26                	sd	s1,24(sp)
    8000518c:	e84a                	sd	s2,16(sp)
    8000518e:	1800                	addi	s0,sp,48
    80005190:	892e                	mv	s2,a1
    80005192:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005194:	fdc40593          	addi	a1,s0,-36
    80005198:	ffffe097          	auipc	ra,0xffffe
    8000519c:	b0c080e7          	jalr	-1268(ra) # 80002ca4 <argint>
    800051a0:	04054063          	bltz	a0,800051e0 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800051a4:	fdc42703          	lw	a4,-36(s0)
    800051a8:	47bd                	li	a5,15
    800051aa:	02e7ed63          	bltu	a5,a4,800051e4 <argfd+0x60>
    800051ae:	ffffc097          	auipc	ra,0xffffc
    800051b2:	7e8080e7          	jalr	2024(ra) # 80001996 <myproc>
    800051b6:	fdc42703          	lw	a4,-36(s0)
    800051ba:	01c70793          	addi	a5,a4,28 # fffffffffffff01c <end+0xffffffff7ffd901c>
    800051be:	078e                	slli	a5,a5,0x3
    800051c0:	953e                	add	a0,a0,a5
    800051c2:	611c                	ld	a5,0(a0)
    800051c4:	c395                	beqz	a5,800051e8 <argfd+0x64>
    return -1;
  if(pfd)
    800051c6:	00090463          	beqz	s2,800051ce <argfd+0x4a>
    *pfd = fd;
    800051ca:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800051ce:	4501                	li	a0,0
  if(pf)
    800051d0:	c091                	beqz	s1,800051d4 <argfd+0x50>
    *pf = f;
    800051d2:	e09c                	sd	a5,0(s1)
}
    800051d4:	70a2                	ld	ra,40(sp)
    800051d6:	7402                	ld	s0,32(sp)
    800051d8:	64e2                	ld	s1,24(sp)
    800051da:	6942                	ld	s2,16(sp)
    800051dc:	6145                	addi	sp,sp,48
    800051de:	8082                	ret
    return -1;
    800051e0:	557d                	li	a0,-1
    800051e2:	bfcd                	j	800051d4 <argfd+0x50>
    return -1;
    800051e4:	557d                	li	a0,-1
    800051e6:	b7fd                	j	800051d4 <argfd+0x50>
    800051e8:	557d                	li	a0,-1
    800051ea:	b7ed                	j	800051d4 <argfd+0x50>

00000000800051ec <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800051ec:	1101                	addi	sp,sp,-32
    800051ee:	ec06                	sd	ra,24(sp)
    800051f0:	e822                	sd	s0,16(sp)
    800051f2:	e426                	sd	s1,8(sp)
    800051f4:	1000                	addi	s0,sp,32
    800051f6:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800051f8:	ffffc097          	auipc	ra,0xffffc
    800051fc:	79e080e7          	jalr	1950(ra) # 80001996 <myproc>
    80005200:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005202:	0e050793          	addi	a5,a0,224
    80005206:	4501                	li	a0,0
    80005208:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000520a:	6398                	ld	a4,0(a5)
    8000520c:	cb19                	beqz	a4,80005222 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000520e:	2505                	addiw	a0,a0,1
    80005210:	07a1                	addi	a5,a5,8
    80005212:	fed51ce3          	bne	a0,a3,8000520a <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005216:	557d                	li	a0,-1
}
    80005218:	60e2                	ld	ra,24(sp)
    8000521a:	6442                	ld	s0,16(sp)
    8000521c:	64a2                	ld	s1,8(sp)
    8000521e:	6105                	addi	sp,sp,32
    80005220:	8082                	ret
      p->ofile[fd] = f;
    80005222:	01c50793          	addi	a5,a0,28
    80005226:	078e                	slli	a5,a5,0x3
    80005228:	963e                	add	a2,a2,a5
    8000522a:	e204                	sd	s1,0(a2)
      return fd;
    8000522c:	b7f5                	j	80005218 <fdalloc+0x2c>

000000008000522e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000522e:	715d                	addi	sp,sp,-80
    80005230:	e486                	sd	ra,72(sp)
    80005232:	e0a2                	sd	s0,64(sp)
    80005234:	fc26                	sd	s1,56(sp)
    80005236:	f84a                	sd	s2,48(sp)
    80005238:	f44e                	sd	s3,40(sp)
    8000523a:	f052                	sd	s4,32(sp)
    8000523c:	ec56                	sd	s5,24(sp)
    8000523e:	0880                	addi	s0,sp,80
    80005240:	89ae                	mv	s3,a1
    80005242:	8ab2                	mv	s5,a2
    80005244:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005246:	fb040593          	addi	a1,s0,-80
    8000524a:	fffff097          	auipc	ra,0xfffff
    8000524e:	e74080e7          	jalr	-396(ra) # 800040be <nameiparent>
    80005252:	892a                	mv	s2,a0
    80005254:	12050e63          	beqz	a0,80005390 <create+0x162>
    return 0;

  ilock(dp);
    80005258:	ffffe097          	auipc	ra,0xffffe
    8000525c:	68c080e7          	jalr	1676(ra) # 800038e4 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005260:	4601                	li	a2,0
    80005262:	fb040593          	addi	a1,s0,-80
    80005266:	854a                	mv	a0,s2
    80005268:	fffff097          	auipc	ra,0xfffff
    8000526c:	b60080e7          	jalr	-1184(ra) # 80003dc8 <dirlookup>
    80005270:	84aa                	mv	s1,a0
    80005272:	c921                	beqz	a0,800052c2 <create+0x94>
    iunlockput(dp);
    80005274:	854a                	mv	a0,s2
    80005276:	fffff097          	auipc	ra,0xfffff
    8000527a:	8d0080e7          	jalr	-1840(ra) # 80003b46 <iunlockput>
    ilock(ip);
    8000527e:	8526                	mv	a0,s1
    80005280:	ffffe097          	auipc	ra,0xffffe
    80005284:	664080e7          	jalr	1636(ra) # 800038e4 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005288:	2981                	sext.w	s3,s3
    8000528a:	4789                	li	a5,2
    8000528c:	02f99463          	bne	s3,a5,800052b4 <create+0x86>
    80005290:	0444d783          	lhu	a5,68(s1)
    80005294:	37f9                	addiw	a5,a5,-2
    80005296:	17c2                	slli	a5,a5,0x30
    80005298:	93c1                	srli	a5,a5,0x30
    8000529a:	4705                	li	a4,1
    8000529c:	00f76c63          	bltu	a4,a5,800052b4 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800052a0:	8526                	mv	a0,s1
    800052a2:	60a6                	ld	ra,72(sp)
    800052a4:	6406                	ld	s0,64(sp)
    800052a6:	74e2                	ld	s1,56(sp)
    800052a8:	7942                	ld	s2,48(sp)
    800052aa:	79a2                	ld	s3,40(sp)
    800052ac:	7a02                	ld	s4,32(sp)
    800052ae:	6ae2                	ld	s5,24(sp)
    800052b0:	6161                	addi	sp,sp,80
    800052b2:	8082                	ret
    iunlockput(ip);
    800052b4:	8526                	mv	a0,s1
    800052b6:	fffff097          	auipc	ra,0xfffff
    800052ba:	890080e7          	jalr	-1904(ra) # 80003b46 <iunlockput>
    return 0;
    800052be:	4481                	li	s1,0
    800052c0:	b7c5                	j	800052a0 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800052c2:	85ce                	mv	a1,s3
    800052c4:	00092503          	lw	a0,0(s2)
    800052c8:	ffffe097          	auipc	ra,0xffffe
    800052cc:	482080e7          	jalr	1154(ra) # 8000374a <ialloc>
    800052d0:	84aa                	mv	s1,a0
    800052d2:	c521                	beqz	a0,8000531a <create+0xec>
  ilock(ip);
    800052d4:	ffffe097          	auipc	ra,0xffffe
    800052d8:	610080e7          	jalr	1552(ra) # 800038e4 <ilock>
  ip->major = major;
    800052dc:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800052e0:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800052e4:	4a05                	li	s4,1
    800052e6:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    800052ea:	8526                	mv	a0,s1
    800052ec:	ffffe097          	auipc	ra,0xffffe
    800052f0:	52c080e7          	jalr	1324(ra) # 80003818 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800052f4:	2981                	sext.w	s3,s3
    800052f6:	03498a63          	beq	s3,s4,8000532a <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800052fa:	40d0                	lw	a2,4(s1)
    800052fc:	fb040593          	addi	a1,s0,-80
    80005300:	854a                	mv	a0,s2
    80005302:	fffff097          	auipc	ra,0xfffff
    80005306:	cdc080e7          	jalr	-804(ra) # 80003fde <dirlink>
    8000530a:	06054b63          	bltz	a0,80005380 <create+0x152>
  iunlockput(dp);
    8000530e:	854a                	mv	a0,s2
    80005310:	fffff097          	auipc	ra,0xfffff
    80005314:	836080e7          	jalr	-1994(ra) # 80003b46 <iunlockput>
  return ip;
    80005318:	b761                	j	800052a0 <create+0x72>
    panic("create: ialloc");
    8000531a:	00003517          	auipc	a0,0x3
    8000531e:	3ee50513          	addi	a0,a0,1006 # 80008708 <syscalls+0x2c0>
    80005322:	ffffb097          	auipc	ra,0xffffb
    80005326:	218080e7          	jalr	536(ra) # 8000053a <panic>
    dp->nlink++;  // for ".."
    8000532a:	04a95783          	lhu	a5,74(s2)
    8000532e:	2785                	addiw	a5,a5,1
    80005330:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005334:	854a                	mv	a0,s2
    80005336:	ffffe097          	auipc	ra,0xffffe
    8000533a:	4e2080e7          	jalr	1250(ra) # 80003818 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000533e:	40d0                	lw	a2,4(s1)
    80005340:	00003597          	auipc	a1,0x3
    80005344:	3d858593          	addi	a1,a1,984 # 80008718 <syscalls+0x2d0>
    80005348:	8526                	mv	a0,s1
    8000534a:	fffff097          	auipc	ra,0xfffff
    8000534e:	c94080e7          	jalr	-876(ra) # 80003fde <dirlink>
    80005352:	00054f63          	bltz	a0,80005370 <create+0x142>
    80005356:	00492603          	lw	a2,4(s2)
    8000535a:	00003597          	auipc	a1,0x3
    8000535e:	3c658593          	addi	a1,a1,966 # 80008720 <syscalls+0x2d8>
    80005362:	8526                	mv	a0,s1
    80005364:	fffff097          	auipc	ra,0xfffff
    80005368:	c7a080e7          	jalr	-902(ra) # 80003fde <dirlink>
    8000536c:	f80557e3          	bgez	a0,800052fa <create+0xcc>
      panic("create dots");
    80005370:	00003517          	auipc	a0,0x3
    80005374:	3b850513          	addi	a0,a0,952 # 80008728 <syscalls+0x2e0>
    80005378:	ffffb097          	auipc	ra,0xffffb
    8000537c:	1c2080e7          	jalr	450(ra) # 8000053a <panic>
    panic("create: dirlink");
    80005380:	00003517          	auipc	a0,0x3
    80005384:	3b850513          	addi	a0,a0,952 # 80008738 <syscalls+0x2f0>
    80005388:	ffffb097          	auipc	ra,0xffffb
    8000538c:	1b2080e7          	jalr	434(ra) # 8000053a <panic>
    return 0;
    80005390:	84aa                	mv	s1,a0
    80005392:	b739                	j	800052a0 <create+0x72>

0000000080005394 <sys_dup>:
{
    80005394:	7179                	addi	sp,sp,-48
    80005396:	f406                	sd	ra,40(sp)
    80005398:	f022                	sd	s0,32(sp)
    8000539a:	ec26                	sd	s1,24(sp)
    8000539c:	e84a                	sd	s2,16(sp)
    8000539e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800053a0:	fd840613          	addi	a2,s0,-40
    800053a4:	4581                	li	a1,0
    800053a6:	4501                	li	a0,0
    800053a8:	00000097          	auipc	ra,0x0
    800053ac:	ddc080e7          	jalr	-548(ra) # 80005184 <argfd>
    return -1;
    800053b0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800053b2:	02054363          	bltz	a0,800053d8 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    800053b6:	fd843903          	ld	s2,-40(s0)
    800053ba:	854a                	mv	a0,s2
    800053bc:	00000097          	auipc	ra,0x0
    800053c0:	e30080e7          	jalr	-464(ra) # 800051ec <fdalloc>
    800053c4:	84aa                	mv	s1,a0
    return -1;
    800053c6:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800053c8:	00054863          	bltz	a0,800053d8 <sys_dup+0x44>
  filedup(f);
    800053cc:	854a                	mv	a0,s2
    800053ce:	fffff097          	auipc	ra,0xfffff
    800053d2:	368080e7          	jalr	872(ra) # 80004736 <filedup>
  return fd;
    800053d6:	87a6                	mv	a5,s1
}
    800053d8:	853e                	mv	a0,a5
    800053da:	70a2                	ld	ra,40(sp)
    800053dc:	7402                	ld	s0,32(sp)
    800053de:	64e2                	ld	s1,24(sp)
    800053e0:	6942                	ld	s2,16(sp)
    800053e2:	6145                	addi	sp,sp,48
    800053e4:	8082                	ret

00000000800053e6 <sys_read>:
{
    800053e6:	7179                	addi	sp,sp,-48
    800053e8:	f406                	sd	ra,40(sp)
    800053ea:	f022                	sd	s0,32(sp)
    800053ec:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053ee:	fe840613          	addi	a2,s0,-24
    800053f2:	4581                	li	a1,0
    800053f4:	4501                	li	a0,0
    800053f6:	00000097          	auipc	ra,0x0
    800053fa:	d8e080e7          	jalr	-626(ra) # 80005184 <argfd>
    return -1;
    800053fe:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005400:	04054163          	bltz	a0,80005442 <sys_read+0x5c>
    80005404:	fe440593          	addi	a1,s0,-28
    80005408:	4509                	li	a0,2
    8000540a:	ffffe097          	auipc	ra,0xffffe
    8000540e:	89a080e7          	jalr	-1894(ra) # 80002ca4 <argint>
    return -1;
    80005412:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005414:	02054763          	bltz	a0,80005442 <sys_read+0x5c>
    80005418:	fd840593          	addi	a1,s0,-40
    8000541c:	4505                	li	a0,1
    8000541e:	ffffe097          	auipc	ra,0xffffe
    80005422:	8a8080e7          	jalr	-1880(ra) # 80002cc6 <argaddr>
    return -1;
    80005426:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005428:	00054d63          	bltz	a0,80005442 <sys_read+0x5c>
  return fileread(f, p, n);
    8000542c:	fe442603          	lw	a2,-28(s0)
    80005430:	fd843583          	ld	a1,-40(s0)
    80005434:	fe843503          	ld	a0,-24(s0)
    80005438:	fffff097          	auipc	ra,0xfffff
    8000543c:	48a080e7          	jalr	1162(ra) # 800048c2 <fileread>
    80005440:	87aa                	mv	a5,a0
}
    80005442:	853e                	mv	a0,a5
    80005444:	70a2                	ld	ra,40(sp)
    80005446:	7402                	ld	s0,32(sp)
    80005448:	6145                	addi	sp,sp,48
    8000544a:	8082                	ret

000000008000544c <sys_write>:
{
    8000544c:	7179                	addi	sp,sp,-48
    8000544e:	f406                	sd	ra,40(sp)
    80005450:	f022                	sd	s0,32(sp)
    80005452:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005454:	fe840613          	addi	a2,s0,-24
    80005458:	4581                	li	a1,0
    8000545a:	4501                	li	a0,0
    8000545c:	00000097          	auipc	ra,0x0
    80005460:	d28080e7          	jalr	-728(ra) # 80005184 <argfd>
    return -1;
    80005464:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005466:	04054163          	bltz	a0,800054a8 <sys_write+0x5c>
    8000546a:	fe440593          	addi	a1,s0,-28
    8000546e:	4509                	li	a0,2
    80005470:	ffffe097          	auipc	ra,0xffffe
    80005474:	834080e7          	jalr	-1996(ra) # 80002ca4 <argint>
    return -1;
    80005478:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000547a:	02054763          	bltz	a0,800054a8 <sys_write+0x5c>
    8000547e:	fd840593          	addi	a1,s0,-40
    80005482:	4505                	li	a0,1
    80005484:	ffffe097          	auipc	ra,0xffffe
    80005488:	842080e7          	jalr	-1982(ra) # 80002cc6 <argaddr>
    return -1;
    8000548c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000548e:	00054d63          	bltz	a0,800054a8 <sys_write+0x5c>
  return filewrite(f, p, n);
    80005492:	fe442603          	lw	a2,-28(s0)
    80005496:	fd843583          	ld	a1,-40(s0)
    8000549a:	fe843503          	ld	a0,-24(s0)
    8000549e:	fffff097          	auipc	ra,0xfffff
    800054a2:	4e6080e7          	jalr	1254(ra) # 80004984 <filewrite>
    800054a6:	87aa                	mv	a5,a0
}
    800054a8:	853e                	mv	a0,a5
    800054aa:	70a2                	ld	ra,40(sp)
    800054ac:	7402                	ld	s0,32(sp)
    800054ae:	6145                	addi	sp,sp,48
    800054b0:	8082                	ret

00000000800054b2 <sys_close>:
{
    800054b2:	1101                	addi	sp,sp,-32
    800054b4:	ec06                	sd	ra,24(sp)
    800054b6:	e822                	sd	s0,16(sp)
    800054b8:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800054ba:	fe040613          	addi	a2,s0,-32
    800054be:	fec40593          	addi	a1,s0,-20
    800054c2:	4501                	li	a0,0
    800054c4:	00000097          	auipc	ra,0x0
    800054c8:	cc0080e7          	jalr	-832(ra) # 80005184 <argfd>
    return -1;
    800054cc:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800054ce:	02054463          	bltz	a0,800054f6 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800054d2:	ffffc097          	auipc	ra,0xffffc
    800054d6:	4c4080e7          	jalr	1220(ra) # 80001996 <myproc>
    800054da:	fec42783          	lw	a5,-20(s0)
    800054de:	07f1                	addi	a5,a5,28
    800054e0:	078e                	slli	a5,a5,0x3
    800054e2:	953e                	add	a0,a0,a5
    800054e4:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800054e8:	fe043503          	ld	a0,-32(s0)
    800054ec:	fffff097          	auipc	ra,0xfffff
    800054f0:	29c080e7          	jalr	668(ra) # 80004788 <fileclose>
  return 0;
    800054f4:	4781                	li	a5,0
}
    800054f6:	853e                	mv	a0,a5
    800054f8:	60e2                	ld	ra,24(sp)
    800054fa:	6442                	ld	s0,16(sp)
    800054fc:	6105                	addi	sp,sp,32
    800054fe:	8082                	ret

0000000080005500 <sys_fstat>:
{
    80005500:	1101                	addi	sp,sp,-32
    80005502:	ec06                	sd	ra,24(sp)
    80005504:	e822                	sd	s0,16(sp)
    80005506:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005508:	fe840613          	addi	a2,s0,-24
    8000550c:	4581                	li	a1,0
    8000550e:	4501                	li	a0,0
    80005510:	00000097          	auipc	ra,0x0
    80005514:	c74080e7          	jalr	-908(ra) # 80005184 <argfd>
    return -1;
    80005518:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000551a:	02054563          	bltz	a0,80005544 <sys_fstat+0x44>
    8000551e:	fe040593          	addi	a1,s0,-32
    80005522:	4505                	li	a0,1
    80005524:	ffffd097          	auipc	ra,0xffffd
    80005528:	7a2080e7          	jalr	1954(ra) # 80002cc6 <argaddr>
    return -1;
    8000552c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000552e:	00054b63          	bltz	a0,80005544 <sys_fstat+0x44>
  return filestat(f, st);
    80005532:	fe043583          	ld	a1,-32(s0)
    80005536:	fe843503          	ld	a0,-24(s0)
    8000553a:	fffff097          	auipc	ra,0xfffff
    8000553e:	316080e7          	jalr	790(ra) # 80004850 <filestat>
    80005542:	87aa                	mv	a5,a0
}
    80005544:	853e                	mv	a0,a5
    80005546:	60e2                	ld	ra,24(sp)
    80005548:	6442                	ld	s0,16(sp)
    8000554a:	6105                	addi	sp,sp,32
    8000554c:	8082                	ret

000000008000554e <sys_link>:
{
    8000554e:	7169                	addi	sp,sp,-304
    80005550:	f606                	sd	ra,296(sp)
    80005552:	f222                	sd	s0,288(sp)
    80005554:	ee26                	sd	s1,280(sp)
    80005556:	ea4a                	sd	s2,272(sp)
    80005558:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000555a:	08000613          	li	a2,128
    8000555e:	ed040593          	addi	a1,s0,-304
    80005562:	4501                	li	a0,0
    80005564:	ffffd097          	auipc	ra,0xffffd
    80005568:	784080e7          	jalr	1924(ra) # 80002ce8 <argstr>
    return -1;
    8000556c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000556e:	10054e63          	bltz	a0,8000568a <sys_link+0x13c>
    80005572:	08000613          	li	a2,128
    80005576:	f5040593          	addi	a1,s0,-176
    8000557a:	4505                	li	a0,1
    8000557c:	ffffd097          	auipc	ra,0xffffd
    80005580:	76c080e7          	jalr	1900(ra) # 80002ce8 <argstr>
    return -1;
    80005584:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005586:	10054263          	bltz	a0,8000568a <sys_link+0x13c>
  begin_op();
    8000558a:	fffff097          	auipc	ra,0xfffff
    8000558e:	d36080e7          	jalr	-714(ra) # 800042c0 <begin_op>
  if((ip = namei(old)) == 0){
    80005592:	ed040513          	addi	a0,s0,-304
    80005596:	fffff097          	auipc	ra,0xfffff
    8000559a:	b0a080e7          	jalr	-1270(ra) # 800040a0 <namei>
    8000559e:	84aa                	mv	s1,a0
    800055a0:	c551                	beqz	a0,8000562c <sys_link+0xde>
  ilock(ip);
    800055a2:	ffffe097          	auipc	ra,0xffffe
    800055a6:	342080e7          	jalr	834(ra) # 800038e4 <ilock>
  if(ip->type == T_DIR){
    800055aa:	04449703          	lh	a4,68(s1)
    800055ae:	4785                	li	a5,1
    800055b0:	08f70463          	beq	a4,a5,80005638 <sys_link+0xea>
  ip->nlink++;
    800055b4:	04a4d783          	lhu	a5,74(s1)
    800055b8:	2785                	addiw	a5,a5,1
    800055ba:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800055be:	8526                	mv	a0,s1
    800055c0:	ffffe097          	auipc	ra,0xffffe
    800055c4:	258080e7          	jalr	600(ra) # 80003818 <iupdate>
  iunlock(ip);
    800055c8:	8526                	mv	a0,s1
    800055ca:	ffffe097          	auipc	ra,0xffffe
    800055ce:	3dc080e7          	jalr	988(ra) # 800039a6 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800055d2:	fd040593          	addi	a1,s0,-48
    800055d6:	f5040513          	addi	a0,s0,-176
    800055da:	fffff097          	auipc	ra,0xfffff
    800055de:	ae4080e7          	jalr	-1308(ra) # 800040be <nameiparent>
    800055e2:	892a                	mv	s2,a0
    800055e4:	c935                	beqz	a0,80005658 <sys_link+0x10a>
  ilock(dp);
    800055e6:	ffffe097          	auipc	ra,0xffffe
    800055ea:	2fe080e7          	jalr	766(ra) # 800038e4 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800055ee:	00092703          	lw	a4,0(s2)
    800055f2:	409c                	lw	a5,0(s1)
    800055f4:	04f71d63          	bne	a4,a5,8000564e <sys_link+0x100>
    800055f8:	40d0                	lw	a2,4(s1)
    800055fa:	fd040593          	addi	a1,s0,-48
    800055fe:	854a                	mv	a0,s2
    80005600:	fffff097          	auipc	ra,0xfffff
    80005604:	9de080e7          	jalr	-1570(ra) # 80003fde <dirlink>
    80005608:	04054363          	bltz	a0,8000564e <sys_link+0x100>
  iunlockput(dp);
    8000560c:	854a                	mv	a0,s2
    8000560e:	ffffe097          	auipc	ra,0xffffe
    80005612:	538080e7          	jalr	1336(ra) # 80003b46 <iunlockput>
  iput(ip);
    80005616:	8526                	mv	a0,s1
    80005618:	ffffe097          	auipc	ra,0xffffe
    8000561c:	486080e7          	jalr	1158(ra) # 80003a9e <iput>
  end_op();
    80005620:	fffff097          	auipc	ra,0xfffff
    80005624:	d1e080e7          	jalr	-738(ra) # 8000433e <end_op>
  return 0;
    80005628:	4781                	li	a5,0
    8000562a:	a085                	j	8000568a <sys_link+0x13c>
    end_op();
    8000562c:	fffff097          	auipc	ra,0xfffff
    80005630:	d12080e7          	jalr	-750(ra) # 8000433e <end_op>
    return -1;
    80005634:	57fd                	li	a5,-1
    80005636:	a891                	j	8000568a <sys_link+0x13c>
    iunlockput(ip);
    80005638:	8526                	mv	a0,s1
    8000563a:	ffffe097          	auipc	ra,0xffffe
    8000563e:	50c080e7          	jalr	1292(ra) # 80003b46 <iunlockput>
    end_op();
    80005642:	fffff097          	auipc	ra,0xfffff
    80005646:	cfc080e7          	jalr	-772(ra) # 8000433e <end_op>
    return -1;
    8000564a:	57fd                	li	a5,-1
    8000564c:	a83d                	j	8000568a <sys_link+0x13c>
    iunlockput(dp);
    8000564e:	854a                	mv	a0,s2
    80005650:	ffffe097          	auipc	ra,0xffffe
    80005654:	4f6080e7          	jalr	1270(ra) # 80003b46 <iunlockput>
  ilock(ip);
    80005658:	8526                	mv	a0,s1
    8000565a:	ffffe097          	auipc	ra,0xffffe
    8000565e:	28a080e7          	jalr	650(ra) # 800038e4 <ilock>
  ip->nlink--;
    80005662:	04a4d783          	lhu	a5,74(s1)
    80005666:	37fd                	addiw	a5,a5,-1
    80005668:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000566c:	8526                	mv	a0,s1
    8000566e:	ffffe097          	auipc	ra,0xffffe
    80005672:	1aa080e7          	jalr	426(ra) # 80003818 <iupdate>
  iunlockput(ip);
    80005676:	8526                	mv	a0,s1
    80005678:	ffffe097          	auipc	ra,0xffffe
    8000567c:	4ce080e7          	jalr	1230(ra) # 80003b46 <iunlockput>
  end_op();
    80005680:	fffff097          	auipc	ra,0xfffff
    80005684:	cbe080e7          	jalr	-834(ra) # 8000433e <end_op>
  return -1;
    80005688:	57fd                	li	a5,-1
}
    8000568a:	853e                	mv	a0,a5
    8000568c:	70b2                	ld	ra,296(sp)
    8000568e:	7412                	ld	s0,288(sp)
    80005690:	64f2                	ld	s1,280(sp)
    80005692:	6952                	ld	s2,272(sp)
    80005694:	6155                	addi	sp,sp,304
    80005696:	8082                	ret

0000000080005698 <sys_unlink>:
{
    80005698:	7151                	addi	sp,sp,-240
    8000569a:	f586                	sd	ra,232(sp)
    8000569c:	f1a2                	sd	s0,224(sp)
    8000569e:	eda6                	sd	s1,216(sp)
    800056a0:	e9ca                	sd	s2,208(sp)
    800056a2:	e5ce                	sd	s3,200(sp)
    800056a4:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800056a6:	08000613          	li	a2,128
    800056aa:	f3040593          	addi	a1,s0,-208
    800056ae:	4501                	li	a0,0
    800056b0:	ffffd097          	auipc	ra,0xffffd
    800056b4:	638080e7          	jalr	1592(ra) # 80002ce8 <argstr>
    800056b8:	18054163          	bltz	a0,8000583a <sys_unlink+0x1a2>
  begin_op();
    800056bc:	fffff097          	auipc	ra,0xfffff
    800056c0:	c04080e7          	jalr	-1020(ra) # 800042c0 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800056c4:	fb040593          	addi	a1,s0,-80
    800056c8:	f3040513          	addi	a0,s0,-208
    800056cc:	fffff097          	auipc	ra,0xfffff
    800056d0:	9f2080e7          	jalr	-1550(ra) # 800040be <nameiparent>
    800056d4:	84aa                	mv	s1,a0
    800056d6:	c979                	beqz	a0,800057ac <sys_unlink+0x114>
  ilock(dp);
    800056d8:	ffffe097          	auipc	ra,0xffffe
    800056dc:	20c080e7          	jalr	524(ra) # 800038e4 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800056e0:	00003597          	auipc	a1,0x3
    800056e4:	03858593          	addi	a1,a1,56 # 80008718 <syscalls+0x2d0>
    800056e8:	fb040513          	addi	a0,s0,-80
    800056ec:	ffffe097          	auipc	ra,0xffffe
    800056f0:	6c2080e7          	jalr	1730(ra) # 80003dae <namecmp>
    800056f4:	14050a63          	beqz	a0,80005848 <sys_unlink+0x1b0>
    800056f8:	00003597          	auipc	a1,0x3
    800056fc:	02858593          	addi	a1,a1,40 # 80008720 <syscalls+0x2d8>
    80005700:	fb040513          	addi	a0,s0,-80
    80005704:	ffffe097          	auipc	ra,0xffffe
    80005708:	6aa080e7          	jalr	1706(ra) # 80003dae <namecmp>
    8000570c:	12050e63          	beqz	a0,80005848 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005710:	f2c40613          	addi	a2,s0,-212
    80005714:	fb040593          	addi	a1,s0,-80
    80005718:	8526                	mv	a0,s1
    8000571a:	ffffe097          	auipc	ra,0xffffe
    8000571e:	6ae080e7          	jalr	1710(ra) # 80003dc8 <dirlookup>
    80005722:	892a                	mv	s2,a0
    80005724:	12050263          	beqz	a0,80005848 <sys_unlink+0x1b0>
  ilock(ip);
    80005728:	ffffe097          	auipc	ra,0xffffe
    8000572c:	1bc080e7          	jalr	444(ra) # 800038e4 <ilock>
  if(ip->nlink < 1)
    80005730:	04a91783          	lh	a5,74(s2)
    80005734:	08f05263          	blez	a5,800057b8 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005738:	04491703          	lh	a4,68(s2)
    8000573c:	4785                	li	a5,1
    8000573e:	08f70563          	beq	a4,a5,800057c8 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005742:	4641                	li	a2,16
    80005744:	4581                	li	a1,0
    80005746:	fc040513          	addi	a0,s0,-64
    8000574a:	ffffb097          	auipc	ra,0xffffb
    8000574e:	582080e7          	jalr	1410(ra) # 80000ccc <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005752:	4741                	li	a4,16
    80005754:	f2c42683          	lw	a3,-212(s0)
    80005758:	fc040613          	addi	a2,s0,-64
    8000575c:	4581                	li	a1,0
    8000575e:	8526                	mv	a0,s1
    80005760:	ffffe097          	auipc	ra,0xffffe
    80005764:	530080e7          	jalr	1328(ra) # 80003c90 <writei>
    80005768:	47c1                	li	a5,16
    8000576a:	0af51563          	bne	a0,a5,80005814 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    8000576e:	04491703          	lh	a4,68(s2)
    80005772:	4785                	li	a5,1
    80005774:	0af70863          	beq	a4,a5,80005824 <sys_unlink+0x18c>
  iunlockput(dp);
    80005778:	8526                	mv	a0,s1
    8000577a:	ffffe097          	auipc	ra,0xffffe
    8000577e:	3cc080e7          	jalr	972(ra) # 80003b46 <iunlockput>
  ip->nlink--;
    80005782:	04a95783          	lhu	a5,74(s2)
    80005786:	37fd                	addiw	a5,a5,-1
    80005788:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000578c:	854a                	mv	a0,s2
    8000578e:	ffffe097          	auipc	ra,0xffffe
    80005792:	08a080e7          	jalr	138(ra) # 80003818 <iupdate>
  iunlockput(ip);
    80005796:	854a                	mv	a0,s2
    80005798:	ffffe097          	auipc	ra,0xffffe
    8000579c:	3ae080e7          	jalr	942(ra) # 80003b46 <iunlockput>
  end_op();
    800057a0:	fffff097          	auipc	ra,0xfffff
    800057a4:	b9e080e7          	jalr	-1122(ra) # 8000433e <end_op>
  return 0;
    800057a8:	4501                	li	a0,0
    800057aa:	a84d                	j	8000585c <sys_unlink+0x1c4>
    end_op();
    800057ac:	fffff097          	auipc	ra,0xfffff
    800057b0:	b92080e7          	jalr	-1134(ra) # 8000433e <end_op>
    return -1;
    800057b4:	557d                	li	a0,-1
    800057b6:	a05d                	j	8000585c <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800057b8:	00003517          	auipc	a0,0x3
    800057bc:	f9050513          	addi	a0,a0,-112 # 80008748 <syscalls+0x300>
    800057c0:	ffffb097          	auipc	ra,0xffffb
    800057c4:	d7a080e7          	jalr	-646(ra) # 8000053a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800057c8:	04c92703          	lw	a4,76(s2)
    800057cc:	02000793          	li	a5,32
    800057d0:	f6e7f9e3          	bgeu	a5,a4,80005742 <sys_unlink+0xaa>
    800057d4:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057d8:	4741                	li	a4,16
    800057da:	86ce                	mv	a3,s3
    800057dc:	f1840613          	addi	a2,s0,-232
    800057e0:	4581                	li	a1,0
    800057e2:	854a                	mv	a0,s2
    800057e4:	ffffe097          	auipc	ra,0xffffe
    800057e8:	3b4080e7          	jalr	948(ra) # 80003b98 <readi>
    800057ec:	47c1                	li	a5,16
    800057ee:	00f51b63          	bne	a0,a5,80005804 <sys_unlink+0x16c>
    if(de.inum != 0)
    800057f2:	f1845783          	lhu	a5,-232(s0)
    800057f6:	e7a1                	bnez	a5,8000583e <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800057f8:	29c1                	addiw	s3,s3,16
    800057fa:	04c92783          	lw	a5,76(s2)
    800057fe:	fcf9ede3          	bltu	s3,a5,800057d8 <sys_unlink+0x140>
    80005802:	b781                	j	80005742 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005804:	00003517          	auipc	a0,0x3
    80005808:	f5c50513          	addi	a0,a0,-164 # 80008760 <syscalls+0x318>
    8000580c:	ffffb097          	auipc	ra,0xffffb
    80005810:	d2e080e7          	jalr	-722(ra) # 8000053a <panic>
    panic("unlink: writei");
    80005814:	00003517          	auipc	a0,0x3
    80005818:	f6450513          	addi	a0,a0,-156 # 80008778 <syscalls+0x330>
    8000581c:	ffffb097          	auipc	ra,0xffffb
    80005820:	d1e080e7          	jalr	-738(ra) # 8000053a <panic>
    dp->nlink--;
    80005824:	04a4d783          	lhu	a5,74(s1)
    80005828:	37fd                	addiw	a5,a5,-1
    8000582a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000582e:	8526                	mv	a0,s1
    80005830:	ffffe097          	auipc	ra,0xffffe
    80005834:	fe8080e7          	jalr	-24(ra) # 80003818 <iupdate>
    80005838:	b781                	j	80005778 <sys_unlink+0xe0>
    return -1;
    8000583a:	557d                	li	a0,-1
    8000583c:	a005                	j	8000585c <sys_unlink+0x1c4>
    iunlockput(ip);
    8000583e:	854a                	mv	a0,s2
    80005840:	ffffe097          	auipc	ra,0xffffe
    80005844:	306080e7          	jalr	774(ra) # 80003b46 <iunlockput>
  iunlockput(dp);
    80005848:	8526                	mv	a0,s1
    8000584a:	ffffe097          	auipc	ra,0xffffe
    8000584e:	2fc080e7          	jalr	764(ra) # 80003b46 <iunlockput>
  end_op();
    80005852:	fffff097          	auipc	ra,0xfffff
    80005856:	aec080e7          	jalr	-1300(ra) # 8000433e <end_op>
  return -1;
    8000585a:	557d                	li	a0,-1
}
    8000585c:	70ae                	ld	ra,232(sp)
    8000585e:	740e                	ld	s0,224(sp)
    80005860:	64ee                	ld	s1,216(sp)
    80005862:	694e                	ld	s2,208(sp)
    80005864:	69ae                	ld	s3,200(sp)
    80005866:	616d                	addi	sp,sp,240
    80005868:	8082                	ret

000000008000586a <sys_open>:

uint64
sys_open(void)
{
    8000586a:	7131                	addi	sp,sp,-192
    8000586c:	fd06                	sd	ra,184(sp)
    8000586e:	f922                	sd	s0,176(sp)
    80005870:	f526                	sd	s1,168(sp)
    80005872:	f14a                	sd	s2,160(sp)
    80005874:	ed4e                	sd	s3,152(sp)
    80005876:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005878:	08000613          	li	a2,128
    8000587c:	f5040593          	addi	a1,s0,-176
    80005880:	4501                	li	a0,0
    80005882:	ffffd097          	auipc	ra,0xffffd
    80005886:	466080e7          	jalr	1126(ra) # 80002ce8 <argstr>
    return -1;
    8000588a:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000588c:	0c054163          	bltz	a0,8000594e <sys_open+0xe4>
    80005890:	f4c40593          	addi	a1,s0,-180
    80005894:	4505                	li	a0,1
    80005896:	ffffd097          	auipc	ra,0xffffd
    8000589a:	40e080e7          	jalr	1038(ra) # 80002ca4 <argint>
    8000589e:	0a054863          	bltz	a0,8000594e <sys_open+0xe4>

  begin_op();
    800058a2:	fffff097          	auipc	ra,0xfffff
    800058a6:	a1e080e7          	jalr	-1506(ra) # 800042c0 <begin_op>

  if(omode & O_CREATE){
    800058aa:	f4c42783          	lw	a5,-180(s0)
    800058ae:	2007f793          	andi	a5,a5,512
    800058b2:	cbdd                	beqz	a5,80005968 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800058b4:	4681                	li	a3,0
    800058b6:	4601                	li	a2,0
    800058b8:	4589                	li	a1,2
    800058ba:	f5040513          	addi	a0,s0,-176
    800058be:	00000097          	auipc	ra,0x0
    800058c2:	970080e7          	jalr	-1680(ra) # 8000522e <create>
    800058c6:	892a                	mv	s2,a0
    if(ip == 0){
    800058c8:	c959                	beqz	a0,8000595e <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800058ca:	04491703          	lh	a4,68(s2)
    800058ce:	478d                	li	a5,3
    800058d0:	00f71763          	bne	a4,a5,800058de <sys_open+0x74>
    800058d4:	04695703          	lhu	a4,70(s2)
    800058d8:	47a5                	li	a5,9
    800058da:	0ce7ec63          	bltu	a5,a4,800059b2 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800058de:	fffff097          	auipc	ra,0xfffff
    800058e2:	dee080e7          	jalr	-530(ra) # 800046cc <filealloc>
    800058e6:	89aa                	mv	s3,a0
    800058e8:	10050263          	beqz	a0,800059ec <sys_open+0x182>
    800058ec:	00000097          	auipc	ra,0x0
    800058f0:	900080e7          	jalr	-1792(ra) # 800051ec <fdalloc>
    800058f4:	84aa                	mv	s1,a0
    800058f6:	0e054663          	bltz	a0,800059e2 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800058fa:	04491703          	lh	a4,68(s2)
    800058fe:	478d                	li	a5,3
    80005900:	0cf70463          	beq	a4,a5,800059c8 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005904:	4789                	li	a5,2
    80005906:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    8000590a:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000590e:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005912:	f4c42783          	lw	a5,-180(s0)
    80005916:	0017c713          	xori	a4,a5,1
    8000591a:	8b05                	andi	a4,a4,1
    8000591c:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005920:	0037f713          	andi	a4,a5,3
    80005924:	00e03733          	snez	a4,a4
    80005928:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000592c:	4007f793          	andi	a5,a5,1024
    80005930:	c791                	beqz	a5,8000593c <sys_open+0xd2>
    80005932:	04491703          	lh	a4,68(s2)
    80005936:	4789                	li	a5,2
    80005938:	08f70f63          	beq	a4,a5,800059d6 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    8000593c:	854a                	mv	a0,s2
    8000593e:	ffffe097          	auipc	ra,0xffffe
    80005942:	068080e7          	jalr	104(ra) # 800039a6 <iunlock>
  end_op();
    80005946:	fffff097          	auipc	ra,0xfffff
    8000594a:	9f8080e7          	jalr	-1544(ra) # 8000433e <end_op>

  return fd;
}
    8000594e:	8526                	mv	a0,s1
    80005950:	70ea                	ld	ra,184(sp)
    80005952:	744a                	ld	s0,176(sp)
    80005954:	74aa                	ld	s1,168(sp)
    80005956:	790a                	ld	s2,160(sp)
    80005958:	69ea                	ld	s3,152(sp)
    8000595a:	6129                	addi	sp,sp,192
    8000595c:	8082                	ret
      end_op();
    8000595e:	fffff097          	auipc	ra,0xfffff
    80005962:	9e0080e7          	jalr	-1568(ra) # 8000433e <end_op>
      return -1;
    80005966:	b7e5                	j	8000594e <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005968:	f5040513          	addi	a0,s0,-176
    8000596c:	ffffe097          	auipc	ra,0xffffe
    80005970:	734080e7          	jalr	1844(ra) # 800040a0 <namei>
    80005974:	892a                	mv	s2,a0
    80005976:	c905                	beqz	a0,800059a6 <sys_open+0x13c>
    ilock(ip);
    80005978:	ffffe097          	auipc	ra,0xffffe
    8000597c:	f6c080e7          	jalr	-148(ra) # 800038e4 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005980:	04491703          	lh	a4,68(s2)
    80005984:	4785                	li	a5,1
    80005986:	f4f712e3          	bne	a4,a5,800058ca <sys_open+0x60>
    8000598a:	f4c42783          	lw	a5,-180(s0)
    8000598e:	dba1                	beqz	a5,800058de <sys_open+0x74>
      iunlockput(ip);
    80005990:	854a                	mv	a0,s2
    80005992:	ffffe097          	auipc	ra,0xffffe
    80005996:	1b4080e7          	jalr	436(ra) # 80003b46 <iunlockput>
      end_op();
    8000599a:	fffff097          	auipc	ra,0xfffff
    8000599e:	9a4080e7          	jalr	-1628(ra) # 8000433e <end_op>
      return -1;
    800059a2:	54fd                	li	s1,-1
    800059a4:	b76d                	j	8000594e <sys_open+0xe4>
      end_op();
    800059a6:	fffff097          	auipc	ra,0xfffff
    800059aa:	998080e7          	jalr	-1640(ra) # 8000433e <end_op>
      return -1;
    800059ae:	54fd                	li	s1,-1
    800059b0:	bf79                	j	8000594e <sys_open+0xe4>
    iunlockput(ip);
    800059b2:	854a                	mv	a0,s2
    800059b4:	ffffe097          	auipc	ra,0xffffe
    800059b8:	192080e7          	jalr	402(ra) # 80003b46 <iunlockput>
    end_op();
    800059bc:	fffff097          	auipc	ra,0xfffff
    800059c0:	982080e7          	jalr	-1662(ra) # 8000433e <end_op>
    return -1;
    800059c4:	54fd                	li	s1,-1
    800059c6:	b761                	j	8000594e <sys_open+0xe4>
    f->type = FD_DEVICE;
    800059c8:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800059cc:	04691783          	lh	a5,70(s2)
    800059d0:	02f99223          	sh	a5,36(s3)
    800059d4:	bf2d                	j	8000590e <sys_open+0xa4>
    itrunc(ip);
    800059d6:	854a                	mv	a0,s2
    800059d8:	ffffe097          	auipc	ra,0xffffe
    800059dc:	01a080e7          	jalr	26(ra) # 800039f2 <itrunc>
    800059e0:	bfb1                	j	8000593c <sys_open+0xd2>
      fileclose(f);
    800059e2:	854e                	mv	a0,s3
    800059e4:	fffff097          	auipc	ra,0xfffff
    800059e8:	da4080e7          	jalr	-604(ra) # 80004788 <fileclose>
    iunlockput(ip);
    800059ec:	854a                	mv	a0,s2
    800059ee:	ffffe097          	auipc	ra,0xffffe
    800059f2:	158080e7          	jalr	344(ra) # 80003b46 <iunlockput>
    end_op();
    800059f6:	fffff097          	auipc	ra,0xfffff
    800059fa:	948080e7          	jalr	-1720(ra) # 8000433e <end_op>
    return -1;
    800059fe:	54fd                	li	s1,-1
    80005a00:	b7b9                	j	8000594e <sys_open+0xe4>

0000000080005a02 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005a02:	7175                	addi	sp,sp,-144
    80005a04:	e506                	sd	ra,136(sp)
    80005a06:	e122                	sd	s0,128(sp)
    80005a08:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005a0a:	fffff097          	auipc	ra,0xfffff
    80005a0e:	8b6080e7          	jalr	-1866(ra) # 800042c0 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005a12:	08000613          	li	a2,128
    80005a16:	f7040593          	addi	a1,s0,-144
    80005a1a:	4501                	li	a0,0
    80005a1c:	ffffd097          	auipc	ra,0xffffd
    80005a20:	2cc080e7          	jalr	716(ra) # 80002ce8 <argstr>
    80005a24:	02054963          	bltz	a0,80005a56 <sys_mkdir+0x54>
    80005a28:	4681                	li	a3,0
    80005a2a:	4601                	li	a2,0
    80005a2c:	4585                	li	a1,1
    80005a2e:	f7040513          	addi	a0,s0,-144
    80005a32:	fffff097          	auipc	ra,0xfffff
    80005a36:	7fc080e7          	jalr	2044(ra) # 8000522e <create>
    80005a3a:	cd11                	beqz	a0,80005a56 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a3c:	ffffe097          	auipc	ra,0xffffe
    80005a40:	10a080e7          	jalr	266(ra) # 80003b46 <iunlockput>
  end_op();
    80005a44:	fffff097          	auipc	ra,0xfffff
    80005a48:	8fa080e7          	jalr	-1798(ra) # 8000433e <end_op>
  return 0;
    80005a4c:	4501                	li	a0,0
}
    80005a4e:	60aa                	ld	ra,136(sp)
    80005a50:	640a                	ld	s0,128(sp)
    80005a52:	6149                	addi	sp,sp,144
    80005a54:	8082                	ret
    end_op();
    80005a56:	fffff097          	auipc	ra,0xfffff
    80005a5a:	8e8080e7          	jalr	-1816(ra) # 8000433e <end_op>
    return -1;
    80005a5e:	557d                	li	a0,-1
    80005a60:	b7fd                	j	80005a4e <sys_mkdir+0x4c>

0000000080005a62 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005a62:	7135                	addi	sp,sp,-160
    80005a64:	ed06                	sd	ra,152(sp)
    80005a66:	e922                	sd	s0,144(sp)
    80005a68:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005a6a:	fffff097          	auipc	ra,0xfffff
    80005a6e:	856080e7          	jalr	-1962(ra) # 800042c0 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a72:	08000613          	li	a2,128
    80005a76:	f7040593          	addi	a1,s0,-144
    80005a7a:	4501                	li	a0,0
    80005a7c:	ffffd097          	auipc	ra,0xffffd
    80005a80:	26c080e7          	jalr	620(ra) # 80002ce8 <argstr>
    80005a84:	04054a63          	bltz	a0,80005ad8 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005a88:	f6c40593          	addi	a1,s0,-148
    80005a8c:	4505                	li	a0,1
    80005a8e:	ffffd097          	auipc	ra,0xffffd
    80005a92:	216080e7          	jalr	534(ra) # 80002ca4 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a96:	04054163          	bltz	a0,80005ad8 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005a9a:	f6840593          	addi	a1,s0,-152
    80005a9e:	4509                	li	a0,2
    80005aa0:	ffffd097          	auipc	ra,0xffffd
    80005aa4:	204080e7          	jalr	516(ra) # 80002ca4 <argint>
     argint(1, &major) < 0 ||
    80005aa8:	02054863          	bltz	a0,80005ad8 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005aac:	f6841683          	lh	a3,-152(s0)
    80005ab0:	f6c41603          	lh	a2,-148(s0)
    80005ab4:	458d                	li	a1,3
    80005ab6:	f7040513          	addi	a0,s0,-144
    80005aba:	fffff097          	auipc	ra,0xfffff
    80005abe:	774080e7          	jalr	1908(ra) # 8000522e <create>
     argint(2, &minor) < 0 ||
    80005ac2:	c919                	beqz	a0,80005ad8 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005ac4:	ffffe097          	auipc	ra,0xffffe
    80005ac8:	082080e7          	jalr	130(ra) # 80003b46 <iunlockput>
  end_op();
    80005acc:	fffff097          	auipc	ra,0xfffff
    80005ad0:	872080e7          	jalr	-1934(ra) # 8000433e <end_op>
  return 0;
    80005ad4:	4501                	li	a0,0
    80005ad6:	a031                	j	80005ae2 <sys_mknod+0x80>
    end_op();
    80005ad8:	fffff097          	auipc	ra,0xfffff
    80005adc:	866080e7          	jalr	-1946(ra) # 8000433e <end_op>
    return -1;
    80005ae0:	557d                	li	a0,-1
}
    80005ae2:	60ea                	ld	ra,152(sp)
    80005ae4:	644a                	ld	s0,144(sp)
    80005ae6:	610d                	addi	sp,sp,160
    80005ae8:	8082                	ret

0000000080005aea <sys_chdir>:

uint64
sys_chdir(void)
{
    80005aea:	7135                	addi	sp,sp,-160
    80005aec:	ed06                	sd	ra,152(sp)
    80005aee:	e922                	sd	s0,144(sp)
    80005af0:	e526                	sd	s1,136(sp)
    80005af2:	e14a                	sd	s2,128(sp)
    80005af4:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005af6:	ffffc097          	auipc	ra,0xffffc
    80005afa:	ea0080e7          	jalr	-352(ra) # 80001996 <myproc>
    80005afe:	892a                	mv	s2,a0
  
  begin_op();
    80005b00:	ffffe097          	auipc	ra,0xffffe
    80005b04:	7c0080e7          	jalr	1984(ra) # 800042c0 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005b08:	08000613          	li	a2,128
    80005b0c:	f6040593          	addi	a1,s0,-160
    80005b10:	4501                	li	a0,0
    80005b12:	ffffd097          	auipc	ra,0xffffd
    80005b16:	1d6080e7          	jalr	470(ra) # 80002ce8 <argstr>
    80005b1a:	04054b63          	bltz	a0,80005b70 <sys_chdir+0x86>
    80005b1e:	f6040513          	addi	a0,s0,-160
    80005b22:	ffffe097          	auipc	ra,0xffffe
    80005b26:	57e080e7          	jalr	1406(ra) # 800040a0 <namei>
    80005b2a:	84aa                	mv	s1,a0
    80005b2c:	c131                	beqz	a0,80005b70 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005b2e:	ffffe097          	auipc	ra,0xffffe
    80005b32:	db6080e7          	jalr	-586(ra) # 800038e4 <ilock>
  if(ip->type != T_DIR){
    80005b36:	04449703          	lh	a4,68(s1)
    80005b3a:	4785                	li	a5,1
    80005b3c:	04f71063          	bne	a4,a5,80005b7c <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005b40:	8526                	mv	a0,s1
    80005b42:	ffffe097          	auipc	ra,0xffffe
    80005b46:	e64080e7          	jalr	-412(ra) # 800039a6 <iunlock>
  iput(p->cwd);
    80005b4a:	16093503          	ld	a0,352(s2)
    80005b4e:	ffffe097          	auipc	ra,0xffffe
    80005b52:	f50080e7          	jalr	-176(ra) # 80003a9e <iput>
  end_op();
    80005b56:	ffffe097          	auipc	ra,0xffffe
    80005b5a:	7e8080e7          	jalr	2024(ra) # 8000433e <end_op>
  p->cwd = ip;
    80005b5e:	16993023          	sd	s1,352(s2)
  return 0;
    80005b62:	4501                	li	a0,0
}
    80005b64:	60ea                	ld	ra,152(sp)
    80005b66:	644a                	ld	s0,144(sp)
    80005b68:	64aa                	ld	s1,136(sp)
    80005b6a:	690a                	ld	s2,128(sp)
    80005b6c:	610d                	addi	sp,sp,160
    80005b6e:	8082                	ret
    end_op();
    80005b70:	ffffe097          	auipc	ra,0xffffe
    80005b74:	7ce080e7          	jalr	1998(ra) # 8000433e <end_op>
    return -1;
    80005b78:	557d                	li	a0,-1
    80005b7a:	b7ed                	j	80005b64 <sys_chdir+0x7a>
    iunlockput(ip);
    80005b7c:	8526                	mv	a0,s1
    80005b7e:	ffffe097          	auipc	ra,0xffffe
    80005b82:	fc8080e7          	jalr	-56(ra) # 80003b46 <iunlockput>
    end_op();
    80005b86:	ffffe097          	auipc	ra,0xffffe
    80005b8a:	7b8080e7          	jalr	1976(ra) # 8000433e <end_op>
    return -1;
    80005b8e:	557d                	li	a0,-1
    80005b90:	bfd1                	j	80005b64 <sys_chdir+0x7a>

0000000080005b92 <sys_exec>:

uint64
sys_exec(void)
{
    80005b92:	7145                	addi	sp,sp,-464
    80005b94:	e786                	sd	ra,456(sp)
    80005b96:	e3a2                	sd	s0,448(sp)
    80005b98:	ff26                	sd	s1,440(sp)
    80005b9a:	fb4a                	sd	s2,432(sp)
    80005b9c:	f74e                	sd	s3,424(sp)
    80005b9e:	f352                	sd	s4,416(sp)
    80005ba0:	ef56                	sd	s5,408(sp)
    80005ba2:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005ba4:	08000613          	li	a2,128
    80005ba8:	f4040593          	addi	a1,s0,-192
    80005bac:	4501                	li	a0,0
    80005bae:	ffffd097          	auipc	ra,0xffffd
    80005bb2:	13a080e7          	jalr	314(ra) # 80002ce8 <argstr>
    return -1;
    80005bb6:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005bb8:	0c054b63          	bltz	a0,80005c8e <sys_exec+0xfc>
    80005bbc:	e3840593          	addi	a1,s0,-456
    80005bc0:	4505                	li	a0,1
    80005bc2:	ffffd097          	auipc	ra,0xffffd
    80005bc6:	104080e7          	jalr	260(ra) # 80002cc6 <argaddr>
    80005bca:	0c054263          	bltz	a0,80005c8e <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    80005bce:	10000613          	li	a2,256
    80005bd2:	4581                	li	a1,0
    80005bd4:	e4040513          	addi	a0,s0,-448
    80005bd8:	ffffb097          	auipc	ra,0xffffb
    80005bdc:	0f4080e7          	jalr	244(ra) # 80000ccc <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005be0:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005be4:	89a6                	mv	s3,s1
    80005be6:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005be8:	02000a13          	li	s4,32
    80005bec:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005bf0:	00391513          	slli	a0,s2,0x3
    80005bf4:	e3040593          	addi	a1,s0,-464
    80005bf8:	e3843783          	ld	a5,-456(s0)
    80005bfc:	953e                	add	a0,a0,a5
    80005bfe:	ffffd097          	auipc	ra,0xffffd
    80005c02:	00c080e7          	jalr	12(ra) # 80002c0a <fetchaddr>
    80005c06:	02054a63          	bltz	a0,80005c3a <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005c0a:	e3043783          	ld	a5,-464(s0)
    80005c0e:	c3b9                	beqz	a5,80005c54 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005c10:	ffffb097          	auipc	ra,0xffffb
    80005c14:	ed0080e7          	jalr	-304(ra) # 80000ae0 <kalloc>
    80005c18:	85aa                	mv	a1,a0
    80005c1a:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005c1e:	cd11                	beqz	a0,80005c3a <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005c20:	6605                	lui	a2,0x1
    80005c22:	e3043503          	ld	a0,-464(s0)
    80005c26:	ffffd097          	auipc	ra,0xffffd
    80005c2a:	036080e7          	jalr	54(ra) # 80002c5c <fetchstr>
    80005c2e:	00054663          	bltz	a0,80005c3a <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005c32:	0905                	addi	s2,s2,1
    80005c34:	09a1                	addi	s3,s3,8
    80005c36:	fb491be3          	bne	s2,s4,80005bec <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c3a:	f4040913          	addi	s2,s0,-192
    80005c3e:	6088                	ld	a0,0(s1)
    80005c40:	c531                	beqz	a0,80005c8c <sys_exec+0xfa>
    kfree(argv[i]);
    80005c42:	ffffb097          	auipc	ra,0xffffb
    80005c46:	da0080e7          	jalr	-608(ra) # 800009e2 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c4a:	04a1                	addi	s1,s1,8
    80005c4c:	ff2499e3          	bne	s1,s2,80005c3e <sys_exec+0xac>
  return -1;
    80005c50:	597d                	li	s2,-1
    80005c52:	a835                	j	80005c8e <sys_exec+0xfc>
      argv[i] = 0;
    80005c54:	0a8e                	slli	s5,s5,0x3
    80005c56:	fc0a8793          	addi	a5,s5,-64 # ffffffffffffefc0 <end+0xffffffff7ffd8fc0>
    80005c5a:	00878ab3          	add	s5,a5,s0
    80005c5e:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005c62:	e4040593          	addi	a1,s0,-448
    80005c66:	f4040513          	addi	a0,s0,-192
    80005c6a:	fffff097          	auipc	ra,0xfffff
    80005c6e:	172080e7          	jalr	370(ra) # 80004ddc <exec>
    80005c72:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c74:	f4040993          	addi	s3,s0,-192
    80005c78:	6088                	ld	a0,0(s1)
    80005c7a:	c911                	beqz	a0,80005c8e <sys_exec+0xfc>
    kfree(argv[i]);
    80005c7c:	ffffb097          	auipc	ra,0xffffb
    80005c80:	d66080e7          	jalr	-666(ra) # 800009e2 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c84:	04a1                	addi	s1,s1,8
    80005c86:	ff3499e3          	bne	s1,s3,80005c78 <sys_exec+0xe6>
    80005c8a:	a011                	j	80005c8e <sys_exec+0xfc>
  return -1;
    80005c8c:	597d                	li	s2,-1
}
    80005c8e:	854a                	mv	a0,s2
    80005c90:	60be                	ld	ra,456(sp)
    80005c92:	641e                	ld	s0,448(sp)
    80005c94:	74fa                	ld	s1,440(sp)
    80005c96:	795a                	ld	s2,432(sp)
    80005c98:	79ba                	ld	s3,424(sp)
    80005c9a:	7a1a                	ld	s4,416(sp)
    80005c9c:	6afa                	ld	s5,408(sp)
    80005c9e:	6179                	addi	sp,sp,464
    80005ca0:	8082                	ret

0000000080005ca2 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005ca2:	7139                	addi	sp,sp,-64
    80005ca4:	fc06                	sd	ra,56(sp)
    80005ca6:	f822                	sd	s0,48(sp)
    80005ca8:	f426                	sd	s1,40(sp)
    80005caa:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005cac:	ffffc097          	auipc	ra,0xffffc
    80005cb0:	cea080e7          	jalr	-790(ra) # 80001996 <myproc>
    80005cb4:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005cb6:	fd840593          	addi	a1,s0,-40
    80005cba:	4501                	li	a0,0
    80005cbc:	ffffd097          	auipc	ra,0xffffd
    80005cc0:	00a080e7          	jalr	10(ra) # 80002cc6 <argaddr>
    return -1;
    80005cc4:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005cc6:	0e054063          	bltz	a0,80005da6 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005cca:	fc840593          	addi	a1,s0,-56
    80005cce:	fd040513          	addi	a0,s0,-48
    80005cd2:	fffff097          	auipc	ra,0xfffff
    80005cd6:	de6080e7          	jalr	-538(ra) # 80004ab8 <pipealloc>
    return -1;
    80005cda:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005cdc:	0c054563          	bltz	a0,80005da6 <sys_pipe+0x104>
  fd0 = -1;
    80005ce0:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005ce4:	fd043503          	ld	a0,-48(s0)
    80005ce8:	fffff097          	auipc	ra,0xfffff
    80005cec:	504080e7          	jalr	1284(ra) # 800051ec <fdalloc>
    80005cf0:	fca42223          	sw	a0,-60(s0)
    80005cf4:	08054c63          	bltz	a0,80005d8c <sys_pipe+0xea>
    80005cf8:	fc843503          	ld	a0,-56(s0)
    80005cfc:	fffff097          	auipc	ra,0xfffff
    80005d00:	4f0080e7          	jalr	1264(ra) # 800051ec <fdalloc>
    80005d04:	fca42023          	sw	a0,-64(s0)
    80005d08:	06054963          	bltz	a0,80005d7a <sys_pipe+0xd8>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d0c:	4691                	li	a3,4
    80005d0e:	fc440613          	addi	a2,s0,-60
    80005d12:	fd843583          	ld	a1,-40(s0)
    80005d16:	70a8                	ld	a0,96(s1)
    80005d18:	ffffc097          	auipc	ra,0xffffc
    80005d1c:	942080e7          	jalr	-1726(ra) # 8000165a <copyout>
    80005d20:	02054063          	bltz	a0,80005d40 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005d24:	4691                	li	a3,4
    80005d26:	fc040613          	addi	a2,s0,-64
    80005d2a:	fd843583          	ld	a1,-40(s0)
    80005d2e:	0591                	addi	a1,a1,4
    80005d30:	70a8                	ld	a0,96(s1)
    80005d32:	ffffc097          	auipc	ra,0xffffc
    80005d36:	928080e7          	jalr	-1752(ra) # 8000165a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005d3a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d3c:	06055563          	bgez	a0,80005da6 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005d40:	fc442783          	lw	a5,-60(s0)
    80005d44:	07f1                	addi	a5,a5,28
    80005d46:	078e                	slli	a5,a5,0x3
    80005d48:	97a6                	add	a5,a5,s1
    80005d4a:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005d4e:	fc042783          	lw	a5,-64(s0)
    80005d52:	07f1                	addi	a5,a5,28
    80005d54:	078e                	slli	a5,a5,0x3
    80005d56:	00f48533          	add	a0,s1,a5
    80005d5a:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005d5e:	fd043503          	ld	a0,-48(s0)
    80005d62:	fffff097          	auipc	ra,0xfffff
    80005d66:	a26080e7          	jalr	-1498(ra) # 80004788 <fileclose>
    fileclose(wf);
    80005d6a:	fc843503          	ld	a0,-56(s0)
    80005d6e:	fffff097          	auipc	ra,0xfffff
    80005d72:	a1a080e7          	jalr	-1510(ra) # 80004788 <fileclose>
    return -1;
    80005d76:	57fd                	li	a5,-1
    80005d78:	a03d                	j	80005da6 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005d7a:	fc442783          	lw	a5,-60(s0)
    80005d7e:	0007c763          	bltz	a5,80005d8c <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005d82:	07f1                	addi	a5,a5,28
    80005d84:	078e                	slli	a5,a5,0x3
    80005d86:	97a6                	add	a5,a5,s1
    80005d88:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005d8c:	fd043503          	ld	a0,-48(s0)
    80005d90:	fffff097          	auipc	ra,0xfffff
    80005d94:	9f8080e7          	jalr	-1544(ra) # 80004788 <fileclose>
    fileclose(wf);
    80005d98:	fc843503          	ld	a0,-56(s0)
    80005d9c:	fffff097          	auipc	ra,0xfffff
    80005da0:	9ec080e7          	jalr	-1556(ra) # 80004788 <fileclose>
    return -1;
    80005da4:	57fd                	li	a5,-1
}
    80005da6:	853e                	mv	a0,a5
    80005da8:	70e2                	ld	ra,56(sp)
    80005daa:	7442                	ld	s0,48(sp)
    80005dac:	74a2                	ld	s1,40(sp)
    80005dae:	6121                	addi	sp,sp,64
    80005db0:	8082                	ret
	...

0000000080005dc0 <kernelvec>:
    80005dc0:	7111                	addi	sp,sp,-256
    80005dc2:	e006                	sd	ra,0(sp)
    80005dc4:	e40a                	sd	sp,8(sp)
    80005dc6:	e80e                	sd	gp,16(sp)
    80005dc8:	ec12                	sd	tp,24(sp)
    80005dca:	f016                	sd	t0,32(sp)
    80005dcc:	f41a                	sd	t1,40(sp)
    80005dce:	f81e                	sd	t2,48(sp)
    80005dd0:	fc22                	sd	s0,56(sp)
    80005dd2:	e0a6                	sd	s1,64(sp)
    80005dd4:	e4aa                	sd	a0,72(sp)
    80005dd6:	e8ae                	sd	a1,80(sp)
    80005dd8:	ecb2                	sd	a2,88(sp)
    80005dda:	f0b6                	sd	a3,96(sp)
    80005ddc:	f4ba                	sd	a4,104(sp)
    80005dde:	f8be                	sd	a5,112(sp)
    80005de0:	fcc2                	sd	a6,120(sp)
    80005de2:	e146                	sd	a7,128(sp)
    80005de4:	e54a                	sd	s2,136(sp)
    80005de6:	e94e                	sd	s3,144(sp)
    80005de8:	ed52                	sd	s4,152(sp)
    80005dea:	f156                	sd	s5,160(sp)
    80005dec:	f55a                	sd	s6,168(sp)
    80005dee:	f95e                	sd	s7,176(sp)
    80005df0:	fd62                	sd	s8,184(sp)
    80005df2:	e1e6                	sd	s9,192(sp)
    80005df4:	e5ea                	sd	s10,200(sp)
    80005df6:	e9ee                	sd	s11,208(sp)
    80005df8:	edf2                	sd	t3,216(sp)
    80005dfa:	f1f6                	sd	t4,224(sp)
    80005dfc:	f5fa                	sd	t5,232(sp)
    80005dfe:	f9fe                	sd	t6,240(sp)
    80005e00:	cbffc0ef          	jal	ra,80002abe <kerneltrap>
    80005e04:	6082                	ld	ra,0(sp)
    80005e06:	6122                	ld	sp,8(sp)
    80005e08:	61c2                	ld	gp,16(sp)
    80005e0a:	7282                	ld	t0,32(sp)
    80005e0c:	7322                	ld	t1,40(sp)
    80005e0e:	73c2                	ld	t2,48(sp)
    80005e10:	7462                	ld	s0,56(sp)
    80005e12:	6486                	ld	s1,64(sp)
    80005e14:	6526                	ld	a0,72(sp)
    80005e16:	65c6                	ld	a1,80(sp)
    80005e18:	6666                	ld	a2,88(sp)
    80005e1a:	7686                	ld	a3,96(sp)
    80005e1c:	7726                	ld	a4,104(sp)
    80005e1e:	77c6                	ld	a5,112(sp)
    80005e20:	7866                	ld	a6,120(sp)
    80005e22:	688a                	ld	a7,128(sp)
    80005e24:	692a                	ld	s2,136(sp)
    80005e26:	69ca                	ld	s3,144(sp)
    80005e28:	6a6a                	ld	s4,152(sp)
    80005e2a:	7a8a                	ld	s5,160(sp)
    80005e2c:	7b2a                	ld	s6,168(sp)
    80005e2e:	7bca                	ld	s7,176(sp)
    80005e30:	7c6a                	ld	s8,184(sp)
    80005e32:	6c8e                	ld	s9,192(sp)
    80005e34:	6d2e                	ld	s10,200(sp)
    80005e36:	6dce                	ld	s11,208(sp)
    80005e38:	6e6e                	ld	t3,216(sp)
    80005e3a:	7e8e                	ld	t4,224(sp)
    80005e3c:	7f2e                	ld	t5,232(sp)
    80005e3e:	7fce                	ld	t6,240(sp)
    80005e40:	6111                	addi	sp,sp,256
    80005e42:	10200073          	sret
    80005e46:	00000013          	nop
    80005e4a:	00000013          	nop
    80005e4e:	0001                	nop

0000000080005e50 <timervec>:
    80005e50:	34051573          	csrrw	a0,mscratch,a0
    80005e54:	e10c                	sd	a1,0(a0)
    80005e56:	e510                	sd	a2,8(a0)
    80005e58:	e914                	sd	a3,16(a0)
    80005e5a:	6d0c                	ld	a1,24(a0)
    80005e5c:	7110                	ld	a2,32(a0)
    80005e5e:	6194                	ld	a3,0(a1)
    80005e60:	96b2                	add	a3,a3,a2
    80005e62:	e194                	sd	a3,0(a1)
    80005e64:	4589                	li	a1,2
    80005e66:	14459073          	csrw	sip,a1
    80005e6a:	6914                	ld	a3,16(a0)
    80005e6c:	6510                	ld	a2,8(a0)
    80005e6e:	610c                	ld	a1,0(a0)
    80005e70:	34051573          	csrrw	a0,mscratch,a0
    80005e74:	30200073          	mret
	...

0000000080005e7a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005e7a:	1141                	addi	sp,sp,-16
    80005e7c:	e422                	sd	s0,8(sp)
    80005e7e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005e80:	0c0007b7          	lui	a5,0xc000
    80005e84:	4705                	li	a4,1
    80005e86:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005e88:	c3d8                	sw	a4,4(a5)
}
    80005e8a:	6422                	ld	s0,8(sp)
    80005e8c:	0141                	addi	sp,sp,16
    80005e8e:	8082                	ret

0000000080005e90 <plicinithart>:

void
plicinithart(void)
{
    80005e90:	1141                	addi	sp,sp,-16
    80005e92:	e406                	sd	ra,8(sp)
    80005e94:	e022                	sd	s0,0(sp)
    80005e96:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005e98:	ffffc097          	auipc	ra,0xffffc
    80005e9c:	ad2080e7          	jalr	-1326(ra) # 8000196a <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005ea0:	0085171b          	slliw	a4,a0,0x8
    80005ea4:	0c0027b7          	lui	a5,0xc002
    80005ea8:	97ba                	add	a5,a5,a4
    80005eaa:	40200713          	li	a4,1026
    80005eae:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005eb2:	00d5151b          	slliw	a0,a0,0xd
    80005eb6:	0c2017b7          	lui	a5,0xc201
    80005eba:	97aa                	add	a5,a5,a0
    80005ebc:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005ec0:	60a2                	ld	ra,8(sp)
    80005ec2:	6402                	ld	s0,0(sp)
    80005ec4:	0141                	addi	sp,sp,16
    80005ec6:	8082                	ret

0000000080005ec8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005ec8:	1141                	addi	sp,sp,-16
    80005eca:	e406                	sd	ra,8(sp)
    80005ecc:	e022                	sd	s0,0(sp)
    80005ece:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ed0:	ffffc097          	auipc	ra,0xffffc
    80005ed4:	a9a080e7          	jalr	-1382(ra) # 8000196a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005ed8:	00d5151b          	slliw	a0,a0,0xd
    80005edc:	0c2017b7          	lui	a5,0xc201
    80005ee0:	97aa                	add	a5,a5,a0
  return irq;
}
    80005ee2:	43c8                	lw	a0,4(a5)
    80005ee4:	60a2                	ld	ra,8(sp)
    80005ee6:	6402                	ld	s0,0(sp)
    80005ee8:	0141                	addi	sp,sp,16
    80005eea:	8082                	ret

0000000080005eec <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005eec:	1101                	addi	sp,sp,-32
    80005eee:	ec06                	sd	ra,24(sp)
    80005ef0:	e822                	sd	s0,16(sp)
    80005ef2:	e426                	sd	s1,8(sp)
    80005ef4:	1000                	addi	s0,sp,32
    80005ef6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005ef8:	ffffc097          	auipc	ra,0xffffc
    80005efc:	a72080e7          	jalr	-1422(ra) # 8000196a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005f00:	00d5151b          	slliw	a0,a0,0xd
    80005f04:	0c2017b7          	lui	a5,0xc201
    80005f08:	97aa                	add	a5,a5,a0
    80005f0a:	c3c4                	sw	s1,4(a5)
}
    80005f0c:	60e2                	ld	ra,24(sp)
    80005f0e:	6442                	ld	s0,16(sp)
    80005f10:	64a2                	ld	s1,8(sp)
    80005f12:	6105                	addi	sp,sp,32
    80005f14:	8082                	ret

0000000080005f16 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005f16:	1141                	addi	sp,sp,-16
    80005f18:	e406                	sd	ra,8(sp)
    80005f1a:	e022                	sd	s0,0(sp)
    80005f1c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005f1e:	479d                	li	a5,7
    80005f20:	06a7c863          	blt	a5,a0,80005f90 <free_desc+0x7a>
    panic("free_desc 1");
  if(disk.free[i])
    80005f24:	0001d717          	auipc	a4,0x1d
    80005f28:	0dc70713          	addi	a4,a4,220 # 80023000 <disk>
    80005f2c:	972a                	add	a4,a4,a0
    80005f2e:	6789                	lui	a5,0x2
    80005f30:	97ba                	add	a5,a5,a4
    80005f32:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005f36:	e7ad                	bnez	a5,80005fa0 <free_desc+0x8a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005f38:	00451793          	slli	a5,a0,0x4
    80005f3c:	0001f717          	auipc	a4,0x1f
    80005f40:	0c470713          	addi	a4,a4,196 # 80025000 <disk+0x2000>
    80005f44:	6314                	ld	a3,0(a4)
    80005f46:	96be                	add	a3,a3,a5
    80005f48:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005f4c:	6314                	ld	a3,0(a4)
    80005f4e:	96be                	add	a3,a3,a5
    80005f50:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80005f54:	6314                	ld	a3,0(a4)
    80005f56:	96be                	add	a3,a3,a5
    80005f58:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80005f5c:	6318                	ld	a4,0(a4)
    80005f5e:	97ba                	add	a5,a5,a4
    80005f60:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80005f64:	0001d717          	auipc	a4,0x1d
    80005f68:	09c70713          	addi	a4,a4,156 # 80023000 <disk>
    80005f6c:	972a                	add	a4,a4,a0
    80005f6e:	6789                	lui	a5,0x2
    80005f70:	97ba                	add	a5,a5,a4
    80005f72:	4705                	li	a4,1
    80005f74:	00e78c23          	sb	a4,24(a5) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005f78:	0001f517          	auipc	a0,0x1f
    80005f7c:	0a050513          	addi	a0,a0,160 # 80025018 <disk+0x2018>
    80005f80:	ffffc097          	auipc	ra,0xffffc
    80005f84:	26a080e7          	jalr	618(ra) # 800021ea <wakeup>
}
    80005f88:	60a2                	ld	ra,8(sp)
    80005f8a:	6402                	ld	s0,0(sp)
    80005f8c:	0141                	addi	sp,sp,16
    80005f8e:	8082                	ret
    panic("free_desc 1");
    80005f90:	00002517          	auipc	a0,0x2
    80005f94:	7f850513          	addi	a0,a0,2040 # 80008788 <syscalls+0x340>
    80005f98:	ffffa097          	auipc	ra,0xffffa
    80005f9c:	5a2080e7          	jalr	1442(ra) # 8000053a <panic>
    panic("free_desc 2");
    80005fa0:	00002517          	auipc	a0,0x2
    80005fa4:	7f850513          	addi	a0,a0,2040 # 80008798 <syscalls+0x350>
    80005fa8:	ffffa097          	auipc	ra,0xffffa
    80005fac:	592080e7          	jalr	1426(ra) # 8000053a <panic>

0000000080005fb0 <virtio_disk_init>:
{
    80005fb0:	1101                	addi	sp,sp,-32
    80005fb2:	ec06                	sd	ra,24(sp)
    80005fb4:	e822                	sd	s0,16(sp)
    80005fb6:	e426                	sd	s1,8(sp)
    80005fb8:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005fba:	00002597          	auipc	a1,0x2
    80005fbe:	7ee58593          	addi	a1,a1,2030 # 800087a8 <syscalls+0x360>
    80005fc2:	0001f517          	auipc	a0,0x1f
    80005fc6:	16650513          	addi	a0,a0,358 # 80025128 <disk+0x2128>
    80005fca:	ffffb097          	auipc	ra,0xffffb
    80005fce:	b76080e7          	jalr	-1162(ra) # 80000b40 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005fd2:	100017b7          	lui	a5,0x10001
    80005fd6:	4398                	lw	a4,0(a5)
    80005fd8:	2701                	sext.w	a4,a4
    80005fda:	747277b7          	lui	a5,0x74727
    80005fde:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005fe2:	0ef71063          	bne	a4,a5,800060c2 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005fe6:	100017b7          	lui	a5,0x10001
    80005fea:	43dc                	lw	a5,4(a5)
    80005fec:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005fee:	4705                	li	a4,1
    80005ff0:	0ce79963          	bne	a5,a4,800060c2 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005ff4:	100017b7          	lui	a5,0x10001
    80005ff8:	479c                	lw	a5,8(a5)
    80005ffa:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005ffc:	4709                	li	a4,2
    80005ffe:	0ce79263          	bne	a5,a4,800060c2 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006002:	100017b7          	lui	a5,0x10001
    80006006:	47d8                	lw	a4,12(a5)
    80006008:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000600a:	554d47b7          	lui	a5,0x554d4
    8000600e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006012:	0af71863          	bne	a4,a5,800060c2 <virtio_disk_init+0x112>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006016:	100017b7          	lui	a5,0x10001
    8000601a:	4705                	li	a4,1
    8000601c:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000601e:	470d                	li	a4,3
    80006020:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006022:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006024:	c7ffe6b7          	lui	a3,0xc7ffe
    80006028:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    8000602c:	8f75                	and	a4,a4,a3
    8000602e:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006030:	472d                	li	a4,11
    80006032:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006034:	473d                	li	a4,15
    80006036:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006038:	6705                	lui	a4,0x1
    8000603a:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000603c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006040:	5bdc                	lw	a5,52(a5)
    80006042:	2781                	sext.w	a5,a5
  if(max == 0)
    80006044:	c7d9                	beqz	a5,800060d2 <virtio_disk_init+0x122>
  if(max < NUM)
    80006046:	471d                	li	a4,7
    80006048:	08f77d63          	bgeu	a4,a5,800060e2 <virtio_disk_init+0x132>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000604c:	100014b7          	lui	s1,0x10001
    80006050:	47a1                	li	a5,8
    80006052:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006054:	6609                	lui	a2,0x2
    80006056:	4581                	li	a1,0
    80006058:	0001d517          	auipc	a0,0x1d
    8000605c:	fa850513          	addi	a0,a0,-88 # 80023000 <disk>
    80006060:	ffffb097          	auipc	ra,0xffffb
    80006064:	c6c080e7          	jalr	-916(ra) # 80000ccc <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006068:	0001d717          	auipc	a4,0x1d
    8000606c:	f9870713          	addi	a4,a4,-104 # 80023000 <disk>
    80006070:	00c75793          	srli	a5,a4,0xc
    80006074:	2781                	sext.w	a5,a5
    80006076:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80006078:	0001f797          	auipc	a5,0x1f
    8000607c:	f8878793          	addi	a5,a5,-120 # 80025000 <disk+0x2000>
    80006080:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006082:	0001d717          	auipc	a4,0x1d
    80006086:	ffe70713          	addi	a4,a4,-2 # 80023080 <disk+0x80>
    8000608a:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    8000608c:	0001e717          	auipc	a4,0x1e
    80006090:	f7470713          	addi	a4,a4,-140 # 80024000 <disk+0x1000>
    80006094:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80006096:	4705                	li	a4,1
    80006098:	00e78c23          	sb	a4,24(a5)
    8000609c:	00e78ca3          	sb	a4,25(a5)
    800060a0:	00e78d23          	sb	a4,26(a5)
    800060a4:	00e78da3          	sb	a4,27(a5)
    800060a8:	00e78e23          	sb	a4,28(a5)
    800060ac:	00e78ea3          	sb	a4,29(a5)
    800060b0:	00e78f23          	sb	a4,30(a5)
    800060b4:	00e78fa3          	sb	a4,31(a5)
}
    800060b8:	60e2                	ld	ra,24(sp)
    800060ba:	6442                	ld	s0,16(sp)
    800060bc:	64a2                	ld	s1,8(sp)
    800060be:	6105                	addi	sp,sp,32
    800060c0:	8082                	ret
    panic("could not find virtio disk");
    800060c2:	00002517          	auipc	a0,0x2
    800060c6:	6f650513          	addi	a0,a0,1782 # 800087b8 <syscalls+0x370>
    800060ca:	ffffa097          	auipc	ra,0xffffa
    800060ce:	470080e7          	jalr	1136(ra) # 8000053a <panic>
    panic("virtio disk has no queue 0");
    800060d2:	00002517          	auipc	a0,0x2
    800060d6:	70650513          	addi	a0,a0,1798 # 800087d8 <syscalls+0x390>
    800060da:	ffffa097          	auipc	ra,0xffffa
    800060de:	460080e7          	jalr	1120(ra) # 8000053a <panic>
    panic("virtio disk max queue too short");
    800060e2:	00002517          	auipc	a0,0x2
    800060e6:	71650513          	addi	a0,a0,1814 # 800087f8 <syscalls+0x3b0>
    800060ea:	ffffa097          	auipc	ra,0xffffa
    800060ee:	450080e7          	jalr	1104(ra) # 8000053a <panic>

00000000800060f2 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800060f2:	7119                	addi	sp,sp,-128
    800060f4:	fc86                	sd	ra,120(sp)
    800060f6:	f8a2                	sd	s0,112(sp)
    800060f8:	f4a6                	sd	s1,104(sp)
    800060fa:	f0ca                	sd	s2,96(sp)
    800060fc:	ecce                	sd	s3,88(sp)
    800060fe:	e8d2                	sd	s4,80(sp)
    80006100:	e4d6                	sd	s5,72(sp)
    80006102:	e0da                	sd	s6,64(sp)
    80006104:	fc5e                	sd	s7,56(sp)
    80006106:	f862                	sd	s8,48(sp)
    80006108:	f466                	sd	s9,40(sp)
    8000610a:	f06a                	sd	s10,32(sp)
    8000610c:	ec6e                	sd	s11,24(sp)
    8000610e:	0100                	addi	s0,sp,128
    80006110:	8aaa                	mv	s5,a0
    80006112:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006114:	00c52c83          	lw	s9,12(a0)
    80006118:	001c9c9b          	slliw	s9,s9,0x1
    8000611c:	1c82                	slli	s9,s9,0x20
    8000611e:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006122:	0001f517          	auipc	a0,0x1f
    80006126:	00650513          	addi	a0,a0,6 # 80025128 <disk+0x2128>
    8000612a:	ffffb097          	auipc	ra,0xffffb
    8000612e:	aa6080e7          	jalr	-1370(ra) # 80000bd0 <acquire>
  for(int i = 0; i < 3; i++){
    80006132:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006134:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006136:	0001dc17          	auipc	s8,0x1d
    8000613a:	ecac0c13          	addi	s8,s8,-310 # 80023000 <disk>
    8000613e:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80006140:	4b0d                	li	s6,3
    80006142:	a0ad                	j	800061ac <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80006144:	00fc0733          	add	a4,s8,a5
    80006148:	975e                	add	a4,a4,s7
    8000614a:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    8000614e:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006150:	0207c563          	bltz	a5,8000617a <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006154:	2905                	addiw	s2,s2,1
    80006156:	0611                	addi	a2,a2,4 # 2004 <_entry-0x7fffdffc>
    80006158:	19690c63          	beq	s2,s6,800062f0 <virtio_disk_rw+0x1fe>
    idx[i] = alloc_desc();
    8000615c:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    8000615e:	0001f717          	auipc	a4,0x1f
    80006162:	eba70713          	addi	a4,a4,-326 # 80025018 <disk+0x2018>
    80006166:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006168:	00074683          	lbu	a3,0(a4)
    8000616c:	fee1                	bnez	a3,80006144 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    8000616e:	2785                	addiw	a5,a5,1
    80006170:	0705                	addi	a4,a4,1
    80006172:	fe979be3          	bne	a5,s1,80006168 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006176:	57fd                	li	a5,-1
    80006178:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000617a:	01205d63          	blez	s2,80006194 <virtio_disk_rw+0xa2>
    8000617e:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006180:	000a2503          	lw	a0,0(s4)
    80006184:	00000097          	auipc	ra,0x0
    80006188:	d92080e7          	jalr	-622(ra) # 80005f16 <free_desc>
      for(int j = 0; j < i; j++)
    8000618c:	2d85                	addiw	s11,s11,1
    8000618e:	0a11                	addi	s4,s4,4
    80006190:	ff2d98e3          	bne	s11,s2,80006180 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006194:	0001f597          	auipc	a1,0x1f
    80006198:	f9458593          	addi	a1,a1,-108 # 80025128 <disk+0x2128>
    8000619c:	0001f517          	auipc	a0,0x1f
    800061a0:	e7c50513          	addi	a0,a0,-388 # 80025018 <disk+0x2018>
    800061a4:	ffffc097          	auipc	ra,0xffffc
    800061a8:	eba080e7          	jalr	-326(ra) # 8000205e <sleep>
  for(int i = 0; i < 3; i++){
    800061ac:	f8040a13          	addi	s4,s0,-128
{
    800061b0:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800061b2:	894e                	mv	s2,s3
    800061b4:	b765                	j	8000615c <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800061b6:	0001f697          	auipc	a3,0x1f
    800061ba:	e4a6b683          	ld	a3,-438(a3) # 80025000 <disk+0x2000>
    800061be:	96ba                	add	a3,a3,a4
    800061c0:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800061c4:	0001d817          	auipc	a6,0x1d
    800061c8:	e3c80813          	addi	a6,a6,-452 # 80023000 <disk>
    800061cc:	0001f697          	auipc	a3,0x1f
    800061d0:	e3468693          	addi	a3,a3,-460 # 80025000 <disk+0x2000>
    800061d4:	6290                	ld	a2,0(a3)
    800061d6:	963a                	add	a2,a2,a4
    800061d8:	00c65583          	lhu	a1,12(a2)
    800061dc:	0015e593          	ori	a1,a1,1
    800061e0:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    800061e4:	f8842603          	lw	a2,-120(s0)
    800061e8:	628c                	ld	a1,0(a3)
    800061ea:	972e                	add	a4,a4,a1
    800061ec:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800061f0:	20050593          	addi	a1,a0,512
    800061f4:	0592                	slli	a1,a1,0x4
    800061f6:	95c2                	add	a1,a1,a6
    800061f8:	577d                	li	a4,-1
    800061fa:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800061fe:	00461713          	slli	a4,a2,0x4
    80006202:	6290                	ld	a2,0(a3)
    80006204:	963a                	add	a2,a2,a4
    80006206:	03078793          	addi	a5,a5,48
    8000620a:	97c2                	add	a5,a5,a6
    8000620c:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    8000620e:	629c                	ld	a5,0(a3)
    80006210:	97ba                	add	a5,a5,a4
    80006212:	4605                	li	a2,1
    80006214:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006216:	629c                	ld	a5,0(a3)
    80006218:	97ba                	add	a5,a5,a4
    8000621a:	4809                	li	a6,2
    8000621c:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006220:	629c                	ld	a5,0(a3)
    80006222:	97ba                	add	a5,a5,a4
    80006224:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006228:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    8000622c:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006230:	6698                	ld	a4,8(a3)
    80006232:	00275783          	lhu	a5,2(a4)
    80006236:	8b9d                	andi	a5,a5,7
    80006238:	0786                	slli	a5,a5,0x1
    8000623a:	973e                	add	a4,a4,a5
    8000623c:	00a71223          	sh	a0,4(a4)

  __sync_synchronize();
    80006240:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006244:	6698                	ld	a4,8(a3)
    80006246:	00275783          	lhu	a5,2(a4)
    8000624a:	2785                	addiw	a5,a5,1
    8000624c:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006250:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006254:	100017b7          	lui	a5,0x10001
    80006258:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000625c:	004aa783          	lw	a5,4(s5)
    80006260:	02c79163          	bne	a5,a2,80006282 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80006264:	0001f917          	auipc	s2,0x1f
    80006268:	ec490913          	addi	s2,s2,-316 # 80025128 <disk+0x2128>
  while(b->disk == 1) {
    8000626c:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    8000626e:	85ca                	mv	a1,s2
    80006270:	8556                	mv	a0,s5
    80006272:	ffffc097          	auipc	ra,0xffffc
    80006276:	dec080e7          	jalr	-532(ra) # 8000205e <sleep>
  while(b->disk == 1) {
    8000627a:	004aa783          	lw	a5,4(s5)
    8000627e:	fe9788e3          	beq	a5,s1,8000626e <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80006282:	f8042903          	lw	s2,-128(s0)
    80006286:	20090713          	addi	a4,s2,512
    8000628a:	0712                	slli	a4,a4,0x4
    8000628c:	0001d797          	auipc	a5,0x1d
    80006290:	d7478793          	addi	a5,a5,-652 # 80023000 <disk>
    80006294:	97ba                	add	a5,a5,a4
    80006296:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    8000629a:	0001f997          	auipc	s3,0x1f
    8000629e:	d6698993          	addi	s3,s3,-666 # 80025000 <disk+0x2000>
    800062a2:	00491713          	slli	a4,s2,0x4
    800062a6:	0009b783          	ld	a5,0(s3)
    800062aa:	97ba                	add	a5,a5,a4
    800062ac:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800062b0:	854a                	mv	a0,s2
    800062b2:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800062b6:	00000097          	auipc	ra,0x0
    800062ba:	c60080e7          	jalr	-928(ra) # 80005f16 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800062be:	8885                	andi	s1,s1,1
    800062c0:	f0ed                	bnez	s1,800062a2 <virtio_disk_rw+0x1b0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800062c2:	0001f517          	auipc	a0,0x1f
    800062c6:	e6650513          	addi	a0,a0,-410 # 80025128 <disk+0x2128>
    800062ca:	ffffb097          	auipc	ra,0xffffb
    800062ce:	9ba080e7          	jalr	-1606(ra) # 80000c84 <release>
}
    800062d2:	70e6                	ld	ra,120(sp)
    800062d4:	7446                	ld	s0,112(sp)
    800062d6:	74a6                	ld	s1,104(sp)
    800062d8:	7906                	ld	s2,96(sp)
    800062da:	69e6                	ld	s3,88(sp)
    800062dc:	6a46                	ld	s4,80(sp)
    800062de:	6aa6                	ld	s5,72(sp)
    800062e0:	6b06                	ld	s6,64(sp)
    800062e2:	7be2                	ld	s7,56(sp)
    800062e4:	7c42                	ld	s8,48(sp)
    800062e6:	7ca2                	ld	s9,40(sp)
    800062e8:	7d02                	ld	s10,32(sp)
    800062ea:	6de2                	ld	s11,24(sp)
    800062ec:	6109                	addi	sp,sp,128
    800062ee:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800062f0:	f8042503          	lw	a0,-128(s0)
    800062f4:	20050793          	addi	a5,a0,512
    800062f8:	0792                	slli	a5,a5,0x4
  if(write)
    800062fa:	0001d817          	auipc	a6,0x1d
    800062fe:	d0680813          	addi	a6,a6,-762 # 80023000 <disk>
    80006302:	00f80733          	add	a4,a6,a5
    80006306:	01a036b3          	snez	a3,s10
    8000630a:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    8000630e:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80006312:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006316:	7679                	lui	a2,0xffffe
    80006318:	963e                	add	a2,a2,a5
    8000631a:	0001f697          	auipc	a3,0x1f
    8000631e:	ce668693          	addi	a3,a3,-794 # 80025000 <disk+0x2000>
    80006322:	6298                	ld	a4,0(a3)
    80006324:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006326:	0a878593          	addi	a1,a5,168
    8000632a:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000632c:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000632e:	6298                	ld	a4,0(a3)
    80006330:	9732                	add	a4,a4,a2
    80006332:	45c1                	li	a1,16
    80006334:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006336:	6298                	ld	a4,0(a3)
    80006338:	9732                	add	a4,a4,a2
    8000633a:	4585                	li	a1,1
    8000633c:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80006340:	f8442703          	lw	a4,-124(s0)
    80006344:	628c                	ld	a1,0(a3)
    80006346:	962e                	add	a2,a2,a1
    80006348:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd800e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    8000634c:	0712                	slli	a4,a4,0x4
    8000634e:	6290                	ld	a2,0(a3)
    80006350:	963a                	add	a2,a2,a4
    80006352:	058a8593          	addi	a1,s5,88
    80006356:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006358:	6294                	ld	a3,0(a3)
    8000635a:	96ba                	add	a3,a3,a4
    8000635c:	40000613          	li	a2,1024
    80006360:	c690                	sw	a2,8(a3)
  if(write)
    80006362:	e40d1ae3          	bnez	s10,800061b6 <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006366:	0001f697          	auipc	a3,0x1f
    8000636a:	c9a6b683          	ld	a3,-870(a3) # 80025000 <disk+0x2000>
    8000636e:	96ba                	add	a3,a3,a4
    80006370:	4609                	li	a2,2
    80006372:	00c69623          	sh	a2,12(a3)
    80006376:	b5b9                	j	800061c4 <virtio_disk_rw+0xd2>

0000000080006378 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006378:	1101                	addi	sp,sp,-32
    8000637a:	ec06                	sd	ra,24(sp)
    8000637c:	e822                	sd	s0,16(sp)
    8000637e:	e426                	sd	s1,8(sp)
    80006380:	e04a                	sd	s2,0(sp)
    80006382:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006384:	0001f517          	auipc	a0,0x1f
    80006388:	da450513          	addi	a0,a0,-604 # 80025128 <disk+0x2128>
    8000638c:	ffffb097          	auipc	ra,0xffffb
    80006390:	844080e7          	jalr	-1980(ra) # 80000bd0 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006394:	10001737          	lui	a4,0x10001
    80006398:	533c                	lw	a5,96(a4)
    8000639a:	8b8d                	andi	a5,a5,3
    8000639c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000639e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800063a2:	0001f797          	auipc	a5,0x1f
    800063a6:	c5e78793          	addi	a5,a5,-930 # 80025000 <disk+0x2000>
    800063aa:	6b94                	ld	a3,16(a5)
    800063ac:	0207d703          	lhu	a4,32(a5)
    800063b0:	0026d783          	lhu	a5,2(a3)
    800063b4:	06f70163          	beq	a4,a5,80006416 <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800063b8:	0001d917          	auipc	s2,0x1d
    800063bc:	c4890913          	addi	s2,s2,-952 # 80023000 <disk>
    800063c0:	0001f497          	auipc	s1,0x1f
    800063c4:	c4048493          	addi	s1,s1,-960 # 80025000 <disk+0x2000>
    __sync_synchronize();
    800063c8:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800063cc:	6898                	ld	a4,16(s1)
    800063ce:	0204d783          	lhu	a5,32(s1)
    800063d2:	8b9d                	andi	a5,a5,7
    800063d4:	078e                	slli	a5,a5,0x3
    800063d6:	97ba                	add	a5,a5,a4
    800063d8:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800063da:	20078713          	addi	a4,a5,512
    800063de:	0712                	slli	a4,a4,0x4
    800063e0:	974a                	add	a4,a4,s2
    800063e2:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800063e6:	e731                	bnez	a4,80006432 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800063e8:	20078793          	addi	a5,a5,512
    800063ec:	0792                	slli	a5,a5,0x4
    800063ee:	97ca                	add	a5,a5,s2
    800063f0:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    800063f2:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800063f6:	ffffc097          	auipc	ra,0xffffc
    800063fa:	df4080e7          	jalr	-524(ra) # 800021ea <wakeup>

    disk.used_idx += 1;
    800063fe:	0204d783          	lhu	a5,32(s1)
    80006402:	2785                	addiw	a5,a5,1
    80006404:	17c2                	slli	a5,a5,0x30
    80006406:	93c1                	srli	a5,a5,0x30
    80006408:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000640c:	6898                	ld	a4,16(s1)
    8000640e:	00275703          	lhu	a4,2(a4)
    80006412:	faf71be3          	bne	a4,a5,800063c8 <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    80006416:	0001f517          	auipc	a0,0x1f
    8000641a:	d1250513          	addi	a0,a0,-750 # 80025128 <disk+0x2128>
    8000641e:	ffffb097          	auipc	ra,0xffffb
    80006422:	866080e7          	jalr	-1946(ra) # 80000c84 <release>
}
    80006426:	60e2                	ld	ra,24(sp)
    80006428:	6442                	ld	s0,16(sp)
    8000642a:	64a2                	ld	s1,8(sp)
    8000642c:	6902                	ld	s2,0(sp)
    8000642e:	6105                	addi	sp,sp,32
    80006430:	8082                	ret
      panic("virtio_disk_intr status");
    80006432:	00002517          	auipc	a0,0x2
    80006436:	3e650513          	addi	a0,a0,998 # 80008818 <syscalls+0x3d0>
    8000643a:	ffffa097          	auipc	ra,0xffffa
    8000643e:	100080e7          	jalr	256(ra) # 8000053a <panic>
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
