#include <string.h>
#include "myexec.h"
#include "drawbob.h"
#include "gfx.h"
#include "joystick.h"
#include "scroll.h"
#include "select.h"
#include "blase.h"
#include "main.h"
#include "id.h"

#define	WAITCNT	80

short	lastobjx,
		lastobjy;


WORD __regargs Select(struct SelectObject *obj, struct Bob *enemybob)
{
	struct	Window		*HeroWindow,
						*EnemyWindow;
	struct	SizeStruct	size,
						scansize;
	struct	JoyInfo		 joy;
	short				maxpos,
						lastpos,
						pos,
						i,
						x,
						y,
						yoffset,
						cnt,
						maxcnt,
						button_cnt;
	BYTE				button_state,
						wait_flag;

	void (*handler)(struct Bob *);				// die Routine

	NoInt++;

	do
	{
		EnemyWindow = 0;
		HeroWindow	= 0;

		if(obj->EnemyText)
		{
			wait_flag = TRUE;

			if( obj->herox==-1 && obj->heroy==-1 )
				wait_flag = FALSE;

			if(enemybob)
			{
				size.x = enemybob->bob_X;
				size.y = enemybob->bob_Y;
			}
			else
			{
				size.x = 0;
				size.y = 0;
			}
			size.x	 += obj->enemyx;
			size.y	 += obj->enemyy;
			size.txt  = obj->EnemyText;
			ScanText(&size);
			if(size.h & 1 == 0)
				size.yoffset = 4;
			else
				size.yoffset = 0;

			maxcnt    = WAITCNT*size.h;
			if(size.h > 5)	maxcnt*=2;

			EnemyWindow = CreateBlase(&size);		// Open the EnemyWindow

			cnt = 0;
			button_cnt = 0;

			while( cnt < maxcnt )
			{
				if(wait_flag)	cnt++;

				RasterDelay(150);
				GetKey();

				button_state = CheckJoy();
				if(button_state)	button_cnt = 0;
				else				button_cnt++;

				if(button_cnt == 4)
				{
					button_cnt = 0;
					while(button_cnt < 4)
					{
						RasterDelay(150);
						GetKey();

						button_state = CheckJoy();
						if(button_state)	button_cnt = 0;
						else				button_cnt++;
					}
					break;
				}
			}

			RasterDelay(300);
			if(EnemyWindow)	CloseWindow(EnemyWindow);
		}

		size.w		 = 0;
		size.h		 = 0;
		size.x		 = MyBob->bob_X;
		size.y  	 = 120;
		size.x		+= obj->herox;
		size.y		+= obj->heroy;
		size.txt 	 = NULL;
		size.yoffset = 0;
		x			 = 10;
		y			 = 5;
		i		 	 = 0;
		cnt			 = 0;

		lastobjx	 = obj->herox;
		lastobjy	 = obj->heroy;

		while(obj->SelectText[cnt].text && cnt < MAX_SELECT) { cnt++; };
		maxpos = cnt-1;

		if(cnt)
		{
			if((cnt & 1) == 0)
				yoffset = 4;
			else
				yoffset = 0;

			for(i=0;i<=maxpos;i++)
			{
				obj->SelectText[i].x = x;
				obj->SelectText[i].y = y;						// Actual Coordinates

				scansize.txt = obj->SelectText[i].text;			// Actual Text
				ScanText(&scansize);							// Get Text Size

				if(scansize.w > size.w)	size.w = scansize.w;	// Change width
				size.h += scansize.h;							// Add height
				y += scansize.h<<3;								// Add Y-Position
			};

			HeroWindow = CreateBlase(&size);
			SetAPen(HeroWindow,31);
			for(i=0;i<=maxpos;i++)
			{
				PrintAt(HeroWindow,obj->SelectText[i].x,
								   obj->SelectText[i].y+yoffset,
								   obj->SelectText[i].text);
				SetAPen(HeroWindow,0);
			}

			pos		= 0;
			lastpos = 0;
			button_cnt = 0;

			RasterDelay(300);

			while(1)
			{
				button_state = CheckJoy();
				if(button_state)	button_cnt = 0;
				else				button_cnt++;

				if(button_cnt == 4)	break;

				GetKey();

				if(maxpos)
				{	
					GetJoy(&joy);

					if(joy.ydir == JOY_DOWN && pos < maxpos)
					{
						pos++;
						while(joy.ydir == JOY_DOWN)		GetJoy(&joy);
					}

					if(joy.ydir == JOY_UP && pos > 0)
					{
						pos--;
						while(joy.ydir == JOY_UP)		GetJoy(&joy);
					}

					if(lastpos != pos)
					{
						SetAPen(HeroWindow,0);
						PrintAt(HeroWindow,obj->SelectText[lastpos].x,
										   obj->SelectText[lastpos].y+yoffset,
										   obj->SelectText[lastpos].text);

						SetAPen(HeroWindow,31);
						PrintAt(HeroWindow,obj->SelectText[pos].x,
										   obj->SelectText[pos].y+yoffset,
										   obj->SelectText[pos].text);

						lastpos = pos;
					}
					RasterDelay(200);
				}
			};

			while(!CheckJoy());

			if(HeroWindow)	CloseWindow(HeroWindow);
		
			handler = obj->SelectText[pos].handler;
			if(handler)		handler(enemybob);
		
			obj = obj->SelectText[pos].newobject;
		}
		else	break;
	}
	while(obj);

//	SoftScroll2();

	NoInt--;

	return pos;
}
