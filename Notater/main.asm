#include "p16f1829.inc"
 __CONFIG _CONFIG1, _FOSC_INTOSC & _WDTE_SWDTEN & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_ON & _CLKOUTEN_OFF & _IESO_ON & _FCMEN_ON
 __CONFIG _CONFIG2, _WRT_OFF & _PLLEN_ON & _STVREN_ON & _BORV_LO & _LVP_OFF

; latch for 4 digital inputs, pollable with serial output of latched value
; RC0:3 is new value, rc0 MUST change for a new value to be accepted.

; the chip:
; RA0 - pin 19 - ICSPDAT - 
; RA1 - pin 18 - ICSPCLK - 
; RA2 - pin 17 - INT
; RA3 - pin  4 - Vpp     -
; RA4 - pin  3 -
; RA5 - pin  2 -

; RB4 - pin 13
; RB5 - pin 12 - RX
; RB6 - pin 11
; RB7 - pin 10 - TX

; PORTC, handles IO ..
; RC0 - pin 16 - wheel sensor 0
; RC1 - pin 15 - wheel sensor 1
; RC2 - pin 14 - wheel sensor 2
; RC3 - pin  7 - wheel sensor 3
; RC4 - pin  6 - wheel sensor power (?)
; RC5 - pin  5 - LED RED
; RC6 - pin  8 - LED GREEN
; RC7 - pin  9 - LED BLUE
 
 
; RGB output of configured values for display background color
; startup value = 0,0,0 for no display. 
; Set color using serial three-byte command ending with null byte.

; variables
	cblock 0x20	; bank 0 variables - 80 bytes
	    prodLo	; mul temp variables
	    prodHi
	    count
	    slowCountL
	    slowCountH
	    srLed, sgLed, sbLed
	endc
	
	cblock 0x70	; 16 bytes bank-free ram
	    previous	; last key
	    new		; next value
	    current	; newest confirmed value
	    counter	; number of new values read consecutively
	    measurement ; worked on right now
	    temp	; generic variable
	    rLed, gLed, bLed, ledCount, sine
	    buffer:4	; serial input command, r,g,b,0 or just 0 as poll request
	    bufferPointer ; 0-3 value, pointing into buffer
	endc
; application constants
FILTER EQU 0x03  ; new value 3 times to accept

;bits and pins 
wheel0 EQU RC0
wheel1 EQU RC1
wheel2 EQU RC2
wheel3 EQU RC3
sensorPwr EQU RC4
ledRed EQU RC5
ledGreen EQU RC6
ledBlue EQU RC7
 
; configuration data
 
	org 0x00 ; reset vector
	goto init
	org 0x04 ; interrupt vector
	goto isr
init
	; IO port C - configure wheel sensors digital input, led&power output
	movlw (1<<ledRed)|(1<<ledGreen)|(1<<ledBlue)|(1<<sensorPwr)
	banksel TRISC
	movwf TRISC
	banksel ANSELC
	clrf ANSELC ; no analog function on port c
	; Configure Fosc @ 4MHz, mcu clock = 1MHz, TMR0 = 1:1
	
	; INTCON, TMR0 sets rgb-action. Rollover on 1:1 clock = 1MHz/256 cycle
	bsf INTCON, TMR0IE
	bsf INTCON, GIE
	; setup tx serial for 9600,N,8,1 - first the baud generator
	; SYNC = 0, BRGH = 1, BRG16 = 0, SPBRG = 25 (check data sheet)
	banksel TXSTA
	bsf TXSTA, BRGH  ; SYNC is default 0
	movlw .25
	movwf SPBRG
	; prepare serial tx: SPEN, TXEN, TXREG, TXIF
	
	; appinit
	clrf bufferPointer
	clrf ledCount
	movlw 0xff ; just lets see ..
	movwf rLed
	movwf gLed
	movwf bLed
main
	; main loop. RGB handles itself, so does serial - just poll the wheel
	; and yell when it changes.
	
	goto main

scaleLeds ; after any change of rgb-values, and rollover slowCountH	
	movfw rLed
	movwf prodLo
	movfw slowCountH
	call mul8
	movfw prodHi
	addlw 0x80 ; get signed value
	movwf srLed
	movfw gLed
	movwf prodLo
	movfw slowCountH
	call mul8
	movfw prodHi
	addlw 0x80
	movwf sgLed
	movfw bLed
	movwf prodLo
	movfw slowCountH
	call mul8
	movfw prodHi
	addlw 0x80
	movwf sbLed
	return
isr
	; TMR0 overflow ?
	btfss INTCON, TMR0IF
	bra notTMR0
	; TMR0 overflow. We need access to PORTC
	banksel PORTC
	bcf INTCON, TMR0IF ; clear interrupt source
	incf ledCount ; counter increase may be all we do here ..
	movf ledCount, f ; test: at zero ?
	btfss STATUS, Z ; skip if so
	bra TMR0NotZero
	banksel 0
	incfsz slowCountL, f
	bra startRed
	incfsz slowCountH, f ; now this, will be slow enough ?
	bra startRed
	call scaleLeds
startRed
	movf rLed, f
	btfss STATUS, Z
	bsf PORTC, ledRed
startGreen
	movf gLed, f
	btfss STATUS, Z
	bsf PORTC, ledGreen
startBlue
	movf bLed, f
	btfss STATUS, Z
	bsf PORTC, ledBlue 
	retfie
TMR0NotZero
	; turn off LED, if appropriate at this time
stopRed
	movfw ledCount
	xorwf srLed, W
	btfsc STATUS, Z
	bcf PORTC, ledRed
stopGreen
	movfw ledCount
	xorwf sgLed, W
	btfsc STATUS, Z
	bcf PORTC, ledGreen
stopBlue
	movfw ledCount
	xorwf sbLed, W
	btfsc STATUS, Z
	bcf PORTC, ledBlue
	retfie
notTMR0	
	clrf INTCON
	retfie
	
mul8	; prodlhi:prodLo = w * prodLo
	clrf prodHi
        clrf count
	bsf count,3
	rrf prodLo,f
loop
	skpnc
	addwf prodHi,f
	rrf prodHi,f
	rrf prodLo,f

	decfsz count
	bra loop
	return
	
getSine ; courtesy of Eric Smith @ piclist.com
	movwf	temp	  ; save arg
	btfsc	temp,6	  ; is arg in the 2nd or 4th quadrant?
	sublw	0	  ; yes, complement it to reduce to 1st or 3rd
	andlw	07fh	  ; reduce to 1st quadrant
	call	sineTable ; get magnitude
	btfsc	temp,7	  ; was it 3rd or 4th quadrant?
	sublw	0	  ; yes, complement result
	return		    ; this is a signed result ..
	
sineTable
	andlw 0x3f ; so, I'm allowed to be paranoid !
	brw
	dt	0x00,0x03,0x06,0x09,0x0c,0x10,0x13,0x16
	dt	0x19,0x1c,0x1f,0x22,0x25,0x28,0x2b,0x2e
	dt	0x31,0x33,0x36,0x39,0x3c,0x3f,0x41,0x44
	dt	0x47,0x49,0x4c,0x4e,0x51,0x53,0x55,0x58
	dt	0x5a,0x5c,0x5e,0x60,0x62,0x64,0x66,0x68
	dt	0x6a,0x6b,0x6d,0x6f,0x70,0x71,0x73,0x74
	dt	0x75,0x76,0x78,0x79,0x7a,0x7a,0x7b,0x7c
	dt	0x7d,0x7d,0x7e,0x7e,0x7e,0x7f,0x7f,0x7f
	dt	0x7f
	
	end ; of everything
	