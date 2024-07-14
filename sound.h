
void __asm SoundPlayer(void);
void __asm StopAll(void);
void __asm StartSong(register __d0 LONG);
void __asm InitPlayer(register __d0 APTR,
		      register __d1 APTR);
void __asm OffChannel(register __d0 LONG);
void __asm FadeOutSong(void);
void __asm StartFX(register __d0 LONG);

