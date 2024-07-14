		IDNT	EndLabel

		XREF	__MyExecBase
		XDEF	__H2_end,_MyExecBase


		SECTION	data,DATA

_MyExecBase:	dc.l	__MyExecBase
		dc.b	"EXECEND."		; Endmarkierung

		SECTION	last,BSS
__H2_end:
