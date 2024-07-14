
#define JOY_UP		-1
#define JOY_DOWN	1
#define JOY_LEFT	-1
#define JOY_RIGHT	1

struct JoyInfo
{
	BYTE xdir,ydir;
};

void __regargs WaitJoy(void);
BYTE __regargs CheckJoy(void);
void __regargs GetJoy(struct JoyInfo *);
