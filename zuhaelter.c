#include "myexec.h"
#include "select.h"
#include "main.h"
#include "id.h"
#include "panel.h"
#include "drawbob.h"
#include "sound.h"

extern	APTR	ZuhaMove;
extern	APTR	ZuhaAnim;
extern	APTR	HundFliehtMove,HundFliehtAnim;
extern	APTR	ZuhaFliehtMove,ZuhaFliehtAnim;
extern	APTR	FliehKatze;

static	struct	SelectObject ZuhaSelect1;

#define	ZUHAELTERGRENZE	(200)

/**** Die Routinen für den Hund ************************************************/

void __regargs HundHandler(struct Bob *bob, LONG value)
{
	if((ElementList[el_Hund].flag == Solved))
	{
		if(!Random(30))	StartFX(10);
	}
	else
	{
		if(!Random(70))	StartFX(10);
	}

	if((ElementList[el_Hund].flag == Solved) && (bob->bob_AnimPrg != &HundFliehtAnim))
	{
		RemBob(bob);
	}
}

void __regargs HundCollision(struct Bob *mybob, struct Bob *enemybob)
{
	struct Bob *katzebob;

	if(ElementList[el_Hund].flag == Solved)	return;

	if(ElementList[el_Katze].flag == Solved)	// Katze dabei ??
	{
		// JAJA -> Hund flieht (und Zuhälter !!)
	
		SetMovePrg(enemybob,&HundFliehtMove,1,6);
		SetAnimPrg(enemybob,&HundFliehtAnim,2);

		katzebob = AddBob(&FliehKatze);
		katzebob->bob_X = enemybob->bob_X-20;

		ChangeEmotion(5);
		RemoveGadget(Katze);

		RightLock 					= FALSE;
		ElementList[el_Hund].flag	= Solved;

		enemybob->bob_CollHandler = NULL;
	}
	else
	{
		// NEIN

		ChangeEnergy(-10);
		ChangeEmotion(-3);

		enemybob->bob_CollHandler = NULL;
	}
}

/**** Die Routinen für den Zuhälter *******************************************/

void __regargs ZuhaHandler(struct Bob *bob, LONG value)
{
	if((ElementList[el_Hund].flag != Solved) && (MyBob->bob_X > ZUHAELTERGRENZE))
		RightLock = TRUE;
	else
		RightLock = FALSE;

	// Zuhälter läuft Hund hinterher

	if((ElementList[el_Hund].flag == Solved) && (ElementList[el_Zuhaelter].flag != Solved ))
	{
		SetAnimPrg(bob,&ZuhaFliehtAnim,4);
		SetMovePrg(bob,&ZuhaFliehtMove,1,14);

		ElementList[el_Zuhaelter].flag = Solved;
	}

	if((ElementList[el_Zuhaelter].flag == Solved) && (bob->bob_AnimPrg != &ZuhaFliehtAnim))
	{
		RemBob(bob);		// Bob removen wenn Auftrag erledigt
	}
}


void __regargs ZuhaCollision(struct Bob *mybob, struct Bob *enemybob)
{
	if(ElementList[el_Zuhaelter].flag != Talked && ElementList[el_Katze].flag != Solved)
	{
		Select(&ZuhaSelect1,enemybob);

		ElementList[el_Zuhaelter].flag = Talked;

		enemybob->bob_CollHandler = NULL;
	}
}

static struct SelectObject ZuhaSelect1 =
{
	0,0,
	0,-55,

	"Mein Kampfdackel\n"
	"fuerchtet keine\n"
	"Gefahr und laesst\n"
	"niemanden vorbei.",
};
