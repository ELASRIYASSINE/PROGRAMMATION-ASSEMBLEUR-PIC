		list p=116f84A
		#include p16f84A.inc
		Time  equ  0X00
		----------------------------------------------------------
		org  0X00
		goto START
		-----------------------------------------------------------
		org    0X04
		bcf    INTCON,T0IF
		decfsz TIME,f
		retfie
		comf   PORTB
		movlw  8
		movwf  TIME
		retfie
START   bsf    STATUS,RP0
		clrf   TRISB
		movlw  B'00000111'
		movwf  OPTION_REG
		bcf    STATUS,5
		movlw  B'10100000'
		movwf  INTCON
		movlw  8
		movwf  TIME
		movlw  B'00001111'
		movwf  PORTB
Loop    goto   Loop
interruption
        end