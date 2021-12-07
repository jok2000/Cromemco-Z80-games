/*
 * ic.c		86-02-12
 */
#include "defs.h"

int    icclean(), skipmsg();

char *
fnm(n)
{
    int i;
    n=(n-(n%ICSAFILE))/10;
    strcpy(gpbuf,"D:0000.STR");
    for (i=5;i>1;--i) {
	gpbuf[i]=n%10+'0';
	n /= 10;
    }
    return(gpbuf);
}

ico(s)
char *s;
{
	if ((icfile=bopen(s,"r"))==NULL) kill(SIGINT);
	icopen=1;
	signal(SIGINT, &iccl1);
	signal(SIGHUP, &ichup);
}

skipicm()
{
    dnl();
    pputc('\n');
    readable=0;
    longjmp(quitjmp, 1);
}

icclean()
{
    if (!icopen) 
	return;
    iclose();
}

iclose()
{
    bclose(icfile);
    icopen=0;
}

ichup()
{
    signal(SIGQUIT, SIG_IGN);
    icclean();
    hup();
}

iccl1()
{
    icclean();
    signal(SIGQUIT, SIG_IGN);
    signal(SIGINT, &iccl1);
    longjmp(interrupt, 1);
}

tog(bit, s)
char *s;
{
    st^=bit;
    pputs2(s," mode o");
    if (st&bit) 
	pputc('n');
    else 
	pputs("ff");
    pputc('\n');
}

whattodo()
{
/*
 * A kludgy way of getting into the appropriate part of ic
 */
    if (argsc==-2) return('u');
    if (argsc==-1) {
	argsc=-2;
	return('r');
    }
    if (argsc!=1) return('w');
    return(tolower(getch()));
}

dou()
{
    argsc=-1;
    doic();
}

doic()
{
    char    hnum[7],  rmask[9], smask[9], c, *loc, *loca, *locb, chold,
	    **icm, lc, nc, *trash;
    int     i, ic_, ic_r_, msg, ic_f, ic_r_f, ic_r_s_, ic_r_s_f, mine,
	    rmasked, smasked, excluded, private, out, arlen, err;
    icopen=0;
    *rmask= *smask= '\0';
    ic_f=ic_r_f=1;
    for (ic_=1;ic_;) {
	signal(SIGHUP, &ichup);
	signal(SIGINT, &iccl1);
	setjmp(interrupt);
	if (argsc==1 && ic_f) {
	    dnl();
	    pputs("[?qrw] ");
	}
	ic_f=1;
	switch (whattodo()) {
	case '?':
	    pputs("Help\nq=Return to shell\n");
	    pputs("r=Enter read menu\nw=Write a message\n");
	    break;
	case 'q':
	    pputs("Quit\n");
	    icclean();
	    ic_=0;
	    break;
	case 'r':
	    if (argsc==1) pputs("Read\n");
	    for (ic_r_=1;ic_r_;) {
		if (argsc==1 && ic_r_f) pputs("[?cmqsuvx] ");
		ic_r_f=1;
		switch (c=whattodo()) {
		case '?':
		    pputs("Help\nc=Toggle continuous msg reading\n");
		    pputs("m=Set read masks\nq=Return to [?qrw] level\ns=Read a specific message\n");
		    pputs("u=Read messages not yet read (unread msgs)\nv=Toggle auto-vi mode\n");
		    pputs("x=Toggle expert user mode\n");
		    break;
		case 'c':
		    tog(CONTMASK,"Continuous");
		    break;
		case 'm':
		    pputs("Masks\nReceiver mask: ");
		    getline(rmask,8);
		    pputs("Sender mask: ");
		    getline(smask,8);
		    if (getuid(smask)==-1)
			*smask='\0';
		    break;
		case 'q':
		    pputs("Quit\n");
		    ic_r_=0;
		    break;
		case 's':
		    pputs("Specific\nEnter message (");
		    putd(ls);
		    pputc('-');
		    putd(sn);
		    pputs("): ");
		    getline(hnum, 6);
		    msg=atoi(hnum);
		case 'u':
		    if (c=='u') {
			msg=un;
			if (argsc==1) pputs("Unread\n");
		    	argsc=1;
		    }
		    pputc('\n');
		    if (msg<ls) msg=ls;
		    if (msg>sn)
			break;
		    ico(fnm(msg));
		    if (*rmask || *smask)
			pputs("Looking for msgs ");
		    if (*rmask) {
			pputs2("to ",rmask);
			if (*smask)
			    pputs(" and ");
			else pputc('\n');
		    }
		    if (*smask) {
			pputs2("from ",smask);
			pputc('\n');
		    }
		    for (i=0;i<msg%ICSAFILE;++i) {
			if (fgets(line, icfile)==NULL) {
			    pputs("icfile err\n");
			    kill(SIGINT);
			}
			while(strcmp(".\n",fgets(line, icfile))!=0);
		    }
		    for (;;) {
			if (fgets(line, icfile)==NULL) kill(SIGINT);
			if ((loc=index(line,','))==NULL) kill(SIGINT);
			*loc++='\0';
			excluded=0;
			smasked=(*smask!='\0') && (strcmp(line,smask)!=0);
			rmasked=(*rmask!='\0');
			mine=(strcmp(line,lname)==0);
			private=(*loc=='*');
			readable=mine || !private;
			loca=loc+private;
			do {
			    if ((locb=index(loca,' '))==NULL)
				locb=index(loca,'\n');
			    chold=*locb;
			    *locb='\0';
			    if (*loca=='-') excluded |= (strcmp(lname,loca+1)==0);
			    readable |= (strcmp(lname,loca)==0);
			    rmasked = rmasked && (strcmp(rmask,loca)!=0);
			    *locb=chold;
			    loca=locb+1;
			} while (chold!='\n');
			readable = readable && !excluded && !smasked && !rmasked && !(mine && c=='u');
			signal(SIGQUIT, &skipicm);
			setjmp(quitjmp);
			testio();
			if (readable) {
			    pputs2(line," > ");
			    pputs2(loc,"[ ");
			    fgets(line, icfile);
			    *(line+strlen(line)-1)='\0';
			    pputs2(line," #");
			    putd(msg);
			    pputs(" ]\n");
			    fgets(line, icfile);
			    pputs(line);
			    pputc('\n');
			    if (!(st&CONTMASK)) {
				ic_r_s_f=1;
				for (ic_r_s_=1;ic_r_s_;) {
				    if (ic_r_s_f) pputs("[?QRS] ");
				    ic_r_s_f=1;
				    switch (tolower(getch())) {
				    case '?':
					pputs("Help\nq=Return to [?qrw] menu\n");
					pputs("r=Read message\ns=Skip messsage\n");
					break;
				    case 'q':
					pputs("Quit\n");
					signal(SIGQUIT, SIG_IGN);
					kill(SIGINT);
				    case 'r':
					pputs("Read\n\n");
					ic_r_s_=0;
					break;
				    case 's':
					pputs("Skip\n\n");
					readable=0;
					ic_r_s_=0;
					break;
				    default:
					ic_r_s_f=0;
				    }
				}
			    }
			}
			do {
			    fgets(line, icfile);
			    out=(strcmp(".\n",line)==0);
			    if (readable && !out) pputs(line);
			} while (!out);
			signal(SIGQUIT, SIG_IGN);
			if (readable) pputc('\n');
			if (un<++msg) un=msg;
			if (msg>sn) break;
			if (msg%ICSAFILE==0) {
			    iclose();
			    ico(fnm(msg));
			}
		    }
		    iclose();
		    break;
		case 'v':
		    tog(VIMASK,"Auto-vi");
		    break;
		case 'x':
		    tog(XPRMASK,"Expert");
		    break;
		default:
		    ic_r_f=0;
		}
		if (c=='s' || c=='u') break;
	    }
	    break;
	case 'w':
	    if (argsc>=2) {
		*line='\0';
		for (i=1;i<argsc;++i) {
			if (i>1) strcat(line," ");
			strcat(line,argys[i]);
		}
	    } else {
		pputs("Write\nReceiver: ");
		getline(line,MAXLINE-20); /* allow room for goodies on this line */
	    }
	    argsc=1;
	    signal(SIGINT, SIG_IGN);
	    signal(SIGHUP, SIG_IGN);
	    arlen=0;
	    addline(&icm, arlen, arlen++, line);
	    pputs("Subject: ");
	    getline(line, MAXLINE-1);
	    addline(&icm, arlen, arlen++, line);
	    if (st&XPRMASK)
		pputs("Go:\n");
	    else
		pputs("Enter your msg, ending with a line with only a dot.\n");
	    err=1;
	    while (err) {
		err=0;
		if ((icfile=nalloc(BUFSIZ))==NULL) icfile=nalloc(1);
		arlen=ed(&icm, arlen, "a");
		signal(SIGINT, SIG_IGN);
		signal(SIGHUP, SIG_IGN);
		tfree(icfile);
		if (arlen<2) break;
		if (un==++sn) ++un;
		if (sn-ls>MAXONLINE) {
		    unlink(fnm(ls));
		    ls+=ICSAFILE;
		}
		if (sn%ICSAFILE==0) {
		    if ((icfile=bopen(fnm(sn), "w"))==NULL) {
			err=1;
			continue;
		    }
		} else {
		    if ((icfile=bopen(fnm(sn), "a"))==NULL) {
			err=1;
			continue;
		    }
		}
		++wics;
		putj(lname, ',', icfile);
		for (i=0;*(icm[0]+i);++i) {
		    if (isctl(*(icm[0]+i))) *(icm[0]+i)='\0';
		}
		putj(icm[0], '\n', icfile);
		putj(dater(ldate,0), '\n', icfile);
		for (i=1;i<arlen;++i) {
		    if (strcmp(".", icm[i])==0 || index(icm[i],'\r')!=0 || index(icm[i],'\n')!=0) *icm[i]='\0';
		    putj(icm[i], '\n', icfile);
		}
		edcl(icm,arlen);
		fputs(".\n\032", icfile);
		iclose();
	    }
	    break;
	default:
	    ic_f=0;
	}
    }
}

edfix()
{
    longjmp(edhup, 1);
}

char
addr(addr1, addr2, len, dot, s)
int *addr1, *addr2, *dot;
char *s;
{
	if (*s=='\0') {
		s="+p";
		pputs2(tcap.cup,tcap.cteol);
	}
	*addr1=address(len, *dot, &s);
	if (*s==',') {
		++s;
		if (*addr1==0) *addr1=1;
		if ((*addr2=address(len, *dot, &s))==0) *addr2=len;
	}
	else {
		if (*addr1==0) *addr1=*dot;
		*addr2=*addr1;
	}
	if (*addr1==-1 || *addr2==-1 || *addr1>*addr2) {
		pputs("?$\n");
		return(0);
	}
	*dot=*addr2;
	return((*s)?(*s):'p');
}

address(len, dot, s)
char **s;
{
	int minus, n, a1, relerr;
	char c;
	a1=minus=0;
	for (;;) {
		c=**s;
		if ('0'<=c && c<='9') {
			n=0;
			do {
				++(*s);
				n *= 10;
				n +=c -'0';
			} while ( (c=**s)>='0' && c<='9');
			if (minus<0) n = -n;
			a1 += n;
			minus=0;
			continue;
		}
		relerr=0;
		if (a1 || minus) relerr++;
		switch(c) {
		case ' ':
		case '\t':
			++(*s);
			continue;
		case '+':
			minus+=2;
		case '^':
		case '-':
			--minus;
			if (a1==0) a1=dot;
			++(*s);
			continue;
		case '$':
			a1=len;
			++(*s);
			break;
		case '.':
			a1=dot;
			++(*s);
			break;
		default:
			if (a1==0) return(0);
			a1 += minus;
			if (a1<0 || a1>len) return(-1);
			return(a1);
		}
		if (relerr) return(-1);
	}
}

zap(s)
char **s;
{
	char goop[MAXLINE+2],c,*ns,*os,*as, *tline;
	int len, tpos, ttpos, temp;
	tline=goop+1;	/* allocate room for one backstep */
	for (;;) {
		for (ns=*s;*ns;++ns) {
			if (iscot(*ns)) pputc(*ns);
			else pctl(*ns);
		}
		pputc('\n');
		getline(tline,MAXLINE-1);
		ttpos=tpos=0;
		as=NULL;
		if (*tline=='\0') break;
		tline[strlen(tline)+1]='\0';
		while ((c=tline[tpos++]) && (as==NULL)) {
			temp=zloc(*s,ttpos);
			if (temp==-1) break;
			if (c==' ') {
				++ttpos;
				continue;
			}
			if (c=='\t') {
				ttpos=1+(ttpos|7);
				continue;
			}
			if (c=='^') {
				as=*s+temp;
				break;
			}
			if (c=='$') c='\0';
			if (c=='%') c=' ';
			if (c=='#') c=(*s)[temp]|128;
			++ttpos;
			if (c<' ') ++ttpos;
			(*s)[temp]=c;
		}
		--tpos;
		ns=os=*s;
		while (*ns) {
			if (*os<128) *ns++=*os;
			else if (as) --as;
			++os;
		}
		len=strlen(os=*s)+strlen(tline+tpos)+1;
		if ((ns=nalloc(len))!=NULL) {
			strcpy(ns,os);
			if (as) {
				strcpy(ns+(as-os),tline+tpos+1);
				strcat(ns,as);
			}
			else strcat(ns,tline+tpos);
			tfree(os);
			*s=ns;
			if (len<strlen(*s)+1) pputs("Fatal z error\n");
		}
	}
}

/* what follows should really not start from the beginning of the
 * string all of the time... ah well
 */
zloc(s,n)
char *s;
{
	char c;
	int pos,rv;
	rv=pos=0;
	--s;
	while ((c=*(++s)&127)) {
		if (c=='\t') pos|=7;
		else if (c<' ') ++pos;
		++pos;
		if (pos>n) return(rv);
		++rv;
	}
	return(-1);
}

addline(str, pos, len, s)
char ***str, *s;
{
	int i;
	char **ts;
	if (pos<0 || pos>len) pos=len;
	if ((ts=nalloc((len+1)*CPTRSZ))==NULL) return(NULL);
	if (len!=0) {
		for (i=0;i<pos;++i) ts[i]=(*str)[i];
		for (i=pos;i<len;++i) ts[i+1]=(*str)[i];
		tfree(*str);
	}
	*str=ts;
	if ((ts[pos]=nalloc(strlen(s)+1))==NULL) {
		ts[pos]=nalloc(1);
		*ts[pos]='\0';
	} else
		strcpy(ts[pos],s);
	return(1);
}

delline(str, pos, len)
char ***str;
{
	int i;
	if (len==1) {
		tfree(**str);
		tfree(*str);
		return;
	}
	tfree ((*str)[pos]);
	for (i=pos+1;i<len;++i) (*str)[i-1]=(*str)[i];
}

rchk(a,b,l)
{
	return (a<1 || b<1 || a>l || b>l);
}

ed(str, curlen, com)
char ***str, *com;
{
    char thecom;
    int qflag, j, len, i, done, addr1, addr2, dot;
    qflag=0;
    len=curlen;
    dot=curlen+1;
    done=0;
    signal(SIGINT, &onint);
    signal(SIGHUP, &edfix);
    if (setjmp(edhup)==1) {
	edcl(*str,len);
	ichup();
    }
    while (!done) {
	if (setjmp(interrupt)==1)
	    pputs("?!\n");
	if (*com=='\0') {
	    pputc('*');
	    getline(line,MAXLINE-1);
	} else {
	    strcpy(line,com);
	    com="";
	}
	if ((thecom=addr(&addr1, &addr2, len, &dot, line))==0) continue;
	switch (thecom) {
	case 'n':
	case 'z':
	case 'p':
	    if (rchk(addr1,addr2,len)) {
		dot=len;
		break;
	    }
	    for (i=addr1;i<=addr2;++i) {
		if (thecom=='n') {
			putd(i);
			pputc('\t');
		}
		if (thecom=='z') zap(&((*str)[i-1]));
		else {
		    pputs((*str)[i-1]);
		    pputc('\n');
		}
	    }
	    break;

	case 'c':
	case 'd':
	    if (rchk(addr1,addr2,len)) break;
	    for (i=addr1;i<=addr2;++i) delline(str, addr1-1, len--);
	    if (addr1>len) addr1=len;
	    dot=addr1;
	    if (thecom=='d') break;
	case 'i':
	    --addr1;
	case 'a':
	    dot=addr1;
	    if (dot<0) dot=0;
	    if (dot>len) dot=len;
	    for (;;) {
		getline(line, MAXLINE-1);
		if (strcmp(".",line)==0) break;
		if (addline(str, dot++, len++, line)==NULL) {
		    --len;
		    --dot;
		    break;
		}
	    }
	    break;

	case '=':
	    putd(len);
	    pputc('\n');
	case '#':
	    break;

	case 'q':
	    if ((qflag=!qflag)) {
		pputs("?not saved\n");
		break;
	    }
	case 'Q':
	    edcl(*str,len);
	    len=-1;
	case 'w':
	    done=1;
	    break;

	default:
	    pputs("??\n");
	}
	if (thecom!='q') qflag=0;
    }
    return(len);
}
