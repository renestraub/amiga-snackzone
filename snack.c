#include "myexec.h"
#include "gfx.h"
#include "select.h"
#include "main.h"
#include "id.h"
#include "panel.h"
#include "drawbob.h"
#include "level.h"
#include "joystick.h"
#include "sound.h"

static	struct SelectObject SnackSelect1;
static	short lastdir = 1;

void __regargs SnackCollision(struct Bob *mybob, struct Bob *enemybob)
{
	struct JoyInfo joy;

	PfeilFlag = TRUE;

	GetJoy(&joy);

	if(joy.ydir == JOY_UP)
	{
		Select(&SnackSelect1,enemybob);
		enemybob->bob_CollHandler = NULL;
	}
}

void __regargs SnackMove(struct Bob *bob, LONG l)
{
	if(bob->bob_X == PixelSizeX-360)	lastdir = -1;
	if(bob->bob_X == 100)				lastdir = 1;

	bob->bob_X += lastdir;
}

static void Take1(struct Bob *bob)
{
	ChangeMoney(-1);
	ChangeEnergy(4);
	StartFX(2);
	ShowMoney();
}

static void Take2(struct Bob *bob)
{
	ChangeMoney(-2);
	ChangeEnergy(8);
	StartFX(2);
	ShowMoney();
}

static struct SelectObject SnackSelect1 =
{
	0,0,
	-40,-42,
	"Hallo Fremder!\n"
	"Mein Angebot\n\n"
	"Gelbe Snack-Pillen (1)\n"
	"Rote Snack-Pillen  (2)\n"
	"Blaue Snack-Pillen (1)\n"
	"Lila Snack-Pillen  (1)",
	
	0,0,"Wuerg! Danke Nein",NULL,NULL,
	0,0,"Die Gelben",NULL,&Take1,
	0,0,"Die Roten",NULL,&Take2,
	0,0,"Die Blauen",NULL,&Take1,
	0,0,"Die Lila",NULL,&Take1
};
