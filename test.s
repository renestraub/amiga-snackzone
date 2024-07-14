Lattice AMIGA 68000-68020 OBJ Module Disassembler V5.04.039
Copyright © 1988, 1989 Lattice Inc.  All Rights Reserved.


Amiga Object File Loader V1.00
68000 Instruction Set

EXTERNAL DEFINITIONS

@GetCPUType 0000-00

SECTION 00 "text" 0000006C BYTES
       | 0000  48E7 60C6                      MOVEM.L   D1-D2/A0-A1/A5-A6,-(A7)
       | 0004  2C78 0004                      MOVEA.L   0004,A6
       | 0008  322E 0128                      MOVE.W    0128(A6),D1
       | 000C  7000                           MOVEQ     #00,D0
       | 000E  0801 0003                      BTST      #0003,D1
       | 0012  6704                           BEQ.B     0018
       | 0014  7028                           MOVEQ     #28,D0
       | 0016  6024                           BRA.B     003C
       | 0018  0801 0002                      BTST      #0002,D1
       | 001C  6704                           BEQ.B     0022
       | 001E  701E                           MOVEQ     #1E,D0
       | 0020  601A                           BRA.B     003C
       | 0022  0801 0001                      BTST      #0001,D1
       | 0026  660A                           BNE.B     0032
       | 0028  0801 0000                      BTST      #0000,D1
       | 002C  670E                           BEQ.B     003C
       | 002E  700A                           MOVEQ     #0A,D0
       | 0030  600A                           BRA.B     003C
       | 0032  7014                           MOVEQ     #14,D0
       | 0034  4BFA 000C                      LEA       000C(PC),A5
       | 0038  4EAE  0000-XX.1                JSR       _LVOSupervisor(A6)
       | 003C  4CDF 6306                      MOVEM.L   (A7)+,D1-D2/A0-A1/A5-A6
       | 0040  4E75                           RTS
       | 0042  4E7A 1002                      MOVEC     CACR,D1
       | 0046  2401                           MOVE.L    D1,D2
       | 0048  08C1 0004                      BSET      #0004,D1
       | 004C  0881 0000                      BCLR      #0000,D1
       | 0050  4E7B 1002                      MOVEC     D1,CACR
       | 0054  4E7A 1002                      MOVEC     CACR,D1
       | 0058  0801 0004                      BTST      #0004,D1
       | 005C  6708                           BEQ.B     0066
       | 005E  701E                           MOVEQ     #1E,D0
       | 0060  006E 0004 0128                 ORI.W     #0004,0128(A6)
       | 0066  4E7B 2002                      MOVEC     D2,CACR
       | 006A  4E73                           RTE
