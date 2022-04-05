/*--------------------------------------------------------------------*/
/*                                                                    */
/*                 8x8Matrix LED Display with pi4oorexx.jar           */
/*                                                                    */
/* This example shows the simple integration of an Matrix LED display,*/
/* via SPI bus with the help of BSF4ooRexx and the pi4oorexx.jar file,*/
/* into an ooRexx program.        									  */
/* more infos with ~help											  */
/*--------------------------------------------------------------------*/

-- Import Class
matrix = bsf.importClass("at.pi4oorexx.matrix.MATRIX")
-- create new Object
m = matrix~new
/*use the help function to learn more about the available routines*/
m~help
/* initialize the MAX7219 driver to be able to send data to the
display*/
m~open
/*clear display*/
m~clear
/*change orientation of scrolling Text */
m~orientation(0)       --0,90,180,270
/*print scrolling Text*/
m~showMessage("Hello ooRexx")

/*write customdata to the Matrix Display*/
-- all eight register of the Display
reg= .array~of(1~x2c,2~x2c,3~x2c,4~x2c,5~x2c,6~x2c,7~x2c,8~x2c)
-- draw a rectangle
do i = 1 to 8
	val = (2**i-1)~d2c
	m~_write(BSFRawBytes(reg[i]||val))
	call syssleep 0.5
end
call syssleep 3
--clear screen
m~clear

::requires BSF.CLS   -- get java Support
