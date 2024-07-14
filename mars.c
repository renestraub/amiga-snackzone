#include "myexec.h"
#include "select.h"
#include "main.h"
#include "id.h"
#include "panel.h"
#include "drawbob.h"
#include "sound.h"

static	struct SelectObject MarsSelect1;

// Wird bei Kollision aufgerufen

void __regargs AlienCollision(struct Bob *mybob, struct Bob *enemybob)
{
	if(ElementList[el_Marsmenschen].flag != Solved)
	{
		Select(&MarsSelect1,enemybob);
	
		enemybob->bob_CollHandler = NULL;
	}
}

static void Ende2(struct Bob *bob)
{
	ElementList[el_Marsmenschen].flag = Solved;
	ElementList[el_Marsgestein].flag = Taken;

	ChangeEmotion(7);
	AddGadget(Marsgestein);
	StartFX(6);
}

static void Ende1(struct Bob *bob)
{
	ChangeEmotion(-3);
	StartFX(7);
}

static struct SelectObject MarsSelect6 =
{
	0,0,
	0,-42,

	"Das kommt mir merkur-\n"
	"ianisch vor! Ich habe\n"
	"in der Schule gelernt,\n"
	"dass Uranus auf dem Weg\n"
	"zum Merkur liegt"
};

static struct SelectObject MarsSelect5 =
{
	0,0,
	0,-42,

	"Vielen Dank fuer Ihre\n"
	"Hilfe. Bitte nehmen Sie\n"
	"dieses wertvolle Stueck\n"
	"Gestein vom Merkur."
};

static struct SelectObject MarsSelect4 =
{
	0,0,
	0,-42,

	"Das kann nicht sein.\n"
	"Ich bin sicher,dass\n"
	"Mars und Jupiter be-\n"
	"nachbart sind. Trotz-\n"
	"dem Vielen Dank"
};

static struct SelectObject MarsSelect3 =
{
	-50,0,
	0,-42,

	"   Auf der Erde\n"
	"     -hmmm-\n"
	"    schlecht.\n"
	" Koennen Sie uns\n"
	"den Weg zum Neptun\n"
	"    erklaeren",

	0,0,"-Sorry keine Ahnung",NULL,NULL,
	0,0,"-Erde-Mars-Saturn-\n"
		" Jupiter-Uranus-Neptun",&MarsSelect4,&Ende1,
	0,0,"-Erde-Venus-Saturn-\n"
		" Jupiter-Uranus-Neptun",&MarsSelect4,&Ende1,
	0,0,"-Erde-Mars-Jupiter-\n"
		" Saturn-Uranus-Neptun",&MarsSelect5,&Ende2,
	0,0,"-Erde-Venus-Jupiter-\n"
		" Saturn-Neptun",&MarsSelect6,&Ende1
};

static struct SelectObject MarsSelect2 =
{
	0,0,
	0,-42,

	"Nein durchaus\n"
	"nicht,mein Herr\n"
	"Wir kommen vom\n"
	"Merkur und kennen\n"
	"uns hier nicht aus\n"
	"Wir haben einen\n"
	"dringenden Termin\n"
	"auf dem 2.Mond des\n"
	"Neptun und koennen\n"
	"ihn nicht finden.",

	0,0,"Nun dies ist die\n"
		"Erde, wir haben\n"
		"nur 1 Mond",&MarsSelect3,NULL,
	0,0,"Viel Erfolg bei\n"
		"der Suche. Auf\n"
		"Wiedersehen.",NULL,NULL
};

static struct SelectObject MarsSelect1 =
{
	0,0,
	0,-42,
	" . as=dD RET H$&&%\n"
	"   SDFgdf$Ftzs....\n"
	"..Sprachcomputer an..\n"
	"Hallo Sie !  Sind wir\n"
	"hier auf dem Planeten\n"
	"Neptun ?",
	
	0,0,"Weitergehen",NULL,NULL,
	0,0,"Nein dies ist\n"
		"die Erde",&MarsSelect3,NULL,
	0,0,"Wollen sie mich\n"
		"verkohlen",&MarsSelect2,NULL
};
