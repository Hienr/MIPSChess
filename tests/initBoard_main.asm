.include "hw4_hienr.asm"

.data

.text
.globl main
main:
	li $a0, 0x05
	li $a1, 0XA4
	li $a2, 0xE3
	jal initBoard
	