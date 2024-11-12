; TIMER_TEST.asm
; ----------------------------------------------------------
; TIMER_FREQ control the clock speed going to the clock
;       ACC = Freq (Neg, Zero, Pos)
;       If ACC = 0, then stop timer
;       Else if ACC = POS, then count up
;       Else if ACC = NEG, then count down
; TIMER stores the counter and does the counting
;       ACC = Starting Value
; ----------------------------------------------------------
; OUT TIMER : Sets Timer counter
; IN TIMER : Gets Timer counter
; OUT TIMER_FREQ : Sets Timer frequency (Hz)
; IN TIMER_FREQ : Gets Timer frequency (Hz)
; ----------------------------------------------------------
; Tests each clock frequencies and outputs to Hex Display
; Last updated on 7/18/2024

ORG 0

    ; Count up to 4, slow down, count to 8, slow down, count to 12
    ; --------------------------

    LOADI   0
    OUT     TIMER_FREQ
    OUT     TIMER

    LOADI   8
    CALL    SET_FREQ_AND_COUNT_UP_BY_4

    LOADI   4
    CALL    SET_FREQ_AND_COUNT_UP_BY_4

    LOADI   2
    CALL    SET_FREQ_AND_COUNT_UP_BY_4

    LOADI   1
    CALL    SET_FREQ_AND_COUNT_UP_BY_4

    ; Count down to 8, speed up, count down to 4, speed up, count down to 0
    ; -------------------------

    LOADI   -1
    CALL    SET_FREQ_AND_COUNT_DOWN_BY_4

    LOADI   -2
    CALL    SET_FREQ_AND_COUNT_DOWN_BY_4

    LOADI   -4
    CALL    SET_FREQ_AND_COUNT_DOWN_BY_4

    LOADI   -8
    CALL    SET_FREQ_AND_COUNT_DOWN_BY_4

    ; Count up to 4, speed up, count to 8, speed up, count to 12
    ; --------------------------

    LOADI   1
    CALL    SET_FREQ_AND_COUNT_UP_BY_4

    LOADI   2
    CALL    SET_FREQ_AND_COUNT_UP_BY_4

    LOADI   4
    CALL    SET_FREQ_AND_COUNT_UP_BY_4

    LOADI   8
    CALL    SET_FREQ_AND_COUNT_UP_BY_4

    ; Count down to 8, slow down, count down to 4, slow down, count down to 0
    ; -------------------------

    LOADI   -8
    CALL    SET_FREQ_AND_COUNT_DOWN_BY_4

    LOADI   -4
    CALL    SET_FREQ_AND_COUNT_DOWN_BY_4

    LOADI   -2
    CALL    SET_FREQ_AND_COUNT_DOWN_BY_4

    LOADI   -1
    CALL    SET_FREQ_AND_COUNT_DOWN_BY_4

    ; --------------------------

    CALL    STOP_TIMER_AND_CHECK

    ; --------------------------
    ; Rocketship count down then take off
    LOADI   -1
    OUT     TIMER_FREQ
    LOADI   3
    OUT     TIMER
    STORE   COUNT
    CALL    COUNT_DOWN

    LOADI   50
    OUT     TIMER_FREQ
    LOADI   192
    STORE   COUNT
    CALL    COUNT_UP

    ; Slow down considerably and count up by 4
    LOADI   1
    CALL    SET_FREQ_AND_COUNT_UP_BY_4

    ; -------------------------

    CALL    STOP_TIMER_AND_CHECK

    ; -------------------------

    ; Countinue and count up by 4
    LOADI   1
    CALL    SET_FREQ_AND_COUNT_UP_BY_4

    ; -------------------------

    ; Crash down to 0, IN TIMER is always positive
    LOADI   -100
    OUT     TIMER_FREQ
    LOADI   400
    STORE   COUNT
    CALL    COUNT_DOWN

    ; -------------------------

    LOADI   1
    CALL    SET_FREQ_AND_COUNT_UP_BY_4

    ; -------------------------

    LOADI   255
    OUT     TIMER
    IN      TIMER
    OUT     Hex1
    CALL    STOP_TIMER_AND_CHECK
	JUMP    0

    ; -------------------------

COUNT_UP:
    IN      TIMER
    STORE   INIT
LOOP1:
    IN      TIMER
    OUT     Hex1
    SUB     COUNT
    SUB     INIT
    JNEG    LOOP1
    RETURN

COUNT_DOWN:
    IN      TIMER
    STORE   INIT
LOOP2:
    IN      TIMER
    OUT     Hex1
    JZERO   END
    SUB     INIT
    ADD     COUNT
    JPOS    LOOP2
END:
    RETURN

STOP_TIMER_AND_CHECK:
    LOADI   0
    OUT     TIMER_FREQ
WHILE1:
    IN      TIMER
    OUT     HEX1
    IN      Switches
    JZERO   WHILE1
    RETURN

SET_FREQ_AND_COUNT_UP_BY_4:
    OUT     TIMER_FREQ
    LOADI   4
    STORE   COUNT
    CALL    COUNT_UP
    RETURN

SET_FREQ_AND_COUNT_DOWN_BY_4:
    OUT     TIMER_FREQ
    LOADI   4
    STORE   COUNT
    CALL    COUNT_DOWN
    RETURN

; Global Variables
COUNT:      DW  0
INIT:       DW  0

; IO address constants
Switches:   EQU 000
LEDs:       EQU 001
TIMER:      EQU 002
TIMER_FREQ: EQU 003
Hex0:       EQU 004
Hex1:       EQU 005
