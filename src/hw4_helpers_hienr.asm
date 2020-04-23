# Raymond
# Hienr

.text

# Helper
# short removeKing(int player)
removeKing:
	# Prologue =============================
	# Stack
	#	1) $ra
	#	2) $s0
	#	3) $s1
	#	4) $s2
	#	5) $s3

	addi $sp, $sp, -20
	
	sw $ra, 16($sp)
	sw $s0, 12($sp)
	sw $s1, 8($sp)
	sw $s2, 4($sp)
	sw $s3, 0($sp)
	# ======================================	

	li $s1, 0							# row = 0
	li $s2, 0							# col = 0
	
	move $s3, $a0						# save player
	removeKing_InvestigateBlock:
	# short the coordinates
										# prepare call to getShort(;;)
	move $a0, $s1						# pass row
	move $a1, $s2						# pass col
	jal getShort							# getShort(;;)
	move $s0, $v0						# save short
	
										# prepare call to getChessPiece(;)
	move $a0, $v0						# pass coordinates
	jal getChessPiece					# getChessPiece(;;)
	
	#beq $v1, $s3, removeKing_prepareInvestigation
	#beq $v1, -1, removeKing_prepareInvestigation
	dbbeu:
	bne $v0, 'K', removeKing_prepareInvestigation
	
	removeKing_remove:
										# prepare call to getBoardPosition(;;)
	move $a0, $s1						# pass rows
	move $a1, $s2						# pass cols
	jal getBoardPosition					# getBoardPosition(;;)
			
	li $t0, 'E'
	sb $t0, 0($v0)						# store empty
	
	j removeKing_removed
	
	removeKing_prepareInvestigation:
	beq $s2, 7, removeKing_incrementRow
	
	addi $s2, $s2, 1
	j removeKing_InvestigateBlock
	
	removeKing_incrementRow:
	beq $s1, 7, removeKing_removed
	li $s2, 0
	
	addi $s1, $s1, 1
	
	j removeKing_InvestigateBlock
	
	removeKing_removed:
	move $v0, $s0						# return address of found king
	# Epilogue =============================
	# Stack
	#	1) $ra
	#	2) $s0
	#	3) $s1
	#	4) $s2
	#	5) $s3
	lw $ra, 16($sp)
	lw $s0, 12($sp)
	lw $s1, 8($sp)
	lw $s2, 4($sp)
	lw $s3, 0($sp)
	
	addi $sp, $sp, 20
	# ======================================	
	jr $ra
	

	
# bool isValidL(short a short b)
# Arguments: a from and to position
# Returns: 1/0 if the 2 points form a valid L on the chess board
isValidL:
	# Prologue =============================
	# Stack
	#	1) $ra
	#	2) $s0
	#	3) $s1
	#	4) $s2

	addi $sp, $sp, -16
	
	sw $ra, 12($sp)
	sw $s0, 8($sp)
	sw $s1, 4($sp)
	sw $s2, 0($sp)
	# ======================================
	
	move $s0, $a1						# save b
										# prepare call to getLocation
	# a0 already has a
	jal getLocation	
	move $s1, $v0
	move $s2, $v1						# save from.x from.y
	
										# prepare call to getLocation
	move $a0, $s0						# pass a0
	jal getLocation

	# subtract points
	sub $t0, $v0, $s1
	sub $t1, $v1, $s2
	
	# get abs value
	abs $t0, $t0
	abs $t1, $t1
	
	beq $t0, 1, isValidL_1
	beq $t0, 2, isValidL_2
	j isValidL_invalid
	
	isValidL_1:
	beq $t1, 2, isValidL_valid
	
	j isValidL_invalid
	isValidL_2:
	beq $t1, 1, isValidL_valid
	
	j isValidL_invalid
	
	isValidL_invalid:
	li $v0, 0
	j isValidL_return
	
	isValidL_valid:
	li $v0, 1
	
	isValidL_return:
	# Epilogue =============================
	
	lw $ra, 12($sp)
	lw $s0, 8($sp)
	lw $s1, 4($sp)
	lw $s2, 0($sp)
	
	addi $sp, $sp, 16
	# ======================================
	jr $ra
	
	
# (int, char) validKingMove(short from, short to, int player, short& capture)
# Arguments:
#	from is where the king starts
#	to is where the king is hoping to move to
#	player is {1,2}
#	capture is the address of where we need to store the captured piece (Row/col)
# Returns:
#	(-2,'\0') for invalud ARGS like from, to, player
#	(-1,'\0') for invalid move
#	(0, '\0') for valid unobstructed move
#	(1, pieceAcquired) for valid captured movement
validKingMove:
	# Prologue =============================
	# Stack
	#	1) $ra
	#	2) $s0
	#	3) $s1
	#	4) $s2
	#	5) $s3
	#	6) $s4
	#	7) $s5
	#	8) $s6
	#	9) $s7

	addi $sp, $sp, -36
	
	sw $ra, 32($sp)
	sw $s0, 28($sp)
	sw $s1, 24($sp)
	sw $s2, 20($sp)
	sw $s3, 16($sp)
	sw $s4, 12($sp)
	sw $s5, 8($sp)
	sw $s6, 4($sp)
	sw $s7, 0($sp)
	
	# ======================================

	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3					# save all our arguments
		
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# Preliminary Checks
	
	# Step 2 : Check FROM, TO, and PLAYER
	
	li $s6, -2 
	li $s7, '\0'						# default fail state
	
	# check from's coordinates
									# prepare call isValidShort
	move $a0, $s0					# pass from
	jal isValidShort					# isValidShort(;)
	beqz $v0, validKingMove_invalidArg
	
	# check to's coordinates
									# prepare call isValidShort
	move $a0, $s1					# pass to
	jal isValidShort					# isValidShort(;)
	beqz $v0, validKingMove_invalidArg
	
	# check player
	bgt $s2, 2, validKingMove_invalidArg
	blt $s2, 1, validKingMove_invalidArg

	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# Step 3: Check for invalid movement
	
	li $s6, -1
	li $s7, '\0'						# invalid move state
	
	# Step 3a check if no movement
	# check equal position because its invalid to not make a move
	beq $s0, $s1, validKingMove_invalidMove
	
	# Step 3b check obstructions
	beq $s2, 2, validKingMove_checkAgainstP2
	li $s4, 2
	j validKingMove_checkmateScan
	
	validKingMove_checkAgainstP2:
	li $s4, 1
	
									# prepare call to removeKing(;)
	move $a0, $s4					# pass player
	jal removeKing					# remove king of plaeyer1,2)
	move $s5, $v0					# save location of king  
	
	validKingMove_checkmateScan:
									# prepare call to check(;;)
	move $a0, $s4					# pass player
	move $a1, $s1					# pass to
	jal check						# check(;;)
	
									# put the king back
									# prepare call to getLocation(;)
	move $a0, $s5					# pass location of king
	jal getLocation					# getLocation(;)
	
									# prepare call to getBoardPosition(;)
	move $a0, $v0					# pass x
	move $a1, $v1					# pass y
	jal getBoardPosition				# getBoardPosition(;)
	
	li $t0, 'K'
	sb $t0, 0($v0)					# store KING back
	
	beqz $v0, validKingMove_invalidMove
	
									# prepare call to getChessPiece(;)
	move $a0, $s1					# pass current coordinate 
	jal getChessPiece				# getChessPiece(;)
	
									# if last square is our OWN piece -> invalid
	beq $v1, $s2, validKingMove_invalidMove
									# else if empty -> valid unobstructed
	beq $v0, 'E', validKingMove_valid 
									# else CAPTURE
	sw $s1, 0($s3)					# save the captured piece location onto memory
	
	li $s6, 1
	move $s7, $v0					# return valid capture
	j validKingMove_done
	
	validKingMove_valid:
	li $s6, 0
	li $s7, '\0'
	validKingMove_invalidMove:
	validKingMove_done:	 
	move $v0, $s6
	move $v1, $s7
	
	validKingMove_invalidArg:
	validKingMove_epilogue: 
	# Epilogue =============================	
	lw $ra, 32($sp)
	lw $s0, 28($sp)
	lw $s1, 24($sp)
	lw $s2, 20($sp)
	lw $s3, 16($sp)
	lw $s4, 12($sp)
	lw $s5, 8($sp)
	lw $s6, 4($sp)
	lw $s7, 0($sp)
	
	addi $sp, $sp, 36
	# ======================================
	jr $ra

validQueenMove:
	# Prologue =============================
	# Stack
	#	1) $ra
	#	2) $s0
	#	3) $s1
	#	4) $s2
	#	5) $s3
	#	6) $s4
	#	7) $s5
	#	8) $s6
	#	9) $s7

	addi $sp, $sp, -36
	
	sw $ra, 32($sp)
	sw $s0, 28($sp)
	sw $s1, 24($sp)
	sw $s2, 20($sp)
	sw $s3, 16($sp)
	sw $s4, 12($sp)
	sw $s5, 8($sp)
	sw $s6, 4($sp)
	sw $s7, 0($sp)
	
	# ======================================

	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3					# save all our arguments
		
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# Preliminary Checks
	
	# Step 2 : Check FROM, TO, and PLAYER
	
	li $s6, -2 
	li $s7, '\0'						# default fail state
	
	# check from's coordinates
									# prepare call isValidShort
	move $a0, $s0					# pass from
	jal isValidShort					# isValidShort(;)
	beqz $v0, validQueenMove_invalidArg
	
	# check to's coordinates
									# prepare call isValidShort
	move $a0, $s1					# pass to
	jal isValidShort					# isValidShort(;)
	beqz $v0, validQueenMove_invalidArg
	
	# check player
	bgt $s2, 2, validQueenMove_invalidArg
	blt $s2, 1, validQueenMove_invalidArg

	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# Step 3: Check for invalid movement
	
	li $s6, -1
	li $s7, '\0'						# invalid move state
	
	# Step 3a check if no movement
	# check equal position because its invalid to not make a move
	beq $s0, $s1, validQueenMove_invalidMove
	
	# Step 3b check obstructions 
	
	# CHECK KING MOVEMENT
									# prepare call to validKingMove
	move $a0, $s0					# pass from
	move $a1, $s1					# pass to
	move $a2, $s2					# pass player
	move $a3, $s3					# pass capture
	jal validKingMove				# validKingMove()
									# if move isnt 0 then diagonals succeeded
	bne $v0, -1, validQueenMove_investigate
	
	# CHECK BISHOP MOVEMENT
									# prepare call to validBishopMove
	move $a0, $s0					# pass from
	move $a1, $s1					# pass to
	move $a2, $s2					# pass player
	move $a3, $s3					# pass capture
	jal validBishopMove				# validBishopMove()
									# if move isnt 0 then diagonals succeeded
	
	bne $v0, -1, validQueenMove_investigate
	
	# CHECK ROOK MOVEMENT
									# prepare call to validRookMove
	move $a0, $s0					# pass from
	move $a1, $s1					# pass to
	move $a2, $s2					# pass player
	move $a3, $s3					# pass capture
	jal validRookMove				# validRookMove()
									# if move isnt 0 then diagonals succeeded
	bne $v0, -1, validQueenMove_investigate
	
	# IF queen could not move like a bishop, rook, or king FAIL
	j validQueenMove_invalidMove
	# else we will investigate the square
	
	validQueenMove_investigate:
									# prepare call to getChessPiece(;)
	move $a0, $s1					# pass current coordinate 
	jal getChessPiece				# getChessPiece(;)
	
									# if last square is our OWN piece -> invalid
	beq $v1, $s2, validQueenMove_invalidMove
									# else if empty -> valid unobstructed
	beq $v0, 'E', validQueenMove_valid 
									# else CAPTURE
	sw $s1, 0($s3)					# save the captured piece location onto memory
	
	li $s6, 1
	move $s7, $v0					# return valid capture
	j validQueenMove_done
	
	validQueenMove_valid:
	li $s6, 0
	li $s7, '\0'
	validQueenMove_invalidMove:
	validQueenMove_done:	 
	move $v0, $s6
	move $v1, $s7
	
	validQueenMove_invalidArg:
	validQueenMove_epilogue: 
	# Epilogue =============================	
	lw $ra, 32($sp)
	lw $s0, 28($sp)
	lw $s1, 24($sp)
	lw $s2, 20($sp)
	lw $s3, 16($sp)
	lw $s4, 12($sp)
	lw $s5, 8($sp)
	lw $s6, 4($sp)
	lw $s7, 0($sp)
	
	addi $sp, $sp, 36
	# ======================================
	jr $ra


validKnightMove:
	# Prologue =============================
	# Stack
	#	1) $ra
	#	2) $s0
	#	3) $s1
	#	4) $s2
	#	5) $s3
	#	6) $s4
	#	7) $s5
	#	8) $s6
	#	9) $s7

	addi $sp, $sp, -28
	
	sw $ra, 24($sp)
	sw $s0, 20($sp)
	sw $s1, 16($sp)
	sw $s2, 12($sp)
	sw $s3, 8($sp)
	sw $s6, 4($sp)
	sw $s7, 0($sp)
	
	# ======================================

	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3					# save all our arguments
		
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# Preliminary Checks
	
	# Step 2 : Check FROM, TO, and PLAYER
	
	li $s6, -2 
	li $s7, '\0'						# default fail state
	
	# check from's coordinates
									# prepare call isValidShort
	move $a0, $s0					# pass from
	jal isValidShort					# isValidShort(;)
	beqz $v0, validKnightMove_invalidArg
	
	# check to's coordinates
									# prepare call isValidShort
	move $a0, $s1					# pass to
	jal isValidShort					# isValidShort(;)
	beqz $v0, validKnightMove_invalidArg
	
	# check player
	bgt $s2, 2, validKnightMove_invalidArg
	blt $s2, 1, validKnightMove_invalidArg

	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# Step 3: Check for invalid movement
	
	li $s6, -1
	li $s7, '\0'						# invalid move state
	
	# Step 3a check if no movement
	# check equal position because its invalid to not make a move
	beq $s0, $s1, validKnightMove_invalidMove
	
	# Step 3b check if reachable
									# prepare call to isValidL
	move $a0, $s0					# pss from
	move $a1, $s1					# pass to
	jal isValidL						# isValidL(;;)
	beqz $v0, validKnightMove_invalidMove 	

	# Step 3c check destination
	
	validKnightMove_investigate:
	# investigate the last block
	
									# prepare call to getChessPiece(;)
	move $a0, $s1					# pass to coordinate
	jal getChessPiece				# getChessPiece(;)
	
									# if last square is our OWN piece -> invalid
	beq $v1, $s2, validKnightMove_invalidMove
									# else if empty -> valid unobstructed
	beq $v0, 'E', validKnightMove_valid 
									# else CAPTURE
	sw $s0, 0($s3)					# save the captured piece location onto memory
	
	li $s6, 1
	move $s7, $v0					# return valid capture
	j validKnightMove_done
	
	validKnightMove_valid:
	li $s6, 0
	li $s7, '\0'
	validKnightMove_invalidMove:
	validKnightMove_invalidArg:
	validKnightMove_done:	
	move $v0, $s6
	move $v1, $s7
	
	validKnightMove_epilogue:
	# Epilogue =============================		
	lw $ra, 24($sp)
	lw $s0, 20($sp)
	lw $s1, 16($sp)
	lw $s2, 12($sp)
	lw $s3, 8($sp)
	lw $s6, 4($sp)
	lw $s7, 0($sp)
	
	addi $sp, $sp, 28
	# ======================================
	jr $ra
	
validPawnMove:
	# Your code here
	li $v0, -2 #replace this line
	jr $ra
