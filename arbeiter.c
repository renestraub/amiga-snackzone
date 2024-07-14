#include "myexec.h"
#include "select.h"
#include "main.h"
#include "id.h"
#include "panel.h"
#include "drawbob.h"
#include "sound.h"

struct SelectObject ArbeiterSelect11,ArbeiterSelect12;
struct SelectObject ArbeiterSelect20,ArbeiterSelect21;

void __regargs ArbeiterCollision(struct Bob *mybob, struct Bob *enemybob)
{
	// Werkzeug zurückgebracht -> Auftrag erledigt -> Kein Dialog mehr
	
	if(ElementList[el_Werkzeug].flag == Solved)	return;

	if(ElementList[el_Werkzeug].flag == Taken)
	{
		if((ElementList[el_Werkzeug].timer1+10*60*50) > GameTimer)
		{	// Rechtzeitig
			Select(&ArbeiterSelect20,enemybob);
			ChangeEmotion(5);
		}
		else
		{	// Zu spaet
			Select(&ArbeiterSelect21,enemybob);
			ChangeEmotion(-10);
		}
		RemoveGadget(Werkzeugkiste);
		ElementList[el_Werkzeug].flag = Solved;
		enemybob->bob_CollHandler = NULL;

		return;
	}

	// Werkzeug abgeschwatzt -> Kein Dialog mehr

	if(ElementList[el_Arbeiter].flag == Solved)	return;

	// Achtung nur DEBUG !!!!!!!!
	// ElementList[el_Eistee].flag = Solved;

	// Hat er denn den Eistee dabei ???????

	if(ElementList[el_Eistee].flag == Solved)
	{
		Select(&ArbeiterSelect12,enemybob);
		RemoveGadget(Lipton);
		enemybob->bob_CollHandler = NULL;
	}
	else
	{
		Select(&ArbeiterSelect11,enemybob);
		enemybob->bob_CollHandler = NULL;
	}
}

void GetWerkzeug(struct Bob *bob)
{
	ElementList[el_Arbeiter].flag = Solved;

	AddGadget(Werkzeugkiste);
	ElementList[el_Werkzeug].flag   = Taken;
	ElementList[el_Werkzeug].timer1 = GameTimer;	// Zeit merken wann Werkzeug erhalten
}

struct SelectObject ArbeiterSelect20 =
{
	0,0,
	0,-55,

	"Das ging ja schnell -\n"
	"schoenen Tag noch."
};

struct SelectObject ArbeiterSelect21 =
{
	0,0,
	0,-55,

	"Wegen Dir konnte ich\n"
	"die ganze Zeit nicht\n"
	"arbeiten! Ich bin\n"
	"richtig sauer!\n"
	"Verschwinde schnell!"
};


struct SelectObject ArbeiterSelect3 =
{
	0,0,
	0,-55,

	"Kein Problem -\n"
	"nach meiner Pause\n"
	"brauch ich sie aber\n"
	"wieder, sonst gibt\n"
	"es Aerger..",

	0,0,"Ok, alles klar",NULL,&GetWerkzeug,
	0,0,"Na dann doch\n"
		"lieber nicht\n",NULL,NULL
};

struct SelectObject ArbeiterSelect2 =
{
	0,0,
	0,-55,

	"Danke sehr\n"
	"Jetzt mach ich\n"
	"erst mal Pause",

	0,0,"Bitte, gern\n"
		"geschehen!",NULL,NULL,
	0,0,"Bitte sehr ...\n"
		"uebrigens ...\n"
		"ich wuerde mir\n"
		"gerne fuer 10\n"
		"Minuten die Werk-\n"
		"zeugkiste leihen",&ArbeiterSelect3
};

struct SelectObject ArbeiterSelect11 =
{
	-8,3,
	0,-55,

	"Puh-ist das heiss!\n"
	"Ich wuenschte,ich\n"
	"ich haette ein\n"
	"kuehles Getraenk.",

	0,0,"Ja man hat's nicht\n"
		"leicht",NULL,NULL,
	0,0,"Mecker nicht und\n"
		"arbeite! Mir geht\n"
		"es auch nicht besser!\n",NULL,NULL,
};

struct SelectObject ArbeiterSelect12 =
{
	-8,3,
	0,-55,

	"Puh-ist das heiss!\n"
	"Ich wuenschte,ich\n"
	"ich haette ein\n"
	"kuehles Getraenk.",

	0,0,"Ja man hat's nicht\n"
		"leicht",NULL,NULL,
	0,0,"Mecker nicht und\n"
		"arbeite! Mir geht\n"
		"es auch nicht besser!",NULL,NULL,
	0,0,"Hier nimm diese Dose\n"
		"Liptonice. Das\n"
		"wird dich abkuehlen.",&ArbeiterSelect2,NULL

};
