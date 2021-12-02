.data
.align 1
cores: .ascii "B","G","R","W","B","O"			#Azul, Verde, Vermelho, Branco, Preto, Laranja

.align 4
code: .space 12




.text

rand_4: li $t0, 0
loop:   beq $t0, 16, end_loop
	li $v0, 42
	li $a1,	5
	syscall
	
	sw $a0, code($t0)
	addi $t0, $t0, 4
	j loop
	
end_loop:li $t1, 0
loop2:
	beq $t1, 16, end
	
	lw $a0, code($t1)
	li $v0, 1
	syscall
	
	addi $t1, $t1, 4
	j loop2
	
	
end: li $v0,10
     syscall