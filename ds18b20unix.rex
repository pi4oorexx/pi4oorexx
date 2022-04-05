/*--------------------------------------------------------------------*/
/*                                                                    */
/*                 1-Wire DS18B20 Temperture Sensor                   */
/*                       use Unix command                            */
/*                                                                    */
/* In this example, a 1-wire temperature sensor is read out and       */
/* output using Unix command tail and ooRexx                          */
/*                                                                    */
/*--------------------------------------------------------------------*/

say "current Temp: "ds18b20GetTemp()
exit
------------------------------------------------------------------------
------------------------------------------------------------------------
/*get temp value from sensor */
::Routine ds18b20GetTemp public
Sensors = "ls /sys/bus/w1/devices"                                            -- command to get all IDs of 1-Wire devices
sen=.array~new
address system sensors with output using (sen)
ds18b20 = sen[1]                                                              -- get sensor id from first sensor
temp = ("tail -n 1 /sys/bus/w1/devices/"ds18b20"/driver/"ds18b20"/w1_slave")  -- command to read last line
value = .array~new
address system temp with output using (value)   							  -- execute command and save return in array
parse var value "t=" grad      										          -- parse temperature from return
return grad/1000