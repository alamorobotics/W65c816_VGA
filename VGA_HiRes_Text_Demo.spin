''***************************************
''*  VGA High-Res Text Demo v1.0        *
''*  Author: Chip Gracey                *
''*  Copyright (c) 2006 Parallax, Inc.  *
''*  See end of file for terms of use.  *
''***************************************

' 3 June 2006

' This program (a quick piece of junk) demonstrates the VGA_HIRES_TEXT
' object. It is meant for use on the Propeller Demo Board Rev C. You can
' plug in a mouse for screen action. The mouse driver has been upgraded
' to provided bounded mouse coordinates. This makes constrained and
' scaled mouse movement mindless.

' The VGA_HIRES_TEXT went through much metamorphosis before completion.
' Initially, it ran on five COGs! I thought this was a miracle, since I
' didn't think we'd be able to get such high-res displays on the current
' Propeller chip. It used four COGs to build scan lines, and a fifth COG
' to display them. I kept looking at the problem and realized that it
' all came down to how little monkeying could be done with the data in
' order to display it. The scan line building was reorganized so that a
' single RDLONG picks up four lines worth of pixels for a character, and
' then buffers them within the COG, to later output them with back-to-
' back 'WAITVID color,pixels' and 'SHR pixels,#8' instruction sequences.
' This was so much faster that only two COGs were required for the job!
' They had to be synchronized so that they could step seamlessly into
' eachother's shoes as they traded the tasks of building scan lines and
' then displaying them. Anyway, it all came together nicely.

' Note that the driver has different VGA mode settings which you can de-
' comment and try. Also, the driver contains its own font. You will see
' the character set printed out when you run the program. There are some
' characters within the font that provide quarter-character-cell block
' pixels (for 128x64 characters, you can get 256x128 'pixels'). They can
' be used for graphing or crude picture drawing, where text can be inter-
' mingled.
'
' If you have a 15" LCD monitor, you must see the 1024x768 mode on it.
' At least on my little Acer AL1511 monitor, every pixel locks perfectly.


CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  cols = vgatext#cols
  rows = vgatext#rows
  chrs = cols * rows


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
  vgatext.start(16, @screen, @colors, @cx0, @sync)

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

input_mask                     long  $FF00      ' Make sure lower 16 bits are flagged as input...     

' General Purpose Registers
r0                              long  $0        ' should typically equal 0
r1                              long  $0
r2                              long  $0
r3                              long  $0

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