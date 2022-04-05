/*--------------------------------------------------------------------*/
/*																	  */
/*							GPIO output								  */
/*						   with pi4j support    					  */
/*																	  */
/* This example demonstrates how to define a GPIO pin as an			  */
/* output and switch it on and off. To see the status of the		  */
/* outputpin it is connected to a LED							      */
/*																	  */
/*--------------------------------------------------------------------*/


/*load required java classes*/
gpio 	 = bsf.loadClass("com.pi4j.io.gpio.GpioFactory")~getInstance
RaspiPin = bsf.loadClass("com.pi4j.io.gpio.RaspiPin")
pinstate = bsf.loadClass("com.pi4j.io.gpio.PinState")

/*creates a digital output and set status of the output to low
used output Pin --> GPIO 29*/
LED =gpio~provisionDigitalOutputPin(RaspiPin~GPIO_29,pinstate~low)

-- Switch output pin on and off

say "program started"
do forever
    LED~high 		-- turn output/LED on
	call syssleep 1
	LED~low		    -- turn output/LED off
	call syssleep 1
end
exit

::requires BSF.CLS  -- get Java support
