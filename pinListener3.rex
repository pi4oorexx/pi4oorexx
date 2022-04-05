/*--------------------------------------------------------------------*/
/*																	  */
/*							Pinlistener								  */
/*					with pi4j and Actionlistener				      */
/*																	  */
/* This examples demonstrates the control of an LED with a pushbutton.*/
/* When the button is pressed, the LED is switched on and the status  */
/* of the LED is saved. When the button is pressed again, the LED	  */
/* is switched off.                                                   */
/*																      */
/*--------------------------------------------------------------------*/
/*    based on ListenGpioExample.java from pi4j from Robert Savage 	  */

/*load required java classes*/
gpio = bsf.loadClass("com.pi4j.io.gpio.GpioFactory")~getInstance
clzRaspiPin          = bsf.loadClass("com.pi4j.io.gpio.RaspiPin")
clzPinPullResistance = bsf.loadClass("com.pi4j.io.gpio.PinPullResistance")
clzPinstate = bsf.loadClass("com.pi4j.io.gpio.PinState")
/*creates a digital input and set the status of the input to low
used input Pin --> GPIO 24*/
PushButton = gpio~provisionDigitalInputPin(clzRaspiPin~GPIO_24,clzPinPullResistance~PULL_DOWN)

/*creates a digital output and set status of the output to low
used output Pin --> GPIO 29*/
pkgLocal=.context~package~local  -- get package local directory
pkgLocal~LED = gpio~provisionDigitalOutputPin(clzRaspiPin~GPIO_29, clzPinstate~low)
LEDstate = 0	-- Stores the current status if the LED   -- Initial status off


say "Listening started - press the pushbutton to change the status of the LED"

-- create and register gpio pin listener

rexxObj = .evl~new
clzGpioPinListenerDigital = bsf.loadClass("com.pi4j.io.gpio.event.GpioPinListenerDigital")
javaObj = bsfCreateRexxProxy(rexxObj, , clzGpioPinListenerDigital)
listeners=bsf.createJavaArrayOf(clzGpioPinListenerDigital, javaObj)
PushButton~addListener(listeners)

signal on syntax name syntax_but_ok
do forever				--active until cancel program with ctrl +c
  call syssleep .5
end
exit

syntax_but_ok:
  say "syntax_but_ok"
  exit


/*eventlistener class*/
::class evl
::method unknown                       -- catches all messages from Java
	expose LEDstate
	use arg eventObject, slotDir

	if LEDstate = 0 then do					-- when LED off it is switched on
		if slotdir[1]~getState~toString = "HIGH" then do
			say "LED on"
			LEDstate = 1				--change status to 1 --> ON
			.LED~high				--set outputpin to high

		end
	end

	else do									-- when LED on it is switched on
		if slotdir[1]~getState~toString = "HIGH" then do
			say "LED OFF"
			LEDstate = 0				--change status to 0 --> OFF
			.LED~low					--set outputpin to low

		end
	end

::requires BSF.CLS  --get Java Support
