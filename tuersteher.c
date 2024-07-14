#include "myexec.h"
#include "select.h"
#include "main.h"
#include "id.h"
#include "panel.h"
#include "drawbob.h"
#include "joystick.h"
#include "disco.h"

struct SelectObject TuerSelect1;


// Wird bei Kollision aufgerufen

void __regargs TuersteherCollision(struct Bob *mybob, struct Bob *enemybob)
{
	struct	JoyInfo joy;

	PfeilFlag = TRUE;

	GetJoy(&joy);
	if(joy.ydir == JOY_UP)
	{
		if(ElementList[el_Kondom].flag == Taken)
		{
			DiscoGegenwart();
		}
		else
		{
			Select(&TuerSelect1,enemybob);
			ElementList[el_Tuersteher].flag = Talked;
		}
	}
}

struct SelectObject TuerSelect4 =
{
	0,0,
	0,-55,

	"Mann bist du\n"
	"schwer von Begriff!\n"
	"Kein Einlass ohne\n"
	"Gummi, so einfach\n"
	"ist das."
};

struct SelectObject TuerSelect3 =
{
	0,0,
	0,-55,

	"Ist doch klar!\n"
	"Ohne Schutz laeuft\n"
	"nichts mehr.",

	0,0,"Aha-verstehe!",NULL,NULL,
	0,0,"Du sprichst in\n"
		"Raetseln. Red\n"
		"doch mal Klartext",&TuerSelect4,NULL
};

struct SelectObject TuerSelect2 =
{
	0,0,
	0,-55,
	"Ist doch klar\n"
	"Mann!\n"
	"Ohne laeuft\n"
	"hier nichts!",

	0,0,"Ohne WAS\nlaeuft nichts!",&TuerSelect3,NULL,
	0,0,"Ich versteh\nnur Bahnhof!",&TuerSelect3,NULL
};

struct SelectObject TuerSelect1 =
{
	0,0,
	0,-55,

	"Halt mein Freund!\n"
	"Hast Du nicht\n"
	"etwas vergessen ?",

	0,0,"Wie bitte was?",&TuerSelect2,NULL,
	0,0,"Vergessen? Ich\n"
		"vergess mich\n"
		"gleich!",NULL,NULL,
};

