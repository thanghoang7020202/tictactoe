	.data
board: 	.space	100	# (5*5)*4
strO:	.asciiz "Now is O turn!\n"
strX:	.asciiz "Now is X turn!\n"
request:.asciiz "1: place marker in position.\n2: undo last move\nselect: "
XPos:	.asciiz "Enter x axis position (1 to 5): "
YPos:	.asciiz "Enter y axis position (1 to 5): "
invalid:.asciiz "invalid position!\n"
warning:.asciiz "During the first turn, you are not allowed to choose the central point (3,3)\n"
NLM:	.asciiz "No last move!\n"
Owin:	.asciiz "O has won!\n"
Xwin:	.asciiz "X has won!\n"
Draw:	.asciiz "Draw!\n"
Dash:	.asciiz " _"
X:	.asciiz " X"
O:	.asciiz " O"
newline:.asciiz "\n"
askend: .asciiz "This is the end of the game, wanna try again? ([1]: continue, else: end )"
	.text
main:
	li $s1, 1		# fill = 1
	li $s2, -1		# prevPos = -1
	li $s7, 0		# for indicate turn (first turn s7 = 0, other turn: s7 = n-1, last turn s7 = 24)
	la $s3, board	# board array[[],[],[],[],[]]
	jal resetBoard	# resetBoard();
loop:
	jal printBoard
	#con_MainLoop:
	beq $s1, 0, promptA
	j promptB
promptA:
	li $v0, 4
	la $a0, strO
	syscall
	j askLoop
promptB:
	li $v0, 4
	la $a0, strX
	syscall
askLoop:
	beq $s7, 25, endGame 
	li $v0, 4
	la $a0, request
	syscall
	li $v0, 5
	syscall
	add $t0, $v0, $zero
	beq $t0, 1, placeMarker
	beq $t0, 2, undoLastMove
	j askLoop
placeMarker:
	li $v0, 4		# printStr("enter x position (0 to 4): ");
	la $a0, XPos
	syscall
	li $v0, 5		#input x pos to t0
	syscall 
	add $t0, $v0, $zero
	sgt $t1, $t0, 5
	beq $t1, 1, invalidPos
	sle $t1, $t0, $zero
	beq $t1, 1, invalidPos
	
	li $v0, 4		# printStr("enter y pos (0 to 4): ");
	la $a0, YPos
	syscall
	li $v0, 5		#input y pos to t1
	syscall 
	add $t1, $v0, $zero
	sgt $t2, $t1, 5
	beq $t2, 1, invalidPos
	sle $t2, $t0, $zero
	beq $t2, 1, invalidPos
	addi $s6, $zero, 2 
	slt $s6, $s7, $s6
	beq $s6, 1, midCheck	#check if the first turn is middle (3,3) or not
	notMid:
	addi $s7, $s7, 1	#turn index
	addi $t0, $t0, -1	#set them back to machine cordinates (0 to 4)
	addi $t1, $t1, -1
	mul $t0,$t0, 4		# t2 = t1*4 * boardSize + t0*4
	mul $t1,$t1, 4
	mul $t1,$t1, 5
	add $t2, $t1, $t0
	add $s2, $zero, $t2	# save t2 to prevPos
	add $t3, $s3, $t2	# address of index
	lw $t4, ($t3)		# t4 = board[t2]
	bne $t4, -1, invalidPos
	sw $s1, ($t3)
	nor $s1, $s1, $s1
	andi $s1, $s1, 1	#switch (fill = fill * -1)
	jal winCheck
	beq $v0, 1, winB
	beq $v0, 0, winA
	j loop  
invalidPos:
	li $v0, 4
	la $a0, invalid
	syscall
	j askLoop
firstTurn:
	li $v0, 4
	la $a0, warning
	syscall
	j askLoop
undoLastMove:
	beq $s2, -1, noLastMove
	con_undo:
	add $t1, $s3, $s2
	li $t2, -1
	sw $t2, ($t1)		# set broad[prePos] = -1
	li $s2, -1
	nor $s1, $s1, $s1	# switch back (fill = fill *-1)
	andi $s1, $s1, 1	
	j loop
noLastMove:
	li $v0, 4
	la $a0, NLM
	syscall
	j askLoop
winA:
	jal printBoard
	li $v0, 4
	la $a0, Owin
	syscall
	li $v0, 4
	la $a0, askend
	syscall
	li $v0, 5
	syscall
	beq $v0, 1, main
	li $v0, 10
	syscall
	li $v0, 10
	syscall 
winB:
	jal printBoard
	li $v0, 4
	la $a0, Xwin
	syscall
	#-------------------- chang here
	li $v0, 4
	la $a0, askend
	syscall
	li $v0, 5
	syscall
	beq $v0, 1, main
	li $v0, 10
	syscall
midCheck:
	bne $t0, 3, notMid 
	bne $t1, 3, notMid
	li $v0, 4
	la $a0, warning
	syscall
	j askLoop
return:
	jr $ra
resetBoard:
	li $t0,0			#int i =0;
	li $t2, -1
	resetBoardLoop:
		beq $t0, 25, return	#if( t0==25 ) return; 
		mul $t1, $t0, 4		#board[t0] = -1;
		add $t1, $t1, $s3
		sw $t2, ($t1)
		addi $t0, $t0, 1	# i++;
		j resetBoardLoop
printDash:
	li $v0, 4
	la $a0, Dash
	syscall
	j con_printB
printX:
	li $v0, 4
	la $a0,	X
	syscall
	j con_printB
printO:
	li $v0, 4
	la $a0, O
	syscall
	j con_printB
printnl:
	li $v0, 4
	la $a0, newline
	syscall
	j con_printAnext
printBoard:
	li $t0, 0
	li $t1, 0
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	printBoardLoopA:
		sge $t5, $t0, 5			# if (t0>=boardSize) goto printBoardEnd;
		beq $t5, 1,  printBoardEnd	
		li $t1, 0
	printBoardLoopB:
		sge $t5, $t1, 5			# if (t1>=boardSize) goto printBoardLoopANext;
		beq $t5, 1,  printBoardLoopANext
		mul $t2, $t0, 5			# t2=t0*boardSize+t1;
		mul $t2, $t2, 4	
		mul $t4, $t1, 4	
		add $t2, $t2, $t4		
		add $t3, $zero, $s3		# t3=board[t2];
		add $t3, $t3, $t2
		lw $t3, ($t3)			
		sw $t0, 4($sp)			# Save temporary registers in stack
		sw $t1, 8($sp)			# for ensure that it does not lost data after jump
		sw $t2, 12($sp)
		sw $t3, 16($sp)
		beq $t3, -1, printDash
		beq $t3, 0, printO
		j printX
		con_printB:
		lw $t0, 4($sp)			# load them back
		lw $t1, 8($sp)
		lw $t2, 12($sp)
		lw $t3, 16($sp)
		addi $t1, $t1, 1
		j printBoardLoopB
	printBoardLoopANext:
		j printnl
		con_printAnext:
		addi $t0, $t0, 1
		j printBoardLoopA
	printBoardEnd:
		lw $ra, 0($sp)
		addi $sp, $sp, 20
		jr $ra
winCheck:
	# unfinished
	li $t0, 0
	li $t1, -1
	checkLoopOuterV:
		addi $t1, $t1, 1
		mul $t0, $t1, 5
		li $t2, 0
		sge $t3, $t1, 3
		beq $t3, 1, PreLoopH
	checkloopInnerV:
		sge $t3, $t2, 5
		beq $t3, 1, checkLoopOuterV
		mul $t4, $t2, 4
		mul $t5, $t0, 4
		add $t4, $t4, $t5
		add $t5, $t4, $s3	# t5 = board[t0 +t2]
		add $t6, $t5, 20	# t6 = board[t0 +t2 + 5]
		add $t7 ,$t5, 40	# t7 = board[t0 +t2 + 5*2]
		lw $t5, ($t5)
		lw $t6, ($t6)
		lw $t7, ($t7)
		bne $t5, $t6, Vout
		bne $t5, $t7, Vout
		beq $t5, -1, Vout
		add $v0, $zero, $t5
		jr $ra 
		Vout:
		addi $t2, $t2, 1
		j checkloopInnerV
	PreLoopH:
	li $t0, 0
	li $t1, -1
	checkLoopOuterH:
		addi $t1, $t1, 1
		mul $t0, $t1, 5
		li $t2, 0
		sge $t3, $t1, 5
		beq $t3, 1, PreLoopD
	checkloopInnerH:
		sge $t3, $t2, 3
		beq $t3, 1, checkLoopOuterH
		mul $t4, $t2, 4
		mul $t5, $t0, 4
		add $t4, $t4, $t5
		add $t5, $t4, $s3	# t5 = board[t0 +t2]
		add $t6, $t5, 4		# t6 = board[t0 +t2 + 1]
		add $t7 ,$t5, 8		# t7 = board[t0 +t2 + 2]
		lw $t5, ($t5)
		lw $t6, ($t6)
		lw $t7, ($t7)
		bne $t5, $t6, Hout
		bne $t5, $t7, Hout
		beq $t5, -1, Hout
		add $v0, $zero, $t5
		jr $ra 
		Hout:
		addi $t2, $t2, 1
		j checkloopInnerH
	PreLoopD:
	li $t0, 0
	li $t1, -1
	checkLoopOuterD:
		addi $t1, $t1, 1
		mul $t0, $t1, 5
		li $t2, 0
		sge $t3, $t1, 3
		beq $t3, 1, PreLoopD2
	checkloopInnerD:
		sge $t3, $t2, 3
		beq $t3, 1, checkLoopOuterD
		mul $t4, $t2, 4
		mul $t5, $t0, 4
		add $t4, $t4, $t5
		add $t5, $t4, $s3	# t5 = board[t0 +t2]
		add $t6, $t5, 24	# t6 = board[t0 +t2 + 6]
		add $t7 ,$t5, 48	# t7 = board[t0 +t2 + 12]
		lw $t5, ($t5)
		lw $t6, ($t6)
		lw $t7, ($t7)
		bne $t5, $t6, Dout
		bne $t5, $t7, Dout
		beq $t5, -1, Dout
		add $v0, $zero, $t5
		jr $ra 
		Dout:
		addi $t2, $t2, 1
		j checkloopInnerD
	PreLoopD2:
	li $t0, 0
	li $t1, -1
	checkLoopOuterD2:
		addi $t1, $t1, 1
		mul $t0, $t1, 5
		li $t2, 4
		sge $t3, $t1, 3
		beq $t3, 1, endWinCheck
	checkloopInnerD2:
		sle $t3, $t2, 1
		beq $t3, 1, checkLoopOuterD2
		mul $t4, $t2, 4
		mul $t5, $t0, 4
		add $t4, $t4, $t5
		add $t5, $t4, $s3	# t5 = board[t0 +t2]
		add $t6, $t5, 16	# t6 = board[t0 +t2 + 5]
		add $t7 ,$t5, 32	# t7 = board[t0 +t2 + 5*2]
		lw $t5, ($t5)
		lw $t6, ($t6)
		lw $t7, ($t7)
		bne $t5, $t6, D2out
		bne $t5, $t7, D2out
		beq $t5, -1, D2out
		add $v0, $zero, $t5
		jr $ra 
		D2out:
		addi $t2, $t2, -1
		j checkloopInnerD2
	endWinCheck:	 
	li $v0, -1
	jr $ra
endGame:
	li $v0, 4
	la $a0, Draw
	syscall
	li $v0, 4
	la $a0, askend
	syscall
	li $v0, 5
	syscall
	beq $v0, 1, main
	li $v0, 10
	syscall
	li $v0, 10
	syscall
#-----------------------------------
