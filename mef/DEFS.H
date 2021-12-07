/*
 * defs.h		86-11-21
 */
#include "bdscio.h"

#define CPTRSZ 2		/* change to sizeof(char *)  */
#define H ldate[3]		/* local setting to return hour */
#define M ldate[4]		/* minute */
#define S ldate[5]		/* second */
#define D ldate[2]		/* day    */
#define MM ldate[1]		/* month  */
#define Y ldate[0]		/* year   */

#define NUMSTATS 11		/* size of instat array */
#define MAXONLINE 400		/* total icms on-line at once */
#define ICSAFILE 20		/* icms per file */
#define NUMCOM 48		/* number of commands (should be a sizeof) */
#define NUMSTTYOPS 44		/* number of elements in sttyops array	   */
#define LOGENT 21		/* number of log entries (dependant record)*/
#define MAXARG 32		/* maximum number of arguments to a command*/
#define MAXLINE 256		/* longest line */
#define MAXDATELENGTH 64	/* length of Thu Mar 23 1984 00:00:00	   */
#define CBUFSIZE 50		/* internal bufferring */
#define UFILESIZE 256		/* pretty much must be 256 */

#define CONTMASK 1		/* continuous mode bit	*/
#define XPRMASK 2		/* expert bit		*/
#define MOTDMASK 4		/* motd bit		*/
#define PRIVMASK 24		/* privilege bits (pretty much must be this*/
#define CPMMASK 32		/* cpm priv bit		*/
#define VIMASK 128		/* auto-vi bit		*/
				/* one must be careful to see that dopriv() and
				   docu() are aware of any changes here */

#define TABS 0x100		/* tty.mode settings...	*/
#define NCR 0x40		/* cr bit */
#define NLF 0x80
#define ECHO 0x200
#define CRT 0x400
#define CASE 0x800		/* etc. */

#define SIG_IGN 0
#define SIGHUP 0
#define SIGINT 1
#define SIGQUIT 2
#define MAXSIG 2		/* signals */

char	*getpass(), *index();
FILE	*bopen();

char	getch(), *fgets(), *ialloc(), *alloc(), *sbrk(), *dater(), 
	*getline(), *fnm(), tolower(), *nalloc(), *flnm();

int	doUPPER(), dobye(), dochat(), dodate(), dodebug(), doecho(), doexit(),
	dof(), dohack(), dohello(), dohelp(), doic(), doiam(), dolm(), dolog(),
	dologin(), dolower(), dopasswd(), dophone(), dopriv(), doprof(),
	doprompt(), doquit(), dosu(), dotos(), dou(), doun(), dowhat(),
	dowhen(), dowhere(), dowho(), dowmi(), hup(), onint(), sfix(), sint(),
	schr(), sstr(), iccl1(), ichup(), dols(), docat(), dogfile(),
	dochown(), dochmod(), inohup(), inoint(), cmhup(), cmint(), domore(),
	dotouch(), dorm(), dosetmotd(), doed(), dostat(), doepoch(), scinit(),
	sclear(), docu(), doreboot(), dostty();

/* global variables: */

char	*cbuf, *cwait, *line, *prompt, *argys[MAXARG], pass[9], lname[9],
	*ldate, *drop, **logins, gpbuf[11], finished[JBUFSIZE], *flnmb,
	interrupt[JBUFSIZE], quitjmp[JBUFSIZE], *dateh, *dow[7], *moy[12],
	edhup[JBUFSIZE], loginjmp[JBUFSIZE], gdbuf[128], epoch[6];
int	debugf, cbuft, cbufb, ufile, st, misc, un, argsc, ls, nu, sn, elog, 
	uid, filnum, inl, hon, mon, son, term, days[12], coreuid, pwhatf,
	icopen, *instat[NUMSTATS], logfile, lcarrier, readable, inode,
	ipoin, irnum, zerof, minsin, wics, wlogins, ldt, lmt, lit, llt, allocc;
FILE	*icfile, *iamnew, *iamold;

struct stty {
	int	mode;
	int	col;
	int	ncols;
	int	nlins;
	char	erase;
	char	killc;
	char	intrc;
	char	eofc;
	char	retype;
	char	stopc;
	char	startc;
	char	quitc;
	char	force;
	char	wordd;
} tty;

struct coms {
	char *name;
	int (*func)();
} com[NUMCOM];

#define PROFLEN 116
struct urec {
	char login[9];
	char passwd[9];
	char who[32];
	char phone[9];
	char lm[64];
	char when[5];
	int fst;
	int fun;
	char prof[PROFLEN];
	int fics;
	int flogins;
	int fdays;
	int fmins;
} uf;

struct log_ {
	int luid;
	char fhour;
	char fmin;
	char thour;
	char tmin;
} lbuf[LOGENT+1]; /* make sure we have 128 bytes here! */

int	(*sigs[MAXSIG+1])();

struct tc {
	int dca;
	char *cup;
	char *cdown;
	char *cright;
	char *cleft;
	char *home;
	char *clear;
	char *cteol;
	char *cteos;
	char *insc;
	char *insl;
	char *delc;
	char *dell;
	char *dlin;
	char *dsep;
	char *dlout;
	char *up;
	char *down;
	char *right;
	char *left;
	char *blk;
	char *bell;
	char *inson;
	char *insoff;
	char *rvon;
	char *rvoff;
} tcap;

struct sttyer {
	char *sname;
	int (*pfunc)();
	union {
		int bits;
		int *sitem;
		char *scitem;
		char **ssitem;
	} aux;
} sttyops[NUMSTTYOPS];

struct tfiletype {
	char termname[6];	/* Not null terminated in termcap file */
	char tcols;
	char tlins;
	char ttext[120];
} tcapent;			/* this structure should be 128 bytes long */

struct ffile {
	int	fstat;
	int	fown;
	int	fgrp;
	int	fsize;
	char	fdate[6];
	char	fname[9];
	char	fleft[9];	/* 32 bytes */
} *frecs;
