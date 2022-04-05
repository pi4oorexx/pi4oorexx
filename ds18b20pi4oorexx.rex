/*--------------------------------------------------------------------*/
/*                                                                    */
/*                 1-Wire DS18B20 Temperture Sensor                   */
/*               with BSF4ooRexx and pi4oorexx support                */
/*                                                                    */
/* In this example, a 1-wire temperature sensor is read out and       */
/* output using pi4oorexx.The used Java class for the pi4oorexx       */
/* JAR archive comes from the Diozero project by Matthew Lewis        */
/* www.diozero.com											          */
/* https://github.com/mattjlewis						              */
/*	                                                                  */
/* To get access to the sensor the setup_ds18b20 routine has to be    */
/* called first once												  */
/*--------------------------------------------------------------------*/

/*make sensor available*/
call setupDs18b20
/*outputs the currently measured temperature*/
say ds18b20GetTemp()
exit
------------------------------------------------------------------------
------------------------------------------------------------------------
/*this routine returns the read temperature. Because it is public,
it can also be used in other programs.*/

::routine ds18b20GetTemp public
return .s~get(0)~getTemperature

/* Make sensor available in .package~local*/

::routine setupDs18b20 public
pkgLocal=.context~package~local  -- get package local directory
sensor = bsf.loadClass("at.pi4oorexx.ds18b20.W1ThermSensor")
pkgLocal~s= sensor~getAvailableSensors
return
::requires BSF.CLS
