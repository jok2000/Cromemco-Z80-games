/*
 * mef.c		86-11-21
 */
#include "defs.h"

varinit()
{
	cwait=ialloc(MAXLINE);
	line=ialloc(MAXLINE);
	prompt=ialloc(3);
	cbuf=ialloc(CBUFSIZE);
	dateh=ialloc(MAXDATELENGTH);
	coreuid=-1;
	signal(SIGHUP, SIG_IGN);
	signal(SIGINT, &doexit);
	signal(SIGQUIT,SIG_IGN);
}

ttyinit()
{
	int i;
	tty.ncols=64;
	tty.nlins=16;
	tty.mode=NCR|NLF|ECHO|TABS;
	tty.erase='H'-64;
	tty.killc='U'-64;
	tty.intrc='C'-64;
	tty.eofc='D'-64;
	tty.retype='R'-64;
	tty.stopc='S'-64;
	tty.startc=0;
	tty.quitc='P'-64;
	tty.force='V'-64;
	tty.wordd='W'-64;
	sttyscan(&sclear);
}

sclear(i)
{
	**sttyops[i].aux.ssitem='\0';
}

scinit(i)
{
	if ( (*sttyops[i].aux.ssitem=nalloc(1))==NULL) panic("tcap alloc");
	sclear(i);
}

sttyscan(f)
int (*f)();
{
	int i;
	for (i=0;strcmp("cup",sttyops[i].sname)!=0;++i);
	--i;
	do {
		(*f)(++i);
	} while (strcmp("rvoff",sttyops[i].sname)!=0);
}

onint()
{
	*cwait='\0';
	dnl();
	longjmp(interrupt,1);
}

#define YEAR datel[0]
#define MONTH datel[1]
#define DAY datel[2]

char *
dater(datel,f)
char datel[6];
{
	int i;
	char *start;
	if (MONTH==0) MONTH=1;
	strcpy(dateh,dow[(YEAR/4+DAY+YEAR+days[MONTH-1]-(YEAR%4==0 && MONTH<3))%7]);
	strcat(dateh,moy[MONTH-1]);
	strcat(dateh,num(DAY));
	strcat(dateh," 19");
	strcat(dateh,num(YEAR));
	start=dateh+15;
	*start++ = ' ';
	for (i=3;i<6-f;++i) {
		*start++ = datel[i]/10+'0';
		*start++ = datel[i]%10+'0';
		if (i<5-f) *start++ = ':';
	}
	*start = '\0';
	return(dateh);
}

localset()
{
	char **lo;
	lo=0xf333;
	ldate=*lo++;
	lo++;			/* inrcpm */
	lo++;			/* modmf  */
	lo++;			/* mchar  */
	drop=*lo;
}

fetchif()
{
		un=uf.fun;
		st=uf.fst;
		wics=uf.fics;
		wlogins=uf.flogins;
		minsin=H*60+M;
}

getlogin()
{
	int u,lun,i,qf,len;
	char *loc, *curs, *cw;
	*pass='\0';
	qf=0;
	if (argsc==1 || *argys[1]=='\0') {
		tty.mode&=~CASE;
		pputs("login: ");
		getline(line,MAXLINE-1);
		for (i=0;line[i]!='\0';++i)
			if (islower(line[i])) break;
		if (line[i]=='\0') {
			tty.mode|=CASE;
			for (i=0;line[i]!='\0';++i) line[i]=tolower(line[i]);
		}
		switch (strsw("log\0q\0new\0",line)) {
		case 0:
			argsc=2;
			dolog();
			return(1);
		case 1:
			dropuser();
			kill(SIGHUP);
		case 2:
			if ((u=new())==-1) return(1);
			strcpy(line,logins[u]);
			strcat(line,"-");
			strcat(line,logins[u]);
			break;
		}
	} else strcpy(line,argys[1]);
	if (*line=='\0') return(1);
	curs=line;
	strcpy(cwait,"echo;what;prompt \"% \";prof -x");
	cw=cwait+(len=strlen(cwait));
	if ((loc=setpos(curs,'/',0))!=0) {
		if (len+1+strlen(loc+1) < MAXLINE-1) {
			*cw++=';';
			strcpy(cw,loc+1);
		}
	}
	if ((loc=setpos(curs,'?',0))!=0) {
		qf=atoi(line);
		if (qf==0) qf=1;
		curs=loc+1;
	}
	if ((loc=setpos(curs,'-',0))!=0)
		strncpy(pass,loc+1,8);
	strncpy(lname,curs,8);
	if (strlen(pass)==0)
		strcpy(pass,getpass("Password:"));
	u=getuid(lname);
	if (u!=-1) {
		pufile(u,'r');
		if (strcmp(uf.passwd,pass)!=0) u=-1;
	} else
		pputs("Enter 'new' if you don't have an account on this bbs.\n");
	if (u==-1) {
		pufile(0, 'r');
		if (strcmp(uf.passwd,pass)==0 && strcmp(lname,"exit")==0) {
			close(ufile);
			exit();
		}
		pputs("Login incorrect.\n");
		return(1);
	}
	if (qf==0) {
		fetchif();
		uid=u;
		return(0);
	}
	lun=sn-uf.fun+1;
	if (lun>=qf) {
		fetchif();
		uid=u;	
		return(0);
	}
	if (lun==0)
		pputs("No");
	else {
		pputs("Only ");
		putd(lun);
	}
	pputs(" new message");
	if (lun!=1) 
		pputc('s');
	pputc('\n');
	return (1);
}

doUPPER()
{
	tty.mode|=CASE;
}

dobye()
{
	char c;
	pputs("Are you sure? ");
	c=tolower(getch());
	if (c=='y') {
		pputs("Yes\n");
		hup();
	} else pputs("No\n");
}

dochat()
{
	if (!(st&XPRMASK))
		pputs("\".\" terminates.\n");
	do {
		if (argsc==1) pputc('>');
	} while(strcmp(getline(line,tty.ncols-2+(argsc!=1)),".")!=0);
}

dodate()
{
	pputs(dater(ldate,0));
	pputc('\n');
}

dodebug()
{
	int val;
	putd(allocc);
	pputs(" active strings\n");
	if (st&PRIVMASK) return;
	if (argsc<3) return;
	val=atoi(argys[2]);
	switch (strsw("ls\0sn\0nu\0inl\0",argys[1])) {
	case 0:
		ls=val;
		break;
	case 1:
		sn=val;
		break;
	case 2:
		nu=val;
		break;
	case 3:
		inl=val;
		break;
	}
}

doecho()
{
	int nlf,i;
	if (argsc==1) {
		pputc('\n');
		return;
	}
	if (strcmp(argys[1],"-n")==0) {
		shift();
		nlf=0;
	} else nlf=1;
	for (i=1;i<argsc;++i) {
		pputs(argys[i]);
		if (i!=(argsc-1)) pputc(' ');
	}
	if (nlf) pputc('\n');
}

doexit()
{
	if ((st&CPMMASK)!=0 || (st&PRIVMASK)==0) {
		shop();
		if ((icfile=bopen("B:LASTCALR.DAT","w"))!=ERROR) {
			fputs(lname, icfile);
			fputs(": ", icfile);
			fputs(dater(ldate,0), icfile);
			fputs("\n\032", icfile);
			bclose(icfile);
		}
		panic("exit");
	}
}

doreboot()
{
	pputs("Rebooting...\n");
	shop();
	exec("e:mef");
	exec("b:mef");
}

shop()
{
	writestat();
	winfo();
	svlog();
	close(ufile);
}

dohack()
{
	int i, f;
	ico(fnm(sn));
	if (icfile==NULL) {
		--sn;
		ico(fnm(sn));
	}
	i=sn-(sn%20)-1;
	f=1;
	do {
		if (fgets(line, icfile)==NULL) break;
		if (strcmp(line, ".\n")==0) {
			++i;
			f=0;
		} else f=1;
	} while (1);
	if (f) {
		pputs("?.\n");
	} else {
		if (i!=sn) {
			pputs("sn=");
			putd(sn);
			pputs(" true=");
			putd(i);
			pputc('\n');
			sn=i;
		} else pputs("sn ok\n");
	}
	iclose();
	writestat();
	winfo();
}

dohello()
{
	pputs("\7\200\200\200\200\200\7\200\200\200\200\200\7\200\200\200\200\200\7\200\200\200\200\200\7\n");
}

dohelp()
{
	int i;
	char hc[10];
	if (argsc==1) {
		pputs(" Commands:\n");
		for (i=0;i<NUMCOM;++i) dump(com[i].name);
		dnl();
		pputs(" For additional help type \"help <command>\"\n");
	} else {
		ico("B:000.BBS");
		strncpy(hc, argys[1], 8);
		strcat(hc, "\n");
		do {
			if (fgets(line, icfile)==NULL) kill(SIGINT);
		} while (strcmp(hc,line)!=0);
		do {
			pputs(line);
			if (fgets(line, icfile)==NULL) kill(SIGINT);
		} while (*line==' ' || *line=='\t');
		iclose();
	}
}

dofortune()
{
	int ff, nf, cf;
	int *ci;
	char *s;
	if ((ff=open("E:FORIND", 2))==-1) return;
	if (read(ff, gdbuf, 1)!=1) goto clabt;
	ci=gdbuf;
	nf=ci[0];
	cf=ci[1];
	cf+=877;
	if (cf>=nf) cf-=nf;
	ci[1]=cf;
	seek(ff, 0, 0);
	write(ff, gdbuf, 1);
	cf+=1;
	seek(ff, cf/32, 0);
	if (read(ff, gdbuf, 1)!=1) goto clabt;
	cf=(cf&31)<<1;
	nf=ci[cf];
	cf=ci[cf+1];
	close(ff);
	if ((ff=open("E:FORTUNE", 0))==-1) return;
	seek(ff, nf, 0);
	if (read(ff, s=gdbuf, 1)!=1) goto clabt;
	while (s[cf] != 13) {
		pputc(s[cf++]);
		if (cf==128) {
			cf=0;
			seek(ff, ++nf, 0);
			if (read(ff, gdbuf, 1)!=1) goto clabt;
		}
	}
clabt:	close(ff);
	pputs("\n");
}

dologin()
{
	enduser();
	longjmp(loginjmp, 1);
}

dolower()
{
	tty.mode&=~CASE;
}

dopasswd()
{
	int u;
	char p[9];
	if ((u=(argsc==1)? uid: getuid(argys[1]))==-1) return;
	pufile(u,'r');
	pputs2("Changing \201 for ",uf.login);
	pputc('\n');
	if ((st&PRIVMASK)!=0) {
		if (strcmp(uf.passwd,getpass("Old \201:"))!=0) {
			pputs("Sorry.\n");
			return;
		}
	}
	strcpy(p,getpass("New \201:"));
	if (strcmp(p,getpass("Repeat new \201:"))!=0) {
		pputs("Mismatch, \201 unchanged\n");
		return;
	}
	strcpy(uf.passwd,p);
	pufile(u,'w');
}

doprompt()
{
	if (argsc<2) return;
	tfree(prompt);
	if ((prompt=nalloc(strlen(argys[1])+1))==NULL) {
		prompt=nalloc(3);
		argys[1]="% ";
	}
	strcpy(prompt,argys[1]);
}

doquit()
{
	hup();
}

epochp()
{
	uf.fics=uf.flogins=uf.fdays=uf.fmins=0;
}
doepoch()
{
	int i;
	wics=wlogins=0;
	ster(&epochp);
	for (i=0;i<6;++i)
		epoch[i]=ldate[i];
}

motdp()
{
	uf.fst|=MOTDMASK;
}
dosetmotd()
{
	ster(&motdp);
}

ster(f)
int (*f)();
{
	int i;
	if (st&PRIVMASK) kill(SIGINT);
	for (i=0;i<nu;++i) {
		pufile(i,'r');
		(*f)();
		pufile(i,'w');
	}
}

dosu()
{
	int u;
	switch (argsc) {
		case 1:
			u=0;
			break;
		case 2:
			if ((u=getuid(argys[1]))==-1) return;
			break;
		default:
			return;
	}
	pufile(u,'r');
	if ((st&PRIVMASK)!=0) {
		if (strcmp(getpass("\201:"),uf.passwd)!=0) {
			pputs("Sorry.\n");
			return;
		}
	}
	winfo();
	pufile(u,'r');
	strcpy(lname,uf.login);
	fetchif();
	uid=u;
}

putt(n,c)
char c;
{
	pputc(n/10+'0');
	pputc(n%10+'0');
	pputc(c);
}

dotos()
{
	int h,m,s,c;
	pputs("Logged in for ");
	if ( (c=((s=S-son)<0)) ) s+=60;
	if ( (c=((m=M-mon-c)<0)) ) m+=60;
	if ( (h=H-hon-c)<0 ) h+=24;
	putt(h,':');
	putt(m,':');
	putt(s,'\n');
}

dowmi()
{
	pputs2("I think you are ",lname);
	pputc('\n');
}

setlogins()
{
	char *area, *p;
	int i;
	logins=nalloc(nu*CPTRSZ);
	area=nalloc(nu*9);
	for (i=0;i<nu;++i) {
		pufile(i,'r');
		p=uf.login;
		logins[i]=area;
		while(*area++ = *p++);
	}
}

new()
{
	char c;
	int correct, used;
	coreuid=-1;
	pputs("Hi, what is your real name? ");
	getline(uf.who,31);
	pputs("Your phone number: ");
	getline(uf.phone,8);
	pputs("Now pick a 3-5 letter (maximum is 8) indentifier you would\n");
	pputs("like to refer to you.  (Most people use their initials).\n");
	for (;;) {
		pputs("Identifier: ");
		getline(uf.login,8);
		if (getuid(uf.login)!=-1 || strlen(uf.login)<2) {
			pputs("Pick a different id.\n");
			continue;
		}
		break;
	}
	pputs("Is this correct? ");
	c=getch();
	if (c=='n' || c=='N') {
		pputs("No.\n");
		return(-1);
	}
	pputs("Yes.\n");
	uf.fst=8|MOTDMASK;
	uf.fics=uf.flogins=uf.fdays=uf.fmins=uf.fun=0;
	strcpy(uf.lm,"jok:Type \"help\" or \"cat new\" for help");
	*uf.when=*uf.prof='\0';
	strcpy(uf.passwd,uf.login);
	pufile(nu++,'w');
	tfree(logins[0]);
	tfree(logins);
	setlogins();
	writestat();
	pputs2("Your \201 is ",uf.login);
	pputc('\n');
	return(nu-1);
}

preset()
{
	sttyscan(&scinit);
	ttyinit();
	varinit();
	localset();
	if ((ufile=open("D:UFILE",2))==-1)
		panic("preset: ufile open");
	getstat();
	setlogins();
	if ((logfile=open("E:LOG", 0))==-1) {
		if ((logfile=open("D:LOG", 0))==-1) panic("logfile");
	}
	if (read(logfile, &lbuf, 1)!=1) panic("logfile read");
	close(logfile);
	unlink("E:LOG");
}

intro()
{
	int i;
	ttyinit();
	if (!carrier()) {
		for (i=0;i<1;++i)
			if (getch()!=13) i=0;
		term=-1;
		hon=H;
		mon=M;
		son=S;
		argsc=0;
		pputs("\nCmef!jok Written by Jeff Kesner\n\n");
	}
}

finito()
{
	FILE *trash,*subtrash;
	int c;
	if ((trash=bopen("e:trash.poo","r"))!=NULL) {
		if ((subtrash=bopen("a:.sub","w"))!=NULL) {
			while((c=getc(trash))!=EOF) putc(c,subtrash);
			bclose(subtrash);
			bdos(14,0);	/* Select drive A */
			exec("15/A:SUBMIT");
			bclose(trash);
		}
	}
	longjmp(finished, 1);
}

setup()
{
	signal(SIGHUP, SIG_IGN);
	lcarrier=carrier();
	ttyinit();
	argsc=1;
	if (uid==-1) setupb();
	else {
		pufile(uid, 'r');
		strcpy(lname,uf.login);
		fetchif();
		argsc=2;
		argys[1]="% ";
		doprompt();
		argsc=0;
		if (term!=-1) dostty();
	}
}

setupb()
{
	char *s;
	signal(SIGHUP, &finito);
	setjmp(interrupt);
	signal(SIGINT, &onint);
	while (getlogin()==1);
	if (setjmp(interrupt)==0) {
		lbuf[elog].luid=uid;
		lbuf[elog].fhour=H;
		lbuf[elog].fmin=M;
		lbuf[elog].thour=24;
		argsc=1;
		pputs("Last on: ");
		dowhen();
	}
	signal(SIGINT, &onint);
	if (st&MOTDMASK) {
		pputc('\n');
		argsc=2;
		argys[1]="motd";
		if (setjmp(interrupt)==0) docat();
		pputc('\n');
		st&=~MOTDMASK;
	}
	argsc=1;
	doun();
	s=uf.when;
	*s++=Y; *s++=MM; *s++=D; *s++=H; *s++=M; /* set when entry */
	pufile(uid, 'w');
}

hup()
{
	signal(SIGHUP, SIG_IGN);
	dnl();
	dotos();
	pputs("Thanks for calling\n");
	dropuser();
	enduser();
	finito();
}

enduser()
{
	lbuf[elog].thour=H;
	lbuf[elog].tmin=M;
	elog=(elog==0)?LOGENT-1:elog-1;
	winfo();
	uid=-1;
	writestat();
	svlog();
}

svlog()
{
	if ((logfile=open("D:LOG", 1))!=-1) {
		write(logfile, &lbuf, 1);
		close(logfile);
	}
}

main(argc,argv)
char **argv;
{
	int i;
	if (argc>1) {
		if (strcmp(argv[1],"-X")==0) goto loop;
	}
	debugf=(argsc>1);
#include "init.mef"
	if (setjmp(interrupt)==1) exit();
	preset();
/*
 *   a loop starts here...
 */
	setjmp(finished);
	signal(SIGINT, SIG_IGN);
	signal(SIGHUP, SIG_IGN);
	signal(SIGQUIT,SIG_IGN);
	if (uid==-1) intro();
	if (setjmp(loginjmp))
		setupb();
	else
		setup();
	++wlogins;
loop:	for (;;) {
		setjmp(interrupt);
		signal(SIGINT, &onint);
		signal(SIGHUP, &hup);
		argsc=shline(line,prompt,argys,cwait);
		testio();
		for (i=0;i<NUMCOM;++i) {
			if (strcmp(com[i].name,argys[0])==0) {
				(*com[i].func)();
				break;
			}
		}
	}
}
