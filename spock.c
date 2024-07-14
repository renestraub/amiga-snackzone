#include "myexec.h"
#include "select.h"
#include "main.h"
#include "id.h"
#include "panel.h"
#include "drawbob.h"
#include "sound.h"

static	struct	SelectObject SpockSelect1,SpockSelect10,SpockSelect11;
static	struct	SelectObject SpockSelect12,SpockSelect13,SpockSelect14;
static	short	counter;

void __regargs SpockHandler(struct Bob *bob, LONG value)
{
	if(ElementList[el_Spock].flag == Solved && bob->bob_CollHandler)
	{
		RemBob(bob);
	}
}

// Wird bei Kollision aufgerufen

void __regargs SpockCollision(struct Bob *mybob, struct Bob *enemybob)
{
	if(ElementList[el_Spock].flag == Solved)	return;

	counter = 0;
	Select(&SpockSelect1,enemybob);

	enemybob->bob_CollHandler = NULL;
}

static void Auswertung(struct Bob *bob)
{
	switch(counter)
	{
		case 0:
			Select(&SpockSelect10,bob);
			ChangeEmotion(-7);
			break;

		case 1:
			Select(&SpockSelect11,bob);
			ChangeEmotion(-4);
			break;

		case 2:
			Select(&SpockSelect12,bob);
			ChangeMoney(5);
			StartFX(2);
			ShowMoney();
			break;

		case 3:
			Select(&SpockSelect13,bob);
			ChangeEmotion(4);
			ChangeMoney(10);
			StartFX(2);
			ShowMoney();
			break;

		case 4:
			Select(&SpockSelect14,bob);
			ChangeEmotion(7);
			ChangeMoney(15);
			StartFX(2);
			ShowMoney();
			break;
	}
	ElementList[el_Spock].flag = Solved;
}

static void Correct(struct Bob *bob)
{
	StartFX(6);
	counter++;
}

static void Correct2(struct Bob *bob)
{
	StartFX(6);
	counter++;

	Auswertung(bob);
}

static void InCorrect(struct Bob *bob)
{
	StartFX(7);
}

static struct SelectObject SpockSelect10 =
{
	0,0,
	0,-48,

	"Vielen Dank fuer Ihre\n"
	"Mitarbeit. Sie haben\n"
	"keine Frage richtig\n"
	"beantwortet. Das ist\n"
	"ja beschaemend."
};

static struct SelectObject SpockSelect11 =
{
	0,0,
	0,-48,

	"Vielen Dank fuer Ihre\n"
	"Mitarbeit. Sie haben\n"
	"1 Frage richtig\n"
	"beantwortet. Etwas\n"
	"bescheiden oder wie ?"
};

static struct SelectObject SpockSelect12 =
{
	0,0,
	0,-48,

	"Vielen Dank fuer Ihre\n"
	"Mitarbeit.Sie haben\n"
	"2 Fragen richtig\n"
	"beantwortet.\n"
	"Ihre Leistung war\n"
	"ausreichend. Sie\n"
	"kriegen 5 ECU."
};

static struct SelectObject SpockSelect13 =
{
	0,0,
	0,-48,

	"Vielen Dank fuer Ihre\n"
	"Mitarbeit.Sie haben\n"
	"3 Fragen richtig\n"
	"beantwortet.\n"
	"Ihre Leistung war gut.\n"
	"Sie kriegen 10 ECU."
};

static struct SelectObject SpockSelect14 =
{
	0,0,
	0,-48,

	"Vielen Dank fuer Ihre\n"
	"Mitarbeit.Sie haben\n"
	"4 Fragen richtig\n"
	"beantwortet.\n"
	"Ihre Leistung war\n"
	"hervorragend. Sie\n"
	"kriegen 15 ECU."
};

static struct SelectObject SpockSelect5 =
{
	-1,-1,
	0,-48,

	"Welches Wort\n"
	"passt hier\n"
	"nicht ?",

	0,0,"Stunde",NULL,&Auswertung,
	0,0,"Monat",NULL,&Auswertung,
	0,0,"Lichtjahr",NULL,&Correct2,
	0,0,"Tag",NULL,&Auswertung,
	0,0,"Sekunde",NULL,&Auswertung,
	0,0,"Minute",NULL,&Auswertung
};

static struct SelectObject SpockSelect4 =
{
	-1,-1,
	0,-48,
	"Welcher\n"
	"Buchstabe\n"
	"folgt auf\n"
	"OQ PR FE I?\n",

	0,0,"A",&SpockSelect5,&InCorrect,
	0,0,"L",&SpockSelect5,&Correct,
	0,0,"K",&SpockSelect5,&InCorrect,
	0,0,"P",&SpockSelect5,&InCorrect,
	0,0,"V",&SpockSelect5,&InCorrect,
	0,0,"R",&SpockSelect5,&InCorrect
};

static struct SelectObject SpockSelect3 =
{
	-1,-1,
	0,-48,
	"Welche Zahl\n"
	"folgt auf\n"
	"1,1,2,3,\n"
	"5,8,13 ?\n",

	0,0,"10",&SpockSelect4,&InCorrect,
	0,0,"14",&SpockSelect4,&InCorrect,
	0,0,"15",&SpockSelect4,&InCorrect,
	0,0,"17",&SpockSelect4,&InCorrect,
	0,0,"20",&SpockSelect4,&InCorrect,
	0,0,"21",&SpockSelect4,&Correct
};

static struct SelectObject SpockSelect2 =
{
	-1,-1,
	0,-48,
	"Welche Zahl\n"
	"folgt auf\n"
	"8,1,9,3\n"
	"10,5,11,7\n"
	"12",

	0,0,"6",&SpockSelect3,&InCorrect,
	0,0,"8",&SpockSelect3,&InCorrect,
	0,0,"9",&SpockSelect3,&Correct,
	0,0,"10",&SpockSelect3,&InCorrect,
	0,0,"13",&SpockSelect3,&InCorrect,
	0,0,"15",&SpockSelect3,&InCorrect
};

static struct SelectObject SpockSelect1 =
{
	0,0,
	0,-48,
	"Guten Tag. Ich bin\n"
	"im Auftrag der\n"
	"vulkanischen Gilde\n"
	"fuer Nachwuchs-\n"
	"logiker unterwegs.\n"
	"Darf ich Ihnen\n"
	"einige schwierige\n"
	"Fragen stellen ?",

	0,0,"Ja gerne",&SpockSelect2,NULL,
	0,0,"Nein keine Zeit",NULL,NULL
};
