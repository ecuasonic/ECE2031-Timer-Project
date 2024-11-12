# ECE 2031 Final Project

### Recent Changes:

- `SCOMP2.sof` is the .sof file that was tested on the DE10, and was shown to work, but there is a bug in the assembly code
    - Line 95
    - `OUT COUNT` instead of `STORE COUNT` was used on the rocketship countdown.
    - `COUNT: DW 0`, so COUNT represented an addresss whose value didn't correspond to any IO Address, therefore no IO device effect was seen.
    - The program appeared to be correct, since the `COUNT_DOWN` subroutine was programmed such that when `timer_counter` = 0, then break out. `timer_counter` = 3 to begin with, and so `COUNT` acted as though `COUNT` = 3 even though `COUNT` = 4 at the time.
    - `timer_project2.zip` corresponds with SCOMP2.sof

- `SCOMP.sof` is fixed .sof file, but untested since lab is closed.
    - `timer_project.zip` corresponds with SCOMP.sof


## Timer Functionality Added:

1. TIMER peripheral
    - Stores current counter value
    - Does the counting
2. TIMER_FREQ peripheral
    - Provides user-specified timer speed in Hz

## TIMER BDF Structure:

![TIMER.png](https://github.com/ecuasonic/ECE2031-Timer-Project/blob/main/TIMER.png)

## VHDL Organization:

The TIMER and TIMER_FREQ are currently in separate vhdl files, but it is possible to merge them together into a single vhdl file, and have two Chip Select inputs to differ between the two.
The peripherals are separated for now for debugging simplicity.

## Assembly Code Example:
```asm
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

ORG 0
    ; Stop timer and set counter = 0
    LOADI   0
    OUT     TIMER_FREQ
    OUT     TIMER

    ; Start timer with 2 Hz and count until 10
    LOADI   2
    OUT     TIMER_FREQ
    CALL    COUNT_UP

    ; Stop timer
    LOADI   0
    OUT     TIMER_FREQ

    ; Set counter = 10 and start timer with -2 Hz
    LOADI   10
    OUT     TIMER
    LOADI   -2
    OUT     TIMER_FREQ
    CALL    COUNT_DOWN

	JUMP    0

COUNT_UP:
    IN      TIMER
    OUT     Hex1
    SUB     LIMIT
    JNEG    COUNT_UP
    RETURN

COUNT_DOWN:
    IN      TIMER_FREQ
    OUT     Hex1
    JPOS    COUNT_DOWN
    RETURN

; Values
LIMIT:      DW  10

; IO address constants
Switches:   EQU 000
LEDs:       EQU 001
TIMER:      EQU 002
TIMER_FREQ: EQU 003
Hex0:       EQU 004
Hex1:       EQU 005
```

## Overall SCOMP_System BDF structure:

![SCOMP_SystemBDF.png](https://github.com/ecuasonic/ECE2031-Timer-Project/blob/main/SCOMP_SystemBDF.png)

