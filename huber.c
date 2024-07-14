#include "myexec.h"
#include "select.h"
#include "main.h"
#include "id.h"
#include "panel.h"
#include "drawbob.h"
#include "joystick.h"
#include "sound.h"

extern	APTR	HuberDrehAnim, HuberAnim;

static struct SelectObject HuberSelect10,HuberSelect20,HuberSelect21;

void __regargs HuberHandler(struct Bob *mybob, LONG l)
{
	if(ElementList[el_Honighuber].flag == Solved)
	{
		RemBob(mybob);
	}
}

void __regargs HuberCollision(struct Bob *mybob, struct Bob *enemybob)
{
	struct	JoyInfo joy;

	if(ElementList[el_Honighuber].flag == Solved)	return;

	PfeilFlag = TRUE;

	GetJoy(&joy);
	if(joy.ydir == JOY_UP)
	{
		if(enemybob->bob_AnimPrg != &HuberDrehAnim)
		{
			SetAnimPrg(enemybob,&HuberDrehAnim,3);
		}
	}
}

void __regargs HuberCollision2(struct Bob *mybob, struct Bob *enemybob)
{
	ClearPfeil();

	Select(&HuberSelect10,enemybob);
	enemybob->bob_CollHandler	= NULL;
	SetAnimPrg(enemybob,&HuberAnim,7);
}

static void SelectHonig(struct Bob *bob)
{
//	ElementList[el_Werkzeug].flag = Taken;

	if(ElementList[el_Werkzeug].flag == Taken)
	{
		Select(&HuberSelect21,bob);
	}
	else
	{
		Select(&HuberSelect20,bob);
	}
}

static void TakeHonig(struct Bob *bob)
{
	AddGadget(Honig);

	bob->bob_Handler				= NULL;
	ElementList[el_Honighuber].flag = Solved;
	StartFX(2);
}


static struct SelectObject HuberSelect23 =
{
	0,0,
	0,-60,

	"Nehmen Sie es\n"
	"doch trotzdem.\n"
	"Vielleicht\n"
	"koennen Sie es\n"
	"verschenken."
};

static struct SelectObject HuberSelect22 =
{
	0,0,
	0,-60,

	"Prima,das hilft\n"
	"mir weiter.Darf\n"
	"ich Ihnen zum\n"
	"Dank ein Glas\n"
	"Honig geben ?",

	0,0,"Ja gerne.",NULL,&TakeHonig,
	0,0,"Nein Danke,\n"
		"ich mag nichts\n"
		"suesses.",&HuberSelect23,&TakeHonig
};

static struct SelectObject HuberSelect21 =
{
	0,0,
	0,-60,

	"Danke nein,ich\n"
	"glaube,mir fehlt\n"
	"das noetige\n"
	"Werkzeug.",

	0,0,"OK Tschuess.",NULL,NULL,
	0,0,"Kein Problem\n"
		"Ich habe Werk-\n"
		"zeug dabei.",&HuberSelect22,NULL
};

static struct SelectObject HuberSelect20 =
{
	0,0,
	0,-60,

	"Danke nein,ich\n"
	"glaube,mir fehlt\n"
	"das noetige\n"
	"Werkzeug.",

	0,0,"OK Tschuess.",NULL,NULL
};

static struct SelectObject HuberSelect10 =
{
	0,0,
	0,-60,
	
	NULL,

	0,0,"Guten Tag\n"
		"Kann ich helfen?",NULL,&SelectHonig,
	0,0,"Weitergehen.\n",NULL,NULL
};
