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
  P14 - RWB
  P15 - XCS0B ($7F00-$7F1F)
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

  cols = vgatext#cols
  rows = vgatext#rows
  chrs = cols * rows
  base_pin = 16

OBJ

  vgatext : "vga_hires_text"

VAR

  'sync long - written to -1 by VGA driver after each screen refresh
  long  sync
  'screen buffer - could be bytes, but longs allow more efficient scrolling
  long  screen[cols*rows/4]
  'row colors
  word  colors[rows]
  'cursor control bytes
  byte  cx0, cy0, cm0, cx1, cy1, cm1

  long virtual_address[8]

  long params[2]                                    'The address of this array gets 

  

PUB start | i, j

  'start vga text driver
  vgatext.start(base_pin, @screen, @colors, @cx0, @sync)

  params[0] := @virtual_address
  params[1] := @screen
  

  'set up colors
  repeat i from 0 to rows - 1
    colors[i] := %%0000_3200
    
  'colors[0] := %%3000_3330
  'colors[1] := %%0000_0300
  'colors[2] := %%1100_3300
  'colors[3] := %%0020_3330
  'colors[4] := %%3130_0000
  'colors[5] := %%3310_0000
  'colors[6] := %%1330_0000
  'colors[7] := %%0020_3300
  
  'colors[rows-1] := %%1110_2220

  'fill screen with characters
  repeat i from 0 to chrs - 1
    screen.byte[i] := i // $81
    screen.byte[i] := " "

  screen.byte[100] := "H"
  screen.byte[101] := "e"
  screen.byte[102] := "l"
  screen.byte[103] := "l"
  screen.byte[104] := "o"
  screen.byte[105] := " "
    
  'set cursor 0 to be a solid block
  cm0 := %001
  'set cursor 1 to be a blinking underscore
  cm1 := %111

  cognew(@entry, @params)

  
  'main loop - mouse controls stuff
  repeat

      repeat until sync       
      sync := 0


DAT                     org     0
entry                   jmp     #initialization         'Start here...

input_mask                      long  $FF00

' General Purpose Registers
r0                              long  $0        ' should typically equal 0
r1                              long  $0
r2                              long  $0
r3                              long  $0
XCS0B_LOW                       long  $0
XCS0B_MASK                      long  $8000
PHI2_HIGH                       long  $2000
PHI2_LOW                        long  $0
PHI2_MASK                       long  $2000


virtual_address_data            long  $0
screen_address                  long  $0


'***************************************************
'* The driver itself                               *
'***************************************************

initialization

                        and     DIRA, input_mask                               ' Set input pins

                        mov     r0, PAR                                         ' Get parameter block address
                        rdlong  virtual_address_data, r0                        ' Get virtual address
                        add     r0, #4                                          ' Get parameter block address
                        rdlong  screen_address, r0                              ' Get virtual address
                        mov     r1,#"Q"
                        mov     r2, screen_address
                        add     r2,#200
                        wrbyte  r1, r2
                        
:loop
                        waitpeq PHI2_LOW, PHI2_MASK                             ' Wait for PHI 2 to go low
                        waitpeq XCS0B_LOW, XCS0B_MASK                           ' Wait for XCS0B to go low
                        mov     r0, INA                                         ' Get input to use as data
                        mov     r1, r0
                        shr     r0, #$8                                         ' Shif 8 bits down.
                        and     r0, #$1F                                        ' Address
                        and     r1, #$FF                                        ' Data
                        
                        mov     r2, screen_address
                        add     r2, #300
                        add     r2, r0
                        wrbyte  r1, r2

                         
                        jmp     #:loop



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