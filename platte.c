#include "myexec.h"
#include "select.h"
#include "main.h"
#include "id.h"
#include "panel.h"
#include "drawbob.h"
#include "sound.h"

void __regargs PlatteHandler(struct Bob *mybob, LONG l)
{
	if(ElementList[el_Schallplatte].flag != 0)
	{
		RemBob(mybob);
	}
}

// Wird bei Kollision aufgerufen

void __regargs PlatteCollision(struct Bob *mybob, struct Bob *enemybob)
{
	ElementList[el_Schallplatte].flag = Taken;

	AddGadget(Schallplatte);
	RemBob(enemybob);

	StartFX(2);
}
