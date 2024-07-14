
struct SizeStruct
{
	short x;
	short y;
	short w;
	short h;
	short xdiff;
	short yoffset;
	char  *txt;
};

short	__regargs GetLineLength(char *);
struct	Window * CreateBlase(struct SizeStruct *);
void	__regargs Blase(short, short, char *);
void	ScanText(struct SizeStruct *);
