;------   Exemple d'application avec un PIC : Une jeu de lumi�re programmable -------

; Titre : jeu de lumi�re
; Date : 01juillet 2000
; Auteur : P.MAYEUX
; PIC utilis� : PIC 16 F 84
; Ce montage d'initiation � base de PIC 16C84 permet de r�aliser un jeu de lumi�re programmable. 
; Selon les codes inscrits en E�PROM le montage r�alise une s�quence type.
; Chaque octet de l 'E�PROM permet de d�finir :

; 1 er octet : 
; quartet de poids fort = vitesse d'�x�cution ( 0 � F ) 0 = vitesse la + rapide
; quartet de poids faible = nombre de r�p�tition de chaque s�quence ( 1 � F soit 1 � 15 fois )

; 2 eme octet : 
; type de la  s�quence demand�e ( 00 � FF ) soit 256 types  de jeux diff�rents

; 0 = chennillard   ; 1 = chennillard altern�   ;  2 = chennillard 2 leds ; 
; 3 = chennillard 2 leds altern� ; 4 = led ext vers int�rieur ; 5 = ext -> int et int > ext
; 6 = chennillard 3 leds ; 7 = chennillard 3 leds altern�
; 8 = toutes les leds allum�es puis �teintes

;------------   Directive d' assemblage pour PLAB   ---------------

	list	p=16f84A
	#include p16f84A.inc
	__config H'3FF9'   
 			
;------------   D�finition des registres temporaires   ---------------

retard1      EQU        0x0C      ; le registre temporaire retard1 pour la temporisation
retard2      EQU        0x0D      ; le registre temporaire retard2 pour la temporisation
retard3      EQU        0x0E      ; le registre temporaire retard2 pour la temporisation

adresse	     EQU	0x0F	  ; le registre adresse est � l'adresse 10
vitesse	     EQU  0x10
nbre_fois      EQU	0x11
type	     EQU	0x12
memo	     EQU	0x14
memo_ch	     EQU	0x15	  ; utilis� pour le chennillard
retour	     EQU	0x16	  ; utilis� pour le chennillard altern�

;------------   Mise en E�PROM des valeurs ---------------

	org H'2100'    			; Donn�es mise en EEPROM 
	DE  0x24,0x04,0x24,0x05		; 
	DE  0x15,0x00,0x14,0x01		; 
	DE  0x54,0x02,0x14,0x03		; 
	DE  0x14,0x04,0x14,0x05		; 
	DE  0x14,0x06,0x14,0x07		; 
	DE  0x14,0x06,0x14,0x08		; 
	
;------------   Init des ports A et B   ---------------

	ORG 0
	  
	bsf STATUS,5		; on met � 1 le 5eme bit du registre status pour acc�der
    				; � la 2eme page m�moire ( pour trisa et trisb )

	MOVLW B'00000000'     	; on met 00 dans le registre W
	MOVWF TRISB           	; on met 00 dans le port B il est programm� partiellement en sortie

	MOVLW 0x1F            	; on met 1F dans le registre W
	MOVWF TRISA           	; on met 00 dans le port A il est programm� en entr�e
	
	bcf STATUS,5		; on remet � 0 le 5eme bit du registre status pour acc�der	
				; � la 1eme page m�moire 

;------------------------   Init et RAZ  ---------------------------------
raz
	clrf adresse		; on met 00 dans le registre adresse
	clrf  PORTB                         ; on met 00 sur le port B 

init
        MOVLW  0x01                            ; on met 1 dans le registre W
	movwf memo		; on met memo � 1
	movwf memo_ch
        MOVLW  0x40                            ; on met 40 dans le registre W
	movwf retour		; on met retour � 40 ( 0100 0000 ) retour chennillard altern�

	clrf vitesse	     
	clrf nbre_fois    
	clrf type	     

	MOVF  adresse, W               ; on met adresse dans W
	SUBLW 0x3E	              ; W - 3E -> W 
	BTFSC STATUS,2		; on teste le bit Z si Z=0 on saute la prochaine instruction	
	goto raz

;---------------------- lecture E�PROM et r�cup�ration des param�tres ---------------------------

	 call lecture
	 movwf type	              ; on sauvegarde w dans type
	 andlw 0xF0		; masque w pour avoir la vitesse ( W & 1111 0000 )	 
	 movwf vitesse		; on r�cup�re la vitesse d' �x�cution
	 swapf vitesse,F
	 movf type,W		; on recharge W avec type
	 andlw 0x0F		; masque w pour avoir le nombre de r�p�tition ( W & 0000 1111 )	 
	 movwf nbre_fois	              ; on r�cup�re le nombre de r�p�tition demand�

	 call lecture
	 movwf type	              ; on sauvegarde w dans type ( jeu de lumi�re demand� ) 


;--------------------   Programme principal   ----------------------

debut 
	 
	 BTFSS PORTA,0		; on teste le bit RAO si = 1 on saute la prochaine instruction	
	 goto debut		; bouton marche


	 SUBLW 0x00	              ; W - 0 -> W 
	 BTFSC STATUS,2		; on teste le bit Z si Z=0 on saute la prochaine instruction	
	 GOTO chenn		; chennillard
	 movf type,W		; on remet type dans W
 
	 SUBLW 0x01	              ; W - 1 -> W 
	 BTFSC STATUS,2		; on teste le bit Z si Z=0 on saute la prochaine instruction	
	 GOTO ch_alt		; chennillard altern�

; si double chennillard ou double altern�

               MOVLW  0x03                    ; on met 3 dans le registre W
	 movwf memo_ch
	 movwf memo		; on met 3 dans memo
               MOVLW  0xC0                     ; on met C0 dans le registre W
	 movwf retour		; on met retour � C0 ( 1100 0000 ) retour chennillard altern�

	 movf type,W		; on remet type dans W

	 SUBLW 0x02	              ; W - 2 -> W 
	 BTFSC STATUS,2		; on teste le bit Z si Z=0 on saute la prochaine instruction	
	 GOTO chenn		; double chennillard 
	 movf type,W		; on remet type dans W

	 SUBLW 0x03	              ; W - 3 -> W 
	 BTFSC STATUS,2		; on teste le bit Z si Z=0 on saute la prochaine instruction	
	 GOTO ch_alt		; double chennillard altern�
	 movf type,W		; on remet type dans W

	 SUBLW 0x04	        
	 BTFSC STATUS,2		; on teste le bit Z si Z=0 on saute la prochaine instruction	
	 GOTO ext_int		; ext�rieur vers int�rieur
	 movf type,W		; on remet type dans W

	 SUBLW 0x05	        
	 BTFSC STATUS,2		; on teste le bit Z si Z=0 on saute la prochaine instruction	
	 GOTO ext_int_alt	              ; ext�rieur vers int�rieur et int�rieur vers ext�rieur
	 movf type,W		; on remet type dans W

; si triple chennillard ou triple altern�

               MOVLW  0x07                    ; on met 7 dans le registre W (0000 0111)
	 movwf memo_ch
	 movwf memo		; on met 3 dans memo
               MOVLW  0xE0                    ; on met 0E dans le registre W
	 movwf retour		; on met retour � E0 ( 1110 0000 ) retour chennillard altern�

	 movf type,W		; on remet type dans W

	 SUBLW 0x06	        
	 BTFSC STATUS,2		; on teste le bit Z si Z=0 on saute la prochaine instruction	
	 GOTO chenn		; triple chennillard 
	 movf type,W		; on remet type dans W

	 SUBLW 0x07	        
	 BTFSC STATUS,2		; on teste le bit Z si Z=0 on saute la prochaine instruction	
	 GOTO ch_alt		; triple chennillard altern�
	 movf type,W		; on remet type dans W

	 SUBLW 0x08	        
	 BTFSC STATUS,2		; on teste le bit Z si Z=0 on saute la prochaine instruction	
	 GOTO allume		; toutes les leds allum�es 
	 movf type,W		; on remet type dans W


	 GOTO init

;------------   chennillard   ---------------

chenn

	movf memo_ch, W
	movwf memo
che
	movf memo,W		; on met memo dans W
	movwf PORTB		; on met W sur le port B ( leds )
	CALL  tempo                        ; on appel la temporisation 
	bcf STATUS,0		; on met la carry � 0
	RLF memo, F		; rotation � gauche du registre memo
	BTFSS STATUS,0		; on teste le bit C si C=0 on saute la prochaine instruction		
	call che
	
              MOVLW  0x01                     ; on met 1 dans le registre W
	SUBWF nbre_fois, F             ; Nbre_fois - 1 -> nbre_fois 
	BTFSS STATUS,2		; on teste le bit Z si Z=1 on saute la prochaine instruction		
	goto chenn
	goto init                              ; retour � init

;------------   chennillard altern�  ---------------
gauche
	movf memo_ch, W
	movwf memo
ch_alt

	movf memo,W		; on met memo dans W
	movwf PORTB		; on met W sur le port B ( leds )
	CALL  tempo                        ; on appel la temporisation 

	bcf STATUS,0		; on met la carry � 0
	RLF memo, F		; rotation � gauche du registre memo
	BTFSC STATUS,0		; on teste le bit C si C=0 on saute la prochaine instruction		
	call droite
	goto ch_alt

droite 
	movf retour, W
	movwf memo
drt
	movf memo,W		; on met memo dans W
	movwf PORTB		; on met W sur le port B ( leds )
	CALL  tempo                        ; on appel la temporisation 

	bcf STATUS,0		; on met la carry � 0
	RRF memo, F		; rotation � droite du registre memo
	BTFSC STATUS,0		; on teste le bit Z si Z=0 on saute la prochaine instruction		
	goto decrement
	goto drt

decrement
             
              MOVLW  0x01                     ; on met 1 dans le registre W
	SUBWF nbre_fois, F             ; Nbre_fois - 1 -> nbre_fois 
	BTFSC STATUS,2		; on teste le bit Z si Z=1 on saute la prochaine instruction		
	goto init
	goto gauche	              ; retour � gauche

;------------   Exr�rieur vers int�rieur ->> <<-  ---------------

ext_int

              MOVLW  b'10000001'      ; on met 81 dans le registre W
	call affiche
        
	MOVLW  b'01000010'      ; on met 42 dans le registre W
	call affiche
 
              MOVLW  b'00100100'      ; on met 24 dans le registre W
	call affiche
 	
              MOVLW  b'00011000'      ; on met 18 dans le registre W
	call affiche
 
              MOVLW  0x01                ; on met 1 dans le registre W
	SUBWF nbre_fois, F       ; Nbre_fois - 1 -> nbre_fois 
	BTFSC STATUS,2	        ; on teste le bit Z si Z=1 on saute la prochaine instruction		
	goto init
	goto ext_int	        ; retour ext_int

;------------   Ext�rieur vers int�rieur et int�rieur vers ext�rieur  ---------------

ext_int_alt

              MOVLW  b'10000001'      ; on met 81 dans le registre W
	call affiche
        
	MOVLW  b'01000010'      ; on met 42 dans le registre W
	call affiche
 
              MOVLW  b'00100100'      ; on met 24 dans le registre W
	call affiche
 	
              MOVLW  b'00011000'      ; on met 18 dans le registre W
	call affiche
        
	MOVLW  b'00100100'      ; on met 24 dans le registre W
	call affiche

	MOVLW  b'01000010'      ; on met 42 dans le registre W
	call affiche

              MOVLW  b'10000001'       ; on met 81 dans le registre W
	call affiche
 
              MOVLW  0x01                 ; on met 1 dans le registre W
	SUBWF nbre_fois, F         ; Nbre_fois - 1 -> nbre_fois 
	BTFSC STATUS,2	           ; on teste le bit Z si Z=1 on saute la prochaine instruction		
	goto init
	goto ext_int_alt	          ; retour ext_int_alt


affiche
	movwf PORTB		; on met W sur le port B ( leds )
	CALL  tempo                        ; on appel la temporisation 
	return

;------------   Toutes les leds allum�es ---------------

allume

	movlw 0xff		; on met ff dans W
	movwf PORTB		; on met W sur le port B ( leds )
	CALL  tempo                        ; on appel la temporisation 
	clrf PORTB		; on etteind les leds
              call tempo

	MOVLW  0x01                      ; on met 1 dans le registre W
	SUBWF nbre_fois, F              ; Nbre_fois - 1 -> nbre_fois 
	BTFSC STATUS,2		; on teste le bit Z si Z=1 on saute la prochaine instruction		
	goto init
	goto allume	               ; retour � allume

;---------------------- lecture E�PROM ---------------------------

lecture

	 MOVF  adresse, W       ; on met adresse dans W
               MOVWF  EEADR          ; on met W sur EEADR ( adresse E�PROM )
	 bsf STATUS,5	       ; on met � 1 le 5eme bit du registre status pour acc�der
    			       ; � la 2eme page m�moire ( EECON1 )

               MOVLW 0x01               ; on met 01 dans le registre W
               MOVWF EECON1          ; on met 01 dans le registre EECON1
 	 bcf STATUS,5	       ; on remet � 0 le 5eme bit du registre status 
				
               MOVLW  0x01              ; on met 1 dans le registre W
               ADDWF adresse, F       ; on additionne adresse + 1       
               MOVF  EEDATA, W       ; on met la donn�e E�PROM dans W
	 return

;------------   Programme de temporisation   ---------------

tempo
	MOVLW 0xff            ; on met ff dans le registre W
	MOVWF retard1         ; on met W dans le registre retard1 
	MOVWF retard2         ; on met W dans le registre retard2 
	movf vitesse,W
	movwf retard3

attente

	DECFSZ retard1,F       ; on d�cr�mente retard1 et on saute la prochaine instruction si 
	GOTO  attente            ; le registre retard1 = 0 sinon retour � tempo

	movlw 0x50	     ; on recharge retard1 avec 50
	movwf retard1

	DECFSZ retard2,F       ; on d�cr�mente retard2 et on saute la prochaine instruction si 
	GOTO  attente            ; le registre retard2 = 0 sinon retour � tempo

	movlw 0xFF	     ; on recharge retard2
	movwf retard2

	DECFSZ retard3,F       ; on d�cr�mente retard3 et on saute la prochaine instruction si 
	GOTO  attente            ; le registre retard3 = 0 sinon retour � tempo
	  
	RETURN                     ; retour au programme principal apr�s l 'instruction CALL


	END
 






