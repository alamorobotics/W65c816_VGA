{{

#######################################
#                                     #
# W65C816_VGA_07                      #
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
  P27 - BE
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
  

PUB start_VGA | i

  'start vga text driver
  vgatext.start(base_pin, @screen, @colors, @cx0, @sync)



  ' Pass on Parameters.
  params[0] := @screen
  params[1] := @colors
  params[2] := @cx0
  cognew(@VGAentry, @params)   

  repeat
    repeat until sync       
      sync := 0

  DIRA := 0

  colors[0] := %%3000_3330
  colors[1] := %%0000_0300
  colors[2] := %%1100_3300
  colors[3] := %%0020_3330
  colors[4] := %%3130_0000
  colors[5] := %%3310_0000
  colors[6] := %%1330_0000
  colors[7] := %%0020_3300

  repeat i from 0 to chrs - 1
    screen.byte[i] := i // $81
    screen.byte[i] := " "  

  repeat
    screen.byte[100] := INA[15] + $30
    screen.byte[101] := INA[14] + $30
    screen.byte[102] := INA[13] + $30
    screen.byte[103] := INA[12] + $30
    screen.byte[104] := INA[11] + $30
    screen.byte[105] := INA[10] + $30
    screen.byte[106] := INA[9] + $30
    screen.byte[107] := INA[8] + $30
    screen.byte[108] := INA[7] + $30
    screen.byte[109] := INA[6] + $30
    screen.byte[110] := INA[5] + $30
    screen.byte[111] := INA[4] + $30
    screen.byte[112] := INA[3] + $30
    screen.byte[113] := INA[2] + $30
    screen.byte[114] := INA[1] + $30
    screen.byte[115] := INA[0] + $30



DAT                             org     0
VGAentry                        jmp     #initialization         'Start here...

'***************************************************
'* Constants                                       *
'***************************************************



' Used to figure out when to read the address and data
VGA_START                       long  $00004000
VGA_END                         long  $00000000
VGA_MASK                        long  $00004000

DIRECTION_MASK                  long  $00008000
COLOR_CLEAR_VALUE               long  %%0000_0300

'***************************************************
'* Variables                                       *
'***************************************************

' Parameters...
screen_address                  long  $0
color_address                   long  $0
cursor_address                  long  $0
sid_address                     long  $0    

' General Purpose Registers
r0                              long  $0        ' should typically equal 0
r1                              long  $0
r2                              long  $0
r3                              long  $0
r4                              long  $0

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

                        and     DIRA, DIRECTION_MASK                            ' Set input pins
                        or      DIRA, DIRECTION_MASK                            ' Set output pin.
                        and     OUTA, #0                                        ' Set output low.
                        mov     r0, PAR                                         ' Get parameter block address
                        rdlong  screen_address, r0                              ' Get virtual address
                        add     r0, #4                                          ' Next parameter address
                        rdlong  color_address, r0                               ' Get Screen address
                        add     r0, #4                                          ' Next parameter address
                        rdlong  cursor_address, r0                               ' Get color address
                        mov     current_screen_add,screen_address               ' Initiate screen address

                        mov     r0, color_address
                        mov     r2, #50                                         ' 50 rows
                        mov     r1, COLOR_CLEAR_VALUE

clear_loop              wrword  r1, r0                                          ' Write one long.
                        add     r0, #2                                          ' Increase address                                           
                        djnz    r2, #clear_loop                                 ' Decrease r3

                        mov     r1, #$20
                        jmp     #fill_screen

                        
main_loop
                        and     OUTA, #0                                        ' Set BUSY Flag Low.
                        waitpeq VGA_START, VGA_MASK                             ' Wait for Write Flag and VGA address. 
                        or      OUTA, DIRECTION_MASK                            ' Set BUSY Flag high.
                        mov     r0, INA                                         ' Get input to figure out register and data
                        waitpeq VGA_END, VGA_MASK                               ' Wait for Clear Write Flag and VGA address. 
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
'* Fill Screen $7F06                               *
'***************************************************
fill_screen
                        mov     r0, screen_address                              ' Load screen address
                        mov     r2, r1                                          ' Copy r1
                        shl     r2, #8                                          ' Multiply by 256
                        add     r1, r2                                          ' Add to r1
                        mov     r2, r1                                          ' Copy r1
                        shl     r2, #16                                         ' Multiply by 65536
                        add     r1, r2                                          ' Add to r1, r1 now has four of it's original byte so to say.  
                        mov     r2, #50                                         ' 50 rows
                        mov     r3, #25                                         ' 100 chars but divided by 4.

fill_loop1              wrlong  r1, r0                                          ' Write one long.
                        add     r0, #4                                          ' Increase address                                           
                        djnz    r3, #fill_loop1                                 ' Decrease r3
                        mov     r3, #25                                         ' Refill loop counter
                        djnz    r2, #fill_loop1                                 ' Decrease r2

                        mov     current_screen_add, screen_address              ' Reset pointer to top of screen.
                        
                        jmp     #main_loop                                      ' Back to work

'***************************************************
'* Fill color $7F07                                *
'***************************************************
fill_color
                        mov     r0, color_address
                        mov     r2, #50                                         ' 50 rows

fill_loop2              wrbyte  r1, r0                                          ' Write one long.
                        add     r0, #2                                          ' Increase address                                           
                        djnz    r2, #fill_loop2                                 ' Decrease r3
                        
                        jmp     #main_loop                                      ' Back to work

'***************************************************
'* Fill background color $7F08                     *
'***************************************************
fill_back
                        mov     r0, color_address
                        add     r0, #1
                        mov     r2, #50                                         ' 50 rows

fill_loop3              wrbyte  r1, r0                                          ' Write one long.
                        add     r0, #2                                          ' Increase address                                           
                        djnz    r2, #fill_loop3                                 ' Decrease r3
                        
                        jmp     #main_loop                                      ' Back to work

'***************************************************
'* Scroll one row up $7F09                         *
'***************************************************
scroll_up
                        mov     r0, screen_address
                        add     r0, #100
                        mov     r1, screen_address
                        mov     r2, #49                                         ' 49 rows
                        mov     r3, #25                                         ' 100 chars but divided by 4.

scroll_loop1            rdlong  r4, r0                                          ' Read Word
                        add     r0, #4                                          ' Increase address                                           
                        wrlong  r4, r1
                        add     r1, #4                                          ' Increase address                                           
                        djnz    r3, #scroll_loop1                                 ' Decrease r3
                        mov     r3, #25                                         ' Refill loop counter
                        djnz    r2, #scroll_loop1                                 ' Decrease r2
                        jmp     #main_loop                                      ' Back to work


'***************************************************
'* Scroll one row down $7F0A                       *
'***************************************************
scroll_down
                        mov     r0, #300                                        ' 300 to r0 
                        shl     r0, #4                                          ' Multiply by 16, 300x16 = 4800
                        add     r0, #96                                         ' 4800 + 96 = 4896,                         
                        add     r0, screen_address
                        mov     r1, r0
                        add     r1, #100
                        mov     r2, #49                                         ' 49 rows
                        mov     r3, #25                                         ' 100 chars but divided by 4.

scroll_loop2            rdlong  r4, r0                                          ' Read Word
                        sub     r0, #4                                          ' Increase address                                           
                        wrlong  r4, r1
                        sub     r1, #4                                          ' Increase address                                           
                        djnz    r3, #scroll_loop2                                 ' Decrease r3
                        mov     r3, #25                                         ' Refill loop counter
                        djnz    r2, #scroll_loop2                                 ' Decrease r2
                        jmp     #main_loop 

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
                       jmp    #print_char               '$7F00
                       jmp    #set_col                  '$7F01
                       jmp    #set_row                  '$7F02
                       jmp    #set_row_color            '$7F03
                       jmp    #set_row_color_back       '$7F04
                       jmp    #set_auto_increase        '$7F05
                       jmp    #fill_screen              '$7F06
                       jmp    #fill_color               '$7F07
                       jmp    #fill_back                '$7F08
                       jmp    #scroll_up                '$7F09
                       jmp    #scroll_down              '$7F0A
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