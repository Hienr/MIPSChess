.include "hw4_hienr.asm"

.data

.text
.globl main
main:
	li $a0, 'H'
	li $a1, '8'
	jal mapChessMove
	
	move $a0, $v0
	li $v0, 1
	syscall
	
	
	
	li $v0, 10
	syscall
	
	
	
	
	
