#include "p12f1840.inc"
 __CONFIG _CONFIG1, _FOSC_INTOSC & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_ON & _CLKOUTEN_OFF & _IESO_ON & _FCMEN_ON
 __CONFIG _CONFIG2, _WRT_OFF & _PLLEN_ON & _STVREN_ON & _BORV_LO & _LVP_OFF

; not in include file
IRCF EQU 0x03

; supporting function project "hjulet"
; input : four bits of data
; output : DAC power output = input << 1
; read hall effect sensors to determine magnets, thus
; wheel position from binary encoding of north/south poles

; chip pins
output EQU RA0 ; dacout
input0 EQU RA1
input1 EQU RA2
input2 EQU RA4
input3 EQU RA5

        cblock 0x70
            value
            temp
        endc

        org 0x00
        goto init
        org 0x04
        goto isr
init
        ; chip init
	banksel ANSELA
	clrf ANSELA
        movlw b'1011' << IRCF ; 1MHz speed .. perhaps overkill ..
        banksel OSCCON
        movwf OSCCON
        ; set IO
        movlw 1 << input0 | 1 << input1 | 1 << input2 | 1 << input3
        banksel TRISA
        movwf TRISA
        ; enable the DAC
        banksel DACCON0
        movlw 1 << DACOE | 1 << DACEN  ; Vdd-Vss range, output enable, dac enable
        movwf DACCON0
        banksel 0

main
	banksel PORTA
	
        clrf value
        bcf STATUS, C           ; assume not set
        btfsc PORTA, input3
        bsf STATUS, C           ; input bit set, set carry
        rlf value, f            ; rotate the carry into value

        bcf STATUS, C           ; assume not set
        btfsc PORTA, input2
        bsf STATUS, C           ; input bit set, set carry
        rlf value, f            ; rotate the carry into value

        bcf STATUS, C           ; assume not set
        btfsc PORTA, input1
        bsf STATUS, C           ; input bit set, set carry
        rlf value, f            ; rotate the carry into value

        bcf STATUS, C           ; assume not set
        btfsc PORTA, input0
        bsf STATUS, C           ; input bit set, set carry
        rlf value, f            ; rotate the carry into value
	bcf STATUS, C
	rlf value, f		; four bits -> 5 bits output
        movfw value

setDAC
        banksel DACCON1
        movwf DACCON1
        banksel PORTA
        ; short break
        nop
        decfsz temp, f
        bra $-2
        bra main

isr
        clrf INTCON
        retfie

        end