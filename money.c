#include "myexec.h"
#include "drawbob.h"
#include "gfx.h"
#include "joystick.h"
#include "scroll.h"
#include "blase.h"
#include "main.h"
#include "level.h"
#include "panel.h"

extern	short	lastobjx,
				lastobjy;

#define	WAITCNT	60

void __regargs ShowMoney(void)
{
	struct	Window		*HeroWindow;
	struct	SizeStruct	size;
	short				value;

	NoInt++;

	size.w		 = 8;
	size.h		 = 2;
	size.x		 = MyBob->bob_X;
	size.y  	 = 120;
	size.x		+= lastobjx;
	size.y		+= lastobjy;
	size.txt 	 = NULL;
	size.yoffset = 0;

	value		 = MoneyObject.value;

	HeroWindow = CreateBlase(&size);
	if(HeroWindow)
	{
		SetAPen(HeroWindow,31);

		if(TimeZone == GEGENWART)
		{
			PrintAt(HeroWindow,10,10,"Ich habe\n"
								 "%ld Taler",value);
		}
		else
		{
			PrintAt(HeroWindow,10,10,"Ich habe\n"
								 "%ld ECU",value);
		}

		RasterDelay(300*WAITCNT);

		CloseWindow(HeroWindow);
	}

	SoftScroll2();

	NoInt--;
}
