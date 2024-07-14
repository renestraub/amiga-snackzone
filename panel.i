
		XREF	@LoadPanel,@InitPanel,@UpDatePanel
		XREF	@AddGadget,@RemoveGadget
		XREF	@ChangeEnergy,@HandleEnergy
		XREF	@ChangeScore,@ChangeMoney
		XREF	@SetPanel,@InvalidPanel
		XREF	@UpDateSkaterPanel,@InitSkaterPanel

		XREF	_EnergyIst,_GameTimer
		XREF	_PanelBase

PanelWidth:	EQU	(320/8)
PanelHeight:	EQU	32
PanelDepth:	EQU	6

PanelPlane:	EQU	PanelWidth*PanelHeight


ro_value:	EQU	10
ro_actvalue:	EQU	12
ro_lastvalue:	EQU	14
