/*--------------------------------------------------------------------*/
/*																	  */
/*							GPIO output								  */
/*						   with pigpio support   					  */
/*																	  */
/* This example demonstrates how to define a GPIO pin as an			  */
/* output and switch it on and off. To see the status of the		  */
/* outputpin it is connected to a LED							      */
/*																	  */
/*--------------------------------------------------------------------*/

--start pigpiod daemon
address system "sudo systemctl start pigpiod"

-- define GPIO(BCM) pin as output
address system "pigs modes 21 w"

-- define initial state of GPIO pin(BCM GPIO 21)   --> default "LOW"
address system "pigs w 21 0"

-- Switch outputpin on and off

say "program started"
do forever
    address system "pigs w 21 1" 		-- turn output/LED on
	call syssleep 1
	address system "pigs w 21 0"		-- turn output/LED off
	call syssleep 1
end
exit



