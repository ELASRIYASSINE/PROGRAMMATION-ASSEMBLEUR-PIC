			list p=16f84A
			#INCLUDE P16F84A.inc
			
			C1 equ 0x0C
			T1 equ 0x0D
			T2 equ 0x0E
			T3 equ 0x0F
		
			ORG 0
main		bsf STATUS,RP0
			clrf TRISB
			bcf STATUS,RP0

loop 		movf C1,w
			andlw 0x0F
			call TEMPO
			movwf PORTB
			movlw 4
			call TEMPO
			incf C1,1
			goto loop

			;ORG 4
			;clrf INTCON
			;retfie
bcd7seg
			addwf PCL,1
			retlw 0x40
			retlw 0x79
			retlw 0x24
			retlw 0x30
			retlw 0x19
			retlw 0x12
			retlw 0x02
			retlw 0x78
			retlw 0x00
			retlw 0x10
			retlw 0x08
			retlw 0x03
			retlw 0x46
			retlw 0x21
			retlw 0x06
			retlw 0x0E

TEMPO 		movlw T3
bcltmp		decfsz T1,F
			goto bcltmp
			decfsz T2,F
			goto bcltmp
			decfsz T3,F
			goto bcltmp
			return

			end