/*--------------------------------------------------------------------*/
/*																	  */
/*							GPIO PWM								  */
/*						   with WiringPi support   					  */
/*																	  */
/* This example demonstrates the use of the PWM function of the		  */
/* Raspberry Pi. As an example, an SG90 servo is controlled with it.  */
/* The servo can rotate approximately 180°						      */
/*																	  */
/*--------------------------------------------------------------------*/
-- Operating frequency of the servo is 50 Hz -> 20ms PWM Period
--set GPIO Pin 26 to PWM mode
address system "gpio mode 26 pwm"
address system "gpio pwm-ms"	  -- PWM mark space mode
address system "gpio pwmc 192"    -- PWM clock divider
address system "gpio pwmr 2000"   -- PWM range

--Duty cycle = 0,5 -2,5 ms --> values between 50 and 250
--Duty cycle 150 = 0°   --> 50 =-90°  --> 250 = 180°

address system "gpio pwm 26 150"  --set servo to 0°

do forever
say " Enter a value between 50 and 250 "
parse pull angle
	if angle >49 & angle < 251 then do
		command = "gpio pwm 26 " angle
		address system command
		end
	else say "wrong input - must be between 50 and 250 "
end
exit