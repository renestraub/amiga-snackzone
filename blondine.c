#include "myexec.h"
#include "select.h"
#include "main.h"
#include "id.h"
#include "panel.h"
#include "drawbob.h"
#include "sound.h"

static struct SelectObject BlondiSelect10,BlondiSelect11,BlondiSelect12;
static struct SelectObject BlondiSelect20;
static struct SelectObject BlondiSelect50,BlondiSelect51,BlondiSelect52;
static struct SelectObject BlondiSelect60,BlondiSelect61,BlondiSelect62;

static char Text1[] = { "Ja, diese wunder-\n"
						"schoenen Ohrringe" };
static char Text2[] = { "Diese goldene\n"
						"Halskette" };
static char Text3[] = { "Diese brandneue\n"
						"Single" };
static char Text4[] = { "Die edelste\n"
						"Strumphose" };
static char Text5[] = { "Nein nichts\n" };


static void CheckRoutine(struct Bob *bob)
{
	short i;

	i = 0;

	if(ElementList[el_Ohrring].flag == Solved)			i++;
	if(ElementList[el_Halskette].flag == Solved)		i++;
	if(ElementList[el_Schallplatte].flag == Solved)		i++;
	if(ElementList[el_Strumpfhose].flag == Solved)		i++;

	if(i<3)		Select(&BlondiSelect60,bob);
	else
	{
		if(i==4)
		{
			Select(&BlondiSelect62,bob);
			ChangeEmotion(10);

			bob->bob_CollHandler = NULL;
			ElementList[el_Blondine2].flag = Solved;

			AddGadget(Rollerskates);		
			ElementList[el_Rollerskates].flag = Taken;
			StartFX(2);
		}
		else
		{
			Select(&BlondiSelect61,bob);
			ChangeEmotion(10);
		}
	}
}

static void GetRollschuhe(struct Bob *bob)
{
	short i;

	i = 0;

	if(ElementList[el_Ohrring].flag == Solved)		i++;
	if(ElementList[el_Halskette].flag == Solved)	i++;
	if(ElementList[el_Schallplatte].flag == Solved)	i++;
	if(ElementList[el_Strumpfhose].flag == Solved)	i++;

	if(i<3)		Select(&BlondiSelect60,bob);
	else
	{
		Select(&BlondiSelect61,bob);
		ChangeEmotion(10);

		bob->bob_CollHandler = NULL;
		ElementList[el_Blondine2].flag = Solved;

		AddGadget(Rollerskates);		
		ElementList[el_Rollerskates].flag = Taken;

		StartFX(2);
	}
}


static void GibOhrring(struct Bob *bob)
{
	ElementList[el_Ohrring].flag = Solved;
	RemoveGadget(Ohrring);

	StartFX(3);

	Select(&BlondiSelect50,bob);
}

static void GibHalskette(struct Bob *bob)
{
	ElementList[el_Halskette].flag = Solved;
	RemoveGadget(Halskette);

	StartFX(3);

	Select(&BlondiSelect51,bob);
}

static void GibSingle(struct Bob *bob)
{
	ElementList[el_Schallplatte].flag = Solved;
	RemoveGadget(Schallplatte);

	StartFX(3);

	Select(&BlondiSelect50,bob);
}

static void GibStrumpfhose(struct Bob *bob)
{
	ElementList[el_Strumpfhose].flag = Solved;
	RemoveGadget(Strumpfhose);

	StartFX(3);

	Select(&BlondiSelect52,bob);
}


static void SolvedBlondi1(struct Bob *bob)
{
	ElementList[el_Blondine1].flag = Solved;
}


void __regargs BlondiHandler(struct Bob *bob, LONG value)
{
	if(ElementList[el_Blondine2].flag == Solved && bob->bob_CollHandler != NULL)
	{
		RemBob(bob);
	}
}


void __regargs BlondiCollision(struct Bob *mybob, struct Bob *enemybob)
{
	short i;

	if(ElementList[el_Blondine1].flag != Solved)
	{
		i = EmotionObject.value;

		if(i<20)
		{
			Select(&BlondiSelect10,enemybob);
			enemybob->bob_CollHandler = NULL;
			return;
		}
		if(i<30)	
		{
			Select(&BlondiSelect11,enemybob);
			enemybob->bob_CollHandler = NULL;
			return;
		}
		if(i>=30)
		{
			Select(&BlondiSelect12,enemybob);
			enemybob->bob_CollHandler = NULL;
			return;
		}
	}
	
	if(ElementList[el_Blondine2].flag != Solved)
	{
		i = 0;

		if(ElementList[el_Ohrring].flag == Taken)
		{
			BlondiSelect20.SelectText[i].text		= Text1;
			BlondiSelect20.SelectText[i++].handler	= &GibOhrring;
		}

		if(ElementList[el_Halskette].flag == Taken)
		{
			BlondiSelect20.SelectText[i].text		= Text2;
			BlondiSelect20.SelectText[i++].handler	= &GibHalskette;
		}

		if(ElementList[el_Schallplatte].flag == Taken)
		{
			BlondiSelect20.SelectText[i].text		= Text3;
			BlondiSelect20.SelectText[i++].handler	= &GibSingle;
		}

		if(ElementList[el_Strumpfhose].flag == Taken)
		{
			BlondiSelect20.SelectText[i].text		= Text4;
			BlondiSelect20.SelectText[i++].handler	= &GibStrumpfhose;
		}

		BlondiSelect20.SelectText[i].text			= Text5;
		BlondiSelect20.SelectText[i++].handler		= NULL;

		BlondiSelect20.SelectText[i].text			= NULL;

		Select(&BlondiSelect20,enemybob);
		enemybob->bob_CollHandler = NULL;
	}
}


static struct SelectObject BlondiSelect62 =
{
	0,0,
	0,-46,

	"Hier Lukas\n"
	"nimm meine\n"
	"Roller-Skates."
};

static struct SelectObject BlondiSelect60 =
{
	0,0,
	0,-46,

	"Heute nicht\n"
	"vielleicht\n"
	"spaeter mal."
};

static struct SelectObject BlondiSelect61 =
{
	0,0,
	0,-46,

	"\nJa, gerne"
};

static struct SelectObject BlondiSelect50 =
{
	0,0,
	0,-46,
	"Toll - ein\n"
	"schoenes\n"
	"Geschenk.",

	0,0,"Willst du heute\n"
		"Abend mit mir\n"
		"ins Kino gehen?",NULL,&CheckRoutine,
	0,0,"Sehen wir uns\n"
		"nachher im Uno-X?",NULL,&CheckRoutine,
	0,0,"Darf ich deine\n"
		"Roller Skates\n"
		"haben?",NULL,&GetRollschuhe
};

static struct SelectObject BlondiSelect51 =
{
	0,0,
	0,-46,
	"Danke lieb\n"
	"von Dir.",

	0,0,"Willst du heute\n"
		"Abend mit mir\n"
		"ins Kino gehen?",NULL,&CheckRoutine,
	0,0,"Sehen wir uns\n"
		"nachher im Uno-X?",NULL,&CheckRoutine,
	0,0,"Darf ich deine\n"
		"Roller Skates\n"
		"haben?",NULL,&GetRollschuhe
};

static struct SelectObject BlondiSelect52 =
{
	0,0,
	0,-46,
	"Oh...\n"
	"Danke sehr",

	0,0,"Willst du heute\n"
		"Abend mit mir\n"
		"ins Kino gehen?",NULL,&CheckRoutine,
	0,0,"Sehen wir uns\n"
		"nachher im Uno-X?",NULL,&CheckRoutine,
	0,0,"Darf ich deine\n"
		"Roller Skates\n"
		"haben?",NULL,&GetRollschuhe
};


static struct SelectObject BlondiSelect30 =
{
	0,0,
	0,-46,
	"\nHallo"
};

static struct SelectObject BlondiSelect20 =
{
	0,0,
	0,-46,
	"Hallo Jaeger der\n"
	"verlorenen Pro-\n"
	"duktionsunterlagen!\n"
	"Ich sehe Du moechtest\n"
	"mir etwas schenken.",

	0,0,NULL,NULL,NULL,
	0,0,NULL,NULL,NULL,
	0,0,NULL,NULL,NULL,
	0,0,NULL,NULL,NULL,
	0,0,NULL,NULL,NULL,
};

static struct SelectObject BlondiSelect18 =
{
	0,0,
	0,-46,

	"Ich gehe nachher\n"
	"in die Disco\n"
	"Uno-X in der\n"
	"5th Avenue.\n"
	"Tschuess !"
};

static struct SelectObject BlondiSelect17 =
{
	0,0,
	0,-46,

	"Vielleicht,\n"
	"aber ich muss\n"
	"jetzt weiter-\n"
	"laufen."
};

static struct SelectObject BlondiSelect16 =
{
	0,0,
	0,-46,

	"Du bist witzig...\n"
	"..und ich bin im\n"
	"im Auftrag des CIA\n"
	"unterwegs.",

	0,0,"Doch-ehrlich. Meine\n"
		"Aufgabe ist,die Bi-Fi\n"
		"Roll Produktions-\n"
		"unterlagen wiederzu-\n"
		"beschaffen.",&BlondiSelect17,&SolvedBlondi1,

	0,0,"War nur ein Scherz.\n"
		"Ich bin neu hier in\n"
		"der Stadt. Weisst Du\n"
		"wo man hier Abends\n"
		"hingehen kann ?\n",&BlondiSelect18,&SolvedBlondi1,
};

static struct SelectObject BlondiSelect15 =
{
	0,0,
	0,-46,

	"Das sagen sie\n"
	"alle. Faellt Dir\n"
	"keine bessere\n"
	"Anmache ein ?"
};

static struct SelectObject BlondiSelect14 =
{
	0,0,
	0,-46,

	"\nWie langweilig"
};

static struct SelectObject BlondiSelect13 =
{
	-4,0,
	0,-46,

	"Ich habe Dich\n"
	"hier noch nie\n"
	"gesehen. Was\n"
	"machst Du hier?",

	0,0,"Ich bin Fotograf und\n"
		"suche Fotomodelle",&BlondiSelect15,NULL,
	0,0,"Ich bin mit einem\n"
		"wichtigen Auftrag\n"
		"unterwegs",&BlondiSelect16,NULL,
	0,0,"Spazierengehen",&BlondiSelect14,NULL
};


static struct SelectObject BlondiSelect10 =
{
	0,0,
	0,-46,
	NULL,

	0,0,"Hallo",NULL,NULL,
	0,0,"Hi!",NULL,NULL,
	0,0,"Guten Morgen",NULL,NULL,
};


static struct SelectObject BlondiSelect11 =
{
	0,0,
	0,-46,
	NULL,

	0,0,"Hallo",&BlondiSelect30,NULL,
	0,0,"Hi!",&BlondiSelect30,NULL,
	0,0,"Guten Morgen",&BlondiSelect30,NULL,
};

static struct SelectObject BlondiSelect12 =
{
	0,0,
	0,-46,
	"\nHallo",

	0,0,"Hallo!",&BlondiSelect13,NULL,
	0,0,"Hi schnelle\n"
		"Schoenheit\n",&BlondiSelect13,NULL,
};


