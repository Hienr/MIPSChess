.include "hw4_hienr.asm"

.data
fileName1: .asciiz "game1.txt"
fileName2: .asciiz "game2.txt"
fileName3: .asciiz "game3.txt"
fileName4: .asciiz "8queens.txt"
fileName5: .asciiz "invalid.txt"

king_starting: .asciiz "iwanttocrysobadly"

.text
.globl main
main:
	li $a0, 0x7
	li $a1, 0X4
	li $a2, 0xA
	jal initBoard
	
	la $a0, fileName1
	jal loadGame
	
	li $a0, 2
	li $a1, 0x0706
	jal check
	
	move $t0, $v0

	li $v0, 1
	move $a0, $t0
	syscall
	
	li $v0, 11
	move $a0, $t1
	syscall
	
	li $v0, 10
	syscall
	
	
	
	
	
