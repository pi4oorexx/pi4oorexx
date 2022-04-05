/*--------------------------------------------------------------------*/
/*                                                                    */
/*                 			Binary Clock  							  */
/*  				based on the LEDMatrix Driver.					  */
/*                                                                    */
/* This nutshell example shows the current time on the matrix LED	  */
/* display in binary coding.									      */
/*                                                                    */
/*--------------------------------------------------------------------*/

-- get SPI Support
call setupLED
call syssleep 0.5
-- initialize the chip so that it can accept data
call init
call syssleep 0.5
/* create an array with the available registers and
 convert the numbers into characters*/
reg= .array~of(1~x2c,2~x2c,3~x2c,4~x2c,5~x2c,6~x2c,7~x2c,8~x2c)

do forever
	time = TIME()			--get system Time
	/*formats the read-in time for the output on the display
	colons are replaced by zeros and the string is inverted*/
	time = time~replaceAT("0",3)~replaceAT("0",6)~reverse
	/* console output in the usual format*/
	say time~reverse~replaceAT(":",3)~replaceAT(":",6)
	/*output the current time on the display. Byte by byte*/
	do i = 1 to 8
		call write reg[i] , time[i]~d2c
		call syssleep 0.02
	end
	call syssleep 0.1
end
exit

::requires "LEDMatrixDriver.rex"   --load Driver fir LED Matrix Modul
