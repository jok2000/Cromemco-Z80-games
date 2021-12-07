/*
 * info.c		86-02-12
 */
#include "defs.h"

char *
flnm(i)
int i;
{
	flnmb[2]=i/100+'0';
	flnmb[3]='0'+((i/10)%10);
	flnmb[4]='0'+(i%10);
	return(flnmb);
}
	
setpos(str,c,d)
char *str,c,d;
{
	char *loc;
	if ((loc=index(str,c))==NULL) return(NULL);
	*loc=d;
	return loc;
}

pputs2(s,t)
char *s,*t;
{
	pputs(s);
	pputs(t);
}

putj(s,c,file)
char *s, c;
FILE  *file;
{
	char blech[2];
	blech[1]='\0';
	*blech=c;
	fputs(s, file);
	fputs(blech, file);
}

uinfo(f)
int (*f)();
{
	char ts[11], *hl, *k, *ts1;
	int i,j,start;
	int colf;
	colf=0;
	if (argsc==1) {
		colf=1;
		argys[argsc++]=lname;
	}
	for (i=0;i<nu;++i) {
		hl=logins[i];
		for (j=1;j<argsc;++j) {
			if ((strcmp(argys[j],hl)==0) || (*argys[j]=='*')) {
				pufile(i,'r');
				if (strcmp(argys[j],"**")==0)
					if (uf.fun<ls) continue;
				testio();
				if (colf==0) {
					ts1=ts;
					for (k=hl;*k!='\0';++k) *ts1++=*k;
					*ts1++=':';
					*ts1++='\t';
					*ts1='\0';
				} else *ts='\0';
				(*f)(ts);
			}
		}
	}
}

char *
num(n)
{
	gpbuf[0]=n/10+'0';
	gpbuf[1]=n%10+'0';
	gpbuf[2]='\0';
	return (gpbuf);
}

dowhere()
{
	char iline[MAXLINE+25], *loc;
	int u,i;
	if (argsc==1) argys[argsc++]=lname;
	ico("D:IAMS");
	while (fgets(iline, icfile)!=NULL) {
		if ((loc=setpos(iline,',',0))==NULL) continue;
		u=getuid(iline);
		*loc='\t';
		if (setpos(iline,',',' ')==NULL) continue;
		if (*argys[1]=='*') pputs(iline);
		else {
			for (i=1; i<argsc; ++i) {
				if (getuid(argys[i])==u)
					pputs(iline);
			}
		}
	}
	iclose();
}

doiam()
{
	int day, i, u;
	char iline[MAXLINE+25], *loc;

	if ((iamold=bopen("D:IAMS", "r"))==NULL) return;
	if ((iamnew=bopen("D:IAMNEW", "w"))==NULL) {
		bclose(iamold);
		return;
	}
	while (fgets(iline, iamold)!=NULL) {
		if ((loc=setpos(iline,',',0))==NULL) continue;
		u=getuid(iline);
		*loc=',';
		if (u==uid) continue;
		/*
		day=D-((*(loc+1)-'0')*10+*(loc+2)-'0');
		if (day<0) day+=29;
		if (day<10) fputs(iline, iamnew);
		*/
		fputs(iline, iamnew);
	}
	bclose(iamold);
	unlink("D:IAMS");
	if (argsc>1) {
		putj(lname, ',', iamnew);
		putj(num(D), '-', iamnew);
		putj(num(H), ':', iamnew);
		putj(num(M), ',', iamnew);
		for (i=1;i<argsc;++i)
			putj(argys[i], ' ', iamnew);
		fputs("\n\032", iamnew);
	}
	bclose(iamnew);
	rename("D:IAMNEW", "D:IAMS");
	argsc=2;
	argys[1]=logins[uid];
	dowhere();
}

dolm()
{
	int u,zf;
	char *ln,*ilm;
	signal(SIGINT, SIG_IGN);
	ln=line;
	zf=0;
	if (argsc>1) {
		if (strcmp("-z",argys[1])==0) {
			zf=1;
			shift();
		}
	}
	if ( (u=(argsc!=2)? uid: getuid(argys[1])) == -1) return;
	strcpy(line,lname);
	pufile(u,'r');
	if (zf) {
		ln=index(uf.lm,':')+1;
		if (ln==1) ln="";
		if ((ilm=nalloc(strlen(ln)+1))==NULL) return;
		strcpy(ilm,ln);
		zap(&ilm);
	} else {
		if ((ilm=nalloc(64))==NULL) return;
		pputs("New message: ");
		getline(ilm,63);
	}
	ln=line+strlen(line);
	*ln++=':';
	strncpy(ln,ilm,64);
	strncpy(uf.lm,line,63);
	tfree(ilm);
	pufile(u,'w');
}

docu()
{
	int u, f;
	char c;
	if ((st&PRIVMASK) || argsc<3) return;
	if ((u=getuid(argys[1]))==-1) return;
	if (strcmp(argys[2],"delete")==0) {
		pufile(nu-1,'r');
		pufile(u,'w');
		logins[u]=logins[--nu];
		return;
	}
	pufile(u,'r');
	if (argsc<4) return;
	do {
		shift();
		switch (strsw("login\0passwd\0who\0phone\0priv\0",argys[1])) {
		case 0:
			strncpy(uf.login,argys[2],8);
			break;
		case 1:
			strncpy(uf.passwd,argys[2],8);
			break;
		case 2:
			strncpy(uf.who,argys[2],31);
			break;
		case 3:
			strncpy(uf.phone,argys[2],8);
			break;
		case 4:
			uf.fst=0;
			while (c=*((argys[2])++)) {
				switch (c) {
				case 'm':
					f=MOTDMASK;
					break;
				case 'c':
					f=CONTMASK;
					break;
				case 'h':
					f=CPMMASK;
					break;
				case 'x':
					f=XPRMASK;
					break;
				case 'v':
					f=VIMASK;
					break;
				case '%':
					f=8;
					break;
				case 'M':
					f=16;
					break;
				case '$':
					f=24;
					break;
				default:
					f=0;
				}
				uf.fst|=f;
			}
			if ((uf.fst&PRIVMASK)==0) pputs("Super user!\n");
		}
		shift();
	} while (argsc>3);
	pufile(u,'w');
}

dolog()
{
	int i,ohour,pfl,ah;
	char adate[5], *ds;
	for (i=0;i<5;++i)
		adate[i]=ldate[i];
	ohour=H;
	adate[2]=D;
	pfl=1;
	i=(argsc==1)? elog: (elog+1)%LOGENT;
	argsc=1;
	do {
		if (lbuf[i].luid>=0 && lbuf[i].luid<nu) {
			pputs(logins[lbuf[i].luid]);
			pputc('\t');
			putt(ah=lbuf[i].fhour,':');
			putt(lbuf[i].fmin,'-');
			if (lbuf[i].thour==24)
				pputs("xx:xx ");
			else {
				putt(lbuf[i].thour,':');
				putt(lbuf[i].tmin,' ');
			}
			if (ohour<ah) {
				--adate[2];
				pfl=1;
			}
			if (pfl) {
				pfl=0;
				if (adate[2]>0) {
					ds=dater(adate,1);
					ds[15]='\0';
					pputs(ds);
				}
			}
			ohour=ah;
			pputc('\n');
		}
	} while ((i=(i+1)%LOGENT)!=elog);
}

pphone(s)
char *s;
{
	if (uf.phone[0]!='0') {
		pputs2(s,uf.phone);
		pputc('\n');
	}
}
dophone()
{
	uinfo(&pphone);
}

pf(s)
char *s;
{
	pputs2("Login: ",uf.login);
	pputs2("\tName: ",uf.who);
	pputs("\nUnread: ");
	putd(uf.fun);
	pputs("\tPrivs: ");
	ppriv("");
	pputs("Last on: ");
	pwhen("");
}

dof()
{
	uinfo(&pf);
}

ppriv(s)
char *s;
{
	char *ps;
	char *ut;
	int j;
	ps="cxm  hev";
	ut="#%m$";
	pputs(s);
	pputc(ut[(uf.fst&PRIVMASK)>>3]);
	for (j=0;j<8;++j) {
		if (uf.fst&(1<<j))
			pputc(ps[j]);
		else
			pputc('-');
		if (j==2) j=4;
	}
	pputc('\n');
}
dopriv()
{
	uinfo(&ppriv);
}

pprof(s)
char *s;
{
	if (uf.prof[0]!='\0') {
		pputs2(s,uf.prof);
		pputc('\n');
	}
}
doprof()
{
	char *cw;
	int u, l;
	switch (strsw("-v\0-x\0",argys[1])) {
	case 0:
			shift();
			uinfo(&pprof);
			return;
	case 1:
		shift();
		if ((u=(argsc==1?uid:getuid(argys[1])))!=-1) {
			pufile(u,'r');
			cw=cwait+(l=strlen(cwait));
			*cw++=';';
			strncpy(cw,uf.prof,MAXLINE-l-1);
		}
		return;
	}
	signal(SIGINT, SIG_IGN);
	pufile(uid,'r');
	if ((cw=nalloc(strlen(uf.prof)+1))==NULL) return;
	strcpy(cw,uf.prof);
	zap(&cw);
	strncpy(uf.prof,cw,PROFLEN-1);
	tfree(cw);
	pufile(uid,'w');
}

pun(s)
char *s;
{
	pputs(s);
	putd(uf.fun);
	pputc('\n');
}
doun()
{
	if (argsc==1) {
		pputs("u=");
		putd(un);
		pputs(" #=");
		putd(sn);
		pputs(" [");
		putd(sn-un+1);
		pputs("]\n");
	} else uinfo(&pun);
}

pstat(s)
char *s;
{
	sline(s,uf.fics,uf.fmins,uf.fdays,uf.flogins);
}
sline(s,i,m,d,l)
char *s;
{
	pputs(s);
	putd(l);
	llt+=l;
	pputc('\t');
	putd(i);
	lit+=i;
	pputc('\t');
	if (d) {
		putd(d);
		pputc('d');
	}
	ldt+=d;
	putt(m/60,'h');
	putt(m%60,'m');
	lmt+=m;
	if (lmt>1440) {
		lmt-=1440;
		++ldt;
	}
	pputc('\n');
}
dostat()
{
	int f;
	ldt=lmt=lit=llt=0;
	if ((f=(argsc>2 || *argys[1]=='*'))) {
		putd(nu);
		pputs2(" users, epoch: ",dater(epoch,1));
		pputs("\nuser\tlogins\tics\ttos\n");
	}
	uinfo(&pstat);
	if (f) sline("total:\t",lit,lmt,ldt,llt);
}

pwhat(s)
char *s;
{
	char *t;
	t=index(uf.lm,':');
	if (t!=0) {
		t=(pwhatf==0)? uf.lm: t+1;
		if (*t!='\0') {
			pputs2(s,t);
			pputc('\n');
		}
	}
}
dowhat()
{
	if ( (pwhatf=strcmp("-w",argys[1]))==0 ) shift();
	uinfo(&pwhat);
}

pwhen(s)
char *s;
{
	pputs(s);
	if (uf.when[0]=='\0') pputs("Never logged in");
	else pputs(dater(uf.when,1));
	pputc('\n');
}
dowhen()
{
	uinfo(&pwhen);
}

pwho(s)
char *s;
{
	pputs2(s,uf.who);
	pputc('\n');
}
dowho()
{
	int i;
	if (argsc==1) {
		for (i=0;i<nu;i++) dump(logins[i]);
		dnl();
	}
	else uinfo(&pwho);
}

getstat()
{
	int i;
	FILE *stat;
	if ((stat=bopen("E:STAT","r"))==NULL) {
		if ((stat=bopen("D:STAT","r"))==NULL) {
			pputs("Can't open stat!\n");
			return;
		}
	}
	for (i=0;i<NUMSTATS;++i)
		*instat[i]=getw(stat);
	for (i=0;i<6;++i)
		epoch[i]=getc(stat);
	bclose(stat);
	unlink("E:STAT");
}

writestat()
{
	int i;
	FILE *stat;
	if  ((stat=bopen("D:STAT","w"))==NULL) {
		pputs("Can't write stat\n");
		return;
	}
	for (i=0;i<NUMSTATS;++i)
		putw(*instat[i], stat);
	for (i=0;i<6;++i)
		putc(epoch[i],stat);
	bclose(stat);
}

winfo()
{
	int t,i;
	pufile(uid, 'r');
	uf.fics=wics;
	uf.flogins=wlogins;
	t=H*60+M;
	i=t<minsin?t+1440:t;
	uf.fmins+=i-minsin;
	minsin=t;
	if (uf.fmins>1440) {
		uf.fmins-=1440;
		++uf.fdays;
	}
	uf.fun=un;
	uf.fst=st;
	pufile(uid, 'w');
}
		
pufile(rec,direc)
char direc;
{
	switch (direc) {
	case 'r':
		if (coreuid!=rec) {
			coreuid=rec;
			seek(ufile, rec*2, 0);
			if (read(ufile, &uf, 2)!=2)
				pputs("pufile: read");
		}
		break;
	case 'w':
		seek(ufile, rec*2, 0);
		if (write(ufile, &uf, 2)!=2)
			pputs("pufile: write");
	}
}

getuid(person)
char *person;
{
	int i;
	for (i=0;i<nu;++i) 
		if (strcmp(person,logins[i])==0) return(i);
	return(-1);
}

inohup()
{
	close(inode);
	hup();
}

inoint()
{
	close(inode);
	longjmp(interrupt, 1);
}

inoop()
{
	signal(SIGHUP, &inohup);
	signal(SIGINT, &inoint);
	inode=open("D:INODE",2);
	ipoin=-1;
}

rfsize(fname)
char *fname;
{
	char buf[128];
	int fd, recs, i;
	if ((fd=open(fname, 0))==-1) return(0);
	recs=cfsize(fd);
	seek(fd, -1, 2);
	read(fd, buf, 1);
	for (i=0;i<128;++i)
		if (buf[i]==CPMEOF) break;
	close(fd);
	return((recs-1)*128+i);
}

getinode()
{
	if ((++ipoin&3)==0)
		if (read(inode, gdbuf, 1)!=1) return (0);
	frecs=&gdbuf[(ipoin&3)*32];
	return (!(ipoin>=inl));
}

dols()
{
	int lfg, i;
	char *ch;
	ch="xwrxwrxwrd";
	lfg=0;
	if (argsc>1) {
		if (*argys[1]=='-') {
			while (*argys[1]!='\0') {
				if (*argys[1]=='l') lfg=1;
				++(argys[1]);
			}
			shift();
		}
	}
	inoop();
	while (getinode()) {
		if (argsc!=1) {
			for (i=1;i<argsc;++i)
				if (strcmp(frecs->fname,argys[i])==0) break;
		}
		if (i==argsc && argsc!=1) continue;
		if (lfg) {
			for (i=9;i>=0;--i) {
				if (frecs->fstat&(1<<i)) pputc(ch[i]);
				else pputc('-');
			}
			pputc(' ');
			if (frecs->fown>=0 && frecs->fown<nu)
				pputs(logins[frecs->fown]);
			else
				putd(frecs->fown);
			pputc('\t');
			putd(frecs->fsize);
			pputc('\t');
			pputs(dater(frecs->fdate,1)+4);
			pputc(' ');
			pputs(frecs->fname);
			pputc('\n');
		} else
			dump(frecs->fname);
	}
	dnl();
	close(inode);
}

mkfile(s)
char *s;
{
	int i;
	inoop();
	if (inl&3) {
		seek(inode, inl>>2, 0);
		read(inode, gdbuf, 1);
	}
	for (i=(inl&3)*32;i<128;++i) gdbuf[i]=0;
	seek(inode, inl>>2, 0);
	frecs=&gdbuf[(inl++&3)*32];
	for (i=0;i<6;++i)
		frecs->fdate[i]=ldate[i];
	strncpy(frecs->fname, s, 8);
	frecs->fsize=frecs->fgrp=0;
	frecs->fown=uid;
	frecs->fstat=0644;
	write(inode, gdbuf, 1);
	close(inode);
}

locatefile(s)
char *s;
{
	inoop();
	while (getinode())
		if (strcmp(frecs->fname,s)==0) return(ipoin);
	close(inode);
	return (-1);
}

setnode()
{
	seek(inode, -1, 1);
	write(inode, gdbuf, 1);
}
	
dogfile()
{
	if (st&PRIVMASK) return;
	if (argsc<2) return;
	mkfile(argys[1]);
	dotouch();
}

dotouch()
{
	int i;
	while (argsc>1) {
		if (locatefile(argys[1])==-1) return;
		pd();
		for (i=0;i<6;++i) frecs->fdate[i]=ldate[i];
		frecs->fsize=rfsize(flnm(ipoin));
		setnode();
		close (inode);
		shift();
	}
}

pd()
{
	if ((st&PRIVMASK)!=0 && frecs->fown!=uid) {
		pputs("Permission denied\n");
		kill (SIGINT);
	}
}

dochmod()
{
	int i,n;
	if (argsc<2) return;
	n=0;
	for (i=0;i<strlen(argys[1]);++i)
		n=(n*8)+(*(argys[1]+i)&7);
	while (argsc>2) {
		shift();
		if (locatefile(argys[1])==-1) return;
		pd();
		frecs->fstat=n;
		setnode();
		close(inode);
	}
}

dochown()
{
	int u;
	if (st&PRIVMASK) return;
	if (argsc<2) return;
	if ((u=getuid(argys[1]))==-1) return;
	while (argsc>2) {
		shift();
		if (locatefile(argys[1])==-1) return;
		frecs->fown=u;
		setnode();
		close(inode);
	}
}

dorm()
{
	int i, orec;
	char buf[32], *old;
	while (argsc>1) {
		if (locatefile(argys[1])==-1) return;
		pd();
		old=frecs;
		orec=ipoin>>2;
		frecs->fname[0]='\0';
		seek(inode, --inl>>2, 0);
		read(inode, gdbuf, 1);
		for (i=0;i<32;i++)
			buf[i]=gdbuf[i+(inl&3)*32];
		seek(inode, orec, 0);
		read(inode, gdbuf, 1);
		for (i=0;i<32;i++)
			old[i]=buf[i];
		seek(inode, orec, 0);
		write(inode, gdbuf, 1);
		strcpy(buf, flnm(inl));
		rename(buf, flnm(ipoin));
		close(inode);
	}
}

cmint()
{
	if (tty.col) pputc('\n');
	if (tcap.cteos) {
		pputs(tcap.cteos);
		tty.col=0;
	}
	close(inode);
	iccl1();
}

cmhup()
{
	close(inode);
	ichup();
}

chfl(n)
{
	char c;
	int i;
	if (locatefile(argys[1])==-1) {
		if (!n) {
			pputs("Not found\n");
			return(1);
		}
		mkfile(argys[1]);
 	}
	else close(inode);
	if (!readp()) {
		pputs("Access denied\n");
		return(1);
	}
	if ((icfile=bopen(flnm(ipoin), "r"))==NULL) return(1);
	icopen=1;
	signal(SIGINT, &cmint);
	signal(SIGHUP, &cmhup);
	return(0);
}

doed()
{
	char **text;
	int len, i, err;
	if (argsc<2) return;
	if (chfl(1)) return;
	len=0;
	if (!writep()) pputs("?read only\n");
	while(fgets(line, icfile)!=NULL) {
		line[strlen(line)-1]='\0';
		if (addline(&text, len+1, len++, line)==NULL) {
			--len;
			break;
		}
	}
	bclose(icfile);
	signal(SIGINT, SIG_IGN);
	err=1;
	while (err) {
		err=0;
		len=ed(&text, len, "");
		if (len==-1) {
			edcl(text,len);
			return;
		}
		if (!writep()) {
			pputs("?Can't write\n");
			err=1;
			continue;
		}
		if ((icfile=bopen(flnm(ipoin), "w"))==NULL) {
			pputs("?Write error\n");
			err=1;
		}
	}
	for (i=0;i<len;++i) putj(text[i],'\n',icfile);
	putc(CPMEOF, icfile);
	edcl(text,len);
	bclose(icfile);
	icopen=0;
	argys[1]=frecs->fname;
	argsc=2;
	dotouch();
}

edcl(text,len)
char **text;
{
	int i;
	if (len==0) return;
	for (i=0;i<len;++i) tfree(text[i]);
	tfree(text);
}

domore()
{
	zerof=0;
	if (argsc<2) return;
	if (strcmp("-0",argys[1])==0) {
		zerof=1;
		shift();
	}
	domc();
}

domc()
{
	int skip, count, lin, i ,j;
	char *s, c;
	if (argsc<2) return;
	if (*argys[1]=='+') {
		skip=atoi(argys[1]+1);
		shift();
		if (argsc<2) return;
	} else skip=0;
	count=0;
	if (chfl(0)) return;
	if (!zerof) pputs(tcap.clear);
	if (*tcap.cteol=='\0') zerof=1;
	lin=0;
	while(fgets(line,icfile)!=NULL) {
		if (count++>=skip) {
			i=0;
			do {
				if (!zerof) pputs(tcap.cteol);
				tty.col=0;
				for (i=i;(zerof || tty.col<tty.ncols-1) && line[i]!='\n';++i)
					pputc(line[i]);
				pputc('\n');
				if (!zerof && (++lin>=(tty.nlins-1))) {
					lin=0;
					if (st&XPRMASK) 
						s="---more";
					else
						s="---more (^C=quit, ' '=next, cr=next line";
					pputs(tcap.rvon);
					pputs(s);
					pputs(tcap.rvoff);
					pputs(tcap.cteol);
					for (;;) {
						c=getch();
						if (c=='\r') {
							lin=tty.nlins-1;
							break;
						}
						if (c==' ') break;
					}
					if (*tcap.dlin=='\0') {
						if (*tcap.cteol!='\0')
							for (j=0;j<strlen(s);++j) pputc(8);
						else bs(strlen(s));
					}
					else
						gotoxy(0,tty.nlins-1);
					if (!zerof && c==' ') {
						pputs(tcap.home);
						tty.col=0;
					}
				}
			} while (line[i]!='\n');

		}
	}
	if (!zerof) pputs(tcap.cteos);
	iclose();
}

gotoxy(x,y)
int x,y;
{
	pputs(tcap.dlin);
	if (tcap.dca>0) {
		pputc(y+tcap.dca);
		pputs(tcap.dsep);
		pputc(x+tcap.dca);
	} else {
		pputs(num(y-tcap.dca));
		pputs(tcap.dsep);
		pputs(num(x-tcap.dca));
	}
	pputs(tcap.dlout);
	tty.col=x;
}

docat()
{
	zerof=1;
	domc();
}

per(b)
{
	if ((st&PRIVMASK)==0 || (frecs->fstat&b)!=0) return(1);
	return (uid==frecs->fown && (frecs->fstat&(b<<6))!=0);
}
	
readp()
{
	return (per(4));
}

writep()
{
	return(per(2));
}
