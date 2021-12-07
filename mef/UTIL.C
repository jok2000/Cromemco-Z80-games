/*
 * util.c		86-02-11
 */
#include "defs.h"

dropuser()
{
	*drop=255;
	pputs("\n\n\n");
}

carrier()
{
	return ((inp(137)&128)==128);
}

gls()
/*
 * Get local input status 
 */
{
	if (lcarrier) {
		if (!carrier()) {
			lcarrier=0;
			kill(SIGHUP);
		}
	}
	return (bios(2,0) != 0);
}

char
glc()
/*
 * Get local character
 */
{
	char c;
	while (!gls());
	c=bios(3,0);
	if (tty.mode&CASE) {
		if (c>='A' && c<='Z')
			c+=32;
	}
	if (c==tty.intrc) {
		pctl(c);
		pputc('\n');
		kill(SIGINT);
	}
	return (c);
}

plc(c)
char c;
{
	bios(4,c);
}

char getch()
{
	if (cbuft!=cbufb) {
		cbuft=(cbuft-1+CBUFSIZE)%CBUFSIZE;
		return (cbuf[cbuft]);
	}
	return (glc());
}

ungetch(c)
char c;
{
	if ((cbuft+1)%CBUFSIZE==cbufb)
		pputc(7);
	else {
		cbuf[cbuft]=c;
		cbuft=(cbuft+1)%CBUFSIZE;
	}
}

rungetch(c)
char c;
{
	if  ((cbuft+1)%CBUFSIZE==cbufb)
		pputc(7);
	else {
		cbufb=(cbufb-1+CBUFSIZE)%CBUFSIZE;
		cbuf[cbufb]=c;
	}
}
		
testio()
{
	char c;
	if (!gls())
		return;
	if ((c=glc())==tty.stopc) {
		do {
			c = glc();
			if (tty.startc == c || tty.startc == 0)
				return;
		} while(c != tty.intrc);
	}
	if (c==tty.quitc)
		kill(SIGQUIT);
	rungetch(c);
}

plce(c)
char c;
{
	if (tty.mode&ECHO)
		pputc(c);
}

pputc(c)
char c;
{
	testio();
	if (c==0201) {
		pputs("password");
		return;
	}
	if (c>=' ' && c<0177) {
		++tty.col;
		plc(c);
		return;
	}
	if (c == '\t') {
		if (tty.mode&TABS) {
			tty.col = 1+(tty.col|7);
			plc(c);
			return;
		}
		do {
			plc(' ');
		} while(++tty.col&07);
		return;
	}
	if (c == '\n') {
		tty.col=0;
		if (tty.mode&NCR) {
			plc('\r');
			nulls(tty.mode&07);
		}
		if (tty.mode&NLF) {
			plc('\n');
			nulls((tty.mode&070) >> 3);
		}
		return;
	}
	tty.col -= (c == '\b');
	plc(c);
	return;
}

nulls(n)
{
	while(n--)
		plc('\0');
}

pputs(s)
char *s;
{
	char	c;

	while (c = *s++)
		pputc(c);
}

putd(n)
{
	if (n<0) {
		pputc('-');
		n=-n;
	}
	if (n>9) putd(n/10);
	pputc(n%10+'0');
}

char *
getpass(msg)
char *msg;
{
	int	save;

	pputs(msg);
	save = tty.mode;
	tty.mode &= ~ECHO;
	getline(gpbuf,8);
	tty.mode = save;
	pputc('\n');
	return(gpbuf);
}

char	*
getline(s,lim)
char s[];
{
	int i, j, column, n, vflag, opos;
	char c;

	i=0;
	vflag=0;
	column = tty.col;
	for (;;) {
		c=i<lim?getch():'\n';
		if (iscot(c) || vflag) {
			vflag=0;
			s[i++] = c;
			if (iscot(c)) plce(c);
			else pctl(c);
			continue;
		}
		if (c== tty.force) {
			vflag=1;
			continue;
		}
		if (c=='\r' || c=='\n') {
			s[i] = '\0';
			plce('\n');
			return(s);
		}
		if (c == tty.wordd) {
			opos=i;
			if (i==0) continue;
			while (i>=0 && (s[--i]=='\t' || s[i]==' '));
			while (i>=0 && (s[i]!='\t' && s[i]!=' ')) --i;
			++i;
			if (tty.mode&ECHO) pcomp(s,i,column,opos);
			continue;
		}
		if (c == tty.erase ) {
			if (i==0) continue;
			--i;
			if ((tty.mode&ECHO)==0) continue;
			c = s[i];
			if (c != '\t')
				bs(1+isctl(c));
			else
				pcomp(s,i,column,i+1);
			continue;
		}
		pctl(c);
		if (c == tty.eofc) {
			s[i] = '\0';
			if (*s)
				return(s);
			else
				return(NULL);
		}
		if (c == tty.killc) {
			plce('\n');
			column = 0;
			i = 0;
			continue;
		}
		if (c == tty.retype) {
			if ((tty.mode&ECHO)==0)
				continue;
			plce('\n');
			for(j=0;j<i;++j) {
				c = s[j];
				if (iscot(c))
					plce(c);
				else
					pctl(c);
			}
			column = tty.col;
			continue;
		}
		s[i++] = c;
	}
	if (i=lim) plce('\n');
}

pcomp(s,i, column,old)
char *s;
{
	int n, j, first;
	char c;
	n = column;
	for(j=0;j<old;++j) {
		if (j==i) first=n;
		c = s[j];
		if (c == '\t')
			n = 1+(n|7);
		else
			n = n+1+isctl(c);
	}
	bs(n-first);
}


isctl(c)
char	c;
{
	return(c<' ' || c == 0177);
}

iscot(c)
char c;
{
	return(!isctl(c) || c=='\t');
}

pctl(c)
char	c;
{
	plce('^');
	plce((c+64)&0x7f);
}

dchar(c)
char c;
{
	if (isctl(c)) pctl(c);
	else plce(c);
}

bs(n)
{
	while(n-->0) {
		plce('\b');
		if (tty.mode&CRT) {
			plce(' ');
			plce('\b');
		}
	}
}

panic(s)
char *s;
{
	dnl();
	pputs(s);
	pputc('\n');
	exit();
}

signal(sig,f)
int	(*f)();
{
	int	(*v)();

	if (sig<0 || sig>MAXSIG)
		return(-1);
	v = sigs[sig];
	sigs[sig] = f;
	return(v);
}

kill(sig)
{
	int (*v)();

	if (sig<0 || sig>MAXSIG)
		return(-1);
	if ((v = sigs[sig]) == SIG_IGN)
		return;
	sigs[sig] = SIG_IGN;
	(*v)();
}

shline(sbuf,p,a,cwa)
char *sbuf,*p,**a,*cwa;
{
	int ac;
	int i;
	char quote,c;
	if (*cwa=='\0') {
		pputs(p);
		if(getline(sbuf,MAXLINE)==NULL) {
			pputs("\b\bquit\n");
			strcpy(sbuf,"quit");
		}
	} else {
		strcpy(sbuf,cwa);
		*cwa='\0';
	}
	for (ac=0;ac<MAXARG;++ac) {
		while (*sbuf==' ' || *sbuf=='\t') ++sbuf;
		if (*sbuf=='\0')
			break;
		quote=' ';
		if (*sbuf=='"' || *sbuf=='\'') {
			quote=*sbuf;
			sbuf++;
		}
		a[ac]=sbuf;
		while(c = *sbuf) {
			if (c==quote || (quote==' ' && (c=='\t' || c==';'))) {
				if (c==';') {
					strcpy(cwa,sbuf+1);
					*(sbuf+1)='\0';
				}
				*sbuf++='\0';
				break;
			} else ++sbuf;
		}
		if (*a[ac]=='\0') --ac;
	}
	return(ac);
}

bclose(stream)
FILE *stream;
{
	fclose(stream);
	tfree(stream);
}
	
/* What follows can be replaced with the UNIX fopen()... sigh */
bopen(f,mode)
char *f;
char *mode;
{
	char *buf;
	if ((buf=(nalloc(BUFSIZ)))==NULL) return(NULL);
	switch (*mode) {
	case 'r':
		if (fopen(f,buf)==-1) goto arg;
		break;	
	case 'w':
		switch (*(mode+1)) {
		case '+':
			if (fopen(f,buf)!=-1) break;
		default:
			if (fcreat(f,buf)==-1) goto arg;
		}
		break;
	case 'a':
		if (fappend(f,buf)==-1) goto arg;
		break;
	default:
		return(NULL);
	}
	return(buf);
arg:	tfree(buf);
	return(NULL);
}

/*
 * Note: This routine is not like that in aztec c
 */
strncpy(dest,src,max)
char *dest, *src;
{
	int i;
	for (i=0;i<max && *src!='\0';++i) *dest++=*src++;
	*dest='\0';
}

char *
index(cp,c)
char *cp, c;
{
	while (*cp!=c) 
		if (*cp++=='\0') return(NULL);
	return(cp);
}

tfree(s)
char *s;
{
	--allocc;
	free(s);
}

char *
ialloc(len)
{
	int ptr;
	if ((ptr=nalloc(len))!=NULL) return(ptr);
	panic("space");
}

char *
nalloc(len)
{
	int ptr;
	++allocc;
	if ((ptr=alloc(len))==NULL) pputs("alloc: no space\n");
	return(ptr);
}

shift()
{
	int i;
	switch (argsc) {
	case 0:
	case 1:
		break;
	case 2:
		--argsc;
		break;
	default:
		--argsc;
		for (i=1;i<argsc;++i) argys[i]=argys[i+1];
	}
}

strsw(s,g)
char *s, *g;
{
	int i;
	i=0;
	while (*s) {
		if (strcmp(s,g)==0) return(i);
		++i;
		while (*s++);
	}
	return(-1);
}

dump(item)
char *item;
{
	if (tty.col+strlen(item)+1>=tty.ncols-1)
		pputc('\n');
	if (tty.col)
		pputc(' ');
	pputs(item);
}

dnl()
{
	if (tty.col)
		pputc('\n');
}

sfix(b,nf)
struct sttyer *b;
{
	tty.mode= (tty.mode&~b->aux.bits) | (nf?0:b->aux.bits);
}

sint(b,nf)
struct sttyer *b;
{
	int i;
	if (argsc<2)  return;
	shift();
	i=atoi(argys[1]);
	if (strcmp(b->sname,"dca")!=0)
		if (i<15 || i>255) return;
	*b->aux.sitem=i;
}

schr(b,nf)
struct sttyer *b;
{
	int i;
	if (argsc<2) return;
	shift();
	if (strlen(argys[1])!=1)
		*argys[1]=*(argys[1]+1)&31;
	*b->aux.scitem=*argys[1];
}

sstr(b,nf)
struct sttyer *b;
{
	if (argsc<2) {
		**b->aux.ssitem='\0';
		return;
	}
	shift();
	tfree(*b->aux.ssitem);
	if ((*b->aux.ssitem=nalloc(strlen(argys[1])+1))==NULL) {
		*b->aux.ssitem=nalloc(1);
		return;
	}
	strcpy(*b->aux.ssitem,argys[1]);
}
