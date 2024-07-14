JOYSTICK_S:

		INCLUDE "myexec.i"
		INCLUDE "relcustom.i"			* AmigaCustomChips
		INCLUDE "definitions.i"
		INCLUDE	"joystick.i"

		SECTION	JoyStick,Code

@GetJoy:	bsr	GetJoy
		move.b	d0,(a0)
		move.b	d1,1(a0)
		rts

GetJoy:		movem.l	d2-d6/a0-a6,-(sp)
		lea	custom,a5
		move.w	joy1dat(A5),d2			* Normal Port 1
		tst.w	JoyStick			* Joy 2
		beq.s	7$				* No -->
	
		move.w	joy0dat(A5),d2			* Port 0 (Mouse Port)

7$:		moveq	#0,d0
		moveq	#0,d1

		btst	#9,d2
		bne.s	1$				* LINKS

		btst	#1,d2
		bne.s	2$				* RECHTS

6$:		move	d2,d3
		move	d3,d4
		lsr	#1,d3
		and	#$100,d3
		and	#$100,d4
		eor	d3,d4
		bne.s	3$				* OBEN

		move	d2,d3
		move	d3,d4
		lsr	#1,d3
		and	#1,d3
		and	#1,d4
		eor	d3,d4
		bne.s	4$				* UNTEN
		bra.s	5$

1$:		moveq	#-1,d0
		bra.s	6$

2$:		moveq	#1,d0
		bra.s	6$

3$:		moveq	#-1,d1
		bra.s	5$

4$:		moveq	#1,d1

5$:		movem.l	(sp)+,d2-d6/a0-a6
		rts

****************************************************************************

@WaitJoy:
WaitJoy:
.WaitJoy1:	bsr	CheckJoy
		bne.s	.WaitJoy1			* Gedrückt nein -->
.WaitJoy2:	bsr	CheckJoy
		beq.s	.WaitJoy2			* Gedrückt ja -->
		rts

****************************************************************************

@CheckJoy:
CheckJoy:	tst.w	JoyStick
		bne.s	.MousePort

		btst	#7,$bfe001			* JoyStickPort
		beq.s	.Pressed			* Pressed ->

.Release:	moveq	#-1,d0				
		rts

.MousePort:	btst	#6,$bfe001			* MousePort
		bne.s	.Release			* Released

.Pressed:	moveq	#0,d0
		rts

**************************************************************************

JoyStick:	dc.w	0				* JoyStick to use

;			X , Y
		dc.b	-1,-1
		dc.b	 0,-1
		dc.b	 1,-1
		dc.b	-1 ,0
JoyTab:		dc.b	 0 ,0
		dc.b	 1 ,0
		dc.b	-1 ,1
		dc.b	 0 ,1
		dc.b	 1 ,1
		
		CNOP	0,2

