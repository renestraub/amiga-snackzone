
	IFD	SCROLL_S
	 XDEF	@SoftScroll,_FlipScreen,_DrawChar,GetElem,GetInfo
	 XDEF	@SoftScroll2
	 XDEF	@SetBitmapPtrs
	 XDEF	_FlipFlag

	 XREF	DrawChar
	 XREF	_ViewBitmStr,_DrawBitmStr
	 XREF	_PictureBase,_ScrSize,_LevelX,_LastLevelX
	 XREF	_CharBase,_LevelBase
	 XREF	_LevelFlags,_PictureBase
	 XREF	_SizeX,_SizeY
	ENDC

	IFND	SCROLL_S
	 XREF	@SoftScroll,_FlipScreen,_DrawChar,GetElem,GetInfo
	 XREF	@SoftScroll2
	 XREF	_FlipFlag
	ENDC

