#include "myexec.h"
#include "select.h"
#include "main.h"
#include "id.h"
#include "panel.h"
#include "drawbob.h"
#include "sound.h"

extern	APTR	KatzeFliehtMove;
extern	APTR	KatzeFliehtAnim;

static struct SelectObject CatSelect1;

void __regargs CatHandler(struct Bob *bob, LONG value)
{
	if(ElementList[el_Katze].flag == Solved)
	{
		RemBob(bob);
	}
}

// Wird bei Kollision aufgerufen

void __regargs CatCollision(struct Bob *mybob, struct Bob *enemybob)
{
	if(ElementList[el_Katze].flag == Solved)	return;

	Select(&CatSelect1,enemybob);
}

void GetCat(struct Bob *bob)
{
	ElementList[el_Katze].flag = Solved;

	AddGadget(Katze);
	ChangeEmotion(5);
	RemBob(bob);

	StartFX(2);
}

void CatLeaves(struct Bob *bob)
{
	SetMovePrg(bob,&KatzeFliehtMove,1,12);
	SetAnimPrg(bob,&KatzeFliehtAnim,3);
}

static struct SelectObject CatSelect2 =
{
	0,0,
	0,-14,
	"Schnur\n"
	"rrrr..",

	0,0,"Weiter..",NULL,&CatLeaves,
	0,0,"Mitnehmen.",NULL,&GetCat,
};

static struct SelectObject CatSelect1 =
{
	0,0,
	0,-12,
	"Miau\nMiau",

	0,0,"Wau wau",NULL,&CatLeaves,
	0,0,"Miau",&CatSelect2,NULL,
	0,0,"Streicheln.",&CatSelect2,NULL,
	0,0,"Weiter..",NULL,&CatLeaves
};

