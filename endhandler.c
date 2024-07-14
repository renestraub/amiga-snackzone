#include "myexec.h"
#include "gfx.h"
#include "main.h"
#include "show.h"

void __regargs OutOfEnergyEnd(void)
{
	ShowIFF("Abspann1",NULL,1);
}

void __regargs GameWon(void)
{
	ShowIFF("Abspann2",NULL,1);
	ShowIFF("Abspann3",NULL,1);
	ShowIFF("Abspann4",NULL,1);
	ShowIFF("Abspann5",NULL,1);
	ShowIFF("Abspann6",NULL,1);
	ShowIFF("Abspann7",NULL,1);
}
