
	IFD	JOYSTICK_S

	XDEF	GetJoy,WaitJoy,CheckJoy
	XDEF	JoyStick
	XDEF	@WaitJoy,@CheckJoy,@GetJoy
	
	ENDC

	IFND	JOYSTICK_S

	XREF	GetJoy,WaitJoy,CheckJoy
	XREF	JoyStick

	ENDC

