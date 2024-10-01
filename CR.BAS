1 REM *** Chain Reaction ***
2 REM From COMPUTE! magazine, January 1987
3 REM Converted to Agon Light BBCBASIC24 by James Higgs 2024
4 REM (from the Atari ST Basic version)
5 REM
6 REM BBCBASIC reference: https://github.com/breakintoprogram/agon-docs/wiki
10 MODE 9                      : REM 320 x 240 X 16
15 VDU 23, 0, &C0, 0           : REM Turn off (ill)logical coords
16 VDU 23, 1, 0                : REM disable cursor
19 REM u() = bomb count per cell, j() = max bomb count per cell
20 DIM u(4,5), l(4,5), j(4,5), rt(30), tr(30), tx(30), ty(30)
25 DIM fs(2), hx(2), hy(2)
26 LET GRIDLEFT% = 59 : LET GRIDTOP% = 32
27 ax = 0 : ay = 0 : fg = 0 : pu = 0
28 np = 1 : tu = 0
30 FOR i=0 TO 1 : fs(i)=0 : hx(i)=0 : hy(i)=0 : NEXT i
40 FOR i=0 TO 4 : FOR j=0 TO 5 : u(i,j)=0 : l(i,j)=0 : j(i,j)=4 : NEXT j
50 j(i,0)=3 : j(i,5)=3 : NEXT i
60 RESTORE 70 : FOR j=1 TO 4 : j(0,j)=3 : j(4,j)=3 : READ a,b : j(a,b)=2 : NEXT j
70 DATA 0,0,0,5,4,0,4,5
99 REM *** Set up audio channel 2 to play explosion sound
100 VDU 23,0,&85,2,6,1,5;300;0,0;   : REM Channel 2 envelope
105 VDU 23,0,&85,2,4,4              : REM Channel 2 waveform = noise
120 a = RND(-TIME)              : REM was RANDOMIZE 0
130 PROC_titleScreen            : REM Show title screen and set up options np and tu
210 CLS : COLOUR 15 : PRINT TAB(12,1) "CHAIN REACTION"
215 PROC_drawGrid               : REM Draw grid
219 REM *********************** MAIN GAME LOOP *****************************
220 tu=-tu+1 : co=tu*4+5
230 IF np=1 AND tu=0 THEN GOSUB 970 : GOTO 260
240 GOSUB 400                   : REM Get player move
250 IF l(y,x)<>tu+1 AND l(y,x)<>0 THEN 240
260 pu=u(y,x) : u(y,x)=pu+1 : fs(tu)=fs(tu)+1 : IF l(y,x)=0 THEN l(y,x)=tu+1
270 GOSUB 770                   : REM Redraw grid cell at x,y
280 IF u(y,x)=j(y,x) THEN 300
290 GOTO 220
300 e=0 : fg = 0 : FOR p=0 TO 4 : FOR q=0 TO 5 : y=p : x=q
310 IF u(y,x)>=j(y,x) AND e=0 THEN fg=1 : GOSUB 490
320 NEXT q,p : IF e=1 THEN 350
330 IF fg=1 THEN 300
340 GOTO 220
349 REM ***********************    GAME OVER   *****************************
350 COLOUR 9
351 PRINT TAB(13,8) "           ";
352 PRINT TAB(13,9) " GAME OVER ";
353 PRINT TAB(13,10) "           ";
360 FOR i=1 TO 3 : PRINT CHR$(7); : FOR j=1 TO 500 : NEXT j : NEXT i
365 PRINT TAB(12,12); : IF fs(0) < 1 THEN PRINT "Player 1 Wins!" ELSE PRINT "Computer Wins!"
370 COLOUR 7 : PRINT TAB(4, 23) "Press space bar to play again.";
380 PROC_pressSpace     : REM wait for space press  : REM WAS k$=INKEY$(10) : IF k$ <> " " THEN 380
390 CLS : CLEAR : GOTO 20
400 x=hx(tu) : y=hy(tu) : PROC_drawCursor : PRINT CHR$(7);
409 REM ************* Get player cursor movement and space bar *************
410 dx=0 : dy=0 : A$=INKEY$(10) : IF A$ = "" THEN 410
415 k=ASC(A$) : REM was k=INP(2)
420 IF k = 32 THEN hx(tu)=x : hy(tu)=y : co=0 : PROC_drawCursor : co=tu*4+5 : RETURN
430 IF k = 11 THEN IF y>0 THEN dy=-1
440 IF k = 10 THEN IF y<4 THEN dy=1
450 IF k = 8 THEN IF x>0 THEN dx=-1
460 IF k = 21 THEN IF x<5 THEN dx=1
470 IF dx=0 AND dy=0 THEN 410
480 co=0 : PROC_drawCursor : x=x+dx : y=y+dy : co=tu*4+5 : PROC_drawCursor : GOTO 410
490 PROC_playExplode : tx=x : ty=y : co=4 : PROC_drawCursor
500 IF tx>0 THEN x=tx-1 : GOSUB 570
510 IF tx<5 THEN x=tx+1 : GOSUB 570
520 x=tx : IF ty>0 THEN y=ty-1 : GOSUB 570
530 IF ty<4 THEN y=ty+1 : GOSUB 570
540 IF fs(0)<1 OR fs(1)<1 THEN e=1
550 y=ty : pu=u(y,x) : u(y,x)=pu-j(y,x) : GOSUB 770 : IF u(y,x)=0 THEN l(y,x)=0
560 co=0 : x=tx : y=ty : PROC_drawCursor : RETURN
570 IF l(y,x)<>tu+1 THEN fs(tu)=fs(tu)+u(y,x) : fs(-tu+1)=fs(-tu+1)-u(y,x)
580 l(y,x)=tu+1 : pu=u(y,x) : u(y,x)=pu+1 : GOSUB 770 : RETURN
589 REM *** Subroutine (unknown) called from "think" routine
590 lp=0 : IF y>0 THEN IF l(y-1,x)=2 THEN ay=y-1 : GOTO 640
600 IF x>0 THEN IF l(y,x-1)=2 THEN ax=x-1 : GOTO 640
610 IF x<5 THEN IF l(y,x+1)=2 THEN ax=x+1 : GOTO 640
620 IF y<4 THEN IF l(y+1,x)=2 THEN ay=y+1 : GOTO 640
630 RETURN
640 lp=1 : RETURN
648 REM *** Draw grid ***
649 REM wAS color 1,1,2 BELOW
650 DEF PROC_drawGrid
655    GCOL 0,3 : FOR y=0 TO 4 : yy=28*y+GRIDTOP% : FOR x=0 TO 5 : xx=32*x+GRIDLEFT%
660    MOVE xx,yy : DRAW xx+30,yy
665    MOVE xx+30,yy : DRAW xx+30,yy+26
670    MOVE xx+30,yy+26 : DRAW xx,yy+26
675    MOVE xx,yy+26 : DRAW xx,yy
680    NEXT x,y
685 ENDPROC
688 REM *** Draw bomb
689 REM WAS COLOUR 1,0,tu*4+4+i below
690 DEF PROC_drawBomb(X%, Y%)
691    IF tu = 0 THEN GCOL 0,1 ELSE GCOL 0,4
692    MOVE X%, Y% : PLOT 153, 5, 0   : REM PLOT 153 = fill circle
693    IF tu = 0 THEN GCOL 0,9 ELSE GCOL 0,12
694    MOVE X% - 1, Y% - 1 : PLOT 153, 4, 0
695    GCOL 0, 15 : MOVE X% - 2, Y% - 2 : PLOT 153, 1, 0
696    GCOL 0, 3 : MOVE X%, Y% - 5 : DRAW X% + 1, Y% - 8
697 ENDPROC
709 REM *** Draw cursor (uses globals x and y)***
710 DEF PROC_drawCursor
715    yy=28*y+GRIDTOP%-1 : xx=32*x+GRIDLEFT%-1 : GCOL 0,co : REM was COLOUR 1,co,co
720    MOVE xx,yy : DRAW xx+32,yy
725    MOVE xx+32,yy : DRAW xx+32,yy+28
730    MOVE xx+32,yy+28 : DRAW xx,yy+28
735    MOVE xx,yy+28 : DRAW xx,yy
740    MOVE xx+2,yy+2 : DRAW xx+30,yy+2
745    MOVE xx+30,yy+2 : DRAW xx+30,yy+26
750    MOVE xx+30,yy+26 : DRAW xx+2,yy+26
755    MOVE xx+2,yy+26 : DRAW xx+2,yy+2
760 ENDPROC
769 REM *** Redraw a grid cell with bombs
770 yy=28*y+GRIDTOP% : xx=32*x+GRIDLEFT%
779 REM Clear cell
780 MOVE xx + 1, yy + 1 : PLOT 99, 28, 24        : REM 99 = FILL RECT, BG COLOUR
789 REM Draw Bombs in cell
790 k=u(y,x)+1 : IF k=6 THEN k=5
800 ON k GOSUB 810,820,830,850,870,870
805 REM A$ = INKEY$(20)  : REM a little AIT to slow things down
810 RETURN
820 PROC_drawBomb(xx+15, yy+13) : RETURN
830 PROC_drawBomb(xx+9, yy+13)
840 PROC_drawBomb(xx+21, yy+13) : RETURN 
850 PROC_drawBomb(xx+15, yy+9)
860 PROC_drawBomb(xx+9, yy+17)
865 PROC_drawBomb(xx+21, yy+17) : RETURN
870 PROC_drawBomb(xx+9, yy+13)
875 PROC_drawBomb(xx+21, yy+13)
880 PROC_drawBomb(xx+15, yy+7)
885 PROC_drawBomb(xx+15, yy+19) : RETURN
890 RETURN
899 REM *** PLay explosion sound
900 DEF PROC_playExplode
910    SOUND 2, -15, 20, 12                     : REM last 2 params don't matter
920 ENDPROC
969 REM ****************** COMPUTER TURN / CALCULATION ********************
970 xt=0 : FOR y=0 TO 4 : FOR x=0 TO 5 : IF l(y,x)=2 THEN 990
980 xt=xt+1 : ty(xt)=y : tx(xt)=x
990 NEXT x,y
1000 PRINT TAB(15, 23) "Thinking...";
1001 REM CLS : TRACE ON 
1010 FOR i=1 TO xt : rt(i)=0 : tr(i)=0 : y=ty(i) : x=tx(i) : GOSUB 590
1020 REM was IF fg=1 AND lp<>0 AND u(y,x)>0 THEN 1230
1021 IF fg=1 AND lp<>0 AND u(y,x)>0 THEN i = xt + 1 : GOTO 1180
1030 IF u(y,x)+1 <> j(y,x) THEN 1070
1040 IF lp=1 AND u(ay,ax)+1 = j(ay,ax) THEN rt(i)=6 : GOTO 1180
1050 IF lp=1 THEN rt(i)=2 : GOTO 1180
1060 IF lp=0 THEN rt(i)=1 : GOTO 1180
1070 IF j(y,x) <> 2 THEN 1110
1080 IF lp=0 AND u(y,x)=1 THEN rt(i)=1 : GOTO 1180
1090 IF lp=0 AND u(y,x)=0 THEN rt(i)=4 : GOTO 1180
1100 IF lp=1 AND u(y,x)=1 THEN rt(i)=4 : GOTO 1180
1110 IF u(ay,ax)+1 = j(ay,ax) THEN rt(i)=1 : GOTO 1180
1120 IF u(y,x)+2 < j(y,x) THEN 1160
1130 IF lp=1 AND u(ay,ax)+1<j(ay,ax) THEN rt(i)=5 : GOTO 1180
1140 IF lp=0 THEN rt(i)=3 : GOTO 1180
1150 rt(i)=2 : GOTO 1180
1160 IF lp=0 THEN rt(i)=2 : GOTO 1180
1170 rt(i)=1
1180 NEXT i
1182 IF fg=1 AND lp<>0 AND u(y,x)>0 THEN 1230
1185 zt=0 : ab=6
1190 FOR i=1 TO xt : IF rt(i)=ab THEN zt=zt+1 : tr(zt)=i
1200 NEXT i : IF zt > 0 THEN 1220
1210 ab=ab-1 : GOTO 1190
1219 REM Note BBCBASIC RND(1) returns from 0 to 0.9999999
1220 dh=INT(zt*RND(1))+1 : hd=tr(dh) : y=ty(hd) : x=tx(hd)
1230 PRINT TAB(15, 23)"           "; : fg=fg+1
1240 RETURN
1999 REM *** Show instructions
2000 DEF PROC_instructions
2010    CLS : COLOUR 11 : PRINT "INSTRUCTIONS:"
2020    COLOUR 3 : PRINT
2030    PRINT "Eliminate all of your opponent's "
2040    PRINT "bombs from the play grid. "
2050    PRINT
2060    PRINT "Taking turns, each player places a "
2070    PRINT "bomb in any empty square in the grid, "
2080    PRINT "or any square that already contains "
2090    PRINT "that player's bombs."
2100    PRINT
2110    PRINT "Whenever any square reaches 'critical "
2120    PRINT "mass', it explodes and sends its bombs "
2130    PRINT "into neighboring squares. This can "
2140    PRINT "create a 'chain reaction' that can "
2150    PRINT "spread across the board."
2160    PRINT
2170    PRINT "The game ends when a chain reaction "
2180    PRINT "removes all the other player's bombs"
2190    PRINT "from the grid."
2200    PRINT
2210    PRINT "Press space to continue.";
2220    PROC_pressSpace     : REM wait for space press
2230 ENDPROC
2999 REM *** Wait for space key
3000 DEF PROC_pressSpace
3010    LOCAL K$
3020    K$=INKEY$(10) : IF K$ <> " " THEN 3020
3030 ENDPROC
3999 REM *** Title / options screen  (sets up 'np' and 'tu' vars)
4000 DEF PROC_titleScreen
4005    LOCAL A$
4010    CLS : COLOUR 15 : PRINT TAB(12, 3) "CHAIN REACTION";
4020    COLOUR 11 : PRINT TAB(3, 7) "Players:         ";np;"   (press 1 or 2)"
4025    IF np = 2 THEN GOTO 4050
4030    PRINT TAB(3, 10) "Computer first:  ";
4040    IF tu = 0 THEN PRINT "No "; ELSE PRINT "Yes";
4045    PRINT " (press Y or N)"
4050    PRINT TAB(3, 13) "Press 'I' for instructions"
4055    PRINT TAB(7, 18) "Press space to start game";
4060    COLOUR 3 : PRINT TAB(1, 24) "Agon Light BBCBASIC version by Jum Hig";
4061    PRINT TAB(1, 25) "From original COMPUTE! magazine version";
4069    REM Get keyboard input
4070    A$ = INKEY$(10) : IF A$ = "" THEN 4070
4080    IF A$ = "1" THEN np = 1
4090    IF A$ = "2" THEN np = 2
4100    IF A$ = "Y" OR A$ = "y" THEN tu = 1
4110    IF A$ = "N" OR A$ = "n" THEN tu = 0
4120    IF A$ = "I" OR A$ = "i" THEN PROC_instructions 
4130    IF A$ <> " " THEN GOTO 4010
4140 ENDPROC
