
#define GEGENWART	22
#define	ZUKUNFT		23
#define	lgf_Gate	1
#define	lgf_Subway	2

struct LevelData			// Werner's geniales LevelED Format
{
	LONG Id;				// 0  Die ID
	WORD Dummy1;			// 4
	WORD Dummy2;			// 6
	WORD Depth;				// 8
	WORD XChars;			// 10
	WORD YChars;			// 12
	WORD XScr;				// 14
	WORD YScr;				// 16
};

struct LevelBob
{
	WORD	XPos;
	WORD	YPos;
	WORD	Flags;
	BYTE	BobRight;
	BYTE	BobLeft;
};

struct Level
{
	APTR	Char;
	APTR	Level;
	APTR	Bobs;
	APTR	Flags;
	struct	LevelBob *EnemyLeft;
	struct	LevelBob *EnemyRight;
	APTR	ColorMap;
	struct	Gate *GateWay;
	WORD	LevelX;
	WORD	RonnyX;
	WORD	RonnyY;
	WORD	SchildBob;
	WORD	UBahnLinie;
};

struct Gate
{
	struct	Gate *NextGate;		// Nächstes Gate
	WORD	Flag;				// Flag (Gate oder UBahn)
	WORD	X1;					// Anfang des Bereiches
	WORD	X2;					// Ende des Bereiches
	WORD	BobX;				// Start im neuen Level
	WORD	LevelX;				// LevelX-Pos
	struct	Level *NewLevel;	// Nach unten
};

extern	struct		Level *ActLevelPtr,
					*NextLevelPtr;

extern	PLANEPTR	PictureBase;
extern	APTR		CharBase,	
					LevelBase;
extern	LONG		ScrSize;

extern  WORD	LevelX,
				PixelSizeX,
				PixelSizeY;

extern	BYTE		GateFlag,			// TRUE wenn Bob im Bereich eines Gates ist
					HinweisFlag,		// TRUE wenn HinweisBob auf dem Bildschirm ist
					TimeZone,			// Gibt an ob wir in der Gegenwart oder der Zukunft sind
					LastTimeZone;		// Gibt an ob wir in der Gegenwart oder der Zukunft sind

extern	struct Level Level1Tab,
					 Level2Tab,
					 Level3Tab,
					 Level4Tab,
					 Level5Tab,
					 Level6Tab,
					 Level7Tab,
					 Level8Tab,

					 Level11Tab,
					 Level12Tab,
					 Level13Tab,
					 Level14Tab,
					 Level15Tab,
					 Level16Tab,
					 Level17Tab,
					 Level18Tab;


extern void SetUpLevel(void);

