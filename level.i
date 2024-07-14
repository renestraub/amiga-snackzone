
	XREF	_ActLevelPtr,_NextLevelPtr

	XREF	@InitGame,@LoadLevel,@UnLoadLevel,@CreateLevel,@CheckGate,@FreeGame

	XREF	_ViewBitmStr,_DrawBitmStr
	XREF	_PixelSizeX,_PixelSizeY,_SizeX,_SizeY,_LevelX
	XREF	_LEnemyListPtr,_REnemyListPtr,_LevelBobTab
	XREF	_GateFlag,_SubwayFlag

	XREF	_LevelBase,_CharBase


	STRUCTURE LevelStructure,0
		LONG	lv_Char
		LONG	lv_Level
		LONG	lv_Bobs
		LONG	lv_Flags
		APTR	lv_EnemyLeft
		APTR	lv_EnemyRight
		APTR	lv_ColorMap
		APTR	lv_GateWay
		WORD	lv_LevelX
		WORD	lv_RonnyX
		WORD	lv_RonnyY
		WORD	lv_SchildBob
		WORD	lv_UBahnLinie
		LABEL	lv_SIZEOF

	STRUCTURE GateStructure,0
		LONG	gt_NextGate
		WORD	gt_X1
		WORD	gt_X2
		WORD	gt_BobX
		WORD	gt_LevelX
		APTR	gt_Gate
		LABEL	gt_SIZEOF

