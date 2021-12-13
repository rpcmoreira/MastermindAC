.data
MSG: .asciiz "\nInsira a tua tentativa de descodificação:\n"
BR: .asciiz "\n"
MSG2: .asciiz "\nPontuação: \n"
MSG3: .asciiz "\nContinuar o jogo? 'e' para sair do jogo.\n"
MSG_INVALIDA: .asciiz "\nCarater invalido!\n"
end_letter: .asciiz "e\n"



.align 2
buffer: .space 4

.align 0

end_input: .space 1

.align 0
verver: .ascii " oO"

.align 0
tentativas: .space 44			#Array de Tentativas para jogo

.align 0
cores: .ascii "BGRWPO"			#Azul, Verde, Vermelho, Branco, Preto, Laranja

.align 0
code_let: .space 4			#Array onde estara o codigo em formato Letra

.align 2
code: .space 12				#Array onde estara o codigo gerado pelo random_4

.align 2
compare: .space 12

.align 2
aux: .space 12

.text

############################################################################ INICIO JOGO E RANDOMIZER DO CODIGO
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
###############################################################################################################

######################################################################################### INICIO DO JOGO JOGADO
main: 	
	la $t0, tentativas
	li $t2, 0
	
main_loop:
	beq $t2, 40, end_loop
	la $a0, MSG
	li $v0, 4
	syscall
	
	la $a0, buffer
	li $v0,8
	syscall
	
	jal verificacao_cod
	
loop_tent: li $t3, 0 
loop_tent_a:
	beq $t3, 4, end_loop_tent	
	lb $a0, buffer($t3)
	addi $t0, $t0, 1
	sb $a0, ($t0)
	addi $t3, $t3, 1
	j loop_tent_a

end_loop_tent:
    add $v0, $v0, $0
    addi $t2, $t2, 4
    j main_loop
    
#######################################################################################################################
# VERIFICAÇAO DO CODIGO INSERIDO

verificacao_cod:
	la $t5, cores
	la $t6, buffer
	la $t7, compare
	li $s5, 0
	li $s6, 0
	li $s7, 0
loop_c:
	beq $s6, 4, sair
loop_c_2:
	lb $t3, ($t5)
	lb $t4, ($t6)
	beq $s5, 6, diferente
	beq $t4, $t3, igual
	addi $s5, $s5, 1
	addi $t5, $t5, 1
	j loop_c_2
			
igual:
	addi $s7, $0, 1
	sw $s7, ($t7)
	addi $t7, $t7, 4
	addi $s6, $s6, 1
	addi $t6, $t6, 1
	li $s5, 0
	la $t5, cores
	j loop_c

diferente:
	add $s7, $0, $0
	sw $s7, ($t7)
	addi $t7, $t7, 4
	addi $s6, $s6, 1
	addi $t6, $t6, 1
	li $s5, 0
	la $t5, cores
	j loop_c
	
sair:
	la $t7, compare
	li $t9, 1
	li $a3, 0
sair_loop:
	beq $a3, 4, verifica_rand	
	lw $t8, ($t7)
	mul $t9, $t9, $t8
	addi $t7, $t7, 4
	addi $a3, $a3, 1
	j sair_loop
	
sair_loop_a:
	beq $t9, 1, loop_tent
	
	li $v0, 4
	la $a0, MSG_INVALIDA
	syscall
			
	j loop_tent				# Temos que usar a stack em cima para ele voltar a tentativa correta, sem stack vamos perder a posicao
	
#########################################################################################################################
# VERIFICAÇÃO DO CODIGO RANDOM

verifica_rand:
	la $t5, code_let
	la $t6, buffer
	la $t7, aux
	li $s5, 0
	li $s6, 0
	
verifica_loop:
	beq $s6, 4, end_verifica
verifica_loop_a:
	lb $t3, ($t5)
	lb $t4, ($t6)
	beq $t3, $t4, cpc
	
	addi $t8, $0, 1
	sw $t8, ($t7)	
	addi $s5, $s5, 1
	addi $s6, $s6, 1
	addi $t5, $t5, 1
	addi $t6, $t6, 1
	addi $t7, $t7, 4
	j verifica_loop
	
cpc:
	addi $t8, $0, 2
	sw $t8, ($t7)	
	addi $s5, $s5, 1
	addi $s6, $s6, 1
	addi $t5, $t5, 1
	addi $t6, $t6, 1
	addi $t7, $t7, 4
	j verifica_loop
	
end_verifica:
	li $v0, 4
	la $a0, BR
	syscall
	
	la $t6, aux
	la $t7, verver
	li $t8, 0
end_verifica_a:
	beq $t8, 4, end_ver_final	
	lb $t3, ($t6)
	beq $t3, 2, print_O
	beq $t3, 1, print_o				#falta condição default aqui e em cima (Se nao for igual nem estiver no codigo), neste momento apenas e 1 ou 2


print_O:
	lb $a0, 2($t7)
	li $v0, 11
	syscall
	addi $t8, $t8, 1
	addi $t6, $t6, 4
	j end_verifica_a
	
print_o:
	lb $a0, 1($t7)
	li $v0, 11
	syscall
	addi $t8, $t8, 1
	addi $t6, $t6, 4
	j end_verifica_a
	
end_ver_final:
	jr $ra

############################################################################################################# FIM DO JOGO
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
	
end: 
     la $a0, MSG2
     li $v0, 4
     syscall
     la $a0, MSG3
     li $v0, 4
     syscall
     
     li $v0, 8
     la $a0, end_input
     syscall 			# Resposta do usuario
     move $t0, $a0 		# Grava a resposta em $t0
     
     la $t2, end_letter 
     lb $t3, ($t0)
     lb $t4, ($t2)
     bne $t3, $t4, rand_4 	# Se não escrever 'e' o jogo continua

     li $v0,10
     syscall
