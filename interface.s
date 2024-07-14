
		INCLUDE	"myexec.i"

		XDEF	_LoadFile,_LoadFastFile,_LoadSeg,_ReadFile,_ColdReboot,_AddBob
		XDEF	_UnLoadSeg
		XDEF	_DrawOneBob,_BufLoadFile,_FreeMem,_AllocMem
		XDEF	_BufReadFile
		XDEF	_AllocClearMem,_AllocFastMem,_AllocFastClearMem
		XDEF	_AvailMem,_AvailFastMem
		XDEF	_SetMovePrg,_SetAnimPrg
		XDEF	_RemBob
		XDEF	_ClearMem,_CopyMem
		XDEF	_WaitKey,_GetKey
		XDEF	_Random,_Debug

		XREF	_MyExecBase

_AddBob:	SYSCALL	AddBob
		rts

_RemBob:	SYSCALL	RemBob
		rts

_DrawOneBob:	SYSCALL	DrawOneBob
		rts

_SetMovePrg:	SYSCALL	SetMovePrg
		rts

_SetAnimPrg:	SYSCALL	SetAnimPrg
		rts

_ColdReboot:	SYSCALL	ColdReboot
		rts

_ReadFile:	SYSCALL	ReadFile		
		rts

_BufReadFile:	SYSCALL	BufReadFile
		rts

_LoadFile:	SYSCALL	LoadFile
		rts

_LoadFastFile:	SYSCALL	LoadFastFile
		rts

_LoadSeg:	SYSCALL	LoadSeg
		rts

_UnLoadSeg:	SYSCALL	UnLoadSeg
		rts

_BufLoadFile:	SYSCALL	BufLoadFile
		rts

_GetKey:	SYSCALL	GetKey
		tst.b	d0
		rts

_WaitKey:	SYSCALL	WaitKey
		tst.b	d0
		rts

_AllocMem:	SYSCALL	AllocMem
		tst.l	d0
		rts

_AllocClearMem:	SYSCALL	AllocClearMem
		tst.l	d0
		rts

_AllocFastMem:	SYSCALL	AllocFastMem
		tst.l	d0
		rts

_AllocFastClearMem:
		SYSCALL	AllocFastClearMem
		tst.l	d0
		rts

_FreeMem:	SYSCALL	FreeMem
		rts

_AvailMem:	SYSCALL	AvailMem
		rts

_AvailFastMem:	SYSCALL	AvailFastMem
		rts

_CopyMem:	SYSCALL	CopyMem
		rts

_ClearMem:	SYSCALL ClearMem
		rts

_Random:	SYSCALL	Random
		rts


_Debug:		move.l	a6,-(sp)
		move.l	_MyExecBase,a6
		move.l	a0,meb_ROMCrackDebugText	; NICHT (a6)!
		jsr	meb_Debug(a6)
		move.l	(sp)+,a6
		rts

