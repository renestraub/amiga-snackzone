#include "myexec.h"
#include "drawbob.h"
#include "gfx.h"
#include "joystick.h"
#include "scroll.h"
#include "main.h"
#include "blase.h"
#include "level.h"

extern	APTR	BlaseBob;
//extern	WORD	PixelSizeX;

static struct NewWindow nw =
{
	0,0,
	0,0,
	0,0,
	WNF_BORDERLESS,
	DM_OR,
	NULL,
	0
};

static struct Bob *blase;

short __regargs GetLineLength(char *txt)
{
	short cnt;

	cnt = 0;

	while((*txt != '\n') && (*txt !=0))
	{
		cnt++;
		txt++;
	}
	return cnt;
}

void ScanText(struct SizeStruct *size)
{
	short width;
	char *txt;

	width=0;

	txt     = size->txt;
	size->w = 0;
	size->h = 0;

	do
	{
		width = GetLineLength(txt);
		if(width > size->w)	size->w = width;

		txt=txt+width+1;
		size->h++;
	}	
	while(txt[-1] != 0);
}

short xorg,yorg;

void PaintBob(short x, short y, short image)
{
	blase->bob_X = (x<<4) + xorg;
	blase->bob_Y = (y<<4) + yorg;
	blase->bob_Image = image;

	DrawOneBob(blase,ActBitmap);
}

void DrawBlase(struct Window *window, struct SizeStruct *size)
{
	short width,height;
	short x,y;

	xorg   = window->wn_XOrigin;
	yorg   = window->wn_YOrigin;
	width  = window->wn_Width>>4;
	height = window->wn_Height>>4;

	if(!blase)	blase = AddBob(&BlaseBob);		// BlaseBob adden
	
	PaintBob(0,0,0);
	for(x=1;x<width-1;x++)
	{
		PaintBob(x,0,1);
	}
	PaintBob(x,0,2);

	for(y=1;y<height-1;y++)
	{
		PaintBob(0,y,3);
		for(x=1;x<width-1;x++)
		{
			PaintBob(x,y,4);
		}
		PaintBob(x,y,5);
	}

	PaintBob(0,y,6);
	for(x=1;x<width-1;x++)
	{
		PaintBob(x,y,7);
	}
	PaintBob(x,y,8);
    PaintBob(1+(size->xdiff>>4),y+1,9);
}

struct Window *CreateBlase(struct SizeStruct *size)
{
	struct Window *window;

	if(size->x <= 64)	size->x = 64;
    if(size->w<2)		size->w = 2;
    if(size->h<2)		size->h = 2;

	size->w	= ((size->w<<3)+32) & 0xFFF0;
	size->h  = ((size->h<<3)+16) & 0xFFF0;

	size->xdiff	 = 0;

	if(size->x > (PixelSizeX-320-size->w+22))
		size->xdiff = size->x-(PixelSizeX-320-size->w+22);

	if(size->x+size->w > (LevelX+368))
	{
		size->xdiff = size->x+size->w-LevelX-368;
	}

	size->x -= size->xdiff;
	size->x -= 22;
	size->y = size->y - size->h - 10;

	nw.nw_LeftEdge = size->x;
	nw.nw_TopEdge  = size->y;
	nw.nw_Width    = size->w;
	nw.nw_Height   = size->h+12;

	window = OpenWindow(&nw, ActBitmap);

	DrawBlase(window, size);
	SetAPen(window,0);
	if(size->txt)	PrintAt(window,10,5+size->yoffset,size->txt);

	return window;
}

void __regargs Blase(short x, short y, char *txt)
{
	struct Window *window;
	struct SizeStruct size;

	size.x   = x;
	size.y   = y;
	size.txt = txt;

	NoInt++;

	ScanText(&size);
	window = CreateBlase(&size);
	SoftScroll();

	while(GetKey() || CheckJoy() );

	CloseWindow(window);

	NoInt--;
}

