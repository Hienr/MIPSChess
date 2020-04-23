.include "hw4_hienr.asm"

.data

.text
.globl main
main:
	li $a0, 2
	li $a1, 4
	li $a2, 1
	jal getBishopDirection
	
	move $a0, $v0
	li $v0, 1
	syscall
	
	move $a0, $v1
	syscall
	
	
	
	li $v0, 10
	syscall
	
	
	
	
	
