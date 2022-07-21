# RISCV-multycicle

![riscv](https://img.shields.io/github/languages/top/gtLara/RISCV-multicycle?color=green&label=VHDL)![Itype](https://img.shields.io/badge/ISA-Itype-blueviolet)![Itype](https://img.shields.io/badge/ISA-Rtype-blueviolet)

Uma implementação experimental do conjunto de instruções RISC-V em multiciclo.
Desenvolvimento iniciado para matéria Laboratório e Arquitetura e Organização
de Computadores (ELT134) lecionada a nível de graduação na UFMG pelo professor
Ricardo Duarte do departamento de Engenharia Eletrônica.

## Datapath

![datapath](imagens/datapath.png?raw=true)

## Componentes

Os componentes usados no caminho de dados são de autoria mista: dos
contribuidores do repositório e do professor Ricardo Duarte. A inclusão dos
componentes de autoria própria foi realizada ao ter dificuldade de compreender
e desenvolver em torno dos componentes pré-existentes, especialmente as
memórias.

## Controle

Os sinais de controle do datapath são emitidos por uma máquina de estados
finitos distinta em nível de abstração. O projeto em alto nível da máquina
de estados (HLFSM) é ilustrado pela figura abaixo.

![controle](imagens/controle.jpg?raw=true)

A máquina de estados é implementada no componente [control](control.vhd) e
a verificação de seu funcionamento é apresentada na subseção seguinte.

## Simulações

### Datapath

A simulação realizada para verificar o datapath é simples: observar a
propagação apropriada de sinais no datapath e verificação de funcionamento da
instrução `lw`. A seguinte imagem apresenta a execução da instrução

`lw x4, 4(3)`

montada para binário em

`00000000010000011010111110000011`

![lw](imagens/simulacao_simples_lw.png?raw=true)

Observamos na figura que o resultado da ULA está como esperado e a leitura do
contador de programas também, assim como o parsing das instruções e os sinais
de controle. Outras instruções foram observadas da mesma maneira, resultando
em comportamento adequado.

### Controle

A verificação do funcionamento do controle pode ser realizada pela
observação dos sinais de saída em resposta à instruções simuladas pelo
testbench do componente. Observamos que a saída dos sinais de controle em cada
estado é condizente com os sinais indicados pela máquina de estados finitos
estabelecida no projeto do controle - que por sua vez é condizente com livro do
Harris.

O caso específico avaliado no testbench é o processamento de uma instrução de
branch.

![controletb](imagens/controle_tb.png?raw=true)

### Integração Datapath + Controle - CPU

A verificação da integração entre datapath e controle, isso é, da CPU de fato,
pode ser realizada pela observação do comportamento dos sinais internos do
componente [riscv](riscv.vhd) durante seu [testbench](tb_riscv.vhd).

Nesse teste executamos o seguinte programa.

```
addi x1, x0, 1
addi x3, x0, 860
add x3, x3, x1
sw x3, 0(x0)
lw x3, 0(x0)
```

Correspondendo às seguintes instruções.

```
00000000000100000000000010010011
00110101110000000000000010010011
00000000000000011000000110110011
00000000000000000010001110100011
00000000000000000010000110000011
```

Podemos averiguar o comportamento esperado analisando inicialmente os
sinais fundamentais do testbech: o valor de PC e o fluxo de instruções.
Obsevamos pela imagem abaixo que o PC é incrementado como esperado e as
instruções são lidas corretamente.


![integracaotb1](imagens/integracao_tb_1.png?raw=true)

Um teste mais detalhado é realizado nas seguintes imagens, onde inicialmente
conseguimos observar a progressão apropriada de estados da controladora e por
fim o resultado do programa com o dado 8611 no registrador x3.

![integracaotb2](imagens/integracao_tb_2.png?raw=true)

![integracaotb3](imagens/integracao_tb_3.png?raw=true)

### Controladora de Interrupções

A controladora de interrupções foi implementada de forma simplificada, com
ordem de prioridade constante - e portanto ausência de FIFO.

A controladora foi montada a partir de cinco componentes - um registrador
responsável por armazenar o endereço da instrução anterior à ocorrência de uma
interrupção (RAR), um registrador responsável por indicar quais interrupções
estão habilitadas (IER), uma *look up table* responsável por traduzir
requisições de interrupções em endereços de memória da ISR correspondente.

As simplificações empregadas foram a remoção completa da FIFO - justificável
uma vez que a ordem de prioridade é fixa - e a remoção da dinâmica de dupla
indireção na determinação do endereço do ISR. Nessa última simplificação a
controladora armazena endereços das ISRs diretamente ao invés de endereços de
endereços da ISR. Isso foi feito com intuito de simplificar o projeto e pelo
fato da camada adicional de indireção não ser tão necessária nesse contexto -
onde o posicionamento das ISRs pode ser mantido constante.

A parte central da controladora é o [módulo de resolução de prioridades](componentes),
fornecido pelo professor. Esse componente resolve prioridade em um vetor
binário filtrando a entrada para produzir uma saída que prioriza o bit menos
significativo da entrada, sob ação de uma máscara que permite controlar quais
bits fazem parte desse processo. Esse componente recebe como entrada a saída
do registrador IER como a máscara do processo de priorização e o vetor de
requisição de interrupção como entrada de interrupção. A saída desse processo
é um vetor *one-hot* que indica qual interrupção será processada de acordo com
a posição do bit contendo 1. O componente natural para traduzir esse vetor em
um endereço para execução da ISR é uma loop up table que é implementada de
forma estática e puramente combinacional. Por fim a controladora possui o RAR,
responsável por armazenar o endereço de retorno ao programa executado antes da
ocorrência da interrupção. Esse registrador é lido e escrito, com escrita sendo
mediada pelo módulo de controle da CPU.

A verificação do funcionamento básico da controladora de interrupções pode
ser realizada analisando os sinais de seu [testbench](components/tb_interruption_handler.vhd).

Antes de analisar o testbench é interessante observar que seu comportamento
esperado é receber um vetor binário indicando ocorrência de uma interrupção e
retornar a ISR dessa instrução, como definida da *look up table*. A ocorrência
de duas interrupções simultâneas deve retornar a ISR de maior prioridade -
definida no nosso caso como a do timer.

Os sinais destacados na simulação abaixo, mencionados no parágrafo anterior,
permitem observar o funcionamento adequado do componente.

![handlertb](imagens/handler_tb.png?raw=true)

### Integração de Interrupções em Datapath

A integração da controladora de interrupções no datapath acontece por duas
simples mudanças. Inicialmente o multiplexador que determina o endereço de
entrada do PC é expandido de forma a incluir duas entradas: o endereço de uma
ISR e o endereço armazenada em no RAR. Além disso um nova instrução é
adicionada para retornar o fluxo de execução para o endereço armazenado no RAR.
Essa instrução é a última de cada ISR, intitulada `roi` (*return to original
instruction*), e realiza a simples ação de escrever o endereço contigo no RAR
no PC.

A simplicidade das mudanças não demanda um testbench próprio especialmente
considerando que o código foi escrito de forma a maximizar legibilidade.

### Integração de Interrupções em Controladora

Como já observado é necessário integrar alguma lógica de processamento de
interrupções na controladora porque o multiplexador responsável por determinar
o endereço de escrita no PC passa a ter mais entradas e é necessário decidir o
momento de escrita no registrador RAR, interno à controladora de interrupção.

Ambas alterações demandam a decisão de qual etapa do multiciclo preparar o
processador para o processamento da interrupção, isso, é armazenar a próxima
instruçaço no RAR e escrever o endereço da ISR no PC. Foi decidido que isso
deve ser feito imediamente antes do estado de fetch pelo fato de sua execução
resultar na propação da instrução presente no endereço armazenado no PC. Como
o processamento da controladora de interrupções é totalmente combinacional
a resolução da ISR é realizada dentro de um ciclo de clock e torna coerente a
decisão do momento de escrita nos registradores relevantes.

A inclusão desse detalhe foi simples - em cada estado que progride para fetch
em seguida foi realizada uma verificação de ocorrência de interrupção. Se
houver interrupção em processamento pela controladora as ações de escrita no
RAR e chaveamento de conteúdo de escrito no PC para a saída da controladora
são tomadas. A verificação do funcionamento da integração pode ser
realizado por um testbench incrementado do processador, que alimenta uma
interrupção como entrada e espera observar um chaveamento para o endereço
adequado da ISR correspondente. A interrupção alimentada foi `01`
correspondendo à timer e o endereço associado à ISR foi definido em
`000000011111`. Observamos nos sinais destacados abaixo que a integração da
controladora foi bem sucedida.

![integracaohandlertb](imagens/integracao_controladora.png?raw=true)

### Timer Básico

O temporizador básico é essencialmente um contador que dispara um sinal
ao valor de sua contagem atingir um valor inserido como entrada. Esse
periférico é testado no tesbench associado e a verificação de seu funcionamento
é prontamente realizado por inspeção da figura abaixo.

![timertb](imagens/timer_tb.png?raw=true)

### Timer Completo

O periférico temporizador completo foi implementado de forma mais simples do
que proposto no roteiro, sendo usado apenas como um temporizador e não um
contador. Nesse periférico o limite da contagem é armazenado em um registrador
a qual o usuário tem acesso.


### GPIO

### UART

### Integração de Periféricos

O processo de integração de periféricos é realizado instanciando componentes
adicionais, correspondendo aos periféricos, no testbench da CPU desenvolvida.
Em seguida o periférico provoca uma interrupção de alguma forma que é
encaminhada para a CPU que por sua vez processa a interrupção por meio da
controladora de interrupções.

### Integração de Periféricos - Timer Básico

A integração de um periférico consistindo de um timer básico foi realizada
como mencionado no parágrafo anterior. A provocação da interrupção no caso do
timer básico foi o sinal que indica que o contador interno atingiu o valor
limite informado pelo usuário.

Observamos na figura abaixo, extraída da simulação de integração
(tb_timer_riscv), que o fluxo de interrupção ocorre como desejado: após atingir
o limite estabelecido de pulsos de clock o timer envia um sinal de interrupção
para o processador que por meio da controladora de interrupções interpreta esse
sinal e atualiza o endereço do PC para a ISR correspondente, salvando enquanto
isso o valor do próximo endereço do PC no RAR, dentro da controladora. O
retorno do fluxo ao RAR é realizado por meio de uma instrução contida na RAR,
como explicado anteriormente.

![timerintegrationtb](imagens/timer_integration_tb.png?raw=true)

### Notas sobre integração de periféricos e interrupções

## Observações Finais
