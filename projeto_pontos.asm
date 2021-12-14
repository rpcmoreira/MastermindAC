.data
MSG: .asciiz "\nInsira a tua tentativa de descodificação:\n"
BR: .asciiz "\n"
MSG2: .asciiz "\nPontuação atual: "
MSG3: .asciiz "\nContinuar o jogo? 'e' para sair do jogo.\n"
MSG_INVALIDA: .asciiz "\nCarater invalido!\n"
MSG_GANHOU: .asciiz"\n Acertou no codigo!\n Ganhou 12 pontos.\n"
MSG_PERDEU: .asciiz"\n Não descobriu o codigo!\n Perdeu 3 pontos.\n"
MSG_HISTORICO: .asciiz "\nHistorico de pontos:\n"
END_LETTER: .asciiz "e\n"

.align 0
historico_pontos: .space 88

.align 2
buffer: .space 4

.align 0

end_input: .space 1

.align 0
verver: .ascii "VoO"

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
	li $t1, 0 # Começo da pontuação
	li $t9, 0 # Variavel que começa o historico de pontuação
main_loop:
	beq $t2, 40, end_loop
	
	la $a0, MSG
	li $v0, 4
	syscall
	addi $sp, $sp, -12
	sw $t9, 0($sp) # Guardamos a pontuação efetuada
	sw $t1, 4($sp) # Guardamos a pontuação efetuada
    	sw $t2, 8($sp) # Guardamos o numero de tentativas, para ser possivel fazer a pontuação
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
    lw $t2, 8($sp)
    addi $sp, $sp, 4 # Carregamos o valor de volta para ser atualizado, e abrimos espaço para ele, será necessario fechar logo esta parte da stack?
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
	beq $a3, 4, loop_tent	
	lw $t8, ($t7)
	mul $t9, $t9, $t8
	addi $t7, $t7, 4
	addi $a3, $a3, 1
	j sair_loop
	
sair_loop_a:
	beq $t9, 1, verifica_rand
	
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
	#la $t9, cores
	li $t9, 0
	li $s5, 0
	li $s6, 0
	
verifica_loop:
	li $s0, 0
	beq $s6, 4, end_verifica
verifica_loop_a:
	lb $t3, ($t5) # Carrega o codigo em formato letra
	lb $t4, ($t6) # Carrega o que o usuario colocou
	#lb $s7, ($t9) # Carrega as cores
	beq $t3, $t4, cpc # Se se for igual ao codigo vai para o cpc
loop_cores:
	beq $t3, $t4, valida_cor
	beq $t9, 3, nao_acertou
	#lb $t3, ($t5)
	lb $t3, ($t5)
	addi $t5, $t5, 1
	#addi $t5, $t5, 1
	addi $t9, $t9, 1
	j loop_cores
	
valida_cor:
	addi $t8, $0, 1
	sw $t8, ($t7)	# Guarda no aux o o valor de 1
	addi $s5, $s5, 1
	addi $s6, $s6, 1
	addi $t5, $t5, 1
	addi $t6, $t6, 1
	addi $t7, $t7, 4
	j verifica_loop
	
cpc:
	addi $t8, $0, 2
	sw $t8, ($t7)	# Guarda no aux o o valor de 2
	addi $s5, $s5, 1
	addi $s6, $s6, 1
	addi $t5, $t5, 1
	addi $t6, $t6, 1
	addi $t7, $t7, 4
	j verifica_loop
nao_acertou:
	li $t9, 0
	addi $t8, $0, 0
	sw $t8, ($t7)	
	addi $s5, $s5, 1
	addi $s6, $s6, 1
	#addi $t5, $t5, 1
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
	la $t9, code_let
end_verifica_a:
	beq $t8, 4, end_ver_final	
	lb $t3, ($t6)  # Carrega os valores do buffer para $t3
	lb $t4, ($t9) #  Carrega o codigo
	beq $t3, 2, print_O
	beq $t3, 1, print_o				#falta condição default aqui e em cima (Se nao for igual nem estiver no codigo), neste momento apenas e 1 ou 2
	beq $t3, 0, print_nothing

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
	
print_nothing:
	lb $a0, 0($t7)
	li $v0, 11
	syscall
	addi $t8, $t8, 1
	addi $t6, $t6, 4
	j end_verifica_a
	
end_ver_final:
	jr $ra
############################################################################################################## Pontuação
pontuação:
	lw $t2, 8($sp)
	addi $sp, $sp, 4 # Carregamos o numero de tentativas
	la $t7, aux # Carregamos para $t7 os valores usados para verificar o codigo
	lb $t9, ($t7) # Carrega para bytes o valor de aux
	li $t8, 0 # Variavel que gere os valores
	li $t1, 0 # Variavel que confirma se o jogador errou
	beq $t2, 36, ultima_jogada # Verifica se está na ultima jogada
loop_pontuação:
	lb $t9, ($t7) # Carrega para bytes o valor de aux
	bne $t9, 2, end_ver_final # Salta se não forem equivalentes
	beq $t8, 3, atribuir_pontuação
	addi $t8, $t8, 1
	addi $t7, $t7, 1 # Para passar ao proximo valor
	j loop_pontuação
	
atribuir_pontuação:
	lw $s0, 4($sp)
	lw $s1, 0($sp)
	addi $sp, $sp, 8
	addi $s1, $s1, 1
	addi $s0, $s0, 12
	addi $sp, $sp, -8
	sw $s1, 0($sp)
	sw $s0, 4($sp)
	j end_loop # Como acertou para o jogo e manda o usuario para a parte final
	
ultima_jogada:
	lw $s0, 4($sp)
	lw $s1, 0($sp)
	addi $sp, $sp, 8
ultima_jogada_loop:
	lb $t9, ($t7)
	beq $t9, 2, ultima_jogada_a
	beq $t8, 3, ultima_jogada_final
	# Caso não tenha encontrado o 2
	addi $t8, $t8, 1
	addi $t7, $t7, 1
	j ultima_jogada_loop
	
ultima_jogada_a:
	addi $s0, $s0, 3
	addi $t8, $t8, 1
	addi $t7, $t7, 1
	j ultima_jogada_loop
	
ultima_jogada_final:
	addi $s1, $s1, 1 # Adiciona um valor no historico
	addi $s0, $s0, -3 # O jogador perdeu a partida por não ter descoberto a combinação, devido a isso é removido 3 pontos
	addi $sp, $sp, -8
	sw $s1, 0($sp)
	sw $s0, 4($sp)
	j end
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
	
ajustar_pontuação:
	li $s0, 0
	jr $ra
end:      
     lw $s1, 4($sp) # Carrega o "i" do array historico_pontos
     lw $s0, 0($sp) # Carrega a pontuação
     addi $sp, $sp, 8
     slti $t0, $s0, 0 # Se a pontuação estiver a baixo de zero $t0 fica com 1, se não fica com zero
     beq $t0, 1, ajustar_pontuação # Se tiver abaixo de zero, é colocado o valor a zero
     
     sb $s0, historico_pontos($s1) # Duvidas aqui, era assim que se guardava no array?
     
     la $a0, MSG2
     li $v0, 4
     syscall
     li $v0, 1
     move $a0, $s0
     syscall
     la $a0, MSG3
     li $v0, 4
     syscall
     
     li $v0, 8
     la $a0, end_input
     li $a1, 2 # Limita o numero de careteres que o usuario pode colocar para evitar "bugs"
     syscall 			# Resposta do usuario
     move $t0, $a0 		
     
     la $t2, END_LETTER
     lb $t3, ($t0)
     lb $t4, ($t2)
     bne $t3, $t4, rand_4 	# Se não escrever 'e' o jogo continua
     
     li $v0, 4
     la $a0, MSG_HISTORICO
     syscall
     li $t5, 0
loop_end: # O historico não está a funcionar bem
     beq $t5, $s1, finish
     lb $t6, historico_pontos($t5) # Começa do zero até onde o $s1 foi
     li $v0, 1
     move $a0, $t6
     syscall
     addi $t5, $t5, 1
     j loop_end
finish:
     li $v0,10
     syscall
