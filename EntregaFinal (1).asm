; Projeto: Sistema de Dosagem Rotativa - Entrega Final
; Nomes: Luis Carlos Bastreghi Neto - 14802716
; Victor Henrique Portella Soler Rangel - 11954012

VAR_PROCESSO EQU 40h          ; Endereco de memoria para a variavel de processo

ORG 0000h
    AJMP main                 ; Desvia dos vetores de interrupcao

ORG 001Bh                     ; Vetor de interrupcao do Timer 1
    AJMP timer1_isr           ; Pula para a rotina de servico do Timer 1

ORG 0033h                     ; Inicio do programa principal
main:
    ; Inicializa o Stack Pointer em area segura
    MOV SP, #30h              

    ; Configura Timer 1 como contador de eventos externos no Modo 2 (Auto-reload 8-bit)
    ; Isso permite gerar uma interrupcao a cada pulso recebido no pino T1 (P3.5)
    MOV TMOD, #60h            ; TMOD: T1 em modo contador (C/T=1), Modo 2
    MOV TH1, #0FFh            ; Valor de recarga para transbordar a cada 1 evento
    
    ; Habilita interrupcoes
    SETB ET1                  ; Habilita interrupcao do Timer 1
    SETB EA                   ; Habilita chave geral de interrupcoes

    ; Selecionando o display 0 no EdSim51
    CLR P3.3                  
    CLR P3.4                  

    ; Inicializa estado e variaveis
    CLR F0                    ; Inicializa o sentido de rotacao (0 = horario)
    ACALL reset_timer         ; Garante que variavel de processo e Timer iniciam zerados e ligados

loop_principal:
    ACALL verifica_chave      ; Monitora se houve mudanca na chave fisica 
    ACALL atualiza_display    ; Atualiza o numero de voltas e o sentido no display
    SJMP loop_principal       ; Mantem o monitoramento continuo

; --- SUB-ROTINA: INTERRUPCAO DO TIMER 1 ---
; Disparada a cada evento (devido ao transbordo do auto-reload em FFh)
timer1_isr:
    PUSH ACC                  ; Salva contexto do acumulador
    PUSH PSW                  ; Salva contexto do status da CPU
    
    INC VAR_PROCESSO          ; Incrementa a variavel de processo a cada evento
    MOV A, VAR_PROCESSO       
    
    ; Verificacao do limite do contador (comparacao com 10)
    CJNE A, #10, fim_isr      ; Se nao for 10, vai para o fim da interrupcao
    
    ; Se atingiu 10, chama a rotina dedicada para parar, zerar e reiniciar
    ACALL reset_timer

fim_isr:
    POP PSW                   ; Restaura contexto
    POP ACC
    RETI                      ; Retorna da interrupcao

; --- SUB-ROTINA: RESET DO TIMER E VARIAVEL DE PROCESSO ---
reset_timer:
    CLR TR1                   ; Para o temporizador
    MOV VAR_PROCESSO, #0      ; Zera a variavel de processo (0 a 9)
    MOV TL1, #0FFh            ; Reinicia a contagem (prepara para o proximo transbordo)
    SETB TR1                  ; Reinicia a contagem de forma controlada
    RET

; --- SUB-ROTINA: ATUALIZA DISPLAY ---
atualiza_display:
    MOV A, VAR_PROCESSO       ; Captura o valor atual da contagem
    MOV DPTR, #TABELA         ; Carrega o endereco da tabela de segmentos 
    MOVC A, @A+DPTR           ; Busca o codigo correspondente na memoria de programa 
    
    ; Integracao da sinalizacao do sentido de rotacao (bit P1.7)
    MOV C, F0                 ; Copia o estado do sentido armazenado em F0 para o Carry
    MOV ACC.7, C              ; Insere o estado de F0 no bit 7 do padrao de segmentos
    
    MOV P1, A                 ; Envia o padrao de bits final para a Porta P1 
    RET

; --- SUB-ROTINAS DE DIRECAO ---
verifica_chave:
    MOV C, P2.0               ; Le o estado da chave no pino P2.0
    JB F0, chave_era_1        
    JC chama_muda             
    RET                       
chave_era_1:
    JNC chama_muda            
    RET                       
chama_muda:
    ACALL muda_direcao        
    RET

muda_direcao:
    MOV C, P2.0               
    MOV F0, C                 ; Atualiza a variavel de estado (F0)
    
    ; Garante coerencia ao trocar o sentido: chama a rotina de reset
    ACALL reset_timer         
    
    JB F0, sentido_anti       
sentido_horario:
    SETB P3.0                 
    CLR P3.1                  
    RET
sentido_anti:
    CLR P3.0                  
    SETB P3.1                 
    RET

; --- TABELA DE CODIFICACAO (7 Segmentos - Anodo Comum) ---
ORG 0100h                     ; Armazena a tabela em endereco isolado
TABELA: 
    DB 0C0h, 0F9h, 0A4h, 0B0h, 099h, 092h, 082h, 0F8h, 080h, 090h ; Digitos 0-9

END