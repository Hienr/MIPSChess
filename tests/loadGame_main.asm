.include "hw4_hienr.asm"

.data
fileName1: .asciiz "game1.txt"
fileName2: .asciiz "game2.txt"
fileName3: .asciiz "game3.txt"
fileName4: .asciiz "8queens.txt"
fileName5: .asciiz "invalid.txt"

.text
.globl main
main:
	li $a0, 0x0
	li $a1, 0XE
	li $a2, 0xD
	jal initBoard
	
	la $a0, fileName4
	jal loadGame
	
	move $a0, $v0
	li $v0, 1
	syscall
	
	move $a0, $v1
	li $v0, 1
	syscall
	
	li $v0, 10
	syscall
	
	
	
	
	
