/*--------------------------------------------------------------------*/
/*                                                                    */
/*                 MAX7219 8x8LED Matrix driver                       */
/*                                                                    */
/* This nutshell example illustrates the control of a MAX7219         */
/* Serially Interfaced, 8-Digit LED Display Driver.                   */
/* In this example, an 8x8 LED matrix is controlled.                  */
/* The display is controlled via a 3-Wire SPI connection.             */
/* The connection to the SPI bus is established via pi4j using        */
/* BSF4ooRexx.                                                        */
/*                                                                    */
/*    --- public routines: ---                                        */
/*                                                                    */
/* -)write: writes a Byte to the Display.                             */
/*                                                                    */
/*       The write command absolutely needs single char as values     */
/*       for register and value. e.g. write 1~x2c , 255~d2c           */
/*       register :1 -> 8     values from 0 - 255 as Char             */
/*                                                                    */
/*  -)printString: outputs the entered string as a ticker             */
/*                                                                    */
/*  -)setup: must be called first at the beginning of the program     */
/*                                                                    */
/*  -)init:must be called after setup. Activates the chip so          */
/*         that it accepts commands                                   */
/*                                                                    */
/*  -)clear: deletes the display content                              */
/*                                                                    */
/*  -)intensity: set brightness of the display.                       */
/*    e.g. call intensity "12"x   --> Min: "01"x -> Max:"15"x         */
/*                                                                    */
/*                                                                    */
/*  -)close: switches off the MAX7219 chip and clears the display.    */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*   this example was inspired by github.com/sharetop/max7219-java    */
/*--------------------------------------------------------------------*/


------------------------------------------------------------------------
------------------------------------------------------------------------
/* EXAMPLE to try the example, remove comment characters in lines 46 and 76 */
/* displays the entered text as a ticker. */

/*

/* Make constants, font and SPI classes and spi instance
    available in .package~local*/

call setupLED

/* initialize the MAX7219 driver to be able to send data to the
display*/

call init

/* The brightness of the display can be set here. This call is only
to illustrate that the brightness can also be changed during the
program run. When the init routine is called, the brightness is already
set values: Min = "01"x  Max: "15"x */

call intensity "15"x

/*The entered text is output on the display.
Attention! ASCII-127 font*/

say "Please insert String [Ascii-127]"
parse pull string
call printString string

-- shudown max7219 chip
call close

exit 0
*/

say "LEDMatrixDriver loaded"
------------------------------------------------------------------------
------------------------------------------------------------------------



/* printString:
routine to print a read string in ascii-127 encoding*/

::routine printString public
   use arg string
   mb=.mutableBuffer~new
   do i=1 to string~length
   	decCode   = c2d(String[i])  		-- decimal position in the ascii table
      pos=decCode*8+1                  -- position in font string
      fontBytes = .font~substr(pos,8)  -- eight corresponding FontBytes for the character
      mb~append(fontBytes)
   end
   call ticker mb~string
   return

--------------------
--------------------
/*

Ticker:
All transferred characters are output byte by byte on the display.
After each pass, the characters are advanced by one byte.
This creates a ticker.The prologue is appended to the string so that
the ticker starts from the right and the epilogue causes the characters
to disappear completely from the display.

*/

::routine ticker
   use arg charsAsFontBytes   -- already has 8 font bytes per character to be output

   epilog=.font~substr(1,8)
   prolog = epilog
   charsAsFontBytes= prolog || charsAsFontBytes || epilog
   do i=1 to (charsAsFontBytes~length-8)      --
      do idx=1 to 8           -- send single font bytes of the character
         call write idx~x2c, charsAsFontBytes[i+idx-1]  --write Byte
      end
   call speed 0.05	--speed of the ticker [s]  default: 0.05[s]
   end
   return

-------------------
-------------------

/* intensity:
Routine for setting the brightness of the display.
Minimum is 1 - Maximum is 15.
These values must be passed as hex values*/

::routine intensity public
   parse arg value
   call write .MAX7219_REG_INTENSITY, value
   return

-------------------
-------------------
/*This routine clears the display
For this purpose, all data registers are written with "00*/

::routine clear public
   do i=1 to .clearSequence~length
   	call write .clearSequence[i], "00"x
   end
   return

-------------------
-------------------

/* Initialization of the max7219 display driver

scanlimit ->7
decode ->0
displaytest-> 0
shutdown-> 1
intensity -> 1

This routine must be executed only at the first program call.
As long as the routine close is not used, the chip remains ready
for use. The command shutdown -> 1 switches the chip active.
After the close routine has been executed (shutdown -> 0), the
init routine must also be executed again.
*/
::routine init public
   call write .MAX7219_REG_SCANLIMIT   , "07"x
   call write .MAX7219_REG_DECODEMODE  , "00"x
   call write .MAX7219_REG_DISPLAYTEST , "00"x
   call write .MAX7219_REG_SHUTDOWN    , "01"x
   call intensity "12"x
   return

-------------------
-------------------
/*This routine switches off the MAX7219 chip and clears the display.*/

::routine close public
   call clear
   call write .MAX7219_REG_SHUTDOWN , "00"x
   return

-------------------
-------------------

/*This routine is used to specify the speed of the ticker.*/
::routine speed
   use arg s
   call syssleep s
   return

-------------------
-------------------

/*This routine writes the command into the specified register
in the MAX7219.
register and value must be a single character
register: 1 -> 8     values from 0 - 255 as Char
e.g. call write 1~x2c , 127~d2c
*/

::routine write public
   parse arg register , value			--- register and byteaddress
       --combine both characters and convert them into a Java byte array
   .spi~write(BsfRawBytes(register || value))	--- write array via spi
   return
-------------------
-------------------



  /* all entries can be retrieved via an environment symbol in the
  entire package. Make constants, font and SPI classes and spi instance

   available in .package~local */
::routine setupLED public

   pkgLocal=.context~package~local  -- get package local directory

   pkgLocal~clzSpiChannel=bsf.loadClass("com.pi4j.io.spi.SpiChannel")
   pkgLocal~clzSpiDevice=bsf.loadClass("com.pi4j.io.spi.SpiDevice")
   pkgLocal~spi = bsf.loadClass("com.pi4j.io.spi.SpiFactory")~getInstance(.clzSpiChannel~CS0, .clzSpiDevice~DEFAULT_SPI_SPEED,.clzSpiDevice~DEFAULT_SPI_MODE)

   -- define some constants
   /*Adressen der Register*/
   /* DATENBLATT MAX7219
   https://datasheets.maximintegrated.com/en/ds/MAX7219-MAX7221.pdf 06.02.2022
    */

   pkgLocal~MAX7219_REG_DECODEMODE ="09"x
   pkgLocal~MAX7219_REG_INTENSITY  ="0a"x
   pkgLocal~MAX7219_REG_SCANLIMIT  ="0b"x
   pkgLocal~MAX7219_REG_SHUTDOWN   ="0c"x
   pkgLocal~MAX7219_REG_DISPLAYTEST="0f"x

   /* clear sequence */
   pkgLocal~clearSequence= "01 02 03 04 05 06 07 08"x

   /* define font: eight bytes per char */
   pkgLocal~font=.resources~ascii127fontHex~makeString("line"," ")~space(1)~strip~x2c


/* Ascii 127 font
  -->https://github.com/sharetop/max7219-java/blob/master/src/main/java/cn/sharetop/max7219/Font.java
  (higher 128 code places seem to be defined for Codepage 437 (CP437) inferring from comments?)
*/
::resource ascii127fontHex
   00 00 00 00 00 00 00 00
   7E 81 95 B1 B1 95 81 7E
   7E FF EB CF CF EB FF 7E
   0E 1F 3F 7E 3F 1F 0E 00
   08 1C 3E 7F 3E 1C 08 00
   18 BA FF FF FF BA 18 00
   10 B8 FC FF FC B8 10 00
   00 00 18 3C 3C 18 00 00
   FF FF E7 C3 C3 E7 FF FF
   00 3C 66 42 42 66 3C 00
   FF C3 99 BD BD 99 C3 FF
   70 F8 88 88 FD 7F 07 0F
   00 4E 5F F1 F1 5F 4E 00
   C0 E0 FF 7F 05 05 07 07
   C0 FF 7F 05 05 65 7F 3F
   99 5A 3C E7 E7 3C 5A 99
   7F 3E 3E 1C 1C 08 08 00
   08 08 1C 1C 3E 3E 7F 00
   00 24 66 FF FF 66 24 00
   00 5F 5F 00 00 5F 5F 00
   06 0F 09 7F 7F 01 7F 7F
   40 DA BF A5 FD 59 03 02
   00 70 70 70 70 70 70 00
   80 94 B6 FF FF B6 94 80
   00 04 06 7F 7F 06 04 00
   00 10 30 7F 7F 30 10 00
   08 08 08 2A 3E 1C 08 00
   08 1C 3E 2A 08 08 08 00
   3C 3C 20 20 20 20 20 00
   08 1C 3E 08 08 3E 1C 08
   30 38 3C 3E 3E 3C 38 30
   06 0E 1E 3E 3E 1E 0E 06
   00 00 00 00 00 00 00 00
   00 06 5F 5F 06 00 00 00
   00 07 07 00 07 07 00 00
   14 7F 7F 14 7F 7F 14 00
   24 2E 6B 6B 3A 12 00 00
   46 66 30 18 0C 66 62 00
   30 7A 4F 5D 37 7A 48 00
   04 07 03 00 00 00 00 00
   00 1C 3E 63 41 00 00 00
   00 41 63 3E 1C 00 00 00
   08 2A 3E 1C 1C 3E 2A 08
   08 08 3E 3E 08 08 00 00
   00 80 E0 60 00 00 00 00
   08 08 08 08 08 08 00 00
   00 00 60 60 00 00 00 00
   60 30 18 0C 06 03 01 00
   3E 7F 71 59 4D 7F 3E 00
   40 42 7F 7F 40 40 00 00
   62 73 59 49 6F 66 00 00
   22 63 49 49 7F 36 00 00
   18 1C 16 53 7F 7F 50 00
   27 67 45 45 7D 39 00 00
   3C 7E 4B 49 79 30 00 00
   03 03 71 79 0F 07 00 00
   36 7F 49 49 7F 36 00 00
   06 4F 49 69 3F 1E 00 00
   00 00 66 66 00 00 00 00
   00 80 E6 66 00 00 00 00
   08 1C 36 63 41 00 00 00
   24 24 24 24 24 24 00 00
   00 41 63 36 1C 08 00 00
   02 03 51 59 0F 06 00 00
   3E 7F 41 5D 5D 1F 1E 00
   7C 7E 13 13 7E 7C 00 00
   41 7F 7F 49 49 7F 36 00
   1C 3E 63 41 41 63 22 00
   41 7F 7F 41 63 3E 1C 00
   41 7F 7F 49 5D 41 63 00
   41 7F 7F 49 1D 01 03 00
   1C 3E 63 41 51 73 72 00
   7F 7F 08 08 7F 7F 00 00
   00 41 7F 7F 41 00 00 00
   30 70 40 41 7F 3F 01 00
   41 7F 7F 08 1C 77 63 00
   41 7F 7F 41 40 60 70 00
   7F 7F 0E 1C 0E 7F 7F 00
   7F 7F 06 0C 18 7F 7F 00
   1C 3E 63 41 63 3E 1C 00
   41 7F 7F 49 09 0F 06 00
   1E 3F 21 71 7F 5E 00 00
   41 7F 7F 09 19 7F 66 00
   26 6F 4D 59 73 32 00 00
   03 41 7F 7F 41 03 00 00
   7F 7F 40 40 7F 7F 00 00
   1F 3F 60 60 3F 1F 00 00
   7F 7F 30 18 30 7F 7F 00
   43 67 3C 18 3C 67 43 00
   07 4F 78 78 4F 07 00 00
   47 63 71 59 4D 67 73 00
   00 7F 7F 41 41 00 00 00
   01 03 06 0C 18 30 60 00
   00 41 41 7F 7F 00 00 00
   08 0C 06 03 06 0C 08 00
   80 80 80 80 80 80 80 80
   00 00 03 07 04 00 00 00
   20 74 54 54 3C 78 40 00
   41 7F 3F 48 48 78 30 00
   38 7C 44 44 6C 28 00 00
   30 78 48 49 3F 7F 40 00
   38 7C 54 54 5C 18 00 00
   48 7E 7F 49 03 02 00 00
   0e 0f 51 51 51 7f 0e 00
   41 7F 7F 08 04 7C 78 00
   00 44 7D 7D 40 00 00 00
   60 70 40 40 7D 7D 00 00
   41 7F 7F 10 38 6C 44 00
   00 41 7F 7F 40 00 00 00
   7C 7C 18 38 1C 7C 78 00
   7C 7C 04 04 7C 78 00 00
   38 7C 44 44 7C 38 00 00
   7f 7f 11 11 11 1f 0e 00
   00 0e 11 11 11 7f 00 00
   44 7C 78 4C 04 1C 18 00
   48 5C 54 54 74 24 00 00
   00 04 3E 7F 44 24 00 00
   3C 7C 40 40 3C 7C 40 00
   1C 3C 60 60 3C 1C 00 00
   3C 7C 70 38 70 7C 3C 00
   44 6C 38 10 38 6C 44 00
   00 07 08 48 48 7f 00 00
   00 00 44 64 54 4c 44 00
   08 08 3E 77 41 41 00 00
   00 00 00 77 77 00 00 00
   41 41 77 3E 08 08 00 00
   02 03 01 03 02 03 01 00
   70 78 4C 46 4C 78 70 00
::END
--------------------
--------------------

::requires "BSF.CLS"    -- get ooRexx-Java bridge
