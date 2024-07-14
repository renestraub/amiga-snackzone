
	IFD	BOBS_S
	 XDEF	_BlaseBob,_HinweisBob,_NewPanelBob

	 XDEF	_EnemyList1
	 XDEF	_EnemyList2
	 XDEF	_EnemyList3
	 XDEF	_EnemyList4
	 XDEF	_EnemyList5
	 XDEF	_EnemyList6
	 XDEF	_EnemyList7
	 XDEF	_EnemyList8

	 XDEF	_EnemyList11
	 XDEF	_EnemyList12
	 XDEF	_EnemyList13
	 XDEF	_EnemyList14
	 XDEF	_EnemyList15
	 XDEF	_EnemyList16
	 XDEF	_EnemyList17
	 XDEF	_EnemyList18

	 XREF	@CatCollision,@CatHandler
	 XREF	@ZuhaCollision,@ZuhaHandler,@ZuhaRemove
	 XREF	@HundCollision,@HundHandler
	 XREF	@TuersteherCollision,@TuersteherHandler
	 XREF	@ArbeiterCollision,@ArbeiterHandler
	 XREF	@SkaterCollision
	 XREF	@Kiosk
	 XREF	@HaendlerCollision
	 XREF	@KinderwagenCollision,@SchnullerCollision,@SchnullerHandler
	 XREF	@HuberCollision,@HuberCollision2,@HuberHandler
	 XREF	@SnackCollision,@SnackMove
	 XREF	@AlienCollision
	 XREF	@SpockCollision,@SpockHandler
	 XREF	@BlondiCollision,@BlondiHandler
	 XREF	@MusikerCollision,@MusikerHandler
	 XREF	@RoboterCollision,@RoboterHandler
	 XREF	@FremderCollision,@FremderHandler
	 XREF	@OmaCollision,@OmaHandler,@OmaCheck
	 XREF	@WespeCollision,@WespeHandler
	 XREF	@Kino,@Kneipe
	 XREF	@StromGame,@Sokoban
	 XREF	@PlatteHandler,@PlatteCollision
	 XREF	@SchrottiHandler,@SchrottiCollision
	 XREF	@Museum
	 XREF	@RockerCollision,@RockerHandler,@StoreRocker2
	 XREF	@DiscoFuture
	 XREF	@FerrariLHandler,@FerrariRHandler,@FerrariColl
	 XREF	@SkaterGame
	 XREF	@AgentCollision,@VerbMannCollision,@AgentHandler,@VerbMannHandler
	 XREF	_MoveFlag

	 XDEF	_KatzeFliehtMove,_KatzeFliehtAnim,_FliehKatze
	 XDEF	_HundFliehtMove,_HundFliehtAnim
	 XDEF	_ZuhaFliehtMove,_ZuhaFliehtAnim
	 XDEF	_HuberDrehAnim,_HuberAnim
	 XDEF	_OmaMove,_OmaAnim
	 XDEF	_HonigTopf
	 XDEF	_WespeMove2
	 XDEF	_BigRonny
	 XDEF	_BigRonnyLeftAnim,_BigRonnyLeftMove
	 XDEF	_BigRonnyRightAnim,_BigRonnyRightMove
	 XDEF	_RockerMove,_RockerAnim
	ENDC

	IFND	BOBS_S
	 XREF	_BlaseBob,_HinweisBob,_NewPanelBob

	 XREF	_EnemyList1
	 XREF	_EnemyList2
	 XREF	_EnemyList3
	 XREF	_EnemyList4
	 XREF	_EnemyList5
	 XREF	_EnemyList6
	 XREF	_EnemyList7
	 XREF	_EnemyList8

	 XREF	_EnemyList11
	 XREF	_EnemyList12
	 XREF	_EnemyList13
	 XREF	_EnemyList14
	 XREF	_EnemyList15
	 XREF	_EnemyList16
	 XREF	_EnemyList17
	 XREF	_EnemyList18

	ENDC

SETBOB:		MACRO
		IFEQ	NARG-4
		 dc.w	\1,\2,\3			* XPos,YPos,Flags
		 dc.l	\4				* Bob
		ENDC
		IFNE	NARG-4
		 FAIL	<"ERROR : SETBOB NEEDS 4 ARGS">
		ENDC
		ENDM

