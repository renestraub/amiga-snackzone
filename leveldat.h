
extern		APTR flags1,flags11;
extern		struct LevelBob  EnemyList1[];
extern		struct LevelBob  EnemyList2[];
extern		struct LevelBob  EnemyList3[];
extern		struct LevelBob  EnemyList4[];
extern		struct LevelBob  EnemyList5[];
extern		struct LevelBob  EnemyList6[];
extern		struct LevelBob  EnemyList7[];
extern		struct LevelBob  EnemyList8[];

extern		struct LevelBob  EnemyList11[];
extern		struct LevelBob  EnemyList12[];
extern		struct LevelBob  EnemyList13[];
extern		struct LevelBob  EnemyList14[];
extern		struct LevelBob  EnemyList15[];
extern		struct LevelBob  EnemyList16[];
extern		struct LevelBob  EnemyList17[];
extern		struct LevelBob  EnemyList18[];

// Palette für die Gegenwart

WORD Level1ColorMap[] =
{
	0x000,0xDDA,0x996,0xFF0,0xAA0,0x270,0x592,0x8D5,
	0x0F0,0xE65,0x00F,0x007,0xF0F,0x909,0xACF,0x78B,
	0xFFF,0xCCC,0xAAA,0x888,0x666,0x444,0x333,0xEB9,
	0xC97,0xA75,0x850,0x530,0xC70,0xA50,0xC00,0xF33,

	0x0F65,0x0E65,0x0F65,0x0F66,0x0F65,0x0F66,0x0F78,0x0F66,
	0x0F78,0x0F79,0x0F78,0x0F79,0x0F7A,0x0F79,0x0F7A,0x0F7B,
	0x0F7A,0x0F7B,0x0F7C,0x0F7B,0x0F7C,0x0F7D,0x0F7C,0x0F7D,
	0x0F7E,0x0F7D,0x0F7E,0x0F7F,0x0F7E,0x0F7F,0x0E8E,0x0F7F,
	0x0E8E,0x0D8E,0x0E8E,0x0D8E,0x0C8E,0x0D8E,0x0C8E,0x0B8E,
	0x0C8E,0x0B8E,0x0A8E,0x0B8E,0x0A8E,0x098E,0x0A8E,0x098E,
	0x088E,0x098E,0x088E,0x078E,0x088E,0x078E,0x068E,0x078E,
	0x068E,0x058E,0x068E,0x058E,0x048E,0x058E,0x048E,0x038E,
	0x048E,0x038E,0x067F,0x038E,0x067F,0x0000,

	-1
};

// Palette für die Zukunft

WORD Level11ColorMap[] =
{
	0x000,0xDDA,0x996,0xFF0,0xAA0,0x270,0x592,0x8D5,
	0x0F0,0xE65,0x00F,0x007,0xF0F,0x909,0xACF,0x78B,
	0xFFF,0xCCC,0xAAA,0x888,0x666,0x444,0x333,0xEB9,
	0xC97,0xA75,0x850,0x530,0xC70,0xA50,0xC00,0xF33,

	0x0F65,0x0E65,0x0F65,0x0F66,0x0F65,0x0F66,0x0F78,0x0F66,
	0x0F78,0x0F79,0x0F78,0x0F79,0x0F7A,0x0F79,0x0F7A,0x0F7B,
	0x0F7A,0x0F7B,0x0F7C,0x0F7B,0x0F7C,0x0F7D,0x0F7C,0x0F7D,
	0x0F7E,0x0F7D,0x0F7E,0x0F7F,0x0F7E,0x0F7F,0x0E8E,0x0F7F,
	0x0E8E,0x0D8E,0x0E8E,0x0D8E,0x0C8E,0x0D8E,0x0C8E,0x0B8E,
	0x0C8E,0x0B8E,0x0A8E,0x0B8E,0x0A8E,0x098E,0x0A8E,0x098E,
	0x088E,0x098E,0x088E,0x078E,0x088E,0x078E,0x068E,0x078E,
	0x068E,0x058E,0x068E,0x058E,0x048E,0x058E,0x048E,0x038E,
	0x048E,0x038E,0x067F,0x038E,0x067F,0x0000,

	-1
};

// Level Gegenwart

struct Level Level1Tab;
struct Level Level2Tab;
struct Level Level3Tab;
struct Level Level4Tab;
struct Level Level5Tab;
struct Level Level6Tab;
struct Level Level7Tab;
struct Level Level8Tab;

// Level Zukunft

struct Level Level11Tab;
struct Level Level12Tab;
struct Level Level13Tab;
struct Level Level14Tab;
struct Level Level15Tab;
struct Level Level16Tab;
struct Level Level17Tab;
struct Level Level18Tab;

// Gates Gegenwart

struct Gate Level1Gate1;
struct Gate Level1Gate2;
struct Gate Level1Gate3;
struct Gate Level1Gate4;

struct Gate Level2Gate1;
struct Gate Level2Gate2;
struct Gate Level2Gate3;

struct Gate Level3Gate1;
struct Gate Level3Gate2;
struct Gate Level3Gate3;
struct Gate Level3Gate4;
struct Gate Level3Gate5;

struct Gate Level4Gate1;
struct Gate Level4Gate2;
struct Gate Level4Gate3;

struct Gate Level5Gate1;
struct Gate Level5Gate2;

struct Gate Level6Gate1;
struct Gate Level6Gate2;
struct Gate Level6Gate3;

struct Gate Level7Gate1;

struct Gate Level8Gate1;
struct Gate Level8Gate2;

// Gates Zukunft

struct Gate Level11Gate1;
struct Gate Level11Gate2;
struct Gate Level11Gate3;
struct Gate Level11Gate4;

struct Gate Level12Gate1;
struct Gate Level12Gate2;
struct Gate Level12Gate3;

struct Gate Level13Gate1;
struct Gate Level13Gate2;
struct Gate Level13Gate3;
struct Gate Level13Gate4;
struct Gate Level13Gate5;

struct Gate Level14Gate1;
struct Gate Level14Gate2;
struct Gate Level14Gate3;

struct Gate Level15Gate1;
struct Gate Level15Gate2;

struct Gate Level16Gate1;
struct Gate Level16Gate2;
struct Gate Level16Gate3;

struct Gate Level17Gate1;

struct Gate Level18Gate1;
struct Gate Level18Gate2;

/**** LEVEL 1 (5th. Avenue) *****************************************************/

struct Level Level1Tab =
{
	"char1",				// CharacterSet
	"level1",				// LevelDaten
	"gegenbobs",			// BobFile
	&flags1,				// Flags
	EnemyList1-1,			// EnemyList Left
	EnemyList1,				// EnemyList Right
	&Level1ColorMap,		// ColorMap
	&Level1Gate1,			// Die Gateways
	0,						// LevelX
	100,					// StartX
	175,					// StartY
	0,						// StrassenschildBob
	1,						// UbahnLinie	
};

struct Gate Level1Gate1 =	// Gate to SnackStreet
{
	&Level1Gate2,
	lgf_Gate,				// Flags
	1380,1420,
	680,					// BobX
	520,					// LevelX
	&Level6Tab
};

struct Gate Level1Gate2 =	// Gate to Dammtorwall
{
	&Level1Gate3,
	lgf_Gate,				// Flags
	980,1020,
	674,					// BobX
	414,					// LevelX
	&Level5Tab
};

struct Gate Level1Gate3 =	// Gate to River Street
{
	&Level1Gate4,
	lgf_Gate,				// Flags
	600,640,
	110,					// BobX
	0,						// LevelX
	&Level3Tab
};

struct Gate Level1Gate4 =	// Gate to River Street
{
	NULL,
	lgf_Subway,				// Flags
	120,140,
	0,						// BobX
	0,						// LevelX
	NULL
};

/**** LEVEL 2 (Route 66) ********************************************************/

struct Level Level2Tab =
{
	"char1",				// CharacterSet
	"level2",				// LevelDaten
	"gegenbobs",			// BobFile
	&flags1,				// Flags
	EnemyList2-1,			// EnemyList Left
	EnemyList2,				// EnemyList Right
	&Level1ColorMap,		// ColorMap
	&Level2Gate1,			// Die Gateways
	0,						// LevelX
	0,						// StartX
	175,					// StartY
	1,						// StrassenschildBob
	-1,						// UBahnLinie	
};

struct Gate Level2Gate1 =	// Gate to SnackStreet
{
	&Level2Gate2,
	lgf_Gate,				// Flags
	1380,1420,
	938,					// BobX
	609,					// LevelX
	&Level6Tab
};

struct Gate Level2Gate2 =	// Gate to Dammtorwall
{
	&Level2Gate3,
	lgf_Gate,				// Flags
	980,1020,
	938,					// BobX
	610,	//674,					// LevelX
	&Level5Tab
};

struct Gate Level2Gate3 =	// Gate to Königsalle
{
	NULL,
	lgf_Gate,				// Flags
	600,640,
	528,					// BobX
	345,					// LevelX
	&Level3Tab
};

/**** LEVEL 3 (Königsallee) ******************************************************/

struct Level Level3Tab =
{
	"char1",				// CharacterSet
	"level3",				// LevelDaten
	"gegenbobs",			// BobFile
	&flags1,				// Flags
	EnemyList3-1,			// EnemyList Left
	EnemyList3,				// EnemyList Right
	&Level1ColorMap,		// ColorMap
	&Level3Gate1,			// Die Gateways
	0,						// LevelX
	100,					// StartX
	175,					// StartY
	2,						// StrassenschildBob
	0,						// UbahnLinie	
};

struct Gate Level3Gate1 =	// Gate to 5th Avenue
{
	&Level3Gate2,
	lgf_Gate,				// Flags
	90,130,
	620,					// BobX
	438,					// LevelX
	&Level1Tab
};

struct Gate Level3Gate2 =	// Gate to Route 66
{
	&Level3Gate3,
	lgf_Gate,				// Flags
	508,548,
	620,					// BobX
	438,					// LevelX
	&Level2Tab
};

struct Gate Level3Gate3 =	// Gate to Strip
{
	&Level3Gate4,
	lgf_Gate,				// Flags
	1460,1500,
	80,						// BobX
	0,						// LevelX
	&Level7Tab
};

struct Gate Level3Gate4 =	// Gate to Baker Street
{
	&Level3Gate5,
	lgf_Gate,				// Flags
	1747,1787,
	700,					// BobX
	515,					// LevelX
	&Level4Tab
};

struct Gate Level3Gate5 =	// Gate to Baker Street
{
	NULL,
	lgf_Subway,				// Flags
	1100,1120,
	0,						// BobX
	0,						// LevelX
	NULL
};


/**** LEVEL 4 (Baker Street) ****************************************************/

struct Level Level4Tab =
{
	"char1",				// CharacterSet
	"level4",				// LevelDaten
	"gegenbobs",			// BobFile
	&flags1,				// Flags
	EnemyList4-1,			// EnemyList Left
	EnemyList4,				// EnemyList Right
	&Level1ColorMap,		// ColorMap
	&Level4Gate1,			// Die Gateways
	0,						// LevelX
	100,					// StartX
	175,					// StartY
	3,						// StrassenschildBob
	4,						// UbahnLinie	
};

struct Gate Level4Gate1 =	// Gate to Baker Street
{
	&Level4Gate2,
	lgf_Gate,				// Flags
	680,720,
	1767,					// BobX
	1564,					// LevelX
	&Level3Tab
};

struct Gate Level4Gate2 =	// Gate to Baker Street
{
	&Level4Gate3,
	lgf_Gate,				// Flags
	120,160,
	60,						// BobX
	0,						// LevelX
	&Level8Tab
};

struct Gate Level4Gate3 =	// Gate to Baker Street
{
	NULL,
	lgf_Subway,				// Flags
	1736,1756,
	0,						// BobX
	0,						// LevelX
	NULL
};

/**** LEVEL 5 (Dammtorwall) ******************************************************/

struct Level Level5Tab =
{
	"char1",				// CharacterSet
	"level5",				// LevelDaten
	"gegenbobs",			// BobFile
	&flags1,				// Flags
	EnemyList5-1,			// EnemyList Left
	EnemyList5,				// EnemyList Right
	&Level1ColorMap,		// ColorMap
	&Level5Gate1,			// Die Gateways
	200,					// LevelX
	100,					// StartX
	175,					// StartY
	4,						// StrassenschildBob
	-1,						// UbahnLinie	
};

struct Gate Level5Gate1 =	// Gate to 5th Avenue
{
	&Level5Gate2,
	lgf_Gate,				// Flags
	654,694,
	1000,
	850,
	&Level1Tab
};

struct Gate Level5Gate2 =	// Gate to Route 66
{
	NULL,
	lgf_Gate,				// Flags
	900,940,
	1008,
	824,
	&Level2Tab
};

/**** LEVEL 6 (SnackStreet = StartLevel) ****************************************/

struct Level Level6Tab =
{
	"char1",				// CharacterSet
	"level6",				// LevelDaten
	"gegenbobs",			// BobFile
	&flags1,				// Flags
	EnemyList6-1,			// EnemyList Left
	EnemyList6,				// EnemyList Right
	&Level1ColorMap,		// ColorMap
	&Level6Gate1,			// Die Gateways
	0,						// LevelX
	100,					// BobX
	175,					// BobY
	5,						// StrassenschildBob
	2,						// UbahnLinie	
};

struct Gate Level6Gate1 =	// Gate to 5th Avenue
{
	&Level6Gate2,
	lgf_Gate,				// Flags
	660,700,
	1400,					// BobX
	1244,					// LevelX
	&Level1Tab
};

struct Gate Level6Gate2 =	// Gate to Route 66
{
	&Level6Gate3,
	lgf_Gate,				// Flags
	900,940,
	1400,					// BobX
	1244,					// LevelX
	&Level2Tab
};

struct Gate Level6Gate3 =	// Subway Station
{
	NULL,
	lgf_Subway,				// Flags
	30,60,
	0,						// BobX
	0,						// LevelX
	NULL
};

/**** LEVEL 7 (Strip) ***********************************************************/

struct Level Level7Tab =
{
	"char1",				// CharacterSet
	"level7",				// LevelDaten
	"gegenbobs",			// BobFile
	&flags1,				// Flags
	EnemyList7-1,			// EnemyList Left
	EnemyList7,				// EnemyList Right
	&Level1ColorMap,		// ColorMap
	&Level7Gate1,			// Die Gateways
	0,						// LevelX
	100,					// StartX
	175,					// StartY
	6,						// StrassenschildBob
	-1,						// UbahnLinie	
};

struct Gate Level7Gate1 =	// Gate to Baker Street
{
	NULL,
	lgf_Gate,				// Flags
	60,100,
	1480,					// BobX
	1276,					// LevelX
	&Level3Tab
};

/**** LEVEL 8 (Eyberstrasse) ****************************************************/

struct Level Level8Tab =
{
	"char11",				// CharacterSet
	"level8",				// LevelDaten
	"gegenbobs",			// BobFile
	&flags1,				// Flags
	EnemyList8-1,			// EnemyList Left
	EnemyList8,				// EnemyList Right
	&Level1ColorMap,		// ColorMap
	&Level8Gate1,			// Die Gateways
	0,						// LevelX
	100,					// StartX
	175,					// StartY
	7,						// StrassenschildBob
	3,						// UbahnLinie	
};

struct Gate Level8Gate1 =	// Gate to Baker Street
{
	&Level8Gate2,
	lgf_Gate,				// Flags
	40,80,
	140,					// BobX
	0,						// LevelX
	&Level4Tab
};

struct Gate Level8Gate2 =	// Gate to Baker Street
{
	NULL,
	lgf_Subway,				// Flags
	550,570,
	0,						// BobX
	0,						// LevelX
	NULL
};





/**** LEVEL 11 (5th. Avenue) *****************************************************/

struct Level Level11Tab =
{
	"char11",				// CharacterSet
	"level11",				// LevelDaten
	"futurebobs",			// BobFile
	&flags11,				// Flags
	EnemyList11-1,			// EnemyList Left
	EnemyList11,				// EnemyList Right
	&Level11ColorMap,		// ColorMap
	&Level11Gate1,			// Die Gateways
	0,						// LevelX
	100,					// StartX
	175,					// StartY
	9,						// StrassenschildBob
	1,						// UbahnLinie	
};

struct Gate Level11Gate1 =	// Gate to SnackStreet
{
	&Level11Gate2,
	lgf_Gate,				// Flags
	1380,1420,
	680+16,					// BobX
	520+16,					// LevelX
	&Level16Tab
};

struct Gate Level11Gate2 =	// Gate to Dammtorwall
{
	&Level11Gate3,
	lgf_Gate,				// Flags
	1000,1040,
	600,					// BobX
	440,					// LevelX
	&Level15Tab
};

struct Gate Level11Gate3 =	// Gate to River Street
{
	&Level11Gate4,
	lgf_Gate,				// Flags
	600,640,
	110,					// BobX
	0,						// LevelX
	&Level13Tab
};

struct Gate Level11Gate4 =	// Gate to River Street
{
	NULL,
	lgf_Subway,				// Flags
	134,162,
	0,						// BobX
	0,						// LevelX
	NULL
};

/**** LEVEL 12 (Route 66) ********************************************************/

struct Level Level12Tab =
{
	"char11",				// CharacterSet
	"level12",				// LevelDaten
	"futurebobs",			// BobFile
	&flags11,				// Flags
	EnemyList12-1,			// EnemyList Left
	EnemyList12,				// EnemyList Right
	&Level11ColorMap,		// ColorMap
	&Level12Gate1,			// Die Gateways
	0,						// LevelX
	0,						// StartX
	175,					// StartY
	14,						// StrassenschildBob
	-1,						// UbahnLinie	
};

struct Gate Level12Gate1 =	// Gate to SnackStreet
{
	&Level12Gate2,
	lgf_Gate,				// Flags
	1380,1420,
	938,					// BobX
	609,					// LevelX
	&Level16Tab
};

struct Gate Level12Gate2 =	// Gate to Dammtorwall
{
	&Level12Gate3,
	lgf_Gate,				// Flags
	1000,1040,
	938,					// BobX
	606,					// LevelX
	&Level15Tab
};

struct Gate Level12Gate3 =	// Gate to Königsalle
{
	NULL,
	lgf_Gate,				// Flags
	600,640,
	528,					// BobX
	345,					// LevelX
	&Level13Tab
};

/**** LEVEL 13 (Königsalle) ******************************************************/

struct Level Level13Tab =
{
	"char11",				// CharacterSet
	"level13",				// LevelDaten
	"futurebobs",			// BobFile
	&flags11,				// Flags
	EnemyList13-1,			// EnemyList Left
	EnemyList13,				// EnemyList Right
	&Level11ColorMap,		// ColorMap
	&Level13Gate1,			// Die Gateways
	0,						// LevelX
	100,					// StartX
	175,					// StartY
	12,						// StrassenschildBob
	0,						// UbahnLinie	
};

struct Gate Level13Gate1 =	// Gate to 5th Avenue
{
	&Level13Gate2,
	lgf_Gate,				// Flags
	84,124,
	620,					// BobX
	438,					// LevelX
	&Level11Tab
};

struct Gate Level13Gate2 =	// Gate to Route 66
{
	&Level13Gate3,
	lgf_Gate,				// Flags
	508,548,
	620,					// BobX
	438,					// LevelX
	&Level12Tab
};

struct Gate Level13Gate3 =	// Gate to Strip
{
	&Level13Gate4,
	lgf_Gate,				// Flags
	1460-16,1500-16,
	240,					// BobX
	0,						// LevelX
	&Level17Tab
};

struct Gate Level13Gate4 =	// Gate to Baker Street
{
	&Level13Gate5,
	lgf_Gate,				// Flags
	1747,1787,
	1192,					// BobX
	1016,					// LevelX
	&Level14Tab
};

struct Gate Level13Gate5 =	// Gate to Baker Street
{
	NULL,
	lgf_Subway,				// Flags
	1100,1120,
	0,						// BobX
	0,						// LevelX
	NULL
};


/**** LEVEL 14 (Baker Street) ****************************************************/

struct Level Level14Tab =
{
	"char11",				// CharacterSet
	"level14",				// LevelDaten
	"futurebobs",			// BobFile
	&flags11,				// Flags
	EnemyList14-1,			// EnemyList Left
	EnemyList14,				// EnemyList Right
	&Level11ColorMap,		// ColorMap
	&Level14Gate1,			// Die Gateways
	0,						// LevelX
	100,					// StartX
	175,					// StartY
	11,						// StrassenschildBob
	4,						// UbahnLinie	
};

struct Gate Level14Gate1 =	// Gate to Königsallee
{
	&Level14Gate2,
	lgf_Gate,				// Flags
	1172,1212,
	1767,					// BobX
	1567,					// LevelX
	&Level13Tab
};

struct Gate Level14Gate2 =	// Gate to Eyberstrasse
{
	&Level14Gate3,
	lgf_Gate,				// Flags
	680,720,
	60,						// BobX
	0,						// LevelX
	&Level18Tab
};

struct Gate Level14Gate3 =
{
	NULL,
	lgf_Subway,				// Flags
	1836,1856,
	0,						// BobX
	0,						// LevelX
	NULL
};

/**** LEVEL 15 (Dammtorwall) *****************************************************/

struct Level Level15Tab =
{
	"char11",				// CharacterSet
	"level15",				// LevelDaten
	"futurebobs",			// BobFile
	&flags11,				// Flags
	EnemyList15-1,			// EnemyList Left
	EnemyList15,				// EnemyList Right
	&Level11ColorMap,		// ColorMap
	&Level15Gate1,			// Die Gateways
	200,					// LevelX
	100,					// StartX
	175,					// StartY
	8,						// StrassenschildBob
	-1,						// UbahnLinie	
};

struct Gate Level15Gate1 =	// Gate to 5th Avenue
{
	&Level15Gate2,
	lgf_Gate,				// Flags
	580,620,
	1020,
	870,
	&Level11Tab
};

struct Gate Level15Gate2 =	// Gate to Route 66
{
	NULL,
	lgf_Gate,				// Flags
	900,940,
	1020,
	836,
	&Level12Tab
};

/**** LEVEL 16 (SnackStreet = StartLevel) ****************************************/

struct Level Level16Tab =
{
	"char11",				// CharacterSet
	"level16",				// LevelDaten
	"futurebobs",			// BobFile
	&flags11,				// Flags
	EnemyList16-1,			// EnemyList Left
	EnemyList16,			// EnemyList Right
	&Level11ColorMap,		// ColorMap
	&Level16Gate1,			// Die Gateways
	0,						// LevelX
	100,					// BobX
	175,					// BobY
	13,						// StrassenschildBob
	2,						// UbahnLinie	
};

struct Gate Level16Gate1 =	// Gate to 5th Avenue
{
	&Level16Gate2,
	lgf_Gate,				// Flags
	660+16,700+16,
	1400,					// BobX
	1246,					// LevelX
	&Level11Tab
};

struct Gate Level16Gate2 =	// Gate to Route 66
{
	&Level16Gate3,
	lgf_Gate,				// Flags
	900,940,
	1400,					// BobX
	1246,					// LevelX
	&Level12Tab
};

struct Gate Level16Gate3 =	// Subway Station
{
	NULL,
	lgf_Subway,				// Flags
	30,60,
	0,						// BobX
	0,						// LevelX
	NULL
};

/**** LEVEL 17 (Strip) ***********************************************************/

struct Level Level17Tab =
{
	"char11",				// CharacterSet
	"level17",				// LevelDaten
	"futurebobs",			// BobFile
	&flags11,				// Flags
	EnemyList17-1,			// EnemyList Left
	EnemyList17,				// EnemyList Right
	&Level11ColorMap,		// ColorMap
	&Level17Gate1,			// Die Gateways
	0,						// LevelX
	100,					// StartX
	175,					// StartY
	15,						// StrassenschildBob
	-1,						// UbahnLinie	
};

struct Gate Level17Gate1 =	// Gate to Baker Street
{
	NULL,
	lgf_Gate,				// Flags
	220,260,
	1474,					// BobX
	1256,					// LevelX
	&Level13Tab
};

/**** LEVEL 18 (Eyberstrasse) ****************************************************/

struct Level Level18Tab =
{
	"char11",				// CharacterSet
	"level18",				// LevelDaten
	"futurebobs",			// BobFile
	&flags11,				// Flags
	EnemyList18-1,			// EnemyList Left
	EnemyList18,				// EnemyList Right
	&Level11ColorMap,		// ColorMap
	&Level18Gate1,			// Die Gateways
	0,						// LevelX
	100,					// StartX
	175,					// StartY
	10,						// StrassenschildBob
	3,						// UbahnLinie	
};

struct Gate Level18Gate1 =	// Gate to Baker Street
{
	&Level18Gate2,
	lgf_Gate,				// Flags
	40,80,
	700,					// BobX
	500,					// LevelX
	&Level14Tab
};

struct Gate Level18Gate2 =
{
	NULL,
	lgf_Subway,				// Flags
	550,570,
	0,						// BobX
	0,						// LevelX
	NULL
};


