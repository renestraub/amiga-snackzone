#include "myexec.h"
#include "gfx.h"
#include "joystick.h"
#include "copper.h"
#include "main.h"
#include "level.h"
#include "enemy.h"
#include "sound.h"
#include "panel.h"
#include "main.h"
#include "definitions.h"

void __regargs StromGame(struct Bob *bob, struct Bob *enemybob)
{
	struct JoyInfo joy;
	int  (__asm *stromgame)(register __d0 int,
							register __a0 APTR,
							register __a1 APTR,
							register __a2 APTR,
							register __a6 APTR);

	int	result;

//	if(1)

	if(ElementList[el_Sokoban].flag == 5)			// Produktionsgeheimsnis erhalten
	{
		PfeilFlag = TRUE;

		GetJoy(&joy);
		if(joy.ydir != JOY_UP)	return;

		NoInt++;

		FadeOutCopper();
		StartSong(5);

		stromgame = LoadSeg("StromPrg");
		result = stromgame(1,PictureBase,&PictureBase[42000],&StartFX,MyExecBase);
		if(result == 1)
			EndFlag = GAME_WON;		// Yaeh that's it folks

		UnLoadSeg(stromgame);

		SetUpLevel();
		UpDateBobs();

		StartSong(2);
		SetCopperList(&CopperList);

		if(EndFlag != GAME_WON)
			FadeInCopper();

		NoInt--;
	}
}
