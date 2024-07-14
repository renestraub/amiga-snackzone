#include "MyExec.h"
#include "DrawBob.h"
#include "Gfx.h"
#include "Scroll.h"
#include "Copper.h"
#include "Blase.h"
#include "Level.h"
#include "Main.h"
#include "Definitions.h"
#include "UBahn.h"
#include "Panel.h"
#include "JoyStick.h"
#include "Select.h"

#include "leveldat.h"

extern		APTR HinweisBob;

struct		Level		*ActLevelPtr,
						*NextLevelPtr;
struct		LevelBob	*LEnemyListPtr,
						*REnemyListPtr;

PLANEPTR	PictureBase;
APTR		BobBase,
			CharBase,
			LevelBase,
			LevelFlags;

LONG		ScrSize;

WORD		SizeX,
			SizeY,
			PixelSizeX,
			PixelSizeY,
			LevelX,
			LastLevelX;

BYTE		GateFlag,			// TRUE wenn Bob im Bereich eines Gates ist
			HinweisFlag,		// TRUE wenn HinweisBob auf dem Bildschirm ist
			TimeZone,			// Gibt an ob wir in der Gegenwart oder der Zukunft sind
			LastTimeZone;

struct BitMap ViewBitmStr =
{
	ScrWidth,
	ScrHeight,
	0,
	ScrDepth,
	0,
	0,0,0,0,0,0,0,0
};

struct BitMap DrawBitmStr =
{
	ScrWidth,
	ScrHeight,
	0,
	ScrDepth,
	0,
	0,0,0,0,0,0,0,0
};

/************************************************************************************/

void SetUpPicture(struct BitMap *bm)
{
	WORD x,y,xofs;

	xofs = LevelX>>4;

	for(x=xofs;x<((ScrWidth/2)+xofs);x++)
	{
		for(y=0;y<(ScrHeight/16);y++)
		{
			DrawChar(bm,x,y);
		}
	}
}

void InitGame(void)
{
	short i;

	Level6Tab.LevelX = 0;
	Level6Tab.RonnyX = 100;

	ActLevelPtr = &Level6Tab;

	for(i=0;i<NumElements;i++)	ElementList[i].flag = 0;
	for(i=0;i<NumGadgets;i++)	GadgetList[i].num = 0;

	GameTimer = 0;
	TimeZone  = GEGENWART;
	LastTimeZone  = ZUKUNFT;

	PictureBase = AllocMem( (49950+100) * 2 );
	BobBase   = AllocMem( 97292+100 );
	CharBase  = AllocFastMem( 41190+100 );
	LevelBase = AllocFastMem( 1698+100 );

//	AddGadget(Ticket);
//	ElementList[el_Ticket].flag = Solved;
//	AddGadget(Videogamemuenze);
//	ElementList[el_Videogamemuenze].flag = Taken;
}

void FreeGame(void)
{
	FreeMem(PictureBase);
	FreeMem(BobBase);
	FreeMem(CharBase);
	FreeMem(LevelBase);
}

void LoadLevel(void)
{
	LevelFlags		= ActLevelPtr->Flags;
	LEnemyListPtr	= ActLevelPtr->EnemyLeft;
	REnemyListPtr	= ActLevelPtr->EnemyRight;

	CopyColorMap(ActLevelPtr->ColorMap);

	if(TimeZone != LastTimeZone)
	{
		LastTimeZone = TimeZone;

		ReadFile(ActLevelPtr->Char,CharBase);
		ReadFile(ActLevelPtr->Bobs,BobBase);
	}
	
	ReadFile(ActLevelPtr->Level,LevelBase);
}

void UnLoadLevel(void)
{
}

void SetUpLevel(void)
{
	SetBitmapPtrs(&ViewBitmStr,PictureBase,ScrDepth,Plane_SIZEOF);
	SetBitmapPtrs(&DrawBitmStr,PictureBase+ScrSize,ScrDepth,Plane_SIZEOF);
	SetUpPicture(&ViewBitmStr);
	SetUpPicture(&DrawBitmStr);
}

void CreateLevel(void)
{
	struct	LevelData *dataptr;

	dataptr		= (struct LevelData *)LevelBase;

	SizeX		= dataptr->XScr*dataptr->XChars;
	SizeY		= dataptr->YScr*dataptr->YChars;
	PixelSizeX	= SizeX<<4;
	PixelSizeY	= SizeY<<4;
	
	ScrSize     = Scr_SIZEOF + (SizeX-(ScrWidth>>1))*10;

	SetUpLevel();

	LastLevelX  = -1;
	HinweisFlag = FALSE;

	if(ElementList[el_Oma].flag == Talked)	ElementList[el_Oma].flag = 0;
}

void CheckGate(void)
{
	struct	JoyInfo	joy;
	struct	Gate	*gate;
	struct	Bob		*bob;
	short	xpos;

	gate = ActLevelPtr->GateWay;
	xpos = MyBob->bob_X;

	GateFlag   = FALSE;

	GetJoy(&joy);

	do
	{
		if((xpos > gate->X1) && (xpos < gate->X2))
		{
			PfeilFlag = TRUE;

			switch(gate->Flag)
			{
				case lgf_Gate:
					if(!HinweisFlag)
					{
						NextLevelPtr	 	 = gate->NewLevel;
						NextLevelPtr->LevelX = gate->LevelX;
						NextLevelPtr->RonnyX = gate->BobX;
						bob					 = AddBob(&HinweisBob);
						bob->bob_Image		 = NextLevelPtr->SchildBob;
						bob->bob_X			 = (gate->X1+gate->X2)>>1;
						HinweisFlag			 = TRUE;
					}
					if(joy.ydir)
					{
						EndFlag = CHANGE_LEVEL;
						return;
					}
					break;

				case lgf_Subway:
					if(joy.ydir)
					{
						Fahrkarte();
						EndFlag = CHANGE_LEVEL;
					}
					break;
			};
			GateFlag = TRUE;
			return;
		}

		gate = gate->NextGate;
		if(!gate)	return;
	}
	while(gate);
}
