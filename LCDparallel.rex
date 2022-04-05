/*This example demostrates the display of strings on a LC display
with HD44780 or compatible controllers.
Seven GPIO pins are needed because the display is
operated in 4-bit mode. There is also an 8-bit mode,
but this would require 4 more GPIO pins.
In 4-bit mode only data line 4-7 are used.

ATTENTION: in this example the READ commands are not used, because
they work with 5V and would destroy the GPIO pins (max 3,3V)
of the Raspberry Pi

Based on JavaBSP
adolf-reichwein-schule.de/bildungsangebote/berufliches-gymnasium/
praktische-informatik/newsdetaildvt/news/
lcd-display-fuer-den-raspberry-pi/

public routines:
- setup
- init
- LCDprint line, String

To show something on the display the methods 1) setup and 2) init
have to be executed once at the start of the program
*/

------------------------------------------------------------------------
------------------------------------------------------------------------
/* Main Programm */


call setup				--load all required connections
call init				--Initialize display

say "Clock is running"				--outputs time and date
do forever
	call lcdprint 1 ,TIME()
	call lcdprint 2 , DATE()
end
exit
::requires BSF.CLS  --Get Java Support


------------------------------------------------------------------------
------------------------------------------------------------------------
/*
This routine expects a character and a mode(COMMANDREGISTER
 or DATAREGISTER).

first it is checked which mode was selected so that the display
knows whether a command or data follows.

After that the passed character is converted into an 8-bit string
(e.g. 10011101), which is then divided into an upper and lower nibble.
First the upper nibble is sent to the display and then the
lower nibble. The advantage of the 4-bit mode is the saving
of 4 data lines.
*/

::routine lcdByte
use arg bits, mode

/*Decide whether to write to the command or data register*/
if mode = .COMMANDREGISTER then do
	.rs~LOW
end
else do
	.rs~HIGH
end

/*Set data lines to low*/
.d4~LOW
.d5~LOW
.d6~LOW
.d7~LOW

/*Convert the passed character into an 8 bit string*/
bits = bits~c2x~x2b

/*create upper nibble*/
do i=1 to 4

if i = 1 then do
		if bits[i] = 1 then .d7~high
	end

else if i= 2 then do
		if bits[i] = 1 then .d6~high
	end
else if i = 3 then do
		if bits[i] = 1 then .d5~high
	end
else
		if bits[i] = 1 then .d4~high
end

/*Write data to the register*/
call syssleep 0.001
.e~high
call syssleep 0.001
.e~low

/*Set data lines to low*/
.d4~LOW
.d5~LOW
.d6~LOW
.d7~LOW

/*create lower nibble*/
do i=5 to 8

if i = 5 then do
		if bits[i] = 1 then .d7~high
	end

else if i= 6 then do
		if bits[i] = 1 then .d6~high
	end
else if i= 7 then do
		if bits[i] = 1 then .d5~high
	end
else
		if bits[i] = 1 then .d4~high
end

/*Write data to the register*/

call syssleep 0.001
.e~high
call syssleep 0.001
.e~low
call syssleep 0.001

return
------------------
------------------
/*The routine init initializes the display and brings it into the
desired mode (here 4-bit). Further possibilities can be found in
the data sheet of the HD44780 controller*/

::routine init public

call lcdByte "33"x , .COMMANDREGISTER
call syssleep 0.01
call lcdByte "32"x , .COMMANDREGISTER
call syssleep 0.01
call lcdByte "28"x , .COMMANDREGISTER
call syssleep 0.01
call lcdByte .LCD_CLEARDISPLAY , .COMMANDREGISTER
call syssleep 0.01
call lcdByte "0C"x , .COMMANDREGISTER
call syssleep 0.01
call lcdByte "06"x , .COMMANDREGISTER
call syssleep 0.01
call lcdByte .LCD_CLEARDISPLAY, .COMMANDREGISTER
call syssleep 0.05
return
--------------------
--------------------
/*With the routine LCD_print it is possible to print strings on
the LC-Display.

For this, first the desired row and then the string to be output must
be passed to the routine. Then the passed string is sent character
by character to the display.

It is possible to write up to 4 lines.
The string to be output will be truncated if the number
of characters is exceeded.
e.g. 16x2 display with 16 characters per row and two rows */

::Routine LCDprint public
use arg zeile, String

if zeile = 1 then call lcdByte .LCD_ROW_1 , .COMMANDREGISTER
else if zeile = 2 then call lcdByte .LCD_ROW_2 , .COMMANDREGISTER
else if zeile = 3 then call lcdByte .LCD_ROW_3 , .COMMANDREGISTER
else call lcdByte .LCD_ROW_4 , .COMMANDREGISTER
string = substr(string,1,16)
do j=1 to string~length
	call lcdByte String[j] , .DATAREGISTER
end
return

--------------------
--------------------
/*The routine setup is used to establish a connection to the GPIO pins
 of the Raspberry Pi and to make them available in the package pkgLocal.*/
::routine setup public

pkgLocal=.context~package~local  -- get package local directory

/*Establish connection to the GPIO pins*/
GpioFactory = bsf.loadClass("com.pi4j.io.gpio.GpioFactory")~getInstance
RaspiPin = bsf.loadClass("com.pi4j.io.gpio.RaspiPin")
pinState = bsf.loadClass("com.pi4j.io.gpio.PinState")

/*raspipin uses the WPI scheme for pinout*/
pkgLocal~rs = GpioFactory~provisionDigitalOutputPin(RaspiPin~GPIO_29,"rs",pinState~LOW)    --wpi 29
pkgLocal~e = GpioFactory~provisionDigitalOutputPin(RaspiPin~GPIO_28,"e",pinState~LOW)		--wpi 28
pkgLocal~d4 =GpioFactory~provisionDigitalOutputPin(RaspiPin~GPIO_22,"Datenbit1",pinState~LOW) --wpi 22
pkgLocal~d5 =GpioFactory~provisionDigitalOutputPin(RaspiPin~GPIO_23,"Datenbit2",pinState~LOW) --wpi 23
pkgLocal~d6 =GpioFactory~provisionDigitalOutputPin(RaspiPin~GPIO_24,"Datenbit3",pinState~LOW) --wpi 24
pkgLocal~d7 =GpioFactory~provisionDigitalOutputPin(RaspiPin~GPIO_25,"Datenbit4",pinState~LOW) --wpi 25

/* commands for the Lc display */
pkgLocal~LCD_CLEARDISPLAY = "01"x
pkgLocal~LCD_ROW_1 = "80"x
pkgLocal~LCD_ROW_2 = "C0"x
pkgLocal~LCD_ROW_3 = "94"x
pkgLocal~LCD_ROW_4 = "D4"x
pkgLocal~COMMANDREGISTER 	=	"00"x
pkgLocal~DATAREGISTER 		= 	"01"x
return

