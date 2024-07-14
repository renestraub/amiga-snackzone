#include "myexec.h"
#include "gfx.h"
#include "drawbob.h"
#include "copper.h"
#include "scroll.h"
#include "panel.h"
#include "main.h"
#include "id.h"
#include "level.h"
#include "main.h"
#include "definitions.h"

#define NODEBUG

#define	PanelWidth	(320/8)
#define	PanelHeight	24
#define	PanelDepth	6
#define	PanelPlane	(PanelWidth*PanelHeight)

extern	struct	Bob	*MyBob;
extern	WORD 	LevelX;

void ChangeEnergy(WORD num);

static struct BitMap PanelBitmStr =
{
	PanelWidth,
	PanelHeight,
	0,
	PanelDepth,
	0,
	0,0,0,0,0,0,0,0
};

static struct BitMap FxPanelBitmStr =
{
	PanelWidth,
	PanelHeight,
	0,
	1,
	0,
	0,0,0,0,0,0,0,0
};

static struct NewWindow NewPanelWindow =
{
	0,0,
	PanelWidth*8,PanelHeight,
	1,0,
	WNF_NOBACKSAVE|WNF_BORDERLESS|WNF_FASTTEXT,
	DM_JAM,
	0,
	NULL
};

	#ifdef DEBUG

struct NumObject MemoryObject =
{
	id_NumObject,
	100,4,
	100,2,64,12,
	0,0,"%ld"
};

struct NumObject MemoryObject2 =
{
	id_NumObject,
	100,14,
	100,12,64,22,
	0,0,"%ld"
};
	#endif


struct NumObject MoneyObject =
{
	id_NumObject,
	10,4,
	10,2,64,12,
	0,0,"%ld"
};

struct RectObject EnergyObject =
{
	id_RectObject,
	218,3,
	100,4,
	0,0,-1
};

struct RectObject EmotionObject =
{
	id_RectObject,
	218,10,
	100,4,
	0,0,-1
};

struct RectObject SnackObject =
{
	id_RectObject,
	218,17,
	100,4,
	0,0,-1
};

struct RectObject SpeedObject =
{
	id_RectObject,
	102,6,
	144,12,
	0,0,-1
};

static struct IconObject Field1 =
{
	id_IconObject,
	12,21,
	Leerfeld,-1
};

static struct IconObject Field2 =
{
	id_IconObject,
	36,21,
	Leerfeld,-1
};

static struct IconObject Field3 =
{
	id_IconObject,
	60,21,
	Leerfeld,-1
};

static struct IconObject Field4 =
{
	id_IconObject,
	84,21,
	Leerfeld,-1
};

static struct IconObject Field5 =
{
	id_IconObject,
	108,21,
	Leerfeld,-1
};

static struct IconObject Field6 =
{
	id_IconObject,
	132,21,
	Leerfeld,-1
};

extern	APTR		PanelPtrs,
					PanelColors;
extern	APTR		NewPanelBob;

static	struct		Window		*PanelWindow;
static	struct		Window		*FxPanelWindow;
static	struct		Bob			*PanelBob;
		PLANEPTR	PanelBase;
		APTR		PanelBobBase;
		LONG		Time,
					GameTimer;
		WORD		Health,
					Energy;
		WORD		HealthIst,
					EnergyIst;
static	short		GadgetCnt;
static	BYTE		timer;

struct	ElementItem ElementList[NumElements];
struct	GadgetItem	GadgetList[NumGadgets];

/**** LowLevelDrawing ****************************************************************************/

void __regargs PrintRectObject(struct RectObject *obj)
{
	short value;

	if(obj->actvalue > obj->value)	obj->actvalue--;
	if(obj->actvalue < obj->value)	obj->actvalue++;

	if(obj->actvalue != obj->lastvalue)
	{
		obj->lastvalue = obj->actvalue;

		value = obj->actvalue;
		if(value > obj->w)	value = obj->w;
	
		SetAPen(FxPanelWindow,1);
		RectFill(FxPanelWindow,obj->x,obj->y,obj->w,obj->h);
		SetAPen(FxPanelWindow,0);
		RectFill(FxPanelWindow,obj->x,obj->y,value,obj->h);
	}
}

void __regargs PrintNumObject(struct NumObject *obj)
{
	BYTE oldpen;

	if(obj->value != obj->lastvalue)
	{
		obj->lastvalue = obj->value;

		oldpen = GetAPen(PanelWindow);
		SetAPen(PanelWindow,0);
		RectFill(PanelWindow,obj->x,obj->y,obj->w,obj->h);
		SetAPen(PanelWindow,oldpen);

		PrintAt(PanelWindow,obj->tx,obj->ty,obj->fmtstr,obj->value);
	}
}

void __regargs PrintIconObject(struct IconObject *obj)
{
	if(obj->bobnum != obj->lastbobnum)
	{
		obj->lastbobnum 	= obj->bobnum;

		PanelBob->bob_X		= obj->x;
		PanelBob->bob_Y		= obj->y;
		PanelBob->bob_Image = obj->bobnum;

		GetCustom();
		DrawOneBob(PanelBob, &PanelBitmStr);
	}
}


/**** Gadget Adding/Drawing etc. ***************************************************************/

short Offset,Timer;
short VisItem[6];

void __regargs AddGadget(short object)
{
	GadgetList[object].num++;
}

void __regargs RemoveGadget(short object)
{
	GadgetList[object].num--;
}

void __regargs ShowGadgets(void)
{
	short i,j;

	if(Timer++ != 10)	return;
	else				Timer = 0;

	for(i=0;i<6;i++)	VisItem[i] = Leerfeld;

	j = 0;

	for(i=Offset;i<NumGadgets;i++)
	{
		if(j == 6)	break;

		if(GadgetList[i].num > 0)	VisItem[j++] = i;
	}

	for(i=0;i<Offset;i++)
	{
		if(j == 6)	break;

		if(GadgetList[i].num > 0)	VisItem[j++] = i;
	}

	Field1.bobnum = VisItem[0];
	Field2.bobnum = VisItem[1];
	Field3.bobnum = VisItem[2];
	Field4.bobnum = VisItem[3];
	Field5.bobnum = VisItem[4];
	Field6.bobnum = VisItem[5];

	PrintIconObject(&Field1);
	PrintIconObject(&Field2);
	PrintIconObject(&Field3);
	PrintIconObject(&Field4);
	PrintIconObject(&Field5);
	PrintIconObject(&Field6);

	if(j>=6)
	{
		Offset++;
		if(Offset == NumGadgets)		Offset = 0;
	}
}

/**** Modifiy Panel Entries ******************************************************/

void __regargs ChangeMoney(WORD num)
{
	MoneyObject.value += num;
}

void __regargs ChangeEnergy(WORD num)
{
	EnergyObject.value += num;

	if(EnergyObject.value < 0)
	{
		EnergyObject.value = 0;

		EndFlag = OUT_OF_ENERGY;
	}
}

void __regargs ChangeEmotion(WORD num)
{
	EmotionObject.value += num;

	if(EmotionObject.value < 0)
	{
		EmotionObject.value = 0;
	}
}

void __regargs ChangeSnack(WORD num)
{
	SnackObject.value += num;

	if(SnackObject.value < 0)
	{
		SnackObject.value = 0;
	}
}

/**** Load & Initialize & Update ****************************************************/

void __regargs LoadPanel(void)
{
	PanelBase = AllocMem(5824+100);
	PanelBobBase = AllocMem(15290+100);

	ReadFile("Panel",PanelBase);
	ReadFile("PanelBobs",PanelBobBase);

	PanelBob	  = AddBob(&NewPanelBob);

	PanelWindow   = OpenWindow(&NewPanelWindow,&PanelBitmStr);
	FxPanelWindow = OpenWindow(&NewPanelWindow,&FxPanelBitmStr);
}

void __regargs SetPanel(void)
{
	SetBitmapPtrs(&PanelBitmStr,PanelBase,PanelDepth,PanelPlane);
	SetBitmapPtrs(&FxPanelBitmStr,PanelBase+(PanelPlane*(PanelDepth-1)),1,0);

	SetPointers(PanelBase,&PanelPtrs,PanelPlane,PanelDepth);
	SetColors(PanelBase+(PanelPlane*PanelDepth),&PanelColors,32);
}

void __regargs InvalidPanel(void)
{
	Timer					= 9;
	timer					= 0;

	MoneyObject.lastvalue	= -1;
	EnergyObject.lastvalue	= -1;
	EmotionObject.lastvalue	= -1;
	SnackObject.lastvalue	= -1;

	Field1.lastbobnum = -1;
	Field2.lastbobnum = -1;
	Field3.lastbobnum = -1;
	Field4.lastbobnum = -1;
	Field5.lastbobnum = -1;
	Field6.lastbobnum = -1;

	ShowGadgets();
}

void __regargs InitSkaterPanel(void)
{
	SpeedObject.value 		= 50;
	SpeedObject.lastvalue	= -1;
}

void __regargs InitPanel(void)
{
	InvalidPanel();

	MoneyObject.value 		= 20;

	EnergyObject.value		= 80;
	EnergyObject.actvalue	= 0;

	EmotionObject.value		= 80;
	EmotionObject.actvalue	= 0;

	SnackObject.value		= 50;
	SnackObject.actvalue	= 0;

	PrintRectObject(&EnergyObject);
	PrintRectObject(&EmotionObject);
	PrintRectObject(&SnackObject);

	ShowGadgets();
}

void __regargs UpDatePanel(void)
{
	switch(timer++)
	{
		case 0:
	#ifdef DEBUG
			MemoryObject.value = AvailMem();
			PrintNumObject(&MemoryObject);
			MemoryObject2.value = AvailFastMem();
			PrintNumObject(&MemoryObject2);
	#endif
			ShowGadgets();
			break;

		case 1:
			PrintRectObject(&EnergyObject);
			PrintRectObject(&EmotionObject);
			PrintRectObject(&SnackObject);
			timer = 0;
			break;

	}
}

void __regargs UpDateSkaterPanel(void)
{
	PrintRectObject(&SpeedObject);
}
