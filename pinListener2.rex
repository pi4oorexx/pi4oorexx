/*--------------------------------------------------------------------*/
/*																	  */
/*							Pinlistener								  */
/*						with wiringPi support						  */
/*																	  */
/* This examples demonstrates the control of an LED with a pushbutton.*/
/* When the button is pressed, the LED is switched on and the status  */
/* of the LED is saved. When the button is pressed again, the LED	  */
/* is switched off. The current state of the input is sampled in this */
/* example with a sampling rate of 10 Hertz							  */
/*																      */
/*--------------------------------------------------------------------*/


/*creates a digital input and set the status of the input to low
used input Pin --> GPIO 24*/
address system "gpio mode 24 in"
address system "gpio mode 24 down"

/*creates a digital output and set status of the output to low
used output Pin --> GPIO 29*/

address system "gpio mode 29 out"
address system "gpio write 29 0"

LEDstat = 0			-- Stores the current status if the LED


say "Listening started - press the pushbutton to change the status of the LED"
currentState= .array~new
do forever			-- Pinlistener - constantly check input status

/*check status of input pin*/
address command "gpio read 24" with output using (currentState)

	if LEDstat = 0 then do					-- when LED off it is switched on
		if currentState[1] = 1 then do
			say "LED on"
			LEDstat = 1				--change status to 1 --> ON
			address system "gpio write 29 1"		--set outputpin to high
			call syssleep 0.4		--debounce the pushbutton
		end
	end

	else do									-- when LED on it is switched off
		if currentState[1] = 1 then do
			say "LED OFF"
			LEDstat = 0				--change status to 0 --> OFF
			address system "gpio write 29 0"		--set outputpin to low
			call syssleep 0.4		--debounce the pushbutton
		end
	end
call syssleep 0.1		--Sampling rate of the pushbutton  -> 10 hertz
end



