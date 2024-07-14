BOBS_S:
		XREF	_MyExecBase
		XREF	_BobBase,_BigHeroBase

		INCLUDE "MyExec.i"
		INCLUDE	"DrawBob.i"
		INCLUDE	"Definitions.i"
		INCLUDE	"Sfx.i"
		INCLUDE	"Level.i"
		INCLUDE	"Bobs.i"
		INCLUDE "Show.i"
		INCLUDE	"Tankstelle.i"
		INCLUDE	"Sound.i"

		INCLUDE	"Game/ImmerBobs.i"
		INCLUDE	"Game/GegenBobs.i"
		INCLUDE	"Game/PanelBobs.i"
		INCLUDE	"Game/FutureBobs.i"
		INCLUDE	"Game/HeroBig.i"

		XREF	_ImmerBobBase,_PanelBobBase
		XREF	_HinweisFlag,_GateFlag

**** BOBS ******************************************************************

_BigRonny:	SETDATA		BigHeroBob0,_BigHeroBase
		SETFLAGS	BOBF_NORESTORE|BOBF_NODRAW|BOBF_NOANIM|BOBF_NOMOVE
		SETX		260
		SETY		172
		SETIMAGE	6
		ENDE

_BigRonnyLeftAnim:
		ANIMTO		6,11
		POKEB		_MoveFlag,0
		ENDE

_BigRonnyLeftMove:
		LEFT		1
		ENDE

_BigRonnyRightAnim:
		ANIMTO		0,5
		POKEB		_MoveFlag,0
		ENDE

_BigRonnyRightMove:
		RIGHT		1
		ENDE

**** BOBS ******************************************************************

_HinweisBob:	SETDATA		GrundBobs175,_ImmerBobBase
		SETY		20
		SETMOVE		.HinweisMove
		SETMOVESPEED	1
		ENDE

.HinweisMove:	DELAY		1
		BITTEST		0,_GateFlag
		JNE		.HinweisMove	; Bob im Gate

		POKEB		_HinweisFlag,0
		REMOVE
		ENDE

*********************************************************************************

_BlaseBob:	SETDATA		BlaseBob46,_ImmerBobBase
		SETFLAGS	BOBF_NOLIST|BOBF_NORESTORE|BOBF_NODOUBLE
		ENDE

*********************************************************************************

_NewPanelBob:	SETDATA		Item0,_PanelBobBase
		SETFLAGS	BOBF_NOLIST|BOBF_NORESTORE|BOBF_NODOUBLE
		ENDE

*********************************************************************************

_Oma:		SETDATA		Oma,_BobBase
		SETANIM		1$
		SETANIMSPEED	6
		SETCOLLHANDLER	@OmaCollision
		SETHANDLER	@OmaHandler
		SETMEMASK	RONNY_COLL
		ENDE

1$:		dc.w		4,5,6,5
		RNDDELAY	1,3
		LOOP

_OmaAnim:	FOR		40
		 ANIMTO		0,3
		 LSIGNAL	1
		NEXT
		CPUJUMP		@OmaCheck,0
		ENDE

_OmaMove:	FOR		40
		 RIGHT		1
		 LWAIT		1
		NEXT
		ENDE

*********************************************************************************

_TankBob:	SETDATA		TouristBob,_ImmerBobBase
		SETCOLLHANDLER	@Tankstelle
Global1:	SETFLAGS	BOBF_NODRAW|BOBF_NORESTORE
		SETMEMASK	RONNY_COLL
		ENDE

*********************************************************************************

_KioskBob:	SETDATA		TouristBob,_ImmerBobBase
		SETCOLLHANDLER	@Kiosk
		GOTO		Global1

*********************************************************************************

_SupermarktBob:	SETDATA		CollBob,_ImmerBobBase
		SETCOLLHANDLER	@ShowSupermarkt
		GOTO		Global1

*********************************************************************************

_KinoBob:	SETDATA		CollBob,_ImmerBobBase
		SETCOLLHANDLER	@Kino
		GOTO		Global1

*********************************************************************************

_KneipeBob:	SETDATA		CollBob,_ImmerBobBase
		SETCOLLHANDLER	@Kneipe
		GOTO		Global1

*********************************************************************************

_DiscoBob:	SETDATA		CollBob,_ImmerBobBase
		SETCOLLHANDLER	@DiscoFuture
		GOTO		Global1

*********************************************************************************

_MuseumBob:	SETDATA		CollBob,_ImmerBobBase
		SETCOLLHANDLER	@Museum
		GOTO		Global1

*********************************************************************************

_StromBob:	SETDATA		CollBob,_ImmerBobBase
		SETCOLLHANDLER	@StromGame
		GOTO		Global1

*********************************************************************************

_TouristInfo:	SETDATA		TouristBob,_ImmerBobBase
		SETMEMASK	RONNY_COLL
		SETCOLLHANDLER	@ShowKarte
_BackFlags:	SETFLAGS	BOBF_NORESTORE
		ENDE

*********************************************************************************

_Unilever:	SETDATA		Unilever,_ImmerBobBase
		GOTO		_BackFlags

*********************************************************************************

_Museum:	SETDATA		MuseumBob,_ImmerBobBase
		GOTO		_BackFlags

*********************************************************************************

_Plattenladen:	SETDATA		PlattenBob,_ImmerBobBase
		GOTO		_BackFlags

*********************************************************************************

_Supermarkt:	SETDATA		SBMarktBob,_ImmerBobBase
		GOTO		_BackFlags

*********************************************************************************

_Film:		SETDATA		KinoBob,_ImmerBobBase
		GOTO		_BackFlags

*********************************************************************************

_Coll:		SETDATA		CollBob,_ImmerBobBase
		SETFLAGS	BOBF_NODRAW
		ENDE

*********************************************************************************

_Skater:	SETDATA		Popper,_BobBase
		SETANIM		1$
		SETANIMSPEED	6
		SETMEMASK	RONNY_COLL
		SETCOLLHANDLER	@SkaterCollision
		ENDE

1$:		ANIMTO		0,5
		ANIMTO		4,1
		LOOP

*********************************************************************************

_Huber:		SETDATA		HonighuberSub,_BobBase
		SETANIM		1$
		SETANIMSPEED	7
		SETHANDLER	@HuberHandler
		SETCOLLHANDLER	@HuberCollision
		SETMEMASK	RONNY_COLL
		ENDE		

1$:		ADDDAUGHTER	_HuberSub,-58,1
_HuberAnim:	FOR		10
		 dc.w		0,1
		NEXT
		RNDDELAY	2,8
		GOTO		_HuberAnim


_HuberSub:	SETDATA		Honighuber,_BobBase
		SETFLAGS	BOBF_NORESTORE
		SETCLIP		0,0,0,0,CLIPF_ALL
		ENDE

_HuberDrehAnim:	dc.w		2,3,4,5
		SETCOLLHANDLER	@HuberCollision2
		ENDE

*********************************************************************************

_Bauarbeiter:	SETDATA		Bauarbeiter,_BobBase
		SETANIM		1$
		SETANIMSPEED	3
		SETMEMASK	RONNY_COLL
		SETCOLLHANDLER	@ArbeiterCollision
		ENDE		

1$:		FOR		5
		 RNDDELAY	2,4
		 dc.w		0,1,2,1,2,1,2,1
		NEXT

		ADDDAUGHTER	_Arbeiter2,10,-23
		dc.w		3
		DELAY		12
		LOOP

_Arbeiter2:	SETDATA		ArbeiterSub,_BobBase
		SETCLIP		0,0,0,0,CLIPF_ALL
		SETANIM		1$
		SETANIMSPEED	3
		ENDE

1$:		ANIMTO		0,5
		DELAY		5
		ANIMTO		5,0
		REMOVE

*********************************************************************************

_Katze:		SETDATA		Katze,_BobBase
		SETANIM		1$
		SETANIMSPEED	6
		SETMEMASK	RONNY_COLL
		SETCOLLHANDLER	@CatCollision
		SETHANDLER	@CatHandler
		SETPRI		10
		ENDE

1$:		RNDDELAY	0,5
		dc.w		0,1,2,1
		LOOP

_FliehKatze:	SETDATA		Katze,_BobBase
		SETY		175
		SETANIM		_KatzeFliehtAnim
		SETMOVE		_KatzeFliehtMove
		SETMOVESTEP	12
		SETANIMSPEED	4
		ENDE

_KatzeFliehtMove:
		SETCOLLHANDLER	0
		FOR		40
		 RIGHT		1
		 LWAIT		1
		NEXT
		REMOVE

_KatzeFliehtAnim:
		ANIMTO		3,6
		LSIGNAL		1
		LOOP

*********************************************************************************

_Zuhaelter:	SETDATA		ZuhaelterR,_BobBase
		SETANIM		1$
		SETMOVE		2$
		SETANIMSPEED	6
		SETMOVESTEP	12
		SETMEMASK	RONNY_COLL
		SETCOLLHANDLER	@ZuhaCollision
		SETHANDLER	@ZuhaHandler
		SETPRI		-10
		ENDE

1$:		FOR		8
		 ANIMTO		0,5
		 LSIGNAL	1
		NEXT
		FOR		8
		 ANIMTO		6,10
		 LSIGNAL	1
		NEXT	
		LOOP

2$:		FOR		8
		 RIGHT		1
		 LWAIT		1
		NEXT
		FOR		8
		 LEFT		1
		 LWAIT		1
		NEXT
		LOOP

_ZuhaFliehtAnim:
		FOR		36
		 ANIMTO		0,5
		 LSIGNAL	1
		NEXT
	;;	CPUJUMP		@ZuhaRemove,0
		REMOVE

_ZuhaFliehtMove:
		RIGHT		1
		LWAIT		1
		LOOP
		
*********************************************************************************

_Hund:		SETDATA		Hund,_BobBase
		SETANIM		1$
		SETMOVE		2$
		SETANIMSPEED	6
		SETMOVESTEP	6
		SETMEMASK	RONNY_COLL
		SETCOLLHANDLER	@HundCollision
		SETHANDLER	@HundHandler
		ENDE

1$:		FOR		14
		 ANIMTO		0,3
		 LSIGNAL	1
		NEXT
		FOR		14
		 ANIMTO		4,7
		 LSIGNAL	1
		NEXT	
		LOOP

2$:		FOR		14
		 RIGHT		1
		 LWAIT		1
		NEXT
		FOR		14
		 LEFT		1
		 LWAIT		1
		NEXT
		LOOP

_HundFliehtMove:
		SETCOLLHANDLER	0
		FOR		80
		 RIGHT		1
		 LWAIT		1
		NEXT
		REMOVE

_HundFliehtAnim:
		ANIMTO		0,3
		LSIGNAL		1
		LOOP


*********************************************************************************

_Tuersteher:	SETDATA		Schlaeger,_BobBase
		SETANIM		1$
		SETANIMSPEED	6
		SETMEMASK	RONNY_COLL
		SETCOLLHANDLER	@TuersteherCollision
	;	SETHANDLER	@TuersteherHandler
		ENDE

1$:		dc.w		0
		RNDDELAY	10,20
		dc.w		1
		RNDDELAY	4,12
		LOOP


*********************************************************************************

_Haendler:	SETDATA		Bauchladen,_BobBase
		SETANIM		1$
		SETANIMSPEED	6
		SETMEMASK	RONNY_COLL
		SETCOLLHANDLER	@HaendlerCollision
		ENDE

1$:		ANIMTO		0,3
		dc.w		2,1
		LOOP

*********************************************************************************

_Agent:		SETDATA		Agent,_BobBase
		SETMEMASK	RONNY_COLL
		SETCOLLHANDLER	@AgentCollision
		SETHANDLER	@AgentHandler
		ENDE

_Verbmann:	SETDATA		VerbMann,_BobBase
		SETMEMASK	RONNY_COLL
		SETCOLLHANDLER	@VerbMannCollision
		SETHANDLER	@VerbMannHandler
		ENDE

*********************************************************************************

_Wespen:	SETDATA		Wespen,_BobBase
		SETANIM		1$
		SETANIMSPEED	1
		SETMOVE		2$
		SETMOVESTEP	2
		SETMEMASK	RONNY_COLL
		SETCOLLHANDLER	@WespeCollision
		SETHANDLER	@WespeHandler
		ENDE

1$:		dc.w		0,1,2
		LOOP


2$:		RIGHT		20
		DOWN		30
		LEFTUP		15
		LEFTDOWN	15
		UP		25
		LEFT		15
		RIGHTDOWN	10
		RIGHT		10
		RIGHTUP		20
		LEFT		15
		DOWN		5
		LOOP

_WespeMove2:	LEFT		10
		UP		15
		RIGHTDOWN	7
		RIGHTUP		7
		DOWN		13
		RIGHT		8
		LEFTUP		5
		LEFT		5
		LEFTDOWN	10
		RIGHT		8
		UP		3
		LOOP


_HonigTopf:	SETDATA		Honigtopf,_BobBase
		ENDE

*********************************************************************************

_Kinderwagen:	SETDATA		KinderwagenR,_BobBase
		SETANIM		1$
		SETMOVE		2$
		SETANIMSPEED	3
		SETMOVESPEED	3
		SETMEMASK	RONNY_COLL
		SETCOLLHANDLER	@KinderwagenCollision
		ENDE


1$:		FOR		100
		 ANIMTO		0,3
		NEXT
		FOR		100
		 ANIMTO		4,7
		NEXT
		LOOP	

2$:		RIGHT		300		; muss 3 mal grösser als anim sein !!
		LEFT		300
		LOOP


_Schnuller:	SETDATA		Schnuller,_BobBase
		SETMEMASK	RONNY_COLL
		SETHANDLER	@SchnullerHandler
		SETCOLLHANDLER	@SchnullerCollision
		ENDE

*********************************************************************************

_Blondine:	SETDATA		FrauR,_BobBase
		SETANIM		1$
		SETMOVE		2$
		SETANIMSPEED	4
		SETMOVESTEP	12
		SETMEMASK	RONNY_COLL
		SETCOLLHANDLER	@BlondiCollision
		SETHANDLER	@BlondiHandler
		SETPRI		-10
		ENDE

1$:		FOR		16
		 ANIMTO		0,5
		 LSIGNAL	1
		NEXT
		FOR		16
		 ANIMTO		6,10
		 LSIGNAL	1
		NEXT	
		LOOP

2$:		FOR		16
		 RIGHT		1
		 LWAIT		1
		NEXT
		FOR		16
		 LEFT		1
		 LWAIT		1
		NEXT
		LOOP

*********************************************************************************

_Platte:	SETDATA		SchallplatteBob,_BobBase
		SETMEMASK	RONNY_COLL
		SETHANDLER	@PlatteHandler
		SETCOLLHANDLER	@PlatteCollision
		ENDE

*********************************************************************************

_SnackRoboter:	SETDATA		SnackRoboter,_BobBase
		SETANIM		1$
		SETMEMASK	RONNY_COLL
		SETCOLLHANDLER	@SnackCollision
		ENDE

1$:		dc.w		0
		CPUJUMP		@SnackMove,1
		DELAY		1
		CPUJUMP		@SnackMove,1
		dc.w		1
		CPUJUMP		@SnackMove,1
		DELAY		1
		CPUJUMP		@SnackMove,1
		LOOP

*********************************************************************************

_Marsianer:	SETDATA		Alien1,_BobBase
		ADDDAUGHTER	_MarsSub1,12,-3
		ADDDAUGHTER	_MarsSub2,24,0
		SETMEMASK	RONNY_COLL
		SETCOLLHANDLER	@AlienCollision
MarsGlobal:	SETANIM		_MarsAnim
		SETANIMSPEED	5
		SETCLIP		0,0,0,0,CLIPF_ALL
		ENDE

_MarsSub1:	SETDATA		Alien2,_BobBase
		GOTO		MarsGlobal

_MarsSub2:	SETDATA		Alien3,_BobBase
		GOTO		MarsGlobal

_MarsAnim:	RNDDELAY	2,10
		ANIMTO		0,3
		dc.w		2,1
		LOOP

*********************************************************************************

_Schrotti:	SETDATA		SchrottMann,_BobBase
		ADDDAUGHTER	_Schrotti2,-1,0
		SETMEMASK	RONNY_COLL
		SETCLIP		0,0,0,0,CLIPF_ALL
		SETCOLLHANDLER	@SchrottiCollision
		SETHANDLER	@SchrottiHandler
		SETMEMASK	RONNY_COLL
		ENDE

_Schrotti2:	SETDATA		FutureBob15,_BobBase
		SETANIM		1$
		SETANIMSPEED	3
		SETCLIP		0,0,0,0,CLIPF_ALL
		ENDE

1$:		RNDDELAY	10,25
		ANIMTO		0,5
		dc.w		0
		LOOP

*********************************************************************************

_Spock:		SETDATA		Spock,_BobBase
		SETANIM		1$
		SETANIMSPEED	5
		SETMOVE		2$
		SETMOVESTEP	20
		SETMEMASK	RONNY_COLL
		SETCOLLHANDLER	@SpockCollision
		SETHANDLER	@SpockHandler
		ENDE

1$:		FOR		8
		 ANIMTO		6,11
		 LSIGNAL	1
		NEXT
		FOR		8
		 ANIMTO		0,5
		 LSIGNAL	1
		NEXT
		LOOP

2$:		FOR		8
		 LEFT		1
		 LWAIT		1
		NEXT
		FOR		8
		 RIGHT		1
		 LWAIT		1
		NEXT
		LOOP

*********************************************************************************

_Musiker:	SETDATA		Gittarist,_BobBase
		SETANIM		1$
		SETANIMSPEED	5
		SETMEMASK	RONNY_COLL
		SETCOLLHANDLER	@MusikerCollision
		ENDE

1$:		dc.w		0,1,2
		LOOP


*********************************************************************************

_Roboter:	SETDATA		Panzer,_BobBase
		SETANIM		1$
		SETANIMSPEED	5
		SETMOVE		2$
		SETMOVESPEED	2
		SETMEMASK	RONNY_COLL
		SETCOLLHANDLER	@RoboterCollision
		ENDE

1$:		dc.w		0,1
		LOOP

2$:		LEFT		180
		RIGHT		180
		LOOP

*********************************************************************************

_Fremder:	SETDATA		Ortsfremder,_BobBase
		SETANIM		1$
		SETANIMSPEED	5
		SETMOVE		2$
		SETMOVESTEP	23
		SETMEMASK	RONNY_COLL
		SETCOLLHANDLER	@FremderCollision
		SETHANDLER	@FremderHandler
		ENDE

1$:		FOR		5
		 ANIMTO		6,11
		 LSIGNAL	1
		NEXT
		FOR		5
		 ANIMTO		0,5
		 LSIGNAL	1
		NEXT
		LOOP

2$:		FOR		5
		 LEFT		1
		 LWAIT		1
		NEXT
		FOR		5
		 RIGHT		1
		 LWAIT		1
		NEXT
		LOOP

*********************************************************************************

_Rocker:	SETDATA		FutureBob60,_BobBase
		ADDDAUGHTER	_Rocker2,0,0
		ADDDAUGHTER	_Rocker4,0,0
		ADDDAUGHTER	_Rocker5,0,0
		ADDDAUGHTER	_Rocker6,0,0
		SETMEMASK	RONNY_COLL
		SETCOLLHANDLER	@RockerCollision
		SETHANDLER	@RockerHandler
		ENDE

_RockerMove:	RIGHT		4
		SETMOVESTEP	3
		RIGHT		10
		SETMOVESTEP	4
		RIGHT		20
		SETMOVESTEP	5
		RIGHT		100
		ENDE

_RockerAnim:	dc.w		1
		ENDE


_Rocker2:	SETDATA		FutureBob56,_BobBase
_RockerGlobal:	SETCLIP		0,0,0,0,CLIPF_ALL
		SETANIM		1$
		ENDE


1$:		CPUJUMP		@StoreRocker2,0
		ENDE


_Rocker4:	SETDATA		FutureBob65,_BobBase
		SETCLIP		0,0,0,0,CLIPF_ALL
		GOTO		_RockerGlobal

_Rocker5:	SETDATA		FutureBob67,_BobBase
		SETANIMSPEED	3
		SETANIM		51$
		SETCLIP		0,0,0,0,CLIPF_ALL
		GOTO		_RockerGlobal

51$:		RNDDELAY	2,6
		dc.w		0,1
		LOOP

_Rocker6:	SETDATA		FutureBob69,_BobBase
		SETCLIP		0,0,0,0,CLIPF_ALL
		GOTO		_RockerGlobal

_Rocker7:	SETDATA		FutureBob72,_BobBase
		SETANIMSPEED	2
		SETANIM		71$
		SETCLIP		0,0,0,0,CLIPF_ALL
		GOTO		_RockerGlobal

71$:		dc.w		0,1
		LOOP




*********************************************************************************

_FerrariL:	SETDATA		FerrariL,_BobBase
		SETANIM		1$
		SETUSERDATA	100
		SETHANDLER	@FerrariLHandler
		SETMEMASK	RONNY_COLL
		SETCOLLHANDLER	@FerrariColl
		SETPRI		32
		ENDE

1$:		dc.w		0,1
		GOTO		1$

*********************************************************************************

_FerrariR:	SETDATA		FerrariR,_BobBase
		SETANIM		1$
		SETUSERDATA	100
		SETMEMASK	RONNY_COLL
		SETHANDLER	@FerrariRHandler
		SETCOLLHANDLER	@FerrariColl
		SETPRI		32
		ENDE

1$:		dc.w		0,1
		GOTO		1$

*********************************************************************************

_ToeffL:	SETDATA		ToeffL,_BobBase
		SETUSERDATA	100
		SETMEMASK	RONNY_COLL
		SETHANDLER	@FerrariLHandler
		SETCOLLHANDLER	@FerrariColl
		SETPRI		32
		ENDE

*********************************************************************************

****  Level 1 (5th Avenue) *************************************************************

		SETBOB	LISTSTART,0,0,0
_EnemyList1:
		SETBOB	-500,175,0,_FerrariR
		SETBOB	-50,176,0,_Tuersteher
		SETBOB	410,174,0,_Verbmann
		SETBOB	720,144,0,_KinoBob
		SETBOB	810,144,0,_KinoBob
		SETBOB	900,144,0,_KinoBob
		SETBOB	832,74,0,_Film

		SETBOB	LISTEND,0,0,0

****  Level 2 (Route 66) *************************************************************

		SETBOB	LISTSTART,0,0,0
_EnemyList2:
		SETBOB	-200,176,0,_Blondine
		SETBOB	700,176,0,_Haendler
		SETBOB	1160,174,0,_Katze
		SETBOB	2000,175,0,_FerrariL
		SETBOB	LISTEND,0,0,0

****  Level 3 (Königsalle) *************************************************************

		SETBOB	LISTSTART,0,0,0
_EnemyList3:
		SETBOB	24,176,0,_TankBob

		SETBOB	380,175,0,_Huber

		SETBOB	555,176,0,_Kinderwagen
		SETBOB	970,175,0,_Schnuller

		SETBOB	LISTEND,0,0,0

****  Level 4 (Baker Street) *************************************************************

		SETBOB	LISTSTART,0,0,0
_EnemyList4:
		SETBOB	144,176,0,_Agent
		SETBOB	555+16+16,176,0,_SupermarktBob
		SETBOB	555+32+8,97,0,_Supermarkt
		SETBOB	995+24,144,0,_KneipeBob
		SETBOB	2000,175,0,_ToeffL

		SETBOB	LISTEND,0,0,0

****  Level 5 (Dammtorwall) *************************************************************

		SETBOB	LISTSTART,0,0,0
_EnemyList5:
		SETBOB	-500,175,0,_FerrariR
		SETBOB	-240,105,0,_Plattenladen
		SETBOB	-240,175,0,_Platte
		SETBOB	-100,104,0,_Wespen
		SETBOB	96+16,144-16-24,0,_Unilever

		SETBOB	LISTEND,0,0,0

****  Level 6 (Snack Street) *************************************************************

		SETBOB	LISTSTART,0,0,0
_EnemyList6:
	;;	SETBOB	-250,144,0,_MuseumBob
	;;	SETBOB	-200,144,0,_KneipeBob
	;;	SETBOB	-150,145,0,_StromBob

		SETBOB	42,145,0,_TouristInfo
		SETBOB	240,176,0,_Oma
		SETBOB	410,176,0,_KioskBob
		SETBOB	2000,175,0,_FerrariL

		SETBOB	LISTEND,0,0,0

****  Level 7 (Strip) ************************************************************

		SETBOB	LISTSTART,0,0,0
_EnemyList7:
		SETBOB	-200,175,0,_Hund
		SETBOB	-190,175,0,_Zuhaelter
		SETBOB	0,176,0,_Skater
		SETBOB	200,176,0,_Bauarbeiter
		SETBOB	2000,175,0,_ToeffL

		SETBOB	LISTEND,0,0,0

****  Level 8 (Eyberstrasse) ******************************************************

		SETBOB	LISTSTART,0,0,0
_EnemyList8:
		SETBOB	-16,164,0,_StromBob
		SETBOB	2000,175,0,_FerrariL

		SETBOB	LISTEND,0,0,0



** FUTURE ************************************************************************************

**** Level 11 (5th Avenue) *************************************************************

		SETBOB	LISTSTART,0,0,0
_EnemyList11:
		SETBOB	32,164,0,_DiscoBob
		SETBOB	-248,154,0,_SnackRoboter
		SETBOB	LISTEND,0,0,0

**** Level 12 (Route 66) *************************************************************

		SETBOB	LISTSTART,0,0,0
_EnemyList12:
		SETBOB	348,154,0,_SnackRoboter
		SETBOB	820,175,0,_Fremder
		SETBOB	1180,175,0,_Roboter
		SETBOB	LISTEND,0,0,0

**** Level 13 (Königsalle) *************************************************************

		SETBOB	LISTSTART,0,0,0
_EnemyList13:
		SETBOB	100,154,0,_SnackRoboter
		SETBOB	50,175,0,_Spock
		SETBOB	400,175,0,_Musiker
		SETBOB	LISTEND,0,0,0

**** Level 14 (Baker Street) *************************************************************

		SETBOB	LISTSTART,0,0,0
_EnemyList14:
		SETBOB	-48,154,0,_SnackRoboter
		SETBOB	0,136,0,_Schrotti
		SETBOB	LISTEND,0,0,0

**** Level 15 (Dammtorwall) *************************************************************

		SETBOB	LISTSTART,0,0,0
_EnemyList15:
		SETBOB	148,154,0,_SnackRoboter
		SETBOB	40,155,0,_Rocker
		SETBOB	-224,110,0,_Museum
		SETBOB	-224-32,144,0,_MuseumBob
		SETBOB	LISTEND,0,0,0

**** Level 16 (Snack Street) *************************************************************

		SETBOB	LISTSTART,0,0,0
_EnemyList16:
		SETBOB	-48,154,0,_SnackRoboter
		SETBOB	-30,145,0,_TouristInfo
		SETBOB	LISTEND,0,0,0

**** Level 17 (Strip) ************************************************************

		SETBOB	LISTSTART,0,0,0
_EnemyList17:
		SETBOB	200,154,0,_SnackRoboter
		SETBOB	-10,175,0,_Marsianer
		SETBOB	LISTEND,0,0,0

**** Level 18 (Eyberstrasse) ******************************************************

		SETBOB	LISTSTART,0,0,0
_EnemyList18:
		SETBOB	-48,154,0,_SnackRoboter
		SETBOB	LISTEND,0,0,0

