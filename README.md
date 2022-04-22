# RISCV-multycicle

![riscv](https://img.shields.io/github/languages/top/gtLara/RISCV-multicycle?color=green&label=VHDL)![Itype](https://img.shields.io/badge/ISA-Itype-blueviolet)![Itype](https://img.shields.io/badge/ISA-Rtype-blueviolet)

Uma implementação experimental do conjunto de instruções RISC-V em multiciclo.
Desenvolvimento iniciado para matéria Laboratório e Arquitetura e Organização
de Computadores (ELT134) lecionada a nível de graduação na UFMG pelo professor
Ricardo Duarte do departamento de Engenharia Eletrônica.

## Datapath

![datapath](https://github.com/gtLara/RISCV-multicycle/blob/master/imagens/datapath.png)

## Componentes

Os componentes usados no caminho de dados são de autoria mista: dos
contribuidores do repositório e do professor Ricardo Duarte. A inclusão dos
componentes de autoria própria foi realizada ao ter dificuldade de compreender
e desenvolver em torno dos componentes pré-existentes, especialmente as
memórias.

## Controle

Os sinais de controle são alimentados ao processador externamente via
testbench, por enquanto. Variação dos sinais de controle podem ser aferidas no
arquito [riscvtb](https://github.com/gtLara/RISCV-multicycle/blob/master/tb_riscv.vhd).

## Simulações

As simulações realizadas até então são simples: constam apenas as propagação
apropriada de sinais no datapath e verificação de funcionamento da instrução
`lw`. A seguinte imagem apresenta a execução da instrução

`lw x4, 4(3)`

montada para binário em

00000000010000011010111110000011

![lw](https://github.com/gtLara/RISCV-multicycle/blob/master/imagens/simulacao_simples_lw.png)

Observamos na figura que o resultado da ULA está como esperado e a leitura do
contador de programas também, assim como o parsing das instruções e os sinais
de controle.
