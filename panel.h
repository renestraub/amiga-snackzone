
void __regargs AddGadget(short);
void __regargs RemoveGadget(short);

void __regargs ChangeEmotion(WORD num);
void __regargs ChangeEnergy(WORD num);
void __regargs ChangeSnack(WORD num);
void __regargs ChangeMoney(WORD num);

extern	LONG	GameTimer;


struct ElementItem
{
	short flag;
	long  timer1;
};

struct GadgetItem
{
	BYTE num;
};

extern struct ElementItem ElementList[];
extern struct GadgetItem GadgetList[];

struct NumObject
{
	WORD	type;
	WORD	tx,ty;
	WORD	x,y,w,h;			/* Koordinate */
	LONG	value;
	LONG	lastvalue;
	char	fmtstr[16];
};

struct RectObject
{
	WORD	type;
	WORD	x,y,w,h;
	WORD	value;
	WORD	actvalue;
	WORD	lastvalue;
};

struct IconObject
{
	WORD	type;
	WORD	x,y;
	WORD	bobnum;
	WORD	lastbobnum;
};

enum Catstate
{
	Normal,
	Solved,
	Talked,
	Running,
	Taken,
	Returned
};

enum Elements
{
	el_Katze,
	el_Zuhaelter,
	el_Hund,
	el_Tuersteher,
	el_Kondom,
	el_Arbeiter,
	el_Eistee,
	el_Werkzeug,
	el_Rennen,
	el_Halskette,
	el_Siegelring,	
	el_Ohrring,
	el_Schnuller,
	el_Kinderwagen,
	el_Honighuber,
	el_Marsmenschen,
	el_Marsgestein,
	el_Spock,
	el_Blondine1,
	el_Blondine2,
	el_Strumpfhose,
	el_Rollerskates,
	el_Musiker,
	el_Magnet,
	el_Roentgen,
	el_Faden,
	el_Fremder,
	el_Foodmuseum,
	el_Oma,
	el_Wespe,
	el_Kino,
	el_Kaugummi,
	el_Bifiroll,
	el_Feder,
	el_Kneipe,
	el_PaintSpiel,
	el_Ticket,
	el_DiscoGegenwart,
	el_DiscoFuture,
	el_Schallplatte,
	el_Schrotti,
	el_Zeitmaschine,
	el_Sokoban,
	el_Waerter,
	el_Bedienteil,
	el_Videogamemuenze,
	el_Rocker,
	el_FederInfo,
	el_Agent,
	el_VMann,

	NumElements
};

enum Gadgets
{
	Dummy,
	Marsgestein,
	Ohrring,
	Ring,
	Katze,
	Briefumschlag,
	SpaceTaler,
	Magnet,
	Roentgengeraet,
	Ticket,
	Nadel,
	Zeitmaschine,
	Skalpel,
	Werkzeugkiste,
	Rollerskates,	
	Honig,
	Taler,
	Lipton,
	Dokument,
	Schnuller,
	Kaugummi,
	Kinokarte,
	Schallplatte,
	Videogamemuenze,
	Feder,
	Faden,
	Strumpfhose,
	Halskette,
	Kondom,

	Leerfeld,

	Patent,

	NumGadgets
};

extern	struct NumObject MoneyObject;
extern	struct RectObject EnergyObject;
extern	struct RectObject EmotionObject;
extern	struct RectObject SnackObject;
