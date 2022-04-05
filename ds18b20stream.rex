/*--------------------------------------------------------------------*/
/*                                                                    */
/*                 1-Wire DS18B20 Temperture Sensor                   */
/*                       with ooRexx Stream                           */
/*                                                                    */
/* In this example, a 1-wire temperature sensor is read out and       */
/* output using ooRexx Stream Class.                                  */
/*                                                                    */
/*--------------------------------------------------------------------*/

say "current Temp: "ds18b20GetTemp()
exit
------------------------------------------------------------------------
------------------------------------------------------------------------
/*get temp value from sensor */
::Routine ds18b20GetTemp public
Sensors = "ls /sys/bus/w1/devices"                      -- command to get all IDs of 1-Wire devices
sen=.array~new
address system sensors with output using (sen)
ds18b20 = sen[1]										-- get sensor id from first sensor
stream=.stream~new("/sys/bus/w1/devices/"||ds18b20||"/driver/"||ds18b20||"/temperature")~~open -- open Stream
return stream~lineIn/1000    --return read temp/ 1000
