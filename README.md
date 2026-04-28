# Sistema de Dosagem Rotativa - Entrega Final

**Autores:**
- Luis Carlos Bastreghi Neto - 14802716
- Victor Henrique Portella Soler Rangel - 11954012

## Descrição do Projeto
Projeto final desenvolvido em linguagem Assembly para o microcontrolador 8051, simulado no ambiente EdSim51. O sistema controla a direção de um motor e conta o número de voltas (eventos), exibindo a contagem em um display de 7 segmentos.

## Funcionalidades Implementadas (Requisitos da Entrega)
1. **Contador de Voltas (0 a 9) com Interrupção:** Utiliza o Timer 1 como contador de eventos externos. A comparação do limite de 10 eventos é feita via sub-rotina de interrupção, que para o temporizador, zera a variável e reinicia a contagem de forma controlada.
2. **Coerência na Mudança de Direção:** O sentido do motor é controlado pela chave conectada em P2.0. Sempre que a chave provoca mudança de direção, o sistema aciona a rotina de reset do Timer 1, zerando o display para não acumular giros de sentidos distintos.
3. **Sinalização Visual de Sentido:** O ponto decimal do display (bit P1.7) reflete o estado do sentido armazenado no bit F0. O ponto acende ou apaga simultaneamente com a exibição do número de voltas para indicar a direção atual.

## Como testar no EdSim51
1. Carregue o código Assembly no simulador.
2. Ajuste a "Update Freq." para 50000 e clique em "Run".
3. Dê cliques manuais no pino `P3.5` (Motor Sensor) para simular as voltas. O display contará de 0 a 9 e resetará.
4. Alterne a chave `SW 0` (pino `P2.0`) para testar a inversão do motor. O contador será zerado imediatamente e o ponto decimal do display (DP) mudará.
