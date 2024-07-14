
	#define	BOBSETLONG			-2
	#define	BOBLOOP			-4
	#define	BOBENDE			-6
	#define	BOBREMOVE			-8
	#define	BOBSETPRI			-10

	#define	BOBSIGNAL			-12
	#define	BOBWAIT			-14
	#define	BOBCPUJUMP			-16
	#define	BOBUNTIL			-18
	#define	BOBWHILE			-20

	#define	BOBPOKEB			-22
	#define	BOBPOKEW			-24
	#define	BOBPOKEL			-26
	#define	BOBRELMOVE			-28
	#define	BOBSETANIM			-30

	#define	BOBSETMOVE			-32
	#define	BOBSETCLIP 		-34
	#define	BOBSETDATA			-36
	#define	BOBSETMOVESPEED	-38

	#define	BOBSETANIMSPEED	-40
	#define	BOBSETID			-42
	#define	BOBFOR				-44
	#define	BOBNEXT			-46

	#define	BOBLSIGNAL			-48
	#define	BOBLWAIT			-50
	#define	BOBDELAY			-52
	#define	BOBRNDDELAY		-54
	#define	BOBADDBOB			-56

	#define	BOBRNDANIM			-58
	#define	BOBMOVETO			-60

	#define	BOBFLASH			-62
	#define	BOBSETCONVERT		-64
	#define	BOBANIMTO			-66
	#define	BOBGOTO			-68
	#define	BOBADDRELBOB		-70
	#define	BOBSETRELDATA		-72
	#define	BOBADDDAUGHTERBOB	-74

	#define	BOBTESTJOY			-76
	#define	BOBBITTEST			-78
	#define	BOBJEQ				-80
	#define	BOBJNE				-82


#define	BOBLEFT		1
#define	BOBRIGHT	2
#define	BOBUP		4
#define	BOBDOWN		8


struct BobData
{
	WORD	bod_Width;			// Breite des Bobs in Pixel
	WORD	bod_Height;			// Höhe des Bobs in Zeilen
	WORD	bod_X0;				// X-Offset des Bob-Nullpunkts
	WORD	bod_Y0;				// Y-Offset des Bob-Nullpunkts
	WORD	bod_CollX0;
	WORD	bod_CollY0;
	WORD	bod_CollX1;
	WORD	bod_CollY1;
	BYTE	bod_PlanePick;		// Für welche Planes sind Daten vorhanden
	BYTE	bod_PlaneOnOff;		// Was tun mit den restlichen Planes
	WORD	bod_Flags;			// Siehe BODF_ Definitionen
	WORD	bod_WordSize;		// Bob-Breite in WORDs +1
	WORD	bod_PlaneSize;		// Anzahl Bytes einer Plane
	WORD	bod_TotalSize;		// Länge des Bobs+Header
};

#define	BODB_ANIMKEY		8
#define	BODF_ANIMKEY		256

#define	BOBB_NORESTORE		0
#define	BOBB_NODRAW			1
#define	BOBB_BACKCLEAR		2
#define	BOBB_NOLIST			3
#define	BOBB_NOCUT			4
#define	BOBB_NODOUBLE		5
#define	BOBB_SPECIALDRAW	6
#define	BOBB_NOCOLLISION	7
#define	BOBB_FLIPXMOVE		8
#define	BOBB_FLIPYMOVE		9
#define	BOBB_NEWIMAGE		10
#define	BOBB_NOMOVE			11
#define	BOBB_NOANIM			12
#define	BOBB_ONLYANIM		13
#define	BOBB_HIDDEN			14
#define	BOBB_VHALF			15

#define	BOBF_NORESTORE		1
#define	BOBF_NODRAW			2
#define	BOBF_BACKCLEAR		4
#define	BOBF_NOLIST			8
#define	BOBF_NOCUT			16
#define	BOBF_NODOUBLE		32
#define	BOBF_SPECIALDRAW	64
#define	BOBF_NOCOLLISION	128
#define	BOBF_FLIPXMOVE		256
#define	BOBF_FLIPYMOVE		512
#define	BOBF_NEWIMAGE		1024
#define	BOBF_NOMOVE			2048
#define	BOBF_NOANIM			4096
#define	BOBF_ONLYANIM		8192
#define	BOBF_HIDDEN			16384
#define	BOBF_VHALF			32768

#define	CLIPB_DOWN			0
#define	CLIPB_UP			1
#define	CLIPB_LEFT			2
#define	CLIPB_RIGHT			3
#define	CLIPB_GLOBAL		4

#define	CLIPF_DOWN			1
#define	CLIPF_UP			2
#define	CLIPF_LEFT			4
#define	CLIPF_RIGHT			8
#define	CLIPF_GLOBAL		16

#define	CLIPF_X			CLIPF_RIGHT|CLIPF_LEFT
#define	CLIPF_Y			CLIPF_UP|CLIPF_DOWN
#define	CLIPF_ALL		CLIPF_X|CLIPF_Y
#define	CLIPF_GLOBALL	CLIPF_ALL|CLIPF_GLOBAL

struct Bob
{
	APTR	bob_NextBob;			// nachfolgendes Bob in der Liste
	APTR	bob_LastBob;			// vorhergehendes Bob in der Liste
	BYTE	bob_Id;					// BobKennung
	BYTE	bob_Priority;			// Priorität

	APTR	bob_BobData;			// Zeiger auf BobData Struktur
	WORD	bob_X;					// aktuelle X Koordinate (ohne Offset)
	WORD	bob_Y;					// aktuelle Y Koordinate (ohne Offset)

	WORD	bob_AbsX;				// korrigierte X Koordinate (ohne Offset)
	WORD	bob_AbsY;				// korrigierte Y Koordinate (ohne Offset)
	
	WORD	bob_X0;					// Kopie aus bod_X0
	WORD	bob_Y0;					// Kopie aus bod_Y0

	LONG	bob_LastLastOffset;		// vorletzte X+Y Koordinate (mit Offset)
	WORD	bob_LastLastBltSize;	// vorletzte Breite+Höhe

	LONG	bob_LastOffset;			// letzte X+Y Koordinate (mit Offset)
	WORD	bob_LastBltSize;		// letzte Breite+Höhe

	WORD	bob_Image;				// aktuelles Bob
	WORD	bob_LastImage;			// letztes Bob
	WORD	bob_LastLastImage;		// vorletztes Bob

	APTR	bob_AnimPrg;			// Zeiger auf aktuelles AnimKommando
	WORD	bob_AnimOffset;			// Offset ins AnimPrg
	BYTE	bob_AnimSpeed;			// AnimationsGeschwindigkeit
	BYTE	bob_AnimSpeedCounter;	// Speed-Zähler
	WORD	bob_AnimTo;				// Ziel von ANIMTO

	APTR	bob_MovePrg;			// Zeiger auf aktuelles MoveProgram
	WORD	bob_MoveOffset;			// Offsets ins MovePrg
	BYTE	bob_MoveSpeed;			// Bewegungsgeschwindigkeit
	BYTE	bob_MoveSpeedCounter;	// Speed-Zähler
	WORD	bob_MoveCounter;		// Kommando Zähler
	WORD	bob_MoveCommand;		// aktuelles Kommando
	WORD	bob_MoveStep;			// Geschwindigkeit
	WORD	bob_RelMoveCounter;		// Anzahl RelMoves (in Bytes)	

	WORD	bob_AnimDelayCounter;
	WORD	bob_MoveDelayCounter;

	WORD	bob_LSignalSet;			// gesetzte lokale symbols
	WORD	bob_Flags;				// diverse Flags (siehe NewBob Struktur)
	BYTE	bob_RemFlag;			// Wenn dieses Flag nicht 0 ist, wird Bob entfernt sobald es wieder 0 ist
	BYTE	bob_NewPri;

	APTR	bob_LastLastSaveBuffer;	// HintergrundBuffer für vorletztes Bob
	APTR	bob_LastSaveBuffer;		// HintergrundBuffer für letztes Bob

	WORD	bob_ClipX;				// linke obere X Clip-Koordinate
	WORD	bob_ClipY;				// linke obere Y Clip-Koordinate
	WORD	bob_ClipX2;				// rechte untere X Clip-Koordinate
	WORD	bob_ClipY2;				// rechte untere Y Clip-Koordinate
	WORD	bob_ClipFlags;			// diverse Flags fürs Cliing

	WORD	bob_CollX0;
	WORD	bob_CollY0;
	WORD	bob_CollX1;
	WORD	bob_CollY1;

	WORD	bob_AnimForCounter;		// für AnimPrg-For-Next 
	WORD	bob_MoveForCounter;		// für MovePrg-For-Next 

	APTR	bob_OrgTab;				// Zeiger auf ersetzende OriginTabelle

	APTR	bob_CollHandler;		// Wird angesprungen bei MeMask-Koll.
	WORD	bob_MeMask;				// which types can collide with this bob
	WORD	bob_HitMask;			// which types this bob can collide with

	LONG	bob_Handler;				// CPU-Prg welches vor dem Zeichnen aufgerufen wird
	LONG	bob_HandlerD0;			// Diesen Wert bekommt man im D0

	WORD	bob_MoveToSteps;			// Anzahl der noch zu machenden Steps	
	WORD	bob_MoveToX;				// X Koordinate mit 16 multipliziert 
	WORD	bob_MoveToY;				// Y Koordinate mit 16 multipliziert
	WORD	bob_MoveToXStep;			// X Verschiebung
	WORD	bob_MoveToYStep;			// Y Verschiebung
	
	APTR	bob_ConvertTab;
	WORD	bob_ConvertSize;
	WORD	bob_ConvertOffset;

	BYTE	bob_TraceMode;
	BYTE	bob_TraceLock;

	BYTE	bob_FlashTime;
	BYTE	bob_FlashColor;
	
	LONG	bob_UserData;			// Frei benutzbar vom User
	APTR	bob_UserDataPtr;			// noch mal was für Straub's Ronny
	WORD	bob_UserFlags;

	APTR	bob_ParentBob;

	BYTE	bob_sr;					// Status-register
	BYTE	bob_Pad1;
};


#define NewBob(name) WORD name[]=
#define SetData(adr,base)	(WORD)BOBSETDATA,(LONG)adr,(LONG)base,
#define SetFlags(flags)		(BYTE)bob_Flags,(BYTE)BOBSETWORD,WORD(flags)
#define Ende			(WORD)BOBENDE,











