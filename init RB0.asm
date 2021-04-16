
                 LIST    p=16F84A 
                 #include "P16F84A.INC" 

;++++++++++++++++++++++++++++++++++  INITIALISATION   +++++++++++++++++++++++++++++++++++++++++++
		   retard1   		EQU  0X0C	  	 
		   retard2   		EQU  0X0D	  	 	
	  	   W_TEMP    		EQU  0X0E	  	;( contenu de W juste avant l'interruption).
		   STATUS_TEMP  	EQU  0X0F  	    ;( contenu de STATUS juste avant l'interruption).
		   compt   			EQU  0X1C	  	;( compteur).
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
           ORG    0X00			
           GOTO   DEBUT
;+++++++++++++++++++++++++++++++++   DEBUT DE L'INTERRUPTION  +++++++++++++++++++++++++++++++++++++++++++
           ORG     0X04						;  Début du programme d'interruption .
;++++++++++++++++++++++++++++++++++  SAUVEGARDE  +++++++++++++++++++++++++++++++++++++++++++++++++++++
SAUVEGARDE		
	
		   MOVWF   W_TEMP					;  W ---> W_TEMP .
		   SWAPF   STATUS , W				;  Inversion de 2 quartets de STATUS . le résultat est dans W .
		   MOVWF   STATUS_TEMP				;  W ---> STATUS_TEMP .  

;++++++++++++++++++++++++++++++++++  SOUSPROGRAMME D'INTRRUPTION 'compt = compt + 1'  +++++++++++++++++++++++++++++++++++++++++++++++++++ 
           INCF    compt
           MOVF    compt , 0 
           MOVWF   PORTA 
;++++++++++++++++++++++++++++++++++  RESTAURATION  ++++++++++++++++++++++++++++++++++++++++++++
RESTAURER		

		   SWAPF   STATUS_TEMP , W			;  Inversion de 2 quartets de STATUS_TEMP . le résultat est dans W .
		   MOVWF   STATUS					;  W ---> STATUS .
		   SWAPF   W_TEMP , F				;  Inversion de 2 quartets de W_TEMP . le résultat est dans W_TEMP .
		   SWAPF   W_TEMP , W				;  Inversion de 2 quartets de W_TEMP . le résultat est dans W .
	
	       BCF     INTCON , 1 	 			;  ( INTF = 0 ) --> Passage à la page 0 .
		   RETFIE							;  Fin de l'interruption .

;+++++++++++++++++++++++++++++++++  FIN DE L'INTERRUPTION   +++++++++++++++++++++++++++++++++++++++++

;++++++++++++++++++++++++++++++++   CONFIGURATION DES REGISTRES   +++++++++++++++++++++++++++++++++++++
DEBUT
           BSF     STATUS , RP0		;  ( RP0 = 1 ) --> Passage à la BANK 1 .
           MOVLW   B'00000001'		;  B'00000001' ---> W .
	       MOVWF   TRISB   			;  H'01' ---> TRISB : 
                                    ;     - le bit  RB0 du PORTB est configuré comme entrée .
                                    ;     - les bits RB7 à RB1 du PORTB sont configurés comme sorties ).
           CLRF   TRISA				;  le PORTA est configurés comme sorties .

	       MOVLW   B'11000000'		;  B'11000000' ---> W .
	  	   MOVWF   OPTION_REG		;  B'11000000' ---> OPTION_REG :
                                    ;     - INTEDG = 1 ---> Déclenchement sur front MONTANT ( BP ) .

	   	   MOVLW   B'10010000'	    ;  B'10010000' ---> W .
	       MOVWF   INTCON   		;  B'10010000' ---> INTCON  :
                                    ;     -  GIE  = 1 : Validation des INTERRUPTIONS .
                                    ;     -  INTE = 1 : Validation de l'interruption d'origine RB0 .
                                    ;     -  INTF = 0 : mise à zéro du flag (correspondant à RB0 ).

           BCF      STATUS , RP0 	;  ( RP0 = 0 ) --> Passage à la BANK 0 .

	       CLRF 	PORTA
		   CLRF 	PORTB

	       BSF      STATUS , C 		;  Met le bit C du registre STATUS à 1 .

;++++++++++++++++++++++++++++++++ PROGRAMME PRINCIPALE 'CLIGNOTEMENT DE LA LED'+++++++++++++++++++++++++++++++++++++++

LOOP       MOVLW   B'10000000'		
		   MOVWF   PORTB	    	;  ( RB7 = 1 ) --> LED  = 1 .            
		   CALL    TEMPO  		
		   MOVLW   B'00000000'		
		   MOVWF   PORTB			;  ( RB7 = 0 ) --> LED  = 0 .
		   CALL    TEMPO  		
		   GOTO    LOOP		

;+++++++++++++++++++++++++++++++  TEMPORISATION   ++++++++++++++++++++++++++++++++++++++++++
	      MOVLW  0xFF            
          MOVWF  retard1         
          MOVLW  0xFF            
          MOVWF  retard2         
TEMPO     DECFSZ retard1,F        
          GOTO  TEMPO              
          MOVLW 0xFF            
          MOVWF retard1         
          DECFSZ retard2,F       
          GOTO  TEMPO            
          RETURN                    
          END                           
