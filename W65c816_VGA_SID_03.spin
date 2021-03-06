{{

#######################################
#                                     #
# W65c816_VGA_SID_03                  #
#                                     #
# Copyright (c) 2015 Fredrik Safstrom #
#                                     #
# See end of file for terms of use.   #
#                                     #
#######################################

############################# DESCIPTION ########################

Transfer from W65C816SXB to Propeller

1. W65C816SXB waits for PB7 (P15) to be low, $80
2. W65C816SXB puts data on PIA PA
3. W65C816SXB puts data on PIA PB with PB6 high. $40
4. Propeller waits for PB6 (P14) to go high.
5. Propeller reads PIA PA-PB and sets P15 high.
6, W65C816SXB waits for PB7 (P15)to be high, $80
7. W65C816SXB sets PIA PB6 (P14) low. $40
8. Propeller waits for PB6 (P14) to go low.
9. Propeller does it's thing...
10. Propeller sets P15 Low.

########################### PIN ASSIGNMENTS #####################

  P0  - Data 0 - PIA PA0
  P1  - Data 1 - PIA PA1
  P2  - Data 2 - PIA PA2
  P3  - Data 3 - PIA PA3 
  P4  - Data 4 - PIA PA4 
  P5  - Data 5 - PIA PA5
  P6  - Data 6 - PIA PA6
  P7  - Data 7 - PIA PA7
  P8  - Address 0 - PIA PB0
  P9  - Address 1 - PIA PB1
  P10 - Address 2 - PIA PB2
  P11 - Address 3 - PIA PB3
  P12 - Address 4 - PIA PB4
  P13 - Address 5 - 0 for VGA and 1 for SID  - PIA PB5
  P14 - Flag Write - Wait for High from W65C816SXB, once propeller flag busy, W65C816SXB sets low. - PIA PB6
  P15 - Flag BUSY - Set high by propeller when processing. - PIA PB7, only input...    
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
  _xinfreq = 5_000_000


OBJ

  SID : "W65c816_SID_04"
  VGA : "W65c816_VGA_07"

VAR

  long dummy

PUB start

  'SID.start_SID(24, 25)
  VGA.start_VGA

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