.data
mensagem_boas_vindas:      .string "Bem-vindo ao Blackjack!\n"
mensagem_opcao_jogo:       .string "Você deseja jogar? Digite S para sim e N para não: \n"
mensagem_recebeu:          .string "\nVocê recebeu: "
mensagem_dealer_mostra:    .string "\nO dealer mostra: "
mensagem_carta_oculta:     .string ", e uma carta oculta"
mensagem_sua_mao:          .string "\nSua mão: "
mensagem_dealer_mao:       .string "\nMão do dealer: "
mensagem_mais:             .string " + "
mensagem_igual:            .string " = "
mensagem_opcao:            .string "\nO que você deseja fazer? (1 - Hit, 2 - Stand): \n"
mensagem_invalida:         .string "\nOpção inválida. Digite 1 para Hit ou 2 para Stand.\n"
mensagem_estouro:          .string "\nVocê estourou! Dealer vence.\n"
mensagem_dealer_estouro:   .string "\nDealer estourou! Você venceu.\n"
mensagem_dealer_vence:     .string "\nDealer venceu com "
mensagem_jogador_vence:    .string "\nVocê venceu com "
mensagem_empate:           .string "\nEmpate!\n"
mensagem_jogar_novamente:  .string "\nDeseja jogar novamente? (S - Sim, N - Não): \n"
mensagem_opcao_invalida_jogo: .string "Opção inválida. Digite S para sim ou N para não.\n"
mensagem_fim_jogo:         .string "\nObrigado por jogar!"
mensagem_dealer_hit:       .string "\nDealer pede mais uma carta..."
espaco:                    .string " "
buffer:                    .space 10
seed:                      .word 1

.text
.globl _start

_start:
    la a0, mensagem_boas_vindas
    li a7, 4
    ecall

loop_principal:
    la a0, mensagem_opcao_jogo
    li a7, 4
    ecall

leitura_jogo:
    la a0, buffer
    li a1, 10
    li a7, 8
    ecall

    la t0, buffer
    lb t1, 0(t0)
    lb t2, 1(t0)
    li t3, '\n'
    beq t2, t3, entrada_valida
    j entrada_invalida_jogo

entrada_valida:
    li t2, 0
    sb t2, 1(t0)
    lb t2, 0(t0)
    li t3, 'S'
    li t4, 's'
    li t5, 'N'
    li t6, 'n'
    beq t2, t3, jogar
    beq t2, t4, jogar
    beq t2, t5, fim_jogo
    beq t2, t6, fim_jogo

entrada_invalida_jogo:
    la a0, mensagem_opcao_invalida_jogo
    li a7, 4
    ecall
    j loop_principal

jogar:
    li s5, 0               # Pontuação do jogador
    li s6, 0               # Pontuação do dealer
    li s7, 0               # Contador de Ases do jogador
    li s8, 0               # Contador de Ases do dealer

    # Sorteia cartas iniciais
    jal gerar_carta
    mv s1, a0              # Primeira carta do jogador
    jal verificar_as_inicial
    add s7, s7, t0         # Incrementa contador de Ases se necessário
    
    jal gerar_carta
    mv s2, a0              # Segunda carta do jogador
    jal verificar_as_inicial
    add s7, s7, t0         # Incrementa contador de Ases se necessário
    
    jal gerar_carta
    mv s3, a0              # Primeira carta do dealer
    jal verificar_as_inicial
    add s8, s8, t0         # Incrementa contador de Ases do dealer
    
    jal gerar_carta
    mv s4, a0              # Segunda carta do dealer (oculta)
    jal verificar_as_inicial
    add s8, s8, t0         # Incrementa contador de Ases do dealer

    # Mostra as cartas iniciais
    la a0, mensagem_recebeu
    li a7, 4
    ecall
    
    mv a0, s1
    li a7, 1
    ecall
    
    la a0, mensagem_mais
    li a7, 4
    ecall
    
    mv a0, s2
    li a7, 1
    ecall

    # Mostra a mão do dealer (primeira carta + oculta)
    la a0, mensagem_dealer_mostra
    li a7, 4
    ecall
    
    mv a0, s3
    li a7, 1
    ecall
    
    la a0, mensagem_carta_oculta
    li a7, 4
    ecall

    # Calcula e mostra a soma inicial do jogador
    jal calcular_pontuacao_jogador
    mv s5, a0              # Guarda pontuação do jogador

    la a0, mensagem_sua_mao
    li a7, 4
    ecall
    
    mv a0, s1
    li a7, 1
    ecall
    
    la a0, mensagem_mais
    li a7, 4
    ecall
    
    mv a0, s2
    li a7, 1
    ecall
    
    la a0, mensagem_igual
    li a7, 4
    ecall
    
    mv a0, s5
    li a7, 1
    ecall

turno_jogador:
    la a0, mensagem_opcao
    li a7, 4
    ecall

    li a7, 5
    ecall

    li t4, 1
    beq a0, t4, jogador_hit
    li t4, 2
    beq a0, t4, turno_dealer

    la a0, mensagem_invalida
    li a7, 4
    ecall
    j turno_jogador

jogador_hit:
    jal gerar_carta
    mv t5, a0              # Nova carta

    la a0, mensagem_recebeu
    li a7, 4
    ecall
    
    mv a0, t5
    li a7, 1
    ecall

    # Verifica se é um Ás
    li t0, 1
    beq t5, t0, incrementa_as_jogador
    j continua_hit

incrementa_as_jogador:
    addi s7, s7, 1         # Incrementa contador de Ases

continua_hit:
    add s5, s5, t5         # Adiciona nova carta à pontuação
    jal ajustar_ases_jogador  # Ajusta pontuação considerando Ases

    # Mostra nova soma
    la a0, mensagem_sua_mao
    li a7, 4
    ecall
    
    mv a0, s5
    li a7, 1
    ecall

    li t0, 21
    bgt s5, t0, jogador_estoura
    j turno_jogador

jogador_estoura:
    la a0, mensagem_estouro
    li a7, 4
    ecall
    j jogar_novamente

turno_dealer:
    # Revela a mão completa do dealer
    la a0, mensagem_dealer_mao
    li a7, 4
    ecall
    
    mv a0, s3
    li a7, 1
    ecall
    
    la a0, mensagem_mais
    li a7, 4
    ecall
    
    mv a0, s4
    li a7, 1
    ecall

    # Calcula pontuação inicial do dealer
    jal calcular_pontuacao_dealer
    mv s6, a0

    la a0, mensagem_igual
    li a7, 4
    ecall
    
    mv a0, s6
    li a7, 1
    ecall

loop_dealer:
    li t0, 17
    bge s6, t0, verificar_vencedor  # Se dealer tem 17 ou mais, para de pedir

    la a0, mensagem_dealer_hit
    li a7, 4
    ecall

    jal gerar_carta
    mv t5, a0

    # Verifica se é um Ás
    li t0, 1
    beq t5, t0, incrementa_as_dealer
    j continua_dealer_hit

incrementa_as_dealer:
    addi s8, s8, 1         # Incrementa contador de Ases do dealer

continua_dealer_hit:
    add s6, s6, t5
    jal ajustar_ases_dealer

    # Mostra nova pontuação do dealer
    la a0, mensagem_dealer_mao
    li a7, 4
    ecall
    
    mv a0, s6
    li a7, 1
    ecall

    li t0, 21
    bgt s6, t0, dealer_estoura
    j loop_dealer

dealer_estoura:
    la a0, mensagem_dealer_estouro
    li a7, 4
    ecall
    j jogar_novamente

verificar_vencedor:
    beq s5, s6, empate     # Se pontuações iguais, empate
    bgt s5, s6, jogador_vence  # Se jogador tem mais, jogador vence
    j dealer_vence         # Senão, dealer vence

empate:
    la a0, mensagem_empate
    li a7, 4
    ecall
    j jogar_novamente

jogador_vence:
    la a0, mensagem_jogador_vence
    li a7, 4
    ecall
    mv a0, s5
    li a7, 1
    ecall
    j jogar_novamente

dealer_vence:
    la a0, mensagem_dealer_vence
    li a7, 4
    ecall
    mv a0, s6
    li a7, 1
    ecall
    j jogar_novamente

jogar_novamente:
    la a0, mensagem_jogar_novamente
    li a7, 4
    ecall
    j loop_principal

fim_jogo:
    la a0, mensagem_fim_jogo
    li a7, 4
    ecall
    li a7, 10
    ecall

# Funções auxiliares
gerar_carta:
    li t0, 13
    li t1, 1
    li a7, 42
    ecall
    rem a0, a0, t0
    add a0, a0, t1
    ret

verificar_as_inicial:
    li t0, 0               # Inicializa contador
    li t1, 1
    beq a0, t1, e_as      # Se carta é 1 (Ás)
    j nao_e_as
e_as:
    li t0, 1               # Incrementa contador de Ases
nao_e_as:
    ret

calcular_pontuacao_jogador:
    mv t0, s1              # Primeira carta
    mv t1, s2              # Segunda carta
    
    # Ajusta valor das cartas de figura para 10
    li t2, 10
    bgt t0, t2, ajusta_figura_1
    j continua_1
ajusta_figura_1:
    li t0, 10
continua_1:
    bgt t1, t2, ajusta_figura_2
    j continua_2
ajusta_figura_2:
    li t1, 10
continua_2:
    add a0, t0, t1
    ret

calcular_pontuacao_dealer:
    mv t0, s3              # Primeira carta do dealer
    mv t1, s4              # Segunda carta do dealer
    
    # Ajusta valor das cartas de figura para 10
    li t2, 10
    bgt t0, t2, ajusta_figura_3
    j continua_3
ajusta_figura_3:
    li t0, 10
continua_3:
    bgt t1, t2, ajusta_figura_4
    j continua_4
ajusta_figura_4:
    li t1, 10
continua_4:
    add a0, t0, t1
    ret

ajustar_ases_jogador:
    beqz s7, fim_ajuste_jogador  # Se não tem Ases, retorna
    li t0, 21
    bgt s5, t0, reduz_as_jogador # Se passou de 21, reduz valor do Ás
    j fim_ajuste_jogador
reduz_as_jogador:
    li t1, 10
    sub s5, s5, t1         # Reduz 10 (diferença entre valor 11 e 1 do Ás)
    addi s7, s7, -1        # Reduz contador de Ases
    bgt s5, t0, reduz_as_jogador # Se ainda passou de 21, continua reduzindo
fim_ajuste_jogador:
    ret

ajustar_ases_dealer:
    beqz s8, fim_ajuste_dealer   # Se não tem Ases, retorna
    li t0, 21
    bgt s6, t0, reduz_as_dealer  # Se passou de 21, reduz valor do Ás
    j fim_ajuste_dealer
reduz_as_dealer:
    li t1, 10
    sub s6, s6, t1         # Reduz 10 (diferença entre valor 11 e 1 do Ás)
    addi s8, s8, -1        # Reduz contador de Ases
    bgt s6, t0, reduz_as_dealer  # Se ainda passou de 21, continua reduzindo
fim_ajuste_dealer:
    ret
