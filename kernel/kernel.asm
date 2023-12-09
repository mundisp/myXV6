
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	93013103          	ld	sp,-1744(sp) # 80009930 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
    80000022:	f14027f3          	csrr	a5,mhartid
    80000026:	0007859b          	sext.w	a1,a5
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	0000a717          	auipc	a4,0xa
    80000054:	ff070713          	addi	a4,a4,-16 # 8000a040 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
    8000005a:	ef1c                	sd	a5,24(a4)
    8000005c:	f310                	sd	a2,32(a4)
    8000005e:	34071073          	csrw	mscratch,a4
    80000062:	00007797          	auipc	a5,0x7
    80000066:	8ae78793          	addi	a5,a5,-1874 # 80006910 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
    8000006e:	300027f3          	csrr	a5,mstatus
    80000072:	0087e793          	ori	a5,a5,8
    80000076:	30079073          	csrw	mstatus,a5
    8000007a:	304027f3          	csrr	a5,mie
    8000007e:	0807e793          	ori	a5,a5,128
    80000082:	30479073          	csrw	mie,a5
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
    80000094:	300027f3          	csrr	a5,mstatus
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffc7b67>
    8000009e:	8ff9                	and	a5,a5,a4
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
    800000a8:	30079073          	csrw	mstatus,a5
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	e1078793          	addi	a5,a5,-496 # 80000ebc <main>
    800000b4:	34179073          	csrw	mepc,a5
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
    800000c6:	30379073          	csrw	mideleg,a5
    800000ca:	104027f3          	csrr	a5,sie
    800000ce:	2227e793          	ori	a5,a5,546
    800000d2:	10479073          	csrw	sie,a5
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
    800000ec:	f14027f3          	csrr	a5,mhartid
    800000f0:	2781                	sext.w	a5,a5
    800000f2:	823e                	mv	tp,a5
    800000f4:	30200073          	mret
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	094080e7          	jalr	148(ra) # 800021be <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	780080e7          	jalr	1920(ra) # 800008ba <uartputc>
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
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
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
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
    80000186:	00060b1b          	sext.w	s6,a2
    8000018a:	00012517          	auipc	a0,0x12
    8000018e:	ff650513          	addi	a0,a0,-10 # 80012180 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a88080e7          	jalr	-1400(ra) # 80000c1a <acquire>
    8000019a:	00012497          	auipc	s1,0x12
    8000019e:	fe648493          	addi	s1,s1,-26 # 80012180 <cons>
    800001a2:	00012917          	auipc	s2,0x12
    800001a6:	07690913          	addi	s2,s2,118 # 80012218 <cons+0x98>
    800001aa:	4b91                	li	s7,4
    800001ac:	5c7d                	li	s8,-1
    800001ae:	4ca9                	li	s9,10
    800001b0:	07305963          	blez	s3,80000222 <consoleread+0xbe>
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71563          	bne	a4,a5,800001e6 <consoleread+0x82>
    800001c0:	00002097          	auipc	ra,0x2
    800001c4:	930080e7          	jalr	-1744(ra) # 80001af0 <myproc>
    800001c8:	2b052783          	lw	a5,688(a0)
    800001cc:	e7b5                	bnez	a5,80000238 <consoleread+0xd4>
    800001ce:	85a6                	mv	a1,s1
    800001d0:	854a                	mv	a0,s2
    800001d2:	00002097          	auipc	ra,0x2
    800001d6:	d06080e7          	jalr	-762(ra) # 80001ed8 <sleep>
    800001da:	0984a783          	lw	a5,152(s1)
    800001de:	09c4a703          	lw	a4,156(s1)
    800001e2:	fcf70fe3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    800001e6:	0017871b          	addiw	a4,a5,1
    800001ea:	08e4ac23          	sw	a4,152(s1)
    800001ee:	07f7f713          	andi	a4,a5,127
    800001f2:	9726                	add	a4,a4,s1
    800001f4:	01874703          	lbu	a4,24(a4)
    800001f8:	00070d1b          	sext.w	s10,a4
    800001fc:	077d0563          	beq	s10,s7,80000266 <consoleread+0x102>
    80000200:	f8e40fa3          	sb	a4,-97(s0)
    80000204:	4685                	li	a3,1
    80000206:	f9f40613          	addi	a2,s0,-97
    8000020a:	85d2                	mv	a1,s4
    8000020c:	8556                	mv	a0,s5
    8000020e:	00002097          	auipc	ra,0x2
    80000212:	f58080e7          	jalr	-168(ra) # 80002166 <either_copyout>
    80000216:	01850663          	beq	a0,s8,80000222 <consoleread+0xbe>
    8000021a:	0a05                	addi	s4,s4,1
    8000021c:	39fd                	addiw	s3,s3,-1
    8000021e:	f99d19e3          	bne	s10,s9,800001b0 <consoleread+0x4c>
    80000222:	00012517          	auipc	a0,0x12
    80000226:	f5e50513          	addi	a0,a0,-162 # 80012180 <cons>
    8000022a:	00001097          	auipc	ra,0x1
    8000022e:	aa4080e7          	jalr	-1372(ra) # 80000cce <release>
    80000232:	413b053b          	subw	a0,s6,s3
    80000236:	a811                	j	8000024a <consoleread+0xe6>
    80000238:	00012517          	auipc	a0,0x12
    8000023c:	f4850513          	addi	a0,a0,-184 # 80012180 <cons>
    80000240:	00001097          	auipc	ra,0x1
    80000244:	a8e080e7          	jalr	-1394(ra) # 80000cce <release>
    80000248:	557d                	li	a0,-1
    8000024a:	70a6                	ld	ra,104(sp)
    8000024c:	7406                	ld	s0,96(sp)
    8000024e:	64e6                	ld	s1,88(sp)
    80000250:	6946                	ld	s2,80(sp)
    80000252:	69a6                	ld	s3,72(sp)
    80000254:	6a06                	ld	s4,64(sp)
    80000256:	7ae2                	ld	s5,56(sp)
    80000258:	7b42                	ld	s6,48(sp)
    8000025a:	7ba2                	ld	s7,40(sp)
    8000025c:	7c02                	ld	s8,32(sp)
    8000025e:	6ce2                	ld	s9,24(sp)
    80000260:	6d42                	ld	s10,16(sp)
    80000262:	6165                	addi	sp,sp,112
    80000264:	8082                	ret
    80000266:	0009871b          	sext.w	a4,s3
    8000026a:	fb677ce3          	bgeu	a4,s6,80000222 <consoleread+0xbe>
    8000026e:	00012717          	auipc	a4,0x12
    80000272:	faf72523          	sw	a5,-86(a4) # 80012218 <cons+0x98>
    80000276:	b775                	j	80000222 <consoleread+0xbe>

0000000080000278 <consputc>:
    80000278:	1141                	addi	sp,sp,-16
    8000027a:	e406                	sd	ra,8(sp)
    8000027c:	e022                	sd	s0,0(sp)
    8000027e:	0800                	addi	s0,sp,16
    80000280:	10000793          	li	a5,256
    80000284:	00f50a63          	beq	a0,a5,80000298 <consputc+0x20>
    80000288:	00000097          	auipc	ra,0x0
    8000028c:	560080e7          	jalr	1376(ra) # 800007e8 <uartputc_sync>
    80000290:	60a2                	ld	ra,8(sp)
    80000292:	6402                	ld	s0,0(sp)
    80000294:	0141                	addi	sp,sp,16
    80000296:	8082                	ret
    80000298:	4521                	li	a0,8
    8000029a:	00000097          	auipc	ra,0x0
    8000029e:	54e080e7          	jalr	1358(ra) # 800007e8 <uartputc_sync>
    800002a2:	02000513          	li	a0,32
    800002a6:	00000097          	auipc	ra,0x0
    800002aa:	542080e7          	jalr	1346(ra) # 800007e8 <uartputc_sync>
    800002ae:	4521                	li	a0,8
    800002b0:	00000097          	auipc	ra,0x0
    800002b4:	538080e7          	jalr	1336(ra) # 800007e8 <uartputc_sync>
    800002b8:	bfe1                	j	80000290 <consputc+0x18>

00000000800002ba <consoleintr>:
    800002ba:	1101                	addi	sp,sp,-32
    800002bc:	ec06                	sd	ra,24(sp)
    800002be:	e822                	sd	s0,16(sp)
    800002c0:	e426                	sd	s1,8(sp)
    800002c2:	e04a                	sd	s2,0(sp)
    800002c4:	1000                	addi	s0,sp,32
    800002c6:	84aa                	mv	s1,a0
    800002c8:	00012517          	auipc	a0,0x12
    800002cc:	eb850513          	addi	a0,a0,-328 # 80012180 <cons>
    800002d0:	00001097          	auipc	ra,0x1
    800002d4:	94a080e7          	jalr	-1718(ra) # 80000c1a <acquire>
    800002d8:	47d5                	li	a5,21
    800002da:	0af48663          	beq	s1,a5,80000386 <consoleintr+0xcc>
    800002de:	0297ca63          	blt	a5,s1,80000312 <consoleintr+0x58>
    800002e2:	47a1                	li	a5,8
    800002e4:	0ef48763          	beq	s1,a5,800003d2 <consoleintr+0x118>
    800002e8:	47c1                	li	a5,16
    800002ea:	10f49a63          	bne	s1,a5,800003fe <consoleintr+0x144>
    800002ee:	00002097          	auipc	ra,0x2
    800002f2:	f28080e7          	jalr	-216(ra) # 80002216 <procdump>
    800002f6:	00012517          	auipc	a0,0x12
    800002fa:	e8a50513          	addi	a0,a0,-374 # 80012180 <cons>
    800002fe:	00001097          	auipc	ra,0x1
    80000302:	9d0080e7          	jalr	-1584(ra) # 80000cce <release>
    80000306:	60e2                	ld	ra,24(sp)
    80000308:	6442                	ld	s0,16(sp)
    8000030a:	64a2                	ld	s1,8(sp)
    8000030c:	6902                	ld	s2,0(sp)
    8000030e:	6105                	addi	sp,sp,32
    80000310:	8082                	ret
    80000312:	07f00793          	li	a5,127
    80000316:	0af48e63          	beq	s1,a5,800003d2 <consoleintr+0x118>
    8000031a:	00012717          	auipc	a4,0x12
    8000031e:	e6670713          	addi	a4,a4,-410 # 80012180 <cons>
    80000322:	0a072783          	lw	a5,160(a4)
    80000326:	09872703          	lw	a4,152(a4)
    8000032a:	9f99                	subw	a5,a5,a4
    8000032c:	07f00713          	li	a4,127
    80000330:	fcf763e3          	bltu	a4,a5,800002f6 <consoleintr+0x3c>
    80000334:	47b5                	li	a5,13
    80000336:	0cf48763          	beq	s1,a5,80000404 <consoleintr+0x14a>
    8000033a:	8526                	mv	a0,s1
    8000033c:	00000097          	auipc	ra,0x0
    80000340:	f3c080e7          	jalr	-196(ra) # 80000278 <consputc>
    80000344:	00012797          	auipc	a5,0x12
    80000348:	e3c78793          	addi	a5,a5,-452 # 80012180 <cons>
    8000034c:	0a07a703          	lw	a4,160(a5)
    80000350:	0017069b          	addiw	a3,a4,1
    80000354:	0006861b          	sext.w	a2,a3
    80000358:	0ad7a023          	sw	a3,160(a5)
    8000035c:	07f77713          	andi	a4,a4,127
    80000360:	97ba                	add	a5,a5,a4
    80000362:	00978c23          	sb	s1,24(a5)
    80000366:	47a9                	li	a5,10
    80000368:	0cf48563          	beq	s1,a5,80000432 <consoleintr+0x178>
    8000036c:	4791                	li	a5,4
    8000036e:	0cf48263          	beq	s1,a5,80000432 <consoleintr+0x178>
    80000372:	00012797          	auipc	a5,0x12
    80000376:	ea67a783          	lw	a5,-346(a5) # 80012218 <cons+0x98>
    8000037a:	0807879b          	addiw	a5,a5,128
    8000037e:	f6f61ce3          	bne	a2,a5,800002f6 <consoleintr+0x3c>
    80000382:	863e                	mv	a2,a5
    80000384:	a07d                	j	80000432 <consoleintr+0x178>
    80000386:	00012717          	auipc	a4,0x12
    8000038a:	dfa70713          	addi	a4,a4,-518 # 80012180 <cons>
    8000038e:	0a072783          	lw	a5,160(a4)
    80000392:	09c72703          	lw	a4,156(a4)
    80000396:	00012497          	auipc	s1,0x12
    8000039a:	dea48493          	addi	s1,s1,-534 # 80012180 <cons>
    8000039e:	4929                	li	s2,10
    800003a0:	f4f70be3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
    800003a4:	37fd                	addiw	a5,a5,-1
    800003a6:	07f7f713          	andi	a4,a5,127
    800003aa:	9726                	add	a4,a4,s1
    800003ac:	01874703          	lbu	a4,24(a4)
    800003b0:	f52703e3          	beq	a4,s2,800002f6 <consoleintr+0x3c>
    800003b4:	0af4a023          	sw	a5,160(s1)
    800003b8:	10000513          	li	a0,256
    800003bc:	00000097          	auipc	ra,0x0
    800003c0:	ebc080e7          	jalr	-324(ra) # 80000278 <consputc>
    800003c4:	0a04a783          	lw	a5,160(s1)
    800003c8:	09c4a703          	lw	a4,156(s1)
    800003cc:	fcf71ce3          	bne	a4,a5,800003a4 <consoleintr+0xea>
    800003d0:	b71d                	j	800002f6 <consoleintr+0x3c>
    800003d2:	00012717          	auipc	a4,0x12
    800003d6:	dae70713          	addi	a4,a4,-594 # 80012180 <cons>
    800003da:	0a072783          	lw	a5,160(a4)
    800003de:	09c72703          	lw	a4,156(a4)
    800003e2:	f0f70ae3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
    800003e6:	37fd                	addiw	a5,a5,-1
    800003e8:	00012717          	auipc	a4,0x12
    800003ec:	e2f72c23          	sw	a5,-456(a4) # 80012220 <cons+0xa0>
    800003f0:	10000513          	li	a0,256
    800003f4:	00000097          	auipc	ra,0x0
    800003f8:	e84080e7          	jalr	-380(ra) # 80000278 <consputc>
    800003fc:	bded                	j	800002f6 <consoleintr+0x3c>
    800003fe:	ee048ce3          	beqz	s1,800002f6 <consoleintr+0x3c>
    80000402:	bf21                	j	8000031a <consoleintr+0x60>
    80000404:	4529                	li	a0,10
    80000406:	00000097          	auipc	ra,0x0
    8000040a:	e72080e7          	jalr	-398(ra) # 80000278 <consputc>
    8000040e:	00012797          	auipc	a5,0x12
    80000412:	d7278793          	addi	a5,a5,-654 # 80012180 <cons>
    80000416:	0a07a703          	lw	a4,160(a5)
    8000041a:	0017069b          	addiw	a3,a4,1
    8000041e:	0006861b          	sext.w	a2,a3
    80000422:	0ad7a023          	sw	a3,160(a5)
    80000426:	07f77713          	andi	a4,a4,127
    8000042a:	97ba                	add	a5,a5,a4
    8000042c:	4729                	li	a4,10
    8000042e:	00e78c23          	sb	a4,24(a5)
    80000432:	00012797          	auipc	a5,0x12
    80000436:	dec7a523          	sw	a2,-534(a5) # 8001221c <cons+0x9c>
    8000043a:	00012517          	auipc	a0,0x12
    8000043e:	dde50513          	addi	a0,a0,-546 # 80012218 <cons+0x98>
    80000442:	00002097          	auipc	ra,0x2
    80000446:	afc080e7          	jalr	-1284(ra) # 80001f3e <wakeup>
    8000044a:	b575                	j	800002f6 <consoleintr+0x3c>

000000008000044c <consoleinit>:
    8000044c:	1141                	addi	sp,sp,-16
    8000044e:	e406                	sd	ra,8(sp)
    80000450:	e022                	sd	s0,0(sp)
    80000452:	0800                	addi	s0,sp,16
    80000454:	00009597          	auipc	a1,0x9
    80000458:	bbc58593          	addi	a1,a1,-1092 # 80009010 <etext+0x10>
    8000045c:	00012517          	auipc	a0,0x12
    80000460:	d2450513          	addi	a0,a0,-732 # 80012180 <cons>
    80000464:	00000097          	auipc	ra,0x0
    80000468:	726080e7          	jalr	1830(ra) # 80000b8a <initlock>
    8000046c:	00000097          	auipc	ra,0x0
    80000470:	32c080e7          	jalr	812(ra) # 80000798 <uartinit>
    80000474:	00031797          	auipc	a5,0x31
    80000478:	0bc78793          	addi	a5,a5,188 # 80031530 <devsw>
    8000047c:	00000717          	auipc	a4,0x0
    80000480:	ce870713          	addi	a4,a4,-792 # 80000164 <consoleread>
    80000484:	eb98                	sd	a4,16(a5)
    80000486:	00000717          	auipc	a4,0x0
    8000048a:	c7a70713          	addi	a4,a4,-902 # 80000100 <consolewrite>
    8000048e:	ef98                	sd	a4,24(a5)
    80000490:	60a2                	ld	ra,8(sp)
    80000492:	6402                	ld	s0,0(sp)
    80000494:	0141                	addi	sp,sp,16
    80000496:	8082                	ret

0000000080000498 <printint>:
    80000498:	7179                	addi	sp,sp,-48
    8000049a:	f406                	sd	ra,40(sp)
    8000049c:	f022                	sd	s0,32(sp)
    8000049e:	ec26                	sd	s1,24(sp)
    800004a0:	e84a                	sd	s2,16(sp)
    800004a2:	1800                	addi	s0,sp,48
    800004a4:	c219                	beqz	a2,800004aa <printint+0x12>
    800004a6:	08054763          	bltz	a0,80000534 <printint+0x9c>
    800004aa:	2501                	sext.w	a0,a0
    800004ac:	4881                	li	a7,0
    800004ae:	fd040693          	addi	a3,s0,-48
    800004b2:	4701                	li	a4,0
    800004b4:	2581                	sext.w	a1,a1
    800004b6:	00009617          	auipc	a2,0x9
    800004ba:	b8a60613          	addi	a2,a2,-1142 # 80009040 <digits>
    800004be:	883a                	mv	a6,a4
    800004c0:	2705                	addiw	a4,a4,1
    800004c2:	02b577bb          	remuw	a5,a0,a1
    800004c6:	1782                	slli	a5,a5,0x20
    800004c8:	9381                	srli	a5,a5,0x20
    800004ca:	97b2                	add	a5,a5,a2
    800004cc:	0007c783          	lbu	a5,0(a5)
    800004d0:	00f68023          	sb	a5,0(a3)
    800004d4:	0005079b          	sext.w	a5,a0
    800004d8:	02b5553b          	divuw	a0,a0,a1
    800004dc:	0685                	addi	a3,a3,1
    800004de:	feb7f0e3          	bgeu	a5,a1,800004be <printint+0x26>
    800004e2:	00088c63          	beqz	a7,800004fa <printint+0x62>
    800004e6:	fe070793          	addi	a5,a4,-32
    800004ea:	00878733          	add	a4,a5,s0
    800004ee:	02d00793          	li	a5,45
    800004f2:	fef70823          	sb	a5,-16(a4)
    800004f6:	0028071b          	addiw	a4,a6,2
    800004fa:	02e05763          	blez	a4,80000528 <printint+0x90>
    800004fe:	fd040793          	addi	a5,s0,-48
    80000502:	00e784b3          	add	s1,a5,a4
    80000506:	fff78913          	addi	s2,a5,-1
    8000050a:	993a                	add	s2,s2,a4
    8000050c:	377d                	addiw	a4,a4,-1
    8000050e:	1702                	slli	a4,a4,0x20
    80000510:	9301                	srli	a4,a4,0x20
    80000512:	40e90933          	sub	s2,s2,a4
    80000516:	fff4c503          	lbu	a0,-1(s1)
    8000051a:	00000097          	auipc	ra,0x0
    8000051e:	d5e080e7          	jalr	-674(ra) # 80000278 <consputc>
    80000522:	14fd                	addi	s1,s1,-1
    80000524:	ff2499e3          	bne	s1,s2,80000516 <printint+0x7e>
    80000528:	70a2                	ld	ra,40(sp)
    8000052a:	7402                	ld	s0,32(sp)
    8000052c:	64e2                	ld	s1,24(sp)
    8000052e:	6942                	ld	s2,16(sp)
    80000530:	6145                	addi	sp,sp,48
    80000532:	8082                	ret
    80000534:	40a0053b          	negw	a0,a0
    80000538:	4885                	li	a7,1
    8000053a:	bf95                	j	800004ae <printint+0x16>

000000008000053c <panic>:
    8000053c:	1101                	addi	sp,sp,-32
    8000053e:	ec06                	sd	ra,24(sp)
    80000540:	e822                	sd	s0,16(sp)
    80000542:	e426                	sd	s1,8(sp)
    80000544:	1000                	addi	s0,sp,32
    80000546:	84aa                	mv	s1,a0
    80000548:	00012797          	auipc	a5,0x12
    8000054c:	ce07ac23          	sw	zero,-776(a5) # 80012240 <pr+0x18>
    80000550:	00009517          	auipc	a0,0x9
    80000554:	ac850513          	addi	a0,a0,-1336 # 80009018 <etext+0x18>
    80000558:	00000097          	auipc	ra,0x0
    8000055c:	02e080e7          	jalr	46(ra) # 80000586 <printf>
    80000560:	8526                	mv	a0,s1
    80000562:	00000097          	auipc	ra,0x0
    80000566:	024080e7          	jalr	36(ra) # 80000586 <printf>
    8000056a:	00009517          	auipc	a0,0x9
    8000056e:	b5e50513          	addi	a0,a0,-1186 # 800090c8 <digits+0x88>
    80000572:	00000097          	auipc	ra,0x0
    80000576:	014080e7          	jalr	20(ra) # 80000586 <printf>
    8000057a:	4785                	li	a5,1
    8000057c:	0000a717          	auipc	a4,0xa
    80000580:	a8f72223          	sw	a5,-1404(a4) # 8000a000 <panicked>
    80000584:	a001                	j	80000584 <panic+0x48>

0000000080000586 <printf>:
    80000586:	7131                	addi	sp,sp,-192
    80000588:	fc86                	sd	ra,120(sp)
    8000058a:	f8a2                	sd	s0,112(sp)
    8000058c:	f4a6                	sd	s1,104(sp)
    8000058e:	f0ca                	sd	s2,96(sp)
    80000590:	ecce                	sd	s3,88(sp)
    80000592:	e8d2                	sd	s4,80(sp)
    80000594:	e4d6                	sd	s5,72(sp)
    80000596:	e0da                	sd	s6,64(sp)
    80000598:	fc5e                	sd	s7,56(sp)
    8000059a:	f862                	sd	s8,48(sp)
    8000059c:	f466                	sd	s9,40(sp)
    8000059e:	f06a                	sd	s10,32(sp)
    800005a0:	ec6e                	sd	s11,24(sp)
    800005a2:	0100                	addi	s0,sp,128
    800005a4:	8a2a                	mv	s4,a0
    800005a6:	e40c                	sd	a1,8(s0)
    800005a8:	e810                	sd	a2,16(s0)
    800005aa:	ec14                	sd	a3,24(s0)
    800005ac:	f018                	sd	a4,32(s0)
    800005ae:	f41c                	sd	a5,40(s0)
    800005b0:	03043823          	sd	a6,48(s0)
    800005b4:	03143c23          	sd	a7,56(s0)
    800005b8:	00012d97          	auipc	s11,0x12
    800005bc:	c88dad83          	lw	s11,-888(s11) # 80012240 <pr+0x18>
    800005c0:	020d9b63          	bnez	s11,800005f6 <printf+0x70>
    800005c4:	040a0263          	beqz	s4,80000608 <printf+0x82>
    800005c8:	00840793          	addi	a5,s0,8
    800005cc:	f8f43423          	sd	a5,-120(s0)
    800005d0:	000a4503          	lbu	a0,0(s4)
    800005d4:	14050f63          	beqz	a0,80000732 <printf+0x1ac>
    800005d8:	4981                	li	s3,0
    800005da:	02500a93          	li	s5,37
    800005de:	07000b93          	li	s7,112
    800005e2:	4d41                	li	s10,16
    800005e4:	00009b17          	auipc	s6,0x9
    800005e8:	a5cb0b13          	addi	s6,s6,-1444 # 80009040 <digits>
    800005ec:	07300c93          	li	s9,115
    800005f0:	06400c13          	li	s8,100
    800005f4:	a82d                	j	8000062e <printf+0xa8>
    800005f6:	00012517          	auipc	a0,0x12
    800005fa:	c3250513          	addi	a0,a0,-974 # 80012228 <pr>
    800005fe:	00000097          	auipc	ra,0x0
    80000602:	61c080e7          	jalr	1564(ra) # 80000c1a <acquire>
    80000606:	bf7d                	j	800005c4 <printf+0x3e>
    80000608:	00009517          	auipc	a0,0x9
    8000060c:	a2050513          	addi	a0,a0,-1504 # 80009028 <etext+0x28>
    80000610:	00000097          	auipc	ra,0x0
    80000614:	f2c080e7          	jalr	-212(ra) # 8000053c <panic>
    80000618:	00000097          	auipc	ra,0x0
    8000061c:	c60080e7          	jalr	-928(ra) # 80000278 <consputc>
    80000620:	2985                	addiw	s3,s3,1
    80000622:	013a07b3          	add	a5,s4,s3
    80000626:	0007c503          	lbu	a0,0(a5)
    8000062a:	10050463          	beqz	a0,80000732 <printf+0x1ac>
    8000062e:	ff5515e3          	bne	a0,s5,80000618 <printf+0x92>
    80000632:	2985                	addiw	s3,s3,1
    80000634:	013a07b3          	add	a5,s4,s3
    80000638:	0007c783          	lbu	a5,0(a5)
    8000063c:	0007849b          	sext.w	s1,a5
    80000640:	cbed                	beqz	a5,80000732 <printf+0x1ac>
    80000642:	05778a63          	beq	a5,s7,80000696 <printf+0x110>
    80000646:	02fbf663          	bgeu	s7,a5,80000672 <printf+0xec>
    8000064a:	09978863          	beq	a5,s9,800006da <printf+0x154>
    8000064e:	07800713          	li	a4,120
    80000652:	0ce79563          	bne	a5,a4,8000071c <printf+0x196>
    80000656:	f8843783          	ld	a5,-120(s0)
    8000065a:	00878713          	addi	a4,a5,8
    8000065e:	f8e43423          	sd	a4,-120(s0)
    80000662:	4605                	li	a2,1
    80000664:	85ea                	mv	a1,s10
    80000666:	4388                	lw	a0,0(a5)
    80000668:	00000097          	auipc	ra,0x0
    8000066c:	e30080e7          	jalr	-464(ra) # 80000498 <printint>
    80000670:	bf45                	j	80000620 <printf+0x9a>
    80000672:	09578f63          	beq	a5,s5,80000710 <printf+0x18a>
    80000676:	0b879363          	bne	a5,s8,8000071c <printf+0x196>
    8000067a:	f8843783          	ld	a5,-120(s0)
    8000067e:	00878713          	addi	a4,a5,8
    80000682:	f8e43423          	sd	a4,-120(s0)
    80000686:	4605                	li	a2,1
    80000688:	45a9                	li	a1,10
    8000068a:	4388                	lw	a0,0(a5)
    8000068c:	00000097          	auipc	ra,0x0
    80000690:	e0c080e7          	jalr	-500(ra) # 80000498 <printint>
    80000694:	b771                	j	80000620 <printf+0x9a>
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	addi	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	0007b903          	ld	s2,0(a5)
    800006a6:	03000513          	li	a0,48
    800006aa:	00000097          	auipc	ra,0x0
    800006ae:	bce080e7          	jalr	-1074(ra) # 80000278 <consputc>
    800006b2:	07800513          	li	a0,120
    800006b6:	00000097          	auipc	ra,0x0
    800006ba:	bc2080e7          	jalr	-1086(ra) # 80000278 <consputc>
    800006be:	84ea                	mv	s1,s10
    800006c0:	03c95793          	srli	a5,s2,0x3c
    800006c4:	97da                	add	a5,a5,s6
    800006c6:	0007c503          	lbu	a0,0(a5)
    800006ca:	00000097          	auipc	ra,0x0
    800006ce:	bae080e7          	jalr	-1106(ra) # 80000278 <consputc>
    800006d2:	0912                	slli	s2,s2,0x4
    800006d4:	34fd                	addiw	s1,s1,-1
    800006d6:	f4ed                	bnez	s1,800006c0 <printf+0x13a>
    800006d8:	b7a1                	j	80000620 <printf+0x9a>
    800006da:	f8843783          	ld	a5,-120(s0)
    800006de:	00878713          	addi	a4,a5,8
    800006e2:	f8e43423          	sd	a4,-120(s0)
    800006e6:	6384                	ld	s1,0(a5)
    800006e8:	cc89                	beqz	s1,80000702 <printf+0x17c>
    800006ea:	0004c503          	lbu	a0,0(s1)
    800006ee:	d90d                	beqz	a0,80000620 <printf+0x9a>
    800006f0:	00000097          	auipc	ra,0x0
    800006f4:	b88080e7          	jalr	-1144(ra) # 80000278 <consputc>
    800006f8:	0485                	addi	s1,s1,1
    800006fa:	0004c503          	lbu	a0,0(s1)
    800006fe:	f96d                	bnez	a0,800006f0 <printf+0x16a>
    80000700:	b705                	j	80000620 <printf+0x9a>
    80000702:	00009497          	auipc	s1,0x9
    80000706:	91e48493          	addi	s1,s1,-1762 # 80009020 <etext+0x20>
    8000070a:	02800513          	li	a0,40
    8000070e:	b7cd                	j	800006f0 <printf+0x16a>
    80000710:	8556                	mv	a0,s5
    80000712:	00000097          	auipc	ra,0x0
    80000716:	b66080e7          	jalr	-1178(ra) # 80000278 <consputc>
    8000071a:	b719                	j	80000620 <printf+0x9a>
    8000071c:	8556                	mv	a0,s5
    8000071e:	00000097          	auipc	ra,0x0
    80000722:	b5a080e7          	jalr	-1190(ra) # 80000278 <consputc>
    80000726:	8526                	mv	a0,s1
    80000728:	00000097          	auipc	ra,0x0
    8000072c:	b50080e7          	jalr	-1200(ra) # 80000278 <consputc>
    80000730:	bdc5                	j	80000620 <printf+0x9a>
    80000732:	020d9163          	bnez	s11,80000754 <printf+0x1ce>
    80000736:	70e6                	ld	ra,120(sp)
    80000738:	7446                	ld	s0,112(sp)
    8000073a:	74a6                	ld	s1,104(sp)
    8000073c:	7906                	ld	s2,96(sp)
    8000073e:	69e6                	ld	s3,88(sp)
    80000740:	6a46                	ld	s4,80(sp)
    80000742:	6aa6                	ld	s5,72(sp)
    80000744:	6b06                	ld	s6,64(sp)
    80000746:	7be2                	ld	s7,56(sp)
    80000748:	7c42                	ld	s8,48(sp)
    8000074a:	7ca2                	ld	s9,40(sp)
    8000074c:	7d02                	ld	s10,32(sp)
    8000074e:	6de2                	ld	s11,24(sp)
    80000750:	6129                	addi	sp,sp,192
    80000752:	8082                	ret
    80000754:	00012517          	auipc	a0,0x12
    80000758:	ad450513          	addi	a0,a0,-1324 # 80012228 <pr>
    8000075c:	00000097          	auipc	ra,0x0
    80000760:	572080e7          	jalr	1394(ra) # 80000cce <release>
    80000764:	bfc9                	j	80000736 <printf+0x1b0>

0000000080000766 <printfinit>:
    80000766:	1101                	addi	sp,sp,-32
    80000768:	ec06                	sd	ra,24(sp)
    8000076a:	e822                	sd	s0,16(sp)
    8000076c:	e426                	sd	s1,8(sp)
    8000076e:	1000                	addi	s0,sp,32
    80000770:	00012497          	auipc	s1,0x12
    80000774:	ab848493          	addi	s1,s1,-1352 # 80012228 <pr>
    80000778:	00009597          	auipc	a1,0x9
    8000077c:	8c058593          	addi	a1,a1,-1856 # 80009038 <etext+0x38>
    80000780:	8526                	mv	a0,s1
    80000782:	00000097          	auipc	ra,0x0
    80000786:	408080e7          	jalr	1032(ra) # 80000b8a <initlock>
    8000078a:	4785                	li	a5,1
    8000078c:	cc9c                	sw	a5,24(s1)
    8000078e:	60e2                	ld	ra,24(sp)
    80000790:	6442                	ld	s0,16(sp)
    80000792:	64a2                	ld	s1,8(sp)
    80000794:	6105                	addi	sp,sp,32
    80000796:	8082                	ret

0000000080000798 <uartinit>:
    80000798:	1141                	addi	sp,sp,-16
    8000079a:	e406                	sd	ra,8(sp)
    8000079c:	e022                	sd	s0,0(sp)
    8000079e:	0800                	addi	s0,sp,16
    800007a0:	100007b7          	lui	a5,0x10000
    800007a4:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>
    800007a8:	f8000713          	li	a4,-128
    800007ac:	00e781a3          	sb	a4,3(a5)
    800007b0:	470d                	li	a4,3
    800007b2:	00e78023          	sb	a4,0(a5)
    800007b6:	000780a3          	sb	zero,1(a5)
    800007ba:	00e781a3          	sb	a4,3(a5)
    800007be:	469d                	li	a3,7
    800007c0:	00d78123          	sb	a3,2(a5)
    800007c4:	00e780a3          	sb	a4,1(a5)
    800007c8:	00009597          	auipc	a1,0x9
    800007cc:	89058593          	addi	a1,a1,-1904 # 80009058 <digits+0x18>
    800007d0:	00012517          	auipc	a0,0x12
    800007d4:	a7850513          	addi	a0,a0,-1416 # 80012248 <uart_tx_lock>
    800007d8:	00000097          	auipc	ra,0x0
    800007dc:	3b2080e7          	jalr	946(ra) # 80000b8a <initlock>
    800007e0:	60a2                	ld	ra,8(sp)
    800007e2:	6402                	ld	s0,0(sp)
    800007e4:	0141                	addi	sp,sp,16
    800007e6:	8082                	ret

00000000800007e8 <uartputc_sync>:
    800007e8:	1101                	addi	sp,sp,-32
    800007ea:	ec06                	sd	ra,24(sp)
    800007ec:	e822                	sd	s0,16(sp)
    800007ee:	e426                	sd	s1,8(sp)
    800007f0:	1000                	addi	s0,sp,32
    800007f2:	84aa                	mv	s1,a0
    800007f4:	00000097          	auipc	ra,0x0
    800007f8:	3da080e7          	jalr	986(ra) # 80000bce <push_off>
    800007fc:	0000a797          	auipc	a5,0xa
    80000800:	8047a783          	lw	a5,-2044(a5) # 8000a000 <panicked>
    80000804:	10000737          	lui	a4,0x10000
    80000808:	c391                	beqz	a5,8000080c <uartputc_sync+0x24>
    8000080a:	a001                	j	8000080a <uartputc_sync+0x22>
    8000080c:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000810:	0207f793          	andi	a5,a5,32
    80000814:	dfe5                	beqz	a5,8000080c <uartputc_sync+0x24>
    80000816:	0ff4f513          	zext.b	a0,s1
    8000081a:	100007b7          	lui	a5,0x10000
    8000081e:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>
    80000822:	00000097          	auipc	ra,0x0
    80000826:	44c080e7          	jalr	1100(ra) # 80000c6e <pop_off>
    8000082a:	60e2                	ld	ra,24(sp)
    8000082c:	6442                	ld	s0,16(sp)
    8000082e:	64a2                	ld	s1,8(sp)
    80000830:	6105                	addi	sp,sp,32
    80000832:	8082                	ret

0000000080000834 <uartstart>:
    80000834:	00009797          	auipc	a5,0x9
    80000838:	7d47b783          	ld	a5,2004(a5) # 8000a008 <uart_tx_r>
    8000083c:	00009717          	auipc	a4,0x9
    80000840:	7d473703          	ld	a4,2004(a4) # 8000a010 <uart_tx_w>
    80000844:	06f70a63          	beq	a4,a5,800008b8 <uartstart+0x84>
    80000848:	7139                	addi	sp,sp,-64
    8000084a:	fc06                	sd	ra,56(sp)
    8000084c:	f822                	sd	s0,48(sp)
    8000084e:	f426                	sd	s1,40(sp)
    80000850:	f04a                	sd	s2,32(sp)
    80000852:	ec4e                	sd	s3,24(sp)
    80000854:	e852                	sd	s4,16(sp)
    80000856:	e456                	sd	s5,8(sp)
    80000858:	0080                	addi	s0,sp,64
    8000085a:	10000937          	lui	s2,0x10000
    8000085e:	00012a17          	auipc	s4,0x12
    80000862:	9eaa0a13          	addi	s4,s4,-1558 # 80012248 <uart_tx_lock>
    80000866:	00009497          	auipc	s1,0x9
    8000086a:	7a248493          	addi	s1,s1,1954 # 8000a008 <uart_tx_r>
    8000086e:	00009997          	auipc	s3,0x9
    80000872:	7a298993          	addi	s3,s3,1954 # 8000a010 <uart_tx_w>
    80000876:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087a:	02077713          	andi	a4,a4,32
    8000087e:	c705                	beqz	a4,800008a6 <uartstart+0x72>
    80000880:	01f7f713          	andi	a4,a5,31
    80000884:	9752                	add	a4,a4,s4
    80000886:	01874a83          	lbu	s5,24(a4)
    8000088a:	0785                	addi	a5,a5,1
    8000088c:	e09c                	sd	a5,0(s1)
    8000088e:	8526                	mv	a0,s1
    80000890:	00001097          	auipc	ra,0x1
    80000894:	6ae080e7          	jalr	1710(ra) # 80001f3e <wakeup>
    80000898:	01590023          	sb	s5,0(s2)
    8000089c:	609c                	ld	a5,0(s1)
    8000089e:	0009b703          	ld	a4,0(s3)
    800008a2:	fcf71ae3          	bne	a4,a5,80000876 <uartstart+0x42>
    800008a6:	70e2                	ld	ra,56(sp)
    800008a8:	7442                	ld	s0,48(sp)
    800008aa:	74a2                	ld	s1,40(sp)
    800008ac:	7902                	ld	s2,32(sp)
    800008ae:	69e2                	ld	s3,24(sp)
    800008b0:	6a42                	ld	s4,16(sp)
    800008b2:	6aa2                	ld	s5,8(sp)
    800008b4:	6121                	addi	sp,sp,64
    800008b6:	8082                	ret
    800008b8:	8082                	ret

00000000800008ba <uartputc>:
    800008ba:	7179                	addi	sp,sp,-48
    800008bc:	f406                	sd	ra,40(sp)
    800008be:	f022                	sd	s0,32(sp)
    800008c0:	ec26                	sd	s1,24(sp)
    800008c2:	e84a                	sd	s2,16(sp)
    800008c4:	e44e                	sd	s3,8(sp)
    800008c6:	e052                	sd	s4,0(sp)
    800008c8:	1800                	addi	s0,sp,48
    800008ca:	8a2a                	mv	s4,a0
    800008cc:	00012517          	auipc	a0,0x12
    800008d0:	97c50513          	addi	a0,a0,-1668 # 80012248 <uart_tx_lock>
    800008d4:	00000097          	auipc	ra,0x0
    800008d8:	346080e7          	jalr	838(ra) # 80000c1a <acquire>
    800008dc:	00009797          	auipc	a5,0x9
    800008e0:	7247a783          	lw	a5,1828(a5) # 8000a000 <panicked>
    800008e4:	c391                	beqz	a5,800008e8 <uartputc+0x2e>
    800008e6:	a001                	j	800008e6 <uartputc+0x2c>
    800008e8:	00009717          	auipc	a4,0x9
    800008ec:	72873703          	ld	a4,1832(a4) # 8000a010 <uart_tx_w>
    800008f0:	00009797          	auipc	a5,0x9
    800008f4:	7187b783          	ld	a5,1816(a5) # 8000a008 <uart_tx_r>
    800008f8:	02078793          	addi	a5,a5,32
    800008fc:	02e79b63          	bne	a5,a4,80000932 <uartputc+0x78>
    80000900:	00012997          	auipc	s3,0x12
    80000904:	94898993          	addi	s3,s3,-1720 # 80012248 <uart_tx_lock>
    80000908:	00009497          	auipc	s1,0x9
    8000090c:	70048493          	addi	s1,s1,1792 # 8000a008 <uart_tx_r>
    80000910:	00009917          	auipc	s2,0x9
    80000914:	70090913          	addi	s2,s2,1792 # 8000a010 <uart_tx_w>
    80000918:	85ce                	mv	a1,s3
    8000091a:	8526                	mv	a0,s1
    8000091c:	00001097          	auipc	ra,0x1
    80000920:	5bc080e7          	jalr	1468(ra) # 80001ed8 <sleep>
    80000924:	00093703          	ld	a4,0(s2)
    80000928:	609c                	ld	a5,0(s1)
    8000092a:	02078793          	addi	a5,a5,32
    8000092e:	fee785e3          	beq	a5,a4,80000918 <uartputc+0x5e>
    80000932:	00012497          	auipc	s1,0x12
    80000936:	91648493          	addi	s1,s1,-1770 # 80012248 <uart_tx_lock>
    8000093a:	01f77793          	andi	a5,a4,31
    8000093e:	97a6                	add	a5,a5,s1
    80000940:	01478c23          	sb	s4,24(a5)
    80000944:	0705                	addi	a4,a4,1
    80000946:	00009797          	auipc	a5,0x9
    8000094a:	6ce7b523          	sd	a4,1738(a5) # 8000a010 <uart_tx_w>
    8000094e:	00000097          	auipc	ra,0x0
    80000952:	ee6080e7          	jalr	-282(ra) # 80000834 <uartstart>
    80000956:	8526                	mv	a0,s1
    80000958:	00000097          	auipc	ra,0x0
    8000095c:	376080e7          	jalr	886(ra) # 80000cce <release>
    80000960:	70a2                	ld	ra,40(sp)
    80000962:	7402                	ld	s0,32(sp)
    80000964:	64e2                	ld	s1,24(sp)
    80000966:	6942                	ld	s2,16(sp)
    80000968:	69a2                	ld	s3,8(sp)
    8000096a:	6a02                	ld	s4,0(sp)
    8000096c:	6145                	addi	sp,sp,48
    8000096e:	8082                	ret

0000000080000970 <uartgetc>:
    80000970:	1141                	addi	sp,sp,-16
    80000972:	e422                	sd	s0,8(sp)
    80000974:	0800                	addi	s0,sp,16
    80000976:	100007b7          	lui	a5,0x10000
    8000097a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000097e:	8b85                	andi	a5,a5,1
    80000980:	cb81                	beqz	a5,80000990 <uartgetc+0x20>
    80000982:	100007b7          	lui	a5,0x10000
    80000986:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000098a:	6422                	ld	s0,8(sp)
    8000098c:	0141                	addi	sp,sp,16
    8000098e:	8082                	ret
    80000990:	557d                	li	a0,-1
    80000992:	bfe5                	j	8000098a <uartgetc+0x1a>

0000000080000994 <uartintr>:
    80000994:	1101                	addi	sp,sp,-32
    80000996:	ec06                	sd	ra,24(sp)
    80000998:	e822                	sd	s0,16(sp)
    8000099a:	e426                	sd	s1,8(sp)
    8000099c:	1000                	addi	s0,sp,32
    8000099e:	54fd                	li	s1,-1
    800009a0:	a029                	j	800009aa <uartintr+0x16>
    800009a2:	00000097          	auipc	ra,0x0
    800009a6:	918080e7          	jalr	-1768(ra) # 800002ba <consoleintr>
    800009aa:	00000097          	auipc	ra,0x0
    800009ae:	fc6080e7          	jalr	-58(ra) # 80000970 <uartgetc>
    800009b2:	fe9518e3          	bne	a0,s1,800009a2 <uartintr+0xe>
    800009b6:	00012497          	auipc	s1,0x12
    800009ba:	89248493          	addi	s1,s1,-1902 # 80012248 <uart_tx_lock>
    800009be:	8526                	mv	a0,s1
    800009c0:	00000097          	auipc	ra,0x0
    800009c4:	25a080e7          	jalr	602(ra) # 80000c1a <acquire>
    800009c8:	00000097          	auipc	ra,0x0
    800009cc:	e6c080e7          	jalr	-404(ra) # 80000834 <uartstart>
    800009d0:	8526                	mv	a0,s1
    800009d2:	00000097          	auipc	ra,0x0
    800009d6:	2fc080e7          	jalr	764(ra) # 80000cce <release>
    800009da:	60e2                	ld	ra,24(sp)
    800009dc:	6442                	ld	s0,16(sp)
    800009de:	64a2                	ld	s1,8(sp)
    800009e0:	6105                	addi	sp,sp,32
    800009e2:	8082                	ret

00000000800009e4 <kfree>:
    800009e4:	1101                	addi	sp,sp,-32
    800009e6:	ec06                	sd	ra,24(sp)
    800009e8:	e822                	sd	s0,16(sp)
    800009ea:	e426                	sd	s1,8(sp)
    800009ec:	e04a                	sd	s2,0(sp)
    800009ee:	1000                	addi	s0,sp,32
    800009f0:	03451793          	slli	a5,a0,0x34
    800009f4:	ebb9                	bnez	a5,80000a4a <kfree+0x66>
    800009f6:	84aa                	mv	s1,a0
    800009f8:	00036797          	auipc	a5,0x36
    800009fc:	2a078793          	addi	a5,a5,672 # 80036c98 <end>
    80000a00:	04f56563          	bltu	a0,a5,80000a4a <kfree+0x66>
    80000a04:	47c5                	li	a5,17
    80000a06:	07ee                	slli	a5,a5,0x1b
    80000a08:	04f57163          	bgeu	a0,a5,80000a4a <kfree+0x66>
    80000a0c:	6605                	lui	a2,0x1
    80000a0e:	4585                	li	a1,1
    80000a10:	00000097          	auipc	ra,0x0
    80000a14:	306080e7          	jalr	774(ra) # 80000d16 <memset>
    80000a18:	00012917          	auipc	s2,0x12
    80000a1c:	86890913          	addi	s2,s2,-1944 # 80012280 <kmem>
    80000a20:	854a                	mv	a0,s2
    80000a22:	00000097          	auipc	ra,0x0
    80000a26:	1f8080e7          	jalr	504(ra) # 80000c1a <acquire>
    80000a2a:	01893783          	ld	a5,24(s2)
    80000a2e:	e09c                	sd	a5,0(s1)
    80000a30:	00993c23          	sd	s1,24(s2)
    80000a34:	854a                	mv	a0,s2
    80000a36:	00000097          	auipc	ra,0x0
    80000a3a:	298080e7          	jalr	664(ra) # 80000cce <release>
    80000a3e:	60e2                	ld	ra,24(sp)
    80000a40:	6442                	ld	s0,16(sp)
    80000a42:	64a2                	ld	s1,8(sp)
    80000a44:	6902                	ld	s2,0(sp)
    80000a46:	6105                	addi	sp,sp,32
    80000a48:	8082                	ret
    80000a4a:	00008517          	auipc	a0,0x8
    80000a4e:	61650513          	addi	a0,a0,1558 # 80009060 <digits+0x20>
    80000a52:	00000097          	auipc	ra,0x0
    80000a56:	aea080e7          	jalr	-1302(ra) # 8000053c <panic>

0000000080000a5a <freerange>:
    80000a5a:	7179                	addi	sp,sp,-48
    80000a5c:	f406                	sd	ra,40(sp)
    80000a5e:	f022                	sd	s0,32(sp)
    80000a60:	ec26                	sd	s1,24(sp)
    80000a62:	e84a                	sd	s2,16(sp)
    80000a64:	e44e                	sd	s3,8(sp)
    80000a66:	e052                	sd	s4,0(sp)
    80000a68:	1800                	addi	s0,sp,48
    80000a6a:	6785                	lui	a5,0x1
    80000a6c:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a70:	00e504b3          	add	s1,a0,a4
    80000a74:	777d                	lui	a4,0xfffff
    80000a76:	8cf9                	and	s1,s1,a4
    80000a78:	94be                	add	s1,s1,a5
    80000a7a:	0095ee63          	bltu	a1,s1,80000a96 <freerange+0x3c>
    80000a7e:	892e                	mv	s2,a1
    80000a80:	7a7d                	lui	s4,0xfffff
    80000a82:	6985                	lui	s3,0x1
    80000a84:	01448533          	add	a0,s1,s4
    80000a88:	00000097          	auipc	ra,0x0
    80000a8c:	f5c080e7          	jalr	-164(ra) # 800009e4 <kfree>
    80000a90:	94ce                	add	s1,s1,s3
    80000a92:	fe9979e3          	bgeu	s2,s1,80000a84 <freerange+0x2a>
    80000a96:	70a2                	ld	ra,40(sp)
    80000a98:	7402                	ld	s0,32(sp)
    80000a9a:	64e2                	ld	s1,24(sp)
    80000a9c:	6942                	ld	s2,16(sp)
    80000a9e:	69a2                	ld	s3,8(sp)
    80000aa0:	6a02                	ld	s4,0(sp)
    80000aa2:	6145                	addi	sp,sp,48
    80000aa4:	8082                	ret

0000000080000aa6 <kinit>:
    80000aa6:	1141                	addi	sp,sp,-16
    80000aa8:	e406                	sd	ra,8(sp)
    80000aaa:	e022                	sd	s0,0(sp)
    80000aac:	0800                	addi	s0,sp,16
    80000aae:	00008597          	auipc	a1,0x8
    80000ab2:	5ba58593          	addi	a1,a1,1466 # 80009068 <digits+0x28>
    80000ab6:	00011517          	auipc	a0,0x11
    80000aba:	7ca50513          	addi	a0,a0,1994 # 80012280 <kmem>
    80000abe:	00000097          	auipc	ra,0x0
    80000ac2:	0cc080e7          	jalr	204(ra) # 80000b8a <initlock>
    80000ac6:	45c5                	li	a1,17
    80000ac8:	05ee                	slli	a1,a1,0x1b
    80000aca:	00036517          	auipc	a0,0x36
    80000ace:	1ce50513          	addi	a0,a0,462 # 80036c98 <end>
    80000ad2:	00000097          	auipc	ra,0x0
    80000ad6:	f88080e7          	jalr	-120(ra) # 80000a5a <freerange>
    80000ada:	60a2                	ld	ra,8(sp)
    80000adc:	6402                	ld	s0,0(sp)
    80000ade:	0141                	addi	sp,sp,16
    80000ae0:	8082                	ret

0000000080000ae2 <kalloc>:
    80000ae2:	1101                	addi	sp,sp,-32
    80000ae4:	ec06                	sd	ra,24(sp)
    80000ae6:	e822                	sd	s0,16(sp)
    80000ae8:	e426                	sd	s1,8(sp)
    80000aea:	1000                	addi	s0,sp,32
    80000aec:	00011497          	auipc	s1,0x11
    80000af0:	79448493          	addi	s1,s1,1940 # 80012280 <kmem>
    80000af4:	8526                	mv	a0,s1
    80000af6:	00000097          	auipc	ra,0x0
    80000afa:	124080e7          	jalr	292(ra) # 80000c1a <acquire>
    80000afe:	6c84                	ld	s1,24(s1)
    80000b00:	c885                	beqz	s1,80000b30 <kalloc+0x4e>
    80000b02:	609c                	ld	a5,0(s1)
    80000b04:	00011517          	auipc	a0,0x11
    80000b08:	77c50513          	addi	a0,a0,1916 # 80012280 <kmem>
    80000b0c:	ed1c                	sd	a5,24(a0)
    80000b0e:	00000097          	auipc	ra,0x0
    80000b12:	1c0080e7          	jalr	448(ra) # 80000cce <release>
    80000b16:	6605                	lui	a2,0x1
    80000b18:	4595                	li	a1,5
    80000b1a:	8526                	mv	a0,s1
    80000b1c:	00000097          	auipc	ra,0x0
    80000b20:	1fa080e7          	jalr	506(ra) # 80000d16 <memset>
    80000b24:	8526                	mv	a0,s1
    80000b26:	60e2                	ld	ra,24(sp)
    80000b28:	6442                	ld	s0,16(sp)
    80000b2a:	64a2                	ld	s1,8(sp)
    80000b2c:	6105                	addi	sp,sp,32
    80000b2e:	8082                	ret
    80000b30:	00011517          	auipc	a0,0x11
    80000b34:	75050513          	addi	a0,a0,1872 # 80012280 <kmem>
    80000b38:	00000097          	auipc	ra,0x0
    80000b3c:	196080e7          	jalr	406(ra) # 80000cce <release>
    80000b40:	b7d5                	j	80000b24 <kalloc+0x42>

0000000080000b42 <freeCount>:
    80000b42:	1101                	addi	sp,sp,-32
    80000b44:	ec06                	sd	ra,24(sp)
    80000b46:	e822                	sd	s0,16(sp)
    80000b48:	e426                	sd	s1,8(sp)
    80000b4a:	1000                	addi	s0,sp,32
    80000b4c:	00011497          	auipc	s1,0x11
    80000b50:	73448493          	addi	s1,s1,1844 # 80012280 <kmem>
    80000b54:	8526                	mv	a0,s1
    80000b56:	00000097          	auipc	ra,0x0
    80000b5a:	0c4080e7          	jalr	196(ra) # 80000c1a <acquire>
    80000b5e:	6c9c                	ld	a5,24(s1)
    80000b60:	c39d                	beqz	a5,80000b86 <freeCount+0x44>
    80000b62:	4481                	li	s1,0
    80000b64:	2485                	addiw	s1,s1,1
    80000b66:	639c                	ld	a5,0(a5)
    80000b68:	fff5                	bnez	a5,80000b64 <freeCount+0x22>
    80000b6a:	00011517          	auipc	a0,0x11
    80000b6e:	71650513          	addi	a0,a0,1814 # 80012280 <kmem>
    80000b72:	00000097          	auipc	ra,0x0
    80000b76:	15c080e7          	jalr	348(ra) # 80000cce <release>
    80000b7a:	8526                	mv	a0,s1
    80000b7c:	60e2                	ld	ra,24(sp)
    80000b7e:	6442                	ld	s0,16(sp)
    80000b80:	64a2                	ld	s1,8(sp)
    80000b82:	6105                	addi	sp,sp,32
    80000b84:	8082                	ret
    80000b86:	4481                	li	s1,0
    80000b88:	b7cd                	j	80000b6a <freeCount+0x28>

0000000080000b8a <initlock>:
    80000b8a:	1141                	addi	sp,sp,-16
    80000b8c:	e422                	sd	s0,8(sp)
    80000b8e:	0800                	addi	s0,sp,16
    80000b90:	e50c                	sd	a1,8(a0)
    80000b92:	00052023          	sw	zero,0(a0)
    80000b96:	00053823          	sd	zero,16(a0)
    80000b9a:	6422                	ld	s0,8(sp)
    80000b9c:	0141                	addi	sp,sp,16
    80000b9e:	8082                	ret

0000000080000ba0 <holding>:
    80000ba0:	411c                	lw	a5,0(a0)
    80000ba2:	e399                	bnez	a5,80000ba8 <holding+0x8>
    80000ba4:	4501                	li	a0,0
    80000ba6:	8082                	ret
    80000ba8:	1101                	addi	sp,sp,-32
    80000baa:	ec06                	sd	ra,24(sp)
    80000bac:	e822                	sd	s0,16(sp)
    80000bae:	e426                	sd	s1,8(sp)
    80000bb0:	1000                	addi	s0,sp,32
    80000bb2:	6904                	ld	s1,16(a0)
    80000bb4:	00001097          	auipc	ra,0x1
    80000bb8:	f20080e7          	jalr	-224(ra) # 80001ad4 <mycpu>
    80000bbc:	40a48533          	sub	a0,s1,a0
    80000bc0:	00153513          	seqz	a0,a0
    80000bc4:	60e2                	ld	ra,24(sp)
    80000bc6:	6442                	ld	s0,16(sp)
    80000bc8:	64a2                	ld	s1,8(sp)
    80000bca:	6105                	addi	sp,sp,32
    80000bcc:	8082                	ret

0000000080000bce <push_off>:
    80000bce:	1101                	addi	sp,sp,-32
    80000bd0:	ec06                	sd	ra,24(sp)
    80000bd2:	e822                	sd	s0,16(sp)
    80000bd4:	e426                	sd	s1,8(sp)
    80000bd6:	1000                	addi	s0,sp,32
    80000bd8:	100024f3          	csrr	s1,sstatus
    80000bdc:	100027f3          	csrr	a5,sstatus
    80000be0:	9bf5                	andi	a5,a5,-3
    80000be2:	10079073          	csrw	sstatus,a5
    80000be6:	00001097          	auipc	ra,0x1
    80000bea:	eee080e7          	jalr	-274(ra) # 80001ad4 <mycpu>
    80000bee:	5d3c                	lw	a5,120(a0)
    80000bf0:	cf89                	beqz	a5,80000c0a <push_off+0x3c>
    80000bf2:	00001097          	auipc	ra,0x1
    80000bf6:	ee2080e7          	jalr	-286(ra) # 80001ad4 <mycpu>
    80000bfa:	5d3c                	lw	a5,120(a0)
    80000bfc:	2785                	addiw	a5,a5,1
    80000bfe:	dd3c                	sw	a5,120(a0)
    80000c00:	60e2                	ld	ra,24(sp)
    80000c02:	6442                	ld	s0,16(sp)
    80000c04:	64a2                	ld	s1,8(sp)
    80000c06:	6105                	addi	sp,sp,32
    80000c08:	8082                	ret
    80000c0a:	00001097          	auipc	ra,0x1
    80000c0e:	eca080e7          	jalr	-310(ra) # 80001ad4 <mycpu>
    80000c12:	8085                	srli	s1,s1,0x1
    80000c14:	8885                	andi	s1,s1,1
    80000c16:	dd64                	sw	s1,124(a0)
    80000c18:	bfe9                	j	80000bf2 <push_off+0x24>

0000000080000c1a <acquire>:
    80000c1a:	1101                	addi	sp,sp,-32
    80000c1c:	ec06                	sd	ra,24(sp)
    80000c1e:	e822                	sd	s0,16(sp)
    80000c20:	e426                	sd	s1,8(sp)
    80000c22:	1000                	addi	s0,sp,32
    80000c24:	84aa                	mv	s1,a0
    80000c26:	00000097          	auipc	ra,0x0
    80000c2a:	fa8080e7          	jalr	-88(ra) # 80000bce <push_off>
    80000c2e:	8526                	mv	a0,s1
    80000c30:	00000097          	auipc	ra,0x0
    80000c34:	f70080e7          	jalr	-144(ra) # 80000ba0 <holding>
    80000c38:	4705                	li	a4,1
    80000c3a:	e115                	bnez	a0,80000c5e <acquire+0x44>
    80000c3c:	87ba                	mv	a5,a4
    80000c3e:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c42:	2781                	sext.w	a5,a5
    80000c44:	ffe5                	bnez	a5,80000c3c <acquire+0x22>
    80000c46:	0ff0000f          	fence
    80000c4a:	00001097          	auipc	ra,0x1
    80000c4e:	e8a080e7          	jalr	-374(ra) # 80001ad4 <mycpu>
    80000c52:	e888                	sd	a0,16(s1)
    80000c54:	60e2                	ld	ra,24(sp)
    80000c56:	6442                	ld	s0,16(sp)
    80000c58:	64a2                	ld	s1,8(sp)
    80000c5a:	6105                	addi	sp,sp,32
    80000c5c:	8082                	ret
    80000c5e:	00008517          	auipc	a0,0x8
    80000c62:	41250513          	addi	a0,a0,1042 # 80009070 <digits+0x30>
    80000c66:	00000097          	auipc	ra,0x0
    80000c6a:	8d6080e7          	jalr	-1834(ra) # 8000053c <panic>

0000000080000c6e <pop_off>:
    80000c6e:	1141                	addi	sp,sp,-16
    80000c70:	e406                	sd	ra,8(sp)
    80000c72:	e022                	sd	s0,0(sp)
    80000c74:	0800                	addi	s0,sp,16
    80000c76:	00001097          	auipc	ra,0x1
    80000c7a:	e5e080e7          	jalr	-418(ra) # 80001ad4 <mycpu>
    80000c7e:	100027f3          	csrr	a5,sstatus
    80000c82:	8b89                	andi	a5,a5,2
    80000c84:	e78d                	bnez	a5,80000cae <pop_off+0x40>
    80000c86:	5d3c                	lw	a5,120(a0)
    80000c88:	02f05b63          	blez	a5,80000cbe <pop_off+0x50>
    80000c8c:	37fd                	addiw	a5,a5,-1
    80000c8e:	0007871b          	sext.w	a4,a5
    80000c92:	dd3c                	sw	a5,120(a0)
    80000c94:	eb09                	bnez	a4,80000ca6 <pop_off+0x38>
    80000c96:	5d7c                	lw	a5,124(a0)
    80000c98:	c799                	beqz	a5,80000ca6 <pop_off+0x38>
    80000c9a:	100027f3          	csrr	a5,sstatus
    80000c9e:	0027e793          	ori	a5,a5,2
    80000ca2:	10079073          	csrw	sstatus,a5
    80000ca6:	60a2                	ld	ra,8(sp)
    80000ca8:	6402                	ld	s0,0(sp)
    80000caa:	0141                	addi	sp,sp,16
    80000cac:	8082                	ret
    80000cae:	00008517          	auipc	a0,0x8
    80000cb2:	3ca50513          	addi	a0,a0,970 # 80009078 <digits+0x38>
    80000cb6:	00000097          	auipc	ra,0x0
    80000cba:	886080e7          	jalr	-1914(ra) # 8000053c <panic>
    80000cbe:	00008517          	auipc	a0,0x8
    80000cc2:	3d250513          	addi	a0,a0,978 # 80009090 <digits+0x50>
    80000cc6:	00000097          	auipc	ra,0x0
    80000cca:	876080e7          	jalr	-1930(ra) # 8000053c <panic>

0000000080000cce <release>:
    80000cce:	1101                	addi	sp,sp,-32
    80000cd0:	ec06                	sd	ra,24(sp)
    80000cd2:	e822                	sd	s0,16(sp)
    80000cd4:	e426                	sd	s1,8(sp)
    80000cd6:	1000                	addi	s0,sp,32
    80000cd8:	84aa                	mv	s1,a0
    80000cda:	00000097          	auipc	ra,0x0
    80000cde:	ec6080e7          	jalr	-314(ra) # 80000ba0 <holding>
    80000ce2:	c115                	beqz	a0,80000d06 <release+0x38>
    80000ce4:	0004b823          	sd	zero,16(s1)
    80000ce8:	0ff0000f          	fence
    80000cec:	0f50000f          	fence	iorw,ow
    80000cf0:	0804a02f          	amoswap.w	zero,zero,(s1)
    80000cf4:	00000097          	auipc	ra,0x0
    80000cf8:	f7a080e7          	jalr	-134(ra) # 80000c6e <pop_off>
    80000cfc:	60e2                	ld	ra,24(sp)
    80000cfe:	6442                	ld	s0,16(sp)
    80000d00:	64a2                	ld	s1,8(sp)
    80000d02:	6105                	addi	sp,sp,32
    80000d04:	8082                	ret
    80000d06:	00008517          	auipc	a0,0x8
    80000d0a:	39250513          	addi	a0,a0,914 # 80009098 <digits+0x58>
    80000d0e:	00000097          	auipc	ra,0x0
    80000d12:	82e080e7          	jalr	-2002(ra) # 8000053c <panic>

0000000080000d16 <memset>:
    80000d16:	1141                	addi	sp,sp,-16
    80000d18:	e422                	sd	s0,8(sp)
    80000d1a:	0800                	addi	s0,sp,16
    80000d1c:	ca19                	beqz	a2,80000d32 <memset+0x1c>
    80000d1e:	87aa                	mv	a5,a0
    80000d20:	1602                	slli	a2,a2,0x20
    80000d22:	9201                	srli	a2,a2,0x20
    80000d24:	00a60733          	add	a4,a2,a0
    80000d28:	00b78023          	sb	a1,0(a5)
    80000d2c:	0785                	addi	a5,a5,1
    80000d2e:	fee79de3          	bne	a5,a4,80000d28 <memset+0x12>
    80000d32:	6422                	ld	s0,8(sp)
    80000d34:	0141                	addi	sp,sp,16
    80000d36:	8082                	ret

0000000080000d38 <memcmp>:
    80000d38:	1141                	addi	sp,sp,-16
    80000d3a:	e422                	sd	s0,8(sp)
    80000d3c:	0800                	addi	s0,sp,16
    80000d3e:	ca05                	beqz	a2,80000d6e <memcmp+0x36>
    80000d40:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d44:	1682                	slli	a3,a3,0x20
    80000d46:	9281                	srli	a3,a3,0x20
    80000d48:	0685                	addi	a3,a3,1
    80000d4a:	96aa                	add	a3,a3,a0
    80000d4c:	00054783          	lbu	a5,0(a0)
    80000d50:	0005c703          	lbu	a4,0(a1)
    80000d54:	00e79863          	bne	a5,a4,80000d64 <memcmp+0x2c>
    80000d58:	0505                	addi	a0,a0,1
    80000d5a:	0585                	addi	a1,a1,1
    80000d5c:	fed518e3          	bne	a0,a3,80000d4c <memcmp+0x14>
    80000d60:	4501                	li	a0,0
    80000d62:	a019                	j	80000d68 <memcmp+0x30>
    80000d64:	40e7853b          	subw	a0,a5,a4
    80000d68:	6422                	ld	s0,8(sp)
    80000d6a:	0141                	addi	sp,sp,16
    80000d6c:	8082                	ret
    80000d6e:	4501                	li	a0,0
    80000d70:	bfe5                	j	80000d68 <memcmp+0x30>

0000000080000d72 <memmove>:
    80000d72:	1141                	addi	sp,sp,-16
    80000d74:	e422                	sd	s0,8(sp)
    80000d76:	0800                	addi	s0,sp,16
    80000d78:	c205                	beqz	a2,80000d98 <memmove+0x26>
    80000d7a:	02a5e263          	bltu	a1,a0,80000d9e <memmove+0x2c>
    80000d7e:	1602                	slli	a2,a2,0x20
    80000d80:	9201                	srli	a2,a2,0x20
    80000d82:	00c587b3          	add	a5,a1,a2
    80000d86:	872a                	mv	a4,a0
    80000d88:	0585                	addi	a1,a1,1
    80000d8a:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffc8369>
    80000d8c:	fff5c683          	lbu	a3,-1(a1)
    80000d90:	fed70fa3          	sb	a3,-1(a4)
    80000d94:	fef59ae3          	bne	a1,a5,80000d88 <memmove+0x16>
    80000d98:	6422                	ld	s0,8(sp)
    80000d9a:	0141                	addi	sp,sp,16
    80000d9c:	8082                	ret
    80000d9e:	02061693          	slli	a3,a2,0x20
    80000da2:	9281                	srli	a3,a3,0x20
    80000da4:	00d58733          	add	a4,a1,a3
    80000da8:	fce57be3          	bgeu	a0,a4,80000d7e <memmove+0xc>
    80000dac:	96aa                	add	a3,a3,a0
    80000dae:	fff6079b          	addiw	a5,a2,-1
    80000db2:	1782                	slli	a5,a5,0x20
    80000db4:	9381                	srli	a5,a5,0x20
    80000db6:	fff7c793          	not	a5,a5
    80000dba:	97ba                	add	a5,a5,a4
    80000dbc:	177d                	addi	a4,a4,-1
    80000dbe:	16fd                	addi	a3,a3,-1
    80000dc0:	00074603          	lbu	a2,0(a4)
    80000dc4:	00c68023          	sb	a2,0(a3)
    80000dc8:	fee79ae3          	bne	a5,a4,80000dbc <memmove+0x4a>
    80000dcc:	b7f1                	j	80000d98 <memmove+0x26>

0000000080000dce <memcpy>:
    80000dce:	1141                	addi	sp,sp,-16
    80000dd0:	e406                	sd	ra,8(sp)
    80000dd2:	e022                	sd	s0,0(sp)
    80000dd4:	0800                	addi	s0,sp,16
    80000dd6:	00000097          	auipc	ra,0x0
    80000dda:	f9c080e7          	jalr	-100(ra) # 80000d72 <memmove>
    80000dde:	60a2                	ld	ra,8(sp)
    80000de0:	6402                	ld	s0,0(sp)
    80000de2:	0141                	addi	sp,sp,16
    80000de4:	8082                	ret

0000000080000de6 <strncmp>:
    80000de6:	1141                	addi	sp,sp,-16
    80000de8:	e422                	sd	s0,8(sp)
    80000dea:	0800                	addi	s0,sp,16
    80000dec:	ce11                	beqz	a2,80000e08 <strncmp+0x22>
    80000dee:	00054783          	lbu	a5,0(a0)
    80000df2:	cf89                	beqz	a5,80000e0c <strncmp+0x26>
    80000df4:	0005c703          	lbu	a4,0(a1)
    80000df8:	00f71a63          	bne	a4,a5,80000e0c <strncmp+0x26>
    80000dfc:	367d                	addiw	a2,a2,-1
    80000dfe:	0505                	addi	a0,a0,1
    80000e00:	0585                	addi	a1,a1,1
    80000e02:	f675                	bnez	a2,80000dee <strncmp+0x8>
    80000e04:	4501                	li	a0,0
    80000e06:	a809                	j	80000e18 <strncmp+0x32>
    80000e08:	4501                	li	a0,0
    80000e0a:	a039                	j	80000e18 <strncmp+0x32>
    80000e0c:	ca09                	beqz	a2,80000e1e <strncmp+0x38>
    80000e0e:	00054503          	lbu	a0,0(a0)
    80000e12:	0005c783          	lbu	a5,0(a1)
    80000e16:	9d1d                	subw	a0,a0,a5
    80000e18:	6422                	ld	s0,8(sp)
    80000e1a:	0141                	addi	sp,sp,16
    80000e1c:	8082                	ret
    80000e1e:	4501                	li	a0,0
    80000e20:	bfe5                	j	80000e18 <strncmp+0x32>

0000000080000e22 <strncpy>:
    80000e22:	1141                	addi	sp,sp,-16
    80000e24:	e422                	sd	s0,8(sp)
    80000e26:	0800                	addi	s0,sp,16
    80000e28:	872a                	mv	a4,a0
    80000e2a:	8832                	mv	a6,a2
    80000e2c:	367d                	addiw	a2,a2,-1
    80000e2e:	01005963          	blez	a6,80000e40 <strncpy+0x1e>
    80000e32:	0705                	addi	a4,a4,1
    80000e34:	0005c783          	lbu	a5,0(a1)
    80000e38:	fef70fa3          	sb	a5,-1(a4)
    80000e3c:	0585                	addi	a1,a1,1
    80000e3e:	f7f5                	bnez	a5,80000e2a <strncpy+0x8>
    80000e40:	86ba                	mv	a3,a4
    80000e42:	00c05c63          	blez	a2,80000e5a <strncpy+0x38>
    80000e46:	0685                	addi	a3,a3,1
    80000e48:	fe068fa3          	sb	zero,-1(a3)
    80000e4c:	40d707bb          	subw	a5,a4,a3
    80000e50:	37fd                	addiw	a5,a5,-1
    80000e52:	010787bb          	addw	a5,a5,a6
    80000e56:	fef048e3          	bgtz	a5,80000e46 <strncpy+0x24>
    80000e5a:	6422                	ld	s0,8(sp)
    80000e5c:	0141                	addi	sp,sp,16
    80000e5e:	8082                	ret

0000000080000e60 <safestrcpy>:
    80000e60:	1141                	addi	sp,sp,-16
    80000e62:	e422                	sd	s0,8(sp)
    80000e64:	0800                	addi	s0,sp,16
    80000e66:	02c05363          	blez	a2,80000e8c <safestrcpy+0x2c>
    80000e6a:	fff6069b          	addiw	a3,a2,-1
    80000e6e:	1682                	slli	a3,a3,0x20
    80000e70:	9281                	srli	a3,a3,0x20
    80000e72:	96ae                	add	a3,a3,a1
    80000e74:	87aa                	mv	a5,a0
    80000e76:	00d58963          	beq	a1,a3,80000e88 <safestrcpy+0x28>
    80000e7a:	0585                	addi	a1,a1,1
    80000e7c:	0785                	addi	a5,a5,1
    80000e7e:	fff5c703          	lbu	a4,-1(a1)
    80000e82:	fee78fa3          	sb	a4,-1(a5)
    80000e86:	fb65                	bnez	a4,80000e76 <safestrcpy+0x16>
    80000e88:	00078023          	sb	zero,0(a5)
    80000e8c:	6422                	ld	s0,8(sp)
    80000e8e:	0141                	addi	sp,sp,16
    80000e90:	8082                	ret

0000000080000e92 <strlen>:
    80000e92:	1141                	addi	sp,sp,-16
    80000e94:	e422                	sd	s0,8(sp)
    80000e96:	0800                	addi	s0,sp,16
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
    80000eb2:	6422                	ld	s0,8(sp)
    80000eb4:	0141                	addi	sp,sp,16
    80000eb6:	8082                	ret
    80000eb8:	4501                	li	a0,0
    80000eba:	bfe5                	j	80000eb2 <strlen+0x20>

0000000080000ebc <main>:
    80000ebc:	1141                	addi	sp,sp,-16
    80000ebe:	e406                	sd	ra,8(sp)
    80000ec0:	e022                	sd	s0,0(sp)
    80000ec2:	0800                	addi	s0,sp,16
    80000ec4:	00001097          	auipc	ra,0x1
    80000ec8:	c00080e7          	jalr	-1024(ra) # 80001ac4 <cpuid>
    80000ecc:	00009717          	auipc	a4,0x9
    80000ed0:	14c70713          	addi	a4,a4,332 # 8000a018 <started>
    80000ed4:	c139                	beqz	a0,80000f1a <main+0x5e>
    80000ed6:	431c                	lw	a5,0(a4)
    80000ed8:	2781                	sext.w	a5,a5
    80000eda:	dff5                	beqz	a5,80000ed6 <main+0x1a>
    80000edc:	0ff0000f          	fence
    80000ee0:	00001097          	auipc	ra,0x1
    80000ee4:	be4080e7          	jalr	-1052(ra) # 80001ac4 <cpuid>
    80000ee8:	85aa                	mv	a1,a0
    80000eea:	00008517          	auipc	a0,0x8
    80000eee:	1ce50513          	addi	a0,a0,462 # 800090b8 <digits+0x78>
    80000ef2:	fffff097          	auipc	ra,0xfffff
    80000ef6:	694080e7          	jalr	1684(ra) # 80000586 <printf>
    80000efa:	00000097          	auipc	ra,0x0
    80000efe:	0d8080e7          	jalr	216(ra) # 80000fd2 <kvminithart>
    80000f02:	00002097          	auipc	ra,0x2
    80000f06:	d4c080e7          	jalr	-692(ra) # 80002c4e <trapinithart>
    80000f0a:	00006097          	auipc	ra,0x6
    80000f0e:	a46080e7          	jalr	-1466(ra) # 80006950 <plicinithart>
    80000f12:	00001097          	auipc	ra,0x1
    80000f16:	e0e080e7          	jalr	-498(ra) # 80001d20 <scheduler>
    80000f1a:	fffff097          	auipc	ra,0xfffff
    80000f1e:	532080e7          	jalr	1330(ra) # 8000044c <consoleinit>
    80000f22:	00000097          	auipc	ra,0x0
    80000f26:	844080e7          	jalr	-1980(ra) # 80000766 <printfinit>
    80000f2a:	00008517          	auipc	a0,0x8
    80000f2e:	19e50513          	addi	a0,a0,414 # 800090c8 <digits+0x88>
    80000f32:	fffff097          	auipc	ra,0xfffff
    80000f36:	654080e7          	jalr	1620(ra) # 80000586 <printf>
    80000f3a:	00008517          	auipc	a0,0x8
    80000f3e:	16650513          	addi	a0,a0,358 # 800090a0 <digits+0x60>
    80000f42:	fffff097          	auipc	ra,0xfffff
    80000f46:	644080e7          	jalr	1604(ra) # 80000586 <printf>
    80000f4a:	00008517          	auipc	a0,0x8
    80000f4e:	17e50513          	addi	a0,a0,382 # 800090c8 <digits+0x88>
    80000f52:	fffff097          	auipc	ra,0xfffff
    80000f56:	634080e7          	jalr	1588(ra) # 80000586 <printf>
    80000f5a:	00000097          	auipc	ra,0x0
    80000f5e:	b4c080e7          	jalr	-1204(ra) # 80000aa6 <kinit>
    80000f62:	00000097          	auipc	ra,0x0
    80000f66:	322080e7          	jalr	802(ra) # 80001284 <kvminit>
    80000f6a:	00000097          	auipc	ra,0x0
    80000f6e:	068080e7          	jalr	104(ra) # 80000fd2 <kvminithart>
    80000f72:	00001097          	auipc	ra,0x1
    80000f76:	aa0080e7          	jalr	-1376(ra) # 80001a12 <procinit>
    80000f7a:	00002097          	auipc	ra,0x2
    80000f7e:	cac080e7          	jalr	-852(ra) # 80002c26 <trapinit>
    80000f82:	00002097          	auipc	ra,0x2
    80000f86:	ccc080e7          	jalr	-820(ra) # 80002c4e <trapinithart>
    80000f8a:	00006097          	auipc	ra,0x6
    80000f8e:	9b0080e7          	jalr	-1616(ra) # 8000693a <plicinit>
    80000f92:	00006097          	auipc	ra,0x6
    80000f96:	9be080e7          	jalr	-1602(ra) # 80006950 <plicinithart>
    80000f9a:	00003097          	auipc	ra,0x3
    80000f9e:	802080e7          	jalr	-2046(ra) # 8000379c <binit>
    80000fa2:	00003097          	auipc	ra,0x3
    80000fa6:	e90080e7          	jalr	-368(ra) # 80003e32 <iinit>
    80000faa:	00004097          	auipc	ra,0x4
    80000fae:	e46080e7          	jalr	-442(ra) # 80004df0 <fileinit>
    80000fb2:	00006097          	auipc	ra,0x6
    80000fb6:	abe080e7          	jalr	-1346(ra) # 80006a70 <virtio_disk_init>
    80000fba:	00001097          	auipc	ra,0x1
    80000fbe:	712080e7          	jalr	1810(ra) # 800026cc <userinit>
    80000fc2:	0ff0000f          	fence
    80000fc6:	4785                	li	a5,1
    80000fc8:	00009717          	auipc	a4,0x9
    80000fcc:	04f72823          	sw	a5,80(a4) # 8000a018 <started>
    80000fd0:	b789                	j	80000f12 <main+0x56>

0000000080000fd2 <kvminithart>:
    80000fd2:	1141                	addi	sp,sp,-16
    80000fd4:	e422                	sd	s0,8(sp)
    80000fd6:	0800                	addi	s0,sp,16
    80000fd8:	00009797          	auipc	a5,0x9
    80000fdc:	0487b783          	ld	a5,72(a5) # 8000a020 <kernel_pagetable>
    80000fe0:	83b1                	srli	a5,a5,0xc
    80000fe2:	577d                	li	a4,-1
    80000fe4:	177e                	slli	a4,a4,0x3f
    80000fe6:	8fd9                	or	a5,a5,a4
    80000fe8:	18079073          	csrw	satp,a5
    80000fec:	12000073          	sfence.vma
    80000ff0:	6422                	ld	s0,8(sp)
    80000ff2:	0141                	addi	sp,sp,16
    80000ff4:	8082                	ret

0000000080000ff6 <walk>:
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
    80001010:	57fd                	li	a5,-1
    80001012:	83e9                	srli	a5,a5,0x1a
    80001014:	4a79                	li	s4,30
    80001016:	4b31                	li	s6,12
    80001018:	04b7f263          	bgeu	a5,a1,8000105c <walk+0x66>
    8000101c:	00008517          	auipc	a0,0x8
    80001020:	0b450513          	addi	a0,a0,180 # 800090d0 <digits+0x90>
    80001024:	fffff097          	auipc	ra,0xfffff
    80001028:	518080e7          	jalr	1304(ra) # 8000053c <panic>
    8000102c:	060a8663          	beqz	s5,80001098 <walk+0xa2>
    80001030:	00000097          	auipc	ra,0x0
    80001034:	ab2080e7          	jalr	-1358(ra) # 80000ae2 <kalloc>
    80001038:	84aa                	mv	s1,a0
    8000103a:	c529                	beqz	a0,80001084 <walk+0x8e>
    8000103c:	6605                	lui	a2,0x1
    8000103e:	4581                	li	a1,0
    80001040:	00000097          	auipc	ra,0x0
    80001044:	cd6080e7          	jalr	-810(ra) # 80000d16 <memset>
    80001048:	00c4d793          	srli	a5,s1,0xc
    8000104c:	07aa                	slli	a5,a5,0xa
    8000104e:	0017e793          	ori	a5,a5,1
    80001052:	00f93023          	sd	a5,0(s2)
    80001056:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffc835f>
    80001058:	036a0063          	beq	s4,s6,80001078 <walk+0x82>
    8000105c:	0149d933          	srl	s2,s3,s4
    80001060:	1ff97913          	andi	s2,s2,511
    80001064:	090e                	slli	s2,s2,0x3
    80001066:	9926                	add	s2,s2,s1
    80001068:	00093483          	ld	s1,0(s2)
    8000106c:	0014f793          	andi	a5,s1,1
    80001070:	dfd5                	beqz	a5,8000102c <walk+0x36>
    80001072:	80a9                	srli	s1,s1,0xa
    80001074:	04b2                	slli	s1,s1,0xc
    80001076:	b7c5                	j	80001056 <walk+0x60>
    80001078:	00c9d513          	srli	a0,s3,0xc
    8000107c:	1ff57513          	andi	a0,a0,511
    80001080:	050e                	slli	a0,a0,0x3
    80001082:	9526                	add	a0,a0,s1
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
    80001098:	4501                	li	a0,0
    8000109a:	b7ed                	j	80001084 <walk+0x8e>

000000008000109c <walkaddr>:
    8000109c:	57fd                	li	a5,-1
    8000109e:	83e9                	srli	a5,a5,0x1a
    800010a0:	00b7f463          	bgeu	a5,a1,800010a8 <walkaddr+0xc>
    800010a4:	4501                	li	a0,0
    800010a6:	8082                	ret
    800010a8:	1141                	addi	sp,sp,-16
    800010aa:	e406                	sd	ra,8(sp)
    800010ac:	e022                	sd	s0,0(sp)
    800010ae:	0800                	addi	s0,sp,16
    800010b0:	4601                	li	a2,0
    800010b2:	00000097          	auipc	ra,0x0
    800010b6:	f44080e7          	jalr	-188(ra) # 80000ff6 <walk>
    800010ba:	c105                	beqz	a0,800010da <walkaddr+0x3e>
    800010bc:	611c                	ld	a5,0(a0)
    800010be:	0117f693          	andi	a3,a5,17
    800010c2:	4745                	li	a4,17
    800010c4:	4501                	li	a0,0
    800010c6:	00e68663          	beq	a3,a4,800010d2 <walkaddr+0x36>
    800010ca:	60a2                	ld	ra,8(sp)
    800010cc:	6402                	ld	s0,0(sp)
    800010ce:	0141                	addi	sp,sp,16
    800010d0:	8082                	ret
    800010d2:	83a9                	srli	a5,a5,0xa
    800010d4:	00c79513          	slli	a0,a5,0xc
    800010d8:	bfcd                	j	800010ca <walkaddr+0x2e>
    800010da:	4501                	li	a0,0
    800010dc:	b7fd                	j	800010ca <walkaddr+0x2e>

00000000800010de <mappages>:
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
    800010f4:	c639                	beqz	a2,80001142 <mappages+0x64>
    800010f6:	8aaa                	mv	s5,a0
    800010f8:	8b3a                	mv	s6,a4
    800010fa:	777d                	lui	a4,0xfffff
    800010fc:	00e5f7b3          	and	a5,a1,a4
    80001100:	fff58993          	addi	s3,a1,-1
    80001104:	99b2                	add	s3,s3,a2
    80001106:	00e9f9b3          	and	s3,s3,a4
    8000110a:	893e                	mv	s2,a5
    8000110c:	40f68a33          	sub	s4,a3,a5
    80001110:	6b85                	lui	s7,0x1
    80001112:	012a04b3          	add	s1,s4,s2
    80001116:	4605                	li	a2,1
    80001118:	85ca                	mv	a1,s2
    8000111a:	8556                	mv	a0,s5
    8000111c:	00000097          	auipc	ra,0x0
    80001120:	eda080e7          	jalr	-294(ra) # 80000ff6 <walk>
    80001124:	cd1d                	beqz	a0,80001162 <mappages+0x84>
    80001126:	611c                	ld	a5,0(a0)
    80001128:	8b85                	andi	a5,a5,1
    8000112a:	e785                	bnez	a5,80001152 <mappages+0x74>
    8000112c:	80b1                	srli	s1,s1,0xc
    8000112e:	04aa                	slli	s1,s1,0xa
    80001130:	0164e4b3          	or	s1,s1,s6
    80001134:	0014e493          	ori	s1,s1,1
    80001138:	e104                	sd	s1,0(a0)
    8000113a:	05390063          	beq	s2,s3,8000117a <mappages+0x9c>
    8000113e:	995e                	add	s2,s2,s7
    80001140:	bfc9                	j	80001112 <mappages+0x34>
    80001142:	00008517          	auipc	a0,0x8
    80001146:	f9650513          	addi	a0,a0,-106 # 800090d8 <digits+0x98>
    8000114a:	fffff097          	auipc	ra,0xfffff
    8000114e:	3f2080e7          	jalr	1010(ra) # 8000053c <panic>
    80001152:	00008517          	auipc	a0,0x8
    80001156:	f9650513          	addi	a0,a0,-106 # 800090e8 <digits+0xa8>
    8000115a:	fffff097          	auipc	ra,0xfffff
    8000115e:	3e2080e7          	jalr	994(ra) # 8000053c <panic>
    80001162:	557d                	li	a0,-1
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
    8000117a:	4501                	li	a0,0
    8000117c:	b7e5                	j	80001164 <mappages+0x86>

000000008000117e <kvmmap>:
    8000117e:	1141                	addi	sp,sp,-16
    80001180:	e406                	sd	ra,8(sp)
    80001182:	e022                	sd	s0,0(sp)
    80001184:	0800                	addi	s0,sp,16
    80001186:	87b6                	mv	a5,a3
    80001188:	86b2                	mv	a3,a2
    8000118a:	863e                	mv	a2,a5
    8000118c:	00000097          	auipc	ra,0x0
    80001190:	f52080e7          	jalr	-174(ra) # 800010de <mappages>
    80001194:	e509                	bnez	a0,8000119e <kvmmap+0x20>
    80001196:	60a2                	ld	ra,8(sp)
    80001198:	6402                	ld	s0,0(sp)
    8000119a:	0141                	addi	sp,sp,16
    8000119c:	8082                	ret
    8000119e:	00008517          	auipc	a0,0x8
    800011a2:	f5a50513          	addi	a0,a0,-166 # 800090f8 <digits+0xb8>
    800011a6:	fffff097          	auipc	ra,0xfffff
    800011aa:	396080e7          	jalr	918(ra) # 8000053c <panic>

00000000800011ae <kvmmake>:
    800011ae:	1101                	addi	sp,sp,-32
    800011b0:	ec06                	sd	ra,24(sp)
    800011b2:	e822                	sd	s0,16(sp)
    800011b4:	e426                	sd	s1,8(sp)
    800011b6:	e04a                	sd	s2,0(sp)
    800011b8:	1000                	addi	s0,sp,32
    800011ba:	00000097          	auipc	ra,0x0
    800011be:	928080e7          	jalr	-1752(ra) # 80000ae2 <kalloc>
    800011c2:	84aa                	mv	s1,a0
    800011c4:	6605                	lui	a2,0x1
    800011c6:	4581                	li	a1,0
    800011c8:	00000097          	auipc	ra,0x0
    800011cc:	b4e080e7          	jalr	-1202(ra) # 80000d16 <memset>
    800011d0:	4719                	li	a4,6
    800011d2:	6685                	lui	a3,0x1
    800011d4:	10000637          	lui	a2,0x10000
    800011d8:	100005b7          	lui	a1,0x10000
    800011dc:	8526                	mv	a0,s1
    800011de:	00000097          	auipc	ra,0x0
    800011e2:	fa0080e7          	jalr	-96(ra) # 8000117e <kvmmap>
    800011e6:	4719                	li	a4,6
    800011e8:	6685                	lui	a3,0x1
    800011ea:	10001637          	lui	a2,0x10001
    800011ee:	100015b7          	lui	a1,0x10001
    800011f2:	8526                	mv	a0,s1
    800011f4:	00000097          	auipc	ra,0x0
    800011f8:	f8a080e7          	jalr	-118(ra) # 8000117e <kvmmap>
    800011fc:	4719                	li	a4,6
    800011fe:	004006b7          	lui	a3,0x400
    80001202:	0c000637          	lui	a2,0xc000
    80001206:	0c0005b7          	lui	a1,0xc000
    8000120a:	8526                	mv	a0,s1
    8000120c:	00000097          	auipc	ra,0x0
    80001210:	f72080e7          	jalr	-142(ra) # 8000117e <kvmmap>
    80001214:	00008917          	auipc	s2,0x8
    80001218:	dec90913          	addi	s2,s2,-532 # 80009000 <etext>
    8000121c:	4729                	li	a4,10
    8000121e:	80008697          	auipc	a3,0x80008
    80001222:	de268693          	addi	a3,a3,-542 # 9000 <_entry-0x7fff7000>
    80001226:	4605                	li	a2,1
    80001228:	067e                	slli	a2,a2,0x1f
    8000122a:	85b2                	mv	a1,a2
    8000122c:	8526                	mv	a0,s1
    8000122e:	00000097          	auipc	ra,0x0
    80001232:	f50080e7          	jalr	-176(ra) # 8000117e <kvmmap>
    80001236:	4719                	li	a4,6
    80001238:	46c5                	li	a3,17
    8000123a:	06ee                	slli	a3,a3,0x1b
    8000123c:	412686b3          	sub	a3,a3,s2
    80001240:	864a                	mv	a2,s2
    80001242:	85ca                	mv	a1,s2
    80001244:	8526                	mv	a0,s1
    80001246:	00000097          	auipc	ra,0x0
    8000124a:	f38080e7          	jalr	-200(ra) # 8000117e <kvmmap>
    8000124e:	4729                	li	a4,10
    80001250:	6685                	lui	a3,0x1
    80001252:	00007617          	auipc	a2,0x7
    80001256:	dae60613          	addi	a2,a2,-594 # 80008000 <_trampoline>
    8000125a:	040005b7          	lui	a1,0x4000
    8000125e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001260:	05b2                	slli	a1,a1,0xc
    80001262:	8526                	mv	a0,s1
    80001264:	00000097          	auipc	ra,0x0
    80001268:	f1a080e7          	jalr	-230(ra) # 8000117e <kvmmap>
    8000126c:	8526                	mv	a0,s1
    8000126e:	00000097          	auipc	ra,0x0
    80001272:	70e080e7          	jalr	1806(ra) # 8000197c <proc_mapstacks>
    80001276:	8526                	mv	a0,s1
    80001278:	60e2                	ld	ra,24(sp)
    8000127a:	6442                	ld	s0,16(sp)
    8000127c:	64a2                	ld	s1,8(sp)
    8000127e:	6902                	ld	s2,0(sp)
    80001280:	6105                	addi	sp,sp,32
    80001282:	8082                	ret

0000000080001284 <kvminit>:
    80001284:	1141                	addi	sp,sp,-16
    80001286:	e406                	sd	ra,8(sp)
    80001288:	e022                	sd	s0,0(sp)
    8000128a:	0800                	addi	s0,sp,16
    8000128c:	00000097          	auipc	ra,0x0
    80001290:	f22080e7          	jalr	-222(ra) # 800011ae <kvmmake>
    80001294:	00009797          	auipc	a5,0x9
    80001298:	d8a7b623          	sd	a0,-628(a5) # 8000a020 <kernel_pagetable>
    8000129c:	60a2                	ld	ra,8(sp)
    8000129e:	6402                	ld	s0,0(sp)
    800012a0:	0141                	addi	sp,sp,16
    800012a2:	8082                	ret

00000000800012a4 <uvmunmap>:
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
    800012ba:	03459793          	slli	a5,a1,0x34
    800012be:	e795                	bnez	a5,800012ea <uvmunmap+0x46>
    800012c0:	8a2a                	mv	s4,a0
    800012c2:	892e                	mv	s2,a1
    800012c4:	8b36                	mv	s6,a3
    800012c6:	0632                	slli	a2,a2,0xc
    800012c8:	00b609b3          	add	s3,a2,a1
    800012cc:	4b85                	li	s7,1
    800012ce:	6a85                	lui	s5,0x1
    800012d0:	0535ea63          	bltu	a1,s3,80001324 <uvmunmap+0x80>
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
    800012ea:	00008517          	auipc	a0,0x8
    800012ee:	e1650513          	addi	a0,a0,-490 # 80009100 <digits+0xc0>
    800012f2:	fffff097          	auipc	ra,0xfffff
    800012f6:	24a080e7          	jalr	586(ra) # 8000053c <panic>
    800012fa:	00008517          	auipc	a0,0x8
    800012fe:	e1e50513          	addi	a0,a0,-482 # 80009118 <digits+0xd8>
    80001302:	fffff097          	auipc	ra,0xfffff
    80001306:	23a080e7          	jalr	570(ra) # 8000053c <panic>
    8000130a:	00008517          	auipc	a0,0x8
    8000130e:	e1e50513          	addi	a0,a0,-482 # 80009128 <digits+0xe8>
    80001312:	fffff097          	auipc	ra,0xfffff
    80001316:	22a080e7          	jalr	554(ra) # 8000053c <panic>
    8000131a:	0004b023          	sd	zero,0(s1)
    8000131e:	9956                	add	s2,s2,s5
    80001320:	fb397ae3          	bgeu	s2,s3,800012d4 <uvmunmap+0x30>
    80001324:	4601                	li	a2,0
    80001326:	85ca                	mv	a1,s2
    80001328:	8552                	mv	a0,s4
    8000132a:	00000097          	auipc	ra,0x0
    8000132e:	ccc080e7          	jalr	-820(ra) # 80000ff6 <walk>
    80001332:	84aa                	mv	s1,a0
    80001334:	d179                	beqz	a0,800012fa <uvmunmap+0x56>
    80001336:	611c                	ld	a5,0(a0)
    80001338:	0017f713          	andi	a4,a5,1
    8000133c:	d36d                	beqz	a4,8000131e <uvmunmap+0x7a>
    8000133e:	3ff7f713          	andi	a4,a5,1023
    80001342:	fd7704e3          	beq	a4,s7,8000130a <uvmunmap+0x66>
    80001346:	fc0b0ae3          	beqz	s6,8000131a <uvmunmap+0x76>
    8000134a:	83a9                	srli	a5,a5,0xa
    8000134c:	00c79513          	slli	a0,a5,0xc
    80001350:	fffff097          	auipc	ra,0xfffff
    80001354:	694080e7          	jalr	1684(ra) # 800009e4 <kfree>
    80001358:	b7c9                	j	8000131a <uvmunmap+0x76>

000000008000135a <uvmcreate>:
    8000135a:	1101                	addi	sp,sp,-32
    8000135c:	ec06                	sd	ra,24(sp)
    8000135e:	e822                	sd	s0,16(sp)
    80001360:	e426                	sd	s1,8(sp)
    80001362:	1000                	addi	s0,sp,32
    80001364:	fffff097          	auipc	ra,0xfffff
    80001368:	77e080e7          	jalr	1918(ra) # 80000ae2 <kalloc>
    8000136c:	84aa                	mv	s1,a0
    8000136e:	c519                	beqz	a0,8000137c <uvmcreate+0x22>
    80001370:	6605                	lui	a2,0x1
    80001372:	4581                	li	a1,0
    80001374:	00000097          	auipc	ra,0x0
    80001378:	9a2080e7          	jalr	-1630(ra) # 80000d16 <memset>
    8000137c:	8526                	mv	a0,s1
    8000137e:	60e2                	ld	ra,24(sp)
    80001380:	6442                	ld	s0,16(sp)
    80001382:	64a2                	ld	s1,8(sp)
    80001384:	6105                	addi	sp,sp,32
    80001386:	8082                	ret

0000000080001388 <uvminit>:
    80001388:	7179                	addi	sp,sp,-48
    8000138a:	f406                	sd	ra,40(sp)
    8000138c:	f022                	sd	s0,32(sp)
    8000138e:	ec26                	sd	s1,24(sp)
    80001390:	e84a                	sd	s2,16(sp)
    80001392:	e44e                	sd	s3,8(sp)
    80001394:	e052                	sd	s4,0(sp)
    80001396:	1800                	addi	s0,sp,48
    80001398:	6785                	lui	a5,0x1
    8000139a:	04f67863          	bgeu	a2,a5,800013ea <uvminit+0x62>
    8000139e:	8a2a                	mv	s4,a0
    800013a0:	89ae                	mv	s3,a1
    800013a2:	84b2                	mv	s1,a2
    800013a4:	fffff097          	auipc	ra,0xfffff
    800013a8:	73e080e7          	jalr	1854(ra) # 80000ae2 <kalloc>
    800013ac:	892a                	mv	s2,a0
    800013ae:	6605                	lui	a2,0x1
    800013b0:	4581                	li	a1,0
    800013b2:	00000097          	auipc	ra,0x0
    800013b6:	964080e7          	jalr	-1692(ra) # 80000d16 <memset>
    800013ba:	4779                	li	a4,30
    800013bc:	86ca                	mv	a3,s2
    800013be:	6605                	lui	a2,0x1
    800013c0:	4581                	li	a1,0
    800013c2:	8552                	mv	a0,s4
    800013c4:	00000097          	auipc	ra,0x0
    800013c8:	d1a080e7          	jalr	-742(ra) # 800010de <mappages>
    800013cc:	8626                	mv	a2,s1
    800013ce:	85ce                	mv	a1,s3
    800013d0:	854a                	mv	a0,s2
    800013d2:	00000097          	auipc	ra,0x0
    800013d6:	9a0080e7          	jalr	-1632(ra) # 80000d72 <memmove>
    800013da:	70a2                	ld	ra,40(sp)
    800013dc:	7402                	ld	s0,32(sp)
    800013de:	64e2                	ld	s1,24(sp)
    800013e0:	6942                	ld	s2,16(sp)
    800013e2:	69a2                	ld	s3,8(sp)
    800013e4:	6a02                	ld	s4,0(sp)
    800013e6:	6145                	addi	sp,sp,48
    800013e8:	8082                	ret
    800013ea:	00008517          	auipc	a0,0x8
    800013ee:	d5650513          	addi	a0,a0,-682 # 80009140 <digits+0x100>
    800013f2:	fffff097          	auipc	ra,0xfffff
    800013f6:	14a080e7          	jalr	330(ra) # 8000053c <panic>

00000000800013fa <uvmdealloc>:
    800013fa:	1101                	addi	sp,sp,-32
    800013fc:	ec06                	sd	ra,24(sp)
    800013fe:	e822                	sd	s0,16(sp)
    80001400:	e426                	sd	s1,8(sp)
    80001402:	1000                	addi	s0,sp,32
    80001404:	84ae                	mv	s1,a1
    80001406:	00b67d63          	bgeu	a2,a1,80001420 <uvmdealloc+0x26>
    8000140a:	84b2                	mv	s1,a2
    8000140c:	6785                	lui	a5,0x1
    8000140e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001410:	00f60733          	add	a4,a2,a5
    80001414:	76fd                	lui	a3,0xfffff
    80001416:	8f75                	and	a4,a4,a3
    80001418:	97ae                	add	a5,a5,a1
    8000141a:	8ff5                	and	a5,a5,a3
    8000141c:	00f76863          	bltu	a4,a5,8000142c <uvmdealloc+0x32>
    80001420:	8526                	mv	a0,s1
    80001422:	60e2                	ld	ra,24(sp)
    80001424:	6442                	ld	s0,16(sp)
    80001426:	64a2                	ld	s1,8(sp)
    80001428:	6105                	addi	sp,sp,32
    8000142a:	8082                	ret
    8000142c:	8f99                	sub	a5,a5,a4
    8000142e:	83b1                	srli	a5,a5,0xc
    80001430:	4685                	li	a3,1
    80001432:	0007861b          	sext.w	a2,a5
    80001436:	85ba                	mv	a1,a4
    80001438:	00000097          	auipc	ra,0x0
    8000143c:	e6c080e7          	jalr	-404(ra) # 800012a4 <uvmunmap>
    80001440:	b7c5                	j	80001420 <uvmdealloc+0x26>

0000000080001442 <uvmalloc>:
    80001442:	0ab66163          	bltu	a2,a1,800014e4 <uvmalloc+0xa2>
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
    8000145c:	6785                	lui	a5,0x1
    8000145e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001460:	95be                	add	a1,a1,a5
    80001462:	77fd                	lui	a5,0xfffff
    80001464:	00f5f9b3          	and	s3,a1,a5
    80001468:	08c9f063          	bgeu	s3,a2,800014e8 <uvmalloc+0xa6>
    8000146c:	894e                	mv	s2,s3
    8000146e:	fffff097          	auipc	ra,0xfffff
    80001472:	674080e7          	jalr	1652(ra) # 80000ae2 <kalloc>
    80001476:	84aa                	mv	s1,a0
    80001478:	c51d                	beqz	a0,800014a6 <uvmalloc+0x64>
    8000147a:	6605                	lui	a2,0x1
    8000147c:	4581                	li	a1,0
    8000147e:	00000097          	auipc	ra,0x0
    80001482:	898080e7          	jalr	-1896(ra) # 80000d16 <memset>
    80001486:	4779                	li	a4,30
    80001488:	86a6                	mv	a3,s1
    8000148a:	6605                	lui	a2,0x1
    8000148c:	85ca                	mv	a1,s2
    8000148e:	8556                	mv	a0,s5
    80001490:	00000097          	auipc	ra,0x0
    80001494:	c4e080e7          	jalr	-946(ra) # 800010de <mappages>
    80001498:	e905                	bnez	a0,800014c8 <uvmalloc+0x86>
    8000149a:	6785                	lui	a5,0x1
    8000149c:	993e                	add	s2,s2,a5
    8000149e:	fd4968e3          	bltu	s2,s4,8000146e <uvmalloc+0x2c>
    800014a2:	8552                	mv	a0,s4
    800014a4:	a809                	j	800014b6 <uvmalloc+0x74>
    800014a6:	864e                	mv	a2,s3
    800014a8:	85ca                	mv	a1,s2
    800014aa:	8556                	mv	a0,s5
    800014ac:	00000097          	auipc	ra,0x0
    800014b0:	f4e080e7          	jalr	-178(ra) # 800013fa <uvmdealloc>
    800014b4:	4501                	li	a0,0
    800014b6:	70e2                	ld	ra,56(sp)
    800014b8:	7442                	ld	s0,48(sp)
    800014ba:	74a2                	ld	s1,40(sp)
    800014bc:	7902                	ld	s2,32(sp)
    800014be:	69e2                	ld	s3,24(sp)
    800014c0:	6a42                	ld	s4,16(sp)
    800014c2:	6aa2                	ld	s5,8(sp)
    800014c4:	6121                	addi	sp,sp,64
    800014c6:	8082                	ret
    800014c8:	8526                	mv	a0,s1
    800014ca:	fffff097          	auipc	ra,0xfffff
    800014ce:	51a080e7          	jalr	1306(ra) # 800009e4 <kfree>
    800014d2:	864e                	mv	a2,s3
    800014d4:	85ca                	mv	a1,s2
    800014d6:	8556                	mv	a0,s5
    800014d8:	00000097          	auipc	ra,0x0
    800014dc:	f22080e7          	jalr	-222(ra) # 800013fa <uvmdealloc>
    800014e0:	4501                	li	a0,0
    800014e2:	bfd1                	j	800014b6 <uvmalloc+0x74>
    800014e4:	852e                	mv	a0,a1
    800014e6:	8082                	ret
    800014e8:	8532                	mv	a0,a2
    800014ea:	b7f1                	j	800014b6 <uvmalloc+0x74>

00000000800014ec <freewalk>:
    800014ec:	7179                	addi	sp,sp,-48
    800014ee:	f406                	sd	ra,40(sp)
    800014f0:	f022                	sd	s0,32(sp)
    800014f2:	ec26                	sd	s1,24(sp)
    800014f4:	e84a                	sd	s2,16(sp)
    800014f6:	e44e                	sd	s3,8(sp)
    800014f8:	e052                	sd	s4,0(sp)
    800014fa:	1800                	addi	s0,sp,48
    800014fc:	8a2a                	mv	s4,a0
    800014fe:	84aa                	mv	s1,a0
    80001500:	6905                	lui	s2,0x1
    80001502:	992a                	add	s2,s2,a0
    80001504:	4985                	li	s3,1
    80001506:	a829                	j	80001520 <freewalk+0x34>
    80001508:	83a9                	srli	a5,a5,0xa
    8000150a:	00c79513          	slli	a0,a5,0xc
    8000150e:	00000097          	auipc	ra,0x0
    80001512:	fde080e7          	jalr	-34(ra) # 800014ec <freewalk>
    80001516:	0004b023          	sd	zero,0(s1)
    8000151a:	04a1                	addi	s1,s1,8
    8000151c:	03248163          	beq	s1,s2,8000153e <freewalk+0x52>
    80001520:	609c                	ld	a5,0(s1)
    80001522:	00f7f713          	andi	a4,a5,15
    80001526:	ff3701e3          	beq	a4,s3,80001508 <freewalk+0x1c>
    8000152a:	8b85                	andi	a5,a5,1
    8000152c:	d7fd                	beqz	a5,8000151a <freewalk+0x2e>
    8000152e:	00008517          	auipc	a0,0x8
    80001532:	c3250513          	addi	a0,a0,-974 # 80009160 <digits+0x120>
    80001536:	fffff097          	auipc	ra,0xfffff
    8000153a:	006080e7          	jalr	6(ra) # 8000053c <panic>
    8000153e:	8552                	mv	a0,s4
    80001540:	fffff097          	auipc	ra,0xfffff
    80001544:	4a4080e7          	jalr	1188(ra) # 800009e4 <kfree>
    80001548:	70a2                	ld	ra,40(sp)
    8000154a:	7402                	ld	s0,32(sp)
    8000154c:	64e2                	ld	s1,24(sp)
    8000154e:	6942                	ld	s2,16(sp)
    80001550:	69a2                	ld	s3,8(sp)
    80001552:	6a02                	ld	s4,0(sp)
    80001554:	6145                	addi	sp,sp,48
    80001556:	8082                	ret

0000000080001558 <uvmfree>:
    80001558:	1101                	addi	sp,sp,-32
    8000155a:	ec06                	sd	ra,24(sp)
    8000155c:	e822                	sd	s0,16(sp)
    8000155e:	e426                	sd	s1,8(sp)
    80001560:	1000                	addi	s0,sp,32
    80001562:	84aa                	mv	s1,a0
    80001564:	e999                	bnez	a1,8000157a <uvmfree+0x22>
    80001566:	8526                	mv	a0,s1
    80001568:	00000097          	auipc	ra,0x0
    8000156c:	f84080e7          	jalr	-124(ra) # 800014ec <freewalk>
    80001570:	60e2                	ld	ra,24(sp)
    80001572:	6442                	ld	s0,16(sp)
    80001574:	64a2                	ld	s1,8(sp)
    80001576:	6105                	addi	sp,sp,32
    80001578:	8082                	ret
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
    80001592:	715d                	addi	sp,sp,-80
    80001594:	e486                	sd	ra,72(sp)
    80001596:	e0a2                	sd	s0,64(sp)
    80001598:	fc26                	sd	s1,56(sp)
    8000159a:	f84a                	sd	s2,48(sp)
    8000159c:	f44e                	sd	s3,40(sp)
    8000159e:	f052                	sd	s4,32(sp)
    800015a0:	ec56                	sd	s5,24(sp)
    800015a2:	e85a                	sd	s6,16(sp)
    800015a4:	e45e                	sd	s7,8(sp)
    800015a6:	0880                	addi	s0,sp,80
    800015a8:	8b2a                	mv	s6,a0
    800015aa:	8aae                	mv	s5,a1
    800015ac:	89b2                	mv	s3,a2
    800015ae:	8a36                	mv	s4,a3
    800015b0:	0ad67963          	bgeu	a2,a3,80001662 <uvmcopy+0xd0>
    800015b4:	4601                	li	a2,0
    800015b6:	85ce                	mv	a1,s3
    800015b8:	855a                	mv	a0,s6
    800015ba:	00000097          	auipc	ra,0x0
    800015be:	a3c080e7          	jalr	-1476(ra) # 80000ff6 <walk>
    800015c2:	c531                	beqz	a0,8000160e <uvmcopy+0x7c>
    800015c4:	6118                	ld	a4,0(a0)
    800015c6:	00177793          	andi	a5,a4,1
    800015ca:	cbb1                	beqz	a5,8000161e <uvmcopy+0x8c>
    800015cc:	00a75593          	srli	a1,a4,0xa
    800015d0:	00c59b93          	slli	s7,a1,0xc
    800015d4:	3ff77493          	andi	s1,a4,1023
    800015d8:	fffff097          	auipc	ra,0xfffff
    800015dc:	50a080e7          	jalr	1290(ra) # 80000ae2 <kalloc>
    800015e0:	892a                	mv	s2,a0
    800015e2:	c939                	beqz	a0,80001638 <uvmcopy+0xa6>
    800015e4:	6605                	lui	a2,0x1
    800015e6:	85de                	mv	a1,s7
    800015e8:	fffff097          	auipc	ra,0xfffff
    800015ec:	78a080e7          	jalr	1930(ra) # 80000d72 <memmove>
    800015f0:	8726                	mv	a4,s1
    800015f2:	86ca                	mv	a3,s2
    800015f4:	6605                	lui	a2,0x1
    800015f6:	85ce                	mv	a1,s3
    800015f8:	8556                	mv	a0,s5
    800015fa:	00000097          	auipc	ra,0x0
    800015fe:	ae4080e7          	jalr	-1308(ra) # 800010de <mappages>
    80001602:	e515                	bnez	a0,8000162e <uvmcopy+0x9c>
    80001604:	6785                	lui	a5,0x1
    80001606:	99be                	add	s3,s3,a5
    80001608:	fb49e6e3          	bltu	s3,s4,800015b4 <uvmcopy+0x22>
    8000160c:	a081                	j	8000164c <uvmcopy+0xba>
    8000160e:	00008517          	auipc	a0,0x8
    80001612:	b6250513          	addi	a0,a0,-1182 # 80009170 <digits+0x130>
    80001616:	fffff097          	auipc	ra,0xfffff
    8000161a:	f26080e7          	jalr	-218(ra) # 8000053c <panic>
    8000161e:	00008517          	auipc	a0,0x8
    80001622:	b7250513          	addi	a0,a0,-1166 # 80009190 <digits+0x150>
    80001626:	fffff097          	auipc	ra,0xfffff
    8000162a:	f16080e7          	jalr	-234(ra) # 8000053c <panic>
    8000162e:	854a                	mv	a0,s2
    80001630:	fffff097          	auipc	ra,0xfffff
    80001634:	3b4080e7          	jalr	948(ra) # 800009e4 <kfree>
    80001638:	4685                	li	a3,1
    8000163a:	00c9d613          	srli	a2,s3,0xc
    8000163e:	4581                	li	a1,0
    80001640:	8556                	mv	a0,s5
    80001642:	00000097          	auipc	ra,0x0
    80001646:	c62080e7          	jalr	-926(ra) # 800012a4 <uvmunmap>
    8000164a:	557d                	li	a0,-1
    8000164c:	60a6                	ld	ra,72(sp)
    8000164e:	6406                	ld	s0,64(sp)
    80001650:	74e2                	ld	s1,56(sp)
    80001652:	7942                	ld	s2,48(sp)
    80001654:	79a2                	ld	s3,40(sp)
    80001656:	7a02                	ld	s4,32(sp)
    80001658:	6ae2                	ld	s5,24(sp)
    8000165a:	6b42                	ld	s6,16(sp)
    8000165c:	6ba2                	ld	s7,8(sp)
    8000165e:	6161                	addi	sp,sp,80
    80001660:	8082                	ret
    80001662:	4501                	li	a0,0
    80001664:	b7e5                	j	8000164c <uvmcopy+0xba>

0000000080001666 <uvmcopyshared>:
    80001666:	7179                	addi	sp,sp,-48
    80001668:	f406                	sd	ra,40(sp)
    8000166a:	f022                	sd	s0,32(sp)
    8000166c:	ec26                	sd	s1,24(sp)
    8000166e:	e84a                	sd	s2,16(sp)
    80001670:	e44e                	sd	s3,8(sp)
    80001672:	e052                	sd	s4,0(sp)
    80001674:	1800                	addi	s0,sp,48
    80001676:	8a2a                	mv	s4,a0
    80001678:	89ae                	mv	s3,a1
    8000167a:	84b2                	mv	s1,a2
    8000167c:	8936                	mv	s2,a3
    8000167e:	08d67263          	bgeu	a2,a3,80001702 <uvmcopyshared+0x9c>
    80001682:	4601                	li	a2,0
    80001684:	85a6                	mv	a1,s1
    80001686:	8552                	mv	a0,s4
    80001688:	00000097          	auipc	ra,0x0
    8000168c:	96e080e7          	jalr	-1682(ra) # 80000ff6 <walk>
    80001690:	c51d                	beqz	a0,800016be <uvmcopyshared+0x58>
    80001692:	6118                	ld	a4,0(a0)
    80001694:	00177793          	andi	a5,a4,1
    80001698:	cb9d                	beqz	a5,800016ce <uvmcopyshared+0x68>
    8000169a:	00a75693          	srli	a3,a4,0xa
    8000169e:	3ff77713          	andi	a4,a4,1023
    800016a2:	06b2                	slli	a3,a3,0xc
    800016a4:	6605                	lui	a2,0x1
    800016a6:	85a6                	mv	a1,s1
    800016a8:	854e                	mv	a0,s3
    800016aa:	00000097          	auipc	ra,0x0
    800016ae:	a34080e7          	jalr	-1484(ra) # 800010de <mappages>
    800016b2:	e515                	bnez	a0,800016de <uvmcopyshared+0x78>
    800016b4:	6785                	lui	a5,0x1
    800016b6:	94be                	add	s1,s1,a5
    800016b8:	fd24e5e3          	bltu	s1,s2,80001682 <uvmcopyshared+0x1c>
    800016bc:	a81d                	j	800016f2 <uvmcopyshared+0x8c>
    800016be:	00008517          	auipc	a0,0x8
    800016c2:	ab250513          	addi	a0,a0,-1358 # 80009170 <digits+0x130>
    800016c6:	fffff097          	auipc	ra,0xfffff
    800016ca:	e76080e7          	jalr	-394(ra) # 8000053c <panic>
    800016ce:	00008517          	auipc	a0,0x8
    800016d2:	ac250513          	addi	a0,a0,-1342 # 80009190 <digits+0x150>
    800016d6:	fffff097          	auipc	ra,0xfffff
    800016da:	e66080e7          	jalr	-410(ra) # 8000053c <panic>
    800016de:	4685                	li	a3,1
    800016e0:	00c4d613          	srli	a2,s1,0xc
    800016e4:	4581                	li	a1,0
    800016e6:	854e                	mv	a0,s3
    800016e8:	00000097          	auipc	ra,0x0
    800016ec:	bbc080e7          	jalr	-1092(ra) # 800012a4 <uvmunmap>
    800016f0:	557d                	li	a0,-1
    800016f2:	70a2                	ld	ra,40(sp)
    800016f4:	7402                	ld	s0,32(sp)
    800016f6:	64e2                	ld	s1,24(sp)
    800016f8:	6942                	ld	s2,16(sp)
    800016fa:	69a2                	ld	s3,8(sp)
    800016fc:	6a02                	ld	s4,0(sp)
    800016fe:	6145                	addi	sp,sp,48
    80001700:	8082                	ret
    80001702:	4501                	li	a0,0
    80001704:	b7fd                	j	800016f2 <uvmcopyshared+0x8c>

0000000080001706 <uvmclear>:
    80001706:	1141                	addi	sp,sp,-16
    80001708:	e406                	sd	ra,8(sp)
    8000170a:	e022                	sd	s0,0(sp)
    8000170c:	0800                	addi	s0,sp,16
    8000170e:	4601                	li	a2,0
    80001710:	00000097          	auipc	ra,0x0
    80001714:	8e6080e7          	jalr	-1818(ra) # 80000ff6 <walk>
    80001718:	c901                	beqz	a0,80001728 <uvmclear+0x22>
    8000171a:	611c                	ld	a5,0(a0)
    8000171c:	9bbd                	andi	a5,a5,-17
    8000171e:	e11c                	sd	a5,0(a0)
    80001720:	60a2                	ld	ra,8(sp)
    80001722:	6402                	ld	s0,0(sp)
    80001724:	0141                	addi	sp,sp,16
    80001726:	8082                	ret
    80001728:	00008517          	auipc	a0,0x8
    8000172c:	a8850513          	addi	a0,a0,-1400 # 800091b0 <digits+0x170>
    80001730:	fffff097          	auipc	ra,0xfffff
    80001734:	e0c080e7          	jalr	-500(ra) # 8000053c <panic>

0000000080001738 <copyout>:
    80001738:	c6bd                	beqz	a3,800017a6 <copyout+0x6e>
    8000173a:	715d                	addi	sp,sp,-80
    8000173c:	e486                	sd	ra,72(sp)
    8000173e:	e0a2                	sd	s0,64(sp)
    80001740:	fc26                	sd	s1,56(sp)
    80001742:	f84a                	sd	s2,48(sp)
    80001744:	f44e                	sd	s3,40(sp)
    80001746:	f052                	sd	s4,32(sp)
    80001748:	ec56                	sd	s5,24(sp)
    8000174a:	e85a                	sd	s6,16(sp)
    8000174c:	e45e                	sd	s7,8(sp)
    8000174e:	e062                	sd	s8,0(sp)
    80001750:	0880                	addi	s0,sp,80
    80001752:	8b2a                	mv	s6,a0
    80001754:	8c2e                	mv	s8,a1
    80001756:	8a32                	mv	s4,a2
    80001758:	89b6                	mv	s3,a3
    8000175a:	7bfd                	lui	s7,0xfffff
    8000175c:	6a85                	lui	s5,0x1
    8000175e:	a015                	j	80001782 <copyout+0x4a>
    80001760:	9562                	add	a0,a0,s8
    80001762:	0004861b          	sext.w	a2,s1
    80001766:	85d2                	mv	a1,s4
    80001768:	41250533          	sub	a0,a0,s2
    8000176c:	fffff097          	auipc	ra,0xfffff
    80001770:	606080e7          	jalr	1542(ra) # 80000d72 <memmove>
    80001774:	409989b3          	sub	s3,s3,s1
    80001778:	9a26                	add	s4,s4,s1
    8000177a:	01590c33          	add	s8,s2,s5
    8000177e:	02098263          	beqz	s3,800017a2 <copyout+0x6a>
    80001782:	017c7933          	and	s2,s8,s7
    80001786:	85ca                	mv	a1,s2
    80001788:	855a                	mv	a0,s6
    8000178a:	00000097          	auipc	ra,0x0
    8000178e:	912080e7          	jalr	-1774(ra) # 8000109c <walkaddr>
    80001792:	cd01                	beqz	a0,800017aa <copyout+0x72>
    80001794:	418904b3          	sub	s1,s2,s8
    80001798:	94d6                	add	s1,s1,s5
    8000179a:	fc99f3e3          	bgeu	s3,s1,80001760 <copyout+0x28>
    8000179e:	84ce                	mv	s1,s3
    800017a0:	b7c1                	j	80001760 <copyout+0x28>
    800017a2:	4501                	li	a0,0
    800017a4:	a021                	j	800017ac <copyout+0x74>
    800017a6:	4501                	li	a0,0
    800017a8:	8082                	ret
    800017aa:	557d                	li	a0,-1
    800017ac:	60a6                	ld	ra,72(sp)
    800017ae:	6406                	ld	s0,64(sp)
    800017b0:	74e2                	ld	s1,56(sp)
    800017b2:	7942                	ld	s2,48(sp)
    800017b4:	79a2                	ld	s3,40(sp)
    800017b6:	7a02                	ld	s4,32(sp)
    800017b8:	6ae2                	ld	s5,24(sp)
    800017ba:	6b42                	ld	s6,16(sp)
    800017bc:	6ba2                	ld	s7,8(sp)
    800017be:	6c02                	ld	s8,0(sp)
    800017c0:	6161                	addi	sp,sp,80
    800017c2:	8082                	ret

00000000800017c4 <copyin>:
    800017c4:	caa5                	beqz	a3,80001834 <copyin+0x70>
    800017c6:	715d                	addi	sp,sp,-80
    800017c8:	e486                	sd	ra,72(sp)
    800017ca:	e0a2                	sd	s0,64(sp)
    800017cc:	fc26                	sd	s1,56(sp)
    800017ce:	f84a                	sd	s2,48(sp)
    800017d0:	f44e                	sd	s3,40(sp)
    800017d2:	f052                	sd	s4,32(sp)
    800017d4:	ec56                	sd	s5,24(sp)
    800017d6:	e85a                	sd	s6,16(sp)
    800017d8:	e45e                	sd	s7,8(sp)
    800017da:	e062                	sd	s8,0(sp)
    800017dc:	0880                	addi	s0,sp,80
    800017de:	8b2a                	mv	s6,a0
    800017e0:	8a2e                	mv	s4,a1
    800017e2:	8c32                	mv	s8,a2
    800017e4:	89b6                	mv	s3,a3
    800017e6:	7bfd                	lui	s7,0xfffff
    800017e8:	6a85                	lui	s5,0x1
    800017ea:	a01d                	j	80001810 <copyin+0x4c>
    800017ec:	018505b3          	add	a1,a0,s8
    800017f0:	0004861b          	sext.w	a2,s1
    800017f4:	412585b3          	sub	a1,a1,s2
    800017f8:	8552                	mv	a0,s4
    800017fa:	fffff097          	auipc	ra,0xfffff
    800017fe:	578080e7          	jalr	1400(ra) # 80000d72 <memmove>
    80001802:	409989b3          	sub	s3,s3,s1
    80001806:	9a26                	add	s4,s4,s1
    80001808:	01590c33          	add	s8,s2,s5
    8000180c:	02098263          	beqz	s3,80001830 <copyin+0x6c>
    80001810:	017c7933          	and	s2,s8,s7
    80001814:	85ca                	mv	a1,s2
    80001816:	855a                	mv	a0,s6
    80001818:	00000097          	auipc	ra,0x0
    8000181c:	884080e7          	jalr	-1916(ra) # 8000109c <walkaddr>
    80001820:	cd01                	beqz	a0,80001838 <copyin+0x74>
    80001822:	418904b3          	sub	s1,s2,s8
    80001826:	94d6                	add	s1,s1,s5
    80001828:	fc99f2e3          	bgeu	s3,s1,800017ec <copyin+0x28>
    8000182c:	84ce                	mv	s1,s3
    8000182e:	bf7d                	j	800017ec <copyin+0x28>
    80001830:	4501                	li	a0,0
    80001832:	a021                	j	8000183a <copyin+0x76>
    80001834:	4501                	li	a0,0
    80001836:	8082                	ret
    80001838:	557d                	li	a0,-1
    8000183a:	60a6                	ld	ra,72(sp)
    8000183c:	6406                	ld	s0,64(sp)
    8000183e:	74e2                	ld	s1,56(sp)
    80001840:	7942                	ld	s2,48(sp)
    80001842:	79a2                	ld	s3,40(sp)
    80001844:	7a02                	ld	s4,32(sp)
    80001846:	6ae2                	ld	s5,24(sp)
    80001848:	6b42                	ld	s6,16(sp)
    8000184a:	6ba2                	ld	s7,8(sp)
    8000184c:	6c02                	ld	s8,0(sp)
    8000184e:	6161                	addi	sp,sp,80
    80001850:	8082                	ret

0000000080001852 <copyinstr>:
    80001852:	c2dd                	beqz	a3,800018f8 <copyinstr+0xa6>
    80001854:	715d                	addi	sp,sp,-80
    80001856:	e486                	sd	ra,72(sp)
    80001858:	e0a2                	sd	s0,64(sp)
    8000185a:	fc26                	sd	s1,56(sp)
    8000185c:	f84a                	sd	s2,48(sp)
    8000185e:	f44e                	sd	s3,40(sp)
    80001860:	f052                	sd	s4,32(sp)
    80001862:	ec56                	sd	s5,24(sp)
    80001864:	e85a                	sd	s6,16(sp)
    80001866:	e45e                	sd	s7,8(sp)
    80001868:	0880                	addi	s0,sp,80
    8000186a:	8a2a                	mv	s4,a0
    8000186c:	8b2e                	mv	s6,a1
    8000186e:	8bb2                	mv	s7,a2
    80001870:	84b6                	mv	s1,a3
    80001872:	7afd                	lui	s5,0xfffff
    80001874:	6985                	lui	s3,0x1
    80001876:	a02d                	j	800018a0 <copyinstr+0x4e>
    80001878:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000187c:	4785                	li	a5,1
    8000187e:	37fd                	addiw	a5,a5,-1
    80001880:	0007851b          	sext.w	a0,a5
    80001884:	60a6                	ld	ra,72(sp)
    80001886:	6406                	ld	s0,64(sp)
    80001888:	74e2                	ld	s1,56(sp)
    8000188a:	7942                	ld	s2,48(sp)
    8000188c:	79a2                	ld	s3,40(sp)
    8000188e:	7a02                	ld	s4,32(sp)
    80001890:	6ae2                	ld	s5,24(sp)
    80001892:	6b42                	ld	s6,16(sp)
    80001894:	6ba2                	ld	s7,8(sp)
    80001896:	6161                	addi	sp,sp,80
    80001898:	8082                	ret
    8000189a:	01390bb3          	add	s7,s2,s3
    8000189e:	c8a9                	beqz	s1,800018f0 <copyinstr+0x9e>
    800018a0:	015bf933          	and	s2,s7,s5
    800018a4:	85ca                	mv	a1,s2
    800018a6:	8552                	mv	a0,s4
    800018a8:	fffff097          	auipc	ra,0xfffff
    800018ac:	7f4080e7          	jalr	2036(ra) # 8000109c <walkaddr>
    800018b0:	c131                	beqz	a0,800018f4 <copyinstr+0xa2>
    800018b2:	417906b3          	sub	a3,s2,s7
    800018b6:	96ce                	add	a3,a3,s3
    800018b8:	00d4f363          	bgeu	s1,a3,800018be <copyinstr+0x6c>
    800018bc:	86a6                	mv	a3,s1
    800018be:	955e                	add	a0,a0,s7
    800018c0:	41250533          	sub	a0,a0,s2
    800018c4:	daf9                	beqz	a3,8000189a <copyinstr+0x48>
    800018c6:	87da                	mv	a5,s6
    800018c8:	41650633          	sub	a2,a0,s6
    800018cc:	fff48593          	addi	a1,s1,-1
    800018d0:	95da                	add	a1,a1,s6
    800018d2:	96da                	add	a3,a3,s6
    800018d4:	00f60733          	add	a4,a2,a5
    800018d8:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffc8368>
    800018dc:	df51                	beqz	a4,80001878 <copyinstr+0x26>
    800018de:	00e78023          	sb	a4,0(a5)
    800018e2:	40f584b3          	sub	s1,a1,a5
    800018e6:	0785                	addi	a5,a5,1
    800018e8:	fed796e3          	bne	a5,a3,800018d4 <copyinstr+0x82>
    800018ec:	8b3e                	mv	s6,a5
    800018ee:	b775                	j	8000189a <copyinstr+0x48>
    800018f0:	4781                	li	a5,0
    800018f2:	b771                	j	8000187e <copyinstr+0x2c>
    800018f4:	557d                	li	a0,-1
    800018f6:	b779                	j	80001884 <copyinstr+0x32>
    800018f8:	4781                	li	a5,0
    800018fa:	37fd                	addiw	a5,a5,-1
    800018fc:	0007851b          	sext.w	a0,a5
    80001900:	8082                	ret

0000000080001902 <mapvpages>:
    80001902:	7179                	addi	sp,sp,-48
    80001904:	f406                	sd	ra,40(sp)
    80001906:	f022                	sd	s0,32(sp)
    80001908:	ec26                	sd	s1,24(sp)
    8000190a:	e84a                	sd	s2,16(sp)
    8000190c:	e44e                	sd	s3,8(sp)
    8000190e:	e052                	sd	s4,0(sp)
    80001910:	1800                	addi	s0,sp,48
    80001912:	ca15                	beqz	a2,80001946 <mapvpages+0x44>
    80001914:	89aa                	mv	s3,a0
    80001916:	77fd                	lui	a5,0xfffff
    80001918:	00f5f4b3          	and	s1,a1,a5
    8000191c:	fff58913          	addi	s2,a1,-1
    80001920:	9932                	add	s2,s2,a2
    80001922:	00f97933          	and	s2,s2,a5
    80001926:	6a05                	lui	s4,0x1
    80001928:	4605                	li	a2,1
    8000192a:	85a6                	mv	a1,s1
    8000192c:	854e                	mv	a0,s3
    8000192e:	fffff097          	auipc	ra,0xfffff
    80001932:	6c8080e7          	jalr	1736(ra) # 80000ff6 <walk>
    80001936:	c905                	beqz	a0,80001966 <mapvpages+0x64>
    80001938:	611c                	ld	a5,0(a0)
    8000193a:	8b85                	andi	a5,a5,1
    8000193c:	ef89                	bnez	a5,80001956 <mapvpages+0x54>
    8000193e:	03248d63          	beq	s1,s2,80001978 <mapvpages+0x76>
    80001942:	94d2                	add	s1,s1,s4
    80001944:	b7d5                	j	80001928 <mapvpages+0x26>
    80001946:	00007517          	auipc	a0,0x7
    8000194a:	79250513          	addi	a0,a0,1938 # 800090d8 <digits+0x98>
    8000194e:	fffff097          	auipc	ra,0xfffff
    80001952:	bee080e7          	jalr	-1042(ra) # 8000053c <panic>
    80001956:	00007517          	auipc	a0,0x7
    8000195a:	79250513          	addi	a0,a0,1938 # 800090e8 <digits+0xa8>
    8000195e:	fffff097          	auipc	ra,0xfffff
    80001962:	bde080e7          	jalr	-1058(ra) # 8000053c <panic>
    80001966:	557d                	li	a0,-1
    80001968:	70a2                	ld	ra,40(sp)
    8000196a:	7402                	ld	s0,32(sp)
    8000196c:	64e2                	ld	s1,24(sp)
    8000196e:	6942                	ld	s2,16(sp)
    80001970:	69a2                	ld	s3,8(sp)
    80001972:	6a02                	ld	s4,0(sp)
    80001974:	6145                	addi	sp,sp,48
    80001976:	8082                	ret
    80001978:	4501                	li	a0,0
    8000197a:	b7fd                	j	80001968 <mapvpages+0x66>

000000008000197c <proc_mapstacks>:
    8000197c:	7139                	addi	sp,sp,-64
    8000197e:	fc06                	sd	ra,56(sp)
    80001980:	f822                	sd	s0,48(sp)
    80001982:	f426                	sd	s1,40(sp)
    80001984:	f04a                	sd	s2,32(sp)
    80001986:	ec4e                	sd	s3,24(sp)
    80001988:	e852                	sd	s4,16(sp)
    8000198a:	e456                	sd	s5,8(sp)
    8000198c:	e05a                	sd	s6,0(sp)
    8000198e:	0080                	addi	s0,sp,64
    80001990:	89aa                	mv	s3,a0
    80001992:	00016497          	auipc	s1,0x16
    80001996:	d5648493          	addi	s1,s1,-682 # 800176e8 <proc>
    8000199a:	8b26                	mv	s6,s1
    8000199c:	00007a97          	auipc	s5,0x7
    800019a0:	664a8a93          	addi	s5,s5,1636 # 80009000 <etext>
    800019a4:	04000937          	lui	s2,0x4000
    800019a8:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    800019aa:	0932                	slli	s2,s2,0xc
    800019ac:	00026a17          	auipc	s4,0x26
    800019b0:	93ca0a13          	addi	s4,s4,-1732 # 800272e8 <tickslock>
    800019b4:	fffff097          	auipc	ra,0xfffff
    800019b8:	12e080e7          	jalr	302(ra) # 80000ae2 <kalloc>
    800019bc:	862a                	mv	a2,a0
    800019be:	c131                	beqz	a0,80001a02 <proc_mapstacks+0x86>
    800019c0:	416485b3          	sub	a1,s1,s6
    800019c4:	8591                	srai	a1,a1,0x4
    800019c6:	000ab783          	ld	a5,0(s5)
    800019ca:	02f585b3          	mul	a1,a1,a5
    800019ce:	2585                	addiw	a1,a1,1
    800019d0:	00d5959b          	slliw	a1,a1,0xd
    800019d4:	4719                	li	a4,6
    800019d6:	6685                	lui	a3,0x1
    800019d8:	40b905b3          	sub	a1,s2,a1
    800019dc:	854e                	mv	a0,s3
    800019de:	fffff097          	auipc	ra,0xfffff
    800019e2:	7a0080e7          	jalr	1952(ra) # 8000117e <kvmmap>
    800019e6:	3f048493          	addi	s1,s1,1008
    800019ea:	fd4495e3          	bne	s1,s4,800019b4 <proc_mapstacks+0x38>
    800019ee:	70e2                	ld	ra,56(sp)
    800019f0:	7442                	ld	s0,48(sp)
    800019f2:	74a2                	ld	s1,40(sp)
    800019f4:	7902                	ld	s2,32(sp)
    800019f6:	69e2                	ld	s3,24(sp)
    800019f8:	6a42                	ld	s4,16(sp)
    800019fa:	6aa2                	ld	s5,8(sp)
    800019fc:	6b02                	ld	s6,0(sp)
    800019fe:	6121                	addi	sp,sp,64
    80001a00:	8082                	ret
    80001a02:	00007517          	auipc	a0,0x7
    80001a06:	7be50513          	addi	a0,a0,1982 # 800091c0 <digits+0x180>
    80001a0a:	fffff097          	auipc	ra,0xfffff
    80001a0e:	b32080e7          	jalr	-1230(ra) # 8000053c <panic>

0000000080001a12 <procinit>:
    80001a12:	7139                	addi	sp,sp,-64
    80001a14:	fc06                	sd	ra,56(sp)
    80001a16:	f822                	sd	s0,48(sp)
    80001a18:	f426                	sd	s1,40(sp)
    80001a1a:	f04a                	sd	s2,32(sp)
    80001a1c:	ec4e                	sd	s3,24(sp)
    80001a1e:	e852                	sd	s4,16(sp)
    80001a20:	e456                	sd	s5,8(sp)
    80001a22:	e05a                	sd	s6,0(sp)
    80001a24:	0080                	addi	s0,sp,64
    80001a26:	00007597          	auipc	a1,0x7
    80001a2a:	7a258593          	addi	a1,a1,1954 # 800091c8 <digits+0x188>
    80001a2e:	00011517          	auipc	a0,0x11
    80001a32:	87250513          	addi	a0,a0,-1934 # 800122a0 <pid_lock>
    80001a36:	fffff097          	auipc	ra,0xfffff
    80001a3a:	154080e7          	jalr	340(ra) # 80000b8a <initlock>
    80001a3e:	00007597          	auipc	a1,0x7
    80001a42:	79258593          	addi	a1,a1,1938 # 800091d0 <digits+0x190>
    80001a46:	00011517          	auipc	a0,0x11
    80001a4a:	87250513          	addi	a0,a0,-1934 # 800122b8 <wait_lock>
    80001a4e:	fffff097          	auipc	ra,0xfffff
    80001a52:	13c080e7          	jalr	316(ra) # 80000b8a <initlock>
    80001a56:	00016497          	auipc	s1,0x16
    80001a5a:	c9248493          	addi	s1,s1,-878 # 800176e8 <proc>
    80001a5e:	00007b17          	auipc	s6,0x7
    80001a62:	782b0b13          	addi	s6,s6,1922 # 800091e0 <digits+0x1a0>
    80001a66:	8aa6                	mv	s5,s1
    80001a68:	00007a17          	auipc	s4,0x7
    80001a6c:	598a0a13          	addi	s4,s4,1432 # 80009000 <etext>
    80001a70:	04000937          	lui	s2,0x4000
    80001a74:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001a76:	0932                	slli	s2,s2,0xc
    80001a78:	00026997          	auipc	s3,0x26
    80001a7c:	87098993          	addi	s3,s3,-1936 # 800272e8 <tickslock>
    80001a80:	85da                	mv	a1,s6
    80001a82:	8526                	mv	a0,s1
    80001a84:	fffff097          	auipc	ra,0xfffff
    80001a88:	106080e7          	jalr	262(ra) # 80000b8a <initlock>
    80001a8c:	415487b3          	sub	a5,s1,s5
    80001a90:	8791                	srai	a5,a5,0x4
    80001a92:	000a3703          	ld	a4,0(s4)
    80001a96:	02e787b3          	mul	a5,a5,a4
    80001a9a:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ffc8369>
    80001a9c:	00d7979b          	slliw	a5,a5,0xd
    80001aa0:	40f907b3          	sub	a5,s2,a5
    80001aa4:	2cf4b423          	sd	a5,712(s1)
    80001aa8:	3f048493          	addi	s1,s1,1008
    80001aac:	fd349ae3          	bne	s1,s3,80001a80 <procinit+0x6e>
    80001ab0:	70e2                	ld	ra,56(sp)
    80001ab2:	7442                	ld	s0,48(sp)
    80001ab4:	74a2                	ld	s1,40(sp)
    80001ab6:	7902                	ld	s2,32(sp)
    80001ab8:	69e2                	ld	s3,24(sp)
    80001aba:	6a42                	ld	s4,16(sp)
    80001abc:	6aa2                	ld	s5,8(sp)
    80001abe:	6b02                	ld	s6,0(sp)
    80001ac0:	6121                	addi	sp,sp,64
    80001ac2:	8082                	ret

0000000080001ac4 <cpuid>:
    80001ac4:	1141                	addi	sp,sp,-16
    80001ac6:	e422                	sd	s0,8(sp)
    80001ac8:	0800                	addi	s0,sp,16
    80001aca:	8512                	mv	a0,tp
    80001acc:	2501                	sext.w	a0,a0
    80001ace:	6422                	ld	s0,8(sp)
    80001ad0:	0141                	addi	sp,sp,16
    80001ad2:	8082                	ret

0000000080001ad4 <mycpu>:
    80001ad4:	1141                	addi	sp,sp,-16
    80001ad6:	e422                	sd	s0,8(sp)
    80001ad8:	0800                	addi	s0,sp,16
    80001ada:	8792                	mv	a5,tp
    80001adc:	2781                	sext.w	a5,a5
    80001ade:	079e                	slli	a5,a5,0x7
    80001ae0:	00010517          	auipc	a0,0x10
    80001ae4:	7f050513          	addi	a0,a0,2032 # 800122d0 <cpus>
    80001ae8:	953e                	add	a0,a0,a5
    80001aea:	6422                	ld	s0,8(sp)
    80001aec:	0141                	addi	sp,sp,16
    80001aee:	8082                	ret

0000000080001af0 <myproc>:
    80001af0:	1101                	addi	sp,sp,-32
    80001af2:	ec06                	sd	ra,24(sp)
    80001af4:	e822                	sd	s0,16(sp)
    80001af6:	e426                	sd	s1,8(sp)
    80001af8:	1000                	addi	s0,sp,32
    80001afa:	fffff097          	auipc	ra,0xfffff
    80001afe:	0d4080e7          	jalr	212(ra) # 80000bce <push_off>
    80001b02:	8792                	mv	a5,tp
    80001b04:	2781                	sext.w	a5,a5
    80001b06:	079e                	slli	a5,a5,0x7
    80001b08:	00010717          	auipc	a4,0x10
    80001b0c:	79870713          	addi	a4,a4,1944 # 800122a0 <pid_lock>
    80001b10:	97ba                	add	a5,a5,a4
    80001b12:	7b84                	ld	s1,48(a5)
    80001b14:	fffff097          	auipc	ra,0xfffff
    80001b18:	15a080e7          	jalr	346(ra) # 80000c6e <pop_off>
    80001b1c:	8526                	mv	a0,s1
    80001b1e:	60e2                	ld	ra,24(sp)
    80001b20:	6442                	ld	s0,16(sp)
    80001b22:	64a2                	ld	s1,8(sp)
    80001b24:	6105                	addi	sp,sp,32
    80001b26:	8082                	ret

0000000080001b28 <forkret>:
    80001b28:	1141                	addi	sp,sp,-16
    80001b2a:	e406                	sd	ra,8(sp)
    80001b2c:	e022                	sd	s0,0(sp)
    80001b2e:	0800                	addi	s0,sp,16
    80001b30:	00000097          	auipc	ra,0x0
    80001b34:	fc0080e7          	jalr	-64(ra) # 80001af0 <myproc>
    80001b38:	fffff097          	auipc	ra,0xfffff
    80001b3c:	196080e7          	jalr	406(ra) # 80000cce <release>
    80001b40:	00008797          	auipc	a5,0x8
    80001b44:	da07a783          	lw	a5,-608(a5) # 800098e0 <first.1>
    80001b48:	eb89                	bnez	a5,80001b5a <forkret+0x32>
    80001b4a:	00001097          	auipc	ra,0x1
    80001b4e:	15e080e7          	jalr	350(ra) # 80002ca8 <usertrapret>
    80001b52:	60a2                	ld	ra,8(sp)
    80001b54:	6402                	ld	s0,0(sp)
    80001b56:	0141                	addi	sp,sp,16
    80001b58:	8082                	ret
    80001b5a:	00008797          	auipc	a5,0x8
    80001b5e:	d807a323          	sw	zero,-634(a5) # 800098e0 <first.1>
    80001b62:	4505                	li	a0,1
    80001b64:	00002097          	auipc	ra,0x2
    80001b68:	24e080e7          	jalr	590(ra) # 80003db2 <fsinit>
    80001b6c:	bff9                	j	80001b4a <forkret+0x22>

0000000080001b6e <allocpid>:
    80001b6e:	1101                	addi	sp,sp,-32
    80001b70:	ec06                	sd	ra,24(sp)
    80001b72:	e822                	sd	s0,16(sp)
    80001b74:	e426                	sd	s1,8(sp)
    80001b76:	e04a                	sd	s2,0(sp)
    80001b78:	1000                	addi	s0,sp,32
    80001b7a:	00010917          	auipc	s2,0x10
    80001b7e:	72690913          	addi	s2,s2,1830 # 800122a0 <pid_lock>
    80001b82:	854a                	mv	a0,s2
    80001b84:	fffff097          	auipc	ra,0xfffff
    80001b88:	096080e7          	jalr	150(ra) # 80000c1a <acquire>
    80001b8c:	00008797          	auipc	a5,0x8
    80001b90:	d5878793          	addi	a5,a5,-680 # 800098e4 <nextpid>
    80001b94:	4384                	lw	s1,0(a5)
    80001b96:	0014871b          	addiw	a4,s1,1
    80001b9a:	c398                	sw	a4,0(a5)
    80001b9c:	854a                	mv	a0,s2
    80001b9e:	fffff097          	auipc	ra,0xfffff
    80001ba2:	130080e7          	jalr	304(ra) # 80000cce <release>
    80001ba6:	8526                	mv	a0,s1
    80001ba8:	60e2                	ld	ra,24(sp)
    80001baa:	6442                	ld	s0,16(sp)
    80001bac:	64a2                	ld	s1,8(sp)
    80001bae:	6902                	ld	s2,0(sp)
    80001bb0:	6105                	addi	sp,sp,32
    80001bb2:	8082                	ret

0000000080001bb4 <proc_pagetable>:
    80001bb4:	1101                	addi	sp,sp,-32
    80001bb6:	ec06                	sd	ra,24(sp)
    80001bb8:	e822                	sd	s0,16(sp)
    80001bba:	e426                	sd	s1,8(sp)
    80001bbc:	e04a                	sd	s2,0(sp)
    80001bbe:	1000                	addi	s0,sp,32
    80001bc0:	892a                	mv	s2,a0
    80001bc2:	fffff097          	auipc	ra,0xfffff
    80001bc6:	798080e7          	jalr	1944(ra) # 8000135a <uvmcreate>
    80001bca:	84aa                	mv	s1,a0
    80001bcc:	c121                	beqz	a0,80001c0c <proc_pagetable+0x58>
    80001bce:	4729                	li	a4,10
    80001bd0:	00006697          	auipc	a3,0x6
    80001bd4:	43068693          	addi	a3,a3,1072 # 80008000 <_trampoline>
    80001bd8:	6605                	lui	a2,0x1
    80001bda:	040005b7          	lui	a1,0x4000
    80001bde:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001be0:	05b2                	slli	a1,a1,0xc
    80001be2:	fffff097          	auipc	ra,0xfffff
    80001be6:	4fc080e7          	jalr	1276(ra) # 800010de <mappages>
    80001bea:	02054863          	bltz	a0,80001c1a <proc_pagetable+0x66>
    80001bee:	4719                	li	a4,6
    80001bf0:	2e093683          	ld	a3,736(s2)
    80001bf4:	6605                	lui	a2,0x1
    80001bf6:	020005b7          	lui	a1,0x2000
    80001bfa:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001bfc:	05b6                	slli	a1,a1,0xd
    80001bfe:	8526                	mv	a0,s1
    80001c00:	fffff097          	auipc	ra,0xfffff
    80001c04:	4de080e7          	jalr	1246(ra) # 800010de <mappages>
    80001c08:	02054163          	bltz	a0,80001c2a <proc_pagetable+0x76>
    80001c0c:	8526                	mv	a0,s1
    80001c0e:	60e2                	ld	ra,24(sp)
    80001c10:	6442                	ld	s0,16(sp)
    80001c12:	64a2                	ld	s1,8(sp)
    80001c14:	6902                	ld	s2,0(sp)
    80001c16:	6105                	addi	sp,sp,32
    80001c18:	8082                	ret
    80001c1a:	4581                	li	a1,0
    80001c1c:	8526                	mv	a0,s1
    80001c1e:	00000097          	auipc	ra,0x0
    80001c22:	93a080e7          	jalr	-1734(ra) # 80001558 <uvmfree>
    80001c26:	4481                	li	s1,0
    80001c28:	b7d5                	j	80001c0c <proc_pagetable+0x58>
    80001c2a:	4681                	li	a3,0
    80001c2c:	4605                	li	a2,1
    80001c2e:	040005b7          	lui	a1,0x4000
    80001c32:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c34:	05b2                	slli	a1,a1,0xc
    80001c36:	8526                	mv	a0,s1
    80001c38:	fffff097          	auipc	ra,0xfffff
    80001c3c:	66c080e7          	jalr	1644(ra) # 800012a4 <uvmunmap>
    80001c40:	4581                	li	a1,0
    80001c42:	8526                	mv	a0,s1
    80001c44:	00000097          	auipc	ra,0x0
    80001c48:	914080e7          	jalr	-1772(ra) # 80001558 <uvmfree>
    80001c4c:	4481                	li	s1,0
    80001c4e:	bf7d                	j	80001c0c <proc_pagetable+0x58>

0000000080001c50 <proc_freepagetable>:
    80001c50:	1101                	addi	sp,sp,-32
    80001c52:	ec06                	sd	ra,24(sp)
    80001c54:	e822                	sd	s0,16(sp)
    80001c56:	e426                	sd	s1,8(sp)
    80001c58:	e04a                	sd	s2,0(sp)
    80001c5a:	1000                	addi	s0,sp,32
    80001c5c:	84aa                	mv	s1,a0
    80001c5e:	892e                	mv	s2,a1
    80001c60:	4681                	li	a3,0
    80001c62:	4605                	li	a2,1
    80001c64:	040005b7          	lui	a1,0x4000
    80001c68:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c6a:	05b2                	slli	a1,a1,0xc
    80001c6c:	fffff097          	auipc	ra,0xfffff
    80001c70:	638080e7          	jalr	1592(ra) # 800012a4 <uvmunmap>
    80001c74:	4681                	li	a3,0
    80001c76:	4605                	li	a2,1
    80001c78:	020005b7          	lui	a1,0x2000
    80001c7c:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c7e:	05b6                	slli	a1,a1,0xd
    80001c80:	8526                	mv	a0,s1
    80001c82:	fffff097          	auipc	ra,0xfffff
    80001c86:	622080e7          	jalr	1570(ra) # 800012a4 <uvmunmap>
    80001c8a:	85ca                	mv	a1,s2
    80001c8c:	8526                	mv	a0,s1
    80001c8e:	00000097          	auipc	ra,0x0
    80001c92:	8ca080e7          	jalr	-1846(ra) # 80001558 <uvmfree>
    80001c96:	60e2                	ld	ra,24(sp)
    80001c98:	6442                	ld	s0,16(sp)
    80001c9a:	64a2                	ld	s1,8(sp)
    80001c9c:	6902                	ld	s2,0(sp)
    80001c9e:	6105                	addi	sp,sp,32
    80001ca0:	8082                	ret

0000000080001ca2 <growproc>:
    80001ca2:	1101                	addi	sp,sp,-32
    80001ca4:	ec06                	sd	ra,24(sp)
    80001ca6:	e822                	sd	s0,16(sp)
    80001ca8:	e426                	sd	s1,8(sp)
    80001caa:	e04a                	sd	s2,0(sp)
    80001cac:	1000                	addi	s0,sp,32
    80001cae:	84aa                	mv	s1,a0
    80001cb0:	00000097          	auipc	ra,0x0
    80001cb4:	e40080e7          	jalr	-448(ra) # 80001af0 <myproc>
    80001cb8:	892a                	mv	s2,a0
    80001cba:	2d053583          	ld	a1,720(a0)
    80001cbe:	0005879b          	sext.w	a5,a1
    80001cc2:	00904f63          	bgtz	s1,80001ce0 <growproc+0x3e>
    80001cc6:	0204ce63          	bltz	s1,80001d02 <growproc+0x60>
    80001cca:	1782                	slli	a5,a5,0x20
    80001ccc:	9381                	srli	a5,a5,0x20
    80001cce:	2cf93823          	sd	a5,720(s2)
    80001cd2:	4501                	li	a0,0
    80001cd4:	60e2                	ld	ra,24(sp)
    80001cd6:	6442                	ld	s0,16(sp)
    80001cd8:	64a2                	ld	s1,8(sp)
    80001cda:	6902                	ld	s2,0(sp)
    80001cdc:	6105                	addi	sp,sp,32
    80001cde:	8082                	ret
    80001ce0:	00f4863b          	addw	a2,s1,a5
    80001ce4:	1602                	slli	a2,a2,0x20
    80001ce6:	9201                	srli	a2,a2,0x20
    80001ce8:	1582                	slli	a1,a1,0x20
    80001cea:	9181                	srli	a1,a1,0x20
    80001cec:	2d853503          	ld	a0,728(a0)
    80001cf0:	fffff097          	auipc	ra,0xfffff
    80001cf4:	752080e7          	jalr	1874(ra) # 80001442 <uvmalloc>
    80001cf8:	0005079b          	sext.w	a5,a0
    80001cfc:	f7f9                	bnez	a5,80001cca <growproc+0x28>
    80001cfe:	557d                	li	a0,-1
    80001d00:	bfd1                	j	80001cd4 <growproc+0x32>
    80001d02:	00f4863b          	addw	a2,s1,a5
    80001d06:	1602                	slli	a2,a2,0x20
    80001d08:	9201                	srli	a2,a2,0x20
    80001d0a:	1582                	slli	a1,a1,0x20
    80001d0c:	9181                	srli	a1,a1,0x20
    80001d0e:	2d853503          	ld	a0,728(a0)
    80001d12:	fffff097          	auipc	ra,0xfffff
    80001d16:	6e8080e7          	jalr	1768(ra) # 800013fa <uvmdealloc>
    80001d1a:	0005079b          	sext.w	a5,a0
    80001d1e:	b775                	j	80001cca <growproc+0x28>

0000000080001d20 <scheduler>:
    80001d20:	7139                	addi	sp,sp,-64
    80001d22:	fc06                	sd	ra,56(sp)
    80001d24:	f822                	sd	s0,48(sp)
    80001d26:	f426                	sd	s1,40(sp)
    80001d28:	f04a                	sd	s2,32(sp)
    80001d2a:	ec4e                	sd	s3,24(sp)
    80001d2c:	e852                	sd	s4,16(sp)
    80001d2e:	e456                	sd	s5,8(sp)
    80001d30:	e05a                	sd	s6,0(sp)
    80001d32:	0080                	addi	s0,sp,64
    80001d34:	8792                	mv	a5,tp
    80001d36:	2781                	sext.w	a5,a5
    80001d38:	00779a93          	slli	s5,a5,0x7
    80001d3c:	00010717          	auipc	a4,0x10
    80001d40:	56470713          	addi	a4,a4,1380 # 800122a0 <pid_lock>
    80001d44:	9756                	add	a4,a4,s5
    80001d46:	02073823          	sd	zero,48(a4)
    80001d4a:	00010717          	auipc	a4,0x10
    80001d4e:	58e70713          	addi	a4,a4,1422 # 800122d8 <cpus+0x8>
    80001d52:	9aba                	add	s5,s5,a4
    80001d54:	498d                	li	s3,3
    80001d56:	4b11                	li	s6,4
    80001d58:	079e                	slli	a5,a5,0x7
    80001d5a:	00010a17          	auipc	s4,0x10
    80001d5e:	546a0a13          	addi	s4,s4,1350 # 800122a0 <pid_lock>
    80001d62:	9a3e                	add	s4,s4,a5
    80001d64:	00025917          	auipc	s2,0x25
    80001d68:	58490913          	addi	s2,s2,1412 # 800272e8 <tickslock>
    80001d6c:	100027f3          	csrr	a5,sstatus
    80001d70:	0027e793          	ori	a5,a5,2
    80001d74:	10079073          	csrw	sstatus,a5
    80001d78:	00016497          	auipc	s1,0x16
    80001d7c:	97048493          	addi	s1,s1,-1680 # 800176e8 <proc>
    80001d80:	a811                	j	80001d94 <scheduler+0x74>
    80001d82:	8526                	mv	a0,s1
    80001d84:	fffff097          	auipc	ra,0xfffff
    80001d88:	f4a080e7          	jalr	-182(ra) # 80000cce <release>
    80001d8c:	3f048493          	addi	s1,s1,1008
    80001d90:	fd248ee3          	beq	s1,s2,80001d6c <scheduler+0x4c>
    80001d94:	8526                	mv	a0,s1
    80001d96:	fffff097          	auipc	ra,0xfffff
    80001d9a:	e84080e7          	jalr	-380(ra) # 80000c1a <acquire>
    80001d9e:	2a04a783          	lw	a5,672(s1)
    80001da2:	ff3790e3          	bne	a5,s3,80001d82 <scheduler+0x62>
    80001da6:	2b64a023          	sw	s6,672(s1)
    80001daa:	029a3823          	sd	s1,48(s4)
    80001dae:	2e848593          	addi	a1,s1,744
    80001db2:	8556                	mv	a0,s5
    80001db4:	00001097          	auipc	ra,0x1
    80001db8:	e08080e7          	jalr	-504(ra) # 80002bbc <swtch>
    80001dbc:	020a3823          	sd	zero,48(s4)
    80001dc0:	b7c9                	j	80001d82 <scheduler+0x62>

0000000080001dc2 <sched>:
    80001dc2:	7179                	addi	sp,sp,-48
    80001dc4:	f406                	sd	ra,40(sp)
    80001dc6:	f022                	sd	s0,32(sp)
    80001dc8:	ec26                	sd	s1,24(sp)
    80001dca:	e84a                	sd	s2,16(sp)
    80001dcc:	e44e                	sd	s3,8(sp)
    80001dce:	1800                	addi	s0,sp,48
    80001dd0:	00000097          	auipc	ra,0x0
    80001dd4:	d20080e7          	jalr	-736(ra) # 80001af0 <myproc>
    80001dd8:	84aa                	mv	s1,a0
    80001dda:	fffff097          	auipc	ra,0xfffff
    80001dde:	dc6080e7          	jalr	-570(ra) # 80000ba0 <holding>
    80001de2:	cd25                	beqz	a0,80001e5a <sched+0x98>
    80001de4:	8792                	mv	a5,tp
    80001de6:	2781                	sext.w	a5,a5
    80001de8:	079e                	slli	a5,a5,0x7
    80001dea:	00010717          	auipc	a4,0x10
    80001dee:	4b670713          	addi	a4,a4,1206 # 800122a0 <pid_lock>
    80001df2:	97ba                	add	a5,a5,a4
    80001df4:	0a87a703          	lw	a4,168(a5)
    80001df8:	4785                	li	a5,1
    80001dfa:	06f71863          	bne	a4,a5,80001e6a <sched+0xa8>
    80001dfe:	2a04a703          	lw	a4,672(s1)
    80001e02:	4791                	li	a5,4
    80001e04:	06f70b63          	beq	a4,a5,80001e7a <sched+0xb8>
    80001e08:	100027f3          	csrr	a5,sstatus
    80001e0c:	8b89                	andi	a5,a5,2
    80001e0e:	efb5                	bnez	a5,80001e8a <sched+0xc8>
    80001e10:	8792                	mv	a5,tp
    80001e12:	00010917          	auipc	s2,0x10
    80001e16:	48e90913          	addi	s2,s2,1166 # 800122a0 <pid_lock>
    80001e1a:	2781                	sext.w	a5,a5
    80001e1c:	079e                	slli	a5,a5,0x7
    80001e1e:	97ca                	add	a5,a5,s2
    80001e20:	0ac7a983          	lw	s3,172(a5)
    80001e24:	8792                	mv	a5,tp
    80001e26:	2781                	sext.w	a5,a5
    80001e28:	079e                	slli	a5,a5,0x7
    80001e2a:	00010597          	auipc	a1,0x10
    80001e2e:	4ae58593          	addi	a1,a1,1198 # 800122d8 <cpus+0x8>
    80001e32:	95be                	add	a1,a1,a5
    80001e34:	2e848513          	addi	a0,s1,744
    80001e38:	00001097          	auipc	ra,0x1
    80001e3c:	d84080e7          	jalr	-636(ra) # 80002bbc <swtch>
    80001e40:	8792                	mv	a5,tp
    80001e42:	2781                	sext.w	a5,a5
    80001e44:	079e                	slli	a5,a5,0x7
    80001e46:	993e                	add	s2,s2,a5
    80001e48:	0b392623          	sw	s3,172(s2)
    80001e4c:	70a2                	ld	ra,40(sp)
    80001e4e:	7402                	ld	s0,32(sp)
    80001e50:	64e2                	ld	s1,24(sp)
    80001e52:	6942                	ld	s2,16(sp)
    80001e54:	69a2                	ld	s3,8(sp)
    80001e56:	6145                	addi	sp,sp,48
    80001e58:	8082                	ret
    80001e5a:	00007517          	auipc	a0,0x7
    80001e5e:	38e50513          	addi	a0,a0,910 # 800091e8 <digits+0x1a8>
    80001e62:	ffffe097          	auipc	ra,0xffffe
    80001e66:	6da080e7          	jalr	1754(ra) # 8000053c <panic>
    80001e6a:	00007517          	auipc	a0,0x7
    80001e6e:	38e50513          	addi	a0,a0,910 # 800091f8 <digits+0x1b8>
    80001e72:	ffffe097          	auipc	ra,0xffffe
    80001e76:	6ca080e7          	jalr	1738(ra) # 8000053c <panic>
    80001e7a:	00007517          	auipc	a0,0x7
    80001e7e:	38e50513          	addi	a0,a0,910 # 80009208 <digits+0x1c8>
    80001e82:	ffffe097          	auipc	ra,0xffffe
    80001e86:	6ba080e7          	jalr	1722(ra) # 8000053c <panic>
    80001e8a:	00007517          	auipc	a0,0x7
    80001e8e:	38e50513          	addi	a0,a0,910 # 80009218 <digits+0x1d8>
    80001e92:	ffffe097          	auipc	ra,0xffffe
    80001e96:	6aa080e7          	jalr	1706(ra) # 8000053c <panic>

0000000080001e9a <yield>:
    80001e9a:	1101                	addi	sp,sp,-32
    80001e9c:	ec06                	sd	ra,24(sp)
    80001e9e:	e822                	sd	s0,16(sp)
    80001ea0:	e426                	sd	s1,8(sp)
    80001ea2:	1000                	addi	s0,sp,32
    80001ea4:	00000097          	auipc	ra,0x0
    80001ea8:	c4c080e7          	jalr	-948(ra) # 80001af0 <myproc>
    80001eac:	84aa                	mv	s1,a0
    80001eae:	fffff097          	auipc	ra,0xfffff
    80001eb2:	d6c080e7          	jalr	-660(ra) # 80000c1a <acquire>
    80001eb6:	478d                	li	a5,3
    80001eb8:	2af4a023          	sw	a5,672(s1)
    80001ebc:	00000097          	auipc	ra,0x0
    80001ec0:	f06080e7          	jalr	-250(ra) # 80001dc2 <sched>
    80001ec4:	8526                	mv	a0,s1
    80001ec6:	fffff097          	auipc	ra,0xfffff
    80001eca:	e08080e7          	jalr	-504(ra) # 80000cce <release>
    80001ece:	60e2                	ld	ra,24(sp)
    80001ed0:	6442                	ld	s0,16(sp)
    80001ed2:	64a2                	ld	s1,8(sp)
    80001ed4:	6105                	addi	sp,sp,32
    80001ed6:	8082                	ret

0000000080001ed8 <sleep>:
    80001ed8:	7179                	addi	sp,sp,-48
    80001eda:	f406                	sd	ra,40(sp)
    80001edc:	f022                	sd	s0,32(sp)
    80001ede:	ec26                	sd	s1,24(sp)
    80001ee0:	e84a                	sd	s2,16(sp)
    80001ee2:	e44e                	sd	s3,8(sp)
    80001ee4:	1800                	addi	s0,sp,48
    80001ee6:	89aa                	mv	s3,a0
    80001ee8:	892e                	mv	s2,a1
    80001eea:	00000097          	auipc	ra,0x0
    80001eee:	c06080e7          	jalr	-1018(ra) # 80001af0 <myproc>
    80001ef2:	84aa                	mv	s1,a0
    80001ef4:	fffff097          	auipc	ra,0xfffff
    80001ef8:	d26080e7          	jalr	-730(ra) # 80000c1a <acquire>
    80001efc:	854a                	mv	a0,s2
    80001efe:	fffff097          	auipc	ra,0xfffff
    80001f02:	dd0080e7          	jalr	-560(ra) # 80000cce <release>
    80001f06:	2b34b423          	sd	s3,680(s1)
    80001f0a:	4789                	li	a5,2
    80001f0c:	2af4a023          	sw	a5,672(s1)
    80001f10:	00000097          	auipc	ra,0x0
    80001f14:	eb2080e7          	jalr	-334(ra) # 80001dc2 <sched>
    80001f18:	2a04b423          	sd	zero,680(s1)
    80001f1c:	8526                	mv	a0,s1
    80001f1e:	fffff097          	auipc	ra,0xfffff
    80001f22:	db0080e7          	jalr	-592(ra) # 80000cce <release>
    80001f26:	854a                	mv	a0,s2
    80001f28:	fffff097          	auipc	ra,0xfffff
    80001f2c:	cf2080e7          	jalr	-782(ra) # 80000c1a <acquire>
    80001f30:	70a2                	ld	ra,40(sp)
    80001f32:	7402                	ld	s0,32(sp)
    80001f34:	64e2                	ld	s1,24(sp)
    80001f36:	6942                	ld	s2,16(sp)
    80001f38:	69a2                	ld	s3,8(sp)
    80001f3a:	6145                	addi	sp,sp,48
    80001f3c:	8082                	ret

0000000080001f3e <wakeup>:
    80001f3e:	7139                	addi	sp,sp,-64
    80001f40:	fc06                	sd	ra,56(sp)
    80001f42:	f822                	sd	s0,48(sp)
    80001f44:	f426                	sd	s1,40(sp)
    80001f46:	f04a                	sd	s2,32(sp)
    80001f48:	ec4e                	sd	s3,24(sp)
    80001f4a:	e852                	sd	s4,16(sp)
    80001f4c:	e456                	sd	s5,8(sp)
    80001f4e:	0080                	addi	s0,sp,64
    80001f50:	8a2a                	mv	s4,a0
    80001f52:	00015497          	auipc	s1,0x15
    80001f56:	79648493          	addi	s1,s1,1942 # 800176e8 <proc>
    80001f5a:	4989                	li	s3,2
    80001f5c:	4a8d                	li	s5,3
    80001f5e:	00025917          	auipc	s2,0x25
    80001f62:	38a90913          	addi	s2,s2,906 # 800272e8 <tickslock>
    80001f66:	a811                	j	80001f7a <wakeup+0x3c>
    80001f68:	8526                	mv	a0,s1
    80001f6a:	fffff097          	auipc	ra,0xfffff
    80001f6e:	d64080e7          	jalr	-668(ra) # 80000cce <release>
    80001f72:	3f048493          	addi	s1,s1,1008
    80001f76:	03248863          	beq	s1,s2,80001fa6 <wakeup+0x68>
    80001f7a:	00000097          	auipc	ra,0x0
    80001f7e:	b76080e7          	jalr	-1162(ra) # 80001af0 <myproc>
    80001f82:	fea488e3          	beq	s1,a0,80001f72 <wakeup+0x34>
    80001f86:	8526                	mv	a0,s1
    80001f88:	fffff097          	auipc	ra,0xfffff
    80001f8c:	c92080e7          	jalr	-878(ra) # 80000c1a <acquire>
    80001f90:	2a04a783          	lw	a5,672(s1)
    80001f94:	fd379ae3          	bne	a5,s3,80001f68 <wakeup+0x2a>
    80001f98:	2a84b783          	ld	a5,680(s1)
    80001f9c:	fd4796e3          	bne	a5,s4,80001f68 <wakeup+0x2a>
    80001fa0:	2b54a023          	sw	s5,672(s1)
    80001fa4:	b7d1                	j	80001f68 <wakeup+0x2a>
    80001fa6:	70e2                	ld	ra,56(sp)
    80001fa8:	7442                	ld	s0,48(sp)
    80001faa:	74a2                	ld	s1,40(sp)
    80001fac:	7902                	ld	s2,32(sp)
    80001fae:	69e2                	ld	s3,24(sp)
    80001fb0:	6a42                	ld	s4,16(sp)
    80001fb2:	6aa2                	ld	s5,8(sp)
    80001fb4:	6121                	addi	sp,sp,64
    80001fb6:	8082                	ret

0000000080001fb8 <reparent>:
    80001fb8:	7179                	addi	sp,sp,-48
    80001fba:	f406                	sd	ra,40(sp)
    80001fbc:	f022                	sd	s0,32(sp)
    80001fbe:	ec26                	sd	s1,24(sp)
    80001fc0:	e84a                	sd	s2,16(sp)
    80001fc2:	e44e                	sd	s3,8(sp)
    80001fc4:	e052                	sd	s4,0(sp)
    80001fc6:	1800                	addi	s0,sp,48
    80001fc8:	892a                	mv	s2,a0
    80001fca:	00015497          	auipc	s1,0x15
    80001fce:	71e48493          	addi	s1,s1,1822 # 800176e8 <proc>
    80001fd2:	00008a17          	auipc	s4,0x8
    80001fd6:	056a0a13          	addi	s4,s4,86 # 8000a028 <initproc>
    80001fda:	00025997          	auipc	s3,0x25
    80001fde:	30e98993          	addi	s3,s3,782 # 800272e8 <tickslock>
    80001fe2:	a029                	j	80001fec <reparent+0x34>
    80001fe4:	3f048493          	addi	s1,s1,1008
    80001fe8:	01348f63          	beq	s1,s3,80002006 <reparent+0x4e>
    80001fec:	2c04b783          	ld	a5,704(s1)
    80001ff0:	ff279ae3          	bne	a5,s2,80001fe4 <reparent+0x2c>
    80001ff4:	000a3503          	ld	a0,0(s4)
    80001ff8:	2ca4b023          	sd	a0,704(s1)
    80001ffc:	00000097          	auipc	ra,0x0
    80002000:	f42080e7          	jalr	-190(ra) # 80001f3e <wakeup>
    80002004:	b7c5                	j	80001fe4 <reparent+0x2c>
    80002006:	70a2                	ld	ra,40(sp)
    80002008:	7402                	ld	s0,32(sp)
    8000200a:	64e2                	ld	s1,24(sp)
    8000200c:	6942                	ld	s2,16(sp)
    8000200e:	69a2                	ld	s3,8(sp)
    80002010:	6a02                	ld	s4,0(sp)
    80002012:	6145                	addi	sp,sp,48
    80002014:	8082                	ret

0000000080002016 <exit>:
    80002016:	7179                	addi	sp,sp,-48
    80002018:	f406                	sd	ra,40(sp)
    8000201a:	f022                	sd	s0,32(sp)
    8000201c:	ec26                	sd	s1,24(sp)
    8000201e:	e84a                	sd	s2,16(sp)
    80002020:	e44e                	sd	s3,8(sp)
    80002022:	e052                	sd	s4,0(sp)
    80002024:	1800                	addi	s0,sp,48
    80002026:	8a2a                	mv	s4,a0
    80002028:	00000097          	auipc	ra,0x0
    8000202c:	ac8080e7          	jalr	-1336(ra) # 80001af0 <myproc>
    80002030:	89aa                	mv	s3,a0
    80002032:	00008797          	auipc	a5,0x8
    80002036:	ff67b783          	ld	a5,-10(a5) # 8000a028 <initproc>
    8000203a:	35850493          	addi	s1,a0,856
    8000203e:	3d850913          	addi	s2,a0,984
    80002042:	02a79363          	bne	a5,a0,80002068 <exit+0x52>
    80002046:	00007517          	auipc	a0,0x7
    8000204a:	1ea50513          	addi	a0,a0,490 # 80009230 <digits+0x1f0>
    8000204e:	ffffe097          	auipc	ra,0xffffe
    80002052:	4ee080e7          	jalr	1262(ra) # 8000053c <panic>
    80002056:	00003097          	auipc	ra,0x3
    8000205a:	e7e080e7          	jalr	-386(ra) # 80004ed4 <fileclose>
    8000205e:	0004b023          	sd	zero,0(s1)
    80002062:	04a1                	addi	s1,s1,8
    80002064:	01248563          	beq	s1,s2,8000206e <exit+0x58>
    80002068:	6088                	ld	a0,0(s1)
    8000206a:	f575                	bnez	a0,80002056 <exit+0x40>
    8000206c:	bfdd                	j	80002062 <exit+0x4c>
    8000206e:	00003097          	auipc	ra,0x3
    80002072:	99a080e7          	jalr	-1638(ra) # 80004a08 <begin_op>
    80002076:	3d89b503          	ld	a0,984(s3)
    8000207a:	00002097          	auipc	ra,0x2
    8000207e:	16c080e7          	jalr	364(ra) # 800041e6 <iput>
    80002082:	00003097          	auipc	ra,0x3
    80002086:	a04080e7          	jalr	-1532(ra) # 80004a86 <end_op>
    8000208a:	3c09bc23          	sd	zero,984(s3)
    8000208e:	00010497          	auipc	s1,0x10
    80002092:	22a48493          	addi	s1,s1,554 # 800122b8 <wait_lock>
    80002096:	8526                	mv	a0,s1
    80002098:	fffff097          	auipc	ra,0xfffff
    8000209c:	b82080e7          	jalr	-1150(ra) # 80000c1a <acquire>
    800020a0:	854e                	mv	a0,s3
    800020a2:	00000097          	auipc	ra,0x0
    800020a6:	f16080e7          	jalr	-234(ra) # 80001fb8 <reparent>
    800020aa:	2c09b503          	ld	a0,704(s3)
    800020ae:	00000097          	auipc	ra,0x0
    800020b2:	e90080e7          	jalr	-368(ra) # 80001f3e <wakeup>
    800020b6:	854e                	mv	a0,s3
    800020b8:	fffff097          	auipc	ra,0xfffff
    800020bc:	b62080e7          	jalr	-1182(ra) # 80000c1a <acquire>
    800020c0:	2b49aa23          	sw	s4,692(s3)
    800020c4:	4795                	li	a5,5
    800020c6:	2af9a023          	sw	a5,672(s3)
    800020ca:	8526                	mv	a0,s1
    800020cc:	fffff097          	auipc	ra,0xfffff
    800020d0:	c02080e7          	jalr	-1022(ra) # 80000cce <release>
    800020d4:	00000097          	auipc	ra,0x0
    800020d8:	cee080e7          	jalr	-786(ra) # 80001dc2 <sched>
    800020dc:	00007517          	auipc	a0,0x7
    800020e0:	16450513          	addi	a0,a0,356 # 80009240 <digits+0x200>
    800020e4:	ffffe097          	auipc	ra,0xffffe
    800020e8:	458080e7          	jalr	1112(ra) # 8000053c <panic>

00000000800020ec <kill>:
    800020ec:	7179                	addi	sp,sp,-48
    800020ee:	f406                	sd	ra,40(sp)
    800020f0:	f022                	sd	s0,32(sp)
    800020f2:	ec26                	sd	s1,24(sp)
    800020f4:	e84a                	sd	s2,16(sp)
    800020f6:	e44e                	sd	s3,8(sp)
    800020f8:	1800                	addi	s0,sp,48
    800020fa:	892a                	mv	s2,a0
    800020fc:	00015497          	auipc	s1,0x15
    80002100:	5ec48493          	addi	s1,s1,1516 # 800176e8 <proc>
    80002104:	00025997          	auipc	s3,0x25
    80002108:	1e498993          	addi	s3,s3,484 # 800272e8 <tickslock>
    8000210c:	8526                	mv	a0,s1
    8000210e:	fffff097          	auipc	ra,0xfffff
    80002112:	b0c080e7          	jalr	-1268(ra) # 80000c1a <acquire>
    80002116:	2b84a783          	lw	a5,696(s1)
    8000211a:	01278d63          	beq	a5,s2,80002134 <kill+0x48>
    8000211e:	8526                	mv	a0,s1
    80002120:	fffff097          	auipc	ra,0xfffff
    80002124:	bae080e7          	jalr	-1106(ra) # 80000cce <release>
    80002128:	3f048493          	addi	s1,s1,1008
    8000212c:	ff3490e3          	bne	s1,s3,8000210c <kill+0x20>
    80002130:	557d                	li	a0,-1
    80002132:	a839                	j	80002150 <kill+0x64>
    80002134:	4785                	li	a5,1
    80002136:	2af4a823          	sw	a5,688(s1)
    8000213a:	2a04a703          	lw	a4,672(s1)
    8000213e:	4789                	li	a5,2
    80002140:	00f70f63          	beq	a4,a5,8000215e <kill+0x72>
    80002144:	8526                	mv	a0,s1
    80002146:	fffff097          	auipc	ra,0xfffff
    8000214a:	b88080e7          	jalr	-1144(ra) # 80000cce <release>
    8000214e:	4501                	li	a0,0
    80002150:	70a2                	ld	ra,40(sp)
    80002152:	7402                	ld	s0,32(sp)
    80002154:	64e2                	ld	s1,24(sp)
    80002156:	6942                	ld	s2,16(sp)
    80002158:	69a2                	ld	s3,8(sp)
    8000215a:	6145                	addi	sp,sp,48
    8000215c:	8082                	ret
    8000215e:	478d                	li	a5,3
    80002160:	2af4a023          	sw	a5,672(s1)
    80002164:	b7c5                	j	80002144 <kill+0x58>

0000000080002166 <either_copyout>:
    80002166:	7179                	addi	sp,sp,-48
    80002168:	f406                	sd	ra,40(sp)
    8000216a:	f022                	sd	s0,32(sp)
    8000216c:	ec26                	sd	s1,24(sp)
    8000216e:	e84a                	sd	s2,16(sp)
    80002170:	e44e                	sd	s3,8(sp)
    80002172:	e052                	sd	s4,0(sp)
    80002174:	1800                	addi	s0,sp,48
    80002176:	84aa                	mv	s1,a0
    80002178:	892e                	mv	s2,a1
    8000217a:	89b2                	mv	s3,a2
    8000217c:	8a36                	mv	s4,a3
    8000217e:	00000097          	auipc	ra,0x0
    80002182:	972080e7          	jalr	-1678(ra) # 80001af0 <myproc>
    80002186:	c095                	beqz	s1,800021aa <either_copyout+0x44>
    80002188:	86d2                	mv	a3,s4
    8000218a:	864e                	mv	a2,s3
    8000218c:	85ca                	mv	a1,s2
    8000218e:	2d853503          	ld	a0,728(a0)
    80002192:	fffff097          	auipc	ra,0xfffff
    80002196:	5a6080e7          	jalr	1446(ra) # 80001738 <copyout>
    8000219a:	70a2                	ld	ra,40(sp)
    8000219c:	7402                	ld	s0,32(sp)
    8000219e:	64e2                	ld	s1,24(sp)
    800021a0:	6942                	ld	s2,16(sp)
    800021a2:	69a2                	ld	s3,8(sp)
    800021a4:	6a02                	ld	s4,0(sp)
    800021a6:	6145                	addi	sp,sp,48
    800021a8:	8082                	ret
    800021aa:	000a061b          	sext.w	a2,s4
    800021ae:	85ce                	mv	a1,s3
    800021b0:	854a                	mv	a0,s2
    800021b2:	fffff097          	auipc	ra,0xfffff
    800021b6:	bc0080e7          	jalr	-1088(ra) # 80000d72 <memmove>
    800021ba:	8526                	mv	a0,s1
    800021bc:	bff9                	j	8000219a <either_copyout+0x34>

00000000800021be <either_copyin>:
    800021be:	7179                	addi	sp,sp,-48
    800021c0:	f406                	sd	ra,40(sp)
    800021c2:	f022                	sd	s0,32(sp)
    800021c4:	ec26                	sd	s1,24(sp)
    800021c6:	e84a                	sd	s2,16(sp)
    800021c8:	e44e                	sd	s3,8(sp)
    800021ca:	e052                	sd	s4,0(sp)
    800021cc:	1800                	addi	s0,sp,48
    800021ce:	892a                	mv	s2,a0
    800021d0:	84ae                	mv	s1,a1
    800021d2:	89b2                	mv	s3,a2
    800021d4:	8a36                	mv	s4,a3
    800021d6:	00000097          	auipc	ra,0x0
    800021da:	91a080e7          	jalr	-1766(ra) # 80001af0 <myproc>
    800021de:	c095                	beqz	s1,80002202 <either_copyin+0x44>
    800021e0:	86d2                	mv	a3,s4
    800021e2:	864e                	mv	a2,s3
    800021e4:	85ca                	mv	a1,s2
    800021e6:	2d853503          	ld	a0,728(a0)
    800021ea:	fffff097          	auipc	ra,0xfffff
    800021ee:	5da080e7          	jalr	1498(ra) # 800017c4 <copyin>
    800021f2:	70a2                	ld	ra,40(sp)
    800021f4:	7402                	ld	s0,32(sp)
    800021f6:	64e2                	ld	s1,24(sp)
    800021f8:	6942                	ld	s2,16(sp)
    800021fa:	69a2                	ld	s3,8(sp)
    800021fc:	6a02                	ld	s4,0(sp)
    800021fe:	6145                	addi	sp,sp,48
    80002200:	8082                	ret
    80002202:	000a061b          	sext.w	a2,s4
    80002206:	85ce                	mv	a1,s3
    80002208:	854a                	mv	a0,s2
    8000220a:	fffff097          	auipc	ra,0xfffff
    8000220e:	b68080e7          	jalr	-1176(ra) # 80000d72 <memmove>
    80002212:	8526                	mv	a0,s1
    80002214:	bff9                	j	800021f2 <either_copyin+0x34>

0000000080002216 <procdump>:
    80002216:	715d                	addi	sp,sp,-80
    80002218:	e486                	sd	ra,72(sp)
    8000221a:	e0a2                	sd	s0,64(sp)
    8000221c:	fc26                	sd	s1,56(sp)
    8000221e:	f84a                	sd	s2,48(sp)
    80002220:	f44e                	sd	s3,40(sp)
    80002222:	f052                	sd	s4,32(sp)
    80002224:	ec56                	sd	s5,24(sp)
    80002226:	e85a                	sd	s6,16(sp)
    80002228:	e45e                	sd	s7,8(sp)
    8000222a:	0880                	addi	s0,sp,80
    8000222c:	00007517          	auipc	a0,0x7
    80002230:	e9c50513          	addi	a0,a0,-356 # 800090c8 <digits+0x88>
    80002234:	ffffe097          	auipc	ra,0xffffe
    80002238:	352080e7          	jalr	850(ra) # 80000586 <printf>
    8000223c:	00016497          	auipc	s1,0x16
    80002240:	88c48493          	addi	s1,s1,-1908 # 80017ac8 <proc+0x3e0>
    80002244:	00025917          	auipc	s2,0x25
    80002248:	48490913          	addi	s2,s2,1156 # 800276c8 <bcache+0x3c8>
    8000224c:	4b15                	li	s6,5
    8000224e:	00007997          	auipc	s3,0x7
    80002252:	00298993          	addi	s3,s3,2 # 80009250 <digits+0x210>
    80002256:	00007a97          	auipc	s5,0x7
    8000225a:	002a8a93          	addi	s5,s5,2 # 80009258 <digits+0x218>
    8000225e:	00007a17          	auipc	s4,0x7
    80002262:	e6aa0a13          	addi	s4,s4,-406 # 800090c8 <digits+0x88>
    80002266:	00007b97          	auipc	s7,0x7
    8000226a:	052b8b93          	addi	s7,s7,82 # 800092b8 <states.0>
    8000226e:	a00d                	j	80002290 <procdump+0x7a>
    80002270:	ed86a583          	lw	a1,-296(a3)
    80002274:	8556                	mv	a0,s5
    80002276:	ffffe097          	auipc	ra,0xffffe
    8000227a:	310080e7          	jalr	784(ra) # 80000586 <printf>
    8000227e:	8552                	mv	a0,s4
    80002280:	ffffe097          	auipc	ra,0xffffe
    80002284:	306080e7          	jalr	774(ra) # 80000586 <printf>
    80002288:	3f048493          	addi	s1,s1,1008
    8000228c:	03248263          	beq	s1,s2,800022b0 <procdump+0x9a>
    80002290:	86a6                	mv	a3,s1
    80002292:	ec04a783          	lw	a5,-320(s1)
    80002296:	dbed                	beqz	a5,80002288 <procdump+0x72>
    80002298:	864e                	mv	a2,s3
    8000229a:	fcfb6be3          	bltu	s6,a5,80002270 <procdump+0x5a>
    8000229e:	02079713          	slli	a4,a5,0x20
    800022a2:	01d75793          	srli	a5,a4,0x1d
    800022a6:	97de                	add	a5,a5,s7
    800022a8:	6390                	ld	a2,0(a5)
    800022aa:	f279                	bnez	a2,80002270 <procdump+0x5a>
    800022ac:	864e                	mv	a2,s3
    800022ae:	b7c9                	j	80002270 <procdump+0x5a>
    800022b0:	60a6                	ld	ra,72(sp)
    800022b2:	6406                	ld	s0,64(sp)
    800022b4:	74e2                	ld	s1,56(sp)
    800022b6:	7942                	ld	s2,48(sp)
    800022b8:	79a2                	ld	s3,40(sp)
    800022ba:	7a02                	ld	s4,32(sp)
    800022bc:	6ae2                	ld	s5,24(sp)
    800022be:	6b42                	ld	s6,16(sp)
    800022c0:	6ba2                	ld	s7,8(sp)
    800022c2:	6161                	addi	sp,sp,80
    800022c4:	8082                	ret

00000000800022c6 <procinfo>:
    800022c6:	7175                	addi	sp,sp,-144
    800022c8:	e506                	sd	ra,136(sp)
    800022ca:	e122                	sd	s0,128(sp)
    800022cc:	fca6                	sd	s1,120(sp)
    800022ce:	f8ca                	sd	s2,112(sp)
    800022d0:	f4ce                	sd	s3,104(sp)
    800022d2:	f0d2                	sd	s4,96(sp)
    800022d4:	ecd6                	sd	s5,88(sp)
    800022d6:	e8da                	sd	s6,80(sp)
    800022d8:	e4de                	sd	s7,72(sp)
    800022da:	0900                	addi	s0,sp,144
    800022dc:	89aa                	mv	s3,a0
    800022de:	00000097          	auipc	ra,0x0
    800022e2:	812080e7          	jalr	-2030(ra) # 80001af0 <myproc>
    800022e6:	8b2a                	mv	s6,a0
    800022e8:	00015917          	auipc	s2,0x15
    800022ec:	7e090913          	addi	s2,s2,2016 # 80017ac8 <proc+0x3e0>
    800022f0:	00025a17          	auipc	s4,0x25
    800022f4:	3d8a0a13          	addi	s4,s4,984 # 800276c8 <bcache+0x3c8>
    800022f8:	4a81                	li	s5,0
    800022fa:	4b81                	li	s7,0
    800022fc:	fa440493          	addi	s1,s0,-92
    80002300:	a089                	j	80002342 <procinfo+0x7c>
    80002302:	f8f42823          	sw	a5,-112(s0)
    80002306:	f9440793          	addi	a5,s0,-108
    8000230a:	874a                	mv	a4,s2
    8000230c:	00074683          	lbu	a3,0(a4)
    80002310:	00d78023          	sb	a3,0(a5)
    80002314:	0705                	addi	a4,a4,1
    80002316:	0785                	addi	a5,a5,1
    80002318:	fe979ae3          	bne	a5,s1,8000230c <procinfo+0x46>
    8000231c:	03800693          	li	a3,56
    80002320:	f7840613          	addi	a2,s0,-136
    80002324:	85ce                	mv	a1,s3
    80002326:	2d8b3503          	ld	a0,728(s6)
    8000232a:	fffff097          	auipc	ra,0xfffff
    8000232e:	40e080e7          	jalr	1038(ra) # 80001738 <copyout>
    80002332:	02054d63          	bltz	a0,8000236c <procinfo+0xa6>
    80002336:	03898993          	addi	s3,s3,56
    8000233a:	3f090913          	addi	s2,s2,1008
    8000233e:	03490863          	beq	s2,s4,8000236e <procinfo+0xa8>
    80002342:	ec092783          	lw	a5,-320(s2)
    80002346:	dbf5                	beqz	a5,8000233a <procinfo+0x74>
    80002348:	2a85                	addiw	s5,s5,1
    8000234a:	ed892703          	lw	a4,-296(s2)
    8000234e:	f6e42c23          	sw	a4,-136(s0)
    80002352:	f8f42023          	sw	a5,-128(s0)
    80002356:	ef093783          	ld	a5,-272(s2)
    8000235a:	f8f43423          	sd	a5,-120(s0)
    8000235e:	ee093703          	ld	a4,-288(s2)
    80002362:	87de                	mv	a5,s7
    80002364:	df59                	beqz	a4,80002302 <procinfo+0x3c>
    80002366:	2b872783          	lw	a5,696(a4)
    8000236a:	bf61                	j	80002302 <procinfo+0x3c>
    8000236c:	5afd                	li	s5,-1
    8000236e:	8556                	mv	a0,s5
    80002370:	60aa                	ld	ra,136(sp)
    80002372:	640a                	ld	s0,128(sp)
    80002374:	74e6                	ld	s1,120(sp)
    80002376:	7946                	ld	s2,112(sp)
    80002378:	79a6                	ld	s3,104(sp)
    8000237a:	7a06                	ld	s4,96(sp)
    8000237c:	6ae6                	ld	s5,88(sp)
    8000237e:	6b46                	ld	s6,80(sp)
    80002380:	6ba6                	ld	s7,72(sp)
    80002382:	6149                	addi	sp,sp,144
    80002384:	8082                	ret

0000000080002386 <mmrlistinit>:
    80002386:	7179                	addi	sp,sp,-48
    80002388:	f406                	sd	ra,40(sp)
    8000238a:	f022                	sd	s0,32(sp)
    8000238c:	ec26                	sd	s1,24(sp)
    8000238e:	e84a                	sd	s2,16(sp)
    80002390:	e44e                	sd	s3,8(sp)
    80002392:	1800                	addi	s0,sp,48
    80002394:	00007597          	auipc	a1,0x7
    80002398:	ed458593          	addi	a1,a1,-300 # 80009268 <digits+0x228>
    8000239c:	00010517          	auipc	a0,0x10
    800023a0:	33450513          	addi	a0,a0,820 # 800126d0 <listid_lock>
    800023a4:	ffffe097          	auipc	ra,0xffffe
    800023a8:	7e6080e7          	jalr	2022(ra) # 80000b8a <initlock>
    800023ac:	00010497          	auipc	s1,0x10
    800023b0:	33c48493          	addi	s1,s1,828 # 800126e8 <mmr_list>
    800023b4:	00007997          	auipc	s3,0x7
    800023b8:	ebc98993          	addi	s3,s3,-324 # 80009270 <digits+0x230>
    800023bc:	00015917          	auipc	s2,0x15
    800023c0:	32c90913          	addi	s2,s2,812 # 800176e8 <proc>
    800023c4:	85ce                	mv	a1,s3
    800023c6:	8526                	mv	a0,s1
    800023c8:	ffffe097          	auipc	ra,0xffffe
    800023cc:	7c2080e7          	jalr	1986(ra) # 80000b8a <initlock>
    800023d0:	0004ac23          	sw	zero,24(s1)
    800023d4:	02048493          	addi	s1,s1,32
    800023d8:	ff2496e3          	bne	s1,s2,800023c4 <mmrlistinit+0x3e>
    800023dc:	70a2                	ld	ra,40(sp)
    800023de:	7402                	ld	s0,32(sp)
    800023e0:	64e2                	ld	s1,24(sp)
    800023e2:	6942                	ld	s2,16(sp)
    800023e4:	69a2                	ld	s3,8(sp)
    800023e6:	6145                	addi	sp,sp,48
    800023e8:	8082                	ret

00000000800023ea <get_mmr_list>:
    800023ea:	1101                	addi	sp,sp,-32
    800023ec:	ec06                	sd	ra,24(sp)
    800023ee:	e822                	sd	s0,16(sp)
    800023f0:	e426                	sd	s1,8(sp)
    800023f2:	1000                	addi	s0,sp,32
    800023f4:	84aa                	mv	s1,a0
    800023f6:	00010517          	auipc	a0,0x10
    800023fa:	2da50513          	addi	a0,a0,730 # 800126d0 <listid_lock>
    800023fe:	fffff097          	auipc	ra,0xfffff
    80002402:	81c080e7          	jalr	-2020(ra) # 80000c1a <acquire>
    80002406:	0004871b          	sext.w	a4,s1
    8000240a:	27f00793          	li	a5,639
    8000240e:	02e7eb63          	bltu	a5,a4,80002444 <get_mmr_list+0x5a>
    80002412:	00549713          	slli	a4,s1,0x5
    80002416:	00010797          	auipc	a5,0x10
    8000241a:	2d278793          	addi	a5,a5,722 # 800126e8 <mmr_list>
    8000241e:	97ba                	add	a5,a5,a4
    80002420:	4f9c                	lw	a5,24(a5)
    80002422:	c38d                	beqz	a5,80002444 <get_mmr_list+0x5a>
    80002424:	00010517          	auipc	a0,0x10
    80002428:	2ac50513          	addi	a0,a0,684 # 800126d0 <listid_lock>
    8000242c:	fffff097          	auipc	ra,0xfffff
    80002430:	8a2080e7          	jalr	-1886(ra) # 80000cce <release>
    80002434:	00549513          	slli	a0,s1,0x5
    80002438:	00010797          	auipc	a5,0x10
    8000243c:	2b078793          	addi	a5,a5,688 # 800126e8 <mmr_list>
    80002440:	953e                	add	a0,a0,a5
    80002442:	a811                	j	80002456 <get_mmr_list+0x6c>
    80002444:	00010517          	auipc	a0,0x10
    80002448:	28c50513          	addi	a0,a0,652 # 800126d0 <listid_lock>
    8000244c:	fffff097          	auipc	ra,0xfffff
    80002450:	882080e7          	jalr	-1918(ra) # 80000cce <release>
    80002454:	4501                	li	a0,0
    80002456:	60e2                	ld	ra,24(sp)
    80002458:	6442                	ld	s0,16(sp)
    8000245a:	64a2                	ld	s1,8(sp)
    8000245c:	6105                	addi	sp,sp,32
    8000245e:	8082                	ret

0000000080002460 <dealloc_mmr_listid>:
    80002460:	1101                	addi	sp,sp,-32
    80002462:	ec06                	sd	ra,24(sp)
    80002464:	e822                	sd	s0,16(sp)
    80002466:	e426                	sd	s1,8(sp)
    80002468:	e04a                	sd	s2,0(sp)
    8000246a:	1000                	addi	s0,sp,32
    8000246c:	84aa                	mv	s1,a0
    8000246e:	00010917          	auipc	s2,0x10
    80002472:	26290913          	addi	s2,s2,610 # 800126d0 <listid_lock>
    80002476:	854a                	mv	a0,s2
    80002478:	ffffe097          	auipc	ra,0xffffe
    8000247c:	7a2080e7          	jalr	1954(ra) # 80000c1a <acquire>
    80002480:	0496                	slli	s1,s1,0x5
    80002482:	00010797          	auipc	a5,0x10
    80002486:	26678793          	addi	a5,a5,614 # 800126e8 <mmr_list>
    8000248a:	97a6                	add	a5,a5,s1
    8000248c:	0007ac23          	sw	zero,24(a5)
    80002490:	854a                	mv	a0,s2
    80002492:	fffff097          	auipc	ra,0xfffff
    80002496:	83c080e7          	jalr	-1988(ra) # 80000cce <release>
    8000249a:	60e2                	ld	ra,24(sp)
    8000249c:	6442                	ld	s0,16(sp)
    8000249e:	64a2                	ld	s1,8(sp)
    800024a0:	6902                	ld	s2,0(sp)
    800024a2:	6105                	addi	sp,sp,32
    800024a4:	8082                	ret

00000000800024a6 <freeproc>:
    800024a6:	711d                	addi	sp,sp,-96
    800024a8:	ec86                	sd	ra,88(sp)
    800024aa:	e8a2                	sd	s0,80(sp)
    800024ac:	e4a6                	sd	s1,72(sp)
    800024ae:	e0ca                	sd	s2,64(sp)
    800024b0:	fc4e                	sd	s3,56(sp)
    800024b2:	f852                	sd	s4,48(sp)
    800024b4:	f456                	sd	s5,40(sp)
    800024b6:	f05a                	sd	s6,32(sp)
    800024b8:	ec5e                	sd	s7,24(sp)
    800024ba:	e862                	sd	s8,16(sp)
    800024bc:	e466                	sd	s9,8(sp)
    800024be:	1080                	addi	s0,sp,96
    800024c0:	8a2a                	mv	s4,a0
    800024c2:	2e053503          	ld	a0,736(a0)
    800024c6:	c509                	beqz	a0,800024d0 <freeproc+0x2a>
    800024c8:	ffffe097          	auipc	ra,0xffffe
    800024cc:	51c080e7          	jalr	1308(ra) # 800009e4 <kfree>
    800024d0:	2e0a3023          	sd	zero,736(s4)
    800024d4:	038a0913          	addi	s2,s4,56
    800024d8:	2b8a0c13          	addi	s8,s4,696
    800024dc:	4b05                	li	s6,1
    800024de:	6b85                	lui	s7,0x1
    800024e0:	00010c97          	auipc	s9,0x10
    800024e4:	208c8c93          	addi	s9,s9,520 # 800126e8 <mmr_list>
    800024e8:	a851                	j	8000257c <freeproc+0xd6>
    800024ea:	00092503          	lw	a0,0(s2)
    800024ee:	0516                	slli	a0,a0,0x5
    800024f0:	9566                	add	a0,a0,s9
    800024f2:	ffffe097          	auipc	ra,0xffffe
    800024f6:	728080e7          	jalr	1832(ra) # 80000c1a <acquire>
    800024fa:	01093783          	ld	a5,16(s2)
    800024fe:	03278263          	beq	a5,s2,80002522 <freeproc+0x7c>
    80002502:	01893703          	ld	a4,24(s2)
    80002506:	ef98                	sd	a4,24(a5)
    80002508:	01093783          	ld	a5,16(s2)
    8000250c:	eb1c                	sd	a5,16(a4)
    8000250e:	00092503          	lw	a0,0(s2)
    80002512:	0516                	slli	a0,a0,0x5
    80002514:	9566                	add	a0,a0,s9
    80002516:	ffffe097          	auipc	ra,0xffffe
    8000251a:	7b8080e7          	jalr	1976(ra) # 80000cce <release>
    8000251e:	8aa6                	mv	s5,s1
    80002520:	a0bd                	j	8000258e <freeproc+0xe8>
    80002522:	00092503          	lw	a0,0(s2)
    80002526:	0516                	slli	a0,a0,0x5
    80002528:	9566                	add	a0,a0,s9
    8000252a:	ffffe097          	auipc	ra,0xffffe
    8000252e:	7a4080e7          	jalr	1956(ra) # 80000cce <release>
    80002532:	00092503          	lw	a0,0(s2)
    80002536:	00000097          	auipc	ra,0x0
    8000253a:	f2a080e7          	jalr	-214(ra) # 80002460 <dealloc_mmr_listid>
    8000253e:	a881                	j	8000258e <freeproc+0xe8>
    80002540:	94de                	add	s1,s1,s7
    80002542:	fe89a783          	lw	a5,-24(s3)
    80002546:	fe09b703          	ld	a4,-32(s3)
    8000254a:	97ba                	add	a5,a5,a4
    8000254c:	02f4f463          	bgeu	s1,a5,80002574 <freeproc+0xce>
    80002550:	85a6                	mv	a1,s1
    80002552:	2d8a3503          	ld	a0,728(s4)
    80002556:	fffff097          	auipc	ra,0xfffff
    8000255a:	b46080e7          	jalr	-1210(ra) # 8000109c <walkaddr>
    8000255e:	d16d                	beqz	a0,80002540 <freeproc+0x9a>
    80002560:	86d6                	mv	a3,s5
    80002562:	865a                	mv	a2,s6
    80002564:	85a6                	mv	a1,s1
    80002566:	2d8a3503          	ld	a0,728(s4)
    8000256a:	fffff097          	auipc	ra,0xfffff
    8000256e:	d3a080e7          	jalr	-710(ra) # 800012a4 <uvmunmap>
    80002572:	b7f9                	j	80002540 <freeproc+0x9a>
    80002574:	04090913          	addi	s2,s2,64
    80002578:	03890363          	beq	s2,s8,8000259e <freeproc+0xf8>
    8000257c:	89ca                	mv	s3,s2
    8000257e:	ff492a83          	lw	s5,-12(s2)
    80002582:	ff6a99e3          	bne	s5,s6,80002574 <freeproc+0xce>
    80002586:	ff092483          	lw	s1,-16(s2)
    8000258a:	8889                	andi	s1,s1,2
    8000258c:	dcb9                	beqz	s1,800024ea <freeproc+0x44>
    8000258e:	fe09b483          	ld	s1,-32(s3)
    80002592:	fe89a783          	lw	a5,-24(s3)
    80002596:	97a6                	add	a5,a5,s1
    80002598:	faf4ece3          	bltu	s1,a5,80002550 <freeproc+0xaa>
    8000259c:	bfe1                	j	80002574 <freeproc+0xce>
    8000259e:	2d8a3503          	ld	a0,728(s4)
    800025a2:	c519                	beqz	a0,800025b0 <freeproc+0x10a>
    800025a4:	2d0a3583          	ld	a1,720(s4)
    800025a8:	fffff097          	auipc	ra,0xfffff
    800025ac:	6a8080e7          	jalr	1704(ra) # 80001c50 <proc_freepagetable>
    800025b0:	2c0a3c23          	sd	zero,728(s4)
    800025b4:	2c0a3823          	sd	zero,720(s4)
    800025b8:	2a0a2c23          	sw	zero,696(s4)
    800025bc:	2c0a3023          	sd	zero,704(s4)
    800025c0:	3e0a0023          	sb	zero,992(s4)
    800025c4:	2a0a3423          	sd	zero,680(s4)
    800025c8:	2a0a2823          	sw	zero,688(s4)
    800025cc:	2a0a2a23          	sw	zero,692(s4)
    800025d0:	2a0a2023          	sw	zero,672(s4)
    800025d4:	60e6                	ld	ra,88(sp)
    800025d6:	6446                	ld	s0,80(sp)
    800025d8:	64a6                	ld	s1,72(sp)
    800025da:	6906                	ld	s2,64(sp)
    800025dc:	79e2                	ld	s3,56(sp)
    800025de:	7a42                	ld	s4,48(sp)
    800025e0:	7aa2                	ld	s5,40(sp)
    800025e2:	7b02                	ld	s6,32(sp)
    800025e4:	6be2                	ld	s7,24(sp)
    800025e6:	6c42                	ld	s8,16(sp)
    800025e8:	6ca2                	ld	s9,8(sp)
    800025ea:	6125                	addi	sp,sp,96
    800025ec:	8082                	ret

00000000800025ee <allocproc>:
    800025ee:	1101                	addi	sp,sp,-32
    800025f0:	ec06                	sd	ra,24(sp)
    800025f2:	e822                	sd	s0,16(sp)
    800025f4:	e426                	sd	s1,8(sp)
    800025f6:	e04a                	sd	s2,0(sp)
    800025f8:	1000                	addi	s0,sp,32
    800025fa:	00015497          	auipc	s1,0x15
    800025fe:	0ee48493          	addi	s1,s1,238 # 800176e8 <proc>
    80002602:	00025917          	auipc	s2,0x25
    80002606:	ce690913          	addi	s2,s2,-794 # 800272e8 <tickslock>
    8000260a:	8526                	mv	a0,s1
    8000260c:	ffffe097          	auipc	ra,0xffffe
    80002610:	60e080e7          	jalr	1550(ra) # 80000c1a <acquire>
    80002614:	2a04a783          	lw	a5,672(s1)
    80002618:	cf81                	beqz	a5,80002630 <allocproc+0x42>
    8000261a:	8526                	mv	a0,s1
    8000261c:	ffffe097          	auipc	ra,0xffffe
    80002620:	6b2080e7          	jalr	1714(ra) # 80000cce <release>
    80002624:	3f048493          	addi	s1,s1,1008
    80002628:	ff2491e3          	bne	s1,s2,8000260a <allocproc+0x1c>
    8000262c:	4481                	li	s1,0
    8000262e:	a085                	j	8000268e <allocproc+0xa0>
    80002630:	fffff097          	auipc	ra,0xfffff
    80002634:	53e080e7          	jalr	1342(ra) # 80001b6e <allocpid>
    80002638:	2aa4ac23          	sw	a0,696(s1)
    8000263c:	4785                	li	a5,1
    8000263e:	2af4a023          	sw	a5,672(s1)
    80002642:	ffffe097          	auipc	ra,0xffffe
    80002646:	4a0080e7          	jalr	1184(ra) # 80000ae2 <kalloc>
    8000264a:	892a                	mv	s2,a0
    8000264c:	2ea4b023          	sd	a0,736(s1)
    80002650:	c531                	beqz	a0,8000269c <allocproc+0xae>
    80002652:	8526                	mv	a0,s1
    80002654:	fffff097          	auipc	ra,0xfffff
    80002658:	560080e7          	jalr	1376(ra) # 80001bb4 <proc_pagetable>
    8000265c:	892a                	mv	s2,a0
    8000265e:	2ca4bc23          	sd	a0,728(s1)
    80002662:	c929                	beqz	a0,800026b4 <allocproc+0xc6>
    80002664:	07000613          	li	a2,112
    80002668:	4581                	li	a1,0
    8000266a:	2e848513          	addi	a0,s1,744
    8000266e:	ffffe097          	auipc	ra,0xffffe
    80002672:	6a8080e7          	jalr	1704(ra) # 80000d16 <memset>
    80002676:	fffff797          	auipc	a5,0xfffff
    8000267a:	4b278793          	addi	a5,a5,1202 # 80001b28 <forkret>
    8000267e:	2ef4b423          	sd	a5,744(s1)
    80002682:	2c84b783          	ld	a5,712(s1)
    80002686:	6705                	lui	a4,0x1
    80002688:	97ba                	add	a5,a5,a4
    8000268a:	2ef4b823          	sd	a5,752(s1)
    8000268e:	8526                	mv	a0,s1
    80002690:	60e2                	ld	ra,24(sp)
    80002692:	6442                	ld	s0,16(sp)
    80002694:	64a2                	ld	s1,8(sp)
    80002696:	6902                	ld	s2,0(sp)
    80002698:	6105                	addi	sp,sp,32
    8000269a:	8082                	ret
    8000269c:	8526                	mv	a0,s1
    8000269e:	00000097          	auipc	ra,0x0
    800026a2:	e08080e7          	jalr	-504(ra) # 800024a6 <freeproc>
    800026a6:	8526                	mv	a0,s1
    800026a8:	ffffe097          	auipc	ra,0xffffe
    800026ac:	626080e7          	jalr	1574(ra) # 80000cce <release>
    800026b0:	84ca                	mv	s1,s2
    800026b2:	bff1                	j	8000268e <allocproc+0xa0>
    800026b4:	8526                	mv	a0,s1
    800026b6:	00000097          	auipc	ra,0x0
    800026ba:	df0080e7          	jalr	-528(ra) # 800024a6 <freeproc>
    800026be:	8526                	mv	a0,s1
    800026c0:	ffffe097          	auipc	ra,0xffffe
    800026c4:	60e080e7          	jalr	1550(ra) # 80000cce <release>
    800026c8:	84ca                	mv	s1,s2
    800026ca:	b7d1                	j	8000268e <allocproc+0xa0>

00000000800026cc <userinit>:
    800026cc:	1101                	addi	sp,sp,-32
    800026ce:	ec06                	sd	ra,24(sp)
    800026d0:	e822                	sd	s0,16(sp)
    800026d2:	e426                	sd	s1,8(sp)
    800026d4:	1000                	addi	s0,sp,32
    800026d6:	00000097          	auipc	ra,0x0
    800026da:	f18080e7          	jalr	-232(ra) # 800025ee <allocproc>
    800026de:	84aa                	mv	s1,a0
    800026e0:	00008797          	auipc	a5,0x8
    800026e4:	94a7b423          	sd	a0,-1720(a5) # 8000a028 <initproc>
    800026e8:	03400613          	li	a2,52
    800026ec:	00007597          	auipc	a1,0x7
    800026f0:	20458593          	addi	a1,a1,516 # 800098f0 <initcode>
    800026f4:	2d853503          	ld	a0,728(a0)
    800026f8:	fffff097          	auipc	ra,0xfffff
    800026fc:	c90080e7          	jalr	-880(ra) # 80001388 <uvminit>
    80002700:	6785                	lui	a5,0x1
    80002702:	2cf4b823          	sd	a5,720(s1)
    80002706:	2e04b703          	ld	a4,736(s1)
    8000270a:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
    8000270e:	2e04b703          	ld	a4,736(s1)
    80002712:	fb1c                	sd	a5,48(a4)
    80002714:	4641                	li	a2,16
    80002716:	00007597          	auipc	a1,0x7
    8000271a:	b6258593          	addi	a1,a1,-1182 # 80009278 <digits+0x238>
    8000271e:	3e048513          	addi	a0,s1,992
    80002722:	ffffe097          	auipc	ra,0xffffe
    80002726:	73e080e7          	jalr	1854(ra) # 80000e60 <safestrcpy>
    8000272a:	00007517          	auipc	a0,0x7
    8000272e:	b5e50513          	addi	a0,a0,-1186 # 80009288 <digits+0x248>
    80002732:	00002097          	auipc	ra,0x2
    80002736:	0b6080e7          	jalr	182(ra) # 800047e8 <namei>
    8000273a:	3ca4bc23          	sd	a0,984(s1)
    8000273e:	478d                	li	a5,3
    80002740:	2af4a023          	sw	a5,672(s1)
    80002744:	020007b7          	lui	a5,0x2000
    80002748:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    8000274a:	07b6                	slli	a5,a5,0xd
    8000274c:	28f4bc23          	sd	a5,664(s1)
    80002750:	8526                	mv	a0,s1
    80002752:	ffffe097          	auipc	ra,0xffffe
    80002756:	57c080e7          	jalr	1404(ra) # 80000cce <release>
    8000275a:	60e2                	ld	ra,24(sp)
    8000275c:	6442                	ld	s0,16(sp)
    8000275e:	64a2                	ld	s1,8(sp)
    80002760:	6105                	addi	sp,sp,32
    80002762:	8082                	ret

0000000080002764 <fork>:
    80002764:	7159                	addi	sp,sp,-112
    80002766:	f486                	sd	ra,104(sp)
    80002768:	f0a2                	sd	s0,96(sp)
    8000276a:	eca6                	sd	s1,88(sp)
    8000276c:	e8ca                	sd	s2,80(sp)
    8000276e:	e4ce                	sd	s3,72(sp)
    80002770:	e0d2                	sd	s4,64(sp)
    80002772:	fc56                	sd	s5,56(sp)
    80002774:	f85a                	sd	s6,48(sp)
    80002776:	f45e                	sd	s7,40(sp)
    80002778:	f062                	sd	s8,32(sp)
    8000277a:	ec66                	sd	s9,24(sp)
    8000277c:	e86a                	sd	s10,16(sp)
    8000277e:	e46e                	sd	s11,8(sp)
    80002780:	1880                	addi	s0,sp,112
    80002782:	fffff097          	auipc	ra,0xfffff
    80002786:	36e080e7          	jalr	878(ra) # 80001af0 <myproc>
    8000278a:	89aa                	mv	s3,a0
    8000278c:	00000097          	auipc	ra,0x0
    80002790:	e62080e7          	jalr	-414(ra) # 800025ee <allocproc>
    80002794:	28050863          	beqz	a0,80002a24 <fork+0x2c0>
    80002798:	8b2a                	mv	s6,a0
    8000279a:	2d09b683          	ld	a3,720(s3)
    8000279e:	4601                	li	a2,0
    800027a0:	2d853583          	ld	a1,728(a0)
    800027a4:	2d89b503          	ld	a0,728(s3)
    800027a8:	fffff097          	auipc	ra,0xfffff
    800027ac:	dea080e7          	jalr	-534(ra) # 80001592 <uvmcopy>
    800027b0:	04054c63          	bltz	a0,80002808 <fork+0xa4>
    800027b4:	2d09b783          	ld	a5,720(s3)
    800027b8:	2cfb3823          	sd	a5,720(s6)
    800027bc:	2989b783          	ld	a5,664(s3)
    800027c0:	28fb3c23          	sd	a5,664(s6)
    800027c4:	2e09b683          	ld	a3,736(s3)
    800027c8:	87b6                	mv	a5,a3
    800027ca:	2e0b3703          	ld	a4,736(s6)
    800027ce:	12068693          	addi	a3,a3,288
    800027d2:	0007b803          	ld	a6,0(a5)
    800027d6:	6788                	ld	a0,8(a5)
    800027d8:	6b8c                	ld	a1,16(a5)
    800027da:	6f90                	ld	a2,24(a5)
    800027dc:	01073023          	sd	a6,0(a4)
    800027e0:	e708                	sd	a0,8(a4)
    800027e2:	eb0c                	sd	a1,16(a4)
    800027e4:	ef10                	sd	a2,24(a4)
    800027e6:	02078793          	addi	a5,a5,32
    800027ea:	02070713          	addi	a4,a4,32
    800027ee:	fed792e3          	bne	a5,a3,800027d2 <fork+0x6e>
    800027f2:	2e0b3783          	ld	a5,736(s6)
    800027f6:	0607b823          	sd	zero,112(a5)
    800027fa:	35898493          	addi	s1,s3,856
    800027fe:	358b0913          	addi	s2,s6,856
    80002802:	3d898a13          	addi	s4,s3,984
    80002806:	a00d                	j	80002828 <fork+0xc4>
    80002808:	855a                	mv	a0,s6
    8000280a:	00000097          	auipc	ra,0x0
    8000280e:	c9c080e7          	jalr	-868(ra) # 800024a6 <freeproc>
    80002812:	855a                	mv	a0,s6
    80002814:	ffffe097          	auipc	ra,0xffffe
    80002818:	4ba080e7          	jalr	1210(ra) # 80000cce <release>
    8000281c:	5d7d                	li	s10,-1
    8000281e:	a2dd                	j	80002a04 <fork+0x2a0>
    80002820:	04a1                	addi	s1,s1,8
    80002822:	0921                	addi	s2,s2,8
    80002824:	01448b63          	beq	s1,s4,8000283a <fork+0xd6>
    80002828:	6088                	ld	a0,0(s1)
    8000282a:	d97d                	beqz	a0,80002820 <fork+0xbc>
    8000282c:	00002097          	auipc	ra,0x2
    80002830:	656080e7          	jalr	1622(ra) # 80004e82 <filedup>
    80002834:	00a93023          	sd	a0,0(s2)
    80002838:	b7e5                	j	80002820 <fork+0xbc>
    8000283a:	3d89b503          	ld	a0,984(s3)
    8000283e:	00001097          	auipc	ra,0x1
    80002842:	7b0080e7          	jalr	1968(ra) # 80003fee <idup>
    80002846:	3cab3c23          	sd	a0,984(s6)
    8000284a:	4641                	li	a2,16
    8000284c:	3e098593          	addi	a1,s3,992
    80002850:	3e0b0513          	addi	a0,s6,992
    80002854:	ffffe097          	auipc	ra,0xffffe
    80002858:	60c080e7          	jalr	1548(ra) # 80000e60 <safestrcpy>
    8000285c:	2b8b2d03          	lw	s10,696(s6)
    80002860:	28000613          	li	a2,640
    80002864:	01898593          	addi	a1,s3,24
    80002868:	018b0513          	addi	a0,s6,24
    8000286c:	ffffe097          	auipc	ra,0xffffe
    80002870:	506080e7          	jalr	1286(ra) # 80000d72 <memmove>
    80002874:	038b0b93          	addi	s7,s6,56
    80002878:	03898a93          	addi	s5,s3,56
    8000287c:	2b898c93          	addi	s9,s3,696
    80002880:	4c05                	li	s8,1
    80002882:	6a05                	lui	s4,0x1
    80002884:	00010d97          	auipc	s11,0x10
    80002888:	e64d8d93          	addi	s11,s11,-412 # 800126e8 <mmr_list>
    8000288c:	a88d                	j	800028fe <fork+0x19a>
    8000288e:	9952                	add	s2,s2,s4
    80002890:	fe84a783          	lw	a5,-24(s1)
    80002894:	fe04b703          	ld	a4,-32(s1)
    80002898:	97ba                	add	a5,a5,a4
    8000289a:	04f97363          	bgeu	s2,a5,800028e0 <fork+0x17c>
    8000289e:	85ca                	mv	a1,s2
    800028a0:	2d89b503          	ld	a0,728(s3)
    800028a4:	ffffe097          	auipc	ra,0xffffe
    800028a8:	7f8080e7          	jalr	2040(ra) # 8000109c <walkaddr>
    800028ac:	d16d                	beqz	a0,8000288e <fork+0x12a>
    800028ae:	014906b3          	add	a3,s2,s4
    800028b2:	864a                	mv	a2,s2
    800028b4:	2d8b3583          	ld	a1,728(s6)
    800028b8:	2d89b503          	ld	a0,728(s3)
    800028bc:	fffff097          	auipc	ra,0xfffff
    800028c0:	cd6080e7          	jalr	-810(ra) # 80001592 <uvmcopy>
    800028c4:	fc0555e3          	bgez	a0,8000288e <fork+0x12a>
    800028c8:	855a                	mv	a0,s6
    800028ca:	00000097          	auipc	ra,0x0
    800028ce:	bdc080e7          	jalr	-1060(ra) # 800024a6 <freeproc>
    800028d2:	855a                	mv	a0,s6
    800028d4:	ffffe097          	auipc	ra,0xffffe
    800028d8:	3fa080e7          	jalr	1018(ra) # 80000cce <release>
    800028dc:	5d7d                	li	s10,-1
    800028de:	a21d                	j	80002a04 <fork+0x2a0>
    800028e0:	016bb423          	sd	s6,8(s7) # 1008 <_entry-0x7fffeff8>
    800028e4:	57fd                	li	a5,-1
    800028e6:	00fba023          	sw	a5,0(s7)
    800028ea:	017bb823          	sd	s7,16(s7)
    800028ee:	017bbc23          	sd	s7,24(s7)
    800028f2:	040b8b93          	addi	s7,s7,64
    800028f6:	040a8a93          	addi	s5,s5,64
    800028fa:	0d9a8363          	beq	s5,s9,800029c0 <fork+0x25c>
    800028fe:	84d6                	mv	s1,s5
    80002900:	ff4aa783          	lw	a5,-12(s5)
    80002904:	ff8797e3          	bne	a5,s8,800028f2 <fork+0x18e>
    80002908:	ff0aa783          	lw	a5,-16(s5)
    8000290c:	8b89                	andi	a5,a5,2
    8000290e:	cb89                	beqz	a5,80002920 <fork+0x1bc>
    80002910:	fe0ab903          	ld	s2,-32(s5)
    80002914:	fe8aa783          	lw	a5,-24(s5)
    80002918:	97ca                	add	a5,a5,s2
    8000291a:	f8f962e3          	bltu	s2,a5,8000289e <fork+0x13a>
    8000291e:	b7c9                	j	800028e0 <fork+0x17c>
    80002920:	fe0ab903          	ld	s2,-32(s5)
    80002924:	fe8aa783          	lw	a5,-24(s5)
    80002928:	97ca                	add	a5,a5,s2
    8000292a:	04f96763          	bltu	s2,a5,80002978 <fork+0x214>
    8000292e:	016bb423          	sd	s6,8(s7)
    80002932:	4088                	lw	a0,0(s1)
    80002934:	00aba023          	sw	a0,0(s7)
    80002938:	0516                	slli	a0,a0,0x5
    8000293a:	956e                	add	a0,a0,s11
    8000293c:	ffffe097          	auipc	ra,0xffffe
    80002940:	2de080e7          	jalr	734(ra) # 80000c1a <acquire>
    80002944:	689c                	ld	a5,16(s1)
    80002946:	00fbb823          	sd	a5,16(s7)
    8000294a:	0174b823          	sd	s7,16(s1)
    8000294e:	009bbc23          	sd	s1,24(s7)
    80002952:	6c9c                	ld	a5,24(s1)
    80002954:	06978363          	beq	a5,s1,800029ba <fork+0x256>
    80002958:	4088                	lw	a0,0(s1)
    8000295a:	0516                	slli	a0,a0,0x5
    8000295c:	956e                	add	a0,a0,s11
    8000295e:	ffffe097          	auipc	ra,0xffffe
    80002962:	370080e7          	jalr	880(ra) # 80000cce <release>
    80002966:	b771                	j	800028f2 <fork+0x18e>
    80002968:	9952                	add	s2,s2,s4
    8000296a:	fe84a783          	lw	a5,-24(s1)
    8000296e:	fe04b703          	ld	a4,-32(s1)
    80002972:	97ba                	add	a5,a5,a4
    80002974:	faf97de3          	bgeu	s2,a5,8000292e <fork+0x1ca>
    80002978:	85ca                	mv	a1,s2
    8000297a:	2d89b503          	ld	a0,728(s3)
    8000297e:	ffffe097          	auipc	ra,0xffffe
    80002982:	71e080e7          	jalr	1822(ra) # 8000109c <walkaddr>
    80002986:	d16d                	beqz	a0,80002968 <fork+0x204>
    80002988:	014906b3          	add	a3,s2,s4
    8000298c:	864a                	mv	a2,s2
    8000298e:	2d8b3583          	ld	a1,728(s6)
    80002992:	2d89b503          	ld	a0,728(s3)
    80002996:	fffff097          	auipc	ra,0xfffff
    8000299a:	cd0080e7          	jalr	-816(ra) # 80001666 <uvmcopyshared>
    8000299e:	fc0555e3          	bgez	a0,80002968 <fork+0x204>
    800029a2:	855a                	mv	a0,s6
    800029a4:	00000097          	auipc	ra,0x0
    800029a8:	b02080e7          	jalr	-1278(ra) # 800024a6 <freeproc>
    800029ac:	855a                	mv	a0,s6
    800029ae:	ffffe097          	auipc	ra,0xffffe
    800029b2:	320080e7          	jalr	800(ra) # 80000cce <release>
    800029b6:	5d7d                	li	s10,-1
    800029b8:	a0b1                	j	80002a04 <fork+0x2a0>
    800029ba:	0174bc23          	sd	s7,24(s1)
    800029be:	bf69                	j	80002958 <fork+0x1f4>
    800029c0:	855a                	mv	a0,s6
    800029c2:	ffffe097          	auipc	ra,0xffffe
    800029c6:	30c080e7          	jalr	780(ra) # 80000cce <release>
    800029ca:	00010497          	auipc	s1,0x10
    800029ce:	8ee48493          	addi	s1,s1,-1810 # 800122b8 <wait_lock>
    800029d2:	8526                	mv	a0,s1
    800029d4:	ffffe097          	auipc	ra,0xffffe
    800029d8:	246080e7          	jalr	582(ra) # 80000c1a <acquire>
    800029dc:	2d3b3023          	sd	s3,704(s6)
    800029e0:	8526                	mv	a0,s1
    800029e2:	ffffe097          	auipc	ra,0xffffe
    800029e6:	2ec080e7          	jalr	748(ra) # 80000cce <release>
    800029ea:	855a                	mv	a0,s6
    800029ec:	ffffe097          	auipc	ra,0xffffe
    800029f0:	22e080e7          	jalr	558(ra) # 80000c1a <acquire>
    800029f4:	478d                	li	a5,3
    800029f6:	2afb2023          	sw	a5,672(s6)
    800029fa:	855a                	mv	a0,s6
    800029fc:	ffffe097          	auipc	ra,0xffffe
    80002a00:	2d2080e7          	jalr	722(ra) # 80000cce <release>
    80002a04:	856a                	mv	a0,s10
    80002a06:	70a6                	ld	ra,104(sp)
    80002a08:	7406                	ld	s0,96(sp)
    80002a0a:	64e6                	ld	s1,88(sp)
    80002a0c:	6946                	ld	s2,80(sp)
    80002a0e:	69a6                	ld	s3,72(sp)
    80002a10:	6a06                	ld	s4,64(sp)
    80002a12:	7ae2                	ld	s5,56(sp)
    80002a14:	7b42                	ld	s6,48(sp)
    80002a16:	7ba2                	ld	s7,40(sp)
    80002a18:	7c02                	ld	s8,32(sp)
    80002a1a:	6ce2                	ld	s9,24(sp)
    80002a1c:	6d42                	ld	s10,16(sp)
    80002a1e:	6da2                	ld	s11,8(sp)
    80002a20:	6165                	addi	sp,sp,112
    80002a22:	8082                	ret
    80002a24:	5d7d                	li	s10,-1
    80002a26:	bff9                	j	80002a04 <fork+0x2a0>

0000000080002a28 <wait>:
    80002a28:	715d                	addi	sp,sp,-80
    80002a2a:	e486                	sd	ra,72(sp)
    80002a2c:	e0a2                	sd	s0,64(sp)
    80002a2e:	fc26                	sd	s1,56(sp)
    80002a30:	f84a                	sd	s2,48(sp)
    80002a32:	f44e                	sd	s3,40(sp)
    80002a34:	f052                	sd	s4,32(sp)
    80002a36:	ec56                	sd	s5,24(sp)
    80002a38:	e85a                	sd	s6,16(sp)
    80002a3a:	e45e                	sd	s7,8(sp)
    80002a3c:	e062                	sd	s8,0(sp)
    80002a3e:	0880                	addi	s0,sp,80
    80002a40:	8b2a                	mv	s6,a0
    80002a42:	fffff097          	auipc	ra,0xfffff
    80002a46:	0ae080e7          	jalr	174(ra) # 80001af0 <myproc>
    80002a4a:	892a                	mv	s2,a0
    80002a4c:	00010517          	auipc	a0,0x10
    80002a50:	86c50513          	addi	a0,a0,-1940 # 800122b8 <wait_lock>
    80002a54:	ffffe097          	auipc	ra,0xffffe
    80002a58:	1c6080e7          	jalr	454(ra) # 80000c1a <acquire>
    80002a5c:	4b81                	li	s7,0
    80002a5e:	4a15                	li	s4,5
    80002a60:	4a85                	li	s5,1
    80002a62:	00025997          	auipc	s3,0x25
    80002a66:	88698993          	addi	s3,s3,-1914 # 800272e8 <tickslock>
    80002a6a:	00010c17          	auipc	s8,0x10
    80002a6e:	84ec0c13          	addi	s8,s8,-1970 # 800122b8 <wait_lock>
    80002a72:	875e                	mv	a4,s7
    80002a74:	00015497          	auipc	s1,0x15
    80002a78:	c7448493          	addi	s1,s1,-908 # 800176e8 <proc>
    80002a7c:	a0bd                	j	80002aea <wait+0xc2>
    80002a7e:	2b84a983          	lw	s3,696(s1)
    80002a82:	000b0e63          	beqz	s6,80002a9e <wait+0x76>
    80002a86:	4691                	li	a3,4
    80002a88:	2b448613          	addi	a2,s1,692
    80002a8c:	85da                	mv	a1,s6
    80002a8e:	2d893503          	ld	a0,728(s2)
    80002a92:	fffff097          	auipc	ra,0xfffff
    80002a96:	ca6080e7          	jalr	-858(ra) # 80001738 <copyout>
    80002a9a:	02054563          	bltz	a0,80002ac4 <wait+0x9c>
    80002a9e:	8526                	mv	a0,s1
    80002aa0:	00000097          	auipc	ra,0x0
    80002aa4:	a06080e7          	jalr	-1530(ra) # 800024a6 <freeproc>
    80002aa8:	8526                	mv	a0,s1
    80002aaa:	ffffe097          	auipc	ra,0xffffe
    80002aae:	224080e7          	jalr	548(ra) # 80000cce <release>
    80002ab2:	00010517          	auipc	a0,0x10
    80002ab6:	80650513          	addi	a0,a0,-2042 # 800122b8 <wait_lock>
    80002aba:	ffffe097          	auipc	ra,0xffffe
    80002abe:	214080e7          	jalr	532(ra) # 80000cce <release>
    80002ac2:	a0ad                	j	80002b2c <wait+0x104>
    80002ac4:	8526                	mv	a0,s1
    80002ac6:	ffffe097          	auipc	ra,0xffffe
    80002aca:	208080e7          	jalr	520(ra) # 80000cce <release>
    80002ace:	0000f517          	auipc	a0,0xf
    80002ad2:	7ea50513          	addi	a0,a0,2026 # 800122b8 <wait_lock>
    80002ad6:	ffffe097          	auipc	ra,0xffffe
    80002ada:	1f8080e7          	jalr	504(ra) # 80000cce <release>
    80002ade:	59fd                	li	s3,-1
    80002ae0:	a0b1                	j	80002b2c <wait+0x104>
    80002ae2:	3f048493          	addi	s1,s1,1008
    80002ae6:	03348663          	beq	s1,s3,80002b12 <wait+0xea>
    80002aea:	2c04b783          	ld	a5,704(s1)
    80002aee:	ff279ae3          	bne	a5,s2,80002ae2 <wait+0xba>
    80002af2:	8526                	mv	a0,s1
    80002af4:	ffffe097          	auipc	ra,0xffffe
    80002af8:	126080e7          	jalr	294(ra) # 80000c1a <acquire>
    80002afc:	2a04a783          	lw	a5,672(s1)
    80002b00:	f7478fe3          	beq	a5,s4,80002a7e <wait+0x56>
    80002b04:	8526                	mv	a0,s1
    80002b06:	ffffe097          	auipc	ra,0xffffe
    80002b0a:	1c8080e7          	jalr	456(ra) # 80000cce <release>
    80002b0e:	8756                	mv	a4,s5
    80002b10:	bfc9                	j	80002ae2 <wait+0xba>
    80002b12:	c701                	beqz	a4,80002b1a <wait+0xf2>
    80002b14:	2b092783          	lw	a5,688(s2)
    80002b18:	c79d                	beqz	a5,80002b46 <wait+0x11e>
    80002b1a:	0000f517          	auipc	a0,0xf
    80002b1e:	79e50513          	addi	a0,a0,1950 # 800122b8 <wait_lock>
    80002b22:	ffffe097          	auipc	ra,0xffffe
    80002b26:	1ac080e7          	jalr	428(ra) # 80000cce <release>
    80002b2a:	59fd                	li	s3,-1
    80002b2c:	854e                	mv	a0,s3
    80002b2e:	60a6                	ld	ra,72(sp)
    80002b30:	6406                	ld	s0,64(sp)
    80002b32:	74e2                	ld	s1,56(sp)
    80002b34:	7942                	ld	s2,48(sp)
    80002b36:	79a2                	ld	s3,40(sp)
    80002b38:	7a02                	ld	s4,32(sp)
    80002b3a:	6ae2                	ld	s5,24(sp)
    80002b3c:	6b42                	ld	s6,16(sp)
    80002b3e:	6ba2                	ld	s7,8(sp)
    80002b40:	6c02                	ld	s8,0(sp)
    80002b42:	6161                	addi	sp,sp,80
    80002b44:	8082                	ret
    80002b46:	85e2                	mv	a1,s8
    80002b48:	854a                	mv	a0,s2
    80002b4a:	fffff097          	auipc	ra,0xfffff
    80002b4e:	38e080e7          	jalr	910(ra) # 80001ed8 <sleep>
    80002b52:	b705                	j	80002a72 <wait+0x4a>

0000000080002b54 <alloc_mmr_listid>:
    80002b54:	1101                	addi	sp,sp,-32
    80002b56:	ec06                	sd	ra,24(sp)
    80002b58:	e822                	sd	s0,16(sp)
    80002b5a:	e426                	sd	s1,8(sp)
    80002b5c:	1000                	addi	s0,sp,32
    80002b5e:	00010517          	auipc	a0,0x10
    80002b62:	b7250513          	addi	a0,a0,-1166 # 800126d0 <listid_lock>
    80002b66:	ffffe097          	auipc	ra,0xffffe
    80002b6a:	0b4080e7          	jalr	180(ra) # 80000c1a <acquire>
    80002b6e:	00010797          	auipc	a5,0x10
    80002b72:	b9278793          	addi	a5,a5,-1134 # 80012700 <mmr_list+0x18>
    80002b76:	4481                	li	s1,0
    80002b78:	28000693          	li	a3,640
    80002b7c:	4398                	lw	a4,0(a5)
    80002b7e:	cb01                	beqz	a4,80002b8e <alloc_mmr_listid+0x3a>
    80002b80:	2485                	addiw	s1,s1,1
    80002b82:	02078793          	addi	a5,a5,32
    80002b86:	fed49be3          	bne	s1,a3,80002b7c <alloc_mmr_listid+0x28>
    80002b8a:	54fd                	li	s1,-1
    80002b8c:	a811                	j	80002ba0 <alloc_mmr_listid+0x4c>
    80002b8e:	00549713          	slli	a4,s1,0x5
    80002b92:	00010797          	auipc	a5,0x10
    80002b96:	b5678793          	addi	a5,a5,-1194 # 800126e8 <mmr_list>
    80002b9a:	97ba                	add	a5,a5,a4
    80002b9c:	4705                	li	a4,1
    80002b9e:	cf98                	sw	a4,24(a5)
    80002ba0:	00010517          	auipc	a0,0x10
    80002ba4:	b3050513          	addi	a0,a0,-1232 # 800126d0 <listid_lock>
    80002ba8:	ffffe097          	auipc	ra,0xffffe
    80002bac:	126080e7          	jalr	294(ra) # 80000cce <release>
    80002bb0:	8526                	mv	a0,s1
    80002bb2:	60e2                	ld	ra,24(sp)
    80002bb4:	6442                	ld	s0,16(sp)
    80002bb6:	64a2                	ld	s1,8(sp)
    80002bb8:	6105                	addi	sp,sp,32
    80002bba:	8082                	ret

0000000080002bbc <swtch>:
    80002bbc:	00153023          	sd	ra,0(a0)
    80002bc0:	00253423          	sd	sp,8(a0)
    80002bc4:	e900                	sd	s0,16(a0)
    80002bc6:	ed04                	sd	s1,24(a0)
    80002bc8:	03253023          	sd	s2,32(a0)
    80002bcc:	03353423          	sd	s3,40(a0)
    80002bd0:	03453823          	sd	s4,48(a0)
    80002bd4:	03553c23          	sd	s5,56(a0)
    80002bd8:	05653023          	sd	s6,64(a0)
    80002bdc:	05753423          	sd	s7,72(a0)
    80002be0:	05853823          	sd	s8,80(a0)
    80002be4:	05953c23          	sd	s9,88(a0)
    80002be8:	07a53023          	sd	s10,96(a0)
    80002bec:	07b53423          	sd	s11,104(a0)
    80002bf0:	0005b083          	ld	ra,0(a1)
    80002bf4:	0085b103          	ld	sp,8(a1)
    80002bf8:	6980                	ld	s0,16(a1)
    80002bfa:	6d84                	ld	s1,24(a1)
    80002bfc:	0205b903          	ld	s2,32(a1)
    80002c00:	0285b983          	ld	s3,40(a1)
    80002c04:	0305ba03          	ld	s4,48(a1)
    80002c08:	0385ba83          	ld	s5,56(a1)
    80002c0c:	0405bb03          	ld	s6,64(a1)
    80002c10:	0485bb83          	ld	s7,72(a1)
    80002c14:	0505bc03          	ld	s8,80(a1)
    80002c18:	0585bc83          	ld	s9,88(a1)
    80002c1c:	0605bd03          	ld	s10,96(a1)
    80002c20:	0685bd83          	ld	s11,104(a1)
    80002c24:	8082                	ret

0000000080002c26 <trapinit>:
    80002c26:	1141                	addi	sp,sp,-16
    80002c28:	e406                	sd	ra,8(sp)
    80002c2a:	e022                	sd	s0,0(sp)
    80002c2c:	0800                	addi	s0,sp,16
    80002c2e:	00006597          	auipc	a1,0x6
    80002c32:	6ba58593          	addi	a1,a1,1722 # 800092e8 <states.0+0x30>
    80002c36:	00024517          	auipc	a0,0x24
    80002c3a:	6b250513          	addi	a0,a0,1714 # 800272e8 <tickslock>
    80002c3e:	ffffe097          	auipc	ra,0xffffe
    80002c42:	f4c080e7          	jalr	-180(ra) # 80000b8a <initlock>
    80002c46:	60a2                	ld	ra,8(sp)
    80002c48:	6402                	ld	s0,0(sp)
    80002c4a:	0141                	addi	sp,sp,16
    80002c4c:	8082                	ret

0000000080002c4e <trapinithart>:
    80002c4e:	1141                	addi	sp,sp,-16
    80002c50:	e422                	sd	s0,8(sp)
    80002c52:	0800                	addi	s0,sp,16
    80002c54:	00004797          	auipc	a5,0x4
    80002c58:	c2c78793          	addi	a5,a5,-980 # 80006880 <kernelvec>
    80002c5c:	10579073          	csrw	stvec,a5
    80002c60:	6422                	ld	s0,8(sp)
    80002c62:	0141                	addi	sp,sp,16
    80002c64:	8082                	ret

0000000080002c66 <is_valid_address>:
    80002c66:	1141                	addi	sp,sp,-16
    80002c68:	e422                	sd	s0,8(sp)
    80002c6a:	0800                	addi	s0,sp,16
    80002c6c:	2d05b783          	ld	a5,720(a1)
    80002c70:	02f56a63          	bltu	a0,a5,80002ca4 <is_valid_address+0x3e>
    80002c74:	01858793          	addi	a5,a1,24
    80002c78:	29858593          	addi	a1,a1,664
    80002c7c:	a029                	j	80002c86 <is_valid_address+0x20>
    80002c7e:	04078793          	addi	a5,a5,64
    80002c82:	00b78d63          	beq	a5,a1,80002c9c <is_valid_address+0x36>
    80002c86:	4bd8                	lw	a4,20(a5)
    80002c88:	db7d                	beqz	a4,80002c7e <is_valid_address+0x18>
    80002c8a:	6398                	ld	a4,0(a5)
    80002c8c:	fee569e3          	bltu	a0,a4,80002c7e <is_valid_address+0x18>
    80002c90:	4794                	lw	a3,8(a5)
    80002c92:	9736                	add	a4,a4,a3
    80002c94:	fee575e3          	bgeu	a0,a4,80002c7e <is_valid_address+0x18>
    80002c98:	4505                	li	a0,1
    80002c9a:	a011                	j	80002c9e <is_valid_address+0x38>
    80002c9c:	4501                	li	a0,0
    80002c9e:	6422                	ld	s0,8(sp)
    80002ca0:	0141                	addi	sp,sp,16
    80002ca2:	8082                	ret
    80002ca4:	4505                	li	a0,1
    80002ca6:	bfe5                	j	80002c9e <is_valid_address+0x38>

0000000080002ca8 <usertrapret>:
    80002ca8:	1141                	addi	sp,sp,-16
    80002caa:	e406                	sd	ra,8(sp)
    80002cac:	e022                	sd	s0,0(sp)
    80002cae:	0800                	addi	s0,sp,16
    80002cb0:	fffff097          	auipc	ra,0xfffff
    80002cb4:	e40080e7          	jalr	-448(ra) # 80001af0 <myproc>
    80002cb8:	100027f3          	csrr	a5,sstatus
    80002cbc:	9bf5                	andi	a5,a5,-3
    80002cbe:	10079073          	csrw	sstatus,a5
    80002cc2:	00005697          	auipc	a3,0x5
    80002cc6:	33e68693          	addi	a3,a3,830 # 80008000 <_trampoline>
    80002cca:	00005717          	auipc	a4,0x5
    80002cce:	33670713          	addi	a4,a4,822 # 80008000 <_trampoline>
    80002cd2:	8f15                	sub	a4,a4,a3
    80002cd4:	040007b7          	lui	a5,0x4000
    80002cd8:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002cda:	07b2                	slli	a5,a5,0xc
    80002cdc:	973e                	add	a4,a4,a5
    80002cde:	10571073          	csrw	stvec,a4
    80002ce2:	2e053703          	ld	a4,736(a0)
    80002ce6:	18002673          	csrr	a2,satp
    80002cea:	e310                	sd	a2,0(a4)
    80002cec:	2e053603          	ld	a2,736(a0)
    80002cf0:	2c853703          	ld	a4,712(a0)
    80002cf4:	6585                	lui	a1,0x1
    80002cf6:	972e                	add	a4,a4,a1
    80002cf8:	e618                	sd	a4,8(a2)
    80002cfa:	2e053703          	ld	a4,736(a0)
    80002cfe:	00000617          	auipc	a2,0x0
    80002d02:	13e60613          	addi	a2,a2,318 # 80002e3c <usertrap>
    80002d06:	eb10                	sd	a2,16(a4)
    80002d08:	2e053703          	ld	a4,736(a0)
    80002d0c:	8612                	mv	a2,tp
    80002d0e:	f310                	sd	a2,32(a4)
    80002d10:	10002773          	csrr	a4,sstatus
    80002d14:	eff77713          	andi	a4,a4,-257
    80002d18:	02076713          	ori	a4,a4,32
    80002d1c:	10071073          	csrw	sstatus,a4
    80002d20:	2e053703          	ld	a4,736(a0)
    80002d24:	6f18                	ld	a4,24(a4)
    80002d26:	14171073          	csrw	sepc,a4
    80002d2a:	2d853583          	ld	a1,728(a0)
    80002d2e:	81b1                	srli	a1,a1,0xc
    80002d30:	00005717          	auipc	a4,0x5
    80002d34:	36070713          	addi	a4,a4,864 # 80008090 <userret>
    80002d38:	8f15                	sub	a4,a4,a3
    80002d3a:	97ba                	add	a5,a5,a4
    80002d3c:	577d                	li	a4,-1
    80002d3e:	177e                	slli	a4,a4,0x3f
    80002d40:	8dd9                	or	a1,a1,a4
    80002d42:	02000537          	lui	a0,0x2000
    80002d46:	157d                	addi	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    80002d48:	0536                	slli	a0,a0,0xd
    80002d4a:	9782                	jalr	a5
    80002d4c:	60a2                	ld	ra,8(sp)
    80002d4e:	6402                	ld	s0,0(sp)
    80002d50:	0141                	addi	sp,sp,16
    80002d52:	8082                	ret

0000000080002d54 <clockintr>:
    80002d54:	1101                	addi	sp,sp,-32
    80002d56:	ec06                	sd	ra,24(sp)
    80002d58:	e822                	sd	s0,16(sp)
    80002d5a:	e426                	sd	s1,8(sp)
    80002d5c:	1000                	addi	s0,sp,32
    80002d5e:	00024497          	auipc	s1,0x24
    80002d62:	58a48493          	addi	s1,s1,1418 # 800272e8 <tickslock>
    80002d66:	8526                	mv	a0,s1
    80002d68:	ffffe097          	auipc	ra,0xffffe
    80002d6c:	eb2080e7          	jalr	-334(ra) # 80000c1a <acquire>
    80002d70:	00007517          	auipc	a0,0x7
    80002d74:	2c050513          	addi	a0,a0,704 # 8000a030 <ticks>
    80002d78:	411c                	lw	a5,0(a0)
    80002d7a:	2785                	addiw	a5,a5,1
    80002d7c:	c11c                	sw	a5,0(a0)
    80002d7e:	fffff097          	auipc	ra,0xfffff
    80002d82:	1c0080e7          	jalr	448(ra) # 80001f3e <wakeup>
    80002d86:	8526                	mv	a0,s1
    80002d88:	ffffe097          	auipc	ra,0xffffe
    80002d8c:	f46080e7          	jalr	-186(ra) # 80000cce <release>
    80002d90:	60e2                	ld	ra,24(sp)
    80002d92:	6442                	ld	s0,16(sp)
    80002d94:	64a2                	ld	s1,8(sp)
    80002d96:	6105                	addi	sp,sp,32
    80002d98:	8082                	ret

0000000080002d9a <devintr>:
    80002d9a:	1101                	addi	sp,sp,-32
    80002d9c:	ec06                	sd	ra,24(sp)
    80002d9e:	e822                	sd	s0,16(sp)
    80002da0:	e426                	sd	s1,8(sp)
    80002da2:	1000                	addi	s0,sp,32
    80002da4:	14202773          	csrr	a4,scause
    80002da8:	00074d63          	bltz	a4,80002dc2 <devintr+0x28>
    80002dac:	57fd                	li	a5,-1
    80002dae:	17fe                	slli	a5,a5,0x3f
    80002db0:	0785                	addi	a5,a5,1
    80002db2:	4501                	li	a0,0
    80002db4:	06f70363          	beq	a4,a5,80002e1a <devintr+0x80>
    80002db8:	60e2                	ld	ra,24(sp)
    80002dba:	6442                	ld	s0,16(sp)
    80002dbc:	64a2                	ld	s1,8(sp)
    80002dbe:	6105                	addi	sp,sp,32
    80002dc0:	8082                	ret
    80002dc2:	0ff77793          	zext.b	a5,a4
    80002dc6:	46a5                	li	a3,9
    80002dc8:	fed792e3          	bne	a5,a3,80002dac <devintr+0x12>
    80002dcc:	00004097          	auipc	ra,0x4
    80002dd0:	bbc080e7          	jalr	-1092(ra) # 80006988 <plic_claim>
    80002dd4:	84aa                	mv	s1,a0
    80002dd6:	47a9                	li	a5,10
    80002dd8:	02f50763          	beq	a0,a5,80002e06 <devintr+0x6c>
    80002ddc:	4785                	li	a5,1
    80002dde:	02f50963          	beq	a0,a5,80002e10 <devintr+0x76>
    80002de2:	4505                	li	a0,1
    80002de4:	d8f1                	beqz	s1,80002db8 <devintr+0x1e>
    80002de6:	85a6                	mv	a1,s1
    80002de8:	00006517          	auipc	a0,0x6
    80002dec:	50850513          	addi	a0,a0,1288 # 800092f0 <states.0+0x38>
    80002df0:	ffffd097          	auipc	ra,0xffffd
    80002df4:	796080e7          	jalr	1942(ra) # 80000586 <printf>
    80002df8:	8526                	mv	a0,s1
    80002dfa:	00004097          	auipc	ra,0x4
    80002dfe:	bb2080e7          	jalr	-1102(ra) # 800069ac <plic_complete>
    80002e02:	4505                	li	a0,1
    80002e04:	bf55                	j	80002db8 <devintr+0x1e>
    80002e06:	ffffe097          	auipc	ra,0xffffe
    80002e0a:	b8e080e7          	jalr	-1138(ra) # 80000994 <uartintr>
    80002e0e:	b7ed                	j	80002df8 <devintr+0x5e>
    80002e10:	00004097          	auipc	ra,0x4
    80002e14:	028080e7          	jalr	40(ra) # 80006e38 <virtio_disk_intr>
    80002e18:	b7c5                	j	80002df8 <devintr+0x5e>
    80002e1a:	fffff097          	auipc	ra,0xfffff
    80002e1e:	caa080e7          	jalr	-854(ra) # 80001ac4 <cpuid>
    80002e22:	c901                	beqz	a0,80002e32 <devintr+0x98>
    80002e24:	144027f3          	csrr	a5,sip
    80002e28:	9bf5                	andi	a5,a5,-3
    80002e2a:	14479073          	csrw	sip,a5
    80002e2e:	4509                	li	a0,2
    80002e30:	b761                	j	80002db8 <devintr+0x1e>
    80002e32:	00000097          	auipc	ra,0x0
    80002e36:	f22080e7          	jalr	-222(ra) # 80002d54 <clockintr>
    80002e3a:	b7ed                	j	80002e24 <devintr+0x8a>

0000000080002e3c <usertrap>:
    80002e3c:	1101                	addi	sp,sp,-32
    80002e3e:	ec06                	sd	ra,24(sp)
    80002e40:	e822                	sd	s0,16(sp)
    80002e42:	e426                	sd	s1,8(sp)
    80002e44:	e04a                	sd	s2,0(sp)
    80002e46:	1000                	addi	s0,sp,32
    80002e48:	fffff097          	auipc	ra,0xfffff
    80002e4c:	ca8080e7          	jalr	-856(ra) # 80001af0 <myproc>
    80002e50:	100027f3          	csrr	a5,sstatus
    80002e54:	1007f793          	andi	a5,a5,256
    80002e58:	e3b5                	bnez	a5,80002ebc <usertrap+0x80>
    80002e5a:	84aa                	mv	s1,a0
    80002e5c:	00004797          	auipc	a5,0x4
    80002e60:	a2478793          	addi	a5,a5,-1500 # 80006880 <kernelvec>
    80002e64:	10579073          	csrw	stvec,a5
    80002e68:	2e053783          	ld	a5,736(a0)
    80002e6c:	14102773          	csrr	a4,sepc
    80002e70:	ef98                	sd	a4,24(a5)
    80002e72:	14202773          	csrr	a4,scause
    80002e76:	47a1                	li	a5,8
    80002e78:	06f71063          	bne	a4,a5,80002ed8 <usertrap+0x9c>
    80002e7c:	2b052783          	lw	a5,688(a0)
    80002e80:	e7b1                	bnez	a5,80002ecc <usertrap+0x90>
    80002e82:	2e04b703          	ld	a4,736(s1)
    80002e86:	6f1c                	ld	a5,24(a4)
    80002e88:	0791                	addi	a5,a5,4
    80002e8a:	ef1c                	sd	a5,24(a4)
    80002e8c:	100027f3          	csrr	a5,sstatus
    80002e90:	0027e793          	ori	a5,a5,2
    80002e94:	10079073          	csrw	sstatus,a5
    80002e98:	00000097          	auipc	ra,0x0
    80002e9c:	3ac080e7          	jalr	940(ra) # 80003244 <syscall>
    80002ea0:	2b04a783          	lw	a5,688(s1)
    80002ea4:	12079763          	bnez	a5,80002fd2 <usertrap+0x196>
    80002ea8:	00000097          	auipc	ra,0x0
    80002eac:	e00080e7          	jalr	-512(ra) # 80002ca8 <usertrapret>
    80002eb0:	60e2                	ld	ra,24(sp)
    80002eb2:	6442                	ld	s0,16(sp)
    80002eb4:	64a2                	ld	s1,8(sp)
    80002eb6:	6902                	ld	s2,0(sp)
    80002eb8:	6105                	addi	sp,sp,32
    80002eba:	8082                	ret
    80002ebc:	00006517          	auipc	a0,0x6
    80002ec0:	45450513          	addi	a0,a0,1108 # 80009310 <states.0+0x58>
    80002ec4:	ffffd097          	auipc	ra,0xffffd
    80002ec8:	678080e7          	jalr	1656(ra) # 8000053c <panic>
    80002ecc:	557d                	li	a0,-1
    80002ece:	fffff097          	auipc	ra,0xfffff
    80002ed2:	148080e7          	jalr	328(ra) # 80002016 <exit>
    80002ed6:	b775                	j	80002e82 <usertrap+0x46>
    80002ed8:	00000097          	auipc	ra,0x0
    80002edc:	ec2080e7          	jalr	-318(ra) # 80002d9a <devintr>
    80002ee0:	892a                	mv	s2,a0
    80002ee2:	e565                	bnez	a0,80002fca <usertrap+0x18e>
    80002ee4:	14202773          	csrr	a4,scause
    80002ee8:	47b5                	li	a5,13
    80002eea:	00f70763          	beq	a4,a5,80002ef8 <usertrap+0xbc>
    80002eee:	14202773          	csrr	a4,scause
    80002ef2:	47bd                	li	a5,15
    80002ef4:	08f71f63          	bne	a4,a5,80002f92 <usertrap+0x156>
    80002ef8:	14302573          	csrr	a0,stval
    80002efc:	85a6                	mv	a1,s1
    80002efe:	00000097          	auipc	ra,0x0
    80002f02:	d68080e7          	jalr	-664(ra) # 80002c66 <is_valid_address>
    80002f06:	cd21                	beqz	a0,80002f5e <usertrap+0x122>
    80002f08:	ffffe097          	auipc	ra,0xffffe
    80002f0c:	bda080e7          	jalr	-1062(ra) # 80000ae2 <kalloc>
    80002f10:	892a                	mv	s2,a0
    80002f12:	cd39                	beqz	a0,80002f70 <usertrap+0x134>
    80002f14:	143025f3          	csrr	a1,stval
    80002f18:	4779                	li	a4,30
    80002f1a:	86ca                	mv	a3,s2
    80002f1c:	6605                	lui	a2,0x1
    80002f1e:	77fd                	lui	a5,0xfffff
    80002f20:	8dfd                	and	a1,a1,a5
    80002f22:	2d84b503          	ld	a0,728(s1)
    80002f26:	ffffe097          	auipc	ra,0xffffe
    80002f2a:	1b8080e7          	jalr	440(ra) # 800010de <mappages>
    80002f2e:	f60559e3          	bgez	a0,80002ea0 <usertrap+0x64>
    80002f32:	854a                	mv	a0,s2
    80002f34:	ffffe097          	auipc	ra,0xffffe
    80002f38:	ab0080e7          	jalr	-1360(ra) # 800009e4 <kfree>
    80002f3c:	00006517          	auipc	a0,0x6
    80002f40:	41450513          	addi	a0,a0,1044 # 80009350 <states.0+0x98>
    80002f44:	ffffd097          	auipc	ra,0xffffd
    80002f48:	642080e7          	jalr	1602(ra) # 80000586 <printf>
    80002f4c:	4785                	li	a5,1
    80002f4e:	2af4a823          	sw	a5,688(s1)
    80002f52:	557d                	li	a0,-1
    80002f54:	fffff097          	auipc	ra,0xfffff
    80002f58:	0c2080e7          	jalr	194(ra) # 80002016 <exit>
    80002f5c:	b791                	j	80002ea0 <usertrap+0x64>
    80002f5e:	4785                	li	a5,1
    80002f60:	2af4a823          	sw	a5,688(s1)
    80002f64:	557d                	li	a0,-1
    80002f66:	fffff097          	auipc	ra,0xfffff
    80002f6a:	0b0080e7          	jalr	176(ra) # 80002016 <exit>
    80002f6e:	bf69                	j	80002f08 <usertrap+0xcc>
    80002f70:	00006517          	auipc	a0,0x6
    80002f74:	3c050513          	addi	a0,a0,960 # 80009330 <states.0+0x78>
    80002f78:	ffffd097          	auipc	ra,0xffffd
    80002f7c:	60e080e7          	jalr	1550(ra) # 80000586 <printf>
    80002f80:	4785                	li	a5,1
    80002f82:	2af4a823          	sw	a5,688(s1)
    80002f86:	557d                	li	a0,-1
    80002f88:	fffff097          	auipc	ra,0xfffff
    80002f8c:	08e080e7          	jalr	142(ra) # 80002016 <exit>
    80002f90:	b751                	j	80002f14 <usertrap+0xd8>
    80002f92:	142025f3          	csrr	a1,scause
    80002f96:	2b84a603          	lw	a2,696(s1)
    80002f9a:	00006517          	auipc	a0,0x6
    80002f9e:	3d650513          	addi	a0,a0,982 # 80009370 <states.0+0xb8>
    80002fa2:	ffffd097          	auipc	ra,0xffffd
    80002fa6:	5e4080e7          	jalr	1508(ra) # 80000586 <printf>
    80002faa:	141025f3          	csrr	a1,sepc
    80002fae:	14302673          	csrr	a2,stval
    80002fb2:	00006517          	auipc	a0,0x6
    80002fb6:	3ee50513          	addi	a0,a0,1006 # 800093a0 <states.0+0xe8>
    80002fba:	ffffd097          	auipc	ra,0xffffd
    80002fbe:	5cc080e7          	jalr	1484(ra) # 80000586 <printf>
    80002fc2:	4785                	li	a5,1
    80002fc4:	2af4a823          	sw	a5,688(s1)
    80002fc8:	a031                	j	80002fd4 <usertrap+0x198>
    80002fca:	2b04a783          	lw	a5,688(s1)
    80002fce:	cb81                	beqz	a5,80002fde <usertrap+0x1a2>
    80002fd0:	a011                	j	80002fd4 <usertrap+0x198>
    80002fd2:	4901                	li	s2,0
    80002fd4:	557d                	li	a0,-1
    80002fd6:	fffff097          	auipc	ra,0xfffff
    80002fda:	040080e7          	jalr	64(ra) # 80002016 <exit>
    80002fde:	4789                	li	a5,2
    80002fe0:	ecf914e3          	bne	s2,a5,80002ea8 <usertrap+0x6c>
    80002fe4:	fffff097          	auipc	ra,0xfffff
    80002fe8:	eb6080e7          	jalr	-330(ra) # 80001e9a <yield>
    80002fec:	bd75                	j	80002ea8 <usertrap+0x6c>

0000000080002fee <kerneltrap>:
    80002fee:	7179                	addi	sp,sp,-48
    80002ff0:	f406                	sd	ra,40(sp)
    80002ff2:	f022                	sd	s0,32(sp)
    80002ff4:	ec26                	sd	s1,24(sp)
    80002ff6:	e84a                	sd	s2,16(sp)
    80002ff8:	e44e                	sd	s3,8(sp)
    80002ffa:	1800                	addi	s0,sp,48
    80002ffc:	14102973          	csrr	s2,sepc
    80003000:	100024f3          	csrr	s1,sstatus
    80003004:	142029f3          	csrr	s3,scause
    80003008:	1004f793          	andi	a5,s1,256
    8000300c:	cb85                	beqz	a5,8000303c <kerneltrap+0x4e>
    8000300e:	100027f3          	csrr	a5,sstatus
    80003012:	8b89                	andi	a5,a5,2
    80003014:	ef85                	bnez	a5,8000304c <kerneltrap+0x5e>
    80003016:	00000097          	auipc	ra,0x0
    8000301a:	d84080e7          	jalr	-636(ra) # 80002d9a <devintr>
    8000301e:	cd1d                	beqz	a0,8000305c <kerneltrap+0x6e>
    80003020:	4789                	li	a5,2
    80003022:	06f50a63          	beq	a0,a5,80003096 <kerneltrap+0xa8>
    80003026:	14191073          	csrw	sepc,s2
    8000302a:	10049073          	csrw	sstatus,s1
    8000302e:	70a2                	ld	ra,40(sp)
    80003030:	7402                	ld	s0,32(sp)
    80003032:	64e2                	ld	s1,24(sp)
    80003034:	6942                	ld	s2,16(sp)
    80003036:	69a2                	ld	s3,8(sp)
    80003038:	6145                	addi	sp,sp,48
    8000303a:	8082                	ret
    8000303c:	00006517          	auipc	a0,0x6
    80003040:	38450513          	addi	a0,a0,900 # 800093c0 <states.0+0x108>
    80003044:	ffffd097          	auipc	ra,0xffffd
    80003048:	4f8080e7          	jalr	1272(ra) # 8000053c <panic>
    8000304c:	00006517          	auipc	a0,0x6
    80003050:	39c50513          	addi	a0,a0,924 # 800093e8 <states.0+0x130>
    80003054:	ffffd097          	auipc	ra,0xffffd
    80003058:	4e8080e7          	jalr	1256(ra) # 8000053c <panic>
    8000305c:	85ce                	mv	a1,s3
    8000305e:	00006517          	auipc	a0,0x6
    80003062:	3aa50513          	addi	a0,a0,938 # 80009408 <states.0+0x150>
    80003066:	ffffd097          	auipc	ra,0xffffd
    8000306a:	520080e7          	jalr	1312(ra) # 80000586 <printf>
    8000306e:	141025f3          	csrr	a1,sepc
    80003072:	14302673          	csrr	a2,stval
    80003076:	00006517          	auipc	a0,0x6
    8000307a:	3a250513          	addi	a0,a0,930 # 80009418 <states.0+0x160>
    8000307e:	ffffd097          	auipc	ra,0xffffd
    80003082:	508080e7          	jalr	1288(ra) # 80000586 <printf>
    80003086:	00006517          	auipc	a0,0x6
    8000308a:	3aa50513          	addi	a0,a0,938 # 80009430 <states.0+0x178>
    8000308e:	ffffd097          	auipc	ra,0xffffd
    80003092:	4ae080e7          	jalr	1198(ra) # 8000053c <panic>
    80003096:	fffff097          	auipc	ra,0xfffff
    8000309a:	a5a080e7          	jalr	-1446(ra) # 80001af0 <myproc>
    8000309e:	d541                	beqz	a0,80003026 <kerneltrap+0x38>
    800030a0:	fffff097          	auipc	ra,0xfffff
    800030a4:	a50080e7          	jalr	-1456(ra) # 80001af0 <myproc>
    800030a8:	2a052703          	lw	a4,672(a0)
    800030ac:	4791                	li	a5,4
    800030ae:	f6f71ce3          	bne	a4,a5,80003026 <kerneltrap+0x38>
    800030b2:	fffff097          	auipc	ra,0xfffff
    800030b6:	de8080e7          	jalr	-536(ra) # 80001e9a <yield>
    800030ba:	b7b5                	j	80003026 <kerneltrap+0x38>

00000000800030bc <argraw>:
    800030bc:	1101                	addi	sp,sp,-32
    800030be:	ec06                	sd	ra,24(sp)
    800030c0:	e822                	sd	s0,16(sp)
    800030c2:	e426                	sd	s1,8(sp)
    800030c4:	1000                	addi	s0,sp,32
    800030c6:	84aa                	mv	s1,a0
    800030c8:	fffff097          	auipc	ra,0xfffff
    800030cc:	a28080e7          	jalr	-1496(ra) # 80001af0 <myproc>
    800030d0:	4795                	li	a5,5
    800030d2:	0497e763          	bltu	a5,s1,80003120 <argraw+0x64>
    800030d6:	048a                	slli	s1,s1,0x2
    800030d8:	00006717          	auipc	a4,0x6
    800030dc:	39070713          	addi	a4,a4,912 # 80009468 <states.0+0x1b0>
    800030e0:	94ba                	add	s1,s1,a4
    800030e2:	409c                	lw	a5,0(s1)
    800030e4:	97ba                	add	a5,a5,a4
    800030e6:	8782                	jr	a5
    800030e8:	2e053783          	ld	a5,736(a0)
    800030ec:	7ba8                	ld	a0,112(a5)
    800030ee:	60e2                	ld	ra,24(sp)
    800030f0:	6442                	ld	s0,16(sp)
    800030f2:	64a2                	ld	s1,8(sp)
    800030f4:	6105                	addi	sp,sp,32
    800030f6:	8082                	ret
    800030f8:	2e053783          	ld	a5,736(a0)
    800030fc:	7fa8                	ld	a0,120(a5)
    800030fe:	bfc5                	j	800030ee <argraw+0x32>
    80003100:	2e053783          	ld	a5,736(a0)
    80003104:	63c8                	ld	a0,128(a5)
    80003106:	b7e5                	j	800030ee <argraw+0x32>
    80003108:	2e053783          	ld	a5,736(a0)
    8000310c:	67c8                	ld	a0,136(a5)
    8000310e:	b7c5                	j	800030ee <argraw+0x32>
    80003110:	2e053783          	ld	a5,736(a0)
    80003114:	6bc8                	ld	a0,144(a5)
    80003116:	bfe1                	j	800030ee <argraw+0x32>
    80003118:	2e053783          	ld	a5,736(a0)
    8000311c:	6fc8                	ld	a0,152(a5)
    8000311e:	bfc1                	j	800030ee <argraw+0x32>
    80003120:	00006517          	auipc	a0,0x6
    80003124:	32050513          	addi	a0,a0,800 # 80009440 <states.0+0x188>
    80003128:	ffffd097          	auipc	ra,0xffffd
    8000312c:	414080e7          	jalr	1044(ra) # 8000053c <panic>

0000000080003130 <fetchaddr>:
    80003130:	1101                	addi	sp,sp,-32
    80003132:	ec06                	sd	ra,24(sp)
    80003134:	e822                	sd	s0,16(sp)
    80003136:	e426                	sd	s1,8(sp)
    80003138:	e04a                	sd	s2,0(sp)
    8000313a:	1000                	addi	s0,sp,32
    8000313c:	84aa                	mv	s1,a0
    8000313e:	892e                	mv	s2,a1
    80003140:	fffff097          	auipc	ra,0xfffff
    80003144:	9b0080e7          	jalr	-1616(ra) # 80001af0 <myproc>
    80003148:	2d053783          	ld	a5,720(a0)
    8000314c:	02f4f963          	bgeu	s1,a5,8000317e <fetchaddr+0x4e>
    80003150:	00848713          	addi	a4,s1,8
    80003154:	02e7e763          	bltu	a5,a4,80003182 <fetchaddr+0x52>
    80003158:	46a1                	li	a3,8
    8000315a:	8626                	mv	a2,s1
    8000315c:	85ca                	mv	a1,s2
    8000315e:	2d853503          	ld	a0,728(a0)
    80003162:	ffffe097          	auipc	ra,0xffffe
    80003166:	662080e7          	jalr	1634(ra) # 800017c4 <copyin>
    8000316a:	00a03533          	snez	a0,a0
    8000316e:	40a00533          	neg	a0,a0
    80003172:	60e2                	ld	ra,24(sp)
    80003174:	6442                	ld	s0,16(sp)
    80003176:	64a2                	ld	s1,8(sp)
    80003178:	6902                	ld	s2,0(sp)
    8000317a:	6105                	addi	sp,sp,32
    8000317c:	8082                	ret
    8000317e:	557d                	li	a0,-1
    80003180:	bfcd                	j	80003172 <fetchaddr+0x42>
    80003182:	557d                	li	a0,-1
    80003184:	b7fd                	j	80003172 <fetchaddr+0x42>

0000000080003186 <fetchstr>:
    80003186:	7179                	addi	sp,sp,-48
    80003188:	f406                	sd	ra,40(sp)
    8000318a:	f022                	sd	s0,32(sp)
    8000318c:	ec26                	sd	s1,24(sp)
    8000318e:	e84a                	sd	s2,16(sp)
    80003190:	e44e                	sd	s3,8(sp)
    80003192:	1800                	addi	s0,sp,48
    80003194:	892a                	mv	s2,a0
    80003196:	84ae                	mv	s1,a1
    80003198:	89b2                	mv	s3,a2
    8000319a:	fffff097          	auipc	ra,0xfffff
    8000319e:	956080e7          	jalr	-1706(ra) # 80001af0 <myproc>
    800031a2:	86ce                	mv	a3,s3
    800031a4:	864a                	mv	a2,s2
    800031a6:	85a6                	mv	a1,s1
    800031a8:	2d853503          	ld	a0,728(a0)
    800031ac:	ffffe097          	auipc	ra,0xffffe
    800031b0:	6a6080e7          	jalr	1702(ra) # 80001852 <copyinstr>
    800031b4:	00054763          	bltz	a0,800031c2 <fetchstr+0x3c>
    800031b8:	8526                	mv	a0,s1
    800031ba:	ffffe097          	auipc	ra,0xffffe
    800031be:	cd8080e7          	jalr	-808(ra) # 80000e92 <strlen>
    800031c2:	70a2                	ld	ra,40(sp)
    800031c4:	7402                	ld	s0,32(sp)
    800031c6:	64e2                	ld	s1,24(sp)
    800031c8:	6942                	ld	s2,16(sp)
    800031ca:	69a2                	ld	s3,8(sp)
    800031cc:	6145                	addi	sp,sp,48
    800031ce:	8082                	ret

00000000800031d0 <argint>:
    800031d0:	1101                	addi	sp,sp,-32
    800031d2:	ec06                	sd	ra,24(sp)
    800031d4:	e822                	sd	s0,16(sp)
    800031d6:	e426                	sd	s1,8(sp)
    800031d8:	1000                	addi	s0,sp,32
    800031da:	84ae                	mv	s1,a1
    800031dc:	00000097          	auipc	ra,0x0
    800031e0:	ee0080e7          	jalr	-288(ra) # 800030bc <argraw>
    800031e4:	c088                	sw	a0,0(s1)
    800031e6:	4501                	li	a0,0
    800031e8:	60e2                	ld	ra,24(sp)
    800031ea:	6442                	ld	s0,16(sp)
    800031ec:	64a2                	ld	s1,8(sp)
    800031ee:	6105                	addi	sp,sp,32
    800031f0:	8082                	ret

00000000800031f2 <argaddr>:
    800031f2:	1101                	addi	sp,sp,-32
    800031f4:	ec06                	sd	ra,24(sp)
    800031f6:	e822                	sd	s0,16(sp)
    800031f8:	e426                	sd	s1,8(sp)
    800031fa:	1000                	addi	s0,sp,32
    800031fc:	84ae                	mv	s1,a1
    800031fe:	00000097          	auipc	ra,0x0
    80003202:	ebe080e7          	jalr	-322(ra) # 800030bc <argraw>
    80003206:	e088                	sd	a0,0(s1)
    80003208:	4501                	li	a0,0
    8000320a:	60e2                	ld	ra,24(sp)
    8000320c:	6442                	ld	s0,16(sp)
    8000320e:	64a2                	ld	s1,8(sp)
    80003210:	6105                	addi	sp,sp,32
    80003212:	8082                	ret

0000000080003214 <argstr>:
    80003214:	1101                	addi	sp,sp,-32
    80003216:	ec06                	sd	ra,24(sp)
    80003218:	e822                	sd	s0,16(sp)
    8000321a:	e426                	sd	s1,8(sp)
    8000321c:	e04a                	sd	s2,0(sp)
    8000321e:	1000                	addi	s0,sp,32
    80003220:	84ae                	mv	s1,a1
    80003222:	8932                	mv	s2,a2
    80003224:	00000097          	auipc	ra,0x0
    80003228:	e98080e7          	jalr	-360(ra) # 800030bc <argraw>
    8000322c:	864a                	mv	a2,s2
    8000322e:	85a6                	mv	a1,s1
    80003230:	00000097          	auipc	ra,0x0
    80003234:	f56080e7          	jalr	-170(ra) # 80003186 <fetchstr>
    80003238:	60e2                	ld	ra,24(sp)
    8000323a:	6442                	ld	s0,16(sp)
    8000323c:	64a2                	ld	s1,8(sp)
    8000323e:	6902                	ld	s2,0(sp)
    80003240:	6105                	addi	sp,sp,32
    80003242:	8082                	ret

0000000080003244 <syscall>:
    80003244:	1101                	addi	sp,sp,-32
    80003246:	ec06                	sd	ra,24(sp)
    80003248:	e822                	sd	s0,16(sp)
    8000324a:	e426                	sd	s1,8(sp)
    8000324c:	e04a                	sd	s2,0(sp)
    8000324e:	1000                	addi	s0,sp,32
    80003250:	fffff097          	auipc	ra,0xfffff
    80003254:	8a0080e7          	jalr	-1888(ra) # 80001af0 <myproc>
    80003258:	84aa                	mv	s1,a0
    8000325a:	2e053903          	ld	s2,736(a0)
    8000325e:	0a893783          	ld	a5,168(s2)
    80003262:	0007869b          	sext.w	a3,a5
    80003266:	37fd                	addiw	a5,a5,-1 # ffffffffffffefff <end+0xffffffff7ffc8367>
    80003268:	4771                	li	a4,28
    8000326a:	00f76f63          	bltu	a4,a5,80003288 <syscall+0x44>
    8000326e:	00369713          	slli	a4,a3,0x3
    80003272:	00006797          	auipc	a5,0x6
    80003276:	20e78793          	addi	a5,a5,526 # 80009480 <syscalls>
    8000327a:	97ba                	add	a5,a5,a4
    8000327c:	639c                	ld	a5,0(a5)
    8000327e:	c789                	beqz	a5,80003288 <syscall+0x44>
    80003280:	9782                	jalr	a5
    80003282:	06a93823          	sd	a0,112(s2)
    80003286:	a00d                	j	800032a8 <syscall+0x64>
    80003288:	3e048613          	addi	a2,s1,992
    8000328c:	2b84a583          	lw	a1,696(s1)
    80003290:	00006517          	auipc	a0,0x6
    80003294:	1b850513          	addi	a0,a0,440 # 80009448 <states.0+0x190>
    80003298:	ffffd097          	auipc	ra,0xffffd
    8000329c:	2ee080e7          	jalr	750(ra) # 80000586 <printf>
    800032a0:	2e04b783          	ld	a5,736(s1)
    800032a4:	577d                	li	a4,-1
    800032a6:	fbb8                	sd	a4,112(a5)
    800032a8:	60e2                	ld	ra,24(sp)
    800032aa:	6442                	ld	s0,16(sp)
    800032ac:	64a2                	ld	s1,8(sp)
    800032ae:	6902                	ld	s2,0(sp)
    800032b0:	6105                	addi	sp,sp,32
    800032b2:	8082                	ret

00000000800032b4 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800032b4:	1101                	addi	sp,sp,-32
    800032b6:	ec06                	sd	ra,24(sp)
    800032b8:	e822                	sd	s0,16(sp)
    800032ba:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    800032bc:	fec40593          	addi	a1,s0,-20
    800032c0:	4501                	li	a0,0
    800032c2:	00000097          	auipc	ra,0x0
    800032c6:	f0e080e7          	jalr	-242(ra) # 800031d0 <argint>
    return -1;
    800032ca:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800032cc:	00054963          	bltz	a0,800032de <sys_exit+0x2a>
  exit(n);
    800032d0:	fec42503          	lw	a0,-20(s0)
    800032d4:	fffff097          	auipc	ra,0xfffff
    800032d8:	d42080e7          	jalr	-702(ra) # 80002016 <exit>
  return 0;  // not reached
    800032dc:	4781                	li	a5,0
}
    800032de:	853e                	mv	a0,a5
    800032e0:	60e2                	ld	ra,24(sp)
    800032e2:	6442                	ld	s0,16(sp)
    800032e4:	6105                	addi	sp,sp,32
    800032e6:	8082                	ret

00000000800032e8 <sys_getpid>:

uint64
sys_getpid(void)
{
    800032e8:	1141                	addi	sp,sp,-16
    800032ea:	e406                	sd	ra,8(sp)
    800032ec:	e022                	sd	s0,0(sp)
    800032ee:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800032f0:	fffff097          	auipc	ra,0xfffff
    800032f4:	800080e7          	jalr	-2048(ra) # 80001af0 <myproc>
}
    800032f8:	2b852503          	lw	a0,696(a0)
    800032fc:	60a2                	ld	ra,8(sp)
    800032fe:	6402                	ld	s0,0(sp)
    80003300:	0141                	addi	sp,sp,16
    80003302:	8082                	ret

0000000080003304 <sys_fork>:

uint64
sys_fork(void)
{
    80003304:	1141                	addi	sp,sp,-16
    80003306:	e406                	sd	ra,8(sp)
    80003308:	e022                	sd	s0,0(sp)
    8000330a:	0800                	addi	s0,sp,16
  return fork();
    8000330c:	fffff097          	auipc	ra,0xfffff
    80003310:	458080e7          	jalr	1112(ra) # 80002764 <fork>
}
    80003314:	60a2                	ld	ra,8(sp)
    80003316:	6402                	ld	s0,0(sp)
    80003318:	0141                	addi	sp,sp,16
    8000331a:	8082                	ret

000000008000331c <sys_wait>:

uint64
sys_wait(void)
{
    8000331c:	1101                	addi	sp,sp,-32
    8000331e:	ec06                	sd	ra,24(sp)
    80003320:	e822                	sd	s0,16(sp)
    80003322:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003324:	fe840593          	addi	a1,s0,-24
    80003328:	4501                	li	a0,0
    8000332a:	00000097          	auipc	ra,0x0
    8000332e:	ec8080e7          	jalr	-312(ra) # 800031f2 <argaddr>
    80003332:	87aa                	mv	a5,a0
    return -1;
    80003334:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80003336:	0007c863          	bltz	a5,80003346 <sys_wait+0x2a>
  return wait(p);
    8000333a:	fe843503          	ld	a0,-24(s0)
    8000333e:	fffff097          	auipc	ra,0xfffff
    80003342:	6ea080e7          	jalr	1770(ra) # 80002a28 <wait>
}
    80003346:	60e2                	ld	ra,24(sp)
    80003348:	6442                	ld	s0,16(sp)
    8000334a:	6105                	addi	sp,sp,32
    8000334c:	8082                	ret

000000008000334e <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000334e:	7179                	addi	sp,sp,-48
    80003350:	f406                	sd	ra,40(sp)
    80003352:	f022                	sd	s0,32(sp)
    80003354:	ec26                	sd	s1,24(sp)
    80003356:	e84a                	sd	s2,16(sp)
    80003358:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    8000335a:	fdc40593          	addi	a1,s0,-36
    8000335e:	4501                	li	a0,0
    80003360:	00000097          	auipc	ra,0x0
    80003364:	e70080e7          	jalr	-400(ra) # 800031d0 <argint>
    80003368:	87aa                	mv	a5,a0
    return -1;
    8000336a:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    8000336c:	0207c363          	bltz	a5,80003392 <sys_sbrk+0x44>
  addr = myproc()->sz;
    80003370:	ffffe097          	auipc	ra,0xffffe
    80003374:	780080e7          	jalr	1920(ra) # 80001af0 <myproc>
    80003378:	2d052483          	lw	s1,720(a0)
  
  //if(growproc(n) < 0)
    //return -1;

  int newsz = addr + n;
    8000337c:	fdc42903          	lw	s2,-36(s0)
    80003380:	0099093b          	addw	s2,s2,s1
  if(newsz < TRAPFRAME){
  	//allocate more virtual mem
  	myproc()->sz = newsz;
    80003384:	ffffe097          	auipc	ra,0xffffe
    80003388:	76c080e7          	jalr	1900(ra) # 80001af0 <myproc>
    8000338c:	2d253823          	sd	s2,720(a0)
  	return addr;
    80003390:	8526                	mv	a0,s1
  }
  return -1;
}
    80003392:	70a2                	ld	ra,40(sp)
    80003394:	7402                	ld	s0,32(sp)
    80003396:	64e2                	ld	s1,24(sp)
    80003398:	6942                	ld	s2,16(sp)
    8000339a:	6145                	addi	sp,sp,48
    8000339c:	8082                	ret

000000008000339e <sys_sleep>:

uint64
sys_sleep(void)
{
    8000339e:	7139                	addi	sp,sp,-64
    800033a0:	fc06                	sd	ra,56(sp)
    800033a2:	f822                	sd	s0,48(sp)
    800033a4:	f426                	sd	s1,40(sp)
    800033a6:	f04a                	sd	s2,32(sp)
    800033a8:	ec4e                	sd	s3,24(sp)
    800033aa:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    800033ac:	fcc40593          	addi	a1,s0,-52
    800033b0:	4501                	li	a0,0
    800033b2:	00000097          	auipc	ra,0x0
    800033b6:	e1e080e7          	jalr	-482(ra) # 800031d0 <argint>
    return -1;
    800033ba:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800033bc:	06054663          	bltz	a0,80003428 <sys_sleep+0x8a>
  acquire(&tickslock);
    800033c0:	00024517          	auipc	a0,0x24
    800033c4:	f2850513          	addi	a0,a0,-216 # 800272e8 <tickslock>
    800033c8:	ffffe097          	auipc	ra,0xffffe
    800033cc:	852080e7          	jalr	-1966(ra) # 80000c1a <acquire>
  ticks0 = ticks;
    800033d0:	00007917          	auipc	s2,0x7
    800033d4:	c6092903          	lw	s2,-928(s2) # 8000a030 <ticks>
  while(ticks - ticks0 < n){
    800033d8:	fcc42783          	lw	a5,-52(s0)
    800033dc:	cf8d                	beqz	a5,80003416 <sys_sleep+0x78>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800033de:	00024997          	auipc	s3,0x24
    800033e2:	f0a98993          	addi	s3,s3,-246 # 800272e8 <tickslock>
    800033e6:	00007497          	auipc	s1,0x7
    800033ea:	c4a48493          	addi	s1,s1,-950 # 8000a030 <ticks>
    if(myproc()->killed){
    800033ee:	ffffe097          	auipc	ra,0xffffe
    800033f2:	702080e7          	jalr	1794(ra) # 80001af0 <myproc>
    800033f6:	2b052783          	lw	a5,688(a0)
    800033fa:	ef9d                	bnez	a5,80003438 <sys_sleep+0x9a>
    sleep(&ticks, &tickslock);
    800033fc:	85ce                	mv	a1,s3
    800033fe:	8526                	mv	a0,s1
    80003400:	fffff097          	auipc	ra,0xfffff
    80003404:	ad8080e7          	jalr	-1320(ra) # 80001ed8 <sleep>
  while(ticks - ticks0 < n){
    80003408:	409c                	lw	a5,0(s1)
    8000340a:	412787bb          	subw	a5,a5,s2
    8000340e:	fcc42703          	lw	a4,-52(s0)
    80003412:	fce7eee3          	bltu	a5,a4,800033ee <sys_sleep+0x50>
  }
  release(&tickslock);
    80003416:	00024517          	auipc	a0,0x24
    8000341a:	ed250513          	addi	a0,a0,-302 # 800272e8 <tickslock>
    8000341e:	ffffe097          	auipc	ra,0xffffe
    80003422:	8b0080e7          	jalr	-1872(ra) # 80000cce <release>
  return 0;
    80003426:	4781                	li	a5,0
}
    80003428:	853e                	mv	a0,a5
    8000342a:	70e2                	ld	ra,56(sp)
    8000342c:	7442                	ld	s0,48(sp)
    8000342e:	74a2                	ld	s1,40(sp)
    80003430:	7902                	ld	s2,32(sp)
    80003432:	69e2                	ld	s3,24(sp)
    80003434:	6121                	addi	sp,sp,64
    80003436:	8082                	ret
      release(&tickslock);
    80003438:	00024517          	auipc	a0,0x24
    8000343c:	eb050513          	addi	a0,a0,-336 # 800272e8 <tickslock>
    80003440:	ffffe097          	auipc	ra,0xffffe
    80003444:	88e080e7          	jalr	-1906(ra) # 80000cce <release>
      return -1;
    80003448:	57fd                	li	a5,-1
    8000344a:	bff9                	j	80003428 <sys_sleep+0x8a>

000000008000344c <sys_kill>:

uint64
sys_kill(void)
{
    8000344c:	1101                	addi	sp,sp,-32
    8000344e:	ec06                	sd	ra,24(sp)
    80003450:	e822                	sd	s0,16(sp)
    80003452:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80003454:	fec40593          	addi	a1,s0,-20
    80003458:	4501                	li	a0,0
    8000345a:	00000097          	auipc	ra,0x0
    8000345e:	d76080e7          	jalr	-650(ra) # 800031d0 <argint>
    80003462:	87aa                	mv	a5,a0
    return -1;
    80003464:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80003466:	0007c863          	bltz	a5,80003476 <sys_kill+0x2a>
  return kill(pid);
    8000346a:	fec42503          	lw	a0,-20(s0)
    8000346e:	fffff097          	auipc	ra,0xfffff
    80003472:	c7e080e7          	jalr	-898(ra) # 800020ec <kill>
}
    80003476:	60e2                	ld	ra,24(sp)
    80003478:	6442                	ld	s0,16(sp)
    8000347a:	6105                	addi	sp,sp,32
    8000347c:	8082                	ret

000000008000347e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000347e:	1101                	addi	sp,sp,-32
    80003480:	ec06                	sd	ra,24(sp)
    80003482:	e822                	sd	s0,16(sp)
    80003484:	e426                	sd	s1,8(sp)
    80003486:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003488:	00024517          	auipc	a0,0x24
    8000348c:	e6050513          	addi	a0,a0,-416 # 800272e8 <tickslock>
    80003490:	ffffd097          	auipc	ra,0xffffd
    80003494:	78a080e7          	jalr	1930(ra) # 80000c1a <acquire>
  xticks = ticks;
    80003498:	00007497          	auipc	s1,0x7
    8000349c:	b984a483          	lw	s1,-1128(s1) # 8000a030 <ticks>
  release(&tickslock);
    800034a0:	00024517          	auipc	a0,0x24
    800034a4:	e4850513          	addi	a0,a0,-440 # 800272e8 <tickslock>
    800034a8:	ffffe097          	auipc	ra,0xffffe
    800034ac:	826080e7          	jalr	-2010(ra) # 80000cce <release>
  return xticks;
}
    800034b0:	02049513          	slli	a0,s1,0x20
    800034b4:	9101                	srli	a0,a0,0x20
    800034b6:	60e2                	ld	ra,24(sp)
    800034b8:	6442                	ld	s0,16(sp)
    800034ba:	64a2                	ld	s1,8(sp)
    800034bc:	6105                	addi	sp,sp,32
    800034be:	8082                	ret

00000000800034c0 <sys_getprocs>:


uint64
sys_getprocs(void)
{
    800034c0:	1101                	addi	sp,sp,-32
    800034c2:	ec06                	sd	ra,24(sp)
    800034c4:	e822                	sd	s0,16(sp)
    800034c6:	1000                	addi	s0,sp,32
  uint64 addr;

  if (argaddr(0, &addr) < 0)
    800034c8:	fe840593          	addi	a1,s0,-24
    800034cc:	4501                	li	a0,0
    800034ce:	00000097          	auipc	ra,0x0
    800034d2:	d24080e7          	jalr	-732(ra) # 800031f2 <argaddr>
    800034d6:	87aa                	mv	a5,a0
    return -1;
    800034d8:	557d                	li	a0,-1
  if (argaddr(0, &addr) < 0)
    800034da:	0007c863          	bltz	a5,800034ea <sys_getprocs+0x2a>
  return(procinfo(addr));
    800034de:	fe843503          	ld	a0,-24(s0)
    800034e2:	fffff097          	auipc	ra,0xfffff
    800034e6:	de4080e7          	jalr	-540(ra) # 800022c6 <procinfo>
}
    800034ea:	60e2                	ld	ra,24(sp)
    800034ec:	6442                	ld	s0,16(sp)
    800034ee:	6105                	addi	sp,sp,32
    800034f0:	8082                	ret

00000000800034f2 <sys_freepmem>:

uint64
sys_freepmem(void){
    800034f2:	1141                	addi	sp,sp,-16
    800034f4:	e406                	sd	ra,8(sp)
    800034f6:	e022                	sd	s0,0(sp)
    800034f8:	0800                	addi	s0,sp,16
	int freePages = freeCount() * 4096;
    800034fa:	ffffd097          	auipc	ra,0xffffd
    800034fe:	648080e7          	jalr	1608(ra) # 80000b42 <freeCount>
	return freePages;
}
    80003502:	00c5151b          	slliw	a0,a0,0xc
    80003506:	60a2                	ld	ra,8(sp)
    80003508:	6402                	ld	s0,0(sp)
    8000350a:	0141                	addi	sp,sp,16
    8000350c:	8082                	ret

000000008000350e <sys_sem_init>:

int sys_sem_init(void) {
    8000350e:	7179                	addi	sp,sp,-48
    80003510:	f406                	sd	ra,40(sp)
    80003512:	f022                	sd	s0,32(sp)
    80003514:	1800                	addi	s0,sp,48
    uint64 s;
    int index, value, pshared;

        if (argaddr(0, &s) < 0 || argint(1, &pshared) < 0 || argint(2, &value) < 0) 
    80003516:	fe840593          	addi	a1,s0,-24
    8000351a:	4501                	li	a0,0
    8000351c:	00000097          	auipc	ra,0x0
    80003520:	cd6080e7          	jalr	-810(ra) # 800031f2 <argaddr>
    80003524:	06054c63          	bltz	a0,8000359c <sys_sem_init+0x8e>
    80003528:	fdc40593          	addi	a1,s0,-36
    8000352c:	4505                	li	a0,1
    8000352e:	00000097          	auipc	ra,0x0
    80003532:	ca2080e7          	jalr	-862(ra) # 800031d0 <argint>
    80003536:	06054563          	bltz	a0,800035a0 <sys_sem_init+0x92>
    8000353a:	fe040593          	addi	a1,s0,-32
    8000353e:	4509                	li	a0,2
    80003540:	00000097          	auipc	ra,0x0
    80003544:	c90080e7          	jalr	-880(ra) # 800031d0 <argint>
    80003548:	04054e63          	bltz	a0,800035a4 <sys_sem_init+0x96>
        {
        return -1;
        }

        if (pshared == 0)
    8000354c:	fdc42783          	lw	a5,-36(s0)
    80003550:	cfa1                	beqz	a5,800035a8 <sys_sem_init+0x9a>
        {
        return -1;}

    index = semalloc();
    80003552:	00004097          	auipc	ra,0x4
    80003556:	a10080e7          	jalr	-1520(ra) # 80006f62 <semalloc>
    8000355a:	fea42223          	sw	a0,-28(s0)
    semtable.sem[index].count = value;
    8000355e:	0505                	addi	a0,a0,1
    80003560:	0516                	slli	a0,a0,0x5
    80003562:	00033797          	auipc	a5,0x33
    80003566:	a9e78793          	addi	a5,a5,-1378 # 80036000 <semtable>
    8000356a:	97aa                	add	a5,a5,a0
    8000356c:	fe042703          	lw	a4,-32(s0)
    80003570:	cb98                	sw	a4,16(a5)

    if (copyout(myproc()->pagetable, s, (char*)&index, sizeof(index)) < 0) 
    80003572:	ffffe097          	auipc	ra,0xffffe
    80003576:	57e080e7          	jalr	1406(ra) # 80001af0 <myproc>
    8000357a:	4691                	li	a3,4
    8000357c:	fe440613          	addi	a2,s0,-28
    80003580:	fe843583          	ld	a1,-24(s0)
    80003584:	2d853503          	ld	a0,728(a0)
    80003588:	ffffe097          	auipc	ra,0xffffe
    8000358c:	1b0080e7          	jalr	432(ra) # 80001738 <copyout>
    80003590:	41f5551b          	sraiw	a0,a0,0x1f
    {
    return -1;
    }

    return 0;
}
    80003594:	70a2                	ld	ra,40(sp)
    80003596:	7402                	ld	s0,32(sp)
    80003598:	6145                	addi	sp,sp,48
    8000359a:	8082                	ret
        return -1;
    8000359c:	557d                	li	a0,-1
    8000359e:	bfdd                	j	80003594 <sys_sem_init+0x86>
    800035a0:	557d                	li	a0,-1
    800035a2:	bfcd                	j	80003594 <sys_sem_init+0x86>
    800035a4:	557d                	li	a0,-1
    800035a6:	b7fd                	j	80003594 <sys_sem_init+0x86>
        return -1;}
    800035a8:	557d                	li	a0,-1
    800035aa:	b7ed                	j	80003594 <sys_sem_init+0x86>

00000000800035ac <sys_sem_destroy>:

int sys_sem_destroy(void) {
    800035ac:	1101                	addi	sp,sp,-32
    800035ae:	ec06                	sd	ra,24(sp)
    800035b0:	e822                	sd	s0,16(sp)
    800035b2:	1000                	addi	s0,sp,32
    uint64 s;
    int addr;

    if (argaddr(0, &s) < 0) 
    800035b4:	fe840593          	addi	a1,s0,-24
    800035b8:	4501                	li	a0,0
    800035ba:	00000097          	auipc	ra,0x0
    800035be:	c38080e7          	jalr	-968(ra) # 800031f2 <argaddr>
    800035c2:	06054863          	bltz	a0,80003632 <sys_sem_destroy+0x86>
        {
        return -1;
       }

     acquire(&semtable.lock);
    800035c6:	00033517          	auipc	a0,0x33
    800035ca:	a3a50513          	addi	a0,a0,-1478 # 80036000 <semtable>
    800035ce:	ffffd097          	auipc	ra,0xffffd
    800035d2:	64c080e7          	jalr	1612(ra) # 80000c1a <acquire>

    if (copyin(myproc()->pagetable, (char*)&addr, s, sizeof(int)) < 0)
    800035d6:	ffffe097          	auipc	ra,0xffffe
    800035da:	51a080e7          	jalr	1306(ra) # 80001af0 <myproc>
    800035de:	4691                	li	a3,4
    800035e0:	fe843603          	ld	a2,-24(s0)
    800035e4:	fe440593          	addi	a1,s0,-28
    800035e8:	2d853503          	ld	a0,728(a0)
    800035ec:	ffffe097          	auipc	ra,0xffffe
    800035f0:	1d8080e7          	jalr	472(ra) # 800017c4 <copyin>
    800035f4:	02054563          	bltz	a0,8000361e <sys_sem_destroy+0x72>
         {
            release(&semtable.lock);
            return -1;
        }

    sedealloc(addr);
    800035f8:	fe442503          	lw	a0,-28(s0)
    800035fc:	00004097          	auipc	ra,0x4
    80003600:	9d8080e7          	jalr	-1576(ra) # 80006fd4 <sedealloc>

    release(&semtable.lock);
    80003604:	00033517          	auipc	a0,0x33
    80003608:	9fc50513          	addi	a0,a0,-1540 # 80036000 <semtable>
    8000360c:	ffffd097          	auipc	ra,0xffffd
    80003610:	6c2080e7          	jalr	1730(ra) # 80000cce <release>

    return 0;
    80003614:	4501                	li	a0,0
}
    80003616:	60e2                	ld	ra,24(sp)
    80003618:	6442                	ld	s0,16(sp)
    8000361a:	6105                	addi	sp,sp,32
    8000361c:	8082                	ret
            release(&semtable.lock);
    8000361e:	00033517          	auipc	a0,0x33
    80003622:	9e250513          	addi	a0,a0,-1566 # 80036000 <semtable>
    80003626:	ffffd097          	auipc	ra,0xffffd
    8000362a:	6a8080e7          	jalr	1704(ra) # 80000cce <release>
            return -1;
    8000362e:	557d                	li	a0,-1
    80003630:	b7dd                	j	80003616 <sys_sem_destroy+0x6a>
        return -1;
    80003632:	557d                	li	a0,-1
    80003634:	b7cd                	j	80003616 <sys_sem_destroy+0x6a>

0000000080003636 <sys_sem_wait>:

int sys_sem_wait(void) {
    80003636:	7179                	addi	sp,sp,-48
    80003638:	f406                	sd	ra,40(sp)
    8000363a:	f022                	sd	s0,32(sp)
    8000363c:	ec26                	sd	s1,24(sp)
    8000363e:	1800                	addi	s0,sp,48
    
      uint64 s;
      int addr;

    if (argaddr(0, &s) < 0 || copyin(myproc()->pagetable, (char*)&addr, s, sizeof(int)) < 0)
    80003640:	fd840593          	addi	a1,s0,-40
    80003644:	4501                	li	a0,0
    80003646:	00000097          	auipc	ra,0x0
    8000364a:	bac080e7          	jalr	-1108(ra) # 800031f2 <argaddr>
    8000364e:	0a054463          	bltz	a0,800036f6 <sys_sem_wait+0xc0>
    80003652:	ffffe097          	auipc	ra,0xffffe
    80003656:	49e080e7          	jalr	1182(ra) # 80001af0 <myproc>
    8000365a:	4691                	li	a3,4
    8000365c:	fd843603          	ld	a2,-40(s0)
    80003660:	fd440593          	addi	a1,s0,-44
    80003664:	2d853503          	ld	a0,728(a0)
    80003668:	ffffe097          	auipc	ra,0xffffe
    8000366c:	15c080e7          	jalr	348(ra) # 800017c4 <copyin>
    80003670:	08054563          	bltz	a0,800036fa <sys_sem_wait+0xc4>
    {
        return -1;}

    acquire(&semtable.sem[addr].lock);
    80003674:	fd442503          	lw	a0,-44(s0)
    80003678:	0516                	slli	a0,a0,0x5
    8000367a:	0561                	addi	a0,a0,24
    8000367c:	00033497          	auipc	s1,0x33
    80003680:	98448493          	addi	s1,s1,-1660 # 80036000 <semtable>
    80003684:	9526                	add	a0,a0,s1
    80003686:	ffffd097          	auipc	ra,0xffffd
    8000368a:	594080e7          	jalr	1428(ra) # 80000c1a <acquire>

    while (semtable.sem[addr].count == 0) 
    8000368e:	fd442783          	lw	a5,-44(s0)
    80003692:	00178713          	addi	a4,a5,1
    80003696:	0716                	slli	a4,a4,0x5
    80003698:	94ba                	add	s1,s1,a4
    8000369a:	4898                	lw	a4,16(s1)
    8000369c:	e715                	bnez	a4,800036c8 <sys_sem_wait+0x92>
    {
        sleep((void*)&semtable.sem[addr], &semtable.sem[addr].lock);
    8000369e:	00033497          	auipc	s1,0x33
    800036a2:	96248493          	addi	s1,s1,-1694 # 80036000 <semtable>
    800036a6:	00579513          	slli	a0,a5,0x5
    800036aa:	0561                	addi	a0,a0,24
    800036ac:	9526                	add	a0,a0,s1
    800036ae:	85aa                	mv	a1,a0
    800036b0:	fffff097          	auipc	ra,0xfffff
    800036b4:	828080e7          	jalr	-2008(ra) # 80001ed8 <sleep>
    while (semtable.sem[addr].count == 0) 
    800036b8:	fd442783          	lw	a5,-44(s0)
    800036bc:	00178713          	addi	a4,a5,1
    800036c0:	0716                	slli	a4,a4,0x5
    800036c2:	9726                	add	a4,a4,s1
    800036c4:	4b18                	lw	a4,16(a4)
    800036c6:	d365                	beqz	a4,800036a6 <sys_sem_wait+0x70>
    }

      semtable.sem[addr].count--;
    800036c8:	00033517          	auipc	a0,0x33
    800036cc:	93850513          	addi	a0,a0,-1736 # 80036000 <semtable>
    800036d0:	00178693          	addi	a3,a5,1
    800036d4:	0696                	slli	a3,a3,0x5
    800036d6:	96aa                	add	a3,a3,a0
    800036d8:	377d                	addiw	a4,a4,-1
    800036da:	ca98                	sw	a4,16(a3)
      release(&semtable.sem[addr].lock);
    800036dc:	0796                	slli	a5,a5,0x5
    800036de:	07e1                	addi	a5,a5,24
    800036e0:	953e                	add	a0,a0,a5
    800036e2:	ffffd097          	auipc	ra,0xffffd
    800036e6:	5ec080e7          	jalr	1516(ra) # 80000cce <release>

      return 0;}
    800036ea:	4501                	li	a0,0
    800036ec:	70a2                	ld	ra,40(sp)
    800036ee:	7402                	ld	s0,32(sp)
    800036f0:	64e2                	ld	s1,24(sp)
    800036f2:	6145                	addi	sp,sp,48
    800036f4:	8082                	ret
        return -1;}
    800036f6:	557d                	li	a0,-1
    800036f8:	bfd5                	j	800036ec <sys_sem_wait+0xb6>
    800036fa:	557d                	li	a0,-1
    800036fc:	bfc5                	j	800036ec <sys_sem_wait+0xb6>

00000000800036fe <sys_sem_post>:

int sys_sem_post(void)
{
    800036fe:	7179                	addi	sp,sp,-48
    80003700:	f406                	sd	ra,40(sp)
    80003702:	f022                	sd	s0,32(sp)
    80003704:	ec26                	sd	s1,24(sp)
    80003706:	1800                	addi	s0,sp,48
    uint64 s;
    int addr;

    if (argaddr(0, &s) < 0 || copyin(myproc()->pagetable, (char*)&addr, s, sizeof(int)) < 0)
    80003708:	fd840593          	addi	a1,s0,-40
    8000370c:	4501                	li	a0,0
    8000370e:	00000097          	auipc	ra,0x0
    80003712:	ae4080e7          	jalr	-1308(ra) # 800031f2 <argaddr>
    80003716:	06054f63          	bltz	a0,80003794 <sys_sem_post+0x96>
    8000371a:	ffffe097          	auipc	ra,0xffffe
    8000371e:	3d6080e7          	jalr	982(ra) # 80001af0 <myproc>
    80003722:	4691                	li	a3,4
    80003724:	fd843603          	ld	a2,-40(s0)
    80003728:	fd440593          	addi	a1,s0,-44
    8000372c:	2d853503          	ld	a0,728(a0)
    80003730:	ffffe097          	auipc	ra,0xffffe
    80003734:	094080e7          	jalr	148(ra) # 800017c4 <copyin>
    80003738:	06054063          	bltz	a0,80003798 <sys_sem_post+0x9a>
        {
        return -1;
        }


    acquire(&semtable.sem[addr].lock);
    8000373c:	fd442503          	lw	a0,-44(s0)
    80003740:	0516                	slli	a0,a0,0x5
    80003742:	0561                	addi	a0,a0,24
    80003744:	00033497          	auipc	s1,0x33
    80003748:	8bc48493          	addi	s1,s1,-1860 # 80036000 <semtable>
    8000374c:	9526                	add	a0,a0,s1
    8000374e:	ffffd097          	auipc	ra,0xffffd
    80003752:	4cc080e7          	jalr	1228(ra) # 80000c1a <acquire>

    semtable.sem[addr].count++;
    80003756:	fd442503          	lw	a0,-44(s0)
    8000375a:	00150793          	addi	a5,a0,1
    8000375e:	0796                	slli	a5,a5,0x5
    80003760:	97a6                	add	a5,a5,s1
    80003762:	4b98                	lw	a4,16(a5)
    80003764:	2705                	addiw	a4,a4,1
    80003766:	cb98                	sw	a4,16(a5)
    wakeup((void*)&semtable.sem[addr]);
    80003768:	0516                	slli	a0,a0,0x5
    8000376a:	0561                	addi	a0,a0,24
    8000376c:	9526                	add	a0,a0,s1
    8000376e:	ffffe097          	auipc	ra,0xffffe
    80003772:	7d0080e7          	jalr	2000(ra) # 80001f3e <wakeup>

    release(&semtable.sem[addr].lock);
    80003776:	fd442503          	lw	a0,-44(s0)
    8000377a:	0516                	slli	a0,a0,0x5
    8000377c:	0561                	addi	a0,a0,24
    8000377e:	9526                	add	a0,a0,s1
    80003780:	ffffd097          	auipc	ra,0xffffd
    80003784:	54e080e7          	jalr	1358(ra) # 80000cce <release>

  return 0;
    80003788:	4501                	li	a0,0
}
    8000378a:	70a2                	ld	ra,40(sp)
    8000378c:	7402                	ld	s0,32(sp)
    8000378e:	64e2                	ld	s1,24(sp)
    80003790:	6145                	addi	sp,sp,48
    80003792:	8082                	ret
        return -1;
    80003794:	557d                	li	a0,-1
    80003796:	bfd5                	j	8000378a <sys_sem_post+0x8c>
    80003798:	557d                	li	a0,-1
    8000379a:	bfc5                	j	8000378a <sys_sem_post+0x8c>

000000008000379c <binit>:
    8000379c:	7179                	addi	sp,sp,-48
    8000379e:	f406                	sd	ra,40(sp)
    800037a0:	f022                	sd	s0,32(sp)
    800037a2:	ec26                	sd	s1,24(sp)
    800037a4:	e84a                	sd	s2,16(sp)
    800037a6:	e44e                	sd	s3,8(sp)
    800037a8:	e052                	sd	s4,0(sp)
    800037aa:	1800                	addi	s0,sp,48
    800037ac:	00006597          	auipc	a1,0x6
    800037b0:	dc458593          	addi	a1,a1,-572 # 80009570 <syscalls+0xf0>
    800037b4:	00024517          	auipc	a0,0x24
    800037b8:	b4c50513          	addi	a0,a0,-1204 # 80027300 <bcache>
    800037bc:	ffffd097          	auipc	ra,0xffffd
    800037c0:	3ce080e7          	jalr	974(ra) # 80000b8a <initlock>
    800037c4:	0002c797          	auipc	a5,0x2c
    800037c8:	b3c78793          	addi	a5,a5,-1220 # 8002f300 <bcache+0x8000>
    800037cc:	0002c717          	auipc	a4,0x2c
    800037d0:	d9c70713          	addi	a4,a4,-612 # 8002f568 <bcache+0x8268>
    800037d4:	2ae7b823          	sd	a4,688(a5)
    800037d8:	2ae7bc23          	sd	a4,696(a5)
    800037dc:	00024497          	auipc	s1,0x24
    800037e0:	b3c48493          	addi	s1,s1,-1220 # 80027318 <bcache+0x18>
    800037e4:	893e                	mv	s2,a5
    800037e6:	89ba                	mv	s3,a4
    800037e8:	00006a17          	auipc	s4,0x6
    800037ec:	d90a0a13          	addi	s4,s4,-624 # 80009578 <syscalls+0xf8>
    800037f0:	2b893783          	ld	a5,696(s2)
    800037f4:	e8bc                	sd	a5,80(s1)
    800037f6:	0534b423          	sd	s3,72(s1)
    800037fa:	85d2                	mv	a1,s4
    800037fc:	01048513          	addi	a0,s1,16
    80003800:	00001097          	auipc	ra,0x1
    80003804:	4c2080e7          	jalr	1218(ra) # 80004cc2 <initsleeplock>
    80003808:	2b893783          	ld	a5,696(s2)
    8000380c:	e7a4                	sd	s1,72(a5)
    8000380e:	2a993c23          	sd	s1,696(s2)
    80003812:	45848493          	addi	s1,s1,1112
    80003816:	fd349de3          	bne	s1,s3,800037f0 <binit+0x54>
    8000381a:	70a2                	ld	ra,40(sp)
    8000381c:	7402                	ld	s0,32(sp)
    8000381e:	64e2                	ld	s1,24(sp)
    80003820:	6942                	ld	s2,16(sp)
    80003822:	69a2                	ld	s3,8(sp)
    80003824:	6a02                	ld	s4,0(sp)
    80003826:	6145                	addi	sp,sp,48
    80003828:	8082                	ret

000000008000382a <bread>:
    8000382a:	7179                	addi	sp,sp,-48
    8000382c:	f406                	sd	ra,40(sp)
    8000382e:	f022                	sd	s0,32(sp)
    80003830:	ec26                	sd	s1,24(sp)
    80003832:	e84a                	sd	s2,16(sp)
    80003834:	e44e                	sd	s3,8(sp)
    80003836:	1800                	addi	s0,sp,48
    80003838:	892a                	mv	s2,a0
    8000383a:	89ae                	mv	s3,a1
    8000383c:	00024517          	auipc	a0,0x24
    80003840:	ac450513          	addi	a0,a0,-1340 # 80027300 <bcache>
    80003844:	ffffd097          	auipc	ra,0xffffd
    80003848:	3d6080e7          	jalr	982(ra) # 80000c1a <acquire>
    8000384c:	0002c497          	auipc	s1,0x2c
    80003850:	d6c4b483          	ld	s1,-660(s1) # 8002f5b8 <bcache+0x82b8>
    80003854:	0002c797          	auipc	a5,0x2c
    80003858:	d1478793          	addi	a5,a5,-748 # 8002f568 <bcache+0x8268>
    8000385c:	02f48f63          	beq	s1,a5,8000389a <bread+0x70>
    80003860:	873e                	mv	a4,a5
    80003862:	a021                	j	8000386a <bread+0x40>
    80003864:	68a4                	ld	s1,80(s1)
    80003866:	02e48a63          	beq	s1,a4,8000389a <bread+0x70>
    8000386a:	449c                	lw	a5,8(s1)
    8000386c:	ff279ce3          	bne	a5,s2,80003864 <bread+0x3a>
    80003870:	44dc                	lw	a5,12(s1)
    80003872:	ff3799e3          	bne	a5,s3,80003864 <bread+0x3a>
    80003876:	40bc                	lw	a5,64(s1)
    80003878:	2785                	addiw	a5,a5,1
    8000387a:	c0bc                	sw	a5,64(s1)
    8000387c:	00024517          	auipc	a0,0x24
    80003880:	a8450513          	addi	a0,a0,-1404 # 80027300 <bcache>
    80003884:	ffffd097          	auipc	ra,0xffffd
    80003888:	44a080e7          	jalr	1098(ra) # 80000cce <release>
    8000388c:	01048513          	addi	a0,s1,16
    80003890:	00001097          	auipc	ra,0x1
    80003894:	46c080e7          	jalr	1132(ra) # 80004cfc <acquiresleep>
    80003898:	a8b9                	j	800038f6 <bread+0xcc>
    8000389a:	0002c497          	auipc	s1,0x2c
    8000389e:	d164b483          	ld	s1,-746(s1) # 8002f5b0 <bcache+0x82b0>
    800038a2:	0002c797          	auipc	a5,0x2c
    800038a6:	cc678793          	addi	a5,a5,-826 # 8002f568 <bcache+0x8268>
    800038aa:	00f48863          	beq	s1,a5,800038ba <bread+0x90>
    800038ae:	873e                	mv	a4,a5
    800038b0:	40bc                	lw	a5,64(s1)
    800038b2:	cf81                	beqz	a5,800038ca <bread+0xa0>
    800038b4:	64a4                	ld	s1,72(s1)
    800038b6:	fee49de3          	bne	s1,a4,800038b0 <bread+0x86>
    800038ba:	00006517          	auipc	a0,0x6
    800038be:	cc650513          	addi	a0,a0,-826 # 80009580 <syscalls+0x100>
    800038c2:	ffffd097          	auipc	ra,0xffffd
    800038c6:	c7a080e7          	jalr	-902(ra) # 8000053c <panic>
    800038ca:	0124a423          	sw	s2,8(s1)
    800038ce:	0134a623          	sw	s3,12(s1)
    800038d2:	0004a023          	sw	zero,0(s1)
    800038d6:	4785                	li	a5,1
    800038d8:	c0bc                	sw	a5,64(s1)
    800038da:	00024517          	auipc	a0,0x24
    800038de:	a2650513          	addi	a0,a0,-1498 # 80027300 <bcache>
    800038e2:	ffffd097          	auipc	ra,0xffffd
    800038e6:	3ec080e7          	jalr	1004(ra) # 80000cce <release>
    800038ea:	01048513          	addi	a0,s1,16
    800038ee:	00001097          	auipc	ra,0x1
    800038f2:	40e080e7          	jalr	1038(ra) # 80004cfc <acquiresleep>
    800038f6:	409c                	lw	a5,0(s1)
    800038f8:	cb89                	beqz	a5,8000390a <bread+0xe0>
    800038fa:	8526                	mv	a0,s1
    800038fc:	70a2                	ld	ra,40(sp)
    800038fe:	7402                	ld	s0,32(sp)
    80003900:	64e2                	ld	s1,24(sp)
    80003902:	6942                	ld	s2,16(sp)
    80003904:	69a2                	ld	s3,8(sp)
    80003906:	6145                	addi	sp,sp,48
    80003908:	8082                	ret
    8000390a:	4581                	li	a1,0
    8000390c:	8526                	mv	a0,s1
    8000390e:	00003097          	auipc	ra,0x3
    80003912:	2a4080e7          	jalr	676(ra) # 80006bb2 <virtio_disk_rw>
    80003916:	4785                	li	a5,1
    80003918:	c09c                	sw	a5,0(s1)
    8000391a:	b7c5                	j	800038fa <bread+0xd0>

000000008000391c <bwrite>:
    8000391c:	1101                	addi	sp,sp,-32
    8000391e:	ec06                	sd	ra,24(sp)
    80003920:	e822                	sd	s0,16(sp)
    80003922:	e426                	sd	s1,8(sp)
    80003924:	1000                	addi	s0,sp,32
    80003926:	84aa                	mv	s1,a0
    80003928:	0541                	addi	a0,a0,16
    8000392a:	00001097          	auipc	ra,0x1
    8000392e:	46e080e7          	jalr	1134(ra) # 80004d98 <holdingsleep>
    80003932:	cd01                	beqz	a0,8000394a <bwrite+0x2e>
    80003934:	4585                	li	a1,1
    80003936:	8526                	mv	a0,s1
    80003938:	00003097          	auipc	ra,0x3
    8000393c:	27a080e7          	jalr	634(ra) # 80006bb2 <virtio_disk_rw>
    80003940:	60e2                	ld	ra,24(sp)
    80003942:	6442                	ld	s0,16(sp)
    80003944:	64a2                	ld	s1,8(sp)
    80003946:	6105                	addi	sp,sp,32
    80003948:	8082                	ret
    8000394a:	00006517          	auipc	a0,0x6
    8000394e:	c4e50513          	addi	a0,a0,-946 # 80009598 <syscalls+0x118>
    80003952:	ffffd097          	auipc	ra,0xffffd
    80003956:	bea080e7          	jalr	-1046(ra) # 8000053c <panic>

000000008000395a <brelse>:
    8000395a:	1101                	addi	sp,sp,-32
    8000395c:	ec06                	sd	ra,24(sp)
    8000395e:	e822                	sd	s0,16(sp)
    80003960:	e426                	sd	s1,8(sp)
    80003962:	e04a                	sd	s2,0(sp)
    80003964:	1000                	addi	s0,sp,32
    80003966:	84aa                	mv	s1,a0
    80003968:	01050913          	addi	s2,a0,16
    8000396c:	854a                	mv	a0,s2
    8000396e:	00001097          	auipc	ra,0x1
    80003972:	42a080e7          	jalr	1066(ra) # 80004d98 <holdingsleep>
    80003976:	c92d                	beqz	a0,800039e8 <brelse+0x8e>
    80003978:	854a                	mv	a0,s2
    8000397a:	00001097          	auipc	ra,0x1
    8000397e:	3da080e7          	jalr	986(ra) # 80004d54 <releasesleep>
    80003982:	00024517          	auipc	a0,0x24
    80003986:	97e50513          	addi	a0,a0,-1666 # 80027300 <bcache>
    8000398a:	ffffd097          	auipc	ra,0xffffd
    8000398e:	290080e7          	jalr	656(ra) # 80000c1a <acquire>
    80003992:	40bc                	lw	a5,64(s1)
    80003994:	37fd                	addiw	a5,a5,-1
    80003996:	0007871b          	sext.w	a4,a5
    8000399a:	c0bc                	sw	a5,64(s1)
    8000399c:	eb05                	bnez	a4,800039cc <brelse+0x72>
    8000399e:	68bc                	ld	a5,80(s1)
    800039a0:	64b8                	ld	a4,72(s1)
    800039a2:	e7b8                	sd	a4,72(a5)
    800039a4:	64bc                	ld	a5,72(s1)
    800039a6:	68b8                	ld	a4,80(s1)
    800039a8:	ebb8                	sd	a4,80(a5)
    800039aa:	0002c797          	auipc	a5,0x2c
    800039ae:	95678793          	addi	a5,a5,-1706 # 8002f300 <bcache+0x8000>
    800039b2:	2b87b703          	ld	a4,696(a5)
    800039b6:	e8b8                	sd	a4,80(s1)
    800039b8:	0002c717          	auipc	a4,0x2c
    800039bc:	bb070713          	addi	a4,a4,-1104 # 8002f568 <bcache+0x8268>
    800039c0:	e4b8                	sd	a4,72(s1)
    800039c2:	2b87b703          	ld	a4,696(a5)
    800039c6:	e724                	sd	s1,72(a4)
    800039c8:	2a97bc23          	sd	s1,696(a5)
    800039cc:	00024517          	auipc	a0,0x24
    800039d0:	93450513          	addi	a0,a0,-1740 # 80027300 <bcache>
    800039d4:	ffffd097          	auipc	ra,0xffffd
    800039d8:	2fa080e7          	jalr	762(ra) # 80000cce <release>
    800039dc:	60e2                	ld	ra,24(sp)
    800039de:	6442                	ld	s0,16(sp)
    800039e0:	64a2                	ld	s1,8(sp)
    800039e2:	6902                	ld	s2,0(sp)
    800039e4:	6105                	addi	sp,sp,32
    800039e6:	8082                	ret
    800039e8:	00006517          	auipc	a0,0x6
    800039ec:	bb850513          	addi	a0,a0,-1096 # 800095a0 <syscalls+0x120>
    800039f0:	ffffd097          	auipc	ra,0xffffd
    800039f4:	b4c080e7          	jalr	-1204(ra) # 8000053c <panic>

00000000800039f8 <bpin>:
    800039f8:	1101                	addi	sp,sp,-32
    800039fa:	ec06                	sd	ra,24(sp)
    800039fc:	e822                	sd	s0,16(sp)
    800039fe:	e426                	sd	s1,8(sp)
    80003a00:	1000                	addi	s0,sp,32
    80003a02:	84aa                	mv	s1,a0
    80003a04:	00024517          	auipc	a0,0x24
    80003a08:	8fc50513          	addi	a0,a0,-1796 # 80027300 <bcache>
    80003a0c:	ffffd097          	auipc	ra,0xffffd
    80003a10:	20e080e7          	jalr	526(ra) # 80000c1a <acquire>
    80003a14:	40bc                	lw	a5,64(s1)
    80003a16:	2785                	addiw	a5,a5,1
    80003a18:	c0bc                	sw	a5,64(s1)
    80003a1a:	00024517          	auipc	a0,0x24
    80003a1e:	8e650513          	addi	a0,a0,-1818 # 80027300 <bcache>
    80003a22:	ffffd097          	auipc	ra,0xffffd
    80003a26:	2ac080e7          	jalr	684(ra) # 80000cce <release>
    80003a2a:	60e2                	ld	ra,24(sp)
    80003a2c:	6442                	ld	s0,16(sp)
    80003a2e:	64a2                	ld	s1,8(sp)
    80003a30:	6105                	addi	sp,sp,32
    80003a32:	8082                	ret

0000000080003a34 <bunpin>:
    80003a34:	1101                	addi	sp,sp,-32
    80003a36:	ec06                	sd	ra,24(sp)
    80003a38:	e822                	sd	s0,16(sp)
    80003a3a:	e426                	sd	s1,8(sp)
    80003a3c:	1000                	addi	s0,sp,32
    80003a3e:	84aa                	mv	s1,a0
    80003a40:	00024517          	auipc	a0,0x24
    80003a44:	8c050513          	addi	a0,a0,-1856 # 80027300 <bcache>
    80003a48:	ffffd097          	auipc	ra,0xffffd
    80003a4c:	1d2080e7          	jalr	466(ra) # 80000c1a <acquire>
    80003a50:	40bc                	lw	a5,64(s1)
    80003a52:	37fd                	addiw	a5,a5,-1
    80003a54:	c0bc                	sw	a5,64(s1)
    80003a56:	00024517          	auipc	a0,0x24
    80003a5a:	8aa50513          	addi	a0,a0,-1878 # 80027300 <bcache>
    80003a5e:	ffffd097          	auipc	ra,0xffffd
    80003a62:	270080e7          	jalr	624(ra) # 80000cce <release>
    80003a66:	60e2                	ld	ra,24(sp)
    80003a68:	6442                	ld	s0,16(sp)
    80003a6a:	64a2                	ld	s1,8(sp)
    80003a6c:	6105                	addi	sp,sp,32
    80003a6e:	8082                	ret

0000000080003a70 <bfree>:
    80003a70:	1101                	addi	sp,sp,-32
    80003a72:	ec06                	sd	ra,24(sp)
    80003a74:	e822                	sd	s0,16(sp)
    80003a76:	e426                	sd	s1,8(sp)
    80003a78:	e04a                	sd	s2,0(sp)
    80003a7a:	1000                	addi	s0,sp,32
    80003a7c:	84ae                	mv	s1,a1
    80003a7e:	00d5d59b          	srliw	a1,a1,0xd
    80003a82:	0002c797          	auipc	a5,0x2c
    80003a86:	f5a7a783          	lw	a5,-166(a5) # 8002f9dc <sb+0x1c>
    80003a8a:	9dbd                	addw	a1,a1,a5
    80003a8c:	00000097          	auipc	ra,0x0
    80003a90:	d9e080e7          	jalr	-610(ra) # 8000382a <bread>
    80003a94:	0074f713          	andi	a4,s1,7
    80003a98:	4785                	li	a5,1
    80003a9a:	00e797bb          	sllw	a5,a5,a4
    80003a9e:	14ce                	slli	s1,s1,0x33
    80003aa0:	90d9                	srli	s1,s1,0x36
    80003aa2:	00950733          	add	a4,a0,s1
    80003aa6:	05874703          	lbu	a4,88(a4)
    80003aaa:	00e7f6b3          	and	a3,a5,a4
    80003aae:	c69d                	beqz	a3,80003adc <bfree+0x6c>
    80003ab0:	892a                	mv	s2,a0
    80003ab2:	94aa                	add	s1,s1,a0
    80003ab4:	fff7c793          	not	a5,a5
    80003ab8:	8f7d                	and	a4,a4,a5
    80003aba:	04e48c23          	sb	a4,88(s1)
    80003abe:	00001097          	auipc	ra,0x1
    80003ac2:	120080e7          	jalr	288(ra) # 80004bde <log_write>
    80003ac6:	854a                	mv	a0,s2
    80003ac8:	00000097          	auipc	ra,0x0
    80003acc:	e92080e7          	jalr	-366(ra) # 8000395a <brelse>
    80003ad0:	60e2                	ld	ra,24(sp)
    80003ad2:	6442                	ld	s0,16(sp)
    80003ad4:	64a2                	ld	s1,8(sp)
    80003ad6:	6902                	ld	s2,0(sp)
    80003ad8:	6105                	addi	sp,sp,32
    80003ada:	8082                	ret
    80003adc:	00006517          	auipc	a0,0x6
    80003ae0:	acc50513          	addi	a0,a0,-1332 # 800095a8 <syscalls+0x128>
    80003ae4:	ffffd097          	auipc	ra,0xffffd
    80003ae8:	a58080e7          	jalr	-1448(ra) # 8000053c <panic>

0000000080003aec <balloc>:
    80003aec:	711d                	addi	sp,sp,-96
    80003aee:	ec86                	sd	ra,88(sp)
    80003af0:	e8a2                	sd	s0,80(sp)
    80003af2:	e4a6                	sd	s1,72(sp)
    80003af4:	e0ca                	sd	s2,64(sp)
    80003af6:	fc4e                	sd	s3,56(sp)
    80003af8:	f852                	sd	s4,48(sp)
    80003afa:	f456                	sd	s5,40(sp)
    80003afc:	f05a                	sd	s6,32(sp)
    80003afe:	ec5e                	sd	s7,24(sp)
    80003b00:	e862                	sd	s8,16(sp)
    80003b02:	e466                	sd	s9,8(sp)
    80003b04:	1080                	addi	s0,sp,96
    80003b06:	0002c797          	auipc	a5,0x2c
    80003b0a:	ebe7a783          	lw	a5,-322(a5) # 8002f9c4 <sb+0x4>
    80003b0e:	cbc1                	beqz	a5,80003b9e <balloc+0xb2>
    80003b10:	8baa                	mv	s7,a0
    80003b12:	4a81                	li	s5,0
    80003b14:	0002cb17          	auipc	s6,0x2c
    80003b18:	eacb0b13          	addi	s6,s6,-340 # 8002f9c0 <sb>
    80003b1c:	4c01                	li	s8,0
    80003b1e:	4985                	li	s3,1
    80003b20:	6a09                	lui	s4,0x2
    80003b22:	6c89                	lui	s9,0x2
    80003b24:	a831                	j	80003b40 <balloc+0x54>
    80003b26:	854a                	mv	a0,s2
    80003b28:	00000097          	auipc	ra,0x0
    80003b2c:	e32080e7          	jalr	-462(ra) # 8000395a <brelse>
    80003b30:	015c87bb          	addw	a5,s9,s5
    80003b34:	00078a9b          	sext.w	s5,a5
    80003b38:	004b2703          	lw	a4,4(s6)
    80003b3c:	06eaf163          	bgeu	s5,a4,80003b9e <balloc+0xb2>
    80003b40:	41fad79b          	sraiw	a5,s5,0x1f
    80003b44:	0137d79b          	srliw	a5,a5,0x13
    80003b48:	015787bb          	addw	a5,a5,s5
    80003b4c:	40d7d79b          	sraiw	a5,a5,0xd
    80003b50:	01cb2583          	lw	a1,28(s6)
    80003b54:	9dbd                	addw	a1,a1,a5
    80003b56:	855e                	mv	a0,s7
    80003b58:	00000097          	auipc	ra,0x0
    80003b5c:	cd2080e7          	jalr	-814(ra) # 8000382a <bread>
    80003b60:	892a                	mv	s2,a0
    80003b62:	004b2503          	lw	a0,4(s6)
    80003b66:	000a849b          	sext.w	s1,s5
    80003b6a:	8762                	mv	a4,s8
    80003b6c:	faa4fde3          	bgeu	s1,a0,80003b26 <balloc+0x3a>
    80003b70:	00777693          	andi	a3,a4,7
    80003b74:	00d996bb          	sllw	a3,s3,a3
    80003b78:	41f7579b          	sraiw	a5,a4,0x1f
    80003b7c:	01d7d79b          	srliw	a5,a5,0x1d
    80003b80:	9fb9                	addw	a5,a5,a4
    80003b82:	4037d79b          	sraiw	a5,a5,0x3
    80003b86:	00f90633          	add	a2,s2,a5
    80003b8a:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    80003b8e:	00c6f5b3          	and	a1,a3,a2
    80003b92:	cd91                	beqz	a1,80003bae <balloc+0xc2>
    80003b94:	2705                	addiw	a4,a4,1
    80003b96:	2485                	addiw	s1,s1,1
    80003b98:	fd471ae3          	bne	a4,s4,80003b6c <balloc+0x80>
    80003b9c:	b769                	j	80003b26 <balloc+0x3a>
    80003b9e:	00006517          	auipc	a0,0x6
    80003ba2:	a2250513          	addi	a0,a0,-1502 # 800095c0 <syscalls+0x140>
    80003ba6:	ffffd097          	auipc	ra,0xffffd
    80003baa:	996080e7          	jalr	-1642(ra) # 8000053c <panic>
    80003bae:	97ca                	add	a5,a5,s2
    80003bb0:	8e55                	or	a2,a2,a3
    80003bb2:	04c78c23          	sb	a2,88(a5)
    80003bb6:	854a                	mv	a0,s2
    80003bb8:	00001097          	auipc	ra,0x1
    80003bbc:	026080e7          	jalr	38(ra) # 80004bde <log_write>
    80003bc0:	854a                	mv	a0,s2
    80003bc2:	00000097          	auipc	ra,0x0
    80003bc6:	d98080e7          	jalr	-616(ra) # 8000395a <brelse>
    80003bca:	85a6                	mv	a1,s1
    80003bcc:	855e                	mv	a0,s7
    80003bce:	00000097          	auipc	ra,0x0
    80003bd2:	c5c080e7          	jalr	-932(ra) # 8000382a <bread>
    80003bd6:	892a                	mv	s2,a0
    80003bd8:	40000613          	li	a2,1024
    80003bdc:	4581                	li	a1,0
    80003bde:	05850513          	addi	a0,a0,88
    80003be2:	ffffd097          	auipc	ra,0xffffd
    80003be6:	134080e7          	jalr	308(ra) # 80000d16 <memset>
    80003bea:	854a                	mv	a0,s2
    80003bec:	00001097          	auipc	ra,0x1
    80003bf0:	ff2080e7          	jalr	-14(ra) # 80004bde <log_write>
    80003bf4:	854a                	mv	a0,s2
    80003bf6:	00000097          	auipc	ra,0x0
    80003bfa:	d64080e7          	jalr	-668(ra) # 8000395a <brelse>
    80003bfe:	8526                	mv	a0,s1
    80003c00:	60e6                	ld	ra,88(sp)
    80003c02:	6446                	ld	s0,80(sp)
    80003c04:	64a6                	ld	s1,72(sp)
    80003c06:	6906                	ld	s2,64(sp)
    80003c08:	79e2                	ld	s3,56(sp)
    80003c0a:	7a42                	ld	s4,48(sp)
    80003c0c:	7aa2                	ld	s5,40(sp)
    80003c0e:	7b02                	ld	s6,32(sp)
    80003c10:	6be2                	ld	s7,24(sp)
    80003c12:	6c42                	ld	s8,16(sp)
    80003c14:	6ca2                	ld	s9,8(sp)
    80003c16:	6125                	addi	sp,sp,96
    80003c18:	8082                	ret

0000000080003c1a <bmap>:
    80003c1a:	7179                	addi	sp,sp,-48
    80003c1c:	f406                	sd	ra,40(sp)
    80003c1e:	f022                	sd	s0,32(sp)
    80003c20:	ec26                	sd	s1,24(sp)
    80003c22:	e84a                	sd	s2,16(sp)
    80003c24:	e44e                	sd	s3,8(sp)
    80003c26:	e052                	sd	s4,0(sp)
    80003c28:	1800                	addi	s0,sp,48
    80003c2a:	892a                	mv	s2,a0
    80003c2c:	47ad                	li	a5,11
    80003c2e:	04b7fe63          	bgeu	a5,a1,80003c8a <bmap+0x70>
    80003c32:	ff45849b          	addiw	s1,a1,-12
    80003c36:	0004871b          	sext.w	a4,s1
    80003c3a:	0ff00793          	li	a5,255
    80003c3e:	0ae7e463          	bltu	a5,a4,80003ce6 <bmap+0xcc>
    80003c42:	08052583          	lw	a1,128(a0)
    80003c46:	c5b5                	beqz	a1,80003cb2 <bmap+0x98>
    80003c48:	00092503          	lw	a0,0(s2)
    80003c4c:	00000097          	auipc	ra,0x0
    80003c50:	bde080e7          	jalr	-1058(ra) # 8000382a <bread>
    80003c54:	8a2a                	mv	s4,a0
    80003c56:	05850793          	addi	a5,a0,88
    80003c5a:	02049713          	slli	a4,s1,0x20
    80003c5e:	01e75593          	srli	a1,a4,0x1e
    80003c62:	00b784b3          	add	s1,a5,a1
    80003c66:	0004a983          	lw	s3,0(s1)
    80003c6a:	04098e63          	beqz	s3,80003cc6 <bmap+0xac>
    80003c6e:	8552                	mv	a0,s4
    80003c70:	00000097          	auipc	ra,0x0
    80003c74:	cea080e7          	jalr	-790(ra) # 8000395a <brelse>
    80003c78:	854e                	mv	a0,s3
    80003c7a:	70a2                	ld	ra,40(sp)
    80003c7c:	7402                	ld	s0,32(sp)
    80003c7e:	64e2                	ld	s1,24(sp)
    80003c80:	6942                	ld	s2,16(sp)
    80003c82:	69a2                	ld	s3,8(sp)
    80003c84:	6a02                	ld	s4,0(sp)
    80003c86:	6145                	addi	sp,sp,48
    80003c88:	8082                	ret
    80003c8a:	02059793          	slli	a5,a1,0x20
    80003c8e:	01e7d593          	srli	a1,a5,0x1e
    80003c92:	00b504b3          	add	s1,a0,a1
    80003c96:	0504a983          	lw	s3,80(s1)
    80003c9a:	fc099fe3          	bnez	s3,80003c78 <bmap+0x5e>
    80003c9e:	4108                	lw	a0,0(a0)
    80003ca0:	00000097          	auipc	ra,0x0
    80003ca4:	e4c080e7          	jalr	-436(ra) # 80003aec <balloc>
    80003ca8:	0005099b          	sext.w	s3,a0
    80003cac:	0534a823          	sw	s3,80(s1)
    80003cb0:	b7e1                	j	80003c78 <bmap+0x5e>
    80003cb2:	4108                	lw	a0,0(a0)
    80003cb4:	00000097          	auipc	ra,0x0
    80003cb8:	e38080e7          	jalr	-456(ra) # 80003aec <balloc>
    80003cbc:	0005059b          	sext.w	a1,a0
    80003cc0:	08b92023          	sw	a1,128(s2)
    80003cc4:	b751                	j	80003c48 <bmap+0x2e>
    80003cc6:	00092503          	lw	a0,0(s2)
    80003cca:	00000097          	auipc	ra,0x0
    80003cce:	e22080e7          	jalr	-478(ra) # 80003aec <balloc>
    80003cd2:	0005099b          	sext.w	s3,a0
    80003cd6:	0134a023          	sw	s3,0(s1)
    80003cda:	8552                	mv	a0,s4
    80003cdc:	00001097          	auipc	ra,0x1
    80003ce0:	f02080e7          	jalr	-254(ra) # 80004bde <log_write>
    80003ce4:	b769                	j	80003c6e <bmap+0x54>
    80003ce6:	00006517          	auipc	a0,0x6
    80003cea:	8f250513          	addi	a0,a0,-1806 # 800095d8 <syscalls+0x158>
    80003cee:	ffffd097          	auipc	ra,0xffffd
    80003cf2:	84e080e7          	jalr	-1970(ra) # 8000053c <panic>

0000000080003cf6 <iget>:
    80003cf6:	7179                	addi	sp,sp,-48
    80003cf8:	f406                	sd	ra,40(sp)
    80003cfa:	f022                	sd	s0,32(sp)
    80003cfc:	ec26                	sd	s1,24(sp)
    80003cfe:	e84a                	sd	s2,16(sp)
    80003d00:	e44e                	sd	s3,8(sp)
    80003d02:	e052                	sd	s4,0(sp)
    80003d04:	1800                	addi	s0,sp,48
    80003d06:	89aa                	mv	s3,a0
    80003d08:	8a2e                	mv	s4,a1
    80003d0a:	0002c517          	auipc	a0,0x2c
    80003d0e:	cd650513          	addi	a0,a0,-810 # 8002f9e0 <itable>
    80003d12:	ffffd097          	auipc	ra,0xffffd
    80003d16:	f08080e7          	jalr	-248(ra) # 80000c1a <acquire>
    80003d1a:	4901                	li	s2,0
    80003d1c:	0002c497          	auipc	s1,0x2c
    80003d20:	cdc48493          	addi	s1,s1,-804 # 8002f9f8 <itable+0x18>
    80003d24:	0002d697          	auipc	a3,0x2d
    80003d28:	76468693          	addi	a3,a3,1892 # 80031488 <log>
    80003d2c:	a039                	j	80003d3a <iget+0x44>
    80003d2e:	02090b63          	beqz	s2,80003d64 <iget+0x6e>
    80003d32:	08848493          	addi	s1,s1,136
    80003d36:	02d48a63          	beq	s1,a3,80003d6a <iget+0x74>
    80003d3a:	449c                	lw	a5,8(s1)
    80003d3c:	fef059e3          	blez	a5,80003d2e <iget+0x38>
    80003d40:	4098                	lw	a4,0(s1)
    80003d42:	ff3716e3          	bne	a4,s3,80003d2e <iget+0x38>
    80003d46:	40d8                	lw	a4,4(s1)
    80003d48:	ff4713e3          	bne	a4,s4,80003d2e <iget+0x38>
    80003d4c:	2785                	addiw	a5,a5,1
    80003d4e:	c49c                	sw	a5,8(s1)
    80003d50:	0002c517          	auipc	a0,0x2c
    80003d54:	c9050513          	addi	a0,a0,-880 # 8002f9e0 <itable>
    80003d58:	ffffd097          	auipc	ra,0xffffd
    80003d5c:	f76080e7          	jalr	-138(ra) # 80000cce <release>
    80003d60:	8926                	mv	s2,s1
    80003d62:	a03d                	j	80003d90 <iget+0x9a>
    80003d64:	f7f9                	bnez	a5,80003d32 <iget+0x3c>
    80003d66:	8926                	mv	s2,s1
    80003d68:	b7e9                	j	80003d32 <iget+0x3c>
    80003d6a:	02090c63          	beqz	s2,80003da2 <iget+0xac>
    80003d6e:	01392023          	sw	s3,0(s2)
    80003d72:	01492223          	sw	s4,4(s2)
    80003d76:	4785                	li	a5,1
    80003d78:	00f92423          	sw	a5,8(s2)
    80003d7c:	04092023          	sw	zero,64(s2)
    80003d80:	0002c517          	auipc	a0,0x2c
    80003d84:	c6050513          	addi	a0,a0,-928 # 8002f9e0 <itable>
    80003d88:	ffffd097          	auipc	ra,0xffffd
    80003d8c:	f46080e7          	jalr	-186(ra) # 80000cce <release>
    80003d90:	854a                	mv	a0,s2
    80003d92:	70a2                	ld	ra,40(sp)
    80003d94:	7402                	ld	s0,32(sp)
    80003d96:	64e2                	ld	s1,24(sp)
    80003d98:	6942                	ld	s2,16(sp)
    80003d9a:	69a2                	ld	s3,8(sp)
    80003d9c:	6a02                	ld	s4,0(sp)
    80003d9e:	6145                	addi	sp,sp,48
    80003da0:	8082                	ret
    80003da2:	00006517          	auipc	a0,0x6
    80003da6:	84e50513          	addi	a0,a0,-1970 # 800095f0 <syscalls+0x170>
    80003daa:	ffffc097          	auipc	ra,0xffffc
    80003dae:	792080e7          	jalr	1938(ra) # 8000053c <panic>

0000000080003db2 <fsinit>:
    80003db2:	7179                	addi	sp,sp,-48
    80003db4:	f406                	sd	ra,40(sp)
    80003db6:	f022                	sd	s0,32(sp)
    80003db8:	ec26                	sd	s1,24(sp)
    80003dba:	e84a                	sd	s2,16(sp)
    80003dbc:	e44e                	sd	s3,8(sp)
    80003dbe:	1800                	addi	s0,sp,48
    80003dc0:	892a                	mv	s2,a0
    80003dc2:	4585                	li	a1,1
    80003dc4:	00000097          	auipc	ra,0x0
    80003dc8:	a66080e7          	jalr	-1434(ra) # 8000382a <bread>
    80003dcc:	84aa                	mv	s1,a0
    80003dce:	0002c997          	auipc	s3,0x2c
    80003dd2:	bf298993          	addi	s3,s3,-1038 # 8002f9c0 <sb>
    80003dd6:	02000613          	li	a2,32
    80003dda:	05850593          	addi	a1,a0,88
    80003dde:	854e                	mv	a0,s3
    80003de0:	ffffd097          	auipc	ra,0xffffd
    80003de4:	f92080e7          	jalr	-110(ra) # 80000d72 <memmove>
    80003de8:	8526                	mv	a0,s1
    80003dea:	00000097          	auipc	ra,0x0
    80003dee:	b70080e7          	jalr	-1168(ra) # 8000395a <brelse>
    80003df2:	0009a703          	lw	a4,0(s3)
    80003df6:	102037b7          	lui	a5,0x10203
    80003dfa:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003dfe:	02f71263          	bne	a4,a5,80003e22 <fsinit+0x70>
    80003e02:	0002c597          	auipc	a1,0x2c
    80003e06:	bbe58593          	addi	a1,a1,-1090 # 8002f9c0 <sb>
    80003e0a:	854a                	mv	a0,s2
    80003e0c:	00001097          	auipc	ra,0x1
    80003e10:	b56080e7          	jalr	-1194(ra) # 80004962 <initlog>
    80003e14:	70a2                	ld	ra,40(sp)
    80003e16:	7402                	ld	s0,32(sp)
    80003e18:	64e2                	ld	s1,24(sp)
    80003e1a:	6942                	ld	s2,16(sp)
    80003e1c:	69a2                	ld	s3,8(sp)
    80003e1e:	6145                	addi	sp,sp,48
    80003e20:	8082                	ret
    80003e22:	00005517          	auipc	a0,0x5
    80003e26:	7de50513          	addi	a0,a0,2014 # 80009600 <syscalls+0x180>
    80003e2a:	ffffc097          	auipc	ra,0xffffc
    80003e2e:	712080e7          	jalr	1810(ra) # 8000053c <panic>

0000000080003e32 <iinit>:
    80003e32:	7179                	addi	sp,sp,-48
    80003e34:	f406                	sd	ra,40(sp)
    80003e36:	f022                	sd	s0,32(sp)
    80003e38:	ec26                	sd	s1,24(sp)
    80003e3a:	e84a                	sd	s2,16(sp)
    80003e3c:	e44e                	sd	s3,8(sp)
    80003e3e:	1800                	addi	s0,sp,48
    80003e40:	00005597          	auipc	a1,0x5
    80003e44:	7d858593          	addi	a1,a1,2008 # 80009618 <syscalls+0x198>
    80003e48:	0002c517          	auipc	a0,0x2c
    80003e4c:	b9850513          	addi	a0,a0,-1128 # 8002f9e0 <itable>
    80003e50:	ffffd097          	auipc	ra,0xffffd
    80003e54:	d3a080e7          	jalr	-710(ra) # 80000b8a <initlock>
    80003e58:	0002c497          	auipc	s1,0x2c
    80003e5c:	bb048493          	addi	s1,s1,-1104 # 8002fa08 <itable+0x28>
    80003e60:	0002d997          	auipc	s3,0x2d
    80003e64:	63898993          	addi	s3,s3,1592 # 80031498 <log+0x10>
    80003e68:	00005917          	auipc	s2,0x5
    80003e6c:	7b890913          	addi	s2,s2,1976 # 80009620 <syscalls+0x1a0>
    80003e70:	85ca                	mv	a1,s2
    80003e72:	8526                	mv	a0,s1
    80003e74:	00001097          	auipc	ra,0x1
    80003e78:	e4e080e7          	jalr	-434(ra) # 80004cc2 <initsleeplock>
    80003e7c:	08848493          	addi	s1,s1,136
    80003e80:	ff3498e3          	bne	s1,s3,80003e70 <iinit+0x3e>
    80003e84:	70a2                	ld	ra,40(sp)
    80003e86:	7402                	ld	s0,32(sp)
    80003e88:	64e2                	ld	s1,24(sp)
    80003e8a:	6942                	ld	s2,16(sp)
    80003e8c:	69a2                	ld	s3,8(sp)
    80003e8e:	6145                	addi	sp,sp,48
    80003e90:	8082                	ret

0000000080003e92 <ialloc>:
    80003e92:	715d                	addi	sp,sp,-80
    80003e94:	e486                	sd	ra,72(sp)
    80003e96:	e0a2                	sd	s0,64(sp)
    80003e98:	fc26                	sd	s1,56(sp)
    80003e9a:	f84a                	sd	s2,48(sp)
    80003e9c:	f44e                	sd	s3,40(sp)
    80003e9e:	f052                	sd	s4,32(sp)
    80003ea0:	ec56                	sd	s5,24(sp)
    80003ea2:	e85a                	sd	s6,16(sp)
    80003ea4:	e45e                	sd	s7,8(sp)
    80003ea6:	0880                	addi	s0,sp,80
    80003ea8:	0002c717          	auipc	a4,0x2c
    80003eac:	b2472703          	lw	a4,-1244(a4) # 8002f9cc <sb+0xc>
    80003eb0:	4785                	li	a5,1
    80003eb2:	04e7fa63          	bgeu	a5,a4,80003f06 <ialloc+0x74>
    80003eb6:	8aaa                	mv	s5,a0
    80003eb8:	8bae                	mv	s7,a1
    80003eba:	4485                	li	s1,1
    80003ebc:	0002ca17          	auipc	s4,0x2c
    80003ec0:	b04a0a13          	addi	s4,s4,-1276 # 8002f9c0 <sb>
    80003ec4:	00048b1b          	sext.w	s6,s1
    80003ec8:	0044d593          	srli	a1,s1,0x4
    80003ecc:	018a2783          	lw	a5,24(s4)
    80003ed0:	9dbd                	addw	a1,a1,a5
    80003ed2:	8556                	mv	a0,s5
    80003ed4:	00000097          	auipc	ra,0x0
    80003ed8:	956080e7          	jalr	-1706(ra) # 8000382a <bread>
    80003edc:	892a                	mv	s2,a0
    80003ede:	05850993          	addi	s3,a0,88
    80003ee2:	00f4f793          	andi	a5,s1,15
    80003ee6:	079a                	slli	a5,a5,0x6
    80003ee8:	99be                	add	s3,s3,a5
    80003eea:	00099783          	lh	a5,0(s3)
    80003eee:	c785                	beqz	a5,80003f16 <ialloc+0x84>
    80003ef0:	00000097          	auipc	ra,0x0
    80003ef4:	a6a080e7          	jalr	-1430(ra) # 8000395a <brelse>
    80003ef8:	0485                	addi	s1,s1,1
    80003efa:	00ca2703          	lw	a4,12(s4)
    80003efe:	0004879b          	sext.w	a5,s1
    80003f02:	fce7e1e3          	bltu	a5,a4,80003ec4 <ialloc+0x32>
    80003f06:	00005517          	auipc	a0,0x5
    80003f0a:	72250513          	addi	a0,a0,1826 # 80009628 <syscalls+0x1a8>
    80003f0e:	ffffc097          	auipc	ra,0xffffc
    80003f12:	62e080e7          	jalr	1582(ra) # 8000053c <panic>
    80003f16:	04000613          	li	a2,64
    80003f1a:	4581                	li	a1,0
    80003f1c:	854e                	mv	a0,s3
    80003f1e:	ffffd097          	auipc	ra,0xffffd
    80003f22:	df8080e7          	jalr	-520(ra) # 80000d16 <memset>
    80003f26:	01799023          	sh	s7,0(s3)
    80003f2a:	854a                	mv	a0,s2
    80003f2c:	00001097          	auipc	ra,0x1
    80003f30:	cb2080e7          	jalr	-846(ra) # 80004bde <log_write>
    80003f34:	854a                	mv	a0,s2
    80003f36:	00000097          	auipc	ra,0x0
    80003f3a:	a24080e7          	jalr	-1500(ra) # 8000395a <brelse>
    80003f3e:	85da                	mv	a1,s6
    80003f40:	8556                	mv	a0,s5
    80003f42:	00000097          	auipc	ra,0x0
    80003f46:	db4080e7          	jalr	-588(ra) # 80003cf6 <iget>
    80003f4a:	60a6                	ld	ra,72(sp)
    80003f4c:	6406                	ld	s0,64(sp)
    80003f4e:	74e2                	ld	s1,56(sp)
    80003f50:	7942                	ld	s2,48(sp)
    80003f52:	79a2                	ld	s3,40(sp)
    80003f54:	7a02                	ld	s4,32(sp)
    80003f56:	6ae2                	ld	s5,24(sp)
    80003f58:	6b42                	ld	s6,16(sp)
    80003f5a:	6ba2                	ld	s7,8(sp)
    80003f5c:	6161                	addi	sp,sp,80
    80003f5e:	8082                	ret

0000000080003f60 <iupdate>:
    80003f60:	1101                	addi	sp,sp,-32
    80003f62:	ec06                	sd	ra,24(sp)
    80003f64:	e822                	sd	s0,16(sp)
    80003f66:	e426                	sd	s1,8(sp)
    80003f68:	e04a                	sd	s2,0(sp)
    80003f6a:	1000                	addi	s0,sp,32
    80003f6c:	84aa                	mv	s1,a0
    80003f6e:	415c                	lw	a5,4(a0)
    80003f70:	0047d79b          	srliw	a5,a5,0x4
    80003f74:	0002c597          	auipc	a1,0x2c
    80003f78:	a645a583          	lw	a1,-1436(a1) # 8002f9d8 <sb+0x18>
    80003f7c:	9dbd                	addw	a1,a1,a5
    80003f7e:	4108                	lw	a0,0(a0)
    80003f80:	00000097          	auipc	ra,0x0
    80003f84:	8aa080e7          	jalr	-1878(ra) # 8000382a <bread>
    80003f88:	892a                	mv	s2,a0
    80003f8a:	05850793          	addi	a5,a0,88
    80003f8e:	40d8                	lw	a4,4(s1)
    80003f90:	8b3d                	andi	a4,a4,15
    80003f92:	071a                	slli	a4,a4,0x6
    80003f94:	97ba                	add	a5,a5,a4
    80003f96:	04449703          	lh	a4,68(s1)
    80003f9a:	00e79023          	sh	a4,0(a5)
    80003f9e:	04649703          	lh	a4,70(s1)
    80003fa2:	00e79123          	sh	a4,2(a5)
    80003fa6:	04849703          	lh	a4,72(s1)
    80003faa:	00e79223          	sh	a4,4(a5)
    80003fae:	04a49703          	lh	a4,74(s1)
    80003fb2:	00e79323          	sh	a4,6(a5)
    80003fb6:	44f8                	lw	a4,76(s1)
    80003fb8:	c798                	sw	a4,8(a5)
    80003fba:	03400613          	li	a2,52
    80003fbe:	05048593          	addi	a1,s1,80
    80003fc2:	00c78513          	addi	a0,a5,12
    80003fc6:	ffffd097          	auipc	ra,0xffffd
    80003fca:	dac080e7          	jalr	-596(ra) # 80000d72 <memmove>
    80003fce:	854a                	mv	a0,s2
    80003fd0:	00001097          	auipc	ra,0x1
    80003fd4:	c0e080e7          	jalr	-1010(ra) # 80004bde <log_write>
    80003fd8:	854a                	mv	a0,s2
    80003fda:	00000097          	auipc	ra,0x0
    80003fde:	980080e7          	jalr	-1664(ra) # 8000395a <brelse>
    80003fe2:	60e2                	ld	ra,24(sp)
    80003fe4:	6442                	ld	s0,16(sp)
    80003fe6:	64a2                	ld	s1,8(sp)
    80003fe8:	6902                	ld	s2,0(sp)
    80003fea:	6105                	addi	sp,sp,32
    80003fec:	8082                	ret

0000000080003fee <idup>:
    80003fee:	1101                	addi	sp,sp,-32
    80003ff0:	ec06                	sd	ra,24(sp)
    80003ff2:	e822                	sd	s0,16(sp)
    80003ff4:	e426                	sd	s1,8(sp)
    80003ff6:	1000                	addi	s0,sp,32
    80003ff8:	84aa                	mv	s1,a0
    80003ffa:	0002c517          	auipc	a0,0x2c
    80003ffe:	9e650513          	addi	a0,a0,-1562 # 8002f9e0 <itable>
    80004002:	ffffd097          	auipc	ra,0xffffd
    80004006:	c18080e7          	jalr	-1000(ra) # 80000c1a <acquire>
    8000400a:	449c                	lw	a5,8(s1)
    8000400c:	2785                	addiw	a5,a5,1
    8000400e:	c49c                	sw	a5,8(s1)
    80004010:	0002c517          	auipc	a0,0x2c
    80004014:	9d050513          	addi	a0,a0,-1584 # 8002f9e0 <itable>
    80004018:	ffffd097          	auipc	ra,0xffffd
    8000401c:	cb6080e7          	jalr	-842(ra) # 80000cce <release>
    80004020:	8526                	mv	a0,s1
    80004022:	60e2                	ld	ra,24(sp)
    80004024:	6442                	ld	s0,16(sp)
    80004026:	64a2                	ld	s1,8(sp)
    80004028:	6105                	addi	sp,sp,32
    8000402a:	8082                	ret

000000008000402c <ilock>:
    8000402c:	1101                	addi	sp,sp,-32
    8000402e:	ec06                	sd	ra,24(sp)
    80004030:	e822                	sd	s0,16(sp)
    80004032:	e426                	sd	s1,8(sp)
    80004034:	e04a                	sd	s2,0(sp)
    80004036:	1000                	addi	s0,sp,32
    80004038:	c115                	beqz	a0,8000405c <ilock+0x30>
    8000403a:	84aa                	mv	s1,a0
    8000403c:	451c                	lw	a5,8(a0)
    8000403e:	00f05f63          	blez	a5,8000405c <ilock+0x30>
    80004042:	0541                	addi	a0,a0,16
    80004044:	00001097          	auipc	ra,0x1
    80004048:	cb8080e7          	jalr	-840(ra) # 80004cfc <acquiresleep>
    8000404c:	40bc                	lw	a5,64(s1)
    8000404e:	cf99                	beqz	a5,8000406c <ilock+0x40>
    80004050:	60e2                	ld	ra,24(sp)
    80004052:	6442                	ld	s0,16(sp)
    80004054:	64a2                	ld	s1,8(sp)
    80004056:	6902                	ld	s2,0(sp)
    80004058:	6105                	addi	sp,sp,32
    8000405a:	8082                	ret
    8000405c:	00005517          	auipc	a0,0x5
    80004060:	5e450513          	addi	a0,a0,1508 # 80009640 <syscalls+0x1c0>
    80004064:	ffffc097          	auipc	ra,0xffffc
    80004068:	4d8080e7          	jalr	1240(ra) # 8000053c <panic>
    8000406c:	40dc                	lw	a5,4(s1)
    8000406e:	0047d79b          	srliw	a5,a5,0x4
    80004072:	0002c597          	auipc	a1,0x2c
    80004076:	9665a583          	lw	a1,-1690(a1) # 8002f9d8 <sb+0x18>
    8000407a:	9dbd                	addw	a1,a1,a5
    8000407c:	4088                	lw	a0,0(s1)
    8000407e:	fffff097          	auipc	ra,0xfffff
    80004082:	7ac080e7          	jalr	1964(ra) # 8000382a <bread>
    80004086:	892a                	mv	s2,a0
    80004088:	05850593          	addi	a1,a0,88
    8000408c:	40dc                	lw	a5,4(s1)
    8000408e:	8bbd                	andi	a5,a5,15
    80004090:	079a                	slli	a5,a5,0x6
    80004092:	95be                	add	a1,a1,a5
    80004094:	00059783          	lh	a5,0(a1)
    80004098:	04f49223          	sh	a5,68(s1)
    8000409c:	00259783          	lh	a5,2(a1)
    800040a0:	04f49323          	sh	a5,70(s1)
    800040a4:	00459783          	lh	a5,4(a1)
    800040a8:	04f49423          	sh	a5,72(s1)
    800040ac:	00659783          	lh	a5,6(a1)
    800040b0:	04f49523          	sh	a5,74(s1)
    800040b4:	459c                	lw	a5,8(a1)
    800040b6:	c4fc                	sw	a5,76(s1)
    800040b8:	03400613          	li	a2,52
    800040bc:	05b1                	addi	a1,a1,12
    800040be:	05048513          	addi	a0,s1,80
    800040c2:	ffffd097          	auipc	ra,0xffffd
    800040c6:	cb0080e7          	jalr	-848(ra) # 80000d72 <memmove>
    800040ca:	854a                	mv	a0,s2
    800040cc:	00000097          	auipc	ra,0x0
    800040d0:	88e080e7          	jalr	-1906(ra) # 8000395a <brelse>
    800040d4:	4785                	li	a5,1
    800040d6:	c0bc                	sw	a5,64(s1)
    800040d8:	04449783          	lh	a5,68(s1)
    800040dc:	fbb5                	bnez	a5,80004050 <ilock+0x24>
    800040de:	00005517          	auipc	a0,0x5
    800040e2:	56a50513          	addi	a0,a0,1386 # 80009648 <syscalls+0x1c8>
    800040e6:	ffffc097          	auipc	ra,0xffffc
    800040ea:	456080e7          	jalr	1110(ra) # 8000053c <panic>

00000000800040ee <iunlock>:
    800040ee:	1101                	addi	sp,sp,-32
    800040f0:	ec06                	sd	ra,24(sp)
    800040f2:	e822                	sd	s0,16(sp)
    800040f4:	e426                	sd	s1,8(sp)
    800040f6:	e04a                	sd	s2,0(sp)
    800040f8:	1000                	addi	s0,sp,32
    800040fa:	c905                	beqz	a0,8000412a <iunlock+0x3c>
    800040fc:	84aa                	mv	s1,a0
    800040fe:	01050913          	addi	s2,a0,16
    80004102:	854a                	mv	a0,s2
    80004104:	00001097          	auipc	ra,0x1
    80004108:	c94080e7          	jalr	-876(ra) # 80004d98 <holdingsleep>
    8000410c:	cd19                	beqz	a0,8000412a <iunlock+0x3c>
    8000410e:	449c                	lw	a5,8(s1)
    80004110:	00f05d63          	blez	a5,8000412a <iunlock+0x3c>
    80004114:	854a                	mv	a0,s2
    80004116:	00001097          	auipc	ra,0x1
    8000411a:	c3e080e7          	jalr	-962(ra) # 80004d54 <releasesleep>
    8000411e:	60e2                	ld	ra,24(sp)
    80004120:	6442                	ld	s0,16(sp)
    80004122:	64a2                	ld	s1,8(sp)
    80004124:	6902                	ld	s2,0(sp)
    80004126:	6105                	addi	sp,sp,32
    80004128:	8082                	ret
    8000412a:	00005517          	auipc	a0,0x5
    8000412e:	52e50513          	addi	a0,a0,1326 # 80009658 <syscalls+0x1d8>
    80004132:	ffffc097          	auipc	ra,0xffffc
    80004136:	40a080e7          	jalr	1034(ra) # 8000053c <panic>

000000008000413a <itrunc>:
    8000413a:	7179                	addi	sp,sp,-48
    8000413c:	f406                	sd	ra,40(sp)
    8000413e:	f022                	sd	s0,32(sp)
    80004140:	ec26                	sd	s1,24(sp)
    80004142:	e84a                	sd	s2,16(sp)
    80004144:	e44e                	sd	s3,8(sp)
    80004146:	e052                	sd	s4,0(sp)
    80004148:	1800                	addi	s0,sp,48
    8000414a:	89aa                	mv	s3,a0
    8000414c:	05050493          	addi	s1,a0,80
    80004150:	08050913          	addi	s2,a0,128
    80004154:	a021                	j	8000415c <itrunc+0x22>
    80004156:	0491                	addi	s1,s1,4
    80004158:	01248d63          	beq	s1,s2,80004172 <itrunc+0x38>
    8000415c:	408c                	lw	a1,0(s1)
    8000415e:	dde5                	beqz	a1,80004156 <itrunc+0x1c>
    80004160:	0009a503          	lw	a0,0(s3)
    80004164:	00000097          	auipc	ra,0x0
    80004168:	90c080e7          	jalr	-1780(ra) # 80003a70 <bfree>
    8000416c:	0004a023          	sw	zero,0(s1)
    80004170:	b7dd                	j	80004156 <itrunc+0x1c>
    80004172:	0809a583          	lw	a1,128(s3)
    80004176:	e185                	bnez	a1,80004196 <itrunc+0x5c>
    80004178:	0409a623          	sw	zero,76(s3)
    8000417c:	854e                	mv	a0,s3
    8000417e:	00000097          	auipc	ra,0x0
    80004182:	de2080e7          	jalr	-542(ra) # 80003f60 <iupdate>
    80004186:	70a2                	ld	ra,40(sp)
    80004188:	7402                	ld	s0,32(sp)
    8000418a:	64e2                	ld	s1,24(sp)
    8000418c:	6942                	ld	s2,16(sp)
    8000418e:	69a2                	ld	s3,8(sp)
    80004190:	6a02                	ld	s4,0(sp)
    80004192:	6145                	addi	sp,sp,48
    80004194:	8082                	ret
    80004196:	0009a503          	lw	a0,0(s3)
    8000419a:	fffff097          	auipc	ra,0xfffff
    8000419e:	690080e7          	jalr	1680(ra) # 8000382a <bread>
    800041a2:	8a2a                	mv	s4,a0
    800041a4:	05850493          	addi	s1,a0,88
    800041a8:	45850913          	addi	s2,a0,1112
    800041ac:	a021                	j	800041b4 <itrunc+0x7a>
    800041ae:	0491                	addi	s1,s1,4
    800041b0:	01248b63          	beq	s1,s2,800041c6 <itrunc+0x8c>
    800041b4:	408c                	lw	a1,0(s1)
    800041b6:	dde5                	beqz	a1,800041ae <itrunc+0x74>
    800041b8:	0009a503          	lw	a0,0(s3)
    800041bc:	00000097          	auipc	ra,0x0
    800041c0:	8b4080e7          	jalr	-1868(ra) # 80003a70 <bfree>
    800041c4:	b7ed                	j	800041ae <itrunc+0x74>
    800041c6:	8552                	mv	a0,s4
    800041c8:	fffff097          	auipc	ra,0xfffff
    800041cc:	792080e7          	jalr	1938(ra) # 8000395a <brelse>
    800041d0:	0809a583          	lw	a1,128(s3)
    800041d4:	0009a503          	lw	a0,0(s3)
    800041d8:	00000097          	auipc	ra,0x0
    800041dc:	898080e7          	jalr	-1896(ra) # 80003a70 <bfree>
    800041e0:	0809a023          	sw	zero,128(s3)
    800041e4:	bf51                	j	80004178 <itrunc+0x3e>

00000000800041e6 <iput>:
    800041e6:	1101                	addi	sp,sp,-32
    800041e8:	ec06                	sd	ra,24(sp)
    800041ea:	e822                	sd	s0,16(sp)
    800041ec:	e426                	sd	s1,8(sp)
    800041ee:	e04a                	sd	s2,0(sp)
    800041f0:	1000                	addi	s0,sp,32
    800041f2:	84aa                	mv	s1,a0
    800041f4:	0002b517          	auipc	a0,0x2b
    800041f8:	7ec50513          	addi	a0,a0,2028 # 8002f9e0 <itable>
    800041fc:	ffffd097          	auipc	ra,0xffffd
    80004200:	a1e080e7          	jalr	-1506(ra) # 80000c1a <acquire>
    80004204:	4498                	lw	a4,8(s1)
    80004206:	4785                	li	a5,1
    80004208:	02f70363          	beq	a4,a5,8000422e <iput+0x48>
    8000420c:	449c                	lw	a5,8(s1)
    8000420e:	37fd                	addiw	a5,a5,-1
    80004210:	c49c                	sw	a5,8(s1)
    80004212:	0002b517          	auipc	a0,0x2b
    80004216:	7ce50513          	addi	a0,a0,1998 # 8002f9e0 <itable>
    8000421a:	ffffd097          	auipc	ra,0xffffd
    8000421e:	ab4080e7          	jalr	-1356(ra) # 80000cce <release>
    80004222:	60e2                	ld	ra,24(sp)
    80004224:	6442                	ld	s0,16(sp)
    80004226:	64a2                	ld	s1,8(sp)
    80004228:	6902                	ld	s2,0(sp)
    8000422a:	6105                	addi	sp,sp,32
    8000422c:	8082                	ret
    8000422e:	40bc                	lw	a5,64(s1)
    80004230:	dff1                	beqz	a5,8000420c <iput+0x26>
    80004232:	04a49783          	lh	a5,74(s1)
    80004236:	fbf9                	bnez	a5,8000420c <iput+0x26>
    80004238:	01048913          	addi	s2,s1,16
    8000423c:	854a                	mv	a0,s2
    8000423e:	00001097          	auipc	ra,0x1
    80004242:	abe080e7          	jalr	-1346(ra) # 80004cfc <acquiresleep>
    80004246:	0002b517          	auipc	a0,0x2b
    8000424a:	79a50513          	addi	a0,a0,1946 # 8002f9e0 <itable>
    8000424e:	ffffd097          	auipc	ra,0xffffd
    80004252:	a80080e7          	jalr	-1408(ra) # 80000cce <release>
    80004256:	8526                	mv	a0,s1
    80004258:	00000097          	auipc	ra,0x0
    8000425c:	ee2080e7          	jalr	-286(ra) # 8000413a <itrunc>
    80004260:	04049223          	sh	zero,68(s1)
    80004264:	8526                	mv	a0,s1
    80004266:	00000097          	auipc	ra,0x0
    8000426a:	cfa080e7          	jalr	-774(ra) # 80003f60 <iupdate>
    8000426e:	0404a023          	sw	zero,64(s1)
    80004272:	854a                	mv	a0,s2
    80004274:	00001097          	auipc	ra,0x1
    80004278:	ae0080e7          	jalr	-1312(ra) # 80004d54 <releasesleep>
    8000427c:	0002b517          	auipc	a0,0x2b
    80004280:	76450513          	addi	a0,a0,1892 # 8002f9e0 <itable>
    80004284:	ffffd097          	auipc	ra,0xffffd
    80004288:	996080e7          	jalr	-1642(ra) # 80000c1a <acquire>
    8000428c:	b741                	j	8000420c <iput+0x26>

000000008000428e <iunlockput>:
    8000428e:	1101                	addi	sp,sp,-32
    80004290:	ec06                	sd	ra,24(sp)
    80004292:	e822                	sd	s0,16(sp)
    80004294:	e426                	sd	s1,8(sp)
    80004296:	1000                	addi	s0,sp,32
    80004298:	84aa                	mv	s1,a0
    8000429a:	00000097          	auipc	ra,0x0
    8000429e:	e54080e7          	jalr	-428(ra) # 800040ee <iunlock>
    800042a2:	8526                	mv	a0,s1
    800042a4:	00000097          	auipc	ra,0x0
    800042a8:	f42080e7          	jalr	-190(ra) # 800041e6 <iput>
    800042ac:	60e2                	ld	ra,24(sp)
    800042ae:	6442                	ld	s0,16(sp)
    800042b0:	64a2                	ld	s1,8(sp)
    800042b2:	6105                	addi	sp,sp,32
    800042b4:	8082                	ret

00000000800042b6 <stati>:
    800042b6:	1141                	addi	sp,sp,-16
    800042b8:	e422                	sd	s0,8(sp)
    800042ba:	0800                	addi	s0,sp,16
    800042bc:	411c                	lw	a5,0(a0)
    800042be:	c19c                	sw	a5,0(a1)
    800042c0:	415c                	lw	a5,4(a0)
    800042c2:	c1dc                	sw	a5,4(a1)
    800042c4:	04451783          	lh	a5,68(a0)
    800042c8:	00f59423          	sh	a5,8(a1)
    800042cc:	04a51783          	lh	a5,74(a0)
    800042d0:	00f59523          	sh	a5,10(a1)
    800042d4:	04c56783          	lwu	a5,76(a0)
    800042d8:	e99c                	sd	a5,16(a1)
    800042da:	6422                	ld	s0,8(sp)
    800042dc:	0141                	addi	sp,sp,16
    800042de:	8082                	ret

00000000800042e0 <readi>:
    800042e0:	457c                	lw	a5,76(a0)
    800042e2:	0ed7e963          	bltu	a5,a3,800043d4 <readi+0xf4>
    800042e6:	7159                	addi	sp,sp,-112
    800042e8:	f486                	sd	ra,104(sp)
    800042ea:	f0a2                	sd	s0,96(sp)
    800042ec:	eca6                	sd	s1,88(sp)
    800042ee:	e8ca                	sd	s2,80(sp)
    800042f0:	e4ce                	sd	s3,72(sp)
    800042f2:	e0d2                	sd	s4,64(sp)
    800042f4:	fc56                	sd	s5,56(sp)
    800042f6:	f85a                	sd	s6,48(sp)
    800042f8:	f45e                	sd	s7,40(sp)
    800042fa:	f062                	sd	s8,32(sp)
    800042fc:	ec66                	sd	s9,24(sp)
    800042fe:	e86a                	sd	s10,16(sp)
    80004300:	e46e                	sd	s11,8(sp)
    80004302:	1880                	addi	s0,sp,112
    80004304:	8baa                	mv	s7,a0
    80004306:	8c2e                	mv	s8,a1
    80004308:	8ab2                	mv	s5,a2
    8000430a:	84b6                	mv	s1,a3
    8000430c:	8b3a                	mv	s6,a4
    8000430e:	9f35                	addw	a4,a4,a3
    80004310:	4501                	li	a0,0
    80004312:	0ad76063          	bltu	a4,a3,800043b2 <readi+0xd2>
    80004316:	00e7f463          	bgeu	a5,a4,8000431e <readi+0x3e>
    8000431a:	40d78b3b          	subw	s6,a5,a3
    8000431e:	0a0b0963          	beqz	s6,800043d0 <readi+0xf0>
    80004322:	4981                	li	s3,0
    80004324:	40000d13          	li	s10,1024
    80004328:	5cfd                	li	s9,-1
    8000432a:	a82d                	j	80004364 <readi+0x84>
    8000432c:	020a1d93          	slli	s11,s4,0x20
    80004330:	020ddd93          	srli	s11,s11,0x20
    80004334:	05890613          	addi	a2,s2,88
    80004338:	86ee                	mv	a3,s11
    8000433a:	963a                	add	a2,a2,a4
    8000433c:	85d6                	mv	a1,s5
    8000433e:	8562                	mv	a0,s8
    80004340:	ffffe097          	auipc	ra,0xffffe
    80004344:	e26080e7          	jalr	-474(ra) # 80002166 <either_copyout>
    80004348:	05950d63          	beq	a0,s9,800043a2 <readi+0xc2>
    8000434c:	854a                	mv	a0,s2
    8000434e:	fffff097          	auipc	ra,0xfffff
    80004352:	60c080e7          	jalr	1548(ra) # 8000395a <brelse>
    80004356:	013a09bb          	addw	s3,s4,s3
    8000435a:	009a04bb          	addw	s1,s4,s1
    8000435e:	9aee                	add	s5,s5,s11
    80004360:	0569f763          	bgeu	s3,s6,800043ae <readi+0xce>
    80004364:	000ba903          	lw	s2,0(s7)
    80004368:	00a4d59b          	srliw	a1,s1,0xa
    8000436c:	855e                	mv	a0,s7
    8000436e:	00000097          	auipc	ra,0x0
    80004372:	8ac080e7          	jalr	-1876(ra) # 80003c1a <bmap>
    80004376:	0005059b          	sext.w	a1,a0
    8000437a:	854a                	mv	a0,s2
    8000437c:	fffff097          	auipc	ra,0xfffff
    80004380:	4ae080e7          	jalr	1198(ra) # 8000382a <bread>
    80004384:	892a                	mv	s2,a0
    80004386:	3ff4f713          	andi	a4,s1,1023
    8000438a:	40ed07bb          	subw	a5,s10,a4
    8000438e:	413b06bb          	subw	a3,s6,s3
    80004392:	8a3e                	mv	s4,a5
    80004394:	2781                	sext.w	a5,a5
    80004396:	0006861b          	sext.w	a2,a3
    8000439a:	f8f679e3          	bgeu	a2,a5,8000432c <readi+0x4c>
    8000439e:	8a36                	mv	s4,a3
    800043a0:	b771                	j	8000432c <readi+0x4c>
    800043a2:	854a                	mv	a0,s2
    800043a4:	fffff097          	auipc	ra,0xfffff
    800043a8:	5b6080e7          	jalr	1462(ra) # 8000395a <brelse>
    800043ac:	59fd                	li	s3,-1
    800043ae:	0009851b          	sext.w	a0,s3
    800043b2:	70a6                	ld	ra,104(sp)
    800043b4:	7406                	ld	s0,96(sp)
    800043b6:	64e6                	ld	s1,88(sp)
    800043b8:	6946                	ld	s2,80(sp)
    800043ba:	69a6                	ld	s3,72(sp)
    800043bc:	6a06                	ld	s4,64(sp)
    800043be:	7ae2                	ld	s5,56(sp)
    800043c0:	7b42                	ld	s6,48(sp)
    800043c2:	7ba2                	ld	s7,40(sp)
    800043c4:	7c02                	ld	s8,32(sp)
    800043c6:	6ce2                	ld	s9,24(sp)
    800043c8:	6d42                	ld	s10,16(sp)
    800043ca:	6da2                	ld	s11,8(sp)
    800043cc:	6165                	addi	sp,sp,112
    800043ce:	8082                	ret
    800043d0:	89da                	mv	s3,s6
    800043d2:	bff1                	j	800043ae <readi+0xce>
    800043d4:	4501                	li	a0,0
    800043d6:	8082                	ret

00000000800043d8 <writei>:
    800043d8:	457c                	lw	a5,76(a0)
    800043da:	10d7e863          	bltu	a5,a3,800044ea <writei+0x112>
    800043de:	7159                	addi	sp,sp,-112
    800043e0:	f486                	sd	ra,104(sp)
    800043e2:	f0a2                	sd	s0,96(sp)
    800043e4:	eca6                	sd	s1,88(sp)
    800043e6:	e8ca                	sd	s2,80(sp)
    800043e8:	e4ce                	sd	s3,72(sp)
    800043ea:	e0d2                	sd	s4,64(sp)
    800043ec:	fc56                	sd	s5,56(sp)
    800043ee:	f85a                	sd	s6,48(sp)
    800043f0:	f45e                	sd	s7,40(sp)
    800043f2:	f062                	sd	s8,32(sp)
    800043f4:	ec66                	sd	s9,24(sp)
    800043f6:	e86a                	sd	s10,16(sp)
    800043f8:	e46e                	sd	s11,8(sp)
    800043fa:	1880                	addi	s0,sp,112
    800043fc:	8b2a                	mv	s6,a0
    800043fe:	8c2e                	mv	s8,a1
    80004400:	8ab2                	mv	s5,a2
    80004402:	8936                	mv	s2,a3
    80004404:	8bba                	mv	s7,a4
    80004406:	00e687bb          	addw	a5,a3,a4
    8000440a:	0ed7e263          	bltu	a5,a3,800044ee <writei+0x116>
    8000440e:	00043737          	lui	a4,0x43
    80004412:	0ef76063          	bltu	a4,a5,800044f2 <writei+0x11a>
    80004416:	0c0b8863          	beqz	s7,800044e6 <writei+0x10e>
    8000441a:	4a01                	li	s4,0
    8000441c:	40000d13          	li	s10,1024
    80004420:	5cfd                	li	s9,-1
    80004422:	a091                	j	80004466 <writei+0x8e>
    80004424:	02099d93          	slli	s11,s3,0x20
    80004428:	020ddd93          	srli	s11,s11,0x20
    8000442c:	05848513          	addi	a0,s1,88
    80004430:	86ee                	mv	a3,s11
    80004432:	8656                	mv	a2,s5
    80004434:	85e2                	mv	a1,s8
    80004436:	953a                	add	a0,a0,a4
    80004438:	ffffe097          	auipc	ra,0xffffe
    8000443c:	d86080e7          	jalr	-634(ra) # 800021be <either_copyin>
    80004440:	07950263          	beq	a0,s9,800044a4 <writei+0xcc>
    80004444:	8526                	mv	a0,s1
    80004446:	00000097          	auipc	ra,0x0
    8000444a:	798080e7          	jalr	1944(ra) # 80004bde <log_write>
    8000444e:	8526                	mv	a0,s1
    80004450:	fffff097          	auipc	ra,0xfffff
    80004454:	50a080e7          	jalr	1290(ra) # 8000395a <brelse>
    80004458:	01498a3b          	addw	s4,s3,s4
    8000445c:	0129893b          	addw	s2,s3,s2
    80004460:	9aee                	add	s5,s5,s11
    80004462:	057a7663          	bgeu	s4,s7,800044ae <writei+0xd6>
    80004466:	000b2483          	lw	s1,0(s6)
    8000446a:	00a9559b          	srliw	a1,s2,0xa
    8000446e:	855a                	mv	a0,s6
    80004470:	fffff097          	auipc	ra,0xfffff
    80004474:	7aa080e7          	jalr	1962(ra) # 80003c1a <bmap>
    80004478:	0005059b          	sext.w	a1,a0
    8000447c:	8526                	mv	a0,s1
    8000447e:	fffff097          	auipc	ra,0xfffff
    80004482:	3ac080e7          	jalr	940(ra) # 8000382a <bread>
    80004486:	84aa                	mv	s1,a0
    80004488:	3ff97713          	andi	a4,s2,1023
    8000448c:	40ed07bb          	subw	a5,s10,a4
    80004490:	414b86bb          	subw	a3,s7,s4
    80004494:	89be                	mv	s3,a5
    80004496:	2781                	sext.w	a5,a5
    80004498:	0006861b          	sext.w	a2,a3
    8000449c:	f8f674e3          	bgeu	a2,a5,80004424 <writei+0x4c>
    800044a0:	89b6                	mv	s3,a3
    800044a2:	b749                	j	80004424 <writei+0x4c>
    800044a4:	8526                	mv	a0,s1
    800044a6:	fffff097          	auipc	ra,0xfffff
    800044aa:	4b4080e7          	jalr	1204(ra) # 8000395a <brelse>
    800044ae:	04cb2783          	lw	a5,76(s6)
    800044b2:	0127f463          	bgeu	a5,s2,800044ba <writei+0xe2>
    800044b6:	052b2623          	sw	s2,76(s6)
    800044ba:	855a                	mv	a0,s6
    800044bc:	00000097          	auipc	ra,0x0
    800044c0:	aa4080e7          	jalr	-1372(ra) # 80003f60 <iupdate>
    800044c4:	000a051b          	sext.w	a0,s4
    800044c8:	70a6                	ld	ra,104(sp)
    800044ca:	7406                	ld	s0,96(sp)
    800044cc:	64e6                	ld	s1,88(sp)
    800044ce:	6946                	ld	s2,80(sp)
    800044d0:	69a6                	ld	s3,72(sp)
    800044d2:	6a06                	ld	s4,64(sp)
    800044d4:	7ae2                	ld	s5,56(sp)
    800044d6:	7b42                	ld	s6,48(sp)
    800044d8:	7ba2                	ld	s7,40(sp)
    800044da:	7c02                	ld	s8,32(sp)
    800044dc:	6ce2                	ld	s9,24(sp)
    800044de:	6d42                	ld	s10,16(sp)
    800044e0:	6da2                	ld	s11,8(sp)
    800044e2:	6165                	addi	sp,sp,112
    800044e4:	8082                	ret
    800044e6:	8a5e                	mv	s4,s7
    800044e8:	bfc9                	j	800044ba <writei+0xe2>
    800044ea:	557d                	li	a0,-1
    800044ec:	8082                	ret
    800044ee:	557d                	li	a0,-1
    800044f0:	bfe1                	j	800044c8 <writei+0xf0>
    800044f2:	557d                	li	a0,-1
    800044f4:	bfd1                	j	800044c8 <writei+0xf0>

00000000800044f6 <namecmp>:
    800044f6:	1141                	addi	sp,sp,-16
    800044f8:	e406                	sd	ra,8(sp)
    800044fa:	e022                	sd	s0,0(sp)
    800044fc:	0800                	addi	s0,sp,16
    800044fe:	4639                	li	a2,14
    80004500:	ffffd097          	auipc	ra,0xffffd
    80004504:	8e6080e7          	jalr	-1818(ra) # 80000de6 <strncmp>
    80004508:	60a2                	ld	ra,8(sp)
    8000450a:	6402                	ld	s0,0(sp)
    8000450c:	0141                	addi	sp,sp,16
    8000450e:	8082                	ret

0000000080004510 <dirlookup>:
    80004510:	7139                	addi	sp,sp,-64
    80004512:	fc06                	sd	ra,56(sp)
    80004514:	f822                	sd	s0,48(sp)
    80004516:	f426                	sd	s1,40(sp)
    80004518:	f04a                	sd	s2,32(sp)
    8000451a:	ec4e                	sd	s3,24(sp)
    8000451c:	e852                	sd	s4,16(sp)
    8000451e:	0080                	addi	s0,sp,64
    80004520:	04451703          	lh	a4,68(a0)
    80004524:	4785                	li	a5,1
    80004526:	00f71a63          	bne	a4,a5,8000453a <dirlookup+0x2a>
    8000452a:	892a                	mv	s2,a0
    8000452c:	89ae                	mv	s3,a1
    8000452e:	8a32                	mv	s4,a2
    80004530:	457c                	lw	a5,76(a0)
    80004532:	4481                	li	s1,0
    80004534:	4501                	li	a0,0
    80004536:	e79d                	bnez	a5,80004564 <dirlookup+0x54>
    80004538:	a8a5                	j	800045b0 <dirlookup+0xa0>
    8000453a:	00005517          	auipc	a0,0x5
    8000453e:	12650513          	addi	a0,a0,294 # 80009660 <syscalls+0x1e0>
    80004542:	ffffc097          	auipc	ra,0xffffc
    80004546:	ffa080e7          	jalr	-6(ra) # 8000053c <panic>
    8000454a:	00005517          	auipc	a0,0x5
    8000454e:	12e50513          	addi	a0,a0,302 # 80009678 <syscalls+0x1f8>
    80004552:	ffffc097          	auipc	ra,0xffffc
    80004556:	fea080e7          	jalr	-22(ra) # 8000053c <panic>
    8000455a:	24c1                	addiw	s1,s1,16
    8000455c:	04c92783          	lw	a5,76(s2)
    80004560:	04f4f763          	bgeu	s1,a5,800045ae <dirlookup+0x9e>
    80004564:	4741                	li	a4,16
    80004566:	86a6                	mv	a3,s1
    80004568:	fc040613          	addi	a2,s0,-64
    8000456c:	4581                	li	a1,0
    8000456e:	854a                	mv	a0,s2
    80004570:	00000097          	auipc	ra,0x0
    80004574:	d70080e7          	jalr	-656(ra) # 800042e0 <readi>
    80004578:	47c1                	li	a5,16
    8000457a:	fcf518e3          	bne	a0,a5,8000454a <dirlookup+0x3a>
    8000457e:	fc045783          	lhu	a5,-64(s0)
    80004582:	dfe1                	beqz	a5,8000455a <dirlookup+0x4a>
    80004584:	fc240593          	addi	a1,s0,-62
    80004588:	854e                	mv	a0,s3
    8000458a:	00000097          	auipc	ra,0x0
    8000458e:	f6c080e7          	jalr	-148(ra) # 800044f6 <namecmp>
    80004592:	f561                	bnez	a0,8000455a <dirlookup+0x4a>
    80004594:	000a0463          	beqz	s4,8000459c <dirlookup+0x8c>
    80004598:	009a2023          	sw	s1,0(s4)
    8000459c:	fc045583          	lhu	a1,-64(s0)
    800045a0:	00092503          	lw	a0,0(s2)
    800045a4:	fffff097          	auipc	ra,0xfffff
    800045a8:	752080e7          	jalr	1874(ra) # 80003cf6 <iget>
    800045ac:	a011                	j	800045b0 <dirlookup+0xa0>
    800045ae:	4501                	li	a0,0
    800045b0:	70e2                	ld	ra,56(sp)
    800045b2:	7442                	ld	s0,48(sp)
    800045b4:	74a2                	ld	s1,40(sp)
    800045b6:	7902                	ld	s2,32(sp)
    800045b8:	69e2                	ld	s3,24(sp)
    800045ba:	6a42                	ld	s4,16(sp)
    800045bc:	6121                	addi	sp,sp,64
    800045be:	8082                	ret

00000000800045c0 <namex>:
    800045c0:	711d                	addi	sp,sp,-96
    800045c2:	ec86                	sd	ra,88(sp)
    800045c4:	e8a2                	sd	s0,80(sp)
    800045c6:	e4a6                	sd	s1,72(sp)
    800045c8:	e0ca                	sd	s2,64(sp)
    800045ca:	fc4e                	sd	s3,56(sp)
    800045cc:	f852                	sd	s4,48(sp)
    800045ce:	f456                	sd	s5,40(sp)
    800045d0:	f05a                	sd	s6,32(sp)
    800045d2:	ec5e                	sd	s7,24(sp)
    800045d4:	e862                	sd	s8,16(sp)
    800045d6:	e466                	sd	s9,8(sp)
    800045d8:	e06a                	sd	s10,0(sp)
    800045da:	1080                	addi	s0,sp,96
    800045dc:	84aa                	mv	s1,a0
    800045de:	8b2e                	mv	s6,a1
    800045e0:	8ab2                	mv	s5,a2
    800045e2:	00054703          	lbu	a4,0(a0)
    800045e6:	02f00793          	li	a5,47
    800045ea:	02f70363          	beq	a4,a5,80004610 <namex+0x50>
    800045ee:	ffffd097          	auipc	ra,0xffffd
    800045f2:	502080e7          	jalr	1282(ra) # 80001af0 <myproc>
    800045f6:	3d853503          	ld	a0,984(a0)
    800045fa:	00000097          	auipc	ra,0x0
    800045fe:	9f4080e7          	jalr	-1548(ra) # 80003fee <idup>
    80004602:	8a2a                	mv	s4,a0
    80004604:	02f00913          	li	s2,47
    80004608:	4cb5                	li	s9,13
    8000460a:	4b81                	li	s7,0
    8000460c:	4c05                	li	s8,1
    8000460e:	a87d                	j	800046cc <namex+0x10c>
    80004610:	4585                	li	a1,1
    80004612:	4505                	li	a0,1
    80004614:	fffff097          	auipc	ra,0xfffff
    80004618:	6e2080e7          	jalr	1762(ra) # 80003cf6 <iget>
    8000461c:	8a2a                	mv	s4,a0
    8000461e:	b7dd                	j	80004604 <namex+0x44>
    80004620:	8552                	mv	a0,s4
    80004622:	00000097          	auipc	ra,0x0
    80004626:	c6c080e7          	jalr	-916(ra) # 8000428e <iunlockput>
    8000462a:	4a01                	li	s4,0
    8000462c:	8552                	mv	a0,s4
    8000462e:	60e6                	ld	ra,88(sp)
    80004630:	6446                	ld	s0,80(sp)
    80004632:	64a6                	ld	s1,72(sp)
    80004634:	6906                	ld	s2,64(sp)
    80004636:	79e2                	ld	s3,56(sp)
    80004638:	7a42                	ld	s4,48(sp)
    8000463a:	7aa2                	ld	s5,40(sp)
    8000463c:	7b02                	ld	s6,32(sp)
    8000463e:	6be2                	ld	s7,24(sp)
    80004640:	6c42                	ld	s8,16(sp)
    80004642:	6ca2                	ld	s9,8(sp)
    80004644:	6d02                	ld	s10,0(sp)
    80004646:	6125                	addi	sp,sp,96
    80004648:	8082                	ret
    8000464a:	8552                	mv	a0,s4
    8000464c:	00000097          	auipc	ra,0x0
    80004650:	aa2080e7          	jalr	-1374(ra) # 800040ee <iunlock>
    80004654:	bfe1                	j	8000462c <namex+0x6c>
    80004656:	8552                	mv	a0,s4
    80004658:	00000097          	auipc	ra,0x0
    8000465c:	c36080e7          	jalr	-970(ra) # 8000428e <iunlockput>
    80004660:	8a4e                	mv	s4,s3
    80004662:	b7e9                	j	8000462c <namex+0x6c>
    80004664:	40998633          	sub	a2,s3,s1
    80004668:	00060d1b          	sext.w	s10,a2
    8000466c:	09acd863          	bge	s9,s10,800046fc <namex+0x13c>
    80004670:	4639                	li	a2,14
    80004672:	85a6                	mv	a1,s1
    80004674:	8556                	mv	a0,s5
    80004676:	ffffc097          	auipc	ra,0xffffc
    8000467a:	6fc080e7          	jalr	1788(ra) # 80000d72 <memmove>
    8000467e:	84ce                	mv	s1,s3
    80004680:	0004c783          	lbu	a5,0(s1)
    80004684:	01279763          	bne	a5,s2,80004692 <namex+0xd2>
    80004688:	0485                	addi	s1,s1,1
    8000468a:	0004c783          	lbu	a5,0(s1)
    8000468e:	ff278de3          	beq	a5,s2,80004688 <namex+0xc8>
    80004692:	8552                	mv	a0,s4
    80004694:	00000097          	auipc	ra,0x0
    80004698:	998080e7          	jalr	-1640(ra) # 8000402c <ilock>
    8000469c:	044a1783          	lh	a5,68(s4)
    800046a0:	f98790e3          	bne	a5,s8,80004620 <namex+0x60>
    800046a4:	000b0563          	beqz	s6,800046ae <namex+0xee>
    800046a8:	0004c783          	lbu	a5,0(s1)
    800046ac:	dfd9                	beqz	a5,8000464a <namex+0x8a>
    800046ae:	865e                	mv	a2,s7
    800046b0:	85d6                	mv	a1,s5
    800046b2:	8552                	mv	a0,s4
    800046b4:	00000097          	auipc	ra,0x0
    800046b8:	e5c080e7          	jalr	-420(ra) # 80004510 <dirlookup>
    800046bc:	89aa                	mv	s3,a0
    800046be:	dd41                	beqz	a0,80004656 <namex+0x96>
    800046c0:	8552                	mv	a0,s4
    800046c2:	00000097          	auipc	ra,0x0
    800046c6:	bcc080e7          	jalr	-1076(ra) # 8000428e <iunlockput>
    800046ca:	8a4e                	mv	s4,s3
    800046cc:	0004c783          	lbu	a5,0(s1)
    800046d0:	01279763          	bne	a5,s2,800046de <namex+0x11e>
    800046d4:	0485                	addi	s1,s1,1
    800046d6:	0004c783          	lbu	a5,0(s1)
    800046da:	ff278de3          	beq	a5,s2,800046d4 <namex+0x114>
    800046de:	cb9d                	beqz	a5,80004714 <namex+0x154>
    800046e0:	0004c783          	lbu	a5,0(s1)
    800046e4:	89a6                	mv	s3,s1
    800046e6:	8d5e                	mv	s10,s7
    800046e8:	865e                	mv	a2,s7
    800046ea:	01278963          	beq	a5,s2,800046fc <namex+0x13c>
    800046ee:	dbbd                	beqz	a5,80004664 <namex+0xa4>
    800046f0:	0985                	addi	s3,s3,1
    800046f2:	0009c783          	lbu	a5,0(s3)
    800046f6:	ff279ce3          	bne	a5,s2,800046ee <namex+0x12e>
    800046fa:	b7ad                	j	80004664 <namex+0xa4>
    800046fc:	2601                	sext.w	a2,a2
    800046fe:	85a6                	mv	a1,s1
    80004700:	8556                	mv	a0,s5
    80004702:	ffffc097          	auipc	ra,0xffffc
    80004706:	670080e7          	jalr	1648(ra) # 80000d72 <memmove>
    8000470a:	9d56                	add	s10,s10,s5
    8000470c:	000d0023          	sb	zero,0(s10)
    80004710:	84ce                	mv	s1,s3
    80004712:	b7bd                	j	80004680 <namex+0xc0>
    80004714:	f00b0ce3          	beqz	s6,8000462c <namex+0x6c>
    80004718:	8552                	mv	a0,s4
    8000471a:	00000097          	auipc	ra,0x0
    8000471e:	acc080e7          	jalr	-1332(ra) # 800041e6 <iput>
    80004722:	4a01                	li	s4,0
    80004724:	b721                	j	8000462c <namex+0x6c>

0000000080004726 <dirlink>:
    80004726:	7139                	addi	sp,sp,-64
    80004728:	fc06                	sd	ra,56(sp)
    8000472a:	f822                	sd	s0,48(sp)
    8000472c:	f426                	sd	s1,40(sp)
    8000472e:	f04a                	sd	s2,32(sp)
    80004730:	ec4e                	sd	s3,24(sp)
    80004732:	e852                	sd	s4,16(sp)
    80004734:	0080                	addi	s0,sp,64
    80004736:	892a                	mv	s2,a0
    80004738:	8a2e                	mv	s4,a1
    8000473a:	89b2                	mv	s3,a2
    8000473c:	4601                	li	a2,0
    8000473e:	00000097          	auipc	ra,0x0
    80004742:	dd2080e7          	jalr	-558(ra) # 80004510 <dirlookup>
    80004746:	e93d                	bnez	a0,800047bc <dirlink+0x96>
    80004748:	04c92483          	lw	s1,76(s2)
    8000474c:	c49d                	beqz	s1,8000477a <dirlink+0x54>
    8000474e:	4481                	li	s1,0
    80004750:	4741                	li	a4,16
    80004752:	86a6                	mv	a3,s1
    80004754:	fc040613          	addi	a2,s0,-64
    80004758:	4581                	li	a1,0
    8000475a:	854a                	mv	a0,s2
    8000475c:	00000097          	auipc	ra,0x0
    80004760:	b84080e7          	jalr	-1148(ra) # 800042e0 <readi>
    80004764:	47c1                	li	a5,16
    80004766:	06f51163          	bne	a0,a5,800047c8 <dirlink+0xa2>
    8000476a:	fc045783          	lhu	a5,-64(s0)
    8000476e:	c791                	beqz	a5,8000477a <dirlink+0x54>
    80004770:	24c1                	addiw	s1,s1,16
    80004772:	04c92783          	lw	a5,76(s2)
    80004776:	fcf4ede3          	bltu	s1,a5,80004750 <dirlink+0x2a>
    8000477a:	4639                	li	a2,14
    8000477c:	85d2                	mv	a1,s4
    8000477e:	fc240513          	addi	a0,s0,-62
    80004782:	ffffc097          	auipc	ra,0xffffc
    80004786:	6a0080e7          	jalr	1696(ra) # 80000e22 <strncpy>
    8000478a:	fd341023          	sh	s3,-64(s0)
    8000478e:	4741                	li	a4,16
    80004790:	86a6                	mv	a3,s1
    80004792:	fc040613          	addi	a2,s0,-64
    80004796:	4581                	li	a1,0
    80004798:	854a                	mv	a0,s2
    8000479a:	00000097          	auipc	ra,0x0
    8000479e:	c3e080e7          	jalr	-962(ra) # 800043d8 <writei>
    800047a2:	872a                	mv	a4,a0
    800047a4:	47c1                	li	a5,16
    800047a6:	4501                	li	a0,0
    800047a8:	02f71863          	bne	a4,a5,800047d8 <dirlink+0xb2>
    800047ac:	70e2                	ld	ra,56(sp)
    800047ae:	7442                	ld	s0,48(sp)
    800047b0:	74a2                	ld	s1,40(sp)
    800047b2:	7902                	ld	s2,32(sp)
    800047b4:	69e2                	ld	s3,24(sp)
    800047b6:	6a42                	ld	s4,16(sp)
    800047b8:	6121                	addi	sp,sp,64
    800047ba:	8082                	ret
    800047bc:	00000097          	auipc	ra,0x0
    800047c0:	a2a080e7          	jalr	-1494(ra) # 800041e6 <iput>
    800047c4:	557d                	li	a0,-1
    800047c6:	b7dd                	j	800047ac <dirlink+0x86>
    800047c8:	00005517          	auipc	a0,0x5
    800047cc:	ec050513          	addi	a0,a0,-320 # 80009688 <syscalls+0x208>
    800047d0:	ffffc097          	auipc	ra,0xffffc
    800047d4:	d6c080e7          	jalr	-660(ra) # 8000053c <panic>
    800047d8:	00005517          	auipc	a0,0x5
    800047dc:	00050513          	mv	a0,a0
    800047e0:	ffffc097          	auipc	ra,0xffffc
    800047e4:	d5c080e7          	jalr	-676(ra) # 8000053c <panic>

00000000800047e8 <namei>:
    800047e8:	1101                	addi	sp,sp,-32
    800047ea:	ec06                	sd	ra,24(sp)
    800047ec:	e822                	sd	s0,16(sp)
    800047ee:	1000                	addi	s0,sp,32
    800047f0:	fe040613          	addi	a2,s0,-32
    800047f4:	4581                	li	a1,0
    800047f6:	00000097          	auipc	ra,0x0
    800047fa:	dca080e7          	jalr	-566(ra) # 800045c0 <namex>
    800047fe:	60e2                	ld	ra,24(sp)
    80004800:	6442                	ld	s0,16(sp)
    80004802:	6105                	addi	sp,sp,32
    80004804:	8082                	ret

0000000080004806 <nameiparent>:
    80004806:	1141                	addi	sp,sp,-16
    80004808:	e406                	sd	ra,8(sp)
    8000480a:	e022                	sd	s0,0(sp)
    8000480c:	0800                	addi	s0,sp,16
    8000480e:	862e                	mv	a2,a1
    80004810:	4585                	li	a1,1
    80004812:	00000097          	auipc	ra,0x0
    80004816:	dae080e7          	jalr	-594(ra) # 800045c0 <namex>
    8000481a:	60a2                	ld	ra,8(sp)
    8000481c:	6402                	ld	s0,0(sp)
    8000481e:	0141                	addi	sp,sp,16
    80004820:	8082                	ret

0000000080004822 <write_head>:
    80004822:	1101                	addi	sp,sp,-32
    80004824:	ec06                	sd	ra,24(sp)
    80004826:	e822                	sd	s0,16(sp)
    80004828:	e426                	sd	s1,8(sp)
    8000482a:	e04a                	sd	s2,0(sp)
    8000482c:	1000                	addi	s0,sp,32
    8000482e:	0002d917          	auipc	s2,0x2d
    80004832:	c5a90913          	addi	s2,s2,-934 # 80031488 <log>
    80004836:	01892583          	lw	a1,24(s2)
    8000483a:	02892503          	lw	a0,40(s2)
    8000483e:	fffff097          	auipc	ra,0xfffff
    80004842:	fec080e7          	jalr	-20(ra) # 8000382a <bread>
    80004846:	84aa                	mv	s1,a0
    80004848:	02c92683          	lw	a3,44(s2)
    8000484c:	cd34                	sw	a3,88(a0)
    8000484e:	02d05863          	blez	a3,8000487e <write_head+0x5c>
    80004852:	0002d797          	auipc	a5,0x2d
    80004856:	c6678793          	addi	a5,a5,-922 # 800314b8 <log+0x30>
    8000485a:	05c50713          	addi	a4,a0,92 # 80009834 <syscalls+0x3b4>
    8000485e:	36fd                	addiw	a3,a3,-1
    80004860:	02069613          	slli	a2,a3,0x20
    80004864:	01e65693          	srli	a3,a2,0x1e
    80004868:	0002d617          	auipc	a2,0x2d
    8000486c:	c5460613          	addi	a2,a2,-940 # 800314bc <log+0x34>
    80004870:	96b2                	add	a3,a3,a2
    80004872:	4390                	lw	a2,0(a5)
    80004874:	c310                	sw	a2,0(a4)
    80004876:	0791                	addi	a5,a5,4
    80004878:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    8000487a:	fed79ce3          	bne	a5,a3,80004872 <write_head+0x50>
    8000487e:	8526                	mv	a0,s1
    80004880:	fffff097          	auipc	ra,0xfffff
    80004884:	09c080e7          	jalr	156(ra) # 8000391c <bwrite>
    80004888:	8526                	mv	a0,s1
    8000488a:	fffff097          	auipc	ra,0xfffff
    8000488e:	0d0080e7          	jalr	208(ra) # 8000395a <brelse>
    80004892:	60e2                	ld	ra,24(sp)
    80004894:	6442                	ld	s0,16(sp)
    80004896:	64a2                	ld	s1,8(sp)
    80004898:	6902                	ld	s2,0(sp)
    8000489a:	6105                	addi	sp,sp,32
    8000489c:	8082                	ret

000000008000489e <install_trans>:
    8000489e:	0002d797          	auipc	a5,0x2d
    800048a2:	c167a783          	lw	a5,-1002(a5) # 800314b4 <log+0x2c>
    800048a6:	0af05d63          	blez	a5,80004960 <install_trans+0xc2>
    800048aa:	7139                	addi	sp,sp,-64
    800048ac:	fc06                	sd	ra,56(sp)
    800048ae:	f822                	sd	s0,48(sp)
    800048b0:	f426                	sd	s1,40(sp)
    800048b2:	f04a                	sd	s2,32(sp)
    800048b4:	ec4e                	sd	s3,24(sp)
    800048b6:	e852                	sd	s4,16(sp)
    800048b8:	e456                	sd	s5,8(sp)
    800048ba:	e05a                	sd	s6,0(sp)
    800048bc:	0080                	addi	s0,sp,64
    800048be:	8b2a                	mv	s6,a0
    800048c0:	0002da97          	auipc	s5,0x2d
    800048c4:	bf8a8a93          	addi	s5,s5,-1032 # 800314b8 <log+0x30>
    800048c8:	4a01                	li	s4,0
    800048ca:	0002d997          	auipc	s3,0x2d
    800048ce:	bbe98993          	addi	s3,s3,-1090 # 80031488 <log>
    800048d2:	a00d                	j	800048f4 <install_trans+0x56>
    800048d4:	854a                	mv	a0,s2
    800048d6:	fffff097          	auipc	ra,0xfffff
    800048da:	084080e7          	jalr	132(ra) # 8000395a <brelse>
    800048de:	8526                	mv	a0,s1
    800048e0:	fffff097          	auipc	ra,0xfffff
    800048e4:	07a080e7          	jalr	122(ra) # 8000395a <brelse>
    800048e8:	2a05                	addiw	s4,s4,1
    800048ea:	0a91                	addi	s5,s5,4
    800048ec:	02c9a783          	lw	a5,44(s3)
    800048f0:	04fa5e63          	bge	s4,a5,8000494c <install_trans+0xae>
    800048f4:	0189a583          	lw	a1,24(s3)
    800048f8:	014585bb          	addw	a1,a1,s4
    800048fc:	2585                	addiw	a1,a1,1
    800048fe:	0289a503          	lw	a0,40(s3)
    80004902:	fffff097          	auipc	ra,0xfffff
    80004906:	f28080e7          	jalr	-216(ra) # 8000382a <bread>
    8000490a:	892a                	mv	s2,a0
    8000490c:	000aa583          	lw	a1,0(s5)
    80004910:	0289a503          	lw	a0,40(s3)
    80004914:	fffff097          	auipc	ra,0xfffff
    80004918:	f16080e7          	jalr	-234(ra) # 8000382a <bread>
    8000491c:	84aa                	mv	s1,a0
    8000491e:	40000613          	li	a2,1024
    80004922:	05890593          	addi	a1,s2,88
    80004926:	05850513          	addi	a0,a0,88
    8000492a:	ffffc097          	auipc	ra,0xffffc
    8000492e:	448080e7          	jalr	1096(ra) # 80000d72 <memmove>
    80004932:	8526                	mv	a0,s1
    80004934:	fffff097          	auipc	ra,0xfffff
    80004938:	fe8080e7          	jalr	-24(ra) # 8000391c <bwrite>
    8000493c:	f80b1ce3          	bnez	s6,800048d4 <install_trans+0x36>
    80004940:	8526                	mv	a0,s1
    80004942:	fffff097          	auipc	ra,0xfffff
    80004946:	0f2080e7          	jalr	242(ra) # 80003a34 <bunpin>
    8000494a:	b769                	j	800048d4 <install_trans+0x36>
    8000494c:	70e2                	ld	ra,56(sp)
    8000494e:	7442                	ld	s0,48(sp)
    80004950:	74a2                	ld	s1,40(sp)
    80004952:	7902                	ld	s2,32(sp)
    80004954:	69e2                	ld	s3,24(sp)
    80004956:	6a42                	ld	s4,16(sp)
    80004958:	6aa2                	ld	s5,8(sp)
    8000495a:	6b02                	ld	s6,0(sp)
    8000495c:	6121                	addi	sp,sp,64
    8000495e:	8082                	ret
    80004960:	8082                	ret

0000000080004962 <initlog>:
    80004962:	7179                	addi	sp,sp,-48
    80004964:	f406                	sd	ra,40(sp)
    80004966:	f022                	sd	s0,32(sp)
    80004968:	ec26                	sd	s1,24(sp)
    8000496a:	e84a                	sd	s2,16(sp)
    8000496c:	e44e                	sd	s3,8(sp)
    8000496e:	1800                	addi	s0,sp,48
    80004970:	892a                	mv	s2,a0
    80004972:	89ae                	mv	s3,a1
    80004974:	0002d497          	auipc	s1,0x2d
    80004978:	b1448493          	addi	s1,s1,-1260 # 80031488 <log>
    8000497c:	00005597          	auipc	a1,0x5
    80004980:	d1c58593          	addi	a1,a1,-740 # 80009698 <syscalls+0x218>
    80004984:	8526                	mv	a0,s1
    80004986:	ffffc097          	auipc	ra,0xffffc
    8000498a:	204080e7          	jalr	516(ra) # 80000b8a <initlock>
    8000498e:	0149a583          	lw	a1,20(s3)
    80004992:	cc8c                	sw	a1,24(s1)
    80004994:	0109a783          	lw	a5,16(s3)
    80004998:	ccdc                	sw	a5,28(s1)
    8000499a:	0324a423          	sw	s2,40(s1)
    8000499e:	854a                	mv	a0,s2
    800049a0:	fffff097          	auipc	ra,0xfffff
    800049a4:	e8a080e7          	jalr	-374(ra) # 8000382a <bread>
    800049a8:	4d34                	lw	a3,88(a0)
    800049aa:	d4d4                	sw	a3,44(s1)
    800049ac:	02d05663          	blez	a3,800049d8 <initlog+0x76>
    800049b0:	05c50793          	addi	a5,a0,92
    800049b4:	0002d717          	auipc	a4,0x2d
    800049b8:	b0470713          	addi	a4,a4,-1276 # 800314b8 <log+0x30>
    800049bc:	36fd                	addiw	a3,a3,-1
    800049be:	02069613          	slli	a2,a3,0x20
    800049c2:	01e65693          	srli	a3,a2,0x1e
    800049c6:	06050613          	addi	a2,a0,96
    800049ca:	96b2                	add	a3,a3,a2
    800049cc:	4390                	lw	a2,0(a5)
    800049ce:	c310                	sw	a2,0(a4)
    800049d0:	0791                	addi	a5,a5,4
    800049d2:	0711                	addi	a4,a4,4
    800049d4:	fed79ce3          	bne	a5,a3,800049cc <initlog+0x6a>
    800049d8:	fffff097          	auipc	ra,0xfffff
    800049dc:	f82080e7          	jalr	-126(ra) # 8000395a <brelse>
    800049e0:	4505                	li	a0,1
    800049e2:	00000097          	auipc	ra,0x0
    800049e6:	ebc080e7          	jalr	-324(ra) # 8000489e <install_trans>
    800049ea:	0002d797          	auipc	a5,0x2d
    800049ee:	ac07a523          	sw	zero,-1334(a5) # 800314b4 <log+0x2c>
    800049f2:	00000097          	auipc	ra,0x0
    800049f6:	e30080e7          	jalr	-464(ra) # 80004822 <write_head>
    800049fa:	70a2                	ld	ra,40(sp)
    800049fc:	7402                	ld	s0,32(sp)
    800049fe:	64e2                	ld	s1,24(sp)
    80004a00:	6942                	ld	s2,16(sp)
    80004a02:	69a2                	ld	s3,8(sp)
    80004a04:	6145                	addi	sp,sp,48
    80004a06:	8082                	ret

0000000080004a08 <begin_op>:
    80004a08:	1101                	addi	sp,sp,-32
    80004a0a:	ec06                	sd	ra,24(sp)
    80004a0c:	e822                	sd	s0,16(sp)
    80004a0e:	e426                	sd	s1,8(sp)
    80004a10:	e04a                	sd	s2,0(sp)
    80004a12:	1000                	addi	s0,sp,32
    80004a14:	0002d517          	auipc	a0,0x2d
    80004a18:	a7450513          	addi	a0,a0,-1420 # 80031488 <log>
    80004a1c:	ffffc097          	auipc	ra,0xffffc
    80004a20:	1fe080e7          	jalr	510(ra) # 80000c1a <acquire>
    80004a24:	0002d497          	auipc	s1,0x2d
    80004a28:	a6448493          	addi	s1,s1,-1436 # 80031488 <log>
    80004a2c:	4979                	li	s2,30
    80004a2e:	a039                	j	80004a3c <begin_op+0x34>
    80004a30:	85a6                	mv	a1,s1
    80004a32:	8526                	mv	a0,s1
    80004a34:	ffffd097          	auipc	ra,0xffffd
    80004a38:	4a4080e7          	jalr	1188(ra) # 80001ed8 <sleep>
    80004a3c:	50dc                	lw	a5,36(s1)
    80004a3e:	fbed                	bnez	a5,80004a30 <begin_op+0x28>
    80004a40:	5098                	lw	a4,32(s1)
    80004a42:	2705                	addiw	a4,a4,1
    80004a44:	0007069b          	sext.w	a3,a4
    80004a48:	0027179b          	slliw	a5,a4,0x2
    80004a4c:	9fb9                	addw	a5,a5,a4
    80004a4e:	0017979b          	slliw	a5,a5,0x1
    80004a52:	54d8                	lw	a4,44(s1)
    80004a54:	9fb9                	addw	a5,a5,a4
    80004a56:	00f95963          	bge	s2,a5,80004a68 <begin_op+0x60>
    80004a5a:	85a6                	mv	a1,s1
    80004a5c:	8526                	mv	a0,s1
    80004a5e:	ffffd097          	auipc	ra,0xffffd
    80004a62:	47a080e7          	jalr	1146(ra) # 80001ed8 <sleep>
    80004a66:	bfd9                	j	80004a3c <begin_op+0x34>
    80004a68:	0002d517          	auipc	a0,0x2d
    80004a6c:	a2050513          	addi	a0,a0,-1504 # 80031488 <log>
    80004a70:	d114                	sw	a3,32(a0)
    80004a72:	ffffc097          	auipc	ra,0xffffc
    80004a76:	25c080e7          	jalr	604(ra) # 80000cce <release>
    80004a7a:	60e2                	ld	ra,24(sp)
    80004a7c:	6442                	ld	s0,16(sp)
    80004a7e:	64a2                	ld	s1,8(sp)
    80004a80:	6902                	ld	s2,0(sp)
    80004a82:	6105                	addi	sp,sp,32
    80004a84:	8082                	ret

0000000080004a86 <end_op>:
    80004a86:	7139                	addi	sp,sp,-64
    80004a88:	fc06                	sd	ra,56(sp)
    80004a8a:	f822                	sd	s0,48(sp)
    80004a8c:	f426                	sd	s1,40(sp)
    80004a8e:	f04a                	sd	s2,32(sp)
    80004a90:	ec4e                	sd	s3,24(sp)
    80004a92:	e852                	sd	s4,16(sp)
    80004a94:	e456                	sd	s5,8(sp)
    80004a96:	0080                	addi	s0,sp,64
    80004a98:	0002d497          	auipc	s1,0x2d
    80004a9c:	9f048493          	addi	s1,s1,-1552 # 80031488 <log>
    80004aa0:	8526                	mv	a0,s1
    80004aa2:	ffffc097          	auipc	ra,0xffffc
    80004aa6:	178080e7          	jalr	376(ra) # 80000c1a <acquire>
    80004aaa:	509c                	lw	a5,32(s1)
    80004aac:	37fd                	addiw	a5,a5,-1
    80004aae:	0007891b          	sext.w	s2,a5
    80004ab2:	d09c                	sw	a5,32(s1)
    80004ab4:	50dc                	lw	a5,36(s1)
    80004ab6:	e7b9                	bnez	a5,80004b04 <end_op+0x7e>
    80004ab8:	04091e63          	bnez	s2,80004b14 <end_op+0x8e>
    80004abc:	0002d497          	auipc	s1,0x2d
    80004ac0:	9cc48493          	addi	s1,s1,-1588 # 80031488 <log>
    80004ac4:	4785                	li	a5,1
    80004ac6:	d0dc                	sw	a5,36(s1)
    80004ac8:	8526                	mv	a0,s1
    80004aca:	ffffc097          	auipc	ra,0xffffc
    80004ace:	204080e7          	jalr	516(ra) # 80000cce <release>
    80004ad2:	54dc                	lw	a5,44(s1)
    80004ad4:	06f04763          	bgtz	a5,80004b42 <end_op+0xbc>
    80004ad8:	0002d497          	auipc	s1,0x2d
    80004adc:	9b048493          	addi	s1,s1,-1616 # 80031488 <log>
    80004ae0:	8526                	mv	a0,s1
    80004ae2:	ffffc097          	auipc	ra,0xffffc
    80004ae6:	138080e7          	jalr	312(ra) # 80000c1a <acquire>
    80004aea:	0204a223          	sw	zero,36(s1)
    80004aee:	8526                	mv	a0,s1
    80004af0:	ffffd097          	auipc	ra,0xffffd
    80004af4:	44e080e7          	jalr	1102(ra) # 80001f3e <wakeup>
    80004af8:	8526                	mv	a0,s1
    80004afa:	ffffc097          	auipc	ra,0xffffc
    80004afe:	1d4080e7          	jalr	468(ra) # 80000cce <release>
    80004b02:	a03d                	j	80004b30 <end_op+0xaa>
    80004b04:	00005517          	auipc	a0,0x5
    80004b08:	b9c50513          	addi	a0,a0,-1124 # 800096a0 <syscalls+0x220>
    80004b0c:	ffffc097          	auipc	ra,0xffffc
    80004b10:	a30080e7          	jalr	-1488(ra) # 8000053c <panic>
    80004b14:	0002d497          	auipc	s1,0x2d
    80004b18:	97448493          	addi	s1,s1,-1676 # 80031488 <log>
    80004b1c:	8526                	mv	a0,s1
    80004b1e:	ffffd097          	auipc	ra,0xffffd
    80004b22:	420080e7          	jalr	1056(ra) # 80001f3e <wakeup>
    80004b26:	8526                	mv	a0,s1
    80004b28:	ffffc097          	auipc	ra,0xffffc
    80004b2c:	1a6080e7          	jalr	422(ra) # 80000cce <release>
    80004b30:	70e2                	ld	ra,56(sp)
    80004b32:	7442                	ld	s0,48(sp)
    80004b34:	74a2                	ld	s1,40(sp)
    80004b36:	7902                	ld	s2,32(sp)
    80004b38:	69e2                	ld	s3,24(sp)
    80004b3a:	6a42                	ld	s4,16(sp)
    80004b3c:	6aa2                	ld	s5,8(sp)
    80004b3e:	6121                	addi	sp,sp,64
    80004b40:	8082                	ret
    80004b42:	0002da97          	auipc	s5,0x2d
    80004b46:	976a8a93          	addi	s5,s5,-1674 # 800314b8 <log+0x30>
    80004b4a:	0002da17          	auipc	s4,0x2d
    80004b4e:	93ea0a13          	addi	s4,s4,-1730 # 80031488 <log>
    80004b52:	018a2583          	lw	a1,24(s4)
    80004b56:	012585bb          	addw	a1,a1,s2
    80004b5a:	2585                	addiw	a1,a1,1
    80004b5c:	028a2503          	lw	a0,40(s4)
    80004b60:	fffff097          	auipc	ra,0xfffff
    80004b64:	cca080e7          	jalr	-822(ra) # 8000382a <bread>
    80004b68:	84aa                	mv	s1,a0
    80004b6a:	000aa583          	lw	a1,0(s5)
    80004b6e:	028a2503          	lw	a0,40(s4)
    80004b72:	fffff097          	auipc	ra,0xfffff
    80004b76:	cb8080e7          	jalr	-840(ra) # 8000382a <bread>
    80004b7a:	89aa                	mv	s3,a0
    80004b7c:	40000613          	li	a2,1024
    80004b80:	05850593          	addi	a1,a0,88
    80004b84:	05848513          	addi	a0,s1,88
    80004b88:	ffffc097          	auipc	ra,0xffffc
    80004b8c:	1ea080e7          	jalr	490(ra) # 80000d72 <memmove>
    80004b90:	8526                	mv	a0,s1
    80004b92:	fffff097          	auipc	ra,0xfffff
    80004b96:	d8a080e7          	jalr	-630(ra) # 8000391c <bwrite>
    80004b9a:	854e                	mv	a0,s3
    80004b9c:	fffff097          	auipc	ra,0xfffff
    80004ba0:	dbe080e7          	jalr	-578(ra) # 8000395a <brelse>
    80004ba4:	8526                	mv	a0,s1
    80004ba6:	fffff097          	auipc	ra,0xfffff
    80004baa:	db4080e7          	jalr	-588(ra) # 8000395a <brelse>
    80004bae:	2905                	addiw	s2,s2,1
    80004bb0:	0a91                	addi	s5,s5,4
    80004bb2:	02ca2783          	lw	a5,44(s4)
    80004bb6:	f8f94ee3          	blt	s2,a5,80004b52 <end_op+0xcc>
    80004bba:	00000097          	auipc	ra,0x0
    80004bbe:	c68080e7          	jalr	-920(ra) # 80004822 <write_head>
    80004bc2:	4501                	li	a0,0
    80004bc4:	00000097          	auipc	ra,0x0
    80004bc8:	cda080e7          	jalr	-806(ra) # 8000489e <install_trans>
    80004bcc:	0002d797          	auipc	a5,0x2d
    80004bd0:	8e07a423          	sw	zero,-1816(a5) # 800314b4 <log+0x2c>
    80004bd4:	00000097          	auipc	ra,0x0
    80004bd8:	c4e080e7          	jalr	-946(ra) # 80004822 <write_head>
    80004bdc:	bdf5                	j	80004ad8 <end_op+0x52>

0000000080004bde <log_write>:
    80004bde:	1101                	addi	sp,sp,-32
    80004be0:	ec06                	sd	ra,24(sp)
    80004be2:	e822                	sd	s0,16(sp)
    80004be4:	e426                	sd	s1,8(sp)
    80004be6:	e04a                	sd	s2,0(sp)
    80004be8:	1000                	addi	s0,sp,32
    80004bea:	84aa                	mv	s1,a0
    80004bec:	0002d917          	auipc	s2,0x2d
    80004bf0:	89c90913          	addi	s2,s2,-1892 # 80031488 <log>
    80004bf4:	854a                	mv	a0,s2
    80004bf6:	ffffc097          	auipc	ra,0xffffc
    80004bfa:	024080e7          	jalr	36(ra) # 80000c1a <acquire>
    80004bfe:	02c92603          	lw	a2,44(s2)
    80004c02:	47f5                	li	a5,29
    80004c04:	06c7c563          	blt	a5,a2,80004c6e <log_write+0x90>
    80004c08:	0002d797          	auipc	a5,0x2d
    80004c0c:	89c7a783          	lw	a5,-1892(a5) # 800314a4 <log+0x1c>
    80004c10:	37fd                	addiw	a5,a5,-1
    80004c12:	04f65e63          	bge	a2,a5,80004c6e <log_write+0x90>
    80004c16:	0002d797          	auipc	a5,0x2d
    80004c1a:	8927a783          	lw	a5,-1902(a5) # 800314a8 <log+0x20>
    80004c1e:	06f05063          	blez	a5,80004c7e <log_write+0xa0>
    80004c22:	4781                	li	a5,0
    80004c24:	06c05563          	blez	a2,80004c8e <log_write+0xb0>
    80004c28:	44cc                	lw	a1,12(s1)
    80004c2a:	0002d717          	auipc	a4,0x2d
    80004c2e:	88e70713          	addi	a4,a4,-1906 # 800314b8 <log+0x30>
    80004c32:	4781                	li	a5,0
    80004c34:	4314                	lw	a3,0(a4)
    80004c36:	04b68c63          	beq	a3,a1,80004c8e <log_write+0xb0>
    80004c3a:	2785                	addiw	a5,a5,1
    80004c3c:	0711                	addi	a4,a4,4
    80004c3e:	fef61be3          	bne	a2,a5,80004c34 <log_write+0x56>
    80004c42:	0621                	addi	a2,a2,8
    80004c44:	060a                	slli	a2,a2,0x2
    80004c46:	0002d797          	auipc	a5,0x2d
    80004c4a:	84278793          	addi	a5,a5,-1982 # 80031488 <log>
    80004c4e:	97b2                	add	a5,a5,a2
    80004c50:	44d8                	lw	a4,12(s1)
    80004c52:	cb98                	sw	a4,16(a5)
    80004c54:	8526                	mv	a0,s1
    80004c56:	fffff097          	auipc	ra,0xfffff
    80004c5a:	da2080e7          	jalr	-606(ra) # 800039f8 <bpin>
    80004c5e:	0002d717          	auipc	a4,0x2d
    80004c62:	82a70713          	addi	a4,a4,-2006 # 80031488 <log>
    80004c66:	575c                	lw	a5,44(a4)
    80004c68:	2785                	addiw	a5,a5,1
    80004c6a:	d75c                	sw	a5,44(a4)
    80004c6c:	a82d                	j	80004ca6 <log_write+0xc8>
    80004c6e:	00005517          	auipc	a0,0x5
    80004c72:	a4250513          	addi	a0,a0,-1470 # 800096b0 <syscalls+0x230>
    80004c76:	ffffc097          	auipc	ra,0xffffc
    80004c7a:	8c6080e7          	jalr	-1850(ra) # 8000053c <panic>
    80004c7e:	00005517          	auipc	a0,0x5
    80004c82:	a4a50513          	addi	a0,a0,-1462 # 800096c8 <syscalls+0x248>
    80004c86:	ffffc097          	auipc	ra,0xffffc
    80004c8a:	8b6080e7          	jalr	-1866(ra) # 8000053c <panic>
    80004c8e:	00878693          	addi	a3,a5,8
    80004c92:	068a                	slli	a3,a3,0x2
    80004c94:	0002c717          	auipc	a4,0x2c
    80004c98:	7f470713          	addi	a4,a4,2036 # 80031488 <log>
    80004c9c:	9736                	add	a4,a4,a3
    80004c9e:	44d4                	lw	a3,12(s1)
    80004ca0:	cb14                	sw	a3,16(a4)
    80004ca2:	faf609e3          	beq	a2,a5,80004c54 <log_write+0x76>
    80004ca6:	0002c517          	auipc	a0,0x2c
    80004caa:	7e250513          	addi	a0,a0,2018 # 80031488 <log>
    80004cae:	ffffc097          	auipc	ra,0xffffc
    80004cb2:	020080e7          	jalr	32(ra) # 80000cce <release>
    80004cb6:	60e2                	ld	ra,24(sp)
    80004cb8:	6442                	ld	s0,16(sp)
    80004cba:	64a2                	ld	s1,8(sp)
    80004cbc:	6902                	ld	s2,0(sp)
    80004cbe:	6105                	addi	sp,sp,32
    80004cc0:	8082                	ret

0000000080004cc2 <initsleeplock>:
    80004cc2:	1101                	addi	sp,sp,-32
    80004cc4:	ec06                	sd	ra,24(sp)
    80004cc6:	e822                	sd	s0,16(sp)
    80004cc8:	e426                	sd	s1,8(sp)
    80004cca:	e04a                	sd	s2,0(sp)
    80004ccc:	1000                	addi	s0,sp,32
    80004cce:	84aa                	mv	s1,a0
    80004cd0:	892e                	mv	s2,a1
    80004cd2:	00005597          	auipc	a1,0x5
    80004cd6:	a1658593          	addi	a1,a1,-1514 # 800096e8 <syscalls+0x268>
    80004cda:	0521                	addi	a0,a0,8
    80004cdc:	ffffc097          	auipc	ra,0xffffc
    80004ce0:	eae080e7          	jalr	-338(ra) # 80000b8a <initlock>
    80004ce4:	0324b023          	sd	s2,32(s1)
    80004ce8:	0004a023          	sw	zero,0(s1)
    80004cec:	0204a423          	sw	zero,40(s1)
    80004cf0:	60e2                	ld	ra,24(sp)
    80004cf2:	6442                	ld	s0,16(sp)
    80004cf4:	64a2                	ld	s1,8(sp)
    80004cf6:	6902                	ld	s2,0(sp)
    80004cf8:	6105                	addi	sp,sp,32
    80004cfa:	8082                	ret

0000000080004cfc <acquiresleep>:
    80004cfc:	1101                	addi	sp,sp,-32
    80004cfe:	ec06                	sd	ra,24(sp)
    80004d00:	e822                	sd	s0,16(sp)
    80004d02:	e426                	sd	s1,8(sp)
    80004d04:	e04a                	sd	s2,0(sp)
    80004d06:	1000                	addi	s0,sp,32
    80004d08:	84aa                	mv	s1,a0
    80004d0a:	00850913          	addi	s2,a0,8
    80004d0e:	854a                	mv	a0,s2
    80004d10:	ffffc097          	auipc	ra,0xffffc
    80004d14:	f0a080e7          	jalr	-246(ra) # 80000c1a <acquire>
    80004d18:	409c                	lw	a5,0(s1)
    80004d1a:	cb89                	beqz	a5,80004d2c <acquiresleep+0x30>
    80004d1c:	85ca                	mv	a1,s2
    80004d1e:	8526                	mv	a0,s1
    80004d20:	ffffd097          	auipc	ra,0xffffd
    80004d24:	1b8080e7          	jalr	440(ra) # 80001ed8 <sleep>
    80004d28:	409c                	lw	a5,0(s1)
    80004d2a:	fbed                	bnez	a5,80004d1c <acquiresleep+0x20>
    80004d2c:	4785                	li	a5,1
    80004d2e:	c09c                	sw	a5,0(s1)
    80004d30:	ffffd097          	auipc	ra,0xffffd
    80004d34:	dc0080e7          	jalr	-576(ra) # 80001af0 <myproc>
    80004d38:	2b852783          	lw	a5,696(a0)
    80004d3c:	d49c                	sw	a5,40(s1)
    80004d3e:	854a                	mv	a0,s2
    80004d40:	ffffc097          	auipc	ra,0xffffc
    80004d44:	f8e080e7          	jalr	-114(ra) # 80000cce <release>
    80004d48:	60e2                	ld	ra,24(sp)
    80004d4a:	6442                	ld	s0,16(sp)
    80004d4c:	64a2                	ld	s1,8(sp)
    80004d4e:	6902                	ld	s2,0(sp)
    80004d50:	6105                	addi	sp,sp,32
    80004d52:	8082                	ret

0000000080004d54 <releasesleep>:
    80004d54:	1101                	addi	sp,sp,-32
    80004d56:	ec06                	sd	ra,24(sp)
    80004d58:	e822                	sd	s0,16(sp)
    80004d5a:	e426                	sd	s1,8(sp)
    80004d5c:	e04a                	sd	s2,0(sp)
    80004d5e:	1000                	addi	s0,sp,32
    80004d60:	84aa                	mv	s1,a0
    80004d62:	00850913          	addi	s2,a0,8
    80004d66:	854a                	mv	a0,s2
    80004d68:	ffffc097          	auipc	ra,0xffffc
    80004d6c:	eb2080e7          	jalr	-334(ra) # 80000c1a <acquire>
    80004d70:	0004a023          	sw	zero,0(s1)
    80004d74:	0204a423          	sw	zero,40(s1)
    80004d78:	8526                	mv	a0,s1
    80004d7a:	ffffd097          	auipc	ra,0xffffd
    80004d7e:	1c4080e7          	jalr	452(ra) # 80001f3e <wakeup>
    80004d82:	854a                	mv	a0,s2
    80004d84:	ffffc097          	auipc	ra,0xffffc
    80004d88:	f4a080e7          	jalr	-182(ra) # 80000cce <release>
    80004d8c:	60e2                	ld	ra,24(sp)
    80004d8e:	6442                	ld	s0,16(sp)
    80004d90:	64a2                	ld	s1,8(sp)
    80004d92:	6902                	ld	s2,0(sp)
    80004d94:	6105                	addi	sp,sp,32
    80004d96:	8082                	ret

0000000080004d98 <holdingsleep>:
    80004d98:	7179                	addi	sp,sp,-48
    80004d9a:	f406                	sd	ra,40(sp)
    80004d9c:	f022                	sd	s0,32(sp)
    80004d9e:	ec26                	sd	s1,24(sp)
    80004da0:	e84a                	sd	s2,16(sp)
    80004da2:	e44e                	sd	s3,8(sp)
    80004da4:	1800                	addi	s0,sp,48
    80004da6:	84aa                	mv	s1,a0
    80004da8:	00850913          	addi	s2,a0,8
    80004dac:	854a                	mv	a0,s2
    80004dae:	ffffc097          	auipc	ra,0xffffc
    80004db2:	e6c080e7          	jalr	-404(ra) # 80000c1a <acquire>
    80004db6:	409c                	lw	a5,0(s1)
    80004db8:	ef99                	bnez	a5,80004dd6 <holdingsleep+0x3e>
    80004dba:	4481                	li	s1,0
    80004dbc:	854a                	mv	a0,s2
    80004dbe:	ffffc097          	auipc	ra,0xffffc
    80004dc2:	f10080e7          	jalr	-240(ra) # 80000cce <release>
    80004dc6:	8526                	mv	a0,s1
    80004dc8:	70a2                	ld	ra,40(sp)
    80004dca:	7402                	ld	s0,32(sp)
    80004dcc:	64e2                	ld	s1,24(sp)
    80004dce:	6942                	ld	s2,16(sp)
    80004dd0:	69a2                	ld	s3,8(sp)
    80004dd2:	6145                	addi	sp,sp,48
    80004dd4:	8082                	ret
    80004dd6:	0284a983          	lw	s3,40(s1)
    80004dda:	ffffd097          	auipc	ra,0xffffd
    80004dde:	d16080e7          	jalr	-746(ra) # 80001af0 <myproc>
    80004de2:	2b852483          	lw	s1,696(a0)
    80004de6:	413484b3          	sub	s1,s1,s3
    80004dea:	0014b493          	seqz	s1,s1
    80004dee:	b7f9                	j	80004dbc <holdingsleep+0x24>

0000000080004df0 <fileinit>:
    80004df0:	1141                	addi	sp,sp,-16
    80004df2:	e406                	sd	ra,8(sp)
    80004df4:	e022                	sd	s0,0(sp)
    80004df6:	0800                	addi	s0,sp,16
    80004df8:	00005597          	auipc	a1,0x5
    80004dfc:	90058593          	addi	a1,a1,-1792 # 800096f8 <syscalls+0x278>
    80004e00:	0002c517          	auipc	a0,0x2c
    80004e04:	7d050513          	addi	a0,a0,2000 # 800315d0 <ftable>
    80004e08:	ffffc097          	auipc	ra,0xffffc
    80004e0c:	d82080e7          	jalr	-638(ra) # 80000b8a <initlock>
    80004e10:	60a2                	ld	ra,8(sp)
    80004e12:	6402                	ld	s0,0(sp)
    80004e14:	0141                	addi	sp,sp,16
    80004e16:	8082                	ret

0000000080004e18 <filealloc>:
    80004e18:	1101                	addi	sp,sp,-32
    80004e1a:	ec06                	sd	ra,24(sp)
    80004e1c:	e822                	sd	s0,16(sp)
    80004e1e:	e426                	sd	s1,8(sp)
    80004e20:	1000                	addi	s0,sp,32
    80004e22:	0002c517          	auipc	a0,0x2c
    80004e26:	7ae50513          	addi	a0,a0,1966 # 800315d0 <ftable>
    80004e2a:	ffffc097          	auipc	ra,0xffffc
    80004e2e:	df0080e7          	jalr	-528(ra) # 80000c1a <acquire>
    80004e32:	0002c497          	auipc	s1,0x2c
    80004e36:	7b648493          	addi	s1,s1,1974 # 800315e8 <ftable+0x18>
    80004e3a:	0002d717          	auipc	a4,0x2d
    80004e3e:	74e70713          	addi	a4,a4,1870 # 80032588 <ftable+0xfb8>
    80004e42:	40dc                	lw	a5,4(s1)
    80004e44:	cf99                	beqz	a5,80004e62 <filealloc+0x4a>
    80004e46:	02848493          	addi	s1,s1,40
    80004e4a:	fee49ce3          	bne	s1,a4,80004e42 <filealloc+0x2a>
    80004e4e:	0002c517          	auipc	a0,0x2c
    80004e52:	78250513          	addi	a0,a0,1922 # 800315d0 <ftable>
    80004e56:	ffffc097          	auipc	ra,0xffffc
    80004e5a:	e78080e7          	jalr	-392(ra) # 80000cce <release>
    80004e5e:	4481                	li	s1,0
    80004e60:	a819                	j	80004e76 <filealloc+0x5e>
    80004e62:	4785                	li	a5,1
    80004e64:	c0dc                	sw	a5,4(s1)
    80004e66:	0002c517          	auipc	a0,0x2c
    80004e6a:	76a50513          	addi	a0,a0,1898 # 800315d0 <ftable>
    80004e6e:	ffffc097          	auipc	ra,0xffffc
    80004e72:	e60080e7          	jalr	-416(ra) # 80000cce <release>
    80004e76:	8526                	mv	a0,s1
    80004e78:	60e2                	ld	ra,24(sp)
    80004e7a:	6442                	ld	s0,16(sp)
    80004e7c:	64a2                	ld	s1,8(sp)
    80004e7e:	6105                	addi	sp,sp,32
    80004e80:	8082                	ret

0000000080004e82 <filedup>:
    80004e82:	1101                	addi	sp,sp,-32
    80004e84:	ec06                	sd	ra,24(sp)
    80004e86:	e822                	sd	s0,16(sp)
    80004e88:	e426                	sd	s1,8(sp)
    80004e8a:	1000                	addi	s0,sp,32
    80004e8c:	84aa                	mv	s1,a0
    80004e8e:	0002c517          	auipc	a0,0x2c
    80004e92:	74250513          	addi	a0,a0,1858 # 800315d0 <ftable>
    80004e96:	ffffc097          	auipc	ra,0xffffc
    80004e9a:	d84080e7          	jalr	-636(ra) # 80000c1a <acquire>
    80004e9e:	40dc                	lw	a5,4(s1)
    80004ea0:	02f05263          	blez	a5,80004ec4 <filedup+0x42>
    80004ea4:	2785                	addiw	a5,a5,1
    80004ea6:	c0dc                	sw	a5,4(s1)
    80004ea8:	0002c517          	auipc	a0,0x2c
    80004eac:	72850513          	addi	a0,a0,1832 # 800315d0 <ftable>
    80004eb0:	ffffc097          	auipc	ra,0xffffc
    80004eb4:	e1e080e7          	jalr	-482(ra) # 80000cce <release>
    80004eb8:	8526                	mv	a0,s1
    80004eba:	60e2                	ld	ra,24(sp)
    80004ebc:	6442                	ld	s0,16(sp)
    80004ebe:	64a2                	ld	s1,8(sp)
    80004ec0:	6105                	addi	sp,sp,32
    80004ec2:	8082                	ret
    80004ec4:	00005517          	auipc	a0,0x5
    80004ec8:	83c50513          	addi	a0,a0,-1988 # 80009700 <syscalls+0x280>
    80004ecc:	ffffb097          	auipc	ra,0xffffb
    80004ed0:	670080e7          	jalr	1648(ra) # 8000053c <panic>

0000000080004ed4 <fileclose>:
    80004ed4:	7139                	addi	sp,sp,-64
    80004ed6:	fc06                	sd	ra,56(sp)
    80004ed8:	f822                	sd	s0,48(sp)
    80004eda:	f426                	sd	s1,40(sp)
    80004edc:	f04a                	sd	s2,32(sp)
    80004ede:	ec4e                	sd	s3,24(sp)
    80004ee0:	e852                	sd	s4,16(sp)
    80004ee2:	e456                	sd	s5,8(sp)
    80004ee4:	0080                	addi	s0,sp,64
    80004ee6:	84aa                	mv	s1,a0
    80004ee8:	0002c517          	auipc	a0,0x2c
    80004eec:	6e850513          	addi	a0,a0,1768 # 800315d0 <ftable>
    80004ef0:	ffffc097          	auipc	ra,0xffffc
    80004ef4:	d2a080e7          	jalr	-726(ra) # 80000c1a <acquire>
    80004ef8:	40dc                	lw	a5,4(s1)
    80004efa:	06f05163          	blez	a5,80004f5c <fileclose+0x88>
    80004efe:	37fd                	addiw	a5,a5,-1
    80004f00:	0007871b          	sext.w	a4,a5
    80004f04:	c0dc                	sw	a5,4(s1)
    80004f06:	06e04363          	bgtz	a4,80004f6c <fileclose+0x98>
    80004f0a:	0004a903          	lw	s2,0(s1)
    80004f0e:	0094ca83          	lbu	s5,9(s1)
    80004f12:	0104ba03          	ld	s4,16(s1)
    80004f16:	0184b983          	ld	s3,24(s1)
    80004f1a:	0004a223          	sw	zero,4(s1)
    80004f1e:	0004a023          	sw	zero,0(s1)
    80004f22:	0002c517          	auipc	a0,0x2c
    80004f26:	6ae50513          	addi	a0,a0,1710 # 800315d0 <ftable>
    80004f2a:	ffffc097          	auipc	ra,0xffffc
    80004f2e:	da4080e7          	jalr	-604(ra) # 80000cce <release>
    80004f32:	4785                	li	a5,1
    80004f34:	04f90d63          	beq	s2,a5,80004f8e <fileclose+0xba>
    80004f38:	3979                	addiw	s2,s2,-2
    80004f3a:	4785                	li	a5,1
    80004f3c:	0527e063          	bltu	a5,s2,80004f7c <fileclose+0xa8>
    80004f40:	00000097          	auipc	ra,0x0
    80004f44:	ac8080e7          	jalr	-1336(ra) # 80004a08 <begin_op>
    80004f48:	854e                	mv	a0,s3
    80004f4a:	fffff097          	auipc	ra,0xfffff
    80004f4e:	29c080e7          	jalr	668(ra) # 800041e6 <iput>
    80004f52:	00000097          	auipc	ra,0x0
    80004f56:	b34080e7          	jalr	-1228(ra) # 80004a86 <end_op>
    80004f5a:	a00d                	j	80004f7c <fileclose+0xa8>
    80004f5c:	00004517          	auipc	a0,0x4
    80004f60:	7ac50513          	addi	a0,a0,1964 # 80009708 <syscalls+0x288>
    80004f64:	ffffb097          	auipc	ra,0xffffb
    80004f68:	5d8080e7          	jalr	1496(ra) # 8000053c <panic>
    80004f6c:	0002c517          	auipc	a0,0x2c
    80004f70:	66450513          	addi	a0,a0,1636 # 800315d0 <ftable>
    80004f74:	ffffc097          	auipc	ra,0xffffc
    80004f78:	d5a080e7          	jalr	-678(ra) # 80000cce <release>
    80004f7c:	70e2                	ld	ra,56(sp)
    80004f7e:	7442                	ld	s0,48(sp)
    80004f80:	74a2                	ld	s1,40(sp)
    80004f82:	7902                	ld	s2,32(sp)
    80004f84:	69e2                	ld	s3,24(sp)
    80004f86:	6a42                	ld	s4,16(sp)
    80004f88:	6aa2                	ld	s5,8(sp)
    80004f8a:	6121                	addi	sp,sp,64
    80004f8c:	8082                	ret
    80004f8e:	85d6                	mv	a1,s5
    80004f90:	8552                	mv	a0,s4
    80004f92:	00000097          	auipc	ra,0x0
    80004f96:	34c080e7          	jalr	844(ra) # 800052de <pipeclose>
    80004f9a:	b7cd                	j	80004f7c <fileclose+0xa8>

0000000080004f9c <filestat>:
    80004f9c:	715d                	addi	sp,sp,-80
    80004f9e:	e486                	sd	ra,72(sp)
    80004fa0:	e0a2                	sd	s0,64(sp)
    80004fa2:	fc26                	sd	s1,56(sp)
    80004fa4:	f84a                	sd	s2,48(sp)
    80004fa6:	f44e                	sd	s3,40(sp)
    80004fa8:	0880                	addi	s0,sp,80
    80004faa:	84aa                	mv	s1,a0
    80004fac:	89ae                	mv	s3,a1
    80004fae:	ffffd097          	auipc	ra,0xffffd
    80004fb2:	b42080e7          	jalr	-1214(ra) # 80001af0 <myproc>
    80004fb6:	409c                	lw	a5,0(s1)
    80004fb8:	37f9                	addiw	a5,a5,-2
    80004fba:	4705                	li	a4,1
    80004fbc:	04f76763          	bltu	a4,a5,8000500a <filestat+0x6e>
    80004fc0:	892a                	mv	s2,a0
    80004fc2:	6c88                	ld	a0,24(s1)
    80004fc4:	fffff097          	auipc	ra,0xfffff
    80004fc8:	068080e7          	jalr	104(ra) # 8000402c <ilock>
    80004fcc:	fb840593          	addi	a1,s0,-72
    80004fd0:	6c88                	ld	a0,24(s1)
    80004fd2:	fffff097          	auipc	ra,0xfffff
    80004fd6:	2e4080e7          	jalr	740(ra) # 800042b6 <stati>
    80004fda:	6c88                	ld	a0,24(s1)
    80004fdc:	fffff097          	auipc	ra,0xfffff
    80004fe0:	112080e7          	jalr	274(ra) # 800040ee <iunlock>
    80004fe4:	46e1                	li	a3,24
    80004fe6:	fb840613          	addi	a2,s0,-72
    80004fea:	85ce                	mv	a1,s3
    80004fec:	2d893503          	ld	a0,728(s2)
    80004ff0:	ffffc097          	auipc	ra,0xffffc
    80004ff4:	748080e7          	jalr	1864(ra) # 80001738 <copyout>
    80004ff8:	41f5551b          	sraiw	a0,a0,0x1f
    80004ffc:	60a6                	ld	ra,72(sp)
    80004ffe:	6406                	ld	s0,64(sp)
    80005000:	74e2                	ld	s1,56(sp)
    80005002:	7942                	ld	s2,48(sp)
    80005004:	79a2                	ld	s3,40(sp)
    80005006:	6161                	addi	sp,sp,80
    80005008:	8082                	ret
    8000500a:	557d                	li	a0,-1
    8000500c:	bfc5                	j	80004ffc <filestat+0x60>

000000008000500e <fileread>:
    8000500e:	7179                	addi	sp,sp,-48
    80005010:	f406                	sd	ra,40(sp)
    80005012:	f022                	sd	s0,32(sp)
    80005014:	ec26                	sd	s1,24(sp)
    80005016:	e84a                	sd	s2,16(sp)
    80005018:	e44e                	sd	s3,8(sp)
    8000501a:	1800                	addi	s0,sp,48
    8000501c:	00854783          	lbu	a5,8(a0)
    80005020:	c3d5                	beqz	a5,800050c4 <fileread+0xb6>
    80005022:	84aa                	mv	s1,a0
    80005024:	89ae                	mv	s3,a1
    80005026:	8932                	mv	s2,a2
    80005028:	411c                	lw	a5,0(a0)
    8000502a:	4705                	li	a4,1
    8000502c:	04e78963          	beq	a5,a4,8000507e <fileread+0x70>
    80005030:	470d                	li	a4,3
    80005032:	04e78d63          	beq	a5,a4,8000508c <fileread+0x7e>
    80005036:	4709                	li	a4,2
    80005038:	06e79e63          	bne	a5,a4,800050b4 <fileread+0xa6>
    8000503c:	6d08                	ld	a0,24(a0)
    8000503e:	fffff097          	auipc	ra,0xfffff
    80005042:	fee080e7          	jalr	-18(ra) # 8000402c <ilock>
    80005046:	874a                	mv	a4,s2
    80005048:	5094                	lw	a3,32(s1)
    8000504a:	864e                	mv	a2,s3
    8000504c:	4585                	li	a1,1
    8000504e:	6c88                	ld	a0,24(s1)
    80005050:	fffff097          	auipc	ra,0xfffff
    80005054:	290080e7          	jalr	656(ra) # 800042e0 <readi>
    80005058:	892a                	mv	s2,a0
    8000505a:	00a05563          	blez	a0,80005064 <fileread+0x56>
    8000505e:	509c                	lw	a5,32(s1)
    80005060:	9fa9                	addw	a5,a5,a0
    80005062:	d09c                	sw	a5,32(s1)
    80005064:	6c88                	ld	a0,24(s1)
    80005066:	fffff097          	auipc	ra,0xfffff
    8000506a:	088080e7          	jalr	136(ra) # 800040ee <iunlock>
    8000506e:	854a                	mv	a0,s2
    80005070:	70a2                	ld	ra,40(sp)
    80005072:	7402                	ld	s0,32(sp)
    80005074:	64e2                	ld	s1,24(sp)
    80005076:	6942                	ld	s2,16(sp)
    80005078:	69a2                	ld	s3,8(sp)
    8000507a:	6145                	addi	sp,sp,48
    8000507c:	8082                	ret
    8000507e:	6908                	ld	a0,16(a0)
    80005080:	00000097          	auipc	ra,0x0
    80005084:	3c0080e7          	jalr	960(ra) # 80005440 <piperead>
    80005088:	892a                	mv	s2,a0
    8000508a:	b7d5                	j	8000506e <fileread+0x60>
    8000508c:	02451783          	lh	a5,36(a0)
    80005090:	03079693          	slli	a3,a5,0x30
    80005094:	92c1                	srli	a3,a3,0x30
    80005096:	4725                	li	a4,9
    80005098:	02d76863          	bltu	a4,a3,800050c8 <fileread+0xba>
    8000509c:	0792                	slli	a5,a5,0x4
    8000509e:	0002c717          	auipc	a4,0x2c
    800050a2:	49270713          	addi	a4,a4,1170 # 80031530 <devsw>
    800050a6:	97ba                	add	a5,a5,a4
    800050a8:	639c                	ld	a5,0(a5)
    800050aa:	c38d                	beqz	a5,800050cc <fileread+0xbe>
    800050ac:	4505                	li	a0,1
    800050ae:	9782                	jalr	a5
    800050b0:	892a                	mv	s2,a0
    800050b2:	bf75                	j	8000506e <fileread+0x60>
    800050b4:	00004517          	auipc	a0,0x4
    800050b8:	66450513          	addi	a0,a0,1636 # 80009718 <syscalls+0x298>
    800050bc:	ffffb097          	auipc	ra,0xffffb
    800050c0:	480080e7          	jalr	1152(ra) # 8000053c <panic>
    800050c4:	597d                	li	s2,-1
    800050c6:	b765                	j	8000506e <fileread+0x60>
    800050c8:	597d                	li	s2,-1
    800050ca:	b755                	j	8000506e <fileread+0x60>
    800050cc:	597d                	li	s2,-1
    800050ce:	b745                	j	8000506e <fileread+0x60>

00000000800050d0 <filewrite>:
    800050d0:	715d                	addi	sp,sp,-80
    800050d2:	e486                	sd	ra,72(sp)
    800050d4:	e0a2                	sd	s0,64(sp)
    800050d6:	fc26                	sd	s1,56(sp)
    800050d8:	f84a                	sd	s2,48(sp)
    800050da:	f44e                	sd	s3,40(sp)
    800050dc:	f052                	sd	s4,32(sp)
    800050de:	ec56                	sd	s5,24(sp)
    800050e0:	e85a                	sd	s6,16(sp)
    800050e2:	e45e                	sd	s7,8(sp)
    800050e4:	e062                	sd	s8,0(sp)
    800050e6:	0880                	addi	s0,sp,80
    800050e8:	00954783          	lbu	a5,9(a0)
    800050ec:	10078663          	beqz	a5,800051f8 <filewrite+0x128>
    800050f0:	892a                	mv	s2,a0
    800050f2:	8b2e                	mv	s6,a1
    800050f4:	8a32                	mv	s4,a2
    800050f6:	411c                	lw	a5,0(a0)
    800050f8:	4705                	li	a4,1
    800050fa:	02e78263          	beq	a5,a4,8000511e <filewrite+0x4e>
    800050fe:	470d                	li	a4,3
    80005100:	02e78663          	beq	a5,a4,8000512c <filewrite+0x5c>
    80005104:	4709                	li	a4,2
    80005106:	0ee79163          	bne	a5,a4,800051e8 <filewrite+0x118>
    8000510a:	0ac05d63          	blez	a2,800051c4 <filewrite+0xf4>
    8000510e:	4981                	li	s3,0
    80005110:	6b85                	lui	s7,0x1
    80005112:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80005116:	6c05                	lui	s8,0x1
    80005118:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    8000511c:	a861                	j	800051b4 <filewrite+0xe4>
    8000511e:	6908                	ld	a0,16(a0)
    80005120:	00000097          	auipc	ra,0x0
    80005124:	22e080e7          	jalr	558(ra) # 8000534e <pipewrite>
    80005128:	8a2a                	mv	s4,a0
    8000512a:	a045                	j	800051ca <filewrite+0xfa>
    8000512c:	02451783          	lh	a5,36(a0)
    80005130:	03079693          	slli	a3,a5,0x30
    80005134:	92c1                	srli	a3,a3,0x30
    80005136:	4725                	li	a4,9
    80005138:	0cd76263          	bltu	a4,a3,800051fc <filewrite+0x12c>
    8000513c:	0792                	slli	a5,a5,0x4
    8000513e:	0002c717          	auipc	a4,0x2c
    80005142:	3f270713          	addi	a4,a4,1010 # 80031530 <devsw>
    80005146:	97ba                	add	a5,a5,a4
    80005148:	679c                	ld	a5,8(a5)
    8000514a:	cbdd                	beqz	a5,80005200 <filewrite+0x130>
    8000514c:	4505                	li	a0,1
    8000514e:	9782                	jalr	a5
    80005150:	8a2a                	mv	s4,a0
    80005152:	a8a5                	j	800051ca <filewrite+0xfa>
    80005154:	00048a9b          	sext.w	s5,s1
    80005158:	00000097          	auipc	ra,0x0
    8000515c:	8b0080e7          	jalr	-1872(ra) # 80004a08 <begin_op>
    80005160:	01893503          	ld	a0,24(s2)
    80005164:	fffff097          	auipc	ra,0xfffff
    80005168:	ec8080e7          	jalr	-312(ra) # 8000402c <ilock>
    8000516c:	8756                	mv	a4,s5
    8000516e:	02092683          	lw	a3,32(s2)
    80005172:	01698633          	add	a2,s3,s6
    80005176:	4585                	li	a1,1
    80005178:	01893503          	ld	a0,24(s2)
    8000517c:	fffff097          	auipc	ra,0xfffff
    80005180:	25c080e7          	jalr	604(ra) # 800043d8 <writei>
    80005184:	84aa                	mv	s1,a0
    80005186:	00a05763          	blez	a0,80005194 <filewrite+0xc4>
    8000518a:	02092783          	lw	a5,32(s2)
    8000518e:	9fa9                	addw	a5,a5,a0
    80005190:	02f92023          	sw	a5,32(s2)
    80005194:	01893503          	ld	a0,24(s2)
    80005198:	fffff097          	auipc	ra,0xfffff
    8000519c:	f56080e7          	jalr	-170(ra) # 800040ee <iunlock>
    800051a0:	00000097          	auipc	ra,0x0
    800051a4:	8e6080e7          	jalr	-1818(ra) # 80004a86 <end_op>
    800051a8:	009a9f63          	bne	s5,s1,800051c6 <filewrite+0xf6>
    800051ac:	013489bb          	addw	s3,s1,s3
    800051b0:	0149db63          	bge	s3,s4,800051c6 <filewrite+0xf6>
    800051b4:	413a04bb          	subw	s1,s4,s3
    800051b8:	0004879b          	sext.w	a5,s1
    800051bc:	f8fbdce3          	bge	s7,a5,80005154 <filewrite+0x84>
    800051c0:	84e2                	mv	s1,s8
    800051c2:	bf49                	j	80005154 <filewrite+0x84>
    800051c4:	4981                	li	s3,0
    800051c6:	013a1f63          	bne	s4,s3,800051e4 <filewrite+0x114>
    800051ca:	8552                	mv	a0,s4
    800051cc:	60a6                	ld	ra,72(sp)
    800051ce:	6406                	ld	s0,64(sp)
    800051d0:	74e2                	ld	s1,56(sp)
    800051d2:	7942                	ld	s2,48(sp)
    800051d4:	79a2                	ld	s3,40(sp)
    800051d6:	7a02                	ld	s4,32(sp)
    800051d8:	6ae2                	ld	s5,24(sp)
    800051da:	6b42                	ld	s6,16(sp)
    800051dc:	6ba2                	ld	s7,8(sp)
    800051de:	6c02                	ld	s8,0(sp)
    800051e0:	6161                	addi	sp,sp,80
    800051e2:	8082                	ret
    800051e4:	5a7d                	li	s4,-1
    800051e6:	b7d5                	j	800051ca <filewrite+0xfa>
    800051e8:	00004517          	auipc	a0,0x4
    800051ec:	54050513          	addi	a0,a0,1344 # 80009728 <syscalls+0x2a8>
    800051f0:	ffffb097          	auipc	ra,0xffffb
    800051f4:	34c080e7          	jalr	844(ra) # 8000053c <panic>
    800051f8:	5a7d                	li	s4,-1
    800051fa:	bfc1                	j	800051ca <filewrite+0xfa>
    800051fc:	5a7d                	li	s4,-1
    800051fe:	b7f1                	j	800051ca <filewrite+0xfa>
    80005200:	5a7d                	li	s4,-1
    80005202:	b7e1                	j	800051ca <filewrite+0xfa>

0000000080005204 <pipealloc>:
    80005204:	7179                	addi	sp,sp,-48
    80005206:	f406                	sd	ra,40(sp)
    80005208:	f022                	sd	s0,32(sp)
    8000520a:	ec26                	sd	s1,24(sp)
    8000520c:	e84a                	sd	s2,16(sp)
    8000520e:	e44e                	sd	s3,8(sp)
    80005210:	e052                	sd	s4,0(sp)
    80005212:	1800                	addi	s0,sp,48
    80005214:	84aa                	mv	s1,a0
    80005216:	8a2e                	mv	s4,a1
    80005218:	0005b023          	sd	zero,0(a1)
    8000521c:	00053023          	sd	zero,0(a0)
    80005220:	00000097          	auipc	ra,0x0
    80005224:	bf8080e7          	jalr	-1032(ra) # 80004e18 <filealloc>
    80005228:	e088                	sd	a0,0(s1)
    8000522a:	c551                	beqz	a0,800052b6 <pipealloc+0xb2>
    8000522c:	00000097          	auipc	ra,0x0
    80005230:	bec080e7          	jalr	-1044(ra) # 80004e18 <filealloc>
    80005234:	00aa3023          	sd	a0,0(s4)
    80005238:	c92d                	beqz	a0,800052aa <pipealloc+0xa6>
    8000523a:	ffffc097          	auipc	ra,0xffffc
    8000523e:	8a8080e7          	jalr	-1880(ra) # 80000ae2 <kalloc>
    80005242:	892a                	mv	s2,a0
    80005244:	c125                	beqz	a0,800052a4 <pipealloc+0xa0>
    80005246:	4985                	li	s3,1
    80005248:	23352023          	sw	s3,544(a0)
    8000524c:	23352223          	sw	s3,548(a0)
    80005250:	20052e23          	sw	zero,540(a0)
    80005254:	20052c23          	sw	zero,536(a0)
    80005258:	00004597          	auipc	a1,0x4
    8000525c:	4e058593          	addi	a1,a1,1248 # 80009738 <syscalls+0x2b8>
    80005260:	ffffc097          	auipc	ra,0xffffc
    80005264:	92a080e7          	jalr	-1750(ra) # 80000b8a <initlock>
    80005268:	609c                	ld	a5,0(s1)
    8000526a:	0137a023          	sw	s3,0(a5)
    8000526e:	609c                	ld	a5,0(s1)
    80005270:	01378423          	sb	s3,8(a5)
    80005274:	609c                	ld	a5,0(s1)
    80005276:	000784a3          	sb	zero,9(a5)
    8000527a:	609c                	ld	a5,0(s1)
    8000527c:	0127b823          	sd	s2,16(a5)
    80005280:	000a3783          	ld	a5,0(s4)
    80005284:	0137a023          	sw	s3,0(a5)
    80005288:	000a3783          	ld	a5,0(s4)
    8000528c:	00078423          	sb	zero,8(a5)
    80005290:	000a3783          	ld	a5,0(s4)
    80005294:	013784a3          	sb	s3,9(a5)
    80005298:	000a3783          	ld	a5,0(s4)
    8000529c:	0127b823          	sd	s2,16(a5)
    800052a0:	4501                	li	a0,0
    800052a2:	a025                	j	800052ca <pipealloc+0xc6>
    800052a4:	6088                	ld	a0,0(s1)
    800052a6:	e501                	bnez	a0,800052ae <pipealloc+0xaa>
    800052a8:	a039                	j	800052b6 <pipealloc+0xb2>
    800052aa:	6088                	ld	a0,0(s1)
    800052ac:	c51d                	beqz	a0,800052da <pipealloc+0xd6>
    800052ae:	00000097          	auipc	ra,0x0
    800052b2:	c26080e7          	jalr	-986(ra) # 80004ed4 <fileclose>
    800052b6:	000a3783          	ld	a5,0(s4)
    800052ba:	557d                	li	a0,-1
    800052bc:	c799                	beqz	a5,800052ca <pipealloc+0xc6>
    800052be:	853e                	mv	a0,a5
    800052c0:	00000097          	auipc	ra,0x0
    800052c4:	c14080e7          	jalr	-1004(ra) # 80004ed4 <fileclose>
    800052c8:	557d                	li	a0,-1
    800052ca:	70a2                	ld	ra,40(sp)
    800052cc:	7402                	ld	s0,32(sp)
    800052ce:	64e2                	ld	s1,24(sp)
    800052d0:	6942                	ld	s2,16(sp)
    800052d2:	69a2                	ld	s3,8(sp)
    800052d4:	6a02                	ld	s4,0(sp)
    800052d6:	6145                	addi	sp,sp,48
    800052d8:	8082                	ret
    800052da:	557d                	li	a0,-1
    800052dc:	b7fd                	j	800052ca <pipealloc+0xc6>

00000000800052de <pipeclose>:
    800052de:	1101                	addi	sp,sp,-32
    800052e0:	ec06                	sd	ra,24(sp)
    800052e2:	e822                	sd	s0,16(sp)
    800052e4:	e426                	sd	s1,8(sp)
    800052e6:	e04a                	sd	s2,0(sp)
    800052e8:	1000                	addi	s0,sp,32
    800052ea:	84aa                	mv	s1,a0
    800052ec:	892e                	mv	s2,a1
    800052ee:	ffffc097          	auipc	ra,0xffffc
    800052f2:	92c080e7          	jalr	-1748(ra) # 80000c1a <acquire>
    800052f6:	02090d63          	beqz	s2,80005330 <pipeclose+0x52>
    800052fa:	2204a223          	sw	zero,548(s1)
    800052fe:	21848513          	addi	a0,s1,536
    80005302:	ffffd097          	auipc	ra,0xffffd
    80005306:	c3c080e7          	jalr	-964(ra) # 80001f3e <wakeup>
    8000530a:	2204b783          	ld	a5,544(s1)
    8000530e:	eb95                	bnez	a5,80005342 <pipeclose+0x64>
    80005310:	8526                	mv	a0,s1
    80005312:	ffffc097          	auipc	ra,0xffffc
    80005316:	9bc080e7          	jalr	-1604(ra) # 80000cce <release>
    8000531a:	8526                	mv	a0,s1
    8000531c:	ffffb097          	auipc	ra,0xffffb
    80005320:	6c8080e7          	jalr	1736(ra) # 800009e4 <kfree>
    80005324:	60e2                	ld	ra,24(sp)
    80005326:	6442                	ld	s0,16(sp)
    80005328:	64a2                	ld	s1,8(sp)
    8000532a:	6902                	ld	s2,0(sp)
    8000532c:	6105                	addi	sp,sp,32
    8000532e:	8082                	ret
    80005330:	2204a023          	sw	zero,544(s1)
    80005334:	21c48513          	addi	a0,s1,540
    80005338:	ffffd097          	auipc	ra,0xffffd
    8000533c:	c06080e7          	jalr	-1018(ra) # 80001f3e <wakeup>
    80005340:	b7e9                	j	8000530a <pipeclose+0x2c>
    80005342:	8526                	mv	a0,s1
    80005344:	ffffc097          	auipc	ra,0xffffc
    80005348:	98a080e7          	jalr	-1654(ra) # 80000cce <release>
    8000534c:	bfe1                	j	80005324 <pipeclose+0x46>

000000008000534e <pipewrite>:
    8000534e:	711d                	addi	sp,sp,-96
    80005350:	ec86                	sd	ra,88(sp)
    80005352:	e8a2                	sd	s0,80(sp)
    80005354:	e4a6                	sd	s1,72(sp)
    80005356:	e0ca                	sd	s2,64(sp)
    80005358:	fc4e                	sd	s3,56(sp)
    8000535a:	f852                	sd	s4,48(sp)
    8000535c:	f456                	sd	s5,40(sp)
    8000535e:	f05a                	sd	s6,32(sp)
    80005360:	ec5e                	sd	s7,24(sp)
    80005362:	e862                	sd	s8,16(sp)
    80005364:	1080                	addi	s0,sp,96
    80005366:	84aa                	mv	s1,a0
    80005368:	8aae                	mv	s5,a1
    8000536a:	8a32                	mv	s4,a2
    8000536c:	ffffc097          	auipc	ra,0xffffc
    80005370:	784080e7          	jalr	1924(ra) # 80001af0 <myproc>
    80005374:	89aa                	mv	s3,a0
    80005376:	8526                	mv	a0,s1
    80005378:	ffffc097          	auipc	ra,0xffffc
    8000537c:	8a2080e7          	jalr	-1886(ra) # 80000c1a <acquire>
    80005380:	0b405363          	blez	s4,80005426 <pipewrite+0xd8>
    80005384:	4901                	li	s2,0
    80005386:	5b7d                	li	s6,-1
    80005388:	21848c13          	addi	s8,s1,536
    8000538c:	21c48b93          	addi	s7,s1,540
    80005390:	a089                	j	800053d2 <pipewrite+0x84>
    80005392:	8526                	mv	a0,s1
    80005394:	ffffc097          	auipc	ra,0xffffc
    80005398:	93a080e7          	jalr	-1734(ra) # 80000cce <release>
    8000539c:	597d                	li	s2,-1
    8000539e:	854a                	mv	a0,s2
    800053a0:	60e6                	ld	ra,88(sp)
    800053a2:	6446                	ld	s0,80(sp)
    800053a4:	64a6                	ld	s1,72(sp)
    800053a6:	6906                	ld	s2,64(sp)
    800053a8:	79e2                	ld	s3,56(sp)
    800053aa:	7a42                	ld	s4,48(sp)
    800053ac:	7aa2                	ld	s5,40(sp)
    800053ae:	7b02                	ld	s6,32(sp)
    800053b0:	6be2                	ld	s7,24(sp)
    800053b2:	6c42                	ld	s8,16(sp)
    800053b4:	6125                	addi	sp,sp,96
    800053b6:	8082                	ret
    800053b8:	8562                	mv	a0,s8
    800053ba:	ffffd097          	auipc	ra,0xffffd
    800053be:	b84080e7          	jalr	-1148(ra) # 80001f3e <wakeup>
    800053c2:	85a6                	mv	a1,s1
    800053c4:	855e                	mv	a0,s7
    800053c6:	ffffd097          	auipc	ra,0xffffd
    800053ca:	b12080e7          	jalr	-1262(ra) # 80001ed8 <sleep>
    800053ce:	05495d63          	bge	s2,s4,80005428 <pipewrite+0xda>
    800053d2:	2204a783          	lw	a5,544(s1)
    800053d6:	dfd5                	beqz	a5,80005392 <pipewrite+0x44>
    800053d8:	2b09a783          	lw	a5,688(s3)
    800053dc:	fbdd                	bnez	a5,80005392 <pipewrite+0x44>
    800053de:	2184a783          	lw	a5,536(s1)
    800053e2:	21c4a703          	lw	a4,540(s1)
    800053e6:	2007879b          	addiw	a5,a5,512
    800053ea:	fcf707e3          	beq	a4,a5,800053b8 <pipewrite+0x6a>
    800053ee:	4685                	li	a3,1
    800053f0:	01590633          	add	a2,s2,s5
    800053f4:	faf40593          	addi	a1,s0,-81
    800053f8:	2d89b503          	ld	a0,728(s3)
    800053fc:	ffffc097          	auipc	ra,0xffffc
    80005400:	3c8080e7          	jalr	968(ra) # 800017c4 <copyin>
    80005404:	03650263          	beq	a0,s6,80005428 <pipewrite+0xda>
    80005408:	21c4a783          	lw	a5,540(s1)
    8000540c:	0017871b          	addiw	a4,a5,1
    80005410:	20e4ae23          	sw	a4,540(s1)
    80005414:	1ff7f793          	andi	a5,a5,511
    80005418:	97a6                	add	a5,a5,s1
    8000541a:	faf44703          	lbu	a4,-81(s0)
    8000541e:	00e78c23          	sb	a4,24(a5)
    80005422:	2905                	addiw	s2,s2,1
    80005424:	b76d                	j	800053ce <pipewrite+0x80>
    80005426:	4901                	li	s2,0
    80005428:	21848513          	addi	a0,s1,536
    8000542c:	ffffd097          	auipc	ra,0xffffd
    80005430:	b12080e7          	jalr	-1262(ra) # 80001f3e <wakeup>
    80005434:	8526                	mv	a0,s1
    80005436:	ffffc097          	auipc	ra,0xffffc
    8000543a:	898080e7          	jalr	-1896(ra) # 80000cce <release>
    8000543e:	b785                	j	8000539e <pipewrite+0x50>

0000000080005440 <piperead>:
    80005440:	715d                	addi	sp,sp,-80
    80005442:	e486                	sd	ra,72(sp)
    80005444:	e0a2                	sd	s0,64(sp)
    80005446:	fc26                	sd	s1,56(sp)
    80005448:	f84a                	sd	s2,48(sp)
    8000544a:	f44e                	sd	s3,40(sp)
    8000544c:	f052                	sd	s4,32(sp)
    8000544e:	ec56                	sd	s5,24(sp)
    80005450:	e85a                	sd	s6,16(sp)
    80005452:	0880                	addi	s0,sp,80
    80005454:	84aa                	mv	s1,a0
    80005456:	892e                	mv	s2,a1
    80005458:	8ab2                	mv	s5,a2
    8000545a:	ffffc097          	auipc	ra,0xffffc
    8000545e:	696080e7          	jalr	1686(ra) # 80001af0 <myproc>
    80005462:	8a2a                	mv	s4,a0
    80005464:	8526                	mv	a0,s1
    80005466:	ffffb097          	auipc	ra,0xffffb
    8000546a:	7b4080e7          	jalr	1972(ra) # 80000c1a <acquire>
    8000546e:	2184a703          	lw	a4,536(s1)
    80005472:	21c4a783          	lw	a5,540(s1)
    80005476:	21848993          	addi	s3,s1,536
    8000547a:	02f71463          	bne	a4,a5,800054a2 <piperead+0x62>
    8000547e:	2244a783          	lw	a5,548(s1)
    80005482:	c385                	beqz	a5,800054a2 <piperead+0x62>
    80005484:	2b0a2783          	lw	a5,688(s4)
    80005488:	ebc9                	bnez	a5,8000551a <piperead+0xda>
    8000548a:	85a6                	mv	a1,s1
    8000548c:	854e                	mv	a0,s3
    8000548e:	ffffd097          	auipc	ra,0xffffd
    80005492:	a4a080e7          	jalr	-1462(ra) # 80001ed8 <sleep>
    80005496:	2184a703          	lw	a4,536(s1)
    8000549a:	21c4a783          	lw	a5,540(s1)
    8000549e:	fef700e3          	beq	a4,a5,8000547e <piperead+0x3e>
    800054a2:	4981                	li	s3,0
    800054a4:	5b7d                	li	s6,-1
    800054a6:	05505463          	blez	s5,800054ee <piperead+0xae>
    800054aa:	2184a783          	lw	a5,536(s1)
    800054ae:	21c4a703          	lw	a4,540(s1)
    800054b2:	02f70e63          	beq	a4,a5,800054ee <piperead+0xae>
    800054b6:	0017871b          	addiw	a4,a5,1
    800054ba:	20e4ac23          	sw	a4,536(s1)
    800054be:	1ff7f793          	andi	a5,a5,511
    800054c2:	97a6                	add	a5,a5,s1
    800054c4:	0187c783          	lbu	a5,24(a5)
    800054c8:	faf40fa3          	sb	a5,-65(s0)
    800054cc:	4685                	li	a3,1
    800054ce:	fbf40613          	addi	a2,s0,-65
    800054d2:	85ca                	mv	a1,s2
    800054d4:	2d8a3503          	ld	a0,728(s4)
    800054d8:	ffffc097          	auipc	ra,0xffffc
    800054dc:	260080e7          	jalr	608(ra) # 80001738 <copyout>
    800054e0:	01650763          	beq	a0,s6,800054ee <piperead+0xae>
    800054e4:	2985                	addiw	s3,s3,1
    800054e6:	0905                	addi	s2,s2,1
    800054e8:	fd3a91e3          	bne	s5,s3,800054aa <piperead+0x6a>
    800054ec:	89d6                	mv	s3,s5
    800054ee:	21c48513          	addi	a0,s1,540
    800054f2:	ffffd097          	auipc	ra,0xffffd
    800054f6:	a4c080e7          	jalr	-1460(ra) # 80001f3e <wakeup>
    800054fa:	8526                	mv	a0,s1
    800054fc:	ffffb097          	auipc	ra,0xffffb
    80005500:	7d2080e7          	jalr	2002(ra) # 80000cce <release>
    80005504:	854e                	mv	a0,s3
    80005506:	60a6                	ld	ra,72(sp)
    80005508:	6406                	ld	s0,64(sp)
    8000550a:	74e2                	ld	s1,56(sp)
    8000550c:	7942                	ld	s2,48(sp)
    8000550e:	79a2                	ld	s3,40(sp)
    80005510:	7a02                	ld	s4,32(sp)
    80005512:	6ae2                	ld	s5,24(sp)
    80005514:	6b42                	ld	s6,16(sp)
    80005516:	6161                	addi	sp,sp,80
    80005518:	8082                	ret
    8000551a:	8526                	mv	a0,s1
    8000551c:	ffffb097          	auipc	ra,0xffffb
    80005520:	7b2080e7          	jalr	1970(ra) # 80000cce <release>
    80005524:	59fd                	li	s3,-1
    80005526:	bff9                	j	80005504 <piperead+0xc4>

0000000080005528 <print_prefix>:
    80005528:	1141                	addi	sp,sp,-16
    8000552a:	e422                	sd	s0,8(sp)
    8000552c:	0800                	addi	s0,sp,16
    8000552e:	4709                	li	a4,2
    80005530:	02e50263          	beq	a0,a4,80005554 <print_prefix+0x2c>
    80005534:	87aa                	mv	a5,a0
    80005536:	4705                	li	a4,1
    80005538:	00004517          	auipc	a0,0x4
    8000553c:	21850513          	addi	a0,a0,536 # 80009750 <syscalls+0x2d0>
    80005540:	00e78563          	beq	a5,a4,8000554a <print_prefix+0x22>
    80005544:	6422                	ld	s0,8(sp)
    80005546:	0141                	addi	sp,sp,16
    80005548:	8082                	ret
    8000554a:	00004517          	auipc	a0,0x4
    8000554e:	1fe50513          	addi	a0,a0,510 # 80009748 <syscalls+0x2c8>
    80005552:	bfcd                	j	80005544 <print_prefix+0x1c>
    80005554:	00004517          	auipc	a0,0x4
    80005558:	1ec50513          	addi	a0,a0,492 # 80009740 <syscalls+0x2c0>
    8000555c:	b7e5                	j	80005544 <print_prefix+0x1c>

000000008000555e <vmprint_helper>:
    8000555e:	715d                	addi	sp,sp,-80
    80005560:	e486                	sd	ra,72(sp)
    80005562:	e0a2                	sd	s0,64(sp)
    80005564:	fc26                	sd	s1,56(sp)
    80005566:	f84a                	sd	s2,48(sp)
    80005568:	f44e                	sd	s3,40(sp)
    8000556a:	f052                	sd	s4,32(sp)
    8000556c:	ec56                	sd	s5,24(sp)
    8000556e:	e85a                	sd	s6,16(sp)
    80005570:	e45e                	sd	s7,8(sp)
    80005572:	e062                	sd	s8,0(sp)
    80005574:	0880                	addi	s0,sp,80
    80005576:	8b2e                	mv	s6,a1
    80005578:	8ab2                	mv	s5,a2
    8000557a:	892a                	mv	s2,a0
    8000557c:	4481                	li	s1,0
    8000557e:	00004b97          	auipc	s7,0x4
    80005582:	1e2b8b93          	addi	s7,s7,482 # 80009760 <syscalls+0x2e0>
    80005586:	fff60c1b          	addiw	s8,a2,-1
    8000558a:	20000a13          	li	s4,512
    8000558e:	a029                	j	80005598 <vmprint_helper+0x3a>
    80005590:	2485                	addiw	s1,s1,1
    80005592:	0921                	addi	s2,s2,8
    80005594:	05448163          	beq	s1,s4,800055d6 <vmprint_helper+0x78>
    80005598:	00093683          	ld	a3,0(s2)
    8000559c:	0016f793          	andi	a5,a3,1
    800055a0:	dbe5                	beqz	a5,80005590 <vmprint_helper+0x32>
    800055a2:	00a6d993          	srli	s3,a3,0xa
    800055a6:	09b2                	slli	s3,s3,0xc
    800055a8:	874e                	mv	a4,s3
    800055aa:	8626                	mv	a2,s1
    800055ac:	85da                	mv	a1,s6
    800055ae:	855e                	mv	a0,s7
    800055b0:	ffffb097          	auipc	ra,0xffffb
    800055b4:	fd6080e7          	jalr	-42(ra) # 80000586 <printf>
    800055b8:	fd505ce3          	blez	s5,80005590 <vmprint_helper+0x32>
    800055bc:	8562                	mv	a0,s8
    800055be:	00000097          	auipc	ra,0x0
    800055c2:	f6a080e7          	jalr	-150(ra) # 80005528 <print_prefix>
    800055c6:	85aa                	mv	a1,a0
    800055c8:	8662                	mv	a2,s8
    800055ca:	854e                	mv	a0,s3
    800055cc:	00000097          	auipc	ra,0x0
    800055d0:	f92080e7          	jalr	-110(ra) # 8000555e <vmprint_helper>
    800055d4:	bf75                	j	80005590 <vmprint_helper+0x32>
    800055d6:	60a6                	ld	ra,72(sp)
    800055d8:	6406                	ld	s0,64(sp)
    800055da:	74e2                	ld	s1,56(sp)
    800055dc:	7942                	ld	s2,48(sp)
    800055de:	79a2                	ld	s3,40(sp)
    800055e0:	7a02                	ld	s4,32(sp)
    800055e2:	6ae2                	ld	s5,24(sp)
    800055e4:	6b42                	ld	s6,16(sp)
    800055e6:	6ba2                	ld	s7,8(sp)
    800055e8:	6c02                	ld	s8,0(sp)
    800055ea:	6161                	addi	sp,sp,80
    800055ec:	8082                	ret

00000000800055ee <vmprint>:
    800055ee:	1101                	addi	sp,sp,-32
    800055f0:	ec06                	sd	ra,24(sp)
    800055f2:	e822                	sd	s0,16(sp)
    800055f4:	e426                	sd	s1,8(sp)
    800055f6:	1000                	addi	s0,sp,32
    800055f8:	84aa                	mv	s1,a0
    800055fa:	85aa                	mv	a1,a0
    800055fc:	00004517          	auipc	a0,0x4
    80005600:	17c50513          	addi	a0,a0,380 # 80009778 <syscalls+0x2f8>
    80005604:	ffffb097          	auipc	ra,0xffffb
    80005608:	f82080e7          	jalr	-126(ra) # 80000586 <printf>
    8000560c:	4609                	li	a2,2
    8000560e:	00004597          	auipc	a1,0x4
    80005612:	17a58593          	addi	a1,a1,378 # 80009788 <syscalls+0x308>
    80005616:	8526                	mv	a0,s1
    80005618:	00000097          	auipc	ra,0x0
    8000561c:	f46080e7          	jalr	-186(ra) # 8000555e <vmprint_helper>
    80005620:	60e2                	ld	ra,24(sp)
    80005622:	6442                	ld	s0,16(sp)
    80005624:	64a2                	ld	s1,8(sp)
    80005626:	6105                	addi	sp,sp,32
    80005628:	8082                	ret

000000008000562a <exec>:
    8000562a:	de010113          	addi	sp,sp,-544
    8000562e:	20113c23          	sd	ra,536(sp)
    80005632:	20813823          	sd	s0,528(sp)
    80005636:	20913423          	sd	s1,520(sp)
    8000563a:	21213023          	sd	s2,512(sp)
    8000563e:	ffce                	sd	s3,504(sp)
    80005640:	fbd2                	sd	s4,496(sp)
    80005642:	f7d6                	sd	s5,488(sp)
    80005644:	f3da                	sd	s6,480(sp)
    80005646:	efde                	sd	s7,472(sp)
    80005648:	ebe2                	sd	s8,464(sp)
    8000564a:	e7e6                	sd	s9,456(sp)
    8000564c:	e3ea                	sd	s10,448(sp)
    8000564e:	ff6e                	sd	s11,440(sp)
    80005650:	1400                	addi	s0,sp,544
    80005652:	892a                	mv	s2,a0
    80005654:	dea43423          	sd	a0,-536(s0)
    80005658:	deb43823          	sd	a1,-528(s0)
    8000565c:	ffffc097          	auipc	ra,0xffffc
    80005660:	494080e7          	jalr	1172(ra) # 80001af0 <myproc>
    80005664:	84aa                	mv	s1,a0
    80005666:	fffff097          	auipc	ra,0xfffff
    8000566a:	3a2080e7          	jalr	930(ra) # 80004a08 <begin_op>
    8000566e:	854a                	mv	a0,s2
    80005670:	fffff097          	auipc	ra,0xfffff
    80005674:	178080e7          	jalr	376(ra) # 800047e8 <namei>
    80005678:	c93d                	beqz	a0,800056ee <exec+0xc4>
    8000567a:	8aaa                	mv	s5,a0
    8000567c:	fffff097          	auipc	ra,0xfffff
    80005680:	9b0080e7          	jalr	-1616(ra) # 8000402c <ilock>
    80005684:	04000713          	li	a4,64
    80005688:	4681                	li	a3,0
    8000568a:	e5040613          	addi	a2,s0,-432
    8000568e:	4581                	li	a1,0
    80005690:	8556                	mv	a0,s5
    80005692:	fffff097          	auipc	ra,0xfffff
    80005696:	c4e080e7          	jalr	-946(ra) # 800042e0 <readi>
    8000569a:	04000793          	li	a5,64
    8000569e:	00f51a63          	bne	a0,a5,800056b2 <exec+0x88>
    800056a2:	e5042703          	lw	a4,-432(s0)
    800056a6:	464c47b7          	lui	a5,0x464c4
    800056aa:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800056ae:	04f70663          	beq	a4,a5,800056fa <exec+0xd0>
    800056b2:	8556                	mv	a0,s5
    800056b4:	fffff097          	auipc	ra,0xfffff
    800056b8:	bda080e7          	jalr	-1062(ra) # 8000428e <iunlockput>
    800056bc:	fffff097          	auipc	ra,0xfffff
    800056c0:	3ca080e7          	jalr	970(ra) # 80004a86 <end_op>
    800056c4:	557d                	li	a0,-1
    800056c6:	21813083          	ld	ra,536(sp)
    800056ca:	21013403          	ld	s0,528(sp)
    800056ce:	20813483          	ld	s1,520(sp)
    800056d2:	20013903          	ld	s2,512(sp)
    800056d6:	79fe                	ld	s3,504(sp)
    800056d8:	7a5e                	ld	s4,496(sp)
    800056da:	7abe                	ld	s5,488(sp)
    800056dc:	7b1e                	ld	s6,480(sp)
    800056de:	6bfe                	ld	s7,472(sp)
    800056e0:	6c5e                	ld	s8,464(sp)
    800056e2:	6cbe                	ld	s9,456(sp)
    800056e4:	6d1e                	ld	s10,448(sp)
    800056e6:	7dfa                	ld	s11,440(sp)
    800056e8:	22010113          	addi	sp,sp,544
    800056ec:	8082                	ret
    800056ee:	fffff097          	auipc	ra,0xfffff
    800056f2:	398080e7          	jalr	920(ra) # 80004a86 <end_op>
    800056f6:	557d                	li	a0,-1
    800056f8:	b7f9                	j	800056c6 <exec+0x9c>
    800056fa:	8526                	mv	a0,s1
    800056fc:	ffffc097          	auipc	ra,0xffffc
    80005700:	4b8080e7          	jalr	1208(ra) # 80001bb4 <proc_pagetable>
    80005704:	8b2a                	mv	s6,a0
    80005706:	d555                	beqz	a0,800056b2 <exec+0x88>
    80005708:	e7042783          	lw	a5,-400(s0)
    8000570c:	e8845703          	lhu	a4,-376(s0)
    80005710:	c735                	beqz	a4,8000577c <exec+0x152>
    80005712:	4481                	li	s1,0
    80005714:	e0043423          	sd	zero,-504(s0)
    80005718:	6a05                	lui	s4,0x1
    8000571a:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    8000571e:	dee43023          	sd	a4,-544(s0)
    80005722:	6d85                	lui	s11,0x1
    80005724:	7d7d                	lui	s10,0xfffff
    80005726:	ac1d                	j	8000595c <exec+0x332>
    80005728:	00004517          	auipc	a0,0x4
    8000572c:	06850513          	addi	a0,a0,104 # 80009790 <syscalls+0x310>
    80005730:	ffffb097          	auipc	ra,0xffffb
    80005734:	e0c080e7          	jalr	-500(ra) # 8000053c <panic>
    80005738:	874a                	mv	a4,s2
    8000573a:	009c86bb          	addw	a3,s9,s1
    8000573e:	4581                	li	a1,0
    80005740:	8556                	mv	a0,s5
    80005742:	fffff097          	auipc	ra,0xfffff
    80005746:	b9e080e7          	jalr	-1122(ra) # 800042e0 <readi>
    8000574a:	2501                	sext.w	a0,a0
    8000574c:	1aa91863          	bne	s2,a0,800058fc <exec+0x2d2>
    80005750:	009d84bb          	addw	s1,s11,s1
    80005754:	013d09bb          	addw	s3,s10,s3
    80005758:	1f74f263          	bgeu	s1,s7,8000593c <exec+0x312>
    8000575c:	02049593          	slli	a1,s1,0x20
    80005760:	9181                	srli	a1,a1,0x20
    80005762:	95e2                	add	a1,a1,s8
    80005764:	855a                	mv	a0,s6
    80005766:	ffffc097          	auipc	ra,0xffffc
    8000576a:	936080e7          	jalr	-1738(ra) # 8000109c <walkaddr>
    8000576e:	862a                	mv	a2,a0
    80005770:	dd45                	beqz	a0,80005728 <exec+0xfe>
    80005772:	8952                	mv	s2,s4
    80005774:	fd49f2e3          	bgeu	s3,s4,80005738 <exec+0x10e>
    80005778:	894e                	mv	s2,s3
    8000577a:	bf7d                	j	80005738 <exec+0x10e>
    8000577c:	4481                	li	s1,0
    8000577e:	8556                	mv	a0,s5
    80005780:	fffff097          	auipc	ra,0xfffff
    80005784:	b0e080e7          	jalr	-1266(ra) # 8000428e <iunlockput>
    80005788:	fffff097          	auipc	ra,0xfffff
    8000578c:	2fe080e7          	jalr	766(ra) # 80004a86 <end_op>
    80005790:	ffffc097          	auipc	ra,0xffffc
    80005794:	360080e7          	jalr	864(ra) # 80001af0 <myproc>
    80005798:	8baa                	mv	s7,a0
    8000579a:	2d053d03          	ld	s10,720(a0)
    8000579e:	6785                	lui	a5,0x1
    800057a0:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800057a2:	97a6                	add	a5,a5,s1
    800057a4:	777d                	lui	a4,0xfffff
    800057a6:	8ff9                	and	a5,a5,a4
    800057a8:	def43c23          	sd	a5,-520(s0)
    800057ac:	6609                	lui	a2,0x2
    800057ae:	963e                	add	a2,a2,a5
    800057b0:	85be                	mv	a1,a5
    800057b2:	855a                	mv	a0,s6
    800057b4:	ffffc097          	auipc	ra,0xffffc
    800057b8:	c8e080e7          	jalr	-882(ra) # 80001442 <uvmalloc>
    800057bc:	8c2a                	mv	s8,a0
    800057be:	4a81                	li	s5,0
    800057c0:	12050e63          	beqz	a0,800058fc <exec+0x2d2>
    800057c4:	75f9                	lui	a1,0xffffe
    800057c6:	95aa                	add	a1,a1,a0
    800057c8:	855a                	mv	a0,s6
    800057ca:	ffffc097          	auipc	ra,0xffffc
    800057ce:	f3c080e7          	jalr	-196(ra) # 80001706 <uvmclear>
    800057d2:	7afd                	lui	s5,0xfffff
    800057d4:	9ae2                	add	s5,s5,s8
    800057d6:	df043783          	ld	a5,-528(s0)
    800057da:	6388                	ld	a0,0(a5)
    800057dc:	c925                	beqz	a0,8000584c <exec+0x222>
    800057de:	e9040993          	addi	s3,s0,-368
    800057e2:	f9040c93          	addi	s9,s0,-112
    800057e6:	8962                	mv	s2,s8
    800057e8:	4481                	li	s1,0
    800057ea:	ffffb097          	auipc	ra,0xffffb
    800057ee:	6a8080e7          	jalr	1704(ra) # 80000e92 <strlen>
    800057f2:	0015079b          	addiw	a5,a0,1
    800057f6:	40f907b3          	sub	a5,s2,a5
    800057fa:	ff07f913          	andi	s2,a5,-16
    800057fe:	13596363          	bltu	s2,s5,80005924 <exec+0x2fa>
    80005802:	df043d83          	ld	s11,-528(s0)
    80005806:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    8000580a:	8552                	mv	a0,s4
    8000580c:	ffffb097          	auipc	ra,0xffffb
    80005810:	686080e7          	jalr	1670(ra) # 80000e92 <strlen>
    80005814:	0015069b          	addiw	a3,a0,1
    80005818:	8652                	mv	a2,s4
    8000581a:	85ca                	mv	a1,s2
    8000581c:	855a                	mv	a0,s6
    8000581e:	ffffc097          	auipc	ra,0xffffc
    80005822:	f1a080e7          	jalr	-230(ra) # 80001738 <copyout>
    80005826:	10054363          	bltz	a0,8000592c <exec+0x302>
    8000582a:	0129b023          	sd	s2,0(s3)
    8000582e:	0485                	addi	s1,s1,1
    80005830:	008d8793          	addi	a5,s11,8
    80005834:	def43823          	sd	a5,-528(s0)
    80005838:	008db503          	ld	a0,8(s11)
    8000583c:	c911                	beqz	a0,80005850 <exec+0x226>
    8000583e:	09a1                	addi	s3,s3,8
    80005840:	fb3c95e3          	bne	s9,s3,800057ea <exec+0x1c0>
    80005844:	df843c23          	sd	s8,-520(s0)
    80005848:	4a81                	li	s5,0
    8000584a:	a84d                	j	800058fc <exec+0x2d2>
    8000584c:	8962                	mv	s2,s8
    8000584e:	4481                	li	s1,0
    80005850:	00349793          	slli	a5,s1,0x3
    80005854:	f9078793          	addi	a5,a5,-112
    80005858:	97a2                	add	a5,a5,s0
    8000585a:	f007b023          	sd	zero,-256(a5)
    8000585e:	00148693          	addi	a3,s1,1
    80005862:	068e                	slli	a3,a3,0x3
    80005864:	40d90933          	sub	s2,s2,a3
    80005868:	ff097913          	andi	s2,s2,-16
    8000586c:	01597663          	bgeu	s2,s5,80005878 <exec+0x24e>
    80005870:	df843c23          	sd	s8,-520(s0)
    80005874:	4a81                	li	s5,0
    80005876:	a059                	j	800058fc <exec+0x2d2>
    80005878:	e9040613          	addi	a2,s0,-368
    8000587c:	85ca                	mv	a1,s2
    8000587e:	855a                	mv	a0,s6
    80005880:	ffffc097          	auipc	ra,0xffffc
    80005884:	eb8080e7          	jalr	-328(ra) # 80001738 <copyout>
    80005888:	0a054663          	bltz	a0,80005934 <exec+0x30a>
    8000588c:	2e0bb783          	ld	a5,736(s7)
    80005890:	0727bc23          	sd	s2,120(a5)
    80005894:	de843783          	ld	a5,-536(s0)
    80005898:	0007c703          	lbu	a4,0(a5)
    8000589c:	cf11                	beqz	a4,800058b8 <exec+0x28e>
    8000589e:	0785                	addi	a5,a5,1
    800058a0:	02f00693          	li	a3,47
    800058a4:	a039                	j	800058b2 <exec+0x288>
    800058a6:	def43423          	sd	a5,-536(s0)
    800058aa:	0785                	addi	a5,a5,1
    800058ac:	fff7c703          	lbu	a4,-1(a5)
    800058b0:	c701                	beqz	a4,800058b8 <exec+0x28e>
    800058b2:	fed71ce3          	bne	a4,a3,800058aa <exec+0x280>
    800058b6:	bfc5                	j	800058a6 <exec+0x27c>
    800058b8:	4641                	li	a2,16
    800058ba:	de843583          	ld	a1,-536(s0)
    800058be:	3e0b8513          	addi	a0,s7,992
    800058c2:	ffffb097          	auipc	ra,0xffffb
    800058c6:	59e080e7          	jalr	1438(ra) # 80000e60 <safestrcpy>
    800058ca:	2d8bb503          	ld	a0,728(s7)
    800058ce:	2d6bbc23          	sd	s6,728(s7)
    800058d2:	2d8bb823          	sd	s8,720(s7)
    800058d6:	2e0bb783          	ld	a5,736(s7)
    800058da:	e6843703          	ld	a4,-408(s0)
    800058de:	ef98                	sd	a4,24(a5)
    800058e0:	2e0bb783          	ld	a5,736(s7)
    800058e4:	0327b823          	sd	s2,48(a5)
    800058e8:	85ea                	mv	a1,s10
    800058ea:	ffffc097          	auipc	ra,0xffffc
    800058ee:	366080e7          	jalr	870(ra) # 80001c50 <proc_freepagetable>
    800058f2:	0004851b          	sext.w	a0,s1
    800058f6:	bbc1                	j	800056c6 <exec+0x9c>
    800058f8:	de943c23          	sd	s1,-520(s0)
    800058fc:	df843583          	ld	a1,-520(s0)
    80005900:	855a                	mv	a0,s6
    80005902:	ffffc097          	auipc	ra,0xffffc
    80005906:	34e080e7          	jalr	846(ra) # 80001c50 <proc_freepagetable>
    8000590a:	da0a94e3          	bnez	s5,800056b2 <exec+0x88>
    8000590e:	557d                	li	a0,-1
    80005910:	bb5d                	j	800056c6 <exec+0x9c>
    80005912:	de943c23          	sd	s1,-520(s0)
    80005916:	b7dd                	j	800058fc <exec+0x2d2>
    80005918:	de943c23          	sd	s1,-520(s0)
    8000591c:	b7c5                	j	800058fc <exec+0x2d2>
    8000591e:	de943c23          	sd	s1,-520(s0)
    80005922:	bfe9                	j	800058fc <exec+0x2d2>
    80005924:	df843c23          	sd	s8,-520(s0)
    80005928:	4a81                	li	s5,0
    8000592a:	bfc9                	j	800058fc <exec+0x2d2>
    8000592c:	df843c23          	sd	s8,-520(s0)
    80005930:	4a81                	li	s5,0
    80005932:	b7e9                	j	800058fc <exec+0x2d2>
    80005934:	df843c23          	sd	s8,-520(s0)
    80005938:	4a81                	li	s5,0
    8000593a:	b7c9                	j	800058fc <exec+0x2d2>
    8000593c:	df843483          	ld	s1,-520(s0)
    80005940:	e0843783          	ld	a5,-504(s0)
    80005944:	0017869b          	addiw	a3,a5,1
    80005948:	e0d43423          	sd	a3,-504(s0)
    8000594c:	e0043783          	ld	a5,-512(s0)
    80005950:	0387879b          	addiw	a5,a5,56
    80005954:	e8845703          	lhu	a4,-376(s0)
    80005958:	e2e6d3e3          	bge	a3,a4,8000577e <exec+0x154>
    8000595c:	2781                	sext.w	a5,a5
    8000595e:	e0f43023          	sd	a5,-512(s0)
    80005962:	03800713          	li	a4,56
    80005966:	86be                	mv	a3,a5
    80005968:	e1840613          	addi	a2,s0,-488
    8000596c:	4581                	li	a1,0
    8000596e:	8556                	mv	a0,s5
    80005970:	fffff097          	auipc	ra,0xfffff
    80005974:	970080e7          	jalr	-1680(ra) # 800042e0 <readi>
    80005978:	03800793          	li	a5,56
    8000597c:	f6f51ee3          	bne	a0,a5,800058f8 <exec+0x2ce>
    80005980:	e1842783          	lw	a5,-488(s0)
    80005984:	4705                	li	a4,1
    80005986:	fae79de3          	bne	a5,a4,80005940 <exec+0x316>
    8000598a:	e4043603          	ld	a2,-448(s0)
    8000598e:	e3843783          	ld	a5,-456(s0)
    80005992:	f8f660e3          	bltu	a2,a5,80005912 <exec+0x2e8>
    80005996:	e2843783          	ld	a5,-472(s0)
    8000599a:	963e                	add	a2,a2,a5
    8000599c:	f6f66ee3          	bltu	a2,a5,80005918 <exec+0x2ee>
    800059a0:	85a6                	mv	a1,s1
    800059a2:	855a                	mv	a0,s6
    800059a4:	ffffc097          	auipc	ra,0xffffc
    800059a8:	a9e080e7          	jalr	-1378(ra) # 80001442 <uvmalloc>
    800059ac:	dea43c23          	sd	a0,-520(s0)
    800059b0:	d53d                	beqz	a0,8000591e <exec+0x2f4>
    800059b2:	e2843c03          	ld	s8,-472(s0)
    800059b6:	de043783          	ld	a5,-544(s0)
    800059ba:	00fc77b3          	and	a5,s8,a5
    800059be:	ff9d                	bnez	a5,800058fc <exec+0x2d2>
    800059c0:	e2042c83          	lw	s9,-480(s0)
    800059c4:	e3842b83          	lw	s7,-456(s0)
    800059c8:	f60b8ae3          	beqz	s7,8000593c <exec+0x312>
    800059cc:	89de                	mv	s3,s7
    800059ce:	4481                	li	s1,0
    800059d0:	b371                	j	8000575c <exec+0x132>

00000000800059d2 <argfd>:
    800059d2:	7179                	addi	sp,sp,-48
    800059d4:	f406                	sd	ra,40(sp)
    800059d6:	f022                	sd	s0,32(sp)
    800059d8:	ec26                	sd	s1,24(sp)
    800059da:	e84a                	sd	s2,16(sp)
    800059dc:	1800                	addi	s0,sp,48
    800059de:	892e                	mv	s2,a1
    800059e0:	84b2                	mv	s1,a2
    800059e2:	fdc40593          	addi	a1,s0,-36
    800059e6:	ffffd097          	auipc	ra,0xffffd
    800059ea:	7ea080e7          	jalr	2026(ra) # 800031d0 <argint>
    800059ee:	04054063          	bltz	a0,80005a2e <argfd+0x5c>
    800059f2:	fdc42703          	lw	a4,-36(s0)
    800059f6:	47bd                	li	a5,15
    800059f8:	02e7ed63          	bltu	a5,a4,80005a32 <argfd+0x60>
    800059fc:	ffffc097          	auipc	ra,0xffffc
    80005a00:	0f4080e7          	jalr	244(ra) # 80001af0 <myproc>
    80005a04:	fdc42703          	lw	a4,-36(s0)
    80005a08:	06a70793          	addi	a5,a4,106 # fffffffffffff06a <end+0xffffffff7ffc83d2>
    80005a0c:	078e                	slli	a5,a5,0x3
    80005a0e:	953e                	add	a0,a0,a5
    80005a10:	651c                	ld	a5,8(a0)
    80005a12:	c395                	beqz	a5,80005a36 <argfd+0x64>
    80005a14:	00090463          	beqz	s2,80005a1c <argfd+0x4a>
    80005a18:	00e92023          	sw	a4,0(s2)
    80005a1c:	4501                	li	a0,0
    80005a1e:	c091                	beqz	s1,80005a22 <argfd+0x50>
    80005a20:	e09c                	sd	a5,0(s1)
    80005a22:	70a2                	ld	ra,40(sp)
    80005a24:	7402                	ld	s0,32(sp)
    80005a26:	64e2                	ld	s1,24(sp)
    80005a28:	6942                	ld	s2,16(sp)
    80005a2a:	6145                	addi	sp,sp,48
    80005a2c:	8082                	ret
    80005a2e:	557d                	li	a0,-1
    80005a30:	bfcd                	j	80005a22 <argfd+0x50>
    80005a32:	557d                	li	a0,-1
    80005a34:	b7fd                	j	80005a22 <argfd+0x50>
    80005a36:	557d                	li	a0,-1
    80005a38:	b7ed                	j	80005a22 <argfd+0x50>

0000000080005a3a <fdalloc>:
    80005a3a:	1101                	addi	sp,sp,-32
    80005a3c:	ec06                	sd	ra,24(sp)
    80005a3e:	e822                	sd	s0,16(sp)
    80005a40:	e426                	sd	s1,8(sp)
    80005a42:	1000                	addi	s0,sp,32
    80005a44:	84aa                	mv	s1,a0
    80005a46:	ffffc097          	auipc	ra,0xffffc
    80005a4a:	0aa080e7          	jalr	170(ra) # 80001af0 <myproc>
    80005a4e:	862a                	mv	a2,a0
    80005a50:	35850793          	addi	a5,a0,856
    80005a54:	4501                	li	a0,0
    80005a56:	46c1                	li	a3,16
    80005a58:	6398                	ld	a4,0(a5)
    80005a5a:	cb19                	beqz	a4,80005a70 <fdalloc+0x36>
    80005a5c:	2505                	addiw	a0,a0,1
    80005a5e:	07a1                	addi	a5,a5,8
    80005a60:	fed51ce3          	bne	a0,a3,80005a58 <fdalloc+0x1e>
    80005a64:	557d                	li	a0,-1
    80005a66:	60e2                	ld	ra,24(sp)
    80005a68:	6442                	ld	s0,16(sp)
    80005a6a:	64a2                	ld	s1,8(sp)
    80005a6c:	6105                	addi	sp,sp,32
    80005a6e:	8082                	ret
    80005a70:	06a50793          	addi	a5,a0,106
    80005a74:	078e                	slli	a5,a5,0x3
    80005a76:	963e                	add	a2,a2,a5
    80005a78:	e604                	sd	s1,8(a2)
    80005a7a:	b7f5                	j	80005a66 <fdalloc+0x2c>

0000000080005a7c <create>:
    80005a7c:	715d                	addi	sp,sp,-80
    80005a7e:	e486                	sd	ra,72(sp)
    80005a80:	e0a2                	sd	s0,64(sp)
    80005a82:	fc26                	sd	s1,56(sp)
    80005a84:	f84a                	sd	s2,48(sp)
    80005a86:	f44e                	sd	s3,40(sp)
    80005a88:	f052                	sd	s4,32(sp)
    80005a8a:	ec56                	sd	s5,24(sp)
    80005a8c:	0880                	addi	s0,sp,80
    80005a8e:	89ae                	mv	s3,a1
    80005a90:	8ab2                	mv	s5,a2
    80005a92:	8a36                	mv	s4,a3
    80005a94:	fb040593          	addi	a1,s0,-80
    80005a98:	fffff097          	auipc	ra,0xfffff
    80005a9c:	d6e080e7          	jalr	-658(ra) # 80004806 <nameiparent>
    80005aa0:	892a                	mv	s2,a0
    80005aa2:	12050e63          	beqz	a0,80005bde <create+0x162>
    80005aa6:	ffffe097          	auipc	ra,0xffffe
    80005aaa:	586080e7          	jalr	1414(ra) # 8000402c <ilock>
    80005aae:	4601                	li	a2,0
    80005ab0:	fb040593          	addi	a1,s0,-80
    80005ab4:	854a                	mv	a0,s2
    80005ab6:	fffff097          	auipc	ra,0xfffff
    80005aba:	a5a080e7          	jalr	-1446(ra) # 80004510 <dirlookup>
    80005abe:	84aa                	mv	s1,a0
    80005ac0:	c921                	beqz	a0,80005b10 <create+0x94>
    80005ac2:	854a                	mv	a0,s2
    80005ac4:	ffffe097          	auipc	ra,0xffffe
    80005ac8:	7ca080e7          	jalr	1994(ra) # 8000428e <iunlockput>
    80005acc:	8526                	mv	a0,s1
    80005ace:	ffffe097          	auipc	ra,0xffffe
    80005ad2:	55e080e7          	jalr	1374(ra) # 8000402c <ilock>
    80005ad6:	2981                	sext.w	s3,s3
    80005ad8:	4789                	li	a5,2
    80005ada:	02f99463          	bne	s3,a5,80005b02 <create+0x86>
    80005ade:	0444d783          	lhu	a5,68(s1)
    80005ae2:	37f9                	addiw	a5,a5,-2
    80005ae4:	17c2                	slli	a5,a5,0x30
    80005ae6:	93c1                	srli	a5,a5,0x30
    80005ae8:	4705                	li	a4,1
    80005aea:	00f76c63          	bltu	a4,a5,80005b02 <create+0x86>
    80005aee:	8526                	mv	a0,s1
    80005af0:	60a6                	ld	ra,72(sp)
    80005af2:	6406                	ld	s0,64(sp)
    80005af4:	74e2                	ld	s1,56(sp)
    80005af6:	7942                	ld	s2,48(sp)
    80005af8:	79a2                	ld	s3,40(sp)
    80005afa:	7a02                	ld	s4,32(sp)
    80005afc:	6ae2                	ld	s5,24(sp)
    80005afe:	6161                	addi	sp,sp,80
    80005b00:	8082                	ret
    80005b02:	8526                	mv	a0,s1
    80005b04:	ffffe097          	auipc	ra,0xffffe
    80005b08:	78a080e7          	jalr	1930(ra) # 8000428e <iunlockput>
    80005b0c:	4481                	li	s1,0
    80005b0e:	b7c5                	j	80005aee <create+0x72>
    80005b10:	85ce                	mv	a1,s3
    80005b12:	00092503          	lw	a0,0(s2)
    80005b16:	ffffe097          	auipc	ra,0xffffe
    80005b1a:	37c080e7          	jalr	892(ra) # 80003e92 <ialloc>
    80005b1e:	84aa                	mv	s1,a0
    80005b20:	c521                	beqz	a0,80005b68 <create+0xec>
    80005b22:	ffffe097          	auipc	ra,0xffffe
    80005b26:	50a080e7          	jalr	1290(ra) # 8000402c <ilock>
    80005b2a:	05549323          	sh	s5,70(s1)
    80005b2e:	05449423          	sh	s4,72(s1)
    80005b32:	4a05                	li	s4,1
    80005b34:	05449523          	sh	s4,74(s1)
    80005b38:	8526                	mv	a0,s1
    80005b3a:	ffffe097          	auipc	ra,0xffffe
    80005b3e:	426080e7          	jalr	1062(ra) # 80003f60 <iupdate>
    80005b42:	2981                	sext.w	s3,s3
    80005b44:	03498a63          	beq	s3,s4,80005b78 <create+0xfc>
    80005b48:	40d0                	lw	a2,4(s1)
    80005b4a:	fb040593          	addi	a1,s0,-80
    80005b4e:	854a                	mv	a0,s2
    80005b50:	fffff097          	auipc	ra,0xfffff
    80005b54:	bd6080e7          	jalr	-1066(ra) # 80004726 <dirlink>
    80005b58:	06054b63          	bltz	a0,80005bce <create+0x152>
    80005b5c:	854a                	mv	a0,s2
    80005b5e:	ffffe097          	auipc	ra,0xffffe
    80005b62:	730080e7          	jalr	1840(ra) # 8000428e <iunlockput>
    80005b66:	b761                	j	80005aee <create+0x72>
    80005b68:	00004517          	auipc	a0,0x4
    80005b6c:	c4850513          	addi	a0,a0,-952 # 800097b0 <syscalls+0x330>
    80005b70:	ffffb097          	auipc	ra,0xffffb
    80005b74:	9cc080e7          	jalr	-1588(ra) # 8000053c <panic>
    80005b78:	04a95783          	lhu	a5,74(s2)
    80005b7c:	2785                	addiw	a5,a5,1
    80005b7e:	04f91523          	sh	a5,74(s2)
    80005b82:	854a                	mv	a0,s2
    80005b84:	ffffe097          	auipc	ra,0xffffe
    80005b88:	3dc080e7          	jalr	988(ra) # 80003f60 <iupdate>
    80005b8c:	40d0                	lw	a2,4(s1)
    80005b8e:	00004597          	auipc	a1,0x4
    80005b92:	bca58593          	addi	a1,a1,-1078 # 80009758 <syscalls+0x2d8>
    80005b96:	8526                	mv	a0,s1
    80005b98:	fffff097          	auipc	ra,0xfffff
    80005b9c:	b8e080e7          	jalr	-1138(ra) # 80004726 <dirlink>
    80005ba0:	00054f63          	bltz	a0,80005bbe <create+0x142>
    80005ba4:	00492603          	lw	a2,4(s2)
    80005ba8:	00004597          	auipc	a1,0x4
    80005bac:	b9858593          	addi	a1,a1,-1128 # 80009740 <syscalls+0x2c0>
    80005bb0:	8526                	mv	a0,s1
    80005bb2:	fffff097          	auipc	ra,0xfffff
    80005bb6:	b74080e7          	jalr	-1164(ra) # 80004726 <dirlink>
    80005bba:	f80557e3          	bgez	a0,80005b48 <create+0xcc>
    80005bbe:	00004517          	auipc	a0,0x4
    80005bc2:	c0250513          	addi	a0,a0,-1022 # 800097c0 <syscalls+0x340>
    80005bc6:	ffffb097          	auipc	ra,0xffffb
    80005bca:	976080e7          	jalr	-1674(ra) # 8000053c <panic>
    80005bce:	00004517          	auipc	a0,0x4
    80005bd2:	c0250513          	addi	a0,a0,-1022 # 800097d0 <syscalls+0x350>
    80005bd6:	ffffb097          	auipc	ra,0xffffb
    80005bda:	966080e7          	jalr	-1690(ra) # 8000053c <panic>
    80005bde:	84aa                	mv	s1,a0
    80005be0:	b739                	j	80005aee <create+0x72>

0000000080005be2 <sys_dup>:
    80005be2:	7179                	addi	sp,sp,-48
    80005be4:	f406                	sd	ra,40(sp)
    80005be6:	f022                	sd	s0,32(sp)
    80005be8:	ec26                	sd	s1,24(sp)
    80005bea:	e84a                	sd	s2,16(sp)
    80005bec:	1800                	addi	s0,sp,48
    80005bee:	fd840613          	addi	a2,s0,-40
    80005bf2:	4581                	li	a1,0
    80005bf4:	4501                	li	a0,0
    80005bf6:	00000097          	auipc	ra,0x0
    80005bfa:	ddc080e7          	jalr	-548(ra) # 800059d2 <argfd>
    80005bfe:	57fd                	li	a5,-1
    80005c00:	02054363          	bltz	a0,80005c26 <sys_dup+0x44>
    80005c04:	fd843903          	ld	s2,-40(s0)
    80005c08:	854a                	mv	a0,s2
    80005c0a:	00000097          	auipc	ra,0x0
    80005c0e:	e30080e7          	jalr	-464(ra) # 80005a3a <fdalloc>
    80005c12:	84aa                	mv	s1,a0
    80005c14:	57fd                	li	a5,-1
    80005c16:	00054863          	bltz	a0,80005c26 <sys_dup+0x44>
    80005c1a:	854a                	mv	a0,s2
    80005c1c:	fffff097          	auipc	ra,0xfffff
    80005c20:	266080e7          	jalr	614(ra) # 80004e82 <filedup>
    80005c24:	87a6                	mv	a5,s1
    80005c26:	853e                	mv	a0,a5
    80005c28:	70a2                	ld	ra,40(sp)
    80005c2a:	7402                	ld	s0,32(sp)
    80005c2c:	64e2                	ld	s1,24(sp)
    80005c2e:	6942                	ld	s2,16(sp)
    80005c30:	6145                	addi	sp,sp,48
    80005c32:	8082                	ret

0000000080005c34 <sys_read>:
    80005c34:	7179                	addi	sp,sp,-48
    80005c36:	f406                	sd	ra,40(sp)
    80005c38:	f022                	sd	s0,32(sp)
    80005c3a:	1800                	addi	s0,sp,48
    80005c3c:	fe840613          	addi	a2,s0,-24
    80005c40:	4581                	li	a1,0
    80005c42:	4501                	li	a0,0
    80005c44:	00000097          	auipc	ra,0x0
    80005c48:	d8e080e7          	jalr	-626(ra) # 800059d2 <argfd>
    80005c4c:	57fd                	li	a5,-1
    80005c4e:	04054163          	bltz	a0,80005c90 <sys_read+0x5c>
    80005c52:	fe440593          	addi	a1,s0,-28
    80005c56:	4509                	li	a0,2
    80005c58:	ffffd097          	auipc	ra,0xffffd
    80005c5c:	578080e7          	jalr	1400(ra) # 800031d0 <argint>
    80005c60:	57fd                	li	a5,-1
    80005c62:	02054763          	bltz	a0,80005c90 <sys_read+0x5c>
    80005c66:	fd840593          	addi	a1,s0,-40
    80005c6a:	4505                	li	a0,1
    80005c6c:	ffffd097          	auipc	ra,0xffffd
    80005c70:	586080e7          	jalr	1414(ra) # 800031f2 <argaddr>
    80005c74:	57fd                	li	a5,-1
    80005c76:	00054d63          	bltz	a0,80005c90 <sys_read+0x5c>
    80005c7a:	fe442603          	lw	a2,-28(s0)
    80005c7e:	fd843583          	ld	a1,-40(s0)
    80005c82:	fe843503          	ld	a0,-24(s0)
    80005c86:	fffff097          	auipc	ra,0xfffff
    80005c8a:	388080e7          	jalr	904(ra) # 8000500e <fileread>
    80005c8e:	87aa                	mv	a5,a0
    80005c90:	853e                	mv	a0,a5
    80005c92:	70a2                	ld	ra,40(sp)
    80005c94:	7402                	ld	s0,32(sp)
    80005c96:	6145                	addi	sp,sp,48
    80005c98:	8082                	ret

0000000080005c9a <sys_write>:
    80005c9a:	7179                	addi	sp,sp,-48
    80005c9c:	f406                	sd	ra,40(sp)
    80005c9e:	f022                	sd	s0,32(sp)
    80005ca0:	1800                	addi	s0,sp,48
    80005ca2:	fe840613          	addi	a2,s0,-24
    80005ca6:	4581                	li	a1,0
    80005ca8:	4501                	li	a0,0
    80005caa:	00000097          	auipc	ra,0x0
    80005cae:	d28080e7          	jalr	-728(ra) # 800059d2 <argfd>
    80005cb2:	57fd                	li	a5,-1
    80005cb4:	04054163          	bltz	a0,80005cf6 <sys_write+0x5c>
    80005cb8:	fe440593          	addi	a1,s0,-28
    80005cbc:	4509                	li	a0,2
    80005cbe:	ffffd097          	auipc	ra,0xffffd
    80005cc2:	512080e7          	jalr	1298(ra) # 800031d0 <argint>
    80005cc6:	57fd                	li	a5,-1
    80005cc8:	02054763          	bltz	a0,80005cf6 <sys_write+0x5c>
    80005ccc:	fd840593          	addi	a1,s0,-40
    80005cd0:	4505                	li	a0,1
    80005cd2:	ffffd097          	auipc	ra,0xffffd
    80005cd6:	520080e7          	jalr	1312(ra) # 800031f2 <argaddr>
    80005cda:	57fd                	li	a5,-1
    80005cdc:	00054d63          	bltz	a0,80005cf6 <sys_write+0x5c>
    80005ce0:	fe442603          	lw	a2,-28(s0)
    80005ce4:	fd843583          	ld	a1,-40(s0)
    80005ce8:	fe843503          	ld	a0,-24(s0)
    80005cec:	fffff097          	auipc	ra,0xfffff
    80005cf0:	3e4080e7          	jalr	996(ra) # 800050d0 <filewrite>
    80005cf4:	87aa                	mv	a5,a0
    80005cf6:	853e                	mv	a0,a5
    80005cf8:	70a2                	ld	ra,40(sp)
    80005cfa:	7402                	ld	s0,32(sp)
    80005cfc:	6145                	addi	sp,sp,48
    80005cfe:	8082                	ret

0000000080005d00 <sys_close>:
    80005d00:	1101                	addi	sp,sp,-32
    80005d02:	ec06                	sd	ra,24(sp)
    80005d04:	e822                	sd	s0,16(sp)
    80005d06:	1000                	addi	s0,sp,32
    80005d08:	fe040613          	addi	a2,s0,-32
    80005d0c:	fec40593          	addi	a1,s0,-20
    80005d10:	4501                	li	a0,0
    80005d12:	00000097          	auipc	ra,0x0
    80005d16:	cc0080e7          	jalr	-832(ra) # 800059d2 <argfd>
    80005d1a:	57fd                	li	a5,-1
    80005d1c:	02054563          	bltz	a0,80005d46 <sys_close+0x46>
    80005d20:	ffffc097          	auipc	ra,0xffffc
    80005d24:	dd0080e7          	jalr	-560(ra) # 80001af0 <myproc>
    80005d28:	fec42783          	lw	a5,-20(s0)
    80005d2c:	06a78793          	addi	a5,a5,106
    80005d30:	078e                	slli	a5,a5,0x3
    80005d32:	953e                	add	a0,a0,a5
    80005d34:	00053423          	sd	zero,8(a0)
    80005d38:	fe043503          	ld	a0,-32(s0)
    80005d3c:	fffff097          	auipc	ra,0xfffff
    80005d40:	198080e7          	jalr	408(ra) # 80004ed4 <fileclose>
    80005d44:	4781                	li	a5,0
    80005d46:	853e                	mv	a0,a5
    80005d48:	60e2                	ld	ra,24(sp)
    80005d4a:	6442                	ld	s0,16(sp)
    80005d4c:	6105                	addi	sp,sp,32
    80005d4e:	8082                	ret

0000000080005d50 <sys_fstat>:
    80005d50:	1101                	addi	sp,sp,-32
    80005d52:	ec06                	sd	ra,24(sp)
    80005d54:	e822                	sd	s0,16(sp)
    80005d56:	1000                	addi	s0,sp,32
    80005d58:	fe840613          	addi	a2,s0,-24
    80005d5c:	4581                	li	a1,0
    80005d5e:	4501                	li	a0,0
    80005d60:	00000097          	auipc	ra,0x0
    80005d64:	c72080e7          	jalr	-910(ra) # 800059d2 <argfd>
    80005d68:	57fd                	li	a5,-1
    80005d6a:	02054563          	bltz	a0,80005d94 <sys_fstat+0x44>
    80005d6e:	fe040593          	addi	a1,s0,-32
    80005d72:	4505                	li	a0,1
    80005d74:	ffffd097          	auipc	ra,0xffffd
    80005d78:	47e080e7          	jalr	1150(ra) # 800031f2 <argaddr>
    80005d7c:	57fd                	li	a5,-1
    80005d7e:	00054b63          	bltz	a0,80005d94 <sys_fstat+0x44>
    80005d82:	fe043583          	ld	a1,-32(s0)
    80005d86:	fe843503          	ld	a0,-24(s0)
    80005d8a:	fffff097          	auipc	ra,0xfffff
    80005d8e:	212080e7          	jalr	530(ra) # 80004f9c <filestat>
    80005d92:	87aa                	mv	a5,a0
    80005d94:	853e                	mv	a0,a5
    80005d96:	60e2                	ld	ra,24(sp)
    80005d98:	6442                	ld	s0,16(sp)
    80005d9a:	6105                	addi	sp,sp,32
    80005d9c:	8082                	ret

0000000080005d9e <sys_link>:
    80005d9e:	7169                	addi	sp,sp,-304
    80005da0:	f606                	sd	ra,296(sp)
    80005da2:	f222                	sd	s0,288(sp)
    80005da4:	ee26                	sd	s1,280(sp)
    80005da6:	ea4a                	sd	s2,272(sp)
    80005da8:	1a00                	addi	s0,sp,304
    80005daa:	08000613          	li	a2,128
    80005dae:	ed040593          	addi	a1,s0,-304
    80005db2:	4501                	li	a0,0
    80005db4:	ffffd097          	auipc	ra,0xffffd
    80005db8:	460080e7          	jalr	1120(ra) # 80003214 <argstr>
    80005dbc:	57fd                	li	a5,-1
    80005dbe:	10054e63          	bltz	a0,80005eda <sys_link+0x13c>
    80005dc2:	08000613          	li	a2,128
    80005dc6:	f5040593          	addi	a1,s0,-176
    80005dca:	4505                	li	a0,1
    80005dcc:	ffffd097          	auipc	ra,0xffffd
    80005dd0:	448080e7          	jalr	1096(ra) # 80003214 <argstr>
    80005dd4:	57fd                	li	a5,-1
    80005dd6:	10054263          	bltz	a0,80005eda <sys_link+0x13c>
    80005dda:	fffff097          	auipc	ra,0xfffff
    80005dde:	c2e080e7          	jalr	-978(ra) # 80004a08 <begin_op>
    80005de2:	ed040513          	addi	a0,s0,-304
    80005de6:	fffff097          	auipc	ra,0xfffff
    80005dea:	a02080e7          	jalr	-1534(ra) # 800047e8 <namei>
    80005dee:	84aa                	mv	s1,a0
    80005df0:	c551                	beqz	a0,80005e7c <sys_link+0xde>
    80005df2:	ffffe097          	auipc	ra,0xffffe
    80005df6:	23a080e7          	jalr	570(ra) # 8000402c <ilock>
    80005dfa:	04449703          	lh	a4,68(s1)
    80005dfe:	4785                	li	a5,1
    80005e00:	08f70463          	beq	a4,a5,80005e88 <sys_link+0xea>
    80005e04:	04a4d783          	lhu	a5,74(s1)
    80005e08:	2785                	addiw	a5,a5,1
    80005e0a:	04f49523          	sh	a5,74(s1)
    80005e0e:	8526                	mv	a0,s1
    80005e10:	ffffe097          	auipc	ra,0xffffe
    80005e14:	150080e7          	jalr	336(ra) # 80003f60 <iupdate>
    80005e18:	8526                	mv	a0,s1
    80005e1a:	ffffe097          	auipc	ra,0xffffe
    80005e1e:	2d4080e7          	jalr	724(ra) # 800040ee <iunlock>
    80005e22:	fd040593          	addi	a1,s0,-48
    80005e26:	f5040513          	addi	a0,s0,-176
    80005e2a:	fffff097          	auipc	ra,0xfffff
    80005e2e:	9dc080e7          	jalr	-1572(ra) # 80004806 <nameiparent>
    80005e32:	892a                	mv	s2,a0
    80005e34:	c935                	beqz	a0,80005ea8 <sys_link+0x10a>
    80005e36:	ffffe097          	auipc	ra,0xffffe
    80005e3a:	1f6080e7          	jalr	502(ra) # 8000402c <ilock>
    80005e3e:	00092703          	lw	a4,0(s2)
    80005e42:	409c                	lw	a5,0(s1)
    80005e44:	04f71d63          	bne	a4,a5,80005e9e <sys_link+0x100>
    80005e48:	40d0                	lw	a2,4(s1)
    80005e4a:	fd040593          	addi	a1,s0,-48
    80005e4e:	854a                	mv	a0,s2
    80005e50:	fffff097          	auipc	ra,0xfffff
    80005e54:	8d6080e7          	jalr	-1834(ra) # 80004726 <dirlink>
    80005e58:	04054363          	bltz	a0,80005e9e <sys_link+0x100>
    80005e5c:	854a                	mv	a0,s2
    80005e5e:	ffffe097          	auipc	ra,0xffffe
    80005e62:	430080e7          	jalr	1072(ra) # 8000428e <iunlockput>
    80005e66:	8526                	mv	a0,s1
    80005e68:	ffffe097          	auipc	ra,0xffffe
    80005e6c:	37e080e7          	jalr	894(ra) # 800041e6 <iput>
    80005e70:	fffff097          	auipc	ra,0xfffff
    80005e74:	c16080e7          	jalr	-1002(ra) # 80004a86 <end_op>
    80005e78:	4781                	li	a5,0
    80005e7a:	a085                	j	80005eda <sys_link+0x13c>
    80005e7c:	fffff097          	auipc	ra,0xfffff
    80005e80:	c0a080e7          	jalr	-1014(ra) # 80004a86 <end_op>
    80005e84:	57fd                	li	a5,-1
    80005e86:	a891                	j	80005eda <sys_link+0x13c>
    80005e88:	8526                	mv	a0,s1
    80005e8a:	ffffe097          	auipc	ra,0xffffe
    80005e8e:	404080e7          	jalr	1028(ra) # 8000428e <iunlockput>
    80005e92:	fffff097          	auipc	ra,0xfffff
    80005e96:	bf4080e7          	jalr	-1036(ra) # 80004a86 <end_op>
    80005e9a:	57fd                	li	a5,-1
    80005e9c:	a83d                	j	80005eda <sys_link+0x13c>
    80005e9e:	854a                	mv	a0,s2
    80005ea0:	ffffe097          	auipc	ra,0xffffe
    80005ea4:	3ee080e7          	jalr	1006(ra) # 8000428e <iunlockput>
    80005ea8:	8526                	mv	a0,s1
    80005eaa:	ffffe097          	auipc	ra,0xffffe
    80005eae:	182080e7          	jalr	386(ra) # 8000402c <ilock>
    80005eb2:	04a4d783          	lhu	a5,74(s1)
    80005eb6:	37fd                	addiw	a5,a5,-1
    80005eb8:	04f49523          	sh	a5,74(s1)
    80005ebc:	8526                	mv	a0,s1
    80005ebe:	ffffe097          	auipc	ra,0xffffe
    80005ec2:	0a2080e7          	jalr	162(ra) # 80003f60 <iupdate>
    80005ec6:	8526                	mv	a0,s1
    80005ec8:	ffffe097          	auipc	ra,0xffffe
    80005ecc:	3c6080e7          	jalr	966(ra) # 8000428e <iunlockput>
    80005ed0:	fffff097          	auipc	ra,0xfffff
    80005ed4:	bb6080e7          	jalr	-1098(ra) # 80004a86 <end_op>
    80005ed8:	57fd                	li	a5,-1
    80005eda:	853e                	mv	a0,a5
    80005edc:	70b2                	ld	ra,296(sp)
    80005ede:	7412                	ld	s0,288(sp)
    80005ee0:	64f2                	ld	s1,280(sp)
    80005ee2:	6952                	ld	s2,272(sp)
    80005ee4:	6155                	addi	sp,sp,304
    80005ee6:	8082                	ret

0000000080005ee8 <sys_unlink>:
    80005ee8:	7151                	addi	sp,sp,-240
    80005eea:	f586                	sd	ra,232(sp)
    80005eec:	f1a2                	sd	s0,224(sp)
    80005eee:	eda6                	sd	s1,216(sp)
    80005ef0:	e9ca                	sd	s2,208(sp)
    80005ef2:	e5ce                	sd	s3,200(sp)
    80005ef4:	1980                	addi	s0,sp,240
    80005ef6:	08000613          	li	a2,128
    80005efa:	f3040593          	addi	a1,s0,-208
    80005efe:	4501                	li	a0,0
    80005f00:	ffffd097          	auipc	ra,0xffffd
    80005f04:	314080e7          	jalr	788(ra) # 80003214 <argstr>
    80005f08:	18054163          	bltz	a0,8000608a <sys_unlink+0x1a2>
    80005f0c:	fffff097          	auipc	ra,0xfffff
    80005f10:	afc080e7          	jalr	-1284(ra) # 80004a08 <begin_op>
    80005f14:	fb040593          	addi	a1,s0,-80
    80005f18:	f3040513          	addi	a0,s0,-208
    80005f1c:	fffff097          	auipc	ra,0xfffff
    80005f20:	8ea080e7          	jalr	-1814(ra) # 80004806 <nameiparent>
    80005f24:	84aa                	mv	s1,a0
    80005f26:	c979                	beqz	a0,80005ffc <sys_unlink+0x114>
    80005f28:	ffffe097          	auipc	ra,0xffffe
    80005f2c:	104080e7          	jalr	260(ra) # 8000402c <ilock>
    80005f30:	00004597          	auipc	a1,0x4
    80005f34:	82858593          	addi	a1,a1,-2008 # 80009758 <syscalls+0x2d8>
    80005f38:	fb040513          	addi	a0,s0,-80
    80005f3c:	ffffe097          	auipc	ra,0xffffe
    80005f40:	5ba080e7          	jalr	1466(ra) # 800044f6 <namecmp>
    80005f44:	14050a63          	beqz	a0,80006098 <sys_unlink+0x1b0>
    80005f48:	00003597          	auipc	a1,0x3
    80005f4c:	7f858593          	addi	a1,a1,2040 # 80009740 <syscalls+0x2c0>
    80005f50:	fb040513          	addi	a0,s0,-80
    80005f54:	ffffe097          	auipc	ra,0xffffe
    80005f58:	5a2080e7          	jalr	1442(ra) # 800044f6 <namecmp>
    80005f5c:	12050e63          	beqz	a0,80006098 <sys_unlink+0x1b0>
    80005f60:	f2c40613          	addi	a2,s0,-212
    80005f64:	fb040593          	addi	a1,s0,-80
    80005f68:	8526                	mv	a0,s1
    80005f6a:	ffffe097          	auipc	ra,0xffffe
    80005f6e:	5a6080e7          	jalr	1446(ra) # 80004510 <dirlookup>
    80005f72:	892a                	mv	s2,a0
    80005f74:	12050263          	beqz	a0,80006098 <sys_unlink+0x1b0>
    80005f78:	ffffe097          	auipc	ra,0xffffe
    80005f7c:	0b4080e7          	jalr	180(ra) # 8000402c <ilock>
    80005f80:	04a91783          	lh	a5,74(s2)
    80005f84:	08f05263          	blez	a5,80006008 <sys_unlink+0x120>
    80005f88:	04491703          	lh	a4,68(s2)
    80005f8c:	4785                	li	a5,1
    80005f8e:	08f70563          	beq	a4,a5,80006018 <sys_unlink+0x130>
    80005f92:	4641                	li	a2,16
    80005f94:	4581                	li	a1,0
    80005f96:	fc040513          	addi	a0,s0,-64
    80005f9a:	ffffb097          	auipc	ra,0xffffb
    80005f9e:	d7c080e7          	jalr	-644(ra) # 80000d16 <memset>
    80005fa2:	4741                	li	a4,16
    80005fa4:	f2c42683          	lw	a3,-212(s0)
    80005fa8:	fc040613          	addi	a2,s0,-64
    80005fac:	4581                	li	a1,0
    80005fae:	8526                	mv	a0,s1
    80005fb0:	ffffe097          	auipc	ra,0xffffe
    80005fb4:	428080e7          	jalr	1064(ra) # 800043d8 <writei>
    80005fb8:	47c1                	li	a5,16
    80005fba:	0af51563          	bne	a0,a5,80006064 <sys_unlink+0x17c>
    80005fbe:	04491703          	lh	a4,68(s2)
    80005fc2:	4785                	li	a5,1
    80005fc4:	0af70863          	beq	a4,a5,80006074 <sys_unlink+0x18c>
    80005fc8:	8526                	mv	a0,s1
    80005fca:	ffffe097          	auipc	ra,0xffffe
    80005fce:	2c4080e7          	jalr	708(ra) # 8000428e <iunlockput>
    80005fd2:	04a95783          	lhu	a5,74(s2)
    80005fd6:	37fd                	addiw	a5,a5,-1
    80005fd8:	04f91523          	sh	a5,74(s2)
    80005fdc:	854a                	mv	a0,s2
    80005fde:	ffffe097          	auipc	ra,0xffffe
    80005fe2:	f82080e7          	jalr	-126(ra) # 80003f60 <iupdate>
    80005fe6:	854a                	mv	a0,s2
    80005fe8:	ffffe097          	auipc	ra,0xffffe
    80005fec:	2a6080e7          	jalr	678(ra) # 8000428e <iunlockput>
    80005ff0:	fffff097          	auipc	ra,0xfffff
    80005ff4:	a96080e7          	jalr	-1386(ra) # 80004a86 <end_op>
    80005ff8:	4501                	li	a0,0
    80005ffa:	a84d                	j	800060ac <sys_unlink+0x1c4>
    80005ffc:	fffff097          	auipc	ra,0xfffff
    80006000:	a8a080e7          	jalr	-1398(ra) # 80004a86 <end_op>
    80006004:	557d                	li	a0,-1
    80006006:	a05d                	j	800060ac <sys_unlink+0x1c4>
    80006008:	00003517          	auipc	a0,0x3
    8000600c:	7d850513          	addi	a0,a0,2008 # 800097e0 <syscalls+0x360>
    80006010:	ffffa097          	auipc	ra,0xffffa
    80006014:	52c080e7          	jalr	1324(ra) # 8000053c <panic>
    80006018:	04c92703          	lw	a4,76(s2)
    8000601c:	02000793          	li	a5,32
    80006020:	f6e7f9e3          	bgeu	a5,a4,80005f92 <sys_unlink+0xaa>
    80006024:	02000993          	li	s3,32
    80006028:	4741                	li	a4,16
    8000602a:	86ce                	mv	a3,s3
    8000602c:	f1840613          	addi	a2,s0,-232
    80006030:	4581                	li	a1,0
    80006032:	854a                	mv	a0,s2
    80006034:	ffffe097          	auipc	ra,0xffffe
    80006038:	2ac080e7          	jalr	684(ra) # 800042e0 <readi>
    8000603c:	47c1                	li	a5,16
    8000603e:	00f51b63          	bne	a0,a5,80006054 <sys_unlink+0x16c>
    80006042:	f1845783          	lhu	a5,-232(s0)
    80006046:	e7a1                	bnez	a5,8000608e <sys_unlink+0x1a6>
    80006048:	29c1                	addiw	s3,s3,16
    8000604a:	04c92783          	lw	a5,76(s2)
    8000604e:	fcf9ede3          	bltu	s3,a5,80006028 <sys_unlink+0x140>
    80006052:	b781                	j	80005f92 <sys_unlink+0xaa>
    80006054:	00003517          	auipc	a0,0x3
    80006058:	7a450513          	addi	a0,a0,1956 # 800097f8 <syscalls+0x378>
    8000605c:	ffffa097          	auipc	ra,0xffffa
    80006060:	4e0080e7          	jalr	1248(ra) # 8000053c <panic>
    80006064:	00003517          	auipc	a0,0x3
    80006068:	7ac50513          	addi	a0,a0,1964 # 80009810 <syscalls+0x390>
    8000606c:	ffffa097          	auipc	ra,0xffffa
    80006070:	4d0080e7          	jalr	1232(ra) # 8000053c <panic>
    80006074:	04a4d783          	lhu	a5,74(s1)
    80006078:	37fd                	addiw	a5,a5,-1
    8000607a:	04f49523          	sh	a5,74(s1)
    8000607e:	8526                	mv	a0,s1
    80006080:	ffffe097          	auipc	ra,0xffffe
    80006084:	ee0080e7          	jalr	-288(ra) # 80003f60 <iupdate>
    80006088:	b781                	j	80005fc8 <sys_unlink+0xe0>
    8000608a:	557d                	li	a0,-1
    8000608c:	a005                	j	800060ac <sys_unlink+0x1c4>
    8000608e:	854a                	mv	a0,s2
    80006090:	ffffe097          	auipc	ra,0xffffe
    80006094:	1fe080e7          	jalr	510(ra) # 8000428e <iunlockput>
    80006098:	8526                	mv	a0,s1
    8000609a:	ffffe097          	auipc	ra,0xffffe
    8000609e:	1f4080e7          	jalr	500(ra) # 8000428e <iunlockput>
    800060a2:	fffff097          	auipc	ra,0xfffff
    800060a6:	9e4080e7          	jalr	-1564(ra) # 80004a86 <end_op>
    800060aa:	557d                	li	a0,-1
    800060ac:	70ae                	ld	ra,232(sp)
    800060ae:	740e                	ld	s0,224(sp)
    800060b0:	64ee                	ld	s1,216(sp)
    800060b2:	694e                	ld	s2,208(sp)
    800060b4:	69ae                	ld	s3,200(sp)
    800060b6:	616d                	addi	sp,sp,240
    800060b8:	8082                	ret

00000000800060ba <sys_open>:
    800060ba:	7131                	addi	sp,sp,-192
    800060bc:	fd06                	sd	ra,184(sp)
    800060be:	f922                	sd	s0,176(sp)
    800060c0:	f526                	sd	s1,168(sp)
    800060c2:	f14a                	sd	s2,160(sp)
    800060c4:	ed4e                	sd	s3,152(sp)
    800060c6:	0180                	addi	s0,sp,192
    800060c8:	08000613          	li	a2,128
    800060cc:	f5040593          	addi	a1,s0,-176
    800060d0:	4501                	li	a0,0
    800060d2:	ffffd097          	auipc	ra,0xffffd
    800060d6:	142080e7          	jalr	322(ra) # 80003214 <argstr>
    800060da:	54fd                	li	s1,-1
    800060dc:	0c054163          	bltz	a0,8000619e <sys_open+0xe4>
    800060e0:	f4c40593          	addi	a1,s0,-180
    800060e4:	4505                	li	a0,1
    800060e6:	ffffd097          	auipc	ra,0xffffd
    800060ea:	0ea080e7          	jalr	234(ra) # 800031d0 <argint>
    800060ee:	0a054863          	bltz	a0,8000619e <sys_open+0xe4>
    800060f2:	fffff097          	auipc	ra,0xfffff
    800060f6:	916080e7          	jalr	-1770(ra) # 80004a08 <begin_op>
    800060fa:	f4c42783          	lw	a5,-180(s0)
    800060fe:	2007f793          	andi	a5,a5,512
    80006102:	cbdd                	beqz	a5,800061b8 <sys_open+0xfe>
    80006104:	4681                	li	a3,0
    80006106:	4601                	li	a2,0
    80006108:	4589                	li	a1,2
    8000610a:	f5040513          	addi	a0,s0,-176
    8000610e:	00000097          	auipc	ra,0x0
    80006112:	96e080e7          	jalr	-1682(ra) # 80005a7c <create>
    80006116:	892a                	mv	s2,a0
    80006118:	c959                	beqz	a0,800061ae <sys_open+0xf4>
    8000611a:	04491703          	lh	a4,68(s2)
    8000611e:	478d                	li	a5,3
    80006120:	00f71763          	bne	a4,a5,8000612e <sys_open+0x74>
    80006124:	04695703          	lhu	a4,70(s2)
    80006128:	47a5                	li	a5,9
    8000612a:	0ce7ec63          	bltu	a5,a4,80006202 <sys_open+0x148>
    8000612e:	fffff097          	auipc	ra,0xfffff
    80006132:	cea080e7          	jalr	-790(ra) # 80004e18 <filealloc>
    80006136:	89aa                	mv	s3,a0
    80006138:	10050263          	beqz	a0,8000623c <sys_open+0x182>
    8000613c:	00000097          	auipc	ra,0x0
    80006140:	8fe080e7          	jalr	-1794(ra) # 80005a3a <fdalloc>
    80006144:	84aa                	mv	s1,a0
    80006146:	0e054663          	bltz	a0,80006232 <sys_open+0x178>
    8000614a:	04491703          	lh	a4,68(s2)
    8000614e:	478d                	li	a5,3
    80006150:	0cf70463          	beq	a4,a5,80006218 <sys_open+0x15e>
    80006154:	4789                	li	a5,2
    80006156:	00f9a023          	sw	a5,0(s3)
    8000615a:	0209a023          	sw	zero,32(s3)
    8000615e:	0129bc23          	sd	s2,24(s3)
    80006162:	f4c42783          	lw	a5,-180(s0)
    80006166:	0017c713          	xori	a4,a5,1
    8000616a:	8b05                	andi	a4,a4,1
    8000616c:	00e98423          	sb	a4,8(s3)
    80006170:	0037f713          	andi	a4,a5,3
    80006174:	00e03733          	snez	a4,a4
    80006178:	00e984a3          	sb	a4,9(s3)
    8000617c:	4007f793          	andi	a5,a5,1024
    80006180:	c791                	beqz	a5,8000618c <sys_open+0xd2>
    80006182:	04491703          	lh	a4,68(s2)
    80006186:	4789                	li	a5,2
    80006188:	08f70f63          	beq	a4,a5,80006226 <sys_open+0x16c>
    8000618c:	854a                	mv	a0,s2
    8000618e:	ffffe097          	auipc	ra,0xffffe
    80006192:	f60080e7          	jalr	-160(ra) # 800040ee <iunlock>
    80006196:	fffff097          	auipc	ra,0xfffff
    8000619a:	8f0080e7          	jalr	-1808(ra) # 80004a86 <end_op>
    8000619e:	8526                	mv	a0,s1
    800061a0:	70ea                	ld	ra,184(sp)
    800061a2:	744a                	ld	s0,176(sp)
    800061a4:	74aa                	ld	s1,168(sp)
    800061a6:	790a                	ld	s2,160(sp)
    800061a8:	69ea                	ld	s3,152(sp)
    800061aa:	6129                	addi	sp,sp,192
    800061ac:	8082                	ret
    800061ae:	fffff097          	auipc	ra,0xfffff
    800061b2:	8d8080e7          	jalr	-1832(ra) # 80004a86 <end_op>
    800061b6:	b7e5                	j	8000619e <sys_open+0xe4>
    800061b8:	f5040513          	addi	a0,s0,-176
    800061bc:	ffffe097          	auipc	ra,0xffffe
    800061c0:	62c080e7          	jalr	1580(ra) # 800047e8 <namei>
    800061c4:	892a                	mv	s2,a0
    800061c6:	c905                	beqz	a0,800061f6 <sys_open+0x13c>
    800061c8:	ffffe097          	auipc	ra,0xffffe
    800061cc:	e64080e7          	jalr	-412(ra) # 8000402c <ilock>
    800061d0:	04491703          	lh	a4,68(s2)
    800061d4:	4785                	li	a5,1
    800061d6:	f4f712e3          	bne	a4,a5,8000611a <sys_open+0x60>
    800061da:	f4c42783          	lw	a5,-180(s0)
    800061de:	dba1                	beqz	a5,8000612e <sys_open+0x74>
    800061e0:	854a                	mv	a0,s2
    800061e2:	ffffe097          	auipc	ra,0xffffe
    800061e6:	0ac080e7          	jalr	172(ra) # 8000428e <iunlockput>
    800061ea:	fffff097          	auipc	ra,0xfffff
    800061ee:	89c080e7          	jalr	-1892(ra) # 80004a86 <end_op>
    800061f2:	54fd                	li	s1,-1
    800061f4:	b76d                	j	8000619e <sys_open+0xe4>
    800061f6:	fffff097          	auipc	ra,0xfffff
    800061fa:	890080e7          	jalr	-1904(ra) # 80004a86 <end_op>
    800061fe:	54fd                	li	s1,-1
    80006200:	bf79                	j	8000619e <sys_open+0xe4>
    80006202:	854a                	mv	a0,s2
    80006204:	ffffe097          	auipc	ra,0xffffe
    80006208:	08a080e7          	jalr	138(ra) # 8000428e <iunlockput>
    8000620c:	fffff097          	auipc	ra,0xfffff
    80006210:	87a080e7          	jalr	-1926(ra) # 80004a86 <end_op>
    80006214:	54fd                	li	s1,-1
    80006216:	b761                	j	8000619e <sys_open+0xe4>
    80006218:	00f9a023          	sw	a5,0(s3)
    8000621c:	04691783          	lh	a5,70(s2)
    80006220:	02f99223          	sh	a5,36(s3)
    80006224:	bf2d                	j	8000615e <sys_open+0xa4>
    80006226:	854a                	mv	a0,s2
    80006228:	ffffe097          	auipc	ra,0xffffe
    8000622c:	f12080e7          	jalr	-238(ra) # 8000413a <itrunc>
    80006230:	bfb1                	j	8000618c <sys_open+0xd2>
    80006232:	854e                	mv	a0,s3
    80006234:	fffff097          	auipc	ra,0xfffff
    80006238:	ca0080e7          	jalr	-864(ra) # 80004ed4 <fileclose>
    8000623c:	854a                	mv	a0,s2
    8000623e:	ffffe097          	auipc	ra,0xffffe
    80006242:	050080e7          	jalr	80(ra) # 8000428e <iunlockput>
    80006246:	fffff097          	auipc	ra,0xfffff
    8000624a:	840080e7          	jalr	-1984(ra) # 80004a86 <end_op>
    8000624e:	54fd                	li	s1,-1
    80006250:	b7b9                	j	8000619e <sys_open+0xe4>

0000000080006252 <sys_mkdir>:
    80006252:	7175                	addi	sp,sp,-144
    80006254:	e506                	sd	ra,136(sp)
    80006256:	e122                	sd	s0,128(sp)
    80006258:	0900                	addi	s0,sp,144
    8000625a:	ffffe097          	auipc	ra,0xffffe
    8000625e:	7ae080e7          	jalr	1966(ra) # 80004a08 <begin_op>
    80006262:	08000613          	li	a2,128
    80006266:	f7040593          	addi	a1,s0,-144
    8000626a:	4501                	li	a0,0
    8000626c:	ffffd097          	auipc	ra,0xffffd
    80006270:	fa8080e7          	jalr	-88(ra) # 80003214 <argstr>
    80006274:	02054963          	bltz	a0,800062a6 <sys_mkdir+0x54>
    80006278:	4681                	li	a3,0
    8000627a:	4601                	li	a2,0
    8000627c:	4585                	li	a1,1
    8000627e:	f7040513          	addi	a0,s0,-144
    80006282:	fffff097          	auipc	ra,0xfffff
    80006286:	7fa080e7          	jalr	2042(ra) # 80005a7c <create>
    8000628a:	cd11                	beqz	a0,800062a6 <sys_mkdir+0x54>
    8000628c:	ffffe097          	auipc	ra,0xffffe
    80006290:	002080e7          	jalr	2(ra) # 8000428e <iunlockput>
    80006294:	ffffe097          	auipc	ra,0xffffe
    80006298:	7f2080e7          	jalr	2034(ra) # 80004a86 <end_op>
    8000629c:	4501                	li	a0,0
    8000629e:	60aa                	ld	ra,136(sp)
    800062a0:	640a                	ld	s0,128(sp)
    800062a2:	6149                	addi	sp,sp,144
    800062a4:	8082                	ret
    800062a6:	ffffe097          	auipc	ra,0xffffe
    800062aa:	7e0080e7          	jalr	2016(ra) # 80004a86 <end_op>
    800062ae:	557d                	li	a0,-1
    800062b0:	b7fd                	j	8000629e <sys_mkdir+0x4c>

00000000800062b2 <sys_mknod>:
    800062b2:	7135                	addi	sp,sp,-160
    800062b4:	ed06                	sd	ra,152(sp)
    800062b6:	e922                	sd	s0,144(sp)
    800062b8:	1100                	addi	s0,sp,160
    800062ba:	ffffe097          	auipc	ra,0xffffe
    800062be:	74e080e7          	jalr	1870(ra) # 80004a08 <begin_op>
    800062c2:	08000613          	li	a2,128
    800062c6:	f7040593          	addi	a1,s0,-144
    800062ca:	4501                	li	a0,0
    800062cc:	ffffd097          	auipc	ra,0xffffd
    800062d0:	f48080e7          	jalr	-184(ra) # 80003214 <argstr>
    800062d4:	04054a63          	bltz	a0,80006328 <sys_mknod+0x76>
    800062d8:	f6c40593          	addi	a1,s0,-148
    800062dc:	4505                	li	a0,1
    800062de:	ffffd097          	auipc	ra,0xffffd
    800062e2:	ef2080e7          	jalr	-270(ra) # 800031d0 <argint>
    800062e6:	04054163          	bltz	a0,80006328 <sys_mknod+0x76>
    800062ea:	f6840593          	addi	a1,s0,-152
    800062ee:	4509                	li	a0,2
    800062f0:	ffffd097          	auipc	ra,0xffffd
    800062f4:	ee0080e7          	jalr	-288(ra) # 800031d0 <argint>
    800062f8:	02054863          	bltz	a0,80006328 <sys_mknod+0x76>
    800062fc:	f6841683          	lh	a3,-152(s0)
    80006300:	f6c41603          	lh	a2,-148(s0)
    80006304:	458d                	li	a1,3
    80006306:	f7040513          	addi	a0,s0,-144
    8000630a:	fffff097          	auipc	ra,0xfffff
    8000630e:	772080e7          	jalr	1906(ra) # 80005a7c <create>
    80006312:	c919                	beqz	a0,80006328 <sys_mknod+0x76>
    80006314:	ffffe097          	auipc	ra,0xffffe
    80006318:	f7a080e7          	jalr	-134(ra) # 8000428e <iunlockput>
    8000631c:	ffffe097          	auipc	ra,0xffffe
    80006320:	76a080e7          	jalr	1898(ra) # 80004a86 <end_op>
    80006324:	4501                	li	a0,0
    80006326:	a031                	j	80006332 <sys_mknod+0x80>
    80006328:	ffffe097          	auipc	ra,0xffffe
    8000632c:	75e080e7          	jalr	1886(ra) # 80004a86 <end_op>
    80006330:	557d                	li	a0,-1
    80006332:	60ea                	ld	ra,152(sp)
    80006334:	644a                	ld	s0,144(sp)
    80006336:	610d                	addi	sp,sp,160
    80006338:	8082                	ret

000000008000633a <sys_chdir>:
    8000633a:	7135                	addi	sp,sp,-160
    8000633c:	ed06                	sd	ra,152(sp)
    8000633e:	e922                	sd	s0,144(sp)
    80006340:	e526                	sd	s1,136(sp)
    80006342:	e14a                	sd	s2,128(sp)
    80006344:	1100                	addi	s0,sp,160
    80006346:	ffffb097          	auipc	ra,0xffffb
    8000634a:	7aa080e7          	jalr	1962(ra) # 80001af0 <myproc>
    8000634e:	892a                	mv	s2,a0
    80006350:	ffffe097          	auipc	ra,0xffffe
    80006354:	6b8080e7          	jalr	1720(ra) # 80004a08 <begin_op>
    80006358:	08000613          	li	a2,128
    8000635c:	f6040593          	addi	a1,s0,-160
    80006360:	4501                	li	a0,0
    80006362:	ffffd097          	auipc	ra,0xffffd
    80006366:	eb2080e7          	jalr	-334(ra) # 80003214 <argstr>
    8000636a:	04054b63          	bltz	a0,800063c0 <sys_chdir+0x86>
    8000636e:	f6040513          	addi	a0,s0,-160
    80006372:	ffffe097          	auipc	ra,0xffffe
    80006376:	476080e7          	jalr	1142(ra) # 800047e8 <namei>
    8000637a:	84aa                	mv	s1,a0
    8000637c:	c131                	beqz	a0,800063c0 <sys_chdir+0x86>
    8000637e:	ffffe097          	auipc	ra,0xffffe
    80006382:	cae080e7          	jalr	-850(ra) # 8000402c <ilock>
    80006386:	04449703          	lh	a4,68(s1)
    8000638a:	4785                	li	a5,1
    8000638c:	04f71063          	bne	a4,a5,800063cc <sys_chdir+0x92>
    80006390:	8526                	mv	a0,s1
    80006392:	ffffe097          	auipc	ra,0xffffe
    80006396:	d5c080e7          	jalr	-676(ra) # 800040ee <iunlock>
    8000639a:	3d893503          	ld	a0,984(s2)
    8000639e:	ffffe097          	auipc	ra,0xffffe
    800063a2:	e48080e7          	jalr	-440(ra) # 800041e6 <iput>
    800063a6:	ffffe097          	auipc	ra,0xffffe
    800063aa:	6e0080e7          	jalr	1760(ra) # 80004a86 <end_op>
    800063ae:	3c993c23          	sd	s1,984(s2)
    800063b2:	4501                	li	a0,0
    800063b4:	60ea                	ld	ra,152(sp)
    800063b6:	644a                	ld	s0,144(sp)
    800063b8:	64aa                	ld	s1,136(sp)
    800063ba:	690a                	ld	s2,128(sp)
    800063bc:	610d                	addi	sp,sp,160
    800063be:	8082                	ret
    800063c0:	ffffe097          	auipc	ra,0xffffe
    800063c4:	6c6080e7          	jalr	1734(ra) # 80004a86 <end_op>
    800063c8:	557d                	li	a0,-1
    800063ca:	b7ed                	j	800063b4 <sys_chdir+0x7a>
    800063cc:	8526                	mv	a0,s1
    800063ce:	ffffe097          	auipc	ra,0xffffe
    800063d2:	ec0080e7          	jalr	-320(ra) # 8000428e <iunlockput>
    800063d6:	ffffe097          	auipc	ra,0xffffe
    800063da:	6b0080e7          	jalr	1712(ra) # 80004a86 <end_op>
    800063de:	557d                	li	a0,-1
    800063e0:	bfd1                	j	800063b4 <sys_chdir+0x7a>

00000000800063e2 <sys_exec>:
    800063e2:	7145                	addi	sp,sp,-464
    800063e4:	e786                	sd	ra,456(sp)
    800063e6:	e3a2                	sd	s0,448(sp)
    800063e8:	ff26                	sd	s1,440(sp)
    800063ea:	fb4a                	sd	s2,432(sp)
    800063ec:	f74e                	sd	s3,424(sp)
    800063ee:	f352                	sd	s4,416(sp)
    800063f0:	ef56                	sd	s5,408(sp)
    800063f2:	0b80                	addi	s0,sp,464
    800063f4:	08000613          	li	a2,128
    800063f8:	f4040593          	addi	a1,s0,-192
    800063fc:	4501                	li	a0,0
    800063fe:	ffffd097          	auipc	ra,0xffffd
    80006402:	e16080e7          	jalr	-490(ra) # 80003214 <argstr>
    80006406:	597d                	li	s2,-1
    80006408:	0c054b63          	bltz	a0,800064de <sys_exec+0xfc>
    8000640c:	e3840593          	addi	a1,s0,-456
    80006410:	4505                	li	a0,1
    80006412:	ffffd097          	auipc	ra,0xffffd
    80006416:	de0080e7          	jalr	-544(ra) # 800031f2 <argaddr>
    8000641a:	0c054263          	bltz	a0,800064de <sys_exec+0xfc>
    8000641e:	10000613          	li	a2,256
    80006422:	4581                	li	a1,0
    80006424:	e4040513          	addi	a0,s0,-448
    80006428:	ffffb097          	auipc	ra,0xffffb
    8000642c:	8ee080e7          	jalr	-1810(ra) # 80000d16 <memset>
    80006430:	e4040493          	addi	s1,s0,-448
    80006434:	89a6                	mv	s3,s1
    80006436:	4901                	li	s2,0
    80006438:	02000a13          	li	s4,32
    8000643c:	00090a9b          	sext.w	s5,s2
    80006440:	00391513          	slli	a0,s2,0x3
    80006444:	e3040593          	addi	a1,s0,-464
    80006448:	e3843783          	ld	a5,-456(s0)
    8000644c:	953e                	add	a0,a0,a5
    8000644e:	ffffd097          	auipc	ra,0xffffd
    80006452:	ce2080e7          	jalr	-798(ra) # 80003130 <fetchaddr>
    80006456:	02054a63          	bltz	a0,8000648a <sys_exec+0xa8>
    8000645a:	e3043783          	ld	a5,-464(s0)
    8000645e:	c3b9                	beqz	a5,800064a4 <sys_exec+0xc2>
    80006460:	ffffa097          	auipc	ra,0xffffa
    80006464:	682080e7          	jalr	1666(ra) # 80000ae2 <kalloc>
    80006468:	85aa                	mv	a1,a0
    8000646a:	00a9b023          	sd	a0,0(s3)
    8000646e:	cd11                	beqz	a0,8000648a <sys_exec+0xa8>
    80006470:	6605                	lui	a2,0x1
    80006472:	e3043503          	ld	a0,-464(s0)
    80006476:	ffffd097          	auipc	ra,0xffffd
    8000647a:	d10080e7          	jalr	-752(ra) # 80003186 <fetchstr>
    8000647e:	00054663          	bltz	a0,8000648a <sys_exec+0xa8>
    80006482:	0905                	addi	s2,s2,1
    80006484:	09a1                	addi	s3,s3,8
    80006486:	fb491be3          	bne	s2,s4,8000643c <sys_exec+0x5a>
    8000648a:	f4040913          	addi	s2,s0,-192
    8000648e:	6088                	ld	a0,0(s1)
    80006490:	c531                	beqz	a0,800064dc <sys_exec+0xfa>
    80006492:	ffffa097          	auipc	ra,0xffffa
    80006496:	552080e7          	jalr	1362(ra) # 800009e4 <kfree>
    8000649a:	04a1                	addi	s1,s1,8
    8000649c:	ff2499e3          	bne	s1,s2,8000648e <sys_exec+0xac>
    800064a0:	597d                	li	s2,-1
    800064a2:	a835                	j	800064de <sys_exec+0xfc>
    800064a4:	0a8e                	slli	s5,s5,0x3
    800064a6:	fc0a8793          	addi	a5,s5,-64 # ffffffffffffefc0 <end+0xffffffff7ffc8328>
    800064aa:	00878ab3          	add	s5,a5,s0
    800064ae:	e80ab023          	sd	zero,-384(s5)
    800064b2:	e4040593          	addi	a1,s0,-448
    800064b6:	f4040513          	addi	a0,s0,-192
    800064ba:	fffff097          	auipc	ra,0xfffff
    800064be:	170080e7          	jalr	368(ra) # 8000562a <exec>
    800064c2:	892a                	mv	s2,a0
    800064c4:	f4040993          	addi	s3,s0,-192
    800064c8:	6088                	ld	a0,0(s1)
    800064ca:	c911                	beqz	a0,800064de <sys_exec+0xfc>
    800064cc:	ffffa097          	auipc	ra,0xffffa
    800064d0:	518080e7          	jalr	1304(ra) # 800009e4 <kfree>
    800064d4:	04a1                	addi	s1,s1,8
    800064d6:	ff3499e3          	bne	s1,s3,800064c8 <sys_exec+0xe6>
    800064da:	a011                	j	800064de <sys_exec+0xfc>
    800064dc:	597d                	li	s2,-1
    800064de:	854a                	mv	a0,s2
    800064e0:	60be                	ld	ra,456(sp)
    800064e2:	641e                	ld	s0,448(sp)
    800064e4:	74fa                	ld	s1,440(sp)
    800064e6:	795a                	ld	s2,432(sp)
    800064e8:	79ba                	ld	s3,424(sp)
    800064ea:	7a1a                	ld	s4,416(sp)
    800064ec:	6afa                	ld	s5,408(sp)
    800064ee:	6179                	addi	sp,sp,464
    800064f0:	8082                	ret

00000000800064f2 <sys_pipe>:
    800064f2:	7139                	addi	sp,sp,-64
    800064f4:	fc06                	sd	ra,56(sp)
    800064f6:	f822                	sd	s0,48(sp)
    800064f8:	f426                	sd	s1,40(sp)
    800064fa:	0080                	addi	s0,sp,64
    800064fc:	ffffb097          	auipc	ra,0xffffb
    80006500:	5f4080e7          	jalr	1524(ra) # 80001af0 <myproc>
    80006504:	84aa                	mv	s1,a0
    80006506:	fd840593          	addi	a1,s0,-40
    8000650a:	4501                	li	a0,0
    8000650c:	ffffd097          	auipc	ra,0xffffd
    80006510:	ce6080e7          	jalr	-794(ra) # 800031f2 <argaddr>
    80006514:	57fd                	li	a5,-1
    80006516:	0e054563          	bltz	a0,80006600 <sys_pipe+0x10e>
    8000651a:	fc840593          	addi	a1,s0,-56
    8000651e:	fd040513          	addi	a0,s0,-48
    80006522:	fffff097          	auipc	ra,0xfffff
    80006526:	ce2080e7          	jalr	-798(ra) # 80005204 <pipealloc>
    8000652a:	57fd                	li	a5,-1
    8000652c:	0c054a63          	bltz	a0,80006600 <sys_pipe+0x10e>
    80006530:	fcf42223          	sw	a5,-60(s0)
    80006534:	fd043503          	ld	a0,-48(s0)
    80006538:	fffff097          	auipc	ra,0xfffff
    8000653c:	502080e7          	jalr	1282(ra) # 80005a3a <fdalloc>
    80006540:	fca42223          	sw	a0,-60(s0)
    80006544:	0a054163          	bltz	a0,800065e6 <sys_pipe+0xf4>
    80006548:	fc843503          	ld	a0,-56(s0)
    8000654c:	fffff097          	auipc	ra,0xfffff
    80006550:	4ee080e7          	jalr	1262(ra) # 80005a3a <fdalloc>
    80006554:	fca42023          	sw	a0,-64(s0)
    80006558:	06054d63          	bltz	a0,800065d2 <sys_pipe+0xe0>
    8000655c:	4691                	li	a3,4
    8000655e:	fc440613          	addi	a2,s0,-60
    80006562:	fd843583          	ld	a1,-40(s0)
    80006566:	2d84b503          	ld	a0,728(s1)
    8000656a:	ffffb097          	auipc	ra,0xffffb
    8000656e:	1ce080e7          	jalr	462(ra) # 80001738 <copyout>
    80006572:	02054163          	bltz	a0,80006594 <sys_pipe+0xa2>
    80006576:	4691                	li	a3,4
    80006578:	fc040613          	addi	a2,s0,-64
    8000657c:	fd843583          	ld	a1,-40(s0)
    80006580:	0591                	addi	a1,a1,4
    80006582:	2d84b503          	ld	a0,728(s1)
    80006586:	ffffb097          	auipc	ra,0xffffb
    8000658a:	1b2080e7          	jalr	434(ra) # 80001738 <copyout>
    8000658e:	4781                	li	a5,0
    80006590:	06055863          	bgez	a0,80006600 <sys_pipe+0x10e>
    80006594:	fc442783          	lw	a5,-60(s0)
    80006598:	06a78793          	addi	a5,a5,106
    8000659c:	078e                	slli	a5,a5,0x3
    8000659e:	97a6                	add	a5,a5,s1
    800065a0:	0007b423          	sd	zero,8(a5)
    800065a4:	fc042783          	lw	a5,-64(s0)
    800065a8:	06a78793          	addi	a5,a5,106
    800065ac:	078e                	slli	a5,a5,0x3
    800065ae:	00f48533          	add	a0,s1,a5
    800065b2:	00053423          	sd	zero,8(a0)
    800065b6:	fd043503          	ld	a0,-48(s0)
    800065ba:	fffff097          	auipc	ra,0xfffff
    800065be:	91a080e7          	jalr	-1766(ra) # 80004ed4 <fileclose>
    800065c2:	fc843503          	ld	a0,-56(s0)
    800065c6:	fffff097          	auipc	ra,0xfffff
    800065ca:	90e080e7          	jalr	-1778(ra) # 80004ed4 <fileclose>
    800065ce:	57fd                	li	a5,-1
    800065d0:	a805                	j	80006600 <sys_pipe+0x10e>
    800065d2:	fc442783          	lw	a5,-60(s0)
    800065d6:	0007c863          	bltz	a5,800065e6 <sys_pipe+0xf4>
    800065da:	06a78793          	addi	a5,a5,106
    800065de:	078e                	slli	a5,a5,0x3
    800065e0:	97a6                	add	a5,a5,s1
    800065e2:	0007b423          	sd	zero,8(a5)
    800065e6:	fd043503          	ld	a0,-48(s0)
    800065ea:	fffff097          	auipc	ra,0xfffff
    800065ee:	8ea080e7          	jalr	-1814(ra) # 80004ed4 <fileclose>
    800065f2:	fc843503          	ld	a0,-56(s0)
    800065f6:	fffff097          	auipc	ra,0xfffff
    800065fa:	8de080e7          	jalr	-1826(ra) # 80004ed4 <fileclose>
    800065fe:	57fd                	li	a5,-1
    80006600:	853e                	mv	a0,a5
    80006602:	70e2                	ld	ra,56(sp)
    80006604:	7442                	ld	s0,48(sp)
    80006606:	74a2                	ld	s1,40(sp)
    80006608:	6121                	addi	sp,sp,64
    8000660a:	8082                	ret

000000008000660c <sys_mmap>:
    8000660c:	7139                	addi	sp,sp,-64
    8000660e:	fc06                	sd	ra,56(sp)
    80006610:	f822                	sd	s0,48(sp)
    80006612:	f426                	sd	s1,40(sp)
    80006614:	f04a                	sd	s2,32(sp)
    80006616:	ec4e                	sd	s3,24(sp)
    80006618:	0080                	addi	s0,sp,64
    8000661a:	ffffb097          	auipc	ra,0xffffb
    8000661e:	4d6080e7          	jalr	1238(ra) # 80001af0 <myproc>
    80006622:	89aa                	mv	s3,a0
    80006624:	fc840593          	addi	a1,s0,-56
    80006628:	4505                	li	a0,1
    8000662a:	ffffd097          	auipc	ra,0xffffd
    8000662e:	bc8080e7          	jalr	-1080(ra) # 800031f2 <argaddr>
    80006632:	597d                	li	s2,-1
    80006634:	0a054263          	bltz	a0,800066d8 <sys_mmap+0xcc>
    80006638:	fc440593          	addi	a1,s0,-60
    8000663c:	4509                	li	a0,2
    8000663e:	ffffd097          	auipc	ra,0xffffd
    80006642:	b92080e7          	jalr	-1134(ra) # 800031d0 <argint>
    80006646:	08054963          	bltz	a0,800066d8 <sys_mmap+0xcc>
    8000664a:	fc040593          	addi	a1,s0,-64
    8000664e:	450d                	li	a0,3
    80006650:	ffffd097          	auipc	ra,0xffffd
    80006654:	b80080e7          	jalr	-1152(ra) # 800031d0 <argint>
    80006658:	0a054663          	bltz	a0,80006704 <sys_mmap+0xf8>
    8000665c:	02c98793          	addi	a5,s3,44
    80006660:	4481                	li	s1,0
    80006662:	46a9                	li	a3,10
    80006664:	4398                	lw	a4,0(a5)
    80006666:	cb01                	beqz	a4,80006676 <sys_mmap+0x6a>
    80006668:	2485                	addiw	s1,s1,1
    8000666a:	04078793          	addi	a5,a5,64
    8000666e:	fed49be3          	bne	s1,a3,80006664 <sys_mmap+0x58>
    80006672:	597d                	li	s2,-1
    80006674:	a095                	j	800066d8 <sys_mmap+0xcc>
    80006676:	2989b603          	ld	a2,664(s3)
    8000667a:	fc843903          	ld	s2,-56(s0)
    8000667e:	41260933          	sub	s2,a2,s2
    80006682:	77fd                	lui	a5,0xfffff
    80006684:	00f97933          	and	s2,s2,a5
    80006688:	00649713          	slli	a4,s1,0x6
    8000668c:	00e987b3          	add	a5,s3,a4
    80006690:	4685                	li	a3,1
    80006692:	d7d4                	sw	a3,44(a5)
    80006694:	0127bc23          	sd	s2,24(a5) # fffffffffffff018 <end+0xffffffff7ffc8380>
    80006698:	4126063b          	subw	a2,a2,s2
    8000669c:	d390                	sw	a2,32(a5)
    8000669e:	fc442683          	lw	a3,-60(s0)
    800066a2:	d3d4                	sw	a3,36(a5)
    800066a4:	fc042683          	lw	a3,-64(s0)
    800066a8:	d794                	sw	a3,40(a5)
    800066aa:	0537b023          	sd	s3,64(a5)
    800066ae:	03870713          	addi	a4,a4,56
    800066b2:	974e                	add	a4,a4,s3
    800066b4:	e7b8                	sd	a4,72(a5)
    800066b6:	ebb8                	sd	a4,80(a5)
    800066b8:	2601                	sext.w	a2,a2
    800066ba:	85ca                	mv	a1,s2
    800066bc:	2d89b503          	ld	a0,728(s3)
    800066c0:	ffffb097          	auipc	ra,0xffffb
    800066c4:	242080e7          	jalr	578(ra) # 80001902 <mapvpages>
    800066c8:	02054063          	bltz	a0,800066e8 <sys_mmap+0xdc>
    800066cc:	fc042783          	lw	a5,-64(s0)
    800066d0:	8b85                	andi	a5,a5,1
    800066d2:	e38d                	bnez	a5,800066f4 <sys_mmap+0xe8>
    800066d4:	2929bc23          	sd	s2,664(s3)
    800066d8:	854a                	mv	a0,s2
    800066da:	70e2                	ld	ra,56(sp)
    800066dc:	7442                	ld	s0,48(sp)
    800066de:	74a2                	ld	s1,40(sp)
    800066e0:	7902                	ld	s2,32(sp)
    800066e2:	69e2                	ld	s3,24(sp)
    800066e4:	6121                	addi	sp,sp,64
    800066e6:	8082                	ret
    800066e8:	049a                	slli	s1,s1,0x6
    800066ea:	94ce                	add	s1,s1,s3
    800066ec:	0204a623          	sw	zero,44(s1)
    800066f0:	597d                	li	s2,-1
    800066f2:	b7dd                	j	800066d8 <sys_mmap+0xcc>
    800066f4:	ffffc097          	auipc	ra,0xffffc
    800066f8:	460080e7          	jalr	1120(ra) # 80002b54 <alloc_mmr_listid>
    800066fc:	049a                	slli	s1,s1,0x6
    800066fe:	94ce                	add	s1,s1,s3
    80006700:	dc88                	sw	a0,56(s1)
    80006702:	bfc9                	j	800066d4 <sys_mmap+0xc8>
    80006704:	597d                	li	s2,-1
    80006706:	bfc9                	j	800066d8 <sys_mmap+0xcc>

0000000080006708 <munmap>:
    80006708:	715d                	addi	sp,sp,-80
    8000670a:	e486                	sd	ra,72(sp)
    8000670c:	e0a2                	sd	s0,64(sp)
    8000670e:	fc26                	sd	s1,56(sp)
    80006710:	f84a                	sd	s2,48(sp)
    80006712:	f44e                	sd	s3,40(sp)
    80006714:	f052                	sd	s4,32(sp)
    80006716:	ec56                	sd	s5,24(sp)
    80006718:	e85a                	sd	s6,16(sp)
    8000671a:	e45e                	sd	s7,8(sp)
    8000671c:	e062                	sd	s8,0(sp)
    8000671e:	0880                	addi	s0,sp,80
    80006720:	892a                	mv	s2,a0
    80006722:	89ae                	mv	s3,a1
    80006724:	ffffb097          	auipc	ra,0xffffb
    80006728:	3cc080e7          	jalr	972(ra) # 80001af0 <myproc>
    8000672c:	8a2a                	mv	s4,a0
    8000672e:	01850793          	addi	a5,a0,24
    80006732:	4481                	li	s1,0
    80006734:	4685                	li	a3,1
    80006736:	6705                	lui	a4,0x1
    80006738:	177d                	addi	a4,a4,-1 # fff <_entry-0x7ffff001>
    8000673a:	00e985b3          	add	a1,s3,a4
    8000673e:	777d                	lui	a4,0xfffff
    80006740:	8df9                	and	a1,a1,a4
    80006742:	4629                	li	a2,10
    80006744:	a031                	j	80006750 <munmap+0x48>
    80006746:	2485                	addiw	s1,s1,1
    80006748:	04078793          	addi	a5,a5,64
    8000674c:	04c48363          	beq	s1,a2,80006792 <munmap+0x8a>
    80006750:	0147a983          	lw	s3,20(a5)
    80006754:	fed999e3          	bne	s3,a3,80006746 <munmap+0x3e>
    80006758:	6388                	ld	a0,0(a5)
    8000675a:	ff2516e3          	bne	a0,s2,80006746 <munmap+0x3e>
    8000675e:	4798                	lw	a4,8(a5)
    80006760:	fee593e3          	bne	a1,a4,80006746 <munmap+0x3e>
    80006764:	00649793          	slli	a5,s1,0x6
    80006768:	97d2                	add	a5,a5,s4
    8000676a:	0207a623          	sw	zero,44(a5)
    8000676e:	0287aa83          	lw	s5,40(a5)
    80006772:	002afa93          	andi	s5,s5,2
    80006776:	020a8063          	beqz	s5,80006796 <munmap+0x8e>
    8000677a:	00649793          	slli	a5,s1,0x6
    8000677e:	97d2                	add	a5,a5,s4
    80006780:	5398                	lw	a4,32(a5)
    80006782:	6f9c                	ld	a5,24(a5)
    80006784:	97ba                	add	a5,a5,a4
    80006786:	0af97c63          	bgeu	s2,a5,8000683e <munmap+0x136>
    8000678a:	6a85                	lui	s5,0x1
    8000678c:	049a                	slli	s1,s1,0x6
    8000678e:	94d2                	add	s1,s1,s4
    80006790:	a885                	j	80006800 <munmap+0xf8>
    80006792:	557d                	li	a0,-1
    80006794:	a849                	j	80006826 <munmap+0x11e>
    80006796:	00649b13          	slli	s6,s1,0x6
    8000679a:	016a0bb3          	add	s7,s4,s6
    8000679e:	038ba503          	lw	a0,56(s7)
    800067a2:	ffffc097          	auipc	ra,0xffffc
    800067a6:	c48080e7          	jalr	-952(ra) # 800023ea <get_mmr_list>
    800067aa:	8c2a                	mv	s8,a0
    800067ac:	ffffa097          	auipc	ra,0xffffa
    800067b0:	46e080e7          	jalr	1134(ra) # 80000c1a <acquire>
    800067b4:	048bb783          	ld	a5,72(s7)
    800067b8:	038b0b13          	addi	s6,s6,56
    800067bc:	9b52                	add	s6,s6,s4
    800067be:	01678f63          	beq	a5,s6,800067dc <munmap+0xd4>
    800067c2:	050bb703          	ld	a4,80(s7)
    800067c6:	ef98                	sd	a4,24(a5)
    800067c8:	048bb783          	ld	a5,72(s7)
    800067cc:	eb1c                	sd	a5,16(a4)
    800067ce:	8562                	mv	a0,s8
    800067d0:	ffffa097          	auipc	ra,0xffffa
    800067d4:	4fe080e7          	jalr	1278(ra) # 80000cce <release>
    800067d8:	89d6                	mv	s3,s5
    800067da:	b745                	j	8000677a <munmap+0x72>
    800067dc:	8562                	mv	a0,s8
    800067de:	ffffa097          	auipc	ra,0xffffa
    800067e2:	4f0080e7          	jalr	1264(ra) # 80000cce <release>
    800067e6:	038ba503          	lw	a0,56(s7)
    800067ea:	ffffc097          	auipc	ra,0xffffc
    800067ee:	c76080e7          	jalr	-906(ra) # 80002460 <dealloc_mmr_listid>
    800067f2:	b761                	j	8000677a <munmap+0x72>
    800067f4:	9956                	add	s2,s2,s5
    800067f6:	509c                	lw	a5,32(s1)
    800067f8:	6c98                	ld	a4,24(s1)
    800067fa:	97ba                	add	a5,a5,a4
    800067fc:	02f97463          	bgeu	s2,a5,80006824 <munmap+0x11c>
    80006800:	85ca                	mv	a1,s2
    80006802:	2d8a3503          	ld	a0,728(s4)
    80006806:	ffffb097          	auipc	ra,0xffffb
    8000680a:	896080e7          	jalr	-1898(ra) # 8000109c <walkaddr>
    8000680e:	d17d                	beqz	a0,800067f4 <munmap+0xec>
    80006810:	86ce                	mv	a3,s3
    80006812:	4605                	li	a2,1
    80006814:	85ca                	mv	a1,s2
    80006816:	2d8a3503          	ld	a0,728(s4)
    8000681a:	ffffb097          	auipc	ra,0xffffb
    8000681e:	a8a080e7          	jalr	-1398(ra) # 800012a4 <uvmunmap>
    80006822:	bfc9                	j	800067f4 <munmap+0xec>
    80006824:	4501                	li	a0,0
    80006826:	60a6                	ld	ra,72(sp)
    80006828:	6406                	ld	s0,64(sp)
    8000682a:	74e2                	ld	s1,56(sp)
    8000682c:	7942                	ld	s2,48(sp)
    8000682e:	79a2                	ld	s3,40(sp)
    80006830:	7a02                	ld	s4,32(sp)
    80006832:	6ae2                	ld	s5,24(sp)
    80006834:	6b42                	ld	s6,16(sp)
    80006836:	6ba2                	ld	s7,8(sp)
    80006838:	6c02                	ld	s8,0(sp)
    8000683a:	6161                	addi	sp,sp,80
    8000683c:	8082                	ret
    8000683e:	4501                	li	a0,0
    80006840:	b7dd                	j	80006826 <munmap+0x11e>

0000000080006842 <sys_munmap>:
    80006842:	1101                	addi	sp,sp,-32
    80006844:	ec06                	sd	ra,24(sp)
    80006846:	e822                	sd	s0,16(sp)
    80006848:	1000                	addi	s0,sp,32
    8000684a:	fe840593          	addi	a1,s0,-24
    8000684e:	4501                	li	a0,0
    80006850:	ffffd097          	auipc	ra,0xffffd
    80006854:	9a2080e7          	jalr	-1630(ra) # 800031f2 <argaddr>
    80006858:	87aa                	mv	a5,a0
    8000685a:	557d                	li	a0,-1
    8000685c:	0007ca63          	bltz	a5,80006870 <sys_munmap+0x2e>
    80006860:	fe040593          	addi	a1,s0,-32
    80006864:	4505                	li	a0,1
    80006866:	ffffd097          	auipc	ra,0xffffd
    8000686a:	98c080e7          	jalr	-1652(ra) # 800031f2 <argaddr>
    8000686e:	957d                	srai	a0,a0,0x3f
    80006870:	60e2                	ld	ra,24(sp)
    80006872:	6442                	ld	s0,16(sp)
    80006874:	6105                	addi	sp,sp,32
    80006876:	8082                	ret
	...

0000000080006880 <kernelvec>:
    80006880:	7111                	addi	sp,sp,-256
    80006882:	e006                	sd	ra,0(sp)
    80006884:	e40a                	sd	sp,8(sp)
    80006886:	e80e                	sd	gp,16(sp)
    80006888:	ec12                	sd	tp,24(sp)
    8000688a:	f016                	sd	t0,32(sp)
    8000688c:	f41a                	sd	t1,40(sp)
    8000688e:	f81e                	sd	t2,48(sp)
    80006890:	fc22                	sd	s0,56(sp)
    80006892:	e0a6                	sd	s1,64(sp)
    80006894:	e4aa                	sd	a0,72(sp)
    80006896:	e8ae                	sd	a1,80(sp)
    80006898:	ecb2                	sd	a2,88(sp)
    8000689a:	f0b6                	sd	a3,96(sp)
    8000689c:	f4ba                	sd	a4,104(sp)
    8000689e:	f8be                	sd	a5,112(sp)
    800068a0:	fcc2                	sd	a6,120(sp)
    800068a2:	e146                	sd	a7,128(sp)
    800068a4:	e54a                	sd	s2,136(sp)
    800068a6:	e94e                	sd	s3,144(sp)
    800068a8:	ed52                	sd	s4,152(sp)
    800068aa:	f156                	sd	s5,160(sp)
    800068ac:	f55a                	sd	s6,168(sp)
    800068ae:	f95e                	sd	s7,176(sp)
    800068b0:	fd62                	sd	s8,184(sp)
    800068b2:	e1e6                	sd	s9,192(sp)
    800068b4:	e5ea                	sd	s10,200(sp)
    800068b6:	e9ee                	sd	s11,208(sp)
    800068b8:	edf2                	sd	t3,216(sp)
    800068ba:	f1f6                	sd	t4,224(sp)
    800068bc:	f5fa                	sd	t5,232(sp)
    800068be:	f9fe                	sd	t6,240(sp)
    800068c0:	f2efc0ef          	jal	ra,80002fee <kerneltrap>
    800068c4:	6082                	ld	ra,0(sp)
    800068c6:	6122                	ld	sp,8(sp)
    800068c8:	61c2                	ld	gp,16(sp)
    800068ca:	7282                	ld	t0,32(sp)
    800068cc:	7322                	ld	t1,40(sp)
    800068ce:	73c2                	ld	t2,48(sp)
    800068d0:	7462                	ld	s0,56(sp)
    800068d2:	6486                	ld	s1,64(sp)
    800068d4:	6526                	ld	a0,72(sp)
    800068d6:	65c6                	ld	a1,80(sp)
    800068d8:	6666                	ld	a2,88(sp)
    800068da:	7686                	ld	a3,96(sp)
    800068dc:	7726                	ld	a4,104(sp)
    800068de:	77c6                	ld	a5,112(sp)
    800068e0:	7866                	ld	a6,120(sp)
    800068e2:	688a                	ld	a7,128(sp)
    800068e4:	692a                	ld	s2,136(sp)
    800068e6:	69ca                	ld	s3,144(sp)
    800068e8:	6a6a                	ld	s4,152(sp)
    800068ea:	7a8a                	ld	s5,160(sp)
    800068ec:	7b2a                	ld	s6,168(sp)
    800068ee:	7bca                	ld	s7,176(sp)
    800068f0:	7c6a                	ld	s8,184(sp)
    800068f2:	6c8e                	ld	s9,192(sp)
    800068f4:	6d2e                	ld	s10,200(sp)
    800068f6:	6dce                	ld	s11,208(sp)
    800068f8:	6e6e                	ld	t3,216(sp)
    800068fa:	7e8e                	ld	t4,224(sp)
    800068fc:	7f2e                	ld	t5,232(sp)
    800068fe:	7fce                	ld	t6,240(sp)
    80006900:	6111                	addi	sp,sp,256
    80006902:	10200073          	sret
    80006906:	00000013          	nop
    8000690a:	00000013          	nop
    8000690e:	0001                	nop

0000000080006910 <timervec>:
    80006910:	34051573          	csrrw	a0,mscratch,a0
    80006914:	e10c                	sd	a1,0(a0)
    80006916:	e510                	sd	a2,8(a0)
    80006918:	e914                	sd	a3,16(a0)
    8000691a:	6d0c                	ld	a1,24(a0)
    8000691c:	7110                	ld	a2,32(a0)
    8000691e:	6194                	ld	a3,0(a1)
    80006920:	96b2                	add	a3,a3,a2
    80006922:	e194                	sd	a3,0(a1)
    80006924:	4589                	li	a1,2
    80006926:	14459073          	csrw	sip,a1
    8000692a:	6914                	ld	a3,16(a0)
    8000692c:	6510                	ld	a2,8(a0)
    8000692e:	610c                	ld	a1,0(a0)
    80006930:	34051573          	csrrw	a0,mscratch,a0
    80006934:	30200073          	mret
	...

000000008000693a <plicinit>:
    8000693a:	1141                	addi	sp,sp,-16
    8000693c:	e422                	sd	s0,8(sp)
    8000693e:	0800                	addi	s0,sp,16
    80006940:	0c0007b7          	lui	a5,0xc000
    80006944:	4705                	li	a4,1
    80006946:	d798                	sw	a4,40(a5)
    80006948:	c3d8                	sw	a4,4(a5)
    8000694a:	6422                	ld	s0,8(sp)
    8000694c:	0141                	addi	sp,sp,16
    8000694e:	8082                	ret

0000000080006950 <plicinithart>:
    80006950:	1141                	addi	sp,sp,-16
    80006952:	e406                	sd	ra,8(sp)
    80006954:	e022                	sd	s0,0(sp)
    80006956:	0800                	addi	s0,sp,16
    80006958:	ffffb097          	auipc	ra,0xffffb
    8000695c:	16c080e7          	jalr	364(ra) # 80001ac4 <cpuid>
    80006960:	0085171b          	slliw	a4,a0,0x8
    80006964:	0c0027b7          	lui	a5,0xc002
    80006968:	97ba                	add	a5,a5,a4
    8000696a:	40200713          	li	a4,1026
    8000696e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>
    80006972:	00d5151b          	slliw	a0,a0,0xd
    80006976:	0c2017b7          	lui	a5,0xc201
    8000697a:	97aa                	add	a5,a5,a0
    8000697c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
    80006980:	60a2                	ld	ra,8(sp)
    80006982:	6402                	ld	s0,0(sp)
    80006984:	0141                	addi	sp,sp,16
    80006986:	8082                	ret

0000000080006988 <plic_claim>:
    80006988:	1141                	addi	sp,sp,-16
    8000698a:	e406                	sd	ra,8(sp)
    8000698c:	e022                	sd	s0,0(sp)
    8000698e:	0800                	addi	s0,sp,16
    80006990:	ffffb097          	auipc	ra,0xffffb
    80006994:	134080e7          	jalr	308(ra) # 80001ac4 <cpuid>
    80006998:	00d5151b          	slliw	a0,a0,0xd
    8000699c:	0c2017b7          	lui	a5,0xc201
    800069a0:	97aa                	add	a5,a5,a0
    800069a2:	43c8                	lw	a0,4(a5)
    800069a4:	60a2                	ld	ra,8(sp)
    800069a6:	6402                	ld	s0,0(sp)
    800069a8:	0141                	addi	sp,sp,16
    800069aa:	8082                	ret

00000000800069ac <plic_complete>:
    800069ac:	1101                	addi	sp,sp,-32
    800069ae:	ec06                	sd	ra,24(sp)
    800069b0:	e822                	sd	s0,16(sp)
    800069b2:	e426                	sd	s1,8(sp)
    800069b4:	1000                	addi	s0,sp,32
    800069b6:	84aa                	mv	s1,a0
    800069b8:	ffffb097          	auipc	ra,0xffffb
    800069bc:	10c080e7          	jalr	268(ra) # 80001ac4 <cpuid>
    800069c0:	00d5151b          	slliw	a0,a0,0xd
    800069c4:	0c2017b7          	lui	a5,0xc201
    800069c8:	97aa                	add	a5,a5,a0
    800069ca:	c3c4                	sw	s1,4(a5)
    800069cc:	60e2                	ld	ra,24(sp)
    800069ce:	6442                	ld	s0,16(sp)
    800069d0:	64a2                	ld	s1,8(sp)
    800069d2:	6105                	addi	sp,sp,32
    800069d4:	8082                	ret

00000000800069d6 <free_desc>:
    800069d6:	1141                	addi	sp,sp,-16
    800069d8:	e406                	sd	ra,8(sp)
    800069da:	e022                	sd	s0,0(sp)
    800069dc:	0800                	addi	s0,sp,16
    800069de:	479d                	li	a5,7
    800069e0:	06a7c863          	blt	a5,a0,80006a50 <free_desc+0x7a>
    800069e4:	0002c717          	auipc	a4,0x2c
    800069e8:	61c70713          	addi	a4,a4,1564 # 80033000 <disk>
    800069ec:	972a                	add	a4,a4,a0
    800069ee:	6789                	lui	a5,0x2
    800069f0:	97ba                	add	a5,a5,a4
    800069f2:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    800069f6:	e7ad                	bnez	a5,80006a60 <free_desc+0x8a>
    800069f8:	00451793          	slli	a5,a0,0x4
    800069fc:	0002e717          	auipc	a4,0x2e
    80006a00:	60470713          	addi	a4,a4,1540 # 80035000 <disk+0x2000>
    80006a04:	6314                	ld	a3,0(a4)
    80006a06:	96be                	add	a3,a3,a5
    80006a08:	0006b023          	sd	zero,0(a3)
    80006a0c:	6314                	ld	a3,0(a4)
    80006a0e:	96be                	add	a3,a3,a5
    80006a10:	0006a423          	sw	zero,8(a3)
    80006a14:	6314                	ld	a3,0(a4)
    80006a16:	96be                	add	a3,a3,a5
    80006a18:	00069623          	sh	zero,12(a3)
    80006a1c:	6318                	ld	a4,0(a4)
    80006a1e:	97ba                	add	a5,a5,a4
    80006a20:	00079723          	sh	zero,14(a5)
    80006a24:	0002c717          	auipc	a4,0x2c
    80006a28:	5dc70713          	addi	a4,a4,1500 # 80033000 <disk>
    80006a2c:	972a                	add	a4,a4,a0
    80006a2e:	6789                	lui	a5,0x2
    80006a30:	97ba                	add	a5,a5,a4
    80006a32:	4705                	li	a4,1
    80006a34:	00e78c23          	sb	a4,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006a38:	0002e517          	auipc	a0,0x2e
    80006a3c:	5e050513          	addi	a0,a0,1504 # 80035018 <disk+0x2018>
    80006a40:	ffffb097          	auipc	ra,0xffffb
    80006a44:	4fe080e7          	jalr	1278(ra) # 80001f3e <wakeup>
    80006a48:	60a2                	ld	ra,8(sp)
    80006a4a:	6402                	ld	s0,0(sp)
    80006a4c:	0141                	addi	sp,sp,16
    80006a4e:	8082                	ret
    80006a50:	00003517          	auipc	a0,0x3
    80006a54:	dd050513          	addi	a0,a0,-560 # 80009820 <syscalls+0x3a0>
    80006a58:	ffffa097          	auipc	ra,0xffffa
    80006a5c:	ae4080e7          	jalr	-1308(ra) # 8000053c <panic>
    80006a60:	00003517          	auipc	a0,0x3
    80006a64:	dd050513          	addi	a0,a0,-560 # 80009830 <syscalls+0x3b0>
    80006a68:	ffffa097          	auipc	ra,0xffffa
    80006a6c:	ad4080e7          	jalr	-1324(ra) # 8000053c <panic>

0000000080006a70 <virtio_disk_init>:
    80006a70:	1101                	addi	sp,sp,-32
    80006a72:	ec06                	sd	ra,24(sp)
    80006a74:	e822                	sd	s0,16(sp)
    80006a76:	e426                	sd	s1,8(sp)
    80006a78:	1000                	addi	s0,sp,32
    80006a7a:	00003597          	auipc	a1,0x3
    80006a7e:	dc658593          	addi	a1,a1,-570 # 80009840 <syscalls+0x3c0>
    80006a82:	0002e517          	auipc	a0,0x2e
    80006a86:	6a650513          	addi	a0,a0,1702 # 80035128 <disk+0x2128>
    80006a8a:	ffffa097          	auipc	ra,0xffffa
    80006a8e:	100080e7          	jalr	256(ra) # 80000b8a <initlock>
    80006a92:	100017b7          	lui	a5,0x10001
    80006a96:	4398                	lw	a4,0(a5)
    80006a98:	2701                	sext.w	a4,a4
    80006a9a:	747277b7          	lui	a5,0x74727
    80006a9e:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006aa2:	0ef71063          	bne	a4,a5,80006b82 <virtio_disk_init+0x112>
    80006aa6:	100017b7          	lui	a5,0x10001
    80006aaa:	43dc                	lw	a5,4(a5)
    80006aac:	2781                	sext.w	a5,a5
    80006aae:	4705                	li	a4,1
    80006ab0:	0ce79963          	bne	a5,a4,80006b82 <virtio_disk_init+0x112>
    80006ab4:	100017b7          	lui	a5,0x10001
    80006ab8:	479c                	lw	a5,8(a5)
    80006aba:	2781                	sext.w	a5,a5
    80006abc:	4709                	li	a4,2
    80006abe:	0ce79263          	bne	a5,a4,80006b82 <virtio_disk_init+0x112>
    80006ac2:	100017b7          	lui	a5,0x10001
    80006ac6:	47d8                	lw	a4,12(a5)
    80006ac8:	2701                	sext.w	a4,a4
    80006aca:	554d47b7          	lui	a5,0x554d4
    80006ace:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006ad2:	0af71863          	bne	a4,a5,80006b82 <virtio_disk_init+0x112>
    80006ad6:	100017b7          	lui	a5,0x10001
    80006ada:	4705                	li	a4,1
    80006adc:	dbb8                	sw	a4,112(a5)
    80006ade:	470d                	li	a4,3
    80006ae0:	dbb8                	sw	a4,112(a5)
    80006ae2:	4b98                	lw	a4,16(a5)
    80006ae4:	c7ffe6b7          	lui	a3,0xc7ffe
    80006ae8:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fc7ac7>
    80006aec:	8f75                	and	a4,a4,a3
    80006aee:	d398                	sw	a4,32(a5)
    80006af0:	472d                	li	a4,11
    80006af2:	dbb8                	sw	a4,112(a5)
    80006af4:	473d                	li	a4,15
    80006af6:	dbb8                	sw	a4,112(a5)
    80006af8:	6705                	lui	a4,0x1
    80006afa:	d798                	sw	a4,40(a5)
    80006afc:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
    80006b00:	5bdc                	lw	a5,52(a5)
    80006b02:	2781                	sext.w	a5,a5
    80006b04:	c7d9                	beqz	a5,80006b92 <virtio_disk_init+0x122>
    80006b06:	471d                	li	a4,7
    80006b08:	08f77d63          	bgeu	a4,a5,80006ba2 <virtio_disk_init+0x132>
    80006b0c:	100014b7          	lui	s1,0x10001
    80006b10:	47a1                	li	a5,8
    80006b12:	dc9c                	sw	a5,56(s1)
    80006b14:	6609                	lui	a2,0x2
    80006b16:	4581                	li	a1,0
    80006b18:	0002c517          	auipc	a0,0x2c
    80006b1c:	4e850513          	addi	a0,a0,1256 # 80033000 <disk>
    80006b20:	ffffa097          	auipc	ra,0xffffa
    80006b24:	1f6080e7          	jalr	502(ra) # 80000d16 <memset>
    80006b28:	0002c717          	auipc	a4,0x2c
    80006b2c:	4d870713          	addi	a4,a4,1240 # 80033000 <disk>
    80006b30:	00c75793          	srli	a5,a4,0xc
    80006b34:	2781                	sext.w	a5,a5
    80006b36:	c0bc                	sw	a5,64(s1)
    80006b38:	0002e797          	auipc	a5,0x2e
    80006b3c:	4c878793          	addi	a5,a5,1224 # 80035000 <disk+0x2000>
    80006b40:	e398                	sd	a4,0(a5)
    80006b42:	0002c717          	auipc	a4,0x2c
    80006b46:	53e70713          	addi	a4,a4,1342 # 80033080 <disk+0x80>
    80006b4a:	e798                	sd	a4,8(a5)
    80006b4c:	0002d717          	auipc	a4,0x2d
    80006b50:	4b470713          	addi	a4,a4,1204 # 80034000 <disk+0x1000>
    80006b54:	eb98                	sd	a4,16(a5)
    80006b56:	4705                	li	a4,1
    80006b58:	00e78c23          	sb	a4,24(a5)
    80006b5c:	00e78ca3          	sb	a4,25(a5)
    80006b60:	00e78d23          	sb	a4,26(a5)
    80006b64:	00e78da3          	sb	a4,27(a5)
    80006b68:	00e78e23          	sb	a4,28(a5)
    80006b6c:	00e78ea3          	sb	a4,29(a5)
    80006b70:	00e78f23          	sb	a4,30(a5)
    80006b74:	00e78fa3          	sb	a4,31(a5)
    80006b78:	60e2                	ld	ra,24(sp)
    80006b7a:	6442                	ld	s0,16(sp)
    80006b7c:	64a2                	ld	s1,8(sp)
    80006b7e:	6105                	addi	sp,sp,32
    80006b80:	8082                	ret
    80006b82:	00003517          	auipc	a0,0x3
    80006b86:	cce50513          	addi	a0,a0,-818 # 80009850 <syscalls+0x3d0>
    80006b8a:	ffffa097          	auipc	ra,0xffffa
    80006b8e:	9b2080e7          	jalr	-1614(ra) # 8000053c <panic>
    80006b92:	00003517          	auipc	a0,0x3
    80006b96:	cde50513          	addi	a0,a0,-802 # 80009870 <syscalls+0x3f0>
    80006b9a:	ffffa097          	auipc	ra,0xffffa
    80006b9e:	9a2080e7          	jalr	-1630(ra) # 8000053c <panic>
    80006ba2:	00003517          	auipc	a0,0x3
    80006ba6:	cee50513          	addi	a0,a0,-786 # 80009890 <syscalls+0x410>
    80006baa:	ffffa097          	auipc	ra,0xffffa
    80006bae:	992080e7          	jalr	-1646(ra) # 8000053c <panic>

0000000080006bb2 <virtio_disk_rw>:
    80006bb2:	7119                	addi	sp,sp,-128
    80006bb4:	fc86                	sd	ra,120(sp)
    80006bb6:	f8a2                	sd	s0,112(sp)
    80006bb8:	f4a6                	sd	s1,104(sp)
    80006bba:	f0ca                	sd	s2,96(sp)
    80006bbc:	ecce                	sd	s3,88(sp)
    80006bbe:	e8d2                	sd	s4,80(sp)
    80006bc0:	e4d6                	sd	s5,72(sp)
    80006bc2:	e0da                	sd	s6,64(sp)
    80006bc4:	fc5e                	sd	s7,56(sp)
    80006bc6:	f862                	sd	s8,48(sp)
    80006bc8:	f466                	sd	s9,40(sp)
    80006bca:	f06a                	sd	s10,32(sp)
    80006bcc:	ec6e                	sd	s11,24(sp)
    80006bce:	0100                	addi	s0,sp,128
    80006bd0:	8aaa                	mv	s5,a0
    80006bd2:	8d2e                	mv	s10,a1
    80006bd4:	00c52c83          	lw	s9,12(a0)
    80006bd8:	001c9c9b          	slliw	s9,s9,0x1
    80006bdc:	1c82                	slli	s9,s9,0x20
    80006bde:	020cdc93          	srli	s9,s9,0x20
    80006be2:	0002e517          	auipc	a0,0x2e
    80006be6:	54650513          	addi	a0,a0,1350 # 80035128 <disk+0x2128>
    80006bea:	ffffa097          	auipc	ra,0xffffa
    80006bee:	030080e7          	jalr	48(ra) # 80000c1a <acquire>
    80006bf2:	4981                	li	s3,0
    80006bf4:	44a1                	li	s1,8
    80006bf6:	0002cc17          	auipc	s8,0x2c
    80006bfa:	40ac0c13          	addi	s8,s8,1034 # 80033000 <disk>
    80006bfe:	6b89                	lui	s7,0x2
    80006c00:	4b0d                	li	s6,3
    80006c02:	a0ad                	j	80006c6c <virtio_disk_rw+0xba>
    80006c04:	00fc0733          	add	a4,s8,a5
    80006c08:	975e                	add	a4,a4,s7
    80006c0a:	00070c23          	sb	zero,24(a4)
    80006c0e:	c19c                	sw	a5,0(a1)
    80006c10:	0207c563          	bltz	a5,80006c3a <virtio_disk_rw+0x88>
    80006c14:	2905                	addiw	s2,s2,1
    80006c16:	0611                	addi	a2,a2,4 # 2004 <_entry-0x7fffdffc>
    80006c18:	19690c63          	beq	s2,s6,80006db0 <virtio_disk_rw+0x1fe>
    80006c1c:	85b2                	mv	a1,a2
    80006c1e:	0002e717          	auipc	a4,0x2e
    80006c22:	3fa70713          	addi	a4,a4,1018 # 80035018 <disk+0x2018>
    80006c26:	87ce                	mv	a5,s3
    80006c28:	00074683          	lbu	a3,0(a4)
    80006c2c:	fee1                	bnez	a3,80006c04 <virtio_disk_rw+0x52>
    80006c2e:	2785                	addiw	a5,a5,1
    80006c30:	0705                	addi	a4,a4,1
    80006c32:	fe979be3          	bne	a5,s1,80006c28 <virtio_disk_rw+0x76>
    80006c36:	57fd                	li	a5,-1
    80006c38:	c19c                	sw	a5,0(a1)
    80006c3a:	01205d63          	blez	s2,80006c54 <virtio_disk_rw+0xa2>
    80006c3e:	8dce                	mv	s11,s3
    80006c40:	000a2503          	lw	a0,0(s4)
    80006c44:	00000097          	auipc	ra,0x0
    80006c48:	d92080e7          	jalr	-622(ra) # 800069d6 <free_desc>
    80006c4c:	2d85                	addiw	s11,s11,1
    80006c4e:	0a11                	addi	s4,s4,4
    80006c50:	ff2d98e3          	bne	s11,s2,80006c40 <virtio_disk_rw+0x8e>
    80006c54:	0002e597          	auipc	a1,0x2e
    80006c58:	4d458593          	addi	a1,a1,1236 # 80035128 <disk+0x2128>
    80006c5c:	0002e517          	auipc	a0,0x2e
    80006c60:	3bc50513          	addi	a0,a0,956 # 80035018 <disk+0x2018>
    80006c64:	ffffb097          	auipc	ra,0xffffb
    80006c68:	274080e7          	jalr	628(ra) # 80001ed8 <sleep>
    80006c6c:	f8040a13          	addi	s4,s0,-128
    80006c70:	8652                	mv	a2,s4
    80006c72:	894e                	mv	s2,s3
    80006c74:	b765                	j	80006c1c <virtio_disk_rw+0x6a>
    80006c76:	0002e697          	auipc	a3,0x2e
    80006c7a:	38a6b683          	ld	a3,906(a3) # 80035000 <disk+0x2000>
    80006c7e:	96ba                	add	a3,a3,a4
    80006c80:	00069623          	sh	zero,12(a3)
    80006c84:	0002c817          	auipc	a6,0x2c
    80006c88:	37c80813          	addi	a6,a6,892 # 80033000 <disk>
    80006c8c:	0002e697          	auipc	a3,0x2e
    80006c90:	37468693          	addi	a3,a3,884 # 80035000 <disk+0x2000>
    80006c94:	6290                	ld	a2,0(a3)
    80006c96:	963a                	add	a2,a2,a4
    80006c98:	00c65583          	lhu	a1,12(a2)
    80006c9c:	0015e593          	ori	a1,a1,1
    80006ca0:	00b61623          	sh	a1,12(a2)
    80006ca4:	f8842603          	lw	a2,-120(s0)
    80006ca8:	628c                	ld	a1,0(a3)
    80006caa:	972e                	add	a4,a4,a1
    80006cac:	00c71723          	sh	a2,14(a4)
    80006cb0:	20050593          	addi	a1,a0,512
    80006cb4:	0592                	slli	a1,a1,0x4
    80006cb6:	95c2                	add	a1,a1,a6
    80006cb8:	577d                	li	a4,-1
    80006cba:	02e58823          	sb	a4,48(a1)
    80006cbe:	00461713          	slli	a4,a2,0x4
    80006cc2:	6290                	ld	a2,0(a3)
    80006cc4:	963a                	add	a2,a2,a4
    80006cc6:	03078793          	addi	a5,a5,48
    80006cca:	97c2                	add	a5,a5,a6
    80006ccc:	e21c                	sd	a5,0(a2)
    80006cce:	629c                	ld	a5,0(a3)
    80006cd0:	97ba                	add	a5,a5,a4
    80006cd2:	4605                	li	a2,1
    80006cd4:	c790                	sw	a2,8(a5)
    80006cd6:	629c                	ld	a5,0(a3)
    80006cd8:	97ba                	add	a5,a5,a4
    80006cda:	4809                	li	a6,2
    80006cdc:	01079623          	sh	a6,12(a5)
    80006ce0:	629c                	ld	a5,0(a3)
    80006ce2:	97ba                	add	a5,a5,a4
    80006ce4:	00079723          	sh	zero,14(a5)
    80006ce8:	00caa223          	sw	a2,4(s5) # 1004 <_entry-0x7fffeffc>
    80006cec:	0355b423          	sd	s5,40(a1)
    80006cf0:	6698                	ld	a4,8(a3)
    80006cf2:	00275783          	lhu	a5,2(a4)
    80006cf6:	8b9d                	andi	a5,a5,7
    80006cf8:	0786                	slli	a5,a5,0x1
    80006cfa:	973e                	add	a4,a4,a5
    80006cfc:	00a71223          	sh	a0,4(a4)
    80006d00:	0ff0000f          	fence
    80006d04:	6698                	ld	a4,8(a3)
    80006d06:	00275783          	lhu	a5,2(a4)
    80006d0a:	2785                	addiw	a5,a5,1
    80006d0c:	00f71123          	sh	a5,2(a4)
    80006d10:	0ff0000f          	fence
    80006d14:	100017b7          	lui	a5,0x10001
    80006d18:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>
    80006d1c:	004aa783          	lw	a5,4(s5)
    80006d20:	02c79163          	bne	a5,a2,80006d42 <virtio_disk_rw+0x190>
    80006d24:	0002e917          	auipc	s2,0x2e
    80006d28:	40490913          	addi	s2,s2,1028 # 80035128 <disk+0x2128>
    80006d2c:	4485                	li	s1,1
    80006d2e:	85ca                	mv	a1,s2
    80006d30:	8556                	mv	a0,s5
    80006d32:	ffffb097          	auipc	ra,0xffffb
    80006d36:	1a6080e7          	jalr	422(ra) # 80001ed8 <sleep>
    80006d3a:	004aa783          	lw	a5,4(s5)
    80006d3e:	fe9788e3          	beq	a5,s1,80006d2e <virtio_disk_rw+0x17c>
    80006d42:	f8042903          	lw	s2,-128(s0)
    80006d46:	20090713          	addi	a4,s2,512
    80006d4a:	0712                	slli	a4,a4,0x4
    80006d4c:	0002c797          	auipc	a5,0x2c
    80006d50:	2b478793          	addi	a5,a5,692 # 80033000 <disk>
    80006d54:	97ba                	add	a5,a5,a4
    80006d56:	0207b423          	sd	zero,40(a5)
    80006d5a:	0002e997          	auipc	s3,0x2e
    80006d5e:	2a698993          	addi	s3,s3,678 # 80035000 <disk+0x2000>
    80006d62:	00491713          	slli	a4,s2,0x4
    80006d66:	0009b783          	ld	a5,0(s3)
    80006d6a:	97ba                	add	a5,a5,a4
    80006d6c:	00c7d483          	lhu	s1,12(a5)
    80006d70:	854a                	mv	a0,s2
    80006d72:	00e7d903          	lhu	s2,14(a5)
    80006d76:	00000097          	auipc	ra,0x0
    80006d7a:	c60080e7          	jalr	-928(ra) # 800069d6 <free_desc>
    80006d7e:	8885                	andi	s1,s1,1
    80006d80:	f0ed                	bnez	s1,80006d62 <virtio_disk_rw+0x1b0>
    80006d82:	0002e517          	auipc	a0,0x2e
    80006d86:	3a650513          	addi	a0,a0,934 # 80035128 <disk+0x2128>
    80006d8a:	ffffa097          	auipc	ra,0xffffa
    80006d8e:	f44080e7          	jalr	-188(ra) # 80000cce <release>
    80006d92:	70e6                	ld	ra,120(sp)
    80006d94:	7446                	ld	s0,112(sp)
    80006d96:	74a6                	ld	s1,104(sp)
    80006d98:	7906                	ld	s2,96(sp)
    80006d9a:	69e6                	ld	s3,88(sp)
    80006d9c:	6a46                	ld	s4,80(sp)
    80006d9e:	6aa6                	ld	s5,72(sp)
    80006da0:	6b06                	ld	s6,64(sp)
    80006da2:	7be2                	ld	s7,56(sp)
    80006da4:	7c42                	ld	s8,48(sp)
    80006da6:	7ca2                	ld	s9,40(sp)
    80006da8:	7d02                	ld	s10,32(sp)
    80006daa:	6de2                	ld	s11,24(sp)
    80006dac:	6109                	addi	sp,sp,128
    80006dae:	8082                	ret
    80006db0:	f8042503          	lw	a0,-128(s0)
    80006db4:	20050793          	addi	a5,a0,512
    80006db8:	0792                	slli	a5,a5,0x4
    80006dba:	0002c817          	auipc	a6,0x2c
    80006dbe:	24680813          	addi	a6,a6,582 # 80033000 <disk>
    80006dc2:	00f80733          	add	a4,a6,a5
    80006dc6:	01a036b3          	snez	a3,s10
    80006dca:	0ad72423          	sw	a3,168(a4)
    80006dce:	0a072623          	sw	zero,172(a4)
    80006dd2:	0b973823          	sd	s9,176(a4)
    80006dd6:	7679                	lui	a2,0xffffe
    80006dd8:	963e                	add	a2,a2,a5
    80006dda:	0002e697          	auipc	a3,0x2e
    80006dde:	22668693          	addi	a3,a3,550 # 80035000 <disk+0x2000>
    80006de2:	6298                	ld	a4,0(a3)
    80006de4:	9732                	add	a4,a4,a2
    80006de6:	0a878593          	addi	a1,a5,168
    80006dea:	95c2                	add	a1,a1,a6
    80006dec:	e30c                	sd	a1,0(a4)
    80006dee:	6298                	ld	a4,0(a3)
    80006df0:	9732                	add	a4,a4,a2
    80006df2:	45c1                	li	a1,16
    80006df4:	c70c                	sw	a1,8(a4)
    80006df6:	6298                	ld	a4,0(a3)
    80006df8:	9732                	add	a4,a4,a2
    80006dfa:	4585                	li	a1,1
    80006dfc:	00b71623          	sh	a1,12(a4)
    80006e00:	f8442703          	lw	a4,-124(s0)
    80006e04:	628c                	ld	a1,0(a3)
    80006e06:	962e                	add	a2,a2,a1
    80006e08:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffc7376>
    80006e0c:	0712                	slli	a4,a4,0x4
    80006e0e:	6290                	ld	a2,0(a3)
    80006e10:	963a                	add	a2,a2,a4
    80006e12:	058a8593          	addi	a1,s5,88
    80006e16:	e20c                	sd	a1,0(a2)
    80006e18:	6294                	ld	a3,0(a3)
    80006e1a:	96ba                	add	a3,a3,a4
    80006e1c:	40000613          	li	a2,1024
    80006e20:	c690                	sw	a2,8(a3)
    80006e22:	e40d1ae3          	bnez	s10,80006c76 <virtio_disk_rw+0xc4>
    80006e26:	0002e697          	auipc	a3,0x2e
    80006e2a:	1da6b683          	ld	a3,474(a3) # 80035000 <disk+0x2000>
    80006e2e:	96ba                	add	a3,a3,a4
    80006e30:	4609                	li	a2,2
    80006e32:	00c69623          	sh	a2,12(a3)
    80006e36:	b5b9                	j	80006c84 <virtio_disk_rw+0xd2>

0000000080006e38 <virtio_disk_intr>:
    80006e38:	1101                	addi	sp,sp,-32
    80006e3a:	ec06                	sd	ra,24(sp)
    80006e3c:	e822                	sd	s0,16(sp)
    80006e3e:	e426                	sd	s1,8(sp)
    80006e40:	e04a                	sd	s2,0(sp)
    80006e42:	1000                	addi	s0,sp,32
    80006e44:	0002e517          	auipc	a0,0x2e
    80006e48:	2e450513          	addi	a0,a0,740 # 80035128 <disk+0x2128>
    80006e4c:	ffffa097          	auipc	ra,0xffffa
    80006e50:	dce080e7          	jalr	-562(ra) # 80000c1a <acquire>
    80006e54:	10001737          	lui	a4,0x10001
    80006e58:	533c                	lw	a5,96(a4)
    80006e5a:	8b8d                	andi	a5,a5,3
    80006e5c:	d37c                	sw	a5,100(a4)
    80006e5e:	0ff0000f          	fence
    80006e62:	0002e797          	auipc	a5,0x2e
    80006e66:	19e78793          	addi	a5,a5,414 # 80035000 <disk+0x2000>
    80006e6a:	6b94                	ld	a3,16(a5)
    80006e6c:	0207d703          	lhu	a4,32(a5)
    80006e70:	0026d783          	lhu	a5,2(a3)
    80006e74:	06f70163          	beq	a4,a5,80006ed6 <virtio_disk_intr+0x9e>
    80006e78:	0002c917          	auipc	s2,0x2c
    80006e7c:	18890913          	addi	s2,s2,392 # 80033000 <disk>
    80006e80:	0002e497          	auipc	s1,0x2e
    80006e84:	18048493          	addi	s1,s1,384 # 80035000 <disk+0x2000>
    80006e88:	0ff0000f          	fence
    80006e8c:	6898                	ld	a4,16(s1)
    80006e8e:	0204d783          	lhu	a5,32(s1)
    80006e92:	8b9d                	andi	a5,a5,7
    80006e94:	078e                	slli	a5,a5,0x3
    80006e96:	97ba                	add	a5,a5,a4
    80006e98:	43dc                	lw	a5,4(a5)
    80006e9a:	20078713          	addi	a4,a5,512
    80006e9e:	0712                	slli	a4,a4,0x4
    80006ea0:	974a                	add	a4,a4,s2
    80006ea2:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    80006ea6:	e731                	bnez	a4,80006ef2 <virtio_disk_intr+0xba>
    80006ea8:	20078793          	addi	a5,a5,512
    80006eac:	0792                	slli	a5,a5,0x4
    80006eae:	97ca                	add	a5,a5,s2
    80006eb0:	7788                	ld	a0,40(a5)
    80006eb2:	00052223          	sw	zero,4(a0)
    80006eb6:	ffffb097          	auipc	ra,0xffffb
    80006eba:	088080e7          	jalr	136(ra) # 80001f3e <wakeup>
    80006ebe:	0204d783          	lhu	a5,32(s1)
    80006ec2:	2785                	addiw	a5,a5,1
    80006ec4:	17c2                	slli	a5,a5,0x30
    80006ec6:	93c1                	srli	a5,a5,0x30
    80006ec8:	02f49023          	sh	a5,32(s1)
    80006ecc:	6898                	ld	a4,16(s1)
    80006ece:	00275703          	lhu	a4,2(a4)
    80006ed2:	faf71be3          	bne	a4,a5,80006e88 <virtio_disk_intr+0x50>
    80006ed6:	0002e517          	auipc	a0,0x2e
    80006eda:	25250513          	addi	a0,a0,594 # 80035128 <disk+0x2128>
    80006ede:	ffffa097          	auipc	ra,0xffffa
    80006ee2:	df0080e7          	jalr	-528(ra) # 80000cce <release>
    80006ee6:	60e2                	ld	ra,24(sp)
    80006ee8:	6442                	ld	s0,16(sp)
    80006eea:	64a2                	ld	s1,8(sp)
    80006eec:	6902                	ld	s2,0(sp)
    80006eee:	6105                	addi	sp,sp,32
    80006ef0:	8082                	ret
    80006ef2:	00003517          	auipc	a0,0x3
    80006ef6:	9be50513          	addi	a0,a0,-1602 # 800098b0 <syscalls+0x430>
    80006efa:	ffff9097          	auipc	ra,0xffff9
    80006efe:	642080e7          	jalr	1602(ra) # 8000053c <panic>

0000000080006f02 <seminit>:
    80006f02:	7179                	addi	sp,sp,-48
    80006f04:	f406                	sd	ra,40(sp)
    80006f06:	f022                	sd	s0,32(sp)
    80006f08:	ec26                	sd	s1,24(sp)
    80006f0a:	e84a                	sd	s2,16(sp)
    80006f0c:	e44e                	sd	s3,8(sp)
    80006f0e:	1800                	addi	s0,sp,48
    80006f10:	00003597          	auipc	a1,0x3
    80006f14:	9b858593          	addi	a1,a1,-1608 # 800098c8 <syscalls+0x448>
    80006f18:	0002f517          	auipc	a0,0x2f
    80006f1c:	0e850513          	addi	a0,a0,232 # 80036000 <semtable>
    80006f20:	ffffa097          	auipc	ra,0xffffa
    80006f24:	c6a080e7          	jalr	-918(ra) # 80000b8a <initlock>
    80006f28:	0002f497          	auipc	s1,0x2f
    80006f2c:	0f048493          	addi	s1,s1,240 # 80036018 <semtable+0x18>
    80006f30:	00030997          	auipc	s3,0x30
    80006f34:	d6898993          	addi	s3,s3,-664 # 80036c98 <end>
    80006f38:	00003917          	auipc	s2,0x3
    80006f3c:	9a090913          	addi	s2,s2,-1632 # 800098d8 <syscalls+0x458>
    80006f40:	85ca                	mv	a1,s2
    80006f42:	8526                	mv	a0,s1
    80006f44:	ffffa097          	auipc	ra,0xffffa
    80006f48:	c46080e7          	jalr	-954(ra) # 80000b8a <initlock>
    80006f4c:	02048493          	addi	s1,s1,32
    80006f50:	ff3498e3          	bne	s1,s3,80006f40 <seminit+0x3e>
    80006f54:	70a2                	ld	ra,40(sp)
    80006f56:	7402                	ld	s0,32(sp)
    80006f58:	64e2                	ld	s1,24(sp)
    80006f5a:	6942                	ld	s2,16(sp)
    80006f5c:	69a2                	ld	s3,8(sp)
    80006f5e:	6145                	addi	sp,sp,48
    80006f60:	8082                	ret

0000000080006f62 <semalloc>:
    80006f62:	1101                	addi	sp,sp,-32
    80006f64:	ec06                	sd	ra,24(sp)
    80006f66:	e822                	sd	s0,16(sp)
    80006f68:	e426                	sd	s1,8(sp)
    80006f6a:	1000                	addi	s0,sp,32
    80006f6c:	0002f517          	auipc	a0,0x2f
    80006f70:	09450513          	addi	a0,a0,148 # 80036000 <semtable>
    80006f74:	ffffa097          	auipc	ra,0xffffa
    80006f78:	ca6080e7          	jalr	-858(ra) # 80000c1a <acquire>
    80006f7c:	0002f797          	auipc	a5,0x2f
    80006f80:	0b878793          	addi	a5,a5,184 # 80036034 <semtable+0x34>
    80006f84:	4481                	li	s1,0
    80006f86:	06400693          	li	a3,100
    80006f8a:	4398                	lw	a4,0(a5)
    80006f8c:	c305                	beqz	a4,80006fac <semalloc+0x4a>
    80006f8e:	2485                	addiw	s1,s1,1
    80006f90:	02078793          	addi	a5,a5,32
    80006f94:	fed49be3          	bne	s1,a3,80006f8a <semalloc+0x28>
    80006f98:	0002f517          	auipc	a0,0x2f
    80006f9c:	06850513          	addi	a0,a0,104 # 80036000 <semtable>
    80006fa0:	ffffa097          	auipc	ra,0xffffa
    80006fa4:	d2e080e7          	jalr	-722(ra) # 80000cce <release>
    80006fa8:	54fd                	li	s1,-1
    80006faa:	a839                	j	80006fc8 <semalloc+0x66>
    80006fac:	0002f517          	auipc	a0,0x2f
    80006fb0:	05450513          	addi	a0,a0,84 # 80036000 <semtable>
    80006fb4:	00148793          	addi	a5,s1,1
    80006fb8:	0796                	slli	a5,a5,0x5
    80006fba:	97aa                	add	a5,a5,a0
    80006fbc:	4705                	li	a4,1
    80006fbe:	cbd8                	sw	a4,20(a5)
    80006fc0:	ffffa097          	auipc	ra,0xffffa
    80006fc4:	d0e080e7          	jalr	-754(ra) # 80000cce <release>
    80006fc8:	8526                	mv	a0,s1
    80006fca:	60e2                	ld	ra,24(sp)
    80006fcc:	6442                	ld	s0,16(sp)
    80006fce:	64a2                	ld	s1,8(sp)
    80006fd0:	6105                	addi	sp,sp,32
    80006fd2:	8082                	ret

0000000080006fd4 <sedealloc>:
    80006fd4:	1101                	addi	sp,sp,-32
    80006fd6:	ec06                	sd	ra,24(sp)
    80006fd8:	e822                	sd	s0,16(sp)
    80006fda:	e426                	sd	s1,8(sp)
    80006fdc:	e04a                	sd	s2,0(sp)
    80006fde:	1000                	addi	s0,sp,32
    80006fe0:	84aa                	mv	s1,a0
    80006fe2:	00551913          	slli	s2,a0,0x5
    80006fe6:	0002f797          	auipc	a5,0x2f
    80006fea:	03278793          	addi	a5,a5,50 # 80036018 <semtable+0x18>
    80006fee:	993e                	add	s2,s2,a5
    80006ff0:	854a                	mv	a0,s2
    80006ff2:	ffffa097          	auipc	ra,0xffffa
    80006ff6:	c28080e7          	jalr	-984(ra) # 80000c1a <acquire>
    80006ffa:	0004871b          	sext.w	a4,s1
    80006ffe:	06300793          	li	a5,99
    80007002:	00e7eb63          	bltu	a5,a4,80007018 <sedealloc+0x44>
    80007006:	0485                	addi	s1,s1,1
    80007008:	0496                	slli	s1,s1,0x5
    8000700a:	0002f797          	auipc	a5,0x2f
    8000700e:	ff678793          	addi	a5,a5,-10 # 80036000 <semtable>
    80007012:	97a6                	add	a5,a5,s1
    80007014:	0007aa23          	sw	zero,20(a5)
    80007018:	854a                	mv	a0,s2
    8000701a:	ffffa097          	auipc	ra,0xffffa
    8000701e:	cb4080e7          	jalr	-844(ra) # 80000cce <release>
    80007022:	60e2                	ld	ra,24(sp)
    80007024:	6442                	ld	s0,16(sp)
    80007026:	64a2                	ld	s1,8(sp)
    80007028:	6902                	ld	s2,0(sp)
    8000702a:	6105                	addi	sp,sp,32
    8000702c:	8082                	ret
	...

0000000080008000 <_trampoline>:
    80008000:	14051573          	csrrw	a0,sscratch,a0
    80008004:	02153423          	sd	ra,40(a0)
    80008008:	02253823          	sd	sp,48(a0)
    8000800c:	02353c23          	sd	gp,56(a0)
    80008010:	04453023          	sd	tp,64(a0)
    80008014:	04553423          	sd	t0,72(a0)
    80008018:	04653823          	sd	t1,80(a0)
    8000801c:	04753c23          	sd	t2,88(a0)
    80008020:	f120                	sd	s0,96(a0)
    80008022:	f524                	sd	s1,104(a0)
    80008024:	fd2c                	sd	a1,120(a0)
    80008026:	e150                	sd	a2,128(a0)
    80008028:	e554                	sd	a3,136(a0)
    8000802a:	e958                	sd	a4,144(a0)
    8000802c:	ed5c                	sd	a5,152(a0)
    8000802e:	0b053023          	sd	a6,160(a0)
    80008032:	0b153423          	sd	a7,168(a0)
    80008036:	0b253823          	sd	s2,176(a0)
    8000803a:	0b353c23          	sd	s3,184(a0)
    8000803e:	0d453023          	sd	s4,192(a0)
    80008042:	0d553423          	sd	s5,200(a0)
    80008046:	0d653823          	sd	s6,208(a0)
    8000804a:	0d753c23          	sd	s7,216(a0)
    8000804e:	0f853023          	sd	s8,224(a0)
    80008052:	0f953423          	sd	s9,232(a0)
    80008056:	0fa53823          	sd	s10,240(a0)
    8000805a:	0fb53c23          	sd	s11,248(a0)
    8000805e:	11c53023          	sd	t3,256(a0)
    80008062:	11d53423          	sd	t4,264(a0)
    80008066:	11e53823          	sd	t5,272(a0)
    8000806a:	11f53c23          	sd	t6,280(a0)
    8000806e:	140022f3          	csrr	t0,sscratch
    80008072:	06553823          	sd	t0,112(a0)
    80008076:	00853103          	ld	sp,8(a0)
    8000807a:	02053203          	ld	tp,32(a0)
    8000807e:	01053283          	ld	t0,16(a0)
    80008082:	00053303          	ld	t1,0(a0)
    80008086:	18031073          	csrw	satp,t1
    8000808a:	12000073          	sfence.vma
    8000808e:	8282                	jr	t0

0000000080008090 <userret>:
    80008090:	18059073          	csrw	satp,a1
    80008094:	12000073          	sfence.vma
    80008098:	07053283          	ld	t0,112(a0)
    8000809c:	14029073          	csrw	sscratch,t0
    800080a0:	02853083          	ld	ra,40(a0)
    800080a4:	03053103          	ld	sp,48(a0)
    800080a8:	03853183          	ld	gp,56(a0)
    800080ac:	04053203          	ld	tp,64(a0)
    800080b0:	04853283          	ld	t0,72(a0)
    800080b4:	05053303          	ld	t1,80(a0)
    800080b8:	05853383          	ld	t2,88(a0)
    800080bc:	7120                	ld	s0,96(a0)
    800080be:	7524                	ld	s1,104(a0)
    800080c0:	7d2c                	ld	a1,120(a0)
    800080c2:	6150                	ld	a2,128(a0)
    800080c4:	6554                	ld	a3,136(a0)
    800080c6:	6958                	ld	a4,144(a0)
    800080c8:	6d5c                	ld	a5,152(a0)
    800080ca:	0a053803          	ld	a6,160(a0)
    800080ce:	0a853883          	ld	a7,168(a0)
    800080d2:	0b053903          	ld	s2,176(a0)
    800080d6:	0b853983          	ld	s3,184(a0)
    800080da:	0c053a03          	ld	s4,192(a0)
    800080de:	0c853a83          	ld	s5,200(a0)
    800080e2:	0d053b03          	ld	s6,208(a0)
    800080e6:	0d853b83          	ld	s7,216(a0)
    800080ea:	0e053c03          	ld	s8,224(a0)
    800080ee:	0e853c83          	ld	s9,232(a0)
    800080f2:	0f053d03          	ld	s10,240(a0)
    800080f6:	0f853d83          	ld	s11,248(a0)
    800080fa:	10053e03          	ld	t3,256(a0)
    800080fe:	10853e83          	ld	t4,264(a0)
    80008102:	11053f03          	ld	t5,272(a0)
    80008106:	11853f83          	ld	t6,280(a0)
    8000810a:	14051573          	csrrw	a0,sscratch,a0
    8000810e:	10200073          	sret
	...
