LIST p=pic18f4550     ;define el mirco a usar
#include p18f4550.inc ;que incluya las librerias del pic
CONFIG FOSC=XT_XT;PWRT = OFF, WDT=OFF LVP=OFF ;directivas del pic para operracion

;DEFINICION DE VARIABLES.
	CUENTA1 EQU 20H ;equ define la dierccion de la variable(localidad e memoria)las variables que usemos siempre a partir de 20h
	CUENTA2 EQU 21H
	CUENTA3 EQU 22H
	OPCION  EQU 23H ;OPCION DE LAS ROTAS AQUI SE GUARDA LO QUE SE LEE DEL PUERTO B
	
;CONSTANTES DEL PROGRAMA.
	F       EQU 1
	W       EQU 0
;ESPESIFICAMOS EL ORIGEN
	ORG 1000H 		;INICIA EN LA 00H DE LA 
	BSF STATUS,5 	;BANCO 1 (QUEREMOS PONER UN 1 EN UNA DE LAS BANDERAS)REGISTRO STATUS 
    MOVLW  00H		;MUEVE AL REGISTRO W LA LITERAL L QUE SERIA 00H O CERO HEXADECIMAL
	MOVWF TRISD  	;RD0 COMO SALIDA (TRISD ES EL REGISTRO QUE SIRVE PARA CONFIGURAR LAS SALIDAS O ENTRADAS DE LOS PUERTOS)
	BCF STATUS,5 	;BANCO 0

;CONFIGURACION DEL PUERTO D PARA LAS RESISTENCIAS DE PULL-UP
	MOVLW 0FFH		;
	MOVWF TRISB		;PUERTO B COMO ENTRASA
	BCF INTCON2,7	;RESISTENCIAS DE PULL-UP EN RB
	MOVLW 0FH
	MOVWF ADCON1	;BITS 0-4 DE RB DIGITAL
;	BANCO0
	
;************************************************MAIN***********************************************************************************
INICIO;ETIQUETA
	BCF STATUS,0	;LIMPIA EL BIT CERO DEL REGISTRO STATUS

	MOVF PORTB,W    ;MUEVE W<-F ESTO SIRVE PARA COMPARAR (ESTO SIRVE PARA LEER EL PUERTO B)
	MOVWF OPCION    ;GUARDA EL CONTENIDO EN LA VARIABLE OPCION QUE TUVIMOS QUE DECLARAR ARRIBA PARA ASIGNARLE UNA DIRECCION DE MEMORIA

;MENUS DE ROTAS---------------------------------------------------------------------------------------------------
OPCION1
	MOVLW 01H		;MOVEMOS UN 1 AL REGISTRO W 
	SUBWF OPCION,W	;AQUI HACEMOS UNA RESTA EN LA VARIABLE OPCION 
	BTFSC STATUS,2	;SI LA RESTA ES IGUAL A CERO EL BIT NUMERO TRES DEL REGISTRO STATUS SE PONE EN UNO SI NO ES ASI HACE SKIP A LA SIGUIENTE INSTRUCCION Y PASA A LA SIGUIENTE OPCION
	CALL ROTA1		;SI LA BANDERA SE PONE EN UNO EJECUTA EL ROTA CORRESPONDIENTE
OPCION2
	MOVLW 02H		 
	SUBWF OPCION,W	 
	BTFSC STATUS,2	
	CALL ROTA2

	GOTO INICIO

;ROTAS---------------------------------------------------------------------------------------------------------------
ROTA1
	BCF STATUS,0        ;NO SABEMOS SI EL CARRY EMPIEZA EN 0 EN UNO NOSOTROS O HACEMOS QUE EMPIECE EN 0
	MOVLW  03H          ;PONEMOS UN 01H EN EL REGISTRO W QUE SERIA EL ULTIMO BIT
    MOVWF PORTD			;LO QUE HAY EN EL REGISTRO W LO MOSTRAMOS EN EL PUERTO D
OTRAR1
;	CALL DELAY			;LLAMA A LA SUBRUTINA DE RETARDO
	RLCF PORTD			;FUNCION PARA ROTACION A LA IZQUIERDA DEL PUERTO D
	BTFSS STATUS,0	    ;QUIERO PROBAR EL BIT CERO DEL REGISTRO STATUS SI ESTA EN UNO QUE SERIA EL CARRY(CONDICION IF)
	GOTO OTRAR1			;CUANDO NO SE CUMPLE SE SALTA A LA ETIQUETA PERO CUANDO SE CUMPLE REGRESA AL INICIO
	BCF STATUS,0		;BORRA UN SOLO BIT DEL REGISTRO STATUS QUE SERIA EL BIT 0(CARRY
	RETURN        		

ROTA2
	BCF STATUS,0        ;NO SABEMOS SI EL CARRY EMPIEZA EN 0 EN UNO NOSOTROS O HACEMOS QUE EMPIECE EN 0
	MOVLW  0C0H          ;PONEMOS UN 80H EN EL REGISTRO W QUE SERIA EL ULTIMO BIT
    MOVWF PORTD			;LO QUE HAY EN EL REGISTRO W LO MOSTRAMOS EN EL PUERTO D
OTRAR2
;	CALL DELAY			;LLAMA A LA SUBRUTINA DE RETARDO
	RRCF PORTD			;FUNCION PARA ROTACION A LA DERECHA DEL PUERTO D
	BTFSS STATUS,0	    ;QUIERO PROBAR EL BIT CERO DEL REGISTRO STATUS SI ESTA EN UNO QUE SERIA EL CARRY SALTA LA SIGUENTE LINEA(CONDICION IF)
	GOTO OTRAR2			;CUANDO NO SE CUMPLE SE SALTA A LA ETIQUETA PERO CUANDO SE CUMPLE REGRESA AL INICIO
	BCF STATUS,0		;BORRA UN SOLO BIT DEL REGISTRO STATUS QUE SERIA EL BIT 0(CARRY
	RETURN


;-------------------------------------------------------------------------------------------------------------------
;**************************************************************************************************************************************
;SUBRUTINA HECHA CON 2 LAZOS ANIDADOS (DELAY)
DELAY MOVLW 3EH
	;RETURN  ;SOLO PARA PROBAR
	MOVWF CUENTA3

ACA3 MOVLW 0FFH      ;CARGA EL ACUMULADOR W CON EL VALOR DE FFH(255 DECIMAL)
	MOVWF CUENTA1    ;MUEVE EL CONTENIDO DEL ACUMULADOR A CUENTA 1

ACA1 MOVLW 0FFH
	MOVWF CUENTA2    ;CARGA CUENTA2 CON EL VALOR FFH(255 DECIMAL)

ACA DECFSZ CUENTA2,F ;DECREMENTA CUENTA2, GUARDAEL RESULTADO EN F(CUENTA2)Y SI ES CERO SE SALTA LA SIGUIENTE INSTRUCCION

	GOTO ACA         ;VUELVE A DECREMENTAR MIENTRAS CUENTA 2 NO SEA CERO

	DECFSZ CUENTA1,F ;SE DECREMENTA CUENTA1 CADA VEZ QUE CUENTA 2 LLEGA A CERO

	GOTO ACA1        ;MIENTRAS CUENTA1 NO LLEGUE A CERO RECARGA  CUENTA2 Y REPITE PORCESO
	
	DECFSZ CUENTA3;F
	GOTO ACA3
RETURN
;FIN DE LA SUBRUTINA DELAY(RETARDO)
;*******************************************************************************************************++
END