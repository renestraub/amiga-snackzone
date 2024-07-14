#include "myexec.h"
#include "select.h"
#include "main.h"
#include "id.h"
#include "panel.h"
#include "drawbob.h"

static	struct	SelectObject FremderSelect1;
static	struct	SelectObject FremderSelect2;

void __regargs FremderHandler(struct Bob *bob, LONG value)
{
	if(ElementList[el_Fremder].flag == Solved && bob->bob_CollHandler)
	{
		RemBob(bob);
	}
}

void __regargs FremderCollision(struct Bob *mybob, struct Bob *enemybob)
{
	if(ElementList[el_Fremder].flag == Solved)	return;
	
	ElementList[el_Foodmuseum].flag = Solved;

	if(ElementList[el_Foodmuseum].flag == Solved)
	{
		Select(&FremderSelect1,enemybob);
	}
	else
	{
		Select(&FremderSelect2,enemybob);
	}

	enemybob->bob_CollHandler = NULL;
}

static void SolvedFremder(struct Bob *bob)
{
	ElementList[el_Fremder].flag = Solved;
}



static struct SelectObject FremderSelect3 =
{
	0,0,
	0,-48,
	"Im Food-Museum werden\n"
	"Lebensmittel aus dem\n"
	"20.Jahrhundert aus-\n"
	"gestellt.Dort befinden\n"
	"sich auch Unterlagen\n"
	"ueber alte Rezepte und\n"
	"Herstellungsverfahren"
};

static struct SelectObject FremderSelect2 =
{
	0,0,
	0,-48,
	"Entschuldigen Sie\n"
	"Kennen Sie den\n"
	"Weg zum Food-\n"
	"Museum?",

	0,0,"Nein,tut mir leid",NULL,NULL,
	0,0,"Food Museum\n"
		"kenne ich nicht\n"
		"Bitte erzaehlen\n"
		"Sie mir mehr davon\n",&FremderSelect3,&SolvedFremder
};

static struct SelectObject FremderSelect1 =
{
	0,0,
	0,-48,
	"Entschuldigen Sie\n"
	"Kennen Sie den\n"
	"Weg zum Food-\n"
	"Museum?",

	0,0,"Nein,tut mir leid.",NULL,NULL,
	0,0,"Food Museum\n"
		"kenne ich nicht\n"
		"Bitte erzaehlen\n"
		"Sie mir mehr davon",&FremderSelect3,NULL,
	0,0,"Das Food-Museum be-\n"
		"findet sich am Ende\n"
		"des Dammtorwalls.",NULL,&SolvedFremder
};
