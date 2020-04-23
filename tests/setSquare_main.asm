.include "hw4_hienr.asm"

.data

.text
.globl main
main:
	li $a0, 0x0
	li $a1, 0XE
	li $a2, 0xD
	jal initBoard
	
	li $a0, 6
	li $a1, 3
	li $a2, 'E'
	li $a3, 1
	li $t0, 0x6
	
	sw $t0, 0($sp)
	
	jal setSquare
	
	move $a0, $v0
	li $v0, 1
	syscall
	
	li $v0, 10
	syscall
	
	
	
	
	
