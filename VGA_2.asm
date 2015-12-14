; File: VGA_2.asm
; 12/10/2015

;############################# DESCIPTION ########################

; Transfer from W65C816SXB to Propeller

; 1. W65C816SXB waits for PB7 (P15) to be low, $80
; 2. W65C816SXB puts data on PIA PA
; 3. W65C816SXB puts data on PIA PB with PB6 high. $40
; 4. Propeller waits for PB6 (P14) to go high.
; 5. Propeller reads PIA PA-PB and sets P15 high.
; 6, W65C816SXB waits for PB7 (P15)to be high, $80
; 7. W65C816SXB sets PIA PB6 (P14) low. $40
; 8. Propeller waits for PB6 (P14) to go low.
; 9. Propeller does it's thing...
; 10. Propeller sets P15 Low.

; Note: All connections to the W65C816SXB board have a 1Kohm resistor in series...

;########################### PIN ASSIGNMENTS #####################

;  P0  - Data 0 - PIA PA0 via 1Kohm resistor
;  P1  - Data 1 - PIA PA1 via 1Kohm resistor
;  P2  - Data 2 - PIA PA2 via 1Kohm resistor
;  P3  - Data 3 - PIA PA3 via 1Kohm resistor 
;  P4  - Data 4 - PIA PA4 via 1Kohm resistor 
;  P5  - Data 5 - PIA PA5 via 1Kohm resistor
;  P6  - Data 6 - PIA PA6 via 1Kohm resistor
;  P7  - Data 7 - PIA PA7 via 1Kohm resistor
;  P8  - Address 0 - PIA PB0 via 1Kohm resistor
;  P9  - Address 1 - PIA PB1 via 1Kohm resistor
;  P10 - Address 2 - PIA PB2 via 1Kohm resistor
;  P11 - Address 3 - PIA PB3 via 1Kohm resistor
;  P12 - Address 4 - PIA PB4 via 1Kohm resistor
;  P13 - Address 5 - 0 for VGA and 1 for SID  - PIA PB5 via 1Kohm resistor
;  P14 - Flag Write - Wait for High from W65C816SXB, once propeller flag busy, W65C816SXB sets low. - PIA PB6 via 1Kohm resistor
;  P15 - Flag BUSY - Set high by propeller when processing. - PIA PB7 via 1Kohm resistor, only input...    
;  P16 - VGA VSync - 270 ohm resistor to D-Sub 14
;  P17 - VGA HSync - 270 ohm resistor to D-Sub 13 
;  P18 - VGA B0 - 560 ohm resistor to D-Sub 3
;  P19 - VGA B1 - 270 ohm resistor to D-Sub 3
;  P20 - VGA G0 - 560 ohm resistor to D-Sub 2
;  P21 - VGA G1 - 270 ohm resistor to D-Sub 2
;  P22 - VGA R0 - 560 ohm resistor to D-Sub 1
;  P23 - VGA R1 - 270 ohm resistor to D-Sub 1
;  P24 - SID Right Channel connect to amplifier for headphones or line in to computer 
;  P25 - SID Left Channel connect to amplifier for headphones or line in to computer 
;  P26 - 
;  P27 - 
;  P28 - I2C SCL
;  P29 - I2C SDA
;  P30 - Serial Tx
;  P31 - Serial Rx

;#################################################################


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

VIA_BASE		EQU $7FC0		; base address of VIA port on SXB
VIA_ORB			EQU VIA_BASE
VIA_IRB			EQU VIA_BASE
VIA_ORA			EQU VIA_BASE+1
VIA_IRA			EQU VIA_BASE+1
VIA_DDRB		EQU VIA_BASE+2
VIA_DDRA		EQU VIA_BASE+3
VIA_T1CLO		EQU VIA_BASE+4
VIA_T1CHI		EQU VIA_BASE+5
VIA_T1LLO		EQU VIA_BASE+6
VIA_T1LHI		EQU VIA_BASE+7
VIA_T2CLO		EQU VIA_BASE+8
VIA_T2CHI		EQU VIA_BASE+9
VIA_SR			EQU VIA_BASE+10
VIA_ACR			EQU VIA_BASE+11
VIA_PCR			EQU VIA_BASE+12
VIA_IFR			EQU VIA_BASE+13
VIA_IER			EQU VIA_BASE+14
VIA_ORANH		EQU VIA_BASE+15
VIA_IRANH		EQU VIA_BASE+15

PIA_BASE		EQU $7FA0		; base address of PIA port on SXB
PIA_ORA			EQU PIA_BASE
PIA_IRA			EQU PIA_BASE
PIA_DDRA		EQU PIA_BASE
PIA_CTRLA		EQU PIA_BASE+1
PIA_ORB			EQU PIA_BASE+2
PIA_IRB			EQU PIA_BASE+2
PIA_DDRB		EQU PIA_BASE+2
PIA_CTRLB		EQU PIA_BASE+3

VGA_BASE		EQU $00		; "base address" of VGA, this address is sent to the propeller
VGA_PRINT		EQU VGA_BASE
VGA_COL			EQU VGA_BASE+$01
VGA_ROW			EQU VGA_BASE+$02
VGA_ROW_COLOR	EQU VGA_BASE+$03
VGA_ROW_BACK	EQU VGA_BASE+$04
VGA_AUTO_INC	EQU VGA_BASE+$05
VGA_FILL_CHAR	EQU VGA_BASE+$06
VGA_FILL_COL	EQU VGA_BASE+$07
VGA_FILL_BACK	EQU VGA_BASE+$08
VGA_SCROLL_UP	EQU VGA_BASE+$09
VGA_SCROLL_DN	EQU VGA_BASE+$0A

VGA_CUR1_X		EQU VGA_BASE+$10
VGA_CUR1_Y		EQU VGA_BASE+$11
VGA_CUR1_MODE	EQU VGA_BASE+$12
VGA_CUR2_X		EQU VGA_BASE+$13
VGA_CUR2_Y		EQU VGA_BASE+$14
VGA_CUR2_MODE	EQU VGA_BASE+$15

SID_BASE		EQU $20		; "base address" of SID emulation, this address is sent to the propeller
SID_FR1LO		EQU SID_BASE
SID_FR1HI		EQU SID_BASE+$01
SID_PW1LO		EQU SID_BASE+$02
SID_PW1HI		EQU SID_BASE+$03
SID_CR1			EQU SID_BASE+$04
SID_AD1			EQU SID_BASE+$05
SID_SR1			EQU SID_BASE+$06

SID_FR2LO		EQU SID_BASE+$07
SID_FR2HI		EQU SID_BASE+$08
SID_PW2LO		EQU SID_BASE+$09
SID_PW2HI		EQU SID_BASE+$0A
SID_CR2			EQU SID_BASE+$0B
SID_AD2			EQU SID_BASE+$0C
SID_SR2			EQU SID_BASE+$0D

SID_FR3LO		EQU SID_BASE+$0E
SID_FR3HI		EQU SID_BASE+$0F
SID_PW3LO		EQU SID_BASE+$10
SID_PW3HI		EQU SID_BASE+$11
SID_CR3			EQU SID_BASE+$12
SID_AD3			EQU SID_BASE+$13
SID_SR3			EQU SID_BASE+$14

SID_FCLO		EQU SID_BASE+$15
SID_FCHI		EQU SID_BASE+$16
SID_RESFIL		EQU SID_BASE+$17
SID_MODVOL		EQU SID_BASE+$18

; Crazy idea for future project...
; Include 3 other SID Cogs to emulate 4 sids.
; Output induvudual channels so you can pan left/right and mix separately.
; EQU SID_BASE+$19 to select sid chip, don't have room for all addresses.


NOTE1_ON		EQU $41	; Square
NOTE1_OFF		EQU $40
NOTE2_ON		EQU $81 ; Noise
NOTE2_OFF		EQU $80
NOTE3_ON		EQU $21 ; Sawtooth
NOTE3_OFF		EQU $20


; Zero Page stuff

; String Pointers
StringLo		EQU $40 ; Low pointer
StringHi		EQU $41 ; High pointer
; Music Pointers
MusicLo			EQU	$42 ; Low Music Pointer
MusicHi			EQU	$43 ; High Music Pointer
NoteLo			EQU $44 ; Value of the note in the SID
NoteHi			EQU $45
Temp_Color		EQU $46 ; Color rotation helpers
Current_Color	EQU $47

; Temp Storage
Temp			EQU $60 ; Temp storage

	CHIP 65C02
	LONGI OFF
	LONGA OFF

	.STTL "VGA"
	.PAGE
				ORG $0200
START
										; Init PIA, a quite interesting chip...
				LDA #$00				; Set DDR
				STA PIA_CTRLA
				STA PIA_CTRLB
				
				LDA #$FF				; Make all output
				STA PIA_DDRA
				LDA #$7F
				STA PIA_DDRB			; Bit 0-7 output, bit 8 input

				LDA #$04				; Set OR/IR
				STA PIA_CTRLA
				STA PIA_CTRLB

				LDA #<MusicData     	; Reset Music Pointers.
				STA MusicLo
				LDA #>MusicData
				STA MusicHi
				
				LDA #$20				; Blank Screen
				LDX #VGA_FILL_CHAR
				JSR writeToPropeller
				
				LDA #03					; Red
				LDX #03					; Green
				LDY #00					; Blue
				JSR calc_rgb
				LDX #VGA_FILL_COL		; Yello Text
				JSR writeToPropeller	

				LDA #00					; Red
				LDX #00					; Green
				LDY #02					; Blue
				JSR calc_rgb
				LDX #VGA_FILL_BACK		; Blue background
				JSR writeToPropeller					
				
				LDA #$1					; Print with one char at the time
				LDX #VGA_AUTO_INC
				JSR writeToPropeller

				LDX	#30					; Print String
				LDY #0
				LDA #<String1     		; Load String Pointers.
				STA StringLo
				LDA #>String1
				STA StringHi
				JSR printStringXY
				
				LDA #$1F
				LDX #SID_MODVOL			; Full volumne, Low Pass filter
				JSR writeToPropeller

				LDA #$F1
				LDX #SID_RESFIL			; Full Resonance, filter 1 enabled.
				JSR writeToPropeller
				
				LDA #$25				; Attack = 2, Decay = 5, Sustain = 9 and Release = 6 for Channel 1
				LDX #SID_AD1
				JSR writeToPropeller
				LDA #$96
				LDX #SID_SR1
				JSR writeToPropeller
				
				LDA #$08				; Attack = 0, Decay = 8, Sustain = 4 and Release = 7 for Channel 2
				LDX #SID_AD2
				JSR writeToPropeller
				LDA #$47
				LDX #SID_SR2
				JSR writeToPropeller
				
				LDA #$74				; Attack = 7, Decay = 4, Sustain = 8 and Release = 9 for Channel 3
				LDX #SID_AD3
				JSR writeToPropeller
				LDA #$89
				LDX #SID_SR3
				JSR writeToPropeller
				
				LDA #>1928				; Pulse Width to 1928 for Channel 1
				LDX #SID_PW1LO
				JSR writeToPropeller
				LDA #>1928
				LDX #SID_PW1HI
				JSR writeToPropeller
				
				
				LDX	#18					; Print 0-64 of char set.
				LDY #3
				JSR setXY
				LDA #0
				LDX #VGA_PRINT
l1				JSR writeToPropeller
				INC
				CMP #64
				BNE l1
				
				LDX	#18					; Print 65-128 of char set.
				LDY #4
				JSR setXY
				LDA #64
				LDX #VGA_PRINT
l2				JSR writeToPropeller
				INC
				CMP #128
				BNE l2
				
				LDX	#18					; Print 129-192 of char set.
				LDY #5
				JSR setXY
				LDA #128
				LDX #VGA_PRINT
l3				JSR writeToPropeller
				INC
				CMP #192
				BNE l3
				
				LDX	#18					; Print 193-255 of char set.
				LDY #6
				JSR setXY
				LDA #192
				LDX #VGA_PRINT
l4				JSR writeToPropeller
				INC
				BNE l4
				

				LDX	#4					; Print String "64 Colors"
				LDY #21
				LDA #<StringTXT1   		; Load String Pointers.
				STA StringLo
				LDA #>StringTXT1
				STA StringHi
				JSR printStringXY
				LDA #0
				LDX #VGA_ROW_COLOR
				JSR writeToPropeller
				
				LDX	#4					; Print String "64 Colors"
				LDY #22
				LDA #<StringTXT2  		; Load String Pointers.
				STA StringLo
				LDA #>StringTXT2
				STA StringHi
				JSR printStringXY
				LDA #0
				LDX #VGA_ROW_COLOR
				JSR writeToPropeller
				
				LDX	#4					; Print String "64 Colors"
				LDY #23
				LDA #<StringTXT3 		; Load String Pointers.
				STA StringLo
				LDA #>StringTXT3
				STA StringHi
				JSR printStringXY
				LDA #0
				LDX #VGA_ROW_COLOR
				JSR writeToPropeller
				
				LDX	#4					; Print String "64 Colors"
				LDY #24
				LDA #<StringTXT4 		; Load String Pointers.
				STA StringLo
				LDA #>StringTXT4
				STA StringHi
				JSR printStringXY
				LDA #0
				LDX #VGA_ROW_COLOR
				JSR writeToPropeller
				
				LDX	#4					; Print String "64 Colors"
				LDY #25
				LDA #<StringTXT5  		; Load String Pointers.
				STA StringLo
				LDA #>StringTXT5
				STA StringHi
				JSR printStringXY
				LDA #0
				LDX #VGA_ROW_COLOR
				JSR writeToPropeller
				
				LDX	#4					; Print String "64 Colors"
				LDY #26
				LDA #<StringTXT6 		; Load String Pointers.
				STA StringLo
				LDA #>StringTXT6
				STA StringHi
				JSR printStringXY
				LDA #0
				LDX #VGA_ROW_COLOR
				JSR writeToPropeller
				
				LDX	#4					; Print String "64 Colors"
				LDY #27
				LDA #<StringTXT7		; Load String Pointers.
				STA StringLo
				LDA #>StringTXT7
				STA StringHi
				JSR printStringXY
				LDA #0
				LDX #VGA_ROW_COLOR
				JSR writeToPropeller
				
				LDX	#4					; Print String "64 Colors"
				LDY #28
				LDA #<StringTXT8		; Load String Pointers.
				STA StringLo
				LDA #>StringTXT8
				STA StringHi
				JSR printStringXY
				LDA #0
				LDX #VGA_ROW_COLOR
				JSR writeToPropeller
				
				STZ Current_Color		; Zero color rotation
				
mainLoop			  
			  
				LDX	#34					; Location for tracker data
				LDY #1
				JSR setXY
				
				; Channel 1
				LDY #0
				LDA (MusicLo),Y
				STA Temp
				STA NoteLo
				INY
				LDA (MusicLo),Y
				STA NoteHi
				INY
				JSR printHex			; Print values for Channel 1
				LDA Temp
				JSR printHex
				LDA #$20				; Couple of spaces..
				LDX #VGA_PRINT
				JSR writeToPropeller
				JSR writeToPropeller
				
				LDA NoteLo				; Get Note
				BEQ doNote1_off			; Note off ?
				LDX #SID_FR1LO			; Write low Frequency to SID
				JSR writeToPropeller
				
				LDA NoteHi
				LDX #SID_FR1HI			; Write low Frequency to SID
				JSR writeToPropeller
				
				LDA #NOTE1_ON			; Play note
				LDX #SID_CR1
				JSR writeToPropeller
				BRA doChannel2
				
doNote1_off		LDA #NOTE1_OFF			; Flag note off
				LDX #SID_CR1
				JSR writeToPropeller
				
				
doChannel2		
				; Channel 2
				LDA (MusicLo),Y
				STA Temp
				STA NoteLo
				INY
				LDA (MusicLo),Y
				STA NoteHi
				INY
				JSR printHex			; Print values for Channel 2
				LDA Temp
				JSR printHex
				LDA #$20				; Couple of spaces..
				LDX #VGA_PRINT
				JSR writeToPropeller
				JSR writeToPropeller

				LDA NoteLo
				BEQ doNote2_off
				LDX #SID_FR2LO
				JSR writeToPropeller
				
				LDA NoteHi
				LDX #SID_FR2HI
				JSR writeToPropeller
				
				LDA #NOTE2_ON
				LDX #SID_CR2
				JSR writeToPropeller
				BRA doChannel3
				
doNote2_off		LDA #NOTE2_OFF
				LDX #SID_CR2
				JSR writeToPropeller				
				
doChannel3
				; Channel 3
				LDA (MusicLo),Y
				STA Temp
				STA NoteLo
				INY
				LDA (MusicLo),Y
				STA NoteHi
				INY
				JSR printHex			; Print values for Channel 3
				LDA Temp
				JSR printHex
				LDA #$20				; Couple of spaces..
				LDX #VGA_PRINT
				JSR writeToPropeller
				JSR writeToPropeller
				
				LDA NoteLo
				BEQ doNote3_off
				LDX #SID_FR3LO
				JSR writeToPropeller
				
				LDA NoteHi
				LDX #SID_FR3HI
				JSR writeToPropeller
				
				LDA #NOTE3_ON
				LDX #SID_CR3
				JSR writeToPropeller
				BRA doCutOff
				
doNote3_off		LDA #NOTE3_OFF
				LDX #SID_CR3
				JSR writeToPropeller					

doCutOff
				; Cutoff
				LDA (MusicLo),Y
				STA Temp
				STA NoteLo
				INY
				LDA (MusicLo),Y
				STA NoteHi
				INY
				JSR printHex			; Print values for Cutoff
				LDA Temp
				JSR printHex
				
				LDA NoteLo				; Low value anded by 7 to mask bits
				AND #7
				LDX SID_FCLO			; Low cutoff frequency. It's only three bits...
				JSR writeToPropeller

				ROR NoteHi				; Shift three times to get rid of Low bits.
				ROR NoteLo				; We now have a value between 0 and 255.
				ROR NoteHi
				ROR NoteLo
				ROR NoteHi
				ROR NoteLo

				LDA NoteLo				; High cutoff frequency.
				LDX SID_FCLO
				JSR writeToPropeller
				
setNextNotes				
				LDA MusicLo				; Add 8 bytes to point to next note.
				CLC
				ADC #8
				STA MusicLo
				LDA MusicHi
				ADC #0
				STA MusicHi
				
				LDA (MusicLo)			; Do we need to reset ?
				INC						; If current note is 255, reset. Load current note, increase it and test for zero.
				BNE noMusicReset
				LDA #<MusicData     	; Reset Music Pointers.
				STA MusicLo
				LDA #>MusicData
				STA MusicHi

noMusicReset				

				LDA Current_Color		; Get current color
				STA Temp_Color			; Store in Temp
				INC Current_Color		; Next color in rotation.
				LDY #10					; Start on row 10
colorLoop
				TYA						; Set Row
				LDX #VGA_ROW
				JSR writeToPropeller
				LDA Temp_Color			; Get temp color
				ASL						; Shift up two bits, lower 2 bits not used in color.
				ASL
				LDX #VGA_ROW_BACK		; Set background color.
				JSR writeToPropeller
				INC Temp_Color			; Rotate.
				INY						; Next row.
				TYA
				CMP #50					; Done ?
				BNE colorLoop
				
				JSR delay				; Wait for it...
				JMP mainLoop			; Repeat forever....

;-------------------------------------------------------------------------
; writeToPropeller, A is data, X is Address
;-------------------------------------------------------------------------

writeToPropeller
				PHA				; Save A
tstBusy			LDA	PIA_ORB		; Read Output.
				AND	#$80		; Is High Bit set ?
				BNE	tstBusy		; Wait for Propeller to finish.
				PLA				; Restore A
				PHA				; Save it again
				STA	PIA_ORA
				TXA
				ORA #$40		; Set Write Flag.
				STA PIA_ORB		; Send data.
tstBusy2		LDA	PIA_ORB		; Read Output.
				AND	#$80		; Is High Bit set ?
				BEQ	tstBusy2	; Wait for Propeller to be busy.
				TXA
				AND #$3F		; Clear Write Flag.
				STA PIA_ORB		; Flag it.
				
				PLA				; Restore A
				RTS
				
;-------------------------------------------------------------------------
; delay: delay to see changes on screen.
;-------------------------------------------------------------------------

delay			LDA #$01
				LDY #$00            ; Loop 16*256*256 times...
				LDX #$00
dloop1			DEX
				BNE dloop1
				DEY
				BNE dloop1
				DEC
				BNE dloop1
				RTS

;-------------------------------------------------------------------------
; delay: delay to see changes on screen.
;-------------------------------------------------------------------------

delay2			LDA #$01
				LDY #$40            ; Loop 16*256*256 times...
				LDX #$00
dloop2			DEX
				BNE dloop2
				DEY
				BNE dloop2
				DEC
				BNE dloop2
				RTS				
				
;-------------------------------------------------------------------------
; calc_rgb: A = R, X = G, Y = B values between 0 and 3
; Resulting byte is RRGGBB00 each two bit values.
;-------------------------------------------------------------------------

calc_rgb		ROL				; Shift Red 6 bits
				ROL
				ROL
				ROL
				ROL
				ROL
				STA Temp		; Store in Temp
				TXA				; X to A and shift Green 4 bits
				ROL
				ROL
				ROL
				ROL
				CLC
				ADC Temp		; Add with Temp
				STA Temp		; Store in Temp
				TYA				; Y to A and shift Blue 2 bits
				ROL
				ROL
				CLC
				ADC Temp		; Add with Temp
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
				JSR PRHEX		; Output hex digit 
				PLA				; Restore A
PRHEX			AND #%00001111	; Mask LSD for hex print			  
				ORA #"0"		; Add "0"
				CMP #"9"+1		; Is it a decimal digit ?
				BCC ECHO		; Yes Output it
				ADC #6			; Add offset for letter A-F
ECHO			LDX #VGA_PRINT	; Print
				JSR writeToPropeller	; Print it...
				RTS


;-------------------------------------------------------------------------
; setXY: Set XY from X and Y register.
;-------------------------------------------------------------------------

setXY
				TXA
				LDX #VGA_COL
				JSR writeToPropeller
				TYA
				LDX #VGA_ROW
				JMP writeToPropeller
			  
;-------------------------------------------------------------------------
; printStringXY: Print a string preloaded in StringLo at XY from X and Y register.
;-------------------------------------------------------------------------

printStringXY
				TXA
				LDX #VGA_COL
				JSR writeToPropeller
				TYA
				LDX #VGA_ROW
				JSR writeToPropeller

;-------------------------------------------------------------------------
; printString: Print a string preloaded in StringLo
;-------------------------------------------------------------------------

printString
				LDY #0
nextChar		LDA (StringLo),Y	; Get character
				BEQ done_Printing	; Zero, we done...
				LDX #VGA_PRINT		; Print
				JSR writeToPropeller
				INY					; Next, cannot print more than 254 bytes or we wrap around in an infinite loop.
				BRA nextChar		; Continue
done_Printing	RTS

;-------------------------------------------------------------------------
; FUNCTION NAME	: Event Hander re-vectors
;-------------------------------------------------------------------------
IRQHandler:
				PHA
				PLA
				RTI

badVec			; $FFE0 - IRQRVD2(134)
				PHP
				PHA
				LDA #$FF
				;clear Irq
				PLA
				PLP
				RTI

	DATA

String1
				BYTE	"W65CSXB VGA and SID system...", $00 ; 1

StringTXT1		BYTE	" .d8888b.      d8888        .d8888b.   .d88888b.  888      .d88888b.  8888888b.   .d8888b.  ", 0
StringTXT2		BYTE	"d88P  Y88b    d8P888       d88P  Y88b d88P' 'Y88b 888     d88P' 'Y88b 888   Y88b d88P  Y88b ", 0
StringTXT3		BYTE	"888          d8P 888       888    888 888     888 888     888     888 888    888 Y88b.      ", 0
StringTXT4		BYTE	"888d888b.   d8P  888       888        888     888 888     888     888 888   d88P  'Y888b.   ", 0
StringTXT5		BYTE	"888P 'Y88b d88   888       888        888     888 888     888     888 8888888P'      'Y88b. ", 0
StringTXT6		BYTE	"888    888 8888888888      888    888 888     888 888     888     888 888 T88b         '888 ", 0
StringTXT7		BYTE	"Y88b  d88P       888       Y88b  d88P Y88b. .d88P 888     Y88b. .d88P 888  T88b  Y88b  d88P ", 0
StringTXT8		BYTE	" 'Y8888P'        888        'Y8888P'   'Y88888P'  88888888 'Y88888P'  888   T88b  'Y8888P'  ", 0
                                                                                            
MusicData
				WORD 1146,0,0,0
				WORD 1146,0,0,8
				WORD 1146,0,0,16
				WORD 0,0,0,24
				WORD 1146,0,0,32
				WORD 0,0,0,40
				WORD 0,0,0,48
				WORD 0,0,0,56
				WORD 2293,0,0,64
				WORD 0,0,0,72
				WORD 0,0,0,80
				WORD 0,0,0,88
				WORD 1146,0,0,96
				WORD 1146,0,0,104
				WORD 0,0,0,112
				WORD 0,0,0,120
				WORD 1146,0,0,128
				WORD 0,0,0,136
				WORD 0,0,0,144
				WORD 0,0,0,152
				WORD 2293,0,0,160
				WORD 0,0,0,168
				WORD 0,0,0,176
				WORD 0,0,0,184
				WORD 1146,0,0,192
				WORD 1146,0,0,200
				WORD 0,0,0,208
				WORD 0,0,0,216
				WORD 2293,0,0,224
				WORD 0,0,0,232
				WORD 2293,0,0,240
				WORD 0,0,0,248
				WORD 1531,0,0,256
				WORD 1531,0,0,264
				WORD 1531,0,0,272
				WORD 0,0,0,280
				WORD 1531,0,0,288
				WORD 0,0,0,296
				WORD 0,0,0,304
				WORD 0,0,0,312
				WORD 2728,0,0,320
				WORD 0,0,0,328
				WORD 0,0,0,336
				WORD 0,0,0,344
				WORD 1531,0,0,352
				WORD 1531,0,0,360
				WORD 0,0,0,368
				WORD 0,0,0,376
				WORD 1531,0,0,384
				WORD 0,0,0,392
				WORD 0,0,0,400
				WORD 0,0,0,408
				WORD 2728,0,0,416
				WORD 0,0,0,424
				WORD 0,0,0,432
				WORD 0,0,0,440
				WORD 1531,0,0,448
				WORD 1531,0,0,456
				WORD 0,0,0,464
				WORD 0,0,0,472
				WORD 2293,0,0,480
				WORD 0,0,0,488
				WORD 1531,0,0,496
				WORD 0,0,0,504
				WORD 1146,0,0,512
				WORD 0,0,0,520
				WORD 1146,0,0,528
				WORD 0,0,0,536
				WORD 1146,0,0,544
				WORD 0,0,0,552
				WORD 0,0,0,560
				WORD 0,0,0,568
				WORD 2293,0,0,576
				WORD 0,0,0,584
				WORD 0,0,0,592
				WORD 0,0,0,600
				WORD 1146,0,0,608
				WORD 1146,0,0,616
				WORD 0,0,0,624
				WORD 0,0,0,632
				WORD 1146,0,0,640
				WORD 0,0,0,648
				WORD 0,0,0,656
				WORD 0,0,0,664
				WORD 2293,0,0,672
				WORD 0,0,0,680
				WORD 0,0,0,688
				WORD 0,0,0,696
				WORD 1146,0,0,704
				WORD 1146,0,0,712
				WORD 0,0,0,720
				WORD 0,0,0,728
				WORD 2293,0,0,736
				WORD 0,0,0,744
				WORD 2293,0,0,752
				WORD 0,0,0,760
				WORD 2043,0,0,768
				WORD 2043,0,0,776
				WORD 2043,0,0,784
				WORD 0,0,0,792
				WORD 2043,0,0,800
				WORD 0,0,0,808
				WORD 0,0,0,816
				WORD 0,0,0,824
				WORD 3062,0,0,832
				WORD 0,0,0,840
				WORD 0,0,0,848
				WORD 0,0,0,856
				WORD 2043,0,0,864
				WORD 2043,0,0,872
				WORD 0,0,0,880
				WORD 0,0,0,888
				WORD 1531,0,0,896
				WORD 0,0,0,904
				WORD 0,0,0,912
				WORD 0,0,0,920
				WORD 3062,0,0,928
				WORD 0,0,0,936
				WORD 0,0,0,944
				WORD 0,0,0,952
				WORD 1531,0,0,960
				WORD 1531,0,0,968
				WORD 0,0,0,976
				WORD 0,0,0,984
				WORD 3062,0,0,992
				WORD 0,0,0,1000
				WORD 3062,0,0,1008
				WORD 0,0,0,1016
				WORD 1146,2043,0,1024
				WORD 1146,2043,0,1032
				WORD 1146,0,0,1040
				WORD 0,0,0,1048
				WORD 1146,0,0,1056
				WORD 0,0,0,1064
				WORD 0,0,0,1072
				WORD 0,0,0,1080
				WORD 2293,6490,0,1088
				WORD 0,0,0,1096
				WORD 0,0,0,1104
				WORD 0,0,0,1112
				WORD 1146,0,0,1120
				WORD 1146,0,0,1128
				WORD 0,0,0,1136
				WORD 0,0,0,1144
				WORD 1146,2043,0,1152
				WORD 0,2043,0,1160
				WORD 0,0,0,1168
				WORD 0,0,0,1176
				WORD 2293,2043,0,1184
				WORD 0,2043,0,1192
				WORD 0,0,0,1200
				WORD 0,0,0,1208
				WORD 1146,6490,0,1216
				WORD 1146,0,0,1224
				WORD 0,0,0,1232
				WORD 0,0,0,1240
				WORD 2293,0,0,1248
				WORD 0,0,0,1256
				WORD 2293,0,0,1264
				WORD 0,0,0,1272
				WORD 1531,2043,0,1280
				WORD 1531,2043,0,1288
				WORD 1531,0,0,1296
				WORD 0,0,0,1304
				WORD 1531,0,0,1312
				WORD 0,0,0,1320
				WORD 0,0,0,1328
				WORD 0,0,0,1336
				WORD 2728,6490,0,1344
				WORD 0,0,0,1352
				WORD 0,0,0,1360
				WORD 0,0,0,1368
				WORD 1531,0,0,1376
				WORD 1531,0,0,1384
				WORD 0,0,0,1392
				WORD 0,0,0,1400
				WORD 1531,2043,0,1408
				WORD 0,2043,0,1416
				WORD 0,0,0,1424
				WORD 0,0,0,1432
				WORD 2728,2043,0,1440
				WORD 0,2043,0,1448
				WORD 0,0,0,1456
				WORD 0,0,0,1464
				WORD 1531,6490,0,1472
				WORD 1531,0,0,1480
				WORD 0,0,0,1488
				WORD 0,0,0,1496
				WORD 2293,6490,0,1504
				WORD 0,0,0,1512
				WORD 1531,6490,0,1520
				WORD 0,0,0,1528
				WORD 1146,2043,0,1536
				WORD 0,2043,0,1544
				WORD 1146,0,0,1552
				WORD 0,0,0,1560
				WORD 1146,0,0,1568
				WORD 0,0,0,1576
				WORD 0,0,0,1584
				WORD 0,0,0,1592
				WORD 2293,6490,0,1600
				WORD 0,0,0,1608
				WORD 0,0,0,1616
				WORD 0,0,0,1624
				WORD 1146,0,0,1632
				WORD 1146,0,0,1640
				WORD 0,0,0,1648
				WORD 0,0,0,1656
				WORD 1146,2043,0,1664
				WORD 0,2043,0,1672
				WORD 0,0,0,1680
				WORD 0,0,0,1688
				WORD 2293,2043,0,1696
				WORD 0,2043,0,1704
				WORD 0,0,0,1712
				WORD 0,0,0,1720
				WORD 1146,6490,0,1728
				WORD 1146,0,0,1736
				WORD 0,0,0,1744
				WORD 0,0,0,1752
				WORD 2293,0,0,1760
				WORD 0,0,0,1768
				WORD 2293,0,0,1776
				WORD 0,0,0,1784
				WORD 2043,2043,0,1792
				WORD 2043,2043,0,1800
				WORD 2043,0,0,1808
				WORD 0,0,0,1816
				WORD 2043,0,0,1824
				WORD 0,0,0,1832
				WORD 0,0,0,1840
				WORD 0,0,0,1848
				WORD 3062,6490,0,1856
				WORD 0,0,0,1864
				WORD 0,0,0,1872
				WORD 0,0,0,1880
				WORD 2043,0,0,1888
				WORD 2043,0,0,1896
				WORD 0,0,0,1904
				WORD 0,0,0,1912
				WORD 1531,2043,0,1920
				WORD 0,2043,0,1928
				WORD 0,0,0,1936
				WORD 0,0,0,1944
				WORD 3062,0,0,1952
				WORD 0,0,0,1960
				WORD 0,2043,0,1968
				WORD 0,0,0,1976
				WORD 1531,6490,0,1984
				WORD 1531,0,0,1992
				WORD 0,2043,0,2000
				WORD 0,0,0,2008
				WORD 3062,6490,0,2016
				WORD 0,0,0,2024
				WORD 3062,6490,0,2032
				WORD 0,0,0,2040
				WORD 1146,2043,0,2040
				WORD 1146,2043,0,1024
				WORD 1146,0,0,512
				WORD 0,0,0,256
				WORD 1146,0,0,2040
				WORD 0,0,0,1024
				WORD 0,0,0,512
				WORD 0,0,0,256
				WORD 2293,6490,9175,2040
				WORD 0,0,9175,1024
				WORD 0,0,9175,512
				WORD 0,0,9175,256
				WORD 1146,0,0,2040
				WORD 1146,0,0,1024
				WORD 0,0,0,512
				WORD 0,0,0,256
				WORD 1146,2043,9175,2040
				WORD 0,2043,9175,1024
				WORD 0,0,0,512
				WORD 0,0,0,256
				WORD 2293,2043,13750,2040
				WORD 0,2043,13750,1024
				WORD 0,0,13750,512
				WORD 0,0,13750,256
				WORD 1146,6490,13750,2040
				WORD 1146,0,13750,1024
				WORD 0,0,13750,512
				WORD 0,0,13750,256
				WORD 2293,0,13750,2040
				WORD 0,0,13750,1024
				WORD 2293,0,0,2040
				WORD 0,0,0,1024
				WORD 1531,2043,6125,2040
				WORD 1531,2043,6125,1024
				WORD 1531,0,6125,512
				WORD 0,0,6125,256
				WORD 1531,0,6125,2040
				WORD 0,0,6125,1024
				WORD 0,0,6125,512
				WORD 0,0,6125,256
				WORD 2728,6490,0,2040
				WORD 0,0,0,1024
				WORD 0,0,0,512
				WORD 0,0,0,256
				WORD 1531,0,0,2040
				WORD 1531,0,0,1024
				WORD 0,0,0,512
				WORD 0,0,0,256
				WORD 1531,2043,5457,2040
				WORD 0,2043,5457,1024
				WORD 0,0,5457,512
				WORD 0,0,5457,256
				WORD 2728,2043,5457,2040
				WORD 0,2043,5457,1024
				WORD 0,0,0,512
				WORD 0,0,0,256
				WORD 1531,6490,7717,2040
				WORD 1531,0,7717,1024
				WORD 0,0,7717,512
				WORD 0,0,7717,256
				WORD 2293,6490,0,2040
				WORD 0,0,0,1024
				WORD 1531,6490,0,2040
				WORD 0,0,0,1024
				WORD 1146,2043,6875,2040
				WORD 0,2043,6875,1024
				WORD 1146,0,6875,2040
				WORD 0,0,6875,1024
				WORD 1146,0,6875,2040
				WORD 0,0,6875,1024
				WORD 0,0,6875,512
				WORD 0,0,6875,256
				WORD 2293,6490,6875,2040
				WORD 0,0,0,1024
				WORD 0,0,0,512
				WORD 0,0,0,256
				WORD 1146,0,6125,2040
				WORD 1146,0,6125,1024
				WORD 0,0,6125,512
				WORD 0,0,6125,256
				WORD 1146,2043,0,2040
				WORD 0,2043,0,1024
				WORD 0,0,0,512
				WORD 0,0,0,256
				WORD 2293,2043,5457,2040
				WORD 0,2043,5457,1024
				WORD 0,0,5457,512
				WORD 0,0,5457,256
				WORD 1146,6490,0,2040
				WORD 1146,0,0,1024
				WORD 0,0,0,512
				WORD 0,0,0,256
				WORD 2293,0,8175,2040
				WORD 0,0,8175,1024
				WORD 2293,0,0,2040
				WORD 0,0,0,1024
				WORD 2043,2043,9175,2040
				WORD 2043,2043,9175,1024
				WORD 2043,0,9175,512
				WORD 0,0,9175,256
				WORD 2043,2043,9175,2040
				WORD 0,2043,9175,1024
				WORD 0,0,0,512
				WORD 0,0,0,256
				WORD 3062,6490,9175,1024
				WORD 0,0,9175,512
				WORD 0,0,0,256
				WORD 0,0,0,128
				WORD 2043,0,0,2040
				WORD 2043,0,0,1024
				WORD 0,0,0,512
				WORD 0,0,0,256
				WORD 1531,2043,10915,2040
				WORD 0,2043,10915,1024
				WORD 0,0,10915,512
				WORD 0,0,10915,256
				WORD 3062,0,0,2040
				WORD 0,0,0,1024
				WORD 0,0,0,512
				WORD 0,0,0,256
				WORD 1531,6490,10300,2040
				WORD 1531,0,10300,1024
				WORD 0,2043,10300,512
				WORD 0,0,10300,256
				WORD 3062,6490,10300,2040
				WORD 0,0,10300,1024
				WORD 3062,6490,10300,2040
				WORD 0,0,10300,1024
				WORD 1146,2043,10300,1024
				WORD 1146,2043,10300,512
				WORD 1146,0,0,256
				WORD 0,0,0,128
				WORD 1146,0,6875,1024
				WORD 0,0,6875,512
				WORD 0,0,6875,256
				WORD 0,0,6875,128
				WORD 2293,6490,11560,1024
				WORD 0,0,10915,512
				WORD 0,0,0,256
				WORD 0,0,0,128
				WORD 1146,0,6875,1024
				WORD 1146,0,6875,512
				WORD 0,0,0,256
				WORD 0,0,0,128
				WORD 1146,2043,10915,1024
				WORD 0,2043,10300,512
				WORD 0,0,0,256
				WORD 0,0,0,128
				WORD 2293,2043,10915,1024
				WORD 0,2043,10915,512
				WORD 0,0,0,256
				WORD 0,0,0,128
				WORD 1146,6490,6875,1024
				WORD 1146,0,6875,512
				WORD 0,0,6875,256
				WORD 0,0,6875,128
				WORD 2293,0,6875,1024
				WORD 0,0,6875,512
				WORD 2293,0,0,256
				WORD 0,0,0,128
				WORD 1531,2043,8175,1024
				WORD 1531,2043,8175,512
				WORD 1531,0,8175,256
				WORD 0,0,8175,128
				WORD 1531,0,8175,1024
				WORD 0,0,8175,512
				WORD 0,0,8175,256
				WORD 0,0,8175,128
				WORD 2728,6490,8175,1024
				WORD 0,0,0,512
				WORD 0,0,0,256
				WORD 0,0,0,128
				WORD 1531,0,0,1024
				WORD 1531,0,0,512
				WORD 0,0,0,256
				WORD 0,0,0,128
				WORD 1531,2043,7717,1024
				WORD 0,2043,7717,512
				WORD 0,0,0,256
				WORD 0,0,0,128
				WORD 2728,2043,0,1024
				WORD 0,2043,0,512
				WORD 0,0,0,256
				WORD 0,0,0,128
				WORD 1531,6490,6125,1024
				WORD 1531,0,6125,512
				WORD 0,0,0,256
				WORD 0,0,0,128
				WORD 2293,6490,0,1024
				WORD 0,0,0,512
				WORD 1531,6490,0,1024
				WORD 0,0,0,512
				WORD 1146,2043,9175,2040
				WORD 0,2043,9175,512
				WORD 1146,0,9175,2040
				WORD 0,0,9175,512
				WORD 1146,0,9175,2040
				WORD 0,0,9175,1024
				WORD 0,0,9175,512
				WORD 0,0,9175,256
				WORD 2293,6490,9175,128
				WORD 0,0,9175,64
				WORD 0,0,9175,32
				WORD 0,0,9175,16
				WORD 1146,0,0,16
				WORD 1146,0,0,32
				WORD 0,0,0,128
				WORD 0,0,0,256
				WORD 1146,2043,0,512
				WORD 0,2043,0,1024
				WORD 0,0,0,1536
				WORD 0,0,0,2040
				WORD 2293,2043,7285,2040
				WORD 0,2043,6875,1536
				WORD 0,0,6875,1200
				WORD 0,0,6875,960
				WORD 1146,6490,0,800
				WORD 1146,0,0,640
				WORD 0,0,6490,800
				WORD 0,0,6125,960
				WORD 2293,0,6125,1200
				WORD 0,0,6125,1536
				WORD 2293,0,0,1840
				WORD 0,0,0,2040
				WORD 2043,2043,7285,2040
				WORD 2043,2043,6875,1984
				WORD 2043,0,6875,1920
				WORD 0,0,6875,1856
				WORD 2043,2043,6875,1792
				WORD 0,2043,0,1728
				WORD 0,0,0,1664
				WORD 0,0,0,1600
				WORD 3062,6490,8175,1536
				WORD 0,0,8175,1472
				WORD 0,0,0,1408
				WORD 0,0,0,1344
				WORD 2043,0,6490,1280
				WORD 2043,0,6125,1216
				WORD 0,0,6125,1152
				WORD 0,0,6125,1088
				WORD 1531,2043,0,1024
				WORD 0,2043,0,960
				WORD 0,0,0,896
				WORD 0,0,0,832
				WORD 3062,0,6125,768
				WORD 0,0,6125,704
				WORD 0,0,0,640
				WORD 0,0,0,576
				WORD 1531,6490,5457,512
				WORD 1531,0,5457,448
				WORD 0,2043,0,384
				WORD 0,0,0,320
				WORD 3062,6490,4087,256
				WORD 0,0,4087,192
				WORD 3062,6490,4087,128
				WORD 0,0,4087,64
				BYTE 255

				
	ENDS

;-----------------------------
;
;		Reset and Interrupt Vectors (define for 265, 816/02 are subsets)
;
;-----------------------------

Shadow_VECTORS	SECTION OFFSET $7EE0
								;65C816 Interrupt Vectors
								;Status bit E = 0 (Native mode, 16 bit mode)
				DW badVec		; $FFE0 - IRQRVD4(816)
				DW badVec		; $FFE2 - IRQRVD5(816)
				DW badVec		; $FFE4 - COP(816)
				DW badVec		; $FFE6 - BRK(816)
				DW badVec		; $FFE8 - ABORT(816)
				DW badVec		; $FFEA - NMI(816)
				DW badVec		; $FFEC - IRQRVD(816)
				DW badVec		; $FFEE - IRQ(816)
								;Status bit E = 1 (Emulation mode, 8 bit mode)
				DW badVec		; $FFF0 - IRQRVD2(8 bit Emulation)(IRQRVD(265))
				DW badVec		; $FFF2 - IRQRVD1(8 bit Emulation)(IRQRVD(265))
				DW badVec		; $FFF4 - COP(8 bit Emulation)
				DW badVec   	; $FFF6 - IRQRVD0(8 bit Emulation)(IRQRVD(265))
				DW badVec		; $FFF8 - ABORT(8 bit Emulation)
								; Common 8 bit Vectors for all CPUs
				DW badVec		; $FFFA -  NMIRQ (ALL)
				DW START		; $FFFC -  RESET (ALL)
				DW IRQHandler	; $FFFE -  IRQBRK (ALL)
	ENDS

vectors	SECTION OFFSET $FFE0
								;65C816 Interrupt Vectors
								;Status bit E = 0 (Native mode, 16 bit mode)
				DW badVec		; $FFE0 - IRQRVD4(816)
				DW badVec		; $FFE2 - IRQRVD5(816)
				DW badVec		; $FFE4 - COP(816)
				DW badVec		; $FFE6 - BRK(816)
				DW badVec		; $FFE8 - ABORT(816)
				DW badVec		; $FFEA - NMI(816)
				DW badVec		; $FFEC - IRQRVD(816)
				DW badVec		; $FFEE - IRQ(816)
								;Status bit E = 1 (Emulation mode, 8 bit mode)
				DW badVec		; $FFF0 - IRQRVD2(8 bit Emulation)(IRQRVD(265))
				DW badVec		; $FFF2 - IRQRVD1(8 bit Emulation)(IRQRVD(265))
				DW badVec		; $FFF4 - COP(8 bit Emulation)
				DW badVec		; $FFF6 - IRQRVD0(8 bit Emulation)(IRQRVD(265))
				DW badVec		; $FFF8 - ABORT(8 bit Emulation)
								; Common 8 bit Vectors for all CPUs
				DW badVec		; $FFFA -  NMIRQ (ALL)
				DW START		; $FFFC -  RESET (ALL)
				DW IRQHandler	; $FFFE -  IRQBRK (ALL)
	ENDS
	END
