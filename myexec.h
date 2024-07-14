
typedef void			*APTR;	    /* 32-bit untyped pointer */
typedef long			LONG;	    /* signed 32-bit quantity */
typedef unsigned long	ULONG;	    /* unsigned 32-bit quantity */
typedef unsigned long	LONGBITS;   /* 32 bits manipulated individually */
typedef short			WORD;	    /* signed 16-bit quantity */
typedef unsigned short	UWORD;	    /* unsigned 16-bit quantity */
typedef unsigned short	WORDBITS;   /* 16 bits manipulated individually */
typedef char			BYTE;	    /* signed 8-bit quantity */
typedef unsigned char	UBYTE;	    /* unsigned 8-bit quantity */
typedef unsigned char	BYTEBITS;   /* 8 bits manipulated individually */
typedef short			RPTR;	    /* signed relative pointer */

#define TRUE 	1
#define FALSE	0

#ifndef NULL
#define NULL	0
#endif

extern __far APTR	MyExecBase;

void __asm BufReadFile(register __d0 char *, register __a0 APTR);
void __asm ReadFile(register __d0 char *, register __a0 APTR);
APTR __asm LoadFile(register __d0 char *);
APTR __asm LoadFastFile(register __d0 char *);
APTR __asm LoadSeg(register __d0 char *);
void __asm UnLoadSeg(register __a1 APTR);
APTR __asm BufLoadFile(register __d0 char *);
char __asm GetKey(void);
void __asm ColdReboot(void);
struct Bob * __asm AddBob(register __a1 APTR);
void __asm DrawOneBob(register __a0 struct Bob *, register __a1 struct BitMap *);
APTR __asm AllocMem(register __d0 LONG);
APTR __asm AllocClearMem(register __d0 LONG);
APTR __asm AllocFastMem(register __d0 LONG);
APTR __asm AllocFastClearMem(register __d0 LONG);
void __asm FreeMem(register __a1 APTR);
LONG __asm AvailMem(void);
LONG __asm AvailFastMem(void);
void __asm SetMovePrg(register __a0 struct Bob *, register __a1 APTR, register __d0 LONG, register __d1 LONG);
void __asm SetAnimPrg(register __a0 struct Bob *, register __a1 APTR, register __d0 LONG);
void __asm RemBob(register __a0 struct Bob *);
void __asm CopyMem(register __a0 APTR, register __a1 APTR, register __d0 LONG);
void __asm ClearMem(register __a0 APTR, register __d0 LONG);
short __asm Random(register __d0 LONG);
void __asm Debug(register __a0 char *);
