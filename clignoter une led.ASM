 		  list	p=16f84A
		  #include p16f84A.inc
       	  TIME   EQU  0x10      
		  ORG 0
		  GOTO START
		  ORG 4
	  	  BCF INTCON,T0IF
		  DECFSZ TIME,F
		  RETFIE
		  COMF PORTB
		  MOVLW 8
		  MOVWF TIME
		  RETFIE


START 	  bsf STATUS,RP0             
 		  clrf TRISB
		  movlw B'00000111'
 		  movwf OPTION_REG
		  bcf STATUS,RP0
		  movlw B'10100000'
		  movwf INTCON
		  movlw 8
		  movwf TIME
		  movlw B'00001111'
		  movwf PORTB
LOOP	  GOTO LOOP
interruption 
		  end

