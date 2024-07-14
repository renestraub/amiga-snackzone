
	IFD	RONNYMOVE_S
	 XDEF	NewMoveMyBob,InitMyBob
	 XDEF	@LoadHero

	 XDEF	_MyBob
	 XDEF	_DuckFlag
	 XDEF	_NoLeftFlag,_NoRightFlag,_DirectionX,_DirX
	 XDEF	_NoCollisionTimer,_WalkFlag
	 XDEF	_LeftLock,_RightLock
	 XDEF	_AusweichFlag

	ENDC

	IFND	RONNYMOVE_S
	 XREF	NewMoveMyBob,InitMyBob
	 XREF	@LoadHero

	 XREF	_MyBob
	 XREF	_DuckFlag
	 XREF	_NoLeftFlag,_NoRightFlag,_DirectionX,_DirX
	 XREF	_NoCollisionTimer,_WalkFlag
	 XREF	_LeftLock,_RightLock
	 XREF	_AusweichFlag

	ENDC

