#include "myexec.h"
#include "select.h"
#include "main.h"
#include "id.h"
#include "panel.h"
#include "drawbob.h"
#include "sound.h"

#define	WESPEGRENZE		275

extern	APTR	HonigTopf;
extern	APTR	WespeMove2;

void __regargs WespeHandler(struct Bob *bob, LONG value)
{
	LeftLock = FALSE;

	if(ElementList[el_Wespe].flag != Solved)
	{
		if(MyBob->bob_X < WESPEGRENZE)
		{
			LeftLock = TRUE;
		}
	}

	if(ElementList[el_Wespe].flag == Solved && bob->bob_CollHandler)
	{
		RemBob(bob);
	}
}


void __regargs WespeCollision(struct Bob *mybob, struct Bob *enemybob)
{
	struct Bob *topfbob;

	if(ElementList[el_Wespe].flag == Solved)	return;

//	ElementList[el_Honighuber].flag = Solved;

	if(ElementList[el_Honighuber].flag == Solved)
	{
		topfbob = AddBob(&HonigTopf);
		topfbob->bob_X = WESPEGRENZE-20;
		topfbob->bob_Y = 175;
		
		SetMovePrg(enemybob,&WespeMove2,2,1);
		enemybob->bob_X = topfbob->bob_X;
		enemybob->bob_Y = topfbob->bob_Y-10;

		ChangeEmotion(7);
		ElementList[el_Wespe].flag = Solved;

		StartFX(3);
	}
	else
	{
		ChangeEnergy(-10);
		ChangeEmotion(-5);
	}
	enemybob->bob_CollHandler = NULL;
}

