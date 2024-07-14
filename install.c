/*****************************************************************************
*                                                                            *
*  HD-Install V2.16                        Project started  : 04-mar-1991    *
*  ----------------                                finished : 07-apr-1993    *
*                                                                            *
*  Programm by: René Straub                                                  *
*               Talstrasse 820                                               *
*               5726 Unterkulm (Schweiz)                                     *
*               Tel.: P: 064/46 26 61                                        *
*                     G: 064/24 77 24                                        *
*                                                                            *
*  Modification History:                                                     *
*                                                                            *
*  05-mar-91  RHS  V1.00 Winzer                                              *
*  14-aug-91  RHS  V1.30 Super-Soccer                                        *
*  26-nov-91  RHS  V1.50 BlackGold                                           *
*  26-nov-92  RHS  V1.55 CopyBalken eingebaut                                *
*  17-mar-92  RHS  V2.00 SpaceMAX Auf KommandoListe umgebaut                 *
*  18-mar-92  RHS  V2.01 IDirCopy() eingebaut                                *
*  19-mar-92  RHS  V2.02 Erzeugt jetzt Drawer / Neues ITools eingebaut       *
*  09-apr-92  RHS  V2.04 SwapDisk abgeändert                                 *
*  18-apr-92  RHS  V2.06 CopyBalken2 eingebaut                               *
*  06-jun-92  RHS  V2.09 SpaceMAX                                            *
*  28-jun-92  RHS  V2.10 Start nur noch möglich, wenn von HD gebootet        *
*  07-apr-93  RHS  V2.15 SnackZone                                           *
*                                                                            *
******************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dos/dos.h>
#include <exec/memory.h>
#include <graphics/rastport.h>
#include <graphics/gfx.h>
#include <graphics/gfxbase.h>
#include <intuition/intuition.h>
#include <intuition/screens.h>
#include <libraries/dosextens.h>
#include <workbench/workbench.h>

#include <proto/dos.h>
#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/graphics.h>
#include <proto/diskfont.h>

#include <ITools.h>

#define	NOSCREEN

#define MAXWIDTH			56
#define BUFSIZE				(11*512)
#define SKIPPED				2
#define BYTES_NEEDED		719500
#define InstallName			"SnackZone"

#define Prgname				"HD-Install"
#define	Version				"2"
#define Revision			"15"
#define Date				"14.4.1993"
#define Autor				"René Straub"

#define VersionInit	"$VER:"

extern	struct	IntuitionBase	*IntuitionBase;
extern  struct  GfxBase			*GfxBase;
extern	struct	Library			*DiskfontBase;

		LONG					NewPanel[];

		char					InstallPrg[];

static	struct	Process			*ProcessBase;
static	struct	Screen			*myscreen;
static	struct	Panel			*p;
static	struct	RastPort		*rp;
static	struct	MsgPort			*port;
static	struct	Window			*window;
static	struct	TextFont		*font;

static	APTR					oldwindow;
static	BPTR					destlock,
								newdir,
								currdir=0;

static	LONG					BytesCopied;
static  SHORT					Cursor,
								PrgPos,
								QuitFlag,
								Left,	
								Top,
								Right,
								Bottom,
								Balken1Top,
								Balken2Top,
								FontHeight,
								TitleBar;

static	char					temp[1024],
								path[256],
								ReplaceFlag,
								*dirname;

char VersionString[] = VersionInit " " Prgname " " Version "." Revision" (" Date ") by " Autor;

static	USHORT	colors[4]= { 0x0AAA,0x0000,0x0FFF,0x068C };

static struct TextAttr nf = {
	(STRPTR)"topaz.font",8,0,0
};

#ifdef SCREEN

static WORD MyPens[1] = { -1 };

static struct TagItem MyTags[] =
{
	SA_Pens,&MyPens,
	TAG_END,0
};

struct ExtNewScreen ns =
{
	 0,0, 640, STDSCREENHEIGHT,2, 0,1, HIRES, CUSTOMSCREEN|NS_EXTENDED,
	 &nf,"Deluxe HardDisk Installation " Version "." Revision" (" Date "), NULL, NULL, (void *)&MyTags
};

#endif

char	VerString[] = "$VER: Deluxe-Install 2.06 by Rene Straub\n";

void	myexit(LONG);

void	ICls(void);
void	IPrint(char *);
void	IAbbruch(void);

BYTE	CheckSys(void);
ULONG	DiskFree(char *);
ULONG	FileLength(char *);

BYTE	ICopyLow(char *, char *);
BYTE	IMkDirLow(char *);
BYTE	IDirCopy(void);
BYTE	IMkDir(void);
BYTE	ICopy(void);
void	IDiskChange(void);

void	GetArgument(char *);
void	GetCommand(char *);

void __stdargs __main(char *argline)
{
	struct IntuiMessage *msg;

	IntuitionBase=(struct IntuitionBase *)OpenLibrary("intuition.library",0L);
	GfxBase=(struct GfxBase *)OpenLibrary("graphics.library",0L);

	ProcessBase = (struct Process *)FindTask(NULL);
/*
	DiskfontBase=OpenLibrary("diskfont.library",0L);
	if(!DiskfontBase)
	{
		ITShowRequest("Can't open 'diskfont.library'",0,"  _Ok  ",REQF_POSDEFAULT);
		myexit(10);
	}
*/
	font=OpenFont(&nf);
	if(!font || (font !=0 && font->tf_YSize !=8))
	{
/*
		if(!(font=OpenDiskFont(&nf)))
		{
*/
			ITShowRequest("Can't open topaz.font 8",0,"  _Ok  ",REQF_POSDEFAULT);
			myexit(10);	
/*
		}	
*/
	}

#ifdef SCREEN
	myscreen=OpenScreen(&ns);
	if(!myscreen)
	{
		ITShowRequest("Can't open screen",0,"  _Ok  ",REQF_POSDEFAULT);
		myexit(10);
	}

	LoadRGB4(&(myscreen->ViewPort),colors,4);
#elseif
	myscreen = NULL;
#endif

	if(!(p=ITCreatePanel(myscreen,font,NewPanel)))
	{
		ITShowRequest("Can't open Panel",0,"  _Ok  ",REQF_POSDEFAULT);
		myexit(10);
	}

	rp					      = p->RPort;
	port					  = p->Window->UserPort;
	ProcessBase->pr_WindowPtr = p->Window;

	FontHeight	= 9;
	TitleBar	= p->Window->WScreen->BarHeight+1;
	Left		= 12;
	Top			= TitleBar+4;
	Right		= 474;
	Bottom		= Top+98;
	Balken1Top  = Bottom+12;
	Balken2Top  = Bottom+26;

	ICls();
	IPrint("             ----------------------------\n"
		   "             Deluxe HardDisk Installation\n"
		   "               (C) 1992-93 René Straub\n"
		   "             ----------------------------\n");

	if(CheckSys())			/* Wurde von HD gebootet ? */
	{
		QuitFlag = FALSE;

		do
		{
			WaitPort(port); 
			msg=(struct IntuiMessage *)GetMsg(port);
		
			msg=ITFilterIMsg(p,msg);
			if((void *)(msg)==(void *)(-1))		QuitFlag = TRUE;
			else
			{
				if(msg)		ReplyMsg((struct Message *)msg);
			}
		}
		while(!QuitFlag);
	}

	myexit(0);
}

void myexit(LONG error)
{
	ProcessBase->pr_WindowPtr = 0;

	if(currdir)
	{
		CurrentDir(currdir);							/* Altes CurrentDir */
		UnLock(newdir);
	}
	if(p)				ITFreePanel(p);					/* Clear Panel */
	if(font)			CloseFont(font);				/* Close Font */
	if(myscreen)		CloseScreen(myscreen);			/* Close Screen */

//	if(DiskfontBase)	CloseLibrary(DiskfontBase);		/* Close DiskFontLib */

	if(IntuitionBase)	CloseLibrary((struct Library *)IntuitionBase);
	if(GfxBase)			CloseLibrary(GfxBase);

	exit(error);
}

LONG MainExit(void)
{
	QuitFlag = TRUE;
	return TRUE;
}

BYTE AbortCheck(void)
{
	struct	IntuiMessage *msg;

	msg=(struct IntuiMessage *)GetMsg(port);
	if(msg)
	{	
		msg=ITFilterIMsg(p,msg);
		if((void *)(msg)==(void *)(-1))		QuitFlag = TRUE;
		else
		{
			if(msg)		ReplyMsg((struct Message *)msg);
		}
		if(QuitFlag)	
		{
			QuitFlag = FALSE;		/* Sonst exit im Hauptprogram */
			if(ITShowRequest("Soll die Installation abgebrochen werden","  _Ja  "," _Nein ",REQF_POSDEFAULT))
			{
				return TRUE;
			}
		}
	}
	return FALSE;
}

LONG Start(void)
{
	struct	ITObject *itobj;
	struct	ITButton *itbut;
	BPTR 	dir;
	ULONG	free;
	SHORT	f,endflag;
	BYTE 	ret;
	char	cmdline[128];

	dir = ProcessBase->pr_CurrentDir;				/* CurrentDir retten */
	path[0] = '\0';
	BytesCopied = 0;
	ReplaceFlag = FALSE;

	ICls();
	IPrint("\n" InstallName " HardDisk Installation\n-------------------------------\n");

	itbut        = (struct ITButton *)ITFindObject(p,4);
	strcpy(itbut->Text,"Abbruch");
	ITRefreshObject(p,4);

	itobj        = ITFindObject(p,3);
	itobj->Flags |= ITF_DISABLED;
	ITRefreshObject(p,3);

	if(dirname=ITFileRequest("Zielverzeichnis auswählen"," OK ",path,NULL,0))
	{
		destlock = Lock(path,ACCESS_READ);		/* Test ob Verzeichnis auch existiert */
		if(!destlock)
		{
			sprintf(temp,"Kann '%s' nicht finden !",path);
			IPrint(temp);
			IAbbruch();
			return TRUE;
		}
		else
		{
			UnLock(destlock);		/* Lock freigeben */

			f=0;
			while(path[f++] != 0)
			{
				if(path[f]==':' && path[f+1] != 0)	/* Kommt nach dem : noch was */
				{
					sprintf(temp,"%s/",path);		/* Slash anhängen */
					strcpy(path,temp);				/* und wieder nach Path kopieren */
					break;
				}
			};
		
			f = strlen(path);
			if(path[f-2]=='/' && path[f-1]=='/')	path[f-1] = '\0';	/* Doppeltes "//" herausnehmen */

			sprintf(temp,"%s"InstallName,path);

			if(!(ITShowRequest("Soll "InstallName " nach '%s'\n"
						       "installiert werden ?","  _Ja  "," _Nein ",REQF_POSDEFAULT,temp)))

			{											/* Sicherheitsabfrage */
				IPrint("Installation abgebrochen\n\0");
				goto end;
			}


			free = DiskFree(path);

			if(free < BYTES_NEEDED)
			{
				ITShowRequest("Auf dem Laufwerk '%s' ist nicht genügend Platz !\n"
							  "Es werden mindestens %ld KByte benötigt.\n"
							  "Verfügbar sind %ld KByte.",0,"  _Ok  ",REQF_POSDEFAULT, path, BYTES_NEEDED/1024, free/1024);
				goto end;			/* Abbrechen */
			}

			sprintf(temp,"Verfügbare Kapazität auf dem Ziellaufwerk\n");
			IPrint(temp);
			sprintf(temp,"Vor der Installation  : %ld KByte\n"
						 "Nach der Installation : %ld KByte\n",free/1024,(free-BYTES_NEEDED)/1024);
			IPrint(temp);

			sprintf(temp,"Erzeuge Schublade '%s'\n",InstallName);
	/*		IPrint(temp);	*/

			ICopyLow("Game.info","%s" InstallName ".info");

			sprintf(temp,"%s"InstallName,path);
			strcpy(path,temp);					/* InstallName einfügen */
			IMkDirLow(path);					/* ZielVerzeichnis erzeugen */

			PrgPos	= 0;						/* ProgrammCounter */
			endflag	= FALSE;					/* AbbruchFlag */

			while(!endflag)						/* Ende -> */
			{
				GetCommand(cmdline);			/* Kommando lesen */

				switch(cmdline[0])
				{
					case 'C':					/* Copy */
						ret = ICopy();
						break;

					case 'M':					/* MakeDir */
						ret = IMkDir();
						break;
						
					case 'S':					/* DiskChange */
						IDiskChange();
						break;

					case 'D':					/* DirCopy */
						ret = IDirCopy();
						break;

					case 'E':					/* Ende */
						IPrint("\nInstallation beendet\n");
						endflag = TRUE;
						break;

					default:					/* Hhhmmm */
						IPrint("\nUnknown Command\n");
						endflag = TRUE;
						break;
				}
				if(!ret)						/* Gab's einen Fehler */
				{
					IAbbruch();					/* Meldung */
					endflag = TRUE;				/* und weg */
				}
				if(AbortCheck())
				{
					IAbbruch();
					endflag = TRUE;				/* Abort durch User */
				}
			}
		}
	}
	else	
	{
		IAbbruch();
	}
end:;
	strcpy(itbut->Text,"Ende");
	ITRefreshObject(p,4);
	itobj->Flags &= ~ITF_DISABLED;
	ITRefreshObject(p,3);

	CurrentDir(dir);

	return TRUE;
}

#ifdef fdskjhfjds
/*****************************************************************************
* Der ExistsRequester                                                        *
******************************************************************************/

#define MAXTEXTLENGTH 200		/* Maximale Länge einer Textzeile */

struct MyIText
{
	struct IntuiText ShadowIText;
	struct IntuiText IText;
	char Text[MAXTEXTLENGTH];
};

short Button;

short ExistsRequest(char *text)
{
	struct	MyIText		itext;
	struct	MyIText		*iptr;
	struct	IntuiMessage *mymsg;
	struct	RastPort	*myrp;
	struct	MsgPort		*myport;
	struct	Panel		*mypanel;
	short	endflag;
	short	height;
	char	*dptr;

	if(ReplaceFlag)		return TRUE;
	Button = FALSE;
	
	height = 18;
	iptr = &itext;

//	printf("String '%s'\n",text);

	do
	{
		iptr->IText.NextText=AllocMem(sizeof(*iptr),MEMF_CLEAR);
		if(!(iptr=(struct MyIText *)iptr->IText.NextText)) break;
		iptr->IText.LeftEdge       = 18;
		iptr->IText.TopEdge        = height;
		iptr->IText.FrontPen       = 1;

		iptr->IText.IText=iptr->ShadowIText.IText=dptr=iptr->Text;

		while((*dptr=*text) > '\n') {dptr++; text++;} *dptr=0;

		height+=FontHeight;

		iptr->ShadowIText.IText=0;
	}
	while(*text++);

	mypanel=ITCreatePanel(myscreen,0,Request1);
	if(mypanel)
	{
		myrp	= mypanel->RPort;
		myport	= mypanel->Window->UserPort;
		endflag = FALSE;

		PrintIText(myrp,itext.IText.NextText,0,0);

		Move(myrp,30,20);
		Text(myrp,text,strlen(text));

		do
		{
			WaitPort(myport); 
			mymsg=(struct IntuiMessage *)GetMsg(myport);
		
			mymsg=ITFilterIMsg(mypanel,mymsg);
			if((void *)(mymsg)==(void *)(-1))	endflag = TRUE;
			else
			{
				if(mymsg)	ReplyMsg((struct Message *)mymsg);
			}
		}
		while(!endflag);

		ITFreePanel(mypanel);					/* Clear Panel */
	}
	for(iptr=(struct MyIText *)itext.IText.NextText; iptr;)
	{
		register struct MyIText *temp=iptr;
		iptr = (struct MyIText *)iptr->IText.NextText;
		FreeMem(temp,sizeof(*temp));
	}

	return Button;
}

LONG ButtonJa(void)
{
	Button = TRUE;
	return 0;
}

LONG ButtonNein(void)
{
	Button = FALSE;
	return 0;
}

LONG ButtonAlle(void)
{
	Button		= TRUE;
	ReplaceFlag = TRUE;
	return 0;
}
#endif

/*****************************************************************************
* Ab hier folgen die TextRoutinen                                            *
******************************************************************************/

void ICls(void)
{
	SetAPen(rp,0);
	RectFill(rp,Left,Top,Right,Bottom);
	Cursor = Top+FontHeight-1;
}

void IText(char *text)
{
	if(Cursor>(Bottom))
	{
		SetBPen(rp,0);
		ScrollRaster(rp,0,FontHeight,Left,Top+1,Right,Bottom+1);
		Cursor-=9;
	}
	SetAPen(rp,1);
	Move(rp,16,Cursor);
	Text(rp,text,strlen(text));

	Cursor+=FontHeight;
}

void IPrint(char *text)
{
	SHORT i,j,oldj,oldi;
	char linebuffer[256];

	i=j=0;

	while(text[i] != '\0')
	{
		if(text[i] == '\n')
		{
			linebuffer[j] = '\0';
			IText(linebuffer);
			j   = 0;
			i++;
		}								/* Carriage Return */
		if(j > MAXWIDTH)				/* Zeile zu lang */
		{
			oldj = j;				
			oldi = i;					/* Pos merken */

			while(text[--i] != ' ')		/* Letztes Space suchen */
			{
				j--;
				if(text[i]=='\n')		/* Keines gefunden */
				{
					j = oldj;
					i = oldi;
					break;
				}
			}
			linebuffer[j] = '\0';
			IText(linebuffer);
			j = 0;						/* Zeilenanfang */
		}								/* Line too long */
		linebuffer[j++] = text[i++];	/* Copy char */
	}
	linebuffer[j] = '\0';
	IText(linebuffer);
}

void IAbbruch(void)
{
	IPrint("Installation abgebrochen !!!");
}

/*****************************************************************************
* Ab hier folgen die Routinen für den KommandoHandler                        *
******************************************************************************/

void GetCommand(char *STR1)
{
	short n;
	short end;
	char c;	

	end = FALSE;
	n = 0;

	while(InstallPrg[PrgPos++] != '@');			/* # suchen */

	while(!end)
	{
		c = InstallPrg[PrgPos++];	

		switch(c)
		{
			case '\n':
				end = TRUE;
				break;

			case ' ':
				end = TRUE;
				break;				
		}
		STR1[n++] = c;
	}
	STR1[n] = '\0';
}

void GetArgument(char *STR1)
{
	short n;

	n = 0;

	while(InstallPrg[PrgPos++] != '(');		/* ' suchen */

	while(InstallPrg[PrgPos] != ')')
	{
		STR1[n++] = InstallPrg[PrgPos++];
	};
	STR1[n] = '\0';
}

/*****************************************************************************
* Hilfsroutinen für Diskette                                                 *
******************************************************************************/

void DiskInfo(char *filename, ULONG *free, ULONG *prot, ULONG *num)
{
	struct	InfoData *id;
	BPTR	lk,oldlk,newlk;
	BYTE	volume;
	char	volname[32];
	short	i,j;

	i = j = 0;
	*free = 0;
	*prot = 0;
	volume = FALSE;

	do
	{
		if(filename[i]==':')
		{
			do
			{
				volname[j]=filename[j];
			}
			while(filename[j++]!=':');
			volname[j]=0;
			volume = TRUE;
		}
	}
	while(filename[i++]);

	if(id=(struct InfoData *)AllocMem(sizeof(struct InfoData),0))
	{
		if(volume)	lk=Lock(volname,ACCESS_READ);	/* Lock auf Volume */
		else		lk=Lock(InstallName,ACCESS_READ);	/* Lock auf CurrentDir */

		if(lk)
		{
			newlk = lk;
			do
			{
				oldlk=newlk;
				newlk=ParentDir(oldlk);
			} while(newlk);

			Info(oldlk,id);
			UnLock(lk);
		
			*free = (id->id_NumBlocks-id->id_NumBlocksUsed)*id->id_BytesPerBlock;
			*num  = id->id_NumBlocks*id->id_BytesPerBlock;
			*prot = id->id_DiskState;
		}
		FreeMem(id,sizeof(struct InfoData));
	}
}

BYTE Schreibschutz(char *name)
{
	ULONG dummy,prot;

	DiskInfo(name,&dummy,&prot,&dummy);
	if(prot == ID_VALIDATED)	return FALSE;
	else						return TRUE;
}

ULONG DiskFree(char *name)
{
	ULONG free,dummy;

	DiskInfo(name,&free,&dummy,&dummy);
	return free;
}

ULONG DiskSize(char *name)
{
	ULONG num,dummy;

	DiskInfo(name,&dummy,&dummy,&num);
	return num;
}

ULONG FileLength(char *name)
{
	BPTR	fh;
	ULONG	len;

	if(fh=Open(name,MODE_OLDFILE))
	{
		Seek(fh,0,OFFSET_CURRENT);				/* An Anfang */
		Seek(fh,0,OFFSET_END);					/* Ans Ende seeken */
		len = Seek(fh,0,OFFSET_CURRENT);		/* Position holen = Länge */
		Close(fh);

		return len;
	}
	return 0;
}

/*****************************************************************************
* Ab hier folgen die eigentlichen KopierRoutinen                             *
******************************************************************************/

BYTE IDirCopy(void)
{
	struct	FileInfoBlock *fib;
	BPTR	lock;
	char	source[256],dest[256],dirname[256];
	BYTE	ret;

	ret	= FALSE;

	GetArgument(dirname);
	lock = Lock(dirname,ACCESS_READ);
	if(lock)
	{
		fib = AllocMem(sizeof(struct FileInfoBlock),MEMF_PUBLIC);
		if(fib)
		{
			if(Examine(lock,fib))
			{
				while(ExNext(lock,fib)!=0)
				{
					sprintf(source,"%s/%s",dirname,fib->fib_FileName); 	/* Source mit Pfad */
					sprintf(dest,"%%s/%s",source); 						/* Destination */
					ICopyLow(source, dest);
					if(AbortCheck())	break;			/* User Abort */
				};
		
				if(IoErr() == ERROR_NO_MORE_ENTRIES)
						ret = TRUE;						/* Alles I.O. */
			}
			FreeMem(fib,(sizeof(struct FileInfoBlock)));
		}
		else
		{
			sprintf(temp,"Kann %ld Bytes Speicher nicht reservieren",BUFSIZE);
			IPrint(temp);
		}
		UnLock(lock);
	}
	else
	{
		sprintf(temp,"Kann Verzeichnis '%s' nicht finden",dirname);
		IPrint(temp);
	}
	return ret;
}

BYTE IMkDir(void)
{
	char temp2[256];
	char name[256];
	BYTE ret;

	GetArgument(temp2);
	sprintf(name,temp2,path);	/* Zielverzeichnis in Destination einfügen */

	ret = IMkDirLow(name);
	return ret;
}

BYTE IMkDirLow(char *dirname)
{
	LONG error;
	BPTR lock;

	lock = CreateDir(dirname);
	if(!lock)
	{
		error = IoErr();
		if(error == ERROR_OBJECT_EXISTS)
		{
			return TRUE;
		}
		else
		{
			sprintf(temp,"Kann Verzeichnis '%s' nicht erstellen",dirname);
			IPrint(temp);
			return FALSE;
		}
	}
	else
	{
		sprintf(temp,"Erstelle Verzeichnis '%s'",dirname);
		IPrint(temp);
		UnLock(lock);
	}
	return TRUE;
}

BYTE ICopy(void)
{
	char	source[256],dest[256];

	GetArgument(source);
	GetArgument(dest);

	return ICopyLow(source, dest);
}

BYTE ICopyLow(char *source, char *dest)
{
	APTR	mem;
	ULONG	len;
	ULONG	xpos,numx;
	BPTR	sfile,dfile;
	BYTE	ret;
	long	rlen;
	char	temp2[256];

	ret = FALSE;
	sprintf(temp2,dest,path);			/* Zielverzeichnis in Destination einfügen */

	SetAPen(rp,1);
	RectFill(rp,12,Balken1Top,474-12,Balken1Top+7);

	sfile = Open(source,MODE_OLDFILE);
	if(sfile)
	{
/*
		if(dfile = Open(temp2,MODE_OLDFILE))
		{
			Close(dfile);

			ExistsRequest("Ja aber Hallo");

			if(!(ITShowRequest("Datei '%s' existiert bereits.\n"
						       "Soll sie überschrieben werden ?",
							   "  _Ja  "," _Nein ",REQF_WINDOWSNAP,temp2)))
			{
				sprintf(temp,"Datei '%s' wurde übersprungen",source);
				IPrint(temp);

				return TRUE;
			}
		}
*/
		sprintf(temp,"Kopiere '%s'",source);
		IPrint(temp);

		dfile = Open(temp2,MODE_NEWFILE);
		if(dfile)
		{
			mem = AllocMem(BUFSIZE,MEMF_PUBLIC|MEMF_CLEAR);
			if(mem)
			{
				len = FileLength(source);
				numx = 0;

				while((rlen=Read(sfile,mem,BUFSIZE)) >0)
				{
					if(Write(dfile,mem,rlen) != rlen)
					{
						sprintf(temp,"Schreibfehler in File '%s'",temp2);
						IPrint(temp);
						Close(sfile);
						Close(dfile);
						FreeMem(mem,BUFSIZE);
						
						return FALSE;
					}
					BytesCopied += rlen;

					if(len/BUFSIZE > 0)		xpos = (474-12) * numx / (len/BUFSIZE);	/* Schrittweite */
					else					xpos = 474-12;
					numx++;

					SetAPen(rp,1);
					RectFill(rp,12,Balken1Top,12+xpos,Balken1Top+7);
					SetAPen(rp,0);
					RectFill(rp,12+xpos,Balken1Top,474,Balken1Top+7);	/* Kopierbalken zeichnen */

					xpos = 462 * BytesCopied / BYTES_NEEDED;
					if(xpos > 462)		xpos=462;
					SetAPen(rp,1);
					RectFill(rp,12,Balken2Top,12+xpos,Balken2Top+7);
					SetAPen(rp,0);
					RectFill(rp,12+xpos,Balken2Top,474,Balken2Top+7);	/* Kopierbalken zeichnen */

//					printf("Bytes %ld\n",BytesCopied);
				}

				if(!rlen)
				{
					SetAPen(rp,1);
					RectFill(rp,12,Balken1Top,474,Balken1Top+7);		/* Kopierbalken füllen */
					ret = TRUE; 										/* File einwandfrei kopiert */
				}
				else
				{
					sprintf(temp,"Lesefehler in File '%s'",source);
					IPrint(temp);
				}
				FreeMem(mem,BUFSIZE);
			}
			else
			{
				sprintf(temp,"Kann %ld Bytes Speicher nicht reservieren",BUFSIZE);
				IPrint(temp);
			}
			Close(dfile);
		}
		else
		{
			sprintf(temp,"Kann Ziel-File '%s' nicht öffnen",temp2);
			IPrint(temp);
		}
		Close(sfile);
	}
	else
	{
		sprintf(temp,"Kann Source-File '%s' nicht öffnen",source);
		IPrint(temp);
	}
	return ret;
}

void IDiskChange(void)
{
	BPTR	fh;
	short	abbruch;
	char	searchfile[256],diskname[256],STR1[256],STR2[256];

	abbruch = FALSE;

	GetArgument(diskname);
	GetArgument(searchfile);

	STR2[0] = diskname[9];
	STR2[1] = 0;

	do
	{
		ProcessBase->pr_WindowPtr = (void *)-1;			/* Keine Requester bitte */

		fh=Open(searchfile,MODE_OLDFILE);
		if(!fh)											/* File nicht da */
		{
			ProcessBase->pr_WindowPtr = p->Window;		/* Requester wieder an */
			ITShowRequest("Bitte die Diskette\n"
						  "'" InstallName "%s'\n einlegen",0,"  _Ok  ",REQF_POSDEFAULT,STR2);
		}
		else
		{
			Close(fh);
			sprintf(STR1,"\nWechsle zu Disk '%s'\n",diskname);
			IPrint(STR1);

			newdir  = Lock(diskname,ACCESS_READ);
			if(!currdir)
			{
		/*		UnLock(currdir);	*/
				currdir = CurrentDir(newdir);
			}
			else
			{
				CurrentDir(newdir);
			}
			abbruch = TRUE;
		}
	}
	while(!abbruch);

	ProcessBase->pr_WindowPtr = p->Window;		/* Requester wieder an */
}

BYTE CheckSys(void)
{
	BPTR lock;

	lock = Lock("SYS:Game/SnackZone",ACCESS_READ);
	if(lock)
	{
		UnLock(lock);

		ITShowRequest("WARNUNG\n"
					  "Die Installation von " InstallName " kann nicht\n"
					  "direkt von Diskette aus erfolgen.\n"
					  "Starten Sie Ihr System von Festplatte\n"
					  "und rufen Sie '" Prgname "' erneut auf.\n",
					  0,"  _Ok  ",REQF_POSDEFAULT);

		return FALSE;
	}
	else
		return TRUE;
}

LONG NewPanel[]=
{
	WINDOW		(ITF_HCENTER|ITF_VCENTER,-1,11,480,165,ACTIVATE|WINDOWDRAG|WINDOWCLOSE|WINDOWDEPTH,
				 "DeluxeInstall " Version "." Revision " (" Date ")")
 	 BEVELBOX	(ITF_RELWIDTH|ITF_RELHEIGHT,0,0,0,0)
	 ENDBOX

	 BEVELBOX	(BBF_RECESSED|BBF_BACKFILL,4,3,472,104)
	 ENDBOX

	 BEVELBOX	(BBF_RAISED|BBF_BACKFILL,4,112,472,12)
	 ENDBOX

	 BEVELBOX	(BBF_RAISED|BBF_BACKFILL,4,126,472,12)
	 ENDBOX

	 BUTTON		(3,ITF_RELBOTTOM ,4 ,-2,210,"Installation beginnen",Start)
	 BUTTON		(4,ITF_RELRIGHT|ITF_RELBOTTOM,-4,-2,80," Ende ",MainExit)
 	ITAG_END
};

/*
LONG Request1[]=
{
	WINDOW		(ITF_HCENTER|ITF_VCENTER,-1,11,400,60,ACTIVATE|WINDOWDRAG|WINDOWCLOSE|WINDOWDEPTH,"DeluxeInstall ") // Version "." Revision" (" Date "))
 	 BEVELBOX	(BBF_CHECKFILL|ITF_RELWIDTH|ITF_RELHEIGHT,0,0,0,0)
	 ENDBOX

	 BEVELBOX	(BBF_RECESSED|BBF_BACKFILL|ITF_RELWIDTH|ITF_RELHEIGHT,4,2,-8,-18)
	 ENDBOX

	 BUTTON		(1,ITF_RELBOTTOM,4,-2,64,"Ja",ButtonJa)
	 BUTTON		(2,ITF_RELBOTTOM,168,-2,64, "Nein",ButtonNein)
	 BUTTON		(3,ITF_RELBOTTOM,332,-2,64, "Alle",ButtonAlle)

	ITAG_END
};
*/

char InstallPrg[] =
{
	"@Copy      (libs/arp.library)     (libs:arp.library)"

	"@MkDir     (%s/Game)"
	"@Copy      (Game.info)            (%s/Game.info)"

	"@DirCopy   (Game)"

	"@Ende"
};

