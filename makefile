##############################################################################
#        	                                                             #
#   Makefile für Rolling Ronny                         		             #
#                                                        		     #
#   Created: 18-May-89 CHW             		  Last update: 12-12-92 RHS  #
#                                               	                     #
##############################################################################

#### Allgemeine Flags:

AFLAGS	  = -ih: -l
LFLAGS    = SMALLCODE SMALLDATA NOICONS
ASM	  = Genim2

EXEC	  = Projects:SnackZone/Exec/
DRIVE     = Projects:SnackZone/Game/
BACKUP    = Projects:SnackZone/Backup/

MODS      = Main.o Gfx.o Collision.o JoyStick.o\
            Bobs.o Copper.o DosFileNames.o ExecBase.o Interface.o Menu.o\
            Scroll.o Panel.o Sprite.o RonnyMove.o Enemy.o CXM33.o\
	    Level.o Flags1.o Flags11.o Blase.o Select.o Show.o Iff.o\
	    Katze.o UBahn.o Zuhaelter.o Tuersteher.o Arbeiter.o Tankstelle.o\
	    Skater.o Disco.o Kiosk.o Haendler.o Kinderwagen.o Huber.o Snack.o\
	    Mars.o Spock.o Blondine.o Musiker.o Roboter.o Fremder.o Oma.o Wespe.o\
	    Sound.o Kino.o BigSprite.o StromGame.o Schrotti.o Kneipe.o\
	    Platte.o Museum.o Rocker.o AutoHandler.o EndHandler.o SkaterGame.o\
	    SkaterDialog.o Money.o Agent.o GetCPUType.o


IMODS = lib:c.o Install.o

#### Regeln: 

.S.O:
	$(ASM) $*.S -o$*.o $(AFLAGS)
	Copy   $*.S $(BACKUP)

.C.O:
	SC     $*.c
	Copy   $*.C $(BACKUP)


#### Programme:

All:	Main HD-Install

Main:	$(MODS)
	SLink WITH WithFile
	SpecAbsLoad >NIL: -d -o$(DRIVE)MainPrg Main

HD-Install: $(IMODS)
	SLink FROM $(IMODS) TO $*\
	LIB lib:sc.lib lib:itools.lib


Enemy.o:	enemy.i Game/hero.i
Bobs.o:		bobs.i Game/immerbobs.i Game/gegenbobs.i Game/futurebobs.i
PanelBob.o:	Game/panelbobs.i
RonnyMove.o:	Game/immerbobs.i
RonnyMove.o:	definitions.i
Panel.o:	panel.h
Gfx.o:		gfx.i gfx.h
Level.o:	gfx.h level.h select.h leveldat.h panel.h
Panel.o:	gfx.h panel.h
Blase.o:	gfx.h blase.h
HiScore.o:	gfx.h joystick.h
Select.o:	blase.h joystick.h select.h
Interface.o:	MyExec.h
sound.o:	Sound.h
Sprite.o:	Sprite.i
