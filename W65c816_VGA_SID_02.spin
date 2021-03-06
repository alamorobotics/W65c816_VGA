{{

#######################################
#                                     #
# W65c816_VGA_SID_01                  #
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
  P16 - VGA V
  P17 - VGA H 
  P18 - VGA B0
  P19 - VGA B1
  P20 - VGA G0
  P21 - VGA G1
  P22 - VGA r0_VGA
  P23 - VGA r1_VGA
  P24 - SID Right Channel
  P25 - SID Left Channel  
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
  _xinfreq = 6_250_000


OBJ

  SID : "W65c816_SID_03"
  VGA : "W65c816_VGA_06"

VAR

  long dummy

PUB start

  SID.start_SID(24, 25)
  VGA.start_VGA(16)

DAT 

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