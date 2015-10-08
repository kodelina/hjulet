#include "p16f1829.inc"
 __CONFIG _CONFIG1, _FOSC_INTOSC & _WDTE_SWDTEN & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_ON & _CLKOUTEN_OFF & _IESO_ON & _FCMEN_ON
 __CONFIG _CONFIG2, _WRT_OFF & _PLLEN_ON & _STVREN_ON & _BORV_LO & _LVP_OFF

; latch for 4 digital inputs, pollable with serial output of latched value
; RC0:3 is new value, rc0 MUST change for a new value to be accepted.

; the chip:
; RA0 - pin 19 - ICSPDAT - 
; RA1 - pin 18 - ICSPCLK - 
; RA2 - pin 17 - INT
; RA3 - pin  4 - Vpp
; RA4 - pin  3 -
; RA5 - pin  2 -

; RB4 - pin 13
; RB5 - pin 12 - RX
; RB6 - pin 11
; RB7 - pin 10 - TX

; PORTC, handles IO ..
; RC0 - pin 16 - wheel sensor 0 - this MUST be outermost sensor!
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
	; IO ports - configure wheel sensors digital input, led&power output
	movlw (1<<ledRed)|(1<<ledGreen)|(1<<ledBlue)|(1<<sensorPwr)
	banksel TRISC
	movwf TRISC
	banksel ANSELC
	clrf ANSELC ; no analog function on port c
	banksel WPUC
	movlw 0x0f
	movwf WPUC  ; weak pullup for open drain output of sensors
	; Configure Fosc @ 4MHz, mcu clock = 1MHz, TMR0 = 1:1
	; OSCCON, OPTION_REG, T1CON
	movlw b'1101' << IRCF | b'10' ; 4MHz clock
	banksel OSCCON
	movwf OSCCON
	movlw 1 << PSA ; prescaler -> WDT (timer0 = 1:1)
	banksel OPTION_REG
	movwf OPTION_REG
	movlw b'01' << TMR1CS | 1 << T1SYNC
	movwf T1CON ; timer1 ready to go at 1:1, but not started
	
	
	; INTCON, TMR0 sets rgb-action. Rollover on 1:1 clock = 1MHz/256 cycle
	bsf INTCON, TMR0IE ; accept interrupts for timer 0 overflow
	bsf INTCON, PEIE   ; accept (enabled) peripheral interrupts
	banksel PIE1
	bsf PIE1, RCIE	   ; enable receive interrupt
	bsf INTCON, GIE    ; accept interrupts at all
	; setup tx serial for 9600,N,8,1 - first the baud generator
	; SYNC = 0, BRGH = 1, BRG16 = 0, SPBRG = 25 (check data sheet)
	banksel TXSTA
	bsf TXSTA, BRGH  ; SYNC is default 0
	movlw .25
	movwf SPBRG
	; prepare serial tx: SPEN, TXEN, TXREG, TXIF, RCIF
	; enable transmitter: TXEN = 1, SYNC = 0, SPEN = 1
	bcf TXSTA, SYNC
	bsf TXSTA, TXEN
	; enable receiver: CREN = 1, SYNC = 0, SPEN = 1
	bsf RCSTA, CREN
	bsf RCSTA, SPEN
	; appinit
	clrf bufferPointer
	clrf ledCount
	movlw 0xff ; just lets see ..
	movwf rLed
	movwf gLed
	movwf bLed
main
	; arrange for a small break first ?
	clrf temp
	clrf count
	nop
	decfsz count, f
	bra $-2
	decfsz temp, f
	bra $-4
	; see if a request for data has arrived on the serial bus
	; 1. bufferPointer = 1 & buffer[0] = 0 => request for update
	banksel buffer
	movlw 0x01
	xorwf bufferPointer, W
	btfss STATUS, Z
	bra mainNoRequest
	movf buffer, f
	btfss STATUS, Z
	bra mainNoRequest
	call sendW	    ; ok, send update.
	clrf bufferPointer
mainNoRequest	
	; 2. bufferPointer = 4 & buffer[3] = 0 => set RGB
	movlw 0x04
	xorwf bufferPointer, W
	btfss STATUS, Z
	bra mainNoRGB
	movf buffer + 3, f
	btfss STATUS, Z
	bra mainNoRGB
	; hooray - a new set of RGB has arrived
	movfw buffer + 0
	movwf rLed
	movfw buffer + 1
	movwf gLed
	movfw buffer + 2
	movwf bLed
	clrf bufferPointer
	call scaleLeds
mainNoRGB
	; check on our sensors 
	banksel PORTC
	movfw PORTC
	andlw 0x0f	; just the sensor bits
	movwf measurement
	; if equal to current, ignore
	xorwf current, F
	btfsc STATUS, Z
	bra finishedMeasurement
	; zo, we hav e new one. Not interested unless bit 0 changes
	movfw measurement
	andlw 0x01
	xorwf current, W
	asrf WREG   ; C set = different measurement - else, false alarm
	btfss STATUS, C
	bra finishedMeasurement
	; so, new and bit0 change. Are we building on previous measurements ?
	movfw measurement
	xorwf new, W
	btfss STATUS, Z
	bra mainNewValue
	; so, more of the same .. we meet again
	incf counter, f
	movlw FILTER
	xorwf counter, W
	btfss STATUS, Z
	bra finishedMeasurement
	; we have a new value, tidy up our variables
	movfw current
	movwf previous
	movfw measurement
	movwf current
	clrf counter
	clrf new
	call sendW
	bra finishedMeasurement
mainNewValue ; new, new value .. start counting
	movfw measurement
	movwf new
	clrf counter
finishedMeasurement
	goto main

sendW
	; make sure TXIF is set, no outbound queue
	banksel PIR1
	btfss PIR1, TXIF
	bra sendW
	banksel current
	movfw current ; current value of wheel sensoring
	banksel TXREG
	movwf TXREG
	banksel 0
	return
	
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
	call scaleLeds ; >120 cycles .. will this work well?
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
	movfw ledCount
	xorwf srLed, W   ; check red led setting
	btfsc STATUS, Z
	bcf PORTC, ledRed ; turn off the red led
	movfw ledCount
	xorwf sgLed, W	 ; check green led setting
	btfsc STATUS, Z
	bcf PORTC, ledGreen ; turn off green led
	movfw ledCount
	xorwf sbLed, W	  ; check blue led setting
	btfsc STATUS, Z
	bcf PORTC, ledBlue  ; turn off blue led
	retfie
notTMR0	
	; serial usart receive, unread incoming byte ?
	banksel PIR1
	btfss PIR1, RCIF
	bra unknownISR
	; if bufferPointer > 3, buffer is invalid, and byte is lost
	btfsc bufferPointer, 2
	bra bufferInvalid
	; welcome aboard :)
	banksel buffer
	movlw low buffer
	addwf bufferPointer, W
	movwf FSR0L
	movlw high buffer
	movwf FSR0H
	banksel RCREG
	movfw RCREG
	movwf INDF0
	banksel buffer
	incf bufferPointer, f
	retfie
bufferInvalid	
	clrf bufferPointer ; sorry, but all is lost :(
unknownISR	
	clrf INTCON
	retfie
	
mul8	; prodlhi:prodLo = w * prodLo
	clrf prodHi
        clrf count
	bsf count,3
	rrf prodLo,f
mulLoop
	skpnc
	addwf prodHi,f
	rrf prodHi,f
	rrf prodLo,f

	decfsz count
	bra mulLoop
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
	andlw 0x3f ; so, I'm old and allowed some paranoia !
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
	