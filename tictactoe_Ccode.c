#include <stdio.h>

// syscalls
void printChar(const char ch) {
	printf("%c",ch);
}
void printStr(const char *str) {
	printf("%s", str);
}

void printInt(int i){
	printf("%d", i);
}

int inputInt() {
	int x=0;
	scanf("%d",&x);
	return x;
}

// functions

const int boardSize=5;// replace boardSize with 5 in assembly code!
int board[25];//5*5

void resetBoard() {
	int t0=0;
resetBoardLoop:
	if(t0==25) return;
	board[t0]=-1;
	t0++;
	goto resetBoardLoop;
}

void printBoard() {
	int t0,t1,t2,t3;
	t0=0;
	t1=0;
printBoardLoopA:
	if (t0>=boardSize) goto printBoardEnd;
	t1=0;
printBoardLoopB:
	if (t1>=boardSize) goto printBoardLoopANext;
	t2=t0*boardSize+t1;
	t3=board[t2];
	if (t3==-1) printChar('_');
	else if (t3==0) printChar('O');
	else printChar('X');
	t1++;
	goto printBoardLoopB;
printBoardLoopANext:
	printChar('\n');
	t0++;
	goto printBoardLoopA;
printBoardEnd:;
}

int winCheck() {
	// todo
	int t0 = 0, t1 = -1, t2;
	checkLoopOuterV:
		t1++;
		t0 = t1 * 5;
		t2 = 0;
		if(t1 >= 3) goto preLoopH; 
	checkloopInnerV:
		if(t2 >= 5) goto checkLoopOuterV;
		int x = t0 +t2;
		if(board[t0 +t2] == board[t0 +t2 + boardSize] && board[t0 +t2] != -1){
			if(board[t0 + t2] == board[t0 +t2 + boardSize*2]){
				return board[t0 +t2];
			}
		}
		t2++;
		goto checkloopInnerV;
	preLoopH:
		t0 = 0;
		t1 = -1;
	checkLoopOuterH:
		t1 += 1;
		t0 = t1 *5;
		t2 = 0;
		if(t1 >= 5) goto PreLoopD; 
	checkloopInnerH:
		if(t2 >= 3) goto checkLoopOuterH;
		if(board[t2 + t0] == board[t2 + t0 +1] && board[t2 +t0] != -1){
			if(board[t2 +t0] == board[t2 +t0 +2]){
				return board[t2 +t0];
			}
		}
		t2++;
		goto checkloopInnerH;
	PreLoopD:
		t0 = 0;
		t1 = -1;
	checkLoopOuterD:
		t1 += 1;
		t0 = t1 *5;
		t2 = 0;
		if(t1 >= 3) goto PreLoopD2; 
	checkloopInnerD:
		if(t2 >= 3) goto checkLoopOuterD;
		if(board[t2 + t0] == board[t2 + t0 + 6] && board[t2 +t0] != -1){
			if(board[t2 +t0] == board[t2 +t0 +12]){
				return board[t2 +t0];
			}
		}
		t2++;
		goto checkloopInnerD;
	PreLoopD2:
		t0 = 0;
		t1 = -1;
	checkLoopOuterD2:
		t1 += 1;
		t0 = t1 *5;
		t2 = 4;
		if(t1 >= 3) goto endWinCheck; // fixed
	checkloopInnerD2:
		if(t2 <= 1) goto checkLoopOuterD2;
		if(board[t2 + t0] == board[t2 + t0 + 4] && board[t2 +t0] != -1){
			if(board[t2 +t0] == board[t2 +t0 +8]){
				return board[t2 +t0];
			}
		}
		t2--;
		goto checkloopInnerD2;
	endWinCheck:
		return -1;
}

int main() {
	int fill = 1;
	int prevPos=-1;
	int t0, t1, t2, s7 = 0, v0; // temporary variables
	resetBoard();
loop:
	printBoard();
	if (fill==0) goto promptA;
	goto promptB;
promptA:
	printStr("now is O turn!\n");
	goto askLoop;
promptB:
	printStr("now is X turn!\n");
askLoop:
	if(s7 == 25) goto endGame;
	printStr("1: place marker in position.\n2: undo last move\nselect: ");
	t0=inputInt();
	if (t0==1) goto placeMarker;
	if (t0==2) goto undoLastMove;
	goto askLoop;
placeMarker:
	printStr("enter x position (1 to 5): ");
	t0=inputInt();
	if (t0>boardSize) goto invalidPos;
	if (t0 < 1) goto invalidPos;
	printStr("enter y position (1 to 5): ");
	t1=inputInt();
	if (t1>boardSize) goto invalidPos;
	if (t1 < 1) goto invalidPos;
	if(s7 < 2)goto midCheck;
	notMid:
	t0 -=1;
	t1 -=1;
	t2=t1*boardSize+t0;
	prevPos=t2; // save last pos in memory
	if (board[t2]!=-1) goto invalidPos;
	board[t2]=fill;
	// set next fill
	fill = 1 - fill;
	// check winner
	v0=winCheck();
	if(v0==0) goto winA;
	else if (v0==1) goto winB;
	goto loop;
invalidPos:
	printStr("invalid position!\n");
	goto askLoop;
undoLastMove:
	if (prevPos == -1) goto noLastMove;
	board[prevPos]=-1;
	prevPos=-1;
	// set next fill
	fill = 1 - fill;
	goto loop;
noLastMove:
	printStr("no last move!\n");
	goto loop;
midCheck:
	if (t0 != 3 || t1 != 3) goto notMid;
	printf("During the first turn, you are not allowed to choose the central point (3,3)\n");
	goto askLoop;
winA:
	printBoard();
	printStr("O has won!\n");
	return 0; // exit syscall
winB:
	printBoard();
	printStr("X has won!\n");
	return 0; // exit syscall
endGame:
	printf("Draw");
	return 0;
}

