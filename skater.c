#include "myexec.h"
#include "select.h"
#include "main.h"
#include "id.h"
#include "panel.h"
#include "drawbob.h"
#include "definitions.h"
#include "joystick.h"


extern	BYTE	__regargs SkaterGame(void);

static	struct	SelectObject SkaterSelect11,SkaterSelect12;
static	short	skateflag;

#define FUN		1
#define	REAL	2

// Wird bei Kollision aufgerufen

void __regargs SkaterCollision(struct Bob *mybob, struct Bob *enemybob)
{
	struct JoyInfo joy;
	short ret;

	skateflag = 0;
	PfeilFlag = TRUE;

	GetJoy(&joy);
	if(joy.ydir != JOY_UP)	return;

	ClearPfeil();

//	if(1)		// DEBUG
	if(ElementList[el_Rollerskates].flag == Taken)	// Hat er die Rollschuhe dabei ???
	{
		Select(&SkaterSelect11,enemybob);			// JA

		if(skateflag == REAL)
		{
			ChangeEnergy(-10);

			ret = SkaterGame();
		
		/* Achtung ab hier ist die BobListe ungültig !!! */

			if(ret == HERO_WINS)
			{
				ElementList[el_Videogamemuenze].flag = Taken;
				AddGadget(Videogamemuenze);
			}
		}	
		if(skateflag == FUN)
		{
			ChangeEnergy(-5);
			ret = SkaterGame();

		/* Achtung ab hier ist die BobListe ungültig !!! */

		}
	}
	else
	{
		Select(&SkaterSelect12,enemybob);			// Nein
	}
}

void __regargs RaceForFun(struct Bob *bob)
{
	skateflag = FUN;
}

void __regargs RaceReal(struct Bob *bob)
{
	skateflag = REAL;
}

static struct SelectObject SkaterSelect3 =
{
	0,0,
	-20,-45,

	"Schade Mann\n"
	"sonst waeren wir\n"
	"ein kleines\n"
	"Rennen gefahren."
};

static struct SelectObject SkaterSelect2 =
{
	0,0,
	0,-45,

	"Ich setze diese\n"
	"alte Muenze. Dein\n"
	"Einsatz ist ein\n"
	"Taler."
};

static struct SelectObject SkaterSelect11 =
{
	0,0,
	0,-45,
	"Yo man!\n"
	"kleines Rennen\n"
	"gefaellig ?",

	0,0,"Aehm,lieber nicht.",NULL,NULL,
	0,0,"Klar doch\n"
		"just for fun.",NULL,&RaceForFun,
	0,0,"Aber immer,\n"
		"was ist dein\n"
		"Einsatz ?",&SkaterSelect2,&RaceReal
};

static struct SelectObject SkaterSelect12 =
{
	0,10,
	0,-45,
	"Yo man!\n"
	"Wo sind deine\n"
	"Roller-Skates?",

	0,0,"Aeh? Roller Skates?\n"
		"Hab ich keine.",NULL,NULL,
	0,0,"Zu hause.",&SkaterSelect3,NULL,
	0,0,"In der Werkstatt.",&SkaterSelect3,NULL
};

