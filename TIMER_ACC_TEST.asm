; TIMER_ACC_TEST.asm
; Timer receives start_count from ACC during OUT instruction
; Shows Timer go from 0.0 to 5.0 then 2.5 to 7.5
; Last updated on 7/17/2024

ORG 0
    ; --------------------
    ; Count from 0.0 to 5.0
    LOAD    ZERO
    OUT     TIMER_ACC
LOOP1:
    IN      TIMER_ACC
    OUT     Hex1
    SUB     FIVE
    JNEG    LOOP1
    ; --------------------
    ; Reset Hex1 Display
    LOAD    ZERO
    OUT     Hex1
    ; --------------------
    ; Count to 2.5 to 7.5
    LOAD    TWO_FIVE
    OUT     TIMER_ACC
LOOP2:
    IN      TIMER_ACC
    OUT     Hex0
    SUB     SEVEN_FIVE
    JNEG    LOOP2
    ; --------------------
    ; Reset Hex0 Display
    LOAD    ZERO
    OUT     Hex0
    ; --------------------
    ; Restart
	JUMP    0

; Values
ZERO:       DW  0
TWO_FIVE:   DW  25
FIVE:       DW  50
SEVEN_FIVE: DW  75

; IO address constants
Switches:   EQU 000
LEDs:       EQU 001
TIMER_ACC:  EQU 002
TIMER_FREQ: EQU 003
Hex0:       EQU 004
Hex1:       EQU 005
