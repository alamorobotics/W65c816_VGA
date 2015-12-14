{Object_Title_and_Purpose}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

VAR
  long  symbol
   
OBJ
    pst   : "parallax serial terminal"


      
PUB start | i, j

  pst.start(38400)

  DIRA := 0  

  repeat
     pst.char(pst#HM)
     pst.char( 48 + ina[15])
     pst.char( 48 + ina[14])
     pst.char( 48 + ina[13])
     pst.char( 48 + ina[12])
     pst.char( 48 + ina[11])
     pst.char( 48 + ina[10])
     pst.char( 48 + ina[09])
     pst.char( 48 + ina[08])
     pst.char( 48 + ina[07])
     pst.char( 48 + ina[06])
     pst.char( 48 + ina[05])
     pst.char( 48 + ina[04])
     pst.char( 48 + ina[03])
     pst.char( 48 + ina[02])
     pst.char( 48 + ina[01])
     pst.char( 48 + ina[00])
     'pst.char(13) 


DAT
name    byte  "string_data",0        
        