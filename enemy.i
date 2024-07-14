
	IFD	ENEMY_S
	 XDEF	InitEnemyList,UpDateClip
	 XDEF	HandleEnemyList2
	 XDEF	_UpDateBobs
	ENDC

	IFND	ENEMY_S
	 XREF	InitEnemyList,UpDateClip
	 XREF	HandleEnemyList2
	 XREF	_UpDateBobs
	ENDC

	STRUCTURE LevelBobStructure,0
	 WORD	sb_XPos
	 WORD	sb_YPos
	 WORD	sb_Flags
	 APTR	sb_Bob
	LABEL	sb_SIZEOF

