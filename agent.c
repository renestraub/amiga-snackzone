#include "myexec.h"
#include "select.h"
#include "main.h"
#include "id.h"
#include "panel.h"
#include "drawbob.h"
#include "sound.h"
#include "joystick.h"

struct SelectObject AgentSelect10,
					VMannSelect10;

// Wird bei Kollision aufgerufen

void __regargs AgentHandler(struct Bob *bob, LONG l)
{
	if(ElementList[el_Agent].flag && bob->bob_CollHandler)
	{
		RemBob(bob);
	}
}

void __regargs VerbMannHandler(struct Bob *bob, LONG l)
{
	if(ElementList[el_VMann].flag && bob->bob_CollHandler)
	{
		RemBob(bob);
	}
}


void __regargs VerbMannCollision(struct Bob *mybob, struct Bob *enemybob)
{
	short	oldmoney;

	if(ElementList[el_Agent].flag)
	{
		oldmoney = MoneyObject.value;

		Select(&VMannSelect10,enemybob);

		enemybob->bob_CollHandler = NULL;

		if(oldmoney != MoneyObject.value)
			ShowMoney();
	}
}

void __regargs AgentCollision(struct Bob *mybob, struct Bob *enemybob)
{
	Select(&AgentSelect10,enemybob);

	enemybob->bob_CollHandler = NULL;
}


void __regargs TakeIt(struct Bob *bob)
{
	ElementList[el_Agent].flag = Taken;
	AddGadget(Dokument);
	StartFX(2);
}

void __regargs GetIt(struct Bob *bob)
{
	ElementList[el_VMann].flag = Solved;
	RemoveGadget(Dokument);
	ChangeEnergy(5);
	ChangeEmotion(3);
	ChangeMoney(10);
	StartFX(3);
}

struct SelectObject VMannSelect12 =
{
	0,10,
	0,-45,

	"Danke, das haben\n"
	"Sie gut gemacht!"
};

struct SelectObject VMannSelect11 =
{
	0,10,
	0,-45,

	"Okay - haben\n"
	"Sie den Koffer?",

	0,0,"Ja hier!",&VMannSelect12,&GetIt,
	0,0,"welchen Koffer?",NULL,NULL,
	0,0,"Nein",NULL,NULL,
};

struct SelectObject VMannSelect10 =
{
	0,10,
	0,-45,

	"Parole:\n"
	"Bi-Fi..\n",

	0,0,"...Roll",NULL,NULL,
	0,0,"...Minisalami",NULL,NULL,
	0,0,"...Light",NULL,NULL,
	0,0,"...hat Biss",&VMannSelect11,NULL,
	0,0,"Weitergehen",NULL,NULL,
};

struct SelectObject AgentSelect15 =
{
	0,10,
	0,-45,

	"Die Parole lautet:\n"
	">>Bi-Fi hat Biss<<"
};

struct SelectObject AgentSelect14 =
{
	0,10,
	0,-45,
	"Bringen Sie einen\n"
	"Aktenkoffer zu\n"
	"meinem Kollegen\n"
	"in der 5th Avenue.",

	0,0,"Okay! Wird\n"
		"sofort erledigt.",&AgentSelect15,&TakeIt,
	0,0,"Lieber nicht.\n",NULL,NULL,
};

struct SelectObject AgentSelect13 =
{
	0,10,
	0,-45,
	"Noch nicht!\n"
	"Aber ich habe einen\n"
	"wichtigen Auftrag\n"
	"fuer Sie.",

	0,0,"Das ist mir\n"
		"nicht geheuer.",NULL,NULL,
	0,0,"Einen Auftrag?\n",&AgentSelect14,NULL,
};

struct SelectObject AgentSelect12 =
{
	0,10,
	0,-45,
	"Es ist ihr Gluecks-\n"
	"tag! Ich habe einen\n"
	"Auftrag fuer Sie.",

	0,0,"Das ist mir\n"
		"nicht geheuer.",NULL,NULL,
	0,0,"Einen Auftrag?\n",&AgentSelect14,NULL,
};

struct SelectObject AgentSelect11 =
{
	0,10,
	0,-45,
	"Ja -\n"
	"genau!\n",

	0,0,"Kennen wir uns?",&AgentSelect13,NULL,
	0,0,"Was ist los ?",&AgentSelect12,NULL,
};


struct SelectObject AgentSelect10 =
{
	0,10,
	0,-45,
	"Hey!\nPsst!",

	0,0,"Wer? ich?",&AgentSelect11,NULL,
	0,0,"WER? ICH?",&AgentSelect11,NULL,
	0,0,"weitergehen",NULL,NULL
};

