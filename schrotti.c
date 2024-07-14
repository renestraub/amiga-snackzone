#include "myexec.h"
#include "select.h"
#include "main.h"
#include "id.h"
#include "panel.h"
#include "drawbob.h"

static	struct	SelectObject SchrottSelect1,
							 SchrottSelect2,
							 SchrottSelect4,
							 SchrottSelect5,
							 SchrottSelect52,
							 SchrottSelect6;

static short info;

void __regargs SchrottiHandler(struct Bob *bob, LONG value)
{
	if(ElementList[el_Schrotti].flag == Solved && bob->bob_CollHandler)
	{
		RemBob(bob);
	}
}

void __regargs SchrottiCollision(struct Bob *mybob, struct Bob *enemybob)
{
	if(ElementList[el_Rocker].flag != Talked)
	{
		Select(&SchrottSelect1,enemybob);
	}
	else
	{
		Select(&SchrottSelect2,enemybob);
	}
	enemybob->bob_CollHandler = NULL;
}

void __regargs Get17(struct Bob *bob)
{
	info = 17;
}

void __regargs Get19(struct Bob *bob)
{
	info = 19;
}

void __regargs Get20(struct Bob *bob)
{
	info = 20;
}

void __regargs AnswerSilber(struct Bob *bob)
{
	if( info == 19 )
	{
		if(ElementList[el_Marsgestein].flag == Taken)
		{
			Select(&SchrottSelect52,bob);
		}
		else
		{
			Select(&SchrottSelect5,bob);
		}
	}
	else
	{
		Select(&SchrottSelect4,bob);
		AddGadget(Feder);

		ElementList[el_FederInfo].flag = 2;		// Silber aber nicht 19"
	}
}

void __regargs AnswerChrom(struct Bob *bob)
{
	Select(&SchrottSelect4,bob);
	AddGadget(Feder);

	ElementList[el_FederInfo].flag = 1;		// Chrom
}

void __regargs SolvedFeder(struct Bob *bob)
{
	ElementList[el_Feder].flag = Taken;
	ElementList[el_Marsgestein].flag = Solved;
	ElementList[el_Schrotti].flag = Solved;

	RemoveGadget(Marsgestein);
	AddGadget(Feder);

	ElementList[el_FederInfo].flag = 3;		// Silber 19"
}

static struct SelectObject SchrottSelect6 =
{
	0,0,
	0,-8,

	"Oh was fuer ein\n"
	"wunderschoenes\n"
	"Stueck !"
};

static struct SelectObject SchrottSelect52 =
{
	0,0,
	0,-8,

	"Eine Kolbenrueck-\n"
	"hohlfeder 19 Zoll\n"
	"versilbert wollen\n"
	"Sie? Das ist ein\n"
	"seltenes Modell!\n"
	"Das wird teuer..\n"
	"Das macht 137 ECU.",

	0,0,"So viel hab ich nicht",NULL,NULL,
	0,0,"Darf ich ihnen diesen\n"
		"exklusiven Briefbe-\n"
		"schwerer anbieten.Es\n"
		"handelt sich dabei um\n"
		"Original Merkurgestein",&SchrottSelect6,&SolvedFeder
};

static struct SelectObject SchrottSelect5 =
{
	0,0,
	0,-8,

	"Eine Kolbenrueck-\n"
	"hohlfeder 19 Zoll\n"
	"versilbert wollen\n"
	"Sie? Das ist ein\n"
	"seltenes Modell!\n"
	"Das wird teuer..\n"
	"Das macht 137 ECU.",

	0,0,"So viel hab ich nicht",NULL,NULL,
};

static struct SelectObject SchrottSelect4 =
{
	0,0,
	0,-8,

	"Kein Problem der\n"
	"Herr. Die kann\n"
	"ihnen umsonst\n"
	"mitgeben.",
};

static struct SelectObject SchrottSelect3 =
{
	0,0,
	0,-8,

	"Verchromt\n"
	"oder\n"
	"versilbert?",

	0,0,"Keine Ahnung",NULL,NULL,
	0,0,"Verchromt?!",NULL,&AnswerChrom,
	0,0,"Versilbert?!",NULL,&AnswerSilber
};

static struct SelectObject SchrottSelect2 =
{
	0,0,
	0,-8,

	"Guten Tag mein\n"
	"Herr, wir haben\n"
	"Schrott und\n"
	"Ersatzteile\n"
	"vom Feinsten.\n"
	"Womit kann ich\n"
	"Ihnen helfen ?",

	0,0,"Mit einer 17 Zoll\n"
		"Kolbenrueckholfeder",&SchrottSelect3,&Get17,
	0,0,"Mit einer 19 Zoll\n"
		"Kolbenrueckholfeder",&SchrottSelect3,&Get19,
	0,0,"Mit einer 20 Zoll\n"
		"Kolbenrueckholfeder",&SchrottSelect3,&Get20
};

static struct SelectObject SchrottSelect1 =
{
	0,0,
	0,-8,

	"Guten Tag mein\n"
	"Herr, wir haben\n"
	"Schrott und\n"
	"Ersatzteile\n"
	"vom Feinsten.\n"
	"Womit kann ich\n"
	"Ihnen helfen ?",

	0,0,"Danke, ich\n"
		"brauche keine\n"
		"Ersatzteile.",NULL,NULL
};
