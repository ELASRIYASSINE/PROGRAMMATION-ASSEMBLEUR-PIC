		list p=116f84A
		#include p16f84A.inc
		TIME  equ  0X10
		retard1      EQU        0x0C      
		retard2      EQU        0x0F      
	    compt        EQU        0X0E	
		;----------------------------------------------------------
		org  0X00
		goto START
		;-----------------------------------------------------------

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
		movlw 0X00
		movwf TRISA
		movlw  B'00000111'
		movwf  OPTION_REG
		bcf    STATUS,5
		movlw  B'10100000'
		movwf  INTCON
		movlw  8
		movwf  TIME
		movlw  B'00001111'
		movwf  PORTB
		

	
		movlw B'00001'
		movwf PORTA
A		RLF PORTA
		call tempo
 		GOTO A
interruption




;------------   Programme de temporisation    ---------------

          MOVLW  0xFF            
          MOVWF  retard1         
          MOVLW  0xFF            
          MOVWF  retard2         
tempo     DECFSZ retard1,F        
          GOTO  tempo              
          MOVLW 0xFF            
          MOVWF retard1         
          DECFSZ retard2,F       
          GOTO  tempo            
          RETURN                    
          END                           
