
;------------   Directive d' assemblage pour MPLAB   ---------------

 		  list	p=16f84A
		  #include p16f84A.inc
;------------   Définition des constantes   ---------------

		  #define inter0 0	   ; bouton marche

		  retard1      EQU        0x0C      
		  retard2      EQU        0x0F      
	      compt        EQU        0X0E
		  TEMP 		   EQU        0X0D	
		  ORG 0

;------------   Programme principal   ---------------		 
		  bsf STATUS,RP0             
 		  clrf TRISB
		  movlw 0x1F 
 		  movwf TRISA
		  bcf STATUS,RP0

MAIN2	  clrf PORTB
TEST      btfss PORTA,inter0      
          goto TEST		
	    
MAIN1	  INCF compt,f
		  call tempo		
		  MOVF compt,w
		  MOVWF PORTB
		  SUBLW 0X09
		  BTFSS STATUS,Z
		  GOTO MAIN1
          GOTO MAIN2
                 
;------------   Programme de temporisation    ---------------

          MOVLW  0x1F            
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
