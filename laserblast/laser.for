C Copyright (c) 1979 Jeff Kesner
      PROGRAM LASERB
      BYTE B(20,20),SCORE(5,2),A(11)
      INTEGER TIME
      DIMENSION IPB(2,3)
      COMMON /ID/ IP(2,3)
      COMMON /JBS/ IGARB(802),IARRAY(200)
      COMMON /JSC/ IGAR(5)
      EQUIVALENCE (SCORE(1,1),IGAR(1))
      EQUIVALENCE (B(1,1),IARRAY(1))
      DATA A /84,83,65,76,66,32,82,69,83,65,76/
  420 IGARB(801)=0
      IPLAYS=0
      DO 90 I=1,2
      DO 100 J=1,5
      SCORE(J,I)=48
  100 CONTINUE
   90 CONTINUE
  421 TIME=1050-150*IPLAYS
      IPLAYS=IPLAYS+1
      IGARB(802)=0
      CALL INITG$
      CALL INTSET
      CALL PAGE$
      CALL CHAR$(2)
      CALL CHAR$(14)
      IPB(1,1)=0
      IPB(2,1)=0
      DO 10 I=1,20
      DO 20 J=1,20
      B(I,J)=1
   20 CONTINUE
   10 CONTINUE
      DO 30 I=4,7
      DO 40 J=18,20
      B(J,I)=0
      I1=21-I
      J1=21-J
      B(J1,I1)=0
   40 CONTINUE
   30 CONTINUE
      DO 50 I=16,20
      B(I,8)=0
      I1=21-I
      B(I1,I3)=0
   50 CONTINUE
      DO 60 I=5,16
      B(I,10)=0
      I1=21-I
      B(I1,11)=0
   60 CONTINUE
      B(16,9)=0
      B(17,9)=0
      B(5,12)=0
      B(4,12)=0
C Randomly populate the board with Circles, Squares and spaces
      DO 70 I=1,20
      DO 80 J=1,20
      CALL IR
      K=PEEK(256)
      IF (K.LT.0) K=K+256
      IF (K.GT.204) B(I,J)=0
      IF (B(I,J).NE.0) B(I,J)=2
C Page 2
      IF ((K.LT.60).AND.(B(I,J).EQ.2)) B(I,J)=3
      L=B(I,J)
      CALL JJP(L,I,J)
   80 CONTINUE
   70 CONTINUE
      CALL CHAR$(19)
      CALL XPLOD(1)
      CALL CURSR$(0,240)
      CALL STRIN$(5,SCORE)
      CALL XPLOD(2)
      CALL CURSR$(180,240)
      CALL STRIN$(5,SCORE(1,2))
C Display "LASER BLAST"
      DO 110 I=1,11
      CALL CURSR$(240,48+I*12)
      CALL CHAR$(A(I))
  110 CONTINUE
      CALL CURSR$(240,240)
      CALL CHAR$(48)
      CALL CURSR$(60,240)
      CALL CHAR$(48)
      IP(1,1)=1
      IP(1,2)=15
      IP(2,1)=20
      IP(2,2)=6
      IP(1,3)=6
      IP(2,3)=4
  120 IF (IPB(1,1).EQ.0) GOTO 130
      IO=IPB(1,2)
      JO=IPB(1,3)
      IF (IPB(1,1).EQ.4) IPB(1,2)=IPB(1,2)+1
      IF (IPB(1,1).EQ.5) IPB(1,3)=IPB(1,3)+1
      IF (IPB(1,1).EQ.6) IPB(1,2)=IPB(1,2)-1
      IF (IPB(1,1).EQ.7) IPB(1,3)=IPB(1,3)-1
      IF ((IPB(1,2).GT.0).AND.(IPB(1,2).LT.21).AND.(IPB(1,3).GT
     +.0).AND.(IPB(1,3).LT.21)) GOTO 140
      IPB(1,1)=0
      GOTO 160
  270 IF ((IPB(1,2).EQ.IP(2,1)).AND.(IPB(1,3).EQ.IP(2,2))) GOTO
     + 290
      GOTO 160
  290 CALL JJP(1,IP(1,1),IP(1,2))
      CALL JJP(1,IP(2,1),IP(2,2))
      WRITE(3,291),IP(1,1),IP(1,2),IP(2,1),IP(2,2)
  291 FORMAT(1X, 'Player 1 X Y, Player 2 X Y', I7,I7,I7,I7)
      IF (IPB(1,1).EQ.0) GOTO 300
      CALL JJP(1,IPB(1,2),IPB(1,3))
      IPB(1,1)=0
  300 IF (IPB(2,1).EQ.0) GOTO 310
      CALL JJP(1,IPB(2,2),IPB(2,3))
  310 IPB(2,1)=0
      IP(1,1)=1
      IP(1,2)=15
      IP(1,3)=6
      IP(2,1)=20
      IP(2,2)=6
      IP(2,3)=4
      CALL XPLOD(1)
      CALL SCORER(1,5)
      GOTO 160
  140 K1=8
      IF ((IPB(1,1).EQ.5).OR.(IPB(1,1).EQ.7)) K1=9
      CALL JJP(K1,IPB(1,2),IPB(1,3))
      IPB2=IPB(1,2)
      IPB3=IPB(1,3)
      IF (B(IPB2,IPB3).EQ.0) GOTO 270
      CALL SCORER (1,B(IPB2,IPB3))
      CALL XPLOD(1)
      IPB(1,1)=0
C Page 3
      IF (B(IPB2,IPB3).EQ.3) CALL JBSET(1,IPB2,IPB3)
      B(IPB2,IPB3)=0
      CALL JJP(1,IPB(1,2),IPB(1,3))
  160 CALL JJP(1,IO,JO)
  130 IF (IPB(2,1).EQ.0) GOTO 170
      IO=IPB(2,2)
      JO=IPB(2,3)
      IF (IPB(2,1).EQ.4) IPB(2,2)=IPB(2,2)+1
      IF (IPB(2,1).EQ.5) IPB(2,3)=IPB(2,3)+1
      IF (IPB(2,1).EQ.6) IPB(2,2)=IPB(2,2)-1
      IF (IPB(2,1).EQ.7) IPB(2,3)=IPB(2,3)-1
      IF ((IPB(2,2).GT.0).AND.(IPB(2,2).LT.21).AND.(IPB(2,3).GT
     +.0).AND.(IPB(2,3).LT.21)) GOTO 180
      IPB(2,1)=0
      GOTO 190
  260 IF ((IPB(2,2).EQ.IP(1,1)).AND.(IPB(2,3).EQ.IP(1,2))) GOTO
     +280
      GOTO 190
  280 CALL JJP(1,IP(1,1),IP(1,2))
      CALL JJP(1,IPB(1,2),IPB(1,3))
      IF (IPB(1,1).EQ.0) GOTO 320
      CALL JJP(1,IPB(1,2),IPB(1,3))
      IPB(1,1)=0
  320 IF (IPB(2,1).EQ.0) GOTO 330
      CALL JJP(1,IPB(2,2),IPB(2,3))
  330 IPB(2,1)=0
      IP(1,1)=1
      IP(1,2)=15
      IP(1,3)=6
      IP(2,1)=20
      IP(2,2)=6
      IP(2,3)=4
      CALL SCORER(2,5)
      CALL XPLOD(2)
      GOTO 190
  180 K1=8
      IF ((IPB(2,1).EQ.5).OR.(IPB(2,1).EQ.7)) K1=9
      CALL JJP(K1,IPB(2,2),IPB(2,3))
      IPB2=IPB(2,2)
      IPB3=IPB(2,3)
      IF (B(IPB2,IPB3).EQ.0) GOTO 260
      CALL SCORER(2,B(IPB2,IPB3))
      CALL XPLOD(2)
      IPB(2,1)=0
      IF (B(IPB2,IPB3).EQ.3) CALL JBSET(2,IPB2,IPB3)
      B(IPB2,IPB3)=0
      CALL JJP(1,IPB(2,2),IPB(2,3))
  190 CALL JJP(1,IO,JO)
  170 IF (IPB(1,1).NE.0) GOTO 200
      J=IBKILL(1)
      J=INP(24)
      IF (J/2*2.NE.J) GOTO 200
      CALL FIRE(1)
      IPB(1,1)=IP(1,3)
      IPB(1,2)=IP(1,1)
      IPB(1,3)=IP(1,2)
  200 IF (IPB(2,1).NE.0) GOTO 210
      J=IBKILL(2)
      J=INP(24)/16
      IF (J/2*2.EQ.J) GOTO 210
      CALL FIRE(2)
      IPB(2,1)=IP(2,3)
      IPB(2,2)=IP(2,1)
      IPB(2,3)=IP(2,2)
  210 CALL JJP(1,IP(1,1),IP(1,2))
      CALL JJP(1,IP(2,1),IP(2,2))
C Page 4     
      N=IJ1(1)
      IF (N.EQ.0) GOTO 220
      IP1=IP(1,1)
      IP2=IP(1,2)
      IF (B(IP1,IP2).EQ.0) GOTO 240
      CALL SCORER(2,4)
      CALL SCORER(1,B(IP1,IP2))
      CALL JJP(1,IP(1,1),IP(1,2))
      CALL JJP(1,IP(2,1),IP(2,2))
      IP(1,1)=1
      IP(1,2)=15
      IP(1,3)=6
      IP(2,1)=20
      IP(2,2)=6
      IP(2,3)=4
      CALL XPLOD(2)
      IF (B(IP1,IP2).EQ.3) CALL JBSET(1,IP1,IP2)
      B(IP1,IP2)=0
      GOTO 240
  220 IP(1,3)=IJ(1)
  240 CALL JJP(IP(1,3),IP(1,1),IP(1,2))
      N=IJ1(2)
      IF (N.EQ.0) GOTO 230
      IP1=IP(2,1)
      IP2=IP(2,2)
      IF (B(IP1,IP2).EQ.0) GOTO 250
      CALL SCORER(1,4)
      CALL SCORER(2,B(IP1,IP2))
      CALL JJP(1,IP(1,1),IP(1,2))
      CALL JJP(1,IP(2,1),IP(2,2))
      IP(1,1)=1
      IP(1,2)=15
      IP(1,3)=6
      IP(2,1)=20
      IP(2,2)=6
      IP(2,3)=4
      CALL XPLOD(1)
      IF (B(IP1,IP2).EQ.3) CALL JBSET(2,IP1,IP2)
      B(IP1,IP2)=0
      GOTO 250
  230 IP(2,3)=IJ(2)
  250 CALL JJP(IP(2,3),IP(2,1),IP(2,2))
      IT1=TIME/1000
      IT2=TIME/100-10*IT1
      IT3=TIME/10-100*IT1-10*IT2
      TIME=TIME-1
      IF (TIME.EQ.0) GOTO 350
      IT1A=TIME/1000
      IT2A=TIME/100-10*IT1A
      IT3A=TIME/10-100*IT1A-10*IT2A
      IF (IT1.EQ.IT1A) GOTO 360
      CALL CHAR$(16)
      CALL CURSR$(116,240)
      CALL CHAR$(8)
      CALL CHAR$(19)
      CALL CHAR$(IT1A+48)
  360 IF (IT2.EQ.IT2A) GOTO 370
      CALL CHAR$(16)
      CALL CURSR$(128,240)
      CALL CHAR$(IT2+48)
      CALL CHAR$(8)
      CALL CHAR$(19)
      CALL CHAR$(IT2A+48)
  370 IF (IT3.EQ.IT3A) GOTO 380
      CALL CHAR$(16)
C Page 5      
      CALL CURSR$(140,240)
      CALL CHAR$(IT3+48)
      CALL CHAR$(8)
      CALL CHAR$(19)
      CALL CHAR$(IT3A+48)
  380 GOTO 120
  350 M=0
      DO 400 J=1,20
      DO 410 I=1,20
      IF (B(I,J).EQ.0) GOTO 410
      CALL XPLOD(1)
      CALL XPLOD(2)
      CALL JJP(1,I,J)
      CALL JJP(1,I,J)
      M=M+B(I,J)
  410 CONTINUE
  400 CONTINUE
      IF (M.EQ.0) GOTO 421
  430 IF (INP(24).EQ.0) GOTO 420
      GOTO 430
      END
C     
      SUBROUTINE JJP(I,J,K)
      CALL CHAR$(19)
      J1=(J-1)*12
      K1=(K-1)*12
      I1=I
      IF (I.EQ.0) I1=1
      GOTO (10,20,30,40,50,60,70,80,90),I1
C 1. Blank      
  10  CALL CHAR$(16)
      CALL CURSR$(J1,K1)
      CALL AREA$(J1+10,K1+10)
      RETURN
C 2. Small box
  20  CALL CURSR$(J1+2,K1+2)
      CALL LINE$(J1+6,K1+2)
      CALL LINE$(J1+6,K1+6)
      CALL LINE$(J1+2,K1+6)
      CALL LINE$(J1+2,K1+2)
      RETURN
C 3. Circle      
  30  CALL CURSR$(J1,K1+2)
      CALL LINE$(J1,K1+6)
      CALL CURSR$(J1+2,K1)
      CALL LINE$(J1+6,K1)
      CALL CURSR$(J1+8,K1+2)
      CALL LINE$(J1+8,K1+6)
      CALL CURSR$(J1+2,K1+8)
      CALL LINE$(J1+6,K1+8)
      RETURN
  40  CALL CURSR$(J1+4,K1)
      CALL LINE$(J1+2,K1)
      CALL CURSR$(J1,K1+2)
      CALL LINE$(J1,K1+6)
      CALL CURSR$(J1+2,K1+8)
      CALL LINE$(J1+4,K1+8)
      CALL CURSR$(J1+2,K1+4)
      CALL LINE$(J1+8,K1+4)
      RETURN
  50  CALL CURSR$(J1,K1+4)
      CALL LINE$(J1,K1+2)
      CALL CURSR$(J1+2,K1)
      CALL LINE$(J1+6,K1)
      CALL CURSR$(J1+8,K1+2)
      CALL LINE$(J1+8,K1+4)
      CALL CURSR$(J1+4,K1+2)
      CALL LINE$(J1+4,K1+8)
      RETURN
  60  CALL CURSR$(J1+4,K1)
C Page 6  
      CALL LINE$(J1+6,K1)
      CALL CURSR$(J1+8,K1+2)
      CALL LINE$(J1+8,K1+6)
      CALL CURSR$(J1+6,K1+8)
      CALL LINE$(J1+4,K1+8)
      CALL CURSR$(J1,K1+4)
      CALL LINE$(J1+8,K1+4)
      RETURN
  70  CALL CURSR$(J1+4,K1)
      CALL LINE$(J1+4,K1+6)
      CALL CURSR$(J1,K1+4)
      CALL LINE$(J1,K1+6)
      CALL CURSR$(J1+2,K1+8)
      CALL LINE$(J1+6,K1+8)
      CALL CURSR$(J1+8,K1+6)
      CALL LINE$(J1+8,K1+4)
      RETURN
 80   CALL CURSR$(J1+2,K1)
      CALL LINE$(J1+8,K1)
      CALL CURSR$(J1,K1+4)
      CALL LINE$(J1+10,K1+4)
      CALL CURSR$(J1+2,K1+8)
      CALL LINE$(J1+8,K1+8)
      RETURN
  90  CALL CURSR$(J1,K1+2)
      CALL LINE$(J1,K1+8)
      CALL CURSR$(J1+4,K1)
      CALL LINE$(J1+4,K1+10)
      CALL CURSR$(J1+8,K1+2)
      CALL LINE$(J1+8,K1+8)
      RETURN
      END
      FUNCTION IJ(I)
      COMMON /ID/ IP(2,3)
      J=25
      IF (I.EQ.2) J=27
      K=INP(J)/32
      IF (K.EQ.0) GOTO 10
      L=4
      IF (K.LT.0) L=6
      IJ=L
      RETURN
  10  K=INP(J+1)/32
      L=5
      IF (K.EQ.0) L=IP(I,3)
      IF (K.LT.0) L=7
      IJ=L
      RETURN
      END
C     
      FUNCTION IJ1(I)
      COMMON /ID/ IP(2,3)
C Was 75 in original      
      IFJOY = 120
      J=25
      IF (I.EQ.2) J=27
      L=0
      M=INP(J)/IFJOY+(INP(J+1)/IFJOY)
      IF (M.EQ.0) GOTO 10
      M=IJ(I)
      IF (M.NE.IP(I,3)) GOTO 10
      IF ((M.EQ.4).AND.(IP(I,1).LT.20)) IP(I,1)=IP(I,1)+1
      IF ((M.EQ.5).AND.(IP(I,2).LT.20)) IP(I,2)=IP(I,2)+1
      IF ((M.EQ.6).AND.(IP(I,1).GT.1)) IP(I,1)=IP(I,1)-1
      IF ((M.EQ.7).AND.(IP(I,2).GT.1)) IP(I,2)=IP(I,2)-1
      L=1
  10  IJ1=L
      RETURN
      END
C Page 7
      SUBROUTINE JBSET(I,J,K)
      BYTE ISET(400,4)
      COMMON /JBS/ ISET1(200,4),IC(2),IJ(200)
      EQUIVALENCE (ISET(1,1),ISET1(1,1))
C I=PLAYER J=X K=Y ISET(X,1)=P1X 2=P1Y 3=P2X 4=P2Y
      DO 10 L=1,3
      DO 20 M=1,3
      IX=J+L-2
      IY=K+M-2
      IF ((IX.GT.20).OR.(IX.LT.1).OR.(IY.GT.20).OR.(IY.LT.1))
     + GOTO 20
      IC(I)=IC(I)+1
      IND=(I-1)*2
      IND1=IC(I)
      ISET(IND1,IND+1)=IX
      ISET(IND1,IND+2)=IY
   20 CONTINUE
   10 CONTINUE
      RETURN
      END
C
      FUNCTION IBKILL(I)
      BYTE B(20,20),ISET(400,4)
      COMMON /JBS/ ISET1(200,4),IC(2),IJ(200)
      EQUIVALENCE (B(1,1),IJ(1)),(ISET(1,1),ISET1(1,1))
   30 IF (IC(I).NE.0) GOTO 10
      IBKILL=0
      RETURN
   10 IND=(I-1)*2
      ID1=IC(1)
      ID2=ISET(ID1,IND+2)
      ID1=ISET(ID1,IND+1)
      IF (B(ID1,ID2).NE.0) GOTO 20
      IC(I)=IC(I)-1
      GOTO 30
   20 CALL XPLOD(I)
      JI=B(ID1,ID2)
      CALL SCORER(I,B(ID1,ID2))
      B(ID1,ID2)=0
      CALL JJP(1,ID1,ID2)
      IF (JI.EQ.3) CALL JBSET(I,ID1,ID2)
      IBKILL=1
      RETURN
      END
C
      SUBROUTINE SCORER(I,J)
      BYTE SCORE(5,2),IP(2,5,2)
      COMMON /JSC/ ID(5)
      EQUIVALENCE (SCORE(1,1),ID(1))
      DATA IP /0,180,12,192,24,204,36,216,48,228,240,240,240,
     +240,240,240,240,240,240,240/
      I1=J-1
      GOTO (10,20,30,40),I1
   10 IA=2
      IA1=0
      GOTO 50
   20 IA=5
      IA1=0
      GOTO 50
   30 IA=5
      IA1=2
      GOTO 50
   40 IA=0
      IA1=5
   50 JO=SCORE(5,I)
      JN=JO+IA
      JO1=SCORE(4,I)
      JN1=JO1+IA1
C Page 8      
      IF (JN.LT.58) GOTO 60
      JN=JN-10
      JN1=JN1+1
   60 IF (JN.EQ.JO) GOTO 70
      CALL CHAR$(16)
      CALL CURSR$(IP(I,5,1),IP(I,5,2))
      CALL CHAR$(JO)
      CALL CHAR$(8)
      CALL CHAR$(19)
      CALL CHAR$(JN)
      SCORE (5,I)=JN
   70 IF (JN1.LT.58) GOTO 80
      JN1=JN1-10
      CALL CHAR$(16)
      CALL CURSR$(IP(I,3,1),IP(I,3,2))
      CALL CHAR$(SCORE(3,I))
      SCORE(3,I)=SCORE(3,I)+1
      IF (SCORE(3,I).LT.58) GOTO 90
      SCORE(3,I)=SCORE(3,I)-10
      CALL CURSR$(IP(I,2,1),IP(I,2,2))
      CALL CHAR$(SCORE(2,I))
      SCORE(2,I)=SCORE(2,I)+1
      IF (SCORE(2,I).LT.58) GOTO 100
      SCORE(2,I)=SCORE(2,I)-10
      CALL CURSR$(IP(I,1,1),IP(I,1,2))
      CALL CHAR$(SCORE(1,I))
      CALL CHAR$(19)
      CALL CHAR$(8)
      SCORE(1,I)=SCORE(1,I)+1
      CALL CHAR$(SCORE(1,I))
  100 CALL CHAR$(19)
      CALL CURSR$(IP(I,2,1),IP(I,2,2))
      CALL CHAR$(SCORE(2,I))
   90 CALL CHAR$(19)
      CALL CURSR$(IP(I,3,1),IP(I,3,2))
      CALL CHAR$(SCORE(3,I))
   80 IF (JN1.EQ.JO1) GOTO 85
      CALL CHAR$(16)
      CALL CURSR$(IP(I,4,1),IP(I,4,2))
      CALL CHAR$(SCORE(4,I))
      CALL CHAR$(19)
      SCORE(4,I)=JN1
      CALL CURSR$(IP(I,4,1),IP(I,4,2))
      CALL CHAR$(SCORE(4,I))
   85 RETURN
      END
C
      SUBROUTINE XPLOD(I)
      CALL XPLODE(I)
C      J = PEEK(257)
C      WRITE(3,10),I,J
C   10 FORMAT(1X,'EXPLODE',I7,I7)
      RETURN
      END
