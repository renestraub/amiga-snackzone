#include "myexec.h"
#include "select.h"
#include "main.h"
#include "id.h"
#include "panel.h"
#include "drawbob.h"
#include "sound.h"
#include "joystick.h"

struct SelectObject KinderSelect10,KinderSelect20;


void __regargs SchnullerHandler(struct Bob *mybob, LONG l)
{
	if(ElementList[el_Schnuller].flag == Solved)
	{
		RemBob(mybob);
	}
}

// Wird bei Kollision aufgerufen

void __regargs SchnullerCollision(struct Bob *mybob, struct Bob *enemybob)
{
	ElementList[el_Schnuller].flag = Solved;

	AddGadget(Schnuller);

	RemBob(enemybob);

	StartFX(2);
}


void __regargs KinderwagenCollision(struct Bob *mybob, struct Bob *enemybob)
{
	struct JoyInfo joy;
	short	oldmoney;

	if(ElementList[el_Kinderwagen].flag == Solved)	return;

	PfeilFlag = TRUE;

	GetJoy(&joy);
	if(joy.ydir != JOY_UP)	return;

	if(ElementList[el_Schnuller].flag == Solved)
	{
		ClearPfeil();

		oldmoney = MoneyObject.value;

		Select(&KinderSelect20,enemybob);

		if(oldmoney != MoneyObject.value)
			ShowMoney();

	}
	else
	{
		ClearPfeil();

		Select(&KinderSelect10,enemybob);
	}
//	enemybob->bob_CollHandler = 0;
}

static void Belohnung(struct Bob *bob)
{
	ChangeEmotion(6);
	ChangeMoney(5);
	StartFX(2);

	RemoveGadget(Schnuller);

	ElementList[el_Kinderwagen].flag = Solved;
}

static void Strafe(struct Bob *bob)
{
	ChangeEmotion(-3);

//	RemoveGadget(Schnuller);
	ElementList[el_Kinderwagen].flag = Solved;
}

struct SelectObject KinderSelect22 =
{
	0,0,
	-15,-50,

	"WAAAEEEHHHHHH\n\n"
	"Du solltest besser\n"
	"auf deine Manieren\n"
	"achten! Halunke\n"
	"Verschwinde hier!"
};

struct SelectObject KinderSelect21 =
{
	0,0,
	-15,-50,

	"Nuckel! - Saug!\n\n"
	"Oh mein Held! Sie\n"
	"haben den Schnuller\n"
	"wiedergebracht.Hier\n"
	"haben Sie 5 Taler\n"
	"fuer Ihr Spar-\n"
	"schwein.\n"
};

struct SelectObject KinderSelect20 =
{
	0,0,
	0,-35,
	"Waeh!!!\n",

	0,0,"Hier Dein Schnuller\n"
		"mein suesser kleiner\n"
		"Schreihals.",&KinderSelect21,&Belohnung,

	0,0,"Ich hab den Schnuller\n"
		"gefunden. Sie kriegen\n"
		"ihn fuer 2 Taler.",&KinderSelect22,&Strafe,
};


struct SelectObject KinderSelect12 =
{
	0,0,
	-15,-50,

	"Oh gerne, wir haben\n"
	"ihn irgendwo auf der\n"
	"Koenigsalle oder der\n"
	"BakerStreet verloren."
};

struct SelectObject KinderSelect11 =
{
	0,0,
	-16,-50,
	"Wir haben\n"
	"unseren\n"
	"Schnuller\n"
	"verloren.",

	0,0,"Kann ich\n"
		"suchen helfen?",&KinderSelect12,NULL,
	0,0,"So ein Pech!\n",NULL,NULL,
};

struct SelectObject KinderSelect10 =
{
	0,10,
	0,-35,
	"Waeh!!\n"
	"Waeh!!!",

	0,0,"Warum schreit\n"
		"denn der Kleine\n"
		"so laut ?",&KinderSelect11,NULL,
	0,0,"Muss der den so\n"
		"schreien ? Das\n"
		"haelt ja kein\n"
		"Mensch aus.",NULL,NULL,
	0,0,"Weitergehen.\n",NULL,NULL
};

