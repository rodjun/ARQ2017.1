	processor 6502	;Diz para o compilador a arquitetura que estamos usando
	include "vcs.h"	;Arquivo com variaveis do atari pré nomeadas
	org $F000	;Diz para o compilador em qual região de memória o nosso programa deve ser executado
init
	SEI		;Desabilita os interrupts
	CLD		;Desabilita o modo decimal aritmetico
	LDX #$FF	;Coloca o valor hexadecimal FF no registrador X
	TXS		;Transfere esse valor (FF) para o stack pointer
	LDA #0		;Coloca o valor 0 no registrador A
clearmem
	STA 0,X		;Seta o byte de memória no local apontado pelo registrador X para 0
	DEX		;Decrementa o registrador X em 1
	BNE clearmem 	;Se X não for 0, volta para a tag clearmem
	LDA #$1E	;Coloca o valor hexadecimal 1E no registrador A (cor amarela no padrão NTSC)
	STA COLUBK	;Seta a cor do background para o valor do registrador A
mainloop
	LDA #2		;Para ativar o VSYNC, temos que setar o segundo bit, então carregamos o numero 2 no registrador A
	STA VSYNC	;Ativa o VSYNC e deixa ativado por 3 scanlines
	STA WSYNC	;1...
	STA WSYNC	;2...
	STA WSYNC	;3!
	LDA VBLANK	;Habilitamos o VBLANK aqui para reutilizar o registrador A que já contem o valor 2
	LDA #0		;Agora desativamos o VSYNC
	STA VSYNC	;Desabilitado!
	LDY #37		;37 linhas de VLANK, o emulador por algum motivo usa 34 como default
vblankwait
	JSR wait_y_lines;Chama a função que espera um certo numero de linhas contido no registrador Y
	STA VBLANK	;Quando o loop termina desabilitamos o vlblank
	LDY #192	;Agora é hora de esperar as 192 linhas "verdadeiras", o que realmente aparece na TV.
			;Como vamos apenas mostrar o background, não precisamos fazer nada nesse tempo, então
			;apenas esperamos 192 scanlines, da mesma maneira que esperamos o VBLANK
scanloop
	JSR wait_y_lines;Chama a função que espera um certo numero de linhas contido no registrado Y
	LDA #2		;Aqui já começa o overscan, as 30 linhas finais que não aparecem na imagem
	STA VBLANK	;Primeiramente habilitamos o VBLANK escrevendo um 2 na sua localização de memória
	LDY #30		;Depois carregamos o numero de linhas que vamos esperar e fazemos aquele mesmo loop pela 3a vez
overscanwait
	JSR wait_y_lines;Chama a... deu pra enteder já
	STY VBLANK	;Desativa o VBLANK, aparentemente não é necessario fazer isso pois o VSYNC do proximo frame
			;funciona normalmente com o VBLANK ativado, se retirarmos esse disable aqui e o enable no 
			;inicio do programa podemos economizar incriveis 4 ciclos de processamento!
	JMP mainloop	;De volta para o inicio
wait_y_lines
	STA WSYNC	;Espera uma linha
	DEY		;Decrementa o valor do registrador Y
	BNE wait_y_lines;Se o valor do registrador y não for zero continua no loop
	RTS		;Fim da função
	
	org $FFFC
	.word init
	.word init
