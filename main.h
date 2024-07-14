
extern	BYTE	NoInt;
extern	BYTE	EndFlag;

extern	WORD	Processor;

extern	APTR	ImmerBobBase;

extern	struct	BitMap ViewBitmStr;
extern	struct	BitMap DrawBitmStr;
extern	struct	Bob	*MyBob;
extern	BYTE	LeftLock,RightLock;
extern	LONG	GameTimer;
extern	struct	BitMap *ActBitmap;

extern	WORD	PfeilFlag;

extern	void	__regargs DelayBlank(void);
extern	void	__regargs ClearPfeil(void);
