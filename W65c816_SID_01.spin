{{

#######################################
#                                     #
# W65c816 VGA                         #
#                                     #
# Copyright (c) 2015 Fredrik Safstrom #
#                                     #
# See end of file for terms of use.   #
#                                     #
#######################################

############################# DESCIPTION ########################


########################### PIN ASSIGNMENTS #####################

  P0  - Data 0
  P1  - Data 1
  P2  - Data 2
  P3  - Data 3 
  P4  - Data 4 
  P5  - Data 5
  P6  - Data 6
  P7  - Data 7
  P8  - Address 0
  P9  - Address 1
  P10 - Address 2
  P11 - Address 3
  P12 - Address 4
  P13 - PHI 02
  P14 - XCS0B ($7F00-$7F1F) VGA
  P15 - XCS1B ($7F20-$7F3F) SID
  P16 - 
  P17 - 
  P18 - 
  P19 - 
  P20 - 
  P21 - 
  P22 - 
  P23 - 
  P24 - 
  P25 - 
  P26 - 
  P27 - 
  P28 - I2C SCL
  P29 - I2C SDA
  P30 - Serial Tx
  P31 - Serial Rx

########################### REVISIONS ###########################

}}
CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

    rightPin = 24  
    leftPin = 25
    
OBJ

    SID : "SIDcog"
    pst   : "parallax serial terminal"   

VAR

  long param

PUB start | i, j

  pst.start(38400)

  param := SID.start(rightPin, leftPin)  'Start the emulated SID chip in one cog 
  SID.resetRegisters                     'Reset all SID registers

  byte[param+27] := 3
  
  'byte[param] := 20
  'byte[param+1] := 10
  'byte[param+5] := $22
  'byte[param+6] := $22

  'byte[param+4] := $21
  
  ' Pass on Parameters.
  cognew(@SIDentry, param)   

  repeat
     waitcnt(cnt + (clkfreq/2))
     pst.str(string(pst#HM, " 00: "))
     pst.DEC(byte[param])
     pst.str(string("  "))

     pst.str(string("01: "))
     pst.DEC(byte[param+1])
     pst.str(string("    "))

     pst.str(string("02: "))
     pst.DEC(byte[param+2])
     pst.str(string("    "))

     pst.str(string("03: "))
     pst.DEC(byte[param+3])
     pst.str(string("    "))

     pst.str(string("04: "))
     pst.DEC(byte[param+4])
     pst.str(string("    "))

     pst.str(string("05: "))
     pst.DEC(byte[param+5])
     pst.str(string("    "))

     pst.str(string("06: "))
     pst.DEC(byte[param+6])
     pst.str(string("    "))

     pst.char(13)
     pst.char(13)
  

DAT                             org     0
SIDentry                        jmp     #initialization         'Start here...

'***************************************************
'* Constants                                       *
'***************************************************



' Used to figure out when to read the address and data
XCS1B_LOW                       long  $0
XCS1B_MASK                      long  $8000
PHI2_LOW                        long  $0
PHI2_MASK                       long  $2000
INPUT_MASK                      long  $FF00

'***************************************************
'* Variables                                       *
'***************************************************

' Parameters...
sid_address                     long  $0

' General Purpose Registers
r0                              long  $0        ' should typically equal 0
r1                              long  $0
r2                              long  $0
r3                              long  $0


'***************************************************
'* The driver itself                               *
'***************************************************

initialization

                        and     DIRA, INPUT_MASK                                ' Set input pins
                        mov     sid_address, PAR                                         ' Get parameter block address
main_loop
                        waitpeq PHI2_LOW, PHI2_MASK                             ' Wait for PHI 2 to go low 
                        waitpeq XCS1B_LOW, XCS1B_MASK                           ' Wait for XCS0B to go low
                        mov     r0, INA                                         ' Get input to figure out register and data
                        mov     r1, r0                                          ' Copy input to r1 for data
                        shr     r0, #$8                                         ' Shift 8 bits down.
                        and     r0, #$1F                                        ' Address $7F00-$7F1F, 0-31 in r0
                        and     r1, #$FF                                        ' Data in r1

                        mov     r2, #jumptable                                  ' Get Jump Table                                  
                        add     r2, r0                                          ' Add address
                        jmp     r2                                              ' Jump to subroutine.

'***************************************************
'* Sid 0 register 00 - $7F20                       *
'***************************************************
sid_00
                        mov     r2, sid_address                                 ' Get Sid address
                        add     r2, #$00                                        ' Add Offset
                        add     r2, r0                        
                        wrbyte  r1, r2                                          ' Set SID Value                        
                        jmp     #main_loop  

'***************************************************
'* Sid register 01 - $7F21                         *
'***************************************************
sid_01
                        mov     r2, sid_address                                 ' Get Sid address
                        add     r2, #$01                                        ' Add Offset
                        add     r2, r0                        
                        wrbyte  r1, r2                                          ' Set SID Value                        
                        jmp     #main_loop  

'***************************************************
'* Sid register 02 - $7F22                         *
'***************************************************
sid_02
                        mov     r2, sid_address                                 ' Get Sid address
                        add     r2, #$02                                        ' Add Offset
                        add     r2, r0                        
                        wrbyte  r1, r2                                          ' Set SID Value                        
                        jmp     #main_loop  

'***************************************************
'* Sid register 03 - $7F23                         *
'***************************************************
sid_03
                        mov     r2, sid_address                                 ' Get Sid address
                        add     r2, #$03                                        ' Add Offset
                        add     r2, r0                        
                        wrbyte  r1, r2                                          ' Set SID Value                        
                        jmp     #main_loop  


'***************************************************
'* Sid register 03 - $7F23                         *
'***************************************************
sid_04
                        mov     r2, sid_address                                 ' Get Sid address
                        add     r2, #$04                                        ' Add Offset
                        add     r2, r0                        
                        wrbyte  r1, r2                                          ' Set SID Value                        
                        jmp     #main_loop  

'***************************************************
'* Jump table, used to map address to subroutine.  *
'***************************************************
jumptable
                       jmp    #sid_00    '$7F20
                       jmp    #sid_00    '$7F21
                       jmp    #sid_00    '$7F22
                       jmp    #sid_00    '$7F23
                       jmp    #sid_00    '$7F24
                       jmp    #sid_00    '$7F25
                       jmp    #sid_00    '$7F26
                       jmp    #sid_01    '$7F27
                       jmp    #sid_01    '$7F28
                       jmp    #sid_01    '$7F29
                       jmp    #sid_01    '$7F2A
                       jmp    #sid_01    '$7F2B
                       jmp    #sid_01    '$7F2C
                       jmp    #sid_01    '$7F2D
                       jmp    #sid_02    '$7F2E
                       jmp    #sid_02    '$7F2F

                       jmp    #sid_02    '$7F30
                       jmp    #sid_02    '$7F31
                       jmp    #sid_02    '$7F32
                       jmp    #sid_02    '$7F33
                       jmp    #sid_02    '$7F34
                       jmp    #sid_03    '$7F35
                       jmp    #sid_03    '$7F36
                       jmp    #sid_03    '$7F37
                       jmp    #sid_03    '$7F38
                       jmp    #sid_04    '$7F39
                       jmp    #sid_04    '$7F3A
                       jmp    #sid_04    '$7F3B
                       jmp    #sid_04    '$7F3C
                       jmp    #sid_04    '$7F3D
                       jmp    #sid_04    '$7F3E
                       jmp    #sid_04    '$7F3F

                       fit      'Warn if we used up memory...

{{

┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}        