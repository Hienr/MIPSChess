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
	li $a0, 0x7
	li $a1, 0X4
	li $a2, 0xA
	jal initBoard
	
	la $a0, fileName1
	jal loadGame
	
	li $a0, 3
	li $a1, 0
	li $a2, 'B'
	li $a3, 2
	li $t0, 0xF
	addi $sp, $sp, 4
	sw $t0, 0($sp)
	jal setSquare
	
	li $a0, 2
	li $a1, 1
	li $a2, 'P'
	li $a3, 2
	li $t0, 0xF
	jal setSquare
	
	li $a0, 'A'
	li $a1, '5'
	jal mapChessMove
	move $t0, $v0
	
	li $a0, 'B'
	li $a1, '6'
	jal mapChessMove
	move $t1, $v0
	
	move $a0, $t0
	move $a1, $t1
	#li $a0, 0x0401
	#li $a1, 0x0500
	li $a2, 2
	li $a3, 268501380
	jal validBishopMove
	
	move $t0, $v0
	move $t1, $v1
	
	li $v0, 1
	move $a0, $t0
	syscall
	
	li $v0, 11
	move $a0, $t1
	syscall
	
	li $v0, 10
	syscall
	
	
	
	
	
