/*--------------------------------------------------------------------*/
/*																	  */
/*							GPIO output								  */
/*						   with WiringPi support   					  */
/*																	  */
/* This example demonstrates how to define a GPIO pin as an			  */
/* output and switch it on and off. To see the status of the		  */
/* outputpin it is connected to a LED							      */
/*																	  */
/*--------------------------------------------------------------------*/


-- define GPIO pin as output
address system "gpio mode 29 out"

-- define initial state of GPIO pin(GPIO 29)   --> default "LOW"
address system "gpio write 29 0"


-- Switch outputpin on and off

say "program started"
do forever
    address system "gpio write 29 1" 		-- turn output/LED on
	call syssleep 1
	address system "gpio write 29 0"		-- turn output/LED off
	call syssleep 1
end
exit



