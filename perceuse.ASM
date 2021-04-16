;------------   Directive d' assemblage pour MPLAB   ---------------

 		  list	p=16f84A
		  #include p16f84A.inc
;------------   Définition des constantes   ---------------

		    retard1      EQU        0x0C      
		    retard2      EQU        0x0F      
	        compt        EQU        0X0E	
		    ORG 0

 		    bsf STATUS,RP0             
 		    clrf TRISB
		    movlw 0x1F 
 		    movwf TRISA
		    bcf STATUS,RP0

;------------   Programme principal   ---------------
			CLRF PORTB
DCY

            btfss PORTA,1      
            goto DCY		
		
		    MOVLW 0X13
			MOVFW PORTB
DES			BTFSS PORTA,0
			GOTO DES
  	        MOVLW 0X1C
			MOVWF PORTB            
MONT		BTFSS PORTA,3
			GOTO MONT
			BTFSS PORTA,2
			GOTO A
			GOTO DCY   
A           RETURN                    
            END                           
