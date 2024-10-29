.data
mensagem_boas_vindas:      .string "Bem-vindo ao Blackjack!\n"
mensagem_opcao_jogo:       .string "Você deseja jogar? Digite S para sim e N para não: \n"
mensagem_recebeu:          .string "\nVocê recebeu: "
mensagem_dealer_mostra:    .string "\nO dealer mostra: "
mensagem_opcao:            .string "\nO que você deseja fazer? (1 - Hit, 2 - Stand): \n"
mensagem_invalida:         .string "\nOpção inválida. Digite 1 para Hit ou 2 para Stand.\n"
mensagem_estouro:          .string "Você estourou! Dealer vence.\n"
mensagem_dealer_estouro:   .string "\nDealer estourou! Você venceu.\n"
mensagem_dealer_vence:     .string "\nDealer venceu com "
mensagem_jogador_vence:    .string "\nVocê venceu com "
mensagem_empate:           .string "\nEmpate!\n"
mensagem_jogar_novamente:  .string "\nDeseja jogar novamente? (S - Sim, N - Não): \n"
mensagem_opcao_invalida_jogo: .string "Opção inválida. Digite S para sim ou N para não.\n"
mensagem_fim_jogo:         .string "Obrigado por jogar!\n"
buffer:                    .space 10  # Buffer para armazenar a entrada do jogador
seed:                      .word 1    # Semente inicial para o gerador

.text
.globl _start

_start:
    # Exibe mensagem de boas-vindas e inicia o loop principal
    la a0, mensagem_boas_vindas
    li a7, 4               # syscall para imprimir string
    ecall

loop_principal:
    # Pergunta ao jogador se deseja jogar
    la a0, mensagem_opcao_jogo
    li a7, 4               # syscall para imprimir string
    ecall

leitura_jogo:
    # Lê a resposta do jogador (S ou N)
    la a0, buffer          # Carrega o endereço do buffer
    li a1, 10              # Tamanho máximo de caracteres a ler
    li a7, 8               # syscall para leitura de string
    ecall

    # Remove o caractere de nova linha ('\n') da entrada
    la t0, buffer          # Carrega a entrada lida em t0
    lb t1, 0(t0)           # Carrega o primeiro caractere
    lb t2, 1(t0)           # Carrega o segundo caractere (que deve ser '\n')
    li t3, '\n'            # Define '\n' para comparação
    beq t2, t3, entrada_valida # Se o segundo caractere for '\n', a entrada é válida
    j entrada_invalida_jogo

entrada_valida:
    li t2, 0               # Substitui o '\n' por '\0' (fim de string)
    sb t2, 1(t0)           # Grava o '\0' no lugar do '\n'
    # Verifica se o jogador digitou 'S', 's', 'N' ou 'n'
    lb t2, 0(t0)           # Lê o caractere da entrada
    li t3, 'S'             # Carrega 'S' para comparar
    li t4, 's'             # Carrega 's' para comparar
    li t5, 'N'             # Carrega 'N' para comparar
    li t6, 'n'             # Carrega 'n' para comparar
    beq t2, t3, jogar      # Se digitou 'S', vai para o jogo
    beq t2, t4, jogar      # Se digitou 's', vai para o jogo
    beq t2, t5, fim_jogo   # Se digitou 'N', termina o jogo
    beq t2, t6, fim_jogo   # Se digitou 'n', termina o jogo

    # Se a entrada for inválida, exibe mensagem de erro
entrada_invalida_jogo:
    la a0, mensagem_opcao_invalida_jogo
    li a7, 4               # syscall para imprimir string
    ecall
    j loop_principal       # Pergunta novamente

jogar:
    # Inicializa as pontuações do jogador e dealer
    li s5, 0               # Pontuação do jogador
    li s6, 0               # Pontuação do dealer (opcional, mas pode ser útil no futuro)

    # Sorteio inicial de cartas para o jogador e dealer
    jal gerar_carta        # Sorteia primeira carta do jogador
    mv s1, a0              # Armazena carta do jogador em s1
    jal gerar_carta        # Sorteia segunda carta do jogador
    mv s2, a0              # Armazena segunda carta do jogador em s2
    jal gerar_carta        # Sorteia primeira carta do dealer
    mv s3, a0              # Armazena carta do dealer em s3
    jal gerar_carta        # Sorteia segunda carta do dealer
    mv s4, a0              # Armazena segunda carta do dealer

    # Mostra as cartas do jogador e uma carta do dealer
    la a0, mensagem_recebeu
    li a7, 4
    ecall
    mv a0, s1              # Mostra a primeira carta do jogador
    li a7, 1               # syscall para imprimir inteiro
    ecall
    mv a0, s2              # Mostra a segunda carta do jogador
    li a7, 1               # syscall para imprimir inteiro
    ecall
    la a0, mensagem_dealer_mostra
    li a7, 4
    ecall
    mv a0, s3              # Mostra a primeira carta do dealer
    li a7, 1               # syscall para imprimir inteiro
    ecall

    # Calcula a pontuação do jogador
    jal calcular_pontuacao
    mv s5, a0              # Armazena a pontuação do jogador

turno_jogador:
    # Pede uma ação do jogador: Hit (1) ou Stand (2)
    la a0, mensagem_opcao
    li a7, 4
    ecall

    # Lê a escolha do jogador (1 ou 2)
    li a7, 5               # syscall para leitura de número inteiro
    ecall                  # Resultado será colocado em a0

    # Verifica se o jogador escolheu 1 para Hit
    li t4, 1
    beq a0, t4, jogador_hit

    # Verifica se o jogador escolheu 2 para Stand
    li t4, 2
    beq a0, t4, turno_dealer

    # Entrada inválida, exibe mensagem e retorna para escolher novamente
    la a0, mensagem_invalida
    li a7, 4
    ecall
    j turno_jogador

jogador_hit:
    # Jogador escolheu Hit, sorteia nova carta
    jal gerar_carta        # Sorteia mais uma carta
    mv t5, a0              # Armazena a nova carta recebida

    # Mostra a nova carta recebida
    la a0, mensagem_recebeu
    li a7, 4
    ecall
    mv a0, t5              # Mostra carta sorteada
    li a7, 1
    ecall

    # Atualiza a pontuação do jogador
    add s5, s5, t5         # Adiciona a nova carta à pontuação
    jal verificar_as       # Verifica se a contagem de Ás deve ser ajustada

    # Checa se o jogador estourou
    li t0, 21
    blt s5, t0, turno_jogador  # Se a pontuação é menor que 21, volta para o turno do jogador

    # Jogador estourou
    la a0, mensagem_estouro
    li a7, 4
    ecall
    j jogar_novamente

turno_dealer:
    # Código para o turno do dealer
    # (deve conter a lógica para o dealer agir e, ao final, verificar o vencedor)
    j jogar_novamente

jogar_novamente:
    la a0, mensagem_jogar_novamente
    li a7, 4
    ecall
    j loop_principal       # Reinicia o loop principal

fim_jogo:
    la a0, mensagem_fim_jogo
    li a7, 4
    ecall
    li a7, 10              # Termina o programa
    ecall

# Funções auxiliares
gerar_carta:
    # Gera uma carta aleatória entre 1 e 13 (para simular cartas de um baralho)
    li t0, 13
    li t1, 1
    li a7, 42              # syscall para randomização
    ecall                  # Resultado será colocado em a0
    rem a0, a0, t0         # Gera número entre 0 e 12
    add a0, a0, t1         # Gera número entre 1 e 13
    ret

calcular_pontuacao:
    # Calcula a pontuação inicial baseada nas cartas
    add a0, s1, s2
    ret

verificar_as:
    # Ajusta a contagem do Ás se estourar
    li t0, 10

