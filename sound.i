

	IFD SND_S
	 XDEF	_SongPlayer
	 XDEF	_SoundPlayer,_StopAll,_StartSong,_InitPlayer,_OffChannel,_FadeOutSong
	 XDEF	_LoadSound,_StartFX
	ENDC

	IFND SND_S
	 XREF	_SoundPlayer,_StopAll,_StartSong,_InitPlayer,_OffChannel,_FadeOutSong
	 XREF	_SongPlayer,_StartFX
	 XREF	_LoadSound
	ENDC

