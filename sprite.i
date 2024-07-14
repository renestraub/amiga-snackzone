
	IFD	SPRITE_S
	 XDEF	InitSprite,SpriteHandler,ClearRonny
	 XDEF	_PfeilFlag,@ClearPfeil,_PfeilStrobe
	 XDEF	SetSprPos		;;,CopyMap32

	 XDEF	_ShowSpr
	ENDC

	IFND	SPRITE_S
	 XREF	InitSprite,SpriteHandler,ClearRonny
	 XREF	_PfeilFlag,@ClearPfeil,_PfeilStrobe
	 XREF	SetSprPos		;;,CopyMap32

	 XREF	_ShowSpr
	ENDC
