#include "myexec.h"
#include "gfx.h"
#include "joystick.h"
#include "iff.h"
#include "main.h"

#define	WAITCNT	1000

static struct NewScreen MenuScreen = { 0,0,320,200,5,0,0,0,0 };
static struct NewWindow MenuWindow =
{
	0,0,
	320,200,
	17,0,
	WNF_NOBACKSAVE+WNF_BORDERLESS,
	DM_OR,
	0,
	0
};

static char FirstFlag = TRUE;

void __regargs Menu(void)
{
	struct	Screen *myscreen;
	struct	BitMap *bitmap;
	short	abort,cnt;
	WORD	cmap[32];
	IFFFILE	picture;

	if(FirstFlag)
	{
		myscreen = OpenScreen(&MenuScreen);
		bitmap = &(myscreen->sc_Bitmap);

		picture = LoadFastFile("ArtDept");
		DecodePic(bitmap,picture);
		GetColorTab(cmap,picture);
		FreeMem(picture);

		FadeIn(myscreen,cmap,125);

		picture = LoadFastFile("Intro");

		for(cnt=0;cnt<WAITCNT;cnt++)
		{
			if(!CheckJoy())	break;
			DelayBlank();
			GetKey();
		}

		FadeOut(myscreen,125);

		DecodePic(bitmap,picture);
		GetColorTab(cmap,picture);
		FreeMem(picture);

		FadeIn(myscreen,cmap,125);

		for(cnt=0;cnt<WAITCNT;cnt++)
		{
			if(!CheckJoy())	break;
			DelayBlank();
			GetKey();
		}

		FadeOut(myscreen,125);
		CloseScreen(myscreen);

		FirstFlag = FALSE;
	}

	abort = FALSE;
	cnt	  = 0;

	myscreen = OpenScreen(&MenuScreen);
	bitmap = &(myscreen->sc_Bitmap);

	picture = LoadFastFile("Menu");
	DecodePic(bitmap,picture);
	GetColorTab(cmap,picture);
	FreeMem(picture);

	FadeIn(myscreen,cmap,125);

	while(CheckJoy())
	{
		GetKey();
	}

	FadeOut(myscreen,125);
	CloseScreen(myscreen);
}

