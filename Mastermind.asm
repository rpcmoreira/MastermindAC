.data
MSG: .asciiz "\nInsira a tua tentativa de descodificação:\n"
BR: .asciiz "\n"

buffer: .space 4

.align 1
tentativas: .space 40			#Array de Tentativas para jogo

.align 1
cores: .ascii "BGRWPO"			#Azul, Verde, Vermelho, Branco, Preto, Laranja

.align 1
code_let: .space 4			#Array onde estara o codigo em formato Letra


.align 4
code: .space 12				#Array onde estara o codigo gerado pelo random_4


.text

rand_4: li $t0, 0
loop:   beq $t0, 16, codigo_troca
	li $v0, 42
	li $a1,	5
	syscall
	
	sw $a0, code($t0)
	addi $t0, $t0, 4
	j loop

codigo_troca:		
	la $s2, code_let
	li $s7, 0
	
codigo_letras: 
	beq $s7, 16, main
	la $s0, code
	la $s1, cores
	
	lw $t1, code($s7)
	add $s1, $s1, $t1
	lb $t2, ($s1)
	
	sb $t2, ($s2)
	
	addi $s7, $s7, 4
	addi $s2, $s2, 1
	j codigo_letras



main: 	
	la $t0, tentativas
	li $t2, 0
	
main_loop:
	beq $t2, 44, end_loop
	la $a0, MSG
	li $v0, 4
	syscall
	
	la $a0, buffer
	li $v0,8
	syscall
	
	li $t3, 0

loop_tent:
	beq $t3, 4, end_loop_tent	
	add $a0, $a0, $t3	
	sb $a0, ($t0)
	addi $t3, $t3, 1
	j loop_tent

end_loop_tent:	
	add $v0, $v0, $0
	addi $t0, $t0, 4
	addi $t2, $t2, 4
	j main_loop
	

end_loop:
	li $t1, 0
	la $t0, code_let
	li $v0, 4
	la $a0, BR
	syscall
loop2:
	beq $t1, 4, end
	lb $t3, ($t0)
	add $a0, $t3, $0
	li $v0, 11
	syscall
	
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	j loop2
	
end: li $v0,10
     syscall
