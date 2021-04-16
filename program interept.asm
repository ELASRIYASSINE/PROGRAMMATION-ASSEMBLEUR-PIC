
;------------   Directive d' assemblage pour MPLAB   ---------------

 		  list	p=16f84A
		  #include p16f84A.inc
;------------   Définition des constantes   ---------------

		  #define inter0 0	   ; bouton marche

		  retard1      EQU        0x0C      
		  retard2      EQU        0x0D      
	      compt        EQU        0X0E
		  Int1Context  EQU        0X0F
		  Int1BContext EQU        0x1C
ORG 0x00 
	GOTO	START
	ORG 0x04
	MOVWF Int1Context
	SWAPF STATUS, W
	BCF STATUS, RP0
	MOVWF Int1BContext
	SWAPF PCLATH, W
	MOVWF Int1BContext+D'1'
	SWAPF FSR, W
	MOVWF Int1BContext+D'2'
	BCF PCLATH,3
	BCF PCLATH,4
	GOTO	interrupt
;------------   Programme principal   ---------------
START		 
		  bsf STATUS,RP0             
 		  clrf TRISB
		  movlw 0x1F 
 		  movwf TRISA
		  bcf STATUS,RP0
DEBUT

          btfss PORTA,inter0      
          goto DEBUT		

	 	  clrf PORTB	    
MAIN1	  INCF compt,f		
		  MOVF compt,w
		  SUBLW 0X09
		  MOVF compt,w
		  movwf PORTB
		  call tempo
		  BTFSS STATUS,Z
		  GOTO MAIN1
MAIN2	  DECF compt,f
		  MOVF compt,w
		  MOVWF PORTB
		  CALL tempo
		  BTFSC STATUS,RP0
		  GOTO MAIN2
          GOTO MAIN1
                 
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


interrupt
; { interrupt ; function begin
	BCF STATUS, RP0
	SWAPF Int1BContext+D'2', W
	MOVWF FSR
	SWAPF Int1BContext+D'1', W
	MOVWF PCLATH
	SWAPF Int1BContext, W
	MOVWF STATUS
	SWAPF Int1Context, F
	SWAPF Int1Context, W
	RETFIE
; } interrupt function end

	      RETURN                    
          END                           

