.EQU clock = 16000000															;Frecuencia del reloj
.EQU baud = 9600																;Numero de bits por segundo
.EQU UBRRvalue = clock/(baud * 16) - 1											;Calculamos el valor de UBRR

.ORG 0x0000																		;Posicion de memoria inicial
	JMP main															
		
.ORG 0X0032																		;Posicion de memoria donde se encuentran las interrupciones serial
	JMP USART0_reception_completed												;Saltamos a la funcion cuando se genere la interrupcion
//	JMP USART0_transmit_buffer_empty											;Saltamos a la funcion cuando se genere la interrupcion
//	JMP USART0_byte_transmitted													;Saltamos a la funcion cuando se genere la interrupcion

.ORG 0x0072

.dseg
	trigger: .BYTE 1	
	current_pos: .BYTE 1

.cseg
main:
	SER R16
	OUT DDRB, R16

	LDI R16, HIGH(RAMEND)														;Inicializamos la pila OBLIGATORIO si usamos interrupciones
	OUT SPH, R16
	LDI R16, LOW(RAMEND)
	OUT SPL, R16

	RCALL init_USART0															;Llamamos a la funcion para configurar USART
	SEI																			;Activamos el uso de interrupciones
	
	LDI R16, 90
	STS current_pos, R16

	SER R16
	OUT PORTB, R16
	CALL delay_1_5ms
	CLR R16
	OUT PORTB, R16
	CALL delay_19ms

	loop:
		LDS R17, trigger

		CPI R17, 97
		BREQ abrir

		CPI R17, 99
		BREQ cerrar

		RJMP seguir

		abrir:
			LDS R18, current_pos
			INC R18
			CPI R18, 180
			BREQ set_180
			STS current_pos, R18

			SER R17
			OUT PORTB, R17

			PUSH R18
			CALL delay_0_01ms
			POP R18

			CALL delay_0_5ms

			CLR R17
			OUT PORTB, R17
			CALL delay_19ms

			CLR R17
			STS trigger, R17

			RJMP seguir

		cerrar:
			LDS R18, current_pos
			DEC R18
			CPI R18, 0
			BREQ set_0
			STS current_pos, R18

			SER R17
			OUT PORTB, R17

			PUSH R18
			CALL delay_0_01ms
			POP R18

			CALL delay_0_5ms

			CLR R17
			OUT PORTB, R17
			CALL delay_19ms

			CLR R17
			STS trigger, R17

			RJMP seguir
	
		set_180:
			LDS R18, current_pos

			CPI R18, 180
			BRNE seguir

			LDI R18, 180
			STS current_pos, R18

			RJMP seguir

		set_0:
			LDS R18, current_pos
			CPI R18, 0
			BRNE seguir

			LDI R18, 0
			STS current_pos, R18

			RJMP seguir
		
		seguir:
			RJMP loop															;Saltamos a la etiqueta loop

/***************************************************

	Configuracion UART

***************************************************/

init_USART0:																	;Funcion para cargar el valor de UBRR
	PUSH R16
	LDI R16, LOW(UBRRvalue)														;Cogemos el valor bajo de la variable UBRRvalue
	STS UBRR0L, R16																;Cargamos el valor del byte bajo
	LDI R16, HIGH(UBRRvalue)													;Cogemos el valor alto de la variable UBRRvalue
	STS UBRR0H, R16																;Cargamos el valor del byte alto

	//Activamos la recepcion y transmision de datos
	LDI R16, (1 << RXEN0)|(0 << TXEN0)|(0 << UDRIE0)|(0 << TXCIE0)|(1 << RXCIE0)
	STS UCSR0B, R16																;Asignamos al registro UCSR0B los bits establecidos
	LDI R16, (0 << UMSEL00)|(1 << UCSZ01)|(1 << UCSZ00)|(0 << USBS0)|(0 << UPM01)|(0 << UPM00)
	STS UCSR0C, R16																;Asignamos al registro UCSR0C los bits establecidos				
	POP R16

	RET

//Función de atención a la interrupcion
USART0_reception_completed:
	PUSH R16
	IN R16, SREG																;Hacemos una copia del registro SREG OBLIGATORIO si se usan interrupciones
	PUSH R16
	
	LDS R16, UDR0																;Cogemos el byte recivido y hacemos algo con el

	//Procesamos el dato
	STS trigger, R16

	//Finalizamos la interrupcion
	POP R16
	OUT SREG, R16																;Restablecemos el registro SREG
	POP R16
	RETI																		;RETI equivale a RET pero utilizado en interrupciones

/***************************************************

		Funciones de delay

***************************************************/
delay_19ms:
	PUSH R18											;Copia de seguridad del R18
	PUSH R19											;Copia de seguridad del R19
	PUSH R20											;Copia de seguridad del R20

	; Assembly code auto-generated
	; by utility from Bret Mulvey
	; Delay 304 000 cycles
	; 19ms at 16 MHz

	ldi  r18, 2
	ldi  r19, 139
	ldi  r20, 204
	L1: 
		dec  r20
		brne L1
		dec  r19
		brne L1
		dec  r18
		brne L1
		
	POP R20												;Reestablecemos el valor de R20
	POP R19												;Reestablecemos el valor de R19
	POP R18												;Reestablecemos el valor de R18
	RET	

delay_0_5ms:
	PUSH R18
	PUSH R19

	; Assembly code auto-generated
	; by utility from Bret Mulvey
	; Delay 8 000 cycles
	; 500us at 16 MHz

		ldi  r18, 11
		ldi  r19, 99
	L2: 
		dec  r19
		brne L2
		dec  r18
		brne L2

	POP R19
	POP R18

	RET

delay_0_01ms:
	
	PUSH YH															;Copia de seguridad del registro YH
	PUSH YL															;Copia de seguridad del registro YL
	IN YL, SPL														
	IN YH, SPH														
	PUSH R0															;Copia de seguridad del registro R0
	

	PUSH R18														;Copia de seguridad del registro 18													;Copia de seguridad del registro 22
	
	LDD R0, Y + 5													;Guardamos en el R0 el valor que haya en la pila desde Y + 5

repeticiones:
		; Assembly code auto-generated
		; by utility from Bret Mulvey
		; Delay 160 cycles
		; 10us at 16 MHz

			ldi  r18, 53
		L3: 
			dec  r18
			brne L3
			nop
	
	DEC R0															;Decrementamos R0
	BRNE repeticiones												;Si no es cero vamos a repeticiones

	
	POP R18															;Restauración del registro 20
	POP R0															;Restauración del registro 0
	POP YL															;Restauración del registro YL
	POP YH															;Restauración del registro YH
	RET																;RET es el equivalente al return, antes deberemos de haber guardado el PC (Program Counter)	

delay_1_5ms:
	PUSH R18
	PUSH R19
	; Assembly code auto-generated
	; by utility from Bret Mulvey
	; Delay 24 000 cycles
	; 1ms 500us at 16 MHz

		ldi  r18, 32
		ldi  r19, 42
	L4: 
		dec  r19
		brne L4
		dec  r18
		brne L4
		nop

	POP R19
	POP R18
	RET
