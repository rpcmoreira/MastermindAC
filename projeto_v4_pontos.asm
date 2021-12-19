.data
MSG: .asciiz "\nInsira a tua tentativa de descodificação:\n"
VENCE: .asciiz "\nAcertaste na Combinacao!\n"
Perdeu: .asciiz "\nErrou na combinação!\n"
BR: .asciiz "\n"
MSG2: .asciiz "\nPontuação: \n"
MSG3: .asciiz "\nContinuar o jogo? 'e' para sair do jogo.\n"
MSG_INVALIDA: .asciiz "\nCarater invalido!\n"

end_letter: .asciiz "e\n"

verver: .ascii "XoO" 	
cores: .ascii "BGRWPO"          #Azul, Verde, Vermelho, Branco, Preto, Laranja

.align 0
pontos: .byte 0

.align 0
tentativas: .space 40           #Array de Tentativas para jogo     # $s3

code_let: .space 4            	#Array onde estara o codigo em formato Letra         # $s5

buffer: .space 4   		# $s0

.align 2
code: .space 16               	#Array onde estara o codigo gerado pelo random_4    # $s6

compare: .space 16           	# $s7

aux: .space 16                	# usar stack
end_input: .space 1 
.text
######################################################################################### INICIO DO JOGO JOGADO
inicio_jogo: 	
	jal rand_4
	li $s0, 0    # valor das tentativas 
	la $s1, tentativas
	
jogo:
	#beq $s0, 40, ultima_jogada # key_print
	#beq $s0, 36, ultima_jogada
	la $a0, MSG
	la $a1, buffer
	la $a2, cores
	jal user_input			# salta para receber o input do user e verifica-o (valido ou nao)
	
	la $a0, code_let
	la $a1, buffer
	la $a2, aux
	jal comparacao_key 		# se o input for valido, salta para comparar o input com a key
	
	beq $s0, 40, ultima_jogada # key_print
	
add_tentativa: 
	li $t3, 0 
add_tentativa_loop:
	beq $t3, 4, exit_tentativa	
	lb $a0, buffer($t3)
	addi $t0, $t0, 1
	sb $a0, ($s1)
	addi $t3, $t3, 1
	addi $s1, $s1, 1
	j add_tentativa_loop

exit_tentativa:
	beq $v0, 8, ganhou # Se o $v0 de verificar_vitoria tiver 8 (os 4 careteres corretos) termina o jogo
    	add $v0, $v0, $0
    	addi $s0, $s0, 4
    	j jogo
    
#######################################################################################################################
# VERIFICAÇAO DO CODIGO INSERIDO			$a0- MSG	$a1 - buffer    $a2 - cores

user_input:						#usamos a stack para guardar os valores todos e nao estragar-mos nada na funcao jogo
	addi $sp, $sp, -24
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $a0, 8($sp)
	sw $a1, 12($sp)
	sw $a2, 16($sp)	
	sw $ra, 20($sp)
	move $t6, $a1
	move $t5, $a2
	
ler_cod:					       # Aqui iremos receber o input do user, para depois comparar
	la $a0, MSG
	li $v0, 4
	syscall
	
	la $a0, buffer
	li $v0,8
	syscall
	
	move $t6, $a0
	
	la $t7, compare
	li $s5, 0
	li $s6, 0
	li $s7, 0
	
	
validacao_input:					#inicio da validaçao do input
	beq $s6, 4, valida_input_exit
	
validacao_input_loop:
	lb $t3, ($t5)
	lb $t4, ($t6)
	beq $s5, 6, diferente
	beq $t4, $t3, igual
	addi $s5, $s5, 1
	addi $t5, $t5, 1
	j validacao_input_loop
			
igual:							#Case a cor seja valida, coloca 1 no array compare (Encontrou a cor)
	addi $s7, $0, 1
	sw $s7, ($t7)
	addi $t7, $t7, 4
	addi $s6, $s6, 1
	addi $t6, $t6, 1
	li $s5, 0
	la $t5, cores
	j validacao_input

diferente:						#Case a cor seja invalida, coloca 0 no array compare (Nao encontrou a cor)
	add $s7, $0, $0
	sw $s7, ($t7)
	addi $t7, $t7, 4
	addi $s6, $s6, 1
	addi $t6, $t6, 1
	li $s5, 0
	la $t5, cores
	j validacao_input
	
valida_input_exit:
	la $t7, compare
	li $t9, 1
	li $a3, 0
	
cod_valido:						# Multiplica todos os valores do array compare
	beq $a3, 4, valida_cod_exit			# Se o resultado for 0, entao existe um caracter inválido
	lw $t8, ($t7)					# Se o resultado for 1, entao o codigo é válido e pode ser comparado com a key gerada
	mul $t9, $t9, $t8
	addi $t7, $t7, 4
	addi $a3, $a3, 1
	j cod_valido
	
valida_cod_exit:					# Restauramos todos os valores que estavam guardados na stack novamente antes de retornar-mos a funcao jogo
	bne $t9, 1, cod_invalido
		
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $a0, 8($sp)
	lw $a1, 12($sp)
	lw $a2, 16($sp)	
	lw $ra, 20($sp)
	addi $sp, $sp, 24
	
	jr $ra
	
cod_invalido:
	li $v0, 4
	la $a0, MSG_INVALIDA
	syscall
	
	j ler_cod
	
#########################################################################################################################
# Comparaçao do Input do user com a combinaçao gerada        				  $a0-code_let $a1-buffer $a2-aux

comparacao_key:
	li $s6, 0
	
comparacao_loop:							#Aqui a dois loops
	beq $s6, 4, ajuda						
cor_pos_correta_loop:							#O primeiro ira comparar se o input tem a cor e a posicao correta em relacao a key
	lb $t3, ($a0)							#Se tiver, coloca no array ajuda o valor de 2 e passa para a letra seguinte do input
	lb $t4, ($a1)
	beq $t3, $t4, cor_pos_correta
	
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $s6, 4($sp)
	
	la $a0, code_let
	
comparacao_existe_key:							#Se o primeiro loop nao for valido, passa para o segundo, onde ira comparar se a letra do input esta presente
	beq $s6, 4, erro						#em qualquer posiçao da key gerada
	
comparacao_existe_loop:							#Se estiver, então adiciona ao array ajuda um valor 1, se não estiver, adiciona o valor de 0
	lb $t3, ($a0)
	beq $t3, $t4, cor_correta
	
	addi $s6, $s6, 1
	addi $a0, $a0, 1
	j comparacao_existe_key
	
erro:
	lw $a0, 0($sp)
	lw $s6, 4($sp)
	addi $sp, $sp, 8
	
	
	addi $t8, $0, 0
	sw $t8, ($a2)	
	addi $s6, $s6, 1
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	addi $a2, $a2, 4
	j comparacao_loop

cor_correta:	
	lw $a0, 0($sp)
	lw $s6, 4($sp)
	addi $sp, $sp, 8
	
	addi $t8, $0, 1
	sw $t8, ($a2)	
	addi $s6, $s6, 1
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	addi $a2, $a2, 4
	
	j comparacao_loop
	
cor_pos_correta:
	addi $t8, $0, 2
	sw $t8, ($a2)	
	addi $s6, $s6, 1
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	addi $a2, $a2, 4
	j comparacao_loop
	
	

ajuda:							#Usando o array ajuda, podemos imprimir as pistas para o user saber o que errou/acertou
	la $a2, aux					#Se o array tiver um 2, vai imprimir O - Posicao e Cor correta
	la $t7, verver					#Se o array tiver um 1, vai imprimir o - Posicao incorreta mas Cor correta
	li $t8, 0					#Se o array tiver um 0, vai imprimir X - Cor nao existe
	
loop_ajuda:
	beq $t8, 4, comparacao_end	
	lb $t3, ($a2)
	beq $t3, 2, print_O
	beq $t3, 1, print_o				
	beq $t3, 0, print_x

print_O:
	lb $a0, 2($t7)
	li $v0, 11
	syscall
	addi $t8, $t8, 1
	addi $a2, $a2, 4
	j loop_ajuda
	
print_o:
	lb $a0, 1($t7)
	li $v0, 11
	syscall
	addi $t8, $t8, 1
	addi $a2, $a2, 4
	j loop_ajuda
		
print_x:
	lb $a0, 0($t7)
	li $v0, 11
	syscall
	addi $t8, $t8, 1
	addi $a2, $a2, 4
	j loop_ajuda
	
comparacao_end:
	la $a2, aux
	li $t9, 0
	li $v0, 0
	
verificar_vitoria:					#Aqui iremos somar os valores de aux numa variavel $v0, que caso seja 8, significa que o user ganhou
	beq $t9, 4, comparacao_exit
	lw $t8, ($a2)
	add $v0, $v0, $t8
	addi $t9, $t9, 1
	addi $a2, $a2, 4
	j verificar_vitoria	
	
comparacao_exit:
	jr $ra
	
############################################################################################################# FIM DO JOGO
						#Aqui simplesmente estão as impressoes todas quando o jogo acaba
ultima_jogada:
	beq $v0, 8, ganhou 		# Se o jogador tiver ganho na ultima jogada
	lb $s2, pontos
	#addi $sp, $sp, 4
	li $t0, 0 # 2, 4, 6, 8
loop_ultima:
	bge $t0, $v0 end_ultima
	#beq $t1, 0, end_ultima
	addi $t0, $t0, 2
	addi $s2, $s2, 3
	j loop_ultima
	
end_ultima:
	sub $s2, $s2, 3
	sb $s2, pontos
	#addi $sp, $sp, -4
	#sw $s2, 24($sp)
	j key_print
	
ganhou:						#Pontuacao, se Venceu, o Codigo correto e se quer continuar
	lb $s2, pontos
	addi $s2, $s2, 12
	sb $s2, pontos
	la $a0, VENCE
	li $v0, 4
	syscall
	
key_print:
	la $a0, BR
	li $v0, 4
	syscall
	li $t1, 0
	la $t0, code_let
	
key_print_loop:
	beq $t1, 4, end_game
	lb $t3, ($t0)
	add $a0, $t3, $0
	li $v0, 11
	syscall
	
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	j key_print_loop
	
end_game: 
	
	lb $s2, pontos
	la $a0, MSG2 		# Mesnsagem da pontuação
	li $v0, 4
	syscall
	
     	slti $t1, $s2, 0
     	beq $t1, 1, ajuste_pont # Verifica se os pontos estão abaixo de zero, se tiverem vão para ajuste_pont
     	li $v0, 1
     	move $a0, $s2
     	syscall 
     	sb $s2, pontos

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
	bne $t3, $t4, reset 	# Se não escrever 'e' o jogo continua
	li $v0,10
	syscall
ajuste_pont:		# Se a pontuação tiver abaixo de zero colocamos os pontos a zero
	li $s2, 0
	jr $ra
	
reset:			# Para evitar problemas com as proximas tentativas de jogo foi criado uma função que coloca os valores a zero
	li $t0, 0
	li $t1, 0
	li $t2, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	li $t6, 0
	li $t7, 0
	li $t8, 0
	li $t9, 0
	
	li $s0, 0
	li $s1, 0
	li $s2, 0
	li $s3, 0
	li $s4, 0
	li $s5, 0
	li $s6, 0
	li $s7, 0
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $a0, 8($sp)
	lw $a1, 12($sp)
	lw $a2, 16($sp)	
	lw $ra, 20($sp)
	addi $sp, $sp, 24
	
	j inicio_jogo
	
############################################################################ RANDOMIZER DA KEY
rand_4: li $t0, 0
rand_loop:   							#Aqui vamos gerar um codigo de 4 numeros aleatorios de 0-5 (visto que temos 6 cores) para o array code
	beq $t0, 16, troca_letra
	li $v0, 42
	li $a1,	5
	syscall
	
	sw $a0, code($t0)
	addi $t0, $t0, 4
	j rand_loop

troca_letra:		
	la $s2, code_let
	li $s7, 0
	
troca_letra_loop: 						#Como o código é de letras, vamos converter os valores que estao em numero para as respetivas letras presente em "cores"
	beq $s7, 16, rand_exit					#Isto irá ser a nossa key durante o jogo, que a cada run irá sempre ser alterada
	la $s0, code
	la $s1, cores
	
	lw $t1, code($s7)
	add $s1, $s1, $t1
	lb $t2, ($s1)
	
	sb $t2, ($s2)
	
	addi $s7, $s7, 4
	addi $s2, $s2, 1
	j troca_letra_loop
	
rand_exit:
	jr $ra
###############################################################################################################
