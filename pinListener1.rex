/*--------------------------------------------------------------------*/
/*																	  */
/*							Pinlistener								  */
/*						with pi4j support							  */
/*																	  */
/* This examples demonstrates the control of an LED with a pushbutton.*/
/* When the button is pressed, the LED is switched on and the status  */
/* of the LED is saved. When the button is pressed again, the LED	  */
/* is switched off. The current state of the input is sampled in this */
/* example with a sampling rate of 10 Hertz							  */
/*																      */
/*--------------------------------------------------------------------*/

/*load required java classes*/
gpio = bsf.loadClass("com.pi4j.io.gpio.GpioFactory")~getInstance
clzRaspiPin          = bsf.loadClass("com.pi4j.io.gpio.RaspiPin")
clzPinPullResistance = bsf.loadClass("com.pi4j.io.gpio.PinPullResistance")
pinstate = bsf.loadClass("com.pi4j.io.gpio.PinState")
/*creates a digital input and set the status of the input to low
used input Pin --> GPIO 24*/
PushButton = gpio~provisionDigitalInputPin(clzRaspiPin~GPIO_24,clzPinPullResistance~PULL_DOWN)

/*creates a digital output and set status of the output to low
used output Pin --> GPIO 29*/

LED =gpio~provisionDigitalOutputPin(clzRaspiPin~GPIO_29,pinstate~low)   -- Initial status off
LEDstate = 0			-- Stores the current status if the LED

say "Listening started - press the pushbutton to change the status of the LED"
do forever			-- Pinlistener - constantly check input status

	if LEDstate = 0 then do					-- when LED off it is switched on
		if PushButton~getState~toString = "HIGH" then do
			say "LED on"
			LEDstat = 1				--change status to 1 --> ON
			LED~high				--set outputpin to high
			call syssleep 0.4		--debounce the pushbutton
		end
	end

	else do									-- when LED on it is switched off
		if PushButton~getState~toString = "HIGH" then do
			say "LED OFF"
			LEDstat = 0				--change status to 0 --> OFF
			LED~low					--set outputpin to low
			call syssleep 0.4		--debounce the pushbutton
		end
	end
call syssleep 0.1		--Sampling rate of the pushbutton  -> 10 hertz
end
::Requires BSF.CLS  --get Java Support
