/*
 * stty.c		86-02-12
 */
#include "defs.h"

dostty()
{
	struct sttyer *b;
	int i, nf, match, tfile, listf, fds, fdsp, j, f, n, k;
	char c, *s, **d;
	listf=0;
	if (argsc==1) {
		fds=tty.ncols/8;
		for (i=0;i<NUMSTTYOPS;i=j) {
			for (k=0;k<2;++k) {
				fdsp=0;
				for (j=i;;) {
					b=&sttyops[j];
					if (k==0) {
						if (b->pfunc==&sfix)
							if ((tty.mode&b->aux.bits)==0)
								pputc('-');
						pputs(b->sname);
					} else {
						if (b->pfunc==&sint)
							putd(*b->aux.sitem);
						if (b->pfunc==&schr)
							dchar(*b->aux.scitem);
						if (b->pfunc==&sstr)
							for (s=*b->aux.ssitem;*s!='\0';)
								dchar(*s++);
					}
					if (++j<NUMSTTYOPS && ++fdsp<fds) {
						pputc('\t');
						continue;
					}
					break;
				}
				pputc('\n');
			}
		}
		return;
	}

	while (argsc>1 || argsc==0) {
		if (argsc!=0) {
			if (strlen(argys[1])==3) {
				s=argys[1]+2;
				n=*s-'0';
				if (n>=0 && n<=7) {
					c=*s;
					*s='\0';
					f=0;
					switch (strsw("cr\0lf\0",argys[1])) {
					case 1:
						f=3;
					case 0:
						tty.mode = tty.mode & ~(7<<f) | (n<<f);
						shift();
						continue;
					}
				*s=c;
				}
			}
			listf=(strcmp("list",argys[1])==0);
			match=0;
			if (!listf) {
				nf=(*argys[1]=='-');
				for (i=0;i<NUMSTTYOPS;++i) {
					b=&sttyops[i];
					if (strcmp(argys[1]+nf,b->sname)==0) {
						(*b->pfunc)(b, nf);
						match=1;
						break;
					}
				}
			}
		}
		if (match==0 || argsc==0) {
			if ((tfile=open("D:TERMCAP", 0))==-1) {
				shift();
				continue;
			}
			signal(SIGINT,SIG_IGN);
			for (j=0;;++j) {
				if (read(tfile, &tcapent, 1)!=1) {
					close(tfile);
					dnl();
					break;
				}
				c=tcapent.tcols;
				if ((s=index(tcapent.termname,' '))!=NULL)
					*s='\0';
				tcapent.tcols=0;
				if (listf) {
					dump(tcapent.termname);
					continue;
				}
				if (argsc) {
					if (strcmp(tcapent.termname,argys[1])!=0)
						continue;
				} else {
					if (j!=term) continue;
					else argsc=2;
				}
				term=j;
				tty.ncols=c;
				tty.nlins=tcapent.tlins;
				d=&tcap.cup;
				s=tcapent.ttext;
				for (i=0;i<25;++i) {
					tfree(*d);
					if ((*d=nalloc(strlen(s)+1))==NULL) break;
					strcpy(*d++,s);
					s=s+strlen(s)+1;
				}
				tcap.dca=*s-128;
				close (tfile);
				break;
			}
		}
		shift();
	}
}
