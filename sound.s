SND_S:
		INCLUDE	"myexec.i"
		INCLUDE	"sound.i"
		INCLUDE	"dosfilenames.i"


snd_VBlank:		EQU	36
snd_StopAll:		EQU	40
snd_StartSong:		EQU	44
snd_NotePort:		EQU	48
snd_InitPlayer:		EQU	52
snd_OffChannel:		EQU	64
snd_FadeOutSong:	EQU	72
snd_GetInfo:		EQU	76
snd_PlayPatt1:		EQU	84
snd_FXPlay:		EQU	92

_LoadSound:	movem.l	d0-d7/a0-a6,-(sp)

		move.l	#_FN_SNDMOD,d0
		SYSCALL	LoadFastFile
		move.l	d0,_SongPlayer		* Load the Player

		move.l	#_FN_SONG,d0
		SYSCALL	LoadFastFile
		move.l	d0,_Song		* Load the Song
		move.l	d0,a0

		move.l	#_FN_SAMPLES,d0
		SYSCALL	LoadFile
		move.l	d0,_Samples		* Load the SampleDatas

		move.l	d0,d1			* D1 = Samples
		move.l	a0,d0			* D0 = Song
		bsr	_InitPlayer		* Init()

		movem.l	(sp)+,d0-d7/a0-a6
		rts


_SoundPlayer:	movem.l	d0-d7/a0-a6,-(sp)
		move.l	_SongPlayer,a0
		move.l	a0,d7
		beq.s	1$
		jsr	snd_VBlank(a0)
1$:		movem.l	(sp)+,d0-d7/a0-a6
		rts

_StopAll:	movem.l	d0-d7/a0-a6,-(sp)
		move.l	_SongPlayer,a0
		move.l	a0,d7
		beq.s	1$
		jsr	snd_StopAll(a0)
1$:		movem.l	(sp)+,d0-d7/a0-a6
		rts

_StartSong:	movem.l	d0-d7/a0-a6,-(sp)
		move.l	_SongPlayer,a0
		move.l	a0,d7
		beq.s	1$
		jsr	snd_StartSong(a0)
1$:		movem.l	(sp)+,d0-d7/a0-a6
		rts

_StartFX:	movem.l	d0-d7/a0-a6,-(sp)
		move.l	_SongPlayer,a0
		move.l	a0,d7
		beq.s	1$
		jsr	snd_FXPlay(a0)
1$:		movem.l	(sp)+,d0-d7/a0-a6
		rts

_InitPlayer:	movem.l	d0-d7/a0-a6,-(sp)
		move.l	_SongPlayer,a0
		move.l	a0,d7
		beq.s	1$
		jsr	snd_InitPlayer(a0)
1$:		movem.l	(sp)+,d0-d7/a0-a6
		rts

_OffChannel:	movem.l	d0-d7/a0-a6,-(sp)
		move.l	_SongPlayer,a0
		move.l	a0,d7
		beq.s	1$
		jsr	snd_OffChannel(a0)
1$:		movem.l	(sp)+,d0-d7/a0-a6
		rts

_FadeOutSong:	movem.l	d0-d7/a0-a6,-(sp)
		move.l	_SongPlayer,a0
		move.l	a0,d7
		beq.s	1$
		move.l	#$00010000,d0
		jsr	snd_FadeOutSong(a0)		* Fade Out
		jsr	snd_GetInfo(a0)
2$:		tst	(A0)				* Wait 'till
                bne.s	2$				* we finished this

1$:		movem.l	(sp)+,d0-d7/a0-a6
		rts



_SongPlayer:	dc.l	0
_Song:		dc.l	0
_Samples:	dc.l	0

