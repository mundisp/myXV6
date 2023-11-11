
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	8c013103          	ld	sp,-1856(sp) # 800088c0 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000066:	f1e78793          	addi	a5,a5,-226 # 80005f80 <timervec>
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
    800000b0:	e1078793          	addi	a5,a5,-496 # 80000ebc <main>
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
    8000012e:	3ac080e7          	jalr	940(ra) # 800024d6 <either_copyin>
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
    80000196:	a88080e7          	jalr	-1400(ra) # 80000c1a <acquire>
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
    800001c0:	00002097          	auipc	ra,0x2
    800001c4:	806080e7          	jalr	-2042(ra) # 800019c6 <myproc>
    800001c8:	551c                	lw	a5,40(a0)
    800001ca:	e7b5                	bnez	a5,80000236 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001cc:	85a6                	mv	a1,s1
    800001ce:	854a                	mv	a0,s2
    800001d0:	00002097          	auipc	ra,0x2
    800001d4:	f02080e7          	jalr	-254(ra) # 800020d2 <sleep>
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
    80000210:	274080e7          	jalr	628(ra) # 80002480 <either_copyout>
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
    8000022c:	aa6080e7          	jalr	-1370(ra) # 80000cce <release>

  return target - n;
    80000230:	413b053b          	subw	a0,s6,s3
    80000234:	a811                	j	80000248 <consoleread+0xe4>
        release(&cons.lock);
    80000236:	00011517          	auipc	a0,0x11
    8000023a:	f4a50513          	addi	a0,a0,-182 # 80011180 <cons>
    8000023e:	00001097          	auipc	ra,0x1
    80000242:	a90080e7          	jalr	-1392(ra) # 80000cce <release>
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
    800002d2:	94c080e7          	jalr	-1716(ra) # 80000c1a <acquire>

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
    800002f0:	240080e7          	jalr	576(ra) # 8000252c <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f4:	00011517          	auipc	a0,0x11
    800002f8:	e8c50513          	addi	a0,a0,-372 # 80011180 <cons>
    800002fc:	00001097          	auipc	ra,0x1
    80000300:	9d2080e7          	jalr	-1582(ra) # 80000cce <release>
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
    80000444:	e1e080e7          	jalr	-482(ra) # 8000225e <wakeup>
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
    80000466:	728080e7          	jalr	1832(ra) # 80000b8a <initlock>

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
    80000600:	61e080e7          	jalr	1566(ra) # 80000c1a <acquire>
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
    8000075e:	574080e7          	jalr	1396(ra) # 80000cce <release>
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
    80000784:	40a080e7          	jalr	1034(ra) # 80000b8a <initlock>
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
    800007da:	3b4080e7          	jalr	948(ra) # 80000b8a <initlock>
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
    800007f6:	3dc080e7          	jalr	988(ra) # 80000bce <push_off>

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
    80000824:	44e080e7          	jalr	1102(ra) # 80000c6e <pop_off>
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
    80000892:	9d0080e7          	jalr	-1584(ra) # 8000225e <wakeup>
    
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
    800008d6:	348080e7          	jalr	840(ra) # 80000c1a <acquire>
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
    8000091e:	7b8080e7          	jalr	1976(ra) # 800020d2 <sleep>
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
    8000095a:	378080e7          	jalr	888(ra) # 80000cce <release>
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
    800009c2:	25c080e7          	jalr	604(ra) # 80000c1a <acquire>
  uartstart();
    800009c6:	00000097          	auipc	ra,0x0
    800009ca:	e6c080e7          	jalr	-404(ra) # 80000832 <uartstart>
  release(&uart_tx_lock);
    800009ce:	8526                	mv	a0,s1
    800009d0:	00000097          	auipc	ra,0x0
    800009d4:	2fe080e7          	jalr	766(ra) # 80000cce <release>
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
    80000a12:	308080e7          	jalr	776(ra) # 80000d16 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a16:	00011917          	auipc	s2,0x11
    80000a1a:	86a90913          	addi	s2,s2,-1942 # 80011280 <kmem>
    80000a1e:	854a                	mv	a0,s2
    80000a20:	00000097          	auipc	ra,0x0
    80000a24:	1fa080e7          	jalr	506(ra) # 80000c1a <acquire>
  r->next = kmem.freelist;
    80000a28:	01893783          	ld	a5,24(s2)
    80000a2c:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a2e:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a32:	854a                	mv	a0,s2
    80000a34:	00000097          	auipc	ra,0x0
    80000a38:	29a080e7          	jalr	666(ra) # 80000cce <release>
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
    80000ac0:	0ce080e7          	jalr	206(ra) # 80000b8a <initlock>
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
    80000af8:	126080e7          	jalr	294(ra) # 80000c1a <acquire>
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
    80000b10:	1c2080e7          	jalr	450(ra) # 80000cce <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b14:	6605                	lui	a2,0x1
    80000b16:	4595                	li	a1,5
    80000b18:	8526                	mv	a0,s1
    80000b1a:	00000097          	auipc	ra,0x0
    80000b1e:	1fc080e7          	jalr	508(ra) # 80000d16 <memset>
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
    80000b3a:	198080e7          	jalr	408(ra) # 80000cce <release>
  if(r)
    80000b3e:	b7d5                	j	80000b22 <kalloc+0x42>

0000000080000b40 <freepmem>:

uint64
freepmem(void)
{
    80000b40:	1101                	addi	sp,sp,-32
    80000b42:	ec06                	sd	ra,24(sp)
    80000b44:	e822                	sd	s0,16(sp)
    80000b46:	e426                	sd	s1,8(sp)
    80000b48:	1000                	addi	s0,sp,32
	struct run *r;
	int fpages = 0;
	
	acquire(&kmem.lock);
    80000b4a:	00010497          	auipc	s1,0x10
    80000b4e:	73648493          	addi	s1,s1,1846 # 80011280 <kmem>
    80000b52:	8526                	mv	a0,s1
    80000b54:	00000097          	auipc	ra,0x0
    80000b58:	0c6080e7          	jalr	198(ra) # 80000c1a <acquire>
	r = kmem.freelist;
    80000b5c:	6c9c                	ld	a5,24(s1)
	while(r){
    80000b5e:	c785                	beqz	a5,80000b86 <freepmem+0x46>
	int fpages = 0;
    80000b60:	4481                	li	s1,0
		fpages = fpages + 1;
    80000b62:	2485                	addiw	s1,s1,1
		r = r -> next;
    80000b64:	639c                	ld	a5,0(a5)
	while(r){
    80000b66:	fff5                	bnez	a5,80000b62 <freepmem+0x22>
	}
	release(&kmem.lock);
    80000b68:	00010517          	auipc	a0,0x10
    80000b6c:	71850513          	addi	a0,a0,1816 # 80011280 <kmem>
    80000b70:	00000097          	auipc	ra,0x0
    80000b74:	15e080e7          	jalr	350(ra) # 80000cce <release>
	
	int fmem = fpages * PGSIZE;
	return fmem;
}
    80000b78:	00c4951b          	slliw	a0,s1,0xc
    80000b7c:	60e2                	ld	ra,24(sp)
    80000b7e:	6442                	ld	s0,16(sp)
    80000b80:	64a2                	ld	s1,8(sp)
    80000b82:	6105                	addi	sp,sp,32
    80000b84:	8082                	ret
	int fpages = 0;
    80000b86:	4481                	li	s1,0
    80000b88:	b7c5                	j	80000b68 <freepmem+0x28>

0000000080000b8a <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b8a:	1141                	addi	sp,sp,-16
    80000b8c:	e422                	sd	s0,8(sp)
    80000b8e:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b90:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b92:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b96:	00053823          	sd	zero,16(a0)
}
    80000b9a:	6422                	ld	s0,8(sp)
    80000b9c:	0141                	addi	sp,sp,16
    80000b9e:	8082                	ret

0000000080000ba0 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000ba0:	411c                	lw	a5,0(a0)
    80000ba2:	e399                	bnez	a5,80000ba8 <holding+0x8>
    80000ba4:	4501                	li	a0,0
  return r;
}
    80000ba6:	8082                	ret
{
    80000ba8:	1101                	addi	sp,sp,-32
    80000baa:	ec06                	sd	ra,24(sp)
    80000bac:	e822                	sd	s0,16(sp)
    80000bae:	e426                	sd	s1,8(sp)
    80000bb0:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bb2:	6904                	ld	s1,16(a0)
    80000bb4:	00001097          	auipc	ra,0x1
    80000bb8:	df6080e7          	jalr	-522(ra) # 800019aa <mycpu>
    80000bbc:	40a48533          	sub	a0,s1,a0
    80000bc0:	00153513          	seqz	a0,a0
}
    80000bc4:	60e2                	ld	ra,24(sp)
    80000bc6:	6442                	ld	s0,16(sp)
    80000bc8:	64a2                	ld	s1,8(sp)
    80000bca:	6105                	addi	sp,sp,32
    80000bcc:	8082                	ret

0000000080000bce <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bce:	1101                	addi	sp,sp,-32
    80000bd0:	ec06                	sd	ra,24(sp)
    80000bd2:	e822                	sd	s0,16(sp)
    80000bd4:	e426                	sd	s1,8(sp)
    80000bd6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bd8:	100024f3          	csrr	s1,sstatus
    80000bdc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000be0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000be2:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000be6:	00001097          	auipc	ra,0x1
    80000bea:	dc4080e7          	jalr	-572(ra) # 800019aa <mycpu>
    80000bee:	5d3c                	lw	a5,120(a0)
    80000bf0:	cf89                	beqz	a5,80000c0a <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bf2:	00001097          	auipc	ra,0x1
    80000bf6:	db8080e7          	jalr	-584(ra) # 800019aa <mycpu>
    80000bfa:	5d3c                	lw	a5,120(a0)
    80000bfc:	2785                	addiw	a5,a5,1
    80000bfe:	dd3c                	sw	a5,120(a0)
}
    80000c00:	60e2                	ld	ra,24(sp)
    80000c02:	6442                	ld	s0,16(sp)
    80000c04:	64a2                	ld	s1,8(sp)
    80000c06:	6105                	addi	sp,sp,32
    80000c08:	8082                	ret
    mycpu()->intena = old;
    80000c0a:	00001097          	auipc	ra,0x1
    80000c0e:	da0080e7          	jalr	-608(ra) # 800019aa <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c12:	8085                	srli	s1,s1,0x1
    80000c14:	8885                	andi	s1,s1,1
    80000c16:	dd64                	sw	s1,124(a0)
    80000c18:	bfe9                	j	80000bf2 <push_off+0x24>

0000000080000c1a <acquire>:
{
    80000c1a:	1101                	addi	sp,sp,-32
    80000c1c:	ec06                	sd	ra,24(sp)
    80000c1e:	e822                	sd	s0,16(sp)
    80000c20:	e426                	sd	s1,8(sp)
    80000c22:	1000                	addi	s0,sp,32
    80000c24:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c26:	00000097          	auipc	ra,0x0
    80000c2a:	fa8080e7          	jalr	-88(ra) # 80000bce <push_off>
  if(holding(lk))
    80000c2e:	8526                	mv	a0,s1
    80000c30:	00000097          	auipc	ra,0x0
    80000c34:	f70080e7          	jalr	-144(ra) # 80000ba0 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c38:	4705                	li	a4,1
  if(holding(lk))
    80000c3a:	e115                	bnez	a0,80000c5e <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c3c:	87ba                	mv	a5,a4
    80000c3e:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c42:	2781                	sext.w	a5,a5
    80000c44:	ffe5                	bnez	a5,80000c3c <acquire+0x22>
  __sync_synchronize();
    80000c46:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c4a:	00001097          	auipc	ra,0x1
    80000c4e:	d60080e7          	jalr	-672(ra) # 800019aa <mycpu>
    80000c52:	e888                	sd	a0,16(s1)
}
    80000c54:	60e2                	ld	ra,24(sp)
    80000c56:	6442                	ld	s0,16(sp)
    80000c58:	64a2                	ld	s1,8(sp)
    80000c5a:	6105                	addi	sp,sp,32
    80000c5c:	8082                	ret
    panic("acquire");
    80000c5e:	00007517          	auipc	a0,0x7
    80000c62:	41250513          	addi	a0,a0,1042 # 80008070 <digits+0x30>
    80000c66:	00000097          	auipc	ra,0x0
    80000c6a:	8d4080e7          	jalr	-1836(ra) # 8000053a <panic>

0000000080000c6e <pop_off>:

void
pop_off(void)
{
    80000c6e:	1141                	addi	sp,sp,-16
    80000c70:	e406                	sd	ra,8(sp)
    80000c72:	e022                	sd	s0,0(sp)
    80000c74:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c76:	00001097          	auipc	ra,0x1
    80000c7a:	d34080e7          	jalr	-716(ra) # 800019aa <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c7e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c82:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c84:	e78d                	bnez	a5,80000cae <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c86:	5d3c                	lw	a5,120(a0)
    80000c88:	02f05b63          	blez	a5,80000cbe <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c8c:	37fd                	addiw	a5,a5,-1
    80000c8e:	0007871b          	sext.w	a4,a5
    80000c92:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c94:	eb09                	bnez	a4,80000ca6 <pop_off+0x38>
    80000c96:	5d7c                	lw	a5,124(a0)
    80000c98:	c799                	beqz	a5,80000ca6 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c9a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c9e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000ca2:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000ca6:	60a2                	ld	ra,8(sp)
    80000ca8:	6402                	ld	s0,0(sp)
    80000caa:	0141                	addi	sp,sp,16
    80000cac:	8082                	ret
    panic("pop_off - interruptible");
    80000cae:	00007517          	auipc	a0,0x7
    80000cb2:	3ca50513          	addi	a0,a0,970 # 80008078 <digits+0x38>
    80000cb6:	00000097          	auipc	ra,0x0
    80000cba:	884080e7          	jalr	-1916(ra) # 8000053a <panic>
    panic("pop_off");
    80000cbe:	00007517          	auipc	a0,0x7
    80000cc2:	3d250513          	addi	a0,a0,978 # 80008090 <digits+0x50>
    80000cc6:	00000097          	auipc	ra,0x0
    80000cca:	874080e7          	jalr	-1932(ra) # 8000053a <panic>

0000000080000cce <release>:
{
    80000cce:	1101                	addi	sp,sp,-32
    80000cd0:	ec06                	sd	ra,24(sp)
    80000cd2:	e822                	sd	s0,16(sp)
    80000cd4:	e426                	sd	s1,8(sp)
    80000cd6:	1000                	addi	s0,sp,32
    80000cd8:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cda:	00000097          	auipc	ra,0x0
    80000cde:	ec6080e7          	jalr	-314(ra) # 80000ba0 <holding>
    80000ce2:	c115                	beqz	a0,80000d06 <release+0x38>
  lk->cpu = 0;
    80000ce4:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ce8:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000cec:	0f50000f          	fence	iorw,ow
    80000cf0:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cf4:	00000097          	auipc	ra,0x0
    80000cf8:	f7a080e7          	jalr	-134(ra) # 80000c6e <pop_off>
}
    80000cfc:	60e2                	ld	ra,24(sp)
    80000cfe:	6442                	ld	s0,16(sp)
    80000d00:	64a2                	ld	s1,8(sp)
    80000d02:	6105                	addi	sp,sp,32
    80000d04:	8082                	ret
    panic("release");
    80000d06:	00007517          	auipc	a0,0x7
    80000d0a:	39250513          	addi	a0,a0,914 # 80008098 <digits+0x58>
    80000d0e:	00000097          	auipc	ra,0x0
    80000d12:	82c080e7          	jalr	-2004(ra) # 8000053a <panic>

0000000080000d16 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d16:	1141                	addi	sp,sp,-16
    80000d18:	e422                	sd	s0,8(sp)
    80000d1a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d1c:	ca19                	beqz	a2,80000d32 <memset+0x1c>
    80000d1e:	87aa                	mv	a5,a0
    80000d20:	1602                	slli	a2,a2,0x20
    80000d22:	9201                	srli	a2,a2,0x20
    80000d24:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d28:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d2c:	0785                	addi	a5,a5,1
    80000d2e:	fee79de3          	bne	a5,a4,80000d28 <memset+0x12>
  }
  return dst;
}
    80000d32:	6422                	ld	s0,8(sp)
    80000d34:	0141                	addi	sp,sp,16
    80000d36:	8082                	ret

0000000080000d38 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d38:	1141                	addi	sp,sp,-16
    80000d3a:	e422                	sd	s0,8(sp)
    80000d3c:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d3e:	ca05                	beqz	a2,80000d6e <memcmp+0x36>
    80000d40:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d44:	1682                	slli	a3,a3,0x20
    80000d46:	9281                	srli	a3,a3,0x20
    80000d48:	0685                	addi	a3,a3,1
    80000d4a:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d4c:	00054783          	lbu	a5,0(a0)
    80000d50:	0005c703          	lbu	a4,0(a1)
    80000d54:	00e79863          	bne	a5,a4,80000d64 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d58:	0505                	addi	a0,a0,1
    80000d5a:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d5c:	fed518e3          	bne	a0,a3,80000d4c <memcmp+0x14>
  }

  return 0;
    80000d60:	4501                	li	a0,0
    80000d62:	a019                	j	80000d68 <memcmp+0x30>
      return *s1 - *s2;
    80000d64:	40e7853b          	subw	a0,a5,a4
}
    80000d68:	6422                	ld	s0,8(sp)
    80000d6a:	0141                	addi	sp,sp,16
    80000d6c:	8082                	ret
  return 0;
    80000d6e:	4501                	li	a0,0
    80000d70:	bfe5                	j	80000d68 <memcmp+0x30>

0000000080000d72 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d72:	1141                	addi	sp,sp,-16
    80000d74:	e422                	sd	s0,8(sp)
    80000d76:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d78:	c205                	beqz	a2,80000d98 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d7a:	02a5e263          	bltu	a1,a0,80000d9e <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d7e:	1602                	slli	a2,a2,0x20
    80000d80:	9201                	srli	a2,a2,0x20
    80000d82:	00c587b3          	add	a5,a1,a2
{
    80000d86:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d88:	0585                	addi	a1,a1,1
    80000d8a:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffd9001>
    80000d8c:	fff5c683          	lbu	a3,-1(a1)
    80000d90:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d94:	fef59ae3          	bne	a1,a5,80000d88 <memmove+0x16>

  return dst;
}
    80000d98:	6422                	ld	s0,8(sp)
    80000d9a:	0141                	addi	sp,sp,16
    80000d9c:	8082                	ret
  if(s < d && s + n > d){
    80000d9e:	02061693          	slli	a3,a2,0x20
    80000da2:	9281                	srli	a3,a3,0x20
    80000da4:	00d58733          	add	a4,a1,a3
    80000da8:	fce57be3          	bgeu	a0,a4,80000d7e <memmove+0xc>
    d += n;
    80000dac:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000dae:	fff6079b          	addiw	a5,a2,-1
    80000db2:	1782                	slli	a5,a5,0x20
    80000db4:	9381                	srli	a5,a5,0x20
    80000db6:	fff7c793          	not	a5,a5
    80000dba:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000dbc:	177d                	addi	a4,a4,-1
    80000dbe:	16fd                	addi	a3,a3,-1
    80000dc0:	00074603          	lbu	a2,0(a4)
    80000dc4:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000dc8:	fee79ae3          	bne	a5,a4,80000dbc <memmove+0x4a>
    80000dcc:	b7f1                	j	80000d98 <memmove+0x26>

0000000080000dce <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000dce:	1141                	addi	sp,sp,-16
    80000dd0:	e406                	sd	ra,8(sp)
    80000dd2:	e022                	sd	s0,0(sp)
    80000dd4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000dd6:	00000097          	auipc	ra,0x0
    80000dda:	f9c080e7          	jalr	-100(ra) # 80000d72 <memmove>
}
    80000dde:	60a2                	ld	ra,8(sp)
    80000de0:	6402                	ld	s0,0(sp)
    80000de2:	0141                	addi	sp,sp,16
    80000de4:	8082                	ret

0000000080000de6 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000de6:	1141                	addi	sp,sp,-16
    80000de8:	e422                	sd	s0,8(sp)
    80000dea:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dec:	ce11                	beqz	a2,80000e08 <strncmp+0x22>
    80000dee:	00054783          	lbu	a5,0(a0)
    80000df2:	cf89                	beqz	a5,80000e0c <strncmp+0x26>
    80000df4:	0005c703          	lbu	a4,0(a1)
    80000df8:	00f71a63          	bne	a4,a5,80000e0c <strncmp+0x26>
    n--, p++, q++;
    80000dfc:	367d                	addiw	a2,a2,-1
    80000dfe:	0505                	addi	a0,a0,1
    80000e00:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e02:	f675                	bnez	a2,80000dee <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e04:	4501                	li	a0,0
    80000e06:	a809                	j	80000e18 <strncmp+0x32>
    80000e08:	4501                	li	a0,0
    80000e0a:	a039                	j	80000e18 <strncmp+0x32>
  if(n == 0)
    80000e0c:	ca09                	beqz	a2,80000e1e <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000e0e:	00054503          	lbu	a0,0(a0)
    80000e12:	0005c783          	lbu	a5,0(a1)
    80000e16:	9d1d                	subw	a0,a0,a5
}
    80000e18:	6422                	ld	s0,8(sp)
    80000e1a:	0141                	addi	sp,sp,16
    80000e1c:	8082                	ret
    return 0;
    80000e1e:	4501                	li	a0,0
    80000e20:	bfe5                	j	80000e18 <strncmp+0x32>

0000000080000e22 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e22:	1141                	addi	sp,sp,-16
    80000e24:	e422                	sd	s0,8(sp)
    80000e26:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e28:	872a                	mv	a4,a0
    80000e2a:	8832                	mv	a6,a2
    80000e2c:	367d                	addiw	a2,a2,-1
    80000e2e:	01005963          	blez	a6,80000e40 <strncpy+0x1e>
    80000e32:	0705                	addi	a4,a4,1
    80000e34:	0005c783          	lbu	a5,0(a1)
    80000e38:	fef70fa3          	sb	a5,-1(a4)
    80000e3c:	0585                	addi	a1,a1,1
    80000e3e:	f7f5                	bnez	a5,80000e2a <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e40:	86ba                	mv	a3,a4
    80000e42:	00c05c63          	blez	a2,80000e5a <strncpy+0x38>
    *s++ = 0;
    80000e46:	0685                	addi	a3,a3,1
    80000e48:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e4c:	40d707bb          	subw	a5,a4,a3
    80000e50:	37fd                	addiw	a5,a5,-1
    80000e52:	010787bb          	addw	a5,a5,a6
    80000e56:	fef048e3          	bgtz	a5,80000e46 <strncpy+0x24>
  return os;
}
    80000e5a:	6422                	ld	s0,8(sp)
    80000e5c:	0141                	addi	sp,sp,16
    80000e5e:	8082                	ret

0000000080000e60 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e60:	1141                	addi	sp,sp,-16
    80000e62:	e422                	sd	s0,8(sp)
    80000e64:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e66:	02c05363          	blez	a2,80000e8c <safestrcpy+0x2c>
    80000e6a:	fff6069b          	addiw	a3,a2,-1
    80000e6e:	1682                	slli	a3,a3,0x20
    80000e70:	9281                	srli	a3,a3,0x20
    80000e72:	96ae                	add	a3,a3,a1
    80000e74:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e76:	00d58963          	beq	a1,a3,80000e88 <safestrcpy+0x28>
    80000e7a:	0585                	addi	a1,a1,1
    80000e7c:	0785                	addi	a5,a5,1
    80000e7e:	fff5c703          	lbu	a4,-1(a1)
    80000e82:	fee78fa3          	sb	a4,-1(a5)
    80000e86:	fb65                	bnez	a4,80000e76 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e88:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e8c:	6422                	ld	s0,8(sp)
    80000e8e:	0141                	addi	sp,sp,16
    80000e90:	8082                	ret

0000000080000e92 <strlen>:

int
strlen(const char *s)
{
    80000e92:	1141                	addi	sp,sp,-16
    80000e94:	e422                	sd	s0,8(sp)
    80000e96:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e98:	00054783          	lbu	a5,0(a0)
    80000e9c:	cf91                	beqz	a5,80000eb8 <strlen+0x26>
    80000e9e:	0505                	addi	a0,a0,1
    80000ea0:	87aa                	mv	a5,a0
    80000ea2:	4685                	li	a3,1
    80000ea4:	9e89                	subw	a3,a3,a0
    80000ea6:	00f6853b          	addw	a0,a3,a5
    80000eaa:	0785                	addi	a5,a5,1
    80000eac:	fff7c703          	lbu	a4,-1(a5)
    80000eb0:	fb7d                	bnez	a4,80000ea6 <strlen+0x14>
    ;
  return n;
}
    80000eb2:	6422                	ld	s0,8(sp)
    80000eb4:	0141                	addi	sp,sp,16
    80000eb6:	8082                	ret
  for(n = 0; s[n]; n++)
    80000eb8:	4501                	li	a0,0
    80000eba:	bfe5                	j	80000eb2 <strlen+0x20>

0000000080000ebc <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000ebc:	1141                	addi	sp,sp,-16
    80000ebe:	e406                	sd	ra,8(sp)
    80000ec0:	e022                	sd	s0,0(sp)
    80000ec2:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000ec4:	00001097          	auipc	ra,0x1
    80000ec8:	ad6080e7          	jalr	-1322(ra) # 8000199a <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000ecc:	00008717          	auipc	a4,0x8
    80000ed0:	14c70713          	addi	a4,a4,332 # 80009018 <started>
  if(cpuid() == 0){
    80000ed4:	c139                	beqz	a0,80000f1a <main+0x5e>
    while(started == 0)
    80000ed6:	431c                	lw	a5,0(a4)
    80000ed8:	2781                	sext.w	a5,a5
    80000eda:	dff5                	beqz	a5,80000ed6 <main+0x1a>
      ;
    __sync_synchronize();
    80000edc:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000ee0:	00001097          	auipc	ra,0x1
    80000ee4:	aba080e7          	jalr	-1350(ra) # 8000199a <cpuid>
    80000ee8:	85aa                	mv	a1,a0
    80000eea:	00007517          	auipc	a0,0x7
    80000eee:	1ce50513          	addi	a0,a0,462 # 800080b8 <digits+0x78>
    80000ef2:	fffff097          	auipc	ra,0xfffff
    80000ef6:	692080e7          	jalr	1682(ra) # 80000584 <printf>
    kvminithart();    // turn on paging
    80000efa:	00000097          	auipc	ra,0x0
    80000efe:	0d8080e7          	jalr	216(ra) # 80000fd2 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f02:	00002097          	auipc	ra,0x2
    80000f06:	9a8080e7          	jalr	-1624(ra) # 800028aa <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f0a:	00005097          	auipc	ra,0x5
    80000f0e:	0b6080e7          	jalr	182(ra) # 80005fc0 <plicinithart>
  }

  scheduler();        
    80000f12:	00001097          	auipc	ra,0x1
    80000f16:	fca080e7          	jalr	-54(ra) # 80001edc <scheduler>
    consoleinit();
    80000f1a:	fffff097          	auipc	ra,0xfffff
    80000f1e:	530080e7          	jalr	1328(ra) # 8000044a <consoleinit>
    printfinit();
    80000f22:	00000097          	auipc	ra,0x0
    80000f26:	842080e7          	jalr	-1982(ra) # 80000764 <printfinit>
    printf("\n");
    80000f2a:	00007517          	auipc	a0,0x7
    80000f2e:	19e50513          	addi	a0,a0,414 # 800080c8 <digits+0x88>
    80000f32:	fffff097          	auipc	ra,0xfffff
    80000f36:	652080e7          	jalr	1618(ra) # 80000584 <printf>
    printf("xv6 kernel is booting\n");
    80000f3a:	00007517          	auipc	a0,0x7
    80000f3e:	16650513          	addi	a0,a0,358 # 800080a0 <digits+0x60>
    80000f42:	fffff097          	auipc	ra,0xfffff
    80000f46:	642080e7          	jalr	1602(ra) # 80000584 <printf>
    printf("\n");
    80000f4a:	00007517          	auipc	a0,0x7
    80000f4e:	17e50513          	addi	a0,a0,382 # 800080c8 <digits+0x88>
    80000f52:	fffff097          	auipc	ra,0xfffff
    80000f56:	632080e7          	jalr	1586(ra) # 80000584 <printf>
    kinit();         // physical page allocator
    80000f5a:	00000097          	auipc	ra,0x0
    80000f5e:	b4a080e7          	jalr	-1206(ra) # 80000aa4 <kinit>
    kvminit();       // create kernel page table
    80000f62:	00000097          	auipc	ra,0x0
    80000f66:	322080e7          	jalr	802(ra) # 80001284 <kvminit>
    kvminithart();   // turn on paging
    80000f6a:	00000097          	auipc	ra,0x0
    80000f6e:	068080e7          	jalr	104(ra) # 80000fd2 <kvminithart>
    procinit();      // process table
    80000f72:	00001097          	auipc	ra,0x1
    80000f76:	978080e7          	jalr	-1672(ra) # 800018ea <procinit>
    trapinit();      // trap vectors
    80000f7a:	00002097          	auipc	ra,0x2
    80000f7e:	908080e7          	jalr	-1784(ra) # 80002882 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f82:	00002097          	auipc	ra,0x2
    80000f86:	928080e7          	jalr	-1752(ra) # 800028aa <trapinithart>
    plicinit();      // set up interrupt controller
    80000f8a:	00005097          	auipc	ra,0x5
    80000f8e:	020080e7          	jalr	32(ra) # 80005faa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f92:	00005097          	auipc	ra,0x5
    80000f96:	02e080e7          	jalr	46(ra) # 80005fc0 <plicinithart>
    binit();         // buffer cache
    80000f9a:	00002097          	auipc	ra,0x2
    80000f9e:	1ee080e7          	jalr	494(ra) # 80003188 <binit>
    iinit();         // inode table
    80000fa2:	00003097          	auipc	ra,0x3
    80000fa6:	87c080e7          	jalr	-1924(ra) # 8000381e <iinit>
    fileinit();      // file table
    80000faa:	00004097          	auipc	ra,0x4
    80000fae:	82e080e7          	jalr	-2002(ra) # 800047d8 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fb2:	00005097          	auipc	ra,0x5
    80000fb6:	12e080e7          	jalr	302(ra) # 800060e0 <virtio_disk_init>
    userinit();      // first user process
    80000fba:	00001097          	auipc	ra,0x1
    80000fbe:	ce8080e7          	jalr	-792(ra) # 80001ca2 <userinit>
    __sync_synchronize();
    80000fc2:	0ff0000f          	fence
    started = 1;
    80000fc6:	4785                	li	a5,1
    80000fc8:	00008717          	auipc	a4,0x8
    80000fcc:	04f72823          	sw	a5,80(a4) # 80009018 <started>
    80000fd0:	b789                	j	80000f12 <main+0x56>

0000000080000fd2 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fd2:	1141                	addi	sp,sp,-16
    80000fd4:	e422                	sd	s0,8(sp)
    80000fd6:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000fd8:	00008797          	auipc	a5,0x8
    80000fdc:	0487b783          	ld	a5,72(a5) # 80009020 <kernel_pagetable>
    80000fe0:	83b1                	srli	a5,a5,0xc
    80000fe2:	577d                	li	a4,-1
    80000fe4:	177e                	slli	a4,a4,0x3f
    80000fe6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fe8:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fec:	12000073          	sfence.vma
  sfence_vma();
}
    80000ff0:	6422                	ld	s0,8(sp)
    80000ff2:	0141                	addi	sp,sp,16
    80000ff4:	8082                	ret

0000000080000ff6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000ff6:	7139                	addi	sp,sp,-64
    80000ff8:	fc06                	sd	ra,56(sp)
    80000ffa:	f822                	sd	s0,48(sp)
    80000ffc:	f426                	sd	s1,40(sp)
    80000ffe:	f04a                	sd	s2,32(sp)
    80001000:	ec4e                	sd	s3,24(sp)
    80001002:	e852                	sd	s4,16(sp)
    80001004:	e456                	sd	s5,8(sp)
    80001006:	e05a                	sd	s6,0(sp)
    80001008:	0080                	addi	s0,sp,64
    8000100a:	84aa                	mv	s1,a0
    8000100c:	89ae                	mv	s3,a1
    8000100e:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001010:	57fd                	li	a5,-1
    80001012:	83e9                	srli	a5,a5,0x1a
    80001014:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001016:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001018:	04b7f263          	bgeu	a5,a1,8000105c <walk+0x66>
    panic("walk");
    8000101c:	00007517          	auipc	a0,0x7
    80001020:	0b450513          	addi	a0,a0,180 # 800080d0 <digits+0x90>
    80001024:	fffff097          	auipc	ra,0xfffff
    80001028:	516080e7          	jalr	1302(ra) # 8000053a <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000102c:	060a8663          	beqz	s5,80001098 <walk+0xa2>
    80001030:	00000097          	auipc	ra,0x0
    80001034:	ab0080e7          	jalr	-1360(ra) # 80000ae0 <kalloc>
    80001038:	84aa                	mv	s1,a0
    8000103a:	c529                	beqz	a0,80001084 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000103c:	6605                	lui	a2,0x1
    8000103e:	4581                	li	a1,0
    80001040:	00000097          	auipc	ra,0x0
    80001044:	cd6080e7          	jalr	-810(ra) # 80000d16 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001048:	00c4d793          	srli	a5,s1,0xc
    8000104c:	07aa                	slli	a5,a5,0xa
    8000104e:	0017e793          	ori	a5,a5,1
    80001052:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001056:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffd8ff7>
    80001058:	036a0063          	beq	s4,s6,80001078 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000105c:	0149d933          	srl	s2,s3,s4
    80001060:	1ff97913          	andi	s2,s2,511
    80001064:	090e                	slli	s2,s2,0x3
    80001066:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001068:	00093483          	ld	s1,0(s2)
    8000106c:	0014f793          	andi	a5,s1,1
    80001070:	dfd5                	beqz	a5,8000102c <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001072:	80a9                	srli	s1,s1,0xa
    80001074:	04b2                	slli	s1,s1,0xc
    80001076:	b7c5                	j	80001056 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001078:	00c9d513          	srli	a0,s3,0xc
    8000107c:	1ff57513          	andi	a0,a0,511
    80001080:	050e                	slli	a0,a0,0x3
    80001082:	9526                	add	a0,a0,s1
}
    80001084:	70e2                	ld	ra,56(sp)
    80001086:	7442                	ld	s0,48(sp)
    80001088:	74a2                	ld	s1,40(sp)
    8000108a:	7902                	ld	s2,32(sp)
    8000108c:	69e2                	ld	s3,24(sp)
    8000108e:	6a42                	ld	s4,16(sp)
    80001090:	6aa2                	ld	s5,8(sp)
    80001092:	6b02                	ld	s6,0(sp)
    80001094:	6121                	addi	sp,sp,64
    80001096:	8082                	ret
        return 0;
    80001098:	4501                	li	a0,0
    8000109a:	b7ed                	j	80001084 <walk+0x8e>

000000008000109c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000109c:	57fd                	li	a5,-1
    8000109e:	83e9                	srli	a5,a5,0x1a
    800010a0:	00b7f463          	bgeu	a5,a1,800010a8 <walkaddr+0xc>
    return 0;
    800010a4:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010a6:	8082                	ret
{
    800010a8:	1141                	addi	sp,sp,-16
    800010aa:	e406                	sd	ra,8(sp)
    800010ac:	e022                	sd	s0,0(sp)
    800010ae:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010b0:	4601                	li	a2,0
    800010b2:	00000097          	auipc	ra,0x0
    800010b6:	f44080e7          	jalr	-188(ra) # 80000ff6 <walk>
  if(pte == 0)
    800010ba:	c105                	beqz	a0,800010da <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800010bc:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010be:	0117f693          	andi	a3,a5,17
    800010c2:	4745                	li	a4,17
    return 0;
    800010c4:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010c6:	00e68663          	beq	a3,a4,800010d2 <walkaddr+0x36>
}
    800010ca:	60a2                	ld	ra,8(sp)
    800010cc:	6402                	ld	s0,0(sp)
    800010ce:	0141                	addi	sp,sp,16
    800010d0:	8082                	ret
  pa = PTE2PA(*pte);
    800010d2:	83a9                	srli	a5,a5,0xa
    800010d4:	00c79513          	slli	a0,a5,0xc
  return pa;
    800010d8:	bfcd                	j	800010ca <walkaddr+0x2e>
    return 0;
    800010da:	4501                	li	a0,0
    800010dc:	b7fd                	j	800010ca <walkaddr+0x2e>

00000000800010de <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010de:	715d                	addi	sp,sp,-80
    800010e0:	e486                	sd	ra,72(sp)
    800010e2:	e0a2                	sd	s0,64(sp)
    800010e4:	fc26                	sd	s1,56(sp)
    800010e6:	f84a                	sd	s2,48(sp)
    800010e8:	f44e                	sd	s3,40(sp)
    800010ea:	f052                	sd	s4,32(sp)
    800010ec:	ec56                	sd	s5,24(sp)
    800010ee:	e85a                	sd	s6,16(sp)
    800010f0:	e45e                	sd	s7,8(sp)
    800010f2:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010f4:	c639                	beqz	a2,80001142 <mappages+0x64>
    800010f6:	8aaa                	mv	s5,a0
    800010f8:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010fa:	777d                	lui	a4,0xfffff
    800010fc:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001100:	fff58993          	addi	s3,a1,-1
    80001104:	99b2                	add	s3,s3,a2
    80001106:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    8000110a:	893e                	mv	s2,a5
    8000110c:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001110:	6b85                	lui	s7,0x1
    80001112:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001116:	4605                	li	a2,1
    80001118:	85ca                	mv	a1,s2
    8000111a:	8556                	mv	a0,s5
    8000111c:	00000097          	auipc	ra,0x0
    80001120:	eda080e7          	jalr	-294(ra) # 80000ff6 <walk>
    80001124:	cd1d                	beqz	a0,80001162 <mappages+0x84>
    if(*pte & PTE_V)
    80001126:	611c                	ld	a5,0(a0)
    80001128:	8b85                	andi	a5,a5,1
    8000112a:	e785                	bnez	a5,80001152 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000112c:	80b1                	srli	s1,s1,0xc
    8000112e:	04aa                	slli	s1,s1,0xa
    80001130:	0164e4b3          	or	s1,s1,s6
    80001134:	0014e493          	ori	s1,s1,1
    80001138:	e104                	sd	s1,0(a0)
    if(a == last)
    8000113a:	05390063          	beq	s2,s3,8000117a <mappages+0x9c>
    a += PGSIZE;
    8000113e:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001140:	bfc9                	j	80001112 <mappages+0x34>
    panic("mappages: size");
    80001142:	00007517          	auipc	a0,0x7
    80001146:	f9650513          	addi	a0,a0,-106 # 800080d8 <digits+0x98>
    8000114a:	fffff097          	auipc	ra,0xfffff
    8000114e:	3f0080e7          	jalr	1008(ra) # 8000053a <panic>
      panic("mappages: remap");
    80001152:	00007517          	auipc	a0,0x7
    80001156:	f9650513          	addi	a0,a0,-106 # 800080e8 <digits+0xa8>
    8000115a:	fffff097          	auipc	ra,0xfffff
    8000115e:	3e0080e7          	jalr	992(ra) # 8000053a <panic>
      return -1;
    80001162:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001164:	60a6                	ld	ra,72(sp)
    80001166:	6406                	ld	s0,64(sp)
    80001168:	74e2                	ld	s1,56(sp)
    8000116a:	7942                	ld	s2,48(sp)
    8000116c:	79a2                	ld	s3,40(sp)
    8000116e:	7a02                	ld	s4,32(sp)
    80001170:	6ae2                	ld	s5,24(sp)
    80001172:	6b42                	ld	s6,16(sp)
    80001174:	6ba2                	ld	s7,8(sp)
    80001176:	6161                	addi	sp,sp,80
    80001178:	8082                	ret
  return 0;
    8000117a:	4501                	li	a0,0
    8000117c:	b7e5                	j	80001164 <mappages+0x86>

000000008000117e <kvmmap>:
{
    8000117e:	1141                	addi	sp,sp,-16
    80001180:	e406                	sd	ra,8(sp)
    80001182:	e022                	sd	s0,0(sp)
    80001184:	0800                	addi	s0,sp,16
    80001186:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001188:	86b2                	mv	a3,a2
    8000118a:	863e                	mv	a2,a5
    8000118c:	00000097          	auipc	ra,0x0
    80001190:	f52080e7          	jalr	-174(ra) # 800010de <mappages>
    80001194:	e509                	bnez	a0,8000119e <kvmmap+0x20>
}
    80001196:	60a2                	ld	ra,8(sp)
    80001198:	6402                	ld	s0,0(sp)
    8000119a:	0141                	addi	sp,sp,16
    8000119c:	8082                	ret
    panic("kvmmap");
    8000119e:	00007517          	auipc	a0,0x7
    800011a2:	f5a50513          	addi	a0,a0,-166 # 800080f8 <digits+0xb8>
    800011a6:	fffff097          	auipc	ra,0xfffff
    800011aa:	394080e7          	jalr	916(ra) # 8000053a <panic>

00000000800011ae <kvmmake>:
{
    800011ae:	1101                	addi	sp,sp,-32
    800011b0:	ec06                	sd	ra,24(sp)
    800011b2:	e822                	sd	s0,16(sp)
    800011b4:	e426                	sd	s1,8(sp)
    800011b6:	e04a                	sd	s2,0(sp)
    800011b8:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800011ba:	00000097          	auipc	ra,0x0
    800011be:	926080e7          	jalr	-1754(ra) # 80000ae0 <kalloc>
    800011c2:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800011c4:	6605                	lui	a2,0x1
    800011c6:	4581                	li	a1,0
    800011c8:	00000097          	auipc	ra,0x0
    800011cc:	b4e080e7          	jalr	-1202(ra) # 80000d16 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011d0:	4719                	li	a4,6
    800011d2:	6685                	lui	a3,0x1
    800011d4:	10000637          	lui	a2,0x10000
    800011d8:	100005b7          	lui	a1,0x10000
    800011dc:	8526                	mv	a0,s1
    800011de:	00000097          	auipc	ra,0x0
    800011e2:	fa0080e7          	jalr	-96(ra) # 8000117e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011e6:	4719                	li	a4,6
    800011e8:	6685                	lui	a3,0x1
    800011ea:	10001637          	lui	a2,0x10001
    800011ee:	100015b7          	lui	a1,0x10001
    800011f2:	8526                	mv	a0,s1
    800011f4:	00000097          	auipc	ra,0x0
    800011f8:	f8a080e7          	jalr	-118(ra) # 8000117e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011fc:	4719                	li	a4,6
    800011fe:	004006b7          	lui	a3,0x400
    80001202:	0c000637          	lui	a2,0xc000
    80001206:	0c0005b7          	lui	a1,0xc000
    8000120a:	8526                	mv	a0,s1
    8000120c:	00000097          	auipc	ra,0x0
    80001210:	f72080e7          	jalr	-142(ra) # 8000117e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001214:	00007917          	auipc	s2,0x7
    80001218:	dec90913          	addi	s2,s2,-532 # 80008000 <etext>
    8000121c:	4729                	li	a4,10
    8000121e:	80007697          	auipc	a3,0x80007
    80001222:	de268693          	addi	a3,a3,-542 # 8000 <_entry-0x7fff8000>
    80001226:	4605                	li	a2,1
    80001228:	067e                	slli	a2,a2,0x1f
    8000122a:	85b2                	mv	a1,a2
    8000122c:	8526                	mv	a0,s1
    8000122e:	00000097          	auipc	ra,0x0
    80001232:	f50080e7          	jalr	-176(ra) # 8000117e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001236:	4719                	li	a4,6
    80001238:	46c5                	li	a3,17
    8000123a:	06ee                	slli	a3,a3,0x1b
    8000123c:	412686b3          	sub	a3,a3,s2
    80001240:	864a                	mv	a2,s2
    80001242:	85ca                	mv	a1,s2
    80001244:	8526                	mv	a0,s1
    80001246:	00000097          	auipc	ra,0x0
    8000124a:	f38080e7          	jalr	-200(ra) # 8000117e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000124e:	4729                	li	a4,10
    80001250:	6685                	lui	a3,0x1
    80001252:	00006617          	auipc	a2,0x6
    80001256:	dae60613          	addi	a2,a2,-594 # 80007000 <_trampoline>
    8000125a:	040005b7          	lui	a1,0x4000
    8000125e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001260:	05b2                	slli	a1,a1,0xc
    80001262:	8526                	mv	a0,s1
    80001264:	00000097          	auipc	ra,0x0
    80001268:	f1a080e7          	jalr	-230(ra) # 8000117e <kvmmap>
  proc_mapstacks(kpgtbl);
    8000126c:	8526                	mv	a0,s1
    8000126e:	00000097          	auipc	ra,0x0
    80001272:	5e6080e7          	jalr	1510(ra) # 80001854 <proc_mapstacks>
}
    80001276:	8526                	mv	a0,s1
    80001278:	60e2                	ld	ra,24(sp)
    8000127a:	6442                	ld	s0,16(sp)
    8000127c:	64a2                	ld	s1,8(sp)
    8000127e:	6902                	ld	s2,0(sp)
    80001280:	6105                	addi	sp,sp,32
    80001282:	8082                	ret

0000000080001284 <kvminit>:
{
    80001284:	1141                	addi	sp,sp,-16
    80001286:	e406                	sd	ra,8(sp)
    80001288:	e022                	sd	s0,0(sp)
    8000128a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000128c:	00000097          	auipc	ra,0x0
    80001290:	f22080e7          	jalr	-222(ra) # 800011ae <kvmmake>
    80001294:	00008797          	auipc	a5,0x8
    80001298:	d8a7b623          	sd	a0,-628(a5) # 80009020 <kernel_pagetable>
}
    8000129c:	60a2                	ld	ra,8(sp)
    8000129e:	6402                	ld	s0,0(sp)
    800012a0:	0141                	addi	sp,sp,16
    800012a2:	8082                	ret

00000000800012a4 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800012a4:	715d                	addi	sp,sp,-80
    800012a6:	e486                	sd	ra,72(sp)
    800012a8:	e0a2                	sd	s0,64(sp)
    800012aa:	fc26                	sd	s1,56(sp)
    800012ac:	f84a                	sd	s2,48(sp)
    800012ae:	f44e                	sd	s3,40(sp)
    800012b0:	f052                	sd	s4,32(sp)
    800012b2:	ec56                	sd	s5,24(sp)
    800012b4:	e85a                	sd	s6,16(sp)
    800012b6:	e45e                	sd	s7,8(sp)
    800012b8:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012ba:	03459793          	slli	a5,a1,0x34
    800012be:	e795                	bnez	a5,800012ea <uvmunmap+0x46>
    800012c0:	8a2a                	mv	s4,a0
    800012c2:	892e                	mv	s2,a1
    800012c4:	8b36                	mv	s6,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012c6:	0632                	slli	a2,a2,0xc
    800012c8:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      //panic("uvmunmap: not mapped");
      continue;
    if(PTE_FLAGS(*pte) == PTE_V)
    800012cc:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ce:	6a85                	lui	s5,0x1
    800012d0:	0535ea63          	bltu	a1,s3,80001324 <uvmunmap+0x80>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800012d4:	60a6                	ld	ra,72(sp)
    800012d6:	6406                	ld	s0,64(sp)
    800012d8:	74e2                	ld	s1,56(sp)
    800012da:	7942                	ld	s2,48(sp)
    800012dc:	79a2                	ld	s3,40(sp)
    800012de:	7a02                	ld	s4,32(sp)
    800012e0:	6ae2                	ld	s5,24(sp)
    800012e2:	6b42                	ld	s6,16(sp)
    800012e4:	6ba2                	ld	s7,8(sp)
    800012e6:	6161                	addi	sp,sp,80
    800012e8:	8082                	ret
    panic("uvmunmap: not aligned");
    800012ea:	00007517          	auipc	a0,0x7
    800012ee:	e1650513          	addi	a0,a0,-490 # 80008100 <digits+0xc0>
    800012f2:	fffff097          	auipc	ra,0xfffff
    800012f6:	248080e7          	jalr	584(ra) # 8000053a <panic>
      panic("uvmunmap: walk");
    800012fa:	00007517          	auipc	a0,0x7
    800012fe:	e1e50513          	addi	a0,a0,-482 # 80008118 <digits+0xd8>
    80001302:	fffff097          	auipc	ra,0xfffff
    80001306:	238080e7          	jalr	568(ra) # 8000053a <panic>
      panic("uvmunmap: not a leaf");
    8000130a:	00007517          	auipc	a0,0x7
    8000130e:	e1e50513          	addi	a0,a0,-482 # 80008128 <digits+0xe8>
    80001312:	fffff097          	auipc	ra,0xfffff
    80001316:	228080e7          	jalr	552(ra) # 8000053a <panic>
    *pte = 0;
    8000131a:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000131e:	9956                	add	s2,s2,s5
    80001320:	fb397ae3          	bgeu	s2,s3,800012d4 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001324:	4601                	li	a2,0
    80001326:	85ca                	mv	a1,s2
    80001328:	8552                	mv	a0,s4
    8000132a:	00000097          	auipc	ra,0x0
    8000132e:	ccc080e7          	jalr	-820(ra) # 80000ff6 <walk>
    80001332:	84aa                	mv	s1,a0
    80001334:	d179                	beqz	a0,800012fa <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001336:	611c                	ld	a5,0(a0)
    80001338:	0017f713          	andi	a4,a5,1
    8000133c:	d36d                	beqz	a4,8000131e <uvmunmap+0x7a>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000133e:	3ff7f713          	andi	a4,a5,1023
    80001342:	fd7704e3          	beq	a4,s7,8000130a <uvmunmap+0x66>
    if(do_free){
    80001346:	fc0b0ae3          	beqz	s6,8000131a <uvmunmap+0x76>
      uint64 pa = PTE2PA(*pte);
    8000134a:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    8000134c:	00c79513          	slli	a0,a5,0xc
    80001350:	fffff097          	auipc	ra,0xfffff
    80001354:	692080e7          	jalr	1682(ra) # 800009e2 <kfree>
    80001358:	b7c9                	j	8000131a <uvmunmap+0x76>

000000008000135a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000135a:	1101                	addi	sp,sp,-32
    8000135c:	ec06                	sd	ra,24(sp)
    8000135e:	e822                	sd	s0,16(sp)
    80001360:	e426                	sd	s1,8(sp)
    80001362:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001364:	fffff097          	auipc	ra,0xfffff
    80001368:	77c080e7          	jalr	1916(ra) # 80000ae0 <kalloc>
    8000136c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000136e:	c519                	beqz	a0,8000137c <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001370:	6605                	lui	a2,0x1
    80001372:	4581                	li	a1,0
    80001374:	00000097          	auipc	ra,0x0
    80001378:	9a2080e7          	jalr	-1630(ra) # 80000d16 <memset>
  return pagetable;
}
    8000137c:	8526                	mv	a0,s1
    8000137e:	60e2                	ld	ra,24(sp)
    80001380:	6442                	ld	s0,16(sp)
    80001382:	64a2                	ld	s1,8(sp)
    80001384:	6105                	addi	sp,sp,32
    80001386:	8082                	ret

0000000080001388 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001388:	7179                	addi	sp,sp,-48
    8000138a:	f406                	sd	ra,40(sp)
    8000138c:	f022                	sd	s0,32(sp)
    8000138e:	ec26                	sd	s1,24(sp)
    80001390:	e84a                	sd	s2,16(sp)
    80001392:	e44e                	sd	s3,8(sp)
    80001394:	e052                	sd	s4,0(sp)
    80001396:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001398:	6785                	lui	a5,0x1
    8000139a:	04f67863          	bgeu	a2,a5,800013ea <uvminit+0x62>
    8000139e:	8a2a                	mv	s4,a0
    800013a0:	89ae                	mv	s3,a1
    800013a2:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    800013a4:	fffff097          	auipc	ra,0xfffff
    800013a8:	73c080e7          	jalr	1852(ra) # 80000ae0 <kalloc>
    800013ac:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800013ae:	6605                	lui	a2,0x1
    800013b0:	4581                	li	a1,0
    800013b2:	00000097          	auipc	ra,0x0
    800013b6:	964080e7          	jalr	-1692(ra) # 80000d16 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800013ba:	4779                	li	a4,30
    800013bc:	86ca                	mv	a3,s2
    800013be:	6605                	lui	a2,0x1
    800013c0:	4581                	li	a1,0
    800013c2:	8552                	mv	a0,s4
    800013c4:	00000097          	auipc	ra,0x0
    800013c8:	d1a080e7          	jalr	-742(ra) # 800010de <mappages>
  memmove(mem, src, sz);
    800013cc:	8626                	mv	a2,s1
    800013ce:	85ce                	mv	a1,s3
    800013d0:	854a                	mv	a0,s2
    800013d2:	00000097          	auipc	ra,0x0
    800013d6:	9a0080e7          	jalr	-1632(ra) # 80000d72 <memmove>
}
    800013da:	70a2                	ld	ra,40(sp)
    800013dc:	7402                	ld	s0,32(sp)
    800013de:	64e2                	ld	s1,24(sp)
    800013e0:	6942                	ld	s2,16(sp)
    800013e2:	69a2                	ld	s3,8(sp)
    800013e4:	6a02                	ld	s4,0(sp)
    800013e6:	6145                	addi	sp,sp,48
    800013e8:	8082                	ret
    panic("inituvm: more than a page");
    800013ea:	00007517          	auipc	a0,0x7
    800013ee:	d5650513          	addi	a0,a0,-682 # 80008140 <digits+0x100>
    800013f2:	fffff097          	auipc	ra,0xfffff
    800013f6:	148080e7          	jalr	328(ra) # 8000053a <panic>

00000000800013fa <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013fa:	1101                	addi	sp,sp,-32
    800013fc:	ec06                	sd	ra,24(sp)
    800013fe:	e822                	sd	s0,16(sp)
    80001400:	e426                	sd	s1,8(sp)
    80001402:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001404:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001406:	00b67d63          	bgeu	a2,a1,80001420 <uvmdealloc+0x26>
    8000140a:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000140c:	6785                	lui	a5,0x1
    8000140e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001410:	00f60733          	add	a4,a2,a5
    80001414:	76fd                	lui	a3,0xfffff
    80001416:	8f75                	and	a4,a4,a3
    80001418:	97ae                	add	a5,a5,a1
    8000141a:	8ff5                	and	a5,a5,a3
    8000141c:	00f76863          	bltu	a4,a5,8000142c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001420:	8526                	mv	a0,s1
    80001422:	60e2                	ld	ra,24(sp)
    80001424:	6442                	ld	s0,16(sp)
    80001426:	64a2                	ld	s1,8(sp)
    80001428:	6105                	addi	sp,sp,32
    8000142a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000142c:	8f99                	sub	a5,a5,a4
    8000142e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001430:	4685                	li	a3,1
    80001432:	0007861b          	sext.w	a2,a5
    80001436:	85ba                	mv	a1,a4
    80001438:	00000097          	auipc	ra,0x0
    8000143c:	e6c080e7          	jalr	-404(ra) # 800012a4 <uvmunmap>
    80001440:	b7c5                	j	80001420 <uvmdealloc+0x26>

0000000080001442 <uvmalloc>:
  if(newsz < oldsz)
    80001442:	0ab66163          	bltu	a2,a1,800014e4 <uvmalloc+0xa2>
{
    80001446:	7139                	addi	sp,sp,-64
    80001448:	fc06                	sd	ra,56(sp)
    8000144a:	f822                	sd	s0,48(sp)
    8000144c:	f426                	sd	s1,40(sp)
    8000144e:	f04a                	sd	s2,32(sp)
    80001450:	ec4e                	sd	s3,24(sp)
    80001452:	e852                	sd	s4,16(sp)
    80001454:	e456                	sd	s5,8(sp)
    80001456:	0080                	addi	s0,sp,64
    80001458:	8aaa                	mv	s5,a0
    8000145a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000145c:	6785                	lui	a5,0x1
    8000145e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001460:	95be                	add	a1,a1,a5
    80001462:	77fd                	lui	a5,0xfffff
    80001464:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001468:	08c9f063          	bgeu	s3,a2,800014e8 <uvmalloc+0xa6>
    8000146c:	894e                	mv	s2,s3
    mem = kalloc();
    8000146e:	fffff097          	auipc	ra,0xfffff
    80001472:	672080e7          	jalr	1650(ra) # 80000ae0 <kalloc>
    80001476:	84aa                	mv	s1,a0
    if(mem == 0){
    80001478:	c51d                	beqz	a0,800014a6 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000147a:	6605                	lui	a2,0x1
    8000147c:	4581                	li	a1,0
    8000147e:	00000097          	auipc	ra,0x0
    80001482:	898080e7          	jalr	-1896(ra) # 80000d16 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001486:	4779                	li	a4,30
    80001488:	86a6                	mv	a3,s1
    8000148a:	6605                	lui	a2,0x1
    8000148c:	85ca                	mv	a1,s2
    8000148e:	8556                	mv	a0,s5
    80001490:	00000097          	auipc	ra,0x0
    80001494:	c4e080e7          	jalr	-946(ra) # 800010de <mappages>
    80001498:	e905                	bnez	a0,800014c8 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000149a:	6785                	lui	a5,0x1
    8000149c:	993e                	add	s2,s2,a5
    8000149e:	fd4968e3          	bltu	s2,s4,8000146e <uvmalloc+0x2c>
  return newsz;
    800014a2:	8552                	mv	a0,s4
    800014a4:	a809                	j	800014b6 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    800014a6:	864e                	mv	a2,s3
    800014a8:	85ca                	mv	a1,s2
    800014aa:	8556                	mv	a0,s5
    800014ac:	00000097          	auipc	ra,0x0
    800014b0:	f4e080e7          	jalr	-178(ra) # 800013fa <uvmdealloc>
      return 0;
    800014b4:	4501                	li	a0,0
}
    800014b6:	70e2                	ld	ra,56(sp)
    800014b8:	7442                	ld	s0,48(sp)
    800014ba:	74a2                	ld	s1,40(sp)
    800014bc:	7902                	ld	s2,32(sp)
    800014be:	69e2                	ld	s3,24(sp)
    800014c0:	6a42                	ld	s4,16(sp)
    800014c2:	6aa2                	ld	s5,8(sp)
    800014c4:	6121                	addi	sp,sp,64
    800014c6:	8082                	ret
      kfree(mem);
    800014c8:	8526                	mv	a0,s1
    800014ca:	fffff097          	auipc	ra,0xfffff
    800014ce:	518080e7          	jalr	1304(ra) # 800009e2 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014d2:	864e                	mv	a2,s3
    800014d4:	85ca                	mv	a1,s2
    800014d6:	8556                	mv	a0,s5
    800014d8:	00000097          	auipc	ra,0x0
    800014dc:	f22080e7          	jalr	-222(ra) # 800013fa <uvmdealloc>
      return 0;
    800014e0:	4501                	li	a0,0
    800014e2:	bfd1                	j	800014b6 <uvmalloc+0x74>
    return oldsz;
    800014e4:	852e                	mv	a0,a1
}
    800014e6:	8082                	ret
  return newsz;
    800014e8:	8532                	mv	a0,a2
    800014ea:	b7f1                	j	800014b6 <uvmalloc+0x74>

00000000800014ec <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014ec:	7179                	addi	sp,sp,-48
    800014ee:	f406                	sd	ra,40(sp)
    800014f0:	f022                	sd	s0,32(sp)
    800014f2:	ec26                	sd	s1,24(sp)
    800014f4:	e84a                	sd	s2,16(sp)
    800014f6:	e44e                	sd	s3,8(sp)
    800014f8:	e052                	sd	s4,0(sp)
    800014fa:	1800                	addi	s0,sp,48
    800014fc:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014fe:	84aa                	mv	s1,a0
    80001500:	6905                	lui	s2,0x1
    80001502:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001504:	4985                	li	s3,1
    80001506:	a829                	j	80001520 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001508:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    8000150a:	00c79513          	slli	a0,a5,0xc
    8000150e:	00000097          	auipc	ra,0x0
    80001512:	fde080e7          	jalr	-34(ra) # 800014ec <freewalk>
      pagetable[i] = 0;
    80001516:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000151a:	04a1                	addi	s1,s1,8
    8000151c:	03248163          	beq	s1,s2,8000153e <freewalk+0x52>
    pte_t pte = pagetable[i];
    80001520:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001522:	00f7f713          	andi	a4,a5,15
    80001526:	ff3701e3          	beq	a4,s3,80001508 <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000152a:	8b85                	andi	a5,a5,1
    8000152c:	d7fd                	beqz	a5,8000151a <freewalk+0x2e>
      panic("freewalk: leaf");
    8000152e:	00007517          	auipc	a0,0x7
    80001532:	c3250513          	addi	a0,a0,-974 # 80008160 <digits+0x120>
    80001536:	fffff097          	auipc	ra,0xfffff
    8000153a:	004080e7          	jalr	4(ra) # 8000053a <panic>
    }
  }
  kfree((void*)pagetable);
    8000153e:	8552                	mv	a0,s4
    80001540:	fffff097          	auipc	ra,0xfffff
    80001544:	4a2080e7          	jalr	1186(ra) # 800009e2 <kfree>
}
    80001548:	70a2                	ld	ra,40(sp)
    8000154a:	7402                	ld	s0,32(sp)
    8000154c:	64e2                	ld	s1,24(sp)
    8000154e:	6942                	ld	s2,16(sp)
    80001550:	69a2                	ld	s3,8(sp)
    80001552:	6a02                	ld	s4,0(sp)
    80001554:	6145                	addi	sp,sp,48
    80001556:	8082                	ret

0000000080001558 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001558:	1101                	addi	sp,sp,-32
    8000155a:	ec06                	sd	ra,24(sp)
    8000155c:	e822                	sd	s0,16(sp)
    8000155e:	e426                	sd	s1,8(sp)
    80001560:	1000                	addi	s0,sp,32
    80001562:	84aa                	mv	s1,a0
  if(sz > 0)
    80001564:	e999                	bnez	a1,8000157a <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001566:	8526                	mv	a0,s1
    80001568:	00000097          	auipc	ra,0x0
    8000156c:	f84080e7          	jalr	-124(ra) # 800014ec <freewalk>
}
    80001570:	60e2                	ld	ra,24(sp)
    80001572:	6442                	ld	s0,16(sp)
    80001574:	64a2                	ld	s1,8(sp)
    80001576:	6105                	addi	sp,sp,32
    80001578:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000157a:	6785                	lui	a5,0x1
    8000157c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000157e:	95be                	add	a1,a1,a5
    80001580:	4685                	li	a3,1
    80001582:	00c5d613          	srli	a2,a1,0xc
    80001586:	4581                	li	a1,0
    80001588:	00000097          	auipc	ra,0x0
    8000158c:	d1c080e7          	jalr	-740(ra) # 800012a4 <uvmunmap>
    80001590:	bfd9                	j	80001566 <uvmfree+0xe>

0000000080001592 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001592:	c269                	beqz	a2,80001654 <uvmcopy+0xc2>
{
    80001594:	715d                	addi	sp,sp,-80
    80001596:	e486                	sd	ra,72(sp)
    80001598:	e0a2                	sd	s0,64(sp)
    8000159a:	fc26                	sd	s1,56(sp)
    8000159c:	f84a                	sd	s2,48(sp)
    8000159e:	f44e                	sd	s3,40(sp)
    800015a0:	f052                	sd	s4,32(sp)
    800015a2:	ec56                	sd	s5,24(sp)
    800015a4:	e85a                	sd	s6,16(sp)
    800015a6:	e45e                	sd	s7,8(sp)
    800015a8:	0880                	addi	s0,sp,80
    800015aa:	8aaa                	mv	s5,a0
    800015ac:	8b2e                	mv	s6,a1
    800015ae:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800015b0:	4481                	li	s1,0
    800015b2:	a829                	j	800015cc <uvmcopy+0x3a>
    if((pte = walk(old, i, 0)) == 0)
      panic("uvmcopy: pte should exist");
    800015b4:	00007517          	auipc	a0,0x7
    800015b8:	bbc50513          	addi	a0,a0,-1092 # 80008170 <digits+0x130>
    800015bc:	fffff097          	auipc	ra,0xfffff
    800015c0:	f7e080e7          	jalr	-130(ra) # 8000053a <panic>
  for(i = 0; i < sz; i += PGSIZE){
    800015c4:	6785                	lui	a5,0x1
    800015c6:	94be                	add	s1,s1,a5
    800015c8:	0944f463          	bgeu	s1,s4,80001650 <uvmcopy+0xbe>
    if((pte = walk(old, i, 0)) == 0)
    800015cc:	4601                	li	a2,0
    800015ce:	85a6                	mv	a1,s1
    800015d0:	8556                	mv	a0,s5
    800015d2:	00000097          	auipc	ra,0x0
    800015d6:	a24080e7          	jalr	-1500(ra) # 80000ff6 <walk>
    800015da:	dd69                	beqz	a0,800015b4 <uvmcopy+0x22>
    if((*pte & PTE_V) == 0)
    800015dc:	6118                	ld	a4,0(a0)
    800015de:	00177793          	andi	a5,a4,1
    800015e2:	d3ed                	beqz	a5,800015c4 <uvmcopy+0x32>
      //panic("uvmcopy: page not present");
      continue;
    pa = PTE2PA(*pte);
    800015e4:	00a75593          	srli	a1,a4,0xa
    800015e8:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015ec:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    800015f0:	fffff097          	auipc	ra,0xfffff
    800015f4:	4f0080e7          	jalr	1264(ra) # 80000ae0 <kalloc>
    800015f8:	89aa                	mv	s3,a0
    800015fa:	c515                	beqz	a0,80001626 <uvmcopy+0x94>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015fc:	6605                	lui	a2,0x1
    800015fe:	85de                	mv	a1,s7
    80001600:	fffff097          	auipc	ra,0xfffff
    80001604:	772080e7          	jalr	1906(ra) # 80000d72 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001608:	874a                	mv	a4,s2
    8000160a:	86ce                	mv	a3,s3
    8000160c:	6605                	lui	a2,0x1
    8000160e:	85a6                	mv	a1,s1
    80001610:	855a                	mv	a0,s6
    80001612:	00000097          	auipc	ra,0x0
    80001616:	acc080e7          	jalr	-1332(ra) # 800010de <mappages>
    8000161a:	d54d                	beqz	a0,800015c4 <uvmcopy+0x32>
      kfree(mem);
    8000161c:	854e                	mv	a0,s3
    8000161e:	fffff097          	auipc	ra,0xfffff
    80001622:	3c4080e7          	jalr	964(ra) # 800009e2 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001626:	4685                	li	a3,1
    80001628:	00c4d613          	srli	a2,s1,0xc
    8000162c:	4581                	li	a1,0
    8000162e:	855a                	mv	a0,s6
    80001630:	00000097          	auipc	ra,0x0
    80001634:	c74080e7          	jalr	-908(ra) # 800012a4 <uvmunmap>
  return -1;
    80001638:	557d                	li	a0,-1
}
    8000163a:	60a6                	ld	ra,72(sp)
    8000163c:	6406                	ld	s0,64(sp)
    8000163e:	74e2                	ld	s1,56(sp)
    80001640:	7942                	ld	s2,48(sp)
    80001642:	79a2                	ld	s3,40(sp)
    80001644:	7a02                	ld	s4,32(sp)
    80001646:	6ae2                	ld	s5,24(sp)
    80001648:	6b42                	ld	s6,16(sp)
    8000164a:	6ba2                	ld	s7,8(sp)
    8000164c:	6161                	addi	sp,sp,80
    8000164e:	8082                	ret
  return 0;
    80001650:	4501                	li	a0,0
    80001652:	b7e5                	j	8000163a <uvmcopy+0xa8>
    80001654:	4501                	li	a0,0
}
    80001656:	8082                	ret

0000000080001658 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001658:	1141                	addi	sp,sp,-16
    8000165a:	e406                	sd	ra,8(sp)
    8000165c:	e022                	sd	s0,0(sp)
    8000165e:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001660:	4601                	li	a2,0
    80001662:	00000097          	auipc	ra,0x0
    80001666:	994080e7          	jalr	-1644(ra) # 80000ff6 <walk>
  if(pte == 0)
    8000166a:	c901                	beqz	a0,8000167a <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000166c:	611c                	ld	a5,0(a0)
    8000166e:	9bbd                	andi	a5,a5,-17
    80001670:	e11c                	sd	a5,0(a0)
}
    80001672:	60a2                	ld	ra,8(sp)
    80001674:	6402                	ld	s0,0(sp)
    80001676:	0141                	addi	sp,sp,16
    80001678:	8082                	ret
    panic("uvmclear");
    8000167a:	00007517          	auipc	a0,0x7
    8000167e:	b1650513          	addi	a0,a0,-1258 # 80008190 <digits+0x150>
    80001682:	fffff097          	auipc	ra,0xfffff
    80001686:	eb8080e7          	jalr	-328(ra) # 8000053a <panic>

000000008000168a <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000168a:	c6bd                	beqz	a3,800016f8 <copyout+0x6e>
{
    8000168c:	715d                	addi	sp,sp,-80
    8000168e:	e486                	sd	ra,72(sp)
    80001690:	e0a2                	sd	s0,64(sp)
    80001692:	fc26                	sd	s1,56(sp)
    80001694:	f84a                	sd	s2,48(sp)
    80001696:	f44e                	sd	s3,40(sp)
    80001698:	f052                	sd	s4,32(sp)
    8000169a:	ec56                	sd	s5,24(sp)
    8000169c:	e85a                	sd	s6,16(sp)
    8000169e:	e45e                	sd	s7,8(sp)
    800016a0:	e062                	sd	s8,0(sp)
    800016a2:	0880                	addi	s0,sp,80
    800016a4:	8b2a                	mv	s6,a0
    800016a6:	8c2e                	mv	s8,a1
    800016a8:	8a32                	mv	s4,a2
    800016aa:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800016ac:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800016ae:	6a85                	lui	s5,0x1
    800016b0:	a015                	j	800016d4 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800016b2:	9562                	add	a0,a0,s8
    800016b4:	0004861b          	sext.w	a2,s1
    800016b8:	85d2                	mv	a1,s4
    800016ba:	41250533          	sub	a0,a0,s2
    800016be:	fffff097          	auipc	ra,0xfffff
    800016c2:	6b4080e7          	jalr	1716(ra) # 80000d72 <memmove>

    len -= n;
    800016c6:	409989b3          	sub	s3,s3,s1
    src += n;
    800016ca:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016cc:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016d0:	02098263          	beqz	s3,800016f4 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016d4:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016d8:	85ca                	mv	a1,s2
    800016da:	855a                	mv	a0,s6
    800016dc:	00000097          	auipc	ra,0x0
    800016e0:	9c0080e7          	jalr	-1600(ra) # 8000109c <walkaddr>
    if(pa0 == 0)
    800016e4:	cd01                	beqz	a0,800016fc <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016e6:	418904b3          	sub	s1,s2,s8
    800016ea:	94d6                	add	s1,s1,s5
    800016ec:	fc99f3e3          	bgeu	s3,s1,800016b2 <copyout+0x28>
    800016f0:	84ce                	mv	s1,s3
    800016f2:	b7c1                	j	800016b2 <copyout+0x28>
  }
  return 0;
    800016f4:	4501                	li	a0,0
    800016f6:	a021                	j	800016fe <copyout+0x74>
    800016f8:	4501                	li	a0,0
}
    800016fa:	8082                	ret
      return -1;
    800016fc:	557d                	li	a0,-1
}
    800016fe:	60a6                	ld	ra,72(sp)
    80001700:	6406                	ld	s0,64(sp)
    80001702:	74e2                	ld	s1,56(sp)
    80001704:	7942                	ld	s2,48(sp)
    80001706:	79a2                	ld	s3,40(sp)
    80001708:	7a02                	ld	s4,32(sp)
    8000170a:	6ae2                	ld	s5,24(sp)
    8000170c:	6b42                	ld	s6,16(sp)
    8000170e:	6ba2                	ld	s7,8(sp)
    80001710:	6c02                	ld	s8,0(sp)
    80001712:	6161                	addi	sp,sp,80
    80001714:	8082                	ret

0000000080001716 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001716:	caa5                	beqz	a3,80001786 <copyin+0x70>
{
    80001718:	715d                	addi	sp,sp,-80
    8000171a:	e486                	sd	ra,72(sp)
    8000171c:	e0a2                	sd	s0,64(sp)
    8000171e:	fc26                	sd	s1,56(sp)
    80001720:	f84a                	sd	s2,48(sp)
    80001722:	f44e                	sd	s3,40(sp)
    80001724:	f052                	sd	s4,32(sp)
    80001726:	ec56                	sd	s5,24(sp)
    80001728:	e85a                	sd	s6,16(sp)
    8000172a:	e45e                	sd	s7,8(sp)
    8000172c:	e062                	sd	s8,0(sp)
    8000172e:	0880                	addi	s0,sp,80
    80001730:	8b2a                	mv	s6,a0
    80001732:	8a2e                	mv	s4,a1
    80001734:	8c32                	mv	s8,a2
    80001736:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001738:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000173a:	6a85                	lui	s5,0x1
    8000173c:	a01d                	j	80001762 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000173e:	018505b3          	add	a1,a0,s8
    80001742:	0004861b          	sext.w	a2,s1
    80001746:	412585b3          	sub	a1,a1,s2
    8000174a:	8552                	mv	a0,s4
    8000174c:	fffff097          	auipc	ra,0xfffff
    80001750:	626080e7          	jalr	1574(ra) # 80000d72 <memmove>

    len -= n;
    80001754:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001758:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000175a:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000175e:	02098263          	beqz	s3,80001782 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001762:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001766:	85ca                	mv	a1,s2
    80001768:	855a                	mv	a0,s6
    8000176a:	00000097          	auipc	ra,0x0
    8000176e:	932080e7          	jalr	-1742(ra) # 8000109c <walkaddr>
    if(pa0 == 0)
    80001772:	cd01                	beqz	a0,8000178a <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001774:	418904b3          	sub	s1,s2,s8
    80001778:	94d6                	add	s1,s1,s5
    8000177a:	fc99f2e3          	bgeu	s3,s1,8000173e <copyin+0x28>
    8000177e:	84ce                	mv	s1,s3
    80001780:	bf7d                	j	8000173e <copyin+0x28>
  }
  return 0;
    80001782:	4501                	li	a0,0
    80001784:	a021                	j	8000178c <copyin+0x76>
    80001786:	4501                	li	a0,0
}
    80001788:	8082                	ret
      return -1;
    8000178a:	557d                	li	a0,-1
}
    8000178c:	60a6                	ld	ra,72(sp)
    8000178e:	6406                	ld	s0,64(sp)
    80001790:	74e2                	ld	s1,56(sp)
    80001792:	7942                	ld	s2,48(sp)
    80001794:	79a2                	ld	s3,40(sp)
    80001796:	7a02                	ld	s4,32(sp)
    80001798:	6ae2                	ld	s5,24(sp)
    8000179a:	6b42                	ld	s6,16(sp)
    8000179c:	6ba2                	ld	s7,8(sp)
    8000179e:	6c02                	ld	s8,0(sp)
    800017a0:	6161                	addi	sp,sp,80
    800017a2:	8082                	ret

00000000800017a4 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800017a4:	c2dd                	beqz	a3,8000184a <copyinstr+0xa6>
{
    800017a6:	715d                	addi	sp,sp,-80
    800017a8:	e486                	sd	ra,72(sp)
    800017aa:	e0a2                	sd	s0,64(sp)
    800017ac:	fc26                	sd	s1,56(sp)
    800017ae:	f84a                	sd	s2,48(sp)
    800017b0:	f44e                	sd	s3,40(sp)
    800017b2:	f052                	sd	s4,32(sp)
    800017b4:	ec56                	sd	s5,24(sp)
    800017b6:	e85a                	sd	s6,16(sp)
    800017b8:	e45e                	sd	s7,8(sp)
    800017ba:	0880                	addi	s0,sp,80
    800017bc:	8a2a                	mv	s4,a0
    800017be:	8b2e                	mv	s6,a1
    800017c0:	8bb2                	mv	s7,a2
    800017c2:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017c4:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017c6:	6985                	lui	s3,0x1
    800017c8:	a02d                	j	800017f2 <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017ca:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017ce:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017d0:	37fd                	addiw	a5,a5,-1
    800017d2:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017d6:	60a6                	ld	ra,72(sp)
    800017d8:	6406                	ld	s0,64(sp)
    800017da:	74e2                	ld	s1,56(sp)
    800017dc:	7942                	ld	s2,48(sp)
    800017de:	79a2                	ld	s3,40(sp)
    800017e0:	7a02                	ld	s4,32(sp)
    800017e2:	6ae2                	ld	s5,24(sp)
    800017e4:	6b42                	ld	s6,16(sp)
    800017e6:	6ba2                	ld	s7,8(sp)
    800017e8:	6161                	addi	sp,sp,80
    800017ea:	8082                	ret
    srcva = va0 + PGSIZE;
    800017ec:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017f0:	c8a9                	beqz	s1,80001842 <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017f2:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017f6:	85ca                	mv	a1,s2
    800017f8:	8552                	mv	a0,s4
    800017fa:	00000097          	auipc	ra,0x0
    800017fe:	8a2080e7          	jalr	-1886(ra) # 8000109c <walkaddr>
    if(pa0 == 0)
    80001802:	c131                	beqz	a0,80001846 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80001804:	417906b3          	sub	a3,s2,s7
    80001808:	96ce                	add	a3,a3,s3
    8000180a:	00d4f363          	bgeu	s1,a3,80001810 <copyinstr+0x6c>
    8000180e:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001810:	955e                	add	a0,a0,s7
    80001812:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001816:	daf9                	beqz	a3,800017ec <copyinstr+0x48>
    80001818:	87da                	mv	a5,s6
      if(*p == '\0'){
    8000181a:	41650633          	sub	a2,a0,s6
    8000181e:	fff48593          	addi	a1,s1,-1
    80001822:	95da                	add	a1,a1,s6
    while(n > 0){
    80001824:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    80001826:	00f60733          	add	a4,a2,a5
    8000182a:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd9000>
    8000182e:	df51                	beqz	a4,800017ca <copyinstr+0x26>
        *dst = *p;
    80001830:	00e78023          	sb	a4,0(a5)
      --max;
    80001834:	40f584b3          	sub	s1,a1,a5
      dst++;
    80001838:	0785                	addi	a5,a5,1
    while(n > 0){
    8000183a:	fed796e3          	bne	a5,a3,80001826 <copyinstr+0x82>
      dst++;
    8000183e:	8b3e                	mv	s6,a5
    80001840:	b775                	j	800017ec <copyinstr+0x48>
    80001842:	4781                	li	a5,0
    80001844:	b771                	j	800017d0 <copyinstr+0x2c>
      return -1;
    80001846:	557d                	li	a0,-1
    80001848:	b779                	j	800017d6 <copyinstr+0x32>
  int got_null = 0;
    8000184a:	4781                	li	a5,0
  if(got_null){
    8000184c:	37fd                	addiw	a5,a5,-1
    8000184e:	0007851b          	sext.w	a0,a5
}
    80001852:	8082                	ret

0000000080001854 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    80001854:	7139                	addi	sp,sp,-64
    80001856:	fc06                	sd	ra,56(sp)
    80001858:	f822                	sd	s0,48(sp)
    8000185a:	f426                	sd	s1,40(sp)
    8000185c:	f04a                	sd	s2,32(sp)
    8000185e:	ec4e                	sd	s3,24(sp)
    80001860:	e852                	sd	s4,16(sp)
    80001862:	e456                	sd	s5,8(sp)
    80001864:	e05a                	sd	s6,0(sp)
    80001866:	0080                	addi	s0,sp,64
    80001868:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000186a:	00010497          	auipc	s1,0x10
    8000186e:	e6648493          	addi	s1,s1,-410 # 800116d0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001872:	8b26                	mv	s6,s1
    80001874:	00006a97          	auipc	s5,0x6
    80001878:	78ca8a93          	addi	s5,s5,1932 # 80008000 <etext>
    8000187c:	04000937          	lui	s2,0x4000
    80001880:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001882:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001884:	00016a17          	auipc	s4,0x16
    80001888:	c4ca0a13          	addi	s4,s4,-948 # 800174d0 <tickslock>
    char *pa = kalloc();
    8000188c:	fffff097          	auipc	ra,0xfffff
    80001890:	254080e7          	jalr	596(ra) # 80000ae0 <kalloc>
    80001894:	862a                	mv	a2,a0
    if(pa == 0)
    80001896:	c131                	beqz	a0,800018da <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001898:	416485b3          	sub	a1,s1,s6
    8000189c:	858d                	srai	a1,a1,0x3
    8000189e:	000ab783          	ld	a5,0(s5)
    800018a2:	02f585b3          	mul	a1,a1,a5
    800018a6:	2585                	addiw	a1,a1,1
    800018a8:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800018ac:	4719                	li	a4,6
    800018ae:	6685                	lui	a3,0x1
    800018b0:	40b905b3          	sub	a1,s2,a1
    800018b4:	854e                	mv	a0,s3
    800018b6:	00000097          	auipc	ra,0x0
    800018ba:	8c8080e7          	jalr	-1848(ra) # 8000117e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018be:	17848493          	addi	s1,s1,376
    800018c2:	fd4495e3          	bne	s1,s4,8000188c <proc_mapstacks+0x38>
  }
}
    800018c6:	70e2                	ld	ra,56(sp)
    800018c8:	7442                	ld	s0,48(sp)
    800018ca:	74a2                	ld	s1,40(sp)
    800018cc:	7902                	ld	s2,32(sp)
    800018ce:	69e2                	ld	s3,24(sp)
    800018d0:	6a42                	ld	s4,16(sp)
    800018d2:	6aa2                	ld	s5,8(sp)
    800018d4:	6b02                	ld	s6,0(sp)
    800018d6:	6121                	addi	sp,sp,64
    800018d8:	8082                	ret
      panic("kalloc");
    800018da:	00007517          	auipc	a0,0x7
    800018de:	8c650513          	addi	a0,a0,-1850 # 800081a0 <digits+0x160>
    800018e2:	fffff097          	auipc	ra,0xfffff
    800018e6:	c58080e7          	jalr	-936(ra) # 8000053a <panic>

00000000800018ea <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    800018ea:	7139                	addi	sp,sp,-64
    800018ec:	fc06                	sd	ra,56(sp)
    800018ee:	f822                	sd	s0,48(sp)
    800018f0:	f426                	sd	s1,40(sp)
    800018f2:	f04a                	sd	s2,32(sp)
    800018f4:	ec4e                	sd	s3,24(sp)
    800018f6:	e852                	sd	s4,16(sp)
    800018f8:	e456                	sd	s5,8(sp)
    800018fa:	e05a                	sd	s6,0(sp)
    800018fc:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018fe:	00007597          	auipc	a1,0x7
    80001902:	8aa58593          	addi	a1,a1,-1878 # 800081a8 <digits+0x168>
    80001906:	00010517          	auipc	a0,0x10
    8000190a:	99a50513          	addi	a0,a0,-1638 # 800112a0 <pid_lock>
    8000190e:	fffff097          	auipc	ra,0xfffff
    80001912:	27c080e7          	jalr	636(ra) # 80000b8a <initlock>
  initlock(&wait_lock, "wait_lock");
    80001916:	00007597          	auipc	a1,0x7
    8000191a:	89a58593          	addi	a1,a1,-1894 # 800081b0 <digits+0x170>
    8000191e:	00010517          	auipc	a0,0x10
    80001922:	99a50513          	addi	a0,a0,-1638 # 800112b8 <wait_lock>
    80001926:	fffff097          	auipc	ra,0xfffff
    8000192a:	264080e7          	jalr	612(ra) # 80000b8a <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000192e:	00010497          	auipc	s1,0x10
    80001932:	da248493          	addi	s1,s1,-606 # 800116d0 <proc>
      initlock(&p->lock, "proc");
    80001936:	00007b17          	auipc	s6,0x7
    8000193a:	88ab0b13          	addi	s6,s6,-1910 # 800081c0 <digits+0x180>
      p->kstack = KSTACK((int) (p - proc));
    8000193e:	8aa6                	mv	s5,s1
    80001940:	00006a17          	auipc	s4,0x6
    80001944:	6c0a0a13          	addi	s4,s4,1728 # 80008000 <etext>
    80001948:	04000937          	lui	s2,0x4000
    8000194c:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    8000194e:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001950:	00016997          	auipc	s3,0x16
    80001954:	b8098993          	addi	s3,s3,-1152 # 800174d0 <tickslock>
      initlock(&p->lock, "proc");
    80001958:	85da                	mv	a1,s6
    8000195a:	8526                	mv	a0,s1
    8000195c:	fffff097          	auipc	ra,0xfffff
    80001960:	22e080e7          	jalr	558(ra) # 80000b8a <initlock>
      p->kstack = KSTACK((int) (p - proc));
    80001964:	415487b3          	sub	a5,s1,s5
    80001968:	878d                	srai	a5,a5,0x3
    8000196a:	000a3703          	ld	a4,0(s4)
    8000196e:	02e787b3          	mul	a5,a5,a4
    80001972:	2785                	addiw	a5,a5,1
    80001974:	00d7979b          	slliw	a5,a5,0xd
    80001978:	40f907b3          	sub	a5,s2,a5
    8000197c:	e8bc                	sd	a5,80(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000197e:	17848493          	addi	s1,s1,376
    80001982:	fd349be3          	bne	s1,s3,80001958 <procinit+0x6e>
  }
}
    80001986:	70e2                	ld	ra,56(sp)
    80001988:	7442                	ld	s0,48(sp)
    8000198a:	74a2                	ld	s1,40(sp)
    8000198c:	7902                	ld	s2,32(sp)
    8000198e:	69e2                	ld	s3,24(sp)
    80001990:	6a42                	ld	s4,16(sp)
    80001992:	6aa2                	ld	s5,8(sp)
    80001994:	6b02                	ld	s6,0(sp)
    80001996:	6121                	addi	sp,sp,64
    80001998:	8082                	ret

000000008000199a <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    8000199a:	1141                	addi	sp,sp,-16
    8000199c:	e422                	sd	s0,8(sp)
    8000199e:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019a0:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800019a2:	2501                	sext.w	a0,a0
    800019a4:	6422                	ld	s0,8(sp)
    800019a6:	0141                	addi	sp,sp,16
    800019a8:	8082                	ret

00000000800019aa <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    800019aa:	1141                	addi	sp,sp,-16
    800019ac:	e422                	sd	s0,8(sp)
    800019ae:	0800                	addi	s0,sp,16
    800019b0:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019b2:	2781                	sext.w	a5,a5
    800019b4:	079e                	slli	a5,a5,0x7
  return c;
}
    800019b6:	00010517          	auipc	a0,0x10
    800019ba:	91a50513          	addi	a0,a0,-1766 # 800112d0 <cpus>
    800019be:	953e                	add	a0,a0,a5
    800019c0:	6422                	ld	s0,8(sp)
    800019c2:	0141                	addi	sp,sp,16
    800019c4:	8082                	ret

00000000800019c6 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    800019c6:	1101                	addi	sp,sp,-32
    800019c8:	ec06                	sd	ra,24(sp)
    800019ca:	e822                	sd	s0,16(sp)
    800019cc:	e426                	sd	s1,8(sp)
    800019ce:	1000                	addi	s0,sp,32
  push_off();
    800019d0:	fffff097          	auipc	ra,0xfffff
    800019d4:	1fe080e7          	jalr	510(ra) # 80000bce <push_off>
    800019d8:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019da:	2781                	sext.w	a5,a5
    800019dc:	079e                	slli	a5,a5,0x7
    800019de:	00010717          	auipc	a4,0x10
    800019e2:	8c270713          	addi	a4,a4,-1854 # 800112a0 <pid_lock>
    800019e6:	97ba                	add	a5,a5,a4
    800019e8:	7b84                	ld	s1,48(a5)
  pop_off();
    800019ea:	fffff097          	auipc	ra,0xfffff
    800019ee:	284080e7          	jalr	644(ra) # 80000c6e <pop_off>
  return p;
}
    800019f2:	8526                	mv	a0,s1
    800019f4:	60e2                	ld	ra,24(sp)
    800019f6:	6442                	ld	s0,16(sp)
    800019f8:	64a2                	ld	s1,8(sp)
    800019fa:	6105                	addi	sp,sp,32
    800019fc:	8082                	ret

00000000800019fe <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019fe:	1141                	addi	sp,sp,-16
    80001a00:	e406                	sd	ra,8(sp)
    80001a02:	e022                	sd	s0,0(sp)
    80001a04:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a06:	00000097          	auipc	ra,0x0
    80001a0a:	fc0080e7          	jalr	-64(ra) # 800019c6 <myproc>
    80001a0e:	fffff097          	auipc	ra,0xfffff
    80001a12:	2c0080e7          	jalr	704(ra) # 80000cce <release>

  if (first) {
    80001a16:	00007797          	auipc	a5,0x7
    80001a1a:	e5a7a783          	lw	a5,-422(a5) # 80008870 <first.1>
    80001a1e:	eb89                	bnez	a5,80001a30 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a20:	00001097          	auipc	ra,0x1
    80001a24:	ea2080e7          	jalr	-350(ra) # 800028c2 <usertrapret>
}
    80001a28:	60a2                	ld	ra,8(sp)
    80001a2a:	6402                	ld	s0,0(sp)
    80001a2c:	0141                	addi	sp,sp,16
    80001a2e:	8082                	ret
    first = 0;
    80001a30:	00007797          	auipc	a5,0x7
    80001a34:	e407a023          	sw	zero,-448(a5) # 80008870 <first.1>
    fsinit(ROOTDEV);
    80001a38:	4505                	li	a0,1
    80001a3a:	00002097          	auipc	ra,0x2
    80001a3e:	d64080e7          	jalr	-668(ra) # 8000379e <fsinit>
    80001a42:	bff9                	j	80001a20 <forkret+0x22>

0000000080001a44 <allocpid>:
allocpid() {
    80001a44:	1101                	addi	sp,sp,-32
    80001a46:	ec06                	sd	ra,24(sp)
    80001a48:	e822                	sd	s0,16(sp)
    80001a4a:	e426                	sd	s1,8(sp)
    80001a4c:	e04a                	sd	s2,0(sp)
    80001a4e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a50:	00010917          	auipc	s2,0x10
    80001a54:	85090913          	addi	s2,s2,-1968 # 800112a0 <pid_lock>
    80001a58:	854a                	mv	a0,s2
    80001a5a:	fffff097          	auipc	ra,0xfffff
    80001a5e:	1c0080e7          	jalr	448(ra) # 80000c1a <acquire>
  pid = nextpid;
    80001a62:	00007797          	auipc	a5,0x7
    80001a66:	e1278793          	addi	a5,a5,-494 # 80008874 <nextpid>
    80001a6a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a6c:	0014871b          	addiw	a4,s1,1
    80001a70:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a72:	854a                	mv	a0,s2
    80001a74:	fffff097          	auipc	ra,0xfffff
    80001a78:	25a080e7          	jalr	602(ra) # 80000cce <release>
}
    80001a7c:	8526                	mv	a0,s1
    80001a7e:	60e2                	ld	ra,24(sp)
    80001a80:	6442                	ld	s0,16(sp)
    80001a82:	64a2                	ld	s1,8(sp)
    80001a84:	6902                	ld	s2,0(sp)
    80001a86:	6105                	addi	sp,sp,32
    80001a88:	8082                	ret

0000000080001a8a <proc_pagetable>:
{
    80001a8a:	1101                	addi	sp,sp,-32
    80001a8c:	ec06                	sd	ra,24(sp)
    80001a8e:	e822                	sd	s0,16(sp)
    80001a90:	e426                	sd	s1,8(sp)
    80001a92:	e04a                	sd	s2,0(sp)
    80001a94:	1000                	addi	s0,sp,32
    80001a96:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a98:	00000097          	auipc	ra,0x0
    80001a9c:	8c2080e7          	jalr	-1854(ra) # 8000135a <uvmcreate>
    80001aa0:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001aa2:	c121                	beqz	a0,80001ae2 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001aa4:	4729                	li	a4,10
    80001aa6:	00005697          	auipc	a3,0x5
    80001aaa:	55a68693          	addi	a3,a3,1370 # 80007000 <_trampoline>
    80001aae:	6605                	lui	a2,0x1
    80001ab0:	040005b7          	lui	a1,0x4000
    80001ab4:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ab6:	05b2                	slli	a1,a1,0xc
    80001ab8:	fffff097          	auipc	ra,0xfffff
    80001abc:	626080e7          	jalr	1574(ra) # 800010de <mappages>
    80001ac0:	02054863          	bltz	a0,80001af0 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ac4:	4719                	li	a4,6
    80001ac6:	06893683          	ld	a3,104(s2)
    80001aca:	6605                	lui	a2,0x1
    80001acc:	020005b7          	lui	a1,0x2000
    80001ad0:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ad2:	05b6                	slli	a1,a1,0xd
    80001ad4:	8526                	mv	a0,s1
    80001ad6:	fffff097          	auipc	ra,0xfffff
    80001ada:	608080e7          	jalr	1544(ra) # 800010de <mappages>
    80001ade:	02054163          	bltz	a0,80001b00 <proc_pagetable+0x76>
}
    80001ae2:	8526                	mv	a0,s1
    80001ae4:	60e2                	ld	ra,24(sp)
    80001ae6:	6442                	ld	s0,16(sp)
    80001ae8:	64a2                	ld	s1,8(sp)
    80001aea:	6902                	ld	s2,0(sp)
    80001aec:	6105                	addi	sp,sp,32
    80001aee:	8082                	ret
    uvmfree(pagetable, 0);
    80001af0:	4581                	li	a1,0
    80001af2:	8526                	mv	a0,s1
    80001af4:	00000097          	auipc	ra,0x0
    80001af8:	a64080e7          	jalr	-1436(ra) # 80001558 <uvmfree>
    return 0;
    80001afc:	4481                	li	s1,0
    80001afe:	b7d5                	j	80001ae2 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b00:	4681                	li	a3,0
    80001b02:	4605                	li	a2,1
    80001b04:	040005b7          	lui	a1,0x4000
    80001b08:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b0a:	05b2                	slli	a1,a1,0xc
    80001b0c:	8526                	mv	a0,s1
    80001b0e:	fffff097          	auipc	ra,0xfffff
    80001b12:	796080e7          	jalr	1942(ra) # 800012a4 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b16:	4581                	li	a1,0
    80001b18:	8526                	mv	a0,s1
    80001b1a:	00000097          	auipc	ra,0x0
    80001b1e:	a3e080e7          	jalr	-1474(ra) # 80001558 <uvmfree>
    return 0;
    80001b22:	4481                	li	s1,0
    80001b24:	bf7d                	j	80001ae2 <proc_pagetable+0x58>

0000000080001b26 <proc_freepagetable>:
{
    80001b26:	1101                	addi	sp,sp,-32
    80001b28:	ec06                	sd	ra,24(sp)
    80001b2a:	e822                	sd	s0,16(sp)
    80001b2c:	e426                	sd	s1,8(sp)
    80001b2e:	e04a                	sd	s2,0(sp)
    80001b30:	1000                	addi	s0,sp,32
    80001b32:	84aa                	mv	s1,a0
    80001b34:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b36:	4681                	li	a3,0
    80001b38:	4605                	li	a2,1
    80001b3a:	040005b7          	lui	a1,0x4000
    80001b3e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b40:	05b2                	slli	a1,a1,0xc
    80001b42:	fffff097          	auipc	ra,0xfffff
    80001b46:	762080e7          	jalr	1890(ra) # 800012a4 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b4a:	4681                	li	a3,0
    80001b4c:	4605                	li	a2,1
    80001b4e:	020005b7          	lui	a1,0x2000
    80001b52:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b54:	05b6                	slli	a1,a1,0xd
    80001b56:	8526                	mv	a0,s1
    80001b58:	fffff097          	auipc	ra,0xfffff
    80001b5c:	74c080e7          	jalr	1868(ra) # 800012a4 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b60:	85ca                	mv	a1,s2
    80001b62:	8526                	mv	a0,s1
    80001b64:	00000097          	auipc	ra,0x0
    80001b68:	9f4080e7          	jalr	-1548(ra) # 80001558 <uvmfree>
}
    80001b6c:	60e2                	ld	ra,24(sp)
    80001b6e:	6442                	ld	s0,16(sp)
    80001b70:	64a2                	ld	s1,8(sp)
    80001b72:	6902                	ld	s2,0(sp)
    80001b74:	6105                	addi	sp,sp,32
    80001b76:	8082                	ret

0000000080001b78 <freeproc>:
{
    80001b78:	1101                	addi	sp,sp,-32
    80001b7a:	ec06                	sd	ra,24(sp)
    80001b7c:	e822                	sd	s0,16(sp)
    80001b7e:	e426                	sd	s1,8(sp)
    80001b80:	1000                	addi	s0,sp,32
    80001b82:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b84:	7528                	ld	a0,104(a0)
    80001b86:	c509                	beqz	a0,80001b90 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b88:	fffff097          	auipc	ra,0xfffff
    80001b8c:	e5a080e7          	jalr	-422(ra) # 800009e2 <kfree>
  p->trapframe = 0;
    80001b90:	0604b423          	sd	zero,104(s1)
  if(p->pagetable)
    80001b94:	70a8                	ld	a0,96(s1)
    80001b96:	c511                	beqz	a0,80001ba2 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b98:	6cac                	ld	a1,88(s1)
    80001b9a:	00000097          	auipc	ra,0x0
    80001b9e:	f8c080e7          	jalr	-116(ra) # 80001b26 <proc_freepagetable>
  p->pagetable = 0;
    80001ba2:	0604b023          	sd	zero,96(s1)
  p->sz = 0;
    80001ba6:	0404bc23          	sd	zero,88(s1)
  p->pid = 0;
    80001baa:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001bae:	0404b423          	sd	zero,72(s1)
  p->name[0] = 0;
    80001bb2:	16048423          	sb	zero,360(s1)
  p->chan = 0;
    80001bb6:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001bba:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bbe:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bc2:	0004ae23          	sw	zero,28(s1)
}
    80001bc6:	60e2                	ld	ra,24(sp)
    80001bc8:	6442                	ld	s0,16(sp)
    80001bca:	64a2                	ld	s1,8(sp)
    80001bcc:	6105                	addi	sp,sp,32
    80001bce:	8082                	ret

0000000080001bd0 <allocproc>:
{
    80001bd0:	1101                	addi	sp,sp,-32
    80001bd2:	ec06                	sd	ra,24(sp)
    80001bd4:	e822                	sd	s0,16(sp)
    80001bd6:	e426                	sd	s1,8(sp)
    80001bd8:	e04a                	sd	s2,0(sp)
    80001bda:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bdc:	00010497          	auipc	s1,0x10
    80001be0:	af448493          	addi	s1,s1,-1292 # 800116d0 <proc>
    80001be4:	00016917          	auipc	s2,0x16
    80001be8:	8ec90913          	addi	s2,s2,-1812 # 800174d0 <tickslock>
    acquire(&p->lock);
    80001bec:	8526                	mv	a0,s1
    80001bee:	fffff097          	auipc	ra,0xfffff
    80001bf2:	02c080e7          	jalr	44(ra) # 80000c1a <acquire>
    if(p->state == UNUSED) {
    80001bf6:	4cdc                	lw	a5,28(s1)
    80001bf8:	cf81                	beqz	a5,80001c10 <allocproc+0x40>
      release(&p->lock);
    80001bfa:	8526                	mv	a0,s1
    80001bfc:	fffff097          	auipc	ra,0xfffff
    80001c00:	0d2080e7          	jalr	210(ra) # 80000cce <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c04:	17848493          	addi	s1,s1,376
    80001c08:	ff2492e3          	bne	s1,s2,80001bec <allocproc+0x1c>
  return 0;
    80001c0c:	4481                	li	s1,0
    80001c0e:	a899                	j	80001c64 <allocproc+0x94>
  p->pid = allocpid();
    80001c10:	00000097          	auipc	ra,0x0
    80001c14:	e34080e7          	jalr	-460(ra) # 80001a44 <allocpid>
    80001c18:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c1a:	4785                	li	a5,1
    80001c1c:	ccdc                	sw	a5,28(s1)
  p-> cputime = 0;
    80001c1e:	0204bc23          	sd	zero,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c22:	fffff097          	auipc	ra,0xfffff
    80001c26:	ebe080e7          	jalr	-322(ra) # 80000ae0 <kalloc>
    80001c2a:	892a                	mv	s2,a0
    80001c2c:	f4a8                	sd	a0,104(s1)
    80001c2e:	c131                	beqz	a0,80001c72 <allocproc+0xa2>
  p->pagetable = proc_pagetable(p);
    80001c30:	8526                	mv	a0,s1
    80001c32:	00000097          	auipc	ra,0x0
    80001c36:	e58080e7          	jalr	-424(ra) # 80001a8a <proc_pagetable>
    80001c3a:	892a                	mv	s2,a0
    80001c3c:	f0a8                	sd	a0,96(s1)
  if(p->pagetable == 0){
    80001c3e:	c531                	beqz	a0,80001c8a <allocproc+0xba>
  memset(&p->context, 0, sizeof(p->context));
    80001c40:	07000613          	li	a2,112
    80001c44:	4581                	li	a1,0
    80001c46:	07048513          	addi	a0,s1,112
    80001c4a:	fffff097          	auipc	ra,0xfffff
    80001c4e:	0cc080e7          	jalr	204(ra) # 80000d16 <memset>
  p->context.ra = (uint64)forkret;
    80001c52:	00000797          	auipc	a5,0x0
    80001c56:	dac78793          	addi	a5,a5,-596 # 800019fe <forkret>
    80001c5a:	f8bc                	sd	a5,112(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c5c:	68bc                	ld	a5,80(s1)
    80001c5e:	6705                	lui	a4,0x1
    80001c60:	97ba                	add	a5,a5,a4
    80001c62:	fcbc                	sd	a5,120(s1)
}
    80001c64:	8526                	mv	a0,s1
    80001c66:	60e2                	ld	ra,24(sp)
    80001c68:	6442                	ld	s0,16(sp)
    80001c6a:	64a2                	ld	s1,8(sp)
    80001c6c:	6902                	ld	s2,0(sp)
    80001c6e:	6105                	addi	sp,sp,32
    80001c70:	8082                	ret
    freeproc(p);
    80001c72:	8526                	mv	a0,s1
    80001c74:	00000097          	auipc	ra,0x0
    80001c78:	f04080e7          	jalr	-252(ra) # 80001b78 <freeproc>
    release(&p->lock);
    80001c7c:	8526                	mv	a0,s1
    80001c7e:	fffff097          	auipc	ra,0xfffff
    80001c82:	050080e7          	jalr	80(ra) # 80000cce <release>
    return 0;
    80001c86:	84ca                	mv	s1,s2
    80001c88:	bff1                	j	80001c64 <allocproc+0x94>
    freeproc(p);
    80001c8a:	8526                	mv	a0,s1
    80001c8c:	00000097          	auipc	ra,0x0
    80001c90:	eec080e7          	jalr	-276(ra) # 80001b78 <freeproc>
    release(&p->lock);
    80001c94:	8526                	mv	a0,s1
    80001c96:	fffff097          	auipc	ra,0xfffff
    80001c9a:	038080e7          	jalr	56(ra) # 80000cce <release>
    return 0;
    80001c9e:	84ca                	mv	s1,s2
    80001ca0:	b7d1                	j	80001c64 <allocproc+0x94>

0000000080001ca2 <userinit>:
{
    80001ca2:	1101                	addi	sp,sp,-32
    80001ca4:	ec06                	sd	ra,24(sp)
    80001ca6:	e822                	sd	s0,16(sp)
    80001ca8:	e426                	sd	s1,8(sp)
    80001caa:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cac:	00000097          	auipc	ra,0x0
    80001cb0:	f24080e7          	jalr	-220(ra) # 80001bd0 <allocproc>
    80001cb4:	84aa                	mv	s1,a0
  initproc = p;
    80001cb6:	00007797          	auipc	a5,0x7
    80001cba:	36a7b923          	sd	a0,882(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001cbe:	03400613          	li	a2,52
    80001cc2:	00007597          	auipc	a1,0x7
    80001cc6:	bbe58593          	addi	a1,a1,-1090 # 80008880 <initcode>
    80001cca:	7128                	ld	a0,96(a0)
    80001ccc:	fffff097          	auipc	ra,0xfffff
    80001cd0:	6bc080e7          	jalr	1724(ra) # 80001388 <uvminit>
  p->sz = PGSIZE;
    80001cd4:	6785                	lui	a5,0x1
    80001cd6:	ecbc                	sd	a5,88(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cd8:	74b8                	ld	a4,104(s1)
    80001cda:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cde:	74b8                	ld	a4,104(s1)
    80001ce0:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001ce2:	4641                	li	a2,16
    80001ce4:	00006597          	auipc	a1,0x6
    80001ce8:	4e458593          	addi	a1,a1,1252 # 800081c8 <digits+0x188>
    80001cec:	16848513          	addi	a0,s1,360
    80001cf0:	fffff097          	auipc	ra,0xfffff
    80001cf4:	170080e7          	jalr	368(ra) # 80000e60 <safestrcpy>
  p->cwd = namei("/");
    80001cf8:	00006517          	auipc	a0,0x6
    80001cfc:	4e050513          	addi	a0,a0,1248 # 800081d8 <digits+0x198>
    80001d00:	00002097          	auipc	ra,0x2
    80001d04:	4d4080e7          	jalr	1236(ra) # 800041d4 <namei>
    80001d08:	16a4b023          	sd	a0,352(s1)
  p->state = RUNNABLE;
    80001d0c:	478d                	li	a5,3
    80001d0e:	ccdc                	sw	a5,28(s1)
  release(&p->lock);
    80001d10:	8526                	mv	a0,s1
    80001d12:	fffff097          	auipc	ra,0xfffff
    80001d16:	fbc080e7          	jalr	-68(ra) # 80000cce <release>
}
    80001d1a:	60e2                	ld	ra,24(sp)
    80001d1c:	6442                	ld	s0,16(sp)
    80001d1e:	64a2                	ld	s1,8(sp)
    80001d20:	6105                	addi	sp,sp,32
    80001d22:	8082                	ret

0000000080001d24 <growproc>:
{
    80001d24:	1101                	addi	sp,sp,-32
    80001d26:	ec06                	sd	ra,24(sp)
    80001d28:	e822                	sd	s0,16(sp)
    80001d2a:	e426                	sd	s1,8(sp)
    80001d2c:	e04a                	sd	s2,0(sp)
    80001d2e:	1000                	addi	s0,sp,32
    80001d30:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d32:	00000097          	auipc	ra,0x0
    80001d36:	c94080e7          	jalr	-876(ra) # 800019c6 <myproc>
    80001d3a:	892a                	mv	s2,a0
  sz = p->sz;
    80001d3c:	6d2c                	ld	a1,88(a0)
    80001d3e:	0005879b          	sext.w	a5,a1
  if(n > 0){
    80001d42:	00904f63          	bgtz	s1,80001d60 <growproc+0x3c>
  } else if(n < 0){
    80001d46:	0204cd63          	bltz	s1,80001d80 <growproc+0x5c>
  p->sz = sz;
    80001d4a:	1782                	slli	a5,a5,0x20
    80001d4c:	9381                	srli	a5,a5,0x20
    80001d4e:	04f93c23          	sd	a5,88(s2)
  return 0;
    80001d52:	4501                	li	a0,0
}
    80001d54:	60e2                	ld	ra,24(sp)
    80001d56:	6442                	ld	s0,16(sp)
    80001d58:	64a2                	ld	s1,8(sp)
    80001d5a:	6902                	ld	s2,0(sp)
    80001d5c:	6105                	addi	sp,sp,32
    80001d5e:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001d60:	00f4863b          	addw	a2,s1,a5
    80001d64:	1602                	slli	a2,a2,0x20
    80001d66:	9201                	srli	a2,a2,0x20
    80001d68:	1582                	slli	a1,a1,0x20
    80001d6a:	9181                	srli	a1,a1,0x20
    80001d6c:	7128                	ld	a0,96(a0)
    80001d6e:	fffff097          	auipc	ra,0xfffff
    80001d72:	6d4080e7          	jalr	1748(ra) # 80001442 <uvmalloc>
    80001d76:	0005079b          	sext.w	a5,a0
    80001d7a:	fbe1                	bnez	a5,80001d4a <growproc+0x26>
      return -1;
    80001d7c:	557d                	li	a0,-1
    80001d7e:	bfd9                	j	80001d54 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d80:	00f4863b          	addw	a2,s1,a5
    80001d84:	1602                	slli	a2,a2,0x20
    80001d86:	9201                	srli	a2,a2,0x20
    80001d88:	1582                	slli	a1,a1,0x20
    80001d8a:	9181                	srli	a1,a1,0x20
    80001d8c:	7128                	ld	a0,96(a0)
    80001d8e:	fffff097          	auipc	ra,0xfffff
    80001d92:	66c080e7          	jalr	1644(ra) # 800013fa <uvmdealloc>
    80001d96:	0005079b          	sext.w	a5,a0
    80001d9a:	bf45                	j	80001d4a <growproc+0x26>

0000000080001d9c <fork>:
{
    80001d9c:	7139                	addi	sp,sp,-64
    80001d9e:	fc06                	sd	ra,56(sp)
    80001da0:	f822                	sd	s0,48(sp)
    80001da2:	f426                	sd	s1,40(sp)
    80001da4:	f04a                	sd	s2,32(sp)
    80001da6:	ec4e                	sd	s3,24(sp)
    80001da8:	e852                	sd	s4,16(sp)
    80001daa:	e456                	sd	s5,8(sp)
    80001dac:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001dae:	00000097          	auipc	ra,0x0
    80001db2:	c18080e7          	jalr	-1000(ra) # 800019c6 <myproc>
    80001db6:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001db8:	00000097          	auipc	ra,0x0
    80001dbc:	e18080e7          	jalr	-488(ra) # 80001bd0 <allocproc>
    80001dc0:	10050c63          	beqz	a0,80001ed8 <fork+0x13c>
    80001dc4:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001dc6:	058ab603          	ld	a2,88(s5)
    80001dca:	712c                	ld	a1,96(a0)
    80001dcc:	060ab503          	ld	a0,96(s5)
    80001dd0:	fffff097          	auipc	ra,0xfffff
    80001dd4:	7c2080e7          	jalr	1986(ra) # 80001592 <uvmcopy>
    80001dd8:	04054863          	bltz	a0,80001e28 <fork+0x8c>
  np->sz = p->sz;
    80001ddc:	058ab783          	ld	a5,88(s5)
    80001de0:	04fa3c23          	sd	a5,88(s4)
  *(np->trapframe) = *(p->trapframe);
    80001de4:	068ab683          	ld	a3,104(s5)
    80001de8:	87b6                	mv	a5,a3
    80001dea:	068a3703          	ld	a4,104(s4)
    80001dee:	12068693          	addi	a3,a3,288
    80001df2:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001df6:	6788                	ld	a0,8(a5)
    80001df8:	6b8c                	ld	a1,16(a5)
    80001dfa:	6f90                	ld	a2,24(a5)
    80001dfc:	01073023          	sd	a6,0(a4)
    80001e00:	e708                	sd	a0,8(a4)
    80001e02:	eb0c                	sd	a1,16(a4)
    80001e04:	ef10                	sd	a2,24(a4)
    80001e06:	02078793          	addi	a5,a5,32
    80001e0a:	02070713          	addi	a4,a4,32
    80001e0e:	fed792e3          	bne	a5,a3,80001df2 <fork+0x56>
  np->trapframe->a0 = 0;
    80001e12:	068a3783          	ld	a5,104(s4)
    80001e16:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e1a:	0e0a8493          	addi	s1,s5,224
    80001e1e:	0e0a0913          	addi	s2,s4,224
    80001e22:	160a8993          	addi	s3,s5,352
    80001e26:	a00d                	j	80001e48 <fork+0xac>
    freeproc(np);
    80001e28:	8552                	mv	a0,s4
    80001e2a:	00000097          	auipc	ra,0x0
    80001e2e:	d4e080e7          	jalr	-690(ra) # 80001b78 <freeproc>
    release(&np->lock);
    80001e32:	8552                	mv	a0,s4
    80001e34:	fffff097          	auipc	ra,0xfffff
    80001e38:	e9a080e7          	jalr	-358(ra) # 80000cce <release>
    return -1;
    80001e3c:	597d                	li	s2,-1
    80001e3e:	a059                	j	80001ec4 <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001e40:	04a1                	addi	s1,s1,8
    80001e42:	0921                	addi	s2,s2,8
    80001e44:	01348b63          	beq	s1,s3,80001e5a <fork+0xbe>
    if(p->ofile[i])
    80001e48:	6088                	ld	a0,0(s1)
    80001e4a:	d97d                	beqz	a0,80001e40 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e4c:	00003097          	auipc	ra,0x3
    80001e50:	a1e080e7          	jalr	-1506(ra) # 8000486a <filedup>
    80001e54:	00a93023          	sd	a0,0(s2)
    80001e58:	b7e5                	j	80001e40 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e5a:	160ab503          	ld	a0,352(s5)
    80001e5e:	00002097          	auipc	ra,0x2
    80001e62:	b7c080e7          	jalr	-1156(ra) # 800039da <idup>
    80001e66:	16aa3023          	sd	a0,352(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e6a:	4641                	li	a2,16
    80001e6c:	168a8593          	addi	a1,s5,360
    80001e70:	168a0513          	addi	a0,s4,360
    80001e74:	fffff097          	auipc	ra,0xfffff
    80001e78:	fec080e7          	jalr	-20(ra) # 80000e60 <safestrcpy>
  pid = np->pid;
    80001e7c:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001e80:	8552                	mv	a0,s4
    80001e82:	fffff097          	auipc	ra,0xfffff
    80001e86:	e4c080e7          	jalr	-436(ra) # 80000cce <release>
  acquire(&wait_lock);
    80001e8a:	0000f497          	auipc	s1,0xf
    80001e8e:	42e48493          	addi	s1,s1,1070 # 800112b8 <wait_lock>
    80001e92:	8526                	mv	a0,s1
    80001e94:	fffff097          	auipc	ra,0xfffff
    80001e98:	d86080e7          	jalr	-634(ra) # 80000c1a <acquire>
  np->parent = p;
    80001e9c:	055a3423          	sd	s5,72(s4)
  release(&wait_lock);
    80001ea0:	8526                	mv	a0,s1
    80001ea2:	fffff097          	auipc	ra,0xfffff
    80001ea6:	e2c080e7          	jalr	-468(ra) # 80000cce <release>
  acquire(&np->lock);
    80001eaa:	8552                	mv	a0,s4
    80001eac:	fffff097          	auipc	ra,0xfffff
    80001eb0:	d6e080e7          	jalr	-658(ra) # 80000c1a <acquire>
  np->state = RUNNABLE;
    80001eb4:	478d                	li	a5,3
    80001eb6:	00fa2e23          	sw	a5,28(s4)
  release(&np->lock);
    80001eba:	8552                	mv	a0,s4
    80001ebc:	fffff097          	auipc	ra,0xfffff
    80001ec0:	e12080e7          	jalr	-494(ra) # 80000cce <release>
}
    80001ec4:	854a                	mv	a0,s2
    80001ec6:	70e2                	ld	ra,56(sp)
    80001ec8:	7442                	ld	s0,48(sp)
    80001eca:	74a2                	ld	s1,40(sp)
    80001ecc:	7902                	ld	s2,32(sp)
    80001ece:	69e2                	ld	s3,24(sp)
    80001ed0:	6a42                	ld	s4,16(sp)
    80001ed2:	6aa2                	ld	s5,8(sp)
    80001ed4:	6121                	addi	sp,sp,64
    80001ed6:	8082                	ret
    return -1;
    80001ed8:	597d                	li	s2,-1
    80001eda:	b7ed                	j	80001ec4 <fork+0x128>

0000000080001edc <scheduler>:
{
    80001edc:	711d                	addi	sp,sp,-96
    80001ede:	ec86                	sd	ra,88(sp)
    80001ee0:	e8a2                	sd	s0,80(sp)
    80001ee2:	e4a6                	sd	s1,72(sp)
    80001ee4:	e0ca                	sd	s2,64(sp)
    80001ee6:	fc4e                	sd	s3,56(sp)
    80001ee8:	f852                	sd	s4,48(sp)
    80001eea:	f456                	sd	s5,40(sp)
    80001eec:	f05a                	sd	s6,32(sp)
    80001eee:	ec5e                	sd	s7,24(sp)
    80001ef0:	e862                	sd	s8,16(sp)
    80001ef2:	e466                	sd	s9,8(sp)
    80001ef4:	1080                	addi	s0,sp,96
    80001ef6:	8792                	mv	a5,tp
  int id = r_tp();
    80001ef8:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001efa:	00779c13          	slli	s8,a5,0x7
    80001efe:	0000f717          	auipc	a4,0xf
    80001f02:	3a270713          	addi	a4,a4,930 # 800112a0 <pid_lock>
    80001f06:	9762                	add	a4,a4,s8
    80001f08:	02073823          	sd	zero,48(a4)
        	swtch(&c->context, &maxproc->context);
    80001f0c:	0000f717          	auipc	a4,0xf
    80001f10:	3cc70713          	addi	a4,a4,972 # 800112d8 <cpus+0x8>
    80001f14:	9c3a                	add	s8,s8,a4
  	int maximum_process = 0;
    80001f16:	4b81                	li	s7,0
  		if(p-> state == RUNNABLE){
    80001f18:	490d                	li	s2,3
  	for(p = proc; p < &proc[NPROC]; p++) {
    80001f1a:	00015997          	auipc	s3,0x15
    80001f1e:	5b698993          	addi	s3,s3,1462 # 800174d0 <tickslock>
        	maxproc->state = RUNNING;
    80001f22:	4c91                	li	s9,4
        	c->proc = maxproc;
    80001f24:	079e                	slli	a5,a5,0x7
    80001f26:	0000fb17          	auipc	s6,0xf
    80001f2a:	37ab0b13          	addi	s6,s6,890 # 800112a0 <pid_lock>
    80001f2e:	9b3e                	add	s6,s6,a5
    80001f30:	a049                	j	80001fb2 <scheduler+0xd6>
  		release(&p->lock);
    80001f32:	8526                	mv	a0,s1
    80001f34:	fffff097          	auipc	ra,0xfffff
    80001f38:	d9a080e7          	jalr	-614(ra) # 80000cce <release>
  	for(p = proc; p < &proc[NPROC]; p++) {
    80001f3c:	17848493          	addi	s1,s1,376
    80001f40:	03348763          	beq	s1,s3,80001f6e <scheduler+0x92>
  		acquire(&p->lock);
    80001f44:	8526                	mv	a0,s1
    80001f46:	fffff097          	auipc	ra,0xfffff
    80001f4a:	cd4080e7          	jalr	-812(ra) # 80000c1a <acquire>
  		if(p-> state == RUNNABLE){
    80001f4e:	4cdc                	lw	a5,28(s1)
    80001f50:	ff2791e3          	bne	a5,s2,80001f32 <scheduler+0x56>
  			int age = sys_uptime() - p->readytime;
    80001f54:	00001097          	auipc	ra,0x1
    80001f58:	0f0080e7          	jalr	240(ra) # 80003044 <sys_uptime>
    80001f5c:	60bc                	ld	a5,64(s1)
    80001f5e:	9d1d                	subw	a0,a0,a5
  			int max_priority = p->priority + age;
    80001f60:	4c9c                	lw	a5,24(s1)
    80001f62:	9d3d                	addw	a0,a0,a5
  			if(p->priority + (age) > maximum_process){
    80001f64:	fcaa57e3          	bge	s4,a0,80001f32 <scheduler+0x56>
  				maximum_process = max_priority;
    80001f68:	8a2a                	mv	s4,a0
  			if(p->priority + (age) > maximum_process){
    80001f6a:	8aa6                	mv	s5,s1
    80001f6c:	b7d9                	j	80001f32 <scheduler+0x56>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f6e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f72:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f76:	10079073          	csrw	sstatus,a5
      	acquire(&maxproc->lock);
    80001f7a:	84d6                	mv	s1,s5
    80001f7c:	8556                	mv	a0,s5
    80001f7e:	fffff097          	auipc	ra,0xfffff
    80001f82:	c9c080e7          	jalr	-868(ra) # 80000c1a <acquire>
      	if(maxproc->state == RUNNABLE) {
    80001f86:	01caa783          	lw	a5,28(s5)
    80001f8a:	01279f63          	bne	a5,s2,80001fa8 <scheduler+0xcc>
        	maxproc->state = RUNNING;
    80001f8e:	019aae23          	sw	s9,28(s5)
        	c->proc = maxproc;
    80001f92:	035b3823          	sd	s5,48(s6)
        	swtch(&c->context, &maxproc->context);
    80001f96:	070a8593          	addi	a1,s5,112
    80001f9a:	8562                	mv	a0,s8
    80001f9c:	00001097          	auipc	ra,0x1
    80001fa0:	87c080e7          	jalr	-1924(ra) # 80002818 <swtch>
        	c->proc = 0;
    80001fa4:	020b3823          	sd	zero,48(s6)
      		release(&maxproc->lock);
    80001fa8:	8526                	mv	a0,s1
    80001faa:	fffff097          	auipc	ra,0xfffff
    80001fae:	d24080e7          	jalr	-732(ra) # 80000cce <release>
  	for(p = proc; p < &proc[NPROC]; p++) {
    80001fb2:	0000f497          	auipc	s1,0xf
    80001fb6:	71e48493          	addi	s1,s1,1822 # 800116d0 <proc>
  	maxproc = proc;
    80001fba:	8aa6                	mv	s5,s1
  	int maximum_process = 0;
    80001fbc:	8a5e                	mv	s4,s7
    80001fbe:	b759                	j	80001f44 <scheduler+0x68>

0000000080001fc0 <sched>:
{
    80001fc0:	7179                	addi	sp,sp,-48
    80001fc2:	f406                	sd	ra,40(sp)
    80001fc4:	f022                	sd	s0,32(sp)
    80001fc6:	ec26                	sd	s1,24(sp)
    80001fc8:	e84a                	sd	s2,16(sp)
    80001fca:	e44e                	sd	s3,8(sp)
    80001fcc:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001fce:	00000097          	auipc	ra,0x0
    80001fd2:	9f8080e7          	jalr	-1544(ra) # 800019c6 <myproc>
    80001fd6:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001fd8:	fffff097          	auipc	ra,0xfffff
    80001fdc:	bc8080e7          	jalr	-1080(ra) # 80000ba0 <holding>
    80001fe0:	c93d                	beqz	a0,80002056 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fe2:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001fe4:	2781                	sext.w	a5,a5
    80001fe6:	079e                	slli	a5,a5,0x7
    80001fe8:	0000f717          	auipc	a4,0xf
    80001fec:	2b870713          	addi	a4,a4,696 # 800112a0 <pid_lock>
    80001ff0:	97ba                	add	a5,a5,a4
    80001ff2:	0a87a703          	lw	a4,168(a5)
    80001ff6:	4785                	li	a5,1
    80001ff8:	06f71763          	bne	a4,a5,80002066 <sched+0xa6>
  if(p->state == RUNNING)
    80001ffc:	4cd8                	lw	a4,28(s1)
    80001ffe:	4791                	li	a5,4
    80002000:	06f70b63          	beq	a4,a5,80002076 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002004:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002008:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000200a:	efb5                	bnez	a5,80002086 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000200c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000200e:	0000f917          	auipc	s2,0xf
    80002012:	29290913          	addi	s2,s2,658 # 800112a0 <pid_lock>
    80002016:	2781                	sext.w	a5,a5
    80002018:	079e                	slli	a5,a5,0x7
    8000201a:	97ca                	add	a5,a5,s2
    8000201c:	0ac7a983          	lw	s3,172(a5)
    80002020:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002022:	2781                	sext.w	a5,a5
    80002024:	079e                	slli	a5,a5,0x7
    80002026:	0000f597          	auipc	a1,0xf
    8000202a:	2b258593          	addi	a1,a1,690 # 800112d8 <cpus+0x8>
    8000202e:	95be                	add	a1,a1,a5
    80002030:	07048513          	addi	a0,s1,112
    80002034:	00000097          	auipc	ra,0x0
    80002038:	7e4080e7          	jalr	2020(ra) # 80002818 <swtch>
    8000203c:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000203e:	2781                	sext.w	a5,a5
    80002040:	079e                	slli	a5,a5,0x7
    80002042:	993e                	add	s2,s2,a5
    80002044:	0b392623          	sw	s3,172(s2)
}
    80002048:	70a2                	ld	ra,40(sp)
    8000204a:	7402                	ld	s0,32(sp)
    8000204c:	64e2                	ld	s1,24(sp)
    8000204e:	6942                	ld	s2,16(sp)
    80002050:	69a2                	ld	s3,8(sp)
    80002052:	6145                	addi	sp,sp,48
    80002054:	8082                	ret
    panic("sched p->lock");
    80002056:	00006517          	auipc	a0,0x6
    8000205a:	18a50513          	addi	a0,a0,394 # 800081e0 <digits+0x1a0>
    8000205e:	ffffe097          	auipc	ra,0xffffe
    80002062:	4dc080e7          	jalr	1244(ra) # 8000053a <panic>
    panic("sched locks");
    80002066:	00006517          	auipc	a0,0x6
    8000206a:	18a50513          	addi	a0,a0,394 # 800081f0 <digits+0x1b0>
    8000206e:	ffffe097          	auipc	ra,0xffffe
    80002072:	4cc080e7          	jalr	1228(ra) # 8000053a <panic>
    panic("sched running");
    80002076:	00006517          	auipc	a0,0x6
    8000207a:	18a50513          	addi	a0,a0,394 # 80008200 <digits+0x1c0>
    8000207e:	ffffe097          	auipc	ra,0xffffe
    80002082:	4bc080e7          	jalr	1212(ra) # 8000053a <panic>
    panic("sched interruptible");
    80002086:	00006517          	auipc	a0,0x6
    8000208a:	18a50513          	addi	a0,a0,394 # 80008210 <digits+0x1d0>
    8000208e:	ffffe097          	auipc	ra,0xffffe
    80002092:	4ac080e7          	jalr	1196(ra) # 8000053a <panic>

0000000080002096 <yield>:
{
    80002096:	1101                	addi	sp,sp,-32
    80002098:	ec06                	sd	ra,24(sp)
    8000209a:	e822                	sd	s0,16(sp)
    8000209c:	e426                	sd	s1,8(sp)
    8000209e:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020a0:	00000097          	auipc	ra,0x0
    800020a4:	926080e7          	jalr	-1754(ra) # 800019c6 <myproc>
    800020a8:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020aa:	fffff097          	auipc	ra,0xfffff
    800020ae:	b70080e7          	jalr	-1168(ra) # 80000c1a <acquire>
  p->state = RUNNABLE;
    800020b2:	478d                	li	a5,3
    800020b4:	ccdc                	sw	a5,28(s1)
  sched();
    800020b6:	00000097          	auipc	ra,0x0
    800020ba:	f0a080e7          	jalr	-246(ra) # 80001fc0 <sched>
  release(&p->lock);
    800020be:	8526                	mv	a0,s1
    800020c0:	fffff097          	auipc	ra,0xfffff
    800020c4:	c0e080e7          	jalr	-1010(ra) # 80000cce <release>
}
    800020c8:	60e2                	ld	ra,24(sp)
    800020ca:	6442                	ld	s0,16(sp)
    800020cc:	64a2                	ld	s1,8(sp)
    800020ce:	6105                	addi	sp,sp,32
    800020d0:	8082                	ret

00000000800020d2 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800020d2:	7179                	addi	sp,sp,-48
    800020d4:	f406                	sd	ra,40(sp)
    800020d6:	f022                	sd	s0,32(sp)
    800020d8:	ec26                	sd	s1,24(sp)
    800020da:	e84a                	sd	s2,16(sp)
    800020dc:	e44e                	sd	s3,8(sp)
    800020de:	1800                	addi	s0,sp,48
    800020e0:	89aa                	mv	s3,a0
    800020e2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800020e4:	00000097          	auipc	ra,0x0
    800020e8:	8e2080e7          	jalr	-1822(ra) # 800019c6 <myproc>
    800020ec:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800020ee:	fffff097          	auipc	ra,0xfffff
    800020f2:	b2c080e7          	jalr	-1236(ra) # 80000c1a <acquire>
  release(lk);
    800020f6:	854a                	mv	a0,s2
    800020f8:	fffff097          	auipc	ra,0xfffff
    800020fc:	bd6080e7          	jalr	-1066(ra) # 80000cce <release>

  // Go to sleep.
  p->chan = chan;
    80002100:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002104:	4789                	li	a5,2
    80002106:	ccdc                	sw	a5,28(s1)

  sched();
    80002108:	00000097          	auipc	ra,0x0
    8000210c:	eb8080e7          	jalr	-328(ra) # 80001fc0 <sched>

  // Tidy up.
  p->chan = 0;
    80002110:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002114:	8526                	mv	a0,s1
    80002116:	fffff097          	auipc	ra,0xfffff
    8000211a:	bb8080e7          	jalr	-1096(ra) # 80000cce <release>
  acquire(lk);
    8000211e:	854a                	mv	a0,s2
    80002120:	fffff097          	auipc	ra,0xfffff
    80002124:	afa080e7          	jalr	-1286(ra) # 80000c1a <acquire>
}
    80002128:	70a2                	ld	ra,40(sp)
    8000212a:	7402                	ld	s0,32(sp)
    8000212c:	64e2                	ld	s1,24(sp)
    8000212e:	6942                	ld	s2,16(sp)
    80002130:	69a2                	ld	s3,8(sp)
    80002132:	6145                	addi	sp,sp,48
    80002134:	8082                	ret

0000000080002136 <wait>:
{
    80002136:	715d                	addi	sp,sp,-80
    80002138:	e486                	sd	ra,72(sp)
    8000213a:	e0a2                	sd	s0,64(sp)
    8000213c:	fc26                	sd	s1,56(sp)
    8000213e:	f84a                	sd	s2,48(sp)
    80002140:	f44e                	sd	s3,40(sp)
    80002142:	f052                	sd	s4,32(sp)
    80002144:	ec56                	sd	s5,24(sp)
    80002146:	e85a                	sd	s6,16(sp)
    80002148:	e45e                	sd	s7,8(sp)
    8000214a:	e062                	sd	s8,0(sp)
    8000214c:	0880                	addi	s0,sp,80
    8000214e:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002150:	00000097          	auipc	ra,0x0
    80002154:	876080e7          	jalr	-1930(ra) # 800019c6 <myproc>
    80002158:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000215a:	0000f517          	auipc	a0,0xf
    8000215e:	15e50513          	addi	a0,a0,350 # 800112b8 <wait_lock>
    80002162:	fffff097          	auipc	ra,0xfffff
    80002166:	ab8080e7          	jalr	-1352(ra) # 80000c1a <acquire>
    havekids = 0;
    8000216a:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    8000216c:	4a15                	li	s4,5
        havekids = 1;
    8000216e:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002170:	00015997          	auipc	s3,0x15
    80002174:	36098993          	addi	s3,s3,864 # 800174d0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002178:	0000fc17          	auipc	s8,0xf
    8000217c:	140c0c13          	addi	s8,s8,320 # 800112b8 <wait_lock>
    havekids = 0;
    80002180:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002182:	0000f497          	auipc	s1,0xf
    80002186:	54e48493          	addi	s1,s1,1358 # 800116d0 <proc>
    8000218a:	a0bd                	j	800021f8 <wait+0xc2>
          pid = np->pid;
    8000218c:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002190:	000b0e63          	beqz	s6,800021ac <wait+0x76>
    80002194:	4691                	li	a3,4
    80002196:	02c48613          	addi	a2,s1,44
    8000219a:	85da                	mv	a1,s6
    8000219c:	06093503          	ld	a0,96(s2)
    800021a0:	fffff097          	auipc	ra,0xfffff
    800021a4:	4ea080e7          	jalr	1258(ra) # 8000168a <copyout>
    800021a8:	02054563          	bltz	a0,800021d2 <wait+0x9c>
          freeproc(np);
    800021ac:	8526                	mv	a0,s1
    800021ae:	00000097          	auipc	ra,0x0
    800021b2:	9ca080e7          	jalr	-1590(ra) # 80001b78 <freeproc>
          release(&np->lock);
    800021b6:	8526                	mv	a0,s1
    800021b8:	fffff097          	auipc	ra,0xfffff
    800021bc:	b16080e7          	jalr	-1258(ra) # 80000cce <release>
          release(&wait_lock);
    800021c0:	0000f517          	auipc	a0,0xf
    800021c4:	0f850513          	addi	a0,a0,248 # 800112b8 <wait_lock>
    800021c8:	fffff097          	auipc	ra,0xfffff
    800021cc:	b06080e7          	jalr	-1274(ra) # 80000cce <release>
          return pid;
    800021d0:	a09d                	j	80002236 <wait+0x100>
            release(&np->lock);
    800021d2:	8526                	mv	a0,s1
    800021d4:	fffff097          	auipc	ra,0xfffff
    800021d8:	afa080e7          	jalr	-1286(ra) # 80000cce <release>
            release(&wait_lock);
    800021dc:	0000f517          	auipc	a0,0xf
    800021e0:	0dc50513          	addi	a0,a0,220 # 800112b8 <wait_lock>
    800021e4:	fffff097          	auipc	ra,0xfffff
    800021e8:	aea080e7          	jalr	-1302(ra) # 80000cce <release>
            return -1;
    800021ec:	59fd                	li	s3,-1
    800021ee:	a0a1                	j	80002236 <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    800021f0:	17848493          	addi	s1,s1,376
    800021f4:	03348463          	beq	s1,s3,8000221c <wait+0xe6>
      if(np->parent == p){
    800021f8:	64bc                	ld	a5,72(s1)
    800021fa:	ff279be3          	bne	a5,s2,800021f0 <wait+0xba>
        acquire(&np->lock);
    800021fe:	8526                	mv	a0,s1
    80002200:	fffff097          	auipc	ra,0xfffff
    80002204:	a1a080e7          	jalr	-1510(ra) # 80000c1a <acquire>
        if(np->state == ZOMBIE){
    80002208:	4cdc                	lw	a5,28(s1)
    8000220a:	f94781e3          	beq	a5,s4,8000218c <wait+0x56>
        release(&np->lock);
    8000220e:	8526                	mv	a0,s1
    80002210:	fffff097          	auipc	ra,0xfffff
    80002214:	abe080e7          	jalr	-1346(ra) # 80000cce <release>
        havekids = 1;
    80002218:	8756                	mv	a4,s5
    8000221a:	bfd9                	j	800021f0 <wait+0xba>
    if(!havekids || p->killed){
    8000221c:	c701                	beqz	a4,80002224 <wait+0xee>
    8000221e:	02892783          	lw	a5,40(s2)
    80002222:	c79d                	beqz	a5,80002250 <wait+0x11a>
      release(&wait_lock);
    80002224:	0000f517          	auipc	a0,0xf
    80002228:	09450513          	addi	a0,a0,148 # 800112b8 <wait_lock>
    8000222c:	fffff097          	auipc	ra,0xfffff
    80002230:	aa2080e7          	jalr	-1374(ra) # 80000cce <release>
      return -1;
    80002234:	59fd                	li	s3,-1
}
    80002236:	854e                	mv	a0,s3
    80002238:	60a6                	ld	ra,72(sp)
    8000223a:	6406                	ld	s0,64(sp)
    8000223c:	74e2                	ld	s1,56(sp)
    8000223e:	7942                	ld	s2,48(sp)
    80002240:	79a2                	ld	s3,40(sp)
    80002242:	7a02                	ld	s4,32(sp)
    80002244:	6ae2                	ld	s5,24(sp)
    80002246:	6b42                	ld	s6,16(sp)
    80002248:	6ba2                	ld	s7,8(sp)
    8000224a:	6c02                	ld	s8,0(sp)
    8000224c:	6161                	addi	sp,sp,80
    8000224e:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002250:	85e2                	mv	a1,s8
    80002252:	854a                	mv	a0,s2
    80002254:	00000097          	auipc	ra,0x0
    80002258:	e7e080e7          	jalr	-386(ra) # 800020d2 <sleep>
    havekids = 0;
    8000225c:	b715                	j	80002180 <wait+0x4a>

000000008000225e <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    8000225e:	7139                	addi	sp,sp,-64
    80002260:	fc06                	sd	ra,56(sp)
    80002262:	f822                	sd	s0,48(sp)
    80002264:	f426                	sd	s1,40(sp)
    80002266:	f04a                	sd	s2,32(sp)
    80002268:	ec4e                	sd	s3,24(sp)
    8000226a:	e852                	sd	s4,16(sp)
    8000226c:	e456                	sd	s5,8(sp)
    8000226e:	0080                	addi	s0,sp,64
    80002270:	8a2a                	mv	s4,a0
  struct proc *p;
  
  //uint64 sys_uptime(void);

  for(p = proc; p < &proc[NPROC]; p++) {
    80002272:	0000f497          	auipc	s1,0xf
    80002276:	45e48493          	addi	s1,s1,1118 # 800116d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000227a:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000227c:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000227e:	00015917          	auipc	s2,0x15
    80002282:	25290913          	addi	s2,s2,594 # 800174d0 <tickslock>
    80002286:	a811                	j	8000229a <wakeup+0x3c>
        p->readytime = sys_uptime();
      }
      release(&p->lock);
    80002288:	8526                	mv	a0,s1
    8000228a:	fffff097          	auipc	ra,0xfffff
    8000228e:	a44080e7          	jalr	-1468(ra) # 80000cce <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002292:	17848493          	addi	s1,s1,376
    80002296:	03248b63          	beq	s1,s2,800022cc <wakeup+0x6e>
    if(p != myproc()){
    8000229a:	fffff097          	auipc	ra,0xfffff
    8000229e:	72c080e7          	jalr	1836(ra) # 800019c6 <myproc>
    800022a2:	fea488e3          	beq	s1,a0,80002292 <wakeup+0x34>
      acquire(&p->lock);
    800022a6:	8526                	mv	a0,s1
    800022a8:	fffff097          	auipc	ra,0xfffff
    800022ac:	972080e7          	jalr	-1678(ra) # 80000c1a <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800022b0:	4cdc                	lw	a5,28(s1)
    800022b2:	fd379be3          	bne	a5,s3,80002288 <wakeup+0x2a>
    800022b6:	709c                	ld	a5,32(s1)
    800022b8:	fd4798e3          	bne	a5,s4,80002288 <wakeup+0x2a>
        p->state = RUNNABLE;
    800022bc:	0154ae23          	sw	s5,28(s1)
        p->readytime = sys_uptime();
    800022c0:	00001097          	auipc	ra,0x1
    800022c4:	d84080e7          	jalr	-636(ra) # 80003044 <sys_uptime>
    800022c8:	e0a8                	sd	a0,64(s1)
    800022ca:	bf7d                	j	80002288 <wakeup+0x2a>
    }
  }
}
    800022cc:	70e2                	ld	ra,56(sp)
    800022ce:	7442                	ld	s0,48(sp)
    800022d0:	74a2                	ld	s1,40(sp)
    800022d2:	7902                	ld	s2,32(sp)
    800022d4:	69e2                	ld	s3,24(sp)
    800022d6:	6a42                	ld	s4,16(sp)
    800022d8:	6aa2                	ld	s5,8(sp)
    800022da:	6121                	addi	sp,sp,64
    800022dc:	8082                	ret

00000000800022de <reparent>:
{
    800022de:	7179                	addi	sp,sp,-48
    800022e0:	f406                	sd	ra,40(sp)
    800022e2:	f022                	sd	s0,32(sp)
    800022e4:	ec26                	sd	s1,24(sp)
    800022e6:	e84a                	sd	s2,16(sp)
    800022e8:	e44e                	sd	s3,8(sp)
    800022ea:	e052                	sd	s4,0(sp)
    800022ec:	1800                	addi	s0,sp,48
    800022ee:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800022f0:	0000f497          	auipc	s1,0xf
    800022f4:	3e048493          	addi	s1,s1,992 # 800116d0 <proc>
      pp->parent = initproc;
    800022f8:	00007a17          	auipc	s4,0x7
    800022fc:	d30a0a13          	addi	s4,s4,-720 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002300:	00015997          	auipc	s3,0x15
    80002304:	1d098993          	addi	s3,s3,464 # 800174d0 <tickslock>
    80002308:	a029                	j	80002312 <reparent+0x34>
    8000230a:	17848493          	addi	s1,s1,376
    8000230e:	01348d63          	beq	s1,s3,80002328 <reparent+0x4a>
    if(pp->parent == p){
    80002312:	64bc                	ld	a5,72(s1)
    80002314:	ff279be3          	bne	a5,s2,8000230a <reparent+0x2c>
      pp->parent = initproc;
    80002318:	000a3503          	ld	a0,0(s4)
    8000231c:	e4a8                	sd	a0,72(s1)
      wakeup(initproc);
    8000231e:	00000097          	auipc	ra,0x0
    80002322:	f40080e7          	jalr	-192(ra) # 8000225e <wakeup>
    80002326:	b7d5                	j	8000230a <reparent+0x2c>
}
    80002328:	70a2                	ld	ra,40(sp)
    8000232a:	7402                	ld	s0,32(sp)
    8000232c:	64e2                	ld	s1,24(sp)
    8000232e:	6942                	ld	s2,16(sp)
    80002330:	69a2                	ld	s3,8(sp)
    80002332:	6a02                	ld	s4,0(sp)
    80002334:	6145                	addi	sp,sp,48
    80002336:	8082                	ret

0000000080002338 <exit>:
{
    80002338:	7179                	addi	sp,sp,-48
    8000233a:	f406                	sd	ra,40(sp)
    8000233c:	f022                	sd	s0,32(sp)
    8000233e:	ec26                	sd	s1,24(sp)
    80002340:	e84a                	sd	s2,16(sp)
    80002342:	e44e                	sd	s3,8(sp)
    80002344:	e052                	sd	s4,0(sp)
    80002346:	1800                	addi	s0,sp,48
    80002348:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000234a:	fffff097          	auipc	ra,0xfffff
    8000234e:	67c080e7          	jalr	1660(ra) # 800019c6 <myproc>
    80002352:	89aa                	mv	s3,a0
  if(p == initproc)
    80002354:	00007797          	auipc	a5,0x7
    80002358:	cd47b783          	ld	a5,-812(a5) # 80009028 <initproc>
    8000235c:	0e050493          	addi	s1,a0,224
    80002360:	16050913          	addi	s2,a0,352
    80002364:	02a79363          	bne	a5,a0,8000238a <exit+0x52>
    panic("init exiting");
    80002368:	00006517          	auipc	a0,0x6
    8000236c:	ec050513          	addi	a0,a0,-320 # 80008228 <digits+0x1e8>
    80002370:	ffffe097          	auipc	ra,0xffffe
    80002374:	1ca080e7          	jalr	458(ra) # 8000053a <panic>
      fileclose(f);
    80002378:	00002097          	auipc	ra,0x2
    8000237c:	544080e7          	jalr	1348(ra) # 800048bc <fileclose>
      p->ofile[fd] = 0;
    80002380:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002384:	04a1                	addi	s1,s1,8
    80002386:	01248563          	beq	s1,s2,80002390 <exit+0x58>
    if(p->ofile[fd]){
    8000238a:	6088                	ld	a0,0(s1)
    8000238c:	f575                	bnez	a0,80002378 <exit+0x40>
    8000238e:	bfdd                	j	80002384 <exit+0x4c>
  begin_op();
    80002390:	00002097          	auipc	ra,0x2
    80002394:	064080e7          	jalr	100(ra) # 800043f4 <begin_op>
  iput(p->cwd);
    80002398:	1609b503          	ld	a0,352(s3)
    8000239c:	00002097          	auipc	ra,0x2
    800023a0:	836080e7          	jalr	-1994(ra) # 80003bd2 <iput>
  end_op();
    800023a4:	00002097          	auipc	ra,0x2
    800023a8:	0ce080e7          	jalr	206(ra) # 80004472 <end_op>
  p->cwd = 0;
    800023ac:	1609b023          	sd	zero,352(s3)
  acquire(&wait_lock);
    800023b0:	0000f497          	auipc	s1,0xf
    800023b4:	f0848493          	addi	s1,s1,-248 # 800112b8 <wait_lock>
    800023b8:	8526                	mv	a0,s1
    800023ba:	fffff097          	auipc	ra,0xfffff
    800023be:	860080e7          	jalr	-1952(ra) # 80000c1a <acquire>
  reparent(p);
    800023c2:	854e                	mv	a0,s3
    800023c4:	00000097          	auipc	ra,0x0
    800023c8:	f1a080e7          	jalr	-230(ra) # 800022de <reparent>
  wakeup(p->parent);
    800023cc:	0489b503          	ld	a0,72(s3)
    800023d0:	00000097          	auipc	ra,0x0
    800023d4:	e8e080e7          	jalr	-370(ra) # 8000225e <wakeup>
  acquire(&p->lock);
    800023d8:	854e                	mv	a0,s3
    800023da:	fffff097          	auipc	ra,0xfffff
    800023de:	840080e7          	jalr	-1984(ra) # 80000c1a <acquire>
  p->xstate = status;
    800023e2:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800023e6:	4795                	li	a5,5
    800023e8:	00f9ae23          	sw	a5,28(s3)
  release(&wait_lock);
    800023ec:	8526                	mv	a0,s1
    800023ee:	fffff097          	auipc	ra,0xfffff
    800023f2:	8e0080e7          	jalr	-1824(ra) # 80000cce <release>
  sched();
    800023f6:	00000097          	auipc	ra,0x0
    800023fa:	bca080e7          	jalr	-1078(ra) # 80001fc0 <sched>
  panic("zombie exit");
    800023fe:	00006517          	auipc	a0,0x6
    80002402:	e3a50513          	addi	a0,a0,-454 # 80008238 <digits+0x1f8>
    80002406:	ffffe097          	auipc	ra,0xffffe
    8000240a:	134080e7          	jalr	308(ra) # 8000053a <panic>

000000008000240e <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000240e:	7179                	addi	sp,sp,-48
    80002410:	f406                	sd	ra,40(sp)
    80002412:	f022                	sd	s0,32(sp)
    80002414:	ec26                	sd	s1,24(sp)
    80002416:	e84a                	sd	s2,16(sp)
    80002418:	e44e                	sd	s3,8(sp)
    8000241a:	1800                	addi	s0,sp,48
    8000241c:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000241e:	0000f497          	auipc	s1,0xf
    80002422:	2b248493          	addi	s1,s1,690 # 800116d0 <proc>
    80002426:	00015997          	auipc	s3,0x15
    8000242a:	0aa98993          	addi	s3,s3,170 # 800174d0 <tickslock>
    acquire(&p->lock);
    8000242e:	8526                	mv	a0,s1
    80002430:	ffffe097          	auipc	ra,0xffffe
    80002434:	7ea080e7          	jalr	2026(ra) # 80000c1a <acquire>
    if(p->pid == pid){
    80002438:	589c                	lw	a5,48(s1)
    8000243a:	01278d63          	beq	a5,s2,80002454 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000243e:	8526                	mv	a0,s1
    80002440:	fffff097          	auipc	ra,0xfffff
    80002444:	88e080e7          	jalr	-1906(ra) # 80000cce <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002448:	17848493          	addi	s1,s1,376
    8000244c:	ff3491e3          	bne	s1,s3,8000242e <kill+0x20>
  }
  return -1;
    80002450:	557d                	li	a0,-1
    80002452:	a829                	j	8000246c <kill+0x5e>
      p->killed = 1;
    80002454:	4785                	li	a5,1
    80002456:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002458:	4cd8                	lw	a4,28(s1)
    8000245a:	4789                	li	a5,2
    8000245c:	00f70f63          	beq	a4,a5,8000247a <kill+0x6c>
      release(&p->lock);
    80002460:	8526                	mv	a0,s1
    80002462:	fffff097          	auipc	ra,0xfffff
    80002466:	86c080e7          	jalr	-1940(ra) # 80000cce <release>
      return 0;
    8000246a:	4501                	li	a0,0
}
    8000246c:	70a2                	ld	ra,40(sp)
    8000246e:	7402                	ld	s0,32(sp)
    80002470:	64e2                	ld	s1,24(sp)
    80002472:	6942                	ld	s2,16(sp)
    80002474:	69a2                	ld	s3,8(sp)
    80002476:	6145                	addi	sp,sp,48
    80002478:	8082                	ret
        p->state = RUNNABLE;
    8000247a:	478d                	li	a5,3
    8000247c:	ccdc                	sw	a5,28(s1)
    8000247e:	b7cd                	j	80002460 <kill+0x52>

0000000080002480 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002480:	7179                	addi	sp,sp,-48
    80002482:	f406                	sd	ra,40(sp)
    80002484:	f022                	sd	s0,32(sp)
    80002486:	ec26                	sd	s1,24(sp)
    80002488:	e84a                	sd	s2,16(sp)
    8000248a:	e44e                	sd	s3,8(sp)
    8000248c:	e052                	sd	s4,0(sp)
    8000248e:	1800                	addi	s0,sp,48
    80002490:	84aa                	mv	s1,a0
    80002492:	892e                	mv	s2,a1
    80002494:	89b2                	mv	s3,a2
    80002496:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002498:	fffff097          	auipc	ra,0xfffff
    8000249c:	52e080e7          	jalr	1326(ra) # 800019c6 <myproc>
  if(user_dst){
    800024a0:	c08d                	beqz	s1,800024c2 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800024a2:	86d2                	mv	a3,s4
    800024a4:	864e                	mv	a2,s3
    800024a6:	85ca                	mv	a1,s2
    800024a8:	7128                	ld	a0,96(a0)
    800024aa:	fffff097          	auipc	ra,0xfffff
    800024ae:	1e0080e7          	jalr	480(ra) # 8000168a <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024b2:	70a2                	ld	ra,40(sp)
    800024b4:	7402                	ld	s0,32(sp)
    800024b6:	64e2                	ld	s1,24(sp)
    800024b8:	6942                	ld	s2,16(sp)
    800024ba:	69a2                	ld	s3,8(sp)
    800024bc:	6a02                	ld	s4,0(sp)
    800024be:	6145                	addi	sp,sp,48
    800024c0:	8082                	ret
    memmove((char *)dst, src, len);
    800024c2:	000a061b          	sext.w	a2,s4
    800024c6:	85ce                	mv	a1,s3
    800024c8:	854a                	mv	a0,s2
    800024ca:	fffff097          	auipc	ra,0xfffff
    800024ce:	8a8080e7          	jalr	-1880(ra) # 80000d72 <memmove>
    return 0;
    800024d2:	8526                	mv	a0,s1
    800024d4:	bff9                	j	800024b2 <either_copyout+0x32>

00000000800024d6 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024d6:	7179                	addi	sp,sp,-48
    800024d8:	f406                	sd	ra,40(sp)
    800024da:	f022                	sd	s0,32(sp)
    800024dc:	ec26                	sd	s1,24(sp)
    800024de:	e84a                	sd	s2,16(sp)
    800024e0:	e44e                	sd	s3,8(sp)
    800024e2:	e052                	sd	s4,0(sp)
    800024e4:	1800                	addi	s0,sp,48
    800024e6:	892a                	mv	s2,a0
    800024e8:	84ae                	mv	s1,a1
    800024ea:	89b2                	mv	s3,a2
    800024ec:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024ee:	fffff097          	auipc	ra,0xfffff
    800024f2:	4d8080e7          	jalr	1240(ra) # 800019c6 <myproc>
  if(user_src){
    800024f6:	c08d                	beqz	s1,80002518 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800024f8:	86d2                	mv	a3,s4
    800024fa:	864e                	mv	a2,s3
    800024fc:	85ca                	mv	a1,s2
    800024fe:	7128                	ld	a0,96(a0)
    80002500:	fffff097          	auipc	ra,0xfffff
    80002504:	216080e7          	jalr	534(ra) # 80001716 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002508:	70a2                	ld	ra,40(sp)
    8000250a:	7402                	ld	s0,32(sp)
    8000250c:	64e2                	ld	s1,24(sp)
    8000250e:	6942                	ld	s2,16(sp)
    80002510:	69a2                	ld	s3,8(sp)
    80002512:	6a02                	ld	s4,0(sp)
    80002514:	6145                	addi	sp,sp,48
    80002516:	8082                	ret
    memmove(dst, (char*)src, len);
    80002518:	000a061b          	sext.w	a2,s4
    8000251c:	85ce                	mv	a1,s3
    8000251e:	854a                	mv	a0,s2
    80002520:	fffff097          	auipc	ra,0xfffff
    80002524:	852080e7          	jalr	-1966(ra) # 80000d72 <memmove>
    return 0;
    80002528:	8526                	mv	a0,s1
    8000252a:	bff9                	j	80002508 <either_copyin+0x32>

000000008000252c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000252c:	715d                	addi	sp,sp,-80
    8000252e:	e486                	sd	ra,72(sp)
    80002530:	e0a2                	sd	s0,64(sp)
    80002532:	fc26                	sd	s1,56(sp)
    80002534:	f84a                	sd	s2,48(sp)
    80002536:	f44e                	sd	s3,40(sp)
    80002538:	f052                	sd	s4,32(sp)
    8000253a:	ec56                	sd	s5,24(sp)
    8000253c:	e85a                	sd	s6,16(sp)
    8000253e:	e45e                	sd	s7,8(sp)
    80002540:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002542:	00006517          	auipc	a0,0x6
    80002546:	b8650513          	addi	a0,a0,-1146 # 800080c8 <digits+0x88>
    8000254a:	ffffe097          	auipc	ra,0xffffe
    8000254e:	03a080e7          	jalr	58(ra) # 80000584 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002552:	0000f497          	auipc	s1,0xf
    80002556:	2e648493          	addi	s1,s1,742 # 80011838 <proc+0x168>
    8000255a:	00015917          	auipc	s2,0x15
    8000255e:	0de90913          	addi	s2,s2,222 # 80017638 <bcache+0x150>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002562:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002564:	00006997          	auipc	s3,0x6
    80002568:	ce498993          	addi	s3,s3,-796 # 80008248 <digits+0x208>
    printf("%d %s %s", p->pid, state, p->name);
    8000256c:	00006a97          	auipc	s5,0x6
    80002570:	ce4a8a93          	addi	s5,s5,-796 # 80008250 <digits+0x210>
    printf("\n");
    80002574:	00006a17          	auipc	s4,0x6
    80002578:	b54a0a13          	addi	s4,s4,-1196 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000257c:	00006b97          	auipc	s7,0x6
    80002580:	d0cb8b93          	addi	s7,s7,-756 # 80008288 <states.0>
    80002584:	a00d                	j	800025a6 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002586:	ec86a583          	lw	a1,-312(a3)
    8000258a:	8556                	mv	a0,s5
    8000258c:	ffffe097          	auipc	ra,0xffffe
    80002590:	ff8080e7          	jalr	-8(ra) # 80000584 <printf>
    printf("\n");
    80002594:	8552                	mv	a0,s4
    80002596:	ffffe097          	auipc	ra,0xffffe
    8000259a:	fee080e7          	jalr	-18(ra) # 80000584 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000259e:	17848493          	addi	s1,s1,376
    800025a2:	03248263          	beq	s1,s2,800025c6 <procdump+0x9a>
    if(p->state == UNUSED)
    800025a6:	86a6                	mv	a3,s1
    800025a8:	eb44a783          	lw	a5,-332(s1)
    800025ac:	dbed                	beqz	a5,8000259e <procdump+0x72>
      state = "???";
    800025ae:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025b0:	fcfb6be3          	bltu	s6,a5,80002586 <procdump+0x5a>
    800025b4:	02079713          	slli	a4,a5,0x20
    800025b8:	01d75793          	srli	a5,a4,0x1d
    800025bc:	97de                	add	a5,a5,s7
    800025be:	6390                	ld	a2,0(a5)
    800025c0:	f279                	bnez	a2,80002586 <procdump+0x5a>
      state = "???";
    800025c2:	864e                	mv	a2,s3
    800025c4:	b7c9                	j	80002586 <procdump+0x5a>
  }
}
    800025c6:	60a6                	ld	ra,72(sp)
    800025c8:	6406                	ld	s0,64(sp)
    800025ca:	74e2                	ld	s1,56(sp)
    800025cc:	7942                	ld	s2,48(sp)
    800025ce:	79a2                	ld	s3,40(sp)
    800025d0:	7a02                	ld	s4,32(sp)
    800025d2:	6ae2                	ld	s5,24(sp)
    800025d4:	6b42                	ld	s6,16(sp)
    800025d6:	6ba2                	ld	s7,8(sp)
    800025d8:	6161                	addi	sp,sp,80
    800025da:	8082                	ret

00000000800025dc <procinfo>:

// Fill in user-provided array with info for current processes
// Return the number of processes found
int
procinfo(uint64 addr)
{
    800025dc:	7175                	addi	sp,sp,-144
    800025de:	e506                	sd	ra,136(sp)
    800025e0:	e122                	sd	s0,128(sp)
    800025e2:	fca6                	sd	s1,120(sp)
    800025e4:	f8ca                	sd	s2,112(sp)
    800025e6:	f4ce                	sd	s3,104(sp)
    800025e8:	f0d2                	sd	s4,96(sp)
    800025ea:	ecd6                	sd	s5,88(sp)
    800025ec:	e8da                	sd	s6,80(sp)
    800025ee:	e4de                	sd	s7,72(sp)
    800025f0:	0900                	addi	s0,sp,144
    800025f2:	89aa                	mv	s3,a0
  struct proc *p;
  struct proc *thisproc = myproc();
    800025f4:	fffff097          	auipc	ra,0xfffff
    800025f8:	3d2080e7          	jalr	978(ra) # 800019c6 <myproc>
    800025fc:	8b2a                	mv	s6,a0
  struct pstat procinfo;
  int nprocs = 0;
  for(p = proc; p < &proc[NPROC]; p++){ 
    800025fe:	0000f917          	auipc	s2,0xf
    80002602:	23a90913          	addi	s2,s2,570 # 80011838 <proc+0x168>
    80002606:	00015a17          	auipc	s4,0x15
    8000260a:	032a0a13          	addi	s4,s4,50 # 80017638 <bcache+0x150>
  int nprocs = 0;
    8000260e:	4a81                	li	s5,0
    procinfo.readytime = p->readytime;
    
    if (p->parent)
      procinfo.ppid = (p->parent)->pid;
    else
      procinfo.ppid = 0;
    80002610:	4b81                	li	s7,0
    80002612:	fa440493          	addi	s1,s0,-92
    80002616:	a089                	j	80002658 <procinfo+0x7c>
    80002618:	f8f42823          	sw	a5,-112(s0)
    for (int i=0; i<16; i++)
    8000261c:	f9440793          	addi	a5,s0,-108
      procinfo.ppid = 0;
    80002620:	874a                	mv	a4,s2
      procinfo.name[i] = p->name[i];
    80002622:	00074683          	lbu	a3,0(a4)
    80002626:	00d78023          	sb	a3,0(a5)
    for (int i=0; i<16; i++)
    8000262a:	0705                	addi	a4,a4,1
    8000262c:	0785                	addi	a5,a5,1
    8000262e:	fe979ae3          	bne	a5,s1,80002622 <procinfo+0x46>
   if (copyout(thisproc->pagetable, addr, (char *)&procinfo, sizeof(procinfo)) < 0)
    80002632:	03800693          	li	a3,56
    80002636:	f7840613          	addi	a2,s0,-136
    8000263a:	85ce                	mv	a1,s3
    8000263c:	060b3503          	ld	a0,96(s6)
    80002640:	fffff097          	auipc	ra,0xfffff
    80002644:	04a080e7          	jalr	74(ra) # 8000168a <copyout>
    80002648:	04054463          	bltz	a0,80002690 <procinfo+0xb4>
      return -1;
    addr += sizeof(procinfo);
    8000264c:	03898993          	addi	s3,s3,56
  for(p = proc; p < &proc[NPROC]; p++){ 
    80002650:	17890913          	addi	s2,s2,376
    80002654:	03490f63          	beq	s2,s4,80002692 <procinfo+0xb6>
    if(p->state == UNUSED)
    80002658:	eb492783          	lw	a5,-332(s2)
    8000265c:	dbf5                	beqz	a5,80002650 <procinfo+0x74>
    nprocs++;
    8000265e:	2a85                	addiw	s5,s5,1
    procinfo.pid = p->pid;
    80002660:	ec892703          	lw	a4,-312(s2)
    80002664:	f6e42c23          	sw	a4,-136(s0)
    procinfo.state = p->state;
    80002668:	f8f42023          	sw	a5,-128(s0)
    procinfo.size = p->sz;
    8000266c:	ef093783          	ld	a5,-272(s2)
    80002670:	f8f43423          	sd	a5,-120(s0)
    procinfo.priority = p->priority;
    80002674:	eb092783          	lw	a5,-336(s2)
    80002678:	f6f42e23          	sw	a5,-132(s0)
    procinfo.readytime = p->readytime;
    8000267c:	ed893783          	ld	a5,-296(s2)
    80002680:	faf42223          	sw	a5,-92(s0)
    if (p->parent)
    80002684:	ee093703          	ld	a4,-288(s2)
      procinfo.ppid = 0;
    80002688:	87de                	mv	a5,s7
    if (p->parent)
    8000268a:	d759                	beqz	a4,80002618 <procinfo+0x3c>
      procinfo.ppid = (p->parent)->pid;
    8000268c:	5b1c                	lw	a5,48(a4)
    8000268e:	b769                	j	80002618 <procinfo+0x3c>
      return -1;
    80002690:	5afd                	li	s5,-1
  }
  return nprocs;
}
    80002692:	8556                	mv	a0,s5
    80002694:	60aa                	ld	ra,136(sp)
    80002696:	640a                	ld	s0,128(sp)
    80002698:	74e6                	ld	s1,120(sp)
    8000269a:	7946                	ld	s2,112(sp)
    8000269c:	79a6                	ld	s3,104(sp)
    8000269e:	7a06                	ld	s4,96(sp)
    800026a0:	6ae6                	ld	s5,88(sp)
    800026a2:	6b46                	ld	s6,80(sp)
    800026a4:	6ba6                	ld	s7,72(sp)
    800026a6:	6149                	addi	sp,sp,144
    800026a8:	8082                	ret

00000000800026aa <wait2>:
// WAIT2
// Wait for a child process to exit and return its status and reusage.
// Return -1 if this process has no children.
int
wait2(uint64 addr, uint64 addr2)
{
    800026aa:	7159                	addi	sp,sp,-112
    800026ac:	f486                	sd	ra,104(sp)
    800026ae:	f0a2                	sd	s0,96(sp)
    800026b0:	eca6                	sd	s1,88(sp)
    800026b2:	e8ca                	sd	s2,80(sp)
    800026b4:	e4ce                	sd	s3,72(sp)
    800026b6:	e0d2                	sd	s4,64(sp)
    800026b8:	fc56                	sd	s5,56(sp)
    800026ba:	f85a                	sd	s6,48(sp)
    800026bc:	f45e                	sd	s7,40(sp)
    800026be:	f062                	sd	s8,32(sp)
    800026c0:	ec66                	sd	s9,24(sp)
    800026c2:	1880                	addi	s0,sp,112
    800026c4:	8baa                	mv	s7,a0
    800026c6:	8b2e                	mv	s6,a1
  struct proc *np;
  int havekids, pid;
  struct rusage cru;
  struct proc *p = myproc();
    800026c8:	fffff097          	auipc	ra,0xfffff
    800026cc:	2fe080e7          	jalr	766(ra) # 800019c6 <myproc>
    800026d0:	892a                	mv	s2,a0

  acquire(&wait_lock);
    800026d2:	0000f517          	auipc	a0,0xf
    800026d6:	be650513          	addi	a0,a0,-1050 # 800112b8 <wait_lock>
    800026da:	ffffe097          	auipc	ra,0xffffe
    800026de:	540080e7          	jalr	1344(ra) # 80000c1a <acquire>

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    800026e2:	4c01                	li	s8,0
      if(np->parent == p){
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if(np->state == ZOMBIE){
    800026e4:	4a15                	li	s4,5
        havekids = 1;
    800026e6:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    800026e8:	00015997          	auipc	s3,0x15
    800026ec:	de898993          	addi	s3,s3,-536 # 800174d0 <tickslock>
      return -1;
    }
    
    
    // Wait for a child to exit.
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800026f0:	0000fc97          	auipc	s9,0xf
    800026f4:	bc8c8c93          	addi	s9,s9,-1080 # 800112b8 <wait_lock>
    havekids = 0;
    800026f8:	8762                	mv	a4,s8
    for(np = proc; np < &proc[NPROC]; np++){
    800026fa:	0000f497          	auipc	s1,0xf
    800026fe:	fd648493          	addi	s1,s1,-42 # 800116d0 <proc>
    80002702:	a07d                	j	800027b0 <wait2+0x106>
          pid = np->pid;
    80002704:	0304a983          	lw	s3,48(s1)
          cru.cputime = np -> cputime;
    80002708:	7c9c                	ld	a5,56(s1)
    8000270a:	f8f42c23          	sw	a5,-104(s0)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000270e:	040b9363          	bnez	s7,80002754 <wait2+0xaa>
          if(addr2 != 0 && copyout(p->pagetable, addr2, (char *)&cru,
    80002712:	000b0e63          	beqz	s6,8000272e <wait2+0x84>
    80002716:	4691                	li	a3,4
    80002718:	f9840613          	addi	a2,s0,-104
    8000271c:	85da                	mv	a1,s6
    8000271e:	06093503          	ld	a0,96(s2)
    80002722:	fffff097          	auipc	ra,0xfffff
    80002726:	f68080e7          	jalr	-152(ra) # 8000168a <copyout>
    8000272a:	06054063          	bltz	a0,8000278a <wait2+0xe0>
          freeproc(np);
    8000272e:	8526                	mv	a0,s1
    80002730:	fffff097          	auipc	ra,0xfffff
    80002734:	448080e7          	jalr	1096(ra) # 80001b78 <freeproc>
          release(&np->lock);
    80002738:	8526                	mv	a0,s1
    8000273a:	ffffe097          	auipc	ra,0xffffe
    8000273e:	594080e7          	jalr	1428(ra) # 80000cce <release>
          release(&wait_lock);
    80002742:	0000f517          	auipc	a0,0xf
    80002746:	b7650513          	addi	a0,a0,-1162 # 800112b8 <wait_lock>
    8000274a:	ffffe097          	auipc	ra,0xffffe
    8000274e:	584080e7          	jalr	1412(ra) # 80000cce <release>
          return pid;
    80002752:	a871                	j	800027ee <wait2+0x144>
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002754:	4691                	li	a3,4
    80002756:	02c48613          	addi	a2,s1,44
    8000275a:	85de                	mv	a1,s7
    8000275c:	06093503          	ld	a0,96(s2)
    80002760:	fffff097          	auipc	ra,0xfffff
    80002764:	f2a080e7          	jalr	-214(ra) # 8000168a <copyout>
    80002768:	fa0555e3          	bgez	a0,80002712 <wait2+0x68>
            release(&np->lock);
    8000276c:	8526                	mv	a0,s1
    8000276e:	ffffe097          	auipc	ra,0xffffe
    80002772:	560080e7          	jalr	1376(ra) # 80000cce <release>
            release(&wait_lock);
    80002776:	0000f517          	auipc	a0,0xf
    8000277a:	b4250513          	addi	a0,a0,-1214 # 800112b8 <wait_lock>
    8000277e:	ffffe097          	auipc	ra,0xffffe
    80002782:	550080e7          	jalr	1360(ra) # 80000cce <release>
            return -1;
    80002786:	59fd                	li	s3,-1
    80002788:	a09d                	j	800027ee <wait2+0x144>
            release(&np->lock);
    8000278a:	8526                	mv	a0,s1
    8000278c:	ffffe097          	auipc	ra,0xffffe
    80002790:	542080e7          	jalr	1346(ra) # 80000cce <release>
            release(&wait_lock);
    80002794:	0000f517          	auipc	a0,0xf
    80002798:	b2450513          	addi	a0,a0,-1244 # 800112b8 <wait_lock>
    8000279c:	ffffe097          	auipc	ra,0xffffe
    800027a0:	532080e7          	jalr	1330(ra) # 80000cce <release>
            return -1;
    800027a4:	59fd                	li	s3,-1
    800027a6:	a0a1                	j	800027ee <wait2+0x144>
    for(np = proc; np < &proc[NPROC]; np++){
    800027a8:	17848493          	addi	s1,s1,376
    800027ac:	03348463          	beq	s1,s3,800027d4 <wait2+0x12a>
      if(np->parent == p){
    800027b0:	64bc                	ld	a5,72(s1)
    800027b2:	ff279be3          	bne	a5,s2,800027a8 <wait2+0xfe>
        acquire(&np->lock);
    800027b6:	8526                	mv	a0,s1
    800027b8:	ffffe097          	auipc	ra,0xffffe
    800027bc:	462080e7          	jalr	1122(ra) # 80000c1a <acquire>
        if(np->state == ZOMBIE){
    800027c0:	4cdc                	lw	a5,28(s1)
    800027c2:	f54781e3          	beq	a5,s4,80002704 <wait2+0x5a>
        release(&np->lock);
    800027c6:	8526                	mv	a0,s1
    800027c8:	ffffe097          	auipc	ra,0xffffe
    800027cc:	506080e7          	jalr	1286(ra) # 80000cce <release>
        havekids = 1;
    800027d0:	8756                	mv	a4,s5
    800027d2:	bfd9                	j	800027a8 <wait2+0xfe>
    if(!havekids || p->killed){
    800027d4:	c701                	beqz	a4,800027dc <wait2+0x132>
    800027d6:	02892783          	lw	a5,40(s2)
    800027da:	cb85                	beqz	a5,8000280a <wait2+0x160>
      release(&wait_lock);
    800027dc:	0000f517          	auipc	a0,0xf
    800027e0:	adc50513          	addi	a0,a0,-1316 # 800112b8 <wait_lock>
    800027e4:	ffffe097          	auipc	ra,0xffffe
    800027e8:	4ea080e7          	jalr	1258(ra) # 80000cce <release>
      return -1;
    800027ec:	59fd                	li	s3,-1
  }
}
    800027ee:	854e                	mv	a0,s3
    800027f0:	70a6                	ld	ra,104(sp)
    800027f2:	7406                	ld	s0,96(sp)
    800027f4:	64e6                	ld	s1,88(sp)
    800027f6:	6946                	ld	s2,80(sp)
    800027f8:	69a6                	ld	s3,72(sp)
    800027fa:	6a06                	ld	s4,64(sp)
    800027fc:	7ae2                	ld	s5,56(sp)
    800027fe:	7b42                	ld	s6,48(sp)
    80002800:	7ba2                	ld	s7,40(sp)
    80002802:	7c02                	ld	s8,32(sp)
    80002804:	6ce2                	ld	s9,24(sp)
    80002806:	6165                	addi	sp,sp,112
    80002808:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000280a:	85e6                	mv	a1,s9
    8000280c:	854a                	mv	a0,s2
    8000280e:	00000097          	auipc	ra,0x0
    80002812:	8c4080e7          	jalr	-1852(ra) # 800020d2 <sleep>
    havekids = 0;
    80002816:	b5cd                	j	800026f8 <wait2+0x4e>

0000000080002818 <swtch>:
    80002818:	00153023          	sd	ra,0(a0)
    8000281c:	00253423          	sd	sp,8(a0)
    80002820:	e900                	sd	s0,16(a0)
    80002822:	ed04                	sd	s1,24(a0)
    80002824:	03253023          	sd	s2,32(a0)
    80002828:	03353423          	sd	s3,40(a0)
    8000282c:	03453823          	sd	s4,48(a0)
    80002830:	03553c23          	sd	s5,56(a0)
    80002834:	05653023          	sd	s6,64(a0)
    80002838:	05753423          	sd	s7,72(a0)
    8000283c:	05853823          	sd	s8,80(a0)
    80002840:	05953c23          	sd	s9,88(a0)
    80002844:	07a53023          	sd	s10,96(a0)
    80002848:	07b53423          	sd	s11,104(a0)
    8000284c:	0005b083          	ld	ra,0(a1)
    80002850:	0085b103          	ld	sp,8(a1)
    80002854:	6980                	ld	s0,16(a1)
    80002856:	6d84                	ld	s1,24(a1)
    80002858:	0205b903          	ld	s2,32(a1)
    8000285c:	0285b983          	ld	s3,40(a1)
    80002860:	0305ba03          	ld	s4,48(a1)
    80002864:	0385ba83          	ld	s5,56(a1)
    80002868:	0405bb03          	ld	s6,64(a1)
    8000286c:	0485bb83          	ld	s7,72(a1)
    80002870:	0505bc03          	ld	s8,80(a1)
    80002874:	0585bc83          	ld	s9,88(a1)
    80002878:	0605bd03          	ld	s10,96(a1)
    8000287c:	0685bd83          	ld	s11,104(a1)
    80002880:	8082                	ret

0000000080002882 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002882:	1141                	addi	sp,sp,-16
    80002884:	e406                	sd	ra,8(sp)
    80002886:	e022                	sd	s0,0(sp)
    80002888:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000288a:	00006597          	auipc	a1,0x6
    8000288e:	a2e58593          	addi	a1,a1,-1490 # 800082b8 <states.0+0x30>
    80002892:	00015517          	auipc	a0,0x15
    80002896:	c3e50513          	addi	a0,a0,-962 # 800174d0 <tickslock>
    8000289a:	ffffe097          	auipc	ra,0xffffe
    8000289e:	2f0080e7          	jalr	752(ra) # 80000b8a <initlock>
}
    800028a2:	60a2                	ld	ra,8(sp)
    800028a4:	6402                	ld	s0,0(sp)
    800028a6:	0141                	addi	sp,sp,16
    800028a8:	8082                	ret

00000000800028aa <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800028aa:	1141                	addi	sp,sp,-16
    800028ac:	e422                	sd	s0,8(sp)
    800028ae:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028b0:	00003797          	auipc	a5,0x3
    800028b4:	64078793          	addi	a5,a5,1600 # 80005ef0 <kernelvec>
    800028b8:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800028bc:	6422                	ld	s0,8(sp)
    800028be:	0141                	addi	sp,sp,16
    800028c0:	8082                	ret

00000000800028c2 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800028c2:	1141                	addi	sp,sp,-16
    800028c4:	e406                	sd	ra,8(sp)
    800028c6:	e022                	sd	s0,0(sp)
    800028c8:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800028ca:	fffff097          	auipc	ra,0xfffff
    800028ce:	0fc080e7          	jalr	252(ra) # 800019c6 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028d2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800028d6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028d8:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800028dc:	00004697          	auipc	a3,0x4
    800028e0:	72468693          	addi	a3,a3,1828 # 80007000 <_trampoline>
    800028e4:	00004717          	auipc	a4,0x4
    800028e8:	71c70713          	addi	a4,a4,1820 # 80007000 <_trampoline>
    800028ec:	8f15                	sub	a4,a4,a3
    800028ee:	040007b7          	lui	a5,0x4000
    800028f2:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800028f4:	07b2                	slli	a5,a5,0xc
    800028f6:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028f8:	10571073          	csrw	stvec,a4

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800028fc:	7538                	ld	a4,104(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800028fe:	18002673          	csrr	a2,satp
    80002902:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002904:	7530                	ld	a2,104(a0)
    80002906:	6938                	ld	a4,80(a0)
    80002908:	6585                	lui	a1,0x1
    8000290a:	972e                	add	a4,a4,a1
    8000290c:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000290e:	7538                	ld	a4,104(a0)
    80002910:	00000617          	auipc	a2,0x0
    80002914:	13860613          	addi	a2,a2,312 # 80002a48 <usertrap>
    80002918:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000291a:	7538                	ld	a4,104(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000291c:	8612                	mv	a2,tp
    8000291e:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002920:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002924:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002928:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000292c:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002930:	7538                	ld	a4,104(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002932:	6f18                	ld	a4,24(a4)
    80002934:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002938:	712c                	ld	a1,96(a0)
    8000293a:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    8000293c:	00004717          	auipc	a4,0x4
    80002940:	75470713          	addi	a4,a4,1876 # 80007090 <userret>
    80002944:	8f15                	sub	a4,a4,a3
    80002946:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002948:	577d                	li	a4,-1
    8000294a:	177e                	slli	a4,a4,0x3f
    8000294c:	8dd9                	or	a1,a1,a4
    8000294e:	02000537          	lui	a0,0x2000
    80002952:	157d                	addi	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    80002954:	0536                	slli	a0,a0,0xd
    80002956:	9782                	jalr	a5
}
    80002958:	60a2                	ld	ra,8(sp)
    8000295a:	6402                	ld	s0,0(sp)
    8000295c:	0141                	addi	sp,sp,16
    8000295e:	8082                	ret

0000000080002960 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002960:	1101                	addi	sp,sp,-32
    80002962:	ec06                	sd	ra,24(sp)
    80002964:	e822                	sd	s0,16(sp)
    80002966:	e426                	sd	s1,8(sp)
    80002968:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000296a:	00015497          	auipc	s1,0x15
    8000296e:	b6648493          	addi	s1,s1,-1178 # 800174d0 <tickslock>
    80002972:	8526                	mv	a0,s1
    80002974:	ffffe097          	auipc	ra,0xffffe
    80002978:	2a6080e7          	jalr	678(ra) # 80000c1a <acquire>
  ticks++;
    8000297c:	00006517          	auipc	a0,0x6
    80002980:	6b450513          	addi	a0,a0,1716 # 80009030 <ticks>
    80002984:	411c                	lw	a5,0(a0)
    80002986:	2785                	addiw	a5,a5,1
    80002988:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000298a:	00000097          	auipc	ra,0x0
    8000298e:	8d4080e7          	jalr	-1836(ra) # 8000225e <wakeup>
  release(&tickslock);
    80002992:	8526                	mv	a0,s1
    80002994:	ffffe097          	auipc	ra,0xffffe
    80002998:	33a080e7          	jalr	826(ra) # 80000cce <release>
}
    8000299c:	60e2                	ld	ra,24(sp)
    8000299e:	6442                	ld	s0,16(sp)
    800029a0:	64a2                	ld	s1,8(sp)
    800029a2:	6105                	addi	sp,sp,32
    800029a4:	8082                	ret

00000000800029a6 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800029a6:	1101                	addi	sp,sp,-32
    800029a8:	ec06                	sd	ra,24(sp)
    800029aa:	e822                	sd	s0,16(sp)
    800029ac:	e426                	sd	s1,8(sp)
    800029ae:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029b0:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800029b4:	00074d63          	bltz	a4,800029ce <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800029b8:	57fd                	li	a5,-1
    800029ba:	17fe                	slli	a5,a5,0x3f
    800029bc:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800029be:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800029c0:	06f70363          	beq	a4,a5,80002a26 <devintr+0x80>
  }
}
    800029c4:	60e2                	ld	ra,24(sp)
    800029c6:	6442                	ld	s0,16(sp)
    800029c8:	64a2                	ld	s1,8(sp)
    800029ca:	6105                	addi	sp,sp,32
    800029cc:	8082                	ret
     (scause & 0xff) == 9){
    800029ce:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    800029d2:	46a5                	li	a3,9
    800029d4:	fed792e3          	bne	a5,a3,800029b8 <devintr+0x12>
    int irq = plic_claim();
    800029d8:	00003097          	auipc	ra,0x3
    800029dc:	620080e7          	jalr	1568(ra) # 80005ff8 <plic_claim>
    800029e0:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800029e2:	47a9                	li	a5,10
    800029e4:	02f50763          	beq	a0,a5,80002a12 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800029e8:	4785                	li	a5,1
    800029ea:	02f50963          	beq	a0,a5,80002a1c <devintr+0x76>
    return 1;
    800029ee:	4505                	li	a0,1
    } else if(irq){
    800029f0:	d8f1                	beqz	s1,800029c4 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800029f2:	85a6                	mv	a1,s1
    800029f4:	00006517          	auipc	a0,0x6
    800029f8:	8cc50513          	addi	a0,a0,-1844 # 800082c0 <states.0+0x38>
    800029fc:	ffffe097          	auipc	ra,0xffffe
    80002a00:	b88080e7          	jalr	-1144(ra) # 80000584 <printf>
      plic_complete(irq);
    80002a04:	8526                	mv	a0,s1
    80002a06:	00003097          	auipc	ra,0x3
    80002a0a:	616080e7          	jalr	1558(ra) # 8000601c <plic_complete>
    return 1;
    80002a0e:	4505                	li	a0,1
    80002a10:	bf55                	j	800029c4 <devintr+0x1e>
      uartintr();
    80002a12:	ffffe097          	auipc	ra,0xffffe
    80002a16:	f80080e7          	jalr	-128(ra) # 80000992 <uartintr>
    80002a1a:	b7ed                	j	80002a04 <devintr+0x5e>
      virtio_disk_intr();
    80002a1c:	00004097          	auipc	ra,0x4
    80002a20:	a8c080e7          	jalr	-1396(ra) # 800064a8 <virtio_disk_intr>
    80002a24:	b7c5                	j	80002a04 <devintr+0x5e>
    if(cpuid() == 0){
    80002a26:	fffff097          	auipc	ra,0xfffff
    80002a2a:	f74080e7          	jalr	-140(ra) # 8000199a <cpuid>
    80002a2e:	c901                	beqz	a0,80002a3e <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002a30:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002a34:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002a36:	14479073          	csrw	sip,a5
    return 2;
    80002a3a:	4509                	li	a0,2
    80002a3c:	b761                	j	800029c4 <devintr+0x1e>
      clockintr();
    80002a3e:	00000097          	auipc	ra,0x0
    80002a42:	f22080e7          	jalr	-222(ra) # 80002960 <clockintr>
    80002a46:	b7ed                	j	80002a30 <devintr+0x8a>

0000000080002a48 <usertrap>:
{
    80002a48:	7179                	addi	sp,sp,-48
    80002a4a:	f406                	sd	ra,40(sp)
    80002a4c:	f022                	sd	s0,32(sp)
    80002a4e:	ec26                	sd	s1,24(sp)
    80002a50:	e84a                	sd	s2,16(sp)
    80002a52:	e44e                	sd	s3,8(sp)
    80002a54:	e052                	sd	s4,0(sp)
    80002a56:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a58:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002a5c:	1007f793          	andi	a5,a5,256
    80002a60:	e7a5                	bnez	a5,80002ac8 <usertrap+0x80>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a62:	00003797          	auipc	a5,0x3
    80002a66:	48e78793          	addi	a5,a5,1166 # 80005ef0 <kernelvec>
    80002a6a:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002a6e:	fffff097          	auipc	ra,0xfffff
    80002a72:	f58080e7          	jalr	-168(ra) # 800019c6 <myproc>
    80002a76:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002a78:	753c                	ld	a5,104(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a7a:	14102773          	csrr	a4,sepc
    80002a7e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a80:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002a84:	47a1                	li	a5,8
    80002a86:	04f71f63          	bne	a4,a5,80002ae4 <usertrap+0x9c>
    if(p->killed)
    80002a8a:	551c                	lw	a5,40(a0)
    80002a8c:	e7b1                	bnez	a5,80002ad8 <usertrap+0x90>
    p->trapframe->epc += 4;
    80002a8e:	74b8                	ld	a4,104(s1)
    80002a90:	6f1c                	ld	a5,24(a4)
    80002a92:	0791                	addi	a5,a5,4
    80002a94:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a96:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002a9a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a9e:	10079073          	csrw	sstatus,a5
    syscall();
    80002aa2:	00000097          	auipc	ra,0x0
    80002aa6:	372080e7          	jalr	882(ra) # 80002e14 <syscall>
  if(p->killed)
    80002aaa:	549c                	lw	a5,40(s1)
    80002aac:	10079a63          	bnez	a5,80002bc0 <usertrap+0x178>
  usertrapret();
    80002ab0:	00000097          	auipc	ra,0x0
    80002ab4:	e12080e7          	jalr	-494(ra) # 800028c2 <usertrapret>
}
    80002ab8:	70a2                	ld	ra,40(sp)
    80002aba:	7402                	ld	s0,32(sp)
    80002abc:	64e2                	ld	s1,24(sp)
    80002abe:	6942                	ld	s2,16(sp)
    80002ac0:	69a2                	ld	s3,8(sp)
    80002ac2:	6a02                	ld	s4,0(sp)
    80002ac4:	6145                	addi	sp,sp,48
    80002ac6:	8082                	ret
    panic("usertrap: not from user mode");
    80002ac8:	00006517          	auipc	a0,0x6
    80002acc:	81850513          	addi	a0,a0,-2024 # 800082e0 <states.0+0x58>
    80002ad0:	ffffe097          	auipc	ra,0xffffe
    80002ad4:	a6a080e7          	jalr	-1430(ra) # 8000053a <panic>
      exit(-1);
    80002ad8:	557d                	li	a0,-1
    80002ada:	00000097          	auipc	ra,0x0
    80002ade:	85e080e7          	jalr	-1954(ra) # 80002338 <exit>
    80002ae2:	b775                	j	80002a8e <usertrap+0x46>
  } else if((which_dev = devintr()) != 0){
    80002ae4:	00000097          	auipc	ra,0x0
    80002ae8:	ec2080e7          	jalr	-318(ra) # 800029a6 <devintr>
    80002aec:	892a                	mv	s2,a0
    80002aee:	e571                	bnez	a0,80002bba <usertrap+0x172>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002af0:	14202773          	csrr	a4,scause
  } else if(r_scause() == 13 || r_scause() == 15){
    80002af4:	47b5                	li	a5,13
    80002af6:	00f70763          	beq	a4,a5,80002b04 <usertrap+0xbc>
    80002afa:	14202773          	csrr	a4,scause
    80002afe:	47bd                	li	a5,15
    80002b00:	08f71563          	bne	a4,a5,80002b8a <usertrap+0x142>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b04:	143029f3          	csrr	s3,stval
  	if(fault_addr < p -> sz){
    80002b08:	6cbc                	ld	a5,88(s1)
    80002b0a:	04f9f463          	bgeu	s3,a5,80002b52 <usertrap+0x10a>
  		char* physical_frame = kalloc();
    80002b0e:	ffffe097          	auipc	ra,0xffffe
    80002b12:	fd2080e7          	jalr	-46(ra) # 80000ae0 <kalloc>
    80002b16:	8a2a                	mv	s4,a0
  		if(physical_frame == 0){
    80002b18:	c11d                	beqz	a0,80002b3e <usertrap+0xf6>
  		memset((void*)physical_frame, 0, PGSIZE);
    80002b1a:	6605                	lui	a2,0x1
    80002b1c:	4581                	li	a1,0
    80002b1e:	ffffe097          	auipc	ra,0xffffe
    80002b22:	1f8080e7          	jalr	504(ra) # 80000d16 <memset>
  		mappages(p -> pagetable, PGROUNDDOWN(fault_addr), PGSIZE, (uint64)physical_frame, (PTE_R | PTE_W | PTE_X | PTE_U));
    80002b26:	4779                	li	a4,30
    80002b28:	86d2                	mv	a3,s4
    80002b2a:	6605                	lui	a2,0x1
    80002b2c:	75fd                	lui	a1,0xfffff
    80002b2e:	00b9f5b3          	and	a1,s3,a1
    80002b32:	70a8                	ld	a0,96(s1)
    80002b34:	ffffe097          	auipc	ra,0xffffe
    80002b38:	5aa080e7          	jalr	1450(ra) # 800010de <mappages>
    80002b3c:	b7bd                	j	80002aaa <usertrap+0x62>
  		printf("usertrap(): out of memory, pid = %d\n", p -> pid);
    80002b3e:	588c                	lw	a1,48(s1)
    80002b40:	00005517          	auipc	a0,0x5
    80002b44:	7c050513          	addi	a0,a0,1984 # 80008300 <states.0+0x78>
    80002b48:	ffffe097          	auipc	ra,0xffffe
    80002b4c:	a3c080e7          	jalr	-1476(ra) # 80000584 <printf>
  		p -> killed = 1;
    80002b50:	a819                	j	80002b66 <usertrap+0x11e>
  	printf("usertrap(): out of memory, pid = %d, faulting_address = %p\n", p -> pid, fault_addr);
    80002b52:	864e                	mv	a2,s3
    80002b54:	588c                	lw	a1,48(s1)
    80002b56:	00005517          	auipc	a0,0x5
    80002b5a:	7d250513          	addi	a0,a0,2002 # 80008328 <states.0+0xa0>
    80002b5e:	ffffe097          	auipc	ra,0xffffe
    80002b62:	a26080e7          	jalr	-1498(ra) # 80000584 <printf>
  		p -> killed = 1;
    80002b66:	4785                	li	a5,1
    80002b68:	d49c                	sw	a5,40(s1)
    exit(-1);
    80002b6a:	557d                	li	a0,-1
    80002b6c:	fffff097          	auipc	ra,0xfffff
    80002b70:	7cc080e7          	jalr	1996(ra) # 80002338 <exit>
  if(which_dev == 2){
    80002b74:	4789                	li	a5,2
    80002b76:	f2f91de3          	bne	s2,a5,80002ab0 <usertrap+0x68>
    p -> cputime++;
    80002b7a:	7c9c                	ld	a5,56(s1)
    80002b7c:	0785                	addi	a5,a5,1
    80002b7e:	fc9c                	sd	a5,56(s1)
    yield();
    80002b80:	fffff097          	auipc	ra,0xfffff
    80002b84:	516080e7          	jalr	1302(ra) # 80002096 <yield>
    80002b88:	b725                	j	80002ab0 <usertrap+0x68>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b8a:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002b8e:	5890                	lw	a2,48(s1)
    80002b90:	00005517          	auipc	a0,0x5
    80002b94:	7d850513          	addi	a0,a0,2008 # 80008368 <states.0+0xe0>
    80002b98:	ffffe097          	auipc	ra,0xffffe
    80002b9c:	9ec080e7          	jalr	-1556(ra) # 80000584 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ba0:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ba4:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ba8:	00005517          	auipc	a0,0x5
    80002bac:	7f050513          	addi	a0,a0,2032 # 80008398 <states.0+0x110>
    80002bb0:	ffffe097          	auipc	ra,0xffffe
    80002bb4:	9d4080e7          	jalr	-1580(ra) # 80000584 <printf>
    p->killed = 1;
    80002bb8:	b77d                	j	80002b66 <usertrap+0x11e>
  if(p->killed)
    80002bba:	549c                	lw	a5,40(s1)
    80002bbc:	dfc5                	beqz	a5,80002b74 <usertrap+0x12c>
    80002bbe:	b775                	j	80002b6a <usertrap+0x122>
    80002bc0:	4901                	li	s2,0
    80002bc2:	b765                	j	80002b6a <usertrap+0x122>

0000000080002bc4 <kerneltrap>:
{
    80002bc4:	7179                	addi	sp,sp,-48
    80002bc6:	f406                	sd	ra,40(sp)
    80002bc8:	f022                	sd	s0,32(sp)
    80002bca:	ec26                	sd	s1,24(sp)
    80002bcc:	e84a                	sd	s2,16(sp)
    80002bce:	e44e                	sd	s3,8(sp)
    80002bd0:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bd2:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bd6:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bda:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002bde:	1004f793          	andi	a5,s1,256
    80002be2:	cb85                	beqz	a5,80002c12 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002be4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002be8:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002bea:	ef85                	bnez	a5,80002c22 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002bec:	00000097          	auipc	ra,0x0
    80002bf0:	dba080e7          	jalr	-582(ra) # 800029a6 <devintr>
    80002bf4:	cd1d                	beqz	a0,80002c32 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING){
    80002bf6:	4789                	li	a5,2
    80002bf8:	06f50a63          	beq	a0,a5,80002c6c <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002bfc:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c00:	10049073          	csrw	sstatus,s1
}
    80002c04:	70a2                	ld	ra,40(sp)
    80002c06:	7402                	ld	s0,32(sp)
    80002c08:	64e2                	ld	s1,24(sp)
    80002c0a:	6942                	ld	s2,16(sp)
    80002c0c:	69a2                	ld	s3,8(sp)
    80002c0e:	6145                	addi	sp,sp,48
    80002c10:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002c12:	00005517          	auipc	a0,0x5
    80002c16:	7a650513          	addi	a0,a0,1958 # 800083b8 <states.0+0x130>
    80002c1a:	ffffe097          	auipc	ra,0xffffe
    80002c1e:	920080e7          	jalr	-1760(ra) # 8000053a <panic>
    panic("kerneltrap: interrupts enabled");
    80002c22:	00005517          	auipc	a0,0x5
    80002c26:	7be50513          	addi	a0,a0,1982 # 800083e0 <states.0+0x158>
    80002c2a:	ffffe097          	auipc	ra,0xffffe
    80002c2e:	910080e7          	jalr	-1776(ra) # 8000053a <panic>
    printf("scause %p\n", scause);
    80002c32:	85ce                	mv	a1,s3
    80002c34:	00005517          	auipc	a0,0x5
    80002c38:	7cc50513          	addi	a0,a0,1996 # 80008400 <states.0+0x178>
    80002c3c:	ffffe097          	auipc	ra,0xffffe
    80002c40:	948080e7          	jalr	-1720(ra) # 80000584 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c44:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c48:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c4c:	00005517          	auipc	a0,0x5
    80002c50:	7c450513          	addi	a0,a0,1988 # 80008410 <states.0+0x188>
    80002c54:	ffffe097          	auipc	ra,0xffffe
    80002c58:	930080e7          	jalr	-1744(ra) # 80000584 <printf>
    panic("kerneltrap");
    80002c5c:	00005517          	auipc	a0,0x5
    80002c60:	7cc50513          	addi	a0,a0,1996 # 80008428 <states.0+0x1a0>
    80002c64:	ffffe097          	auipc	ra,0xffffe
    80002c68:	8d6080e7          	jalr	-1834(ra) # 8000053a <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING){
    80002c6c:	fffff097          	auipc	ra,0xfffff
    80002c70:	d5a080e7          	jalr	-678(ra) # 800019c6 <myproc>
    80002c74:	d541                	beqz	a0,80002bfc <kerneltrap+0x38>
    80002c76:	fffff097          	auipc	ra,0xfffff
    80002c7a:	d50080e7          	jalr	-688(ra) # 800019c6 <myproc>
    80002c7e:	4d58                	lw	a4,28(a0)
    80002c80:	4791                	li	a5,4
    80002c82:	f6f71de3          	bne	a4,a5,80002bfc <kerneltrap+0x38>
    myproc()->cputime++;
    80002c86:	fffff097          	auipc	ra,0xfffff
    80002c8a:	d40080e7          	jalr	-704(ra) # 800019c6 <myproc>
    80002c8e:	7d1c                	ld	a5,56(a0)
    80002c90:	0785                	addi	a5,a5,1
    80002c92:	fd1c                	sd	a5,56(a0)
    yield();
    80002c94:	fffff097          	auipc	ra,0xfffff
    80002c98:	402080e7          	jalr	1026(ra) # 80002096 <yield>
    80002c9c:	b785                	j	80002bfc <kerneltrap+0x38>

0000000080002c9e <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002c9e:	1101                	addi	sp,sp,-32
    80002ca0:	ec06                	sd	ra,24(sp)
    80002ca2:	e822                	sd	s0,16(sp)
    80002ca4:	e426                	sd	s1,8(sp)
    80002ca6:	1000                	addi	s0,sp,32
    80002ca8:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002caa:	fffff097          	auipc	ra,0xfffff
    80002cae:	d1c080e7          	jalr	-740(ra) # 800019c6 <myproc>
  switch (n) {
    80002cb2:	4795                	li	a5,5
    80002cb4:	0497e163          	bltu	a5,s1,80002cf6 <argraw+0x58>
    80002cb8:	048a                	slli	s1,s1,0x2
    80002cba:	00005717          	auipc	a4,0x5
    80002cbe:	7a670713          	addi	a4,a4,1958 # 80008460 <states.0+0x1d8>
    80002cc2:	94ba                	add	s1,s1,a4
    80002cc4:	409c                	lw	a5,0(s1)
    80002cc6:	97ba                	add	a5,a5,a4
    80002cc8:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002cca:	753c                	ld	a5,104(a0)
    80002ccc:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002cce:	60e2                	ld	ra,24(sp)
    80002cd0:	6442                	ld	s0,16(sp)
    80002cd2:	64a2                	ld	s1,8(sp)
    80002cd4:	6105                	addi	sp,sp,32
    80002cd6:	8082                	ret
    return p->trapframe->a1;
    80002cd8:	753c                	ld	a5,104(a0)
    80002cda:	7fa8                	ld	a0,120(a5)
    80002cdc:	bfcd                	j	80002cce <argraw+0x30>
    return p->trapframe->a2;
    80002cde:	753c                	ld	a5,104(a0)
    80002ce0:	63c8                	ld	a0,128(a5)
    80002ce2:	b7f5                	j	80002cce <argraw+0x30>
    return p->trapframe->a3;
    80002ce4:	753c                	ld	a5,104(a0)
    80002ce6:	67c8                	ld	a0,136(a5)
    80002ce8:	b7dd                	j	80002cce <argraw+0x30>
    return p->trapframe->a4;
    80002cea:	753c                	ld	a5,104(a0)
    80002cec:	6bc8                	ld	a0,144(a5)
    80002cee:	b7c5                	j	80002cce <argraw+0x30>
    return p->trapframe->a5;
    80002cf0:	753c                	ld	a5,104(a0)
    80002cf2:	6fc8                	ld	a0,152(a5)
    80002cf4:	bfe9                	j	80002cce <argraw+0x30>
  panic("argraw");
    80002cf6:	00005517          	auipc	a0,0x5
    80002cfa:	74250513          	addi	a0,a0,1858 # 80008438 <states.0+0x1b0>
    80002cfe:	ffffe097          	auipc	ra,0xffffe
    80002d02:	83c080e7          	jalr	-1988(ra) # 8000053a <panic>

0000000080002d06 <fetchaddr>:
{
    80002d06:	1101                	addi	sp,sp,-32
    80002d08:	ec06                	sd	ra,24(sp)
    80002d0a:	e822                	sd	s0,16(sp)
    80002d0c:	e426                	sd	s1,8(sp)
    80002d0e:	e04a                	sd	s2,0(sp)
    80002d10:	1000                	addi	s0,sp,32
    80002d12:	84aa                	mv	s1,a0
    80002d14:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d16:	fffff097          	auipc	ra,0xfffff
    80002d1a:	cb0080e7          	jalr	-848(ra) # 800019c6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002d1e:	6d3c                	ld	a5,88(a0)
    80002d20:	02f4f863          	bgeu	s1,a5,80002d50 <fetchaddr+0x4a>
    80002d24:	00848713          	addi	a4,s1,8
    80002d28:	02e7e663          	bltu	a5,a4,80002d54 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002d2c:	46a1                	li	a3,8
    80002d2e:	8626                	mv	a2,s1
    80002d30:	85ca                	mv	a1,s2
    80002d32:	7128                	ld	a0,96(a0)
    80002d34:	fffff097          	auipc	ra,0xfffff
    80002d38:	9e2080e7          	jalr	-1566(ra) # 80001716 <copyin>
    80002d3c:	00a03533          	snez	a0,a0
    80002d40:	40a00533          	neg	a0,a0
}
    80002d44:	60e2                	ld	ra,24(sp)
    80002d46:	6442                	ld	s0,16(sp)
    80002d48:	64a2                	ld	s1,8(sp)
    80002d4a:	6902                	ld	s2,0(sp)
    80002d4c:	6105                	addi	sp,sp,32
    80002d4e:	8082                	ret
    return -1;
    80002d50:	557d                	li	a0,-1
    80002d52:	bfcd                	j	80002d44 <fetchaddr+0x3e>
    80002d54:	557d                	li	a0,-1
    80002d56:	b7fd                	j	80002d44 <fetchaddr+0x3e>

0000000080002d58 <fetchstr>:
{
    80002d58:	7179                	addi	sp,sp,-48
    80002d5a:	f406                	sd	ra,40(sp)
    80002d5c:	f022                	sd	s0,32(sp)
    80002d5e:	ec26                	sd	s1,24(sp)
    80002d60:	e84a                	sd	s2,16(sp)
    80002d62:	e44e                	sd	s3,8(sp)
    80002d64:	1800                	addi	s0,sp,48
    80002d66:	892a                	mv	s2,a0
    80002d68:	84ae                	mv	s1,a1
    80002d6a:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002d6c:	fffff097          	auipc	ra,0xfffff
    80002d70:	c5a080e7          	jalr	-934(ra) # 800019c6 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002d74:	86ce                	mv	a3,s3
    80002d76:	864a                	mv	a2,s2
    80002d78:	85a6                	mv	a1,s1
    80002d7a:	7128                	ld	a0,96(a0)
    80002d7c:	fffff097          	auipc	ra,0xfffff
    80002d80:	a28080e7          	jalr	-1496(ra) # 800017a4 <copyinstr>
  if(err < 0)
    80002d84:	00054763          	bltz	a0,80002d92 <fetchstr+0x3a>
  return strlen(buf);
    80002d88:	8526                	mv	a0,s1
    80002d8a:	ffffe097          	auipc	ra,0xffffe
    80002d8e:	108080e7          	jalr	264(ra) # 80000e92 <strlen>
}
    80002d92:	70a2                	ld	ra,40(sp)
    80002d94:	7402                	ld	s0,32(sp)
    80002d96:	64e2                	ld	s1,24(sp)
    80002d98:	6942                	ld	s2,16(sp)
    80002d9a:	69a2                	ld	s3,8(sp)
    80002d9c:	6145                	addi	sp,sp,48
    80002d9e:	8082                	ret

0000000080002da0 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002da0:	1101                	addi	sp,sp,-32
    80002da2:	ec06                	sd	ra,24(sp)
    80002da4:	e822                	sd	s0,16(sp)
    80002da6:	e426                	sd	s1,8(sp)
    80002da8:	1000                	addi	s0,sp,32
    80002daa:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002dac:	00000097          	auipc	ra,0x0
    80002db0:	ef2080e7          	jalr	-270(ra) # 80002c9e <argraw>
    80002db4:	c088                	sw	a0,0(s1)
  return 0;
}
    80002db6:	4501                	li	a0,0
    80002db8:	60e2                	ld	ra,24(sp)
    80002dba:	6442                	ld	s0,16(sp)
    80002dbc:	64a2                	ld	s1,8(sp)
    80002dbe:	6105                	addi	sp,sp,32
    80002dc0:	8082                	ret

0000000080002dc2 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002dc2:	1101                	addi	sp,sp,-32
    80002dc4:	ec06                	sd	ra,24(sp)
    80002dc6:	e822                	sd	s0,16(sp)
    80002dc8:	e426                	sd	s1,8(sp)
    80002dca:	1000                	addi	s0,sp,32
    80002dcc:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002dce:	00000097          	auipc	ra,0x0
    80002dd2:	ed0080e7          	jalr	-304(ra) # 80002c9e <argraw>
    80002dd6:	e088                	sd	a0,0(s1)
  return 0;
}
    80002dd8:	4501                	li	a0,0
    80002dda:	60e2                	ld	ra,24(sp)
    80002ddc:	6442                	ld	s0,16(sp)
    80002dde:	64a2                	ld	s1,8(sp)
    80002de0:	6105                	addi	sp,sp,32
    80002de2:	8082                	ret

0000000080002de4 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002de4:	1101                	addi	sp,sp,-32
    80002de6:	ec06                	sd	ra,24(sp)
    80002de8:	e822                	sd	s0,16(sp)
    80002dea:	e426                	sd	s1,8(sp)
    80002dec:	e04a                	sd	s2,0(sp)
    80002dee:	1000                	addi	s0,sp,32
    80002df0:	84ae                	mv	s1,a1
    80002df2:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002df4:	00000097          	auipc	ra,0x0
    80002df8:	eaa080e7          	jalr	-342(ra) # 80002c9e <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002dfc:	864a                	mv	a2,s2
    80002dfe:	85a6                	mv	a1,s1
    80002e00:	00000097          	auipc	ra,0x0
    80002e04:	f58080e7          	jalr	-168(ra) # 80002d58 <fetchstr>
}
    80002e08:	60e2                	ld	ra,24(sp)
    80002e0a:	6442                	ld	s0,16(sp)
    80002e0c:	64a2                	ld	s1,8(sp)
    80002e0e:	6902                	ld	s2,0(sp)
    80002e10:	6105                	addi	sp,sp,32
    80002e12:	8082                	ret

0000000080002e14 <syscall>:
[SYS_memuser]	sys_memuser,
};

void
syscall(void)
{
    80002e14:	1101                	addi	sp,sp,-32
    80002e16:	ec06                	sd	ra,24(sp)
    80002e18:	e822                	sd	s0,16(sp)
    80002e1a:	e426                	sd	s1,8(sp)
    80002e1c:	e04a                	sd	s2,0(sp)
    80002e1e:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002e20:	fffff097          	auipc	ra,0xfffff
    80002e24:	ba6080e7          	jalr	-1114(ra) # 800019c6 <myproc>
    80002e28:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002e2a:	06853903          	ld	s2,104(a0)
    80002e2e:	0a893783          	ld	a5,168(s2)
    80002e32:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002e36:	37fd                	addiw	a5,a5,-1
    80002e38:	4769                	li	a4,26
    80002e3a:	00f76f63          	bltu	a4,a5,80002e58 <syscall+0x44>
    80002e3e:	00369713          	slli	a4,a3,0x3
    80002e42:	00005797          	auipc	a5,0x5
    80002e46:	63678793          	addi	a5,a5,1590 # 80008478 <syscalls>
    80002e4a:	97ba                	add	a5,a5,a4
    80002e4c:	639c                	ld	a5,0(a5)
    80002e4e:	c789                	beqz	a5,80002e58 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002e50:	9782                	jalr	a5
    80002e52:	06a93823          	sd	a0,112(s2)
    80002e56:	a839                	j	80002e74 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002e58:	16848613          	addi	a2,s1,360
    80002e5c:	588c                	lw	a1,48(s1)
    80002e5e:	00005517          	auipc	a0,0x5
    80002e62:	5e250513          	addi	a0,a0,1506 # 80008440 <states.0+0x1b8>
    80002e66:	ffffd097          	auipc	ra,0xffffd
    80002e6a:	71e080e7          	jalr	1822(ra) # 80000584 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002e6e:	74bc                	ld	a5,104(s1)
    80002e70:	577d                	li	a4,-1
    80002e72:	fbb8                	sd	a4,112(a5)
  }
}
    80002e74:	60e2                	ld	ra,24(sp)
    80002e76:	6442                	ld	s0,16(sp)
    80002e78:	64a2                	ld	s1,8(sp)
    80002e7a:	6902                	ld	s2,0(sp)
    80002e7c:	6105                	addi	sp,sp,32
    80002e7e:	8082                	ret

0000000080002e80 <sys_exit>:

uint64 freepmem(void);

uint64
sys_exit(void)
{
    80002e80:	1101                	addi	sp,sp,-32
    80002e82:	ec06                	sd	ra,24(sp)
    80002e84:	e822                	sd	s0,16(sp)
    80002e86:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002e88:	fec40593          	addi	a1,s0,-20
    80002e8c:	4501                	li	a0,0
    80002e8e:	00000097          	auipc	ra,0x0
    80002e92:	f12080e7          	jalr	-238(ra) # 80002da0 <argint>
    return -1;
    80002e96:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002e98:	00054963          	bltz	a0,80002eaa <sys_exit+0x2a>
  exit(n);
    80002e9c:	fec42503          	lw	a0,-20(s0)
    80002ea0:	fffff097          	auipc	ra,0xfffff
    80002ea4:	498080e7          	jalr	1176(ra) # 80002338 <exit>
  return 0;  // not reached
    80002ea8:	4781                	li	a5,0
}
    80002eaa:	853e                	mv	a0,a5
    80002eac:	60e2                	ld	ra,24(sp)
    80002eae:	6442                	ld	s0,16(sp)
    80002eb0:	6105                	addi	sp,sp,32
    80002eb2:	8082                	ret

0000000080002eb4 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002eb4:	1141                	addi	sp,sp,-16
    80002eb6:	e406                	sd	ra,8(sp)
    80002eb8:	e022                	sd	s0,0(sp)
    80002eba:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002ebc:	fffff097          	auipc	ra,0xfffff
    80002ec0:	b0a080e7          	jalr	-1270(ra) # 800019c6 <myproc>
}
    80002ec4:	5908                	lw	a0,48(a0)
    80002ec6:	60a2                	ld	ra,8(sp)
    80002ec8:	6402                	ld	s0,0(sp)
    80002eca:	0141                	addi	sp,sp,16
    80002ecc:	8082                	ret

0000000080002ece <sys_fork>:

uint64
sys_fork(void)
{
    80002ece:	1141                	addi	sp,sp,-16
    80002ed0:	e406                	sd	ra,8(sp)
    80002ed2:	e022                	sd	s0,0(sp)
    80002ed4:	0800                	addi	s0,sp,16
  return fork();
    80002ed6:	fffff097          	auipc	ra,0xfffff
    80002eda:	ec6080e7          	jalr	-314(ra) # 80001d9c <fork>
}
    80002ede:	60a2                	ld	ra,8(sp)
    80002ee0:	6402                	ld	s0,0(sp)
    80002ee2:	0141                	addi	sp,sp,16
    80002ee4:	8082                	ret

0000000080002ee6 <sys_wait>:

uint64
sys_wait(void)
{
    80002ee6:	1101                	addi	sp,sp,-32
    80002ee8:	ec06                	sd	ra,24(sp)
    80002eea:	e822                	sd	s0,16(sp)
    80002eec:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002eee:	fe840593          	addi	a1,s0,-24
    80002ef2:	4501                	li	a0,0
    80002ef4:	00000097          	auipc	ra,0x0
    80002ef8:	ece080e7          	jalr	-306(ra) # 80002dc2 <argaddr>
    80002efc:	87aa                	mv	a5,a0
    return -1;
    80002efe:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002f00:	0007c863          	bltz	a5,80002f10 <sys_wait+0x2a>
  return wait(p);
    80002f04:	fe843503          	ld	a0,-24(s0)
    80002f08:	fffff097          	auipc	ra,0xfffff
    80002f0c:	22e080e7          	jalr	558(ra) # 80002136 <wait>
}
    80002f10:	60e2                	ld	ra,24(sp)
    80002f12:	6442                	ld	s0,16(sp)
    80002f14:	6105                	addi	sp,sp,32
    80002f16:	8082                	ret

0000000080002f18 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002f18:	7179                	addi	sp,sp,-48
    80002f1a:	f406                	sd	ra,40(sp)
    80002f1c:	f022                	sd	s0,32(sp)
    80002f1e:	ec26                	sd	s1,24(sp)
    80002f20:	e84a                	sd	s2,16(sp)
    80002f22:	1800                	addi	s0,sp,48
  int addr;
  int n;
  int new_size;

  if(argint(0, &n) < 0){
    80002f24:	fdc40593          	addi	a1,s0,-36
    80002f28:	4501                	li	a0,0
    80002f2a:	00000097          	auipc	ra,0x0
    80002f2e:	e76080e7          	jalr	-394(ra) # 80002da0 <argint>
    80002f32:	87aa                	mv	a5,a0
    return -1;
    80002f34:	557d                	li	a0,-1
  if(argint(0, &n) < 0){
    80002f36:	0207c263          	bltz	a5,80002f5a <sys_sbrk+0x42>
  }
  addr = myproc()->sz;
    80002f3a:	fffff097          	auipc	ra,0xfffff
    80002f3e:	a8c080e7          	jalr	-1396(ra) # 800019c6 <myproc>
    80002f42:	4d24                	lw	s1,88(a0)
  new_size = addr + n;
    80002f44:	fdc42903          	lw	s2,-36(s0)
    80002f48:	0099093b          	addw	s2,s2,s1
  
  if(new_size < TRAPFRAME){
  	myproc() -> sz = new_size;
    80002f4c:	fffff097          	auipc	ra,0xfffff
    80002f50:	a7a080e7          	jalr	-1414(ra) # 800019c6 <myproc>
    80002f54:	05253c23          	sd	s2,88(a0)
  	return addr;
    80002f58:	8526                	mv	a0,s1
  }
  
  return -1;
}
    80002f5a:	70a2                	ld	ra,40(sp)
    80002f5c:	7402                	ld	s0,32(sp)
    80002f5e:	64e2                	ld	s1,24(sp)
    80002f60:	6942                	ld	s2,16(sp)
    80002f62:	6145                	addi	sp,sp,48
    80002f64:	8082                	ret

0000000080002f66 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002f66:	7139                	addi	sp,sp,-64
    80002f68:	fc06                	sd	ra,56(sp)
    80002f6a:	f822                	sd	s0,48(sp)
    80002f6c:	f426                	sd	s1,40(sp)
    80002f6e:	f04a                	sd	s2,32(sp)
    80002f70:	ec4e                	sd	s3,24(sp)
    80002f72:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002f74:	fcc40593          	addi	a1,s0,-52
    80002f78:	4501                	li	a0,0
    80002f7a:	00000097          	auipc	ra,0x0
    80002f7e:	e26080e7          	jalr	-474(ra) # 80002da0 <argint>
    return -1;
    80002f82:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002f84:	06054563          	bltz	a0,80002fee <sys_sleep+0x88>
  acquire(&tickslock);
    80002f88:	00014517          	auipc	a0,0x14
    80002f8c:	54850513          	addi	a0,a0,1352 # 800174d0 <tickslock>
    80002f90:	ffffe097          	auipc	ra,0xffffe
    80002f94:	c8a080e7          	jalr	-886(ra) # 80000c1a <acquire>
  ticks0 = ticks;
    80002f98:	00006917          	auipc	s2,0x6
    80002f9c:	09892903          	lw	s2,152(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    80002fa0:	fcc42783          	lw	a5,-52(s0)
    80002fa4:	cf85                	beqz	a5,80002fdc <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002fa6:	00014997          	auipc	s3,0x14
    80002faa:	52a98993          	addi	s3,s3,1322 # 800174d0 <tickslock>
    80002fae:	00006497          	auipc	s1,0x6
    80002fb2:	08248493          	addi	s1,s1,130 # 80009030 <ticks>
    if(myproc()->killed){
    80002fb6:	fffff097          	auipc	ra,0xfffff
    80002fba:	a10080e7          	jalr	-1520(ra) # 800019c6 <myproc>
    80002fbe:	551c                	lw	a5,40(a0)
    80002fc0:	ef9d                	bnez	a5,80002ffe <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002fc2:	85ce                	mv	a1,s3
    80002fc4:	8526                	mv	a0,s1
    80002fc6:	fffff097          	auipc	ra,0xfffff
    80002fca:	10c080e7          	jalr	268(ra) # 800020d2 <sleep>
  while(ticks - ticks0 < n){
    80002fce:	409c                	lw	a5,0(s1)
    80002fd0:	412787bb          	subw	a5,a5,s2
    80002fd4:	fcc42703          	lw	a4,-52(s0)
    80002fd8:	fce7efe3          	bltu	a5,a4,80002fb6 <sys_sleep+0x50>
  }
  release(&tickslock);
    80002fdc:	00014517          	auipc	a0,0x14
    80002fe0:	4f450513          	addi	a0,a0,1268 # 800174d0 <tickslock>
    80002fe4:	ffffe097          	auipc	ra,0xffffe
    80002fe8:	cea080e7          	jalr	-790(ra) # 80000cce <release>
  return 0;
    80002fec:	4781                	li	a5,0
}
    80002fee:	853e                	mv	a0,a5
    80002ff0:	70e2                	ld	ra,56(sp)
    80002ff2:	7442                	ld	s0,48(sp)
    80002ff4:	74a2                	ld	s1,40(sp)
    80002ff6:	7902                	ld	s2,32(sp)
    80002ff8:	69e2                	ld	s3,24(sp)
    80002ffa:	6121                	addi	sp,sp,64
    80002ffc:	8082                	ret
      release(&tickslock);
    80002ffe:	00014517          	auipc	a0,0x14
    80003002:	4d250513          	addi	a0,a0,1234 # 800174d0 <tickslock>
    80003006:	ffffe097          	auipc	ra,0xffffe
    8000300a:	cc8080e7          	jalr	-824(ra) # 80000cce <release>
      return -1;
    8000300e:	57fd                	li	a5,-1
    80003010:	bff9                	j	80002fee <sys_sleep+0x88>

0000000080003012 <sys_kill>:

uint64
sys_kill(void)
{
    80003012:	1101                	addi	sp,sp,-32
    80003014:	ec06                	sd	ra,24(sp)
    80003016:	e822                	sd	s0,16(sp)
    80003018:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    8000301a:	fec40593          	addi	a1,s0,-20
    8000301e:	4501                	li	a0,0
    80003020:	00000097          	auipc	ra,0x0
    80003024:	d80080e7          	jalr	-640(ra) # 80002da0 <argint>
    80003028:	87aa                	mv	a5,a0
    return -1;
    8000302a:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    8000302c:	0007c863          	bltz	a5,8000303c <sys_kill+0x2a>
  return kill(pid);
    80003030:	fec42503          	lw	a0,-20(s0)
    80003034:	fffff097          	auipc	ra,0xfffff
    80003038:	3da080e7          	jalr	986(ra) # 8000240e <kill>
}
    8000303c:	60e2                	ld	ra,24(sp)
    8000303e:	6442                	ld	s0,16(sp)
    80003040:	6105                	addi	sp,sp,32
    80003042:	8082                	ret

0000000080003044 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003044:	1101                	addi	sp,sp,-32
    80003046:	ec06                	sd	ra,24(sp)
    80003048:	e822                	sd	s0,16(sp)
    8000304a:	e426                	sd	s1,8(sp)
    8000304c:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000304e:	00014517          	auipc	a0,0x14
    80003052:	48250513          	addi	a0,a0,1154 # 800174d0 <tickslock>
    80003056:	ffffe097          	auipc	ra,0xffffe
    8000305a:	bc4080e7          	jalr	-1084(ra) # 80000c1a <acquire>
  xticks = ticks;
    8000305e:	00006497          	auipc	s1,0x6
    80003062:	fd24a483          	lw	s1,-46(s1) # 80009030 <ticks>
  release(&tickslock);
    80003066:	00014517          	auipc	a0,0x14
    8000306a:	46a50513          	addi	a0,a0,1130 # 800174d0 <tickslock>
    8000306e:	ffffe097          	auipc	ra,0xffffe
    80003072:	c60080e7          	jalr	-928(ra) # 80000cce <release>
  return xticks;
}
    80003076:	02049513          	slli	a0,s1,0x20
    8000307a:	9101                	srli	a0,a0,0x20
    8000307c:	60e2                	ld	ra,24(sp)
    8000307e:	6442                	ld	s0,16(sp)
    80003080:	64a2                	ld	s1,8(sp)
    80003082:	6105                	addi	sp,sp,32
    80003084:	8082                	ret

0000000080003086 <sys_getprocs>:

// return the number of active processes in the system
// fill in user-provided data structure with pid,state,sz,ppid,name
uint64
sys_getprocs(void)
{
    80003086:	1101                	addi	sp,sp,-32
    80003088:	ec06                	sd	ra,24(sp)
    8000308a:	e822                	sd	s0,16(sp)
    8000308c:	1000                	addi	s0,sp,32
  uint64 addr;  // user pointer to struct pstat
  //struct proc *p;  //create a pointer to struct proc
  
  //checks if address of first argument (index 0) passed to system call and be retrieved
  //by argaddr function
  if (argaddr(0, &addr) < 0){
    8000308e:	fe840593          	addi	a1,s0,-24
    80003092:	4501                	li	a0,0
    80003094:	00000097          	auipc	ra,0x0
    80003098:	d2e080e7          	jalr	-722(ra) # 80002dc2 <argaddr>
    8000309c:	87aa                	mv	a5,a0
    return -1;
    8000309e:	557d                	li	a0,-1
  if (argaddr(0, &addr) < 0){
    800030a0:	0007c863          	bltz	a5,800030b0 <sys_getprocs+0x2a>
  }
  
  return(procinfo(addr));
    800030a4:	fe843503          	ld	a0,-24(s0)
    800030a8:	fffff097          	auipc	ra,0xfffff
    800030ac:	534080e7          	jalr	1332(ra) # 800025dc <procinfo>
}
    800030b0:	60e2                	ld	ra,24(sp)
    800030b2:	6442                	ld	s0,16(sp)
    800030b4:	6105                	addi	sp,sp,32
    800030b6:	8082                	ret

00000000800030b8 <sys_wait2>:

// sys_wait2
uint64
sys_wait2(void)
{
    800030b8:	1101                	addi	sp,sp,-32
    800030ba:	ec06                	sd	ra,24(sp)
    800030bc:	e822                	sd	s0,16(sp)
    800030be:	1000                	addi	s0,sp,32
  uint64 p;
  uint64 p2;
  
  if(argaddr(0, &p) < 0){
    800030c0:	fe840593          	addi	a1,s0,-24
    800030c4:	4501                	li	a0,0
    800030c6:	00000097          	auipc	ra,0x0
    800030ca:	cfc080e7          	jalr	-772(ra) # 80002dc2 <argaddr>
    return -1;
    800030ce:	57fd                	li	a5,-1
  if(argaddr(0, &p) < 0){
    800030d0:	02054563          	bltz	a0,800030fa <sys_wait2+0x42>
  }
  
  if(argaddr(1, &p2) < 0){
    800030d4:	fe040593          	addi	a1,s0,-32
    800030d8:	4505                	li	a0,1
    800030da:	00000097          	auipc	ra,0x0
    800030de:	ce8080e7          	jalr	-792(ra) # 80002dc2 <argaddr>
    return -1;
    800030e2:	57fd                	li	a5,-1
  if(argaddr(1, &p2) < 0){
    800030e4:	00054b63          	bltz	a0,800030fa <sys_wait2+0x42>
  }
  
  return wait2(p, p2);
    800030e8:	fe043583          	ld	a1,-32(s0)
    800030ec:	fe843503          	ld	a0,-24(s0)
    800030f0:	fffff097          	auipc	ra,0xfffff
    800030f4:	5ba080e7          	jalr	1466(ra) # 800026aa <wait2>
    800030f8:	87aa                	mv	a5,a0
  
}
    800030fa:	853e                	mv	a0,a5
    800030fc:	60e2                	ld	ra,24(sp)
    800030fe:	6442                	ld	s0,16(sp)
    80003100:	6105                	addi	sp,sp,32
    80003102:	8082                	ret

0000000080003104 <sys_getpriority>:

// sys_getprocs
uint64
sys_getpriority(void){
    80003104:	1141                	addi	sp,sp,-16
    80003106:	e406                	sd	ra,8(sp)
    80003108:	e022                	sd	s0,0(sp)
    8000310a:	0800                	addi	s0,sp,16
	return myproc()->priority;
    8000310c:	fffff097          	auipc	ra,0xfffff
    80003110:	8ba080e7          	jalr	-1862(ra) # 800019c6 <myproc>
}
    80003114:	4d08                	lw	a0,24(a0)
    80003116:	60a2                	ld	ra,8(sp)
    80003118:	6402                	ld	s0,0(sp)
    8000311a:	0141                	addi	sp,sp,16
    8000311c:	8082                	ret

000000008000311e <sys_setpriority>:

// sys_setprocs
uint64
sys_setpriority(void){
    8000311e:	1101                	addi	sp,sp,-32
    80003120:	ec06                	sd	ra,24(sp)
    80003122:	e822                	sd	s0,16(sp)
    80003124:	1000                	addi	s0,sp,32
	int priority;
	if(argint(0, &priority) < 0){
    80003126:	fec40593          	addi	a1,s0,-20
    8000312a:	4501                	li	a0,0
    8000312c:	00000097          	auipc	ra,0x0
    80003130:	c74080e7          	jalr	-908(ra) # 80002da0 <argint>
		return -1;
    80003134:	57fd                	li	a5,-1
	if(argint(0, &priority) < 0){
    80003136:	00054a63          	bltz	a0,8000314a <sys_setpriority+0x2c>
	}
	//if(priority->MAXEFPRIORITY){
	//	return -1;
	//}
	
	myproc()->priority = priority;
    8000313a:	fffff097          	auipc	ra,0xfffff
    8000313e:	88c080e7          	jalr	-1908(ra) # 800019c6 <myproc>
    80003142:	fec42783          	lw	a5,-20(s0)
    80003146:	cd1c                	sw	a5,24(a0)
	return 0;
    80003148:	4781                	li	a5,0
}
    8000314a:	853e                	mv	a0,a5
    8000314c:	60e2                	ld	ra,24(sp)
    8000314e:	6442                	ld	s0,16(sp)
    80003150:	6105                	addi	sp,sp,32
    80003152:	8082                	ret

0000000080003154 <sys_freepmem>:

uint64
sys_freepmem(void)
{
    80003154:	1141                	addi	sp,sp,-16
    80003156:	e406                	sd	ra,8(sp)
    80003158:	e022                	sd	s0,0(sp)
    8000315a:	0800                	addi	s0,sp,16
	int res = freepmem();
    8000315c:	ffffe097          	auipc	ra,0xffffe
    80003160:	9e4080e7          	jalr	-1564(ra) # 80000b40 <freepmem>
	return res;
}
    80003164:	2501                	sext.w	a0,a0
    80003166:	60a2                	ld	ra,8(sp)
    80003168:	6402                	ld	s0,0(sp)
    8000316a:	0141                	addi	sp,sp,16
    8000316c:	8082                	ret

000000008000316e <sys_memuser>:

uint64
sys_memuser(void)
{
    8000316e:	1141                	addi	sp,sp,-16
    80003170:	e406                	sd	ra,8(sp)
    80003172:	e022                	sd	s0,0(sp)
    80003174:	0800                	addi	s0,sp,16
	int res = freepmem();
    80003176:	ffffe097          	auipc	ra,0xffffe
    8000317a:	9ca080e7          	jalr	-1590(ra) # 80000b40 <freepmem>
	return res;
}
    8000317e:	2501                	sext.w	a0,a0
    80003180:	60a2                	ld	ra,8(sp)
    80003182:	6402                	ld	s0,0(sp)
    80003184:	0141                	addi	sp,sp,16
    80003186:	8082                	ret

0000000080003188 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003188:	7179                	addi	sp,sp,-48
    8000318a:	f406                	sd	ra,40(sp)
    8000318c:	f022                	sd	s0,32(sp)
    8000318e:	ec26                	sd	s1,24(sp)
    80003190:	e84a                	sd	s2,16(sp)
    80003192:	e44e                	sd	s3,8(sp)
    80003194:	e052                	sd	s4,0(sp)
    80003196:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003198:	00005597          	auipc	a1,0x5
    8000319c:	3c058593          	addi	a1,a1,960 # 80008558 <syscalls+0xe0>
    800031a0:	00014517          	auipc	a0,0x14
    800031a4:	34850513          	addi	a0,a0,840 # 800174e8 <bcache>
    800031a8:	ffffe097          	auipc	ra,0xffffe
    800031ac:	9e2080e7          	jalr	-1566(ra) # 80000b8a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800031b0:	0001c797          	auipc	a5,0x1c
    800031b4:	33878793          	addi	a5,a5,824 # 8001f4e8 <bcache+0x8000>
    800031b8:	0001c717          	auipc	a4,0x1c
    800031bc:	59870713          	addi	a4,a4,1432 # 8001f750 <bcache+0x8268>
    800031c0:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800031c4:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800031c8:	00014497          	auipc	s1,0x14
    800031cc:	33848493          	addi	s1,s1,824 # 80017500 <bcache+0x18>
    b->next = bcache.head.next;
    800031d0:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800031d2:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800031d4:	00005a17          	auipc	s4,0x5
    800031d8:	38ca0a13          	addi	s4,s4,908 # 80008560 <syscalls+0xe8>
    b->next = bcache.head.next;
    800031dc:	2b893783          	ld	a5,696(s2)
    800031e0:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800031e2:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800031e6:	85d2                	mv	a1,s4
    800031e8:	01048513          	addi	a0,s1,16
    800031ec:	00001097          	auipc	ra,0x1
    800031f0:	4c2080e7          	jalr	1218(ra) # 800046ae <initsleeplock>
    bcache.head.next->prev = b;
    800031f4:	2b893783          	ld	a5,696(s2)
    800031f8:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800031fa:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800031fe:	45848493          	addi	s1,s1,1112
    80003202:	fd349de3          	bne	s1,s3,800031dc <binit+0x54>
  }
}
    80003206:	70a2                	ld	ra,40(sp)
    80003208:	7402                	ld	s0,32(sp)
    8000320a:	64e2                	ld	s1,24(sp)
    8000320c:	6942                	ld	s2,16(sp)
    8000320e:	69a2                	ld	s3,8(sp)
    80003210:	6a02                	ld	s4,0(sp)
    80003212:	6145                	addi	sp,sp,48
    80003214:	8082                	ret

0000000080003216 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003216:	7179                	addi	sp,sp,-48
    80003218:	f406                	sd	ra,40(sp)
    8000321a:	f022                	sd	s0,32(sp)
    8000321c:	ec26                	sd	s1,24(sp)
    8000321e:	e84a                	sd	s2,16(sp)
    80003220:	e44e                	sd	s3,8(sp)
    80003222:	1800                	addi	s0,sp,48
    80003224:	892a                	mv	s2,a0
    80003226:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003228:	00014517          	auipc	a0,0x14
    8000322c:	2c050513          	addi	a0,a0,704 # 800174e8 <bcache>
    80003230:	ffffe097          	auipc	ra,0xffffe
    80003234:	9ea080e7          	jalr	-1558(ra) # 80000c1a <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003238:	0001c497          	auipc	s1,0x1c
    8000323c:	5684b483          	ld	s1,1384(s1) # 8001f7a0 <bcache+0x82b8>
    80003240:	0001c797          	auipc	a5,0x1c
    80003244:	51078793          	addi	a5,a5,1296 # 8001f750 <bcache+0x8268>
    80003248:	02f48f63          	beq	s1,a5,80003286 <bread+0x70>
    8000324c:	873e                	mv	a4,a5
    8000324e:	a021                	j	80003256 <bread+0x40>
    80003250:	68a4                	ld	s1,80(s1)
    80003252:	02e48a63          	beq	s1,a4,80003286 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003256:	449c                	lw	a5,8(s1)
    80003258:	ff279ce3          	bne	a5,s2,80003250 <bread+0x3a>
    8000325c:	44dc                	lw	a5,12(s1)
    8000325e:	ff3799e3          	bne	a5,s3,80003250 <bread+0x3a>
      b->refcnt++;
    80003262:	40bc                	lw	a5,64(s1)
    80003264:	2785                	addiw	a5,a5,1
    80003266:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003268:	00014517          	auipc	a0,0x14
    8000326c:	28050513          	addi	a0,a0,640 # 800174e8 <bcache>
    80003270:	ffffe097          	auipc	ra,0xffffe
    80003274:	a5e080e7          	jalr	-1442(ra) # 80000cce <release>
      acquiresleep(&b->lock);
    80003278:	01048513          	addi	a0,s1,16
    8000327c:	00001097          	auipc	ra,0x1
    80003280:	46c080e7          	jalr	1132(ra) # 800046e8 <acquiresleep>
      return b;
    80003284:	a8b9                	j	800032e2 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003286:	0001c497          	auipc	s1,0x1c
    8000328a:	5124b483          	ld	s1,1298(s1) # 8001f798 <bcache+0x82b0>
    8000328e:	0001c797          	auipc	a5,0x1c
    80003292:	4c278793          	addi	a5,a5,1218 # 8001f750 <bcache+0x8268>
    80003296:	00f48863          	beq	s1,a5,800032a6 <bread+0x90>
    8000329a:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000329c:	40bc                	lw	a5,64(s1)
    8000329e:	cf81                	beqz	a5,800032b6 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800032a0:	64a4                	ld	s1,72(s1)
    800032a2:	fee49de3          	bne	s1,a4,8000329c <bread+0x86>
  panic("bget: no buffers");
    800032a6:	00005517          	auipc	a0,0x5
    800032aa:	2c250513          	addi	a0,a0,706 # 80008568 <syscalls+0xf0>
    800032ae:	ffffd097          	auipc	ra,0xffffd
    800032b2:	28c080e7          	jalr	652(ra) # 8000053a <panic>
      b->dev = dev;
    800032b6:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800032ba:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800032be:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800032c2:	4785                	li	a5,1
    800032c4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800032c6:	00014517          	auipc	a0,0x14
    800032ca:	22250513          	addi	a0,a0,546 # 800174e8 <bcache>
    800032ce:	ffffe097          	auipc	ra,0xffffe
    800032d2:	a00080e7          	jalr	-1536(ra) # 80000cce <release>
      acquiresleep(&b->lock);
    800032d6:	01048513          	addi	a0,s1,16
    800032da:	00001097          	auipc	ra,0x1
    800032de:	40e080e7          	jalr	1038(ra) # 800046e8 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800032e2:	409c                	lw	a5,0(s1)
    800032e4:	cb89                	beqz	a5,800032f6 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800032e6:	8526                	mv	a0,s1
    800032e8:	70a2                	ld	ra,40(sp)
    800032ea:	7402                	ld	s0,32(sp)
    800032ec:	64e2                	ld	s1,24(sp)
    800032ee:	6942                	ld	s2,16(sp)
    800032f0:	69a2                	ld	s3,8(sp)
    800032f2:	6145                	addi	sp,sp,48
    800032f4:	8082                	ret
    virtio_disk_rw(b, 0);
    800032f6:	4581                	li	a1,0
    800032f8:	8526                	mv	a0,s1
    800032fa:	00003097          	auipc	ra,0x3
    800032fe:	f28080e7          	jalr	-216(ra) # 80006222 <virtio_disk_rw>
    b->valid = 1;
    80003302:	4785                	li	a5,1
    80003304:	c09c                	sw	a5,0(s1)
  return b;
    80003306:	b7c5                	j	800032e6 <bread+0xd0>

0000000080003308 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003308:	1101                	addi	sp,sp,-32
    8000330a:	ec06                	sd	ra,24(sp)
    8000330c:	e822                	sd	s0,16(sp)
    8000330e:	e426                	sd	s1,8(sp)
    80003310:	1000                	addi	s0,sp,32
    80003312:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003314:	0541                	addi	a0,a0,16
    80003316:	00001097          	auipc	ra,0x1
    8000331a:	46c080e7          	jalr	1132(ra) # 80004782 <holdingsleep>
    8000331e:	cd01                	beqz	a0,80003336 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003320:	4585                	li	a1,1
    80003322:	8526                	mv	a0,s1
    80003324:	00003097          	auipc	ra,0x3
    80003328:	efe080e7          	jalr	-258(ra) # 80006222 <virtio_disk_rw>
}
    8000332c:	60e2                	ld	ra,24(sp)
    8000332e:	6442                	ld	s0,16(sp)
    80003330:	64a2                	ld	s1,8(sp)
    80003332:	6105                	addi	sp,sp,32
    80003334:	8082                	ret
    panic("bwrite");
    80003336:	00005517          	auipc	a0,0x5
    8000333a:	24a50513          	addi	a0,a0,586 # 80008580 <syscalls+0x108>
    8000333e:	ffffd097          	auipc	ra,0xffffd
    80003342:	1fc080e7          	jalr	508(ra) # 8000053a <panic>

0000000080003346 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003346:	1101                	addi	sp,sp,-32
    80003348:	ec06                	sd	ra,24(sp)
    8000334a:	e822                	sd	s0,16(sp)
    8000334c:	e426                	sd	s1,8(sp)
    8000334e:	e04a                	sd	s2,0(sp)
    80003350:	1000                	addi	s0,sp,32
    80003352:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003354:	01050913          	addi	s2,a0,16
    80003358:	854a                	mv	a0,s2
    8000335a:	00001097          	auipc	ra,0x1
    8000335e:	428080e7          	jalr	1064(ra) # 80004782 <holdingsleep>
    80003362:	c92d                	beqz	a0,800033d4 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003364:	854a                	mv	a0,s2
    80003366:	00001097          	auipc	ra,0x1
    8000336a:	3d8080e7          	jalr	984(ra) # 8000473e <releasesleep>

  acquire(&bcache.lock);
    8000336e:	00014517          	auipc	a0,0x14
    80003372:	17a50513          	addi	a0,a0,378 # 800174e8 <bcache>
    80003376:	ffffe097          	auipc	ra,0xffffe
    8000337a:	8a4080e7          	jalr	-1884(ra) # 80000c1a <acquire>
  b->refcnt--;
    8000337e:	40bc                	lw	a5,64(s1)
    80003380:	37fd                	addiw	a5,a5,-1
    80003382:	0007871b          	sext.w	a4,a5
    80003386:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003388:	eb05                	bnez	a4,800033b8 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000338a:	68bc                	ld	a5,80(s1)
    8000338c:	64b8                	ld	a4,72(s1)
    8000338e:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003390:	64bc                	ld	a5,72(s1)
    80003392:	68b8                	ld	a4,80(s1)
    80003394:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003396:	0001c797          	auipc	a5,0x1c
    8000339a:	15278793          	addi	a5,a5,338 # 8001f4e8 <bcache+0x8000>
    8000339e:	2b87b703          	ld	a4,696(a5)
    800033a2:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800033a4:	0001c717          	auipc	a4,0x1c
    800033a8:	3ac70713          	addi	a4,a4,940 # 8001f750 <bcache+0x8268>
    800033ac:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800033ae:	2b87b703          	ld	a4,696(a5)
    800033b2:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800033b4:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800033b8:	00014517          	auipc	a0,0x14
    800033bc:	13050513          	addi	a0,a0,304 # 800174e8 <bcache>
    800033c0:	ffffe097          	auipc	ra,0xffffe
    800033c4:	90e080e7          	jalr	-1778(ra) # 80000cce <release>
}
    800033c8:	60e2                	ld	ra,24(sp)
    800033ca:	6442                	ld	s0,16(sp)
    800033cc:	64a2                	ld	s1,8(sp)
    800033ce:	6902                	ld	s2,0(sp)
    800033d0:	6105                	addi	sp,sp,32
    800033d2:	8082                	ret
    panic("brelse");
    800033d4:	00005517          	auipc	a0,0x5
    800033d8:	1b450513          	addi	a0,a0,436 # 80008588 <syscalls+0x110>
    800033dc:	ffffd097          	auipc	ra,0xffffd
    800033e0:	15e080e7          	jalr	350(ra) # 8000053a <panic>

00000000800033e4 <bpin>:

void
bpin(struct buf *b) {
    800033e4:	1101                	addi	sp,sp,-32
    800033e6:	ec06                	sd	ra,24(sp)
    800033e8:	e822                	sd	s0,16(sp)
    800033ea:	e426                	sd	s1,8(sp)
    800033ec:	1000                	addi	s0,sp,32
    800033ee:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800033f0:	00014517          	auipc	a0,0x14
    800033f4:	0f850513          	addi	a0,a0,248 # 800174e8 <bcache>
    800033f8:	ffffe097          	auipc	ra,0xffffe
    800033fc:	822080e7          	jalr	-2014(ra) # 80000c1a <acquire>
  b->refcnt++;
    80003400:	40bc                	lw	a5,64(s1)
    80003402:	2785                	addiw	a5,a5,1
    80003404:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003406:	00014517          	auipc	a0,0x14
    8000340a:	0e250513          	addi	a0,a0,226 # 800174e8 <bcache>
    8000340e:	ffffe097          	auipc	ra,0xffffe
    80003412:	8c0080e7          	jalr	-1856(ra) # 80000cce <release>
}
    80003416:	60e2                	ld	ra,24(sp)
    80003418:	6442                	ld	s0,16(sp)
    8000341a:	64a2                	ld	s1,8(sp)
    8000341c:	6105                	addi	sp,sp,32
    8000341e:	8082                	ret

0000000080003420 <bunpin>:

void
bunpin(struct buf *b) {
    80003420:	1101                	addi	sp,sp,-32
    80003422:	ec06                	sd	ra,24(sp)
    80003424:	e822                	sd	s0,16(sp)
    80003426:	e426                	sd	s1,8(sp)
    80003428:	1000                	addi	s0,sp,32
    8000342a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000342c:	00014517          	auipc	a0,0x14
    80003430:	0bc50513          	addi	a0,a0,188 # 800174e8 <bcache>
    80003434:	ffffd097          	auipc	ra,0xffffd
    80003438:	7e6080e7          	jalr	2022(ra) # 80000c1a <acquire>
  b->refcnt--;
    8000343c:	40bc                	lw	a5,64(s1)
    8000343e:	37fd                	addiw	a5,a5,-1
    80003440:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003442:	00014517          	auipc	a0,0x14
    80003446:	0a650513          	addi	a0,a0,166 # 800174e8 <bcache>
    8000344a:	ffffe097          	auipc	ra,0xffffe
    8000344e:	884080e7          	jalr	-1916(ra) # 80000cce <release>
}
    80003452:	60e2                	ld	ra,24(sp)
    80003454:	6442                	ld	s0,16(sp)
    80003456:	64a2                	ld	s1,8(sp)
    80003458:	6105                	addi	sp,sp,32
    8000345a:	8082                	ret

000000008000345c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000345c:	1101                	addi	sp,sp,-32
    8000345e:	ec06                	sd	ra,24(sp)
    80003460:	e822                	sd	s0,16(sp)
    80003462:	e426                	sd	s1,8(sp)
    80003464:	e04a                	sd	s2,0(sp)
    80003466:	1000                	addi	s0,sp,32
    80003468:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000346a:	00d5d59b          	srliw	a1,a1,0xd
    8000346e:	0001c797          	auipc	a5,0x1c
    80003472:	7567a783          	lw	a5,1878(a5) # 8001fbc4 <sb+0x1c>
    80003476:	9dbd                	addw	a1,a1,a5
    80003478:	00000097          	auipc	ra,0x0
    8000347c:	d9e080e7          	jalr	-610(ra) # 80003216 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003480:	0074f713          	andi	a4,s1,7
    80003484:	4785                	li	a5,1
    80003486:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000348a:	14ce                	slli	s1,s1,0x33
    8000348c:	90d9                	srli	s1,s1,0x36
    8000348e:	00950733          	add	a4,a0,s1
    80003492:	05874703          	lbu	a4,88(a4)
    80003496:	00e7f6b3          	and	a3,a5,a4
    8000349a:	c69d                	beqz	a3,800034c8 <bfree+0x6c>
    8000349c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000349e:	94aa                	add	s1,s1,a0
    800034a0:	fff7c793          	not	a5,a5
    800034a4:	8f7d                	and	a4,a4,a5
    800034a6:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800034aa:	00001097          	auipc	ra,0x1
    800034ae:	120080e7          	jalr	288(ra) # 800045ca <log_write>
  brelse(bp);
    800034b2:	854a                	mv	a0,s2
    800034b4:	00000097          	auipc	ra,0x0
    800034b8:	e92080e7          	jalr	-366(ra) # 80003346 <brelse>
}
    800034bc:	60e2                	ld	ra,24(sp)
    800034be:	6442                	ld	s0,16(sp)
    800034c0:	64a2                	ld	s1,8(sp)
    800034c2:	6902                	ld	s2,0(sp)
    800034c4:	6105                	addi	sp,sp,32
    800034c6:	8082                	ret
    panic("freeing free block");
    800034c8:	00005517          	auipc	a0,0x5
    800034cc:	0c850513          	addi	a0,a0,200 # 80008590 <syscalls+0x118>
    800034d0:	ffffd097          	auipc	ra,0xffffd
    800034d4:	06a080e7          	jalr	106(ra) # 8000053a <panic>

00000000800034d8 <balloc>:
{
    800034d8:	711d                	addi	sp,sp,-96
    800034da:	ec86                	sd	ra,88(sp)
    800034dc:	e8a2                	sd	s0,80(sp)
    800034de:	e4a6                	sd	s1,72(sp)
    800034e0:	e0ca                	sd	s2,64(sp)
    800034e2:	fc4e                	sd	s3,56(sp)
    800034e4:	f852                	sd	s4,48(sp)
    800034e6:	f456                	sd	s5,40(sp)
    800034e8:	f05a                	sd	s6,32(sp)
    800034ea:	ec5e                	sd	s7,24(sp)
    800034ec:	e862                	sd	s8,16(sp)
    800034ee:	e466                	sd	s9,8(sp)
    800034f0:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800034f2:	0001c797          	auipc	a5,0x1c
    800034f6:	6ba7a783          	lw	a5,1722(a5) # 8001fbac <sb+0x4>
    800034fa:	cbc1                	beqz	a5,8000358a <balloc+0xb2>
    800034fc:	8baa                	mv	s7,a0
    800034fe:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003500:	0001cb17          	auipc	s6,0x1c
    80003504:	6a8b0b13          	addi	s6,s6,1704 # 8001fba8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003508:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000350a:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000350c:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000350e:	6c89                	lui	s9,0x2
    80003510:	a831                	j	8000352c <balloc+0x54>
    brelse(bp);
    80003512:	854a                	mv	a0,s2
    80003514:	00000097          	auipc	ra,0x0
    80003518:	e32080e7          	jalr	-462(ra) # 80003346 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000351c:	015c87bb          	addw	a5,s9,s5
    80003520:	00078a9b          	sext.w	s5,a5
    80003524:	004b2703          	lw	a4,4(s6)
    80003528:	06eaf163          	bgeu	s5,a4,8000358a <balloc+0xb2>
    bp = bread(dev, BBLOCK(b, sb));
    8000352c:	41fad79b          	sraiw	a5,s5,0x1f
    80003530:	0137d79b          	srliw	a5,a5,0x13
    80003534:	015787bb          	addw	a5,a5,s5
    80003538:	40d7d79b          	sraiw	a5,a5,0xd
    8000353c:	01cb2583          	lw	a1,28(s6)
    80003540:	9dbd                	addw	a1,a1,a5
    80003542:	855e                	mv	a0,s7
    80003544:	00000097          	auipc	ra,0x0
    80003548:	cd2080e7          	jalr	-814(ra) # 80003216 <bread>
    8000354c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000354e:	004b2503          	lw	a0,4(s6)
    80003552:	000a849b          	sext.w	s1,s5
    80003556:	8762                	mv	a4,s8
    80003558:	faa4fde3          	bgeu	s1,a0,80003512 <balloc+0x3a>
      m = 1 << (bi % 8);
    8000355c:	00777693          	andi	a3,a4,7
    80003560:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003564:	41f7579b          	sraiw	a5,a4,0x1f
    80003568:	01d7d79b          	srliw	a5,a5,0x1d
    8000356c:	9fb9                	addw	a5,a5,a4
    8000356e:	4037d79b          	sraiw	a5,a5,0x3
    80003572:	00f90633          	add	a2,s2,a5
    80003576:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    8000357a:	00c6f5b3          	and	a1,a3,a2
    8000357e:	cd91                	beqz	a1,8000359a <balloc+0xc2>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003580:	2705                	addiw	a4,a4,1
    80003582:	2485                	addiw	s1,s1,1
    80003584:	fd471ae3          	bne	a4,s4,80003558 <balloc+0x80>
    80003588:	b769                	j	80003512 <balloc+0x3a>
  panic("balloc: out of blocks");
    8000358a:	00005517          	auipc	a0,0x5
    8000358e:	01e50513          	addi	a0,a0,30 # 800085a8 <syscalls+0x130>
    80003592:	ffffd097          	auipc	ra,0xffffd
    80003596:	fa8080e7          	jalr	-88(ra) # 8000053a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000359a:	97ca                	add	a5,a5,s2
    8000359c:	8e55                	or	a2,a2,a3
    8000359e:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800035a2:	854a                	mv	a0,s2
    800035a4:	00001097          	auipc	ra,0x1
    800035a8:	026080e7          	jalr	38(ra) # 800045ca <log_write>
        brelse(bp);
    800035ac:	854a                	mv	a0,s2
    800035ae:	00000097          	auipc	ra,0x0
    800035b2:	d98080e7          	jalr	-616(ra) # 80003346 <brelse>
  bp = bread(dev, bno);
    800035b6:	85a6                	mv	a1,s1
    800035b8:	855e                	mv	a0,s7
    800035ba:	00000097          	auipc	ra,0x0
    800035be:	c5c080e7          	jalr	-932(ra) # 80003216 <bread>
    800035c2:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800035c4:	40000613          	li	a2,1024
    800035c8:	4581                	li	a1,0
    800035ca:	05850513          	addi	a0,a0,88
    800035ce:	ffffd097          	auipc	ra,0xffffd
    800035d2:	748080e7          	jalr	1864(ra) # 80000d16 <memset>
  log_write(bp);
    800035d6:	854a                	mv	a0,s2
    800035d8:	00001097          	auipc	ra,0x1
    800035dc:	ff2080e7          	jalr	-14(ra) # 800045ca <log_write>
  brelse(bp);
    800035e0:	854a                	mv	a0,s2
    800035e2:	00000097          	auipc	ra,0x0
    800035e6:	d64080e7          	jalr	-668(ra) # 80003346 <brelse>
}
    800035ea:	8526                	mv	a0,s1
    800035ec:	60e6                	ld	ra,88(sp)
    800035ee:	6446                	ld	s0,80(sp)
    800035f0:	64a6                	ld	s1,72(sp)
    800035f2:	6906                	ld	s2,64(sp)
    800035f4:	79e2                	ld	s3,56(sp)
    800035f6:	7a42                	ld	s4,48(sp)
    800035f8:	7aa2                	ld	s5,40(sp)
    800035fa:	7b02                	ld	s6,32(sp)
    800035fc:	6be2                	ld	s7,24(sp)
    800035fe:	6c42                	ld	s8,16(sp)
    80003600:	6ca2                	ld	s9,8(sp)
    80003602:	6125                	addi	sp,sp,96
    80003604:	8082                	ret

0000000080003606 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003606:	7179                	addi	sp,sp,-48
    80003608:	f406                	sd	ra,40(sp)
    8000360a:	f022                	sd	s0,32(sp)
    8000360c:	ec26                	sd	s1,24(sp)
    8000360e:	e84a                	sd	s2,16(sp)
    80003610:	e44e                	sd	s3,8(sp)
    80003612:	e052                	sd	s4,0(sp)
    80003614:	1800                	addi	s0,sp,48
    80003616:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003618:	47ad                	li	a5,11
    8000361a:	04b7fe63          	bgeu	a5,a1,80003676 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000361e:	ff45849b          	addiw	s1,a1,-12
    80003622:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003626:	0ff00793          	li	a5,255
    8000362a:	0ae7e463          	bltu	a5,a4,800036d2 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000362e:	08052583          	lw	a1,128(a0)
    80003632:	c5b5                	beqz	a1,8000369e <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003634:	00092503          	lw	a0,0(s2)
    80003638:	00000097          	auipc	ra,0x0
    8000363c:	bde080e7          	jalr	-1058(ra) # 80003216 <bread>
    80003640:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003642:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003646:	02049713          	slli	a4,s1,0x20
    8000364a:	01e75593          	srli	a1,a4,0x1e
    8000364e:	00b784b3          	add	s1,a5,a1
    80003652:	0004a983          	lw	s3,0(s1)
    80003656:	04098e63          	beqz	s3,800036b2 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    8000365a:	8552                	mv	a0,s4
    8000365c:	00000097          	auipc	ra,0x0
    80003660:	cea080e7          	jalr	-790(ra) # 80003346 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003664:	854e                	mv	a0,s3
    80003666:	70a2                	ld	ra,40(sp)
    80003668:	7402                	ld	s0,32(sp)
    8000366a:	64e2                	ld	s1,24(sp)
    8000366c:	6942                	ld	s2,16(sp)
    8000366e:	69a2                	ld	s3,8(sp)
    80003670:	6a02                	ld	s4,0(sp)
    80003672:	6145                	addi	sp,sp,48
    80003674:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003676:	02059793          	slli	a5,a1,0x20
    8000367a:	01e7d593          	srli	a1,a5,0x1e
    8000367e:	00b504b3          	add	s1,a0,a1
    80003682:	0504a983          	lw	s3,80(s1)
    80003686:	fc099fe3          	bnez	s3,80003664 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    8000368a:	4108                	lw	a0,0(a0)
    8000368c:	00000097          	auipc	ra,0x0
    80003690:	e4c080e7          	jalr	-436(ra) # 800034d8 <balloc>
    80003694:	0005099b          	sext.w	s3,a0
    80003698:	0534a823          	sw	s3,80(s1)
    8000369c:	b7e1                	j	80003664 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    8000369e:	4108                	lw	a0,0(a0)
    800036a0:	00000097          	auipc	ra,0x0
    800036a4:	e38080e7          	jalr	-456(ra) # 800034d8 <balloc>
    800036a8:	0005059b          	sext.w	a1,a0
    800036ac:	08b92023          	sw	a1,128(s2)
    800036b0:	b751                	j	80003634 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800036b2:	00092503          	lw	a0,0(s2)
    800036b6:	00000097          	auipc	ra,0x0
    800036ba:	e22080e7          	jalr	-478(ra) # 800034d8 <balloc>
    800036be:	0005099b          	sext.w	s3,a0
    800036c2:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800036c6:	8552                	mv	a0,s4
    800036c8:	00001097          	auipc	ra,0x1
    800036cc:	f02080e7          	jalr	-254(ra) # 800045ca <log_write>
    800036d0:	b769                	j	8000365a <bmap+0x54>
  panic("bmap: out of range");
    800036d2:	00005517          	auipc	a0,0x5
    800036d6:	eee50513          	addi	a0,a0,-274 # 800085c0 <syscalls+0x148>
    800036da:	ffffd097          	auipc	ra,0xffffd
    800036de:	e60080e7          	jalr	-416(ra) # 8000053a <panic>

00000000800036e2 <iget>:
{
    800036e2:	7179                	addi	sp,sp,-48
    800036e4:	f406                	sd	ra,40(sp)
    800036e6:	f022                	sd	s0,32(sp)
    800036e8:	ec26                	sd	s1,24(sp)
    800036ea:	e84a                	sd	s2,16(sp)
    800036ec:	e44e                	sd	s3,8(sp)
    800036ee:	e052                	sd	s4,0(sp)
    800036f0:	1800                	addi	s0,sp,48
    800036f2:	89aa                	mv	s3,a0
    800036f4:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800036f6:	0001c517          	auipc	a0,0x1c
    800036fa:	4d250513          	addi	a0,a0,1234 # 8001fbc8 <itable>
    800036fe:	ffffd097          	auipc	ra,0xffffd
    80003702:	51c080e7          	jalr	1308(ra) # 80000c1a <acquire>
  empty = 0;
    80003706:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003708:	0001c497          	auipc	s1,0x1c
    8000370c:	4d848493          	addi	s1,s1,1240 # 8001fbe0 <itable+0x18>
    80003710:	0001e697          	auipc	a3,0x1e
    80003714:	f6068693          	addi	a3,a3,-160 # 80021670 <log>
    80003718:	a039                	j	80003726 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000371a:	02090b63          	beqz	s2,80003750 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000371e:	08848493          	addi	s1,s1,136
    80003722:	02d48a63          	beq	s1,a3,80003756 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003726:	449c                	lw	a5,8(s1)
    80003728:	fef059e3          	blez	a5,8000371a <iget+0x38>
    8000372c:	4098                	lw	a4,0(s1)
    8000372e:	ff3716e3          	bne	a4,s3,8000371a <iget+0x38>
    80003732:	40d8                	lw	a4,4(s1)
    80003734:	ff4713e3          	bne	a4,s4,8000371a <iget+0x38>
      ip->ref++;
    80003738:	2785                	addiw	a5,a5,1
    8000373a:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000373c:	0001c517          	auipc	a0,0x1c
    80003740:	48c50513          	addi	a0,a0,1164 # 8001fbc8 <itable>
    80003744:	ffffd097          	auipc	ra,0xffffd
    80003748:	58a080e7          	jalr	1418(ra) # 80000cce <release>
      return ip;
    8000374c:	8926                	mv	s2,s1
    8000374e:	a03d                	j	8000377c <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003750:	f7f9                	bnez	a5,8000371e <iget+0x3c>
    80003752:	8926                	mv	s2,s1
    80003754:	b7e9                	j	8000371e <iget+0x3c>
  if(empty == 0)
    80003756:	02090c63          	beqz	s2,8000378e <iget+0xac>
  ip->dev = dev;
    8000375a:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000375e:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003762:	4785                	li	a5,1
    80003764:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003768:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000376c:	0001c517          	auipc	a0,0x1c
    80003770:	45c50513          	addi	a0,a0,1116 # 8001fbc8 <itable>
    80003774:	ffffd097          	auipc	ra,0xffffd
    80003778:	55a080e7          	jalr	1370(ra) # 80000cce <release>
}
    8000377c:	854a                	mv	a0,s2
    8000377e:	70a2                	ld	ra,40(sp)
    80003780:	7402                	ld	s0,32(sp)
    80003782:	64e2                	ld	s1,24(sp)
    80003784:	6942                	ld	s2,16(sp)
    80003786:	69a2                	ld	s3,8(sp)
    80003788:	6a02                	ld	s4,0(sp)
    8000378a:	6145                	addi	sp,sp,48
    8000378c:	8082                	ret
    panic("iget: no inodes");
    8000378e:	00005517          	auipc	a0,0x5
    80003792:	e4a50513          	addi	a0,a0,-438 # 800085d8 <syscalls+0x160>
    80003796:	ffffd097          	auipc	ra,0xffffd
    8000379a:	da4080e7          	jalr	-604(ra) # 8000053a <panic>

000000008000379e <fsinit>:
fsinit(int dev) {
    8000379e:	7179                	addi	sp,sp,-48
    800037a0:	f406                	sd	ra,40(sp)
    800037a2:	f022                	sd	s0,32(sp)
    800037a4:	ec26                	sd	s1,24(sp)
    800037a6:	e84a                	sd	s2,16(sp)
    800037a8:	e44e                	sd	s3,8(sp)
    800037aa:	1800                	addi	s0,sp,48
    800037ac:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800037ae:	4585                	li	a1,1
    800037b0:	00000097          	auipc	ra,0x0
    800037b4:	a66080e7          	jalr	-1434(ra) # 80003216 <bread>
    800037b8:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800037ba:	0001c997          	auipc	s3,0x1c
    800037be:	3ee98993          	addi	s3,s3,1006 # 8001fba8 <sb>
    800037c2:	02000613          	li	a2,32
    800037c6:	05850593          	addi	a1,a0,88
    800037ca:	854e                	mv	a0,s3
    800037cc:	ffffd097          	auipc	ra,0xffffd
    800037d0:	5a6080e7          	jalr	1446(ra) # 80000d72 <memmove>
  brelse(bp);
    800037d4:	8526                	mv	a0,s1
    800037d6:	00000097          	auipc	ra,0x0
    800037da:	b70080e7          	jalr	-1168(ra) # 80003346 <brelse>
  if(sb.magic != FSMAGIC)
    800037de:	0009a703          	lw	a4,0(s3)
    800037e2:	102037b7          	lui	a5,0x10203
    800037e6:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800037ea:	02f71263          	bne	a4,a5,8000380e <fsinit+0x70>
  initlog(dev, &sb);
    800037ee:	0001c597          	auipc	a1,0x1c
    800037f2:	3ba58593          	addi	a1,a1,954 # 8001fba8 <sb>
    800037f6:	854a                	mv	a0,s2
    800037f8:	00001097          	auipc	ra,0x1
    800037fc:	b56080e7          	jalr	-1194(ra) # 8000434e <initlog>
}
    80003800:	70a2                	ld	ra,40(sp)
    80003802:	7402                	ld	s0,32(sp)
    80003804:	64e2                	ld	s1,24(sp)
    80003806:	6942                	ld	s2,16(sp)
    80003808:	69a2                	ld	s3,8(sp)
    8000380a:	6145                	addi	sp,sp,48
    8000380c:	8082                	ret
    panic("invalid file system");
    8000380e:	00005517          	auipc	a0,0x5
    80003812:	dda50513          	addi	a0,a0,-550 # 800085e8 <syscalls+0x170>
    80003816:	ffffd097          	auipc	ra,0xffffd
    8000381a:	d24080e7          	jalr	-732(ra) # 8000053a <panic>

000000008000381e <iinit>:
{
    8000381e:	7179                	addi	sp,sp,-48
    80003820:	f406                	sd	ra,40(sp)
    80003822:	f022                	sd	s0,32(sp)
    80003824:	ec26                	sd	s1,24(sp)
    80003826:	e84a                	sd	s2,16(sp)
    80003828:	e44e                	sd	s3,8(sp)
    8000382a:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000382c:	00005597          	auipc	a1,0x5
    80003830:	dd458593          	addi	a1,a1,-556 # 80008600 <syscalls+0x188>
    80003834:	0001c517          	auipc	a0,0x1c
    80003838:	39450513          	addi	a0,a0,916 # 8001fbc8 <itable>
    8000383c:	ffffd097          	auipc	ra,0xffffd
    80003840:	34e080e7          	jalr	846(ra) # 80000b8a <initlock>
  for(i = 0; i < NINODE; i++) {
    80003844:	0001c497          	auipc	s1,0x1c
    80003848:	3ac48493          	addi	s1,s1,940 # 8001fbf0 <itable+0x28>
    8000384c:	0001e997          	auipc	s3,0x1e
    80003850:	e3498993          	addi	s3,s3,-460 # 80021680 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003854:	00005917          	auipc	s2,0x5
    80003858:	db490913          	addi	s2,s2,-588 # 80008608 <syscalls+0x190>
    8000385c:	85ca                	mv	a1,s2
    8000385e:	8526                	mv	a0,s1
    80003860:	00001097          	auipc	ra,0x1
    80003864:	e4e080e7          	jalr	-434(ra) # 800046ae <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003868:	08848493          	addi	s1,s1,136
    8000386c:	ff3498e3          	bne	s1,s3,8000385c <iinit+0x3e>
}
    80003870:	70a2                	ld	ra,40(sp)
    80003872:	7402                	ld	s0,32(sp)
    80003874:	64e2                	ld	s1,24(sp)
    80003876:	6942                	ld	s2,16(sp)
    80003878:	69a2                	ld	s3,8(sp)
    8000387a:	6145                	addi	sp,sp,48
    8000387c:	8082                	ret

000000008000387e <ialloc>:
{
    8000387e:	715d                	addi	sp,sp,-80
    80003880:	e486                	sd	ra,72(sp)
    80003882:	e0a2                	sd	s0,64(sp)
    80003884:	fc26                	sd	s1,56(sp)
    80003886:	f84a                	sd	s2,48(sp)
    80003888:	f44e                	sd	s3,40(sp)
    8000388a:	f052                	sd	s4,32(sp)
    8000388c:	ec56                	sd	s5,24(sp)
    8000388e:	e85a                	sd	s6,16(sp)
    80003890:	e45e                	sd	s7,8(sp)
    80003892:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003894:	0001c717          	auipc	a4,0x1c
    80003898:	32072703          	lw	a4,800(a4) # 8001fbb4 <sb+0xc>
    8000389c:	4785                	li	a5,1
    8000389e:	04e7fa63          	bgeu	a5,a4,800038f2 <ialloc+0x74>
    800038a2:	8aaa                	mv	s5,a0
    800038a4:	8bae                	mv	s7,a1
    800038a6:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800038a8:	0001ca17          	auipc	s4,0x1c
    800038ac:	300a0a13          	addi	s4,s4,768 # 8001fba8 <sb>
    800038b0:	00048b1b          	sext.w	s6,s1
    800038b4:	0044d593          	srli	a1,s1,0x4
    800038b8:	018a2783          	lw	a5,24(s4)
    800038bc:	9dbd                	addw	a1,a1,a5
    800038be:	8556                	mv	a0,s5
    800038c0:	00000097          	auipc	ra,0x0
    800038c4:	956080e7          	jalr	-1706(ra) # 80003216 <bread>
    800038c8:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800038ca:	05850993          	addi	s3,a0,88
    800038ce:	00f4f793          	andi	a5,s1,15
    800038d2:	079a                	slli	a5,a5,0x6
    800038d4:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800038d6:	00099783          	lh	a5,0(s3)
    800038da:	c785                	beqz	a5,80003902 <ialloc+0x84>
    brelse(bp);
    800038dc:	00000097          	auipc	ra,0x0
    800038e0:	a6a080e7          	jalr	-1430(ra) # 80003346 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800038e4:	0485                	addi	s1,s1,1
    800038e6:	00ca2703          	lw	a4,12(s4)
    800038ea:	0004879b          	sext.w	a5,s1
    800038ee:	fce7e1e3          	bltu	a5,a4,800038b0 <ialloc+0x32>
  panic("ialloc: no inodes");
    800038f2:	00005517          	auipc	a0,0x5
    800038f6:	d1e50513          	addi	a0,a0,-738 # 80008610 <syscalls+0x198>
    800038fa:	ffffd097          	auipc	ra,0xffffd
    800038fe:	c40080e7          	jalr	-960(ra) # 8000053a <panic>
      memset(dip, 0, sizeof(*dip));
    80003902:	04000613          	li	a2,64
    80003906:	4581                	li	a1,0
    80003908:	854e                	mv	a0,s3
    8000390a:	ffffd097          	auipc	ra,0xffffd
    8000390e:	40c080e7          	jalr	1036(ra) # 80000d16 <memset>
      dip->type = type;
    80003912:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003916:	854a                	mv	a0,s2
    80003918:	00001097          	auipc	ra,0x1
    8000391c:	cb2080e7          	jalr	-846(ra) # 800045ca <log_write>
      brelse(bp);
    80003920:	854a                	mv	a0,s2
    80003922:	00000097          	auipc	ra,0x0
    80003926:	a24080e7          	jalr	-1500(ra) # 80003346 <brelse>
      return iget(dev, inum);
    8000392a:	85da                	mv	a1,s6
    8000392c:	8556                	mv	a0,s5
    8000392e:	00000097          	auipc	ra,0x0
    80003932:	db4080e7          	jalr	-588(ra) # 800036e2 <iget>
}
    80003936:	60a6                	ld	ra,72(sp)
    80003938:	6406                	ld	s0,64(sp)
    8000393a:	74e2                	ld	s1,56(sp)
    8000393c:	7942                	ld	s2,48(sp)
    8000393e:	79a2                	ld	s3,40(sp)
    80003940:	7a02                	ld	s4,32(sp)
    80003942:	6ae2                	ld	s5,24(sp)
    80003944:	6b42                	ld	s6,16(sp)
    80003946:	6ba2                	ld	s7,8(sp)
    80003948:	6161                	addi	sp,sp,80
    8000394a:	8082                	ret

000000008000394c <iupdate>:
{
    8000394c:	1101                	addi	sp,sp,-32
    8000394e:	ec06                	sd	ra,24(sp)
    80003950:	e822                	sd	s0,16(sp)
    80003952:	e426                	sd	s1,8(sp)
    80003954:	e04a                	sd	s2,0(sp)
    80003956:	1000                	addi	s0,sp,32
    80003958:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000395a:	415c                	lw	a5,4(a0)
    8000395c:	0047d79b          	srliw	a5,a5,0x4
    80003960:	0001c597          	auipc	a1,0x1c
    80003964:	2605a583          	lw	a1,608(a1) # 8001fbc0 <sb+0x18>
    80003968:	9dbd                	addw	a1,a1,a5
    8000396a:	4108                	lw	a0,0(a0)
    8000396c:	00000097          	auipc	ra,0x0
    80003970:	8aa080e7          	jalr	-1878(ra) # 80003216 <bread>
    80003974:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003976:	05850793          	addi	a5,a0,88
    8000397a:	40d8                	lw	a4,4(s1)
    8000397c:	8b3d                	andi	a4,a4,15
    8000397e:	071a                	slli	a4,a4,0x6
    80003980:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003982:	04449703          	lh	a4,68(s1)
    80003986:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000398a:	04649703          	lh	a4,70(s1)
    8000398e:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003992:	04849703          	lh	a4,72(s1)
    80003996:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000399a:	04a49703          	lh	a4,74(s1)
    8000399e:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800039a2:	44f8                	lw	a4,76(s1)
    800039a4:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800039a6:	03400613          	li	a2,52
    800039aa:	05048593          	addi	a1,s1,80
    800039ae:	00c78513          	addi	a0,a5,12
    800039b2:	ffffd097          	auipc	ra,0xffffd
    800039b6:	3c0080e7          	jalr	960(ra) # 80000d72 <memmove>
  log_write(bp);
    800039ba:	854a                	mv	a0,s2
    800039bc:	00001097          	auipc	ra,0x1
    800039c0:	c0e080e7          	jalr	-1010(ra) # 800045ca <log_write>
  brelse(bp);
    800039c4:	854a                	mv	a0,s2
    800039c6:	00000097          	auipc	ra,0x0
    800039ca:	980080e7          	jalr	-1664(ra) # 80003346 <brelse>
}
    800039ce:	60e2                	ld	ra,24(sp)
    800039d0:	6442                	ld	s0,16(sp)
    800039d2:	64a2                	ld	s1,8(sp)
    800039d4:	6902                	ld	s2,0(sp)
    800039d6:	6105                	addi	sp,sp,32
    800039d8:	8082                	ret

00000000800039da <idup>:
{
    800039da:	1101                	addi	sp,sp,-32
    800039dc:	ec06                	sd	ra,24(sp)
    800039de:	e822                	sd	s0,16(sp)
    800039e0:	e426                	sd	s1,8(sp)
    800039e2:	1000                	addi	s0,sp,32
    800039e4:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800039e6:	0001c517          	auipc	a0,0x1c
    800039ea:	1e250513          	addi	a0,a0,482 # 8001fbc8 <itable>
    800039ee:	ffffd097          	auipc	ra,0xffffd
    800039f2:	22c080e7          	jalr	556(ra) # 80000c1a <acquire>
  ip->ref++;
    800039f6:	449c                	lw	a5,8(s1)
    800039f8:	2785                	addiw	a5,a5,1
    800039fa:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800039fc:	0001c517          	auipc	a0,0x1c
    80003a00:	1cc50513          	addi	a0,a0,460 # 8001fbc8 <itable>
    80003a04:	ffffd097          	auipc	ra,0xffffd
    80003a08:	2ca080e7          	jalr	714(ra) # 80000cce <release>
}
    80003a0c:	8526                	mv	a0,s1
    80003a0e:	60e2                	ld	ra,24(sp)
    80003a10:	6442                	ld	s0,16(sp)
    80003a12:	64a2                	ld	s1,8(sp)
    80003a14:	6105                	addi	sp,sp,32
    80003a16:	8082                	ret

0000000080003a18 <ilock>:
{
    80003a18:	1101                	addi	sp,sp,-32
    80003a1a:	ec06                	sd	ra,24(sp)
    80003a1c:	e822                	sd	s0,16(sp)
    80003a1e:	e426                	sd	s1,8(sp)
    80003a20:	e04a                	sd	s2,0(sp)
    80003a22:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003a24:	c115                	beqz	a0,80003a48 <ilock+0x30>
    80003a26:	84aa                	mv	s1,a0
    80003a28:	451c                	lw	a5,8(a0)
    80003a2a:	00f05f63          	blez	a5,80003a48 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003a2e:	0541                	addi	a0,a0,16
    80003a30:	00001097          	auipc	ra,0x1
    80003a34:	cb8080e7          	jalr	-840(ra) # 800046e8 <acquiresleep>
  if(ip->valid == 0){
    80003a38:	40bc                	lw	a5,64(s1)
    80003a3a:	cf99                	beqz	a5,80003a58 <ilock+0x40>
}
    80003a3c:	60e2                	ld	ra,24(sp)
    80003a3e:	6442                	ld	s0,16(sp)
    80003a40:	64a2                	ld	s1,8(sp)
    80003a42:	6902                	ld	s2,0(sp)
    80003a44:	6105                	addi	sp,sp,32
    80003a46:	8082                	ret
    panic("ilock");
    80003a48:	00005517          	auipc	a0,0x5
    80003a4c:	be050513          	addi	a0,a0,-1056 # 80008628 <syscalls+0x1b0>
    80003a50:	ffffd097          	auipc	ra,0xffffd
    80003a54:	aea080e7          	jalr	-1302(ra) # 8000053a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a58:	40dc                	lw	a5,4(s1)
    80003a5a:	0047d79b          	srliw	a5,a5,0x4
    80003a5e:	0001c597          	auipc	a1,0x1c
    80003a62:	1625a583          	lw	a1,354(a1) # 8001fbc0 <sb+0x18>
    80003a66:	9dbd                	addw	a1,a1,a5
    80003a68:	4088                	lw	a0,0(s1)
    80003a6a:	fffff097          	auipc	ra,0xfffff
    80003a6e:	7ac080e7          	jalr	1964(ra) # 80003216 <bread>
    80003a72:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003a74:	05850593          	addi	a1,a0,88
    80003a78:	40dc                	lw	a5,4(s1)
    80003a7a:	8bbd                	andi	a5,a5,15
    80003a7c:	079a                	slli	a5,a5,0x6
    80003a7e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003a80:	00059783          	lh	a5,0(a1)
    80003a84:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003a88:	00259783          	lh	a5,2(a1)
    80003a8c:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003a90:	00459783          	lh	a5,4(a1)
    80003a94:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003a98:	00659783          	lh	a5,6(a1)
    80003a9c:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003aa0:	459c                	lw	a5,8(a1)
    80003aa2:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003aa4:	03400613          	li	a2,52
    80003aa8:	05b1                	addi	a1,a1,12
    80003aaa:	05048513          	addi	a0,s1,80
    80003aae:	ffffd097          	auipc	ra,0xffffd
    80003ab2:	2c4080e7          	jalr	708(ra) # 80000d72 <memmove>
    brelse(bp);
    80003ab6:	854a                	mv	a0,s2
    80003ab8:	00000097          	auipc	ra,0x0
    80003abc:	88e080e7          	jalr	-1906(ra) # 80003346 <brelse>
    ip->valid = 1;
    80003ac0:	4785                	li	a5,1
    80003ac2:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003ac4:	04449783          	lh	a5,68(s1)
    80003ac8:	fbb5                	bnez	a5,80003a3c <ilock+0x24>
      panic("ilock: no type");
    80003aca:	00005517          	auipc	a0,0x5
    80003ace:	b6650513          	addi	a0,a0,-1178 # 80008630 <syscalls+0x1b8>
    80003ad2:	ffffd097          	auipc	ra,0xffffd
    80003ad6:	a68080e7          	jalr	-1432(ra) # 8000053a <panic>

0000000080003ada <iunlock>:
{
    80003ada:	1101                	addi	sp,sp,-32
    80003adc:	ec06                	sd	ra,24(sp)
    80003ade:	e822                	sd	s0,16(sp)
    80003ae0:	e426                	sd	s1,8(sp)
    80003ae2:	e04a                	sd	s2,0(sp)
    80003ae4:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003ae6:	c905                	beqz	a0,80003b16 <iunlock+0x3c>
    80003ae8:	84aa                	mv	s1,a0
    80003aea:	01050913          	addi	s2,a0,16
    80003aee:	854a                	mv	a0,s2
    80003af0:	00001097          	auipc	ra,0x1
    80003af4:	c92080e7          	jalr	-878(ra) # 80004782 <holdingsleep>
    80003af8:	cd19                	beqz	a0,80003b16 <iunlock+0x3c>
    80003afa:	449c                	lw	a5,8(s1)
    80003afc:	00f05d63          	blez	a5,80003b16 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003b00:	854a                	mv	a0,s2
    80003b02:	00001097          	auipc	ra,0x1
    80003b06:	c3c080e7          	jalr	-964(ra) # 8000473e <releasesleep>
}
    80003b0a:	60e2                	ld	ra,24(sp)
    80003b0c:	6442                	ld	s0,16(sp)
    80003b0e:	64a2                	ld	s1,8(sp)
    80003b10:	6902                	ld	s2,0(sp)
    80003b12:	6105                	addi	sp,sp,32
    80003b14:	8082                	ret
    panic("iunlock");
    80003b16:	00005517          	auipc	a0,0x5
    80003b1a:	b2a50513          	addi	a0,a0,-1238 # 80008640 <syscalls+0x1c8>
    80003b1e:	ffffd097          	auipc	ra,0xffffd
    80003b22:	a1c080e7          	jalr	-1508(ra) # 8000053a <panic>

0000000080003b26 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003b26:	7179                	addi	sp,sp,-48
    80003b28:	f406                	sd	ra,40(sp)
    80003b2a:	f022                	sd	s0,32(sp)
    80003b2c:	ec26                	sd	s1,24(sp)
    80003b2e:	e84a                	sd	s2,16(sp)
    80003b30:	e44e                	sd	s3,8(sp)
    80003b32:	e052                	sd	s4,0(sp)
    80003b34:	1800                	addi	s0,sp,48
    80003b36:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003b38:	05050493          	addi	s1,a0,80
    80003b3c:	08050913          	addi	s2,a0,128
    80003b40:	a021                	j	80003b48 <itrunc+0x22>
    80003b42:	0491                	addi	s1,s1,4
    80003b44:	01248d63          	beq	s1,s2,80003b5e <itrunc+0x38>
    if(ip->addrs[i]){
    80003b48:	408c                	lw	a1,0(s1)
    80003b4a:	dde5                	beqz	a1,80003b42 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003b4c:	0009a503          	lw	a0,0(s3)
    80003b50:	00000097          	auipc	ra,0x0
    80003b54:	90c080e7          	jalr	-1780(ra) # 8000345c <bfree>
      ip->addrs[i] = 0;
    80003b58:	0004a023          	sw	zero,0(s1)
    80003b5c:	b7dd                	j	80003b42 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003b5e:	0809a583          	lw	a1,128(s3)
    80003b62:	e185                	bnez	a1,80003b82 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003b64:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003b68:	854e                	mv	a0,s3
    80003b6a:	00000097          	auipc	ra,0x0
    80003b6e:	de2080e7          	jalr	-542(ra) # 8000394c <iupdate>
}
    80003b72:	70a2                	ld	ra,40(sp)
    80003b74:	7402                	ld	s0,32(sp)
    80003b76:	64e2                	ld	s1,24(sp)
    80003b78:	6942                	ld	s2,16(sp)
    80003b7a:	69a2                	ld	s3,8(sp)
    80003b7c:	6a02                	ld	s4,0(sp)
    80003b7e:	6145                	addi	sp,sp,48
    80003b80:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003b82:	0009a503          	lw	a0,0(s3)
    80003b86:	fffff097          	auipc	ra,0xfffff
    80003b8a:	690080e7          	jalr	1680(ra) # 80003216 <bread>
    80003b8e:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003b90:	05850493          	addi	s1,a0,88
    80003b94:	45850913          	addi	s2,a0,1112
    80003b98:	a021                	j	80003ba0 <itrunc+0x7a>
    80003b9a:	0491                	addi	s1,s1,4
    80003b9c:	01248b63          	beq	s1,s2,80003bb2 <itrunc+0x8c>
      if(a[j])
    80003ba0:	408c                	lw	a1,0(s1)
    80003ba2:	dde5                	beqz	a1,80003b9a <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003ba4:	0009a503          	lw	a0,0(s3)
    80003ba8:	00000097          	auipc	ra,0x0
    80003bac:	8b4080e7          	jalr	-1868(ra) # 8000345c <bfree>
    80003bb0:	b7ed                	j	80003b9a <itrunc+0x74>
    brelse(bp);
    80003bb2:	8552                	mv	a0,s4
    80003bb4:	fffff097          	auipc	ra,0xfffff
    80003bb8:	792080e7          	jalr	1938(ra) # 80003346 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003bbc:	0809a583          	lw	a1,128(s3)
    80003bc0:	0009a503          	lw	a0,0(s3)
    80003bc4:	00000097          	auipc	ra,0x0
    80003bc8:	898080e7          	jalr	-1896(ra) # 8000345c <bfree>
    ip->addrs[NDIRECT] = 0;
    80003bcc:	0809a023          	sw	zero,128(s3)
    80003bd0:	bf51                	j	80003b64 <itrunc+0x3e>

0000000080003bd2 <iput>:
{
    80003bd2:	1101                	addi	sp,sp,-32
    80003bd4:	ec06                	sd	ra,24(sp)
    80003bd6:	e822                	sd	s0,16(sp)
    80003bd8:	e426                	sd	s1,8(sp)
    80003bda:	e04a                	sd	s2,0(sp)
    80003bdc:	1000                	addi	s0,sp,32
    80003bde:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003be0:	0001c517          	auipc	a0,0x1c
    80003be4:	fe850513          	addi	a0,a0,-24 # 8001fbc8 <itable>
    80003be8:	ffffd097          	auipc	ra,0xffffd
    80003bec:	032080e7          	jalr	50(ra) # 80000c1a <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003bf0:	4498                	lw	a4,8(s1)
    80003bf2:	4785                	li	a5,1
    80003bf4:	02f70363          	beq	a4,a5,80003c1a <iput+0x48>
  ip->ref--;
    80003bf8:	449c                	lw	a5,8(s1)
    80003bfa:	37fd                	addiw	a5,a5,-1
    80003bfc:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003bfe:	0001c517          	auipc	a0,0x1c
    80003c02:	fca50513          	addi	a0,a0,-54 # 8001fbc8 <itable>
    80003c06:	ffffd097          	auipc	ra,0xffffd
    80003c0a:	0c8080e7          	jalr	200(ra) # 80000cce <release>
}
    80003c0e:	60e2                	ld	ra,24(sp)
    80003c10:	6442                	ld	s0,16(sp)
    80003c12:	64a2                	ld	s1,8(sp)
    80003c14:	6902                	ld	s2,0(sp)
    80003c16:	6105                	addi	sp,sp,32
    80003c18:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003c1a:	40bc                	lw	a5,64(s1)
    80003c1c:	dff1                	beqz	a5,80003bf8 <iput+0x26>
    80003c1e:	04a49783          	lh	a5,74(s1)
    80003c22:	fbf9                	bnez	a5,80003bf8 <iput+0x26>
    acquiresleep(&ip->lock);
    80003c24:	01048913          	addi	s2,s1,16
    80003c28:	854a                	mv	a0,s2
    80003c2a:	00001097          	auipc	ra,0x1
    80003c2e:	abe080e7          	jalr	-1346(ra) # 800046e8 <acquiresleep>
    release(&itable.lock);
    80003c32:	0001c517          	auipc	a0,0x1c
    80003c36:	f9650513          	addi	a0,a0,-106 # 8001fbc8 <itable>
    80003c3a:	ffffd097          	auipc	ra,0xffffd
    80003c3e:	094080e7          	jalr	148(ra) # 80000cce <release>
    itrunc(ip);
    80003c42:	8526                	mv	a0,s1
    80003c44:	00000097          	auipc	ra,0x0
    80003c48:	ee2080e7          	jalr	-286(ra) # 80003b26 <itrunc>
    ip->type = 0;
    80003c4c:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003c50:	8526                	mv	a0,s1
    80003c52:	00000097          	auipc	ra,0x0
    80003c56:	cfa080e7          	jalr	-774(ra) # 8000394c <iupdate>
    ip->valid = 0;
    80003c5a:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003c5e:	854a                	mv	a0,s2
    80003c60:	00001097          	auipc	ra,0x1
    80003c64:	ade080e7          	jalr	-1314(ra) # 8000473e <releasesleep>
    acquire(&itable.lock);
    80003c68:	0001c517          	auipc	a0,0x1c
    80003c6c:	f6050513          	addi	a0,a0,-160 # 8001fbc8 <itable>
    80003c70:	ffffd097          	auipc	ra,0xffffd
    80003c74:	faa080e7          	jalr	-86(ra) # 80000c1a <acquire>
    80003c78:	b741                	j	80003bf8 <iput+0x26>

0000000080003c7a <iunlockput>:
{
    80003c7a:	1101                	addi	sp,sp,-32
    80003c7c:	ec06                	sd	ra,24(sp)
    80003c7e:	e822                	sd	s0,16(sp)
    80003c80:	e426                	sd	s1,8(sp)
    80003c82:	1000                	addi	s0,sp,32
    80003c84:	84aa                	mv	s1,a0
  iunlock(ip);
    80003c86:	00000097          	auipc	ra,0x0
    80003c8a:	e54080e7          	jalr	-428(ra) # 80003ada <iunlock>
  iput(ip);
    80003c8e:	8526                	mv	a0,s1
    80003c90:	00000097          	auipc	ra,0x0
    80003c94:	f42080e7          	jalr	-190(ra) # 80003bd2 <iput>
}
    80003c98:	60e2                	ld	ra,24(sp)
    80003c9a:	6442                	ld	s0,16(sp)
    80003c9c:	64a2                	ld	s1,8(sp)
    80003c9e:	6105                	addi	sp,sp,32
    80003ca0:	8082                	ret

0000000080003ca2 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003ca2:	1141                	addi	sp,sp,-16
    80003ca4:	e422                	sd	s0,8(sp)
    80003ca6:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003ca8:	411c                	lw	a5,0(a0)
    80003caa:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003cac:	415c                	lw	a5,4(a0)
    80003cae:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003cb0:	04451783          	lh	a5,68(a0)
    80003cb4:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003cb8:	04a51783          	lh	a5,74(a0)
    80003cbc:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003cc0:	04c56783          	lwu	a5,76(a0)
    80003cc4:	e99c                	sd	a5,16(a1)
}
    80003cc6:	6422                	ld	s0,8(sp)
    80003cc8:	0141                	addi	sp,sp,16
    80003cca:	8082                	ret

0000000080003ccc <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003ccc:	457c                	lw	a5,76(a0)
    80003cce:	0ed7e963          	bltu	a5,a3,80003dc0 <readi+0xf4>
{
    80003cd2:	7159                	addi	sp,sp,-112
    80003cd4:	f486                	sd	ra,104(sp)
    80003cd6:	f0a2                	sd	s0,96(sp)
    80003cd8:	eca6                	sd	s1,88(sp)
    80003cda:	e8ca                	sd	s2,80(sp)
    80003cdc:	e4ce                	sd	s3,72(sp)
    80003cde:	e0d2                	sd	s4,64(sp)
    80003ce0:	fc56                	sd	s5,56(sp)
    80003ce2:	f85a                	sd	s6,48(sp)
    80003ce4:	f45e                	sd	s7,40(sp)
    80003ce6:	f062                	sd	s8,32(sp)
    80003ce8:	ec66                	sd	s9,24(sp)
    80003cea:	e86a                	sd	s10,16(sp)
    80003cec:	e46e                	sd	s11,8(sp)
    80003cee:	1880                	addi	s0,sp,112
    80003cf0:	8baa                	mv	s7,a0
    80003cf2:	8c2e                	mv	s8,a1
    80003cf4:	8ab2                	mv	s5,a2
    80003cf6:	84b6                	mv	s1,a3
    80003cf8:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003cfa:	9f35                	addw	a4,a4,a3
    return 0;
    80003cfc:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003cfe:	0ad76063          	bltu	a4,a3,80003d9e <readi+0xd2>
  if(off + n > ip->size)
    80003d02:	00e7f463          	bgeu	a5,a4,80003d0a <readi+0x3e>
    n = ip->size - off;
    80003d06:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d0a:	0a0b0963          	beqz	s6,80003dbc <readi+0xf0>
    80003d0e:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d10:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003d14:	5cfd                	li	s9,-1
    80003d16:	a82d                	j	80003d50 <readi+0x84>
    80003d18:	020a1d93          	slli	s11,s4,0x20
    80003d1c:	020ddd93          	srli	s11,s11,0x20
    80003d20:	05890613          	addi	a2,s2,88
    80003d24:	86ee                	mv	a3,s11
    80003d26:	963a                	add	a2,a2,a4
    80003d28:	85d6                	mv	a1,s5
    80003d2a:	8562                	mv	a0,s8
    80003d2c:	ffffe097          	auipc	ra,0xffffe
    80003d30:	754080e7          	jalr	1876(ra) # 80002480 <either_copyout>
    80003d34:	05950d63          	beq	a0,s9,80003d8e <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003d38:	854a                	mv	a0,s2
    80003d3a:	fffff097          	auipc	ra,0xfffff
    80003d3e:	60c080e7          	jalr	1548(ra) # 80003346 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d42:	013a09bb          	addw	s3,s4,s3
    80003d46:	009a04bb          	addw	s1,s4,s1
    80003d4a:	9aee                	add	s5,s5,s11
    80003d4c:	0569f763          	bgeu	s3,s6,80003d9a <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003d50:	000ba903          	lw	s2,0(s7)
    80003d54:	00a4d59b          	srliw	a1,s1,0xa
    80003d58:	855e                	mv	a0,s7
    80003d5a:	00000097          	auipc	ra,0x0
    80003d5e:	8ac080e7          	jalr	-1876(ra) # 80003606 <bmap>
    80003d62:	0005059b          	sext.w	a1,a0
    80003d66:	854a                	mv	a0,s2
    80003d68:	fffff097          	auipc	ra,0xfffff
    80003d6c:	4ae080e7          	jalr	1198(ra) # 80003216 <bread>
    80003d70:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d72:	3ff4f713          	andi	a4,s1,1023
    80003d76:	40ed07bb          	subw	a5,s10,a4
    80003d7a:	413b06bb          	subw	a3,s6,s3
    80003d7e:	8a3e                	mv	s4,a5
    80003d80:	2781                	sext.w	a5,a5
    80003d82:	0006861b          	sext.w	a2,a3
    80003d86:	f8f679e3          	bgeu	a2,a5,80003d18 <readi+0x4c>
    80003d8a:	8a36                	mv	s4,a3
    80003d8c:	b771                	j	80003d18 <readi+0x4c>
      brelse(bp);
    80003d8e:	854a                	mv	a0,s2
    80003d90:	fffff097          	auipc	ra,0xfffff
    80003d94:	5b6080e7          	jalr	1462(ra) # 80003346 <brelse>
      tot = -1;
    80003d98:	59fd                	li	s3,-1
  }
  return tot;
    80003d9a:	0009851b          	sext.w	a0,s3
}
    80003d9e:	70a6                	ld	ra,104(sp)
    80003da0:	7406                	ld	s0,96(sp)
    80003da2:	64e6                	ld	s1,88(sp)
    80003da4:	6946                	ld	s2,80(sp)
    80003da6:	69a6                	ld	s3,72(sp)
    80003da8:	6a06                	ld	s4,64(sp)
    80003daa:	7ae2                	ld	s5,56(sp)
    80003dac:	7b42                	ld	s6,48(sp)
    80003dae:	7ba2                	ld	s7,40(sp)
    80003db0:	7c02                	ld	s8,32(sp)
    80003db2:	6ce2                	ld	s9,24(sp)
    80003db4:	6d42                	ld	s10,16(sp)
    80003db6:	6da2                	ld	s11,8(sp)
    80003db8:	6165                	addi	sp,sp,112
    80003dba:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003dbc:	89da                	mv	s3,s6
    80003dbe:	bff1                	j	80003d9a <readi+0xce>
    return 0;
    80003dc0:	4501                	li	a0,0
}
    80003dc2:	8082                	ret

0000000080003dc4 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003dc4:	457c                	lw	a5,76(a0)
    80003dc6:	10d7e863          	bltu	a5,a3,80003ed6 <writei+0x112>
{
    80003dca:	7159                	addi	sp,sp,-112
    80003dcc:	f486                	sd	ra,104(sp)
    80003dce:	f0a2                	sd	s0,96(sp)
    80003dd0:	eca6                	sd	s1,88(sp)
    80003dd2:	e8ca                	sd	s2,80(sp)
    80003dd4:	e4ce                	sd	s3,72(sp)
    80003dd6:	e0d2                	sd	s4,64(sp)
    80003dd8:	fc56                	sd	s5,56(sp)
    80003dda:	f85a                	sd	s6,48(sp)
    80003ddc:	f45e                	sd	s7,40(sp)
    80003dde:	f062                	sd	s8,32(sp)
    80003de0:	ec66                	sd	s9,24(sp)
    80003de2:	e86a                	sd	s10,16(sp)
    80003de4:	e46e                	sd	s11,8(sp)
    80003de6:	1880                	addi	s0,sp,112
    80003de8:	8b2a                	mv	s6,a0
    80003dea:	8c2e                	mv	s8,a1
    80003dec:	8ab2                	mv	s5,a2
    80003dee:	8936                	mv	s2,a3
    80003df0:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003df2:	00e687bb          	addw	a5,a3,a4
    80003df6:	0ed7e263          	bltu	a5,a3,80003eda <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003dfa:	00043737          	lui	a4,0x43
    80003dfe:	0ef76063          	bltu	a4,a5,80003ede <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e02:	0c0b8863          	beqz	s7,80003ed2 <writei+0x10e>
    80003e06:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e08:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003e0c:	5cfd                	li	s9,-1
    80003e0e:	a091                	j	80003e52 <writei+0x8e>
    80003e10:	02099d93          	slli	s11,s3,0x20
    80003e14:	020ddd93          	srli	s11,s11,0x20
    80003e18:	05848513          	addi	a0,s1,88
    80003e1c:	86ee                	mv	a3,s11
    80003e1e:	8656                	mv	a2,s5
    80003e20:	85e2                	mv	a1,s8
    80003e22:	953a                	add	a0,a0,a4
    80003e24:	ffffe097          	auipc	ra,0xffffe
    80003e28:	6b2080e7          	jalr	1714(ra) # 800024d6 <either_copyin>
    80003e2c:	07950263          	beq	a0,s9,80003e90 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003e30:	8526                	mv	a0,s1
    80003e32:	00000097          	auipc	ra,0x0
    80003e36:	798080e7          	jalr	1944(ra) # 800045ca <log_write>
    brelse(bp);
    80003e3a:	8526                	mv	a0,s1
    80003e3c:	fffff097          	auipc	ra,0xfffff
    80003e40:	50a080e7          	jalr	1290(ra) # 80003346 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e44:	01498a3b          	addw	s4,s3,s4
    80003e48:	0129893b          	addw	s2,s3,s2
    80003e4c:	9aee                	add	s5,s5,s11
    80003e4e:	057a7663          	bgeu	s4,s7,80003e9a <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003e52:	000b2483          	lw	s1,0(s6)
    80003e56:	00a9559b          	srliw	a1,s2,0xa
    80003e5a:	855a                	mv	a0,s6
    80003e5c:	fffff097          	auipc	ra,0xfffff
    80003e60:	7aa080e7          	jalr	1962(ra) # 80003606 <bmap>
    80003e64:	0005059b          	sext.w	a1,a0
    80003e68:	8526                	mv	a0,s1
    80003e6a:	fffff097          	auipc	ra,0xfffff
    80003e6e:	3ac080e7          	jalr	940(ra) # 80003216 <bread>
    80003e72:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e74:	3ff97713          	andi	a4,s2,1023
    80003e78:	40ed07bb          	subw	a5,s10,a4
    80003e7c:	414b86bb          	subw	a3,s7,s4
    80003e80:	89be                	mv	s3,a5
    80003e82:	2781                	sext.w	a5,a5
    80003e84:	0006861b          	sext.w	a2,a3
    80003e88:	f8f674e3          	bgeu	a2,a5,80003e10 <writei+0x4c>
    80003e8c:	89b6                	mv	s3,a3
    80003e8e:	b749                	j	80003e10 <writei+0x4c>
      brelse(bp);
    80003e90:	8526                	mv	a0,s1
    80003e92:	fffff097          	auipc	ra,0xfffff
    80003e96:	4b4080e7          	jalr	1204(ra) # 80003346 <brelse>
  }

  if(off > ip->size)
    80003e9a:	04cb2783          	lw	a5,76(s6)
    80003e9e:	0127f463          	bgeu	a5,s2,80003ea6 <writei+0xe2>
    ip->size = off;
    80003ea2:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003ea6:	855a                	mv	a0,s6
    80003ea8:	00000097          	auipc	ra,0x0
    80003eac:	aa4080e7          	jalr	-1372(ra) # 8000394c <iupdate>

  return tot;
    80003eb0:	000a051b          	sext.w	a0,s4
}
    80003eb4:	70a6                	ld	ra,104(sp)
    80003eb6:	7406                	ld	s0,96(sp)
    80003eb8:	64e6                	ld	s1,88(sp)
    80003eba:	6946                	ld	s2,80(sp)
    80003ebc:	69a6                	ld	s3,72(sp)
    80003ebe:	6a06                	ld	s4,64(sp)
    80003ec0:	7ae2                	ld	s5,56(sp)
    80003ec2:	7b42                	ld	s6,48(sp)
    80003ec4:	7ba2                	ld	s7,40(sp)
    80003ec6:	7c02                	ld	s8,32(sp)
    80003ec8:	6ce2                	ld	s9,24(sp)
    80003eca:	6d42                	ld	s10,16(sp)
    80003ecc:	6da2                	ld	s11,8(sp)
    80003ece:	6165                	addi	sp,sp,112
    80003ed0:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ed2:	8a5e                	mv	s4,s7
    80003ed4:	bfc9                	j	80003ea6 <writei+0xe2>
    return -1;
    80003ed6:	557d                	li	a0,-1
}
    80003ed8:	8082                	ret
    return -1;
    80003eda:	557d                	li	a0,-1
    80003edc:	bfe1                	j	80003eb4 <writei+0xf0>
    return -1;
    80003ede:	557d                	li	a0,-1
    80003ee0:	bfd1                	j	80003eb4 <writei+0xf0>

0000000080003ee2 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003ee2:	1141                	addi	sp,sp,-16
    80003ee4:	e406                	sd	ra,8(sp)
    80003ee6:	e022                	sd	s0,0(sp)
    80003ee8:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003eea:	4639                	li	a2,14
    80003eec:	ffffd097          	auipc	ra,0xffffd
    80003ef0:	efa080e7          	jalr	-262(ra) # 80000de6 <strncmp>
}
    80003ef4:	60a2                	ld	ra,8(sp)
    80003ef6:	6402                	ld	s0,0(sp)
    80003ef8:	0141                	addi	sp,sp,16
    80003efa:	8082                	ret

0000000080003efc <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003efc:	7139                	addi	sp,sp,-64
    80003efe:	fc06                	sd	ra,56(sp)
    80003f00:	f822                	sd	s0,48(sp)
    80003f02:	f426                	sd	s1,40(sp)
    80003f04:	f04a                	sd	s2,32(sp)
    80003f06:	ec4e                	sd	s3,24(sp)
    80003f08:	e852                	sd	s4,16(sp)
    80003f0a:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003f0c:	04451703          	lh	a4,68(a0)
    80003f10:	4785                	li	a5,1
    80003f12:	00f71a63          	bne	a4,a5,80003f26 <dirlookup+0x2a>
    80003f16:	892a                	mv	s2,a0
    80003f18:	89ae                	mv	s3,a1
    80003f1a:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f1c:	457c                	lw	a5,76(a0)
    80003f1e:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003f20:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f22:	e79d                	bnez	a5,80003f50 <dirlookup+0x54>
    80003f24:	a8a5                	j	80003f9c <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003f26:	00004517          	auipc	a0,0x4
    80003f2a:	72250513          	addi	a0,a0,1826 # 80008648 <syscalls+0x1d0>
    80003f2e:	ffffc097          	auipc	ra,0xffffc
    80003f32:	60c080e7          	jalr	1548(ra) # 8000053a <panic>
      panic("dirlookup read");
    80003f36:	00004517          	auipc	a0,0x4
    80003f3a:	72a50513          	addi	a0,a0,1834 # 80008660 <syscalls+0x1e8>
    80003f3e:	ffffc097          	auipc	ra,0xffffc
    80003f42:	5fc080e7          	jalr	1532(ra) # 8000053a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f46:	24c1                	addiw	s1,s1,16
    80003f48:	04c92783          	lw	a5,76(s2)
    80003f4c:	04f4f763          	bgeu	s1,a5,80003f9a <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f50:	4741                	li	a4,16
    80003f52:	86a6                	mv	a3,s1
    80003f54:	fc040613          	addi	a2,s0,-64
    80003f58:	4581                	li	a1,0
    80003f5a:	854a                	mv	a0,s2
    80003f5c:	00000097          	auipc	ra,0x0
    80003f60:	d70080e7          	jalr	-656(ra) # 80003ccc <readi>
    80003f64:	47c1                	li	a5,16
    80003f66:	fcf518e3          	bne	a0,a5,80003f36 <dirlookup+0x3a>
    if(de.inum == 0)
    80003f6a:	fc045783          	lhu	a5,-64(s0)
    80003f6e:	dfe1                	beqz	a5,80003f46 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003f70:	fc240593          	addi	a1,s0,-62
    80003f74:	854e                	mv	a0,s3
    80003f76:	00000097          	auipc	ra,0x0
    80003f7a:	f6c080e7          	jalr	-148(ra) # 80003ee2 <namecmp>
    80003f7e:	f561                	bnez	a0,80003f46 <dirlookup+0x4a>
      if(poff)
    80003f80:	000a0463          	beqz	s4,80003f88 <dirlookup+0x8c>
        *poff = off;
    80003f84:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003f88:	fc045583          	lhu	a1,-64(s0)
    80003f8c:	00092503          	lw	a0,0(s2)
    80003f90:	fffff097          	auipc	ra,0xfffff
    80003f94:	752080e7          	jalr	1874(ra) # 800036e2 <iget>
    80003f98:	a011                	j	80003f9c <dirlookup+0xa0>
  return 0;
    80003f9a:	4501                	li	a0,0
}
    80003f9c:	70e2                	ld	ra,56(sp)
    80003f9e:	7442                	ld	s0,48(sp)
    80003fa0:	74a2                	ld	s1,40(sp)
    80003fa2:	7902                	ld	s2,32(sp)
    80003fa4:	69e2                	ld	s3,24(sp)
    80003fa6:	6a42                	ld	s4,16(sp)
    80003fa8:	6121                	addi	sp,sp,64
    80003faa:	8082                	ret

0000000080003fac <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003fac:	711d                	addi	sp,sp,-96
    80003fae:	ec86                	sd	ra,88(sp)
    80003fb0:	e8a2                	sd	s0,80(sp)
    80003fb2:	e4a6                	sd	s1,72(sp)
    80003fb4:	e0ca                	sd	s2,64(sp)
    80003fb6:	fc4e                	sd	s3,56(sp)
    80003fb8:	f852                	sd	s4,48(sp)
    80003fba:	f456                	sd	s5,40(sp)
    80003fbc:	f05a                	sd	s6,32(sp)
    80003fbe:	ec5e                	sd	s7,24(sp)
    80003fc0:	e862                	sd	s8,16(sp)
    80003fc2:	e466                	sd	s9,8(sp)
    80003fc4:	e06a                	sd	s10,0(sp)
    80003fc6:	1080                	addi	s0,sp,96
    80003fc8:	84aa                	mv	s1,a0
    80003fca:	8b2e                	mv	s6,a1
    80003fcc:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003fce:	00054703          	lbu	a4,0(a0)
    80003fd2:	02f00793          	li	a5,47
    80003fd6:	02f70363          	beq	a4,a5,80003ffc <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003fda:	ffffe097          	auipc	ra,0xffffe
    80003fde:	9ec080e7          	jalr	-1556(ra) # 800019c6 <myproc>
    80003fe2:	16053503          	ld	a0,352(a0)
    80003fe6:	00000097          	auipc	ra,0x0
    80003fea:	9f4080e7          	jalr	-1548(ra) # 800039da <idup>
    80003fee:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003ff0:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003ff4:	4cb5                	li	s9,13
  len = path - s;
    80003ff6:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003ff8:	4c05                	li	s8,1
    80003ffa:	a87d                	j	800040b8 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80003ffc:	4585                	li	a1,1
    80003ffe:	4505                	li	a0,1
    80004000:	fffff097          	auipc	ra,0xfffff
    80004004:	6e2080e7          	jalr	1762(ra) # 800036e2 <iget>
    80004008:	8a2a                	mv	s4,a0
    8000400a:	b7dd                	j	80003ff0 <namex+0x44>
      iunlockput(ip);
    8000400c:	8552                	mv	a0,s4
    8000400e:	00000097          	auipc	ra,0x0
    80004012:	c6c080e7          	jalr	-916(ra) # 80003c7a <iunlockput>
      return 0;
    80004016:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004018:	8552                	mv	a0,s4
    8000401a:	60e6                	ld	ra,88(sp)
    8000401c:	6446                	ld	s0,80(sp)
    8000401e:	64a6                	ld	s1,72(sp)
    80004020:	6906                	ld	s2,64(sp)
    80004022:	79e2                	ld	s3,56(sp)
    80004024:	7a42                	ld	s4,48(sp)
    80004026:	7aa2                	ld	s5,40(sp)
    80004028:	7b02                	ld	s6,32(sp)
    8000402a:	6be2                	ld	s7,24(sp)
    8000402c:	6c42                	ld	s8,16(sp)
    8000402e:	6ca2                	ld	s9,8(sp)
    80004030:	6d02                	ld	s10,0(sp)
    80004032:	6125                	addi	sp,sp,96
    80004034:	8082                	ret
      iunlock(ip);
    80004036:	8552                	mv	a0,s4
    80004038:	00000097          	auipc	ra,0x0
    8000403c:	aa2080e7          	jalr	-1374(ra) # 80003ada <iunlock>
      return ip;
    80004040:	bfe1                	j	80004018 <namex+0x6c>
      iunlockput(ip);
    80004042:	8552                	mv	a0,s4
    80004044:	00000097          	auipc	ra,0x0
    80004048:	c36080e7          	jalr	-970(ra) # 80003c7a <iunlockput>
      return 0;
    8000404c:	8a4e                	mv	s4,s3
    8000404e:	b7e9                	j	80004018 <namex+0x6c>
  len = path - s;
    80004050:	40998633          	sub	a2,s3,s1
    80004054:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80004058:	09acd863          	bge	s9,s10,800040e8 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    8000405c:	4639                	li	a2,14
    8000405e:	85a6                	mv	a1,s1
    80004060:	8556                	mv	a0,s5
    80004062:	ffffd097          	auipc	ra,0xffffd
    80004066:	d10080e7          	jalr	-752(ra) # 80000d72 <memmove>
    8000406a:	84ce                	mv	s1,s3
  while(*path == '/')
    8000406c:	0004c783          	lbu	a5,0(s1)
    80004070:	01279763          	bne	a5,s2,8000407e <namex+0xd2>
    path++;
    80004074:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004076:	0004c783          	lbu	a5,0(s1)
    8000407a:	ff278de3          	beq	a5,s2,80004074 <namex+0xc8>
    ilock(ip);
    8000407e:	8552                	mv	a0,s4
    80004080:	00000097          	auipc	ra,0x0
    80004084:	998080e7          	jalr	-1640(ra) # 80003a18 <ilock>
    if(ip->type != T_DIR){
    80004088:	044a1783          	lh	a5,68(s4)
    8000408c:	f98790e3          	bne	a5,s8,8000400c <namex+0x60>
    if(nameiparent && *path == '\0'){
    80004090:	000b0563          	beqz	s6,8000409a <namex+0xee>
    80004094:	0004c783          	lbu	a5,0(s1)
    80004098:	dfd9                	beqz	a5,80004036 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000409a:	865e                	mv	a2,s7
    8000409c:	85d6                	mv	a1,s5
    8000409e:	8552                	mv	a0,s4
    800040a0:	00000097          	auipc	ra,0x0
    800040a4:	e5c080e7          	jalr	-420(ra) # 80003efc <dirlookup>
    800040a8:	89aa                	mv	s3,a0
    800040aa:	dd41                	beqz	a0,80004042 <namex+0x96>
    iunlockput(ip);
    800040ac:	8552                	mv	a0,s4
    800040ae:	00000097          	auipc	ra,0x0
    800040b2:	bcc080e7          	jalr	-1076(ra) # 80003c7a <iunlockput>
    ip = next;
    800040b6:	8a4e                	mv	s4,s3
  while(*path == '/')
    800040b8:	0004c783          	lbu	a5,0(s1)
    800040bc:	01279763          	bne	a5,s2,800040ca <namex+0x11e>
    path++;
    800040c0:	0485                	addi	s1,s1,1
  while(*path == '/')
    800040c2:	0004c783          	lbu	a5,0(s1)
    800040c6:	ff278de3          	beq	a5,s2,800040c0 <namex+0x114>
  if(*path == 0)
    800040ca:	cb9d                	beqz	a5,80004100 <namex+0x154>
  while(*path != '/' && *path != 0)
    800040cc:	0004c783          	lbu	a5,0(s1)
    800040d0:	89a6                	mv	s3,s1
  len = path - s;
    800040d2:	8d5e                	mv	s10,s7
    800040d4:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    800040d6:	01278963          	beq	a5,s2,800040e8 <namex+0x13c>
    800040da:	dbbd                	beqz	a5,80004050 <namex+0xa4>
    path++;
    800040dc:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800040de:	0009c783          	lbu	a5,0(s3)
    800040e2:	ff279ce3          	bne	a5,s2,800040da <namex+0x12e>
    800040e6:	b7ad                	j	80004050 <namex+0xa4>
    memmove(name, s, len);
    800040e8:	2601                	sext.w	a2,a2
    800040ea:	85a6                	mv	a1,s1
    800040ec:	8556                	mv	a0,s5
    800040ee:	ffffd097          	auipc	ra,0xffffd
    800040f2:	c84080e7          	jalr	-892(ra) # 80000d72 <memmove>
    name[len] = 0;
    800040f6:	9d56                	add	s10,s10,s5
    800040f8:	000d0023          	sb	zero,0(s10)
    800040fc:	84ce                	mv	s1,s3
    800040fe:	b7bd                	j	8000406c <namex+0xc0>
  if(nameiparent){
    80004100:	f00b0ce3          	beqz	s6,80004018 <namex+0x6c>
    iput(ip);
    80004104:	8552                	mv	a0,s4
    80004106:	00000097          	auipc	ra,0x0
    8000410a:	acc080e7          	jalr	-1332(ra) # 80003bd2 <iput>
    return 0;
    8000410e:	4a01                	li	s4,0
    80004110:	b721                	j	80004018 <namex+0x6c>

0000000080004112 <dirlink>:
{
    80004112:	7139                	addi	sp,sp,-64
    80004114:	fc06                	sd	ra,56(sp)
    80004116:	f822                	sd	s0,48(sp)
    80004118:	f426                	sd	s1,40(sp)
    8000411a:	f04a                	sd	s2,32(sp)
    8000411c:	ec4e                	sd	s3,24(sp)
    8000411e:	e852                	sd	s4,16(sp)
    80004120:	0080                	addi	s0,sp,64
    80004122:	892a                	mv	s2,a0
    80004124:	8a2e                	mv	s4,a1
    80004126:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004128:	4601                	li	a2,0
    8000412a:	00000097          	auipc	ra,0x0
    8000412e:	dd2080e7          	jalr	-558(ra) # 80003efc <dirlookup>
    80004132:	e93d                	bnez	a0,800041a8 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004134:	04c92483          	lw	s1,76(s2)
    80004138:	c49d                	beqz	s1,80004166 <dirlink+0x54>
    8000413a:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000413c:	4741                	li	a4,16
    8000413e:	86a6                	mv	a3,s1
    80004140:	fc040613          	addi	a2,s0,-64
    80004144:	4581                	li	a1,0
    80004146:	854a                	mv	a0,s2
    80004148:	00000097          	auipc	ra,0x0
    8000414c:	b84080e7          	jalr	-1148(ra) # 80003ccc <readi>
    80004150:	47c1                	li	a5,16
    80004152:	06f51163          	bne	a0,a5,800041b4 <dirlink+0xa2>
    if(de.inum == 0)
    80004156:	fc045783          	lhu	a5,-64(s0)
    8000415a:	c791                	beqz	a5,80004166 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000415c:	24c1                	addiw	s1,s1,16
    8000415e:	04c92783          	lw	a5,76(s2)
    80004162:	fcf4ede3          	bltu	s1,a5,8000413c <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004166:	4639                	li	a2,14
    80004168:	85d2                	mv	a1,s4
    8000416a:	fc240513          	addi	a0,s0,-62
    8000416e:	ffffd097          	auipc	ra,0xffffd
    80004172:	cb4080e7          	jalr	-844(ra) # 80000e22 <strncpy>
  de.inum = inum;
    80004176:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000417a:	4741                	li	a4,16
    8000417c:	86a6                	mv	a3,s1
    8000417e:	fc040613          	addi	a2,s0,-64
    80004182:	4581                	li	a1,0
    80004184:	854a                	mv	a0,s2
    80004186:	00000097          	auipc	ra,0x0
    8000418a:	c3e080e7          	jalr	-962(ra) # 80003dc4 <writei>
    8000418e:	872a                	mv	a4,a0
    80004190:	47c1                	li	a5,16
  return 0;
    80004192:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004194:	02f71863          	bne	a4,a5,800041c4 <dirlink+0xb2>
}
    80004198:	70e2                	ld	ra,56(sp)
    8000419a:	7442                	ld	s0,48(sp)
    8000419c:	74a2                	ld	s1,40(sp)
    8000419e:	7902                	ld	s2,32(sp)
    800041a0:	69e2                	ld	s3,24(sp)
    800041a2:	6a42                	ld	s4,16(sp)
    800041a4:	6121                	addi	sp,sp,64
    800041a6:	8082                	ret
    iput(ip);
    800041a8:	00000097          	auipc	ra,0x0
    800041ac:	a2a080e7          	jalr	-1494(ra) # 80003bd2 <iput>
    return -1;
    800041b0:	557d                	li	a0,-1
    800041b2:	b7dd                	j	80004198 <dirlink+0x86>
      panic("dirlink read");
    800041b4:	00004517          	auipc	a0,0x4
    800041b8:	4bc50513          	addi	a0,a0,1212 # 80008670 <syscalls+0x1f8>
    800041bc:	ffffc097          	auipc	ra,0xffffc
    800041c0:	37e080e7          	jalr	894(ra) # 8000053a <panic>
    panic("dirlink");
    800041c4:	00004517          	auipc	a0,0x4
    800041c8:	5bc50513          	addi	a0,a0,1468 # 80008780 <syscalls+0x308>
    800041cc:	ffffc097          	auipc	ra,0xffffc
    800041d0:	36e080e7          	jalr	878(ra) # 8000053a <panic>

00000000800041d4 <namei>:

struct inode*
namei(char *path)
{
    800041d4:	1101                	addi	sp,sp,-32
    800041d6:	ec06                	sd	ra,24(sp)
    800041d8:	e822                	sd	s0,16(sp)
    800041da:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800041dc:	fe040613          	addi	a2,s0,-32
    800041e0:	4581                	li	a1,0
    800041e2:	00000097          	auipc	ra,0x0
    800041e6:	dca080e7          	jalr	-566(ra) # 80003fac <namex>
}
    800041ea:	60e2                	ld	ra,24(sp)
    800041ec:	6442                	ld	s0,16(sp)
    800041ee:	6105                	addi	sp,sp,32
    800041f0:	8082                	ret

00000000800041f2 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800041f2:	1141                	addi	sp,sp,-16
    800041f4:	e406                	sd	ra,8(sp)
    800041f6:	e022                	sd	s0,0(sp)
    800041f8:	0800                	addi	s0,sp,16
    800041fa:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800041fc:	4585                	li	a1,1
    800041fe:	00000097          	auipc	ra,0x0
    80004202:	dae080e7          	jalr	-594(ra) # 80003fac <namex>
}
    80004206:	60a2                	ld	ra,8(sp)
    80004208:	6402                	ld	s0,0(sp)
    8000420a:	0141                	addi	sp,sp,16
    8000420c:	8082                	ret

000000008000420e <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000420e:	1101                	addi	sp,sp,-32
    80004210:	ec06                	sd	ra,24(sp)
    80004212:	e822                	sd	s0,16(sp)
    80004214:	e426                	sd	s1,8(sp)
    80004216:	e04a                	sd	s2,0(sp)
    80004218:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000421a:	0001d917          	auipc	s2,0x1d
    8000421e:	45690913          	addi	s2,s2,1110 # 80021670 <log>
    80004222:	01892583          	lw	a1,24(s2)
    80004226:	02892503          	lw	a0,40(s2)
    8000422a:	fffff097          	auipc	ra,0xfffff
    8000422e:	fec080e7          	jalr	-20(ra) # 80003216 <bread>
    80004232:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004234:	02c92683          	lw	a3,44(s2)
    80004238:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000423a:	02d05863          	blez	a3,8000426a <write_head+0x5c>
    8000423e:	0001d797          	auipc	a5,0x1d
    80004242:	46278793          	addi	a5,a5,1122 # 800216a0 <log+0x30>
    80004246:	05c50713          	addi	a4,a0,92
    8000424a:	36fd                	addiw	a3,a3,-1
    8000424c:	02069613          	slli	a2,a3,0x20
    80004250:	01e65693          	srli	a3,a2,0x1e
    80004254:	0001d617          	auipc	a2,0x1d
    80004258:	45060613          	addi	a2,a2,1104 # 800216a4 <log+0x34>
    8000425c:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    8000425e:	4390                	lw	a2,0(a5)
    80004260:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004262:	0791                	addi	a5,a5,4
    80004264:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80004266:	fed79ce3          	bne	a5,a3,8000425e <write_head+0x50>
  }
  bwrite(buf);
    8000426a:	8526                	mv	a0,s1
    8000426c:	fffff097          	auipc	ra,0xfffff
    80004270:	09c080e7          	jalr	156(ra) # 80003308 <bwrite>
  brelse(buf);
    80004274:	8526                	mv	a0,s1
    80004276:	fffff097          	auipc	ra,0xfffff
    8000427a:	0d0080e7          	jalr	208(ra) # 80003346 <brelse>
}
    8000427e:	60e2                	ld	ra,24(sp)
    80004280:	6442                	ld	s0,16(sp)
    80004282:	64a2                	ld	s1,8(sp)
    80004284:	6902                	ld	s2,0(sp)
    80004286:	6105                	addi	sp,sp,32
    80004288:	8082                	ret

000000008000428a <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000428a:	0001d797          	auipc	a5,0x1d
    8000428e:	4127a783          	lw	a5,1042(a5) # 8002169c <log+0x2c>
    80004292:	0af05d63          	blez	a5,8000434c <install_trans+0xc2>
{
    80004296:	7139                	addi	sp,sp,-64
    80004298:	fc06                	sd	ra,56(sp)
    8000429a:	f822                	sd	s0,48(sp)
    8000429c:	f426                	sd	s1,40(sp)
    8000429e:	f04a                	sd	s2,32(sp)
    800042a0:	ec4e                	sd	s3,24(sp)
    800042a2:	e852                	sd	s4,16(sp)
    800042a4:	e456                	sd	s5,8(sp)
    800042a6:	e05a                	sd	s6,0(sp)
    800042a8:	0080                	addi	s0,sp,64
    800042aa:	8b2a                	mv	s6,a0
    800042ac:	0001da97          	auipc	s5,0x1d
    800042b0:	3f4a8a93          	addi	s5,s5,1012 # 800216a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800042b4:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800042b6:	0001d997          	auipc	s3,0x1d
    800042ba:	3ba98993          	addi	s3,s3,954 # 80021670 <log>
    800042be:	a00d                	j	800042e0 <install_trans+0x56>
    brelse(lbuf);
    800042c0:	854a                	mv	a0,s2
    800042c2:	fffff097          	auipc	ra,0xfffff
    800042c6:	084080e7          	jalr	132(ra) # 80003346 <brelse>
    brelse(dbuf);
    800042ca:	8526                	mv	a0,s1
    800042cc:	fffff097          	auipc	ra,0xfffff
    800042d0:	07a080e7          	jalr	122(ra) # 80003346 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800042d4:	2a05                	addiw	s4,s4,1
    800042d6:	0a91                	addi	s5,s5,4
    800042d8:	02c9a783          	lw	a5,44(s3)
    800042dc:	04fa5e63          	bge	s4,a5,80004338 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800042e0:	0189a583          	lw	a1,24(s3)
    800042e4:	014585bb          	addw	a1,a1,s4
    800042e8:	2585                	addiw	a1,a1,1
    800042ea:	0289a503          	lw	a0,40(s3)
    800042ee:	fffff097          	auipc	ra,0xfffff
    800042f2:	f28080e7          	jalr	-216(ra) # 80003216 <bread>
    800042f6:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800042f8:	000aa583          	lw	a1,0(s5)
    800042fc:	0289a503          	lw	a0,40(s3)
    80004300:	fffff097          	auipc	ra,0xfffff
    80004304:	f16080e7          	jalr	-234(ra) # 80003216 <bread>
    80004308:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000430a:	40000613          	li	a2,1024
    8000430e:	05890593          	addi	a1,s2,88
    80004312:	05850513          	addi	a0,a0,88
    80004316:	ffffd097          	auipc	ra,0xffffd
    8000431a:	a5c080e7          	jalr	-1444(ra) # 80000d72 <memmove>
    bwrite(dbuf);  // write dst to disk
    8000431e:	8526                	mv	a0,s1
    80004320:	fffff097          	auipc	ra,0xfffff
    80004324:	fe8080e7          	jalr	-24(ra) # 80003308 <bwrite>
    if(recovering == 0)
    80004328:	f80b1ce3          	bnez	s6,800042c0 <install_trans+0x36>
      bunpin(dbuf);
    8000432c:	8526                	mv	a0,s1
    8000432e:	fffff097          	auipc	ra,0xfffff
    80004332:	0f2080e7          	jalr	242(ra) # 80003420 <bunpin>
    80004336:	b769                	j	800042c0 <install_trans+0x36>
}
    80004338:	70e2                	ld	ra,56(sp)
    8000433a:	7442                	ld	s0,48(sp)
    8000433c:	74a2                	ld	s1,40(sp)
    8000433e:	7902                	ld	s2,32(sp)
    80004340:	69e2                	ld	s3,24(sp)
    80004342:	6a42                	ld	s4,16(sp)
    80004344:	6aa2                	ld	s5,8(sp)
    80004346:	6b02                	ld	s6,0(sp)
    80004348:	6121                	addi	sp,sp,64
    8000434a:	8082                	ret
    8000434c:	8082                	ret

000000008000434e <initlog>:
{
    8000434e:	7179                	addi	sp,sp,-48
    80004350:	f406                	sd	ra,40(sp)
    80004352:	f022                	sd	s0,32(sp)
    80004354:	ec26                	sd	s1,24(sp)
    80004356:	e84a                	sd	s2,16(sp)
    80004358:	e44e                	sd	s3,8(sp)
    8000435a:	1800                	addi	s0,sp,48
    8000435c:	892a                	mv	s2,a0
    8000435e:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004360:	0001d497          	auipc	s1,0x1d
    80004364:	31048493          	addi	s1,s1,784 # 80021670 <log>
    80004368:	00004597          	auipc	a1,0x4
    8000436c:	31858593          	addi	a1,a1,792 # 80008680 <syscalls+0x208>
    80004370:	8526                	mv	a0,s1
    80004372:	ffffd097          	auipc	ra,0xffffd
    80004376:	818080e7          	jalr	-2024(ra) # 80000b8a <initlock>
  log.start = sb->logstart;
    8000437a:	0149a583          	lw	a1,20(s3)
    8000437e:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004380:	0109a783          	lw	a5,16(s3)
    80004384:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004386:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000438a:	854a                	mv	a0,s2
    8000438c:	fffff097          	auipc	ra,0xfffff
    80004390:	e8a080e7          	jalr	-374(ra) # 80003216 <bread>
  log.lh.n = lh->n;
    80004394:	4d34                	lw	a3,88(a0)
    80004396:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004398:	02d05663          	blez	a3,800043c4 <initlog+0x76>
    8000439c:	05c50793          	addi	a5,a0,92
    800043a0:	0001d717          	auipc	a4,0x1d
    800043a4:	30070713          	addi	a4,a4,768 # 800216a0 <log+0x30>
    800043a8:	36fd                	addiw	a3,a3,-1
    800043aa:	02069613          	slli	a2,a3,0x20
    800043ae:	01e65693          	srli	a3,a2,0x1e
    800043b2:	06050613          	addi	a2,a0,96
    800043b6:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800043b8:	4390                	lw	a2,0(a5)
    800043ba:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800043bc:	0791                	addi	a5,a5,4
    800043be:	0711                	addi	a4,a4,4
    800043c0:	fed79ce3          	bne	a5,a3,800043b8 <initlog+0x6a>
  brelse(buf);
    800043c4:	fffff097          	auipc	ra,0xfffff
    800043c8:	f82080e7          	jalr	-126(ra) # 80003346 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800043cc:	4505                	li	a0,1
    800043ce:	00000097          	auipc	ra,0x0
    800043d2:	ebc080e7          	jalr	-324(ra) # 8000428a <install_trans>
  log.lh.n = 0;
    800043d6:	0001d797          	auipc	a5,0x1d
    800043da:	2c07a323          	sw	zero,710(a5) # 8002169c <log+0x2c>
  write_head(); // clear the log
    800043de:	00000097          	auipc	ra,0x0
    800043e2:	e30080e7          	jalr	-464(ra) # 8000420e <write_head>
}
    800043e6:	70a2                	ld	ra,40(sp)
    800043e8:	7402                	ld	s0,32(sp)
    800043ea:	64e2                	ld	s1,24(sp)
    800043ec:	6942                	ld	s2,16(sp)
    800043ee:	69a2                	ld	s3,8(sp)
    800043f0:	6145                	addi	sp,sp,48
    800043f2:	8082                	ret

00000000800043f4 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800043f4:	1101                	addi	sp,sp,-32
    800043f6:	ec06                	sd	ra,24(sp)
    800043f8:	e822                	sd	s0,16(sp)
    800043fa:	e426                	sd	s1,8(sp)
    800043fc:	e04a                	sd	s2,0(sp)
    800043fe:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004400:	0001d517          	auipc	a0,0x1d
    80004404:	27050513          	addi	a0,a0,624 # 80021670 <log>
    80004408:	ffffd097          	auipc	ra,0xffffd
    8000440c:	812080e7          	jalr	-2030(ra) # 80000c1a <acquire>
  while(1){
    if(log.committing){
    80004410:	0001d497          	auipc	s1,0x1d
    80004414:	26048493          	addi	s1,s1,608 # 80021670 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004418:	4979                	li	s2,30
    8000441a:	a039                	j	80004428 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000441c:	85a6                	mv	a1,s1
    8000441e:	8526                	mv	a0,s1
    80004420:	ffffe097          	auipc	ra,0xffffe
    80004424:	cb2080e7          	jalr	-846(ra) # 800020d2 <sleep>
    if(log.committing){
    80004428:	50dc                	lw	a5,36(s1)
    8000442a:	fbed                	bnez	a5,8000441c <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000442c:	5098                	lw	a4,32(s1)
    8000442e:	2705                	addiw	a4,a4,1
    80004430:	0007069b          	sext.w	a3,a4
    80004434:	0027179b          	slliw	a5,a4,0x2
    80004438:	9fb9                	addw	a5,a5,a4
    8000443a:	0017979b          	slliw	a5,a5,0x1
    8000443e:	54d8                	lw	a4,44(s1)
    80004440:	9fb9                	addw	a5,a5,a4
    80004442:	00f95963          	bge	s2,a5,80004454 <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004446:	85a6                	mv	a1,s1
    80004448:	8526                	mv	a0,s1
    8000444a:	ffffe097          	auipc	ra,0xffffe
    8000444e:	c88080e7          	jalr	-888(ra) # 800020d2 <sleep>
    80004452:	bfd9                	j	80004428 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004454:	0001d517          	auipc	a0,0x1d
    80004458:	21c50513          	addi	a0,a0,540 # 80021670 <log>
    8000445c:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000445e:	ffffd097          	auipc	ra,0xffffd
    80004462:	870080e7          	jalr	-1936(ra) # 80000cce <release>
      break;
    }
  }
}
    80004466:	60e2                	ld	ra,24(sp)
    80004468:	6442                	ld	s0,16(sp)
    8000446a:	64a2                	ld	s1,8(sp)
    8000446c:	6902                	ld	s2,0(sp)
    8000446e:	6105                	addi	sp,sp,32
    80004470:	8082                	ret

0000000080004472 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004472:	7139                	addi	sp,sp,-64
    80004474:	fc06                	sd	ra,56(sp)
    80004476:	f822                	sd	s0,48(sp)
    80004478:	f426                	sd	s1,40(sp)
    8000447a:	f04a                	sd	s2,32(sp)
    8000447c:	ec4e                	sd	s3,24(sp)
    8000447e:	e852                	sd	s4,16(sp)
    80004480:	e456                	sd	s5,8(sp)
    80004482:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004484:	0001d497          	auipc	s1,0x1d
    80004488:	1ec48493          	addi	s1,s1,492 # 80021670 <log>
    8000448c:	8526                	mv	a0,s1
    8000448e:	ffffc097          	auipc	ra,0xffffc
    80004492:	78c080e7          	jalr	1932(ra) # 80000c1a <acquire>
  log.outstanding -= 1;
    80004496:	509c                	lw	a5,32(s1)
    80004498:	37fd                	addiw	a5,a5,-1
    8000449a:	0007891b          	sext.w	s2,a5
    8000449e:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800044a0:	50dc                	lw	a5,36(s1)
    800044a2:	e7b9                	bnez	a5,800044f0 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800044a4:	04091e63          	bnez	s2,80004500 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800044a8:	0001d497          	auipc	s1,0x1d
    800044ac:	1c848493          	addi	s1,s1,456 # 80021670 <log>
    800044b0:	4785                	li	a5,1
    800044b2:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800044b4:	8526                	mv	a0,s1
    800044b6:	ffffd097          	auipc	ra,0xffffd
    800044ba:	818080e7          	jalr	-2024(ra) # 80000cce <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800044be:	54dc                	lw	a5,44(s1)
    800044c0:	06f04763          	bgtz	a5,8000452e <end_op+0xbc>
    acquire(&log.lock);
    800044c4:	0001d497          	auipc	s1,0x1d
    800044c8:	1ac48493          	addi	s1,s1,428 # 80021670 <log>
    800044cc:	8526                	mv	a0,s1
    800044ce:	ffffc097          	auipc	ra,0xffffc
    800044d2:	74c080e7          	jalr	1868(ra) # 80000c1a <acquire>
    log.committing = 0;
    800044d6:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800044da:	8526                	mv	a0,s1
    800044dc:	ffffe097          	auipc	ra,0xffffe
    800044e0:	d82080e7          	jalr	-638(ra) # 8000225e <wakeup>
    release(&log.lock);
    800044e4:	8526                	mv	a0,s1
    800044e6:	ffffc097          	auipc	ra,0xffffc
    800044ea:	7e8080e7          	jalr	2024(ra) # 80000cce <release>
}
    800044ee:	a03d                	j	8000451c <end_op+0xaa>
    panic("log.committing");
    800044f0:	00004517          	auipc	a0,0x4
    800044f4:	19850513          	addi	a0,a0,408 # 80008688 <syscalls+0x210>
    800044f8:	ffffc097          	auipc	ra,0xffffc
    800044fc:	042080e7          	jalr	66(ra) # 8000053a <panic>
    wakeup(&log);
    80004500:	0001d497          	auipc	s1,0x1d
    80004504:	17048493          	addi	s1,s1,368 # 80021670 <log>
    80004508:	8526                	mv	a0,s1
    8000450a:	ffffe097          	auipc	ra,0xffffe
    8000450e:	d54080e7          	jalr	-684(ra) # 8000225e <wakeup>
  release(&log.lock);
    80004512:	8526                	mv	a0,s1
    80004514:	ffffc097          	auipc	ra,0xffffc
    80004518:	7ba080e7          	jalr	1978(ra) # 80000cce <release>
}
    8000451c:	70e2                	ld	ra,56(sp)
    8000451e:	7442                	ld	s0,48(sp)
    80004520:	74a2                	ld	s1,40(sp)
    80004522:	7902                	ld	s2,32(sp)
    80004524:	69e2                	ld	s3,24(sp)
    80004526:	6a42                	ld	s4,16(sp)
    80004528:	6aa2                	ld	s5,8(sp)
    8000452a:	6121                	addi	sp,sp,64
    8000452c:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000452e:	0001da97          	auipc	s5,0x1d
    80004532:	172a8a93          	addi	s5,s5,370 # 800216a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004536:	0001da17          	auipc	s4,0x1d
    8000453a:	13aa0a13          	addi	s4,s4,314 # 80021670 <log>
    8000453e:	018a2583          	lw	a1,24(s4)
    80004542:	012585bb          	addw	a1,a1,s2
    80004546:	2585                	addiw	a1,a1,1
    80004548:	028a2503          	lw	a0,40(s4)
    8000454c:	fffff097          	auipc	ra,0xfffff
    80004550:	cca080e7          	jalr	-822(ra) # 80003216 <bread>
    80004554:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004556:	000aa583          	lw	a1,0(s5)
    8000455a:	028a2503          	lw	a0,40(s4)
    8000455e:	fffff097          	auipc	ra,0xfffff
    80004562:	cb8080e7          	jalr	-840(ra) # 80003216 <bread>
    80004566:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004568:	40000613          	li	a2,1024
    8000456c:	05850593          	addi	a1,a0,88
    80004570:	05848513          	addi	a0,s1,88
    80004574:	ffffc097          	auipc	ra,0xffffc
    80004578:	7fe080e7          	jalr	2046(ra) # 80000d72 <memmove>
    bwrite(to);  // write the log
    8000457c:	8526                	mv	a0,s1
    8000457e:	fffff097          	auipc	ra,0xfffff
    80004582:	d8a080e7          	jalr	-630(ra) # 80003308 <bwrite>
    brelse(from);
    80004586:	854e                	mv	a0,s3
    80004588:	fffff097          	auipc	ra,0xfffff
    8000458c:	dbe080e7          	jalr	-578(ra) # 80003346 <brelse>
    brelse(to);
    80004590:	8526                	mv	a0,s1
    80004592:	fffff097          	auipc	ra,0xfffff
    80004596:	db4080e7          	jalr	-588(ra) # 80003346 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000459a:	2905                	addiw	s2,s2,1
    8000459c:	0a91                	addi	s5,s5,4
    8000459e:	02ca2783          	lw	a5,44(s4)
    800045a2:	f8f94ee3          	blt	s2,a5,8000453e <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800045a6:	00000097          	auipc	ra,0x0
    800045aa:	c68080e7          	jalr	-920(ra) # 8000420e <write_head>
    install_trans(0); // Now install writes to home locations
    800045ae:	4501                	li	a0,0
    800045b0:	00000097          	auipc	ra,0x0
    800045b4:	cda080e7          	jalr	-806(ra) # 8000428a <install_trans>
    log.lh.n = 0;
    800045b8:	0001d797          	auipc	a5,0x1d
    800045bc:	0e07a223          	sw	zero,228(a5) # 8002169c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800045c0:	00000097          	auipc	ra,0x0
    800045c4:	c4e080e7          	jalr	-946(ra) # 8000420e <write_head>
    800045c8:	bdf5                	j	800044c4 <end_op+0x52>

00000000800045ca <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800045ca:	1101                	addi	sp,sp,-32
    800045cc:	ec06                	sd	ra,24(sp)
    800045ce:	e822                	sd	s0,16(sp)
    800045d0:	e426                	sd	s1,8(sp)
    800045d2:	e04a                	sd	s2,0(sp)
    800045d4:	1000                	addi	s0,sp,32
    800045d6:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800045d8:	0001d917          	auipc	s2,0x1d
    800045dc:	09890913          	addi	s2,s2,152 # 80021670 <log>
    800045e0:	854a                	mv	a0,s2
    800045e2:	ffffc097          	auipc	ra,0xffffc
    800045e6:	638080e7          	jalr	1592(ra) # 80000c1a <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800045ea:	02c92603          	lw	a2,44(s2)
    800045ee:	47f5                	li	a5,29
    800045f0:	06c7c563          	blt	a5,a2,8000465a <log_write+0x90>
    800045f4:	0001d797          	auipc	a5,0x1d
    800045f8:	0987a783          	lw	a5,152(a5) # 8002168c <log+0x1c>
    800045fc:	37fd                	addiw	a5,a5,-1
    800045fe:	04f65e63          	bge	a2,a5,8000465a <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004602:	0001d797          	auipc	a5,0x1d
    80004606:	08e7a783          	lw	a5,142(a5) # 80021690 <log+0x20>
    8000460a:	06f05063          	blez	a5,8000466a <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000460e:	4781                	li	a5,0
    80004610:	06c05563          	blez	a2,8000467a <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004614:	44cc                	lw	a1,12(s1)
    80004616:	0001d717          	auipc	a4,0x1d
    8000461a:	08a70713          	addi	a4,a4,138 # 800216a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000461e:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004620:	4314                	lw	a3,0(a4)
    80004622:	04b68c63          	beq	a3,a1,8000467a <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004626:	2785                	addiw	a5,a5,1
    80004628:	0711                	addi	a4,a4,4
    8000462a:	fef61be3          	bne	a2,a5,80004620 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000462e:	0621                	addi	a2,a2,8
    80004630:	060a                	slli	a2,a2,0x2
    80004632:	0001d797          	auipc	a5,0x1d
    80004636:	03e78793          	addi	a5,a5,62 # 80021670 <log>
    8000463a:	97b2                	add	a5,a5,a2
    8000463c:	44d8                	lw	a4,12(s1)
    8000463e:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004640:	8526                	mv	a0,s1
    80004642:	fffff097          	auipc	ra,0xfffff
    80004646:	da2080e7          	jalr	-606(ra) # 800033e4 <bpin>
    log.lh.n++;
    8000464a:	0001d717          	auipc	a4,0x1d
    8000464e:	02670713          	addi	a4,a4,38 # 80021670 <log>
    80004652:	575c                	lw	a5,44(a4)
    80004654:	2785                	addiw	a5,a5,1
    80004656:	d75c                	sw	a5,44(a4)
    80004658:	a82d                	j	80004692 <log_write+0xc8>
    panic("too big a transaction");
    8000465a:	00004517          	auipc	a0,0x4
    8000465e:	03e50513          	addi	a0,a0,62 # 80008698 <syscalls+0x220>
    80004662:	ffffc097          	auipc	ra,0xffffc
    80004666:	ed8080e7          	jalr	-296(ra) # 8000053a <panic>
    panic("log_write outside of trans");
    8000466a:	00004517          	auipc	a0,0x4
    8000466e:	04650513          	addi	a0,a0,70 # 800086b0 <syscalls+0x238>
    80004672:	ffffc097          	auipc	ra,0xffffc
    80004676:	ec8080e7          	jalr	-312(ra) # 8000053a <panic>
  log.lh.block[i] = b->blockno;
    8000467a:	00878693          	addi	a3,a5,8
    8000467e:	068a                	slli	a3,a3,0x2
    80004680:	0001d717          	auipc	a4,0x1d
    80004684:	ff070713          	addi	a4,a4,-16 # 80021670 <log>
    80004688:	9736                	add	a4,a4,a3
    8000468a:	44d4                	lw	a3,12(s1)
    8000468c:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000468e:	faf609e3          	beq	a2,a5,80004640 <log_write+0x76>
  }
  release(&log.lock);
    80004692:	0001d517          	auipc	a0,0x1d
    80004696:	fde50513          	addi	a0,a0,-34 # 80021670 <log>
    8000469a:	ffffc097          	auipc	ra,0xffffc
    8000469e:	634080e7          	jalr	1588(ra) # 80000cce <release>
}
    800046a2:	60e2                	ld	ra,24(sp)
    800046a4:	6442                	ld	s0,16(sp)
    800046a6:	64a2                	ld	s1,8(sp)
    800046a8:	6902                	ld	s2,0(sp)
    800046aa:	6105                	addi	sp,sp,32
    800046ac:	8082                	ret

00000000800046ae <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800046ae:	1101                	addi	sp,sp,-32
    800046b0:	ec06                	sd	ra,24(sp)
    800046b2:	e822                	sd	s0,16(sp)
    800046b4:	e426                	sd	s1,8(sp)
    800046b6:	e04a                	sd	s2,0(sp)
    800046b8:	1000                	addi	s0,sp,32
    800046ba:	84aa                	mv	s1,a0
    800046bc:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800046be:	00004597          	auipc	a1,0x4
    800046c2:	01258593          	addi	a1,a1,18 # 800086d0 <syscalls+0x258>
    800046c6:	0521                	addi	a0,a0,8
    800046c8:	ffffc097          	auipc	ra,0xffffc
    800046cc:	4c2080e7          	jalr	1218(ra) # 80000b8a <initlock>
  lk->name = name;
    800046d0:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800046d4:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800046d8:	0204a423          	sw	zero,40(s1)
}
    800046dc:	60e2                	ld	ra,24(sp)
    800046de:	6442                	ld	s0,16(sp)
    800046e0:	64a2                	ld	s1,8(sp)
    800046e2:	6902                	ld	s2,0(sp)
    800046e4:	6105                	addi	sp,sp,32
    800046e6:	8082                	ret

00000000800046e8 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800046e8:	1101                	addi	sp,sp,-32
    800046ea:	ec06                	sd	ra,24(sp)
    800046ec:	e822                	sd	s0,16(sp)
    800046ee:	e426                	sd	s1,8(sp)
    800046f0:	e04a                	sd	s2,0(sp)
    800046f2:	1000                	addi	s0,sp,32
    800046f4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800046f6:	00850913          	addi	s2,a0,8
    800046fa:	854a                	mv	a0,s2
    800046fc:	ffffc097          	auipc	ra,0xffffc
    80004700:	51e080e7          	jalr	1310(ra) # 80000c1a <acquire>
  while (lk->locked) {
    80004704:	409c                	lw	a5,0(s1)
    80004706:	cb89                	beqz	a5,80004718 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004708:	85ca                	mv	a1,s2
    8000470a:	8526                	mv	a0,s1
    8000470c:	ffffe097          	auipc	ra,0xffffe
    80004710:	9c6080e7          	jalr	-1594(ra) # 800020d2 <sleep>
  while (lk->locked) {
    80004714:	409c                	lw	a5,0(s1)
    80004716:	fbed                	bnez	a5,80004708 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004718:	4785                	li	a5,1
    8000471a:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000471c:	ffffd097          	auipc	ra,0xffffd
    80004720:	2aa080e7          	jalr	682(ra) # 800019c6 <myproc>
    80004724:	591c                	lw	a5,48(a0)
    80004726:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004728:	854a                	mv	a0,s2
    8000472a:	ffffc097          	auipc	ra,0xffffc
    8000472e:	5a4080e7          	jalr	1444(ra) # 80000cce <release>
}
    80004732:	60e2                	ld	ra,24(sp)
    80004734:	6442                	ld	s0,16(sp)
    80004736:	64a2                	ld	s1,8(sp)
    80004738:	6902                	ld	s2,0(sp)
    8000473a:	6105                	addi	sp,sp,32
    8000473c:	8082                	ret

000000008000473e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000473e:	1101                	addi	sp,sp,-32
    80004740:	ec06                	sd	ra,24(sp)
    80004742:	e822                	sd	s0,16(sp)
    80004744:	e426                	sd	s1,8(sp)
    80004746:	e04a                	sd	s2,0(sp)
    80004748:	1000                	addi	s0,sp,32
    8000474a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000474c:	00850913          	addi	s2,a0,8
    80004750:	854a                	mv	a0,s2
    80004752:	ffffc097          	auipc	ra,0xffffc
    80004756:	4c8080e7          	jalr	1224(ra) # 80000c1a <acquire>
  lk->locked = 0;
    8000475a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000475e:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004762:	8526                	mv	a0,s1
    80004764:	ffffe097          	auipc	ra,0xffffe
    80004768:	afa080e7          	jalr	-1286(ra) # 8000225e <wakeup>
  release(&lk->lk);
    8000476c:	854a                	mv	a0,s2
    8000476e:	ffffc097          	auipc	ra,0xffffc
    80004772:	560080e7          	jalr	1376(ra) # 80000cce <release>
}
    80004776:	60e2                	ld	ra,24(sp)
    80004778:	6442                	ld	s0,16(sp)
    8000477a:	64a2                	ld	s1,8(sp)
    8000477c:	6902                	ld	s2,0(sp)
    8000477e:	6105                	addi	sp,sp,32
    80004780:	8082                	ret

0000000080004782 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004782:	7179                	addi	sp,sp,-48
    80004784:	f406                	sd	ra,40(sp)
    80004786:	f022                	sd	s0,32(sp)
    80004788:	ec26                	sd	s1,24(sp)
    8000478a:	e84a                	sd	s2,16(sp)
    8000478c:	e44e                	sd	s3,8(sp)
    8000478e:	1800                	addi	s0,sp,48
    80004790:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004792:	00850913          	addi	s2,a0,8
    80004796:	854a                	mv	a0,s2
    80004798:	ffffc097          	auipc	ra,0xffffc
    8000479c:	482080e7          	jalr	1154(ra) # 80000c1a <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800047a0:	409c                	lw	a5,0(s1)
    800047a2:	ef99                	bnez	a5,800047c0 <holdingsleep+0x3e>
    800047a4:	4481                	li	s1,0
  release(&lk->lk);
    800047a6:	854a                	mv	a0,s2
    800047a8:	ffffc097          	auipc	ra,0xffffc
    800047ac:	526080e7          	jalr	1318(ra) # 80000cce <release>
  return r;
}
    800047b0:	8526                	mv	a0,s1
    800047b2:	70a2                	ld	ra,40(sp)
    800047b4:	7402                	ld	s0,32(sp)
    800047b6:	64e2                	ld	s1,24(sp)
    800047b8:	6942                	ld	s2,16(sp)
    800047ba:	69a2                	ld	s3,8(sp)
    800047bc:	6145                	addi	sp,sp,48
    800047be:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800047c0:	0284a983          	lw	s3,40(s1)
    800047c4:	ffffd097          	auipc	ra,0xffffd
    800047c8:	202080e7          	jalr	514(ra) # 800019c6 <myproc>
    800047cc:	5904                	lw	s1,48(a0)
    800047ce:	413484b3          	sub	s1,s1,s3
    800047d2:	0014b493          	seqz	s1,s1
    800047d6:	bfc1                	j	800047a6 <holdingsleep+0x24>

00000000800047d8 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800047d8:	1141                	addi	sp,sp,-16
    800047da:	e406                	sd	ra,8(sp)
    800047dc:	e022                	sd	s0,0(sp)
    800047de:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800047e0:	00004597          	auipc	a1,0x4
    800047e4:	f0058593          	addi	a1,a1,-256 # 800086e0 <syscalls+0x268>
    800047e8:	0001d517          	auipc	a0,0x1d
    800047ec:	fd050513          	addi	a0,a0,-48 # 800217b8 <ftable>
    800047f0:	ffffc097          	auipc	ra,0xffffc
    800047f4:	39a080e7          	jalr	922(ra) # 80000b8a <initlock>
}
    800047f8:	60a2                	ld	ra,8(sp)
    800047fa:	6402                	ld	s0,0(sp)
    800047fc:	0141                	addi	sp,sp,16
    800047fe:	8082                	ret

0000000080004800 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004800:	1101                	addi	sp,sp,-32
    80004802:	ec06                	sd	ra,24(sp)
    80004804:	e822                	sd	s0,16(sp)
    80004806:	e426                	sd	s1,8(sp)
    80004808:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000480a:	0001d517          	auipc	a0,0x1d
    8000480e:	fae50513          	addi	a0,a0,-82 # 800217b8 <ftable>
    80004812:	ffffc097          	auipc	ra,0xffffc
    80004816:	408080e7          	jalr	1032(ra) # 80000c1a <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000481a:	0001d497          	auipc	s1,0x1d
    8000481e:	fb648493          	addi	s1,s1,-74 # 800217d0 <ftable+0x18>
    80004822:	0001e717          	auipc	a4,0x1e
    80004826:	f4e70713          	addi	a4,a4,-178 # 80022770 <ftable+0xfb8>
    if(f->ref == 0){
    8000482a:	40dc                	lw	a5,4(s1)
    8000482c:	cf99                	beqz	a5,8000484a <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000482e:	02848493          	addi	s1,s1,40
    80004832:	fee49ce3          	bne	s1,a4,8000482a <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004836:	0001d517          	auipc	a0,0x1d
    8000483a:	f8250513          	addi	a0,a0,-126 # 800217b8 <ftable>
    8000483e:	ffffc097          	auipc	ra,0xffffc
    80004842:	490080e7          	jalr	1168(ra) # 80000cce <release>
  return 0;
    80004846:	4481                	li	s1,0
    80004848:	a819                	j	8000485e <filealloc+0x5e>
      f->ref = 1;
    8000484a:	4785                	li	a5,1
    8000484c:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000484e:	0001d517          	auipc	a0,0x1d
    80004852:	f6a50513          	addi	a0,a0,-150 # 800217b8 <ftable>
    80004856:	ffffc097          	auipc	ra,0xffffc
    8000485a:	478080e7          	jalr	1144(ra) # 80000cce <release>
}
    8000485e:	8526                	mv	a0,s1
    80004860:	60e2                	ld	ra,24(sp)
    80004862:	6442                	ld	s0,16(sp)
    80004864:	64a2                	ld	s1,8(sp)
    80004866:	6105                	addi	sp,sp,32
    80004868:	8082                	ret

000000008000486a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000486a:	1101                	addi	sp,sp,-32
    8000486c:	ec06                	sd	ra,24(sp)
    8000486e:	e822                	sd	s0,16(sp)
    80004870:	e426                	sd	s1,8(sp)
    80004872:	1000                	addi	s0,sp,32
    80004874:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004876:	0001d517          	auipc	a0,0x1d
    8000487a:	f4250513          	addi	a0,a0,-190 # 800217b8 <ftable>
    8000487e:	ffffc097          	auipc	ra,0xffffc
    80004882:	39c080e7          	jalr	924(ra) # 80000c1a <acquire>
  if(f->ref < 1)
    80004886:	40dc                	lw	a5,4(s1)
    80004888:	02f05263          	blez	a5,800048ac <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000488c:	2785                	addiw	a5,a5,1
    8000488e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004890:	0001d517          	auipc	a0,0x1d
    80004894:	f2850513          	addi	a0,a0,-216 # 800217b8 <ftable>
    80004898:	ffffc097          	auipc	ra,0xffffc
    8000489c:	436080e7          	jalr	1078(ra) # 80000cce <release>
  return f;
}
    800048a0:	8526                	mv	a0,s1
    800048a2:	60e2                	ld	ra,24(sp)
    800048a4:	6442                	ld	s0,16(sp)
    800048a6:	64a2                	ld	s1,8(sp)
    800048a8:	6105                	addi	sp,sp,32
    800048aa:	8082                	ret
    panic("filedup");
    800048ac:	00004517          	auipc	a0,0x4
    800048b0:	e3c50513          	addi	a0,a0,-452 # 800086e8 <syscalls+0x270>
    800048b4:	ffffc097          	auipc	ra,0xffffc
    800048b8:	c86080e7          	jalr	-890(ra) # 8000053a <panic>

00000000800048bc <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800048bc:	7139                	addi	sp,sp,-64
    800048be:	fc06                	sd	ra,56(sp)
    800048c0:	f822                	sd	s0,48(sp)
    800048c2:	f426                	sd	s1,40(sp)
    800048c4:	f04a                	sd	s2,32(sp)
    800048c6:	ec4e                	sd	s3,24(sp)
    800048c8:	e852                	sd	s4,16(sp)
    800048ca:	e456                	sd	s5,8(sp)
    800048cc:	0080                	addi	s0,sp,64
    800048ce:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800048d0:	0001d517          	auipc	a0,0x1d
    800048d4:	ee850513          	addi	a0,a0,-280 # 800217b8 <ftable>
    800048d8:	ffffc097          	auipc	ra,0xffffc
    800048dc:	342080e7          	jalr	834(ra) # 80000c1a <acquire>
  if(f->ref < 1)
    800048e0:	40dc                	lw	a5,4(s1)
    800048e2:	06f05163          	blez	a5,80004944 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800048e6:	37fd                	addiw	a5,a5,-1
    800048e8:	0007871b          	sext.w	a4,a5
    800048ec:	c0dc                	sw	a5,4(s1)
    800048ee:	06e04363          	bgtz	a4,80004954 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800048f2:	0004a903          	lw	s2,0(s1)
    800048f6:	0094ca83          	lbu	s5,9(s1)
    800048fa:	0104ba03          	ld	s4,16(s1)
    800048fe:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004902:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004906:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000490a:	0001d517          	auipc	a0,0x1d
    8000490e:	eae50513          	addi	a0,a0,-338 # 800217b8 <ftable>
    80004912:	ffffc097          	auipc	ra,0xffffc
    80004916:	3bc080e7          	jalr	956(ra) # 80000cce <release>

  if(ff.type == FD_PIPE){
    8000491a:	4785                	li	a5,1
    8000491c:	04f90d63          	beq	s2,a5,80004976 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004920:	3979                	addiw	s2,s2,-2
    80004922:	4785                	li	a5,1
    80004924:	0527e063          	bltu	a5,s2,80004964 <fileclose+0xa8>
    begin_op();
    80004928:	00000097          	auipc	ra,0x0
    8000492c:	acc080e7          	jalr	-1332(ra) # 800043f4 <begin_op>
    iput(ff.ip);
    80004930:	854e                	mv	a0,s3
    80004932:	fffff097          	auipc	ra,0xfffff
    80004936:	2a0080e7          	jalr	672(ra) # 80003bd2 <iput>
    end_op();
    8000493a:	00000097          	auipc	ra,0x0
    8000493e:	b38080e7          	jalr	-1224(ra) # 80004472 <end_op>
    80004942:	a00d                	j	80004964 <fileclose+0xa8>
    panic("fileclose");
    80004944:	00004517          	auipc	a0,0x4
    80004948:	dac50513          	addi	a0,a0,-596 # 800086f0 <syscalls+0x278>
    8000494c:	ffffc097          	auipc	ra,0xffffc
    80004950:	bee080e7          	jalr	-1042(ra) # 8000053a <panic>
    release(&ftable.lock);
    80004954:	0001d517          	auipc	a0,0x1d
    80004958:	e6450513          	addi	a0,a0,-412 # 800217b8 <ftable>
    8000495c:	ffffc097          	auipc	ra,0xffffc
    80004960:	372080e7          	jalr	882(ra) # 80000cce <release>
  }
}
    80004964:	70e2                	ld	ra,56(sp)
    80004966:	7442                	ld	s0,48(sp)
    80004968:	74a2                	ld	s1,40(sp)
    8000496a:	7902                	ld	s2,32(sp)
    8000496c:	69e2                	ld	s3,24(sp)
    8000496e:	6a42                	ld	s4,16(sp)
    80004970:	6aa2                	ld	s5,8(sp)
    80004972:	6121                	addi	sp,sp,64
    80004974:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004976:	85d6                	mv	a1,s5
    80004978:	8552                	mv	a0,s4
    8000497a:	00000097          	auipc	ra,0x0
    8000497e:	34c080e7          	jalr	844(ra) # 80004cc6 <pipeclose>
    80004982:	b7cd                	j	80004964 <fileclose+0xa8>

0000000080004984 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004984:	715d                	addi	sp,sp,-80
    80004986:	e486                	sd	ra,72(sp)
    80004988:	e0a2                	sd	s0,64(sp)
    8000498a:	fc26                	sd	s1,56(sp)
    8000498c:	f84a                	sd	s2,48(sp)
    8000498e:	f44e                	sd	s3,40(sp)
    80004990:	0880                	addi	s0,sp,80
    80004992:	84aa                	mv	s1,a0
    80004994:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004996:	ffffd097          	auipc	ra,0xffffd
    8000499a:	030080e7          	jalr	48(ra) # 800019c6 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000499e:	409c                	lw	a5,0(s1)
    800049a0:	37f9                	addiw	a5,a5,-2
    800049a2:	4705                	li	a4,1
    800049a4:	04f76763          	bltu	a4,a5,800049f2 <filestat+0x6e>
    800049a8:	892a                	mv	s2,a0
    ilock(f->ip);
    800049aa:	6c88                	ld	a0,24(s1)
    800049ac:	fffff097          	auipc	ra,0xfffff
    800049b0:	06c080e7          	jalr	108(ra) # 80003a18 <ilock>
    stati(f->ip, &st);
    800049b4:	fb840593          	addi	a1,s0,-72
    800049b8:	6c88                	ld	a0,24(s1)
    800049ba:	fffff097          	auipc	ra,0xfffff
    800049be:	2e8080e7          	jalr	744(ra) # 80003ca2 <stati>
    iunlock(f->ip);
    800049c2:	6c88                	ld	a0,24(s1)
    800049c4:	fffff097          	auipc	ra,0xfffff
    800049c8:	116080e7          	jalr	278(ra) # 80003ada <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800049cc:	46e1                	li	a3,24
    800049ce:	fb840613          	addi	a2,s0,-72
    800049d2:	85ce                	mv	a1,s3
    800049d4:	06093503          	ld	a0,96(s2)
    800049d8:	ffffd097          	auipc	ra,0xffffd
    800049dc:	cb2080e7          	jalr	-846(ra) # 8000168a <copyout>
    800049e0:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800049e4:	60a6                	ld	ra,72(sp)
    800049e6:	6406                	ld	s0,64(sp)
    800049e8:	74e2                	ld	s1,56(sp)
    800049ea:	7942                	ld	s2,48(sp)
    800049ec:	79a2                	ld	s3,40(sp)
    800049ee:	6161                	addi	sp,sp,80
    800049f0:	8082                	ret
  return -1;
    800049f2:	557d                	li	a0,-1
    800049f4:	bfc5                	j	800049e4 <filestat+0x60>

00000000800049f6 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800049f6:	7179                	addi	sp,sp,-48
    800049f8:	f406                	sd	ra,40(sp)
    800049fa:	f022                	sd	s0,32(sp)
    800049fc:	ec26                	sd	s1,24(sp)
    800049fe:	e84a                	sd	s2,16(sp)
    80004a00:	e44e                	sd	s3,8(sp)
    80004a02:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004a04:	00854783          	lbu	a5,8(a0)
    80004a08:	c3d5                	beqz	a5,80004aac <fileread+0xb6>
    80004a0a:	84aa                	mv	s1,a0
    80004a0c:	89ae                	mv	s3,a1
    80004a0e:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004a10:	411c                	lw	a5,0(a0)
    80004a12:	4705                	li	a4,1
    80004a14:	04e78963          	beq	a5,a4,80004a66 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004a18:	470d                	li	a4,3
    80004a1a:	04e78d63          	beq	a5,a4,80004a74 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004a1e:	4709                	li	a4,2
    80004a20:	06e79e63          	bne	a5,a4,80004a9c <fileread+0xa6>
    ilock(f->ip);
    80004a24:	6d08                	ld	a0,24(a0)
    80004a26:	fffff097          	auipc	ra,0xfffff
    80004a2a:	ff2080e7          	jalr	-14(ra) # 80003a18 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004a2e:	874a                	mv	a4,s2
    80004a30:	5094                	lw	a3,32(s1)
    80004a32:	864e                	mv	a2,s3
    80004a34:	4585                	li	a1,1
    80004a36:	6c88                	ld	a0,24(s1)
    80004a38:	fffff097          	auipc	ra,0xfffff
    80004a3c:	294080e7          	jalr	660(ra) # 80003ccc <readi>
    80004a40:	892a                	mv	s2,a0
    80004a42:	00a05563          	blez	a0,80004a4c <fileread+0x56>
      f->off += r;
    80004a46:	509c                	lw	a5,32(s1)
    80004a48:	9fa9                	addw	a5,a5,a0
    80004a4a:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004a4c:	6c88                	ld	a0,24(s1)
    80004a4e:	fffff097          	auipc	ra,0xfffff
    80004a52:	08c080e7          	jalr	140(ra) # 80003ada <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004a56:	854a                	mv	a0,s2
    80004a58:	70a2                	ld	ra,40(sp)
    80004a5a:	7402                	ld	s0,32(sp)
    80004a5c:	64e2                	ld	s1,24(sp)
    80004a5e:	6942                	ld	s2,16(sp)
    80004a60:	69a2                	ld	s3,8(sp)
    80004a62:	6145                	addi	sp,sp,48
    80004a64:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004a66:	6908                	ld	a0,16(a0)
    80004a68:	00000097          	auipc	ra,0x0
    80004a6c:	3c0080e7          	jalr	960(ra) # 80004e28 <piperead>
    80004a70:	892a                	mv	s2,a0
    80004a72:	b7d5                	j	80004a56 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004a74:	02451783          	lh	a5,36(a0)
    80004a78:	03079693          	slli	a3,a5,0x30
    80004a7c:	92c1                	srli	a3,a3,0x30
    80004a7e:	4725                	li	a4,9
    80004a80:	02d76863          	bltu	a4,a3,80004ab0 <fileread+0xba>
    80004a84:	0792                	slli	a5,a5,0x4
    80004a86:	0001d717          	auipc	a4,0x1d
    80004a8a:	c9270713          	addi	a4,a4,-878 # 80021718 <devsw>
    80004a8e:	97ba                	add	a5,a5,a4
    80004a90:	639c                	ld	a5,0(a5)
    80004a92:	c38d                	beqz	a5,80004ab4 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004a94:	4505                	li	a0,1
    80004a96:	9782                	jalr	a5
    80004a98:	892a                	mv	s2,a0
    80004a9a:	bf75                	j	80004a56 <fileread+0x60>
    panic("fileread");
    80004a9c:	00004517          	auipc	a0,0x4
    80004aa0:	c6450513          	addi	a0,a0,-924 # 80008700 <syscalls+0x288>
    80004aa4:	ffffc097          	auipc	ra,0xffffc
    80004aa8:	a96080e7          	jalr	-1386(ra) # 8000053a <panic>
    return -1;
    80004aac:	597d                	li	s2,-1
    80004aae:	b765                	j	80004a56 <fileread+0x60>
      return -1;
    80004ab0:	597d                	li	s2,-1
    80004ab2:	b755                	j	80004a56 <fileread+0x60>
    80004ab4:	597d                	li	s2,-1
    80004ab6:	b745                	j	80004a56 <fileread+0x60>

0000000080004ab8 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004ab8:	715d                	addi	sp,sp,-80
    80004aba:	e486                	sd	ra,72(sp)
    80004abc:	e0a2                	sd	s0,64(sp)
    80004abe:	fc26                	sd	s1,56(sp)
    80004ac0:	f84a                	sd	s2,48(sp)
    80004ac2:	f44e                	sd	s3,40(sp)
    80004ac4:	f052                	sd	s4,32(sp)
    80004ac6:	ec56                	sd	s5,24(sp)
    80004ac8:	e85a                	sd	s6,16(sp)
    80004aca:	e45e                	sd	s7,8(sp)
    80004acc:	e062                	sd	s8,0(sp)
    80004ace:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004ad0:	00954783          	lbu	a5,9(a0)
    80004ad4:	10078663          	beqz	a5,80004be0 <filewrite+0x128>
    80004ad8:	892a                	mv	s2,a0
    80004ada:	8b2e                	mv	s6,a1
    80004adc:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004ade:	411c                	lw	a5,0(a0)
    80004ae0:	4705                	li	a4,1
    80004ae2:	02e78263          	beq	a5,a4,80004b06 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004ae6:	470d                	li	a4,3
    80004ae8:	02e78663          	beq	a5,a4,80004b14 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004aec:	4709                	li	a4,2
    80004aee:	0ee79163          	bne	a5,a4,80004bd0 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004af2:	0ac05d63          	blez	a2,80004bac <filewrite+0xf4>
    int i = 0;
    80004af6:	4981                	li	s3,0
    80004af8:	6b85                	lui	s7,0x1
    80004afa:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004afe:	6c05                	lui	s8,0x1
    80004b00:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004b04:	a861                	j	80004b9c <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004b06:	6908                	ld	a0,16(a0)
    80004b08:	00000097          	auipc	ra,0x0
    80004b0c:	22e080e7          	jalr	558(ra) # 80004d36 <pipewrite>
    80004b10:	8a2a                	mv	s4,a0
    80004b12:	a045                	j	80004bb2 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004b14:	02451783          	lh	a5,36(a0)
    80004b18:	03079693          	slli	a3,a5,0x30
    80004b1c:	92c1                	srli	a3,a3,0x30
    80004b1e:	4725                	li	a4,9
    80004b20:	0cd76263          	bltu	a4,a3,80004be4 <filewrite+0x12c>
    80004b24:	0792                	slli	a5,a5,0x4
    80004b26:	0001d717          	auipc	a4,0x1d
    80004b2a:	bf270713          	addi	a4,a4,-1038 # 80021718 <devsw>
    80004b2e:	97ba                	add	a5,a5,a4
    80004b30:	679c                	ld	a5,8(a5)
    80004b32:	cbdd                	beqz	a5,80004be8 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004b34:	4505                	li	a0,1
    80004b36:	9782                	jalr	a5
    80004b38:	8a2a                	mv	s4,a0
    80004b3a:	a8a5                	j	80004bb2 <filewrite+0xfa>
    80004b3c:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004b40:	00000097          	auipc	ra,0x0
    80004b44:	8b4080e7          	jalr	-1868(ra) # 800043f4 <begin_op>
      ilock(f->ip);
    80004b48:	01893503          	ld	a0,24(s2)
    80004b4c:	fffff097          	auipc	ra,0xfffff
    80004b50:	ecc080e7          	jalr	-308(ra) # 80003a18 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004b54:	8756                	mv	a4,s5
    80004b56:	02092683          	lw	a3,32(s2)
    80004b5a:	01698633          	add	a2,s3,s6
    80004b5e:	4585                	li	a1,1
    80004b60:	01893503          	ld	a0,24(s2)
    80004b64:	fffff097          	auipc	ra,0xfffff
    80004b68:	260080e7          	jalr	608(ra) # 80003dc4 <writei>
    80004b6c:	84aa                	mv	s1,a0
    80004b6e:	00a05763          	blez	a0,80004b7c <filewrite+0xc4>
        f->off += r;
    80004b72:	02092783          	lw	a5,32(s2)
    80004b76:	9fa9                	addw	a5,a5,a0
    80004b78:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004b7c:	01893503          	ld	a0,24(s2)
    80004b80:	fffff097          	auipc	ra,0xfffff
    80004b84:	f5a080e7          	jalr	-166(ra) # 80003ada <iunlock>
      end_op();
    80004b88:	00000097          	auipc	ra,0x0
    80004b8c:	8ea080e7          	jalr	-1814(ra) # 80004472 <end_op>

      if(r != n1){
    80004b90:	009a9f63          	bne	s5,s1,80004bae <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004b94:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004b98:	0149db63          	bge	s3,s4,80004bae <filewrite+0xf6>
      int n1 = n - i;
    80004b9c:	413a04bb          	subw	s1,s4,s3
    80004ba0:	0004879b          	sext.w	a5,s1
    80004ba4:	f8fbdce3          	bge	s7,a5,80004b3c <filewrite+0x84>
    80004ba8:	84e2                	mv	s1,s8
    80004baa:	bf49                	j	80004b3c <filewrite+0x84>
    int i = 0;
    80004bac:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004bae:	013a1f63          	bne	s4,s3,80004bcc <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004bb2:	8552                	mv	a0,s4
    80004bb4:	60a6                	ld	ra,72(sp)
    80004bb6:	6406                	ld	s0,64(sp)
    80004bb8:	74e2                	ld	s1,56(sp)
    80004bba:	7942                	ld	s2,48(sp)
    80004bbc:	79a2                	ld	s3,40(sp)
    80004bbe:	7a02                	ld	s4,32(sp)
    80004bc0:	6ae2                	ld	s5,24(sp)
    80004bc2:	6b42                	ld	s6,16(sp)
    80004bc4:	6ba2                	ld	s7,8(sp)
    80004bc6:	6c02                	ld	s8,0(sp)
    80004bc8:	6161                	addi	sp,sp,80
    80004bca:	8082                	ret
    ret = (i == n ? n : -1);
    80004bcc:	5a7d                	li	s4,-1
    80004bce:	b7d5                	j	80004bb2 <filewrite+0xfa>
    panic("filewrite");
    80004bd0:	00004517          	auipc	a0,0x4
    80004bd4:	b4050513          	addi	a0,a0,-1216 # 80008710 <syscalls+0x298>
    80004bd8:	ffffc097          	auipc	ra,0xffffc
    80004bdc:	962080e7          	jalr	-1694(ra) # 8000053a <panic>
    return -1;
    80004be0:	5a7d                	li	s4,-1
    80004be2:	bfc1                	j	80004bb2 <filewrite+0xfa>
      return -1;
    80004be4:	5a7d                	li	s4,-1
    80004be6:	b7f1                	j	80004bb2 <filewrite+0xfa>
    80004be8:	5a7d                	li	s4,-1
    80004bea:	b7e1                	j	80004bb2 <filewrite+0xfa>

0000000080004bec <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004bec:	7179                	addi	sp,sp,-48
    80004bee:	f406                	sd	ra,40(sp)
    80004bf0:	f022                	sd	s0,32(sp)
    80004bf2:	ec26                	sd	s1,24(sp)
    80004bf4:	e84a                	sd	s2,16(sp)
    80004bf6:	e44e                	sd	s3,8(sp)
    80004bf8:	e052                	sd	s4,0(sp)
    80004bfa:	1800                	addi	s0,sp,48
    80004bfc:	84aa                	mv	s1,a0
    80004bfe:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004c00:	0005b023          	sd	zero,0(a1)
    80004c04:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004c08:	00000097          	auipc	ra,0x0
    80004c0c:	bf8080e7          	jalr	-1032(ra) # 80004800 <filealloc>
    80004c10:	e088                	sd	a0,0(s1)
    80004c12:	c551                	beqz	a0,80004c9e <pipealloc+0xb2>
    80004c14:	00000097          	auipc	ra,0x0
    80004c18:	bec080e7          	jalr	-1044(ra) # 80004800 <filealloc>
    80004c1c:	00aa3023          	sd	a0,0(s4)
    80004c20:	c92d                	beqz	a0,80004c92 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004c22:	ffffc097          	auipc	ra,0xffffc
    80004c26:	ebe080e7          	jalr	-322(ra) # 80000ae0 <kalloc>
    80004c2a:	892a                	mv	s2,a0
    80004c2c:	c125                	beqz	a0,80004c8c <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004c2e:	4985                	li	s3,1
    80004c30:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004c34:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004c38:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004c3c:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004c40:	00004597          	auipc	a1,0x4
    80004c44:	ae058593          	addi	a1,a1,-1312 # 80008720 <syscalls+0x2a8>
    80004c48:	ffffc097          	auipc	ra,0xffffc
    80004c4c:	f42080e7          	jalr	-190(ra) # 80000b8a <initlock>
  (*f0)->type = FD_PIPE;
    80004c50:	609c                	ld	a5,0(s1)
    80004c52:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004c56:	609c                	ld	a5,0(s1)
    80004c58:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004c5c:	609c                	ld	a5,0(s1)
    80004c5e:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004c62:	609c                	ld	a5,0(s1)
    80004c64:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004c68:	000a3783          	ld	a5,0(s4)
    80004c6c:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004c70:	000a3783          	ld	a5,0(s4)
    80004c74:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004c78:	000a3783          	ld	a5,0(s4)
    80004c7c:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004c80:	000a3783          	ld	a5,0(s4)
    80004c84:	0127b823          	sd	s2,16(a5)
  return 0;
    80004c88:	4501                	li	a0,0
    80004c8a:	a025                	j	80004cb2 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004c8c:	6088                	ld	a0,0(s1)
    80004c8e:	e501                	bnez	a0,80004c96 <pipealloc+0xaa>
    80004c90:	a039                	j	80004c9e <pipealloc+0xb2>
    80004c92:	6088                	ld	a0,0(s1)
    80004c94:	c51d                	beqz	a0,80004cc2 <pipealloc+0xd6>
    fileclose(*f0);
    80004c96:	00000097          	auipc	ra,0x0
    80004c9a:	c26080e7          	jalr	-986(ra) # 800048bc <fileclose>
  if(*f1)
    80004c9e:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004ca2:	557d                	li	a0,-1
  if(*f1)
    80004ca4:	c799                	beqz	a5,80004cb2 <pipealloc+0xc6>
    fileclose(*f1);
    80004ca6:	853e                	mv	a0,a5
    80004ca8:	00000097          	auipc	ra,0x0
    80004cac:	c14080e7          	jalr	-1004(ra) # 800048bc <fileclose>
  return -1;
    80004cb0:	557d                	li	a0,-1
}
    80004cb2:	70a2                	ld	ra,40(sp)
    80004cb4:	7402                	ld	s0,32(sp)
    80004cb6:	64e2                	ld	s1,24(sp)
    80004cb8:	6942                	ld	s2,16(sp)
    80004cba:	69a2                	ld	s3,8(sp)
    80004cbc:	6a02                	ld	s4,0(sp)
    80004cbe:	6145                	addi	sp,sp,48
    80004cc0:	8082                	ret
  return -1;
    80004cc2:	557d                	li	a0,-1
    80004cc4:	b7fd                	j	80004cb2 <pipealloc+0xc6>

0000000080004cc6 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004cc6:	1101                	addi	sp,sp,-32
    80004cc8:	ec06                	sd	ra,24(sp)
    80004cca:	e822                	sd	s0,16(sp)
    80004ccc:	e426                	sd	s1,8(sp)
    80004cce:	e04a                	sd	s2,0(sp)
    80004cd0:	1000                	addi	s0,sp,32
    80004cd2:	84aa                	mv	s1,a0
    80004cd4:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004cd6:	ffffc097          	auipc	ra,0xffffc
    80004cda:	f44080e7          	jalr	-188(ra) # 80000c1a <acquire>
  if(writable){
    80004cde:	02090d63          	beqz	s2,80004d18 <pipeclose+0x52>
    pi->writeopen = 0;
    80004ce2:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004ce6:	21848513          	addi	a0,s1,536
    80004cea:	ffffd097          	auipc	ra,0xffffd
    80004cee:	574080e7          	jalr	1396(ra) # 8000225e <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004cf2:	2204b783          	ld	a5,544(s1)
    80004cf6:	eb95                	bnez	a5,80004d2a <pipeclose+0x64>
    release(&pi->lock);
    80004cf8:	8526                	mv	a0,s1
    80004cfa:	ffffc097          	auipc	ra,0xffffc
    80004cfe:	fd4080e7          	jalr	-44(ra) # 80000cce <release>
    kfree((char*)pi);
    80004d02:	8526                	mv	a0,s1
    80004d04:	ffffc097          	auipc	ra,0xffffc
    80004d08:	cde080e7          	jalr	-802(ra) # 800009e2 <kfree>
  } else
    release(&pi->lock);
}
    80004d0c:	60e2                	ld	ra,24(sp)
    80004d0e:	6442                	ld	s0,16(sp)
    80004d10:	64a2                	ld	s1,8(sp)
    80004d12:	6902                	ld	s2,0(sp)
    80004d14:	6105                	addi	sp,sp,32
    80004d16:	8082                	ret
    pi->readopen = 0;
    80004d18:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004d1c:	21c48513          	addi	a0,s1,540
    80004d20:	ffffd097          	auipc	ra,0xffffd
    80004d24:	53e080e7          	jalr	1342(ra) # 8000225e <wakeup>
    80004d28:	b7e9                	j	80004cf2 <pipeclose+0x2c>
    release(&pi->lock);
    80004d2a:	8526                	mv	a0,s1
    80004d2c:	ffffc097          	auipc	ra,0xffffc
    80004d30:	fa2080e7          	jalr	-94(ra) # 80000cce <release>
}
    80004d34:	bfe1                	j	80004d0c <pipeclose+0x46>

0000000080004d36 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004d36:	711d                	addi	sp,sp,-96
    80004d38:	ec86                	sd	ra,88(sp)
    80004d3a:	e8a2                	sd	s0,80(sp)
    80004d3c:	e4a6                	sd	s1,72(sp)
    80004d3e:	e0ca                	sd	s2,64(sp)
    80004d40:	fc4e                	sd	s3,56(sp)
    80004d42:	f852                	sd	s4,48(sp)
    80004d44:	f456                	sd	s5,40(sp)
    80004d46:	f05a                	sd	s6,32(sp)
    80004d48:	ec5e                	sd	s7,24(sp)
    80004d4a:	e862                	sd	s8,16(sp)
    80004d4c:	1080                	addi	s0,sp,96
    80004d4e:	84aa                	mv	s1,a0
    80004d50:	8aae                	mv	s5,a1
    80004d52:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004d54:	ffffd097          	auipc	ra,0xffffd
    80004d58:	c72080e7          	jalr	-910(ra) # 800019c6 <myproc>
    80004d5c:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004d5e:	8526                	mv	a0,s1
    80004d60:	ffffc097          	auipc	ra,0xffffc
    80004d64:	eba080e7          	jalr	-326(ra) # 80000c1a <acquire>
  while(i < n){
    80004d68:	0b405363          	blez	s4,80004e0e <pipewrite+0xd8>
  int i = 0;
    80004d6c:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d6e:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004d70:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004d74:	21c48b93          	addi	s7,s1,540
    80004d78:	a089                	j	80004dba <pipewrite+0x84>
      release(&pi->lock);
    80004d7a:	8526                	mv	a0,s1
    80004d7c:	ffffc097          	auipc	ra,0xffffc
    80004d80:	f52080e7          	jalr	-174(ra) # 80000cce <release>
      return -1;
    80004d84:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004d86:	854a                	mv	a0,s2
    80004d88:	60e6                	ld	ra,88(sp)
    80004d8a:	6446                	ld	s0,80(sp)
    80004d8c:	64a6                	ld	s1,72(sp)
    80004d8e:	6906                	ld	s2,64(sp)
    80004d90:	79e2                	ld	s3,56(sp)
    80004d92:	7a42                	ld	s4,48(sp)
    80004d94:	7aa2                	ld	s5,40(sp)
    80004d96:	7b02                	ld	s6,32(sp)
    80004d98:	6be2                	ld	s7,24(sp)
    80004d9a:	6c42                	ld	s8,16(sp)
    80004d9c:	6125                	addi	sp,sp,96
    80004d9e:	8082                	ret
      wakeup(&pi->nread);
    80004da0:	8562                	mv	a0,s8
    80004da2:	ffffd097          	auipc	ra,0xffffd
    80004da6:	4bc080e7          	jalr	1212(ra) # 8000225e <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004daa:	85a6                	mv	a1,s1
    80004dac:	855e                	mv	a0,s7
    80004dae:	ffffd097          	auipc	ra,0xffffd
    80004db2:	324080e7          	jalr	804(ra) # 800020d2 <sleep>
  while(i < n){
    80004db6:	05495d63          	bge	s2,s4,80004e10 <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    80004dba:	2204a783          	lw	a5,544(s1)
    80004dbe:	dfd5                	beqz	a5,80004d7a <pipewrite+0x44>
    80004dc0:	0289a783          	lw	a5,40(s3)
    80004dc4:	fbdd                	bnez	a5,80004d7a <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004dc6:	2184a783          	lw	a5,536(s1)
    80004dca:	21c4a703          	lw	a4,540(s1)
    80004dce:	2007879b          	addiw	a5,a5,512
    80004dd2:	fcf707e3          	beq	a4,a5,80004da0 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004dd6:	4685                	li	a3,1
    80004dd8:	01590633          	add	a2,s2,s5
    80004ddc:	faf40593          	addi	a1,s0,-81
    80004de0:	0609b503          	ld	a0,96(s3)
    80004de4:	ffffd097          	auipc	ra,0xffffd
    80004de8:	932080e7          	jalr	-1742(ra) # 80001716 <copyin>
    80004dec:	03650263          	beq	a0,s6,80004e10 <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004df0:	21c4a783          	lw	a5,540(s1)
    80004df4:	0017871b          	addiw	a4,a5,1
    80004df8:	20e4ae23          	sw	a4,540(s1)
    80004dfc:	1ff7f793          	andi	a5,a5,511
    80004e00:	97a6                	add	a5,a5,s1
    80004e02:	faf44703          	lbu	a4,-81(s0)
    80004e06:	00e78c23          	sb	a4,24(a5)
      i++;
    80004e0a:	2905                	addiw	s2,s2,1
    80004e0c:	b76d                	j	80004db6 <pipewrite+0x80>
  int i = 0;
    80004e0e:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004e10:	21848513          	addi	a0,s1,536
    80004e14:	ffffd097          	auipc	ra,0xffffd
    80004e18:	44a080e7          	jalr	1098(ra) # 8000225e <wakeup>
  release(&pi->lock);
    80004e1c:	8526                	mv	a0,s1
    80004e1e:	ffffc097          	auipc	ra,0xffffc
    80004e22:	eb0080e7          	jalr	-336(ra) # 80000cce <release>
  return i;
    80004e26:	b785                	j	80004d86 <pipewrite+0x50>

0000000080004e28 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004e28:	715d                	addi	sp,sp,-80
    80004e2a:	e486                	sd	ra,72(sp)
    80004e2c:	e0a2                	sd	s0,64(sp)
    80004e2e:	fc26                	sd	s1,56(sp)
    80004e30:	f84a                	sd	s2,48(sp)
    80004e32:	f44e                	sd	s3,40(sp)
    80004e34:	f052                	sd	s4,32(sp)
    80004e36:	ec56                	sd	s5,24(sp)
    80004e38:	e85a                	sd	s6,16(sp)
    80004e3a:	0880                	addi	s0,sp,80
    80004e3c:	84aa                	mv	s1,a0
    80004e3e:	892e                	mv	s2,a1
    80004e40:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004e42:	ffffd097          	auipc	ra,0xffffd
    80004e46:	b84080e7          	jalr	-1148(ra) # 800019c6 <myproc>
    80004e4a:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004e4c:	8526                	mv	a0,s1
    80004e4e:	ffffc097          	auipc	ra,0xffffc
    80004e52:	dcc080e7          	jalr	-564(ra) # 80000c1a <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e56:	2184a703          	lw	a4,536(s1)
    80004e5a:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004e5e:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e62:	02f71463          	bne	a4,a5,80004e8a <piperead+0x62>
    80004e66:	2244a783          	lw	a5,548(s1)
    80004e6a:	c385                	beqz	a5,80004e8a <piperead+0x62>
    if(pr->killed){
    80004e6c:	028a2783          	lw	a5,40(s4)
    80004e70:	ebc9                	bnez	a5,80004f02 <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004e72:	85a6                	mv	a1,s1
    80004e74:	854e                	mv	a0,s3
    80004e76:	ffffd097          	auipc	ra,0xffffd
    80004e7a:	25c080e7          	jalr	604(ra) # 800020d2 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e7e:	2184a703          	lw	a4,536(s1)
    80004e82:	21c4a783          	lw	a5,540(s1)
    80004e86:	fef700e3          	beq	a4,a5,80004e66 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e8a:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e8c:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e8e:	05505463          	blez	s5,80004ed6 <piperead+0xae>
    if(pi->nread == pi->nwrite)
    80004e92:	2184a783          	lw	a5,536(s1)
    80004e96:	21c4a703          	lw	a4,540(s1)
    80004e9a:	02f70e63          	beq	a4,a5,80004ed6 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004e9e:	0017871b          	addiw	a4,a5,1
    80004ea2:	20e4ac23          	sw	a4,536(s1)
    80004ea6:	1ff7f793          	andi	a5,a5,511
    80004eaa:	97a6                	add	a5,a5,s1
    80004eac:	0187c783          	lbu	a5,24(a5)
    80004eb0:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004eb4:	4685                	li	a3,1
    80004eb6:	fbf40613          	addi	a2,s0,-65
    80004eba:	85ca                	mv	a1,s2
    80004ebc:	060a3503          	ld	a0,96(s4)
    80004ec0:	ffffc097          	auipc	ra,0xffffc
    80004ec4:	7ca080e7          	jalr	1994(ra) # 8000168a <copyout>
    80004ec8:	01650763          	beq	a0,s6,80004ed6 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ecc:	2985                	addiw	s3,s3,1
    80004ece:	0905                	addi	s2,s2,1
    80004ed0:	fd3a91e3          	bne	s5,s3,80004e92 <piperead+0x6a>
    80004ed4:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004ed6:	21c48513          	addi	a0,s1,540
    80004eda:	ffffd097          	auipc	ra,0xffffd
    80004ede:	384080e7          	jalr	900(ra) # 8000225e <wakeup>
  release(&pi->lock);
    80004ee2:	8526                	mv	a0,s1
    80004ee4:	ffffc097          	auipc	ra,0xffffc
    80004ee8:	dea080e7          	jalr	-534(ra) # 80000cce <release>
  return i;
}
    80004eec:	854e                	mv	a0,s3
    80004eee:	60a6                	ld	ra,72(sp)
    80004ef0:	6406                	ld	s0,64(sp)
    80004ef2:	74e2                	ld	s1,56(sp)
    80004ef4:	7942                	ld	s2,48(sp)
    80004ef6:	79a2                	ld	s3,40(sp)
    80004ef8:	7a02                	ld	s4,32(sp)
    80004efa:	6ae2                	ld	s5,24(sp)
    80004efc:	6b42                	ld	s6,16(sp)
    80004efe:	6161                	addi	sp,sp,80
    80004f00:	8082                	ret
      release(&pi->lock);
    80004f02:	8526                	mv	a0,s1
    80004f04:	ffffc097          	auipc	ra,0xffffc
    80004f08:	dca080e7          	jalr	-566(ra) # 80000cce <release>
      return -1;
    80004f0c:	59fd                	li	s3,-1
    80004f0e:	bff9                	j	80004eec <piperead+0xc4>

0000000080004f10 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004f10:	de010113          	addi	sp,sp,-544
    80004f14:	20113c23          	sd	ra,536(sp)
    80004f18:	20813823          	sd	s0,528(sp)
    80004f1c:	20913423          	sd	s1,520(sp)
    80004f20:	21213023          	sd	s2,512(sp)
    80004f24:	ffce                	sd	s3,504(sp)
    80004f26:	fbd2                	sd	s4,496(sp)
    80004f28:	f7d6                	sd	s5,488(sp)
    80004f2a:	f3da                	sd	s6,480(sp)
    80004f2c:	efde                	sd	s7,472(sp)
    80004f2e:	ebe2                	sd	s8,464(sp)
    80004f30:	e7e6                	sd	s9,456(sp)
    80004f32:	e3ea                	sd	s10,448(sp)
    80004f34:	ff6e                	sd	s11,440(sp)
    80004f36:	1400                	addi	s0,sp,544
    80004f38:	892a                	mv	s2,a0
    80004f3a:	dea43423          	sd	a0,-536(s0)
    80004f3e:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004f42:	ffffd097          	auipc	ra,0xffffd
    80004f46:	a84080e7          	jalr	-1404(ra) # 800019c6 <myproc>
    80004f4a:	84aa                	mv	s1,a0

  begin_op();
    80004f4c:	fffff097          	auipc	ra,0xfffff
    80004f50:	4a8080e7          	jalr	1192(ra) # 800043f4 <begin_op>

  if((ip = namei(path)) == 0){
    80004f54:	854a                	mv	a0,s2
    80004f56:	fffff097          	auipc	ra,0xfffff
    80004f5a:	27e080e7          	jalr	638(ra) # 800041d4 <namei>
    80004f5e:	c93d                	beqz	a0,80004fd4 <exec+0xc4>
    80004f60:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004f62:	fffff097          	auipc	ra,0xfffff
    80004f66:	ab6080e7          	jalr	-1354(ra) # 80003a18 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004f6a:	04000713          	li	a4,64
    80004f6e:	4681                	li	a3,0
    80004f70:	e5040613          	addi	a2,s0,-432
    80004f74:	4581                	li	a1,0
    80004f76:	8556                	mv	a0,s5
    80004f78:	fffff097          	auipc	ra,0xfffff
    80004f7c:	d54080e7          	jalr	-684(ra) # 80003ccc <readi>
    80004f80:	04000793          	li	a5,64
    80004f84:	00f51a63          	bne	a0,a5,80004f98 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004f88:	e5042703          	lw	a4,-432(s0)
    80004f8c:	464c47b7          	lui	a5,0x464c4
    80004f90:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004f94:	04f70663          	beq	a4,a5,80004fe0 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004f98:	8556                	mv	a0,s5
    80004f9a:	fffff097          	auipc	ra,0xfffff
    80004f9e:	ce0080e7          	jalr	-800(ra) # 80003c7a <iunlockput>
    end_op();
    80004fa2:	fffff097          	auipc	ra,0xfffff
    80004fa6:	4d0080e7          	jalr	1232(ra) # 80004472 <end_op>
  }
  return -1;
    80004faa:	557d                	li	a0,-1
}
    80004fac:	21813083          	ld	ra,536(sp)
    80004fb0:	21013403          	ld	s0,528(sp)
    80004fb4:	20813483          	ld	s1,520(sp)
    80004fb8:	20013903          	ld	s2,512(sp)
    80004fbc:	79fe                	ld	s3,504(sp)
    80004fbe:	7a5e                	ld	s4,496(sp)
    80004fc0:	7abe                	ld	s5,488(sp)
    80004fc2:	7b1e                	ld	s6,480(sp)
    80004fc4:	6bfe                	ld	s7,472(sp)
    80004fc6:	6c5e                	ld	s8,464(sp)
    80004fc8:	6cbe                	ld	s9,456(sp)
    80004fca:	6d1e                	ld	s10,448(sp)
    80004fcc:	7dfa                	ld	s11,440(sp)
    80004fce:	22010113          	addi	sp,sp,544
    80004fd2:	8082                	ret
    end_op();
    80004fd4:	fffff097          	auipc	ra,0xfffff
    80004fd8:	49e080e7          	jalr	1182(ra) # 80004472 <end_op>
    return -1;
    80004fdc:	557d                	li	a0,-1
    80004fde:	b7f9                	j	80004fac <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004fe0:	8526                	mv	a0,s1
    80004fe2:	ffffd097          	auipc	ra,0xffffd
    80004fe6:	aa8080e7          	jalr	-1368(ra) # 80001a8a <proc_pagetable>
    80004fea:	8b2a                	mv	s6,a0
    80004fec:	d555                	beqz	a0,80004f98 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004fee:	e7042783          	lw	a5,-400(s0)
    80004ff2:	e8845703          	lhu	a4,-376(s0)
    80004ff6:	c735                	beqz	a4,80005062 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004ff8:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ffa:	e0043423          	sd	zero,-504(s0)
    if((ph.vaddr % PGSIZE) != 0)
    80004ffe:	6a05                	lui	s4,0x1
    80005000:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005004:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80005008:	6d85                	lui	s11,0x1
    8000500a:	7d7d                	lui	s10,0xfffff
    8000500c:	ac1d                	j	80005242 <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    8000500e:	00003517          	auipc	a0,0x3
    80005012:	71a50513          	addi	a0,a0,1818 # 80008728 <syscalls+0x2b0>
    80005016:	ffffb097          	auipc	ra,0xffffb
    8000501a:	524080e7          	jalr	1316(ra) # 8000053a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000501e:	874a                	mv	a4,s2
    80005020:	009c86bb          	addw	a3,s9,s1
    80005024:	4581                	li	a1,0
    80005026:	8556                	mv	a0,s5
    80005028:	fffff097          	auipc	ra,0xfffff
    8000502c:	ca4080e7          	jalr	-860(ra) # 80003ccc <readi>
    80005030:	2501                	sext.w	a0,a0
    80005032:	1aa91863          	bne	s2,a0,800051e2 <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    80005036:	009d84bb          	addw	s1,s11,s1
    8000503a:	013d09bb          	addw	s3,s10,s3
    8000503e:	1f74f263          	bgeu	s1,s7,80005222 <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    80005042:	02049593          	slli	a1,s1,0x20
    80005046:	9181                	srli	a1,a1,0x20
    80005048:	95e2                	add	a1,a1,s8
    8000504a:	855a                	mv	a0,s6
    8000504c:	ffffc097          	auipc	ra,0xffffc
    80005050:	050080e7          	jalr	80(ra) # 8000109c <walkaddr>
    80005054:	862a                	mv	a2,a0
    if(pa == 0)
    80005056:	dd45                	beqz	a0,8000500e <exec+0xfe>
      n = PGSIZE;
    80005058:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    8000505a:	fd49f2e3          	bgeu	s3,s4,8000501e <exec+0x10e>
      n = sz - i;
    8000505e:	894e                	mv	s2,s3
    80005060:	bf7d                	j	8000501e <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005062:	4481                	li	s1,0
  iunlockput(ip);
    80005064:	8556                	mv	a0,s5
    80005066:	fffff097          	auipc	ra,0xfffff
    8000506a:	c14080e7          	jalr	-1004(ra) # 80003c7a <iunlockput>
  end_op();
    8000506e:	fffff097          	auipc	ra,0xfffff
    80005072:	404080e7          	jalr	1028(ra) # 80004472 <end_op>
  p = myproc();
    80005076:	ffffd097          	auipc	ra,0xffffd
    8000507a:	950080e7          	jalr	-1712(ra) # 800019c6 <myproc>
    8000507e:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005080:	05853d03          	ld	s10,88(a0)
  sz = PGROUNDUP(sz);
    80005084:	6785                	lui	a5,0x1
    80005086:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80005088:	97a6                	add	a5,a5,s1
    8000508a:	777d                	lui	a4,0xfffff
    8000508c:	8ff9                	and	a5,a5,a4
    8000508e:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005092:	6609                	lui	a2,0x2
    80005094:	963e                	add	a2,a2,a5
    80005096:	85be                	mv	a1,a5
    80005098:	855a                	mv	a0,s6
    8000509a:	ffffc097          	auipc	ra,0xffffc
    8000509e:	3a8080e7          	jalr	936(ra) # 80001442 <uvmalloc>
    800050a2:	8c2a                	mv	s8,a0
  ip = 0;
    800050a4:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800050a6:	12050e63          	beqz	a0,800051e2 <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    800050aa:	75f9                	lui	a1,0xffffe
    800050ac:	95aa                	add	a1,a1,a0
    800050ae:	855a                	mv	a0,s6
    800050b0:	ffffc097          	auipc	ra,0xffffc
    800050b4:	5a8080e7          	jalr	1448(ra) # 80001658 <uvmclear>
  stackbase = sp - PGSIZE;
    800050b8:	7afd                	lui	s5,0xfffff
    800050ba:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    800050bc:	df043783          	ld	a5,-528(s0)
    800050c0:	6388                	ld	a0,0(a5)
    800050c2:	c925                	beqz	a0,80005132 <exec+0x222>
    800050c4:	e9040993          	addi	s3,s0,-368
    800050c8:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800050cc:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800050ce:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800050d0:	ffffc097          	auipc	ra,0xffffc
    800050d4:	dc2080e7          	jalr	-574(ra) # 80000e92 <strlen>
    800050d8:	0015079b          	addiw	a5,a0,1
    800050dc:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800050e0:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800050e4:	13596363          	bltu	s2,s5,8000520a <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800050e8:	df043d83          	ld	s11,-528(s0)
    800050ec:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800050f0:	8552                	mv	a0,s4
    800050f2:	ffffc097          	auipc	ra,0xffffc
    800050f6:	da0080e7          	jalr	-608(ra) # 80000e92 <strlen>
    800050fa:	0015069b          	addiw	a3,a0,1
    800050fe:	8652                	mv	a2,s4
    80005100:	85ca                	mv	a1,s2
    80005102:	855a                	mv	a0,s6
    80005104:	ffffc097          	auipc	ra,0xffffc
    80005108:	586080e7          	jalr	1414(ra) # 8000168a <copyout>
    8000510c:	10054363          	bltz	a0,80005212 <exec+0x302>
    ustack[argc] = sp;
    80005110:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005114:	0485                	addi	s1,s1,1
    80005116:	008d8793          	addi	a5,s11,8
    8000511a:	def43823          	sd	a5,-528(s0)
    8000511e:	008db503          	ld	a0,8(s11)
    80005122:	c911                	beqz	a0,80005136 <exec+0x226>
    if(argc >= MAXARG)
    80005124:	09a1                	addi	s3,s3,8
    80005126:	fb3c95e3          	bne	s9,s3,800050d0 <exec+0x1c0>
  sz = sz1;
    8000512a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000512e:	4a81                	li	s5,0
    80005130:	a84d                	j	800051e2 <exec+0x2d2>
  sp = sz;
    80005132:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005134:	4481                	li	s1,0
  ustack[argc] = 0;
    80005136:	00349793          	slli	a5,s1,0x3
    8000513a:	f9078793          	addi	a5,a5,-112
    8000513e:	97a2                	add	a5,a5,s0
    80005140:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005144:	00148693          	addi	a3,s1,1
    80005148:	068e                	slli	a3,a3,0x3
    8000514a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000514e:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005152:	01597663          	bgeu	s2,s5,8000515e <exec+0x24e>
  sz = sz1;
    80005156:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000515a:	4a81                	li	s5,0
    8000515c:	a059                	j	800051e2 <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000515e:	e9040613          	addi	a2,s0,-368
    80005162:	85ca                	mv	a1,s2
    80005164:	855a                	mv	a0,s6
    80005166:	ffffc097          	auipc	ra,0xffffc
    8000516a:	524080e7          	jalr	1316(ra) # 8000168a <copyout>
    8000516e:	0a054663          	bltz	a0,8000521a <exec+0x30a>
  p->trapframe->a1 = sp;
    80005172:	068bb783          	ld	a5,104(s7)
    80005176:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000517a:	de843783          	ld	a5,-536(s0)
    8000517e:	0007c703          	lbu	a4,0(a5)
    80005182:	cf11                	beqz	a4,8000519e <exec+0x28e>
    80005184:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005186:	02f00693          	li	a3,47
    8000518a:	a039                	j	80005198 <exec+0x288>
      last = s+1;
    8000518c:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005190:	0785                	addi	a5,a5,1
    80005192:	fff7c703          	lbu	a4,-1(a5)
    80005196:	c701                	beqz	a4,8000519e <exec+0x28e>
    if(*s == '/')
    80005198:	fed71ce3          	bne	a4,a3,80005190 <exec+0x280>
    8000519c:	bfc5                	j	8000518c <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    8000519e:	4641                	li	a2,16
    800051a0:	de843583          	ld	a1,-536(s0)
    800051a4:	168b8513          	addi	a0,s7,360
    800051a8:	ffffc097          	auipc	ra,0xffffc
    800051ac:	cb8080e7          	jalr	-840(ra) # 80000e60 <safestrcpy>
  oldpagetable = p->pagetable;
    800051b0:	060bb503          	ld	a0,96(s7)
  p->pagetable = pagetable;
    800051b4:	076bb023          	sd	s6,96(s7)
  p->sz = sz;
    800051b8:	058bbc23          	sd	s8,88(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800051bc:	068bb783          	ld	a5,104(s7)
    800051c0:	e6843703          	ld	a4,-408(s0)
    800051c4:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800051c6:	068bb783          	ld	a5,104(s7)
    800051ca:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800051ce:	85ea                	mv	a1,s10
    800051d0:	ffffd097          	auipc	ra,0xffffd
    800051d4:	956080e7          	jalr	-1706(ra) # 80001b26 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800051d8:	0004851b          	sext.w	a0,s1
    800051dc:	bbc1                	j	80004fac <exec+0x9c>
    800051de:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    800051e2:	df843583          	ld	a1,-520(s0)
    800051e6:	855a                	mv	a0,s6
    800051e8:	ffffd097          	auipc	ra,0xffffd
    800051ec:	93e080e7          	jalr	-1730(ra) # 80001b26 <proc_freepagetable>
  if(ip){
    800051f0:	da0a94e3          	bnez	s5,80004f98 <exec+0x88>
  return -1;
    800051f4:	557d                	li	a0,-1
    800051f6:	bb5d                	j	80004fac <exec+0x9c>
    800051f8:	de943c23          	sd	s1,-520(s0)
    800051fc:	b7dd                	j	800051e2 <exec+0x2d2>
    800051fe:	de943c23          	sd	s1,-520(s0)
    80005202:	b7c5                	j	800051e2 <exec+0x2d2>
    80005204:	de943c23          	sd	s1,-520(s0)
    80005208:	bfe9                	j	800051e2 <exec+0x2d2>
  sz = sz1;
    8000520a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000520e:	4a81                	li	s5,0
    80005210:	bfc9                	j	800051e2 <exec+0x2d2>
  sz = sz1;
    80005212:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005216:	4a81                	li	s5,0
    80005218:	b7e9                	j	800051e2 <exec+0x2d2>
  sz = sz1;
    8000521a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000521e:	4a81                	li	s5,0
    80005220:	b7c9                	j	800051e2 <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005222:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005226:	e0843783          	ld	a5,-504(s0)
    8000522a:	0017869b          	addiw	a3,a5,1
    8000522e:	e0d43423          	sd	a3,-504(s0)
    80005232:	e0043783          	ld	a5,-512(s0)
    80005236:	0387879b          	addiw	a5,a5,56
    8000523a:	e8845703          	lhu	a4,-376(s0)
    8000523e:	e2e6d3e3          	bge	a3,a4,80005064 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005242:	2781                	sext.w	a5,a5
    80005244:	e0f43023          	sd	a5,-512(s0)
    80005248:	03800713          	li	a4,56
    8000524c:	86be                	mv	a3,a5
    8000524e:	e1840613          	addi	a2,s0,-488
    80005252:	4581                	li	a1,0
    80005254:	8556                	mv	a0,s5
    80005256:	fffff097          	auipc	ra,0xfffff
    8000525a:	a76080e7          	jalr	-1418(ra) # 80003ccc <readi>
    8000525e:	03800793          	li	a5,56
    80005262:	f6f51ee3          	bne	a0,a5,800051de <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    80005266:	e1842783          	lw	a5,-488(s0)
    8000526a:	4705                	li	a4,1
    8000526c:	fae79de3          	bne	a5,a4,80005226 <exec+0x316>
    if(ph.memsz < ph.filesz)
    80005270:	e4043603          	ld	a2,-448(s0)
    80005274:	e3843783          	ld	a5,-456(s0)
    80005278:	f8f660e3          	bltu	a2,a5,800051f8 <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000527c:	e2843783          	ld	a5,-472(s0)
    80005280:	963e                	add	a2,a2,a5
    80005282:	f6f66ee3          	bltu	a2,a5,800051fe <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005286:	85a6                	mv	a1,s1
    80005288:	855a                	mv	a0,s6
    8000528a:	ffffc097          	auipc	ra,0xffffc
    8000528e:	1b8080e7          	jalr	440(ra) # 80001442 <uvmalloc>
    80005292:	dea43c23          	sd	a0,-520(s0)
    80005296:	d53d                	beqz	a0,80005204 <exec+0x2f4>
    if((ph.vaddr % PGSIZE) != 0)
    80005298:	e2843c03          	ld	s8,-472(s0)
    8000529c:	de043783          	ld	a5,-544(s0)
    800052a0:	00fc77b3          	and	a5,s8,a5
    800052a4:	ff9d                	bnez	a5,800051e2 <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800052a6:	e2042c83          	lw	s9,-480(s0)
    800052aa:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800052ae:	f60b8ae3          	beqz	s7,80005222 <exec+0x312>
    800052b2:	89de                	mv	s3,s7
    800052b4:	4481                	li	s1,0
    800052b6:	b371                	j	80005042 <exec+0x132>

00000000800052b8 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800052b8:	7179                	addi	sp,sp,-48
    800052ba:	f406                	sd	ra,40(sp)
    800052bc:	f022                	sd	s0,32(sp)
    800052be:	ec26                	sd	s1,24(sp)
    800052c0:	e84a                	sd	s2,16(sp)
    800052c2:	1800                	addi	s0,sp,48
    800052c4:	892e                	mv	s2,a1
    800052c6:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800052c8:	fdc40593          	addi	a1,s0,-36
    800052cc:	ffffe097          	auipc	ra,0xffffe
    800052d0:	ad4080e7          	jalr	-1324(ra) # 80002da0 <argint>
    800052d4:	04054063          	bltz	a0,80005314 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800052d8:	fdc42703          	lw	a4,-36(s0)
    800052dc:	47bd                	li	a5,15
    800052de:	02e7ed63          	bltu	a5,a4,80005318 <argfd+0x60>
    800052e2:	ffffc097          	auipc	ra,0xffffc
    800052e6:	6e4080e7          	jalr	1764(ra) # 800019c6 <myproc>
    800052ea:	fdc42703          	lw	a4,-36(s0)
    800052ee:	01c70793          	addi	a5,a4,28 # fffffffffffff01c <end+0xffffffff7ffd901c>
    800052f2:	078e                	slli	a5,a5,0x3
    800052f4:	953e                	add	a0,a0,a5
    800052f6:	611c                	ld	a5,0(a0)
    800052f8:	c395                	beqz	a5,8000531c <argfd+0x64>
    return -1;
  if(pfd)
    800052fa:	00090463          	beqz	s2,80005302 <argfd+0x4a>
    *pfd = fd;
    800052fe:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005302:	4501                	li	a0,0
  if(pf)
    80005304:	c091                	beqz	s1,80005308 <argfd+0x50>
    *pf = f;
    80005306:	e09c                	sd	a5,0(s1)
}
    80005308:	70a2                	ld	ra,40(sp)
    8000530a:	7402                	ld	s0,32(sp)
    8000530c:	64e2                	ld	s1,24(sp)
    8000530e:	6942                	ld	s2,16(sp)
    80005310:	6145                	addi	sp,sp,48
    80005312:	8082                	ret
    return -1;
    80005314:	557d                	li	a0,-1
    80005316:	bfcd                	j	80005308 <argfd+0x50>
    return -1;
    80005318:	557d                	li	a0,-1
    8000531a:	b7fd                	j	80005308 <argfd+0x50>
    8000531c:	557d                	li	a0,-1
    8000531e:	b7ed                	j	80005308 <argfd+0x50>

0000000080005320 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005320:	1101                	addi	sp,sp,-32
    80005322:	ec06                	sd	ra,24(sp)
    80005324:	e822                	sd	s0,16(sp)
    80005326:	e426                	sd	s1,8(sp)
    80005328:	1000                	addi	s0,sp,32
    8000532a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000532c:	ffffc097          	auipc	ra,0xffffc
    80005330:	69a080e7          	jalr	1690(ra) # 800019c6 <myproc>
    80005334:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005336:	0e050793          	addi	a5,a0,224
    8000533a:	4501                	li	a0,0
    8000533c:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000533e:	6398                	ld	a4,0(a5)
    80005340:	cb19                	beqz	a4,80005356 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005342:	2505                	addiw	a0,a0,1
    80005344:	07a1                	addi	a5,a5,8
    80005346:	fed51ce3          	bne	a0,a3,8000533e <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000534a:	557d                	li	a0,-1
}
    8000534c:	60e2                	ld	ra,24(sp)
    8000534e:	6442                	ld	s0,16(sp)
    80005350:	64a2                	ld	s1,8(sp)
    80005352:	6105                	addi	sp,sp,32
    80005354:	8082                	ret
      p->ofile[fd] = f;
    80005356:	01c50793          	addi	a5,a0,28
    8000535a:	078e                	slli	a5,a5,0x3
    8000535c:	963e                	add	a2,a2,a5
    8000535e:	e204                	sd	s1,0(a2)
      return fd;
    80005360:	b7f5                	j	8000534c <fdalloc+0x2c>

0000000080005362 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005362:	715d                	addi	sp,sp,-80
    80005364:	e486                	sd	ra,72(sp)
    80005366:	e0a2                	sd	s0,64(sp)
    80005368:	fc26                	sd	s1,56(sp)
    8000536a:	f84a                	sd	s2,48(sp)
    8000536c:	f44e                	sd	s3,40(sp)
    8000536e:	f052                	sd	s4,32(sp)
    80005370:	ec56                	sd	s5,24(sp)
    80005372:	0880                	addi	s0,sp,80
    80005374:	89ae                	mv	s3,a1
    80005376:	8ab2                	mv	s5,a2
    80005378:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000537a:	fb040593          	addi	a1,s0,-80
    8000537e:	fffff097          	auipc	ra,0xfffff
    80005382:	e74080e7          	jalr	-396(ra) # 800041f2 <nameiparent>
    80005386:	892a                	mv	s2,a0
    80005388:	12050e63          	beqz	a0,800054c4 <create+0x162>
    return 0;

  ilock(dp);
    8000538c:	ffffe097          	auipc	ra,0xffffe
    80005390:	68c080e7          	jalr	1676(ra) # 80003a18 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005394:	4601                	li	a2,0
    80005396:	fb040593          	addi	a1,s0,-80
    8000539a:	854a                	mv	a0,s2
    8000539c:	fffff097          	auipc	ra,0xfffff
    800053a0:	b60080e7          	jalr	-1184(ra) # 80003efc <dirlookup>
    800053a4:	84aa                	mv	s1,a0
    800053a6:	c921                	beqz	a0,800053f6 <create+0x94>
    iunlockput(dp);
    800053a8:	854a                	mv	a0,s2
    800053aa:	fffff097          	auipc	ra,0xfffff
    800053ae:	8d0080e7          	jalr	-1840(ra) # 80003c7a <iunlockput>
    ilock(ip);
    800053b2:	8526                	mv	a0,s1
    800053b4:	ffffe097          	auipc	ra,0xffffe
    800053b8:	664080e7          	jalr	1636(ra) # 80003a18 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800053bc:	2981                	sext.w	s3,s3
    800053be:	4789                	li	a5,2
    800053c0:	02f99463          	bne	s3,a5,800053e8 <create+0x86>
    800053c4:	0444d783          	lhu	a5,68(s1)
    800053c8:	37f9                	addiw	a5,a5,-2
    800053ca:	17c2                	slli	a5,a5,0x30
    800053cc:	93c1                	srli	a5,a5,0x30
    800053ce:	4705                	li	a4,1
    800053d0:	00f76c63          	bltu	a4,a5,800053e8 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800053d4:	8526                	mv	a0,s1
    800053d6:	60a6                	ld	ra,72(sp)
    800053d8:	6406                	ld	s0,64(sp)
    800053da:	74e2                	ld	s1,56(sp)
    800053dc:	7942                	ld	s2,48(sp)
    800053de:	79a2                	ld	s3,40(sp)
    800053e0:	7a02                	ld	s4,32(sp)
    800053e2:	6ae2                	ld	s5,24(sp)
    800053e4:	6161                	addi	sp,sp,80
    800053e6:	8082                	ret
    iunlockput(ip);
    800053e8:	8526                	mv	a0,s1
    800053ea:	fffff097          	auipc	ra,0xfffff
    800053ee:	890080e7          	jalr	-1904(ra) # 80003c7a <iunlockput>
    return 0;
    800053f2:	4481                	li	s1,0
    800053f4:	b7c5                	j	800053d4 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800053f6:	85ce                	mv	a1,s3
    800053f8:	00092503          	lw	a0,0(s2)
    800053fc:	ffffe097          	auipc	ra,0xffffe
    80005400:	482080e7          	jalr	1154(ra) # 8000387e <ialloc>
    80005404:	84aa                	mv	s1,a0
    80005406:	c521                	beqz	a0,8000544e <create+0xec>
  ilock(ip);
    80005408:	ffffe097          	auipc	ra,0xffffe
    8000540c:	610080e7          	jalr	1552(ra) # 80003a18 <ilock>
  ip->major = major;
    80005410:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005414:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005418:	4a05                	li	s4,1
    8000541a:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    8000541e:	8526                	mv	a0,s1
    80005420:	ffffe097          	auipc	ra,0xffffe
    80005424:	52c080e7          	jalr	1324(ra) # 8000394c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005428:	2981                	sext.w	s3,s3
    8000542a:	03498a63          	beq	s3,s4,8000545e <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    8000542e:	40d0                	lw	a2,4(s1)
    80005430:	fb040593          	addi	a1,s0,-80
    80005434:	854a                	mv	a0,s2
    80005436:	fffff097          	auipc	ra,0xfffff
    8000543a:	cdc080e7          	jalr	-804(ra) # 80004112 <dirlink>
    8000543e:	06054b63          	bltz	a0,800054b4 <create+0x152>
  iunlockput(dp);
    80005442:	854a                	mv	a0,s2
    80005444:	fffff097          	auipc	ra,0xfffff
    80005448:	836080e7          	jalr	-1994(ra) # 80003c7a <iunlockput>
  return ip;
    8000544c:	b761                	j	800053d4 <create+0x72>
    panic("create: ialloc");
    8000544e:	00003517          	auipc	a0,0x3
    80005452:	2fa50513          	addi	a0,a0,762 # 80008748 <syscalls+0x2d0>
    80005456:	ffffb097          	auipc	ra,0xffffb
    8000545a:	0e4080e7          	jalr	228(ra) # 8000053a <panic>
    dp->nlink++;  // for ".."
    8000545e:	04a95783          	lhu	a5,74(s2)
    80005462:	2785                	addiw	a5,a5,1
    80005464:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005468:	854a                	mv	a0,s2
    8000546a:	ffffe097          	auipc	ra,0xffffe
    8000546e:	4e2080e7          	jalr	1250(ra) # 8000394c <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005472:	40d0                	lw	a2,4(s1)
    80005474:	00003597          	auipc	a1,0x3
    80005478:	2e458593          	addi	a1,a1,740 # 80008758 <syscalls+0x2e0>
    8000547c:	8526                	mv	a0,s1
    8000547e:	fffff097          	auipc	ra,0xfffff
    80005482:	c94080e7          	jalr	-876(ra) # 80004112 <dirlink>
    80005486:	00054f63          	bltz	a0,800054a4 <create+0x142>
    8000548a:	00492603          	lw	a2,4(s2)
    8000548e:	00003597          	auipc	a1,0x3
    80005492:	2d258593          	addi	a1,a1,722 # 80008760 <syscalls+0x2e8>
    80005496:	8526                	mv	a0,s1
    80005498:	fffff097          	auipc	ra,0xfffff
    8000549c:	c7a080e7          	jalr	-902(ra) # 80004112 <dirlink>
    800054a0:	f80557e3          	bgez	a0,8000542e <create+0xcc>
      panic("create dots");
    800054a4:	00003517          	auipc	a0,0x3
    800054a8:	2c450513          	addi	a0,a0,708 # 80008768 <syscalls+0x2f0>
    800054ac:	ffffb097          	auipc	ra,0xffffb
    800054b0:	08e080e7          	jalr	142(ra) # 8000053a <panic>
    panic("create: dirlink");
    800054b4:	00003517          	auipc	a0,0x3
    800054b8:	2c450513          	addi	a0,a0,708 # 80008778 <syscalls+0x300>
    800054bc:	ffffb097          	auipc	ra,0xffffb
    800054c0:	07e080e7          	jalr	126(ra) # 8000053a <panic>
    return 0;
    800054c4:	84aa                	mv	s1,a0
    800054c6:	b739                	j	800053d4 <create+0x72>

00000000800054c8 <sys_dup>:
{
    800054c8:	7179                	addi	sp,sp,-48
    800054ca:	f406                	sd	ra,40(sp)
    800054cc:	f022                	sd	s0,32(sp)
    800054ce:	ec26                	sd	s1,24(sp)
    800054d0:	e84a                	sd	s2,16(sp)
    800054d2:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800054d4:	fd840613          	addi	a2,s0,-40
    800054d8:	4581                	li	a1,0
    800054da:	4501                	li	a0,0
    800054dc:	00000097          	auipc	ra,0x0
    800054e0:	ddc080e7          	jalr	-548(ra) # 800052b8 <argfd>
    return -1;
    800054e4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800054e6:	02054363          	bltz	a0,8000550c <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    800054ea:	fd843903          	ld	s2,-40(s0)
    800054ee:	854a                	mv	a0,s2
    800054f0:	00000097          	auipc	ra,0x0
    800054f4:	e30080e7          	jalr	-464(ra) # 80005320 <fdalloc>
    800054f8:	84aa                	mv	s1,a0
    return -1;
    800054fa:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800054fc:	00054863          	bltz	a0,8000550c <sys_dup+0x44>
  filedup(f);
    80005500:	854a                	mv	a0,s2
    80005502:	fffff097          	auipc	ra,0xfffff
    80005506:	368080e7          	jalr	872(ra) # 8000486a <filedup>
  return fd;
    8000550a:	87a6                	mv	a5,s1
}
    8000550c:	853e                	mv	a0,a5
    8000550e:	70a2                	ld	ra,40(sp)
    80005510:	7402                	ld	s0,32(sp)
    80005512:	64e2                	ld	s1,24(sp)
    80005514:	6942                	ld	s2,16(sp)
    80005516:	6145                	addi	sp,sp,48
    80005518:	8082                	ret

000000008000551a <sys_read>:
{
    8000551a:	7179                	addi	sp,sp,-48
    8000551c:	f406                	sd	ra,40(sp)
    8000551e:	f022                	sd	s0,32(sp)
    80005520:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005522:	fe840613          	addi	a2,s0,-24
    80005526:	4581                	li	a1,0
    80005528:	4501                	li	a0,0
    8000552a:	00000097          	auipc	ra,0x0
    8000552e:	d8e080e7          	jalr	-626(ra) # 800052b8 <argfd>
    return -1;
    80005532:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005534:	04054163          	bltz	a0,80005576 <sys_read+0x5c>
    80005538:	fe440593          	addi	a1,s0,-28
    8000553c:	4509                	li	a0,2
    8000553e:	ffffe097          	auipc	ra,0xffffe
    80005542:	862080e7          	jalr	-1950(ra) # 80002da0 <argint>
    return -1;
    80005546:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005548:	02054763          	bltz	a0,80005576 <sys_read+0x5c>
    8000554c:	fd840593          	addi	a1,s0,-40
    80005550:	4505                	li	a0,1
    80005552:	ffffe097          	auipc	ra,0xffffe
    80005556:	870080e7          	jalr	-1936(ra) # 80002dc2 <argaddr>
    return -1;
    8000555a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000555c:	00054d63          	bltz	a0,80005576 <sys_read+0x5c>
  return fileread(f, p, n);
    80005560:	fe442603          	lw	a2,-28(s0)
    80005564:	fd843583          	ld	a1,-40(s0)
    80005568:	fe843503          	ld	a0,-24(s0)
    8000556c:	fffff097          	auipc	ra,0xfffff
    80005570:	48a080e7          	jalr	1162(ra) # 800049f6 <fileread>
    80005574:	87aa                	mv	a5,a0
}
    80005576:	853e                	mv	a0,a5
    80005578:	70a2                	ld	ra,40(sp)
    8000557a:	7402                	ld	s0,32(sp)
    8000557c:	6145                	addi	sp,sp,48
    8000557e:	8082                	ret

0000000080005580 <sys_write>:
{
    80005580:	7179                	addi	sp,sp,-48
    80005582:	f406                	sd	ra,40(sp)
    80005584:	f022                	sd	s0,32(sp)
    80005586:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005588:	fe840613          	addi	a2,s0,-24
    8000558c:	4581                	li	a1,0
    8000558e:	4501                	li	a0,0
    80005590:	00000097          	auipc	ra,0x0
    80005594:	d28080e7          	jalr	-728(ra) # 800052b8 <argfd>
    return -1;
    80005598:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000559a:	04054163          	bltz	a0,800055dc <sys_write+0x5c>
    8000559e:	fe440593          	addi	a1,s0,-28
    800055a2:	4509                	li	a0,2
    800055a4:	ffffd097          	auipc	ra,0xffffd
    800055a8:	7fc080e7          	jalr	2044(ra) # 80002da0 <argint>
    return -1;
    800055ac:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055ae:	02054763          	bltz	a0,800055dc <sys_write+0x5c>
    800055b2:	fd840593          	addi	a1,s0,-40
    800055b6:	4505                	li	a0,1
    800055b8:	ffffe097          	auipc	ra,0xffffe
    800055bc:	80a080e7          	jalr	-2038(ra) # 80002dc2 <argaddr>
    return -1;
    800055c0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055c2:	00054d63          	bltz	a0,800055dc <sys_write+0x5c>
  return filewrite(f, p, n);
    800055c6:	fe442603          	lw	a2,-28(s0)
    800055ca:	fd843583          	ld	a1,-40(s0)
    800055ce:	fe843503          	ld	a0,-24(s0)
    800055d2:	fffff097          	auipc	ra,0xfffff
    800055d6:	4e6080e7          	jalr	1254(ra) # 80004ab8 <filewrite>
    800055da:	87aa                	mv	a5,a0
}
    800055dc:	853e                	mv	a0,a5
    800055de:	70a2                	ld	ra,40(sp)
    800055e0:	7402                	ld	s0,32(sp)
    800055e2:	6145                	addi	sp,sp,48
    800055e4:	8082                	ret

00000000800055e6 <sys_close>:
{
    800055e6:	1101                	addi	sp,sp,-32
    800055e8:	ec06                	sd	ra,24(sp)
    800055ea:	e822                	sd	s0,16(sp)
    800055ec:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800055ee:	fe040613          	addi	a2,s0,-32
    800055f2:	fec40593          	addi	a1,s0,-20
    800055f6:	4501                	li	a0,0
    800055f8:	00000097          	auipc	ra,0x0
    800055fc:	cc0080e7          	jalr	-832(ra) # 800052b8 <argfd>
    return -1;
    80005600:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005602:	02054463          	bltz	a0,8000562a <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005606:	ffffc097          	auipc	ra,0xffffc
    8000560a:	3c0080e7          	jalr	960(ra) # 800019c6 <myproc>
    8000560e:	fec42783          	lw	a5,-20(s0)
    80005612:	07f1                	addi	a5,a5,28
    80005614:	078e                	slli	a5,a5,0x3
    80005616:	953e                	add	a0,a0,a5
    80005618:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000561c:	fe043503          	ld	a0,-32(s0)
    80005620:	fffff097          	auipc	ra,0xfffff
    80005624:	29c080e7          	jalr	668(ra) # 800048bc <fileclose>
  return 0;
    80005628:	4781                	li	a5,0
}
    8000562a:	853e                	mv	a0,a5
    8000562c:	60e2                	ld	ra,24(sp)
    8000562e:	6442                	ld	s0,16(sp)
    80005630:	6105                	addi	sp,sp,32
    80005632:	8082                	ret

0000000080005634 <sys_fstat>:
{
    80005634:	1101                	addi	sp,sp,-32
    80005636:	ec06                	sd	ra,24(sp)
    80005638:	e822                	sd	s0,16(sp)
    8000563a:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000563c:	fe840613          	addi	a2,s0,-24
    80005640:	4581                	li	a1,0
    80005642:	4501                	li	a0,0
    80005644:	00000097          	auipc	ra,0x0
    80005648:	c74080e7          	jalr	-908(ra) # 800052b8 <argfd>
    return -1;
    8000564c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000564e:	02054563          	bltz	a0,80005678 <sys_fstat+0x44>
    80005652:	fe040593          	addi	a1,s0,-32
    80005656:	4505                	li	a0,1
    80005658:	ffffd097          	auipc	ra,0xffffd
    8000565c:	76a080e7          	jalr	1898(ra) # 80002dc2 <argaddr>
    return -1;
    80005660:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005662:	00054b63          	bltz	a0,80005678 <sys_fstat+0x44>
  return filestat(f, st);
    80005666:	fe043583          	ld	a1,-32(s0)
    8000566a:	fe843503          	ld	a0,-24(s0)
    8000566e:	fffff097          	auipc	ra,0xfffff
    80005672:	316080e7          	jalr	790(ra) # 80004984 <filestat>
    80005676:	87aa                	mv	a5,a0
}
    80005678:	853e                	mv	a0,a5
    8000567a:	60e2                	ld	ra,24(sp)
    8000567c:	6442                	ld	s0,16(sp)
    8000567e:	6105                	addi	sp,sp,32
    80005680:	8082                	ret

0000000080005682 <sys_link>:
{
    80005682:	7169                	addi	sp,sp,-304
    80005684:	f606                	sd	ra,296(sp)
    80005686:	f222                	sd	s0,288(sp)
    80005688:	ee26                	sd	s1,280(sp)
    8000568a:	ea4a                	sd	s2,272(sp)
    8000568c:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000568e:	08000613          	li	a2,128
    80005692:	ed040593          	addi	a1,s0,-304
    80005696:	4501                	li	a0,0
    80005698:	ffffd097          	auipc	ra,0xffffd
    8000569c:	74c080e7          	jalr	1868(ra) # 80002de4 <argstr>
    return -1;
    800056a0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800056a2:	10054e63          	bltz	a0,800057be <sys_link+0x13c>
    800056a6:	08000613          	li	a2,128
    800056aa:	f5040593          	addi	a1,s0,-176
    800056ae:	4505                	li	a0,1
    800056b0:	ffffd097          	auipc	ra,0xffffd
    800056b4:	734080e7          	jalr	1844(ra) # 80002de4 <argstr>
    return -1;
    800056b8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800056ba:	10054263          	bltz	a0,800057be <sys_link+0x13c>
  begin_op();
    800056be:	fffff097          	auipc	ra,0xfffff
    800056c2:	d36080e7          	jalr	-714(ra) # 800043f4 <begin_op>
  if((ip = namei(old)) == 0){
    800056c6:	ed040513          	addi	a0,s0,-304
    800056ca:	fffff097          	auipc	ra,0xfffff
    800056ce:	b0a080e7          	jalr	-1270(ra) # 800041d4 <namei>
    800056d2:	84aa                	mv	s1,a0
    800056d4:	c551                	beqz	a0,80005760 <sys_link+0xde>
  ilock(ip);
    800056d6:	ffffe097          	auipc	ra,0xffffe
    800056da:	342080e7          	jalr	834(ra) # 80003a18 <ilock>
  if(ip->type == T_DIR){
    800056de:	04449703          	lh	a4,68(s1)
    800056e2:	4785                	li	a5,1
    800056e4:	08f70463          	beq	a4,a5,8000576c <sys_link+0xea>
  ip->nlink++;
    800056e8:	04a4d783          	lhu	a5,74(s1)
    800056ec:	2785                	addiw	a5,a5,1
    800056ee:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800056f2:	8526                	mv	a0,s1
    800056f4:	ffffe097          	auipc	ra,0xffffe
    800056f8:	258080e7          	jalr	600(ra) # 8000394c <iupdate>
  iunlock(ip);
    800056fc:	8526                	mv	a0,s1
    800056fe:	ffffe097          	auipc	ra,0xffffe
    80005702:	3dc080e7          	jalr	988(ra) # 80003ada <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005706:	fd040593          	addi	a1,s0,-48
    8000570a:	f5040513          	addi	a0,s0,-176
    8000570e:	fffff097          	auipc	ra,0xfffff
    80005712:	ae4080e7          	jalr	-1308(ra) # 800041f2 <nameiparent>
    80005716:	892a                	mv	s2,a0
    80005718:	c935                	beqz	a0,8000578c <sys_link+0x10a>
  ilock(dp);
    8000571a:	ffffe097          	auipc	ra,0xffffe
    8000571e:	2fe080e7          	jalr	766(ra) # 80003a18 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005722:	00092703          	lw	a4,0(s2)
    80005726:	409c                	lw	a5,0(s1)
    80005728:	04f71d63          	bne	a4,a5,80005782 <sys_link+0x100>
    8000572c:	40d0                	lw	a2,4(s1)
    8000572e:	fd040593          	addi	a1,s0,-48
    80005732:	854a                	mv	a0,s2
    80005734:	fffff097          	auipc	ra,0xfffff
    80005738:	9de080e7          	jalr	-1570(ra) # 80004112 <dirlink>
    8000573c:	04054363          	bltz	a0,80005782 <sys_link+0x100>
  iunlockput(dp);
    80005740:	854a                	mv	a0,s2
    80005742:	ffffe097          	auipc	ra,0xffffe
    80005746:	538080e7          	jalr	1336(ra) # 80003c7a <iunlockput>
  iput(ip);
    8000574a:	8526                	mv	a0,s1
    8000574c:	ffffe097          	auipc	ra,0xffffe
    80005750:	486080e7          	jalr	1158(ra) # 80003bd2 <iput>
  end_op();
    80005754:	fffff097          	auipc	ra,0xfffff
    80005758:	d1e080e7          	jalr	-738(ra) # 80004472 <end_op>
  return 0;
    8000575c:	4781                	li	a5,0
    8000575e:	a085                	j	800057be <sys_link+0x13c>
    end_op();
    80005760:	fffff097          	auipc	ra,0xfffff
    80005764:	d12080e7          	jalr	-750(ra) # 80004472 <end_op>
    return -1;
    80005768:	57fd                	li	a5,-1
    8000576a:	a891                	j	800057be <sys_link+0x13c>
    iunlockput(ip);
    8000576c:	8526                	mv	a0,s1
    8000576e:	ffffe097          	auipc	ra,0xffffe
    80005772:	50c080e7          	jalr	1292(ra) # 80003c7a <iunlockput>
    end_op();
    80005776:	fffff097          	auipc	ra,0xfffff
    8000577a:	cfc080e7          	jalr	-772(ra) # 80004472 <end_op>
    return -1;
    8000577e:	57fd                	li	a5,-1
    80005780:	a83d                	j	800057be <sys_link+0x13c>
    iunlockput(dp);
    80005782:	854a                	mv	a0,s2
    80005784:	ffffe097          	auipc	ra,0xffffe
    80005788:	4f6080e7          	jalr	1270(ra) # 80003c7a <iunlockput>
  ilock(ip);
    8000578c:	8526                	mv	a0,s1
    8000578e:	ffffe097          	auipc	ra,0xffffe
    80005792:	28a080e7          	jalr	650(ra) # 80003a18 <ilock>
  ip->nlink--;
    80005796:	04a4d783          	lhu	a5,74(s1)
    8000579a:	37fd                	addiw	a5,a5,-1
    8000579c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800057a0:	8526                	mv	a0,s1
    800057a2:	ffffe097          	auipc	ra,0xffffe
    800057a6:	1aa080e7          	jalr	426(ra) # 8000394c <iupdate>
  iunlockput(ip);
    800057aa:	8526                	mv	a0,s1
    800057ac:	ffffe097          	auipc	ra,0xffffe
    800057b0:	4ce080e7          	jalr	1230(ra) # 80003c7a <iunlockput>
  end_op();
    800057b4:	fffff097          	auipc	ra,0xfffff
    800057b8:	cbe080e7          	jalr	-834(ra) # 80004472 <end_op>
  return -1;
    800057bc:	57fd                	li	a5,-1
}
    800057be:	853e                	mv	a0,a5
    800057c0:	70b2                	ld	ra,296(sp)
    800057c2:	7412                	ld	s0,288(sp)
    800057c4:	64f2                	ld	s1,280(sp)
    800057c6:	6952                	ld	s2,272(sp)
    800057c8:	6155                	addi	sp,sp,304
    800057ca:	8082                	ret

00000000800057cc <sys_unlink>:
{
    800057cc:	7151                	addi	sp,sp,-240
    800057ce:	f586                	sd	ra,232(sp)
    800057d0:	f1a2                	sd	s0,224(sp)
    800057d2:	eda6                	sd	s1,216(sp)
    800057d4:	e9ca                	sd	s2,208(sp)
    800057d6:	e5ce                	sd	s3,200(sp)
    800057d8:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800057da:	08000613          	li	a2,128
    800057de:	f3040593          	addi	a1,s0,-208
    800057e2:	4501                	li	a0,0
    800057e4:	ffffd097          	auipc	ra,0xffffd
    800057e8:	600080e7          	jalr	1536(ra) # 80002de4 <argstr>
    800057ec:	18054163          	bltz	a0,8000596e <sys_unlink+0x1a2>
  begin_op();
    800057f0:	fffff097          	auipc	ra,0xfffff
    800057f4:	c04080e7          	jalr	-1020(ra) # 800043f4 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800057f8:	fb040593          	addi	a1,s0,-80
    800057fc:	f3040513          	addi	a0,s0,-208
    80005800:	fffff097          	auipc	ra,0xfffff
    80005804:	9f2080e7          	jalr	-1550(ra) # 800041f2 <nameiparent>
    80005808:	84aa                	mv	s1,a0
    8000580a:	c979                	beqz	a0,800058e0 <sys_unlink+0x114>
  ilock(dp);
    8000580c:	ffffe097          	auipc	ra,0xffffe
    80005810:	20c080e7          	jalr	524(ra) # 80003a18 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005814:	00003597          	auipc	a1,0x3
    80005818:	f4458593          	addi	a1,a1,-188 # 80008758 <syscalls+0x2e0>
    8000581c:	fb040513          	addi	a0,s0,-80
    80005820:	ffffe097          	auipc	ra,0xffffe
    80005824:	6c2080e7          	jalr	1730(ra) # 80003ee2 <namecmp>
    80005828:	14050a63          	beqz	a0,8000597c <sys_unlink+0x1b0>
    8000582c:	00003597          	auipc	a1,0x3
    80005830:	f3458593          	addi	a1,a1,-204 # 80008760 <syscalls+0x2e8>
    80005834:	fb040513          	addi	a0,s0,-80
    80005838:	ffffe097          	auipc	ra,0xffffe
    8000583c:	6aa080e7          	jalr	1706(ra) # 80003ee2 <namecmp>
    80005840:	12050e63          	beqz	a0,8000597c <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005844:	f2c40613          	addi	a2,s0,-212
    80005848:	fb040593          	addi	a1,s0,-80
    8000584c:	8526                	mv	a0,s1
    8000584e:	ffffe097          	auipc	ra,0xffffe
    80005852:	6ae080e7          	jalr	1710(ra) # 80003efc <dirlookup>
    80005856:	892a                	mv	s2,a0
    80005858:	12050263          	beqz	a0,8000597c <sys_unlink+0x1b0>
  ilock(ip);
    8000585c:	ffffe097          	auipc	ra,0xffffe
    80005860:	1bc080e7          	jalr	444(ra) # 80003a18 <ilock>
  if(ip->nlink < 1)
    80005864:	04a91783          	lh	a5,74(s2)
    80005868:	08f05263          	blez	a5,800058ec <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000586c:	04491703          	lh	a4,68(s2)
    80005870:	4785                	li	a5,1
    80005872:	08f70563          	beq	a4,a5,800058fc <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005876:	4641                	li	a2,16
    80005878:	4581                	li	a1,0
    8000587a:	fc040513          	addi	a0,s0,-64
    8000587e:	ffffb097          	auipc	ra,0xffffb
    80005882:	498080e7          	jalr	1176(ra) # 80000d16 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005886:	4741                	li	a4,16
    80005888:	f2c42683          	lw	a3,-212(s0)
    8000588c:	fc040613          	addi	a2,s0,-64
    80005890:	4581                	li	a1,0
    80005892:	8526                	mv	a0,s1
    80005894:	ffffe097          	auipc	ra,0xffffe
    80005898:	530080e7          	jalr	1328(ra) # 80003dc4 <writei>
    8000589c:	47c1                	li	a5,16
    8000589e:	0af51563          	bne	a0,a5,80005948 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800058a2:	04491703          	lh	a4,68(s2)
    800058a6:	4785                	li	a5,1
    800058a8:	0af70863          	beq	a4,a5,80005958 <sys_unlink+0x18c>
  iunlockput(dp);
    800058ac:	8526                	mv	a0,s1
    800058ae:	ffffe097          	auipc	ra,0xffffe
    800058b2:	3cc080e7          	jalr	972(ra) # 80003c7a <iunlockput>
  ip->nlink--;
    800058b6:	04a95783          	lhu	a5,74(s2)
    800058ba:	37fd                	addiw	a5,a5,-1
    800058bc:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800058c0:	854a                	mv	a0,s2
    800058c2:	ffffe097          	auipc	ra,0xffffe
    800058c6:	08a080e7          	jalr	138(ra) # 8000394c <iupdate>
  iunlockput(ip);
    800058ca:	854a                	mv	a0,s2
    800058cc:	ffffe097          	auipc	ra,0xffffe
    800058d0:	3ae080e7          	jalr	942(ra) # 80003c7a <iunlockput>
  end_op();
    800058d4:	fffff097          	auipc	ra,0xfffff
    800058d8:	b9e080e7          	jalr	-1122(ra) # 80004472 <end_op>
  return 0;
    800058dc:	4501                	li	a0,0
    800058de:	a84d                	j	80005990 <sys_unlink+0x1c4>
    end_op();
    800058e0:	fffff097          	auipc	ra,0xfffff
    800058e4:	b92080e7          	jalr	-1134(ra) # 80004472 <end_op>
    return -1;
    800058e8:	557d                	li	a0,-1
    800058ea:	a05d                	j	80005990 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800058ec:	00003517          	auipc	a0,0x3
    800058f0:	e9c50513          	addi	a0,a0,-356 # 80008788 <syscalls+0x310>
    800058f4:	ffffb097          	auipc	ra,0xffffb
    800058f8:	c46080e7          	jalr	-954(ra) # 8000053a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800058fc:	04c92703          	lw	a4,76(s2)
    80005900:	02000793          	li	a5,32
    80005904:	f6e7f9e3          	bgeu	a5,a4,80005876 <sys_unlink+0xaa>
    80005908:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000590c:	4741                	li	a4,16
    8000590e:	86ce                	mv	a3,s3
    80005910:	f1840613          	addi	a2,s0,-232
    80005914:	4581                	li	a1,0
    80005916:	854a                	mv	a0,s2
    80005918:	ffffe097          	auipc	ra,0xffffe
    8000591c:	3b4080e7          	jalr	948(ra) # 80003ccc <readi>
    80005920:	47c1                	li	a5,16
    80005922:	00f51b63          	bne	a0,a5,80005938 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005926:	f1845783          	lhu	a5,-232(s0)
    8000592a:	e7a1                	bnez	a5,80005972 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000592c:	29c1                	addiw	s3,s3,16
    8000592e:	04c92783          	lw	a5,76(s2)
    80005932:	fcf9ede3          	bltu	s3,a5,8000590c <sys_unlink+0x140>
    80005936:	b781                	j	80005876 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005938:	00003517          	auipc	a0,0x3
    8000593c:	e6850513          	addi	a0,a0,-408 # 800087a0 <syscalls+0x328>
    80005940:	ffffb097          	auipc	ra,0xffffb
    80005944:	bfa080e7          	jalr	-1030(ra) # 8000053a <panic>
    panic("unlink: writei");
    80005948:	00003517          	auipc	a0,0x3
    8000594c:	e7050513          	addi	a0,a0,-400 # 800087b8 <syscalls+0x340>
    80005950:	ffffb097          	auipc	ra,0xffffb
    80005954:	bea080e7          	jalr	-1046(ra) # 8000053a <panic>
    dp->nlink--;
    80005958:	04a4d783          	lhu	a5,74(s1)
    8000595c:	37fd                	addiw	a5,a5,-1
    8000595e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005962:	8526                	mv	a0,s1
    80005964:	ffffe097          	auipc	ra,0xffffe
    80005968:	fe8080e7          	jalr	-24(ra) # 8000394c <iupdate>
    8000596c:	b781                	j	800058ac <sys_unlink+0xe0>
    return -1;
    8000596e:	557d                	li	a0,-1
    80005970:	a005                	j	80005990 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005972:	854a                	mv	a0,s2
    80005974:	ffffe097          	auipc	ra,0xffffe
    80005978:	306080e7          	jalr	774(ra) # 80003c7a <iunlockput>
  iunlockput(dp);
    8000597c:	8526                	mv	a0,s1
    8000597e:	ffffe097          	auipc	ra,0xffffe
    80005982:	2fc080e7          	jalr	764(ra) # 80003c7a <iunlockput>
  end_op();
    80005986:	fffff097          	auipc	ra,0xfffff
    8000598a:	aec080e7          	jalr	-1300(ra) # 80004472 <end_op>
  return -1;
    8000598e:	557d                	li	a0,-1
}
    80005990:	70ae                	ld	ra,232(sp)
    80005992:	740e                	ld	s0,224(sp)
    80005994:	64ee                	ld	s1,216(sp)
    80005996:	694e                	ld	s2,208(sp)
    80005998:	69ae                	ld	s3,200(sp)
    8000599a:	616d                	addi	sp,sp,240
    8000599c:	8082                	ret

000000008000599e <sys_open>:

uint64
sys_open(void)
{
    8000599e:	7131                	addi	sp,sp,-192
    800059a0:	fd06                	sd	ra,184(sp)
    800059a2:	f922                	sd	s0,176(sp)
    800059a4:	f526                	sd	s1,168(sp)
    800059a6:	f14a                	sd	s2,160(sp)
    800059a8:	ed4e                	sd	s3,152(sp)
    800059aa:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800059ac:	08000613          	li	a2,128
    800059b0:	f5040593          	addi	a1,s0,-176
    800059b4:	4501                	li	a0,0
    800059b6:	ffffd097          	auipc	ra,0xffffd
    800059ba:	42e080e7          	jalr	1070(ra) # 80002de4 <argstr>
    return -1;
    800059be:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800059c0:	0c054163          	bltz	a0,80005a82 <sys_open+0xe4>
    800059c4:	f4c40593          	addi	a1,s0,-180
    800059c8:	4505                	li	a0,1
    800059ca:	ffffd097          	auipc	ra,0xffffd
    800059ce:	3d6080e7          	jalr	982(ra) # 80002da0 <argint>
    800059d2:	0a054863          	bltz	a0,80005a82 <sys_open+0xe4>

  begin_op();
    800059d6:	fffff097          	auipc	ra,0xfffff
    800059da:	a1e080e7          	jalr	-1506(ra) # 800043f4 <begin_op>

  if(omode & O_CREATE){
    800059de:	f4c42783          	lw	a5,-180(s0)
    800059e2:	2007f793          	andi	a5,a5,512
    800059e6:	cbdd                	beqz	a5,80005a9c <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800059e8:	4681                	li	a3,0
    800059ea:	4601                	li	a2,0
    800059ec:	4589                	li	a1,2
    800059ee:	f5040513          	addi	a0,s0,-176
    800059f2:	00000097          	auipc	ra,0x0
    800059f6:	970080e7          	jalr	-1680(ra) # 80005362 <create>
    800059fa:	892a                	mv	s2,a0
    if(ip == 0){
    800059fc:	c959                	beqz	a0,80005a92 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800059fe:	04491703          	lh	a4,68(s2)
    80005a02:	478d                	li	a5,3
    80005a04:	00f71763          	bne	a4,a5,80005a12 <sys_open+0x74>
    80005a08:	04695703          	lhu	a4,70(s2)
    80005a0c:	47a5                	li	a5,9
    80005a0e:	0ce7ec63          	bltu	a5,a4,80005ae6 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005a12:	fffff097          	auipc	ra,0xfffff
    80005a16:	dee080e7          	jalr	-530(ra) # 80004800 <filealloc>
    80005a1a:	89aa                	mv	s3,a0
    80005a1c:	10050263          	beqz	a0,80005b20 <sys_open+0x182>
    80005a20:	00000097          	auipc	ra,0x0
    80005a24:	900080e7          	jalr	-1792(ra) # 80005320 <fdalloc>
    80005a28:	84aa                	mv	s1,a0
    80005a2a:	0e054663          	bltz	a0,80005b16 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005a2e:	04491703          	lh	a4,68(s2)
    80005a32:	478d                	li	a5,3
    80005a34:	0cf70463          	beq	a4,a5,80005afc <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005a38:	4789                	li	a5,2
    80005a3a:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005a3e:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005a42:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005a46:	f4c42783          	lw	a5,-180(s0)
    80005a4a:	0017c713          	xori	a4,a5,1
    80005a4e:	8b05                	andi	a4,a4,1
    80005a50:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005a54:	0037f713          	andi	a4,a5,3
    80005a58:	00e03733          	snez	a4,a4
    80005a5c:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005a60:	4007f793          	andi	a5,a5,1024
    80005a64:	c791                	beqz	a5,80005a70 <sys_open+0xd2>
    80005a66:	04491703          	lh	a4,68(s2)
    80005a6a:	4789                	li	a5,2
    80005a6c:	08f70f63          	beq	a4,a5,80005b0a <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005a70:	854a                	mv	a0,s2
    80005a72:	ffffe097          	auipc	ra,0xffffe
    80005a76:	068080e7          	jalr	104(ra) # 80003ada <iunlock>
  end_op();
    80005a7a:	fffff097          	auipc	ra,0xfffff
    80005a7e:	9f8080e7          	jalr	-1544(ra) # 80004472 <end_op>

  return fd;
}
    80005a82:	8526                	mv	a0,s1
    80005a84:	70ea                	ld	ra,184(sp)
    80005a86:	744a                	ld	s0,176(sp)
    80005a88:	74aa                	ld	s1,168(sp)
    80005a8a:	790a                	ld	s2,160(sp)
    80005a8c:	69ea                	ld	s3,152(sp)
    80005a8e:	6129                	addi	sp,sp,192
    80005a90:	8082                	ret
      end_op();
    80005a92:	fffff097          	auipc	ra,0xfffff
    80005a96:	9e0080e7          	jalr	-1568(ra) # 80004472 <end_op>
      return -1;
    80005a9a:	b7e5                	j	80005a82 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005a9c:	f5040513          	addi	a0,s0,-176
    80005aa0:	ffffe097          	auipc	ra,0xffffe
    80005aa4:	734080e7          	jalr	1844(ra) # 800041d4 <namei>
    80005aa8:	892a                	mv	s2,a0
    80005aaa:	c905                	beqz	a0,80005ada <sys_open+0x13c>
    ilock(ip);
    80005aac:	ffffe097          	auipc	ra,0xffffe
    80005ab0:	f6c080e7          	jalr	-148(ra) # 80003a18 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005ab4:	04491703          	lh	a4,68(s2)
    80005ab8:	4785                	li	a5,1
    80005aba:	f4f712e3          	bne	a4,a5,800059fe <sys_open+0x60>
    80005abe:	f4c42783          	lw	a5,-180(s0)
    80005ac2:	dba1                	beqz	a5,80005a12 <sys_open+0x74>
      iunlockput(ip);
    80005ac4:	854a                	mv	a0,s2
    80005ac6:	ffffe097          	auipc	ra,0xffffe
    80005aca:	1b4080e7          	jalr	436(ra) # 80003c7a <iunlockput>
      end_op();
    80005ace:	fffff097          	auipc	ra,0xfffff
    80005ad2:	9a4080e7          	jalr	-1628(ra) # 80004472 <end_op>
      return -1;
    80005ad6:	54fd                	li	s1,-1
    80005ad8:	b76d                	j	80005a82 <sys_open+0xe4>
      end_op();
    80005ada:	fffff097          	auipc	ra,0xfffff
    80005ade:	998080e7          	jalr	-1640(ra) # 80004472 <end_op>
      return -1;
    80005ae2:	54fd                	li	s1,-1
    80005ae4:	bf79                	j	80005a82 <sys_open+0xe4>
    iunlockput(ip);
    80005ae6:	854a                	mv	a0,s2
    80005ae8:	ffffe097          	auipc	ra,0xffffe
    80005aec:	192080e7          	jalr	402(ra) # 80003c7a <iunlockput>
    end_op();
    80005af0:	fffff097          	auipc	ra,0xfffff
    80005af4:	982080e7          	jalr	-1662(ra) # 80004472 <end_op>
    return -1;
    80005af8:	54fd                	li	s1,-1
    80005afa:	b761                	j	80005a82 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005afc:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005b00:	04691783          	lh	a5,70(s2)
    80005b04:	02f99223          	sh	a5,36(s3)
    80005b08:	bf2d                	j	80005a42 <sys_open+0xa4>
    itrunc(ip);
    80005b0a:	854a                	mv	a0,s2
    80005b0c:	ffffe097          	auipc	ra,0xffffe
    80005b10:	01a080e7          	jalr	26(ra) # 80003b26 <itrunc>
    80005b14:	bfb1                	j	80005a70 <sys_open+0xd2>
      fileclose(f);
    80005b16:	854e                	mv	a0,s3
    80005b18:	fffff097          	auipc	ra,0xfffff
    80005b1c:	da4080e7          	jalr	-604(ra) # 800048bc <fileclose>
    iunlockput(ip);
    80005b20:	854a                	mv	a0,s2
    80005b22:	ffffe097          	auipc	ra,0xffffe
    80005b26:	158080e7          	jalr	344(ra) # 80003c7a <iunlockput>
    end_op();
    80005b2a:	fffff097          	auipc	ra,0xfffff
    80005b2e:	948080e7          	jalr	-1720(ra) # 80004472 <end_op>
    return -1;
    80005b32:	54fd                	li	s1,-1
    80005b34:	b7b9                	j	80005a82 <sys_open+0xe4>

0000000080005b36 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005b36:	7175                	addi	sp,sp,-144
    80005b38:	e506                	sd	ra,136(sp)
    80005b3a:	e122                	sd	s0,128(sp)
    80005b3c:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005b3e:	fffff097          	auipc	ra,0xfffff
    80005b42:	8b6080e7          	jalr	-1866(ra) # 800043f4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005b46:	08000613          	li	a2,128
    80005b4a:	f7040593          	addi	a1,s0,-144
    80005b4e:	4501                	li	a0,0
    80005b50:	ffffd097          	auipc	ra,0xffffd
    80005b54:	294080e7          	jalr	660(ra) # 80002de4 <argstr>
    80005b58:	02054963          	bltz	a0,80005b8a <sys_mkdir+0x54>
    80005b5c:	4681                	li	a3,0
    80005b5e:	4601                	li	a2,0
    80005b60:	4585                	li	a1,1
    80005b62:	f7040513          	addi	a0,s0,-144
    80005b66:	fffff097          	auipc	ra,0xfffff
    80005b6a:	7fc080e7          	jalr	2044(ra) # 80005362 <create>
    80005b6e:	cd11                	beqz	a0,80005b8a <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b70:	ffffe097          	auipc	ra,0xffffe
    80005b74:	10a080e7          	jalr	266(ra) # 80003c7a <iunlockput>
  end_op();
    80005b78:	fffff097          	auipc	ra,0xfffff
    80005b7c:	8fa080e7          	jalr	-1798(ra) # 80004472 <end_op>
  return 0;
    80005b80:	4501                	li	a0,0
}
    80005b82:	60aa                	ld	ra,136(sp)
    80005b84:	640a                	ld	s0,128(sp)
    80005b86:	6149                	addi	sp,sp,144
    80005b88:	8082                	ret
    end_op();
    80005b8a:	fffff097          	auipc	ra,0xfffff
    80005b8e:	8e8080e7          	jalr	-1816(ra) # 80004472 <end_op>
    return -1;
    80005b92:	557d                	li	a0,-1
    80005b94:	b7fd                	j	80005b82 <sys_mkdir+0x4c>

0000000080005b96 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005b96:	7135                	addi	sp,sp,-160
    80005b98:	ed06                	sd	ra,152(sp)
    80005b9a:	e922                	sd	s0,144(sp)
    80005b9c:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005b9e:	fffff097          	auipc	ra,0xfffff
    80005ba2:	856080e7          	jalr	-1962(ra) # 800043f4 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005ba6:	08000613          	li	a2,128
    80005baa:	f7040593          	addi	a1,s0,-144
    80005bae:	4501                	li	a0,0
    80005bb0:	ffffd097          	auipc	ra,0xffffd
    80005bb4:	234080e7          	jalr	564(ra) # 80002de4 <argstr>
    80005bb8:	04054a63          	bltz	a0,80005c0c <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005bbc:	f6c40593          	addi	a1,s0,-148
    80005bc0:	4505                	li	a0,1
    80005bc2:	ffffd097          	auipc	ra,0xffffd
    80005bc6:	1de080e7          	jalr	478(ra) # 80002da0 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005bca:	04054163          	bltz	a0,80005c0c <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005bce:	f6840593          	addi	a1,s0,-152
    80005bd2:	4509                	li	a0,2
    80005bd4:	ffffd097          	auipc	ra,0xffffd
    80005bd8:	1cc080e7          	jalr	460(ra) # 80002da0 <argint>
     argint(1, &major) < 0 ||
    80005bdc:	02054863          	bltz	a0,80005c0c <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005be0:	f6841683          	lh	a3,-152(s0)
    80005be4:	f6c41603          	lh	a2,-148(s0)
    80005be8:	458d                	li	a1,3
    80005bea:	f7040513          	addi	a0,s0,-144
    80005bee:	fffff097          	auipc	ra,0xfffff
    80005bf2:	774080e7          	jalr	1908(ra) # 80005362 <create>
     argint(2, &minor) < 0 ||
    80005bf6:	c919                	beqz	a0,80005c0c <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005bf8:	ffffe097          	auipc	ra,0xffffe
    80005bfc:	082080e7          	jalr	130(ra) # 80003c7a <iunlockput>
  end_op();
    80005c00:	fffff097          	auipc	ra,0xfffff
    80005c04:	872080e7          	jalr	-1934(ra) # 80004472 <end_op>
  return 0;
    80005c08:	4501                	li	a0,0
    80005c0a:	a031                	j	80005c16 <sys_mknod+0x80>
    end_op();
    80005c0c:	fffff097          	auipc	ra,0xfffff
    80005c10:	866080e7          	jalr	-1946(ra) # 80004472 <end_op>
    return -1;
    80005c14:	557d                	li	a0,-1
}
    80005c16:	60ea                	ld	ra,152(sp)
    80005c18:	644a                	ld	s0,144(sp)
    80005c1a:	610d                	addi	sp,sp,160
    80005c1c:	8082                	ret

0000000080005c1e <sys_chdir>:

uint64
sys_chdir(void)
{
    80005c1e:	7135                	addi	sp,sp,-160
    80005c20:	ed06                	sd	ra,152(sp)
    80005c22:	e922                	sd	s0,144(sp)
    80005c24:	e526                	sd	s1,136(sp)
    80005c26:	e14a                	sd	s2,128(sp)
    80005c28:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005c2a:	ffffc097          	auipc	ra,0xffffc
    80005c2e:	d9c080e7          	jalr	-612(ra) # 800019c6 <myproc>
    80005c32:	892a                	mv	s2,a0
  
  begin_op();
    80005c34:	ffffe097          	auipc	ra,0xffffe
    80005c38:	7c0080e7          	jalr	1984(ra) # 800043f4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005c3c:	08000613          	li	a2,128
    80005c40:	f6040593          	addi	a1,s0,-160
    80005c44:	4501                	li	a0,0
    80005c46:	ffffd097          	auipc	ra,0xffffd
    80005c4a:	19e080e7          	jalr	414(ra) # 80002de4 <argstr>
    80005c4e:	04054b63          	bltz	a0,80005ca4 <sys_chdir+0x86>
    80005c52:	f6040513          	addi	a0,s0,-160
    80005c56:	ffffe097          	auipc	ra,0xffffe
    80005c5a:	57e080e7          	jalr	1406(ra) # 800041d4 <namei>
    80005c5e:	84aa                	mv	s1,a0
    80005c60:	c131                	beqz	a0,80005ca4 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005c62:	ffffe097          	auipc	ra,0xffffe
    80005c66:	db6080e7          	jalr	-586(ra) # 80003a18 <ilock>
  if(ip->type != T_DIR){
    80005c6a:	04449703          	lh	a4,68(s1)
    80005c6e:	4785                	li	a5,1
    80005c70:	04f71063          	bne	a4,a5,80005cb0 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005c74:	8526                	mv	a0,s1
    80005c76:	ffffe097          	auipc	ra,0xffffe
    80005c7a:	e64080e7          	jalr	-412(ra) # 80003ada <iunlock>
  iput(p->cwd);
    80005c7e:	16093503          	ld	a0,352(s2)
    80005c82:	ffffe097          	auipc	ra,0xffffe
    80005c86:	f50080e7          	jalr	-176(ra) # 80003bd2 <iput>
  end_op();
    80005c8a:	ffffe097          	auipc	ra,0xffffe
    80005c8e:	7e8080e7          	jalr	2024(ra) # 80004472 <end_op>
  p->cwd = ip;
    80005c92:	16993023          	sd	s1,352(s2)
  return 0;
    80005c96:	4501                	li	a0,0
}
    80005c98:	60ea                	ld	ra,152(sp)
    80005c9a:	644a                	ld	s0,144(sp)
    80005c9c:	64aa                	ld	s1,136(sp)
    80005c9e:	690a                	ld	s2,128(sp)
    80005ca0:	610d                	addi	sp,sp,160
    80005ca2:	8082                	ret
    end_op();
    80005ca4:	ffffe097          	auipc	ra,0xffffe
    80005ca8:	7ce080e7          	jalr	1998(ra) # 80004472 <end_op>
    return -1;
    80005cac:	557d                	li	a0,-1
    80005cae:	b7ed                	j	80005c98 <sys_chdir+0x7a>
    iunlockput(ip);
    80005cb0:	8526                	mv	a0,s1
    80005cb2:	ffffe097          	auipc	ra,0xffffe
    80005cb6:	fc8080e7          	jalr	-56(ra) # 80003c7a <iunlockput>
    end_op();
    80005cba:	ffffe097          	auipc	ra,0xffffe
    80005cbe:	7b8080e7          	jalr	1976(ra) # 80004472 <end_op>
    return -1;
    80005cc2:	557d                	li	a0,-1
    80005cc4:	bfd1                	j	80005c98 <sys_chdir+0x7a>

0000000080005cc6 <sys_exec>:

uint64
sys_exec(void)
{
    80005cc6:	7145                	addi	sp,sp,-464
    80005cc8:	e786                	sd	ra,456(sp)
    80005cca:	e3a2                	sd	s0,448(sp)
    80005ccc:	ff26                	sd	s1,440(sp)
    80005cce:	fb4a                	sd	s2,432(sp)
    80005cd0:	f74e                	sd	s3,424(sp)
    80005cd2:	f352                	sd	s4,416(sp)
    80005cd4:	ef56                	sd	s5,408(sp)
    80005cd6:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005cd8:	08000613          	li	a2,128
    80005cdc:	f4040593          	addi	a1,s0,-192
    80005ce0:	4501                	li	a0,0
    80005ce2:	ffffd097          	auipc	ra,0xffffd
    80005ce6:	102080e7          	jalr	258(ra) # 80002de4 <argstr>
    return -1;
    80005cea:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005cec:	0c054b63          	bltz	a0,80005dc2 <sys_exec+0xfc>
    80005cf0:	e3840593          	addi	a1,s0,-456
    80005cf4:	4505                	li	a0,1
    80005cf6:	ffffd097          	auipc	ra,0xffffd
    80005cfa:	0cc080e7          	jalr	204(ra) # 80002dc2 <argaddr>
    80005cfe:	0c054263          	bltz	a0,80005dc2 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    80005d02:	10000613          	li	a2,256
    80005d06:	4581                	li	a1,0
    80005d08:	e4040513          	addi	a0,s0,-448
    80005d0c:	ffffb097          	auipc	ra,0xffffb
    80005d10:	00a080e7          	jalr	10(ra) # 80000d16 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005d14:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005d18:	89a6                	mv	s3,s1
    80005d1a:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005d1c:	02000a13          	li	s4,32
    80005d20:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005d24:	00391513          	slli	a0,s2,0x3
    80005d28:	e3040593          	addi	a1,s0,-464
    80005d2c:	e3843783          	ld	a5,-456(s0)
    80005d30:	953e                	add	a0,a0,a5
    80005d32:	ffffd097          	auipc	ra,0xffffd
    80005d36:	fd4080e7          	jalr	-44(ra) # 80002d06 <fetchaddr>
    80005d3a:	02054a63          	bltz	a0,80005d6e <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005d3e:	e3043783          	ld	a5,-464(s0)
    80005d42:	c3b9                	beqz	a5,80005d88 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005d44:	ffffb097          	auipc	ra,0xffffb
    80005d48:	d9c080e7          	jalr	-612(ra) # 80000ae0 <kalloc>
    80005d4c:	85aa                	mv	a1,a0
    80005d4e:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005d52:	cd11                	beqz	a0,80005d6e <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005d54:	6605                	lui	a2,0x1
    80005d56:	e3043503          	ld	a0,-464(s0)
    80005d5a:	ffffd097          	auipc	ra,0xffffd
    80005d5e:	ffe080e7          	jalr	-2(ra) # 80002d58 <fetchstr>
    80005d62:	00054663          	bltz	a0,80005d6e <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005d66:	0905                	addi	s2,s2,1
    80005d68:	09a1                	addi	s3,s3,8
    80005d6a:	fb491be3          	bne	s2,s4,80005d20 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d6e:	f4040913          	addi	s2,s0,-192
    80005d72:	6088                	ld	a0,0(s1)
    80005d74:	c531                	beqz	a0,80005dc0 <sys_exec+0xfa>
    kfree(argv[i]);
    80005d76:	ffffb097          	auipc	ra,0xffffb
    80005d7a:	c6c080e7          	jalr	-916(ra) # 800009e2 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d7e:	04a1                	addi	s1,s1,8
    80005d80:	ff2499e3          	bne	s1,s2,80005d72 <sys_exec+0xac>
  return -1;
    80005d84:	597d                	li	s2,-1
    80005d86:	a835                	j	80005dc2 <sys_exec+0xfc>
      argv[i] = 0;
    80005d88:	0a8e                	slli	s5,s5,0x3
    80005d8a:	fc0a8793          	addi	a5,s5,-64 # ffffffffffffefc0 <end+0xffffffff7ffd8fc0>
    80005d8e:	00878ab3          	add	s5,a5,s0
    80005d92:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005d96:	e4040593          	addi	a1,s0,-448
    80005d9a:	f4040513          	addi	a0,s0,-192
    80005d9e:	fffff097          	auipc	ra,0xfffff
    80005da2:	172080e7          	jalr	370(ra) # 80004f10 <exec>
    80005da6:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005da8:	f4040993          	addi	s3,s0,-192
    80005dac:	6088                	ld	a0,0(s1)
    80005dae:	c911                	beqz	a0,80005dc2 <sys_exec+0xfc>
    kfree(argv[i]);
    80005db0:	ffffb097          	auipc	ra,0xffffb
    80005db4:	c32080e7          	jalr	-974(ra) # 800009e2 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005db8:	04a1                	addi	s1,s1,8
    80005dba:	ff3499e3          	bne	s1,s3,80005dac <sys_exec+0xe6>
    80005dbe:	a011                	j	80005dc2 <sys_exec+0xfc>
  return -1;
    80005dc0:	597d                	li	s2,-1
}
    80005dc2:	854a                	mv	a0,s2
    80005dc4:	60be                	ld	ra,456(sp)
    80005dc6:	641e                	ld	s0,448(sp)
    80005dc8:	74fa                	ld	s1,440(sp)
    80005dca:	795a                	ld	s2,432(sp)
    80005dcc:	79ba                	ld	s3,424(sp)
    80005dce:	7a1a                	ld	s4,416(sp)
    80005dd0:	6afa                	ld	s5,408(sp)
    80005dd2:	6179                	addi	sp,sp,464
    80005dd4:	8082                	ret

0000000080005dd6 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005dd6:	7139                	addi	sp,sp,-64
    80005dd8:	fc06                	sd	ra,56(sp)
    80005dda:	f822                	sd	s0,48(sp)
    80005ddc:	f426                	sd	s1,40(sp)
    80005dde:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005de0:	ffffc097          	auipc	ra,0xffffc
    80005de4:	be6080e7          	jalr	-1050(ra) # 800019c6 <myproc>
    80005de8:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005dea:	fd840593          	addi	a1,s0,-40
    80005dee:	4501                	li	a0,0
    80005df0:	ffffd097          	auipc	ra,0xffffd
    80005df4:	fd2080e7          	jalr	-46(ra) # 80002dc2 <argaddr>
    return -1;
    80005df8:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005dfa:	0e054063          	bltz	a0,80005eda <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005dfe:	fc840593          	addi	a1,s0,-56
    80005e02:	fd040513          	addi	a0,s0,-48
    80005e06:	fffff097          	auipc	ra,0xfffff
    80005e0a:	de6080e7          	jalr	-538(ra) # 80004bec <pipealloc>
    return -1;
    80005e0e:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005e10:	0c054563          	bltz	a0,80005eda <sys_pipe+0x104>
  fd0 = -1;
    80005e14:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005e18:	fd043503          	ld	a0,-48(s0)
    80005e1c:	fffff097          	auipc	ra,0xfffff
    80005e20:	504080e7          	jalr	1284(ra) # 80005320 <fdalloc>
    80005e24:	fca42223          	sw	a0,-60(s0)
    80005e28:	08054c63          	bltz	a0,80005ec0 <sys_pipe+0xea>
    80005e2c:	fc843503          	ld	a0,-56(s0)
    80005e30:	fffff097          	auipc	ra,0xfffff
    80005e34:	4f0080e7          	jalr	1264(ra) # 80005320 <fdalloc>
    80005e38:	fca42023          	sw	a0,-64(s0)
    80005e3c:	06054963          	bltz	a0,80005eae <sys_pipe+0xd8>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e40:	4691                	li	a3,4
    80005e42:	fc440613          	addi	a2,s0,-60
    80005e46:	fd843583          	ld	a1,-40(s0)
    80005e4a:	70a8                	ld	a0,96(s1)
    80005e4c:	ffffc097          	auipc	ra,0xffffc
    80005e50:	83e080e7          	jalr	-1986(ra) # 8000168a <copyout>
    80005e54:	02054063          	bltz	a0,80005e74 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005e58:	4691                	li	a3,4
    80005e5a:	fc040613          	addi	a2,s0,-64
    80005e5e:	fd843583          	ld	a1,-40(s0)
    80005e62:	0591                	addi	a1,a1,4
    80005e64:	70a8                	ld	a0,96(s1)
    80005e66:	ffffc097          	auipc	ra,0xffffc
    80005e6a:	824080e7          	jalr	-2012(ra) # 8000168a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005e6e:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e70:	06055563          	bgez	a0,80005eda <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005e74:	fc442783          	lw	a5,-60(s0)
    80005e78:	07f1                	addi	a5,a5,28
    80005e7a:	078e                	slli	a5,a5,0x3
    80005e7c:	97a6                	add	a5,a5,s1
    80005e7e:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005e82:	fc042783          	lw	a5,-64(s0)
    80005e86:	07f1                	addi	a5,a5,28
    80005e88:	078e                	slli	a5,a5,0x3
    80005e8a:	00f48533          	add	a0,s1,a5
    80005e8e:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005e92:	fd043503          	ld	a0,-48(s0)
    80005e96:	fffff097          	auipc	ra,0xfffff
    80005e9a:	a26080e7          	jalr	-1498(ra) # 800048bc <fileclose>
    fileclose(wf);
    80005e9e:	fc843503          	ld	a0,-56(s0)
    80005ea2:	fffff097          	auipc	ra,0xfffff
    80005ea6:	a1a080e7          	jalr	-1510(ra) # 800048bc <fileclose>
    return -1;
    80005eaa:	57fd                	li	a5,-1
    80005eac:	a03d                	j	80005eda <sys_pipe+0x104>
    if(fd0 >= 0)
    80005eae:	fc442783          	lw	a5,-60(s0)
    80005eb2:	0007c763          	bltz	a5,80005ec0 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005eb6:	07f1                	addi	a5,a5,28
    80005eb8:	078e                	slli	a5,a5,0x3
    80005eba:	97a6                	add	a5,a5,s1
    80005ebc:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005ec0:	fd043503          	ld	a0,-48(s0)
    80005ec4:	fffff097          	auipc	ra,0xfffff
    80005ec8:	9f8080e7          	jalr	-1544(ra) # 800048bc <fileclose>
    fileclose(wf);
    80005ecc:	fc843503          	ld	a0,-56(s0)
    80005ed0:	fffff097          	auipc	ra,0xfffff
    80005ed4:	9ec080e7          	jalr	-1556(ra) # 800048bc <fileclose>
    return -1;
    80005ed8:	57fd                	li	a5,-1
}
    80005eda:	853e                	mv	a0,a5
    80005edc:	70e2                	ld	ra,56(sp)
    80005ede:	7442                	ld	s0,48(sp)
    80005ee0:	74a2                	ld	s1,40(sp)
    80005ee2:	6121                	addi	sp,sp,64
    80005ee4:	8082                	ret
	...

0000000080005ef0 <kernelvec>:
    80005ef0:	7111                	addi	sp,sp,-256
    80005ef2:	e006                	sd	ra,0(sp)
    80005ef4:	e40a                	sd	sp,8(sp)
    80005ef6:	e80e                	sd	gp,16(sp)
    80005ef8:	ec12                	sd	tp,24(sp)
    80005efa:	f016                	sd	t0,32(sp)
    80005efc:	f41a                	sd	t1,40(sp)
    80005efe:	f81e                	sd	t2,48(sp)
    80005f00:	fc22                	sd	s0,56(sp)
    80005f02:	e0a6                	sd	s1,64(sp)
    80005f04:	e4aa                	sd	a0,72(sp)
    80005f06:	e8ae                	sd	a1,80(sp)
    80005f08:	ecb2                	sd	a2,88(sp)
    80005f0a:	f0b6                	sd	a3,96(sp)
    80005f0c:	f4ba                	sd	a4,104(sp)
    80005f0e:	f8be                	sd	a5,112(sp)
    80005f10:	fcc2                	sd	a6,120(sp)
    80005f12:	e146                	sd	a7,128(sp)
    80005f14:	e54a                	sd	s2,136(sp)
    80005f16:	e94e                	sd	s3,144(sp)
    80005f18:	ed52                	sd	s4,152(sp)
    80005f1a:	f156                	sd	s5,160(sp)
    80005f1c:	f55a                	sd	s6,168(sp)
    80005f1e:	f95e                	sd	s7,176(sp)
    80005f20:	fd62                	sd	s8,184(sp)
    80005f22:	e1e6                	sd	s9,192(sp)
    80005f24:	e5ea                	sd	s10,200(sp)
    80005f26:	e9ee                	sd	s11,208(sp)
    80005f28:	edf2                	sd	t3,216(sp)
    80005f2a:	f1f6                	sd	t4,224(sp)
    80005f2c:	f5fa                	sd	t5,232(sp)
    80005f2e:	f9fe                	sd	t6,240(sp)
    80005f30:	c95fc0ef          	jal	ra,80002bc4 <kerneltrap>
    80005f34:	6082                	ld	ra,0(sp)
    80005f36:	6122                	ld	sp,8(sp)
    80005f38:	61c2                	ld	gp,16(sp)
    80005f3a:	7282                	ld	t0,32(sp)
    80005f3c:	7322                	ld	t1,40(sp)
    80005f3e:	73c2                	ld	t2,48(sp)
    80005f40:	7462                	ld	s0,56(sp)
    80005f42:	6486                	ld	s1,64(sp)
    80005f44:	6526                	ld	a0,72(sp)
    80005f46:	65c6                	ld	a1,80(sp)
    80005f48:	6666                	ld	a2,88(sp)
    80005f4a:	7686                	ld	a3,96(sp)
    80005f4c:	7726                	ld	a4,104(sp)
    80005f4e:	77c6                	ld	a5,112(sp)
    80005f50:	7866                	ld	a6,120(sp)
    80005f52:	688a                	ld	a7,128(sp)
    80005f54:	692a                	ld	s2,136(sp)
    80005f56:	69ca                	ld	s3,144(sp)
    80005f58:	6a6a                	ld	s4,152(sp)
    80005f5a:	7a8a                	ld	s5,160(sp)
    80005f5c:	7b2a                	ld	s6,168(sp)
    80005f5e:	7bca                	ld	s7,176(sp)
    80005f60:	7c6a                	ld	s8,184(sp)
    80005f62:	6c8e                	ld	s9,192(sp)
    80005f64:	6d2e                	ld	s10,200(sp)
    80005f66:	6dce                	ld	s11,208(sp)
    80005f68:	6e6e                	ld	t3,216(sp)
    80005f6a:	7e8e                	ld	t4,224(sp)
    80005f6c:	7f2e                	ld	t5,232(sp)
    80005f6e:	7fce                	ld	t6,240(sp)
    80005f70:	6111                	addi	sp,sp,256
    80005f72:	10200073          	sret
    80005f76:	00000013          	nop
    80005f7a:	00000013          	nop
    80005f7e:	0001                	nop

0000000080005f80 <timervec>:
    80005f80:	34051573          	csrrw	a0,mscratch,a0
    80005f84:	e10c                	sd	a1,0(a0)
    80005f86:	e510                	sd	a2,8(a0)
    80005f88:	e914                	sd	a3,16(a0)
    80005f8a:	6d0c                	ld	a1,24(a0)
    80005f8c:	7110                	ld	a2,32(a0)
    80005f8e:	6194                	ld	a3,0(a1)
    80005f90:	96b2                	add	a3,a3,a2
    80005f92:	e194                	sd	a3,0(a1)
    80005f94:	4589                	li	a1,2
    80005f96:	14459073          	csrw	sip,a1
    80005f9a:	6914                	ld	a3,16(a0)
    80005f9c:	6510                	ld	a2,8(a0)
    80005f9e:	610c                	ld	a1,0(a0)
    80005fa0:	34051573          	csrrw	a0,mscratch,a0
    80005fa4:	30200073          	mret
	...

0000000080005faa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005faa:	1141                	addi	sp,sp,-16
    80005fac:	e422                	sd	s0,8(sp)
    80005fae:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005fb0:	0c0007b7          	lui	a5,0xc000
    80005fb4:	4705                	li	a4,1
    80005fb6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005fb8:	c3d8                	sw	a4,4(a5)
}
    80005fba:	6422                	ld	s0,8(sp)
    80005fbc:	0141                	addi	sp,sp,16
    80005fbe:	8082                	ret

0000000080005fc0 <plicinithart>:

void
plicinithart(void)
{
    80005fc0:	1141                	addi	sp,sp,-16
    80005fc2:	e406                	sd	ra,8(sp)
    80005fc4:	e022                	sd	s0,0(sp)
    80005fc6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005fc8:	ffffc097          	auipc	ra,0xffffc
    80005fcc:	9d2080e7          	jalr	-1582(ra) # 8000199a <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005fd0:	0085171b          	slliw	a4,a0,0x8
    80005fd4:	0c0027b7          	lui	a5,0xc002
    80005fd8:	97ba                	add	a5,a5,a4
    80005fda:	40200713          	li	a4,1026
    80005fde:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005fe2:	00d5151b          	slliw	a0,a0,0xd
    80005fe6:	0c2017b7          	lui	a5,0xc201
    80005fea:	97aa                	add	a5,a5,a0
    80005fec:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005ff0:	60a2                	ld	ra,8(sp)
    80005ff2:	6402                	ld	s0,0(sp)
    80005ff4:	0141                	addi	sp,sp,16
    80005ff6:	8082                	ret

0000000080005ff8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005ff8:	1141                	addi	sp,sp,-16
    80005ffa:	e406                	sd	ra,8(sp)
    80005ffc:	e022                	sd	s0,0(sp)
    80005ffe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006000:	ffffc097          	auipc	ra,0xffffc
    80006004:	99a080e7          	jalr	-1638(ra) # 8000199a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006008:	00d5151b          	slliw	a0,a0,0xd
    8000600c:	0c2017b7          	lui	a5,0xc201
    80006010:	97aa                	add	a5,a5,a0
  return irq;
}
    80006012:	43c8                	lw	a0,4(a5)
    80006014:	60a2                	ld	ra,8(sp)
    80006016:	6402                	ld	s0,0(sp)
    80006018:	0141                	addi	sp,sp,16
    8000601a:	8082                	ret

000000008000601c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000601c:	1101                	addi	sp,sp,-32
    8000601e:	ec06                	sd	ra,24(sp)
    80006020:	e822                	sd	s0,16(sp)
    80006022:	e426                	sd	s1,8(sp)
    80006024:	1000                	addi	s0,sp,32
    80006026:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006028:	ffffc097          	auipc	ra,0xffffc
    8000602c:	972080e7          	jalr	-1678(ra) # 8000199a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006030:	00d5151b          	slliw	a0,a0,0xd
    80006034:	0c2017b7          	lui	a5,0xc201
    80006038:	97aa                	add	a5,a5,a0
    8000603a:	c3c4                	sw	s1,4(a5)
}
    8000603c:	60e2                	ld	ra,24(sp)
    8000603e:	6442                	ld	s0,16(sp)
    80006040:	64a2                	ld	s1,8(sp)
    80006042:	6105                	addi	sp,sp,32
    80006044:	8082                	ret

0000000080006046 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006046:	1141                	addi	sp,sp,-16
    80006048:	e406                	sd	ra,8(sp)
    8000604a:	e022                	sd	s0,0(sp)
    8000604c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000604e:	479d                	li	a5,7
    80006050:	06a7c863          	blt	a5,a0,800060c0 <free_desc+0x7a>
    panic("free_desc 1");
  if(disk.free[i])
    80006054:	0001d717          	auipc	a4,0x1d
    80006058:	fac70713          	addi	a4,a4,-84 # 80023000 <disk>
    8000605c:	972a                	add	a4,a4,a0
    8000605e:	6789                	lui	a5,0x2
    80006060:	97ba                	add	a5,a5,a4
    80006062:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006066:	e7ad                	bnez	a5,800060d0 <free_desc+0x8a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006068:	00451793          	slli	a5,a0,0x4
    8000606c:	0001f717          	auipc	a4,0x1f
    80006070:	f9470713          	addi	a4,a4,-108 # 80025000 <disk+0x2000>
    80006074:	6314                	ld	a3,0(a4)
    80006076:	96be                	add	a3,a3,a5
    80006078:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    8000607c:	6314                	ld	a3,0(a4)
    8000607e:	96be                	add	a3,a3,a5
    80006080:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006084:	6314                	ld	a3,0(a4)
    80006086:	96be                	add	a3,a3,a5
    80006088:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    8000608c:	6318                	ld	a4,0(a4)
    8000608e:	97ba                	add	a5,a5,a4
    80006090:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006094:	0001d717          	auipc	a4,0x1d
    80006098:	f6c70713          	addi	a4,a4,-148 # 80023000 <disk>
    8000609c:	972a                	add	a4,a4,a0
    8000609e:	6789                	lui	a5,0x2
    800060a0:	97ba                	add	a5,a5,a4
    800060a2:	4705                	li	a4,1
    800060a4:	00e78c23          	sb	a4,24(a5) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    800060a8:	0001f517          	auipc	a0,0x1f
    800060ac:	f7050513          	addi	a0,a0,-144 # 80025018 <disk+0x2018>
    800060b0:	ffffc097          	auipc	ra,0xffffc
    800060b4:	1ae080e7          	jalr	430(ra) # 8000225e <wakeup>
}
    800060b8:	60a2                	ld	ra,8(sp)
    800060ba:	6402                	ld	s0,0(sp)
    800060bc:	0141                	addi	sp,sp,16
    800060be:	8082                	ret
    panic("free_desc 1");
    800060c0:	00002517          	auipc	a0,0x2
    800060c4:	70850513          	addi	a0,a0,1800 # 800087c8 <syscalls+0x350>
    800060c8:	ffffa097          	auipc	ra,0xffffa
    800060cc:	472080e7          	jalr	1138(ra) # 8000053a <panic>
    panic("free_desc 2");
    800060d0:	00002517          	auipc	a0,0x2
    800060d4:	70850513          	addi	a0,a0,1800 # 800087d8 <syscalls+0x360>
    800060d8:	ffffa097          	auipc	ra,0xffffa
    800060dc:	462080e7          	jalr	1122(ra) # 8000053a <panic>

00000000800060e0 <virtio_disk_init>:
{
    800060e0:	1101                	addi	sp,sp,-32
    800060e2:	ec06                	sd	ra,24(sp)
    800060e4:	e822                	sd	s0,16(sp)
    800060e6:	e426                	sd	s1,8(sp)
    800060e8:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800060ea:	00002597          	auipc	a1,0x2
    800060ee:	6fe58593          	addi	a1,a1,1790 # 800087e8 <syscalls+0x370>
    800060f2:	0001f517          	auipc	a0,0x1f
    800060f6:	03650513          	addi	a0,a0,54 # 80025128 <disk+0x2128>
    800060fa:	ffffb097          	auipc	ra,0xffffb
    800060fe:	a90080e7          	jalr	-1392(ra) # 80000b8a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006102:	100017b7          	lui	a5,0x10001
    80006106:	4398                	lw	a4,0(a5)
    80006108:	2701                	sext.w	a4,a4
    8000610a:	747277b7          	lui	a5,0x74727
    8000610e:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006112:	0ef71063          	bne	a4,a5,800061f2 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006116:	100017b7          	lui	a5,0x10001
    8000611a:	43dc                	lw	a5,4(a5)
    8000611c:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000611e:	4705                	li	a4,1
    80006120:	0ce79963          	bne	a5,a4,800061f2 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006124:	100017b7          	lui	a5,0x10001
    80006128:	479c                	lw	a5,8(a5)
    8000612a:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    8000612c:	4709                	li	a4,2
    8000612e:	0ce79263          	bne	a5,a4,800061f2 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006132:	100017b7          	lui	a5,0x10001
    80006136:	47d8                	lw	a4,12(a5)
    80006138:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000613a:	554d47b7          	lui	a5,0x554d4
    8000613e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006142:	0af71863          	bne	a4,a5,800061f2 <virtio_disk_init+0x112>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006146:	100017b7          	lui	a5,0x10001
    8000614a:	4705                	li	a4,1
    8000614c:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000614e:	470d                	li	a4,3
    80006150:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006152:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006154:	c7ffe6b7          	lui	a3,0xc7ffe
    80006158:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    8000615c:	8f75                	and	a4,a4,a3
    8000615e:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006160:	472d                	li	a4,11
    80006162:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006164:	473d                	li	a4,15
    80006166:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006168:	6705                	lui	a4,0x1
    8000616a:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000616c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006170:	5bdc                	lw	a5,52(a5)
    80006172:	2781                	sext.w	a5,a5
  if(max == 0)
    80006174:	c7d9                	beqz	a5,80006202 <virtio_disk_init+0x122>
  if(max < NUM)
    80006176:	471d                	li	a4,7
    80006178:	08f77d63          	bgeu	a4,a5,80006212 <virtio_disk_init+0x132>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000617c:	100014b7          	lui	s1,0x10001
    80006180:	47a1                	li	a5,8
    80006182:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006184:	6609                	lui	a2,0x2
    80006186:	4581                	li	a1,0
    80006188:	0001d517          	auipc	a0,0x1d
    8000618c:	e7850513          	addi	a0,a0,-392 # 80023000 <disk>
    80006190:	ffffb097          	auipc	ra,0xffffb
    80006194:	b86080e7          	jalr	-1146(ra) # 80000d16 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006198:	0001d717          	auipc	a4,0x1d
    8000619c:	e6870713          	addi	a4,a4,-408 # 80023000 <disk>
    800061a0:	00c75793          	srli	a5,a4,0xc
    800061a4:	2781                	sext.w	a5,a5
    800061a6:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    800061a8:	0001f797          	auipc	a5,0x1f
    800061ac:	e5878793          	addi	a5,a5,-424 # 80025000 <disk+0x2000>
    800061b0:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    800061b2:	0001d717          	auipc	a4,0x1d
    800061b6:	ece70713          	addi	a4,a4,-306 # 80023080 <disk+0x80>
    800061ba:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    800061bc:	0001e717          	auipc	a4,0x1e
    800061c0:	e4470713          	addi	a4,a4,-444 # 80024000 <disk+0x1000>
    800061c4:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    800061c6:	4705                	li	a4,1
    800061c8:	00e78c23          	sb	a4,24(a5)
    800061cc:	00e78ca3          	sb	a4,25(a5)
    800061d0:	00e78d23          	sb	a4,26(a5)
    800061d4:	00e78da3          	sb	a4,27(a5)
    800061d8:	00e78e23          	sb	a4,28(a5)
    800061dc:	00e78ea3          	sb	a4,29(a5)
    800061e0:	00e78f23          	sb	a4,30(a5)
    800061e4:	00e78fa3          	sb	a4,31(a5)
}
    800061e8:	60e2                	ld	ra,24(sp)
    800061ea:	6442                	ld	s0,16(sp)
    800061ec:	64a2                	ld	s1,8(sp)
    800061ee:	6105                	addi	sp,sp,32
    800061f0:	8082                	ret
    panic("could not find virtio disk");
    800061f2:	00002517          	auipc	a0,0x2
    800061f6:	60650513          	addi	a0,a0,1542 # 800087f8 <syscalls+0x380>
    800061fa:	ffffa097          	auipc	ra,0xffffa
    800061fe:	340080e7          	jalr	832(ra) # 8000053a <panic>
    panic("virtio disk has no queue 0");
    80006202:	00002517          	auipc	a0,0x2
    80006206:	61650513          	addi	a0,a0,1558 # 80008818 <syscalls+0x3a0>
    8000620a:	ffffa097          	auipc	ra,0xffffa
    8000620e:	330080e7          	jalr	816(ra) # 8000053a <panic>
    panic("virtio disk max queue too short");
    80006212:	00002517          	auipc	a0,0x2
    80006216:	62650513          	addi	a0,a0,1574 # 80008838 <syscalls+0x3c0>
    8000621a:	ffffa097          	auipc	ra,0xffffa
    8000621e:	320080e7          	jalr	800(ra) # 8000053a <panic>

0000000080006222 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006222:	7119                	addi	sp,sp,-128
    80006224:	fc86                	sd	ra,120(sp)
    80006226:	f8a2                	sd	s0,112(sp)
    80006228:	f4a6                	sd	s1,104(sp)
    8000622a:	f0ca                	sd	s2,96(sp)
    8000622c:	ecce                	sd	s3,88(sp)
    8000622e:	e8d2                	sd	s4,80(sp)
    80006230:	e4d6                	sd	s5,72(sp)
    80006232:	e0da                	sd	s6,64(sp)
    80006234:	fc5e                	sd	s7,56(sp)
    80006236:	f862                	sd	s8,48(sp)
    80006238:	f466                	sd	s9,40(sp)
    8000623a:	f06a                	sd	s10,32(sp)
    8000623c:	ec6e                	sd	s11,24(sp)
    8000623e:	0100                	addi	s0,sp,128
    80006240:	8aaa                	mv	s5,a0
    80006242:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006244:	00c52c83          	lw	s9,12(a0)
    80006248:	001c9c9b          	slliw	s9,s9,0x1
    8000624c:	1c82                	slli	s9,s9,0x20
    8000624e:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006252:	0001f517          	auipc	a0,0x1f
    80006256:	ed650513          	addi	a0,a0,-298 # 80025128 <disk+0x2128>
    8000625a:	ffffb097          	auipc	ra,0xffffb
    8000625e:	9c0080e7          	jalr	-1600(ra) # 80000c1a <acquire>
  for(int i = 0; i < 3; i++){
    80006262:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006264:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006266:	0001dc17          	auipc	s8,0x1d
    8000626a:	d9ac0c13          	addi	s8,s8,-614 # 80023000 <disk>
    8000626e:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80006270:	4b0d                	li	s6,3
    80006272:	a0ad                	j	800062dc <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80006274:	00fc0733          	add	a4,s8,a5
    80006278:	975e                	add	a4,a4,s7
    8000627a:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    8000627e:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006280:	0207c563          	bltz	a5,800062aa <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006284:	2905                	addiw	s2,s2,1
    80006286:	0611                	addi	a2,a2,4 # 2004 <_entry-0x7fffdffc>
    80006288:	19690c63          	beq	s2,s6,80006420 <virtio_disk_rw+0x1fe>
    idx[i] = alloc_desc();
    8000628c:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    8000628e:	0001f717          	auipc	a4,0x1f
    80006292:	d8a70713          	addi	a4,a4,-630 # 80025018 <disk+0x2018>
    80006296:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006298:	00074683          	lbu	a3,0(a4)
    8000629c:	fee1                	bnez	a3,80006274 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    8000629e:	2785                	addiw	a5,a5,1
    800062a0:	0705                	addi	a4,a4,1
    800062a2:	fe979be3          	bne	a5,s1,80006298 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    800062a6:	57fd                	li	a5,-1
    800062a8:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800062aa:	01205d63          	blez	s2,800062c4 <virtio_disk_rw+0xa2>
    800062ae:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800062b0:	000a2503          	lw	a0,0(s4)
    800062b4:	00000097          	auipc	ra,0x0
    800062b8:	d92080e7          	jalr	-622(ra) # 80006046 <free_desc>
      for(int j = 0; j < i; j++)
    800062bc:	2d85                	addiw	s11,s11,1
    800062be:	0a11                	addi	s4,s4,4
    800062c0:	ff2d98e3          	bne	s11,s2,800062b0 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800062c4:	0001f597          	auipc	a1,0x1f
    800062c8:	e6458593          	addi	a1,a1,-412 # 80025128 <disk+0x2128>
    800062cc:	0001f517          	auipc	a0,0x1f
    800062d0:	d4c50513          	addi	a0,a0,-692 # 80025018 <disk+0x2018>
    800062d4:	ffffc097          	auipc	ra,0xffffc
    800062d8:	dfe080e7          	jalr	-514(ra) # 800020d2 <sleep>
  for(int i = 0; i < 3; i++){
    800062dc:	f8040a13          	addi	s4,s0,-128
{
    800062e0:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800062e2:	894e                	mv	s2,s3
    800062e4:	b765                	j	8000628c <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800062e6:	0001f697          	auipc	a3,0x1f
    800062ea:	d1a6b683          	ld	a3,-742(a3) # 80025000 <disk+0x2000>
    800062ee:	96ba                	add	a3,a3,a4
    800062f0:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800062f4:	0001d817          	auipc	a6,0x1d
    800062f8:	d0c80813          	addi	a6,a6,-756 # 80023000 <disk>
    800062fc:	0001f697          	auipc	a3,0x1f
    80006300:	d0468693          	addi	a3,a3,-764 # 80025000 <disk+0x2000>
    80006304:	6290                	ld	a2,0(a3)
    80006306:	963a                	add	a2,a2,a4
    80006308:	00c65583          	lhu	a1,12(a2)
    8000630c:	0015e593          	ori	a1,a1,1
    80006310:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80006314:	f8842603          	lw	a2,-120(s0)
    80006318:	628c                	ld	a1,0(a3)
    8000631a:	972e                	add	a4,a4,a1
    8000631c:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006320:	20050593          	addi	a1,a0,512
    80006324:	0592                	slli	a1,a1,0x4
    80006326:	95c2                	add	a1,a1,a6
    80006328:	577d                	li	a4,-1
    8000632a:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000632e:	00461713          	slli	a4,a2,0x4
    80006332:	6290                	ld	a2,0(a3)
    80006334:	963a                	add	a2,a2,a4
    80006336:	03078793          	addi	a5,a5,48
    8000633a:	97c2                	add	a5,a5,a6
    8000633c:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    8000633e:	629c                	ld	a5,0(a3)
    80006340:	97ba                	add	a5,a5,a4
    80006342:	4605                	li	a2,1
    80006344:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006346:	629c                	ld	a5,0(a3)
    80006348:	97ba                	add	a5,a5,a4
    8000634a:	4809                	li	a6,2
    8000634c:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006350:	629c                	ld	a5,0(a3)
    80006352:	97ba                	add	a5,a5,a4
    80006354:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006358:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    8000635c:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006360:	6698                	ld	a4,8(a3)
    80006362:	00275783          	lhu	a5,2(a4)
    80006366:	8b9d                	andi	a5,a5,7
    80006368:	0786                	slli	a5,a5,0x1
    8000636a:	973e                	add	a4,a4,a5
    8000636c:	00a71223          	sh	a0,4(a4)

  __sync_synchronize();
    80006370:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006374:	6698                	ld	a4,8(a3)
    80006376:	00275783          	lhu	a5,2(a4)
    8000637a:	2785                	addiw	a5,a5,1
    8000637c:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006380:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006384:	100017b7          	lui	a5,0x10001
    80006388:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000638c:	004aa783          	lw	a5,4(s5)
    80006390:	02c79163          	bne	a5,a2,800063b2 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80006394:	0001f917          	auipc	s2,0x1f
    80006398:	d9490913          	addi	s2,s2,-620 # 80025128 <disk+0x2128>
  while(b->disk == 1) {
    8000639c:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    8000639e:	85ca                	mv	a1,s2
    800063a0:	8556                	mv	a0,s5
    800063a2:	ffffc097          	auipc	ra,0xffffc
    800063a6:	d30080e7          	jalr	-720(ra) # 800020d2 <sleep>
  while(b->disk == 1) {
    800063aa:	004aa783          	lw	a5,4(s5)
    800063ae:	fe9788e3          	beq	a5,s1,8000639e <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    800063b2:	f8042903          	lw	s2,-128(s0)
    800063b6:	20090713          	addi	a4,s2,512
    800063ba:	0712                	slli	a4,a4,0x4
    800063bc:	0001d797          	auipc	a5,0x1d
    800063c0:	c4478793          	addi	a5,a5,-956 # 80023000 <disk>
    800063c4:	97ba                	add	a5,a5,a4
    800063c6:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    800063ca:	0001f997          	auipc	s3,0x1f
    800063ce:	c3698993          	addi	s3,s3,-970 # 80025000 <disk+0x2000>
    800063d2:	00491713          	slli	a4,s2,0x4
    800063d6:	0009b783          	ld	a5,0(s3)
    800063da:	97ba                	add	a5,a5,a4
    800063dc:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800063e0:	854a                	mv	a0,s2
    800063e2:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800063e6:	00000097          	auipc	ra,0x0
    800063ea:	c60080e7          	jalr	-928(ra) # 80006046 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800063ee:	8885                	andi	s1,s1,1
    800063f0:	f0ed                	bnez	s1,800063d2 <virtio_disk_rw+0x1b0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800063f2:	0001f517          	auipc	a0,0x1f
    800063f6:	d3650513          	addi	a0,a0,-714 # 80025128 <disk+0x2128>
    800063fa:	ffffb097          	auipc	ra,0xffffb
    800063fe:	8d4080e7          	jalr	-1836(ra) # 80000cce <release>
}
    80006402:	70e6                	ld	ra,120(sp)
    80006404:	7446                	ld	s0,112(sp)
    80006406:	74a6                	ld	s1,104(sp)
    80006408:	7906                	ld	s2,96(sp)
    8000640a:	69e6                	ld	s3,88(sp)
    8000640c:	6a46                	ld	s4,80(sp)
    8000640e:	6aa6                	ld	s5,72(sp)
    80006410:	6b06                	ld	s6,64(sp)
    80006412:	7be2                	ld	s7,56(sp)
    80006414:	7c42                	ld	s8,48(sp)
    80006416:	7ca2                	ld	s9,40(sp)
    80006418:	7d02                	ld	s10,32(sp)
    8000641a:	6de2                	ld	s11,24(sp)
    8000641c:	6109                	addi	sp,sp,128
    8000641e:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006420:	f8042503          	lw	a0,-128(s0)
    80006424:	20050793          	addi	a5,a0,512
    80006428:	0792                	slli	a5,a5,0x4
  if(write)
    8000642a:	0001d817          	auipc	a6,0x1d
    8000642e:	bd680813          	addi	a6,a6,-1066 # 80023000 <disk>
    80006432:	00f80733          	add	a4,a6,a5
    80006436:	01a036b3          	snez	a3,s10
    8000643a:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    8000643e:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80006442:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006446:	7679                	lui	a2,0xffffe
    80006448:	963e                	add	a2,a2,a5
    8000644a:	0001f697          	auipc	a3,0x1f
    8000644e:	bb668693          	addi	a3,a3,-1098 # 80025000 <disk+0x2000>
    80006452:	6298                	ld	a4,0(a3)
    80006454:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006456:	0a878593          	addi	a1,a5,168
    8000645a:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000645c:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000645e:	6298                	ld	a4,0(a3)
    80006460:	9732                	add	a4,a4,a2
    80006462:	45c1                	li	a1,16
    80006464:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006466:	6298                	ld	a4,0(a3)
    80006468:	9732                	add	a4,a4,a2
    8000646a:	4585                	li	a1,1
    8000646c:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80006470:	f8442703          	lw	a4,-124(s0)
    80006474:	628c                	ld	a1,0(a3)
    80006476:	962e                	add	a2,a2,a1
    80006478:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd800e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    8000647c:	0712                	slli	a4,a4,0x4
    8000647e:	6290                	ld	a2,0(a3)
    80006480:	963a                	add	a2,a2,a4
    80006482:	058a8593          	addi	a1,s5,88
    80006486:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006488:	6294                	ld	a3,0(a3)
    8000648a:	96ba                	add	a3,a3,a4
    8000648c:	40000613          	li	a2,1024
    80006490:	c690                	sw	a2,8(a3)
  if(write)
    80006492:	e40d1ae3          	bnez	s10,800062e6 <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006496:	0001f697          	auipc	a3,0x1f
    8000649a:	b6a6b683          	ld	a3,-1174(a3) # 80025000 <disk+0x2000>
    8000649e:	96ba                	add	a3,a3,a4
    800064a0:	4609                	li	a2,2
    800064a2:	00c69623          	sh	a2,12(a3)
    800064a6:	b5b9                	j	800062f4 <virtio_disk_rw+0xd2>

00000000800064a8 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800064a8:	1101                	addi	sp,sp,-32
    800064aa:	ec06                	sd	ra,24(sp)
    800064ac:	e822                	sd	s0,16(sp)
    800064ae:	e426                	sd	s1,8(sp)
    800064b0:	e04a                	sd	s2,0(sp)
    800064b2:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800064b4:	0001f517          	auipc	a0,0x1f
    800064b8:	c7450513          	addi	a0,a0,-908 # 80025128 <disk+0x2128>
    800064bc:	ffffa097          	auipc	ra,0xffffa
    800064c0:	75e080e7          	jalr	1886(ra) # 80000c1a <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800064c4:	10001737          	lui	a4,0x10001
    800064c8:	533c                	lw	a5,96(a4)
    800064ca:	8b8d                	andi	a5,a5,3
    800064cc:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800064ce:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800064d2:	0001f797          	auipc	a5,0x1f
    800064d6:	b2e78793          	addi	a5,a5,-1234 # 80025000 <disk+0x2000>
    800064da:	6b94                	ld	a3,16(a5)
    800064dc:	0207d703          	lhu	a4,32(a5)
    800064e0:	0026d783          	lhu	a5,2(a3)
    800064e4:	06f70163          	beq	a4,a5,80006546 <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800064e8:	0001d917          	auipc	s2,0x1d
    800064ec:	b1890913          	addi	s2,s2,-1256 # 80023000 <disk>
    800064f0:	0001f497          	auipc	s1,0x1f
    800064f4:	b1048493          	addi	s1,s1,-1264 # 80025000 <disk+0x2000>
    __sync_synchronize();
    800064f8:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800064fc:	6898                	ld	a4,16(s1)
    800064fe:	0204d783          	lhu	a5,32(s1)
    80006502:	8b9d                	andi	a5,a5,7
    80006504:	078e                	slli	a5,a5,0x3
    80006506:	97ba                	add	a5,a5,a4
    80006508:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    8000650a:	20078713          	addi	a4,a5,512
    8000650e:	0712                	slli	a4,a4,0x4
    80006510:	974a                	add	a4,a4,s2
    80006512:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    80006516:	e731                	bnez	a4,80006562 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006518:	20078793          	addi	a5,a5,512
    8000651c:	0792                	slli	a5,a5,0x4
    8000651e:	97ca                	add	a5,a5,s2
    80006520:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80006522:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006526:	ffffc097          	auipc	ra,0xffffc
    8000652a:	d38080e7          	jalr	-712(ra) # 8000225e <wakeup>

    disk.used_idx += 1;
    8000652e:	0204d783          	lhu	a5,32(s1)
    80006532:	2785                	addiw	a5,a5,1
    80006534:	17c2                	slli	a5,a5,0x30
    80006536:	93c1                	srli	a5,a5,0x30
    80006538:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000653c:	6898                	ld	a4,16(s1)
    8000653e:	00275703          	lhu	a4,2(a4)
    80006542:	faf71be3          	bne	a4,a5,800064f8 <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    80006546:	0001f517          	auipc	a0,0x1f
    8000654a:	be250513          	addi	a0,a0,-1054 # 80025128 <disk+0x2128>
    8000654e:	ffffa097          	auipc	ra,0xffffa
    80006552:	780080e7          	jalr	1920(ra) # 80000cce <release>
}
    80006556:	60e2                	ld	ra,24(sp)
    80006558:	6442                	ld	s0,16(sp)
    8000655a:	64a2                	ld	s1,8(sp)
    8000655c:	6902                	ld	s2,0(sp)
    8000655e:	6105                	addi	sp,sp,32
    80006560:	8082                	ret
      panic("virtio_disk_intr status");
    80006562:	00002517          	auipc	a0,0x2
    80006566:	2f650513          	addi	a0,a0,758 # 80008858 <syscalls+0x3e0>
    8000656a:	ffffa097          	auipc	ra,0xffffa
    8000656e:	fd0080e7          	jalr	-48(ra) # 8000053a <panic>
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
