/*--------------------------------------------------------------------*/
/*                                                                    */
/*                 bme280 with pi4oorexx.jar                          */
/*                                                                    */
/* This example shows the simple integration of bme280 sensor,        */
/* via I²C bus with the help of BSF4ooRexx and the pi4oorexx.jar      */
/* into an ooRexx program.        									  */
/* more infos with ~help											  */
/*--------------------------------------------------------------------*/

b = bsf.loadClass("at.pi4oorexx.bme280.BME280") -- load requires Java Class
b~help  -- use the help function to learn more about the available routines
b~measure  -- start measurement
say b~getPressure  -- get Pressure
say b~getTempCelcius  -- get Temperature in degree Celcius
say b~getTempFahrenheit  -- get Temperature in degree Fahrenheit
say b~getHumidity  -- get Humidity in %
::requires bsf.cls -- get Java Support
