/*--------------------------------------------------------------------*/
/*                                                                    */
/*                 LCD_i2x.rex				                          */
/*                                                                    */
/* This example is a driver for a 16x2 LC display with HD44780 chip   */
/* and I2C 8574 backpack. However, the driver is also designed to 	  */
/* use a 20x4 display. Only the commented out parts of 				  */
/* the routine "printline" have to be changed.						  */
/*                                                                    */
/* public routines: 												  */
/* 1) setup															  */
/* 2) init															  */
/* 3) printline [String , line]										  */
/* 4) clear															  */
/*                                                                    */
/* setup and init are absolutely necessary and must be executed		  */
/* once at the beginning!!!											  */
/*--------------------------------------------------------------------*/


------------------------------------------------------------------------
------------------------------------------------------------------------
/*Make i2c device available*/
call setup
/*initialize the device*/
call init
/*clear the display*/
call clear

/* Sample Output*/
call printline "Hello World" , 1
call syssleep 1
call printline "from ooRexx" , 2
call syssleep 5
call clear

exit

::Requires BSF.CLS		--get Java Support


/*this routine clears the output on the display*/

::routine clear public

call printcmd "01"x
return

--------------------
--------------------
/*initialize display in 4 Bit Mode
more about this in the datasheet of the
hd44780 controller*/

::routine init public
--4 Bit Mode
call printcmd "33"x
--4 Bit Mode
call printcmd "32"x
-- 4Bit 2 Line
call printcmd "28"x
--Turn display on
call printcmd "0C"x
-- move cursor right
call printcmd "06"x
return


--------------------
--------------------
/*function to send a command to the controller*/

::routine printcmd
use arg cmd
mode = 0			-- Mode 0 = CMD mode
call write cmd~c2x~x2b , mode
return

--------------------
--------------------

/*routine for outputting text on the display*/

::routine printline public
use arg string, line
mode = 1						-- mode 1 = Datamode

if string~length > 16 then string = substr(string,1,16)
/*										-- for a 2004 Display
if string~length > 20 then string = substr(string,1,20)
*/
if line = 1 then call printcmd "80"x
if line = 2 then call printcmd "C0"x
/* 										--for a 2004 Display
if line = 3 then call printcmd "94"x
if line = 4 then call printcmd "D4"x
*/
do i=1 to string~length
	call write String[i]~c2x~x2b, mode
end

return

--------------------
--------------------

/*The routine write prepares the passed data or command and writes
it to the controller*/

::routine write
use arg byte, m

if m = 1 then do				--Datamode
	mode 	= 1101
	mode_ 	= 1001
end
else do							--Commandmode
	mode 	= 1100
	mode_	= 1000
end

-- create upper Nibble

upper_Nibble = substr(byte,1,4)
by_un_en	= 	toByte((upper_Nibble||mode)~b2x~x2d)
by_un_en_ 	=	toByte((upper_nibble||mode_)~b2x~x2d)

-- create lower Nibble
lower_Nibble = substr(byte,5,4)

by_ln_en	= 	toByte((lower_Nibble||mode)~b2x~x2d)
by_ln_en_ 	=	toByte((lower_nibble||mode_)~b2x~x2d)

--put the bytes into a Java Byte array

out=bsf.createJavaArray("byte.class", 4)
out~put(by_un_en,1)
out~put(by_un_en_,2)
out~put(by_ln_en,3)
out~put(by_ln_en_,4)

/*write byte by byte to the controller*/
do i= 1 to 4
	.device~write(out[i])
end
return

--------------------
--------------------
/*this routine converts the value to the appropriate format for a
Java byte array.
A byte in Java has a value between -128 -> +127
*/

::routine toByte
use arg value

if value > 127 then do
		value = value-256
		return value
	end
return value

--------------------
--------------------


 /* all entries can be retrieved via an environment symbol in the
  entire package. make i2C-Device  available in .package~local */

::routine setup public
 pkgLocal=.context~package~local  -- get package local directory
/*load required classes*/
	i2cbus = bsf.loadClass("com.pi4j.io.i2c.I2CBus")
/*get Instance of I2CFactory on I2C Bus 1 */
	bus = bsf.loadClass("com.pi4j.io.i2c.I2CFactory")~getInstance(i2cbus~BUS_1)
/*get Device on I2C Address 0x27 -> 39 decimal*/
	pkgLocal~device = bus~getDevice(39)
return



