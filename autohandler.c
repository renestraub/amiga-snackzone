#include "myexec.h"
#include "select.h"
#include "main.h"
#include "panel.h"
#include "drawbob.h"
#include "sound.h"

extern	BYTE	AusweichFlag;

void __regargs FerrariLHandler(struct Bob *bob, LONG value)
{
	if(bob->bob_UserData > 0)	bob->bob_UserData--;
	else
	{
		if(bob->bob_X > -500)
		{
			bob->bob_X-=4;
		} else {
			bob->bob_UserData = Random(1000)+250;
			bob->bob_X = 2000;
			bob->bob_UserDataPtr = 0;
		}
	}
}

void __regargs FerrariRHandler(struct Bob *bob, LONG value)
{
	if(bob->bob_UserData > 0)	bob->bob_UserData--;
	else
	{
		if(bob->bob_X < 2000)
		{
			bob->bob_X+=4;
		} else {
			bob->bob_UserData = Random(1000)+250;
			bob->bob_X = -500;
			bob->bob_UserDataPtr = 0;
		}
	}
}

void __regargs FerrariColl(struct Bob *bob, struct Bob *enemybob)
{
	if(!enemybob->bob_UserDataPtr && !AusweichFlag)
	{
		enemybob->bob_UserDataPtr = (void *)(1);
	
		ChangeEnergy(-10);
		ChangeEmotion(-4);

		StartFX(1);
	}
}
