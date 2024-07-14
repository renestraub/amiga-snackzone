/****************************************************************************
**                                                                         **
**  Start.c  -  Rettet CHIP-RAM, lädt und startet Exec, Exit.              **
**                                                                         **
*****************************************************************************
**                                                                         **
**   Modification History                                                  **
**   --------------------                                                  **
**                                                                         **
**   19-May-89  CHW     Created this file from Auto/Start.S                **
**   04-Jun-89  CHW     Testet jetzt ob RAMDisk vorhanden ist              **
**   20-Jun-89  CHW     Unterstützt jetzt 1MB CHIP-RAM wenn man's hat      **
**   21-Jun-89  CHW     ENV-Variable 'RAMDISKBASE' implementiert           **
**   27-Jun-89  CHW     Converted to genim2                                **
**   24-Aug-89  CHW     Disk-Version implemented                           **
**   27-Nov-89  CHW     FastRAM implemented                                **
**   15-Dec-89  CHW     VBR wird nach 0 gelegt                             **
**   30-Jan-90  CHW     1MB ChipRAM wird bei $a0000 statt $90000 getestet  **
**   03-Apr-90  CHW     CiaKick eingebaut                                  **
**   24-Jul-90  CHW     NoSave option eingebaut                            **
**   03-Sep-90  CHW     C-Version, ARP Parser, variable MemSize eingebaut  **
**   01-Oct-90  CHW     CHIPSIZE-Option funktioniert jetzt                 **
**   17-Oct-90  CHW     CHIPSIZE-Option funktioniert wirklich :-)          **
**   23-Feb-91  CHW     Läuft jetzt mit dem 2.0 ramdrive.device            **
**   09-May-91  RHS     RamDrive Grösse wird jetzt richtig gelesen         **
**   16-Jun-91  CHH     TimerB Bug behoben.                                **
**   16-Jun-91  CHW/CHH Läuft jetzt unter 2.0 ("chip memory" :-()          **
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
#include <dos/dosextens.h>
#include <dos/filehandler.h>
#include <string.h>			/* z.B. für __builtin_memcpy */
#include <dos.h>			/* Für getreg und so */

char ident[]         = "$VER: Exec V4.4 (" __DATE__ ") by Christian A. Weber";
char CLI_Template[]  = "NS=NOSAVE/s,NF=NOFAST/s,CS=CHIPSIZE/k";
char CLI_Help[]      = "Usage: Start [NOSAVE] [NOFAST] [CHIPSIZE size]";

#define ARG_NOSAVE		0				/* Argument numbers for GADS() */
#define ARG_NOFAST		1
#define ARG_CHIPSIZE	2
#define ARG_INVALID		3

void exit(LONG);
ULONG GetVBR(void);
void SetVBR(ULONG);
ULONG GetCACR(void);
void SetCACR(ULONG);

extern struct ExecBase		*SysBase;
extern struct GfxBase		*GfxBase;
extern struct ArpBase		*ArpBase;	/* Also used for DOS functions */
extern struct DosLibrary	*DOSBase;
extern BPTR StdErr;						/* Standard Error output stream */
extern BYTE NewOS;
extern struct Custom far volatile custom;

extern char ExecModuleStart,ExecModuleEnd;

/***************************************************************************/

#define ABORT		0x1FFFFA		/* Am Ende des CHIP RAMs */
#define DISKMAGIC	0x43485700		/* Currently 'CHW',0 */
#define INITMAGIC	0x494E4954		/* 'INIT' */
#define FFSMAGIC	0x444f5301		/* 'DOS',1 */
#define local

struct RAD					/* 1.3 RAD Device-Struktur */
{
	struct Library LibNode;			/*  0 */
	UBYTE Mist[10];					/* 34 */
	ULONG MemSize;					/* 44 */
	void *MemPtr;					/* 48 */
};

struct RUN					/* 2.0 RAD Unit-Struktur */
{
	struct MinNode Node;
	void *MemPtr;
	UWORD MatchWord;
};

struct Mem
{
	struct Mem *Next;
	void *Address;
	ULONG Size;
} *chipmemlist;			/* Liste der geretteten CHIP-Blöcke */

UBYTE *radmem;			/* Startadresse der RAD-Disk */
ULONG radsize;			/* Grösse der RAD-Disk */
ULONG radunit;			/* Unit-Nummer der RAD-Disk */

UBYTE *fastbase;		/* Startadresse des FAST-RAMs für Exec */
LONG fastsize;			/* Grösse des FAST-RAMs für Exec */

UWORD dmaconsave,intenasave;
ULONG attnflags,vblankfreq,sysbplcon0;
ULONG oldcacr,oldvbr;

ULONG oldssp,oldusp;	/* Gerettete Supervisor- und User-Stackpointer */
ULONG stacktop;			/* Obergrenze des Chip-RAMs für Exec */

ULONG GetVBR() { return 0; }
void  SetVBR(ULONG vbr) { }

#ifdef DEBUG
/***************************************************************************/
/* Auf Maustaste warten und dabei Farbe ausgeben */

local void Maus(UWORD col)
{
	register LONG i;
	while((*(UBYTE *)0xbfe001)&0x40) custom.color[0]=col;
	while(!((*(UBYTE *)0xbfe001)&0x40)) ;
	for(i=0; i<200000; ++i) custom.color[0]=(UWORD)i;
	custom.color[0]=0;
}
#endif

/***************************************************************************/
/* Gerettetes CHIP-RAM zurückkopieren */

local void RestoreChipRAM(void)
{
	struct Mem *mc;

	for(mc=chipmemlist; mc; mc=mc->Next)
		memcpy(mc->Address,mc+1,mc->Size);
}

/***************************************************************************/
/* Save-Buffers des CHIP-RAMs freigeben */

local void FreeChipRAMSaveBuffers(void)
{
	struct Mem *mc,*next;
	register LONG size=0;

	for(mc=chipmemlist; mc; mc=next)
	{
		size+=mc->Size;
		next=mc->Next;
		FreeMem(mc,mc->Size+sizeof(*mc));
	}
	chipmemlist = NULL;
	Printf("Saved Chip-RAM = %ld bytes.\n",size);
}

/***************************************************************************/
/* Alles allozierte CHIP-RAM retten und in eine Liste eintragen */

local BOOL SaveChipRAM(void)
{
	struct MemHeader *mrh;
	struct MemChunk *mc;
	struct Mem *dc,*olddc=(struct Mem *)&chipmemlist;
	register ULONG last=0;

	if(!(mrh=(struct MemHeader *)FindName(&SysBase->MemList,"Chip Memory")))
	{
		if(!(mrh=(struct MemHeader *)FindName(&SysBase->MemList,"chip memory")))
		{
			Enable();
			DisownBlitter();
			Puts("Can't find the Chip Memory header");
			return FALSE;
		}
	}

	for(mc=mrh->mh_First;; mc=mc->mc_Next)
	{
		register ULONG size;
		if(mc==NULL) mc=(struct MemChunk *)(SysBase->MaxLocMem-sizeof(*mc));
		size=(ULONG)mc-(ULONG)last+sizeof(*mc);
#ifdef VERBOSE
		Printf("$%06lx-$%06lx (%ld bytes)",last,last+size-1,size);
#endif
		if(dc=AllocMem(size+sizeof(struct Mem),MEMF_FAST))
		{
#ifdef VERBOSE
			Printf("\t -> $%08lx\n",dc+1);
#endif
			dc->Next=NULL;
			dc->Address=(void *)last;
			dc->Size=size;
			CopyMem((void *)last,(void *)(dc+1),size);
			last=(ULONG)mc+mc->mc_Bytes;
			olddc->Next=dc; olddc=dc;
			if(mc==(struct MemChunk *)(SysBase->MaxLocMem-sizeof(*mc))) break;
		}
		else
		{
			Enable();
			DisownBlitter();
			FreeChipRAMSaveBuffers();
			Printf("Can't allocate %ld bytes FAST RAM\n",size+sizeof(struct Mem));
			return FALSE;
		}
	}
	return TRUE;
}

/***************************************************************************/
/* CIA-Resource ankicken */

local void KickResource(char *name)
{
	register UBYTE *ciabase=(UBYTE *)FindName(&SysBase->ResourceList,name);
	ciabase[0x29] = 0x7F;	/* Alle Interrupt-Request-Bits setzen */
}

/***************************************************************************/
/* Alles freigeben, back to DOS */

__saveds void ExitRoutine(LONG D0,LONG D1,void *A0,void *A1)
{
	register i;
	static char text[100];
	putreg(REG_A7,oldusp-256);		/* Temporärer Stack auf unserem Userstack */
	custom.intena = 0x7FFF;			/* Alle Interrupts sperren */
	custom.dmacon = 0x7FFF;			/* DMA abschalten */
	custom.color[0] = 0x173;		/* Grünlich */

	strcpy(text,*(void **)0x110);	/* ROMCrack-Text retten */
#if 0
	memset(NULL,0xAA,stacktop);		/* CHIP-RAM löschen mit $AA */
#endif
	custom.color[0] = 0x713;		/* Rötlich */
	RestoreChipRAM();				/* Und CHIP-RAM wieder restoren */

	/* AB HIER IST DAS BETRIEBSSYSTEM WIEDER VORHANDEN */

	UserState((void *)oldssp);		/* Zurück in den Usermode */

	custom.cop1lc = (ULONG)GfxBase->copinit;	/* Bild wieder einschalten */
	custom.dmacon = dmaconsave | DMAF_SETCLR;	/* Original dmacon zurückholen */
	custom.intena = intenasave | INTF_SETCLR;	/* Dito mit intena */

	for(i=0; i<8; ++i) custom.spr[i].dataa = custom.spr[i].datab=0;

	WaitBlit();
	DisownBlitter();
	Enable();
	RemakeDisplay();

	FreeChipRAMSaveBuffers();					/* Chip-SaveBuffer freigeben */

	SetVBR(oldvbr);
	SetCACR(oldcacr);

	KickResource(CIABNAME);		/* CIA-Resources ankicken (alle Interrupts auslösen) */
	KickResource(CIAANAME);

    *(UBYTE *)0xbfed01=0x82;

	Printf("Last message: %s\nD0=%08lx D1=%08lx A0=%08lx A1=%08lx\n",text,D0,D1,A0,A1);

	exit(RETURN_OK);
}

/***************************************************************************/

int GetDriveVars(char *drive)
{
	struct	DeviceNode *ldn;
	int		found=FALSE;

	Forbid();

	for(ldn=BADDR(((struct DosInfo *)BADDR(((struct RootNode *)DOSBase->dl_Root)->rn_Info))->di_DevInfo);
		ldn; ldn=BADDR(ldn->dn_Next))
	{
		if((ldn->dn_Type==DLT_DEVICE) && (ldn->dn_Startup>0x40))
		{
			struct	FileSysStartupMsg	*fs = BADDR(ldn->dn_Startup);
			struct	DosEnvec			*de = BADDR(fs->fssm_Environ);
			char						*name=(UBYTE *)BADDR(ldn->dn_Name);
			int							i;

			for(i=0; i< *name; ++i)
				if((name[i+1]&0xDF) != (drive[i]&0xDF)) goto next;
			if((drive[i] != ':') && drive[i] != '\0') goto next;

			radsize = ((de->de_HighCyl) - (de->de_LowCyl) +1 )*de->de_BlocksPerTrack*de->de_Surfaces;
			radsize*= 512;
			radunit = fs->fssm_Unit;
			found=TRUE;
			break;
		}
next: ;
	}
	while(ldn=BADDR(ldn->dn_Next));

	Permit();
	return found;
}

/***************************************************************************/
/* Hauptprogramm */

LONG ARPMain(LONG arglen,char *argline)
{
	char *argv[ARG_INVALID+1];			/* Filled in by GADS() */
	struct IOStdReq RADIO;
	ULONG usestacktop;

	memset(argv,0,sizeof(argv));	/* Since no args is valid, clear the arg-array */
	Puts(ident+6);
	if(GADS(argline,arglen,CLI_Help,argv,CLI_Template)<0)
	{
		Puts(argv[0]);
		Puts(CLI_Help);
		return RETURN_FAIL ;
	}

	if(GetDriveVars("EXEC:")==FALSE)
	{
		Puts("Würden Sie bitte gütigerweise das EXEC mounten?!");
	 	return RETURN_ERROR;
	}

	if(!OpenDevice("ramdrive.device",radunit,&RADIO,0))
	{
radok:
		/* Startadresse rausfinden */
		if(NewOS)
		{
			radmem = ((struct RUN *)(RADIO.io_Unit))->MemPtr;
			if(((struct RUN *)(RADIO.io_Unit))->MatchWord != 0x4AFC)
				Puts("WARNING: No resident tag!");
		}
		else radmem = ((struct RAD *)(RADIO.io_Device))->MemPtr;

		CloseDevice(&RADIO);

		if(*(ULONG *)radmem == FFSMAGIC)	/* 'DOS1' am Anfang ? */
		{
			ULONG execentry;
			Printf("RAMDrive: $%08lx (%ldK)\n",radmem,radsize/1024);

			usestacktop = stacktop = (ULONG)SysBase->MaxLocMem;

			if(argv[ARG_CHIPSIZE])
			{
				usestacktop = 1024*Atol(argv[ARG_CHIPSIZE]);
				if((usestacktop<100000) || (usestacktop>stacktop))
				{
					Puts("Bad CHIP size, please try again!");
					return RETURN_ERROR;
				}
			}

			Printf("Chip RAM: $00000000 (%ldK)\n",usestacktop/1024);


			if(!argv[ARG_NOFAST])	/* Grössten freien FAST-RAM-Block reservieren */
			{
				if(fastsize = AvailMem(MEMF_FAST|MEMF_LARGEST) & ~0xff)
				{
					fastsize -= (stacktop-AvailMem(MEMF_CHIP)+10000);
					if(fastsize>=10000L)
					{
						fastbase = ArpAllocMem(fastsize,MEMF_FAST);
						Printf("Fast RAM: $%08lx (%ldK)\n",fastbase,fastsize/1024);
					}
					else
					{
						fastbase=NULL; fastsize=0;
						Puts("Not enough FAST RAM available :-)");
					}
				}
				else Puts("No FAST RAM available.");
			}


			/* AB HIER DARF IM CHIP-RAM NICHTS MEHR VERÄNDERT WERDEN */

			OwnBlitter();
			WaitBlit();
			Disable();

			/* System-Status für MyExec merken/retten etc. */

			dmaconsave = custom.dmaconr&~DMAF_SPRITE;
			intenasave = custom.intenar&~INTF_INTEN;
			attnflags  = SysBase->AttnFlags;
			vblankfreq = SysBase->VBlankFrequency;
			sysbplcon0 = GfxBase->system_bplcon0;
			oldcacr    = GetCACR();					/* Altes CACR retten */
			oldvbr     = GetVBR();					/* Altes VBR retten */
			oldusp     = getreg(REG_A7);			/* Alten User-Stack retten */

			if(!argv[ARG_NOSAVE])				/* CHIP-RAM retten */
			{
				if(!SaveChipRAM()) return RETURN_ERROR;
			}
			else Puts("CHIP RAM will not be saved.");

			SetCACR(0L);					/* Alle Cache off */
			SetVBR(NULL);					/* VBR nach 0 legen */


			/* AB HIER KEIN BETRIEBSSYSTEM MEHR!! */

			oldssp = (ULONG)SuperState();	/* Supervisor-Mode auf Userstack */
			putreg(REG_A7,usestacktop-80);	/* Neuer Supervisor-Stackpointer */
			custom.intena = 0x7FFF;			/* Interrupts sperren */
			custom.dmacon = 0x7FFF;			/* Und DMA auch */

			custom.color[0] = 0x400;		/* Bildschirm dunkelrot */
#if 0
			memset(NULL,0,usestacktop);		/* CHIP-RAM löschen */
#endif
			memcpy(NULL,&ExecModuleStart,&ExecModuleEnd-&ExecModuleStart);

			for(execentry=0; *(ULONG *)execentry!=INITMAGIC; execentry+=2) ; /* Entry suchen */
			execentry += 4;

			if(argv[ARG_NOSAVE])			/* Kein Save -> ABORT macht ColdReboot() */
			{
				*(ULONG *)ABORT = 0x4EF80008+execentry;	/* JMP<<16+4+4=2.Vektor */
			}
			else
			{
				*(UWORD *)ABORT     = 0x4EF9;				/* Rücksprung-JMP */
				*(void **)(ABORT+2) = (void *)ExitRoutine;	/* Cleanup-Routine */
			}

			custom.color[0] = 0xF00;			/* Bildschirm rot */

			{
				register void (* __asm init)(
					register __d0 LONG,  register __d1 LONG,
					register __d2 LONG,  register __d3 LONG,
					register __d4 LONG,
					register __a0 void *,register __a1 void *,
					register __a2 void *,register __a3 void *);

				init =(void *)execentry;

				init(	attnflags,			/* D0 */
						sysbplcon0,			/* D1 */
						vblankfreq,			/* D2 */
						0,					/* D3 :  Product-Code */
						(LONG)"MainPrg",	/* D4 :  MainPrg-Name */
						radmem,				/* A0 :  RAD-Startadresse */
						(void *)radsize,	/* A1 :  RAD-Grösse */
						fastbase,			/* A2 :  FAST-Startadresse */
						fastbase+fastsize	/* A3 :  FAST-Endadresse */
					);
				ExitRoutine();
				/* not reached */
			}
		}
		else Puts("Du musst eine FFS-RamDisk haben, du Depp!");
	}
	else if(!OpenDevice("ffsdrive.device",radunit,&RADIO,0)) goto radok;
	else Puts("Can't open ramdrive.device or ffsdrive.device");

	return RETURN_OK;
}

