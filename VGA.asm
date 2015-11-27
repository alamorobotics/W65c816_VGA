; File: VGA.asm
; 11/17/2015

  PW 80          ;Page Width (# of char/line)
  PL 60          ;Page Length for HP Laser
  INCLIST ON     ;Add Include files in Listing

;*********************************************
;Test for Valid Processor defined in -D option
;*********************************************
  IF USING_816
  ELSE
    EXIT  "Not Valid Processor: Use -DUSING_02, etc."
  ENDIF

  TITLE  "VGA VGA.asm"
  STTL

VIA_BASE:     EQU $7FC0		; base address of VIA port on SXB
VIA_ORB:      EQU VIA_BASE
VIA_IRB:      EQU VIA_BASE
VIA_ORA:      EQU VIA_BASE+1
VIA_IRA:      EQU VIA_BASE+1
VIA_DDRB:     EQU VIA_BASE+2
VIA_DDRA:     EQU VIA_BASE+3
VIA_T1CLO:    EQU VIA_BASE+4
VIA_T1CHI:    EQU VIA_BASE+5
VIA_T1LLO:    EQU VIA_BASE+6
VIA_T1LHI:    EQU VIA_BASE+7
VIA_T2CLO:    EQU VIA_BASE+8
VIA_T2CHI:    EQU VIA_BASE+9
VIA_SR:       EQU VIA_BASE+10
VIA_ACR:      EQU VIA_BASE+11
VIA_PCR:      EQU VIA_BASE+12
VIA_IFR:      EQU VIA_BASE+13
VIA_IER:      EQU VIA_BASE+14
VIA_ORANH:    EQU VIA_BASE+15
VIA_IRANH:    EQU VIA_BASE+15

VGA_BASE      EQU $7F00		; base address of VGA port on SXB
VGA_PRINT     EQU VGA_BASE
VGA_COL       EQU VGA_BASE+$01
VGA_ROW       EQU VGA_BASE+$02
VGA_ROW_COLOR EQU VGA_BASE+$03
VGA_ROW_BACK  EQU VGA_BASE+$04
VGA_AUTO_INC  EQU VGA_BASE+$05
VGA_FILL_CHAR EQU VGA_BASE+$06
VGA_FILL_COL  EQU VGA_BASE+$07
VGA_FILL_BACK EQU VGA_BASE+$08
VGA_SCROLL_UP EQU VGA_BASE+$09
VGA_SCROLL_DN EQU VGA_BASE+$0A

VGA_CUR1_X    EQU VGA_BASE+$10
VGA_CUR1_Y    EQU VGA_BASE+$11
VGA_CUR1_MODE EQU VGA_BASE+$12
VGA_CUR2_X    EQU VGA_BASE+$13
VGA_CUR2_Y    EQU VGA_BASE+$14
VGA_CUR2_MODE EQU VGA_BASE+$15

SID_BASE      EQU $7F20		; base address of SID port on SXB
SID_FR1LO     EQU SID_BASE
SID_FR1HI     EQU SID_BASE+$01
SID_PW1LO     EQU SID_BASE+$02
SID_PW1HI     EQU SID_BASE+$03
SID_CR1       EQU SID_BASE+$04
SID_AD1       EQU SID_BASE+$05
SID_SR1       EQU SID_BASE+$06

SID_FR2LO     EQU SID_BASE+$07
SID_FR2HI     EQU SID_BASE+$08
SID_PW2LO     EQU SID_BASE+$09
SID_PW2HI     EQU SID_BASE+$0A
SID_CR2       EQU SID_BASE+$0B
SID_AD2       EQU SID_BASE+$0C
SID_SR2       EQU SID_BASE+$0D

SID_FR3LO     EQU SID_BASE+$0E
SID_FR3HI     EQU SID_BASE+$0F
SID_PW3LO     EQU SID_BASE+$10
SID_PW3HI     EQU SID_BASE+$11
SID_CR3       EQU SID_BASE+$12
SID_AD3       EQU SID_BASE+$13
SID_SR3       EQU SID_BASE+$14

SID_FCLO      EQU SID_BASE+$15
SID_FCHI      EQU SID_BASE+$16
SID_RESFIL    EQU SID_BASE+$17
SID_MODVOL    EQU SID_BASE+$18

StringLo      EQU $40 ; Low pointer
StringHi      EQU $41 ; High pointer
Temp          EQU $42 ; Temp storage

  CHIP 65C02
  LONGI OFF
  LONGA OFF

  .STTL "VGA"
  .PAGE
              ORG $0200
	START:

FirstChar

              LDA #$20
              STA VGA_FILL_CHAR
              JSR delay

mainLoop			  
			  
              LDA #03			; Red
              LDX #03			; Green
              LDY #00			; Blue
              JSR calc_rgb
              STA VGA_FILL_BACK
              JSR small_delay
              JSR small_delay

              LDA #00			; Red
              LDX #00			; Green
              LDY #03			; Blue
              JSR calc_rgb
              STA VGA_FILL_COL
              JSR small_delay
              JSR small_delay

              LDA #1
              STA VGA_AUTO_INC
              JSR small_delay

              LDX #0
              LDY #0
              LDA #<String1     ; Load String Pointers.
              STA StringLo
              LDA #>String1
              STA StringHi
              JSR printStringXY			  
              JSR small_delay
			  
			  LDX #0
			  LDY #3
              STX VGA_COL
              JSR small_delay
              STY VGA_ROW
              JSR small_delay			  
			  
			  LDY #18
			  LDA #0
tstLoop2	  STA VGA_PRINT
			  JSR small_delay
			  INC
			  BNE tstLoop2
			  DEY
			  BNE tstLoop2
			  
			  LDX #0
			  LDY #2
			  JSR setRowCol
			  LDA #$01
			  JSR printHex
			  LDA #$23
			  JSR printHex
			  LDA #$45
			  JSR printHex
			  LDA #$67
			  JSR printHex
			  LDA #$89
			  JSR printHex
			  LDA #$AB
			  JSR printHex
			  LDA #$CD
			  JSR printHex
			  LDA #$EF
			  JSR printHex
			  
			  STA VGA_SCROLL_UP
              JSR delay

			  STA VGA_SCROLL_UP
              JSR delay

			  STA VGA_SCROLL_UP
              JSR delay

			  STA VGA_SCROLL_UP
              JSR delay

			  STA VGA_SCROLL_UP
              JSR delay

              JSR delay
              JSR delay
              JSR delay
              JSR delay
              JSR delay

			  STA VGA_SCROLL_DN
              JSR delay

			  STA VGA_SCROLL_DN
              JSR delay

			  STA VGA_SCROLL_DN
              JSR delay

			  STA VGA_SCROLL_DN
              JSR delay

			  STA VGA_SCROLL_DN
              JSR delay

              JSR delay
              JSR delay
              JSR delay
              JSR delay
              JSR delay			  

			  
			  JMP mainLoop
			  
              LDA #$07
              STA SID_MODVOL
              JSR small_delay
              LDA #20
              STA SID_FR1LO
              JSR small_delay
              LDA #10
              STA SID_FR1HI
              JSR small_delay
              LDA #$22
              STA SID_AD1
              JSR small_delay
              LDA #$2F
              STA SID_SR1
              JSR small_delay
              LDA #$21
              STA SID_CR1
              JSR small_delay

              JSR delay

              LDA #$20
              STA SID_CR1
              JSR small_delay

              JSR delay

              ;JMP FirstChar


              LDA #100
              STA SID_FR2LO
              JSR small_delay
              LDA #100
              STA SID_FR2HI
              JSR small_delay
              LDA #$11
              STA SID_CR2
              JSR small_delay

              LDA #100
              STA SID_FR3LO
              JSR small_delay
              LDA #100
              STA SID_FR3HI
              JSR small_delay
              LDA #$11
              STA SID_CR3
              JSR small_delay


              LDA #40
              STA SID_FR1LO
              JSR small_delay
              LDA #40
              STA SID_FR1HI
              JSR small_delay
              LDA #$11
              STA SID_CR1
              JSR small_delay

              LDA #40
              STA SID_FR2LO
              JSR small_delay
              LDA #40
              STA SID_FR2HI
              JSR small_delay
              LDA #$11
              STA SID_CR2
              JSR small_delay

              LDA #40
              STA SID_FR3LO
              JSR small_delay
              LDA #40
              STA SID_FR3HI
              JSR small_delay
              LDA #$11
              STA SID_CR3
              JSR small_delay

              JSR delay

              ;JMP FirstChar

              LDA #1
              STA VGA_AUTO_INC
              JSR small_delay


              LDX #2
              LDY #3
              LDA #<String1         ; Load String Pointers.
              STA StringLo
              LDA #>String1
              STA StringHi
              JSR printStringXY

              LDA #00
              STA VGA_AUTO_INC
              JSR small_delay

              LDA #3
              STA VGA_CUR1_X
              JSR small_delay

              LDA #4
              STA VGA_CUR1_Y
              JSR small_delay

              LDA #7
              STA VGA_CUR1_MODE
              JSR small_delay

              LDA #2
              STA VGA_CUR2_X
              JSR small_delay

              LDA #3
              STA VGA_CUR2_Y
              JSR small_delay

              LDA #2
              STA VGA_CUR2_MODE
              JSR small_delay

              ;JMP FirstChar

              LDA #50
colLoop       STA VGA_ROW
              JSR small_delay
              ROL
              ROL
              STA VGA_ROW_BACK
              JSR small_delay
              ROR
              ROR
              DEC
              ;BNE colLoop

              JSR delay

              LDA #$30
              STA VGA_FILL_CHAR
              JSR delay
              LDA #$FC
              STA VGA_FILL_COL
              JSR delay
              LDA #$00
              STA VGA_FILL_BACK
              JSR delay


              LDA #$31
              STA VGA_FILL_CHAR
              JSR delay
              LDA #$CC
              STA VGA_FILL_COL
              JSR delay
              LDA #$3C
              STA VGA_FILL_BACK
              JSR delay

              LDA #$32
              STA VGA_FILL_CHAR
              JSR delay
              LDA #$00
              STA VGA_FILL_COL
              JSR delay
              LDA #$F0
              STA VGA_FILL_BACK
              JSR delay

              LDA #$20
              STA VGA_FILL_CHAR
              JSR delay

              JMP FirstChar

;-------------------------------------------------------------------------
; delay: delay to see changes on screen.
;-------------------------------------------------------------------------

delay         LDA #$10
              LDY #$00            ; Loop 256*256 times...
              LDX #$00

dloop1        DEX
              BNE dloop1
              DEY
              BNE dloop1
              DEC
              BNE dloop1
              RTS

;-------------------------------------------------------------------------
; small_delay: Small delay for propeller to catch up.
;-------------------------------------------------------------------------

small_delay   LDX #$08

dloop2        DEX
              BNE dloop2
              RTS

;-------------------------------------------------------------------------
; calc_rgb: A = R, X = G, Y = B values between 0 and 3
; Resulting byte is RRGGBB00 each two bit values.
;-------------------------------------------------------------------------

calc_rgb      ROL
              ROL
              ROL
              ROL
              ROL
              ROL
              STA Temp
              TXA
              ROL
              ROL
              ROL
              ROL
              CLC
              ADC Temp
              STA Temp
              TYA
              ROL
              ROL
              CLC
              ADC Temp
              RTS

;-------------------------------------------------------------------------
; setRowCol: Set Row and col from X and Y.
;-------------------------------------------------------------------------
setRowCol
              STX VGA_COL
              JSR small_delay
              STY VGA_ROW
              JSR small_delay
			  RTS
			  
;-------------------------------------------------------------------------
; printHex: Print a HEX value, the Woz way...
;-------------------------------------------------------------------------

printHex
			  PHA				; Save A for LSD
			  LSR
			  LSR
			  LSR				; MSD to LSD position
			  LSR
			  JSR PRHEX			; Output hex digit 
			  PLA				; Restore A
PRHEX		  AND #%00001111	; Mask LSD for hex print			  
			  ORA #"0"			; Add "0"
			  CMP #"9"+1		; Is it a decimal digit ?
			  BCC ECHO			; Yes Output it
			  ADC #6			; Add offset for letter A-F
ECHO		  STA VGA_PRINT		; Print
			  JSR small_delay	; Wait to catch up
			  RTS
			  
;-------------------------------------------------------------------------
; printStringXY: Print a string preloaded in StringLo at XY from Xand Y register.
;-------------------------------------------------------------------------

printStringXY
              STX VGA_COL
              JSR small_delay
              STY VGA_ROW
              JSR small_delay

;-------------------------------------------------------------------------
; printString: Print a string preloaded in StringLo
;-------------------------------------------------------------------------

printString
              LDY #0
nextChar      LDA (StringLo),Y
              BEQ done_Printing
              STA VGA_PRINT
              JSR small_delay
              INY
              BRA nextChar
done_Printing
              RTS
;-------------------------------------------------------------------------
; FUNCTION NAME	: Event Hander re-vectors
;-------------------------------------------------------------------------
IRQHandler:
              PHA
			  PLA
			  RTI

badVec:		; $FFE0 - IRQRVD2(134)
              PHP
              PHA
              LDA #$FF
              ;clear Irq
              PLA
              PLP
              RTI


	DATA

String1
              BYTE "Testing printing a string...", $00 ; 1
	ENDS

;-----------------------------
;
;		Reset and Interrupt Vectors (define for 265, 816/02 are subsets)
;
;-----------------------------

Shadow_VECTORS	SECTION OFFSET $7EE0
                            ;65C816 Interrupt Vectors
                            ;Status bit E = 0 (Native mode, 16 bit mode)
              DW badVec     ; $FFE0 - IRQRVD4(816)
              DW badVec     ; $FFE2 - IRQRVD5(816)
              DW badVec     ; $FFE4 - COP(816)
              DW badVec     ; $FFE6 - BRK(816)
              DW badVec     ; $FFE8 - ABORT(816)
              DW badVec     ; $FFEA - NMI(816)
              DW badVec     ; $FFEC - IRQRVD(816)
              DW badVec     ; $FFEE - IRQ(816)
                            ;Status bit E = 1 (Emulation mode, 8 bit mode)
              DW badVec     ; $FFF0 - IRQRVD2(8 bit Emulation)(IRQRVD(265))
              DW badVec     ; $FFF2 - IRQRVD1(8 bit Emulation)(IRQRVD(265))
              DW badVec     ; $FFF4 - COP(8 bit Emulation)
              DW badVec     ; $FFF6 - IRQRVD0(8 bit Emulation)(IRQRVD(265))
              DW badVec     ; $FFF8 - ABORT(8 bit Emulation)
                            ; Common 8 bit Vectors for all CPUs
              DW badVec     ; $FFFA -  NMIRQ (ALL)
              DW START      ; $FFFC -  RESET (ALL)
              DW IRQHandler ; $FFFE -  IRQBRK (ALL)
	ENDS

vectors	SECTION OFFSET $FFE0
							;65C816 Interrupt Vectors
							;Status bit E = 0 (Native mode, 16 bit mode)
              DW badVec     ; $FFE0 - IRQRVD4(816)
              DW badVec     ; $FFE2 - IRQRVD5(816)
              DW badVec     ; $FFE4 - COP(816)
              DW badVec     ; $FFE6 - BRK(816)
              DW badVec     ; $FFE8 - ABORT(816)
              DW badVec     ; $FFEA - NMI(816)
              DW badVec     ; $FFEC - IRQRVD(816)
              DW badVec     ; $FFEE - IRQ(816)
							;Status bit E = 1 (Emulation mode, 8 bit mode)
              DW badVec     ; $FFF0 - IRQRVD2(8 bit Emulation)(IRQRVD(265))
              DW badVec     ; $FFF2 - IRQRVD1(8 bit Emulation)(IRQRVD(265))
              DW badVec     ; $FFF4 - COP(8 bit Emulation)
              DW badVec     ; $FFF6 - IRQRVD0(8 bit Emulation)(IRQRVD(265))
              DW badVec     ; $FFF8 - ABORT(8 bit Emulation)
							; Common 8 bit Vectors for all CPUs
              DW badVec     ; $FFFA -  NMIRQ (ALL)
              DW START      ; $FFFC -  RESET (ALL)
              DW IRQHandler ; $FFFE -  IRQBRK (ALL)
	ENDS
	END
