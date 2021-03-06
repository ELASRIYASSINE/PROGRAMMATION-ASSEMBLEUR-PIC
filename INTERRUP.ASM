
;-----   Application avec un PIC : Gestion d'une interruption sur RB0 ------
; Titre : Interruption sur RB0
; Date : 31 Janvier 2002
; Auteur : P.M
; PIC utilis� : PIC 16 F 84
; Ce montage d'initiation � base de PIC 16F84 permet de tester le d�roulement d 'une
; interruption. Lorsque la broche RB0 passe de 0 � 1 ( front montant ) alors on g�n�re
; une IT , on allume une led ( RB7 ) et apr�s une temporisation on �teint celle-ci. 
; Une prochaine action sur RB0 red�clenche l ' IT


;------------   Directive d' assemblage pour PLAB   --- -
	
	list p=16f84A
 	#include p16f84A.inc
 	__config H'3FF9'

;**** Le programme pricipal commence � l ' �tiquette init ******
	
	ORG 0
	goto init

;**** Le programme d' interruption se d�clenche lorsque l' entr�e RB0 passe de 0 � 1 ***
	
	ORG 4

;*********** Programme d 'interruption **********************

	bsf PORTB,7            	; on allume la led connect�e sur rb7

;------------  temporisation   ---------------

tempo2
	MOVLW 0xFF            ; on met ff dans le registre W
	MOVWF retard1         ; on met W dans le registre retard1 
	MOVWF retard2         ; on met W dans le registre retard2 
	MOVLW 0x07            ; on met 7 dans le registre W
	MOVWF retard3         ; on met W dans le registre retard3 

attente2

	DECFSZ retard1,F       ; on d�cr�mente retard1 et on saute la prochaine instruction si 
	GOTO  attente2         ; le registre retard1 = 0 sinon retour � tempo

	movlw 0xFF		; on recharge retard1
	movwf retard1

	DECFSZ retard2,F       ; on d�cr�mente retard2 et on saute la prochaine instruction si 
	GOTO  attente2         ; le registre retard2 = 0 sinon retour � tempo

	movlw 0xFF		; on recharge retard2
	movwf retard2

	DECFSZ retard3,F       ; on d�cr�mente retard3 et on saute la prochaine instruction si 
	GOTO  attente2         ; le registre retard3 = 0 sinon retour � tempo

	bcf PORTB,7            	; on �teint la led connect�e sur rb7
	bcf INTCON,INTF  	; on remet � 0 le bit du registre d' IT qui est pass� � 1

	RETFIE                  ; retour d 'interruption

;************* Programme d' INIT **************************
init

retard1      EQU        0x0C      ; le registre temporaire retard1 se trouve � l' adresse 0C
retard2      EQU        0x0F      ; le registre temporaire retard2 se trouve � l' adresse 0F
retard3      EQU        0x0E      ; le registre temporaire retard3 se trouve � l' adresse 0F


 	bsf STATUS,5               ; on met � 1 le 5eme bit du registre status pour acc�der
 	                           ; � la 2eme page m�moire ( pour configurer trisa et trisb
                                   ; -> broches en entr�e ou en sortie )

 	MOVLW B'00000001'  	   ; rb0, en entr�e ( rb0 sera la broche utilis�e
                                   ; pour l ' interruption )
 	MOVWF TRISB 
	
	bcf STATUS,5               ; on remet � 0 le 5eme bit du registre status pour acc�der
                                   ; � la 1ere page m�moire
 	bsf OPTION_REG,INTEDG      ; Le passage de 0 � 1 sur RB0 provoque une IT
                                   ; sur un  front montant ( choix du front sur RB0 )

	bsf INTCON,INTE            ; autorise l ' IT sur RB0
	bsf INTCON,GIE             ; autorise les Interruptions
	clrf PORTB

;************ Programme principal en rebouclage *********************

debut
	sleep                 ; mise en sommeil du PIC conso : 3.2 mA, attente impulsion sur RB0
	GOTO debut

;*********** Fin du programme ***********

	end
