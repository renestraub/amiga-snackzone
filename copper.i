
	IFD	COPPER_S

	XDEF	BlackCopper
	XDEF	CopperList,CopperSprites
	XDEF	_CopperList
	XDEF	BitMapPtrs,c_bplcon1
	XDEF	@FadeOutCopper,@FadeInCopper
	XDEF	FadeOutCopp,FadeInCopp
	XDEF	_PanelPtrs,_PanelColors
	XDEF	@SetColors,@SetPointers,@CopyColorMap,@SetCopperList
	XDEF	BlackCopper

	ENDC

	IFND	COPPER_S

	XREF	BlackCopper
	XREF	CopperList,CopperSprites
	XREF	_CopperList
	XREF	BitMapPtrs,c_bplcon1
	XREF	@FadeOutCopper,@FadeInCopper
	XREF	PanelColors,PanelPtrs				* CopperList	
	XREF	FadeOutCopp,FadeInCopp
	XREF	@SetCopperList
	XREF	BlackCopper

	ENDC

; ***** COPPER MACROS, last update: 05-Dec-87 ***********************

cmove:		macro
		  dc.w	((\2)&$01fe)		; Zielregister
		  dc.w	\1
		endm

cmovel:		macro
		  dc.w	((\2)&$01fe)		; Zielregister Hi-Word
		  dc.w	(\1)/$10000
		  dc.w	((\2)&$01fe)+2		; Zielregister Lo-Word
		  dc.w	(\1)&$ffff		
		endm

ccwait:		macro
		  dc.w	(\1)&$fffe|$0001	; Rasterzeile und -Spalte
		  dc.w	(\2)&$7ffe|$8000	; Compare-Enable-Maske
		endm

cend:		macro
		  dc.w	$ffff,$fffe
		endm


