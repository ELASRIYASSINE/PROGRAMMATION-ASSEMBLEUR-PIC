			liste p=16F84A
			# include P16F84A.INC
;...........................................
			BSF STATUS,RP0
			MOVLW B'11111001'
			MOVWF TRISB 
			MOVLW B'00011'
			MOVWF TRISA
			BSF STATUS,RP0
			CLRF PORTA
			CLRF PORTB
;..........................................
TEST		BTFSS PORTA,0
			GOTO TEST
			
			MOVLW 
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
