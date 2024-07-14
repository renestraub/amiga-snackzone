
#define		STOF_SELECTED		1
#define		STOF_DISABLED		2

#define		END_DIALOG			0

#define		MAX_SELECT			9

struct SelectTextObject
{
	short	x,y;
	char	*text;							// der Text
	struct	SelectObject *newobject;		// der neue Dialog
	void	(*handler)(struct Bob *);		// die Routine
};

struct SelectObject
{
	WORD	herox,heroy;					// Meine Position (OFFSET)
	WORD	enemyx,enemyy;					// Gegner Position (OFFSET)

	char	*EnemyText;						// Der Text des Gegners
	struct	SelectTextObject SelectText[MAX_SELECT];	// Meine Auswahl
};

WORD __regargs Select(struct SelectObject *, struct Bob *);
extern	void __regargs ShowMoney(void);
