/* Prelaboratorio03.asm
 Created: 17/02/2025 19:14:44
 Author : Gerardo Avila
 Descripcion: Contador de incremento y decremento con interrupciones
*/

//Encabezado (Definicion de registros, variables y constantes)
.include "M328PDEF.inc"

.cseg
			//Direccion de vectores
.org		0x0000			//RESET
	JMP			INICIO
.org		PCI0addr
	JMP			ISR_PCINT
.org		OVF0addr
	JMP			ISR_TMR0
.def		CONT = R20

//Configuracion de la pila
INICIO:
	LDI			R16, LOW(RAMEND)
	OUT			SPL, R16
	LDI			R16, HIGH(RAMEND)
	OUT			SPH, R16

//Tabla de Display
T7S:			.DB		0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x67

//----------------------------------------------------------------------------//
//Configuracion de SETUP
SETUP:
	CLI									//Desabilitamos interrupciones globales
//Desabilitamos comunicacion serial
	LDI			R16, 0x00
	STS			UCSR0B, R16

//Configuracion de oscilador externo
	LDI			R16, (1 << CLKPCE)
	STS			CLKPR, R16
	LDI			R16, 0b00000010			//Prescaler a 4 => 4MHz	
	STS			CLKPR, R16

//Iniciamos el TMR0
	LDI			R16, (1 << CS02)
	OUT			TCCR0B, R16
	LDI			R18, 100
	OUT			TCNT0, R18

//Habilitamos interrupcion de TMR0
	LDI			R16, (1 << TOIE0)
	STS			TIMSK0, R16

//Configuracion registro de Pin Change
	LDI			R16, (1 << PCIE0)
	STS			PCICR, R16
	LDI			R16, (1 << PCINT0) | (1 << PCINT1)
	STS			PCMSK0, R16

//Configuracion de entradas/salidas
	//Contador binario/transistores
	LDI			R16, 0xFF
	OUT			DDRC, R16
	LDI			R16, 0x00
	OUT			PORTC, R16
	//BOTONES
	LDI			R17, 0x00
	OUT			DDRB, R17
	LDI			R17, 0b00000011
	OUT			PORTB, R17
	//Display
	LDI			R16, 0xFF
	OUT			DDRD, R16
	LDI			R16, 0x00
	OUT			PORTD, R16

//Cargar tabla de display de siete segmentos
	LDI			ZL, LOW(T7S << 1)
	LDI			ZH, HIGH(T7S << 1)
	LPM			R22, Z
	OUT			PORTD, R22

//Configuracion de registros
	LDI			R16, 0x00
	LDI			R17, 0x00
	LDI			R18, 0b00000011
	LDI			R19, 0x00
	LDI			CONT, 0x00
	LDI			R21, 0x00
	LDI			R23, 0x00

//Transistores
	SBI			PORTC, PC4
	SBI			PORTC, PC5

	SEI										//Habilitar interrupciones globales


//---------------------------------------------------------------------------//
//LOOP
//---------------------------------------------------------------------------//
MAIN:
	CPI			CONT, 100
	BRNE		MAIN
	CLR			CONT
	RCALL		INCREMENTO_DISPLAY
	RJMP		MAIN

//----------------------------------------------------------------------//
//Sub rutinas
//---------------------------------------------------------------------//

INCREMENTO_DISPLAY:
	INC			R21
	CPI			R21, 10
	BRNE		ACTUALIZAR
	CLR			R21

	INC			R27
	CPI			R27, 6
	BRNE		ACTUALIZAR
	CLR			R27
	//RJMP		ACTUALIZAR

ACTUALIZAR:
	LDI			ZL, LOW(T7S << 1)
	LDI			ZH, HIGH(T7S << 1)
	ADD			ZL, R21
	LPM			R22, Z

	SBI			PORTC, PC4
	CBI			PORTC, PC5
	OUT			PORTD, R22
	CALL		WAIT_DISPLAY

	LDI			ZL, LOW(T7S << 1)
	LDI			ZH, HIGH(T7S << 1)
	ADD			ZL, R27
	LPM			R22, Z

	SBI			PORTC, PC5
	CBI			PORTC, PC4
	OUT			PORTD, R22
	CALL		WAIT_DISPLAY

	RET	

INCREMENTAR:
	INC			R24
	ANDI		R24, 0x0F
	OUT			PORTC, R24
	RET

DECREMENTAR:
	DEC			R24
	ANDI		R24, 0x0F
	OUT			PORTC, R24
	RET

WAIT:
	LDI		R25, 0			//Empieza la cuenta en 0
WAIT1:
	INC		R25				//Empieza el primer contador
	CPI		R25, 0			//Verificamos que la cuenta terminó
	BRNE	WAIT1			//Si la cuenta no ha terminado que siga contando
	LDI		R25, 0			//De haber terminado, volver a cargar 0
WAIT2:
	INC		R25				
	CPI		R25, 0			
	BRNE	WAIT2
	LDI		R25, 0
WAIT3:
	INC		R25				
	CPI		R25, 0			
	BRNE	WAIT3			
	LDI		R25, 0
WAIT4:
	INC		R25				
	CPI		R25, 0			
	BRNE	WAIT4			
	LDI		R25, 0
WAIT5:
	INC		R25				
	CPI		R25, 0			
	BRNE	WAIT5			
	LDI		R25, 0
WAIT6:
	INC		R25				
	CPI		R25, 0			
	BRNE	WAIT6			
	LDI		R25, 0
WAIT7:
	INC		R25				
	CPI		R25, 0			
	BRNE	WAIT7			
	LDI		R25, 0
WAIT8:
	INC		R25				
	CPI		R25, 0			
	BRNE	WAIT8			
	LDI		R25, 0
WAIT9:
	INC		R25				
	CPI		R25, 0			
	BRNE	WAIT9			
	LDI		R25, 0
WAIT10:
	INC		R25				
	CPI		R25, 0			
	BRNE	WAIT10			
	RET						//Regresamos a MAIN

WAIT_DISPLAY:
	LDI			R30, 1
WAIT1_D:
	LDI			R28, 255
WAIT2_D:
	LDI			R29, 255
WAIT3_D:
	DEC			R29
	BRNE		WAIT3_D
	DEC			R28
	BRNE		WAIT2_D
	DEC			R30
	BRNE		WAIT1_D
	RET

//--------------------------------------------------------------------//
//Rutinas de Interrupcion
//--------------------------------------------------------------------//

ISR_TMR0:
	PUSH		R19
	IN			R19, SREG
	PUSH		R19

	SBI			TIFR0, TOV0
	LDI			R23, 100
	OUT			TCNT0, R23
	INC			CONT

	POP			R19
	OUT			SREG, R19
	POP			R19

	RETI
	
ISR_PCINT:
	PUSH		R26
	IN			R26, SREG
	PUSH		R26
	
	CALL		WAIT

	IN			R17, PINB
	CP			R17, R18
	BREQ		SALIR
	MOV			R18, R17

	SBRS		R17, 0
	CALL		INCREMENTAR
	SBRS		R17, 1
	CALL		DECREMENTAR

	LDI			R16, (1 << PCINT0) | (1 << PCINT1)
	STS			PCMSK0, R16
	
	SALIR:
	POP			R26
	OUT			SREG, R26
	POP			R26
	RETI

