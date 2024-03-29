C Based on 1979 arcade game "Crash" by Exidy
C Copyright (c) 1979, Jeff Kesner
C
C C:FOR =CRASH
C C:LINK CRASH,B:GRAPHFOR,C:FORLIB/G
      PROGRAM CRASH
      BYTE CR(5),SC(5),NSC(10),PMES(15),NSC1(5),
     +FNAM(11),NAME1(12),HISC(6,10),NAMES(12,10),ST2(17)
      DIMENSION ICOD(4,2),ICARS(5,2),ICSET(3,3)
      COMMON /JCAR/ ICCARS(3,3),ICRASH,ICRX,ICRY,ICPSX,ICPSY
     +,IDL,IDLT(13,13),JSPED,JSO,ID,ICCAR
      COMMON /MESS/ IMES(11)
      EQUIVALENCE (NSC(1),IMES(1)),(NSC1(1),NSC(6)),(NAME1(1),
     +IMES(6))
      DATA FNAM /67,82,65,83,72,73,71,72,83,67,79/
C 'CRASHIGHSCO'
      DATA ST2 /42,42,42,32,71,65,77,69,32,79,86,69,82,32,42,42
     +,42/
C '*** GAME OVER ***'
      DATA ICOD /0,0,254,254,0,254,254,0/
      DATA ICARS /90,102,114,126,138,146,146,146,146,146/
      DATA ICSET /3,2,4,98,40,214,8,156,98/
      DATA PMES /32,80,79,73,78,84,83,32,80,69,82,32,68,79,84/
C ' POINTS PER DOT'
      DATA CR /67,82,65,83,72/
C 'CRASH'
      DATA SC /83,67,79,82,69/
C 'SCORE'
 9400 ICAR=2
      JSPED=6
      JSO1=6
      JXYZ1=127
      ICCAR=0
      CALL INTSET
      DO 3 J=1,5
      NSC(J)=48
 3    CONTINUE
      IAWARD=2
 996  DO 1 J=1,13
      DO 2 K=1,13
      IDLT(J,K)=1
 2    CONTINUE
 1    CONTINUE
      JSO=JSO1
      NJK=22
      JSPED=JSO
      IDL=0
      IONES=0
      ICOUNT=160
      DO 990 J=1,3
      DO 991 K=1,3
      ICCARS(J,K)=ICSET(J,K)
 991  CONTINUE
 990  CONTINUE
      ICRASH=0
      IF (JSPED.EQ.6) GOTO 989
      JSPED=JSPED+2
      GOTO 988
 989  IF (ICCAR.EQ.3) GOTO 988
      ICCAR=ICCAR+1
      JSPED=2
 988  IL=(JSPED/2)*5+15*(ICCAR-1)
      JSO=JSPED
      JSO1=JSO
      ITENS=IL/10
      IONES=IL-ITENS*10
C Page 2
      M=0
      IF (ICCAR.EQ.3) GOTO 9398
      M12=ICCAR+1
      DO 9399 J=M12,3
      ICCARS(J,1)=2
      ICCARS(J,2)=90
      ICCARS(J,3)=128
 9399 CONTINUE
 9398 CALL INITG$
      CALL ANIMT$
C Resolution etc
      CALL CHAR$(26)
      CALL CHAR$(2)
      CALL CHAR$(14)
      CALL CHAR$(5)
      CALL PAGE$
C Display credits and points per dot
      CALL CURSR$(24,122)
      CALL CHAR$(ITENS+48)
      CALL CHAR$(IONES+48)
      CALL STRIN$(15,PMES)
C Points per dot
C Display the play field
      CALL ANIMT$
      CALL PAGE$
      DO 30 I=1,4
      IBX=ICOD(I,1)
      IBY=ICOD(I,2)
      INX=1
      INY=1
      IF (IBX.NE.0) INX=-1
      IF (IBY.NE.0) INY=-1
      DO 10 J=1,65,16
C The lane walls
      CALL CURSR$(IBX+(J-1)*INX,IBY+(J-1)*INY)
      CALL LINE$(IBX+98*INX,IBY+(J-1)*INY)
      CALL CURSR$(IBX+(J-1)*INX,IBY+(J-1)*INY)
      CALL LINE$(IBX+(J-1)*INX,IBY+98*INY)
C Compute number of dots for this lane
      J1=7-((J-1)/16+1)
      DO 5 J2=1,J1
      IMX=IBX+(J+7)*INX
      IMY=IBY+(J+16*J2)*INY
      CALL CURSR$(IMX,IMY)
      CALL DOT$
      CALL CURSR$(IMY,IMX)
      CALL DOT$
 5    CONTINUE
 10   CONTINUE
 30   CONTINUE
C Central Box
      CALL CURSR$(80,80)
      CALL LINE$(80,174)
      CALL LINE$(174,174)
      CALL LINE$(174,80)
      CALL LINE$(80,80)
      CALL PAUSE$(30)
      CALL CHAR$(22)
      CALL CHAR$(6)
      CALL CURSR$(98,160)
      CALL STRIN$(5,CR)
      CALL CURSR$(98,96)
      CALL STRIN$(5,SC)
      CALL CURSR$(98,84)
      CALL STRIN$(5,NSC)
      IF (ICAR.EQ.0) GOTO 9970

      DO 995 J=1,ICAR
      CALL ICDRWY(2,ICARS(J,1),ICARS(J,2))
 995  CONTINUE
C 9970 DO 999 J=1,32000
C 999  CONTINUE
C Page 3
 9970 ICPSX=156
      ID=1
      ICPSY=8
C Game loop starts here      
 90   CALL CHAR$(22)
      JD=ID
      JCPSX=ICPSX
      JCPSY=ICPSY
      MNO=NSC(1)*10-480+NSC(2)-48
      IF (MNO.LT.IAWARD) GOTO 9990
      IAWARD=IAWARD+4
      IF (ICAR.GT.4) GOTO 9990
      ICAR=ICAR+1
      CALL ICDRWY(2,ICARS(ICAR,1),ICARS(ICAR,2))
 9990 CALL ICDRWY(ID,ICPSX,ICPSY)
      IF (NJK.EQ.0) GOTO 984
      NJK=NJK-1
      GOTO 983
C Move the cars
 984  DO 980 J=1,3
      CALL ICOMP(J)
 980  CONTINUE
C Collision?  Goto Collision handler
 983  IF (ICRASH.EQ.1) GOTO 900
      GOTO (100,110,120,130),ID
 100  ISP0=ISP(0)
      ICPSX=ICPSX+ISP0
      IF (ICPSX.LT.254-ICPSY) GOTO 140
      ICPSX=254-ICPSY
      ICPSY=ICPSY+8
      ID=2
      GOTO 140
 110  ICPSY=ICPSY+ISP(0)
      IF (ICPSY.LT.ICPSX) GOTO 140
      ICPSY=ICPSX
      ICPSX=ICPSX-8
      ID=3
      GOTO 140
 120  ICPSX=ICPSX-ISP(0)
      IF (ICPSX.GT.254-ICPSY) GOTO 140
      ICPSX=254-ICPSY
      ICPSY=ICPSY-8
      ID=4
      GOTO 140
 130  ICPSY=ICPSY-ISP(0)
      IF (ICPSY.GT.ICPSX) GOTO 140
      ICPSY=ICPSX
      ICPSX=ICPSX+8
      ID=1
 140  CALL CHAR$(16)
      IF (((ICPSX.GT.112).AND.(ICPSX.LT.144)).OR.((ICPSY.GT.112
     +).AND.(ICPSY.LT.144))) GOTO 240
      GOTO (200,210,220,230),ID
 200  ICPSY=(ICPSY+16)/16*16-8
      GOTO 290
 210  ICPSX=254-((254-ICPSX+16)/16*16-8)
      GOTO 290
 220  ICPSY=254-((254-ICPSY+16)/16*16-8)
      GOTO 290
 230  ICPSX=(ICPSX+16)/16*16-8
      GOTO 290
 240  GOTO (250,260,270,280),ID
 250  K=INP(26)
      K1=IABS(K)
      IF (K1.LT.32) GOTO 290
      ICPSY=ICPSY+K/K1*2
      IF (ICPSY.LT.8) ICPSY=8
      IF (ICPSY.GT.72) ICPSY=72
      GOTO 290
 260  K=INP(25)
C Page 4
      K1=IABS(K)
      IF (K1.LT.32) GOTO 290
      ICPSX=ICPSX+K/K1*2
      IF (ICPSX.LT.182) ICPSX=182
      IF (ICPSX.GT.246) ICPSX=246
      GOTO 290
 270  K=INP(26)
      K1=IABS(K)
      IF (K1.LT.32) GOTO 290
      ICPSY=ICPSY+K/K1*2
      IF (ICPSY.LT.182) ICPSY=182
      IF (ICPSY.GT.246) ICPSY=246
      GOTO 290
 280  K=INP(25)
      K1=IABS(K)
      IF (K1.LT.32) GOTO 290
      ICPSX=ICPSX+K/K1*2
      IF (ICPSX.LT.8) ICPSX=8
      IF (ICPSX.GT.72) ICPSX=72
 290  J=ICPSX/16+1
      K=ICPSY/16+1
      IF (((J.LT.11).AND.(J.GT.7)).OR.((K.LT.11).AND.(K.GT.7)))
     + GOTO 295
      IF (J.GT.7) J=J-3
      IF (KT.GT.7) K=K-3
      IF (IDLT(J,K).EQ.0) GOTO 295
      CALL BEEPER
      IDLT(J,K)=0
      ICOUNT=ICOUNT-1
      IF (ICOUNT.GT.70) GOTO 9844
      IF (JSO.GT.JSO1) GOTO 9844
      JSO1=JS0
      JSO=JSO+2
 9844 CALL CURSR$(146,84)
      CALL CHAR$(NSC(5))
      NSC(5)=NSC(5)+IONES
      IJ=NSC(4)
      CALL CURSR$(146,84)
      CALL CHAR$(22)
      IF (NSC(5).LT.58) GOTO 293
      NSC(5)=NSC(5)-10
      NSC(4)=NSC(4)+1
 293  NSC(4)=NSC(4)+ITENS
      CALL CHAR$(NSC(5))
      ICURX=146
      ICURY=84
      DO 294 N=1,4
      L=5-N
      ICURX=ICURX-12
      IF ((NSC(L).LT.58).OR.(L.EQ.1)) GOTO 291
C Above is bug fix?      
      NSC(L)=NSC(L)-10
      IJ1=NSC(L-1)
      NSC(L-1)=NSC(L-1)+1
 291  IF (NSC(L).EQ.IJ) GOTO 292
      CALL CHAR$(16)
      CALL CURSR$(ICURX,ICURY)
      IF (IJ.LT.32) GOTO 2809

      CALL CHAR$(IJ)
2809  CALL CHAR$(22)
      CALL CURSR$(ICURX,ICURY)
      CALL CHAR$(NSC(L))
 292  IJ=IJ1
 294  CONTINUE
      IF (ICOUNT.NE.0) GOTO 998
      N=127
      DO 997 J=1,5
      DO 777 K=1,100
C Page 5      
      L=101-K
      DO 776 M=1,L
 776  CONTINUE
      N=-N
      CALL OUT(25,N)
 777  CONTINUE
 997  CONTINUE
      GOTO 996
 998  CALL CHAR$(16)
 295  CALL ICDRWN(JD,JCPSX,JCPSY)
C Back to main loop
      GOTO 90
C Collision
 900  ICAR=ICAR-1
      JSO=JSO1-2
      JSO1=JSO
      M=127
      CALL CHAR$(25)
      INCX=4
      INCY=4
      IF (ICPSX.GT.126) INCX=-4
      IF (ICPSY.GT.126) INCY=-4
      CALL XPLODE
      DO 666 J=1,29
      JD=ID
      JCPSX=ICPSX
      JCPSY=ICPSY
      ID=ID+1
      IF (ID.EQ.5) ID=1
      ICPSX=ICPSX+INCX
      ICPSY=ICPSY+INCY
      CALL CHAR$(16)
      CALL ICDRWN(JD,JCPSX,JCPSY)
      CALL CHAR$(17)
      CALL ICDRWY(ID,ICPSX,ICPSY)
 666  CONTINUE
      CALL CHAR$(0)
      DO 665 J=16,31
      K=47-J
      CALL PAUSE$(1)
      CALL CHAR$(K)
 665  CONTINUE
      ICRASH=0
      IF (ICAR.GT.-1) GOTO 996
C Game Over
      CALL CHAR$(7)
      DO 1112 J=1,5
      NSC1(J)=NSC(J)
 1112 CONTINUE
      WRITE(3,771)
771   FORMAT(1X, 'JOK GAME OVER')
C *** DISK HIGH SCORE TABLE
      CALL OPEN (6,FNAM,0)
      READ (6,600) HISC
 600  FORMAT (6A1)
      READ (6,700) NAMES  
 700  FORMAT(12A1)
      L=1
 603  K=1
 601  IF (NSC(K).GT.HISC(K,L)) GOTO 701
      IF (NSC(K).EQ.HISC(K,L)) GOTO 602
 702  L=L+1
      IF (L.EQ.11) GOTO 604
      GOTO 603
 602  K=K+1
      IF (K.NE.6) GOTO 601
      GOTO 702
 701  WRITE (3,775) (NSC(I),I=1,5)
 775  FORMAT('YOUR SCORE OF '5A1' IS ONE OF THE TEN HIGHEST.'
     +/'GIVE ELEVEN LETTERS FOR YOUR NAME:')
      READ (3,606) NAME1
 606  FORMAT(12A1)
C Page 6 
      IF (L.EQ.10) GOTO 9845
      DO 607 L1=L,10
      L2=L+10-L1
      L3=L2-1
      DO 608 L4=1,5
      HISC(L4,L2)=HISC(L4,L3)
 608  CONTINUE
      DO 609 L4=1,12
      NAMES(L4,L2)=NAMES(L4,L3)
 609  CONTINUE
 607  CONTINUE
 9845 DO 610 J=1,5
      HISC(J,L)=NSC(J)
 610  CONTINUE
      DO 611 J=1,12
      NAMES(J,L)=NAME1(J)
 611  CONTINUE
 604  REWIND 6
      WRITE (6,612) ((HISC(I,J),I=1,5),J=1,10),((NAMES(I,J),I=1
     +,12),J=1,10)
 612  FORMAT (10('+',5A1/),10('+'12A1/))
      ENDFILE 6
      WRITE(3,615)
 615  FORMAT (//24X'*** GAME OVER ***'//18X'+++ CRASH--HIGHEST SCORES **
     ++'/)
      DO 616 J=1,10
      DO 617 K=1,12
      NAME1(K)=NAMES(K,J)
 617  CONTINUE
      DO 618 K=1,5
      NSC(K)=HISC(K,J)
 618  CONTINUE
      WRITE (3,619) (NSC(I),I=1,5),NAME1
 619  FORMAT (23X,5A1,1X,12A1)
 616  CONTINUE
      CALL CHAR$(5)
      CALL CHAR$(7)
      DO 1113 J=1,12
      NAME1(J)=NAMES(J,1)
 1113 CONTINUE
      DO 1114 J=1,5
      NSC(J)=HISC(J,1)
 1114 CONTINUE
      CALL EMES
      CALL CHAR$(2)
      CALL CHAR$(6)
      CALL CHAR$(7)
      CALL EMES
      CALL CURSR$(25,242)
      CALL STRIN$(17,ST2)
 620  CALL PAUSE$(10)
      CALL CHAR$(5)
      CALL PAUSE$(10)
      CALL CHAR$(6)
      IF (ISP(0).EQ.2) GOTO 620
      GOTO 9400
      END
      SUBROUTINE EMES
      BYTE ST1(4),ST3(17),ST4(11),ST5(19),NSC(10),NSC1(5),NAME1(
     +12)
      COMMON /MESS/ IMES(11)
      EQUIVALENCE (NSC(1),IMES(1)),(NSC1(1),NSC(6)),(NAME1(1),
     +IMES(6))
      DATA ST1 /32,66,89,32/
C 'BY'
      DATA ST3 /80,82,69,83,83,32,79,78,69,32,84,79,32,80,76,65
     +,89/
C Page 7    
C 'PRESS ONE TO PLAY'
      DATA ST4 /76,65,83,84,32,83,67,79,82,69,61/
C 'LAST SCORE='
      DATA ST5 /72,73,71,72,69,83,84,32,83,67,79,82,69,32,69,86
     +,69,82,58/
C 'HIGHEST SCORE EVER:'
      CALL PAGE$
      CALL CHAR$(21)
      CALL CURSR$(25,156)
C PRESS ONE TO PLAY
      CALL STRIN$(17,ST3)
      CALL CURSR$(32,132)
C LAST SCORE=
      CALL STRIN$(11,ST4)
      CALL STRIN$(5,NSC1)
      CALL CURSR$(14,108)
C 'HIGHEST SCORE EVER:'
      CALL STRIN$(19,ST5)
      CALL CURSR$(0,84)
      CALL STRIN$(5,NSC)
C BY
      CALL STRIN$(4,ST1)
      CALL CHAR$(32)
      CALL STRIN$(12,NAME1)
      RETURN
      END
C Fast or slow speed per joystick of player
      FUNCTION ISP(I)
      J=INP(24)
      K=I
      J=IABS(J)
      K=2
      IF (J-J/2*2.EQ.0) K=6
      ISP=K
      RETURN
      END
C Move a car
      SUBROUTINE ICOMP(I)
      BYTE IDC(40,3)
      COMMON /JCAR/ ICCARS(3,3),ICRASH,ICRX,ICRY,ICPSX,ICPSY
     +,IDL,IDLT(13,13),JSPED,JSO,MD,ICCAR
      JSPED=JSO
      IF (((ICCARS(I,2).GT.112).AND.(ICCARS(I,2).LT.144)).OR.((
     +ICCARS(I,3).GT.112).AND.(ICCARS(I,3).LT.144))) JSPED=2
      IF (I.GT.ICCAR) JSPED=0
      ICPSY1=ICPSY
      ICPSX1=ICPSX    
      IF (ICPSY.GT.126) ICPSY1=254-ICPSY
      IF (ICPSX.GT.126) ICPSX1=254-ICPSX
      IF ((MD.EQ.1).OR.(MD.EQ.3)) ICPSX1=ICPSY1
      IF ((MD.EQ.2).OR.(MD.EQ.4)) ICPSY1=ICPSX1
      ID=ICCARS(I,1)
      JD=ICCARS(I,1)
      JCPSX=ICCARS(I,2)
      JCPSY=ICCARS(I,3)
      GOTO (100,110,120,130),ID
 100  ICCARS(I,2)=ICCARS(I,2)+JSPED
      IF (ICCARS(I,2).LT.ICCARS(I,3)) GOTO 140
      ICCARS(I,2)=ICCARS(I,3)
      ICCARS(I,3)=ICCARS(I,3)-8
      ID=4
      ICCARS(I,1)=4
      GOTO 140
 110  ICCARS(I,3)=ICCARS(I,3)+JSPED
      IF (ICCARS(I,3).LT.254-ICCARS(I,2)) GOTO 140
      ICCARS(I,3)=254-ICCARS(I,2)
      ICCARS(I,2)=ICCARS(I,2)+8
      ID=1
      ICCARS(I,1)=1
      GOTO 140
 120  ICCARS(I,2)=ICCARS(I,2)-JSPED
C Page 8 
      IF (ICCARS(I,2).GT.ICCARS(I,3)) GOTO 140
      ICCARS(I,2)=ICCARS(I,3)
      ICCARS(I,3)=ICCARS(I,3)+8
      ID=2
      ICCARS(I,1)=2
      GOTO 140
 130  ICCARS(I,3)=ICCARS(I,3)-JSPED
      IF (ICCARS(I,3).GT.254-ICCARS(I,2)) GOTO 140
      ICCARS(I,3)=254-ICCARS(I,2)
      ICCARS(I,2)=ICCARS(I,2)-8
      ID=3
      ICCARS(I,1)=3
 140  CALL CHAR$(16)
      IF (((ICCARS(I,2).GT.112).AND.(ICCARS(I,2).LT.144)).OR.
     +((ICCARS(I,3).GT.112).AND.(ICCARS(I,3).LT.144))) GOTO 240
      GOTO (220,230,200,210),ID
 200  ICCARS(I,3)=(ICCARS(I,3)+16)/16*16-8
      GOTO 290
 210  ICCARS(I,2)=254-((254-ICCARS(I,2)+16)/16*16-8)
      GOTO 290
 220  ICCARS(I,3)=254-((254-ICCARS(I,3)+16)/16*16-8)
      GOTO 290
 230  ICCARS(I,2)=(ICCARS(I,2)+16)/16*16-8
      GOTO 290
 240  IF (JSPED.EQ.0) GOTO 290
      IX=ICCARS(I,2)
      IY=ICCARS(I,3)
      IF (IY.GT.126) IY=254-IY
      IF (IX.GT.126) IX=254-IX
      GOTO (250,260,270,280),ID
 250  IF (IY.GT.ICPSY1) ICCARS(I,3)=ICCARS(I,3)+2
      IF (IY.LT.ICPSY1) ICCARS(I,3)=ICCARS(I,3)-2
      IF (ICCARS(I,3).LT.182) ICCARS(I,3)=182
      IF (ICCARS(I,3).GT.246) ICCARS(I,3)=246
      GOTO 290
 260  IF (IX.GT.ICPSX1) ICCARS(I,2)=ICCARS(I,2)-2
      IF (IX.LT.ICPSX1) ICCARS(I,2)=ICCARS(I,2)+2
      IF (ICCARS(I,2).LT.8) ICCARS(I,2)=8
      IF (ICCARS(I,2).GT.72) ICCARS(I,2)=72
      GOTO 290
 270  IF (IY.GT.ICPSY1) ICCARS(I,3)=ICCARS(I,3)-2
      IF (IY.LT.ICPSY1) ICCARS(I,3)=ICCARS(I,3)+2
      IF (ICCARS(I,3).LT.8) ICCARS(I,3)=8
      IF (ICCARS(I,3).GT.72) ICCARS(I,3)=72
      GOTO 290
 280  IF (IX.LT.ICPSX1) ICCARS(I,2)=ICCARS(I,2)-2
      IF (IX.GT.ICPSX1) ICCARS(I,2)=ICCARS(I,2)+2
      IF (ICCARS(I,2).LT.182) ICCARS(I,2)=182
      IF (ICCARS(I,2).GT.246) ICCARS(I,2)=246
 290  J=ICCARS(I,2)/16+1
      K=ICCARS(I,3)/16+1
      IF (((J.LT.11).AND.(J.GT.7)).OR.((K.LT.11).AND.(K.GT.7)))
     +GOTO 295
      IF (J.GT.7) J=J-3
      IF (K.GT.7) K=K-3
      IF (IDLT(J,K).EQ.0) GOTO 295
      IDL=IDL+1
      GOTO (8886,8887,8888,8889),ID
 8886 J=ICCARS(I,2)/16*16
      IF (J.GT.126) J=J-2
      K=ICCARS(I,3)
      GOTO 8884
 8887 K=ICCARS(I,3)/16*16
      IF(K.GT.126) K=K-2
      J=ICCARS(I,2)
      GOTO 8884
C Page 10      
 8888 J=ICCARS(I,2)/16*16
      IF (J.GT.126) J=J-4
      K=ICCARS(I,3)
      GOTO 8884
 8889 K=ICCARS(I,3)/16*16
      IF (K.GT.126) K=K-4
      J=ICCARS(I,2)
 8884 IDC(IDL,1)=J
      IDC(IDL,2)=K
      IDC(IDL,3)=32
      IF (IDL.EQ.1) GOTO 295
      IF ((IDC(IDL,1).EQ.IDC(IDL-1,1)).AND.(IDC(IDL,2).EQ.IDC(
     +IDL-1,2))) IDL=IDL-1
 295  IF (IDL.EQ.0) GOTO 300
      CALL CHAR$(22)
      L=1
 296  CALL CURSR$(IDC(L,1),IDC(L,2))
      CALL DOT$
      IF (IDC(L,3).GT.1) GOTO 297
      IDL=IDL-1
      IF (IDL.EQ.0) GOTO 300
      DO 298 KA=L,IDL
      IDC(KA,1)=IDC(KA+1,1)
      IDC(KA,2)=IDC(KA+1,2)
      IDC(KA,3)=IDC(KA+1,3)
 298  CONTINUE
      GOTO 296
 297  L=L+1
      IF (L.LE.IDL) GOTO 296
 300  IF (IDL.EQ.0) GOTO 315
      DO 310 J=1,IDL
      IDC(I,3)=IDC(I,3)-1
 310  CONTINUE
C Erase car at old position, then draw at new position
 315  CALL ICDRWN(JD,JCPSX,JCPSY)
      CALL ICDRWY(ID,ICCARS(I,2),ICCARS(I,3))
      IF ((IABS(ICCARS(I,2)-ICPSX).GT.8).OR.(IABS(ICCARS(I,3)
     +-ICPSY).GT.8)) GOTO 400
C Otherwise, there is a collision
      ICRASH=1
      ICRY=ICCARS(I,3)
      ICRX=ICCARS(I,2)
    
 400  RETURN
      END
      SUBROUTINE BEEPER
      RETURN
      END
      SUBROUTINE ICDRWN(ID,IX,IY)
      CALL CHAR$(16)
      CALL DRAW(ID,IX,IY)
      RETURN
      END
      SUBROUTINE DRAW(ID,IX,IY)
      GOTO (410,420,410,420),ID
 410  IY1=IY-2
      IX1=IX-8
      CALL CURSR$(IX1+2,IY1)
      CALL LINE$(IX1+14,IY1)
      CALL CURSR$(IX1,IY1+2)
      CALL LINE$(IX1+16,IY1+2)
      CALL CURSR$(IX1+2,IY1+4)
      CALL LINE$(IX1+14,IY1+4)
      GOTO 430
 420  IX1=IX-2
      IY1=IY-8
      CALL CURSR$(IX1,IY1+2)
      CALL LINE$(IX1,IY1+14)
      CALL CURSR$(IX1+2,IY1)
      CALL LINE$(IX1+2,IY1+16)
      CALL CURSR$(IX1+4,IY1+2)
      CALL LINE$(IX1+4,IY1+14)
 430  RETURN
      END
      SUBROUTINE ICDRWY(ID,IX,IY)
      CALL CHAR$(22)
      CALL DRAW(ID,IX,IY)
      CALL CHAR$(16)
      GOTO (411,421,411,421),ID
 411  IY1=IY-2
      IX1=IX-8
      CALL CURSR$(IX1+8,IY1)
      CALL DOT$
      CALL CURSR$(IX1+8,IY1+4)
      CALL DOT$
      GOTO 431
 421  IX1=IX-2
      IY1=IY-8
      CALL CURSR$(IX1,IY1+8)
      CALL DOT$
      CALL CURSR$(IX1+4,IY1+8)
      CALL DOT$
 431  RETURN
      END
