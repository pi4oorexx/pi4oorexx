/*--------------------------------------------------------------------*/
/*                                                                    */
/*                 I²C LC-Display with pi4oorexx.jar                  */
/*                                                                    */
/* This example shows the simple integration of an LC display,		  */
/* via I²C bus with the help of BSF4ooRexx and the pi4oorexx.jar file,*/
/* into an ooRexx program.        									  */
/* more infos with ~help											  */
/*--------------------------------------------------------------------*/


/* load all required classes*/
lcd = bsf.import("at.pi4oorexx.lcd.I2CLCD")
i2cbus = bsf.loadClass("com.pi4j.io.i2c.I2CBus")
/*get Instance of I2C Factory: I2C Bus 1   */
bus = bsf.loadClass("com.pi4j.io.i2c.I2CFactory")~getInstance(i2cbus~BUS_1)
/*get Device on I2C Address 0x27 -> 39 int*/
device = bus~getDevice(39)
/*build new object*/
screen =lcd~new(device)
/*use the help function to learn more about the available routines*/
screen~help
/*clear screen*/
screen~clear
/*display string on desired line*/
screen~display_string("Hello from",1)
screen~display_string("ooRexx",2)

call syssleep 3
screen~clear

/*display string on desired line and desired positon*/
screen~display_string_pos("Hello from",1,2)
screen~display_string_pos("ooRexx",2,3)
call syssleep 3
screen~clear
call syssleep 1
/*Backlight off-on*/
screen~backlight(0)
call syssleep 0.5
screen~backlight(1)

::requires BSF.CLS  --get Java Support
