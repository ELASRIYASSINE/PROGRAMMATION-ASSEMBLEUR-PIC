		
;------------   Directive d' assemblage pour MPLAB   ---------------
			list	p=16f84A
			#include p16f84A.inc
;------------   Définition des constantes   ---------------
			#define inter1 0	   ; bouton 1   
			#define inter2 1	   ; bouton 2   
			#define inter3 2	   ; bouton RAZ   
			
            retard1      EQU        0x0C      
		    retard2      EQU        0x0F      
	        compt        EQU        0X0E	
		    TIME  equ  0X10	
			ORG 0
			org    0X04
		
INT			bcf    INTCON,T0IF
			decfsz TIME,f
			retfie
			CLRF   PORTA
			movlw  8
			movwf  TIME
			retfie
		
		 	bsf STATUS,RP0             
		 	clrf TRISB
			movlw 0x1F 
		 	movwf TRISA
			bcf STATUS,RP0
		
;------------   Programme principal   ---------------

debut		movlw B'00000010'		
			movwf PORTB


T3
			btfss PORTA,inter3      
		    goto T1
			clrf PORTB
			CLRF PORTA
			GOTO INT
			
		
		
T1			btfss PORTA,inter1      
		    goto T3
			movlw B'00000010'		
			movwf PORTB
			GOTO INT
			RETURN
            END                           
