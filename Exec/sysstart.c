/****************************************************************************
**                                                                         **
**  SysStart.c  -  Startet Exec MIT Betriebssystem                         **
**                                                                         **
*****************************************************************************
**                                                                         **
**   Modification History                                                  **
**   --------------------                                                  **
**                                                                         **
**   24-Feb-91  CHW  Created this file from Start.S                        **
**                                                                         **
****************************************************************************/

#include <proto/exec.h>
#include <exec/io.h>
#include <exec/memory.h>
#include <exec/execbase.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <graphics/gfxbase.h>
#include <hardware/custom.h>
#include <hardware/dmabits.h>
#include <hardware/intbits.h>
#include <resources/cia.h>
#include <arp/arpbase.h>
#include <string.h>			/* z.B. für __builtin_memcpy */
#include <dos.h>			/* Für getreg und so */

#define ARG_CHIPSIZE	0				/* Argument numbers for GADS() */
#define ARG_FASTSIZE	1
#define ARG_MODULE		2
#define ARG_PRI			3
#define ARG_INVALID		4

static char ident[]         = "$VER: Exec 4.01 by Christian A. Weber (" __DATE__ ")";
static char CLI_Template[]  = "CS=CHIPSIZE/k,FS=FASTSIZE/k,MOD/k,PRI/k";
static char CLI_Help[]      = "Usage: SysStart [CHIPSIZE kbytes] [FASTSIZE kbytes] [MOD name] [PRI pri]";

char DebugText[256];

extern struct ExecBase *SysBase;
extern struct GfxBase *GfxBase;
extern struct ArpBase *ArpBase;			/* Also used for DOS functions */
extern BPTR StdErr;				/* Standard Error output stream */
extern BYTE NewOS;
extern struct Custom far volatile custom;

extern void __asm __far InitExec(
	register __d0 LONG,  register __d1 LONG,
	register __d2 LONG,  register __d3 LONG, register __d4 LONG,
	register __a0 void *,register __a1 void *,
	register __a2 void *,register __a3 void *);

static UBYTE *chipbase;		/* Startadresse des CHIP-RAMs für Exec */
static LONG chipsize;		/* Grösse des CHIP-RAMs für Exec */

static UBYTE *fastbase;		/* Startadresse des FAST-RAMs für Exec */
static LONG fastsize;		/* Grösse des FAST-RAMs für Exec */

static UWORD dmaconsave,intenasave;
static ULONG attnflags,vblankfreq,sysbplcon0;
static BYTE oldtaskpri;
static BYTE wbclose;
//static BPTR	dir_lock;

/***************************************************************************/
/* Alles freigeben, back to DOS */

__saveds void ExitRoutine(LONG D0,LONG D1,void *A0,void *A1)
{
	extern void exit(LONG);
	register i;
	custom.color[0] = 0x173;		/* Grünlich */

//	WaitBlit();
//	DisownBlitter();

	custom.cop1lc = (ULONG)GfxBase->copinit;	/* Bild wieder einschalten */

	custom.dmacon = 0x7FFF;
	custom.dmacon = dmaconsave | DMAF_SETCLR;	/* Original dmacon zurückholen */

	custom.intena = 0x7FFF;
	custom.intena = intenasave | INTF_SETCLR;	/* Dito mit intena */

	for(i=0; i<8; ++i) custom.spr[i].dataa = custom.spr[i].datab=0;

	RemakeDisplay();
	SetTaskPri(SysBase->ThisTask,oldtaskpri);

	if(wbclose)			OpenWorkBench();	/* ReOpen WB */

//	if(dir_lock)		UnLock(dir_lock);

//	if(DebugText[0])	Printf("MSG '%s'\n",&DebugText);

	exit(RETURN_OK);
}

/***************************************************************************/
/* Hauptprogramm */

LONG ARPMain(LONG arglen,char *argline)
{
	static char *argv[ARG_INVALID+1];	/* static damit's gelöscht wird */
	static char module[64]="MAINPRG";
	LONG taskpri=4;

//	Puts(ident+6);

	if(GADS(argline,arglen,CLI_Help,argv,CLI_Template)<0)
	{
		Puts(argv[0]);
		Puts(CLI_Help);
		return RETURN_FAIL ;
	}

	AllocMem(0x40000000,0);		/* Flushlibs */
	AllocMem(0x40000000,0);

	wbclose = FALSE;
	if((AvailMem(MEMF_CHIP|MEMF_LARGEST)) < 500*1024)
		wbclose = CloseWorkBench();		/* Weg mit der Workbench */

	if(argv[ARG_CHIPSIZE])
	{
		chipsize = 1024*Atol(argv[ARG_CHIPSIZE]);
		if(chipsize < 100000)
		{
			Puts("Bad CHIP size, please try again!");
			return RETURN_ERROR;
		}
	}
	else
	{
//		chipsize = (AvailMem(MEMF_CHIP|MEMF_LARGEST)-30000) & ~0xff;

		chipsize = (AvailMem(MEMF_CHIP|MEMF_LARGEST)-10000) & ~0xff;
		if(chipsize > 1000000) chipsize = (3*chipsize)/4;
	}

	if(argv[ARG_FASTSIZE])
	{
		fastsize = 1024*Atol(argv[ARG_FASTSIZE]);
	}
	else
	{
		fastsize = (AvailMem(MEMF_FAST|MEMF_LARGEST)-50000) & ~0xff;
		if(fastsize > 1000000) fastsize = (3*fastsize)/4;
	}

	if(argv[ARG_MODULE])	strcpy(module,argv[ARG_MODULE]);
	if(argv[ARG_PRI])		taskpri = Atol(argv[ARG_PRI]);

//	dir_lock = Lock("Game", ACCESS_READ);
//	if(dir_lock)
//	{
//		CurrentDir(dir_lock);

		if(chipbase=ArpAllocMem(chipsize,MEMF_CHIP|MEMF_CLEAR))
		{
//			Printf("Chip RAM: $%08lx (%ldK)\n",chipbase,chipsize/1024);

			if(fastbase = ArpAllocMem(fastsize,MEMF_FAST|MEMF_CLEAR))
			{
//				Printf("Fast RAM: $%08lx (%ldK)\n",fastbase,fastsize/1024);
			}
			else
			{
				fastbase=NULL; fastsize=0;
				Puts("Not enough FAST RAM available");
			}

	//		OwnBlitter()
			LoadView(0);
			WaitBlit();

			oldtaskpri = SetTaskPri(SysBase->ThisTask,taskpri);

			/* System-Status für MyExec merken/retten etc. */

			dmaconsave = custom.dmaconr;		// &~DMAF_SPRITE;
			intenasave = custom.intenar;		// &~INTF_INTEN;
			attnflags  = SysBase->AttnFlags;
			vblankfreq = SysBase->VBlankFrequency;
			sysbplcon0 = GfxBase->system_bplcon0;

			custom.color[0] = 0xF00;		/* Bildschirm rot */

			InitExec(	attnflags,			/* D0 */
						sysbplcon0,			/* D1 */
						vblankfreq,			/* D2 */
						0,					/* D3 :  Product-Code */
						(LONG)module,		/* D4 :  MainPrg-Name */
						chipbase,			/* A0 :  CHIP-Startadresse */
						chipbase+chipsize,	/* A1 :  CHIP-Grösse */
						fastbase,			/* A2 :  FAST-Startadresse */
						fastbase+fastsize	/* A3 :  FAST-Endadresse */
			);

			ExitRoutine();

			/* not reached */
		}
		else
		{
			Printf("Can't get %ldK CHIP RAM!\n",chipsize/1024);
		}
//	}
	if(wbclose)		OpenWorkBench();	/* ReOpen WB */
	return RETURN_WARN;
}

