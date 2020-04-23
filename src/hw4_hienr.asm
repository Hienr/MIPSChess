# Raymond Hien
# hienr

.include "hw4_helpers_hienr.asm"

.text
#########################################
# Helpers
#########################################

# (short, bool) getDiagonalScales(short from, short to)
# Arguments: short from, short target location
# Returns the scalers to move along the diagonal
getDiagonalScales:
	# Prologue =============================
	# Stack
	#	1) $ra
	#	2) $s0
	#	3) $s1
	#	4) $s3
	#	5) $s4
	#	6) $s5
	#	7) $s6
	
	addi $sp, $sp, -28			# preallocate stack
	
	sw $ra, 24($sp)
	sw $s0, 20($sp)
	sw $s1, 16($sp)
	sw $s3, 12($sp)
	sw $s4, 8($sp)
	sw $s5, 4($sp)
	sw $s6, 0($sp)
	# ======================================
	
	move $s0, $a0	
	move $s1, $a1				# save from and to
	
								# prepare call to getLocation(;)
	# $a0 already passed
	jal getLocation				# getLocation(;)
	move $s3, $v0
	move $s4, $v1				# save from x,y
	
								# prepare call to getLocation(;)
	move $a0, $s1				# pass to
	jal getLocation				# getLocation(;)
	
	move $s5, $v0
	move $s6, $v1				# save to.x,y
	
	# Current Locations registers
	# $s3 - FROM.X
	# $s4 - FROM.Y
	# $s5 - TO.X
	# $s6 - TO.Y
	
	# check if valid diagonal first
								# prepare call to isValidDiagonal(;;;;)
	move $a0, $s3				# pass from.x
	move $a1, $s4				# pass from.y
	move $a2, $s5				# pass to.x
	move $a3, $s6				# pass to.y
	jal isValidDiagonal			# isValidDiagonal(;;;;)
								# if not valid diagonal -> fail
	beq $v0, $0, getDiagonalScales_invalidDiagonal
	
	
	bgt $s5, $s3, getDiagonalScales_incrementX
	li $a0, -1
	j getDiagonalScales_checkY
	
	getDiagonalScales_incrementX:
	li $a0, 1
	
	getDiagonalScales_checkY:
	
	bgt $s6, $s4, getDiagonalScales_incrementY
	li $a1, -1
	
	j getDiagonalScales_shortIt
	
	getDiagonalScales_incrementY:
	li $a1, 1
	
	getDiagonalScales_shortIt:
								# prepare call to getShort(;;)
	# $a0 already has x
	# $a1 already has y
	jal getShort					# getShort(;;)
	
	# $v0 is returned from getShort(;;) as well
	j getDiagonalScales_epilogue
	
	getDiagonalScales_invalidDiagonal:
	li $v0, -1
	li $v1, -1
	
	getDiagonalScales_epilogue:
	li $v1, 1
	# Epilogue =============================
	lw $ra, 24($sp)
	lw $s0, 20($sp)
	lw $s1, 16($sp)
	lw $s3, 12($sp)
	lw $s4, 8($sp)
	lw $s5, 4($sp)
	lw $s6, 0($sp)
	
	addi $sp, $sp, 28			# return stack
	# ======================================
	jr $ra
	
# bool isValidDiagonal(int from.x, int from.y, int to.x, int to.y)
# Arguments: a from and to position
# Returns: 1/0 if the 2 points form a valid diagonal on the chess board
isValidDiagonal:
	# formula for slope
	# rise/run = y2 - y1 / x2 - x1
	li $t0, 1					# constant
	
	sub $t1, $a3, $a1			# y2-y1
	sub $t2, $a2, $a0			# x2-x1
	
	div $t1, $t2					# y2-y1 / x2 - x1
	
	mflo $t3
	abs $t3, $t3
	
	seq $v0, $t3, $t0			# if their slope is 1 (x) 
								# then they are on the proper diagonal
	jr $ra
	
# bool isValidAxis(int from.x, int from.y, int to.x, int to.y)
# Arguments: a from and to position
# Returns: 1/0 if the 2 points form a valid rook axis on the chess board
isValidAxis:
	li $v0, 0
	beq $a0, $a2, isValidAxis_valid
	beq $a1, $a3, isValidAxis_valid
	
	j isValidAxis_invalid
	
	isValidAxis_valid:
	li $v0, 1
	isValidAxis_invalid:
	jr $ra
	
# (short, bool) getAxialScales(short from, short to)
# Arguments: short from, short target location
# Returns the scalers to move along the x or y axis
getAxialScales:
	# Prologue =============================
	# Stack
	#	1) $ra
	#	2) $s0
	#	3) $s1
	#	4) $s3
	#	5) $s4
	#	6) $s5
	#	7) $s6
	
	addi $sp, $sp, -28			# preallocate stack
	
	sw $ra, 24($sp)
	sw $s0, 20($sp)
	sw $s1, 16($sp)
	sw $s3, 12($sp)
	sw $s4, 8($sp)
	sw $s5, 4($sp)
	sw $s6, 0($sp)
	# ======================================
	
	move $s0, $a0	
	move $s1, $a1				# save from and to
	
								# prepare call to getLocation(;)
	# $a0 already passed
	jal getLocation				# getLocation(;)
	move $s3, $v0
	move $s4, $v1				# save from x,y

	
								# prepare call to getLocation(;)
	move $a0, $s1				# pass to
	jal getLocation				# getLocation(;)
	
	move $s5, $v0
	move $s6, $v1				# save to.x,y
	
	# Current Locations registers
	# $s3 - FROM.X
	# $s4 - FROM.Y
	# $s5 - TO.X
	# $s6 - TO.Y
	
	# check if valid axial first
								# prepare call to isValidAxis(;;;;)
	move $a0, $s3				# pass from.x
	move $a1, $s4				# pass from.y
	move $a2, $s5				# pass to.x
	move $a3, $s6				# pass to.y
	jal isValidAxis				# isValidAxis(;;;;)
								# if not valid axial -> fail
	beq $v0, $0, getAxialScales_invalidAxial
	
	# get scalers to pass into fnc to turn into short
								# if to.x = from.x -> up/down only
	bne $s5, $s3, getAxialScales_horizontalMovement
								# elif to.y > from.y -> go upwards
	bgt $s6, $s4, getAxialScales_moveUp
								# else go downwards
	# SET (0, -1)
	li $a1, -1
	li $a0, 0
	j getAxialScales_shortIt
							
								# if to.x = from.x and to.y > from.y -> 
	getAxialScales_moveUp:
	# SET (0, 1)
	li $a1, 1					# move upwards
	li $a0, 0	
	j getAxialScales_shortIt
	
	getAxialScales_horizontalMovement:
								# if to.x > from.x -> go right
	bgt $s5, $s4, getAxialScales_moveRight
								# else go left
	# SET (-1, 0)
	li $a0, -1
	li $a1, 0
	j getAxialScales_shortIt
	
	getAxialScales_moveRight:
	# SET (1, 0)
	li $a0, 1
	li $a1, 0
	# fall through
	
	getAxialScales_shortIt:
								# prepare call to getShort(;;)
	# $a0 already has x
	# $a1 already has y
	jal getShort					# getShort(;;)
	
	# $v0 is returned from getShort(;;) as well
	j getAxialScales_epilogue
	
	getAxialScales_invalidAxial:
	li $v0, -1
	li $v1, -1
	
	getAxialScales_epilogue:
	li $v1, 1
	# Epilogue =============================
	lw $ra, 24($sp)
	lw $s0, 20($sp)
	lw $s1, 16($sp)
	lw $s3, 12($sp)
	lw $s4, 8($sp)
	lw $s5, 4($sp)
	lw $s6, 0($sp)
	
	addi $sp, $sp, 28			# return stack
	# ======================================
	jr $ra

# board[][] getBoardPosition(int rows, int cols)
# Arguments: int rows, int cols
# Returns: The position on the board at byte 0
getBoardPosition:
	li $v0, 0xffff0000
	# we multi by 2 because each cell is only 2 BYTES
	sll $t0, $a0, 4				# (i * # of columns) * 2
	sll $t1, $a1, 1				# j * 2
	
	add $v0, $v0, $t0			# add I offset to chess board
	add $v0, $v0, $t1			# now add J offset to chess board
	jr $ra


# (int row, int col) getLocation(short location)
# Arguments: a short containing data for a loc on the board
# Returns: row and col INT
getLocation:
	andi $v0, $a0, 65280			# mask out the higher8bits to get low-order rows
	srl $v0, $v0, 8				# to get them in the lower order
	
	andi $v1, $a0, 255			# mask out the lower 8 bits to get cols
	
	# $v0 has rows
	# $v1 has cols
	
	jr $ra

# short getShort(int row, int col)
# Arguments: row, col
# Returns: a short containing the cords
getShort:
	sll $a0, $a0, 8				# move every bit into
								# 0000 xxxx 0000 0000 
	add $v0, $a0, $a1			#+0000 xxxx 0000 xxxx
								# -------------------
	jr $ra						# 0000 xxxx 0000 xxxx
	
# short moveCoordinates(short coordinates, int x, int y)
# Arguments: the coordinates, and x and y to move
# Returns a short containing the new coordinates
moveCoordinates:
	# Prologue =============================
	# Stack
	#	1) $ra
	#	2) $s0
	#	3) $s1
	
	addi $sp, $sp, -12			# preallocate stack
	
	sw $ra, 8($sp)
	sw $s0, 4($sp)
	sw $s1, 0($sp)	
	# ======================================
	move $s0, $a1
	move $s1, $a2				# save scales
	
	# break down coordinates into its x and y
								# prepare call to getLocation(;)
	# $a0 already contains coordinates
	jal getLocation				# returns x and y into $v0, $v1
	
	# scale x and y from inputs
	add $a0, $v0, $s0			# scale x
	add $a1, $v1, $s1			# scale y
	
	# convert back to short
								# prepare call to getShort(;;)
	# $a0 is already passed
	# $a1 is already passed
	jal getShort					# getShort(;;)
	
	
	# Epilogue =============================
	lw $ra, 8($sp)
	lw $s0, 4($sp)
	lw $s1, 0($sp)	
	
	addi $sp, $sp, 12 
	# ======================================
	jr $ra						# $v0 is returned as short

# int getPlayer(byte fg)
# Arguments: a fg byte
# Returns: {1,2, -1 for fail} player
getPlayer:
	li $v0, -1
	
	andi $t0, $a0, 15				# isolate lower 4bits to get fg
	beq $t0, 0x0, getPlayer_isP2
	beq $t0, 0xF getPlayer_isP1
	j getPlayer_return
	
	getPlayer_isP2:
	li $v0, 2
	j getPlayer_return
	
	getPlayer_isP1:
	li $v0, 1
	getPlayer_return:
	jr $ra

# hexColor getColor(int player)
# Arguments: int player {1, 2}
# Returns the hexcolor
getColor:
	li $v0, 0x0
	bne $a0, 1, getColor_returnBlack
	li $v0, 0xF					# load white instead
	
	getColor_returnBlack:
	jr $ra
	
# bool isPiece(byte piece)
# Arguments: byte or char of a piece
# Returns 1/0 ifPieceOrNot
isPiece:
	# $a0 is piece
	li $v0, 1					# success state
	beq $a0, 'p', isValidPiece
	beq $a0, 'P', isValidPiece
	beq $a0, 'R', isValidPiece
	beq $a0, 'H', isValidPiece
	beq $a0, 'B', isValidPiece
	beq $a0, 'Q', isValidPiece
	beq $a0, 'K', isValidPiece
	
	# if not a piece, return 0 then
	li $v0, 0
	isValidPiece:
	jr $ra
	
# (bool, bool) inRange(int rows, int cols)
# Arguments: row # and col # as int
# Returns : 1/0 if its within range
# 0 <= x <= 7
inRange:
	li $v0, 0
	li $v1, 0
	
	bltz $a0, inRange_fail
	bgt $a0, 7, inRange_fail
	li $v0, 1
	
	bltz $a1, inRange_fail
	bgt $a1, 7, inRange_fail
	li $v1, 1
	
	inRange_fail:
	jr $ra
	
# bool isValidShort(short coordinates)
# Arguments: short form of coordinates
# Returns 1/0 if its valid
isValidShort:
	# Prologue =============================
	# Stack
	#	1) $ra
	
	addi $sp, $sp, -4			# preallocate stack
	
	sw $ra, 0($sp)	
	# ======================================
	
	li $v0, 0			# default false state
	
						# prepare call to getLocation(;)
	# $a0 already contains our short
	jal getLocation		# returns x and y into $v0 & $v1
	
						# prepare call to inRange(;;)
	move $a0, $v0		# pass rows
	move $a1, $v1		# pass cols
	jal inRange			# inRange(;;)
	
						# if x is not valid return 0
	beqz $v0, isValidShort_invalid
						# if y is not valid return 0
	beqz $v1, isValidShort_invalid
						# else x and y are valid return 1
	li $v0, 1			
	
	isValidShort_invalid:
	# Epilogue =============================
	lw $ra, 0($sp)	
	
	addi $sp, $sp, 4
	# ======================================
	jr $ra
	
##########################################
#  Part #1 Functions
##########################################
# void initBoard(byte fg, byte darkbg, byte lightbg)
# Arguments:
#	fg: byte value representing foreground color for all squares
#	darkbg: byte-v for bg color for the dark squares
# 	lightbh: byte-b got bg color for the light squares
#	* May assume all inputs will be between 0x00 and 0xFF	only
# Returns Void
# Reset the cells of the board in each cell to a specified color, and 'E'
initBoard:
	# $a0 fg
	# $a1 darkbg
	# $a2 lightbg
	
	li $t0, 0xffff0000			# load starting address of board
	li $t1, 0					# counter of squares filled
	li $t2, 'E'					# reset value
	li $t9, 8					# constant value; edge of board
	
	sll $a1, $a1, 4				# shift all the bits in lightBG to the left
	sll $a2, $a2, 4				# shift all the bits in darkBG to the left
	
	or $t8, $a1, $a0				# or the two bytes to get color (DARK) +FG
	or $t7, $a2, $a0				# or the two bytes to get color (LIGHT) + FG
	
	initBoard_fillLight:
	beq $t1, 64, initBoard_finInit
	
								# store in byte 1 the ASCII
	sb $t2, 0($t0)				# store 'E'
	addi $t0, $t0, 1				# store in byte 2 the COLOR
				
	sb $t7, 0($t0)				# store COLOR
	
								# prepare to fill in a dark
	addi $t1, $t1, 1				# increment 1 : we filled in a block
	addi $t0, $t0, 1				# proceed to next byte
	
								# get modulo of 8 to get remainder
								# with remainder we can know if we should proceed
								# with double-fill
	div $t1, $t9					# divide # of blocks filled with 8
	mfhi $t3						# move remainder into $t3
	beqz $t3, initBoard_fillLight
	
	initBoard_fillDark:
	
								# store in byte 1 the ASCII
	sb $t2, 0($t0)				# store 'E'
	addi $t0, $t0, 1				# store in byte 2 the COLOR

	sb $t8, 0($t0)				# store COLOR
	
	addi $t1, $t1, 1				# increment 1 : we filled in a block
	addi $t0, $t0, 1				# proceed to next byte
	
								# get modulo of 8 to get remainder
								# with remainder we can know if we should proceed
								# with double-fill
	div $t1, $t9					# divide # of blocks filled with 8
	mfhi $t3						# move remainder into $t3
	beqz $t3, initBoard_fillDark
	
	j initBoard_fillLight
	
	initBoard_finInit:
	jr $ra

# int setSquare(int row, int col, char piece, int player, byte fg)
# Arguments:
#	row 0 < x< 7: row of the 2D board to place the piece
#	col 0 < x < 7: column of the 2D board to place the piece
#	piece : ASCII char to place 
#	player {1,2}: the player placing the piece 
#	fg : foreground color to set the square to upon piece removal
setSquare:
	# $a0 row
	# $a1 col
	# $a2 piece
	# $a3 player
	# ($a4 is on the top of the stack) fg
	
	li $v0, -1					# default error state to return
	lw $t9, 0($sp)				# load fourth arg from the stack
	
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# Preliminary Checks
	
	# row = [0,7]
	bltz $a0, setSquare_error
	bgt $a0, 7, setSquare_error
	
	# col = [0, 7]
	bltz $a1, setSquare_error
	bgt $a1, 7, setSquare_error
	
	# player = {1,2}
	blt $a3, 1, setSquare_error
	bgt $a3, 2, setSquare_error
	
	# fg > 0xF
	bgt $t9, 0xF, setSquare_error
	
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	li $t0, 0xffff0000			# base addr of chess board
	
	# Step 1: Calculate Array Position to Set
	# we multi by 2 because each cell is only 2 BYTES
	sll $a0, $a0, 4				# (i * # of columns) * 2
	sll $a1, $a1, 1				# j * 2
	
	add $t0, $t0, $a0			# add I offset to chess board
	add $t0, $t0, $a1			# now add J offset to chess board
						
	# we now have board[i][j] into $t0
	sb $a2, 0($t0)				# Set the PIECE		
	
	# Step 2: Set Foreground
	addi $t0, $t0, 1				# get the color BYTE of the CELL
	
	lb $t2, 0($t0)				# load the COLOR BYTE of this CELL
	# color byte of this cell is now in $t2
	
								# mask out the LAST 4 BITS to set FOREGROUND TO 0
	andi $t2, $t2, 240			# mask out with 240:
								# 0000 0000 0000 0000 0000 0000 1111 0000
								# whatever bits are in here     xxxx yyyy
								# will be preserved in x, but will flip to 0 in y
	
								# if piece is E then remove by changing foreground
	beq $a2, 'E', setSquare_removePiece
	beq $a3, 2, setSquare_Player2
	
	# setSquare_Player1:
	ori $t2, $t2, 0xF			# or with WHITE
	j setSquare_finalize
	
	setSquare_Player2:
	ori $t2, $t2, 0x0			# or with BLACK
	j setSquare_finalize
	
	setSquare_removePiece:
	or $t2, $t9, $t2				# or with FG
	
	setSquare_finalize:
	sb $t2, 0($t0)				# store
	move $v0, $0					# success state to return

	setSquare_error:
	jr $ra

# void initPieces()
# Arguments: None
# Returns Void
initPieces:	# nested func
	# Prologue =============================
	# Stack
	#	1) $ra
	#	2) $s0
	#	3) $s1
	#	4) $s2
	#	5) $s3
	
	addi $sp, $sp, -24			# preallocate stack
	
	sw $ra, 20($sp)
	sw $s0, 16($sp)
	sw $s1, 12($sp)
	sw $s2, 8($sp)
	sw $s3, 4($sp)
	# 0($sp) is preallocated for our 1 pushed argument
	
	# ======================================
	# initialize the [row,column]
	li $s0, 0					# initialize i
	li $s1, 0					# initialize j
	li $s2, 2					# initialize player
	li $s3, 0x0					# initialize FG to BLACK
	
	initPieces_royals:
	# Traverse every pos in a row and place the corresponding piece
	
	# place rook
								# prepare call to setSquare(;;;;;)
	move $a0, $s0				# pass rows
	move $a1, $s1				# pass columns
	li $a2, 'R'					# pass ROOK
	move $a3, $s2				# pass current player
	sw $s3, 0($sp)				# store FG on stack
	jal setSquare				# setSquare(;;;;;)
	
	addi $s1, $s1, 1				# cols++
	
	# place knight
								# prepare call to setSquare(;;;;;)
	move $a0, $s0				# pass rows
	move $a1, $s1				# pass columns
	li $a2, 'H'					# pass KNIGHT
	move $a3, $s2				# pass current player
	sw $s3, 0($sp)				# store FG on stack
	jal setSquare				# setSquare(;;;;;)
	
	addi $s1, $s1, 1				# cols++
	
	# place bishop
								# prepare call to setSquare(;;;;;)
	move $a0, $s0				# pass rows
	move $a1, $s1				# pass columns
	li $a2, 'B'					# pass BISHOP
	move $a3, $s2				# pass current player
	sw $s3, 0($sp)				# store FG on stack
	jal setSquare				# setSquare(;;;;;)
	
	addi $s1, $s1, 1				# cols++
	
	# place QUEEN
	
								# prepare call to setSquare(;;;;;)
	move $a0, $s0				# pass rows
	move $a1, $s1				# pass columns
	li $a2, 'Q'					# pass QUEEN
	move $a3, $s2				# pass current player
	sw $s3, 0($sp)				# store FG on stack
	jal setSquare				# setSquare(;;;;;)
	
	addi $s1, $s1, 1				# cols++
	
	# place KING
								# prepare call to setSquare(;;;;;)
	move $a0, $s0				# pass rows
	move $a1, $s1				# pass columns
	li $a2, 'K'					# pass KING
	move $a3, $s2				# pass current player
	sw $s3, 0($sp)				# store FG on stack
	jal setSquare				# setSquare(;;;;;)

	addi $s1, $s1, 1				# cols++
	
	# place bishop
								# prepare call to setSquare(;;;;;)
	move $a0, $s0				# pass rows
	move $a1, $s1				# pass columns
	li $a2, 'B'					# pass BISHOP
	move $a3, $s2				# pass current player
	sw $s3, 0($sp)				# store FG on stack
	jal setSquare				# setSquare(;;;;;)

	addi $s1, $s1, 1				# cols++
		
	# place knight
								# prepare call to setSquare(;;;;;)
	move $a0, $s0				# pass rows
	move $a1, $s1				# pass columns
	li $a2, 'H'					# pass KNIGHT
	move $a3, $s2				# pass current player
	sw $s3, 0($sp)				# store FG on stack
	jal setSquare				# setSquare(;;;;;)

	addi $s1, $s1, 1				# cols++

	# place rook
								# prepare call to setSquare(;;;;;)
	move $a0, $s0				# pass rows
	move $a1, $s1				# pass columns
	li $a2, 'R'					# pass ROOK
	move $a3, $s2				# pass current player
	sw $s3, 0($sp)				# store FG on stack
	jal setSquare				# setSquare(;;;;;)

	li $s1, 0					# reset columns back to 0
	
	beq $s2, 1, initPieces_player1Pawns
	addi $s0, $s0, 1				# rows++
	j initPieces_pawns
	
	initPieces_player1Pawns:
	li $s0, 6					# player 2 pawns are on row 6
	
	initPieces_pawns:
								# prepare call to setSquare(;;;;;)
	move $a0, $s0				# pass rows
	move $a1, $s1				# pass columns
	li $a2, 'p'					# pass PAWNS
	move $a3, $s2				# pass current player
	sw $s3, 0($sp)				# store FG on stack
	jal setSquare				# setSquare(;;;;;)

	addi $s1, $s1, 1				# cols++
	
								# if cols < 8 then continue placing pawns
	blt $s1, 8, initPieces_pawns
								# else proceed
	beq $s2, 1, initPieces_epilogue
	li $s2, 1					# focus on player 1's pieces now
	li $s0, 7					# row7 must be filled now
	li $s1, 0					# reset cols
	li $s3, 0x0					# initialize color to BLACK now
	j initPieces_royals
	
	initPieces_epilogue:
	# Epilogue =============================
	
	lw $ra, 20($sp)
	lw $s0, 16($sp)
	lw $s1, 12($sp)
	lw $s2, 8($sp)
	lw $s3, 4($sp)
	
	addi $sp, $sp, 24
	# ======================================
	jr $ra

# short mapChessMove(char letter, char number)
# Arguments:
#	letter: ASCII char for column MUST BE IN ['A'-'H'] $a0
#	number: ASCII char for Rrow MUST BE IN ['1'-'8']   $a1
# Returns: short value representing (row, col)coordinate 
# [0] byte will hold a decimal column
# [1] byte will hold a decimal row
# ! Returns 0xFFFF if the move contains any INVALID ASCII chars
mapChessMove:
	li $v0, 0xFFFF				# default invalid state
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# Preliminary Checks
	
	# letter in the set ['A'-'H']
	blt $a0, 'A', mapChessMove_invalidASCII
	bgt $a0, 'H', mapChessMove_invalidASCII
	
	# number in the set ['1'-'8']
	blt $a1, '1', mapChessMove_invalidASCII
	bgt $a1, '8', mapChessMove_invalidASCII
	
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	# Step 1: convert letter to a number on the board
	addi $a0, $a0, -65			# map to a decimal # on ascii table ('A' -> 0)
	
	# Step 2: Map number to appropriate row
	#addi $a1, $a1, -48			# map to a decimal # [1-8]
	#addi $a1, $a1, -8			# sub -8
	addi $a1, $a1, -56			# sub 56 to get dec
	abs $a1, $a1					# get abs val
		
	# Step 3: Build short to return
	move $v0, $a1
	sll $v0, $v0, 8				# shift all the bits left by 8
	or $v0, $v0, $a0				# or the other dec
	
	# return this hex short
	mapChessMove_invalidASCII:
	jr $ra

# (int, int) loadGame(char[] fileName)
# Arguments: 
#	fileName: starting address for the string for the name of the file to open
# Returns: the number of pieces placed on the board for each player 
#			or (-1, -1) for fail in opening the file
loadGame:
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
	
	addi $sp, $sp, -36
	
	sw $ra, 32($sp)
	sw $s0, 28($sp)
	sw $s1, 24($sp)
	sw $s2, 20($sp)
	sw $s3, 16($sp)
	sw $s4, 12($sp)
	sw $s5, 8($sp)
	sw $s6, 4($sp)
	
	# ======================================
	
	li $s0, -1					# initialize both fail states
	li $s1, -1
	move $s3, $a0				# input stream
	
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# Preliminary Checks
	
	# Step 1 : Open file for processing
	# $a0 already contains our file name string
	li $v0, 13					# pass open file code
	li $a1, 0					# pass read only flag
	li $a2, 0					# pass mode
	syscall						# openFile(;;;)
	
								# if file DNE, error
	bltz $v0, loadGame_invalidFile
								# else prepare to read from file
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# no error so counter is at 0
	li $s0, 0
	li $s1, 0
	
	# maintenance on essential file registers
	move $s4, $v0				# save file descriptor
	
	# Step 2: Read line by line
	loadGame_readLine:
	li $v0, 14					# pass read from file syscall code
	move $a0, $s4				# pass file descriptor
	move $a1, $s3				# pass input stream
	li $a2, 5					# pass 5 to read 4char + \n
	syscall
	
	move $s3, $a1				# save new input chars stream
	move $s5, $v0				# save # of chars read
	beqz $s5, loadGame_finishedReading
	bltz $s5, loadGame_error
	
	# Step 3 parse line
	
	# get FG from player
	lb $a0, 0($s3)				# load player
	beq $a0, '1', loadGame_p1
	addi $s1, $s1, 1				# increment count of pieces for p2
	j loadGame_proceed

	loadGame_p1:
	addi $s0, $s0, 1				# increment count of pieces for p1
	
	loadGame_proceed:
								# prepare call to getColor(;)
	jal getColor					# getColor(;)
	move $s6, $v0				# save FG color
	
	lb $a0, 2($s3)				# get char at position 3 __x_ for letter
	lb $a1, 3($s3)				# get char at position 4 ___x for number
								# prepare call to mapChessMove(;;)
	# $a0 
	# $a1 already passed				
	jal mapChessMove				# mapChessMove(;;)
	# results of coordinate now in $v0
	
	# get rows and columns from $v0
	andi $t0, $v0, 3840			# mask out the higher4bits to get low-order rows
	srl $t0, $t0, 8				# to get them in the lower order
	
	andi $t1, $v0, 15			# mask out the lower 4 bits to get cols
	#srl $t1, $v0, 4				# drop the low-order 4bits to get columns
	
	# get int of player
	lb $a3, 0($s3)				# pass player but after passing -48
	addi $a3, $a3, -48
	
								# prepare call to setSquare(;;;;;)
	move $a0, $t0				# pass rows
	move $a1, $t1				# pass cols
	lb $a2, 1($s3)				# pass piece
	# $a3 already passed			# pass player
	sw $s6, 0($sp)				# pass FG
	jal setSquare				# setSquare(;;;;;)
	
	j loadGame_readLine
	
	loadGame_finishedReading:
	loadGame_error:
	loadGame_invalidFile:
	move $v0, $s0
	move $v1, $s1
	
	# Epilogue =============================

	lw $ra, 32($sp)
	lw $s0, 28($sp)
	lw $s1, 24($sp)
	lw $s2, 20($sp)
	lw $s3, 16($sp)
	lw $s4, 12($sp)
	lw $s5, 8($sp)
	lw $s6, 4($sp)
	
	addi $sp, $sp, 36
	jr $ra

##########################################
#  Part #2 Functions
##########################################

# (char, int) getChessPiece(short location)
# Function will return what piece & player at a location
# Arguments:
#	location : 2byte val represnting row and col
# Returns:
# char - piece
# int - player
getChessPiece:
	# Prologue =============================
	# Stack
	#	1) $ra
	#	2) $s0
	#	3) $s1
	#	4) $s2
	#	5) $s3
	#	6) $s4

	addi $sp, $sp, -24
	
	sw $ra, 20($sp)
	sw $s0, 16($sp)
	sw $s1, 12($sp)
	sw $s2, 8($sp)
	sw $s3, 4($sp)
	sw $s4, 0($sp)
	# ======================================
	# $a0 - location
	
	li $s0, 0xffff0000			# load board
	
	# Step 1: Get (Row,Col) from location
								# prepare call to getLocation(;)
	# $a0 already contains our location
	jal getLocation				# getLocation(;) -> returns $v0 $v1 rows/cols
	move $s1, $v0				# save (rows) i
	move $s2, $v1				# save (cols) j
	
								# prepare call to inRange(;;)
	#move $a0, $v0				# pass rows
	#move $a1, $v1				# pass cols
	#jal inRange					# if not in range error out
	#beqz $v0, getChessPiece_invalid
	#beqz $v1, getChessPiece_invalid
	
	# Step 2: Calculate Array Position
								# prepare call to getBoardPosition(;;)
	move $a0, $s1				# pass i
	move $a1, $s2				# pass j
	jal getBoardPosition			# getBoardPosition(;;)
	
	# we now have board[i][j] into $v0 now, save it into $s0
	move $s0, $v0				# save exact board position

	lb $s3, 0($s0)				# load the piece from byte0
	beq $s3, 'E', getChessPiece_invalid
	
								# prepare call to isPiece(;)
	#move $a0, $s3				# pass piece
	#jal isPiece					# isPiece(;)
	#beqz $v0, getChessPiece_invalid 
	
	addi $s0, $s0, 1				# advanced to color byte
	lb $s4, 0($s0)				# load the color byte from byte1
	
								# prepare call to getPlayer(;)
	move $a0, $s4				# pass color
	jal getPlayer				# getPlayer(;)
	
	move $v1, $v0				# return player
	move $v0, $s3				# return piece 
	
	j getChessPiece_valid
	
	getChessPiece_invalid:
	li $v0, 'E'
	li $v1, -1

	getChessPiece_valid:
	# Epilogue =============================
	lw $ra, 20($sp)
	lw $s0, 16($sp)
	lw $s1, 12($sp)
	lw $s2, 8($sp)
	lw $s3, 4($sp)
	lw $s4, 0($sp)
	
	addi $sp, $sp, 24
	# ======================================
	jr $ra

# (int, char) validBishopMove(short from, short to, int player, short& capture)
# Arguments:
#	from is where the bishop starts
#	to is where the bishop is hoping to move to
#	player is {1,2}
#	capture is the address of where we need to store the captured piece (Row/col)
# Returns:
#	(-2,'\0') for invalud ARGS like from, to, player
#	(-1,'\0') for invalid move
#	(0, '\0') for valid unobstructed move
#	(1, pieceAcquired) for valid captured movement
validBishopMove:
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
	beqz $v0, validBishopMove_invalidArg
	
	# check to's coordinates
									# prepare call isValidShort
	move $a0, $s1					# pass to
	jal isValidShort					# isValidShort(;)
	beqz $v0, validBishopMove_invalidArg
	
	# check player
	bgt $s2, 2, validBishopMove_invalidArg
	blt $s2, 1, validBishopMove_invalidArg

	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# Step 3: Check for invalid movement
	
	li $s6, -1
	li $s7, '\0'						# invalid move state
	
	# Step 3a check if no movement
	# check equal position because its invalid to not make a move
	beq $s0, $s1, validBishopMove_invalidMove
	
	# Step 3b check obstructions
	# find the direction first
									# prepare call to getDiagonalScales(;)
	move $a0, $s0					# pass from
	move $a1, $s1					# pass to
	jal getDiagonalScales			# getDiagonalScales(;)
	
									# if scales were not able
									# to be retrieved -> fail
	beq $v0, -1, validBishopMove_invalidMove
	
	# we have a unit vector of our scales in $v0 now
	move $s4, $v0					# save it
	
	# increment to the next block 
	add $s0, $s0, $s4				# from + (scales)
	
	validBishopMove_investigate:
									# if shorts == then attempt to capture
	beq $s0, $s1, validBishopMove_attemptCapture
	
									# prepare call to getChessPiece(;)
	move $a0, $s0					# pass current coordinate 
	jal getChessPiece				# getChessPiece(;)
							
									# if current block has a PIECE -> invalid
	bne $v0, 'E', validBishopMove_invalidMove
									# else process next square
									
	# increment to the next block 
	add $s0, $s0, $s4				# from + (scales)
	j validBishopMove_investigate
									
	validBishopMove_attemptCapture:
	
	# investigate the last block
	
									# prepare call to getChessPiece(;)
	move $a0, $s0					# pass current coordinate 
	jal getChessPiece				# getChessPiece(;)
	
									# if last square is our OWN piece -> invalid
	beq $v1, $s2, validBishopMove_invalidMove
									# else if empty -> valid unobstructed
	beq $v0, 'E', validBishopMove_valid 
									# else CAPTURE
	sw $s0, 0($s3)					# save the captured piece location onto memory
	
	li $s6, 1
	move $s7, $v0					# return valid capture
	j validBishopMove_done
	
	validBishopMove_valid:
	li $s6, 0
	li $s7, '\0'
	validBishopMove_invalidMove:
	validBishopMove_invalidArg:
	validBishopMove_done:	
	move $v0, $s6
	move $v1, $s7
	
	validBishopMove_epilogue:
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

validRookMove:
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
	beqz $v0, validRookMove_invalidArg
	
	# check to's coordinates
									# prepare call isValidShort
	move $a0, $s1					# pass to
	jal isValidShort					# isValidShort(;)
	beqz $v0, validRookMove_invalidArg
	
	# check player
	bgt $s2, 2, validRookMove_invalidArg
	blt $s2, 1, validRookMove_invalidArg

	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# Step 3: Check for invalid movement
	
	li $s6, -1
	li $s7, '\0'						# invalid move state
	
	# Step 3a check if no movement
	# check equal position because its invalid to not make a move
	beq $s0, $s1, validRookMove_invalidMove
	
	# Step 3b check obstructions
	# find the scales to proceed in the right direction toward "to"
	
									# prepare call to getAxialScales(;)
	move $a0, $s0					# pass from
	move $a1, $s1					# pass to
	jal getAxialScales				# getAxialScales(;)
	
									# if scales were not able
									# to be retrieved -> fail
	beq $v0, -1, validRookMove_invalidMove
	
	# we have a unit vector of our scales in $v0 now
	move $s4, $v0					# save it
	
	# increment to the next block 
	add $s0, $s0, $s4				# from + (scales)
	
	validRookMove_investigate:
									# if shorts == then attempt to capture
	beq $s0, $s1, validRookMove_attemptCapture
	
									# prepare call to getChessPiece(;)
	move $a0, $s0					# pass current coordinate 
	jal getChessPiece				# getChessPiece(;)
							
									# if current block has a PIECE -> invalid
	bne $v0, 'E', validRookMove_invalidMove
									# else process next square
									
	# increment to the next block 
	add $s0, $s0, $s4				# from + (scales)
	j validRookMove_investigate
									
	validRookMove_attemptCapture:
	
	# investigate the last block
	
									# prepare call to getChessPiece(;)
	move $a0, $s0					# pass current coordinate 
	jal getChessPiece				# getChessPiece(;)
	
									# if last square is our OWN piece -> invalid
	beq $v1, $s2, validRookMove_invalidMove
									# else if empty -> valid unobstructed
	beq $v0, 'E', validRookMove_valid 
									# else CAPTURE
	sw $s0, 0($s3)					# save the captured piece location onto memory
	
	li $s6, 1
	move $s7, $v0					# return valid capture
	j validRookMove_done
	
	validRookMove_valid:
	li $s6, 0
	li $s7, '\0'
	validRookMove_invalidMove:
	validRookMove_invalidArg:
	validRookMove_done:	
	move $v0, $s6
	move $v1, $s7
	
	validRookMove_epilogue:
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

# (int, char) performMove(int player, short from, short to, byte fg, short& king_pos)
# Arguments:
#	player int
#	short of from coordinate
#	short of to coordinate
# 	foreground
# Returns:
#	(status, piece captured)
#	(-2, '\0') for error with input arguments
#	(-1, '\0') for error with invalid move
#	(0, '\0') for successful move/ NO capture
#	(1, letter of piece captured) for successful YES capture
perform_move:
	lw $t0, 0($sp)					# 5th argument is on the stack
	
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

	addi $sp, $sp, -40
	
	sw $ra, 36($sp)
	sw $s0, 32($sp)
	sw $s1, 28($sp)
	sw $s2, 24($sp)
	sw $s3, 20($sp)
	sw $s4, 16($sp)
	sw $s5, 12($sp)
	sw $s6, 8($sp)
	sw $s7, 4($sp)
	# ======================================	
	move $s0, $a0					# save player
	move $s1, $a1					# save from
	move $s2, $a2					# save to
	move $s3, $a3					# save fg
	move $s4, $t0					# save address of king_pos 
	
	lw $t0, 0($s4)					# load original position of king
	sw $t0, 0($sp)					# save original king_pos to stack
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# Preliminary Checks
	
	# check if there is no piece at from
	# check if the piece belongs to current player
	# check if the coordinates are in range
	
	li $s5, -2
	li $s6, '\0'
			
	# check if the position is valid
									# prepare call to isValidShort(;)
	move $a0, $s1					# pass from
	jal isValidShort					# isValidShort(;)
	beqz $v0, perform_move_invalidArgs
	
									# prepare call to isValidShort(;)
	move $a0, $s2					# pass to
	jal isValidShort					# isValidShort(;)
	beqz $v0, perform_move_invalidArgs
	
	
									# prepare call to getChessPiece(;)
	move $a0, $s1					# pass from
	jal getChessPiece				# getChessPiece(;)
	
									# if current pos is EMPTY -> invalid args
	beq $v0, 'E', perform_move_invalidArgs
									# elif current pos player != current player
	bne $v1, $s0, perform_move_invalidArgs
	
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
								# prepare call to the validityFncs
	move $a0, $s1				# pass from
	move $a1, $s2				# pass to
	move $a2, $s0				# pass player
	move $a3, $s4				# pass space to store piece
	
	# SWITCH($v0)
	
		# PAWN CHECK
								# if not P check for p
		beq $v0, 'P', perform_move_pawn
								# elif not p then check ROOK
		bne $v0, 'p', perform_move_caseR
		
		perform_move_pawn:	
									# prepare call to validPawnMove
									
		addi $sp, $sp, -4			# preallocate stack
		
		sw $v0, 0($sp)				# push
		
		jal validPawnMove			# validPawnMove(;;;;)
		
		addi $sp, $sp 4				# pop stack

		li $s7, 'P'					# set pawn flag
		
		#d.f
		#li $v0, 0
		
		j perform_move_valid
		
		# ROOK CHECK
		perform_move_caseR:
		bne $v0, 'R', perform_move_caseH
			
									# prepare call to validRookMove
		jal validRookMove			# validRookMove(;;;;)
		
		li $s7, 'R'					# set rook flag
		j perform_move_valid
		
		# KNIGHT CHECK
		perform_move_caseH:
		bne $v0, 'H', perform_move_caseB
			
									# prepare call to validKnightMove
		jal validKnightMove			# validKnightMove(;;;;)
		
		li $s7, 'H'					# set knight flag
		j perform_move_valid
		
		# BISHOP CHECK
		perform_move_caseB:
		bne $v0, 'B', perform_move_caseQ
			
									# prepare call to validBishopMove
		jal validBishopMove			# validBishopMove(;;;;)
		
		li $s7, 'B'					# set bishop flag
		j perform_move_valid
		
		# QUEEN CHECK
		perform_move_caseQ:
		bne $v0, 'Q', perform_move_caseK
			
									# prepare call to validQueenMove
		jal validQueenMove			# validQueenMove(;;;;)
		
		li $s7, 'Q'					# set queen flag
		j perform_move_valid
		
		# KING CHECK
		perform_move_caseK:
		bne $v0, 'K', perform_move_invalidArgs
			
									# prepare call to validKingMove		
		jal validKingMove			# validKingMove(;;;;)
		
		li $s7, 'K'					# set king flag
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	perform_move_valid:	
	move $s5, $v0					# save VALIDITY RETURN STATE	
	move $s6, $v1					# save VALIDITY RETURN CHAR
	
									# if validityFnc fails -> return their fail state
	bltz $s5, perform_move_invalidValidity
									# else move is VALID
												
	# Get coordinates of FROM
									# perform call to getLocation(;)
	move $a0, $s1					# pass from
	jal getLocation					# getLocation(;)
	# $v0 and $v1 = x,y
	
	# Clear FROM
									# perform call to setSquare(;;;;;)
	move $a0, $v0					# pass rows
	move $a1, $v1					# pass cols
	li $a2, 'E'						# 'E' to clear it
	move $a3, $s0					# pass player
	
	addi $sp, $sp, -4				# allocate stack
	sw $s3, 0($sp)					# push byte fg
	
	jal setSquare					# setSquare(;;;;;)
	addi $sp, $sp, 4					# pop
	
	# Get coordinates of TO
									# perform call to getLocation(;)
	move $a0, $s2					# pass to
	jal getLocation					# getLocation(;)
	# $v0 and $v1 = x,y
	
	# Set TO
									# perform call to setSquare(;;;;;)
	move $a0, $v0					# pass rows
	move $a1, $v1					# pass cols
	move $a2, $s7					# pass the flag we set earlier on what piece to set to
	move $a3, $s0					# pass player
	
	addi $sp, $sp, -4				# allocate stack
	sw $s3, 0($sp)					# push byte fg
	
	jal setSquare					# setSquare(;;;;;)
	addi $sp, $sp, 4					# pop
	
	# Check King's position 
									# if not king flag -> return success
	bne $s7, 'K', perform_move_unmovedKing
									# else then its a king that moved
	sh $s2,0($s4)					# save its new position by ref
	j perform_move_success
	
	perform_move_unmovedKing:
	lw $t4, 0($sp)					# reload the original position of the king
	sw $t4, 0($s4)					# store it back into address at $s4
	
	perform_move_success:
	move $v0, $s5					# return state
	move $v1, $s6					# return captured character
	j perform_move_epilogue
	
	perform_move_invalidArgs:
	li $v0, -2
	li $v1, '\0'	
	
	perform_move_invalidValidity:		# $v0 and $v1 already set
	perform_move_epilogue:
	# Epilogue =============================	
	lw $ra, 36($sp)
	lw $s0, 32($sp)
	lw $s1, 28($sp)
	lw $s2, 24($sp)
	lw $s3, 20($sp)
	lw $s4, 16($sp)
	lw $s5, 12($sp)
	lw $s6, 8($sp)
	lw $s7, 4($sp)
	
	addi $sp, $sp, 40
	# ======================================
	jr $ra

##########################################
#  Part #3 Function
##########################################

# int check(int player, short opponentKingPos)
# Arguments: int player, short opponentKingPos
# Returns: -2 for error with input arguments
#		   -1 for failure (not in check state)
#		    0 for success (in check state)
check:
	# Prologue =============================
	# Stack
	#	1) $ra
	#	2) $s0
	#	3) $s1
	#	4) $s2
	#	5) $s3
	#	6) $s4
	#	7) $s5

	addi $sp, $sp, -32
	
	sw $ra, 28($sp)
	sw $s0, 24($sp)
	sw $s1, 20($sp)
	sw $s2, 16($sp)
	sw $s3, 12($sp)
	sw $s4, 8($sp)
	sw $s5, 4($sp)
	# ======================================	

	move $s0, $a0
	move $s1, $a1
	
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# Preliminary Checks
	
	
	blt $a0, 1, check_invalidArgs			# less than 1 error
	bgt $a0, 2, check_invalidArgs			# > 2 error
	
										# prepare call to isValidShort(;)
	move $a0, $a1						# pass opponents king pos
	jal isValidShort						# isValidShort(;)
										# if not valid short -> invalid arguments
										
	beqz $v0, check_invalidArgs			
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	li $s3, 0							# row = 0
	li $s4, 0							# col = 0
	
	check_InvestigateBlock:
	# short the coordinates
										# prepare call to getShort(;;)
	move $a0, $s3						# pass row
	move $a1, $s4						# pass col
	jal getShort							# getShort(;;)
	move $s5, $v0						# save short
	
										# prepare call to getChessPiece(;)
	move $a0, $v0						# pass coordinates
	jal getChessPiece					# getChessPiece(;;)
	
										# if players dont match -> next
	bne $v1, $s0, check_prepareInvestigation
	
	# Step 2 - investigate the block im on
	beq $v0, 'E', check_prepareInvestigation
										# prepare call to validityFnc
	move $a0, $s5						# pass from
	move $a1, $s1						# pass opponent to
	move $a2, $s0						# pass player
	move $a3, $sp						# initialize with sp top
	
	# SWITCH($v0)
	
		# PAWN CHECK
								# if not P check for p
		beq $v0, 'P', check__pawn
								# elif not p then check ROOK
		bne $v0, 'p', check__caseR
		
		check__pawn:	
									# prepare call to validPawnMove
									
		addi $sp, $sp, -4			# preallocate stack
		
		sw $v0, 0($sp)				# push
		
		jal validPawnMove			# validPawnMove(;;;;)
		
		addi $sp, $sp 4				# pop stack
		
		j check_prepareInvestigation
		
		# ROOK CHECK
		check__caseR:
		bne $v0, 'R', check__caseH
			
									# prepare call to validRookMove
		jal validRookMove			# validRookMove(;;;;)
	
		j check_prepareInvestigation
		
		# KNIGHT CHECK
		check__caseH:
		bne $v0, 'H', check__caseB
			
									# prepare call to validKnightMove
		jal validKnightMove			# validKnightMove(;;;;)
	
		j check_prepareInvestigation
		
		# BISHOP CHECK
		check__caseB:
		bne $v0, 'B', check__caseQ
			
									# prepare call to validBishopMove
		jal validBishopMove			# validBishopMove(;;;;)
		
		j check_prepareInvestigation
		
		# QUEEN CHECK
		check__caseQ:
		bne $v0, 'Q', check__caseK
			
									# prepare call to validQueenMove
		jal validQueenMove			# validQueenMove(;;;;)
		
		j check_prepareInvestigation
		
		# KING CHECK
		check__caseK:
		bne $v0, 'K', check_invalidArgs
			
									# prepare call to validKingMove		
		jal validKingMove			# validKingMove(;;;;)	
	
	check_prepareInvestigation:
	beq $v0, 1, check_check
	
	beq $s4, 7, check_incrementRow
	
	addi $s4, $s4, 1
	j check_InvestigateBlock
	
	check_incrementRow:
	beq $s3, 7, check_noCheck
	li $s4, 0
	
	addi $s3, $s3, 1
	
	j check_InvestigateBlock

	check_check:
	li $v0, 0
	
	j check_epilogue
	check_noCheck:
	li $v0, -1
	
	j check_epilogue
	check_invalidArgs:
	li $v0, -2
	
	check_epilogue:
	# Epilogue =============================
	lw $ra, 28($sp)
	lw $s0, 24($sp)
	lw $s1, 20($sp)
	lw $s2, 16($sp)
	lw $s3, 12($sp)
	lw $s4, 8($sp)
	lw $s5, 4($sp)
	
	addi $sp, $sp, 32
	
	# ======================================
	jr $ra