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

  long params[3]                                    'The address of this array gets 
  

PUB start | i, j

  'start vga text driver
  vgatext.start(base_pin, @screen, @colors, @cx0, @sync)

  ' Pass on Parameters.
  params[0] := @screen
  params[1] := @colors
  params[2] := @cx0
  cognew(@entry, @params)   

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
    
  'set cursor 0 to be a solid block
  cm0 := %000
  'set cursor 1 to be a blinking underscore
  cm1 := %111

  'main loop - mouse controls stuff
  repeat

      repeat until sync       
      sync := 0


DAT                             org     0
entry                           jmp     #initialization         'Start here...

'***************************************************
'* Constants                                       *
'***************************************************



' Used to figure out when to read the address and data
XCS0B_LOW                       long  $0
XCS0B_MASK                      long  $4000
PHI2_LOW                        long  $0
PHI2_MASK                       long  $2000
INPUT_MASK                      long  $FF00

'***************************************************
'* Variables                                       *
'***************************************************

' Parameters...
screen_address                  long  $0
color_address                   long  $0
cursor_address                  long  $0

' General Purpose Registers
r0                              long  $0        ' should typically equal 0
r1                              long  $0
r2                              long  $0
r3                              long  $0

' current stuff
current_screen_add              long  $0

' Registers, mapped to $7F00
current_Col                     long $0         ' $7F01
current_Row                     long $0         ' $7F02
auto_increase                   long $0         ' $7F05

'***************************************************
'* The driver itself                               *
'***************************************************

initialization

                        and     DIRA, INPUT_MASK                                ' Set input pins
                        mov     r0, PAR                                         ' Get parameter block address
                        rdlong  screen_address, r0                              ' Get virtual address
                        add     r0, #4                                          ' Next parameter address
                        rdlong  color_address, r0                               ' Get Screen address
                        add     r0, #4                                          ' Next parameter address
                        rdlong  cursor_address, r0                               ' Get color address
                        mov     current_screen_add,screen_address               ' Initiate screen address
                        
main_loop
                        waitpeq PHI2_LOW, PHI2_MASK                             ' Wait for PHI 2 to go low 
                        waitpeq XCS0B_LOW, XCS0B_MASK                           ' Wait for XCS0B to go low
                        mov     r0, INA                                         ' Get input to figure out register and data
                        mov     r1, r0                                          ' Copy input to r1 for data
                        shr     r0, #$8                                         ' Shift 8 bits down.
                        and     r0, #$1F                                        ' Address $7F00-$7F1F, 0-31 in r0
                        and     r1, #$FF                                        ' Data in r1

                        mov     r2, #jumptable                                  ' Get Jump Table                                  
                        add     r2, r0                                          ' Add address
                        jmp     r2                                              ' Jump to subroutine.

'***************************************************
'* Print a character $7F00                         *
'***************************************************
print_char
                        wrbyte  r1, current_screen_add                          ' "Print" by writing to shared memory.
                        add     current_screen_add, auto_increase               ' Add auto_increase to address
                        jmp     #main_loop                                      ' Back to work

'***************************************************
'* Set column $7F01                                *
'***************************************************
set_col
                        mov     current_Col, r1                                 ' Set current column
                        call    #calculate_row_col                              ' Recaluclate current address
                        jmp     #main_loop                                      ' Back to work

'***************************************************
'* Set row $7F02                                   *
'***************************************************
set_row
                        mov     current_Row, r1                                 ' Set current row
                        call    #calculate_row_col                              ' Recaluclate current address
                        jmp     #main_loop                                      ' Back to work

'***************************************************
'* Set row color $7F03                             *
'***************************************************
set_row_color
                        mov     r0, current_Row                                 ' Get current row.         
                        add     r0, r0                                          ' Double
                        add     r0, color_address                               ' Add color address.
                        wrbyte  r1, r0                                          ' Write color byte to memory.
                        jmp     #main_loop                                      ' Back to work

'***************************************************
'* Set row background color $7F04                  *
'***************************************************
set_row_color_back
                        mov     r0, current_Row                                 ' Get current row.         
                        add     r0, r0                                          ' Double
                        add     r0, #1                                          ' Add 1 
                        add     r0, color_address                               ' Add color address.
                        wrbyte  r1, r0                                          ' Write color byte to memory.
                        jmp     #main_loop                                      ' Back to work

'***************************************************
'* Set auto increase $7F05                         *
'***************************************************
set_auto_increase
                        mov     auto_increase, r1                               ' Set auto increase
                        jmp     #main_loop                                      ' Back to work

'***************************************************
'* Set cursor 1 X $7F10                            *
'***************************************************
set_cursor1_X
                        wrbyte  r1, cursor_address                              ' Set Cursor X                       
                        jmp     #main_loop                                      ' Back to work

'***************************************************
'* Set cursor 1 Y $7F11                            *
'***************************************************
set_cursor1_Y
                        mov     r0, cursor_address                              ' Get Cursor address
                        add     r0, #1                                          ' Add Offset
                        wrbyte  r1, r0                                          ' Set Cursor Y                        
                        jmp     #main_loop                                      ' Back to work

'***************************************************
'* Set cursor 1 Mode $7F12                         *
'***************************************************
set_cursor1_mode
                        mov     r0, cursor_address                              ' Get Cursor address
                        add     r0, #2                                          ' Add Offset
                        wrbyte  r1, r0                                          ' Set Cursor Mode                        
                        jmp     #main_loop                                      ' Back to work

'***************************************************
'* Set cursor 2 X $7F13                            *
'***************************************************
set_cursor2_X
                        mov     r0, cursor_address                              ' Get Cursor address
                        add     r0, #3                                          ' Add Offset
                        wrbyte  r1, r0                                          ' Set Cursor X                        
                        jmp     #main_loop                                      ' Back to work

'***************************************************
'* Set cursor 2 Y $7F14                            *
'***************************************************
set_cursor2_Y
                        mov     r0, cursor_address                              ' Get Cursor address
                        add     r0, #4                                          ' Add Offset
                        wrbyte  r1, r0                                          ' Set Cursor Y                        
                        jmp     #main_loop                                      ' Back to work

'***************************************************
'* Set cursor 2 Mode $7F15                         *
'***************************************************
set_cursor2_mode
                        mov     r0, cursor_address                              ' Get Cursor address
                        add     r0, #5                                          ' Add Offset
                        wrbyte  r1, r0                                          ' Set Cursor Mode                        
                        jmp     #main_loop                                      ' Back to work


'***************************************************
'* Subroutines                                     *
'***************************************************
calculate_row_col
                        mov     r1, current_Row                                 ' Get row.
                        shl     r1, #6                                          ' Multiply by 64
                        mov     r2, current_Row                                 ' Get row.
                        shl     r2, #5                                          ' Multiply by 32
                        add     r1,r2                                           ' Add to r1 
                        mov     r2, current_Row                                 ' Get row.
                        shl     r2, #2                                          ' Multiply by 4
                        add     r1,r2                                           ' Add to r1, each row is 100 chars, row*64+row*32+row*4 = 100*row
                        add     r1, current_Col                                 ' Add columns                                           
                        add     r1,screen_address                               ' Add address
                        mov     current_screen_add, r1                          ' Set current.
calculate_row_col_ret   
                        ret

'***************************************************
'* Jump table, used to map address to subroutine.  *
'***************************************************
jumptable
                       jmp    #print_char               '$7F00
                       jmp    #set_col                  '$7F01
                       jmp    #set_row                  '$7F02
                       jmp    #set_row_color            '$7F03
                       jmp    #set_row_color_back       '$7F04
                       jmp    #set_auto_increase        '$7F05
                       jmp    #print_char               '$7F06
                       jmp    #print_char               '$7F07
                       jmp    #print_char               '$7F08
                       jmp    #print_char               '$7F09
                       jmp    #print_char               '$7F0A
                       jmp    #print_char               '$7F0B
                       jmp    #print_char               '$7F0C
                       jmp    #print_char               '$7F0D
                       jmp    #print_char               '$7F0E
                       jmp    #print_char               '$7F0F

                       jmp    #set_cursor1_X            '$7F10
                       jmp    #set_cursor1_Y            '$7F11
                       jmp    #set_cursor1_mode         '$7F12
                       jmp    #set_cursor2_X            '$7F13
                       jmp    #set_cursor2_Y            '$7F14
                       jmp    #set_cursor2_mode         '$7F15
                       jmp    #print_char       '$7F16
                       jmp    #print_char       '$7F17
                       jmp    #print_char       '$7F18
                       jmp    #print_char       '$7F19
                       jmp    #print_char       '$7F1A
                       jmp    #print_char       '$7F1B
                       jmp    #print_char       '$7F1C
                       jmp    #print_char       '$7F1D
                       jmp    #print_char       '$7F1E
                       jmp    #print_char       '$7F1F

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